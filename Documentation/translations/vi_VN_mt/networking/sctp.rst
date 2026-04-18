.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/sctp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Hạt nhân Linux SCTP
=================

Đây là bản phát hành BETA hiện tại của hạt nhân Linux SCTP tham khảo
thực hiện.

SCTP (Giao thức truyền điều khiển luồng) là giao thức dựa trên IP, định hướng tin nhắn,
giao thức truyền tải đáng tin cậy, với khả năng kiểm soát tắc nghẽn, hỗ trợ
multi-homing trong suốt và nhiều luồng tin nhắn được sắp xếp.
RFC2960 xác định giao thức cốt lõi.  Nhóm làm việc IETF SIGTRAN ban đầu
đã phát triển giao thức SCTP và sau đó chuyển giao giao thức này cho
Nhóm làm việc về Khu vực Giao thông vận tải (TSVWG) để tiếp tục phát triển SCTP với tư cách là một
vận tải mục đích chung.

Xem trang web IETF (ZZ0000ZZ để biết thêm tài liệu về SCTP.
Xem ZZ0001ZZ

Mục tiêu ban đầu của dự án là tạo ra một triển khai tham chiếu nhân Linux
của SCTP tương thích với RFC 2960 và cung cấp giao diện lập trình
được gọi là API kiểu UDP của Phần mở rộng ổ cắm cho SCTP, như
được đề xuất trong Bản nháp Internet IETF.

Hãy cẩn thận
=======

- lksctp có thể được xây dựng dưới dạng tĩnh hoặc dưới dạng mô-đun.  Tuy nhiên, hãy lưu ý rằng
  việc loại bỏ mô-đun lksctp vẫn chưa phải là một hoạt động an toàn.

- Có sự hỗ trợ dự kiến cho IPv6, nhưng hầu hết công việc đều hướng tới
  triển khai và thử nghiệm lksctp trên IPv4.


Để biết thêm thông tin, vui lòng truy cập trang web dự án lksctp:

ZZ0000ZZ

Hoặc liên hệ với nhà phát triển lksctp thông qua danh sách gửi thư:

<linux-sctp@vger.kernel.org>