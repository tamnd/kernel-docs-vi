.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/emu-mixer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================================
Bộ trộn hệ thống âm thanh kỹ thuật số E-MU / mã DSP mặc định
==================================================

Tài liệu này bao gồm E-MU 0404/1010/1212/1616/1820 PCI/PCI-e/CardBus
thẻ.

Các thẻ này sử dụng chip EMU10K2 (SoundBlaster Audigy) thông thường nhưng có
giao diện người dùng thay thế hướng tới việc ghi âm phòng thu bán chuyên nghiệp.

Tài liệu này dựa trên audigy-mixer.rst.


Khả năng tương thích phần cứng
======================

Các chip EMU10K2 có FIFO thu rất ngắn, giúp ghi âm
không đáng tin cậy nếu các yêu cầu bus PCI của thẻ không được xử lý bằng
ưu tiên phù hợp.
Đây là trường hợp trên các bo mạch chủ hiện đại hơn, trong đó bus PCI chỉ là một
thiết bị ngoại vi thứ cấp, chứ không phải là trọng tài thực tế của việc truy cập thiết bị.
Đặc biệt, tôi gặp trục trặc khi ghi âm trong khi phát lại đồng thời trên một thiết bị.
Bo mạch Intel DP55 (bộ điều khiển bộ nhớ trong CPU), nhưng đã thành công với
Bo mạch Intel DP45 (bộ điều khiển bộ nhớ ở cầu bắc).

Các biến thể PCI Express của những thẻ này (có cầu nối PCI trên bo mạch,
nhưng giống hệt nhau) có thể ít vấn đề hơn.


Khả năng của trình điều khiển
===================

Trình điều khiển này chỉ hỗ trợ hoạt động 16-bit 44.1/48 kHz. Đa kênh
thiết bị (xem emu10k1-jack.rst) cũng hỗ trợ chụp 24-bit.

Một bản vá để nâng cao trình điều khiển có sẵn từ ZZ0000ZZ.
Thiết bị đa kênh của nó hỗ trợ 24-bit cho cả phát lại và chụp,
và cũng hỗ trợ hoạt động đầy đủ ở 88.2/96/176.4/192 kHz.
Nó sẽ không được ngược dòng do sự bất đồng cơ bản về
những gì tạo nên trải nghiệm người dùng tốt.


Điều khiển máy trộn kỹ thuật số
======================

Lưu ý rằng các bộ điều khiển hoạt động như bộ suy giảm: giá trị tối đa là giá trị trung tính
vị trí để tín hiệu không thay đổi. Lưu ý rằng nếu cùng một điểm đến
được đề cập trong nhiều điều khiển, tín hiệu được tích lũy và có thể được cắt bớt
(được đặt thành giá trị tối đa hoặc tối thiểu mà không kiểm tra tràn).

Giải thích các chữ viết tắt được sử dụng:

DAC
	bộ chuyển đổi kỹ thuật số sang analog
ADC
	bộ chuyển đổi analog sang kỹ thuật số
LFE
	hiệu ứng tần số thấp (được sử dụng làm tín hiệu loa siêu trầm)
IEC958
	S/PDIF
Xe buýt FX
	chip EMU10K2 có bus hiệu ứng chứa 64 bộ tích lũy.
	Mỗi giọng nói của bộ tổng hợp có thể cung cấp đầu ra của nó cho các bộ tích lũy này
	và bộ vi điều khiển DSP có thể hoạt động với tổng kết quả.

name='Nguồn đồng hồ',index=0
---------------------------
Điều khiển này cho phép chuyển đổi đồng hồ từ giữa các
44,1 hoặc 48 kHz hoặc một số nguồn bên ngoài.

Lưu ý: nguồn của card 1616 CardBus không rõ ràng. Hãy báo cáo của bạn
những phát hiện.

name='Đồng hồ dự phòng',index=0
-----------------------------
Điều khiển này xác định đồng hồ bên trong mà thẻ sẽ chuyển sang khi
nguồn đồng hồ bên ngoài đã chọn là/trở nên không hợp lệ.

name='DAC1 0202 14dB PAD',index=0, v.v.
---------------------------------------
Điều khiển suy giảm đầu ra. Không có sẵn trên thẻ 0404.

name='ADC1 14dB PAD 0202',index=0, v.v.
---------------------------------------
Điều khiển suy giảm đầu vào. Không có sẵn trên thẻ 0404.

name='Chế độ đầu ra quang',index=0
----------------------------------
Chuyển đổi cổng đầu ra TOSLINK giữa S/PDIF và ADAT.
Không có trên thẻ 0404 (cố định ở S/PDIF).

name='Chế độ đầu vào quang',index=0
---------------------------------
Chuyển đổi cổng đầu vào TOSLINK giữa S/PDIF và ADAT.
Không có trên thẻ 0404 (cố định ở S/PDIF).

name='PCM Khối lượng phát lại phía trước',index=0
----------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus phía trước bên trái và bên phải
ắc quy. ALSA sử dụng ắc quy 8 và 9 cho mặt trước bên trái và bên phải PCM
mẫu để phát lại 5.1. Các mẫu kết quả được chuyển tiếp đến DSP 0 & 1
các kênh phát lại.

name='PCM Âm lượng phát lại âm thanh vòm',index=0
-------------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ xung quanh trái và phải PCM FX-bus
ắc quy. ALSA sử dụng bộ tích lũy 2 và 3 cho âm thanh vòm trái và phải PCM
mẫu để phát lại 5.1. Các mẫu kết quả được chuyển tiếp đến DSP 2 & 3
các kênh phát lại.

name='PCM Âm lượng phát lại bên',index=0
---------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ PCM FX-bus bên trái và bên phải
ắc quy. ALSA sử dụng ắc quy 14 và 15 cho bên trái và bên phải PCM
mẫu để phát lại 7.1. Các mẫu kết quả được chuyển tiếp đến DSP 6 & 7
các kênh phát lại.

name='PCM Âm lượng phát lại trung tâm',index=0
-----------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bộ tích lũy FX-bus PCM trung tâm.
ALSA sử dụng bộ tích lũy 6 cho các mẫu PCM trung tâm để phát lại 5.1. Các mẫu kết quả
được chuyển tiếp đến kênh phát lại DSP 4.

name='PCM LFE Khối lượng phát lại',index=0
--------------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bộ tích lũy FX-bus LFE PCM.
ALSA sử dụng bộ tích lũy 7 cho các mẫu LFE PCM để phát lại 5.1. Các mẫu kết quả
được chuyển tiếp đến kênh phát lại DSP 5.

name='PCM Khối lượng phát lại',index=0
----------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho các mẫu PCM trái và phải cho
phát lại âm thanh nổi. Các mẫu kết quả được chuyển tiếp đến bộ trộn âm thanh nổi ảo.

name='PCM Khối lượng chụp',index=0
---------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ bus FX PCM bên trái và bên phải
ắc quy. ALSA sử dụng bộ tích lũy 0 và 1 cho PCM trái và phải.
Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

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

name='Khối lượng phát lại phía trước',index=0
------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến các kênh phát lại DSP 0 & 1.

name='Âm lượng phát lại âm thanh vòm',index=0
---------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến các kênh phát lại DSP 2 & 3.

name='Khối lượng phát lại bên cạnh',index=0
-----------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến các kênh phát lại DSP 6 & 7.

name='Khối lượng phát lại ở giữa',index=0
-------------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến kênh phát lại DSP 4.

name='LFE Khối lượng phát lại',index=0
----------------------------------
Điều khiển này được sử dụng để làm giảm các mẫu từ bộ trộn âm thanh nổi ảo.
Các mẫu kết quả được chuyển tiếp đến kênh phát lại DSP 5.

name='Điều khiển giai điệu - Chuyển đổi',index=0
------------------------------------
Điều khiển này bật hoặc tắt điều khiển âm thanh. Các mẫu được chuyển đến
các kênh phát lại DSP bị ảnh hưởng.

name='Điều khiển giai điệu - Âm trầm',index=0
----------------------------------
Điều khiển này đặt cường độ âm trầm. Không có giá trị trung lập!!
Khi mã điều khiển âm thanh được kích hoạt, các mẫu luôn được sửa đổi.
Giá trị gần nhất với tín hiệu thuần là 20.

name='Điều khiển giai điệu - Treble',index=0
------------------------------------
Điều khiển này đặt cường độ âm bổng. Không có giá trị trung lập!!
Khi mã điều khiển âm thanh được kích hoạt, các mẫu luôn được sửa đổi.
Giá trị gần nhất với tín hiệu thuần là 20.

name='Khối lượng phát lại chính',index=0
-------------------------------------
Điều khiển này được sử dụng để giảm âm lượng mẫu cho tất cả các kênh phát lại DSP.

name='EMU Khối lượng chụp',index=0
----------------------------------
Điều khiển này được sử dụng để làm suy giảm các mẫu từ các kênh chụp DSP 0 & 1.
Kết quả được chuyển tiếp đến thiết bị PCM chụp tiêu chuẩn.

name='DAC Left',index=0, v.v.
-----------------------------
Chọn nguồn cho đầu ra âm thanh vật lý nhất định. Đây có thể là vật chất
đầu vào, kênh phát lại (DSP xx, được chỉ định dưới dạng số thập phân) hoặc im lặng.

name='DSP x',index=0
--------------------
Chọn nguồn cho kênh chụp nhất định (được chỉ định dưới dạng thập lục phân
chữ số). Các tùy chọn tương tự như đối với đầu ra âm thanh vật lý.


Điều khiển liên quan đến luồng PCM
===========================

Các điều khiển này được mô tả trong audigy-mixer.rst.


MANUALS/PATENTS
===============

Xem sb-live-mixer.rst.
