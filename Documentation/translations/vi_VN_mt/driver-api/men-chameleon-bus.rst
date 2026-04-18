.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/men-chameleon-bus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Xe buýt tắc kè hoa MEN
======================

.. Table of Contents
   =================
   1 Introduction
       1.1 Scope of this Document
       1.2 Limitations of the current implementation
   2 Architecture
       2.1 MEN Chameleon Bus
       2.2 Carrier Devices
       2.3 Parser
   3 Resource handling
       3.1 Memory Resources
       3.2 IRQs
   4 Writing an MCB driver
       4.1 The driver structure
       4.2 Probing and attaching
       4.3 Initializing the driver
       4.4 Using DMA


Giới thiệu
============

Tài liệu này mô tả kiến trúc và cách triển khai MEN
Xe buýt Chameleon (được gọi là MCB trong suốt tài liệu này).

Phạm vi của tài liệu này
----------------------

Tài liệu này nhằm mục đích cung cấp một cái nhìn tổng quan ngắn gọn về hiện tại
triển khai và không hề mô tả các khả năng đầy đủ của MCB
các thiết bị dựa trên.

Hạn chế của việc thực hiện hiện tại
-----------------------------------------

Việc triển khai hiện tại được giới hạn ở các thiết bị mang dựa trên PCI và PCIe
chỉ sử dụng một tài nguyên bộ nhớ duy nhất và chia sẻ IRQ kế thừa PCI.  Không
được thực hiện là:

- Các thiết bị MCB đa tài nguyên như Bộ điều khiển VME hoặc sóng mang M-Module.
- Các thiết bị MCB cần một thiết bị MCB khác, như SRAM cho Bộ điều khiển DMA
  bộ mô tả bộ đệm hoặc bộ nhớ video của bộ điều khiển video.
- Miền IRQ trên mỗi nhà cung cấp dịch vụ dành cho các thiết bị của nhà cung cấp dịch vụ có một (hoặc nhiều) IRQ
  trên mỗi thiết bị MCB như các nhà cung cấp dịch vụ dựa trên PCIe có hỗ trợ MSI hoặc MSI-X.

Ngành kiến ​​​​trúc
============

MCB được chia thành 3 khối chức năng:

- Bản thân xe buýt tắc kè hoa MEN,
- trình điều khiển cho Thiết bị mang MCB và
- trình phân tích cú pháp cho bảng Chameleon.

Xe buýt tắc kè hoa MEN
-----------------

Xe buýt tắc kè hoa MEN là một hệ thống xe buýt nhân tạo được gắn vào một
được gọi là thiết bị Chameleon FPGA được tìm thấy trên một số phần cứng sản xuất MEN Mikro của tôi
Elektronik GmbH. Các thiết bị này là các thiết bị đa chức năng được triển khai trong một
một FPGA duy nhất và thường được gắn thông qua một số loại liên kết PCI hoặc PCIe. Mỗi
FPGA chứa phần tiêu đề mô tả nội dung của FPGA. các
tiêu đề liệt kê id thiết bị, PCI BAR, chênh lệch so với phần đầu của PCI
BAR, kích thước trong FPGA, số ngắt và một số thuộc tính khác hiện tại
không được xử lý bởi việc triển khai MCB.

Thiết bị mang
---------------

Một thiết bị mang chỉ là một sự trừu tượng của bus vật lý trong thế giới thực.
Tắc kè hoa FPGA được gắn vào. Một số trình điều khiển IP Core có thể cần tương tác với
thuộc tính của thiết bị mang (như truy vấn số IRQ của PCI
thiết bị). Để cung cấp sự trừu tượng hóa từ bus phần cứng thực, sóng mang MCB
thiết bị cung cấp các phương thức gọi lại để dịch các lệnh gọi hàm MCB của trình điều khiển
đến các cuộc gọi chức năng liên quan đến phần cứng. Ví dụ: một thiết bị mang có thể
triển khai phương thức get_irq() có thể được dịch sang bus phần cứng
truy vấn số IRQ mà thiết bị nên sử dụng.

Trình phân tích cú pháp
------

Trình phân tích cú pháp đọc 512 byte đầu tiên của thiết bị Chameleon và phân tích cú pháp
Bàn tắc kè hoa. Hiện tại trình phân tích cú pháp chỉ hỗ trợ biến thể Chameleon v2
của bảng Chameleon nhưng có thể dễ dàng được áp dụng để hỗ trợ bảng cũ hơn hoặc
biến thể có thể xảy ra trong tương lai. Trong khi phân tích các mục của bảng, các thiết bị MCB mới
được phân bổ và tài nguyên của họ được phân bổ theo tài nguyên
nhiệm vụ trong bảng Chameleon. Sau khi việc phân công tài nguyên kết thúc,
Các thiết bị MCB được đăng ký tại MCB và do đó nằm ở lõi trình điều khiển của
Hạt nhân Linux.

Xử lý tài nguyên
=================

Việc triển khai hiện tại chỉ định chính xác một bộ nhớ và một tài nguyên IRQ
trên mỗi thiết bị MCB. Nhưng điều này có thể sẽ thay đổi trong tương lai.

Tài nguyên bộ nhớ
----------------

Mỗi thiết bị MCB có chính xác một tài nguyên bộ nhớ, có thể được yêu cầu từ
xe buýt MCB. Tài nguyên bộ nhớ này là địa chỉ vật lý của thiết bị MCB
bên trong nhà cung cấp dịch vụ và dự định sẽ được chuyển tới ioremap() và bạn bè. Nó
đã được yêu cầu từ kernel bằng cách gọi request_mem_khu vực().

IRQ
----

Mỗi thiết bị MCB có chính xác một tài nguyên IRQ, có thể được yêu cầu từ
Xe buýt MCB. Nếu trình điều khiển thiết bị của nhà cung cấp dịch vụ thực hiện lệnh gọi lại ->get_irq()
phương pháp này, số IRQ do thiết bị mang sẽ được trả về,
nếu không thì số IRQ bên trong bảng Chameleon sẽ được trả về. Cái này
số phù hợp để chuyển tới request_irq().

Viết trình điều khiển MCB
=====================

Cấu trúc điều khiển
--------------------

Mỗi trình điều khiển MCB có cấu trúc để xác định trình điều khiển thiết bị cũng như
id thiết bị xác định IP Core bên trong FPGA. Cấu trúc điều khiển
cũng chứa các phương thức gọi lại được thực thi trên đầu dò trình điều khiển và
xóa khỏi hệ thống::

const tĩnh struct mcb_device_id foo_ids[] = {
		{ .thiết bị = 0x123 },
		{ }
	};
	MODULE_DEVICE_TABLE(mcb, foo_ids);

cấu trúc tĩnh mcb_driver foo_driver = {
	tài xế = {
		.name = "foo-bar",
		.chủ sở hữu = THIS_MODULE,
	},
		.probe = foo_probe,
		.remove = foo_remove,
		.id_table = foo_ids,
	};

Thăm dò và gắn kết
---------------------

Khi trình điều khiển được tải và các thiết bị MCB mà nó phục vụ được tìm thấy, MCB
core sẽ gọi phương thức gọi lại thăm dò của trình điều khiển. Khi trình điều khiển được gỡ bỏ
khỏi hệ thống, lõi MCB sẽ gọi phương thức gọi lại loại bỏ trình điều khiển ::

init tĩnh foo_probe(struct mcb_device *mdev, const struct mcb_device_id *id);
	static void foo_remove(struct mcb_device *mdev);

Đang khởi tạo trình điều khiển
-----------------------

Khi kernel được khởi động hoặc mô-đun trình điều khiển foo của bạn được chèn vào, bạn phải
thực hiện khởi tạo trình điều khiển. Thông thường chỉ cần đăng ký trình điều khiển của bạn là đủ
mô-đun ở lõi MCB::

int tĩnh __init foo_init(void)
	{
		trả về mcb_register_driver(&foo_driver);
	}
	module_init(foo_init);

khoảng trống tĩnh __exit foo_exit(void)
	{
		mcb_unregister_driver(&foo_driver);
	}
	module_exit(foo_exit);

Macro module_mcb_driver() có thể được sử dụng để giảm đoạn mã trên ::

module_mcb_driver(foo_driver);

Sử dụng DMA
---------

Để sử dụng chức năng DMA-API của kernel, bạn sẽ cần sử dụng
'thiết bị cấu trúc' của thiết bị mang. May mắn thay 'struct mcb_device' nhúng một
con trỏ (->dma_dev) tới thiết bị của nhà cung cấp dịch vụ cho mục đích DMA::

ret = dma_set_mask_and_coherent(&mdev->dma_dev, DMA_BIT_MASK(dma_bits));
        nếu (rc)
                /* Xử lý lỗi */
