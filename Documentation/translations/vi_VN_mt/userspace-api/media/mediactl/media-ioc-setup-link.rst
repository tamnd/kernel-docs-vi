.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-ioc-setup-link.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: MC

.. _media_ioc_setup_link:

**************************
ioctl MEDIA_IOC_SETUP_LINK
**************************

Tên
====

MEDIA_IOC_SETUP_LINK - Sửa đổi thuộc tính của liên kết

Tóm tắt
========

.. c:macro:: MEDIA_IOC_SETUP_LINK

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0001ZZ
    Con trỏ tới cấu trúc ZZ0000ZZ.

Sự miêu tả
===========

Để thay đổi các thuộc tính liên kết, các ứng dụng hãy điền vào một cấu trúc
ZZ0000ZZ với nhận dạng liên kết
thông tin (nguồn và phần chìm) và các cờ liên kết được yêu cầu mới. Họ
sau đó gọi MEDIA_IOC_SETUP_LINK ioctl bằng một con trỏ tới đó
cấu trúc.

Thuộc tính có thể định cấu hình duy nhất là cờ liên kết ZZ0000ZZ tới
bật/tắt một liên kết. Các liên kết được đánh dấu bằng cờ liên kết ZZ0001ZZ có thể
không được kích hoạt hoặc vô hiệu hóa.

Cấu hình liên kết không có tác dụng phụ đối với các liên kết khác. Nếu một liên kết được kích hoạt
ở miếng đệm chìm ngăn liên kết được kích hoạt, trình điều khiển sẽ quay lại
với mã lỗi ZZ0000ZZ.

Chỉ các liên kết được đánh dấu bằng cờ liên kết ZZ0000ZZ mới có thể được bật/tắt
trong khi truyền dữ liệu đa phương tiện. Đang cố gắng bật hoặc tắt tính năng phát trực tuyến
liên kết không động sẽ trả về mã lỗi ZZ0001ZZ.

Nếu không tìm thấy liên kết đã chỉ định, trình điều khiển sẽ quay lại với ZZ0000ZZ
mã lỗi.

Giá trị trả về
============

Khi thành công, trả về 0, lỗi -1 và biến ZZ0001ZZ được đặt
một cách thích hợp. Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.

EINVAL
    Cấu trúc ZZ0000ZZ tham chiếu đến một
    liên kết không tồn tại hoặc liên kết không thể thay đổi và nỗ lực sửa đổi
    cấu hình của nó đã được thực hiện.