.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/thunderx2-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
Bộ giám sát hiệu suất SoC Cavium ThunderX2 (PMU UNCORE)
===================================================================

ThunderX2 SoC PMU bao gồm các ổ cắm độc lập, toàn hệ thống,
Các PMU như Bộ nhớ đệm cấp 3 (L3C), Bộ điều khiển bộ nhớ DDR4 (DMC) và
Kết nối bộ xử lý kết hợp Cavium (CCPI2).

DMC có 8 kênh xen kẽ và L3C có 16 ô xen kẽ.
Các sự kiện được tính cho kênh mặc định (tức là kênh 0) và được chia theo tỷ lệ
vào tổng số kênh/ô.

DMC và L3C hỗ trợ tới 4 bộ đếm, trong khi CCPI2 hỗ trợ tới 8 bộ đếm.
quầy. Bộ đếm được lập trình độc lập cho các sự kiện khác nhau và
có thể được bắt đầu và dừng riêng lẻ. Không có bộ đếm nào hỗ trợ
ngắt tràn. Bộ đếm DMC và L3C là 32 bit và đọc cứ sau 2 giây.
Bộ đếm CCPI2 là 64-bit và được cho là không bị tràn trong hoạt động bình thường.

Trình điều khiển PMU UNCORE (hoàn hảo):

Trình điều khiển Thunderx2_pmu đăng ký PMU hiệu suất trên mỗi ổ cắm cho DMC và
Thiết bị L3C.  Mỗi PMU có thể được sử dụng để đếm tối đa 4 (DMC/L3C) hoặc tối đa 8
(CCPI2) sự kiện đồng thời. Các Ban QLDA cung cấp bản mô tả về
các sự kiện và tùy chọn cấu hình có sẵn trong sysfs, xem
/sys/bus/event_source/devices/uncore_<l3c_S/dmc_S/ccpi2_S/>; S là id ổ cắm.

Trình điều khiển không hỗ trợ lấy mẫu, do đó "bản ghi hoàn hảo" sẽ không
làm việc. Phiên hoàn thiện mỗi nhiệm vụ cũng không được hỗ trợ.

Ví dụ::

# perf stat -a -e uncore_dmc_0/cnt_cycles/ ngủ 1

Chỉ số # perf -a -e \
  uncore_dmc_0/cnt_cycles/,\
  uncore_dmc_0/data_transfers/,\
  uncore_dmc_0/read_txns/,\
  uncore_dmc_0/write_txns/ ngủ 1

Chỉ số # perf -a -e \
  uncore_l3c_0/read_request/,\
  uncore_l3c_0/read_hit/,\
  uncore_l3c_0/inv_request/,\
  uncore_l3c_0/inv_hit/ ngủ 1
