.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-parport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-parport
=========================

Tác giả: Jean Delvare <jdelvare@suse.de>

Đây là trình điều khiển hợp nhất cho một số bộ điều hợp cổng song song i2c,
chẳng hạn như những sản phẩm của Philips, Velleman hoặc ELV. Người lái xe này là
có nghĩa là thay thế cho các trình điều khiển cá nhân, cũ hơn:

* i2c-philips-par
 * i2c-elv
 * i2c-velleman
 * video/i2c-parport
   (NOT giống như cái này, dành riêng cho bộ điều hợp teletext pha cà phê tại nhà)

Nó hiện hỗ trợ các thiết bị sau:

* (loại=0) Bộ chuyển đổi Philips
 * (loại=1) bộ chuyển đổi teletext pha chế tại nhà
 * (loại=2) Bộ chuyển đổi Velleman K8000
 * (loại=3) Bộ chuyển đổi ELV
 * (loại=4) Bảng đánh giá Thiết bị Analog ADM1032
 * (loại=5) Bảng đánh giá thiết bị analog: ADM1025, ADM1030, ADM1031
 * (loại=6) Bộ chuyển đổi Barco LPT->DVI (K5800236)
 * (loại=7) Bộ chuyển đổi cổng song song One For All JP1
 * (loại=8) VCT-jig

Các thiết bị này sử dụng các cấu hình sơ đồ chân khác nhau, vì vậy bạn phải cho biết
trình điều khiển mà bạn có, sử dụng tham số loại mô-đun. không có
cách để tự động phát hiện các thiết bị. Hỗ trợ các cấu hình sơ đồ chân khác nhau
có thể dễ dàng thêm vào khi cần thiết.

Các hạt nhân trước đó được mặc định là loại = 0 (Philips).  Nhưng bây giờ, nếu loại
tham số bị thiếu, trình điều khiển sẽ không khởi tạo được.

Hỗ trợ cảnh báo SMBus có sẵn trên các bộ điều hợp có dòng này đúng cách
được kết nối với chân ngắt của cổng song song.


Xây dựng bộ chuyển đổi của riêng bạn
-------------------------

Nếu bạn muốn xây dựng bộ điều hợp cổng song song i2c của riêng mình, đây là
một lược đồ điện tử mẫu (tín dụng thuộc về Sylvain Munaut)::

Máy tính thiết bị
  Bên ___________________Vdd (+) Bên
                 ZZ0000ZZ |
                --- --- ---
                ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
                ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
                ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
                --- --- ---
                 ZZ0010ZZ |
                 ZZ0011ZZ /ZZ0012ZZ
  SCL ----------x--------o |----------x---------- chân 2
                      ZZ0013ZZ ZZ0014ZZ
                      ZZ0015ZZ |
                      ZZ0016ZZ\ ZZ0017ZZ
  SDA ----------x---x---| o---x-------------------------- chân 13
                 ZZ0018ZZ/ |
                 ZZ0019ZZ
                 ZZ0020ZZ |
                 ---------o |-------x-------------- chân 3
                           \ZZ0021ZZ |
                                        ZZ0022ZZ
                                       --- ---
                                       ZZ0023ZZ ZZ0024ZZ
                                       ZZ0025ZZ ZZ0026ZZ
                                       ZZ0027ZZ ZZ0028ZZ
                                       --- ---
                                        ZZ0029ZZ
                                       ### ###
                                       ZZ0062ZZ GND

Nhận xét:
 - Đây là sơ đồ chân và thiết bị điện tử chính xác được sử dụng trên Thiết bị Analog
   các hội đồng đánh giá.
 - Tất cả các loại biến tần::

/|
                 -o |-
                   \|

phải là 74HC05, chúng phải là đầu ra của bộ thu mở.
 - Tất cả các điện trở đều là 10k.
 - Chân 18-25 của cổng song song kết nối với GND.
 - Các chân 4-9 (D2-D7) có thể được sử dụng vì VDD là trình điều khiển đẩy chúng lên cao.
   Bảng đánh giá ADM1032 sử dụng D4-D7. Hãy lưu ý rằng số lượng
   dòng điện bạn có thể rút ra từ cổng song song bị hạn chế. Cũng lưu ý rằng
   tất cả các đường kết nối MUST BE được điều khiển ở cùng một trạng thái, nếu không bạn sẽ bị chập mạch
   mạch các bộ đệm đầu ra! Vì vậy việc cắm adapter I2C sau khi tải
   mô-đun i2c-parport có thể an toàn tốt vì trạng thái dòng dữ liệu
   trước init có thể chưa được biết.
 - Đây là 5V!
 - Rõ ràng là bạn không thể đọc SCL (vì vậy nó không thực sự tuân thủ tiêu chuẩn).
   Việc thêm khá dễ dàng, chỉ cần sao chép phần SDA và sử dụng mã pin đầu vào khác.
   Điều đó sẽ cung cấp (sơ đồ chân tương thích ELV)::


Máy tính thiết bị
      Bên ______________________________Vdd (+) Bên
                     ZZ0000ZZ ZZ0001ZZ
                    --- --- --- ---
                    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
                    ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
                    ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
                    --- --- --- ---
                     ZZ0014ZZ ZZ0015ZZ
                     ZZ0016ZZ ZZ0017ZZ |
      SCL ----------x--------x--| o---x----------- chân 15
                          ZZ0018ZZ ZZ0019ZZ
                          ZZ0020ZZ |
                          ZZ0021ZZ /ZZ0022ZZ
                          ZZ0023ZZ-------------x-------------- chân 2
                          ZZ0024ZZ ZZ0025ZZ
                          ZZ0026ZZ |
                          ZZ0027ZZ |
                          ZZ0028ZZ\ ZZ0029ZZ
      SDA ---------------x---x--| o--------x------chân 10
                              ZZ0030ZZ/ |
                              ZZ0031ZZ
                              ZZ0032ZZ |
                              ---o |----------x-------- chân 3
                                  \ZZ0033ZZ |
                                                 ZZ0034ZZ
                                                --- ---
                                                ZZ0035ZZ ZZ0036ZZ
                                                ZZ0037ZZ ZZ0038ZZ
                                                ZZ0039ZZ ZZ0040ZZ
                                                --- ---
                                                 ZZ0041ZZ
                                                ### ###
                                                ZZ0086ZZ GND


Nếu có thể, bạn nên sử dụng cấu hình sơ đồ chân giống như hiện có
bộ điều hợp làm được, do đó bạn thậm chí sẽ không phải thay đổi mã.


Trình điều khiển tương tự (nhưng khác)
-------------------------------

Trình điều khiển này là NOT giống như trình điều khiển i2c-pport được tìm thấy trong i2c
gói. Trình điều khiển i2c-pport sử dụng các tính năng cổng song song hiện đại để
rằng bạn không cần thêm thiết bị điện tử. Nó có những hạn chế khác
tuy nhiên, và chưa được chuyển sang Linux 2.6.

Trình điều khiển này cũng là NOT giống như trình điều khiển i2c-pcf-epp được tìm thấy trong
gói lm_sensors. Trình điều khiển i2c-pcf-epp không sử dụng cổng song song như
một xe buýt I2C trực tiếp. Thay vào đó, nó sử dụng nó để điều khiển bus I2C bên ngoài
chủ nhân. Trình điều khiển đó cũng chưa được chuyển sang Linux 2.6.


Tài liệu kế thừa cho bộ điều hợp Velleman
-----------------------------------------

Liên kết hữu ích:

- Velleman ZZ0000ZZ
- Velleman K8000 Howto ZZ0001ZZ

Dự án đã dẫn đến các lib mới cho Velleman K8000 và K8005:

LIBK8000 v1.99.1 và LIBK8005 v0.21

Với các lib này, bạn có thể điều khiển card giao diện K8000 và K8005
thẻ động cơ bước với các lệnh đơn giản có trong bản gốc
Phần mềm Velleman, như SetIOchannel, ReadADchannel, SendStepCCWFull và
nhiều hơn nữa, sử dụng /dev/velleman.

-ZZ0000ZZ
  -ZZ0001ZZ
  -ZZ0002ZZ
  -ZZ0003ZZ


Bộ chuyển đổi cổng song song One For All JP1
-------------------------------------

Dự án JP1 xoay quanh một bộ điều khiển từ xa hiển thị
bus I2C cấu hình bên trong EEPROM của họ hoạt động thông qua 6 chân
jumper trong ngăn chứa pin. Thông tin chi tiết có thể được tìm thấy tại:

ZZ0000ZZ

Chi tiết về phần cứng cổng song song đơn giản có thể được tìm thấy tại:

ZZ0000ZZ
