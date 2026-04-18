.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-viapro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-viapro
========================

Bộ điều hợp được hỗ trợ:
  * VIA Technologies, Inc. VT82C596A/B
    Bảng dữ liệu: Đôi khi có sẵn tại trang web VIA

* VIA Technologies, Inc. VT82C686A/B
    Bảng dữ liệu: Đôi khi có sẵn tại trang web VIA

* VIA Technologies, Inc. VT8231, VT8233, VT8233A
    Bảng dữ liệu: có sẵn theo yêu cầu từ VIA

* VIA Technologies, Inc. VT8235, VT8237R, VT8237A, VT8237S, VT8251
    Bảng dữ liệu: có sẵn theo yêu cầu và dưới NDA từ VIA

* VIA Technologies, Inc. CX700
    Bảng dữ liệu: có sẵn theo yêu cầu và dưới NDA từ VIA

* VIA Technologies, Inc. VX800/VX820
    Bảng dữ liệu: có sẵn trên ZZ0000ZZ

* VIA Technologies, Inc. VX855/VX875
    Bảng dữ liệu: có sẵn trên ZZ0000ZZ

* VIA Technologies, Inc. VX900
    Bảng dữ liệu: có sẵn trên ZZ0000ZZ

tác giả:
	- Kyösti Mälkki <kmalkki@cc.hut.fi>,
	- Mark D. Studebaker <mdsxyz123@yahoo.com>,
	- Jean Delvare <jdelvare@suse.de>

Thông số mô-đun
-----------------

* lực: int
  Buộc kích hoạt bộ điều khiển SMBus. DANGEROUS!
* Force_addr: int
  Buộc kích hoạt SMBus tại địa chỉ đã cho. EXTREMELY DANGEROUS!

Sự miêu tả
-----------

i2c-viapro là trình điều khiển máy chủ SMBus thực sự dành cho bo mạch chủ với một trong các
hỗ trợ cầu phía nam VIA.

Danh sách ZZ0000ZZ của bạn phải hiển thị một trong những điều sau:

=========================================
 thiết bị 1106:3050 (VT82C596A chức năng 3)
 thiết bị 1106:3051 (VT82C596B chức năng 3)
 thiết bị 1106:3057 (VT82C686 chức năng 4)
 thiết bị 1106:3074 (VT8233)
 thiết bị 1106:3147 (VT8233A)
 thiết bị 1106:8235 (VT8231 chức năng 4)
 thiết bị 1106:3177 (VT8235)
 thiết bị 1106:3227 (VT8237R)
 thiết bị 1106:3337 (VT8237A)
 thiết bị 1106:3372 (VT8237S)
 thiết bị 1106:3287 (VT8251)
 thiết bị 1106:8324 (CX700)
 thiết bị 1106:8353 (VX800/VX820)
 thiết bị 1106:8409 (VX855/VX875)
 thiết bị 1106:8410 (VX900)
 =========================================

Nếu không có cái nào trong số này hiển thị, bạn nên tìm trong BIOS để biết các cài đặt như
kích hoạt ACPI / SMBus hoặc thậm chí USB.

Ngoại trừ các chip cũ nhất (VT82C596A/B, VT82C686A và hầu hết có lẽ
VT8231), trình điều khiển này hỗ trợ các giao dịch khối I2C. Những giao dịch như vậy
chủ yếu hữu ích để đọc và ghi vào EEPROM.

CX700/VX800/VX820 dường như cũng hỗ trợ SMBus PEC, mặc dù
trình điều khiển này chưa triển khai nó.
