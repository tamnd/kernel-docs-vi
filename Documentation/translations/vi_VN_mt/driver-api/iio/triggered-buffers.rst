.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/iio/triggered-buffers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Bộ đệm được kích hoạt
=====================

Bây giờ chúng ta đã biết bộ đệm và trình kích hoạt là gì, hãy xem chúng hoạt động cùng nhau như thế nào.

Thiết lập bộ đệm kích hoạt IIO
==============================

* ZZ0000ZZ — Thiết lập bộ đệm được kích hoạt và pollfunc
* ZZ0001ZZ — Tài nguyên miễn phí được phân bổ bởi
  ZZ0002ZZ
* struct iio_buffer_setup_ops — các lệnh gọi lại liên quan đến thiết lập bộ đệm

Thiết lập bộ đệm được kích hoạt điển hình trông như thế này::

const struct iio_buffer_setup_ops cảm biến_buffer_setup_ops = {
      .preenable = cảm biến_buffer_preenable,
      .postenable = cảm biến_buffer_postenable,
      .postdisable = cảm biến_buffer_postdisable,
      .predisable = cảm biến_buffer_predisable,
    };

irqreturn_t cảm biến_iio_pollfunc(int irq, void *p)
    {
        pf->dấu thời gian = iio_get_time_ns((struct indio_dev *)p);
        trả lại IRQ_WAKE_THREAD;
    }

irqreturn_t cảm biến_trigger_handler(int irq, void *p)
    {
        u16 buf[8];
        int tôi = 0;

/*đọc dữ liệu cho từng kênh đang hoạt động */
        for_each_set_bit(bit, active_scan_mask, chiều dài mặt nạ)
            buf[i++] = cảm biến_get_data(bit)

iio_push_to_buffers_with_timestamp(indio_dev, buf, dấu thời gian);

iio_trigger_notify_done(kích hoạt);
        trả lại IRQ_HANDLED;
    }

/* thiết lập bộ đệm được kích hoạt, thường ở chức năng thăm dò */
    iio_triggered_buffer_setup(indio_dev, cảm biến_iio_polfunc,
                               cảm biến_trigger_handler,
                               cảm biến_buffer_setup_ops);

Những điều quan trọng cần chú ý ở đây là:

* ZZ0000ZZ, chức năng thiết lập bộ đệm sẽ được gọi tại
  các điểm được xác định trước trong trình tự cấu hình bộ đệm (ví dụ: trước khi bật,
  sau khi vô hiệu hóa). Nếu không được chỉ định, lõi IIO sẽ sử dụng giá trị mặc định
  iio_triggered_buffer_setup_ops.
* ZZ0002ZZ, chức năng sẽ được sử dụng làm nửa trên của cuộc thăm dò ý kiến
  chức năng. Nó nên xử lý càng ít càng tốt vì nó chạy trong
  làm gián đoạn bối cảnh. Hoạt động phổ biến nhất là ghi lại dòng điện
  dấu thời gian và vì lý do này người ta có thể sử dụng lõi IIO được xác định
  Chức năng ZZ0001ZZ.
* ZZ0003ZZ, chức năng sẽ được sử dụng ở nửa dưới của
  chức năng thăm dò ý kiến. Điều này chạy trong ngữ cảnh của một luồng nhân và tất cả các
  quá trình xử lý diễn ra ở đây. Nó thường đọc dữ liệu từ thiết bị và
  lưu nó vào bộ đệm bên trong cùng với dấu thời gian được ghi trong
  nửa trên.

Thêm chi tiết
=============
.. kernel-doc:: drivers/iio/buffer/industrialio-triggered-buffer.c
