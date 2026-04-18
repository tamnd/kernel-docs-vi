.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/marvell.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
ARM SoC Marvell
==================

Tài liệu này liệt kê tất cả các SoC ARM Marvell hiện đang được sử dụng
được hỗ trợ trong dòng chính bởi nhân Linux. Là gia đình Marvell của
SoC rất lớn và phức tạp, thật khó hiểu sự hỗ trợ ở đâu
cho một SoC cụ thể có sẵn trong nhân Linux. Tài liệu này
cố gắng giúp hiểu những SoC đó được hỗ trợ ở đâu và để
đối sánh chúng với bảng dữ liệu công khai tương ứng, nếu có.

Gia đình Orion
------------

Hương vị:
        - 88F5082
        - 88F5181 hay còn gọi là Orion-1
        - 88F5181L hay còn gọi là Orion-VoIP
        - 88F5182 hay còn gọi là Orion-NAS

- Bảng dữ liệu: ZZ0000ZZ
               - Hướng dẫn sử dụng lập trình viên: ZZ0001ZZ
               - Hướng dẫn sử dụng: ZZ0002ZZ
               - Lỗi chức năng: ZZ0003ZZ
        - 88F5281 hay còn gọi là Orion-2

- Bảng dữ liệu: ZZ0000ZZ
        - 88F6183 hay còn gọi là Orion-1-90
  Trang chủ:
        ZZ0001ZZ
  Cốt lõi:
	Feroceon 88fr331 (88f51xx) hoặc 88fr531-vd (88f52xx) tương thích ARMv5
  Thư mục máy nhân Linux:
	vòm/cánh tay/mach-orion5x
  Thư mục plat nhân Linux:
	vòm/cánh tay/plat-orion

gia đình Kirkwood
---------------

Hương vị:
        - 88F6282 hay còn gọi là Armada 300

- Tóm tắt sản phẩm : ZZ0000ZZ
        - 88F6283 hay còn gọi là Armada 310

- Tóm tắt sản phẩm : ZZ0000ZZ
        - 88F6190

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ
        - 88F6192

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ
        - 88F6182
        - 88F6180

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ
        - 88F6280

- Tóm tắt sản phẩm : ZZ0000ZZ
        - 88F6281

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ
        - 88F6321
        - 88F6322
        - 88F6323

- Tóm tắt sản phẩm : ZZ0000ZZ
  Trang chủ:
	ZZ0001ZZ
  Cốt lõi:
	Tương thích Feroceon 88fr131 ARMv5
  Thư mục máy nhân Linux:
	vòm/cánh tay/mach-mvebu
  Thư mục plat nhân Linux:
	không có

gia đình khám phá
----------------

Hương vị:
        -MV78100

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ
        -MV78200

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ

-MV76100

- Tóm tắt sản phẩm : ZZ0000ZZ
                - Thông số phần cứng: ZZ0001ZZ
                - Thông số chức năng: ZZ0002ZZ

Không được nhân Linux hỗ trợ.

Trang chủ:
        ZZ0000ZZ
  Cốt lõi:
	Tương thích Feroceon 88fr571-vd ARMv5

Thư mục máy nhân Linux:
	vòm/cánh tay/mach-mv78xx0
  Thư mục plat nhân Linux:
	vòm/cánh tay/plat-orion

Gia đình Armada EBU
-----------------

Hương vị Armada 370:
        - 88F6710
        - 88F6707
        - 88F6W11

- Thông tin sản phẩm: ZZ0000ZZ
    - Tóm tắt sản phẩm: ZZ0001ZZ
    - Thông số phần cứng: ZZ0002ZZ
    - Thông số chức năng: ZZ0003ZZ

Cốt lõi:
	Sheeva ARMv7 tương thích PJ4B

Hương vị Armada XP:
        -MV78230
        -MV78260
        -MV78460

NOTE:
	đừng nhầm lẫn với các SoC không phải SMP 78xx0

- Thông tin sản phẩm: ZZ0000ZZ
    - Tóm tắt sản phẩm: ZZ0001ZZ
    - Thông số chức năng: ZZ0002ZZ
    - Thông số phần cứng:
        -ZZ0003ZZ
        -ZZ0004ZZ
        -ZZ0005ZZ

Cốt lõi:
	Sheeva ARMv7 tương thích Dual-core hoặc Quad-core PJ4B-MP

Armada 375 Hương vị:
	- 88F6720

- Thông tin sản phẩm: ZZ0000ZZ
    - Tóm tắt sản phẩm: ZZ0001ZZ

Cốt lõi:
	ARM Cortex-A9

Hương vị Armada 38x:
	- 88F6810 Armada 380
	- 88F6811 Hạm đội 381
	- 88F6821 Hạm đội 382
	- 88F6W21 Hạm đội 383
	- 88F6820 Armada 385
	- 88F6825
	- 88F6828 Hạm Đội 388

- Thông tin sản phẩm: ZZ0000ZZ
    - Thông số chức năng: ZZ0001ZZ
    - Thông số phần cứng: ZZ0002ZZ
    - Hướng dẫn thiết kế: ZZ0003ZZ

Cốt lõi:
	ARM Cortex-A9

Hương vị Armada 39x:
	- 88F6920 Armada 390
	- 88F6925 Hạm đội 395
	- 88F6928 Hạm Đội 398

- Thông tin sản phẩm: ZZ0000ZZ

Cốt lõi:
	ARM Cortex-A9

Thư mục máy nhân Linux:
	vòm/cánh tay/mach-mvebu
  Thư mục plat nhân Linux:
	không có

EBU Gia đình Armada ARMv8
-----------------------

Armada 3710/3720 Hương vị:
	- 88F3710
	- 88F3720

Cốt lõi:
	ARM Cortex A53 (ARMv8)

Trang chủ:
	ZZ0000ZZ

Tóm tắt sản phẩm:
	ZZ0000ZZ

Thông số phần cứng:
	ZZ0000ZZ

Tệp cây thiết bị:
	Arch/arm64/boot/dts/marvell/armada-37*

Hương vị Armada 7K:
	  - 88F6040 (AP806 Quad 600 MHz + một CP110)
	  - 88F7020 (AP806 Kép + một CP110)
	  - 88F7040 (AP806 Quad + một CP110)

Cốt lõi: ARM Cortex A72

Trang chủ:
	ZZ0000ZZ

Tóm tắt sản phẩm:
	  -ZZ0000ZZ
	  -ZZ0001ZZ

Tệp cây thiết bị:
	Arch/arm64/boot/dts/marvell/armada-70*

Hương vị Armada 8K:
	- 88F8020 (AP806 Kép + hai CP110)
	- 88F8040 (AP806 Quad + hai CP110)
  Cốt lõi:
	ARM Cortex A72

Trang chủ:
	ZZ0000ZZ

Tóm tắt sản phẩm:
	  -ZZ0000ZZ
	  -ZZ0001ZZ

Tệp cây thiết bị:
	Arch/arm64/boot/dts/marvell/armada-80*

Octeon TX2 CN913x Hương vị:
	- CN9130 (AP807 Quad + một CP115 nội bộ)
	- CN9131 (AP807 Quad + một CP115 bên trong + một CP115 bên ngoài / 88F8215)
	- CN9132 (AP807 Quad + một CP115 bên trong + hai CP115 bên ngoài / 88F8215)

Cốt lõi:
	ARM Cortex A72

Trang chủ:
	ZZ0000ZZ

Tóm tắt sản phẩm:
	ZZ0000ZZ

Tệp cây thiết bị:
	Arch/arm64/boot/dts/marvell/cn913*

gia đình avanta
-------------

Hương vị:
       - 88F6500
       - 88F6510
       - 88F6530P
       - 88F6550
       - 88F6560
       - 88F6601

Trang chủ:
	ZZ0000ZZ

Tóm tắt sản phẩm:
	ZZ0000ZZ

Không có bảng dữ liệu công cộng có sẵn.

Cốt lõi:
	Tương thích ARMv5

Thư mục máy nhân Linux:
	chưa có mã nào trong dòng chính, được lên kế hoạch cho tương lai
  Thư mục plat nhân Linux:
	chưa có mã nào trong dòng chính, được lên kế hoạch cho tương lai

Gia đình lưu trữ
--------------

Armada SP:
	- 88RC1580

Thông tin sản phẩm:
	ZZ0000ZZ

Cốt lõi:
	Sheeva ARMv7 lõi tứ tương thích PJ4C

(không được hỗ trợ trong nhân Linux ngược dòng)

Họ Dove (bộ xử lý ứng dụng)
-----------------------------------

Hương vị:
        - 88AP510 hay còn gọi là Armada 510

Tóm tắt sản phẩm:
	ZZ0000ZZ

Thông số phần cứng:
	ZZ0000ZZ

Thông số chức năng:
	ZZ0000ZZ

Trang chủ:
	ZZ0000ZZ

Cốt lõi:
	Tương thích ARMv7

Thư mục:
	- Arch/arm/mach-mvebu (nền tảng hỗ trợ DT)
        - Arch/arm/mach-dove (nền tảng không hỗ trợ DT)

Dòng PXA 2xx/3xx/93x/95x
--------------------------

Hương vị:
        - PXA21x, PXA25x, PXA26x
             - Chỉ bộ xử lý ứng dụng
             - Lõi: lõi ARMv5 XScale1
        - PXA270, PXA271, PXA272
             - Tóm tắt sản phẩm : ZZ0000ZZ
             - Hướng dẫn thiết kế : ZZ0001ZZ
             - Hướng dẫn dành cho nhà phát triển: ZZ0002ZZ
             - Thông số kỹ thuật: ZZ0003ZZ
             - Cập nhật thông số kỹ thuật: ZZ0004ZZ
             - Chỉ bộ xử lý ứng dụng
             - Lõi: lõi ARMv5 XScale2
        -PXA300, PXA310, PXA320
             - Tóm tắt sản phẩm PXA 300 : ZZ0005ZZ
             - Tóm tắt sản phẩm PXA 310 : ZZ0006ZZ
             - Tóm tắt sản phẩm PXA 320 : ZZ0007ZZ
             - Hướng dẫn thiết kế : ZZ0008ZZ
             - Hướng dẫn dành cho nhà phát triển: ZZ0009ZZ
             - Thông số kỹ thuật: ZZ0010ZZ
             - Cập nhật thông số kỹ thuật: ZZ0011ZZ
             - Tài liệu tham khảo: ZZ0012ZZ
             - Chỉ bộ xử lý ứng dụng
             - Lõi: lõi ARMv5 XScale3
        - PXA930, PXA935
             - Bộ xử lý ứng dụng với bộ xử lý Truyền thông
             - Lõi: lõi ARMv5 XScale3
        -PXA955
             - Bộ xử lý ứng dụng với bộ xử lý Truyền thông
             - Lõi: Lõi Sheeva PJ4 tương thích ARMv7

Bình luận:

* Dòng SoC này có nguồn gốc từ dòng XScale được phát triển bởi
      Intel và được Marvell mua lại vào năm 2006. PXA21x, PXA25x,
      PXA26x, PXA27x, PXA3xx và PXA93x được Intel phát triển, trong khi
      PXA95x sau này được phát triển bởi Marvell.

* Do có nguồn gốc XScale nên các SoC này hầu như không có gì
      chung với các họ khác (Kirkwood, Dove, v.v.) của Marvell
      SoC, ngoại trừ dòng SoC MMP/MMP2.

Thư mục máy nhân Linux:
	vòm/cánh tay/mach-pxa

Họ MMP/MMP2/MMP3 (bộ xử lý truyền thông)
----------------------------------------------

Hương vị:
        - PXA168, hay còn gọi là Armada 168
             - Trang chủ : ZZ0000ZZ
             - Tóm tắt sản phẩm : ZZ0001ZZ
             - Hướng dẫn sử dụng phần cứng: ZZ0002ZZ
             - Hướng dẫn sử dụng phần mềm: ZZ0003ZZ
             - Cập nhật thông số kỹ thuật: ZZ0004ZZ
             - Hướng dẫn khởi động ROM: ZZ0005ZZ
             - Gói nút ứng dụng: ZZ0006ZZ
             - Chỉ bộ xử lý ứng dụng
             - Cốt lõi: Marvell PJ1 88sv331 (Mohawk) tương thích ARMv5
        -PXA910/PXA920
             - Trang chủ : ZZ0007ZZ
             - Tóm tắt sản phẩm : ZZ0008ZZ
             - Bộ xử lý ứng dụng với bộ xử lý Truyền thông
             - Cốt lõi: Marvell PJ1 88sv331 (Mohawk) tương thích ARMv5
        - PXA688, còn gọi là MMP2, hay còn gọi là Armada 610 (OLPC XO-1.75)
             - Tóm tắt sản phẩm : ZZ0009ZZ
             - Chỉ bộ xử lý ứng dụng
             - Lõi: Lõi Sheeva PJ4 88sv581x tương thích ARMv7
	- PXA2128, còn gọi là MMP3, hay còn gọi là Armada 620 (OLPC XO-4)
	     - Tóm tắt sản phẩm : ZZ0010ZZ
	     - Chỉ bộ xử lý ứng dụng
	     - Lõi: Lõi Sheeva PJ4C lõi kép tương thích ARMv7
	- PXA960/PXA968/PXA978 (hỗ trợ Linux không ngược dòng)
	     - Bộ xử lý ứng dụng với bộ xử lý truyền thông
	     - Lõi: Lõi Sheeva PJ4 tương thích ARMv7
	- PXA986/PXA988 (Linux không hỗ trợ ngược dòng)
	     - Bộ xử lý ứng dụng với bộ xử lý truyền thông
	     - Lõi: Lõi Sheeva PJ4B-MP tương thích ARMv7 lõi kép
	- PXA1088/PXA1920 (Linux không hỗ trợ ngược dòng)
	     - Bộ xử lý ứng dụng với bộ xử lý truyền thông
	     - Lõi: lõi tứ ARMv7 Cortex-A7
	-PXA1908/PXA1928/PXA1936
	     - Bộ xử lý ứng dụng với bộ xử lý truyền thông
	     - Lõi: ARMv8 Cortex-A53 đa lõi

Bình luận:

* Dòng SoC này có nguồn gốc từ dòng XScale được phát triển bởi
      Intel và được Marvell mua lại vào năm 2006. Tất cả các bộ xử lý của
      dòng MMP/MMP2 này được phát triển bởi Marvell.

* Do có nguồn gốc XScale nên các SoC này hầu như không có gì
      chung với các họ khác (Kirkwood, Dove, v.v.) của Marvell
      SoC, ngoại trừ dòng SoC PXA được liệt kê ở trên.

Thư mục máy nhân Linux:
	vòm/cánh tay/mach-mmp

Gia đình Berlin (Giải pháp đa phương tiện)
-------------------------------------

- Hương vị:
	- 88DE3010, Armada 1000 (không hỗ trợ Linux)
		- Lõi: Marvell PJ1 (ARMv5TE), lõi kép
		- Tóm tắt sản phẩm: ZZ0000ZZ
	- 88DE3005, Armada 1500 Mini
		- Tên thiết kế: BG2CD
		- Lõi: ARM Cortex-A9, PL310 L2CC
	- 88DE3006, Armada 1500 Mini Plus
		- Tên thiết kế: BG2CDP
		- Lõi: Lõi kép ARM Cortex-A7
	- 88DE3100, Armada 1500
		- Tên thiết kế: BG2
		- Lõi: Marvell PJ4B-MP (ARMv7), Tauros3 L2CC
	- 88DE3114, Armada 1500 Pro
		- Tên thiết kế: BG2Q
		- Lõi: Quad Core ARM Cortex-A9, PL310 L2CC
	- 88DE3214, Armada 1500 Pro 4K
		- Tên thiết kế: BG3
		- Lõi: ARM Cortex-A15, CA15 tích hợp L2CC
	- 88DE3218, ARMADA 1500 Cực
		- Lõi: ARM Cortex-A53

Trang chủ: ZZ0000ZZ
  Thư mục: Arch/arm/mach-berlin

Bình luận:

* Dòng SoC này dựa trên CPU Marvell Sheeva hoặc ARM Cortex
     với Synopsys DesignWare (IRQ, GPIO, Bộ hẹn giờ, ...) và PXA IP (SDHCI, USB, ETH, ...).

* Gia đình Berlin được Synaptics mua lại từ Marvell vào năm 2017.

Lõi CPU
---------

Các lõi XScale được thiết kế bởi Intel và được Marvell vận chuyển trong các thế hệ cũ hơn.
Bộ xử lý PXA. Feroceon là một lõi được Marvell thiết kế được phát triển nội bộ,
và điều đó đã phát triển thành Sheeva. Các lõi XScale và Feroceon đã bị loại bỏ dần
theo thời gian và được thay thế bằng lõi Sheeva trong các sản phẩm sau này, sau đó
đã được thay thế bằng lõi ARM Cortex-A được cấp phép.

XScale 1
	CPUID 0x69052xxx
	ARMv5, iWMMXt
  XScale 2
	CPUID 0x69054xxx
	ARMv5, iWMMXt
  XScale 3
	CPUID 0x69056xxx hoặc 0x69056xxx
	ARMv5, iWMMXt
  Feroceon-1850 88fr331 "Mohawk"
	CPUID 0x5615331x hoặc 0x41xx926x
	ARMv5TE, vấn đề duy nhất
  Feroceon-2850 88fr531-vd "Jolteon"
	CPUID 0x5605531x hoặc 0x41xx926x
	ARMv5TE, VFP, vấn đề kép
  Feroceon 88fr571-vd "Jolteon"
	CPUID 0x5615571x
	ARMv5TE, VFP, vấn đề kép
  Feroceon 88fr131 "Mohawk-D"
	CPUID 0x5625131x
	ARMv5TE, phát hành một lần theo thứ tự
  Sheeva PJ1 88sv331 "Mohawk"
	CPUID 0x561584xx
	ARMv5, iWMMXt v2 phát hành một lần
  Sheeva PJ4 88sv581x "Flareon"
	CPUID 0x560f581x
	ARMv7, idivt, iWMMXt v2 tùy chọn
  Sheeva PJ4B 88sv581x
	CPUID 0x561f581x
	ARMv7, idivt, iWMMXt v2 tùy chọn
  Sheeva PJ4B-MP / PJ4C
	CPUID 0x562f584x
	ARMv7, idivt/idiva, LPAE, iWMMXt v2 tùy chọn và/hoặc NEON

Kế hoạch dài hạn
---------------

* Hợp nhất mach-dove/, mach-mv78xx0/, mach-orion5x/ vào
   mach-mvebu/ để hỗ trợ tất cả các SoC từ Marvell EBU (Kỹ thuật
   Đơn vị kinh doanh) trong một thư mục mach-<foo>. Nền tảng/
   do đó sẽ biến mất.

Tín dụng
-------

- Maen Suleiman <maen@marvell.com>
- Lior Amsalem <alior@marvell.com>
- Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
- Andrew Lunn <andrew@lunn.ch>
- Nicolas Pitre <nico@fluxnic.net>
- Eric Miao <eric.y.miao@gmail.com>
