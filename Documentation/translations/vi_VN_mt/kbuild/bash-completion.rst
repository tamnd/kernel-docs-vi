.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/bash-completion.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Hoàn thành Bash cho Kbuild
=============================

Hệ thống xây dựng kernel được viết bằng Makefiles và hoàn thành Bash
đối với lệnh ZZ0001ZZ có sẵn thông qua dự án ZZ0000ZZ.

Tuy nhiên, Makefiles để xây dựng kernel rất phức tạp. Sự hoàn thiện chung
các quy tắc cho lệnh ZZ0000ZZ không cung cấp các gợi ý có ý nghĩa cho
hệ thống xây dựng kernel, ngoại trừ các tùy chọn của chính lệnh ZZ0001ZZ.

Để tăng cường hoàn thiện các biến và mục tiêu khác nhau, nguồn kernel
bao gồm tập lệnh hoàn thành của riêng nó tại ZZ0000ZZ.

Tập lệnh này cung cấp các phần hoàn thiện bổ sung khi làm việc trong cây hạt nhân.
Bên ngoài cây hạt nhân, nó mặc định tuân theo các quy tắc hoàn thành chung cho
Lệnh ZZ0000ZZ.

Điều kiện tiên quyết
====================

Tập lệnh dựa trên các chức năng trợ giúp do dự án ZZ0000ZZ cung cấp.
Hãy đảm bảo nó được cài đặt trên hệ thống của bạn. Trên hầu hết các bản phân phối, bạn có thể
cài đặt gói ZZ0001ZZ thông qua trình quản lý gói tiêu chuẩn.

Cách sử dụng
============

Bạn có thể lấy nguồn tập lệnh trực tiếp ::

$ tập lệnh nguồn/bash-hoàn thành/make

Hoặc, bạn có thể sao chép nó vào đường dẫn tìm kiếm các tập lệnh hoàn thành Bash.
Ví dụ::

$ mkdir -p ~/.local/share/bash-completion/completions
  $ cp scripts/bash-completion/make ~/.local/share/bash-completion/completions/

Chi tiết
========

Việc hoàn thành bổ sung cho Kbuild được kích hoạt trong các trường hợp sau:

- Bạn đang ở thư mục gốc của nguồn kernel.
 - Bạn đang ở trong thư mục bản dựng cấp cao nhất được tạo bởi tùy chọn O=
   (được kiểm tra thông qua liên kết tượng trưng ZZ0000ZZ trỏ đến nguồn kernel).
 - Tùy chọn -C make chỉ định nguồn kernel hoặc thư mục build.
 - Tùy chọn -f make chỉ định một tệp trong thư mục nguồn kernel hoặc build.

Nếu không có điều nào ở trên được đáp ứng, nó sẽ quay trở lại các quy tắc hoàn thành chung.

Việc hoàn thành hỗ trợ:

- Các mục tiêu thường được sử dụng, chẳng hạn như ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, v.v.
  - Tạo các biến (hoặc môi trường), chẳng hạn như ZZ0003ZZ, ZZ0004ZZ, v.v.
  - Bản dựng mục tiêu đơn (ZZ0005ZZ)
  - Tệp cấu hình (ZZ0006ZZ và ZZ0007ZZ)

Một số biến đưa ra hành vi thông minh. Ví dụ: ZZ0000ZZ
tiếp theo là TAB hiển thị các chuỗi công cụ đã cài đặt. Danh sách file defconfig
được hiển thị phụ thuộc vào giá trị của biến ZZ0001ZZ.

.. _bash-completion: https://github.com/scop/bash-completion/