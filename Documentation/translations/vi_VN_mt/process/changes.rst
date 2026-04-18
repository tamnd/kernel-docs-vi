.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/changes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _changes:

Yêu cầu tối thiểu để biên dịch Kernel
++++++++++++++++++++++++++++++++++++++++++

giới thiệu
=====

Tài liệu này được thiết kế để cung cấp danh sách các mức độ tối thiểu của
phần mềm cần thiết để chạy phiên bản kernel hiện tại.

Tài liệu này ban đầu dựa trên tệp "Thay đổi" của tôi dành cho hạt nhân 2.0.x
và do đó mang ơn những người giống như hồ sơ đó (Jared Mauch,
Axel Boldt, Alessandro Sigala và vô số người dùng khác trên khắp thế giới
'mạng).

Yêu cầu tối thiểu hiện tại
****************************

Hãy nâng cấp lên ZZ0000ZZ những bản sửa đổi phần mềm này trước khi nghĩ rằng bạn đã
gặp phải một lỗi!  Nếu bạn không chắc chắn mình đang sử dụng phiên bản nào
đang chạy, lệnh được đề xuất sẽ cho bạn biết. Để biết danh sách các chương trình
trên hệ thống của bạn bao gồm cả phiên bản của họ thực thi ./scripts/ver_linux

Một lần nữa, hãy nhớ rằng danh sách này giả định rằng bạn đã sẵn sàng
chạy nhân Linux.  Ngoài ra, không phải tất cả các công cụ đều cần thiết trên tất cả
hệ thống; rõ ràng là nếu bạn không có bất kỳ phần cứng PC Card nào, chẳng hạn,
bạn có thể không cần phải lo lắng về pcmciautils.

======================= ============================================================
        Chương trình Phiên bản tối thiểu Lệnh kiểm tra phiên bản
======================= ============================================================
bash 4.2 bash --version
bc 1.06.95 bc --version
bindgen (tùy chọn) 0.71.1 bindgen --version
binutils 2.30 ld -v
bò rừng bison 2.0 bò rừng --version
btrfs-progs 0,18 btrfs --version
Clang/LLVM (tùy chọn) 15.0.0 clang --version
e2fsprogs 1.41.4 e2fsck -V
flex 2.5.35 flex --version
gdb 7.2 gdb --version
GNU awk (tùy chọn) 5.1.0 gawk --version
GNU C 8.1 gcc --phiên bản
GNU tạo phiên bản 4.0 --version
GNU tar 1.28 tar --version
GRUB 0.93 grub --version || cài đặt grub --version
gtags (tùy chọn) 6.6.5 gtags --version
iptables 1.4.2 iptables -V
jfsutils 1.1.3 fsck.jfs -V
kmod 13 kmod -V
mcelog 0.6 mcelog --version
mkimage (tùy chọn) 2017.01 mkimage --version
nfs-utils 1.0.5 showmount --version
phiên bản openssl & libcrypto 1.0.0 openssl
pahole 1.22 pahole --version
pcmciautils 004 pccardctl -V
PPP 2.4.0 pppd --phiên bản
Procps 3.2.0 ps --version
Python 3.9.x python3 --version
hạn ngạch công cụ 3.09 hạn ngạch -V
Rust (tùy chọn) 1.85.0 Rustc --version
Sphinx\ [#f1]_ 3.4.3 sphinx-build --version
công cụ bí đao 4.0 mksquashfs -version
udev 081 udevadm --version
util-linux 2.10o mount --version
xfsprogs 2.6.0 xfs_db -V
======================= ============================================================

.. [#f1] Sphinx is needed only to build the Kernel documentation

Biên dịch hạt nhân
******************

GCC
---

Yêu cầu về phiên bản gcc có thể khác nhau tùy thuộc vào loại CPU trong
máy tính.

Kêu vang/LLVM (tùy chọn)
---------------------

Bản phát hành chính thức mới nhất của các tiện ích clang và LLVM (theo
ZZ0001ZZ) được hỗ trợ để xây dựng
hạt nhân. Các bản phát hành cũ hơn không được đảm bảo sẽ hoạt động và chúng tôi có thể loại bỏ các giải pháp thay thế
từ kernel được sử dụng để hỗ trợ các phiên bản cũ hơn. Vui lòng xem thêm
tài liệu trên ZZ0000ZZ.

Rỉ sét (tùy chọn)
---------------

Cần có phiên bản mới nhất của trình biên dịch Rust.

Vui lòng xem Documentation/rust/quick-start.rst để biết hướng dẫn về cách
đáp ứng các yêu cầu xây dựng của hỗ trợ Rust. Đặc biệt, ZZ0000ZZ
target ZZ0001ZZ rất hữu ích để kiểm tra lý do tại sao chuỗi công cụ Rust có thể không
được phát hiện.

bindgen (tùy chọn)
------------------

ZZ0000ZZ được sử dụng để tạo các liên kết Rust với phía C của kernel.
Nó phụ thuộc vào ZZ0001ZZ.

Làm
----

Bạn sẽ cần GNU make 4.0 trở lên để xây dựng kernel.

đánh
----

Một số tập lệnh bash được sử dụng để xây dựng kernel.
Cần có Bash 4.2 hoặc mới hơn.

Binutils
--------

Cần có Binutils 2.30 hoặc mới hơn để xây dựng kernel.

pkg-config
----------

Hệ thống xây dựng, kể từ phiên bản 4.18, yêu cầu pkg-config để kiểm tra xem đã cài đặt chưa
công cụ kconfig và xác định cài đặt cờ để sử dụng trong
'tạo {g,x}cấu hình'.  Trước đây pkg-config đã được sử dụng nhưng không
được xác minh hoặc ghi lại.

Uốn cong
----

Kể từ Linux 4.16, hệ thống xây dựng tạo ra các bộ phân tích từ vựng
trong quá trình xây dựng.  Điều này yêu cầu flex 2.5.35 trở lên.


Bò rừng
-----

Kể từ Linux 4.16, hệ thống xây dựng tạo ra các trình phân tích cú pháp
trong quá trình xây dựng.  Điều này yêu cầu bison 2.0 trở lên.

hố nước
------

Kể từ Linux 5.2, nếu CONFIG_DEBUG_INFO_BTF được chọn, hệ thống xây dựng
tạo BTF (Định dạng loại BPF) từ DWARF trong vmlinux, muộn hơn một chút từ kernel
các mô-đun là tốt.  Điều này yêu cầu pahole v1.22 trở lên.

Nó được tìm thấy trong các gói phân phối 'dwarves' hoặc 'pahole' hoặc từ
ZZ0000ZZ

Perl
----

Bạn sẽ cần Perl 5 và các mô-đun sau: ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ để xây dựng kernel.

Python
------

Một số tùy chọn cấu hình yêu cầu nó: nó được yêu cầu cho arm/arm64
cấu hình mặc định, CONFIG_LTO_CLANG, một số cấu hình tùy chọn DRM,
công cụ kernel-doc và công cụ xây dựng tài liệu (Sphinx), cùng nhiều công cụ khác.

BC
--

Bạn sẽ cần bc để xây dựng kernel 3.10 trở lên


OpenSSL
-------

Ký mô-đun và xử lý chứng chỉ bên ngoài sử dụng chương trình OpenSSL và
thư viện mật mã để thực hiện việc tạo khóa và tạo chữ ký.

Bạn sẽ cần openssl để xây dựng hạt nhân 3.7 trở lên nếu việc ký mô-đun được thực hiện
đã bật.  Bạn cũng sẽ cần các gói phát triển openssl để xây dựng hạt nhân 4.3
và cao hơn.

hắc ín
---

Cần có tar GNU nếu bạn muốn cho phép truy cập vào các tiêu đề kernel thông qua sysfs
(CONFIG_IKHEADERS).

gtags / GNU GLOBAL (tùy chọn)
-----------------------------

Bản dựng kernel yêu cầu GNU GLOBAL phiên bản 6.6.5 trở lên để tạo
gắn thẻ các tập tin thông qua ZZ0000ZZ.  Điều này là do nó sử dụng gtags
Cờ ZZ0001ZZ.

hình ảnh mk
-------

Công cụ này được sử dụng khi xây dựng Flat Image Tree (FIT), thường được sử dụng trên ARM
nền tảng. Công cụ này có sẵn thông qua gói ZZ0000ZZ hoặc có thể
được xây dựng từ mã nguồn U-Boot. Xem hướng dẫn tại
ZZ0001ZZ

GNU AWK
-------

GNU AWK là cần thiết nếu bạn muốn các bản dựng kernel tạo dữ liệu dải địa chỉ cho
mô-đun dựng sẵn (CONFIG_BUILTIN_MODULE_RANGES).

Tiện ích hệ thống
****************

Thay đổi kiến ​​trúc
---------------------

DevFS đã lỗi thời nhường chỗ cho udev
(ZZ0000ZZ

Hiện đã có hỗ trợ UID 32 bit.  Chúc vui vẻ!

Tài liệu Linux cho các hàm đang chuyển sang nội tuyến
tài liệu thông qua các nhận xét được định dạng đặc biệt gần
định nghĩa trong nguồn.  Những ý kiến này có thể được kết hợp với ReST
các tập tin trong thư mục Documentation/ để tạo ra tài liệu phong phú, có thể
sau đó được chuyển đổi sang các tệp PostScript, HTML, LaTex, ePUB và PDF.
Để chuyển đổi từ định dạng ReST sang định dạng bạn chọn, bạn sẽ cần
Nhân sư.

Sử dụng linux
----------

Các phiên bản mới của util-linux cung cấp hỗ trợ ZZ0000ZZ cho các ổ đĩa lớn hơn,
hỗ trợ các tùy chọn mới để gắn kết, nhận biết nhiều phân vùng được hỗ trợ hơn
các loại và những món quà tương tự.
Có thể bạn sẽ muốn nâng cấp.

Ksymoops
--------

Nếu điều không thể tưởng tượng được xảy ra và kernel của bạn bị lỗi, bạn có thể cần
ksymoops để giải mã nó, nhưng trong hầu hết các trường hợp thì không.
Nói chung, việc xây dựng kernel bằng ZZ0000ZZ thường được ưu tiên hơn
rằng nó tạo ra các kết xuất có thể đọc được và có thể được sử dụng nguyên trạng (điều này cũng
tạo ra đầu ra tốt hơn ksymoops).  Nếu vì lý do nào đó kernel của bạn
không được xây dựng bằng ZZ0001ZZ và bạn không có cách nào để xây dựng lại và
tái tạo Rất tiếc bằng tùy chọn đó, thì bạn vẫn có thể giải mã Rất tiếc đó
với ksymoops.

Mkinitrd
--------

Những thay đổi này đối với bố cục cây tệp ZZ0000ZZ cũng yêu cầu
mkinitrd được nâng cấp.

E2fsprogs
---------

Phiên bản mới nhất của ZZ0000ZZ sửa một số lỗi trong fsck và
debugfs.  Rõ ràng, đó là một ý tưởng tốt để nâng cấp.

JFSutils
--------

Gói ZZ0000ZZ chứa các tiện ích cho hệ thống tệp.
Các tiện ích sau đây có sẵn:

- ZZ0000ZZ - bắt đầu phát lại nhật ký giao dịch và kiểm tra
  và sửa chữa phân vùng được định dạng JFS.

- ZZ0000ZZ - tạo phân vùng có định dạng JFS.

- các tiện ích hệ thống tập tin khác cũng có sẵn trong gói này.

Xfsprogs
--------

Phiên bản mới nhất của ZZ0000ZZ chứa ZZ0001ZZ, ZZ0002ZZ và
Các tiện ích ZZ0003ZZ, trong số những tiện ích khác, dành cho hệ thống tệp XFS.  Đó là
kiến trúc độc lập và mọi phiên bản từ 2.0.0 trở đi đều phải
hoạt động chính xác với phiên bản mã hạt nhân XFS này (2.6.0 hoặc
được khuyến khích sử dụng sau do có một số cải tiến đáng kể).

PCMCIAutils
-----------

PCMCIAutils thay thế ZZ0000ZZ. Nó thiết lập đúng
Ổ cắm PCMCIA khi khởi động hệ thống và tải các mô-đun thích hợp
đối với các thiết bị PCMCIA 16 bit nếu hạt nhân được mô-đun hóa và trình cắm nóng
hệ thống con được sử dụng.

Công cụ hạn ngạch
-----------

Cần hỗ trợ uid và gid 32 bit nếu bạn muốn sử dụng
định dạng hạn ngạch phiên bản 2 mới hơn.  Công cụ hạn ngạch phiên bản 3.07 và
mới hơn có hỗ trợ này.  Sử dụng phiên bản được đề xuất hoặc mới hơn
từ bảng trên.

Mã vi Intel IA32
--------------------

Một trình điều khiển đã được thêm vào để cho phép cập nhật vi mã Intel IA32,
có thể truy cập như một thiết bị ký tự (linh tinh) bình thường.  Nếu bạn không sử dụng
udev bạn có thể cần::

mkdir/dev/cpu
  mknod /dev/cpu/microcode c 10 184
  chmod 0644/dev/cpu/microcode

là root trước khi bạn có thể sử dụng cái này.  Có lẽ bạn cũng sẽ muốn
lấy tiện ích microcode_ctl trong không gian người dùng để sử dụng với tiện ích này.

udev
----

ZZ0000ZZ là một ứng dụng không gian người dùng để điền động ZZ0001ZZ với
chỉ các mục dành cho các thiết bị thực sự có mặt. ZZ0002ZZ thay thế cơ bản
chức năng của devfs, đồng thời cho phép đặt tên thiết bị liên tục cho
thiết bị.

FUSE
----

Cần libfuse 2.4.0 trở lên.  Tối thiểu tuyệt đối là 2.3.0 nhưng gắn kết
tùy chọn ZZ0000ZZ và ZZ0001ZZ sẽ không hoạt động.

Mạng
**********

Những thay đổi chung
---------------

Nếu bạn có nhu cầu cấu hình mạng nâng cao, có lẽ bạn nên
hãy cân nhắc sử dụng các công cụ mạng từ ip-route2.

Bộ lọc gói / NAT
-------------------
Việc lọc gói và mã NAT sử dụng các công cụ tương tự như 2.4.x trước đó
loạt hạt nhân (iptables).  Nó vẫn bao gồm các mô-đun tương thích ngược
dành cho ipchains kiểu 2.2.x và ipfwadm kiểu 2.0.x.

PPP
---

Trình điều khiển PPP đã được cơ cấu lại để hỗ trợ đa liên kết và
cho phép nó hoạt động trên các lớp phương tiện đa dạng.  Nếu bạn sử dụng PPP,
nâng cấp pppd lên ít nhất 2.4.0.

Nếu bạn không sử dụng udev, bạn phải có tệp thiết bị /dev/ppp
có thể được thực hiện bởi::

mknod /dev/ppp c 108 0

như gốc.

NFS-utils
---------

Trong các hạt nhân cổ (2.4 trở về trước), máy chủ nfs cần biết
về bất kỳ ứng dụng khách nào dự kiến có thể truy cập tệp qua NFS.  Cái này
thông tin sẽ được ZZ0000ZZ cung cấp cho kernel khi máy khách
gắn hệ thống tập tin hoặc bằng ZZ0001ZZ khi khởi động hệ thống.  xuất khẩu
sẽ lấy thông tin về các khách hàng đang hoạt động từ ZZ0002ZZ.

Cách tiếp cận này khá mong manh vì nó phụ thuộc vào rmtab là chính xác
điều này không phải lúc nào cũng dễ dàng, đặc biệt khi cố gắng thực hiện
thất bại.  Ngay cả khi hệ thống hoạt động tốt, ZZ0000ZZ vẫn gặp phải vấn đề
nhận được rất nhiều mục cũ mà không bao giờ bị xóa.

Với các hạt nhân hiện đại, chúng ta có tùy chọn để hạt nhân thông báo cho mountd
khi nó nhận được yêu cầu từ một máy chủ không xác định và mountd có thể đưa ra
xuất thông tin thích hợp vào kernel.  Điều này loại bỏ
phụ thuộc vào ZZ0000ZZ và có nghĩa là kernel chỉ cần biết về
khách hàng hiện đang hoạt động.

Để kích hoạt chức năng mới này, bạn cần::

mount -t nfsd nfsd /proc/fs/nfsd

trước khi chạy importfs hoặc mountd.  Chúng tôi đề nghị tất cả NFS
các dịch vụ được bảo vệ khỏi mạng Internet nói chung bằng tường lửa nơi
điều đó là có thể.

mcelog
------

Trên nhân x86, cần có tiện ích mcelog để xử lý và ghi nhật ký kiểm tra máy
sự kiện khi ZZ0000ZZ được kích hoạt. Sự kiện kiểm tra máy bị lỗi
được báo cáo bởi CPU. Việc xử lý chúng được khuyến khích mạnh mẽ.

Tài liệu hạt nhân
********************

Nhân sư
------

Vui lòng xem ZZ0000ZZ trong Tài liệu/doc-guide/sphinx.rst
để biết chi tiết về các yêu cầu của Sphinx.

bác sĩ rỉ sét
-------

ZZ0000ZZ được sử dụng để tạo tài liệu cho mã Rust. Xin vui lòng xem
Tài liệu/rust/general-information.rst để biết thêm thông tin.

Đang cập nhật phần mềm
========================

Biên dịch hạt nhân
******************

gcc
---

- <ftp://ftp.gnu.org/gnu/gcc/>

Tiếng kêu/LLVM
----------

-ZZ0000ZZ.

rỉ sét
----

- Tài liệu/rust/quick-start.rst.

chất kết dính
-------

- Tài liệu/rust/quick-start.rst.

Làm
----

- <ftp://ftp.gnu.org/gnu/make/>

đánh
----

- <ftp://ftp.gnu.org/gnu/bash/>

Binutils
--------

- <ZZ0000ZZ

Uốn cong
----

- <ZZ0000ZZ

Bò rừng
-----

- <ftp://ftp.gnu.org/gnu/bison/>

OpenSSL
-------

- <ZZ0000ZZ

Tiện ích hệ thống
****************

Sử dụng linux
----------

- <ZZ0000ZZ

Kmod
----

- <ZZ0000ZZ
- <ZZ0001ZZ

Ksymoops
--------

- <ZZ0000ZZ

Mkinitrd
--------

- <ZZ0000ZZ

E2fsprogs
---------

- <ZZ0000ZZ
- <ZZ0001ZZ

JFSutils
--------

- <ZZ0000ZZ

Xfsprogs
--------

- <ZZ0000ZZ
- <ZZ0001ZZ

Pcmciautils
-----------

- <ZZ0000ZZ

Công cụ hạn ngạch
-----------

- <ZZ0000ZZ


Vi mã Intel P6
------------------

- <ZZ0000ZZ

udev
----

- <ZZ0000ZZ

FUSE
----

- <ZZ0000ZZ

mcelog
------

- <ZZ0000ZZ

Mạng
**********

PPP
---

- <ZZ0000ZZ
- <ZZ0001ZZ
- <ZZ0002ZZ

NFS-utils
---------

- <ZZ0000ZZ
- <ZZ0001ZZ

iptables
--------

- <ZZ0000ZZ

Tuyến đường IP2
---------

- <ZZ0000ZZ

Hồ sơ O
--------

- <ZZ0000ZZ

Tài liệu hạt nhân
********************

Nhân sư
------

- <ZZ0000ZZ
