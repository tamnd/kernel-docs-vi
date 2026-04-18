.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/gpio-properties.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
Thuộc tính thiết bị _DSD liên quan đến GPIO
======================================

Với việc phát hành ACPI 5.1, đối tượng cấu hình _DSD cuối cùng
cho phép đặt tên cho GPIO (và cả những thứ khác nữa) được trả lại
bởi _CRS. Trước đây chúng ta chỉ có thể sử dụng chỉ mục số nguyên để tìm
GPIO tương ứng, khá dễ bị lỗi (điều này phụ thuộc vào
ví dụ như thứ tự đầu ra _CRS).

Với _DSD giờ đây chúng ta có thể truy vấn GPIO bằng tên thay vì số nguyên
chỉ mục, như ví dụ ASL bên dưới hiển thị::

// Thiết bị Bluetooth có GPIO đặt lại và tắt
  Thiết bị (BTH)
  {
      Tên (_HID, ...)

Tên (_CRS, ResourceTemplate ()
      {
          GpioIo (Độc quyền, PullUp, 0, 0, IoRestrictionOutputOnly,
                  "\\_SB.GPO0", 0, ResourceConsumer) { 15 }
          GpioIo (Độc quyền, PullUp, 0, 0, IoRestrictionOutputOnly,
                  "\\_SB.GPO0", 0, ResourceConsumer) { 27, 31 }
      })

Tên (_DSD, Gói ()
      {
          ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
          Gói ()
          {
              Gói () { "reset-gpios", Gói () { ^BTH, 1, 1, 0 } },
              Gói () { "shutdown-gpios", Gói () { ^BTH, 0, 0, 0 } },
          }
      })
  }

Định dạng của thuộc tính GPIO được hỗ trợ là::

Gói () { "tên", Gói () { ref, chỉ mục, pin, active_low }}

giới thiệu
  Thiết bị có _CRS chứa tài nguyên GpioIo()/GpioInt(),
  thông thường đây chính là thiết bị (BTH trong trường hợp của chúng tôi).
chỉ mục
  Chỉ mục của tài nguyên GpioIo()/GpioInt() trong _CRS bắt đầu từ 0.
ghim
  Ghim vào tài nguyên GpioIo()/GpioInt(). Thông thường con số này bằng không.
hoạt động_thấp
  Nếu 1, GPIO được đánh dấu là hoạt động ở mức thấp.

Vì tài nguyên ACPI GpioIo() không có trường cho biết liệu nó có
hoạt động ở mức thấp hoặc hoạt động ở mức cao, đối số "active_low" có thể được sử dụng ở đây.
Đặt nó thành 1 sẽ đánh dấu GPIO ở mức hoạt động ở mức thấp.

Lưu ý, active_low trong _DSD không có ý nghĩa đối với tài nguyên GpioInt() và
phải bằng 0. Tài nguyên GpioInt() có cách xác định riêng.

Trong ví dụ về Bluetooth của chúng tôi, "reset-gpios" đề cập đến GpioIo() thứ hai
tài nguyên, pin thứ hai trong tài nguyên đó với số GPIO là 31.

Rất tiếc, tài nguyên GpioIo() không cung cấp rõ ràng thông tin ban đầu
trạng thái của chân đầu ra mà trình điều khiển sẽ sử dụng trong quá trình khởi tạo.

Linux cố gắng sử dụng lẽ thường ở đây và lấy trạng thái từ sự thiên vị
và cài đặt phân cực. Bảng dưới đây cho thấy những kỳ vọng:

+-------------+-------------+-----------------------------------------------+
ZZ0004ZZ Phân cực ZZ0005ZZ
+========================================================================================================================================================
ZZ0006ZZ
+-------------+-------------+-----------------------------------------------+
ZZ0007ZZ x ZZ0008ZZ
+-------------+-------------+-----------------------------------------------+
ZZ0009ZZ
+-------------+-------------+-----------------------------------------------+
ZZ0010ZZ x ZZ0011ZZ
ZZ0012ZZ ZZ0013ZZ
+-------------+-------------+-----------------------------------------------+
ZZ0014ZZ x (không có _DSD) ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ Thấp ZZ0018ZZ
|             +-------------+----------------------------------------------------------+
ZZ0019ZZ Cao ZZ0020ZZ
+-------------+-------------+-----------------------------------------------+
ZZ0021ZZ x (không có _DSD) ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ Cao ZZ0025ZZ
|             +-------------+----------------------------------------------------------+
ZZ0026ZZ Thấp ZZ0027ZZ
+-------------+-------------+-----------------------------------------------+

Điều đó nói lên rằng, đối với ví dụ trên của chúng tôi, vì cài đặt sai lệch là rõ ràng và
_DSD hiện diện, cả hai GPIO sẽ được coi là hoạt động với mức cao
phân cực và Linux sẽ cấu hình các chân ở trạng thái này cho đến khi trình điều khiển
lập trình lại chúng một cách khác nhau.

Có thể để lại lỗ hổng trong mảng GPIO. Điều này hữu ích trong
các trường hợp như với bộ điều khiển máy chủ SPI trong đó một số lựa chọn chip có thể
được triển khai dưới dạng GPIO và một số dưới dạng tín hiệu gốc. Ví dụ: máy chủ SPI
bộ điều khiển có thể có chip chọn 0 và 2 được triển khai dưới dạng GPIO và 1 làm
bản địa::

Gói () {
      "cs-gpios",
      Gói () {
          ^GPIO, 19, 0, 0, // chip chọn 0: GPIO
          0, // chip chọn 1: tín hiệu gốc
          ^GPIO, 20, 0, 0, // chip chọn 2: GPIO
      }
  }

Lưu ý rằng về mặt lịch sử ACPI không có phương tiện phân cực GPIO và do đó
tài nguyên SPISerialBus() xác định nó trên cơ sở mỗi chip. theo thứ tự
để tránh một chuỗi phủ định, cực GPIO được coi là
Hoạt động Cao. Ngay cả đối với các trường hợp có liên quan đến _DSD() (xem ví dụ
ở trên) cực GPIO CS phải được xác định là Hoạt động Cao để tránh sự mơ hồ.

Các thuộc tính được hỗ trợ khác
==========================

Các thuộc tính thiết bị tương thích với Cây thiết bị sau đây cũng được hỗ trợ bởi
Thuộc tính thiết bị _DSD cho bộ điều khiển GPIO:

- gpio-hog
- đầu ra cao
- đầu ra thấp
- đầu vào
- tên dòng

Ví dụ::

Tên (_DSD, Gói () {
      // _DSD Tiện ích mở rộng thuộc tính phân cấp UUID
      ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
      Gói () {
          Gói () { "hog-gpio8", "G8PU" }
      }
  })

Tên (G8PU, Gói () {
      ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
      Gói () {
          Gói () { "gpio-hog", 1 },
          Gói () { "gpios", Gói () { 8, 0 } },
          Gói () { "đầu ra cao", 1 },
          Gói () { "tên dòng", "gpio8-pullup" },
      }
  })

- tên dòng gpio

Khai báo ZZ0000ZZ là một danh sách các chuỗi ("tên"), trong đó
mô tả từng dòng/chân của bộ điều khiển/bộ mở rộng GPIO. Danh sách này, có trong
một gói, phải được chèn bên trong khai báo bộ điều khiển GPIO của ACPI
bảng (thường bên trong DSDT). Danh sách ZZ0001ZZ phải tôn trọng
các quy tắc sau (xem thêm ví dụ):

- tên đầu tiên trong danh sách tương ứng với dòng/pin đầu tiên của GPIO
    bộ điều khiển/bộ mở rộng
  - các tên trong danh sách phải liên tiếp (không được phép có "lỗ hổng")
  - danh sách có thể không đầy đủ và có thể kết thúc trước dòng GPIO cuối cùng: trong
    nói cách khác, không bắt buộc phải điền hết các dòng GPIO
  - cho phép tên trống (hai dấu ngoặc kép ZZ0000ZZ tương ứng với một tên trống
    tên)
  - tên bên trong một bộ điều khiển/bộ mở rộng GPIO phải là duy nhất

Ví dụ về bộ điều khiển GPIO gồm 16 dòng, với danh sách không đầy đủ có hai dòng
tên trống::

Gói () {
      "tên dòng gpio",
      Gói () {
          "pin_0",
          "pin_1",
          "",
          "",
          "pin_3",
          "pin_4_push_button",
      }
  }

Khi chạy, khai báo trên tạo ra kết quả sau (sử dụng
công cụ "libgpiod")::

root@debian:~# gpioinfo gpiochip4
  gpiochip4 - 16 dòng:
          dòng 0: "pin_0" đầu vào không được sử dụng đang hoạt động ở mức cao
          dòng 1: "pin_1" đầu vào chưa được sử dụng đang hoạt động ở mức cao
          dòng 2: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 3: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 4: "pin_3" đầu vào chưa được sử dụng đang hoạt động ở mức cao
          dòng 5: "pin_4_push_button" đầu vào không được sử dụng ở mức cao
          dòng 6: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 7 chưa được đặt tên đầu vào chưa sử dụng đang hoạt động ở mức cao
          dòng 8: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 9: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 10: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 11: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 12: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 13: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 14: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
          dòng 15: đầu vào không được sử dụng chưa được đặt tên đang hoạt động ở mức cao
  root@debian:~# gpiofind pin_4_push_button
  gpiochip4 5
  root@debian:~#

Một ví dụ khác::

Gói () {
      "tên dòng gpio",
      Gói () {
          "SPI0_CS_N", "EXP2_INT", "MUX6_IO", "UART0_RXD",
          "MUX7_IO", "LVL_C_A1", "MUX0_IO", "SPI1_MISO",
      }
  }

Xem Tài liệu/devicetree/binds/gpio/gpio.txt để biết thêm thông tin
về những tài sản này.

Ánh xạ ACPI GPIO được cung cấp bởi trình điều khiển
======================================

Có những hệ thống trong đó các bảng ACPI không chứa _DSD nhưng cung cấp _CRS
với tài nguyên GpioIo()/GpioInt() và trình điều khiển thiết bị vẫn cần hoạt động với
họ.

Trong những trường hợp đó, đối tượng nhận dạng thiết bị ACPI, _HID, _CID, _CLS, _SUB, _HRV,
có sẵn cho trình điều khiển có thể được sử dụng để nhận dạng thiết bị và điều đó được cho là
đủ để xác định ý nghĩa và mục đích của tất cả các dòng GPIO
được liệt kê bởi tài nguyên GpioIo()/GpioInt() được trả về bởi _CRS.  Nói cách khác,
trình điều khiển phải biết nên sử dụng những gì từ tài nguyên GpioIo()/GpioInt()
một khi nó đã xác định được thiết bị. Làm xong việc đó, nó có thể chỉ cần gán tên
cho các dòng GPIO nó sẽ sử dụng và cung cấp cho hệ thống con GPIO một
ánh xạ giữa các tên đó và tài nguyên ACPI GPIO tương ứng với chúng.

Để làm điều đó, trình điều khiển cần xác định bảng ánh xạ là bảng kết thúc NULL
mảng các đối tượng struct acpi_gpio_mapping, mỗi đối tượng chứa một tên, một con trỏ
đến một mảng các đối tượng dữ liệu dòng (struct acpi_gpio_params) và kích thước của nó
mảng.  Mỗi đối tượng struct acpi_gpio_params bao gồm ba trường,
crs_entry_index, line_index, active_low, thể hiện chỉ mục của mục tiêu
Tài nguyên GpioIo()/GpioInt() trong _CRS bắt đầu từ 0, chỉ mục của mục tiêu
dòng trong tài nguyên đó bắt đầu từ 0 và cờ mức hoạt động thấp cho dòng đó,
tương ứng, tương tự với định dạng thuộc tính _DSD GPIO được chỉ định ở trên.

Đối với ví dụ về thiết bị Bluetooth đã thảo luận trước đây về cấu trúc dữ liệu trong
câu hỏi sẽ như thế này::

cấu trúc const tĩnh acpi_gpio_params reset_gpio = { 1, 1, false };
  cấu trúc const tĩnh acpi_gpio_params tắt máy_gpio = { 0, 0, sai };

cấu trúc const tĩnh acpi_gpio_mapping bluetooth_acpi_gpios[] = {
      { "reset-gpios", &reset_gpio, 1 },
      { "shutdown-gpios", &shutdown_gpio, 1 },
      { }
  };

Tiếp theo, bảng ánh xạ cần được chuyển làm đối số thứ hai cho
acpi_dev_add_driver_gpios() hoặc chất tương tự được quản lý của nó sẽ
đăng ký nó với đối tượng thiết bị ACPI được trỏ tới bởi đối tượng đầu tiên của nó
lý lẽ. Điều đó nên được thực hiện trong quy trình .probe() của trình điều khiển.
Khi xóa, trình điều khiển nên hủy đăng ký bảng ánh xạ GPIO của nó bằng cách
gọi acpi_dev_remove_driver_gpios() trên đối tượng thiết bị ACPI trong đó
bảng đã được đăng ký trước đó.

Sử dụng dự phòng _CRS
=======================

Nếu thiết bị không có _DSD hoặc trình điều khiển không tạo ACPI GPIO
ánh xạ, khung Linux GPIO từ chối trả về bất kỳ GPIO nào. Đây là
bởi vì người lái xe không biết nó thực sự nhận được gì. Ví dụ, nếu chúng ta
có một thiết bị như dưới đây::

Thiết bị (BTH)
  {
      Tên (_HID, ...)

Tên (_CRS, ResourceTemplate () {
          GpioIo (Độc quyền, PullNone, 0, 0, IoRestrictionNone,
                  "\\_SB.GPO0", 0, ResourceConsumer) { 15 }
          GpioIo (Độc quyền, PullNone, 0, 0, IoRestrictionNone,
                  "\\_SB.GPO0", 0, ResourceConsumer) { 27 }
      })
  }

Người lái xe có thể mong đợi nhận được GPIO phù hợp khi thực hiện::

desc = gpiod_get(dev, "reset", GPIOD_OUT_LOW);
  nếu (IS_ERR(desc))
	...error handling...

nhưng vì không có cách nào để biết ánh xạ giữa "đặt lại" và
GpioIo() trong _CRS, desc sẽ giữ ERR_PTR(-ENOENT).

Tác giả trình điều khiển có thể giải quyết vấn đề này bằng cách chuyển ánh xạ một cách rõ ràng
(đây là cách được đề xuất và nó đã được ghi lại trong chương trên).

Các bảng ánh xạ ACPI GPIO không được làm ô nhiễm các trình điều khiển không
biết chính xác thiết bị nào họ đang phục vụ. Nó ngụ ý rằng
các bảng ánh xạ ACPI GPIO hầu như không được liên kết với ID ACPI và một số
các đối tượng, như được liệt kê trong chương trên, của thiết bị được đề cập.

Lấy bộ mô tả GPIO
=======================

Có hai cách tiếp cận chính để lấy tài nguyên GPIO từ ACPI:

desc = gpiod_get(dev, Connection_id, flags);
  desc = gpiod_get_index(dev, Connection_id, chỉ mục, cờ);

Chúng ta có thể xem xét hai trường hợp khác nhau ở đây, tức là khi ID kết nối được
được cung cấp và ngược lại.

Trường hợp 1::

desc = gpiod_get(dev, "non-null-connection-id", flags);
  desc = gpiod_get_index(dev, "non-null-connection-id", chỉ mục, cờ);

Trường hợp 1 giả định rằng mô tả thiết bị ACPI tương ứng phải có
thuộc tính thiết bị được xác định và sẽ ngăn nhận bất kỳ tài nguyên GPIO nào
mặt khác.

Trường hợp 2::

desc = gpiod_get(dev, NULL, flag);
  desc = gpiod_get_index(dev, NULL, chỉ mục, cờ);

Trường hợp 2 yêu cầu lõi GPIO tìm kiếm tài nguyên trong _CRS một cách rõ ràng.

Xin lưu ý rằng gpiod_get_index() trong trường hợp 1 và 2, giả sử rằng có
có hai phiên bản mô tả thiết bị ACPI được cung cấp và không có bản đồ nào
có trong trình điều khiển, sẽ trả về các tài nguyên khác nhau. Đó là lý do tại sao một
người lái xe nhất định phải xử lý chúng cẩn thận như đã giải thích ở phần trước
chương.