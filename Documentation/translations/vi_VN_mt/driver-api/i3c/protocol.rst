.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/i3c/protocol.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Giao thức I3C
=============

Tuyên bố miễn trừ trách nhiệm
==========

Chương này sẽ tập trung vào các khía cạnh quan trọng đối với các nhà phát triển phần mềm. cho
mọi thứ liên quan đến phần cứng (như cách mọi thứ được truyền trên xe buýt, cách
tránh va chạm, ...) vui lòng xem thông số kỹ thuật của I3C.

Tài liệu này chỉ là phần giới thiệu ngắn gọn về giao thức I3C và các khái niệm
nó mang đến bàn. Nếu bạn cần thêm thông tin, vui lòng tham khảo MIPI
Thông số kỹ thuật I3C (có thể tải xuống tại đây
ZZ0000ZZ

Giới thiệu
============

I3C (phát âm là 'eye-ba-see') là giao thức tiêu chuẩn hóa MIPI được thiết kế
để khắc phục các hạn chế của I2C (tốc độ hạn chế, tín hiệu bên ngoài cần thiết cho
ngắt, không tự động phát hiện các thiết bị kết nối với bus, ...)
trong khi vẫn tiết kiệm điện.

Xe buýt I3C
=======

Một bus I3C được tạo thành từ một số thiết bị I3C và có thể một số thiết bị I2C như
tốt, nhưng bây giờ hãy tập trung vào các thiết bị I3C.

Thiết bị I3C trên bus I3C có thể có một trong các vai trò sau:

* Master: thiết bị đang điều khiển xe buýt. Đó là người chịu trách nhiệm khởi xướng
  giao dịch hoặc quyết định ai được phép nói chuyện trên xe buýt (nô lệ tạo ra
  các sự kiện có thể xảy ra trong I3C, xem bên dưới).
* Slave: thiết bị hoạt động như một thiết bị phụ và không thể gửi khung hình cho thiết bị khác
  nô lệ trên xe buýt. Thiết bị vẫn có thể gửi sự kiện tới máy chủ trên
  sáng kiến riêng của nó nếu chủ nhân cho phép.

I3C là giao thức đa chủ, do đó có thể có một số chủ trên một xe buýt,
mặc dù chỉ có một thiết bị có thể hoạt động như một thiết bị chủ tại một thời điểm nhất định. Để đạt được
sở hữu xe buýt, người chủ phải tuân theo một thủ tục cụ thể.

Mỗi thiết bị trên bus I3C phải được gán một địa chỉ động để có thể
giao tiếp. Cho đến khi việc này được thực hiện, thiết bị sẽ chỉ đáp ứng với một giới hạn
tập lệnh. Nếu nó có địa chỉ tĩnh (còn gọi là địa chỉ I2C kế thừa),
thiết bị có thể phản hồi việc chuyển I2C.

Ngoài các địa chỉ trên mỗi thiết bị này, giao thức còn xác định địa chỉ quảng bá
address để đánh địa chỉ tất cả các thiết bị trên bus.

Khi địa chỉ động đã được gán cho thiết bị, địa chỉ này sẽ được sử dụng
cho bất kỳ giao tiếp trực tiếp nào với thiết bị. Lưu ý rằng ngay cả sau khi
được chỉ định một địa chỉ động, thiết bị vẫn phải xử lý các tin nhắn quảng bá.

I3C Khám phá thiết bị
====================

Giao thức I3C xác định cơ chế tự động phát hiện các thiết bị hiện diện
trên xe buýt, khả năng và chức năng mà chúng cung cấp. Trong này
coi I3C gần với một chiếc xe buýt có thể khám phá như USB hơn là I2C hoặc SPI.

Cơ chế khám phá được gọi là DAA (Gán địa chỉ động), bởi vì nó
không chỉ phát hiện các thiết bị mà còn gán cho chúng một địa chỉ động.

Trong DAA, mỗi thiết bị I3C báo cáo 3 điều quan trọng:

* BCR: Đăng ký đặc tính xe buýt. Thanh ghi 8 bit này mô tả bus thiết bị
  khả năng liên quan
* DCR: Đăng ký đặc tính thiết bị. Thanh ghi 8 bit này mô tả
  chức năng do thiết bị cung cấp
* ID được cung cấp: Mã định danh duy nhất 48 bit. Trên một chiếc xe buýt nhất định không nên có
  Xung đột ID được cung cấp, nếu không cơ chế khám phá có thể không thành công.

Sự kiện nô lệ I3C
================

Giao thức I3C cho phép các nô lệ tự tạo các sự kiện và do đó cho phép
họ tạm thời kiểm soát xe buýt.

Cơ chế này được gọi là IBI dành cho Ngắt trong băng tần và như đã nêu trong tên,
nó cho phép các thiết bị tạo ra các ngắt mà không cần tín hiệu bên ngoài.

Trong DAA, mỗi thiết bị trên bus đã được gán một địa chỉ và địa chỉ này
địa chỉ sẽ đóng vai trò là mã định danh ưu tiên để xác định ai thắng nếu 2 địa chỉ khác nhau
các thiết bị đang tạo ra một ngắt tại cùng một thời điểm trên xe buýt (giá trị càng thấp
địa chỉ động có mức độ ưu tiên càng cao).

Các bậc thầy được phép ngăn chặn các ngắt nếu họ muốn. Sự ức chế này
yêu cầu có thể được phát sóng (áp dụng cho tất cả các thiết bị) hoặc gửi đến một thiết bị cụ thể
thiết bị.

I3C Tham gia nóng
============

Cơ chế Hot-Join tương tự như hotplug USB. Cơ chế này cho phép
nô lệ tham gia vào xe buýt sau khi nó được chủ khởi tạo.

Điều này bao gồm các trường hợp sử dụng sau:

* thiết bị không được cấp nguồn khi xe buýt được thăm dò
* thiết bị được cắm nóng trên xe buýt thông qua bảng mở rộng

Cơ chế này dựa vào các sự kiện nô lệ để thông báo cho chủ nhân rằng một
thiết bị đã tham gia vào bus và đang chờ địa chỉ động.

Sau đó, chủ có thể tự do giải quyết yêu cầu theo ý muốn: bỏ qua nó hoặc
gán một địa chỉ động cho nô lệ.

Các loại chuyển I3C
==================

Nếu bạn bỏ qua SMBus (đây chỉ là một tiêu chuẩn hóa về cách truy cập các thanh ghi
được hiển thị bởi các thiết bị I2C), I2C chỉ có một kiểu truyền.

I3C xác định 3 loại chuyển khoản khác nhau ngoài chuyển khoản I2C.
ở đây để có khả năng tương thích ngược với các thiết bị I2C.

Các lệnh I3C CCC
----------------

Các lệnh CCC (Mã lệnh chung) được sử dụng cho mọi mục đích
liên quan đến quản lý xe buýt và tất cả các tính năng chung cho một bộ thiết bị.

Các lệnh CCC chứa ID CCC 8 bit mô tả lệnh được thực thi.
MSB của ID này chỉ định xem đây là lệnh phát sóng (bit7 = 0) hay lệnh
unicast một (bit7 = 1).

ID lệnh có thể được theo sau bởi một tải trọng. Tùy thuộc vào lệnh, điều này
tải trọng được gửi bởi chủ gửi lệnh (viết lệnh CCC),
hoặc được gửi bởi nô lệ nhận lệnh (đọc lệnh CCC). Tất nhiên là đọc
truy cập chỉ áp dụng cho các lệnh unicast.
Lưu ý rằng, khi gửi lệnh CCC tới một thiết bị cụ thể, địa chỉ thiết bị
được truyền vào byte đầu tiên của tải trọng.

Độ dài tải trọng không được truyền rõ ràng trên xe buýt và phải được trích xuất
từ ID CCC.

Lưu ý rằng các nhà cung cấp có thể sử dụng một loạt ID CCC dành riêng cho các lệnh của riêng họ
(0x61-0x7f và 0xe0-0xef).

I3C Chuyển khoản SDR riêng tư
-------------------------

Nên sử dụng chuyển khoản SDR (Tốc độ dữ liệu đơn) riêng tư cho bất kỳ mục đích nào
thiết bị cụ thể và không yêu cầu tốc độ truyền cao.

Nó tương đương với chuyển khoản I2C nhưng trong thế giới I3C. Mỗi lần chuyển giao là
đã chuyển địa chỉ thiết bị (địa chỉ động được chỉ định trong DAA), tải trọng
và một hướng đi.

Sự khác biệt duy nhất với I2C là tốc độ truyền nhanh hơn nhiều (đồng hồ thông thường
tần số là 12,5 MHz).

Các lệnh I3C HDR
----------------

Các lệnh HDR nên được sử dụng cho mọi thứ dành riêng cho thiết bị và yêu cầu
tốc độ truyền cao.

Điều đầu tiên gắn liền với lệnh HDR là chế độ HDR. Hiện tại có
3 chế độ khác nhau được xác định bởi thông số kỹ thuật I3C (tham khảo thông số kỹ thuật
để biết thêm chi tiết):

* HDR-DDR: Chế độ Tốc độ dữ liệu kép
* HDR-TSP: Biểu tượng bậc ba thuần túy. Chỉ sử dụng được trên xe buýt không có thiết bị I2C
* HDR-TSL: Di sản biểu tượng bậc ba. Có thể sử dụng trên xe buýt có thiết bị I2C

Khi gửi lệnh HDR, toàn bộ bus phải vào chế độ HDR, việc này được thực hiện
sử dụng lệnh phát sóng CCC.
Khi bus đã vào chế độ HDR cụ thể, master sẽ gửi lệnh HDR.
Lệnh HDR được tạo từ:

* một từ lệnh 16 bit ở dạng endian lớn
* N từ dữ liệu 16 bit ở dạng big endian

Những từ đó có thể được bao bọc bằng các phần mở đầu/hậu trường cụ thể tùy thuộc vào
chế độ HDR đã chọn và được trình bày chi tiết tại đây (xem thông số kỹ thuật để biết thêm
chi tiết).

Từ lệnh 16 bit được tạo thành từ:

* bit[15]: bit định hướng, đọc là 1, ghi là 0
* bit[14:8]: mã lệnh. Xác định lệnh đang được thực thi, số lượng
  từ dữ liệu và ý nghĩa của chúng
* bit[7:1]: Địa chỉ I3C của thiết bị mà lệnh này được gửi tới
* bit[0]: bit dành riêng/bit chẵn lẻ

Khả năng tương thích ngược với các thiết bị I2C
=======================================

Giao thức I3C được thiết kế để tương thích ngược với các thiết bị I2C.
Khả năng tương thích ngược này cho phép một người kết nối hỗn hợp các thiết bị I2C và I3C
Tuy nhiên, trên cùng một bus, để thực sự hiệu quả, các thiết bị I2C nên
được trang bị bộ lọc tăng đột biến 50 ns.

Không thể phát hiện các thiết bị I2C như các thiết bị I3C và phải ở trạng thái tĩnh
tuyên bố. Để cho chủ nhân biết những thiết bị này có khả năng gì
(cả về các hạn chế và chức năng liên quan đến bus), phần mềm
phải cung cấp một số thông tin được thực hiện thông qua LVR (Legacy I2C
Đăng ký ảo).