.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/dvb_intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Sử dụng Khung TV Kỹ thuật số
==============================

Giới thiệu
~~~~~~~~~~~~

Một điểm khác biệt đáng kể giữa TV Kỹ thuật số và TV Analog là
bất cẩn (như tôi) nên cân nhắc là, mặc dù thành phần
cấu trúc của thẻ DVB-T về cơ bản giống với thẻ TV Analog,
chúng hoạt động theo những cách khác nhau đáng kể.

Mục đích của TV Analog là nhận và hiển thị tín hiệu Analog
Tín hiệu truyền hình. Tín hiệu TV Analog (còn được gọi là tín hiệu tổng hợp
video) là mã hóa tương tự của một chuỗi các khung hình ảnh (25 khung hình
mỗi giây ở Châu Âu) được rasterized bằng kỹ thuật xen kẽ.
Việc xen kẽ có hai trường để thể hiện một khung. Vì vậy, một
Card TV Analog cho PC có mục đích sau:

* Điều chỉnh máy thu để nhận tín hiệu phát sóng
* giải điều chế tín hiệu phát sóng
* tách kênh tín hiệu video analog và âm thanh analog
  tín hiệu.

  .. note::

     some countries employ a digital audio signal
     embedded within the modulated composite analogue signal -
     using NICAM signaling.)

* số hóa tín hiệu video tương tự và tạo luồng dữ liệu kết quả
  có sẵn trên bus dữ liệu.

Luồng dữ liệu kỹ thuật số từ thẻ TV Analog được tạo bởi
mạch điện trên thẻ và thường ở dạng không nén. Đối với TV PAL
tín hiệu được mã hóa ở độ phân giải 768x576 pixel màu 24 bit trên 25
khung hình trên giây - một lượng dữ liệu hợp lý được tạo ra và phải được
được PC xử lý trước khi hiển thị trên màn hình video
màn hình. Một số card TV Analog dành cho PC có bộ mã hóa MPEG2 trên bo mạch.
cho phép luồng dữ liệu số thô được trình bày tới PC theo cách
dạng được mã hóa và nén - tương tự như dạng được sử dụng trong
Truyền hình kỹ thuật số.

Mục đích của thẻ TV kỹ thuật số giá rẻ đơn giản (DVB-T,C hoặc S) là để
đơn giản là:

* Điều chỉnh nhận được để nhận tín hiệu phát sóng. * Trích xuất được mã hóa
  luồng dữ liệu số từ tín hiệu phát sóng.
* Cung cấp luồng dữ liệu kỹ thuật số được mã hóa (MPEG2) cho bus dữ liệu.

Sự khác biệt đáng kể giữa hai loại này là bộ điều chỉnh trên
Card TV analog phát ra tín hiệu Analog, trong khi bộ dò sóng trên
Card TV kỹ thuật số tạo ra luồng dữ liệu kỹ thuật số được mã hóa nén. Như
tín hiệu đã được số hóa, việc truyền luồng dữ liệu này là chuyện nhỏ
vào cơ sở dữ liệu PC với quá trình xử lý bổ sung tối thiểu và sau đó trích xuất
các luồng dữ liệu âm thanh và video kỹ thuật số chuyển chúng đến thiết bị thích hợp
phần mềm hoặc phần cứng để giải mã và xem.

Bắt thẻ đi
~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển thiết bị API cho DVB trong Linux sẽ như sau
các nút thiết bị thông qua hệ thống tập tin devfs:

* /dev/dvb/adapter0/demux0
* /dev/dvb/adapter0/dvr0
* /dev/dvb/adapter0/frontend0

Nút thiết bị ZZ0000ZZ được sử dụng để đọc MPEG2
Luồng dữ liệu và nút thiết bị ZZ0001ZZ được sử dụng
để điều chỉnh mô-đun điều chỉnh giao diện người dùng. ZZ0002ZZ là
được sử dụng để kiểm soát những chương trình sẽ được nhận.

Tùy thuộc vào bộ tính năng của thẻ, Trình điều khiển thiết bị API cũng có thể
hiển thị các nút thiết bị khác:

* /dev/dvb/adapter0/ca0
* /dev/dvb/adapter0/audio0
* /dev/dvb/adapter0/net0
* /dev/dvb/adapter0/osd0
* /dev/dvb/adapter0/video0

ZZ0000ZZ được sử dụng để giải mã các kênh được mã hóa. các
các nút thiết bị khác chỉ được tìm thấy trên các thiết bị sử dụng av7110
trình điều khiển hiện đã lỗi thời cùng với API bổ sung có trình điều khiển như vậy
thiết bị sử dụng.

Nhận kênh truyền hình kỹ thuật số
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phần này cố gắng giải thích cách nó hoạt động và điều này ảnh hưởng như thế nào đến
cấu hình của card TV kỹ thuật số.

Trong ví dụ này, chúng tôi đang xem xét điều chỉnh các kênh DVB-T trong
Úc, tại khu vực Melbourne.

Tần số được phát bởi các máy phát Mount Dandenong là,
hiện tại:

Bảng 1. Tần số phát đáp Mount Dandenong, Vic, Aus.

=======================
Tần số phát sóng
=======================
Bảy 177.500 Mhz
SBS 184.500 MHz
Chín 191.625 Mhz
Mười 219.500 Mhz
ABC 226.500 MHz
Kênh 31 557,625 Mhz
=======================

Các tiện ích Quét TV kỹ thuật số (như dvbv5-scan) sử dụng một bộ
mặc định được biên soạn cho các quốc gia và khu vực khác nhau. Đó là những
hiện được cung cấp dưới dạng một gói riêng biệt, được gọi là bảng quét dtv. Đó là
cây git được đặt tại LinuxTV.org:

ZZ0000ZZ

Nếu không có bảng nào phù hợp, bạn có thể chỉ định tệp dữ liệu trên
dòng lệnh chứa tần số bộ phát đáp. Đây là một
tệp mẫu cho bộ tiếp sóng kênh ở trên, trong "kênh" cũ
định dạng::

Tệp # Data cho chương trình quét DVB
	#
	# C Tỷ lệ ký hiệu tần số FEC QAM
	# S Biểu tượng phân cực tần sốTỷ lệ FEC
	# T Băng thông tần số FEC FEC2 QAM Trình bảo vệ chế độ

T 177500000 7 MHz AUTO AUTO QAM64 8k 1/16 NONE
	T 184500000 7 MHz AUTO AUTO QAM64 8k 1/8 NONE
	T 191625000 7 MHz AUTO AUTO QAM64 8k 1/16 NONE
	T 219500000 7 MHz AUTO AUTO QAM64 8k 1/16 NONE
	T 226500000 7 MHz AUTO AUTO QAM64 8k 1/16 NONE
	T 557625000 7 MHz AUTO AUTO QPSK 8k 1/16 NONE

Ngày nay, chúng tôi thích sử dụng một định dạng mới hơn, dài dòng hơn và dễ dàng hơn.
để hiểu. Với định dạng mới, bộ phát đáp kênh "Seven"
dữ liệu được đại diện bởi::

[Bảy]
		DELIVERY_SYSTEM = DVBT
		FREQUENCY = 177500000
		BANDWIDTH_HZ = 7000000
		CODE_RATE_HP = AUTO
		CODE_RATE_LP = AUTO
		MODULATION = QAM/64
		TRANSMISSION_MODE = 8K
		GUARD_INTERVAL = 1/16
		HIERARCHY = NONE
		INVERSION = AUTO

Để có phiên bản cập nhật của bảng hoàn chỉnh, vui lòng xem:

ZZ0000ZZ

Khi tiện ích quét Digital TV chạy sẽ xuất ra file
chứa thông tin về tất cả các chương trình âm thanh và video
tồn tại trong bộ tiếp sóng của mỗi kênh mà giao diện người dùng của thẻ có thể
khóa vào. (tức là bất kỳ tín hiệu nào ở ăng-ten của bạn đủ mạnh).

Đây là kết quả của các công cụ dvbv5 từ quá trình quét kênh được lấy từ
Melburne::

[ABC HDTV]
	    SERVICE_ID = 560
	    VIDEO_PID = 2307
	    AUDIO_PID = 0
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 226500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 3/4
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[ABC TV Melbourne]
	    SERVICE_ID = 561
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 226500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 3/4
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[ABC Tivi 2]
	    SERVICE_ID = 562
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 226500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 3/4
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[ABC Tivi 3]
	    SERVICE_ID = 563
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 226500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 3/4
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[ABC Tivi 4]
	    SERVICE_ID = 564
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 226500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 3/4
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[Đài phát thanh DiG ABC]
	    SERVICE_ID = 566
	    VIDEO_PID = 0
	    AUDIO_PID = 2311
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 226500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 3/4
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số]
	    SERVICE_ID = 1585
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số 1]
	    SERVICE_ID = 1586
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số 2]
	    SERVICE_ID = 1587
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số 3]
	    SERVICE_ID = 1588
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số]
	    SERVICE_ID = 1589
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số 4]
	    SERVICE_ID = 1590
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số]
	    SERVICE_ID = 1591
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN HD]
	    SERVICE_ID = 1592
	    VIDEO_PID = 514
	    AUDIO_PID = 0
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[TEN kỹ thuật số]
	    SERVICE_ID = 1593
	    VIDEO_PID = 512
	    AUDIO_PID = 650
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 219500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[Chín kỹ thuật số]
	    SERVICE_ID = 1072
	    VIDEO_PID = 513
	    AUDIO_PID = 660
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 191625000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[Chín kỹ thuật số HD]
	    SERVICE_ID = 1073
	    VIDEO_PID = 512
	    AUDIO_PID = 0
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 191625000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[Chín hướng dẫn]
	    SERVICE_ID = 1074
	    VIDEO_PID = 514
	    AUDIO_PID = 670
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 191625000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 3/4
	    CODE_RATE_LP = 1/2
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/16
	    HIERARCHY = NONE

[7 Kỹ thuật số]
	    SERVICE_ID = 1328
	    VIDEO_PID = 769
	    AUDIO_PID = 770
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 177500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[7 Kỹ thuật số 1]
	    SERVICE_ID = 1329
	    VIDEO_PID = 769
	    AUDIO_PID = 770
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 177500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[7 Kỹ thuật số 2]
	    SERVICE_ID = 1330
	    VIDEO_PID = 769
	    AUDIO_PID = 770
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 177500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[7 Kỹ thuật số 3]
	    SERVICE_ID = 1331
	    VIDEO_PID = 769
	    AUDIO_PID = 770
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 177500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[7 HD kỹ thuật số]
	    SERVICE_ID = 1332
	    VIDEO_PID = 833
	    AUDIO_PID = 834
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 177500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[7 Hướng dẫn chương trình]
	    SERVICE_ID = 1334
	    VIDEO_PID = 865
	    AUDIO_PID = 866
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 177500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[SBS HD]
	    SERVICE_ID = 784
	    VIDEO_PID = 102
	    AUDIO_PID = 103
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 536500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[SBS DIGITAL 1]
	    SERVICE_ID = 785
	    VIDEO_PID = 161
	    AUDIO_PID = 81
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 536500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[SBS DIGITAL 2]
	    SERVICE_ID = 786
	    VIDEO_PID = 162
	    AUDIO_PID = 83
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 536500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[SBS EPG]
	    SERVICE_ID = 787
	    VIDEO_PID = 163
	    AUDIO_PID = 85
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 536500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[SBS RADIO 1]
	    SERVICE_ID = 798
	    VIDEO_PID = 0
	    AUDIO_PID = 201
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 536500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE

[SBS RADIO 2]
	    SERVICE_ID = 799
	    VIDEO_PID = 0
	    AUDIO_PID = 202
	    DELIVERY_SYSTEM = DVBT
	    FREQUENCY = 536500000
	    INVERSION = OFF
	    BANDWIDTH_HZ = 7000000
	    CODE_RATE_HP = 2/3
	    CODE_RATE_LP = 2/3
	    MODULATION = QAM/64
	    TRANSMISSION_MODE = 8K
	    GUARD_INTERVAL = 1/8
	    HIERARCHY = NONE