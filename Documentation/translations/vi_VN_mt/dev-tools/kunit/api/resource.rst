.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/api/resource.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Tài nguyên API
============

Tệp này ghi lại tài nguyên KUnit API.

Hầu hết người dùng sẽ không cần sử dụng trực tiếp API này, người dùng thành thạo có thể sử dụng nó để lưu trữ
nêu trên cơ sở mỗi lần kiểm tra, đăng ký các hành động dọn dẹp tùy chỉnh, v.v.

.. kernel-doc:: include/kunit/resource.h
   :internal:

Thiết bị được quản lý
---------------

Các chức năng sử dụng thiết bị cấu trúc do KUnit quản lý và struct device_driver.
Bao gồm ZZ0000ZZ để sử dụng chúng.

.. kernel-doc:: include/kunit/device.h
   :internal: