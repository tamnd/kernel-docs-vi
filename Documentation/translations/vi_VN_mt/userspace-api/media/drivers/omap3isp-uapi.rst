.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/omap3isp-uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển Bộ xử lý tín hiệu hình ảnh OMAP 3 (ISP)
==========================================

Bản quyền ZZ0000ZZ 2010 Nokia Corporation

Bản quyền ZZ0000ZZ 2009 Texas Instruments, Inc.

Người liên hệ: Laurent Pinchart <laurent.pinchart@ideasonboard.com>,
Sakari Ailus <sakari.ailus@iki.fi>, David Cohen <dacohen@gmail.com>


Sự kiện
------

Trình điều khiển OMAP 3 ISP hỗ trợ giao diện sự kiện V4L2 trên CCDC và
các phân nhóm thống kê (AEWB, AF và biểu đồ).

Subdev CCDC tạo ra sự kiện loại V4L2_EVENT_FRAME_SYNC trên HS_VS
ngắt được sử dụng để báo hiệu bắt đầu khung. Phiên bản trước của cái này
trình điều khiển đã sử dụng V4L2_EVENT_OMAP3ISP_HS_VS cho mục đích này. Sự kiện này là
được kích hoạt chính xác khi quá trình nhận dòng đầu tiên của khung bắt đầu
trong mô-đun CCDC. Sự kiện này có thể được đăng ký trên subdev CCDC.

(Khi sử dụng giao diện song song phải thanh toán tài khoản để sửa cấu hình
của cực tính tín hiệu VS. Điều này được tự động sửa khi sử dụng nối tiếp
máy thu.)

Mỗi nhà phát triển con thống kê đều có thể tạo ra các sự kiện. Một sự kiện là
được tạo bất cứ khi nào bộ đệm thống kê có thể được loại bỏ khỏi không gian người dùng
ứng dụng sử dụng VIDIOC_OMAP3ISP_STAT_REQ IOCTL. Các sự kiện có sẵn
là:

-V4L2_EVENT_OMAP3ISP_AEWB
-V4L2_EVENT_OMAP3ISP_AF
-V4L2_EVENT_OMAP3ISP_HIST

Loại dữ liệu sự kiện là struct omap3isp_stat_event_status cho những dữ liệu này
ioctls. Nếu có sai sót khi tính toán số liệu thống kê, sẽ có
sự kiện như thường lệ, nhưng không có bộ đệm thống kê liên quan. Trong trường hợp này
omap3isp_stat_event_status.buf_err được đặt thành khác không.


IOCTL riêng tư
--------------

Trình điều khiển OMAP 3 ISP hỗ trợ IOCTL V4L2 tiêu chuẩn và điều khiển ở những nơi
có thể và thực tế. Tuy nhiên, phần lớn các chức năng được cung cấp bởi ISP,
không thuộc IOCTL tiêu chuẩn --- bảng gamma và cấu hình của
việc thu thập số liệu thống kê là những ví dụ như vậy.

Nói chung, có một ioctl riêng để định cấu hình từng khối
chứa các chức năng phụ thuộc vào phần cứng.

Các IOCTL riêng sau đây được hỗ trợ:

-VIDIOC_OMAP3ISP_CCDC_CFG
-VIDIOC_OMAP3ISP_PRV_CFG
-VIDIOC_OMAP3ISP_AEWB_CFG
-VIDIOC_OMAP3ISP_HIST_CFG
-VIDIOC_OMAP3ISP_AF_CFG
-VIDIOC_OMAP3ISP_STAT_REQ
-VIDIOC_OMAP3ISP_STAT_EN

Cấu trúc tham số được sử dụng bởi các ioctls này được mô tả trong
bao gồm/linux/omap3isp.h. Các chức năng chi tiết của bản thân ISP liên quan đến
khối ISP nhất định được mô tả trong Hướng dẫn tham khảo kỹ thuật (TRM) ---
xem phần cuối của tài liệu cho những điều đó.

Mặc dù có thể sử dụng trình điều khiển ISP mà không cần sử dụng các quyền riêng tư này
IOCTL không thể đạt được chất lượng hình ảnh tối ưu theo cách này. AEWB,
Không thể sử dụng các mô-đun AF và biểu đồ nếu không định cấu hình chúng bằng cách sử dụng
IOCTL riêng phù hợp.


CCDC và khối xem trước IOCTL
-----------------------------

IOCTL VIDIOC_OMAP3ISP_CCDC_CFG và VIDIOC_OMAP3ISP_PRV_CFG được sử dụng để
định cấu hình, bật và tắt các chức năng trong khối CCDC và khối xem trước,
tương ứng. Cả hai IOCTL đều kiểm soát một số chức năng trong các khối mà chúng
kiểm soát. VIDIOC_OMAP3ISP_CCDC_CFG IOCTL chấp nhận một con trỏ tới cấu trúc
omap3isp_ccdc_update_config làm đối số của nó. Tương tự VIDIOC_OMAP3ISP_PRV_CFG
chấp nhận một con trỏ tới struct omap3isp_prev_update_config. Định nghĩa của
cả hai cấu trúc đều có sẵn trong [#]_.

Trường cập nhật trong cấu trúc cho biết có nên cập nhật cấu hình hay không
cho chức năng cụ thể và cờ cho biết nên bật hay tắt chức năng đó
chức năng.

Mặt nạ bit cập nhật và cờ chấp nhận các giá trị sau. Mỗi cái riêng biệt
các chức năng trong CCDC và các khối xem trước được liên kết với một cờ (hoặc
vô hiệu hóa hoặc kích hoạt; một phần của trường cờ trong cấu trúc) và một con trỏ tới
dữ liệu cấu hình cho chức năng.

Các giá trị hợp lệ cho trường cập nhật và trường cờ được liệt kê ở đây cho
VIDIOC_OMAP3ISP_CCDC_CFG. Các giá trị có thể được hoặc được định cấu hình nhiều hơn một
hoạt động trong cùng một cuộc gọi IOCTL.

-OMAP3ISP_CCDC_ALAW
-OMAP3ISP_CCDC_LPF
-OMAP3ISP_CCDC_BLCLAMP
-OMAP3ISP_CCDC_BCOMP
-OMAP3ISP_CCDC_FPC
-OMAP3ISP_CCDC_CULL
-OMAP3ISP_CCDC_CONFIG_LSC
-OMAP3ISP_CCDC_TBL_LSC

Các giá trị tương ứng cho VIDIOC_OMAP3ISP_PRV_CFG có ở đây:

-OMAP3ISP_PREV_LUMAENH
-OMAP3ISP_PREV_INVALAW
-OMAP3ISP_PREV_HRZ_MED
-OMAP3ISP_PREV_CFA
-OMAP3ISP_PREV_CHROMA_SUPP
-OMAP3ISP_PREV_WB
-OMAP3ISP_PREV_BLKADJ
-OMAP3ISP_PREV_RGB2RGB
-OMAP3ISP_PREV_COLOR_CONV
-OMAP3ISP_PREV_YC_LIMIT
-OMAP3ISP_PREV_DEFECT_COR
-OMAP3ISP_PREV_GAMMABYPASS
-OMAP3ISP_PREV_DRK_FRM_CAPTURE
-OMAP3ISP_PREV_DRK_FRM_SUBTRACT
-OMAP3ISP_PREV_LENS_SHADING
-OMAP3ISP_PREV_NF
-OMAP3ISP_PREV_GAMMA

Con trỏ cấu hình liên quan cho hàm có thể không phải là NULL khi
kích hoạt chức năng. Khi tắt một chức năng, con trỏ cấu hình sẽ
bị phớt lờ.


Khối thống kê IOCTL
-----------------------

Các nhà phát triển con thống kê cung cấp nhiều tùy chọn cấu hình động hơn so với
các subdev khác. Chúng có thể được kích hoạt, vô hiệu hóa và cấu hình lại khi đường ống
đang ở trạng thái phát trực tuyến.

Các khối thống kê luôn lấy dữ liệu hình ảnh đầu vào từ CCDC (dưới dạng
việc đọc bộ nhớ biểu đồ không được triển khai). Số liệu thống kê có thể xếp hàng được bằng cách
người dùng từ các nút subdev thống kê bằng cách sử dụng IOCTL riêng tư.

Các IOCTL riêng được cung cấp bởi các nhà phát triển phụ AEWB, AF và biểu đồ có rất nhiều
được phản ánh bởi giao diện cấp độ đăng ký được cung cấp bởi phần cứng ISP. Ở đó
là những khía cạnh hoàn toàn liên quan đến việc triển khai trình điều khiển và đây là những
thảo luận tiếp theo.

VIDIOC_OMAP3ISP_STAT_EN
-----------------------

IOCTL riêng tư này kích hoạt/vô hiệu hóa mô-đun thống kê. Nếu yêu cầu này được
được thực hiện trước khi phát trực tuyến, nó sẽ có hiệu lực ngay khi quy trình bắt đầu
suối.  Nếu đường dẫn đã phát trực tuyến, nó sẽ có hiệu lực ngay sau khi
CCDC không hoạt động.

VIDIOC_OMAP3ISP_AEWB_CFG, VIDIOC_OMAP3ISP_HIST_CFG và VIDIOC_OMAP3ISP_AF_CFG
-----------------------------------------------------------------------------

Những IOCTL đó được sử dụng để định cấu hình các mô-đun. Họ yêu cầu ứng dụng của người dùng
có kiến thức chuyên sâu về phần cứng. Hầu hết các trường giải thích
có thể được tìm thấy trên TRM của OMAP. Hai trường sau đây chung cho tất cả các trường trên
định cấu hình IOCTL riêng tư yêu cầu giải thích để hiểu rõ hơn vì chúng
không phải là một phần của TRM.

omap3isp_[h3a_af/h3a_aewb/hist]\_config.buf_size:

Các mô-đun xử lý bộ đệm của chúng trong nội bộ. Kích thước bộ đệm cần thiết cho
đầu ra dữ liệu của mô-đun phụ thuộc vào cấu hình được yêu cầu. Mặc dù
trình điều khiển hỗ trợ cấu hình lại trong khi phát trực tuyến, nó không hỗ trợ
cấu hình lại yêu cầu kích thước bộ đệm lớn hơn kích thước đã có
được phân bổ nội bộ nếu mô-đun được kích hoạt. Nó sẽ trả về -EBUSY về điều này
trường hợp. Để tránh tình trạng đó, hãy tắt/cấu hình lại/bật
mô-đun hoặc yêu cầu kích thước bộ đệm cần thiết trong lần cấu hình đầu tiên
trong khi mô-đun bị vô hiệu hóa.

Việc phân bổ kích thước bộ đệm bên trong xem xét cấu hình được yêu cầu
kích thước bộ đệm tối thiểu và giá trị được đặt trên trường buf_size. Nếu trường buf_size là
ngoài phạm vi kích thước bộ đệm [tối thiểu, tối đa], nó được kẹp để vừa với đó.
Trình điều khiển sau đó chọn giá trị lớn nhất. Giá trị buf_size đã sửa là
được viết lại cho ứng dụng của người dùng.

omap3isp_[h3a_af/h3a_aewb/hist]\_config.config_counter:

Vì cấu hình không có hiệu lực đồng bộ với yêu cầu nên
tài xế phải cung cấp cách theo dõi thông tin này để cung cấp chính xác hơn
dữ liệu. Sau khi yêu cầu cấu hình, config_counter sẽ được trả lại cho người dùng
ứng dụng không gian sẽ là một giá trị duy nhất được liên kết với yêu cầu đó. Khi nào
ứng dụng người dùng nhận được một sự kiện về tính khả dụng của bộ đệm hoặc khi có một bộ đệm mới
bộ đệm được yêu cầu, config_counter này được sử dụng để khớp với dữ liệu bộ đệm và
cấu hình.

VIDIOC_OMAP3ISP_STAT_REQ
------------------------

Gửi tới không gian người dùng dữ liệu cũ nhất có sẵn trong hàng đợi bộ đệm nội bộ và
loại bỏ bộ đệm như vậy sau đó. Trường omap3isp_stat_data.frame_number
khớp với field_count của bộ đệm video.


Tài liệu tham khảo
----------

.. [#] include/linux/omap3isp.h