.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-event.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _event:

****************
Giao diện sự kiện
***************

Giao diện sự kiện V4L2 cung cấp phương tiện để người dùng nhận được ngay lập tức
được thông báo về một số điều kiện nhất định diễn ra trên thiết bị. Điều này có thể
bao gồm bắt đầu khung hoặc mất các sự kiện tín hiệu chẳng hạn. Những thay đổi trong
giá trị hoặc trạng thái của điều khiển V4L2 cũng có thể được báo cáo thông qua
sự kiện.

Để nhận được sự kiện, sự kiện mà người dùng quan tâm trước tiên phải là
đã đăng ký bằng cách sử dụng
ZZ0000ZZ ioctl. Một lần
một sự kiện được đăng ký, các sự kiện thuộc loại đã đăng ký có thể xếp hàng được
sử dụng ZZ0001ZZ ioctl. Sự kiện có thể
hủy đăng ký bằng VIDIOC_UNSUBSCRIBE_EVENT ioctl. Sự kiện đặc biệt
loại V4L2_EVENT_ALL có thể được sử dụng để hủy đăng ký tất cả các sự kiện
hỗ trợ lái xe.

Đăng ký sự kiện và hàng đợi sự kiện dành riêng cho việc xử lý tệp.
Đăng ký một sự kiện trên một tệp xử lý không ảnh hưởng đến tệp khác
tay cầm.

Thông tin về các sự kiện có thể xếp hàng được lấy bằng cách sử dụng select hoặc
cuộc gọi hệ thống thăm dò ý kiến trên các thiết bị video. Sự kiện V4L2 sử dụng sự kiện POLLPRI
về cuộc gọi hệ thống thăm dò ý kiến và ngoại lệ đối với cuộc gọi hệ thống chọn lọc.

Bắt đầu với kernel 3.1 có thể đưa ra một số đảm bảo nhất định liên quan đến
sự kiện:

1. Mỗi sự kiện đã đăng ký đều có hàng đợi sự kiện dành riêng cho nội bộ của nó.
   Điều này có nghĩa là lũ lụt của một loại sự kiện sẽ không ảnh hưởng đến
   các loại sự kiện khác.

2. Nếu hàng đợi sự kiện nội bộ cho một sự kiện được đăng ký cụ thể trở nên
   đầy thì sự kiện cũ nhất trong hàng đợi đó sẽ bị loại bỏ.

3. Nếu có thể, một số loại sự kiện nhất định có thể đảm bảo rằng trọng tải của
   sự kiện cũ nhất sắp bị loại bỏ sẽ được hợp nhất với sự kiện
   tải trọng của sự kiện cũ nhất tiếp theo. Do đó đảm bảo rằng không có thông tin
   bị mất đi mà chỉ là một bước trung gian dẫn đến bước đó
   thông tin. Xem tài liệu về sự kiện bạn muốn
   đăng ký xem điều này có áp dụng cho sự kiện đó hay không.