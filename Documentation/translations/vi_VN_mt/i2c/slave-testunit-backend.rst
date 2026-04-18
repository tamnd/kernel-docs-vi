.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/slave-testunit-backend.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Phần phụ trợ thử nghiệm nô lệ Linux I2C
================================

bởi Wolfram Sang <wsa@sang-engineering.com> vào năm 2020

Phần phụ trợ này có thể được sử dụng để kích hoạt các trường hợp thử nghiệm cho các chủ bus I2C.
yêu cầu một thiết bị từ xa có những khả năng nhất định (và thường không như vậy
dễ dàng có được). Các ví dụ bao gồm thử nghiệm đa chủ và Thông báo máy chủ SMBus
thử nghiệm. Đối với một số thử nghiệm, bộ điều khiển phụ I2C phải có khả năng chuyển đổi
giữa chế độ chủ và chế độ nô lệ vì nó cũng cần gửi dữ liệu.

Lưu ý rằng đây là thiết bị để thử nghiệm và gỡ lỗi. Nó không nên được kích hoạt
trong một công trình sản xuất. Và mặc dù có một số phiên bản và chúng tôi cố gắng hết sức để
giữ khả năng tương thích ngược, không đảm bảo ABI ổn định!

Khởi tạo thiết bị là thường xuyên. Ví dụ cho bus 0, địa chỉ 0x30::

# echo "thử nghiệm nô lệ 0x1030" > /sys/bus/i2c/devices/i2c-0/new_device

Hoặc sử dụng các nút phần sụn. Đây là một ví dụ về cây thiết bị (lưu ý đây chỉ là một
gỡ lỗi thiết bị, do đó không có ràng buộc DT chính thức)::

&i2c0 {
        ...

testunit@30 {
		tương thích = "nô lệ-testunit";
		reg = <(0x30 | I2C_OWN_SLAVE_ADDRESS)>;
	};
  };

Sau đó, bạn sẽ có thiết bị nghe. Việc đọc sẽ trả về một
byte. Giá trị của nó là 0 nếu đơn vị kiểm tra không hoạt động, nếu không thì số lệnh của
lệnh hiện đang chạy.

Khi ghi, thiết bị bao gồm 4 thanh ghi 8 bit và ngoại trừ một số thanh ghi
lệnh "một phần", tất cả các thanh ghi phải được ghi để bắt đầu một testcase, tức là bạn
thường ghi 4 byte vào thiết bị. Các sổ đăng ký là:

.. csv-table::
  :header: "Offset", "Name", "Description"

  0x00, CMD, which test to trigger
  0x01, DATAL, configuration byte 1 for the test
  0x02, DATAH, configuration byte 2 for the test
  0x03, DELAY, delay in n * 10ms until test is started

Sử dụng 'i2cset' từ gói i2c-tools, lệnh chung trông giống như ::

# i2cset -y <bus_num> <testunit_address> <CMD> <DATAL> <DATAH> <DELAY> và

DELAY là tham số chung sẽ trì hoãn việc thực hiện thử nghiệm trong CMD.
Trong khi một lệnh đang chạy (bao gồm cả độ trễ), các lệnh mới sẽ không được thực hiện.
thừa nhận. Bạn cần đợi cho đến khi cái cũ được hoàn thành.

Các lệnh được mô tả trong phần sau. Một lệnh không hợp lệ sẽ
dẫn đến việc chuyển giao không được thừa nhận.

Lệnh
--------

0x00 NOOP
~~~~~~~~~

Dự trữ để sử dụng trong tương lai.

0x01 READ_BYTES
~~~~~~~~~~~~~~~

.. list-table::
  :header-rows: 1

  * - CMD
    - DATAL
    - DATAH
    - DELAY

  * - 0x01
    - address to read data from (lower 7 bits, highest bit currently unused)
    - number of bytes to read
    - n * 10ms

Cũng cần chế độ chủ. Điều này rất hữu ích để kiểm tra xem trình điều khiển xe buýt chính của bạn có
xử lý đa chủ một cách chính xác. Bạn có thể kích hoạt testunit để đọc byte
từ một thiết bị khác trên xe buýt. Nếu chủ xe buýt đang thử nghiệm cũng muốn
truy cập vào xe buýt cùng một lúc, xe buýt sẽ bận rộn. Ví dụ để đọc 128
byte từ thiết bị 0x50 sau 50 mili giây trễ::

# i2cset -y 0 0x30 1 0x50 0x80 5 tôi

0x02 SMBUS_HOST_NOTIFY
~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
  :header-rows: 1

  * - CMD
    - DATAL
    - DATAH
    - DELAY

  * - 0x02
    - low byte of the status word to send
    - high byte of the status word to send
    - n * 10ms

Cũng cần chế độ chủ. Kiểm tra này sẽ gửi tin nhắn SMBUS_HOST_NOTIFY tới
chủ nhà. Lưu ý rằng từ trạng thái hiện bị bỏ qua trong Hạt nhân Linux.
Ví dụ gửi thông báo với từ trạng thái 0x6442 sau 10ms::

# i2cset -y 0 0x30 2 0x42 0x64 1 tôi

Nếu bộ điều khiển máy chủ hỗ trợ HostNotify, thông báo này có mức độ gỡ lỗi
sẽ xuất hiện (Linux 6.11 trở lên)::

Đã phát hiện HostNotify từ địa chỉ 0x30

0x03 SMBUS_BLOCK_PROC_CALL
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
  :header-rows: 1

  * - CMD
    - DATAL
    - DATAH
    - DELAY

  * - 0x03
    - 0x01 (i.e. one further byte will be written)
    - number of bytes to be sent back
    - leave out, partial command!

Lệnh một phần. Thử nghiệm này sẽ phản hồi lệnh gọi quy trình khối như được xác định bởi
đặc tả SMBus. Một byte dữ liệu được ghi xác định có bao nhiêu byte
sẽ được gửi lại trong lần chuyển đọc sau. Lưu ý rằng trong bài đọc này
chuyển, đơn vị kiểm tra sẽ thêm tiền tố vào độ dài của byte tiếp theo. Vì vậy, nếu
trình điều khiển xe buýt chủ của bạn mô phỏng các cuộc gọi SMBus giống như phần lớn, nó cần phải
hỗ trợ cờ I2C_M_RECV_LEN của i2c_msg. Đây là một trường hợp thử nghiệm tốt cho nó.
Dữ liệu được trả về bao gồm độ dài đầu tiên và sau đó là một mảng byte
từ độ dài-1 đến 0. Đây là một ví dụ mô phỏng
i2c_smbus_block_process_call() sử dụng i2ctransfer (bạn cần i2c-tools v4.2 hoặc
sau)::

# i2ctransfer -y 0 w3@0x30 3 1 0x10 r?
  0x10 0x0f 0x0e 0x0d 0x0c 0x0b 0x0a 0x09 0x08 0x07 0x06 0x05 0x04 0x03 0x02 0x01 0x00

0x04 GET_VERSION_WITH_REP_START
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
  :header-rows: 1

  * - CMD
    - DATAL
    - DATAH
    - DELAY

  * - 0x04
    - currently unused
    - currently unused
    - leave out, partial command!

Lệnh một phần. Sau khi gửi lệnh này, testunit sẽ trả lời thông báo đã đọc
thông báo có chuỗi phiên bản đã kết thúc NUL dựa trên UTS_RELEASE. đầu tiên
ký tự luôn là 'v' và độ dài của chuỗi phiên bản là tối đa
128 byte. Tuy nhiên, nó sẽ chỉ phản hồi nếu tin nhắn đã đọc được kết nối với
tin nhắn viết thông qua bắt đầu lặp đi lặp lại. Nếu trình điều khiển bộ điều khiển của bạn xử lý
lặp lại bắt đầu chính xác, điều này sẽ hoạt động ::

# i2ctransfer -y 0 w3@0x30 4 0 0 r128
  0x76 0x36 0x2e 0x31 0x31 0x2e 0x30 0x2d 0x72 0x63 0x31 0x2d 0x30 0x30 0x30 0x30 ...

Nếu bạn có i2c-tools 4.4 trở lên, bạn có thể in dữ liệu ra ngay::

# i2ctransfer -y -b 0 w3@0x30 4 0 0 r128
  v6.11.0-rc1-00009-gd37a1b4d3fd0

Sự kết hợp STOP/START giữa hai tin nhắn sẽ hoạt động ZZ0000ZZ vì chúng
không tương đương với REPEATED START. Ví dụ, điều này chỉ trả về
phản hồi mặc định::

# i2cset -y 0 0x30 4 0 0 tôi; i2cget -y 0 0x30
  0x00

0x05 SMBUS_ALERT_REQUEST
~~~~~~~~~~~~~~~~~~~~~~~~

.. list-table::
  :header-rows: 1

  * - CMD
    - DATAL
    - DATAH
    - DELAY

  * - 0x05
    - response value (7 MSBs interpreted as I2C address)
    - currently unused
    - n * 10ms

Thử nghiệm này tạo ra một ngắt thông qua chân SMBAlert mà bộ điều khiển máy chủ
phải xử lý. Pin phải được kết nối với thiết bị kiểm tra dưới dạng GPIO. Truy cập GPIO
không được phép ngủ. Hiện tại, điều này chỉ có thể được mô tả bằng phần sụn
nút. Vì vậy, đối với devicetree, bạn sẽ thêm một cái gì đó như thế này vào testunit
nút::

gpios = <&gpio1 24 GPIO_ACTIVE_LOW>;

Lệnh sau sẽ kích hoạt cảnh báo có phản hồi 0xc9 sau 1
giây chậm trễ::

# i2cset -y 0 0x30 5 0xc9 0x00 100 tôi

Nếu bộ điều khiển máy chủ hỗ trợ SMBusAlert, thông báo này có mức độ gỡ lỗi
sẽ xuất hiện::

smbus_alert 0-000c: SMBALERT# from dev 0x64, cờ 1

Thông báo này có thể xuất hiện nhiều lần vì testunit không phải là phần mềm
phần cứng và do đó có thể không phản ứng nhanh với phản hồi của máy chủ
đủ rồi. Tuy nhiên, số lượng ngắt chỉ nên tăng thêm một ::

# cat /proc/ngắt | grep smbus_alert
   93: 1 gpio-rcar 26 Edge smbus_alert

Nếu máy chủ không phản hồi cảnh báo trong vòng 1 giây, quá trình kiểm tra sẽ bị hủy
bị hủy bỏ và testunit sẽ báo lỗi.

Đối với thử nghiệm này, đơn vị thử nghiệm sẽ nhanh chóng bỏ địa chỉ được chỉ định và lắng nghe
trên Địa chỉ phản hồi cảnh báo SMBus (0x0c). Nó sẽ gán lại bản gốc của nó
địa chỉ sau đó.