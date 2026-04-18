.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sht3x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân sht3x
===============================

Chip được hỗ trợ:

* Sensirion SHT3x-DIS

Tiền tố: 'sht3x'

Địa chỉ được quét: không có

Bảng dữ liệu:
        -ZZ0000ZZ
        -ZZ0001ZZ

* Sensirion STS3x-DIS

Tiền tố: 'sts3x'

Địa chỉ được quét: không có

Bảng dữ liệu:
        -ZZ0000ZZ
        -ZZ0001ZZ

* Sensirion SHT85

Tiền tố: 'sht85'

Địa chỉ được quét: không có

Bảng dữ liệu: ZZ0000ZZ

Tác giả:

- David Frey <david.frey@sensirion.com>
  - Pascal Sachs <pascal.sachs@sensirion.com>

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho Sensirion SHT3x-DIS, STS3x-DIS và SHT85
loạt cảm biến độ ẩm và nhiệt độ. Nhiệt độ được đo bằng độ
độ C, độ ẩm tương đối được biểu thị bằng phần trăm. Trong giao diện sysfs,
tất cả các giá trị được chia tỷ lệ theo 1000, tức là giá trị cho 31,5 độ C là 31500.

Thiết bị giao tiếp với giao thức I2C. Cảm biến SHT3x có thể có I2C
địa chỉ 0x44 hoặc 0x45 (0x4a hoặc 0x4b cho sts3x), tùy thuộc vào hệ thống dây điện. SHT85
địa chỉ là 0x44 và được cố định. Xem Documentation/i2c/instantiating-devices.rst để biết
các phương pháp khởi tạo thiết bị.

Ngay cả khi cảm biến sht3x hỗ trợ kéo dài đồng hồ (chế độ chặn) và không kéo dài
(chế độ không chặn) ở chế độ chụp một lần, trình điều khiển này chỉ hỗ trợ chế độ sau.

Cảm biến sht3x hỗ trợ chế độ chụp một lần cũng như 5 lần đo định kỳ
các chế độ, có thể được điều khiển bằng giao diện sysfs update_interval.
Update_interval được phép tính bằng mili giây như sau:

===== ======= ======================
       0 chế độ chụp một lần
    Đo định kỳ 2000 0,5 Hz
    Đo định kỳ 1000 1 Hz
     Đo định kỳ 500 2 Hz
     Đo định kỳ 250 4 Hz
     Đo định kỳ 100 10 Hz
    ===== ======= ======================

Ở chế độ đo định kỳ, cảm biến sẽ tự động kích hoạt phép đo
với khoảng thời gian cập nhật được cấu hình trên chip. Khi nhiệt độ hoặc độ ẩm
đọc vượt quá giới hạn được định cấu hình, thuộc tính cảnh báo được đặt thành 1 và
chân cảnh báo trên cảm biến được đặt ở mức cao.
Khi số đọc nhiệt độ và độ ẩm di chuyển trở lại giữa độ trễ
giá trị, bit cảnh báo được đặt thành 0 và chân cảnh báo trên cảm biến được đặt thành
thấp.

Số sê-ri tiếp xúc với các bản gỡ lỗi cho phép nhận dạng duy nhất của
cảm biến. Đối với sts32, sts33 và sht33, nhà sản xuất cung cấp hiệu chuẩn
chứng chỉ thông qua API.

giao diện sysfs
---------------

=================== ==================================================================
temp1_input: đầu vào nhiệt độ
độ ẩm1_input: đầu vào độ ẩm
temp1_max: giá trị nhiệt độ tối đa
temp1_max_hyst: giá trị trễ nhiệt độ cho giới hạn tối đa
độ ẩm1_max: giá trị độ ẩm tối đa
độ ẩm1_max_hyst: giá trị độ trễ độ ẩm cho giới hạn tối đa
temp1_min: giá trị nhiệt độ tối thiểu
temp1_min_hyst: giá trị trễ nhiệt độ cho giới hạn tối thiểu
độ ẩm1_min: giá trị độ ẩm tối thiểu
độ ẩm1_min_hyst: giá trị độ trễ độ ẩm cho giới hạn tối thiểu
temp1_alarm: cờ báo động được đặt thành 1 nếu nhiệt độ nằm ngoài giới hạn cho phép
		    giới hạn được cấu hình. Báo động chỉ hoạt động ở chế độ đo định kỳ
độ ẩm1_alarm: cờ báo động được đặt thành 1 nếu độ ẩm nằm ngoài phạm vi
		    giới hạn được cấu hình. Báo động chỉ hoạt động ở chế độ đo định kỳ
heater_enable: kích hoạt bộ sưởi, bộ phận làm nóng sẽ loại bỏ độ ẩm dư thừa khỏi
		    cảm biến:

- 0: đã tắt
			- 1: bật
update_interval: khoảng thời gian cập nhật, 0 cho một lần chụp, khoảng thời gian tính bằng mili giây
		    để đo định kỳ. Nếu khoảng thời gian không được hỗ trợ
		    bởi cảm biến, khoảng thời gian nhanh hơn tiếp theo sẽ được chọn
độ lặp lại: khả năng lặp lại viết hoặc đọc, nghĩa là độ lặp lại cao hơn
                    thời gian đo dài hơn, độ ồn thấp hơn và
                    tiêu thụ năng lượng lớn hơn:

- 0: độ lặp lại thấp
                        - 1: độ lặp lại trung bình
                        - 2: độ lặp lại cao
=================== ==================================================================

debugfs-Giao diện
-----------------

=================== ==================================================================
serial_number: số sê-ri duy nhất của cảm biến ở dạng thập phân
=================== ==================================================================
