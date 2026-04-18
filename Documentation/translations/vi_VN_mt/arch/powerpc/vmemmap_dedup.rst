.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/vmemmap_dedup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Thiết bị DAX
==========

Giao diện device-dax sử dụng kỹ thuật chống trùng lặp đuôi được giải thích trong
Tài liệu/mm/vmemmap_dedup.rst

Trên powerpc, tính năng chống trùng lặp vmemmap chỉ được sử dụng với bản dịch cơ số MMU. Ngoài ra
với kích thước trang 64K, chỉ không gian tên devdax có căn chỉnh 1G mới sử dụng vmemmap
sự trùng lặp.

Với ánh xạ cấp độ PMD 2M, chúng tôi yêu cầu 32 trang cấu trúc và một vmemmap 64K
trang có thể chứa 1024 trang cấu trúc (64K/sizeof(trang cấu trúc)). Do đó không có
Có thể loại bỏ sự trùng lặp vmemmap.

Với ánh xạ cấp 1G PUD, chúng tôi yêu cầu 16384 trang cấu trúc và một trang 64K
Trang vmemmap có thể chứa 1024 trang cấu trúc (64K/sizeof(trang cấu trúc)). Do đó chúng tôi
yêu cầu 16 trang 64K trong vmemmap để ánh xạ trang cấu trúc cho ánh xạ cấp 1G PUD.

Đây là cách mọi thứ trông như thế nào trên device-dax sau khi các phần được điền::
 +----------+ ---virt_to_page---> +----------+ ánh xạ tới +-----------+
 ZZ0000ZZ ZZ0001ZZ -------------> ZZ0002ZZ
 ZZ0003ZZ +-------------+ +----------+
 ZZ0004ZZ ZZ0005ZZ -------------> ZZ0006ZZ
 ZZ0007ZZ +-------------+ +----------+
 ZZ0008ZZ ZZ0009ZZ ----------------^ ^ ^ ^ ^ ^
 ZZ0010ZZ +-------------+ ZZ0011ZZ ZZ0012ZZ |
 ZZ0013ZZ ZZ0014ZZ -------------------+ ZZ0015ZZ ZZ0016ZZ
 ZZ0017ZZ +-------------+ ZZ0018ZZ ZZ0019ZZ
 ZZ0020ZZ ZZ0021ZZ ----------------------+ ZZ0022ZZ |
 ZZ0023ZZ +-------------+ ZZ0024ZZ |
 ZZ0025ZZ ZZ0026ZZ ----------------------+ ZZ0027ZZ
 ZZ0028ZZ +-------------+ ZZ0029ZZ
 ZZ0030ZZ ZZ0031ZZ ---------------+ |
 ZZ0032ZZ +-------------+ |
 ZZ0033ZZ ZZ0034ZZ -----------------+
 ZZ0035ZZ +-----------+
 ZZ0036ZZ
 ZZ0037ZZ
 ZZ0038ZZ
 +----------+


Với kích thước trang 4K, ánh xạ mức PMD 2M yêu cầu 512 trang cấu trúc và một trang duy nhất
Trang vmemmap 4K chứa 64 trang cấu trúc (4K/sizeof(trang cấu trúc)). Do đó chúng tôi
yêu cầu 8 trang 4K trong vmemmap để ánh xạ trang cấu trúc cho ánh xạ mức 2M chiều chiều.

Đây là cách mọi thứ trông như thế nào trên device-dax sau khi các phần được điền::

+----------+ ---virt_to_page---> +----------+ ánh xạ tới +-----------+
 ZZ0000ZZ ZZ0001ZZ -------------> ZZ0002ZZ
 ZZ0003ZZ +-------------+ +----------+
 ZZ0004ZZ ZZ0005ZZ -------------> ZZ0006ZZ
 ZZ0007ZZ +-------------+ +----------+
 ZZ0008ZZ ZZ0009ZZ ----------------^ ^ ^ ^ ^ ^
 ZZ0010ZZ +-------------+ ZZ0011ZZ ZZ0012ZZ |
 ZZ0013ZZ ZZ0014ZZ -------------------+ ZZ0015ZZ ZZ0016ZZ
 ZZ0017ZZ +-------------+ ZZ0018ZZ ZZ0019ZZ
 ZZ0020ZZ ZZ0021ZZ ----------------------+ ZZ0022ZZ |
 ZZ0023ZZ +-------------+ ZZ0024ZZ |
 ZZ0025ZZ ZZ0026ZZ ----------------------+ ZZ0027ZZ
 ZZ0028ZZ +-------------+ ZZ0029ZZ
 ZZ0030ZZ ZZ0031ZZ ---------------+ |
 ZZ0032ZZ +-------------+ |
 ZZ0033ZZ ZZ0034ZZ -----------------+
 ZZ0035ZZ +-----------+
 ZZ0036ZZ
 ZZ0037ZZ
 ZZ0038ZZ
 +----------+

Với ánh xạ cấp 1G PUD, chúng tôi yêu cầu 262144 trang cấu trúc và một trang 4K
Trang vmemmap có thể chứa 64 trang cấu trúc (4K/sizeof(trang cấu trúc)). Do đó chúng tôi
yêu cầu 4096 trang 4K trong vmemmap để ánh xạ các trang cấu trúc cho cấp độ 1G PUD
lập bản đồ.

Đây là cách mọi thứ trông như thế nào trên device-dax sau khi các phần được điền::

+----------+ ---virt_to_page---> +----------+ ánh xạ tới +-----------+
 ZZ0000ZZ ZZ0001ZZ -------------> ZZ0002ZZ
 ZZ0003ZZ +-------------+ +----------+
 ZZ0004ZZ ZZ0005ZZ -------------> ZZ0006ZZ
 ZZ0007ZZ +-------------+ +----------+
 ZZ0008ZZ ZZ0009ZZ ----------------^ ^ ^ ^ ^ ^
 ZZ0010ZZ +-------------+ ZZ0011ZZ ZZ0012ZZ |
 ZZ0013ZZ ZZ0014ZZ -------------------+ ZZ0015ZZ ZZ0016ZZ
 ZZ0017ZZ +-------------+ ZZ0018ZZ ZZ0019ZZ
 ZZ0020ZZ ZZ0021ZZ ----------------------+ ZZ0022ZZ |
 ZZ0023ZZ +-------------+ ZZ0024ZZ |
 ZZ0025ZZ ZZ0026ZZ ----------------------+ ZZ0027ZZ
 ZZ0028ZZ +-------------+ ZZ0029ZZ
 ZZ0030ZZ ZZ0031ZZ ---------------+ |
 ZZ0032ZZ +-------------+ |
 ZZ0033ZZ ZZ0034ZZ -----------------+
 ZZ0035ZZ +-----------+
 ZZ0036ZZ
 ZZ0037ZZ
 ZZ0038ZZ
 +----------+