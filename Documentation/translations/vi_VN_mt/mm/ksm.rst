.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/ksm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Hợp nhất cùng một trang hạt nhân
=======================

KSM là tính năng khử trùng lặp tiết kiệm bộ nhớ, được kích hoạt bởi CONFIG_KSM=y,
được thêm vào nhân Linux trong 2.6.32.  Xem ZZ0000ZZ để biết cách triển khai,
và ZZ0001ZZ và ZZ0002ZZ

Giao diện không gian người dùng của KSM được mô tả trong Tài liệu/admin-guide/mm/ksm.rst

Thiết kế
======

Tổng quan
--------

.. kernel-doc:: mm/ksm.c
   :DOC: Overview

Ánh xạ ngược
---------------
KSM duy trì thông tin ánh xạ ngược cho các trang KSM ở trạng thái ổn định
cây.

Nếu một trang KSM được chia sẻ giữa ít hơn ZZ0000ZZ VMAs,
nút của cây ổn định đại diện cho trang KSM đó trỏ đến một
danh sách struct ksm_rmap_item và ZZ0001ZZ của
Trang KSM trỏ tới nút cây ổn định.

Khi việc chia sẻ vượt qua ngưỡng này, KSM sẽ thêm chiều thứ hai vào
cây ổn định. Nút cây trở thành một “chuỗi” liên kết một hoặc
nhiều "sự lừa đảo" hơn. Mỗi "bản sao" giữ thông tin ánh xạ ngược cho KSM
trang có ZZ0000ZZ trỏ đến "bản sao" đó.

Mọi "chuỗi" và tất cả các "bản sao" được liên kết thành một "chuỗi" đều thực thi
bất biến rằng chúng đại diện cho cùng một nội dung bộ nhớ được bảo vệ ghi,
ngay cả khi mỗi "bản sao" sẽ được chỉ ra bởi một bản sao trang KSM khác nhau của
nội dung đó.

Bằng cách này, độ phức tạp tính toán tra cứu cây ổn định không bị ảnh hưởng
nếu so sánh với danh sách ánh xạ ngược không giới hạn. Nó vẫn còn
buộc rằng không thể có nội dung trang KSM trùng lặp trong
bản thân cây ổn định.

Cần có giới hạn chống trùng lặp được thực thi bởi ZZ0000ZZ
để tránh danh sách rmap bộ nhớ ảo phát triển quá lớn. Bản đồ
walk có độ phức tạp O(N) trong đó N là số lượng rmap_items
(tức là ánh xạ ảo) đang chia sẻ trang, đến lượt nó
được giới hạn bởi ZZ0001ZZ. Vì vậy, điều này có hiệu quả lây lan tuyến tính
Độ phức tạp tính toán O(N) từ bối cảnh đi bộ rmap trên các bối cảnh khác nhau
Các trang KSM. Bước đi ksmd trên các "chuỗi" stable_node cũng là O(N),
nhưng N là số lượng "bản sao" của stable_node, không phải số lượng
rmap_items, do đó nó không ảnh hưởng đáng kể đến hiệu suất ksmd. trong
thực hành ứng cử viên "dup" stable_node tốt nhất sẽ được lưu giữ và tìm thấy
ở đầu danh sách "dups".

Giá trị cao của ZZ0000ZZ dẫn đến việc hợp nhất bộ nhớ nhanh hơn
(vì sẽ có ít bản sao stable_node hơn được xếp hàng vào
stable_node chain->hlist để kiểm tra việc cắt tỉa) và cao hơn
hệ số chống trùng lặp gây ra trường hợp xấu nhất chậm hơn cho rmap
đi cho bất kỳ trang KSM nào có thể xảy ra trong quá trình hoán đổi, nén,
Cân bằng và di chuyển trang NUMA.

Tỷ lệ ZZ0000ZZ cũng bị ảnh hưởng bởi
ZZ0001ZZ có thể điều chỉnh được và tỷ lệ cao có thể cho thấy sự phân mảnh
trong các bản sao stable_node, có thể được giải quyết bằng cách giới thiệu
thuật toán phân mảnh trong ksmd sẽ lọc lại rmap_items từ
một bản sao stable_node sang một bản sao stable_node khác, để giải phóng
stable_node "dups" có ít rmap_items trong đó, nhưng con số đó có thể tăng lên
việc sử dụng ksmd CPU và có thể làm chậm quá trình tính toán chỉ đọc trên
các trang KSM của ứng dụng.

Toàn bộ danh sách "bản sao" của stable_node được liên kết trong stable_node
"Chuỗi" được quét định kỳ để loại bỏ các stable_nodes cũ.
Tần suất quét như vậy được xác định bởi
ZZ0000ZZ sysfs có thể điều chỉnh được.

Thẩm quyền giải quyết
---------
.. kernel-doc:: mm/ksm.c
   :functions: mm_slot ksm_scan stable_node rmap_item

--
Izik Eidus,
Hugh Dickins, ngày 17 tháng 11 năm 2009
