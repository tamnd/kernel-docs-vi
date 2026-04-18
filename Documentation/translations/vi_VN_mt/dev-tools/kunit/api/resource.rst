.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/api/resource.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Tài nguyên API
==============

Tệp này ghi lại tài nguyên KUnit API.

Hầu hết người dùng sẽ không cần sử dụng trực tiếp API này, người dùng thành thạo có thể sử dụng nó để lưu trữ
nêu trên cơ sở mỗi lần kiểm tra, đăng ký các hành động dọn dẹp tùy chỉnh, v.v.

.. kernel-doc:: include/kunit/resource.h
   :internal:

Thiết bị được quản lý
---------------------

Các chức năng sử dụng thiết bị cấu trúc do KUnit quản lý và struct device_driver.
Bao gồm ZZ0000ZZ để sử dụng chúng.

.. kernel-doc:: include/kunit/device.h
   :internal: