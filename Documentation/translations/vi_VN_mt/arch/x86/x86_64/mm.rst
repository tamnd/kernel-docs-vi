.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Quản lý bộ nhớ
=================

Bản đồ bộ nhớ ảo hoàn chỉnh với bảng trang 4 cấp
====================================================

.. note::

 - Negative addresses such as "-23 TB" are absolute addresses in bytes, counted down
   from the top of the 64-bit address space. It's easier to understand the layout
   when seen both in absolute addresses and in distance-from-top notation.

   For example 0xffffe90000000000 == -23 TB, it's 23 TB lower than the top of the
   64-bit address space (ffffffffffffffff).

   Note that as we get closer to the top of the address space, the notation changes
   from TB to GB and then MB/KB.

 - "16M TB" might look weird at first sight, but it's an easier way to visualize size
   notation than "16 EB", which few will recognize at first sight as 16 exabytes.
   It also shows it nicely how incredibly large 64-bit address space is.

::

================================================================= =================================================================
      Địa chỉ bắt đầu ZZ0000ZZ Địa chỉ cuối ZZ0001ZZ Mô tả khu vực VM
  ================================================================= =================================================================
                    ZZ0002ZZ ZZ0003ZZ
   0000000000000000 ZZ0004ZZ 00007ffffffefff ZZ0005ZZ bộ nhớ ảo trong không gian người dùng, khác nhau trên mỗi mm
   00007ffffffff000 ZZ0006ZZ 00007fffffffffff ZZ0007ZZ... lỗ bảo vệ
  __________________ZZ0008ZZ__________________ZZ0009ZZ___________________________________________________________
                    ZZ0010ZZ ZZ0011ZZ
   0000800000000000 ZZ0012ZZ 7fffffffffffffff ZZ0013ZZ ... lỗ lớn, rộng gần 63 bit của không chuẩn
                    ZZ0014ZZ ZZ0015ZZ có địa chỉ bộ nhớ ảo lên tới -8 EB
                    ZZ0016ZZ ZZ0017ZZ bắt đầu bù đắp ánh xạ hạt nhân.
                    ZZ0018ZZ ZZ0019ZZ
                    ZZ0020ZZ ZZ0021ZZ LAM nới lỏng việc kiểm tra tính chính tắc cho phép tạo bí danh
                    ZZ0022ZZ ZZ0023ZZ cho bộ nhớ không gian người dùng tại đây.
  __________________ZZ0024ZZ__________________ZZ0025ZZ___________________________________________________________
                                                              |
                                                              | Bộ nhớ ảo không gian hạt nhân, được chia sẻ giữa tất cả các tiến trình:
  __________________ZZ0026ZZ__________________ZZ0027ZZ___________________________________________________________
                    ZZ0028ZZ ZZ0029ZZ
   8000000000000000 ZZ0030ZZ ffff7ffffffffffff ZZ0031ZZ ... lỗ lớn, rộng gần 63 bit của không chuẩn
                    ZZ0032ZZ ZZ0033ZZ có địa chỉ bộ nhớ ảo lên tới -128 TB
                    ZZ0034ZZ ZZ0035ZZ bắt đầu bù đắp ánh xạ hạt nhân.
                    ZZ0036ZZ ZZ0037ZZ
                    ZZ0038ZZ ZZ0039ZZ LAM_SUP nới lỏng việc kiểm tra tính chính tắc cho phép tạo
                    Bí danh ZZ0040ZZ ZZ0041ZZ cho bộ nhớ kernel tại đây.
  ____________________________________________________________|___________________________________________________________
                    ZZ0042ZZ ZZ0043ZZ
   ffff800000000000 ZZ0044ZZ ffff87ffffffffff ZZ0045ZZ ... lỗ bảo vệ, cũng dành riêng cho hypervisor
   ffff880000000000 ZZ0046ZZ ffff887fffffffff ZZ0047ZZ LDT ánh xạ lại cho PTI
   ffff888000000000 ZZ0048ZZ ffffc87fffffffff ZZ0049ZZ ánh xạ trực tiếp tất cả bộ nhớ vật lý (page_offset_base)
   ffffc88000000000 ZZ0050ZZ ffffc8ffffffffff ZZ0051ZZ ... lỗ chưa sử dụng
   ffffc90000000000 ZZ0052ZZ ffffe8ffffffffff ZZ0053ZZ không gian vmalloc/ioremap (vmalloc_base)
   ffffe90000000000 ZZ0054ZZ ffffe9ffffffffff ZZ0055ZZ ... lỗ chưa sử dụng
   ffffea0000000000 ZZ0056ZZ ffffeaffffffffff ZZ0057ZZ bản đồ bộ nhớ ảo (vmemmap_base)
   ffffeb0000000000 ZZ0058ZZ ffffebffffffffff ZZ0059ZZ ... lỗ chưa sử dụng
   ffffec0000000000 ZZ0060ZZ fffffbffffffffff ZZ0061ZZ KASAN bộ nhớ bóng
  __________________ZZ0062ZZ__________________ZZ0063ZZ____________________________________________________________
                                                              |
                                                              | Bố cục giống hệt với bố cục 56 bit kể từ đây trở đi:
  ____________________________________________________________|____________________________________________________________
                    ZZ0064ZZ ZZ0065ZZ
   fffffc0000000000 ZZ0066ZZ fffffdffffffffff ZZ0067ZZ ... lỗ chưa sử dụng
                    ZZ0068ZZ ZZ0069ZZ vaddr_end cho KASLR
   fffffe0000000000 ZZ0070ZZ fffffe7fffffffff ZZ0071ZZ ánh xạ cpu_entry_area
   fffffe8000000000 ZZ0072ZZ fffffeffffffffff ZZ0073ZZ ... lỗ chưa sử dụng
   ffffff0000000000 ZZ0074ZZ ffffff7fffffffff ZZ0075ZZ % ngăn xếp sửa lỗi đặc biệt
   ffffff8000000000 ZZ0076ZZ ffffffeeffffffff ZZ0077ZZ ... lỗ chưa sử dụng
   ffffffef00000000 ZZ0078ZZ fffffffffffffff ZZ0079ZZ EFI không gian ánh xạ vùng
   ffffffff00000000 ZZ0080ZZ ffffffff7fffffff ZZ0081ZZ ... lỗ chưa sử dụng
   ffffffff80000000 ZZ0082ZZ ffffffff9fffffff ZZ0083ZZ ánh xạ văn bản hạt nhân, được ánh xạ tới địa chỉ vật lý 0
   ffffffff80000000 ZZ0084ZZ ZZ0085ZZ
   ffffffffa0000000 ZZ0086ZZ fffffffffffffff ZZ0087ZZ không gian ánh xạ mô-đun
   ffffffffff000000 ZZ0088ZZ ZZ0089ZZ
      FIXADDR_START ZZ0090ZZ ffffffffff5fffff ZZ0091ZZ phạm vi bản đồ sửa lỗi nội bộ của hạt nhân, kích thước thay đổi và độ lệch
   ffffffffff600000 ZZ0092ZZ ffffffffff600fff ZZ0093ZZ kế thừa vsyscall ABI
   ffffffffffe00000 ZZ0094ZZ ffffffffffffffff ZZ0095ZZ ... lỗ chưa sử dụng
  __________________ZZ0096ZZ__________________ZZ0097ZZ___________________________________________________________


Bản đồ bộ nhớ ảo hoàn chỉnh với bảng trang 5 cấp
====================================================

.. note::

 - With 56-bit addresses, user-space memory gets expanded by a factor of 512x,
   from 0.125 PB to 64 PB. All kernel mappings shift down to the -64 PB starting
   offset and many of the regions expand to support the much larger physical
   memory supported.

::

================================================================= =================================================================
      Địa chỉ bắt đầu ZZ0000ZZ Địa chỉ cuối ZZ0001ZZ Mô tả khu vực VM
  ================================================================= =================================================================
                    ZZ0002ZZ ZZ0003ZZ
   0000000000000000 ZZ0004ZZ 00ffffffffffff000 ZZ0005ZZ bộ nhớ ảo trong không gian người dùng, khác nhau trên mỗi mm
   00fffffffffff000 ZZ0006ZZ 00ffffffffffffff ZZ0007ZZ ... lỗ bảo vệ
  __________________ZZ0008ZZ__________________ZZ0009ZZ___________________________________________________________
                    ZZ0010ZZ ZZ0011ZZ
   0100000000000000 ZZ0012ZZ 7fffffffffffffff ZZ0013ZZ ... lỗ lớn, rộng gần 63 bit của không chuẩn
                    ZZ0014ZZ ZZ0015ZZ bộ nhớ ảo có địa chỉ lên tới -8EB TB
                    ZZ0016ZZ ZZ0017ZZ bắt đầu bù đắp ánh xạ hạt nhân.
                    ZZ0018ZZ ZZ0019ZZ
                    ZZ0020ZZ ZZ0021ZZ LAM nới lỏng việc kiểm tra tính chính tắc cho phép tạo bí danh
                    ZZ0022ZZ ZZ0023ZZ cho bộ nhớ không gian người dùng tại đây.
  __________________ZZ0024ZZ__________________ZZ0025ZZ___________________________________________________________
                                                              |
                                                              | Bộ nhớ ảo không gian hạt nhân, được chia sẻ giữa tất cả các tiến trình:
  ____________________________________________________________|___________________________________________________________
   8000000000000000 ZZ0026ZZ feffffffffffffff ZZ0027ZZ ... lỗ lớn, rộng gần 63 bit của không chuẩn
                    ZZ0028ZZ ZZ0029ZZ bộ nhớ ảo có địa chỉ lên tới -64 PB
                    ZZ0030ZZ ZZ0031ZZ bắt đầu bù đắp ánh xạ hạt nhân.
                    ZZ0032ZZ ZZ0033ZZ
                    ZZ0034ZZ ZZ0035ZZ LAM_SUP nới lỏng việc kiểm tra tính chính tắc cho phép tạo
                    Bí danh ZZ0036ZZ ZZ0037ZZ cho bộ nhớ kernel tại đây.
  ____________________________________________________________|___________________________________________________________
                    ZZ0038ZZ ZZ0039ZZ
   ff00000000000000 ZZ0040ZZ ff0fffffffffffff ZZ0041ZZ ... lỗ bảo vệ, cũng dành riêng cho hypervisor
   ff10000000000000 ZZ0042ZZ ff10ffffffffffff ZZ0043ZZ LDT ánh xạ lại cho PTI
   ff11000000000000 ZZ0044ZZ ff90ffffffffffff ZZ0045ZZ ánh xạ trực tiếp tất cả bộ nhớ vật lý (page_offset_base)
   ff91000000000000 ZZ0046ZZ ff9fffffffffffff ZZ0047ZZ ... lỗ chưa sử dụng
   ffa0000000000000 ZZ0048ZZ ffd1ffffffffffff ZZ0049ZZ không gian vmalloc/ioremap (vmalloc_base)
   ffd2000000000000 ZZ0050ZZ ffd3ffffffffffff ZZ0051ZZ ... lỗ chưa sử dụng
   ffd4000000000000 ZZ0052ZZ ffd5ffffffffffff ZZ0053ZZ bản đồ bộ nhớ ảo (vmemmap_base)
   ffd6000000000000 ZZ0054ZZ ffdeffffffffffff ZZ0055ZZ ... lỗ chưa sử dụng
   ffdf000000000000 ZZ0056ZZ fffffbffffffffff ZZ0057ZZ KASAN bộ nhớ bóng
  __________________ZZ0058ZZ__________________ZZ0059ZZ____________________________________________________________
                                                              |
                                                              | Bố cục giống hệt với bố cục 47 bit kể từ đây trở đi:
  ____________________________________________________________|____________________________________________________________
                    ZZ0060ZZ ZZ0061ZZ
   fffffc0000000000 ZZ0062ZZ fffffdffffffffff ZZ0063ZZ ... lỗ chưa sử dụng
                    ZZ0064ZZ ZZ0065ZZ vaddr_end cho KASLR
   fffffe0000000000 ZZ0066ZZ fffffe7fffffffff ZZ0067ZZ ánh xạ cpu_entry_area
   fffffe8000000000 ZZ0068ZZ fffffeffffffffff ZZ0069ZZ ... lỗ chưa sử dụng
   ffffff0000000000 ZZ0070ZZ ffffff7fffffffff ZZ0071ZZ % ngăn xếp sửa lỗi đặc biệt
   ffffff8000000000 ZZ0072ZZ ffffffeeffffffff ZZ0073ZZ ... lỗ chưa sử dụng
   ffffffef00000000 ZZ0074ZZ fffffffffffffff ZZ0075ZZ EFI không gian ánh xạ vùng
   ffffffff00000000 ZZ0076ZZ ffffffff7fffffff ZZ0077ZZ ... lỗ chưa sử dụng
   ffffffff80000000 ZZ0078ZZ ffffffff9fffffff ZZ0079ZZ ánh xạ văn bản hạt nhân, được ánh xạ tới địa chỉ vật lý 0
   ffffffff80000000 ZZ0080ZZ ZZ0081ZZ
   ffffffffa0000000 ZZ0082ZZ fffffffffffffff ZZ0083ZZ không gian ánh xạ mô-đun
   ffffffffff000000 ZZ0084ZZ ZZ0085ZZ
      FIXADDR_START ZZ0086ZZ ffffffffff5fffff ZZ0087ZZ phạm vi bản đồ sửa lỗi nội bộ của hạt nhân, kích thước thay đổi và độ lệch
   ffffffffff600000 ZZ0088ZZ ffffffffff600fff ZZ0089ZZ kế thừa vsyscall ABI
   ffffffffffe00000 ZZ0090ZZ ffffffffffffffff ZZ0091ZZ ... lỗ chưa sử dụng
  __________________ZZ0092ZZ__________________ZZ0093ZZ___________________________________________________________

Kiến trúc xác định địa chỉ ảo 64 bit. Việc triển khai có thể hỗ trợ
ít hơn. Hiện được hỗ trợ là địa chỉ ảo 48 và 57 bit. Bit 63
cho đến bit được triển khai quan trọng nhất đều được mở rộng dấu hiệu.
Điều này gây ra lỗ hổng giữa không gian người dùng và địa chỉ kernel nếu bạn giải thích chúng
như không dấu.

Ánh xạ trực tiếp bao gồm tất cả bộ nhớ trong hệ thống lên đến mức cao nhất
địa chỉ bộ nhớ (điều này có nghĩa là trong một số trường hợp nó cũng có thể bao gồm bộ nhớ PCI
lỗ).

Chúng tôi ánh xạ các dịch vụ thời gian chạy EFI trong 'efi_pgd' PGD trong một ổ đĩa ảo lớn 64GB
cửa sổ bộ nhớ (kích thước này là tùy ý, có thể tăng lên sau nếu cần).
Các ánh xạ không phải là một phần của bất kỳ hạt nhân PGD nào khác và chỉ khả dụng
trong các cuộc gọi thời gian chạy EFI.

Lưu ý rằng nếu CONFIG_RANDOMIZE_MEMORY được bật, ánh xạ trực tiếp của tất cả
bộ nhớ vật lý, không gian vmalloc/ioremap và bản đồ bộ nhớ ảo được chọn ngẫu nhiên.
Thứ tự của họ được giữ nguyên nhưng cơ sở của họ sẽ được bù đắp sớm khi khởi động.

Hãy hết sức cẩn thận so với KASLR khi thay đổi bất cứ điều gì ở đây. Địa chỉ KASLR
phạm vi không được trùng lặp với bất cứ thứ gì ngoại trừ vùng bóng KASAN, đó là
đúng vì KASAN vô hiệu hóa KASLR.

Đối với cả bố cục 4 và 5 cấp, giá trị KSTACK_ERASE_POISON trong 2 MB cuối cùng
lỗ: ffffffffffff4111