.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/hisi-pcie-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Bộ giám sát hiệu suất PCIe HiSilicon (PMU)
====================================================

Trên Hip09, Bộ giám sát hiệu suất PCIe HiSilicon (PMU) có thể giám sát
băng thông, độ trễ, mức sử dụng bus và dữ liệu chiếm dụng bộ đệm của PCIe.

Mỗi lõi PCIe có một PMU để giám sát nhiều Cổng gốc của Lõi PCIe này và
tất cả các Điểm cuối ở phía dưới các Cổng gốc này.


Trình điều khiển HiSilicon PCIe PMU
===================================

Trình điều khiển PCIe PMU đăng ký PMU hoàn hảo với tên sicl-id và PCIe của nó
Id lõi.::

/sys/bus/event_source/hisi_pcie<sicl>_core<core>

Trình điều khiển PMU cung cấp mô tả về các sự kiện có sẵn và các tùy chọn bộ lọc trong sysfs,
xem /sys/bus/event_source/devices/hisi_pcie<sicl>_core<core>.

Thư mục "format" mô tả tất cả các định dạng của config (sự kiện) và config1
(tùy chọn bộ lọc) các trường của cấu trúc perf_event_attr. Thư mục "sự kiện"
mô tả tất cả các sự kiện được ghi lại trong danh sách hoàn hảo.

Tệp sysfs "định danh" cho phép người dùng xác định phiên bản của
Thiết bị phần cứng PMU.

Tệp sysfs "bus" cho phép người dùng lấy số bus của Cổng gốc
được giám sát bởi PMU. Hơn nữa, người dùng có thể nhận được phạm vi Cổng gốc trong
[bdf_min, bdf_max] từ thuộc tính sysfs "bdf_min" và "bdf_max"
tương ứng.

Ví dụ sử dụng perf::

Danh sách $# perf
  hisi_pcie0_core0/rx_mwr_latency/ [sự kiện kernel PMU]
  hisi_pcie0_core0/rx_mwr_cnt/ [sự kiện kernel PMU]
  ------------------------------------------

Chỉ số $# perf -e hisi_pcie0_core0/rx_mwr_latency,port=0xffff/
  $# perf thống kê -e hisi_pcie0_core0/rx_mwr_cnt,port=0xffff/

Các sự kiện liên quan thường được sử dụng để tính toán băng thông, độ trễ hoặc các sự kiện khác.
Họ cần bắt đầu và kết thúc đếm cùng một lúc, do đó các sự kiện liên quan
được sử dụng tốt nhất trong cùng một nhóm sự kiện để nhận được giá trị mong đợi. Có hai
cách để biết liệu chúng có phải là sự kiện liên quan hay không:

a) Theo tên sự kiện, chẳng hạn như các sự kiện có độ trễ "xxx_latency, xxx_cnt" hoặc
   sự kiện băng thông "xxx_flux, xxx_time".
b) Theo loại sự kiện, chẳng hạn như "sự kiện=0xXXXX, sự kiện=0x1XXXX".

Ví dụ sử dụng nhóm hoàn hảo ::

Chỉ số $# perf -e "{hisi_pcie0_core0/rx_mwr_latency,port=0xffff/,hisi_pcie0_core0/rx_mwr_cnt,port=0xffff/}"

Trình điều khiển hiện tại không hỗ trợ lấy mẫu. Vì vậy "bản ghi hoàn hảo" không được hỗ trợ.
Ngoài ra, việc đính kèm vào một tác vụ không được hỗ trợ cho PCIe PMU.

Tùy chọn bộ lọc
---------------

1. Bộ lọc mục tiêu

PMU chỉ có thể giám sát hiệu suất của mục tiêu hạ lưu lưu lượng Root
   Cổng hoặc điểm cuối đích hạ lưu. Hỗ trợ "cổng" trình điều khiển PCIe PMU và
   giao diện "bdf" cho người dùng.
   Xin lưu ý rằng, một trong hai giao diện này phải được đặt và hai giao diện này
   giao diện không được hỗ trợ cùng một lúc. Nếu cả hai đều được đặt, chỉ
   Bộ lọc "cổng" hợp lệ.
   Nếu bộ lọc "cổng" không được đặt hoặc được đặt rõ ràng về 0 (mặc định), thì
   Bộ lọc "bdf" sẽ có hiệu lực vì "bdf=0" nghĩa là 0000:000:00.0.

- cổng

Bộ lọc "cổng" có thể được sử dụng trong tất cả các sự kiện PCIe PMU, Cổng gốc mục tiêu có thể
     được chọn bằng cách định cấu hình "cổng" 16 bit-bitmap. Nhiều cổng có thể được
     được chọn cho các sự kiện lớp AP và chỉ có thể chọn một cổng cho
     Sự kiện lớp TL/DL.

Ví dụ: nếu Cổng gốc mục tiêu là 0000:00:00.0 (x8 làn), bit0 của
     bitmap nên được đặt, port=0x1; nếu Cổng gốc mục tiêu là 0000:00:04.0 (x4
     làn đường), bit8 được đặt, port=0x100; nếu cả hai Cổng gốc này đều là
     được giám sát, cổng=0x101.

Ví dụ sử dụng perf::

Chỉ số $# perf -e hisi_pcie0_core0/rx_mwr_latency,port=0x1/ ngủ 5

- bạn trai

Bộ lọc "bdf" chỉ có thể được sử dụng trong các sự kiện băng thông, Điểm cuối đích là
     được chọn bằng cách định cấu hình BDF thành "bdf". Bộ đếm chỉ đếm băng thông của
     thông báo được yêu cầu bởi Điểm cuối đích.

Ví dụ: "bdf=0x3900" nghĩa là BDF của Điểm cuối đích là 0000:39:00.0.

Ví dụ sử dụng perf::

$# perf chỉ số -e hisi_pcie0_core0/rx_mrd_flux,bdf=0x3900/ ngủ 5

2. Bộ lọc kích hoạt

Thống kê sự kiện bắt đầu khi độ dài TLP lần đầu tiên lớn hơn/nhỏ hơn
   hơn điều kiện kích hoạt. Bạn có thể đặt điều kiện kích hoạt bằng cách viết
   "trig_len" và đặt chế độ kích hoạt bằng cách viết "trig_mode". Bộ lọc này có thể
   chỉ được sử dụng trong các sự kiện băng thông.

Ví dụ: "trig_len=4" có nghĩa là điều kiện kích hoạt là 2^4 DW, "trig_mode=0"
   nghĩa là số liệu thống kê bắt đầu khi độ dài TLP > điều kiện kích hoạt, "trig_mode=1"
   có nghĩa là bắt đầu khi độ dài TLP < điều kiện.

Ví dụ sử dụng perf::

$# perf thống kê -e hisi_pcie0_core0/rx_mrd_flux,port=0xffff,trig_len=0x4,trig_mode=1/ ngủ 5

3. Bộ lọc ngưỡng

Bộ đếm đếm khi độ dài TLP trong phạm vi được chỉ định. Bạn có thể thiết lập
   ngưỡng bằng cách viết "thr_len" và đặt chế độ ngưỡng bằng cách viết
   "thr_mode". Bộ lọc này chỉ có thể được sử dụng trong các sự kiện băng thông.

Ví dụ: "thr_len=4" nghĩa là ngưỡng là 2^4 DW, "thr_mode=0" nghĩa là
   bộ đếm đếm khi chiều dài TLP >= ngưỡng và "thr_mode=1" nghĩa là đếm
   khi chiều dài TLP < ngưỡng.

Ví dụ sử dụng perf::

$# perf thống kê -e hisi_pcie0_core0/rx_mrd_flux,port=0xffff,thr_len=0x4,thr_mode=1/ ngủ 5

4. Bộ lọc chiều dài TLP

Khi đếm băng thông, dữ liệu có thể bao gồm một số phần nhất định của TLP
   gói. Bạn có thể chỉ định nó thông qua "len_mode":

- 2'b00: Reserved (Không sử dụng vì hành vi không được xác định)
   - 2'b01: Băng thông của payload TLP
   - 2'b10: Băng thông của header TLP
   - 2'b11: Băng thông của cả payload và header TLP

Ví dụ: "len_mode=2" có nghĩa là chỉ tính băng thông của tiêu đề TLP
   và "len_mode=3" có nghĩa là dữ liệu băng thông cuối cùng bao gồm cả TLP
   tiêu đề và tải trọng. Giá trị mặc định nếu không được chỉ định là 2'b11.

Ví dụ sử dụng perf::

$# perf stat -e hisi_pcie0_core0/rx_mrd_flux,port=0xffff,len_mode=0x1/ ngủ 5
