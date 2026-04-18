.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/pxa/mfp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Cấu hình MFP cho Bộ xử lý PXA2xx/PXA3xx
==================================================

Eric Miao <eric.miao@marvell.com>

MFP là viết tắt của Multi-Function Pin, là logic pin-mux trên PXA3xx và
bộ xử lý dòng PXA sau này.  Tài liệu này mô tả MFP API hiện có,
và cách các tác giả trình điều khiển bo mạch/nền tảng có thể sử dụng nó.

Khái niệm cơ bản
=============

Không giống như cài đặt chức năng thay thế GPIO trên PXA25x và PXA27x, MFP mới
cơ chế được giới thiệu từ PXA3xx để di chuyển hoàn toàn các chức năng pin-mux
ra khỏi bộ điều khiển GPIO. Ngoài cấu hình pin-mux, MFP
cũng kiểm soát trạng thái năng lượng thấp, cường độ truyền động, kéo lên/xuống và sự kiện
phát hiện từng pin.  Dưới đây là sơ đồ kết nối nội bộ giữa
logic MFP và các thiết bị ngoại vi SoC còn lại::

+--------+
 ZZ0000ZZ--(GPIO19)--+
 ZZ0001ZZ |
 ZZ0002ZZ--(GPIO...) |
 +--------+ |
                       |       +----------+
 +--------+ +------>ZZ0003ZZ
 ZZ0004ZZ--(PWM_OUT)-------->ZZ0005ZZ
 +--------+ +------>ZZ0006ZZ-------> tới PAD bên ngoài
                       ZZ0007ZZ |
 +--------+ ZZ0008ZZ +-->ZZ0009ZZ
 ZZ0010ZZ---(TXD)----+ ZZ0011ZZ +----------+
 +--------+ ZZ0012ZZ
                         ZZ0013ZZ
 +--------+ ZZ0014ZZ
 ZZ0015ZZ--(MKOUT4)----+ |
 +--------+ |
                           |
 +--------+ |
 ZZ0016ZZ---(TXD)--------+
 +--------+

NOTE: pad ngoài có tên là MFP_PIN_GPIO19, không nhất thiết phải như vậy
có nghĩa là nó dành riêng cho GPIO19, chỉ là một gợi ý rằng bên trong pin này
có thể được định tuyến từ GPIO19 của bộ điều khiển GPIO.

Để hiểu rõ hơn về sự thay đổi từ chức năng thay thế PXA25x/PXA27x GPIO
đối với cơ chế MFP mới này, dưới đây là một số điểm chính:

1. Bộ điều khiển GPIO trên PXA3xx hiện là bộ điều khiển chuyên dụng, giống như các bộ điều khiển khác
     bộ điều khiển bên trong như PWM, SSP và UART, với 128 tín hiệu bên trong
     có thể được định tuyến ra bên ngoài thông qua một hoặc nhiều MFP (ví dụ: GPIO<0>
     có thể được định tuyến qua MFP_PIN_GPIO0 cũng như MFP_PIN_GPIO0_2,
     xem Arch/arm/mach-pxa/mfp-pxa300.h)

2. Cấu hình chức năng thay thế bị xóa khỏi bộ điều khiển GPIO này,
     các chức năng còn lại hoàn toàn dành riêng cho GPIO, tức là

- Điều khiển mức tín hiệu GPIO
       - Điều khiển hướng GPIO
       - Phát hiện thay đổi cấp độ GPIO

3. Trạng thái năng lượng thấp cho mỗi chân hiện được điều khiển bởi MFP, điều này có nghĩa là
     Các thanh ghi PGSRx trên PXA2xx hiện vô dụng trên PXA3xx

4. Phát hiện đánh thức hiện được điều khiển bởi MFP, PWER không kiểm soát
     đánh thức từ GPIO(s) nữa, tùy thuộc vào trạng thái ngủ, ADxER
     (như được định nghĩa trong pxa3xx-regs.h) kiểm soát việc đánh thức từ MFP

NOTE: với sự phân tách rõ ràng giữa MFP và GPIO, bởi GPIO<xx> chúng tôi thường
có nghĩa đó là tín hiệu GPIO và MFP<xxx> hoặc pin xxx, chúng tôi muốn nói đến tín hiệu vật lý
miếng đệm (hoặc quả bóng).

Cách sử dụng MFP API
=============

Đối với người viết mã bảng, đây là một số hướng dẫn:

1. đưa ONE của các tệp tiêu đề sau vào <board>.c của bạn:

- #include "mfp-pxa25x.h"
   - #include "mfp-pxa27x.h"
   - #include "mfp-pxa300.h"
   - #include "mfp-pxa320.h"
   - #include "mfp-pxa930.h"

NOTE: chỉ một tệp trong <board>.c của bạn, tùy thuộc vào bộ xử lý được sử dụng,
   vì định nghĩa cấu hình pin có thể xung đột trong các tệp này (tức là
   cùng tên, ý nghĩa và cài đặt khác nhau trên các bộ xử lý khác nhau). Ví dụ.
   đối với nền tảng zylonite, hỗ trợ cả PXA300/PXA310 và PXA320, hai
   các tệp riêng biệt được giới thiệu: zylonite_pxa300.c và zylonite_pxa320.c
   (ngoài việc xử lý sự khác biệt về cấu hình MFP, chúng còn xử lý
   sự khác biệt khác giữa hai sự kết hợp).

NOTE: PXA300 và PXA310 gần như giống hệt nhau về cấu hình chân cắm (với
   PXA310 hỗ trợ một số cái bổ sung), do đó sự khác biệt thực sự là
   được bao phủ trong một mfp-pxa300.h.

2. chuẩn bị một mảng cho các cấu hình pin ban đầu, ví dụ::

tĩnh dài không dấu mainstone_pin_config[] __initdata = {
	/* Chọn chip */
	GPIO15_nCS_1,

/* LCD - 16bpp TFT hoạt động */
	GPIOxx_TFT_LCD_16BPP,
	GPIO16_PWM0_OUT, /* Đèn nền */

/* MMC */
	GPIO32_MMC_CLK,
	GPIO112_MMC_CMD,
	GPIO92_MMC_DAT_0,
	GPIO109_MMC_DAT_1,
	GPIO110_MMC_DAT_2,
	GPIO111_MMC_DAT_3,

	...

/* GPIO */
	GPIO1_GPIO | WAKEUP_ON_EDGE_BOTH,
     };

a) sau khi cấu hình pin được chuyển tới pxa{2xx,3xx__mfp_config(),
   và được ghi vào sổ đăng ký thực tế, chúng vô dụng và có thể bị loại bỏ,
   thêm '__initdata' sẽ giúp lưu thêm một số byte tại đây.

b) khi chỉ có một cấu hình chân cắm cho một thành phần,
   một số định nghĩa đơn giản có thể được sử dụng, ví dụ: Bật GPIOxx_TFT_LCD_16BPP
   Bộ xử lý PXA25x và PXA27x

c) nếu theo thiết kế bo mạch, một chốt có thể được cấu hình để đánh thức hệ thống
   từ trạng thái năng lượng thấp, nó có thể được 'HOẶC' với bất kỳ:

WAKEUP_ON_EDGE_BOTH
      WAKEUP_ON_EDGE_RISE
      WAKEUP_ON_EDGE_FALL
      WAKEUP_ON_LEVEL_HIGH - đặc biệt để kích hoạt GPIO bàn phím,

để chỉ ra rằng chân này có khả năng đánh thức hệ thống,
   và trên (các) cạnh nào. Tuy nhiên, điều này không nhất thiết có nghĩa là
   pin _will_ đánh thức hệ thống, nó sẽ chỉ hoạt động khi set_irq_wake() được kích hoạt
   được gọi bằng GPIO IRQ tương ứng (GPIO_IRQ(xx) hoặc gpio_to_irq())
   và cuối cùng gọi gpio_set_wake() để cài đặt đăng ký thực tế.

d) mặc dù PXA3xx MFP hỗ trợ phát hiện cạnh trên mỗi chân, nhưng
   logic bên trong sẽ chỉ đánh thức hệ thống khi các bit cụ thể đó
   trong các thanh ghi ADxER được thiết lập, có thể được ánh xạ tốt tới
   thiết bị ngoại vi tương ứng, do đó set_irq_wake() có thể được gọi bằng
   thiết bị ngoại vi IRQ để kích hoạt tính năng đánh thức.


MFP trên PXA3xx
=============

Mỗi bảng I/O bên ngoài trên PXA3xx (không bao gồm các bảng dành cho mục đích đặc biệt) đều có
một logic MFP được liên kết và được điều khiển bởi một thanh ghi MFP (MFPR).

MFPR có các định nghĩa bit sau (dành cho PXA300/PXA310/PXA320)::

31 16 15 14 13 12 11 10 9 8 7 6 5 4 3 2 1 0
  +--------------------------+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+
  ZZ0000ZZPSZZ0001ZZPDZZ0002ZZSSZZ0003ZZSOZZ0004ZZEFZZ0005ZZ--ZZ0006ZZ
  +--------------------------+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+--+

Bit 3: RESERVED
  Bit 4: EDGE_RISE_EN - cho phép phát hiện cạnh lên trên chân này
  Bit 5: EDGE_FALL_EN - cho phép phát hiện cạnh rơi trên chân này
  Bit 6: EDGE_CLEAR - tắt tính năng phát hiện cạnh trên chân này
  Bit 7: SLEEP_OE_N - cho phép đầu ra ở chế độ năng lượng thấp
  Bit 8: SLEEP_DATA - dữ liệu đầu ra trên chân ở chế độ năng lượng thấp
  Bit 9: SLEEP_SEL - điều khiển lựa chọn tín hiệu chế độ năng lượng thấp
  Bit 13: PULLDOWN_EN - kích hoạt điện trở kéo xuống bên trong trên chân này
  Bit 14: PULLUP_EN - kích hoạt điện trở kéo lên bên trong trên chân này
  Bit 15: PULL_SEL - trạng thái kéo được điều khiển bởi chức năng thay thế đã chọn
                          (0) hoặc bằng các bit PULL{UP,DOWN}_EN (1)

Bit 0 - 2: AF_SEL - lựa chọn chức năng thay thế, 8 khả năng, từ 0-7
  Bit 10-12: DRIVE - cường độ truyền động và tốc độ quay
			0b000 - nhanh 1mA
			0b001 - nhanh 2mA
			0b002 - nhanh 3mA
			0b003 - nhanh 4mA
			0b004 - chậm 6mA
			0b005 - nhanh 6mA
			0b006 - chậm 10mA
			0b007 - nhanh 10mA

Thiết kế MFP cho PXA2xx/PXA3xx
============================

Do sự khác biệt trong cách xử lý pin-mux giữa PXA2xx và PXA3xx, một hệ thống thống nhất
MFP API được giới thiệu để bao gồm cả hai dòng bộ xử lý.

Ý tưởng cơ bản của thiết kế này là giới thiệu các định nghĩa cho tất cả các chân có thể
cấu hình, các định nghĩa này độc lập với bộ xử lý và nền tảng và
API thực tế được gọi để chuyển đổi các định nghĩa này thành cài đặt đăng ký và
làm cho chúng có hiệu lực sau đó.

Các tập tin liên quan
--------------

- vòm/cánh tay/mach-pxa/include/mach/mfp.h

cho
    1. Định nghĩa chân thống nhất - hằng số enum cho tất cả các chân có thể định cấu hình
    2. định nghĩa bit trung tính của bộ xử lý cho cấu hình MFP có thể

- vòm/cánh tay/mach-pxa/mfp-pxa3xx.h

đối với các định nghĩa bit thanh ghi MFPR cụ thể của PXA3xx và chân chung PXA3xx
  cấu hình

- vòm/cánh tay/mach-pxa/mfp-pxa2xx.h

để biết các định nghĩa cụ thể của PXA2xx và cấu hình chân chung PXA25x/PXA27x

- vòm/cánh tay/mach-pxa/mfp-pxa25x.h
    vòm/cánh tay/mach-pxa/mfp-pxa27x.h
    vòm/cánh tay/mach-pxa/mfp-pxa300.h
    vòm/cánh tay/mach-pxa/mfp-pxa320.h
    vòm/cánh tay/mach-pxa/mfp-pxa930.h

cho các định nghĩa cụ thể của bộ xử lý

- vòm/cánh tay/mach-pxa/mfp-pxa3xx.c
  - vòm/cánh tay/mach-pxa/mfp-pxa2xx.c

để thực hiện cấu hình pin có hiệu lực cho thực tế
  bộ xử lý.

Cấu hình chân
-----------------

Các nhận xét sau được sao chép từ mfp.h (xem mã nguồn thực tế
  để biết thông tin cập nhật nhất)::

/*
     * cấu hình MFP có thể được biểu thị bằng số nguyên 32 bit
     *
     * bit 0.. 9 - Số chân MFP (Tối đa 1024 chân)
     * bit 10..12 - Lựa chọn chức năng thay thế
     * bit 13..15 - Độ mạnh của ổ đĩa
     * bit 16..18 - Trạng thái chế độ năng lượng thấp
     * bit 19..20 - Phát hiện cạnh ở chế độ năng lượng thấp
     * bit 21..22 - Trạng thái kéo chế độ chạy
     *
     * để thuận tiện cho việc định nghĩa, các macro sau được cung cấp
     *
     * MFP_CFG_DEFAULT - giá trị cấu hình MFP mặc định, với
     * hàm thay thế = 0,
     * cường độ ổ đĩa = nhanh 3mA (MFP_DS03X)
     * chế độ năng lượng thấp = mặc định
     * phát hiện cạnh = không
     *
     * MFP_CFG - giá trị MFPR mặc định với chức năng thay thế
     * MFP_CFG_DRV - giá trị MFPR mặc định với chức năng thay thế và
     * sức mạnh ổ pin
     * MFP_CFG_LPM - giá trị MFPR mặc định với chức năng thay thế và
     * Chế độ năng lượng thấp
     * MFP_CFG_X - giá trị MFPR mặc định với chức năng thay thế,
     * cường độ ổ pin và chế độ năng lượng thấp
     */

Ví dụ về cấu hình pin là::

#define GPIO94_SSP3_RXD MFP_CFG_X(GPIO94, AF1, DS08X, FLOAT)

đọc GPIO94 có thể được cấu hình là SSP3_RXD, với chức năng thay thế
   lựa chọn 1, cường độ truyền động 0b101 và trạng thái nổi ở công suất thấp
   chế độ.

NOTE: đây là cài đặt mặc định của chân này được định cấu hình là SSP3_RXD
   có thể được sửa đổi một chút trong mã bảng, mặc dù không nên
   làm như vậy, đơn giản vì cài đặt mặc định này thường được mã hóa cẩn thận,
   và được cho là có tác dụng trong hầu hết các trường hợp.

Đăng ký cài đặt
-----------------

Đăng ký cài đặt trên PXA3xx cho cấu hình pin thực sự rất phức tạp.
   đơn giản, hầu hết các bit có thể được chuyển đổi trực tiếp thành giá trị MFPR
   một cách dễ dàng hơn. Hai bộ giá trị MFPR được tính toán: thời gian chạy
   những chế độ này và chế độ năng lượng thấp, để cho phép các cài đặt khác nhau.

Việc chuyển đổi từ cấu hình pin chung sang thanh ghi thực tế
   cài đặt trên PXA2xx hơi phức tạp: có nhiều thanh ghi liên quan,
   bao gồm GAFRx, GPDRx, PGSRx, PWER, PKWR, PFER và PRER. Xin vui lòng xem
   mfp-pxa2xx.c để biết cách thực hiện chuyển đổi.
