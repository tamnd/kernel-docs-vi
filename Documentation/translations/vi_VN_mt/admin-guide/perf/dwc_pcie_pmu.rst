.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/dwc_pcie_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============================================================================
Synopsys DesignWare Cores (DWC) Bộ giám sát hiệu suất PCIe (PMU)
======================================================================

Lõi DesignWare (DWC) PCIe PMU
===============================

PMU là khối thanh ghi không gian cấu hình PCIe được cung cấp bởi mỗi PCIe Root
Cổng trong Khả năng mở rộng dành riêng cho nhà cung cấp có tên RAS D.E.S (Gỡ lỗi, Lỗi
tiêm và thống kê).

Đúng như tên gọi, khả năng RAS DES hỗ trợ cấp hệ thống
gỡ lỗi, chèn lỗi AER và thu thập số liệu thống kê. Để tạo điều kiện thuận lợi
bộ sưu tập số liệu thống kê, bộ điều khiển Synopsys DesignWare Cores PCIe
cung cấp hai tính năng sau:

- một bộ đếm 64-bit dành cho Phân tích dựa trên thời gian (thông lượng dữ liệu RX/TX và
  thời gian dành cho mỗi trạng thái LTSSM công suất thấp) và
- một bộ đếm 32 bit cho mỗi sự kiện để đếm sự kiện (có lỗi và không có lỗi
  sự kiện cho một làn đường được chỉ định)

Lưu ý: Không có ngắt khi tràn bộ đếm.

Phân tích dựa trên thời gian
-------------------

Sử dụng tính năng này bạn có thể lấy thông tin về dữ liệu RX/TX
thông lượng và thời gian ở mỗi trạng thái LTSSM công suất thấp của bộ điều khiển.
PMU đo dữ liệu theo hai loại:

- Group#0: Phần trăm thời gian bộ điều khiển ở trạng thái LTSSM.
- Group#1: Lượng dữ liệu đã xử lý (Đơn vị 16 byte).

Quầy sự kiện làn đường
-------------------

Sử dụng tính năng này bạn có thể nhận được thông tin Lỗi và Không Lỗi trong
làn đường cụ thể của bộ điều khiển. Sự kiện PMU được chọn bởi tất cả:

- Nhóm tôi
- Sự kiện j trong Nhóm i
- Ngõ k

Một số sự kiện chỉ tồn tại đối với các cấu hình cụ thể.

Trình điều khiển DesignWare Cores (DWC) PCIe PMU
=======================================

Trình điều khiển này bổ sung các thiết bị PMU cho mỗi Cổng gốc PCIe được đặt tên dựa trên SBDF của
Cổng gốc. Ví dụ,

0001:30:03.0 Cầu PCI: Thiết bị 1ded:8000 (rev 01)

tên thiết bị PMU cho Cổng gốc này là dwc_rootport_13018.

Trình điều khiển DWC PCIe PMU đăng ký trình điều khiển PMU hoàn hảo, cung cấp
mô tả các sự kiện có sẵn và các tùy chọn cấu hình trong sysfs, xem
/sys/bus/event_source/devices/dwc_rootport_{sbdf}.

Thư mục "format" mô tả định dạng của các trường cấu hình của
cấu trúc perf_event_attr. Thư mục "sự kiện" cung cấp cấu hình
mẫu cho tất cả các sự kiện được ghi lại.  Ví dụ,
"rx_pcie_tlp_data_payload" tương đương với "eventid=0x21,type=0x0".

Lệnh "danh sách hoàn hảo" sẽ liệt kê các sự kiện có sẵn từ sysfs, ví dụ:::

Danh sách $# perf | grep dwc_rootport
    <...>
    dwc_rootport_13018/Rx_PCIe_TLP_Data_Payload/ [Sự kiện Kernel PMU]
    <...>
    dwc_rootport_13018/rx_memory_read,lane=?/ [Sự kiện Kernel PMU]

Phân tích dựa trên thời gian Sử dụng sự kiện
-------------------------------

Ví dụ sử dụng cách tính tải trọng dữ liệu PCIe RX TLP (Đơn vị byte)::

Chỉ số $# perf -a -e dwc_rootport_13018/Rx_PCIe_TLP_Data_Payload/

Băng thông RX/TX trung bình có thể được tính bằng công thức sau:

Băng thông PCIe RX = rx_pcie_tlp_data_payload / Measure_Time_Window
    Băng thông PCIe TX = tx_pcie_tlp_data_payload / Measure_Time_Window

Sử dụng làn đường sự kiện
-------------------------------

Mỗi làn có cùng một bộ sự kiện và để tránh tạo danh sách hàng trăm
trong số các sự kiện, người dùng cần chỉ định rõ ràng ID làn đường, ví dụ::

$# perf chỉ số -a -e dwc_rootport_13018/rx_memory_read,lane=4/

Trình điều khiển không hỗ trợ lấy mẫu, do đó "bản ghi hoàn hảo" sẽ không
làm việc. Phiên hoàn thiện mỗi tác vụ (không có "-a") không được hỗ trợ.
