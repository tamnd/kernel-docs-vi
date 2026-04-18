.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/fimc-devel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển Samsung S5P/EXYNOS4 FIMC
===================================

Bản quyền ZZ0000ZZ 2012 - 2013 Công ty TNHH Điện tử Samsung

Phân vùng tập tin
------------------

- trình điều khiển thiết bị đa phương tiện

trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/media-dev.[ch]

- trình điều khiển thiết bị quay video của máy ảnh

trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/fimc-capture.c

- Phân nhóm máy thu MIPI-CSI2

trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/mipi-csis.[ch]

- bộ xử lý hậu video (mem-to-mem)

trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/fimc-core.c

- tập tin phổ biến

trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/fimc-core.h
  trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/fimc-reg.h
  trình điều khiển/phương tiện/nền tảng/samsung/exynos4-is/regs-fimc.h