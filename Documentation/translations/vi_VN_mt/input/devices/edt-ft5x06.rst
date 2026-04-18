.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/edt-ft5x06.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Thiết bị Polytouch dựa trên EDT ft5x06
----------------------------------

Trình điều khiển edt-ft5x06 rất hữu ích cho dòng điện dung EDT "Polytouch"
màn hình cảm ứng. Lưu ý rằng ZZ0000ZZ phù hợp với các thiết bị khác dựa trên
các thiết bị focustec ft5x06 vì chúng chứa chương trình cơ sở dành riêng cho nhà cung cấp. trong
Đặc biệt trình điều khiển này không phù hợp với máy tính bảng Nook.

Nó đã được thử nghiệm với các thiết bị sau:
  * EP0350M06
  * EP0430M06
  * EP0570M06
  * EP0700M06

Trình điều khiển cho phép cấu hình màn hình cảm ứng thông qua một bộ tệp sysfs:

/sys/class/input/eventX/device/device/ngưỡng:
    cho phép đặt ngưỡng "nhấp chuột" trong phạm vi từ 0 đến 80.

/sys/class/input/eventX/device/device/gain:
    cho phép cài đặt độ nhạy trong phạm vi từ 0 đến 31. Lưu ý rằng
    giá trị thấp hơn cho thấy độ nhạy cao hơn.

/sys/class/input/eventX/device/device/offset:
    cho phép thiết lập bù cạnh trong phạm vi từ 0 đến 31.

/sys/class/input/eventX/device/device/report_rate:
    cho phép thiết lập tỷ lệ báo cáo trong khoảng từ 3 đến 14.


Với mục đích gỡ lỗi, trình điều khiển cung cấp một vài tệp trong phần gỡ lỗi.
hệ thống tập tin (nếu có trong kernel). Chúng nằm ở:

/sys/kernel/debug/i2c/<i2c-bus>/<i2c-device>/

Nếu bạn không biết số xe buýt và số thiết bị, bạn có thể tra cứu chúng bằng cách này
lệnh:

$ ls -l /sys/bus/i2c/drivers/edt_ft5x06

Việc hủy đăng ký của liên kết tượng trưng sẽ chứa thông tin cần thiết. Bạn sẽ
cần hai yếu tố cuối cùng của đường dẫn của nó:

0-0038 -> ../../../../devices/platform/soc/fcfee800.i2c/i2c-0/0-0038

Vì vậy, trong trường hợp này, vị trí của các tệp gỡ lỗi là:

/sys/kernel/debug/i2c/i2c-0/0-0038/

Ở đó, bạn sẽ tìm thấy các tập tin sau:

số_x, số_y:
    (chỉ đọc) chứa số trường cảm biến trong X- và
    hướng Y.

chế độ:
    cho phép chuyển đổi cảm biến giữa "chế độ xuất xưởng" và "chế độ vận hành
    mode" bằng cách viết "1" hoặc "0" vào đó. Ở chế độ xuất xưởng (1) nó là
    có thể lấy dữ liệu thô từ cảm biến. Lưu ý rằng trong nhà máy
    chế độ các sự kiện thông thường không được phân phối và các tùy chọn được mô tả
    ở trên không có sẵn.

dữ liệu thô:
    chứa các giá trị num_x * num_y big endian 16 bit mô tả thô
    giá trị cho từng trường cảm biến. Lưu ý rằng mỗi lệnh gọi read() trên này
    tập tin kích hoạt một bản đọc mới. Nên cung cấp bộ đệm
    đủ lớn để chứa num_x * num_y * 2 byte.

Lưu ý rằng việc đọc raw_data sẽ gây ra lỗi I/O khi thiết bị không ở trạng thái xuất xưởng
chế độ. Điều tương tự cũng xảy ra khi đọc/ghi vào các tập tin tham số khi
thiết bị không ở chế độ hoạt động bình thường.
