.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/app-pri.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _app-pri:

********************
Ưu tiên ứng dụng
********************

Khi nhiều ứng dụng chia sẻ một thiết bị, có thể nên gán
những ưu tiên khác nhau của họ. Ngược lại với trường phái "rm -rf/" truyền thống
Ví dụ, một ứng dụng quay video có thể chặn các ứng dụng khác
các ứng dụng từ việc thay đổi điều khiển video hoặc chuyển đổi TV hiện tại
kênh. Một mục tiêu khác là cho phép các ứng dụng có mức độ ưu tiên thấp
hoạt động ở chế độ nền, có thể được ưu tiên bởi người dùng do người dùng kiểm soát
ứng dụng và tự động lấy lại quyền kiểm soát thiết bị sau đó
thời gian.

Vì các tính năng này không thể được triển khai hoàn toàn trong không gian người dùng V4L2
định nghĩa ZZ0000ZZ và
ZZ0001ZZ ioctls để yêu cầu và
truy vấn liên kết ưu tiên truy cập với bộ mô tả tệp. Mở một
thiết bị chỉ định mức độ ưu tiên trung bình, tương thích với các phiên bản trước của
V4L2 và các trình điều khiển không hỗ trợ các ioctls này. Các ứng dụng yêu cầu một
mức độ ưu tiên khác nhau thường sẽ gọi ZZ0002ZZ sau khi xác minh thiết bị bằng
ZZ0003ZZ ioctl.

Ioctls thay đổi thuộc tính trình điều khiển, chẳng hạn như
ZZ0000ZZ, trả về mã lỗi ZZ0001ZZ
sau khi ứng dụng khác có mức độ ưu tiên cao hơn.