.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/sh/new-machine.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Thêm bảng mới vào LinuxSH
=============================

Paul Mundt <lethal@linux-sh.org>

Tài liệu này cố gắng phác thảo những bước cần thiết để thêm hỗ trợ
dành cho các bo mạch mới sang cổng LinuxSH dưới nhân 2.5 và 2.6 mới. Cái này
cũng cố gắng phác thảo một số thay đổi đáng chú ý giữa phiên bản 2.4
và phần phụ trợ 2.5/2.6 SH.

1. Cấu trúc thư mục mới
==========================

Điều đầu tiên cần lưu ý là cấu trúc thư mục mới. Dưới 2,4, hầu hết
của mã dành riêng cho bảng (ngoại trừ bảng) đã kết thúc
trực tiếp trong Arch/sh/kernel/, với các tiêu đề dành riêng cho bảng kết thúc bằng
bao gồm/asm-sh/. Đối với kernel mới, mọi thứ được chia theo loại bảng,
loại chip đồng hành và loại CPU. Nhìn vào chế độ xem dạng cây của thư mục này
hệ thống phân cấp trông giống như sau:

Mã dành riêng cho bảng::

.
    |-- vòm
    |   ZZ0000ZZ-- bảng
    ZZ0004ZZ-- adx
    ZZ0005ZZ ZZ0001ZZ-- các tệp dành riêng cho bảng
    ZZ0006ZZ
    |           ... thêm bảng ở đây ...
    |
    ZZ0002ZZ-- asm-sh
	    |-- adx
	    |   ZZ0003ZZ-- tiêu đề dành riêng cho bảng
	    |
	    .. more boards here ...

Tiếp theo, đối với chip đồng hành::

.
    ZZ0000ZZ-- sh
	    ZZ0001ZZ-- hd6446x
		    ZZ0002ZZ-- các tệp dành riêng cho cchip

... and so on. Headers for the companion chips are treated the same way as
tiêu đề dành riêng cho bảng. Vì vậy, include/asm-sh/hd64461 là nơi chứa tất cả các
tiêu đề dành riêng cho hd64461.

Cuối cùng, hỗ trợ gia đình CPU cũng được tóm tắt ::

.
    |-- vòm
    |   ZZ0000ZZ--cpu
    ZZ0007ZZ |-- sh2
    ZZ0008ZZ |   ZZ0001ZZ-- Tệp chung SH-3
    ZZ0009ZZ ZZ0002ZZ-- Tệp chung SH-4
    |       ZZ0003ZZ-- Điều này cũng được chia ra cho mỗi dòng CPU, vì vậy mỗi gia đình có thể
    |               có bộ chức năng bộ đệm/tlb riêng.
    |
    ZZ0004ZZ-- asm-sh
	    |-- cpu-sh2
	    |   ZZ0005ZZ-- Tiêu đề cụ thể SH-3
	    ZZ0006ZZ-- Tiêu đề cụ thể SH-4

Cần lưu ý rằng các kiểu con CPU _not_ được trừu tượng hóa. Vì vậy, những điều này vẫn
cần được xử lý bằng mã cụ thể của dòng CPU.

2. Thêm bảng mới
=====================

Điều đầu tiên cần xác định là liệu bảng bạn đang thêm có phù hợp hay không.
bị cô lập hay liệu nó có phải là một phần của một nhóm hội đồng quản trị mà hầu hết có thể
chia sẻ cùng một mã dành riêng cho bảng với những khác biệt nhỏ.

Trong trường hợp đầu tiên, đây chỉ là vấn đề tạo một thư mục cho
board trong Arch/sh/boards/ và thêm các quy tắc để kết nối bảng của bạn với
xây dựng hệ thống (thêm về điều này trong phần tiếp theo). Tuy nhiên, đối với các gia đình hội đồng quản trị
sẽ hợp lý hơn khi có một thư mục Arch/sh/boards/ cấp cao nhất
và sau đó điền vào đó các thư mục con cho từng thành viên trong gia đình.
Cả Solution Engine và bo mạch hp6xx đều là một ví dụ về điều này.

Sau khi bạn đã thiết lập thư mục Arch/sh/boards/ mới, hãy nhớ rằng bạn
cũng nên thêm một thư mục trong include/asm-sh cho các tiêu đề được bản địa hóa cho mục này
bảng (nếu có nhiều hơn một bảng). Để tương tác được
liền mạch với hệ thống xây dựng, tốt nhất nên có thư mục này giống nhau
làm tên thư mục Arch/sh/boards/, tuy nhiên nếu bo mạch của bạn lại là một phần của
một gia đình, hệ thống xây dựng có cách giải quyết vấn đề này (thông qua incdir-y
quá tải) và bạn có thể thoải mái đặt tên thư mục theo họ
bản thân thành viên.

Có một vài thứ mà mỗi bảng bắt buộc phải có, cả trong
Arch/sh/boards và phân cấp include/asm-sh/. Để tốt hơn
giải thích điều này, chúng tôi sử dụng một số ví dụ để thêm một bảng tưởng tượng. cho
mã thiết lập, ít nhất chúng tôi được yêu cầu cung cấp định nghĩa cho
get_system_type() và platform_setup(). Đối với bảng tưởng tượng của chúng tôi, điều này
có thể trông giống như::

/*
    * Arch/sh/boards/vapor/setup.c - Mã thiết lập cho bảng ảo
    */
    #include <linux/init.h>

const char *get_system_type(void)
    {
	    trả về "FooTech Vaporboard";
    }

int __init platform_setup(void)
    {
	    /*
	    * Nếu phần cứng của chúng tôi thực sự tồn tại, chúng tôi sẽ làm thật
	    * thiết lập ở đây. Mặc dù việc để trống cái này cũng là điều hợp lý
	    * nếu không có công việc khởi đầu thực sự nào phải được thực hiện
	    * bảng này.
	    */

/* Khởi nghiệp tưởng tượng PCI ... */

/* Và còn gì nữa... */

trả về 0;
    }

Bảng tưởng tượng mới của chúng tôi cũng sẽ phải gắn vào machvec để có thể thực hiện được nó
có ích gì.

Các hàm machvec thuộc một số loại:

- Chức năng I/O cho bộ nhớ IO (inb, v.v.) và PCI/bộ nhớ chính (readb, v.v.).
 - Chức năng ánh xạ I/O (ioport_map, ioport_unmap, v.v.).
 - chức năng 'nhịp tim'.
 - Các thói quen khởi tạo PCI và IRQ.
 - Bộ phân bổ nhất quán (đối với các bảng cần bộ phân bổ đặc biệt,
   đặc biệt là để phân bổ một số SRAM dành riêng cho bảng cho DMA
   tay cầm).

Có các hàm machvec được thêm và xóa theo thời gian, vì vậy hãy luôn đảm bảo
hãy tham khảo include/asm-sh/machvec.h để biết trạng thái hiện tại của machvec.

Hạt nhân sẽ tự động bao bọc các quy trình chung cho hàm không xác định
con trỏ trong machvec lúc khởi động, vì các hàm machvec được tham chiếu
vô điều kiện trên hầu hết cây. Một số bảng có vô cùng
machvec thưa thớt (chẳng hạn như dreamcast và sh03), trong khi những machvec khác phải xác định
hầu như mọi thứ (rts7751r2d).

Việc thêm một máy mới là tương đối đơn giản (lấy hơi làm ví dụ):

Nếu các định nghĩa dành riêng cho bảng khá tối giản, như trường hợp của
đại đa số các bảng, chỉ cần có một tiêu đề dành riêng cho bảng là
đủ.

- thêm một tệp mới include/asm-sh/vapor.h chứa các nguyên mẫu cho
   bất kỳ chức năng IO cụ thể nào của máy có tiền tố tên máy, ví dụ:
   ví dụ hơi_inb. Những thứ này sẽ cần thiết khi điền vào máy
   vectơ.

Lưu ý rằng các nguyên mẫu này được tạo tự động bằng cách cài đặt
   __IO_PREFIX thành một cái gì đó hợp lý. Một ví dụ điển hình sẽ là::

Hơi #define __IO_PREFIX
	#include <asm/io_generic.h>

ở đâu đó trong tiêu đề dành riêng cho bảng. Bất kỳ bảng nào đang được chuyển mà vẫn
   có io.h kế thừa nên loại bỏ hoàn toàn và chuyển sang mô hình mới.

- Thêm định nghĩa vectơ máy vào setup.c của bảng. Ở mức tối thiểu,
   điều này phải được định nghĩa giống như::

struct sh_machine_vector mv_vapor __initmv = {
		.mv_name = "hơi",
	};
	ALIAS_MV(hơi)

- cuối cùng thêm một tệp Arch/sh/boards/vapor/io.c, chứa các định nghĩa về
   các chức năng io cụ thể của máy (nếu có đủ để đảm bảo).

3. Kết nối với hệ thống xây dựng
================================

Bây giờ chúng ta đã thiết lập các thư mục tương ứng và tất cả các
đã có mã dành riêng cho bảng, đã đến lúc xem xét cách lấy
toàn bộ mớ hỗn độn để phù hợp với hệ thống xây dựng.

Phần lớn hệ thống xây dựng giờ đây hoàn toàn động và chỉ đơn thuần là
yêu cầu mục nhập thích hợp ở đây và ở đó để hoàn thành công việc.

Điều đầu tiên cần làm là thêm một mục vào Arch/sh/Kconfig, bên dưới
Menu "Loại hệ thống"::

cấu hình SH_VAPOR
	    bool "Hơi"
	    giúp đỡ
	    chọn Vapor nếu định cấu hình cho FooTech Vaporboard.

tiếp theo, phần này phải được thêm vào Arch/sh/Makefile. Tất cả các bảng yêu cầu một
mục Machdir-y để được xây dựng. Mục này cần phải là tên của
thư mục bảng như nó xuất hiện trong Arch/sh/boards, ngay cả khi nó ở trong một
thư mục con (trong trường hợp đó, tất cả các thư mục mẹ bên dưới Arch/sh/boards/
cần liệt kê). Đối với bảng mới của chúng tôi, mục này có thể trông giống như::

machdir-$(CONFIG_SH_VAPOR) += hơi

với điều kiện là chúng ta đã đặt mọi thứ vào thư mục Arch/sh/boards/vapor/.

Tiếp theo, hệ thống xây dựng giả định rằng thư mục include/asm-sh của bạn cũng sẽ
được đặt tên giống nhau. Nếu đây không phải là trường hợp (như trường hợp có nhiều
các bảng thuộc một họ chung), thì tên thư mục cần phải là
được ngầm định thêm vào incdir-y. Mã hiện có quản lý việc này cho
Các bảng Solution Engine và hp6xx, vì vậy hãy xem những bảng này để biết ví dụ.

Sau khi đã xử lý xong, đã đến lúc thêm mục nhập cho loại máy.
Điều này được thực hiện bằng cách thêm một mục vào cuối Arch/sh/tools/mach-types
danh sách. Phương pháp để thực hiện việc này là dễ hiểu và vì vậy chúng ta sẽ không lãng phí
không gian đặt lại nó ở đây. Sau khi hoàn tất, bạn sẽ có thể sử dụng
kiểm tra ngầm cho bảng của bạn nếu bạn cần điều này ở đâu đó trong suốt
mã phổ biến, chẳng hạn như::

/* Hãy chắc chắn rằng chúng ta đang ở trên FooTech Vaporboard */
	nếu (!mach_is_vapor())
		trả về -ENODEV;

cũng lưu ý rằng việc kiểm tra mach_is_boardname() sẽ bị buộc phải thực hiện
chữ thường, bất kể thực tế là các mục nhập kiểu máy đều là
chữ hoa. Bạn có thể đọc kịch bản nếu bạn thực sự quan tâm, nhưng nó khá xấu,
nên có thể bạn không muốn làm điều đó.

Bây giờ tất cả những gì còn lại phải làm là cung cấp một bản defconfig cho bảng mới của bạn. Cái này
Nhân tiện, những người khác kết thúc với bảng này có thể chỉ cần sử dụng cấu hình này
để tham khảo thay vì cố đoán xem cài đặt nào sẽ là gì
được sử dụng trên đó.

Ngoài ra, ngay sau khi bạn sao chép một mẫu .config cho bảng mới của mình
(giả sử Arch/sh/configs/vapor_defconfig), bạn cũng có thể sử dụng trực tiếp điều này như một
xây dựng mục tiêu và nó sẽ được liệt kê ngầm như vậy trong văn bản trợ giúp.

Nhìn vào kết quả 'make help', bây giờ bạn sẽ thấy một cái gì đó như:

Mục tiêu cụ thể về kiến ​​trúc (sh):

=========================================================================
  zImage Ảnh hạt nhân được nén (arch/sh/boot/zImage)
  adx_defconfig Xây dựng cho adx
  cqreek_defconfig Xây dựng cho cqreek
  dreamcast_defconfig Xây dựng cho dreamcast
  ...
steam_defconfig Xây dựng cho hơi nước
  =========================================================================

sau đó cho phép bạn làm::

$ tạo ARCH=sh CROSS_COMPILE=sh4-linux- steam_defconfig vmlinux

nó sẽ lần lượt sao chép defconfig cho bảng này, chạy nó qua
oldconfig (nhắc bạn về bất kỳ tùy chọn mới nào kể từ thời điểm tạo),
và giúp bạn bắt đầu trên con đường có được một hạt nhân chức năng cho thiết bị mới của mình
bảng.