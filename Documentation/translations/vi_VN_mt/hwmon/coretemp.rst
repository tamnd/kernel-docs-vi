.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/coretemp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Coretemp trình điều khiển hạt nhân
======================

Chip được hỗ trợ:
  * Tất cả bộ xử lý Intel Core và Atom có Cảm biến Nhiệt Kỹ thuật số (DTS)

Tiền tố: 'coretemp'

CPUID: dòng 0x6, các mẫu có X86_FEATURE_DTHERM, bao gồm:

- 0xe (Pentium M DC), 0xf (Core 2 DC 65nm),
			    - 0x16 (Core 2 SC 65nm), 0x17 (Penryn 45nm),
			    - 0x1a (Nehalem), 0x1c (Atom), 0x1e (Lynnfield),
			    - 0x26 (Tunnel Creek Atom), 0x27 (Medfield Atom),
			    - 0x36 (Nguyên tử đường mòn Cedar), 0x37 (Nguyên tử đường mòn Bay),
			    - 0x4a (Merrifield Atom), 0x4c (Cherry Trail Atom),
			    - 0x5a (Nguyên tử Moorefield), 0x5c (Nguyên tử hồ Apollo),
			    - 0x7a (Hồ nguyên tử Song Tử),
			    - 0x96 (Nguyên tử hồ Elkhart), 0x9c (Nguyên tử hồ Jasper)

Bảng dữ liệu:

Hướng dẫn dành cho nhà phát triển phần mềm kiến trúc Intel 64 và IA-32
	       Tập 3A: Hướng dẫn lập trình hệ thống

ZZ0000ZZ

Tác giả: Rudolf Marek

Sự miêu tả
-----------

Trình điều khiển này cho phép đọc DTS (Cảm biến nhiệt độ kỹ thuật số) được nhúng
bên trong CPU Intel. Trình điều khiển này có thể đọc cả lõi và gói
nhiệt độ bằng cách sử dụng các cảm biến thích hợp. Cảm biến trên mỗi gói là
có sẵn trên Sandy Bridge và tất cả các bộ xử lý mới hơn. Người lái xe sẽ hiển thị
nhiệt độ của tất cả các lõi bên trong một gói trong một thiết bị
thư mục bên trong hwmon.

Nhiệt độ được đo bằng độ C và độ phân giải đo là
1 độ C. Nhiệt độ hợp lệ là từ 0 đến TjMax độ C, bởi vì
giá trị thực tế của thanh ghi nhiệt độ trên thực tế là một delta từ TjMax.

Nhiệt độ được gọi là TjMax là nhiệt độ tiếp giáp tối đa của bộ xử lý,
tùy thuộc vào mẫu CPU. Xem bảng dưới đây. Ở nhiệt độ này, khả năng bảo vệ
cơ chế sẽ thực hiện các hành động để buộc làm mát bộ xử lý. báo động
có thể tăng lên nếu nhiệt độ tăng đủ (hơn TjMax) để kích hoạt
bit ngoài thông số kỹ thuật. Bảng sau tóm tắt các tệp sysfs đã xuất:

Tất cả các mục nhập Sysfs đều được đặt tên bằng core_id (ở đây được biểu thị bằng 'X').

===============================================================================
tempX_input Nhiệt độ lõi (tính bằng mili độ C).
tempX_max Tất cả các thiết bị làm mát phải được bật (trên Core2).
tempX_crit Nhiệt độ tiếp giáp tối đa (tính bằng mili độ C).
tempX_crit_alarm Đặt khi bit ngoài thông số kỹ thuật được đặt, không bao giờ xóa.
		  Hoạt động đúng của CPU không còn được đảm bảo.
tempX_label Chứa chuỗi "Core X", trong đó X là bộ xử lý
		  số. Đối với nhiệt độ gói, đây sẽ là "Id vật lý Y",
		  trong đó Y là số gói.
===============================================================================

Trên các CPU hiện đại (Nehalem và mới hơn), TjMax được đọc từ
Đăng ký MSR_IA32_TEMPERATURE_TARGET. Trên các mẫu cũ hơn không có MSR này,
TjMax được xác định bằng cách sử dụng bảng tra cứu hoặc phương pháp phỏng đoán. Nếu những thứ này không hoạt động
đối với CPU của bạn, bạn có thể chuyển giá trị TjMax chính xác làm tham số mô-đun
(tjmax).

Phụ lục A. Danh sách TjMax đã biết (TBD):
Một số thông tin đến từ ark.intel.com

====================================================================================
Bộ xử lý quy trình TjMax(C)

Bộ xử lý Core i5/i7 22nm
		i7 3920XM, 3820QM, 3720QM, 3667U, 3520M 105
		i5 3427U, 3360M/3320M 105
		i7 3770/3770K 105
		i5 3570/3570K, 3550, 3470/3450 105
		i7 3770S 103
		i5 3570S/3550S, 3475S/3470S/3450S 103
		i7 3770T 94
		i5 3570T 94
		i5 3470T 91

Bộ xử lý Core i3/i5/i7 32nm
		i7 2600 98
		i7 660UM/640/620, 640LM/620, 620M, 610E 105
		i5 540UM/520/430, 540M/520/450/430 105
		i3 330E, 370M/350/330 90 rPGA, 105 BGA
		i3 330UM 105

Bộ xử lý cực mạnh Core i7 32nm
		980X100

Bộ xử lý Celeron 32nm
		U3400 105
		P4505/P4500 90

Bộ xử lý nguyên tử 32nm
		S1260/1220 95
		S1240 102
		Z2460 90
		Z2760 90
		D2700/2550/2500 100
		N2850/2800/2650/2600 100

Bộ xử lý nguyên tử 22nm (Silvermont/Bay Trail)
		E3845/3827/3826/3825/3815/3805 110
		Z3795/3775/3770/3740/3736/3735/3680 90

Bộ xử lý nguyên tử 22nm (Silvermont/Moorefield)
		Z3580/3570/3560/3530 90

Bộ xử lý nguyên tử 14nm (Airmont/Cherry Trail)
		x5-Z8550/Z8500/Z8350/Z8330/Z8300 90
		x7-Z8750/Z8700 90

Bộ xử lý nguyên tử 14nm (Goldmont/Apollo Lake)
		x5-E3940/E3930 105
		x7-E3950 105

Bộ xử lý Celeron/Pentium 14nm
		(Goldmont/Hồ Apollo)
		J3455/J3355 105
		N3450/N3350 105
		N4200 105

Bộ xử lý Celeron/Pentium 14nm
		(Goldmont Plus/Hồ Gemini)
		J4105/J4005 105
		N4100/N4000 105
		N5000 105

Bộ xử lý nguyên tử 10nm (Hồ Tremont/Elkhart)
		x6000E 105

Bộ xử lý Celeron/Pentium 10nm
		(Tremont/Hồ Jasper)
		N4500/N5100/N6000 dòng 105

Bộ xử lý Xeon 45nm 5400 lõi tứ
		X5492, X5482, X5472, X5470, X5460, X5450 85
		E5472, E5462, E5450/40/30/20/10/05 85
		L5408 95
		L5430, L5420, L5410 70

Bộ xử lý Xeon 45nm 5200 lõi kép
		X5282, X5272, X5270, X5260 90
		E5240 90
		E5205, E5220 70, 90
		L5240 70
		L5238, L5215 95

Bộ xử lý nguyên tử 45nm
		D525/510/425/410 100
		K525/510/425/410 100
		Z670/650 90
		Z560/550/540/530P/530/520PT/520/515/510PT/510P 90
		Z510/500 90
		N570/550 100
		N475/470/455/450 100
		N280/270 90
		330/230 125
		E680/660/640/620 90
		E680T/660T/640T/620T 110
		E665C/645C 90
		E665CT/645CT 110
		CE4170/4150/4110 110
		Dòng CE4200 chưa rõ
		Dòng CE5300 chưa rõ

Bộ xử lý Core2 45nm
		Đơn ULV SU3500/3300 100
		T9900/9800/9600/9550/9500/9400/9300/8300/8100 105
		T6670/6500/6400 105
		T6600 90
		SU9600/9400/9300 105
		SP9600/9400 105
		SL9600/9400/9380/9300 105
		P9700/9600/9500/8800/8700/8600/8400/7570 105
		P7550/7450 90

Bộ xử lý lõi tứ Core2 45nm
		Q9100/9000 100

Bộ xử lý cực cao Core2 45nm
		X9100/9000 105
		QX9300 100

Bộ xử lý Core i3/i5/i7 45nm
		i7 940XM/920 100
		i7 840QM/820/740/720 100

Bộ xử lý Celeron 45nm
		SU2300 100
		900 105

Bộ xử lý Core2 Duo 65nm
		Độc tấu U2200, U2100 100
		U7700/7600/7500 100
		T7800/7700/7600/7500/7400/7300/7250/7200/7100 100
		T5870/5670/5600/5550/5500/5470/5450/5300/5270 100
		T5250 100
		T5800/5750/5200 85
		L7700/7500/7400/7300/7200 100

Bộ xử lý cực cao Core2 65nm
		X7900/7800 100

Bộ xử lý Core Duo 65nm
		U2500/2400 100
		T2700/2600/2450/2400/2350/2300E/2300/2250/2050 100
		L2500/2400/2300 100

Bộ xử lý lõi đơn 65nm
		U1500/1400/1300 100
		T1400/1350/1300/1250 100

Bộ xử lý Xeon 65nm 5000 lõi tứ
		X5000 90-95
		E5000 80
		L5000 70
		L5318 95

Bộ xử lý Xeon 65nm 5000 lõi kép
		5080, 5063, 5060, 5050, 5030 80-90
		5160, 5150, 5148, 5140, 5130, 5120, 5110 80
		L5138 100

Bộ xử lý Celeron 65nm
		T1700/1600 100
		560/550/540/530 100
====================================================================================
