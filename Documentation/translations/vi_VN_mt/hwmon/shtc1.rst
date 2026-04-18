.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/shtc1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân shtc1
===================

Chip được hỗ trợ:

* Sensirion SHTC1

Tiền tố: 'shtc1'

Địa chỉ được quét: không có

Bảng dữ liệu: ZZ0000ZZ



* Sensirion SHTW1

Tiền tố: 'shtw1'

Địa chỉ được quét: không có

Bảng dữ liệu: ZZ0000ZZ



* Sensirion SHTC3

Tiền tố: 'shtc3'

Địa chỉ được quét: không có

Bảng dữ liệu: ZZ0000ZZ



Tác giả:

Johannes Winkelmann <johannes.winkelmann@sensirion.com>

Sự miêu tả
-----------

Trình điều khiển này triển khai hỗ trợ cho Sensirion SHTC1, SHTW1 và SHTC3
chip, cảm biến độ ẩm và nhiệt độ. Nhiệt độ được đo bằng độ
độ C, độ ẩm tương đối được biểu thị bằng phần trăm.

Thiết bị giao tiếp với giao thức I2C. Tất cả các cảm biến được đặt thành I2C
địa chỉ 0x70. Xem Documentation/i2c/instantiating-devices.rst để biết các phương pháp
khởi tạo thiết bị.

Có hai tùy chọn có thể định cấu hình bằng shtc1_platform_data:

1. chặn (kéo dòng đồng hồ I2C xuống trong khi thực hiện phép đo) hoặc
   chế độ không chặn. Chế độ chặn sẽ đảm bảo kết quả nhanh nhất nhưng
   xe buýt I2C sẽ bận trong thời gian đó. Theo mặc định, chế độ không chặn
   được sử dụng. Đảm bảo tính năng kéo giãn đồng hồ hoạt động bình thường trên thiết bị của bạn nếu bạn
   muốn sử dụng chế độ chặn.
2. độ chính xác cao hay thấp. Độ chính xác cao được sử dụng theo mặc định và việc sử dụng nó là
   khuyến khích mạnh mẽ.

giao diện sysfs
---------------

temp1_input
	- đầu vào nhiệt độ
độ ẩm1_input
	- đầu vào độ ẩm
