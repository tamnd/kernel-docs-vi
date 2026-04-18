.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/iio/triggers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
Trình kích hoạt
========

* struct iio_trigger — thiết bị kích hoạt I/O công nghiệp
* ZZ0000ZZ — iio_trigger_alloc được quản lý tài nguyên
* ZZ0001ZZ — iio_trigger_register được quản lý tài nguyên
  iio_trigger_unregister
* ZZ0002ZZ — Kiểm tra xem có kích hoạt và IIO không
  thiết bị thuộc cùng một thiết bị

Trong nhiều trường hợp, sẽ rất hữu ích nếu người lái xe có thể thu thập dữ liệu dựa trên
trên một số sự kiện bên ngoài (kích hoạt) trái ngược với việc thăm dò dữ liệu định kỳ.
Trình kích hoạt IIO có thể được cung cấp bởi trình điều khiển thiết bị cũng có thiết bị IIO
dựa trên các sự kiện do phần cứng tạo ra (ví dụ: dữ liệu đã sẵn sàng hoặc vượt quá ngưỡng) hoặc
được cung cấp bởi một trình điều khiển riêng biệt từ nguồn ngắt độc lập (ví dụ GPIO
đường dây được kết nối với một số hệ thống bên ngoài, ngắt bộ đếm thời gian hoặc ghi vào không gian người dùng
một tệp cụ thể trong sysfs). Trình kích hoạt có thể bắt đầu thu thập dữ liệu cho một số
cảm biến và nó cũng có thể hoàn toàn không liên quan đến chính cảm biến.

Giao diện sysfs kích hoạt IIO
===========================

Có hai vị trí trong sysfs liên quan đến trình kích hoạt:

* ZZ0000ZZ, tập tin này được tạo một lần
  Trình kích hoạt IIO được đăng ký với lõi IIO và tương ứng với trình kích hoạt
  với chỉ số Y
  Bởi vì trình kích hoạt có thể rất khác nhau tùy theo loại nên có rất ít
  thuộc tính tiêu chuẩn mà chúng tôi có thể mô tả ở đây:

* ZZ0000ZZ, tên trình kích hoạt mà sau này có thể được sử dụng để liên kết với
    thiết bị.
  * ZZ0001ZZ, một số trình kích hoạt dựa trên bộ đếm thời gian sử dụng thuộc tính này để
    chỉ định tần suất cho các cuộc gọi kích hoạt.

* ZZ0000ZZ, thư mục này là
  được tạo khi thiết bị hỗ trợ bộ đệm được kích hoạt. Chúng ta có thể liên kết một
  kích hoạt bằng thiết bị của chúng tôi bằng cách viết tên trình kích hoạt vào
  Tệp ZZ0001ZZ.

Thiết lập kích hoạt IIO
=================

Hãy xem một ví dụ đơn giản về cách thiết lập trình kích hoạt để trình điều khiển sử dụng::

cấu trúc iio_trigger_ops trigger_ops = {
          .set_trigger_state = sample_trigger_state,
          .validate_device = sample_validate_device,
      }

struct iio_trigger *trig;

/* trước tiên, phân bổ bộ nhớ cho trình kích hoạt của chúng tôi */
      trig = iio_trigger_alloc(dev, "trig-%s-%d", name, idx);

/*thiết lập trường hoạt động kích hoạt */
      trig->ops = &trigger_ops;

/* bây giờ hãy đăng ký trình kích hoạt với lõi IIO */
      iio_trigger_register(trig);

Hoạt động kích hoạt IIO
===============

* struct iio_trigger_ops — cấu trúc hoạt động của iio_trigger.

Lưu ý rằng trình kích hoạt có một tập hợp các thao tác được đính kèm:

* ZZ0000ZZ, bật/tắt trigger theo yêu cầu.
* ZZ0001ZZ, chức năng xác thực thiết bị khi có dòng điện
  kích hoạt được thay đổi.

Thêm chi tiết
============
.. kernel-doc:: include/linux/iio/trigger.h
.. kernel-doc:: drivers/iio/industrialio-trigger.c
   :export:
