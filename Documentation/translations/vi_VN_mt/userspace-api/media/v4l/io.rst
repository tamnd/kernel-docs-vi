.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _io:

############
Input/Đầu ra
############
V4L2 API xác định một số phương thức khác nhau để đọc hoặc ghi vào
một thiết bị. Tất cả các trình điều khiển trao đổi dữ liệu với các ứng dụng phải hỗ trợ tại
ít nhất một trong số họ.

Phương pháp I/O cổ điển sử dụng ZZ0000ZZ và
Chức năng ZZ0001ZZ được chọn tự động sau khi mở một
Thiết bị V4L2. Khi trình điều khiển không hỗ trợ phương pháp này, hãy thử
đọc hoặc viết sẽ thất bại bất cứ lúc nào.

Các phương pháp khác phải được đàm phán. Để chọn phương thức I/O truyền phát
với các ứng dụng được ánh xạ bộ nhớ hoặc bộ đệm người dùng, hãy gọi
ZZ0000ZZ ioctl.

Lớp phủ video có thể được coi là một phương pháp I/O khác, mặc dù
ứng dụng không trực tiếp nhận dữ liệu hình ảnh. Nó được chọn bởi
bắt đầu lớp phủ video với ZZ0000ZZ
ioctl. Để biết thêm thông tin, hãy xem ZZ0001ZZ.

Nói chung, chính xác một phương thức I/O, bao gồm cả lớp phủ, được liên kết với
mỗi bộ mô tả tập tin. Ngoại lệ duy nhất là các ứng dụng không
trao đổi dữ liệu với trình điều khiển ("ứng dụng bảng điều khiển", xem ZZ0000ZZ)
và trình điều khiển cho phép quay và phủ video đồng thời bằng cách sử dụng
cùng một bộ mô tả tệp, để tương thích với V4L trở về trước
phiên bản V4L2.

ZZ0000ZZ và ZZ0001ZZ sẽ cho phép điều này đối với một số người
mức độ, nhưng để đơn giản, trình điều khiển không cần hỗ trợ chuyển đổi I/O
phương thức (sau lần đầu tiên chuyển khỏi chế độ đọc/ghi) không phải bằng
đóng và mở lại thiết bị.

Các phần sau đây mô tả chi tiết hơn các phương pháp I/O khác nhau.

.. toctree::
    :maxdepth: 1

    rw
    mmap
    userp
    dmabuf
    buffer
    field-order