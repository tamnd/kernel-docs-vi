.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-device.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Phiên bản thiết bị V4L2
--------------------

Mỗi phiên bản thiết bị được đại diện bởi một cấu trúc v4l2_device.
Các thiết bị rất đơn giản chỉ có thể cấp phát cấu trúc này, nhưng hầu hết thời gian bạn
sẽ nhúng cấu trúc này bên trong một cấu trúc lớn hơn.

Bạn phải đăng ký phiên bản thiết bị bằng cách gọi:

ZZ0000ZZ
	(nhà phát triển, ZZ0001ZZ).

Việc đăng ký sẽ khởi tạo cấu trúc ZZ0000ZZ. Nếu
trường dev->driver_data là ZZ0002ZZ, nó sẽ được liên kết với
Đối số ZZ0001ZZ.

Trình điều khiển muốn tích hợp với khung thiết bị đa phương tiện cần phải đặt
dev->driver_data theo cách thủ công để trỏ đến cấu trúc thiết bị dành riêng cho trình điều khiển
nhúng phiên bản struct v4l2_device. Điều này đạt được bằng một
ZZ0001ZZ gọi trước khi đăng ký phiên bản thiết bị V4L2.
Họ cũng phải đặt trường struct v4l2_device mdev để trỏ tới một
Phiên bản ZZ0000ZZ được khởi tạo và đăng ký đúng cách.

Nếu ZZ0000ZZ\ ->name trống thì nó sẽ được đặt thành
giá trị bắt nguồn từ dev (chính xác là tên trình điều khiển theo sau là bus_id).
Nếu bạn thiết lập nó trước khi gọi ZZ0001ZZ thì nó sẽ
không bị ảnh hưởng. Nếu dev là ZZ0004ZZ thì bạn setup ZZ0005ZZ
ZZ0002ZZ\ ->tên trước khi gọi
ZZ0003ZZ.

Bạn có thể sử dụng ZZ0000ZZ để đặt tên dựa trên trình điều khiển
tên và một phiên bản Atomic_t toàn cầu của trình điều khiển. Điều này sẽ tạo ra những cái tên như
ZZ0001ZZ, ZZ0002ZZ, v.v. Nếu tên kết thúc bằng một chữ số thì nó sẽ chèn
một dấu gạch ngang: ZZ0003ZZ, ZZ0004ZZ, v.v. Hàm này trả về số phiên bản.

Đối số ZZ0001ZZ đầu tiên thường là con trỏ ZZ0002ZZ của một
ZZ0003ZZ, ZZ0004ZZ hoặc ZZ0005ZZ. Rất hiếm khi nhà phát triển làm vậy
là ZZ0006ZZ, nhưng điều này xảy ra với các thiết bị ISA hoặc khi một thiết bị tạo
nhiều thiết bị PCI, do đó không thể liên kết
ZZ0000ZZ với một phụ huynh cụ thể.

Bạn cũng có thể cung cấp lệnh gọi lại ZZ0000ZZ mà các thiết bị phụ có thể gọi
để thông báo cho bạn về các sự kiện. Việc bạn có cần thiết lập điều này hay không tùy thuộc vào
thiết bị phụ. Mọi thông báo mà thiết bị phụ hỗ trợ phải được xác định trong tiêu đề
trong ZZ0001ZZ.

Các thiết bị V4L2 chưa được đăng ký bằng cách gọi:

ZZ0000ZZ
	(ZZ0001ZZ).

Nếu trường dev->driver_data trỏ tới ZZ0000ZZ,
nó sẽ được đặt lại thành ZZ0001ZZ. Hủy đăng ký cũng sẽ tự động hủy đăng ký
tất cả các subdev từ thiết bị.

Nếu bạn có thiết bị có thể cắm nóng (ví dụ: thiết bị USB), thì khi ngắt kết nối
xảy ra thì thiết bị mẹ trở nên không hợp lệ. Vì ZZ0000ZZ có
con trỏ tới thiết bị mẹ đó cũng phải bị xóa để đánh dấu rằng
cha mẹ đã mất. Để thực hiện cuộc gọi này:

ZZ0000ZZ
	(ZZ0001ZZ).

Điều này thực hiện ZZ0002ZZ hủy đăng ký các nhà phát triển con, vì vậy bạn vẫn cần gọi
Chức năng ZZ0000ZZ cho điều đó. Nếu tài xế của bạn không
hotpluggable thì không cần phải gọi ZZ0001ZZ.

Đôi khi bạn cần lặp lại trên tất cả các thiết bị được đăng ký bởi một thiết bị cụ thể
người lái xe. Điều này thường xảy ra nếu nhiều trình điều khiển thiết bị sử dụng cùng một
phần cứng. Ví dụ. trình điều khiển ivtvfb là trình điều khiển bộ đệm khung sử dụng ivtv
phần cứng. Điều này cũng đúng với trình điều khiển alsa chẳng hạn.

Bạn có thể lặp lại trên tất cả các thiết bị đã đăng ký như sau:

.. code-block:: c

	static int callback(struct device *dev, void *p)
	{
		struct v4l2_device *v4l2_dev = dev_get_drvdata(dev);

		/* test if this device was inited */
		if (v4l2_dev == NULL)
			return 0;
		...
		return 0;
	}

	int iterate(void *p)
	{
		struct device_driver *drv;
		int err;

		/* Find driver 'ivtv' on the PCI bus.
		pci_bus_type is a global. For USB buses use usb_bus_type. */
		drv = driver_find("ivtv", &pci_bus_type);
		/* iterate over all ivtv device instances */
		err = driver_for_each_device(drv, NULL, p, callback);
		put_driver(drv);
		return err;
	}

Đôi khi bạn cần duy trì bộ đếm đang chạy của phiên bản thiết bị. Đây là
thường được sử dụng để ánh xạ một phiên bản thiết bị tới một chỉ mục của mảng tùy chọn mô-đun.

Cách tiếp cận được đề xuất như sau:

.. code-block:: c

	static atomic_t drv_instance = ATOMIC_INIT(0);

	static int drv_probe(struct pci_dev *pdev, const struct pci_device_id *pci_id)
	{
		...
		state->instance = atomic_inc_return(&drv_instance) - 1;
	}

Nếu bạn có nhiều nút thiết bị thì có thể khó biết khi nào nó hoạt động.
an toàn khi hủy đăng ký ZZ0000ZZ cho các thiết bị có thể cắm nóng. Vì điều này
mục đích ZZ0001ZZ có hỗ trợ đếm lại. Việc hoàn lại tiền là
tăng bất cứ khi nào ZZ0002ZZ được gọi và nó được
giảm bất cứ khi nào nút thiết bị đó được giải phóng. Khi số tiền hoàn lại đạt đến
bằng 0 thì lệnh gọi lại ZZ0003ZZ Release() sẽ được gọi. bạn có thể
dọn dẹp lần cuối ở đó.

Nếu các nút thiết bị khác (ví dụ: ALSA) được tạo thì bạn có thể tăng và
giảm số tiền hoàn lại theo cách thủ công bằng cách gọi:

ZZ0000ZZ
	(ZZ0001ZZ).

hoặc:

ZZ0000ZZ
	(ZZ0001ZZ).

Vì số tiền hoàn lại ban đầu là 1 nên bạn cũng cần gọi
ZZ0000ZZ trong lệnh gọi lại ZZ0001ZZ (dành cho thiết bị USB)
hoặc trong lệnh gọi lại ZZ0002ZZ (ví dụ: thiết bị PCI), nếu không thì số tiền hoàn lại
sẽ không bao giờ đạt tới 0.

hàm v4l2_device và cấu trúc dữ liệu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. kernel-doc:: include/media/v4l2-device.h