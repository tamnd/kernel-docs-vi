.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/apparmor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
AppArmor
========

AppArmor là gì?
=================

AppArmor là phần mở rộng bảo mật kiểu MAC dành cho nhân Linux.  Nó thực hiện
chính sách tập trung vào nhiệm vụ, với "hồ sơ" nhiệm vụ được tạo và tải
từ không gian người dùng.  Các tác vụ trên hệ thống không có hồ sơ được xác định cho
chúng chạy ở trạng thái không giới hạn tương đương với Linux DAC tiêu chuẩn
quyền.

Cách bật/tắt
=====================

đặt ZZ0000ZZ

Nếu AppArmor nên được chọn làm mô-đun bảo mật mặc định thì hãy đặt::

CONFIG_DEFAULT_SECURITY_APPARMOR=y

Tham số CONFIG_LSM quản lý thứ tự và lựa chọn LSM.
Chỉ định apparmor làm mô-đun "chính" đầu tiên (ví dụ: AppArmor, SELinux, Smack)
trong danh sách.

Xây dựng hạt nhân

Nếu AppArmor không phải là mô-đun bảo mật mặc định thì nó có thể được kích hoạt bằng cách chuyển
ZZ0000ZZ trên dòng lệnh của kernel.

Nếu AppArmor là mô-đun bảo mật mặc định thì nó có thể bị vô hiệu hóa bằng cách chuyển
ZZ0000ZZ (trong đó ZZ0001ZZ là mô-đun bảo mật hợp lệ), trên
dòng lệnh của kernel.

Để AppArmor thực thi mọi hạn chế ngoài quyền DAC tiêu chuẩn của Linux
chính sách phải được tải vào kernel từ không gian người dùng (xem Tài liệu
và các liên kết công cụ).

Tài liệu
=============

Tài liệu có thể được tìm thấy trên wiki, được liên kết bên dưới.

Liên kết
=====

Danh sách gửi thư - apparmor@lists.ubuntu.com

Wiki - ZZ0000ZZ

Công cụ không gian người dùng - ZZ0000ZZ

Mô-đun hạt nhân - git://git.kernel.org/pub/scm/linux/kernel/git/jj/linux-apparmor
