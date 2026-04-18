.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/faq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Câu hỏi thường gặp
=============================

DAMON chỉ hỗ trợ bộ nhớ ảo phải không?
=======================================

Không. Cốt lõi của DAMON là không gian địa chỉ độc lập.  Không gian địa chỉ
hoạt động giám sát cụ thể bao gồm các khu vực mục tiêu giám sát
công trình xây dựng và kiểm tra truy cập thực tế có thể được thực hiện và cấu hình trên
Lõi DAMON do người dùng thực hiện.  Bằng cách này, người dùng DAMON có thể theo dõi bất kỳ địa chỉ nào
không gian bằng bất kỳ kỹ thuật kiểm tra truy cập nào.

Tuy nhiên, DAMON cung cấp tính năng theo dõi vma/rmap và dựa trên kiểm tra bit được truy cập PTE.
triển khai các chức năng phụ thuộc không gian địa chỉ cho bộ nhớ ảo
và bộ nhớ vật lý theo mặc định để tham khảo và sử dụng thuận tiện.


Tôi có thể đơn giản theo dõi mức độ chi tiết của trang không?
=============================================================

Đúng.  Bạn có thể làm như vậy bằng cách đặt thuộc tính ZZ0000ZZ cao hơn thuộc tính
kích thước tập làm việc chia cho kích thước trang.  Vì mục tiêu giám sát
kích thước vùng buộc phải là ZZ0001ZZ, việc phân chia vùng sẽ không
hiệu ứng.