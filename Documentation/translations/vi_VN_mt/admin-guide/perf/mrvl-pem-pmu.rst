.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/mrvl-pem-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================================
Bộ giám sát hiệu suất Marvell Odyssey PEM (PMU UNCORE)
=================================================================

Các đơn vị giao diện nhanh PCI (PEM) được liên kết với một đơn vị tương ứng
đơn vị giám sát. Điều này bao gồm các bộ đếm hiệu suất để theo dõi các
đặc điểm của dữ liệu được truyền qua liên kết PCIe.

Các quầy theo dõi các giao dịch trong và ngoài nước
bao gồm các bộ đếm riêng biệt cho các TLP đã đăng/không đăng/hoàn thành.
Ngoài ra, các yêu cầu đọc bộ nhớ vào và ra cùng với
độ trễ cũng có thể được theo dõi. Sự kiện Dịch vụ dịch địa chỉ(ATS)
chẳng hạn như Bản dịch ATS, Yêu cầu trang ATS, Vô hiệu hóa ATS cùng với
độ trễ tương ứng của chúng cũng được theo dõi.

Có bộ đếm 64 bit riêng biệt để đo lường việc đăng/không đăng/hoàn thành
tlps trong các giao dịch trong và ngoài nước. Các sự kiện ATS được đo bằng
bộ đếm khác nhau.

Trình điều khiển PMU hiển thị các sự kiện và tùy chọn định dạng có sẵn trong sysfs,
/sys/bus/event_source/devices/mrvl_pcie_rc_pmu_<>/events/
/sys/bus/event_source/devices/mrvl_pcie_rc_pmu_<>/format/

Ví dụ::

Danh sách # perf | grep mrvl_pcie_rc_pmu
  mrvl_pcie_rc_pmu_<>/ats_inv/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ats_inv_latency/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ats_pri/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ats_pri_latency/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ats_trans/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ats_trans_latency/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_inflight/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_reads/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_req_no_ro_ebus/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_req_no_ro_ncb/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_tlp_cpl_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_tlp_dwords_cpl_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_tlp_dwords_npr/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_tlp_dwords_pr/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_tlp_npr/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ib_tlp_pr/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_inflight_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_merges_cpl_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_merges_npr_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_merges_pr_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_reads_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_tlp_cpl_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_tlp_dwords_cpl_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_tlp_dwords_npr_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_tlp_dwords_pr_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_tlp_npr_partid/ [Sự kiện hạt nhân PMU]
  mrvl_pcie_rc_pmu_<>/ob_tlp_pr_partid/ [Sự kiện hạt nhân PMU]


Chỉ số # perf -e ib_inflight,ib_reads,ib_req_no_ro_ebus,ib_req_no_ro_ncb <khối lượng công việc>
