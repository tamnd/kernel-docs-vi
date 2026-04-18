.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/procfile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Tệp Proc của trình điều khiển ALSA
==================================

Takashi Iwai <tiwai@suse.de>

Tổng quan
=========

ALSA có cây proc riêng, /proc/asound.  Nhiều thông tin hữu ích được
được tìm thấy ở cây này.  Khi bạn gặp sự cố và cần gỡ lỗi,
kiểm tra các tập tin được liệt kê trong các phần sau.

Mỗi thẻ có thẻ cây conX, trong đó X là từ 0 đến 7.
các tệp dành riêng cho thẻ được lưu trữ trong thư mục con ZZ0000ZZ.


Thông tin toàn cầu
==================

thẻ
	Hiển thị danh sách trình điều khiển ALSA hiện được cấu hình,
	chỉ mục, chuỗi id, mô tả ngắn và dài.

phiên bản
	Hiển thị chuỗi phiên bản và ngày biên dịch.

mô-đun
	Liệt kê mô-đun của mỗi thẻ

thiết bị
	Liệt kê các ánh xạ thiết bị gốc ALSA.

thông tin ghi nhớ
	Hiển thị trạng thái của các trang được phân bổ thông qua trình điều khiển ALSA.
	Chỉ xuất hiện khi ZZ0000ZZ.

hwp
	Liệt kê các thiết bị hwdep hiện có ở định dạng
	ZZ0000ZZ

pcm
	Liệt kê các thiết bị PCM hiện có ở định dạng
	ZZ0000ZZ

hẹn giờ
	Liệt kê các thiết bị hẹn giờ hiện có


oss/thiết bị
	Liệt kê các ánh xạ thiết bị OSS.

oss/sndstat
	Cung cấp đầu ra tương thích với/dev/sndstat.
	Bạn có thể liên kết biểu tượng này với/dev/sndstat.


Tệp cụ thể của thẻ
===================

Các tệp dành riêng cho thẻ được tìm thấy trong thư mục ZZ0000ZZ.
Một số trình điều khiển (ví dụ: cmipci) có mục nhập Proc riêng cho
kết xuất đăng ký, v.v. (ví dụ: ZZ0001ZZ hiển thị thanh ghi
đổ rác).  Những tập tin này sẽ thực sự hữu ích cho việc gỡ lỗi.

Khi có thiết bị PCM trên thẻ này, bạn có thể xem các thư mục
như pcm0p hoặc pcm1c.  Họ lưu giữ thông tin PCM cho mỗi PCM
suối.  Số sau ZZ0000ZZ là số thiết bị PCM từ 0 và
ZZ0001ZZ hoặc ZZ0002ZZ cuối cùng có nghĩa là hướng phát lại hoặc chụp.  Các tập tin trong
cây con này sẽ được mô tả sau.

Trạng thái của I/O MIDI được tìm thấy trong các tệp ZZ0000ZZ.  Nó hiển thị thiết bị
tên và byte được nhận/truyền qua thiết bị MIDI.

Khi thẻ được trang bị codec AC97 thì có ZZ0000ZZ
thư mục con (được mô tả sau).

Khi mô phỏng bộ trộn OSS được bật (và mô-đun được tải),
tập tin oss_mixer cũng xuất hiện ở đây.  Điều này cho thấy ánh xạ hiện tại của
Các phần tử trộn OSS với các phần tử điều khiển ALSA.  Bạn có thể thay đổi
ánh xạ bằng cách ghi vào thiết bị này.  Đọc OSS-Emulation.txt để biết
chi tiết.


Tệp Proc PCM
==============

ZZ0000ZZ
	Thông tin chung của thiết bị PCM này: #card, #thiết bị,
	dòng phụ, v.v.

ZZ0000ZZ
	Tập tin này xuất hiện khi ZZ0001ZZ và
	ZZ0002ZZ.
	Điều này hiển thị trạng thái của xrun (= tràn bộ đệm/xrun) và
	Gỡ lỗi/kiểm tra vị trí PCM không hợp lệ của lớp giữa ALSA PCM.
	Nó nhận một giá trị nguyên, có thể thay đổi bằng cách viết vào đây
	tập tin, chẳng hạn như::

# echo 5 > /proc/asound/card0/pcm0p/xrun_debug

Giá trị bao gồm các cờ bit sau:

* bit 0 = Bật thông báo gỡ lỗi XRUN/jiffies
	* bit 1 = Hiển thị dấu vết ngăn xếp tại XRUN / kiểm tra nhanh
	* bit 2 = Kích hoạt tính năng kiểm tra nhanh hơn

Khi bit 0 được đặt, trình điều khiển sẽ hiển thị thông báo tới
	nhật ký kernel khi phát hiện xrun.  Thông báo gỡ lỗi là
	cũng được hiển thị khi phát hiện thấy con trỏ H/W không hợp lệ tại
	cập nhật các khoảng thời gian (thường được gọi từ ngắt
	người xử lý).

Khi bit 1 được đặt, trình điều khiển sẽ hiển thị dấu vết ngăn xếp
	Ngoài ra.  Điều này có thể giúp gỡ lỗi.

Kể từ phiên bản 2.6.30, tùy chọn này có thể kích hoạt tính năng kiểm tra hwptr bằng cách sử dụng
	nháy mắt.  Điều này phát hiện cuộc gọi lại con trỏ không hợp lệ tự phát
	giá trị, nhưng có thể dẫn đến việc điều chỉnh quá nhiều cho một (chủ yếu là
	buggy) không cung cấp các bản cập nhật con trỏ mượt mà.
	Tính năng này được kích hoạt thông qua bit 2.

ZZ0000ZZ
	Thông tin chung về luồng phụ PCM này.

ZZ0000ZZ
	Trạng thái hiện tại của luồng phụ PCM này, thời gian đã trôi qua,
	Vị trí H/W, v.v.

ZZ0000ZZ
	Các tham số phần cứng được đặt cho luồng phụ này.

ZZ0000ZZ
	Các tham số mềm được đặt cho luồng phụ này.

ZZ0000ZZ
	Thông tin phân bổ trước bộ đệm.

ZZ0000ZZ
	Kích hoạt XRUN cho luồng đang chạy khi có bất kỳ giá trị nào
	được ghi vào tập tin Proc này.  Được sử dụng để tiêm lỗi.
	Mục này chỉ được viết.

Thông tin về mã AC97
======================

ZZ0000ZZ
	Hiển thị thông tin chung của chip codec AC97 này, chẳng hạn như
	tên, khả năng, thiết lập.

ZZ0000ZZ
	Hiển thị kết xuất đăng ký AC97.  Hữu ích cho việc gỡ lỗi.

Khi CONFIG_SND_DEBUG được bật, bạn có thể ghi vào tệp này để
	thay đổi trực tiếp một thanh ghi AC97.  Truyền hai số hex.
	Ví dụ,

::

# echo 02 9f1f > /proc/asound/card0/codec97#0/ac97#0-0+regs


Luồng âm thanh USB
==================

ZZ0000ZZ
	Hiển thị nhiệm vụ và trạng thái hiện tại của từng luồng âm thanh
	của thẻ đã cho.  Thông tin này rất hữu ích cho việc gỡ lỗi.


Bộ giải mã âm thanh HD
======================

ZZ0000ZZ
	Hiển thị thông tin codec chung và thuộc tính của từng loại
	nút tiện ích.

ZZ0000ZZ
	Có sẵn cho giao diện HDMI hoặc DisplayPort.
	Hiển thị thông tin ELD(EDID Like Data) được lấy từ bồn rửa HDMI đính kèm,
	và mô tả khả năng cũng như cấu hình âm thanh của nó.

Một số trường ELD có thể được sửa đổi bằng cách thực hiện ZZ0000ZZ.
	Chỉ thực hiện việc này nếu bạn chắc chắn rằng giá trị được cung cấp trong bồn rửa HDMI là sai.
	Và nếu điều đó làm cho âm thanh HDMI của bạn hoạt động, vui lòng báo cáo cho chúng tôi để chúng tôi
	có thể sửa nó trong các bản phát hành kernel trong tương lai.


Thông tin trình tự
=====================

seq/trình điều khiển
	Liệt kê các trình điều khiển trình sắp xếp ALSA hiện có sẵn.

seq/khách hàng
	Hiển thị danh sách các máy khách sắp xếp thứ tự hiện có và
	cổng.  Trạng thái kết nối và trạng thái chạy được hiển thị
	trong tập tin này nữa.

thứ tự/hàng đợi
	Liệt kê các hàng đợi trình sắp xếp thứ tự hiện được phân bổ/đang chạy.

seq/bộ đếm thời gian
	Liệt kê các bộ đếm thời gian sắp xếp thứ tự hiện được phân bổ/đang chạy.

seq/oss
	Liệt kê các nội dung của trình sắp xếp tương thích với OSS.


Trợ giúp gỡ lỗi?
===================

Khi sự cố liên quan đến PCM, trước tiên hãy thử bật xrun_debug
chế độ.  Điều này sẽ cung cấp cho bạn các thông báo kernel khi nào và ở đâu xrun
đã xảy ra.

Nếu đó thực sự là một lỗi, hãy báo cáo nó với thông tin sau:

- tên của trình điều khiển/thẻ, hiển thị trong ZZ0000ZZ
- kết xuất đăng ký, nếu có (ví dụ ZZ0001ZZ)

khi đó là sự cố PCM,

- thiết lập PCM, được hiển thị trong hw_parms, sw_params và trạng thái trong PCM
  thư mục dòng con

khi đó là vấn đề về máy trộn,

- Tệp Proc AC97, tệp ZZ0000ZZ

cho âm thanh/midi USB,

- đầu ra của ZZ0000ZZ
- Tệp ZZ0001ZZ trong thư mục thẻ


Hệ thống theo dõi lỗi ALSA được tìm thấy tại:
ZZ0000ZZ
