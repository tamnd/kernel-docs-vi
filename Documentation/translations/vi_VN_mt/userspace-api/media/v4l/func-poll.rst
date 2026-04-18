.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-poll.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _func-poll:

*******************
Cuộc thăm dò V4L2()
*******************

Tên
====

v4l2-poll - Đợi một số sự kiện trên bộ mô tả tệp

Tóm tắt
========

.. code-block:: c

    #include <sys/poll.h>

.. c:function:: int poll( struct pollfd *ufds, unsigned int nfds, int timeout )

Đối số
=========


Sự miêu tả
===========

Với chức năng ZZ0000ZZ, các ứng dụng có thể tạm dừng thực thi
cho đến khi trình điều khiển đã nắm bắt được dữ liệu hoặc sẵn sàng chấp nhận dữ liệu cho
đầu ra.

Khi luồng I/O đã được thương lượng, chức năng này sẽ đợi cho đến khi
bộ đệm đã được lấp đầy bởi thiết bị chụp và có thể được xếp hàng đợi bằng
ZZ0000ZZ ioctl. Đối với các thiết bị đầu ra, điều này
chức năng chờ cho đến khi thiết bị sẵn sàng chấp nhận bộ đệm mới
xếp hàng với ZZ0001ZZ ioctl để
hiển thị. Khi bộ đệm đã có trong hàng đợi gửi đi của trình điều khiển
(chụp) hoặc hàng đợi đến không đầy (hiển thị) chức năng
trở lại ngay lập tức.

Khi thành công ZZ0000ZZ trả về số lượng bộ mô tả tệp
đã được chọn (nghĩa là các bộ mô tả tệp mà
Trường ZZ0007ZZ của cấu trúc ZZ0008ZZ tương ứng
là khác không). Thiết bị chụp đặt ZZ0009ZZ và ZZ0010ZZ
cờ trong trường ZZ0011ZZ, thiết bị đầu ra ZZ0012ZZ và
Cờ ZZ0013ZZ. Khi hàm hết thời gian chờ, nó trả về giá trị là
0, nếu thất bại nó trả về -1 và biến ZZ0014ZZ được đặt
một cách thích hợp. Khi ứng dụng không gọi
ZZ0001ZZ và ZZ0002ZZ
chức năng thành công nhưng đặt cờ ZZ0015ZZ trong ZZ0016ZZ
lĩnh vực. Khi ứng dụng đã gọi
ZZ0003ZZ dành cho thiết bị chụp ảnh nhưng
vẫn chưa gọi ZZ0004ZZ,
Chức năng ZZ0005ZZ thành công và đặt cờ ZZ0017ZZ ở
trường ZZ0018ZZ. Đối với các thiết bị đầu ra, tình trạng tương tự này sẽ gây ra
ZZ0006ZZ cũng thành công nhưng nó đặt ra ZZ0019ZZ và
Cờ ZZ0020ZZ trong trường ZZ0021ZZ.

Nếu một sự kiện xảy ra (xem ZZ0000ZZ)
thì ZZ0002ZZ sẽ được đặt trong trường ZZ0003ZZ và
ZZ0001ZZ sẽ trở lại.

Khi việc sử dụng chức năng ZZ0000ZZ đã được thỏa thuận và
trình điều khiển chưa chụp, chức năng ZZ0001ZZ bắt đầu
chụp. Khi thất bại, nó trả về ZZ0002ZZ như trên. Nếu không
nó đợi cho đến khi dữ liệu được ghi lại và có thể đọc được. Khi người lái xe
chụp liên tục (ví dụ như trái ngược với hình ảnh tĩnh)
chức năng có thể trở lại ngay lập tức.

Khi việc sử dụng chức năng ZZ0000ZZ đã được thỏa thuận và
trình điều khiển chưa phát trực tuyến, chức năng ZZ0001ZZ bắt đầu
phát trực tuyến. Khi thất bại, nó trả về ZZ0003ZZ như trên. Nếu không
nó đợi cho đến khi trình điều khiển sẵn sàng cho việc không chặn
Cuộc gọi ZZ0002ZZ.

Nếu người gọi chỉ quan tâm đến các sự kiện (chỉ ZZ0001ZZ được đặt trong
trường ZZ0002ZZ), sau đó ZZ0000ZZ sẽ bắt đầu ZZ0003ZZ
phát trực tuyến nếu trình điều khiển chưa phát trực tuyến. Điều này làm cho nó có thể
chỉ thăm dò các sự kiện chứ không phải cho bộ đệm.

Tất cả các trình điều khiển triển khai ZZ0000ZZ hoặc ZZ0001ZZ
chức năng hoặc truyền phát I/O cũng phải hỗ trợ ZZ0002ZZ
chức năng.

Để biết thêm chi tiết, hãy xem trang hướng dẫn sử dụng ZZ0000ZZ.

Giá trị trả về
============

Khi thành công, ZZ0000ZZ trả về cấu trúc số có
các trường ZZ0001ZZ khác 0 hoặc 0 nếu cuộc gọi đã hết thời gian. Do lỗi -1
được trả về và biến ZZ0002ZZ được đặt thích hợp:

EBADF
    Một hoặc nhiều thành viên ZZ0000ZZ chỉ định tệp không hợp lệ
    mô tả.

EBUSY
    Trình điều khiển không hỗ trợ nhiều luồng đọc hoặc ghi và
    thiết bị đã được sử dụng.

EFAULT
    ZZ0000ZZ tham chiếu vùng bộ nhớ không thể truy cập.

EINTR
    Cuộc gọi bị gián đoạn bởi một tín hiệu.

EINVAL
    Giá trị ZZ0000ZZ vượt quá giá trị ZZ0001ZZ. sử dụng
    ZZ0002ZZ để có được giá trị này.