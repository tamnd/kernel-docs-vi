.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-request-ioc-queue.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: MC

.. _media_request_ioc_queue:

*****************************
ioctl MEDIA_REQUEST_IOC_QUEUE
*****************************

Tên
====

MEDIA_REQUEST_IOC_QUEUE - Xếp hàng yêu cầu

Tóm tắt
========

.. c:macro:: MEDIA_REQUEST_IOC_QUEUE

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

Sự miêu tả
===========

Nếu thiết bị đa phương tiện hỗ trợ ZZ0000ZZ thì
yêu cầu ioctl này có thể được sử dụng để xếp hàng yêu cầu được phân bổ trước đó.

Nếu yêu cầu được xếp hàng thành công thì bộ mô tả tệp có thể
ZZ0000ZZ để chờ yêu cầu hoàn thành.

Nếu yêu cầu đã được xếp hàng trước đó thì ZZ0000ZZ sẽ được trả về.
Các lỗi khác có thể được trả về nếu nội dung của yêu cầu chứa
dữ liệu không hợp lệ hoặc không nhất quán, hãy xem phần tiếp theo để biết danh sách
mã lỗi phổ biến. Khi có lỗi, cả trạng thái yêu cầu và trình điều khiển đều không thay đổi.

Sau khi yêu cầu được xếp hàng đợi, trình điều khiển phải xử lý một cách khéo léo
lỗi xảy ra khi yêu cầu được áp dụng cho phần cứng. các
ngoại lệ là lỗi ZZ0000ZZ báo hiệu một lỗi nghiêm trọng yêu cầu
ứng dụng dừng phát trực tuyến để thiết lập lại trạng thái phần cứng.

Không được phép trộn trực tiếp các yêu cầu xếp hàng với bộ đệm xếp hàng
(không có yêu cầu). ZZ0000ZZ sẽ được trả về nếu bộ đệm đầu tiên được
xếp hàng trực tiếp và tiếp theo bạn cố gắng xếp hàng yêu cầu hoặc ngược lại.

Một yêu cầu phải chứa ít nhất một bộ đệm, nếu không ioctl này sẽ
trả về lỗi ZZ0000ZZ.

Giá trị trả về
==============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EBUSY
    Yêu cầu đã được xếp hàng hoặc ứng dụng đã xếp hàng đầu tiên
    đệm trực tiếp, nhưng sau đó đã cố gắng sử dụng một yêu cầu. Nó không được phép
    để trộn hai API.
ENOENT
    Yêu cầu không chứa bất kỳ bộ đệm nào. Tất cả các yêu cầu đều được yêu cầu
    phải có ít nhất một bộ đệm. Điều này cũng có thể được trả lại nếu một số yêu cầu
    cấu hình bị thiếu trong yêu cầu.
ENOMEM
    Hết bộ nhớ khi phân bổ cấu trúc dữ liệu nội bộ cho việc này
    yêu cầu.
EINVAL
    Yêu cầu có dữ liệu không hợp lệ.
EIO
    Phần cứng đang ở trạng thái xấu. Để khôi phục, ứng dụng cần phải
    dừng phát trực tuyến để đặt lại trạng thái phần cứng rồi thử khởi động lại
    phát trực tuyến.