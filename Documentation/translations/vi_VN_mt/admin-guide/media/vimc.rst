.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/vimc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển bộ điều khiển phương tiện ảo (vimc)
==========================================

Trình điều khiển vimc mô phỏng phần cứng video phức tạp bằng V4L2 API và Media
API. Nó có một thiết bị chụp và ba thiết bị phụ: cảm biến, bộ gỡ lỗi và bộ chia tỷ lệ.

Cấu trúc liên kết
--------

Cấu trúc liên kết được mã hóa cứng, mặc dù bạn có thể sửa đổi nó trong vimc-core và
biên dịch lại trình điều khiển để đạt được cấu trúc liên kết của riêng bạn. Đây là cấu trúc liên kết mặc định:

.. _vimc_topology_graph:

.. kernel-figure:: vimc.dot
    :alt:   Diagram of the default media pipeline topology
    :align: center

    Media pipeline graph on vimc

Cấu hình cấu trúc liên kết
~~~~~~~~~~~~~~~~~~~~~~~~

Mỗi thiết bị con sẽ có cấu hình mặc định (pixelformat, chiều cao,
chiều rộng,...). Người ta cần phải cấu hình cấu trúc liên kết để phù hợp với
cấu hình trên mỗi thiết bị con được liên kết để truyền khung hình qua đường ống.
Nếu cấu hình không khớp, luồng sẽ không thành công. ZZ0000ZZ
gói là một gói ứng dụng không gian người dùng đi kèm với ZZ0001ZZ và
ZZ0002ZZ có thể được sử dụng để định cấu hình cấu hình vimc. Trình tự này
các lệnh phù hợp với cấu trúc liên kết mặc định:

.. code-block:: bash

        media-ctl -d platform:vimc -V '"Sensor A":0[fmt:SBGGR8_1X8/640x480]'
        media-ctl -d platform:vimc -V '"Debayer A":0[fmt:SBGGR8_1X8/640x480]'
        media-ctl -d platform:vimc -V '"Scaler":0[fmt:RGB888_1X24/640x480]'
        media-ctl -d platform:vimc -V '"Scaler":0[crop:(100,50)/400x150]'
        media-ctl -d platform:vimc -V '"Scaler":1[fmt:RGB888_1X24/300x700]'
        v4l2-ctl -z platform:vimc -d "RGB/YUV Capture" -v width=300,height=700
        v4l2-ctl -z platform:vimc -d "Raw Capture 0" -v pixelformat=BA81

Thiết bị phụ
----------

Các thiết bị con xác định hành vi của một thực thể trong cấu trúc liên kết. Tùy thuộc vào
thiết bị con, thực thể có thể có nhiều miếng đệm thuộc loại nguồn hoặc phần chìm.

cảm biến vimc:
	Tạo hình ảnh ở nhiều định dạng bằng cách sử dụng trình tạo mẫu thử nghiệm video.
	Phơi bày:

* 1 nguồn Pad

ống kính vimc:
	Ống kính phụ trợ cho cảm biến. Hỗ trợ điều khiển lấy nét tự động. Liên kết với
	một cảm biến vimc sử dụng liên kết phụ trợ. Ống kính hỗ trợ FOCUS_ABSOLUTE
	kiểm soát.

.. code-block:: bash

	media-ctl -p
	...
	- entity 28: Lens A (0 pad, 0 link)
			type V4L2 subdev subtype Lens flags 0
			device node name /dev/v4l-subdev6
	- entity 29: Lens B (0 pad, 0 link)
			type V4L2 subdev subtype Lens flags 0
			device node name /dev/v4l-subdev7
	v4l2-ctl -d /dev/v4l-subdev7 -C focus_absolute
	focus_absolute: 0


vimc-debayer:
	Chuyển đổi hình ảnh ở định dạng bayer sang định dạng không phải bayer.
	Phơi bày:

* 1 chậu rửa Pad
	* 1 nguồn Pad

công cụ chia tỷ lệ vimc:
	Thay đổi kích thước hình ảnh để đáp ứng độ phân giải của bảng nguồn. Ví dụ: nếu đồng bộ hóa
	pad được định cấu hình thành 360x480 và nguồn là 1280x720, hình ảnh sẽ
	được kéo dài để phù hợp với độ phân giải nguồn. Hoạt động với mọi độ phân giải
	trong giới hạn vimc (thậm chí thu nhỏ hình ảnh nếu cần thiết).
	Phơi bày:

* 1 chậu rửa Pad
	* 1 nguồn Pad

chụp vimc:
	Hiển thị nút /dev/videoX để cho phép không gian người dùng ghi lại luồng.
	Phơi bày:

* 1 chậu rửa Pad
	* 1 nguồn Pad

Tùy chọn mô-đun
--------------

Vimc có tham số mô-đun để định cấu hình trình điều khiển.

* ZZ0000ZZ

lựa chọn bộ cấp phát bộ nhớ, mặc định là 0. Nó chỉ định cách bộ đệm
	sẽ được phân bổ.

- 0: vmalloc
		- 1: dma-contig