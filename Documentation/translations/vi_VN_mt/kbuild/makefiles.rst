.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/makefiles.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Tệp tạo hạt nhân Linux
======================

Tài liệu này mô tả Makefiles nhân Linux.

Tổng quan
========

Makefiles có năm phần::

Makefile là Makefile hàng đầu.
	.config tệp cấu hình kernel.
	Arch/$(SRCARCH)/Makefile thành Arch Makefile.
	scripts/Makefile.* các quy tắc chung, v.v. cho tất cả các Makefiles kbuild.
	kbuild Makefiles tồn tại trong mọi thư mục con

Makefile trên cùng đọc tệp .config, xuất phát từ kernel
quá trình cấu hình.

Makefile hàng đầu chịu trách nhiệm xây dựng hai sản phẩm chính: vmlinux
(hình ảnh hạt nhân thường trú) và các mô-đun (bất kỳ tệp mô-đun nào).
Nó xây dựng các mục tiêu này bằng cách đệ quy đi xuống các thư mục con của
cây nguồn hạt nhân.

Danh sách các thư mục con được truy cập tùy thuộc vào kernel
cấu hình. Makefile hàng đầu về mặt văn bản bao gồm một Makefile vòm
với tên Arch/$(SRCARCH)/Makefile. Nguồn cung cấp Makefile vòm
thông tin kiến trúc cụ thể lên Makefile hàng đầu.

Mỗi thư mục con có một kbuild Makefile thực hiện các lệnh
được truyền từ trên xuống. Kbuild Makefile sử dụng thông tin từ
Tệp .config để xây dựng các danh sách tệp khác nhau được kbuild sử dụng để xây dựng
bất kỳ mục tiêu tích hợp hoặc mô-đun nào.

scripts/Makefile.* chứa tất cả các định nghĩa/quy tắc, v.v.
được sử dụng để xây dựng kernel dựa trên kbuild makefiles.

Ai làm gì
=============

Mọi người có bốn mối quan hệ khác nhau với Makefiles kernel.

ZZ0002ZZ là những người xây dựng hạt nhân.  Những người này gõ lệnh như
ZZ0000ZZ hoặc ZZ0001ZZ.  Họ thường không đọc hoặc chỉnh sửa
bất kỳ Makefiles kernel nào (hoặc bất kỳ tệp nguồn nào khác).

ZZ0000ZZ là những người làm việc về các tính năng như thiết bị
trình điều khiển, hệ thống tập tin và giao thức mạng.  Những người này cần phải
duy trì các Makefiles kbuild cho hệ thống con mà chúng đang có
đang làm việc.  Để làm được điều này một cách hiệu quả, họ cần một số
kiến thức về kernel Makefiles, cùng với kiến thức chi tiết về
giao diện công cộng cho kbuild.

ZZ0000ZZ là những người làm việc trên toàn bộ kiến trúc, chẳng hạn như
như sparc hoặc x86.  Các nhà phát triển Arch cần biết về Arch Makefile
cũng như kbuild Makefiles.

ZZ0000ZZ là những người làm việc trên chính hệ thống xây dựng kernel.
Những người này cần biết về tất cả các khía cạnh của Makefiles kernel.

Tài liệu này hướng tới các nhà phát triển bình thường và nhà phát triển kiến ​​trúc.


Các tập tin kbuild
================

Hầu hết các Makefile trong kernel là kbuild Makefiles sử dụng
cơ sở hạ tầng kbuild Chương này giới thiệu cú pháp được sử dụng trong
kbuild tạo tập tin.

Tên ưa thích cho các tệp kbuild là ZZ0000ZZ nhưng ZZ0001ZZ có thể
được sử dụng và nếu tồn tại cả tệp ZZ0002ZZ và ZZ0003ZZ thì ZZ0004ZZ
tập tin sẽ được sử dụng.

Phần ZZ0000ZZ là phần giới thiệu nhanh; các chương tiếp theo cung cấp
biết thêm chi tiết, với các ví dụ thực tế.

Định nghĩa mục tiêu
----------------

Định nghĩa mục tiêu là phần chính (trái tim) của kbuild Makefile.
Những dòng này xác định các tập tin sẽ được xây dựng, bất kỳ quá trình biên dịch đặc biệt nào
các tùy chọn và bất kỳ thư mục con nào được nhập đệ quy.

Tệp makefile kbuild đơn giản nhất chứa một dòng:

Ví dụ::

obj-y += foo.o

Điều này cho kbuild biết rằng có một đối tượng trong thư mục đó, được đặt tên
foo.o. foo.o sẽ được xây dựng từ foo.c hoặc foo.S.

Nếu foo.o được xây dựng dưới dạng mô-đun thì biến obj-m sẽ được sử dụng.
Vì vậy mẫu sau thường được sử dụng:

Ví dụ::

obj-$(CONFIG_FOO) += foo.o

$(CONFIG_FOO) ước tính thành y (đối với tích hợp) hoặc m (đối với mô-đun).
Nếu CONFIG_FOO không phải y hay m thì tệp sẽ không được biên dịch
cũng không liên kết.

Mục tiêu đối tượng tích hợp - obj-y
-----------------------------

kbuild Makefile chỉ định các tệp đối tượng cho vmlinux
trong danh sách $(obj-y).  Những danh sách này phụ thuộc vào kernel
cấu hình.

Kbuild biên dịch tất cả các tệp $(obj-y).  Sau đó nó gọi
ZZ0000ZZ để hợp nhất các tệp này thành một tệp.a tích hợp.
Đây là một kho lưu trữ mỏng không có bảng ký hiệu. Sẽ có sau
được liên kết với vmlinux bằng scripts/link-vmlinux.sh

Thứ tự của các tệp trong $(obj-y) rất quan trọng.  trùng lặp trong
các danh sách được cho phép: phiên bản đầu tiên sẽ được liên kết vào
các phiên bản tích hợp sẵn và các phiên bản tiếp theo sẽ bị bỏ qua.

Thứ tự liên kết rất quan trọng, bởi vì một số chức năng nhất định
(module_init() / __initcall) sẽ được gọi trong quá trình khởi động trong
thứ tự chúng xuất hiện. Vì vậy hãy nhớ rằng việc thay đổi liên kết
thứ tự có thể ví dụ. thay đổi thứ tự SCSI của bạn
bộ điều khiển được phát hiện và do đó đĩa của bạn được đánh số lại.

Ví dụ::

#drivers/isdn/i4l/Makefile
  # Makefile dành cho trình điều khiển thiết bị và hệ thống con ISDN.
  Tùy chọn cấu hình # Each cho phép danh sách các tệp.
  obj-$(CONFIG_ISDN_I4L) += isdn.o
  obj-$(CONFIG_ISDN_PPP_BSDCOMP) += isdn_bsdcomp.o

Mục tiêu mô-đun có thể tải - obj-m
-----------------------------

$(obj-m) chỉ định các tệp đối tượng được xây dựng dưới dạng có thể tải được
mô-đun hạt nhân.

Một mô-đun có thể được xây dựng từ một tệp nguồn hoặc nhiều nguồn
tập tin. Trong trường hợp chỉ có một tệp nguồn, tệp kbuild makefile
chỉ cần thêm tệp vào $(obj-m).

Ví dụ::

#drivers/isdn/i4l/Makefile
  obj-$(CONFIG_ISDN_PPP_BSDCOMP) += isdn_bsdcomp.o

Lưu ý: Trong ví dụ này $(CONFIG_ISDN_PPP_BSDCOMP) đánh giá là "m"

Nếu một mô-đun hạt nhân được xây dựng từ nhiều tệp nguồn, bạn chỉ định
rằng bạn muốn xây dựng một mô-đun theo cách tương tự như trên; tuy nhiên,
kbuild cần biết bạn muốn xây dựng tệp đối tượng nào
module từ, vì vậy bạn phải thông báo bằng cách đặt $(<module_name>-y)
biến.

Ví dụ::

#drivers/isdn/i4l/Makefile
  obj-$(CONFIG_ISDN_I4L) += isdn.o
  isdn-y := isdn_net_lib.o isdn_v110.o isdn_common.o

Trong ví dụ này, tên mô-đun sẽ là isdn.o. Kbuild sẽ
biên dịch các đối tượng được liệt kê trong $(isdn-y) và sau đó chạy
ZZ0000ZZ trong danh sách các tệp này để tạo isdn.o.

Do kbuild nhận dạng $(<module_name>-y) cho các đối tượng tổng hợp,
bạn có thể sử dụng giá trị của ký hiệu ZZ0000ZZ để bao gồm tùy ý một
tệp đối tượng như một phần của đối tượng tổng hợp.

Ví dụ::

#fs/ext2/Makefile
  obj-$(CONFIG_EXT2_FS) += ext2.o
  ext2-y := balloc.o dir.o file.o ialloc.o inode.o ioctl.o \
    namei.o super.o symlink.o
  ext2-$(CONFIG_EXT2_FS_XATTR) += xattr.o xattr_user.o \
    xattr_trusted.o

Trong ví dụ này, xattr.o, xattr_user.o và xattr_trusted.o chỉ
một phần của đối tượng tổng hợp ext2.o if $(CONFIG_EXT2_FS_XATTR)
đánh giá là "y".

Lưu ý: Tất nhiên, khi bạn xây dựng các đối tượng vào kernel,
cú pháp trên cũng sẽ hoạt động. Vì vậy, nếu bạn có CONFIG_EXT2_FS=y,
kbuild sẽ xây dựng một tệp ext2.o cho riêng bạn
các bộ phận và sau đó liên kết phần này với phần mềm tích hợp sẵn, như bạn mong đợi.

Mục tiêu tệp thư viện - lib-y
--------------------------

Các đối tượng được liệt kê với obj-* được sử dụng cho các mô-đun hoặc
được kết hợp trong một tệp tích hợp sẵn cho thư mục cụ thể đó.
Ngoài ra còn có khả năng liệt kê các đối tượng sẽ
được đưa vào thư viện, lib.a.
Tất cả các đối tượng được liệt kê bằng lib-y được kết hợp trong một
thư viện cho thư mục đó.
Các đối tượng được liệt kê trong obj-y và được liệt kê bổ sung trong
lib-y sẽ không được đưa vào thư viện vì chúng sẽ
dù sao cũng có thể truy cập được.
Để nhất quán, các đối tượng được liệt kê trong lib-m sẽ được đưa vào lib.a.

Lưu ý rằng cùng một tệp kbuild makefile có thể liệt kê các tệp được tích hợp sẵn
và trở thành một phần của thư viện. Vì vậy cùng một thư mục
có thể chứa cả tệp tích hợp và tệp lib.a.

Ví dụ::

#arch/x86/lib/Makefile
  lib-y := độ trễ.o

Điều này sẽ tạo một thư viện lib.a dựa trên delay.o. Đối với kbuild để
thực sự nhận ra rằng có một lib.a đang được xây dựng, thư mục
sẽ được liệt kê trong libs-y.

Xem thêm ZZ0000ZZ.

Việc sử dụng lib-y thường bị hạn chế ở ZZ0000ZZ và ZZ0001ZZ.

Giảm dần xuống trong thư mục
------------------------------

Makefile chỉ chịu trách nhiệm xây dựng các đối tượng trong chính nó
thư mục. Các tập tin trong thư mục con phải được quản lý bởi
Makefiles trong các thư mục con này. Hệ thống xây dựng sẽ tự động
gọi thực hiện đệ quy trong các thư mục con, miễn là bạn cho nó biết
họ.

Để làm như vậy, obj-y và obj-m được sử dụng.
ext2 tồn tại trong một thư mục riêng và Makefile có trong fs/
yêu cầu kbuild đi xuống bằng cách sử dụng bài tập sau.

Ví dụ::

#fs/Tệp tạo
  obj-$(CONFIG_EXT2_FS) += ext2/

Nếu CONFIG_EXT2_FS được đặt thành "y" (tích hợp) hoặc "m" (mô-đun)
biến obj- tương ứng sẽ được đặt và kbuild sẽ giảm xuống
xuống thư mục ext2.

Kbuild sử dụng thông tin này không chỉ để quyết định rằng nó cần truy cập
thư mục mà còn quyết định có hay không liên kết các đối tượng từ
thư mục vào vmlinux.

Khi Kbuild đi xuống thư mục có "y", tất cả các đối tượng tích hợp
từ thư mục đó được kết hợp vào tệp tích hợp sẵn.a, tệp này sẽ
cuối cùng được liên kết vào vmlinux.

Ngược lại, khi Kbuild đi xuống thư mục có chữ "m", không có gì
từ thư mục đó sẽ được liên kết vào vmlinux. Nếu Makefile trong
thư mục đó chỉ định obj-y, những đối tượng đó sẽ mồ côi.
Rất có thể đó là lỗi của Makefile hoặc lỗi phụ thuộc trong Kconfig.

Kbuild cũng hỗ trợ cú pháp chuyên dụng, subdir-y và subdir-m, cho
đi xuống các thư mục con. Thật là phù hợp khi bạn biết họ
hoàn toàn không chứa các đối tượng không gian kernel. Một cách sử dụng điển hình là để cho
Kbuild đi vào các thư mục con để xây dựng công cụ.

Ví dụ::

# scripts/Tệp tạo
  subdir-$(CONFIG_GCC_PLUGINS) += gcc-plugin
  subdir-$(CONFIG_MODVERSIONS) += genksyms
  subdir-$(CONFIG_SECURITY_SELINUX) += selinux

Không giống như obj-y/m, subdir-y/m không cần dấu gạch chéo ở cuối vì điều này
cú pháp luôn được sử dụng cho các thư mục.

Cách tốt nhất là sử dụng biến ZZ0000ZZ khi gán thư mục
những cái tên. Điều này cho phép kbuild hoàn toàn bỏ qua thư mục nếu
tùy chọn ZZ0001ZZ tương ứng không phải là "y" hay "m".

Mục tiêu vmlinux không được tích hợp sẵn - extra-y
-------------------------------------

extra-y chỉ định các mục tiêu cần thiết để xây dựng vmlinux,
nhưng không được kết hợp thành tích hợp sẵn.

Ví dụ là:

1) tập lệnh liên kết vmlinux

Tập lệnh liên kết cho vmlinux được đặt tại
   Arch/$(SRCARCH)/kernel/vmlinux.lds

Ví dụ::

# arch/x86/kernel/Makefile
  thêm-y += vmlinux.lds

extra-y hiện không được dùng nữa vì điều này tương đương với:

luôn-$(KBUILD_BUILTIN) += vmlinux.lds

$(extra-y) chỉ nên chứa các mục tiêu cần thiết cho vmlinux.

Kbuild bỏ qua phần bổ sung khi vmlinux dường như không phải là mục tiêu cuối cùng.
(ví dụ: ZZ0000ZZ hoặc xây dựng các mô-đun bên ngoài)

Nếu bạn có ý định xây dựng mục tiêu vô điều kiện, luôn luôn-y (được giải thích
trong phần tiếp theo) là cú pháp đúng để sử dụng.

Luôn xây dựng mục tiêu - Always-y
-----------------------------

luôn-y chỉ định các mục tiêu luôn được xây dựng theo đúng nghĩa đen khi
Kbuild truy cập Makefile.

Ví dụ::

# ./Kbuild
  offsets-file := include/generated/asm-offsets.h
  luôn-y += $(offsets-file)

Cờ biên soạn
-----------------

ccflags-y, asflags-y và ldflags-y
  Ba cờ này chỉ áp dụng cho kbuild makefile trong đó chúng
  được giao. Chúng được sử dụng cho tất cả các cc, as và ld thông thường
  các lời gọi xảy ra trong quá trình xây dựng đệ quy.

ccflags-y chỉ định các tùy chọn để biên dịch bằng $(CC).

Ví dụ::

# drivers/acpi/acpica/Makefile
    ccflags-y := -Os -D_LINUX -DBUILDING_ACPICA
    ccflags-$(CONFIG_ACPI_DEBUG) += -DACPI_DEBUG_OUTPUT

Biến này là cần thiết vì Makefile hàng đầu sở hữu
  biến $(KBUILD_CFLAGS) và sử dụng nó cho các cờ biên dịch cho
  toàn bộ cây.

asflags-y chỉ định các tùy chọn trình biên dịch mã.

Ví dụ::

#arch/sparc/kernel/Makefile
    asflags-y := -ansi

ldflags-y chỉ định các tùy chọn để liên kết với $(LD).

Ví dụ::

#arch/cris/boot/nén/Makefile
    ldflags-y += -T $(src)/decompress_$(arch-y).lds

thư mục con-ccflags-y, thư mục con-asflags-y
  Hai cờ được liệt kê ở trên tương tự như ccflags-y và asflags-y.
  Sự khác biệt là các biến thể thư mục con có tác dụng đối với kbuild
  tập tin nơi chúng hiện diện và tất cả các thư mục con.
  Các tùy chọn được chỉ định bằng subdir-* được thêm vào dòng lệnh trước
  các tùy chọn được chỉ định bằng cách sử dụng các biến thể không phải thư mục con.

Ví dụ::

subdir-ccflags-y := -Werror

ccflags-remove-y, asflags-remove-y
  Những cờ này được sử dụng để loại bỏ các cờ cụ thể cho trình biên dịch,
  lời gọi hợp ngữ.

Ví dụ::

ccflags-remove-$(CONFIG_MCOUNT) += -pg

CFLAGS_$@, AFLAGS_$@
  CFLAGS_$@ và AFLAGS_$@ chỉ áp dụng cho các lệnh hiện tại
  tập tin kbuild.

$(CFLAGS_$@) chỉ định các tùy chọn cho mỗi tệp cho $(CC).  $@
  một phần có giá trị bằng chữ chỉ định tệp dành cho nó.

CFLAGS_$@ có mức độ ưu tiên cao hơn ccflags-remove-y; CFLAGS_$@
  có thể thêm lại các cờ trình biên dịch đã bị xóa bởi ccflags-remove-y.

Ví dụ::

# drivers/scsi/Makefile
    CFLAGS_aha152x.o = -DAHA152X_STAT -DAUTOCONF

Dòng này chỉ định cờ biên dịch cho aha152x.o.

$(AFLAGS_$@) là một tính năng tương tự cho các tệp nguồn trong tập hợp
  ngôn ngữ.

AFLAGS_$@ có mức độ ưu tiên cao hơn asflags-remove-y; AFLAGS_$@
  có thể thêm lại các cờ của trình biên dịch mã đã bị xóa bởi asflags-remove-y.

Ví dụ::

# arch/cánh tay/hạt nhân/Makefile
    AFLAGS_head.o := -DTEXT_OFFSET=$(TEXT_OFFSET)
    AFLAGS_crunch-bits.o := -Wa,-mcpu=ep9312
    AFLAGS_iwmmxt.o := -Wa,-mcpu=iwmmxt

Theo dõi sự phụ thuộc
-------------------

Kbuild theo dõi các phần phụ thuộc vào những điều sau:

1) Tất cả các tệp tiên quyết (cả ZZ0000ZZ và ZZ0001ZZ)
2) Tùy chọn ZZ0002ZZ được sử dụng trong tất cả các tệp tiên quyết
3) Dòng lệnh dùng để biên dịch mục tiêu

Do đó, nếu bạn thay đổi tùy chọn thành $(CC) thì tất cả các tệp bị ảnh hưởng sẽ
được biên soạn lại.

Quy tắc tùy chỉnh
------------

Quy tắc tùy chỉnh được sử dụng khi cơ sở hạ tầng kbuild thực hiện
không cung cấp sự hỗ trợ cần thiết. Một ví dụ điển hình là
các tệp tiêu đề được tạo trong quá trình xây dựng.
Một ví dụ khác là các Makefile dành riêng cho kiến trúc
cần các quy tắc tùy chỉnh để chuẩn bị hình ảnh khởi động, v.v.

Quy tắc tùy chỉnh được viết như quy tắc Make bình thường.
Kbuild không thực thi trong thư mục chứa Makefile
được định vị, vì vậy tất cả các quy tắc tùy chỉnh sẽ sử dụng một giá trị tương đối
đường dẫn đến các tập tin tiên quyết và các tập tin mục tiêu.

Hai biến được sử dụng khi xác định quy tắc tùy chỉnh:

$(src)
  $(src) là thư mục chứa Makefile. Luôn sử dụng $(src) khi
  đề cập đến các tập tin nằm trong cây src.

$(obj)
  $(obj) là thư mục lưu mục tiêu. Luôn sử dụng $(obj) khi
  đề cập đến các tập tin được tạo ra. Sử dụng $(obj) cho các quy tắc mẫu cần hoạt động
  cho cả tệp được tạo và nguồn thực (VPATH sẽ giúp tìm
  điều kiện tiên quyết không chỉ trong cây đối tượng mà còn trong cây nguồn).

Ví dụ::

#drivers/scsi/Makefile
    $(obj)/53c8xx_d.h: $(src)/53c7,8xx.scr $(src)/script_asm.pl
    $(CPP) -DCHIP=810 - < $< | ... $(src)/script_asm.pl

Đây là quy tắc tùy chỉnh, tuân theo cú pháp thông thường
  được yêu cầu bởi hãng sản xuất.

Tệp đích phụ thuộc vào hai tệp tiên quyết. Tài liệu tham khảo
  vào tệp mục tiêu có tiền tố $(obj), tham chiếu
  đến các điều kiện tiên quyết được tham chiếu bằng $(src) (vì chúng không
  các tập tin được tạo ra).

$(srcroot)
  $(srcroot) đề cập đến thư mục gốc của nguồn bạn đang xây dựng, có thể
  nguồn nhân hoặc nguồn mô-đun bên ngoài, tùy thuộc vào việc
  KBUILD_EXTMOD được thiết lập. Đây có thể là đường dẫn tương đối hoặc tuyệt đối, nhưng
  nếu KBUILD_ABS_SRCTREE=1 được đặt thì nó luôn là đường dẫn tuyệt đối.

$(srctree)
  $(srctree) đề cập đến gốc của cây nguồn kernel. Khi xây dựng
  kernel, cái này giống với $(srcroot).

$(cây đối tượng)
  $(objtree) đề cập đến gốc của cây đối tượng kernel. Đó là ZZ0000ZZ khi
  xây dựng hạt nhân, nhưng nó khác khi xây dựng các mô-đun bên ngoài.

$(kecho)
  lặp lại thông tin cho người dùng trong một quy tắc thường là một cách làm tốt
  nhưng khi thực thi ZZ0000ZZ, người ta không mong đợi thấy bất kỳ đầu ra nào
  ngoại trừ cảnh báo/lỗi.
  Để hỗ trợ kbuild này, hãy xác định $(kecho) sẽ lặp lại
  văn bản theo sau $(kecho) tới thiết bị xuất chuẩn trừ khi ZZ0001ZZ được sử dụng.

Ví dụ::

# arch/cánh tay/Tệp tạo
    $(BOOT_TARGETS): vmlinux
            $(Q)$(MAKE) $(build)=$(boot) MACHINE=$(MACHINE) $(boot)/$@
            @$(kecho) ' Hạt nhân: $(boot)/$@ đã sẵn sàng'

Khi kbuild đang thực thi với KBUILD_VERBOSE không được đặt, thì chỉ có một tốc ký
  của một lệnh thường được hiển thị.
  Để kích hoạt hành vi này cho các lệnh tùy chỉnh, kbuild yêu cầu
  hai biến được đặt::

yên tĩnh_cmd_<lệnh> - những gì sẽ được lặp lại
          cmd_<command> - lệnh thực thi

Ví dụ::

# lib/Tệp tạo
    yên tĩnh_cmd_crc32 = GEN $@
          cmd_crc32 = $< > $@

$(obj)/crc32table.h: $(obj)/gen_crc32table
            $(gọi cmd,crc32)

Khi cập nhật mục tiêu $(obj)/crc32table.h, dòng::

GEN lib/crc32table.h

sẽ được hiển thị với ZZ0000ZZ.

Phát hiện thay đổi lệnh
------------------------

Khi quy tắc được đánh giá, dấu thời gian được so sánh giữa mục tiêu
và các tập tin tiên quyết của nó. GNU Hãy cập nhật mục tiêu khi bất kỳ
điều kiện tiên quyết mới hơn thế.

Mục tiêu cũng nên được xây dựng lại khi dòng lệnh đã thay đổi
kể từ lần gọi cuối cùng. Điều này không được Make hỗ trợ, vì vậy
Kbuild đạt được điều này bằng một loại siêu lập trình.

if_changed là macro được sử dụng cho mục đích này, ở dạng sau::

Quiet_cmd_<lệnh> = ...
        cmd_<lệnh> = ...

<mục tiêu>: <nguồn> FORCE
          $(gọi if_changed,<command>)

Bất kỳ mục tiêu nào sử dụng if_changed đều phải được liệt kê trong $(targets),
nếu không việc kiểm tra dòng lệnh sẽ thất bại và mục tiêu sẽ
luôn được xây dựng.

Nếu mục tiêu đã được liệt kê theo cú pháp được nhận dạng, chẳng hạn như
obj-y/m, lib-y/m, extra-y/m, luôn-y/m, Hostprogs, userprogs, Kbuild
tự động thêm nó vào $(target). Ngược lại, mục tiêu phải là
được thêm rõ ràng vào $(target).

Việc gán cho $(targets) không có tiền tố $(obj)/. if_changed có thể
được sử dụng cùng với các quy tắc tùy chỉnh như được xác định trong ZZ0000ZZ.

Lưu ý: Việc quên điều kiện tiên quyết FORCE là một sai lầm điển hình.
Một nhược điểm phổ biến khác là khoảng trắng đôi khi rất quan trọng; cho
Ví dụ, phần bên dưới sẽ thất bại (lưu ý khoảng trắng thừa sau dấu phẩy)::

mục tiêu: (các) nguồn FORCE

ZZ0000ZZ $(gọi if_changed, objcopy)

Lưu ý:
  if_changed không nên được sử dụng nhiều lần cho mỗi mục tiêu.
  Nó lưu trữ lệnh đã thực thi trong một .cmd tương ứng
  tập tin và nhiều cuộc gọi sẽ dẫn đến việc ghi đè và
  kết quả không mong muốn khi mục tiêu được cập nhật và chỉ
  kiểm tra các lệnh đã thay đổi sẽ kích hoạt việc thực thi các lệnh.

chức năng hỗ trợ $(CC)
-----------------------

Hạt nhân có thể được xây dựng với nhiều phiên bản khác nhau của
$(CC), mỗi loại hỗ trợ một bộ tính năng và tùy chọn riêng.
kbuild cung cấp hỗ trợ cơ bản để kiểm tra các tùy chọn hợp lệ cho $(CC).
$(CC) thường là trình biên dịch gcc, nhưng các lựa chọn thay thế khác là
có sẵn.

tùy chọn
  as-option được sử dụng để kiểm tra xem $(CC) -- khi được sử dụng để biên dịch
  các tệp trình biên dịch mã (ZZ0000ZZ) - hỗ trợ tùy chọn đã cho. Một tùy chọn
  tùy chọn thứ hai có thể được chỉ định nếu tùy chọn đầu tiên không được hỗ trợ.

Ví dụ::

#arch/sh/Tập tin tạo
    cflags-y += $(gọi as-option,-Wa$(comma)-isa=$(isa-y),)

Trong ví dụ trên, cflags-y sẽ được gán tùy chọn
  -Wa$(comma)-isa=$(isa-y) nếu nó được hỗ trợ bởi $(CC).
  Đối số thứ hai là tùy chọn và nếu được cung cấp sẽ được sử dụng
  nếu đối số đầu tiên không được hỗ trợ.

as-instr
  as-instr kiểm tra xem trình biên dịch có báo cáo một lệnh cụ thể hay không
  và sau đó xuất ra option1 hoặc option2
  Lối thoát C được hỗ trợ trong hướng dẫn kiểm tra
  Lưu ý: as-instr-option sử dụng KBUILD_AFLAGS cho các tùy chọn trình biên dịch mã

tùy chọn cc
  tùy chọn cc được sử dụng để kiểm tra xem $(CC) có hỗ trợ một tùy chọn nhất định hay không và liệu
  không được hỗ trợ để sử dụng tùy chọn thứ hai tùy chọn.

Ví dụ::

#arch/x86/Tệp tạo
    cflags-y += $(gọi cc-option,-march=pentium-mmx,-march=i586)

Trong ví dụ trên, cflags-y sẽ được gán tùy chọn
  -march=pentium-mmx nếu được hỗ trợ bởi $(CC), nếu không thì -march=i586.
  Đối số thứ hai cho cc-option là tùy chọn và nếu bị bỏ qua,
  cflags-y sẽ không được gán giá trị nếu tùy chọn đầu tiên không được hỗ trợ.
  Lưu ý: tùy chọn cc sử dụng KBUILD_CFLAGS cho tùy chọn $(CC)

cc-option-yn
  cc-option-yn được sử dụng để kiểm tra xem $(CC) có hỗ trợ một tùy chọn nhất định không
  và trả về "y" nếu được hỗ trợ, nếu không thì trả về "n".

Ví dụ::

#arch/ppc/Tệp Makefile
    biarch := $(gọi cc-option-yn, -m32)
    aflags-$(biarch) += -a32
    cflags-$(biarch) += -m32

Trong ví dụ trên, $(biarch) được đặt thành y nếu $(CC) hỗ trợ -m32
  tùy chọn. Khi $(biarch) bằng "y", các biến mở rộng $(aflags-y)
  và $(cflags-y) sẽ được gán các giá trị -a32 và -m32,
  tương ứng.

Lưu ý: cc-option-yn sử dụng KBUILD_CFLAGS cho các tùy chọn $(CC)

cc-vô hiệu hóa-cảnh báo
  cc-disable-warning kiểm tra xem $(CC) có hỗ trợ cảnh báo đã cho hay không và trả về
  chuyển đổi dòng lệnh để vô hiệu hóa nó. Chức năng đặc biệt này là cần thiết,
  bởi vì gcc 4.4 trở lên chấp nhận mọi tùy chọn -Wno-* không xác định và chỉ
  cảnh báo về điều đó nếu có cảnh báo khác trong tệp nguồn.

Ví dụ::

KBUILD_CFLAGS += $(gọi cc-disable-cảnh báo, biến không sử dụng nhưng được đặt)

Trong ví dụ trên, -Wno-unused-but-set-variable sẽ được thêm vào
  KBUILD_CFLAGS chỉ khi $(CC) thực sự chấp nhận nó.

phiên bản gcc-min
  gcc-min-version kiểm tra xem giá trị của $(CONFIG_GCC_VERSION) có lớn hơn
  hoặc bằng giá trị được cung cấp và đánh giá là y nếu vậy.

Ví dụ::

cflags-$(gọi gcc-min-version, 110100) := -foo

Trong ví dụ này, cflags-y sẽ được gán giá trị -foo nếu $(CC) là gcc và
  $(CONFIG_GCC_VERSION) là >= 11,1.

clang-min-phiên bản
  clang-min-version kiểm tra xem giá trị của $(CONFIG_CLANG_VERSION) có lớn hơn không
  hơn hoặc bằng giá trị được cung cấp và đánh giá là y nếu vậy.

Ví dụ::

cflags-$(gọi clang-min-version, 110000) := -foo

Trong ví dụ này, cflags-y sẽ được gán giá trị -foo nếu $(CC) là clang
  và $(CONFIG_CLANG_VERSION) là >= 11.0.0.

tiền tố chéo cc
  tiền tố cc-cross được sử dụng để kiểm tra xem có tồn tại $(CC) trong đường dẫn với
  một trong những tiền tố được liệt kê. Tiền tố đầu tiên tồn tại một
  tiền tố$(CC) trong PATH được trả về - và nếu không tìm thấy tiền tố$(CC)
  sau đó không có gì được trả lại.

Các tiền tố bổ sung được phân cách bằng một khoảng trắng trong
  lệnh gọi tiền tố cc-cross.

Chức năng này hữu ích cho các Makefile kiến trúc cố gắng
  để đặt CROSS_COMPILE thành các giá trị nổi tiếng nhưng có thể có một số
  giá trị để lựa chọn giữa.

Bạn chỉ nên thử đặt CROSS_COMPILE nếu nó là chữ thập
  xây dựng (vòm máy chủ khác với vòm đích). Và nếu CROSS_COMPILE
  đã được đặt rồi thì để nguyên giá trị cũ.

Ví dụ::

#arch/m68k/Tập tin tạo
    ifneq ($(SUBARCH),$(ARCH))
            ifeq ($(CROSS_COMPILE),)
                    CROSS_COMPILE := $(gọi tiền tố cc-cross, m68k-linux-gnu-)
            cuối cùng
    cuối cùng

Các chức năng hỗ trợ $(RUSTC)
--------------------------

phiên bản Rustc-min
  kiểm tra phiên bản Rustc-min nếu giá trị của $(CONFIG_RUSTC_VERSION) lớn hơn
  hơn hoặc bằng giá trị được cung cấp và đánh giá là y nếu vậy.

Ví dụ::

Rustflags-$(gọi Rustc-min-version, 108500) := -Cfoo

Trong ví dụ này, Rustflags-y sẽ được gán giá trị -Cfoo nếu
  $(CONFIG_RUSTC_VERSION) là >= 1,85,0.

chức năng hỗ trợ $(LD)
-----------------------

tùy chọn ld
  Tùy chọn ld được sử dụng để kiểm tra xem $(LD) có hỗ trợ tùy chọn được cung cấp hay không.
  ld-option lấy hai tùy chọn làm đối số.

Đối số thứ hai là một tùy chọn tùy chọn có thể được sử dụng nếu
  tùy chọn đầu tiên không được hỗ trợ bởi $(LD).

Ví dụ::

#Makefile
    LDFLAGS_vmlinux += $(gọi ld-option, -X)

Lời gọi tập lệnh
-----------------

Tạo quy tắc có thể gọi các tập lệnh để xây dựng kernel. Các quy tắc sẽ
luôn cung cấp trình thông dịch thích hợp để thực thi tập lệnh. Họ
sẽ không dựa vào các bit thực thi được thiết lập và sẽ không gọi lệnh
kịch bản trực tiếp. Để thuận tiện cho việc gọi tập lệnh thủ công, chẳng hạn như
khi gọi ./scripts/checkpatch.pl, bạn nên đặt thực thi
Tuy nhiên, các bit trên các tập lệnh.

Kbuild cung cấp các biến $(CONFIG_SHELL), $(AWK), $(PERL),
và $(PYTHON3) để chỉ thông dịch viên cho từng trường hợp tương ứng
kịch bản.

Ví dụ::

#Makefile
  cmd_depmod = $(CONFIG_SHELL) $(srctree)/scripts/depmod.sh $(DEPMOD) \
          $(KERNELRELEASE)

Hỗ trợ chương trình máy chủ
====================

Kbuild hỗ trợ xây dựng các file thực thi trên máy chủ để sử dụng trong quá trình
giai đoạn biên soạn.

Cần có hai bước để sử dụng máy chủ thực thi.

Bước đầu tiên là thông báo cho kbuild rằng có một chương trình máy chủ tồn tại. Đây là
được thực hiện bằng cách sử dụng biến ZZ0000ZZ.

Bước thứ hai là thêm phần phụ thuộc rõ ràng vào tệp thực thi.
Điều này có thể được thực hiện theo hai cách. Hoặc thêm phần phụ thuộc vào một quy tắc,
hoặc sử dụng biến ZZ0000ZZ.
Cả hai khả năng đều được mô tả sau đây.

Chương trình máy chủ đơn giản
-------------------

Trong một số trường hợp cần phải biên dịch và chạy một chương trình trên
máy tính nơi bản dựng đang chạy.

Dòng sau đây cho kbuild biết rằng chương trình bin2hex sẽ là
được xây dựng trên máy chủ xây dựng.

Ví dụ::

Hostprogs := bin2hex

Kbuild giả định trong ví dụ trên rằng bin2hex được tạo từ một
tệp nguồn c có tên bin2hex.c nằm trong cùng thư mục với
Makefile.

Chương trình máy chủ tổng hợp
-----------------------

Các chương trình máy chủ có thể được tạo thành dựa trên các đối tượng tổng hợp.
Cú pháp được sử dụng để định nghĩa các đối tượng tổng hợp cho chương trình máy chủ là
tương tự như cú pháp được sử dụng cho các đối tượng kernel.
$(<executable>-objs) liệt kê tất cả các đối tượng được sử dụng để liên kết cuối cùng
thực thi được.

Ví dụ::

#scripts/lxdialog/Makefile
  Hostprogs := lxdialog
  lxdialog-objs := danh sách kiểm tra.o lxdialog.o

Các đối tượng có phần mở rộng .o được biên dịch từ .c tương ứng
tập tin. Trong ví dụ trên, danh sách kiểm tra.c được biên dịch thành danh sách kiểm tra.o
và lxdialog.c được biên dịch thành lxdialog.o.

Cuối cùng, hai tệp .o được liên kết với tệp thực thi, lxdialog.
Lưu ý: Cú pháp <executable>-y không được phép đối với các chương trình máy chủ.

Sử dụng C++ cho chương trình máy chủ
---------------------------

kbuild cung cấp hỗ trợ cho các chương trình máy chủ được viết bằng C++. Đây là
được giới thiệu chỉ để hỗ trợ kconfig và không được khuyến nghị
để sử dụng chung.

Ví dụ::

#scripts/kconfig/Makefile
  Hostprogs := qconf
  qconf-cxxobjs := qconf.o

Trong ví dụ trên, tệp thực thi bao gồm tệp C++
qconf.cc - được xác định bởi $(qconf-cxxobjs).

Nếu qconf bao gồm hỗn hợp các tệp .c và .cc thì
dòng bổ sung có thể được sử dụng để xác định điều này.

Ví dụ::

#scripts/kconfig/Makefile
  Hostprogs := qconf
  qconf-cxxobjs := qconf.o
  qconf-objs := kiểm tra.o

Sử dụng Rust cho các chương trình máy chủ
----------------------------

Kbuild cung cấp hỗ trợ cho các chương trình máy chủ được viết bằng Rust. Tuy nhiên,
vì chuỗi công cụ Rust không bắt buộc phải có để biên dịch kernel,
nó chỉ có thể được sử dụng trong các tình huống mà Rust bắt buộc phải có
khả dụng (ví dụ: khi ZZ0000ZZ được bật).

Ví dụ::

Hostprogs := mục tiêu
  mục tiêu rỉ sét := y

Kbuild sẽ biên dịch ZZ0000ZZ bằng cách sử dụng ZZ0001ZZ làm gốc thùng,
nằm trong cùng thư mục với ZZ0002ZZ. Thùng có thể
bao gồm một số tệp nguồn (xem ZZ0003ZZ).

Kiểm soát các tùy chọn trình biên dịch cho chương trình máy chủ
----------------------------------------------

Khi biên dịch chương trình máy chủ, có thể đặt các cờ cụ thể.
Các chương trình sẽ luôn được biên dịch bằng cách sử dụng $(HOSTCC) được thông qua
các tùy chọn được chỉ định trong $(KBUILD_HOSTCFLAGS).

Để đặt cờ sẽ có hiệu lực cho tất cả các chương trình máy chủ được tạo
trong Makefile đó, hãy sử dụng biến HOST_EXTRACFLAGS.

Ví dụ::

#scripts/lxdialog/Makefile
  HOST_EXTRACFLAGS += -I/usr/include/ncurses

Để đặt cờ cụ thể cho một tệp, cấu trúc sau
được sử dụng:

Ví dụ::

#arch/ppc64/boot/Makefile
  HOSTCFLAGS_piggyback.o := -DKERNELBASE=$(KERNELBASE)

Cũng có thể chỉ định các tùy chọn bổ sung cho trình liên kết.

Ví dụ::

#scripts/kconfig/Makefile
  HOSTLDLIBS_qconf := -L$(QTDIR)/lib

Khi liên kết qconf sẽ được thông qua tùy chọn bổ sung
ZZ0000ZZ.

Khi chương trình máy chủ thực sự được xây dựng
-------------------------------------

Kbuild sẽ chỉ xây dựng các chương trình máy chủ khi chúng được tham chiếu
như một điều kiện tiên quyết.

Điều này có thể thực hiện được theo hai cách:

(1) Liệt kê điều kiện tiên quyết một cách rõ ràng trong quy tắc tùy chỉnh.

Ví dụ::

#drivers/pci/Makefile
      Hostprogs := gen-devlist
      $(obj)/devlist.h: $(src)/pci.ids $(obj)/gen-devlist
      ( cd $(obj); ./gen-devlist ) < $<

Mục tiêu $(obj)/devlist.h sẽ không được xây dựng trước đó
    $(obj)/gen-devlist được cập nhật. Lưu ý rằng tham chiếu đến
    các chương trình máy chủ trong quy tắc tùy chỉnh phải có tiền tố $(obj).

(2) Sử dụng luôn-y

Khi không có quy tắc tùy chỉnh phù hợp và chương trình chủ
    sẽ được xây dựng khi nhập tệp thực hiện, luôn luôn-y
    biến sẽ được sử dụng.

Ví dụ::

#scripts/lxdialog/Makefile
      Hostprogs := lxdialog
      luôn luôn-y := $(hostprogs)

Kbuild cung cấp cách viết tắt sau đây cho việc này::

Hostprogs-always-y := lxdialog

Điều này sẽ yêu cầu kbuild xây dựng lxdialog ngay cả khi không được tham chiếu trong
    bất kỳ quy tắc nào.

Hỗ trợ chương trình không gian người dùng
=========================

Cũng giống như các chương trình máy chủ, Kbuild cũng hỗ trợ xây dựng các tệp thực thi của không gian người dùng
cho kiến trúc đích (tức là kiến trúc giống như bạn đang xây dựng
hạt nhân cho).

Cú pháp khá giống nhau. Sự khác biệt là sử dụng ZZ0000ZZ thay vì
ZZ0001ZZ.

Chương trình không gian người dùng đơn giản
------------------------

Dòng sau đây cho kbuild biết rằng chương trình bpf-direct sẽ là
được xây dựng cho kiến trúc mục tiêu.

Ví dụ::

userprogs := bpf-direct

Kbuild giả định trong ví dụ trên rằng bpf-direct được tạo từ một
tệp nguồn C duy nhất có tên bpf-direct.c nằm trong cùng thư mục
dưới dạng Makefile.

Chương trình không gian người dùng tổng hợp
----------------------------

Các chương trình không gian người dùng có thể được tạo thành dựa trên các đối tượng tổng hợp.
Cú pháp được sử dụng để định nghĩa các đối tượng tổng hợp cho các chương trình không gian người dùng là
tương tự như cú pháp được sử dụng cho các đối tượng kernel.
$(<executable>-objs) liệt kê tất cả các đối tượng được sử dụng để liên kết cuối cùng
thực thi được.

Ví dụ::

#samples/seccomp/Makefile
  userprogs := bpf-fancy
  bpf-fancy-objs := bpf-fancy.o bpf-helper.o

Các đối tượng có phần mở rộng .o được biên dịch từ .c tương ứng
tập tin. Trong ví dụ trên, bpf-fancy.c được biên dịch thành bpf-fancy.o
và bpf-helper.c được biên dịch thành bpf-helper.o.

Cuối cùng, hai tệp .o được liên kết với tệp thực thi, bpf-fancy.
Lưu ý: Cú pháp <executable>-y không được phép đối với các chương trình vùng người dùng.

Kiểm soát các tùy chọn trình biên dịch cho các chương trình không gian người dùng
---------------------------------------------------

Khi biên dịch các chương trình không gian người dùng, có thể đặt các cờ cụ thể.
Các chương trình sẽ luôn được biên dịch bằng cách sử dụng $(CC) được thông qua
các tùy chọn được chỉ định trong $(KBUILD_USERCFLAGS).

Để đặt cờ sẽ có hiệu lực cho tất cả các chương trình không gian người dùng được tạo
trong Makefile đó, hãy sử dụng biến userccflags.

Ví dụ::

# samples/seccomp/Makefile
  userccflags += -I usr/include

Để đặt cờ cụ thể cho một tệp, cấu trúc sau
được sử dụng:

Ví dụ::

bpf-helper-userccflags += -I người dùng/bao gồm

Cũng có thể chỉ định các tùy chọn bổ sung cho trình liên kết.

Ví dụ::

# net/bpfilter/Makefile
  bpfilter_umh-userldflags += -static

Để chỉ định các thư viện được liên kết với chương trình không gian người dùng, bạn có thể sử dụng
ZZ0000ZZ. Cú pháp ZZ0001ZZ chỉ định các thư viện
được liên kết với tất cả các chương trình không gian người dùng được tạo trong Makefile hiện tại.

Khi liên kết bpfilter_umh, nó sẽ được chuyển thêm tùy chọn -static.

Từ dòng lệnh, ZZ0000ZZ cũng sẽ được sử dụng.

Khi các chương trình không gian người dùng thực sự được xây dựng
------------------------------------------

Kbuild chỉ xây dựng các chương trình không gian người dùng khi được yêu cầu làm như vậy.
Có hai cách để làm điều này.

(1) Thêm nó làm điều kiện tiên quyết của một tệp khác

Ví dụ::

#net/bpfilter/Makefile
      userprogs := bpfilter_umh
      $(obj)/bpfilter_umh_blob.o: $(obj)/bpfilter_umh

$(obj)/bpfilter_umh được xây dựng trước $(obj)/bpfilter_umh_blob.o

(2) Sử dụng luôn-y

Ví dụ::

userprogs := binderfs_example
      luôn-y := $(userprogs)

Kbuild cung cấp cách viết tắt sau đây cho việc này::

userprogs-always-y := binderfs_example

Điều này sẽ yêu cầu Kbuild xây dựng binderfs_example khi nó truy cập vào đây
    Makefile.

Kbuild hạ tầng sạch
===========================

ZZ0000ZZ xóa hầu hết các tệp được tạo trong cây obj nơi chứa kernel
được biên soạn. Điều này bao gồm các tập tin được tạo ra như các chương trình lưu trữ.
Kbuild biết các mục tiêu được liệt kê trong $(hostprogs), $(always-y), $(always-m),
$(always-), $(extra-y), $(extra-) và $(targets). Tất cả đều bị xóa
trong ZZ0001ZZ. Các tệp phù hợp với mẫu ZZ0002ZZ, ZZ0003ZZ, plus
một số tệp bổ sung được tạo bởi kbuild sẽ bị xóa trên kernel
cây nguồn khi ZZ0004ZZ được thực thi.

Các tập tin hoặc thư mục bổ sung có thể được chỉ định trong kbuild makefiles bằng cách sử dụng
$(tập tin sạch).

Ví dụ::

#lib/Tệp tạo
  tập tin sạch := crc32table.h

Khi thực thi ZZ0000ZZ, tệp ZZ0001ZZ sẽ bị xóa.
Kbuild sẽ giả sử các tệp nằm trong cùng thư mục tương đối với
Makefile.

Để loại trừ một số tập tin hoặc thư mục nhất định khỏi quá trình làm sạch, hãy sử dụng lệnh
Biến $(no-clean-files).

Thông thường kbuild đi xuống các thư mục con do ZZ0000ZZ,
nhưng trong các tệp kiến trúc nơi cơ sở hạ tầng kbuild
là chưa đủ, điều này đôi khi cần phải rõ ràng.

Ví dụ::

#arch/x86/boot/Makefile
  thư mục con- := đã nén

Nhiệm vụ trên hướng dẫn kbuild đi xuống
thư mục được nén/ khi ZZ0000ZZ được thực thi.

Lưu ý 1: Arch/$(SRCARCH)/Makefile không thể sử dụng ZZ0000ZZ, vì tệp đó là
được bao gồm trong makefile cấp cao nhất. Thay vào đó, Arch/$(SRCARCH)/Kbuild có thể sử dụng
ZZ0001ZZ.

Lưu ý 2: Tất cả các thư mục được liệt kê trong core-y, libs-y, driver-y và net-y sẽ
được ghé thăm trong ZZ0000ZZ.

Tệp kiến ​​trúc
======================

Makefile cấp cao nhất thiết lập môi trường và thực hiện việc chuẩn bị,
trước khi bắt đầu đi xuống các thư mục riêng lẻ.

Tệp makefile cấp cao nhất chứa phần chung, trong khi
Arch/$(SRCARCH)/Makefile chứa những gì cần thiết để thiết lập kbuild
cho kiến trúc nói trên.

Để làm như vậy, Arch/$(SRCARCH)/Makefile thiết lập một số biến và xác định
một số mục tiêu.

Khi kbuild thực thi, các bước sau sẽ được thực hiện (đại khái):

1) Cấu hình kernel => tạo .config

2) Lưu trữ phiên bản kernel trong include/linux/version.h

3) Cập nhật tất cả các điều kiện tiên quyết khác để chuẩn bị mục tiêu:

- Các điều kiện tiên quyết bổ sung được chỉ định trong Arch/$(SRCARCH)/Makefile

4) Đệ quy đi xuống trong tất cả các thư mục được liệt kê trong
   init-* core* driver-* net-* libs-* và xây dựng tất cả các mục tiêu.

- Giá trị của các biến trên được mở rộng trong Arch/$(SRCARCH)/Makefile.

5) Sau đó, tất cả các tệp đối tượng được liên kết và tệp kết quả vmlinux là
   nằm ở gốc của cây obj.
   Các đối tượng đầu tiên được liên kết được liệt kê trong scripts/head-object-list.txt.

6) Cuối cùng, phần kiến trúc cụ thể sẽ thực hiện bất kỳ quá trình xử lý hậu kỳ cần thiết nào
   và xây dựng hình ảnh khởi động cuối cùng.

- Điều này bao gồm các bản ghi khởi động của tòa nhà
   - Chuẩn bị hình ảnh initrd và những thứ tương tự

Đặt các biến để điều chỉnh bản dựng theo kiến ​​trúc
----------------------------------------------------

KBUILD_LDFLAGS
  Tùy chọn $(LD) chung

Cờ được sử dụng cho tất cả các lệnh gọi của trình liên kết.
  Thường chỉ định mô phỏng là đủ.

Ví dụ::

#arch/s390/Tập tin tạo
    KBUILD_LDFLAGS := -m elf_s390

Lưu ý: ldflags-y có thể được sử dụng để tùy chỉnh thêm
  những lá cờ được sử dụng. Xem ZZ0000ZZ.

LDFLAGS_vmlinux
  Tùy chọn cho $(LD) khi liên kết vmlinux

LDFLAGS_vmlinux được sử dụng để chỉ định các cờ bổ sung cần chuyển tới
  trình liên kết khi liên kết hình ảnh vmlinux cuối cùng.

LDFLAGS_vmlinux sử dụng hỗ trợ LDFLAGS_$@.

Ví dụ::

#arch/x86/Tệp tạo
    LDFLAGS_vmlinux := -e stext

OBJCOPYFLAGS
  cờ đối tượng

Khi $(call if_changed,objcopy) được sử dụng để dịch tệp .o,
  các cờ được chỉ định trong OBJCOPYFLAGS sẽ được sử dụng.

$(call if_changed,objcopy) thường được sử dụng để tạo các tệp nhị phân thô trên
  vmlinux.

Ví dụ::

#arch/s390/Tập tin tạo
    OBJCOPYFLAGS := -O nhị phân

#arch/s390/boot/Makefile
    $(obj)/hình ảnh: vmlinux FORCE
            $(gọi if_changed,objcopy)

Trong ví dụ này, $(obj)/image nhị phân là phiên bản nhị phân của
  vmlinux. Việc sử dụng $(call if_changed,xxx) sẽ được mô tả sau.

KBUILD_AFLAGS
  Cờ lắp ráp

Giá trị mặc định - xem Makefile cấp cao nhất.

Nối thêm hoặc sửa đổi theo yêu cầu của mỗi kiến ​​trúc.

Ví dụ::

#arch/sparc64/Makefile
    KBUILD_AFLAGS += -m64 -mcpu=ultrasparc

KBUILD_CFLAGS
  Cờ trình biên dịch $(CC)

Giá trị mặc định - xem Makefile cấp cao nhất.

Nối thêm hoặc sửa đổi theo yêu cầu của mỗi kiến ​​trúc.

Thông thường, biến KBUILD_CFLAGS phụ thuộc vào cấu hình.

Ví dụ::

#arch/x86/boot/nén/Makefile
    cflags-$(CONFIG_X86_32) := -march=i386
    cflags-$(CONFIG_X86_64) := -mcmodel=small
    KBUILD_CFLAGS += $(cflags-y)

Nhiều Makefiles Arch tự động chạy trình biên dịch C đích để
  tùy chọn hỗ trợ thăm dò::

#arch/x86/Tệp tạo

    ...
cflags-$(CONFIG_MPENTIUMII) += $(gọi cc-option,\
						-march=pentium2,-march=i686)
    ...
Chế độ đơn vị tại một thời điểm # Disable ...
    KBUILD_CFLAGS += $(gọi cc-option,-fno-unit-at-a-time)
    ...


Ví dụ đầu tiên sử dụng thủ thuật mà tùy chọn cấu hình mở rộng
  thành "y" khi được chọn.

KBUILD_RUSTFLAGS
  Cờ trình biên dịch $(RUSTC)

Giá trị mặc định - xem Makefile cấp cao nhất.

Nối thêm hoặc sửa đổi theo yêu cầu của mỗi kiến ​​trúc.

Thông thường, biến KBUILD_RUSTFLAGS phụ thuộc vào cấu hình.

Lưu ý rằng việc tạo tệp đặc tả mục tiêu (đối với ZZ0000ZZ)
  được xử lý trong ZZ0001ZZ.

KBUILD_AFLAGS_KERNEL
  Tùy chọn trình biên dịch cụ thể cho tích hợp sẵn

$(KBUILD_AFLAGS_KERNEL) chứa các cờ trình biên dịch C bổ sung được sử dụng để biên dịch
  mã hạt nhân thường trú.

KBUILD_AFLAGS_MODULE
  Tùy chọn trình biên dịch cụ thể cho các mô-đun

$(KBUILD_AFLAGS_MODULE) được sử dụng để thêm các tùy chọn dành riêng cho Arch
  được sử dụng cho bộ lắp ráp.

Từ dòng lệnh AFLAGS_MODULE sẽ được sử dụng (xem kbuild.rst).

KBUILD_CFLAGS_KERNEL
  Tùy chọn $(CC) dành riêng cho tích hợp sẵn

$(KBUILD_CFLAGS_KERNEL) chứa các cờ trình biên dịch C bổ sung được sử dụng để biên dịch
  mã hạt nhân thường trú.

KBUILD_CFLAGS_MODULE
  Tùy chọn cho $(CC) khi xây dựng mô-đun

$(KBUILD_CFLAGS_MODULE) được sử dụng để thêm các tùy chọn dành riêng cho Arch
  được sử dụng cho $(CC).

Từ dòng lệnh CFLAGS_MODULE sẽ được sử dụng (xem kbuild.rst).

KBUILD_RUSTFLAGS_KERNEL
  Tùy chọn $(RUSTC) dành riêng cho tích hợp sẵn

$(KBUILD_RUSTFLAGS_KERNEL) chứa các cờ biên dịch Rust bổ sung được sử dụng để
  biên dịch mã hạt nhân thường trú.

KBUILD_RUSTFLAGS_MODULE
  Tùy chọn cho $(RUSTC) khi xây dựng mô-đun

$(KBUILD_RUSTFLAGS_MODULE) được sử dụng để thêm các tùy chọn dành riêng cho Arch
  được sử dụng cho $(RUSTC).

Từ dòng lệnh RUSTFLAGS_MODULE sẽ được sử dụng (xem kbuild.rst).

KBUILD_LDFLAGS_MODULE
  Tùy chọn cho $(LD) khi liên kết các mô-đun

$(KBUILD_LDFLAGS_MODULE) được sử dụng để thêm các tùy chọn dành riêng cho Arch
  được sử dụng khi liên kết các mô-đun. Đây thường là một tập lệnh liên kết.

Từ dòng lệnh LDFLAGS_MODULE sẽ được sử dụng (xem kbuild.rst).

KBUILD_LDS
  Tập lệnh liên kết có đường dẫn đầy đủ. Được chỉ định bởi Makefile cấp cao nhất.

KBUILD_VMLINUX_OBJS
  Tất cả các tệp đối tượng cho vmlinux. Chúng được liên kết với vmlinux trong cùng một
  đặt hàng như được liệt kê trong KBUILD_VMLINUX_OBJS.

Các đối tượng được liệt kê trong scripts/head-object-list.txt là ngoại lệ;
  chúng được đặt trước các đối tượng khác.

KBUILD_VMLINUX_LIBS
  Tất cả các tệp .a ZZ0000ZZ cho vmlinux. KBUILD_VMLINUX_OBJS và
  KBUILD_VMLINUX_LIBS cùng nhau chỉ định tất cả các tệp đối tượng được sử dụng để
  liên kết vmlinux.

Thêm điều kiện tiên quyết vào tiêu đề
--------------------------------

Quy tắc Archheaders: được sử dụng để tạo các tệp tiêu đề
có thể được ZZ0000ZZ cài đặt vào không gian người dùng.

Nó được chạy trước ZZ0000ZZ khi chạy trên
bản thân kiến trúc.

Thêm điều kiện tiên quyết vào Archprepare
--------------------------------

Quy tắc Archprepare: được sử dụng để liệt kê các điều kiện tiên quyết cần phải có
được xây dựng trước khi bắt đầu đi xuống các thư mục con.

Điều này thường được sử dụng cho các tệp tiêu đề chứa hằng số trình biên dịch mã.

Ví dụ::

#arch/cánh tay/Tệp tạo
  Archprepare: công cụ trang điểm

Trong ví dụ này, maketools đích của tệp sẽ được xử lý
trước khi đi xuống các thư mục con.

Xem thêm chương XXX-TODO mô tả cách kbuild hỗ trợ
tạo tập tin tiêu đề bù đắp.

Liệt kê các thư mục cần truy cập khi đi xuống
-----------------------------------------

Arch Makefile hợp tác với Makefile hàng đầu để xác định các biến
trong đó chỉ định cách xây dựng tệp vmlinux.  Lưu ý rằng không có
phần dành riêng cho vòm tương ứng cho các mô-đun; xây dựng mô-đun
máy móc hoàn toàn độc lập với kiến trúc.

lõi-y, libs-y, trình điều khiển-y
  $(libs-y) liệt kê các thư mục nơi có thể đặt kho lưu trữ lib.a.

Các thư mục danh sách còn lại có thể chứa tệp đối tượng tích hợp.a
  nằm.

Sau đó, phần còn lại theo thứ tự này:

$(core-y), $(libs-y), $(drivers-y)

Makefile cấp cao nhất xác định các giá trị cho tất cả các thư mục chung,
  và Arch/$(SRCARCH)/Makefile chỉ thêm kiến ​​trúc cụ thể
  thư mục.

Ví dụ::

# arch/sparc/Makefile
    core-y += Arch/sparc/

libs-y += Arch/sparc/prom/
    libs-y += Arch/sparc/lib/

trình điều khiển-$(CONFIG_PM) += Arch/sparc/power/

Hình ảnh khởi động dành riêng cho kiến ​​trúc
---------------------------------

Arch Makefile chỉ định các mục tiêu lấy tệp vmlinux, nén
nó, bọc nó trong mã khởi động và sao chép các tệp kết quả
ở đâu đó. Điều này bao gồm nhiều loại lệnh cài đặt.
Các mục tiêu thực tế không được chuẩn hóa trên các kiến ​​trúc.

Người ta thường định vị bất kỳ quá trình xử lý bổ sung nào trong boot/
thư mục bên dưới Arch/$(SRCARCH)/.

Kbuild không cung cấp bất kỳ cách thông minh nào để hỗ trợ xây dựng
mục tiêu được chỉ định trong boot/. Do đó, Arch/$(SRCARCH)/Makefile sẽ
gọi make theo cách thủ công để xây dựng mục tiêu trong boot/.

Cách tiếp cận được đề xuất là bao gồm các phím tắt trong
Arch/$(SRCARCH)/Makefile và sử dụng đường dẫn đầy đủ khi gọi xuống
vào Arch/$(SRCARCH)/boot/Makefile.

Ví dụ::

#arch/x86/Tệp tạo
  khởi động := Arch/x86/khởi động
  bzHình ảnh: vmlinux
          $(Q)$(MAKE) $(build)=$(boot) $(boot)/$@

ZZ0000ZZ là cách được khuyến nghị để gọi
tạo trong một thư mục con.

Không có quy tắc nào để đặt tên cho các mục tiêu cụ thể theo kiến trúc,
nhưng việc thực thi ZZ0000ZZ sẽ liệt kê tất cả các mục tiêu có liên quan.
Để hỗ trợ điều này, $(archhelp) phải được xác định.

Ví dụ::

#arch/x86/Tệp tạo
  xác định trợ giúp
    echo '* bzImage - Hình ảnh hạt nhân được nén (arch/x86/boot/bzImage)'
  cuối cùng

Khi thực hiện lệnh make mà không có đối số, mục tiêu đầu tiên gặp phải
sẽ được xây dựng. Trong Makefile cấp cao nhất, mục tiêu đầu tiên hiện diện
là tất cả:.

Theo mặc định, một kiến ​​trúc sẽ luôn xây dựng một image có khả năng khởi động.
Trong ZZ0000ZZ, mục tiêu mặc định được đánh dấu bằng ZZ0001ZZ.

Thêm một điều kiện tiên quyết mới cho tất cả: chọn một mục tiêu mặc định khác
từ vmlinux.

Ví dụ::

#arch/x86/Tệp tạo
  tất cả: bzImage

Khi ZZ0000ZZ được thực thi mà không có đối số, bzImage sẽ được tạo.

Các lệnh hữu ích để xây dựng boot image
-----------------------------------------

Kbuild cung cấp một số macro hữu ích khi xây dựng một
hình ảnh khởi động.

ld
  Mục tiêu liên kết. Thông thường, LDFLAGS_$@ được sử dụng để đặt các tùy chọn cụ thể thành ld.

Ví dụ::

#arch/x86/boot/Makefile
    LDFLAGS_bootsect := -Ttext 0x0 -s --oformat nhị phân
    LDFLAGS_setup := -Ttext 0x0 -s --oformat nhị phân -e begtext

mục tiêu += thiết lập setup.o bootect bootect.o
    $(obj)/setup $(obj)/bootsect: %: %.o FORCE
            $(gọi if_changed,ld)

Trong ví dụ này, có hai mục tiêu có thể xảy ra, yêu cầu các mục tiêu khác nhau.
  tùy chọn cho trình liên kết. Các tùy chọn trình liên kết được chỉ định bằng cách sử dụng
  Cú pháp LDFLAGS_$@ - một cho mỗi mục tiêu tiềm năng.

$(targets) được chỉ định tất cả các mục tiêu tiềm năng, qua đó kbuild biết
  mục tiêu và ý muốn:

1) kiểm tra các thay đổi dòng lệnh
  2) xóa mục tiêu trong quá trình làm sạch

Phần ZZ0000ZZ của điều kiện tiên quyết là một cách viết tắt
  giải phóng chúng tôi khỏi việc liệt kê các tệp setup.o và bootect.o.

Lưu ý:
  Việc quên bài tập ZZ0000ZZ là một lỗi phổ biến,
  dẫn đến tệp mục tiêu được biên dịch lại mà không có
  lý do rõ ràng.

bản sao
  Sao chép nhị phân. Sử dụng OBJCOPYFLAGS thường được chỉ định trong
  Arch/$(SRCARCH)/Makefile.

OBJCOPYFLAGS_$@ có thể được sử dụng để đặt các tùy chọn bổ sung.

gzip
  Nén mục tiêu. Sử dụng nén tối đa để nén mục tiêu.

Ví dụ::

#arch/x86/boot/nén/Makefile
    $(obj)/vmlinux.bin.gz: $(vmlinux.bin.all-y) FORCE
            $(gọi if_changed,gzip)

dtc
  Tạo đối tượng blob cây thiết bị phẳng phù hợp để liên kết
  vào vmlinux. Các đốm màu cây thiết bị được liên kết vào vmlinux được đặt
  trong phần init trong hình ảnh. Mã nền tảng ZZ0000ZZ sao chép
  blob vào bộ nhớ không khởi tạo trước khi gọi unflatten_device_tree().

Để sử dụng lệnh này, chỉ cần thêm ZZ0000ZZ vào obj-y hoặc mục tiêu hoặc tạo
  một số mục tiêu khác phụ thuộc vào ZZ0001ZZ

Một quy tắc trung tâm tồn tại để tạo ZZ0000ZZ từ ZZ0001ZZ;
  kiến trúc Makefiles không cần phải viết ra quy tắc đó một cách rõ ràng.

Ví dụ::

mục tiêu += $(dtb-y)
    DTC_FLAGS ?= -p 1024

Tiền xử lý các tập lệnh liên kết
----------------------------

Khi hình ảnh vmlinux được tạo, tập lệnh liên kết
Arch/$(SRCARCH)/kernel/vmlinux.lds được sử dụng.

Tập lệnh là một biến thể được xử lý trước của tệp vmlinux.lds.S
nằm trong cùng một thư mục.

kbuild biết các tệp .lds và bao gồm quy tắc ZZ0000ZZ -> ZZ0001ZZ.

Ví dụ::

#arch/x86/kernel/Makefile
  thêm-y := vmlinux.lds

Việc gán cho extra-y được sử dụng để yêu cầu kbuild xây dựng
nhắm mục tiêu vmlinux.lds.

Việc gán cho $(CPPFLAGS_vmlinux.lds) yêu cầu kbuild sử dụng
các tùy chọn được chỉ định khi xây dựng vmlinux.lds đích.

Khi xây dựng mục tiêu ZZ0000ZZ, kbuild sử dụng các biến::

KBUILD_CPPFLAGS : Đặt trong Makefile cấp cao nhất
  cppflags-y : Có thể được đặt trong tệp thực hiện kbuild
  CPPFLAGS_$(@F) : Cờ dành riêng cho mục tiêu.
                         Lưu ý rằng tên tập tin đầy đủ được sử dụng trong này
                         nhiệm vụ.

Cơ sở hạ tầng kbuild cho các tệp ZZ0000ZZ được sử dụng trong một số
tập tin kiến trúc cụ thể.

Tệp tiêu đề chung
--------------------

Thư mục include/asm-generic chứa các file header
có thể được chia sẻ giữa các kiến trúc riêng lẻ.

Cách tiếp cận được đề xuất để sử dụng tệp tiêu đề chung là
để liệt kê tệp trong tệp Kbuild.

Xem ZZ0000ZZ để biết thêm thông tin về cú pháp, v.v.

Thẻ sau liên kết
--------------

Nếu tệp Arch/xxx/Makefile.postlink tồn tại, tệp makefile này
sẽ được gọi cho các đối tượng liên kết sau (vmlinux và module.ko)
để các kiến trúc chạy các đường truyền liên kết sau. Cũng phải xử lý
mục tiêu sạch sẽ.

Đèo này chạy sau khi tạo kallsyms. Nếu kiến trúc
cần sửa đổi vị trí ký hiệu, thay vì thao tác
kallsyms, có thể dễ dàng hơn khi thêm mục tiêu liên kết bài đăng khác cho
.tmp_vmlinux? mục tiêu được gọi từ link-vmlinux.sh.

Ví dụ: powerpc sử dụng điều này để kiểm tra độ tỉnh táo của việc di chuyển
tệp vmlinux được liên kết.

Cú pháp Kbuild cho tiêu đề đã xuất
==================================

Hạt nhân bao gồm một tập hợp các tiêu đề được xuất sang không gian người dùng.
Nhiều tiêu đề có thể được xuất nguyên trạng nhưng các tiêu đề khác yêu cầu
xử lý trước tối thiểu trước khi chúng sẵn sàng cho không gian người dùng.

Quá trình xử lý trước thực hiện:

- bỏ các chú thích dành riêng cho kernel
- bỏ bao gồm trình biên dịch.h
- bỏ tất cả các phần bên trong kernel (được bảo vệ bởi ZZ0000ZZ)

Tất cả các tiêu đề bên dưới bao gồm/uapi/, bao gồm/được tạo/uapi/,
Arch/<arch>/include/uapi/ và Arch/<arch>/include/generated/uapi/
được xuất khẩu.

Tệp Kbuild có thể được xác định trong Arch/<arch>/include/uapi/asm/ và
Arch/<arch>/include/asm/ để liệt kê các tệp asm đến từ asm-generic.

Xem chương tiếp theo để biết cú pháp của tệp Kbuild.

tiêu đề không xuất
-----------------

tiêu đề không xuất khẩu về cơ bản được sử dụng bởi include/uapi/linux/Kbuild để
tránh xuất các tiêu đề cụ thể (ví dụ: kvm.h) trên các kiến trúc có
không hỗ trợ nó. Nó nên tránh càng nhiều càng tốt.

chung-y
---------

Nếu một kiến trúc sử dụng bản sao nguyên văn của tiêu đề từ
include/asm-generic thì cái này được liệt kê trong tệp
Arch/$(SRCARCH)/include/asm/Kbuild như thế này:

Ví dụ::

#arch/x86/bao gồm/asm/Kbuild
  generic-y += termios.h
  chung-y += rtc.h

Trong giai đoạn chuẩn bị của quá trình xây dựng, trình bao bọc bao gồm
tập tin được tạo trong thư mục::

Arch/$(SRCARCH)/bao gồm/được tạo/asm

Khi tiêu đề được xuất ở nơi kiến trúc sử dụng
tiêu đề chung, một trình bao bọc tương tự được tạo ra như một phần
của tập hợp các tiêu đề được xuất trong thư mục ::

usr/bao gồm/asm

Trình bao bọc được tạo trong cả hai trường hợp sẽ trông giống như sau:

Ví dụ: termios.h::

#include <asm-generic/termios.h>

tạo-y
-----------

Nếu một kiến trúc tạo ra các tệp tiêu đề khác cùng với generic-y
các hàm bao, được tạo-y chỉ định chúng.

Điều này ngăn chúng bị coi là các trình bao bọc chung asm cũ và
bị loại bỏ.

Ví dụ::

#arch/x86/bao gồm/asm/Kbuild
  được tạo-y += syscalls_32.h

bắt buộc-y
-----------

bắt buộc-y về cơ bản được sử dụng bởi include/(uapi/)asm-generic/Kbuild
để xác định bộ tiêu đề ASM tối thiểu mà tất cả các kiến trúc phải có.

Điều này hoạt động giống như generic-y tùy chọn. Nếu thiếu tiêu đề bắt buộc
trong Arch/$(SRCARCH)/include/(uapi/)/asm, Kbuild sẽ tự động
tạo một trình bao bọc của cái chung asm.

Biến Kbuild
================

Makefile hàng đầu xuất các biến sau:

VERSION, PATCHLEVEL, SUBLEVEL, EXTRAVERSION
  Các biến này xác định phiên bản kernel hiện tại.  Một vài vòm
  Makefiles thực sự sử dụng những giá trị này một cách trực tiếp; họ nên sử dụng
  $(KERNELRELEASE) thay vào đó.

$(VERSION), $(PATCHLEVEL) và $(SUBLEVEL) xác định cơ bản
  số phiên bản gồm ba phần, chẳng hạn như "2", "4" và "0".  Ba người này
  các giá trị luôn là số.

$(EXTRAVERSION) xác định một cấp độ con thậm chí còn nhỏ hơn cho các bản vá trước
  hoặc các bản vá bổ sung.	Nó thường là một chuỗi không phải số
  chẳng hạn như "-pre4" và thường để trống.

KERNELRELEASE
  $(KERNELRELEASE) là một chuỗi đơn như "2.4.0-pre4", phù hợp
  để xây dựng tên thư mục cài đặt hoặc hiển thị trong
  chuỗi phiên bản.  Một số Makefiles vòm sử dụng nó cho mục đích này.

ARCH
  Biến này xác định kiến trúc đích, chẳng hạn như "i386",
  "cánh tay" hoặc "sparc". Một số kbuild Makefiles kiểm tra $(ARCH) thành
  xác định tập tin nào cần biên dịch.

Theo mặc định, Makefile hàng đầu đặt $(ARCH) giống với
  kiến trúc hệ thống máy chủ.  Để xây dựng chéo, người dùng có thể
  ghi đè giá trị của $(ARCH) trên dòng lệnh ::

tạo ARCH=m68k ...

SRCARCH
  Biến này chỉ định thư mục trong Arch/ để build.

ARCH và SRCARCH có thể không nhất thiết phải khớp nhau. Một vài vòm
  các thư mục là biarch, nghĩa là một thư mục ZZ0000ZZ duy nhất hỗ trợ
  cả 32-bit và 64-bit.

Ví dụ: bạn có thể chuyển vào ARCH=i386, ARCH=x86_64 hoặc ARCH=x86.
  Đối với tất cả chúng, SRCARCH=x86 vì Arch/x86/ hỗ trợ cả i386 và
  x86_64.

INSTALL_PATH
  Biến này xác định vị trí để Arch Makefiles cài đặt
  hình ảnh hạt nhân thường trú và tệp System.map.
  Sử dụng điều này cho các mục tiêu cài đặt theo kiến ​​trúc cụ thể.

INSTALL_MOD_PATH, MODLIB
  $(INSTALL_MOD_PATH) chỉ định tiền tố cho $(MODLIB) cho mô-đun
  cài đặt.  Biến này không được xác định trong Makefile nhưng
  có thể được người dùng chuyển vào nếu muốn.

$(MODLIB) chỉ định thư mục để cài đặt mô-đun.
  Makefile hàng đầu định nghĩa $(MODLIB) thành
  $(INSTALL_MOD_PATH)/lib/modules/$(KERNELRELEASE).  Người dùng có thể
  ghi đè giá trị này trên dòng lệnh nếu muốn.

INSTALL_MOD_STRIP
  Nếu biến này được chỉ định, nó sẽ khiến các mô-đun bị loại bỏ
  sau khi chúng được cài đặt.  Nếu INSTALL_MOD_STRIP là "1", thì
  tùy chọn mặc định --strip-debug sẽ được sử dụng.  Nếu không,
  Giá trị INSTALL_MOD_STRIP sẽ được sử dụng làm (các) tùy chọn cho dải
  lệnh.

INSTALL_DTBS_PATH
  Biến này chỉ định tiền tố cho việc di chuyển theo yêu cầu của bản dựng
  rễ. Nó xác định một nơi để cài đặt các đốm màu cây thiết bị. thích
  INSTALL_MOD_PATH, nó không được xác định trong Makefile nhưng có thể được chuyển qua
  của người dùng nếu muốn. Nếu không thì nó mặc định là cài đặt kernel
  con đường.

Ngôn ngữ tạo tệp
=================

Kernel Makefiles được thiết kế để chạy với GNU Make.  Makefiles
chỉ sử dụng các tính năng được ghi lại của GNU Make, nhưng chúng sử dụng nhiều tính năng
Phần mở rộng GNU.

GNU Make hỗ trợ các chức năng xử lý danh sách cơ bản.  Hạt nhân
Makefiles sử dụng một phong cách mới để xây dựng và thao tác danh sách với một số ít
Báo cáo ZZ0000ZZ.

GNU Make có hai toán tử gán là ZZ0000ZZ và ZZ0001ZZ.  ZZ0002ZZ biểu diễn
đánh giá ngay lập tức phía bên phải và lưu trữ một chuỗi thực tế
vào phía bên tay trái.  ZZ0003ZZ giống như một định nghĩa công thức; nó lưu trữ
phía bên phải ở dạng chưa được đánh giá và sau đó đánh giá từng dạng này
thời điểm phía bên trái được sử dụng.

Có một số trường hợp ZZ0000ZZ phù hợp.  Tuy nhiên, thông thường, ZZ0001ZZ
là sự lựa chọn đúng đắn

Tín dụng
=======

- Phiên bản gốc được thực hiện bởi Michael Elizabeth Chastain, <mailto:mec@shout.net>
- Cập nhật của Kai Germaschewski <kai@tp1.ruhr-uni-bochum.de>
- Cập nhật bởi Sam Ravnborg <sam@ravnborg.org>
- Đảm bảo chất lượng ngôn ngữ của Jan Engelhardt <jengelh@gmx.de>

TODO
====

- Tạo tập tin tiêu đề offset.
- Thêm biến vào chương 7 hay 9?
