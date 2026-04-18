.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Trình điều khiển TEE (Môi trường thực thi đáng tin cậy) API
===============================================

Kernel cung cấp cơ sở hạ tầng bus TEE nơi có Ứng dụng đáng tin cậy
được biểu thị dưới dạng một thiết bị được xác định thông qua Mã định danh duy nhất toàn cầu (UUID) và
trình điều khiển máy khách đăng ký một bảng UUID thiết bị được hỗ trợ.

Cơ sở hạ tầng xe buýt TEE đăng ký các API sau:

trận đấu():
  lặp lại bảng UUID của trình điều khiển máy khách để tìm một bảng tương ứng
  phù hợp với thiết bị UUID. Nếu tìm thấy kết quả phù hợp thì thiết bị cụ thể này sẽ
  được thăm dò thông qua đầu dò tương ứng API được trình điều khiển máy khách đăng ký. Cái này
  quá trình xảy ra bất cứ khi nào thiết bị hoặc trình điều khiển máy khách được đăng ký với TEE
  xe buýt.

sự kiện():
  thông báo cho không gian người dùng (udev) bất cứ khi nào một thiết bị mới được đăng ký trên
  Bus TEE để tự động tải trình điều khiển máy khách được mô-đun hóa.

Việc liệt kê thiết bị bus TEE dành riêng cho việc triển khai TEE cơ bản, vì vậy nó
được để ngỏ cho trình điều khiển TEE cung cấp cách triển khai tương ứng.

Sau đó, trình điều khiển máy khách TEE có thể giao tiếp với Ứng dụng đáng tin cậy phù hợp bằng API
được liệt kê trong include/linux/tee_drv.h.

Ví dụ về trình điều khiển máy khách TEE
-------------------------

Giả sử trình điều khiển máy khách TEE cần giao tiếp với Ứng dụng đáng tin cậy
có UUID: ZZ0000ZZ nên đăng ký lái xe
đoạn mã sẽ trông giống như::

cấu trúc const tĩnh tee_client_device_id client_id_table[] = {
		{UUID_INIT(0xac6a4085, 0x0e82, 0x4c33,
			   0xbf, 0x98, 0x8e, 0xb8, 0xe1, 0x18, 0xb6, 0xc2)},
		{}
	};

MODULE_DEVICE_TABLE(tee, client_id_table);

cấu trúc tĩnh tee_client_driver client_driver = {
		.probe = client_probe,
		.remove = client_remove,
		.id_table = client_id_table,
		.driver = {
			.name = DRIVER_NAME,
		},
	};

module_tee_client_driver(client_driver);