.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/sa1100/serial_uart.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Cổng nối tiếp SA1100
==================

Cổng nối tiếp SA1100 có số chính/phụ được gán chính thức::

> Ngày: CN, 24/09/2000 21:40:27 -0700
  > Từ: H. Peter Anvin <hpa@transmeta.com>
  > Tới: Nicolas Pitre <nico@CAM.ORG>
  > Cc: Người duy trì danh sách thiết bị <device@lanana.org>
  > Chủ đề: Re: thiết bị
  >
  > Được rồi.  Lưu ý rằng số thiết bị 204 và 205 được sử dụng cho "mật độ thấp
  > thiết bị nối tiếp", vì vậy bạn sẽ có một loạt các chuyên ngành phụ trong các chuyên ngành đó (
  > lớp thiết bị tty xử lý việc này rất tốt nên bạn không phải lo lắng về
  > làm điều gì đó đặc biệt.)
  >
  > Vậy nhiệm vụ của bạn là:
  >
  > 204 char Cổng nối tiếp mật độ thấp
  > 5 = /dev/ttySA0 SA1100 cổng nối tiếp tích hợp 0
  > 6 = /dev/ttySA1 SA1100 cổng nối tiếp tích hợp 1
  > 7 = /dev/ttySA2 SA1100 cổng nối tiếp tích hợp 2
  >
  > 205 char Cổng nối tiếp mật độ thấp (thiết bị thay thế)
  > 5 = /dev/cusa0 Thiết bị chú thích cho ttySA0
  > 6 = /dev/cusa1 Thiết bị chú thích cho ttySA1
  > 7 = /dev/cusa2 Thiết bị chú thích cho ttySA2
  >

Bạn phải tạo các nút đó trong /dev trên hệ thống tập tin gốc được sử dụng
bởi thiết bị dựa trên SA1100 của bạn::

mknod ttySA0 c 204 5
	mknod ttySA1 c 204 6
	mknod ttySA2 c 204 7
	mknod cusa0 c 205 5
	mknod cusa1 c 205 6
	mknod cusa2 c 205 7

Ngoài việc tạo các nút thiết bị thích hợp ở trên, bạn
phải đảm bảo các ứng dụng không gian người dùng của bạn sử dụng đúng thiết bị
tên. Ví dụ kinh điển là nội dung của tệp /etc/inittab trong đó
bạn có thể bắt đầu một quá trình getty trên ttyS0.

Trong trường hợp này:

- thay thế các lần xuất hiện của ttyS0 bằng ttySA0, ttyS1 bằng ttySA1, v.v.

- đừng quên thêm 'ttySA0', 'console' hoặc tên tty thích hợp
  trong /etc/securetty để root cũng được phép đăng nhập.
