.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/vm-layout.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Bố cục bộ nhớ ảo trên RISC-V Linux
========================================

:Tác giả: Alexandre Ghiti <alex@ghiti.fr>
:Ngày: 12 tháng 2 năm 2021

Tài liệu này mô tả bố cục bộ nhớ ảo được RISC-V Linux sử dụng
Hạt nhân.

Hạt nhân Linux RISC-V 32bit
=========================

Hạt nhân Linux RISC-V SV32
------------------------

TODO

Hạt nhân Linux RISC-V 64bit
=========================

Tài liệu kiến trúc đặc quyền RISC-V nêu rõ rằng địa chỉ 64bit
"phải có các bit 63–48 đều bằng bit 47, nếu không, ngoại lệ lỗi trang sẽ
xảy ra.": chia không gian địa chỉ ảo thành 2 nửa cách nhau bởi một dấu rất
lỗ lớn, nửa dưới là nơi chứa không gian người dùng, nửa trên là nơi
Hạt nhân Linux RISC-V nằm trong đó.

Hạt nhân Linux RISC-V SV39
------------------------

::

================================================================= =================================================================
      Địa chỉ bắt đầu ZZ0000ZZ Địa chỉ cuối ZZ0001ZZ Mô tả khu vực VM
  ================================================================= =================================================================
                    ZZ0002ZZ ZZ0003ZZ
   0000000000000000 ZZ0004ZZ 0000003fffffffff ZZ0005ZZ bộ nhớ ảo trong không gian người dùng, khác nhau trên mỗi mm
  __________________ZZ0006ZZ__________________ZZ0007ZZ___________________________________________________________
                    ZZ0008ZZ ZZ0009ZZ
   0000004000000000 ZZ0010ZZ ffffffbffffffffff ZZ0011ZZ ... lỗ lớn, rộng gần 64 bit của không chuẩn
                    ZZ0012ZZ ZZ0013ZZ có địa chỉ bộ nhớ ảo lên tới -256 GB
                    ZZ0014ZZ ZZ0015ZZ bắt đầu bù đắp ánh xạ hạt nhân.
  __________________ZZ0016ZZ__________________ZZ0017ZZ___________________________________________________________
                                                              |
                                                              | Bộ nhớ ảo không gian hạt nhân, được chia sẻ giữa tất cả các tiến trình:
  ____________________________________________________________|___________________________________________________________
                    ZZ0018ZZ ZZ0019ZZ
   ffffffc4fea00000 ZZ0020ZZ ffffffc4feffffff ZZ0021ZZ bản sửa lỗi
   ffffffc4ff000000 ZZ0022ZZ ffffffc4ffffffff ZZ0023ZZ PCI io
   ffffffc500000000 ZZ0024ZZ ffffffc5ffffffff ZZ0025ZZ vmemmap
   ffffffc600000000 ZZ0026ZZ ffffffd5ffffffff ZZ0027ZZ vmalloc/ioremap không gian
   ffffffd600000000 ZZ0028ZZ fffffff5ffffffff ZZ0029ZZ ánh xạ trực tiếp tất cả bộ nhớ vật lý
                    ZZ0030ZZ ZZ0031ZZ
   fffffff700000000 ZZ0032ZZ fffffffffffffff ZZ0033ZZ kasan
  __________________ZZ0034ZZ__________________ZZ0035ZZ____________________________________________________________
                                                              |
                                                              |
  ____________________________________________________________|____________________________________________________________
                    ZZ0036ZZ ZZ0037ZZ
   ffffffff00000000 ZZ0038ZZ ffffffff7fffffff mô-đun ZZ0039ZZ, BPF
   ffffffff80000000 ZZ0040ZZ ffffffffffffffff ZZ0041ZZ hạt nhân
  __________________ZZ0042ZZ__________________ZZ0043ZZ____________________________________________________________


Hạt nhân Linux RISC-V SV48
------------------------

::

================================================================= =================================================================
      Địa chỉ bắt đầu ZZ0000ZZ Địa chỉ cuối ZZ0001ZZ Mô tả khu vực VM
 ================================================================= =================================================================
                    ZZ0002ZZ ZZ0003ZZ
   0000000000000000 ZZ0004ZZ 00007fffffffffff ZZ0005ZZ bộ nhớ ảo trong không gian người dùng, khác nhau trên mỗi mm
  __________________ZZ0006ZZ__________________ZZ0007ZZ___________________________________________________________
                    ZZ0008ZZ ZZ0009ZZ
   0000800000000000 ZZ0010ZZ ffff7fffffffffff ZZ0011ZZ ... lỗ lớn, rộng gần 64 bit của không chuẩn
                    ZZ0012ZZ ZZ0013ZZ có địa chỉ bộ nhớ ảo lên tới -128 TB
                    ZZ0014ZZ ZZ0015ZZ bắt đầu bù đắp ánh xạ hạt nhân.
  __________________ZZ0016ZZ__________________ZZ0017ZZ___________________________________________________________
                                                              |
                                                              | Bộ nhớ ảo không gian hạt nhân, được chia sẻ giữa tất cả các tiến trình:
  ____________________________________________________________|___________________________________________________________
                    ZZ0018ZZ ZZ0019ZZ
   ffff8d7ffea00000 ZZ0020ZZ ffff8d7ffeffffff ZZ0021ZZ bản sửa lỗi
   ffff8d7fff000000 ZZ0022ZZ ffff8d7fffffffff ZZ0023ZZ PCI io
   ffff8d8000000000 ZZ0024ZZ ffff8f7fffffffff ZZ0025ZZ vmemmap
   ffff8f8000000000 ZZ0026ZZ ffffaf7fffffffff ZZ0027ZZ không gian vmalloc/ioremap
   ffffaf8000000000 ZZ0028ZZ fffef7fffffffff ZZ0029ZZ ánh xạ trực tiếp tất cả bộ nhớ vật lý
   fffef8000000000 ZZ0030ZZ fffffffffffffff ZZ0031ZZ kasan
  __________________ZZ0032ZZ__________________ZZ0033ZZ____________________________________________________________
                                                              |
                                                              | Bố cục giống hệt với bố cục 39 bit kể từ đây trở đi:
  ____________________________________________________________|____________________________________________________________
                    ZZ0034ZZ ZZ0035ZZ
   ffffffff00000000 ZZ0036ZZ ffffffff7fffffff mô-đun ZZ0037ZZ, BPF
   ffffffff80000000 ZZ0038ZZ ffffffffffffffff ZZ0039ZZ hạt nhân
  __________________ZZ0040ZZ__________________ZZ0041ZZ____________________________________________________________


Hạt nhân Linux RISC-V SV57
------------------------

::

================================================================= =================================================================
      Địa chỉ bắt đầu ZZ0000ZZ Địa chỉ cuối ZZ0001ZZ Mô tả khu vực VM
 ================================================================= =================================================================
                    ZZ0002ZZ ZZ0003ZZ
   0000000000000000 ZZ0004ZZ 00ffffffffffffff ZZ0005ZZ bộ nhớ ảo trong không gian người dùng, khác nhau trên mỗi mm
  __________________ZZ0006ZZ__________________ZZ0007ZZ___________________________________________________________
                    ZZ0008ZZ ZZ0009ZZ
   0100000000000000 ZZ0010ZZ feffffffffffffff ZZ0011ZZ ... lỗ lớn, rộng gần 64 bit của không chuẩn
                    ZZ0012ZZ ZZ0013ZZ bộ nhớ ảo có địa chỉ lên tới -64 PB
                    ZZ0014ZZ ZZ0015ZZ bắt đầu bù đắp ánh xạ hạt nhân.
  __________________ZZ0016ZZ__________________ZZ0017ZZ___________________________________________________________
                                                              |
                                                              | Bộ nhớ ảo không gian hạt nhân, được chia sẻ giữa tất cả các tiến trình:
  ____________________________________________________________|___________________________________________________________
                    ZZ0018ZZ ZZ0019ZZ
   ff1bffffffea00000 ZZ0020ZZ ff1bffffffffffff Bản đồ sửa lỗi ZZ0021ZZ
   ff1bffffff000000 ZZ0022ZZ ff1bffffffffffff ZZ0023ZZ PCI io
   ff1c000000000000 ZZ0024ZZ ff1fffffffffffff ZZ0025ZZ vmemmap
   ff20000000000000 ZZ0026ZZ ff5fffffffffffff ZZ0027ZZ không gian vmalloc/ioremap
   ff60000000000000 ZZ0028ZZ ffdeffffffffffff ZZ0029ZZ ánh xạ trực tiếp tất cả bộ nhớ vật lý
   ffdf0000000000000 ZZ0030ZZ fffffffffffffff ZZ0031ZZ kasan
  __________________ZZ0032ZZ__________________ZZ0033ZZ____________________________________________________________
                                                              |
                                                              | Bố cục giống hệt với bố cục 39 bit kể từ đây trở đi:
  ____________________________________________________________|____________________________________________________________
                    ZZ0034ZZ ZZ0035ZZ
   ffffffff00000000 ZZ0036ZZ ffffffff7fffffff mô-đun ZZ0037ZZ, BPF
   ffffffff80000000 ZZ0038ZZ ffffffffffffffff ZZ0039ZZ hạt nhân
  __________________ZZ0040ZZ__________________ZZ0041ZZ____________________________________________________________