.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/tty/moxa-smartio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================================
Hướng dẫn cài đặt trình điều khiển thiết bị gia đình MOXA Smartio/Industio
==========================================================================

Bản quyền (C) 2008, Moxa Inc.
Bản quyền (C) 2021, Jiri Slaby

.. Content

   1. Introduction
   2. System Requirement
   3. Installation
      3.1 Hardware installation
      3.2 Device naming convention
   4. Utilities
   5. Setserial
   6. Troubleshooting

1. Giới thiệu
^^^^^^^^^^^^^^^

Trình điều khiển Linux dòng Smartio/Industio/UPCI hỗ trợ nhiều cổng sau
   bảng:

- Bảng đa cổng 2 cổng
	CP-102U, CP-102UL, CP-102UF
	CP-132U-I, CP-132UL,
	CP-132, CP-132I, CP132S, CP-132IS,
	(CP-102, CP-102S)

- Bảng đa cổng 4 cổng
	CP-104EL,
	CP-104UL, CP-104JU,
	CP-134U, CP-134U-I,
	C104H/PCI, C104HS/PCI,
	CP-114, CP-114I, CP-114S, CP-114IS, CP-114UL,
	(C114HI, CT-114I),
	POS-104UL,
	CB-114,
	CB-134I

- Bảng đa cổng 8 cổng
	CP-118EL, CP-168EL,
	CP-118U, CP-168U,
	C168H/PCI,
	CB-108

Nếu xảy ra sự cố tương thích, vui lòng liên hệ với Moxa theo số
   support@moxa.com.tw.

Ngoài driver thiết bị, các tiện ích hữu ích cũng được cung cấp trong này
   phiên bản. Họ là:

- msdiag
		 Chương trình chẩn đoán hiển thị Moxa đã cài đặt
                 Bảng Smartio/Công nghiệp.
    - msmon
		 Chương trình giám sát để quan sát số lượng dữ liệu và tín hiệu trạng thái đường truyền.
    - msterm Một chương trình đầu cuối đơn giản hữu ích trong việc kiểm tra nối tiếp
	         cổng.

Tất cả các trình điều khiển và tiện ích được xuất bản dưới dạng mã nguồn theo
   Giấy phép Công cộng GNU trong phiên bản này. Vui lòng tham khảo GNU chung
   Thông báo Giấy phép Công cộng trong từng tệp mã nguồn để biết thêm chi tiết.

Trong các trang Web của Moxa, bạn luôn có thể tìm thấy trình điều khiển mới nhất tại
   ZZ0000ZZ

Phiên bản trình điều khiển này có thể được cài đặt dưới dạng Mô-đun có thể tải (Trình điều khiển mô-đun)
   hoặc tích hợp sẵn trong kernel (Trình điều khiển tĩnh). Trước khi cài đặt trình điều khiển,
   vui lòng tham khảo quy trình cài đặt phần cứng trong Hướng dẫn sử dụng.

Chúng tôi cho rằng người dùng nên làm quen với các tài liệu sau:

- Serial-HOWTO
   - Hạt nhân-HOWTO

2. Yêu cầu hệ thống
^^^^^^^^^^^^^^^^^^^^^

- Có thể lắp tối đa 4 bảng kết hợp

3. Cài đặt
^^^^^^^^^^^^^^^

3.1 Cài đặt phần cứng
=========================

Bảng PCI/UPCI
--------------

Bạn có thể cần điều chỉnh việc sử dụng IRQ trong BIOS để tránh xung đột IRQ với các thiết bị khác.
   Thiết bị ISA. Vui lòng tham khảo quy trình cài đặt phần cứng trong phần Người dùng
   Hướng dẫn sử dụng trước.

Chia sẻ PCI IRQ
---------------

Mỗi cổng trong cùng một bảng đa cổng có chung IRQ. Lên đến
   Có thể lắp đặt 4 bo mạch đa cổng dòng Moxa Smartio/Industio PCI
   cùng nhau trên một hệ thống và họ có thể chia sẻ cùng một IRQ.



3.2 Quy ước đặt tên thiết bị
============================

Nút thiết bị có tên là "ttyMxx".

Đặt tên thiết bị khi cài đặt nhiều hơn 2 bảng
-----------------------------------------------

Quy ước đặt tên cho mỗi bo mạch đa cổng Smartio/Industio là
   được xác định trước như dưới đây.

============================
   Số bảng	Nút thiết bị
   Bảng 1 ttyM0 - ttyM7
   Bảng thứ 2 ttyM8 - ttyM15
   Bảng thứ 3 ttyM16 - ttyM23
   Bảng thứ 4 ttyM24 - ttyM31
   ============================

4. Tiện ích
^^^^^^^^^^^^

Có 3 tiện ích chứa trong trình điều khiển này. Đó là msdiag, msmon và
   msterm. 3 tiện ích này được phát hành dưới dạng mã nguồn. Họ nên
   được biên dịch thành tập tin thực thi và sao chép vào /usr/bin.

msdiag - Chẩn đoán
===================

Tiện ích này cung cấp chức năng hiển thị những gì Moxa Smartio/Industio
   bo mạch đã được tìm thấy bởi trình điều khiển trong hệ thống.

msmon - Giám sát cổng
=======================

Tiện ích này cung cấp cho người dùng cái nhìn nhanh về tất cả các cổng MOXA'
   các hoạt động. Người ta có thể dễ dàng tìm hiểu tổng số nhận/truyền của mỗi cổng
   (Rx/Tx) số ký tự kể từ thời điểm bắt đầu giám sát.

Thông lượng Rx/Tx mỗi giây cũng được báo cáo theo khoảng thời gian (ví dụ:
   5 giây cuối cùng) và ở mức trung bình (kể từ thời điểm giám sát
   được bắt đầu). Bạn có thể đặt lại số lượng cổng bằng phím <HOME>. <+> <->
   Phím (cộng/trừ) để thay đổi khoảng thời gian hiển thị. Nhấn <ENTER>
   trên cổng, con trỏ đó ở lại, để xem thông tin liên lạc của cổng
   thông số, trạng thái tín hiệu và hàng đợi đầu vào/đầu ra.

msterm - Mô phỏng thiết bị đầu cuối
===========================

Tiện ích này cung cấp khả năng gửi và nhận dữ liệu của tất cả các cổng tty,
   đặc biệt là đối với các cổng MOXA. Nó khá hữu ích để thử nghiệm đơn giản
   ứng dụng, ví dụ như gửi lệnh AT đến modem được kết nối với
   cổng hoặc được sử dụng làm thiết bị đầu cuối cho mục đích đăng nhập. Lưu ý rằng đây chỉ là một
   mô phỏng thiết bị đầu cuối câm mà không xử lý thao tác toàn màn hình.

5. Bộ nối tiếp
^^^^^^^^^^^^

Các tham số Setserial được hỗ trợ được liệt kê như bên dưới.

==================================================================================
   uart đặt loại UART (16450 --> tắt FIFO, 16550A --> bật FIFO)
   close_delay đặt lượng thời gian (tính bằng 1/100 giây) mà DTR
		  nên được giữ ở mức thấp trong khi đóng cửa.
   việc đóng_wait đặt lượng thời gian (tính bằng 1/100 giây) mà
		  cổng nối tiếp sẽ đợi dữ liệu được rút hết trong khi
		  được đóng lại trước khi máy thu bị vô hiệu hóa.
   spd_hi Sử dụng 57,6kb khi ứng dụng yêu cầu 38,4kb.
   spd_vhi Sử dụng 115,2kb khi ứng dụng yêu cầu 38,4kb.
   spd_shi Sử dụng 230,4kb khi ứng dụng yêu cầu 38,4kb.
   spd_warp Sử dụng 460,8kb khi ứng dụng yêu cầu 38,4kb.
   spd_normal Sử dụng 38,4kb khi ứng dụng yêu cầu 38,4kb.
   spd_cust Sử dụng ước số tùy chỉnh để đặt tốc độ khi
		  yêu cầu ứng dụng 38,4kb.
   số chia Tùy chọn này đặt phép chia tùy chỉnh.
   baud_base Tùy chọn này đặt tốc độ truyền cơ sở.
   ==================================================================================

6. Khắc phục sự cố
^^^^^^^^^^^^^^^^^^

Các thông báo lỗi thời gian khởi động và cách giải quyết được nêu rõ ràng như
   có thể. Nếu tất cả các giải pháp có thể đều không thành công, vui lòng liên hệ với bộ phận kỹ thuật của chúng tôi
   nhóm hỗ trợ để nhận được nhiều sự giúp đỡ hơn.


Thông báo lỗi:
	      Đã tìm thấy hơn 4 bảng gia đình Moxa Smartio/Industio. Bảng thứ năm
              và sau đó được bỏ qua.

Giải pháp:
   Để tránh vấn đề này, vui lòng rút phích cắm thứ năm và sau bo mạch, vì Moxa
   trình điều khiển hỗ trợ lên đến 4 bảng.
