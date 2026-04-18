.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/x86_64/fake-numa-for-cpusets.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
NUMA giả cho CPUSets
=====================

:Tác giả: David Rientjes <rientjes@cs.washington.edu>

Sử dụng numa=fake và CPUSets để quản lý tài nguyên

Tài liệu này mô tả cách sử dụng tùy chọn dòng lệnh numa=fake x86_64
kết hợp với cpusets để quản lý bộ nhớ thô.  Sử dụng tính năng này,
bạn có thể tạo các nút NUMA giả đại diện cho các khối bộ nhớ liền kề và
gán chúng cho cpusets và các tác vụ kèm theo của chúng.  Đây là một cách để hạn chế
lượng bộ nhớ hệ thống có sẵn cho một loại tác vụ nhất định.

Để biết thêm thông tin về các tính năng của CPUset, hãy xem
Tài liệu/admin-guide/cgroup-v1/cpusets.rst.
Có một số cấu hình khác nhau mà bạn có thể sử dụng cho nhu cầu của mình.  cho
thêm thông tin về tùy chọn dòng lệnh numa=fake và các cách khác nhau của nó
định cấu hình các nút giả, xem Tài liệu/admin-guide/kernel-parameter.txt

Với mục đích của phần giới thiệu này, chúng tôi sẽ giả sử một NUMA rất nguyên thủy
thiết lập mô phỏng "numa=fake=4*512,".  Điều này sẽ chia bộ nhớ hệ thống của chúng tôi thành
bốn phần bằng nhau, mỗi phần có dung lượng 512M mà giờ đây chúng ta có thể sử dụng để gán cho bộ vi xử lý.  Như
bạn trở nên quen thuộc hơn với việc sử dụng sự kết hợp này để kiểm soát tài nguyên,
bạn sẽ xác định một thiết lập tốt hơn để giảm thiểu số lượng nút bạn phải xử lý
với.

Một máy có thể được phân chia như sau với "numa=fake=4*512," theo báo cáo của dmesg::

Giả mạo nút 0 tại 00000000000000000-0000000020000000 (512MB)
	Giả mạo nút 1 tại 0000000020000000-0000000040000000 (512MB)
	Giả mạo nút 2 tại 0000000040000000-0000000060000000 (512MB)
	Giả mạo nút 3 tại 0000000060000000-0000000080000000 (512MB)
	...
Trên tổng số trang của nút 0: 130975
	Trên tổng số trang của nút 1: 131072
	Trên tổng số trang của nút 2: 131072
	Trên tổng số trang của nút 3: 131072

Bây giờ hãy làm theo hướng dẫn để gắn hệ thống tập tin cpusets từ
Documentation/admin-guide/cgroup-v1/cpusets.rst, bạn có thể chỉ định các nút giả (tức là bộ nhớ liền kề
không gian địa chỉ) vào từng CPUset::

[root@xroads /]Bộ ví dụ # mkdir
	[root@xroads /]# mount -t cpuset không có bộ ví dụ nào
	[root@xroads /]Bộ ví dụ/ddset# mkdir
	[root@xroads /]Bộ ví dụ/ddset# cd
	[root@xroads /exampleset/ddset]# echo 0-1 > cpu
	[root@xroads /exampleset/ddset]# echo 0-1 > mems

Bây giờ cpuset này, 'ddset', sẽ chỉ cho phép truy cập vào các nút giả 0 và 1 đối với
cấp phát bộ nhớ (1G).

Bây giờ bạn có thể phân công nhiệm vụ cho các bộ xử lý này để hạn chế tài nguyên bộ nhớ
có sẵn cho họ theo các nút giả được chỉ định là mems::

[root@xroads /exampleset/ddset]# echo $$ > nhiệm vụ
	[root@xroads /exampleset/ddset]# dd if=/dev/zero of=tmp bs=1024 count=1G
	[1] 13425

Lưu ý sự khác biệt giữa mức sử dụng bộ nhớ hệ thống theo báo cáo của
/proc/meminfo giữa trường hợp cpuset bị hạn chế ở trên và trường hợp không bị giới hạn
trường hợp (tức là chạy lệnh 'dd' tương tự mà không gán nó cho NUMA giả
bộ xử lý):

======== =======================
	Tên Không hạn chế Hạn chế
	======== =======================
	MemTotal 3091900 kB 3091900 kB
	MemFree 42113 kB 1513236 kB
	======== =======================

Điều này cho phép quản lý bộ nhớ thô cho các tác vụ bạn chỉ định cụ thể
cpuset.  Vì các bộ CPU có thể tạo thành một hệ thống phân cấp nên bạn có thể tạo một số bộ CPU đẹp mắt.
sự kết hợp thú vị của các trường hợp sử dụng cho các loại nhiệm vụ khác nhau cho
nhu cầu quản lý bộ nhớ.