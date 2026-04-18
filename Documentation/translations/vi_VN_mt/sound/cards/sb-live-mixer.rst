.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/sb-live-mixer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Bộ trộn trực tiếp Sound Blaster / mã DSP mặc định
=================================================


Các chip EMU10K1 có bộ phận DSP có thể được lập trình để hỗ trợ
nhiều cách xử lý mẫu khác nhau, được mô tả ở đây.
(Bài viết này không đề cập đến chức năng tổng thể của 
Chip EMU10K1. Xem phần hướng dẫn sử dụng để biết thêm chi tiết.)

Trình điều khiển ALSA lập trình phần chip này theo mã mặc định
(có thể được thay đổi sau) cung cấp các chức năng sau:


IEC958 (S/PDIF) PCM thô
=======================

Thiết bị PCM này (là thiết bị PCM thứ 3 (chỉ số 2!) Và thiết bị con đầu tiên
(chỉ số 0) cho một thẻ nhất định) cho phép chuyển tiếp 48kHz, âm thanh nổi, 16 bit
các luồng endian nhỏ mà không có bất kỳ sửa đổi nào đối với đầu ra kỹ thuật số
(đồng trục hoặc quang học). Giao diện phổ quát cho phép tạo ra
đến 8 thiết bị PCM thô hoạt động ở tần số 48kHz, endian nhỏ 16 bit. Nó sẽ
dễ dàng thêm hỗ trợ cho các thiết bị đa kênh vào mã hiện tại,
nhưng các quy trình chuyển đổi chỉ tồn tại đối với âm thanh nổi (luồng 2 kênh)
vào thời điểm đó.

Hãy xem các quy trình tram_poke trong lowlevel/emu10k1/emufx.c để biết thêm chi tiết.


Điều khiển máy trộn kỹ thuật số
===============================

Các điều khiển này được xây dựng bằng hướng dẫn DSP. Họ cung cấp mở rộng
chức năng. Chỉ mô tả mã tích hợp mặc định trong trình điều khiển ALSA
ở đây. Lưu ý rằng các bộ điều khiển hoạt động như bộ suy giảm: giá trị tối đa là 
vị trí trung lập để tín hiệu không thay đổi. Lưu ý rằng nếu cùng một điểm đến
được đề cập trong nhiều điều khiển, tín hiệu được tích lũy và có thể được cắt bớt
(được đặt thành giá trị tối đa hoặc tối thiểu mà không kiểm tra tràn).


Giải thích các chữ viết tắt được sử dụng:

DAC
	bộ chuyển đổi kỹ thuật số sang analog
ADC
	bộ chuyển đổi analog sang kỹ thuật số
I2S
	Bus nối tiếp ba dây một chiều cho âm thanh kỹ thuật số của Philips Semiconductors
	(tiêu chuẩn này được sử dụng để kết nối các bộ chuyển đổi D/A và A/D độc lập)
LFE
	hiệu ứng tần số thấp (được sử dụng làm tín hiệu loa siêu trầm)
AC97
	một con chip chứa bộ trộn analog, bộ chuyển đổi D/A và A/D
IEC958
	S/PDIF
Xe buýt FX
	chip EMU10K1 có bus hiệu ứng chứa 16 bộ tích lũy.
	Mỗi giọng nói của bộ tổng hợp có thể cung cấp đầu ra của nó cho các bộ tích lũy này
	và bộ vi điều khiển DSP có thể hoạt động với tổng kết quả.


ZZ0000ZZ
---------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho các mẫu PCM bên trái và bên phải.
Các mẫu kết quả được chuyển tiếp đến các khe DAC PCM phía trước của codec AC97.

ZZ0000ZZ
------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho các mẫu PCM bên trái và bên phải.
Các mẫu kết quả được chuyển tiếp đến các DAC I2S phía sau. Các DAC này hoạt động
riêng biệt (chúng không nằm trong codec AC97).

ZZ0000ZZ
----------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho các mẫu PCM bên trái và bên phải.
Kết quả được trộn thành tín hiệu đơn âm (kênh đơn) và được chuyển tiếp tới
?? phía sau?? khe DAC PCM bên phải của codec AC97.

ZZ0000ZZ
-------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho PCM trái và phải.
Kết quả được trộn thành tín hiệu đơn âm (kênh đơn) và được chuyển tiếp tới
?? phía sau?? khe DAC PCM bên trái của codec AC97.

ZZ0000ZZ, ZZ0001ZZ
------------------------------------------------------------------------------
Các điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho PCM trái và phải.
Kết quả được chuyển tiếp đến ADC chụp FIFO (do đó để chụp tiêu chuẩn
thiết bị PCM).

ZZ0000ZZ
----------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX MIDI bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 4 và 5 cho các mẫu MIDI bên trái và bên phải.
Các mẫu kết quả được chuyển tiếp đến các khe DAC PCM phía trước của codec AC97.

ZZ0000ZZ, ZZ0001ZZ
--------------------------------------------------------------------------------
Các điều khiển này được sử dụng để làm suy giảm các mẫu từ MIDI FX-bus bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 4 và 5 cho các mẫu MIDI bên trái và bên phải.
Kết quả được chuyển tiếp đến ADC chụp FIFO (do đó để chụp tiêu chuẩn
thiết bị PCM).

ZZ0000ZZ
-------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus phía sau bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 2 và 3 cho các mẫu PCM phía sau bên trái và bên phải.
Các mẫu kết quả được chuyển tiếp đến các DAC I2S phía sau. Các DAC này hoạt động
riêng biệt (chúng không nằm trong codec AC97).

ZZ0000ZZ, ZZ0001ZZ
--------------------------------------------------------------------------------------
Các điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus phía sau bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 2 và 3 cho các mẫu PCM phía sau bên trái và bên phải.
Kết quả được chuyển tiếp đến ADC chụp FIFO (do đó để chụp tiêu chuẩn
thiết bị PCM).

ZZ0000ZZ
-----------------------------------------
Điều khiển này được sử dụng để làm suy giảm mẫu cho bộ tích lũy FX-bus trung tâm PCM.
ALSA sử dụng bộ tích lũy 6 cho mẫu PCM trung tâm. Mẫu kết quả được chuyển tiếp
về phía sau?? khe DAC PCM bên phải của codec AC97.

ZZ0000ZZ
--------------------------------------
Điều khiển này được sử dụng để làm suy giảm mẫu cho bộ tích lũy FX-bus trung tâm PCM.
ALSA sử dụng bộ tích lũy 6 cho mẫu PCM trung tâm. Mẫu kết quả được chuyển tiếp
về phía sau?? khe DAC PCM bên trái của codec AC97.

ZZ0000ZZ
---------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ các khe ADC PCM phía trước bên trái và bên phải
của codec AC97. Các mẫu kết quả được chuyển tiếp tới DAC PCM phía trước
khe cắm của codec AC97.

.. note::
  This control should be zero for the standard operations, otherwise
  a digital loopback is activated.


ZZ0000ZZ
--------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ các khe ADC PCM phía trước bên trái và bên phải
của codec AC97. Kết quả được chuyển tiếp tới ADC chụp FIFO (do đó
thiết bị PCM chụp tiêu chuẩn).

.. note::
   This control should be 100 (maximal value), otherwise no analog
   inputs of the AC97 codec can be captured (recorded).

ZZ0000ZZ
---------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải IEC958 TTL
đầu vào kỹ thuật số (thường được sử dụng bởi ổ CDROM). Các mẫu kết quả được
được chuyển tiếp đến các khe DAC PCM phía trước của codec AC97.

ZZ0000ZZ
--------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải IEC958 TTL
đầu vào kỹ thuật số (thường được sử dụng bởi ổ CDROM). Các mẫu kết quả được
được chuyển tiếp tới ADC chụp FIFO (do đó tới thiết bị PCM chụp tiêu chuẩn).

ZZ0000ZZ
---------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ video thu phóng trái và phải
đầu vào kỹ thuật số (thường được sử dụng bởi ổ CDROM). Các mẫu kết quả được
được chuyển tiếp đến các khe DAC PCM phía trước của codec AC97.

ZZ0000ZZ
--------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ video thu phóng trái và phải
đầu vào kỹ thuật số (thường được sử dụng bởi ổ CDROM). Các mẫu kết quả được
được chuyển tiếp tới ADC chụp FIFO (do đó tới thiết bị PCM chụp tiêu chuẩn).

ZZ0000ZZ
---------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ quang học IEC958 trái và phải
đầu vào kỹ thuật số. Các mẫu kết quả được chuyển tiếp đến các khe DAC PCM phía trước
của codec AC97.

ZZ0000ZZ
--------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ quang học IEC958 trái và phải
đầu vào kỹ thuật số. Các mẫu kết quả được chuyển tiếp tới ADC chụp FIFO
(do đó đối với thiết bị PCM chụp tiêu chuẩn).

ZZ0000ZZ
-------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ đồng trục IEC958 trái và phải
đầu vào kỹ thuật số. Các mẫu kết quả được chuyển tiếp đến các khe DAC PCM phía trước
của codec AC97.

ZZ0000ZZ
------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ đồng trục IEC958 trái và phải
đầu vào kỹ thuật số. Các mẫu kết quả được chuyển tiếp tới ADC chụp FIFO
(do đó đối với thiết bị PCM chụp tiêu chuẩn).

ZZ0000ZZ, ZZ0001ZZ
----------------------------------------------------------------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào (trên LiveDrive). Các mẫu kết quả được chuyển tiếp lên phía trước
Các khe DAC PCM của codec AC97.

ZZ0000ZZ, ZZ0001ZZ
--------------------------------------------------------------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào (trên LiveDrive). Các mẫu kết quả được chuyển tiếp đến ADC
chụp FIFO (do đó, thiết bị PCM chụp tiêu chuẩn).

ZZ0000ZZ
----------------------------------------
Điều khiển này bật hoặc tắt điều khiển âm thanh. Các mẫu phía trước, phía sau
và đầu ra trung tâm / LFE bị ảnh hưởng.

ZZ0000ZZ
--------------------------------------
Điều khiển này đặt cường độ âm trầm. Không có giá trị trung lập!!
Khi mã điều khiển âm thanh được kích hoạt, các mẫu luôn được sửa đổi.
Giá trị gần nhất với tín hiệu thuần là 20.

ZZ0000ZZ
----------------------------------------
Điều khiển này đặt cường độ âm bổng. Không có giá trị trung lập!!
Khi mã điều khiển âm thanh được kích hoạt, các mẫu luôn được sửa đổi.
Giá trị gần nhất với tín hiệu thuần là 20.

ZZ0000ZZ
-----------------------------------------------------
Nếu công tắc này bật thì các mẫu dành cho kỹ thuật số IEC958 (S/PDIF)
đầu ra chỉ được lấy từ FX8010 PCM thô, nếu không thì mặt trước tiêu chuẩn
Mẫu PCM được lấy.

ZZ0000ZZ
--------------------------------------------
Điều khiển này làm suy giảm các mẫu cho đầu ra tai nghe.

ZZ0000ZZ
---------------------------------------------------
Nếu công tắc này bật thì mẫu dành cho trung tâm PCM sẽ được đưa vào
đầu ra tai nghe bên trái (hữu ích cho thẻ SB Live không có trung tâm riêng/LFE
đầu ra).

ZZ0000ZZ
------------------------------------------------
Nếu công tắc này bật thì mẫu dành cho trung tâm PCM sẽ được đưa vào
đầu ra tai nghe bên phải (hữu ích cho thẻ SB Live không có trung tâm riêng/LFE
đầu ra).


Điều khiển liên quan đến luồng PCM
==================================

ZZ0000ZZ
----------------------------------------
Suy giảm âm lượng kênh trong phạm vi 0-0x1fffd. Giá trị trung bình (không
suy giảm) là mặc định. Ánh xạ kênh cho ba giá trị là
như sau:

* 0 - mono, mặc định 0xffff (không suy giảm)
* 1 - trái, mặc định 0xffff (không suy giảm)
* 2 - phải, mặc định 0xffff (không suy giảm)

ZZ0000ZZ
----------------------------------------------
Điều khiển này chỉ định đích - bộ tích lũy FX-bus. có
mười hai giá trị với ánh xạ này:

* 0 - mono, Đích A (FX-bus 0-15), mặc định 0
* 1 - mono, đích B (FX-bus 0-15), mặc định 1
* 2 - mono, đích C (FX-bus 0-15), mặc định 2
* 3 - mono, đích D (FX-bus 0-15), mặc định 3
* 4 - trái, Đích A (FX-bus 0-15), mặc định 0
* 5 - trái, đích B (FX-bus 0-15), mặc định 1
* 6 - trái, đích C (FX-bus 0-15), mặc định 2
* 7 - trái, đích D (FX-bus 0-15), mặc định 3
* 8 - phải, Đích A (FX-bus 0-15), mặc định 0
* 9 - phải, đích B (FX-bus 0-15), mặc định 1
* 10 - phải, đích C (FX-bus 0-15), mặc định 2
* 11 - phải, đích D (FX-bus 0-15), mặc định 3

Đừng quên rằng việc gán một kênh cho cùng một bộ tích lũy FX-bus là bất hợp pháp 
nhiều lần (điều đó có nghĩa là 0=0 && 1=0 là sự kết hợp không hợp lệ).
 
ZZ0000ZZ
---------------------------------------------
Nó chỉ định mức suy giảm (lượng) cho điểm đến nhất định trong phạm vi 0-255.
Bản đồ kênh như sau:

* 0 - mono, A đích attn, mặc định 255 (không suy giảm)
* 1 - mono, B đích attn, mặc định 255 (không suy giảm)
* 2 - mono, điểm đích C, mặc định 0 (tắt tiếng)
* 3 - mono, đích đến D, mặc định 0 (tắt tiếng)
* 4 - trái, A attn đích, mặc định 255 (không suy giảm)
* 5 - trái, B đích đến, mặc định 0 (tắt tiếng)
* 6 - trái, điểm đích C, mặc định 0 (tắt tiếng)
* 7 - trái, đích đến D, mặc định 0 (tắt tiếng)
* 8 - phải, A đích attn, mặc định 0 (tắt tiếng)
* 9 - phải, điểm đích B, mặc định 255 (không suy giảm)
* 10 - phải, điểm đích C, mặc định 0 (tắt tiếng)
* 11 - phải, D đích attn, mặc định 0 (tắt tiếng)



MANUALS/PATENTS
===============

ftp://opensource.creative.com/pub/doc
-------------------------------------

Lưu ý rằng trang web không còn tồn tại nhưng tài liệu vẫn có sẵn
từ nhiều địa điểm khác nhau.

LM4545.pdf
	Bộ giải mã AC97
m2049.pdf
	Bộ xử lý âm thanh kỹ thuật số EMU10K1
hog63.ps
	FX8010 - Kiến trúc chip DSP cho hiệu ứng âm thanh


Bằng sáng chế WIPO
------------------

WO 9901813 (A1)
	Bộ xử lý hiệu ứng âm thanh với nhiều luồng không đồng bộ
	(14 tháng 1 năm 1999)

WO 9901814 (A1)
	Bộ xử lý với bộ hướng dẫn cho hiệu ứng âm thanh (14 tháng 1 năm 1999)

WO 9901953 (A1)
	Bộ xử lý hiệu ứng âm thanh có hướng dẫn tách rời
        Thực thi và sắp xếp dữ liệu âm thanh (14 tháng 1 năm 1999)


Bằng sáng chế Hoa Kỳ (ZZ0000ZZ
-----------------------------------

Hoa Kỳ 5925841
	Dụng cụ lấy mẫu kỹ thuật số sử dụng bộ nhớ đệm (20/07/1999)

Hoa Kỳ 5928342
	Bộ xử lý hiệu ứng âm thanh được tích hợp trên một chip duy nhất
        với bộ nhớ nhiều cổng có nhiều cổng không đồng bộ
        mẫu âm thanh kỹ thuật số có thể được tải đồng thời
	(27 tháng 7 năm 1999)

Hoa Kỳ 5930158
	Bộ xử lý với bộ hướng dẫn cho hiệu ứng âm thanh (27 tháng 7 năm 1999)

Hoa Kỳ 6032235
	Mạch khởi tạo bộ nhớ (Tram) (29/02/2000)

Hoa Kỳ 6138207
	Vòng lặp nội suy của các mẫu âm thanh trong bộ đệm được kết nối với
        bus hệ thống với mức độ ưu tiên và sửa đổi việc chuyển bus
        phù hợp với kết thúc vòng lặp và kích thước khối tối thiểu
	(24 tháng 10 năm 2000)

Hoa Kỳ 6151670
	Phương pháp bảo tồn bộ nhớ lưu trữ bằng cách sử dụng
        tập hợp các thanh ghi bộ nhớ ngắn hạn
	(21 tháng 11 năm 2000)

Hoa Kỳ 6195715
	Kiểm soát ngắt cho nhiều chương trình giao tiếp với
        một sự gián đoạn phổ biến bằng cách liên kết các chương trình với các thanh ghi GP,
        xác định thanh ghi ngắt, thanh ghi GP thăm dò và gọi
        thói quen gọi lại liên quan đến thanh ghi ngắt được xác định
	(27 tháng 2 năm 2001)
