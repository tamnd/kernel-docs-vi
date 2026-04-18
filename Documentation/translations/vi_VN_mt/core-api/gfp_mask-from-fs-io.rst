.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/gfp_mask-from-fs-io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _gfp_mask_from_fs_io:

====================================
Mặt nạ GFP được sử dụng từ bối cảnh FS/IO
=================================

:Ngày: Tháng 5 năm 2018
:Tác giả: Michal Hocko <mhocko@kernel.org>

Giới thiệu
============

Đường dẫn mã trong hệ thống tập tin và ngăn xếp IO phải cẩn thận khi
cấp phát bộ nhớ để ngăn chặn các bế tắc đệ quy gây ra bởi các lỗi trực tiếp
lấy lại bộ nhớ gọi trở lại đường dẫn FS hoặc IO và chặn trên
các tài nguyên đã được giữ (ví dụ: các khóa - phổ biến nhất là những tài nguyên được sử dụng cho
bối cảnh giao dịch).

Cách truyền thống để tránh vấn đề bế tắc này là xóa __GFP_FS
tương ứng là __GFP_IO (lưu ý cái sau cũng ngụ ý xóa cái đầu tiên) trong
mặt nạ gfp khi gọi bộ cấp phát. GFP_NOFS tương ứng GFP_NOIO có thể
được sử dụng làm phím tắt. Hóa ra cách tiếp cận trên đã dẫn đến
lạm dụng khi sử dụng mặt nạ gfp bị hạn chế "để đề phòng" mà không có
xem xét sâu hơn dẫn đến các vấn đề vì sử dụng quá mức
của GFP_NOFS/GFP_NOIO có thể dẫn đến việc thu hồi quá mức bộ nhớ hoặc bộ nhớ khác
đòi lại các vấn đề.

API mới
========

Kể từ phiên bản 4.12, chúng tôi có phạm vi chung API cho cả bối cảnh NOFS và NOIO
ZZ0000ZZ, ZZ0001ZZ tương ứng ZZ0002ZZ,
ZZ0003ZZ cho phép đánh dấu phạm vi là quan trọng
phần từ hệ thống tập tin hoặc quan điểm I/O. Bất kỳ sự phân bổ nào từ đó
phạm vi vốn sẽ giảm __GFP_FS tương ứng __GFP_IO từ phạm vi đã cho
mặt nạ để không có sự phân bổ bộ nhớ nào có thể lặp lại trong FS/IO.

.. kernel-doc:: include/linux/sched/mm.h
   :functions: memalloc_nofs_save memalloc_nofs_restore
.. kernel-doc:: include/linux/sched/mm.h
   :functions: memalloc_noio_save memalloc_noio_restore

Mã FS/IO sau đó chỉ cần gọi hàm lưu thích hợp trước
bất kỳ phần quan trọng nào liên quan đến việc thu hồi đều được bắt đầu - ví dụ:
lock được chia sẻ với bối cảnh lấy lại hoặc khi bối cảnh giao dịch
việc làm tổ sẽ có thể thực hiện được thông qua việc thu hồi. Chức năng khôi phục phải là
được gọi khi phần quan trọng kết thúc. Tất cả những điều đó một cách lý tưởng cùng với một
giải thích bối cảnh thu hồi để bảo trì dễ dàng hơn là gì.

Xin lưu ý rằng việc ghép nối các chức năng lưu/khôi phục thích hợp
cho phép lồng nhau nên có thể gọi ZZ0000ZZ hoặc
ZZ0001ZZ tương ứng từ NOIO hoặc NOFS hiện có
phạm vi.

Còn __vmalloc(GFP_NOFS) thì sao
==============================

Kể từ v5.17 và đặc biệt là sau cam kết 451769ebb7e79 ("mm/vmalloc:
alloc GFP_NO{FS,IO} for vmalloc"), GFP_NOFS/GFP_NOIO hiện được hỗ trợ trong
ZZ0000ZZ bằng cách ngầm sử dụng phạm vi API.

Trong các hạt nhân trước đó ZZ0000ZZ không hỗ trợ ngữ nghĩa GFP_NOFS vì có
đã được phân bổ GFP_KERNEL được mã hóa cứng sâu bên trong bộ cấp phát. Điều đó có nghĩa
việc gọi ZZ0001ZZ bằng GFP_NOFS/GFP_NOIO hầu như luôn là một lỗi.

Trong thế giới lý tưởng, các tầng trên phải đánh dấu các bối cảnh nguy hiểm
và do đó không cần phải có sự chăm sóc đặc biệt nào và ZZ0000ZZ nên được gọi mà không cần bất kỳ sự chăm sóc đặc biệt nào.
vấn đề. Đôi khi nếu bối cảnh không thực sự rõ ràng hoặc có sự phân lớp
vi phạm thì cách được khuyến nghị để giải quyết vấn đề đó (trên các hạt nhân trước v5.17) là
bọc ZZ0001ZZ theo phạm vi API kèm theo nhận xét giải thích vấn đề.
