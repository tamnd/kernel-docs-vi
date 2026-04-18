.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/codec-to-codec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Tạo codec sang codec dai link cho ALSA dapm
==================================================

Hầu hết luồng âm thanh luôn từ CPU đến codec để hệ thống của bạn
sẽ trông như dưới đây:
::::::::::::::::::::::

--------- ---------
  ZZ0000ZZ đại ZZ0001ZZ
      CPU-------> codec
  ZZ0002ZZ ZZ0003ZZ
   --------- ---------

Trong trường hợp hệ thống của bạn trông như dưới đây:
:::::::::::::::::::::::::::::::::::::::::::::::::::::

---------
                      ZZ0000ZZ
                        codec-2
                      ZZ0001ZZ
                      ---------
                           |
                         dai-2
                           |
   ---------- ---------
  ZZ0002ZZ dai-1 ZZ0003ZZ
      CPU -------> codec-1
  ZZ0004ZZ ZZ0005ZZ
   ---------- ---------
                           |
                         dai-3
                           |
                       ---------
                      ZZ0006ZZ
                        codec-3
                      ZZ0007ZZ
                       ---------

Giả sử codec-2 là chip bluetooth và codec-3 được kết nối với
một diễn giả và bạn có một kịch bản dưới đây:
codec-2 sẽ nhận dữ liệu âm thanh và người dùng muốn phát dữ liệu đó
âm thanh thông qua codec-3 mà không cần đến CPU. Điều này
trường hợp nói trên là trường hợp lý tưởng khi codec sang codec
nên sử dụng kết nối

dai_link của bạn sẽ xuất hiện như bên dưới trong máy của bạn
tập tin:
::::::::

/*
  * luồng pcm này chỉ hỗ trợ 24 bit, 2 kênh và
  * Tốc độ lấy mẫu 48k.
  */
 cấu trúc const tĩnh snd_soc_pcm_stream dsp_codec_params = {
        .format = SNDRV_PCM_FMTBIT_S24_LE,
        .rate_min = 48000,
        .rate_max = 48000,
        .channels_min = 2,
        .channels_max = 2,
 };

{
    .name = "CPU-DSP",
    .stream_name = "CPU-DSP",
    .cpu_dai_name = "samsung-i2s.0",
    .codec_name = "codec-2,
    .codec_dai_name = "codec-2-dai_name",
    .platform_name = "samsung-i2s.0",
    .dai_fmt = SND_SOC_DAIFMT_I2S | SND_SOC_DAIFMT_NB_NF
            | SND_SOC_DAIFMT_CBP_CFP,
    .ignore_suspend = 1,
    .c2c_params = &dsp_codec_params,
    .num_c2c_params = 1,
 },
 {
    .name = "DSP-CODEC",
    .stream_name = "DSP-CODEC",
    .cpu_dai_name = "wm0010-sdi2",
    .codec_name = "codec-3,
    .codec_dai_name = "codec-3-dai_name",
    .dai_fmt = SND_SOC_DAIFMT_I2S | SND_SOC_DAIFMT_NB_NF
            | SND_SOC_DAIFMT_CBP_CFP,
    .ignore_suspend = 1,
    .c2c_params = &dsp_codec_params,
    .num_c2c_params = 1,
 },

Đoạn mã trên được lấy cảm hứng từ sound/soc/samsung/speyside.c.

Lưu ý lệnh gọi lại "c2c_params" cho phép dapm biết rằng điều này
dai_link là một kết nối codec với codec.

Trong lõi dapm, một tuyến đường được tạo giữa tiện ích phát lại cpu_dai
và tiện ích chụp codec_dai cho đường dẫn phát lại và ngược lại là
đúng cho đường dẫn chụp. Để tuyến đường nói trên có được
được kích hoạt, DAPM cần tìm điểm cuối hợp lệ có thể là
một tiện ích chìm hoặc nguồn tương ứng với đường dẫn phát lại và chụp
tương ứng.

Để kích hoạt tiện ích dai_link này, trình điều khiển codec mỏng cho
amp loa có thể được tạo như minh họa trong tệp wm8727.c, nó
đặt các ràng buộc thích hợp cho thiết bị ngay cả khi nó không cần điều khiển.

Đảm bảo đặt tên cho phát lại và ghi lại CPU và codec tương ứng của bạn
tên dai kết thúc bằng "Playback" và "Capture" tương ứng là lõi dapm
sẽ liên kết và cung cấp năng lượng cho các dais đó dựa trên tên.

Dai_link trong "card âm thanh đơn giản" sẽ tự động được phát hiện là
codec sang codec khi tất cả DAI trên liên kết đều thuộc về các thành phần codec.
dai_link sẽ được khởi tạo với tập hợp con các tham số luồng
(kênh, định dạng, tốc độ mẫu) được hỗ trợ bởi tất cả DAI trên liên kết. Kể từ khi
không có cách nào để cung cấp các tham số này trong cây thiết bị, đây là
chủ yếu hữu ích cho việc giao tiếp với các codec chức năng cố định đơn giản, chẳng hạn như
như một bộ điều khiển Bluetooth hoặc modem di động.
