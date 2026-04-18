.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/memory-devices/ti-emif.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Trình điều khiển bộ điều khiển TI EMIF SDRAM
============================================

Tác giả
======
Aneesh V <aneesh@ti.com>

Vị trí
========
trình điều khiển/bộ nhớ/emif.c

SoC được hỗ trợ:
===============
TI OMAP44xx
TI OMAP54xx

Tùy chọn cấu hình menu:
==================
Trình điều khiển thiết bị
	Thiết bị bộ nhớ
		Trình điều khiển EMIF của Texas Instruments

Sự miêu tả
===========
Trình điều khiển này dành cho mô-đun EMIF có sẵn trong Texas Instruments
SoC. EMIF là bộ điều khiển SDRAM, dựa trên bản sửa đổi của nó,
hỗ trợ một hoặc nhiều giao thức DDR2, DDR3 và LPDDR2 SDRAM.
Trình điều khiển này hiện chỉ xử lý các bộ nhớ LPDDR2. các
chức năng của trình điều khiển bao gồm cấu hình lại thời gian AC
các thông số và các cài đặt khác trong tần số, điện áp và
thay đổi nhiệt độ

Dữ liệu nền tảng (xem include/linux/platform_data/emif_plat.h)
===========================================================
Chi tiết thiết bị DDR và phụ thuộc bo mạch khác và phụ thuộc SoC
thông tin có thể được truyền qua dữ liệu nền tảng (struct emif_platform_data)

- Chi tiết thiết bị DDR: 'struct ddr_device_info'
- Định giờ AC của thiết bị: 'struct lpddr2_timings' và 'struct lpddr2_min_tck'
- Cấu hình tùy chỉnh: tùy chọn chính sách có thể tùy chỉnh thông qua
  'cấu trúc emif_custom_configs'
- Sửa đổi IP
- Loại PHY

Giao diện với thế giới bên ngoài
===============================
Trình điều khiển EMIF đăng ký thông báo thay đổi điện áp và tần số
ảnh hưởng đến EMIF và thực hiện các hành động thích hợp khi chúng được gọi.

- freq_pre_notify_handling()
- freq_post_notify_handling()
- volt_notify_handling()

Gỡ lỗi
=======
Trình điều khiển tạo hai mục gỡ lỗi cho mỗi thiết bị.

- reccache_dump : kết xuất các giá trị đăng ký được tính toán và lưu cho tất cả
  tần số được sử dụng cho đến nay.
- mr4 : giá trị được thăm dò cuối cùng của thanh ghi MR4 trong thiết bị LPDDR2. MR4
  cho biết mức nhiệt độ hiện tại của thiết bị.