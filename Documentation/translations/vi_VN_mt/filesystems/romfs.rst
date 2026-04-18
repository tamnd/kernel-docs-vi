.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/romfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
ROMFS - Hệ thống tệp ROM
==========================

Đây là một hệ thống tập tin chỉ đọc, khá ngớ ngẩn, chủ yếu dành cho RAM ban đầu
đĩa của đĩa cài đặt.  Nó đã lớn lên bởi nhu cầu có
các mô-đun được liên kết lúc khởi động.  Sử dụng hệ thống tập tin này, bạn sẽ có được rất nhiều
tính năng tương tự, và thậm chí cả khả năng của một hạt nhân nhỏ, với một
hệ thống tập tin không chiếm bộ nhớ hữu ích từ bộ định tuyến
hoạt động ở tầng hầm văn phòng của bạn.

Để so sánh, cả minix và xiafs cũ hơn (sau này là
hệ thống tập tin không còn tồn tại), được biên dịch dưới dạng mô-đun cần hơn 20000 byte,
trong khi romfs nhỏ hơn một trang, khoảng 4000 byte (giả sử i586
mã).  Trong cùng điều kiện, hệ thống tập tin msdos sẽ cần
khoảng 30K (và không hỗ trợ các nút thiết bị hoặc liên kết tượng trưng), trong khi
mô-đun nfs với nfsroot là khoảng 57K.  Hơn nữa, có chút không công bằng
so sánh, một đĩa cứu hộ thực tế đã sử dụng hết 3202 khối với ext2, trong khi
với romfs, nó cần 3079 khối.

Để tạo một hệ thống tập tin như vậy, bạn sẽ cần một chương trình người dùng có tên
genromfs. Nó có sẵn trên ZZ0000ZZ

Như tên cho thấy, romfs cũng có thể được sử dụng (tiết kiệm không gian) trên
các phương tiện chỉ đọc khác nhau, như đĩa (E)EPROM nếu ai đó có
động lực.. :)

Tuy nhiên, mục đích chính của romfs là có một kernel rất nhỏ,
chỉ có hệ thống tập tin này được liên kết và sau đó có thể tải bất kỳ mô-đun nào
sau này, với các tiện ích mô-đun hiện tại.  Nó cũng có thể được sử dụng để chạy
một số chương trình để quyết định xem bạn có cần thiết bị SCSI hay không, và thậm chí cả IDE hoặc
ổ đĩa mềm có thể được tải sau nếu bạn sử dụng lệnh "initrd"--initial
Đĩa RAM--tính năng của kernel.  Đây thực sự không phải là tin tức
flash, nhưng với romfs, bạn thậm chí có thể bỏ qua ext2 hoặc minix hoặc
thậm chí có thể ảnh hưởng đến hệ thống tập tin cho đến khi bạn thực sự biết rằng mình cần nó.

Ví dụ: đĩa khởi động phân phối chỉ có thể chứa đĩa cd
trình điều khiển (và có thể cả trình điều khiển SCSI) và hệ thống tệp ISO 9660
mô-đun.  Hạt nhân có thể đủ nhỏ vì nó không có phần khác
các hệ thống tập tin, như mô-đun ext2fs khá lớn, sau đó có thể
đã tải đĩa CD ở giai đoạn sau của quá trình cài đặt.  Công dụng khác
sẽ dành cho đĩa khôi phục khi bạn cài đặt lại máy trạm
từ mạng và bạn sẽ có sẵn tất cả các công cụ/mô-đun
từ một máy chủ gần đó, vì vậy bạn không muốn mang theo hai đĩa cho việc này
mục đích, chỉ vì nó không phù hợp với ext2.

romfs hoạt động trên các thiết bị khối như bạn mong đợi và cơ sở
cấu trúc rất đơn giản.  Mọi cấu trúc có thể truy cập đều bắt đầu vào ngày 16
ranh giới byte để truy cập nhanh.  Dung lượng tối thiểu mà một tập tin sẽ chiếm
là 32 byte (đây là một tệp trống, có ít hơn 16 ký tự
tên).  Chi phí tối đa cho bất kỳ tệp không trống nào là tiêu đề và
phần đệm 16 byte cho tên và nội dung, cũng 16+14+15 = 45
byte.  Tuy nhiên, điều này khá hiếm vì hầu hết các tên tệp đều dài hơn.
hơn 3 byte và ngắn hơn 15 byte.

Bố cục của hệ thống tập tin như sau::

nội dung bù đắp

+---+---+---+---+
  0 ZZ0000ZZ r ZZ0001ZZ m |  \
	+---+---+---+---+ Biểu diễn ASCII của các byte đó
  4 ZZ0002ZZ f ZZ0003ZZ - |  / (tức là "-rom1fs-")
	+---+---+---+---+
  8 ZZ0004ZZ Số byte có thể truy cập được trong fs này.
	+---+---+---+---+
 12 ZZ0005ZZ Tổng kiểm tra của FIRST 512 BYTES.
	+---+---+---+---+
 16 ZZ0006ZZ Tên kết thúc bằng 0 của ổ đĩa,
	: : được đệm đến ranh giới 16 byte.
	+---+---+---+---+
 xx ZZ0007ZZ
	: tiêu đề :

Mỗi giá trị nhiều byte (từ 32 bit, tôi sẽ sử dụng thuật ngữ từ dài từ
bây giờ trở đi) phải theo thứ tự big endian.

Tám byte đầu tiên xác định hệ thống tập tin, ngay cả đối với thông thường
thanh tra.  Sau đó, từ dài thứ 3 chứa số
byte có thể truy cập được từ đầu hệ thống tập tin này.  Từ dài thứ 4
là tổng kiểm tra của 512 byte đầu tiên (hoặc số byte
có thể truy cập được, tùy theo giá trị nào nhỏ hơn).  Thuật toán áp dụng giống nhau
như trong hệ thống tập tin AFFS, cụ thể là một tổng đơn giản của các từ dài
(giả sử số lượng bigendian một lần nữa).  Để biết chi tiết, xin vui lòng tham khảo ý kiến
nguồn.  Thuật toán này được chọn vì mặc dù nó không hoàn toàn
đáng tin cậy, nó không yêu cầu bất kỳ bảng nào và rất đơn giản.

Các byte sau hiện là một phần của hệ thống tệp; mỗi tiêu đề tập tin
phải bắt đầu ở ranh giới 16 byte::

nội dung bù đắp

+---+---+---+---+
  0 ZZ0000ZZX|	Phần bù của tiêu đề tệp tiếp theo
	+---+---+---+---+ (không nếu không còn tập tin nào nữa)
  4 ZZ0001ZZ Thông tin về thư mục/liên kết cứng/thiết bị
	+---+---+---+---+
  8 ZZ0002ZZ Kích thước của tệp này tính bằng byte
	+---+---+---+---+
 12 ZZ0003ZZ Bao gồm dữ liệu meta, bao gồm cả tệp
	+---+---+---+---+ tên và phần đệm
 16 ZZ0004ZZ Tên kết thúc bằng 0 của tệp,
	: : được đệm đến ranh giới 16 byte
	+---+---+---+---+
 xx ZZ0005ZZ
	: :

Vì các tiêu đề tệp luôn bắt đầu ở ranh giới 16 byte, mức thấp nhất
4 bit sẽ luôn bằng 0 trong con trỏ filehdr tiếp theo.  Bốn người này
bit được sử dụng cho thông tin chế độ.  Bit 0..2 chỉ định loại
tập tin; trong khi bit 4 hiển thị liệu tệp có thể thực thi được hay không.  các
các quyền được coi là có thể đọc được trên thế giới, nếu bit này không được đặt,
và có thể thực thi được trên thế giới nếu có; ngoại trừ các thiết bị ký tự và khối,
chúng không bao giờ có thể được truy cập bởi những người khác ngoài chủ sở hữu.  Chủ nhân của mọi
tập tin là người dùng và nhóm 0, điều này sẽ không bao giờ là vấn đề đối với
mục đích sử dụng.  Việc ánh xạ 8 giá trị có thể có vào các loại tệp là
sau đây:

=================================================================
	  ánh xạ spec.info có nghĩa là
=================================================================
 0 đích liên kết cứng [tiêu đề tệp]
 1 thư mục tiêu đề của tập tin đầu tiên
 2 tệp thông thường không được sử dụng, phải bằng 0 [MBZ]
 3 liên kết tượng trưng không được sử dụng, MBZ (dữ liệu tệp là nội dung liên kết)
 Thiết bị 4 khối 16/16 bit số chính/phụ
 Thiết bị 5 char - " -
 6 ổ cắm chưa sử dụng, MBZ
 7 fifo chưa sử dụng, MBZ
=================================================================

Lưu ý rằng các liên kết cứng được đánh dấu cụ thể trong hệ thống tập tin này, nhưng
chúng sẽ hoạt động như bạn mong đợi (tức là chia sẻ số inode).
Cũng lưu ý rằng bạn có trách nhiệm không tạo liên kết cứng
các vòng lặp và tạo tất cả các tệp . và .. liên kết đến các thư mục.  Đây là
thường được chương trình genromfs thực hiện chính xác.  Xin vui lòng kiềm chế
sử dụng các bit thực thi cho các mục đích đặc biệt trên socket và fifo
các tệp đặc biệt, chúng có thể có những mục đích sử dụng khác trong tương lai.  Ngoài ra,
hãy nhớ rằng chỉ những tập tin thông thường và các liên kết tượng trưng mới được phép
có trường kích thước khác 0; chúng chứa số byte có sẵn
ngay sau tên tệp (đệm).

Một điều cần lưu ý nữa là romfs hoạt động trên tiêu đề và dữ liệu của tệp.
được căn chỉnh theo ranh giới 16 byte, nhưng hầu hết các thiết bị phần cứng và khối
trình điều khiển thiết bị không thể xử lý dữ liệu nhỏ hơn kích thước khối.
Để khắc phục hạn chế này, toàn bộ kích thước của hệ thống tập tin phải
được đệm đến ranh giới 1024 byte.

Nếu bạn có bất kỳ vấn đề hoặc đề xuất nào liên quan đến hệ thống tập tin này,
xin vui lòng liên hệ với tôi.  Tuy nhiên, hãy suy nghĩ kỹ trước khi muốn tôi thêm
các tính năng và mã, bởi vì lợi thế chính và quan trọng nhất của
hệ thống tập tin này là mã nhỏ.  Mặt khác, đừng
hoảng hốt, tôi không nhận được nhiều thư liên quan đến romfs.  Bây giờ tôi có thể
hiểu lý do tại sao Avery viết thơ trong tài liệu ARCnet để biết thêm
phản hồi. :)

romfs cũng có một danh sách gửi thư và cho đến nay nó vẫn chưa nhận được bất kỳ thư nào.
giao thông, vì vậy bạn có thể tham gia để thảo luận về ý tưởng của mình. :)

Nó được điều hành bởi ezmlm, vì vậy bạn có thể đăng ký nó bằng cách gửi tin nhắn
tới romfs-subscribe@shadow.banki.hu, nội dung không liên quan.

Các vấn đề đang chờ xử lý:

- Quyền và thông tin chủ sở hữu là những tính năng khá cần thiết của một
  Un*x giống như hệ thống, nhưng romfs không cung cấp đầy đủ các khả năng.
  Tôi chưa bao giờ thấy hạn chế này, nhưng những người khác thì có thể.

- Hệ thống tập tin ở chế độ chỉ đọc nên có thể rất nhỏ, nhưng trong trường hợp
  người ta muốn ghi _bất cứ thứ gì_ vào một hệ thống tập tin, anh ta vẫn cần
  một hệ thống tập tin có thể ghi, do đó phủ nhận lợi thế về kích thước.  Có thể
  giải pháp: triển khai quyền truy cập ghi dưới dạng tùy chọn thời gian biên dịch hoặc một tùy chọn mới,
  hệ thống tập tin có thể ghi nhỏ tương tự cho các đĩa RAM.

- Vì các tệp chỉ được yêu cầu căn chỉnh trên 16 byte
  ranh giới, hiện tại có thể chưa tối ưu để đọc hoặc thực thi các tệp
  từ hệ thống tập tin.  Nó có thể được giải quyết bằng cách sắp xếp lại dữ liệu tệp thành
  có hầu hết nội dung đó (tức là ngoại trừ phần đầu và phần cuối) nằm ở mức "tự nhiên"
  ranh giới, do đó có thể lập bản đồ trực tiếp một phần lớn
  nội dung tập tin vào hệ thống con mm.

- Nén có thể là một tính năng hữu ích, nhưng bộ nhớ lại là một tính năng khá khó khăn.
  yếu tố hạn chế trong mắt tôi.

- Nó được sử dụng ở đâu?

- Nó có hoạt động trên các kiến ​​trúc khác ngoài Intel và Motorola không?


Chúc vui vẻ,

Janos Farkas <chexum@shadow.banki.hu>