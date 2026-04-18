.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/pin-control.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Hệ thống con PINCTRL (PIN CONTROL)
==================================

Tài liệu này phác thảo hệ thống con điều khiển pin trong Linux

Hệ thống con này xử lý:

- Đếm và đặt tên các chân điều khiển

- Ghép các chốt, miếng đệm, ngón tay (v.v.) xem bên dưới để biết chi tiết

- Cấu hình các chốt, miếng đệm, ngón tay (vv) như điều khiển bằng phần mềm
  các chân cụ thể của chế độ lái và thiên vị, chẳng hạn như kéo lên, kéo xuống, mở cống,
  điện dung tải vv.

Giao diện cấp cao nhất
===================

định nghĩa:

- PIN CONTROLLER là một phần cứng, thường là một bộ thanh ghi,
  có thể kiểm soát mã PIN. Nó có thể ghép kênh, phân cực, đặt điện dung tải,
  đặt cường độ truyền động, v.v. cho từng chân hoặc nhóm chân.

- PINS tương đương với miếng đệm, ngón tay, quả bóng hoặc bất kỳ đầu vào bao bì nào hoặc
  dòng đầu ra bạn muốn kiểm soát và chúng được biểu thị bằng số nguyên không dấu
  trong phạm vi 0..maxpin. Không gian số này là cục bộ của mỗi PIN CONTROLLER, vì vậy
  có thể có một số không gian số như vậy trong một hệ thống. Không gian ghim này có thể
  thưa thớt - tức là có thể có những khoảng trống trong không gian với những con số không có
  pin tồn tại.

Khi một PIN CONTROLLER được khởi tạo, nó sẽ đăng ký một bộ mô tả cho
khung điều khiển pin và bộ mô tả này chứa một loạt các bộ mô tả pin
mô tả các chân được xử lý bởi bộ điều khiển chân cụ thể này.

Dưới đây là ví dụ về chip PGA (Pin Grid Array) nhìn từ bên dưới::

A B C D E F G H

8 o o o o o o o

7 ồ ồ ồ ồ ồ

6 o o o o o o o

5 o o o o o o o

4 o o o o o o o

3 o o o o o o o

2 o o o o o o o

1 o o o o o o o

Để đăng ký bộ điều khiển pin và đặt tên cho tất cả các chân trên gói này, chúng ta có thể làm
cái này trong trình điều khiển của chúng tôi:

.. code-block:: c

	#include <linux/pinctrl/pinctrl.h>

	const struct pinctrl_pin_desc foo_pins[] = {
		PINCTRL_PIN(0, "A8"),
		PINCTRL_PIN(1, "B8"),
		PINCTRL_PIN(2, "C8"),
		...
		PINCTRL_PIN(61, "F1"),
		PINCTRL_PIN(62, "G1"),
		PINCTRL_PIN(63, "H1"),
	};

	static struct pinctrl_desc foo_desc = {
		.name = "foo",
		.pins = foo_pins,
		.npins = ARRAY_SIZE(foo_pins),
		.owner = THIS_MODULE,
	};

	int __init foo_init(void)
	{
		int error;

		struct pinctrl_dev *pctl;

		error = pinctrl_register_and_init(&foo_desc, <PARENT>, NULL, &pctl);
		if (error)
			return error;

		return pinctrl_enable(pctl);
	}

Để kích hoạt hệ thống con pinctrl và các nhóm con cho PINMUX và PINCONF và
trình điều khiển đã chọn, bạn cần chọn chúng từ mục Kconfig của máy,
vì chúng được tích hợp rất chặt chẽ với các máy mà chúng được sử dụng.
Xem ZZ0000ZZ để biết ví dụ.

Ghim thường có tên lạ hơn thế này. Bạn có thể tìm thấy những thứ này trong biểu dữ liệu
cho chip của bạn. Lưu ý rằng tệp pinctrl.h lõi cung cấp một macro ưa thích
được gọi là ZZ0000ZZ để tạo các mục cấu trúc. Như bạn có thể thấy các chân là
được liệt kê từ 0 ở góc trên bên trái đến 63 ở góc dưới bên phải.
Bảng liệt kê này được chọn tùy ý, trong thực tế bạn cần suy nghĩ
thông qua hệ thống đánh số của bạn sao cho phù hợp với cách bố trí các sổ đăng ký
và những thứ như vậy trong trình điều khiển của bạn, nếu không mã có thể trở nên phức tạp. Bạn phải
cũng xem xét việc kết hợp các độ lệch với phạm vi GPIO có thể được xử lý bởi
bộ điều khiển chốt.

Đối với phần đệm có 467 miếng đệm, trái ngược với các chân thực tế, việc liệt kê sẽ
như thế này, đi vòng quanh rìa của con chip, có vẻ như là ngành công nghiệp
tiêu chuẩn nữa (tất cả các miếng đệm này cũng có tên)::


0..... 104
   466 105
     .        .
     .        .
   358 224
    357 .... 225


Ghim nhóm
==========

Nhiều bộ điều khiển cần xử lý các nhóm chân, do đó bộ điều khiển chân
hệ thống con có cơ chế liệt kê các nhóm chân và truy xuất
các chân được liệt kê thực tế là một phần của một nhóm nhất định.

Ví dụ: giả sử chúng ta có một nhóm chân xử lý giao diện SPI
trên {0, 8, 16, 24 } và một nhóm chân xử lý giao diện I2C trên các chân
vào ngày { 24, 25 }.

Hai nhóm này được đưa vào hệ thống con điều khiển pin bằng cách thực hiện
một số ZZ0000ZZ chung chung như thế này:

.. code-block:: c

	#include <linux/pinctrl/pinctrl.h>

	static const unsigned int spi0_pins[] = { 0, 8, 16, 24 };
	static const unsigned int i2c0_pins[] = { 24, 25 };

	static const struct pingroup foo_groups[] = {
		PINCTRL_PINGROUP("spi0_grp", spi0_pins, ARRAY_SIZE(spi0_pins)),
		PINCTRL_PINGROUP("i2c0_grp", i2c0_pins, ARRAY_SIZE(i2c0_pins)),
	};

	static int foo_get_groups_count(struct pinctrl_dev *pctldev)
	{
		return ARRAY_SIZE(foo_groups);
	}

	static const char *foo_get_group_name(struct pinctrl_dev *pctldev,
					      unsigned int selector)
	{
		return foo_groups[selector].name;
	}

	static int foo_get_group_pins(struct pinctrl_dev *pctldev,
				      unsigned int selector,
				      const unsigned int **pins,
				      unsigned int *npins)
	{
		*pins = foo_groups[selector].pins;
		*npins = foo_groups[selector].npins;
		return 0;
	}

	static struct pinctrl_ops foo_pctrl_ops = {
		.get_groups_count = foo_get_groups_count,
		.get_group_name = foo_get_group_name,
		.get_group_pins = foo_get_group_pins,
	};

	static struct pinctrl_desc foo_desc = {
		...
		.pctlops = &foo_pctrl_ops,
	};

Hệ thống con điều khiển pin sẽ gọi hàm ZZ0000ZZ để
xác định tổng số bộ chọn hợp lệ, sau đó nó sẽ gọi các hàm khác
để lấy tên và các chân của nhóm. Duy trì cấu trúc dữ liệu của
các nhóm tùy thuộc vào người lái xe, đây chỉ là một ví dụ đơn giản - trong thực tế, bạn
có thể cần nhiều mục hơn trong cấu trúc nhóm của bạn, ví dụ như đăng ký cụ thể
phạm vi liên kết với từng nhóm, v.v.


Cấu hình chân
=================

Ghim đôi khi có thể được cấu hình bằng phần mềm theo nhiều cách khác nhau, chủ yếu liên quan đến
thuộc tính điện tử của chúng khi được sử dụng làm đầu vào hoặc đầu ra. Ví dụ bạn
có thể tạo ra trở kháng cao cho chân đầu ra (Hi-Z) hoặc "tristate" nghĩa là nó
bị ngắt kết nối một cách hiệu quả. Bạn có thể kết nối chân đầu vào với VDD hoặc GND
sử dụng một giá trị điện trở nhất định - kéo lên và kéo xuống - để chân có
giá trị ổn định khi không có gì dẫn động đường ray mà nó được kết nối hoặc khi nó
không được kết nối.

Cấu hình pin có thể được lập trình bằng cách thêm các mục cấu hình vào
bảng ánh xạ; xem phần ZZ0000ZZ bên dưới.

Định dạng và ý nghĩa của tham số cấu hình, PLATFORM_X_PULL_UP
ở trên, hoàn toàn được xác định bởi trình điều khiển bộ điều khiển pin.

Trình điều khiển cấu hình pin thực hiện các lệnh gọi lại để thay đổi pin
cấu hình trong bộ điều khiển pin hoạt động như thế này:

.. code-block:: c

	#include <linux/pinctrl/pinconf.h>
	#include <linux/pinctrl/pinctrl.h>

	#include "platform_x_pindefs.h"

	static int foo_pin_config_get(struct pinctrl_dev *pctldev,
				      unsigned int offset,
				      unsigned long *config)
	{
		struct my_conftype conf;

		/* ... Find setting for pin @ offset ... */

		*config = (unsigned long) conf;
	}

	static int foo_pin_config_set(struct pinctrl_dev *pctldev,
				      unsigned int offset,
				      unsigned long config)
	{
		struct my_conftype *conf = (struct my_conftype *) config;

		switch (conf) {
			case PLATFORM_X_PULL_UP:
			...
			break;
		}
	}

	static int foo_pin_config_group_get(struct pinctrl_dev *pctldev,
					    unsigned selector,
					    unsigned long *config)
	{
		...
	}

	static int foo_pin_config_group_set(struct pinctrl_dev *pctldev,
					    unsigned selector,
					    unsigned long config)
	{
		...
	}

	static struct pinconf_ops foo_pconf_ops = {
		.pin_config_get = foo_pin_config_get,
		.pin_config_set = foo_pin_config_set,
		.pin_config_group_get = foo_pin_config_group_get,
		.pin_config_group_set = foo_pin_config_group_set,
	};

	/* Pin config operations are handled by some pin controller */
	static struct pinctrl_desc foo_desc = {
		...
		.confops = &foo_pconf_ops,
	};

Tương tác với hệ thống con GPIO
===================================

Trình điều khiển GPIO có thể muốn thực hiện nhiều loại hoạt động khác nhau trên cùng một
các chân vật lý cũng được đăng ký làm chân điều khiển chân.

Đầu tiên và quan trọng nhất, hai hệ thống con có thể được sử dụng hoàn toàn trực giao,
xem phần có tên ZZ0000ZZ và
ZZ0001ZZ bên dưới để biết chi tiết. Nhưng ở một số
trong các trường hợp cần có ánh xạ hệ thống con chéo giữa các chân và GPIO.

Vì hệ thống con bộ điều khiển chân có không gian pin cục bộ đối với bộ điều khiển chân
chúng ta cần ánh xạ để hệ thống con điều khiển chốt có thể tìm ra chốt nào
bộ điều khiển xử lý việc điều khiển một chân GPIO nhất định. Vì bộ điều khiển một chân
có thể kết hợp một số phạm vi GPIO (thường là SoC có một bộ chân,
nhưng bên trong có một số khối silicon GPIO, mỗi khối được mô hình hóa như một cấu trúc
gpio_chip) bất kỳ số lượng phạm vi GPIO nào cũng có thể được thêm vào phiên bản bộ điều khiển pin
như thế này:

.. code-block:: c

	#include <linux/gpio/driver.h>

	#include <linux/pinctrl/pinctrl.h>

	struct gpio_chip chip_a;
	struct gpio_chip chip_b;

	static struct pinctrl_gpio_range gpio_range_a = {
		.name = "chip a",
		.id = 0,
		.base = 32,
		.pin_base = 32,
		.npins = 16,
		.gc = &chip_a,
	};

	static struct pinctrl_gpio_range gpio_range_b = {
		.name = "chip b",
		.id = 0,
		.base = 48,
		.pin_base = 64,
		.npins = 8,
		.gc = &chip_b;
	};

	int __init foo_init(void)
	{
		struct pinctrl_dev *pctl;
		...
		pinctrl_add_gpio_range(pctl, &gpio_range_a);
		pinctrl_add_gpio_range(pctl, &gpio_range_b);
		...
	}

Vì vậy, hệ thống phức tạp này có một bộ điều khiển pin xử lý hai
Chip GPIO. "chip a" có 16 chân và "chip b" có 8 chân. "chip a" và
"chip b" có ZZ0000ZZ khác nhau, nghĩa là số chân bắt đầu của
Phạm vi GPIO.

Phạm vi "chip a" của GPIO bắt đầu từ cơ sở GPIO gồm 32 và thực tế
phạm vi chân cũng bắt đầu từ 32. Tuy nhiên, "chip b" có điểm khởi đầu khác
bù đắp cho phạm vi GPIO và phạm vi pin. Phạm vi GPIO của "chip b" bắt đầu
từ GPIO số 48, trong khi phạm vi chân của "chip b" bắt đầu từ 64.

Chúng ta có thể chuyển đổi số gpio thành số pin thực tế bằng ZZ0000ZZ này.
Chúng được ánh xạ trong không gian pin GPIO toàn cầu tại:

chíp một:
 - Phạm vi GPIO : [32 .. 47]
 - phạm vi chân cắm: [32 .. 47]
chip b:
 - Phạm vi GPIO : [48 .. 55]
 - phạm vi chân cắm: [64 .. 71]

Các ví dụ trên giả sử ánh xạ giữa GPIO và chân là
tuyến tính. Nếu ánh xạ thưa thớt hoặc lộn xộn, một mảng ghim tùy ý
số có thể được mã hóa trong phạm vi như thế này:

.. code-block:: c

	static const unsigned int range_pins[] = { 14, 1, 22, 17, 10, 8, 6, 2 };

	static struct pinctrl_gpio_range gpio_range = {
		.name = "chip",
		.id = 0,
		.base = 32,
		.pins = &range_pins,
		.npins = ARRAY_SIZE(range_pins),
		.gc = &chip,
	};

Trong trường hợp này thuộc tính ZZ0000ZZ sẽ bị bỏ qua. Nếu tên của một pin
nhóm đã biết, các phần tử chân và npin của cấu trúc trên có thể được
được khởi tạo bằng hàm ZZ0001ZZ, ví dụ: cho pin
nhóm "foo":

.. code-block:: c

	pinctrl_get_group_pins(pctl, "foo", &gpio_range.pins, &gpio_range.npins);

Khi các chức năng dành riêng cho GPIO trong hệ thống con điều khiển pin được gọi, những chức năng này
phạm vi sẽ được sử dụng để tra cứu bộ điều khiển pin thích hợp bằng cách kiểm tra
và khớp chốt với phạm vi chốt trên tất cả các bộ điều khiển. Khi một
Đã tìm thấy bộ điều khiển pin xử lý phạm vi khớp, các chức năng dành riêng cho GPIO
sẽ được gọi trên bộ điều khiển pin cụ thể đó.

Đối với tất cả các chức năng xử lý xu hướng pin, trộn pin, v.v., pin
hệ thống con bộ điều khiển sẽ tra cứu số pin tương ứng từ
bằng số gpio và sử dụng nội dung bên trong của phạm vi để lấy số pin. Sau
rằng, hệ thống con chuyển nó tới trình điều khiển pin, do đó trình điều khiển
sẽ nhận được một số pin trong phạm vi số được xử lý của nó. Hơn nữa nó cũng được thông qua
giá trị ID phạm vi, để bộ điều khiển pin biết phạm vi đó nên
xử lý.

Gọi ZZ0000ZZ từ trình điều khiển pinctrl là DEPRECATED. Xin vui lòng xem
phần 2.1 của ZZ0001ZZ về cách liên kết
trình điều khiển pinctrl và gpio.


Giao diện PINMUX
=================

Các cuộc gọi này sử dụng tiền tố đặt tên pinmux_*.  Không có cuộc gọi nào khác nên sử dụng cuộc gọi đó
tiền tố.


pinmuxing là gì?
==================

PINMUX, còn được gọi là padmux, ballmux, các chức năng thay thế hoặc chế độ nhiệm vụ
là một cách để các nhà cung cấp chip sản xuất một số loại gói điện sử dụng
một chốt vật lý nhất định (quả bóng, miếng đệm, ngón tay, v.v.) cho nhiều loại trừ lẫn nhau
chức năng, tùy thuộc vào ứng dụng. Bằng "ứng dụng" trong bối cảnh này
chúng tôi thường muốn nói đến cách hàn hoặc nối gói hàng vào một thiết bị điện tử
hệ thống, mặc dù khuôn khổ này cũng có thể thay đổi chức năng
vào thời gian chạy.

Dưới đây là ví dụ về chip PGA (Pin Grid Array) nhìn từ bên dưới::

A B C D E F G H
      +---+
   8 ZZ0000ZZ o o o o o o
      ZZ0001ZZ
   7 ZZ0002ZZ o o o o o o
      ZZ0003ZZ
   6 ZZ0004ZZ o o o o o o
      +---+---+
   5 ZZ0005ZZ o | ồ ồ ồ ồ
      +---+---+ +---+
   4 o o o o o o ZZ0006ZZ o
                              ZZ0007ZZ
   3 o o o o o o ZZ0008ZZ o
                              ZZ0009ZZ
   2 o o o o o o ZZ0010ZZ o
      +-------+-------+-------+---+---+
   1 ZZ0011ZZ hoặc ZZ0012ZZ hoặc ZZ0013ZZ
      +-------+-------+-------+---+---+

Đây không phải là tetris. Trò chơi cần nghĩ đến là cờ vua. Không phải tất cả các gói PGA/BGA
giống như bàn cờ, những cái lớn có những “lỗ” được sắp xếp theo
các mẫu thiết kế khác nhau, nhưng chúng tôi đang sử dụng mẫu này làm ví dụ đơn giản. của
các chân mà bạn thấy một số sẽ được lấy bởi những thứ như VCC và GND để cấp nguồn
vào chip và một số ít sẽ được xử lý bởi các cổng lớn như cổng ngoài
giao diện bộ nhớ Các chân còn lại thường sẽ phải ghép kênh chân.

Gói 8x8 PGA ví dụ ở trên sẽ có số pin từ 0 đến 63 được gán
tới các chân vật lý của nó. Nó sẽ đặt tên cho các chân { A1, A2, A3... H6, H7, H8 } bằng cách sử dụng
pinctrl_register_pins() và tập dữ liệu phù hợp như được hiển thị trước đó.

Trong gói 8x8 BGA này, các chân { A8, A7, A6, A5 } có thể được sử dụng làm cổng SPI
(đây là bốn chân: CLK, RXD, TXD, FRM). Trong trường hợp đó, chân B5 có thể được sử dụng làm
một số chân GPIO có mục đích chung. Tuy nhiên, trong một cài đặt khác, các chân { A5, B5 } có thể
được sử dụng làm cổng I2C (đây chỉ là hai chân: SCL, SDA). Không cần phải nói,
chúng tôi không thể sử dụng cổng SPI và cổng I2C cùng một lúc. Tuy nhiên bên trong
của gói, silicon thực hiện logic SPI có thể được định tuyến theo cách khác
ra trên các chân {G4, G3, G2, G1 }.

Ở hàng dưới cùng tại { A1, B1, C1, D1, E1, F1, G1, H1 } ta có cái gì đó
đặc biệt - đó là bus MMC bên ngoài có thể rộng 2, 4 hoặc 8 bit và nó sẽ
tiêu thụ lần lượt 2, 4 hoặc 8 chân, do đó, {A1, B1 } được lấy hoặc
{ A1, B1, C1, D1 } hoặc tất cả chúng. Nếu sử dụng hết 8 bit thì không thể sử dụng SPI
tất nhiên là cổng trên các chân {G4, G3, G2, G1 }.

Bằng cách này, các khối silicon có bên trong chip có thể được ghép kênh "trộn"
ra trên phạm vi pin khác nhau. Thông thường SoC hiện đại (hệ thống trên chip) sẽ
chứa một số khối silicon I2C, SPI, SDIO/MMC, v.v. có thể được định tuyến đến
các chân khác nhau bằng cài đặt pinmux.

Vì các chân I/O đa năng (GPIO) thường luôn bị thiếu hụt nên
phổ biến là có thể sử dụng hầu hết mọi chân cắm làm chân GPIO nếu hiện tại không có
được sử dụng bởi một số cổng I/O khác.


quy ước Pinmux
==================

Mục đích của chức năng pinmux trong hệ thống con bộ điều khiển pin là
trừu tượng và cung cấp cài đặt pinmux cho thiết bị bạn chọn để khởi tạo
trong cấu hình máy của bạn. Nó được lấy cảm hứng từ clk, GPIO và bộ điều chỉnh
các hệ thống con, do đó các thiết bị sẽ yêu cầu cài đặt mux của chúng, nhưng cũng có thể
để yêu cầu một mã pin, ví dụ: GPIO.

Các quy ước là:

- FUNCTIONS có thể được chuyển đổi vào và ra bởi trình điều khiển cư trú bằng chốt
  hệ thống con điều khiển trong thư mục ZZ0000ZZ của kernel. các
  trình điều khiển pin biết các chức năng có thể. Trong ví dụ trên bạn có thể
  xác định ba hàm pinmux, một cho spi, một cho i2c và một cho mmc.

- FUNCTIONS được coi là có thể đếm được từ 0 trong mảng một chiều.
  Trong trường hợp này, mảng có thể giống như sau: { spi0, i2c0, mmc0 }
  cho ba chức năng có sẵn.

- FUNCTIONS có PIN GROUPS như được xác định ở cấp độ chung - vì vậy nhất định
  chức năng là ZZ0000ZZ được liên kết với một tập hợp các nhóm chân nhất định, có thể
  chỉ là một, nhưng cũng có thể là nhiều. Trong ví dụ trên
  hàm i2c được liên kết với các chân { A5, B5 }, được liệt kê là
  { 24, 25 } trong không gian chân điều khiển.

Chức năng spi được liên kết với các nhóm chân { A8, A7, A6, A5 }
  và {G4, G3, G2, G1 } được liệt kê là {0, 8, 16, 24 } và
  {38, 46, 54, 62 } tương ứng.

Tên nhóm phải là duy nhất cho mỗi bộ điều khiển pin, không có hai nhóm trên cùng một nhóm
  bộ điều khiển có thể có cùng tên.

- Sự kết hợp giữa FUNCTION và PIN GROUP xác định một chức năng nhất định
  cho một bộ chân nhất định. Kiến thức về chức năng và nhóm chân
  và các chi tiết cụ thể về máy của chúng được lưu giữ bên trong trình điều khiển pinmux,
  từ bên ngoài chỉ có các điều tra viên được biết và lõi trình điều khiển có thể
  yêu cầu:

- Tên hàm có selector nhất định (>= 0)
  - Danh sách các nhóm liên kết với một chức năng nhất định
  - Rằng một nhóm nhất định trong danh sách đó sẽ được kích hoạt cho một chức năng nhất định

Như đã mô tả ở trên, các nhóm chốt lần lượt có tính tự mô tả, do đó
  lõi sẽ lấy phạm vi pin thực tế trong một nhóm nhất định từ
  người lái xe.

- FUNCTIONS và GROUPS trên một PIN CONTROLLER nhất định là MAPPED ở một số nhất định
  thiết bị theo tệp bảng, cây thiết bị hoặc cấu hình thiết lập máy tương tự
  cơ chế, tương tự như cách các bộ điều chỉnh được kết nối với các thiết bị, thường bằng
  tên. Xác định bộ điều khiển chân, chức năng và nhóm để xác định duy nhất
  tập hợp các chân được sử dụng bởi một thiết bị nhất định. (Nếu chỉ có một nhóm có thể
  số lượng chân có sẵn cho chức năng này, không cần cung cấp tên nhóm -
  lõi sẽ chỉ chọn nhóm đầu tiên và duy nhất có sẵn.)

Trong trường hợp ví dụ, chúng ta có thể định nghĩa rằng chiếc máy cụ thể này sẽ
  sử dụng thiết bị spi0 với chức năng pinmux fspi0 nhóm gspi0 và i2c0 trên chức năng
  nhóm fi2c0 gi2c0, trên bộ điều khiển pin chính, chúng tôi nhận được ánh xạ
  như thế này:

  .. code-block:: c

{
		{"map-spi0", spi0, pinctrl0, fspi0, gspi0},
		{"map-i2c0", i2c0, pinctrl0, fi2c0, gi2c0},
	}

Mỗi bản đồ phải được gán một tên trạng thái, bộ điều khiển pin, thiết bị và
  chức năng. Nhóm này không bắt buộc - nếu nó bị bỏ qua nhóm đầu tiên
  do trình điều khiển trình bày khi áp dụng cho chức năng sẽ được chọn,
  rất hữu ích cho các trường hợp đơn giản.

Có thể ánh xạ một số nhóm tới cùng một tổ hợp thiết bị,
  chức năng và bộ điều khiển chân cắm. Điều này dành cho trường hợp một chức năng nhất định trên
  một bộ điều khiển chân nhất định có thể sử dụng các bộ chân khác nhau theo các cách khác nhau
  cấu hình.

- PINS cho một FUNCTION nhất định sử dụng một PIN GROUP nhất định trên một PIN nhất định
  PIN CONTROLLER được cung cấp trên cơ sở ai đến trước được phục vụ trước, vì vậy nếu một số
  cài đặt mux thiết bị khác hoặc yêu cầu mã pin GPIO đã chiếm dụng vật lý của bạn
  pin, bạn sẽ bị từ chối sử dụng nó. Để có được (kích hoạt) một cài đặt mới,
  cái cũ phải được đặt (hủy kích hoạt) trước.

Đôi khi các thanh ghi tài liệu và phần cứng sẽ được định hướng xung quanh
miếng đệm (hoặc "ngón tay") chứ không phải là ghim - đây là các bề mặt hàn trên
silicon bên trong gói hàng và có thể khớp hoặc không khớp với số lượng thực tế
ghim/quả bóng bên dưới viên nang. Chọn một số liệt kê có ý nghĩa để
bạn. Chỉ xác định các điều tra viên cho các chân mà bạn có thể kiểm soát nếu điều đó hợp lý.

Giả định:

Chúng tôi giả định rằng số lượng sơ đồ chức năng có thể có cho các nhóm ghim bị giới hạn bởi
phần cứng. tức là chúng ta giả định rằng không có hệ thống nào có thể thực hiện được bất kỳ chức năng nào
được ánh xạ tới bất kỳ mã pin nào, giống như trong trao đổi điện thoại. Vì vậy, các nhóm chân có sẵn cho
một chức năng nhất định sẽ bị giới hạn ở một vài lựa chọn (có thể lên tới tám hoặc hơn),
không phải hàng trăm hay bất kỳ số lượng lựa chọn nào. Đây là đặc điểm chúng tôi đã tìm thấy
bằng cách kiểm tra phần cứng pinmux có sẵn và một giả định cần thiết vì chúng tôi
mong đợi trình điều khiển pinmux hiển thị chức năng có thể có của ZZ0000ZZ so với ánh xạ nhóm pin
tới hệ thống con.


Trình điều khiển Pinmux
==============

Lõi pinmux đảm nhiệm việc ngăn chặn xung đột trên các chân và gọi
trình điều khiển bộ điều khiển pin để thực hiện các cài đặt khác nhau.

Trình điều khiển pinmux có trách nhiệm áp đặt thêm các hạn chế
(ví dụ: suy ra các giới hạn điện tử do tải, v.v.) để xác định
chức năng được yêu cầu có thực sự được cho phép hay không và trong trường hợp nó
có thể thực hiện cài đặt mux được yêu cầu, chọc vào phần cứng để
điều này xảy ra.

Trình điều khiển Pinmux được yêu cầu cung cấp một số chức năng gọi lại, một số chức năng
tùy chọn. Thông thường hàm ZZ0000ZZ được triển khai, ghi các giá trị vào
một số thanh ghi nhất định để kích hoạt một cài đặt mux nhất định cho một mã pin nhất định.

Trình điều khiển đơn giản cho ví dụ trên sẽ hoạt động bằng cách đặt các bit 0, 1, 2, 3, 4 hoặc 5
vào một số thanh ghi có tên MUX để chọn một chức năng nhất định với một giá trị nhất định
nhóm chân sẽ hoạt động như thế này:

.. code-block:: c

	#include <linux/pinctrl/pinctrl.h>
	#include <linux/pinctrl/pinmux.h>

	static const unsigned int spi0_0_pins[] = { 0, 8, 16, 24 };
	static const unsigned int spi0_1_pins[] = { 38, 46, 54, 62 };
	static const unsigned int i2c0_pins[] = { 24, 25 };
	static const unsigned int mmc0_1_pins[] = { 56, 57 };
	static const unsigned int mmc0_2_pins[] = { 58, 59 };
	static const unsigned int mmc0_3_pins[] = { 60, 61, 62, 63 };

	static const struct pingroup foo_groups[] = {
		PINCTRL_PINGROUP("spi0_0_grp", spi0_0_pins, ARRAY_SIZE(spi0_0_pins)),
		PINCTRL_PINGROUP("spi0_1_grp", spi0_1_pins, ARRAY_SIZE(spi0_1_pins)),
		PINCTRL_PINGROUP("i2c0_grp", i2c0_pins, ARRAY_SIZE(i2c0_pins)),
		PINCTRL_PINGROUP("mmc0_1_grp", mmc0_1_pins, ARRAY_SIZE(mmc0_1_pins)),
		PINCTRL_PINGROUP("mmc0_2_grp", mmc0_2_pins, ARRAY_SIZE(mmc0_2_pins)),
		PINCTRL_PINGROUP("mmc0_3_grp", mmc0_3_pins, ARRAY_SIZE(mmc0_3_pins)),
	};

	static int foo_get_groups_count(struct pinctrl_dev *pctldev)
	{
		return ARRAY_SIZE(foo_groups);
	}

	static const char *foo_get_group_name(struct pinctrl_dev *pctldev,
					      unsigned int selector)
	{
		return foo_groups[selector].name;
	}

	static int foo_get_group_pins(struct pinctrl_dev *pctldev, unsigned int selector,
				      const unsigned int **pins,
				      unsigned int *npins)
	{
		*pins = foo_groups[selector].pins;
		*npins = foo_groups[selector].npins;
		return 0;
	}

	static struct pinctrl_ops foo_pctrl_ops = {
		.get_groups_count = foo_get_groups_count,
		.get_group_name = foo_get_group_name,
		.get_group_pins = foo_get_group_pins,
	};

	static const char * const spi0_groups[] = { "spi0_0_grp", "spi0_1_grp" };
	static const char * const i2c0_groups[] = { "i2c0_grp" };
	static const char * const mmc0_groups[] = { "mmc0_1_grp", "mmc0_2_grp", "mmc0_3_grp" };

	static const struct pinfunction foo_functions[] = {
		PINCTRL_PINFUNCTION("spi0", spi0_groups, ARRAY_SIZE(spi0_groups)),
		PINCTRL_PINFUNCTION("i2c0", i2c0_groups, ARRAY_SIZE(i2c0_groups)),
		PINCTRL_PINFUNCTION("mmc0", mmc0_groups, ARRAY_SIZE(mmc0_groups)),
	};

	static int foo_get_functions_count(struct pinctrl_dev *pctldev)
	{
		return ARRAY_SIZE(foo_functions);
	}

	static const char *foo_get_fname(struct pinctrl_dev *pctldev, unsigned int selector)
	{
		return foo_functions[selector].name;
	}

	static int foo_get_groups(struct pinctrl_dev *pctldev, unsigned int selector,
				  const char * const **groups,
				  unsigned int * const ngroups)
	{
		*groups = foo_functions[selector].groups;
		*ngroups = foo_functions[selector].ngroups;
		return 0;
	}

	static int foo_set_mux(struct pinctrl_dev *pctldev, unsigned int selector,
			       unsigned int group)
	{
		u8 regbit = BIT(group);

		writeb((readb(MUX) | regbit), MUX);
		return 0;
	}

	static struct pinmux_ops foo_pmxops = {
		.get_functions_count = foo_get_functions_count,
		.get_function_name = foo_get_fname,
		.get_function_groups = foo_get_groups,
		.set_mux = foo_set_mux,
		.strict = true,
	};

	/* Pinmux operations are handled by some pin controller */
	static struct pinctrl_desc foo_desc = {
		...
		.pctlops = &foo_pctrl_ops,
		.pmxops = &foo_pmxops,
	};

Trong ví dụ kích hoạt trộn 0 và 2 cùng lúc các bit cài đặt
0 và 2, sử dụng chung chân 24 nên chúng sẽ xung đột. Tất cả đều giống nhau đối với
mux 1 và 5 có chung chân 62.

Cái hay của hệ thống con pinmux là vì nó theo dõi tất cả
ghim và ai đang sử dụng chúng, nó sẽ từ chối một điều không thể
yêu cầu như vậy thì tài xế không cần phải lo lắng về điều đó
mọi thứ - khi nó nhận được một bộ chọn được truyền vào, hệ thống con pinmux sẽ thực hiện
chắc chắn không có thiết bị nào khác hoặc nhiệm vụ GPIO đang sử dụng thiết bị đã chọn
ghim. Do đó các bit 0 và 2, hoặc 1 và 5 trong thanh ghi điều khiển sẽ không bao giờ
được thiết lập cùng một lúc.

Tất cả các chức năng trên là bắt buộc phải triển khai đối với trình điều khiển pinmux.


Tương tác điều khiển pin với hệ thống con GPIO
===============================================

Lưu ý rằng những điều sau đây ngụ ý rằng trường hợp sử dụng là sử dụng một mã pin nhất định
từ nhân Linux sử dụng API trong ZZ0000ZZ với gpiod_get()
và các chức năng tương tự. Có những trường hợp bạn có thể đang sử dụng thứ gì đó
mà biểu dữ liệu của bạn gọi là "Chế độ GPIO", nhưng thực ra chỉ là một chế độ điện
cấu hình cho một thiết bị nhất định. Xem phần bên dưới có tên
ZZ0001ZZ để biết thêm chi tiết về tình huống này.

Pinmux công khai API chứa hai hàm có tên ZZ0000ZZ
và ZZ0001ZZ. Hai hàm này sẽ được gọi ZZ0008ZZ từ
trình điều khiển dựa trên gpiolib như một phần của ngữ nghĩa ZZ0002ZZ và ZZ0003ZZ của chúng.
Tương tự như vậy ZZ0004ZZ / ZZ0005ZZ
sẽ chỉ được gọi từ bên trong ZZ0006ZZ /
Triển khai gpiolib ZZ0007ZZ.

NOTE rằng các nền tảng và trình điều khiển riêng lẻ sẽ ZZ0000ZZ yêu cầu các chân GPIO được
được kiểm soát, ví dụ: được trộn vào. Thay vào đó, hãy triển khai trình điều khiển gpiolib thích hợp và có
trình điều khiển đó yêu cầu chuyển đổi thích hợp và các biện pháp kiểm soát khác cho các chân của nó.

Danh sách chức năng có thể dài, đặc biệt nếu bạn có thể chuyển đổi mọi
ghim riêng lẻ vào ghim GPIO độc lập với bất kỳ ghim nào khác, sau đó thử
cách tiếp cận để xác định mỗi chân là một hàm.

Trong trường hợp này, mảng chức năng sẽ trở thành 64 mục cho mỗi GPIO
cài đặt và sau đó thiết bị sẽ hoạt động.

Vì lý do này, có hai chức năng mà trình điều khiển pin có thể thực hiện
để chỉ kích hoạt GPIO trên một pin riêng lẻ: ZZ0000ZZ và
ZZ0001ZZ.

Chức năng này sẽ vượt qua trong phạm vi GPIO bị ảnh hưởng được xác định bởi pin
lõi điều khiển, để bạn biết chân GPIO nào đang bị ảnh hưởng bởi yêu cầu
hoạt động.

Nếu trình điều khiển của bạn cần có dấu hiệu từ hệ thống về việc liệu
Chân GPIO sẽ được sử dụng cho đầu vào hoặc đầu ra mà bạn có thể thực hiện
Chức năng ZZ0000ZZ. Như được mô tả, điều này sẽ được gọi từ
trình điều khiển gpiolib và phạm vi GPIO bị ảnh hưởng, độ lệch chân và hướng mong muốn
sẽ được chuyển đến chức năng này.

Ngoài ra, ngoài việc sử dụng các chức năng đặc biệt này, nó hoàn toàn được phép sử dụng
các chức năng được đặt tên cho mỗi chân GPIO, ZZ0000ZZ sẽ cố gắng
lấy hàm "gpioN" trong đó "N" là số pin GPIO toàn cầu nếu không
trình xử lý GPIO đặc biệt đã được đăng ký.


Cạm bẫy của chế độ GPIO
==================

Do quy ước đặt tên được sử dụng bởi các kỹ sư phần cứng, trong đó "GPIO"
được hiểu là có ý nghĩa khác với những gì hạt nhân làm, nhà phát triển
có thể bị nhầm lẫn bởi biểu dữ liệu nói về việc có thể đặt mã pin
vào "Chế độ GPIO". Có vẻ như ý của các kỹ sư phần cứng là
"Chế độ GPIO" không nhất thiết phải là trường hợp sử dụng được ngụ ý trong kernel
giao diện ZZ0000ZZ: một mã pin mà bạn lấy từ mã hạt nhân và sau đó
lắng nghe đầu vào hoặc điều khiển cao/thấp để xác nhận/xác nhận lại một số
đường dây bên ngoài.

Thay vào đó, các kỹ sư phần cứng nghĩ rằng "Chế độ GPIO" có nghĩa là bạn có thể
phần mềm kiểm soát một số đặc tính điện của chân cắm mà bạn sẽ
không thể kiểm soát xem pin có ở chế độ nào khác hay không, chẳng hạn như được kết hợp trong
cho một thiết bị.

Các phần GPIO của một chân và mối quan hệ của nó với bộ điều khiển chân nhất định
cấu hình và logic chuyển đổi có thể được xây dựng theo nhiều cách. đây
là hai ví dụ.

Ví dụ ZZ0000ZZ::

cấu hình ghim
                       quy định logic
                       |               +- SPI
     Chân vật lý --- pad --- pinmux -+- I2C
                               |       +- ừm
                               |       +- GPIO
                               ghim
                               ghép kênh
                               quy định logic

Ở đây một số đặc tính điện của pin có thể được cấu hình bất kể
liệu pin có được sử dụng cho GPIO hay không. Nếu bạn ghép một GPIO vào một
pin, bạn cũng có thể điều khiển nó lên cao/thấp từ thanh ghi "GPIO".
Ngoài ra, chân có thể được điều khiển bởi một thiết bị ngoại vi nhất định, trong khi
vẫn áp dụng các thuộc tính cấu hình pin mong muốn. Do đó, chức năng của GPIO là
trực giao với bất kỳ thiết bị nào khác sử dụng pin.

Trong cách sắp xếp này, các thanh ghi cho các phần GPIO của bộ điều khiển chân,
hoặc các thanh ghi cho mô-đun phần cứng GPIO có thể nằm trong một
phạm vi bộ nhớ riêng biệt chỉ dành cho lái xe GPIO và thanh ghi
phạm vi xử lý cấu hình chân và ghép kênh chân được đặt vào một
phạm vi bộ nhớ khác nhau và một phần riêng biệt của bảng dữ liệu.

Cờ "nghiêm ngặt" trong struct pinmux_ops có sẵn để kiểm tra và từ chối
truy cập đồng thời vào cùng một pin từ GPIO và ghép kênh pin
người tiêu dùng trên phần cứng loại này. Trình điều khiển pinctrl nên đặt cờ này
tương ứng.

Ví dụ ZZ0000ZZ::

cấu hình ghim
                       quy định logic
                       |               +- SPI
     Chân vật lý --- pad --- pinmux -+- I2C
                       ZZ0000ZZ +- mmc
                       ZZ0001ZZ
                       Chân GPIO
                               ghép kênh
                               quy định logic

Trong cách sắp xếp này, chức năng GPIO luôn có thể được bật, sao cho
ví dụ: đầu vào GPIO có thể được sử dụng để "theo dõi" tín hiệu SPI/I2C/MMC trong khi nó đang hoạt động.
đập ra. Có khả năng có thể làm gián đoạn lưu lượng trên chốt bằng cách thực hiện
những điều sai trái trên khối GPIO, vì nó không bao giờ thực sự bị ngắt kết nối. Đó là
có thể các thanh ghi GPIO, cấu hình chân và ghép kênh chân được đặt vào
cùng một phạm vi bộ nhớ và cùng một phần của bảng dữ liệu, mặc dù
không cần phải như vậy.

Trong một số bộ điều khiển chân cắm, mặc dù các chân vật lý được thiết kế giống nhau
như (B), chức năng GPIO vẫn không thể được kích hoạt cùng lúc với
các chức năng ngoại vi. Vì vậy, một lần nữa cờ "nghiêm ngặt" nên được đặt, từ chối
kích hoạt đồng thời bởi GPIO và các thiết bị được kết hợp khác.

Tuy nhiên, từ quan điểm cốt lõi, đây là những khía cạnh khác nhau của
phần cứng và sẽ được đưa vào các hệ thống con khác nhau:

- Các thanh ghi (hoặc các trường trong thanh ghi) điều khiển điện
  các đặc tính của chốt như độ lệch và cường độ truyền động phải được
  được hiển thị thông qua hệ thống con pinctrl, dưới dạng cài đặt "cấu hình pin".

- Các thanh ghi (hoặc các trường trong các thanh ghi) điều khiển việc trộn tín hiệu
  từ nhiều khối CTNH khác (ví dụ: I2C, MMC hoặc GPIO) vào các chân sẽ
  được hiển thị thông qua hệ thống con pinctrl, dưới dạng các hàm mux.

- Các thanh ghi (hoặc các trường trong các thanh ghi) điều khiển chức năng GPIO
  chẳng hạn như đặt giá trị đầu ra của GPIO, đọc giá trị đầu vào của GPIO hoặc
  cài đặt hướng chân GPIO phải được hiển thị thông qua hệ thống con GPIO,
  và nếu chúng cũng hỗ trợ khả năng ngắt, thông qua irqchip
  trừu tượng.

Tùy thuộc vào thiết kế thanh ghi CTNH chính xác, một số chức năng được trình bày bởi
Hệ thống con GPIO có thể gọi vào hệ thống con pinctrl để
phối hợp cài đặt đăng ký trên các mô-đun CTNH. Đặc biệt, điều này có thể
cần thiết cho HW với các mô-đun HW của bộ điều khiển pin và GPIO riêng biệt, trong đó
ví dụ: Hướng GPIO được xác định bởi một thanh ghi trong bộ điều khiển chân HW
mô-đun thay vì mô-đun GPIO HW.

Các đặc tính điện của chốt như độ lệch và cường độ truyền động
có thể được đặt tại một số thanh ghi pin cụ thể trong mọi trường hợp hoặc như một phần
của thanh ghi GPIO trong trường hợp (B) đặc biệt. Điều này không có nghĩa là như vậy
các thuộc tính nhất thiết phải liên quan đến cái mà nhân Linux gọi là "GPIO".

Ví dụ: một chốt thường được trộn vào để sử dụng làm đường dây UART TX. Nhưng trong thời gian
hệ thống ngủ, chúng ta cần đặt chân này vào "chế độ GPIO" và nối đất cho nó.

Nếu bạn tạo bản đồ 1-1 tới hệ thống con GPIO cho mã pin này, bạn có thể bắt đầu
để nghĩ rằng bạn cần phải nghĩ ra thứ gì đó thực sự phức tạp, rằng
pin sẽ được sử dụng cùng lúc cho UART TX và GPIO mà bạn sẽ lấy
một chốt điều khiển và đặt nó ở một trạng thái nhất định để cho phép UART TX hoạt động
được trộn vào, sau đó chuyển nó sang chế độ GPIO và sử dụng gpiod_direction_output()
để giảm tốc độ trong khi ngủ, sau đó chuyển lại sang UART TX khi bạn
thức dậy và thậm chí có thể gpiod_get() / gpiod_put() như một phần của chu trình này. Cái này
tất cả trở nên rất phức tạp.

Giải pháp là đừng nghĩ rằng bảng dữ liệu gọi là "chế độ GPIO"
phải được xử lý bởi giao diện ZZ0000ZZ. Thay vào đó hãy xem đây là
một cài đặt cấu hình pin nhất định. Nhìn vào ví dụ. ZZ0001ZZ
và bạn tìm thấy điều này trong tài liệu:

PIN_CONFIG_LEVEL:
     điều này sẽ cấu hình pin ở đầu ra, sử dụng đối số
     1 để biểu thị mức cao, đối số 0 để biểu thị mức thấp.

Vì vậy, hoàn toàn có thể đẩy chốt vào "chế độ GPIO" và điều khiển
dòng thấp như một phần của bản đồ kiểm soát pin thông thường. Vì vậy, ví dụ UART của bạn
trình điều khiển có thể trông như thế này:

.. code-block:: c

	#include <linux/pinctrl/consumer.h>

	struct pinctrl          *pinctrl;
	struct pinctrl_state    *pins_default;
	struct pinctrl_state    *pins_sleep;

	pins_default = pinctrl_lookup_state(uap->pinctrl, PINCTRL_STATE_DEFAULT);
	pins_sleep = pinctrl_lookup_state(uap->pinctrl, PINCTRL_STATE_SLEEP);

	/* Normal mode */
	retval = pinctrl_select_state(pinctrl, pins_default);

	/* Sleep mode */
	retval = pinctrl_select_state(pinctrl, pins_sleep);

Và cấu hình máy của bạn có thể trông như thế này:

.. code-block:: c

	static unsigned long uart_default_mode[] = {
		PIN_CONF_PACKED(PIN_CONFIG_DRIVE_PUSH_PULL, 0),
	};

	static unsigned long uart_sleep_mode[] = {
		PIN_CONF_PACKED(PIN_CONFIG_LEVEL, 0),
	};

	static struct pinctrl_map pinmap[] __initdata = {
		PIN_MAP_MUX_GROUP("uart", PINCTRL_STATE_DEFAULT, "pinctrl-foo",
				  "u0_group", "u0"),
		PIN_MAP_CONFIGS_PIN("uart", PINCTRL_STATE_DEFAULT, "pinctrl-foo",
				    "UART_TX_PIN", uart_default_mode),
		PIN_MAP_MUX_GROUP("uart", PINCTRL_STATE_SLEEP, "pinctrl-foo",
				  "u0_group", "gpio-mode"),
		PIN_MAP_CONFIGS_PIN("uart", PINCTRL_STATE_SLEEP, "pinctrl-foo",
				    "UART_TX_PIN", uart_sleep_mode),
	};

	foo_init(void)
	{
		pinctrl_register_mappings(pinmap, ARRAY_SIZE(pinmap));
	}

Ở đây, các chân mà chúng ta muốn điều khiển nằm trong "u0_group" và có một số
chức năng được gọi là "u0" có thể được kích hoạt trên nhóm chân này, sau đó
mọi thứ UART vẫn hoạt động bình thường. Nhưng cũng có một số chức năng
được đặt tên là "gpio-mode" có thể được ánh xạ lên cùng các chân để di chuyển chúng vào
Chế độ GPIO.

Điều này sẽ mang lại hiệu quả mong muốn mà không có bất kỳ tương tác không có thật nào với
Hệ thống con GPIO. Nó chỉ là một cấu hình điện được sử dụng bởi thiết bị đó
khi đi ngủ, điều đó có thể ám chỉ rằng chiếc ghim đã được đặt vào vật gì đó
biểu dữ liệu gọi "Chế độ GPIO", nhưng đó không phải là vấn đề: nó vẫn được sử dụng
bởi thiết bị UART đó để điều khiển các chân liên quan đến chính UART đó
trình điều khiển, đưa chúng vào các chế độ cần thiết cho UART. GPIO trong Linux
ý nghĩa hạt nhân chỉ là một số dòng 1 bit và là một trường hợp sử dụng khác.

Cách các thanh ghi được chọc vào để đạt được lực đẩy hoặc kéo và đầu ra ở mức thấp
cấu hình và trộn nhóm "u0" hoặc "gpio-mode" vào các nhóm này
chân là một câu hỏi cho người lái xe.

Một số bảng dữ liệu sẽ hữu ích hơn và đề cập đến "chế độ GPIO" như
"chế độ năng lượng thấp" thay vì bất cứ điều gì liên quan đến GPIO. Điều này thường có nghĩa
điều tương tự nói về mặt điện, nhưng trong trường hợp sau này
các kỹ sư phần mềm thường sẽ nhanh chóng xác định rằng đây là một số
chuyển đổi hoặc cấu hình cụ thể hơn là bất kỳ thứ gì liên quan đến GPIO
API.


Cấu hình bo mạch/máy
===========================

Các bo mạch và máy móc xác định cách cài đặt một hệ thống chạy hoàn chỉnh nhất định
với nhau, bao gồm cách kết hợp các GPIO và thiết bị, cách các cơ quan quản lý hoạt động
bị hạn chế và cây đồng hồ trông như thế nào. Tất nhiên cài đặt pinmux cũng
một phần của điều này.

Cấu hình bộ điều khiển chân cho một máy trông khá giống một cấu hình đơn giản.
cấu hình bộ điều chỉnh, vì vậy đối với mảng ví dụ ở trên, chúng tôi muốn kích hoạt i2c
và spi trên ánh xạ hàm thứ hai:

.. code-block:: c

	#include <linux/pinctrl/machine.h>

	static const struct pinctrl_map mapping[] __initconst = {
		{
			.dev_name = "foo-spi.0",
			.name = PINCTRL_STATE_DEFAULT,
			.type = PIN_MAP_TYPE_MUX_GROUP,
			.ctrl_dev_name = "pinctrl-foo",
			.data.mux.function = "spi0",
		},
		{
			.dev_name = "foo-i2c.0",
			.name = PINCTRL_STATE_DEFAULT,
			.type = PIN_MAP_TYPE_MUX_GROUP,
			.ctrl_dev_name = "pinctrl-foo",
			.data.mux.function = "i2c0",
		},
		{
			.dev_name = "foo-mmc.0",
			.name = PINCTRL_STATE_DEFAULT,
			.type = PIN_MAP_TYPE_MUX_GROUP,
			.ctrl_dev_name = "pinctrl-foo",
			.data.mux.function = "mmc0",
		},
	};

Dev_name ở đây khớp với tên thiết bị duy nhất có thể được sử dụng để xem
lên cấu trúc thiết bị (giống như với clockdev hoặc bộ điều chỉnh). Tên chức năng
phải phù hợp với chức năng được cung cấp bởi trình điều khiển pinmux xử lý phạm vi chân này.

Như bạn có thể thấy, chúng ta có thể có một số bộ điều khiển pin trên hệ thống và do đó
chúng ta cần chỉ định cái nào trong số chúng chứa các hàm mà chúng ta muốn ánh xạ.

Bạn đăng ký ánh xạ pinmux này vào hệ thống con pinmux chỉ bằng cách:

.. code-block:: c

       ret = pinctrl_register_mappings(mapping, ARRAY_SIZE(mapping));

Vì cấu trúc trên khá phổ biến nên có một macro trợ giúp để thực hiện
nó thậm chí còn nhỏ gọn hơn, giả sử bạn muốn sử dụng pinctrl-foo và định vị
0 để lập bản đồ, ví dụ:

.. code-block:: c

	static struct pinctrl_map mapping[] __initdata = {
		PIN_MAP_MUX_GROUP("foo-i2c.0", PINCTRL_STATE_DEFAULT,
				  "pinctrl-foo", NULL, "i2c0"),
	};

Bảng ánh xạ cũng có thể chứa các mục cấu hình pin. Nó phổ biến đối với
mỗi pin/nhóm có một số mục cấu hình ảnh hưởng đến nó, vì vậy
các mục trong bảng để tham chiếu cấu hình một mảng các tham số cấu hình
và các giá trị. Một ví dụ sử dụng macro tiện lợi được hiển thị bên dưới:

.. code-block:: c

	static unsigned long i2c_grp_configs[] = {
		FOO_PIN_DRIVEN,
		FOO_PIN_PULLUP,
	};

	static unsigned long i2c_pin_configs[] = {
		FOO_OPEN_COLLECTOR,
		FOO_SLEW_RATE_SLOW,
	};

	static struct pinctrl_map mapping[] __initdata = {
		PIN_MAP_MUX_GROUP("foo-i2c.0", PINCTRL_STATE_DEFAULT,
				  "pinctrl-foo", "i2c0", "i2c0"),
		PIN_MAP_CONFIGS_GROUP("foo-i2c.0", PINCTRL_STATE_DEFAULT,
				      "pinctrl-foo", "i2c0", i2c_grp_configs),
		PIN_MAP_CONFIGS_PIN("foo-i2c.0", PINCTRL_STATE_DEFAULT,
				    "pinctrl-foo", "i2c0scl", i2c_pin_configs),
		PIN_MAP_CONFIGS_PIN("foo-i2c.0", PINCTRL_STATE_DEFAULT,
				    "pinctrl-foo", "i2c0sda", i2c_pin_configs),
	};

Cuối cùng, một số thiết bị mong muốn bảng ánh xạ chứa một số thông tin cụ thể
các tiểu bang được đặt tên. Khi chạy trên phần cứng không cần bất kỳ bộ điều khiển pin nào
cấu hình, bảng ánh xạ vẫn phải chứa các trạng thái được đặt tên đó, trong
để chỉ rõ ràng rằng các trạng thái đã được cung cấp và nhằm mục đích
hãy trống rỗng. Macro mục nhập bảng ZZ0000ZZ phục vụ mục đích xác định
một trạng thái được đặt tên mà không khiến bất kỳ bộ điều khiển pin nào được lập trình:

.. code-block:: c

	static struct pinctrl_map mapping[] __initdata = {
		PIN_MAP_DUMMY_STATE("foo-i2c.0", PINCTRL_STATE_DEFAULT),
	};


Ánh xạ phức tạp
================

Vì có thể ánh xạ một chức năng tới các nhóm chân khác nhau, một tùy chọn
.group có thể được chỉ định như thế này:

.. code-block:: c

	...
	{
		.dev_name = "foo-spi.0",
		.name = "spi0-pos-A",
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "spi0",
		.group = "spi0_0_grp",
	},
	{
		.dev_name = "foo-spi.0",
		.name = "spi0-pos-B",
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "spi0",
		.group = "spi0_1_grp",
	},
	...

Ánh xạ ví dụ này được sử dụng để chuyển đổi giữa hai vị trí cho spi0 tại
thời gian chạy, như được mô tả thêm bên dưới dưới tiêu đề ZZ0000ZZ.

Hơn nữa, một trạng thái được đặt tên có thể ảnh hưởng đến việc trộn lẫn một số
các nhóm chân, chẳng hạn như trong ví dụ mmc0 ở trên, nơi bạn có thể
mở rộng thêm bus mmc0 từ 2 lên 4 đến 8 chân. Nếu chúng ta muốn sử dụng tất cả
ba nhóm với tổng số 2 + 2 + 4 = 8 chân (đối với bus MMC 8 bit cũng như
trường hợp), chúng tôi xác định ánh xạ như thế này:

.. code-block:: c

	...
	{
		.dev_name = "foo-mmc.0",
		.name = "2bit"
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "mmc0",
		.group = "mmc0_1_grp",
	},
	{
		.dev_name = "foo-mmc.0",
		.name = "4bit"
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "mmc0",
		.group = "mmc0_1_grp",
	},
	{
		.dev_name = "foo-mmc.0",
		.name = "4bit"
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "mmc0",
		.group = "mmc0_2_grp",
	},
	{
		.dev_name = "foo-mmc.0",
		.name = "8bit"
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "mmc0",
		.group = "mmc0_1_grp",
	},
	{
		.dev_name = "foo-mmc.0",
		.name = "8bit"
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "mmc0",
		.group = "mmc0_2_grp",
	},
	{
		.dev_name = "foo-mmc.0",
		.name = "8bit"
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "mmc0",
		.group = "mmc0_3_grp",
	},
	...

Kết quả của việc lấy ánh xạ này từ thiết bị có nội dung như
cái này (xem đoạn tiếp theo):

.. code-block:: c

	p = devm_pinctrl_get(dev);
	s = pinctrl_lookup_state(p, "8bit");
	ret = pinctrl_select_state(p, s);

hoặc đơn giản hơn:

.. code-block:: c

	p = devm_pinctrl_get_select(dev, "8bit");

Sẽ là bạn kích hoạt tất cả ba bản ghi dưới cùng trong ánh xạ tại
một lần. Vì chúng có cùng tên, thiết bị điều khiển pin, chức năng và
thiết bị và vì chúng tôi cho phép nhiều nhóm khớp với một thiết bị duy nhất nên chúng
tất cả đều được chọn và tất cả chúng đều được kích hoạt và vô hiệu hóa đồng thời bởi
lõi pinmux.


Yêu cầu kiểm soát mã pin từ trình điều khiển
=================================

Khi trình điều khiển thiết bị chuẩn bị thăm dò, lõi thiết bị sẽ gắn
trạng thái tiêu chuẩn nếu chúng được xác định trong cây thiết bị bằng cách gọi
ZZ0000ZZ trên các thiết bị này.
Tên trạng thái tiêu chuẩn có thể có là: "mặc định", "init", "ngủ" và "không hoạt động".

- nếu ZZ0000ZZ được xác định trong cây thiết bị, nó sẽ được chọn trước
  đầu dò thiết bị.

- nếu ZZ0000ZZ và ZZ0001ZZ được xác định trong cây thiết bị, "init"
  trạng thái được chọn trước đầu dò trình điều khiển và trạng thái "mặc định" là
  được chọn sau khi thăm dò trình điều khiển.

- trạng thái ZZ0000ZZ và ZZ0001ZZ dành cho quản lý nguồn và chỉ có thể
  được chọn bằng PM API bên dưới.

Giao diện PM
=================
Tạm dừng/tiếp tục thời gian chạy PM có thể cần phải thực thi trình tự init giống như
trong quá trình thăm dò. Vì các trạng thái được xác định trước đã được gắn vào
thiết bị, trình điều khiển có thể kích hoạt các trạng thái này một cách rõ ràng bằng
các chức năng trợ giúp sau:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ

Ví dụ: nếu việc tiếp tục thiết bị phụ thuộc vào một số trạng thái pinmux nhất định

.. code-block:: c

	foo_suspend()
	{
		/* suspend device */
		...

		pinctrl_pm_select_sleep_state(dev);
	}

	foo_resume()
	{
		pinctrl_pm_select_init_state(dev);

		/* resuming device */
		...

		pinctrl_pm_select_default_state(dev);
	}

Bằng cách này, người viết trình điều khiển không cần thêm bất kỳ mã soạn sẵn nào
thuộc loại được tìm thấy dưới đây. Tuy nhiên, khi thực hiện lựa chọn trạng thái chi tiết
và không sử dụng trạng thái "mặc định", bạn có thể phải thực hiện một số trình điều khiển thiết bị
xử lý các trạng thái và tay cầm pinctrl.

Vì vậy nếu bạn chỉ muốn đặt các chân cho một thiết bị nào đó vào mặc định
nêu rõ và hoàn thành nó, bạn không cần phải làm gì ngoài việc
cung cấp bảng ánh xạ thích hợp. Lõi thiết bị sẽ đảm nhiệm
phần còn lại.

Nói chung, không nên để các trình điều khiển riêng lẻ nhận và kích hoạt mã pin
kiểm soát. Vì vậy, nếu có thể, hãy xử lý điều khiển pin trong mã nền tảng hoặc một số mã khác
nơi bạn có quyền truy cập vào tất cả các con trỏ * thiết bị cấu trúc bị ảnh hưởng. trong
một số trường hợp người lái xe cần phải làm vậy. chuyển đổi giữa các ánh xạ mux khác nhau
trong thời gian chạy, điều này là không thể.

Một trường hợp điển hình là nếu người lái xe cần chuyển độ lệch của các chân từ bình thường sang
hoạt động và chuyển sang chế độ ngủ, chuyển từ ZZ0000ZZ sang
ZZ0001ZZ trong thời gian chạy, phân cực lại hoặc thậm chí trộn lại các chân để tiết kiệm
hiện tại ở chế độ ngủ.

Một trường hợp khác là khi pinctrl cần chuyển sang một chế độ nhất định trong
thăm dò và sau đó trở lại trạng thái mặc định ở cuối thăm dò. Ví dụ
PINMUX có thể cần được cấu hình là GPIO trong quá trình thăm dò. Trong trường hợp này, sử dụng
ZZ0000ZZ để chuyển trạng thái trước khi thăm dò, sau đó chuyển sang
ZZ0001ZZ ở cuối đầu dò để hoạt động bình thường.

Người lái xe có thể yêu cầu kích hoạt một trạng thái điều khiển nhất định, thường chỉ là
trạng thái mặc định như thế này:

.. code-block:: c

	#include <linux/pinctrl/consumer.h>

	struct foo_state {
	struct pinctrl *p;
	struct pinctrl_state *s;
	...
	};

	foo_probe()
	{
		/* Allocate a state holder named "foo" etc */
		struct foo_state *foo = ...;
		int ret;

		foo->p = devm_pinctrl_get(&device);
		if (IS_ERR(foo->p)) {
			ret = PTR_ERR(foo->p);
			foo->p = NULL;
			return ret;
		}

		foo->s = pinctrl_lookup_state(foo->p, PINCTRL_STATE_DEFAULT);
		if (IS_ERR(foo->s)) {
			devm_pinctrl_put(foo->p);
			return PTR_ERR(foo->s);
		}

		ret = pinctrl_select_state(foo->p, foo->s);
		if (ret < 0) {
			devm_pinctrl_put(foo->p);
			return ret;
		}
	}

Trình tự nhận/tra cứu/chọn/đặt này cũng có thể được xử lý bởi trình điều khiển xe buýt
nếu bạn không muốn mỗi người lái xe xử lý việc đó và bạn biết
sắp xếp trên xe buýt của bạn.

Ngữ nghĩa của API pinctrl là:

- ZZ0000ZZ được gọi trong ngữ cảnh quy trình để xử lý tất cả pinctrl
  thông tin cho một thiết bị khách hàng nhất định. Nó sẽ phân bổ một cấu trúc từ
  bộ nhớ kernel để giữ trạng thái pinmux. Tất cả phân tích cú pháp bảng ánh xạ hoặc tương tự
  hoạt động chậm diễn ra trong API này.

- ZZ0000ZZ là một biến thể của pinctrl_get() gây ra ZZ0001ZZ
  được gọi tự động trên con trỏ được truy xuất khi liên kết
  thiết bị được gỡ bỏ. Nên sử dụng chức năng này trên đồng bằng
  ZZ0002ZZ.

- ZZ0000ZZ được gọi trong ngữ cảnh tiến trình để có được một điều khiển cho một
  trạng thái cụ thể cho một thiết bị khách. Hoạt động này cũng có thể chậm.

- ZZ0000ZZ lập trình phần cứng bộ điều khiển chân cắm theo
  định nghĩa trạng thái được đưa ra bởi bảng ánh xạ. Về lý thuyết, đây là một
  hoạt động đường dẫn nhanh, vì nó chỉ liên quan đến việc làm hỏng một số cài đặt đăng ký
  vào phần cứng. Tuy nhiên, lưu ý rằng một số bộ điều khiển pin có thể có
  đăng ký trên xe buýt dựa trên chậm/IRQ, vì vậy các thiết bị khách không nên cho rằng chúng
  có thể gọi ZZ0001ZZ từ ngữ cảnh không chặn.

- ZZ0000ZZ giải phóng tất cả thông tin liên quan đến tay cầm pinctrl.

- ZZ0000ZZ là một biến thể của ZZ0001ZZ có thể được sử dụng để
  tiêu diệt rõ ràng một đối tượng pinctrl được trả về bởi ZZ0002ZZ.
  Tuy nhiên, sẽ hiếm khi sử dụng chức năng này do tính năng dọn dẹp tự động
  điều đó sẽ xảy ra ngay cả khi không gọi nó.

ZZ0000ZZ phải được ghép nối với ZZ0001ZZ đơn giản.
  ZZ0002ZZ có thể không được ghép nối với ZZ0003ZZ.
  ZZ0004ZZ có thể được ghép nối tùy chọn với ZZ0005ZZ.
  ZZ0006ZZ có thể không được ghép nối với ZZ0007ZZ đơn giản.

Thông thường, lõi điều khiển pin xử lý cặp get/put và gọi ra
trình điều khiển thiết bị hoạt động ghi sổ, như kiểm tra các chức năng có sẵn và
các chân liên quan, trong khi ZZ0000ZZ chuyển sang bộ điều khiển chân
trình điều khiển đảm nhiệm việc kích hoạt và/hoặc hủy kích hoạt cài đặt mux bằng cách
nhanh chóng chọc vào một số sổ đăng ký.

Các chân được phân bổ cho thiết bị của bạn khi bạn phát hành ZZ0000ZZ
gọi, sau này bạn sẽ có thể thấy điều này trong danh sách gỡ lỗi của tất cả
ghim.

NOTE: hệ thống pinctrl sẽ trả về ZZ0000ZZ nếu không tìm thấy
đã yêu cầu các thẻ điều khiển pinctrl, ví dụ: nếu trình điều khiển pinctrl chưa có
đã đăng ký. Do đó, hãy đảm bảo rằng đường dẫn lỗi trong trình điều khiển của bạn được xử lý một cách duyên dáng.
dọn dẹp và sẵn sàng thử lại việc thăm dò sau này trong quá trình khởi động.


Trình điều khiển cần cả điều khiển pin và GPIO
==========================================

Một lần nữa, không khuyến khích để trình điều khiển tra cứu và chọn trạng thái điều khiển pin
bản thân họ, nhưng đôi khi điều này là không thể tránh khỏi.

Vì vậy, giả sử trình điều khiển của bạn đang tìm nạp tài nguyên của nó như thế này:

.. code-block:: c

	#include <linux/pinctrl/consumer.h>
	#include <linux/gpio/consumer.h>

	struct pinctrl *pinctrl;
	struct gpio_desc *gpio;

	pinctrl = devm_pinctrl_get_select_default(&dev);
	gpio = devm_gpiod_get(&dev, "foo");

Ở đây, trước tiên chúng tôi yêu cầu một trạng thái pin nhất định và sau đó yêu cầu GPIO "foo"
đã sử dụng. Nếu bạn đang sử dụng các hệ thống con trực giao như thế này, bạn nên
trên danh nghĩa luôn lấy tay cầm pinctrl của bạn và chọn pinctrl mong muốn
trạng thái BEFORE yêu cầu GPIO. Đây là một quy ước ngữ nghĩa cần tránh
những tình huống có thể gây khó chịu về điện, bạn chắc chắn sẽ muốn
các chân mux in và thiên vị theo một cách nhất định trước khi các hệ thống con GPIO bắt đầu
đối phó với họ.

Những điều trên có thể được ẩn đi: sử dụng lõi thiết bị, lõi pinctrl có thể
thiết lập cấu hình và muxing cho các chân ngay trước khi khởi động thiết bị
thăm dò, tuy nhiên trực giao với hệ thống con GPIO.

Nhưng cũng có những tình huống có ý nghĩa đối với hệ thống con GPIO
để giao tiếp trực tiếp với hệ thống con pinctrl, sử dụng hệ thống con pinctrl làm
phía sau. Đây là lúc trình điều khiển GPIO có thể gọi các chức năng
được mô tả trong phần ZZ0000ZZ
ở trên. Điều này chỉ liên quan đến ghép kênh trên mỗi chân và sẽ hoàn toàn
ẩn đằng sau không gian tên hàm gpiod_*(). Trong trường hợp này, người lái xe
hoàn toàn không cần phải tương tác với hệ thống con điều khiển pin.

Nếu trình điều khiển pin và trình điều khiển GPIO đang xử lý các chân giống nhau
và các trường hợp sử dụng liên quan đến ghép kênh, bạn MUST sẽ triển khai bộ điều khiển chân
làm back-end cho trình điều khiển GPIO như thế này, trừ khi thiết kế phần cứng của bạn
sao cho bộ điều khiển GPIO có thể ghi đè lên bộ điều khiển pin
trạng thái ghép kênh thông qua phần cứng mà không cần phải tương tác với
hệ thống điều khiển chốt.


Điều khiển chốt hệ thống bị kẹt
==========================

Các mục trong bản đồ điều khiển chốt có thể bị kẹt bởi lõi khi bộ điều khiển chốt
được đăng ký. Điều này có nghĩa là lõi sẽ cố gắng gọi ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ trên đó ngay sau đó
thiết bị điều khiển pin đã được đăng ký.

Điều này xảy ra đối với các mục trong bảng ánh xạ trong đó tên thiết bị khách bằng nhau
vào tên thiết bị bộ điều khiển pin và tên trạng thái là ZZ0000ZZ:

.. code-block:: c

	{
		.dev_name = "pinctrl-foo",
		.name = PINCTRL_STATE_DEFAULT,
		.type = PIN_MAP_TYPE_MUX_GROUP,
		.ctrl_dev_name = "pinctrl-foo",
		.function = "power_func",
	},

Vì việc yêu cầu lõi sử dụng một số thứ luôn có thể áp dụng là điều bình thường
cài đặt mux trên bộ điều khiển chân chính, có một macro tiện lợi cho
cái này:

.. code-block:: c

	PIN_MAP_MUX_GROUP_HOG_DEFAULT("pinctrl-foo", NULL /* group */,
				      "power_func")

Điều này cho kết quả chính xác tương tự như việc xây dựng ở trên.


Pinmuxing thời gian chạy
=================

Có thể kết hợp một chức năng nhất định vào và ra trong thời gian chạy, chẳng hạn như di chuyển
một cổng SPI từ bộ chân này sang bộ chân khác. Nói ví dụ cho
spi0 trong ví dụ trên, chúng tôi đưa ra hai nhóm chân khác nhau cho cùng một
nhưng có tên khác trong ánh xạ như được mô tả bên dưới
"Bản đồ nâng cao" ở trên. Vì vậy, đối với thiết bị SPI, chúng tôi có hai trạng thái được đặt tên
"pos-A" và "pos-B".

Đoạn mã này trước tiên khởi tạo một đối tượng trạng thái cho cả hai nhóm (trong foo_probe()),
sau đó kết hợp chức năng trong các chân được xác định bởi nhóm A và cuối cùng kết hợp nó trong
trên các chân được xác định bởi nhóm B:

.. code-block:: c

	#include <linux/pinctrl/consumer.h>

	struct pinctrl *p;
	struct pinctrl_state *s1, *s2;

	foo_probe()
	{
		/* Setup */
		p = devm_pinctrl_get(&device);
		if (IS_ERR(p))
			...

		s1 = pinctrl_lookup_state(p, "pos-A");
		if (IS_ERR(s1))
			...

		s2 = pinctrl_lookup_state(p, "pos-B");
		if (IS_ERR(s2))
			...
	}

	foo_switch()
	{
		/* Enable on position A */
		ret = pinctrl_select_state(p, s1);
		if (ret < 0)
			...

		...

		/* Enable on position B */
		ret = pinctrl_select_state(p, s2);
		if (ret < 0)
			...

		...
	}

Những điều trên phải được thực hiện từ bối cảnh quá trình. Việc đặt trước các chân
sẽ được thực hiện khi trạng thái được kích hoạt, do đó, trên thực tế, một pin cụ thể
có thể được sử dụng bởi các chức năng khác nhau vào những thời điểm khác nhau trên một hệ thống đang chạy.


Tệp gỡ lỗi
=============

Các tệp này được tạo trong ZZ0000ZZ:

- ZZ0000ZZ: in từng thiết bị điều khiển pin cùng với các cột thành
  cho biết sự hỗ trợ cho pinmux và pinconf

- ZZ0000ZZ: in từng tay cầm điều khiển pin đã được cấu hình và
  bản đồ pinmux tương ứng

- ZZ0000ZZ: in tất cả các bản đồ pinctrl

Một thư mục con được tạo bên trong ZZ0000ZZ cho mỗi pin
thiết bị điều khiển chứa các tệp này:

- ZZ0000ZZ: in một dòng cho mỗi chân được đăng ký trên bộ điều khiển chân. các
  Trình điều khiển pinctrl có thể thêm thông tin bổ sung như nội dung đăng ký.

- ZZ0000ZZ: in các phạm vi ánh xạ các dòng gpio tới các chân trên bộ điều khiển

- ZZ0000ZZ: in tất cả các nhóm chân đã đăng ký trên bộ điều khiển chân

- ZZ0000ZZ: in cài đặt cấu hình pin cho từng pin

- ZZ0000ZZ: in cài đặt cấu hình pin cho mỗi nhóm pin

- ZZ0000ZZ: in từng chức năng chân cắm cùng với các nhóm chân cắm
  ánh xạ tới chức năng pin

- ZZ0000ZZ: lặp qua tất cả các chân và in ra chủ sở hữu mux, chủ sở hữu gpio
  và nếu cái ghim là một con lợn

- ZZ0000ZZ: ghi vào file này để kích hoạt chức năng ghim cho nhóm:

  .. code-block:: sh

        echo "<group-name function-name>" > pinmux-select
