.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/pcwd-watchdog.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Sản phẩm Berkshire Thẻ Watchdog PC
======================================

Đánh giá lần cuối: 05/10/2007

Hỗ trợ Thẻ ISA Phiên bản A và C
=======================================

Tài liệu và trình điều khiển của Ken Hollis <kenji@bitgate.com>

PC Watchdog là thẻ cung cấp cùng loại chức năng
 thẻ WDT có, chỉ có điều nó không yêu cầu IRQ để chạy.  Hơn nữa,
 Thẻ Revision C cho phép bạn giám sát bất kỳ Cổng IO nào để tự động
 kích hoạt thẻ được thiết lập lại.  Bằng cách này bạn có thể làm thẻ
 theo dõi trạng thái ổ cứng hoặc bất cứ thứ gì bạn cần.

Trình điều khiển Watchdog có một vai trò cơ bản: nói chuyện với thẻ và gửi
 báo hiệu cho nó để nó không khởi động lại máy tính của bạn... ít nhất là trong
 hoạt động bình thường.

Trình điều khiển Watchdog sẽ tự động tìm thẻ cơ quan giám sát của bạn và sẽ
 đính kèm driver đang chạy để sử dụng với thẻ đó.  Sau cơ quan giám sát
 trình điều khiển đã được khởi tạo, sau đó bạn có thể nói chuyện với thẻ bằng PC
 Chương trình giám sát.

Tôi khuyên bạn nên đặt "cơ quan giám sát -d" trước khi bắt đầu fsck và
 "watchdog -e -t 1" ngay sau khi kết thúc fsck.  (Ghi nhớ
 để chạy chương trình có dấu "&" để chạy chương trình ở chế độ nền!)

Nếu bạn muốn viết một chương trình tương thích với PC Watchdog
 trình điều khiển, chỉ cần sử dụng sửa đổi chương trình kiểm tra cơ quan giám sát:
 công cụ/thử nghiệm/selftests/watchdog/watchdog-test.c


Các chức năng IOCTL khác bao gồm:

WDIOC_GETSUPPORT
		Điều này trả về sự hỗ trợ của chính thẻ.  Cái này
		trả về cấu trúc "PCWDS" trả về:

tùy chọn = WDIOS_TEMPPANIC
				  (Thẻ này hỗ trợ nhiệt độ)
			firmware_version = xxxx
				  (Phiên bản phần mềm của thẻ)

WDIOC_GETSTATUS
		Điều này trả về trạng thái của thẻ, với các bit của
		WDIOF_* được chuyển đổi theo bit thành giá trị.  (Các ý kiến
		nằm trong include/uapi/linux/watchdog.h)

WDIOC_GETBOOTSTATUS
		Điều này trả về trạng thái của thẻ đã được báo cáo
		lúc khởi động.

WDIOC_GETTEMP
		Điều này trả về nhiệt độ của thẻ.  (Bạn cũng có thể
		đọc /dev/watchdog, cung cấp thông tin cập nhật về nhiệt độ
		mỗi giây.)

WDIOC_SETOPTIONS
		Điều này cho phép bạn thiết lập các tùy chọn của thẻ.  Bạn có thể
		kích hoạt hoặc vô hiệu hóa thẻ theo cách này.

WDIOC_KEEPALIVE
		Thao tác này sẽ ping thẻ để yêu cầu thẻ không đặt lại máy tính của bạn.

Và đó là tất cả những gì cô ấy viết!

-- Ken Hollis
    (kenji@bitgate.com)
