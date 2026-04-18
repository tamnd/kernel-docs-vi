.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/lockstat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Thống kê khóa
===============

Cái gì
====

Như tên cho thấy, nó cung cấp số liệu thống kê về ổ khóa.


Tại sao
===

Bởi vì những thứ như tranh chấp khóa có thể ảnh hưởng nghiêm trọng đến hiệu suất.

Làm sao
===

Lockdep đã có các móc nối trong các chức năng khóa và ánh xạ các trường hợp khóa tới
khóa các lớp học. Chúng tôi xây dựng dựa trên đó (xem Tài liệu/khóa/lockdep-design.rst).
Biểu đồ dưới đây cho thấy mối quan hệ giữa các chức năng khóa và các chức năng khác nhau.
móc trong đó::

__có được
            |
           khóa _____
            |        \
            |    __ tranh cãi
            ZZ0000ZZ
            |       <đợi>
            | _______/
            |/
            |
       __có được
            |
            .
          <giữ>
            .
            |
       __thả ra
            |
         mở khóa

khóa, mở khóa - các chức năng khóa thông thường
  __* - cái móc
  <> - tiểu bang

Với những cái móc này, chúng tôi cung cấp số liệu thống kê sau:

bị trả lại
	- số lượng tranh chấp khóa liên quan đến dữ liệu x-cpu
 sự tranh chấp
	- số lần mua lại khóa phải chờ
 thời gian chờ đợi
     phút
	- thời gian ngắn nhất (không phải 0) mà chúng tôi từng phải chờ khóa
     tối đa
	- thời gian lâu nhất mà chúng tôi phải chờ khóa
     tổng cộng
	- tổng thời gian chúng tôi dành để chờ đợi khóa này
     trung bình
	- thời gian trung bình dành cho việc chờ đợi khóa này
 acq bị trả lại
	- số lần mua lại khóa liên quan đến dữ liệu x-cpu
 mua lại
	- số lần chúng tôi lấy khóa
 giữ thời gian
     phút
	- thời gian ngắn nhất (không phải 0) mà chúng tôi từng giữ khóa
     tối đa
	- thời gian lâu nhất chúng ta từng giữ ổ khóa
     tổng cộng
	- tổng thời gian khóa này được giữ
     trung bình
	- thời gian trung bình khóa này được giữ

Những con số này được tập hợp trên mỗi lớp khóa, trên mỗi trạng thái đọc/ghi (khi
áp dụng).

Nó cũng theo dõi 4 điểm tranh chấp cho mỗi lớp. Một điểm tranh chấp là một địa điểm cuộc gọi
phải chờ mua lại khóa.

Cấu hình
-------------

Thống kê khóa được kích hoạt thông qua CONFIG_LOCK_STAT.

Cách sử dụng
-----

Cho phép thu thập số liệu thống kê::

# echo 1 >/proc/sys/kernel/lock_stat

Vô hiệu hóa việc thu thập số liệu thống kê::

# echo 0 >/proc/sys/kernel/lock_stat

Nhìn vào số liệu thống kê khóa hiện tại::

(số dòng không phải là một phần của đầu ra thực tế, được thực hiện để giải thích rõ ràng
    bên dưới )

# less /proc/lock_stat

01 lock_stat phiên bản 0.4
  02-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  03 tên lớp bị trả lại tranh chấp waittime-min waittime-max waittime-total waittime-avg acq-bounces mua lại holdtime-min holdtime-max holdtime-total holdtime-avg
  04-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
  05
  06 &mm->mmap_sem-W: 46 84 0,26 939,10 16371,53 194,90 47291 2922365 0,16 2220301,69 17464026916,32 5975,99
  07 &mm->mmap_sem-R: 37 100 1,31 299502,61 325629,52 3256,30 212344 34316685 0,10 7744,91 95016910,20 2,77
  08 ---------------
  09 &mm->mmap_sem 1 [<ffffffff811502a7>] khugepaged_scan_mm_slot+0x57/0x280
  10 &mm->mmap_sem 96 [<ffffffff815351c4>] __do_page_fault+0x1d4/0x510
  11 &mm->mmap_sem 34 [<ffffffff81113d77>] vm_mmap_pgoff+0x87/0xd0
  12 &mm->mmap_sem 17 [<ffffffff81127e71>] vm_munmap+0x41/0x80
  13 ---------------
  14 &mm->mmap_sem 1 [<ffffffff81046fda>] dup_mmap+0x2a/0x3f0
  15 &mm->mmap_sem 60 [<ffffffff81129e29>] SyS_mprotect+0xe9/0x250
  16 &mm->mmap_sem 41 [<ffffffff815351c4>] __do_page_fault+0x1d4/0x510
  17 &mm->mmap_sem 68 [<ffffffff81113d77>] vm_mmap_pgoff+0x87/0xd0
  18
  19.................................................................................................................................................................................................
  20
  21 unix_table_lock: 110 112 0,21 49,24 163,91 1,46 21094 66312 0,12 624,42 31589,81 0,48
  22 ---------------
  23 unix_table_lock 45 [<ffffffff8150ad8e>] unix_create1+0x16e/0x1b0
  24 unix_table_lock 47 [<ffffffff8150b111>] unix_release_sock+0x31/0x250
  25 unix_table_lock 15 [<ffffffff8150ca37>] unix_find_other+0x117/0x230
  26 unix_table_lock 5 [<ffffffff8150a09f>] unix_autobind+0x11f/0x1b0
  27 ---------------
  28 unix_table_lock 39 [<ffffffff8150b111>] unix_release_sock+0x31/0x250
  29 unix_table_lock 49 [<ffffffff8150ad8e>] unix_create1+0x16e/0x1b0
  30 unix_table_lock 20 [<ffffffff8150ca37>] unix_find_other+0x117/0x230
  31 unix_table_lock 4 [<ffffffff8150a09f>] unix_autobind+0x11f/0x1b0


Đoạn trích này hiển thị số liệu thống kê về hai lớp khóa đầu tiên. Dòng 01 hiển thị
phiên bản đầu ra - mỗi khi định dạng thay đổi, phiên bản này sẽ được cập nhật. Dòng 02-04
hiển thị tiêu đề với các mô tả cột. Dòng 05-18 và 20-31 hiển thị thực tế
số liệu thống kê. Những số liệu thống kê này có hai phần; số liệu thống kê thực tế được phân tách bằng dấu
dấu phân cách ngắn (dòng 08, 13) từ các điểm tranh chấp.

Dòng 09-12 hiển thị 4 điểm tranh chấp được ghi đầu tiên (mã
cố gắng lấy khóa) và dòng 14-17 hiển thị 4 ghi đầu tiên
điểm tranh chấp (người giữ khóa). Có thể là tối đa
điểm con-bounce bị thiếu trong số liệu thống kê.

Khóa đầu tiên (05-18) là khóa đọc/ghi và hiển thị hai dòng phía trên
dải phân cách ngắn. Các điểm tranh chấp không khớp với mô tả cột,
chúng có hai: nội dung và biểu tượng [<IP>]. Trận tranh chấp thứ hai
điểm là những điểm chúng ta đang tranh cãi.

Phần nguyên của các giá trị thời gian nằm trong chúng ta.

Xử lý các khóa lồng nhau, các lớp con có thể xuất hiện::

32.................................................................................................................................................................................................................
  33
  34 &rq->khóa: 13128 13128 0,43 190,53 103881,26 7,91 97454 3453404 0,00 401,11 13224683,11 3,82
  35 ---------
  36 &rq->lock 645 [<ffffffff8103bfc4>] task_rq_lock+0x43/0x75
  37 &rq->lock 297 [<ffffffff8104ba65>] try_to_wake_up+0x127/0x25a
  38 &rq->lock 360 [<ffffffff8103c4c5>] select_task_rq_fair+0x1f0/0x74a
  39 &rq->lock 428 [<ffffffff81045f98>] Scheduler_tick+0x46/0x1fb
  40 ---------
  41 &rq->khóa 77 [<ffffffff8103bfc4>] task_rq_lock+0x43/0x75
  42 &rq->lock 174 [<ffffffff8104ba65>] try_to_wake_up+0x127/0x25a
  43 &rq->lock 4715 [<ffffffff8103ed4b>] double_rq_lock+0x42/0x54
  44 &rq->khóa 893 [<ffffffff81340524>] lịch+0x157/0x7b8
  45
  46.................................................................................................................................................................................................................
  47
  48 &rq->lock/1: 1526 11488 0,33 388,73 136294,31 11,86 21461 38404 0,00 37,93 109388,53 2,84
  49 ----------
  50 &rq->lock/1 11526 [<ffffffff8103ed58>] double_rq_lock+0x4f/0x54
  51 ----------
  52 &rq->lock/1 5645 [<ffffffff8103ed4b>] double_rq_lock+0x42/0x54
  53 &rq->lock/1 1224 [<ffffffff81340524>] lịch+0x157/0x7b8
  54 &rq->lock/1 4336 [<ffffffff8103ed58>] double_rq_lock+0x4f/0x54
  55 &rq->lock/1 181 [<ffffffff8104ba65>] try_to_wake_up+0x127/0x25a

Dòng 48 hiển thị số liệu thống kê cho lớp con thứ hai (/1) của &rq->lock lớp
(lớp con bắt đầu từ 0), vì trong trường hợp này, như dòng 50 gợi ý,
double_rq_lock thực sự có được một khóa gồm hai khóa xoay lồng nhau.

Xem các khóa cạnh tranh hàng đầu::

# grep : /proc/lock_stat | cái đầu
			clockevents_lock: 2926159 2947636 0,15 46882,81 1784540466,34 605,41 3381345 3879161 0,00 2260,97 53178395,68 13,71
		     tick_broadcast_lock: 346460 346717 0,18 2257,43 39364622,71 113,54 3642919 4242696 0,00 2263,79 49173646,60 11,59
		  &mapping->i_mmap_mutex: 203896 203899 3,36 645530,05 31767507988,39 155800,21 3361776 8893984 0,17 2254,15 14110121,02 1,59
			       &rq->khóa: 135014 136909 0,18 606,09 842160,68 6,15 1540728 10436146 0,00 728,72 17606683,41 1,69
	       &(&zone->lru_lock)->rlock: 93000 94934 0,16 59,18 188253,78 1,98 1199912 3809894 0,15 391,40 3559518,81 0,93
			 danh sách nhiệm vụ_lock-W: 40667 41130 0,23 1189,42 428980,51 10,43 270278 510106 0,16 653,51 3939674,91 7,72
			 tasklist_lock-R: 21298 21305 0,20 1310,05 215511,12 10,12 186204 241258 0,14 1162,33 1179779,23 4,89
			      rcu_node_1: 47656 49022 0,16 635,41 193616,41 3,95 844888 1865423 0,00 764,26 1656226,96 0,89
       &(&dentry->d_lockref.lock)->rlock: 39791 40179 0,15 1302,08 88851,96 2,21 2790851 12527025 0,10 1910,75 3379714,27 0,27
			      rcu_node_0: 29203 30064 0,16 786,55 1555573,00 51,74 88963 244254 0,00 398,87 428872,51 1,76

Xóa số liệu thống kê::

# echo 0 > /proc/lock_stat
