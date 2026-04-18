.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/st.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Trình điều khiển băng SCSI
==========================

Tệp này chứa thông tin ngắn gọn về trình điều khiển băng SCSI.
Người lái xe hiện được Kai Mäkisara bảo trì (email
Kai.Makisara@kolumbus.fi)

Sửa đổi lần cuối: Thứ ba ngày 9 tháng 2 21:54:16 2016 bởi kai.makisara


Khái niệm cơ bản
================

Trình điều khiển mang tính chung chung, nghĩa là nó không chứa bất kỳ mã nào được thiết kế riêng
tới bất kỳ ổ băng từ cụ thể nào. Các thông số băng có thể được xác định bằng
một trong ba phương pháp sau:

1. Mỗi người dùng có thể chỉ định các thông số băng mình muốn sử dụng
trực tiếp với ioctls. Đây là một công việc hành chính rất đơn giản và
phương pháp linh hoạt và có thể áp dụng cho các máy trạm một người dùng. Tuy nhiên,
trong môi trường nhiều người dùng, người dùng tiếp theo sẽ tìm thấy các tham số băng trong
nêu rõ người dùng trước đó đã rời bỏ họ.

2. Trình quản lý hệ thống (root) có thể xác định các giá trị mặc định cho một số băng
các tham số, như kích thước khối và mật độ bằng cách sử dụng MTSETDRVBUFFER ioctl.
Các tham số này có thể được lập trình để có hiệu lực khi
băng mới được nạp vào ổ đĩa hoặc nếu việc ghi bắt đầu ở
đầu của băng. Phương pháp thứ hai có thể áp dụng nếu băng
ổ đĩa thực hiện tốt việc tự động phát hiện định dạng băng (như một số
Ổ đĩa QIC). Kết quả là bất kỳ băng nào cũng có thể đọc được, có thể ghi được.
tiếp tục sử dụng định dạng hiện có và định dạng mặc định được sử dụng nếu
cuốn băng được viết lại từ đầu (hoặc một cuốn băng mới được viết
lần đầu tiên). Phương pháp đầu tiên có thể áp dụng nếu ổ đĩa
không thực hiện chức năng tự động phát hiện đủ tốt và có một lỗi duy nhất
chế độ "hợp lý" cho thiết bị. Một ví dụ là ổ DAT
chỉ được sử dụng ở chế độ khối biến đổi (tôi không biết điều này có hợp lý không
hay không :-).

Người dùng có thể ghi đè các tham số do hệ thống xác định
người quản lý. Những thay đổi vẫn tồn tại cho đến khi mặc định lại xuất hiện
hiệu ứng.

3. Theo mặc định, có thể xác định và chọn tối đa bốn chế độ bằng cách sử dụng
số (bit 5 và 6). Số lượng chế độ có thể được thay đổi bằng cách thay đổi
ST_NBR_MODE_BITS ở s.h. Chế độ 0 tương ứng với các giá trị mặc định đã thảo luận
ở trên. Các chế độ bổ sung không hoạt động cho đến khi chúng được xác định bởi
người quản lý hệ thống (root). Khi đặc điểm kỹ thuật của một chế độ mới được bắt đầu,
cấu hình của chế độ 0 được sử dụng để cung cấp điểm khởi đầu cho
định nghĩa về chế độ mới.

Việc sử dụng các chế độ cho phép người quản lý hệ thống đưa ra các lựa chọn cho người dùng
qua một số tham số bộ đệm không thể truy cập trực tiếp vào
người dùng (ghi vào bộ đệm và ghi không đồng bộ). Các chế độ cũng cho phép lựa chọn
giữa các định dạng trong thao tác nhiều băng (được ghi đè rõ ràng
các tham số được đặt lại khi băng mới được tải).

Nếu sử dụng nhiều hơn một chế độ, tất cả các chế độ phải chứa định nghĩa
cho cùng một bộ tham số.

Nhiều Unice chứa các bảng nội bộ liên kết các chế độ khác nhau với
các thiết bị được hỗ trợ. Trình điều khiển băng Linux SCSI không chứa các
bảng (và sẽ không làm điều đó trong tương lai). Thay vào đó, một tiện ích
chương trình có thể được thực hiện để tìm nạp dữ liệu yêu cầu được gửi bởi thiết bị,
quét cơ sở dữ liệu của nó và thiết lập các chế độ bằng cách sử dụng ioctls. Khác
cách khác là tạo một tập lệnh nhỏ sử dụng mt để đặt mặc định
phù hợp với hệ thống.

Trình điều khiển hỗ trợ kích thước khối cố định và thay đổi (trong bộ đệm
giới hạn). Cả tính năng tự động tua lại (nhỏ bằng số thiết bị) và
thiết bị không tua lại (nhỏ là 128 + số thiết bị) được triển khai.

Trong chế độ khối biến, số byte trong write() xác định kích thước
của khối vật lý trên băng. Khi đọc, ổ đĩa sẽ đọc phần tiếp theo
chặn băng và trả về dữ liệu cho người dùng nếu số byte read()
ít nhất là kích thước khối. Nếu không, lỗi ENOMEM sẽ được trả về.

Ở chế độ khối cố định, việc truyền dữ liệu giữa ổ đĩa và
trình điều khiển có kích thước bội số của khối. Số byte write() phải
là bội số của kích thước khối. Điều này không bắt buộc khi đọc nhưng
có thể được khuyến khích cho tính di động.

Hỗ trợ được cung cấp để thay đổi phân vùng băng và phân vùng
của băng có một hoặc hai phân vùng. Theo mặc định hỗ trợ cho
băng phân vùng bị vô hiệu hóa cho mỗi trình điều khiển và nó có thể được kích hoạt
với ioctl MTSETDRVBUFFER.

Theo mặc định, trình điều khiển ghi một filemark khi đóng thiết bị sau
viết và thao tác cuối cùng là viết. Hai dấu tập tin có thể được
tùy ý viết. Trong cả hai trường hợp, phần cuối của dữ liệu được biểu thị bằng
trả về 0 byte cho hai lần đọc liên tiếp.

Viết các dấu tập tin mà không có bit ngay lập tức được đặt trong khối lệnh SCSI
như một điểm đồng bộ hóa, tức là tất cả dữ liệu còn lại từ bộ đệm ổ đĩa được
được ghi vào băng trước khi lệnh quay trở lại. Điều này đảm bảo rằng lỗi ghi
bị bắt vào thời điểm đó, nhưng việc này cần có thời gian. Trong một số ứng dụng, một số
các tập tin liên tiếp phải được viết nhanh. Hoạt động MTWEOFI có thể được sử dụng để
ghi các tập tin mà không xóa bộ đệm ổ đĩa. Viết filemark tại
close() luôn xóa bộ đệm ổ đĩa. Tuy nhiên, nếu trước đó
hoạt động là MTWEOFI, close() không ghi filemark. Điều này có thể được sử dụng nếu
chương trình muốn đóng/mở thiết bị băng từ giữa các tập tin và muốn
bỏ qua việc chờ đợi.

Nếu tua lại, ngoại tuyến, bsf hoặc tìm kiếm được thực hiện và thao tác băng trước đó đã được thực hiện
ghi, một filemark được ghi trước khi di chuyển băng.

Các tùy chọn biên dịch được xác định trong tệp linux/drivers/scsi/st_options.h.

4. Nếu tùy chọn mở O_NONBLOCK được sử dụng, việc mở thành công ngay cả khi
ổ đĩa chưa sẵn sàng. Nếu O_NONBLOCK không được sử dụng, trình điều khiển sẽ đợi
động lực để trở nên sẵn sàng. Nếu điều này không xảy ra trong ST_BLOCK_SECONDS
giây, mở không thành công với giá trị lỗi EIO. Với O_NONBLOCK,
thiết bị có thể được mở để ghi ngay cả khi có chế độ bảo vệ chống ghi
băng trong ổ đĩa (các lệnh cố gắng ghi nội dung nào đó sẽ trả về lỗi nếu
đã cố gắng).


Số thứ yếu
=============

Trình điều khiển băng từ hiện hỗ trợ tối đa 2^17 ổ đĩa nếu có 4 chế độ cho
mỗi ổ đĩa được sử dụng.

Các số phụ bao gồm các trường bit sau::

dev_upper chế độ không rew dev-low
    20 - 8 7 6 5 4 0

Bit không tua lại luôn là bit 7 (bit cao nhất ở mức thấp nhất
byte). Các bit xác định chế độ nằm bên dưới bit không tua lại. các
các bit còn lại xác định số thiết bị băng. Việc đánh số này là
tương thích ngược với cách đánh số được sử dụng khi số thứ được
chỉ rộng 8 bit.


Hỗ trợ hệ thống
===============

Trình điều khiển tạo thư mục /sys/class/scsi_tape và điền vào đó
thư mục tương ứng với các thiết bị băng hiện có. Có tính năng tự động tua lại
và các mục không tua lại cho từng chế độ. Tên là stxy và nstxy, trong đó x
là số băng và y là ký tự tương ứng với chế độ (none, l, m,
a). Ví dụ: các thư mục cho thiết bị băng đầu tiên là (giả sử có bốn
chế độ): st0 nst0 st0l nst0l st0m nst0m st0a nst0a.

Mỗi thư mục chứa các mục: default_blksize default_compression
trình điều khiển thiết bị phát triển được xác định mật độ mặc định. Tệp 'được xác định' chứa 1
nếu chế độ được xác định và bằng 0 nếu không được xác định. Các tập tin 'default_*' chứa
mặc định do người dùng thiết lập. Giá trị -1 có nghĩa là giá trị mặc định không được đặt. các
file 'dev' chứa số thiết bị tương ứng với thiết bị này. Các liên kết
'thiết bị' và 'trình điều khiển' trỏ đến các mục nhập trình điều khiển và thiết bị SCSI.

Mỗi thư mục cũng chứa mục 'tùy chọn' hiển thị
tùy chọn trình điều khiển và chế độ được kích hoạt. Giá trị trong tệp là một mặt nạ bit trong đó
định nghĩa bit giống như định nghĩa được sử dụng với MTSETDRVBUFFER trong việc thiết lập
tùy chọn.

Mỗi thư mục chứa mục 'position_lost_in_reset'. Nếu giá trị này là
một, việc đọc và ghi vào thiết bị sẽ bị chặn sau khi thiết lập lại thiết bị. Hầu hết
thiết bị tua lại băng sau khi đặt lại và việc ghi/đọc không truy cập được
vị trí băng mà người dùng mong đợi.

Một liên kết có tên 'băng' được tạo từ thư mục thiết bị SCSI đến lớp
thư mục tương ứng với thiết bị tự động tua lại chế độ 0 (ví dụ: st0).


Hệ thống và số liệu thống kê cho thiết bị băng từ
=================================================

Trình điều khiển st duy trì số liệu thống kê cho các ổ băng từ bên trong hệ thống tập tin sysfs.
Phương pháp sau đây có thể được sử dụng để xác định số liệu thống kê
có sẵn (giả sử rằng sysfs được gắn tại/sys):

1. Sử dụng opendir(3) trên thư mục /sys/class/scsi_tape
2. Sử dụng readdir(3) để đọc nội dung thư mục
3. Sử dụng regcomp(3)/regexec(3) để khớp các mục nhập thư mục với phần mở rộng
   biểu thức chính quy "^st[0-9]+$"
4. Truy cập số liệu thống kê từ /sys/class/scsi_tape/<match>/stats
   thư mục (trong đó <match> là mục nhập thư mục từ /sys/class/scsi_tape
   khớp với biểu thức chính quy mở rộng)

Lý do sử dụng phương pháp này là vì tất cả các thiết bị ký tự
trỏ đến cùng một ổ băng sử dụng số liệu thống kê giống nhau. Điều đó có nghĩa
st0 đó sẽ có số liệu thống kê giống như nst0.

Thư mục chứa các file thống kê sau:

1. trên chuyến bay
      - Số lượng I/O hiện còn tồn tại của thiết bị này.
2. io_ns
      - Lượng thời gian chờ đợi (tính bằng nano giây) cho tất cả I/O
        để hoàn thành (bao gồm cả đọc và viết). Điều này bao gồm chuyển động của băng
        các lệnh như tìm kiếm giữa tập tin hoặc tập hợp các dấu và băng ẩn
        chuyển động chẳng hạn như khi tua lại trên các thiết bị đóng băng được sử dụng.
3. other_cnt
      - Số lượng I/O cấp cho ổ băng từ không phải là đọc hoặc
        viết lệnh. Thời gian thực hiện để hoàn thành các lệnh này sử dụng
        phép tính sau io_ms-read_ms-write_ms.
4. read_byte_cnt
      - Số byte được đọc từ ổ băng từ.
5. read_cnt
      - Số lượng yêu cầu đọc được cấp cho ổ băng từ.
6. read_ns
      - Lượng thời gian (tính bằng nano giây) dành để chờ đọc
        yêu cầu hoàn thành.
7. write_byte_cnt
      - Số byte được ghi vào ổ băng từ.
8. viết_cnt
      - Số lượng yêu cầu ghi được cấp cho ổ băng từ.
9. viết_ns
      - Lượng thời gian (tính bằng nano giây) dành để chờ ghi
        yêu cầu hoàn thành.
10. cư trú_cnt
      - Số lần trong quá trình đọc hoặc viết chúng tôi tìm thấy
	số tiền còn lại khác 0. Điều này có nghĩa là một chương trình
	đang đưa ra một giá trị đọc lớn hơn kích thước khối trên băng. Để viết
	không phải tất cả dữ liệu đều được ghi vào băng.

.. Note::

   The in_flight value is incremented when an I/O starts the I/O
   itself is not added to the statistics until it completes.

Tổng số read_cnt, write_cnt và other_cnt có thể không bằng nhau
giá trị là iodone_cnt ở cấp thiết bị. Số liệu thống kê băng chỉ tính
I/O được phát hành thông qua mô-đun st.

Khi đọc số liệu thống kê có thể không nhất quán về mặt thời gian khi I/O đang ở chế độ
tiến bộ. Tuy nhiên, các giá trị riêng lẻ được đọc và ghi vào nguyên tử
khi đọc lại chúng qua sysfs, chúng có thể đang trong quá trình
được cập nhật khi bắt đầu I/O hoặc khi nó hoàn thành.

Giá trị hiển thị trong in_flight được tăng lên trước khi có bất kỳ số liệu thống kê nào
được cập nhật và giảm đi khi I/O hoàn thành sau khi cập nhật số liệu thống kê.
Giá trị của in_flight là 0 khi không có I/O nào tồn đọng.
do người lái xe thứ nhất cấp. Thống kê băng không tính đến bất kỳ
I/O được thực hiện thông qua thiết bị sg.

BSD và Sys V Ngữ nghĩa
=======================

Người dùng có thể chọn giữa hai hành vi này của trình điều khiển băng từ bằng cách
xác định giá trị của ký hiệu ST_SYSV. Ngữ nghĩa khác nhau khi một
tập tin đang đọc đã bị đóng. Ngữ nghĩa BSD để lại băng ở nơi nó
hiện tại là trong khi ngữ nghĩa SYS V di chuyển băng qua băng tiếp theo
filemark trừ khi filemark vừa được vượt qua.

Mặc định là ngữ nghĩa BSD.


Đang đệm
=========

Trình điều khiển cố gắng thực hiện chuyển trực tiếp đến/từ không gian người dùng. Nếu điều này
không thể thực hiện được, bộ đệm trình điều khiển được phân bổ trong thời gian chạy sẽ được sử dụng. Nếu
không thể vào/ra trực tiếp cho toàn bộ quá trình truyền, bộ đệm trình điều khiển
được sử dụng (tức là bộ đệm thoát cho các trang riêng lẻ không
đã sử dụng). I/O trực tiếp có thể không thực hiện được vì một số lý do, ví dụ:

- một hoặc nhiều trang có địa chỉ mà HBA không thể truy cập được
- số lượng trang được chuyển vượt quá số lượng
  phân tán/thu thập các phân đoạn được HBA cho phép
- một hoặc nhiều trang không thể bị khóa vào bộ nhớ (không nên xảy ra trong
  bất kỳ tình huống hợp lý nào)

Kích thước của bộ đệm trình điều khiển luôn bằng ít nhất một khối băng. Trong cố định
chế độ khối, kích thước bộ đệm tối thiểu được xác định (theo đơn vị 1024 byte) bởi
ST_FIXED_BUFFER_BLOCKS. Với kích thước khối nhỏ, điều này cho phép đệm
một số khối và sử dụng một SCSI đọc hoặc ghi để truyền tất cả
khối. Việc đệm dữ liệu qua các cuộc gọi ghi ở chế độ khối cố định là
được phép nếu ST_BUFFER_WRITES khác 0 và i/o trực tiếp không được sử dụng.
Phân bổ bộ đệm sử dụng các khối bộ nhớ có kích thước 2^n * (trang
kích thước). Vì điều này kích thước bộ đệm thực tế có thể lớn hơn kích thước bộ đệm
kích thước bộ đệm tối thiểu cho phép.

NOTE rằng nếu sử dụng i/o trực tiếp, các thao tác ghi nhỏ sẽ không được lưu vào bộ đệm. Điều này có thể
gây bất ngờ khi chuyển từ 2.4. Có ghi nhỏ (ví dụ: tar không có
-b tùy chọn) có thể có thông lượng tốt nhưng điều này không còn đúng nữa với
2.6. I/o trực tiếp có thể được tắt để giải quyết vấn đề này nhưng một giải pháp tốt hơn
là sử dụng số byte write() lớn hơn (ví dụ: tar -b 64).

Viết không đồng bộ. Việc ghi nội dung bộ đệm vào băng là
bắt đầu và lệnh gọi ghi sẽ quay trở lại ngay lập tức. Trạng thái được kiểm tra
ở hoạt động băng tiếp theo. Việc ghi không đồng bộ không được thực hiện với
I/O trực tiếp và không ở chế độ khối cố định.

Ghi vào bộ đệm và ghi không đồng bộ trong một số trường hợp hiếm hoi có thể gây ra
vấn đề trong hoạt động đa khối nếu không có đủ dung lượng trên
băng sau dấu cảnh báo sớm để xóa bộ đệm trình điều khiển.

Đọc trước để biết chế độ khối cố định (ST_READ_AHEAD). Làm đầy bộ đệm là
đã thử ngay cả khi người dùng không muốn lấy tất cả dữ liệu tại
lệnh đọc này. Nên tắt đối với những ổ đĩa không thích
một filemark để cắt bớt yêu cầu đọc hoặc không thích lùi lại.

Bộ đệm phân tán/thu thập (bộ đệm bao gồm các khối không liền kề
trong bộ nhớ vật lý) được sử dụng nếu không thể sử dụng các bộ đệm liền kề
được phân bổ. Để hỗ trợ tất cả các bộ điều hợp SCSI (bao gồm cả những bộ điều hợp không
hỗ trợ phân tán/thu thập), phân bổ bộ đệm đang sử dụng như sau
ba loại khối:

1. Phân đoạn ban đầu được sử dụng cho tất cả các bộ điều hợp SCSI bao gồm
   những thứ không hỗ trợ phân tán/thu thập. Kích thước của bộ đệm này sẽ là
   (PAGE_SIZE << ST_FIRST_ORDER) byte nếu hệ thống có thể cung cấp một đoạn
   kích thước này (và nó không lớn hơn kích thước bộ đệm được chỉ định bởi
   ST_BUFFER_BLOCKS). Nếu không có kích thước này thì tài xế giảm một nửa
   kích thước và thử lại cho đến khi kích thước của một trang. Mặc định
   cài đặt trong st_options.h khiến trình điều khiển cố gắng phân bổ tất cả
   đệm dưới dạng một đoạn.
2. Các phân đoạn phân tán/thu thập để lấp đầy kích thước bộ đệm được chỉ định là
   được phân bổ sao cho càng nhiều phân đoạn càng tốt được sử dụng nhưng số lượng
   của các phân đoạn không vượt quá ST_FIRST_SG.
3. Các phân đoạn còn lại giữa ST_MAX_SG (hoặc tham số mô-đun
   max_sg_segs) và số lượng phân đoạn được sử dụng trong giai đoạn 1 và 2
   được sử dụng để mở rộng bộ đệm vào thời gian chạy nếu điều này là cần thiết. các
   số lượng phân đoạn phân tán/tập hợp được phép cho bộ điều hợp SCSI là không
   vượt quá nếu nó nhỏ hơn số lượng phân tán/tập hợp tối đa
   các phân đoạn được chỉ định. Nếu số lượng tối đa được phép cho bộ chuyển đổi SCSI
   nhỏ hơn số lượng phân đoạn được sử dụng trong giai đoạn 1 và 2,
   mở rộng bộ đệm sẽ luôn thất bại.


Hành vi EOM khi viết
==========================

Khi gặp cảnh báo sớm kết thúc trung bình, ghi hiện tại
kết thúc và số byte được trả về. Lần viết tiếp theo
trả về -1 và errno được đặt thành ENOSPC. Để cho phép viết đoạn giới thiệu,
lần ghi tiếp theo được phép tiếp tục và nếu thành công, số lượng
byte được trả về. Sau đó, -1 và số byte là
luân phiên quay trở lại cho đến khi kết thúc vật lý của phương tiện (hoặc một số phương tiện khác
gặp phải lỗi)

Thông số mô-đun
=================

Kích thước bộ đệm, ngưỡng ghi và số lượng bộ đệm được phân bổ tối đa
có thể cấu hình khi trình điều khiển được tải dưới dạng mô-đun. Các từ khóa là:

==========================================================================
buffer_kbs=xxx kích thước bộ đệm cho chế độ khối cố định được đặt
			   tới xxx kilobyte
write_threshold_kbs=xxx ngưỡng ghi tính bằng kilobyte được đặt thành xxx
max_sg_segs=xxx số lượng phân tán/thu thập tối đa
			   phân đoạn
try_direct_io=x hãy thử chuyển trực tiếp giữa bộ đệm người dùng và
			   ổ băng từ nếu giá trị này khác 0
==========================================================================

Lưu ý rằng nếu kích thước bộ đệm thay đổi nhưng ngưỡng ghi không
được đặt, ngưỡng ghi được đặt thành kích thước bộ đệm mới - 2 kB.


Cấu hình thời gian khởi động
============================

Nếu trình điều khiển được biên dịch vào kernel, các tham số tương tự có thể được
cũng được thiết lập bằng cách sử dụng, ví dụ: dòng lệnh LILO. Cú pháp ưa thích là
để sử dụng cùng một từ khóa được sử dụng khi tải dưới dạng mô-đun nhưng được thêm vào trước
với 'st.'. Ví dụ: để đặt số lượng phân tán/tập hợp tối đa
phân đoạn, nên sử dụng tham số 'st.max_sg_segs=xx' (xx là
số phân đoạn phân tán/tập hợp).

Để tương thích, cú pháp cũ từ kernel 2.5 và 2.4 đời đầu
phiên bản được hỗ trợ. Các từ khóa tương tự có thể được sử dụng như khi tải
trình điều khiển dưới dạng mô-đun. Nếu một số tham số được đặt, giá trị từ khóa
các cặp được phân tách bằng dấu phẩy (không được phép có dấu cách). Một dấu hai chấm có thể
được sử dụng thay cho dấu bằng. Định nghĩa được đặt trước bởi
chuỗi st=. Đây là một ví dụ::

st=buffer_kbs:64,write_threshold_kbs:60

Cú pháp sau đây được sử dụng bởi các phiên bản kernel cũ cũng được hỗ trợ::

st=aa[,bb[,dd]]

Ở đâu:

- aa là kích thước bộ đệm cho chế độ khối cố định tính bằng đơn vị 1024 byte
  - bb là ngưỡng ghi tính theo đơn vị 1024 byte
  - dd là số lượng phân đoạn phân tán/tập hợp tối đa


IOCTL
======

Băng được định vị và các tham số ổ đĩa được đặt bằng ioctls
được xác định trong mtio.h Chương trình điều khiển băng từ 'mt' sử dụng các ioctls này. Hãy thử
để tìm một mt hỗ trợ tất cả ioctls băng Linux SCSI và
mở thiết bị để ghi nếu nội dung băng sẽ được sửa đổi
(tìm gói mt-st* từ các trang ftp của Linux; GNU mt có
không mở để viết, ví dụ: xóa).

Các ioctls được hỗ trợ là:

Sau đây sử dụng cấu trúc mtop:

MTFSF
	Chuyển tiếp khoảng trắng qua số lượng tập tin. Băng được định vị sau filemark.
MTFSFM
	Như trên nhưng băng được đặt trước filemark.
MTBSF
	Không gian lùi về số lượng tập tin. Băng được định vị trước
        filemark.
MTBSFM
	Như trên nhưng ape được đặt sau filemark.
MTFSR
	Chuyển tiếp khoảng trắng qua số lượng bản ghi.
MTBSR
	Không gian lạc hậu trên các bản ghi đếm.
MTFSS
	Không gian chuyển tiếp trên các dấu ấn đếm.
MTBSS
	Không gian lạc hậu trên các dấu hiệu đếm.
MTWEOF
	Viết số lượng tập tin.
MTWEOFI
	Ghi các dấu tập tin đếm với tập bit ngay lập tức (nghĩa là không
	đợi cho đến khi dữ liệu được ghi vào băng)
MTWSM
	Viết số điểm đặt.
MTREW
	Tua lại băng.
MTOFFL
	Đặt thiết bị ở chế độ ngoại tuyến (thường tua lại và đẩy ra).
MTNOP
	Không làm gì ngoại trừ xóa bộ đệm.
MTRETEN
	Băng căng lại.
MTEOM
	Khoảng cách đến cuối dữ liệu được ghi.
MTERASE
	Xóa băng. Nếu đối số bằng 0, lệnh xóa ngắn
	được sử dụng. Lệnh xóa dài được sử dụng với tất cả các giá trị khác
	của lập luận.
MTSEEK
	Tìm cách đếm số khối băng. Sử dụng tìm kiếm tương thích Tandberg (QFA)
        đối với ổ SCSI-1 và SCSI-2, hãy tìm ổ SCSI-2. Tập tin và
	số khối trong trạng thái không hợp lệ sau khi tìm kiếm.
MTSETBLK
	Đặt kích thước khối ổ đĩa. Đặt về 0 sẽ đặt ổ đĩa vào
        chế độ khối biến (nếu có).
MTSETDENSITY
	Đặt mã mật độ ổ đĩa thành arg. Xem ổ đĩa
        tài liệu về các mã có sẵn.
MTLOCK và MTUNLOCK
	Khóa/mở khóa cửa ổ băng một cách rõ ràng.
MTLOAD và MTUNLOAD
	Tải và dỡ băng một cách rõ ràng. Nếu
	đối số lệnh x nằm trong khoảng MT_ST_HPLOADER_OFFSET + 1 và
	MT_ST_HPLOADER_OFFSET+6, số x được dùng để gửi tới
	lái xe bằng lệnh và nó chọn khe băng để sử dụng
	Bộ thay đổi HP C1553A.
MTCOMPRESSION
	Đặt chế độ ổ đĩa nén hoặc giải nén bằng cách sử dụng
	Chế độ SCSI trang 15. Lưu ý rằng một số ổ đĩa có các phương pháp khác dành cho
	điều khiển nén. Một số ổ đĩa (như Exabytes) sử dụng
	mã mật độ để kiểm soát nén. Một số ổ đĩa sử dụng ổ đĩa khác
	trang chế độ nhưng trang này chưa được triển khai trong
	người lái xe. Một số ổ đĩa không có khả năng nén sẽ chấp nhận
	bất kỳ chế độ nén nào không có lỗi.
MTSETPART
	Di chuyển băng tới phân vùng được đưa ra bởi đối số tại
	hoạt động băng tiếp theo. Khối nơi băng được định vị
	là khối nơi băng được định vị trước đó trong
	phân vùng hoạt động mới trừ khi thao tác băng tiếp theo được thực hiện
	MTSEEK. Trong trường hợp này băng được chuyển trực tiếp vào khối
	được chỉ định bởi MTSEEK. MTSETPART không hoạt động trừ khi
	Bộ MT_ST_CAN_PARTITIONS.
MTMKPART
	Định dạng băng với một phân vùng (đối số 0) hoặc hai
	phân vùng (đối số khác không). Nếu lập luận là tích cực,
	nó chỉ định kích thước của phân vùng 1 tính bằng megabyte. Dành cho DDS
	ổ đĩa và một số ổ đĩa đầu tiên, đây là lần đầu tiên về mặt vật lý
	phân vùng của băng. Nếu đối số là phủ định thì nó tuyệt đối
	giá trị chỉ định kích thước của phân vùng 0 tính bằng megabyte. Đây là
	phân vùng vật lý đầu tiên của nhiều ổ đĩa sau này, như
	Ổ đĩa LTO từ LTO-5 trở lên. Ổ đĩa phải hỗ trợ phân vùng
	với kích thước được chỉ định bởi người khởi tạo. Không hoạt động trừ khi
	Bộ MT_ST_CAN_PARTITIONS.
MTSETDRVBUFFER
	Được sử dụng cho một số mục đích. Lệnh được lấy từ count
        với mặt nạ MT_SET_OPTIONS, các bit thứ tự thấp được sử dụng làm đối số.
	Lệnh này chỉ được phép đối với superuser (root). các
	các lệnh phụ là:

* 0
           Tùy chọn bộ đệm ổ đĩa được đặt thành đối số. Không có nghĩa là
           không có bộ đệm.
        * MT_ST_BOOLEANS
           Đặt các tùy chọn đệm. Các bit là trạng thái mới
           (bật/tắt) các tùy chọn sau (trong
	   dấu ngoặc đơn được chỉ định cho dù tùy chọn là chung hay
	   có thể được chỉ định khác nhau cho từng chế độ):

MT_ST_BUFFER_WRITES
		ghi đệm (chế độ)
	     MT_ST_ASYNC_WRITES
		ghi không đồng bộ (chế độ)
             MT_ST_READ_AHEAD
		đọc trước (chế độ)
             MT_ST_TWO_FM
		viết hai filemark (toàn cầu)
	     MT_ST_FAST_EOM
		sử dụng khoảng cách SCSI đến EOD (toàn cầu)
	     MT_ST_AUTO_LOCK
		tự động khóa cửa ổ đĩa (toàn cầu)
             MT_ST_DEF_WRITES
		các giá trị mặc định chỉ dành cho việc ghi (chế độ)
	     MT_ST_CAN_BSR
		lùi lại trên nhiều bản ghi có thể
		được sử dụng để định vị lại băng (toàn cầu)
	     MT_ST_NO_BLKLIMS
		tài xế không hỏi giới hạn chặn
		từ ổ đĩa (kích thước khối chỉ có thể được thay đổi thành
		biến) (toàn cầu)
	     MT_ST_CAN_PARTITIONS
		cho phép hỗ trợ cho phân vùng
		băng (toàn cầu)
	     MT_ST_SCSI2LOGICAL
		số khối logic được sử dụng trong
		MTSEEK và MTIOCPOS dành cho ổ đĩa SCSI-2 thay vì
		địa chỉ phụ thuộc vào thiết bị. Nên thiết lập
		cờ này trừ khi có băng sử dụng thiết bị
		phụ thuộc (từ thời xa xưa) (toàn cầu)
	     MT_ST_SYSV
		đặt ngữ nghĩa SYSV (chế độ)
	     MT_ST_NOWAIT
		bật chế độ ngay lập tức (nghĩa là không đợi
	        lệnh kết thúc) đối với một số lệnh (ví dụ: tua lại)
	     MT_ST_NOWAIT_EOF
		bật chế độ đánh dấu tập tin ngay lập tức (tức là khi
	        viết một filemark, đừng đợi nó hoàn thành). làm ơn
		xem ghi chú BASICS về MTWEOFI liên quan đến
		những nguy hiểm có thể xảy ra khi viết các dấu tập tin ngay lập tức.
	     MT_ST_SILI
		cho phép cài đặt bit SILI trong các lệnh SCSI khi
		đọc ở chế độ khối biến đổi để nâng cao hiệu suất khi
		khối đọc ngắn hơn số byte; chỉ đặt cái này
		nếu bạn chắc chắn rằng ổ đĩa hỗ trợ SILI và HBA
		trả về chính xác số dư chuyển
	     MT_ST_DEBUGGING
		gỡ lỗi (toàn cầu; việc gỡ lỗi phải được thực hiện
		được biên dịch vào trình điều khiển)

* MT_ST_SETBOOLEANS, MT_ST_CLEARBOOLEANS
	   Đặt hoặc xóa các bit tùy chọn.
        * MT_ST_WRITE_THRESHOLD
           Đặt ngưỡng ghi cho thiết bị này thành kilobyte
           được xác định bởi các bit thấp nhất.
	* MT_ST_DEF_BLKSIZE
	   Xác định kích thước khối mặc định được đặt tự động. Giá trị
	   0xffffff có nghĩa là mặc định không được sử dụng nữa.
	* MT_ST_DEF_DENSITY, MT_ST_DEF_DRVBUFFER
	   Được sử dụng để đặt hoặc xóa mật độ (8 bit) và bộ đệm ổ đĩa
	   trạng thái (3 bit). Nếu giá trị là MT_ST_CLEAR_DEFAULT
	   (0xfffff) mặc định sẽ không được sử dụng nữa. Nếu không
	   các bit thấp nhất của giá trị chứa giá trị mới của
	   tham số.
	* MT_ST_DEF_COMPRESSION
	   Mặc định nén sẽ không được sử dụng nếu giá trị của
	   byte thấp nhất là 0xff. Nếu không thì bit thấp nhất
	   chứa mặc định mới. Nếu các bit 8-15 được đặt thành
	   số khác 0 và số này không phải là 0xff, số này là
	   được sử dụng làm thuật toán nén. giá trị
	   MT_ST_CLEAR_DEFAULT có thể được sử dụng để xóa nén
	   mặc định.
	* MT_ST_SET_TIMEOUT
	   Đặt thời gian chờ bình thường tính bằng giây cho thiết bị này. các
	   mặc định là 900 giây (15 phút). Thời gian chờ phải là
	   đủ lâu để thiết bị thực hiện lại các lần thử lại trong khi
	   đọc/viết.
	* MT_ST_SET_LONG_TIMEOUT
	   Đặt thời gian chờ dài được sử dụng cho các hoạt động
	   được biết là phải mất một thời gian dài. Mặc định là 14000 giây
	   (3,9 giờ). Để xóa giá trị này được nhân thêm với
	   tám.
	* MT_ST_SET_CLN
	   Đặt tham số diễn giải yêu cầu dọn dẹp bằng cách sử dụng
	   24 bit thấp nhất của đối số. Người lái xe có thể thiết lập
	   bit trạng thái chung GMT_CLN nếu mẫu bit yêu cầu dọn dẹp
	   được tìm thấy từ dữ liệu giác quan mở rộng. Nhiều ổ đĩa thiết lập một hoặc
	   nhiều bit hơn trong dữ liệu cảm giác mở rộng khi ổ đĩa cần
	   dọn dẹp. Các bit phụ thuộc vào thiết bị. Người lái xe là
	   cho trước số byte dữ liệu cảm giác (tám byte thấp nhất
	   bit của đối số; phải >= 18 (giá trị 1 - 17
	   dành riêng) và <= dữ liệu giác quan được yêu cầu tối đa sixe),
	   một mặt nạ để chọn các bit liên quan (các bit 9-16) và
	   mẫu bit (bit 17-23). Nếu mẫu bit bằng 0, một
	   hoặc nhiều bit dưới mặt nạ biểu thị yêu cầu làm sạch. Nếu
	   mẫu này khác 0, mẫu này phải khớp với mặt nạ
	   cảm nhận byte dữ liệu.

(Bit làm sạch được thiết lập nếu mã ý nghĩa bổ sung và
	   vòng loại 00h 17h được nhìn thấy bất kể cài đặt của
	   MT_ST_SET_CLN.)

Ioctl sau đây sử dụng cấu trúc mtpos:

MTIOCPOS
	Đọc vị trí hiện tại từ ổ đĩa. Công dụng
        QFA tương thích với Tandberg cho các ổ SCSI-1 và SCSI-2
        lệnh cho các ổ đĩa SCSI-2.

Ioctl sau đây sử dụng cấu trúc mtget để trả về trạng thái:

MTIOCGET
	Trả về một số thông tin trạng thái.
        Số tập tin và số khối trong tập tin được trả về. các
        khối là -1 khi không thể xác định được (ví dụ: sau MTBSF).
        Loại ổ đĩa là MTISSCSI1 hoặc MTISSCSI2.
        Số lỗi được khôi phục kể từ lệnh gọi trạng thái trước đó
        được lưu trữ ở từ dưới cùng của trường mt_erreg.
        Kích thước khối hiện tại và mã mật độ được lưu trữ trong trường
        mt_dsreg (sự thay đổi cho các trường con là MT_ST_BLKSIZE_SHIFT và
        MT_ST_DENSITY_SHIFT).
	Các bit trạng thái GMT_xxx phản ánh trạng thái ổ đĩa. GMT_DR_OPEN
	được đặt nếu không có băng trong ổ đĩa. GMT_EOD có nghĩa là
	cuối dữ liệu đã ghi hoặc cuối băng. GMT_EOT có nghĩa là phần cuối của băng.


Tùy chọn biên dịch khác
=============================

Các lỗi ghi được khôi phục được coi là nghiêm trọng nếu ST_RECOVERED_WRITE_FATAL
được xác định.

Số lượng thiết bị băng tối đa được xác định bởi định nghĩa
ST_MAX_TAPES. Nếu phát hiện thêm băng khi khởi tạo trình điều khiển,
tối đa được điều chỉnh cho phù hợp.

Có thể bật tính năng quay lại ngay lập tức từ vị trí băng lệnh SCSI bằng cách
xác định ST_NOWAIT. Nếu điều này được xác định, người dùng nên lưu ý rằng
thao tác băng tiếp theo không được bắt đầu trước khi thao tác băng trước đó được thực hiện
đã xong. Các ổ đĩa và bộ điều hợp SCSI sẽ xử lý tình trạng này
một cách duyên dáng, nhưng một số kết hợp ổ đĩa/bộ chuyển đổi được biết là có thể treo
Xe buýt SCSI trong trường hợp này.

Lệnh MTEOM theo mặc định được triển khai dưới dạng khoảng cách trên 32767
filemarks. Với phương pháp này, số tập tin ở trạng thái là
đúng. Người dùng có thể yêu cầu sử dụng khoảng cách trực tiếp tới EOD bằng cách cài đặt
ST_FAST_EOM 1 (hoặc sử dụng MT_ST_OPTIONS ioctl). Trong trường hợp này tập tin
số sẽ không hợp lệ.

Khi sử dụng tính năng đọc trước hoặc đệm, hãy ghi vị trí trong tệp
có thể không chính xác sau khi đóng tệp (vị trí đúng có thể
yêu cầu lùi lại trên nhiều bản ghi). Vị trí đúng
trong tệp có thể thu được nếu ST_IN_FILE_POS được xác định khi biên dịch
thời gian hoặc bit MT_ST_CAN_BSR được đặt cho ổ đĩa bằng ioctl.
(Trình điều khiển luôn sao lưu dấu tập tin bị vượt qua bằng cách đọc trước nếu
người dùng không yêu cầu dữ liệu đến mức đó.)


Gợi ý gỡ lỗi
===============

Mã gỡ lỗi hiện được biên dịch theo mặc định nhưng tính năng gỡ lỗi bị tắt
với tham số mô-đun hạt nhân debug_flag mặc định là 0. Gỡ lỗi
vẫn có thể bật và tắt bằng ioctl.  Để bật gỡ lỗi tại
thời gian tải mô-đun thêm debug_flag=1 vào các tùy chọn tải mô-đun,
đầu ra gỡ lỗi không nhiều. Gỡ lỗi cũng có thể được kích hoạt
và bị vô hiệu hóa bằng cách viết '0' (tắt) hoặc '1' (bật) vào sysfs
tập tin /sys/bus/scsi/drivers/st/debug_flag.

Nếu cuộn băng dường như bị treo, tôi sẽ rất muốn biết xem nó ở đâu
người lái xe đang đợi. Với lệnh 'ps -l' bạn có thể thấy trạng thái
của quá trình sử dụng băng. Nếu trạng thái là D thì quá trình là
đang chờ đợi một điều gì đó. Trường WCHAN cho biết trình điều khiển đang ở đâu
đang chờ đợi. Nếu bạn có System.map hiện tại ở đúng vị trí (trong
/boot cho các Procp tôi sử dụng) hoặc đã cập nhật /etc/psdatabase (cho kmem
ps), ps ghi tên hàm vào trường WCHAN. Nếu không, bạn có
để tra cứu hàm từ System.map.

Cũng lưu ý rằng thời gian chờ rất dài so với hầu hết các
trình điều khiển. Điều này có nghĩa là trình điều khiển Linux có thể bị treo mặc dù
lý do thực sự là phần sụn của băng bị nhầm lẫn.