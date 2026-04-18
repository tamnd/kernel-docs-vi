.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/sriov.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
API NIC SR-IOV
=================

Các NIC hiện đại được khuyến khích tập trung vào việc triển khai ZZ0001ZZ
model (xem ZZ0000ZZ) để định cấu hình chuyển tiếp và bảo mật của SR-IOV
chức năng.

API kế thừa
==========

SR-IOV API cũ được triển khai trong dòng ZZ0000ZZ Netlink như một phần của
các lệnh ZZ0001ZZ và ZZ0002ZZ. Về phía người lái
nó bao gồm một số lệnh gọi lại ZZ0003ZZ và ZZ0004ZZ.

Vì các API cũ không tích hợp tốt với phần còn lại của ngăn xếp
API được coi là bị đóng băng; không có chức năng hoặc tiện ích mở rộng mới
sẽ được chấp nhận. Trình điều khiển mới không nên triển khai các lệnh gọi lại không phổ biến;
cụ thể là các cuộc gọi lại sau đây bị giới hạn:

-ZZ0000ZZ
 -ZZ0001ZZ
 -ZZ0002ZZ