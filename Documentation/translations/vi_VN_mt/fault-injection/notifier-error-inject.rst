.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fault-injection/notifier-error-inject.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Chèn lỗi thông báo
========================

Việc chèn lỗi thông báo cung cấp khả năng đưa các lỗi nhân tạo vào
cuộc gọi lại chuỗi thông báo được chỉ định. Sẽ rất hữu ích khi kiểm tra việc xử lý lỗi của
lỗi chuỗi cuộc gọi thông báo hiếm khi được thực hiện.  Có hạt nhân
các mô-đun có thể được sử dụng để kiểm tra các trình thông báo sau.

* Trình thông báo PM
 * Trình thông báo cắm nóng bộ nhớ
 * trình thông báo cấu hình lại powerpc pSeries
 * Trình thông báo Netdevice

Mô-đun chèn lỗi thông báo PM
----------------------------------
Tính năng này được điều khiển thông qua giao diện debugfs

/sys/kernel/debug/notifier-error-inject/pm/actions/<sự kiện trình thông báo>/error

Các sự kiện thông báo PM có thể không thành công là:

* PM_HIBERNATION_PREPARE
 * PM_SUSPEND_PREPARE
 * PM_RESTORE_PREPARE

Ví dụ: Lỗi treo PM (-12 = -ENOMEM)::

# cd /sys/kernel/debug/notifier-error-inject/pm/
	# echo -12 > hành động/PM_SUSPEND_PREPARE/lỗi
	Bộ nhớ # echo > /sys/power/state
	bash: echo: lỗi ghi: Không thể phân bổ bộ nhớ

Mô-đun chèn lỗi thông báo cắm nóng bộ nhớ
----------------------------------------------
Tính năng này được điều khiển thông qua giao diện debugfs

/sys/kernel/debug/notifier-error-inject/memory/actions/<sự kiện trình thông báo>/lỗi

Các sự kiện thông báo bộ nhớ có thể bị lỗi là:

* MEM_GOING_ONLINE
 * MEM_GOING_OFFLINE

Ví dụ: Lỗi ngoại tuyến cắm nóng bộ nhớ (-12 == -ENOMEM)::

# cd/sys/kernel/debug/notifier-error-inject/memory
	# echo -12 > hành động/MEM_GOING_OFFLINE/lỗi
	# echo ngoại tuyến > /sys/devices/system/memory/memoryXXX/state
	bash: echo: lỗi ghi: Không thể phân bổ bộ nhớ

mô-đun tiêm lỗi thông báo cấu hình lại powerpc pSeries
--------------------------------------------------------
Tính năng này được điều khiển thông qua giao diện debugfs

/sys/kernel/debug/notifier-error-inject/pSeries-reconfig/actions/<sự kiện trình thông báo>/error

Các sự kiện thông báo cấu hình lại pSeries có thể không thành công là:

* PSERIES_RECONFIG_ADD
 * PSERIES_RECONFIG_REMOVE
 * PSERIES_DRCONF_MEM_ADD
 * PSERIES_DRCONF_MEM_REMOVE

Mô-đun chèn lỗi thông báo Netdevice
----------------------------------------------
Tính năng này được điều khiển thông qua giao diện debugfs

/sys/kernel/debug/notifier-error-inject/netdev/actions/<sự kiện trình thông báo>/error

Các sự kiện thông báo Netdevice có thể bị lỗi là:

* NETDEV_REGISTER
 * NETDEV_CHANGEMTU
 * NETDEV_CHANGENAME
 * NETDEV_PRE_UP
 * NETDEV_PRE_TYPE_CHANGE
 * NETDEV_POST_INIT
 * NETDEV_PRECHANGEMTU
 * NETDEV_PRECHANGEUPPER
 * NETDEV_CHANGEUPPER

Ví dụ: Lỗi thay đổi mtu của netdevice (-22 == -EINVAL)::

# cd/sys/kernel/debug/notifier-error-inject/netdev
	# echo -22 > hành động/NETDEV_CHANGEMTU/lỗi
	Bộ liên kết # ip eth0 mtu 1024
	Câu trả lời RTNETLINK: Đối số không hợp lệ

Để biết thêm ví dụ sử dụng
-----------------------
Có các công cụ/kiểm tra/tự kiểm tra bằng cách sử dụng tính năng chèn lỗi thông báo
cho CPU và trình thông báo bộ nhớ.

* công cụ/kiểm tra/selftests/cpu-hotplug/cpu-on-off-test.sh
 * công cụ/kiểm tra/selftests/memory-hotplug/mem-on-off-test.sh

Các tập lệnh này trước tiên thực hiện các kiểm tra trực tuyến và ngoại tuyến đơn giản, sau đó phát hiện lỗi
kiểm tra tiêm nếu có sẵn mô-đun chèn lỗi thông báo.
