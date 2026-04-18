.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/doc-guide/checktransupdate.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Kiểm tra các bản cập nhật dịch cần thiết
========================================

Tập lệnh này giúp theo dõi trạng thái dịch của tài liệu trong
các ngôn ngữ khác nhau, tức là liệu tài liệu có được cập nhật với
đối tác tiếng Anh.

Nó hoạt động như thế nào
------------------------

Nó sử dụng lệnh ZZ0000ZZ để theo dõi cam kết tiếng Anh mới nhất từ
Cam kết dịch thuật (thứ tự theo ngày tác giả) và cam kết tiếng Anh mới nhất
từ HEAD. Nếu có bất kỳ sự khác biệt nào xảy ra, tập tin được coi là lỗi thời,
thì những cam kết cần cập nhật sẽ được thu thập và báo cáo.

Các tính năng được triển khai

- kiểm tra tất cả các tập tin ở một địa điểm nhất định
- kiểm tra một tệp hoặc một tập hợp tệp
- cung cấp các tùy chọn để thay đổi định dạng đầu ra
- theo dõi trạng thái dịch của các file chưa có bản dịch

Cách sử dụng
------------

::

tools/docs/checktransupdate.py --help

Vui lòng tham khảo đầu ra của trình phân tích cú pháp đối số để biết chi tiết cách sử dụng.

Mẫu

-ZZ0000ZZ
   Thao tác này sẽ in tất cả các tệp cần được cập nhật bằng ngôn ngữ zh_CN.
-ZZ0001ZZ
   Điều này sẽ chỉ in trạng thái của tập tin được chỉ định.

Sau đó, đầu ra là một cái gì đó như:

::

Tài liệu/dev-tools/kfence.rst
    Không có bản dịch bằng ngôn ngữ của zh_CN

Tài liệu/bản dịch/zh_CN/dev-tools/testing-overview.rst
    cam kết 42fb9cfd5b18 ("Tài liệu: công cụ phát triển: Thêm liên kết đến tài liệu RV")
    Tổng cộng có 1 cam kết cần được giải quyết

Các tính năng cần triển khai

- tập tin có thể là một thư mục thay vì chỉ một tập tin