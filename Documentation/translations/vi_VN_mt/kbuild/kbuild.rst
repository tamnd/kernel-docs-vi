.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/kbuild.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
Kbuild
======


Tập tin đầu ra
==============

module.order
-------------
Tệp này ghi lại thứ tự các mô-đun xuất hiện trong Makefiles. Cái này
được modprobe sử dụng để giải quyết một cách xác định các bí danh phù hợp
nhiều mô-đun.

mô-đun.buildin
---------------
Tệp này liệt kê tất cả các mô-đun được tích hợp vào kernel. Cái này được sử dụng
bằng modprobe để không bị lỗi khi cố tải nội dung nào đó được tích hợp sẵn.

mô-đun.buildin.modinfo
-----------------------
Tệp này chứa modinfo từ tất cả các mô-đun được tích hợp vào kernel.
Không giống như modinfo của một mô-đun riêng biệt, tất cả các trường đều có tiền tố là tên mô-đun.

mô-đun.buildin.ranges
----------------------
Tệp này chứa các phạm vi bù địa chỉ (theo phần ELF) cho tất cả các mô-đun
được tích hợp vào kernel. Cùng với System.map, nó có thể được sử dụng
để liên kết tên mô-đun với các ký hiệu.

Biến môi trường
=====================

KCPPFLAGS
---------
Các tùy chọn bổ sung cần chuyển khi xử lý trước. Các tùy chọn tiền xử lý
sẽ được sử dụng trong mọi trường hợp kbuild thực hiện tiền xử lý bao gồm
xây dựng các tập tin C và các tập tin biên dịch mã.

KAFLAGS
-------
Các tùy chọn bổ sung cho trình biên dịch mã (đối với các mô-đun và phần mềm tích hợp).

AFLAGS_MODULE
-------------
Tùy chọn lắp ráp bổ sung cho các mô-đun.

AFLAGS_KERNEL
-------------
Tùy chọn lắp ráp bổ sung để tích hợp sẵn.

KCFLAGS
-------
Các tùy chọn bổ sung cho trình biên dịch C (dành cho mô-đun và mô-đun tích hợp).

KRUSTFLAGS
----------
Các tùy chọn bổ sung cho trình biên dịch Rust (dành cho mô-đun và mô-đun tích hợp).

CFLAGS_KERNEL
-------------
Các tùy chọn bổ sung cho $(CC) khi được sử dụng để biên dịch
mã được biên dịch dưới dạng tích hợp.

CFLAGS_MODULE
-------------
Các tùy chọn cụ thể của mô-đun bổ sung để sử dụng cho $(CC).

RUSTFLAGS_KERNEL
----------------
Các tùy chọn bổ sung cho $(RUSTC) khi được sử dụng để biên dịch
mã được biên dịch dưới dạng tích hợp.

RUSTFLAGS_MODULE
----------------
Các tùy chọn cụ thể của mô-đun bổ sung để sử dụng cho $(RUSTC).

LDFLAGS_MODULE
--------------
Các tùy chọn bổ sung được sử dụng cho $(LD) khi liên kết các mô-đun.

HOSTCFLAGS
----------
Các cờ bổ sung được chuyển tới $(HOSTCC) khi xây dựng chương trình máy chủ.

HOSTCXXFLAGS
------------
Các cờ bổ sung được chuyển tới $(HOSTCXX) khi xây dựng chương trình máy chủ.

HOSTRUSTFLAGS
-------------
Các cờ bổ sung được chuyển tới $(HOSTRUSTC) khi xây dựng chương trình máy chủ.

PROCMACROLDFLAGS
----------------
Cờ cần được chuyển khi liên kết macro Rust Proc. Vì macro proc được tải
bởi Rustc tại thời điểm xây dựng, chúng phải được liên kết theo cách tương thích với
chuỗi công cụ Rustc đang được sử dụng.

Ví dụ, nó có thể hữu ích khi Rustc sử dụng thư viện C khác với
cái mà người dùng muốn sử dụng cho các chương trình máy chủ.

Nếu không được đặt, nó sẽ mặc định chuyển sang các cờ khi liên kết các chương trình lưu trữ.

HOSTLDFLAGS
-----------
Các cờ bổ sung cần được thông qua khi liên kết các chương trình lưu trữ.

HOSTLDLIBS
----------
Thư viện bổ sung để liên kết khi xây dựng chương trình máy chủ.

.. _userkbuildflags:

USERCFLAGS
----------
Các tùy chọn bổ sung được sử dụng cho $(CC) khi biên dịch userprogs.

USERLDFLAGS
-----------
Các tùy chọn bổ sung được sử dụng cho $(LD) khi liên kết các chương trình người dùng. chương trình người dùng được liên kết
với CC, vì vậy $(USERLDFLAGS) phải bao gồm tiền tố "-Wl," nếu có.

KBUILD_KCONFIG
--------------
Đặt tệp Kconfig cấp cao nhất thành giá trị của môi trường này
biến.  Tên mặc định là "Kconfig".

KBUILD_VERBOSE
--------------
Đặt mức độ chi tiết của kbuild. Có thể được gán các giá trị giống như "V=...".

Xem phần trợ giúp để có danh sách đầy đủ.

Cài đặt "V=..." được ưu tiên hơn KBUILD_VERBOSE.

KBUILD_EXTMOD
-------------
Đặt thư mục tìm nguồn kernel khi build bên ngoài
mô-đun.

Cài đặt "M=..." được ưu tiên hơn KBUILD_EXTMOD.

KBUILD_OUTPUT
-------------
Chỉ định thư mục đầu ra khi xây dựng kernel.

Biến này cũng có thể được sử dụng để trỏ tới thư mục đầu ra của kernel khi
xây dựng các mô-đun bên ngoài dựa trên hạt nhân dựng sẵn trong một bản dựng riêng
thư mục. Xin lưu ý rằng điều này NOT chỉ định thư mục đầu ra cho
bản thân các mô-đun bên ngoài. (Sử dụng KBUILD_EXTMOD_OUTPUT cho mục đích đó.)

Thư mục đầu ra cũng có thể được chỉ định bằng cách sử dụng "O=...".

Cài đặt "O=..." được ưu tiên hơn KBUILD_OUTPUT.

KBUILD_EXTMOD_OUTPUT
--------------------
Chỉ định thư mục đầu ra cho các mô-đun bên ngoài.

Cài đặt "MO=..." được ưu tiên hơn KBUILD_EXTMOD_OUTPUT.

KBUILD_EXTRA_WARN
-----------------
Chỉ định các bước kiểm tra bản dựng bổ sung. Giá trị tương tự có thể được gán bằng cách chuyển
W=... từ dòng lệnh.

Xem ZZ0000ZZ để biết danh sách các giá trị được hỗ trợ.

Cài đặt "W=..." được ưu tiên hơn KBUILD_EXTRA_WARN.

KBUILD_DEBARCH
--------------
Đối với mục tiêu deb-pkg, cho phép ghi đè các phương pháp phỏng đoán thông thường được triển khai bởi
deb-pkg. Thông thường deb-pkg cố gắng đoán kiến trúc đúng dựa trên
biến UTS_MACHINE và trên một số kiến trúc cũng có cấu hình kernel.
Giá trị của KBUILD_DEBARCH được giả định (không được kiểm tra) là Debian hợp lệ
kiến trúc.

KDOCFLAGS
---------
Chỉ định các cờ bổ sung (cảnh báo/lỗi) để kiểm tra kernel-doc trong quá trình xây dựng,
xem tools/docs/kernel-doc để biết cờ nào được hỗ trợ. Lưu ý rằng điều này không
(hiện tại) áp dụng cho việc xây dựng tài liệu.

ARCH
----
Đặt ARCH cho kiến ​​trúc sẽ được xây dựng.

Trong hầu hết các trường hợp, tên của kiến trúc giống như tên của
tên thư mục được tìm thấy trong thư mục Arch/.

Nhưng một số kiến ​​trúc như x86 và sparc có bí danh.

- x86: i386 cho 32 bit, x86_64 cho 64 bit
- parisc: parisc64 cho 64 bit
- sparc: sparc32 cho 32 bit, sparc64 cho 64 bit

CROSS_COMPILE
-------------
Chỉ định một phần cố định tùy chọn của tên tệp binutils.
CROSS_COMPILE có thể là một phần của tên tệp hoặc đường dẫn đầy đủ.

CROSS_COMPILE cũng được sử dụng cho ccache trong một số thiết lập.

CF
--
Tùy chọn bổ sung cho thưa thớt.

CF thường được sử dụng trên dòng lệnh như thế này ::

tạo CF=-Wbitwise C=2

INSTALL_PATH
------------
INSTALL_PATH chỉ định nơi đặt bản đồ hệ thống và kernel đã cập nhật
hình ảnh. Mặc định là /boot, nhưng bạn có thể đặt nó thành các giá trị khác.

INSTALLKERNEL
-------------
Tập lệnh cài đặt được gọi khi sử dụng "make install".
Tên mặc định là "installkernel".

Tập lệnh sẽ được gọi với các đối số sau:

- $1 - phiên bản hạt nhân
   - $2 - tập tin ảnh hạt nhân
   - $3 - tệp bản đồ hạt nhân
   - $4 - đường dẫn cài đặt mặc định (sử dụng thư mục gốc nếu trống)

Việc triển khai "thực hiện cài đặt" là kiến trúc cụ thể
và nó có thể khác với những điều trên.

INSTALLKERNEL được cung cấp để cho phép khả năng
chỉ định trình cài đặt tùy chỉnh khi biên dịch chéo kernel.

MODLIB
------
Chỉ định nơi cài đặt các mô-đun.
Giá trị mặc định là::

$(INSTALL_MOD_PATH)/lib/mô-đun/$(KERNELRELEASE)

Giá trị có thể bị ghi đè trong trường hợp giá trị mặc định bị bỏ qua.

INSTALL_MOD_PATH
----------------
INSTALL_MOD_PATH chỉ định tiền tố cho MODLIB cho thư mục mô-đun
di dời theo yêu cầu của rễ xây dựng.  Điều này không được xác định trong
makefile nhưng đối số có thể được chuyển tới make nếu cần.

INSTALL_MOD_STRIP
-----------------
INSTALL_MOD_STRIP, nếu được xác định, sẽ khiến các mô-đun bị
bị tước bỏ sau khi chúng được cài đặt.  Nếu INSTALL_MOD_STRIP là '1' thì
tùy chọn mặc định --strip-debug sẽ được sử dụng.  Nếu không,
Giá trị INSTALL_MOD_STRIP sẽ được sử dụng làm tùy chọn cho lệnh dải.

INSTALL_HDR_PATH
----------------
INSTALL_HDR_PATH chỉ định nơi cài đặt tiêu đề không gian người dùng khi
thực thi "tạo tiêu đề_*".

Giá trị mặc định là::

$(objtree)/usr

$(objtree) là thư mục lưu các tệp đầu ra.
Thư mục đầu ra thường được đặt bằng cách sử dụng "O=..." trên dòng lệnh.

Giá trị có thể bị ghi đè trong trường hợp giá trị mặc định bị bỏ qua.

INSTALL_DTBS_PATH
-----------------
INSTALL_DTBS_PATH chỉ định nơi cài đặt các đốm màu cây thiết bị cho
di dời theo yêu cầu của rễ xây dựng.  Điều này không được xác định trong
makefile nhưng đối số có thể được chuyển tới make nếu cần.

KBUILD_ABS_SRCTREE
--------------------------------------------------
Kbuild sử dụng đường dẫn tương đối để trỏ tới cây khi có thể. Ví dụ,
khi xây dựng trong cây nguồn, đường dẫn của cây nguồn là '.'

Đặt cờ này yêu cầu Kbuild sử dụng đường dẫn tuyệt đối đến cây nguồn.
Có một số trường hợp hữu ích để làm như vậy, như khi tạo tệp thẻ bằng
mục đường dẫn tuyệt đối, v.v.

KBUILD_SIGN_PIN
---------------
Biến này cho phép truyền cụm mật khẩu hoặc PIN vào tệp ký hiệu
tiện ích khi ký các mô-đun hạt nhân, nếu khóa riêng yêu cầu như vậy.

KBUILD_MODPOST_WARN
-------------------
KBUILD_MODPOST_WARN có thể được đặt để tránh lỗi trong trường hợp không xác định
các ký hiệu trong giai đoạn liên kết mô-đun cuối cùng. Nó thay đổi những lỗi như vậy
vào các cảnh báo.

KBUILD_MODPOST_NOFINAL
----------------------
KBUILD_MODPOST_NOFINAL có thể được đặt để bỏ qua liên kết cuối cùng của các mô-đun.
Điều này chỉ hữu ích để tăng tốc độ biên dịch thử nghiệm.

KBUILD_EXTRA_SYMBOLS
--------------------
Đối với các mô-đun sử dụng ký hiệu từ các mô-đun khác.
Xem thêm chi tiết trong module.rst.

ALLSOURCE_ARCHS
---------------
Đối với các mục tiêu thẻ/TAGS/cscope, bạn có thể chỉ định nhiều hơn một vòm
được đưa vào cơ sở dữ liệu, cách nhau bằng khoảng trống. Ví dụ.::

$ make ALLSOURCE_ARCHS="x86 mips arm" thẻ

Để có được tất cả các vòm có sẵn, bạn cũng có thể chỉ định tất cả. Ví dụ.::

$ tạo ALLSOURCE_ARCHS=tất cả các thẻ

IGNORE_DIRS
-----------
Đối với các mục tiêu thẻ/TAGS/cscope, bạn có thể chọn thư mục nào sẽ không
được đưa vào cơ sở dữ liệu, cách nhau bằng khoảng trống. Ví dụ.::

$ make IGNORE_DIRS="drivers/gpu/drm/radeon tools" cscope

KBUILD_BUILD_TIMESTAMP
----------------------
Việc đặt giá trị này thành chuỗi ngày sẽ ghi đè dấu thời gian được sử dụng trong
Định nghĩa UTS_VERSION (uname -v trong kernel đang chạy). Giá trị phải
là một chuỗi có thể được chuyển đến ngày -d. Ví dụ.::

$ KBUILD_BUILD_TIMESTAMP="Thứ Hai ngày 13 tháng 10 00:00:00 UTC 2025" thực hiện

Giá trị mặc định là đầu ra của lệnh ngày tại một thời điểm trong
xây dựng. Nếu được cung cấp, dấu thời gian này cũng sẽ được sử dụng cho các trường mtime
trong bất kỳ kho lưu trữ initramfs nào. Thời gian initramfs là 32-bit, vì vậy ngày trước đó
kỷ nguyên Unix 1970 hoặc sau 2106-02-07 06:28:15 UTC sẽ không thành công.

KBUILD_BUILD_USER, KBUILD_BUILD_HOST
------------------------------------
Hai biến này cho phép ghi đè chuỗi user@host được hiển thị trong
khởi động và trong /proc/version. Giá trị mặc định là đầu ra của lệnh
whoami và máy chủ tương ứng.

LLVM
----
Nếu biến này được đặt thành 1, Kbuild sẽ sử dụng tiện ích Clang và LLVM thay thế
các binutils GCC và GNU để xây dựng kernel.
