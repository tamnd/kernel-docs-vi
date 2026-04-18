.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/ca_high_level.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

CI cấp cao API
=====================

.. note::

   This documentation is outdated.

Tài liệu này mô tả CI API cấp cao theo quy định
Linux DVB API.


Với CI cấp cao, bạn có thể tiếp cận bất kỳ thẻ mới nào có hầu hết các thẻ ngẫu nhiên.
kiến trúc có thể được thực hiện theo phong cách này, các định nghĩa
bên trong câu lệnh switch có thể dễ dàng điều chỉnh cho phù hợp với bất kỳ thẻ nào, do đó
loại bỏ sự cần thiết của bất kỳ ioctls bổ sung nào.

Điểm bất lợi là trình điều khiển/phần cứng phải quản lý phần còn lại. cho
lập trình viên ứng dụng, nó sẽ đơn giản như việc gửi/nhận một
mảng đến/từ CI ioctls như được xác định trong Linux DVB API. Không có thay đổi
đã được chế tạo trong API để phù hợp với tính năng này.


Tại sao cần có giao diện CI khác?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đây là một trong những câu hỏi thường gặp nhất. Vâng một câu hỏi hay.
Nói đúng ra thì đây không phải là một giao diện mới.

Giao diện CI được xác định trong DVB API trong ca.h là:

.. code-block:: c

	typedef struct ca_slot_info {
		int num;               /* slot number */

		int type;              /* CA interface this slot supports */
	#define CA_CI            1     /* CI high level interface */
	#define CA_CI_LINK       2     /* CI link layer level interface */
	#define CA_CI_PHYS       4     /* CI physical layer level interface */
	#define CA_DESCR         8     /* built-in descrambler */
	#define CA_SC          128     /* simple smart card interface */

		unsigned int flags;
	#define CA_CI_MODULE_PRESENT 1 /* module (or card) inserted */
	#define CA_CI_MODULE_READY   2
	} ca_slot_info_t;

Giao diện CI này tuân theo giao diện cấp cao CI, không phải
được thực hiện bởi hầu hết các ứng dụng. Do đó khu vực này được xem xét lại.

Giao diện CI này khá khác biệt trong trường hợp nó cố gắng
chứa tất cả các thiết bị dựa trên CI khác, thuộc các danh mục khác.

Điều này có nghĩa là giao diện CI này xử lý các thẻ kiểu EN50221 trong
Chỉ có lớp ứng dụng và không có quản lý phiên nào được quản lý bởi
ứng dụng. Trình điều khiển/phần cứng sẽ đảm nhiệm tất cả những việc đó.

Giao diện này hoàn toàn là giao diện EN50221 trao đổi APDU. Cái này
có nghĩa là không có lớp quản lý phiên, lớp liên kết hoặc lớp vận chuyển nào làm được điều đó.
tồn tại trong trường hợp này trong ứng dụng giao tiếp với người lái xe. Đó là
đơn giản như vậy. Trình điều khiển/phần cứng phải đảm nhiệm việc đó.

Với giao diện CI cấp cao này, giao diện có thể được xác định bằng
ioctls thông thường.

Tất cả các ioctls này cũng hợp lệ cho giao diện CI cấp cao

#define CA_RESET _IO('o', 128)
#define CA_GET_CAP _IOR('o', 129, ca_caps_t)
#define CA_GET_SLOT_INFO _IOR('o', 130, ca_slot_info_t)
#define CA_GET_DESCR_INFO _IOR('o', 131, ca_descr_info_t)
#define CA_GET_MSG _IOR('o', 132, ca_msg_t)
#define CA_SEND_MSG _IOW('o', 133, ca_msg_t)
#define CA_SET_DESCR _IOW('o', 134, ca_descr_t)


Khi truy vấn thiết bị, thiết bị sẽ mang lại thông tin như sau:

.. code-block:: none

	CA_GET_SLOT_INFO
	----------------------------
	Command = [info]
	APP: Number=[1]
	APP: Type=[1]
	APP: flags=[1]
	APP: CI High level interface
	APP: CA/CI Module Present

	CA_GET_CAP
	----------------------------
	Command = [caps]
	APP: Slots=[1]
	APP: Type=[1]
	APP: Descrambler keys=[16]
	APP: Type=[1]

	CA_SEND_MSG
	----------------------------
	Descriptors(Program Level)=[ 09 06 06 04 05 50 ff f1]
	Found CA descriptor @ program level

	(20) ES type=[2] ES pid=[201]  ES length =[0 (0x0)]
	(25) ES type=[4] ES pid=[301]  ES length =[0 (0x0)]
	ca_message length is 25 (0x19) bytes
	EN50221 CA MSG=[ 9f 80 32 19 03 01 2d d1 f0 08 01 09 06 06 04 05 50 ff f1 02 e0 c9 00 00 04 e1 2d 00 00]


Không phải tất cả ioctl đều được triển khai trong trình điều khiển từ API, cái còn lại
đã đạt được các tính năng của phần cứng mà API không thể triển khai được
bằng cách sử dụng ioctls CA_GET_MSG và CA_SEND_MSG. Một trình bao bọc kiểu EN50221 là
được sử dụng để trao đổi dữ liệu để duy trì khả năng tương thích với phần cứng khác.

.. code-block:: c

	/* a message to/from a CI-CAM */
	typedef struct ca_msg {
		unsigned int index;
		unsigned int type;
		unsigned int length;
		unsigned char msg[256];
	} ca_msg_t;


Luồng dữ liệu có thể được mô tả như sau:

.. code-block:: none

	App (User)
	-----
	parse
	  |
	  |
	  v
	en50221 APDU (package)
   --------------------------------------
   |	  |				| High Level CI driver
   |	  |				|
   |	  v				|
   |	en50221 APDU (unpackage)	|
   |	  |				|
   |	  |				|
   |	  v				|
   |	sanity checks			|
   |	  |				|
   |	  |				|
   |	  v				|
   |	do (H/W dep)			|
   --------------------------------------
	  |    Hardware
	  |
	  v

Giao diện CI cấp cao sử dụng tiêu chuẩn EN50221 DVB, tuân theo một
tiêu chuẩn đảm bảo tính bền vững trong tương lai.