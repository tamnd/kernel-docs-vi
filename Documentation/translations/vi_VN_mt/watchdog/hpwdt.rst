.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/hpwdt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Trình điều khiển cơ quan giám sát HPE iLO NMI
=============================================

dành cho Máy chủ ProLiant dựa trên iLO
==============================

Đánh giá lần cuối: 20/08/2018


Trình điều khiển Watchdog HPE iLO NMI là một mô-đun hạt nhân cung cấp cơ bản
 chức năng giám sát và trình xử lý cho iLO "Tạo NMI vào hệ thống"
 nút ảo.

Tất cả các tham chiếu đến iLO trong tài liệu này đều ngụ ý rằng nó cũng hoạt động trên iLO2 và tất cả
 các thế hệ tiếp theo.

Chức năng cơ quan giám sát được kích hoạt giống như bất kỳ trình điều khiển cơ quan giám sát thông thường nào khác. Đó
 nghĩa là, một ứng dụng cần được khởi động để khởi động bộ đếm thời gian theo dõi. A
 ứng dụng cơ bản tồn tại trong công cụ/thử nghiệm/selftests/watchdog/có tên
 cơ quan giám sát-test.c. Đơn giản chỉ cần biên dịch tệp C và khởi động nó. Nếu hệ thống
 rơi vào trạng thái xấu và bị treo, thanh ghi hẹn giờ iLO HPE ProLiant sẽ
 không được cập nhật kịp thời và thiết lập lại hệ thống phần cứng (còn được gọi là
 sự kiện Phục hồi máy chủ tự động (ASR)) sẽ xảy ra.

Trình điều khiển hpwdt cũng có các tham số mô-đun sau:

==================================================================================
 soft_margin cho phép người dùng đặt giá trị bộ đếm thời gian của cơ quan giám sát.
               Giá trị mặc định là 30 giây.
 hết thời gian bí danh của soft_margin.
 pretimeout cho phép người dùng đặt giá trị pretimeout của cơ quan giám sát.
               Đây là số giây trước khi hết thời gian chờ khi một
               NMI được gửi đến hệ thống. Đặt giá trị thành
               số không vô hiệu hóa thời gian chờ trước NMI.
               Giá trị mặc định là 9 giây.
 tham số cơ quan giám sát cơ bản hiện tại không cho phép bộ đếm thời gian
               được khởi động lại hoặc ASR sắp được thoát.
               Giá trị mặc định được đặt khi biên dịch kernel. Nếu nó được thiết lập
               thành "Y", thì không có cách nào vô hiệu hóa cơ quan giám sát một lần
               nó đã được bắt đầu.
 kdumptimeout Thời gian chờ tối thiểu tính bằng giây để áp dụng khi nhận được NMI
               trước khi kêu gọi hoảng loạn. (-1) vô hiệu hóa cơ quan giám sát.  Khi giá trị
               là > 0, bộ đếm thời gian được lập trình lại với giá trị lớn hơn
               giá trị hoặc giá trị thời gian chờ hiện tại.
 ==================================================================================

NOTE:
       Thông tin thêm về trình điều khiển cơ quan giám sát nói chung, bao gồm cả ioctl
       giao diện cho/dev/watchdog có thể được tìm thấy trong
       Tài liệu/watchdog/watchdog-api.rst và Documentation/driver-api/ipmi.rst

Do những hạn chế trong phần cứng iLO, thời gian chờ trước của NMI nếu được bật,
 chỉ có thể được đặt thành 9 giây.  Cố gắng đặt thời gian chờ cho người khác
 các giá trị khác 0 sẽ được làm tròn, có thể về 0.  Người dùng nên xác minh
 giá trị thời gian chờ sau khi thử đặt thời gian chờ hoặc thời gian chờ.

Khi nhận được NMI từ iLO, trình điều khiển hpwdt sẽ bắt đầu
 hoảng loạn. Điều này cho phép thu thập kết xuất sự cố.  Nó đương nhiệm
 yêu cầu người dùng phải cấu hình hệ thống cho kdump đúng cách.

Hành vi mặc định của nhân Linux khi hoảng loạn là in bia mộ của nhân
 và lặp lại mãi mãi.  Đây thường không phải là điều mà người dùng cơ quan giám sát mong muốn.

Ai muốn tìm hiểu thêm vui lòng xem:
	- Tài liệu/admin-guide/kdump/kdump.rst
	- Documentation/admin-guide/kernel-parameters.txt (hoang mang=)
	- Tài liệu cụ thể về bản phân phối Linux của bạn.

Nếu hpwdt không nhận được NMI được liên kết với bộ hẹn giờ hết hạn,
 iLO sẽ tiến hành thiết lập lại hệ thống khi hết thời gian chờ nếu bộ hẹn giờ không
 đã được cập nhật.

--

Trình điều khiển và tài liệu Watchdog HPE iLO NMI ban đầu được phát triển
 của Tom Mingarelli.
