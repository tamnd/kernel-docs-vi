.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/bpf/standardization/abi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. contents::
.. sectnum::

========================================================
BPF ABI Các quy ước và hướng dẫn được đề xuất v1.0
========================================================

Đây là phiên bản 1.0 của tài liệu thông tin có chứa các thông tin được đề xuất
các quy ước và hướng dẫn để tạo các chương trình nhị phân BPF di động.

Đăng ký và quy ước gọi
================================

BPF có 10 thanh ghi mục đích chung và một thanh ghi con trỏ khung chỉ đọc,
tất cả đều rộng 64 bit.

Quy ước gọi BPF được định nghĩa là:

* R0: trả về giá trị khi gọi hàm và thoát giá trị cho chương trình BPF
* R1 – R5: đối số cho lệnh gọi hàm
* R6 - R9: các thanh ghi đã lưu callee mà lệnh gọi hàm sẽ bảo toàn
* R10: con trỏ khung chỉ đọc để truy cập ngăn xếp

R0 - R5 là các thanh ghi cào và các chương trình BPF cần đổ/điền chúng nếu
cần thiết qua các cuộc gọi.

Chương trình BPF cần lưu giá trị trả về vào thanh ghi R0 trước khi thực hiện
ZZ0000ZZ.
