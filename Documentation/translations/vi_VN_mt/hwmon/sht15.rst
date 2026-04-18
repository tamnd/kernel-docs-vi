.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sht15.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sht15
===============================

tác giả:

* Wouter Horre
  * Jonathan Cameron
  * Vivien Didelot <vivien.didelot@savoirfairelinux.com>
  * Jerome Oufella <jerome.oufella@savoirfairelinux.com>

Chip được hỗ trợ:

* Sensirion SHT10

Tiền tố: 'sht10'

* Sensirion SHT11

Tiền tố: 'sht11'

* Sensirion SHT15

Tiền tố: 'sht15'

* Sensirion SHT71

Tiền tố: 'sht71'

* Sensirion SHT75

Tiền tố: 'sht75'

Bảng dữ liệu: Có sẵn công khai tại trang web Sensirion

ZZ0000ZZ

Sự miêu tả
-----------

SHT10, SHT11, SHT15, SHT71 và SHT75 là độ ẩm và nhiệt độ
cảm biến.

Các thiết bị giao tiếp bằng hai đường GPIO.

Độ phân giải được hỗ trợ cho phép đo là 14 bit cho nhiệt độ và 12
bit cho độ ẩm hoặc 12 bit cho nhiệt độ và 8 bit cho độ ẩm.

Các hệ số hiệu chỉnh độ ẩm được lập trình vào bộ nhớ OTP trên
chip. Các hệ số này được sử dụng để hiệu chỉnh nội bộ các tín hiệu từ
cảm biến. Việc vô hiệu hóa việc tải lại các hệ số đó cho phép tiết kiệm 10ms cho mỗi hệ số
đo lường và giảm mức tiêu thụ điện năng, đồng thời mất đi độ chính xác.

Một số tùy chọn có thể được đặt thông qua thuộc tính sysfs.

Ghi chú:
  * Tên nguồn cung cấp bộ điều chỉnh được đặt thành "vcc".
  * Nếu xác thực CRC không thành công, lệnh đặt lại mềm sẽ được gửi để đặt lại
    đăng ký trạng thái về giá trị mặc định phần cứng của nó, nhưng trình điều khiển sẽ cố gắng
    khôi phục cấu hình thiết bị trước đó.

Dữ liệu nền tảng
----------------

* tổng kiểm tra:
  đặt thành true để bật xác thực CRC cho các bài đọc (mặc định là sai).
* no_otp_reload:
  cờ để cho biết không tải lại từ OTP (mặc định là sai).
* độ phân giải thấp:
  cờ để cho biết độ phân giải nhiệt độ/độ ẩm sẽ sử dụng (mặc định là sai).

Giao diện hệ thống
------------------

==================================================================================
đầu vào nhiệt độ temp1_input
độ ẩm1_input đầu vào độ ẩm
heater_enable ghi 1 vào thuộc tính này để kích hoạt bộ sưởi trên chip,
		   0 để vô hiệu hóa nó. Cẩn thận không bật máy sưởi
		   quá lâu.
temp1_fault nếu 1, điều này có nghĩa là điện áp thấp (dưới 2,47V) và
		   phép đo có thể không hợp lệ.
độ ẩm1_fault giống như temp1_fault.
==================================================================================
