.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/iuu_phoenix.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Infinity USB Readme không giới hạn
=============================

Chào mọi người,


Mô-đun này cung cấp một giao diện nối tiếp để sử dụng
Đơn vị IUU ở chế độ phượng hoàng. Việc tải mô-đun này sẽ
mang theo giao diện ttyUSB [0-x]. Người lái xe này phải
được ứng dụng yêu thích của bạn sử dụng để điều khiển IUU

Trình điều khiển này vẫn đang trong giai đoạn thử nghiệm nên lỗi có thể xảy ra
xảy ra và hệ thống của bạn có thể bị đóng băng. Theo như tôi bây giờ,
Tôi chưa bao giờ gặp vấn đề gì với nó, nhưng tôi không phải là người thực sự
thưa thầy, vì vậy đừng trách tôi nếu hệ thống của bạn không ổn định

Bạn có thể cắm nhiều hơn một chiếc IUU. Mỗi đơn vị sẽ
có tập tin thiết bị của riêng mình (/dev/ttyUSB0,/dev/ttyUSB1,...)



Làm thế nào để điều chỉnh tốc độ đầu đọc?
=============================

Một vài tham số có thể được sử dụng khi tải
 Để sử dụng các tham số, chỉ cần dỡ bỏ mô-đun nếu nó
 đã được tải và sử dụng modprobe iuu_phoenix param=value.
 Trong trường hợp mô-đun dựng sẵn, sử dụng lệnh
 insmod iuu_phoenix param=value.

Ví dụ::

modprobe iuu_phoenix clockmode=3

Các thông số là:

chế độ đồng hồ:
	1=3Mhz579,2=3Mhz680,3=6Mhz (int)
tăng cường:
	phần trăm tăng ép xung 100 đến 500 (int)
chế độ cd:
	Chế độ phát hiện thẻ
	0=không, 1=CD, 2=!CD, 3=DSR, 4=!DSR, 5=CTS, 6=!CTS, 7=RING, 8=!RING (int)
giáng sinh:
	màu giáng sinh có được bật hay không (bool)
gỡ lỗi:
	Đã bật gỡ lỗi hay chưa (bool)

- clockmode sẽ cung cấp 3 cài đặt cơ bản khác nhau thường được áp dụng
   phần mềm khác nhau:

1. 3Mhz579
	2. 3Mhz680
	3. 6 MHz

- boost cung cấp cách ép xung đầu đọc (yêu thích của tôi :-))
   Ví dụ: để có hiệu suất tốt nhất so với clockmode=3 đơn giản, hãy thử điều này ::

tăng cường modprobe=195

Điều này sẽ đặt đầu đọc ở tần số cơ bản là 3Mhz579 nhưng được tăng tốc 195%!
   đồng hồ thực bây giờ sẽ là: 6979050 Hz (6Mhz979) và sẽ tăng
   tốc độ đạt điểm tốt hơn từ 10 đến 20% so với chế độ đồng hồ đơn giản=3 !!!


- cdmode cho phép thiết lập tín hiệu được sử dụng để thông báo cho vùng người dùng (câu trả lời ioctl)
   thẻ có tồn tại hay không. Có thể có tám tín hiệu.

- Giáng sinh hoàn toàn vô dụng ngoại trừ đôi mắt của bạn. Đây là một trong những người bạn của tôi, người đã
   thật buồn khi có một thiết bị đẹp như iuu mà không thấy đủ dải màu.
   Vì vậy tôi đã thêm tùy chọn này để cho phép bé nhìn thấy nhiều màu sắc (mỗi hoạt động sẽ thay đổi màu sắc
   và tần số ngẫu nhiên)

- gỡ lỗi sẽ tạo ra rất nhiều thông báo gỡ lỗi...


Ghi chú cuối cùng
==========

Đừng lo lắng về cài đặt nối tiếp, mô phỏng nối tiếp
 là một sự trừu tượng, vì vậy việc sử dụng bất kỳ cài đặt tốc độ hoặc tính chẵn lẻ nào sẽ
 làm việc. (Điều này sẽ không thay đổi bất cứ điều gì). Sau này có lẽ tôi sẽ thay đổi
 sử dụng cài đặt này để suy ra de boost nhưng tính năng đó có phải không
 thực sự cần thiết?
 Tính năng tự động phát hiện được sử dụng là đĩa CD nối tiếp. Nếu điều đó không
 làm việc cho phần mềm của bạn, hãy tắt cơ chế phát hiện trong đó.


Chúc vui vẻ!

Alain Degreffe

bệnh chàm(at)ecze.com
