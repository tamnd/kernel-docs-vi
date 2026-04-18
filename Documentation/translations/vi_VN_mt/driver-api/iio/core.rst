.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/iio/core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Yếu tố cốt lõi
=============

Lõi I/O công nghiệp cung cấp cả một khuôn khổ thống nhất để viết trình điều khiển cho
nhiều loại cảm biến nhúng khác nhau và giao diện chuẩn cho không gian người dùng
ứng dụng thao tác với cảm biến. Việc thực hiện có thể được tìm thấy dưới
ZZ0000ZZ

Thiết bị I/O công nghiệp
----------------------

* struct iio_dev - thiết bị I/O công nghiệp
* iio_device_alloc() - phân bổ ZZ0000ZZ từ trình điều khiển
* iio_device_free() - giải phóng ZZ0001ZZ khỏi trình điều khiển
* iio_device_register() - đăng ký thiết bị với hệ thống con IIO
* iio_device_unregister() - hủy đăng ký thiết bị khỏi IIO
  hệ thống con

Một thiết bị IIO thường tương ứng với một cảm biến phần cứng duy nhất và nó
cung cấp tất cả thông tin cần thiết cho người điều khiển thiết bị.
Trước tiên chúng ta hãy xem chức năng được nhúng trong thiết bị IIO
sau đó chúng tôi sẽ trình bày cách trình điều khiển thiết bị sử dụng thiết bị IIO.

Có hai cách để ứng dụng không gian người dùng tương tác với trình điều khiển IIO.

1. ZZ0000ZZ, đây là cảm biến phần cứng
   và nhóm các kênh dữ liệu của cùng một con chip lại với nhau.
2. ZZ0001ZZ, giao diện nút thiết bị ký tự được sử dụng cho
   truyền dữ liệu đệm và truy xuất thông tin sự kiện.

Trình điều khiển IIO điển hình sẽ tự đăng ký dưới dạng ZZ0000ZZ hoặc
Trình điều khiển ZZ0001ZZ và sẽ tạo hai thói quen, thăm dò và xóa.

Tại thăm dò:

1. Gọi iio_device_alloc(), phân bổ bộ nhớ cho thiết bị IIO.
2. Khởi tạo các trường thiết bị IIO với thông tin cụ thể về trình điều khiển (ví dụ:
   tên thiết bị, kênh thiết bị).
3. Gọi iio_device_register(), thao tác này sẽ đăng ký thiết bị với
   Lõi IIO. Sau cuộc gọi này, thiết bị sẵn sàng chấp nhận yêu cầu từ người dùng
   ứng dụng không gian.

Khi xóa, chúng tôi giải phóng các tài nguyên được phân bổ trong thăm dò theo thứ tự ngược lại:

1. iio_device_unregister(), hủy đăng ký thiết bị khỏi lõi IIO.
2. iio_device_free(), giải phóng bộ nhớ được phân bổ cho thiết bị IIO.

Giao diện sysfs của thiết bị IIO
==========================

Các thuộc tính là các tệp sysfs được sử dụng để hiển thị thông tin chip và cũng cho phép
ứng dụng để thiết lập các thông số cấu hình khác nhau. Đối với thiết bị có
chỉ mục X, các thuộc tính có thể được tìm thấy trong /sys/bus/iio/devices/iio:deviceX/
thư mục.  Các thuộc tính chung là:

* ZZ0000ZZ, mô tả về chip vật lý.
* ZZ0001ZZ, hiển thị cặp chính:phụ liên kết với
  Nút ZZ0002ZZ.
* ZZ0003ZZ, bộ lấy mẫu rời rạc có sẵn
  giá trị tần số cho thiết bị.
* Các thuộc tính tiêu chuẩn có sẵn cho thiết bị IIO được mô tả trong
  :file:Tệp Documentation/ABI/testing/sysfs-bus-iio trong nhân Linux
  nguồn.

Kênh thiết bị IIO
===================

struct iio_chan_spec - đặc điểm kỹ thuật của một kênh

Kênh thiết bị IIO là đại diện của kênh dữ liệu. Một thiết bị IIO có thể
có một hoặc nhiều kênh. Ví dụ:

* cảm biến nhiệt kế có một kênh biểu thị phép đo nhiệt độ.
* một cảm biến ánh sáng với hai kênh cho biết các phép đo trong vùng nhìn thấy được
  và phổ hồng ngoại.
* một gia tốc kế có thể có tối đa 3 kênh biểu thị gia tốc trên X, Y
  và trục Z.

Kênh IIO được mô tả bởi cấu trúc iio_chan_spec.
Bộ điều khiển nhiệt kế cho cảm biến nhiệt độ trong ví dụ trên sẽ
phải mô tả kênh của mình như sau::

const tĩnh struct iio_chan_spec temp_channel[] = {
        {
            .type = IIO_TEMP,
            .info_mask_separate = BIT(IIO_CHAN_INFO_PROCESSED),
        },
   };

Các thuộc tính sysfs kênh được hiển thị cho không gian người dùng được chỉ định dưới dạng
mặt nạ bit. Tùy thuộc vào thông tin được chia sẻ của họ, các thuộc tính có thể được đặt ở một trong các
mặt nạ sau:

* ZZ0000ZZ, các thuộc tính sẽ dành riêng cho
  kênh này
* ZZ0001ZZ, các thuộc tính được chia sẻ bởi tất cả các kênh của
  cùng loại
* ZZ0002ZZ, các thuộc tính được chia sẻ bởi tất cả các kênh giống nhau
  phương hướng
* ZZ0003ZZ, thuộc tính được chia sẻ bởi tất cả các kênh

Khi có nhiều kênh dữ liệu cho mỗi loại kênh, chúng ta có hai cách để
phân biệt giữa chúng:

* đặt trường ZZ0003ZZ của ZZ0000ZZ thành 1. Công cụ sửa đổi là
  được chỉ định bằng trường ZZ0004ZZ của cùng ZZ0001ZZ
  cấu trúc và được sử dụng để chỉ ra một đặc tính vật lý độc đáo của
  kênh chẳng hạn như hướng hoặc phản ứng quang phổ của nó. Ví dụ, một ánh sáng
  Cảm biến có thể có hai kênh, một cho ánh sáng hồng ngoại và một cho cả hai
  ánh sáng hồng ngoại và ánh sáng nhìn thấy.
* đặt trường ZZ0005ZZ của ZZ0002ZZ thành 1. Trong trường hợp này,
  kênh chỉ đơn giản là một phiên bản khác có chỉ mục được chỉ định bởi ZZ0006ZZ
  lĩnh vực.

Đây là cách chúng ta có thể sử dụng các công cụ sửa đổi của kênh::

const tĩnh struct iio_chan_spec light_channels[] = {
           {
                   .type = IIO_INTENSITY,
                   .đã sửa đổi = 1,
                   .channel2 = IIO_MOD_LIGHT_IR,
                   .info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
                   .info_mask_shared = BIT(IIO_CHAN_INFO_SAMP_FREQ),
           },
           {
                   .type = IIO_INTENSITY,
                   .đã sửa đổi = 1,
                   .channel2 = IIO_MOD_LIGHT_BOTH,
                   .info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
                   .info_mask_shared = BIT(IIO_CHAN_INFO_SAMP_FREQ),
           },
           {
                   .type = IIO_LIGHT,
                   .info_mask_separate = BIT(IIO_CHAN_INFO_PROCESSED),
                   .info_mask_shared = BIT(IIO_CHAN_INFO_SAMP_FREQ),
           },
      }

Định nghĩa của kênh này sẽ tạo ra hai tệp sysfs riêng biệt cho dữ liệu thô
truy xuất:

* ZZ0000ZZ
* ZZ0001ZZ

một tệp cho dữ liệu đã xử lý:

* ZZ0000ZZ

và một tệp sysfs được chia sẻ cho tần suất lấy mẫu:

*ZZ0000ZZ.

Đây là cách chúng tôi có thể sử dụng tính năng lập chỉ mục của kênh::

const tĩnh struct iio_chan_spec light_channels[] = {
           {
                   .type = IIO_VOLTAGE,
		   .được lập chỉ mục = 1,
		   .kênh = 0,
		   .info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
	   },
           {
	           .type = IIO_VOLTAGE,
                   .được lập chỉ mục = 1,
                   .kênh = 1,
                   .info_mask_separate = BIT(IIO_CHAN_INFO_RAW),
           },
   }

Điều này sẽ tạo ra hai tệp thuộc tính riêng biệt để truy xuất dữ liệu thô:

* ZZ0000ZZ, đại diện
  đo điện áp cho kênh 0.
* ZZ0001ZZ, đại diện
  đo điện áp cho kênh 1.

Thêm chi tiết
============
.. kernel-doc:: include/linux/iio/iio.h
.. kernel-doc:: drivers/iio/industrialio-core.c
   :export:
