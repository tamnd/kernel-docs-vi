.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/housekeeping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
dọn phòng
======================================


Tính năng Cách ly CPU loại bỏ công việc kernel có thể chạy trên bất kỳ CPU nào.
Mục đích của các tính năng liên quan của nó là để giảm hiện tượng giật hệ điều hành mà một số
khối lượng công việc cực lớn không thể chịu đựng được, chẳng hạn như trong một số trường hợp sử dụng DPDK.

Công việc kernel được di chuyển đi bằng cách ly CPU thường được mô tả là
"công việc dọn phòng" vì nó bao gồm công việc dọn dẹp,
duy trì số liệu thống kê và các hành động dựa vào chúng, giải phóng bộ nhớ,
các khoản hoãn lại khác nhau, v.v...

Đôi khi công việc dọn phòng chỉ là một số công việc không bị ràng buộc (hàng công việc không bị ràng buộc,
bộ định thời không liên kết, ...) dễ dàng được gán cho các CPU không bị cô lập.
Nhưng đôi khi công việc dọn phòng gắn liền với một CPU cụ thể và yêu cầu
các thủ thuật phức tạp để được giảm tải cho các CPU không bị cô lập (RCU_NOCB, điều khiển từ xa
đánh dấu lịch trình, v.v.).

Vì vậy, CPU dọn phòng có thể được coi là sự đảo ngược của một công việc biệt lập.
CPU. Nó chỉ đơn giản là một chiếc CPU có thể thực hiện công việc dọn dẹp nhà cửa. Phải có
luôn có ít nhất một CPU dọn phòng trực tuyến bất cứ lúc nào. Những CPU đó
không bị cô lập sẽ tự động được chỉ định làm công việc dọn phòng.

Dịch vụ dọn phòng hiện được chia thành bốn tính năng được mô tả
bởi ZZ0000ZZ:

1. HK_TYPE_DOMAIN khớp với công việc đã được chuyển đi theo miền của bộ lập lịch
	cách ly được thực hiện thông qua tham số khởi động ZZ0000ZZ hoặc
	phân vùng cpuset bị cô lập trong cgroup v2. Điều này bao gồm bộ lập lịch
	cân bằng tải, hàng đợi công việc không bị ràng buộc và bộ tính giờ.

2. HK_TYPE_KERNEL_NOISE phù hợp với công việc được di chuyển đi bằng cách cách ly đánh dấu
	được thực hiện thông qua khởi động ZZ0000ZZ hoặc ZZ0001ZZ
	các thông số. Điều này bao gồm đánh dấu lịch trình từ xa, vmstat và khóa
	cơ quan giám sát.

3. HK_TYPE_MANAGED_IRQ khớp với trình xử lý IRQ đã được chuyển đi bởi quản lý
	Cách ly IRQ được thực hiện thông qua ZZ0000ZZ.

4. HK_TYPE_DOMAIN_BOOT khớp với công việc đã được chuyển đi theo miền của bộ lập lịch
	cách ly chỉ được thực hiện thông qua ZZ0000ZZ. Nó tương tự
	tới HK_TYPE_DOMAIN ngoại trừ nó bỏ qua sự cách ly được thực hiện bởi
	cpuset.


mặt nạ cpu dọn phòng
=================================

CPUmasks vệ sinh bao gồm các CPU có thể thực hiện công việc được di chuyển
đi bằng tính năng cách ly phù hợp. Những cpumasks này được trả về bởi
chức năng sau::

const struct cpumask *housekeeping_cpumask(enum hk_type type)

Theo mặc định, nếu không phải ZZ0000ZZ, ZZ0001ZZ hay cpuset
các phân vùng biệt lập được sử dụng, bao gồm hầu hết các usecase, chức năng này
trả về cpu_possible_mask.

Nếu không thì hàm trả về phần bù cpumask của phần cô lập
tính năng. Ví dụ:

Với isolcpus=domain,7 phần sau sẽ trả về một mặt nạ với tất cả những gì có thể
CPU ngoại trừ 7::

Housekeeping_cpumask(HK_TYPE_DOMAIN)

Tương tự với nohz_full=5,6 phần sau sẽ trả về một mặt nạ có tất cả
CPU có thể ngoại trừ 5,6::

Housekeeping_cpumask(HK_TYPE_KERNEL_NOISE)


Đồng bộ hóa với CPUset
=================================

Cpuset có thể sửa đổi cpumask HK_TYPE_DOMAIN trong khi tạo,
sửa đổi hoặc xóa một phân vùng bị cô lập.

Người dùng cpumask HK_TYPE_DOMAIN sau đó phải đảm bảo đồng bộ hóa
chống lại cpuset đúng cách để đảm bảo rằng:

1. Ảnh chụp nhanh cpumask vẫn mạch lạc.

2. Không có công việc dọn phòng nào được xếp hàng trên CPU cách ly mới được tạo ra.

3. Công việc dọn phòng đang chờ xử lý được xếp hàng đến một nơi không bị cô lập
	CPU vừa bị cô lập qua cpuset phải được xóa
	trước khi phân vùng cách ly được tạo/sửa đổi có liên quan được tạo
	có sẵn cho không gian người dùng.

Sự đồng bộ hóa này được duy trì bởi sơ đồ dựa trên RCU. bản cập nhật cpuset
bên chờ thời gian gia hạn RCU sau khi cập nhật HK_TYPE_DOMAIN
cpumask và trước khi xóa các tác phẩm đang chờ xử lý. Về mặt đọc, phải cẩn thận
thực hiện để thu thập các cuộc bầu cử mục tiêu quản lý và công việc trong hàng đợi
phần quan trọng bên đọc RCU tương tự.

Một ví dụ về bố cục điển hình sẽ trông như thế này ở phía cập nhật
(ZZ0000ZZ)::

rcu_sign_pointer(housekeeping_cpumasks[type], dùng thử);
	đồng bộ hóa_rcu();
	Flush_workqueue(example_workqueue);

Và sau đó về phía đọc ::

rcu_read_lock();
	cpu = dọn phòng_any_cpu(HK_TYPE_DOMAIN);
	queue_work_on(cpu, example_workqueue, công việc);
	rcu_read_unlock();
