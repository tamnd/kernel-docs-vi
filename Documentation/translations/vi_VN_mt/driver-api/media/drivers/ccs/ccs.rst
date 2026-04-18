.. SPDX-License-Identifier: GPL-2.0-only OR BSD-3-Clause

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/ccs/ccs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. _media-ccs-driver:

Trình điều khiển cảm biến máy ảnh MIPI CCS
==========================================

Trình điều khiển cảm biến máy ảnh MIPI CCS là trình điều khiển chung dành cho tuân thủ ZZ0000ZZ
cảm biến máy ảnh.

Xem thêm ZZ0000ZZ.

Dữ liệu tĩnh CCS
----------------

Trình điều khiển MIPI CCS hỗ trợ dữ liệu tĩnh CCS cho tất cả các thiết bị tuân thủ,
bao gồm không chỉ những sản phẩm tương thích với CCS 1.1 mà còn cả CCS 1.0 và SMIA(++).
Đối với CCS, tên tệp được tạo thành

ccs/ccs-sensor-vvvv-mmmm-rrrr.fw (cảm biến) và
	ccs/ccs-module-vvvv-mmmm-rrrr.fw (mô-đun).

Đối với các thiết bị tương thích SMIA++, tên tệp tương ứng là

ccs/smiapp-sensor-vv-mmmm-rr.fw (cảm biến) và
	ccs/smiapp-module-vv-mmmm-rrrr.fw (mô-đun).

Đối với các thiết bị tuân thủ SMIA (không phải ++), tên tệp dữ liệu tĩnh là

ccs/smia-sensor-vv-mmmm-rr.fw (cảm biến).

vvvv hoặc vv lần lượt biểu thị ID nhà sản xuất MIPI và SMIA, ID model mmmm
và số sửa đổi rrrr hoặc rr.

Dụng cụ CCS
~~~~~~~~~~~

ZZ0000ZZ là một bộ
công cụ để làm việc với các tệp dữ liệu tĩnh CCS. Công cụ CCS bao gồm một
định nghĩa về định dạng YAML dữ liệu tĩnh CCS mà con người có thể đọc được và bao gồm một
chương trình chuyển nó sang dạng nhị phân.

Đăng ký trình tạo định nghĩa
-----------------------------

Tệp ccs-regs.asc chứa các định nghĩa thanh ghi MIPI CCS được sử dụng
để tạo ra các tệp mã nguồn C cho các định nghĩa có thể được sử dụng tốt hơn bởi
chương trình viết bằng ngôn ngữ C. Vì có nhiều sự phụ thuộc giữa
các tệp đã tạo, vui lòng không sửa đổi chúng theo cách thủ công vì nó dễ bị lỗi và
vô ích mà thay vào đó hãy thay đổi kịch bản tạo ra chúng.

Cách sử dụng
~~~~~~~~~~~~

Thông thường tập lệnh được gọi theo cách này để cập nhật trình điều khiển CCS
định nghĩa:

.. code-block:: none

	$ Documentation/driver-api/media/drivers/ccs/mk-ccs-regs -k \
		-e drivers/media/i2c/ccs/ccs-regs.h \
		-L drivers/media/i2c/ccs/ccs-limits.h \
		-l drivers/media/i2c/ccs/ccs-limits.c \
		-c Documentation/driver-api/media/drivers/ccs/ccs-regs.asc

Máy tính CCS PLL
==================

Máy tính CCS PLL được sử dụng để tính toán cấu hình PLL, dựa trên cảm biến
khả năng cũng như cấu hình bo mạch và cấu hình do người dùng chỉ định. Như
không gian cấu hình bao gồm tất cả các cấu hình này rất rộng lớn,
Máy tính PLL không hoàn toàn tầm thường. Tuy nhiên, nó tương đối đơn giản để sử dụng cho một
người lái xe.

Mô hình PLL do máy tính PLL triển khai tương ứng với MIPI CCS 1.1.

.. kernel-doc:: drivers/media/i2c/ccs-pll.h

ZZ0000ZZ ZZ0001ZZ 2020 Tập đoàn Intel