.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/kdump/kdump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================================
Tài liệu về Kdump - Giải pháp Crash Dumping dựa trên kexec
================================================================

Tài liệu này bao gồm tổng quan, thiết lập, cài đặt và phân tích
thông tin.

Tổng quan
========

Kdump sử dụng kexec để khởi động nhanh vào kernel dump-capture bất cứ khi nào
cần phải lấy kết xuất bộ nhớ của nhân hệ thống (ví dụ: khi
hệ thống hoảng loạn). Hình ảnh bộ nhớ của nhân hệ thống được bảo toàn trên toàn bộ
khởi động lại và có thể truy cập được vào kernel chụp kết xuất.

Bạn có thể sử dụng các lệnh thông dụng như cp, scp hoặc makedumpfile để sao chép
hình ảnh bộ nhớ vào tệp kết xuất trên đĩa cục bộ hoặc trên mạng
tới một hệ thống từ xa.

Kdump và kexec hiện được hỗ trợ trên x86, x86_64, ppc64,
kiến trúc s390x, arm và arm64.

Khi nhân hệ thống khởi động, nó dành một phần nhỏ bộ nhớ cho
hạt nhân thu thập kết xuất. Điều này đảm bảo rằng việc truy cập bộ nhớ trực tiếp đang diễn ra
(DMA) từ hạt nhân hệ thống không làm hỏng hạt nhân chụp kết xuất.
Lệnh kexec -p tải kernel dump-capture vào dành riêng này
trí nhớ.

Trên máy x86, cần có 640 KB bộ nhớ vật lý đầu tiên để khởi động,
bất kể kernel tải ở đâu. Để xử lý đơn giản hơn, toàn bộ
1M thấp được dành riêng để tránh mọi thao tác ghi trình điều khiển thiết bị hoặc hạt nhân sau này
dữ liệu vào khu vực này. Như thế này, 1M thấp có thể được tái sử dụng làm hệ thống RAM
bởi kdump kernel mà không cần xử lý thêm.

Trên máy PPC64 cần 32KB bộ nhớ vật lý đầu tiên để khởi động
bất kể hạt nhân được tải ở đâu và hỗ trợ kích thước trang 64K
kexec sao lưu bộ nhớ 64KB đầu tiên.

Đối với s390x, khi kdump được kích hoạt, vùng hạt nhân sự cố sẽ được trao đổi
với vùng [0, kích thước vùng hạt nhân] và sau đó là hạt nhân kdump
chạy trong [0, kích thước vùng hạt nhân sự cố]. Do đó không có hạt nhân nào có thể định vị lại được
cần thiết cho s390x.

Tất cả thông tin cần thiết về hình ảnh lõi của nhân hệ thống là
được mã hóa ở định dạng ELF và được lưu trữ trong vùng bộ nhớ dành riêng
trước một vụ tai nạn. Địa chỉ vật lý của phần bắt đầu của tiêu đề ELF là
được chuyển tới kernel dump-capture thông qua elfcorehdr= boot
tham số. Tùy chọn kích thước của tiêu đề ELF cũng có thể được thông qua
khi sử dụng cú pháp elfcorehdr=[size[KMG]@]offset[KMG] .

Với kernel chụp kết xuất, bạn có thể truy cập hình ảnh bộ nhớ thông qua
/proc/vmcore. Thao tác này sẽ xuất kết xuất dưới dạng tệp có định dạng ELF mà bạn có thể
viết ra bằng cách sử dụng các lệnh sao chép tập tin như cp hoặc scp. Bạn cũng có thể sử dụng
tiện ích makedumpfile để phân tích và ghi ra nội dung đã lọc với
các tùy chọn, ví dụ: với '-d 31', nó sẽ chỉ ghi dữ liệu kernel. Hơn nữa,
bạn có thể sử dụng các công cụ phân tích như Trình gỡ lỗi GNU (GDB) và Crash
công cụ để gỡ lỗi tệp kết xuất. Phương pháp này đảm bảo rằng các trang kết xuất được
đã đặt hàng đúng.

Thiết lập và cài đặt
======================

Cài đặt công cụ kexec
-------------------

1) Đăng nhập với tư cách người dùng root.

2) Tải xuống gói không gian người dùng kexec-tools từ URL sau:

ZZ0000ZZ

Đây là một liên kết tượng trưng đến phiên bản mới nhất.

Cây git kexec-tools mới nhất hiện có tại:

- git://git.kernel.org/pub/scm/utils/kernel/kexec/kexec-tools.git
-ZZ0000ZZ

Ngoài ra còn có giao diện gitweb có sẵn tại
ZZ0000ZZ

Thông tin thêm về kexec-tools có thể được tìm thấy tại
ZZ0000ZZ

3) Giải nén tarball bằng lệnh tar, như sau ::

tar xvpzf kexec-tools.tar.gz

4) Thay đổi thư mục kexec-tools như sau ::

cd kexec-tools-VERSION

5) Cấu hình gói như sau::

./cấu hình

6) Biên dịch gói như sau::

làm

7) Cài đặt gói như sau ::

thực hiện cài đặt


Xây dựng hệ thống và hạt nhân thu thập kết xuất
-----------------------------------------
Có hai phương pháp sử dụng Kdump.

1) Xây dựng một hạt nhân thu thập kết xuất tùy chỉnh riêng biệt để ghi lại
   kết xuất lõi kernel.

2) Hoặc sử dụng chính hệ thống nhị phân hạt nhân làm hạt nhân chụp kết xuất và có
   không cần phải xây dựng một hạt nhân thu thập kết xuất riêng biệt. Điều này là có thể
   chỉ với các kiến trúc hỗ trợ hạt nhân có thể định vị lại. Như
   ngày nay, hỗ trợ kiến trúc i386, x86_64, ppc64, arm và arm64
   hạt nhân có thể di dời.

Việc xây dựng một hạt nhân có thể định vị lại là thuận lợi xét theo quan điểm rằng
người ta không cần phải xây dựng hạt nhân thứ hai để thu thập kết xuất. Nhưng
đồng thời người ta có thể muốn xây dựng một kernel chụp kết xuất tùy chỉnh
phù hợp với nhu cầu của mình.

Sau đây là cài đặt cấu hình cần thiết cho hệ thống và
hạt nhân chụp kết xuất để cho phép hỗ trợ kdump.

Tùy chọn cấu hình kernel hệ thống
----------------------------

1) Kích hoạt "cuộc gọi hệ thống kexec" hoặc "cuộc gọi hệ thống dựa trên tệp kexec" trong
   "Loại bộ xử lý và tính năng."::

CONFIG_KEXEC=y hoặc CONFIG_KEXEC_FILE=y

Và cả hai sẽ chọn KEXEC_CORE::

CONFIG_KEXEC_CORE=y

2) Kích hoạt "hỗ trợ hệ thống tệp sysfs" trong "Hệ thống tệp" -> "Giả
   hệ thống tập tin." Điều này thường được bật theo mặc định::

CONFIG_SYSFS=y

Lưu ý rằng "hỗ trợ hệ thống tệp sysfs" có thể không xuất hiện trong "Giả
   hệ thống tập tin" nếu "Định cấu hình các tính năng kernel tiêu chuẩn (người dùng chuyên gia)"
   không được bật trong "Cài đặt chung." Trong trường hợp này, hãy kiểm tra tệp .config
   chính nó để đảm bảo rằng sysfs được bật, như sau ::

grep 'CONFIG_SYSFS' .config

3) Kích hoạt "Biên dịch hạt nhân với thông tin gỡ lỗi" trong "Hack hạt nhân."::

CONFIG_DEBUG_INFO=Y

Điều này khiến hạt nhân được xây dựng với các biểu tượng gỡ lỗi. Bãi rác
   công cụ phân tích yêu cầu vmlinux có biểu tượng gỡ lỗi để đọc
   và phân tích một tập tin kết xuất.

Tùy chọn cấu hình kernel chụp kết xuất (Arch Independent)
-----------------------------------------------------

1) Kích hoạt hỗ trợ "kết xuất sự cố hạt nhân" trong "Loại bộ xử lý và
   tính năng"::

CONFIG_CRASH_DUMP=y

Và điều này sẽ chọn VMCORE_INFO và CRASH_RESERVE::
	CONFIG_VMCORE_INFO=y
	CONFIG_CRASH_RESERVE=y

2) Bật "/proc/vmcore support" trong "Hệ thống tệp" -> "Hệ thống tệp giả"::

CONFIG_PROC_VMCORE=y

(CONFIG_PROC_VMCORE được đặt theo mặc định khi chọn CONFIG_CRASH_DUMP.)

Tùy chọn cấu hình kernel chụp kết xuất (Arch Dependent, i386 và x86_64)
--------------------------------------------------------------------

1) Trên i386, bật hỗ trợ bộ nhớ cao trong "Loại bộ xử lý và
   tính năng"::

CONFIG_HIGHMEM4G

2) Với CONFIG_SMP=y, thông thường nr_cpus=1 cần được chỉ định trên kernel
   dòng lệnh khi tải kernel chụp kết xuất vì một
   CPU đủ để kdump kernel kết xuất vmcore trên hầu hết các hệ thống.

Tuy nhiên, bạn cũng có thể chỉ định nr_cpus=X để kích hoạt nhiều bộ xử lý
   trong hạt nhân kdump.

Với CONFIG_SMP=n, những điều trên không liên quan.

3) Một hạt nhân có thể định vị lại được đề xuất xây dựng theo mặc định. Nếu chưa,
   bật hỗ trợ "Xây dựng hạt nhân có thể định vị lại" trong phần "Loại bộ xử lý và
   tính năng"::

CONFIG_RELOCATABLE=y

4) Sử dụng giá trị phù hợp cho "Địa chỉ vật lý chứa kernel
   đã tải" (trong "Loại bộ xử lý và tính năng"). Điều này chỉ xuất hiện khi
   "bãi lỗi hạt nhân" được bật. Một giá trị phù hợp phụ thuộc vào
   liệu kernel có thể định vị lại được hay không.

Nếu bạn đang sử dụng kernel có thể định vị lại, hãy sử dụng CONFIG_PHYSICAL_START=0x100000
   Điều này sẽ biên dịch kernel cho địa chỉ vật lý 1MB, nhưng thực tế là
   kernel có thể định vị lại, do đó nó có thể chạy từ bất kỳ địa chỉ vật lý nào
   bộ tải khởi động kexec sẽ tải nó trong vùng bộ nhớ dành riêng cho việc chụp kết xuất
   hạt nhân.

Nếu không thì nó sẽ là vùng bắt đầu của vùng nhớ dành riêng cho
   kernel thứ hai sử dụng tham số khởi động "crashkernel=Y@X". Đây là X
   bắt đầu vùng bộ nhớ dành riêng cho kernel chụp kết xuất.
   Nói chung X là 16MB (0x1000000). Vì vậy bạn có thể thiết lập
   CONFIG_PHYSICAL_START=0x1000000

5) Tạo và cài đặt kernel và các mô-đun của nó. DO NOT thêm kernel này
   vào các tập tin cấu hình bộ tải khởi động.

Tùy chọn cấu hình kernel chụp kết xuất (Phụ thuộc Arch, ppc64)
----------------------------------------------------------

1) Kích hoạt hỗ trợ "Xây dựng hạt nhân sự cố kdump" trong tùy chọn "Kernel"::

CONFIG_CRASH_DUMP=y

2) Kích hoạt hỗ trợ "Xây dựng hạt nhân có thể định vị lại"::

CONFIG_RELOCATABLE=y

Tạo và cài đặt kernel và các mô-đun của nó.

Tùy chọn cấu hình kernel chụp kết xuất (Phụ thuộc Arch, nhánh)
----------------------------------------------------------

- Để sử dụng hạt nhân có thể định vị lại,
    Bật hỗ trợ "AUTO_ZRELADDR" trong tùy chọn "Khởi động"::

AUTO_ZRELADDR=y

Tùy chọn cấu hình kernel chụp kết xuất (Arch Dependent, arm64)
----------------------------------------------------------

- Xin lưu ý rằng kvm của kernel dump-capture sẽ không được kích hoạt
  trên các hệ thống không phải VHE ngay cả khi nó được định cấu hình. Điều này là do CPU
  sẽ không được đặt lại về EL2 khi hoảng loạn.

cú pháp hạt nhân
===========================
1) Crashkernel=size@offset

Ở đây, 'size' chỉ định dung lượng bộ nhớ dự trữ cho kernel chụp kết xuất
   và 'offset' chỉ định phần đầu của bộ nhớ dành riêng này. Ví dụ,
   "crashkernel=64M@16M" yêu cầu kernel hệ thống dự trữ 64 MB bộ nhớ
   bắt đầu từ địa chỉ vật lý 0x01000000 (16MB) cho kernel chụp kết xuất.

Vùng hạt nhân sự cố có thể được hệ thống tự động đặt
   kernel vào thời gian chạy. Điều này được thực hiện bằng cách chỉ định địa chỉ cơ sở là 0,
   hoặc bỏ qua tất cả cùng nhau::

sự cốkernel=256M@0

hoặc::

hạt nhân bị hỏng = 256M

Nếu địa chỉ bắt đầu được chỉ định, hãy lưu ý rằng địa chỉ bắt đầu của
   kernel sẽ được căn chỉnh theo một giá trị (phụ thuộc vào Arch), vì vậy nếu
   địa chỉ bắt đầu không phải là thì bất kỳ khoảng trống nào bên dưới điểm căn chỉnh sẽ là
   lãng phí.

2) range1:size1[,range2:size2,...][@offset]

Mặc dù cú pháp "crashkernel=size[@offset]" là đủ cho hầu hết
   cấu hình, đôi khi sẽ rất hữu ích khi có bộ nhớ dành riêng phụ thuộc
   về giá trị của Hệ thống RAM -- phần lớn dành cho các nhà phân phối đã thiết lập trước
   dòng lệnh kernel để tránh hệ thống không thể khởi động sau khi một số bộ nhớ bị hỏng
   đã được gỡ bỏ khỏi máy.

Cú pháp là::

Crashkernel=<range1>:<size1>[,<range2>:<size2>,...][@offset]
       phạm vi=bắt đầu-[kết thúc]

Ví dụ::

Crashkernel=512M-2G:64M,2G-:128M

Điều này có nghĩa là:

1) nếu RAM nhỏ hơn 512M thì không dự trữ gì cả
          (đây là trường hợp "cứu hộ")
       2) nếu kích thước RAM nằm trong khoảng từ 512M đến 2G (độc quyền), thì hãy dự trữ 64M
       3) nếu kích thước RAM lớn hơn 2G thì dự trữ 128M

3) Crashkernel=size,high và Crashkernel=size,low

Nếu ưu tiên bộ nhớ trên 4G, có thể sử dụng Crashkernel=size,high để
   đáp ứng điều đó. Với nó, bộ nhớ vật lý được phép phân bổ từ trên xuống,
   vì vậy có thể trên 4G nếu hệ thống được cài đặt nhiều hơn 4G RAM. Nếu không,
   vùng bộ nhớ sẽ được phân bổ dưới 4G nếu có.

Khi Crashkernel=X,high được thông qua, kernel có thể phân bổ bộ nhớ vật lý
   vùng trên 4G, cần có bộ nhớ thấp dưới 4G trong trường hợp này. có
   ba cách để có được bộ nhớ thấp:

1) Kernel sẽ tự động phân bổ ít nhất 256M bộ nhớ dưới 4G
         nếu Crashkernel=Y, mức thấp không được chỉ định.
      2) Thay vào đó, hãy để người dùng chỉ định kích thước bộ nhớ thấp.
      3) Giá trị được chỉ định 0 sẽ vô hiệu hóa việc cấp phát bộ nhớ thấp::

hạt nhân bị hỏng = 0, thấp

4) hạt nhân=kích thước, cma

Dự trữ bộ nhớ kernel bổ sung khi gặp sự cố từ CMA. Việc đặt chỗ này là
	có thể sử dụng được bởi bộ nhớ không gian người dùng của hệ thống đầu tiên và hạt nhân có thể di chuyển được
	phân bổ (bong bóng bộ nhớ, zswap). Các trang được phân bổ từ bộ nhớ này
	phạm vi sẽ không được bao gồm trong vmcore vì vậy không nên sử dụng phạm vi này nếu
	việc bán phá giá bộ nhớ vùng người dùng là có mục đích và người ta dự kiến rằng
	một số trang kernel di động có thể bị thiếu trong kết xuất.

Vẫn cần đặt trước hạt nhân sự cố tiêu chuẩn, như được mô tả ở trên
	để giữ kernel bị lỗi và initrd.

Tùy chọn này làm tăng nguy cơ xảy ra lỗi kdump: chuyển DMA
	được cấu hình bởi hạt nhân đầu tiên có thể làm hỏng hạt nhân thứ hai
	bộ nhớ của hạt nhân.

Phương thức đặt trước này dành cho các hệ thống không đủ khả năng
	hy sinh đủ bộ nhớ để đặt trước hạt nhân sự cố tiêu chuẩn và ở đâu
	kdump kém tin cậy hơn và có thể không đầy đủ thì tốt hơn là không có kdump tại
	tất cả.

Khởi động vào hạt nhân hệ thống
-----------------------
1) Cập nhật cấu hình bộ tải khởi động (chẳng hạn như grub, yaboot hoặc lilo)
   các tập tin khi cần thiết.

2) Khởi động kernel hệ thống với tham số khởi động "crashkernel=Y@X".

Trên x86 và x86_64, hãy sử dụng "crashkernel=Y[@X]". Hầu hết thời gian,
   địa chỉ bắt đầu 'X' là không cần thiết, kernel sẽ tìm kiếm địa chỉ phù hợp
   khu vực. Trừ khi một địa chỉ bắt đầu rõ ràng được mong đợi.

Trên ppc64, sử dụng "crashkernel=128M@32M".

Trên s390x, thường sử dụng "crashkernel=xxM". Giá trị của xx phụ thuộc
   về mức tiêu thụ bộ nhớ của hệ thống kdump. Nói chung đây không phải
   phụ thuộc vào kích thước bộ nhớ của hệ thống sản xuất.

Trên cánh tay, việc sử dụng "crashkernel=Y@X" không còn cần thiết nữa; cái
   kernel sẽ tự động định vị ảnh kernel bị lỗi trong
   512 MB đầu tiên của RAM nếu không cung cấp X.

Trên arm64, sử dụng "crashkernel=Y[@X]".  Lưu ý rằng địa chỉ bắt đầu của
   hạt nhân, X nếu được chỉ định rõ ràng, phải được căn chỉnh thành 2MiB (0x200000).

Tải hạt nhân thu thập dữ liệu
============================

Sau khi khởi động vào kernel hệ thống, kernel dump-capture cần được
đã tải.

Dựa trên kiến trúc và loại hình ảnh (có thể định vị lại hoặc không), một
có thể chọn tải vmlinux không nén hoặc bzImage/vmlinuz đã nén
của hạt nhân chụp kết xuất. Sau đây là bản tóm tắt.

Đối với i386 và x86_64:

- Sử dụng bzImage/vmlinuz nếu kernel có thể định vị lại được.
	- Sử dụng vmlinux nếu kernel không thể định vị lại được.

Đối với ppc64:

- Sử dụng vmlinux

Đối với s390x:

- Sử dụng hình ảnh hoặc bzImage

Đối với cánh tay:

- Sử dụng zImage

Đối với cánh tay64:

- Sử dụng vmlinux hoặc Image

Nếu bạn đang sử dụng hình ảnh vmlinux không nén thì hãy sử dụng lệnh sau
để tải kernel chụp kết xuất::

kexec -p <dump-capture-kernel-vmlinux-image> \
   --initrd=<initrd-for-dump-capture-kernel> --args-linux \
   --append="root=<root-dev> <arch-special-options>"

Nếu bạn đang sử dụng bzImage/vmlinuz đã nén, hãy sử dụng lệnh sau
để tải kernel chụp kết xuất::

kexec -p <dump-capture-kernel-bzImage> \
   --initrd=<initrd-for-dump-capture-kernel> \
   --append="root=<root-dev> <arch-special-options>"

Nếu bạn đang sử dụng zImage nén, hãy sử dụng lệnh sau
để tải kernel chụp kết xuất::

kexec --type zImage -p <dump-capture-kernel-bzImage> \
   --initrd=<initrd-for-dump-capture-kernel> \
   --dtb=<dtb-for-dump-capture-kernel> \
   --append="root=<root-dev> <arch-special-options>"

Nếu bạn đang sử dụng Hình ảnh không nén, hãy sử dụng lệnh sau
để tải kernel chụp kết xuất::

kexec -p <dump-capture-kernel-Image> \
   --initrd=<initrd-for-dump-capture-kernel> \
   --append="root=<root-dev> <arch-special-options>"

Sau đây là các tùy chọn dòng lệnh cụ thể của Arch sẽ được sử dụng trong khi
đang tải kernel chụp kết xuất.

Đối với i386 và x86_64:

"1 irqpoll nr_cpus=1 reset_devices"

Đối với ppc64:

"1 maxcpus=1 noirqdistrib reset_devices"

Đối với s390x:

"1 nr_cpus=1 cgroup_disable=bộ nhớ"

Đối với cánh tay:

"1 maxcpus=1 reset_devices"

Đối với cánh tay64:

"1 nr_cpus=1 reset_devices"

Lưu ý khi tải kernel chụp kết xuất:

* Theo mặc định, các tiêu đề ELF được lưu trữ ở định dạng ELF64 để hỗ trợ
  hệ thống có bộ nhớ lớn hơn 4GB. Trên i386, kexec tự động kiểm tra xem
  kích thước RAM vật lý vượt quá giới hạn 4 GB và nếu không, hãy sử dụng ELF32.
  Vì vậy, trên các hệ thống không phải PAE, ELF32 luôn được sử dụng.

Tùy chọn --elf32-core-headers có thể được sử dụng để buộc tạo ELF32
  tiêu đề. Điều này là cần thiết vì hiện tại GDB không thể mở được file vmcore
  với tiêu đề ELF64 trên hệ thống 32 bit.

* Tham số khởi động "irqpoll" giúp giảm lỗi khởi tạo trình điều khiển
  do các ngắt được chia sẻ trong kernel chụp kết xuất.

* Bạn phải chỉ định <root-dev> ở định dạng tương ứng với root
  tên thiết bị ở đầu ra của lệnh mount.

* Tham số khởi động "1" khởi động kernel chụp kết xuất vào một người dùng
  chế độ không có mạng. Nếu bạn muốn kết nối mạng, hãy sử dụng "3".

* Nói chung, chúng tôi không cần phải mở kernel SMP chỉ để nắm bắt
  đổ. Do đó, nhìn chung sẽ rất hữu ích nếu xây dựng một cơ chế thu thập kết xuất UP
  kernel hoặc chỉ định tùy chọn maxcpus=1 trong khi tải kernel chụp kết xuất.
  Lưu ý, mặc dù maxcpus luôn hoạt động nhưng tốt hơn hết bạn nên thay thế nó bằng
  nr_cpus để tiết kiệm bộ nhớ nếu được ARCH hiện tại hỗ trợ, chẳng hạn như x86.

* Bạn nên kích hoạt tính năng hỗ trợ nhiều CPU trong kernel dump-capture nếu bạn có ý định
  để sử dụng các chương trình đa luồng với nó, chẳng hạn như tính năng kết xuất song song của
  makedumpfile. Nếu không, chương trình đa luồng có thể có tác dụng tuyệt vời
  suy thoái hiệu suất. Để kích hoạt tính năng hỗ trợ nhiều CPU, bạn nên đưa ra một
  Kernel chụp kết xuất SMP và chỉ định các tùy chọn maxcpus/nr_cpus trong khi tải nó.

* Đối với s390x, có hai chế độ kdump: Nếu tiêu đề ELF được chỉ định bằng
  tham số kernel elfcorehdr=, nó được kernel kdump sử dụng vì nó
  được thực hiện trên tất cả các kiến trúc khác. Nếu không có tham số kernel elfcorehdr=
  được chỉ định, hạt nhân kdump s390x sẽ tự động tạo tiêu đề. các
  chế độ thứ hai có ưu điểm là đối với CPU và hotplug bộ nhớ, kdump có
  không được tải lại bằng kexec_load().

* Đối với hệ thống s390x có nhiều thiết bị đính kèm, kernel "cio_ignore"
  nên sử dụng tham số cho kernel kdump để ngăn chặn việc phân bổ
  bộ nhớ kernel cho các thiết bị không liên quan đến kdump. giống nhau
  áp dụng cho các hệ thống sử dụng thiết bị SCSI/FCP. Trong trường hợp đó
  Tham số mô-đun zfcp "allow_lun_scan" phải được đặt thành 0 trước
  cài đặt trực tuyến các thiết bị FCP.

hạt nhân hoảng loạn
============

Sau khi nạp thành công dump-capture kernel như trước
được mô tả, hệ thống sẽ khởi động lại vào kernel dump-capture nếu
sự cố hệ thống được kích hoạt.  Điểm kích hoạt nằm trong hoảng loạn(),
die(), die_nmi() và trong trình xử lý sysrq (ALT-SysRq-c).

Các điều kiện sau sẽ thực thi điểm kích hoạt sự cố:

Nếu phát hiện khóa cứng và "Cơ quan giám sát NMI" được định cấu hình, hệ thống
sẽ khởi động vào kernel chụp kết xuất ( die_nmi() ).

Nếu die() được gọi và đó là một thread có pid 0 hoặc 1 hoặc die()
được gọi bên trong ngữ cảnh ngắt hoặc die() được gọi và Panic_on_oops được đặt,
hệ thống sẽ khởi động vào kernel chụp kết xuất.

Trên các hệ thống powerpc khi thiết lập lại mềm được tạo, die() được gọi bởi tất cả các CPU
và hệ thống sẽ khởi động vào kernel chụp kết xuất.

Vì mục đích thử nghiệm, bạn có thể kích hoạt sự cố bằng cách sử dụng "ALT-SysRq-c",
"echo c > /proc/sysrq-trigger" hoặc viết một mô-đun để gây hoảng loạn.

Viết ra tệp kết xuất
=======================

Sau khi kernel chụp kết xuất được khởi động, hãy ghi tệp kết xuất với
lệnh sau::

cp /proc/vmcore <dump-file>

hoặc sử dụng scp để ghi tệp kết xuất giữa các máy chủ trên mạng, ví dụ::

scp /proc/vmcore remote_username@remote_ip:<dump-file>

Bạn cũng có thể sử dụng tiện ích makedumpfile để ghi ra tệp kết xuất
với các tùy chọn được chỉ định để lọc ra những nội dung không mong muốn, ví dụ::

makedumpfile -l --message-level 1 -d 31 /proc/vmcore <dump-file>

Phân tích
========

Trước khi phân tích ảnh kết xuất, bạn nên khởi động lại vào kernel ổn định.

Bạn có thể thực hiện phân tích hạn chế bằng cách sử dụng GDB trên tệp kết xuất được sao chép từ
/proc/vmcore. Sử dụng trình gỡ lỗi vmlinux được xây dựng bằng -g và chạy như sau
lệnh::

gdb vmlinux <tệp kết xuất>

Dấu vết ngăn xếp cho tác vụ trên bộ xử lý 0, hiển thị thanh ghi và bộ nhớ
màn hình hoạt động tốt.

Lưu ý: GDB không thể phân tích các tệp lõi được tạo ở định dạng ELF64 cho x86.
Trên các hệ thống có bộ nhớ tối đa 4GB, bạn có thể tạo
Tiêu đề định dạng ELF32 sử dụng tùy chọn hạt nhân --elf32-core-headers trên
đổ hạt nhân.

Bạn cũng có thể sử dụng tiện ích Crash để phân tích file dump trong Kdump
định dạng. Sự cố có sẵn tại URL sau:

ZZ0000ZZ

Tài liệu sự cố có thể được tìm thấy tại:
   ZZ0000ZZ

Kích hoạt Kdump trên WARN()
=======================

Tham số kernel, Panic_on_warn, gọi Panic() trong tất cả các đường dẫn WARN().  Cái này
sẽ gây ra lỗi kdump khi gọi phương thức Panic().  Trong trường hợp người dùng muốn
để chỉ định điều này trong thời gian chạy, /proc/sys/kernel/panic_on_warn có thể được đặt thành 1
để đạt được hành vi tương tự.

Kích hoạt Kdump trên add_taint()
============================

Tham số kernel Panic_on_taint tạo điều kiện cho lệnh gọi có điều kiện tới Panic()
từ bên trong add_taint() bất cứ khi nào giá trị được đặt trong bitmask này khớp với
cờ bit được đặt bởi add_taint().
Điều này sẽ gây ra kdump khi gọi add_taint()->panic().

Ghi tệp kết xuất vào ổ đĩa được mã hóa
============================================

CONFIG_CRASH_DM_CRYPT có thể được kích hoạt để hỗ trợ lưu tệp kết xuất vào một
ổ đĩa được mã hóa (hiện chỉ hỗ trợ x86_64). Không gian người dùng có thể tương tác
với /sys/kernel/config/crash_dm_crypt_keys để thiết lập,

1. Cho kernel đầu tiên biết cần có khóa đăng nhập nào để mở khóa ổ đĩa,
    Phím # Add #1
    mkdir /sys/kernel/config/crash_dm_crypt_keys/7d26b7b4-e342-4d2d-b660-7426b0996720
    Khóa # Add Mô tả của #1
    echo cryptsetup:7d26b7b4-e342-4d2d-b660-7426b0996720 > /sys/kernel/config/crash_dm_crypt_keys/description

# how hiện tại chúng ta có nhiều chìa khóa?
    mèo /sys/kernel/config/crash_dm_crypt_keys/count
    1

Phím # Add #2 theo cách tương tự

# how hiện tại chúng ta có nhiều chìa khóa?
    mèo /sys/kernel/config/crash_dm_crypt_keys/count
    2

# To hỗ trợ CPU/cắm nóng bộ nhớ, các phím tái sử dụng đã được lưu vào mục dự trữ
    # memory
    echo true > /sys/kernel/config/crash_dm_crypt_key/reuse

2. Tải kernel chụp kết xuất

3. Sau khi kerne dump-capture khởi động được, hãy khôi phục các phím cho khóa của người dùng
   echo có > /sys/kernel/crash_dm_crypt_keys/restore

Liên hệ
=======

- kexec@lists.infradead.org

Macro GDB
==========

.. include:: gdbmacros.txt
   :literal:
