.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mei/mei.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giới thiệu
============

Công cụ quản lý Intel (Intel ME) là một hệ thống điện toán biệt lập và được bảo vệ
tài nguyên (Bộ đồng xử lý) nằm bên trong một số chipset Intel nhất định. Intel ME
cung cấp hỗ trợ cho các tính năng bảo mật và quản lý máy tính/CNTT.
Bộ tính năng thực tế phụ thuộc vào chipset Intel SKU.

Giao diện công cụ quản lý Intel (Intel MEI, trước đây gọi là HECI)
là giao diện giữa Máy chủ và Intel ME. Giao diện này được hiển thị
tới máy chủ dưới dạng thiết bị PCI, trên thực tế, nhiều thiết bị PCI có thể bị lộ.
Trình điều khiển Intel MEI chịu trách nhiệm về kênh liên lạc giữa
một ứng dụng chủ và các tính năng Intel ME.

Mỗi tính năng Intel ME hoặc Máy khách Intel ME được xử lý bằng một GUID duy nhất và
mỗi khách hàng có giao thức riêng. Giao thức này dựa trên thông điệp với một
tiêu đề và tải trọng lên tới số byte tối đa được khách hàng quảng cáo,
khi kết nối.

Trình điều khiển Intel MEI
================

Trình điều khiển hiển thị một thiết bị ký tự với các nút thiết bị/dev/meiX.

Một ứng dụng duy trì liên lạc với tính năng Intel ME trong khi
/dev/meiX đang mở. Việc liên kết với một tính năng cụ thể được thực hiện bằng cách gọi
ZZ0000ZZ, vượt qua GUID mong muốn.
Số phiên bản của tính năng Intel ME có thể mở được
đồng thời phụ thuộc vào tính năng Intel ME, nhưng hầu hết
các tính năng chỉ cho phép một phiên bản duy nhất.

Trình điều khiển minh bạch đối với dữ liệu được truyền giữa các tính năng phần sụn
và ứng dụng máy chủ.

Bởi vì một số tính năng của Intel ME có thể thay đổi hệ thống
cấu hình, trình điều khiển theo mặc định chỉ cho phép một đặc quyền
người dùng truy cập vào nó.

Phiên kết thúc khi gọi ZZ0000ZZ.

Đoạn mã cho ứng dụng giao tiếp với máy khách Intel AMTHI:

Để hỗ trợ ảo hóa hoặc hộp cát, người giám sát đáng tin cậy
có thể sử dụng ZZ0000ZZ để tạo
các kênh ảo có tính năng Intel ME. Không phải tất cả các tính năng đều hỗ trợ
các kênh ảo của khách hàng như vậy với câu trả lời EOPNOTSUPP.

.. code-block:: C

	struct mei_connect_client_data data;
	fd = open(MEI_DEVICE);

	data.d.in_client_uuid = AMTHI_GUID;

	ioctl(fd, IOCTL_MEI_CONNECT_CLIENT, &data);

	printf("Ver=%d, MaxLen=%ld\n",
	       data.d.in_client_uuid.protocol_version,
	       data.d.in_client_uuid.max_msg_length);

	[...]

	write(fd, amthi_req_data, amthi_req_data_len);

	[...]

	read(fd, &amthi_res_data, amthi_res_data_len);

	[...]
	close(fd);


Không gian người dùng API

IOCTL:
=======

Trình điều khiển Intel MEI hỗ trợ các lệnh IOCTL sau:

IOCTL_MEI_CONNECT_CLIENT
-------------------------
Kết nối với tính năng/máy khách của chương trình cơ sở.

.. code-block:: none

	Usage:

        struct mei_connect_client_data client_data;

        ioctl(fd, IOCTL_MEI_CONNECT_CLIENT, &client_data);

	Inputs:

        struct mei_connect_client_data - contain the following
	Input field:

		in_client_uuid -	GUID of the FW Feature that needs
					to connect to.
         Outputs:
		out_client_properties - Client Properties: MTU and Protocol Version.

         Error returns:

                ENOTTY  No such client (i.e. wrong GUID) or connection is not allowed.
		EINVAL	Wrong IOCTL Number
		ENODEV	Device or Connection is not initialized or ready.
		ENOMEM	Unable to allocate memory to client internal data.
		EFAULT	Fatal Error (e.g. Unable to access user input data)
		EBUSY	Connection Already Open

: Lưu ý:
        max_msg_length (MTU) trong thuộc tính máy khách mô tả mức tối đa
        dữ liệu có thể được gửi hoặc nhận. (ví dụ: nếu MTU=2K, có thể gửi
        yêu cầu lên tới 2k byte và nhận được phản hồi lên tới 2k byte).

IOCTL_MEI_CONNECT_CLIENT_VTAG:
------------------------------

.. code-block:: none

        Usage:

        struct mei_connect_client_data_vtag client_data_vtag;

        ioctl(fd, IOCTL_MEI_CONNECT_CLIENT_VTAG, &client_data_vtag);

        Inputs:

        struct mei_connect_client_data_vtag - contain the following
        Input field:

                in_client_uuid -  GUID of the FW Feature that needs
                                  to connect to.
                vtag - virtual tag [1, 255]

         Outputs:
                out_client_properties - Client Properties: MTU and Protocol Version.

         Error returns:

                ENOTTY No such client (i.e. wrong GUID) or connection is not allowed.
                EINVAL Wrong IOCTL Number or tag == 0
                ENODEV Device or Connection is not initialized or ready.
                ENOMEM Unable to allocate memory to client internal data.
                EFAULT Fatal Error (e.g. Unable to access user input data)
                EBUSY  Connection Already Open
                EOPNOTSUPP Vtag is not supported

IOCTL_MEI_NOTIFY_SET
---------------------
Bật hoặc tắt thông báo sự kiện.


.. code-block:: none

	Usage:

		uint32_t enable;

		ioctl(fd, IOCTL_MEI_NOTIFY_SET, &enable);


		uint32_t enable = 1;
		or
		uint32_t enable[disable] = 0;

	Error returns:


		EINVAL	Wrong IOCTL Number
		ENODEV	Device  is not initialized or the client not connected
		ENOMEM	Unable to allocate memory to client internal data.
		EFAULT	Fatal Error (e.g. Unable to access user input data)
		EOPNOTSUPP if the device doesn't support the feature

: Lưu ý:
	Máy khách phải được kết nối để kích hoạt các sự kiện thông báo


IOCTL_MEI_NOTIFY_GET
--------------------
Truy xuất sự kiện

.. code-block:: none

	Usage:
		uint32_t event;
		ioctl(fd, IOCTL_MEI_NOTIFY_GET, &event);

	Outputs:
		1 - if an event is pending
		0 - if there is no even pending

	Error returns:
		EINVAL	Wrong IOCTL Number
		ENODEV	Device is not initialized or the client not connected
		ENOMEM	Unable to allocate memory to client internal data.
		EFAULT	Fatal Error (e.g. Unable to access user input data)
		EOPNOTSUPP if the device doesn't support the feature

: Lưu ý:
	Máy khách phải được kết nối và thông báo sự kiện phải được bật
	để nhận được một sự kiện



Chipset được hỗ trợ
==================
82X38/X48 Express và mới hơn

linux-mei@linux.intel.com