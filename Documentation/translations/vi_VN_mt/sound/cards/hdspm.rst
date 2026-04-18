.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/hdspm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Giao diện phần mềm Trình điều khiển ALSA-DSP MADI
=================================================

(dịch từ tiếng Đức nên tiếng Anh không tốt ;-),

2004 - Ritsch chiên giòn


Đầy đủ chức năng đã được thêm vào trình điều khiển. Vì một số
các tùy chọn Điều khiển và khởi động là ALSA-Standard và chỉ có
Kiểm soát đặc biệt được mô tả và thảo luận dưới đây.


Chức năng phần cứng
======================
   
Truyền âm thanh
------------------

* số lượng kênh - phụ thuộc vào chế độ truyền

Số lượng kênh được chọn là từ 1..Nmax. Lý do để
		việc sử dụng cho số lượng kênh thấp hơn chỉ nhằm mục đích phân bổ tài nguyên,
		vì các kênh DMA không được sử dụng sẽ bị tắt và ít bộ nhớ hơn
		được phân bổ. Vì vậy, thông lượng của hệ thống PCI có thể là
		thu nhỏ. (Chỉ quan trọng đối với bảng hiệu suất thấp).

* Tốc độ đơn - 1..64 kênh

.. note::
		 (Note: Choosing the 56channel mode for transmission or as
		 receiver, only 56 are transmitted/received over the MADI, but
		 all 64 channels are available for the mixer, so channel count
		 for the driver)

* Tốc độ gấp đôi - 1..32 kênh

.. note::
		 Note: Choosing the 56-channel mode for
		 transmission/receive-mode , only 28 are transmitted/received
		 over the MADI, but all 32 channels are available for the mixer,
		 so channel count for the driver


* Tốc độ bốn - 1..16 kênh

.. note::
		 Choosing the 56-channel mode for
		 transmission/receive-mode , only 14 are transmitted/received
		 over the MADI, but all 16 channels are available for the mixer,
		 so channel count for the driver

* Định dạng -- đã ký 32 Bit Little Endian (SNDRV_PCM_FMTBIT_S32_LE)

* Tỷ lệ mẫu --

Tốc độ đơn -- 32000, 44100, 48000

Tốc độ gấp đôi -- 64000, 88200, 96000 (chưa được kiểm tra)

Tốc độ bốn -- 128000, 176400, 192000 (chưa được kiểm tra)

* chế độ truy cập -- MMAP (ánh xạ bộ nhớ), Không xen kẽ (PCM_NON-INTERLEAVED)

* kích thước bộ đệm -- 64.128.256.512.1024.2048.8192 Mẫu

* mảnh vỡ -- 2

* Con trỏ phần cứng -- 2 Modi


Thẻ hỗ trợ việc đọc con trỏ đệm thực tế,
		 nơi DMA đọc/ghi. Do chế độ hàng loạt của PCI nên nó chỉ
		 64 Byte chính xác. VẬY nó không thực sự có thể sử dụng được cho
		 Các chức năng cấp trung ALSA (ở đây ID bộ đệm cung cấp thông tin tốt hơn
		 result), nhưng nếu MMAP được ứng dụng sử dụng. Vì thế nó
		 có thể được cấu hình tại thời điểm tải với tham số
		 con trỏ chính xác.


.. hint::
		 (Hint: Experimenting I found that the pointer is maximum 64 to
		 large never to small. So if you subtract 64 you always have a
		 safe pointer for writing, which is used on this mode inside
		 ALSA. In theory now you can get now a latency as low as 16
		 Samples, which is a quarter of the interrupt possibilities.)

   * Precise Pointer -- off
					interrupt used for pointer-calculation
				
   * Precise Pointer -- on
					hardware pointer used.

Bộ điều khiển
----------

Vì DSP-MADI-Mixer có Fader 8152 nên việc
sử dụng các điều khiển máy trộn tiêu chuẩn, vì điều này sẽ phá vỡ hầu hết
(đặc biệt là đồ họa) GUI ALSA-Mixer. Vì vậy, điều khiển bộ trộn đã được
được cung cấp bởi bộ điều khiển 2 chiều sử dụng
giao diện hwdep.

Ngoài ra, tất cả 128+256 Peak và RMS-Meter đều có thể được truy cập thông qua
giao diện hwdep. Vì nó luôn có thể là một vấn đề về hiệu suất
sao chép và chuyển đổi Cấp độ Đỉnh và RMS ngay cả khi bạn chỉ cần
thứ nhất, tôi quyết định xuất cấu trúc phần cứng để
cần một số driver-guru có thể triển khai ánh xạ bộ nhớ của bộ trộn
hoặc máy đo đỉnh trên ioctl, hoặc cũng chỉ để sao chép và không
chuyển đổi. Một ứng dụng thử nghiệm cho thấy việc sử dụng bộ điều khiển.

* Kiểm soát độ trễ --- chưa được triển khai !!!

.. note::
	   Note: Within the windows-driver the latency is accessible of a
	   control-panel, but buffer-sizes are controlled with ALSA from
	   hwparams-calls and should not be changed in run-state, I did not
	   implement it here.


* Đồng hồ hệ thống - bị treo !!!!

* Tên - "Chế độ đồng hồ hệ thống"

* Truy cập - Đọc Viết
    
* Giá trị -- "Master" "Slave"

.. note::
		  !!!! This is a hardware-function but is in conflict with the
		  Clock-source controller, which is a kind of ALSA-standard. I
		  makes sense to set the card to a special mode (master at some
		  frequency or slave), since even not using an Audio-application
		  a studio should have working synchronisations setup. So use
		  Clock-source-controller instead !!!!

* Nguồn đồng hồ

* Tên - "Nguồn đồng hồ mẫu"

* Truy cập - Đọc Viết

* Giá trị -- "Tự động đồng bộ hóa", "32,0 kHz nội bộ", "44,1 kHz nội bộ",
    "Nội bộ 48,0 kHz", "Nội bộ 64,0 kHz", "Nội bộ 88,2 kHz",
    "Nội bộ 96,0 kHz"

Chọn giữa Master ở Tần suất cụ thể và tần suất cũng vậy
		 Chế độ tốc độ hoặc Slave (Tự động đồng bộ hóa). Đồng thời xem "Tham chiếu đồng bộ hóa ưa thích"

.. warning::
       !!!! This is no pure hardware function but was implemented by
       ALSA by some ALSA-drivers before, so I use it also. !!!


* Tham chiếu đồng bộ ưa thích

* Tên -- "Tham chiếu đồng bộ hóa ưa thích"

* Truy cập - Đọc Viết

* Giá trị -- "Từ" "MADI"


Trong Chế độ tự động đồng bộ hóa, Nguồn đồng bộ hóa ưu tiên có thể được
		 được chọn. Nếu không có sẵn thì sử dụng cái khác nếu có thể.

.. note::
		 Note: Since MADI has a much higher bit-rate than word-clock, the
		 card should synchronise better in MADI Mode. But since the
		 RME-PLL is very good, there are almost no problems with
		 word-clock too. I never found a difference.


* Kênh TX 64

* Tên -- "Chế độ TX 64 kênh"

* Truy cập - Đọc Viết

* Giá trị -- 0 1

Sử dụng chế độ 64 kênh (1) hoặc chế độ 56 kênh cho
		 Truyền MADI (0).


.. note::
		 Note: This control is for output only. Input-mode is detected
		 automatically from hardware sending MADI.


* Xóa TMS

* Tên - "Xóa điểm đánh dấu theo dõi"

* Truy cập - Đọc Viết

* Giá trị -- 0 1


Không sử dụng để giảm 5 Bit âm thanh trên AES dưới dạng Bit bổ sung.
        

* Chế độ an toàn hoặc Tự động nhập liệu

* Tên -- "Chế độ an toàn"

* Truy cập - Đọc Viết

* Giá trị -- 0 1 (bật mặc định)

Nếu bật (1), thì nếu kết nối quang hoặc đồng trục
		 gặp thất bại, có sự tiếp quản của người đang làm việc, không có
		 mẫu thất bại. Nó chỉ hữu ích nếu bạn sử dụng cái thứ hai làm
		 kết nối dự phòng.

* Đầu vào

* Tên - "Chọn đầu vào"

* Truy cập - Đọc Viết

* Giá trị - đồng trục quang


Chọn đầu vào, quang hoặc đồng trục. Nếu Chế độ an toàn đang hoạt động,
		 đây là Đầu vào ưa thích.

Máy trộn
-----

* Máy trộn

* Tên - "Máy trộn"

* Truy cập - Đọc Viết

* Giá trị - <số kênh 0-127> <Giá trị 0-65535>


Ở đây, giá trị đầu tiên là chỉ mục kênh được lấy để lấy/đặt
		 kênh trộn tương ứng, trong đó 0-63 là đầu vào thành đầu ra
		 fader và 64-127 phát lại để tạo ra fader. Giá trị 0
		 kênh bị tắt tiếng 0 và 32768 có mức khuếch đại là 1.

* Chn 1-64

máy trộn nhanh cho các tiện ích máy trộn ALSA. Đường chéo của
       ma trận trộn được triển khai từ phát lại đến đầu ra.
       

* Dòng ra

* Tên -- "Line Out"

* Truy cập - Đọc Viết

* Giá trị -- 0 1

Bật và tắt đầu ra analog, không có gì để làm
		 với việc trộn hoặc định tuyến. đầu ra tương tự phản ánh kênh 63,64.


Thông tin (chỉ có quyền truy cập đọc)
------------------------------
 
* Tỷ lệ mẫu

* Tên - "Tỷ lệ mẫu hệ thống"

* Truy cập -- Chỉ đọc

nhận được tỷ lệ mẫu.


* Tỷ giá bên ngoài được đo

* Tên -- "Tỷ giá bên ngoài"

* Truy cập -- Chỉ đọc


Phải là "Tốc độ tự động đồng bộ hóa", nhưng Tên được sử dụng là
		 Lược đồ ALSA. Tần số mẫu bên ngoài được thích sử dụng trên Autosync là
		 báo cáo.


* Trạng thái đồng bộ hóa MADI

* Tên -- "Trạng thái khóa đồng bộ hóa MADI"

* Truy cập - Đọc

* Giá trị -- 0,1,2

MADI-Đầu vào là 0=Đã mở khóa, 1=Đã khóa hoặc 2=Đã đồng bộ hóa.


* Trạng thái đồng bộ hóa đồng hồ từ

* Tên -- "Trạng thái khóa đồng hồ từ"

* Truy cập - Đọc

* Giá trị -- 0,1,2

Đầu vào Đồng hồ Từ là 0=Đã mở khóa, 1=Đã khóa hoặc 2=Đã đồng bộ hóa.

* Tự động đồng bộ hóa

* Tên -- "Tham chiếu Tự động Đồng bộ hóa"

* Truy cập - Đọc

* Giá trị -- "WordClock", "MADI", "Không"

Tham chiếu đồng bộ hóa là "WordClock", "MADI" hoặc không có.

* RX 64ch --- người triển khai không có gì

MADI-Receiver ở chế độ 64 kênh hoặc chế độ 56 kênh.


* AB_inp --- chưa được kiểm tra

Đầu vào được sử dụng cho Tự động nhập.


* Vị trí bộ đệm thực tế --- chưa được triển khai

!!! đây là chức năng nội bộ của ALSA nên không sử dụng điều khiển !!!



Tham số cuộc gọi
=================

* chỉ số mảng int (min = 1, max = 8)

Giá trị chỉ mục cho giao diện RME HDSPM. chỉ mục thẻ trong ALSA

lưu ý: tiêu chuẩn ALSA

* Mảng chuỗi id (min=1, max=8)

Chuỗi ID cho giao diện RME HDSPM.

lưu ý: tiêu chuẩn ALSA

* kích hoạt mảng int (min = 1, max = 8)

Bật/tắt các card âm thanh HDSPM cụ thể.

lưu ý: tiêu chuẩn ALSA

* mảng int chính xác_ptr (min = 1, max = 8)

Bật con trỏ chính xác hoặc tắt.

.. note::
     note: Use only when the application supports this (which is a special case).

* mảng int line_outs_monitor (min = 1, max = 8)

Theo mặc định, gửi luồng phát lại tới đầu ra analog.

.. note::
	  note: each playback channel is mixed to the same numbered output
	  channel (routed). This is against the ALSA-convention, where all
	  channels have to be muted on after loading the driver, but was
	  used before on other cards, so i historically use it again)



* mảng int Enable_monitor (min = 1, max = 8)

Bật Analog Out trên Kênh 63/64 theo mặc định.

.. note ::
      note: here the analog output is enabled (but not routed).
