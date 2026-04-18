.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/rkisp1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============================================
Bộ xử lý tín hiệu hình ảnh Rockchip (rkisp1)
=============================================

Giới thiệu
============

Tệp này ghi lại trình điều khiển cho Rockchip ISP1 là một phần của RK3288
và SoC RK3399. Trình điều khiển nằm dưới trình điều khiển/phương tiện/nền tảng/rockchip/
rkisp1 và sử dụng Bộ điều khiển phương tiện API.

Sửa đổi
=========

Tồn tại nhiều phiên bản nhỏ hơn cho ISP này đã được giới thiệu vào năm
SoC sau này. Các bản sửa đổi có thể được tìm thấy trong enum ZZ0000ZZ
trong UAPI và bản sửa đổi của ISP bên trong SoC đang chạy có thể được đọc
trong trường hw_revision của struct media_device_info được trả về bởi
ioctl MEDIA_IOC_DEVICE_INFO.

Các phiên bản đang được sử dụng là:

- RKISP1_V10: được sử dụng ít nhất trong rk3288 và rk3399
- RKISP1_V11: khai báo theo mã nhà cung cấp ban đầu nhưng chưa được sử dụng
- RKISP1_V12: được sử dụng ít nhất trong rk3326 và px30
- RKISP1_V13: được sử dụng ít nhất trong rk1808

Cấu trúc liên kết
=================
.. _rkisp1_topology_graph:

.. kernel-figure:: rkisp1.dot
    :alt:   Diagram of the default media pipeline topology
    :align: center


Trình điều khiển có 4 thiết bị video:

- rkisp1_mainpath: thiết bị chụp để lấy hình ảnh, thường ở mức cao hơn
  độ phân giải.
- rkisp1_selfpath: thiết bị chụp để lấy hình ảnh.
- rkisp1_stats: một thiết bị thu thập siêu dữ liệu gửi số liệu thống kê.
- rkisp1_params: thiết bị đầu ra siêu dữ liệu nhận tham số
  cấu hình từ không gian người dùng.

Trình điều khiển có 3 thiết bị con:

- rkisp1_resizer_mainpath: được sử dụng để thay đổi kích thước và lấy mẫu các khung hình cho
  thiết bị chụp đường chính.
- rkisp1_resizer_selfpath: được sử dụng để thay đổi kích thước và lấy mẫu các khung hình cho
  thiết bị ghi lại đường dẫn tự thân.
- rkisp1_isp: được kết nối với cảm biến và chịu trách nhiệm về tất cả các isp
  hoạt động.


rkisp1_mainpath, rkisp1_selfpath - Nút ghi khung hình video
-------------------------------------------------------------
Đó là các thiết bị chụp ZZ0002ZZ và ZZ0003ZZ để chụp khung hình.
Những thực thể đó là các công cụ DMA ghi các khung vào bộ nhớ.
Thiết bị video selfpath có thể ghi lại các định dạng YUV/RGB. Đầu vào của nó được mã hóa YUV
phát trực tuyến và nó có thể chuyển đổi nó thành RGB. Đường tự thân không thể
nắm bắt các định dạng bayer.
Đường dẫn chính có thể chụp cả định dạng bayer và YUV nhưng không thể
chụp các định dạng RGB.
Cả hai đều hỗ trợ quay video
ZZ0001ZZ ZZ0000ZZ.


rkisp1_resizer_mainpath, rkisp1_resizer_selfpath - Bộ thay đổi kích thước Nút thiết bị phụ
------------------------------------------------------------------------------------------
Đó là các thực thể thay đổi kích thước cho đường dẫn chính và đường dẫn tự thân. Những thực thể đó
có thể chia tỷ lệ khung hình lên xuống và cũng có thể thay đổi mẫu YUV (ví dụ:
YUV4:2:2 -> YUV4:2:0). Họ cũng có khả năng cắt xén trên tấm đệm chìm.
Các thực thể thay đổi kích thước chỉ có thể hoạt động ở định dạng YUV:4:2:2
(MEDIA_BUS_FMT_YUYV8_2X8).
Thiết bị chụp đường dẫn chính hỗ trợ quay video ở định dạng bayer. Trong đó
trường hợp bộ thay đổi kích thước của đường dẫn chính được đặt ở chế độ 'bỏ qua' - nó chỉ chuyển tiếp
frame mà không cần thao tác trên nó.

rkisp1_isp - Nút phụ xử lý tín hiệu hình ảnh
---------------------------------------------------
Đây là thực thể isp. Nó được kết nối với cảm biến trên sink pad 0 và
nhận các khung bằng giao thức CSI-2. Nó chịu trách nhiệm cấu hình
giao thức CSI-2. Nó có khả năng cắt xén trên sink pad 0 tức là
được kết nối với cảm biến và trên bảng nguồn 2 được kết nối với các thực thể thay đổi kích thước.
Cắt xén trên sink pad 0 xác định vùng hình ảnh từ cảm biến.
Việc cắt xén trên bảng nguồn 2 sẽ xác định vùng cho Bộ ổn định hình ảnh (IS).

.. _rkisp1_stats:

rkisp1_stats - Nút video thống kê
------------------------------------
Nút video thống kê xuất ra 3A (lấy nét tự động, phơi sáng tự động và tự động
thống kê cân bằng trắng) cũng như thống kê biểu đồ cho các khung hình
đang được rkisp1 xử lý cho các ứng dụng không gian người dùng.
Sử dụng những dữ liệu này, các ứng dụng có thể triển khai các thuật toán và tái tham số hóa
trình điều khiển thông qua nút rkisp_params để cải thiện chất lượng hình ảnh trong quá trình
luồng video.
Định dạng bộ đệm được xác định bởi struct ZZ0000ZZ và
không gian người dùng nên đặt
ZZ0001ZZ là
dataformat.

.. _rkisp1_params:

rkisp1_params - Nút video tham số
-------------------------------------
Nút video rkisp1_params nhận một tập hợp các tham số từ không gian người dùng
được áp dụng cho phần cứng trong luồng video, cho phép không gian người dùng
để tự động sửa đổi các giá trị như mức độ màu đen, hiệu chỉnh giọng nói chéo
và những người khác.

Trình điều khiển ISP hỗ trợ hai phương thức cấu hình tham số khác nhau,
ZZ0000ZZ hoặc ZZ0001ZZ.

Khi sử dụng phương pháp ZZ0002ZZ, định dạng bộ đệm được xác định bởi struct
ZZ0000ZZ và không gian người dùng nên được đặt
ZZ0001ZZ là
dataformat.

Khi sử dụng phương pháp ZZ0002ZZ, định dạng bộ đệm được xác định bởi
struct ZZ0000ZZ và không gian người dùng sẽ được đặt
ZZ0001ZZ như
định dạng dữ liệu.

Ví dụ về chụp khung hình video
==============================

Trong ví dụ sau, cảm biến được kết nối với phần 0 của 'rkisp1_isp' là
imx219.

Các lệnh sau có thể được sử dụng để quay video từ video selfpath
nút có kích thước 900x800 định dạng phẳng YUV 4:2:2. Nó sử dụng tất cả cắt xén
khả năng có thể, (xem giải thích ngay bên dưới)

.. code-block:: bash

	# set the links
	"media-ctl" "-d" "platform:rkisp1" "-r"
	"media-ctl" "-d" "platform:rkisp1" "-l" "'imx219 4-0010':0 -> 'rkisp1_isp':0 [1]"
	"media-ctl" "-d" "platform:rkisp1" "-l" "'rkisp1_isp':2 -> 'rkisp1_resizer_selfpath':0 [1]"
	"media-ctl" "-d" "platform:rkisp1" "-l" "'rkisp1_isp':2 -> 'rkisp1_resizer_mainpath':0 [0]"

	# set format for imx219 4-0010:0
	"media-ctl" "-d" "platform:rkisp1" "--set-v4l2" '"imx219 4-0010":0 [fmt:SRGGB10_1X10/1640x1232]'

	# set format for rkisp1_isp pads:
	"media-ctl" "-d" "platform:rkisp1" "--set-v4l2" '"rkisp1_isp":0 [fmt:SRGGB10_1X10/1640x1232 crop: (0,0)/1600x1200]'
	"media-ctl" "-d" "platform:rkisp1" "--set-v4l2" '"rkisp1_isp":2 [fmt:YUYV8_2X8/1600x1200 crop: (0,0)/1500x1100]'

	# set format for rkisp1_resizer_selfpath pads:
	"media-ctl" "-d" "platform:rkisp1" "--set-v4l2" '"rkisp1_resizer_selfpath":0 [fmt:YUYV8_2X8/1500x1100 crop: (300,400)/1400x1000]'
	"media-ctl" "-d" "platform:rkisp1" "--set-v4l2" '"rkisp1_resizer_selfpath":1 [fmt:YUYV8_2X8/900x800]'

	# set format for rkisp1_selfpath:
	"v4l2-ctl" "-z" "platform:rkisp1" "-d" "rkisp1_selfpath" "-v" "width=900,height=800,"
	"v4l2-ctl" "-z" "platform:rkisp1" "-d" "rkisp1_selfpath" "-v" "pixelformat=422P"

	# start streaming:
	v4l2-ctl "-z" "platform:rkisp1" "-d" "rkisp1_selfpath" "--stream-mmap" "--stream-count" "10"


Trong ví dụ trên, cảm biến được cấu hình theo định dạng bayer:
ZZ0000ZZ. Phần đệm rkisp1_isp:0 phải được cấu hình thành
cùng định dạng và kích thước mbus như cảm biến, nếu không việc phát trực tuyến sẽ không thành công
với lỗi 'EPIPE'. Vì vậy nó cũng được cấu hình thành ZZ0001ZZ.
Ngoài ra, bảng rkisp1_isp:0 được định cấu hình để cắt xén ZZ0002ZZ.

Kích thước cắt xén được tự động truyền bá thành định dạng của
pad nguồn isp ZZ0000ZZ. Một thao tác cắt xén khác được định cấu hình trên
bảng nguồn isp: ZZ0001ZZ.

Bàn đệm chìm của bộ thay đổi kích thước ZZ0000ZZ phải được cấu hình để định dạng
ZZ0001ZZ để khớp với định dạng ở phía bên kia của
liên kết. Ngoài ra, ZZ0002ZZ cắt xén được cấu hình trên đó.

Bảng nguồn của bộ thay đổi kích thước, ZZ0000ZZ được cấu hình để
định dạng ZZ0001ZZ. Điều đó có nghĩa là trình thay đổi kích thước trước tiên sẽ cắt một cửa sổ
của ZZ0002ZZ từ khung nhận được rồi chia tỷ lệ cửa sổ này
theo kích thước ZZ0003ZZ.

Lưu ý rằng ví dụ trên không sử dụng vòng điều khiển stats-params.
Do đó, các khung chụp sẽ không trải qua thuật toán 3A và
có thể sẽ không có chất lượng tốt và thậm chí có thể trông sẫm màu và xanh lục.

Định cấu hình lượng tử hóa
==========================

Trình điều khiển hỗ trợ lượng tử hóa giới hạn và toàn phạm vi trên các định dạng YUV,
trong đó giới hạn là mặc định.
Để chuyển đổi giữa cái này hay cái kia, không gian người dùng nên sử dụng Không gian màu
Chuyển đổi API (CSC) cho các thiết bị con trên bảng nguồn 2 của
isp (ZZ0001ZZ). Lượng tử hóa được cấu hình trên bảng này là
lượng tử hóa các khung hình video được ghi trên đường dẫn chính và đường dẫn tự
các nút video.
Lưu ý rằng các thực thể thay đổi kích thước và chụp sẽ luôn báo cáo
ZZ0000ZZ ngay cả khi lượng tử hóa được cấu hình đầy đủ
phạm vi trên ZZ0002ZZ. Vì vậy, để có được lượng tử hóa được cấu hình,
ứng dụng sẽ lấy nó từ pad ZZ0003ZZ.
