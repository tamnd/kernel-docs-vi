.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/vidioc-streamon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _VIDIOC_STREAMON:

****************************************
ioctl VIDIOC_STREAMON, VIDIOC_STREAMOFF
****************************************

Tên
====

VIDIOC_STREAMON - VIDIOC_STREAMOFF - Bắt đầu hoặc dừng truyền phát I/O

Tóm tắt
========

.. c:macro:: VIDIOC_STREAMON

ZZ0000ZZ

.. c:macro:: VIDIOC_STREAMOFF

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ
    Con trỏ tới một số nguyên.

Sự miêu tả
===========

ZZ0003ZZ và ZZ0004ZZ ioctl khởi động và dừng
quá trình chụp hoặc xuất trong quá trình phát trực tuyến
(ZZ0000ZZ, ZZ0001ZZ hoặc
ZZ0002ZZ) I/O.

Phần cứng chụp bị vô hiệu hóa và không có bộ đệm đầu vào nào được lấp đầy (nếu có
có bất kỳ bộ đệm trống nào trong hàng đợi đến) cho đến ZZ0000ZZ
đã được gọi. Phần cứng đầu ra bị vô hiệu hóa và không có tín hiệu video
được sản xuất cho đến khi ZZ0001ZZ được gọi.

Các thiết bị chuyển bộ nhớ sang bộ nhớ sẽ không khởi động cho đến khi ZZ0000ZZ có
được gọi cho cả loại luồng chụp và luồng đầu ra.

Nếu ZZ0000ZZ bị lỗi thì mọi bộ đệm đã được xếp hàng đợi sẽ vẫn còn
xếp hàng.

ZZ0001ZZ ioctl, ngoài việc hủy bỏ hoặc hoàn thiện bất kỳ DMA nào
đang tiến hành, mở khóa mọi bộ đệm con trỏ người dùng bị khóa trong bộ nhớ vật lý,
và nó loại bỏ tất cả các bộ đệm khỏi hàng đợi đến và đi. Đó
có nghĩa là tất cả các hình ảnh được chụp nhưng chưa được xếp hàng đợi sẽ bị mất, tương tự như vậy
tất cả các hình ảnh được xếp hàng đợi để xuất nhưng chưa được truyền đi. I/O trở về
trạng thái tương tự như sau khi gọi
ZZ0000ZZ và có thể được khởi động lại
tương ứng.

Nếu bộ đệm đã được xếp hàng đợi với ZZ0000ZZ và
ZZ0002ZZ được gọi mà chưa bao giờ được gọi
ZZ0003ZZ thì các bộ đệm được xếp hàng đó cũng sẽ bị xóa khỏi
hàng đợi đến và tất cả đều được trả về trạng thái như sau
gọi ZZ0001ZZ và có thể khởi động lại
tương ứng.

Cả hai ioctls đều lấy một con trỏ tới một số nguyên, bộ đệm hoặc luồng mong muốn
loại. Điều này giống như cấu trúc
ZZ0000ZZ ZZ0001ZZ.

Nếu ZZ0000ZZ được gọi khi quá trình truyền phát đang diễn ra,
hoặc nếu ZZ0001ZZ được gọi khi quá trình phát trực tuyến đã dừng,
sau đó 0 được trả về. Không có gì xảy ra trong trường hợp ZZ0002ZZ,
nhưng ZZ0003ZZ sẽ trả các bộ đệm được xếp hàng đợi về vị trí ban đầu của chúng
trạng thái như đã đề cập ở trên.

.. note::

   Applications can be preempted for unknown periods right before
   or after the ``VIDIOC_STREAMON`` or ``VIDIOC_STREAMOFF`` calls, there is
   no notion of starting or stopping "now". Buffer timestamps can be used
   to synchronize with other events.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Bộ đệm ZZ0000ZZ không được hỗ trợ hoặc không có bộ đệm nào được cài đặt
    chưa được phân bổ (ánh xạ bộ nhớ) hoặc được xếp vào hàng đợi (đầu ra).

EPIPE
    Người lái xe thực hiện
    ZZ0000ZZ và
    cấu hình đường ống không hợp lệ.

ENOLINK
    Trình điều khiển triển khai giao diện Media Controller và đường dẫn
    cấu hình liên kết không hợp lệ.