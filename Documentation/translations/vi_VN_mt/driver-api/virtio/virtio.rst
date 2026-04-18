.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/virtio/virtio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _virtio:

=================
Virtio trên Linux
=================

Giới thiệu
============

Virtio là một tiêu chuẩn mở xác định giao thức truyền thông
giữa trình điều khiển và thiết bị thuộc các loại khác nhau, xem Chương 5 ("Thiết bị
Các loại") của thông số kỹ năng (ZZ0000ZZ). Ban đầu được phát triển như một tiêu chuẩn
đối với các thiết bị ảo hóa được triển khai bởi bộ ảo hóa, nó có thể được sử dụng
để giao tiếp với bất kỳ thiết bị tương thích nào (thực hoặc mô phỏng) với trình điều khiển.

Với mục đích minh họa, tài liệu này sẽ tập trung vào trường hợp phổ biến
của nhân Linux chạy trong một máy ảo và sử dụng ảo hóa song song
các thiết bị được cung cấp bởi hypervisor, hiển thị chúng dưới dạng thiết bị virtio
thông qua các cơ chế tiêu chuẩn như PCI.


Thiết bị - Giao tiếp trình điều khiển: đức tính
===============================================

Mặc dù các thiết bị virtio thực sự là một lớp trừu tượng trong
hypervisor, chúng tiếp xúc với khách như thể chúng là thiết bị vật lý
sử dụng một phương thức vận chuyển cụ thể -- PCI, MMIO hoặc CCW -- nghĩa là
trực giao với chính thiết bị đó. Thông số kỹ thuật virtio xác định các phương thức vận chuyển này
phương pháp một cách chi tiết, bao gồm khám phá thiết bị, khả năng và
xử lý ngắt.

Giao tiếp giữa trình điều khiển trong hệ điều hành khách và thiết bị trong
trình ảo hóa được thực hiện thông qua bộ nhớ dùng chung (đó là điều khiến cho virtio
thiết bị rất hiệu quả) bằng cách sử dụng cấu trúc dữ liệu chuyên biệt gọi là
virtqueues, thực chất là bộ đệm vòng [#f1]_ của bộ mô tả bộ đệm
tương tự như những cái được sử dụng trong thiết bị mạng:

.. kernel-doc:: include/uapi/linux/virtio_ring.h
    :identifiers: struct vring_desc

Tất cả các vùng đệm mà bộ mô tả trỏ tới đều được cấp phát bởi khách và
được máy chủ sử dụng để đọc hoặc viết nhưng không phải cho cả hai.

Tham khảo Chương 2.5 ("Virtqueues") của thông số virtio (ZZ0000ZZ) để biết
các định nghĩa tham khảo về virtqueues và "virtqueues and virtio ring: How
dữ liệu di chuyển" (ZZ0001ZZ) để có cái nhìn tổng quan minh họa về cách
thiết bị chủ và trình điều khiển khách giao tiếp.

Cấu trúc ZZ0000ZZ mô hình hóa một hàng đợi, bao gồm
bộ đệm vòng và dữ liệu quản lý. Được nhúng trong cấu trúc này là
Cấu trúc ZZ0001ZZ, là cấu trúc dữ liệu
cuối cùng được sử dụng bởi trình điều khiển virtio:

.. kernel-doc:: include/linux/virtio.h
    :identifiers: struct virtqueue

Hàm gọi lại được trỏ bởi cấu trúc này được kích hoạt khi
thiết bị đã sử dụng bộ đệm do trình điều khiển cung cấp. Thêm
cụ thể, trình kích hoạt sẽ là một ngắt do hypervisor đưa ra
(xem vring_interrupt()). Trình xử lý yêu cầu ngắt được đăng ký cho
một Virtqueue trong quá trình thiết lập Virtqueue (dành riêng cho việc vận chuyển).

.. kernel-doc:: drivers/virtio/virtio_ring.c
    :identifiers: vring_interrupt


Khám phá và thăm dò thiết bị
============================

Trong kernel, lõi virtio chứa trình điều khiển bus virtio và
trình điều khiển dành riêng cho vận chuyển như ZZ0000ZZ và ZZ0001ZZ. Sau đó
có các trình điều khiển virtio riêng cho các loại thiết bị cụ thể
đã đăng ký với tài xế xe buýt virtio.

Cách một thiết bị virtio được tìm thấy và cấu hình bởi kernel phụ thuộc vào cách
hypervisor định nghĩa nó. Lấy ZZ0000ZZ
thiết bị làm ví dụ. Khi sử dụng PCI làm phương thức vận chuyển, thiết bị
sẽ xuất hiện trên xe buýt PCI với nhà cung cấp 0x1af4 (Red Hat, Inc.)
và id thiết bị 0x1003 (bảng điều khiển virtio), như được xác định trong thông số kỹ thuật, do đó
kernel sẽ phát hiện nó giống như với bất kỳ thiết bị PCI nào khác.

Trong quá trình liệt kê PCI, nếu tìm thấy một thiết bị khớp với
trình điều khiển virtio-pci (theo bảng thiết bị virtio-pci, bất kỳ PCI nào
thiết bị có id nhà cung cấp = 0x1af4)::

/* Qumranet đã tặng ID nhà cung cấp của họ cho các thiết bị từ 0x1000 đến 0x10FF. */
	const tĩnh struct pci_device_id virtio_pci_id_table[] = {
		{PCI_DEVICE(PCI_VENDOR_ID_REDHAT_QUMRANET, PCI_ANY_ID) },
		{ 0 }
	};

sau đó trình điều khiển virtio-pci sẽ được thăm dò và nếu quá trình thăm dò diễn ra tốt đẹp,
thiết bị đã được đăng ký với bus virtio::

int tĩnh virtio_pci_probe(struct pci_dev *pci_dev,
				    const struct pci_device_id *id)
	{
		...

nếu (force_legacy) {
			rc = virtio_pci_legacy_probe(vp_dev);
			/* Ngoài ra, hãy thử chế độ hiện đại nếu chúng tôi không thể ánh xạ BAR0 (không có không gian IO). */
			nếu (rc == -ENODEV || rc == -ENOMEM)
				rc = virtio_pci_modern_probe(vp_dev);
			nếu (rc)
				đi tới err_probe;
		} khác {
			rc = virtio_pci_modern_probe(vp_dev);
			nếu (rc == -ENODEV)
				rc = virtio_pci_legacy_probe(vp_dev);
			nếu (rc)
				đi tới err_probe;
		}

		...

rc = register_virtio_device(&vp_dev->vdev);

Khi thiết bị được đăng ký vào bus virtio, kernel sẽ trông như thế này
cho người lái xe buýt có thể xử lý thiết bị và gọi đó là
phương pháp ZZ0000ZZ của người lái xe.

Tại thời điểm này, các Virtqueues sẽ được phân bổ và cấu hình bởi
gọi hàm trợ giúp ZZ0000ZZ thích hợp, chẳng hạn như
virtio_find_single_vq() hoặc virtio_find_vqs(), sẽ kết thúc việc gọi
một phương pháp ZZ0001ZZ dành riêng cho vận chuyển.


Tài liệu tham khảo
==================

_ZZ0000ZZ Virtio Spec v1.2:
ZZ0001ZZ

.. Check for later versions of the spec as well.

_ZZ0000ZZ Virtqueues và vòng virtio: Dữ liệu di chuyển như thế nào
ZZ0001ZZ

.. rubric:: Footnotes

.. [#f1] that's why they may be also referred to as virtrings.