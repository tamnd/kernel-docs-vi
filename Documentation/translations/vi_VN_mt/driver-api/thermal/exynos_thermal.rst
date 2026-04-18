.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/exynos_thermal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Trình điều khiển hạt nhân exynos_tmu
========================

Chip được hỗ trợ:

* ARM Samsung Exynos4, dòng SoC Exynos5

Bảng dữ liệu: Không có sẵn công khai

Tác giả: Donggeun Kim <dg77.kim@samsung.com>
Tác giả: Amit Daniel <amit.daniel@samsung.com>

Bộ điều khiển TMU Mô tả:
---------------------------

Trình điều khiển này cho phép đọc nhiệt độ bên trong dòng SoC Samsung Exynos4/5.

Chip chỉ hiển thị giá trị mã nhiệt độ 8 bit đo được
thông qua một sổ đăng ký.
Nhiệt độ có thể được lấy từ mã nhiệt độ.
Có ba phương trình chuyển đổi từ nhiệt độ sang mã nhiệt độ.

Ba phương trình là:
  1. Cắt tỉa hai điểm::

Tc = (T - 25) * (TI2 - TI1) / (85 - 25) + TI1

2. Cắt tỉa một điểm::

Tc = T + TI1 - 25

3. Không cắt tỉa::

Tc = T + 50

Tc:
       Mã nhiệt độ, T: Nhiệt độ,
  TI1:
       Thông tin cắt xén ở 25 độ C (được lưu tại thanh ghi TRIMINFO)
       Mã nhiệt độ đo ở 25 độ C không thay đổi
  TI2:
       Thông tin cắt xén ở 85 độ C (được lưu tại thanh ghi TRIMINFO)
       Mã nhiệt độ đo được ở 85 độ C không thay đổi

TMU(Bộ quản lý nhiệt) trong Exynos4/5 tạo ra ngắt
khi nhiệt độ vượt quá mức xác định trước.
Số ngưỡng tối đa có thể cấu hình là năm.
Các mức ngưỡng được xác định như sau::

Level_0: nhiệt độ hiện tại > trigger_level_0 + ngưỡng
  Cấp_1: nhiệt độ hiện tại > trigger_level_1 + ngưỡng
  Cấp_2: nhiệt độ hiện tại > trigger_level_2 + ngưỡng
  Cấp_3: nhiệt độ hiện tại > trigger_level_3 + ngưỡng

Ngưỡng và mỗi trigger_level được đặt
thông qua các thanh ghi tương ứng.

Khi xảy ra gián đoạn, trình điều khiển này sẽ thông báo cho khung nhiệt kernel
với hàm exynos_report_trigger.
Mặc dù có thể đặt điều kiện ngắt cho cấp_0,
nó có thể được sử dụng để đồng bộ hóa hoạt động làm mát.

Mô tả trình điều khiển TMU:
-----------------------

Trình điều khiển nhiệt exynos có cấu trúc như sau::

Khung nhiệt lõi lõi
				(thermal_core.c, step_wise.c, cpufreq_cooling.c)
								^
								|
								|
  Dữ liệu cấu hình TMU -----> Trình điều khiển TMU <----> Trình bọc nhiệt Exynos Core
  (exynos_tmu_data.c) (exynos_tmu.c) (exynos_thermal_common.c)
  (exynos_tmu_data.h) (exynos_tmu.h) (exynos_thermal_common.h)

a) Dữ liệu cấu hình TMU:
		Điều này bao gồm các offset/bitfield thanh ghi TMU
		được mô tả thông qua cấu trúc exynos_tmu_registers. Ngoài ra một số
		thành viên dữ liệu nền tảng khác (struct exynos_tmu_platform_data)
		được sử dụng để cấu hình TMU.
b) Trình điều khiển TMU:
		Thành phần này khởi tạo bộ điều khiển TMU và thiết lập các cài đặt khác nhau
		ngưỡng. Nó gọi việc triển khai nhiệt lõi bằng lệnh gọi
		exynos_report_trigger.
c) Màng bọc nhiệt Exynos Core:
		Điều này cung cấp 3 hàm bao bọc để sử dụng
		Khung nhiệt lõi hạt nhân. Chúng là exynos_unregister_thermal,
		exynos_register_thermal và exynos_report_trigger.
