.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/radiotrack.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển radio Radiotrack
===========================

Tác giả: Stephen M. Benoit <benoits@servicepro.com>

Ngày: 14 tháng 12 năm 1996

ACKNOWLEDGMENTS
----------------

Tài liệu này được thực hiện dựa trên mã 'C' cho Linux của Gideon le Grange
(legrang@active.co.za hoặc legrang@cs.sun.ac.za) vào năm 1994, và các chi tiết từ
Frans Brinkman (brinkman@esd.nl) vào năm 1996. Các kết quả được báo cáo ở đây là từ
các thử nghiệm mà tác giả đã thực hiện trên thiết lập của riêng mình, vì vậy số dặm của bạn có thể
khác nhau... Tôi không đưa ra bất kỳ đảm bảo, khiếu nại hoặc bảo đảm nào về sự phù hợp hoặc
tính xác thực của thông tin này.  Không có tài liệu nào khác về AIMS
Lab (thẻ ZZ0000ZZ RadioTrack đã được cung cấp cho
tác giả.  Tài liệu này được cung cấp với hy vọng nó có thể giúp ích cho những người dùng
muốn sử dụng thẻ RadioTrack trong môi trường không phải là MS Windows.

WHY THIS DOCUMENT?
------------------

Tôi có thẻ RadioTrack từ hồi tôi chạy nền tảng MS-Windows.  Sau
chuyển sang Linux, tôi tìm thấy phần mềm dòng lệnh của Gideon le Grange dành cho
chạy thẻ thì thấy hay!  Frans Brinkman đã thực hiện một
Giao diện X-windows thoải mái và thêm tính năng quét.  Để hack
giá trị, tôi muốn xem liệu bộ dò sóng có thể được điều chỉnh ngoài đài FM thông thường hay không
băng tần phát sóng, để tôi có thể bắt sóng các nhà cung cấp âm thanh từ Bắc Mỹ
phát sóng các kênh truyền hình, nằm ngay dưới và trên dải tần 87,0-109,0 MHz.
Tôi không đạt được nhiều thành công nhưng tôi đã học về lập trình ioport dưới
Linux và thu được một số hiểu biết sâu sắc về thiết kế phần cứng được sử dụng cho thẻ.

Vì vậy, không chậm trễ hơn nữa, đây là chi tiết.


PHYSICAL DESCRIPTION
--------------------

Thẻ RadioTrack là thẻ radio FM 8 bit ISA.  Tần số vô tuyến (RF)
đầu vào chỉ đơn giản là một dây dẫn ăng-ten và đầu ra là tín hiệu âm thanh nguồn
có sẵn thông qua một phích cắm điện thoại thu nhỏ.  Tần số hoạt động RF của nó là
ít nhiều bị giới hạn từ 87,0 đến 109,0 MHz (chương trình phát sóng FM thương mại
ban nhạc).  Mặc dù các thanh ghi có thể được lập trình để yêu cầu tần số vượt quá
những giới hạn này, các thí nghiệm không cho kết quả đầy hứa hẹn.  Biến
bộ dao động tần số (VFO) giải điều chế tần số trung gian (IF)
tín hiệu có thể có một phạm vi tần số hữu ích nhỏ và bao quanh hoặc
bị cắt vượt quá giới hạn nêu trên.


CONTROLLING THE CARD WITH IOPORT
--------------------------------

Ioport RadioTrack (cơ sở) có thể định cấu hình cho 0x30c hoặc 0x20c.  Chỉ có một
ioport dường như có liên quan.  Mạch giải mã ioport phải đẹp
đơn giản, vì các bit ioport riêng lẻ được khớp trực tiếp với các chức năng cụ thể
(hoặc khối) của thẻ radio.  Bằng cách này, nhiều chức năng có thể được thay đổi trong
song song với một lần ghi vào ioport.  Phản hồi duy nhất có được thông qua
ioports dường như là bit "Phát hiện âm thanh nổi".

Các bit của ioport được sắp xếp như sau:

.. code-block:: none

	MSb                                                         LSb
	+------+------+------+--------+--------+-------+---------+--------+
	| VolA | VolB | ???? | Stereo | Radio  | TuneA | TuneB   | Tune   |
	|  (+) |  (-) |      | Detect | Audio  | (bit) | (latch) | Update |
	|      |      |      | Enable | Enable |       |         | Enable |
	+------+------+------+--------+--------+-------+---------+--------+


==== ========================================
VolA VolB Mô tả
==== ========================================
0 0 tắt âm thanh
0 1 âm lượng + (cần có độ trễ)
Âm lượng 1 0 - (yêu cầu một số độ trễ)
1 1 giữ nguyên khối lượng hiện tại
==== ========================================

===================== ============
Bật phát hiện âm thanh nổi Mô tả
===================== ============
0 Không phát hiện
1 phát hiện
===================== ============

Kết quả có sẵn bằng cách đọc ioport >60 mili giây sau lần ghi cổng cuối cùng.

0xff ==> không phát hiện thấy âm thanh nổi, 0xfd ==> phát hiện âm thanh nổi.

==============================================================
Radio to Audio (đường dẫn) Bật Mô tả
==============================================================
0 Tắt đường dẫn (im lặng)
1 Đường dẫn kích hoạt (âm thanh được tạo ra)
==============================================================

===== ===== ====================
TuneA TuneB Mô tả
===== ===== ====================
0 0 bit "không" pha 1
0 1 bit "không" giai đoạn 2
1 0 "một" bit giai đoạn 1
1 1 bit "một" giai đoạn 2
===== ===== ====================


Mã 24 bit, trong đó bit = (freq*40) + 10486188.
11 bit quan trọng nhất phải là 1010 xxxx 0x0 mới hợp lệ.
Các bit được dịch chuyển trong LSb trước tiên.

=================================================
Điều chỉnh Cập nhật Kích hoạt Mô tả
=================================================
0 Bộ điều chỉnh được giữ cố định
1 Đang cập nhật bộ chỉnh
=================================================


PROGRAMMING EXAMPLES
--------------------

.. code-block:: none

	Default:        BASE <-- 0xc8  (current volume, no stereo detect,
					radio enable, tuner adjust disable)

	Card Off:	BASE <-- 0x00  (audio mute, no stereo detect,
					radio disable, tuner adjust disable)

	Card On:	BASE <-- 0x00  (see "Card Off", clears any unfinished business)
			BASE <-- 0xc8  (see "Default")

	Volume Down:    BASE <-- 0x48  (volume down, no stereo detect,
					radio enable, tuner adjust disable)
			wait 10 msec
			BASE <-- 0xc8  (see "Default")

	Volume Up:      BASE <-- 0x88  (volume up, no stereo detect,
					radio enable, tuner adjust disable)
			wait 10 msec
			BASE <-- 0xc8  (see "Default")

	Check Stereo:   BASE <-- 0xd8  (current volume, stereo detect,
					radio enable, tuner adjust disable)
			wait 100 msec
			x <-- BASE     (read ioport)
			BASE <-- 0xc8  (see "Default")

			x=0xff ==> "not stereo", x=0xfd ==> "stereo detected"

	Set Frequency:  code = (freq*40) + 10486188
			foreach of the 24 bits in code,
			(from Least to Most Significant):
			to write a "zero" bit,
			BASE <-- 0x01  (audio mute, no stereo detect, radio
					disable, "zero" bit phase 1, tuner adjust)
			BASE <-- 0x03  (audio mute, no stereo detect, radio
					disable, "zero" bit phase 2, tuner adjust)
			to write a "one" bit,
			BASE <-- 0x05  (audio mute, no stereo detect, radio
					disable, "one" bit phase 1, tuner adjust)
			BASE <-- 0x07  (audio mute, no stereo detect, radio
					disable, "one" bit phase 2, tuner adjust)