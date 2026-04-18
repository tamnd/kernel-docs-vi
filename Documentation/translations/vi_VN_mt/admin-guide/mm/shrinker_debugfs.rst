.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/shrinker_debugfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Giao diện gỡ lỗi Shrinker
==========================

Giao diện gỡ lỗi Shrinker cung cấp khả năng hiển thị vào bộ nhớ kernel
hệ thống con bộ thu nhỏ và cho phép lấy thông tin về từng bộ thu nhỏ
và tương tác với họ.

Đối với mỗi bộ thu nhỏ được đăng ký trong hệ thống, một thư mục trong ZZ0000ZZ
được tạo ra. Tên của thư mục được tạo từ tên của trình thu gọn và một
id duy nhất: ví dụ: ZZ0001ZZ hoặc ZZ0002ZZ.

Mỗi thư mục thu nhỏ chứa các tệp ZZ0000ZZ và ZZ0001ZZ, cho phép
kích hoạt lệnh gọi lại ZZ0002ZZ và ZZ0003ZZ cho mỗi memcg và
nút numa (nếu có).

Cách sử dụng:
------

1. ZZ0000ZZ

  ::

$ cd /sys/kernel/debug/shrinker/
    $ ls
    dquota-cache-16 sb-devpts-28 sb-proc-47 sb-tmpfs-42
    mm-shadow-18 sb-devtmpfs-5 sb-proc-48 sb-tmpfs-43
    mm-zspool:zram0-34 sb-hugetlbfs-17 sb-pstore-31 sb-tmpfs-44
    rcu-kfree-0 sb-hugetlbfs-33 sb-rootfs-2 sb-tmpfs-49
    sb-aio-20 sb-iomem-12 sb-securityfs-6 sb-tracefs-13
    sb-anon_inodefs-15 sb-mqueue-21 sb-selinuxfs-22 sb-xfs:vda1-36
    sb-bdev-3 sb-nsfs-4 sb-sockfs-8 sb-zsmalloc-19
    sb-bpf-32 sb-pipefs-14 sb-sysfs-26 thp-deferred_split-10
    sb-btrfs:vda2-24 sb-proc-25 sb-tmpfs-1 thp-zero-9
    sb-cgroup2-30 sb-proc-39 sb-tmpfs-27 xfs-buf:vda1-37
    sb-configfs-23 sb-proc-41 sb-tmpfs-29 xfs-inodegc:vda1-38
    sb-dax-11 sb-proc-45 sb-tmpfs-35
    sb-debugfs-7 sb-proc-46 sb-tmpfs-40

2. ZZ0000ZZ

  ::

$ cd sb-btrfs\:vda2-24/
    $ ls
    quét đếm

3. ZZ0000ZZ

Mỗi dòng trong đầu ra có định dạng sau ::

<cgroup inode id> <nr đối tượng trên nút 0> <nr đối tượng trên nút 1> ...
    <cgroup inode id> <nr đối tượng trên nút 0> <nr đối tượng trên nút 1> ...
    ...

Nếu không có đối tượng nào trên tất cả các nút numa thì một dòng sẽ bị bỏ qua. Nếu có
  không có đối tượng nào cả, đầu ra có thể trống.

Nếu bộ thu nhỏ không nhận biết được memcg hoặc CONFIG_MEMCG bị tắt, 0 sẽ được in
  dưới dạng id cgroup inode. Nếu bộ thu nhỏ không nhận biết được số, số 0 sẽ được in
  cho tất cả các nút ngoại trừ nút đầu tiên.
  ::

số lượng mèo $
    1 224 2
    21 98 0
    55 818 10
    2367 2 0
    2401 30 0
    225 13 0
    599 35 0
    939 124 0
    1041 3 0
    1075 1 0
    1109 1 0
    1279 60 0
    1313 7 0
    1347 39 0
    1381 3 0
    1449 14 0
    1483 63 0
    1517 53 0
    1551 6 0
    1585 1 0
    1619 6 0
    1653 40 0
    1687 11 0
    1721 8 0
    1755 4 0
    1789 52 0
    1823 888 0
    1857 1 0
    1925 2 0
    1959 32 0
    2027 22 0
    2061 9 0
    2469 799 0
    2537 861 0
    2639 1 0
    2707 70 0
    2775 4 0
    2877 84 0
    293 1 0
    735 8 0

4. ZZ0000ZZ

Định dạng đầu vào dự kiến::

<cgroup inode id> <numa id> <số lượng đối tượng cần quét>

Dành cho trình thu gọn không nhận biết memcg hoặc trên hệ thống không có bộ nhớ
  cgrups ZZ0000ZZ phải được chuyển dưới dạng id cgroup.
  ::

$ cd /sys/kernel/debug/shrinker/
    $ cd sb-btrfs\:vda2-24/

$ đếm mèo | đầu -n 5
    1 212 0
    21 97 0
    55 802 5
    2367 2 0
    225 13 0

$ echo "55 0 200"> quét

$ đếm mèo | đầu -n 5
    1 212 0
    21 96 0
    55 752 5
    2367 2 0
    225 13 0
