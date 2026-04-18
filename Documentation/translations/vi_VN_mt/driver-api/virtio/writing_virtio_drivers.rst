.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/virtio/writing_virtio_drivers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _writing_virtio_drivers:

========================
Viết trình điều khiển Virtio
======================

Giới thiệu
============

Tài liệu này phục vụ như một hướng dẫn cơ bản cho các lập trình viên điều khiển
cần hack một trình điều khiển virtio mới hoặc hiểu những điều cơ bản của
những cái hiện có. Xem ZZ0000ZZ để biết thông tin chung
tổng quan về đức hạnh


Bản soạn sẵn trình điều khiển
==================

Ở mức tối thiểu, người lái xe tài năng cần phải đăng ký trên xe buýt tài năng
và định cấu hình hàng đợi cho thiết bị theo thông số kỹ thuật của nó,
cấu hình của các đức tính ở phía trình điều khiển phải phù hợp với
định nghĩa Virtqueue trong thiết bị. Bộ xương trình điều khiển cơ bản có thể trông
như thế này::

#include <linux/virtio.h>
	#include <linux/virtio_ids.h>
	#include <linux/virtio_config.h>
	#include <linux/module.h>

/* dữ liệu riêng tư của thiết bị (mỗi thiết bị một dữ liệu) */
	cấu trúc virtio_dummy_dev {
		struct virtqueue *vq;
	};

static void virtio_dummy_recv_cb(struct virtqueue *vq)
	{
		struct virtio_dummy_dev *dev = vq->vdev->priv;
		char *buf;
		int len ​​không dấu;

while ((buf = virtqueue_get_buf(dev->vq, &len)) != NULL) {
			/*xử lý dữ liệu nhận được */
		}
	}

int tĩnh virtio_dummy_probe(struct virtio_device *vdev)
	{
		struct virtio_dummy_dev *dev = NULL;

/*khởi tạo dữ liệu thiết bị */
		dev = kzalloc(sizeof(struct virtio_dummy_dev), GFP_KERNEL);
		nếu (!dev)
			trả về -ENOMEM;

/* thiết bị có một hàng đợi duy nhất */
		dev->vq = virtio_find_single_vq(vdev, virtio_dummy_recv_cb, "đầu vào");
		nếu (IS_ERR(dev->vq)) {
			kfree(dev);
			trả về PTR_ERR(dev->vq);

}
		vdev->priv = dev;

/* từ thời điểm này trở đi, thiết bị có thể thông báo và nhận lệnh gọi lại */
		virtio_device_ready(vdev);

trả về 0;
	}

static void virtio_dummy_remove(struct virtio_device *vdev)
	{
		struct virtio_dummy_dev *dev = vdev->priv;

/*
		 * vô hiệu hóa ngắt vq: tương đương với
		 * vdev->config->đặt lại(vdev)
		 */
		virtio_reset_device(vdev);

/* loại bỏ các bộ đệm không sử dụng */
		while ((buf = virtqueue_detach_unused_buf(dev->vq)) != NULL) {
			kfree(buf);
		}

/* loại bỏ hàng đợi đức hạnh */
		vdev->config->del_vqs(vdev);

kfree(dev);
	}

const tĩnh struct virtio_device_id id_table[] = {
		{VIRTIO_ID_DUMMY, VIRTIO_DEV_ANY_ID },
		{ 0 },
	};

cấu trúc tĩnh virtio_driver virtio_dummy_driver = {
		.driver.name = KBUILD_MODNAME,
		.id_table = id_table,
		.probe = virtio_dummy_probe,
		.remove = virtio_dummy_remove,
	};

module_virtio_driver(virtio_dummy_driver);
	MODULE_DEVICE_TABLE(virtio, id_table);
	MODULE_DESCRIPTION("Trình điều khiển giả");
	MODULE_LICENSE("GPL");

Id thiết bị ZZ0000ZZ ở đây là trình giữ chỗ, trình điều khiển virtio
chỉ nên thêm cho các thiết bị được xác định trong thông số kỹ thuật, xem
bao gồm/uapi/linux/virtio_ids.h. Id thiết bị ít nhất phải được đặt trước
trong thông số virtio trước khi được thêm vào tệp đó.

Nếu trình điều khiển của bạn không phải làm gì đặc biệt trong ZZ0000ZZ của nó và
ZZ0001ZZ, bạn có thể sử dụng trình trợ giúp module_virtio_driver() để
giảm số lượng mã soạn sẵn.

Phương pháp ZZ0000ZZ thực hiện thiết lập trình điều khiển tối thiểu trong trường hợp này
(cấp phát bộ nhớ cho dữ liệu thiết bị) và khởi tạo
đức hạnh. virtio_device_ready() được sử dụng để kích hoạt virtqueue và để
thông báo cho thiết bị driver đã sẵn sàng để quản lý thiết bị
("DRIVER_OK"). Dù sao thì các đức tính cũng được kích hoạt tự động bởi
lõi sau khi ZZ0001ZZ trở lại.

.. kernel-doc:: include/linux/virtio_config.h
    :identifiers: virtio_device_ready

Trong mọi trường hợp, hàng đợi ảo cần phải được kích hoạt trước khi thêm bộ đệm vào
họ.

Gửi và nhận dữ liệu
==========================

Lệnh gọi lại virtio_dummy_recv_cb() trong đoạn mã trên sẽ được kích hoạt
khi thiết bị thông báo cho trình điều khiển sau khi xử lý xong một
bộ mô tả hoặc chuỗi mô tả, để đọc hoặc viết. Tuy nhiên,
đó mới chỉ là nửa sau của quá trình giao tiếp giữa trình điều khiển thiết bị virtio
quá trình, vì giao tiếp luôn được khởi động bởi trình điều khiển bất kể
về hướng truyền dữ liệu.

Để định cấu hình chuyển bộ đệm từ trình điều khiển sang thiết bị, trước tiên bạn
phải thêm bộ đệm -- được đóng gói dưới dạng ZZ0000ZZ -- vào
virtqueue thích hợp bằng cách sử dụng bất kỳ virtqueue_add_inbuf() nào,
virtqueue_add_outbuf() hoặc virtqueue_add_sgs(), tùy thuộc vào việc bạn
cần thêm một đầu vào ZZ0001ZZ (để thiết bị điền vào), một
xuất ra ZZ0002ZZ (để thiết bị tiêu thụ) hoặc nhiều
ZZ0003ZZ, tương ứng. Sau đó, khi hàng đợi được thiết lập, một cuộc gọi
tới virtqueue_kick() gửi thông báo sẽ được phục vụ bởi
trình ảo hóa triển khai thiết bị::

danh sách phân tán cấu trúc sg[1];
	sg_init_one(sg, bộ đệm, BUFLEN);
	virtqueue_add_inbuf(dev->vq, sg, 1, bộ đệm, GFP_ATOMIC);
	virtqueue_kick(dev->vq);

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: virtqueue_add_inbuf

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: virtqueue_add_outbuf

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: virtqueue_add_sgs

Sau đó, sau khi thiết bị đã đọc hoặc ghi bộ đệm được chuẩn bị bởi
trình điều khiển và thông báo lại, trình điều khiển có thể gọi virtqueue_get_buf() để
đọc dữ liệu do thiết bị tạo ra (nếu Virtqueue được thiết lập với
bộ đệm đầu vào) hoặc đơn giản là lấy lại bộ đệm nếu chúng đã
thiết bị tiêu thụ:

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: virtqueue_get_buf_ctx

Các cuộc gọi lại hàng đợi có thể bị vô hiệu hóa và kích hoạt lại bằng cách sử dụng
virtqueue_disable_cb() và nhóm hàm virtqueue_enable_cb()
tương ứng. Xem driver/virtio/virtio_ring.c để biết thêm chi tiết:

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: virtqueue_disable_cb

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: virtqueue_enable_cb

Nhưng lưu ý rằng một số lệnh gọi lại giả vẫn có thể được kích hoạt trong
những kịch bản nhất định. Cách để vô hiệu hóa cuộc gọi lại một cách đáng tin cậy là đặt lại
thiết bị hoặc virtqueue (virtio_reset_device()).


Tài liệu tham khảo
==========

_ZZ0000ZZ Virtio Spec v1.2:
ZZ0001ZZ

Kiểm tra các phiên bản sau của thông số kỹ thuật.