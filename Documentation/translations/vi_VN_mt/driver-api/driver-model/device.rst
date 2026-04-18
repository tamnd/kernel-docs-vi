.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/device.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Cấu trúc thiết bị cơ bản
=============================

Xem kerneldoc để biết thiết bị cấu trúc.


Giao diện lập trình
~~~~~~~~~~~~~~~~~~~~~
Trình điều khiển xe buýt phát hiện ra thiết bị sẽ sử dụng điều này để đăng ký
thiết bị có lõi::

int device_register(struct device * dev);

Xe buýt nên khởi tạo các trường sau:

- cha mẹ
    - tên
    - bus_id
    - xe buýt

Một thiết bị sẽ bị xóa khỏi lõi khi số tham chiếu của nó đạt tới
0. Số lượng tham chiếu có thể được điều chỉnh bằng cách sử dụng::

thiết bị cấu trúc * get_device(thiết bị cấu trúc * dev);
  void put_device(thiết bị cấu trúc * dev);

get_device() sẽ trả về một con trỏ tới thiết bị cấu trúc được truyền cho nó
nếu tham chiếu chưa phải là 0 (nếu nó đang trong quá trình
đã bị loại bỏ rồi).

Trình điều khiển có thể truy cập khóa trong cấu trúc thiết bị bằng cách sử dụng::

void lock_device(thiết bị cấu trúc * dev);
  void unlock_device(thiết bị cấu trúc * dev);


Thuộc tính
~~~~~~~~~~

::

cấu trúc thiết bị_thuộc tính {
	thuộc tính cấu trúc attr;
	ssize_t (*show)(struct device *dev, struct device_attribute *attr,
			char *buf);
	ssize_t (*store)(struct device *dev, struct device_attribute *attr,
			 const char *buf, size_t count);
  };

Các thuộc tính của thiết bị có thể được trình điều khiển thiết bị xuất thông qua sysfs.

Vui lòng xem Tài liệu/filesystems/sysfs.rst để biết thêm thông tin
về cách hoạt động của sysfs.

Như đã giải thích trong Tài liệu/core-api/kobject.rst, thuộc tính thiết bị phải là
được tạo trước khi sự kiện KOBJ_ADD được tạo. Cách duy nhất để nhận ra
đó là bằng cách xác định một nhóm thuộc tính.

Các thuộc tính được khai báo bằng macro có tên DEVICE_ATTR::

#define DEVICE_ATTR (tên, chế độ, hiển thị, cửa hàng)

Ví dụ:::

DEVICE_ATTR tĩnh (loại, 0444, type_show, NULL);
  DEVICE_ATTR tĩnh (nguồn, 0644, power_show, power_store);

Các macro trợ giúp có sẵn cho các giá trị chung của chế độ, vì vậy các ví dụ trên
có thể được đơn giản hóa thành :::

DEVICE_ATTR_RO tĩnh (loại);
  tĩnh DEVICE_ATTR_RW(nguồn);

Điều này khai báo hai cấu trúc kiểu struct device_attribute với tương ứng
đặt tên 'dev_attr_type' và 'dev_attr_power'. Hai thuộc tính này có thể
được tổ chức như sau thành một nhóm::

thuộc tính cấu trúc tĩnh *dev_attrs[] = {
	&dev_attr_type.attr,
	&dev_attr_power.attr,
	NULL,
  };

cấu trúc tĩnh thuộc tính_group dev_group = {
	.attrs = dev_attrs,
  };

const tĩnh struct attribute_group *dev_groups[] = {
	&dev_group,
	NULL,
  };

Macro trợ giúp có sẵn cho trường hợp chung của một nhóm, vì vậy
Hai cấu trúc trên có thể được khai báo bằng :::

ATTRIBUTE_GROUPS(nhà phát triển);

Mảng nhóm này sau đó có thể được liên kết với một thiết bị bằng cách đặt
con trỏ nhóm trong thiết bị struct trước khi device_register() được gọi::

dev->groups = dev_groups;
        device_register(dev);

Hàm device_register() sẽ sử dụng con trỏ 'groups' để tạo
thuộc tính thiết bị và hàm device_unregister() sẽ sử dụng con trỏ này
để loại bỏ các thuộc tính của thiết bị.

Lời cảnh báo: Trong khi kernel cho phép device_create_file() và
device_remove_file() được gọi trên thiết bị bất cứ lúc nào, không gian người dùng có
những kỳ vọng nghiêm ngặt về thời điểm các thuộc tính được tạo.  Khi có một thiết bị mới
được đăng ký trong kernel, một sự kiện được tạo để thông báo cho không gian người dùng (như
udev) rằng có thiết bị mới.  Nếu các thuộc tính được thêm vào sau
thiết bị đã được đăng ký thì vùng người dùng sẽ không nhận được thông báo và vùng người dùng sẽ
không biết về các thuộc tính mới.

Điều này rất quan trọng đối với trình điều khiển thiết bị cần xuất bản bổ sung
thuộc tính cho thiết bị tại thời điểm thăm dò trình điều khiển.  Nếu trình điều khiển thiết bị chỉ đơn giản là
gọi device_create_file() trên cấu trúc thiết bị được truyền cho nó, sau đó
không gian người dùng sẽ không bao giờ được thông báo về các thuộc tính mới.
