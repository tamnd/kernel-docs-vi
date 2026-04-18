.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later OR GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/legacy_dvb_audio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: dtv.legacy.audio

.. _dvb_audio:

==================
Thiết bị âm thanh DVB
================

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Thiết bị âm thanh DVB điều khiển bộ giải mã âm thanh MPEG2 của DVB
phần cứng. Nó có thể được truy cập thông qua ZZ0000ZZ. dữ liệu
các loại và định nghĩa ioctl có thể được truy cập bằng cách bao gồm
ZZ0001ZZ trong ứng dụng của bạn.

Xin lưu ý rằng hầu hết các thẻ DVB không có bộ giải mã MPEG riêng.
dẫn đến sự thiếu sót của thiết bị âm thanh và video.

Các ioctl này cũng được V4L2 sử dụng để điều khiển bộ giải mã MPEG được triển khai
trong V4L2. Việc sử dụng các ioctls này cho mục đích đó đã trở nên lỗi thời
và các ioctls hoặc điều khiển V4L2 thích hợp đã được tạo để thay thế điều đó
chức năng. Sử dụng ZZ0000ZZ cho trình điều khiển mới!


Các loại dữ liệu âm thanh
================

Phần này mô tả cấu trúc, kiểu dữ liệu và định nghĩa được sử dụng khi
nói chuyện với thiết bị âm thanh.


-----


âm thanh_stream_source_t
---------------------

Tóm tắt
~~~~~~~~

.. c:enum:: audio_stream_source_t

.. code-block:: c

    typedef enum {
    AUDIO_SOURCE_DEMUX,
    AUDIO_SOURCE_MEMORY
    } audio_stream_source_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``AUDIO_SOURCE_DEMUX``

       -  :cspan:`1` Selects the demultiplexer (fed either by the frontend
          or the DVR device) as the source of the video stream.

    -  ..

       -  ``AUDIO_SOURCE_MEMORY``

       -  Selects the stream from the application that comes through
          the `write()`_ system call.

Sự miêu tả
~~~~~~~~~~~

Nguồn luồng âm thanh được đặt thông qua lệnh gọi ZZ0000ZZ
và có thể nhận các giá trị sau, tùy thuộc vào việc chúng ta có đang phát lại hay không
từ nguồn nội bộ (demux) hoặc bên ngoài (người dùng ghi).

Dữ liệu được cung cấp cho bộ giải mã cũng được điều khiển bởi bộ lọc PID.
Lựa chọn đầu ra: ZZ0000ZZ ZZ0001ZZ.


-----


audio_play_state_t
------------------

Tóm tắt
~~~~~~~~

.. c:enum:: audio_play_state_t

.. code-block:: c

    typedef enum {
	AUDIO_STOPPED,
	AUDIO_PLAYING,
	AUDIO_PAUSED
    } audio_play_state_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``AUDIO_STOPPED``

       -  Audio is stopped.

    -  ..

       -  ``AUDIO_PLAYING``

       -  Audio is currently playing.

    -  ..

       -  ``AUDIO_PAUSE``

       -  Audio is frozen.

Sự miêu tả
~~~~~~~~~~~

Giá trị này có thể được trả về bằng lệnh gọi ZZ0000ZZ
đại diện cho trạng thái phát lại âm thanh.


-----


âm thanh_channel_select_t
----------------------

Tóm tắt
~~~~~~~~

.. c:enum:: audio_channel_select_t

.. code-block:: c

    typedef enum {
	AUDIO_STEREO,
	AUDIO_MONO_LEFT,
	AUDIO_MONO_RIGHT,
	AUDIO_MONO,
	AUDIO_STEREO_SWAPPED
    } audio_channel_select_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``AUDIO_STEREO``

       -  Stereo.

    -  ..

       -  ``AUDIO_MONO_LEFT``

       -  Mono, select left stereo channel as source.

    -  ..

       -  ``AUDIO_MONO_RIGHT``

       -  Mono, select right stereo channel as source.

    -  ..

       -  ``AUDIO_MONO``

       -  Mono source only.

    -  ..

       -  ``AUDIO_STEREO_SWAPPED``

       -  Stereo, swap L & R.

Sự miêu tả
~~~~~~~~~~~

Kênh âm thanh được chọn qua ZZ0000ZZ được xác định bởi
giá trị này.


-----


audio_mixer_t
-------------

Tóm tắt
~~~~~~~~

.. c:struct:: audio_mixer

.. code-block:: c

    typedef struct audio_mixer {
	unsigned int volume_left;
	unsigned int volume_right;
    } audio_mixer_t;

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``unsigned int volume_left``

       -  Volume left channel.
          Valid range: 0 ... 255

    -  ..

       -  ``unsigned int volume_right``

       -  Volume right channel.
          Valid range: 0 ... 255

Sự miêu tả
~~~~~~~~~~~

Cấu trúc này được sử dụng bởi lệnh gọi ZZ0000ZZ để thiết lập
âm lượng âm thanh.


-----


trạng thái âm thanh
------------

Tóm tắt
~~~~~~~~

.. c:struct:: audio_status

.. code-block:: c

    typedef struct audio_status {
	int AV_sync_state;
	int mute_state;
	audio_play_state_t play_state;
	audio_stream_source_t stream_source;
	audio_channel_select_t channel_select;
	int bypass_mode;
	audio_mixer_t mixer_state;
    } audio_status_t;

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  :rspan:`2` ``int AV_sync_state``

       -  :cspan:`1` Shows if A/V synchronization is ON or OFF.

    -  ..

       -  TRUE  ( != 0 )

       -  AV-sync ON.

    -  ..

       -  FALSE ( == 0 )

       -  AV-sync OFF.

    -  ..

       -  :rspan:`2` ``int mute_state``

       -  :cspan:`1` Indicates if audio is muted or not.

    -  ..

       -  TRUE  ( != 0 )

       -  mute audio

    -  ..

       -  FALSE ( == 0 )

       -  unmute audio

    -  ..

       -  `audio_play_state_t`_ ``play_state``

       -  Current playback state.

    -  ..

       -  `audio_stream_source_t`_ ``stream_source``

       -  Current source of the data.

    -  ..

       -  :rspan:`2` ``int bypass_mode``

       -  :cspan:`1` Is the decoding of the current Audio stream in
          the DVB subsystem enabled or disabled.

    -  ..

       -  TRUE  ( != 0 )

       -  Bypass disabled.

    -  ..

       -  FALSE ( == 0 )

       -  Bypass enabled.

    -  ..

       -  `audio_mixer_t`_ ``mixer_state``

       -  Current volume settings.

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi ZZ0000ZZ trả về cấu trúc này dưới dạng thông tin
về các trạng thái khác nhau của hoạt động phát lại.


-----


mã hóa âm thanh
---------------

Tóm tắt
~~~~~~~~

.. code-block:: c

     #define AUDIO_CAP_DTS    1
     #define AUDIO_CAP_LPCM   2
     #define AUDIO_CAP_MP1    4
     #define AUDIO_CAP_MP2    8
     #define AUDIO_CAP_MP3   16
     #define AUDIO_CAP_AAC   32
     #define AUDIO_CAP_OGG   64
     #define AUDIO_CAP_SDDS 128
     #define AUDIO_CAP_AC3  256

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``AUDIO_CAP_DTS``

       -  :cspan:`1` The hardware accepts DTS audio tracks.

    -  ..

       -  ``AUDIO_CAP_LPCM``

       -   The hardware accepts uncompressed audio with
           Linear Pulse-Code Modulation (LPCM)

    -  ..

       -  ``AUDIO_CAP_MP1``

       -  The hardware accepts MPEG-1 Audio Layer 1.

    -  ..

       -  ``AUDIO_CAP_MP2``

       -  The hardware accepts MPEG-1 Audio Layer 2.
          Also known as MUSICAM.

    -  ..

       -  ``AUDIO_CAP_MP3``

       -  The hardware accepts MPEG-1 Audio Layer III.
          Commonly known as .mp3.

    -  ..

       -  ``AUDIO_CAP_AAC``

       -  The hardware accepts AAC (Advanced Audio Coding).

    -  ..

       -  ``AUDIO_CAP_OGG``

       -  The hardware accepts Vorbis audio tracks.

    -  ..

       -  ``AUDIO_CAP_SDDS``

       -  The hardware accepts Sony Dynamic Digital Sound (SDDS).

    -  ..

       -  ``AUDIO_CAP_AC3``

       -  The hardware accepts Dolby Digital ATSC A/52 audio.
          Also known as AC-3.

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi đến ZZ0000ZZ trả về một số nguyên không dấu với
các bit sau được đặt theo khả năng của phần cứng.


-----


Cuộc gọi chức năng âm thanh
====================


AUDIO_STOP
----------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_STOP

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_STOP)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  File descriptor returned by a previous call to `open()`_.

    -  ..

       -  ``int request``

       -  :cspan:`1` Equals ``AUDIO_STOP`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh ngừng phát nội dung hiện tại
suối.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_PLAY
----------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_PLAY

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_PLAY)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  File descriptor returned by a previous call to `open()`_.

    -  ..

       -  ``int request``

       -  :cspan:`1` Equals ``AUDIO_PLAY`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh bắt đầu phát luồng âm thanh
từ nguồn đã chọn.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_PAUSE
-----------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_PAUSE

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_PAUSE)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_PAUSE`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này sẽ tạm dừng luồng âm thanh đang được phát. Giải mã và
đang chơi bị tạm dừng. Sau đó có thể khởi động lại việc giải mã và
quá trình phát luồng âm thanh bằng lệnh ZZ0000ZZ.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_CONTINUE
--------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_CONTINUE

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_CONTINUE)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_CONTINUE`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này khởi động lại quá trình giải mã và phát đã tạm dừng trước đó
bằng lệnh ZZ0000ZZ.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SELECT_SOURCE
-------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SELECT_SOURCE

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_SELECT_SOURCE,
	 audio_stream_source_t source)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_SELECT_SOURCE`` for this command.

    -  ..

       -  `audio_stream_source_t`_ ``source``

       -  Indicates the source that shall be used for the Audio stream.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này thông báo cho thiết bị âm thanh nguồn nào sẽ được sử dụng cho
dữ liệu đầu vào. Các nguồn có thể là demux hoặc bộ nhớ. Nếu
ZZ0000ZZ được chọn, dữ liệu được đưa vào Thiết bị âm thanh
thông qua lệnh ghi. Nếu ZZ0001ZZ được chọn, dữ liệu
được truyền trực tiếp từ thiết bị giải mã trên bo mạch tới bộ giải mã.
Lưu ý: Tính đến nay, tính năng này chỉ hỗ trợ các thiết bị DVB có một bộ giải mã và một bộ giải mã.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SET_MUTE
--------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SET_MUTE

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_SET_MUTE, int state)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  :cspan:`1` Equals ``AUDIO_SET_MUTE`` for this command.

    -  ..

       -  :rspan:`2` ``int state``

       -  :cspan:`1` Indicates if audio device shall mute or not.

    -  ..

       -  TRUE  ( != 0 )

       -  mute audio

    -  ..

       -  FALSE ( == 0 )

       -  unmute audio

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho thiết bị DVB. Để điều khiển bộ giải mã V4L2, hãy sử dụng
V4L2 ZZ0000ZZ với
Thay vào đó là cờ ZZ0001ZZ.

Cuộc gọi ioctl này yêu cầu thiết bị âm thanh tắt tiếng luồng đang phát
hiện đang được chơi.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SET_AV_SYNC
-----------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SET_AV_SYNC

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_SET_AV_SYNC, int state)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  :cspan:`1` Equals ``AUDIO_AV_SYNC`` for this command.

    -  ..

       -  :rspan:`2` ``int state``

       -  :cspan:`1` Tells the DVB subsystem if A/V synchronization
          shall be ON or OFF.

    -  ..

       -  TRUE  ( != 0 )

       -  AV-sync ON.

    -  ..

       -  FALSE ( == 0 )

       -  AV-sync OFF.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh BẬT hoặc OFF A/V
đồng bộ hóa.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SET_BYPASS_MODE
---------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SET_BYPASS_MODE

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_SET_BYPASS_MODE, int mode)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  :cspan:`1` Equals ``AUDIO_SET_BYPASS_MODE`` for this command.

    -  ..

       -  :rspan:`2` ``int mode``

       -  :cspan:`1` Enables or disables the decoding of the current
          Audio stream in the DVB subsystem.
    -  ..

       -  TRUE  ( != 0 )

       -  Disable bypass

    -  ..

       -  FALSE ( == 0 )

       -  Enable bypass

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh bỏ qua bộ giải mã âm thanh và
chuyển tiếp luồng mà không giải mã. Chế độ này sẽ được sử dụng nếu luồng
mà hệ thống DVB không thể xử lý sẽ được giải mã. Dolby
Các luồng DigitalTM được hệ thống con DVB tự động chuyển tiếp nếu
phần cứng có thể xử lý nó.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_CHANNEL_SELECT
--------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_CHANNEL_SELECT

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_CHANNEL_SELECT,
	 audio_channel_select_t)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_CHANNEL_SELECT`` for this command.

    -  ..

       -  `audio_channel_select_t`_ ``ch``

       -  Select the output format of the audio (mono left/right, stereo).

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho thiết bị DVB. Để điều khiển bộ giải mã V4L2, hãy sử dụng
Thay vào đó hãy điều khiển V4L2 ZZ0000ZZ.

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh chọn kênh được yêu cầu nếu
có thể.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_GET_STATUS
----------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_GET_STATUS

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_GET_STATUS,
	 struct audio_status *status)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals AUDIO_GET_STATUS for this command.

    -  ..

       -  ``struct`` `audio_status`_ ``*status``

       -  Returns the current state of Audio Device.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh trả về trạng thái hiện tại của
Thiết bị âm thanh.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_GET_CAPABILITIES
----------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_GET_CAPABILITIES

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_GET_CAPABILITIES,
	 unsigned int *cap)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_GET_CAPABILITIES`` for this command.

    -  ..

       -  ``unsigned int *cap``

       -  Returns a bit array of supported sound formats.
          Bits are defined in `audio encodings`_.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh cho chúng tôi biết về quá trình giải mã
khả năng của phần cứng âm thanh.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_CLEAR_BUFFER
------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_CLEAR_BUFFER

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_CLEAR_BUFFER)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_CLEAR_BUFFER`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh xóa tất cả phần mềm và phần cứng
bộ đệm của thiết bị giải mã âm thanh.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SET_ID
------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SET_ID

.. code-block:: c

	 int  ioctl(int fd, int request = AUDIO_SET_ID, int id)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_SET_ID`` for this command.

    -  ..

       -  ``int id``

       -  Audio sub-stream id.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

ioctl này chọn luồng con nào sẽ được giải mã nếu một chương trình hoặc
luồng hệ thống được gửi đến thiết bị video.

Nếu không đặt loại luồng âm thanh thì id phải nằm trong phạm vi [0xC0,0xDF]
đối với âm thanh MPEG, trong [0x80,0x87] đối với AC3 và trong [0xA0,0xA7] đối với LPCM.
Xem ITU-T H.222.0 | ISO/IEC 13818-1 để biết thêm mô tả.

Nếu loại luồng được đặt bằng ZZ0000ZZ, hãy chỉ định
id chỉ là id luồng phụ của luồng âm thanh và chỉ 5 bit đầu tiên
(& 0x1F) được công nhận.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SET_MIXER
---------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SET_MIXER

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_SET_MIXER, audio_mixer_t *mix)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_SET_MIXER`` for this command.

    -  ..

       -  ``audio_mixer_t *mix``

       -  Mixer settings.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này cho phép bạn điều chỉnh cài đặt bộ trộn của bộ giải mã âm thanh.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


AUDIO_SET_STREAMTYPE
--------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_SET_STREAMTYPE

.. code-block:: c

	 int  ioctl(fd, int request = AUDIO_SET_STREAMTYPE, int type)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_SET_STREAMTYPE`` for this command.

    -  ..

       -  ``int type``

       -  Stream type.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này sẽ cho trình điều khiển biết loại luồng âm thanh nào sẽ được mong đợi. Cái này
rất hữu ích nếu luồng cung cấp một số luồng phụ âm thanh như LPCM và
AC3.

Các loại luồng được xác định trong ITU-T H.222.0 | ISO/IEC 13818-1 được sử dụng.


Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EINVAL``

       -  Type is not a valid or supported stream type.


-----


AUDIO_BILINGUAL_CHANNEL_SELECT
------------------------------

Tóm tắt
~~~~~~~~

.. c:macro:: AUDIO_BILINGUAL_CHANNEL_SELECT

.. code-block:: c

	 int ioctl(int fd, int request = AUDIO_BILINGUAL_CHANNEL_SELECT,
	 audio_channel_select_t)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``AUDIO_BILINGUAL_CHANNEL_SELECT`` for this command.

    -  ..

       -  ``audio_channel_select_t ch``

       -  Select the output format of the audio (mono left/right, stereo).

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này đã được thay thế bằng V4L2
Điều khiển ZZ0000ZZ
cho bộ giải mã MPEG được điều khiển thông qua V4L2.

Cuộc gọi ioctl này yêu cầu Thiết bị âm thanh chọn kênh được yêu cầu
cho các luồng song ngữ nếu có thể.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


mở()
------

Tóm tắt
~~~~~~~~

.. code-block:: c

    #include <fcntl.h>

.. c:function:: int  open(const char *deviceName, int flags)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``const char *deviceName``

       -  Name of specific audio device.

    -  ..

       -  :rspan:`3` ``int flags``

       -  :cspan:`1` A bit-wise OR of the following flags:

    -  ..

       -  ``O_RDONLY``

       -  read-only access

    -  ..

       -  ``O_RDWR``

       -  read/write access

    -  ..

       -  ``O_NONBLOCK``
       -  | Open in non-blocking mode
          | (blocking mode is the default)

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi hệ thống này sẽ mở một thiết bị âm thanh có tên (ví dụ:
ZZ0000ZZ) để sử dụng tiếp theo. Khi một cuộc gọi open() có
thành công, thiết bị sẽ sẵn sàng để sử dụng. Tầm quan trọng của
chế độ chặn hoặc không chặn được mô tả trong tài liệu dành cho
chức năng khi có sự khác biệt. Nó không ảnh hưởng đến ngữ nghĩa
của chính cuộc gọi open(). Một thiết bị được mở ở chế độ chặn sau này có thể bị
đưa vào chế độ không chặn (và ngược lại) bằng lệnh F_SETFL
của cuộc gọi hệ thống fcntl. Đây là một cuộc gọi hệ thống tiêu chuẩn, được ghi lại trong
trang hướng dẫn sử dụng Linux cho fcntl. Chỉ một người dùng có thể mở Thiết bị âm thanh
ở chế độ O_RDWR. Tất cả các nỗ lực khác để mở thiết bị ở chế độ này sẽ
không thành công và mã lỗi sẽ được trả về. Nếu Thiết bị âm thanh được mở
ở chế độ O_RDONLY, lệnh gọi ioctl duy nhất có thể được sử dụng là
ZZ0001ZZ. Tất cả các cuộc gọi khác sẽ trả về với mã lỗi.

Giá trị trả về
~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``ENODEV``

       -  Device driver not loaded/available.

    -  ..

       -  ``EBUSY``

       -  Device or resource busy.

    -  ..

       -  ``EINVAL``

       -  Invalid argument.


-----


đóng()
-------

Tóm tắt
~~~~~~~~

.. c:function:: 	int close(int fd)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi hệ thống này sẽ đóng thiết bị âm thanh đã mở trước đó.

Giá trị trả về
~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EBADF``

       -  Fd is not a valid open file descriptor.

-----


viết()
-------

Tóm tắt
~~~~~~~~

.. code-block:: c

	 size_t write(int fd, const void *buf, size_t count)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_.

    -  ..

       -  ``void *buf``

       -  Pointer to the buffer containing the PES data.

    -  ..

       -  ``size_t count``

       -  Size of buf.

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi hệ thống này chỉ có thể được sử dụng nếu ZZ0000ZZ được chọn
trong ioctl gọi ZZ0002ZZ. Dữ liệu được cung cấp phải ở dạng
Định dạng PES. Nếu ZZ0001ZZ không được chỉ định, chức năng sẽ chặn
cho đến khi có đủ không gian bộ đệm. Lượng dữ liệu cần chuyển là
ngụ ý bởi số lượng.

Giá trị trả về
~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EPERM``

       -  :cspan:`1` Mode ``AUDIO_SOURCE_MEMORY`` not selected.

    -  ..

       -  ``ENOMEM``

       -  Attempted to write more data than the internal buffer can hold.

    -  ..

       -  ``EBADF``

       -  Fd is not a valid open file descriptor.