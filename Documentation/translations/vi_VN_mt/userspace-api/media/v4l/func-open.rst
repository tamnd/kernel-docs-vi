.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/func-open.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _func-open:

*************
V4L2 mở()
***********

Tên
====

v4l2-open - Mở thiết bị V4L2

Tóm tắt
========

.. code-block:: c

    #include <fcntl.h>

.. c:function:: int open( const char *device_name, int flags )

Đối số
=========

ZZ0000ZZ
    Thiết bị cần mở.

ZZ0000ZZ
    Mở cờ. Chế độ truy cập phải là ZZ0001ZZ. Đây chỉ là một
    Về mặt kỹ thuật, thiết bị đầu vào vẫn chỉ hỗ trợ đọc và xuất
    thiết bị chỉ ghi.

Khi cờ ZZ0002ZZ được đưa ra, ZZ0000ZZ
    chức năng và ZZ0001ZZ ioctl sẽ
    trả về mã lỗi ZZ0003ZZ khi không có dữ liệu hoặc không có
    bộ đệm nằm trong hàng đợi gửi đi của trình điều khiển, nếu không thì các chức năng này
    chặn cho đến khi có dữ liệu. Tất cả các trình điều khiển V4L2 trao đổi dữ liệu
    với các ứng dụng phải hỗ trợ cờ ZZ0004ZZ.

Các cờ khác không có hiệu lực.

Sự miêu tả
===========

Để mở ứng dụng thiết bị V4L2, hãy gọi ZZ0000ZZ bằng
tên thiết bị mong muốn. Chức năng này không có tác dụng phụ; tất cả các định dạng dữ liệu
tham số, đầu vào hoặc đầu ra hiện tại, giá trị điều khiển hoặc các thuộc tính khác
vẫn không thay đổi. Ở cuộc gọi ZZ0001ZZ đầu tiên sau khi tải
trình điều khiển, chúng sẽ được đặt lại về giá trị mặc định, trình điều khiển không bao giờ ở trạng thái
trạng thái không xác định.

Giá trị trả về
============

Khi thành công, ZZ0000ZZ trả về bộ mô tả tệp mới. Bị lỗi
-1 được trả về và biến ZZ0001ZZ được đặt thích hợp.
Các mã lỗi có thể xảy ra là:

EACCES
    Người gọi không có quyền truy cập vào thiết bị.

EBUSY
    Trình điều khiển không hỗ trợ mở nhiều lần và thiết bị đã sẵn sàng
    đang sử dụng.

ENODEV
    Không tìm thấy thiết bị hoặc đã bị xóa.

ENOMEM
    Không có đủ bộ nhớ kernel để hoàn thành yêu cầu.

EMFILE
    Quá trình này đã mở được số lượng tệp tối đa.

ENFILE
    Giới hạn về tổng số tập tin được mở trên hệ thống đã được
    đạt tới.