.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/namespaces/resource-control.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Không gian tên người dùng và kiểm soát tài nguyên
====================================

Hạt nhân chứa nhiều loại đối tượng không có
giới hạn riêng lẻ hoặc có giới hạn không hiệu quả khi
một tập hợp các quy trình được phép chuyển đổi UID của chúng. Trên một hệ thống
trong đó quản trị viên không tin tưởng người dùng hoặc chương trình của người dùng,
không gian tên người dùng khiến hệ thống có nguy cơ bị lạm dụng tài nguyên.

Để giảm thiểu điều này, chúng tôi khuyên quản trị viên nên kích hoạt bộ nhớ
nhóm kiểm soát trên bất kỳ hệ thống nào cho phép không gian tên người dùng.
Hơn nữa, chúng tôi khuyên quản trị viên nên định cấu hình kiểm soát bộ nhớ
nhóm để giới hạn bộ nhớ tối đa có thể sử dụng được bởi bất kỳ người dùng không đáng tin cậy nào.

Các nhóm kiểm soát bộ nhớ có thể được cấu hình bằng cách cài đặt libcgroup
gói có trên hầu hết các bản chỉnh sửa phân phối /etc/cgrules.conf,
/etc/cgconfig.conf và thiết lập libpam-cgroup.
