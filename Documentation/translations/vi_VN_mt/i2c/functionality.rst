.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/functionality.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Chức năng I2C/SMBus
==========================

INTRODUCTION
------------

Bởi vì không phải mọi bộ điều hợp I2C hoặc SMBus đều triển khai mọi thứ trong
Thông số kỹ thuật của I2C, khách hàng không thể tin tưởng rằng mọi thứ họ cần
được triển khai khi được cung cấp tùy chọn gắn vào bộ chuyển đổi:
khách hàng cần một số cách để kiểm tra xem bộ chuyển đổi có cần thiết không
chức năng.


FUNCTIONALITY CONSTANTS
-----------------------

Để có danh sách các hằng số chức năng cập nhật nhất, vui lòng kiểm tra
<uapi/linux/i2c.h>!

===================================================================================
  I2C_FUNC_I2C Các lệnh cấp độ i2c đơn giản (SMBus thuần túy
                                  bộ điều hợp thường không thể làm được những điều này)
  I2C_FUNC_10BIT_ADDR Xử lý phần mở rộng địa chỉ 10 bit
  I2C_FUNC_PROTOCOL_MANGLING Biết về I2C_M_IGNORE_NAK,
                                  I2C_M_REV_DIR_ADDR và I2C_M_NO_RD_ACK
                                  cờ (sửa đổi giao thức I2C!)
  I2C_FUNC_NOSTART Có thể bỏ qua trình tự bắt đầu lặp lại
  I2C_FUNC_SMBUS_QUICK Xử lý lệnh SMBus write_quick
  I2C_FUNC_SMBUS_READ_BYTE Xử lý lệnh SMBus read_byte
  I2C_FUNC_SMBUS_WRITE_BYTE Xử lý lệnh SMBus write_byte
  I2C_FUNC_SMBUS_READ_BYTE_DATA Xử lý lệnh SMBus read_byte_data
  I2C_FUNC_SMBUS_WRITE_BYTE_DATA Xử lý lệnh SMBus write_byte_data
  I2C_FUNC_SMBUS_READ_WORD_DATA Xử lý lệnh SMBus read_word_data
  I2C_FUNC_SMBUS_WRITE_WORD_DATA Xử lý lệnh SMBus write_byte_data
  I2C_FUNC_SMBUS_PROC_CALL Xử lý lệnh SMBus process_call
  I2C_FUNC_SMBUS_READ_BLOCK_DATA Xử lý lệnh SMBus read_block_data
  I2C_FUNC_SMBUS_WRITE_BLOCK_DATA Xử lý lệnh SMBus write_block_data
  I2C_FUNC_SMBUS_READ_I2C_BLOCK Xử lý lệnh SMBus read_i2c_block_data
  I2C_FUNC_SMBUS_WRITE_I2C_BLOCK Xử lý lệnh SMBus write_i2c_block_data
  ===================================================================================

Một vài sự kết hợp của các cờ trên cũng được xác định để thuận tiện cho bạn:

====================================================================
  I2C_FUNC_SMBUS_BYTE Xử lý read_byte SMBus
                                  và lệnh write_byte
  I2C_FUNC_SMBUS_BYTE_DATA Xử lý read_byte_data SMBus
                                  và lệnh write_byte_data
  I2C_FUNC_SMBUS_WORD_DATA Xử lý read_word_data SMBus
                                  và lệnh write_word_data
  I2C_FUNC_SMBUS_BLOCK_DATA Xử lý read_block_data SMBus
                                  và lệnh write_block_data
  I2C_FUNC_SMBUS_I2C_BLOCK Xử lý SMBus read_i2c_block_data
                                  và lệnh write_i2c_block_data
  I2C_FUNC_SMBUS_EMUL Xử lý tất cả các lệnh SMBus có thể
                                  được mô phỏng bằng bộ chuyển đổi I2C thực (sử dụng
                                  lớp mô phỏng trong suốt)
  ====================================================================

Trong các phiên bản kernel trước 3.5 I2C_FUNC_NOSTART đã được triển khai dưới dạng
một phần của I2C_FUNC_PROTOCOL_MANGLING.


ADAPTER IMPLEMENTATION
----------------------

Khi bạn viết trình điều khiển bộ điều hợp mới, bạn sẽ phải triển khai một
chức năng gọi lại ZZ0000ZZ. Việc triển khai điển hình được đưa ra
bên dưới.

Bộ điều hợp chỉ dành cho SMBus thông thường sẽ liệt kê tất cả các giao dịch SMBus mà nó
hỗ trợ. Ví dụ này xuất phát từ trình điều khiển i2c-piix4 ::

u32 tĩnh piix4_func(struct i2c_adapter *adapter)
  {
	trả lại I2C_FUNC_SMBUS_QUICK ZZ0000ZZ
	       I2C_FUNC_SMBUS_BYTE_DATA ZZ0001ZZ
	       I2C_FUNC_SMBUS_BLOCK_DATA;
  }

Bộ điều hợp full-I2C điển hình sẽ sử dụng thông tin sau (từ i2c-pxa
người lái xe)::

u32 tĩnh i2c_pxa_functionity(struct i2c_adapter *adap)
  {
	trả lại I2C_FUNC_I2C | I2C_FUNC_SMBUS_EMUL;
  }

I2C_FUNC_SMBUS_EMUL bao gồm tất cả các giao dịch SMBus (với
bổ sung các giao dịch khối I2C) mà i2c-core có thể mô phỏng bằng cách sử dụng
I2C_FUNC_I2C mà không cần bất kỳ sự trợ giúp nào từ trình điều khiển bộ chuyển đổi. Ý tưởng là
để cho phép trình điều khiển máy khách kiểm tra sự hỗ trợ của các chức năng SMBus
mà không cần quan tâm liệu các chức năng nói trên có được thực hiện trong
phần cứng bằng bộ chuyển đổi hoặc được mô phỏng trong phần mềm bằng i2c-core ở trên cùng
của bộ chuyển đổi I2C.


CLIENT CHECKING
---------------

Trước khi khách hàng cố gắng gắn vào bộ chuyển đổi hoặc thậm chí thực hiện các thử nghiệm để kiểm tra
liệu một trong các thiết bị mà nó hỗ trợ có trên bộ chuyển đổi hay không, nó sẽ
kiểm tra xem các chức năng cần thiết có hiện diện hay không. Cách điển hình để làm
đây là (từ trình điều khiển lm75)::

int tĩnh lm75_Detect (...)
  {
	(...)
	if (!i2c_check_functionity(adapter, I2C_FUNC_SMBUS_BYTE_DATA |
				     I2C_FUNC_SMBUS_WORD_DATA))
		đi đến lối ra;
	(...)
  }

Tại đây, trình điều khiển lm75 sẽ kiểm tra xem bộ điều hợp có thể thực hiện cả dữ liệu byte SMBus hay không
và giao dịch dữ liệu từ SMBus. Nếu không thì trình điều khiển sẽ không hoạt động
bộ chuyển đổi này và không có ích gì khi tiếp tục. Nếu việc kiểm tra ở trên là
thành công thì người lái xe biết rằng nó có thể gọi như sau
các hàm: i2c_smbus_read_byte_data(), i2c_smbus_write_byte_data(),
i2c_smbus_read_word_data() và i2c_smbus_write_word_data(). Như một quy luật của
ngón tay cái, các hằng số chức năng mà bạn kiểm tra bằng
i2c_check_functionity() phải khớp chính xác với các hàm i2c_smbus_*
mà tài xế của bạn đang gọi.

Lưu ý rằng việc kiểm tra ở trên không cho biết liệu các chức năng có
được triển khai trong phần cứng bằng bộ điều hợp cơ bản hoặc được mô phỏng trong
phần mềm của i2c-core. Trình điều khiển máy khách không cần phải quan tâm đến điều này, vì
i2c-core sẽ triển khai các giao dịch SMBus một cách minh bạch trên I2C
bộ điều hợp.


CHECKING THROUGH /DEV
---------------------

Nếu bạn cố gắng truy cập một bộ điều hợp từ một chương trình không gian người dùng, bạn sẽ có
để sử dụng giao diện /dev. Bạn vẫn sẽ phải kiểm tra xem liệu
Tất nhiên, chức năng bạn cần sẽ được hỗ trợ. Việc này được thực hiện bằng cách sử dụng
I2C_FUNCS ioctl. Một ví dụ, được điều chỉnh từ chương trình i2c detect, là
dưới đây::

tập tin int;
  if (tệp = open("/dev/i2c-0", O_RDWR) < 0) {
	/* Một số cách xử lý lỗi */
	thoát (1);
  }
  if (ioctl(file, I2C_FUNCS, &funcs) < 0) {
	/* Một số cách xử lý lỗi */
	thoát (1);
  }
  if (!(funcs & I2C_FUNC_SMBUS_QUICK)) {
	/* Rất tiếc, chức năng cần thiết (chức năng SMBus write_quick) là
           không có sẵn! */
	thoát (1);
  }
  /* Bây giờ đã an toàn khi sử dụng lệnh SMBus write_quick */
