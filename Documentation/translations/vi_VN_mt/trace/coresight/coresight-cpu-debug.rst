.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-cpu-debug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Mô-đun gỡ lỗi Coresight CPU
=============================

:Tác giả: Leo Yan <leo.yan@linaro.org>
   : Ngày: 5 tháng 4 năm 2017

Giới thiệu
------------

Mô-đun gỡ lỗi Coresight CPU được xác định trong sổ tay tham khảo kiến trúc ARMv8-a
(ARM DDI 0487A.k) Chương 'Phần H: Gỡ lỗi bên ngoài', CPU có thể tích hợp
mô-đun gỡ lỗi và nó chủ yếu được sử dụng cho hai chế độ: gỡ lỗi tự lưu trữ và
gỡ lỗi bên ngoài. Thông thường chế độ gỡ lỗi bên ngoài được biết đến nhiều như chế độ gỡ lỗi bên ngoài.
trình gỡ lỗi kết nối với SoC từ cổng JTAG; mặt khác chương trình có thể
khám phá phương pháp gỡ lỗi dựa trên chế độ gỡ lỗi tự lưu trữ, tài liệu này
là tập trung vào phần này.

Mô-đun gỡ lỗi cung cấp phần mở rộng hồ sơ dựa trên mẫu, có thể được sử dụng
để lấy mẫu bộ đếm chương trình CPU, trạng thái an toàn và mức ngoại lệ, v.v; thường
mỗi CPU đều có một mô-đun gỡ lỗi chuyên dụng để kết nối. Dựa trên tự lưu trữ
cơ chế gỡ lỗi, nhân Linux có thể truy cập các thanh ghi liên quan này từ mmio
khu vực khi sự hoảng loạn hạt nhân xảy ra. Trình thông báo gọi lại cho kernel hoảng loạn
sẽ kết xuất các thanh ghi liên quan cho mọi CPU; cuối cùng thì điều này cũng tốt cho trợ lý
phân tích sự hoảng loạn.


Thực hiện
--------------

- Trong quá trình đăng ký trình điều khiển, nó sử dụng EDDEVID và EDDEVID1 - hai ID thiết bị
  đăng ký để quyết định xem hồ sơ dựa trên mẫu có được triển khai hay không. Trên một số
  nền tảng tính năng phần cứng này được triển khai đầy đủ hoặc một phần; và nếu
  tính năng này không được hỗ trợ thì việc đăng ký sẽ thất bại.

- Vào thời điểm tài liệu này được viết, trình điều khiển gỡ lỗi chủ yếu dựa vào
  thông tin được thu thập bởi trình thông báo gọi lại hoảng loạn kernel từ ba
  thanh ghi lấy mẫu: EDPCSR, EDVIDSR và EDCIDSR: từ EDPCSR chúng ta có thể nhận được
  bộ đếm chương trình; EDVIDSR có thông tin về trạng thái bảo mật, mức độ ngoại lệ,
  độ rộng bit, v.v; EDCIDSR là giá trị ID ngữ cảnh chứa giá trị được lấy mẫu
  của CONTEXTIDR_EL1.

- Trình điều khiển hỗ trợ CPU chạy ở chế độ AArch64 hoặc AArch32. các
  quy ước đặt tên các thanh ghi có một chút khác biệt giữa chúng, AArch64 sử dụng
  'ED' cho tiền tố đăng ký (ARM DDI 0487A.k, chương H9.1) và sử dụng AArch32
  'DBG' làm tiền tố (ARM DDI 0487A.k, chương G5.1). Người lái xe được thống nhất để
  sử dụng quy ước đặt tên AArch64.

- ARMv8-a (ARM DDI 0487A.k) và ARMv7-a (ARM DDI 0406C.b) có sự khác nhau
  định nghĩa bit đăng ký Vì vậy, trình điều khiển hợp nhất hai điểm khác biệt:

Nếu PCSROffset=0b0000, trên ARMv8-a, tính năng của EDPCSR không được triển khai;
  nhưng ARMv7-a định nghĩa "các mẫu PCSR được bù bằng một giá trị phụ thuộc vào
  trạng thái tập lệnh". Đối với ARMv7-a, trình điều khiển sẽ kiểm tra thêm xem CPU có
  chạy với ARM hoặc tập lệnh ngón tay cái và hiệu chỉnh giá trị PCSR,
  mô tả chi tiết về phần bù có trong chương ARMv7-a ARM (ARM DDI 0406C.b)
  C11.11.34 "DBGPCSR, Thanh ghi lấy mẫu bộ đếm chương trình".

Nếu PCSROffset=0b0010, ARMv8-a xác định "EDPCSR đã được triển khai và các mẫu có
  không áp dụng bù trừ và không lấy mẫu trạng thái tập lệnh trong AArch32
  nhà nước". Vì vậy, trên ARMv8 nếu EDDEVID1.PCSROffset là 0b0010 và CPU hoạt động
  ở trạng thái AArch32, EDPCSR không được lấy mẫu; khi CPU hoạt động ở AArch64
  trạng thái EDPCSR được lấy mẫu và không áp dụng offset.


Miền đồng hồ và nguồn
----------------------

Trước khi truy cập các thanh ghi gỡ lỗi, chúng ta nên đảm bảo miền đồng hồ và nguồn
đã được kích hoạt đúng cách. Trong ARMv8-a ARM (ARM DDI 0487A.k) chương 'H9.1
Các thanh ghi gỡ lỗi', các thanh ghi gỡ lỗi được chia thành hai miền: thanh ghi gỡ lỗi
miền và miền CPU.
:::::::::::::::::

+--------------+
                                ZZ0000ZZ
                                ZZ0001ZZ
                     +----------+--+ |
        dbg_clock -->ZZ0002ZZ**ZZ0003ZZ<- cpu_clock
                     ZZ0004ZZ**ZZ0005ZZ
 dbg_power_domain -->ZZ0006ZZ**ZZ0007ZZ<- cpu_power_domain
                     +----------+--+ |
                                ZZ0008ZZ
                                ZZ0009ZZ
                                +--------------+

Đối với miền gỡ lỗi, người dùng sử dụng "đồng hồ" và "miền nguồn" liên kết DT để
chỉ định nguồn xung nhịp và nguồn điện tương ứng cho logic gỡ lỗi.
Trình điều khiển gọi các thao tác pm_runtime_{put|get} nếu cần để xử lý
gỡ lỗi miền điện.

Đối với miền CPU, các thiết kế SoC khác nhau có cách quản lý năng lượng khác nhau
lược đồ và cuối cùng điều này ảnh hưởng nặng nề đến mô-đun gỡ lỗi bên ngoài. Vì vậy chúng ta có thể
chia thành các trường hợp sau:

- Trên các hệ thống có bộ điều khiển nguồn hợp lý có thể hoạt động chính xác với
  đối với miền năng lượng CPU, miền năng lượng CPU có thể được kiểm soát bởi
  đăng ký EDPRCR trong trình điều khiển. Trình điều khiển trước tiên ghi bit EDPRCR.COREPURQ
  để cấp nguồn cho CPU, sau đó ghi bit EDPRCR.CORENPDRQ để mô phỏng
  của CPU mất điện. Kết quả là, điều này có thể đảm bảo miền năng lượng CPU
  bật nguồn đúng cách trong khoảng thời gian truy cập vào các thanh ghi liên quan đến gỡ lỗi;

- Một số thiết kế sẽ tắt nguồn toàn bộ cụm nếu tất cả CPU trên cụm
  bị tắt nguồn - bao gồm cả các phần của thanh ghi gỡ lỗi cần
  vẫn được cấp nguồn trong miền năng lượng gỡ lỗi. Các bit trong EDPRCR không
  được tôn trọng trong những trường hợp này, vì vậy những thiết kế này không hỗ trợ gỡ lỗi
  tắt nguồn theo cách mà các nhà thiết kế CoreSight/Debug đã dự đoán.
  Điều này có nghĩa là ngay cả việc kiểm tra EDPRSR cũng có khả năng gây ra hiện tượng treo xe buýt
  nếu thanh ghi mục tiêu không được cấp nguồn.

Trong trường hợp này, việc truy cập vào các thanh ghi gỡ lỗi khi chúng không được cấp nguồn
  là công thức dẫn đến thảm họa; vì vậy chúng ta cần ngăn chặn trạng thái năng lượng thấp của CPU khi khởi động
  thời gian hoặc khi người dùng kích hoạt mô-đun tại thời điểm chạy. Xin vui lòng xem chương
  "Cách sử dụng mô-đun" để biết thông tin sử dụng chi tiết cho việc này.


Ràng buộc cây thiết bị
----------------------

Xem Documentation/devicetree/binds/arm/arm,coresight-cpu-debug.yaml để biết
chi tiết.


Cách sử dụng mô-đun
---------------------

Nếu bạn muốn bật chức năng gỡ lỗi khi khởi động, bạn có thể thêm
"coresight_cpu_debug.enable=1" vào tham số dòng lệnh kernel.

Trình điều khiển cũng có thể hoạt động như mô-đun, do đó có thể kích hoạt tính năng gỡ lỗi khi insmod
mô-đun::

# insmod coresight_cpu_debug.ko debug=1

Khi thời gian khởi động hoặc mô-đun insmod bạn chưa bật tính năng gỡ lỗi, trình điều khiển sẽ
sử dụng hệ thống tệp debugfs để cung cấp một nút xoay để kích hoạt hoặc vô hiệu hóa một cách linh hoạt
gỡ lỗi:

Để kích hoạt nó, hãy viết số '1' vào /sys/kernel/debug/coresight_cpu_debug/enable::

# echo 1 > /sys/kernel/debug/coresight_cpu_debug/bật

Để tắt nó, hãy viết '0' vào /sys/kernel/debug/coresight_cpu_debug/enable::

# echo 0 > /sys/kernel/debug/coresight_cpu_debug/bật

Như đã giải thích trong chương "Miền đồng hồ và nguồn", nếu bạn đang làm việc trên một miền
nền tảng có trạng thái không hoạt động để tắt logic gỡ lỗi và nguồn điện
bộ điều khiển không thể hoạt động tốt theo yêu cầu từ EDPRCR, thì bạn nên
trước tiên hãy hạn chế trạng thái nhàn rỗi của CPU trước khi bật tính năng gỡ lỗi CPU; vậy có thể
đảm bảo việc truy cập vào logic gỡ lỗi.

Nếu bạn muốn giới hạn trạng thái không hoạt động khi khởi động, bạn có thể sử dụng "nohlt" hoặc
"cpuidle.off=1" trong dòng lệnh kernel.

Trong thời gian chạy, bạn có thể tắt trạng thái không hoạt động bằng các phương pháp bên dưới:

Có thể tắt trạng thái nhàn rỗi của CPU bằng PM QoS
hệ thống con, cụ thể hơn bằng cách sử dụng "/dev/cpu_dma_latency"
giao diện (xem Tài liệu/power/pm_qos_interface.rst để biết thêm
chi tiết).  Như được chỉ định trong tài liệu PM QoS, yêu cầu
tham số sẽ có hiệu lực cho đến khi bộ mô tả tệp được giải phóng.
Ví dụ::

# exec 3<> /dev/cpu_dma_latency; tiếng vang 0 >&3
  ...
Làm một số việc...
  ...
# exec 3<>-

Điều tương tự cũng có thể được thực hiện từ một chương trình ứng dụng.

Vô hiệu hóa trạng thái không hoạt động cụ thể của CPU khỏi các hệ thống cpuidle (xem
Tài liệu/admin-guide/pm/cpuidle.rst)::

# echo 1 > /sys/devices/system/cpu/cpu$cpu/cpuidle/state$state/disable

định dạng đầu ra
----------------

Dưới đây là ví dụ về định dạng đầu ra gỡ lỗi::

Mô-đun gỡ lỗi bên ngoài ARM:
  coresight-cpu-debug 850000.debug: CPU[0]:
  coresight-cpu-debug 850000.debug: EDPRSR: 00000001 (Nguồn: Bật DLK: Mở khóa)
  coresight-cpu-debug 850000.debug: EDPCSR: hand_IPI+0x174/0x1d8
  coresight-cpu-debug 850000.debug: EDCIDSR: 00000000
  coresight-cpu-debug 850000.debug: EDVIDSR: 90000000 (Trạng thái:Chế độ không an toàn:EL1/0 Chiều rộng:64bits VMID:0)
  coresight-cpu-debug 852000.debug: CPU[1]:
  coresight-cpu-debug 852000.debug: EDPRSR: 00000001 (Nguồn: Bật DLK: Mở khóa)
  coresight-cpu-debug 852000.debug: EDPCSR: debug_notifier_call+0x23c/0x358
  coresight-cpu-debug 852000.debug: EDCIDSR: 00000000
  coresight-cpu-debug 852000.debug: EDVIDSR: 90000000 (Trạng thái:Chế độ không an toàn:EL1/0 Chiều rộng:64bits VMID:0)
