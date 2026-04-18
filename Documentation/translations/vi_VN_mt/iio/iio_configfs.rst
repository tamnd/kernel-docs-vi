.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/iio/iio_configfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Hỗ trợ cấu hình IIO công nghiệp
==================================

1. Tổng quan
===========

Configfs là trình quản lý các đối tượng kernel dựa trên hệ thống tập tin. IIO sử dụng một số
các đối tượng có thể được cấu hình dễ dàng bằng configfs (ví dụ: thiết bị,
kích hoạt).

Xem Tài liệu/filesystems/configfs.rst để biết thêm thông tin
về cách configfs hoạt động.

2. Cách sử dụng
========

Để sử dụng hỗ trợ configfs trong IIO, chúng ta cần chọn nó khi biên dịch
thời gian thông qua tùy chọn cấu hình CONFIG_IIO_CONFIGFS.

Sau đó, gắn hệ thống tập tin configfs (thường trong thư mục /config)::

$ mkdir/cấu hình
  $ mount -t configfs none /config

Tại thời điểm này, tất cả các nhóm IIO mặc định sẽ được tạo và có thể truy cập được
dưới /config/iio. Các chương tiếp theo sẽ mô tả cấu hình IIO có sẵn
đồ vật.

3. Trình kích hoạt phần mềm
====================

Một trong các nhóm cấu hình mặc định của IIO là nhóm "kích hoạt". Đó là
có thể truy cập tự động khi cấu hình được gắn kết và có thể được tìm thấy
trong /config/iio/triggers.

Việc triển khai phần mềm kích hoạt IIO cung cấp hỗ trợ để tạo nhiều
các loại kích hoạt. Một loại trình kích hoạt mới thường được triển khai dưới dạng riêng biệt
mô-đun hạt nhân theo giao diện trong include/linux/iio/sw_trigger.h::

/*
   * trình điều khiển/iio/kích hoạt/iio-trig-sample.c
   * mô-đun hạt nhân mẫu triển khai loại trình kích hoạt mới
   */
  #include <linux/iio/sw_trigger.h>


cấu trúc tĩnh iio_sw_trigger *iio_trig_sample_probe(const char *name)
  {
	/*
	 * Điều này phân bổ và đăng ký trình kích hoạt IIO cộng với các trình kích hoạt khác
	 * khởi tạo cụ thể loại kích hoạt.
	 */
  }

int tĩnh iio_trig_sample_remove(struct iio_sw_trigger *swt)
  {
	/*
	 * Điều này hoàn tác các hành động trong iio_trig_sample_probe
	 */
  }

cấu trúc const tĩnh iio_sw_trigger_ops iio_trig_sample_ops = {
	.probe = iio_trig_sample_probe,
	.remove = iio_trig_sample_remove,
  };

cấu trúc tĩnh iio_sw_trigger_type iio_trig_sample = {
	.name = "mẫu lượng giác",
	.chủ sở hữu = THIS_MODULE,
	.ops = &iio_trig_sample_ops,
  };

module_iio_sw_trigger_driver(iio_trig_sample);

Mỗi loại trình kích hoạt có thư mục riêng trong /config/iio/triggers. Đang tải
Mô-đun iio-trig-sample sẽ tạo thư mục loại trình kích hoạt 'trig-sample'
/config/iio/triggers/trig-sample.

Chúng tôi hỗ trợ các nguồn ngắt sau (loại kích hoạt):

* hrtimer, sử dụng bộ định thời có độ phân giải cao làm nguồn ngắt

3.1 Hrtimer kích hoạt tạo và hủy
---------------------------------------------

Đang tải mô-đun iio-trig-hrtimer sẽ đăng ký các loại kích hoạt giờ cho phép
người dùng tạo trình kích hoạt giờ trong /config/iio/triggers/hrtimer.

ví dụ::

$ mkdir /config/iio/triggers/hrtimer/instance1
  $ rmdir /config/iio/triggers/hrtimer/instance1

Mỗi trình kích hoạt có thể có một hoặc nhiều thuộc tính cụ thể cho loại trình kích hoạt.

3.2 Thuộc tính loại trình kích hoạt "hrtimer"
--------------------------------------

Loại trình kích hoạt "hrtimer" không có bất kỳ thuộc tính có thể định cấu hình nào từ thư mục /config.
Nó giới thiệu thuộc tính lấy mẫu_tần suất cho thư mục kích hoạt.
Thuộc tính đó đặt tần số bỏ phiếu tính bằng Hz, với độ chính xác mHz.
