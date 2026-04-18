.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/smbus-protocol.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Giao thức SMBus
==================

Sau đây là bản tóm tắt về giao thức SMBus. Nó áp dụng cho
tất cả các phiên bản của giao thức (1.0, 1.1 và 2.0).
Một số tính năng giao thức không được hỗ trợ bởi
gói này được mô tả ngắn gọn ở cuối tài liệu này.

Một số bộ điều hợp chỉ hiểu giao thức SMBus (Bus quản lý hệ thống),
là tập hợp con của giao thức I2C. May mắn thay, nhiều thiết bị sử dụng
chỉ có cùng một tập hợp con, điều này giúp có thể đặt chúng trên SMBus.

Nếu bạn viết trình điều khiển cho một số thiết bị I2C, vui lòng thử sử dụng SMBus
các lệnh nếu có thể (nếu thiết bị chỉ sử dụng tập hợp con đó của
Giao thức I2C). Điều này giúp có thể sử dụng trình điều khiển thiết bị trên cả hai
Bộ điều hợp SMBus và bộ điều hợp I2C (bộ lệnh SMBus được tự động
được dịch sang I2C trên bộ điều hợp I2C, nhưng không thể dịch các lệnh I2C đơn giản
được xử lý hoàn toàn trên hầu hết các bộ điều hợp SMBus thuần túy).

Dưới đây là danh sách các hoạt động của giao thức SMBus và các chức năng thực thi
họ.  Lưu ý rằng tên được sử dụng trong đặc tả giao thức SMBus thường
không khớp với các tên hàm này.  Đối với một số hoạt động vượt qua
byte dữ liệu đơn, các hàm sử dụng tên hoạt động giao thức SMBus sẽ thực thi
một hoạt động giao thức khác hoàn toàn.

Mỗi loại giao dịch tương ứng với một cờ chức năng. Trước khi gọi một
chức năng giao dịch, trình điều khiển thiết bị phải luôn kiểm tra (chỉ một lần) xem
cờ chức năng tương ứng để đảm bảo rằng I2C cơ bản
adapter hỗ trợ giao dịch được đề cập. Xem
Documentation/i2c/functionity.rst để biết chi tiết.


Chìa khóa ký hiệu
==============

==================================================================================
S Điều kiện bắt đầu
Sr Điều kiện bắt đầu lặp lại, dùng để chuyển từ ghi sang
                chế độ đọc.
P Điều kiện dừng
Rd/Wr (1 bit) Bit đọc/ghi. Rd bằng 1, Wr bằng 0.
Bit A, NA (1 bit) Xác nhận (ACK) và Không xác nhận (NACK)
Addr (7 bit) I2C Địa chỉ 7 bit. Lưu ý rằng điều này có thể được mở rộng thành
                lấy địa chỉ I2C 10 bit.
Comm (8 bit) Byte lệnh, byte dữ liệu thường chọn một thanh ghi trên
                thiết bị.
Dữ liệu (8 bit) Một byte dữ liệu đơn giản. DataLow và DataHigh đại diện cho mức thấp và
                byte cao của một từ 16 bit.
Đếm (8 bit) Một byte dữ liệu chứa độ dài của một thao tác khối.

[..] Dữ liệu được gửi bởi thiết bị I2C, trái ngược với dữ liệu do máy chủ gửi
                bộ chuyển đổi.
==================================================================================


Lệnh nhanh SMBus
===================

Thao tác này sẽ gửi một bit tới thiết bị, tại vị trí của bit Rd/Wr::

S Cộng Rd/Wr [A] P

Cờ chức năng: I2C_FUNC_SMBUS_QUICK


SMBus nhận byte
==================

Được triển khai bởi i2c_smbus_read_byte()

Điều này đọc một byte đơn từ một thiết bị mà không chỉ định thiết bị
đăng ký. Một số thiết bị đơn giản đến mức giao diện này là đủ; cho
những người khác, đó là một cách viết tắt nếu bạn muốn đọc cùng một thanh ghi như trong
lệnh SMBus trước đó::

S Addr Rd [A] [Dữ liệu] NA P

Cờ chức năng: I2C_FUNC_SMBUS_READ_BYTE


SMBus gửi byte
===============

Được triển khai bởi i2c_smbus_write_byte()

Hoạt động này ngược lại với Nhận Byte: nó gửi một byte đơn
tới một thiết bị.  Xem Nhận Byte để biết thêm thông tin.

::

S Addr Wr [A] Dữ liệu [A] P

Cờ chức năng: I2C_FUNC_SMBUS_WRITE_BYTE


Byte đọc SMBus
===============

Được triển khai bởi i2c_smbus_read_byte_data()

Điều này đọc một byte đơn từ một thiết bị, từ một thanh ghi được chỉ định.
Thanh ghi được chỉ định thông qua Comm byte::

S Addr Wr [A] Comm [A] Sr Addr Rd [A] [Dữ liệu] NA P

Cờ chức năng: I2C_FUNC_SMBUS_READ_BYTE_DATA


SMBus đọc từ
===============

Được triển khai bởi i2c_smbus_read_word_data()

Thao tác này rất giống Read Byte; một lần nữa, dữ liệu được đọc từ một
thiết bị, từ một thanh ghi được chỉ định được chỉ định thông qua Comm
byte. Nhưng lần này, dữ liệu là một từ hoàn chỉnh (16 bit)::

S Addr Wr [A] Comm [A] Sr Addr Rd [A] [DataLow] A [DataHigh] NA P

Cờ chức năng: I2C_FUNC_SMBUS_READ_WORD_DATA

Lưu ý chức năng tiện lợi i2c_smbus_read_word_swapped() là
có sẵn để đọc trong đó hai byte dữ liệu theo cách khác
xung quanh (không tuân thủ SMBus, nhưng rất phổ biến.)


SMBus ghi byte
================

Được triển khai bởi i2c_smbus_write_byte_data()

Điều này ghi một byte đơn vào một thiết bị, vào một thanh ghi được chỉ định. các
thanh ghi được chỉ định thông qua byte Comm. Điều này trái ngược với
hoạt động Read Byte.

::

S Addr Wr [A] Comm [A] Dữ liệu [A] P

Cờ chức năng: I2C_FUNC_SMBUS_WRITE_BYTE_DATA


SMBus Viết Word
================

Được triển khai bởi i2c_smbus_write_word_data()

Điều này trái ngược với thao tác Đọc Word. 16 bit
dữ liệu được ghi vào một thiết bị, vào thanh ghi được chỉ định
được chỉ định thông qua byte Comm::

S Addr Wr [A] Comm [A] DataLow [A] DataHigh [A] P

Cờ chức năng: I2C_FUNC_SMBUS_WRITE_WORD_DATA

Lưu ý chức năng tiện lợi i2c_smbus_write_word_swapped() là
có sẵn để ghi trong đó hai byte dữ liệu theo cách khác
xung quanh (không tuân thủ SMBus, nhưng rất phổ biến.)


Cuộc gọi xử lý SMBus
==================

Lệnh này chọn một thanh ghi thiết bị (thông qua byte Comm), gửi
16 bit dữ liệu vào nó và đọc lại 16 bit dữ liệu ::

S Addr Wr [A] Comm [A] DataLow [A] DataHigh [A]
                              Sr Addr Rd [A] [DataLow] A [DataHigh] NA P

Cờ chức năng: I2C_FUNC_SMBUS_PROC_CALL


Đọc khối SMBus
================

Được triển khai bởi i2c_smbus_read_block_data()

Lệnh này đọc một khối có kích thước lên tới 32 byte từ một thiết bị, từ một
thanh ghi được chỉ định được chỉ định thông qua byte Comm. số tiền
của dữ liệu được thiết bị chỉ định trong byte Đếm.

::

S Addr Wr [A] Comm [A]
            Sr Addr Rd [A] [Đếm] A [Dữ liệu] A [Dữ liệu] A ... A [Dữ liệu] NA P

Cờ chức năng: I2C_FUNC_SMBUS_READ_BLOCK_DATA


Viết khối SMBus
=================

Được triển khai bởi i2c_smbus_write_block_data()

Ngược lại với lệnh Block Read, lệnh này ghi tối đa 32 byte vào
một thiết bị, tới một thanh ghi được chỉ định được chỉ định thông qua
Byte giao tiếp. Lượng dữ liệu được chỉ định trong byte Count.

::

S Addr Wr [A] Comm [A] Đếm [A] Dữ liệu [A] Dữ liệu [A] ... [A] Dữ liệu [A] P

Cờ chức năng: I2C_FUNC_SMBUS_WRITE_BLOCK_DATA


Ghi khối SMBus - Cuộc gọi quy trình đọc khối
===========================================

SMBus Block Write - Cuộc gọi xử lý đọc khối đã được giới thiệu trong
Bản sửa đổi 2.0 của thông số kỹ thuật.

Lệnh này chọn một thanh ghi thiết bị (thông qua byte Comm), gửi
1 đến 31 byte dữ liệu cho nó và đọc lại 1 đến 31 byte dữ liệu ::

S Addr Wr [A] Comm [A] Đếm [A] Dữ liệu [A] ...
                              Sr Addr Rd [A] [Đếm] A [Dữ liệu] ... A P

Cờ chức năng: I2C_FUNC_SMBUS_BLOCK_PROC_CALL


Thông báo máy chủ SMBus
=================

Lệnh này được gửi từ thiết bị SMBus đóng vai trò là thiết bị chủ tới
Máy chủ SMBus hoạt động như một nô lệ.
Nó có dạng tương tự như Write Word, với mã lệnh được thay thế bằng
địa chỉ của thiết bị cảnh báo

::

[S] [HostAddr] [Wr] A [DevAddr] A [DataLow] A [DataHigh] A [P]

Điều này được thực hiện theo cách sau trong nhân Linux:

* Trình điều khiển bus I2C hỗ trợ Thông báo máy chủ SMBus sẽ báo cáo
  I2C_FUNC_SMBUS_HOST_NOTIFY.
* Trình điều khiển xe buýt I2C kích hoạt Máy chủ SMBus Thông báo bằng cuộc gọi tới
  i2c_handle_smbus_host_notify().
* Trình điều khiển I2C dành cho các thiết bị có thể kích hoạt Thông báo máy chủ SMBus sẽ có
  client->irq được gán cho Máy chủ Thông báo cho IRQ nếu không có ai khác chỉ định máy chủ khác.

Hiện tại không có cách nào để truy xuất tham số dữ liệu từ máy khách.


Kiểm tra lỗi gói (PEC)
===========================

Kiểm tra lỗi gói đã được giới thiệu trong Bản sửa đổi 1.1 của thông số kỹ thuật.

PEC thêm byte kiểm tra lỗi CRC-8 để truyền bằng cách sử dụng nó ngay lập tức
trước khi chấm dứt STOP.


Giao thức phân giải địa chỉ (ARP)
=================================

Giao thức phân giải địa chỉ được giới thiệu trong Phiên bản 2.0 của
đặc điểm kỹ thuật. Đây là một giao thức lớp cao hơn sử dụng
tin nhắn trên.

ARP bổ sung thêm tính năng liệt kê thiết bị và gán địa chỉ động cho
giao thức. Tất cả các giao tiếp ARP đều sử dụng địa chỉ nô lệ 0x61 và
yêu cầu tổng kiểm tra PEC.


Cảnh báo SMBus
===========

Cảnh báo SMBus đã được giới thiệu trong Bản sửa đổi 1.0 của thông số kỹ thuật.

Giao thức cảnh báo SMBus cho phép một số thiết bị phụ thuộc SMBus chia sẻ một
chốt ngắt đơn trên SMBus master, trong khi vẫn cho phép master
để biết nô lệ nào đã kích hoạt ngắt.

Điều này được thực hiện theo cách sau trong nhân Linux:

* Trình điều khiển xe buýt I2C hỗ trợ cảnh báo SMBus nên gọi
  i2c_new_smbus_alert_device() để cài đặt hỗ trợ cảnh báo SMBus.
* Trình điều khiển I2C dành cho các thiết bị có thể kích hoạt cảnh báo SMBus nên triển khai
  lệnh gọi lại cảnh báo() tùy chọn.


Giao dịch khối I2C
======================

Các giao dịch khối I2C sau đây tương tự như Đọc khối SMBus
và Thao tác ghi, ngoại trừ các thao tác này không có byte Đếm. Họ là
được hỗ trợ bởi lớp SMBus và được mô tả đầy đủ ở đây, nhưng
chúng là ZZ0000ZZ được xác định bởi đặc tả SMBus.

Giao dịch khối I2C không giới hạn số byte được truyền
nhưng lớp SMBus đặt giới hạn là 32 byte.


Đọc khối I2C
==============

Được triển khai bởi i2c_smbus_read_i2c_block_data()

Lệnh này đọc một khối byte từ một thiết bị, từ một
thanh ghi được chỉ định được chỉ định thông qua byte Comm::

S Addr Wr [A] Comm [A]
            Sr Addr Rd [A] [Dữ liệu] A [Dữ liệu] A ... A [Dữ liệu] NA P

Cờ chức năng: I2C_FUNC_SMBUS_READ_I2C_BLOCK


Ghi khối I2C
===============

Được triển khai bởi i2c_smbus_write_i2c_block_data()

Ngược lại với lệnh Block Read, lệnh này ghi byte vào
một thiết bị, tới một thanh ghi được chỉ định được chỉ định thông qua
Byte giao tiếp. Lưu ý rằng độ dài lệnh 0, 2 hoặc nhiều byte là
được hỗ trợ vì chúng không thể phân biệt được với dữ liệu.

::

S Addr Wr [A] Comm [A] Dữ liệu [A] Dữ liệu [A] ... [A] Dữ liệu [A] P

Cờ chức năng: I2C_FUNC_SMBUS_WRITE_I2C_BLOCK
