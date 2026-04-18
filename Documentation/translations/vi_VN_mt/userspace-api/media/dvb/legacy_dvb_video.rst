.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later OR GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/legacy_dvb_video.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: dtv.legacy.video

.. _dvb_video:

==================
Thiết bị video DVB
================

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Thiết bị video DVB điều khiển bộ giải mã video MPEG2 của DVB
phần cứng. Nó có thể được truy cập thông qua ZZ0000ZZ. dữ liệu
các loại và định nghĩa ioctl có thể được truy cập bằng cách bao gồm
ZZ0001ZZ trong ứng dụng của bạn.

Lưu ý rằng thiết bị video DVB chỉ điều khiển việc giải mã video MPEG
phát trực tiếp chứ không phải trình chiếu trên TV hoặc màn hình máy tính. Trên PC cái này
thường được xử lý bởi một thiết bị video4linux được liên kết, ví dụ:
ZZ0000ZZ, cho phép chia tỷ lệ và xác định cửa sổ đầu ra.

Hầu hết các thẻ DVB không có bộ giải mã MPEG riêng, điều này dẫn đến
thiếu sót thiết bị âm thanh và video cũng như video4linux
thiết bị.

Các ioctl này cũng được V4L2 sử dụng để điều khiển bộ giải mã MPEG được triển khai
trong V4L2. Việc sử dụng các ioctls này cho mục đích đó đã trở nên lỗi thời
và các ioctls hoặc điều khiển V4L2 thích hợp đã được tạo để thay thế điều đó
chức năng. Sử dụng ZZ0000ZZ cho trình điều khiển mới!


Các loại dữ liệu video
================



video_format_t
--------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef enum {
	VIDEO_FORMAT_4_3,
	VIDEO_FORMAT_16_9,
	VIDEO_FORMAT_221_1
    } video_format_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``VIDEO_FORMAT_4_3``

       -  Select 4:3 format.

    -  ..

       -  ``VIDEO_FORMAT_16_9``

       -  Select 16:9 format.

    -  ..

       -  ``VIDEO_FORMAT_221_1``

       -  Select 2.21:1 format.

Sự miêu tả
~~~~~~~~~~~

Kiểu dữ liệu ZZ0000ZZ
được sử dụng trong chức năng ZZ0001ZZ để báo cho người lái xe biết
tỷ lệ khung hình mà phần cứng đầu ra (ví dụ: TV) có. Nó cũng được sử dụng trong
cấu trúc dữ liệu ZZ0002ZZ được trả về bởi ZZ0003ZZ
và ZZ0004ZZ được trả về bởi ZZ0005ZZ báo cáo
về định dạng hiển thị của luồng video hiện tại.


-----


video_displayformat_t
---------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef enum {
	VIDEO_PAN_SCAN,
	VIDEO_LETTER_BOX,
	VIDEO_CENTER_CUT_OUT
    } video_displayformat_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``VIDEO_PAN_SCAN``

       -  Use pan and scan format.

    -  ..

       -  ``VIDEO_LETTER_BOX``

       -  Use letterbox format.

    -  ..

       -  ``VIDEO_CENTER_CUT_OUT``

       -  Use center cut out format.

Sự miêu tả
~~~~~~~~~~~

Trong trường hợp định dạng hiển thị của luồng video và của màn hình
phần cứng khác nhau mà ứng dụng phải chỉ định cách xử lý
cắt xén hình ảnh. Điều này có thể được thực hiện bằng cách sử dụng
Cuộc gọi ZZ0000ZZ chấp nhận enum này làm đối số.


-----


video_size_t
------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef struct {
	int w;
	int h;
	video_format_t aspect_ratio;
    } video_size_t;

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int w``

       -  Video width in pixels.

    -  ..

       -  ``int h``

       -  Video height in pixels.

    -  ..

       -  `video_format_t`_ ``aspect_ratio``

       -  Aspect ratio.

Sự miêu tả
~~~~~~~~~~~

Được sử dụng trong cấu trúc ZZ0000ZZ. Nó lưu trữ độ phân giải và
tỷ lệ khung hình của video.


-----


video_stream_source_t
---------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef enum {
	VIDEO_SOURCE_DEMUX,
	VIDEO_SOURCE_MEMORY
    } video_stream_source_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``VIDEO_SOURCE_DEMUX``

       -  :cspan:`1` Select the demux as the main source.

    -  ..

       -  ``VIDEO_SOURCE_MEMORY``

       -  If this source is selected, the stream
          comes from the user through the write
          system call.

Sự miêu tả
~~~~~~~~~~~

Nguồn luồng video được đặt thông qua lệnh gọi ZZ0000ZZ
và có thể nhận các giá trị sau, tùy thuộc vào việc chúng ta có đang phát lại hay không
từ nguồn bên trong (bộ giải mã) hoặc bên ngoài (người dùng ghi).
VIDEO_SOURCE_DEMUX chọn bộ tách kênh (được cung cấp bởi
frontend hoặc thiết bị DVR) làm nguồn của luồng video. Nếu
VIDEO_SOURCE_MEMORY được chọn luồng xuất phát từ ứng dụng
thông qua cuộc gọi hệ thống ZZ0001ZZ.


-----


video_play_state_t
------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef enum {
	VIDEO_STOPPED,
	VIDEO_PLAYING,
	VIDEO_FREEZED
    } video_play_state_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``VIDEO_STOPPED``

       -  Video is stopped.

    -  ..

       -  ``VIDEO_PLAYING``

       -  Video is currently playing.

    -  ..

       -  ``VIDEO_FREEZED``

       -  Video is frozen.

Sự miêu tả
~~~~~~~~~~~

Giá trị này có thể được trả về bằng lệnh gọi ZZ0000ZZ
đại diện cho trạng thái phát lại video.


-----


cấu trúc video_command
--------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    struct video_command {
	__u32 cmd;
	__u32 flags;
	union {
	    struct {
		__u64 pts;
	    } stop;

	    struct {
		__s32 speed;
		__u32 format;
	    } play;

	    struct {
		__u32 data[16];
	    } raw;
	};
    };


Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``__u32 cmd``

       -  `Decoder command`_

    -  ..

       -  ``__u32 flags``

       -  Flags for the `Decoder command`_.

    -  ..

       -  ``struct stop``

       -  ``__u64 pts``

       -  MPEG PTS

    -  ..

       -  :rspan:`5` ``stuct play``

       -  :rspan:`4` ``__s32 speed``

       -   0 or 1000 specifies normal speed,

    -  ..

       -   1:  specifies forward single stepping,

    -  ..

       -   -1: specifies backward single stepping,

    -  ..

       -   >1: playback at speed / 1000 of the normal speed

    -  ..

       -   <-1: reverse playback at ( -speed / 1000 ) of the normal speed.

    -  ..

       -  ``__u32 format``

       -  `Play input formats`_

    -  ..

       -  ``__u32 data[16]``

       -  Reserved

Sự miêu tả
~~~~~~~~~~~

Cấu trúc phải bằng 0 trước khi ứng dụng sử dụng. Điều này đảm bảo
nó có thể được mở rộng một cách an toàn trong tương lai.


-----


Các lệnh và cờ giải mã được xác định trước
-------------------------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    #define VIDEO_CMD_PLAY                      (0)
    #define VIDEO_CMD_STOP                      (1)
    #define VIDEO_CMD_FREEZE                    (2)
    #define VIDEO_CMD_CONTINUE                  (3)

    #define VIDEO_CMD_FREEZE_TO_BLACK      (1 << 0)

    #define VIDEO_CMD_STOP_TO_BLACK        (1 << 0)
    #define VIDEO_CMD_STOP_IMMEDIATELY     (1 << 1)

    #define VIDEO_PLAY_FMT_NONE                 (0)
    #define VIDEO_PLAY_FMT_GOP                  (1)

    #define VIDEO_VSYNC_FIELD_UNKNOWN           (0)
    #define VIDEO_VSYNC_FIELD_ODD               (1)
    #define VIDEO_VSYNC_FIELD_EVEN              (2)
    #define VIDEO_VSYNC_FIELD_PROGRESSIVE       (3)

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  :rspan:`3` _`Decoder command`

       -  ``VIDEO_CMD_PLAY``

       -  Start playback.

    -  ..

       -  ``VIDEO_CMD_STOP``

       -  Stop playback.

    -  ..

       -  ``VIDEO_CMD_FREEZE``

       -  Freeze playback.

    -  ..

       -  ``VIDEO_CMD_CONTINUE``

       -  Continue playback after freeze.

    -  ..

       -  Flags for ``VIDEO_CMD_FREEZE``

       -  ``VIDEO_CMD_FREEZE_TO_BLACK``

       -  Show black picture on freeze.

    -  ..

       -  :rspan:`1` Flags for ``VIDEO_CMD_STOP``

       -  ``VIDEO_CMD_STOP_TO_BLACK``

       -  Show black picture on stop.

    -  ..

       -  ``VIDEO_CMD_STOP_IMMEDIATELY``

       -  Stop immediately, without emptying buffers.

    -  ..

       -  :rspan:`1` _`Play input formats`

       -  ``VIDEO_PLAY_FMT_NONE``

       -  The decoder has no special format requirements

    -  ..

       -  ``VIDEO_PLAY_FMT_GOP``

       -  The decoder requires full GOPs

    -  ..

       -  :rspan:`3` Field order

       -  ``VIDEO_VSYNC_FIELD_UNKNOWN``

       -  FIELD_UNKNOWN can be used if the hardware does not know
          whether the Vsync is for an odd, even or progressive
          (i.e. non-interlaced) field.

    -  ..

       -  ``VIDEO_VSYNC_FIELD_ODD``

       -  Vsync is for an odd field.

    -  ..

       -  ``VIDEO_VSYNC_FIELD_EVEN``

       -  Vsync is for an even field.

    -  ..

       -  ``VIDEO_VSYNC_FIELD_PROGRESSIVE``

       -  progressive (i.e. non-interlaced)


-----


video_sự kiện
-----------

Tóm tắt
~~~~~~~~

.. code-block:: c

    struct video_event {
	__s32 type;
    #define VIDEO_EVENT_SIZE_CHANGED        1
    #define VIDEO_EVENT_FRAME_RATE_CHANGED  2
    #define VIDEO_EVENT_DECODER_STOPPED     3
    #define VIDEO_EVENT_VSYNC               4
	long timestamp;
	union {
	    video_size_t size;
	    unsigned int frame_rate;
	    unsigned char vsync_field;
	} u;
    };

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  :rspan:`4` ``__s32 type``

       -  :cspan:`1` Event type.

    -  ..

       -  ``VIDEO_EVENT_SIZE_CHANGED``

       -  Size changed.

    -  ..

       -  ``VIDEO_EVENT_FRAME_RATE_CHANGED``

       -  Framerate changed.

    -  ..

       -  ``VIDEO_EVENT_DECODER_STOPPED``

       -  Decoder stopped.

    -  ..

       -  ``VIDEO_EVENT_VSYNC``

       -  Vsync occurred.

    -  ..

       -  ``long timestamp``

       -  :cspan:`1` MPEG PTS at occurrence.

    -  ..

       -  :rspan:`2` ``union u``

       -  `video_size_t`_ size

       -  Resolution and aspect ratio of the video.

    -  ..

       -  ``unsigned int frame_rate``

       -  in frames per 1000sec

    -  ..

       -  ``unsigned char vsync_field``

       -  | unknown / odd / even / progressive
          | See: `Predefined decoder commands and flags`_

Sự miêu tả
~~~~~~~~~~~

Đây là cấu trúc của một sự kiện video khi nó được trả về bởi
Cuộc gọi ZZ0000ZZ. Xem ở đó để biết thêm chi tiết.


-----


video_status
------------

Tóm tắt
~~~~~~~~

Cuộc gọi ZZ0000ZZ trả về cấu trúc sau thông báo
về các trạng thái khác nhau của hoạt động phát lại.

.. code-block:: c

    struct video_status {
	int                    video_blank;
	video_play_state_t     play_state;
	video_stream_source_t  stream_source;
	video_format_t         video_format;
	video_displayformat_t  display_format;
    };

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  :rspan:`2` ``int video_blank``

       -  :cspan:`1` Show blank video on freeze?

    -  ..

       -  TRUE  ( != 0 )

       -  Blank screen when freeze.

    -  ..

       -  FALSE ( == 0 )

       -  Show last decoded frame.

    -  ..

       -  `video_play_state_t`_ ``play_state``

       -  Current state of playback.

    -  ..

       -  `video_stream_source_t`_ ``stream_source``

       -  Current source (demux/memory).

    -  ..

       -  `video_format_t`_ ``video_format``

       -  Current aspect ratio of stream.

    -  ..

       -  `video_displayformat_t`_ ``display_format``

       -  Applied cropping mode.

Sự miêu tả
~~~~~~~~~~~

Nếu ZZ0000ZZ được đặt, video ZZ0001ZZ sẽ bị xóa nếu
kênh bị thay đổi hoặc nếu quá trình phát lại bị dừng. Nếu không thì hình ảnh cuối cùng
sẽ được hiển thị. ZZ0002ZZ cho biết video hiện có
bị đóng băng, bị dừng hoặc đang được phát lại. ZZ0003ZZ tương ứng
tới nguồn đã chọn cho luồng video. Nó có thể đến từ
bộ tách kênh hoặc từ bộ nhớ. ZZ0004ZZ biểu thị khía cạnh
tỷ lệ (một trong 4:3 hoặc 16:9) của luồng video hiện đang phát.
Cuối cùng, ZZ0005ZZ tương ứng với chế độ cắt xén được áp dụng trong
trường hợp định dạng video nguồn không giống với định dạng đầu ra
thiết bị.


-----


video_tĩnh_hình ảnh
-------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    struct video_still_picture {
    char *iFrame;
    int32_t size;
    };

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``char *iFrame``

       -  Pointer to a single iframe in memory.

    -  ..

       -  ``int32_t size``

       -  Size of the iframe.


Sự miêu tả
~~~~~~~~~~~

Một khung I được hiển thị qua lệnh gọi ZZ0000ZZ được chuyển tiếp
bên trong cấu trúc này.


-----


khả năng video
------------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    #define VIDEO_CAP_MPEG1   1
    #define VIDEO_CAP_MPEG2   2
    #define VIDEO_CAP_SYS     4
    #define VIDEO_CAP_PROG    8

Hằng số
~~~~~~~~~
Định nghĩa bit cho khả năng:

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``VIDEO_CAP_MPEG1``

       -  :cspan:`1` The hardware can decode MPEG1.

    -  ..

       -  ``VIDEO_CAP_MPEG2``

       -  The hardware can decode MPEG2.

    -  ..

       -  ``VIDEO_CAP_SYS``

       -  The video device accepts system stream.

          You still have to open the video and the audio device
          but only send the stream to the video device.

    -  ..

       -  ``VIDEO_CAP_PROG``

       -  The video device accepts program stream.

          You still have to open the video and the audio device
          but only send the stream to the video device.

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi đến ZZ0000ZZ trả về một số nguyên không dấu với
các bit sau được đặt theo khả năng của phần cứng.


-----


Cuộc gọi chức năng video
====================


VIDEO_STOP
----------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_STOP

.. code-block:: c

	int ioctl(fd, VIDEO_STOP, int mode)

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

       -  :cspan:`1` Equals ``VIDEO_STOP`` for this command.

    -  ..

       -  :rspan:`2` ``int mode``

       -  :cspan:`1` Indicates how the screen shall be handled.

    -  ..

       -  TRUE  ( != 0 )

       -  Blank screen when stop.

    -  ..

       -  FALSE ( == 0 )

       -  Show last decoded frame.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho các thiết bị TV kỹ thuật số. Để điều khiển bộ giải mã V4L2, hãy sử dụng
thay vào đó là V4L2 ZZ0000ZZ.

Cuộc gọi ioctl này yêu cầu Thiết bị Video ngừng phát nội dung hiện tại
suối. Tùy thuộc vào thông số đầu vào, màn hình có thể bị xóa trắng
hoặc hiển thị khung được giải mã cuối cùng.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_PLAY
----------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_PLAY

.. code-block:: c

	int ioctl(fd, VIDEO_PLAY)

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

       -  Equals ``VIDEO_PLAY`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho các thiết bị TV kỹ thuật số. Để điều khiển bộ giải mã V4L2, hãy sử dụng
thay vào đó là V4L2 ZZ0000ZZ.

Cuộc gọi ioctl này yêu cầu Thiết bị video bắt đầu phát luồng video
từ nguồn đã chọn.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_FREEZE
------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_FREEZE

.. code-block:: c

	int ioctl(fd, VIDEO_FREEZE)

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

       -  Equals ``VIDEO_FREEZE`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho các thiết bị TV kỹ thuật số. Để điều khiển bộ giải mã V4L2, hãy sử dụng
thay vào đó là V4L2 ZZ0000ZZ.

Cuộc gọi ioctl này sẽ tạm dừng luồng video trực tiếp đang được phát, nếu
VIDEO_SOURCE_DEMUX được chọn. Giải mã và chơi bị đóng băng.
Sau đó có thể khởi động lại quá trình giải mã và phát của
luồng video bằng lệnh ZZ0000ZZ.
Nếu VIDEO_SOURCE_MEMORY được chọn trong lệnh gọi ioctl
ZZ0001ZZ, hệ thống con TV kỹ thuật số sẽ không giải mã nữa
dữ liệu cho đến khi lệnh gọi ioctl ZZ0002ZZ hoặc ZZ0003ZZ được thực hiện.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_CONTINUE
--------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_CONTINUE

.. code-block:: c

	int ioctl(fd, VIDEO_CONTINUE)

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

       -  Equals ``VIDEO_CONTINUE`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho các thiết bị TV kỹ thuật số. Để điều khiển bộ giải mã V4L2, hãy sử dụng
thay vào đó là V4L2 ZZ0000ZZ.

Lệnh gọi ioctl này khởi động lại quá trình giải mã và phát video
luồng được phát trước khi cuộc gọi tới ZZ0000ZZ được thực hiện.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_SELECT_SOURCE
-------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_SELECT_SOURCE

.. code-block:: c

	int ioctl(fd, VIDEO_SELECT_SOURCE, video_stream_source_t source)

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

       -  Equals ``VIDEO_SELECT_SOURCE`` for this command.

    -  ..

       -  `video_stream_source_t`_ ``source``

       -  Indicates which source shall be used for the Video stream.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho các thiết bị TV kỹ thuật số. Ioctl này cũng được hỗ trợ
bởi trình điều khiển ivtv V4L2, nhưng trình điều khiển đó đã được thay thế bằng trình điều khiển dành riêng cho ivtv
ZZ0000ZZ ioctl.

Cuộc gọi ioctl này thông báo cho thiết bị video nguồn nào sẽ được sử dụng cho
dữ liệu đầu vào. Các nguồn có thể là demux hoặc bộ nhớ. Nếu bộ nhớ là
được chọn, dữ liệu sẽ được đưa vào thiết bị video thông qua lệnh ghi
sử dụng cấu trúc ZZ0000ZZ. Nếu demux được chọn, dữ liệu
được truyền trực tiếp từ thiết bị giải mã trên bo mạch tới bộ giải mã.

Dữ liệu được cung cấp cho bộ giải mã cũng được điều khiển bởi bộ lọc PID.
Lựa chọn đầu ra: ZZ0000ZZ ZZ0001ZZ.


Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_SET_BLANK
---------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_SET_BLANK

.. code-block:: c

	int ioctl(fd, VIDEO_SET_BLANK, int mode)

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

       -  :cspan:`1` Equals ``VIDEO_SET_BLANK`` for this command.

    -  ..

       -  :rspan:`2` ``int mode``

       -  :cspan:`1` Indicates if the screen shall be blanked.

    -  ..

       -  TRUE  ( != 0 )

       -  Blank screen when stop.

    -  ..

       -  FALSE ( == 0 )

       -  Show last decoded frame.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị Video xóa hình ảnh.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_GET_STATUS
----------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_GET_STATUS

.. code-block:: c

	int ioctl(fd, int request = VIDEO_GET_STATUS,
	struct video_status *status)

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

       -  Equals ``VIDEO_GET_STATUS`` for this command.

    -  ..

       -  ``struct`` `video_status`_ ``*status``

       -  Returns the current status of the Video Device.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị Video trả về trạng thái hiện tại của
thiết bị.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_GET_EVENT
---------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_GET_EVENT

.. code-block:: c

	int ioctl(fd, int request = VIDEO_GET_EVENT,
	struct video_event *ev)

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

       -  Equals ``VIDEO_GET_EVENT`` for this command.

    -  ..

       -  ``struct`` `video_event`_ ``*ev``

       -  Points to the location where the event, if any, is to be stored.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này chỉ dành cho thiết bị DVB. Để nhận các sự kiện từ bộ giải mã V4L2
thay vào đó hãy sử dụng V4L2 ZZ0000ZZ ioctl.

Cuộc gọi ioctl này trả về một sự kiện thuộc loại ZZ0001ZZ nếu có. A
một số sự kiện mới nhất nhất định sẽ được truy xuất và trả về theo thứ tự
sự xuất hiện. Các sự kiện cũ hơn có thể bị loại bỏ nếu không được tìm nạp kịp thời. Nếu
một sự kiện không có sẵn, hành vi sẽ phụ thuộc vào việc thiết bị có
ở chế độ chặn hoặc không chặn. Trong trường hợp sau, cuộc gọi không thành công
ngay lập tức với lỗi được đặt thành ZZ0000ZZ. Trong trường hợp trước,
chặn cuộc gọi cho đến khi có sự kiện. Cuộc thăm dò tiêu chuẩn của Linux()
và/hoặc các lệnh gọi hệ thống select() có thể được sử dụng với bộ mô tả tệp thiết bị
để theo dõi các sự kiện mới. Đối với select(), bộ mô tả tệp phải là
được bao gồm trong đối số ngoại trừ, và đối với cuộc thăm dò ý kiến(), POLLPRI phải là
được chỉ định làm điều kiện đánh thức. Quyền chỉ đọc là đủ
cho cuộc gọi ioctl này.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EWOULDBLOCK``

       -  :cspan:`1` There is no event pending, and the device is in
          non-blocking mode.

    -  ..

       -  ``EOVERFLOW``

       -  Overflow in event queue - one or more events were lost.


-----


VIDEO_SET_DISPLAY_FORMAT
------------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_SET_DISPLAY_FORMAT

.. code-block:: c

	int ioctl(fd, int request = VIDEO_SET_DISPLAY_FORMAT,
	video_display_format_t format)

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

       -  Equals ``VIDEO_SET_DISPLAY_FORMAT`` for this command.

    -  ..

       -  `video_displayformat_t`_ ``format``

       -  Selects the video format to be used.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị Video chọn định dạng video
được áp dụng bởi chip MPEG trên video.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_STILLPICTURE
------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_STILLPICTURE

.. code-block:: c

	int ioctl(fd, int request = VIDEO_STILLPICTURE,
	struct video_still_picture *sp)

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

       -  Equals ``VIDEO_STILLPICTURE`` for this command.

    -  ..

       -  ``struct`` `video_still_picture`_ ``*sp``

       -  Pointer to the location where the struct with the I-frame
          and size is stored.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị Video hiển thị hình ảnh tĩnh
(I-khung). Dữ liệu đầu vào phải là phần của video cơ bản
luồng chứa I-frame. Thông thường phần này được trích xuất từ một
Ghi TS hoặc PES. Độ phân giải và codec (xem ZZ0000ZZ) phải
được thiết bị hỗ trợ. Nếu con trỏ là NULL thì dòng điện
hình ảnh tĩnh được hiển thị bị trống.

ví dụ. AV7110 hỗ trợ MPEG1 và MPEG2 với PAL-SD phổ biến
nghị quyết.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_FAST_FORWARD
------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_FAST_FORWARD

.. code-block:: c

	int ioctl(fd, int request = VIDEO_FAST_FORWARD, int nFrames)

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

       -  Equals ``VIDEO_FAST_FORWARD`` for this command.

    -  ..

       -  ``int nFrames``

       -  The number of frames to skip.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu Thiết bị Video bỏ qua việc giải mã N số
I-frame. Cuộc gọi này chỉ có thể được sử dụng nếu ZZ0000ZZ
đã chọn.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EPERM``

       -  Mode ``VIDEO_SOURCE_MEMORY`` not selected.


-----


VIDEO_SLOWMOTION
----------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_SLOWMOTION

.. code-block:: c

	int ioctl(fd, int request = VIDEO_SLOWMOTION, int nFrames)

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

       -  Equals ``VIDEO_SLOWMOTION`` for this command.

    -  ..

       -  ``int nFrames``

       -  The number of times to repeat each frame.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này yêu cầu thiết bị video lặp lại giải mã khung số N
nhiều lần. Cuộc gọi này chỉ có thể được sử dụng nếu ZZ0000ZZ
đã chọn.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EPERM``

       -  Mode ``VIDEO_SOURCE_MEMORY`` not selected.


-----


VIDEO_GET_CAPABILITIES
----------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_GET_CAPABILITIES

.. code-block:: c

	int ioctl(fd, int request = VIDEO_GET_CAPABILITIES, unsigned int *cap)

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

       -  Equals ``VIDEO_GET_CAPABILITIES`` for this command.

    -  ..

       -  ``unsigned int *cap``

       -  Pointer to a location where to store the capability information.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này hỏi thiết bị video về khả năng giải mã của nó.
Khi thành công, nó trả về một số nguyên có các bit được đặt theo
định nghĩa trong ZZ0000ZZ.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_CLEAR_BUFFER
------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_CLEAR_BUFFER

.. code-block:: c

	int ioctl(fd, int request = VIDEO_CLEAR_BUFFER)

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

       -  Equals ``VIDEO_CLEAR_BUFFER`` for this command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Cuộc gọi ioctl này sẽ xóa tất cả bộ đệm video trong trình điều khiển và trong
phần cứng bộ giải mã.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_SET_STREAMTYPE
--------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_SET_STREAMTYPE

.. code-block:: c

	int ioctl(fd, int request = VIDEO_SET_STREAMTYPE, int type)

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

       -  Equals ``VIDEO_SET_STREAMTYPE`` for this command.

    -  ..

       -  ``int type``

       -  Stream type.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này cho trình điều khiển biết loại luồng nào sẽ được ghi
đến nó.
Bộ giải mã thông minh cũng có thể không hỗ trợ hoặc bỏ qua (như AV7110)
cuộc gọi này và tự xác định loại luồng.

Các loại luồng hiện đang được sử dụng:

.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    -  ..

       -  Codec

       -  Stream type

    -  ..

       -  MPEG2

       -  0

    -  ..

       -  MPEG4 h.264

       -  1

    -  ..

       -  VC1

       -  3

    -  ..

       -  MPEG4 Part2

       -  4

    -  ..

       -  VC1 SM

       -  5

    -  ..

       -  MPEG1

       -  6

    -  ..

       -  HEVC h.265

       -  | 7
          | DREAMBOX: 22

    -  ..

       -  AVS

       -  16

    -  ..

       -  AVS2

       -  40

Không phải mọi bộ giải mã đều hỗ trợ tất cả các loại luồng.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_SET_FORMAT
----------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_SET_FORMAT

.. code-block:: c

	int ioctl(fd, int request = VIDEO_SET_FORMAT, video_format_t format)

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

       -  Equals ``VIDEO_SET_FORMAT`` for this command.

    -  ..

       -  `video_format_t`_ ``format``

       -  Video format of TV as defined in section `video_format_t`_.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này đặt định dạng màn hình (tỷ lệ khung hình) của đầu ra được kết nối
thiết bị (TV) để có thể điều chỉnh đầu ra của bộ giải mã
tương ứng.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_GET_SIZE
--------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_GET_SIZE

.. code-block:: c

	int ioctl(int fd, int request = VIDEO_GET_SIZE, video_size_t *size)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call,
          to `open()`_.

    -  ..

       -  ``int request``

       -  Equals ``VIDEO_GET_SIZE`` for this command.

    -  ..

       -  `video_size_t`_ ``*size``

       -  Returns the size and aspect ratio.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này trả về kích thước và tỷ lệ khung hình.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_GET_PTS
-------------

Synopsis
~~~~~~~~

.. c:macro:: VIDEO_GET_PTS

.. code-block:: c

	int ioctl(int fd, int request = VIDEO_GET_PTS, __u64 *pts)

Arguments
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

       -  Equals ``VIDEO_GET_PTS`` for this command.

    -  ..

       -  ``__u64 *pts``

       -  Returns the 33-bit timestamp as defined in ITU T-REC-H.222.0 /
          ISO/IEC 13818-1.

          The PTS should belong to the currently played frame if possible,
          but may also be a value close to it like the PTS of the last
          decoded frame or the last PTS extracted by the PES parser.

Description
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

For V4L2 decoders this ioctl has been replaced by the
``V4L2_CID_MPEG_VIDEO_DEC_PTS`` control.

This ioctl call asks the Video Device to return the current PTS
timestamp.

Return Value
~~~~~~~~~~~~

On success 0 is returned, on error -1 and the ``errno`` variable is set
appropriately. The generic error codes are described at the
:ref:`Generic Error Codes <gen-errors>` chapter.


-----


VIDEO_GET_FRAME_COUNT
---------------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_GET_FRAME_COUNT

.. code-block:: c

	int ioctl(int fd, VIDEO_GET_FRAME_COUNT, __u64 *pts)

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

       -  Equals ``VIDEO_GET_FRAME_COUNT`` for this command.

    -  ..

       -  ``__u64 *pts``

       -  Returns the number of frames displayed since the decoder was
          started.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Đối với bộ giải mã V4L2, ioctl này đã được thay thế bằng
Điều khiển ZZ0000ZZ.

Cuộc gọi ioctl này yêu cầu Thiết bị Video trả về số lượng hiển thị
frame kể từ khi bộ giải mã được khởi động.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_COMMAND
-------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_COMMAND

.. code-block:: c

	int ioctl(int fd, int request = VIDEO_COMMAND,
	struct video_command *cmd)

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

       -  Equals ``VIDEO_COMMAND`` for this command.

    -  ..

       -  `struct video_command`_ ``*cmd``

       -  Commands the decoder.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Đối với bộ giải mã V4L2, ioctl này đã được thay thế bằng
ZZ0000ZZ ioctl.

Ioctl này ra lệnh cho bộ giải mã. ZZ0002ZZ là một
tập hợp con của cấu trúc ZZ0001ZZ, vì vậy hãy tham khảo
Tài liệu ZZ0000ZZ cho
thêm thông tin.

Giá trị trả về
~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.


-----


VIDEO_TRY_COMMAND
-----------------

Tóm tắt
~~~~~~~~

.. c:macro:: VIDEO_TRY_COMMAND

.. code-block:: c

	int ioctl(int fd, int request = VIDEO_TRY_COMMAND,
	struct video_command *cmd)

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

       -  Equals ``VIDEO_TRY_COMMAND`` for this command.

    -  ..

       -  `struct video_command`_ ``*cmd``

       -  Try a decoder command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Đối với bộ giải mã V4L2, ioctl này đã được thay thế bằng
ZZ0000ZZ ioctl.

Ioctl này thử lệnh giải mã. ZZ0002ZZ là một
tập hợp con của cấu trúc ZZ0001ZZ, vì vậy hãy tham khảo
Tài liệu ZZ0000ZZ
để biết thêm thông tin.

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

.. c:function:: 	int open(const char *deviceName, int flags)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``const char *deviceName``

       -  Name of specific video device.

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

Cuộc gọi hệ thống này sẽ mở một thiết bị video có tên (ví dụ:
/dev/dvb/adapter?/video?) để sử dụng sau này.

Khi lệnh gọi open() thành công, thiết bị sẽ sẵn sàng để sử dụng. các
tầm quan trọng của chế độ chặn hoặc không chặn được mô tả trong
tài liệu cho các chức năng có sự khác biệt. Nó không
ảnh hưởng đến ngữ nghĩa của chính lệnh gọi open(). Một thiết bị được mở trong
chế độ chặn sau này có thể được chuyển sang chế độ không chặn (và ngược lại)
bằng cách sử dụng lệnh F_SETFL của lệnh gọi hệ thống fcntl. Đây là một tiêu chuẩn
cuộc gọi hệ thống, được ghi lại trong trang hướng dẫn Linux cho fcntl. Chỉ có một
người dùng có thể mở Thiết bị video ở chế độ O_RDWR. Tất cả những nỗ lực khác để
mở thiết bị ở chế độ này sẽ không thành công và mã lỗi sẽ xuất hiện
đã quay trở lại. Nếu Thiết bị Video được mở ở chế độ O_RDONLY, thì chỉ
lệnh gọi ioctl có thể được sử dụng là ZZ0000ZZ. Tất cả các cuộc gọi khác sẽ
trả lại mã lỗi.

Giá trị trả về
~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``ENODEV``

       -  :cspan:`1` Device driver not loaded/available.

    -  ..

       -  ``EINTERNAL``

       -  Internal error.

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

Cuộc gọi hệ thống này sẽ đóng thiết bị video đã mở trước đó.

Giá trị trả về
~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EBADF``

       -  fd is not a valid open file descriptor.


-----


viết()
-------

Tóm tắt
~~~~~~~~

.. c:function:: size_t write(int fd, const void *buf, size_t count)

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

Cuộc gọi hệ thống này chỉ có thể được sử dụng nếu VIDEO_SOURCE_MEMORY được chọn
trong ioctl gọi ZZ0000ZZ. Dữ liệu được cung cấp phải ở dạng
Định dạng PES, trừ khi khả năng cho phép các định dạng khác. TS là
định dạng phổ biến nhất để lưu trữ dữ liệu DVB, nó cũng thường được hỗ trợ.
Nếu O_NONBLOCK không được chỉ định, chức năng sẽ chặn cho đến khi có dung lượng bộ đệm
có sẵn. Lượng dữ liệu được truyền được ngụ ý bằng số lượng.

.. note:: See: :ref:`DVB Data Formats <legacy_dvb_decoder_formats>`

Giá trị trả về
~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EPERM``

       -  :cspan:`1` Mode ``VIDEO_SOURCE_MEMORY`` not selected.

    -  ..

       -  ``ENOMEM``

       -  Attempted to write more data than the internal buffer can hold.

    -  ..

       -  ``EBADF``

       -  fd is not a valid open file descriptor.