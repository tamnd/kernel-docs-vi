.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/ext4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Thông tin chung về ext4
========================

Ext4 là cấp độ nâng cao của hệ thống tập tin ext3 kết hợp
cải tiến khả năng mở rộng và độ tin cậy để hỗ trợ các hệ thống tập tin lớn
(64 bit) phù hợp với dung lượng đĩa ngày càng tăng và công nghệ tiên tiến
yêu cầu về tính năng.

Danh sách gửi thư: linux-ext4@vger.kernel.org
Trang web: ZZ0000ZZ


Hướng dẫn sử dụng nhanh
========================

Lưu ý: Thông tin mở rộng hơn để bắt đầu với ext4 có thể
được tìm thấy tại trang wiki ext4 tại URL:
ZZ0000ZZ

- Phiên bản mới nhất của e2fsprogs có thể được tìm thấy tại:

ZZ0000ZZ

hoặc

ZZ0000ZZ

hoặc lấy kho git mới nhất từ:

ZZ0000ZZ

- Tạo một hệ thống tập tin mới sử dụng kiểu hệ thống tập tin ext4:

# mke2fs -t ext4 /dev/hda1

Hoặc để định cấu hình hệ thống tệp ext3 hiện có để hỗ trợ các phạm vi:

# tune2fs -O phạm vi/dev/hda1

Nếu hệ thống tập tin được tạo bằng các nút 128 byte, nó có thể
    được chuyển đổi để sử dụng 256 byte để có hiệu quả cao hơn thông qua:

# tune2fs -I 256 /dev/hda1

- Lắp đặt:

# mount -t ext4/dev/hda1/bất cứ nơi nào

- Khi so sánh hiệu suất với các hệ thống tập tin khác, luôn luôn
    điều quan trọng là phải thử nhiều khối lượng công việc; rất thường xuyên một sự thay đổi tinh tế trong một
    tham số khối lượng công việc có thể thay đổi hoàn toàn thứ hạng của nó
    hệ thống tập tin hoạt động tốt so với các hệ thống khác.  Khi so sánh với ext3,
    lưu ý rằng ext4 cho phép ghi các rào cản theo mặc định, trong khi ext3 thì có
    không bật rào cản ghi theo mặc định.  Vì vậy, nó rất hữu ích để sử dụng
    xác định rõ ràng liệu các rào cản có được kích hoạt hay không khi thông qua
    Tùy chọn gắn kết '-o Barrier=[0|1]' cho cả hệ thống tập tin ext3 và ext4
    để có sự so sánh công bằng.  Khi điều chỉnh ext3 để có số điểm chuẩn tốt nhất,
    bạn nên thử thay đổi chế độ ghi nhật ký dữ liệu; '-o
    data=writeback' có thể nhanh hơn đối với một số khối lượng công việc.  (Tuy nhiên lưu ý rằng
    chạy được gắn với data=writeback có thể để lại dữ liệu cũ
    được hiển thị trong các tệp được ghi gần đây trong trường hợp tắt máy không sạch sẽ,
    có thể gây nguy hiểm về bảo mật trong một số trường hợp.) Đang định cấu hình
    hệ thống tập tin với một tạp chí lớn cũng có thể hữu ích cho
    khối lượng công việc sử dụng nhiều siêu dữ liệu.

Đặc trưng
========

Hiện có sẵn
-------------------

* khả năng sử dụng hệ thống tập tin> 16TB (chưa hỗ trợ e2fspross)
* định dạng phạm vi giảm chi phí siêu dữ liệu (RAM, IO để truy cập, giao dịch)
* định dạng phạm vi mạnh mẽ hơn khi đối mặt với lỗi trên đĩa do phép thuật,
* dự phòng nội bộ trong cây
* cải thiện việc phân bổ tập tin (cấp phát nhiều khối)
* nâng giới hạn thư mục con 32000 do i_links_count[1] áp đặt
* Dấu thời gian nsec cho mtime, atime, ctime, tạo thời gian
* trường phiên bản inode trên đĩa (NFSv4, Lustre)
* giảm thời gian e2fsck thông qua tính năng uninit_bg
* kiểm tra nhật ký về độ bền, hiệu suất
* Phân bổ trước tệp liên tục (ví dụ: đối với phương tiện truyền phát trực tuyến, cơ sở dữ liệu)
* khả năng đóng gói các bitmap và bảng inode thành các nhóm ảo lớn hơn thông qua
  tính năng flex_bg
* hỗ trợ tập tin lớn
* phân bổ inode bằng cách sử dụng các nhóm khối ảo lớn thông qua flex_bg
* phân bổ chậm trễ
* hỗ trợ khối lớn (tối đa kích thước trang)
* chế độ đặt hàng mới hiệu quả trong JBD2 và ext4 (tránh sử dụng đầu đệm để buộc
  việc đặt hàng)
* Tra cứu tên tệp không phân biệt chữ hoa chữ thường
* hỗ trợ mã hóa dựa trên tệp (fscrypt)
* hỗ trợ xác thực dựa trên tệp (fsverity)

[1] Các hệ thống tập tin có kích thước khối 1k có thể thấy giới hạn do
cây băm thư mục có độ sâu tối đa là hai.

tra cứu tên tệp không phân biệt chữ hoa chữ thường
======================================================

Tính năng tra cứu tên tệp không phân biệt chữ hoa chữ thường được hỗ trợ trên
trên cơ sở mỗi thư mục, cho phép người dùng kết hợp giữa phân biệt chữ hoa chữ thường và
các thư mục phân biệt chữ hoa chữ thường trong cùng một hệ thống tập tin.  Nó được kích hoạt bởi
lật thuộc tính inode +F của một thư mục trống.  các
Hoạt động khớp chuỗi không phân biệt chữ hoa chữ thường chỉ được xác định khi chúng ta biết cách
văn bản được mã hóa theo chuỗi byte.  Vì lý do đó, để có thể kích hoạt
thư mục không phân biệt chữ hoa chữ thường, hệ thống tập tin phải có
tính năng casefold, lưu trữ mã hóa toàn hệ thống tập tin
mô hình được sử dụng.  Theo mặc định, bộ ký tự được sử dụng là phiên bản mới nhất của
Unicode (12.1.0, tại thời điểm viết bài này), được mã hóa trong UTF-8
hình thức.  Thuật toán so sánh được thực hiện bằng cách chuẩn hóa
chuỗi sang dạng phân rã Canonical, như được định nghĩa bởi Unicode,
theo sau là so sánh byte trên mỗi byte.

Nhận biết trường hợp là bảo toàn tên trên đĩa, nghĩa là tệp
tên được cung cấp bởi không gian người dùng khớp với từng byte trên byte thực tế
được ghi vào đĩa.  Định dạng chuẩn hóa Unicode được sử dụng bởi
do đó hạt nhân là một biểu diễn bên trong và không được tiếp xúc với
không gian người dùng cũng như vào đĩa, ngoại trừ các hàm băm đĩa quan trọng,
được sử dụng trên các thư mục lớn không phân biệt chữ hoa chữ thường với tính năng DX.  Trên DX
các thư mục, hàm băm phải được tính bằng cách sử dụng phiên bản được xếp dạng chữ hoa của
tên tệp, nghĩa là định dạng chuẩn hóa được sử dụng thực sự có một
tác động đến nơi mục nhập thư mục được lưu trữ.

Khi chúng ta thay đổi từ việc xem tên tệp dưới dạng chuỗi byte mờ sang xem
chúng dưới dạng các chuỗi được mã hóa, chúng ta cần giải quyết những gì xảy ra khi một chương trình
cố gắng tạo một tập tin có tên không hợp lệ.  Hệ thống con Unicode
trong kernel để lại quyết định phải làm gì trong trường hợp này cho
hệ thống tập tin, chọn hành vi ưa thích của nó bằng cách bật/tắt
chế độ nghiêm ngặt.  Khi Ext4 gặp một trong những chuỗi đó và
hệ thống tập tin không yêu cầu chế độ nghiêm ngặt, nó quay trở lại việc xem xét
toàn bộ chuỗi dưới dạng một chuỗi byte mờ, vẫn cho phép người dùng
hoạt động trên tệp đó, nhưng tra cứu không phân biệt chữ hoa chữ thường sẽ không hoạt động.

Tùy chọn
=======

Khi gắn hệ thống tập tin ext4, tùy chọn sau được chấp nhận:
(*) == mặc định

ro
        Gắn kết hệ thống tập tin chỉ đọc. Lưu ý rằng ext4 sẽ phát lại tạp chí (và
        do đó ghi vào phân vùng) ngay cả khi được gắn "chỉ đọc". gắn kết
        tùy chọn "ro,noload" có thể được sử dụng để ngăn việc ghi vào hệ thống tập tin.

tạp chí_checksum
        Cho phép kiểm tra tổng các giao dịch tạp chí.  Điều này sẽ cho phép
        mã khôi phục trong e2fsck và kernel để phát hiện lỗi trong
        hạt nhân.  Đó là một thay đổi tương thích và sẽ bị bỏ qua bởi các phiên bản cũ hơn.
        hạt nhân.

tạp chí_async_commit
        Khối cam kết có thể được ghi vào đĩa mà không cần chờ bộ mô tả
        khối. Nếu được kích hoạt, các hạt nhân cũ hơn không thể gắn thiết bị. Điều này sẽ
        kích hoạt 'journal_checksum' trong nội bộ.

tạp chí_path=đường dẫn, tạp chí_dev=devnum
        Khi số chính/số phụ của thiết bị nhật ký bên ngoài thay đổi,
        các tùy chọn này cho phép người dùng chỉ định vị trí tạp chí mới.  các
        thiết bị tạp chí được xác định thông qua các số chính/phụ mới của nó
        được mã hóa bằng devnum hoặc thông qua đường dẫn đến thiết bị.

không phục hồi, không tải
        Không tải tạp chí khi gắn.  Lưu ý rằng nếu hệ thống tập tin
        không được ngắt kết nối một cách sạch sẽ, việc bỏ qua việc phát lại nhật ký sẽ dẫn đến
        hệ thống tập tin chứa đựng sự không nhất quán có thể dẫn đến bất kỳ số lượng
        vấn đề.

dữ liệu=tạp chí
        Tất cả dữ liệu được đưa vào nhật ký trước khi ghi vào nhật ký
        hệ thống tập tin chính.  Bật chế độ này sẽ vô hiệu hóa việc phân bổ bị trì hoãn
        và hỗ trợ O_DIRECT.

dữ liệu=đã đặt hàng (*)
        Tất cả dữ liệu được buộc trực tiếp ra hệ thống tệp chính trước khi nó được xử lý.
        siêu dữ liệu được cam kết cho tạp chí.

dữ liệu=ghi lại
        Thứ tự dữ liệu không được bảo toàn, dữ liệu có thể được ghi vào file chính
        hệ thống sau khi siêu dữ liệu của nó đã được chuyển giao cho tạp chí.

cam kết=nrsec (*)
        Cài đặt này giới hạn độ tuổi tối đa của giao dịch đang chạy ở mức
        'nrsec' giây.  Giá trị mặc định là 5 giây.  Điều này có nghĩa là nếu
        bạn mất sức mạnh, bạn sẽ mất tối đa 5 giây cuối cùng của
        metadata changes (your filesystem will not be damaged though, thanks
        vào nhật ký). Giá trị mặc định này (hoặc bất kỳ giá trị thấp nào) sẽ gây tổn hại
        hiệu suất, nhưng nó tốt cho an toàn dữ liệu.  Đặt nó thành 0 sẽ có
        tác dụng tương tự như để nó ở mặc định (5 giây).  Thiết lập nó
        đến các giá trị rất lớn sẽ cải thiện hiệu suất.  Lưu ý rằng do
        phân bổ bị trì hoãn, ngay cả dữ liệu cũ hơn cũng có thể bị mất khi mất điện vì
        việc ghi lại những dữ liệu đó chỉ bắt đầu sau thời gian đã đặt
        /proc/sys/vm/dirty_expire_centisecs.

rào cản=<0|1(ZZ0000ZZ), không có rào cản
        Điều này cho phép/vô hiệu hóa việc sử dụng các rào cản ghi trong mã jbd.
        rào cản=0 vô hiệu hóa, rào cản=1 kích hoạt.  Điều này cũng yêu cầu ngăn xếp IO
        có thể hỗ trợ các rào cản và nếu jbd gặp lỗi trên rào cản
        viết, nó sẽ vô hiệu hóa lại với một cảnh báo.  Viết rào cản thực thi
        thứ tự thích hợp trên đĩa của các cam kết nhật ký, làm cho việc ghi đĩa dễ bay hơi
        bộ nhớ đệm an toàn để sử dụng, với một số hình phạt về hiệu suất.  Nếu đĩa của bạn
        được hỗ trợ bằng pin theo cách này hay cách khác, việc vô hiệu hóa các rào cản có thể an toàn
        cải thiện hiệu suất.  Các tùy chọn gắn kết "rào cản" và "không rào cản" có thể
        cũng được sử dụng để kích hoạt hoặc vô hiệu hóa các rào cản, nhằm thống nhất với các rào cản khác
        tùy chọn gắn kết ext4.

inode_readahead_blks=n
        Tham số điều chỉnh này kiểm soát số khối bảng inode tối đa
        Thuật toán đọc trước bảng inode của ext4 đó sẽ đọc trước vào
        bộ đệm đệm.  Giá trị mặc định là 32 khối.

  bsddf	(*)
        Make 'df' act like BSD.

minixdf
        Làm cho 'df' hoạt động giống như Minix.

  debug
        Extra debugging information is sent to syslog.

  abort
        Simulate the effects of calling ext4_abort() for debugging purposes.
        This is normally used while remounting a filesystem which is already
        mounted.

  errors=remount-ro
        Remount the filesystem read-only on an error.

  errors=continue
        Keep going on a filesystem error.

  errors=panic
        Panic and halt the machine if an error occurs.  (These mount options
        override the errors behavior specified in the superblock, which can be
        configured using tune2fs)

  data_err=ignore(*)
        Just print an error message if an error occurs in a file data buffer.

  data_err=abort
        Abort the journal if an error occurs in a file data buffer.

  grpid | bsdgroups
        New objects have the group ID of their parent.

  nogrpid (*) | sysvgroups
        New objects have the group ID of their creator.

  resgid=n
        The group ID which may use the reserved blocks.

  resuid=n
        The user ID which may use the reserved blocks.

  sb=
        Use alternate superblock at this location.

  quota, noquota, grpquota, usrquota
        These options are ignored by the filesystem. They are used only by
        quota tools to recognize volumes where quota should be turned on. See
        documentation in the quota-tools package for more details
        (http://sourceforge.net/projects/linuxquota).

  jqfmt=<quota type>, usrjquota=<file>, grpjquota=<file>
        These options tell filesystem details about quota so that quota
        information can be properly updated during journal replay. They replace
        the above quota options. See documentation in the quota-tools package
        for more details (http://sourceforge.net/projects/linuxquota).

  stripe=n
        Number of filesystem blocks that mballoc will try to use for allocation
        size and alignment. For RAID5/6 systems this should be the number of
        data disks *  RAID chunk size in file system blocks.

  delalloc	(*)
        Defer block allocation until just before ext4 writes out the block(s)
        in question.  This allows ext4 to better allocation decisions more
        efficiently.

  nodelalloc
        Disable delayed allocation.  Blocks are allocated when the data is
        copied from userspace to the page cache, either via the write(2) system
        call or when an mmap'ed page which was previously unallocated is
        written for the first time.

  max_batch_time=usec
        Maximum amount of time ext4 should wait for additional filesystem
        operations to be batch together with a synchronous write operation.
        Since a synchronous write operation is going to force a commit and then
        a wait for the I/O complete, it doesn't cost much, and can be a huge
        throughput win, we wait for a small amount of time to see if any other
        transactions can piggyback on the synchronous write.   The algorithm
        used is designed to automatically tune for the speed of the disk, by
        measuring the amount of time (on average) that it takes to finish
        committing a transaction.  Call this time the "commit time".  If the
        time that the transaction has been running is less than the commit
        time, ext4 will try sleeping for the commit time to see if other
        operations will join the transaction.   The commit time is capped by
        the max_batch_time, which defaults to 15000us (15ms).   This
        optimization can be turned off entirely by setting max_batch_time to 0.

  min_batch_time=usec
        This parameter sets the commit time (as described above) to be at least
        min_batch_time.  It defaults to zero microseconds.  Increasing this
        parameter may improve the throughput of multi-threaded, synchronous
        workloads on very fast disks, at the cost of increasing latency.

  journal_ioprio=prio
        The I/O priority (from 0 to 7, where 0 is the highest priority) which
        should be used for I/O operations submitted by kjournald2 during a
        commit operation.  This defaults to 3, which is a slightly higher
        priority than the default I/O priority.

  auto_da_alloc(*), noauto_da_alloc
        Many broken applications don't use fsync() when replacing existing
        files via patterns such as fd = open("foo.new")/write(fd,..)/close(fd)/
        rename("foo.new", "foo"), or worse yet, fd = open("foo",
        O_TRUNC)/write(fd,..)/close(fd).  If auto_da_alloc is enabled, ext4
        will detect the replace-via-rename and replace-via-truncate patterns
        and force that any delayed allocation blocks are allocated such that at
        the next journal commit, in the default data=ordered mode, the data
        blocks of the new file are forced to disk before the rename() operation
        is committed.  This provides roughly the same level of guarantees as
        ext3, and avoids the "zero-length" problem that can happen when a
        system crashes before the delayed allocation blocks are forced to disk.

  noinit_itable
        Do not initialize any uninitialized inode table blocks in the
        background.  This feature may be used by installation CD's so that the
        install process can complete as quickly as possible; the inode table
        initialization process would then be deferred until the next time the
        file system is unmounted.

  init_itable=n
        The lazy itable init code will wait n times the number of milliseconds
        it took to zero out the previous block group's inode table.  This
        minimizes the impact on the system performance while file system's
        inode table is being initialized.

  discard, nodiscard(*)
        Controls whether ext4 should issue discard/TRIM commands to the
        underlying block device when blocks are freed.  This is useful for SSD
        devices and sparse/thinly-provisioned LUNs, but it is off by default
        until sufficient testing has been done.

  nouid32
        Disables 32-bit UIDs and GIDs.  This is for interoperability  with
        older kernels which only store and expect 16-bit values.

  block_validity(*), noblock_validity
        These options enable or disable the in-kernel facility for tracking
        filesystem metadata blocks within internal data structures.  This
        allows multi- block allocator and other routines to notice bugs or
        corrupted allocation bitmaps which cause blocks to be allocated which
        overlap with filesystem metadata blocks.

  dioread_lock, dioread_nolock
        Controls whether or not ext4 should use the DIO read locking. If the
        dioread_nolock option is specified ext4 will allocate uninitialized
        extent before buffer write and convert the extent to initialized after
        IO completes. This approach allows ext4 code to avoid using inode
        mutex, which improves scalability on high speed storages. However this
        does not work with data journaling and dioread_nolock option will be
        ignored with kernel warning. Note that dioread_nolock code path is only
        used for extent-based files.  Because of the restrictions this options
        comprises it is off by default (e.g. dioread_lock).

  max_dir_size_kb=n
        This limits the size of directories so that any attempt to expand them
        beyond the specified limit in kilobytes will cause an ENOSPC error.
        This is useful in memory constrained environments, where a very large
        directory can cause severe performance problems or even provoke the Out
        Of Memory killer.  (For example, if there is only 512mb memory
        available, a 176mb directory may seriously cramp the system's style.)

  i_version
        Enable 64-bit inode version support. This option is off by default.

  dax
        Use direct access (no page cache).  See
        Documentation/filesystems/dax.rst.  Note that this option is
        incompatible with data=journal.

  inlinecrypt
        When possible, encrypt/decrypt the contents of encrypted files using the
        blk-crypto framework rather than filesystem-layer encryption. This
        allows the use of inline encryption hardware. The on-disk format is
        unaffected. For more details, see
        Documentation/block/inline-encryption.rst.

Data Mode
=========
There are 3 different data modes:

* writeback mode

  In data=writeback mode, ext4 does not journal data at all.  This mode provides
  a similar level of journaling as that of XFS and JFS in its default
  mode - metadata journaling.  A crash+recovery can cause incorrect data to
  appear in files which were written shortly before the crash.  This mode will
  typically provide the best ext4 performance.

* ordered mode

  In data=ordered mode, ext4 only officially journals metadata, but it logically
  groups metadata information related to data changes with the data blocks into
  a single unit called a transaction.  When it's time to write the new metadata
  out to disk, the associated data blocks are written first.  In general, this
  mode performs slightly slower than writeback but significantly faster than
  journal mode.

* journal mode

  data=journal mode provides full data and metadata journaling.  All new data is
  written to the journal first, and then to its final location.  In the event of
  a crash, the journal can be replayed, bringing both data and metadata into a
  consistent state.  This mode is the slowest except when data needs to be read
  from and written to disk at the same time where it outperforms all others
  modes.  Enabling this mode will disable delayed allocation and O_DIRECT
  support.

/proc entries
=============

Information about mounted ext4 file systems can be found in
/proc/fs/ext4.  Each mounted filesystem will have a directory in
/proc/fs/ext4 based on its device name (i.e., /proc/fs/ext4/hdc or
/proc/fs/ext4/dm-0).   The files in each per-device directory are shown
in table below.

Files in /proc/fs/ext4/<devname>

  mb_groups
        details of multiblock allocator buddy cache of free blocks

/sys entries
============

Information about mounted ext4 file systems can be found in
/sys/fs/ext4.  Each mounted filesystem will have a directory in
/sys/fs/ext4 based on its device name (i.e., /sys/fs/ext4/hdc or
/sys/fs/ext4/dm-0).   The files in each per-device directory are shown
in table below.

Files in /sys/fs/ext4/<devname>:

(see also Documentation/ABI/testing/sysfs-fs-ext4)

  delayed_allocation_blocks
        This file is read-only and shows the number of blocks that are dirty in
        the page cache, but which do not have their location in the filesystem
        allocated yet.

  inode_goal
        Tuning parameter which (if non-zero) controls the goal inode used by
        the inode allocator in preference to all other allocation heuristics.
        This is intended for debugging use only, and should be 0 on production
        systems.

  inode_readahead_blks
        Tuning parameter which controls the maximum number of inode table
        blocks that ext4's inode table readahead algorithm will pre-read into
        the buffer cache.

  lifetime_write_kbytes
        This file is read-only and shows the number of kilobytes of data that
        have been written to this filesystem since it was created.

  max_writeback_mb_bump
        The maximum number of megabytes the writeback code will try to write
        out before move on to another inode.

  mb_group_prealloc
        The multiblock allocator will round up allocation requests to a
        multiple of this tuning parameter if the stripe size is not set in the
        ext4 superblock

  mb_max_to_scan
        The maximum number of extents the multiblock allocator will search to
        find the best extent.

  mb_min_to_scan
        The minimum number of extents the multiblock allocator will search to
        find the best extent.

  mb_order2_req
        Tuning parameter which controls the minimum size for requests (as a
        power of 2) where the buddy cache is used.

  mb_stats
        Controls whether the multiblock allocator should collect statistics,
        which are shown during the unmount. 1 means to collect statistics, 0
        means not to collect statistics.

  mb_stream_req
        Files which have fewer blocks than this tunable parameter will have
        their blocks allocated out of a block group specific preallocation
        pool, so that small files are packed closely together.  Each large file
        will have its blocks allocated out of its own unique preallocation
        pool.

  session_write_kbytes
        This file is read-only and shows the number of kilobytes of data that
        have been written to this filesystem since it was mounted.

  reserved_clusters
        This is RW file and contains number of reserved clusters in the file
        system which will be used in the specific situations to avoid costly
        zeroout, unexpected ENOSPC, or possible data loss. The default is 2% or
        4096 clusters, whichever is smaller and this can be changed however it
        can never exceed number of clusters in the file system. If there is not
        enough space for the reserved space when mounting the file mount will
        _not_ fail.

Ioctls
======

Ext4 implements various ioctls which can be used by applications to access
ext4-specific functionality. An incomplete list of these ioctls is shown in the
table below. This list includes truly ext4-specific ioctls (``EXT4_IOC_*``) as
well as ioctls that may have been ext4-specific originally but are now supported
by some other filesystem(s) too (``FS_IOC_*``).

Table of Ext4 ioctls

  FS_IOC_GETFLAGS
        Get additional attributes associated with inode.  The ioctl argument is
        an integer bitfield, with bit values described in ext4.h.

  FS_IOC_SETFLAGS
        Set additional attributes associated with inode.  The ioctl argument is
        an integer bitfield, with bit values described in ext4.h.

  EXT4_IOC_GETVERSION, EXT4_IOC_GETVERSION_OLD
        Get the inode i_generation number stored for each inode. The
        i_generation number is normally changed only when new inode is created
        and it is particularly useful for network filesystems. The '_OLD'
        version of this ioctl is an alias for FS_IOC_GETVERSION.

  EXT4_IOC_SETVERSION, EXT4_IOC_SETVERSION_OLD
        Set the inode i_generation number stored for each inode. The '_OLD'
        version of this ioctl is an alias for FS_IOC_SETVERSION.

  EXT4_IOC_GROUP_EXTEND
        This ioctl has the same purpose as the resize mount option. It allows
        to resize filesystem to the end of the last existing block group,
        further resize has to be done with resize2fs, either online, or
        offline. The argument points to the unsigned logn number representing
        the filesystem new block count.

  EXT4_IOC_MOVE_EXT
        Move the block extents from orig_fd (the one this ioctl is pointing to)
        to the donor_fd (the one specified in move_extent structure passed as
        an argument to this ioctl). Then, exchange inode metadata between
        orig_fd and donor_fd.  This is especially useful for online
        defragmentation, because the allocator has the opportunity to allocate
        moved blocks better, ideally into one contiguous extent.

  EXT4_IOC_GROUP_ADD
        Add a new group descriptor to an existing or new group descriptor
        block. The new group descriptor is described by ext4_new_group_input
        structure, which is passed as an argument to this ioctl. This is
        especially useful in conjunction with EXT4_IOC_GROUP_EXTEND, which
        allows online resize of the filesystem to the end of the last existing
        block group.  Those two ioctls combined is used in userspace online
        resize tool (e.g. resize2fs).

  EXT4_IOC_MIGRATE
        This ioctl operates on the filesystem itself.  It converts (migrates)
        ext3 indirect block mapped inode to ext4 extent mapped inode by walking
        through indirect block mapping of the original inode and converting
        contiguous block ranges into ext4 extents of the temporary inode. Then,
        inodes are swapped. This ioctl might help, when migrating from ext3 to
        ext4 filesystem, however suggestion is to create fresh ext4 filesystem
        and copy data from the backup. Note, that filesystem has to support
        extents for this ioctl to work.

  EXT4_IOC_ALLOC_DA_BLKS
        Force all of the delay allocated blocks to be allocated to preserve
        application-expected ext3 behaviour. Note that this will also start
        triggering a write of the data blocks, but this behaviour may change in
        the future as it is not necessary and has been done this way only for
        sake of simplicity.

  EXT4_IOC_RESIZE_FS
        Resize the filesystem to a new size.  The number of blocks of resized
        filesystem is passed in via 64 bit integer argument.  The kernel
        allocates bitmaps and inode table, the userspace tool thus just passes
        the new number of blocks.

  EXT4_IOC_SWAP_BOOT
        Swap i_blocks and associated attributes (like i_blocks, i_size,
        i_flags, ...) from the specified inode with inode EXT4_BOOT_LOADER_INO
        (#5). This is typically used to store a boot loader in a secure part of
        the filesystem, where it can't be changed by a normal user by accident.
        The data blocks of the previous boot loader will be associated with the
        given inode.

References
==========

kernel source:	<file:fs/ext4/>
		<file:fs/jbd2/>

programs:	http://e2fsprogs.sourceforge.net/

useful links:	https://fedoraproject.org/wiki/ext3-devel
		http://www.bullopensource.org/ext4/
		http://ext4.wiki.kernel.org/index.php/Main_Page
		https://fedoraproject.org/wiki/Features/Ext4