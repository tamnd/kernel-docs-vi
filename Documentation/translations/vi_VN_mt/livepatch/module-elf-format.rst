.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/module-elf-format.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Mô-đun Livepatch định dạng ELF
==============================

Tài liệu này phác thảo các yêu cầu về định dạng ELF mà các mô-đun bản vá trực tiếp phải tuân theo.


.. Table of Contents

.. contents:: :local:


1. Bối cảnh và động lực
============================

Trước đây, livepatch yêu cầu mã dành riêng cho kiến trúc để viết
tái định cư. Tuy nhiên, mã dành riêng cho Arch để viết các vị trí đã có
tồn tại trong bộ tải mô-đun, do đó cách tiếp cận trước đây tạo ra sự dư thừa
mã. Vì vậy, thay vì sao chép mã và triển khai lại những gì mô-đun
trình tải đã có thể làm được, livepatch tận dụng mã hiện có trong mô-đun
bộ tải để thực hiện tất cả công việc di dời dành riêng cho vòm. Cụ thể,
livepatch sử dụng lại hàm apply_relocate_add() trong trình tải mô-đun để
viết di dời. Định dạng mô-đun bản vá ELF được mô tả trong tài liệu này
cho phép livepatch có thể thực hiện việc này. Hy vọng là điều này sẽ làm
livepatch dễ dàng di chuyển sang các kiến trúc khác hơn và giảm số lượng
mã dành riêng cho Arch cần thiết để chuyển bản vá trực tiếp sang một thiết bị cụ thể
kiến trúc.

Vì apply_relocate_add() yêu cầu quyền truy cập vào tiêu đề phần của mô-đun
bảng, bảng ký hiệu và các chỉ số phần tái định vị, thông tin ELF được
được bảo tồn cho các mô-đun livepatch (xem phần 5). Livepatch tự quản lý
các phần và ký hiệu di dời, được mô tả trong tài liệu này. các
Các hằng số ELF được sử dụng để đánh dấu các ký hiệu livepatch và các phần di dời
được chọn từ phạm vi dành riêng cho hệ điều hành theo định nghĩa từ glibc.

Tại sao livepatch cần phải viết các bản di dời của riêng mình?
-----------------------------------------------------
Một mô-đun livepatch điển hình chứa các phiên bản chức năng được vá lỗi có thể
tham chiếu các ký hiệu toàn cầu không được xuất và các ký hiệu cục bộ không được bao gồm.
Việc tái định vị tham chiếu các loại ký hiệu này không thể được giữ nguyên
vì trình tải mô-đun hạt nhân không thể giải quyết chúng và do đó sẽ
từ chối mô-đun livepatch. Hơn nữa, chúng tôi không thể áp dụng việc di dời mà
ảnh hưởng đến các mô-đun chưa được tải tại thời điểm tải mô-đun bản vá (ví dụ: một bản vá cho một
trình điều khiển chưa được tải). Trước đây, livepatch đã giải quyết vấn đề này bằng cách
nhúng các phần "dynrela" (rela động) đặc biệt vào bản vá kết quả
đầu ra mô-đun ELF. Sử dụng các phần dynrela này, livepatch có thể giải quyết
các ký hiệu trong khi tính đến phạm vi của nó và mô-đun ký hiệu
thuộc về, sau đó áp dụng các chuyển vị trí động theo cách thủ công. Tuy nhiên điều này
Cách tiếp cận yêu cầu livepatch cung cấp mã dành riêng cho Arch để viết
những cuộc di dời này. Ở định dạng mới, livepatch quản lý SHT_RELA của riêng mình
các phần tái định vị thay cho các phần dynrela và các ký hiệu mà
tham chiếu relas là các ký hiệu livepatch đặc biệt (xem phần 2 và 3). các
Mã di chuyển bản vá trực tiếp dành riêng cho Arch được thay thế bằng lệnh gọi tới
áp dụng_relocate_add().

2. Trường thông tin sửa đổi Livepatch
==========================

Các mô-đun Livepatch bắt buộc phải có thuộc tính modinfo "livepatch".
Xem mô-đun livepatch mẫu trong samples/livepatch/ để biết cách thực hiện việc này.

Người dùng có thể xác định các mô-đun Livepatch bằng cách sử dụng lệnh 'modinfo'
và tìm kiếm sự hiện diện của trường "livepatch". Lĩnh vực này cũng
được sử dụng bởi trình tải mô-đun hạt nhân để xác định các mô-đun livepatch.

Ví dụ:
--------

ZZ0000ZZ

::

% modinfo livepatch-meminfo.ko
	tên tập tin: livepatch-meminfo.ko
	bản vá trực tiếp: Y
	giấy phép: GPL
	phụ thuộc:
	vermagic: 4.3.0+ SMP mod_unload

3. Phần di dời Livepatch
================================

Mô-đun livepatch quản lý các phần di dời ELF của riêng nó để áp dụng
di chuyển đến các mô-đun cũng như hạt nhân (vmlinux) tại
thời điểm thích hợp. Ví dụ: nếu một mô-đun vá lỗi vá một trình điều khiển
hiện chưa được tải, livepatch sẽ áp dụng livepatch tương ứng
(các) phần di dời tới trình điều khiển sau khi tải.

Mỗi "đối tượng" (ví dụ: vmlinux hoặc mô-đun) trong mô-đun bản vá có thể có
nhiều phần di dời livepatch được liên kết với nó (ví dụ: các bản vá cho
nhiều chức năng trong cùng một đối tượng). Có sự tương ứng 1-1
giữa phần di dời livepatch và phần mục tiêu (thường là phần
phần văn bản của một hàm) mà (các) vị trí được áp dụng. Đó là
cũng có thể mô-đun livepatch không có khả năng di chuyển bản vá trực tiếp
các phần, như trong trường hợp mô-đun livepatch mẫu (xem
mẫu/bản vá trực tiếp).

Vì thông tin ELF được lưu giữ cho các mô-đun bản vá trực tiếp (xem Phần 5), nên
phần di dời livepatch có thể được áp dụng đơn giản bằng cách chuyển vào
chỉ mục phần thích hợp cho apply_relocate_add(), sau đó sử dụng nó để
truy cập phần di dời và áp dụng các di dời.

Mỗi biểu tượng được tham chiếu bởi một rela trong phần di dời livepatch là một
biểu tượng livepatch. Những điều này phải được giải quyết trước khi livepatch có thể gọi
áp dụng_relocate_add(). Xem Phần 3 để biết thêm thông tin.

3.1 Định dạng phần di dời Livepatch
=======================================

Các phần di dời Livepatch phải được đánh dấu bằng SHF_RELA_LIVEPATCH
cờ phần. Xem include/uapi/linux/elf.h để biết định nghĩa. mô-đun
trình tải nhận ra cờ này và sẽ tránh áp dụng các phần di dời đó
tại thời điểm tải mô-đun bản vá. Các phần này cũng phải được đánh dấu bằng SHF_ALLOC,
để trình tải mô-đun không loại bỏ chúng khi tải mô-đun (tức là chúng sẽ
được sao chép vào bộ nhớ cùng với các phần SHF_ALLOC khác).

Tên của phần di dời livepatch phải tuân theo các mục sau
định dạng::

.klp.rela.objname.section_name
  ^ ^^ ^ ^ ^
  ZZ0000ZZZZ0001ZZ ZZ0002ZZ
     [A] [B] [C]

[A]
  Tên phần di dời có tiền tố là chuỗi ".klp.rela."

[B]
  Tên của đối tượng (tức là "vmlinux" hoặc tên của mô-đun)
  phần tái định vị thuộc về phần nào ngay sau tiền tố.

[C]
  Tên thực tế của khu vực mà khu vực di dời này được áp dụng.

Ví dụ:
---------

ZZ0000ZZ

::

.klp.rela.ext4.text.ext4_attr_store
  .klp.rela.vmlinux.text.cmdline_proc_show

**Đầu ra ZZ0000ZZ cho một bản vá
mô-đun vá vmlinux và mô-đun 9p, btrfs, ext4:**

::

Tiêu đề phần:
  [Nr] Tên Loại Địa chỉ Tắt Kích thước ES Flg Lk Inf Al
  [cắt]
  [29] .klp.rela.9p.text.caches.show RELA 0000000000000000 002d58 0000c0 18 Aio 64 9 8
  [30] .klp.rela.btrfs.text.btrfs.feature.attr.show RELA 0000000000000000 002e18 000060 18 Aio 64 11 8
  [cắt]
  [34] .klp.rela.ext4.text.ext4.attr.store RELA 0000000000000000 002fd8 0000d8 18 Aio 64 13 8
  [35] .klp.rela.ext4.text.ext4.attr.show RELA 0000000000000000 0030b0 000150 18 Aio 64 15 8
  [36] .klp.rela.vmlinux.text.cmdline.proc.show RELA 00000000000000000 003200 000018 18 Aio 64 17 8
  [37] .klp.rela.vmlinux.text.meminfo.proc.show RELA 00000000000000000 003218 0000f0 18 Aio 64 19 8
  [cắt] ^ ^
                                                 ZZ0001ZZ
                                                [ZZ0000ZZ]

[*]
  Các phần di dời Livepatch là các phần SHT_RELA nhưng có một số phần đặc biệt
  đặc điểm. Lưu ý rằng chúng được đánh dấu SHF_ALLOC ("A") để chúng sẽ
  không bị loại bỏ khi mô-đun được tải vào bộ nhớ, cũng như với
  Cờ SHF_RELA_LIVEPATCH ("o" - dành riêng cho hệ điều hành).

ZZ0001ZZ

::

Phần di dời '.klp.rela.btrfs.text.btrfs_feature_attr_show' ở offset 0x2ba0 chứa 4 mục:
      Offset Thông tin Loại Giá trị Ký hiệu Tên Ký hiệu + Phụ lục
  0000000000000001f 0000005e00000002 R_X86_64_PC32 0000000000000000 .klp.sym.vmlinux.printk,0 - 4
  00000000000000028 0000003d0000000b R_X86_64_32S 0000000000000000 .klp.sym.btrfs.btrfs_ktype,0 + 0
  00000000000000036 0000003b00000002 R_X86_64_PC32 0000000000000000 .klp.sym.btrfs.can_modify_feature.isra.3,0 - 4
  0000000000000004c 0000004900000002 R_X86_64_PC32 0000000000000000 .klp.sym.vmlinux.snprintf,0 - 4
  [cắt] ^
                                                                             |
                                                                            [*]

[*]
  Mỗi biểu tượng được tham chiếu bởi một lần di dời đều là một biểu tượng livepatch.

4. Ký hiệu Livepatch
====================

Biểu tượng Livepatch là các biểu tượng được đề cập đến bởi các phần di dời livepatch.
Đây là những biểu tượng được truy cập từ các phiên bản chức năng mới dành cho các bản vá
các đối tượng mà địa chỉ của chúng không thể được giải quyết bằng trình tải mô-đun (vì
chúng là các sym toàn cầu cục bộ hoặc chưa được xuất). Vì chỉ có trình tải mô-đun
giải quyết các ký hiệu đã xuất và không phải mọi biểu tượng được tham chiếu bởi bản vá mới
các chức năng được xuất khẩu, các biểu tượng livepatch đã được giới thiệu. Chúng được sử dụng
cũng trong trường hợp chúng ta không thể biết ngay địa chỉ của một biểu tượng khi
tải một mô-đun bản vá. Ví dụ: đây là trường hợp khi các bản vá livepatch
một mô-đun chưa được tải. Trong trường hợp này, bản vá trực tiếp có liên quan
các ký hiệu được giải quyết đơn giản khi tải mô-đun đích. Trong mọi trường hợp, đối với
bất kỳ phần di dời livepatch nào, tất cả các biểu tượng livepatch được tham chiếu bởi phần đó
phần này phải được giải quyết trước khi livepatch có thể gọi apply_relocate_add() cho
phần reloc đó.

Các biểu tượng Livepatch phải được đánh dấu bằng SHN_LIVEPATCH để mô-đun
bộ nạp có thể xác định và bỏ qua chúng. Các mô-đun Livepatch giữ các ký hiệu này
trong các bảng ký hiệu của chúng và bảng ký hiệu có thể truy cập được thông qua
mô-đun-> bảng ký hiệu.

4.1 Bảng ký hiệu của mô-đun livepatch
=====================================
Thông thường, một bản sao rút gọn của bảng ký hiệu của mô-đun (chỉ chứa
ký hiệu "lõi") được cung cấp thông qua mô-đun->symtab (Xem bố cục_symtab()
trong kernel/module/kallsyms.c). Đối với các mô-đun livepatch, bảng ký hiệu được sao chép
vào bộ nhớ khi tải mô-đun phải giống hệt với bảng ký hiệu được tạo
khi mô-đun bản vá được biên dịch. Điều này là do việc tái định cư ở mỗi
phần di dời livepatch đề cập đến các biểu tượng tương ứng với biểu tượng của chúng
các chỉ mục và các chỉ mục ký hiệu gốc (và do đó thứ tự ký hiệu) phải là
được bảo tồn để apply_relocate_add() tìm đúng biểu tượng.

Ví dụ: lấy bản rela cụ thể này từ mô-đun livepatch ::

Phần di dời '.klp.rela.btrfs.text.btrfs_feature_attr_show' ở offset 0x2ba0 chứa 4 mục:
      Offset Thông tin Loại Giá trị Ký hiệu Tên Ký hiệu + Phụ lục
  0000000000000001f 0000005e00000002 R_X86_64_PC32 0000000000000000 .klp.sym.vmlinux.printk,0 - 4

Rela này đề cập đến ký hiệu '.klp.sym.vmlinux.printk,0' và ký hiệu
chỉ mục được mã hóa trong 'Thông tin'. Ở đây chỉ số ký hiệu của nó là 0x5e, bằng 94 in
số thập phân, đề cập đến chỉ số ký hiệu 94.

Và trong bảng ký hiệu tương ứng của mô-đun bản vá này, chỉ số ký hiệu 94 đề cập đến
với chính biểu tượng đó::

[cắt]
  94: 0000000000000000 0 NOTYPE GLOBAL DEFAULT OS [0xff20] .klp.sym.vmlinux.printk,0
  [cắt]

4.2 Định dạng biểu tượng Livepatch
===========================

Các biểu tượng Livepatch phải có chỉ mục phần được đánh dấu là SHN_LIVEPATCH, vì vậy
rằng trình tải mô-đun có thể xác định chúng và không cố gắng giải quyết chúng.
Xem include/uapi/linux/elf.h để biết các định nghĩa thực tế.

Tên biểu tượng Livepatch phải tuân theo định dạng sau ::

.klp.sym.objname.symbol_name,sympos
  ^ ^^ ^ ^ ^ ^
  ZZ0000ZZZZ0001ZZ ZZ0002ZZ |
     [A] [B] [C] [D]

[A]
  Tên biểu tượng có tiền tố là chuỗi ".klp.sym."

[B]
  Tên của đối tượng (tức là "vmlinux" hoặc tên của mô-đun)
  ký hiệu nào thuộc về ngay sau tiền tố.

[C]
  Tên thật của biểu tượng.

[D]
  Vị trí của ký hiệu trong đối tượng (theo kallsyms)
  Điều này được sử dụng để phân biệt các ký hiệu trùng lặp trong cùng một
  đối tượng. Vị trí ký hiệu được biểu thị bằng số (0, 1, 2...).
  Vị trí ký hiệu của một ký hiệu duy nhất là 0.

Ví dụ:
---------

ZZ0000ZZ

::

.klp.sym.vmlinux.snprintf,0
	.klp.sym.vmlinux.printk,0
	.klp.sym.btrfs.btrfs_ktype,0

ZZ0001ZZ

::

Bảng ký hiệu “.symtab” chứa 127 mục:
     Num: Giá trị Kích thước Loại Liên kết Tên Ndx
     [cắt]
      73: 0000000000000000 0 NOTYPE GLOBAL DEFAULT Hệ điều hành [0xff20] .klp.sym.vmlinux.snprintf,0
      74: 0000000000000000 0 NOTYPE GLOBAL DEFAULT Hệ điều hành [0xff20] .klp.sym.vmlinux.capable,0
      75: 0000000000000000 0 NOTYPE GLOBAL DEFAULT Hệ điều hành [0xff20] .klp.sym.vmlinux.find_next_bit,0
      76: 0000000000000000 0 NOTYPE GLOBAL DEFAULT OS [0xff20] .klp.sym.vmlinux.si_swapinfo,0
    [cắt] ^
                                                           |
                                                          [*]

[*]
  Lưu ý rằng 'Ndx' (Chỉ mục phần) cho các ký hiệu này là SHN_LIVEPATCH (0xff20).
  "OS" có nghĩa là dành riêng cho hệ điều hành.

5. Bảng ký hiệu và truy cập phần ELF
======================================
Bảng ký hiệu của mô-đun livepatch có thể truy cập được thông qua mô-đun->symtab.

Vì apply_relocate_add() yêu cầu quyền truy cập vào tiêu đề phần của mô-đun,
bảng ký hiệu và chỉ mục phần tái định vị, thông tin ELF được lưu giữ cho
mô-đun livepatch và được trình tải mô-đun truy cập thông qua
module->klp_info, là cấu trúc ZZ0000ZZ. Khi một mô-đun livepatch
tải, cấu trúc này được điền vào bởi trình tải mô-đun.
