.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/imx-uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Trình điều khiển quay video i.MX
================================

Sự kiện
======

.. _imx_api_ipuX_csiY:

ipuX_csiY
---------

Subdev này có thể tạo sự kiện sau khi kích hoạt sự kiện thứ hai
Bảng nguồn IDMAC:

-V4L2_EVENT_IMX_FRAME_INTERVAL_ERROR

Ứng dụng người dùng có thể đăng ký sự kiện này từ ipuX_csiY
nút subdev. Sự kiện này được tạo bởi Trình giám sát khoảng thời gian khung
(xem bên dưới để biết thêm về FIM).

Điều khiển
========

.. _imx_api_FIM:

Giám sát khoảng thời gian khung trong ipuX_csiY
-----------------------------------

Bộ giải mã Adv718x đôi khi có thể gửi các trường bị hỏng trong quá trình
Đồng bộ lại tín hiệu NTSC/PAL (quá ít hoặc quá nhiều dòng video). Khi nào
điều này xảy ra, IPU sẽ kích hoạt cơ chế thiết lập lại dọc
đồng bộ hóa bằng cách thêm 1 dòng giả vào mỗi khung hình, điều này gây ra hiệu ứng cuộn
từ hình ảnh này sang hình ảnh khác và có thể tồn tại rất lâu trước khi hình ảnh ổn định
đã hồi phục. Hoặc đôi khi cơ chế đó không hoạt động chút nào, gây ra hiện tượng
hình ảnh được chia vĩnh viễn (một khung chứa các dòng từ hai đường liên tiếp
hình ảnh được chụp).

Từ thí nghiệm người ta thấy rằng trong quá trình cuộn ảnh, khung hình
khoảng thời gian (thời gian trôi qua giữa hai EOF) giảm xuống dưới mức danh nghĩa
giá trị cho tiêu chuẩn hiện tại, khoảng một thời gian khung hình (60 usec),
và duy trì ở giá trị đó cho đến khi dừng lăn.

Mặc dù lý do cho quan sát này vẫn chưa được biết (hình nộm IPU
cơ chế dòng sẽ hiển thị sự gia tăng các khoảng thời gian thêm 1 dòng
mỗi khung hình, không phải một giá trị cố định), chúng ta có thể sử dụng nó để phát hiện
các trường bị hỏng bằng cách sử dụng trình giám sát khoảng thời gian khung. Nếu FIM phát hiện một
khoảng thời gian khung hình xấu, subdev ipuX_csiY sẽ gửi sự kiện
V4L2_EVENT_IMX_FRAME_INTERVAL_ERROR. Userland có thể đăng ký với
thông báo sự kiện FIM trên nút thiết bị phụ ipuX_csiY.
Vùng người dùng có thể phát lệnh khởi động lại phát trực tuyến khi nhận được sự kiện này
để sửa hình ảnh cuộn/tách.

Subdev ipuX_csiY bao gồm các điều khiển tùy chỉnh để điều chỉnh một số mặt số cho
FIM. Nếu một trong những điều khiển này bị thay đổi trong quá trình phát trực tuyến, FIM sẽ
được đặt lại và sẽ tiếp tục ở cài đặt mới.

-V4L2_CID_IMX_FIM_ENABLE

Bật/tắt FIM.

-V4L2_CID_IMX_FIM_NUM

Có bao nhiêu phép đo khoảng thời gian khung hình được tính trung bình trước khi so sánh với
khoảng thời gian khung danh nghĩa được cảm biến báo cáo. Điều này có thể làm giảm tiếng ồn
do độ trễ ngắt gây ra.

-V4L2_CID_IMX_FIM_TOLERANCE_MIN

Nếu khoảng thời gian trung bình nằm ngoài danh nghĩa theo số tiền này, thì
micro giây, sự kiện V4L2_EVENT_IMX_FRAME_INTERVAL_ERROR sẽ được gửi.

-V4L2_CID_IMX_FIM_TOLERANCE_MAX

Nếu bất kỳ khoảng nào cao hơn giá trị này thì các mẫu đó sẽ
loại bỏ và không nhập vào mức trung bình. Điều này có thể được sử dụng để
loại bỏ các lỗi khoảng thời gian thực sự cao có thể do gián đoạn
độ trễ do tải hệ thống cao.

-V4L2_CID_IMX_FIM_NUM_SKIP

Cần bỏ qua bao nhiêu khung hình sau khi đặt lại FIM hoặc khởi động lại luồng trước đó
FIM bắt đầu đo khoảng thời gian trung bình.

-V4L2_CID_IMX_FIM_ICAP_CHANNEL / V4L2_CID_IMX_FIM_ICAP_EDGE

Các điều khiển này sẽ định cấu hình kênh thu thập đầu vào làm phương thức
để đo khoảng thời gian khung. Phương pháp này vượt trội hơn phương pháp mặc định
đo khoảng thời gian khung thông qua ngắt EOF, vì nó không phụ thuộc vào
đến các lỗi không chắc chắn do độ trễ gián đoạn gây ra.

Chụp đầu vào yêu cầu hỗ trợ phần cứng. Tín hiệu VSYNC phải được định tuyến
đến một trong các miếng đệm kênh ghi đầu vào i.MX6.

V4L2_CID_IMX_FIM_ICAP_CHANNEL định cấu hình chụp đầu vào i.MX6 nào
kênh để sử dụng. Đây phải là 0 hoặc 1.

V4L2_CID_IMX_FIM_ICAP_EDGE định cấu hình cạnh tín hiệu nào sẽ kích hoạt
sự kiện chụp đầu vào. Theo mặc định, phương thức thu thập dữ liệu đầu vào bị tắt
với giá trị IRQ_TYPE_NONE. Đặt điều khiển này thành IRQ_TYPE_EDGE_RISING,
IRQ_TYPE_EDGE_FALLING hoặc IRQ_TYPE_EDGE_BOTH để bật tính năng ghi đầu vào,
được kích hoạt trên (các) cạnh tín hiệu nhất định.

Khi tính năng chụp đầu vào bị tắt, khoảng thời gian khung hình sẽ được đo thông qua
Ngắt EOF.


Danh sách tập tin
---------

trình điều khiển/dàn dựng/media/imx/
bao gồm/media/imx.h
bao gồm/linux/imx-media.h


tác giả
-------

- Steve Longerbeam <steve_longerbeam@mentor.com>
- Philipp Zabel <kernel@pengutronix.de>
- Vua Russell <linux@armlinux.org.uk>

Bản quyền (C) 2012-2017 Mentor Graphics Inc.