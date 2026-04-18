.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/hugetlbpage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _hugetlbpage_index:

======================
Trang TLB lớn trên ARM64
====================

Hugepage dựa vào việc sử dụng TLB hiệu quả để cải thiện hiệu suất của
dịch địa chỉ. Lợi ích phụ thuộc vào cả hai -

- kích thước của trang lớn
  - kích thước của các mục được hỗ trợ bởi TLB

Cổng ARM64 hỗ trợ hai loại trang lớn.

1) Ánh xạ chặn ở cấp độ pud/pmd
--------------------------------------

Đây là những trang lớn thông thường trong đó mục nhập bảng trang pmd hoặc pud trỏ đến một
khối bộ nhớ. Bất kể kích thước mục được hỗ trợ trong TLB, hãy chặn
ánh xạ làm giảm độ sâu của bảng trang cần thiết để dịch trang lớn
địa chỉ.

2) Sử dụng bit liền kề
---------------------------

Kiến trúc cung cấp một bit liền kề trong các mục trong bảng dịch
(D4.5.3, ARM DDI 0487C.a) gợi ý cho MMU để chỉ ra rằng nó là một trong những
tập hợp các mục tiếp giáp có thể được lưu vào bộ nhớ đệm trong một mục nhập TLB.

Bit liền kề được sử dụng trong Linux để tăng kích thước ánh xạ tại pmd và
cấp độ pte (cuối cùng). Số lượng mục liền kề được hỗ trợ thay đổi tùy theo kích thước trang
và cấp độ của bảng trang.


Các kích thước trang lớn sau đây được hỗ trợ -

================== ======== ===
  - CONT PTE PMD CONT PMD PUD
  ================== ======== ===
  4K: 64K 2M 32M 1G
  16K: 2M 32M 1G
  64K: 2M 512M 16G
  ================== ======== ===
