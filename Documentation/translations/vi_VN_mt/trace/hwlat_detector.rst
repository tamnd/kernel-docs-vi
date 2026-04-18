.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/hwlat_detector.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình phát hiện độ trễ phần cứng
=========================

Giới thiệu
-------------

Bộ theo dõi hwlat_Detector là một bộ theo dõi có mục đích đặc biệt được sử dụng để
phát hiện độ trễ hệ thống lớn gây ra bởi hoạt động của một số cơ chế cơ bản nhất định
phần cứng hoặc phần sụn, độc lập với chính Linux. Mã đã được phát triển
ban đầu để phát hiện SMI (Ngắt quản lý hệ thống) trên hệ thống x86,
tuy nhiên không có gì cụ thể về x86 về bản vá này. Đó là
ban đầu được viết để sử dụng cho bản vá "RT" kể từ Thời gian thực
kernel rất nhạy cảm với độ trễ.

SMI không được nhân Linux phục vụ, có nghĩa là nó không
thậm chí biết rằng chúng đang xảy ra. Thay vào đó, SMI được thiết lập bằng mã BIOS
và được phục vụ bằng mã BIOS, thường dành cho các sự kiện "quan trọng" như
quản lý cảm biến nhiệt và quạt. Tuy nhiên, đôi khi SMI được sử dụng để
các nhiệm vụ khác và những nhiệm vụ đó có thể tiêu tốn một lượng thời gian quá lớn trong
trình xử lý (đôi khi được đo bằng mili giây). Rõ ràng đây là một vấn đề nếu
bạn đang cố gắng giảm độ trễ của dịch vụ sự kiện trong phạm vi micro giây.

Trình phát hiện độ trễ phần cứng hoạt động bằng cách chiếm dụng một trong các CPU để có thể định cấu hình
lượng thời gian (với các ngắt bị vô hiệu hóa), thăm dò Bộ đếm dấu thời gian CPU
trong một khoảng thời gian, sau đó tìm kiếm những khoảng trống trong dữ liệu TSC. Bất kỳ khoảng trống nào cũng cho thấy một
thời điểm việc bỏ phiếu bị gián đoạn và vì các ngắt bị vô hiệu hóa,
điều duy nhất có thể làm được điều đó là SMI hoặc trục trặc phần cứng khác
(hoặc NMI, nhưng chúng có thể được theo dõi).

Lưu ý rằng máy dò hwlat nên sử dụng ZZ0000ZZ trong môi trường sản xuất.
Nó được thiết kế để chạy thủ công để xác định xem nền tảng phần cứng có
vấn đề với quy trình dịch vụ phần mềm hệ thống dài.

Cách sử dụng
------

Viết văn bản ASCII "hwlat" vào tệp current_tracer của hệ thống theo dõi
(được gắn tại /sys/kernel/tracing hoặc /sys/kernel/tracing). Có thể
xác định lại ngưỡng tính bằng micro giây (chúng tôi) mà trên đó mức độ trễ sẽ tăng đột biến
được tính đến.

Ví dụ::

# echo hwlat > /sys/kernel/tracing/current_tracer
	# echo 100 > /sys/kernel/tracing/tracing_thresh

Giao diện /sys/kernel/tracing/hwlat_Detector chứa các tệp sau:

- chiều rộng - khoảng thời gian để lấy mẫu với CPU được giữ (usecs)
            phải nhỏ hơn tổng kích thước cửa sổ (được thực thi)
  - cửa sổ - tổng thời gian lấy mẫu, chiều rộng bên trong (usecs)

Theo mặc định, chiều rộng được đặt thành 500.000 và cửa sổ thành 1.000.000, nghĩa là
cứ sau 1.000.000 usec (1 giây), trình phát hiện hwlat sẽ quay trong 500.000 usec
(0,5 giây). Nếu tracing_thresh chứa 0 khi bật hwlat tracer, nó sẽ
thay đổi thành mặc định là 10 usec. Nếu có bất kỳ độ trễ nào vượt quá ngưỡng
quan sát thì dữ liệu sẽ được ghi vào bộ đệm vòng theo dõi.

Thời gian ngủ tối thiểu giữa các khoảng thời gian là 1 mili giây. Ngay cả khi chiều rộng
cách cửa sổ chưa đến 1 mili giây, để cho phép hệ thống không
bị bỏ đói hoàn toàn.

Nếu tracing_thresh bằng 0 khi trình phát hiện hwlat được khởi động, nó sẽ được đặt
trở về 0 nếu một bộ theo dõi khác được tải. Lưu ý, giá trị cuối cùng trong
tracing_thresh mà trình phát hiện hwlat có sẽ được lưu và giá trị này sẽ
được khôi phục trong tracing_thresh nếu nó vẫn bằng 0 khi trình phát hiện hwlat được kích hoạt
bắt đầu lại.

Các tệp thư mục theo dõi sau đây được hwlat_Detector sử dụng:

trong/sys/kernel/tracing:

- tracing_threshold - giá trị độ trễ tối thiểu được xem xét (usecs)
 - tracing_max_latency - độ trễ phần cứng tối đa thực sự được quan sát (usecs)
 - tracing_cpumask - CPU để di chuyển luồng hwlat qua
 - hwlat_Detector/width - lượng thời gian được chỉ định để quay trong cửa sổ (usecs)
 - hwlat_Detector/window - lượng thời gian giữa (chiều rộng) lần chạy (usecs)
 - hwlat_Detector/mode - chế độ luồng

Theo mặc định, luồng nhân của một trình phát hiện hwlat sẽ di chuyển qua mỗi CPU
được chỉ định trong cpumask ở đầu cửa sổ mới, theo chế độ quay vòng
thời trang. Hành vi này có thể được thay đổi bằng cách thay đổi chế độ luồng,
các tùy chọn có sẵn là:

- không có: không ép buộc di chuyển
 - round-robin: di chuyển qua từng CPU được chỉ định trong cpumask [mặc định]
 - per-cpu: tạo một thread cho mỗi cpu trong tracing_cpumask
