.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/tmpfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
tmpfs
=====

Tmpfs là một hệ thống tệp lưu giữ tất cả các tệp của nó trong bộ nhớ ảo.


Mọi thứ trong tmpfs đều là tạm thời theo nghĩa là sẽ không có tệp nào được lưu trữ.
được tạo trên ổ cứng của bạn. Nếu bạn ngắt kết nối một phiên bản tmpfs,
mọi thứ được lưu trữ trong đó đều bị mất.

tmpfs đặt mọi thứ vào bộ nhớ đệm bên trong của kernel và phát triển và
co lại để chứa các tập tin chứa trong đó và có thể trao đổi
các trang không cần thiết được loại bỏ để hoán đổi không gian, nếu tính năng hoán đổi được bật cho tmpfs
gắn kết. tmpfs cũng hỗ trợ THP.

tmpfs mở rộng ramf với một vài tùy chọn có thể định cấu hình không gian người dùng được liệt kê và
được giải thích thêm bên dưới, một số trong đó có thể được cấu hình lại một cách linh hoạt trên
bay bằng cách sử dụng remount ('mount -o remount ...') của hệ thống tập tin. Một tmpfs
hệ thống tập tin có thể được thay đổi kích thước nhưng nó không thể được thay đổi kích thước thành kích thước thấp hơn kích thước hiện tại của nó
cách sử dụng. tmpfs cũng hỗ trợ ACL POSIX và các thuộc tính mở rộng cho
không gian tên đáng tin cậy.ZZ0000ZZ và user.*. ramfs không sử dụng trao đổi và bạn
không thể sửa đổi bất kỳ tham số nào cho hệ thống tập tin ramfs. Giới hạn kích thước của một đoạn đường nối
hệ thống tập tin là dung lượng bộ nhớ bạn có sẵn và vì vậy phải cẩn thận nếu
sử dụng như vậy để không bị hết bộ nhớ.

Một cách thay thế cho tmpfs và ramfs là sử dụng brd để tạo đĩa RAM
(/dev/ram*), cho phép bạn mô phỏng đĩa thiết bị khối trong RAM vật lý.
Để ghi dữ liệu, bạn chỉ cần tạo một hệ thống tệp thông thường ở trên cùng
đĩa ram này. Giống như ramf, brd ramdisks không thể hoán đổi. brd ramdisk cũng vậy
được định cấu hình về kích thước khi khởi tạo và bạn không thể thay đổi kích thước chúng một cách linh hoạt.
Trái ngược với brd ramdisks, tmpfs có hệ thống tập tin riêng, nó không dựa vào
lớp khối nào cả.

Vì tmpfs tồn tại hoàn toàn trong bộ đệm trang và tùy chọn trên trao đổi,
tất cả các trang tmpfs sẽ được hiển thị dưới dạng "Shmem" trong /proc/meminfo và "Được chia sẻ" trong
miễn phí(1). Lưu ý rằng các bộ đếm này cũng bao gồm bộ nhớ dùng chung
(shmem, xem ipcs(1)). Cách đáng tin cậy nhất để có được số lượng là
sử dụng df(1) và du(1).

tmpfs có các công dụng sau:

1) Luôn có một mount bên trong kernel mà bạn sẽ không thấy ở đó
   tất cả. Điều này được sử dụng để ánh xạ ẩn danh được chia sẻ và SYSV được chia sẻ
   trí nhớ.

Giá treo này không phụ thuộc vào CONFIG_TMPFS. Nếu CONFIG_TMPFS không
   được thiết lập, phần hiển thị của người dùng của tmpfs không được tạo. Nhưng nội bộ
   cơ chế luôn tồn tại.

2) glibc 2.2 trở lên mong đợi các tmpfs sẽ được gắn tại /dev/shm cho
   Bộ nhớ chia sẻ POSIX (shm_open, shm_unlink). Thêm những điều sau đây
   dòng tới /etc/fstab nên quan tâm đến vấn đề này ::

tmpfs/dev/shm tmpfs mặc định 0 0

Hãy nhớ tạo thư mục mà bạn định gắn tmpfs vào
   nếu cần thiết.

Giá đỡ này _không_ cần thiết cho bộ nhớ dùng chung SYSV. nội bộ
   mount được sử dụng cho việc đó. (Trong phiên bản kernel 2.3, nó là
   cần thiết để gắn kết tiền thân của tmpfs (shm fs) để sử dụng SYSV
   bộ nhớ chia sẻ.)

3) Một số người (bao gồm cả tôi) thấy việc gắn nó rất thuận tiện
   ví dụ: trên/tmp và/var/tmp và có phân vùng trao đổi lớn. Và bây giờ
   việc gắn kết vòng lặp của các tệp tmpfs hoạt động, vì vậy hầu hết mkinitrd đều được vận chuyển
   các bản phân phối sẽ thành công với tmpfs /tmp.

4) Và có lẽ còn nhiều điều nữa mà tôi chưa biết :-)


tmpfs có ba tùy chọn gắn kết để định cỡ:

===========================================================================
size Giới hạn số byte được phân bổ cho phiên bản tmpfs này. các
           mặc định là một nửa RAM vật lý của bạn mà không cần trao đổi. Nếu bạn
           quá lớn các phiên bản tmpfs của bạn, máy sẽ bế tắc
           vì trình xử lý OOM sẽ không thể giải phóng bộ nhớ đó.
nr_blocks Giống như kích thước, nhưng ở dạng khối PAGE_SIZE.
nr_inodes Số lượng nút tối đa cho trường hợp này. Mặc định
           bằng một nửa số trang RAM thực tế của bạn hoặc (trên
           máy có highmem) số lượng trang RAM có mem thấp,
           cái nào thấp hơn.
===========================================================================

Các tham số này chấp nhận hậu tố k, m hoặc g cho kilo, mega và giga và
có thể được thay đổi khi gắn lại.  Tham số kích thước cũng chấp nhận hậu tố %
để giới hạn phiên bản tmpfs này ở tỷ lệ phần trăm của RAM vật lý của bạn:
mặc định, khi cả kích thước lẫn nr_blocks đều không được chỉ định, là size=50%

Nếu nr_blocks=0 (hoặc size=0), các khối sẽ không bị giới hạn trong trường hợp đó;
nếu nr_inodes=0, inode sẽ không bị giới hạn.  Nói chung là không khôn ngoan khi
gắn kết với các tùy chọn như vậy, vì nó cho phép bất kỳ người dùng nào có quyền truy cập ghi vào
sử dụng hết bộ nhớ trên máy; nhưng tăng cường khả năng mở rộng của
trường hợp đó trong một hệ thống có nhiều CPU sử dụng nó nhiều.

Nếu nr_inodes khác 0, không gian giới hạn dành cho inode đó cũng được sử dụng hết bởi
thuộc tính mở rộng: Iused và IUse% của "df -i" tăng, IFree giảm.

Các khối tmpfs có thể được hoán đổi khi thiếu bộ nhớ.
tmpfs có tùy chọn gắn kết để vô hiệu hóa việc sử dụng trao đổi:

====== =================================================================
noswap Vô hiệu hóa trao đổi. Việc gắn lại phải tôn trọng cài đặt gốc.
        Theo mặc định trao đổi được kích hoạt.
====== =================================================================

tmpfs cũng hỗ trợ các Trang lớn trong suốt yêu cầu kernel
được cấu hình với CONFIG_TRANSPARENT_HUGEPAGE và được hỗ trợ rất nhiều cho
hệ thống của bạn (has_transparent_hugepage(), là kiến trúc cụ thể).
Các tùy chọn gắn kết cho việc này là:

=====================================================================================
Huge=Never Không phân bổ các trang lớn.  Đây là mặc định.
Huge=always Cố gắng phân bổ trang lớn mỗi khi cần một trang mới.
Huge=within_size Chỉ phân bổ trang lớn nếu nó hoàn toàn nằm trong i_size.
                 Cũng tôn trọng gợi ý madvise(2).
Huge=Advise Chỉ phân bổ trang lớn nếu được yêu cầu với madvise(2).
=====================================================================================

Xem thêm Tài liệu/admin-guide/mm/transhuge.rst, mô tả
sysfs /sys/kernel/mm/transparent_hugepage/shmem_enabled: có thể
được sử dụng để từ chối các trang lớn trên tất cả các mount tmpfs trong trường hợp khẩn cấp hoặc để
buộc các trang lớn trên tất cả các giá trị tmpfs để thử nghiệm.

tmpfs cũng hỗ trợ hạn ngạch với các tùy chọn gắn kết sau

===============================================================================
hạn ngạch Kế toán và thực thi hạn ngạch người dùng và nhóm
                         được kích hoạt trên mount. Tmpfs đang sử dụng ẩn
                         các tệp hạn ngạch hệ thống được khởi tạo khi gắn kết.
usrquota Tính toán và thực thi hạn ngạch người dùng được bật
                         trên núi.
grpquota Tính năng thực thi và tính toán hạn ngạch của Nhóm grpquota được kích hoạt
                         trên núi.
usrquota_block_hardlimit Đặt giới hạn cứng khối hạn ngạch người dùng toàn cầu.
usrquota_inode_hardlimit Đặt giới hạn cứng inode hạn ngạch người dùng toàn cầu.
grpquota_block_hardlimit Đặt giới hạn cứng khối hạn ngạch nhóm toàn cầu.
grpquota_inode_hardlimit Đặt giới hạn cứng inode hạn ngạch nhóm toàn cầu.
===============================================================================

Không có tùy chọn gắn kết nào liên quan đến hạn ngạch có thể được đặt hoặc thay đổi khi gắn lại.

Các tham số giới hạn hạn ngạch chấp nhận hậu tố k, m hoặc g cho kilo, mega và giga
và không thể thay đổi khi đếm lại. Giới hạn hạn ngạch toàn cầu mặc định đang được áp dụng
có hiệu lực đối với bất kỳ và tất cả người dùng/nhóm/dự án ngoại trừ quyền root trong lần đầu tiên
mục nhập hạn ngạch cho người dùng/nhóm/id dự án đang được truy cập - thường là
lần đầu tiên một nút có quyền sở hữu id cụ thể được tạo sau
gắn kết. Nói cách khác, thay vì các giới hạn được khởi tạo bằng 0,
chúng được khởi tạo với giá trị cụ thể được cung cấp cùng với các giá trị gắn kết này
tùy chọn. Các giới hạn có thể được thay đổi đối với bất kỳ id người dùng/nhóm nào vào bất kỳ lúc nào khi chúng
bình thường có thể được.

Lưu ý rằng hạn ngạch tmpfs không hỗ trợ không gian tên người dùng nên không có uid/gid
quá trình dịch được thực hiện nếu hạn ngạch được bật trong không gian tên người dùng.

tmpfs có tùy chọn gắn kết để đặt chính sách cấp phát bộ nhớ NUMA cho
tất cả các tệp trong trường hợp đó (nếu CONFIG_NUMA được bật) - có thể
được điều chỉnh nhanh chóng thông qua 'mount -o remount ...'

===========================================================================
mpol=default sử dụng chính sách phân bổ quy trình
                         (xem set_mempolicy(2))
mpol=prefer:Node thích phân bổ bộ nhớ từ Node đã cho
mpol=bind:NodeList chỉ phân bổ bộ nhớ từ các nút trong NodeList
mpol=interleave thích phân bổ lần lượt từ mỗi nút
mpol=interleave:NodeList lần lượt phân bổ từ mỗi nút của NodeList
mpol=local thích phân bổ bộ nhớ từ nút cục bộ
===========================================================================

Định dạng NodeList là danh sách các số và phạm vi thập phân được phân tách bằng dấu phẩy,
một phạm vi là hai số thập phân được phân tách bằng dấu gạch nối, số nhỏ nhất và
số nút lớn nhất trong phạm vi.  Ví dụ: mpol=bind:0-3,5,7,9-15

Chính sách bộ nhớ có NodeList hợp lệ sẽ được lưu, như được chỉ định, cho
sử dụng tại thời điểm tạo tập tin.  Khi một tác vụ phân bổ một tệp trong tệp
hệ thống, chính sách bộ nhớ tùy chọn gắn kết sẽ được áp dụng với NodeList,
nếu có, được sửa đổi bởi các ràng buộc cpuset của tác vụ gọi
[Xem Tài liệu/admin-guide/cgroup-v1/cpusets.rst] và mọi cờ tùy chọn,
được liệt kê dưới đây.  Nếu NodeLists kết quả là tập trống, thì hiệu quả
chính sách bộ nhớ cho tệp sẽ trở lại chính sách "mặc định".

Chính sách cấp phát bộ nhớ của NUMA có các cờ tùy chọn có thể được sử dụng trong
kết hợp với các chế độ của chúng.  Những cờ tùy chọn này có thể được chỉ định
khi tmpfs được gắn kết bằng cách thêm chúng vào chế độ trước NodeList.
Xem Documentation/admin-guide/mm/numa_memory_policy.rst để biết danh sách
tất cả các cờ chế độ chính sách phân bổ bộ nhớ có sẵn và ảnh hưởng của chúng lên
chính sách bộ nhớ

::

=static tương đương với MPOL_F_STATIC_NODES
	=tương đối tương đương với MPOL_F_RELATIVE_NODES

Ví dụ: mpol=bind=static:NodeList, tương đương với một
chính sách phân bổ của MPOL_BIND | MPOL_F_STATIC_NODES.

Lưu ý rằng việc cố gắng gắn tmpfs bằng tùy chọn mpol sẽ không thành công nếu
kernel đang chạy không hỗ trợ NUMA; và sẽ thất bại nếu nodelist của nó
chỉ định một nút không trực tuyến.  Nếu hệ thống của bạn dựa vào đó
tmpfs đang được gắn kết, nhưng đôi khi chạy một kernel được xây dựng mà không có
Khả năng NUMA (có thể là kernel khôi phục an toàn) hoặc có ít nút hơn
trực tuyến, thì nên bỏ tùy chọn mpol khỏi tự động
tùy chọn gắn kết.  Nó có thể được thêm vào sau khi tmpfs đã được gắn kết
trên MountPoint, bởi 'mount -o remount,mpol=Policy:NodeList MountPoint'.


Để chỉ định thư mục gốc ban đầu, bạn có thể sử dụng mount sau
tùy chọn:

==== =====================================
chế độ Các quyền dưới dạng số bát phân
uid ID người dùng
gid ID nhóm
==== =====================================

Các tùy chọn này không có bất kỳ ảnh hưởng nào đến việc đếm lại. Bạn có thể thay đổi những điều này
tham số với chmod(1), chown(1) và chgrp(1) trên hệ thống tệp được gắn.


tmpfs có tùy chọn gắn kết để chọn xem nó sẽ bọc ở nút 32 hay 64 bit
số:

======= ===========================
inode64 Sử dụng số inode 64 bit
inode32 Sử dụng số inode 32 bit
======= ===========================

Trên kernel 32 bit, inode32 là ẩn và inode64 bị từ chối tại thời điểm gắn kết.
Trên kernel 64-bit, CONFIG_TMPFS_INODE64 đặt mặc định.  inode64 tránh
khả năng có nhiều tệp có cùng số nút trên một thiết bị;
nhưng có nguy cơ glibc bị lỗi với EOVERFLOW khi đạt đến số lượng inode 33 bit -
nếu một tmpfs tồn tại lâu dài được truy cập bởi các ứng dụng 32-bit cổ xưa đến mức
mở tệp lớn hơn 2GiB không thành công với EINVAL.


Vì vậy, 'mount -t tmpfs -o size=10G,nr_inodes=10k,mode=700 tmpfs /mytmpfs'
sẽ cung cấp cho bạn phiên bản tmpfs trên/mytmpfs có thể phân bổ 10GB
RAM/SWAP ở 10240 nút và chỉ có thể truy cập được bằng root.

tmpfs có các tùy chọn gắn sau để hỗ trợ tra cứu không phân biệt chữ hoa chữ thường:

======================================================================================
casefold Kích hoạt hỗ trợ casefold tại điểm gắn kết này bằng cách sử dụng
                  đối số làm tiêu chuẩn mã hóa. Hiện tại chỉ có UTF-8
                  mã hóa được hỗ trợ. Nếu không có đối số nào được sử dụng, nó sẽ tải
                  mã hóa UTF-8 mới nhất hiện có.
strict_encoding Kích hoạt tính năng mã hóa nghiêm ngặt tại điểm gắn kết này (bị vô hiệu hóa bởi
                  mặc định). Ở chế độ này, hệ thống tập tin từ chối tạo tập tin
                  và thư mục có tên chứa ký tự UTF-8 không hợp lệ.
======================================================================================

Tùy chọn này không hiển thị toàn bộ hệ thống tập tin không phân biệt chữ hoa chữ thường. Người ta cần phải
vẫn đặt cờ casefold cho mỗi thư mục bằng cách lật thuộc tính +F trong một
thư mục trống. Tuy nhiên, các thư mục mới sẽ kế thừa thuộc tính này. các
bản thân điểm gắn kết không thể phân biệt chữ hoa chữ thường.

Ví dụ::

$ mount -t tmpfs -o casefold=utf8-12.1.0,strict_encoding fs_name /mytmpfs
    $ mount -t tmpfs -o casefold fs_name /mytmpfs


:Tác giả:
   Christoph Rohland <cr@sap.com>, 1.12.01
:Đã cập nhật:
   Hugh Dickins, ngày 4 tháng 6 năm 2007
:Đã cập nhật:
   KOSAKI Motohiro, ngày 16 tháng 3 năm 2010
:Đã cập nhật:
   Chris Down, ngày 13 tháng 7 năm 2020
:Đã cập nhật:
   André Almeida, ngày 23 tháng 8 năm 2024