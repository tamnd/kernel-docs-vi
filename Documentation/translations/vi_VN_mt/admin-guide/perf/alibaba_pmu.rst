.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/alibaba_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
Đơn vị giám sát hiệu suất Uncore T-Head SoC của Alibaba (PMU)
===================================================================

Yitian 710, được sản xuất theo đơn đặt hàng của doanh nghiệp phát triển chip của Tập đoàn Alibaba,
T-Head, triển khai PMU không lõi để gỡ lỗi hiệu năng và chức năng cho
tạo điều kiện thuận lợi cho việc bảo trì hệ thống.

Đường lái xe hệ thống phụ DDR (DRW) Trình điều khiển PMU
========================================================

Yitian 710 sử dụng tám kênh DDR5/4, bốn kênh trên mỗi khuôn. Mỗi kênh DDR5
độc lập với những người khác để phục vụ các yêu cầu bộ nhớ hệ thống. Và một chiếc DDR5
kênh được chia thành hai kênh con độc lập. Đường lái xe hệ thống phụ DDR
triển khai các PMU riêng biệt cho từng kênh phụ để giám sát hiệu suất khác nhau
số liệu.

Các thiết bị Driveway PMU được đặt tên là ali_drw_<sys_base_addr> với sự hoàn hảo.
Ví dụ: ali_drw_21000 và ali_drw_21080 là hai thiết bị PMU dành cho hai người
các kênh phụ của cùng một kênh ở khuôn 0. Và thiết bị PMU của khuôn 1 là
có tiền tố là ali_drw_400XXXXX, ví dụ: ali_drw_40021000.

Mỗi kênh phụ có tổng cộng 36 bộ đếm PMU, được phân loại thành
bốn nhóm:

- Nhóm 0: Bộ đếm chu trình PMU. Nhóm này có một cặp quầy
  pmu_cycle_cnt_low và pmu_cycle_cnt_high, được sử dụng làm số chu kỳ
  dựa trên đồng hồ lõi DDRC.

- Nhóm 1: Bộ đếm băng thông PMU. Nhóm này có 8 quầy được sử dụng
  để đếm tổng số truy cập của tám nhóm ngân hàng trong một
  thứ hạng đã chọn hoặc bốn thứ hạng riêng biệt trong 4 quầy đầu tiên. Căn cứ
  đơn vị chuyển giao là 64B.

- Nhóm 2: Bộ đếm thử lại PMU. Nhóm này có 10 quầy, có ý định
  đếm tổng số lần thử lại của từng loại lỗi không thể sửa được.

- Nhóm 3: Bộ đếm thông dụng PMU. Nhóm này có 16 bộ đếm được sử dụng
  để đếm các sự kiện phổ biến.

Hiện tại, trình điều khiển Driveway PMU chỉ sử dụng các bộ đếm ở nhóm 0 và nhóm 3.

Bộ điều khiển DDR (DDRCTL) và DDR PHY kết hợp để tạo ra một giải pháp hoàn chỉnh
để kết nối bus ứng dụng SoC với các thiết bị bộ nhớ DDR. DDRCTL
nhận các giao dịch Giao diện máy chủ (HIF) do Synopsys xác định tùy chỉnh.
Các giao dịch này được xếp hàng nội bộ và được lên lịch để truy cập trong khi
đáp ứng các yêu cầu về thời gian của giao thức SDRAM, mức độ ưu tiên giao dịch và
sự phụ thuộc giữa các giao dịch. DDRCTL lần lượt đưa ra các lệnh trên
Giao diện DDR PHY (DFI) với mô-đun PHY, khởi chạy và thu thập dữ liệu
đến và đi từ SDRAM. Các PMU đường lái xe có logic phần cứng để thu thập
thống kê và tín hiệu ghi nhật ký hiệu suất trên HIF, DFI, v.v.

Bằng cách đếm các lệnh READ, WRITE và RMW được gửi đến DDRC thông qua HIF
giao diện, chúng tôi có thể tính toán băng thông. Ví dụ sử dụng bộ nhớ đếm
băng thông dữ liệu::

chỉ số hoàn hảo \
    -e ali_drw_21000/hif_wr/ \
    -e ali_drw_21000/hif_rd/ \
    -e ali_drw_21000/hif_rmw/ \
    -e ali_drw_21000/cycle/ \
    -e ali_drw_21080/hif_wr/ \
    -e ali_drw_21080/hif_rd/ \
    -e ali_drw_21080/hif_rmw/ \
    -e ali_drw_21080/cycle/ \
    -e ali_drw_23000/hif_wr/ \
    -e ali_drw_23000/hif_rd/ \
    -e ali_drw_23000/hif_rmw/ \
    -e ali_drw_23000/cycle/ \
    -e ali_drw_23080/hif_wr/ \
    -e ali_drw_23080/hif_rd/ \
    -e ali_drw_23080/hif_rmw/ \
    -e ali_drw_23080/cycle/ \
    -e ali_drw_25000/hif_wr/ \
    -e ali_drw_25000/hif_rd/ \
    -e ali_drw_25000/hif_rmw/ \
    -e ali_drw_25000/cycle/ \
    -e ali_drw_25080/hif_wr/ \
    -e ali_drw_25080/hif_rd/ \
    -e ali_drw_25080/hif_rmw/ \
    -e ali_drw_25080/cycle/ \
    -e ali_drw_27000/hif_wr/ \
    -e ali_drw_27000/hif_rd/ \
    -e ali_drw_27000/hif_rmw/ \
    -e ali_drw_27000/cycle/ \
    -e ali_drw_27080/hif_wr/ \
    -e ali_drw_27080/hif_rd/ \
    -e ali_drw_27080/hif_rmw/ \
    -e ali_drw_27080/cycle/ -- ngủ 10

Ví dụ về cách đếm tất cả băng thông đọc/ghi bộ nhớ theo số liệu::

chỉ số hoàn hảo -M ddr_read_bandwidth.all -- ngủ 10
  chỉ số hoàn hảo -M ddr_write_bandwidth.all -- ngủ 10

Băng thông DRAM trung bình có thể được tính như sau:

- Đọc băng thông = perf_hif_rd * DDRC_WIDTH * DDRC_Freq / DDRC_Cycle
- Ghi băng thông = (perf_hif_wr + perf_hif_rmw)*DDRC_WIDTH*DDRC_Freq/DDRC_Cycle

Ở đây, DDRC_WIDTH = 64 byte.

Trình điều khiển hiện tại không hỗ trợ lấy mẫu. Vậy "kỷ lục hoàn hảo" là
không được hỗ trợ.  Ngoài ra, việc đính kèm vào một tác vụ cũng không được hỗ trợ vì tất cả các sự kiện đều
uncore.
