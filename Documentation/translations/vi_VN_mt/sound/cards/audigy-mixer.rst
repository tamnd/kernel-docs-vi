.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/audigy-mixer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Bộ trộn âm thanh Blaster Audigy / mã DSP mặc định
=================================================

Điều này dựa trên sb-live-mixer.rst.

Các chip EMU10K2 có bộ phận DSP có thể được lập trình để hỗ trợ 
nhiều cách xử lý mẫu khác nhau, được mô tả ở đây.
(Bài viết này không đề cập đến chức năng tổng thể của 
Chip EMU10K2. Xem phần hướng dẫn sử dụng để biết thêm chi tiết.)

Trình điều khiển ALSA lập trình phần chip này theo mã mặc định
(có thể được thay đổi sau) cung cấp các chức năng sau:


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
	chip EMU10K2 có bus hiệu ứng chứa 64 bộ tích lũy.
	Mỗi giọng nói của bộ tổng hợp có thể cung cấp đầu ra của nó cho các bộ tích lũy này
	và bộ vi điều khiển DSP có thể hoạt động với tổng kết quả.

name='PCM Khối lượng phát lại phía trước',index=0
-------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus phía trước bên trái và bên phải
ắc quy. ALSA sử dụng ắc quy 8 và 9 cho mặt trước bên trái và bên phải PCM 
mẫu để phát lại 5.1. Các mẫu kết quả được chuyển tiếp đến các loa phía trước.

name='PCM Âm lượng phát lại âm thanh vòm',index=0
-------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ xung quanh trái và phải PCM FX-bus
ắc quy. ALSA sử dụng bộ tích lũy 2 và 3 cho âm thanh vòm trái và phải PCM 
mẫu để phát lại 5.1. Các mẫu kết quả được chuyển tiếp đến xung quanh (phía sau)
loa.

name='PCM Âm lượng phát lại bên',index=0
----------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus bên trái và bên phải
ắc quy. ALSA sử dụng ắc quy 14 và 15 cho bên trái và bên phải PCM
mẫu để phát lại 7.1. Các mẫu kết quả được chuyển tiếp đến các loa bên.

name='PCM Âm lượng phát lại trung tâm',index=0
----------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bộ tích lũy FX-bus PCM trung tâm.
ALSA sử dụng bộ tích lũy 6 cho các mẫu PCM trung tâm để phát lại 5.1. kết quả
mẫu được chuyển tiếp đến loa trung tâm.

name='PCM LFE Khối lượng phát lại',index=0
------------------------------------------
Điều khiển này được sử dụng để làm suy giảm mẫu cho bộ tích lũy FX-bus LFE PCM. 
ALSA sử dụng bộ tích lũy 7 cho các mẫu LFE PCM để phát lại 5.1. kết quả
mẫu được chuyển tiếp đến loa siêu trầm.

name='PCM Khối lượng phát lại',index=0
--------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho các mẫu PCM trái và phải cho
phát lại âm thanh nổi. Các mẫu kết quả được chuyển tiếp đến các loa phía trước.

name='PCM Khối lượng chụp',index=0
----------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho các mẫu PCM trái và phải cho
phát lại âm thanh nổi. Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

name='Âm lượng phát nhạc',index=0
------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX MIDI bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 4 và 5 cho các mẫu MIDI bên trái và bên phải.
Các mẫu kết quả được chuyển tiếp đến bộ trộn âm thanh nổi ảo.

name='Âm lượng thu nhạc',index=0
-----------------------------------
Các điều khiển này được sử dụng để làm suy giảm các mẫu từ MIDI FX-bus bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 4 và 5 cho các mẫu MIDI bên trái và bên phải.
Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

name='Âm lượng phát lại micrô',index=0
--------------------------------------
Điều khiển này được sử dụng để giảm âm lượng mẫu từ đầu vào Mic trái và phải của
bộ giải mã AC97. Các mẫu kết quả được chuyển tiếp đến bộ trộn âm thanh nổi ảo.

name='Âm lượng thu mic',index=0
---------------------------------
Điều khiển này được sử dụng để giảm âm lượng mẫu từ đầu vào Mic trái và phải của
bộ giải mã AC97. Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

Các mẫu gốc cũng được chuyển tiếp đến thiết bị Mic capture PCM (thiết bị 1;
16bit/8KHz mono) không có điều khiển âm lượng.

name='Khối lượng phát lại CD của Audigy',index=0
------------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải IEC958 TTL
đầu vào kỹ thuật số (thường được sử dụng bởi ổ CDROM). Các mẫu kết quả được
được chuyển tiếp đến bộ trộn âm thanh nổi ảo.

name='Audigy CD Capture Volume',index=0
---------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải IEC958 TTL
đầu vào kỹ thuật số (thường được sử dụng bởi ổ CDROM). Kết quả được chuyển tiếp
đến thiết bị PCM chụp tiêu chuẩn.

name='IEC958 Khối lượng phát lại quang học',index=0
---------------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ quang học IEC958 trái và phải
đầu vào kỹ thuật số. Các mẫu kết quả được chuyển tiếp đến bộ trộn âm thanh nổi ảo.

name='IEC958 Khối lượng chụp quang',index=0
--------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ quang học IEC958 trái và phải
đầu vào kỹ thuật số. Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

name='Khối lượng phát lại Line2',index=0
----------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào (trên AudigyDrive). Các mẫu kết quả được chuyển tiếp đến máy ảo
máy trộn âm thanh nổi.

name='Khối lượng chụp Line2',index=1
------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào (trên AudigyDrive). Kết quả được chuyển tiếp đến bản chụp tiêu chuẩn
Thiết bị PCM.

name='Khối lượng phát lại hỗn hợp tương tự',index=0
---------------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào từ Philips ADC. Các mẫu kết quả được chuyển tiếp đến máy ảo
máy trộn âm thanh nổi. Nó chứa sự pha trộn từ các nguồn analog như CD, Line In, Aux, ....

name='Khối lượng thu thập hỗn hợp tương tự',index=1
---------------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào Philips ADC. Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

name='Âm lượng phát lại Aux2',index=0
-------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào (trên AudigyDrive). Các mẫu kết quả được chuyển tiếp đến máy ảo
máy trộn âm thanh nổi.

name='Âm lượng chụp Aux2',index=1
----------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ trái và phải I2S ADC
đầu vào (trên AudigyDrive). Kết quả được chuyển tiếp đến bản chụp tiêu chuẩn
Thiết bị PCM.

name='Khối lượng phát lại phía trước',index=0
---------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến các loa phía trước.

name='Âm lượng phát lại âm thanh vòm',index=0
---------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến loa vòm (phía sau).

name='Khối lượng phát lại bên cạnh',index=0
-------------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến các loa bên.

name='Khối lượng phát lại ở giữa',index=0
-----------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến loa trung tâm.

name='LFE Khối lượng phát lại',index=0
--------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến loa siêu trầm.

name='Điều khiển giai điệu - Chuyển đổi',index=0
------------------------------------------------
Điều khiển này bật hoặc tắt điều khiển âm thanh. Các mẫu được chuyển đến
đầu ra loa bị ảnh hưởng.

name='Điều khiển giai điệu - Âm trầm',index=0
---------------------------------------------
Điều khiển này đặt cường độ âm trầm. Không có giá trị trung lập!!
Khi mã điều khiển âm thanh được kích hoạt, các mẫu luôn được sửa đổi.
Giá trị gần nhất với tín hiệu thuần là 20.

name='Điều khiển giai điệu - Treble',index=0
--------------------------------------------
Điều khiển này đặt cường độ âm bổng. Không có giá trị trung lập!!
Khi mã điều khiển âm thanh được kích hoạt, các mẫu luôn được sửa đổi.
Giá trị gần nhất với tín hiệu thuần là 20.

name='Khối lượng phát lại chính',index=0
----------------------------------------
Điều khiển này được sử dụng để giảm âm lượng các mẫu được chuyển tiếp đến đầu ra loa.

name='IEC958 Công tắc phát lại quang học thô',index=0
-----------------------------------------------------
Nếu công tắc này bật thì các mẫu dành cho kỹ thuật số IEC958 (S/PDIF)
đầu ra chỉ được lấy từ thiết bị iec958 ALSA PCM thô (sử dụng
bộ tích lũy 20 và 21 cho PCM trái và phải theo mặc định).


Điều khiển liên quan đến luồng PCM
==================================

name='EMU10K1 PCM Khối lượng',chỉ số 0-31
-----------------------------------------
Suy giảm âm lượng kênh trong phạm vi 0-0x1fffd. Giá trị trung bình (không
suy giảm) là mặc định. Ánh xạ kênh cho ba giá trị là
như sau:

* 0 - mono, mặc định 0xffff (không suy giảm)
* 1 - trái, mặc định 0xffff (không suy giảm)
* 2 - phải, mặc định 0xffff (không suy giảm)

name='EMU10K1 PCM Gửi định tuyến',chỉ mục 0-31
----------------------------------------------
Điều khiển này chỉ định đích - bộ tích lũy FX-bus. Có 24
các giá trị trong ánh xạ này:

* 0 - mono, Đích A (FX-bus 0-63), mặc định 0
* 1 - mono, đích B (FX-bus 0-63), mặc định 1
* 2 - mono, đích C (FX-bus 0-63), mặc định 2
* 3 - mono, đích D (FX-bus 0-63), mặc định 3
* 4 - mono, đích E (FX-bus 0-63), mặc định 4
* 5 - mono, đích F (FX-bus 0-63), mặc định 5
* 6 - mono, đích G (FX-bus 0-63), mặc định 6
* 7 - mono, đích H (FX-bus 0-63), mặc định 7
* 8 - trái, Đích A (FX-bus 0-63), mặc định 0
* 9 - trái, đích B (FX-bus 0-63), mặc định 1
* 10 - trái, đích C (FX-bus 0-63), mặc định 2
* 11 - trái, đích D (FX-bus 0-63), mặc định 3
* 12 - trái, đích E (FX-bus 0-63), mặc định 4
* 13 - trái, đích F (FX-bus 0-63), mặc định 5
* 14 - trái, đích G (FX-bus 0-63), mặc định 6
* 15 - trái, đích H (FX-bus 0-63), mặc định 7
* 16 - phải, Đích A (FX-bus 0-63), mặc định 0
* 17 - phải, đích B (FX-bus 0-63), mặc định 1
* 18 - phải, đích C (FX-bus 0-63), mặc định 2
* 19 - phải, đích D (FX-bus 0-63), mặc định 3
* 20 - phải, đích E (FX-bus 0-63), mặc định 4
* 21 - phải, đích F (FX-bus 0-63), mặc định 5
* 22 - phải, đích G (FX-bus 0-63), mặc định 6
* 23 - phải, đích H (FX-bus 0-63), mặc định 7

Đừng quên rằng việc gán một kênh cho cùng một bộ tích lũy FX-bus là bất hợp pháp 
nhiều lần (điều đó có nghĩa là 0=0 && 1=0 là sự kết hợp không hợp lệ).
 
name='EMU10K1 PCM Gửi khối lượng',chỉ số 0-31
---------------------------------------------
Nó chỉ định mức suy giảm (lượng) cho điểm đến nhất định trong phạm vi 0-255.
Bản đồ kênh như sau:

* 0 - mono, A đích attn, mặc định 255 (không suy giảm)
* 1 - mono, B đích attn, mặc định 255 (không suy giảm)
* 2 - mono, điểm đích C, mặc định 0 (tắt tiếng)
* 3 - mono, đích đến D, mặc định 0 (tắt tiếng)
* 4 - mono, E đích attn, mặc định 0 (tắt tiếng)
* 5 - mono, F đích attn, mặc định 0 (tắt tiếng)
* 6 - mono, G đích attn, mặc định 0 (tắt tiếng)
* 7 - mono, H đích attn, mặc định 0 (tắt tiếng)
* 8 - trái, A attn đích, mặc định 255 (không suy giảm)
* 9 - trái, B đích đến, mặc định 0 (tắt tiếng)
* 10 - trái, điểm đích C, mặc định 0 (tắt tiếng)
* 11 - trái, đích đến D, mặc định 0 (tắt tiếng)
* 12 - trái, E đích attn, mặc định 0 (tắt tiếng)
* 13 - trái, F đích attn, mặc định 0 (tắt tiếng)
* 14 - trái, G đích attn, mặc định 0 (tắt tiếng)
* 15 - trái, H đích đến, mặc định 0 (tắt tiếng)
* 16 - phải, A đích attn, mặc định 0 (tắt tiếng)
* 17 - phải, điểm đích B, mặc định 255 (không suy giảm)
* 18 - phải, điểm đích C, mặc định 0 (tắt tiếng)
* 19 - phải, D đích attn, mặc định 0 (tắt tiếng)
* 20 - phải, E đích attn, mặc định 0 (tắt tiếng)
* 21 - phải, F đích attn, mặc định 0 (tắt tiếng)
* 22 - phải, G đích attn, mặc định 0 (tắt tiếng)
* 23 - phải, H đích attn, mặc định 0 (tắt tiếng)



MANUALS/PATENTS
===============

Xem sb-live-mixer.rst.
