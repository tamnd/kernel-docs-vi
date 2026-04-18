.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-tpdm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================================
Màn hình chẩn đoán và giám sát hiệu suất theo dõi (TPDM)
===============================================================

:Tác giả: Jinlong Mao <quic_jinlmao@quicinc.com>
    :Ngày: Tháng 1 năm 2023

Mô tả phần cứng
--------------------
TPDM - Màn hình chẩn đoán và giám sát hiệu suất theo dõi hoặc TPDM trong
short đóng vai trò là thành phần thu thập dữ liệu cho các loại tập dữ liệu khác nhau.
Trường hợp sử dụng chính của TPDM là thu thập dữ liệu từ các dữ liệu khác nhau
nguồn và gửi nó đến TPDA để đóng gói, đánh dấu thời gian và phân kênh.

Các tập tin và thư mục Sysfs
----------------------------
Gốc: ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (RW)
:Ghi chú:
    -> 0 : kích hoạt bộ dữ liệu của TPDM.

- = 0 : vô hiệu hóa bộ dữ liệu của TPDM.

:Cú pháp:
    ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (wo)
:Ghi chú:
    Kiểm tra tích hợp sẽ tạo ra dữ liệu kiểm tra cho tpdm.

:Cú pháp:
    ZZ0000ZZ

giá trị - 1 hoặc 2.

----

.. This text is intentionally added to make Sphinx happy.