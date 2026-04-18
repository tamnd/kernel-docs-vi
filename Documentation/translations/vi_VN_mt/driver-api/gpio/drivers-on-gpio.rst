.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/gpio/drivers-on-gpio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Trình điều khiển hệ thống con sử dụng GPIO
============================

Lưu ý rằng trình điều khiển hạt nhân tiêu chuẩn tồn tại cho các tác vụ GPIO phổ biến và sẽ cung cấp
các API/ABI trong nhân và không gian người dùng phù hợp cho công việc và những điều này
trình điều khiển có thể kết nối khá dễ dàng với các hệ thống con kernel khác bằng cách sử dụng
mô tả phần cứng như cây thiết bị hoặc ACPI:

- leds-gpio: driver/leds/leds-gpio.c sẽ xử lý các LED kết nối với GPIO
  dòng, cung cấp cho bạn giao diện sysfs LED

- ledtrig-gpio: driver/leds/trigger/ledtrig-gpio.c sẽ cung cấp trình kích hoạt LED,
  tức là LED sẽ bật/tắt khi đường GPIO lên cao hoặc xuống thấp
  (và LED có thể lần lượt sử dụng leds-gpio như trên).

- gpio-keys: driver/input/keyboard/gpio_keys.c được sử dụng khi dòng GPIO của bạn
  có thể tạo ra các ngắt khi nhấn phím. Cũng hỗ trợ gỡ lỗi.

- gpio-keys-polled: driver/input/keyboard/gpio_keys_polled.c được sử dụng khi
  Dòng GPIO không thể tạo ra các ngắt, vì vậy nó cần được thăm dò định kỳ
  bằng một bộ đếm thời gian.

- gpio_mouse: driver/input/mouse/gpio_mouse.c được sử dụng để cung cấp cho chuột
  tối đa ba nút chỉ bằng cách sử dụng GPIO và không cần cổng chuột. Bạn có thể cắt
  cáp chuột và kết nối dây với dòng GPIO hoặc hàn đầu nối chuột
  đến các đường dây để có giải pháp lâu dài hơn cho loại hình này.

- gpio-beeper: driver/input/misc/gpio-beeper.c được sử dụng để phát ra tiếng bíp từ
  một loa ngoài được kết nối với đường dây GPIO. (Nếu tiếng bíp được điều khiển bởi
  tắt/bật, để biết dạng sóng PWM thực tế, hãy xem pwm-gpio bên dưới.)

- pwm-gpio: driver/pwm/pwm-gpio.c được sử dụng để chuyển đổi GPIO ở mức cao
  bộ đếm thời gian phân giải tạo ra dạng sóng PWM trên dòng GPIO, cũng như
  Bộ định thời độ phân giải cao của Linux có thể làm được.

- extcon-gpio: driver/extcon/extcon-gpio.c được sử dụng khi bạn cần đọc một
  trạng thái đầu nối bên ngoài, chẳng hạn như đường dây tai nghe cho trình điều khiển âm thanh hoặc
  Đầu nối HDMI. Nó sẽ cung cấp giao diện sysfs không gian người dùng tốt hơn GPIO.

- restart-gpio: driver/power/reset/gpio-restart.c dùng để khởi động lại/khởi động lại
  hệ thống bằng cách kéo một dòng GPIO và sẽ đăng ký trình xử lý khởi động lại để
  không gian người dùng có thể đưa ra lệnh gọi hệ thống phù hợp để khởi động lại hệ thống.

- poweroff-gpio: driver/power/reset/gpio-poweroff.c được sử dụng để cấp nguồn cho
  hệ thống ngừng hoạt động bằng cách kéo dòng GPIO và sẽ đăng ký pm_power_off()
  gọi lại để không gian người dùng có thể đưa ra lệnh gọi hệ thống phù hợp để tắt nguồn
  hệ thống.

- gpio-gate-clock: driver/clk/clk-gpio.c dùng để điều khiển đồng hồ có cổng
  (tắt/bật) sử dụng GPIO và được tích hợp với hệ thống con đồng hồ.

- i2c-gpio: driver/i2c/busses/i2c-gpio.c dùng để điều khiển bus I2C
  (hai dây, dòng SDA và SCL) bằng cách đóng búa (bitbang) hai dòng GPIO. Nó sẽ
  xuất hiện dưới dạng bất kỳ bus I2C nào khác vào hệ thống và có thể kết nối
  trình điều khiển cho các thiết bị I2C trên xe buýt giống như bất kỳ trình điều khiển xe buýt I2C nào khác.

- spi_gpio: driver/spi/spi-gpio.c dùng để điều khiển bus SPI (số biến
  số dây, ít nhất là SCK và tùy chọn MISO, MOSI và các dòng chọn chip) bằng cách sử dụng
  GPIO búa (bitbang). Nó sẽ xuất hiện dưới dạng bất kỳ bus SPI nào khác trên hệ thống
  và có thể kết nối trình điều khiển cho các thiết bị SPI trên xe buýt như
  bất kỳ trình điều khiển xe buýt SPI nào khác. Ví dụ: bất kỳ thẻ MMC/SD nào cũng có thể được kết nối
  tới SPI này bằng cách sử dụng máy chủ mmc_spi từ hệ thống con thẻ MMC/SD.

- w1-gpio: driver/w1/masters/w1-gpio.c được sử dụng để điều khiển bus một dây bằng cách sử dụng
  một dòng GPIO, tích hợp với hệ thống con W1 và các thiết bị xử lý trên
  bus giống như bất kỳ thiết bị W1 nào khác.

- gpio-fan: driver/hwmon/gpio-fan.c dùng để điều khiển quạt làm mát máy
  hệ thống, được kết nối với đường dây GPIO (và tùy chọn đường dây báo động GPIO),
  trình bày tất cả các giao diện trong kernel và sysfs phù hợp để làm cho hệ thống của bạn
  không quá nóng.

- gpio-regulator: driver/regulator/gpio-regulator.c được sử dụng để điều khiển một
  bộ điều chỉnh cung cấp một điện áp nhất định bằng cách kéo một đường GPIO, tích hợp
  với hệ thống con điều chỉnh và cung cấp cho bạn tất cả các giao diện phù hợp.

- gpio-wdt: driver/watchdog/gpio_wdt.c được sử dụng để cung cấp bộ đếm thời gian theo dõi
  sẽ "ping" định kỳ một phần cứng được kết nối với đường dây GPIO bằng cách chuyển đổi
  nó từ 1 đến 0 đến 1. Nếu phần cứng đó không nhận được "ping"
  định kỳ nó sẽ reset lại hệ thống.

- gpio-nand: driver/mtd/nand/raw/gpio.c dùng để kết nối chip flash NAND
  đến một tập hợp các dòng GPIO đơn giản: RDY, NCE, ALE, CLE, NWP. Nó tương tác với
  NAND flash Hệ thống con MTD và cung cấp khả năng truy cập chip và phân tích phân vùng như
  bất kỳ phần cứng lái xe NAND nào khác.

- ps2-gpio: driver/input/serio/ps2-gpio.c được dùng để điều khiển serio PS/2 (IBM)
  đường bus, dữ liệu và đồng hồ, bằng cách đập hai đường GPIO. Nó sẽ xuất hiện dưới dạng
  bất kỳ bus serio nào khác vào hệ thống và có thể kết nối các trình điều khiển
  ví dụ: bàn phím và các thiết bị dựa trên giao thức PS/2 khác.

- cec-gpio: driver/media/platform/cec-gpio/ được sử dụng để tương tác với CEC
  Xe buýt điều khiển điện tử tiêu dùng chỉ sử dụng GPIO. Nó được sử dụng để giao tiếp
  với các thiết bị trên bus HDMI.

- gpio-charger: driver/power/supply/gpio-charger.c được sử dụng nếu bạn cần làm
  sạc pin và tất cả những gì bạn phải làm để kiểm tra sự hiện diện của
  Bộ sạc AC hoặc các tác vụ phức tạp hơn như chỉ báo trạng thái sạc bằng cách sử dụng
  không có gì ngoài các dòng GPIO, trình điều khiển này cung cấp điều đó và cũng được xác định rõ ràng
  cách để chuyển các tham số sạc từ các mô tả phần cứng như
  cây thiết bị.

- gpio-mux: driver/mux/gpio.c được sử dụng để điều khiển bộ ghép kênh bằng cách sử dụng
  n dòng GPIO để bạn có thể kết nối trên 2^n thiết bị khác nhau bằng cách kích hoạt
  dòng GPIO khác nhau. Thông thường các GPIO nằm trên SoC và các thiết bị
  một số thực thể bên ngoài SoC, chẳng hạn như các thành phần khác nhau trên PCB
  có thể được kích hoạt có chọn lọc.

Ngoài ra, còn có các trình điều khiển GPIO đặc biệt trong các hệ thống con như MMC/SD để
đọc thẻ phát hiện và ghi bảo vệ các dòng GPIO và trong hệ thống con nối tiếp TTY
để mô phỏng tín hiệu MCTRL (điều khiển modem) CTS/RTS bằng cách sử dụng hai đường GPIO. các
Đèn flash MTD NOR cũng có các tiện ích bổ sung cho các dòng GPIO bổ sung, mặc dù bus địa chỉ là
thường được kết nối trực tiếp với đèn flash.

Sử dụng những thứ đó thay vì nói chuyện trực tiếp với GPIO từ không gian người dùng; họ
tích hợp với các khung kernel tốt hơn mã không gian người dùng của bạn.
Không cần phải nói, chỉ cần sử dụng trình điều khiển kernel thích hợp sẽ đơn giản hóa và
đặc biệt là tăng tốc quá trình hack nhúng của bạn bằng cách cung cấp các thành phần làm sẵn.
