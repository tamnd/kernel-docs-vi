.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/mali-c55.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Trình điều khiển bộ xử lý tín hiệu hình ảnh ARM Mali-C55
==========================================

Giới thiệu
============

Tệp này ghi lại trình điều khiển cho Bộ xử lý tín hiệu hình ảnh Mali-C55 của ARM. các
trình điều khiển nằm dưới trình điều khiển/media/platform/arm/mali-c55.

Mali-C55 ISP nhận dữ liệu ở định dạng Bayer thô hoặc định dạng RGB/YUV từ
cảm biến thông qua giao diện song song hoặc bus bộ nhớ trước khi xử lý nó
và xuất nó thông qua một công cụ DMA bên trong. Hai đường ống đầu ra là
có thể (mặc dù một cái có thể không được trang bị, tùy thuộc vào việc triển khai). Những cái này
được gọi là "Độ phân giải đầy đủ" và "Giảm tỷ lệ", nhưng việc đặt tên mang tính lịch sử
và cả hai ống đều có khả năng thực hiện các hoạt động cắt xén/thu nhỏ. Độ phân giải đầy đủ
pipe cũng có khả năng xuất dữ liệu RAW, bỏ qua phần lớn dữ liệu của ISP.
xử lý. Ống hạ cấp không thể xuất dữ liệu RAW. Một bài kiểm tra tích hợp
trình tạo mẫu có thể được sử dụng để điều khiển ISP và tạo dữ liệu hình ảnh trong
thiếu cảm biến camera được kết nối. Mô-đun trình điều khiển có tên mali_c55 và
được kích hoạt thông qua tùy chọn cấu hình CONFIG_VIDEO_MALI_C55.

Trình điều khiển triển khai các giao diện V4L2, Media Controller và V4L2 Subdevice và
hy vọng các cảm biến máy ảnh được kết nối với ISP sẽ có giao diện thiết bị con V4L2.

Phần cứng Mali-C55 ISP
=====================

Dưới đây là chế độ xem chức năng cấp cao của Mali-C55 ISP. ISP
lấy đầu vào từ nguồn trực tiếp hoặc thông qua công cụ DMA để đầu vào bộ nhớ,
tùy thuộc vào sự tích hợp SoC.::

+----------+ +----------+ +--------+
  ZZ0000ZZ--->ZZ0001ZZ "Độ phân giải đầy đủ" ZZ0002ZZ
  +----------+ +----------+ ZZ0003ZZ Nhà văn |
                       ZZ0004ZZ \ |    +--------+
                       ZZ0005ZZ \ +----------+ +------+---> Truyền phát I/O
  +----------+ +------->ZZ0006ZZ ZZ0007ZZ |
  ZZ0008ZZ ZZ0009ZZ->ZZ0010ZZ--+
  ZZ0011ZZ--------------->ZZ0012ZZ ZZ0013ZZ |
  ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ +---> Truyền phát I/O
  +----------+ ZZ0017ZZ |
                                |/ +------+
                                                             |    +--------+
                                                             +--->ZZ0018ZZ
                                               "Thu nhỏ" ZZ0019ZZ
                                                  Đầu ra +--------+

Cấu trúc liên kết điều khiển phương tiện
=========================

Một ví dụ về cấu trúc liên kết của ISP (như được triển khai trong hệ thống có IMX415
cảm biến máy ảnh và bộ thu CSI-2 chung) bên dưới:


.. kernel-figure:: mali-c55-graph.dot
    :alt:   mali-c55-graph.dot
    :align: center

Trình điều khiển có 4 thiết bị con V4L2:

- ZZ0000ZZ: Chịu trách nhiệm cấu hình crop đầu vào và không gian màu
                  chuyển đổi
- ZZ0001ZZ: Trình tạo mẫu thử nghiệm, mô phỏng cảm biến máy ảnh.
- ZZ0002ZZ: Bộ thay đổi kích thước ống có độ phân giải đầy đủ
- ZZ0003ZZ: Bộ thay đổi kích thước đường ống Downscale

Trình điều khiển có 3 thiết bị video V4L2:

- ZZ0000ZZ: Thiết bị chụp ống có độ phân giải đầy đủ
- ZZ0001ZZ: Thiết bị chụp đường ống cấp dưới
- ZZ0002ZZ: Thiết bị thu thập số liệu thống kê 3A

Chuỗi khung hình được đồng bộ hóa giữa hai thiết bị chụp, nghĩa là nếu một
đường ống được bắt đầu muộn hơn đường ống khác, số thứ tự được trả về trong nó
bộ đệm sẽ khớp với bộ đệm của đường ống khác thay vì bắt đầu từ số 0.

đặc điểm riêng
--------------

ZZ0001ZZ
Thiết bị con ZZ0000ZZ có một bảng chìm duy nhất chứa tất cả các nguồn dữ liệu
nên được kết nối. Nguồn hoạt động được chọn bằng cách kích hoạt tùy chọn thích hợp
liên kết phương tiện và vô hiệu hóa tất cả những người khác. ISP có hai miếng nguồn, phản ánh
các đường dẫn khác nhau mà qua đó nó có thể định tuyến dữ liệu nội bộ. Nhấn vào các điểm bên trong
ISP cho phép người dùng chuyển hướng dữ liệu để tránh việc xử lý bởi một số hoặc tất cả
các bước xử lý của phần cứng. Sơ đồ dưới đây chỉ nhằm mục đích làm nổi bật cách thức
việc bỏ qua hoạt động và không phản ánh đúng các bước xử lý đó; cho
sơ đồ khối chức năng cấp cao, xem trang dành cho nhà phát triển của ARM để biết
ISP [3]_::

+-------------------------------------------------------------- +
  ZZ0000ZZ
  ZZ0001ZZ
  +---+ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ +---+
  ZZ0005ZZ---+-->ZZ0006ZZ->ZZ0007ZZ->ZZ0008ZZ--->ZZ0009ZZ
  +---+ Chuyển đổi ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ |    +---+
  ZZ0013ZZ +-------------+ +----------+ +-------------+ |
  ZZ0014ZZ +---+
  ZZ0015ZZ 2 |
  |                                                          +---+
  ZZ0016ZZ
  +-------------------------------------------------------------- +


.. flat-table::
    :header-rows: 1

    * - Pad
      - Direction
      - Purpose

    * - 0
      - sink
      - Data input, connected to the TPG and camera sensors

    * - 1
      - source
      - RGB/YUV data, connected to the FR and DS V4L2 subdevices

    * - 2
      - source
      - RAW bayer data, connected to the FR V4L2 subdevices

ISP bị giới hạn ở cả độ phân giải đầu vào và đầu ra trong khoảng từ 640x480 đến
8192x8192 và điều này được phản ánh trong ISP và .set_fmt() của thiết bị con thay đổi kích thước
hoạt động.

ZZ0001ZZ
Thiết bị con ZZ0000ZZ có hai miếng đệm _sink_ để phản ánh các vùng khác nhau
các điểm chèn trong phần cứng (RAW hoặc dữ liệu bị loại bỏ):

.. flat-table::
    :header-rows: 1

    * - Pad
      - Direction
      - Purpose

    * - 0
      - sink
      - Data input connected to the ISP's demosaiced stream.

    * - 1
      - source
      - Data output connected to the capture video device

    * - 2
      - sink
      - Data input connected to the ISP's raw data stream

Nguồn dữ liệu đang sử dụng được chọn thông qua định tuyến API; mỗi tuyến có hai tuyến đường
luồng duy nhất có sẵn:

.. flat-table::
    :header-rows: 1

    * - Sink Pad
      - Source Pad
      - Purpose

    * - 0
      - 1
      - Demosaiced data route

    * - 2
      - 1
      - Raw data route


Nếu tuyến đường bị khử hoạt động thì ống FR chỉ có khả năng xuất ra
ở định dạng RGB/YUV. Nếu tuyến thô đang hoạt động thì đầu ra phản ánh
đầu vào (có thể là dữ liệu Bayer hoặc RGB/YUV).

Sử dụng trình điều khiển để quay video
=================================

Bằng cách sử dụng API bộ điều khiển phương tiện, chúng ta có thể định cấu hình nguồn đầu vào và ISP để
chụp ảnh ở nhiều định dạng khác nhau. Trong các ví dụ dưới đây, việc định cấu hình
biểu đồ phương tiện được thực hiện bằng tiện ích media-ctl của gói v4l-utils [1]_.
Việc chụp ảnh được thực hiện bằng yavta [2]_.

Định cấu hình nguồn đầu vào
----------------------------

Bước đầu tiên là đặt nguồn đầu vào mà chúng ta muốn bằng cách bật chính xác
liên kết truyền thông. Sử dụng cấu trúc liên kết mẫu ở trên, chúng ta có thể chọn TPG như sau:

.. code-block:: none

    media-ctl -l "'lte-csi2-rx':1->'mali-c55 isp':0[0]"
    media-ctl -l "'mali-c55 tpg':0->'mali-c55 isp':0[1]"

Định cấu hình thiết bị video nào sẽ truyền dữ liệu
------------------------------------------------

Trình điều khiển sẽ đợi tất cả các thiết bị video có VIDIOC_STREAMON ioctl
được gọi trước khi nó báo cho cảm biến bắt đầu truyền phát. Để tạo điều kiện thuận lợi cho việc này chúng ta cần
để kích hoạt liên kết đến các thiết bị video mà chúng tôi muốn sử dụng. Trong ví dụ dưới đây
chúng tôi kích hoạt các liên kết đến cả hai thiết bị quay video chụp ảnh

.. code-block:: none

    media-ctl -l "'mali-c55 resizer fr':1->'mali-c55 fr':0[1]"
    media-ctl -l "'mali-c55 resizer ds':1->'mali-c55 ds':0[1]"

Thu thập dữ liệu bayer từ nguồn và xử lý thành RGB/YUV
--------------------------------------------------------------

Để thu thập dữ liệu bayer 1920x1080 từ nguồn và đẩy nó qua ISP
toàn bộ quy trình xử lý, chúng tôi định cấu hình các định dạng dữ liệu phù hợp trên
nguồn, ISP và các thiết bị con của bộ thay đổi kích thước và đặt định tuyến của bộ thay đổi kích thước FR để chọn
dữ liệu đã được xử lý. Định dạng bus phương tiện trên bảng nguồn của bộ thay đổi kích thước sẽ là
RGB121212_1X36 hoặc YUV10_1X30, tùy thuộc vào việc bạn muốn chụp RGB hay
YUV. Khối gỡ lỗi của ISP xuất ra dữ liệu RGB nguyên bản, thiết lập nguồn
định dạng pad sang YUV10_1X30 cho phép khối chuyển đổi không gian màu.

Trong ví dụ này, chúng tôi nhắm mục tiêu đầu ra RGB565, vì vậy hãy chọn RGB121212_1X36 làm bộ thay đổi kích thước
định dạng của bảng nguồn:

.. code-block:: none

    # Set formats on the TPG and ISP
    media-ctl -V "'mali-c55 tpg':0[fmt:SRGGB20_1X20/1920x1080]"
    media-ctl -V "'mali-c55 isp':0[fmt:SRGGB20_1X20/1920x1080]"
    media-ctl -V "'mali-c55 isp':1[fmt:SRGGB20_1X20/1920x1080]"

    # Set routing on the FR resizer
    media-ctl -R "'mali-c55 resizer fr'[0/0->1/0[1],2/0->1/0[0]]"

    # Set format on the resizer, must be done AFTER the routing.
    media-ctl -V "'mali-c55 resizer fr':1[fmt:RGB121212_1X36/1920x1080]"

Đầu ra thu nhỏ cũng có thể được sử dụng để truyền dữ liệu cùng lúc. Trong này
trường hợp vì chỉ dữ liệu đã xử lý mới có thể được ghi lại thông qua đầu ra thu nhỏ
định tuyến cần được thiết lập:

.. code-block:: none

    # Set format on the resizer
    media-ctl -V "'mali-c55 resizer ds':1[fmt:RGB121212_1X36/1920x1080]"

Theo dõi những hình ảnh nào có thể được chụp từ cả video của đầu ra FR và DS
thiết bị (đồng thời, nếu muốn):

.. code-block:: none

    yavta -f RGB565 -s 1920x1080 -c10 /dev/video0
    yavta -f RGB565 -s 1920x1080 -c10 /dev/video1

Cắt ảnh
~~~~~~~~~~~~~~~~~~

Cả ống có độ phân giải đầy đủ và ống thu nhỏ đều có thể cắt thành độ phân giải tối thiểu là
640x480. Để cắt hình ảnh, chỉ cần định cấu hình phần cắt của bảng điều chỉnh kích thước và
soạn hình chữ nhật và đặt định dạng trên thiết bị video:

.. code-block:: none

    media-ctl -V "'mali-c55 resizer fr':0[fmt:RGB121212_1X36/1920x1080 crop:(480,270)/640x480 compose:(0,0)/640x480]"
    media-ctl -V "'mali-c55 resizer fr':1[fmt:RGB121212_1X36/640x480]"
    yavta -f RGB565 -s 640x480 -c10 /dev/video0

Thu nhỏ hình ảnh
~~~~~~~~~~~~~~~~~~~~~

Cả ống có độ phân giải đầy đủ và ống thu nhỏ đều có thể thu nhỏ hình ảnh lên tới 8 lần
với điều kiện phải tuân thủ độ phân giải đầu ra tối thiểu 640x480. Để có hình ảnh đẹp nhất
kết quả là tỷ lệ chia tỷ lệ cho mỗi hướng phải giống nhau. Để cấu hình
chia tỷ lệ, chúng tôi sử dụng hình chữ nhật soạn thảo trên bảng chìm của bộ thay đổi kích thước:

.. code-block:: none

    media-ctl -V "'mali-c55 resizer fr':0[fmt:RGB121212_1X36/1920x1080 crop:(0,0)/1920x1080 compose:(0,0)/640x480]"
    media-ctl -V "'mali-c55 resizer fr':1[fmt:RGB121212_1X36/640x480]"
    yavta -f RGB565 -s 640x480 -c10 /dev/video0

Chụp ảnh ở định dạng YUV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu chúng ta cần xuất dữ liệu YUV thay vì RGB, khối chuyển đổi không gian màu
cần phải hoạt động, điều này đạt được bằng cách đặt MEDIA_BUS_FMT_YUV10_1X30 trên
bảng nguồn của bộ thay đổi kích thước. Sau đó, chúng tôi có thể định cấu hình định dạng chụp như NV12 (ở đây là
biến thể đa mặt phẳng của nó)

.. code-block:: none

    media-ctl -V "'mali-c55 resizer fr':1[fmt:YUV10_1X30/1920x1080]"
    yavta -f NV12M -s 1920x1080 -c10 /dev/video0

Thu thập dữ liệu RGB từ nguồn và xử lý dữ liệu đó bằng bộ thay đổi kích thước
----------------------------------------------------------------------

Mali-C55 ISP có thể hoạt động với các cảm biến có khả năng xuất dữ liệu RGB. Trong này
trường hợp mặc dù không có khối chất lượng hình ảnh nào được sử dụng nhưng nó vẫn có thể
cắt/chia tỷ lệ dữ liệu theo cách thông thường. Vì lý do này, dữ liệu RGB được nhập vào ISP
vẫn đi qua phần đệm 1 của thiết bị con ISP tới bộ thay đổi kích thước.

Để đạt được điều này, định dạng của tấm lót bồn rửa ISP được đặt thành
MEDIA_BUS_FMT_RGB202020_1X60 - điều này phản ánh định dạng mà dữ liệu phải có
làm việc với ISP. Việc chuyển đổi đầu ra của cảm biến máy ảnh sang định dạng đó là
trách nhiệm của phần cứng bên ngoài.

Trong ví dụ này, chúng tôi yêu cầu trình tạo mẫu thử nghiệm cung cấp cho chúng tôi dữ liệu RGB thay vì
bayer.

.. code-block:: none

    media-ctl -V "'mali-c55 tpg':0[fmt:RGB202020_1X60/1920x1080]"
    media-ctl -V "'mali-c55 isp':0[fmt:RGB202020_1X60/1920x1080]"

Việc cắt xén hoặc chia tỷ lệ dữ liệu có thể được thực hiện theo cách tương tự như đã nêu
trước đó.

Thu thập dữ liệu thô từ nguồn và xuất ra dữ liệu chưa sửa đổi
-----------------------------------------------------------------

ISP có thể thu thập thêm dữ liệu thô từ nguồn và xuất dữ liệu đó trên
chỉ có ống có độ phân giải đầy đủ, hoàn toàn không được sửa đổi. Trong trường hợp này tỷ lệ giảm
pipe vẫn có thể xử lý dữ liệu bình thường và sử dụng đồng thời.

Để định cấu hình bỏ qua thô, bảng định tuyến của thiết bị con của bộ chỉnh lại FR cần phải được
được định cấu hình, theo sau là các định dạng ở những nơi thích hợp:

.. code-block:: none

    media-ctl -R "'mali-c55 resizer fr'[0/0->1/0[0],2/0->1/0[1]]"
    media-ctl -V "'mali-c55 isp':0[fmt:RGB202020_1X60/1920x1080]"
    media-ctl -V "'mali-c55 resizer fr':2[fmt:RGB202020_1X60/1920x1080]"
    media-ctl -V "'mali-c55 resizer fr':1[fmt:RGB202020_1X60/1920x1080]"

    # Set format on the video device and stream
    yavta -f RGB565 -s 1920x1080 -c10 /dev/video0

.. _mali-c55-3a-stats:

Chụp số liệu thống kê ISP
========================

ISP có khả năng tạo số liệu thống kê tiêu thụ bằng cách xử lý hình ảnh
các thuật toán chạy trong không gian người dùng. Những số liệu thống kê này có thể được nắm bắt bằng cách xếp hàng
đệm vào Thiết bị ZZ0001ZZ V4L2 trong khi ISP đang phát trực tuyến. Chỉ
ZZ0000ZZ
định dạng được hỗ trợ, do đó không cần thực hiện cài đặt định dạng:

.. code-block:: none

    # We assume the media graph has been configured to support RGB565 capture
    # from the mali-c55 fr V4L2 Device, which is at /dev/video0. The statistics
    # V4L2 device is at /dev/video3

    yavta -f RGB565 -s 1920x1080 -c32 /dev/video0 && \
    yavta -c10 -F /dev/video3

Bố cục của bộ đệm được mô tả bởi ZZ0000ZZ,
nhưng số liệu thống kê nói chung được tạo ra để hỗ trợ ba quá trình xử lý hình ảnh
thuật toán; AEXP (Tự động phơi sáng), AWB (Cân bằng trắng tự động) và AF (Tự động lấy nét).
Các số liệu thống kê này có thể được lấy từ nhiều nơi khác nhau trong đường ống Mali C55 ISP, được biết đến
là "điểm nhấn". Sơ đồ khối cấp cao này nhằm mục đích giải thích vị trí trong
luồng xử lý, số liệu thống kê có thể được rút ra từ::

+--> AEXP-2 +----> AEXP-1 +--> AF-0
                  ZZ0000ZZ
                  ZZ0001ZZ |
      +----------+ ZZ0002ZZ +--------------+ |
      |  Đầu vào +-+-->+ Tăng âm kỹ thuật số +---+-->+ Mức độ đen +---+---+
      +--------------+ +--------------+ +--------------+ |
  +--------------------------------------------------------------------------------+
  |
  |   +--------------+ +----------+ +-------+
  +-->ZZ0003ZZ Che ống kính +---+--------------+
      ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ |
      +--------------+ +--------------+ ZZ0008ZZ |
                                    +---> AEXP-0 (A) +--> AEXP-0 (B) |
  +-----------------------------------------------------------------------------------+
  |
  |   +++ +--------------+ +----------------+
  +-->ZZ0009ZZ Demosaicing +->+ Viền Tím +-+-----------+
      ZZ0010ZZ ZZ0011ZZ Hiệu chỉnh ZZ0012ZZ |
      +++ +-> AEXP-IRIDIX +----------------+ +---> AWB-0 |
  +-------------------------------------------------------------------------- +
  |                    +-------------+ +-------------+
  +------------------->Đầu ra ZZ0013ZZ |
                       Đường ống ZZ0014ZZ ZZ0015ZZ |
                       +-------------+ |    +-------------+
                                         +--> AWB-1

Theo mặc định, tất cả số liệu thống kê được rút ra từ điểm nhấn thứ 0 cho mỗi thuật toán;
I.E. Thống kê AEXP từ AEXP-0 (A), thống kê AWB từ AWB-0 và AF
thống kê từ AF-0. Điều này có thể được cấu hình cho số liệu thống kê AEXP và AWB thông qua
lập trình các thông số của ISP.

.. _mali-c55-3a-params:

Lập trình thông số ISP
==========================

ISP có thể được lập trình với nhiều thông số khác nhau từ không gian người dùng để áp dụng cho
phần cứng trước và trong khi truyền phát video. Điều này cho phép không gian người dùng tự động
thay đổi các giá trị như mức độ màu đen, cân bằng trắng và mức tăng bóng của ống kính, v.v.
trên.

Định dạng bộ đệm và cách điền nó được mô tả bởi
Định dạng ZZ0000ZZ,
nên được đặt làm định dạng dữ liệu cho nút video ZZ0001ZZ.

Tài liệu tham khảo
==========
.. [1] https://git.linuxtv.org/v4l-utils.git/
.. [2] https://git.ideasonboard.org/yavta.git
.. [3] https://developer.arm.com/Processors/Mali-C55