.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/cma_debugfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Giao diện gỡ lỗi CMA
=====================

Giao diện gỡ lỗi CMA rất hữu ích để truy xuất thông tin cơ bản từ
các khu vực CMA khác nhau và để kiểm tra việc phân bổ/phát hành ở từng khu vực.

Mỗi vùng CMA đại diện cho một thư mục trong <debugfs>/cma/, được biểu thị bằng
tên CMA của nó như dưới đây:

<debugfs>/cma/<cma_name>

Cấu trúc của các file được tạo trong thư mục đó như sau:

- [RO] base_pfn: PFN (Số khung trang) cơ sở của vùng CMA.
        Điều này giống như phạm vi/0/base_pfn.
 - Số lượng [RO]: Dung lượng bộ nhớ trong vùng CMA.
 - [RO] order_per_bit: Thứ tự các trang được biểu thị bằng 1 bit.
 - [RO] bitmap: Bitmap của các trang được phân bổ trong vùng.
        Điều này giống như phạm vi/0/base_pfn.
 - [RO] range/N/base_pfn: Cơ sở PFN của dãy N liền kề
        trong khu vực CMA.
 - [RO] range/N/bitmap: Bản đồ bit của các trang được phân bổ trong
        phạm vi N trong khu vực CMA.
 - [WO] alloc: Cấp phát N trang từ vùng CMA đó. Ví dụ::

echo 5 > <debugfs>/cma/<cma_name>/alloc

sẽ cố gắng phân bổ 5 trang từ vùng 'cma_name'.

- [WO] free: Miễn phí N trang từ vùng CMA đó, tương tự như trên.
