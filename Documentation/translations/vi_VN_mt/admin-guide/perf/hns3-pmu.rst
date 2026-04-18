.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/hns3-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Bộ giám sát hiệu suất HNS3 (PMU)
======================================

HNS3(Hệ thống mạng HiSilicon 3) Đơn vị giám sát hiệu suất (PMU) là một
Thiết bị End Point thu thập số liệu thống kê hiệu suất của HiSilicon SoC NIC.
Trên Hip09, mỗi SICL(Cụm Super I/O) có một thiết bị PMU.

HNS3 PMU hỗ trợ thu thập số liệu thống kê hiệu suất như băng thông,
độ trễ, tốc độ gói và tốc độ ngắt.

Mỗi HNS3 PMU hỗ trợ 8 sự kiện phần cứng.

Trình điều khiển HNS3 PMU
===============

Trình điều khiển HNS3 PMU đăng ký PMU hoàn hảo với tên sicl id của nó.::

/sys/bus/event_source/devices/hns3_pmu_sicl_<sicl_id>

Trình điều khiển PMU cung cấp mô tả về các sự kiện có sẵn, chế độ lọc, định dạng,
mã định danh và cpumask trong sysfs.

Thư mục "sự kiện" mô tả mã sự kiện của tất cả các sự kiện được hỗ trợ
hiển thị trong danh sách hoàn hảo.

Thư mục "filtermode" mô tả các chế độ lọc được hỗ trợ của từng
sự kiện.

Thư mục "format" mô tả tất cả các định dạng của config (sự kiện) và
Các trường config1 (tùy chọn bộ lọc) của cấu trúc perf_event_attr.

Tệp "định danh" hiển thị phiên bản của thiết bị phần cứng PMU.

Tệp "bdf_min" và "bdf_max" hiển thị phạm vi bdf được hỗ trợ của từng loại
thiết bị pmu.

Tệp "hw_clk_freq" hiển thị tần số xung nhịp phần cứng của từng pmu
thiết bị.

Ví dụ sử dụng mã sự kiện kiểm tra và mã sự kiện phụ::

$# cat /sys/bus/event_source/devices/hns3_pmu_sicl_0/events/dly_tx_normal_to_mac_time
  cấu hình=0x00204
  $# cat /sys/bus/event_source/devices/hns3_pmu_sicl_0/events/dly_tx_normal_to_mac_packet_num
  cấu hình=0x10204

Mỗi thống kê hiệu suất có một cặp sự kiện để nhận hai giá trị
tính toán dữ liệu hiệu suất thực trong không gian người dùng.

Các bit 0~15 của cấu hình (ở đây là 0x0204) là mã sự kiện phần cứng thực sự. Nếu
hai sự kiện có cùng giá trị bit 0~15 của cấu hình, điều đó có nghĩa là chúng
cặp sự kiện Và bit 16 của cấu hình biểu thị việc nhận bộ đếm 0 hoặc
bộ đếm 1 của sự kiện phần cứng.

Sau khi nhận được hai giá trị của cặp sự kiện trong không gian người dùng, công thức của
tính toán để tính toán dữ liệu hiệu suất thực là:::

bộ đếm 0 / bộ đếm 1

Ví dụ sử dụng kiểm tra chế độ bộ lọc được hỗ trợ::

$# cat /sys/bus/event_source/devices/hns3_pmu_sicl_0/filtermode/bw_ssu_rpu_byte_num
  chế độ lọc được hỗ trợ: Global/port/port-tc/func/func-queue/

Ví dụ sử dụng perf::

Danh sách $# perf
  hns3_pmu_sicl_0/bw_ssu_rpu_byte_num/ [sự kiện kernel PMU]
  hns3_pmu_sicl_0/bw_ssu_rpu_time/ [sự kiện kernel PMU]
  ------------------------------------------

$# perf stat -g -e hns3_pmu_sicl_0/bw_ssu_rpu_byte_num,global=1/ -e hns3_pmu_sicl_0/bw_ssu_rpu_time,global=1/ -I 1000
  hoặc
  $# perf stat -g -e hns3_pmu_sicl_0/config=0x00002,global=1/ -e hns3_pmu_sicl_0/config=0x10002,global=1/ -I 1000


Chế độ lọc
--------------

1. chế độ toàn cầu
PMU thu thập số liệu thống kê hiệu suất cho tất cả các chức năng PCIe HNS3 của IO DIE.
Đặt tùy chọn bộ lọc "toàn cầu" thành 1 sẽ kích hoạt chế độ này.
Ví dụ sử dụng perf::

$# perf stat -a -e hns3_pmu_sicl_0/config=0x1020F,global=1/ -I 1000

2. chế độ cổng
PMU thu thập thống kê hiệu suất của toàn bộ một cổng vật lý. Id cổng
giống như mac id. Tùy chọn bộ lọc "tc" phải được đặt thành 0xF ở chế độ này,
ở đây tc là viết tắt của lớp lưu lượng.

Ví dụ sử dụng perf::

$# perf thống kê -a -e hns3_pmu_sicl_0/config=0x1020F,port=0,tc=0xF/ -I 1000

3. Chế độ cổng-tc
PMU thu thập số liệu thống kê hiệu suất của một cổng vật lý. Id cổng
giống như mac id. Tùy chọn bộ lọc "tc" phải được đặt thành 0 ~ 7 trong trường hợp này
chế độ.
Ví dụ sử dụng perf::

$# perf thống kê -a -e hns3_pmu_sicl_0/config=0x1020F,port=0,tc=0/ -I 1000

4. chế độ chức năng
PMU thu thập số liệu thống kê hiệu suất của một PF/VF. Id chức năng là BDF của
PF/VF, công thức chuyển đổi của nó::

func = (bus << 8) + (thiết bị << 3) + (chức năng)

ví dụ:
  Chức năng BDF
  35:00.0 0x3500
  35:00.1 0x3501
  35:01.0 0x3508

Ở chế độ này, tùy chọn bộ lọc "hàng đợi" phải được đặt thành 0xFFFF.
Ví dụ sử dụng perf::

$# perf thống kê -a -e hns3_pmu_sicl_0/config=0x1020F,bdf=0x3500,queue=0xFFFF/ -I 1000

5. chế độ xếp hàng chức năng
PMU thu thập số liệu thống kê hiệu suất của một hàng PF/VF. Id chức năng
là BDF của PF/VF, tùy chọn bộ lọc "hàng đợi" phải được đặt thành hàng đợi chính xác
id của hàm
Ví dụ sử dụng perf::

$# perf thống kê -a -e hns3_pmu_sicl_0/config=0x1020F,bdf=0x3500,queue=0/ -I 1000

6. Chế độ func-intr
PMU thu thập thống kê hiệu suất của một lần ngắt của PF/VF. chức năng
id là BDF của PF/VF, tùy chọn bộ lọc "intr" phải được đặt chính xác
id ngắt của hàm.
Ví dụ sử dụng perf::

$# perf thống kê -a -e hns3_pmu_sicl_0/config=0x00301,bdf=0x3500,intr=0/ -I 1000
