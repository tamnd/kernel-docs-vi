.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/imx7.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển quay video i.MX7
==========================

Giới thiệu
------------

I.MX7 trái ngược với dòng i.MX5/6 không chứa Xử lý hình ảnh
Đơn vị (IPU); do đó khả năng thực hiện các hoạt động hoặc
thao tác với các khung chụp ít tính năng hơn.

Để chụp ảnh, i.MX7 có ba đơn vị:
- Giao diện cảm biến CMOS (CSI)
- Bộ ghép kênh video
- Đầu thu MIPI CSI-2

.. code-block:: none

   MIPI Camera Input ---> MIPI CSI-2 --- > |\
                                           | \
                                           |  \
                                           | M |
                                           | U | ------>  CSI ---> Capture
                                           | X |
                                           |  /
   Parallel Camera Input ----------------> | /
                                           |/

Để biết thêm thông tin, vui lòng tham khảo các phiên bản mới nhất của i.MX7
hướng dẫn tham khảo [#f1]_.

Thực thể
--------

imx-mipi-csi2
--------------

Đây là thực thể máy thu MIPI CSI-2. Nó có một miếng đệm chìm để nhận pixel
dữ liệu từ cảm biến máy ảnh MIPI CSI-2. Nó có một bảng nguồn, tương ứng với
kênh ảo 0. Mô-đun này tương thích với phiên bản trước của Samsung
D-phy và hỗ trợ hai làn Dữ liệu D-PHY Rx.

csi-mux
-------

Đây là bộ ghép kênh video. Nó có hai miếng đệm chìm để chọn từ một trong hai máy ảnh
cảm biến có giao diện song song hoặc từ kênh ảo MIPI CSI-2 0. Nó có
một bảng nguồn duy nhất định tuyến đến CSI.

csi
---

CSI cho phép chip kết nối trực tiếp với cảm biến hình ảnh CMOS bên ngoài. CSI
có thể giao tiếp trực tiếp với các bus Parallel và MIPI CSI-2. Nó có 256 x 64 FIFO
để lưu trữ dữ liệu pixel hình ảnh đã nhận và bộ điều khiển DMA được nhúng để truyền dữ liệu
từ FIFO đến xe buýt AHB.

Thực thể này có một sink pad nhận từ thực thể csi-mux và một
bảng nguồn định tuyến các khung hình video trực tiếp đến bộ nhớ đệm. Tấm đệm này là
được định tuyến đến một nút thiết bị chụp.

Ghi chú sử dụng
-----------

Để hỗ trợ cấu hình và tương thích ngược với các ứng dụng V4L2
quyền truy cập chỉ được điều khiển từ các nút thiết bị video, giao diện của thiết bị chụp
kế thừa các điều khiển từ các thực thể đang hoạt động trong quy trình hiện tại, do đó, các điều khiển
có thể được truy cập trực tiếp từ subdev hoặc từ bản chụp hoạt động
giao diện thiết bị. Ví dụ: các điều khiển cảm biến có sẵn từ
subdev cảm biến hoặc từ thiết bị chụp đang hoạt động.

Warp7 với OV2680
-----------------

Trên nền tảng này, mô-đun OV2680 MIPI CSI-2 được kết nối với MIPI bên trong
Máy thu CSI-2. Ví dụ sau định cấu hình quy trình quay video với
đầu ra 800x600 và định dạng bayer 10 bit BGGR:

.. code-block:: none

   # Setup links
   media-ctl -l "'ov2680 1-0036':0 -> 'imx7-mipi-csis.0':0[1]"
   media-ctl -l "'imx7-mipi-csis.0':1 -> 'csi-mux':1[1]"
   media-ctl -l "'csi-mux':2 -> 'csi':0[1]"
   media-ctl -l "'csi':1 -> 'csi capture':0[1]"

   # Configure pads for pipeline
   media-ctl -V "'ov2680 1-0036':0 [fmt:SBGGR10_1X10/800x600 field:none]"
   media-ctl -V "'csi-mux':1 [fmt:SBGGR10_1X10/800x600 field:none]"
   media-ctl -V "'csi-mux':2 [fmt:SBGGR10_1X10/800x600 field:none]"
   media-ctl -V "'imx7-mipi-csis.0':0 [fmt:SBGGR10_1X10/800x600 field:none]"
   media-ctl -V "'csi':0 [fmt:SBGGR10_1X10/800x600 field:none]"

Sau khi truyền phát này có thể bắt đầu. Công cụ v4l2-ctl có thể được sử dụng để chọn bất kỳ
độ phân giải được hỗ trợ bởi cảm biến.

.. code-block:: none

	# media-ctl -p
	Media controller API version 5.2.0

	Media device information
	------------------------
	driver          imx7-csi
	model           imx-media
	serial
	bus info
	hw revision     0x0
	driver version  5.2.0

	Device topology
	- entity 1: csi (2 pads, 2 links)
	            type V4L2 subdev subtype Unknown flags 0
	            device node name /dev/v4l-subdev0
	        pad0: Sink
	                [fmt:SBGGR10_1X10/800x600 field:none colorspace:srgb xfer:srgb ycbcr:601 quantization:full-range]
	                <- "csi-mux":2 [ENABLED]
	        pad1: Source
	                [fmt:SBGGR10_1X10/800x600 field:none colorspace:srgb xfer:srgb ycbcr:601 quantization:full-range]
	                -> "csi capture":0 [ENABLED]

	- entity 4: csi capture (1 pad, 1 link)
	            type Node subtype V4L flags 0
	            device node name /dev/video0
	        pad0: Sink
	                <- "csi":1 [ENABLED]

	- entity 10: csi-mux (3 pads, 2 links)
	             type V4L2 subdev subtype Unknown flags 0
	             device node name /dev/v4l-subdev1
	        pad0: Sink
	                [fmt:Y8_1X8/1x1 field:none]
	        pad1: Sink
	               [fmt:SBGGR10_1X10/800x600 field:none]
	                <- "imx7-mipi-csis.0":1 [ENABLED]
	        pad2: Source
	                [fmt:SBGGR10_1X10/800x600 field:none]
	                -> "csi":0 [ENABLED]

	- entity 14: imx7-mipi-csis.0 (2 pads, 2 links)
	             type V4L2 subdev subtype Unknown flags 0
	             device node name /dev/v4l-subdev2
	        pad0: Sink
	                [fmt:SBGGR10_1X10/800x600 field:none]
	                <- "ov2680 1-0036":0 [ENABLED]
	        pad1: Source
	                [fmt:SBGGR10_1X10/800x600 field:none]
	                -> "csi-mux":1 [ENABLED]

	- entity 17: ov2680 1-0036 (1 pad, 1 link)
	             type V4L2 subdev subtype Sensor flags 0
	             device node name /dev/v4l-subdev3
	        pad0: Source
	                [fmt:SBGGR10_1X10/800x600@1/30 field:none colorspace:srgb]
	                -> "imx7-mipi-csis.0":0 [ENABLED]

i.MX6ULL-EVK với OV5640
------------------------

Trên nền tảng này, cảm biến OV5640 song song được kết nối với cổng CSI.
Ví dụ sau định cấu hình quy trình quay video với đầu ra
có định dạng 640x480 và UYVY8_2X8:

.. code-block:: none

   # Setup links
   media-ctl -l "'ov5640 1-003c':0 -> 'csi':0[1]"
   media-ctl -l "'csi':1 -> 'csi capture':0[1]"

   # Configure pads for pipeline
   media-ctl -v -V "'ov5640 1-003c':0 [fmt:UYVY8_2X8/640x480 field:none]"

Sau khi truyền phát này có thể bắt đầu:

.. code-block:: none

   gst-launch-1.0 -v v4l2src device=/dev/video1 ! video/x-raw,format=UYVY,width=640,height=480 ! v4l2convert ! fbdevsink

.. code-block:: none

	# media-ctl -p
	Media controller API version 5.14.0

	Media device information
	------------------------
	driver          imx7-csi
	model           imx-media
	serial
	bus info
	hw revision     0x0
	driver version  5.14.0

	Device topology
	- entity 1: csi (2 pads, 2 links)
	            type V4L2 subdev subtype Unknown flags 0
	            device node name /dev/v4l-subdev0
	        pad0: Sink
	                [fmt:UYVY8_2X8/640x480 field:none colorspace:srgb xfer:srgb ycbcr:601 quantization:full-range]
	                <- "ov5640 1-003c":0 [ENABLED,IMMUTABLE]
	        pad1: Source
	                [fmt:UYVY8_2X8/640x480 field:none colorspace:srgb xfer:srgb ycbcr:601 quantization:full-range]
	                -> "csi capture":0 [ENABLED,IMMUTABLE]

	- entity 4: csi capture (1 pad, 1 link)
	            type Node subtype V4L flags 0
	            device node name /dev/video1
	        pad0: Sink
	                <- "csi":1 [ENABLED,IMMUTABLE]

	- entity 10: ov5640 1-003c (1 pad, 1 link)
	             type V4L2 subdev subtype Sensor flags 0
	             device node name /dev/v4l-subdev1
	        pad0: Source
	                [fmt:UYVY8_2X8/640x480@1/30 field:none colorspace:srgb xfer:srgb ycbcr:601 quantization:full-range]
	                -> "csi":0 [ENABLED,IMMUTABLE]

Tài liệu tham khảo
----------

.. [#f1] https://www.nxp.com/docs/en/reference-manual/IMX7SRM.pdf