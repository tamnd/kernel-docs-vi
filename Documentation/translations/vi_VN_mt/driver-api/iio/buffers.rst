.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/iio/buffers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
Bộ đệm
=======

* struct iio_buffer - cấu trúc bộ đệm chung
* ZZ0000ZZ — Xác thực chính xác một kênh đó
  được chọn
* ZZ0001ZZ — Lấy tham chiếu đến bộ đệm
* ZZ0002ZZ - Giải phóng tham chiếu đến bộ đệm

Lõi I/O công nghiệp cung cấp một cách để thu thập dữ liệu liên tục dựa trên
nguồn kích hoạt. Nhiều kênh dữ liệu có thể được đọc cùng một lúc từ
Nút thiết bị ký tự ZZ0000ZZ, do đó giảm tải CPU.

Giao diện sysfs bộ đệm IIO
==========================
Bộ đệm IIO có thư mục thuộc tính liên quan bên dưới
ZZ0000ZZ. Dưới đây là một số
thuộc tính hiện có:

* ZZ0000ZZ, tổng số mẫu dữ liệu (dung lượng) có thể
  được lưu trữ bởi bộ đệm.
* ZZ0001ZZ, kích hoạt chụp bộ đệm.

Thiết lập bộ đệm IIO
================

Thông tin meta liên quan đến việc đọc kênh được đặt trong bộ đệm là
được gọi là phần tử quét. Các bit quan trọng cấu hình các phần tử quét là
tiếp xúc với các ứng dụng không gian người dùng thông qua
Thư mục ZZ0000ZZ. Cái này
thư mục chứa các thuộc tính có dạng sau:

* ZZ0000ZZ, được sử dụng để kích hoạt kênh. Nếu và chỉ khi thuộc tính của nó
  không phải là ZZ0003ZZ thì quá trình chụp được kích hoạt sẽ chứa các mẫu dữ liệu cho việc này
  kênh.
* ZZ0001ZZ, scan_index của kênh.
* ZZ0002ZZ, mô tả lưu trữ dữ liệu phần tử quét trong bộ đệm
  và do đó nó được đọc từ không gian người dùng.
  Định dạng là [be|le]:[s|u]bits/storagebits[Xrepeat][>>shift] .

* ZZ0000ZZ hoặc ZZ0001ZZ, chỉ định endian lớn hay nhỏ.
  * ZZ0002ZZ hoặc ZZ0003ZZ, chỉ định có dấu (phần bù 2) hay không dấu.
  * ZZ0004ZZ, là số bit dữ liệu hợp lệ.
  * ZZ0005ZZ, là số bit (sau phần đệm) mà nó chiếm trong
    bộ đệm.
  * ZZ0006ZZ, chỉ định số lần lặp lại bit/bit lưu trữ. Khi
    phần tử lặp lại là 0 hoặc 1 thì giá trị lặp lại sẽ bị bỏ qua.
  * ZZ0007ZZ, nếu được chỉ định, là ca cần được áp dụng trước
    che giấu các bit không sử dụng.

Ví dụ: trình điều khiển cho gia tốc kế 3 trục có độ phân giải 12 bit trong đó
dữ liệu được lưu trữ trong hai thanh ghi 8 bit như sau ::

7 6 5 4 3 2 1 0
      +---+---+---+---+---+---+---+---+
      ZZ0000ZZD2 ZZ0001ZZD0 ZZ0002ZZ X ZZ0003ZZ X | (LOW byte, địa chỉ 0x06)
      +---+---+---+---+---+---+---+---+

7 6 5 4 3 2 1 0
      +---+---+---+---+---+---+---+---+
      ZZ0000ZZD10ZZ0001ZZD8 ZZ0002ZZD6 ZZ0003ZZD4 | (HIGH byte, địa chỉ 0x07)
      +---+---+---+---+---+---+---+---+

sẽ có loại phần tử quét sau cho mỗi trục::

$ cat /sys/bus/iio/devices/iio:device0/scan_elements/in_accel_y_type
      le:s12/16>>4

Ứng dụng không gian người dùng sẽ diễn giải các mẫu dữ liệu được đọc từ bộ đệm dưới dạng
dữ liệu có dấu endian nhỏ hai byte, cần dịch chuyển sang phải 4 bit trước
che giấu 12 bit dữ liệu hợp lệ.

Để triển khai hỗ trợ bộ đệm, trình điều khiển nên khởi tạo như sau
các trường trong định nghĩa iio_chan_spec::

cấu trúc iio_chan_spec {
   /*các thành viên khác*/
           int scan_index
           cấu trúc {
                   ký hiệu char;
                   bit thực u8;
                   bit lưu trữ u8;
                   ca u8;
                   u8 lặp lại;
                   enum iio_endian về độ bền;
                  } quét_type;
          };

Người lái xe thực hiện gia tốc kế được mô tả ở trên sẽ có
định nghĩa kênh sau::

struct iio_chan_spec accel_channels[] = {
           {
                   .type = IIO_ACCEL,
		   .đã sửa đổi = 1,
		   .channel2 = IIO_MOD_X,
		   /*những thứ khác ở đây*/
		   .scan_index = 0,
		   .scan_type = {
		           .sign = 's',
			   .realbits = 12,
			   .storagebits = 16,
			   .shift = 4,
			   .endianness = IIO_LE,
		   },
           }
           /* tương tự cho Y (với kênh2 = IIO_MOD_Y, scan_index = 1)
            * và trục Z (với kênh2 = IIO_MOD_Z, scan_index = 2)
            */
    }

Ở đây ZZ0000ZZ xác định thứ tự đặt các kênh đã bật
bên trong bộ đệm. Các kênh có ZZ0001ZZ thấp hơn sẽ được đặt trước
kênh có chỉ số cao hơn. Mỗi kênh cần có một kênh riêng
ZZ0002ZZ.

Có thể sử dụng cài đặt ZZ0000ZZ thành -1 để cho biết rằng kênh cụ thể
không hỗ trợ chụp đệm. Trong trường hợp này sẽ không có mục nào được tạo cho
kênh trong thư mục scan_elements.

Thêm chi tiết
============
.. kernel-doc:: include/linux/iio/buffer.h
.. kernel-doc:: drivers/iio/industrialio-buffer.c
   :export:
