.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/sht4x.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân sht4x
===================

Chip được hỗ trợ:

* Sensirion SHT4X

Tiền tố: 'sht4x'

Địa chỉ được quét: Không có

Bảng dữ liệu:

Tiếng Anh: ZZ0000ZZ

Tác giả: Navin Sankar Velliangiri <navin@linumiz.com>


Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho chip Sensirion SHT4x, độ ẩm
và cảm biến nhiệt độ. Nhiệt độ được đo bằng độ C, tương đối
độ ẩm được biểu thị bằng phần trăm. Trong giao diện sysfs, tất cả các giá trị đều được
được chia tỷ lệ theo 1000, tức là giá trị của 31,5 độ C là 31500.

Ghi chú sử dụng
-----------

Thiết bị giao tiếp với giao thức I2C. Cảm biến có thể có I2C
địa chỉ 0x44. Xem Documentation/i2c/instantiating-devices.rst để biết các phương thức
để khởi tạo thiết bị.

Mục nhập hệ thống
-------------

================================================================
temp1_input Nhiệt độ đo được tính bằng mili độ C
độ ẩm1_input Độ ẩm đo được bằng %H
update_interval Khoảng thời gian tối thiểu để thăm dò cảm biến,
                tính bằng mili giây. Có thể viết được. Ít nhất phải có
                2000.
heater_power Công suất bộ sưởi được yêu cầu, tính bằng miliwatt.
		Các giá trị khả dụng: 20, 110, 200 (mặc định: 200).
heater_time Thời gian hoạt động được yêu cầu của máy sưởi,
		tính bằng mili giây.
		Các giá trị khả dụng: 100, 1000 (mặc định 1000).
heater_enable Bật máy sưởi với nguồn điện đã chọn
		và trong thời gian đã chọn để loại bỏ
		nước ngưng tụ từ bề mặt cảm biến. các
		lò sưởi không thể được tắt bằng tay một lần
		đã bật (nó sẽ tự động tắt
		sau khi hoàn thành hoạt động của nó).

- 0: đã tắt (giá trị chỉ đọc)
			- 1: bật
================================================================