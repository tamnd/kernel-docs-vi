.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-d4xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-d4xx:

*******************************
V4L2_META_FMT_D4XX ('D4XX')
*******************************

Siêu dữ liệu máy ảnh Intel D4xx UVC


Sự miêu tả
===========

Máy ảnh Intel D4xx (D435, D455 và các loại khác) bao gồm siêu dữ liệu trên mỗi khung hình trong UVC của chúng
tiêu đề tải trọng, theo đề xuất mở rộng Microsoft(R) UVC [1_]. Đó
có nghĩa là siêu dữ liệu D4XX riêng tư, theo tiêu đề UVC tiêu chuẩn, là
được tổ chức theo khối. Camera D4XX triển khai một số loại khối tiêu chuẩn,
được đề xuất bởi Microsoft và một số sản phẩm độc quyền. Siêu dữ liệu tiêu chuẩn được hỗ trợ
các loại là MetadataId_CaptureStats (ID 3), MetadataId_CameraExtrinsics (ID 4),
và MetadataId_CameraIntrinsics (ID 5). Để biết mô tả của họ, hãy xem [1_]. Cái này
tài liệu mô tả các loại siêu dữ liệu độc quyền, được sử dụng bởi máy ảnh D4xx.

Bộ đệm V4L2_META_FMT_D4XX tuân theo bố cục bộ đệm siêu dữ liệu của
V4L2_META_FMT_UVC với điểm khác biệt duy nhất là nó cũng bao gồm độc quyền
dữ liệu tiêu đề tải trọng. Máy ảnh D4xx sử dụng chuyển số lượng lớn và chỉ gửi một tải trọng
trên mỗi khung hình, do đó tiêu đề của chúng không thể lớn hơn 255 byte.

Tài liệu này triển khai Cấu hình Intel phiên bản 3 [9_].

Dưới đây là các loại siêu dữ liệu kiểu Microsoft độc quyền, được sử dụng bởi máy ảnh D4xx,
trong đó tất cả các trường đều theo thứ tự endian nhỏ:

.. tabularcolumns:: |p{5.0cm}|p{12.5cm}|


.. flat-table:: D4xx metadata
    :widths: 1 2
    :header-rows:  1
    :stub-columns: 0

    * - **Field**
      - **Description**
    * - :cspan:`1` *Depth Control*
    * - __u32 ID
      - 0x80000000
    * - __u32 Size
      - Size in bytes, include ID (all protocol versions: 60)
    * - __u32 Version
      - Version of this structure. The documentation herein covers versions 1,
        2 and 3. The version number will be incremented when new fields are
        added.
    * - __u32 Flags
      - A bitmask of flags: see [2_] below
    * - __u32 Gain
      - Gain value in internal units, same as the V4L2_CID_GAIN control, used to
	capture the frame
    * - __u32 Exposure
      - Exposure time (in microseconds) used to capture the frame
    * - __u32 Laser power
      - Power of the laser LED 0-360, used for depth measurement
    * - __u32 AE mode
      - 0: manual; 1: automatic exposure
    * - __u32 Exposure priority
      - Exposure priority value: 0 - constant frame rate
    * - __u32 AE ROI left
      - Left border of the AE Region of Interest (all ROI values are in pixels
	and lie between 0 and maximum width or height respectively)
    * - __u32 AE ROI right
      - Right border of the AE Region of Interest
    * - __u32 AE ROI top
      - Top border of the AE Region of Interest
    * - __u32 AE ROI bottom
      - Bottom border of the AE Region of Interest
    * - __u32 Preset
      - Preset selector value, default: 0, unless changed by the user
    * - __u8 Emitter mode (v3 only) (__u32 Laser mode for v1) [8_]
      - 0: off, 1: on, same as __u32 Laser mode for v1
    * - __u8 RFU byte (v3 only)
      - Spare byte for future use
    * - __u16 LED Power (v3 only)
      - Led power value 0-360 (F416 SKU)
    * - :cspan:`1` *Capture Timing*
    * - __u32 ID
      - 0x80000001
    * - __u32 Size
      - Size in bytes, include ID (all protocol versions: 40)
    * - __u32 Version
      - Version of this structure. The documentation herein corresponds to
        version xxx. The version number will be incremented when new fields are
        added.
    * - __u32 Flags
      - A bitmask of flags: see [3_] below
    * - __u32 Frame counter
      - Monotonically increasing counter
    * - __u32 Optical time
      - Time in microseconds from the beginning of a frame till its middle
    * - __u32 Readout time
      - Time, used to read out a frame in microseconds
    * - __u32 Exposure time
      - Frame exposure time in microseconds
    * - __u32 Frame interval
      - In microseconds = 1000000 / framerate
    * - __u32 Pipe latency
      - Time in microseconds from start of frame to data in USB buffer
    * - :cspan:`1` *Configuration*
    * - __u32 ID
      - 0x80000002
    * - __u32 Size
      - Size in bytes, include ID (v1:36, v3:40)
    * - __u32 Version
      - Version of this structure. The documentation herein corresponds to
        version xxx. The version number will be incremented when new fields are
        added.
    * - __u32 Flags
      - A bitmask of flags: see [4_] below
    * - __u8 Hardware type
      - Camera hardware version [5_]
    * - __u8 SKU ID
      - Camera hardware configuration [6_]
    * - __u32 Cookie
      - Internal synchronisation
    * - __u16 Format
      - Image format code [7_]
    * - __u16 Width
      - Width in pixels
    * - __u16 Height
      - Height in pixels
    * - __u16 Framerate
      - Requested frame rate per second
    * - __u16 Trigger
      - Byte 0: bit 0: depth and RGB are synchronised, bit 1: external trigger
    * - __u16 Calibration count (v3 only)
      - Calibration counter, see [4_] below
    * - __u8 GPIO input data (v3 only)
      - GPIO readout, see [4_] below (Supported from FW 5.12.7.0)
    * - __u32 Sub-preset info (v3 only)
      - Sub-preset choice information, see [4_] below
    * - __u8 reserved (v3 only)
      - RFU byte.

.. _1:

[1] ZZ0000ZZ

.. _2:

[2] Cờ kiểm soát độ sâu chỉ định trường nào hợp lệ: ::

Tăng 0x00000001
  Tiếp xúc 0x00000002
  0x00000004 Công suất laze
  Chế độ AE 0x00000008
  0x00000010 Ưu tiên phơi sáng
  0x00000020 AE ROI
  Đặt trước 0x00000040
  0x00000080 Chế độ phát
  Nguồn 0x00000100 LED

.. _3:

[3] Cờ Thời gian chụp chỉ định trường nào hợp lệ: ::

Bộ đếm khung 0x00000001
  0x00000002 Thời gian quang học
  0x00000004 Thời gian đọc
  0x00000008 Thời gian phơi sáng
  Khoảng thời gian khung 0x00000010
  Độ trễ ống 0x00000020

.. _4:

[4] Cờ cấu hình chỉ định trường nào hợp lệ: ::

0x00000001 Loại phần cứng
  ID 0x00000002 SKU
  0x00000004 Cookie
  Định dạng 0x00000008
  Chiều rộng 0x00000010
  0x00000020 Chiều cao
  Tốc độ khung hình 0x00000040
  Kích hoạt 0x00000080
  Số lượng 0x00000100 Cal
  Dữ liệu đầu vào 0x00000200 GPIO
  0x00000400 Thông tin đặt trước phụ

.. _5:

[5] Mẫu máy ảnh: ::

0 DS5
  1 IVCAM2

.. _6:

[6] Trường bit cấu hình phần cứng máy ảnh 8 bit: ::

[1:0] độ sâuCamera
	00: không có chiều sâu
	01: độ sâu tiêu chuẩn
	10: chiều sâu rộng
	11: dành riêng
  [2] deepIsActive - có máy chiếu laser
  [3] Sự hiện diện của RGB
  [4] Sự hiện diện của Đơn vị đo quán tính (IMU)
  [5] Loại máy chiếu
	0: HPTG
	1: Đại học Princeton
  [6] 0: máy chiếu, 1: LED
  [7] dành riêng

.. _7:

[7] Mã định dạng hình ảnh trên mỗi giao diện truyền phát video:

Độ sâu: ::

1 Z16
  2 Z

Cảm biến bên trái: ::

1 Y8
  2 UYVY
  3 R8L8
  4 Hiệu chuẩn
  5 W10

Cảm biến mắt cá: ::

1 RAW8

.. _8:

[8] "Chế độ Laser" đã được thay thế trong phiên bản 3 bằng ba trường khác nhau.
"Laser" đã được đổi tên thành "Emitter" vì có nhiều công nghệ dành cho
máy chiếu máy ảnh. Vì chúng tôi có một lĩnh vực khác dành cho "Sức mạnh Laser" nên chúng tôi đã giới thiệu
"LED Power" cho bộ phát bổ sung.

Các trường "Chế độ laser" __u32 đã được chia thành: ::
   1 __u8 Chế độ phát
   2 __u8 RFU byte
   3 __u16 LED Nguồn

Đây là sự thay đổi giữa phiên bản 1 và 3. Tất cả phiên bản 1, 2 và 3 đều lạc hậu
tương thích với cùng định dạng dữ liệu và chúng được hỗ trợ. Xem [2_] để biết
các thuộc tính là hợp lệ.

.. _9:

[9] Nguồn siêu dữ liệu LibRealSense SDK:
ZZ0000ZZ