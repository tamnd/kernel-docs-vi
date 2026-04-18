.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/pcmcia/locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
Khóa
=======

Tệp này giải thích sơ đồ khóa và loại trừ được sử dụng trong PCCARD
và các hệ thống con PCMCIA.


A) Tổng quan, Phân cấp khóa:
===============================

pcmcia_socket_list_rwsem
	- chỉ bảo vệ danh sách các ổ cắm

- skt_mutex
	- tuần tự hóa việc chèn / đẩy thẻ

- ops_mutex
	- tuần tự hóa hoạt động của socket


B) Loại trừ
============

Các hàm và lệnh gọi lại sau tới struct pcmcia_socket phải
được gọi với "skt_mutex" được giữ::

socket_Detect_change()
	gửi_event()
	socket_reset()
	socket_shutdown()
	socket_setup()
	socket_remove()
	socket_insert()
	socket_early_resume()
	socket_late_resume()
	socket_resume()
	socket_suspend()

struct pcmcia_callback *gọi lại

Các hàm và lệnh gọi lại sau tới struct pcmcia_socket phải
được gọi với "ops_mutex" được giữ::

socket_reset()
	socket_setup()

cấu trúc pccard_ hoạt động *ops
	cấu trúc pccard_resource_ops *resource_ops;

Lưu ý rằng send_event() và ZZ0000ZZ không được
được gọi với "ops_mutex" được giữ.


C) Bảo vệ
=============

1. Dữ liệu toàn cầu:
---------------
danh sách cấu trúc_head pcmcia_socket_list;

được bảo vệ bởi pcmcia_socket_list_rwsem;


2. Dữ liệu trên mỗi ổ cắm:
-------------------
Resource_ops và dữ liệu của chúng được bảo vệ bởi ops_mutex.

Cấu trúc pcmcia_socket "chính" được bảo vệ như sau (các trường chỉ đọc
hoặc các trường sử dụng một lần không được đề cập):

- bởi pcmcia_socket_list_rwsem::

danh sách cấu trúc_head socket_list;

- bởi thread_lock::

unsigned int thread_events;

- bởi skt_mutex::

u_int bị đình chỉ_state;
	khoảng trống (*tune_bridge);
	struct pcmcia_callback *gọi lại;
	int sơ yếu lý lịch_status;

- bởi ops_mutex::

ổ cắm socket_state_t;
	trạng thái u_int;
	u_lock_count ngắn;
	pccard_mem_map cis_mem;
	void __iomem *cis_virt;
	cấu trúc { } irq;
	io_window_t io[];
	pccard_mem_map thắng[];
	cấu trúc list_head cis_cache;
	size_t giả_cis_len;
	u8 *giả_cis;
	u_int irq_mask;
	khoảng trống (*zoom_video);
	int (*power_hook);
	tài nguyên u8...;
	danh sách cấu trúc_head devices_list;
	u8 device_count;
	cấu trúc pcmcia_state;


3. Dữ liệu trên mỗi thiết bị PCMCIA:
--------------------------

Cấu trúc pcmcia_device "chính" được bảo vệ như sau (các trường chỉ đọc
hoặc các trường sử dụng một lần không được đề cập):


- bởi pcmcia_socket->ops_mutex::

danh sách cấu trúc_head socket_device_list;
	cấu hình config_t *function_config;
	u16 _irq:1;
	u16 _io:1;
	u16 _win:4;
	u16 _locked:1;
	u16 allow_func_id_match:1;
	u16 bị đình chỉ:1;
	u16 _removed:1;

- bởi trình điều khiển PCMCIA::

io_req_t io;
	irq_req_t irq;
	config_req_t conf;
	window_handle_t thắng;
