.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/ff.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Buộc phản hồi cho Linux
========================

:Tác giả: Johann Deneux <johann.deneux@gmail.com> ngày 22/04/2001.
:Cập nhật: Anssi Hannula <anssi.hannula@gmail.com> vào ngày 09/04/2006.

Bạn có thể phân phối lại tập tin này. Hãy nhớ bao gồm hình dạng.svg và
tương tác.svg là tốt.

Giới thiệu
~~~~~~~~~~~~

Tài liệu này mô tả cách sử dụng các thiết bị phản hồi lực trong Linux. các
Mục tiêu không phải là hỗ trợ các thiết bị này như thể chúng là những thiết bị chỉ có đầu vào đơn giản
(như trường hợp này đã xảy ra rồi), nhưng để thực sự có thể tạo ra lực
hiệu ứng.
Tài liệu này chỉ mô tả phần phản hồi lực của đầu vào Linux
giao diện. Vui lòng đọc joydev/joystick.rst và input.rst trước khi đọc thêm
tài liệu này.

Hướng dẫn cho người dùng
~~~~~~~~~~~~~~~~~~~~~~~~

Để bật phản hồi lực, bạn phải:

1. cấu hình kernel của bạn với evdev và trình điều khiển hỗ trợ
   thiết bị.
2. đảm bảo mô-đun evdev đã được tải và các tệp thiết bị /dev/input/event* được
   được tạo ra.

Trước khi bạn bắt đầu, hãy cho tôi biết WARN rằng một số thiết bị rung lắc dữ dội trong quá trình sử dụng.
giai đoạn khởi tạo. Ví dụ: điều này xảy ra với "AVB Top Shot Pegasus" của tôi.
Để ngăn chặn hành vi khó chịu này, hãy di chuyển cần điều khiển của bạn đến giới hạn của nó. Dù sao đi nữa, bạn
nên giữ tay trên thiết bị của bạn để tránh thiết bị bị hỏng nếu
có gì đó không ổn.

Nếu bạn có thiết bị iforce nối tiếp, bạn cần bắt đầu đính kèm đầu vào. Xem
joydev/joystick.rst để biết chi tiết.

Nó có hoạt động không?
--------------

Có một tiện ích tên là fftest sẽ cho phép bạn kiểm tra trình điều khiển ::

% fftest /dev/input/eventXX

Hướng dẫn cho nhà phát triển
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tất cả các tương tác được thực hiện bằng sự kiện API. Tức là bạn có thể sử dụng ioctl()
và write() trên /dev/input/eventXX.
Thông tin này có thể thay đổi.

Truy vấn khả năng của thiết bị
----------------------------

::

#include <linux/input.h>
    #include <sys/ioctl.h>

#define BITS_TO_LONGS(x) \
	    (((x) + 8 * sizeof (dài không dấu) - 1) / (8 * sizeof (dài không dấu)))
    tính năng dài không dấu [BITS_TO_LONGS(FF_CNT)];
    int ioctl(int file_descriptor, int request, các tính năng * dài không dấu);

"yêu cầu" phải là EVIOCGBIT(EV_FF, kích thước của mảng tính năng tính bằng byte)

Trả về các tính năng được thiết bị hỗ trợ. các tính năng là một bitfield với
bit sau:

- FF_CONSTANT có thể tạo ra hiệu ứng lực không đổi
- FF_PERIODIC có thể hiển thị các hiệu ứng định kỳ với các dạng sóng sau:

- Dạng sóng vuông FF_SQUARE
  - Dạng sóng tam giác FF_TRIANGLE
  - Dạng sóng hình sin FF_SINE
  - FF_SAW_UP dạng sóng răng cưa lên
  - FF_SAW_DOWN dạng sóng răng cưa xuống
  - Dạng sóng tùy chỉnh FF_CUSTOM

- FF_RAMP có thể hiển thị hiệu ứng đoạn đường nối
- FF_SPRING có thể mô phỏng sự hiện diện của lò xo
- FF_FRICTION có thể mô phỏng ma sát
- FF_DAMPER có thể mô phỏng hiệu ứng giảm xóc
- Hiệu ứng ầm ầm FF_RUMBLE
- FF_INERTIA có thể mô phỏng quán tính
- Mức tăng FF_GAIN có thể điều chỉnh được
- Tự động điều chỉnh FF_AUTOCENTER

.. note::

    - In most cases you should use FF_PERIODIC instead of FF_RUMBLE. All
      devices that support FF_RUMBLE support FF_PERIODIC (square, triangle,
      sine) and the other way around.

    - The exact syntax FF_CUSTOM is undefined for the time being as no driver
      supports it yet.

::

int ioctl(int fd, EVIOCGEFFECTS, int *n);

Trả về số lượng hiệu ứng mà thiết bị có thể lưu giữ trong bộ nhớ.

Tải hiệu ứng lên thiết bị
-------------------------------

::

#include <linux/input.h>
    #include <sys/ioctl.h>

int ioctl(int file_descriptor, int request, struct ff_effect *effect);

"yêu cầu" phải là EVIOCSFF.

"hiệu ứng" trỏ đến cấu trúc mô tả hiệu ứng cần tải lên. Hiệu ứng là
đã tải lên nhưng không chơi được.
Nội dung của hiệu ứng có thể được sửa đổi. Đặc biệt, trường "id" của nó được đặt
tới id duy nhất do người lái xe chỉ định. Dữ liệu này là cần thiết để thực hiện
một số thao tác (xóa hiệu ứng, điều khiển phát lại).
Trường "id" phải được người dùng đặt thành -1 để yêu cầu người lái xe thực hiện
phân bổ một hiệu ứng mới.

Hiệu ứng là mô tả tập tin cụ thể.

Xem <uapi/linux/input.h> để biết mô tả về cấu trúc ff_effect.  bạn
cũng nên tìm sự trợ giúp trong một vài bản phác thảo, có trong tệp shape.svg
và tương tác.svg:

.. kernel-figure:: shape.svg

    Shape

.. kernel-figure:: interactive.svg

    Interactive


Xóa hiệu ứng khỏi thiết bị
----------------------------------

::

int ioctl(int fd, EVIOCRMFF, effect.id);

Điều này nhường chỗ cho các hiệu ứng mới trong bộ nhớ của thiết bị. Lưu ý rằng điều này cũng
dừng hiệu ứng nếu nó đang chơi.

Kiểm soát việc phát lại các hiệu ứng
-----------------------------------

Việc điều khiển việc chơi được thực hiện bằng write(). Dưới đây là một ví dụ:

::

#include <linux/input.h>
    #include <unistd.h>

struct input_event chơi;
	struct input_event dừng;
	hiệu ứng struct ff_effect;
	int fd;
   ...
fd = open("/dev/input/eventXX", O_RDWR);
   ...
/* Chơi ba lần */
	play.type = EV_FF;
	play.code = effect.id;
	play.value = 3;

write(fd, (const void*) &play, sizeof(play));
   ...
/*Dừng hiệu ứng*/
	stop.type = EV_FF;
	stop.code = effect.id;
	dừng.value = 0;

write(fd, (const void*) &stop, sizeof(stop));

Thiết lập mức tăng
----------------

Không phải tất cả các thiết bị đều có sức mạnh như nhau. Vì vậy, người dùng nên đặt mức tăng
tùy thuộc vào mức độ họ muốn hiệu ứng mạnh đến mức nào. Cài đặt này là
liên tục trong quá trình truy cập vào trình điều khiển.

::

/* Đặt mức tăng của thiết bị
    tăng int;		/* trong khoảng từ 0 đến 100 */
    struct input_event tức là;	/*Cấu trúc dùng để giao tiếp với driver */

tức là.type = EV_FF;
    tức là.code = FF_GAIN;
    tức là.value = 0xFFFFUL * tăng / 100;

if (write(fd, &ie, sizeof(ie)) == -1)
	perror("đặt mức tăng");

Bật/Tắt autocenter
-----------------------------

Theo tôi, tính năng autocenter làm xáo trộn khá nhiều việc hiển thị các hiệu ứng,
và tôi nghĩ nó sẽ là một hiệu ứng, việc tính toán nào phụ thuộc vào trò chơi
loại. Nhưng bạn có thể kích hoạt nó nếu bạn muốn.

::

int autocenter;		/* trong khoảng từ 0 đến 100 */
    struct input_event tức là;

tức là.type = EV_FF;
    tức là.code = FF_AUTOCENTER;
    tức là.value = 0xFFFFUL * autocenter / 100;

if (write(fd, &ie, sizeof(ie)) == -1)
	perror("đặt trung tâm tự động");

Giá trị 0 có nghĩa là "không có trung tâm tự động".

Cập nhật động của hiệu ứng
---------------------------

Tiến hành như thể bạn muốn tải lên một hiệu ứng mới, ngoại trừ thay vì
đặt trường id thành -1, bạn đặt nó thành id hiệu ứng mong muốn.
Thông thường, hiệu ứng không dừng lại và khởi động lại. Tuy nhiên, tùy thuộc vào
loại thiết bị, không phải tất cả các thông số đều có thể được cập nhật động. Ví dụ,
hướng của hiệu ứng không thể được cập nhật bằng thiết bị iforce. Trong này
trường hợp, trình điều khiển sẽ dừng hiệu ứng, tải nó lên và khởi động lại.

Vì vậy, nên thay đổi hướng linh hoạt trong khi hiệu ứng
chỉ phát khi bạn có thể khởi động lại hiệu ứng với số lần phát lại là 1.

Thông tin về trạng thái của hiệu ứng
---------------------------------------

Mỗi khi trạng thái của hiệu ứng thay đổi, một sự kiện sẽ được gửi đi. Các giá trị
và ý nghĩa của các lĩnh vực của sự kiện như sau::

cấu trúc đầu vào_sự kiện {
    /* Khi trạng thái của hiệu ứng thay đổi */
	    cấu trúc thời gian thời gian;

/* Đặt thành EV_FF_STATUS */
	    loại ngắn không dấu;

/* Chứa id của hiệu ứng */
	    mã ngắn không dấu;

/*Biểu thị trạng thái*/
	    giá trị int không dấu;
    };

FF_STATUS_STOPPED Hiệu ứng đã dừng phát
    FF_STATUS_PLAYING Hiệu ứng bắt đầu phát

.. note::

    - Status feedback is only supported by iforce driver. If you have
      a really good reason to use this, please contact
      linux-joystick@atrey.karlin.mff.cuni.cz or anssi.hannula@gmail.com
      so that support for it can be added to the rest of the drivers.
