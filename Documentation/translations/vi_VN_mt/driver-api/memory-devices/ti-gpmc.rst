.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/memory-devices/ti-gpmc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
GPMC (Bộ điều khiển bộ nhớ đa năng)
============================================

GPMC là bộ điều khiển bộ nhớ hợp nhất dành riêng cho giao tiếp bên ngoài
thiết bị bộ nhớ như

* SRAM không đồng bộ giống như bộ nhớ và ứng dụng cụ thể được tích hợp
   các thiết bị mạch.
 * Thiết bị flash NOR không đồng bộ, đồng bộ và chế độ trang
   đèn flash NAND
 * Thiết bị Pseudo-SRAM

GPMC được tìm thấy trên SoC của Texas Instruments (dựa trên OMAP)
Chi tiết IP: ZZ0000ZZ phần 7.1


Tính toán thời gian chung GPMC:
================================

GPMC có một số thời gian nhất định phải được lập trình để phù hợp
hoạt động của thiết bị ngoại vi, trong khi thiết bị ngoại vi có một bộ khác
thời gian. Để có thể làm việc ngoại vi với gpmc, định thời gian ngoại vi phải
dịch sang dạng gpmc có thể hiểu được. Cách nó phải như vậy
dịch phụ thuộc vào thiết bị ngoại vi được kết nối. Ngoài ra còn có một
sự phụ thuộc của thời gian gpmc nhất định vào tần số đồng hồ gpmc. Do đó một
thói quen tính thời gian chung đã được phát triển để đạt được các yêu cầu trên.

Quy trình chung cung cấp một phương pháp chung để tính toán thời gian gpmc
từ thời gian ngoại vi gpmc. Các trường struct gpmc_device_timings phải
được cập nhật thời gian từ biểu dữ liệu của thiết bị ngoại vi
đã kết nối với gpmc. Một số bộ định thời ngoại vi có thể được cung cấp
theo thời gian hoặc theo chu kỳ, việc cung cấp để xử lý tình huống này đã được
được cung cấp (tham khảo định nghĩa struct gpmc_device_timings). Có thể vậy
xảy ra trường hợp không có thời gian được chỉ định bởi biểu dữ liệu ngoại vi
trong cấu trúc thời gian, trong kịch bản này, hãy thử tương quan giữa các thiết bị ngoại vi
thời gian theo thời gian có sẵn. Nếu điều đó không hiệu quả, hãy thử thêm một cái mới
trường theo yêu cầu của thiết bị ngoại vi, hướng dẫn thói quen tính thời gian chung để
xử lý nó, đảm bảo rằng nó không phá vỡ bất kỳ thứ gì hiện có.
Sau đó có thể có trường hợp bảng dữ liệu ngoại vi không đề cập đến
một số trường nhất định của struct gpmc_device_timings, loại bỏ các mục đó.

Quy trình định giờ chung đã được xác minh là hoạt động bình thường trên
nhiều thiết bị ngoại vi của onenand và tusb6010.

Lưu ý: quy trình tính thời gian chung đã được phát triển dựa trên
về sự hiểu biết về thời gian gpmc, thời gian ngoại vi, có sẵn
thói quen định thời gian tùy chỉnh, một loại kỹ thuật đảo ngược không có
hầu hết các bảng dữ liệu và phần cứng (chính xác là không có bảng dữ liệu nào được hỗ trợ
trong tuyến chính có quy trình định giờ tùy chỉnh) và bằng mô phỏng.

phụ thuộc thời gian gpmc vào thời gian ngoại vi:

[<gpmc_timing>: <thời gian ngoại vi1>, <thời gian ngoại vi2> ...]

1. chung

cs_on:
	t_ceasu
lời khuyên:
	t_avdasu, t_ceavd

2. đồng bộ chung

đồng bộ_clk:
	cạch
trang_burst_access:
	t_bacc
clk_activation:
	t_ces, t_avds

3. đọc kết hợp không đồng bộ

adv_rd_off:
	t_avdp_r
ôi_on:
	t_oeasu, t_avdh
truy cập:
	t_iaa, t_oe, t_ce, t_aa
rd_cycle:
	t_rd_cycle, t_cez_r, t_oez

4. đọc không đồng bộ không trộn lẫn

adv_rd_off:
	t_avdp_r
ôi_on:
	t_oasu
truy cập:
	t_iaa, t_oe, t_ce, t_aa
rd_cycle:
	t_rd_cycle, t_cez_r, t_oez

5. đọc đồng bộ hóa

adv_rd_off:
	t_avdp_r, t_avdh
ôi_on:
	t_oeasu, t_ach, cyc_aavdh_oe
truy cập:
	t_iaa, cyc_iaa, cyc_oe
rd_cycle:
	t_cez_r, t_oez, t_ce_rdyz

6. đọc đồng bộ không trộn lẫn

adv_rd_off:
	t_avdp_r
ôi_on:
	t_oasu
truy cập:
	t_iaa, cyc_iaa, cyc_oe
rd_cycle:
	t_cez_r, t_oez, t_ce_rdyz

7. viết không đồng bộ

Adv_wr_off:
	t_avdp_w
we_on, wr_data_mux_bus:
	t_weasu, t_aavdh, cyc_aavhd_we
chúng tôi_off:
	t_wpl
cs_wr_off:
	t_wph
wr_cycle:
	t_cez_w, t_wr_cycle

8. viết không đồng bộ không trộn lẫn

Adv_wr_off:
	t_avdp_w
we_on, wr_data_mux_bus:
	t_weasu
chúng tôi_off:
	t_wpl
cs_wr_off:
	t_wph
wr_cycle:
	t_cez_w, t_wr_cycle

9. viết đồng bộ muxed

Adv_wr_off:
	t_avdp_w, t_avdh
we_on, wr_data_mux_bus:
	t_weasu, t_rdyo, t_aavdh, cyc_aavhd_we
chúng tôi_off:
	t_wpl, cyc_wpl
cs_wr_off:
	t_wph
wr_cycle:
	t_cez_w, t_ce_rdyz

10. ghi đồng bộ không trộn lẫn

Adv_wr_off:
	t_avdp_w
we_on, wr_data_mux_bus:
	t_weasu, t_rdyo
chúng tôi_off:
	t_wpl, cyc_wpl
cs_wr_off:
	t_wph
wr_cycle:
	t_cez_w, t_ce_rdyz


Lưu ý:
  Nhiều cách định thời của gpmc phụ thuộc vào các cách định thời của gpmc khác (một số
  thời gian gpmc hoàn toàn phụ thuộc vào thời gian gpmc khác, lý do là
  một số thời gian gpmc bị thiếu ở trên) và nó sẽ dẫn đến
  sự phụ thuộc gián tiếp của thời gian ngoại vi vào thời gian gpmc khác với
  đã đề cập ở trên, hãy tham khảo lịch trình thời gian để biết thêm chi tiết. Để biết những gì
  những thời gian ngoại vi này tương ứng với, vui lòng xem giải thích trong
  định nghĩa cấu trúc gpmc_device_timings. Và để biết thời gian gpmc hãy tham khảo
  Chi tiết IP (liên kết ở trên).