.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/fujitsu_uncore_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Bộ giám sát hiệu suất Uncore của Fujitsu (PMU)
================================================

Trình điều khiển này hỗ trợ các PMU Uncore MAC và các PMU Uncore PCI được tìm thấy
trong chip Fujitsu.
Mỗi MAC PMU trên các chip này được hiển thị dưới dạng PMU hoàn hảo không lõi với tên thiết bị
mac_iod<iod>_mac<mac>_ch<ch>.
Và mỗi PCI PMU trên các chip này được hiển thị dưới dạng PMU hoàn hảo không lõi với tên thiết bị
pci_iod<iod>_pci<pci>.

Trình điều khiển cung cấp mô tả về các sự kiện và cấu hình có sẵn của nó
tùy chọn trong sysfs, xem /sys/bus/event_sources/devices/mac_iod<iod>_mac<mac>_ch<ch>/
và /sys/bus/event_sources/devices/pci_iod<iod>_pci<pci>/.
Trình điều khiển này xuất:

- các định dạng, được sử dụng bởi không gian người dùng hoàn hảo và các công cụ khác để định cấu hình sự kiện
- sự kiện, được sử dụng bởi không gian người dùng hoàn hảo và các công cụ khác để tạo sự kiện
  mang tính biểu tượng, ví dụ::

chỉ số hoàn hảo -a -e mac_iod0_mac0_ch0/event=0x21/ ls
    chỉ số hoàn hảo -a -e pci_iod0_pci0/event=0x24/ ls

- cpumask, được sử dụng bởi không gian người dùng hoàn hảo và các công cụ khác để biết CPU nào
  để mở các sự kiện

Trình điều khiển này hỗ trợ các sự kiện sau cho MAC:

- chu kỳ
  Sự kiện này đếm chu kỳ MAC ở tần số MAC.
- số lần đọc
  Sự kiện này đếm số lượng yêu cầu đọc tới MAC.
- yêu cầu đọc-đếm
  Sự kiện này đếm số lượng yêu cầu đọc bao gồm cả việc thử lại MAC.
- đọc-đếm-trả về
  Sự kiện này đếm số lượng phản hồi để đọc yêu cầu tới MAC.
- đọc-đếm-yêu cầu-pftgt
  Sự kiện này đếm số lượng yêu cầu đọc bao gồm thử lại với PFTGT
  cờ.
- đọc-đếm-yêu cầu-bình thường
  Sự kiện này đếm số lượng yêu cầu đọc bao gồm cả thử lại mà không có PFTGT
  cờ.
- đọc-đếm-trả lại-pftgt-hit
  Sự kiện này đếm số lượng phản hồi cho các yêu cầu đọc đạt đến
  Bộ đệm PFTGT.
- đọc-đếm-trả lại-pftgt-miss
  Sự kiện này đếm số lượng phản hồi cho các yêu cầu đọc bị thiếu
  Bộ đệm PFTGT.
- đọc-chờ
  Sự kiện này tính các yêu cầu đọc chưa xử lý do bộ điều khiển bộ nhớ DDR đưa ra
  mỗi chu kỳ.
- số lần ghi
  Sự kiện này đếm số lượng yêu cầu ghi vào MAC (bao gồm cả số 0 yêu cầu ghi,
  ghi toàn bộ, viết một phần, hủy bỏ ghi).
- viết-đếm-viết
  Sự kiện này đếm số lượng yêu cầu ghi đầy đủ vào MAC (không bao gồm
  không viết).
- viết-đếm-pwrite
  Sự kiện này đếm số lượng yêu cầu ghi một phần vào MAC.
- bộ nhớ-đọc-đếm
  Sự kiện này đếm số lượng yêu cầu đọc từ MAC vào bộ nhớ.
- bộ nhớ-ghi-đếm
  Sự kiện này đếm số lượng yêu cầu ghi đầy đủ từ MAC vào bộ nhớ.
- bộ nhớ-pwrite-count
  Sự kiện này đếm số lượng yêu cầu ghi một phần từ MAC vào bộ nhớ.
- ea-mac
  Sự kiện này tính mức tiêu thụ năng lượng của MAC.
- ea-bộ nhớ
  Sự kiện này tính mức tiêu thụ năng lượng của bộ nhớ.
- ea-bộ nhớ-mac-ghi
  Sự kiện này đếm số lượng yêu cầu ghi từ MAC vào bộ nhớ.
- ea-ha
  Sự kiện này tính mức tiêu thụ năng lượng của HA.

'ea' là tên viết tắt của 'Máy phân tích năng lượng'.

Ví dụ để sử dụng với perf::

chỉ số hoàn hảo -e mac_iod0_mac0_ch0/ea-mac/ ls

Và trình điều khiển này hỗ trợ các sự kiện sau cho PCI:

- pci-port0-chu kỳ
  Sự kiện này đếm chu kỳ PCI ở tần số PCI trong cổng0.
- pci-port0-đọc-đếm
  Sự kiện này đếm các giao dịch đã đọc để truyền dữ liệu trong cổng0.
- pci-port0-đọc-đếm-bus
  Sự kiện này tính các giao dịch đã đọc để sử dụng bus trong cổng0.
- pci-port0-ghi-đếm
  Sự kiện này đếm các giao dịch ghi để truyền dữ liệu trong cổng0.
- pci-port0-write-count-bus
  Sự kiện này đếm các giao dịch ghi để sử dụng bus trong port0.
- chu kỳ pci-port1
  Sự kiện này đếm chu kỳ PCI ở tần số PCI trong cổng1.
- pci-port1-đọc-đếm
  Sự kiện này đếm các giao dịch đã đọc để truyền dữ liệu trong cổng 1.
- pci-port1-đọc-đếm-bus
  Sự kiện này tính các giao dịch đã đọc để sử dụng bus ở cổng 1.
- pci-port1-ghi-đếm
  Sự kiện này đếm các giao dịch ghi để truyền dữ liệu trong cổng 1.
- pci-port1-write-count-bus
  Sự kiện này đếm các giao dịch ghi để sử dụng bus trong cổng 1.
- ea-pci
  Sự kiện này tính mức tiêu thụ năng lượng của PCI.

'ea' là tên viết tắt của 'Máy phân tích năng lượng'.

Ví dụ để sử dụng với perf::

chỉ số hoàn hảo -e pci_iod0_pci0/ea-pci/ ls

Do đây là các PMU không lõi nên trình điều khiển không hỗ trợ lấy mẫu, do đó
"Bản ghi hoàn hảo" sẽ không hoạt động. Phiên hoàn thiện mỗi nhiệm vụ không được hỗ trợ.