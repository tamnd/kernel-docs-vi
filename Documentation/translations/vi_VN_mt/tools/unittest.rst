.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tools/unittest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Python kém nhất
=================

Kiểm tra tính nhất quán của các mô-đun python có thể phức tạp. Đôi khi, nó là
hữu ích để xác định một tập hợp các bài kiểm tra đơn vị nhằm giúp kiểm tra chúng.

Mặc dù việc triển khai thử nghiệm thực tế phụ thuộc vào từng trường hợp sử dụng nhưng Python đã
cung cấp một cách tiêu chuẩn để thêm các bài kiểm tra đơn vị bằng cách sử dụng ZZ0000ZZ.

Sử dụng lớp như vậy, yêu cầu thiết lập một bộ thử nghiệm. Ngoài ra, định dạng mặc định
có một chút khó chịu. Để cải thiện nó và cung cấp một cách thống nhất hơn để
báo cáo lỗi, một số lớp và hàm nhỏ nhất được xác định.


Mô-đun trợ giúp đơn giản nhất
======================

.. automodule:: lib.python.unittest_helper
   :members:
   :show-inheritance:
   :undoc-members: