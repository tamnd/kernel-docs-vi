.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/rc/rc-protos.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _Remote_controllers_Protocols:

****************************************
Giao thức và mã quét điều khiển từ xa
*****************************************

IR được mã hóa thành một chuỗi các xung và khoảng trắng, sử dụng một giao thức. Những cái này
giao thức có thể mã hóa, ví dụ: một địa chỉ (thiết bị nào sẽ phản hồi) và một
lệnh: nó nên làm gì. Các giá trị này không phải lúc nào cũng nhất quán
trên các thiết bị khác nhau cho một giao thức nhất định.

Do đó, đầu ra của bộ giải mã IR là scancode; một u32 độc thân
giá trị. Sử dụng bảng sơ đồ bàn phím, điều này có thể được ánh xạ tới mã khóa linux.

Những thứ khác cũng có thể được mã hóa. Một số giao thức IR mã hóa bit chuyển đổi; cái này
là để phân biệt xem nút đó đang được giữ hay đã được
thả ra và nhấn lại. Nếu đã được thả ra và nhấn lại,
bit chuyển đổi sẽ đảo ngược từ thông báo IR này sang thông báo tiếp theo.

Một số điều khiển từ xa có thiết bị dạng con trỏ có thể được sử dụng để điều khiển
chuột; một số hệ thống điều hòa không khí có thể có nhiệt độ mục tiêu
mục tiêu được đặt trong IR.

Sau đây là các giao thức mà kernel biết và liệt kê
cách mã hóa scancode cho mỗi giao thức.

RC-5 (RC_PROTO_RC5)
-------------------

Giao thức IR này sử dụng mã hóa manchester để mã hóa 14 bit. có một
mô tả chi tiết tại đây ZZ0000ZZ

Mã hóa scancode là ZZ0000ZZ phù hợp với daemon lirc (lircd) RC5
giao thức hoặc bộ giải mã manchester BPF.

.. flat-table:: rc5 bits scancode mapping
   :widths:       1 1 2

   * - rc-5 bit

     - scancode bit

     - description

   * - 1

     - none

     - Start bit, always set

   * - 1

     - 6 (inverted)

     - 2nd start bit in rc5,  re-used as 6th command bit

   * - 1

     - none

     - Toggle bit

   * - 5

     - 8 to 13

     - Address

   * - 6

     - 0 to 5

     - Command

Có một biến thể của RC5 được gọi là RC5x hoặc RC5 mở rộng
trong đó bit dừng thứ hai là bit lệnh thứ 6, nhưng bị đảo ngược.
Điều này được thực hiện để mã quét và mã hóa tương thích với các mã hiện có
đề án. Bit này được lưu trữ trong bit 6 của scancode, đảo ngược. Đây là
được thực hiện để giữ cho nó tương thích với RC-5 đơn giản nơi có hai bit bắt đầu.

RC-5-sz (RC_PROTO_RC5_SZ)
-------------------------
Cái này giống RC-5 nhưng dài hơn một chút. Scancode được mã hóa
khác nhau.

.. flat-table:: rc-5-sz bits scancode mapping
   :widths:       1 1 2

   * - rc-5-sz bits

     - scancode bit

     - description

   * - 1

     - none

     - Start bit, always set

   * - 1

     - 13

     - Address bit

   * - 1

     - none

     - Toggle bit

   * - 6

     - 6 to 11

     - Address

   * - 6

     - 0 to 5

     - Command

RC-5x-20 (RC_PROTO_RC5X_20)
---------------------------

RC-5 này được mở rộng để mã hóa 20 bit. Đó là khoảng thời gian 3555 micro giây
sau bit thứ 8.

.. flat-table:: rc-5x-20 bits scancode mapping
   :widths:       1 1 2

   * - rc-5-sz bits

     - scancode bit

     - description

   * - 1

     - none

     - Start bit, always set

   * - 1

     - 14

     - Address bit

   * - 1

     - none

     - Toggle bit

   * - 5

     - 16 to 20

     - Address

   * - 6

     - 8 to 13

     - Address

   * - 6

     - 0 to 5

     - Command


jvc (RC_PROTO_JVC)
------------------

Giao thức jvc rất giống nec, không có giá trị đảo ngược. Đó là
được mô tả ở đây ZZ0000ZZ

Scancode là giá trị 16 bit, trong đó địa chỉ là 8 bit thấp hơn
và lệnh 8 bit cao hơn; điều này bị đảo ngược so với thứ tự IR.

sony-12 (RC_PROTO_SONY12)
-------------------------

Giao thức sony là mã hóa độ rộng xung. Có ba biến thể,
chỉ khác nhau về số bit và mã hóa scancode.

.. flat-table:: sony-12 bits scancode mapping
   :widths:       1 1 2

   * - sony-12 bits

     - scancode bit

     - description

   * - 5

     - 16 to 20

     - device

   * - 7

     - 0 to 6

     - function

sony-15 (RC_PROTO_SONY15)
-------------------------

Giao thức sony là mã hóa độ rộng xung. Có ba biến thể,
chỉ khác nhau về số bit và mã hóa scancode.

.. flat-table:: sony-12 bits scancode mapping
   :widths:       1 1 2

   * - sony-12 bits

     - scancode bit

     - description

   * - 8

     - 16 to 23

     - device

   * - 7

     - 0 to 6

     - function

sony-20 (RC_PROTO_SONY20)
-------------------------

Giao thức sony là mã hóa độ rộng xung. Có ba biến thể,
chỉ khác nhau về số bit và mã hóa scancode.

.. flat-table:: sony-20 bits scancode mapping
   :widths:       1 1 2

   * - sony-20 bits

     - scancode bit

     - description

   * - 5

     - 16 to 20

     - device

   * - 7

     - 0 to 7

     - device

   * - 8

     - 8 to 15

     - extended bits

không cần (RC_PROTO_NEC)
------------------

Giao thức nec mã hóa địa chỉ 8 bit và lệnh 8 bit. Đó là
được mô tả ở đây ZZ0000ZZ Lưu ý
rằng giao thức sẽ gửi bit có trọng số thấp nhất trước tiên.

Để kiểm tra, giao thức nec sẽ gửi địa chỉ và lệnh hai lần; cái
lần thứ hai nó bị đảo ngược. Điều này được thực hiện để xác minh.

Một thông báo IR đơn giản có 16 bit; 8 bit cao là địa chỉ
và 8 bit thấp là lệnh.

nec-x (RC_PROTO_NECX)
---------------------

nec mở rộng có địa chỉ 16 bit và lệnh 8 bit. Điều này được mã hóa
dưới dạng giá trị 24 bit như bạn mong đợi, với lệnh 8 bit thấp hơn
và 16 bit trên là địa chỉ.

nec-32 (RC_PROTO_NEC32)
-----------------------

nec-32 không gửi địa chỉ đảo ngược hoặc lệnh đảo ngược; cái
toàn bộ tin nhắn, tất cả 32 bit, đều được sử dụng.

Để mã này được giải mã chính xác, 8 bit thứ hai không được là
giá trị đảo ngược của 8 bit đầu tiên và 8 bit cuối cùng không được là giá trị
giá trị đảo ngược của giá trị 8 bit thứ ba.

Scancode có cách mã hóa hơi khác thường.

.. flat-table:: nec-32 bits scancode mapping

   * - nec-32 bits

     - scancode bit

   * - First 8 bits

     - 16 to 23

   * - Second 8 bits

     - 24 to 31

   * - Third 8 bits

     - 0 to 7

   * - Fourth 8 bits

     - 8 to 15

sanyo (RC_PROTO_SANYO)
----------------------

Giao thức sanyo giống như giao thức nec nhưng có địa chỉ 13 bit
thay vì 8 bit. Cả địa chỉ và lệnh đều được theo sau bởi
phiên bản đảo ngược của chúng, nhưng chúng không có trong scancode.

Bis 8 đến 20 của scancode là địa chỉ 13 bit và 8 bit thấp hơn
bit là lệnh.

mcir2-kbd (RC_PROTO_MCIR2_KBD)
------------------------------

Giao thức này được tạo bởi bàn phím Microsoft MCE cho bàn phím
sự kiện. Tham khảo ir-mce_kbd-decoding.c để xem nó được mã hóa như thế nào.

mcir2-mse (RC_PROTO_MCIR2_MSE)
------------------------------

Giao thức này được tạo bởi bàn phím Microsoft MCE cho con trỏ
sự kiện. Tham khảo ir-mce_kbd-decoding.c để xem nó được mã hóa như thế nào.

RC-6-0 (RC_PROTO_RC6_0)
-----------------------

Đây là RC-6 ở chế độ 0. RC-6 được mô tả ở đây
ZZ0000ZZ
Scancode chính xác là 16 bit như trong giao thức. Ngoài ra còn có một
chuyển đổi bit.

RC-6-6a-20 (RC_PROTO_RC6_6A_20)
-------------------------------

Đây là RC-6 ở chế độ 6a, 20 bit. RC-6 được mô tả ở đây
ZZ0000ZZ
Scancode chính xác là 20 bit
như trong giao thức. Ngoài ra còn có một chút chuyển đổi.

RC-6-6a-24 (RC_PROTO_RC6_6A_24)
-------------------------------

Đây là RC-6 ở chế độ 6a, 24 bit. RC-6 được mô tả ở đây
ZZ0000ZZ
Scancode chính xác là 24 bit
như trong giao thức. Ngoài ra còn có một chút chuyển đổi.

RC-6-6a-32 (RC_PROTO_RC6_6A_32)
-------------------------------

Đây là RC-6 ở chế độ 6a, 32 bit. RC-6 được mô tả ở đây
ZZ0000ZZ
16 bit trên là nhà cung cấp,
và 16 bit thấp hơn là các bit dành riêng cho nhà cung cấp. Giao thức này là
đối với biến thể MCE không phải của Microsoft (nhà cung cấp != 0x800f).


RC-6-mce (RC_PROTO_RC6_MCE)
---------------------------

Đây là RC-6 ở chế độ 6a, 32 bit. 16 bit trên là nhà cung cấp,
và 16 bit thấp hơn là các bit dành riêng cho nhà cung cấp. Giao thức này là
đối với biến thể Microsoft MCE (nhà cung cấp = 0x800f). Bit chuyển đổi trong
bản thân giao thức bị bỏ qua và bit thứ 16 sẽ được lấy làm nút chuyển đổi
chút.

sắc nét (RC_PROTO_SHARP)
----------------------

Đây là giao thức được sử dụng bởi Sharp VCR, được mô tả ở đây
ZZ0000ZZ Có một thời gian rất dài
(40ms) khoảng cách giữa giá trị bình thường và giá trị đảo ngược và một số bộ thu IR
không thể giải mã điều này.

Có một địa chỉ 5 bit và lệnh 8 bit. Trong scancode địa chỉ là
ở bit 8 đến 12 và lệnh ở bit 0 đến 7.

xmp (RC_PROTO_XMP)
------------------

Giao thức này có nhiều phiên bản và chỉ hỗ trợ phiên bản 1. tham khảo
tới bộ giải mã (ir-xmp-decode.c) để xem nó được mã hóa như thế nào.


cec (RC_PROTO_CEC)
------------------

Đây không phải là giao thức IR, đây là giao thức trên CEC. CEC
cơ sở hạ tầng sử dụng RC-core để xử lý các lệnh CEC, do đó chúng
có thể dễ dàng được ánh xạ lại.

imon (RC_PROTO_IMON)
--------------------

Giao thức này được sử dụng bởi điều khiển từ xa Antec Veris/SoundGraph iMON.

giao thức
mô tả cả việc nhấn nút và chuyển động của con trỏ. Giao thức mã hóa
31 bit và scancode đơn giản là 31 bit với bit trên cùng luôn bằng 0.

RC-mm-12 (RC_PROTO_RCMM12)
--------------------------

Giao thức RC-mm được mô tả ở đây
ZZ0000ZZ Scancode đơn giản là
12 bit.

RC-mm-24 (RC_PROTO_RCMM24)
--------------------------

Giao thức RC-mm được mô tả ở đây
ZZ0000ZZ Scancode đơn giản là
24 bit.

RC-mm-32 (RC_PROTO_RCMM32)
--------------------------

Giao thức RC-mm được mô tả ở đây
ZZ0000ZZ Scancode đơn giản là
32 bit.

xbox-dvd (RC_PROTO_XBOX_DVD)
----------------------------

Giao thức này được sử dụng bởi Xbox DVD Remote, được tạo cho phiên bản gốc
Xbox. Không có bộ giải mã hoặc bộ mã hóa trong kernel cho giao thức này. cái USB
thiết bị giải mã giao thức. Có bộ giải mã BPF có sẵn trong v4l-utils.