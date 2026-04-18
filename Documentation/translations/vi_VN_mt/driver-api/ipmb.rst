.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/ipmb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Trình điều khiển IPMB cho MC vệ tinh
====================================

Bus quản lý nền tảng thông minh hoặc IPMB, là một
Bus I2C cung cấp kết nối tiêu chuẩn hóa giữa
các bảng khác nhau trong một khung. Sự kết nối này được
giữa quản lý ván chân tường (BMC) và thiết bị điện tử khung gầm.
IPMB cũng được liên kết với giao thức nhắn tin thông qua
Xe buýt IPMB.

Các thiết bị sử dụng IPMB thường là thiết bị quản lý
bộ điều khiển thực hiện các chức năng quản lý như phục vụ
giao diện bảng mặt trước, giám sát ván chân tường,
trình điều khiển đĩa trao đổi nóng trong khung hệ thống, v.v...

Khi IPMB được triển khai trong hệ thống, BMC sẽ đóng vai trò
bộ điều khiển để cấp quyền truy cập phần mềm hệ thống vào IPMB. BMC
gửi yêu cầu IPMI tới một thiết bị (thường là Quản lý vệ tinh
Bộ điều khiển hoặc MC vệ tinh) qua IPMB và thiết bị
gửi phản hồi trở lại BMC.

Để biết thêm thông tin về IPMB và định dạng của tin nhắn IPMB,
tham khảo thông số kỹ thuật IPMB và IPMI.

Trình điều khiển IPMB cho MC vệ tinh
----------------------------

ipmb-dev-int - Đây là trình điều khiển cần thiết trên MC vệ tinh để
nhận tin nhắn IPMB từ BMC và gửi phản hồi lại.
Trình điều khiển này hoạt động với trình điều khiển I2C và không gian người dùng
chương trình như OpenIPMI:

1) Đây là trình điều khiển phụ trợ nô lệ I2C. Vì vậy, nó định nghĩa một cuộc gọi lại
   chức năng đặt MC vệ tinh làm I2C phụ.
   Chức năng gọi lại này xử lý các yêu cầu IPMI đã nhận.

2) Nó xác định các chức năng đọc và ghi để cho phép người dùng
   chương trình không gian (như OpenIPMI) để giao tiếp với kernel.


Tải trình điều khiển IPMB
--------------------

Trình điều khiển cần được tải khi khởi động hoặc bằng tay trước.
Trước tiên, hãy đảm bảo bạn có những thứ sau trong tệp cấu hình của mình:
CONFIG_IPMB_DEVICE_INTERFACE=y

1) Nếu bạn muốn tải trình điều khiển khi khởi động:

a) Thêm mục này vào bảng ACPI của bạn, trong SMBus thích hợp::

Thiết bị (SMB0) // Ví dụ về bộ điều khiển máy chủ SMBus
     {
     Tên (_HID, "<HID dành riêng cho nhà cung cấp>") // HID dành riêng cho nhà cung cấp
     Tên (_UID, 0) // ID duy nhất của bộ điều khiển máy chủ cụ thể
     :
     :
       Thiết bị (IPMB)
       {
         Tên (_HID, "IPMB0001") // Giao diện thiết bị IPMB
         Tên (_UID, 0) // Mã định danh thiết bị duy nhất
       }
     }

b) Ví dụ về cây thiết bị::

&i2c2 {
            trạng thái = "được";

ipmb@10 {
                    tương thích = "ipmb-dev";
                    reg = ;
                    giao thức i2c;
            };
     };

Nếu việc xmit dữ liệu được thực hiện bằng khối i2c thô so với smbus
thì "giao thức i2c" cần được xác định như trên.

2) Thủ công từ Linux::

modprobe ipmb-dev-int


Khởi tạo thiết bị
----------------------

Sau khi tải trình điều khiển, bạn có thể khởi tạo thiết bị dưới dạng
được mô tả trong 'Documentation/i2c/instantiating-devices.rst'.
Nếu bạn có nhiều BMC, mỗi BMC được kết nối với MC vệ tinh của bạn thông qua
một bus I2C khác, bạn có thể khởi tạo một thiết bị cho mỗi bus
những BMC đó.

Tên của thiết bị được khởi tạo chứa số bus I2C
liên kết với nó như sau::

BMC1 ------ IPMB/I2C xe buýt 1 ---------|   /dev/ipmb-1
				MC vệ tinh
  BMC1 ------ IPMB/I2C xe buýt 2 ---------|   /dev/ipmb-2

Ví dụ: bạn có thể khởi tạo thiết bị ipmb-dev-int từ
không gian người dùng tại địa chỉ 7 bit 0x10 trên bus 2::

# echo ipmb-dev 0x1010 > /sys/bus/i2c/devices/i2c-2/new_device

Điều này sẽ tạo tệp thiết bị /dev/ipmb-2, có thể truy cập được
bởi chương trình không gian người dùng. Thiết bị cần được khởi tạo
trước khi chạy chương trình không gian người dùng.
