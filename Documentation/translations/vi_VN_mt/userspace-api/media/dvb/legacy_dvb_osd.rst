.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later OR GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/legacy_dvb_osd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: dtv.legacy.osd

.. _dvb_osd:

================
Thiết bị DVB OSD
================

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Thiết bị DVB OSD điều khiển OnScreen-Display của AV7110 dựa trên
Thẻ DVB với bộ giải mã MPEG2 phần cứng. Nó có thể được truy cập thông qua
ZZ0000ZZ.
Các kiểu dữ liệu và định nghĩa ioctl có thể được truy cập bằng cách bao gồm
ZZ0001ZZ trong ứng dụng của bạn.

OSD không phải là bộ đệm khung như trên nhiều thẻ khác.
Nó là một loại canvas mà người ta có thể vẽ lên.
Độ sâu màu bị giới hạn tùy thuộc vào kích thước bộ nhớ được cài đặt.
Một bảng màu thích hợp phải được thiết lập.
Kích thước bộ nhớ đã cài đặt có thể được xác định bằng ZZ0000ZZ
ioctl.

Các kiểu dữ liệu OSD
====================

OSD_Lệnh
-----------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef enum {
	/* All functions return -2 on "not open" */
	OSD_Close = 1,
	OSD_Open,
	OSD_Show,
	OSD_Hide,
	OSD_Clear,
	OSD_Fill,
	OSD_SetColor,
	OSD_SetPalette,
	OSD_SetTrans,
	OSD_SetPixel,
	OSD_GetPixel,
	OSD_SetRow,
	OSD_SetBlock,
	OSD_FillRow,
	OSD_FillBlock,
	OSD_Line,
	OSD_Query,
	OSD_Test,
	OSD_Text,
	OSD_SetWindow,
	OSD_MoveWindow,
	OSD_OpenRaw,
    } OSD_Command;

Lệnh
~~~~~~~~

.. note::  All functions return -2 on "not open"

.. flat-table::
    :header-rows:  1
    :stub-columns: 0

    -  ..

       -  Command

       -  | Used variables of ``struct`` `osd_cmd_t`_.
          | Usage{variable} if alternative use.

       -  :cspan:`2` Description



    -  ..

       -  ``OSD_Close``

       -  -

       -  | Disables OSD and releases the buffers.
          | Returns 0 on success.

    -  ..

       -  ``OSD_Open``

       -  | x0,y0,x1,y1,
          | BitPerPixel[2/4/8]{color&0x0F},
          | mix[0..15]{color&0xF0}

       -  | Opens OSD with this size and bit depth
          | Returns 0 on success,
          | -1 on DRAM allocation error,
          | -2 on "already open".

    -  ..

       -  ``OSD_Show``

       - -

       -  | Enables OSD mode.
          | Returns 0 on success.

    -  ..

       -  ``OSD_Hide``

       - -

       -  | Disables OSD mode.
          | Returns 0 on success.

    -  ..

       -  ``OSD_Clear``

       - -

       -  | Sets all pixel to color 0.
          | Returns 0 on success.

    -  ..

       -  ``OSD_Fill``

       -  color

       -  | Sets all pixel to color <color>.
          | Returns 0 on success.

    -  ..

       -  ``OSD_SetColor``

       -  | color,
          | R{x0},G{y0},B{x1},
          | opacity{y1}

       -  | Set palette entry <num> to <r,g,b>, <mix> and <trans> apply
          | R,G,B: 0..255
          | R=Red, G=Green, B=Blue
          | opacity=0:      pixel opacity 0% (only video pixel shows)
          | opacity=1..254: pixel opacity as specified in header
          | opacity=255:    pixel opacity 100% (only OSD pixel shows)
          | Returns 0 on success, -1 on error.

    -  ..

       -  ``OSD_SetPalette``

       -  | firstcolor{color},
          | lastcolor{x0},data

       -  | Set a number of entries in the palette.
          | Sets the entries "firstcolor" through "lastcolor" from the
            array "data".
          | Data has 4 byte for each color:
          | R,G,B, and a opacity value: 0->transparent, 1..254->mix,
            255->pixel

    -  ..

       -  ``OSD_SetTrans``

       -  transparency{color}

       -  | Sets transparency of mixed pixel (0..15).
          | Returns 0 on success.

    -  ..

       -  ``OSD_SetPixel``

       -  x0,y0,color

       -  | Sets pixel <x>,<y> to color number <color>.
          | Returns 0 on success, -1 on error.

    -  ..

       -  ``OSD_GetPixel``

       -  x0,y0

       -  | Returns color number of pixel <x>,<y>,  or -1.
          | Command currently not supported by the AV7110!

    -  ..

       -  ``OSD_SetRow``

       -  x0,y0,x1,data

       -  | Fills pixels x0,y through  x1,y with the content of data[].
          | Returns 0 on success, -1 on clipping all pixel (no pixel
            drawn).

    -  ..

       -  ``OSD_SetBlock``

       -  | x0,y0,x1,y1,
          | increment{color},
          | data

       -  | Fills pixels x0,y0 through  x1,y1 with the content of data[].
          | Inc contains the width of one line in the data block,
          | inc<=0 uses block width as line width.
          | Returns 0 on success, -1 on clipping all pixel.

    -  ..

       -  ``OSD_FillRow``

       -  x0,y0,x1,color

       -  | Fills pixels x0,y through  x1,y with the color <color>.
          | Returns 0 on success, -1 on clipping all pixel.

    -  ..

       -  ``OSD_FillBlock``

       -  x0,y0,x1,y1,color

       -  | Fills pixels x0,y0 through  x1,y1 with the color <color>.
          | Returns 0 on success, -1 on clipping all pixel.

    -  ..

       -  ``OSD_Line``

       -  x0,y0,x1,y1,color

       -  | Draw a line from x0,y0 to x1,y1 with the color <color>.
          | Returns 0 on success.

    -  ..

       -  ``OSD_Query``

       -  | x0,y0,x1,y1,
          | xasp{color}; yasp=11

       -  | Fills parameters with the picture dimensions and the pixel
            aspect ratio.
          | Returns 0 on success.
          | Command currently not supported by the AV7110!

    -  ..

       -  ``OSD_Test``

       -  -

       -  | Draws a test picture.
          | For debugging purposes only.
          | Returns 0 on success.
    -  ..

       -  ``OSD_Text``

       -  x0,y0,size,color,text

       -  Draws a text at position x0,y0 with the color <color>.

    -  ..

       -  ``OSD_SetWindow``

       -  x0

       -  Set window with number 0<x0<8 as current.

    -  ..

       -  ``OSD_MoveWindow``

       -  x0,y0

       -  Move current window to (x0, y0).

    -  ..

       -  ``OSD_OpenRaw``

       -  | x0,y0,x1,y1,
          | `osd_raw_window_t`_ {color}

       -  Open other types of OSD windows.

Sự miêu tả
~~~~~~~~~~~

Kiểu dữ liệu ZZ0000ZZ được sử dụng với ZZ0001ZZ ioctl để
báo cho trình điều khiển OSD_Command nào sẽ thực thi.


-----

osd_cmd_t
---------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef struct osd_cmd_s {
	OSD_Command cmd;
	int x0;
	int y0;
	int x1;
	int y1;
	int color;
	void __user *data;
    } osd_cmd_t;

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``OSD_Command cmd``

       -  `OSD_Command`_ to be executed.

    -  ..

       -  ``int x0``

       -  First horizontal position.

    -  ..

       -  ``int y0``

       -  First vertical position.

    -  ..

       -  ``int x1``

       -  Second horizontal position.

    -  ..

       -  ``int y1``

       -  Second vertical position.

    -  ..

       -  ``int color``

       -  Number of the color in the palette.

    -  ..

       -  ``void __user *data``

       -  Command specific Data.

Sự miêu tả
~~~~~~~~~~~

Kiểu dữ liệu ZZ0000ZZ được sử dụng với ZZ0001ZZ ioctl.
Nó chứa dữ liệu cho OSD_Command và chính ZZ0002ZZ.
Cấu trúc phải được chuyển tới trình điều khiển và các thành phần có thể được
bị nó sửa đổi.


-----


osd_raw_window_t
----------------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef enum {
	OSD_BITMAP1,
	OSD_BITMAP2,
	OSD_BITMAP4,
	OSD_BITMAP8,
	OSD_BITMAP1HR,
	OSD_BITMAP2HR,
	OSD_BITMAP4HR,
	OSD_BITMAP8HR,
	OSD_YCRCB422,
	OSD_YCRCB444,
	OSD_YCRCB444HR,
	OSD_VIDEOTSIZE,
	OSD_VIDEOHSIZE,
	OSD_VIDEOQSIZE,
	OSD_VIDEODSIZE,
	OSD_VIDEOTHSIZE,
	OSD_VIDEOTQSIZE,
	OSD_VIDEOTDSIZE,
	OSD_VIDEONSIZE,
	OSD_CURSOR
    } osd_raw_window_t;

Hằng số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``OSD_BITMAP1``

       -  :cspan:`1` 1 bit bitmap

    -  ..

       -  ``OSD_BITMAP2``

       -  2 bit bitmap

    -  ..

       -  ``OSD_BITMAP4``

       -  4 bit bitmap

    -  ..

       -  ``OSD_BITMAP8``

       -  8 bit bitmap

    -  ..

       -  ``OSD_BITMAP1HR``

       -  1 Bit bitmap half resolution

    -  ..

       -  ``OSD_BITMAP2HR``

       -  2 Bit bitmap half resolution

    -  ..

       -  ``OSD_BITMAP4HR``

       -  4 Bit bitmap half resolution

    -  ..

       -  ``OSD_BITMAP8HR``

       -  8 Bit bitmap half resolution

    -  ..

       -  ``OSD_YCRCB422``

       -  4:2:2 YCRCB Graphic Display

    -  ..

       -  ``OSD_YCRCB444``

       -  4:4:4 YCRCB Graphic Display

    -  ..

       -  ``OSD_YCRCB444HR``

       -  4:4:4 YCRCB graphic half resolution

    -  ..

       -  ``OSD_VIDEOTSIZE``

       -  True Size Normal MPEG Video Display

    -  ..

       -  ``OSD_VIDEOHSIZE``

       -  MPEG Video Display Half Resolution

    -  ..

       -  ``OSD_VIDEOQSIZE``

       -  MPEG Video Display Quarter Resolution

    -  ..

       -  ``OSD_VIDEODSIZE``

       -  MPEG Video Display Double Resolution

    -  ..

       -  ``OSD_VIDEOTHSIZE``

       -  True Size MPEG Video Display Half Resolution

    -  ..

       -  ``OSD_VIDEOTQSIZE``

       -  True Size MPEG Video Display Quarter Resolution

    -  ..

       -  ``OSD_VIDEOTDSIZE``

       -  True Size MPEG Video Display Double Resolution

    -  ..

       -  ``OSD_VIDEONSIZE``

       -  Full Size MPEG Video Display

    -  ..

       -  ``OSD_CURSOR``

       -  Cursor

Sự miêu tả
~~~~~~~~~~~

Kiểu dữ liệu ZZ0000ZZ được sử dụng với ZZ0001ZZ
OSD_OpenRaw để báo cho trình điều khiển loại OSD nào sẽ mở.


-----


osd_cap_t
---------

Tóm tắt
~~~~~~~~

.. code-block:: c

    typedef struct osd_cap_s {
	int  cmd;
    #define OSD_CAP_MEMSIZE         1
	long val;
    } osd_cap_t;

Biến
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int  cmd``

       -  Capability to query.

    -  ..

       -  ``long val``

       -  Used to store the Data.

Các khả năng được hỗ trợ
~~~~~~~~~~~~~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``OSD_CAP_MEMSIZE``

       -  Memory size installed on the card.

Sự miêu tả
~~~~~~~~~~~

Cấu trúc dữ liệu này được sử dụng với lệnh gọi ZZ0000ZZ.


-----


Cuộc gọi chức năng OSD
======================

OSD_SEND_CMD
------------

Tóm tắt
~~~~~~~~

.. c:macro:: OSD_SEND_CMD

.. code-block:: c

    int ioctl(int fd, int request = OSD_SEND_CMD, enum osd_cmd_t *cmd)


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

       -  Pointer to the location of the structure `osd_cmd_t`_ for this
          command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này sẽ gửi ZZ0000ZZ tới thẻ.

Giá trị trả về
~~~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EINVAL``

       -  Command is out of range.


-----


OSD_GET_CAPABILITY
------------------

Tóm tắt
~~~~~~~~

.. c:macro:: OSD_GET_CAPABILITY

.. code-block:: c

    int ioctl(int fd, int request = OSD_GET_CAPABILITY,
    struct osd_cap_t *cap)

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

       -  Equals ``OSD_GET_CAPABILITY`` for this command.

    -  ..

       -  ``unsigned int *cap``

       -  Pointer to the location of the structure `osd_cap_t`_ for this
          command.

Sự miêu tả
~~~~~~~~~~~

.. attention:: Do **not** use in new drivers!
             See: :ref:`legacy_dvb_decoder_notes`

Ioctl này được sử dụng để có được các khả năng của OSD dựa trên AV7110
Thẻ giải mã DVB đang được sử dụng.

.. note::
    The structure osd_cap_t has to be setup by the user and passed to the
    driver.

Giá trị trả về
~~~~~~~~~~~~~~

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0


    -  ..

       -  ``EINVAL``

       -  Unsupported capability.


-----


mở()
------

Tóm tắt
~~~~~~~~

.. code-block:: c

    #include <fcntl.h>

.. c:function:: int open(const char *deviceName, int flags)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``const char *deviceName``

       -  Name of specific OSD device.

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

Cuộc gọi hệ thống này sẽ mở một thiết bị OSD có tên (ví dụ:
ZZ0000ZZ) để sử dụng tiếp theo.

Giá trị trả về
~~~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``ENODEV``

       -  Device driver not loaded/available.

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

.. c:function:: int close(int fd)

Đối số
~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``int fd``

       -  :cspan:`1` File descriptor returned by a previous call
          to `open()`_ .

Sự miêu tả
~~~~~~~~~~~

Cuộc gọi hệ thống này sẽ đóng thiết bị OSD đã mở trước đó.

Giá trị trả về
~~~~~~~~~~~~~~

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    -  ..

       -  ``EBADF``

       -  fd is not a valid open file descriptor.