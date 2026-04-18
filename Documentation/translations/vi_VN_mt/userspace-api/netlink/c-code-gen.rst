.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/netlink/c-code-gen.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Tạo mã C thông số Netlink
==============================

Tài liệu này mô tả cách sử dụng các thông số kỹ thuật của Netlink để hiển thị
Mã C (uAPI, chính sách, v.v.). Nó cũng xác định các thuộc tính bổ sung
được phép trong các gia đình cũ hơn theo cấp độ giao thức ZZ0000ZZ,
để kiểm soát việc đặt tên.

Để cho ngắn gọn, tài liệu này đề cập đến các thuộc tính ZZ0000ZZ của nhiều loại
đối tượng theo loại đối tượng. Ví dụ ZZ0001ZZ là giá trị
của ZZ0002ZZ trong một thuộc tính và ZZ0003ZZ là tên của
họ (thuộc tính ZZ0004ZZ toàn cầu).

Chữ hoa được sử dụng để biểu thị các giá trị bằng chữ, ví dụ: ZZ0000ZZ
có nghĩa là sự kết hợp của ZZ0001ZZ, một ký tự gạch ngang và nghĩa đen
ZZ0002ZZ.

Tên của các giá trị ZZ0000ZZ và enum luôn được chuyển đổi thành chữ hoa,
và với dấu gạch ngang (ZZ0001ZZ) được thay thế bằng dấu gạch dưới (ZZ0002ZZ).

Nếu tên được xây dựng là từ khóa C, dấu gạch dưới bổ sung là
được nối thêm (ZZ0000ZZ -> ZZ0001ZZ).

Quả cầu
=======

ZZ0000ZZ kiểm soát tên ZZ0001ZZ cho gia đình
tên, mặc định là ZZ0002ZZ.

ZZ0000ZZ kiểm soát tên ZZ0001ZZ cho phiên bản
của họ, mặc định là ZZ0002ZZ.

ZZ0000ZZ chọn nếu giá trị tối đa cho enum được xác định là
ZZ0001ZZ chứ không phải bên trong enum.

định nghĩa
===========

Hằng số
---------

Mỗi hằng số được hiển thị dưới dạng ZZ0000ZZ.
Tên của hằng số là ZZ0001ZZ và giá trị
được hiển thị dưới dạng chuỗi hoặc số nguyên tùy theo loại của nó trong thông số kỹ thuật.

Enum và cờ
---------------

Enum được đặt tên là ZZ0000ZZ. Tên đầy đủ có thể được đặt trực tiếp
hoặc bị loại bỏ bằng cách chỉ định thuộc tính ZZ0001ZZ.
Tên mục nhập mặc định là ZZ0002ZZ.
Nếu ZZ0003ZZ được chỉ định, nó sẽ thay thế ZZ0004ZZ
một phần của tên mục.

Boolean ZZ0000ZZ kiểm soát việc tạo các giá trị tối đa
(được bật theo mặc định cho enum thuộc tính). Những tối đa này
các giá trị được đặt tên là ZZ0001ZZ và ZZ0002ZZ. Tên
giá trị đầu tiên có thể được ghi đè thông qua thuộc tính ZZ0003ZZ.

Thuộc tính
==========

Mỗi bộ thuộc tính (không bao gồm bộ phân số) được hiển thị dưới dạng enum.

Các enum thuộc tính theo truyền thống không được đặt tên trong các tiêu đề liên kết mạng.
Nếu muốn đặt tên, ZZ0000ZZ có thể được sử dụng để chỉ định tên.

Tiền tố tên thuộc tính mặc định là ZZ0000ZZ nếu tên của tập hợp
giống với tên của họ và ZZ0001ZZ nếu tên
khác nhau. Tiền tố có thể được ghi đè bằng thuộc tính ZZ0002ZZ của một tập hợp.
Phần còn lại của phần này sẽ đề cập đến tiền tố là ZZ0003ZZ.

Các thuộc tính được đặt tên là ZZ0000ZZ.

Các enum thuộc tính kết thúc bằng hai giá trị đặc biệt ZZ0000ZZ và ZZ0001ZZ
được sử dụng để định cỡ các bảng thuộc tính.
Hai tên này có thể được chỉ định trực tiếp bằng ZZ0002ZZ
và thuộc tính ZZ0003ZZ tương ứng.

Nếu ZZ0000ZZ được đặt thành ZZ0001ZZ ở cấp độ toàn cầu ZZ0002ZZ
sẽ được chỉ định là ZZ0003ZZ thay vì giá trị enum.

Hoạt động
==========

Hoạt động được đặt tên là ZZ0000ZZ.
Nếu ZZ0001ZZ được chỉ định, nó sẽ thay thế ZZ0002ZZ
phần tên.

Tương tự như hoạt động của enum thuộc tính, enum kết thúc bằng số đếm đặc biệt và giá trị tối đa
thuộc tính. Đối với các hoạt động, các thuộc tính đó có thể được đổi tên bằng
ZZ0000ZZ và ZZ0001ZZ. Max sẽ là một định nghĩa nếu ZZ0002ZZ
là ZZ0003ZZ.

Nhóm phát đa hướng
================

Mỗi nhóm phát đa hướng có một định nghĩa được hiển thị trong tiêu đề uAPI kernel.
Tên của định nghĩa là ZZ0000ZZ và có thể được ghi đè
với thuộc tính ZZ0001ZZ.

Tạo mã
===============

Tiêu đề uAPI được giả sử đến từ ZZ0000ZZ trong tiêu đề mặc định
đường dẫn tìm kiếm. Nó có thể được thay đổi bằng cách sử dụng thuộc tính toàn cục ZZ0001ZZ.