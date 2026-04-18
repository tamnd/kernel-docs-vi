.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/emu10k1-jack.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================================================================
Âm thanh đa kênh, độ trễ thấp với JACK và emu10k1/emu10k2
=================================================================

Tài liệu này là hướng dẫn sử dụng các thiết bị dựa trên emu10k1 với JACK ở mức thấp
độ trễ, chức năng ghi đa kênh.  Tất cả công việc gần đây của tôi để cho phép
Người dùng Linux có thể sử dụng toàn bộ khả năng của phần cứng của họ đã được truyền cảm hứng 
bởi Dự án kX.  Nếu không có công việc của họ, tôi sẽ không bao giờ khám phá ra sự thật
sức mạnh của phần cứng này.

ZZ0000ZZ
						- Lee Revell, 2005.03.30


Cho đến gần đây, người dùng emu10k1 trên Linux không có quyền truy cập vào mức thấp tương tự
độ trễ, các tính năng đa kênh được cung cấp bởi tính năng "kX ASIO" của
Trình điều khiển Windows.  Kể từ ALSA 1.0.9, tính năng này không còn nữa!

Đối với những người không quen thuộc với kX ASIO, nó bao gồm 16 lần chụp và 16 lần phát lại
các kênh.  Với nhân Linux phiên bản 2.6.9, độ trễ giảm xuống còn 64 (1,33 ms) hoặc
thậm chí khung hình 32 (0,66 mili giây) cũng hoạt động tốt.

Cấu hình phức tạp hơn một chút so với trên Windows, vì bạn phải
chọn đúng thiết bị cho JACK để sử dụng.  Trên thực tế, đối với người dùng qjackctl thì đó là
khá dễ hiểu - chọn Duplex, sau đó chọn chụp và phát lại
các thiết bị đa kênh, đặt các kênh vào và ra thành 16 và mẫu
tốc độ lên tới 48000Hz.  Dòng lệnh trông như thế này:
::

/usr/local/bin/jackd -R -dalsa -r48000 -p64 -n2 -D -Chw:0,2 -Phw:0,3 -S

Điều này sẽ cung cấp cho bạn 16 cổng đầu vào và 16 cổng đầu ra.

16 cổng đầu ra ánh xạ lên 16 bus FX (hoặc 16 cổng đầu tiên trong số 64 cổng, dành cho
Thính giác).  Việc ánh xạ từ bus FX tới đầu ra vật lý được mô tả trong
sb-live-mixer.rst (hoặc audigy-mixer.rst).

16 cổng đầu vào được kết nối với 16 đầu vào vật lý.  Trái ngược với
niềm tin phổ biến, tất cả các thẻ emu10k1 đều là thẻ đa kênh.  Cái nào trong số này
các kênh đầu vào có đầu vào vật lý được kết nối với chúng tùy thuộc vào thẻ
mô hình.  Việc thử và sai rất được khuyến khích; sơ đồ chân
cho thẻ đã được thiết kế ngược bởi một số người dùng kX táo bạo và 
có sẵn trên internet.  Ở đây Meterbridge rất hữu ích và diễn đàn kX cũng rất hữu ích.
đóng gói với thông tin hữu ích.

Mỗi cổng đầu vào sẽ tương ứng với đầu vào kỹ thuật số (SPDIF), đầu vào analog
đầu vào, hoặc không có gì.  Một ngoại lệ là SBLive! 5.1.  Trên các thiết bị này,
cổng đầu vào thứ hai và thứ ba được nối với đầu ra trung tâm/LFE.  Bạn sẽ
vẫn thấy 16 kênh chụp nhưng chỉ có 14 kênh để ghi đầu vào.

Biểu đồ này, mượn từ kxfxlib/da_asio51.cpp, mô tả ánh xạ của JACK
chuyển sang FXBUS2 (đầu vào ghi nhiều rãnh) và EXTOUT (đầu ra vật lý)
các kênh.

Ánh xạ JACK (& ASIO) trên thẻ 10k1 5.1 SBLive:

====================== =============
JACK Phần kết FXBUS2(nr)
====================== =============
capture_1 asio14 FXBUS2(0xe)
capture_2 asio15 FXBUS2(0xf)
capture_3 asio0 FXBUS2(0x0)	
~capture_4 Trung tâm EXTOUT(0x11) // được ánh xạ tới bởi Trung tâm
~capture_5 LFE EXTOUT(0x12) // được ánh xạ tới bởi LFE
capture_6 asio3 FXBUS2(0x3)
capture_7 asio4 FXBUS2(0x4)
capture_8 asio5 FXBUS2(0x5)
capture_9 asio6 FXBUS2(0x6)
capture_10 asio7 FXBUS2(0x7)
capture_11 asio8 FXBUS2(0x8)
capture_12 asio9 FXBUS2(0x9)
capture_13 asio10 FXBUS2(0xa)
capture_14 asio11 FXBUS2(0xb)
capture_15 asio12 FXBUS2(0xc)
capture_16 asio13 FXBUS2(0xd)
====================== =============

TODO: mô tả việc sử dụng ld10k1/qlo10k1 kết hợp với JACK
