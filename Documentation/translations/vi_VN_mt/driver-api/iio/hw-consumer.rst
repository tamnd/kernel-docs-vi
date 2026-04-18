.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/iio/hw-consumer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
người tiêu dùng CTNH
====================
Một thiết bị IIO có thể được kết nối trực tiếp với một thiết bị khác trong phần cứng. Trong này
trường hợp bộ đệm giữa nhà cung cấp IIO và người tiêu dùng IIO được xử lý bằng phần cứng.
Người tiêu dùng I/O CTNH công nghiệp cung cấp cách liên kết các thiết bị IIO này mà không cần
bộ đệm phần mềm cho dữ liệu. Việc thực hiện có thể được tìm thấy dưới
ZZ0000ZZ


* struct iio_hw_consumer — Cấu trúc người tiêu dùng phần cứng
* ZZ0000ZZ — Phân bổ người tiêu dùng phần cứng IIO
* ZZ0001ZZ — Người tiêu dùng phần cứng IIO miễn phí
* ZZ0002ZZ - Kích hoạt người tiêu dùng phần cứng IIO
* ZZ0003ZZ - Vô hiệu hóa người tiêu dùng phần cứng IIO


Thiết lập người tiêu dùng CTNH
=================

Là thiết bị IIO tiêu chuẩn, việc triển khai dựa trên nhà cung cấp/người tiêu dùng IIO.
Thiết lập tiêu dùng IIO HW điển hình trông như thế này::

cấu trúc tĩnh iio_hw_consumer *hwc;

cấu trúc const tĩnh iio_info adc_info = {
		.read_raw = adc_read_raw,
	};

int tĩnh adc_read_raw(struct iio_dev *indio_dev,
				cấu trúc iio_chan_spec const *chan, int *val,
				int *val2, mặt nạ dài)
	{
		ret = iio_hw_consumer_enable(hwc);

/*Lấy dữ liệu*/

ret = iio_hw_consumer_disable(hwc);
	}

int tĩnh adc_probe(struct platform_device *pdev)
	{
		hwc = devm_iio_hw_consumer_alloc(&iio->dev);
	}

Thêm chi tiết
============
.. kernel-doc:: drivers/iio/buffer/industrialio-hw-consumer.c
   :export:

