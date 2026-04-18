.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/ipu6-isys.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================================================================
Trình điều khiển hệ thống đầu vào Intel Image Treatment Unit 6 (IPU6)
=====================================================================

Bản quyền ZZ0000ZZ 2023--2024 Tập đoàn Intel

Giới thiệu
============

Tệp này ghi lại Intel IPU6 (Bộ xử lý hình ảnh thế hệ thứ 6)
Trình điều khiển Hệ thống đầu vào (bộ thu MIPI CSI2) nằm bên dưới
trình điều khiển/phương tiện/pci/intel/ipu6.

Intel IPU6 có thể được tìm thấy trong một số SoC Intel nhất định nhưng không có trong tất cả SKU:

* Hồ Hổ
* Hồ Jasper
* Hồ Alder
* Hồ Raptor
* Hồ sao băng

Intel IPU6 được tạo thành từ hai thành phần - Hệ thống đầu vào (ISYS) và Xử lý
Hệ thống (PSYS).

Hệ thống đầu vào chủ yếu hoạt động như bộ thu MIPI CSI-2 nhận và
xử lý dữ liệu hình ảnh từ các cảm biến và xuất khung hình vào bộ nhớ.

Có 2 mô-đun trình điều khiển - intel-ipu6 và intel-ipu6-isys. intel-ipu6 là một
Trình điều khiển phổ biến IPU6 thực hiện cấu hình PCI, tải và phân tích chương trình cơ sở,
xác thực chương trình cơ sở, ánh xạ DMA và IPU-MMU (Đơn vị ánh xạ bộ nhớ trong)
cấu hình. intel_ipu6_isys triển khai V4L2, Bộ điều khiển phương tiện và V4L2
giao diện thiết bị phụ. Trình điều khiển IPU6 ISYS hỗ trợ kết nối cảm biến camera
đến IPU6 ISYS thông qua trình điều khiển cảm biến thiết bị phụ V4L2.

.. Note:: See Documentation/driver-api/media/drivers/ipu6.rst for more
	  information about the IPU6 hardware.

Trình điều khiển hệ thống đầu vào
===================

Trình điều khiển Hệ thống đầu vào chủ yếu cấu hình CSI-2 D-PHY, xây dựng chương trình cơ sở
cấu hình luồng, gửi lệnh đến phần sụn, nhận phản hồi từ phần cứng
và phần sụn rồi trả về bộ đệm cho người dùng.  ISYS được biểu diễn dưới dạng
một số thiết bị phụ V4L2 cũng như các nút video.

.. kernel-figure::  ipu6_isys_graph.svg
   :alt: ipu6 isys media graph with multiple streams support

   IPU6 ISYS media graph with multiple streams support

Biểu đồ đã được tạo bằng lệnh sau:

.. code-block:: none

   fdp -Gsplines=true -Tsvg < dot > dot.svg

Chụp khung hình với IPU6 ISYS
-------------------------------

IPU6 ISYS được sử dụng để chụp các khung hình từ các cảm biến máy ảnh được kết nối với
Cổng CSI2. Các định dạng đầu vào được hỗ trợ của ISYS được liệt kê trong bảng bên dưới:

.. tabularcolumns:: |p{0.8cm}|p{4.0cm}|p{4.0cm}|

.. flat-table::
    :header-rows: 1

    * - IPU6 ISYS supported input formats

    * - RGB565, RGB888

    * - UYVY8, YUYV8

    * - RAW8, RAW10, RAW12

.. _ipu6_isys_capture_examples:

Ví dụ
~~~~~~~~

Dưới đây là một ví dụ về chụp thô IPU6 ISYS trên máy tính xách tay Dell XPS 9315. Trên này
máy, cảm biến ov01a10 được kết nối với cổng 2 IPU ISYS CSI-2, có thể
tạo hình ảnh ở sBGGR10 với độ phân giải 1280x800.

Bằng cách sử dụng API của bộ điều khiển phương tiện, chúng ta có thể định cấu hình cảm biến ov01a10 bằng cách
media-ctl [#f1]_ và yavta [#f2]_ để truyền khung hình tới IPU6 ISYS.

.. code-block:: none

    # Example 1 capture frame from ov01a10 camera sensor
    # This example assumes /dev/media0 as the IPU ISYS media device
    export MDEV=/dev/media0

    # Establish the link for the media devices using media-ctl
    media-ctl -d $MDEV -l "\"ov01a10 3-0036\":0 -> \"Intel IPU6 CSI2 2\":0[1]"

    # Set the format for the media devices
    media-ctl -d $MDEV -V "ov01a10:0 [fmt:SBGGR10/1280x800]"
    media-ctl -d $MDEV -V "Intel IPU6 CSI2 2:0 [fmt:SBGGR10/1280x800]"
    media-ctl -d $MDEV -V "Intel IPU6 CSI2 2:1 [fmt:SBGGR10/1280x800]"

Khi đường truyền phương tiện được định cấu hình, cài đặt cụ thể của cảm biến mong muốn
(chẳng hạn như cài đặt độ phơi sáng và mức tăng) có thể được đặt bằng cách sử dụng công cụ yavta.

ví dụ

.. code-block:: none

    # and that ov01a10 sensor is connected to i2c bus 3 with address 0x36
    export SDEV=$(media-ctl -d $MDEV -e "ov01a10 3-0036")

    yavta -w 0x009e0903 400 $SDEV
    yavta -w 0x009e0913 1000 $SDEV
    yavta -w 0x009e0911 2000 $SDEV

Sau khi cài đặt cảm biến mong muốn, việc chụp khung hình có thể được thực hiện như dưới đây.

ví dụ

.. code-block:: none

    yavta --data-prefix -u -c10 -n5 -I -s 1280x800 --file=/tmp/frame-#.bin \
            -f SBGGR10 $(media-ctl -d $MDEV -e "Intel IPU6 ISYS Capture 0")

Với lệnh trên, 10 khung hình được chụp ở độ phân giải 1280x800 với
định dạng sBGGR10. Các khung đã chụp có sẵn dưới dạng tệp /tmp/frame-#.bin.

Đây là một ví dụ khác về IPU6 ISYS RAW và chụp siêu dữ liệu từ máy ảnh
cảm biến ov2740 trên laptop Lenovo X1 Yoga.

.. code-block:: none

    media-ctl -l "\"ov2740 14-0036\":0 -> \"Intel IPU6 CSI2 1\":0[1]"
    media-ctl -l "\"Intel IPU6 CSI2 1\":1 -> \"Intel IPU6 ISYS Capture 0\":0[1]"
    media-ctl -l "\"Intel IPU6 CSI2 1\":2 -> \"Intel IPU6 ISYS Capture 1\":0[1]"

    # set routing
    media-ctl -R "\"Intel IPU6 CSI2 1\" [0/0->1/0[1],0/1->2/1[1]]"

    media-ctl -V "\"Intel IPU6 CSI2 1\":0/0 [fmt:SGRBG10/1932x1092]"
    media-ctl -V "\"Intel IPU6 CSI2 1\":0/1 [fmt:GENERIC_8/97x1]"
    media-ctl -V "\"Intel IPU6 CSI2 1\":1/0 [fmt:SGRBG10/1932x1092]"
    media-ctl -V "\"Intel IPU6 CSI2 1\":2/1 [fmt:GENERIC_8/97x1]"

    CAPTURE_DEV=$(media-ctl -e "Intel IPU6 ISYS Capture 0")
    ./yavta --data-prefix -c100 -n5 -I -s1932x1092 --file=/tmp/frame-#.bin \
        -f SGRBG10 ${CAPTURE_DEV}

    CAPTURE_META=$(media-ctl -e "Intel IPU6 ISYS Capture 1")
    ./yavta --data-prefix -c100 -n5 -I -s97x1 -B meta-capture \
        --file=/tmp/meta-#.bin -f GENERIC_8 ${CAPTURE_META}

Tài liệu tham khảo
==========

.. [#f1] https://git.ideasonboard.org/media-ctl.git
.. [#f2] https://git.ideasonboard.org/yavta.git