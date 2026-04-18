.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/netlabel/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Giới thiệu NetLabel
=====================

Paul Moore, paul.moore@hp.com

Ngày 2 tháng 8 năm 2006

Tổng quan
========

NetLabel là một cơ chế có thể được sử dụng bởi các mô-đun bảo mật hạt nhân để đính kèm
thuộc tính bảo mật cho các gói mạng gửi đi được tạo từ không gian người dùng
ứng dụng và đọc các thuộc tính bảo mật từ các gói mạng đến.  Nó
bao gồm ba thành phần chính, các công cụ giao thức, giao tiếp
lớp và mô-đun bảo mật hạt nhân API.

Công cụ giao thức
================

Các công cụ giao thức chịu trách nhiệm cho cả việc áp dụng và truy xuất
thuộc tính bảo mật của gói mạng.  Nếu có sự dịch giữa mạng
thuộc tính bảo mật và những thuộc tính trên máy chủ được yêu cầu thì giao thức
động cơ cũng sẽ xử lý những nhiệm vụ đó.  Các hệ thống con kernel khác nên
không gọi trực tiếp các công cụ giao thức, thay vào đó họ nên sử dụng
mô-đun bảo mật hạt nhân NetLabel API được mô tả bên dưới.

Thông tin chi tiết về từng công cụ giao thức NetLabel có thể được tìm thấy trong phần này
thư mục.

Lớp giao tiếp
===================

Lớp giao tiếp tồn tại để cho phép cấu hình và giám sát NetLabel
từ không gian người dùng.  Lớp giao tiếp NetLabel sử dụng thông điệp dựa trên
giao thức được xây dựng dựa trên cơ chế vận chuyển NETLINK chung.  Chính xác
định dạng của các thông báo NetLabel này cũng như dòng Generic NETLINK
tên có thể được tìm thấy trong thư mục 'net/netlabel/' dưới dạng nhận xét trong
các tệp tiêu đề cũng như trong 'include/net/netlabel.h'.

Mô-đun bảo mật API
===================

Mục đích của mô-đun bảo mật NetLabel API là cung cấp giao thức
giao diện độc lập với các công cụ giao thức NetLabel cơ bản.  Ngoài ra
để độc lập về giao thức, mô-đun bảo mật API được thiết kế hoàn toàn
LSM độc lập sẽ cho phép nhiều LSM tận dụng cùng một mã
cơ sở.

Thông tin chi tiết về mô-đun bảo mật NetLabel API có thể được tìm thấy trong
tệp tiêu đề 'include/net/netlabel.h' cũng như tệp 'lsm_interface.txt'
được tìm thấy trong thư mục này.
