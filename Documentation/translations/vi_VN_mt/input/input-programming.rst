.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/input-programming.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Tạo trình điều khiển thiết bị đầu vào
=====================================

Ví dụ đơn giản nhất
~~~~~~~~~~~~~~~~~~~~

Sau đây là một ví dụ rất đơn giản về trình điều khiển thiết bị đầu vào. Thiết bị có
chỉ cần một nút và nút này có thể truy cập được tại cổng i/o BUTTON_PORT. Khi nào
nhấn hoặc nhả BUTTON_IRQ sẽ xảy ra. Trình điều khiển có thể trông giống như::

#include <linux/input.h>
    #include <linux/module.h>
    #include <linux/init.h>

#include <asm/irq.h>
    #include <asm/io.h>

cấu trúc tĩnh input_dev *button_dev;

irqreturn_t tĩnh nút_interrupt(int irq, void *dummy)
    {
	    input_report_key(button_dev, BTN_0, inb(BUTTON_PORT) & 1);
	    input_sync(button_dev);
	    trả lại IRQ_HANDLED;
    }

int tĩnh __init nút_init(void)
    {
	    lỗi int;

if (request_irq(BUTTON_IRQ, Button_interrupt, 0, "nút", NULL)) {
		    printk(KERN_ERR "button.c: Không thể phân bổ irq %d\n", nút_irq);
		    trả về -EBUSY;
	    }

nút_dev = input_allocate_device();
	    nếu (!button_dev) {
		    printk(KERN_ERR "button.c: Không đủ bộ nhớ\n");
		    lỗi = -ENOMEM;
		    đi tới err_free_irq;
	    }

nút_dev->evbit[0] = BIT_MASK(EV_KEY);
	    nút_dev->keybit[BIT_WORD(BTN_0)] = BIT_MASK(BTN_0);

lỗi = input_register_device(button_dev);
	    nếu (lỗi) {
		    printk(KERN_ERR "button.c: Không đăng ký được thiết bị\n");
		    đi tới err_free_dev;
	    }

trả về 0;

err_free_dev:
	    input_free_device(button_dev);
    err_free_irq:
	    free_irq(BUTTON_IRQ, Button_interrupt);
	    lỗi trả về;
    }

khoảng trống tĩnh __nút thoát_exit(void)
    {
	    input_unregister_device(button_dev);
	    free_irq(BUTTON_IRQ, Button_interrupt);
    }

module_init(button_init);
    module_exit(button_exit);

Ví dụ làm gì
~~~~~~~~~~~~~~~~~~~~~

Đầu tiên, nó phải bao gồm tệp <linux/input.h>, giao diện với
hệ thống con đầu vào. Điều này cung cấp tất cả các định nghĩa cần thiết.

Trong hàm _init, được gọi khi tải mô-đun hoặc khi
khởi động kernel, nó lấy các tài nguyên cần thiết (nó cũng sẽ kiểm tra
về sự hiện diện của thiết bị).

Sau đó, nó phân bổ cấu trúc thiết bị đầu vào mới với input_allocate_device()
và thiết lập các trường bit đầu vào. Bằng cách này, trình điều khiển thiết bị sẽ thông báo cho thiết bị khác
các bộ phận của hệ thống đầu vào nó là gì - những sự kiện nào có thể được tạo ra hoặc
được chấp nhận bởi thiết bị đầu vào này. Thiết bị ví dụ của chúng tôi chỉ có thể tạo EV_KEY
loại sự kiện và chỉ từ mã sự kiện BTN_0 đó. Vì vậy chúng tôi chỉ thiết lập những
hai bit. Chúng ta có thể đã sử dụng::

set_bit(EV_KEY, Button_dev->evbit);
	set_bit(BTN_0, Button_dev->keybit);

cũng vậy, nhưng với nhiều hơn một bit, cách tiếp cận đầu tiên có xu hướng
ngắn hơn.

Sau đó, trình điều khiển mẫu đăng ký cấu trúc thiết bị đầu vào bằng cách gọi::

input_register_device(button_dev);

Điều này thêm cấu trúc Button_dev vào danh sách liên kết của trình điều khiển đầu vào và
gọi các mô-đun xử lý thiết bị _connect để báo cho chúng biết đầu vào mới
thiết bị đã xuất hiện. input_register_device() có thể ngủ và do đó phải
không được gọi khi bị gián đoạn hoặc khi khóa spinlock được giữ.

Trong khi sử dụng, chức năng duy nhất được sử dụng của trình điều khiển là ::

nút_interrupt()

mỗi lần ngắt từ nút sẽ kiểm tra trạng thái của nó và báo cáo nó
thông qua::

input_report_key()

gọi đến hệ thống đầu vào. Không cần kiểm tra xem ngắt có
thường trình không báo cáo hai sự kiện có giá trị giống nhau (ví dụ: nhấn, nhấn) cho
hệ thống đầu vào, vì các hàm input_report_* kiểm tra xem
chính họ.

Sau đó là::

input_sync()

gọi để thông báo cho những người nhận được sự kiện rằng chúng tôi đã gửi một báo cáo đầy đủ.
Điều này có vẻ không quan trọng trong trường hợp một nút bấm, nhưng lại khá quan trọng
ví dụ: đối với chuyển động của chuột, nơi bạn không muốn giá trị X và Y
được diễn giải một cách riêng biệt, bởi vì điều đó sẽ dẫn đến một chuyển động khác.

dev->open() và dev->close()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trường hợp driver phải thăm dò thiết bị nhiều lần vì không được
bị gián đoạn và việc bỏ phiếu quá tốn kém để thực hiện
mọi lúc hoặc nếu thiết bị sử dụng tài nguyên có giá trị (ví dụ: ngắt), nó
có thể sử dụng lệnh gọi lại open và close để biết khi nào nó có thể dừng bỏ phiếu hoặc
giải phóng ngắt và khi nào nó phải tiếp tục bỏ phiếu hoặc lấy ngắt
một lần nữa. Để làm điều đó, chúng tôi sẽ thêm phần này vào trình điều khiển mẫu của mình ::

nút int tĩnh_open(struct input_dev *dev)
    {
	    if (request_irq(BUTTON_IRQ, Button_interrupt, 0, "nút", NULL)) {
		    printk(KERN_ERR "button.c: Không thể phân bổ irq %d\n", nút_irq);
		    trả về -EBUSY;
	    }

trả về 0;
    }

nút void tĩnh_close(struct input_dev *dev)
    {
	    free_irq(IRQ_AMIGA_VERTB, Button_interrupt);
    }

int tĩnh __init nút_init(void)
    {
	    ...
nút_dev->open = nút_open;
	    nút_dev->đóng = nút_đóng;
	    ...
    }

Lưu ý rằng lõi đầu vào theo dõi số lượng người dùng cho thiết bị và
đảm bảo rằng dev->open() chỉ được gọi khi người dùng đầu tiên kết nối
vào thiết bị và dev->close() được gọi khi người dùng cuối cùng
ngắt kết nối. Các cuộc gọi đến cả hai cuộc gọi lại đều được tuần tự hóa.

Lệnh gọi lại open() sẽ trả về 0 trong trường hợp thành công hoặc bất kỳ giá trị nào khác 0
trong trường hợp thất bại. Lệnh gọi lại close() (không có giá trị) phải luôn thành công.

Ngăn chặn thiết bị đầu vào
~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấm một thiết bị có nghĩa là bỏ qua các sự kiện đầu vào từ nó. Như vậy là về
duy trì mối quan hệ với các trình xử lý đầu vào - hoặc đã tồn tại
các mối quan hệ hoặc các mối quan hệ được thiết lập khi thiết bị đang ở chế độ
trạng thái bị ức chế.

Nếu một thiết bị bị cấm, sẽ không có trình xử lý đầu vào nào nhận được sự kiện từ thiết bị đó.

Việc không ai muốn các sự kiện từ thiết bị bị khai thác sâu hơn bằng cách
gọi thiết bị close() (nếu có người dùng) và open() (nếu có người dùng) trên
hoạt động ức chế và không bị ức chế tương ứng. Thật vậy, ý nghĩa của close()
là ngừng cung cấp các sự kiện cho lõi đầu vào và open() là bắt đầu
cung cấp các sự kiện cho lõi đầu vào.

Gọi phương thức close() của thiết bị khi bị ức chế (nếu có người dùng) cho phép
lái xe để tiết kiệm điện. Hoặc bằng cách trực tiếp tắt nguồn thiết bị hoặc bằng cách
giải phóng tham chiếu thời gian chạy-PM mà nó có trong open() khi trình điều khiển đang sử dụng
thời gian chạy-PM.

Việc ức chế và không bị ức chế trực giao với việc mở và đóng thiết bị bằng cách
các trình xử lý đầu vào. Không gian người dùng có thể muốn chặn một thiết bị trước khi
bất kỳ trình xử lý nào cũng được kết hợp tích cực với nó.

Việc ức chế và không bị ức chế là trực giao với việc thiết bị là nguồn đánh thức,
quá. Là nguồn đánh thức đóng vai trò khi hệ thống đang ngủ chứ không phải khi
hệ thống đang hoạt động.  Người lái xe nên lập trình sự tương tác của họ như thế nào giữa
ức chế, ngủ và là nguồn đánh thức là dành riêng cho người lái xe.

Tương tự với các thiết bị mạng - hạ giao diện mạng xuống
không có nghĩa là không thể đánh thức hệ thống trên LAN thông qua
giao diện này. Vì vậy, có thể có các trình điều khiển đầu vào cần được xem xét đánh thức
nguồn ngay cả khi bị ức chế. Trên thực tế, trong nhiều thiết bị đầu vào I2C, ngắt của chúng
được khai báo là ngắt đánh thức và việc xử lý nó diễn ra trong lõi của trình điều khiển, điều này
không nhận thức được chất ức chế dành riêng cho đầu vào (cũng như không nên như vậy).  Thiết bị tổng hợp
chứa một số giao diện có thể bị hạn chế trên cơ sở mỗi giao diện và ví dụ:
việc ngăn chặn một giao diện sẽ không ảnh hưởng đến khả năng hoạt động của thiết bị
nguồn thức tỉnh.

Nếu một thiết bị được coi là nguồn đánh thức khi bị ức chế, hãy đặc biệt chú ý
phải được thực hiện khi lập trình hệ thống treo() của nó, vì nó có thể cần gọi tới thiết bị
mở(). Tùy thuộc vào ý nghĩa của close() đối với thiết bị được đề cập, không phải
open() trước khi đi ngủ có thể khiến bạn không thể cung cấp bất kỳ thông tin nào
sự kiện thức tỉnh. Dù sao thì thiết bị cũng sẽ chuyển sang chế độ ngủ.

Các loại sự kiện cơ bản
~~~~~~~~~~~~~~~~~~~~~~~

Loại sự kiện đơn giản nhất là EV_KEY, được sử dụng cho các phím và nút.
Nó được báo cáo tới hệ thống đầu vào thông qua::

input_report_key(struct input_dev *dev, mã int, giá trị int)

Xem uapi/linux/input-event-codes.h để biết các giá trị mã được phép (từ 0 đến
KEY_MAX). Giá trị được hiểu là giá trị chân lý, tức là mọi giá trị khác 0 đều có nghĩa là
phím được nhấn, giá trị bằng 0 có nghĩa là phím được nhả. Mã đầu vào chỉ tạo sự kiện
trong trường hợp giá trị khác với trước đây.

Ngoài EV_KEY, còn có hai loại sự kiện cơ bản hơn là EV_REL và
EV_ABS. Chúng được sử dụng cho các giá trị tương đối và tuyệt đối được cung cấp bởi
thiết bị. Ví dụ, một giá trị tương đối có thể là chuyển động của chuột trong trục X.
Con chuột báo cáo đó là sự khác biệt tương đối so với vị trí cuối cùng,
bởi vì nó không có bất kỳ hệ tọa độ tuyệt đối nào để làm việc. Tuyệt đối
các sự kiện cụ thể là dành cho cần điều khiển và bộ số hóa - các thiết bị hoạt động trong một
hệ tọa độ tuyệt đối.

Việc có các nút EV_REL báo cáo thiết bị cũng đơn giản như với EV_KEY; đơn giản
đặt các bit tương ứng và gọi ::

input_report_rel(struct input_dev *dev, mã int, giá trị int)

chức năng. Sự kiện chỉ được tạo cho các giá trị khác 0.

Tuy nhiên EV_ABS cần được chăm sóc đặc biệt một chút. Trước khi gọi
input_register_device, bạn phải điền vào các trường bổ sung trong input_dev
struct cho từng trục tuyệt đối mà thiết bị của bạn có. Nếu thiết bị nút của chúng tôi cũng có
trục ABS_X::

nút_dev.absmin[ABS_X] = 0;
	nút_dev.absmax[ABS_X] = 255;
	nút_dev.absfuzz[ABS_X] = 4;
	nút_dev.absflat[ABS_X] = 8;

Hoặc, bạn chỉ có thể nói::

input_set_abs_params(button_dev, ABS_X, 0, 255, 4, 8);

Cài đặt này sẽ phù hợp với trục X của cần điều khiển, với mức tối thiểu là
0, tối đa là 255 (mà cần điều khiển ZZ0000ZZ có thể chạm tới, không vấn đề gì nếu
đôi khi nó báo cáo nhiều hơn, nhưng nó phải luôn đạt đến mức tối thiểu và
giá trị tối đa), với độ nhiễu trong dữ liệu lên tới +- 4 và với tâm phẳng
vị trí kích thước 8.

Nếu bạn không cần absfuzz và absflat, bạn có thể đặt chúng về 0, nghĩa là
rằng vật đó chính xác và luôn trở về chính xác vị trí trung tâm
(nếu có).

BITS_TO_LONGS(), BIT_WORD(), BIT_MASK()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ba macro này từ bitops.h giúp một số tính toán bitfield ::

BITS_TO_LONGS(x) - trả về độ dài của mảng trường bit theo độ dài cho
			   x bit
	BIT_WORD(x) - trả về chỉ mục trong mảng theo độ dài cho bit x
	BIT_MASK(x) - trả về chỉ mục dài cho bit x

Các trường id* và tên
~~~~~~~~~~~~~~~~~~~~~~~

Tên dev-> phải được đặt trước khi đăng ký thiết bị đầu vào bằng đầu vào
trình điều khiển thiết bị. Đó là một chuỗi như 'Thiết bị nút chung' chứa một
tên thân thiện với người dùng của thiết bị.

Các trường id* chứa ID bus (PCI, USB, ...), ID nhà cung cấp và ID thiết bị
của thiết bị. ID bus được xác định trong input.h. ID nhà cung cấp và thiết bị
được định nghĩa trong pci_ids.h, usb_ids.h và các tệp bao gồm tương tự. Những trường này
phải được thiết lập bởi trình điều khiển thiết bị đầu vào trước khi đăng ký.

Trường idtype có thể được sử dụng để biết thông tin cụ thể cho thiết bị đầu vào
người lái xe.

Các trường id và tên có thể được chuyển đến vùng người dùng thông qua giao diện evdev.

Các trường keycode, keycodemax, keycodesize
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ba trường này nên được sử dụng bởi các thiết bị đầu vào có sơ đồ bàn phím dày đặc.
Mã khóa là một mảng được sử dụng để ánh xạ từ mã scancode tới mã khóa hệ thống đầu vào.
Mã khóa tối đa phải chứa kích thước của mảng và mã hóa khóa
kích thước của mỗi mục trong đó (tính bằng byte).

Không gian người dùng có thể truy vấn và thay đổi scancode hiện tại thành ánh xạ mã khóa bằng cách sử dụng
EVIOCGKEYCODE và EVIOCSKEYCODE ioctls trên giao diện evdev tương ứng.
Khi một thiết bị điền đầy đủ 3 trường nói trên, trình điều khiển có thể
dựa vào việc triển khai cài đặt và truy vấn mã khóa mặc định của kernel
ánh xạ.

dev->getkeycode() và dev->setkeycode()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lệnh gọi lại getkeycode() và setkeycode() cho phép trình điều khiển ghi đè mặc định
Cơ chế ánh xạ keycode/keycodesize/keycodemax được cung cấp bởi lõi đầu vào
và triển khai bản đồ mã khóa thưa thớt.

Tự động lặp lại khóa
~~~~~~~~~~~~~~~~~~~~

... is simple. It is handled by the input.c module. Hardware autorepeat is
không được sử dụng vì nó không có trong nhiều thiết bị và ngay cả ở những nơi nó có
hiện tại thỉnh thoảng bị hỏng (ở bàn phím: notebook Toshiba). Để kích hoạt
tự động lặp lại cho thiết bị của bạn, chỉ cần đặt EV_REP trong dev->evbit. Tất cả sẽ được
được xử lý bởi hệ thống đầu vào.

Các loại sự kiện khác, xử lý các sự kiện đầu ra
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các loại sự kiện khác cho đến nay là:

- EV_LED - dùng cho đèn LED bàn phím.
- EV_SND - dùng cho tiếng bíp bàn phím.

Chúng rất giống với các sự kiện quan trọng chẳng hạn, nhưng chúng đi theo một hướng khác.
hướng - từ hệ thống đến trình điều khiển thiết bị đầu vào. Nếu thiết bị đầu vào của bạn
trình điều khiển có thể xử lý các sự kiện này, nó phải đặt các bit tương ứng trong evbit,
ZZ0000ZZ cũng có thói quen gọi lại::

nút_dev->sự kiện = nút_event;

nút int_event(struct input_dev *dev, kiểu int không dấu,
		     mã int không dấu, giá trị int)
    {
	    if (loại == EV_SND && mã == SND_BELL) {
		    outb(giá trị, BUTTON_BELL);
		    trả về 0;
	    }
	    trả về -1;
    }

Thủ tục gọi lại này có thể được gọi từ một ngắt hoặc một BH (mặc dù
không phải là quy định), do đó không được ngủ và không được mất quá nhiều thời gian để hoàn thành.

Thiết bị đầu vào được thăm dò
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Kiểm tra vòng đầu vào được thiết lập bằng cách chuyển cấu trúc thiết bị đầu vào và gọi lại tới
chức năng::

int input_setup_polling(struct input_dev *dev,
        khoảng trống (*poll_fn)(struct input_dev *dev))

Trong lệnh gọi lại, thiết bị phải sử dụng các hàm input_report_* thông thường
và input_sync như được sử dụng bởi các thiết bị khác.

Ngoài ra còn có chức năng::

void input_set_poll_interval(struct input_dev *dev, khoảng int không dấu)

được sử dụng để định cấu hình khoảng thời gian tính bằng mili giây mà thiết bị sẽ
được bỏ phiếu tại.
