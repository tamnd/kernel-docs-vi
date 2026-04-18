.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tools/unittest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Python kém nhất
===============

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