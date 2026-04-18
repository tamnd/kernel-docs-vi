.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/hyperv/clocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Đồng hồ và hẹn giờ
==================

cánh tay64
----------
Trên arm64, Hyper-V ảo hóa bộ đếm hệ thống kiến trúc ARMv8
và hẹn giờ. Máy ảo khách sử dụng phần cứng ảo hóa này như Linux
clocksource và clockevents thông qua arm_arch_timer.c tiêu chuẩn
người lái xe, giống như họ làm trên kim loại trần. Hỗ trợ Linux vDSO cho
bộ đếm hệ thống kiến trúc hoạt động trong các máy ảo khách trên Hyper-V.
Trong khi Hyper-V cũng cung cấp đồng hồ hệ thống tổng hợp và bốn đồng hồ tổng hợp
bộ định thời trên mỗi CPU như được mô tả trong TLFS, chúng không được sử dụng bởi
Nhân Linux trong máy khách Hyper-V trên arm64.  Tuy nhiên, các phiên bản cũ hơn
của Hyper-V cho arm64 chỉ ảo hóa một phần ARMv8
bộ định thời kiến trúc, sao cho bộ định thời không tạo ra
ngắt trong VM. Vì hạn chế này nên dòng điện chạy
Các phiên bản nhân Linux trên các phiên bản Hyper-V cũ này yêu cầu một
thay thế bằng bản vá ngoài cây để sử dụng đồng hồ/bộ hẹn giờ tổng hợp Hyper-V.

x86/x64
-------
Trên x86/x64, Hyper-V cung cấp cho các máy ảo khách một đồng hồ hệ thống tổng hợp
và bốn bộ định thời tổng hợp trên mỗi CPU như được mô tả trong TLFS. Hyper-V
cũng cung cấp quyền truy cập vào TSC ảo hóa thông qua RDTSC và
hướng dẫn liên quan. Các lệnh TSC này không bẫy vào
bộ ảo hóa và do đó cung cấp hiệu suất tuyệt vời trong máy ảo.
Hyper-V thực hiện hiệu chuẩn TSC và cung cấp tần số TSC
tới VM khách thông qua MSR tổng hợp.  Mã khởi tạo Hyper-V
trong Linux đọc MSR này để lấy tần số, vì vậy nó bỏ qua TSC
hiệu chuẩn và đặt tsc_reliable. Hyper-V cung cấp khả năng ảo hóa
các phiên bản của PIT (chỉ trong máy ảo Hyper-V thế hệ 1), cục bộ
Bộ hẹn giờ APIC và RTC. Hyper-V không cung cấp HPET ảo hóa trong
VM khách.

Đồng hồ hệ thống tổng hợp Hyper-V có thể được đọc thông qua MSR tổng hợp,
nhưng quyền truy cập này bẫy vào bộ ảo hóa. Là một giải pháp thay thế nhanh hơn,
khách có thể định cấu hình trang bộ nhớ để chia sẻ giữa khách
và trình ảo hóa.  Hyper-V điền vào trang bộ nhớ này một
Giá trị tỷ lệ 64 bit và giá trị bù. Để đọc đồng hồ tổng hợp
giá trị, khách đọc TSC rồi áp dụng tỷ lệ và độ lệch
như được mô tả trong Hyper-V TLFS. Giá trị kết quả tăng lên
ở tần số 10 MHz không đổi. Trong trường hợp di cư trực tiếp
tới máy chủ có tần số TSC khác, Hyper-V sẽ điều chỉnh
các giá trị chia tỷ lệ và bù đắp trong trang được chia sẻ sao cho tần số 10 MHz
tần số được duy trì

Bắt đầu với Windows Server 2022 Hyper-V, Hyper-V sử dụng phần cứng
hỗ trợ mở rộng tần số TSC để cho phép di chuyển trực tiếp các máy ảo
trên các máy chủ Hyper-V nơi tần số TSC có thể khác nhau.
Khi một khách Linux phát hiện ra rằng chức năng Hyper-V này bị
sẵn có, nó thích sử dụng nguồn xung nhịp dựa trên TSC tiêu chuẩn của Linux.
Mặt khác, nó sử dụng nguồn xung nhịp cho hệ thống tổng hợp Hyper-V
đồng hồ được thực hiện thông qua trang chia sẻ (được xác định là
"hyperv_clocksource_tsc_page").

Đồng hồ hệ thống tổng hợp Hyper-V có sẵn cho không gian người dùng thông qua
vDSO, gettimeofday() và các cuộc gọi hệ thống liên quan có thể thực thi
hoàn toàn trong không gian người dùng.  vDSO được triển khai bằng cách ánh xạ
trang được chia sẻ với các giá trị tỷ lệ và độ lệch vào không gian người dùng.  người dùng
mã không gian thực hiện cùng một thuật toán đọc TSC và
áp dụng thang đo và độ lệch để có được xung nhịp 10 MHz không đổi.

Các sự kiện xung nhịp của Linux dựa trên bộ đếm thời gian tổng hợp Hyper-V 0 (stimer0).
Trong khi Hyper-V cung cấp 4 bộ định thời tổng hợp cho mỗi CPU thì Linux chỉ sử dụng
bộ đếm thời gian 0. Trong các phiên bản cũ hơn của Hyper-V, một ngắt từ bộ kích thích0
dẫn đến một thông báo điều khiển VMBus được phân kênh bởi
vmbus_isr() như được mô tả trong Documentation/virt/hyperv/vmbus.rst
tài liệu. Trong các phiên bản mới hơn của Hyper-V, ngắt stimer0 có thể
được ánh xạ tới một ngắt kiến trúc, được gọi là
"Chế độ trực tiếp". Linux thích sử dụng Chế độ Trực tiếp khi có sẵn. Kể từ khi
x86/x64 không hỗ trợ ngắt theo CPU, Chế độ trực tiếp tĩnh
phân bổ một vectơ ngắt x86 (HYPERV_STIMER0_VECTOR) trên tất cả các CPU
và mã hóa nó một cách rõ ràng để gọi bộ xử lý ngắt stimer0. Do đó
các ngắt từ stimer0 được ghi trên dòng "HVS" trong /proc/interrupts
thay vì được liên kết với Linux IRQ. Sự kiện đồng hồ dựa trên
PIT ảo hóa và bộ đếm thời gian APIC cục bộ cũng hoạt động, nhưng Hyper-V stimer0
được ưu tiên.

Trình điều khiển cho đồng hồ và bộ hẹn giờ của hệ thống tổng hợp Hyper-V là
trình điều khiển/clocksource/hyperv_timer.c.