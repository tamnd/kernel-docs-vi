.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/irq/irq-affinity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Mối quan hệ SMP IRQ
===================

Nhật ký thay đổi:
	- Bắt đầu bởi Ingo Molnar <mingo@redhat.com>
	- Cập nhật bởi Max Krasnyansky <maxk@qualcomm.com>


/proc/irq/IRQ#/smp_affinity và /proc/irq/IRQ#/smp_affinity_list chỉ định
CPU mục tiêu nào được phép cho nguồn IRQ nhất định.  Đó là một mặt nạ bit
(smp_affinity) hoặc danh sách CPU (smp_affinity_list) của các CPU được phép.  Nó không phải
được phép tắt tất cả các CPU và nếu bộ điều khiển IRQ không hỗ trợ
Mối quan hệ IRQ thì giá trị sẽ không thay đổi so với mặc định của tất cả các CPU.

/proc/irq/default_smp_affinity chỉ định mặt nạ ái lực mặc định được áp dụng
tới tất cả các IRQ không hoạt động. Khi IRQ được phân bổ/kích hoạt bitmask ái lực của nó
sẽ được đặt thành mặt nạ mặc định. Sau đó nó có thể được thay đổi như mô tả ở trên.
Mặt nạ mặc định là 0xffffffff.

Dưới đây là ví dụ về việc hạn chế IRQ44 (eth1) ở CPU0-3 sau đó hạn chế
nó tới CPU4-7 (đây là hộp 8-CPU SMP)::

[root@moon 44]# cd /proc/irq/44
	[root@moon 44]# cat smp_affinity
	ffffffff

[root@moon 44]# echo 0f > smp_affinity
	[root@moon 44]# cat smp_affinity
	0000000f
	[root@moon 44]# ping -f h
	Địa ngục PING (195.4.7.3): 56 byte dữ liệu
	...
--- thống kê ping chết tiệt ---
	6029 gói được truyền, 6027 gói được nhận, mất gói 0%
	khứ hồi tối thiểu/trung bình/tối đa = 0,1/0,1/0,4 ms
	[root@moon 44]# cat /proc/ngắt ZZ0000ZZ44:'
		CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7
	44: 1068 1785 1785 1783 0 0 0 0 IO-APIC cấp eth1

Như có thể thấy từ dòng trên IRQ44 chỉ được giao cho bốn người đầu tiên
bộ xử lý (0-3).
Bây giờ, hãy giới hạn IRQ đó ở CPU(4-7).

::

[root@moon 44]# echo f0 > smp_affinity
	[root@moon 44]# cat smp_affinity
	000000f0
	[root@moon 44]# ping -f h
	Địa ngục PING (195.4.7.3): 56 byte dữ liệu
	..
--- thống kê ping chết tiệt ---
	2779 gói được truyền, 2777 gói được nhận, mất gói 0%
	hành trình khứ hồi tối thiểu/trung bình/tối đa = 0,1/0,5/585,4 ms
	[root@moon 44]# cat /proc/ngắt ZZ0000ZZ44:'
		CPU0 CPU1 CPU2 CPU3 CPU4 CPU5 CPU6 CPU7
	44: 1068 1785 1785 1783 1784 1069 1070 1069 IO-APIC cấp eth1

Lần này IRQ44 chỉ được phân phối cho bốn bộ xử lý cuối cùng.
tức là bộ đếm của CPU0-3 không thay đổi.

Đây là một ví dụ về việc giới hạn IRQ (44) tương tự đó cho các CPU 1024 đến 1031::

[root@moon 44]# echo 1024-1031 > smp_affinity_list
	[root@moon 44]# cat smp_affinity_list
	1024-1031

Lưu ý rằng để thực hiện điều này với mặt nạ bit sẽ cần 32 bitmask bằng 0
để làm theo cái thích hợp.
