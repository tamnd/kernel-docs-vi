.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Quản lý bộ nhớ
===================

Bố trí bộ nhớ ảo
=====================

.. note::

 - Some aspects of the virtual memory layout setup are not
   clarified (number of page levels, alignment, DMA memory).

 - Unused gaps in the virtual memory layout could be present
   or not - depending on how partucular system is configured.
   No page tables are created for the unused gaps.

 - The virtual memory regions are tracked or untracked by KASAN
   instrumentation, as well as the KASAN shadow memory itself is
   created only when CONFIG_KASAN configuration option is enabled.

::

====================================================================================
  ZZ0000ZZ Ảo | Mô tả vùng VM
  ====================================================================================
  +- 0 --------------+- 0 --------------+
  ZZ0001ZZ S390_lowcore | Bộ nhớ địa chỉ thấp
  |		     +- 8KB -----------+
  ZZ0002ZZ |
  ZZ0003ZZ |
  ZZ0004ZZ ... khoảng trống chưa sử dụng | KASAN không bị theo dõi
  ZZ0005ZZ |
  +- AMODE31_START --+- AMODE31_START --+ .amode31 rand. khởi đầu thể chất/tài đức
  Văn bản/dữ liệu ZZ0006ZZ.amode31| KASAN không bị theo dõi
  +- AMODE31_END ----+- AMODE31_END ----+ .amode31 rand. kết thúc vật lý/virt (<2GB)
  ZZ0007ZZ |
  ZZ0008ZZ |
  +- __kaslr_offset_phys | rand hạt nhân. bắt đầu thể chất
  ZZ0009ZZ |
  ZZ0010ZZ |
  ZZ0011ZZ |
  +-------------------+ | kết thúc vật lý hạt nhân
  ZZ0012ZZ |
  ZZ0013ZZ |
  ZZ0014ZZ |
  ZZ0015ZZ |
  +- ident_map_size -+ |
		     ZZ0016ZZ
		     ZZ0017ZZ KASAN chưa được theo dõi
		     ZZ0018ZZ
		     +- __identity_base + bắt đầu ánh xạ danh tính (>= 2GB)
		     ZZ0019ZZ
		     ZZ0020ZZ vật lý == đức hạnh - __identity_base
		     ZZ0021ZZ đức hạnh == vật lý + __identity_base
		     ZZ0022ZZ
		     ZZ0023ZZ KASAN đã theo dõi
		     ZZ0024ZZ
		     ZZ0025ZZ
		     ZZ0026ZZ
		     ZZ0027ZZ
		     ZZ0028ZZ
		     ZZ0029ZZ
		     ZZ0030ZZ
		     ZZ0031ZZ
		     ZZ0032ZZ
		     ZZ0033ZZ
		     ZZ0034ZZ
		     ZZ0035ZZ
		     ZZ0036ZZ
		     ZZ0037ZZ
		     ZZ0038ZZ
		     +---- vmemmap -----+ bắt đầu mảng 'struct page'
		     ZZ0039ZZ
		     ZZ0040ZZ
		     ZZ0041ZZ KASAN chưa được theo dõi
		     ZZ0042ZZ
		     +- __abs_lowcore ---+
		     ZZ0043ZZ
		     ZZ0044ZZ KASAN chưa được theo dõi
		     ZZ0045ZZ
		     +- __memcpy_real_area
		     ZZ0046ZZ
		     ZZ0047ZZ KASAN chưa được theo dõi
		     ZZ0048ZZ
		     +- VMALLOC_START --> bắt đầu khu vực vmalloc
		     ZZ0049ZZ KASAN không bị theo dõi hoặc
		     ZZ0050ZZ KASAN được bố trí nông trong trường hợp
		     ZZ0051ZZ CONFIG_KASAN_VMALLOC=y
		     +- MODULES_VADDR ---+ khu vực mô-đun bắt đầu
		     ZZ0052ZZ KASAN được phân bổ cho mỗi mô-đun hoặc
		     ZZ0053ZZ KASAN được bố trí nông trong trường hợp
		     ZZ0054ZZ CONFIG_KASAN_VMALLOC=y
		     +- __kaslr_offset -+ kernel rand. sự khởi đầu tốt đẹp
		     ZZ0055ZZ KASAN đã theo dõi
		     Vật lý ZZ0056ZZ == (kvirt - __kaslr_offset) +
		     ZZ0057ZZ __kaslr_offset_phys
		     +- kernel .bss end + kernel rand. đức hạnh cuối cùng
		     ZZ0058ZZ
		     ZZ0059ZZ KASAN chưa được theo dõi
		     ZZ0060ZZ
		     +-------------------+ Giới hạn lưu trữ an toàn UltraVisor
		     ZZ0061ZZ
		     ZZ0062ZZ KASAN chưa được theo dõi
		     ZZ0063ZZ
		     +KASAN_SHADOW_START+ KASAN khởi động bộ nhớ bóng
		     ZZ0064ZZ
		     ZZ0065ZZ KASAN chưa được theo dõi
		     ZZ0066ZZ
		     +-------------------+ Giới hạn ASCE
		     ZZ0067ZZ
		     | CONFIG_ILLEGAL_POINTER_VALUE gây ra lỗi truy cập bộ nhớ
		     ZZ0068ZZ
		     +-------------------+