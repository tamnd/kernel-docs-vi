.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-codec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _codec-controls:

**************************
Tham khảo điều khiển Codec
**************************

Dưới đây tất cả các điều khiển trong lớp điều khiển Codec được mô tả. đầu tiên
các điều khiển chung, sau đó điều khiển cụ thể cho phần cứng nhất định.

.. note::

   These controls are applicable to all codecs and not just MPEG. The
   defines are prefixed with V4L2_CID_MPEG/V4L2_MPEG as the controls
   were originally made for MPEG codecs and later extended to cover all
   encoding formats.


Điều khiển Codec chung
======================


.. _mpeg-control-id:

ID kiểm soát codec
-----------------

ZZ0001ZZ
    Bộ mô tả lớp Codec. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này. Sự mô tả này có thể
    Ví dụ: được sử dụng làm chú thích của trang Tab trong GUI.

.. _v4l2-mpeg-stream-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_stream_type -
    Loại luồng đầu ra MPEG-1, -2 hoặc -4. Người ta không thể giả định bất cứ điều gì
    ở đây. Mỗi bộ mã hóa MPEG phần cứng có xu hướng hỗ trợ các tập hợp con khác nhau
    trong số các loại luồng MPEG có sẵn. Việc kiểm soát này dành riêng cho
    các luồng MPEG được ghép kênh. Các loại luồng hiện được xác định là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_STREAM_TYPE_MPEG2_PS``
      - MPEG-2 program stream
    * - ``V4L2_MPEG_STREAM_TYPE_MPEG2_TS``
      - MPEG-2 transport stream
    * - ``V4L2_MPEG_STREAM_TYPE_MPEG1_SS``
      - MPEG-1 system stream
    * - ``V4L2_MPEG_STREAM_TYPE_MPEG2_DVD``
      - MPEG-2 DVD-compatible stream
    * - ``V4L2_MPEG_STREAM_TYPE_MPEG1_VCD``
      - MPEG-1 VCD-compatible stream
    * - ``V4L2_MPEG_STREAM_TYPE_MPEG2_SVCD``
      - MPEG-2 SVCD-compatible stream



ZZ0000ZZ
    ID gói bảng bản đồ chương trình cho luồng truyền tải MPEG (mặc định
    16)

ZZ0000ZZ
    ID gói âm thanh cho luồng truyền tải MPEG (mặc định 256)

ZZ0000ZZ
    ID gói video cho luồng truyền tải MPEG (mặc định 260)

ZZ0000ZZ
    ID gói cho luồng truyền tải MPEG mang các trường PCR (mặc định
    259)

ZZ0000ZZ
    ID âm thanh cho MPEG PES

ZZ0000ZZ
    ID video cho MPEG PES

.. _v4l2-mpeg-stream-vbi-fmt:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_stream_vbi_fmt -
    Một số thẻ có thể nhúng dữ liệu VBI (ví dụ: Phụ đề chi tiết, Teletext) vào
    luồng MPEG. Điều khiển này chọn xem dữ liệu VBI có nên được
    được nhúng và nếu có thì nên sử dụng phương pháp nhúng nào. Danh sách
    các định dạng VBI có thể có tùy thuộc vào trình điều khiển. Hiện tại được xác định
    Các loại định dạng VBI là:



.. tabularcolumns:: |p{6.6 cm}|p{10.9cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_STREAM_VBI_FMT_NONE``
      - No VBI in the MPEG stream
    * - ``V4L2_MPEG_STREAM_VBI_FMT_IVTV``
      - VBI in private packets, IVTV format (documented in the kernel
	sources in the file
	``Documentation/userspace-api/media/drivers/cx2341x-uapi.rst``)



.. _v4l2-mpeg-audio-sampling-freq:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_sampling_freq -
    MPEG Tần số lấy mẫu âm thanh. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_SAMPLING_FREQ_44100``
      - 44.1 kHz
    * - ``V4L2_MPEG_AUDIO_SAMPLING_FREQ_48000``
      - 48 kHz
    * - ``V4L2_MPEG_AUDIO_SAMPLING_FREQ_32000``
      - 32 kHz



.. _v4l2-mpeg-audio-encoding:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_encoding -
    Mã hóa âm thanh MPEG. Điều khiển này dành riêng cho MPEG được ghép kênh
    suối. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_ENCODING_LAYER_1``
      - MPEG-1/2 Layer I encoding
    * - ``V4L2_MPEG_AUDIO_ENCODING_LAYER_2``
      - MPEG-1/2 Layer II encoding
    * - ``V4L2_MPEG_AUDIO_ENCODING_LAYER_3``
      - MPEG-1/2 Layer III encoding
    * - ``V4L2_MPEG_AUDIO_ENCODING_AAC``
      - MPEG-2/4 AAC (Advanced Audio Coding)
    * - ``V4L2_MPEG_AUDIO_ENCODING_AC3``
      - AC-3 aka ATSC A/52 encoding



.. _v4l2-mpeg-audio-l1-bitrate:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_l1_bitrate -
    Tốc độ bit lớp I MPEG-1/2. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_32K``
      - 32 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_64K``
      - 64 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_96K``
      - 96 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_128K``
      - 128 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_160K``
      - 160 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_192K``
      - 192 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_224K``
      - 224 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_256K``
      - 256 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_288K``
      - 288 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_320K``
      - 320 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_352K``
      - 352 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_384K``
      - 384 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_416K``
      - 416 kbit/s
    * - ``V4L2_MPEG_AUDIO_L1_BITRATE_448K``
      - 448 kbit/s



.. _v4l2-mpeg-audio-l2-bitrate:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_l2_bitrate -
    Tốc độ bit MPEG-1/2 Lớp II. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_32K``
      - 32 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_48K``
      - 48 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_56K``
      - 56 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_64K``
      - 64 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_80K``
      - 80 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_96K``
      - 96 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_112K``
      - 112 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_128K``
      - 128 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_160K``
      - 160 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_192K``
      - 192 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_224K``
      - 224 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_256K``
      - 256 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_320K``
      - 320 kbit/s
    * - ``V4L2_MPEG_AUDIO_L2_BITRATE_384K``
      - 384 kbit/s



.. _v4l2-mpeg-audio-l3-bitrate:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_l3_bitrate -
    Tốc độ bit MPEG-1/2 Lớp III. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_32K``
      - 32 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_40K``
      - 40 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_48K``
      - 48 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_56K``
      - 56 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_64K``
      - 64 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_80K``
      - 80 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_96K``
      - 96 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_112K``
      - 112 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_128K``
      - 128 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_160K``
      - 160 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_192K``
      - 192 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_224K``
      - 224 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_256K``
      - 256 kbit/s
    * - ``V4L2_MPEG_AUDIO_L3_BITRATE_320K``
      - 320 kbit/s



ZZ0000ZZ
    Tốc độ bit AAC tính bằng bit trên giây.

.. _v4l2-mpeg-audio-ac3-bitrate:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_ac3_bitrate -
    Tốc độ bit AC-3. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_32K``
      - 32 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_40K``
      - 40 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_48K``
      - 48 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_56K``
      - 56 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_64K``
      - 64 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_80K``
      - 80 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_96K``
      - 96 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_112K``
      - 112 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_128K``
      - 128 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_160K``
      - 160 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_192K``
      - 192 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_224K``
      - 224 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_256K``
      - 256 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_320K``
      - 320 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_384K``
      - 384 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_448K``
      - 448 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_512K``
      - 512 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_576K``
      - 576 kbit/s
    * - ``V4L2_MPEG_AUDIO_AC3_BITRATE_640K``
      - 640 kbit/s



.. _v4l2-mpeg-audio-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_mode -
    Chế độ âm thanh MPEG. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_MODE_STEREO``
      - Stereo
    * - ``V4L2_MPEG_AUDIO_MODE_JOINT_STEREO``
      - Joint Stereo
    * - ``V4L2_MPEG_AUDIO_MODE_DUAL``
      - Bilingual
    * - ``V4L2_MPEG_AUDIO_MODE_MONO``
      - Mono



.. _v4l2-mpeg-audio-mode-extension:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_mode_extension -
    Phần mở rộng chế độ âm thanh Stereo chung. Ở Lớp I và II chúng chỉ ra
    băng tần con nào có cường độ âm thanh nổi. Tất cả các băng con khác được mã hóa
    trong âm thanh nổi. Lớp III chưa được hỗ trợ. Các giá trị có thể là:

.. tabularcolumns:: |p{9.1cm}|p{8.4cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_4``
      - Subbands 4-31 in intensity stereo
    * - ``V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_8``
      - Subbands 8-31 in intensity stereo
    * - ``V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_12``
      - Subbands 12-31 in intensity stereo
    * - ``V4L2_MPEG_AUDIO_MODE_EXTENSION_BOUND_16``
      - Subbands 16-31 in intensity stereo



.. _v4l2-mpeg-audio-emphasis:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_emphasis -
    Nhấn mạnh âm thanh. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_EMPHASIS_NONE``
      - None
    * - ``V4L2_MPEG_AUDIO_EMPHASIS_50_DIV_15_uS``
      - 50/15 microsecond emphasis
    * - ``V4L2_MPEG_AUDIO_EMPHASIS_CCITT_J17``
      - CCITT J.17



.. _v4l2-mpeg-audio-crc:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_crc -
    Phương pháp CRC. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_CRC_NONE``
      - None
    * - ``V4L2_MPEG_AUDIO_CRC_CRC16``
      - 16 bit parity check



ZZ0000ZZ
    Tắt âm thanh khi chụp. Điều này không được thực hiện bằng cách tắt âm thanh
    phần cứng, vẫn có thể tạo ra tiếng rít nhẹ, nhưng trong bộ mã hóa
    chính nó, đảm bảo dòng bit âm thanh cố định và có thể tái tạo. 0 =
    không bị tắt tiếng, 1 = bị tắt tiếng.

.. _v4l2-mpeg-audio-dec-playback:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_dec_playback -
    Xác định cách phát lại âm thanh đơn ngữ. Có thể
    giá trị là:



.. tabularcolumns:: |p{9.8cm}|p{7.7cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_AUDIO_DEC_PLAYBACK_AUTO``
      - Automatically determines the best playback mode.
    * - ``V4L2_MPEG_AUDIO_DEC_PLAYBACK_STEREO``
      - Stereo playback.
    * - ``V4L2_MPEG_AUDIO_DEC_PLAYBACK_LEFT``
      - Left channel playback.
    * - ``V4L2_MPEG_AUDIO_DEC_PLAYBACK_RIGHT``
      - Right channel playback.
    * - ``V4L2_MPEG_AUDIO_DEC_PLAYBACK_MONO``
      - Mono playback.
    * - ``V4L2_MPEG_AUDIO_DEC_PLAYBACK_SWAPPED_STEREO``
      - Stereo playback with swapped left and right channels.



.. _v4l2-mpeg-audio-dec-multilingual-playback:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_audio_dec_playback -
    Xác định cách phát lại âm thanh đa ngôn ngữ.

.. _v4l2-mpeg-video-encoding:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_encoding -
    Phương pháp mã hóa video MPEG. Điều khiển này dành riêng cho ghép kênh
    Luồng MPEG. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_ENCODING_MPEG_1``
      - MPEG-1 Video encoding
    * - ``V4L2_MPEG_VIDEO_ENCODING_MPEG_2``
      - MPEG-2 Video encoding
    * - ``V4L2_MPEG_VIDEO_ENCODING_MPEG_4_AVC``
      - MPEG-4 AVC (H.264) Video encoding



.. _v4l2-mpeg-video-aspect:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_aspect -
    Khía cạnh video. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_ASPECT_1x1``
    * - ``V4L2_MPEG_VIDEO_ASPECT_4x3``
    * - ``V4L2_MPEG_VIDEO_ASPECT_16x9``
    * - ``V4L2_MPEG_VIDEO_ASPECT_221x100``



ZZ0000ZZ
    Số khung B (mặc định 2)

ZZ0000ZZ
    Kích thước GOP (mặc định 12)

ZZ0000ZZ
    Đóng GOP (mặc định 1)

ZZ0000ZZ
    Bật kéo xuống 3:2 (mặc định 0)

.. _v4l2-mpeg-video-bitrate-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_bitrate_mode -
    Chế độ tốc độ bit của video. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_BITRATE_MODE_VBR``
      - Variable bitrate
    * - ``V4L2_MPEG_VIDEO_BITRATE_MODE_CBR``
      - Constant bitrate
    * - ``V4L2_MPEG_VIDEO_BITRATE_MODE_CQ``
      - Constant quality



ZZ0000ZZ
    Tốc độ bit video trung bình tính bằng bit trên giây.

ZZ0000ZZ
    Tốc độ bit video cao nhất tính bằng bit trên giây. Phải lớn hơn hoặc bằng
    tốc độ bit video trung bình. Nó bị bỏ qua nếu chế độ bitrate video
    được đặt thành tốc độ bit không đổi.

ZZ0000ZZ
    Kiểm soát mức chất lượng liên tục. Việc kiểm soát này được áp dụng khi
    Giá trị ZZ0001ZZ là
    ZZ0002ZZ. Phạm vi hợp lệ là 1 đến 100
    trong đó 1 biểu thị chất lượng thấp nhất và 100 biểu thị chất lượng cao nhất.
    Bộ mã hóa sẽ quyết định tham số lượng tử hóa thích hợp và
    tốc độ bit để tạo ra chất lượng khung hình được yêu cầu.


ZZ0000ZZ

enum v4l2_mpeg_video_frame_skip_mode -
    Cho biết điều kiện nào bộ mã hóa nên bỏ qua khung. Nếu
    mã hóa một khung sẽ làm cho luồng được mã hóa lớn hơn một khung
    giới hạn dữ liệu đã chọn thì khung sẽ bị bỏ qua. Giá trị có thể
    là:


.. tabularcolumns:: |p{8.2cm}|p{9.3cm}|

.. raw:: latex

    \small

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_FRAME_SKIP_MODE_DISABLED``
      - Frame skip mode is disabled.
    * - ``V4L2_MPEG_VIDEO_FRAME_SKIP_MODE_LEVEL_LIMIT``
      - Frame skip mode enabled and buffer limit is set by the chosen
        level and is defined by the standard.
    * - ``V4L2_MPEG_VIDEO_FRAME_SKIP_MODE_BUF_LIMIT``
      - Frame skip mode enabled and buffer limit is set by the
        :ref:`VBV (MPEG1/2/4) <v4l2-mpeg-video-vbv-size>` or
        :ref:`CPB (H264) buffer size <v4l2-mpeg-video-h264-cpb-size>` control.

.. raw:: latex

    \normalsize

ZZ0000ZZ
    Đối với mỗi khung hình đã chụp, hãy bỏ qua nhiều khung hình tiếp theo này (mặc định
    0).

ZZ0000ZZ
    "Tắt tiếng" video thành màu cố định khi quay. Điều này rất hữu ích
    để thử nghiệm, để tạo ra dòng bit video cố định. 0 = không tắt tiếng, 1 =
    bị tắt tiếng.

ZZ0000ZZ
    Đặt màu "tắt tiếng" của video. Số nguyên 32 bit được cung cấp là
    được hiểu như sau (bit 0 = bit có ý nghĩa nhỏ nhất):



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - Bit 0:7
      - V chrominance information
    * - Bit 8:15
      - U chrominance information
    * - Bit 16:23
      - Y luminance information
    * - Bit 24:31
      - Must be zero.



.. _v4l2-mpeg-video-dec-pts:

ZZ0001ZZ
    Điều khiển chỉ đọc này trả về Thời gian trình bày video 33 bit
    Tem như được xác định trong ITU T-REC-H.222.0 và ISO/IEC 13818-1 của
    khung hiện đang hiển thị. Đây chính là PTS được sử dụng trong
    ZZ0000ZZ.

.. _v4l2-mpeg-video-dec-frame:

ZZ0000ZZ
    Điều khiển chỉ đọc này trả về bộ đếm khung của khung
    hiện đang được hiển thị (được giải mã). Giá trị này được đặt lại về 0 bất cứ khi nào
    bộ giải mã được bắt đầu.

ZZ0000ZZ
    Điều khiển này đặt màu ẩn trong không gian màu YUV. Nó mô tả
    tùy chọn của khách hàng về màu che giấu lỗi trong trường hợp có lỗi
    nơi thiếu khung tham chiếu. Bộ giải mã sẽ điền vào
    bộ đệm tham chiếu có màu ưa thích và sử dụng nó cho tương lai
    giải mã. Điều khiển đang sử dụng 16 bit cho mỗi kênh.
    Áp dụng cho bộ giải mã.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * -
      - 8bit  format
      - 10bit format
      - 12bit format
    * - Y luminance
      - Bit 0:7
      - Bit 0:9
      - Bit 0:11
    * - Cb chrominance
      - Bit 16:23
      - Bit 16:25
      - Bit 16:27
    * - Cr chrominance
      - Bit 32:39
      - Bit 32:41
      - Bit 32:43
    * - Must be zero
      - Bit 48:63
      - Bit 48:63
      - Bit 48:63

ZZ0000ZZ
    Nếu được bật, bộ giải mã sẽ nhận được một lát trên mỗi bộ đệm,
    nếu không thì bộ giải mã sẽ mong đợi một khung hình duy nhất trong mỗi bộ đệm.
    Áp dụng cho bộ giải mã, tất cả các codec.

ZZ0000ZZ
    Nếu độ trễ hiển thị được bật thì bộ giải mã buộc phải quay lại
    bộ đệm CAPTURE (khung được giải mã) sau khi xử lý một số nhất định
    của bộ đệm OUTPUT. Độ trễ có thể được thiết lập thông qua
    ZZ0001ZZ. Cái này
    tính năng này có thể được sử dụng chẳng hạn để tạo hình thu nhỏ của video.
    Áp dụng cho bộ giải mã.

ZZ0000ZZ
    Hiển thị giá trị độ trễ cho bộ giải mã. Bộ giải mã buộc phải
    trả về khung đã giải mã sau số 'độ trễ hiển thị' đã đặt của
    khung. Nếu con số này thấp, nó có thể dẫn đến việc trả về các khung hình
    theo thứ tự hiển thị, ngoài ra phần cứng có thể vẫn đang sử dụng
    bộ đệm được trả về làm ảnh tham chiếu cho các khung tiếp theo.

ZZ0000ZZ
    Nếu được bật thì NALU AUD (Dấu phân cách đơn vị truy cập) sẽ được tạo.
    Điều đó có thể hữu ích để tìm điểm bắt đầu của khung mà không cần phải
    phân tích đầy đủ từng NALU. Áp dụng cho bộ mã hóa H264 và HEVC.

ZZ0000ZZ
    Bật ghi tỷ lệ khung hình mẫu trong Khả năng sử dụng video
    Thông tin. Áp dụng cho bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-vui-sar-idc:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_vui_sar_idc -
    Chỉ báo tỷ lệ khung hình mẫu VUI cho mã hóa H.264. Giá trị là
    được xác định trong bảng E-1 trong tiêu chuẩn. Áp dụng cho H264
    bộ mã hóa.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_UNSPECIFIED``
      - Unspecified
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_1x1``
      - 1x1
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_12x11``
      - 12x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_10x11``
      - 10x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_16x11``
      - 16x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_40x33``
      - 40x33
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_24x11``
      - 24x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_20x11``
      - 20x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_32x11``
      - 32x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_80x33``
      - 80x33
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_18x11``
      - 18x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_15x11``
      - 15x11
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_64x33``
      - 64x33
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_160x99``
      - 160x99
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_4x3``
      - 4x3
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_3x2``
      - 3x2
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_2x1``
      - 2x1
    * - ``V4L2_MPEG_VIDEO_H264_VUI_SAR_IDC_EXTENDED``
      - Extended SAR



ZZ0000ZZ
    Độ rộng tỷ lệ khung hình mẫu mở rộng cho mã hóa H.264 VUI.
    Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Chiều cao tỷ lệ khung hình mẫu mở rộng cho mã hóa H.264 VUI.
    Áp dụng cho bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-level:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_level -
    Thông tin cấp độ cho luồng cơ bản video H264.
    Áp dụng cho bộ mã hóa H264. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_1_0``
      - Level 1.0
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_1B``
      - Level 1B
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_1_1``
      - Level 1.1
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_1_2``
      - Level 1.2
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_1_3``
      - Level 1.3
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_2_0``
      - Level 2.0
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_2_1``
      - Level 2.1
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_2_2``
      - Level 2.2
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_3_0``
      - Level 3.0
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_3_1``
      - Level 3.1
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_3_2``
      - Level 3.2
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_4_0``
      - Level 4.0
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_4_1``
      - Level 4.1
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_4_2``
      - Level 4.2
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_5_0``
      - Level 5.0
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_5_1``
      - Level 5.1
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_5_2``
      - Level 5.2
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_6_0``
      - Level 6.0
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_6_1``
      - Level 6.1
    * - ``V4L2_MPEG_VIDEO_H264_LEVEL_6_2``
      - Level 6.2



.. _v4l2-mpeg-video-mpeg2-level:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_mpeg2_level -
    Thông tin cấp độ cho dòng cơ sở MPEG2. Áp dụng cho
    Bộ giải mã MPEG2. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_MPEG2_LEVEL_LOW``
      - Low Level (LL)
    * - ``V4L2_MPEG_VIDEO_MPEG2_LEVEL_MAIN``
      - Main Level (ML)
    * - ``V4L2_MPEG_VIDEO_MPEG2_LEVEL_HIGH_1440``
      - High-1440 Level (H-14)
    * - ``V4L2_MPEG_VIDEO_MPEG2_LEVEL_HIGH``
      - High Level (HL)



.. _v4l2-mpeg-video-mpeg4-level:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_mpeg4_level -
    Thông tin cấp độ cho dòng cơ sở MPEG4. Áp dụng cho
    bộ mã hóa MPEG4. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_0``
      - Level 0
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_0B``
      - Level 0b
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_1``
      - Level 1
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_2``
      - Level 2
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_3``
      - Level 3
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_3B``
      - Level 3b
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_4``
      - Level 4
    * - ``V4L2_MPEG_VIDEO_MPEG4_LEVEL_5``
      - Level 5



.. _v4l2-mpeg-video-h264-profile:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_profile -
    Thông tin hồ sơ của H264. Áp dụng cho bộ mã hóa H264.
    Các giá trị có thể là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{10.2cm}|p{7.3cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_BASELINE``
      - Baseline profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_CONSTRAINED_BASELINE``
      - Constrained Baseline profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_MAIN``
      - Main profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_EXTENDED``
      - Extended profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH``
      - High profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_10``
      - High 10 profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_422``
      - High 422 profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_444_PREDICTIVE``
      - High 444 Predictive profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_10_INTRA``
      - High 10 Intra profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_422_INTRA``
      - High 422 Intra profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_HIGH_444_INTRA``
      - High 444 Intra profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_CAVLC_444_INTRA``
      - CAVLC 444 Intra profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_SCALABLE_BASELINE``
      - Scalable Baseline profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_SCALABLE_HIGH``
      - Scalable High profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_SCALABLE_HIGH_INTRA``
      - Scalable High Intra profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_STEREO_HIGH``
      - Stereo High profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_MULTIVIEW_HIGH``
      - Multiview High profile
    * - ``V4L2_MPEG_VIDEO_H264_PROFILE_CONSTRAINED_HIGH``
      - Constrained High profile

.. raw:: latex

    \normalsize

.. _v4l2-mpeg-video-mpeg2-profile:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_mpeg2_profile -
    Thông tin hồ sơ của MPEG2. Áp dụng cho codec MPEG2.
    Các giá trị có thể là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{10.2cm}|p{7.3cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_MPEG2_PROFILE_SIMPLE``
      - Simple profile (SP)
    * - ``V4L2_MPEG_VIDEO_MPEG2_PROFILE_MAIN``
      - Main profile (MP)
    * - ``V4L2_MPEG_VIDEO_MPEG2_PROFILE_SNR_SCALABLE``
      - SNR Scalable profile (SNR)
    * - ``V4L2_MPEG_VIDEO_MPEG2_PROFILE_SPATIALLY_SCALABLE``
      - Spatially Scalable profile (Spt)
    * - ``V4L2_MPEG_VIDEO_MPEG2_PROFILE_HIGH``
      - High profile (HP)
    * - ``V4L2_MPEG_VIDEO_MPEG2_PROFILE_MULTIVIEW``
      - Multi-view profile (MVP)


.. raw:: latex

    \normalsize

.. _v4l2-mpeg-video-mpeg4-profile:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_mpeg4_profile -
    Thông tin hồ sơ của MPEG4. Áp dụng cho bộ mã hóa MPEG4.
    Các giá trị có thể là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{11.8cm}|p{5.7cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_MPEG4_PROFILE_SIMPLE``
      - Simple profile
    * - ``V4L2_MPEG_VIDEO_MPEG4_PROFILE_ADVANCED_SIMPLE``
      - Advanced Simple profile
    * - ``V4L2_MPEG_VIDEO_MPEG4_PROFILE_CORE``
      - Core profile
    * - ``V4L2_MPEG_VIDEO_MPEG4_PROFILE_SIMPLE_SCALABLE``
      - Simple Scalable profile
    * - ``V4L2_MPEG_VIDEO_MPEG4_PROFILE_ADVANCED_CODING_EFFICIENCY``
      - Advanced Coding Efficiency profile

.. raw:: latex

    \normalsize

ZZ0000ZZ
    Số lượng hình ảnh tham chiếu tối đa được sử dụng để mã hóa.
    Áp dụng cho bộ mã hóa.

.. _v4l2-mpeg-video-multi-slice-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_multi_slice_mode -
    Xác định cách bộ mã hóa sẽ xử lý việc phân chia khung thành
    lát. Áp dụng cho bộ mã hóa. Các giá trị có thể là:



.. tabularcolumns:: |p{9.6cm}|p{7.9cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_MULTI_SLICE_MODE_SINGLE``
      - Single slice per frame.
    * - ``V4L2_MPEG_VIDEO_MULTI_SLICE_MODE_MAX_MB``
      - Multiple slices with set maximum number of macroblocks per slice.
    * - ``V4L2_MPEG_VIDEO_MULTI_SLICE_MODE_MAX_BYTES``
      - Multiple slice with set maximum size in bytes per slice.



ZZ0000ZZ
    Số lượng macroblock tối đa trong một slice. Được sử dụng khi
    ZZ0001ZZ được đặt thành
    ZZ0002ZZ. Áp dụng cho
    bộ mã hóa.

ZZ0000ZZ
    Kích thước tối đa của một lát tính bằng byte. Được sử dụng khi
    ZZ0001ZZ được đặt thành
    ZZ0002ZZ. Áp dụng cho
    bộ mã hóa.

.. _v4l2-mpeg-video-h264-loop-filter-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_loop_filter_mode -
    Chế độ lọc vòng lặp cho bộ mã hóa H264. Các giá trị có thể là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{13.5cm}|p{4.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_LOOP_FILTER_MODE_ENABLED``
      - Loop filter is enabled.
    * - ``V4L2_MPEG_VIDEO_H264_LOOP_FILTER_MODE_DISABLED``
      - Loop filter is disabled.
    * - ``V4L2_MPEG_VIDEO_H264_LOOP_FILTER_MODE_DISABLED_AT_SLICE_BOUNDARY``
      - Loop filter is disabled at the slice boundary.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Hệ số alpha của bộ lọc vòng lặp, được xác định trong tiêu chuẩn H264.
    Giá trị này tương ứng với tiêu đề lát slice_alpha_c0_offset_div2
    trường và phải nằm trong phạm vi từ -6 đến +6. Alpha thực tế
    offset FilterOffsetA gấp đôi giá trị này.
    Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Hệ số beta của bộ lọc vòng lặp, được xác định trong tiêu chuẩn H264.
    Điều này tương ứng với trường tiêu đề lát slice_beta_offset_div2 và
    phải nằm trong khoảng từ -6 đến +6. Phần bù beta thực tế
    FilterOffsetB gấp đôi giá trị này.
    Áp dụng cho bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-entropy-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_entropy_mode -
    Chế độ mã hóa Entropy cho H264 - CABAC/CAVALC. Áp dụng cho H264
    bộ mã hóa. Các giá trị có thể là:


.. tabularcolumns:: |p{9.0cm}|p{8.5cm}|


.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_ENTROPY_MODE_CAVLC``
      - Use CAVLC entropy coding.
    * - ``V4L2_MPEG_VIDEO_H264_ENTROPY_MODE_CABAC``
      - Use CABAC entropy coding.



ZZ0000ZZ
    Kích hoạt chuyển đổi 8X8 cho H264. Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Bật dự đoán nội bộ bị ràng buộc cho H264. Áp dụng cho H264
    bộ mã hóa.

ZZ0000ZZ
    Chỉ định phần bù cần được thêm vào lượng tử hóa độ sáng
    tham số để xác định tham số lượng tử hóa sắc độ. Áp dụng
    đến bộ mã hóa H264.

ZZ0000ZZ
    Làm mới nội bộ macroblock theo chu kỳ. Đây là số lượng liên tục
    macroblocks được làm mới mọi khung hình. Mỗi khung hình là một tập hợp liên tiếp của
    macroblocks được làm mới cho đến khi chu trình hoàn thành và bắt đầu từ
    phía trên của khung. Đặt điều khiển này về 0 có nghĩa là
    macroblocks sẽ không được làm mới.  Lưu ý rằng điều khiển này sẽ không
    có hiệu lực khi điều khiển ZZ0001ZZ
    được đặt thành giá trị khác 0.
    Áp dụng cho bộ mã hóa H264, H263 và MPEG4.

ZZ0000ZZ

enum v4l2_mpeg_video_intra_refresh_ Period_type -
    Đặt kiểu làm mới nội bộ. Thời kỳ làm mới
    toàn bộ khung được chỉ định bởi V4L2_CID_MPEG_VIDEO_INTRA_REFRESH_PERIOD.
    Lưu ý rằng nếu điều khiển này không xuất hiện thì không xác định được điều gì
    loại làm mới được sử dụng và tùy thuộc vào người lái xe quyết định.
    Áp dụng cho bộ mã hóa H264 và HEVC. Các giá trị có thể là:

.. tabularcolumns:: |p{9.6cm}|p{7.9cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_INTRA_REFRESH_PERIOD_TYPE_RANDOM``
      - The whole frame is completely refreshed randomly
        after the specified period.
    * - ``V4L2_MPEG_VIDEO_INTRA_REFRESH_PERIOD_TYPE_CYCLIC``
      - The whole frame MBs are completely refreshed in cyclic order
        after the specified period.

ZZ0000ZZ
    Khoảng thời gian làm mới macroblock nội bộ. Điều này đặt khoảng thời gian để làm mới
    toàn bộ khung hình. Nói cách khác, điều này xác định số lượng khung hình
    mà toàn bộ khung sẽ được làm mới nội bộ.  Một ví dụ:
    khoảng thời gian cài đặt thành 1 có nghĩa là toàn bộ khung hình sẽ được làm mới,
    khoảng thời gian cài đặt thành 2 có nghĩa là một nửa số macroblock sẽ được
    được làm mới nội bộ trên frameX và nửa còn lại của macroblocks
    sẽ được làm mới trong frameX + 1, v.v. Đặt khoảng thời gian thành
    0 có nghĩa là không có khoảng thời gian nào được chỉ định.
    Lưu ý rằng nếu khách hàng đặt điều khiển này thành giá trị khác 0 thì
    Điều khiển ZZ0001ZZ sẽ được
    bị phớt lờ. Áp dụng cho bộ mã hóa H264 và HEVC.

ZZ0000ZZ
    Cho phép kiểm soát tốc độ khung hình. Nếu điều khiển này bị vô hiệu hóa thì
    tham số lượng tử hóa cho từng loại khung là không đổi và được đặt
    với các biện pháp kiểm soát thích hợp (ví dụ:
    ZZ0001ZZ). Nếu điều khiển tốc độ khung hình là
    được bật thì tham số lượng tử hóa được điều chỉnh để đáp ứng đã chọn
    tốc độ bit. Giá trị tối thiểu và tối đa cho tham số lượng tử hóa
    có thể được đặt bằng các điều khiển thích hợp (ví dụ:
    ZZ0002ZZ). Áp dụng cho bộ mã hóa.

ZZ0000ZZ
    Cho phép kiểm soát tốc độ cấp macroblock. Áp dụng cho MPEG4 và
    Bộ mã hóa H264.

ZZ0000ZZ
    Ước tính chuyển động một phần tư pixel cho MPEG4. Áp dụng cho MPEG4
    bộ mã hóa.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung I cho H263. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho H263. Phạm vi hợp lệ: từ 1 đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho H263. Phạm vi hợp lệ: từ 1 đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung P cho H263. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung B cho H263. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung I cho H264. Phạm vi hợp lệ: từ 0
    đến 51.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho H264. Phạm vi hợp lệ: từ 0 đến 51.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho H264. Phạm vi hợp lệ: từ 0 đến 51.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung P cho H264. Phạm vi hợp lệ: từ 0
    đến 51.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung B cho H264. Phạm vi hợp lệ: từ 0
    đến 51.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho khung H264 I để giới hạn khung I
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51. Nếu
    V4L2_CID_MPEG_VIDEO_H264_MIN_QP cũng được thiết lập, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho khung H264 I để giới hạn khung I
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51. Nếu
    V4L2_CID_MPEG_VIDEO_H264_MAX_QP cũng được thiết lập, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho khung P H264 để giới hạn khung P
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51. Nếu
    V4L2_CID_MPEG_VIDEO_H264_MIN_QP cũng được thiết lập, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho khung P H264 để giới hạn khung P
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51. Nếu
    V4L2_CID_MPEG_VIDEO_H264_MAX_QP cũng được thiết lập, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho khung B H264 để giới hạn khung B
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51. Nếu
    V4L2_CID_MPEG_VIDEO_H264_MIN_QP cũng được thiết lập, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho khung B H264 để giới hạn khung B
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51. Nếu
    V4L2_CID_MPEG_VIDEO_H264_MAX_QP cũng được thiết lập, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung I cho MPEG4. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho MPEG4. Phạm vi hợp lệ: từ 1 đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho MPEG4. Phạm vi hợp lệ: từ 1 đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung P cho MPEG4. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung B cho MPEG4. Phạm vi hợp lệ: từ 1
    đến 31.

.. _v4l2-mpeg-video-vbv-size:

ZZ0000ZZ
    Kích thước Trình xác minh bộ đệm video tính bằng kilobyte, nó được sử dụng làm
    hạn chế bỏ qua khung hình VBV được định nghĩa trong tiêu chuẩn là
    có nghĩa là để xác minh rằng luồng được tạo sẽ thành công
    đã được giải mã. Tiêu chuẩn mô tả nó là "Một phần của giả thuyết
    bộ giải mã được kết nối về mặt khái niệm với đầu ra của bộ mã hóa.
    Mục đích của nó là cung cấp một hạn chế về sự thay đổi của
    tốc độ dữ liệu mà bộ mã hóa hoặc quá trình chỉnh sửa có thể tạo ra.".
    Áp dụng cho các bộ mã hóa MPEG1, MPEG2, MPEG4.

.. _v4l2-mpeg-video-vbv-delay:

ZZ0000ZZ
    Đặt độ trễ ban đầu tính bằng mili giây cho điều khiển bộ đệm VBV.

.. _v4l2-mpeg-video-hor-search-range:

ZZ0000ZZ
    Phạm vi tìm kiếm theo chiều ngang xác định vùng tìm kiếm theo chiều ngang tối đa trong
    pixel để tìm kiếm và khớp với Macroblock (MB) hiện tại trong
    hình ảnh tham khảo. Macro điều khiển V4L2 này được sử dụng để đặt ngang
    phạm vi tìm kiếm mô-đun ước tính chuyển động trong bộ mã hóa video.

.. _v4l2-mpeg-video-vert-search-range:

ZZ0000ZZ
    Phạm vi tìm kiếm dọc xác định vùng tìm kiếm dọc tối đa tính bằng pixel
    để tìm kiếm và khớp với Macroblock (MB) hiện tại trong tài liệu tham khảo
    hình ảnh. Macro điều khiển V4L2 này được sử dụng để đặt tìm kiếm dọc
    phạm vi cho mô-đun ước tính chuyển động trong bộ mã hóa video.

.. _v4l2-mpeg-video-force-key-frame:

ZZ0000ZZ
    Buộc một khung chính cho bộ đệm được xếp hàng tiếp theo. Áp dụng cho
    bộ mã hóa. Đây là một điều khiển khung hình chính chung, không phụ thuộc vào codec.

.. _v4l2-mpeg-video-h264-cpb-size:

ZZ0000ZZ
    Kích thước Bộ đệm Ảnh được Mã hóa tính bằng kilobyte, nó được sử dụng làm
    hạn chế bỏ qua khung hình CPB được định nghĩa trong tiêu chuẩn H264 là
    một phương tiện để xác minh rằng luồng được tạo sẽ thành công
    đã được giải mã. Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Khoảng thời gian giữa các khung hình I trong GOP mở cho H264. Trong trường hợp mở
    GOP đây là khoảng thời gian giữa hai khung hình I. Khoảng thời gian giữa IDR
    Các khung hình (Làm mới giải mã tức thời) được lấy từ GOP_SIZE
    kiểm soát. Khung IDR, viết tắt của Giải mã tức thời
    Làm mới là khung I mà sau đó không có khung trước nào được tham chiếu.
    Điều này có nghĩa là luồng có thể được khởi động lại từ khung IDR mà không cần
    nhu cầu lưu trữ hoặc giải mã bất kỳ khung hình nào trước đó. Áp dụng cho
    Bộ mã hóa H264.

.. _v4l2-mpeg-video-header-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_header_mode -
    Xác định xem tiêu đề có được trả về làm bộ đệm đầu tiên hay không
    nó quay trở lại cùng với khung hình đầu tiên. Áp dụng cho bộ mã hóa.
    Các giá trị có thể là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{10.3cm}|p{7.2cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_HEADER_MODE_SEPARATE``
      - The stream header is returned separately in the first buffer.
    * - ``V4L2_MPEG_VIDEO_HEADER_MODE_JOINED_WITH_1ST_FRAME``
      - The stream header is returned together with the first encoded
	frame.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Lặp lại các tiêu đề chuỗi video. Việc lặp lại những tiêu đề này làm cho
    truy cập ngẫu nhiên vào luồng video dễ dàng hơn. Áp dụng cho MPEG1, 2
    và 4 bộ mã hóa.

ZZ0000ZZ
    Đã bật bộ lọc xử lý bài giải mã cho bộ giải mã MPEG4.
    Áp dụng cho bộ giải mã MPEG4.

ZZ0000ZZ
    giá trị vop_time_increment_address cho MPEG4. Áp dụng cho
    Bộ mã hóa MPEG4.

ZZ0000ZZ
    giá trị vop_time_increment cho MPEG4. Áp dụng cho MPEG4
    bộ mã hóa.

ZZ0000ZZ
    Cho phép tạo cải tiến bổ sung cho việc đóng gói khung
    thông tin trong dòng bit được mã hóa. Khung đóng gói tin nhắn SEI
    chứa sự sắp xếp của các mặt phẳng L và R để xem 3D.
    Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Đặt khung hiện tại là frame0 trong việc đóng gói khung SEI. Áp dụng cho
    Bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-sei-fp-arrangement-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_sei_fp_arrangement_type -
    Kiểu sắp xếp khung đóng gói cho H264 SEI. Áp dụng cho H264
    bộ mã hóa. Các giá trị có thể là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{12cm}|p{5.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_CHEKERBOARD``
      - Pixels are alternatively from L and R.
    * - ``V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_COLUMN``
      - L and R are interlaced by column.
    * - ``V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_ROW``
      - L and R are interlaced by row.
    * - ``V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_SIDE_BY_SIDE``
      - L is on the left, R on the right.
    * - ``V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_TOP_BOTTOM``
      - L is on top, R on bottom.
    * - ``V4L2_MPEG_VIDEO_H264_SEI_FP_ARRANGEMENT_TYPE_TEMPORAL``
      - One view per frame.

.. raw:: latex

    \normalsize



ZZ0000ZZ
    Cho phép sắp xếp macroblock linh hoạt trong dòng bit được mã hóa. Đó là
    một kỹ thuật được sử dụng để tái cấu trúc thứ tự của các macroblock trong
    hình ảnh. Áp dụng cho bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-fmo-map-type:

ZZ0000ZZ
   (enum)

enum v4l2_mpeg_video_h264_fmo_map_type -
    Khi sử dụng FMO, loại bản đồ sẽ chia hình ảnh theo các lần quét khác nhau
    mô hình của macroblocks. Áp dụng cho bộ mã hóa H264. Có thể
    giá trị là:

.. raw:: latex

    \small

.. tabularcolumns:: |p{12.5cm}|p{5.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_INTERLEAVED_SLICES``
      - Slices are interleaved one after other with macroblocks in run
	length order.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_SCATTERED_SLICES``
      - Scatters the macroblocks based on a mathematical function known to
	both encoder and decoder.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_FOREGROUND_WITH_LEFT_OVER``
      - Macroblocks arranged in rectangular areas or regions of interest.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_BOX_OUT``
      - Slice groups grow in a cyclic way from centre to outwards.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_RASTER_SCAN``
      - Slice groups grow in raster scan pattern from left to right.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_WIPE_SCAN``
      - Slice groups grow in wipe scan pattern from top to bottom.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_MAP_TYPE_EXPLICIT``
      - User defined map type.

.. raw:: latex

    \normalsize



ZZ0000ZZ
    Số nhóm lát cắt trong FMO. Áp dụng cho bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-fmo-change-direction:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_fmo_change_dir -
    Chỉ định hướng thay đổi nhóm lát cắt cho raster và xóa
    bản đồ. Áp dụng cho bộ mã hóa H264. Các giá trị có thể là:

.. tabularcolumns:: |p{9.6cm}|p{7.9cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_FMO_CHANGE_DIR_RIGHT``
      - Raster scan or wipe right.
    * - ``V4L2_MPEG_VIDEO_H264_FMO_CHANGE_DIR_LEFT``
      - Reverse raster scan or wipe left.



ZZ0000ZZ
    Chỉ định kích thước của nhóm lát cắt đầu tiên cho bản đồ raster và lau.
    Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Chỉ định số lượng macroblock liên tiếp cho các macro được xen kẽ
    bản đồ. Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Cho phép sắp xếp lát cắt tùy ý trong dòng bit được mã hóa. Áp dụng cho
    bộ mã hóa H264.

ZZ0000ZZ
    Chỉ định thứ tự lát trong ASO. Áp dụng cho bộ mã hóa H264.
    Số nguyên 32 bit được cung cấp được hiểu như sau (bit 0 = nhỏ nhất
    bit đáng kể):



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - Bit 0:15
      - Slice ID
    * - Bit 16:32
      - Slice position or order



ZZ0000ZZ
    Cho phép mã hóa phân cấp H264. Áp dụng cho bộ mã hóa H264.

.. _v4l2-mpeg-video-h264-hierarchical-coding-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_h264_hierarchical_coding_type -
    Chỉ định loại mã hóa phân cấp. Áp dụng cho H264
    bộ mã hóa. Các giá trị có thể là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_H264_HIERARCHICAL_CODING_B``
      - Hierarchical B coding.
    * - ``V4L2_MPEG_VIDEO_H264_HIERARCHICAL_CODING_P``
      - Hierarchical P coding.



ZZ0000ZZ
    Chỉ định số lớp mã hóa phân cấp. Áp dụng cho
    bộ mã hóa H264.

ZZ0000ZZ
    Chỉ định QP do người dùng xác định cho mỗi lớp. Áp dụng cho H264
    bộ mã hóa. Số nguyên 32 bit được cung cấp được hiểu như sau (bit
    0 = bit có ý nghĩa nhỏ nhất):



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - Bit 0:15
      - QP value
    * - Bit 16:32
      - Layer number

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 0 cho bộ mã hóa H264.

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 1 cho bộ mã hóa H264.

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 2 cho bộ mã hóa H264.

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 3 cho bộ mã hóa H264.

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 4 cho bộ mã hóa H264.

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 5 cho bộ mã hóa H264.

ZZ0000ZZ
    Biểu thị tốc độ bit (bps) cho lớp mã hóa phân cấp 6 cho bộ mã hóa H264.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung I cho FWHT. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung P cho FWHT. Phạm vi hợp lệ: từ 1
    đến 31.

ZZ0000ZZ
    Điều khiển chỉ đọc này trả về giá trị QP trung bình của dữ liệu hiện tại
    khung được mã hóa. Giá trị áp dụng cho bộ đệm chụp đã được loại bỏ cuối cùng
    (VIDIOC_DQBUF). Phạm vi hợp lệ của nó phụ thuộc vào định dạng và tham số mã hóa.
    Đối với H264, phạm vi hợp lệ của nó là từ 0 đến 51.
    Đối với HEVC, phạm vi hợp lệ của nó là từ 0 đến 51 đối với 8 bit và
    từ 0 đến 63 trong 10 bit.
    Đối với H263 và MPEG4, phạm vi hợp lệ của nó là từ 1 đến 31.
    Đối với VP8, phạm vi hợp lệ của nó là từ 0 đến 127.
    Đối với VP9, phạm vi hợp lệ của nó là từ 0 đến 255.
    Nếu MIN_QP và MAX_QP của codec được đặt thì QP sẽ đáp ứng cả hai yêu cầu.
    Codec cần phải luôn sử dụng phạm vi được chỉ định, thay vì phạm vi tùy chỉnh CTNH.
    Áp dụng cho bộ mã hóa

.. raw:: latex

    \normalsize


Điều khiển MFC 5.1 MPEG
=====================

Các điều khiển lớp MPEG sau đây xử lý việc giải mã và mã hóa MPEG
hiện có các cài đặt dành riêng cho thiết bị Multi Format Codec 5.1
trong dòng SoC S5P của Samsung.


.. _mfc51-control-id:

ID điều khiển MFC 5.1
-------------------

ZZ0000ZZ
    Nếu độ trễ hiển thị được bật thì bộ giải mã buộc phải quay lại
    bộ đệm CAPTURE (khung được giải mã) sau khi xử lý một số nhất định
    của bộ đệm OUTPUT. Độ trễ có thể được thiết lập thông qua
    ZZ0001ZZ. Cái này
    tính năng này có thể được sử dụng chẳng hạn để tạo hình thu nhỏ của video.
    Áp dụng cho bộ giải mã H264.

    .. note::

       This control is deprecated. Use the standard
       ``V4L2_CID_MPEG_VIDEO_DEC_DISPLAY_DELAY_ENABLE`` control instead.

ZZ0000ZZ
    Hiển thị giá trị độ trễ cho bộ giải mã H264. Bộ giải mã buộc phải
    trả về khung đã giải mã sau số 'độ trễ hiển thị' đã đặt của
    khung. Nếu con số này thấp, nó có thể dẫn đến việc trả về các khung hình
    theo thứ tự hiển thị, ngoài ra phần cứng có thể vẫn đang sử dụng
    bộ đệm được trả về làm ảnh tham chiếu cho các khung tiếp theo.

    .. note::

       This control is deprecated. Use the standard
       ``V4L2_CID_MPEG_VIDEO_DEC_DISPLAY_DELAY`` control instead.

ZZ0000ZZ
    Số lượng ảnh tham chiếu được sử dụng để mã hóa ảnh P.
    Áp dụng cho bộ mã hóa H264.

ZZ0000ZZ
    Kích hoạt phần đệm trong bộ mã hóa - sử dụng màu thay vì lặp lại
    pixel viền. Áp dụng cho bộ mã hóa.

ZZ0000ZZ
    Màu đệm trong bộ mã hóa. Áp dụng cho bộ mã hóa. Được cung cấp
    Số nguyên 32 bit được hiểu như sau (bit 0 = ít quan trọng nhất
    chút):



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - Bit 0:7
      - V chrominance information
    * - Bit 8:15
      - U chrominance information
    * - Bit 16:23
      - Y luminance information
    * - Bit 24:31
      - Must be zero.



ZZ0000ZZ
    Hệ số phản ứng để kiểm soát tốc độ MFC. Áp dụng cho bộ mã hóa.

    .. note::

       #. Valid only when the frame level RC is enabled.

       #. For tight CBR, this field must be small (ex. 2 ~ 10). For
VBR, trường này phải lớn (ví dụ: 100 ~ 1000).

#. Không nên sử dụng số lượng lớn hơn
	  FRAME_RATE * (10^9 / BIT_RATE).

ZZ0000ZZ
    Kiểm soát tốc độ thích ứng cho vùng tối. Chỉ hợp lệ khi H.264 và
    RC cấp độ macroblock được bật
    (ZZ0001ZZ). Áp dụng cho H264
    bộ mã hóa.

ZZ0000ZZ
    Kiểm soát tốc độ thích ứng cho vùng trơn tru. Chỉ hợp lệ khi H.264 và
    RC cấp độ macroblock được bật
    (ZZ0001ZZ). Áp dụng cho H264
    bộ mã hóa.

ZZ0000ZZ
    Kiểm soát tốc độ thích ứng cho vùng tĩnh. Chỉ hợp lệ khi H.264 và
    RC cấp độ macroblock được bật
    (ZZ0001ZZ). Áp dụng cho H264
    bộ mã hóa.

ZZ0000ZZ
    Kiểm soát tốc độ thích ứng cho khu vực hoạt động. Chỉ hợp lệ khi H.264 và
    RC cấp độ macroblock được bật
    (ZZ0001ZZ). Áp dụng cho H264
    bộ mã hóa.

.. _v4l2-mpeg-mfc51-video-frame-skip-mode:

ZZ0000ZZ
    (enum)

    .. note::

       This control is deprecated. Use the standard
       ``V4L2_CID_MPEG_VIDEO_FRAME_SKIP_MODE`` control instead.

enum v4l2_mpeg_mfc51_video_frame_skip_mode -
    Cho biết điều kiện nào bộ mã hóa nên bỏ qua khung. Nếu
    mã hóa một khung sẽ làm cho luồng được mã hóa lớn hơn một khung
    giới hạn dữ liệu đã chọn thì khung sẽ bị bỏ qua. Giá trị có thể
    là:


.. tabularcolumns:: |p{9.4cm}|p{8.1cm}|

.. raw:: latex

    \small

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE_DISABLED``
      - Frame skip mode is disabled.
    * - ``V4L2_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE_LEVEL_LIMIT``
      - Frame skip mode enabled and buffer limit is set by the chosen
	level and is defined by the standard.
    * - ``V4L2_MPEG_MFC51_VIDEO_FRAME_SKIP_MODE_BUF_LIMIT``
      - Frame skip mode enabled and buffer limit is set by the VBV
	(MPEG1/2/4) or CPB (H264) buffer size control.

.. raw:: latex

    \normalsize

ZZ0000ZZ
    Cho phép kiểm soát tốc độ với bit mục tiêu cố định. Nếu cài đặt này là
    được bật thì logic điều khiển tốc độ của bộ mã hóa sẽ tính toán
    tốc độ bit trung bình cho GOP và giữ nó ở mức dưới hoặc bằng mức đã đặt
    mục tiêu tốc độ bit. Mặt khác, logic điều khiển tốc độ sẽ tính toán
    tốc độ bit trung bình tổng thể cho luồng và giữ nó ở mức dưới hoặc bằng
    theo tốc độ bit đã đặt. Trong trường hợp đầu tiên, tốc độ bit trung bình cho
    toàn bộ luồng sẽ nhỏ hơn tốc độ bit đã đặt. Điều này được gây ra
    bởi vì mức trung bình được tính cho số lượng khung hình nhỏ hơn, trên
    mặt khác, việc bật cài đặt này sẽ đảm bảo rằng luồng
    sẽ đáp ứng các hạn chế về băng thông chặt chẽ. Áp dụng cho bộ mã hóa.

.. _v4l2-mpeg-mfc51-video-force-frame-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_mfc51_video_force_frame_type -
    Buộc loại khung cho bộ đệm được xếp hàng tiếp theo. Áp dụng cho
    bộ mã hóa. Các giá trị có thể là:

.. tabularcolumns:: |p{9.9cm}|p{7.6cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_MFC51_FORCE_FRAME_TYPE_DISABLED``
      - Forcing a specific frame type disabled.
    * - ``V4L2_MPEG_MFC51_FORCE_FRAME_TYPE_I_FRAME``
      - Force an I-frame.
    * - ``V4L2_MPEG_MFC51_FORCE_FRAME_TYPE_NOT_CODED``
      - Force a non-coded frame.


Bộ điều khiển CX2341x MPEG
=====================

Các điều khiển lớp MPEG sau đây xử lý các cài đặt mã hóa MPEG
dành riêng cho chip mã hóa Conexant CX23415 và CX23416 MPEG.


.. _cx2341x-control-id:

ID điều khiển CX2341x
-------------------

.. _v4l2-mpeg-cx2341x-video-spatial-filter-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_cx2341x_video_spatial_filter_mode -
    Đặt chế độ Bộ lọc không gian (ZZ0000ZZ mặc định). Giá trị có thể
    là:


.. tabularcolumns:: |p{11.5cm}|p{6.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_CX2341X_VIDEO_SPATIAL_FILTER_MODE_MANUAL``
      - Choose the filter manually
    * - ``V4L2_MPEG_CX2341X_VIDEO_SPATIAL_FILTER_MODE_AUTO``
      - Choose the filter automatically



ZZ0000ZZ
    Cài đặt cho Bộ lọc không gian. 0 = tắt, 15 = tối đa. (Mặc định
    là 0.)

.. _luma-spatial-filter-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_cx2341x_video_luma_spatial_filter_type -
    Chọn thuật toán sử dụng cho Luma Spatial Filter (mặc định
    ZZ0000ZZ). Các giá trị có thể:

.. tabularcolumns:: |p{13.1cm}|p{4.4cm}|

.. raw:: latex

    \footnotesize

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_OFF``
      - No filter
    * - ``V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_1D_HOR``
      - One-dimensional horizontal
    * - ``V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_1D_VERT``
      - One-dimensional vertical
    * - ``V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_2D_HV_SEPARABLE``
      - Two-dimensional separable
    * - ``V4L2_MPEG_CX2341X_VIDEO_LUMA_SPATIAL_FILTER_TYPE_2D_SYM_NON_SEPARABLE``
      - Two-dimensional symmetrical non-separable

.. raw:: latex

    \normalsize

.. _chroma-spatial-filter-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_cx2341x_video_chroma_spatial_filter_type -
    Chọn thuật toán cho Bộ lọc không gian Chroma (mặc định
    ZZ0000ZZ). Các giá trị có thể là:

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{11.0cm}|p{6.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_CX2341X_VIDEO_CHROMA_SPATIAL_FILTER_TYPE_OFF``
      - No filter
    * - ``V4L2_MPEG_CX2341X_VIDEO_CHROMA_SPATIAL_FILTER_TYPE_1D_HOR``
      - One-dimensional horizontal

.. raw:: latex

    \normalsize

.. _v4l2-mpeg-cx2341x-video-temporal-filter-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_cx2341x_video_temporal_filter_mode -
    Đặt chế độ Bộ lọc tạm thời (ZZ0000ZZ mặc định). Giá trị có thể
    là:

.. raw:: latex

    \footnotesize

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_CX2341X_VIDEO_TEMPORAL_FILTER_MODE_MANUAL``
      - Choose the filter manually
    * - ``V4L2_MPEG_CX2341X_VIDEO_TEMPORAL_FILTER_MODE_AUTO``
      - Choose the filter automatically

.. raw:: latex

    \normalsize

ZZ0000ZZ
    Cài đặt cho Bộ lọc tạm thời. 0 = tắt, 31 = tối đa. (Mặc định
    là 8 để chụp ở quy mô đầy đủ và 0 để chụp theo tỷ lệ.)

.. _v4l2-mpeg-cx2341x-video-median-filter-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_cx2341x_video_median_filter_type -
    Loại bộ lọc trung vị (ZZ0000ZZ mặc định). Các giá trị có thể là:


.. raw:: latex

    \small

.. tabularcolumns:: |p{11.0cm}|p{6.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_OFF``
      - No filter
    * - ``V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_HOR``
      - Horizontal filter
    * - ``V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_VERT``
      - Vertical filter
    * - ``V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_HOR_VERT``
      - Horizontal and vertical filter
    * - ``V4L2_MPEG_CX2341X_VIDEO_MEDIAN_FILTER_TYPE_DIAG``
      - Diagonal filter

.. raw:: latex

    \normalsize

ZZ0000ZZ
    Ngưỡng trên đó bộ lọc độ sáng trung bình được bật
    (mặc định 0)

ZZ0000ZZ
    Ngưỡng dưới mức mà bộ lọc trung vị độ chói được bật
    (mặc định 255)

ZZ0000ZZ
    Ngưỡng trên đó bộ lọc sắc độ trung bình được bật (mặc định
    0)

ZZ0000ZZ
    Ngưỡng dưới đó bộ lọc sắc độ trung bình được bật (mặc định
    255)

ZZ0000ZZ
    Bộ mã hóa CX2341X MPEG có thể chèn một gói MPEG-2 PES trống vào
    luồng giữa bốn khung hình video. Kích thước gói là 2048
    byte, bao gồm packet_start_code_prefix và stream_id
    lĩnh vực. Stream_id là 0xBF (luồng riêng tư 2). Tải trọng
    bao gồm 0x00 byte, được ứng dụng điền vào. 0 = làm
    không chèn, 1 = chèn gói.


Tham khảo điều khiển VPX
=====================

Bộ điều khiển VPX bao gồm các bộ điều khiển mã hóa thông số của video VPx
codec.


.. _vpx-control-id:

ID điều khiển VPX
---------------

.. _v4l2-vpx-num-partitions:

ZZ0000ZZ
    (enum)

enum v4l2_vp8_num_partitions -
    Số lượng phân vùng mã thông báo sẽ sử dụng trong bộ mã hóa VP8. Có thể
    giá trị là:



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_CID_MPEG_VIDEO_VPX_1_PARTITION``
      - 1 coefficient partition
    * - ``V4L2_CID_MPEG_VIDEO_VPX_2_PARTITIONS``
      - 2 coefficient partitions
    * - ``V4L2_CID_MPEG_VIDEO_VPX_4_PARTITIONS``
      - 4 coefficient partitions
    * - ``V4L2_CID_MPEG_VIDEO_VPX_8_PARTITIONS``
      - 8 coefficient partitions



ZZ0000ZZ
    Cài đặt này sẽ ngăn chế độ nội bộ 4x4 trong quyết định chế độ nội bộ.

.. _v4l2-vpx-num-ref-frames:

ZZ0000ZZ
    (enum)

enum v4l2_vp8_num_ref_frames -
    Số lượng ảnh tham chiếu để mã hóa khung P. Có thể
    giá trị là:

.. tabularcolumns:: |p{7.5cm}|p{7.5cm}|

.. raw:: latex

    \small

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_CID_MPEG_VIDEO_VPX_1_REF_FRAME``
      - Last encoded frame will be searched
    * - ``V4L2_CID_MPEG_VIDEO_VPX_2_REF_FRAME``
      - Two frames will be searched among the last encoded frame, the
	golden frame and the alternate reference (altref) frame. The
	encoder implementation will decide which two are chosen.
    * - ``V4L2_CID_MPEG_VIDEO_VPX_3_REF_FRAME``
      - The last encoded frame, the golden frame and the altref frame will
	be searched.

.. raw:: latex

    \normalsize



ZZ0000ZZ
    Cho biết mức độ bộ lọc vòng lặp. Điều chỉnh bộ lọc vòng lặp
    mức được thực hiện thông qua giá trị delta so với bộ lọc vòng lặp cơ sở
    giá trị.

ZZ0000ZZ
    Tham số này ảnh hưởng đến bộ lọc vòng lặp. Mọi thứ trên 0 đều yếu đi
    hiệu ứng giải khối trên bộ lọc vòng lặp.

ZZ0000ZZ
    Đặt khoảng thời gian làm mới cho khung vàng. Khoảng thời gian được xác định
    về số lượng khung hình. Với giá trị 'n', mỗi khung hình thứ n bắt đầu
    từ khung khóa đầu tiên sẽ được lấy làm khung vàng. Ví dụ:
    để mã hóa chuỗi 0, 1, 2, 3, 4, 5, 6, 7 trong đó màu vàng
    Khoảng thời gian làm mới khung được đặt là 4, các khung 0, 4, 8, v.v. sẽ được
    được lấy làm khung vàng vì khung 0 luôn là khung chính.

.. _v4l2-vpx-golden-frame-sel:

ZZ0000ZZ
    (enum)

enum v4l2_vp8_golden_frame_sel -
    Chọn khung vàng để mã hóa. Các giá trị có thể là:

.. raw:: latex

    \scriptsize

.. tabularcolumns:: |p{8.6cm}|p{8.9cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_USE_PREV``
      - Use the (n-2)th frame as a golden frame, current frame index being
	'n'.
    * - ``V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_USE_REF_PERIOD``
      - Use the previous specific frame indicated by
	``V4L2_CID_MPEG_VIDEO_VPX_GOLDEN_FRAME_REF_PERIOD`` as a
	golden frame.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho VP8.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho VP8.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung I cho VP8.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung P cho VP8.

.. _v4l2-mpeg-video-vp8-profile:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_vp8_profile -
    Điều khiển này cho phép chọn cấu hình cho bộ mã hóa VP8.
    Điều này cũng được sử dụng để liệt kê các cấu hình được hỗ trợ bởi bộ mã hóa hoặc giải mã VP8.
    Các giá trị có thể là:

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_VP8_PROFILE_0``
      - Profile 0
    * - ``V4L2_MPEG_VIDEO_VP8_PROFILE_1``
      - Profile 1
    * - ``V4L2_MPEG_VIDEO_VP8_PROFILE_2``
      - Profile 2
    * - ``V4L2_MPEG_VIDEO_VP8_PROFILE_3``
      - Profile 3

.. _v4l2-mpeg-video-vp9-profile:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_vp9_profile -
    Điều khiển này cho phép chọn cấu hình cho bộ mã hóa VP9.
    Điều này cũng được sử dụng để liệt kê các cấu hình được hỗ trợ bởi bộ mã hóa hoặc giải mã VP9.
    Các giá trị có thể là:

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_VP9_PROFILE_0``
      - Profile 0
    * - ``V4L2_MPEG_VIDEO_VP9_PROFILE_1``
      - Profile 1
    * - ``V4L2_MPEG_VIDEO_VP9_PROFILE_2``
      - Profile 2
    * - ``V4L2_MPEG_VIDEO_VP9_PROFILE_3``
      - Profile 3

.. _v4l2-mpeg-video-vp9-level:

ZZ0000ZZ

enum v4l2_mpeg_video_vp9_level -
    Điều khiển này cho phép chọn mức cho bộ mã hóa VP9.
    Điều này cũng được sử dụng để liệt kê các mức được hỗ trợ bởi bộ mã hóa hoặc giải mã VP9.
    Thông tin thêm có thể được tìm thấy tại
    ZZ0000ZZ. Các giá trị có thể là:

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_1_0``
      - Level 1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_1_1``
      - Level 1.1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_2_0``
      - Level 2
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_2_1``
      - Level 2.1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_3_0``
      - Level 3
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_3_1``
      - Level 3.1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_4_0``
      - Level 4
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_4_1``
      - Level 4.1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_5_0``
      - Level 5
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_5_1``
      - Level 5.1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_5_2``
      - Level 5.2
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_6_0``
      - Level 6
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_6_1``
      - Level 6.1
    * - ``V4L2_MPEG_VIDEO_VP9_LEVEL_6_2``
      - Level 6.2


Tham khảo điều khiển mã hóa video hiệu quả cao (HEVC/H.265)
===========================================================

Bộ điều khiển HEVC/H.265 bao gồm các bộ điều khiển dành cho các tham số mã hóa của HEVC/H.265
bộ giải mã video.


.. _hevc-control-id:

ID điều khiển HEVC/H.265
----------------------

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho HEVC.
    Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho HEVC.
    Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.

ZZ0000ZZ
    Tham số lượng tử hóa cho khung I cho HEVC.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Tham số lượng tử hóa cho khung P cho HEVC.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Tham số lượng tử hóa cho khung B cho HEVC.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho khung HEVC I để giới hạn khung I
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.
    Nếu V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP cũng được đặt, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho khung HEVC I để giới hạn khung I
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.
    Nếu V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP cũng được đặt, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho khung P HEVC để giới hạn khung P
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.
    Nếu V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP cũng được đặt, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho khung P HEVC để giới hạn khung P
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.
    Nếu V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP cũng được đặt, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối thiểu cho khung B HEVC để giới hạn khung B
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.
    Nếu V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP cũng được đặt, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    Tham số lượng tử hóa tối đa cho khung B HEVC để giới hạn khung B
    chất lượng đến một phạm vi. Phạm vi hợp lệ: từ 0 đến 51 cho 8 bit và từ 0 đến 63 cho 10 bit.
    Nếu V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP cũng được đặt, tham số lượng tử hóa
    nên được chọn để đáp ứng cả hai yêu cầu.

ZZ0000ZZ
    HIERARCHICAL_QP cho phép máy chủ chỉ định tham số lượng tử hóa
    giá trị cho từng lớp thời gian thông qua HIERARCHICAL_QP_LAYER. Đây là
    chỉ hợp lệ nếu HIERARCHICAL_CODING_LAYER lớn hơn 1. Đặt
    giá trị điều khiển thành 1 cho phép thiết lập giá trị QP cho các lớp.

.. _v4l2-hevc-hier-coding-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_hevc_hier_coding_type -
    Chọn loại mã hóa phân cấp để mã hóa. Các giá trị có thể là:

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{8.2cm}|p{9.3cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_HEVC_HIERARCHICAL_CODING_B``
      - Use the B frame for hierarchical coding.
    * - ``V4L2_MPEG_VIDEO_HEVC_HIERARCHICAL_CODING_P``
      - Use the P frame for hierarchical coding.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Chọn lớp mã hóa phân cấp. Trong mã hóa thông thường
    (mã hóa không phân cấp), nó phải bằng 0. Các giá trị có thể là [0, 6].
    0 biểu thị HIERARCHICAL CODING LAYER 0, 1 biểu thị HIERARCHICAL CODING
    LAYER 1, v.v.

ZZ0000ZZ
    Chỉ ra tham số lượng tử hóa cho lớp mã hóa phân cấp 0.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Biểu thị tham số lượng tử hóa cho lớp mã hóa phân cấp 1.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Biểu thị tham số lượng tử hóa cho lớp mã hóa phân cấp 2.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Biểu thị tham số lượng tử hóa cho lớp mã hóa phân cấp 3.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Chỉ ra tham số lượng tử hóa cho lớp mã hóa phân cấp 4.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Chỉ ra tham số lượng tử hóa cho lớp mã hóa phân cấp 5.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

ZZ0000ZZ
    Chỉ ra tham số lượng tử hóa cho lớp mã hóa phân cấp 6.
    Phạm vi hợp lệ: [V4L2_CID_MPEG_VIDEO_HEVC_MIN_QP,
    V4L2_CID_MPEG_VIDEO_HEVC_MAX_QP].

.. _v4l2-hevc-profile:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_hevc_profile -
    Chọn cấu hình mong muốn cho bộ mã hóa HEVC.

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{9.0cm}|p{8.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_HEVC_PROFILE_MAIN``
      - Main profile.
    * - ``V4L2_MPEG_VIDEO_HEVC_PROFILE_MAIN_STILL_PICTURE``
      - Main still picture profile.
    * - ``V4L2_MPEG_VIDEO_HEVC_PROFILE_MAIN_10``
      - Main 10 profile.

.. raw:: latex

    \normalsize


.. _v4l2-hevc-level:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_hevc_level -
    Chọn mức mong muốn cho bộ mã hóa HEVC.

===============================================
ZZ0000ZZ Cấp 1.0
ZZ0001ZZ Cấp 2.0
ZZ0002ZZ Cấp 2.1
ZZ0003ZZ Cấp 3.0
ZZ0004ZZ Cấp 3.1
ZZ0005ZZ Cấp 4.0
ZZ0006ZZ Cấp 4.1
ZZ0007ZZ Cấp 5.0
ZZ0008ZZ Cấp 5.1
ZZ0009ZZ Cấp 5.2
ZZ0010ZZ Cấp 6.0
ZZ0011ZZ Cấp 6.1
ZZ0012ZZ Cấp 6.2
===============================================

ZZ0000ZZ
    Cho biết số khoảng con cách đều nhau, được gọi là dấu tích, trong
    một giây. Đây là số nguyên không dấu 16 bit và có giá trị tối đa lên tới
    0xffff và giá trị tối thiểu là 1.

.. _v4l2-hevc-tier:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_hevc_tier -
    TIER_FLAG chỉ định thông tin cấp độ của hình ảnh được mã hóa HEVC. cấp
    được thực hiện để xử lý các ứng dụng khác nhau về bit tối đa
    tỷ lệ. Đặt cờ thành 0 sẽ chọn cấp HEVC làm cấp chính và cài đặt
    cờ này thành 1 biểu thị Cấp cao. Cấp cao dành cho các ứng dụng yêu cầu
    tốc độ bit cao.

================================================
ZZ0000ZZ Tầng chính.
ZZ0001ZZ Cấp cao.
================================================


ZZ0000ZZ
    Chọn độ sâu đơn vị mã hóa tối đa HEVC.

.. _v4l2-hevc-loop-filter-mode:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_hevc_loop_filter_mode -
    Chế độ lọc vòng lặp cho bộ mã hóa HEVC. Các giá trị có thể là:

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{12.1cm}|p{5.4cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_HEVC_LOOP_FILTER_MODE_DISABLED``
      - Loop filter is disabled.
    * - ``V4L2_MPEG_VIDEO_HEVC_LOOP_FILTER_MODE_ENABLED``
      - Loop filter is enabled.
    * - ``V4L2_MPEG_VIDEO_HEVC_LOOP_FILTER_MODE_DISABLED_AT_SLICE_BOUNDARY``
      - Loop filter is disabled at the slice boundary.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Chọn phần bù beta của bộ lọc vòng lặp HEVC. Phạm vi hợp lệ là [-6, +6].

ZZ0000ZZ
    Chọn phần bù tc của bộ lọc vòng lặp HEVC. Phạm vi hợp lệ là [-6, +6].

.. _v4l2-hevc-refresh-type:

ZZ0000ZZ
    (enum)

enum v4l2_mpeg_video_hevc_hier_refresh_type -
    Chọn kiểu làm mới cho bộ mã hóa HEVC.
    Máy chủ phải chỉ định khoảng thời gian vào
    V4L2_CID_MPEG_VIDEO_HEVC_REFRESH_PERIOD.

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{6.2cm}|p{11.3cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_HEVC_REFRESH_NONE``
      - Use the B frame for hierarchical coding.
    * - ``V4L2_MPEG_VIDEO_HEVC_REFRESH_CRA``
      - Use CRA (Clean Random Access Unit) picture encoding.
    * - ``V4L2_MPEG_VIDEO_HEVC_REFRESH_IDR``
      - Use IDR (Instantaneous Decoding Refresh) picture encoding.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Chọn khoảng thời gian làm mới cho bộ mã hóa HEVC.
    Điều này chỉ định số lượng ảnh I giữa hai ảnh CRA/IDR.
    Điều này chỉ hợp lệ nếu REFRESH_TYPE khác 0.

ZZ0000ZZ
    Cho biết mã hóa không mất dữ liệu HEVC. Đặt nó thành 0 sẽ vô hiệu hóa lossless
    mã hóa. Đặt nó thành 1 sẽ cho phép mã hóa không mất dữ liệu.

ZZ0000ZZ
    Cho biết dự đoán nội bộ không đổi cho bộ mã hóa HEVC. Chỉ định
    dự đoán nội bộ bị ràng buộc trong đó đơn vị mã hóa nội bộ lớn nhất (LCU)
    dự đoán được thực hiện bằng cách sử dụng dữ liệu dư và các mẫu được giải mã của
    chỉ bên trong LCU lân cận. Đặt giá trị thành 1 cho phép nội bộ không đổi
    dự đoán và đặt giá trị thành 0 sẽ vô hiệu hóa dự đoán nội bộ liên tục.

ZZ0000ZZ
    Biểu thị quá trình xử lý song song mặt sóng cho bộ mã hóa HEVC. Đặt nó thành 0
    tắt tính năng này và đặt nó thành 1 sẽ bật tính năng song song mặt sóng
    xử lý.

ZZ0000ZZ
    Đặt giá trị thành 1 cho phép kết hợp khung P và B cho HEVC
    bộ mã hóa.

ZZ0000ZZ
    Cho biết mã định danh tạm thời cho bộ mã hóa HEVC được bật bởi
    đặt giá trị thành 1.

ZZ0000ZZ
    Cho biết nội suy song tuyến tính được sử dụng có điều kiện trong nội bộ
    quá trình lọc dự đoán trong CVS khi được đặt thành 1. Biểu thị hai tuyến tính
    nội suy không được sử dụng trong CVS khi được đặt thành 0.

ZZ0000ZZ
    Cho biết số lượng vectơ chuyển động ứng cử viên hợp nhất tối đa.
    Các giá trị là từ 0 đến 4.

ZZ0000ZZ
    Biểu thị dự đoán vectơ chuyển động theo thời gian cho bộ mã hóa HEVC. Đặt nó thành
    1 cho phép dự đoán. Đặt nó thành 0 sẽ vô hiệu hóa dự đoán.

ZZ0000ZZ
    Chỉ định xem HEVC có tạo luồng có kích thước của trường độ dài hay không
    thay vì mẫu mã bắt đầu. Kích thước của trường độ dài có thể được cấu hình
    thông qua điều khiển V4L2_CID_MPEG_VIDEO_HEVC_SIZE_OF_LENGTH_FIELD. Cài đặt
    giá trị thành 0 sẽ vô hiệu hóa mã hóa mà không có mẫu mã bắt đầu. Thiết lập
    giá trị thành 1 sẽ cho phép mã hóa mà không cần mẫu mã bắt đầu.

.. _v4l2-hevc-size-of-length-field:

ZZ0000ZZ
(enum)

enum v4l2_mpeg_video_hevc_size_of_length_field -
    Cho biết kích thước của trường độ dài.
    Điều này hợp lệ khi mã hóa WITHOUT_STARTCODE_ENABLE được bật.

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{5.5cm}|p{12.0cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_MPEG_VIDEO_HEVC_SIZE_0``
      - Generate start code pattern (Normal).
    * - ``V4L2_MPEG_VIDEO_HEVC_SIZE_1``
      - Generate size of length field instead of start code pattern and length is 1.
    * - ``V4L2_MPEG_VIDEO_HEVC_SIZE_2``
      - Generate size of length field instead of start code pattern and length is 2.
    * - ``V4L2_MPEG_VIDEO_HEVC_SIZE_4``
      - Generate size of length field instead of start code pattern and length is 4.

.. raw:: latex

    \normalsize

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 0 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 1 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 2 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 3 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 4 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 5 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Biểu thị tốc độ bit cho lớp mã hóa phân cấp 6 cho bộ mã hóa HEVC.

ZZ0000ZZ
    Chọn số lượng ảnh tham chiếu P cần thiết cho bộ mã hóa HEVC.
    P-Frame có thể sử dụng 1 hoặc 2 khung hình để tham khảo.

ZZ0000ZZ
    Cho biết có tạo SPS và PPS ở mọi IDR hay không. Đặt nó thành 0
    vô hiệu hóa việc tạo SPS và PPS ở mọi IDR. Đặt nó thành một cho phép
    tạo SPS và PPS tại mọi IDR.