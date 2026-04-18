.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/cx2341x-devel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển cx2341x
==================

Bộ nhớ ở chip cx2341x
-----------------------

Phần này mô tả bản đồ bộ nhớ cx2341x và ghi lại một số
đăng ký không gian.

.. note:: the memory long words are little-endian ('intel format').

.. warning::

	This information was figured out from searching through the memory
	and registers, this information may not be correct and is certainly
	not complete, and was not derived from anything more than searching
	through the memory space with commands like:

	.. code-block:: none

		ivtvctl -O min=0x02000000,max=0x020000ff

	So take this as is, I'm always searching for more stuff, it's a large
	register space :-).

Bản đồ bộ nhớ
~~~~~~~~~~

Cx2341x hiển thị toàn bộ không gian bộ nhớ 64M của nó cho máy chủ PCI thông qua PCI BAR0
(Đăng ký địa chỉ cơ sở 0). Các địa chỉ ở đây là độ lệch so với
địa chỉ được giữ trong BAR0.

.. code-block:: none

	0x00000000-0x00ffffff Encoder memory space
	0x00000000-0x0003ffff Encode.rom
	???-???         MPEG buffer(s)
	???-???         Raw video capture buffer(s)
	???-???         Raw audio capture buffer(s)
	???-???         Display buffers (6 or 9)

	0x01000000-0x01ffffff Decoder memory space
	0x01000000-0x0103ffff Decode.rom
	???-???         MPEG buffers(s)
	0x0114b000-0x0115afff Audio.rom (deprecated?)

	0x02000000-0x0200ffff Register Space

Đăng ký
~~~~~~~~~

Các thanh ghi chiếm không gian 64k bắt đầu từ độ lệch 0x02000000 từ BAR0.
Tất cả các thanh ghi này đều rộng 32 bit.

.. code-block:: none

	DMA Registers 0x000-0xff:

	0x00 - Control:
		0=reset/cancel, 1=read, 2=write, 4=stop
	0x04 - DMA status:
		1=read busy, 2=write busy, 4=read error, 8=write error, 16=link list error
	0x08 - pci DMA pointer for read link list
	0x0c - pci DMA pointer for write link list
	0x10 - read/write DMA enable:
		1=read enable, 2=write enable
	0x14 - always 0xffffffff, if set any lower instability occurs, 0x00 crashes
	0x18 - ??
	0x1c - always 0x20 or 32, smaller values slow down DMA transactions
	0x20 - always value of 0x780a010a
	0x24-0x3c - usually just random values???
	0x40 - Interrupt status
	0x44 - Write a bit here and shows up in Interrupt status 0x40
	0x48 - Interrupt Mask
	0x4C - always value of 0xfffdffff,
		if changed to 0xffffffff DMA write interrupts break.
	0x50 - always 0xffffffff
	0x54 - always 0xffffffff (0x4c, 0x50, 0x54 seem like interrupt masks, are
		3 processors on chip, Java ones, VPU, SPU, APU, maybe these are the
		interrupt masks???).
	0x60-0x7C - random values
	0x80 - first write linked list reg, for Encoder Memory addr
	0x84 - first write linked list reg, for pci memory addr
	0x88 - first write linked list reg, for length of buffer in memory addr
		(|0x80000000 or this for last link)
	0x8c-0xdc - rest of write linked list reg, 8 sets of 3 total, DMA goes here
		from linked list addr in reg 0x0c, firmware must push through or
		something.
	0xe0 - first (and only) read linked list reg, for pci memory addr
	0xe4 - first (and only) read linked list reg, for Decoder memory addr
	0xe8 - first (and only) read linked list reg, for length of buffer
	0xec-0xff - Nothing seems to be in these registers, 0xec-f4 are 0x00000000.

Vị trí bộ nhớ cho Bộ đệm mã hóa 0x700-0x7ff:

Các thanh ghi này hiển thị độ lệch của các vị trí bộ nhớ liên quan đến từng
vùng đệm được sử dụng để mã hóa, trước tiên phải dịch chuyển chúng bằng <<1.

- 0x07F8: Làm mới bộ mã hóa SDRAM
- 0x07FC: Nạp trước bộ mã hóa SDRAM

Vị trí bộ nhớ cho Bộ đệm giải mã 0x800-0x8ff:

Các thanh ghi này hiển thị độ lệch của các vị trí bộ nhớ liên quan đến từng
vùng đệm dùng để giải mã, trước tiên phải dịch chuyển chúng theo <<1.

- 0x08F8: Làm mới bộ giải mã SDRAM
- 0x08FC: Nạp trước bộ giải mã SDRAM

Các vị trí bộ nhớ khác:

- 0x2800: Điều khiển mô-đun hiển thị video
- 0x2D00: Điều khiển AO (đầu ra âm thanh?)
- 0x2D24: Xóa byte
- 0x7000: LSB I2C ghi bit đồng hồ (đảo ngược)
- 0x7004: LSB I2C ghi bit dữ liệu (đảo ngược)
- 0x7008: LSB I2C đọc bit đồng hồ
- 0x700c: LSB I2C đọc bit dữ liệu
- 0x9008: GPIO lấy trạng thái đầu vào
- 0x900c: GPIO đặt trạng thái đầu ra
- 0x9020: Hướng GPIO (Bit7 (GPIO 0..7) - 0:đầu vào, 1:đầu ra)
- 0x9050: Điều khiển SPU
- 0x9054: Đặt lại khối CTNH
- 0x9058: Điều khiển VPU
- 0xA018: Bit6: ngắt đang chờ xử lý?
- 0xA064: Lệnh APU


Đăng ký trạng thái ngắt
~~~~~~~~~~~~~~~~~~~~~~~~~

Định nghĩa các bit trong thanh ghi trạng thái ngắt 0x0040 và
mặt nạ ngắt 0x0048. Nếu một bit bị xóa trong mặt nạ thì chúng ta muốn ISR của chúng ta
thi hành.

- Chụp bắt đầu bộ mã hóa bit 31
- Bộ mã hóa bit 30 EOS
- Chụp mã hóa bit 29 VBI
- Sự kiện đặt lại mô-đun đầu vào video bộ mã hóa bit 28
- Bộ mã hóa bit 27 DMA hoàn thành
- sự kiện phát hiện thay đổi chế độ âm thanh bộ giải mã bit 24 (thông qua thông báo sự kiện)
- bit 22 Yêu cầu dữ liệu bộ giải mã
- Bộ giải mã bit 20 DMA hoàn thành
- Chèn lại bộ giải mã bit 19 VBI
- Bit 18 Bộ giải mã DMA bị lỗi (danh sách liên kết bị lỗi)

Thiếu tài liệu
---------------------

- Mã hóa bài API(?)
- Bộ giải mã API bài(?)
- Sự kiện giải mã VTRACE


Tải lên chương trình cơ sở cx2341x
---------------------------

Tài liệu này mô tả cách tải firmware cx2341x lên thẻ.

Làm thế nào để tìm thấy
~~~~~~~~~~~

Xem các trang web của các dự án khác nhau sử dụng chip này để biết thông tin
về cách lấy firmware.

Phần sụn được lưu trữ trong trình điều khiển Windows có thể được phát hiện như sau:

- Mỗi hình ảnh phần sụn là 256k byte.
- Từ 32 bit đầu tiên của ảnh Encode là 0x0000da7
- Từ 32 bit đầu tiên của ảnh Decode là 0x00003a7
- Từ 32 bit thứ 2 của cả hai ảnh là 0xaa55bb66

Làm thế nào để tải
~~~~~~~~~~~

- Ra lệnh FWapi để dừng bộ mã hóa nếu nó đang chạy. Đợi cho
  lệnh để hoàn thành.
- Ra lệnh FWapi để dừng bộ giải mã nếu nó đang chạy. Đợi cho
  lệnh để hoàn thành.
- Ra lệnh I2C cho bộ số hóa để ngừng phát ra các sự kiện VSYNC.
- Ra lệnh FWapi để tạm dừng phần sụn của bộ mã hóa.
- Ngủ 10ms.
- Ra lệnh FWapi để tạm dừng phần sụn của bộ giải mã.
- Ngủ 10ms.
- Viết 0x00000000 để đăng ký 0x2800 dừng Module hiển thị video.
- Viết 0x00000005 để đăng ký 0x2D00 dừng AO (đầu ra âm thanh?).
- Viết 0x00000000 để đăng ký 0xA064 để ping? APU.
- Viết 0xFFFFFFFE để đăng ký 0x9058 dừng VPU.
- Viết 0xFFFFFFFF đăng ký 0x9054 để reset các khối CTNH.
- Viết 0x00000001 để đăng ký 0x9050 dừng SPU.
- Ngủ 10ms.
- Viết 0x0000001A đăng ký 0x07FC để khởi tạo quá trình nạp trước của Encoding SDRAM.
- Viết 0x80000640 để đăng ký 0x07F8 để bắt đầu làm mới Bộ mã hóa SDRAM thành 1us.
- Viết 0x0000001A đăng ký 0x08FC để khởi tạo quá trình nạp trước của Bộ giải mã SDRAM.
- Viết 0x80000640 để đăng ký 0x08F8 để bắt đầu làm mới Bộ giải mã SDRAM thành 1us.
- Ngủ trong 512ms. (khuyến nghị 600ms)
- Chuyển hình ảnh chương trình cơ sở của bộ mã hóa sang offset 0 trong không gian bộ nhớ của Bộ mã hóa.
- Chuyển hình ảnh phần sụn của bộ giải mã sang offset 0 trong không gian bộ nhớ của Bộ giải mã.
- Sử dụng thao tác đọc-sửa-ghi để xóa bit 0 của thanh ghi 0x9050 để
  kích hoạt lại SPU.
- Ngủ 1 giây.
- Sử dụng thao tác đọc-sửa-ghi để xóa bit 3 và 0 của thanh ghi 0x9058
  để kích hoạt lại VPU.
- Ngủ 1 giây.
- Đưa ra các lệnh trạng thái API cho cả hai hình ảnh phần sụn để xác minh.


Cách gọi firmware API
----------------------------

Quy ước gọi ưu tiên được gọi là hộp thư phần sụn. các
hộp thư về cơ bản là một mảng có độ dài cố định đóng vai trò là ngăn xếp cuộc gọi.

Hộp thư chương trình cơ sở có thể được định vị bằng cách tìm kiếm bộ nhớ bộ mã hóa và bộ giải mã
cho chữ ký 16 byte. Chữ ký đó sẽ nằm trên ranh giới 256 byte.

Chữ ký:

.. code-block:: none

	0x78, 0x56, 0x34, 0x12, 0x12, 0x78, 0x56, 0x34,
	0x34, 0x12, 0x78, 0x56, 0x56, 0x34, 0x12, 0x78

Phần sụn triển khai 20 hộp thư gồm 20 từ 32 bit. 10 cái đầu tiên là
dành riêng cho các cuộc gọi API. 10 cái thứ hai được sử dụng bởi phần sụn cho sự kiện
thông báo.

====== ===================
  Tên chỉ mục
  ====== ===================
  0 lá cờ
  1 lệnh
  2 Giá trị trả về
  3 Thời gian chờ
  4-19 Thông số/Kết quả
  ====== ===================


Các cờ được xác định trong bảng sau. Hướng đi là từ
quan điểm của phần sụn.

==== ========== =================================================
  Mục đích hướng bit
  ==== ========== =================================================
  2 O Firmware đã xử lý lệnh.
  1 I Driver đã thiết lập xong thông số.
  0 Tôi Trình điều khiển đang sử dụng hộp thư này.
  ==== ========== =================================================

Lệnh này là một bộ liệt kê 32 bit. Thông tin cụ thể về API có thể được tìm thấy trong này
chương.

Giá trị trả về là một bộ liệt kê 32 bit. Hiện tại chỉ có hai giá trị được xác định:

- 0=thành công
- -1=lệnh không xác định.

Có 16 trường tham số/kết quả 32 bit. Trình điều khiển điền vào các trường này
với các giá trị cho tất cả các tham số mà cuộc gọi yêu cầu. Trình điều khiển ghi đè
các trường này có giá trị kết quả được cuộc gọi trả về.

Giá trị thời gian chờ bảo vệ thẻ khỏi chuỗi trình điều khiển bị treo. Nếu người lái xe
không xử lý cuộc gọi đã hoàn thành trong thời gian chờ được chỉ định, phần sụn
sẽ thiết lập lại hộp thư đó.

Để thực hiện cuộc gọi API, trình điều khiển lặp lại từng hộp thư để tìm kiếm
cái đầu tiên có sẵn (bit 0 đã bị xóa). Trình điều khiển đặt bit đó, điền vào
trong bộ liệt kê lệnh, giá trị thời gian chờ và mọi tham số bắt buộc. các
trình điều khiển sau đó thiết lập tham số bit sẵn sàng (bit 1). Phần sụn sẽ quét
hộp thư cho các lệnh đang chờ xử lý, xử lý chúng, đặt mã kết quả, điền
mảng giá trị kết quả với các giá trị trả về của lệnh gọi đó và đặt lệnh gọi
bit hoàn chỉnh (bit 2). Khi bit 2 được đặt, trình điều khiển sẽ truy xuất kết quả
và xóa tất cả các cờ. Nếu trình điều khiển không thực hiện nhiệm vụ này trong vòng
thời gian được đặt trong thanh ghi hết thời gian chờ, phần sụn sẽ đặt lại hộp thư đó.

Thông báo sự kiện được gửi từ phần sụn đến máy chủ. Người chủ trì kể cho
chương trình cơ sở mà sự kiện mà nó quan tâm thông qua cuộc gọi API. Cuộc gọi đó cho biết
firmware nào sẽ sử dụng hộp thư thông báo. Phần sụn báo hiệu cho máy chủ thông qua
một sự gián đoạn. Chỉ có 16 trường Kết quả được sử dụng, Cờ, Lệnh, Trả về
các từ giá trị và thời gian chờ không được sử dụng.


Phần mềm OSD Mô tả API
----------------------------

.. note:: this API is part of the decoder firmware, so it's cx23415 only.



CX2341X_OSD_GET_FRAMEBUFFER
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 65/0x41

Sự miêu tả
^^^^^^^^^^^

Cơ sở trả về và độ dài của bộ nhớ OSD liền kề.

Kết quả[0]
^^^^^^^^^

Địa chỉ cơ sở OSD

Kết quả[1]
^^^^^^^^^

Chiều dài OSD



CX2341X_OSD_GET_PIXEL_FORMAT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 66/0x42

Sự miêu tả
^^^^^^^^^^^

Truy vấn định dạng OSD

Kết quả[0]
^^^^^^^^^

Chỉ số 0=8bit
1=16bit RGB 5:6:5
2=16bit ARGB 1:5:5:5
3=16bit ARGB 1:4:4:4
4=32bit ARGB 8:8:8:8



CX2341X_OSD_SET_PIXEL_FORMAT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 67/0x43

Sự miêu tả
^^^^^^^^^^^

Chỉ định định dạng pixel

Thông số[0]
^^^^^^^^

- Chỉ số 0=8bit
- 1=16bit RGB 5:6:5
- 2=16bit ARGB 1:5:5:5
- 3=16bit ARGB 1:4:4:4
- 4=32bit ARGB 8:8:8:8



CX2341X_OSD_GET_STATE
~~~~~~~~~~~~~~~~~~~~~

Số đếm: 68/0x44

Sự miêu tả
^^^^^^^^^^^

Truy vấn trạng thái OSD

Kết quả[0]
^^^^^^^^^

- Bit 0 0=tắt, 1=bật
- Kiểm soát alpha 1:2 bit
- Định dạng pixel 3:5 pixel



CX2341X_OSD_SET_STATE
~~~~~~~~~~~~~~~~~~~~~

Số đếm: 69/0x45

Sự miêu tả
^^^^^^^^^^^

Công tắc OSD

Thông số[0]
^^^^^^^^

0=tắt, 1=bật



CX2341X_OSD_GET_OSD_COORDS
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 70/0x46

Sự miêu tả
^^^^^^^^^^^

Truy xuất tọa độ của vùng OSD được trộn với video

Kết quả[0]
^^^^^^^^^

Địa chỉ bộ đệm OSD

Kết quả[1]
^^^^^^^^^

Sải bước theo pixel

Kết quả[2]
^^^^^^^^^

Các dòng trong bộ đệm OSD

Kết quả[3]
^^^^^^^^^

Độ lệch ngang trong bộ đệm

Kết quả[4]
^^^^^^^^^

Độ lệch dọc trong bộ đệm



CX2341X_OSD_SET_OSD_COORDS
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 71/0x47

Sự miêu tả
^^^^^^^^^^^

Gán tọa độ vùng OSD để ghép vào video

Thông số[0]
^^^^^^^^

địa chỉ bộ đệm

Thông số[1]
^^^^^^^^

bước đệm tính bằng pixel

Thông số[2]
^^^^^^^^

dòng trong bộ đệm

Tham số [3]
^^^^^^^^

bù ngang

Thông số[4]
^^^^^^^^

bù dọc



CX2341X_OSD_GET_SCREEN_COORDS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 72/0x48

Sự miêu tả
^^^^^^^^^^^

Truy xuất tọa độ vùng màn hình OSD

Kết quả[0]
^^^^^^^^^

phần bù ngang trên cùng bên trái

Kết quả[1]
^^^^^^^^^

phần bù dọc trên cùng bên trái

Kết quả[2]
^^^^^^^^^

phần bù ngang phía dưới bên phải

Kết quả[3]
^^^^^^^^^

phần bù dọc phía dưới bên phải



CX2341X_OSD_SET_SCREEN_COORDS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 73/0x49

Sự miêu tả
^^^^^^^^^^^

Gán tọa độ vùng màn hình cần ghép với video

Thông số[0]
^^^^^^^^

phần bù ngang trên cùng bên trái

Thông số[1]
^^^^^^^^

phần bù dọc trên cùng bên trái

Thông số[2]
^^^^^^^^

độ lệch ngang phía dưới bên trái

Tham số [3]
^^^^^^^^

phần bù dọc phía dưới bên trái



CX2341X_OSD_GET_GLOBAL_ALPHA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 74/0x4A

Sự miêu tả
^^^^^^^^^^^

Truy xuất alpha toàn cầu OSD

Kết quả[0]
^^^^^^^^^

alpha toàn cầu: 0=tắt, 1=bật

Kết quả[1]
^^^^^^^^^

bit 0:7 alpha toàn cầu



CX2341X_OSD_SET_GLOBAL_ALPHA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 75/0x4B

Sự miêu tả
^^^^^^^^^^^

Cập nhật alpha toàn cầu

Thông số[0]
^^^^^^^^

alpha toàn cầu: 0=tắt, 1=bật

Thông số[1]
^^^^^^^^

alpha toàn cầu (8 bit)

Thông số[2]
^^^^^^^^

alpha cục bộ: 0=bật, 1=tắt



CX2341X_OSD_SET_BLEND_COORDS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 78/0x4C

Sự miêu tả
^^^^^^^^^^^

Di chuyển điểm bắt đầu của vùng hòa trộn trong vùng đệm hiển thị

Thông số[0]
^^^^^^^^

bù ngang trong bộ đệm

Thông số[1]
^^^^^^^^

bù dọc trong bộ đệm



CX2341X_OSD_GET_FLICKER_STATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 79/0x4F

Sự miêu tả
^^^^^^^^^^^

Truy xuất trạng thái mô-đun giảm nhấp nháy

Kết quả[0]
^^^^^^^^^

trạng thái nhấp nháy: 0=tắt, 1=bật



CX2341X_OSD_SET_FLICKER_STATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 80/0x50

Sự miêu tả
^^^^^^^^^^^

Đặt trạng thái mô-đun giảm nhấp nháy

Thông số[0]
^^^^^^^^

Trạng thái: 0=tắt, 1=bật



CX2341X_OSD_BLT_COPY
~~~~~~~~~~~~~~~~~~~~

Số đếm: 82/0x52

Sự miêu tả
^^^^^^^^^^^

Bản sao BLT

Thông số[0]
^^^^^^^^

.. code-block:: none

	'0000'  zero
	'0001' ~destination AND ~source
	'0010' ~destination AND  source
	'0011' ~destination
	'0100'  destination AND ~source
	'0101'                  ~source
	'0110'  destination XOR  source
	'0111' ~destination OR  ~source
	'1000' ~destination AND ~source
	'1001'  destination XNOR source
	'1010'                   source
	'1011' ~destination OR   source
	'1100'  destination
	'1101'  destination OR  ~source
	'1110'  destination OR   source
	'1111'  one


Thông số[1]
^^^^^^^^

Kết quả pha trộn alpha

- '01' nguồn_alpha
- '10' đích_alpha
- '11' nguồn_alpha*destination_alpha+1
  (không nếu cả alpha nguồn và đích đều bằng 0)

Thông số[2]
^^^^^^^^

.. code-block:: none

	'00' output_pixel = source_pixel

	'01' if source_alpha=0:
		 output_pixel = destination_pixel
	     if 256 > source_alpha > 1:
		 output_pixel = ((source_alpha + 1)*source_pixel +
				 (255 - source_alpha)*destination_pixel)/256

	'10' if destination_alpha=0:
		 output_pixel = source_pixel
	      if 255 > destination_alpha > 0:
		 output_pixel = ((255 - destination_alpha)*source_pixel +
				 (destination_alpha + 1)*destination_pixel)/256

	'11' if source_alpha=0:
		 source_temp = 0
	     if source_alpha=255:
		 source_temp = source_pixel*256
	     if 255 > source_alpha > 0:
		 source_temp = source_pixel*(source_alpha + 1)
	     if destination_alpha=0:
		 destination_temp = 0
	     if destination_alpha=255:
		 destination_temp = destination_pixel*256
	     if 255 > destination_alpha > 0:
		 destination_temp = destination_pixel*(destination_alpha + 1)
	     output_pixel = (source_temp + destination_temp)/256

Tham số [3]
^^^^^^^^

chiều rộng

Thông số[4]
^^^^^^^^

chiều cao

Thông số[5]
^^^^^^^^

mặt nạ pixel đích

Tham số [6]
^^^^^^^^

địa chỉ bắt đầu hình chữ nhật đích

Thông số [7]
^^^^^^^^

bước tiến đích trong dwords

Tham số [8]
^^^^^^^^

bước tiến nguồn trong dwords

Thông số[9]
^^^^^^^^

địa chỉ bắt đầu hình chữ nhật nguồn



CX2341X_OSD_BLT_FILL
~~~~~~~~~~~~~~~~~~~~

Số đếm: 83/0x53

Sự miêu tả
^^^^^^^^^^^

Màu tô BLT

Thông số[0]
^^^^^^^^

Tương tự như Param[0] trên API 0x52

Thông số[1]
^^^^^^^^

Tương tự như Param[1] trên API 0x52

Thông số[2]
^^^^^^^^

Tương tự như Param[2] trên API 0x52

Tham số [3]
^^^^^^^^

chiều rộng

Thông số[4]
^^^^^^^^

chiều cao

Thông số[5]
^^^^^^^^

mặt nạ pixel đích

Tham số [6]
^^^^^^^^

địa chỉ bắt đầu hình chữ nhật đích

Thông số [7]
^^^^^^^^

bước tiến đích trong dwords

Tham số [8]
^^^^^^^^

giá trị tô màu



CX2341X_OSD_BLT_TEXT
~~~~~~~~~~~~~~~~~~~~

Số đếm: 84/0x54

Sự miêu tả
^^^^^^^^^^^

BLT cho nguồn văn bản alpha 8 bit

Thông số[0]
^^^^^^^^

Tương tự như Param[0] trên API 0x52

Thông số[1]
^^^^^^^^

Tương tự như Param[1] trên API 0x52

Thông số[2]
^^^^^^^^

Tương tự như Param[2] trên API 0x52

Tham số [3]
^^^^^^^^

chiều rộng

Thông số[4]
^^^^^^^^

chiều cao

Thông số[5]
^^^^^^^^

mặt nạ pixel đích

Tham số [6]
^^^^^^^^

địa chỉ bắt đầu hình chữ nhật đích

Thông số [7]
^^^^^^^^

bước tiến đích trong dwords

Tham số [8]
^^^^^^^^

bước tiến nguồn trong dwords

Thông số[9]
^^^^^^^^

địa chỉ bắt đầu hình chữ nhật nguồn

Tham số [10]
^^^^^^^^^

giá trị tô màu



CX2341X_OSD_SET_FRAMEBUFFER_WINDOW
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 86/0x56

Sự miêu tả
^^^^^^^^^^^

Định vị cửa sổ đầu ra chính trên màn hình. Tọa độ phải là
sao cho toàn bộ cửa sổ vừa khít với màn hình.

Thông số[0]
^^^^^^^^

chiều rộng cửa sổ

Thông số[1]
^^^^^^^^

chiều cao cửa sổ

Thông số[2]
^^^^^^^^

góc trên cùng bên trái của cửa sổ lệch ngang

Tham số [3]
^^^^^^^^

góc trên cùng bên trái của cửa sổ offset theo chiều dọc



CX2341X_OSD_SET_CHROMA_KEY
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 96/0x60

Sự miêu tả
^^^^^^^^^^^

Công tắc phím Chroma và màu sắc

Thông số[0]
^^^^^^^^

trạng thái: 0=tắt, 1=bật

Thông số[1]
^^^^^^^^

màu sắc



CX2341X_OSD_GET_ALPHA_CONTENT_INDEX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 97/0x61

Sự miêu tả
^^^^^^^^^^^

Truy xuất chỉ mục nội dung alpha

Kết quả[0]
^^^^^^^^^

chỉ mục nội dung alpha, Phạm vi 0:15



CX2341X_OSD_SET_ALPHA_CONTENT_INDEX
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 98/0x62

Sự miêu tả
^^^^^^^^^^^

Chỉ định chỉ mục nội dung alpha

Thông số[0]
^^^^^^^^

chỉ mục nội dung alpha, phạm vi 0:15


Mô tả phần mềm mã hóa API
--------------------------------

CX2341X_ENC_PING_FW
~~~~~~~~~~~~~~~~~~~

Số đếm: 128/0x80

Sự miêu tả
^^^^^^^^^^^

Không làm gì cả. Có thể được sử dụng để kiểm tra xem phần sụn có phản hồi hay không.



CX2341X_ENC_START_CAPTURE
~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 129/0x81

Sự miêu tả
^^^^^^^^^^^

Bắt đầu thu thập dữ liệu video, âm thanh và/hoặc VBI. Tất cả mã hóa
các tham số phải được khởi tạo trước lệnh gọi API này. Chụp khung hình
liên tục hoặc cho đến khi chụp được một số khung hình xác định trước.

Thông số[0]
^^^^^^^^

Loại luồng ghi:

- 0=MPEG
	- 1=Thô
	- 2=Thông qua thô
	- 3=VBI


Thông số[1]
^^^^^^^^

Mặt nạ bit:

- Bit 0 khi được đặt, chụp YUV
	- Bit 1 khi được đặt, ghi lại âm thanh PCM
	- Bit 2 khi được thiết lập sẽ ghi lại VBI (giống như param[0]=3)
	- Bit 3 khi được đặt thì đích chụp là bộ giải mã
	  (giống như param[0]=2)
	- Bit 4 khi được đặt thì đích chụp là máy chủ

.. note:: this parameter is only meaningful for RAW capture type.



CX2341X_ENC_STOP_CAPTURE
~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 130/0x82

Sự miêu tả
^^^^^^^^^^^

Kết thúc quá trình chụp đang diễn ra

Thông số[0]
^^^^^^^^

- 0=dừng ở cuối GOP (tạo IRQ)
- 1=dừng ngay lập tức (không có IRQ)

Thông số[1]
^^^^^^^^

Loại luồng cần dừng, xem thông số [0] của API 0x81

Thông số[2]
^^^^^^^^

Loại phụ, xem thông số [1] của API 0x81



CX2341X_ENC_SET_AUDIO_ID
~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 137/0x89

Sự miêu tả
^^^^^^^^^^^

Gán ID luồng truyền tải của luồng âm thanh được mã hóa

Thông số[0]
^^^^^^^^

ID luồng âm thanh



CX2341X_ENC_SET_VIDEO_ID
~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 139/0x8B

Sự miêu tả
^^^^^^^^^^^

Đặt ID luồng truyền tải video

Thông số[0]
^^^^^^^^

ID luồng video



CX2341X_ENC_SET_PCR_ID
~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 141/0x8D

Sự miêu tả
^^^^^^^^^^^

Gán ID luồng truyền tải cho các gói PCR

Thông số[0]
^^^^^^^^

ID luồng PCR



CX2341X_ENC_SET_FRAME_RATE
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 143/0x8F

Sự miêu tả
^^^^^^^^^^^

Đặt khung hình video mỗi giây. Thay đổi xảy ra khi bắt đầu GOP mới.

Thông số[0]
^^^^^^^^

- 0=30 khung hình/giây
- 1=25 khung hình/giây



CX2341X_ENC_SET_FRAME_SIZE
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 145/0x91

Sự miêu tả
^^^^^^^^^^^

Chọn độ phân giải mã hóa luồng video.

Thông số[0]
^^^^^^^^

Chiều cao trong dòng. Mặc định 480

Thông số[1]
^^^^^^^^

Chiều rộng tính bằng pixel. Mặc định 720



CX2341X_ENC_SET_BIT_RATE
~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 149/0x95

Sự miêu tả
^^^^^^^^^^^

Chỉ định tốc độ bit luồng video trung bình.

Thông số[0]
^^^^^^^^

0=tốc độ bit thay đổi, 1=tốc độ bit không đổi

Thông số[1]
^^^^^^^^

tốc độ bit tính bằng bit trên giây

Thông số[2]
^^^^^^^^

tốc độ bit cao nhất tính bằng bit trên giây, chia cho 400

Tham số [3]
^^^^^^^^

Tốc độ bit Mux tính bằng số bit trên giây, chia cho 400. Có thể bằng 0 (mặc định).

Thông số[4]
^^^^^^^^

Kiểm soát tốc độ Phần đệm VBR

Thông số[5]
^^^^^^^^

Bộ đệm VBV được bộ mã hóa sử dụng

.. note::

	#) Param\[3\] and Param\[4\] seem to be always 0
	#) Param\[5\] doesn't seem to be used.



CX2341X_ENC_SET_GOP_PROPERTIES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 151/0x97

Sự miêu tả
^^^^^^^^^^^

Thiết lập cấu trúc GOP

Thông số[0]
^^^^^^^^

Kích thước GOP (tối đa là 34)

Thông số[1]
^^^^^^^^

Số khung B giữa khung I và khung P cộng thêm 1.
Ví dụ: IBBPBBPBBPBB --> GOP kích thước: 12, số khung B: 2+1 = 3

.. note::

	GOP size must be a multiple of (B-frames + 1).



CX2341X_ENC_SET_ASPECT_RATIO
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 153/0x99

Sự miêu tả
^^^^^^^^^^^

Đặt tỷ lệ khung hình mã hóa. Những thay đổi về tỷ lệ khung hình có hiệu lực
khi bắt đầu GOP tiếp theo.

Thông số[0]
^^^^^^^^

- '0000' bị cấm
- '0001' hình vuông 1:1
- '0010' 4:3
- '0011' 16:9
- '0100' 2.21:1
- '0101' đến '1111' dành riêng



CX2341X_ENC_SET_DNR_FILTER_MODE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 155/0x9B

Sự miêu tả
^^^^^^^^^^^

Chỉ định chế độ vận hành Giảm tiếng ồn động

Thông số[0]
^^^^^^^^

Bit0: Bộ lọc không gian, set=auto, clear=manual
Bit1: Bộ lọc tạm thời, set=auto, clear=manual

Thông số[1]
^^^^^^^^

Bộ lọc trung vị:

- 0=Đã tắt
- 1=Nằm ngang
- 2=Dọc
- 3=Chân trời/Đỉnh
- 4=Đường chéo



CX2341X_ENC_SET_DNR_FILTER_PROPS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 157/0x9D

Sự miêu tả
^^^^^^^^^^^

Các giá trị bộ lọc Giảm nhiễu động này chỉ có ý nghĩa khi
bộ lọc tương ứng được đặt thành "thủ công" (Xem API 0x9B)

Thông số[0]
^^^^^^^^

Bộ lọc không gian: mặc định 0, phạm vi 0:15

Thông số[1]
^^^^^^^^

Bộ lọc tạm thời: mặc định 0, phạm vi 0:31



CX2341X_ENC_SET_CORING_LEVELS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 159/0x9F

Sự miêu tả
^^^^^^^^^^^

Chỉ định các thuộc tính bộ lọc trung bình Giảm tiếng ồn động.

Thông số[0]
^^^^^^^^

Ngưỡng trên đó bộ lọc độ sáng trung bình được bật.
Mặc định: 0, phạm vi 0:255

Thông số[1]
^^^^^^^^

Ngưỡng dưới mức mà bộ lọc độ sáng trung bình được bật.
Mặc định: 255, phạm vi 0:255

Thông số[2]
^^^^^^^^

Ngưỡng trên đó bộ lọc trung vị sắc độ được bật.
Mặc định: 0, phạm vi 0:255

Tham số [3]
^^^^^^^^

Ngưỡng dưới mức mà bộ lọc trung vị sắc độ được bật.
Mặc định: 255, phạm vi 0:255



CX2341X_ENC_SET_SPATIAL_FILTER_TYPE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 161/0xA1

Sự miêu tả
^^^^^^^^^^^

Chỉ định các tham số lọc trước không gian

Thông số[0]
^^^^^^^^

Bộ lọc độ sáng

- 0=Tắt
- 1=1D Ngang
- 2=1D Dọc
- 3=2D H/V Có thể tách rời (mặc định)
- 4=2D Đối xứng không thể tách rời

Thông số[1]
^^^^^^^^

Bộ lọc sắc độ

- 0=Tắt
- 1=1D Ngang (mặc định)



CX2341X_ENC_SET_VBI_LINE
~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 183/0xB7

Sự miêu tả
^^^^^^^^^^^

Chọn số dòng VBI.

Thông số[0]
^^^^^^^^

- Số dòng bit 0:4
- Bit 31 0=top_field, 1=bottom_field
- Bit 0:31 all set chỉ định "tất cả các dòng"

Thông số[1]
^^^^^^^^

Tính năng thông tin dòng VBI: 0=đã tắt, 1=đã bật

Thông số[2]
^^^^^^^^

Cắt lát: 0=Không có, 1=Phụ đề chi tiết
Hầu như chắc chắn không được thực hiện. Đặt thành 0.

Tham số [3]
^^^^^^^^

Các mẫu độ chói trong dòng này.
Hầu như chắc chắn không được thực hiện. Đặt thành 0.

Thông số[4]
^^^^^^^^

Các mẫu sắc độ trong dòng này
Hầu như chắc chắn không được thực hiện. Đặt thành 0.



CX2341X_ENC_SET_STREAM_TYPE
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 185/0xB9

Sự miêu tả
^^^^^^^^^^^

Chỉ định loại luồng

.. note::

	Transport stream is not working in recent firmwares.
	And in older firmwares the timestamps in the TS seem to be
	unreliable.

Thông số[0]
^^^^^^^^

- 0=Luồng chương trình
- 1=Luồng truyền tải
- Luồng 2=MPEG1
- 3=PES Luồng A/V
- 5=PES Luồng video
- 7=PES Luồng âm thanh
- 10=DVD luồng
- 11=VCD luồng
- 12=SVCD luồng
- 13=DVD_S1 luồng
- 14=DVD_S2 luồng



CX2341X_ENC_SET_OUTPUT_PORT
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 187/0xBB

Sự miêu tả
^^^^^^^^^^^

Chỉ định cổng đầu ra luồng. Thông thường 0 khi dữ liệu được sao chép qua
bus PCI (DMA) và 1 khi dữ liệu được truyền sang chip khác
(pvrusb và cx88-blackbird).

Thông số[0]
^^^^^^^^

- 0=Bộ nhớ (mặc định)
- 1=Truyền phát
- 2=Nối tiếp

Thông số[1]
^^^^^^^^

Không xác định, nhưng để giá trị này về 0 có vẻ hiệu quả nhất. Dấu hiệu cho thấy rằng
điều này có thể liên quan đến sự hỗ trợ của USB, mặc dù vượt qua bất cứ điều gì ngoại trừ 0
chỉ phá vỡ mọi thứ.



CX2341X_ENC_SET_AUDIO_PROPERTIES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 189/0xBD

Sự miêu tả
^^^^^^^^^^^

Đặt thuộc tính luồng âm thanh, có thể được gọi trong khi đang tiến hành mã hóa.

.. note::

	All bitfields are consistent with ISO11172 documentation except
	bits 2:3 which ISO docs define as:

	- '11' Layer I
	- '10' Layer II
	- '01' Layer III
	- '00' Undefined

	This discrepancy may indicate a possible error in the documentation.
	Testing indicated that only Layer II is actually working, and that
	the minimum bitrate should be 192 kbps.

Thông số[0]
^^^^^^^^

Mặt nạ bit:

.. code-block:: none

	   0:1  '00' 44.1Khz
		'01' 48Khz
		'10' 32Khz
		'11' reserved

	   2:3  '01'=Layer I
		'10'=Layer II

	   4:7  Bitrate:
		     Index | Layer I     | Layer II
		     ------+-------------+------------
		    '0000' | free format | free format
		    '0001' |  32 kbit/s  |  32 kbit/s
		    '0010' |  64 kbit/s  |  48 kbit/s
		    '0011' |  96 kbit/s  |  56 kbit/s
		    '0100' | 128 kbit/s  |  64 kbit/s
		    '0101' | 160 kbit/s  |  80 kbit/s
		    '0110' | 192 kbit/s  |  96 kbit/s
		    '0111' | 224 kbit/s  | 112 kbit/s
		    '1000' | 256 kbit/s  | 128 kbit/s
		    '1001' | 288 kbit/s  | 160 kbit/s
		    '1010' | 320 kbit/s  | 192 kbit/s
		    '1011' | 352 kbit/s  | 224 kbit/s
		    '1100' | 384 kbit/s  | 256 kbit/s
		    '1101' | 416 kbit/s  | 320 kbit/s
		    '1110' | 448 kbit/s  | 384 kbit/s

		.. note::

			For Layer II, not all combinations of total bitrate
			and mode are allowed. See ISO11172-3 3-Annex B,
			Table 3-B.2

	   8:9  '00'=Stereo
		'01'=JointStereo
		'10'=Dual
		'11'=Mono

		.. note::

			The cx23415 cannot decode Joint Stereo properly.

	  10:11 Mode Extension used in joint_stereo mode.
		In Layer I and II they indicate which subbands are in
		intensity_stereo. All other subbands are coded in stereo.
		    '00' subbands 4-31 in intensity_stereo, bound==4
		    '01' subbands 8-31 in intensity_stereo, bound==8
		    '10' subbands 12-31 in intensity_stereo, bound==12
		    '11' subbands 16-31 in intensity_stereo, bound==16

	  12:13 Emphasis:
		    '00' None
		    '01' 50/15uS
		    '10' reserved
		    '11' CCITT J.17

	  14 	CRC:
		    '0' off
		    '1' on

	  15    Copyright:
		    '0' off
		    '1' on

	  16    Generation:
		    '0' copy
		    '1' original



CX2341X_ENC_HALT_FW
~~~~~~~~~~~~~~~~~~~

Số đếm: 195/0xC3

Sự miêu tả
^^^^^^^^^^^

Phần sụn bị tạm dừng và không có cuộc gọi API nào được phục vụ cho đến khi
firmware được tải lên lại.



CX2341X_ENC_GET_VERSION
~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 196/0xC4

Sự miêu tả
^^^^^^^^^^^

Trả về phiên bản phần mềm mã hóa.

Kết quả[0]
^^^^^^^^^

Phiên bản bitmask:
- Xây dựng bit 0:15
- Bit 16:23 thứ
- Bit 24:31 chính



CX2341X_ENC_SET_GOP_CLOSURE
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 197/0xC5

Sự miêu tả
^^^^^^^^^^^

Gán thuộc tính đóng/mở GOP.

Thông số[0]
^^^^^^^^

- 0=Mở
- 1=Đã đóng



CX2341X_ENC_GET_SEQ_END
~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 198/0xC6

Sự miêu tả
^^^^^^^^^^^

Lấy mã kết thúc chuỗi của bộ đệm của bộ mã hóa. Khi bị bắt
được bắt đầu, một số ngắt vẫn được tạo ra, ngắt cuối cùng
sẽ có Kết quả [0] được đặt thành 1 và Kết quả [1] sẽ chứa kích thước
của bộ đệm.

Kết quả[0]
^^^^^^^^^

Trạng thái truyền (1 nếu là bộ đệm cuối cùng)

Kết quả[1]
^^^^^^^^^

Nếu Kết quả[0] là 1, thì kết quả này chứa kích thước của bộ đệm cuối cùng, không xác định
mặt khác.



CX2341X_ENC_SET_PGM_INDEX_INFO
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 199/0xC7

Sự miêu tả
^^^^^^^^^^^

Đặt thông tin chỉ mục chương trình.
Thông tin được lưu trữ như sau:

.. code-block:: c

	struct info {
		u32 length;		// Length of this frame
		u32 offset_low;		// Offset in the file of the
		u32 offset_high;	// start of this frame
		u32 mask1;		// Bits 0-2 are the type mask:
					// 1=I, 2=P, 4=B
					// 0=End of Program Index, other fields
					//   are invalid.
		u32 pts;		// The PTS of the frame
		u32 mask2;		// Bit 0 is bit 32 of the pts.
	};
	u32 table_ptr;
	struct info index[400];

table_ptr là địa chỉ bộ nhớ bộ mã hóa trong bảng được
Các mục ZZ0000ZZ sẽ được viết.

.. note:: This is a ringbuffer, so the table_ptr will wraparound.

Thông số[0]
^^^^^^^^

Mặt nạ hình ảnh:
- 0=Không thu thập chỉ mục
- 1=I đóng khung
- 3=khung hình I,P
- 7=Khung hình I,P,B

(Dường như bị bỏ qua, nó luôn lập chỉ mục các khung I, P và B)

Thông số[1]
^^^^^^^^

Các yếu tố được yêu cầu (tối đa 400)

Kết quả[0]
^^^^^^^^^

Offset trong bộ nhớ mã hóa ở đầu bảng.

Kết quả[1]
^^^^^^^^^

Số phần tử được phân bổ tối đa là Param[1]



CX2341X_ENC_SET_VBI_CONFIG
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 200/0xC8

Sự miêu tả
^^^^^^^^^^^

Định cấu hình cài đặt VBI

Thông số[0]
^^^^^^^^

Bản đồ bit:

.. code-block:: none

	    0    Mode '0' Sliced, '1' Raw
	    1:3  Insertion:
		     '000' insert in extension & user data
		     '001' insert in private packets
		     '010' separate stream and user data
		     '111' separate stream and private data
	    8:15 Stream ID (normally 0xBD)

Thông số[1]
^^^^^^^^

Số khung hình trên mỗi ngắt (tối đa 8). Chỉ hợp lệ ở chế độ thô.

Thông số[2]
^^^^^^^^

Tổng số khung VBI thô. Chỉ hợp lệ ở chế độ thô.

Tham số [3]
^^^^^^^^

Mã bắt đầu

Thông số[4]
^^^^^^^^

Mã dừng

Thông số[5]
^^^^^^^^

Dòng trên mỗi khung

Tham số [6]
^^^^^^^^

Byte trên mỗi dòng

Kết quả[0]
^^^^^^^^^

Các khung hình được quan sát trên mỗi lần ngắt chỉ ở chế độ thô. Cơn thịnh nộ 1 đến Param[1]

Kết quả[1]
^^^^^^^^^

Số lượng khung hình được quan sát ở chế độ thô. Phạm vi 1 đến Param[2]

Kết quả[2]
^^^^^^^^^

Bù bộ nhớ để bắt đầu hoặc dữ liệu VBI thô



CX2341X_ENC_SET_DMA_BLOCK_SIZE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 201/0xC9

Sự miêu tả
^^^^^^^^^^^

Đặt kích thước khối truyền DMA

Thông số[0]
^^^^^^^^

Kích thước khối truyền DMA tính bằng byte hoặc khung. Khi đơn vị là byte,
kích thước khối được hỗ trợ là 2^7, 2^8 và 2^9 byte.

Thông số[1]
^^^^^^^^

Đơn vị: 0=byte, 1=khung



CX2341X_ENC_GET_PREV_DMA_INFO_MB_10
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 202/0xCA

Sự miêu tả
^^^^^^^^^^^

Trả về thông tin về lần chuyển DMA trước đó kết hợp với
bit 27 của mặt nạ ngắt. Sử dụng hộp thư 10.

Kết quả[0]
^^^^^^^^^

Loại luồng

Kết quả[1]
^^^^^^^^^

Bù đắp địa chỉ

Kết quả[2]
^^^^^^^^^

Kích thước chuyển tối đa



CX2341X_ENC_GET_PREV_DMA_INFO_MB_9
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 203/0xCB

Sự miêu tả
^^^^^^^^^^^

Trả về thông tin về lần chuyển DMA trước đó kết hợp với
bit 27 hoặc 18 của mặt nạ ngắt. Sử dụng hộp thư 9.

Kết quả[0]
^^^^^^^^^

Các bit trạng thái:
- 0 lần đọc hoàn thành
- 1 bài viết đã hoàn thành
- Lỗi đọc 2 DMA
- 3 lỗi ghi DMA
- 4 lỗi mảng Scatter-Gather

Kết quả[1]
^^^^^^^^^

Loại DMA

Kết quả[2]
^^^^^^^^^

Bit dấu thời gian trình bày 0..31

Kết quả[3]
^^^^^^^^^

Dấu thời gian trình bày bit 32



CX2341X_ENC_SCHED_DMA_TO_HOST
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 204/0xCC

Sự miêu tả
^^^^^^^^^^^

Thiết lập DMA để vận hành máy chủ

Thông số[0]
^^^^^^^^

Địa chỉ bộ nhớ của danh sách liên kết

Thông số[1]
^^^^^^^^

Độ dài của danh sách liên kết (wtf: đơn vị nào ???)

Thông số[2]
^^^^^^^^

Loại DMA (0=MPEG)



CX2341X_ENC_INITIALIZE_INPUT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 205/0xCD

Sự miêu tả
^^^^^^^^^^^

Khởi tạo đầu vào video



CX2341X_ENC_SET_FRAME_DROP_RATE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 208/0xD0

Sự miêu tả
^^^^^^^^^^^

Đối với mỗi khung hình được chụp, hãy bỏ qua số lượng khung hình được chỉ định.

Thông số[0]
^^^^^^^^

Số khung hình cần bỏ qua



CX2341X_ENC_PAUSE_ENCODER
~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 210/0xD2

Sự miêu tả
^^^^^^^^^^^

Trong điều kiện tạm dừng, tất cả các khung hình sẽ bị loại bỏ thay vì được mã hóa.

Thông số[0]
^^^^^^^^

- 0=Tạm dừng mã hóa
- 1=Tiếp tục mã hóa



CX2341X_ENC_REFRESH_INPUT
~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 211/0xD3

Sự miêu tả
^^^^^^^^^^^

Làm mới đầu vào video



CX2341X_ENC_SET_COPYRIGHT
~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 212/0xD4

Sự miêu tả
^^^^^^^^^^^

Đặt thuộc tính bản quyền luồng

Thông số[0]
^^^^^^^^


- 0=Luồng không có bản quyền
- 1=Luồng có bản quyền



CX2341X_ENC_SET_EVENT_NOTIFICATION
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 213/0xD5

Sự miêu tả
^^^^^^^^^^^

Thiết lập chương trình cơ sở để thông báo cho máy chủ về một sự kiện cụ thể. Máy chủ phải
vạch mặt bit ngắt.

Thông số[0]
^^^^^^^^

Sự kiện (0=làm mới đầu vào bộ mã hóa)

Thông số[1]
^^^^^^^^

Thông báo 0=đã tắt 1=đã bật

Thông số[2]
^^^^^^^^

Bit ngắt

Tham số [3]
^^^^^^^^

Khe cắm hộp thư, -1 nếu không cần hộp thư.



CX2341X_ENC_SET_NUM_VSYNC_LINES
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 214/0xD6

Sự miêu tả
^^^^^^^^^^^

Tùy thuộc vào bộ giải mã video analog được sử dụng, điều này sẽ ấn định số
dòng cho trường 1 và 2.

Thông số[0]
^^^^^^^^

Trường 1 số dòng:
- 0x00EF cho SAA7114
- 0x00F0 cho SAA7115
- 0x0105 cho Micronas

Thông số[1]
^^^^^^^^

Trường 2 số dòng:
- 0x00EF cho SAA7114
- 0x00F0 cho SAA7115
- 0x0106 cho Micronas



CX2341X_ENC_SET_PLACEHOLDER
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 215/0xD7

Sự miêu tả
^^^^^^^^^^^

Cung cấp cơ chế chèn dữ liệu người dùng tùy chỉnh vào luồng MPEG.

Thông số[0]
^^^^^^^^

- 0=tiện ích mở rộng và dữ liệu người dùng
- 1=gói riêng có ID luồng 0xBD

Thông số[1]
^^^^^^^^

Tốc độ chèn dữ liệu, tính bằng đơn vị khung (đối với gói riêng)
hoặc GOP (đối với dữ liệu mở rộng và người dùng)

Thông số[2]
^^^^^^^^

Số lượng dữ liệu DWORD (bên dưới) cần chèn

Tham số [3]
^^^^^^^^

Dữ liệu tùy chỉnh 0

Thông số[4]
^^^^^^^^

Dữ liệu tùy chỉnh 1

Thông số[5]
^^^^^^^^

Dữ liệu tùy chỉnh 2

Tham số [6]
^^^^^^^^

Dữ liệu tùy chỉnh 3

Thông số [7]
^^^^^^^^

Dữ liệu tùy chỉnh 4

Tham số [8]
^^^^^^^^

Dữ liệu tùy chỉnh 5

Thông số[9]
^^^^^^^^

Dữ liệu tùy chỉnh 6

Tham số [10]
^^^^^^^^^

Dữ liệu tùy chỉnh 7

Tham số [11]
^^^^^^^^^

Dữ liệu tùy chỉnh 8



CX2341X_ENC_MUTE_VIDEO
~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 217/0xD9

Sự miêu tả
^^^^^^^^^^^

Tắt tiếng video

Thông số[0]
^^^^^^^^

Cách sử dụng bit:

.. code-block:: none

	 0    	'0'=video not muted
		'1'=video muted, creates frames with the YUV color defined below
	 1:7  	Unused
	 8:15 	V chrominance information
	16:23 	U chrominance information
	24:31 	Y luminance information



CX2341X_ENC_MUTE_AUDIO
~~~~~~~~~~~~~~~~~~~~~~

Enum: 218/0xDA

Sự miêu tả
^^^^^^^^^^^

Tắt tiếng âm thanh

Thông số[0]
^^^^^^^^

- 0=âm thanh không bị tắt tiếng
- 1=âm thanh bị tắt tiếng (tạo ra luồng âm thanh mpeg im lặng)



CX2341X_ENC_SET_VERT_CROP_LINE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 219/0xDB

Sự miêu tả
^^^^^^^^^^^

Điều gì đó liên quan đến 'Đường cắt dọc'

Thông số[0]
^^^^^^^^

Nếu saa7114 và chụp VBI thô và 60 Hz thì đặt thành 10001.
Khác 0.



CX2341X_ENC_MISC
~~~~~~~~~~~~~~~~

Số đếm: 220/0xDC

Sự miêu tả
^^^^^^^^^^^

Các hành động khác. Không biết 100% những gì nó làm. Nó thực sự là một
loại cuộc gọi ioctl. Tham số đầu tiên là số lệnh, tham số thứ hai
giá trị.

Thông số[0]
^^^^^^^^

Số lệnh:

.. code-block:: none

	 1=set initial SCR value when starting encoding (works).
	 2=set quality mode (apparently some test setting).
	 3=setup advanced VIM protection handling.
	   Always 1 for the cx23416 and 0 for cx23415.
	 4=generate DVD compatible PTS timestamps
	 5=USB flush mode
	 6=something to do with the quantization matrix
	 7=set navigation pack insertion for DVD: adds 0xbf (private stream 2)
	   packets to the MPEG. The size of these packets is 2048 bytes (including
	   the header of 6 bytes: 0x000001bf + length). The payload is zeroed and
	   it is up to the application to fill them in. These packets are apparently
	   inserted every four frames.
	 8=enable scene change detection (seems to be a failure)
	 9=set history parameters of the video input module
	10=set input field order of VIM
	11=set quantization matrix
	12=reset audio interface after channel change or input switch (has no argument).
	   Needed for the cx2584x, not needed for the mspx4xx, but it doesn't seem to
	   do any harm calling it regardless.
	13=set audio volume delay
	14=set audio delay


Thông số[1]
^^^^^^^^

Giá trị lệnh.

Phần mềm giải mã API mô tả
--------------------------------

.. note:: this API is part of the decoder firmware, so it's cx23415 only.



CX2341X_DEC_PING_FW
~~~~~~~~~~~~~~~~~~~

Số đếm: 0/0x00

Sự miêu tả
^^^^^^^^^^^

Cuộc gọi API này không làm gì cả. Nó có thể được sử dụng để kiểm tra xem phần sụn
đang phản hồi.



CX2341X_DEC_START_PLAYBACK
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 1/0x01

Sự miêu tả
^^^^^^^^^^^

Bắt đầu hoặc tiếp tục phát lại.

Thông số[0]
^^^^^^^^

0 dựa trên số khung trong GOP để bắt đầu phát lại.

Thông số[1]
^^^^^^^^

Chỉ định số lượng khung âm thanh bị tắt tiếng sẽ phát trước bình thường
âm thanh tiếp tục. (Điều này không được triển khai trong phần sụn, để ở mức 0)



CX2341X_DEC_STOP_PLAYBACK
~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 2/0x02

Sự miêu tả
^^^^^^^^^^^

Kết thúc phát lại và xóa tất cả bộ đệm giải mã. Nếu PTS không bằng 0,
quá trình phát lại dừng ở PTS được chỉ định.

Thông số[0]
^^^^^^^^

Hiển thị 0=khung hình cuối cùng, 1=đen

.. note::

	this takes effect immediately, so if you want to wait for a PTS,
	then use '0', otherwise the screen goes to black at once.
	You can call this later (even if there is no playback) with a 1 value
	to set the screen to black.

Thông số[1]
^^^^^^^^

PTS thấp

Thông số[2]
^^^^^^^^

PTS cao



CX2341X_DEC_SET_PLAYBACK_SPEED
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 3/0x03

Sự miêu tả
^^^^^^^^^^^

Luồng phát lại ở tốc độ khác với bình thường. Có hai chế độ
hoạt động:

- Mượt mà: máy chủ truyền toàn bộ luồng và phần sụn không được sử dụng
	  khung.
	- Thô: máy chủ loại bỏ các khung dựa trên việc lập chỉ mục theo yêu cầu để đạt được
	  tốc độ mong muốn.

Thông số[0]
^^^^^^^^

.. code-block:: none

	Bitmap:
	    0:7  0 normal
		 1 fast only "1.5 times"
		 n nX fast, 1/nX slow
	    30   Framedrop:
		     '0' during 1.5 times play, every other B frame is dropped
		     '1' during 1.5 times play, stream is unchanged (bitrate
			 must not exceed 8mbps)
	    31   Speed:
		     '0' slow
		     '1' fast

.. note::

	n is limited to 2. Anything higher does not result in
	faster playback. Instead the host should start dropping frames.

Thông số[1]
^^^^^^^^

Hướng: 0=tiến, 1=lùi

.. note::

	to make reverse playback work you have to write full GOPs in
	reverse order.

Thông số[2]
^^^^^^^^

.. code-block:: none

	Picture mask:
	    1=I frames
	    3=I, P frames
	    7=I, P, B frames

Tham số [3]
^^^^^^^^

B khung hình trên GOP (chỉ dành cho phát ngược)

.. note::

	for reverse playback the Picture Mask should be set to I or I, P.
	Adding B frames to the mask will result in corrupt video. This field
	has to be set to the correct value in order to keep the timing correct.

Thông số[4]
^^^^^^^^

Tắt tiếng âm thanh: 0=tắt, 1=bật

Thông số[5]
^^^^^^^^

Hiển thị 0=khung, 1=trường

Tham số [6]
^^^^^^^^

Chỉ định số khung âm thanh bị tắt tiếng sẽ phát trước âm thanh bình thường
sơ yếu lý lịch. (Không được triển khai trong phần sụn, để ở mức 0)



CX2341X_DEC_STEP_VIDEO
~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 5/0x05

Sự miêu tả
^^^^^^^^^^^

Mỗi lệnh gọi tới API này sẽ chuyển quá trình phát lại sang thiết bị tiếp theo được xác định bên dưới
theo hướng phát lại hiện tại.

Thông số[0]
^^^^^^^^

0=khung, 1=trường trên cùng, 2=trường dưới cùng



CX2341X_DEC_SET_DMA_BLOCK_SIZE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 8/0x08

Sự miêu tả
^^^^^^^^^^^

Đặt kích thước khối truyền DMA. Đối trọng với API 0xC9

Thông số[0]
^^^^^^^^

Kích thước khối truyền DMA tính bằng byte. Có thể chỉ định kích thước khác
khi ban hành lệnh truyền DMA.



CX2341X_DEC_GET_XFER_INFO
~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 9/0x09

Sự miêu tả
^^^^^^^^^^^

Cuộc gọi API này có thể được sử dụng để phát hiện tình trạng kết thúc luồng.

Kết quả[0]
^^^^^^^^^

Loại luồng

Kết quả[1]
^^^^^^^^^

Địa chỉ bù đắp

Kết quả[2]
^^^^^^^^^

Số byte tối đa cần chuyển

Kết quả[3]
^^^^^^^^^

Bộ đệm đầy



CX2341X_DEC_GET_DMA_STATUS
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 10/0x0A

Sự miêu tả
^^^^^^^^^^^

Trạng thái của lần chuyển DMA cuối cùng

Kết quả[0]
^^^^^^^^^

Bit 1 được đặt có nghĩa là quá trình truyền hoàn tất
Bit 2 được đặt có nghĩa là lỗi DMA
Đặt bit 3 có nghĩa là lỗi danh sách liên kết

Kết quả[1]
^^^^^^^^^

Loại DMA: 0=MPEG, 1=OSD, 2=YUV



CX2341X_DEC_SCHED_DMA_FROM_HOST
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 11/0x0B

Sự miêu tả
^^^^^^^^^^^

Thiết lập DMA từ hoạt động của máy chủ. Đối trọng với API 0xCC

Thông số[0]
^^^^^^^^

Địa chỉ bộ nhớ của danh sách liên kết

Thông số[1]
^^^^^^^^

Tổng số byte # of cần truyền

Thông số[2]
^^^^^^^^

Loại DMA (0=MPEG, 1=OSD, 2=YUV)



CX2341X_DEC_PAUSE_PLAYBACK
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 13/0x0D

Sự miêu tả
^^^^^^^^^^^

Dừng phát lại ngay lập tức. Ở chế độ này, khi bộ đệm bên trong được
đầy, sẽ không có thêm dữ liệu nào được chấp nhận và IRQ yêu cầu dữ liệu sẽ bị hủy
đeo mặt nạ.

Thông số[0]
^^^^^^^^

Hiển thị: 0=khung hình cuối cùng, 1=đen



CX2341X_DEC_HALT_FW
~~~~~~~~~~~~~~~~~~~

Số đếm: 14/0x0E

Sự miêu tả
^^^^^^^^^^^

Phần sụn bị tạm dừng và không có cuộc gọi API nào được phục vụ cho đến khi
firmware được tải lên lại.



CX2341X_DEC_SET_STANDARD
~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 16/0x10

Sự miêu tả
^^^^^^^^^^^

Chọn tiêu chuẩn hiển thị

Thông số[0]
^^^^^^^^

0=NTSC, 1=PAL



CX2341X_DEC_GET_VERSION
~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 17/0x11

Sự miêu tả
^^^^^^^^^^^

Trả về thông tin phiên bản phần mềm giải mã

Kết quả[0]
^^^^^^^^^

Phiên bản bitmask:
	- Xây dựng bit 0:15
	- Bit 16:23 thứ
	- Bit 24:31 chính



CX2341X_DEC_SET_STREAM_INPUT
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 20/0x14

Sự miêu tả
^^^^^^^^^^^

Chọn cổng đầu vào luồng giải mã

Thông số[0]
^^^^^^^^

0=bộ nhớ (mặc định), 1=phát trực tuyến



CX2341X_DEC_GET_TIMING_INFO
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 21/0x15

Sự miêu tả
^^^^^^^^^^^

Trả về thông tin thời gian từ khi bắt đầu phát lại

Kết quả[0]
^^^^^^^^^

Số khung theo thứ tự giải mã

Kết quả[1]
^^^^^^^^^

Video PTS bit 0:31 theo thứ tự hiển thị

Kết quả[2]
^^^^^^^^^

Video PTS bit 32 theo thứ tự hiển thị

Kết quả[3]
^^^^^^^^^

Các bit SCR 0:31 theo thứ tự hiển thị

Kết quả[4]
^^^^^^^^^

SCR bit 32 theo thứ tự hiển thị



CX2341X_DEC_SET_AUDIO_MODE
~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 22/0x16

Sự miêu tả
^^^^^^^^^^^

Chọn chế độ âm thanh

Thông số[0]
^^^^^^^^

Hành động ở chế độ đơn sắc kép
	0=Âm thanh nổi, 1=Trái, 2=Phải, 3=Mono, 4=Hoán đổi, -1=Không thay đổi

Thông số[1]
^^^^^^^^

Hành động ở chế độ âm thanh nổi:
	0=Âm thanh nổi, 1=Trái, 2=Phải, 3=Mono, 4=Hoán đổi, -1=Không thay đổi



CX2341X_DEC_SET_EVENT_NOTIFICATION
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 23/0x17

Sự miêu tả
^^^^^^^^^^^

Thiết lập chương trình cơ sở để thông báo cho máy chủ về một sự kiện cụ thể.
Đối trọng với API 0xD5

Thông số[0]
^^^^^^^^

Sự kiện:
	- 0=Thay đổi chế độ âm thanh giữa mono, stereo (chung) và kênh đôi.
	- 3=Bộ giải mã đã bắt đầu
	- 4=Không xác định: tắt 10-15 lần mỗi giây trong khi giải mã.
	- 5=Một số sự kiện đồng bộ: tắt một lần trên mỗi khung hình.

Thông số[1]
^^^^^^^^

Thông báo 0=đã tắt, 1=đã bật

Thông số[2]
^^^^^^^^

Bit ngắt

Tham số [3]
^^^^^^^^

Khe cắm hộp thư, -1 nếu không cần hộp thư.



CX2341X_DEC_SET_DISPLAY_BUFFERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 24/0x18

Sự miêu tả
^^^^^^^^^^^

Số lượng bộ đệm hiển thị. Để giải mã tất cả các khung hình trong chế độ phát lại ngược, bạn
phải sử dụng chín bộ đệm.

Thông số[0]
^^^^^^^^

0=sáu bộ đệm, 1=chín bộ đệm



CX2341X_DEC_EXTRACT_VBI
~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 25/0x19

Sự miêu tả
^^^^^^^^^^^

Trích xuất dữ liệu VBI

Thông số[0]
^^^^^^^^

0=trích xuất từ ​​tiện ích mở rộng và dữ liệu người dùng, 1=trích xuất từ ​​các gói riêng tư

Kết quả[0]
^^^^^^^^^

Vị trí bàn VBI

Kết quả[1]
^^^^^^^^^

Kích thước bàn VBI



CX2341X_DEC_SET_DECODER_SOURCE
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 26/0x1A

Sự miêu tả
^^^^^^^^^^^

Chọn nguồn giải mã. Đảm bảo rằng các tham số được truyền cho điều này
API khớp với cài đặt bộ mã hóa.

Thông số[0]
^^^^^^^^

Chế độ: 0=MPEG từ máy chủ, 1=YUV từ bộ mã hóa, 2=YUV từ máy chủ

Thông số[1]
^^^^^^^^

Chiều rộng hình ảnh YUV

Thông số[2]
^^^^^^^^

Chiều cao hình ảnh YUV

Tham số [3]
^^^^^^^^

Bitmap: xem Thông số [0] của API 0xBD



CX2341X_DEC_SET_PREBUFFERING
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Số đếm: 30/0x1E

Sự miêu tả
^^^^^^^^^^^

Bộ đệm trước bộ giải mã, khi được bật lên tới 128KB sẽ được lưu vào bộ đệm cho
luồng <8mpbs hoặc 640KB cho luồng>8mbps

Thông số[0]
^^^^^^^^

0=tắt, 1=bật

PVR350 Bộ giải mã video đăng ký 0x02002800 -> 0x02002B00
-------------------------------------------------------

Tác giả: Ian Armstrong <ian@iarmst.demon.co.uk>

Phiên bản: v0.4

Ngày: 12 tháng 3 năm 2007


Danh sách này đã được thực hiện thông qua thử nghiệm và sai sót. Sẽ có những sai lầm
và những thiếu sót. Một số thanh ghi không có tác dụng rõ ràng nên rất khó để nói điều gì
họ làm như vậy, trong khi những người khác tương tác với nhau hoặc yêu cầu một mức tải nhất định
trình tự. Thiết lập bộ lọc ngang là một ví dụ, với sáu thanh ghi hoạt động
đồng loạt và yêu cầu một trình tự tải nhất định để cấu hình chính xác. các
bảng màu được lập chỉ mục dễ dàng hơn nhiều để thiết lập chỉ với hai thanh ghi, nhưng một lần nữa
nó đòi hỏi một trình tự tải nhất định.

Một số sổ đăng ký rất cầu kỳ về những gì chúng được đặt. Tải ở một giá trị xấu &
bộ giải mã sẽ thất bại. Việc tải lại chương trình cơ sở thường sẽ khôi phục nhưng đôi khi việc thiết lập lại
được yêu cầu. Đối với các thanh ghi chứa thông tin kích thước, việc đặt chúng thành 0 là
nói chung là một ý tưởng tồi. Đối với các thanh ghi điều khiển khác, ví dụ 2878, bạn sẽ chỉ tìm thấy
ra những giá trị nào là xấu khi nó bị treo.

.. code-block:: none

	--------------------------------------------------------------------------------
	2800
	bit 0
		Decoder enable
		0 = disable
		1 = enable
	--------------------------------------------------------------------------------
	2804
	bits 0:31
		Decoder horizontal Y alias register 1
	---------------
	2808
	bits 0:31
		Decoder horizontal Y alias register 2
	---------------
	280C
	bits 0:31
		Decoder horizontal Y alias register 3
	---------------
	2810
	bits 0:31
		Decoder horizontal Y alias register 4
	---------------
	2814
	bits 0:31
		Decoder horizontal Y alias register 5
	---------------
	2818
	bits 0:31
		Decoder horizontal Y alias trigger

	These six registers control the horizontal aliasing filter for the Y plane.
	The first five registers must all be loaded before accessing the trigger
	(2818), as this register actually clocks the data through for the first
	five.

	To correctly program set the filter, this whole procedure must be done 16
	times. The actual register contents are copied from a lookup-table in the
	firmware which contains 4 different filter settings.

	--------------------------------------------------------------------------------
	281C
	bits 0:31
		Decoder horizontal UV alias register 1
	---------------
	2820
	bits 0:31
		Decoder horizontal UV alias register 2
	---------------
	2824
	bits 0:31
		Decoder horizontal UV alias register 3
	---------------
	2828
	bits 0:31
		Decoder horizontal UV alias register 4
	---------------
	282C
	bits 0:31
		Decoder horizontal UV alias register 5
	---------------
	2830
	bits 0:31
		Decoder horizontal UV alias trigger

	These six registers control the horizontal aliasing for the UV plane.
	Operation is the same as the Y filter, with 2830 being the trigger
	register.

	--------------------------------------------------------------------------------
	2834
	bits 0:15
		Decoder Y source width in pixels

	bits 16:31
		Decoder Y destination width in pixels
	---------------
	2838
	bits 0:15
		Decoder UV source width in pixels

	bits 16:31
		Decoder UV destination width in pixels

	NOTE: For both registers, the resulting image must be fully visible on
	screen. If the image exceeds the right edge both the source and destination
	size must be adjusted to reflect the visible portion. For the source width,
	you must take into account the scaling when calculating the new value.
	--------------------------------------------------------------------------------

	283C
	bits 0:31
		Decoder Y horizontal scaling
			Normally = Reg 2854 >> 2
	---------------
	2840
	bits 0:31
		Decoder ?? unknown - horizontal scaling
		Usually 0x00080514
	---------------
	2844
	bits 0:31
		Decoder UV horizontal scaling
		Normally = Reg 2854 >> 2
	---------------
	2848
	bits 0:31
		Decoder ?? unknown - horizontal scaling
		Usually 0x00100514
	---------------
	284C
	bits 0:31
		Decoder ?? unknown - Y plane
		Usually 0x00200020
	---------------
	2850
	bits 0:31
		Decoder ?? unknown - UV plane
		Usually 0x00200020
	---------------
	2854
	bits 0:31
		Decoder 'master' value for horizontal scaling
	---------------
	2858
	bits 0:31
		Decoder ?? unknown
		Usually 0
	---------------
	285C
	bits 0:31
		Decoder ?? unknown
		Normally = Reg 2854 >> 1
	---------------
	2860
	bits 0:31
		Decoder ?? unknown
		Usually 0
	---------------
	2864
	bits 0:31
		Decoder ?? unknown
		Normally = Reg 2854 >> 1
	---------------
	2868
	bits 0:31
		Decoder ?? unknown
		Usually 0

	Most of these registers either control horizontal scaling, or appear linked
	to it in some way. Register 2854 contains the 'master' value & the other
	registers can be calculated from that one. You must also remember to
	correctly set the divider in Reg 2874.

	To enlarge:
		Reg 2854 = (source_width * 0x00200000) / destination_width
		Reg 2874 = No divide

	To reduce from full size down to half size:
		Reg 2854 = (source_width/2 * 0x00200000) / destination width
		Reg 2874 = Divide by 2

	To reduce from half size down to quarter size:
		Reg 2854 = (source_width/4 * 0x00200000) / destination width
		Reg 2874 = Divide by 4

	The result is always rounded up.

	--------------------------------------------------------------------------------
	286C
	bits 0:15
		Decoder horizontal Y buffer offset

	bits 15:31
		Decoder horizontal UV buffer offset

	Offset into the video image buffer. If the offset is gradually incremented,
	the on screen image will move left & wrap around higher up on the right.

	--------------------------------------------------------------------------------
	2870
	bits 0:15
		Decoder horizontal Y output offset

	bits 16:31
		Decoder horizontal UV output offset

	Offsets the actual video output. Controls output alignment of the Y & UV
	planes. The higher the value, the greater the shift to the left. Use
	reg 2890 to move the image right.

	--------------------------------------------------------------------------------
	2874
	bits 0:1
		Decoder horizontal Y output size divider
		00 = No divide
		01 = Divide by 2
		10 = Divide by 3

	bits 4:5
		Decoder horizontal UV output size divider
		00 = No divide
		01 = Divide by 2
		10 = Divide by 3

	bit 8
		Decoder ?? unknown
		0 = Normal
		1 = Affects video output levels

	bit 16
		Decoder ?? unknown
		0 = Normal
		1 = Disable horizontal filter

	--------------------------------------------------------------------------------
	2878
	bit 0
		?? unknown

	bit 1
		osd on/off
		0 = osd off
		1 = osd on

	bit 2
		Decoder + osd video timing
		0 = NTSC
		1 = PAL

	bits 3:4
		?? unknown

	bit 5
		Decoder + osd
		Swaps upper & lower fields

	--------------------------------------------------------------------------------
	287C
	bits 0:10
		Decoder & osd ?? unknown
		Moves entire screen horizontally. Starts at 0x005 with the screen
		shifted heavily to the right. Incrementing in steps of 0x004 will
		gradually shift the screen to the left.

	bits 11:31
		?? unknown

	Normally contents are 0x00101111 (NTSC) or 0x1010111d (PAL)

	--------------------------------------------------------------------------------
	2880  --------    ?? unknown
	2884  --------    ?? unknown
	--------------------------------------------------------------------------------
	2888
	bit 0
		Decoder + osd ?? unknown
		0 = Normal
		1 = Misaligned fields (Correctable through 289C & 28A4)

	bit 4
		?? unknown

	bit 8
		?? unknown

	Warning: Bad values will require a firmware reload to recover.
			Known to be bad are 0x000,0x011,0x100,0x111
	--------------------------------------------------------------------------------
	288C
	bits 0:15
		osd ?? unknown
		Appears to affect the osd position stability. The higher the value the
		more unstable it becomes. Decoder output remains stable.

	bits 16:31
		osd ?? unknown
		Same as bits 0:15

	--------------------------------------------------------------------------------
	2890
	bits 0:11
		Decoder output horizontal offset.

	Horizontal offset moves the video image right. A small left shift is
	possible, but it's better to use reg 2870 for that due to its greater
	range.

	NOTE: Video corruption will occur if video window is shifted off the right
	edge. To avoid this read the notes for 2834 & 2838.
	--------------------------------------------------------------------------------
	2894
	bits 0:23
		Decoder output video surround colour.

	Contains the colour (in yuv) used to fill the screen when the video is
	running in a window.
	--------------------------------------------------------------------------------
	2898
	bits 0:23
		Decoder video window colour
		Contains the colour (in yuv) used to fill the video window when the
		video is turned off.

	bit 24
		Decoder video output
		0 = Video on
		1 = Video off

	bit 28
		Decoder plane order
		0 = Y,UV
		1 = UV,Y

	bit 29
		Decoder second plane byte order
		0 = Normal (UV)
		1 = Swapped (VU)

	In normal usage, the first plane is Y & the second plane is UV. Though the
	order of the planes can be swapped, only the byte order of the second plane
	can be swapped. This isn't much use for the Y plane, but can be useful for
	the UV plane.

	--------------------------------------------------------------------------------
	289C
	bits 0:15
		Decoder vertical field offset 1

	bits 16:31
		Decoder vertical field offset 2

	Controls field output vertical alignment. The higher the number, the lower
	the image on screen. Known starting values are 0x011E0017 (NTSC) &
	0x01500017 (PAL)
	--------------------------------------------------------------------------------
	28A0
	bits 0:15
		Decoder & osd width in pixels

	bits 16:31
		Decoder & osd height in pixels

	All output from the decoder & osd are disabled beyond this area. Decoder
	output will simply go black outside of this region. If the osd tries to
	exceed this area it will become corrupt.
	--------------------------------------------------------------------------------
	28A4
	bits 0:11
		osd left shift.

	Has a range of 0x770->0x7FF. With the exception of 0, any value outside of
	this range corrupts the osd.
	--------------------------------------------------------------------------------
	28A8
	bits 0:15
		osd vertical field offset 1

	bits 16:31
		osd vertical field offset 2

	Controls field output vertical alignment. The higher the number, the lower
	the image on screen. Known starting values are 0x011E0017 (NTSC) &
	0x01500017 (PAL)
	--------------------------------------------------------------------------------
	28AC  --------    ?? unknown
	|
	V
	28BC  --------    ?? unknown
	--------------------------------------------------------------------------------
	28C0
	bit 0
		Current output field
		0 = first field
		1 = second field

	bits 16:31
		Current scanline
		The scanline counts from the top line of the first field
		through to the last line of the second field.
	--------------------------------------------------------------------------------
	28C4  --------    ?? unknown
	|
	V
	28F8  --------    ?? unknown
	--------------------------------------------------------------------------------
	28FC
	bit 0
		?? unknown
		0 = Normal
		1 = Breaks decoder & osd output
	--------------------------------------------------------------------------------
	2900
	bits 0:31
		Decoder vertical Y alias register 1
	---------------
	2904
	bits 0:31
		Decoder vertical Y alias register 2
	---------------
	2908
	bits 0:31
		Decoder vertical Y alias trigger

	These three registers control the vertical aliasing filter for the Y plane.
	Operation is similar to the horizontal Y filter (2804). The only real
	difference is that there are only two registers to set before accessing
	the trigger register (2908). As for the horizontal filter, the values are
	taken from a lookup table in the firmware, and the procedure must be
	repeated 16 times to fully program the filter.
	--------------------------------------------------------------------------------
	290C
	bits 0:31
		Decoder vertical UV alias register 1
	---------------
	2910
	bits 0:31
		Decoder vertical UV alias register 2
	---------------
	2914
	bits 0:31
		Decoder vertical UV alias trigger

	These three registers control the vertical aliasing filter for the UV
	plane. Operation is the same as the Y filter, with 2914 being the trigger.
	--------------------------------------------------------------------------------
	2918
	bits 0:15
		Decoder Y source height in pixels

	bits 16:31
		Decoder Y destination height in pixels
	---------------
	291C
	bits 0:15
		Decoder UV source height in pixels divided by 2

	bits 16:31
		Decoder UV destination height in pixels

	NOTE: For both registers, the resulting image must be fully visible on
	screen. If the image exceeds the bottom edge both the source and
	destination size must be adjusted to reflect the visible portion. For the
	source height, you must take into account the scaling when calculating the
	new value.
	--------------------------------------------------------------------------------
	2920
	bits 0:31
		Decoder Y vertical scaling
		Normally = Reg 2930 >> 2
	---------------
	2924
	bits 0:31
		Decoder Y vertical scaling
		Normally = Reg 2920 + 0x514
	---------------
	2928
	bits 0:31
		Decoder UV vertical scaling
		When enlarging = Reg 2930 >> 2
		When reducing = Reg 2930 >> 3
	---------------
	292C
	bits 0:31
		Decoder UV vertical scaling
		Normally = Reg 2928 + 0x514
	---------------
	2930
	bits 0:31
		Decoder 'master' value for vertical scaling
	---------------
	2934
	bits 0:31
		Decoder ?? unknown - Y vertical scaling
	---------------
	2938
	bits 0:31
		Decoder Y vertical scaling
		Normally = Reg 2930
	---------------
	293C
	bits 0:31
		Decoder ?? unknown - Y vertical scaling
	---------------
	2940
	bits 0:31
		Decoder UV vertical scaling
		When enlarging = Reg 2930 >> 1
		When reducing = Reg 2930
	---------------
	2944
	bits 0:31
		Decoder ?? unknown - UV vertical scaling
	---------------
	2948
	bits 0:31
		Decoder UV vertical scaling
		Normally = Reg 2940
	---------------
	294C
	bits 0:31
		Decoder ?? unknown - UV vertical scaling

	Most of these registers either control vertical scaling, or appear linked
	to it in some way. Register 2930 contains the 'master' value & all other
	registers can be calculated from that one. You must also remember to
	correctly set the divider in Reg 296C

	To enlarge:
		Reg 2930 = (source_height * 0x00200000) / destination_height
		Reg 296C = No divide

	To reduce from full size down to half size:
		Reg 2930 = (source_height/2 * 0x00200000) / destination height
		Reg 296C = Divide by 2

	To reduce from half down to quarter.
		Reg 2930 = (source_height/4 * 0x00200000) / destination height
		Reg 296C = Divide by 4

	--------------------------------------------------------------------------------
	2950
	bits 0:15
		Decoder Y line index into display buffer, first field

	bits 16:31
		Decoder Y vertical line skip, first field
	--------------------------------------------------------------------------------
	2954
	bits 0:15
		Decoder Y line index into display buffer, second field

	bits 16:31
		Decoder Y vertical line skip, second field
	--------------------------------------------------------------------------------
	2958
	bits 0:15
		Decoder UV line index into display buffer, first field

	bits 16:31
		Decoder UV vertical line skip, first field
	--------------------------------------------------------------------------------
	295C
	bits 0:15
		Decoder UV line index into display buffer, second field

	bits 16:31
		Decoder UV vertical line skip, second field
	--------------------------------------------------------------------------------
	2960
	bits 0:15
		Decoder destination height minus 1

	bits 16:31
		Decoder destination height divided by 2
	--------------------------------------------------------------------------------
	2964
	bits 0:15
		Decoder Y vertical offset, second field

	bits 16:31
		Decoder Y vertical offset, first field

	These two registers shift the Y plane up. The higher the number, the
	greater the shift.
	--------------------------------------------------------------------------------
	2968
	bits 0:15
		Decoder UV vertical offset, second field

	bits 16:31
		Decoder UV vertical offset, first field

	These two registers shift the UV plane up. The higher the number, the
	greater the shift.
	--------------------------------------------------------------------------------
	296C
	bits 0:1
		Decoder vertical Y output size divider
		00 = No divide
		01 = Divide by 2
		10 = Divide by 4

	bits 8:9
		Decoder vertical UV output size divider
		00 = No divide
		01 = Divide by 2
		10 = Divide by 4
	--------------------------------------------------------------------------------
	2970
	bit 0
		Decoder ?? unknown
		0 = Normal
		1 = Affect video output levels

	bit 16
		Decoder ?? unknown
		0 = Normal
		1 = Disable vertical filter

	--------------------------------------------------------------------------------
	2974  --------   ?? unknown
	|
	V
	29EF  --------   ?? unknown
	--------------------------------------------------------------------------------
	2A00
	bits 0:2
		osd colour mode
		000 = 8 bit indexed
		001 = 16 bit (565)
		010 = 15 bit (555)
		011 = 12 bit (444)
		100 = 32 bit (8888)

	bits 4:5
		osd display bpp
		01 = 8 bit
		10 = 16 bit
		11 = 32 bit

	bit 8
		osd global alpha
		0 = Off
		1 = On

	bit 9
		osd local alpha
		0 = Off
		1 = On

	bit 10
		osd colour key
		0 = Off
		1 = On

	bit 11
		osd ?? unknown
		Must be 1

	bit 13
		osd colour space
		0 = ARGB
		1 = AYVU

	bits 16:31
		osd ?? unknown
		Must be 0x001B (some kind of buffer pointer ?)

	When the bits-per-pixel is set to 8, the colour mode is ignored and
	assumed to be 8 bit indexed. For 16 & 32 bits-per-pixel the colour depth
	is honoured, and when using a colour depth that requires fewer bytes than
	allocated the extra bytes are used as padding. So for a 32 bpp with 8 bit
	index colour, there are 3 padding bytes per pixel. It's also possible to
	select 16bpp with a 32 bit colour mode. This results in the pixel width
	being doubled, but the color key will not work as expected in this mode.

	Colour key is as it suggests. You designate a colour which will become
	completely transparent. When using 565, 555 or 444 colour modes, the
	colour key is always 16 bits wide. The colour to key on is set in Reg 2A18.

	Local alpha works differently depending on the colour mode. For 32bpp & 8
	bit indexed, local alpha is a per-pixel 256 step transparency, with 0 being
	transparent and 255 being solid. For the 16bpp modes 555 & 444, the unused
	bit(s) act as a simple transparency switch, with 0 being solid & 1 being
	fully transparent. There is no local alpha support for 16bit 565.

	Global alpha is a 256 step transparency that applies to the entire osd,
	with 0 being transparent & 255 being solid.

	It's possible to combine colour key, local alpha & global alpha.
	--------------------------------------------------------------------------------
	2A04
	bits 0:15
		osd x coord for left edge

	bits 16:31
		osd y coord for top edge
	---------------
	2A08
	bits 0:15
		osd x coord for right edge

	bits 16:31
		osd y coord for bottom edge

	For both registers, (0,0) = top left corner of the display area. These
	registers do not control the osd size, only where it's positioned & how
	much is visible. The visible osd area cannot exceed the right edge of the
	display, otherwise the osd will become corrupt. See reg 2A10 for
	setting osd width.
	--------------------------------------------------------------------------------
	2A0C
	bits 0:31
		osd buffer index

	An index into the osd buffer. Slowly incrementing this moves the osd left,
	wrapping around onto the right edge
	--------------------------------------------------------------------------------
	2A10
	bits 0:11
		osd buffer 32 bit word width

	Contains the width of the osd measured in 32 bit words. This means that all
	colour modes are restricted to a byte width which is divisible by 4.
	--------------------------------------------------------------------------------
	2A14
	bits 0:15
		osd height in pixels

	bits 16:32
		osd line index into buffer
		osd will start displaying from this line.
	--------------------------------------------------------------------------------
	2A18
	bits 0:31
		osd colour key

	Contains the colour value which will be transparent.
	--------------------------------------------------------------------------------
	2A1C
	bits 0:7
		osd global alpha

	Contains the global alpha value (equiv ivtvfbctl --alpha XX)
	--------------------------------------------------------------------------------
	2A20  --------    ?? unknown
	|
	V
	2A2C  --------    ?? unknown
	--------------------------------------------------------------------------------
	2A30
	bits 0:7
		osd colour to change in indexed palette
	---------------
	2A34
	bits 0:31
		osd colour for indexed palette

	To set the new palette, first load the index of the colour to change into
	2A30, then load the new colour into 2A34. The full palette is 256 colours,
	so the index range is 0x00-0xFF
	--------------------------------------------------------------------------------
	2A38  --------    ?? unknown
	2A3C  --------    ?? unknown
	--------------------------------------------------------------------------------
	2A40
	bits 0:31
		osd ?? unknown

	Affects overall brightness, wrapping around to black
	--------------------------------------------------------------------------------
	2A44
	bits 0:31
		osd ?? unknown

	Green tint
	--------------------------------------------------------------------------------
	2A48
	bits 0:31
		osd ?? unknown

	Red tint
	--------------------------------------------------------------------------------
	2A4C
	bits 0:31
		osd ?? unknown

	Affects overall brightness, wrapping around to black
	--------------------------------------------------------------------------------
	2A50
	bits 0:31
		osd ?? unknown

	Colour shift
	--------------------------------------------------------------------------------
	2A54
	bits 0:31
		osd ?? unknown

	Colour shift
	--------------------------------------------------------------------------------
	2A58  --------    ?? unknown
	|
	V
	2AFC  --------    ?? unknown
	--------------------------------------------------------------------------------
	2B00
	bit 0
		osd filter control
		0 = filter off
		1 = filter on

	bits 1:4
		osd ?? unknown

	--------------------------------------------------------------------------------

Động cơ cx231xx DMA
----------------------


Trang này mô tả các cấu trúc và quy trình được sử dụng bởi cx2341x DMA
động cơ.

Giới thiệu
~~~~~~~~~~~~

Giao diện cx2341x PCI có khả năng busmaster. Điều này có nghĩa là nó có DMA
công cụ truyền tải hiệu quả khối lượng lớn dữ liệu giữa thẻ và thiết bị chính
bộ nhớ mà không cần sự trợ giúp từ CPU. Giống như hầu hết phần cứng, nó phải hoạt động
trên bộ nhớ vật lý liền kề. Điều này khó có được với số lượng lớn
trên các máy bộ nhớ ảo.

Do đó, nó cũng hỗ trợ một kỹ thuật gọi là "phân tán-thu thập". Thẻ có thể
chuyển nhiều bộ đệm trong một thao tác. Thay vì phân bổ một lượng lớn
bộ đệm liền kề, trình điều khiển có thể phân bổ một số bộ đệm nhỏ hơn.

Trong thực tế, tôi thấy số tiền chuyển trung bình là khoảng 80K, nhưng số tiền chuyển
trên 128K không phải là hiếm, đặc biệt là khi khởi động. Con số 128K là
quan trọng, vì đó là khối lớn nhất mà kernel thường có thể
phân bổ. Mặc dù vậy, các khối 128K vẫn khó có được, vì vậy người viết trình điều khiển
urged to choose a smaller block size and learn the scatter-gather technique.

Hộp thư #10 được dành riêng cho thông tin chuyển DMA.

Lưu ý: phần cứng yêu cầu dữ liệu endian nhỏ ('định dạng intel').

Chảy
~~~~

Phần này mô tả tổng quát thứ tự các sự kiện khi xử lý DMA
chuyển khoản. Thông tin chi tiết sau phần này.

- Card gây ngắt Encoding.
- Trình điều khiển đọc kiểu truyền, offset và kích thước từ Mailbox #10.
- Trình điều khiển xây dựng mảng thu thập phân tán từ bộ đệm dma đủ trống
  để che kích thước.
- Trình điều khiển lên lịch chuyển DMA thông qua cuộc gọi ScheduleDMAtoHost API.
- Thẻ tăng ngắt DMA Complete.
- Trình điều khiển kiểm tra thanh ghi trạng thái DMA xem có lỗi gì không.
- Trình điều khiển xử lý hậu kỳ các bộ đệm mới được chuyển.

NOTE! Có thể các ngắt Bộ mã hóa và DMA Complete được nâng lên
đồng thời. (Kết thúc cái cuối cùng, bắt đầu cái tiếp theo, v.v.)

Hộp Thư #10
~~~~~~~~~~~

Các trường Cờ, Lệnh, Giá trị trả về và Thời gian chờ bị bỏ qua.

- Tên: Hộp thư #10
- Kết quả[0]: Loại: 0: MPEG.
- Kết quả[1]: Offset: Vị trí tương ứng với không gian bộ nhớ của thẻ.
- Kết quả[2]: Size: Chính xác số byte cần truyền.

Suy đoán của tôi là vì StartCapture API có kiểu chụp "RAW"
có sẵn, trường loại sẽ có các giá trị khác tương ứng với YUV
và dữ liệu PCM.

Mảng phân tán-thu thập
~~~~~~~~~~~~~~~~~~~~

Mảng phân tán là một khối bộ nhớ được phân bổ liên tục
cho thẻ biết nguồn và đích của từng khối dữ liệu cần truyền.
"Địa chỉ" thẻ được lấy từ phần bù do Hộp thư #10 cung cấp. Máy chủ
địa chỉ là vị trí bộ nhớ vật lý của bộ đệm DMA đích.

Mỗi phần tử mảng S-G là một cấu trúc gồm ba từ 32 bit. Từ đầu tiên là
địa chỉ nguồn, địa chỉ thứ hai là địa chỉ đích. Cả hai đều đảm nhận
toàn bộ 32 bit. 18 bit thấp nhất của từ thứ ba là byte truyền
đếm. Bit cao của từ thứ ba là cờ "cuối cùng". Lá cờ cuối cùng cho biết
thẻ để tăng ngắt DMA_DONE. Từ kinh nghiệm cá nhân khó khăn, nếu
bạn quên đặt bit này, thẻ vẫn "hoạt động" nhưng luồng sẽ
rất có thể bị hỏng.

Số lần chuyển phải là bội số của 256. Do đó, trình điều khiển sẽ cần
để theo dõi lượng dữ liệu trong bộ đệm đích hợp lệ và xử lý nó
tương ứng.

Phần tử mảng:

- Địa chỉ nguồn 32-bit
- Địa chỉ đích 32-bit
- 14-bit dự trữ (bit cao là cờ cuối cùng)
- Số byte 18 bit

Trạng thái chuyển DMA
~~~~~~~~~~~~~~~~~~~

Đăng ký 0x0004 giữ Trạng thái chuyển DMA:

- bit 0: đọc xong
- bit 1: ghi xong
- bit 2: Lỗi đọc DMA
- bit 3: Lỗi ghi DMA
- bit 4: Lỗi mảng Scatter-Gather