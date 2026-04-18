.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/gpio/gpio-aggregator.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Bộ tổng hợp GPIO
===============

Bộ tổng hợp GPIO cung cấp cơ chế tổng hợp các GPIO và hiển thị chúng dưới dạng
một gpio_chip mới.  Điều này hỗ trợ các trường hợp sử dụng sau.


Tổng hợp GPIO bằng Sysfs
-----------------------------

Bộ điều khiển GPIO được xuất sang không gian người dùng bằng ký tự /dev/gpiochip*
thiết bị.  Kiểm soát quyền truy cập vào các thiết bị này được cung cấp bởi tệp UNIX tiêu chuẩn
quyền hệ thống, trên cơ sở tất cả hoặc không có gì: bộ điều khiển GPIO là
người dùng có thể truy cập hoặc không.

Bộ tổng hợp GPIO cung cấp khả năng kiểm soát truy cập cho một bộ gồm một hoặc nhiều GPIO, bằng cách
tổng hợp chúng thành một gpio_chip mới, có thể được gán cho một nhóm hoặc người dùng
sử dụng quyền sở hữu và quyền đối với tệp UNIX tiêu chuẩn.  Hơn nữa, điều này
đơn giản hóa và tăng cường việc xuất GPIO sang máy ảo, vì VM chỉ có thể
lấy bộ điều khiển GPIO đầy đủ và không còn cần phải quan tâm đến GPIO nào nữa
lấy và cái nào không, làm giảm bề mặt tấn công.

Bộ điều khiển GPIO tổng hợp được khởi tạo và hủy bằng cách ghi vào
các tệp thuộc tính chỉ ghi trong sysfs.

/sys/bus/platform/drivers/gpio-aggregator/

"new_device" ...
		Không gian người dùng có thể yêu cầu kernel khởi tạo GPIO tổng hợp
		bộ điều khiển bằng cách viết một chuỗi mô tả GPIO tới
		tổng hợp vào tệp "new_device", sử dụng định dạng

		.. code-block:: none

		    [<gpioA>] [<gpiochipB> <offsets>] ...

Ở đâu:

"<gpioA>" ...
			    là tên dòng GPIO,

"<gpiochipB>" ...
			    là nhãn chip GPIO và

"<bù đắp>" ...
			    là danh sách các phần bù GPIO được phân tách bằng dấu phẩy và/hoặc
			    Phạm vi bù GPIO được biểu thị bằng dấu gạch ngang.

Ví dụ: Khởi tạo trình tổng hợp GPIO mới bằng cách tổng hợp GPIO
		dòng 19 của "e6052000.gpio" và dòng GPIO 20-21 của
		"e6050000.gpio" vào gpio_chip mới:

		.. code-block:: sh

		    $ echo 'e6052000.gpio 19 e6050000.gpio 20-21' > new_device

"xóa_thiết bị" ...
		Không gian người dùng có thể yêu cầu kernel hủy GPIO tổng hợp
		bộ điều khiển sau khi sử dụng bằng cách ghi tên thiết bị của nó vào
		tập tin "xóa_thiết bị".

Ví dụ: Phá hủy GPIO tổng hợp được tạo trước đó
		bộ điều khiển, được coi là "gpio-aggregator.0":

		.. code-block:: sh

		    $ echo gpio-aggregator.0 > delete_device


Tổng hợp GPIO bằng Configfs
--------------------------------

ZZ0001ZZ ZZ0000ZZ

Đây là thư mục gốc của cây configfs gpio-aggregator.

ZZ0001ZZ ZZ0000ZZ

Thư mục này đại diện cho một thiết bị tổng hợp GPIO. Bạn có thể chỉ định bất kỳ
    đặt tên thành ZZ0000ZZ (ví dụ ZZ0001ZZ), ngoại trừ các tên bắt đầu bằng
    Tiền tố ZZ0002ZZ, được dành riêng cho các cấu hình được tạo tự động
    các mục tương ứng với các thiết bị được tạo thông qua Sysfs.

ZZ0001ZZ ZZ0000ZZ

Thuộc tính ZZ0000ZZ cho phép kích hoạt việc tạo thiết bị thực tế
    một khi nó được cấu hình đầy đủ. Các giá trị được chấp nhận là:

* ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ : kích hoạt thiết bị ảo
    * ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ : vô hiệu hóa thiết bị ảo

ZZ0001ZZ ZZ0000ZZ

Thuộc tính ZZ0000ZZ chỉ đọc hiển thị tên của thiết bị vì nó
    sẽ xuất hiện trong hệ thống trên bus nền tảng (ví dụ ZZ0001ZZ).
    Điều này rất hữu ích để xác định thiết bị ký tự cho ký tự mới được tạo
    người tổng hợp. Nếu là ZZ0002ZZ,
    Đường dẫn ZZ0003ZZ cho bạn biết rằng
    Id thiết bị GPIO là ZZ0004ZZ.

Bạn phải tạo thư mục con cho mỗi dòng ảo bạn muốn
khởi tạo, đặt tên chính xác là ZZ0000ZZ, ZZ0001ZZ, ..., ZZ0002ZZ, khi
bạn muốn khởi tạo các dòng ZZ0003ZZ (Y >= 0).  Cấu hình tất cả các dòng trước
kích hoạt thiết bị bằng cách đặt ZZ0004ZZ thành 1.

ZZ0001ZZ ZZ0000ZZ

Thư mục này đại diện cho một dòng GPIO để đưa vào bộ tổng hợp.

ZZ0001ZZ ZZ0000ZZ

ZZ0001ZZ ZZ0000ZZ

Các giá trị mặc định sau khi tạo thư mục ZZ0000ZZ là:

* ZZ0000ZZ : <trống>
    * ZZ0001ZZ : -1

ZZ0000ZZ phải luôn được cấu hình rõ ràng, còn ZZ0001ZZ thì tùy thuộc vào.
    Hai mẫu cấu hình tồn tại cho mỗi ZZ0002ZZ:

(Một). Để tra cứu theo tên dòng GPIO:

* Đặt ZZ0000ZZ thành tên dòng.
         * Đảm bảo ZZ0001ZZ duy trì -1 (mặc định).

(b). Để tra cứu theo tên chip GPIO và độ lệch dòng trong chip:

* Đặt ZZ0000ZZ thành tên chip.
         * Đặt ZZ0001ZZ thành độ lệch dòng (0 <= ZZ0002ZZ < 65535).

ZZ0001ZZ ZZ0000ZZ

Thuộc tính ZZ0000ZZ đặt tên tùy chỉnh cho dòngY. Nếu không được đặt,
    dòng sẽ vẫn chưa được đặt tên.

Sau khi cấu hình xong, thuộc tính ZZ0000ZZ phải được đặt thành 1
để khởi tạo thiết bị tổng hợp. Nó có thể được đặt lại về 0 để
phá hủy thiết bị ảo. Mô-đun sẽ đồng bộ chờ đợi cái mới
thiết bị tổng hợp được thăm dò thành công và nếu điều này không xảy ra, hãy viết
sang ZZ0001ZZ sẽ dẫn đến lỗi. Đây là một hành vi khác với
trường hợp khi bạn tạo nó bằng giao diện sysfs ZZ0002ZZ.

.. note::

   For aggregators created via Sysfs, the configfs entries are
   auto-generated and appear as ``/config/gpio-aggregator/_sysfs.<N>/``. You
   cannot add or remove line directories with mkdir(2)/rmdir(2). To modify
   lines, you must use the "delete_device" interface to tear down the
   existing device and reconfigure it from scratch. However, you can still
   toggle the aggregator with the ``live`` attribute and adjust the
   ``key``, ``offset``, and ``name`` attributes for each line when ``live``
   is set to 0 by hand (i.e. it's not waiting for deferred probe).

Lệnh cấu hình mẫu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: sh

    # Create a directory for an aggregator device
    $ mkdir /sys/kernel/config/gpio-aggregator/agg0

    # Configure each line
    $ mkdir /sys/kernel/config/gpio-aggregator/agg0/line0
    $ echo gpiochip0 > /sys/kernel/config/gpio-aggregator/agg0/line0/key
    $ echo 6         > /sys/kernel/config/gpio-aggregator/agg0/line0/offset
    $ echo test0     > /sys/kernel/config/gpio-aggregator/agg0/line0/name
    $ mkdir /sys/kernel/config/gpio-aggregator/agg0/line1
    $ echo gpiochip0 > /sys/kernel/config/gpio-aggregator/agg0/line1/key
    $ echo 7         > /sys/kernel/config/gpio-aggregator/agg0/line1/offset
    $ echo test1     > /sys/kernel/config/gpio-aggregator/agg0/line1/name

    # Activate the aggregator device
    $ echo 1         > /sys/kernel/config/gpio-aggregator/agg0/live


Trình điều khiển GPIO chung
-------------------

Bộ tổng hợp GPIO cũng có thể được sử dụng làm trình điều khiển chung cho một công việc đơn giản
Thiết bị vận hành GPIO được mô tả trong DT, không có trình điều khiển trong nhân chuyên dụng.
Điều này rất hữu ích trong kiểm soát công nghiệp và không giống như ví dụ: spidev, cái nào
cho phép người dùng giao tiếp với thiết bị SPI từ không gian người dùng.

Việc liên kết một thiết bị với Bộ tổng hợp GPIO được thực hiện bằng cách sửa đổi
trình điều khiển tổng hợp gpio hoặc bằng cách ghi vào tệp "driver_override" trong Sysfs.

Ví dụ: Nếu "cửa" là thiết bị vận hành GPIO được mô tả trong DT, sử dụng thiết bị riêng của nó
giá trị tương thích::

cửa {
		tương thích = "myvendor,mydoor";

gpios = <&gpio2 19 GPIO_ACTIVE_HIGH>,
			<&gpio2 20 GPIO_ACTIVE_LOW>;
		gpio-line-names = "mở", "khóa";
	};

nó có thể được liên kết với Bộ tổng hợp GPIO bằng một trong hai cách:

1. Thêm giá trị tương thích của nó vào ZZ0000ZZ,
2. Liên kết thủ công bằng cách sử dụng "driver_override":

.. code-block:: sh

    $ echo gpio-aggregator > /sys/bus/platform/devices/door/driver_override
    $ echo door > /sys/bus/platform/drivers/gpio-aggregator/bind

Sau đó, một “cánh cửa” gpiochip mới đã được tạo:

.. code-block:: sh

    $ gpioinfo door
    gpiochip12 - 2 lines:
	    line   0:       "open"       unused   input  active-high
	    line   1:       "lock"       unused   input  active-high