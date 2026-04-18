.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/dev-interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================================
Triển khai trình điều khiển thiết bị I2C trong không gian người dùng
====================================================================

Thông thường, các thiết bị I2C được điều khiển bởi trình điều khiển kernel. Nhưng nó cũng
có thể truy cập tất cả các thiết bị trên bộ chuyển đổi từ không gian người dùng, thông qua
giao diện /dev. Bạn cần tải mô-đun i2c-dev cho việc này.

Mỗi bộ điều hợp I2C đã đăng ký sẽ nhận được một số, đếm từ 0. Bạn có thể
kiểm tra /sys/class/i2c-dev/ để xem số nào tương ứng với bộ điều hợp nào.
Ngoài ra, bạn có thể chạy "i2c detect -l" để có được danh sách được định dạng của tất cả
Bộ điều hợp I2C có trên hệ thống của bạn tại một thời điểm nhất định. i2c detect là một phần của
gói công cụ i2c.

Tệp thiết bị I2C là tệp thiết bị ký tự có số thiết bị chính 89
và một số thiết bị phụ tương ứng với số được chỉ định là
đã giải thích ở trên. Chúng phải được gọi là "i2c-%d" (i2c-0, i2c-1, ...,
i2c-10, ...). Tất cả 256 số thiết bị phụ được dành riêng cho I2C.


ví dụ C
=========

Vì vậy, giả sử bạn muốn truy cập bộ điều hợp I2C từ chương trình C.
Trước tiên, bạn cần bao gồm hai tiêu đề sau::

#include <linux/i2c-dev.h>
  #include <i2c/smbus.h>

Bây giờ, bạn phải quyết định bộ chuyển đổi nào bạn muốn truy cập. Bạn nên
kiểm tra /sys/class/i2c-dev/ hoặc chạy "i2c detect -l" để quyết định điều này.
Số bộ điều hợp được gán một cách linh hoạt, do đó bạn không thể
giả định nhiều về họ. Họ thậm chí có thể thay đổi từ chiếc ủng này sang chiếc giày khác.

Điều tiếp theo, mở tệp thiết bị, như sau ::

tập tin int;
  int adapter_nr = 2; /* có thể được xác định một cách linh hoạt */
  tên tệp char[20];

snprintf(tên file, 19, "/dev/i2c-%d", adapter_nr);
  tệp = mở (tên tệp, O_RDWR);
  nếu (tệp < 0) {
    /* ERROR HANDLING; bạn có thể kiểm tra errno để xem có vấn đề gì */
    thoát (1);
  }

Khi đã mở máy phải xác định với thiết bị nào
địa chỉ bạn muốn liên lạc::

int địa chỉ = 0x40; /* Địa chỉ I2C */

if (ioctl(file, I2C_SLAVE, addr) < 0) {
    /* ERROR HANDLING; bạn có thể kiểm tra errno để xem có vấn đề gì */
    thoát (1);
  }

Vâng, bây giờ bạn đã thiết lập xong. Bây giờ bạn có thể sử dụng các lệnh SMBus hoặc đơn giản
I2C để giao tiếp với thiết bị của bạn. Các lệnh SMBus được ưu tiên nếu
thiết bị hỗ trợ chúng. Cả hai đều được minh họa dưới đây::

__u8 reg = 0x10; /* Đăng ký thiết bị để truy cập */
  __s32 độ phân giải;
  char buf[10];

/* Sử dụng lệnh SMBus */
  res = i2c_smbus_read_word_data(file, reg);
  nếu (res < 0) {
    /* ERROR HANDLING: Giao dịch I2C không thành công */
  } khác {
    /* res chứa từ đã đọc */
  }

/*
   * Sử dụng I2C Write, tương đương với
   * i2c_smbus_write_word_data(tệp, reg, 0x6543)
   */
  buf[0] = reg;
  buf[1] = 0x43;
  buf[2] = 0x65;
  if (write(file, buf, 3) != 3) {
    /* ERROR HANDLING: Giao dịch I2C không thành công */
  }

/* Sử dụng I2C Read, tương đương với i2c_smbus_read_byte(file) */
  if (read(file, buf, 1) != 1) {
    /* ERROR HANDLING: Giao dịch I2C không thành công */
  } khác {
    /* buf[0] chứa byte đã đọc */
  }

Lưu ý rằng chỉ có thể đạt được một tập hợp con của giao thức I2C và SMBus bằng cách
phương tiện của các lệnh gọi read() và write(). Đặc biệt, cái gọi là kết hợp
giao dịch (trộn các tin nhắn đọc và viết trong cùng một giao dịch)
không được hỗ trợ. Vì lý do này, giao diện này hầu như không bao giờ được sử dụng bởi
chương trình không gian người dùng.

IMPORTANT: do sử dụng các hàm nội tuyến nên bạn nên sử dụng ZZ0000ZZ
'-O' hoặc một số biến thể khi bạn biên dịch chương trình của mình!


Mô tả giao diện đầy đủ
==========================

Các IOCTL sau đây được xác định:

ZZ0000ZZ
  Thay đổi địa chỉ nô lệ. Địa chỉ được truyền vào 7 bit thấp hơn của
  đối số (ngoại trừ địa chỉ 10 bit, được truyền vào 10 bit thấp hơn trong này
  trường hợp).

ZZ0000ZZ
  Chọn địa chỉ 10 bit nếu chọn không bằng 0, chọn 7 bit bình thường
  địa chỉ nếu chọn bằng 0. Mặc định 0. Yêu cầu này chỉ hợp lệ
  nếu bộ chuyển đổi có I2C_FUNC_10BIT_ADDR.

ZZ0000ZZ
  Chọn việc tạo và xác minh SMBus PEC (kiểm tra lỗi gói)
  nếu chọn không bằng 0, sẽ tắt nếu chọn bằng 0. Mặc định là 0.
  Chỉ được sử dụng cho các giao dịch SMBus.  Yêu cầu này chỉ có hiệu lực nếu
  bộ chuyển đổi có I2C_FUNC_SMBUS_PEC; nó vẫn an toàn nếu không, nó chỉ
  không có tác dụng gì

ZZ0000ZZ
  Nhận chức năng của bộ điều hợp và đặt nó vào ZZ0001ZZ.

ZZ0000ZZ
  Thực hiện giao dịch đọc/ghi kết hợp mà không dừng lại ở giữa.
  Chỉ hợp lệ nếu bộ chuyển đổi có I2C_FUNC_I2C.  Lập luận là
  một con trỏ tới a::

cấu trúc i2c_rdwr_ioctl_data {
      struct i2c_msg ZZ0000ZZ ptr thành mảng các tin nhắn đơn giản */
      int nmsgs;             /*số lượng tin nhắn cần trao đổi */
    }

Bản thân các tin nhắn [] chứa các con trỏ tiếp theo vào bộ đệm dữ liệu.
  Hàm sẽ ghi hoặc đọc dữ liệu đến hoặc từ bộ đệm đó tùy thuộc vào
  về việc cờ I2C_M_RD có được đặt trong một tin nhắn cụ thể hay không.
  Địa chỉ nô lệ và có sử dụng chế độ địa chỉ 10 bit hay không phải là
  được đặt trong mỗi tin nhắn, ghi đè các giá trị được đặt bằng ioctl ở trên.

ZZ0000ZZ
  Nếu có thể, hãy sử dụng các phương pháp ZZ0001ZZ được cung cấp được mô tả bên dưới
  phát hành ioctls trực tiếp.

Bạn có thể thực hiện các giao dịch I2C đơn giản bằng cách sử dụng lệnh gọi đọc (2) và ghi (2).
Bạn không cần phải chuyển byte địa chỉ; thay vào đó, hãy thiết lập nó
ioctl I2C_SLAVE trước khi bạn cố gắng truy cập thiết bị.

Bạn có thể thực hiện các giao dịch cấp SMBus (xem tệp tài liệu smbus-protocol.rst
để biết chi tiết) thông qua các chức năng sau::

__s32 i2c_smbus_write_quick(tệp int, giá trị __u8);
  __s32 i2c_smbus_read_byte(tệp int);
  __s32 i2c_smbus_write_byte(tệp int, giá trị __u8);
  __s32 i2c_smbus_read_byte_data(tệp int, lệnh __u8);
  __s32 i2c_smbus_write_byte_data(tệp int, lệnh __u8, giá trị __u8);
  __s32 i2c_smbus_read_word_data(tệp int, lệnh __u8);
  __s32 i2c_smbus_write_word_data(tệp int, lệnh __u8, giá trị __u16);
  __s32 i2c_smbus_process_call(tệp int, lệnh __u8, giá trị __u16);
  __s32 i2c_smbus_block_process_call(tệp int, lệnh __u8, độ dài __u8,
                                     __u8 *giá trị);
  __s32 i2c_smbus_read_block_data(tệp int, lệnh __u8, __u8 *giá trị);
  __s32 i2c_smbus_write_block_data(tệp int, lệnh __u8, độ dài __u8,
                                   __u8 *giá trị);

Tất cả các giao dịch này trả về -1 nếu thất bại; bạn có thể đọc errno để xem
chuyện gì đã xảy ra. Các giao dịch 'ghi' trả về 0 nếu thành công; cái
Các giao dịch 'đã đọc' trả về giá trị đã đọc, ngoại trừ read_block, giá trị này
trả về số giá trị đã đọc. Bộ đệm khối không cần phải dài hơn
hơn 32 byte.

Các chức năng trên được cung cấp bằng cách liên kết với thư viện libi2c,
được cung cấp bởi dự án i2c-tools.  Xem:
ZZ0000ZZ


Chi tiết triển khai
======================

Đối với những người quan tâm, đây là luồng mã xảy ra bên trong kernel
khi bạn sử dụng giao diện /dev cho I2C:

1) Chương trình của bạn mở /dev/i2c-N và gọi ioctl() trên đó, như được mô tả trong
   phần "Ví dụ C" ở trên.

2) Các lệnh gọi open() và ioctl() này được xử lý bởi kernel i2c-dev
   trình điều khiển: xem i2c-dev.c:i2cdev_open() và i2c-dev.c:i2cdev_ioctl(),
   tương ứng. Bạn có thể coi i2c-dev như một trình điều khiển chip I2C chung
   có thể được lập trình từ không gian người dùng.

3) Một số lệnh gọi ioctl() dành cho các tác vụ quản trị và được xử lý bởi
   i2c-dev trực tiếp. Ví dụ bao gồm I2C_SLAVE (đặt địa chỉ của
   thiết bị bạn muốn truy cập) và I2C_PEC (bật hoặc tắt lỗi SMBus
   kiểm tra các giao dịch trong tương lai.)

4) Các lệnh gọi ioctl() khác được chuyển đổi thành các lệnh gọi hàm trong kernel bởi
   i2c-dev. Các ví dụ bao gồm I2C_FUNCS, truy vấn bộ điều hợp I2C
   chức năng sử dụng i2c.h:i2c_get_functionity() và I2C_SMBUS, trong đó
   thực hiện giao dịch SMBus bằng i2c-core-smbus.c:i2c_smbus_xfer().

Trình điều khiển i2c-dev có trách nhiệm kiểm tra tất cả các thông số
   đến từ không gian người dùng để có giá trị. Sau thời điểm này, không có
   sự khác biệt giữa các cuộc gọi đến từ không gian người dùng thông qua i2c-dev
   và các cuộc gọi lẽ ra đã được thực hiện bởi trình điều khiển chip I2C hạt nhân
   trực tiếp. Điều này có nghĩa là trình điều khiển xe buýt I2C không cần triển khai
   bất cứ điều gì đặc biệt để hỗ trợ truy cập từ không gian người dùng.

5) Các hàm i2c.h này là các hàm bao cho việc triển khai thực tế của
   trình điều khiển xe buýt I2C của bạn. Mỗi bộ chuyển đổi phải khai báo các hàm gọi lại
   thực hiện các cuộc gọi tiêu chuẩn này. cuộc gọi i2c.h:i2c_get_functionity()
   i2c_adapter.algo->functionity(), trong khi
   i2c-core-smbus.c:i2c_smbus_xfer() gọi hoặc
   adapter.algo->smbus_xfer() nếu nó được triển khai hoặc nếu không,
   i2c-core-smbus.c:i2c_smbus_xfer_emulated() lần lượt gọi
   i2c_adapter.algo->master_xfer().

Sau khi trình điều khiển bus I2C của bạn đã xử lý các yêu cầu này, quá trình thực thi sẽ diễn ra
lên chuỗi cuộc gọi mà hầu như không có quá trình xử lý nào được thực hiện, ngoại trừ i2c-dev để
đóng gói dữ liệu trả về, nếu có, ở định dạng phù hợp cho ioctl.
