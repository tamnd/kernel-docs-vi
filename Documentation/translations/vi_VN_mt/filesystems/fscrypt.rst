.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/fscrypt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Mã hóa cấp hệ thống tập tin (fscrypt)
========================================

Giới thiệu
============

fscrypt là một thư viện mà hệ thống tập tin có thể nối vào để hỗ trợ
mã hóa minh bạch các tập tin và thư mục.

Lưu ý: "fscrypt" trong tài liệu này đề cập đến phần cấp hạt nhân,
được triển khai trong ZZ0000ZZ, trái ngược với công cụ không gian người dùng
ZZ0001ZZ.  Tài liệu này chỉ
bao gồm phần cấp hạt nhân.  Để biết ví dụ dòng lệnh về cách
sử dụng mã hóa, hãy xem tài liệu về công cụ không gian người dùng ZZ0002ZZ.  Ngoài ra, nên sử dụng
công cụ không gian người dùng fscrypt hoặc các công cụ không gian người dùng hiện có khác như
ZZ0003ZZ hoặc ZZ0004ZZ, kết thúc
sử dụng trực tiếp API của kernel.  Sử dụng các công cụ hiện có làm giảm
cơ hội giới thiệu các lỗi bảo mật của riêng bạn.  (Tuy nhiên, đối với
tính đầy đủ của tài liệu này dù sao cũng bao gồm API của kernel.)

Không giống như dm-crypt, fscrypt hoạt động ở cấp độ hệ thống tập tin chứ không phải
ở cấp độ thiết bị khối.  Điều này cho phép nó mã hóa các tập tin khác nhau
với các khóa khác nhau và có các tệp không được mã hóa trên cùng một
hệ thống tập tin.  Điều này hữu ích cho các hệ thống nhiều người dùng trong đó mỗi người dùng
dữ liệu ở trạng thái nghỉ cần phải được cách ly bằng mật mã với những dữ liệu khác.
Tuy nhiên, ngoại trừ tên tệp, fscrypt không mã hóa hệ thống tệp
siêu dữ liệu.

Không giống như eCryptfs, là một hệ thống tệp xếp chồng, fscrypt được tích hợp
trực tiếp vào các hệ thống tệp được hỗ trợ --- hiện tại là ext4, F2FS, UBIFS,
và CephFS.  Điều này cho phép các tập tin được mã hóa được đọc và ghi
không lưu vào bộ nhớ đệm cả các trang được giải mã và mã hóa trong
pagecache, do đó giảm gần một nửa bộ nhớ được sử dụng và đưa nó vào
dòng với các tập tin không được mã hóa.  Tương tự như vậy, một nửa số răng giả và
inode là cần thiết.  eCryptfs cũng giới hạn tên tệp được mã hóa ở mức 143
byte, gây ra sự cố tương thích ứng dụng; fscrypt cho phép
đầy đủ 255 byte (NAME_MAX).  Cuối cùng, không giống như eCryptfs, fscrypt API
có thể được sử dụng bởi những người dùng không có đặc quyền mà không cần phải gắn kết bất cứ thứ gì.

fscrypt không hỗ trợ mã hóa tập tin tại chỗ.  Thay vào đó, nó
hỗ trợ đánh dấu một thư mục trống là được mã hóa.  Sau đó, sau
không gian người dùng cung cấp khóa, tất cả các tập tin, thư mục thông thường và
các liên kết tượng trưng được tạo trong cây thư mục đó được minh bạch
được mã hóa.

Mô hình mối đe dọa
============

Tấn công ngoại tuyến
---------------

Với điều kiện không gian người dùng chọn khóa mã hóa mạnh, fscrypt
bảo vệ tính bí mật của nội dung tập tin và tên tập tin trong
trường hợp xảy ra sự xâm phạm ngoại tuyến vĩnh viễn tại một thời điểm duy nhất của
chặn nội dung thiết bị.  fscrypt không bảo vệ tính bí mật của
siêu dữ liệu không phải tên tệp, ví dụ: kích thước tập tin, quyền tập tin, tập tin
dấu thời gian và các thuộc tính mở rộng.  Ngoài ra, sự tồn tại và vị trí
số lỗ (khối chưa được phân bổ chứa tất cả các số 0 một cách hợp lý) trong
tập tin không được bảo vệ.

fscrypt không được đảm bảo để bảo vệ tính bảo mật hoặc tính xác thực
nếu kẻ tấn công có thể thao túng hệ thống tập tin ngoại tuyến trước
một người dùng được ủy quyền sau đó truy cập vào hệ thống tập tin.

Tấn công trực tuyến
--------------

fscrypt (và mã hóa lưu trữ nói chung) chỉ có thể cung cấp một số
bảo vệ chống lại các cuộc tấn công trực tuyến.  Cụ thể:

Tấn công kênh bên
~~~~~~~~~~~~~~~~~~~~

fscrypt chỉ có khả năng chống lại các cuộc tấn công kênh bên, chẳng hạn như thời gian hoặc
các cuộc tấn công điện từ, đến mức Linux cơ bản
Thuật toán mật mã API hoặc phần cứng mã hóa nội tuyến là.  Nếu một
thuật toán dễ bị tổn thương được sử dụng, chẳng hạn như triển khai dựa trên bảng
AES, kẻ tấn công có thể thực hiện cuộc tấn công kênh bên
chống lại hệ thống trực tuyến.  Các cuộc tấn công kênh bên cũng có thể được thực hiện
chống lại các ứng dụng tiêu thụ dữ liệu được giải mã.

Truy cập tập tin trái phép
~~~~~~~~~~~~~~~~~~~~~~~~

Sau khi khóa mã hóa đã được thêm vào, fscrypt không ẩn khóa
nội dung hoặc tên tệp văn bản gốc từ những người dùng khác trên cùng một
hệ thống.  Thay vào đó, các cơ chế kiểm soát truy cập hiện có như chế độ tập tin
bit, POSIX ACL, LSM hoặc không gian tên nên được sử dụng cho mục đích này.

(Để biết lý do đằng sau điều này, hãy hiểu rằng mặc dù chìa khóa là
thêm vào, tính bảo mật của dữ liệu, từ góc độ của
bản thân hệ thống, ZZ0000ZZ được bảo vệ bởi các tính chất toán học của
mã hóa mà chỉ bằng tính chính xác của kernel.
Do đó, mọi kiểm tra kiểm soát truy cập dành riêng cho mã hóa sẽ chỉ đơn thuần là
được thực thi bởi kernel ZZ0001ZZ và do đó phần lớn sẽ dư thừa
với nhiều cơ chế kiểm soát truy cập đã có sẵn.)

Thỏa hiệp bộ nhớ kernel chỉ đọc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trừ khi ZZ0000ZZ được sử dụng, kẻ tấn công sẽ giành được quyền
khả năng đọc từ bộ nhớ hạt nhân tùy ý, ví dụ: bằng cách gắn một
tấn công vật lý hoặc bằng cách khai thác lỗ hổng bảo mật kernel, có thể
xâm phạm tất cả các khóa fscrypt hiện đang được sử dụng.  Điều này cũng
mở rộng sang các cuộc tấn công khởi động nguội; nếu hệ thống bị tắt nguồn đột ngột,
các phím mà hệ thống đang sử dụng có thể vẫn còn trong bộ nhớ trong một thời gian ngắn.

Tuy nhiên, nếu sử dụng các khóa bọc phần cứng thì fscrypt master
khóa và khóa mã hóa nội dung tệp (nhưng không phải các loại fscrypt khác
các khóa con như khóa mã hóa tên tệp) được bảo vệ khỏi
sự thỏa hiệp của bộ nhớ kernel tùy ý.

Ngoài ra, fscrypt cho phép loại bỏ các khóa mã hóa khỏi
kernel, có thể bảo vệ chúng khỏi bị xâm phạm sau này.

Chi tiết hơn, FS_IOC_REMOVE_ENCRYPTION_KEY ioctl (hoặc
FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS ioctl) có thể xóa bản gốc
khóa mã hóa từ bộ nhớ kernel.  Nếu làm như vậy, nó cũng sẽ cố gắng
loại bỏ tất cả các nút được lưu trong bộ nhớ cache đã được "mở khóa" bằng khóa,
do đó xóa sạch các khóa trên mỗi tệp của chúng và làm cho chúng xuất hiện lại một lần nữa
"bị khóa", tức là ở dạng bản mã hoặc dạng mã hóa.

Tuy nhiên, những ioctls này có một số hạn chế:

- Khóa mỗi tệp cho các tệp đang sử dụng sẽ bị xóa hoặc xóa ZZ0000ZZ.
  Vì vậy, để có hiệu quả tối đa, không gian người dùng nên đóng các liên quan
  các tập tin và thư mục được mã hóa trước khi xóa khóa chính, như
  cũng như tiêu diệt bất kỳ tiến trình nào có thư mục làm việc bị ảnh hưởng
  thư mục được mã hóa.

- Hạt nhân không thể xóa sạch các bản sao của (các) khóa chính một cách kỳ diệu
  không gian người dùng cũng có thể có.  Vì vậy, không gian người dùng phải xóa sạch tất cả
  bản sao của (các) khóa chính mà nó tạo ra; thông thường điều này nên
  được thực hiện ngay sau FS_IOC_ADD_ENCRYPTION_KEY mà không cần chờ đợi
  cho FS_IOC_REMOVE_ENCRYPTION_KEY.  Đương nhiên, điều tương tự cũng được áp dụng
  tới tất cả các cấp cao hơn trong hệ thống phân cấp khóa.  Không gian người dùng cũng nên
  tuân theo các biện pháp phòng ngừa bảo mật khác như bộ nhớ mlock()ing
  chứa các khóa để tránh bị tráo đổi.

- Nói chung, nội dung và tên tệp được giải mã trong kernel VFS
  bộ nhớ cache được giải phóng nhưng không bị xóa.  Vì vậy, các phần của chúng có thể
  có thể phục hồi từ bộ nhớ đã giải phóng, ngay cả sau (các) khóa tương ứng
  đã bị xóa sạch.  Để giải quyết một phần vấn đề này, bạn có thể thêm init_on_free=1 vào
  dòng lệnh kernel của bạn.  Tuy nhiên, điều này có một chi phí hiệu suất.

- Khóa bí mật có thể vẫn tồn tại trong sổ đăng ký CPU hoặc ở những nơi khác
  không được xem xét rõ ràng ở đây.

Sự thỏa hiệp toàn bộ hệ thống
~~~~~~~~~~~~~~~~~~~~~~

Kẻ tấn công có được quyền truy cập "root" và/hoặc khả năng thực thi
mã hạt nhân tùy ý có thể tự do lọc dữ liệu được bảo vệ bởi
bất kỳ khóa fscrypt nào đang được sử dụng.  Vì vậy, thông thường fscrypt không cung cấp ý nghĩa gì
bảo vệ trong tình huống này.  (Dữ liệu được bảo vệ bằng khóa
vắng mặt trong toàn bộ cuộc tấn công vẫn được bảo vệ, theo mô-đun
hạn chế của việc loại bỏ khóa được đề cập ở trên trong trường hợp khóa
đã bị xóa trước cuộc tấn công.)

Tuy nhiên, nếu ZZ0000ZZ được sử dụng, những kẻ tấn công như vậy sẽ
không thể lọc các khóa chính hoặc khóa nội dung tệp ở dạng
sẽ có thể sử dụng được sau khi tắt hệ thống.  Đây có thể là
hữu ích nếu kẻ tấn công bị giới hạn đáng kể về thời gian và/hoặc
bị giới hạn băng thông, do đó họ chỉ có thể lấy một số dữ liệu và cần phải
dựa vào một cuộc tấn công ngoại tuyến sau đó để lọc phần còn lại của nó.

Hạn chế của chính sách v1
~~~~~~~~~~~~~~~~~~~~~~~~~~

Chính sách mã hóa v1 có một số điểm yếu liên quan đến trực tuyến
tấn công:

- Không có xác minh rằng khóa chính được cung cấp là chính xác.
  Do đó, người dùng độc hại có thể tạm thời liên kết sai khóa
  với các tệp được mã hóa của người dùng khác mà họ có quyền chỉ đọc
  truy cập.  Do bộ nhớ đệm của hệ thống tập tin nên khóa sai sẽ
  được sử dụng bởi quyền truy cập của người dùng khác vào các tệp đó, ngay cả khi người kia
  người dùng có khóa chính xác trong khóa riêng của họ.  Điều này vi phạm
  nghĩa là "truy cập chỉ đọc".

- Việc xâm phạm khóa của mỗi tệp cũng làm tổn hại đến khóa chính từ
  mà nó đã được bắt nguồn.

- Người dùng không root không thể xóa khóa mã hóa một cách an toàn.

Tất cả các vấn đề trên đều được khắc phục bằng chính sách mã hóa v2.  cho
lý do này trong số những lý do khác, nên sử dụng mã hóa v2
chính sách trên tất cả các thư mục được mã hóa mới.

Hệ thống phân cấp khóa
=============

Lưu ý: phần này giả định việc sử dụng các khóa thô thay vì
phím bọc phần cứng.  Việc sử dụng các phím bọc phần cứng sẽ sửa đổi
phân cấp khóa một chút.  Để biết chi tiết, xem ZZ0000ZZ.

Chìa khóa chính
-----------

Mỗi cây thư mục được mã hóa được bảo vệ bởi ZZ0000ZZ.  Bậc thầy
các khóa có thể dài tới 64 byte và phải dài ít nhất bằng
sức mạnh bảo mật của nội dung và tên tệp cao hơn
chế độ mã hóa đang được sử dụng.  Ví dụ: nếu bất kỳ chế độ AES-256 nào được
được sử dụng, khóa chính phải có ít nhất 256 bit, tức là 32 byte.  A
yêu cầu chặt chẽ hơn được áp dụng nếu khóa được sử dụng bởi mã hóa v1
chính sách và AES-256-XTS được sử dụng; các khóa như vậy phải là 64 byte.

Để "mở khóa" cây thư mục được mã hóa, không gian người dùng phải cung cấp
khóa chủ thích hợp.  Có thể có bất kỳ số lượng khóa chính nào, mỗi khóa
trong đó bảo vệ bất kỳ số lượng cây thư mục nào trên bất kỳ số lượng
hệ thống tập tin.

Khóa chính phải là khóa mật mã thực, tức là không thể phân biệt được
từ các chuỗi byte ngẫu nhiên có cùng độ dài.  Điều này hàm ý rằng người dùng
ZZ0000ZZ trực tiếp sử dụng mật khẩu làm khóa chính, không đệm
phím ngắn hơn hoặc lặp lại phím ngắn hơn.  An ninh không thể được đảm bảo
nếu không gian người dùng mắc phải bất kỳ lỗi nào như vậy, chẳng hạn như bằng chứng mật mã và
phân tích sẽ không còn áp dụng được nữa.

Thay vào đó, người dùng nên tạo khóa chính bằng cách sử dụng
trình tạo số ngẫu nhiên được bảo mật bằng mật mã hoặc bằng cách sử dụng KDF
(Hàm dẫn xuất khóa).  Hạt nhân không thực hiện bất kỳ thao tác kéo dài phím nào;
do đó, nếu không gian người dùng lấy được khóa từ một bí mật có entropy thấp như
làm cụm mật khẩu, điều quan trọng là KDF được thiết kế cho mục đích này
được sử dụng, chẳng hạn như tiền điện tử, PBKDF2 hoặc Argon2.

Hàm dẫn xuất chính
-----------------------

Với một ngoại lệ, fscrypt không bao giờ sử dụng (các) khóa chính cho
mã hóa trực tiếp.  Thay vào đó, chúng chỉ được sử dụng làm đầu vào cho KDF
(Hàm dẫn xuất khóa) để lấy các khóa thực tế.

KDF được sử dụng cho một khóa chính cụ thể sẽ khác nhau tùy thuộc vào việc
khóa được sử dụng cho chính sách mã hóa v1 hoặc mã hóa v2
chính sách.  Người dùng ZZ0000ZZ sử dụng chung một key cho cả v1 và v2
chính sách mã hóa.  (Hiện tại không có cuộc tấn công trong thế giới thực nào được biết đến trên
trường hợp cụ thể của việc tái sử dụng khóa, nhưng tính bảo mật của nó không thể được đảm bảo
vì các bằng chứng và phân tích mật mã sẽ không còn được áp dụng nữa.)

Đối với chính sách mã hóa v1, KDF chỉ hỗ trợ lấy dữ liệu trên mỗi tệp
các khóa mã hóa.  Nó hoạt động bằng cách mã hóa khóa chính bằng
AES-128-ECB, sử dụng nonce 16 byte của tệp làm khóa AES.  các
bản mã thu được sẽ được sử dụng làm khóa dẫn xuất.  Nếu bản mã là
dài hơn mức cần thiết thì nó sẽ bị cắt bớt theo độ dài cần thiết.

Đối với chính sách mã hóa v2, KDF là HKDF-SHA512.  Chìa khóa chính là
được chuyển thành "vật liệu khóa đầu vào", không sử dụng muối và một đặc tính riêng biệt
"chuỗi thông tin dành riêng cho ứng dụng" được sử dụng cho từng
chìa khóa cần được rút ra.  Ví dụ: khi khóa mã hóa cho mỗi tệp được
dẫn xuất, chuỗi thông tin dành riêng cho ứng dụng là của tệp
nonce có tiền tố là "fscrypt\\0" và một byte ngữ cảnh.  Khác nhau
byte ngữ cảnh được sử dụng cho các loại khóa dẫn xuất khác.

HKDF-SHA512 được ưu tiên hơn AES-128-ECB dựa trên KDF ban đầu vì
HKDF linh hoạt hơn, không thể đảo ngược và phân bổ đồng đều
entropy từ khóa chính.  HKDF cũng được tiêu chuẩn hóa và sử dụng rộng rãi
được sử dụng bởi phần mềm khác, trong khi KDF dựa trên AES-128-ECB là đặc biệt.

Khóa mã hóa cho mỗi tập tin
------------------------

Vì mỗi khóa chính có thể bảo vệ nhiều tập tin nên cần phải
"tinh chỉnh" mã hóa của mỗi tập tin sao cho cùng một bản rõ ở hai
các tập tin không ánh xạ tới cùng một bản mã hoặc ngược lại.  Trong hầu hết
trường hợp, fscrypt thực hiện điều này bằng cách lấy khóa trên mỗi tệp.  Khi mới
inode được mã hóa (tệp thông thường, thư mục hoặc liên kết tượng trưng) được tạo,
fscrypt tạo ngẫu nhiên một nonce 16 byte và lưu trữ nó trong
mã hóa xattr của inode.  Sau đó, nó sử dụng KDF (như được mô tả trong ZZ0000ZZ) để lấy khóa của tệp từ khóa chính
và nonce.

Dẫn xuất khóa được chọn thay vì gói khóa vì các khóa được gói sẽ
yêu cầu xattr lớn hơn sẽ ít có khả năng phù hợp với nội tuyến hơn
bảng inode của hệ thống tập tin và dường như không có bất kỳ
lợi thế đáng kể cho việc gói chìa khóa.  Đặc biệt, hiện nay
không có yêu cầu hỗ trợ mở khóa một tập tin với nhiều
các phím chính thay thế hoặc để hỗ trợ các phím chính xoay.  Thay vào đó,
các khóa chính có thể được bao bọc trong không gian người dùng, ví dụ: như được thực hiện bởi
Công cụ ZZ0000ZZ.

Chính sách của DIRECT_KEY
-------------------

Chế độ mã hóa Adiantum (xem ZZ0000ZZ) là
thích hợp cho cả mã hóa nội dung và tên tập tin, và nó chấp nhận
IV dài --- đủ dài để chứa cả chỉ mục đơn vị dữ liệu 8 byte và
16 byte cho mỗi tệp nonce.  Ngoài ra, chi phí hoạt động của mỗi khóa Adiantum là
lớn hơn khóa AES-256-XTS.

Vì vậy, để cải thiện hiệu suất và tiết kiệm bộ nhớ, dành cho Adiantum một
Cấu hình "khóa trực tiếp" được hỗ trợ.  Khi người dùng đã kích hoạt
điều này bằng cách đặt FSCRYPT_POLICY_FLAG_DIRECT_KEY trong chính sách fscrypt,
khóa mã hóa cho mỗi tập tin không được sử dụng.  Thay vào đó, bất cứ khi nào có dữ liệu
(nội dung hoặc tên tệp) được mã hóa, nonce 16 byte của tệp là
được đưa vào IV.  Hơn thế nữa:

- Đối với chính sách mã hóa v1, việc mã hóa được thực hiện trực tiếp với
  chìa khóa chính.  Vì điều này, người dùng ZZ0000ZZ sử dụng cùng một bản gốc
  key cho bất kỳ mục đích nào khác, ngay cả đối với các chính sách v1 khác.

- Đối với chính sách mã hóa v2, việc mã hóa được thực hiện theo từng chế độ
  khóa được lấy bằng KDF.  Người dùng có thể sử dụng cùng một khóa chính cho
  chính sách mã hóa v2 khác.

Chính sách của IV_INO_LBLK_64
-----------------------

Khi FSCRYPT_POLICY_FLAG_IV_INO_LBLK_64 được đặt trong chính sách fscrypt,
các khóa mã hóa được lấy từ khóa chính, chế độ mã hóa
số và hệ thống tập tin UUID.  Điều này thường dẫn đến tất cả các tập tin
được bảo vệ bởi cùng một khóa chính chia sẻ mã hóa nội dung duy nhất
khóa và một khóa mã hóa tên tệp duy nhất.  Để vẫn mã hóa khác nhau
dữ liệu của các tệp khác nhau, số inode được bao gồm trong IV.
Do đó, việc thu nhỏ hệ thống tập tin có thể không được phép.

Định dạng này được tối ưu hóa để sử dụng với phần cứng mã hóa nội tuyến
tuân thủ tiêu chuẩn UFS, chỉ hỗ trợ 64 bit IV mỗi
Yêu cầu I/O và có thể chỉ có một số lượng nhỏ khe khóa.

Chính sách của IV_INO_LBLK_32
-----------------------

Các chính sách của IV_INO_LBLK_32 hoạt động giống như IV_INO_LBLK_64, ngoại trừ
IV_INO_LBLK_32, số inode được băm bằng SipHash-2-4 (trong đó
Khóa SipHash được lấy từ khóa chính) và được thêm vào dữ liệu tệp
chỉ số đơn vị mod 2^32 để tạo IV 32 bit.

Định dạng này được tối ưu hóa để sử dụng với phần cứng mã hóa nội tuyến
tuân thủ tiêu chuẩn eMMC v5.2, chỉ hỗ trợ 32 bit IV
theo yêu cầu I/O và có thể chỉ có một số lượng nhỏ khe khóa.  Cái này
định dạng này dẫn đến việc sử dụng lại IV ở một mức độ nào đó, vì vậy nó chỉ nên được sử dụng
khi cần thiết do hạn chế về phần cứng.

Mã định danh chính
---------------

Đối với các khóa chính được sử dụng cho chính sách mã hóa v2, một "khóa" 16 byte duy nhất
định danh" cũng được bắt nguồn bằng KDF.  Giá trị này được lưu trữ trong
rõ ràng, vì cần phải xác định chính khóa đó một cách đáng tin cậy.

Chìa khóa dirhash
------------

Đối với các thư mục được lập chỉ mục bằng dirhash có khóa bí mật trên
tên tệp văn bản gốc, KDF cũng được sử dụng để lấy mã 128-bit
Khóa SipHash-2-4 cho mỗi thư mục để băm tên tệp.  Cái này hoạt động
giống như lấy khóa mã hóa cho mỗi tệp, ngoại trừ một khóa khác
Bối cảnh KDF được sử dụng.  Hiện tại, chỉ được phân biệt chữ hoa chữ thường ("không phân biệt chữ hoa chữ thường")
các thư mục được mã hóa sử dụng kiểu băm này.

Chế độ mã hóa và cách sử dụng
==========================

fscrypt cho phép chỉ định một chế độ mã hóa cho nội dung tệp
và một chế độ mã hóa được chỉ định cho tên tệp.  Khác nhau
cây thư mục được phép sử dụng các chế độ mã hóa khác nhau.

Các chế độ được hỗ trợ
---------------

Hiện tại, các cặp chế độ mã hóa sau được hỗ trợ:

- AES-256-XTS cho nội dung và AES-256-CBC-CTS cho tên tệp
- AES-256-XTS cho nội dung và AES-256-HCTR2 cho tên tệp
- Adiantum cho cả nội dung và tên tập tin
- AES-128-CBC-ESSIV cho nội dung và AES-128-CBC-CTS cho tên tệp
- SM4-XTS cho nội dung và SM4-CBC-CTS cho tên tệp

Lưu ý: trong API, "CBC" có nghĩa là CBC-ESSIV và "CTS" có nghĩa là CBC-CTS.
Vì vậy, ví dụ: FSCRYPT_MODE_AES_256_CTS có nghĩa là AES-256-CBC-CTS.

Chế độ mã hóa xác thực hiện không được hỗ trợ vì
khó khăn trong việc giải quyết việc mở rộng bản mã.  Vì vậy,
mã hóa nội dung sử dụng mật mã khối trong ZZ0000ZZ hoặc
ZZ0001ZZ,
hoặc mật mã khối rộng.  Mã hóa tên tập tin sử dụng một
mật mã khối trong ZZ0002ZZ hoặc khối rộng
mật mã.

Cặp (AES-256-XTS, AES-256-CBC-CTS) là mặc định được đề xuất.
Đây cũng là lựa chọn duy nhất mà ZZ0001ZZ luôn được hỗ trợ
liệu kernel có hỗ trợ fscrypt hay không; xem ZZ0000ZZ.

Cặp (AES-256-XTS, AES-256-HCTR2) cũng là một lựa chọn tốt đó
nâng cấp mã hóa tên tệp để sử dụng mật mã khối rộng.  (A
ZZ0002ZZ, còn được gọi là siêu giả ngẫu nhiên có thể điều chỉnh
hoán vị, có đặc tính là thay đổi một bit sẽ làm xáo trộn
toàn bộ kết quả.) Như được mô tả trong ZZ0000ZZ, một khối rộng
mật mã là chế độ lý tưởng cho miền vấn đề, mặc dù CBC-CTS là
lựa chọn "ít tệ nhất" trong số các lựa chọn thay thế.  Để biết thêm thông tin về
HCTR2, xem ZZ0001ZZ.

Adiantum được khuyên dùng trên các hệ thống có AES quá chậm do thiếu
tăng tốc phần cứng cho AES.  Adiantum là mật mã khối rộng
sử dụng XChaCha12 và AES-256 làm thành phần cơ bản.  Hầu hết
công việc được thực hiện bởi XChaCha12, nhanh hơn nhiều so với AES khi AES
khả năng tăng tốc không có sẵn.  Để biết thêm thông tin về Adiantum, xem
ZZ0000ZZ.

Cặp (AES-128-CBC-ESSIV, AES-128-CBC-CTS) đã được thêm vào để thử
cung cấp tùy chọn hiệu quả hơn cho các hệ thống thiếu hướng dẫn AES
trong CPU nhưng có công cụ mã hóa không nội tuyến như CAAM hoặc CESA
hỗ trợ AES-CBC (chứ không phải AES-XTS).  Điều này không được dùng nữa.  Nó có
đã được chứng minh rằng chỉ thực hiện AES trên CPU thực sự nhanh hơn.
Hơn nữa, Adiantum vẫn nhanh hơn và được khuyên dùng trên các hệ thống như vậy.

Các cặp chế độ còn lại là "mật mã niềm tự hào dân tộc":

- (SM4-XTS, SM4-CBC-CTS)

Nói chung, bản chất những mật mã này không phải là "xấu" nhưng chúng
nhận được đánh giá bảo mật hạn chế so với các lựa chọn thông thường như
AES và ChaCha.  Họ cũng không mang lại nhiều điều mới mẻ.  Đó là
đề xuất chỉ sử dụng các mật mã này khi việc sử dụng chúng được bắt buộc.

Tùy chọn cấu hình hạt nhân
---------------------

Kích hoạt hỗ trợ fscrypt (CONFIG_FS_ENCRYPTION) sẽ tự động kéo vào
chỉ cần hỗ trợ cơ bản từ tiền điện tử API để sử dụng AES-256-XTS
và mã hóa AES-256-CBC-CTS.  Để có hiệu suất tối ưu, đó là
cũng được khuyến khích kích hoạt mọi nền tảng cụ thể có sẵn
tùy chọn kconfig cung cấp khả năng tăng tốc cho (các) thuật toán mà bạn
mong muốn sử dụng.  Thông thường hỗ trợ mọi chế độ mã hóa "không mặc định"
cũng yêu cầu thêm tùy chọn kconfig.

Dưới đây, một số tùy chọn có liên quan được liệt kê theo chế độ mã hóa.  Lưu ý,
các tùy chọn tăng tốc không được liệt kê bên dưới có thể có sẵn cho
nền tảng; tham khảo các menu kconfig.  Mã hóa nội dung tập tin có thể
cũng được cấu hình để sử dụng phần cứng mã hóa nội tuyến thay vì
mật mã hạt nhân API (xem ZZ0000ZZ); trong trường hợp đó,
chế độ nội dung tệp không cần được hỗ trợ trong kernel crypto
API, nhưng chế độ tên tệp vẫn hoạt động.

- AES-256-XTS và AES-256-CBC-CTS
    - Khuyến nghị:
        - arm64: CONFIG_CRYPTO_AES_ARM64_CE_BLK
        - x86: CONFIG_CRYPTO_AES_NI_INTEL

- AES-256-HCTR2
    - Bắt buộc:
        -CONFIG_CRYPTO_HCTR2
    - Khuyến nghị:
        - arm64: CONFIG_CRYPTO_AES_ARM64_CE_BLK
        - x86: CONFIG_CRYPTO_AES_NI_INTEL

- Adiantum
    - Bắt buộc:
        -CONFIG_CRYPTO_ADIANTUM

- AES-128-CBC-ESSIV và AES-128-CBC-CTS:
    - Bắt buộc:
        -CONFIG_CRYPTO_ESSIV
        - CONFIG_CRYPTO_SHA256 hoặc triển khai SHA-256 khác
    - Khuyến nghị:
        - Tăng tốc AES-CBC

Mã hóa nội dung
-------------------

Để mã hóa nội dung, nội dung của mỗi tệp được chia thành "dữ liệu
đơn vị”.  Mỗi đơn vị dữ liệu được mã hóa độc lập.  IV cho mỗi
đơn vị dữ liệu kết hợp chỉ mục dựa trên 0 của đơn vị dữ liệu trong
tập tin.  Điều này đảm bảo rằng mỗi đơn vị dữ liệu trong một tệp được mã hóa
khác nhau, điều này rất cần thiết để ngăn chặn rò rỉ thông tin.

Lưu ý: việc mã hóa tùy thuộc vào offset vào tệp có nghĩa là
các hoạt động như "thu gọn phạm vi" và "chèn phạm vi" để sắp xếp lại
ánh xạ phạm vi của các tệp không được hỗ trợ trên các tệp được mã hóa.

Có hai trường hợp về kích thước của đơn vị dữ liệu:

* Đơn vị dữ liệu có kích thước cố định.  Đây là cách tất cả các hệ thống tập tin khác ngoài UBIFS
  làm việc.  Các đơn vị dữ liệu của tệp đều có cùng kích thước; đơn vị dữ liệu cuối cùng
  được đệm bằng 0 nếu cần.  Theo mặc định, kích thước đơn vị dữ liệu bằng nhau
  đến kích thước khối hệ thống tập tin.  Trên một số hệ thống tập tin, người dùng có thể chọn
  kích thước đơn vị dữ liệu khối con thông qua trường ZZ0000ZZ của
  chính sách mã hóa; xem ZZ0001ZZ.

* Đơn vị dữ liệu có kích thước thay đổi.  Đây là những gì UBIFS làm.  Mỗi "UBIFS
  nút dữ liệu" được coi là đơn vị dữ liệu mật mã.  Mỗi cái chứa biến
  độ dài, có thể là dữ liệu được nén, không đệm vào 16 byte tiếp theo
  ranh giới.  Người dùng không thể chọn kích thước đơn vị dữ liệu khối phụ trên UBIFS.

Trong trường hợp nén + mã hóa, dữ liệu được nén
được mã hóa.  Nén UBIFS hoạt động như mô tả ở trên.  f2fs
tính năng nén hoạt động hơi khác một chút; nó nén một số
khối hệ thống tập tin thành một số khối hệ thống tập tin nhỏ hơn.
Do đó, tệp nén f2fs vẫn sử dụng các đơn vị dữ liệu có kích thước cố định và
nó được mã hóa theo cách tương tự như một tệp chứa lỗ hổng.

Như đã đề cập trong ZZ0000ZZ, cài đặt mã hóa mặc định sử dụng
khóa cho mỗi tập tin.  Trong trường hợp này, IV cho mỗi đơn vị dữ liệu chỉ đơn giản là
chỉ mục của đơn vị dữ liệu trong tệp.  Tuy nhiên, người dùng có thể chọn một
cài đặt mã hóa không sử dụng khóa cho mỗi tệp.  Đối với những điều này, một số
loại mã định danh tệp được tích hợp vào IV như sau:

- Với ZZ0000ZZ, chỉ mục đơn vị dữ liệu được đặt theo bit
  0-63 của IV và số nonce của tệp được đặt ở bit 64-191.

- Với ZZ0000ZZ, chỉ mục đơn vị dữ liệu được đặt trong
  bit 0-31 của IV và số inode của tệp được đặt theo bit
  32-63.  Cài đặt này chỉ được phép khi chỉ mục đơn vị dữ liệu và
  số inode phù hợp với 32 bit.

- Với ZZ0000ZZ, số inode của file được băm
  và được thêm vào chỉ mục đơn vị dữ liệu.  Giá trị kết quả bị cắt ngắn
  thành 32 bit và được đặt trong các bit 0-31 của IV.  Cài đặt này chỉ
  được phép khi chỉ số đơn vị dữ liệu và số inode vừa đủ 32 bit.

Thứ tự byte của IV luôn là endian nhỏ.

Nếu người dùng chọn FSCRYPT_MODE_AES_128_CBC cho chế độ nội dung,
Lớp ESSIV được tự động đưa vào.  Trong trường hợp này, trước khi IV được
được chuyển tới AES-128-CBC, nó được mã hóa bằng AES-256 trong đó AES-256
key là hàm băm SHA-256 của khóa mã hóa nội dung của tệp.

Mã hóa tên tập tin
--------------------

Đối với tên tệp, mỗi tên tệp đầy đủ được mã hóa cùng một lúc.  Bởi vì
các yêu cầu để duy trì sự hỗ trợ cho việc tra cứu thư mục hiệu quả và
tên tệp lên tới 255 byte, cùng một IV được sử dụng cho mọi tên tệp
trong một thư mục.

Tuy nhiên, mỗi thư mục được mã hóa vẫn sử dụng một khóa duy nhất, hoặc
cách khác là có nonce của tệp (đối với ZZ0000ZZ) hoặc
số inode (đối với ZZ0001ZZ) có trong IV.
Do đó, việc tái sử dụng IV bị giới hạn trong một thư mục.

Với CBC-CTS, việc sử dụng lại IV có nghĩa là khi tên tệp văn bản gốc chia sẻ một
tiền tố chung ít nhất bằng kích thước khối mật mã (16 byte cho AES),
tên tệp được mã hóa tương ứng cũng sẽ có chung tiền tố.  Đây là
không mong muốn.  Adiantum và HCTR2 không có điểm yếu này
chế độ mã hóa khối rộng.

Tất cả các chế độ mã hóa tên tệp được hỗ trợ đều chấp nhận mọi độ dài văn bản gốc
>= 16 byte; căn chỉnh khối mật mã là không cần thiết.  Tuy nhiên,
tên tệp ngắn hơn 16 byte được đệm NUL thành 16 byte trước đó
đang được mã hóa.  Ngoài ra, để giảm rò rỉ độ dài tên tệp
thông qua bản mã của chúng, tất cả tên tệp đều được đệm NUL vào 4, 8, tiếp theo
Ranh giới 16 hoặc 32 byte (có thể định cấu hình).  32 được khuyến nghị vì điều này
cung cấp sự bảo mật tốt nhất, với chi phí tạo thư mục
các mục tiêu thụ nhiều không gian hơn một chút.  Lưu ý rằng vì NUL (ZZ0000ZZ) là
không phải là ký tự hợp lệ trong tên tệp, phần đệm sẽ không bao giờ
tạo ra các bản rõ trùng lặp.

Mục tiêu liên kết tượng trưng được coi là một loại tên tệp và
được mã hóa theo cách tương tự như tên tệp trong các mục thư mục, ngoại trừ
việc sử dụng lại IV không phải là vấn đề vì mỗi liên kết tượng trưng có nút riêng.

Người dùng API
========

Đặt chính sách mã hóa
----------------------------

FS_IOC_SET_ENCRYPTION_POLICY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_SET_ENCRYPTION_POLICY ioctl đặt chính sách mã hóa trên một
thư mục trống hoặc xác minh rằng một thư mục hoặc tệp thông thường đã có
có chính sách mã hóa được chỉ định.  Nó cần một con trỏ để
struct fscrypt_policy_v1 hoặc struct fscrypt_policy_v2, được định nghĩa là
sau::

#define FSCRYPT_POLICY_V1 0
    #define FSCRYPT_KEY_DESCRIPTOR_SIZE 8
    cấu trúc fscrypt_policy_v1 {
            __u8 phiên bản;
            __u8 nội dung_encryption_mode;
            __u8 tên tập tin_encryption_mode;
            __u8 cờ;
            __u8 master_key_descriptor[FSCRYPT_KEY_DESCRIPTOR_SIZE];
    };
    #define fscrypt_policy fscrypt_policy_v1

#define FSCRYPT_POLICY_V2 2
    #define FSCRYPT_KEY_IDENTIFIER_SIZE 16
    cấu trúc fscrypt_policy_v2 {
            __u8 phiên bản;
            __u8 nội dung_encryption_mode;
            __u8 tên tập tin_encryption_mode;
            __u8 cờ;
            __u8 log2_data_unit_size;
            __u8 __reserved[3];
            __u8 master_key_identifier[FSCRYPT_KEY_IDENTIFIER_SIZE];
    };

Cấu trúc này phải được khởi tạo như sau:

- ZZ0000ZZ phải là FSCRYPT_POLICY_V1 (0) nếu
  struct fscrypt_policy_v1 được sử dụng hoặc FSCRYPT_POLICY_V2 (2) nếu
  struct fscrypt_policy_v2 được sử dụng. (Lưu ý: chúng tôi tham khảo bản gốc
  phiên bản chính sách là "v1", mặc dù mã phiên bản của nó thực sự là 0.)
  Đối với các thư mục được mã hóa mới, hãy sử dụng chính sách v2.

- Phải có ZZ0000ZZ và ZZ0001ZZ
  được đặt thành các hằng số từ ZZ0002ZZ để xác định
  chế độ mã hóa để sử dụng.  Nếu không chắc chắn, hãy sử dụng FSCRYPT_MODE_AES_256_XTS
  (1) cho ZZ0003ZZ và FSCRYPT_MODE_AES_256_CTS
  (4) đối với ZZ0004ZZ.  Để biết chi tiết, xem ZZ0005ZZ.

Chính sách mã hóa v1 chỉ hỗ trợ ba kết hợp chế độ:
  (FSCRYPT_MODE_AES_256_XTS, FSCRYPT_MODE_AES_256_CTS),
  (FSCRYPT_MODE_AES_128_CBC, FSCRYPT_MODE_AES_128_CTS) và
  (FSCRYPT_MODE_ADIANTUM, FSCRYPT_MODE_ADIANTUM).  hỗ trợ chính sách v2
  tất cả các kết hợp được ghi lại trong ZZ0000ZZ.

- ZZ0000ZZ chứa các cờ tùy chọn từ ZZ0001ZZ:

- FSCRYPT_POLICY_FLAGS_PAD_*: Lượng đệm NUL sẽ sử dụng khi
    mã hóa tên tập tin.  Nếu không chắc chắn, hãy sử dụng FSCRYPT_POLICY_FLAGS_PAD_32
    (0x3).
  - FSCRYPT_POLICY_FLAG_DIRECT_KEY: Xem ZZ0000ZZ.
  - FSCRYPT_POLICY_FLAG_IV_INO_LBLK_64: Xem ZZ0001ZZ.
  - FSCRYPT_POLICY_FLAG_IV_INO_LBLK_32: Xem ZZ0002ZZ.

Chính sách mã hóa v1 chỉ hỗ trợ cờ PAD_* và DIRECT_KEY.
  Các cờ khác chỉ được hỗ trợ bởi chính sách mã hóa v2.

Các cờ DIRECT_KEY, IV_INO_LBLK_64 và IV_INO_LBLK_32 là
  loại trừ lẫn nhau.

- ZZ0000ZZ là log2 của kích thước đơn vị dữ liệu tính bằng byte,
  hoặc 0 để chọn kích thước đơn vị dữ liệu mặc định.  Kích thước đơn vị dữ liệu là
  mức độ chi tiết của mã hóa nội dung tập tin.  Ví dụ, thiết lập
  ZZ0001ZZ thành 12 khiến nội dung tệp được chuyển tới
  thuật toán mã hóa cơ bản (chẳng hạn như AES-256-XTS) ở 4096 byte
  đơn vị dữ liệu, mỗi đơn vị có IV riêng.

Không phải tất cả các hệ thống tập tin đều hỗ trợ cài đặt ZZ0000ZZ.  ext4
  và f2fs hỗ trợ nó kể từ Linux v6.7.  Trên các hệ thống tập tin hỗ trợ
  nó, các giá trị khác 0 được hỗ trợ là 9 đến log2 của
  kích thước khối hệ thống tập tin, bao gồm.  Giá trị mặc định là 0 chọn
  kích thước khối hệ thống tập tin.

Trường hợp sử dụng chính của ZZ0000ZZ là để chọn một
  kích thước đơn vị dữ liệu nhỏ hơn kích thước khối hệ thống tập tin cho
  khả năng tương thích với phần cứng mã hóa nội tuyến chỉ hỗ trợ
  kích thước đơn vị dữ liệu nhỏ hơn.  ZZ0001ZZ có thể
  hữu ích cho việc kiểm tra kích thước đơn vị dữ liệu nào được hỗ trợ bởi
  phần cứng mã hóa nội tuyến của hệ thống cụ thể.

Để trường này bằng 0 trừ khi bạn chắc chắn mình cần nó.  sử dụng
  kích thước đơn vị dữ liệu nhỏ không cần thiết sẽ làm giảm hiệu suất.

- Đối với chính sách mã hóa v2, ZZ0000ZZ phải bằng 0.

- Đối với chính sách mã hóa v1, ZZ0000ZZ chỉ định cách thực hiện
  để tìm chìa khóa chính trong một chiếc chìa khóa; xem ZZ0003ZZ.  nó lên rồi
  vào không gian người dùng để chọn một ZZ0001ZZ duy nhất cho mỗi người dùng
  chìa khóa chính.  Các công cụ e4crypt và fscrypt sử dụng 8 byte đầu tiên của
  ZZ0002ZZ, nhưng sơ đồ cụ thể này thì không
  được yêu cầu.  Ngoài ra, chìa khóa chính chưa cần phải có trong ổ khóa khi
  FS_IOC_SET_ENCRYPTION_POLICY được thực thi.  Tuy nhiên, phải bổ sung
  trước khi có thể tạo bất kỳ tập tin nào trong thư mục được mã hóa.

Đối với chính sách mã hóa v2, ZZ0000ZZ đã được
  được thay thế bằng ZZ0001ZZ, dài hơn và không thể
  được lựa chọn tùy ý.  Thay vào đó, khóa trước tiên phải được thêm bằng cách sử dụng
  ZZ0004ZZ.  Sau đó, ZZ0002ZZ
  hạt nhân được trả về trong cấu trúc fscrypt_add_key_arg phải
  được sử dụng làm ZZ0003ZZ trong
  cấu trúc fscrypt_policy_v2.

Nếu tệp chưa được mã hóa thì FS_IOC_SET_ENCRYPTION_POLICY
xác minh rằng tập tin là một thư mục trống.  Nếu vậy, quy định
chính sách mã hóa được gán cho thư mục, biến nó thành một
thư mục được mã hóa.  Sau đó và sau khi cung cấp
khóa chính tương ứng như được mô tả trong ZZ0000ZZ, tất cả đều thông thường
các tập tin, thư mục (đệ quy) và các liên kết tượng trưng được tạo trong
thư mục sẽ được mã hóa, kế thừa chính sách mã hóa tương tự.
Tên tập tin trong các mục của thư mục cũng sẽ được mã hóa.

Ngoài ra, nếu tập tin đã được mã hóa thì
FS_IOC_SET_ENCRYPTION_POLICY xác nhận rằng mã hóa được chỉ định
chính sách khớp chính xác với thực tế.  Nếu chúng khớp nhau thì ioctl
trả về 0. Nếu không, nó sẽ thất bại với EEXIST.  Điều này hoạt động trên cả hai
các tập tin và thư mục thông thường, bao gồm cả các thư mục không trống.

Khi chính sách mã hóa v2 được gán cho một thư mục, nó cũng được
yêu cầu khóa được chỉ định đã được thêm bởi khóa hiện tại
người dùng hoặc người gọi có CAP_FOWNER trong không gian tên người dùng ban đầu.
(Điều này là cần thiết để ngăn người dùng mã hóa dữ liệu của họ bằng
khóa của người dùng khác.) Khóa này phải được thêm vào trong khi
FS_IOC_SET_ENCRYPTION_POLICY đang thực thi.  Tuy nhiên, nếu mới
thư mục được mã hóa không cần phải truy cập ngay lập tức, thì
chìa khóa có thể được gỡ bỏ ngay sau đó.

Lưu ý rằng hệ thống tập tin ext4 không cho phép thư mục gốc
được mã hóa, ngay cả khi nó trống.  Người dùng muốn mã hóa toàn bộ
thay vào đó, hệ thống tập tin có một khóa nên cân nhắc sử dụng dm-crypt.

FS_IOC_SET_ENCRYPTION_POLICY có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: tập tin không thuộc quyền sở hữu của uid của tiến trình, cũng như không
  quy trình có khả năng CAP_FOWNER trong không gian tên với tệp
  bản đồ uid của chủ sở hữu
- ZZ0001ZZ: file đã được mã hóa bằng chính sách mã hóa
  khác với cái đã chỉ định
- ZZ0002ZZ: chính sách mã hóa không hợp lệ đã được chỉ định (không hợp lệ
  phiên bản, (các) chế độ hoặc cờ; hoặc các bit dành riêng đã được đặt); hoặc v1
  chính sách mã hóa đã được chỉ định nhưng thư mục có dạng casefold
  đã bật cờ (casefolding không tương thích với chính sách v1).
- ZZ0003ZZ: chính sách mã hóa v2 đã được chỉ định, nhưng khóa có
  ZZ0004ZZ được chỉ định chưa được thêm vào, cũng như không
  quy trình có khả năng CAP_FOWNER ở người dùng ban đầu
  không gian tên
- ZZ0005ZZ: file chưa được mã hóa và là file thông thường, không phải file
  thư mục
- ZZ0006ZZ: file chưa được mã hóa và là thư mục không trống
- ZZ0007ZZ: loại hệ thống tập tin này không thực hiện mã hóa
- ZZ0008ZZ: kernel không được cấu hình mã hóa
  hỗ trợ cho các hệ thống tập tin hoặc siêu khối hệ thống tập tin chưa
  đã kích hoạt mã hóa trên đó.  (Ví dụ: để sử dụng mã hóa trên một
  hệ thống tập tin ext4, CONFIG_FS_ENCRYPTION phải được kích hoạt trong
  cấu hình kernel và siêu khối phải có "mã hóa"
  cờ tính năng được bật bằng ZZ0009ZZ hoặc ZZ0010ZZ.)
- ZZ0011ZZ: thư mục này có thể không được mã hóa, ví dụ: bởi vì nó là
  thư mục gốc của hệ thống tập tin ext4
- ZZ0012ZZ: hệ thống tập tin ở chế độ chỉ đọc

Nhận chính sách mã hóa
----------------------------

Có sẵn hai ioctls để nhận chính sách mã hóa của tệp:

-ZZ0000ZZ
-ZZ0001ZZ

Phiên bản mở rộng (_EX) của ioctl tổng quát hơn và
khuyến khích sử dụng khi có thể.  Tuy nhiên, trên các hạt nhân cũ hơn chỉ có
ioctl gốc có sẵn.  Ứng dụng nên thử mở rộng
phiên bản và nếu nó bị lỗi với ENOTTY, hãy quay lại phiên bản gốc
phiên bản.

FS_IOC_GET_ENCRYPTION_POLICY_EX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_GET_ENCRYPTION_POLICY_EX ioctl lấy mã hóa
chính sách, nếu có, đối với một thư mục hoặc tập tin thông thường.  Không bổ sung
quyền được yêu cầu ngoài khả năng mở tệp.  Nó
lấy một con trỏ tới struct fscrypt_get_policy_ex_arg,
được xác định như sau::

cấu trúc fscrypt_get_policy_ex_arg {
            __u64 chính sách_size; /*đầu vào/đầu ra */
            công đoàn {
                    __u8 phiên bản;
                    cấu trúc fscrypt_policy_v1 v1;
                    cấu trúc fscrypt_policy_v2 v2;
            } chính sách; /*xuất ra*/
    };

Người gọi phải khởi tạo ZZ0000ZZ theo kích thước có sẵn cho
cấu trúc chính sách, tức là ZZ0001ZZ.

Khi thành công, cấu trúc chính sách được trả về trong ZZ0000ZZ và
kích thước thực tế được trả về trong ZZ0001ZZ.  ZZ0002ZZ nên
được kiểm tra để xác định phiên bản của chính sách được trả về.  Lưu ý rằng
mã phiên bản cho chính sách "v1" thực tế là 0 (FSCRYPT_POLICY_V1).

FS_IOC_GET_ENCRYPTION_POLICY_EX có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: tệp được mã hóa nhưng sử dụng phần mềm không được nhận dạng
  phiên bản chính sách mã hóa
- ZZ0001ZZ: file chưa được mã hóa
- ZZ0002ZZ: loại hệ thống tập tin này không thực hiện mã hóa,
  hoặc kernel này quá cũ để hỗ trợ FS_IOC_GET_ENCRYPTION_POLICY_EX
  (thay vào đó hãy thử FS_IOC_GET_ENCRYPTION_POLICY)
- ZZ0003ZZ: kernel không được cấu hình mã hóa
  hỗ trợ cho hệ thống tập tin này hoặc siêu khối hệ thống tập tin chưa
  đã kích hoạt mã hóa trên đó
- ZZ0004ZZ: tệp được mã hóa và sử dụng
  phiên bản chính sách mã hóa, nhưng cấu trúc chính sách không phù hợp với
  bộ đệm được cung cấp

Lưu ý: nếu bạn chỉ cần biết một tập tin có được mã hóa hay không, trên
hầu hết các hệ thống tập tin cũng có thể sử dụng FS_IOC_GETFLAGS ioctl
và kiểm tra FS_ENCRYPT_FL hoặc sử dụng lệnh gọi hệ thống statx() và
kiểm tra STATX_ATTR_ENCRYPTED trong stx_attributes.

FS_IOC_GET_ENCRYPTION_POLICY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_GET_ENCRYPTION_POLICY ioctl cũng có thể truy xuất
chính sách mã hóa, nếu có, đối với một thư mục hoặc tập tin thông thường.  Tuy nhiên,
không giống như ZZ0000ZZ,
FS_IOC_GET_ENCRYPTION_POLICY chỉ hỗ trợ chính sách ban đầu
phiên bản.  Nó lấy một con trỏ trực tiếp tới struct fscrypt_policy_v1
thay vì cấu trúc fscrypt_get_policy_ex_arg.

Mã lỗi của FS_IOC_GET_ENCRYPTION_POLICY giống với mã lỗi
cho FS_IOC_GET_ENCRYPTION_POLICY_EX, ngoại trừ điều đó
FS_IOC_GET_ENCRYPTION_POLICY cũng trả về ZZ0000ZZ nếu tệp được
được mã hóa bằng phiên bản chính sách mã hóa mới hơn.

Lấy muối trên mỗi hệ thống tập tin
-------------------------------

Một số hệ thống tập tin, chẳng hạn như ext4 và F2FS, cũng hỗ trợ tính năng không được dùng nữa
ioctl FS_IOC_GET_ENCRYPTION_PWSALT.  Ioctl này lấy ngẫu nhiên
đã tạo ra giá trị 16 byte được lưu trữ trong siêu khối hệ thống tập tin.  Cái này
giá trị được dự định sử dụng làm muối khi lấy khóa mã hóa
từ cụm mật khẩu hoặc thông tin xác thực người dùng có entropy thấp khác.

FS_IOC_GET_ENCRYPTION_PWSALT không được dùng nữa.  Thay vào đó, thích
tạo và quản lý mọi loại muối cần thiết trong không gian người dùng.

Nhận mã hóa của tập tin nonce
---------------------------------

Kể từ Linux v5.7, ioctl FS_IOC_GET_ENCRYPTION_NONCE được hỗ trợ.
Trên các tập tin và thư mục được mã hóa, nó nhận được số nonce 16 byte của inode.
Trên các tệp và thư mục không được mã hóa, ENODATA không thành công.

Ioctl này có thể hữu ích cho các thử nghiệm tự động xác minh rằng
mã hóa đang được thực hiện chính xác.  Nó không cần thiết cho việc sử dụng bình thường
của fscrypt.

Thêm phím
-----------

FS_IOC_ADD_ENCRYPTION_KEY
~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_ADD_ENCRYPTION_KEY ioctl thêm khóa mã hóa chính vào
hệ thống tập tin, tạo ra tất cả các tập tin trên hệ thống tập tin đã được
được mã hóa bằng khóa đó có vẻ "đã được mở khóa", tức là ở dạng văn bản gốc.
Nó có thể được thực thi trên bất kỳ tệp hoặc thư mục nào trên hệ thống tệp đích,
nhưng nên sử dụng thư mục gốc của hệ thống tập tin.  Nó mất vào
một con trỏ tới cấu trúc fscrypt_add_key_arg, được định nghĩa như sau::

cấu trúc fscrypt_add_key_arg {
            cấu trúc fscrypt_key_specifier key_spec;
            __u32 raw_size;
            __u32 key_id;
    #define FSCRYPT_ADD_KEY_FLAG_HW_WRAPPED 0x00000001
            __u32 cờ;
            __u32 __reserved[7];
            __u8 thô[];
    };

#define FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR 1
    #define FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER 2

cấu trúc fscrypt_key_specifier {
            __u32 loại;     /* một trong số FSCRYPT_KEY_SPEC_TYPE_* */
            __u32 __reserved;
            công đoàn {
                    __u8 __reserved[32]; /* dành thêm một số không gian */
                    __u8 bộ mô tả[FSCRYPT_KEY_DESCRIPTOR_SIZE];
                    __u8 mã định danh[FSCRYPT_KEY_IDENTIFIER_SIZE];
            } bạn;
    };

cấu trúc fscrypt_provisioning_key_payload {
            __u32 loại;
            __u32 cờ;
            __u8 thô[];
    };

struct fscrypt_add_key_arg phải bằng 0, sau đó được khởi tạo
như sau:

- Nếu khóa đang được thêm vào để sử dụng bởi chính sách mã hóa v1 thì
  ZZ0000ZZ phải chứa FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR và
  ZZ0001ZZ phải chứa phần mô tả của khóa
  được thêm vào, tương ứng với giá trị trong
  Trường ZZ0002ZZ của cấu trúc fscrypt_policy_v1.
  Để thêm loại khóa này, quá trình gọi phải có
  Khả năng CAP_SYS_ADMIN trong không gian tên người dùng ban đầu.

Ngoài ra, nếu khóa đang được thêm để sử dụng bằng mã hóa v2
  chính sách thì ZZ0000ZZ phải chứa
  FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER và ZZ0001ZZ là
  trường ZZ0003ZZ mà hạt nhân điền vào bằng mật mã
  hàm băm của khóa.  Để thêm loại khóa này, quá trình gọi sẽ thực hiện
  không cần bất kỳ đặc quyền nào.  Tuy nhiên, số lượng khóa có thể được
  được thêm vào bị giới hạn bởi hạn ngạch của người dùng đối với dịch vụ móc khóa (xem
  ZZ0002ZZ).

- ZZ0000ZZ phải có kích thước bằng khóa ZZ0001ZZ được cung cấp, tính bằng byte.
  Ngoài ra, nếu ZZ0002ZZ khác 0 thì trường này phải bằng 0, vì
  trong trường hợp đó kích thước được ngụ ý bởi khóa khóa Linux được chỉ định.

- ZZ0000ZZ là 0 nếu khóa được cấp trực tiếp trong trường ZZ0001ZZ.
  Mặt khác, ZZ0002ZZ là ID của loại khóa Linux
  "cung cấp fscrypt" có trọng tải là cấu trúc
  fscrypt_provisioning_key_payload có trường ZZ0003ZZ chứa
  khóa, có trường ZZ0004ZZ khớp với ZZ0005ZZ và có
  Trường ZZ0006ZZ khớp với ZZ0007ZZ.  Vì ZZ0008ZZ là
  có độ dài thay đổi, tổng kích thước tải trọng của khóa này phải là
  ZZ0009ZZ cộng với số
  của các byte khóa.  Quá trình này phải có quyền Tìm kiếm trên khóa này.

Hầu hết người dùng nên để lại số 0 này và chỉ định khóa trực tiếp.  các
  hỗ trợ chỉ định khóa khóa Linux chủ yếu nhằm mục đích
  cho phép thêm lại khóa sau khi hệ thống tập tin được ngắt kết nối và gắn lại,
  mà không cần phải lưu trữ các khóa trong bộ nhớ không gian người dùng.

- ZZ0000ZZ chứa các cờ tùy chọn từ ZZ0001ZZ:

- FSCRYPT_ADD_KEY_FLAG_HW_WRAPPED: Điều này biểu thị rằng khóa là một
    khóa bọc phần cứng.  Xem ZZ0000ZZ.  Lá cờ này
    không thể sử dụng được nếu sử dụng FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR.

- ZZ0000ZZ là trường có độ dài thay đổi phải chứa thông tin thực tế
  khóa, ZZ0001ZZ dài byte.  Ngoài ra, nếu ZZ0002ZZ là
  khác 0 thì trường này không được sử dụng.  Lưu ý rằng mặc dù được đặt tên
  ZZ0003ZZ, nếu FSCRYPT_ADD_KEY_FLAG_HW_WRAPPED được chỉ định thì nó
  sẽ chứa khóa được bọc, không phải khóa thô.

Đối với các khóa chính sách v2, kernel theo dõi người dùng nào (được xác định
bằng ID người dùng hiệu quả) đã thêm khóa và chỉ cho phép khóa
bị xóa bởi người dùng đó --- hoặc bởi "root", nếu họ sử dụng
ZZ0000ZZ.

Tuy nhiên, nếu người dùng khác đã thêm khóa thì có thể nên
ngăn chặn người dùng khác bất ngờ xóa nó.  Vì vậy,
FS_IOC_ADD_ENCRYPTION_KEY cũng có thể được sử dụng để thêm khóa chính sách v2
ZZ0000ZZ, ngay cả khi nó đã được người dùng khác thêm vào.  Trong trường hợp này,
FS_IOC_ADD_ENCRYPTION_KEY sẽ chỉ cài đặt xác nhận quyền sở hữu khóa cho
người dùng hiện tại, thay vì thực sự thêm lại khóa (nhưng khóa phải
vẫn được cung cấp, như một bằng chứng về kiến thức).

FS_IOC_ADD_ENCRYPTION_KEY trả về 0 nếu khóa hoặc yêu cầu đối với
khóa đã được thêm hoặc đã tồn tại.

FS_IOC_ADD_ENCRYPTION_KEY có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR đã được chỉ định, nhưng
  người gọi ban đầu không có khả năng CAP_SYS_ADMIN
  không gian tên người dùng; hoặc khóa được chỉ định bởi ID khóa Linux nhưng
  quá trình thiếu quyền Tìm kiếm trên khóa.
- ZZ0001ZZ: khóa bọc phần cứng không hợp lệ
- ZZ0002ZZ: hạn ngạch khóa cho người dùng này sẽ bị vượt quá bằng cách thêm
  chìa khóa
- ZZ0003ZZ: kích thước khóa hoặc loại bộ xác định khóa không hợp lệ hoặc các bit dành riêng
  đã được thiết lập
- ZZ0004ZZ: khóa được chỉ định bởi ID khóa Linux, nhưng khóa
  có loại sai
- ZZ0005ZZ: khóa được chỉ định bởi ID khóa Linux, nhưng không tồn tại khóa
  với ID đó
- ZZ0006ZZ: loại hệ thống tập tin này không thực hiện mã hóa
- ZZ0007ZZ: kernel không được cấu hình mã hóa
  hỗ trợ cho hệ thống tập tin này hoặc siêu khối hệ thống tập tin chưa
  đã kích hoạt mã hóa trên đó; hoặc một khóa bọc phần cứng đã được chỉ định
  nhưng hệ thống tập tin không hỗ trợ mã hóa nội tuyến hoặc phần cứng
  không hỗ trợ các phím bọc phần cứng

Phương pháp kế thừa
~~~~~~~~~~~~~

Đối với chính sách mã hóa v1, khóa mã hóa chính cũng có thể được
được cung cấp bằng cách thêm nó vào khóa được đăng ký theo quy trình, ví dụ: đến một
khóa phiên hoặc tới khóa người dùng nếu khóa người dùng được liên kết
vào khóa phiên.

Phương pháp này không được dùng nữa (và không được hỗ trợ cho mã hóa v2
chính sách) vì nhiều lý do.  Đầu tiên, nó không thể được sử dụng trong
kết hợp với FS_IOC_REMOVE_ENCRYPTION_KEY (xem ZZ0002ZZ),
vì vậy, để xóa khóa, hãy giải quyết như keyctl_unlink() trong
kết hợp với ZZ0000ZZ sẽ
phải được sử dụng.  Thứ hai, nó không phù hợp với thực tế là
trạng thái khóa/mở khóa của các tập tin được mã hóa (tức là liệu chúng có xuất hiện
ở dạng bản rõ hoặc ở dạng bản mã) là toàn cục.  Sự không phù hợp này
đã gây ra nhiều nhầm lẫn cũng như các vấn đề thực sự khi các quy trình
chạy dưới các UID khác nhau, chẳng hạn như lệnh ZZ0001ZZ, cần phải
truy cập các tập tin được mã hóa.

Tuy nhiên, để thêm khóa vào một trong các chuỗi khóa được đăng ký quy trình,
có thể sử dụng lệnh gọi hệ thống add_key() (xem:
ZZ0000ZZ).  Loại khóa phải là
"đăng nhập"; các khóa thuộc loại này được lưu giữ trong bộ nhớ kernel và không thể
đọc lại bởi không gian người dùng.  Mô tả khóa phải là "fscrypt:"
tiếp theo là biểu diễn dạng hex chữ thường gồm 16 ký tự của
ZZ0001ZZ đã được đặt trong chính sách mã hóa.  các
tải trọng chính phải tuân theo cấu trúc sau::

#define FSCRYPT_MAX_KEY_SIZE 64

cấu trúc fscrypt_key {
            Chế độ __u32;
            __u8 thô[FSCRYPT_MAX_KEY_SIZE];
            __u32 kích thước;
    };

ZZ0000ZZ bị bỏ qua; chỉ cần đặt nó thành 0. Khóa thực tế được cung cấp trong
ZZ0001ZZ với ZZ0002ZZ cho biết kích thước của nó tính bằng byte.  Đó là,
byte ZZ0003ZZ (đã bao gồm) là khóa thực tế.

Tiền tố mô tả khóa "fscrypt:" có thể được thay thế
với tiền tố dành riêng cho hệ thống tệp, chẳng hạn như "ext4:".  Tuy nhiên,
tiền tố dành riêng cho hệ thống tập tin không được dùng nữa và không nên được sử dụng trong
các chương trình mới.

Xóa phím
-------------

Có sẵn hai ioctls để xóa khóa được thêm bởi
ZZ0000ZZ:

-ZZ0000ZZ
-ZZ0001ZZ

Hai ioctls này chỉ khác nhau trong trường hợp khóa chính sách v2 được thêm vào
hoặc bị xóa bởi người dùng không phải root.

Các ioctls này không hoạt động trên các khóa được thêm thông qua phiên bản cũ
cơ chế móc khóa được đăng ký theo quy trình.

Trước khi sử dụng các ioctls này, hãy đọc phần ZZ0000ZZ để biết
thảo luận về các mục tiêu bảo mật và hạn chế của các ioctls này.

FS_IOC_REMOVE_ENCRYPTION_KEY
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_REMOVE_ENCRYPTION_KEY ioctl xóa yêu cầu đối với chủ
khóa mã hóa khỏi hệ thống tập tin và có thể xóa khóa
chính nó.  Nó có thể được thực thi trên bất kỳ tập tin hoặc thư mục nào trên mục tiêu
hệ thống tập tin, nhưng nên sử dụng thư mục gốc của hệ thống tập tin.
Nó lấy một con trỏ tới cấu trúc fscrypt_remove_key_arg, được xác định
như sau::

cấu trúc fscrypt_remove_key_arg {
            cấu trúc fscrypt_key_specifier key_spec;
    #define FSCRYPT_KEY_REMOVAL_STATUS_FLAG_FILES_BUSY 0x00000001
    #define FSCRYPT_KEY_REMOVAL_STATUS_FLAG_OTHER_USERS 0x00000002
            __u32 loại bỏ_status_flags;     /*xuất ra*/
            __u32 __reserved[5];
    };

Cấu trúc này phải bằng 0, sau đó được khởi tạo như sau:

- Key cần gỡ bỏ được chỉ định bởi ZZ0000ZZ:

- Để xóa khóa được sử dụng bởi chính sách mã hóa v1, hãy đặt
      ZZ0000ZZ sang FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR và điền vào
      trong ZZ0001ZZ.  Để loại bỏ loại khóa này,
      quá trình gọi phải có khả năng CAP_SYS_ADMIN trong
      không gian tên người dùng ban đầu.

- Để xóa khóa được sử dụng bởi chính sách mã hóa v2, hãy đặt
      ZZ0000ZZ sang FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER và điền vào
      trong ZZ0001ZZ.

Đối với các khóa chính sách v2, người dùng không phải root có thể sử dụng ioctl này.  Tuy nhiên,
để thực hiện được điều này, thực ra nó chỉ xóa địa chỉ của người dùng hiện tại
yêu cầu chìa khóa, hoàn tác một cuộc gọi tới FS_IOC_ADD_ENCRYPTION_KEY.
Chỉ sau khi tất cả các xác nhận quyền sở hữu bị xóa thì khóa mới thực sự bị xóa.

Ví dụ: nếu FS_IOC_ADD_ENCRYPTION_KEY được gọi với uid 1000,
thì khóa sẽ được uid 1000 "xác nhận" và
FS_IOC_REMOVE_ENCRYPTION_KEY sẽ chỉ thành công dưới dạng uid 1000. Hoặc, nếu
cả uids 1000 và 2000 đều thêm khóa, sau đó cho mỗi uid
FS_IOC_REMOVE_ENCRYPTION_KEY sẽ chỉ xóa yêu cầu của riêng họ.  Chỉ
một khi ZZ0000ZZ bị xóa thì chìa khóa thực sự bị xóa.  (Hãy nghĩ về nó như
hủy liên kết một tập tin có thể có liên kết cứng.)

Nếu FS_IOC_REMOVE_ENCRYPTION_KEY thực sự loại bỏ chìa khóa, nó cũng sẽ
cố gắng "khóa" tất cả các tập tin đã được mở khóa bằng chìa khóa.  Nó sẽ không
lock các tập tin vẫn đang được sử dụng, vì vậy ioctl này dự kiến sẽ được sử dụng
phối hợp với không gian người dùng để đảm bảo rằng không có tệp nào bị
vẫn mở.  Tuy nhiên, nếu cần, ioctl này có thể được thực thi lại
sau đó để thử khóa lại mọi tập tin còn lại.

FS_IOC_REMOVE_ENCRYPTION_KEY trả về 0 nếu khóa bị xóa
(nhưng có thể vẫn còn các tập tin bị khóa), yêu cầu của người dùng đối với
khóa đã bị xóa hoặc khóa đã bị xóa nhưng có tệp
còn lại bị khóa nên ioctl đã thử khóa lại chúng.  Trong bất kỳ
trong những trường hợp này, ZZ0000ZZ được điền bằng
cờ trạng thái thông tin sau:

- ZZ0000ZZ: đặt nếu một số tệp
  vẫn đang được sử dụng.  Không đảm bảo được thiết lập trong trường hợp chỉ
  yêu cầu của người dùng đối với khóa đã bị xóa.
- ZZ0001ZZ: thiết lập nếu chỉ
  yêu cầu của người dùng đối với khóa đã bị xóa chứ không phải chính khóa đó

FS_IOC_REMOVE_ENCRYPTION_KEY có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: Kiểu xác định khóa FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR
  đã được chỉ định, nhưng người gọi không có CAP_SYS_ADMIN
  khả năng trong không gian tên người dùng ban đầu
- ZZ0001ZZ: loại bộ xác định khóa không hợp lệ hoặc các bit dành riêng đã được đặt
- ZZ0002ZZ: đối tượng chính hoàn toàn không tìm thấy, tức là không bao giờ
  được thêm vào ngay từ đầu hoặc đã bị xóa hoàn toàn bao gồm tất cả
  tập tin bị khóa; hoặc, người dùng không có quyền yêu cầu khóa (nhưng
  người khác làm).
- ZZ0003ZZ: loại hệ thống tập tin này không thực hiện mã hóa
- ZZ0004ZZ: kernel không được cấu hình mã hóa
  hỗ trợ cho hệ thống tập tin này hoặc siêu khối hệ thống tập tin chưa
  đã kích hoạt mã hóa trên đó

FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS hoàn toàn giống với
ZZ0000ZZ, ngoại trừ các khóa chính sách v2,
Phiên bản ALL_USERS của ioctl sẽ xóa tất cả các khiếu nại của người dùng đối với
key, không chỉ của người dùng hiện tại.  Tức là, bản thân chìa khóa sẽ luôn là
đã bị xóa, bất kể có bao nhiêu người dùng đã thêm nó.  Sự khác biệt này là
chỉ có ý nghĩa nếu người dùng không phải root thêm và xóa khóa.

Vì điều này, FS_IOC_REMOVE_ENCRYPTION_KEY_ALL_USERS cũng yêu cầu
"root", cụ thể là khả năng CAP_SYS_ADMIN ở người dùng ban đầu
không gian tên.  Nếu không nó sẽ thất bại với EACCES.

Nhận trạng thái chính
------------------

FS_IOC_GET_ENCRYPTION_KEY_STATUS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

FS_IOC_GET_ENCRYPTION_KEY_STATUS ioctl truy xuất trạng thái của một
khóa mã hóa chính.  Nó có thể được thực thi trên bất kỳ tập tin hoặc thư mục nào trên
hệ thống tập tin đích, nhưng việc sử dụng thư mục gốc của hệ thống tập tin là
đề nghị.  Nó cần một con trỏ để
struct fscrypt_get_key_status_arg, được định nghĩa như sau::

cấu trúc fscrypt_get_key_status_arg {
            /*đầu vào*/
            cấu trúc fscrypt_key_specifier key_spec;
            __u32 __reserved[6];

/*xuất ra*/
    #define FSCRYPT_KEY_STATUS_ABSENT 1
    #define FSCRYPT_KEY_STATUS_PRESENT 2
    #define FSCRYPT_KEY_STATUS_INCOMPLETELY_REMOVED 3
            trạng thái __u32;
    #define FSCRYPT_KEY_STATUS_FLAG_ADDED_BY_SELF 0x00000001
            __u32 trạng thái_flags;
            __u32 user_count;
            __u32 __out_reserved[13];
    };

Người gọi phải đưa tất cả các trường đầu vào về 0, sau đó điền ZZ0000ZZ:

- Để lấy trạng thái của khóa cho chính sách mã hóa v1, hãy đặt
      ZZ0000ZZ sang FSCRYPT_KEY_SPEC_TYPE_DESCRIPTOR và điền vào
      trong ZZ0001ZZ.

- Để lấy trạng thái của khóa cho chính sách mã hóa v2, hãy đặt
      ZZ0000ZZ sang FSCRYPT_KEY_SPEC_TYPE_IDENTIFIER và điền vào
      trong ZZ0001ZZ.

Nếu thành công, 0 được trả về và kernel điền vào các trường đầu ra:

- ZZ0000ZZ cho biết khóa không có, có hoặc không
  loại bỏ không đầy đủ.  Loại bỏ không hoàn toàn có nghĩa là việc loại bỏ có
  đã được khởi tạo nhưng một số tệp vẫn đang được sử dụng; tức là,
  ZZ0001ZZ trả về 0 nhưng đặt thông tin
  cờ trạng thái FSCRYPT_KEY_REMOVAL_STATUS_FLAG_FILES_BUSY.

- ZZ0000ZZ có thể chứa các cờ sau:

- ZZ0000ZZ chỉ ra rằng phím
      đã được thêm bởi người dùng hiện tại.  Điều này chỉ được đặt cho các phím
      được xác định bởi ZZ0001ZZ chứ không phải bởi ZZ0002ZZ.

- ZZ0000ZZ chỉ định số lượng người dùng đã thêm key.
  Điều này chỉ được đặt cho các khóa được xác định bởi ZZ0001ZZ chứ không phải
  bởi ZZ0002ZZ.

FS_IOC_GET_ENCRYPTION_KEY_STATUS có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: loại bộ xác định khóa không hợp lệ hoặc các bit dành riêng đã được đặt
- ZZ0001ZZ: loại hệ thống tập tin này không thực hiện mã hóa
- ZZ0002ZZ: kernel không được cấu hình mã hóa
  hỗ trợ cho hệ thống tập tin này hoặc siêu khối hệ thống tập tin chưa
  đã kích hoạt mã hóa trên đó

Trong số các trường hợp sử dụng khác, FS_IOC_GET_ENCRYPTION_KEY_STATUS có thể hữu ích
để xác định xem khóa cho một thư mục được mã hóa nhất định có cần
được thêm vào trước khi nhắc người dùng nhập cụm mật khẩu cần thiết để
lấy được chìa khóa.

FS_IOC_GET_ENCRYPTION_KEY_STATUS chỉ có thể nhận được trạng thái của các phím trong
khóa cấp hệ thống tập tin, tức là khóa được quản lý bởi
ZZ0000ZZ và ZZ0001ZZ.  Nó
không thể nhận trạng thái của khóa chỉ được thêm vào để sử dụng bởi v1
chính sách mã hóa sử dụng cơ chế kế thừa liên quan đến
dây khóa được đăng ký theo quy trình.

Truy cập ngữ nghĩa
================

Với chìa khóa
------------

Với khóa mã hóa, các tập tin, thư mục thông thường được mã hóa và
các liên kết tượng trưng hoạt động rất giống với các liên kết không được mã hóa ---
xét cho cùng, mã hóa nhằm mục đích minh bạch.  Tuy nhiên,
người dùng khôn ngoan có thể nhận thấy một số khác biệt trong hành vi:

- Tệp không được mã hóa hoặc tệp được mã hóa bằng mã hóa khác
  chính sách (tức là khóa, chế độ hoặc cờ khác nhau), không thể đổi tên hoặc
  liên kết vào một thư mục được mã hóa; xem ZZ0000ZZ.  Nỗ lực làm như vậy sẽ thất bại với EXDEV.  Tuy nhiên,
  các tập tin được mã hóa có thể được đổi tên trong một thư mục được mã hóa hoặc
  vào một thư mục không được mã hóa.

Lưu ý: "di chuyển" một tệp không được mã hóa vào một thư mục được mã hóa, ví dụ:
  với chương trình ZZ0000ZZ, được triển khai trong không gian người dùng bằng một bản sao
  theo sau là xóa.  Xin lưu ý rằng dữ liệu ban đầu không được mã hóa
  có thể vẫn có thể phục hồi được từ không gian trống trên đĩa; thích giữ hơn
  tất cả các tập tin được mã hóa ngay từ đầu.  Chương trình ZZ0001ZZ
  có thể được sử dụng để ghi đè lên các tệp nguồn nhưng không được đảm bảo
  hiệu quả trên tất cả các hệ thống tập tin và thiết bị lưu trữ.

- I/O trực tiếp chỉ được hỗ trợ trên các tập tin được mã hóa trong một số
  hoàn cảnh.  Để biết chi tiết, xem ZZ0000ZZ.

- Các phép toán sai vị trí FALLOC_FL_COLLAPSE_RANGE và
  FALLOC_FL_INSERT_RANGE không được hỗ trợ trên các tệp được mã hóa và sẽ
  thất bại với EOPNOTSUPP.

- Không hỗ trợ chống phân mảnh trực tuyến các tập tin được mã hóa.  các
  ioctls EXT4_IOC_MOVE_EXT và F2FS_IOC_MOVE_RANGE sẽ thất bại với
  EOPNOTSUPP.

- Hệ thống tập tin ext4 không hỗ trợ ghi nhật ký dữ liệu bằng mã hóa
  các tập tin thông thường.  Thay vào đó, nó sẽ quay trở lại chế độ dữ liệu được đặt hàng.

- DAX (Truy cập trực tiếp) không được hỗ trợ trên các tệp được mã hóa.

- Độ dài tối đa của một liên kết tượng trưng được mã hóa ngắn hơn 2 byte so với
  độ dài tối đa của một liên kết tượng trưng không được mã hóa.  Ví dụ, trên một
  Hệ thống tệp EXT4 có kích thước khối 4K, các liên kết tượng trưng không được mã hóa có thể tăng lên
  dài tới 4095 byte, trong khi các liên kết tượng trưng được mã hóa chỉ có thể lên tới 4093
  dài byte (cả hai độ dài không bao gồm null kết thúc).

Lưu ý rằng mmap ZZ0000ZZ được hỗ trợ.  Điều này có thể thực hiện được vì bộ đệm trang
đối với một tệp được mã hóa chứa bản rõ chứ không phải bản mã.

Không có chìa khóa
---------------

Một số thao tác hệ thống tập tin có thể được thực hiện trên các thiết bị thông thường được mã hóa.
các tập tin, thư mục và liên kết tượng trưng ngay cả trước khi khóa mã hóa của chúng có
đã được thêm vào hoặc sau khi khóa mã hóa của họ bị xóa:

- Siêu dữ liệu tệp có thể được đọc, ví dụ: sử dụng stat().

- Các thư mục có thể được liệt kê, trong trường hợp đó tên tập tin sẽ được
  được liệt kê ở dạng được mã hóa bắt nguồn từ bản mã của chúng.  các
  thuật toán mã hóa hiện tại được mô tả trong ZZ0002ZZ.  Thuật toán có thể thay đổi nhưng
  đảm bảo rằng tên tập tin được trình bày sẽ không dài hơn
  Các byte NAME_MAX sẽ không chứa các ký tự ZZ0000ZZ hoặc ZZ0001ZZ và
  sẽ xác định duy nhất các mục thư mục.

Các mục thư mục ZZ0000ZZ và ZZ0001ZZ là đặc biệt.  Họ luôn luôn
  hiện tại và không được mã hóa hoặc mã hóa.

- Tập tin có thể bị xóa.  Nghĩa là, các tập tin không có thư mục có thể bị xóa
  bằng unlink() như thường lệ và các thư mục trống có thể bị xóa bằng
  rmdir() như thường lệ.  Do đó, ZZ0000ZZ và ZZ0001ZZ sẽ hoạt động như
  mong đợi.

- Mục tiêu liên kết tượng trưng có thể được đọc và theo dõi, nhưng chúng sẽ được trình bày
  ở dạng mã hóa, tương tự như tên tập tin trong thư mục.  Do đó, họ
  không có khả năng trỏ đến bất cứ nơi nào hữu ích.

Không có khóa, các tập tin thông thường không thể mở hoặc cắt bớt được.
Nỗ lực làm như vậy sẽ thất bại với ENOKEY.  Điều này ngụ ý rằng bất kỳ
các thao tác tệp thông thường yêu cầu bộ mô tả tệp, chẳng hạn như
read(), write(), mmap(), fallocate() và ioctl() cũng bị cấm.

Ngoài ra, nếu không có khóa, mọi loại tập tin (kể cả thư mục) đều không thể
được tạo hoặc liên kết vào một thư mục được mã hóa, cũng như tên trong một
thư mục được mã hóa có thể là nguồn hoặc mục tiêu của việc đổi tên, cũng như không thể
Tệp tạm thời O_TMPFILE được tạo trong một thư mục được mã hóa.  Tất cả
những hoạt động như vậy sẽ thất bại với ENOKEY.

Hiện tại không thể sao lưu và khôi phục các tập tin được mã hóa
không có khóa mã hóa.  Điều này sẽ yêu cầu các API đặc biệt
vẫn chưa được triển khai.

Thực thi chính sách mã hóa
=============================

Sau khi chính sách mã hóa đã được đặt trên một thư mục, tất cả thông thường
các tập tin, thư mục và các liên kết tượng trưng được tạo trong thư mục đó
(đệ quy) sẽ kế thừa chính sách mã hóa đó.  Các tập tin đặc biệt ---
nghĩa là, các đường ống được đặt tên, các nút thiết bị và ổ cắm miền UNIX --- sẽ
không được mã hóa.

Ngoại trừ những tập tin đặc biệt đó, không được phép có các tập tin không được mã hóa.
các tệp hoặc các tệp được mã hóa bằng chính sách mã hóa khác, trong một
cây thư mục được mã hóa  Cố gắng liên kết hoặc đổi tên một tập tin như vậy thành
một thư mục được mã hóa sẽ không thành công với EXDEV.  Điều này cũng được thực thi
trong quá trình ->lookup() để cung cấp sự bảo vệ hạn chế chống lại tình trạng ngoại tuyến
các cuộc tấn công cố gắng vô hiệu hóa hoặc hạ cấp mã hóa ở những vị trí đã biết
nơi các ứng dụng sau này có thể ghi dữ liệu nhạy cảm.  Nó được khuyến khích
rằng các hệ thống triển khai hình thức "khởi động đã được xác minh" sẽ tận dụng
điều này bằng cách xác thực tất cả các chính sách mã hóa cấp cao nhất trước khi truy cập.

Hỗ trợ mã hóa nội tuyến
=========================

Nhiều hệ thống mới hơn (đặc biệt là SoC di động) có *mã hóa nội tuyến
phần cứng* có thể mã hóa/giải mã dữ liệu khi nó đang trên đường đến/từ
thiết bị lưu trữ.  Linux hỗ trợ mã hóa nội tuyến thông qua một bộ
phần mở rộng cho lớp khối có tên ZZ0001ZZ.  blk-crypto cho phép
hệ thống tập tin để đính kèm bối cảnh mã hóa vào bios (yêu cầu I/O) vào
chỉ định cách dữ liệu sẽ được mã hóa hoặc giải mã nội tuyến.  Để biết thêm
thông tin về blk-crypto, xem
ZZ0000ZZ.

Trên các hệ thống tệp được hỗ trợ (hiện tại là ext4 và f2fs), fscrypt có thể sử dụng
blk-crypto thay vì kernel crypto API để mã hóa/giải mã tập tin
nội dung.  Để kích hoạt tính năng này, hãy đặt CONFIG_FS_ENCRYPTION_INLINE_CRYPT=y trong
cấu hình kernel và chỉ định tùy chọn gắn kết "inlinecrypt"
khi gắn hệ thống tập tin.

Lưu ý rằng tùy chọn gắn kết "inlinecrypt" chỉ chỉ định sử dụng nội tuyến
mã hóa khi có thể; nó không ép buộc việc sử dụng nó.  fscrypt sẽ
vẫn quay lại sử dụng kernel crypto API trên các tệp có
phần cứng mã hóa nội tuyến không có khả năng mã hóa cần thiết
(ví dụ: hỗ trợ thuật toán mã hóa cần thiết và kích thước đơn vị dữ liệu)
và nơi blk-crypto-fallback không thể sử dụng được.  (Đối với blk-crypto-dự phòng
để có thể sử dụng được, nó phải được kích hoạt trong cấu hình kernel với
CONFIG_BLK_INLINE_ENCRYPTION_FALLBACK=y và tệp phải là
được bảo vệ bằng khóa thô thay vì khóa được bọc phần cứng.)

Hiện tại fscrypt luôn sử dụng kích thước khối hệ thống tập tin (tức là
thường là 4096 byte) làm kích thước đơn vị dữ liệu.  Vì vậy, nó chỉ có thể sử dụng
phần cứng mã hóa nội tuyến hỗ trợ kích thước đơn vị dữ liệu đó.

Mã hóa nội tuyến không ảnh hưởng đến bản mã hoặc các khía cạnh khác của
định dạng trên đĩa, do đó người dùng có thể tự do chuyển đổi qua lại giữa
sử dụng "inlinecrypt" và không sử dụng "inlinecrypt".  Một ngoại lệ đó là
các tập tin được bảo vệ bằng khóa bọc phần cứng chỉ có thể được
được mã hóa/giải mã bởi phần cứng mã hóa nội tuyến và do đó
chỉ có thể được truy cập khi tùy chọn gắn kết "inlinecrypt" được sử dụng.  cho
thêm thông tin về các khóa được bọc phần cứng, xem bên dưới.

Phím bọc phần cứng
---------------------

fscrypt hỗ trợ sử dụng ZZ0000ZZ khi nội tuyến
phần cứng mã hóa hỗ trợ nó.  Các khóa như vậy chỉ có trong kernel
bộ nhớ ở dạng được bao bọc (mã hóa); chúng chỉ có thể được mở ra
(được giải mã) bằng phần cứng mã hóa nội tuyến và bị ràng buộc theo thời gian
vào boot hiện tại.  Điều này ngăn không cho các khóa bị xâm phạm nếu
bộ nhớ kernel bị rò rỉ.  Điều này được thực hiện mà không giới hạn số lượng
các phím có thể được sử dụng và trong khi vẫn cho phép thực thi
các tác vụ mật mã được gắn với cùng một khóa nhưng không thể sử dụng nội tuyến
phần cứng mã hóa, ví dụ: mã hóa tên tập tin.

Lưu ý rằng các khóa được bọc phần cứng không dành riêng cho fscrypt; họ là một
tính năng lớp khối (một phần của ZZ0001ZZ).  Để biết thêm chi tiết về
các khóa được bọc phần cứng, xem tài liệu về lớp khối tại
ZZ0000ZZ.  Phần còn lại của phần này chỉ tập trung vào
chi tiết về cách fscrypt có thể sử dụng các khóa được bọc trong phần cứng.

fscrypt hỗ trợ các khóa được bọc phần cứng bằng cách cho phép fscrypt master
các khóa là các khóa được bọc phần cứng thay thế cho các khóa thô.  Đến
thêm khóa bọc phần cứng với ZZ0002ZZ,
không gian người dùng phải chỉ định FSCRYPT_ADD_KEY_FLAG_HW_WRAPPED trong
Trường ZZ0000ZZ của struct fscrypt_add_key_arg và cả trong
Trường ZZ0001ZZ của cấu trúc fscrypt_provisioning_key_payload khi
áp dụng.  Chìa khóa phải ở dạng được bọc tạm thời, không
dạng bọc dài hạn.

Một số hạn chế được áp dụng.  Đầu tiên, các tập tin được bảo vệ bằng gói phần cứng
khóa được gắn với phần cứng mã hóa nội tuyến của hệ thống.  Vì thế
chúng chỉ có thể được truy cập khi tùy chọn gắn kết "inlinecrypt" được sử dụng,
và chúng không thể được đưa vào hình ảnh hệ thống tập tin di động.  Thứ hai,
hiện tại hỗ trợ khóa được bao bọc bằng phần cứng chỉ tương thích với
ZZ0000ZZ và ZZ0001ZZ, cũng như vậy
giả định rằng chỉ có một khóa mã hóa nội dung tệp cho mỗi
khóa chính fscrypt thay vì một khóa cho mỗi tệp.  Công việc trong tương lai có thể giải quyết
hạn chế này bằng cách chuyển số nonces của mỗi tệp xuống ngăn xếp lưu trữ tới
cho phép phần cứng lấy được các khóa trên mỗi tệp.

Về mặt triển khai, để mã hóa/giải mã nội dung của các tệp được
được bảo vệ bằng khóa bọc phần cứng, fscrypt sử dụng blk-crypto,
gắn khóa được bọc phần cứng vào bối cảnh mật mã sinh học.  Như là
Trong trường hợp khóa thô, lớp khối sẽ lập trình khóa thành một
khe khóa khi nó chưa có sẵn.  Tuy nhiên, khi lập trình một
khóa được bọc phần cứng, phần cứng không lập trình khóa đã cho
trực tiếp vào khe phím mà thay vào đó là mở nó ra (sử dụng
khóa gói tạm thời) và lấy khóa mã hóa nội tuyến từ nó.
Khóa mã hóa nội tuyến là khóa thực sự được lập trình
vào khe khóa và nó không bao giờ được tiếp xúc với phần mềm.

Tuy nhiên, fscrypt không chỉ mã hóa nội dung tệp; nó cũng
sử dụng các khóa chính của nó để lấy các khóa mã hóa tên tệp, khóa
số nhận dạng và đôi khi một số loại khóa con khó hiểu hơn như
phím dirhash.  Vì vậy ngay cả khi mã hóa nội dung tập tin ngoài
picture, fscrypt vẫn cần một khóa thô để làm việc.  Để có được như vậy
khóa từ khóa được bọc phần cứng, fscrypt yêu cầu mã hóa nội tuyến
phần cứng để lấy được "bí mật phần mềm" được cách ly bằng mật mã từ
khóa bọc phần cứng.  fscrypt sử dụng "bí mật phần mềm" này để khóa
KDF của nó để lấy tất cả các khóa con ngoài khóa nội dung tệp.

Lưu ý rằng điều này ngụ ý rằng tính năng khóa được bao bọc trong phần cứng chỉ
bảo vệ các khóa mã hóa nội dung tập tin.  Nó không bảo vệ người khác
các khóa con fscrypt như khóa mã hóa tên tệp.

Hỗ trợ I/O trực tiếp
==================

Để I/O trực tiếp trên tệp được mã hóa hoạt động, các điều kiện sau
phải được đáp ứng (ngoài các điều kiện cho I/O trực tiếp trên một
tập tin không được mã hóa):

* Tệp phải được sử dụng mã hóa nội tuyến.  Thông thường điều này có nghĩa là
  hệ thống tập tin phải được gắn với ZZ0000ZZ và nội tuyến
  phần cứng mã hóa phải có mặt.  Tuy nhiên, một dự phòng phần mềm
  cũng có sẵn.  Để biết chi tiết, xem ZZ0001ZZ.

* Yêu cầu I/O phải được căn chỉnh hoàn toàn theo kích thước khối hệ thống tệp.
  Điều này có nghĩa là vị trí tệp mà I/O đang nhắm mục tiêu, độ dài
  của tất cả các phân đoạn I/O và địa chỉ bộ nhớ của tất cả các bộ đệm I/O
  phải là bội số của giá trị này.  Lưu ý rằng khối hệ thống tập tin
  kích thước có thể lớn hơn kích thước khối logic của thiết bị khối.

Nếu một trong hai điều kiện trên không được đáp ứng thì gửi I/O trực tiếp trên
tập tin được mã hóa sẽ quay trở lại I/O được lưu vào bộ đệm.

Chi tiết triển khai
======================

Bối cảnh mã hóa
------------------

Chính sách mã hóa được thể hiện trên đĩa bằng
cấu trúc fscrypt_context_v1 hoặc cấu trúc fscrypt_context_v2.  Nó tùy thuộc vào
các hệ thống tập tin riêng lẻ để quyết định nơi lưu trữ nó, nhưng thông thường nó
sẽ được lưu trữ trong một thuộc tính mở rộng ẩn.  Nó phải là ZZ0000ZZ
được hiển thị bởi các lệnh gọi hệ thống liên quan đến xattr như getxattr() và
setxattr() vì ngữ nghĩa đặc biệt của xattr mã hóa.
(Đặc biệt, sẽ có nhiều nhầm lẫn nếu chính sách mã hóa
được thêm vào hoặc xóa khỏi bất cứ thứ gì ngoài một khoảng trống
thư mục.) Các cấu trúc này được định nghĩa như sau ::

#define FSCRYPT_FILE_NONCE_SIZE 16

#define FSCRYPT_KEY_DESCRIPTOR_SIZE 8
    cấu trúc fscrypt_context_v1 {
            phiên bản u8;
            nội dung u8_encryption_mode;
            tên tập tin u8_encryption_mode;
            cờ u8;
            u8 master_key_descriptor[FSCRYPT_KEY_DESCRIPTOR_SIZE];
            u8 nonce[FSCRYPT_FILE_NONCE_SIZE];
    };

#define FSCRYPT_KEY_IDENTIFIER_SIZE 16
    cấu trúc fscrypt_context_v2 {
            phiên bản u8;
            nội dung u8_encryption_mode;
            tên tập tin u8_encryption_mode;
            cờ u8;
            u8 log2_data_unit_size;
            u8 __reserved[3];
            u8 master_key_identifier[FSCRYPT_KEY_IDENTIFIER_SIZE];
            u8 nonce[FSCRYPT_FILE_NONCE_SIZE];
    };

Cấu trúc ngữ cảnh chứa thông tin giống như cấu trúc tương ứng
cấu trúc chính sách (xem ZZ0000ZZ), ngoại trừ
cấu trúc ngữ cảnh cũng chứa một nonce.  Nonce được tạo ngẫu nhiên
bởi kernel và được sử dụng làm đầu vào KDF hoặc như một tinh chỉnh để gây ra
các tập tin khác nhau được mã hóa khác nhau; xem ZZ0001ZZ và ZZ0002ZZ.

Thay đổi đường dẫn dữ liệu
-----------------

Khi sử dụng mã hóa nội tuyến, hệ thống tập tin chỉ cần liên kết
bối cảnh mã hóa với bios để chỉ định cách lớp khối hoặc lớp
phần cứng mã hóa nội tuyến sẽ mã hóa/giải mã nội dung tệp.

Khi mã hóa nội tuyến không được sử dụng, hệ thống tập tin phải mã hóa/giải mã
chính nội dung tệp, như được mô tả bên dưới:

Đối với đường dẫn đọc (->read_folio()) của các tệp thông thường, hệ thống tệp có thể
đọc bản mã vào bộ đệm của trang và giải mã nó tại chỗ.  các
khóa folio phải được giữ cho đến khi quá trình giải mã kết thúc, để ngăn chặn việc
folio không hiển thị sớm trên không gian người dùng.

Đối với đường dẫn ghi (->writepages()) của file thông thường, hệ thống file
không thể mã hóa dữ liệu tại chỗ trong bộ nhớ đệm của trang vì
bản rõ phải được bảo tồn.  Thay vào đó, hệ thống tập tin phải mã hóa thành một
vùng đệm tạm thời hoặc "trang thoát", sau đó ghi ra vùng đệm tạm thời
bộ đệm.  Một số hệ thống tập tin, chẳng hạn như UBIFS, đã sử dụng tạm thời
bộ đệm bất kể mã hóa.  Các hệ thống tập tin khác, chẳng hạn như ext4 và
F2FS, phải phân bổ các trang bị trả lại đặc biệt để mã hóa.

Băm và mã hóa tên tệp
-----------------------------

Các hệ thống tập tin hiện đại tăng tốc việc tra cứu thư mục bằng cách sử dụng chỉ mục
thư mục.  Một thư mục được lập chỉ mục được tổ chức dưới dạng cây được khóa bởi
băm tên tập tin.  Khi một ->lookup() được yêu cầu, hệ thống tập tin
thường băm tên tệp đang được tra cứu để có thể nhanh chóng
tìm mục nhập thư mục tương ứng, nếu có.

Với mã hóa, việc tra cứu phải được hỗ trợ và hiệu quả cả với và
không có khóa mã hóa.  Rõ ràng là sẽ không hiệu quả nếu băm
tên tệp văn bản gốc, vì tên tệp văn bản gốc không có sẵn
không có chìa khóa.  (Băm tên tập tin văn bản gốc cũng sẽ làm cho nó
công cụ fsck của hệ thống tập tin không thể tối ưu hóa mã hóa
thư mục.) Thay vào đó, hệ thống tập tin băm tên tập tin văn bản mã hóa,
tức là các byte thực sự được lưu trữ trên đĩa trong các mục nhập thư mục.  Khi nào
được yêu cầu thực hiện ->tra cứu() bằng khóa, hệ thống tập tin chỉ mã hóa
tên do người dùng cung cấp để lấy bản mã.

Việc tra cứu không có khóa sẽ phức tạp hơn.  Bản mã thô có thể
chứa các ký tự ZZ0000ZZ và ZZ0001ZZ, những ký tự này không hợp lệ trong
tên tập tin.  Vì vậy, readdir() phải mã hóa base64url văn bản mã hóa
để trình bày.  Đối với hầu hết các tên tệp, điều này hoạt động tốt; trên ->tra cứu(),
hệ thống tập tin chỉ cần base64url-giải mã tên do người dùng cung cấp để nhận
quay lại bản mã thô.

Tuy nhiên, đối với những tên tệp rất dài, mã hóa base64url sẽ gây ra
độ dài tên tệp vượt quá NAME_MAX.  Để ngăn chặn điều này, readdir()
thực sự trình bày tên tệp dài ở dạng viết tắt mã hóa
một "băm" mạnh của tên tệp văn bản mã hóa, cùng với tùy chọn
(các) hàm băm dành riêng cho hệ thống tập tin cần thiết để tra cứu thư mục.  Cái này
cho phép hệ thống tập tin tĩnh, với độ tin cậy cao, ánh xạ
tên tệp được cung cấp trong ->lookup() quay lại một mục nhập thư mục cụ thể
đã được liệt kê trước đó bởi readdir().  Xem
struct fscrypt_nokey_name trong nguồn để biết thêm chi tiết.

Lưu ý rằng cách chính xác mà tên tệp được hiển thị cho không gian người dùng
không có chìa khóa có thể thay đổi trong tương lai.  Nó chỉ có ý nghĩa
như một cách để tạm thời trình bày tên tệp hợp lệ để các lệnh như
ZZ0000ZZ hoạt động như mong đợi trên các thư mục được mã hóa.

Kiểm tra
=====

Để kiểm tra fscrypt, hãy sử dụng xfstests, đây là tiêu chuẩn thực tế của Linux
bộ kiểm tra hệ thống tập tin.  Đầu tiên, chạy tất cả các bài kiểm tra trong phần "mã hóa"
nhóm trên (các) hệ thống tập tin có liên quan.  Người ta cũng có thể chạy thử nghiệm
với tùy chọn gắn kết 'inlinecrypt' để kiểm tra việc triển khai
hỗ trợ mã hóa nội tuyến.  Ví dụ: để kiểm tra ext4 và
Mã hóa f2fs bằng ZZ0000ZZ::

kvm-xfstests -c ext4,f2fs -g mã hóa
    kvm-xfstests -c ext4,f2fs -g mã hóa -m inlinecrypt

Mã hóa UBIFS cũng có thể được kiểm tra theo cách này, nhưng nó phải được thực hiện trong
một lệnh riêng biệt và phải mất một thời gian để thiết lập kvm-xfstests
khối lượng UBI mô phỏng::

kvm-xfstests -c ubifs -g mã hóa

Không có bài kiểm tra nào sẽ thất bại.  Tuy nhiên, các thử nghiệm sử dụng mã hóa không mặc định
các chế độ (ví dụ: generic/549 và generic/550) sẽ bị bỏ qua nếu cần
các thuật toán không được tích hợp vào mật mã API của hạt nhân.  Ngoài ra, các bài kiểm tra
truy cập vào thiết bị khối thô (ví dụ: generic/399, generic/548,
generic/549, generic/550) sẽ bị bỏ qua trên UBIFS.

Bên cạnh việc chạy thử nghiệm nhóm "mã hóa", đối với ext4 và f2fs, nó cũng
có thể chạy hầu hết các xfstest với mount "test_dummy_encryption"
tùy chọn.  Tùy chọn này khiến tất cả các tệp mới được tự động
được mã hóa bằng khóa giả mà không cần phải thực hiện bất kỳ cuộc gọi API nào.
Việc này sẽ kiểm tra các đường dẫn I/O được mã hóa kỹ lưỡng hơn.  Để làm điều này với
kvm-xfstests, hãy sử dụng cấu hình hệ thống tệp "mã hóa" ::

kvm-xfstests -c ext4/encrypt,f2fs/encrypt -g auto
    kvm-xfstests -c ext4/encrypt,f2fs/encrypt -g auto -m inlinecrypt

Bởi vì điều này chạy nhiều thử nghiệm hơn "-g mã hóa", nên cần
chạy lâu hơn nhiều; vì vậy hãy cân nhắc sử dụng ZZ0000ZZ
thay vì kvm-xfstests::

gce-xfstests -c ext4/encrypt,f2fs/encrypt -g auto
    gce-xfstests -c ext4/encrypt,f2fs/encrypt -g auto -m inlinecrypt
