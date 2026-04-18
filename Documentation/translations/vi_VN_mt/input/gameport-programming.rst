.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/gameport-programming.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Lập trình driver gameport
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một gameport cổ điển cơ bản
~~~~~~~~~~~~~~~~~~~~~~~~

Nếu cổng trò chơi không cung cấp nhiều hơn chức năng inb()/outb(),
mã cần thiết để đăng ký nó với trình điều khiển cần điều khiển rất đơn giản ::

cấu trúc cổng gameport gameport;

gameport.io = MY_IO_ADDRESS;
	gameport_register_port(&gameport);

Đảm bảo struct gameport được khởi tạo thành 0 trong tất cả các trường khác. các
Mã chung của gameport sẽ lo phần còn lại.

Nếu phần cứng của bạn hỗ trợ nhiều địa chỉ io và trình điều khiển của bạn có thể
chọn cái nào để lập trình phần cứng, bắt đầu từ cái kỳ lạ hơn
địa chỉ được ưu tiên hơn vì khả năng xung đột với tiêu chuẩn
Địa chỉ 0x201 nhỏ hơn.

Ví dụ. nếu trình điều khiển của bạn hỗ trợ các địa chỉ 0x200, 0x208, 0x210 và 0x218 thì
0x218 sẽ là địa chỉ được lựa chọn đầu tiên.

Nếu phần cứng của bạn hỗ trợ địa chỉ gameport không được ánh xạ tới ISA io
khoảng trống (trên 0x1000), hãy sử dụng khoảng trắng đó và không ánh xạ gương ISA.

Ngoài ra, luôn luôn request_khu vực() trên toàn bộ không gian io bị chiếm giữ bởi
gameport. Mặc dù chỉ có một ioport thực sự được sử dụng nhưng gameport thường
chiếm từ một đến mười sáu địa chỉ trong không gian io.

Ngoài ra, vui lòng xem xét việc bật cổng trò chơi trên thẻ trong ->open()
gọi lại nếu io được ánh xạ tới không gian ISA - theo cách này, nó sẽ chiếm io
không gian chỉ khi một cái gì đó thực sự đang sử dụng nó. Vô hiệu hóa nó một lần nữa trong
->close() gọi lại. Bạn cũng có thể chọn địa chỉ io trong ->open()
gọi lại, để nó không bị lỗi nếu một số địa chỉ có thể có
đã bị chiếm giữ bởi các gameport khác.

Cổng trò chơi được ánh xạ theo bộ nhớ
~~~~~~~~~~~~~~~~~~~~~~

Khi một gameport có thể được truy cập thông qua MMIO, cách này được ưu tiên hơn, bởi vì
nó nhanh hơn, cho phép đọc nhiều hơn mỗi giây. Đăng ký một gameport như vậy
không dễ như IO cơ bản, nhưng không quá phức tạp ::

cấu trúc cổng gameport gameport;

void my_trigger(struct gameport *gameport)
	{
		my_mmio = 0xff;
	}

unsigned char my_read(struct gameport *gameport)
	{
		trả lại my_mmio;
	}

gameport.read = my_read;
	gameport.trigger = my_trigger;
	gameport_register_port(&gameport);

.. _gameport_pgm_cooked_mode:

Cổng trò chơi chế độ nấu chín
~~~~~~~~~~~~~~~~~~~~

Có những gameport có thể báo cáo các giá trị trục dưới dạng số, điều đó có nghĩa là
người lái xe không cần phải đo chúng theo cách cũ - ADC được tích hợp sẵn
cổng trò chơi. Để đăng ký một gameport nấu chín::

cấu trúc cổng gameport gameport;

int my_cook_read(struct gameport *gameport, int *axes, int *buttons)
	{
		int tôi;

vì (i = 0; i < 4; i++)
			trục[i] = my_mmio[i];
		nút [0] = my_mmio [4];
	}

int my_open(struct gameport *gameport, chế độ int)
	{
		return -(chế độ != GAMEPORT_MODE_COOKED);
	}

gameport.cook_read = my_cook_read;
	gameport.open = my_open;
	gameport.fuzz = 8;
	gameport_register_port(&gameport);

Điều khó hiểu duy nhất ở đây là giá trị fuzz. Tốt nhất được xác định bởi
thử nghiệm, đó là lượng nhiễu trong dữ liệu ADC. hoàn hảo
gameports có thể đặt giá trị này thành 0, phổ biến nhất có fuzz từ 8 đến 32.
Xem analog.c và input.c để biết cách xử lý fuzz - giá trị fuzz xác định
kích thước của cửa sổ bộ lọc gaussian được sử dụng để loại bỏ nhiễu
trong dữ liệu.

Cổng game phức tạp hơn
~~~~~~~~~~~~~~~~~~~~~~

Gameports có thể hỗ trợ cả chế độ sống và nấu chín. Trong trường hợp đó kết hợp một trong hai
ví dụ 1+2 hoặc 1+3. Gameport có thể hỗ trợ hiệu chỉnh nội bộ - xem bên dưới,
và cả Lightning.c và analog.c về cách hoạt động. Nếu trình điều khiển của bạn hỗ trợ
nhiều phiên bản gameport cùng một lúc, hãy sử dụng thành viên ->private của
cấu trúc gameport để trỏ đến dữ liệu của bạn.

Hủy đăng ký một gameport
~~~~~~~~~~~~~~~~~~~~~~~~

Đơn giản::

gameport_unregister_port(&gameport);

Cấu trúc cổng game
~~~~~~~~~~~~~~~~~~~~~~

::

cấu trúc cổng game {

vô hiệu *port_data;

Một con trỏ riêng để sử dụng miễn phí trong trình điều khiển gameport. (Không phải cần điều khiển
tài xế!)

::

tên char[32];

Tên trình điều khiển do trình điều khiển gọi gameport_set_name() đặt. Thông tin
mục đích duy nhất.

::

char Phys[32];

Tên/mô tả vật lý của gameport do trình điều khiển gọi gameport_set_phys() đặt.
Chỉ nhằm mục đích thông tin.

::

int io;

Địa chỉ I/O để sử dụng với chế độ thô. Bạn phải đặt cái này hoặc ->read()
đến một giá trị nào đó nếu gameport của bạn hỗ trợ chế độ thô.

::

tốc độ int;

Tốc độ ở chế độ thô của gameport đọc hàng nghìn lần đọc mỗi giây.

::

int lông tơ;

Nếu cổng trò chơi hỗ trợ chế độ nấu chín, giá trị này phải được đặt thành giá trị
thể hiện mức độ nhiễu trong dữ liệu. Xem
ZZ0000ZZ.

::

khoảng trống (ZZ0000ZZ);

Cò súng. Chức năng này sẽ kích hoạt oneshots ns558. Nếu được đặt thành NULL,
outb(0xff, io) sẽ được sử dụng.

::

ký tự không dấu (ZZ0000ZZ);

Đọc các nút và bit oneshot ns558. Nếu được đặt thành NULL, inb(io) sẽ là
được sử dụng thay thế.

::

int (ZZ0000ZZ, int *axes, int *buttons);

Nếu gameport hỗ trợ chế độ nấu chín, nó sẽ trỏ tới chế độ nấu chín của nó.
chức năng đọc. Nó sẽ lấp đầy các trục [0..3] bằng bốn giá trị của trục cần điều khiển
và các nút [0] với bốn bit đại diện cho các nút.

::

int (ZZ0000ZZ, int *axes, int *max);

Chức năng hiệu chỉnh phần cứng ADC. Khi được gọi, trục [0..3] phải là
được người gọi điền sẵn dữ liệu đã nấu, max[0..3] phải được điền trước bằng
mức tối đa dự kiến cho mỗi trục. Hàm calibrate() sẽ thiết lập
độ nhạy của phần cứng ADC sao cho mức tối đa phù hợp với phạm vi của nó và
tính toán lại các giá trị trục [] để phù hợp với độ nhạy mới hoặc đọc lại chúng từ
phần cứng để chúng đưa ra các giá trị hợp lệ.

::

int (ZZ0000ZZ, chế độ int);

Open() phục vụ hai mục đích. Đầu tiên, trình điều khiển sẽ mở cổng ở dạng thô hoặc
ở chế độ nấu chín, hàm gọi lại open() có thể quyết định chế độ nào được hỗ trợ.
Thứ hai, việc phân bổ nguồn lực có thể xảy ra ở đây. Cổng cũng có thể được kích hoạt
ở đây. Trước lệnh gọi này, các trường khác của cấu trúc gameport (cụ thể là io
member) không cần phải hợp lệ.

::

khoảng trống (ZZ0000ZZ);

Close() sẽ giải phóng các tài nguyên được cấp phát bởi open, có thể vô hiệu hóa
gameport.

::

cấu trúc bộ đếm thời gian_list thăm dò_timer;
	unsign int poll_interval;     /* tính bằng mili giây */
	spinlock_t hẹn giờ_lock;
	unsign int poll_cnt;
	khoảng trống (ZZ0000ZZ);
	cấu trúc gameport *parent, *child;
	cấu trúc gameport_driver *drv;
	cấu trúc mutex drv_mutex;		/* bảo vệ serio->drv để các thuộc tính có thể ghim driver */
	nhà phát triển thiết bị cấu trúc;
	nút cấu trúc list_head;

Để sử dụng nội bộ bởi lớp gameport.

::

    };

Thưởng thức!
