.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cgroup-v1/memcg_test.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================================
Bản ghi nhớ triển khai Bộ điều khiển tài nguyên bộ nhớ (Memcg)
=====================================================

Cập nhật lần cuối: 2010/2

Phiên bản hạt nhân cơ sở: dựa trên 2.6.33-rc7-mm(ứng cử viên cho 34).

Vì VM ngày càng phức tạp (một trong những lý do là memcg...), hành vi của memcg
là phức tạp. Đây là tài liệu về hành vi nội bộ của memcg.
Xin lưu ý rằng chi tiết triển khai có thể được thay đổi.

(*) Các chủ đề trên API phải có trong Documentation/admin-guide/cgroup-v1/memory.rst)

0. Làm thế nào để ghi lại việc sử dụng?
========================

2 đối tượng được sử dụng

page_cgroup ....một đối tượng trên mỗi trang.

Được phân bổ khi khởi động hoặc cắm nóng bộ nhớ. Giải phóng tại bộ nhớ nóng loại bỏ.

swap_cgroup ... một mục nhập cho mỗi swp_entry.

Được phân bổ tại swapon(). Được giải phóng tại swapoff().

Page_cgroup có bit USED và không bao giờ đếm gấp đôi so với page_cgroup
   xảy ra. swap_cgroup chỉ được sử dụng khi một trang bị tính phí bị hoán đổi.

1. Sạc
=========

một trang/swp_entry có thể bị tính phí (mức sử dụng += PAGE_SIZE) tại

mem_cgroup_try_charge()

2. Nạp tiền
===========

một trang/swp_entry có thể không bị tính phí (mức sử dụng -= PAGE_SIZE) bởi

mem_cgroup_uncharge()
	  Được gọi khi số lượt truy cập của trang giảm xuống 0.

mem_cgroup_uncharge_swap()
	  Được gọi khi số refcnt của swp_entry giảm xuống 0. Phí trao đổi
	  biến mất.

3. thu phí-cam kết-hủy bỏ
=======================

Các trang Memcg được tính phí theo hai bước:

- mem_cgroup_try_charge()
		- mem_cgroup_commit_charge() hoặc mem_cgroup_cancel_charge()

Tại try_charge(), không có cờ nào cho biết "trang này đã bị tính phí".
	tại thời điểm này, mức sử dụng += PAGE_SIZE.

Tại commit(), trang được liên kết với memcg.

Tại cancel(), chỉ cần sử dụng -= PAGE_SIZE.

Theo phần giải thích bên dưới, chúng tôi giả sử CONFIG_SWAP=y.

4. Ẩn danh
============

Trang ẩn danh mới được phân bổ tại
		  - lỗi trang vào ánh xạ MAP_ANONYMOUS.
		  - Sao chép-ghi.

4.1 Hoán đổi.
	Khi trao đổi, trang được lấy từ bộ đệm trao đổi. Có 2 trường hợp.

(a) Nếu SwapCache mới được phân bổ và đọc, nó sẽ không bị tính phí.
	(b) Nếu SwapCache đã được ánh xạ bởi các tiến trình, thì nó đã được
	    đã tính phí rồi.

4.2 Hoán đổi.
	Khi hoán đổi, quá trình chuyển đổi trạng thái điển hình như sau.

(a) thêm vào bộ đệm trao đổi. (được đánh dấu là SwapCache)
	    số lần phản hồi của swp_entry += 1.
	(b) hoàn toàn chưa được lập bản đồ.
	    lượt giới thiệu của swp_entry += số điểm # of.
	(c) viết lại để trao đổi.
	(d) xóa khỏi bộ đệm trao đổi. (xóa khỏi SwapCache)
	    số lần phản hồi của swp_entry -= 1.


Cuối cùng, khi thoát nhiệm vụ,
	(e) zap_pte() được gọi và refcnt của swp_entry -=1 -> 0.

5. Bộ đệm trang
=============

Bộ đệm trang được tính phí tại
	- filemap_add_folio().

Logic rất rõ ràng. (Về di chuyển, xem bên dưới)

Lưu ý:
	  __filemap_remove_folio() được gọi bởi filemap_remove_folio()
	  và __remove_mapping().

6. Bộ nhớ đệm trang Shmem(tmpfs)
===========================

Cách tốt nhất để hiểu quá trình chuyển đổi trạng thái trang của shmem là đọc
	mm/shmem.c.

Nhưng lời giải thích ngắn gọn về hành vi của memcg xung quanh shmem sẽ là
	hữu ích để hiểu logic.

Trang của Shmem (chỉ trang lá, không phải khối trực tiếp/gián tiếp) có thể bật

- cây cơ số của inode của shmem.
		- Hoán đổi bộ đệm.
		- Cả trên cây cơ số và SwapCache. Điều này xảy ra khi trao đổi
		  và hoán đổi,

Nó được tính phí khi...

- Một trang mới được thêm vào cây cơ số của shmem.
	- Một trang swp được đọc. (chuyển khoản phí từ swap_cgroup sang page_cgroup)

7. Di chuyển trang
=================

mem_cgroup_migrate()

8. LRU
======
Mỗi memcg có vectơ LRU riêng (anon không hoạt động, anon hoạt động,
	tệp không hoạt động, tệp đang hoạt động, không thể xóa) của các trang từ mỗi nút,
	mỗi LRU được xử lý theo một lru_lock duy nhất cho memcg và nút đó.

9. Các bài kiểm tra điển hình.
=================

Các thử nghiệm cho các trường hợp không phù hợp.

9.1 Giới hạn nhỏ đối với memcg.
-------------------------

Khi bạn thực hiện kiểm tra để thực hiện trường hợp đặc biệt, bạn nên đặt giới hạn của memcg là một thử nghiệm tốt
	rất nhỏ chứ không phải GB. Nhiều chủng tộc được tìm thấy trong thử nghiệm dưới
	giới hạn xKB hoặc xxMB.

(Hành vi bộ nhớ dưới GB và trạng thái bộ nhớ dưới MB hiển thị rất
	tình huống khác.)

9.2 Shmem
---------

Trong lịch sử, việc xử lý shmem của memcg rất kém và chúng tôi đã thấy một số lượng
	về những rắc rối ở đây. Điều này là do shmem là bộ đệm trang nhưng có thể
	Hoán đổi bộ đệm. Kiểm tra bằng shmem/tmpfs luôn là bài kiểm tra tốt.

9.3 Di chuyển
-------------

Đối với NUMA, việc di chuyển là một trường hợp đặc biệt khác. Để làm bài kiểm tra dễ dàng, cpuset
	rất hữu ích. Sau đây là tập lệnh mẫu để thực hiện di chuyển::

mount -t cgroup -o cpuset none /opt/cpuset

mkdir /opt/cpuset/01
		echo 1 > /opt/cpuset/01/cpuset.cpus
		echo 0 > /opt/cpuset/01/cpuset.mems
		echo 1 > /opt/cpuset/01/cpuset.memory_migrate
		mkdir /opt/cpuset/02
		echo 1 > /opt/cpuset/02/cpuset.cpus
		echo 1 > /opt/cpuset/02/cpuset.mems
		echo 1 > /opt/cpuset/02/cpuset.memory_migrate

Trong tập hợp trên, khi bạn di chuyển một tác vụ từ 01 sang 02, việc di chuyển trang sang
	nút 0 đến nút 1 sẽ xảy ra. Sau đây là một đoạn script để di chuyển tất cả
	dưới cpuset.::

--
		move_task()
		{
		cho pid bằng $1
		làm
			/bin/echo $pid >$2/tác vụ 2>/dev/null
			echo -n $pid
			tiếng vang -n " "
		xong
		tiếng vang END
		}

G1_TASK=ZZ0000ZZ
		G2_TASK=ZZ0001ZZ
		move_task "${G1_TASK}" ${G2} &
		--

9.4 Cắm nóng bộ nhớ
------------------

Kiểm tra cắm nóng bộ nhớ là một trong những thử nghiệm tốt.

vào bộ nhớ ngoại tuyến, hãy làm như sau::

# echo ngoại tuyến > /sys/devices/system/memory/memoryXXX/state

(XXX là nơi chứa bộ nhớ)

Đây cũng là một cách dễ dàng để kiểm tra việc di chuyển trang.

9,5 nhóm lồng nhau
------------------

Sử dụng các thử nghiệm như sau để kiểm tra các nhóm lồng nhau::

mkdir /opt/cgroup/01/child_a
		mkdir /opt/cgroup/01/child_b

đặt giới hạn thành 01.
		thêm giới hạn vào 01/child_b
		chạy các công việc dưới child_a và child_b

tạo/xóa các nhóm sau một cách ngẫu nhiên trong khi công việc đang chạy::

/opt/cgroup/01/child_a/child_aa
		/opt/cgroup/01/child_b/child_bb
		/opt/cgroup/01/child_c

điều hành công việc mới trong nhóm mới cũng tốt.

9.6 Gắn kết với các hệ thống con khác
-------------------------------

Việc gắn kết với các hệ thống con khác là một thử nghiệm tốt vì có một
	phụ thuộc vào chủng tộc và khóa với các hệ thống con cgroup khác.

ví dụ::

# mount -t cgroup none /cgroup -o cpuset,bộ nhớ,cpu,thiết bị

và thực hiện di chuyển tác vụ, mkdir, rmdir, v.v... bên dưới phần này.

hoán đổi 9,7
-----------

Bên cạnh việc quản lý trao đổi là một trong những phần phức tạp của memcg,
	đường dẫn cuộc gọi trao đổi tại thời điểm trao đổi không giống với đường dẫn trao đổi thông thường..
	Nó có giá trị để được kiểm tra một cách rõ ràng.

Ví dụ: kiểm tra như sau là tốt:

(Vỏ-A)::

# mount -t cgroup none /cgroup -o bộ nhớ
		# mkdir /cgroup/kiểm tra
		# echo 40M > /cgroup/test/memory.limit_in_bytes
		# echo 0 > /cgroup/test/tasks

Chạy chương trình malloc(100M) theo phần này. Bạn sẽ thấy 60 triệu giao dịch hoán đổi.

(Shell-B)::

# move tất cả các tác vụ trong /cgroup/test tới /cgroup
		# /sbin/hoán đổi -a
		# rmdir /cgroup/kiểm tra
		Nhiệm vụ malloc # kill.

Tất nhiên, tmpfs v.s. kiểm tra hoán đổi cũng nên được kiểm tra.

9.8 OOM-Kẻ giết người
--------------

Hết bộ nhớ do giới hạn của memcg sẽ giết chết các tác vụ trong
	memcg. Khi hệ thống phân cấp được sử dụng, một nhiệm vụ trong hệ thống phân cấp
	sẽ bị giết bởi kernel.

Trong trường hợp này, không nên gọi Panic_on_oom và các tác vụ
	trong các nhóm khác không nên bị giết.

Không khó để gây ra OOM theo memcg như sau.

Trường hợp A) khi bạn có thể trao đổi ::

#swapoff-a
		#echo 50M > /memory.limit_in_bytes

chạy 51 triệu malloc

Trường hợp B) khi bạn sử dụng giới hạn mem+swap::

#echo 50M > bộ nhớ.limit_in_bytes
		#echo 50M > bộ nhớ.memsw.limit_in_bytes

chạy 51 triệu malloc

9.9 Di chuyển phí khi di chuyển nhiệm vụ
----------------------------------

Các khoản phí liên quan đến một nhiệm vụ có thể được di chuyển cùng với việc di chuyển nhiệm vụ.

(Vỏ-A)::

#mkdir /cgroup/A
		#echo $$ >/cgroup/A/tasks

chạy một số chương trình sử dụng một lượng bộ nhớ trong/cgroup/A.

(Shell-B)::

#mkdir /cgroup/B
		#echo 1 >/cgroup/B/memory.move_charge_at_immigrate
		#echo "pid của chương trình đang chạy trong nhóm A" >/cgroup/B/tasks

Bạn có thể thấy các khoản phí đã được chuyển bằng cách đọc ZZ0000ZZ hoặc
	Memory.stat của cả A và B.

Xem phần 8.2 của Documentation/admin-guide/cgroup-v1/memory.rst để biết giá trị nào sẽ
	được ghi vào move_charge_at_immigrate.

9.10 Ngưỡng bộ nhớ
----------------------

Bộ điều khiển bộ nhớ thực hiện ngưỡng bộ nhớ bằng thông báo cgroups
	API. Bạn có thể sử dụng tools/cgroup/cgroup_event_listener.c để kiểm tra nó.

(Shell-A) Tạo cgroup và chạy trình xử lý sự kiện::

# mkdir /cgroup/A
		# ./cgroup_event_listener /cgroup/A/memory.usage_in_bytes 5M

(Shell-B) Thêm tác vụ vào nhóm và cố gắng phân bổ và giải phóng bộ nhớ ::

# echo $$ >/cgroup/A/tasks
		# a="$(dd if=/dev/zero bs=1M count=10)"
		# a=

Bạn sẽ thấy tin nhắn từ cgroup_event_listener mỗi khi bạn vượt qua
	các ngưỡng.

Sử dụng /cgroup/A/memory.memsw.usage_in_bytes để kiểm tra ngưỡng memsw.

Bạn cũng nên kiểm tra nhóm gốc.
