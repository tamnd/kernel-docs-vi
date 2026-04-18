.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/accounting/delay-accounting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Trì hoãn kế toán
==================

Nhiệm vụ gặp phải sự chậm trễ khi thực hiện khi chúng chờ đợi
để một số tài nguyên hạt nhân có sẵn, ví dụ: một
tác vụ có thể chạy được có thể đợi CPU miễn phí chạy tiếp.

Các biện pháp chức năng tính toán độ trễ theo từng nhiệm vụ
sự chậm trễ mà một nhiệm vụ gặp phải trong khi

a) chờ CPU (trong khi có thể chạy được)
b) hoàn thành khối I/O đồng bộ được khởi tạo bởi tác vụ
c) hoán đổi trong các trang
d) lấy lại bộ nhớ
e) đập
f) compact trực tiếp
g) bản sao chống ghi
h) IRQ/SOFTIRQ

và cung cấp những số liệu thống kê này cho không gian người dùng thông qua
giao diện taskstats

Sự chậm trễ như vậy cung cấp phản hồi để thiết lập mức độ ưu tiên CPU của tác vụ,
giá trị ưu tiên io và giới hạn rss một cách thích hợp. Sự chậm trễ kéo dài cho
các nhiệm vụ quan trọng có thể là yếu tố thúc đẩy việc nâng cao mức độ ưu tiên tương ứng của nó.

Chức năng này, thông qua việc sử dụng giao diện taskstats, cũng cung cấp
thống kê độ trễ được tổng hợp cho tất cả các tác vụ (hoặc luồng) thuộc về một
nhóm luồng (tương ứng với quy trình Unix truyền thống). Đây là một điều phổ biến
sự tổng hợp cần thiết được thực hiện hiệu quả hơn bởi kernel.

Các tiện ích không gian người dùng, đặc biệt là các ứng dụng quản lý tài nguyên, cũng có thể
thống kê độ trễ tổng hợp thành các nhóm tùy ý. Để kích hoạt tính năng này, hãy trì hoãn
số liệu thống kê của một nhiệm vụ có sẵn cả trong thời gian tồn tại của nó cũng như trên
thoát ra, đảm bảo việc giám sát liên tục và đầy đủ có thể được thực hiện.


Giao diện
---------

Tính toán độ trễ sử dụng giao diện taskstats được mô tả
chi tiết trong một tài liệu riêng biệt trong thư mục này. Taskstats trả về một
cấu trúc dữ liệu chung cho không gian người dùng tương ứng với per-pid và per-tgid
số liệu thống kê. Chức năng tính toán độ trễ sẽ điền vào các trường cụ thể của
cấu trúc này. Nhìn thấy

bao gồm/uapi/linux/taskstats.h

để biết mô tả về các trường liên quan đến việc tính toán độ trễ.
Nói chung nó sẽ ở dạng bộ đếm trả về giá trị tích lũy
độ trễ được thấy đối với cpu, I/O khối đồng bộ, trao đổi, lấy lại bộ nhớ, trang thrash
bộ đệm, nén trực tiếp, bản sao chống ghi, IRQ/SOFTIRQ, v.v.

Lấy hiệu của hai số đọc liên tiếp của một số đã cho
bộ đếm (giả sử cpu_delay_total) cho một tác vụ sẽ gây ra độ trễ
được trải nghiệm bởi nhiệm vụ đang chờ tài nguyên tương ứng
trong khoảng đó.

Khi một nhiệm vụ thoát ra, các bản ghi chứa số liệu thống kê cho mỗi nhiệm vụ
được gửi đến không gian người dùng mà không cần lệnh. Nếu đó là lần thoát cuối cùng
nhiệm vụ của một nhóm luồng, số liệu thống kê trên mỗi tgid cũng được gửi. Thêm chi tiết
được đưa ra trong phần mô tả giao diện taskstats.

Tiện ích không gian người dùng getdelays.c trong thư mục công cụ/kế toán cho phép đơn giản
các lệnh sẽ được chạy và số liệu thống kê độ trễ tương ứng sẽ được hiển thị. Nó
cũng đóng vai trò là một ví dụ về việc sử dụng giao diện taskstats.

Cách sử dụng
-----

Biên dịch kernel với::

CONFIG_TASK_DELAY_ACCT=y
	CONFIG_TASKSTATS=y

Tính toán độ trễ bị tắt theo mặc định khi khởi động.
Để kích hoạt, hãy thêm::

sự chậm trễ

vào các tùy chọn khởi động kernel. Phần còn lại của hướng dẫn bên dưới giả sử điều này có
đã được thực hiện. Ngoài ra, hãy sử dụng sysctl kernel.task_delayacct để chuyển trạng thái
vào thời gian chạy. Tuy nhiên, xin lưu ý rằng chỉ những tác vụ được bắt đầu sau khi kích hoạt nó mới có
thông tin chậm trễ.

Sau khi hệ thống khởi động xong, hãy sử dụng tiện ích
tương tự như getdelays.c để truy cập độ trễ
được nhìn thấy bởi một nhiệm vụ nhất định hoặc một nhóm nhiệm vụ (tgid).
Tiện ích này cũng cho phép một lệnh nhất định được
được thực thi và độ trễ tương ứng sẽ được
nhìn thấy.

Định dạng chung của lệnh getdelays::

getdelays [-dilv] [-t tgid] [-p pid]

Nhận được độ trễ kể từ khi khởi động hệ thống đối với pid 10::

# ./getdelays -d -p 10
	(đầu ra tương tự với trường hợp tiếp theo)

Nhận tổng và mức độ trễ cao nhất kể từ khi khởi động hệ thống cho tất cả các pid có tgid 242::

bash-4.4# ./getdelays -d -t 242
	số liệu thống kê độ trễ in BẬT
	TGID 242


CPU đếm tổng số thực ảo tổng độ trễ tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	               46 188000000 192348334 4098012 0,089ms 0,429260ms 0,051205ms 2026-01-15T15:06:58
	Độ trễ đếm IO tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	                0 0 0,000ms 0,000000ms 0,000000ms Không áp dụng
	SWAP độ trễ đếm tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	                0 0 0,000ms 0,000000ms 0,000000ms Không áp dụng
	RECLAIM độ trễ đếm tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	                0 0 0,000ms 0,000000ms 0,000000ms Không áp dụng
	THRASHING độ trễ đếm tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	                0 0 0,000ms 0,000000ms 0,000000ms Không áp dụng
	COMPACT độ trễ đếm tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	                0 0 0,000ms 0,000000ms 0,000000ms Không áp dụng
	WPCOPY độ trễ đếm tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	              182 19413338 0,107ms 0,547353ms 0,022462ms 2026-01-15T15:05:24
	IRQ độ trễ đếm tổng độ trễ độ trễ trung bình độ trễ tối đa độ trễ tối thiểu dấu thời gian tối đa
	                0 0 0,000ms 0,000000ms 0,000000ms Không áp dụng

Nhận IO hạch toán cho pid 1, nó chỉ hoạt động với -p::

# ./getdelays -i -p 1
	in ấn kế toán IO
	linuxrc: đọc=65536, viết=0, cancel_write=0

Lệnh trên có thể được sử dụng với -v để có thêm thông tin gỡ lỗi.

Sau khi hệ thống khởi động, hãy sử dụng ZZ0000ZZ để nhận thông tin về độ trễ trên toàn hệ thống,
bao gồm thông tin PSI trên toàn hệ thống và các tác vụ có độ trễ cao Top-N.
Lưu ý: Hỗ trợ PSI yêu cầu ZZ0001ZZ và ZZ0002ZZ để có đầy đủ chức năng.

ZZ0000ZZ là một công cụ tương tác để theo dõi áp lực hệ thống và độ trễ của nhiệm vụ.
Nó hỗ trợ nhiều tùy chọn sắp xếp, chế độ hiển thị và điều khiển bàn phím theo thời gian thực.

Cách sử dụng cơ bản với cài đặt mặc định (sắp xếp theo độ trễ CPU, hiển thị 20 tác vụ hàng đầu, làm mới sau mỗi 2 giây)::

bash# ./delaytop
	Thông tin áp suất hệ thống: (avg10/avg60vg300/total)
	CPU một số: 0,0%/ 0,0%/ 0,0%/ 106137(ms)
	CPU đầy: 0,0%/ 0,0%/ 0,0%/ 0(ms)
	Bộ nhớ đầy: 0,0%/ 0,0%/ 0,0%/ 0(ms)
	Một số bộ nhớ: 0,0%/ 0,0%/ 0,0%/ 0(ms)
	IO đầy: 0,0%/ 0,0%/ 0,0%/ 2240(ms)
	IO một số: 0,0%/ 0,0%/ 0,0%/ 2783(ms)
	IRQ đầy: 0,0%/ 0,0%/ 0,0%/ 0(ms)
	[o]sắp xếp [M]memverbose [q]bỏ
	20 quy trình hàng đầu (được sắp xếp theo độ trễ CPU):
		PID TGID COMMAND CPU(ms) IO(ms) IRQ(ms) MEM(ms)
	-------------------------------------------------------------------------
		110 110 kworker/15:0H-s 27,91 0,00 0,00 0,00
		57 57 cpuhp/7 3,18 0,00 0,00 0,00
		99 99 cpuhp/14 2,97 0,00 0,00 0,00
		51 51 cpuhp/6 0,90 0,00 0,00 0,00
		44 44 kworker/4:0H-sy 0,80 0,00 0,00 0,00
		60 60 ksoftirqd/7 0,74 0,00 0,00 0,00
		76 76 nhàn rỗi_inject/10 0,31 0,00 0,00 0,00
		100 100 nhàn rỗi_inject/14 0,30 0,00 0,00 0,00
		1309 1309 cài đặt hệ thống 0,29 0,00 0,00 0,00
		45 45 cpuhp/5 0,22 0,00 0,00 0,00
		63 63 cpuhp/8 0,20 0,00 0,00 0,00
		87 87 cpuhp/12 0,18 0,00 0,00 0,00
		93 93 cpuhp/13 0,17 0,00 0,00 0,00
		1265 1265 acpid 0,17 0,00 0,00 0,00
		1552 1552 sshd 0,17 0,00 0,00 0,00
		2584 2584 người trợ giúp sddm 0,16 0,00 0,00 0,00
		1284 1284 rtkit-daemon 0,15 0,00 0,00 0,00
		1326 1326 nde-netfilter 0,14 0,00 0,00 0,00
		27 27 cpuhp/2 0,13 0,00 0,00 0,00
		631 631 kworker/11:2-rc 0,11 0,00 0,00 0,00

Điều khiển bàn phím tương tác trong thời gian chạy::

o - Chọn trường sắp xếp (CPU, IO, IRQ, Bộ nhớ, v.v.)
	M - Chuyển đổi chế độ hiển thị (Mặc định/Bộ nhớ Verbose)
	q - Bỏ cuộc

Các trường sắp xếp có sẵn (sử dụng -s/--sort hoặc lệnh tương tác)::

cpu(c) - Độ trễ CPU
	blkio(i) - Độ trễ I/O
	irq(q) - độ trễ IRQ
	mem(m) - Tổng độ trễ bộ nhớ
	swapin(s) - Độ trễ hoán đổi (chỉ ở chế độ dài dòng bộ nhớ)
	freepages(r) - Độ trễ lấy lại trang miễn phí (chỉ ở chế độ dài dòng bộ nhớ)
	thrashing(t) - Độ trễ đập (chỉ ở chế độ dài dòng bộ nhớ)
	compact(p) - Độ trễ nén (chỉ chế độ dài dòng bộ nhớ)
	wpcopy(w) - Ghi độ trễ sao chép trang (chỉ chế độ dài dòng bộ nhớ)

Ví dụ sử dụng nâng cao::

# ./delaytop -s blkio
	Sắp xếp theo độ trễ IO

# ./delaytop -s mem -M
	Sắp xếp theo độ trễ bộ nhớ ở chế độ chi tiết về bộ nhớ

# ./delaytop -p pid
	Số liệu thống kê về độ trễ in

# ./delaytop -P num
	Hiển thị N nhiệm vụ hàng đầu

# ./delaytop -n num
	Đặt tần số làm mới độ trễ (số lần)

# ./delaytop -d giây
	Chỉ định khoảng thời gian làm mới là giây
