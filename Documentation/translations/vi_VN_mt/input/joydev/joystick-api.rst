.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/joydev/joystick-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _joystick-api:

=======================
Giao diện lập trình
=======================

:Tác giả: Ragnar Hojland Espinosa <ragnar@macula.net> - 7 tháng 8 năm 1998

Giới thiệu
============

.. important::
   This document describes legacy ``js`` interface. Newer clients are
   encouraged to switch to the generic event (``evdev``) interface.

Trình điều khiển 1.0 sử dụng cách tiếp cận mới, dựa trên sự kiện cho trình điều khiển cần điều khiển.
Thay vì chương trình người dùng thăm dò các giá trị cần điều khiển, cần điều khiển
trình điều khiển hiện chỉ báo cáo bất kỳ thay đổi nào về trạng thái của nó. Xem cần điều khiển-api.txt,
joystick.h và jstest.c được bao gồm trong gói cần điều khiển để biết thêm
thông tin. Thiết bị cần điều khiển có thể được sử dụng để chặn hoặc
chế độ không chặn và hỗ trợ các cuộc gọi select().

Để tương thích ngược, giao diện cũ (v0.x) vẫn được bao gồm.
Mọi lệnh gọi tới trình điều khiển cần điều khiển sử dụng giao diện cũ sẽ trả về giá trị
tương thích với giao diện cũ. Giao diện này vẫn còn hạn chế
thành 2 trục và các ứng dụng sử dụng nó thường chỉ giải mã được 2 nút, mặc dù
tài xế cung cấp tới 32.

Khởi tạo
==============

Mở thiết bị cần điều khiển theo ngữ nghĩa thông thường (nghĩa là mở).
Vì trình điều khiển hiện báo cáo các sự kiện thay vì thăm dò các thay đổi,
ngay sau khi mở nó sẽ đưa ra một loạt các sự kiện tổng hợp
(JS_EVENT_INIT) mà bạn có thể đọc để biết trạng thái ban đầu của
cần điều khiển.

Mặc định máy mở ở chế độ chặn::

int fd = open ("/dev/input/js0", O_RDONLY);


Đọc sự kiện
=============

::

cấu trúc js_event e;
	đọc (fd, &e, sizeof(e));

nơi js_event được định nghĩa là::

cấu trúc js_event {
		__u32 giờ;     /*dấu thời gian sự kiện tính bằng mili giây */
		giá trị __s16;    /*giá trị*/
		__u8 loại;      /*loại sự kiện */
		__u8 số;    /* trục/số nút */
	};

Nếu đọc thành công, nó sẽ trả về sizeof(e), trừ khi bạn muốn đọc
nhiều hơn một sự kiện cho mỗi lần đọc như được mô tả trong phần 3.1.


js_event.type
-------------

Các giá trị có thể có của ZZ0000ZZ là::

#define JS_EVENT_BUTTON 0x01 /* nhấn/nhả nút */
	#define JS_EVENT_AXIS 0x02 /* cần điều khiển đã di chuyển */
	#define JS_EVENT_INIT 0x80 /* trạng thái ban đầu của thiết bị */

Như đã nói ở trên driver sẽ ra tổng hợp JS_EVENT_INIT ORed
sự kiện mở. Nghĩa là, nếu nó đang phát hành một sự kiện INIT BUTTON,
giá trị loại hiện tại sẽ là::

kiểu int = JS_EVENT_BUTTON | JS_EVENT_INIT;	/* 0x81 */

Nếu bạn chọn không phân biệt giữa các sự kiện tổng hợp hoặc thực tế
bạn có thể tắt các bit JS_EVENT_INIT ::

gõ &= ~JS_EVENT_INIT;				/* 0x01 */


js_event.number
---------------

Các giá trị của ZZ0000ZZ tương ứng với trục hoặc nút
đã tạo ra sự kiện. Lưu ý rằng chúng mang cách đánh số riêng biệt (đó là
nghĩa là bạn có cả trục 0 và nút 0). Nói chung là,

================ =======
	Số trục
        ================ =======
	Trục thứ nhất X 0
	Trục thứ nhất Y 1
	Trục thứ 2 X 2
	Trục thứ 2 Y 3
	...and so on
        =============== =======

Mũ thay đổi từ loại cần điều khiển này sang loại cần điều khiển khác. Một số có thể được di chuyển trong 8
chỉ đường, một số chỉ có hướng 4. Tuy nhiên, người lái xe luôn báo đội mũ là hai
trục độc lập, ngay cả khi phần cứng không cho phép chuyển động độc lập.


js_event.value
--------------

Đối với một trục, ZZ0000ZZ là số nguyên có dấu nằm trong khoảng từ -32767 đến +32767
đại diện cho vị trí của cần điều khiển dọc theo trục đó. Nếu bạn
không đọc số 0 khi cần điều khiển là ZZ0001ZZ hoặc nếu nó không trải rộng trên
toàn dải, bạn nên hiệu chỉnh lại nó (ví dụ: bằng jscal).

Đối với một nút, ZZ0000ZZ đối với sự kiện nhấn nút là 1 và đối với sự kiện nhả nút
sự kiện nút là 0.

Mặc dù điều này ::

nếu (js_event.type == JS_EVENT_BUTTON) {
		nút_state ^= (1 << js_event.number);
	}

có thể hoạt động tốt nếu bạn xử lý riêng các sự kiện JS_EVENT_INIT,

::

if ((js_event.type & ~JS_EVENT_INIT) == JS_EVENT_BUTTON) {
		nếu (js_event.value)
			nút_state |= (1 << js_event.number);
		khác
			nút_state &= ~(1 << js_event.number);
	}

an toàn hơn nhiều vì không thể mất đồng bộ với trình điều khiển. Như bạn muốn
phải viết một trình xử lý riêng cho các sự kiện JS_EVENT_INIT trong lần đầu tiên
đoạn trích, đoạn này cuối cùng sẽ ngắn hơn.


js_event.time
-------------

Thời gian một sự kiện được tạo được lưu trữ trong ZZ0000ZZ. Đó là một thời gian
tính bằng mili giây kể từ ... à, kể từ một thời điểm nào đó trong quá khứ.  Điều này làm giảm bớt sự
nhiệm vụ phát hiện nhấp đúp, tìm hiểu xem chuyển động của trục và nút
máy ép xảy ra cùng lúc và tương tự.


Đọc
=======

Nếu bạn mở thiết bị ở chế độ chặn, quá trình đọc sẽ bị chặn (nghĩa là
chờ) mãi mãi cho đến khi một sự kiện được tạo và đọc hiệu quả. Ở đó
là hai lựa chọn thay thế nếu bạn không đủ khả năng để chờ đợi mãi (nghĩa là
công nhận là lâu lắm rồi ;)

a) sử dụng select để đợi cho đến khi có dữ liệu được đọc trên fd hoặc
	   cho đến khi hết thời gian. Có một ví dụ hay về select(2)
	   trang người đàn ông.

b) mở thiết bị ở chế độ không chặn (O_NONBLOCK)


O_NONBLOCK
----------

Nếu đọc trả về -1 khi đọc ở chế độ O_NONBLOCK thì đây không phải là
nhất thiết phải là lỗi "thực sự" (kiểm tra errno(3)); nó chỉ có thể có nghĩa là ở đó
không có sự kiện nào đang chờ đọc trên hàng đợi trình điều khiển. Bạn nên đọc
tất cả các sự kiện trong hàng đợi (nghĩa là cho đến khi bạn nhận được -1).

Ví dụ,

::

trong khi (1) {
		while (đọc (fd, &e, sizeof(e)) > 0) {
			quá trình_event (e);
		}
		/* EAGAIN được trả về khi hàng đợi trống */
		nếu (errno != EAGAIN) {
			/*lỗi*/
		}
		/* làm điều gì đó thú vị với các sự kiện đã được xử lý */
	}

Một lý do để làm trống hàng đợi là nếu nó đầy bạn sẽ bắt đầu
sự kiện bị thiếu vì hàng đợi là hữu hạn và các sự kiện cũ hơn sẽ nhận được
bị ghi đè.

Lý do khác là bạn muốn biết tất cả những gì đã xảy ra chứ không phải
trì hoãn việc xử lý cho đến sau này.

Tại sao hàng đợi có thể đầy? Bởi vì bạn không làm trống hàng đợi như
được đề cập hoặc vì quá nhiều thời gian trôi qua từ lần đọc này sang lần đọc khác
và có quá nhiều sự kiện cần lưu trữ trong hàng đợi được tạo ra. Lưu ý rằng
tải hệ thống cao có thể góp phần tăng thêm dung lượng cho những lần đọc đó.

Nếu thời gian giữa các lần đọc đủ để lấp đầy hàng đợi và làm mất một sự kiện,
trình điều khiển sẽ chuyển sang chế độ khởi động và lần sau bạn đọc nó,
các sự kiện tổng hợp (JS_EVENT_INIT) sẽ được tạo để thông báo cho bạn về
trạng thái thực tế của cần điều khiển.


.. note::

 As of version 1.2.8, the queue is circular and able to hold 64
 events. You can increment this size bumping up JS_BUFF_SIZE in
 joystick.h and recompiling the driver.


Trong đoạn mã trên, bạn cũng có thể muốn đọc nhiều sự kiện
tại một thời điểm bằng cách sử dụng chức năng đọc (2) điển hình. Vì điều đó, bạn sẽ
thay thế phần đọc ở trên bằng một cái gì đó như ::

struct js_event mybuffer[0xff];
	int i = đọc (fd, mybuffer, sizeof(mybuffer));

Trong trường hợp này, read sẽ trả về -1 nếu hàng đợi trống hoặc một số
giá trị khác trong đó số lượng sự kiện được đọc sẽ là i /
sizeof(js_event) Một lần nữa, nếu bộ đệm đã đầy, bạn nên
xử lý các sự kiện và tiếp tục đọc nó cho đến khi bạn làm trống hàng đợi trình điều khiển.


IOCTL
======

Trình điều khiển cần điều khiển xác định các thao tác ioctl(2) sau::

/*hàm đối số thứ 3 */
	#define JSIOCGAXES /* lấy số trục char */
	#define JSIOCGBUTTONS /* lấy số nút char */
	#define JSIOCGVERSION /* lấy phiên bản trình điều khiển int */
	#define JSIOCGNAME(len) /* lấy chuỗi ký tự định danh */
	#define JSIOCSCORR /* đặt giá trị hiệu chỉnh &js_corr */
	#define JSIOCGCORR /* nhận giá trị hiệu chỉnh &js_corr */

Ví dụ: để đọc số trục::

số char_of_axes;
	ioctl (fd, JSIOCGAXES, &number_of_axes);


JSIOGCVERSION
-------------

JSIOGCVERSION là một cách tốt để kiểm tra thời gian chạy xem
trình điều khiển là 1.0+ và hỗ trợ giao diện sự kiện. Nếu không,
IOCTL sẽ thất bại. Để đưa ra quyết định tại thời điểm biên dịch, bạn có thể kiểm tra
Biểu tượng JS_VERSION::

#ifdef JS_VERSION
	#if JS_VERSION > 0xsomething


JSIOCGNAME
----------

JSIOCGNAME(len) cho phép bạn lấy chuỗi tên của cần điều khiển - tương tự
như đang được in lúc khởi động. Đối số 'len' là độ dài của
bộ đệm được cung cấp bởi ứng dụng yêu cầu tên. Nó được sử dụng để tránh
có thể bị tràn nếu tên quá dài::

tên char[128];
	if (ioctl(fd, JSIOCGNAME(sizeof(name)), name) < 0)
		strscpy(name, "Unknown", sizeof(name));
	printf("Tên: %s\n", tên);


JSIOC[SG]CORR
-------------

Để sử dụng trên JSIOC[SG]CORR, tôi khuyên bạn nên xem xét jscal.c Chúng là
không cần thiết trong chương trình thông thường, chỉ cần trong phần mềm hiệu chỉnh cần điều khiển
chẳng hạn như jscal hoặc kcmjoy. Các IOCTL và loại dữ liệu này không được xem xét
nằm trong phần ổn định của API và do đó có thể thay đổi mà không cần
cảnh báo trong các phiên bản tiếp theo của trình điều khiển.

Cả JSIOCSCORR và JSIOCGCORR đều mong đợi &js_corr có thể giữ được
thông tin cho tất cả các trục. Nghĩa là, struct js_corr corr[MAX_AXIS];

struct js_corr được định nghĩa là::

cấu trúc js_corr {
		__s32 coef[8];
		__u16 tiền;
		__u16 loại;
	};

và ZZ0000ZZ::

#define JS_CORR_NONE 0x00 /* trả về giá trị thô */
	#define JS_CORR_BROKEN 0x01 /* đường gãy */


Khả năng tương thích ngược
======================

Trình điều khiển cần điều khiển 0.x API khá hạn chế và việc sử dụng nó không được dùng nữa.
Tuy nhiên, trình điều khiển cung cấp khả năng tương thích ngược. Dưới đây là tóm tắt nhanh::

cấu trúc JS_DATA_TYPE js;
	trong khi (1) {
		if (đọc (fd, &js, JS_RETURN) != JS_RETURN) {
			/*lỗi*/
		}
		ngủ (1000);
	}

Như bạn có thể thấy từ ví dụ, kết quả đọc sẽ trả về ngay lập tức,
với trạng thái thực tế của cần điều khiển::

cấu trúc JS_DATA_TYPE {
		nút int;    /*trạng thái nút ngay lập tức */
		int x;          /*giá trị trục x tức thời */
		int y;          /*giá trị trục y tức thời */
	};

và JS_RETURN được định nghĩa là::

Kích thước #define JS_RETURN(struct JS_DATA_TYPE)

Để kiểm tra trạng thái của các nút,

::

first_button_state = js.buttons & 1;
	giây_button_state = js.buttons & 2;

Các giá trị trục không có phạm vi xác định trong trình điều khiển 0.x gốc,
ngoại trừ các giá trị không âm. Trình điều khiển 1.2.8+ sử dụng
phạm vi cố định để báo cáo các giá trị, 1 là mức tối thiểu, 128 là
trung tâm và giá trị tối đa là 255.

Trình điều khiển v0.8.0.2 cũng có giao diện cho 'cần điều khiển kỹ thuật số', (bây giờ
được gọi là cần điều khiển Đa hệ thống trong trình điều khiển này), trong /dev/djsX. Người lái xe này
không cố gắng tương thích với giao diện đó.


Ghi chú cuối cùng
===========

::

____/|	Bình luận, bổ sung và sửa chữa đặc biệt đều được chào đón.
  \ o.O|	Tài liệu hợp lệ cho ít nhất phiên bản 1.2.8 của cần điều khiển
   =(_)= driver và như thường lệ, nguồn tài liệu cơ bản là
     Bạn có thể "Sử dụng Nguồn Luke" hoặc, khi thuận tiện, Vojtech;)
