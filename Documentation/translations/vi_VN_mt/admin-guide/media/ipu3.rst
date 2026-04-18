.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/ipu3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=====================================================================
Trình điều khiển Bộ xử lý hình ảnh Intel 3 (IPU3) (ImgU)
=====================================================================

Bản quyền ZZ0000ZZ 2018 Tập đoàn Intel

Giới thiệu
============

Tệp này ghi lại Intel IPU3 (Bộ xử lý hình ảnh thế hệ thứ 3)
Trình điều khiển Bộ Hình ảnh cũng nằm trong trình điều khiển/media/pci/intel/ipu3 (CIO2)
như trong trình điều khiển/dàn dựng/media/ipu3 (ImgU).

Intel IPU3 được tìm thấy ở một số hồ Kaby nhất định (cũng như một số hồ Sky nhất định)
nền tảng (dòng bộ xử lý U/Y) được tạo thành từ hai phần là Bộ phận Hình ảnh
(ImgU) và thiết bị CIO2 (bộ thu MIPI CSI2).

Thiết bị CIO2 nhận dữ liệu thô của Bayer từ các cảm biến và xuất ra
các khung ở định dạng dành riêng cho IPU3 (dành cho IPU3 sử dụng
ImgU). Trình điều khiển CIO2 có sẵn dưới dạng trình điều khiển/media/pci/intel/ipu3/ipu3-cio2*
và được kích hoạt thông qua tùy chọn cấu hình CONFIG_VIDEO_IPU3_CIO2.

Bộ phận Hình ảnh (ImgU) chịu trách nhiệm xử lý các hình ảnh được chụp
bởi thiết bị IPU3 CIO2. Các nguồn trình điều khiển ImgU có thể được tìm thấy trong
thư mục driver/staging/media/ipu3. Trình điều khiển được kích hoạt thông qua
Tùy chọn cấu hình CONFIG_VIDEO_IPU3_IMGU.

Hai mô-đun trình điều khiển có tên lần lượt là ipu3_csi2 và ipu3_imgu.

Trình điều khiển đã được thử nghiệm trên nền tảng Kaby Lake (dòng bộ xử lý U/Y).

Cả hai trình điều khiển đều triển khai V4L2, Bộ điều khiển phương tiện và thiết bị phụ V4L2
giao diện. Trình điều khiển IPU3 CIO2 hỗ trợ các cảm biến camera được kết nối với CIO2
MIPI CSI-2 giao tiếp thông qua trình điều khiển cảm biến thiết bị phụ V4L2.

CIO2
====

CIO2 được biểu diễn dưới dạng một subdev V4L2 duy nhất, cung cấp một subdev V4L2
giao diện với không gian người dùng. Có một nút video cho mỗi máy thu CSI-2,
với một giao diện điều khiển phương tiện duy nhất cho toàn bộ thiết bị.

CIO2 chứa bốn kênh thu âm độc lập, mỗi kênh có MIPI CSI-2 riêng
máy thu và động cơ DMA. Mỗi kênh được mô hình hóa như một thiết bị phụ V4L2 được hiển thị
tới không gian người dùng dưới dạng nút thiết bị phụ V4L2 và có hai phần đệm:

.. tabularcolumns:: |p{0.8cm}|p{4.0cm}|p{4.0cm}|

.. flat-table::
    :header-rows: 1

    * - Pad
      - Direction
      - Purpose

    * - 0
      - sink
      - MIPI CSI-2 input, connected to the sensor subdev

    * - 1
      - source
      - Raw video capture, connected to the V4L2 video interface

Giao diện video V4L2 mô hình hóa các động cơ DMA. Họ được tiếp xúc với không gian người dùng
như các nút thiết bị video V4L2.

Chụp khung hình ở định dạng Bayer thô
-------------------------------------

Bộ thu CIO2 MIPI CSI2 được sử dụng để chụp các khung hình (ở định dạng Bayer thô được đóng gói)
từ các cảm biến thô được kết nối với các cổng CSI2. Các khung hình đã chụp được sử dụng
làm đầu vào cho trình điều khiển ImgU.

Xử lý hình ảnh bằng IPU3 ImgU yêu cầu các công cụ như raw2pnm [#f1]_ và
yavta [#f2]_ do các yêu cầu riêng và/hoặc tính năng cụ thể sau đây
tới IPU3.

-- Bộ thu IPU3 CSI2 xuất các khung hình đã chụp từ cảm biến ở dạng được đóng gói
định dạng Bayer thô dành riêng cho IPU3.

-- Nhiều nút video phải được vận hành đồng thời.

Chúng ta hãy lấy ví dụ về cảm biến ov5670 được kết nối với cổng CSI2 0, để biết
Chụp ảnh 2592x1944.

Bằng cách sử dụng API của bộ điều khiển phương tiện, cảm biến ov5670 được định cấu hình để gửi
các khung ở định dạng Bayer thô được đóng gói tới bộ thu IPU3 CSI2.

.. code-block:: none

    # This example assumes /dev/media0 as the CIO2 media device
    export MDEV=/dev/media0

    # and that ov5670 sensor is connected to i2c bus 10 with address 0x36
    export SDEV=$(media-ctl -d $MDEV -e "ov5670 10-0036")

    # Establish the link for the media devices using media-ctl
    media-ctl -d $MDEV -l "ov5670:0 -> ipu3-csi2 0:0[1]"

    # Set the format for the media devices
    media-ctl -d $MDEV -V "ov5670:0 [fmt:SGRBG10/2592x1944]"
    media-ctl -d $MDEV -V "ipu3-csi2 0:0 [fmt:SGRBG10/2592x1944]"
    media-ctl -d $MDEV -V "ipu3-csi2 0:1 [fmt:SGRBG10/2592x1944]"

Khi đường truyền phương tiện được định cấu hình, cài đặt cụ thể của cảm biến mong muốn
(chẳng hạn như cài đặt độ phơi sáng và mức tăng) có thể được đặt bằng cách sử dụng công cụ yavta.

ví dụ

.. code-block:: none

    yavta -w 0x009e0903 444 $SDEV
    yavta -w 0x009e0913 1024 $SDEV
    yavta -w 0x009e0911 2046 $SDEV

Sau khi cài đặt cảm biến mong muốn, việc chụp khung hình có thể được thực hiện như dưới đây.

ví dụ

.. code-block:: none

    yavta --data-prefix -u -c10 -n5 -I -s2592x1944 --file=/tmp/frame-#.bin \
          -f IPU3_SGRBG10 $(media-ctl -d $MDEV -e "ipu3-cio2 0")

Với lệnh trên, 10 khung hình được chụp ở độ phân giải 2592x1944, với
định dạng sGRAG10 và xuất ra ở định dạng IPU3_SGRBG10.

Các khung đã chụp có sẵn dưới dạng tệp /tmp/frame-#.bin.

ImgU
====

ImgU được biểu diễn dưới dạng hai nhà phát triển con V4L2, mỗi nhà cung cấp một V4L2
giao diện subdev cho không gian người dùng.

Mỗi subdev V4L2 đại diện cho một ống, có thể hỗ trợ tối đa 2 luồng.
Điều này giúp hỗ trợ các tính năng máy ảnh nâng cao như Trình tìm kiếm chế độ xem liên tục (CVF)
và Ảnh chụp nhanh trong khi quay video (SDV).

ImgU chứa hai ống độc lập, mỗi ống được mô hình hóa như một thiết bị phụ V4L2
được tiếp xúc với không gian người dùng dưới dạng nút thiết bị phụ V4L2.

Mỗi ống có hai miếng đệm chìm và ba miếng nguồn nhằm mục đích sau:

.. tabularcolumns:: |p{0.8cm}|p{4.0cm}|p{4.0cm}|

.. flat-table::
    :header-rows: 1

    * - Pad
      - Direction
      - Purpose

    * - 0
      - sink
      - Input raw video stream

    * - 1
      - sink
      - Processing parameters

    * - 2
      - source
      - Output processed video stream

    * - 3
      - source
      - Output viewfinder video stream

    * - 4
      - source
      - 3A statistics

Mỗi miếng đệm được kết nối với giao diện video V4L2 tương ứng, được hiển thị 
không gian người dùng dưới dạng nút thiết bị video V4L2.

Vận hành thiết bị
-----------------

Với ImgU, khi nút video đầu vào ("ipu3-imgu 0/1":0, trong
<entity>:<pad-number> format) được xếp hàng đợi với bộ đệm (trong định dạng Bayer thô được đóng gói
format), ImgU bắt đầu xử lý bộ đệm và tạo đầu ra video ở định dạng YUV
đầu ra định dạng và thống kê trên các nút đầu ra tương ứng. Người lái xe được mong đợi
để có bộ đệm sẵn sàng cho tất cả các nút tham số, đầu ra và thống kê, khi
nút video đầu vào được xếp hàng đợi với bộ đệm.

Ở mức tối thiểu, tất cả đầu vào, đầu ra chính, số liệu thống kê 3A và kính ngắm
các nút video phải được bật để IPU3 bắt đầu xử lý hình ảnh.

Mỗi subdev ImgU V4L2 có tập hợp các nút video sau.

các nút video đầu vào, đầu ra và kính ngắm
------------------------------------------

Các khung hình (ở định dạng Bayer thô được đóng gói dành riêng cho IPU3) được nhận bởi
nút video đầu vào được xử lý bởi Bộ hình ảnh IPU3 và được xuất ra 2 video
các nút, với mỗi nút nhắm mục tiêu một mục đích khác nhau (đầu ra chính và kính ngắm
đầu ra).

Bạn có thể tìm thấy thông tin chi tiết về định dạng Bayer dành riêng cho IPU3 trong
ZZ0000ZZ.

Trình điều khiển hỗ trợ Giao diện quay video V4L2 như được xác định tại ZZ0000ZZ.

Chỉ hỗ trợ API đa mặt phẳng. Thông tin chi tiết có thể được tìm thấy tại
ZZ0000ZZ.

Nút video thông số
---------------------

Nút video tham số nhận các tham số thuật toán ImgU được sử dụng
để định cấu hình cách thuật toán ImgU xử lý hình ảnh.

Bạn có thể tìm thấy thông tin chi tiết về các tham số xử lý cụ thể cho IPU3 trong
ZZ0000ZZ.

Nút video thống kê 3A
------------------------

Nút video thống kê 3A được trình điều khiển ImgU sử dụng để xuất 3A (tự động
thống kê lấy nét, phơi sáng tự động và cân bằng trắng tự động) cho các khung hình được
đang được ImgU xử lý tới các ứng dụng không gian người dùng. Ứng dụng không gian người dùng
có thể sử dụng dữ liệu thống kê này để tính toán các tham số thuật toán mong muốn cho
ImgU.

Định cấu hình Intel IPU3
==========================

Có thể định cấu hình đường dẫn IPU3 ImgU bằng Bộ điều khiển phương tiện, được xác định tại
ZZ0000ZZ.

Chế độ chạy và lựa chọn nhị phân phần sụn
------------------------------------------

ImgU hoạt động dựa trên firmware, hiện tại firmware ImgU hỗ trợ chạy 2 pipe
trong việc chia sẻ thời gian với dữ liệu khung đầu vào duy nhất. Mỗi ống có thể chạy ở chế độ nhất định
- Chế độ "VIDEO" hoặc "STILL", "VIDEO" thường được sử dụng để quay khung hình video,
và "STILL" được sử dụng để chụp khung hình tĩnh. Tuy nhiên, bạn cũng có thể chọn
"VIDEO" để chụp các khung hình tĩnh nếu bạn muốn chụp ảnh với ít hệ thống hơn
tải và công suất. Đối với chế độ "STILL", ImgU sẽ cố gắng sử dụng hệ số BDS nhỏ hơn và
xuất ra khung bayer lớn hơn để xử lý YUV sâu hơn chế độ "VIDEO" để có được
hình ảnh chất lượng cao. Ngoài ra, chế độ "STILL" cần XNR3 để giảm tiếng ồn,
do đó chế độ "STILL" sẽ cần nhiều năng lượng và băng thông bộ nhớ hơn chế độ "VIDEO".
TNR sẽ được bật ở chế độ "VIDEO" và được bỏ qua bởi chế độ "STILL". ImgU là
chạy ở chế độ "VIDEO" theo mặc định, người dùng có thể sử dụng điều khiển v4l2
V4L2_CID_INTEL_IPU3_MODE (hiện được xác định trong
driver/staging/media/ipu3/include/uapi/intel-ipu3.h) để truy vấn và đặt
chế độ chạy. Đối với người dùng, không có sự khác biệt nào về việc xếp hàng bộ đệm giữa
Chế độ "VIDEO" và "STILL", nút đầu vào và đầu ra chính bắt buộc phải là
được bật và bộ đệm cần được xếp hàng đợi, số liệu thống kê và hàng đợi của công cụ tìm khung nhìn
là tùy chọn.

Tệp nhị phân phần sụn sẽ được chọn theo chế độ chạy hiện tại, nhật ký như vậy
"sử dụng nhị phân if_to_osys_striped" hoặc "sử dụng nhị phân if_to_osys_primary_striped"
có thể được quan sát thấy nếu bạn bật tính năng gỡ lỗi động ImgU, tệp nhị phân
if_to_osys_striped được chọn cho "VIDEO" và tệp nhị phân
"if_to_osys_primary_striped" được chọn cho "STILL".


Xử lý hình ảnh ở định dạng Bayer thô
----------------------------------------

Định cấu hình subdev ImgU V4L2 để xử lý hình ảnh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các nhà phát triển phụ ImgU V4L2 phải được cấu hình bằng API bộ điều khiển phương tiện để có
tất cả các nút video được thiết lập chính xác.

Hãy lấy subdev "ipu3-imgu 0" làm ví dụ.

.. code-block:: none

    media-ctl -d $MDEV -r
    media-ctl -d $MDEV -l "ipu3-imgu 0 input":0 -> "ipu3-imgu 0":0[1]
    media-ctl -d $MDEV -l "ipu3-imgu 0":2 -> "ipu3-imgu 0 output":0[1]
    media-ctl -d $MDEV -l "ipu3-imgu 0":3 -> "ipu3-imgu 0 viewfinder":0[1]
    media-ctl -d $MDEV -l "ipu3-imgu 0":4 -> "ipu3-imgu 0 3a stat":0[1]

Ngoài ra, chế độ đường ống của subdev V4L2 tương ứng phải được đặt theo ý muốn
(ví dụ: 0 cho chế độ video hoặc 1 cho chế độ tĩnh) thông qua id điều khiển 0x009819a1 dưới dạng
bên dưới.

.. code-block:: none

    yavta -w "0x009819A1 1" /dev/v4l-subdev7

Một số khối phần cứng nhất định trong đường dẫn ImgU có thể thay đổi độ phân giải khung hình bằng cách
cắt xén hoặc chia tỷ lệ, các khối phần cứng này bao gồm Bộ nạp đầu vào (IF), Bayer Down
Bộ chia tỷ lệ (BDS) và Hiệu chỉnh biến dạng hình học (GDC).
Ngoài ra còn có một khối có thể thay đổi độ phân giải khung hình - YUV Scaler, đó là
chỉ áp dụng cho đầu ra thứ cấp.

Các khung RAW của Bayer đi qua các khối phần cứng đường ống ImgU này và khối cuối cùng
đầu ra hình ảnh được xử lý vào bộ nhớ DDR.

.. kernel-figure::  ipu3_rcb.svg
   :alt: ipu3 resolution blocks image

   IPU3 resolution change hardware blocks

ZZ0000ZZ

Bộ nạp đầu vào lấy dữ liệu khung của Bayer từ cảm biến, nó có thể cho phép cắt xén
các dòng và cột từ khung rồi lưu các pixel vào bên trong thiết bị
bộ đệm pixel đã sẵn sàng để đọc theo các khối sau.

ZZ0000ZZ

Bayer Down Scaler có khả năng thực hiện chia tỷ lệ hình ảnh trong miền Bayer,
hệ số tỷ lệ giảm có thể được cấu hình từ 1X đến 1/4X ở mỗi trục với
các bước cấu hình 0,03125 (1/32).

ZZ0000ZZ

Hiệu chỉnh biến dạng hình học được sử dụng để thực hiện hiệu chỉnh biến dạng
và lọc hình ảnh. Nó cần thêm một số pixel bộ lọc và phần đệm bao để
hoạt động, do đó độ phân giải đầu vào của GDC phải lớn hơn độ phân giải đầu ra
độ phân giải.

ZZ0000ZZ

YUV Scaler tương tự như BDS, nhưng nó chủ yếu thực hiện thu nhỏ hình ảnh trong
Miền YUV, nó có thể hỗ trợ giảm tỷ lệ lên tới 1/12X, nhưng không thể áp dụng
đến đầu ra chính.

Nhà phát triển con ImgU V4L2 phải được định cấu hình với tất cả các độ phân giải được hỗ trợ
các khối phần cứng ở trên, cho độ phân giải đầu vào nhất định.
Đối với độ phân giải được hỗ trợ nhất định cho khung đầu vào, Bộ nạp đầu vào, Bayer
Các khối Down Scaler và GDC phải được định cấu hình với độ phân giải được hỗ trợ
vì mỗi khối phần cứng có yêu cầu căn chỉnh riêng.

Bạn phải cấu hình độ phân giải đầu ra của khối phần cứng một cách thông minh để đáp ứng
yêu cầu phần cứng cùng với việc giữ trường nhìn tối đa. các
độ phân giải trung gian có thể được tạo bằng công cụ cụ thể -

ZZ0000ZZ

Công cụ này có thể được sử dụng để tạo độ phân giải trung gian. Thông tin thêm có thể
có thể thu được bằng cách xem bảng cấu hình IPU3 ImgU sau đây.

ZZ0000ZZ

Dưới baseboard-poppy/media-libs/cros-CAMERA-hal-configs-poppy/files/gcss
thư mục, graph_settings_ov5670.xml có thể được sử dụng làm ví dụ.

Các bước sau đây chuẩn bị quy trình ImgU để xử lý hình ảnh.

1. Nên đặt định dạng dữ liệu con ImgU V4L2 bằng cách sử dụng
VIDIOC_SUBDEV_S_FMT trên pad 0, sử dụng chiều rộng và chiều cao GDC thu được ở trên.

2. Nên đặt việc cắt xén subdev ImgU V4L2 bằng cách sử dụng
VIDIOC_SUBDEV_S_SELECTION trên bảng 0, với V4L2_SEL_TGT_CROP là mục tiêu,
bằng cách sử dụng chiều cao và chiều rộng của bộ nạp đầu vào.

3. Việc soạn thảo subdev ImgU V4L2 phải được thiết lập bằng cách sử dụng
VIDIOC_SUBDEV_S_SELECTION trên bảng 0, với V4L2_SEL_TGT_COMPOSE là mục tiêu,
sử dụng chiều cao và chiều rộng BDS.

Đối với ví dụ ov5670, đối với khung đầu vào có độ phân giải 2592x1944
(là đầu vào của bảng phụ ImgU 0), độ phân giải tương ứng
đối với bộ nạp đầu vào, BDS và GDC là 2592x1944, 2592x1944 và 2560x1920
tương ứng.

Khi việc này hoàn tất, các khung Bayer thô nhận được có thể được nhập vào ImgU
Subdev V4L2 như bên dưới, sử dụng ứng dụng mã nguồn mở v4l2n [#f1]_.

Đối với hình ảnh được chụp với độ phân giải 2592x1944 [#f4]_, với đầu ra mong muốn
độ phân giải là 2560x1920 và độ phân giải của kính ngắm là 2560x1920, như sau
lệnh v4l2n có thể được sử dụng. Điều này giúp xử lý các khung Bayer thô và tạo ra
kết quả mong muốn cho hình ảnh đầu ra chính và đầu ra của kính ngắm, trong NV12
định dạng.

.. code-block:: none

    v4l2n --pipe=4 --load=/tmp/frame-#.bin --open=/dev/video4
          --fmt=type:VIDEO_OUTPUT_MPLANE,width=2592,height=1944,pixelformat=0X47337069 \
          --reqbufs=type:VIDEO_OUTPUT_MPLANE,count:1 --pipe=1 \
          --output=/tmp/frames.out --open=/dev/video5 \
          --fmt=type:VIDEO_CAPTURE_MPLANE,width=2560,height=1920,pixelformat=NV12 \
          --reqbufs=type:VIDEO_CAPTURE_MPLANE,count:1 --pipe=2 \
          --output=/tmp/frames.vf --open=/dev/video6 \
          --fmt=type:VIDEO_CAPTURE_MPLANE,width=2560,height=1920,pixelformat=NV12 \
          --reqbufs=type:VIDEO_CAPTURE_MPLANE,count:1 --pipe=3 --open=/dev/video7 \
          --output=/tmp/frames.3A --fmt=type:META_CAPTURE,? \
          --reqbufs=count:1,type:META_CAPTURE --pipe=1,2,3,4 --stream=5

Bạn cũng có thể sử dụng lệnh yavta [#f2]_ để thực hiện điều tương tự như trên:

.. code-block:: none

    yavta --data-prefix -Bcapture-mplane -c10 -n5 -I -s2592x1944 \
          --file=frame-#.out-f NV12 /dev/video5 & \
    yavta --data-prefix -Bcapture-mplane -c10 -n5 -I -s2592x1944 \
          --file=frame-#.vf -f NV12 /dev/video6 & \
    yavta --data-prefix -Bmeta-capture -c10 -n5 -I \
          --file=frame-#.3a /dev/video7 & \
    yavta --data-prefix -Boutput-mplane -c10 -n5 -I -s2592x1944 \
          --file=/tmp/frame-in.cio2 -f IPU3_SGRBG10 /dev/video4

trong đó các thiết bị /dev/video4, /dev/video5, /dev/video6 và /dev/video7 trỏ tới
các nút video thống kê đầu vào, đầu ra, kính ngắm và 3A tương ứng.

Chuyển đổi hình ảnh thô của Bayer thành miền YUV
------------------------------------------------

Hình ảnh được xử lý sau bước trên có thể được chuyển đổi sang miền YUV
như dưới đây.

Khung đầu ra chính
~~~~~~~~~~~~~~~~~~

.. code-block:: none

    raw2pnm -x2560 -y1920 -fNV12 /tmp/frames.out /tmp/frames.out.ppm

trong đó 2560x1920 là độ phân giải đầu ra, NV12 là định dạng video, theo sau là
bằng khung đầu vào và đầu ra tệp PNM.

Khung đầu ra của kính ngắm
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: none

    raw2pnm -x2560 -y1920 -fNV12 /tmp/frames.vf /tmp/frames.vf.ppm

trong đó 2560x1920 là độ phân giải đầu ra, NV12 là định dạng video, theo sau là
bằng khung đầu vào và đầu ra tệp PNM.

Mã không gian người dùng mẫu cho IPU3
=====================================

Mã không gian người dùng định cấu hình và sử dụng IPU3 có sẵn tại đây.

ZZ0000ZZ

Nguồn có thể được đặt trong thư mục hal/intel.

Tổng quan về đường ống IPU3
===========================

Đường ống IPU3 có một số giai đoạn xử lý hình ảnh, mỗi giai đoạn chiếm một
tập hợp các tham số làm đầu vào. Các giai đoạn chính của đường ống được hiển thị ở đây:

.. kernel-render:: DOT
   :alt: IPU3 ImgU Pipeline
   :caption: IPU3 ImgU Pipeline Diagram

   digraph "IPU3 ImgU" {
       node [shape=box]
       splines="ortho"
       rankdir="LR"

       a [label="Raw pixels"]
       b [label="Bayer Downscaling"]
       c [label="Optical Black Correction"]
       d [label="Linearization"]
       e [label="Lens Shading Correction"]
       f [label="White Balance / Exposure / Focus Apply"]
       g [label="Bayer Noise Reduction"]
       h [label="ANR"]
       i [label="Demosaicing"]
       j [label="Color Correction Matrix"]
       k [label="Gamma correction"]
       l [label="Color Space Conversion"]
       m [label="Chroma Down Scaling"]
       n [label="Chromatic Noise Reduction"]
       o [label="Total Color Correction"]
       p [label="XNR3"]
       q [label="TNR"]
       r [label="DDR", style=filled, fillcolor=yellow, shape=cylinder]
       s [label="YUV Downscaling"]
       t [label="DDR", style=filled, fillcolor=yellow, shape=cylinder]

       { rank=same; a -> b -> c -> d -> e -> f -> g -> h -> i }
       { rank=same; j -> k -> l -> m -> n -> o -> p -> q -> s -> t}

       a -> j [style=invis, weight=10]
       i -> j
       q -> r
   }

Bảng dưới đây trình bày mô tả về các thuật toán trên.

=====================================================================================
Tên Mô tả
=====================================================================================
Hiệu chỉnh màu đen quang học Khối hiệu chỉnh màu đen quang học trừ đi một giá trị được xác định trước
			 giá trị từ các giá trị pixel tương ứng để có được kết quả tốt hơn
			 chất lượng hình ảnh.
			 Được xác định trong struct ipu3_uapi_obgrid_param.
Tuyến tính hóa Khối thuật toán này sử dụng các tham số tuyến tính hóa để
			 giải quyết các hiệu ứng cảm biến phi tuyến tính. Bảng tra cứu
			 bảng được định nghĩa trong
			 cấu trúc ipu3_uapi_isp_lin_vmem_params.
SHD Hiệu chỉnh bóng ống kính được sử dụng để hiệu chỉnh không gian
			 phản hồi pixel không đồng đều do hiệu ứng quang học
			 che nắng ống kính. Điều này được thực hiện bằng cách áp dụng một mức tăng khác
			 cho mỗi pixel. Mức tăng, mức độ đen, v.v. là
			 được định cấu hình trong struct ipu3_uapi_shd_config_static.
Khối giảm nhiễu BNR của Bayer loại bỏ nhiễu hình ảnh bằng cách
			 áp dụng bộ lọc song phương.
			 Xem struct ipu3_uapi_bnr_static_config để biết chi tiết.
Giảm nhiễu nâng cao ANR là thuật toán dựa trên khối
			 thực hiện giảm nhiễu trong miền Bayer. các
			 ma trận tích chập vv có thể được tìm thấy trong
			 cấu trúc ipu3_uapi_anr_config.
DM Demosaicing chuyển đổi dữ liệu cảm biến thô ở định dạng Bayer
			 vào bản trình bày RGB (Đỏ, Xanh lục, Xanh lam). Sau đó thêm
			 kết quả ước tính kênh Y cho luồng sau
			 xử lý bằng Firmware. Cấu trúc được định nghĩa là
			 cấu trúc ipu3_uapi_dm_config.
Hiệu chỉnh màu Thuật toán hiệu chỉnh màu biến đổi màu cụ thể của cảm biến
			 không gian sang không gian màu "sRGB" tiêu chuẩn. Việc này được thực hiện
			 bằng cách áp dụng ma trận 3x3 được xác định trong
			 cấu trúc ipu3_uapi_ccm_mat_config.
Hiệu chỉnh gamma Cấu trúc hiệu chỉnh gamma ipu3_uapi_gamma_config là một
			 hiệu chỉnh ánh xạ giai điệu phi tuyến tính cơ bản
			 được áp dụng cho mỗi pixel cho từng thành phần pixel.
CSC Chuyển đổi không gian màu biến đổi từng pixel từ
			 Bản trình bày chính RGB cho YUV (Y: độ sáng,
			 Trình bày UV: Độ sáng). Điều này được thực hiện bằng cách áp dụng
			 ma trận 3x3 được xác định trong
			 cấu trúc ipu3_uapi_csc_mat_config
Lấy mẫu xuống Chroma CDS
			 Sau khi CSC được thực hiện, Lấy mẫu Chroma Down
			 được áp dụng cho lấy mẫu xuống mặt phẳng UV theo hệ số
			 2 theo mỗi hướng cho YUV 4:2:0 sử dụng 4x2
			 bộ lọc có thể định cấu hình struct ipu3_uapi_cds_params.
Giảm nhiễu Chroma CHNR
			 Khối này chỉ xử lý các pixel sắc độ và
			 thực hiện giảm tiếng ồn bằng cách làm sạch mức cao
			 nhiễu tần số.
			 Xem cấu trúc struct ipu3_uapi_yuvp1_chnr_config.
TCC Hiệu chỉnh màu tổng thể như được xác định trong cấu trúc
			 cấu trúc ipu3_uapi_yuvp2_tcc_static_config.
XNR3 eXtreme Noise Giảm V3 là phiên bản thứ ba của
			 Thuật toán giảm nhiễu được sử dụng để cải thiện hình ảnh
			 chất lượng. Điều này loại bỏ tiếng ồn tần số thấp trong
			 hình ảnh đã chụp. Hai cấu trúc liên quan đang được xác định,
			 struct ipu3_uapi_isp_xnr3_params cho bộ nhớ dữ liệu ISP
			 và struct ipu3_uapi_isp_xnr3_vmem_params cho vector
			 trí nhớ.
Khối giảm nhiễu tạm thời TNR so sánh liên tiếp
			 khung hình kịp thời để loại bỏ sự bất thường/nhiễu trong pixel
			 các giá trị. cấu trúc ipu3_uapi_isp_tnr3_vmem_params và
			 struct ipu3_uapi_isp_tnr3_params được xác định cho ISP
			 bộ nhớ vector và dữ liệu tương ứng.
=====================================================================================

Các từ viết tắt thường gặp khác không được liệt kê trong bảng trên:

ACC
		Cụm máy gia tốc
	AWB_FR
		Thống kê phản hồi của bộ lọc cân bằng trắng tự động
	BDS
		Thông số thu nhỏ của Bayer
	CCM
		Hệ số ma trận hiệu chỉnh màu
	IEFd
		Bộ lọc nâng cao hình ảnh được hướng dẫn
	lưới điện
		Bù mức độ đen quang học
	OSYS
		Cấu hình hệ thống đầu ra
	ROI
		Khu vực quan tâm
	YDS
		Lấy mẫu Y xuống
	YTM
		Ánh xạ giai điệu Y

Một số giai đoạn của quy trình sẽ được thực thi bởi chương trình cơ sở chạy trên ISP
bộ xử lý, trong khi nhiều bộ xử lý khác cũng sẽ sử dụng một tập hợp các khối phần cứng cố định
được gọi là cụm tăng tốc (ACC) để xử lý dữ liệu pixel và tạo ra số liệu thống kê.

Các tham số ACC của các thuật toán riêng lẻ, như được xác định bởi
struct ipu3_uapi_acc_param, người dùng có thể chọn để áp dụng
không gian thông qua struct struct ipu3_uapi_flags được nhúng trong
cấu trúc ipu3_uapi_params. Đối với các tham số được cấu hình là
không được kích hoạt bởi không gian người dùng, các cấu trúc tương ứng sẽ bị bỏ qua bởi
trình điều khiển, trong trường hợp đó cấu hình hiện tại của thuật toán sẽ là
được bảo tồn.

Tài liệu tham khảo
==================

.. [#f1] https://github.com/intel/nvt

.. [#f2] http://git.ideasonboard.org/yavta.git

.. [#f4] ImgU limitation requires an additional 16x16 for all input resolutions