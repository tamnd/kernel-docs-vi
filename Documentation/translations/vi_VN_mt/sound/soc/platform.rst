.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/platform.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Trình điều khiển nền tảng ASoC
====================

Một lớp trình điều khiển nền tảng ASoC có thể được chia thành các trình điều khiển âm thanh DMA, SoC DAI
trình điều khiển và trình điều khiển DSP. Trình điều khiển nền tảng chỉ nhắm mục tiêu SoC CPU và phải
không có mã cụ thể của bảng.

Âm thanh DMA
=========

Trình điều khiển DMA nền tảng tùy chọn hỗ trợ các hoạt động ALSA sau: -
::

/* Hoạt động âm thanh SoC */
  cấu trúc snd_soc_ops {
	int (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);
	int (ZZ0002ZZ, cấu trúc snd_pcm_hw_params *);
	int (ZZ0003ZZ);
	int (ZZ0004ZZ);
	int (ZZ0005ZZ, int);
  };

Trình điều khiển nền tảng xuất chức năng DMA của nó thông qua struct
snd_soc_comComponent_driver: -
::

cấu trúc snd_soc_comComponent_driver {
	const char *tên;

	...
int (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);
	int (ZZ0002ZZ);
	int (ZZ0003ZZ);

/* Tạo và hủy pcm */
	int (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);

	...
const struct snd_pcm_ops *ops;
	const struct snd_compr_ops *compr_ops;
	...
  };

Vui lòng tham khảo ZZ0000ZZ để biết chi tiết về âm thanh DMA.

Một ví dụ về trình điều khiển DMA là soc/pxa/pxa2xx-pcm.c


Trình điều khiển SoC DAI
===============

Mỗi trình điều khiển SoC DAI phải cung cấp các tính năng sau:-

1. Mô tả giao diện âm thanh kỹ thuật số (DAI)
2. Cấu hình giao diện âm thanh kỹ thuật số
3. Mô tả của PCM
4. Cấu hình SYSCLK
5. Tạm dừng và tiếp tục (tùy chọn)

Vui lòng xem codec.rst để biết mô tả về các mục 1 - 4.


Trình điều khiển SoC DSP
===============

Mỗi trình điều khiển SoC DSP thường cung cấp các tính năng sau: -

1. Đồ thị DAPM
2. Điều khiển máy trộn
3. DMA IO đến/từ bộ đệm DSP (nếu có)
4. Định nghĩa các thiết bị PCM giao diện người dùng DSP (FE).

Vui lòng xem DPCM.txt để biết mô tả về mục 4.
