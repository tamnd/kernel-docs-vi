.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/codec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Trình điều khiển lớp Codec ASoC
=======================

Trình điều khiển lớp codec là mã chung và độc lập với phần cứng để cấu hình
codec, FM, MODEM, BT hoặc DSP bên ngoài để cung cấp khả năng thu và phát lại âm thanh.
Nó không được chứa mã dành riêng cho nền tảng hoặc máy đích.
Tất cả mã cụ thể của nền tảng và máy phải được thêm vào nền tảng và
trình điều khiển máy tương ứng.

Mỗi trình điều khiển lớp codec ZZ0000ZZ cung cấp các tính năng sau: -

1. Cấu hình Codec DAI và PCM
2. Codec điều khiển IO - sử dụng RegMap API
3. Bộ trộn và điều khiển âm thanh
4. Hoạt động âm thanh Codec
5. Mô tả DAPM.
6. Trình xử lý sự kiện DAPM.

Tùy chọn, trình điều khiển codec cũng có thể cung cấp: -

7. DAC Điều khiển tắt tiếng kỹ thuật số.

Có lẽ tốt nhất nên sử dụng hướng dẫn này kết hợp với codec hiện có
mã trình điều khiển trong sound/soc/codecs/

Sự cố trình điều khiển Codec ASoC
===========================

Cấu hình Codec DAI và PCM
-------------------------------
Mỗi trình điều khiển codec phải có struct snd_soc_dai_driver để xác định DAI của nó và
Khả năng và hoạt động của PCM. Cấu trúc này được xuất để nó có thể được
đã được đăng ký với lõi bởi trình điều khiển máy của bạn.

ví dụ.
::

cấu trúc tĩnh snd_soc_dai_ops wm8731_dai_ops = {
	.prepare = wm8731_pcm_prepare,
	.hw_params = wm8731_hw_params,
	.shutdown = wm8731_shutdown,
	.mute_stream = wm8731_mute,
	.set_sysclk = wm8731_set_dai_sysclk,
	.set_fmt = wm8731_set_dai_fmt,
  };
  
cấu trúc snd_soc_dai_driver wm8731_dai = {
	.name = "wm8731-hifi",
	.playback = {
		.stream_name = "Phát lại",
		.channels_min = 1,
		.channels_max = 2,
		.giá = WM8731_RATES,
		.formats = WM8731_FORMATS,},
	.capture = {
		.stream_name = "Chụp",
		.channels_min = 1,
		.channels_max = 2,
		.giá = WM8731_RATES,
		.formats = WM8731_FORMATS,},
	.ops = &wm8731_dai_ops,
	. đối xứng_rate = 1,
  };


Kiểm soát codec IO
----------------
Codec thường có thể được điều khiển thông qua giao diện kiểu I2C hoặc SPI
(AC97 kết hợp điều khiển với dữ liệu trong DAI). Trình điều khiển codec nên sử dụng
Regmap API cho tất cả codec IO. Vui lòng xem include/linux/regmap.h và hiện có
trình điều khiển codec, ví dụ như sử dụng regmap.


Bộ trộn và điều khiển âm thanh
-------------------------
Tất cả các bộ trộn codec và điều khiển âm thanh có thể được xác định bằng cách sử dụng tiện ích
macro được xác định trong soc.h.
::

#define SOC_SINGLE(xname, reg, shift, mặt nạ, đảo ngược)

Xác định một điều khiển duy nhất như sau: -
::

xname = Tên điều khiển, ví dụ: "Âm lượng phát lại"
  reg = đăng ký codec
  shift = độ lệch bit điều khiển trong thanh ghi
  mặt nạ = (các) kích thước bit điều khiển, ví dụ: mặt nạ 7 = 3 bit
  đảo ngược = điều khiển bị đảo ngược

Các macro khác bao gồm: -
::

#define SOC_DOUBLE(xname, reg, shift_left, shift_right, mặt nạ, đảo ngược)

Một điều khiển âm thanh nổi
::

#define SOC_DOUBLE_R(xname, reg_left, reg_right, shift, mặt nạ, đảo ngược)

Một điều khiển âm thanh nổi trải dài 2 thanh ghi
::

#define SOC_ENUM_SINGLE(xreg, xshift, xmask, xtexts)

Xác định một điều khiển liệt kê duy nhất như sau: -
::

xreg = đăng ký
   xshift = độ lệch bit điều khiển trong thanh ghi
   xmask = kích thước (các) bit điều khiển
   xtexts = con trỏ tới mảng chuỗi mô tả từng cài đặt

#define SOC_ENUM_DOUBLE(xreg, xshift_l, xshift_r, xmask, xtexts)

Xác định điều khiển liệt kê âm thanh nổi


Hoạt động âm thanh Codec
----------------------
Trình điều khiển codec cũng hỗ trợ các hoạt động ALSA PCM sau:-
::

/* Hoạt động âm thanh SoC */
  cấu trúc snd_soc_ops {
	int (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);
	int (ZZ0002ZZ, cấu trúc snd_pcm_hw_params *);
	int (ZZ0003ZZ);
	int (ZZ0004ZZ);
  };

Vui lòng tham khảo ZZ0000ZZ để biết chi tiết.


Mô tả DAPM
----------------
Mô tả Quản lý nguồn âm thanh động mô tả nguồn codec
các thành phần và mối quan hệ của chúng và đăng ký vào lõi ASoC.
Vui lòng đọc dapm.rst để biết chi tiết về cách xây dựng mô tả.

Vui lòng xem thêm các ví dụ trong trình điều khiển codec khác.


Trình xử lý sự kiện DAPM
------------------
Chức năng này là một cuộc gọi lại xử lý các cuộc gọi và hệ thống PM miền codec
cuộc gọi PM miền (ví dụ: tạm dừng và tiếp tục). Nó được sử dụng để đặt codec
đi ngủ khi không sử dụng.

Trạng thái năng lượng: -
::

SNDRV_CTL_POWER_D0: /* Bật đầy đủ */
	/* vref/mid, bật clk và OSc, đang hoạt động */

SNDRV_CTL_POWER_D1: /* Bật một phần */
	SNDRV_CTL_POWER_D2: /* Bật một phần */

SNDRV_CTL_POWER_D3hot: /* Tắt, có nguồn */
	/* tắt mọi thứ ngoại trừ vref/vmid, không hoạt động */

SNDRV_CTL_POWER_D3cold: /* Mọi thứ đều tắt, không có nguồn */


Điều khiển tắt tiếng kỹ thuật số Codec DAC
------------------------------
Hầu hết các codec đều có chức năng tắt tiếng kỹ thuật số trước DAC có thể được sử dụng để
giảm thiểu bất kỳ tiếng ồn hệ thống.  Việc tắt tiếng sẽ dừng mọi dữ liệu kỹ thuật số khỏi
vào DAC.

Có thể tạo một cuộc gọi lại được gọi bởi lõi cho mỗi codec DAI
khi tắt tiếng được áp dụng hoặc giải phóng.

tức là
::

int tĩnh wm8974_mute(struct snd_soc_dai *dai, int mute, int Direction)
  {
	struct snd_soc_comComponent *thành phần = dai->thành phần;
	u16 mute_reg = snd_soc_comComponent_read(thành phần, WM8974_DAC) & 0xffbf;

nếu (tắt tiếng)
		snd_soc_comComponent_write(thành phần, WM8974_DAC, mute_reg | 0x40);
	khác
		snd_soc_comComponent_write(thành phần, WM8974_DAC, mute_reg);
	trả về 0;
  }
