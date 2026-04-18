.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/devpts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Hệ thống tập tin Devpts
=====================

Mỗi mount của hệ thống tập tin devpts bây giờ đã khác biệt sao cho ptys
và các chỉ số của chúng được phân bổ trong một mount độc lập với ptys
và chỉ số của chúng trong tất cả các thú cưỡi khác.

Tất cả các mount của hệ thống tập tin devpts hiện tạo nút ZZ0000ZZ
với quyền ZZ0001ZZ.

Để duy trì khả năng tương thích ngược, nút thiết bị ptmx (còn gọi là bất kỳ nút nào
được tạo bằng ZZ0000ZZ) khi mở sẽ tìm một phiên bản
của các nhà phát triển có tên ZZ0001ZZ trong cùng thư mục với thiết bị ptmx
nút.

Là một tùy chọn thay vì đặt nút thiết bị ZZ0000ZZ tại ZZ0001ZZ
có thể đặt một liên kết tượng trưng tới ZZ0002ZZ tại ZZ0003ZZ hoặc
để liên kết gắn kết ZZ0004ZZ với ZZ0005ZZ.  Nếu bạn chọn sử dụng
hệ thống tập tin devpts theo cách này, devpts nên được gắn kết với
nên gọi ZZ0006ZZ hoặc ZZ0007ZZ.

Tổng số cặp pty trong tất cả các trường hợp bị giới hạn bởi sysctls::

kernel.pty.max = 4096 - giới hạn toàn cầu
    kernel.pty.reserve = 1024 - dành riêng cho các hệ thống tập tin được gắn từ không gian tên gắn kết ban đầu
    kernel.pty.nr - số lượng ptys hiện tại

Có thể đặt giới hạn cho mỗi phiên bản bằng cách thêm tùy chọn gắn kết ZZ0000ZZ.

Tính năng này đã được thêm vào kernel 3.4 cùng với
ZZ0000ZZ.

Trong các hạt nhân cũ hơn 3,4 sysctl ZZ0000ZZ hoạt động theo giới hạn cho mỗi phiên bản.