.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/modules.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Xây dựng các mô-đun bên ngoài
=============================

Tài liệu này mô tả cách xây dựng một mô-đun hạt nhân ngoài cây.

Giới thiệu
============

"kbuild" là hệ thống xây dựng được nhân Linux sử dụng. Các mô-đun phải sử dụng
kbuild để luôn tương thích với những thay đổi trong cơ sở hạ tầng xây dựng và
để nhận các cờ phù hợp cho trình biên dịch. Chức năng xây dựng module
cả trong cây và ngoài cây đều được cung cấp. Phương pháp xây dựng
hoặc là tương tự nhau và tất cả các mô-đun đều được phát triển và xây dựng ban đầu
ngoài cây.

Bao gồm trong tài liệu này là thông tin nhằm vào các nhà phát triển quan tâm
trong việc xây dựng các mô-đun ngoài cây (hoặc "bên ngoài"). Tác giả của một
mô-đun bên ngoài sẽ cung cấp một tệp thực hiện để ẩn hầu hết các
phức tạp nên người ta chỉ cần gõ "make" để xây dựng mô-đun. Đây là
dễ dàng thực hiện và một ví dụ đầy đủ sẽ được trình bày trong
phần ZZ0000ZZ.


Cách xây dựng mô-đun bên ngoài
=============================

Để xây dựng các mô-đun bên ngoài, bạn phải có sẵn kernel dựng sẵn
chứa các tệp cấu hình và tiêu đề được sử dụng trong bản dựng.
Ngoài ra, hạt nhân phải được xây dựng với các mô-đun được kích hoạt. Nếu bạn là
sử dụng kernel phân phối thì sẽ có một gói dành cho kernel mà bạn
đang chạy do bản phân phối của bạn cung cấp.

Một cách khác là sử dụng mục tiêu "make" "modules_prepare." Điều này sẽ
đảm bảo kernel chứa thông tin cần thiết. mục tiêu
chỉ tồn tại như một cách đơn giản để chuẩn bị cây nguồn hạt nhân cho
xây dựng các module bên ngoài.

NOTE: "modules_prepare" sẽ không xây dựng Module.symvers ngay cả khi
CONFIG_MODVERSIONS được đặt; do đó, cần phải có một bản dựng kernel đầy đủ
được thực thi để làm cho việc lập phiên bản mô-đun hoạt động.

Cú pháp lệnh
--------------

Lệnh để xây dựng một mô-đun bên ngoài là::

$ tạo -C <path_to_kernel_dir> M=$PWD

Hệ thống kbuild biết rằng một mô-đun bên ngoài đang được xây dựng
	do tùy chọn "M=<dir>" được đưa ra trong lệnh.

Để xây dựng dựa trên kernel đang chạy, hãy sử dụng ::

$ make -C /lib/modules/ZZ0000ZZ/build M=$PWD

Sau đó, để cài đặt (các) mô-đun vừa tạo, hãy thêm mục tiêu
	"modules_install" vào lệnh::

$ make -C /lib/modules/ZZ0000ZZ/build M=$PWD module_install

Bắt đầu từ Linux 6.13, bạn có thể sử dụng tùy chọn -f thay vì -C. Cái này
	sẽ tránh được sự thay đổi không cần thiết của thư mục làm việc. Bên ngoài
	mô-đun sẽ được xuất ra thư mục nơi bạn gọi make.

$ make -f /lib/modules/ZZ0000ZZ/build/Makefile M=$PWD

Tùy chọn
-------

($KDIR đề cập đến đường dẫn của thư mục nguồn kernel hoặc đường dẫn
	của thư mục đầu ra kernel nếu kernel được xây dựng trong một thư mục riêng
	xây dựng thư mục.)

Bạn có thể tùy ý chuyển tùy chọn MO= nếu bạn muốn xây dựng các mô-đun trong
	một thư mục riêng.

tạo -C $KDIR M=$PWD [MO=$BUILD_DIR]

-C $KDIR
		Thư mục chứa kernel và bản dựng có liên quan
		các tạo tác được sử dụng để xây dựng một mô-đun bên ngoài.
		"make" sẽ thực sự thay đổi vào thư mục được chỉ định
		khi thực hiện và sẽ thay đổi trở lại khi hoàn thành.

M=$PWD
		Thông báo cho kbuild rằng một mô-đun bên ngoài đang được xây dựng.
		Giá trị được gán cho "M" là đường dẫn tuyệt đối của
		thư mục chứa mô-đun bên ngoài (tệp kbuild)
		nằm.

MO=$BUILD_DIR
		Chỉ định một thư mục đầu ra riêng cho mô-đun bên ngoài.

Mục tiêu
-------

Khi xây dựng một mô-đun bên ngoài, chỉ một tập hợp con của "make"
	mục tiêu đã có sẵn.

tạo -C $KDIR M=$PWD [mục tiêu]

Mặc định sẽ xây dựng (các) mô-đun nằm trong
	thư mục, do đó không cần phải chỉ định mục tiêu. Tất cả
	các tập tin đầu ra cũng sẽ được tạo trong thư mục này. Không
	những nỗ lực được thực hiện để cập nhật nguồn kernel và đó là một
	với điều kiện là việc "làm" thành công đã được thực hiện cho
	hạt nhân.

mô-đun
		Mục tiêu mặc định cho các mô-đun bên ngoài. Nó có
		chức năng tương tự như thể không có mục tiêu nào được chỉ định. Xem
		mô tả ở trên.

mô-đun_cài đặt
		Cài đặt (các) mô-đun bên ngoài. Vị trí mặc định là
		/lib/modules/<kernel_release>/updates/, nhưng tiền tố có thể
		được thêm vào INSTALL_MOD_PATH (được thảo luận trong phần
		ZZ0000ZZ).

sạch sẽ
		Chỉ xóa tất cả các tệp được tạo trong thư mục mô-đun.

giúp đỡ
		Liệt kê các mục tiêu có sẵn cho các mô-đun bên ngoài.

Xây dựng các tập tin riêng biệt
-----------------------

Có thể xây dựng các tệp đơn lẻ là một phần của mô-đun.
	Điều này hoạt động tốt như nhau đối với kernel, mô-đun và thậm chí đối với
	các mô-đun bên ngoài.

Ví dụ (Mô-đun foo.ko, bao gồm bar.o và baz.o)::

tạo -C $KDIR M=$PWD bar.lst
		tạo -C $KDIR M=$PWD baz.o
		tạo -C $KDIR M=$PWD foo.ko
		tạo -C $KDIR M=$PWD ./


Tạo tệp Kbuild cho mô-đun bên ngoài
=============================================

Trong phần trước chúng ta đã thấy lệnh xây dựng một mô-đun cho
chạy hạt nhân. Tuy nhiên, mô-đun này không thực sự được xây dựng bởi vì một
tập tin xây dựng là bắt buộc. Chứa trong tập tin này sẽ là tên của
(các) mô-đun đang được xây dựng, cùng với danh sách nguồn cần thiết
tập tin. Tệp có thể đơn giản như một dòng duy nhất ::

obj-m := <module_name>.o

Hệ thống kbuild sẽ xây dựng <module_name>.o từ <module_name>.c,
và sau khi liên kết sẽ tạo ra mô-đun hạt nhân <module_name>.ko.
Dòng trên có thể được đặt trong tệp "Kbuild" hoặc "Makefile."
Khi mô-đun được xây dựng từ nhiều nguồn, một dòng bổ sung sẽ được
cần liệt kê các tập tin::

<module_name>-y := <src1>.o <src2>.o ...

NOTE: Tài liệu bổ sung mô tả cú pháp được sử dụng bởi kbuild là
nằm trong Tài liệu/kbuild/makefiles.rst.

Các ví dụ dưới đây minh họa cách tạo tệp xây dựng cho
mô-đun 8123.ko, được xây dựng từ các tệp sau::

8123_if.c
	8123_if.h
	8123_pci.c

Tệp tạo tệp được chia sẻ
---------------

Một mô-đun bên ngoài luôn bao gồm một tệp thực hiện bao bọc
	hỗ trợ xây dựng mô-đun bằng cách sử dụng "make" không có đối số.
	Mục tiêu này không được kbuild sử dụng; nó chỉ để thuận tiện.
	Chức năng bổ sung, chẳng hạn như mục tiêu thử nghiệm, có thể được bao gồm
	nhưng nên được lọc khỏi kbuild do có thể có tên
	xung đột.

Ví dụ 1::

--> tên tập tin: Makefile
		ifneq ($(KERNELRELEASE),)
		# kbuild một phần của tệp thực hiện
		obj-m := 8123.o
		8123-y := 8123_if.o 8123_pci.o

khác
		Tệp tạo # normal
		KDIR ?= /lib/modules/ZZ0000ZZ/build

mặc định:
			$(MAKE) -C $(KDIR) M=$$PWD

cuối cùng

Việc kiểm tra KERNELRELEASE được sử dụng để tách hai phần
	của tệp thực hiện. Trong ví dụ, kbuild sẽ chỉ nhìn thấy hai
	bài tập, trong khi "make" sẽ thấy mọi thứ ngoại trừ những bài tập này
	hai nhiệm vụ. Điều này là do hai lần chuyển được thực hiện trên tệp:
	lần vượt qua đầu tiên là do cá thể "thực hiện" chạy trên lệnh
	dòng; đường chuyền thứ hai là bởi hệ thống kbuild, đó là
	được bắt đầu bởi "make" được tham số hóa trong mục tiêu mặc định.

Tách tệp Kbuild và Makefile
---------------------------------

Đầu tiên Kbuild sẽ tìm file có tên "Kbuild", nếu không có thì
	được tìm thấy, sau đó nó sẽ tìm kiếm "Makefile". Sử dụng tệp "Kbuild"
	cho phép chúng tôi chia "Makefile" từ ví dụ 1 thành hai tệp:

Ví dụ 2::

--> tên file: Kbuild
		obj-m := 8123.o
		8123-y := 8123_if.o 8123_pci.o

--> tên tập tin: Makefile
		KDIR ?= /lib/modules/ZZ0000ZZ/build

mặc định:
			$(MAKE) -C $(KDIR) M=$$PWD

Sự phân chia trong ví dụ 2 có vấn đề do tính đơn giản của
	mỗi tập tin; tuy nhiên, một số mô-đun bên ngoài sử dụng tệp tạo tệp
	bao gồm vài trăm dòng, và ở đây nó thực sự mang lại lợi ích
	off để tách phần kbuild khỏi phần còn lại.

Linux 6.13 trở lên hỗ trợ theo cách khác. Mô-đun bên ngoài Makefile
	có thể bao gồm trực tiếp kernel Makefile, thay vì gọi sub Make.

Ví dụ 3::

--> tên file: Kbuild
		obj-m := 8123.o
		8123-y := 8123_if.o 8123_pci.o

--> tên tập tin: Makefile
		KDIR ?= /lib/modules/$(shell uname -r)/build
		xuất KBUILD_EXTMOD := $(realpath $(dir $(lastword $(MAKEFILE_LIST))))
		bao gồm $(KDIR)/Makefile


Xây dựng nhiều mô-đun
-------------------------

kbuild hỗ trợ xây dựng nhiều mô-đun với một bản dựng duy nhất
	tập tin. Ví dụ: nếu bạn muốn xây dựng hai mô-đun, foo.ko
	và bar.ko, các dòng kbuild sẽ là::

obj-m := foo.o bar.o
		foo-y := <foo_srcs>
		bar-y := <bar_srcs>

Nó thật đơn giản!


Bao gồm các tệp
=============

Trong hạt nhân, các tệp tiêu đề được lưu giữ ở các vị trí tiêu chuẩn
theo quy tắc sau:

* Nếu tệp tiêu đề chỉ mô tả giao diện bên trong của một
	  mô-đun, thì tệp sẽ được đặt trong cùng thư mục với
	  các tập tin nguồn.
	* Nếu tệp tiêu đề mô tả giao diện được sử dụng bởi các phần khác
	  của kernel nằm trong các thư mục khác nhau, sau đó
	  tập tin được đặt trong include/linux/.

NOTE:
	      Có hai trường hợp ngoại lệ đáng chú ý đối với quy tắc này: lớn hơn
	      các hệ thống con có thư mục riêng trong include/, chẳng hạn như
	      bao gồm/scsi; và các tiêu đề cụ thể về kiến trúc được đặt
	      dưới Arch/$(SRCARCH)/include/.

Hạt nhân bao gồm
---------------

Để bao gồm một tệp tiêu đề nằm trong include/linux/, chỉ cần
	sử dụng::

#include <linux/module.h>

kbuild sẽ thêm các tùy chọn vào trình biên dịch để các thư mục liên quan
	được tìm kiếm.

Thư mục con đơn
-------------------

Các mô-đun bên ngoài có xu hướng đặt các tệp tiêu đề ở một nơi riêng biệt
	include/ thư mục chứa nguồn của chúng, mặc dù điều này
	không phải là kiểu kernel thông thường. Để thông báo cho kbuild về
	thư mục, hãy sử dụng ccflags-y hoặc CFLAGS_<filename>.o.

Sử dụng ví dụ ở phần 3, nếu chúng ta chuyển 8123_if.h sang một
	thư mục con có tên bao gồm, tệp kbuild kết quả sẽ
	trông giống như::

--> tên file: Kbuild
		obj-m := 8123.o

ccflags-y := -I $(src)/include
		8123-y := 8123_if.o 8123_pci.o

Một số thư mục con
----------------------

kbuild có thể xử lý các tệp nằm rải rác trên nhiều thư mục.
	Hãy xem xét ví dụ sau::

.
		|__ src
		ZZ0000ZZ__ phức tạp_main.c
		ZZ0001ZZ__ nửa
		Phần cứng ZZ0002ZZ__if.c
		ZZ0003ZZ__ bao gồm
		Phần cứng ZZ0004ZZ__if.h
		|__ bao gồm
			|__ phức tạp.h

Để xây dựng mô-đun complex.ko, chúng ta cần những thứ sau
	tập tin kbuild::

--> tên file: Kbuild
		obj-m := phức tạp.o
		phức tạp-y := src/complex_main.o
		phức tạp-y += src/hal/hardwareif.o

ccflags-y := -I$(src)/include
		ccflags-y += -I$(src)/src/hal/include

Như bạn có thể thấy, kbuild biết cách xử lý các tệp đối tượng nằm
	trong các thư mục khác. Bí quyết là chỉ định thư mục
	liên quan đến vị trí của tệp kbuild. That being said, this
	là phương pháp thực hành được khuyến nghị của NOT.

Đối với các tập tin tiêu đề, kbuild phải được chỉ rõ nơi để
	nhìn. Khi kbuild thực thi, thư mục hiện tại luôn là
	gốc của cây nhân (đối số là "-C") và do đó một
	đường dẫn tuyệt đối là cần thiết. $(src) cung cấp đường dẫn tuyệt đối bằng cách
	trỏ đến thư mục nơi kbuild hiện đang thực thi
	tập tin được định vị.


Cài đặt mô-đun
===================

Các mô-đun có trong kernel được cài đặt trong
thư mục:

/lib/modules/$(KERNELRELEASE)/kernel/

Và các mô-đun bên ngoài được cài đặt trong:

/lib/modules/$(KERNELRELEASE)/updates/

INSTALL_MOD_PATH
----------------

Trên đây là các thư mục mặc định nhưng cũng như mọi mức độ
	tùy biến là có thể. Tiền tố có thể được thêm vào
	đường dẫn cài đặt sử dụng biến INSTALL_MOD_PATH::

$ tạo INSTALL_MOD_PATH=/frodo module_install
		=> Thư mục cài đặt: /frodo/lib/modules/$(KERNELRELEASE)/kernel/

INSTALL_MOD_PATH có thể được đặt làm biến shell thông thường hoặc,
	như được hiển thị ở trên, có thể được chỉ định trên dòng lệnh khi
	gọi "làm." Điều này có hiệu lực khi cài đặt cả trong cây
	và các mô-đun ngoài cây.

INSTALL_MOD_DIR
---------------

Các mô-đun bên ngoài theo mặc định được cài đặt vào một thư mục bên dưới
	/lib/modules/$(KERNELRELEASE)/updates/, nhưng bạn có thể muốn
	định vị các mô-đun cho một chức năng cụ thể trong một khu vực riêng biệt
	thư mục. Với mục đích này, hãy sử dụng INSTALL_MOD_DIR để chỉ định một
	tên thay thế cho "cập nhật."::

$ tạo INSTALL_MOD_DIR=gandalf -C $KDIR \
		       M=$PWD module_install
		=> Thư mục cài đặt: /lib/modules/$(KERNELRELEASE)/gandalf/


Phiên bản mô-đun
=================

Phiên bản mô-đun được kích hoạt bởi thẻ CONFIG_MODVERSIONS và được sử dụng
như một kiểm tra tính nhất quán ABI đơn giản. Giá trị CRC của nguyên mẫu đầy đủ
cho một biểu tượng xuất khẩu được tạo ra. Khi một mô-đun được tải/sử dụng,
Các giá trị CRC chứa trong kernel được so sánh với các giá trị tương tự trong
mô-đun; nếu chúng không bằng nhau thì kernel sẽ từ chối tải
mô-đun.

Module.symvers chứa danh sách tất cả các ký hiệu được xuất từ kernel
xây dựng.

Các ký hiệu từ hạt nhân (vmlinux + mô-đun)
-------------------------------------------

Trong quá trình xây dựng kernel, một tệp có tên Module.symvers sẽ được
	được tạo ra. Module.symvers chứa tất cả các ký hiệu được xuất từ ​​
	hạt nhân và các mô-đun được biên dịch. Đối với mỗi ký hiệu,
	giá trị CRC tương ứng cũng được lưu trữ.

Cú pháp của tệp Module.symvers là::

<CRC> <Ký hiệu> <Mô-đun> <Loại xuất> <Không gian tên>

0xe1cc2a05 trình điều khiển usb_stor_suspend/usb/storage/usb-storage EXPORT_SYMBOL_GPL USB_STORAGE

Các trường được phân tách bằng tab và các giá trị có thể trống (ví dụ:
	nếu không có không gian tên nào được xác định cho ký hiệu được xuất).

Đối với bản dựng kernel không kích hoạt CONFIG_MODVERSIONS, CRC
	sẽ đọc 0x00000000.

Module.symvers phục vụ hai mục đích:

1) Nó liệt kê tất cả các ký hiệu được xuất từ ​​vmlinux và tất cả các mô-đun.
	2) Nó liệt kê CRC nếu CONFIG_MODVERSIONS được bật.

Định dạng thông tin phiên bản
---------------------------

Các ký hiệu được xuất có thông tin được lưu trữ trong __ksymtab và
	__ phần kflagstab. Tên biểu tượng và không gian tên được lưu trữ trong
	Phần __ksymtab_strings, sử dụng định dạng tương tự như chuỗi
	bảng được sử dụng cho ELF. Nếu CONFIG_MODVERSIONS được bật, CRC
	tương ứng với các ký hiệu đã xuất sẽ được thêm vào
	__kcrctab phần.

Nếu CONFIG_BASIC_MODVERSIONS được bật (mặc định với
	CONFIG_MODVERSIONS), các biểu tượng được nhập sẽ có tên biểu tượng và
	CRC được lưu trữ trong phần __versions của mô-đun nhập. Cái này
	chế độ chỉ hỗ trợ các ký hiệu có độ dài tối đa 64 byte.

Nếu CONFIG_EXTENDED_MODVERSIONS được bật (bắt buộc phải bật cả hai
	CONFIG_MODVERSIONS và CONFIG_RUST cùng lúc), ký hiệu được nhập khẩu
	sẽ có tên biểu tượng của họ được ghi lại trong __version_ext_names
	phần dưới dạng một chuỗi các chuỗi được nối với nhau, kết thúc bằng null. CRC dành cho
	những ký hiệu này sẽ được ghi lại trong phần __version_ext_crcs.

Biểu tượng và mô-đun bên ngoài
----------------------------

Khi xây dựng một mô-đun bên ngoài, hệ thống xây dựng cần có quyền truy cập
	vào các ký hiệu từ kernel để kiểm tra xem tất cả các ký hiệu bên ngoài có
	được xác định. Điều này được thực hiện ở bước MODPOST. modpost có được
	các ký hiệu bằng cách đọc Module.symvers từ nguồn kernel
	cây. Trong bước MODPOST, một tệp Module.symvers mới sẽ được
	được viết có chứa tất cả các ký hiệu được xuất từ mô-đun bên ngoài đó.

Ký hiệu từ một mô-đun bên ngoài khác
------------------------------------

Đôi khi, một mô-đun bên ngoài sử dụng các ký hiệu được xuất từ
	một mô-đun bên ngoài khác. Kbuild cần có đầy đủ kiến thức về
	tất cả các ký hiệu để tránh đưa ra cảnh báo về việc không xác định
	biểu tượng. Có hai giải pháp cho tình huống này.

NOTE: Nên sử dụng phương pháp có tệp kbuild cấp cao nhất
	nhưng có thể không thực tế trong một số trường hợp nhất định.

Sử dụng tệp kbuild cấp cao nhất
		Nếu bạn có hai mô-đun, foo.ko và bar.ko, ở đâu
		foo.ko cần các ký hiệu từ bar.ko, bạn có thể sử dụng
		tệp kbuild cấp cao nhất phổ biến nên cả hai mô-đun đều
		được biên dịch trong cùng một bản dựng. Hãy xem xét những điều sau đây
		bố cục thư mục::

./foo/ <= chứa foo.ko
			./bar/ <= chứa bar.ko

Khi đó, tệp kbuild cấp cao nhất sẽ có dạng::

#./Kbuild (hoặc ./Makefile):
				obj-m := foo/ bar/

Và thực hiện::

$ tạo -C $KDIR M=$PWD

sau đó sẽ thực hiện dự kiến và biên dịch cả hai mô-đun với
		kiến thức đầy đủ về các ký hiệu từ một trong hai mô-đun.

Sử dụng biến "tạo" KBUILD_EXTRA_SYMBOLS
		Nếu việc thêm tệp kbuild cấp cao nhất là không thực tế,
		bạn có thể chỉ định một danh sách được phân tách bằng dấu cách
		của các tệp vào KBUILD_EXTRA_SYMBOLS trong tệp bản dựng của bạn.
		Những tập tin này sẽ được tải bởi modpost trong quá trình
		khởi tạo các bảng ký hiệu của nó.


Mẹo & thủ thuật
=============

Đang thử nghiệm CONFIG_FOO_BAR
--------------------------

Các mô-đun thường cần kiểm tra các tùy chọn ZZ0000ZZ nhất định để
	quyết định xem một tính năng cụ thể có được đưa vào mô-đun hay không. trong
	kbuild việc này được thực hiện bằng cách tham chiếu biến ZZ0001ZZ
	trực tiếp::

#fs/ext2/Makefile
		obj-$(CONFIG_EXT2_FS) += ext2.o

ext2-y := balloc.o bitmap.o dir.o
		ext2-$(CONFIG_EXT2_FS_XATTR) += xattr.o
