.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/vidtv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
vidtv: Trình điều khiển TV kỹ thuật số ảo
================================

Tác giả: Daniel W. S. Almeida <dwlsalmeida@gmail.com>, tháng 6 năm 2020.

Lý lịch
----------

Vidtv là trình điều khiển DVB ảo nhằm mục đích làm tài liệu tham khảo cho trình điều khiển
người viết bằng cách phục vụ như một khuôn mẫu. Nó cũng xác nhận phương tiện truyền thông hiện có DVB
API, do đó giúp người viết ứng dụng không gian người dùng.

Hiện tại, nó bao gồm:

- Trình điều khiển bộ chỉnh giả, sẽ báo chất lượng tín hiệu kém nếu được chọn
  tần số quá xa so với bảng tần số hợp lệ đối với một
  hệ thống phân phối cụ thể.

- Trình điều khiển demo giả, sẽ liên tục thăm dò chất lượng tín hiệu giả
  được bộ điều chỉnh trả về, mô phỏng một thiết bị có thể mất/lấy lại khóa
  trên tín hiệu tùy thuộc vào mức CNR.

- Trình điều khiển cầu giả, là mô-đun chịu trách nhiệm sửa đổi
  các mô-đun điều chỉnh và demo giả mạo cũng như triển khai logic demux. mô-đun này
  lấy các tham số khi khởi tạo sẽ chỉ ra cách mô phỏng
  cư xử.

- Mã chịu trách nhiệm mã hóa Luồng truyền tải MPEG hợp lệ, sau đó
  chuyển cho người lái cầu. Luồng giả mạo này chứa một số nội dung được mã hóa cứng.
  Hiện tại, chúng tôi có một kênh duy nhất, chỉ có âm thanh chứa một MPEG
  Luồng cơ bản, lần lượt chứa sóng hình sin được mã hóa SMPTE 302m.
  Lưu ý rằng bộ mã hóa cụ thể này đã được chọn vì nó dễ dàng nhất
  cách mã hóa dữ liệu âm thanh PCM trong Luồng truyền tải MPEG.

xây dựng vidtv
--------------
vidtv là trình điều khiển thử nghiệm và do đó ZZ0000ZZ được bật theo mặc định khi
biên dịch hạt nhân.

Để cho phép biên soạn vidtv:

- Kích hoạt ZZ0000ZZ, sau đó
- Kích hoạt ZZ0001ZZ

Khi được biên dịch dưới dạng mô-đun, hãy mong đợi các tệp .ko sau:

- dvb_vidtv_tuner.ko

- dvb_vidtv_demod.ko

- dvb_vidtv_bridge.ko

Chạy vidtv
-------------
Khi được biên dịch dưới dạng mô-đun, hãy chạy::

modprobe vidtv

Thế thôi! Trình điều khiển bridge sẽ khởi tạo trình điều khiển bộ chỉnh và trình điều khiển demo như
một phần của quá trình khởi tạo của chính nó.

Theo mặc định, nó sẽ chấp nhận các tần số sau:

- 474 MHz cho DVB-T/T2/C;
	- 11.362 GHz cho DVB-S/S2.

Đối với hệ thống vệ tinh, trình điều khiển mô phỏng một phạm vi mở rộng phổ quát
LNBf, với tần số ở băng tần Ku, nằm trong khoảng từ 10,7 GHz đến 12,75 GHz.

Bạn có thể tùy ý xác định một số đối số dòng lệnh cho vidtv.

Đối số dòng lệnh cho vidtv
-------------------------------
Dưới đây là danh sách tất cả các đối số có thể được cung cấp cho vidtv:

drop_tslock_prob_on_low_snr
	Khả năng mất khóa TS nếu chất lượng tín hiệu kém.
	Xác suất này được sử dụng bởi trình điều khiển giải điều chế giả để
	cuối cùng trả về trạng thái 0 khi chất lượng tín hiệu không tốt
	tốt.

recovery_tslock_prob_on_good_snr:
	Xác suất khôi phục khóa TS khi tín hiệu được cải thiện. Cái này
	xác suất được sử dụng bởi trình điều khiển giải điều chế giả để cuối cùng
	trả về trạng thái 0x1f khi/nếu chất lượng tín hiệu được cải thiện.

mock_power_up_delay_msec
	Mô phỏng độ trễ bật nguồn.  Mặc định: 0.

mock_tune_delay_msec
	Mô phỏng độ trễ giai điệu.  Mặc định 0.

vidtv_valid_dvb_t_freqs
	Tần số DVB-T hợp lệ để mô phỏng, tính bằng Hz.

vidtv_valid_dvb_c_freqs
	Tần số DVB-C hợp lệ để mô phỏng, tính bằng Hz.

vidtv_valid_dvb_s_freqs
	Tần số DVB-S/S2 hợp lệ để mô phỏng ở Băng tần Ku, tính bằng kHz.

tần số tối đa_shift_hz,
	Sự thay đổi tối đa trong HZ được phép khi điều chỉnh trong một kênh.

si_thời_msec
	Tần suất gửi gói SI.  Mặc định: 40ms.

pcr_thời_msec
	Tần suất gửi các gói PCR.  Mặc định: 40ms.

mux_rate_kbytes_sec
	Cố gắng duy trì tốc độ bit này bằng cách chèn các gói TS null, nếu
	cần thiết.  Mặc định: 4096.

pcr_pid,
	PCR PID cho tất cả các kênh.  Mặc định: 0x200.

mux_buf_sz_pkts,
	Kích thước cho bộ đệm mux theo bội số của 188 byte.

cấu trúc bên trong vidtv
------------------------
Các mô-đun hạt nhân được phân chia theo cách sau:

vidtv_tuner.[ch]
	Triển khai trình điều khiển DVB bộ chỉnh giả.

vidtv_demod.[ch]
	Triển khai trình điều khiển DVB giải mã giả.

vidtv_bridge.[ch]
	Triển khai trình điều khiển cầu.

Mã liên quan đến MPEG được chia theo cách sau:

vidtv_ts.[ch]
	Mã để hoạt động với các gói TS MPEG, chẳng hạn như tiêu đề TS, thích ứng
	trường, gói PCR và gói NULL.

vidtv_psi.[ch]
	Đây là máy phát điện PSI.  Gói PSI chứa thông tin chung
	về Luồng truyền tải MPEG.  Cần có một máy phát điện PSI
	ứng dụng không gian người dùng có thể truy xuất thông tin về Luồng truyền tải
	và cuối cùng chuyển sang một kênh (giả).

Bởi vì trình tạo được triển khai trong một tệp riêng biệt nên nó có thể
	được sử dụng lại ở nơi khác trong hệ thống con phương tiện.

Hiện tại vidtv hỗ trợ làm việc với 5 bảng PSI: PAT, PMT,
	SDT, NIT và EIT.

Thông số kỹ thuật cho PAT và PMT có thể được tìm thấy trong *ISO 13818-1:
	Hệ thống*, while the specification for the SDT, NIT, EIT can be found in *ETSI
	EN 300 468: Đặc điểm kỹ thuật về thông tin dịch vụ (SI) trong DVB
	hệ thống*.

Việc này không thực sự cần thiết nhưng việc sử dụng tệp TS thực sẽ giúp ích khi
	gỡ lỗi bảng PSI. Vidtv hiện đang cố gắng sao chép PSI
	cấu trúc được tìm thấy trong tệp này: ZZ0000ZZ.

Một cách tốt để hình dung cấu trúc của luồng là sử dụng
	ZZ0000ZZ.

vidtv_pes.[ch]
	Triển khai logic PES để chuyển đổi dữ liệu bộ mã hóa thành MPEG TS
	gói. Sau đó chúng có thể được đưa vào bộ ghép kênh TS và cuối cùng
	vào không gian người dùng.

vidtv_encoding.h
	Một giao diện cho bộ mã hóa vidtv. Bộ mã hóa mới có thể được thêm vào này
	driver bằng cách thực hiện các lệnh gọi trong tệp này.

vidtv_s302m.[ch]
	Triển khai bộ mã hóa S302M để có thể chèn âm thanh PCM
	dữ liệu trong Luồng truyền tải MPEG được tạo. Có liên quan
	thông số kỹ thuật có sẵn trực tuyến dưới dạng *SMPTE 302M-2007: Tivi -
	Ánh xạ dữ liệu AES3 vào Luồng truyền tải MPEG-2*.


Luồng cơ bản MPEG kết quả được truyền theo cách riêng tư
	phát trực tuyến có đính kèm bộ mô tả đăng ký S302M.

Điều này sẽ cho phép truyền tín hiệu âm thanh vào không gian người dùng để nó có thể
	được giải mã và phát bằng phần mềm đa phương tiện. Bộ giải mã tương ứng
	trong ffmpeg nằm ở 'libavcodec/s302m.c' và đang thử nghiệm.

vidtv_channel.[ch]
	Thực hiện trừu tượng hóa 'kênh'.

Khi vidtv khởi động, nó sẽ tạo ra một số kênh được mã hóa cứng:

#. Các dịch vụ của họ sẽ được kết nối để đưa vào SDT.

#. Các chương trình của họ sẽ được ghép nối để đưa vào PAT

#. Các sự kiện của họ sẽ được nối với nhau để đưa vào EIT

#. Đối với mỗi chương trình trong PAT, phần PMT sẽ được tạo

#. Phần PMT cho một kênh sẽ được chỉ định các luồng của kênh đó.

#. Mỗi luồng sẽ có bộ mã hóa tương ứng được thăm dò trong một
	   vòng lặp để tạo ra các gói TS.
	   Các gói này có thể được xen kẽ bởi muxer và sau đó được phân phối
	   đến cây cầu.

vidtv_mux.[ch]
	Triển khai mux MPEG TS, dựa trên ffmpeg một cách lỏng lẻo
	triển khai trong "libavcodec/mpegtsenc.c"

Muxer chạy một vòng lặp chịu trách nhiệm:

#. Theo dõi lượng thời gian đã trôi qua kể từ lần cuối cùng
	   sự lặp lại.

#. Bộ mã hóa thăm dò để tìm nạp dữ liệu có giá trị 'elapsed_time'.

#. Chèn các gói PSI và/hoặc PCR, nếu cần.

#. Đệm luồng kết quả bằng các gói NULL nếu
	   cần thiết để duy trì tốc độ bit đã chọn.

#. Cung cấp các gói TS kết quả tới bridge
	   driver để nó có thể chuyển chúng tới demux.

Kiểm tra vidtv với v4l-utils
----------------------------

Sử dụng các công cụ trong v4l-utils là một cách tuyệt vời để kiểm tra và kiểm tra đầu ra của
vidtv. Nó được lưu trữ ở đây: ZZ0000ZZ.

Từ trang web của nó::

v4l-utils là một loạt các gói để xử lý các thiết bị đa phương tiện.

Nó được lưu trữ tại ZZ0000ZZ và được đóng gói
	trên hầu hết các bản phân phối.

Nó cung cấp một loạt các thư viện và tiện ích được sử dụng để
	kiểm soát một số khía cạnh của các bảng truyền thông.


Bắt đầu bằng cách cài đặt v4l-utils và sau đó sửa đổi vidtv ::

modprobe dvb_vidtv_bridge

Nếu trình điều khiển ổn, nó sẽ tải và mã thăm dò của nó sẽ chạy. Điều này sẽ
kéo bộ chỉnh và trình điều khiển demo.

Sử dụng dvb-fe-tool
~~~~~~~~~~~~~~~~~

Bước đầu tiên để kiểm tra xem bản demo đã được tải thành công hay chưa là chạy::

$ dvb-fe-công cụ
	Bản demo giả của thiết bị cho các khả năng DVB-T/T2/C/S/S2 (/dev/dvb/adapter0/frontend0):
	    CAN_FEC_1_2
	    CAN_FEC_2_3
	    CAN_FEC_3_4
	    CAN_FEC_4_5
	    CAN_FEC_5_6
	    CAN_FEC_6_7
	    CAN_FEC_7_8
	    CAN_FEC_8_9
	    CAN_FEC_AUTO
	    CAN_GUARD_INTERVAL_AUTO
	    CAN_HIERARCHY_AUTO
	    CAN_INVERSION_AUTO
	    CAN_QAM_16
	    CAN_QAM_32
	    CAN_QAM_64
	    CAN_QAM_128
	    CAN_QAM_256
	    CAN_QAM_AUTO
	    CAN_QPSK
	    CAN_TRANSMISSION_MODE_AUTO
	DVB API Phiên bản 5.11, Hệ thống phân phối v5 hiện tại: DVBC/ANNEX_A
	Hệ thống phân phối được hỗ trợ:
	    DVBT
	    DVBT2
	    [DVBC/ANNEX_A]
	    DVBS
	    DVBS2
	Dải tần số cho tiêu chuẩn hiện tại:
	Từ: 51,0 MHz
	Đến: 2,15 GHz
	Bước: 62,5 kHz
	Dung sai: 29,5 MHz
	Phạm vi tốc độ ký hiệu cho tiêu chuẩn hiện tại:
	Từ: 1,00 MBaud
	Tới: 45,0 MBaud

Điều này sẽ trả về những gì hiện được thiết lập tại cấu trúc demod, tức là::

cấu trúc const tĩnh dvb_frontend_ops vidtv_demod_ops = {
		.delsys = {
			SYS_DVBT,
			SYS_DVBT2,
			SYS_DVBC_ANNEX_A,
			SYS_DVBS,
			SYS_DVBS2,
		},

.thông tin = {
			.name = "Bản demo giả cho DVB-T/T2/C/S/S2",
			.tần số_min_hz = 51 * MHz,
			.tần số_max_hz = 2150 * MHz,
			.tần số_stepsize_hz = 62500,
			.tần số_tolerance_hz = 29500 * kHz,
			.symbol_rate_min = 1000000,
			.symbol_rate_max = 45000000,

.caps = FE_CAN_FEC_1_2 |
				FE_CAN_FEC_2_3 |
				FE_CAN_FEC_3_4 |
				FE_CAN_FEC_4_5 |
				FE_CAN_FEC_5_6 |
				FE_CAN_FEC_6_7 |
				FE_CAN_FEC_7_8 |
				FE_CAN_FEC_8_9 |
				FE_CAN_QAM_16 |
				FE_CAN_QAM_64 |
				FE_CAN_QAM_32 |
				FE_CAN_QAM_128 |
				FE_CAN_QAM_256 |
				FE_CAN_QAM_AUTO |
				FE_CAN_QPSK |
				FE_CAN_FEC_AUTO |
				FE_CAN_INVERSION_AUTO |
				FE_CAN_TRANSMISSION_MODE_AUTO |
				FE_CAN_GUARD_INTERVAL_AUTO |
				FE_CAN_HIERARCHY_AUTO,
		}

		....

Để biết thêm thông tin về dvb-fe-tools, hãy kiểm tra tài liệu trực tuyến của nó tại đây:
ZZ0000ZZ.

Sử dụng dvb-scan
~~~~~~~~~~~~~~

Để dò kênh và đọc bảng PSI, chúng ta có thể sử dụng dvb-scan.

Đối với điều này, người ta phải cung cấp một tệp cấu hình được gọi là 'tệp quét',
đây là một ví dụ::

[Kênh]
	FREQUENCY = 474000000
	MODULATION = QAM/AUTO
	SYMBOL_RATE = 6940000
	INNER_FEC = AUTO
	DELIVERY_SYSTEM = DVBC/ANNEX_A

.. note::
	The parameters depend on the video standard you're testing.

.. note::
	Vidtv is a fake driver and does not validate much of the information
	in the scan file. Just specifying 'FREQUENCY' and 'DELIVERY_SYSTEM'
	should be enough for DVB-T/DVB-T2. For DVB-S/DVB-C however, you
	should also provide 'SYMBOL_RATE'.

Bạn có thể duyệt bảng quét trực tuyến tại đây: ZZ0000ZZ.

Giả sử kênh này được đặt tên là 'channel.conf', thì bạn có thể chạy::

$ dvbv5-scan kênh.conf
	quét dvbv5 ~/vidtv.conf
	Không tìm thấy lệnh ERROR BANDWIDTH_HZ (5) trong quá trình truy xuất
	Không thể tính toán sự thay đổi tần số. Băng thông/tốc độ ký hiệu không có sẵn (chưa).
	Tần số quét #1 330000000
	    (0x00) Tín hiệu= -68,00dBm
	Tần số quét #2 474000000
	Khóa (0x1f) Tín hiệu= -34,45dBm C/N= 33,74dB UCB= 0
	Dịch vụ Beethoven, nhà cung cấp LinuxTV.org: truyền hình kỹ thuật số

Để biết thêm thông tin về dvb-scan, hãy kiểm tra tài liệu trực tuyến tại đây:
ZZ0000ZZ.

Sử dụng dvb-zap
~~~~~~~~~~~~~

dvbv5-zap là một công cụ dòng lệnh có thể được sử dụng để ghi MPEG-TS vào đĩa. các
cách sử dụng thông thường là dò kênh và đặt kênh đó vào chế độ ghi. Ví dụ
bên dưới - được lấy từ tài liệu - minh họa rằng\ [1]_::

$ dvbv5-zap -c dvb_channel.conf "beethoven" -o music.ts -P -t 10
	sử dụng demux 'dvb0.demux0'
	đọc các kênh từ tập tin 'dvb_channel.conf'
	điều chỉnh đến 474000000 Hz
	chuyển tất cả PID cho TS
	dvb_set_pesfilter 8192
	dvb_dev_set_bufsize: bộ đệm được đặt thành 6160384
	Khóa (0x1f) Chất lượng= Tín hiệu tốt= -34,66dBm C/N= 33,41dB UCB= 0 postBER= 0 preBER= 1.05x10^-3 PER= 0
	Khóa (0x1f) Chất lượng= Tín hiệu tốt= -34,57dBm C/N= 33,46dB UCB= 0 postBER= 0 preBER= 1.05x10^-3 PER= 0
	Đã bắt đầu ghi vào tập tin 'music.ts'
	đã nhận được 24587768 byte (2401 Kbyte/giây)
	Khóa (0x1f) Chất lượng= Tín hiệu tốt= -34,42dBm C/N= 33,89dB UCB= 0 postBER= 0 preBER= 2,44x10^-3 PER= 0

.. [1] In this example, it records 10 seconds with all program ID's stored
       at the music.ts file.


Có thể xem kênh bằng cách phát nội dung của luồng với một số
trình phát nhận dạng định dạng MPEG-TS, chẳng hạn như ZZ0000ZZ hoặc ZZ0001ZZ.

Bằng cách phát nội dung của luồng, người ta có thể kiểm tra trực quan hoạt động của
vidtv, ví dụ: để phát tệp TS đã ghi với::

$ mplayer nhạc.ts

hoặc, cách khác, chạy lệnh này trên một thiết bị đầu cuối ::

$ dvbv5-zap -c dvb_channel.conf "beethoven" -P -r &

Và, trên thiết bị đầu cuối thứ hai, phát nội dung từ giao diện DVR với ::

$ mplayer /dev/dvb/adapter0/dvr0

Để biết thêm thông tin về dvb-zap, hãy kiểm tra tài liệu trực tuyến của nó tại đây:
ZZ0000ZZ.
Xem thêm: ZZ0001ZZ.


Những gì vẫn có thể được cải thiện trong vidtv
-----------------------------------

Thêm tích hợp ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~

Mặc dù trình điều khiển giao diện người dùng cung cấp số liệu thống kê DVBv5 thông qua .read_status
cuộc gọi, một bổ sung thú vị sẽ là cung cấp số liệu thống kê bổ sung cho
không gian người dùng thông qua debugfs, đây là một hệ thống tệp dựa trên RAM dễ sử dụng
được thiết kế đặc biệt cho mục đích gỡ lỗi.

Logic cho việc này sẽ được triển khai trên một tệp riêng biệt để không
làm ô nhiễm trình điều khiển lối vào.  Những số liệu thống kê này dành riêng cho từng trình điều khiển và có thể
hữu ích trong quá trình kiểm tra.

Trình điều khiển Siano là một ví dụ về trình điều khiển sử dụng
debugfs để truyền tải số liệu thống kê dành riêng cho trình điều khiển tới không gian người dùng và nó có thể
được sử dụng làm tài liệu tham khảo.

Điều này cần được kích hoạt và vô hiệu hóa thêm thông qua Kconfig
tùy chọn để thuận tiện.

Thêm cách test video
~~~~~~~~~~~~~~~~~~~~~~~

Hiện tại, vidtv chỉ có thể mã hóa âm thanh PCM. Sẽ thật tuyệt nếu thực hiện
một phiên bản cơ bản của mã hóa video MPEG-2 để chúng tôi cũng có thể kiểm tra video. các
nơi đầu tiên cần xem xét là *ISO 13818-2: Công nghệ thông tin - Chung
Mã hóa hình ảnh chuyển động và thông tin âm thanh liên quan - Phần 2: Video*,
bao gồm mã hóa video nén trong Luồng truyền tải MPEG.

Điều này có thể tùy ý sử dụng Trình tạo mẫu thử nghiệm Video4Linux2, v4l2-tpg,
cư trú tại::

trình điều khiển/phương tiện/chung/v4l2-tpg/


Thêm mô phỏng tiếng ồn trắng
~~~~~~~~~~~~~~~~~~~~~~~~~~

Bộ điều chỉnh vidtv đã có mã để xác định xem tần số đã chọn có
quá xa so với bảng tần số hợp lệ. Hiện tại, điều này có nghĩa là
bộ giải điều chế cuối cùng có thể mất khóa tín hiệu, vì bộ điều chỉnh sẽ
báo cáo chất lượng tín hiệu xấu.

Một bổ sung thú vị là mô phỏng một số nhiễu khi chất lượng tín hiệu kém bằng cách:

- Đánh rơi ngẫu nhiên một số gói TS. Điều này sẽ gây ra lỗi liên tục nếu
  bộ đếm liên tục được cập nhật nhưng gói không được chuyển đến bộ giải mã.

- Cập nhật số liệu thống kê lỗi tương ứng (ví dụ BER, v.v.).

- Mô phỏng một số nhiễu trong dữ liệu được mã hóa.

Các hàm và cấu trúc được sử dụng trong vidtv
---------------------------------------

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_bridge.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_channel.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_demod.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_encoder.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_mux.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_pes.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_psi.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_s302m.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_ts.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_tuner.h

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_common.c

.. kernel-doc:: drivers/media/test-drivers/vidtv/vidtv_tuner.c