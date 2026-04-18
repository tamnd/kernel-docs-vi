.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/namespaces/resource-control.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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
