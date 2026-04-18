.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ubifs-authentication.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. UBIFS Authentication
.. sigma star gmbh
.. 2018

===============================
Hỗ trợ xác thực UBIFS
============================

Giới thiệu
============

UBIFS sử dụng khung fscrypt để cung cấp tính bảo mật cho tệp
nội dung và tên tập tin. Điều này ngăn chặn các cuộc tấn công mà kẻ tấn công có thể
đọc nội dung của hệ thống tập tin tại một thời điểm. Một ví dụ cổ điển
là điện thoại thông minh bị mất mà kẻ tấn công không thể đọc dữ liệu cá nhân được lưu trữ
trên thiết bị không có khóa giải mã hệ thống tập tin.

Tuy nhiên, ở trạng thái hiện tại, mã hóa UBIFS không ngăn chặn các cuộc tấn công trong đó
kẻ tấn công có thể sửa đổi nội dung hệ thống tập tin và người dùng sử dụng
thiết bị sau đó. Trong trường hợp như vậy, kẻ tấn công có thể sửa đổi hệ thống tập tin
nội dung tùy ý mà người dùng không nhận thấy. Một ví dụ là sửa đổi một
nhị phân để thực hiện hành động độc hại khi được thực thi [DMC-CBC-ATTACK]. Kể từ khi
hầu hết siêu dữ liệu hệ thống tập tin của UBIFS được lưu trữ ở dạng đơn giản, điều này làm cho nó
khá dễ dàng để trao đổi tập tin và thay thế nội dung của chúng.

Các hệ thống mã hóa toàn bộ đĩa khác như dm-crypt bao gồm tất cả siêu dữ liệu của hệ thống tệp,
điều này làm cho các kiểu tấn công như vậy trở nên phức tạp hơn, nhưng không phải là không thể.
Đặc biệt, nếu kẻ tấn công được cấp quyền truy cập vào thiết bị nhiều điểm trong
thời gian. Đối với dm-crypt và các hệ thống tệp khác được xây dựng dựa trên khối IO của Linux
lớp, hệ thống con dm-integrity hoặc dm-verity [DM-INTEGRITY, DM-VERITY]
có thể được sử dụng để xác thực dữ liệu đầy đủ ở lớp khối.
Chúng cũng có thể được kết hợp với dm-crypt [CRYPTSETUP2].

Tài liệu này mô tả cách tiếp cận để lấy nội dung tệp _và_ siêu dữ liệu đầy đủ
xác thực cho UBIFS. Vì UBIFS sử dụng fscrypt cho nội dung tệp và tệp
mã hóa tên, hệ thống xác thực có thể được gắn vào fscrypt sao cho
các tính năng hiện có như đạo hàm chính có thể được sử dụng. Tuy nhiên nó cũng nên
có thể sử dụng xác thực UBIFS mà không cần sử dụng mã hóa.


MTD, UBI & UBIFS
----------------

Trên Linux, hệ thống con MTD (Thiết bị công nghệ bộ nhớ) cung cấp một hệ thống thống nhất
giao diện để truy cập các thiết bị flash thô. Một trong những hệ thống con nổi bật hơn
hoạt động trên MTD là UBI (Hình ảnh khối chưa được sắp xếp). Nó cung cấp quản lý khối lượng
dành cho thiết bị flash và do đó hơi giống với LVM dành cho thiết bị khối. trong
Ngoài ra, nó còn xử lý lỗi I/O trong suốt và cân bằng hao mòn dành riêng cho đèn flash
xử lý. UBI cung cấp các khối xóa logic (LEB) cho các lớp trên nó
và ánh xạ chúng một cách trong suốt tới các khối xóa vật lý (PEB) trên đèn flash.

UBIFS là một hệ thống tập tin dành cho flash thô hoạt động trên UBI. Vì vậy, mặc
cân bằng và một số chi tiết cụ thể về flash được giao cho UBI, trong khi UBIFS tập trung vào
khả năng mở rộng, hiệu suất và khả năng phục hồi.

::

+-------------+ +*********+ +----------+ +------+
	ZZ0000ZZ * UBIFS * ZZ0001ZZ ZZ0002ZZ
	ZZ0003ZZ +*********+ +----------+ +------+
	ZZ0004ZZ +-----------------------------+ +----------+ +------+
	ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
	+-------------+ +-----------------------------+ +-----------+ +------+
	+--------------------------------------------------------------------------------+
	ZZ0009ZZ
	+--------------------------------------------------------------------------------+
	+-----------------------------+ +--------------------------+ +------+
	ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
	+-----------------------------+ +--------------------------+ +------+

Hình 1: Các hệ thống con nhân Linux để xử lý flash thô



Trong nội bộ, UBIFS duy trì nhiều cấu trúc dữ liệu được duy trì trên
đèn flash:

- ZZ0000ZZ: cây B+ flash trong đó các nút lá chứa dữ liệu hệ thống tệp
- ZZ0001ZZ: cấu trúc dữ liệu bổ sung để thu thập các thay đổi của FS trước khi cập nhật
  chỉ số bật đèn flash và giảm hao mòn đèn flash.
- ZZ0002ZZ: cây B+ trong bộ nhớ phản ánh FS hiện tại
  trạng thái để tránh việc đọc flash thường xuyên. Về cơ bản nó là trong bộ nhớ
  đại diện cho chỉ mục nhưng chứa các thuộc tính bổ sung.
- ZZ0003ZZ: cây B+ flash để chiếm không gian trống trên mỗi
  UBI LEB.

Trong phần còn lại của phần này, chúng tôi sẽ đề cập đến dữ liệu UBIFS flash
các cấu trúc chi tiết hơn. TNC ở đây ít quan trọng hơn vì nó không bao giờ
vẫn tồn tại trực tiếp trên đèn flash. Bạn cũng có thể tìm thêm thông tin chi tiết về UBIFS trong
[UBIFS-WP].


Chỉ mục UBIFS & Bộ đệm nút cây
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các thực thể UBIFS flash cơ bản được gọi là ZZ0004ZZ. UBIFS biết nhiều loại khác nhau
của các nút. Ví dụ. các nút dữ liệu (ZZ0000ZZ) lưu trữ các đoạn tệp
nội dung hoặc nút inode (ZZ0001ZZ) đại diện cho nút VFS.
Hầu hết tất cả các loại nút đều có chung một tiêu đề (ZZ0002ZZ) chứa cơ bản
thông tin như loại nút, độ dài nút, số thứ tự, v.v. (xem
ZZ0003ZZ trong nguồn kernel). Ngoại lệ là các mục của LPT
và một số loại nút ít quan trọng hơn như các nút đệm được sử dụng để đệm
nội dung không sử dụng được ở cuối LEB.

Để tránh phải viết lại toàn bộ cây B+ sau mỗi lần thay đổi, nó được triển khai
như ZZ0000ZZ, trong đó chỉ các nút đã thay đổi được viết lại và trước đó
các phiên bản của chúng đã lỗi thời mà không xóa chúng ngay lập tức. Kết quả là,
chỉ mục không được lưu trữ ở một nơi duy nhất trên flash mà ZZ0001ZZ được lưu trữ xung quanh
và có những bộ phận lỗi thời trên đèn flash miễn là LEB chứa chúng
không được UBIFS sử dụng lại. Để tìm phiên bản mới nhất của chỉ mục, UBIFS lưu trữ
một nút đặc biệt có tên ZZ0002ZZ vào UBI LEB 1 luôn trỏ đến
nút gốc gần đây nhất của chỉ mục UBIFS. Để có khả năng phục hồi, nút chính
cũng được sao chép thành LEB 2. Do đó, việc gắn UBIFS là một cách đọc đơn giản
LEB 1 và 2 để lấy nút chính hiện tại và từ đó lấy vị trí của
chỉ số on-flash gần đây nhất.

TNC là biểu diễn trong bộ nhớ của chỉ mục bật flash. Nó chứa một số
các thuộc tính thời gian chạy bổ sung cho mỗi nút không được duy trì. Một trong số đó là
một lá cờ bẩn đánh dấu các nút phải được duy trì vào lần tiếp theo
chỉ mục được ghi vào flash. TNC hoạt động như một bộ đệm ghi lại và tất cả
việc sửa đổi chỉ mục flash được thực hiện thông qua TNC. Giống như các bộ nhớ đệm khác,
TNC không phải phản chiếu chỉ mục đầy đủ vào bộ nhớ mà đọc các phần của
nó từ flash bất cứ khi nào cần thiết. ZZ0000ZZ là hoạt động UBIFS để cập nhật
cấu trúc hệ thống tập tin trên flash như chỉ mục. Trên mỗi lần xác nhận, các nút TNC
được đánh dấu là bẩn được ghi vào flash để cập nhật chỉ mục liên tục.


tạp chí
~~~~~~~

Để tránh làm đèn flash bị hao mòn, chỉ số chỉ được duy trì (ZZ0001ZZ) khi
đáp ứng một số điều kiện nhất định (ví dụ: ZZ0000ZZ). Nhật ký được dùng để ghi lại
mọi thay đổi (dưới dạng nút inode, nút dữ liệu, v.v.) giữa các lần xác nhận
của chỉ số. Trong quá trình gắn kết, nhật ký được đọc từ flash và phát lại
vào TNC (sẽ được tạo theo yêu cầu từ chỉ mục on-flash).

UBIFS dành một loạt LEB chỉ dành cho tạp chí có tên ZZ0001ZZ. các
số lượng LEB vùng nhật ký được định cấu hình khi tạo hệ thống tệp (sử dụng
ZZ0000ZZ) và được lưu trữ trong nút siêu khối. Vùng nhật ký chỉ chứa
hai loại nút: ZZ0002ZZ và ZZ0003ZZ. Một sự khởi đầu cam kết
nút được viết bất cứ khi nào một cam kết chỉ mục được thực hiện. Các nút tham chiếu là
được viết trên mỗi bản cập nhật tạp chí. Mỗi nút tham chiếu trỏ đến vị trí của
các nút khác (nút inode, nút dữ liệu, v.v.) trên flash là một phần của nút này
mục nhật ký. Các nút này được gọi là ZZ0004ZZ và mô tả hệ thống tệp thực tế
những thay đổi bao gồm cả dữ liệu của họ.

Khu vực nhật ký được duy trì dưới dạng một vòng. Mỗi khi nhật ký gần đầy,
một cam kết được bắt đầu. Điều này cũng ghi một nút bắt đầu cam kết để trong khi
mount, UBIFS sẽ tìm kiếm nút bắt đầu cam kết gần đây nhất và chỉ phát lại
mọi nút tham chiếu sau đó. Mỗi nút tham chiếu trước khi bắt đầu cam kết
nút sẽ bị bỏ qua vì chúng đã là một phần của chỉ mục flash.

Khi viết một mục nhật ký, UBIFS trước tiên phải đảm bảo có đủ không gian.
có sẵn để viết phần nút tham chiếu và chồi của mục này. Sau đó,
nút tham chiếu được ghi và sau đó các chồi mô tả tệp sẽ thay đổi.
Khi phát lại, UBIFS sẽ ghi lại mọi nút tham chiếu và kiểm tra vị trí của
các LEB được tham chiếu để khám phá các chồi. If these are corrupt or missing,
UBIFS sẽ cố gắng khôi phục chúng bằng cách đọc lại LEB. Tuy nhiên đây chỉ là
được thực hiện cho LEB được tham chiếu lần cuối của tạp chí. Chỉ điều này mới có thể trở nên hư hỏng
vì bị cắt điện. Nếu quá trình khôi phục không thành công, UBIFS sẽ không được gắn kết. Một lỗi
đối với mọi LEB khác sẽ trực tiếp khiến UBIFS không thực hiện được thao tác gắn kết.

::

ZZ0000ZZ ---------- MAIN AREA ------------- |

-----+------+------+--------+---- ------+------+------+--------------
        \ ZZ0000ZZ ZZ0001ZZ / / ZZ0002ZZ |               \
        / CS ZZ0003ZZ REF ZZ0004ZZ \ \ DENT ZZ0005ZZ INO |               /
        \ ZZ0006ZZ ZZ0007ZZ / / ZZ0008ZZ |               \
         ----+------+------+--------+--- -------+------+------+-------
                 ZZ0009ZZ ^ ^
                 ZZ0010ZZ ZZ0011ZZ
                 +------------------------+ |
                       ZZ0012ZZ
                       +------------------------------+


Hình 2: Bố cục flash UBIFS của khu vực nhật ký với các nút bắt đầu cam kết
                          (CS) và các nút tham chiếu (REF) trỏ đến khu vực chính
                          chứa chồi của chúng


Cây/Bảng thuộc tính LEB
~~~~~~~~~~~~~~~~~~~~~~~

Cây thuộc tính LEB được sử dụng để lưu trữ thông tin trên mỗi LEB. Điều này bao gồm
Loại và dung lượng LEB miễn phí và dung lượng ZZ0000ZZ (nội dung cũ, lỗi thời) [1]_ trên
LEB. Loại này rất quan trọng vì UBIFS không bao giờ trộn lẫn các nút chỉ mục với dữ liệu
các nút trên một LEB duy nhất và do đó mỗi LEB có một mục đích cụ thể. Đây lại là
hữu ích cho việc tính toán không gian trống. Xem [UBIFS-WP] để biết thêm chi tiết.

Cây thuộc tính LEB lại là cây B+, nhưng nó nhỏ hơn nhiều so với cây thuộc tính
chỉ số. Do kích thước nhỏ hơn nên nó luôn được viết thành một đoạn trên mỗi
cam kết. Vì vậy, việc cứu LPT là một hoạt động nguyên tử.


.. [1] Since LEBs can only be appended and never overwritten, there is a
   difference between free space ie. the remaining space left on the LEB to be
   written to without erasing it and previously written content that is obsolete
   but can't be overwritten without erasing the full LEB.


Xác thực UBIFS
====================

Chương này giới thiệu xác thực UBIFS cho phép UBIFS xác minh
tính xác thực và tính toàn vẹn của siêu dữ liệu và nội dung tệp được lưu trữ trên flash.


Mô hình mối đe dọa
------------

Xác thực UBIFS cho phép phát hiện sửa đổi dữ liệu ngoại tuyến. Trong khi nó
không ngăn chặn điều đó, nó cho phép mã (đáng tin cậy) kiểm tra tính toàn vẹn và
tính xác thực của nội dung tệp trên flash và siêu dữ liệu hệ thống tệp. Điều này bao gồm
các cuộc tấn công trong đó nội dung tập tin bị hoán đổi.

Xác thực UBIFS sẽ không bảo vệ khỏi việc khôi phục nội dung flash đầy đủ.
Tức là. kẻ tấn công vẫn có thể hủy flash và khôi phục nó sau đó mà không cần
phát hiện. Nó cũng sẽ không bảo vệ chống lại việc khôi phục một phần của từng cá nhân
chỉ số cam kết. Điều đó có nghĩa là kẻ tấn công có thể hoàn tác một phần các thay đổi.
Điều này có thể thực hiện được vì UBIFS không ghi đè ngay lập tức các dữ liệu lỗi thời
các phiên bản của cây chỉ mục hoặc tạp chí, nhưng thay vào đó lại đánh dấu chúng là lỗi thời
và việc thu gom rác sẽ xóa chúng sau đó. Kẻ tấn công có thể sử dụng điều này bằng cách
xóa các phần của cây hiện tại và khôi phục các phiên bản cũ vẫn còn
flash và vẫn chưa bị xóa. Điều này là có thể, bởi vì mọi cam kết
sẽ luôn viết một phiên bản mới của nút gốc chỉ mục và nút chính
mà không ghi đè lên phiên bản trước đó. Điều này còn được hỗ trợ thêm bởi
hoạt động cân bằng hao mòn của UBI sao chép nội dung từ một vật lý
khối xóa này sang khối khác và không xóa khối xóa đầu tiên một cách nguyên tử.

Xác thực UBIFS không bao gồm các cuộc tấn công mà kẻ tấn công có thể
thực thi mã trên thiết bị sau khi khóa xác thực được cung cấp.
Các biện pháp bổ sung như khởi động an toàn và khởi động đáng tin cậy phải được thực hiện để
đảm bảo rằng chỉ mã đáng tin cậy mới được thực thi trên thiết bị.


Xác thực
--------------

Để có thể tin cậy hoàn toàn dữ liệu được đọc từ flash, tất cả cấu trúc dữ liệu UBIFS
được lưu trữ trên flash được xác thực. Đó là:

- Chỉ mục bao gồm nội dung file, siêu dữ liệu file như phần mở rộng
  thuộc tính, độ dài tập tin, v.v.
- Nhật ký cũng chứa nội dung tệp và siêu dữ liệu bằng cách ghi lại các thay đổi
  vào hệ thống tập tin
- LPT lưu trữ siêu dữ liệu UBI LEB mà UBIFS sử dụng để tính toán không gian trống


Xác thực chỉ mục
~~~~~~~~~~~~~~~~~~~~

Thông qua khái niệm cây lang thang của UBIFS, nó chỉ chăm sóc
cập nhật và duy trì các phần đã thay đổi từ nút lá lên nút gốc
của cây B+ đầy đủ. Điều này cho phép chúng ta tăng thêm các nút chỉ mục của cây
với hàm băm trên các nút con của mỗi nút. Kết quả là về cơ bản chỉ số này cũng
một cây Merkle. Vì các nút lá của chỉ mục chứa hệ thống tập tin thực tế
dữ liệu, giá trị băm của các nút chỉ mục gốc của chúng sẽ bao gồm tất cả nội dung tệp
và siêu dữ liệu tập tin. Khi một tệp thay đổi, chỉ mục UBIFS sẽ được cập nhật tương ứng
từ nút lá đến nút gốc bao gồm cả nút chính. Quá trình này
có thể được nối để tính toán lại hàm băm chỉ cho mỗi nút đã thay đổi cùng một lúc.
Bất cứ khi nào một tập tin được đọc, UBIFS có thể xác minh các giá trị băm từ mỗi nút lá cho đến
nút gốc để đảm bảo tính toàn vẹn của nút.

Để đảm bảo tính xác thực của toàn bộ chỉ mục, nút chính UBIFS lưu trữ một
hàm băm có khóa (HMAC) trên nội dung của chính nó và hàm băm của nút gốc của chỉ mục
cây. Như đã đề cập ở trên, nút chính luôn được ghi vào flash bất cứ khi nào
chỉ mục được duy trì (tức là trên cam kết chỉ mục).

Sử dụng phương pháp này chỉ các nút chỉ mục UBIFS và nút chính được thay đổi thành
bao gồm một hàm băm. Tất cả các loại nút khác sẽ không thay đổi. Điều này làm giảm
chi phí lưu trữ rất quý giá đối với người dùng UBIFS (tức là được nhúng
thiết bị).

::

+--------------+
                             ZZ0000ZZ
                             ZZ0001ZZ
                             +--------------+
                                     |
                                     v
                            +-------------------+
                            ZZ0002ZZ
                            ZZ0003ZZ
                            ZZ0004ZZ
                            ZZ0005ZZ
                            +-------------------+
                               ZZ0006ZZ (fanout: 8)
                               ZZ0007ZZ
                       +-------+ +------+
                       ZZ0008ZZ
                       v v
            +-------------------+ +-------------------+
            ZZ0009ZZ ZZ0010ZZ
            ZZ0011ZZ ZZ0012ZZ
            ZZ0013ZZ ZZ0014ZZ
            ZZ0015ZZ ZZ0016ZZ
            +-------------------+ +-------------------+
                 ZZ0017ZZ ... |
                 v v v
               +----------+ +----------+ +-------------+
               ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ
               +----------+ +----------+ +-------------+


Hình 3: Vùng phủ sóng của nút băm chỉ mục và nút chính HMAC



Phần quan trọng nhất để đảm bảo độ bền và an toàn khi cắt điện là về mặt nguyên tử
duy trì nội dung băm và tập tin. Đây là logic UBIFS hiện có để biết cách thực hiện
các nút thay đổi được duy trì đã được thiết kế cho mục đích này sao cho
UBIFS có thể phục hồi một cách an toàn nếu xảy ra tình trạng mất điện trong khi vẫn tồn tại. Thêm
băm vào các nút chỉ mục không thay đổi điều này vì mỗi hàm băm sẽ được duy trì
nguyên tử cùng với nút tương ứng của nó.


Xác thực tạp chí
~~~~~~~~~~~~~~~~~~~~~~

Tạp chí cũng được xác thực. Vì nhật ký được viết liên tục
cũng cần phải thêm thông tin xác thực thường xuyên vào
nhật ký để trong trường hợp mất điện không có quá nhiều dữ liệu có thể được xác thực.
Điều này được thực hiện bằng cách tạo một hàm băm liên tục bắt đầu từ nút bắt đầu cam kết
qua các nút tham chiếu trước đó, nút tham chiếu hiện tại và chồi
nút. Thỉnh thoảng, bất cứ khi nào các nút xác thực phù hợp sẽ được thêm vào
giữa các nút chồi. Loại nút mới này chứa HMAC ở trạng thái hiện tại
của chuỗi băm. Bằng cách đó, một tạp chí có thể được xác thực đến ngày cuối cùng
nút xác thực. Phần đuôi của tạp chí có thể không có phần xác thực
nút không thể được xác thực và bị bỏ qua trong quá trình phát lại tạp chí.

Chúng tôi lấy hình ảnh này để xác thực tạp chí::

,,,,,,,,
    ,.........,.................................................
    ,. CS , hàm băm1.----.           băm2.----.
    ,.  ZZ0000Zhmac .    |hmac
    ,.  v, .    v.    v
    ,.REF#0,-> nụ -> nụ -> nụ.-> auth -> nụ -> nụ.-> auth ...
    ,..|...,.................................................
    , |   ,
    , |   ,,,,,,,,,,,,,,,
    .  |            băm3,----.
    , ZZ0001Zhmac
    , v , v
    , REF#1 -> chồi -> chồi,-> xác thực ...
    ,,,|,,,,,,,,,,,,,,,,,,
       v
      REF#2 -> ...
       |
       V.
      ...

Vì hàm băm cũng bao gồm các nút tham chiếu nên kẻ tấn công không thể sắp xếp lại hoặc
bỏ qua bất kỳ đầu tạp chí nào để phát lại. Kẻ tấn công chỉ có thể loại bỏ các nút chồi hoặc
các nút tham chiếu từ cuối tạp chí, tua lại một cách hiệu quả
hệ thống tập tin ở mức tối đa trở lại lần xác nhận cuối cùng.

Vị trí của khu vực nhật ký được lưu trữ trong nút chính. Kể từ khi chủ nhân
nút được xác thực bằng HMAC như mô tả ở trên thì không thể
giả mạo điều đó mà không bị phát hiện. Kích thước của vùng nhật ký được chỉ định khi
hệ thống tập tin được tạo bằng ZZ0000ZZ và được lưu trữ trong nút siêu khối.
Để tránh giả mạo giá trị này và các giá trị khác được lưu trữ ở đó, HMAC được thêm vào
cấu trúc siêu khối Nút siêu khối được lưu trữ trong LEB 0 và chỉ
được sửa đổi trên cờ tính năng hoặc các thay đổi tương tự, nhưng không bao giờ thay đổi trên tệp.


Xác thực LPT
~~~~~~~~~~~~~~~~~~

Vị trí của nút gốc LPT trên flash được lưu trong UBIFS master
nút. Vì LPT được viết và đọc nguyên tử trên mỗi lần chuyển giao, nên có
không cần xác thực các nút riêng lẻ của cây. Nó đủ để
bảo vệ tính toàn vẹn của LPT đầy đủ bằng hàm băm đơn giản được lưu trữ trong bản gốc
nút. Vì nút chính đã được xác thực nên tính xác thực của LPT có thể
được xác minh bằng cách xác minh tính xác thực của nút chính và so sánh
Hàm băm LTP được lưu trữ ở đó với hàm băm được tính toán từ LPT được đọc trên flash.


Quản lý khóa
--------------

Để đơn giản, xác thực UBIFS sử dụng một khóa duy nhất để tính toán HMAC
của các nút siêu khối, nút chính, nút bắt đầu cam kết và nút tham chiếu. Chìa khóa này phải được
có sẵn khi tạo hệ thống tập tin (ZZ0000ZZ) để xác thực
nút siêu khối. Hơn nữa, nó phải có sẵn trên mount của hệ thống tập tin
để xác minh các nút đã xác thực và tạo HMAC mới để thay đổi.

Xác thực UBIFS được thiết kế để hoạt động song song với mã hóa UBIFS
(fscrypt) để cung cấp tính bảo mật và tính xác thực. Kể từ khi mã hóa UBIFS
có cách tiếp cận khác nhau về chính sách mã hóa cho mỗi thư mục, có thể có
nhiều khóa chính fscrypt và có thể có các thư mục không được mã hóa.
Mặt khác, xác thực UBIFS có cách tiếp cận tất cả hoặc không có gì trong
có nghĩa là nó xác thực mọi thứ của hệ thống tập tin hoặc không có gì.
Vì điều này và vì xác thực UBIFS cũng có thể sử dụng được mà không cần
mã hóa, nó không chia sẻ cùng khóa chính với fscrypt nhưng quản lý
một khóa xác thực chuyên dụng.

API để cung cấp khóa xác thực vẫn chưa được xác định, nhưng
chìa khóa có thể ví dụ. được cung cấp bởi không gian người dùng thông qua một khóa tương tự như cách nó
hiện được thực hiện trong fscrypt. Tuy nhiên cần lưu ý rằng hiện tại
Cách tiếp cận fscrypt đã bộc lộ những sai sót của nó và không gian người dùng API cuối cùng sẽ
thay đổi [FSCRYPT-POLICY2].

Tuy nhiên, người dùng có thể cung cấp một cụm mật khẩu duy nhất
hoặc khóa trong không gian người dùng bao gồm xác thực và mã hóa UBIFS. Điều này có thể
được giải quyết bằng các công cụ không gian người dùng tương ứng lấy ra khóa thứ hai cho
xác thực ngoài khóa chính fscrypt dẫn xuất được sử dụng cho
mã hóa.

Để có thể kiểm tra xem khóa thích hợp có sẵn trên giá treo hay không, UBIFS
nút siêu khối sẽ lưu trữ thêm hàm băm của khóa xác thực. Cái này
Cách tiếp cận tương tự như cách tiếp cận được đề xuất cho chính sách mã hóa fscrypt v2
[FSCRYPT-POLICY2].


Tiện ích mở rộng trong tương lai
=================

Trong một số trường hợp nhất định khi nhà cung cấp muốn cung cấp hệ thống tệp được xác thực
hình ảnh cho khách hàng, có thể thực hiện được điều đó mà không cần chia sẻ bí mật
Khóa xác thực UBIFS. Thay vào đó, mỗi HMAC còn có một thiết bị kỹ thuật số
chữ ký có thể được lưu trữ ở nơi nhà cung cấp chia sẻ khóa chung cùng với
hình ảnh hệ thống tập tin. Trong trường hợp hệ thống tập tin này phải được sửa đổi sau đó,
UBIFS có thể trao đổi tất cả chữ ký số với HMAC ở lần lắp đầu tiên tương tự
đến cách hệ thống con IMA/EVM xử lý các tình huống như vậy. Phím HMAC
sau đó sẽ phải được cung cấp trước theo cách thông thường.


Tài liệu tham khảo
==========

[CRYPTSETUP2] ZZ0000ZZ

[DMC-CBC-ATTACK] ZZ0000ZZ

[DM-INTEGRITY] ZZ0000ZZ

[DM-VERITY] ZZ0000ZZ

[FSCRYPT-POLICY2] ZZ0000ZZ

[UBIFS-WP] ZZ0000ZZ