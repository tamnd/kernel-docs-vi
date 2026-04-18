.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/fam15h_power.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân fam15h_power
==========================

Chip được hỗ trợ:

* Bộ xử lý 15h dòng AMD

* Bộ xử lý 16h dòng AMD

Tiền tố: 'fam15h_power'

Địa chỉ được quét: không gian PCI

Bảng dữ liệu:

- Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS (BKDG) dành cho bộ xử lý 15h dòng AMD
  - Hướng dẫn dành cho nhà phát triển hạt nhân và BIOS (BKDG) dành cho bộ xử lý 16h dòng AMD
  - Cẩm nang Lập trình viên Kiến trúc AMD64 Tập 2: Lập trình hệ thống

Tác giả: Andreas Herrmann <herrmann.der.user@googlemail.com>

Sự miêu tả
-----------

1) Bộ xử lý TDP (Công suất thiết kế nhiệt)

Với tần số và điện áp cố định, công suất tiêu thụ của
bộ xử lý thay đổi tùy theo khối lượng công việc được thực thi. Giảm sức mạnh
là năng lượng tiêu thụ khi chạy một ứng dụng cụ thể. nhiệt
công suất thiết kế (TDP) là một ví dụ về công suất suy giảm.

Trình điều khiển này cho phép đọc các thanh ghi cung cấp thông tin về nguồn điện
của bộ xử lý AMD Dòng 15h và 16h thông qua thuật toán TDP.

Đối với bộ xử lý AMD Family 15h và 16h, các giá trị công suất sau có thể
được tính toán bằng cách sử dụng chức năng cầu bắc của bộ xử lý khác nhau
đăng ký:

* BasePwrWatt:
    Chỉ định lượng điện năng tối đa tính bằng watt
    được bộ xử lý tiêu thụ cho NB và logic bên ngoài lõi.

* Bộ xử lýPwrWatts:
    Chỉ định lượng điện năng tối đa tính bằng watt
    bộ xử lý có thể hỗ trợ.
* CurrPwrWatt:
    Chỉ định lượng điện năng hiện tại được tính bằng watt
    được bộ xử lý tiêu thụ.

Trình điều khiển này cung cấp Bộ xử lýPwrWatts và CurrPwrWatts:

* power1_crit (Bộ xử lýPwrWatts)
* power1_input (CurrPwrWatts)

Trên bộ xử lý nhiều nút, giá trị được tính toán dành cho toàn bộ
gói chứ không phải cho một nút nào. Do đó trình điều khiển tạo sysfs
các thuộc tính chỉ dành cho nút0 bên trong của bộ xử lý nhiều nút.

2) Cơ chế năng lượng tích lũy

Trình điều khiển này cũng giới thiệu một thuật toán nên được sử dụng để
tính công suất trung bình mà bộ xử lý tiêu thụ trong một
khoảng đo Tm. Đặc điểm của cơ chế năng lượng tích lũy là
được chỉ định bởi CPUID Fn8000_0007_EDX[12].

* Mẫu:
	đơn vị tính toán thời gian lấy mẫu ắc quy điện

* Tref:
	chu kỳ truy cập PTSC

*PTSC:
	bộ đếm dấu thời gian hiệu suất

*N:
	tỷ lệ giữa thời gian lấy mẫu bộ tích điện của đơn vị tính toán và thời gian lấy mẫu
	Thời kỳ PTSC

*Jmax:
	công suất tích lũy đơn vị tính toán tối đa được biểu thị bằng
	MaxCpuSwPwrAcc MSR C001007b

* Jx/Jy:
	tính toán công suất tích lũy của đơn vị được biểu thị bằng
	CpuSwPwrAcc MSR C001007a
*Tx/Ty:
	giá trị của bộ đếm dấu thời gian hiệu suất được chỉ định
	bởi CU_PTSC MSR C0010280

* PwrCPUave:
	Công suất trung bình CPU

Tôi. Xác định tỷ lệ Tsample so với Tref bằng cách thực thi CPUID Fn8000_0007.

N = giá trị của CPUID Fn8000_0007_ECX[CpuPwrSampleTimeRatio[15:0]].

ii. Đọc toàn bộ phạm vi giá trị năng lượng tích lũy từ mới
    MSR MaxCpuSwPwrAcc.

Jmax = giá trị trả về

iii. Tại thời điểm x, SW đọc CpuSwPwrAcc MSR và lấy mẫu PTSC.

Jx = giá trị đọc từ CpuSwPwrAcc và Tx = giá trị đọc từ PTSC.

iv. Tại thời điểm y, SW đọc CpuSwPwrAcc MSR và lấy mẫu PTSC.

Jy = giá trị đọc từ CpuSwPwrAcc và Ty = giá trị đọc từ PTSC.

v. Tính mức tiêu thụ điện năng trung bình cho một đơn vị tính toán trên
   khoảng thời gian (y-x). Đơn vị kết quả là uWatt::

if (Jy < Jx) // Rollover đã xảy ra
		Jdelta = (Jy + Jmax) - Jx
	khác
		Jdelta = Jy - Jx
	PwrCPUave = N * Jdelta * 1000 / (Ty - Tx)

Trình điều khiển này cung cấp PwrCPUave và khoảng thời gian (mặc định là 10 mili giây
và tối đa là 1 giây):

* power1_average (PwrCPUave)
* power1_average_interval (Khoảng thời gian)

Power1_average_interval có thể được cập nhật tại tệp /etc/sensors3.conf
như dưới đây:

chip ZZ0000ZZ
	đặt power1_average_interval 0,01

Sau đó lưu nó với "cảm biến -s".
