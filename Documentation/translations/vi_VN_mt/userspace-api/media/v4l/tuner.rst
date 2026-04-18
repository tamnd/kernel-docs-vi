.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/tuner.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _tuner:

**********************
Bộ điều chỉnh và bộ điều biến
*********************


Bộ chỉnh
======

Thiết bị đầu vào video có thể có một hoặc nhiều bộ điều chỉnh giải điều chế RF
tín hiệu. Mỗi bộ dò được liên kết với một hoặc nhiều đầu vào video,
tùy thuộc vào số lượng đầu nối RF trên bộ chỉnh tần. ZZ0002ZZ
trường của cấu trúc tương ứng ZZ0000ZZ
được trả về bởi ZZ0001ZZ ioctl là
được đặt thành ZZ0003ZZ và trường ZZ0004ZZ của nó chứa
số chỉ mục của bộ điều chỉnh.

Các thiết bị đầu vào vô tuyến có chính xác một bộ dò sóng có chỉ số 0, không có video
đầu vào.

Để truy vấn và thay đổi các ứng dụng thuộc tính bộ điều chỉnh, hãy sử dụng
ZZ0000ZZ và
ZZ0001ZZ ioctls tương ứng. các
struct ZZ0002ZZ returned by ZZ0003ZZ
cũng chứa thông tin trạng thái tín hiệu có thể áp dụng khi bộ điều chỉnh của
đầu vào video hoặc radio hiện tại được truy vấn.

.. note::

   :ref:`VIDIOC_S_TUNER <VIDIOC_G_TUNER>` does not switch the
   current tuner, when there is more than one. The tuner is solely
   determined by the current video input. Drivers must support both ioctls
   and set the ``V4L2_CAP_TUNER`` flag in the struct :c:type:`v4l2_capability`
   returned by the :ref:`VIDIOC_QUERYCAP` ioctl when the
   device has one or more tuners.


Bộ điều biến
==========

Thiết bị đầu ra video có thể có một hoặc nhiều bộ điều biến, điều chỉnh một
tín hiệu video cho bức xạ hoặc kết nối với đầu vào ăng-ten của TV
bộ hoặc máy ghi video. Mỗi bộ điều biến được liên kết với một hoặc nhiều
đầu ra video, tùy thuộc vào số lượng đầu nối RF trên
bộ điều biến. Trường ZZ0002ZZ của cấu trúc tương ứng
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl được đặt thành
ZZ0003ZZ và trường ZZ0004ZZ của nó chứa
số chỉ số của bộ điều biến.

Các thiết bị đầu ra vô tuyến có chính xác một bộ điều biến có chỉ số 0, không
đầu ra video.

Thiết bị video hoặc radio không thể hỗ trợ cả bộ dò sóng và bộ điều biến. Hai
các nút thiết bị riêng biệt sẽ phải được sử dụng cho phần cứng đó, một nút
hỗ trợ chức năng điều chỉnh và một chức năng hỗ trợ bộ điều biến
chức năng. Nguyên nhân là do hạn chế về
ZZ0000ZZ ioctl bạn ở đâu
không thể chỉ định tần số dành cho bộ chỉnh tần hay bộ điều biến.

Để truy vấn và thay đổi các ứng dụng thuộc tính bộ điều biến, hãy sử dụng
ZZ0000ZZ và
ZZ0001ZZ ioctl. Lưu ý rằng
ZZ0002ZZ không chuyển đổi bộ điều biến hiện tại khi có
là nhiều hơn một chút nào. Bộ điều biến chỉ được xác định bởi
đầu ra video hiện tại. Trình điều khiển phải hỗ trợ cả ioctls và đặt
Cờ ZZ0005ZZ trong cấu trúc
ZZ0003ZZ được trả lại bởi
ZZ0004ZZ ioctl khi máy có
một hoặc nhiều bộ điều biến.


Tần số vô tuyến
===============

Để nhận và thiết lập các ứng dụng tần số vô tuyến của bộ điều chỉnh hoặc bộ điều biến, hãy sử dụng
ZZ0000ZZ và
ZZ0001ZZ ioctl mà cả hai đều lấy
một con trỏ tới cấu trúc ZZ0002ZZ. Những cái này
ioctls được sử dụng cho các thiết bị TV và radio. Trình điều khiển phải hỗ trợ
cả ioctls khi ioctls bộ điều chỉnh hoặc bộ điều biến được hỗ trợ hoặc khi
thiết bị này là một thiết bị vô tuyến.