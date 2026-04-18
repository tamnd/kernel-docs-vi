.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/viafb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================================
Trình điều khiển bộ đệm khung bảng điều khiển chip đồ họa tích hợp VIA
=======================================================

Nền tảng
--------
Trình điều khiển bộ đệm khung của bảng điều khiển dành cho chip đồ họa của
    Gia đình UniChrome VIA
    (CLE266, PM800 / CN400 / CN300,
    P4M800CE / P4M800Pro / CN700 / VN800,
    CX700 / VX700, K8M890, P4M890,
    CN896 / P4M900, VX800, VX855)

Tính năng trình điều khiển
---------------
Thiết bị: CRT, LCD, DVI

Hỗ trợ viafb_mode::

CRT:
	    640x480(60, 75, 85, 100, 120 Hz), 720x480(60 Hz),
	    720x576(60 Hz), 800x600(60, 75, 85, 100, 120 Hz),
	    848x480(60Hz), 856x480(60Hz), 1024x512(60Hz),
	    1024x768(60, 75, 85, 100 Hz), 1152x864(75 Hz),
	    1280x768(60 Hz), 1280x960(60 Hz), 1280x1024(60, 75, 85 Hz),
	    1440x1050(60 Hz), 1600x1200(60, 75 Hz), 1280x720(60 Hz),
	    1920x1080(60Hz), 1400x1050(60Hz), 800x480(60Hz)

độ sâu màu: hỗ trợ 8 bpp, 16 bpp, 32 bpp.

Hỗ trợ tăng tốc phần cứng 2D.

Sử dụng mô-đun viafb
----------------------
Bắt đầu viafb với cài đặt mặc định::

#modprobe viafb

Bắt đầu viafb với các tùy chọn người dùng::

#modprobe viafb viafb_mode=800x600 viafb_bpp=16 viafb_refresh=60
		  viafb_active_dev=CRT+DVI viafb_dvi_port=DVP1
		  viafb_mode1=1024x768 viafb_bpp=16 viafb_refresh1=60
		  viafb_SAMM_ON=1

viafb_mode:
	- 640x480 (mặc định)
	- 720x480
	- 800x600
	- 1024x768

viafb_bpp:
	- 8, 16, 32 (mặc định: 32)

viafb_refresh:
	- 60, 75, 85, 100, 120 (mặc định: 60)

viafb_lcd_dsp_method:
	- 0 : mở rộng (mặc định)
	- 1 : định tâm

viafb_lcd_mode:
	0 : Bảng LCD có đầu vào định dạng dữ liệu LSB (mặc định)
	1 : Bảng LCD với đầu vào định dạng dữ liệu MSB

viafb_lcd_panel_id:
	- 0 : Độ phân giải: 640x480, Kênh: đơn, Phối màu: Bật
	- 1 : Độ phân giải: 800x600, Kênh: đơn, Phối màu: Bật
	- 2 : Độ phân giải: 1024x768, Kênh: đơn, Phối màu: Bật (mặc định)
	- 3 : Độ phân giải: 1280x768, Kênh: đơn, Phối màu: Bật
	- 4 : Độ phân giải: 1280x1024, Kênh: kép, Phối màu: Bật
	- 5 : Độ phân giải: 1400x1050, Kênh: kép, Phối màu: Bật
	- 6 : Độ phân giải: 1600x1200, Kênh: kép, Phối màu: Bật

- 8 : Độ phân giải: 800x480, Kênh: đơn, Phối màu: Bật
	- 9 : Độ phân giải: 1024x768, Kênh: kép, Phối màu: Bật
	- 10: Độ phân giải: 1024x768, Kênh: đơn, Phối màu: Tắt
	- 11: Độ phân giải: 1024x768, Kênh: kép, Phối màu: Tắt
	- 12: Độ phân giải: 1280x768, Kênh: đơn, Phối màu: Tắt
	- 13: Độ phân giải: 1280x1024, Kênh: kép, Phối màu: Tắt
	- 14: Độ phân giải: 1400x1050, Kênh: kép, Phối màu: Tắt
	- 15: Độ phân giải: 1600x1200, Kênh: kép, Phối màu: Tắt
	- 16: Độ phân giải: 1366x768, Kênh: đơn, Phối màu: Tắt
	- 17: Độ phân giải: 1024x600, Kênh: đơn, Phối màu: Bật
	- 18: Độ phân giải: 1280x768, Kênh: kép, Phối màu: Bật
	- 19: Độ phân giải: 1280x800, Kênh: đơn, Phối màu: Bật

viafb_accel:
	- 0 : Không tăng tốc phần cứng 2D
	- 1 : Tăng tốc phần cứng 2D (mặc định)

viafb_SAMM_ON:
	- 0 : vô hiệu hóa viafb_SAMM_ON (mặc định)
	- 1 : kích hoạt viafb_SAMM_ON

viafb_mode1: (thiết bị hiển thị phụ)
	- 640x480 (mặc định)
	- 720x480
	- 800x600
	- 1024x768

viafb_bpp1: (thiết bị hiển thị phụ)
	- 8, 16, 32 (mặc định: 32)

viafb_refresh1: (thiết bị hiển thị phụ)
	- 60, 75, 85, 100, 120 (mặc định: 60)

viafb_active_dev:
	Tùy chọn này được sử dụng để chỉ định các thiết bị đang hoạt động.(CRT, DVI, CRT+LCD...)
	DVI là viết tắt của DVI hoặc HDMI, Ví dụ: Nếu bạn muốn bật HDMI,
	đặt viafb_active_dev=DVI. Trong trường hợp SAMM, phần trước của
	viafb_active_dev là thiết bị chính và sau đây là
	thiết bị thứ cấp.

Ví dụ:

Để kích hoạt một thiết bị, chẳng hạn như DVI, chúng ta có thể sử dụng::

modprobe viafb viafb_active_dev=DVI

Để bật hai thiết bị, chẳng hạn như CRT+DVI::

modprobe viafb viafb_active_dev=CRT+DVI;

Đối với trường hợp DuoView, chúng ta có thể sử dụng::

modprobe viafb viafb_active_dev=CRT+DVI

HOẶC::

modprobe viafb viafb_active_dev=DVI+CRT...

Đối với vỏ SAMM:

Nếu CRT là chính và DVI là phụ, chúng ta nên sử dụng::

modprobe viafb viafb_active_dev=CRT+DVI viafb_SAMM_ON=1...

Nếu DVI là chính và CRT là phụ, chúng ta nên sử dụng::

modprobe viafb viafb_active_dev=DVI+CRT viafb_SAMM_ON=1...

viafb_display_hardware_layout:
	Tùy chọn này được sử dụng để chỉ định bố cục phần cứng hiển thị cho chip CX700.

- 1 : chỉ LCD
	- 2 : chỉ DVI
	- 3 : LCD+DVI (mặc định)
	- 4 : LCD1+LCD2 (nội bộ + nội bộ)
	- 16: LCD1+ExternalLCD2 (trong + ngoài)

viafb_second_size:
	Tùy chọn này được sử dụng để đặt kích thước bộ nhớ thiết bị thứ hai (MB) trong trường hợp SAMM.
	Kích thước tối thiểu là 16.

viafb_platform_epia_dvi:
	Tùy chọn này được sử dụng để kích hoạt DVI trên EPIA - M

- 0 : Không có DVI trên EPIA - M (mặc định)
	- 1 : DVI trên EPIA - M

viafb_bus_width:
	Khi sử dụng Giao diện kỹ thuật số có độ rộng bus 24 - Bit,
	tùy chọn này nên được thiết lập.

- 12: LVDS 12-bit hoặc TMDS 12-bit (mặc định)
	- 24: LVDS 24-bit hoặc TMDS 24-bit

viafb_device_lcd_dualedge:
	Khi sử dụng Dual Edge Panel, nên đặt tùy chọn này.

- 0 : Không có Dual Edge Panel (mặc định)
	- 1 : Bảng điều khiển cạnh kép

viafb_lcd_port:
	Tùy chọn này được sử dụng để chỉ định cổng đầu ra LCD,
	các giá trị khả dụng là "DVP0" "DVP1" "DFP_HIGHLOW" "DFP_HIGH" "DFP_LOW".

cho LCD bên ngoài + DVI bên ngoài trên CX700(LCD bên ngoài nằm trên DVP0),
	chúng ta nên sử dụng::

modprobe viafb viafb_lcd_port=DVP0...

Ghi chú:
    1. CRT có thể không hiển thị chính xác đối với màn hình DuoView CRT & DVI tại
       chế độ PAL "640x480" có bật tính năng quét quá mức DVI.
    2. SAMM là viết tắt của bộ điều hợp đơn đa màn hình. Nó khác với
       nhiều đầu vì SAMM hỗ trợ nhiều màn hình ở các lớp trình điều khiển, do đó fbcon
       lớp thậm chí không biết về nó; Màn hình thứ hai của SAMM không có
       tệp nút thiết bị, do đó ứng dụng chế độ người dùng không thể truy cập trực tiếp vào tệp đó.
       Khi SAMM được bật, viafb_mode và viafb_mode1, viafb_bpp và
       viafb_bpp1, viafb_refresh và viafb_refresh1 có thể khác nhau.
    3. Khi bảng điều khiển phụ thuộc vào viafbinfo1, hãy tự động thay đổi độ phân giải
       và bpp, cần gọi VIAFB giao diện ioctl được chỉ định VIAFB_SET_DEVICE
       thay vì gọi hàm ioctl chung FBIOPUT_VSCREENINFO vì
       viafb không hỗ trợ tốt nhiều đầu, nếu không sẽ gây ra tình trạng vỡ màn hình.


Định cấu hình viafb bằng công cụ "fbset"
---------------------------------

"fbset" là tiện ích hộp thư đến của Linux.

1. Tra cứu thông tin viafb hiện tại, gõ::

# fbset-i

2. Đặt các độ phân giải và tốc độ viafb_refresh khác nhau::

# fbset <độ phân giải-vertical_sync>

ví dụ::

# fbset "1024x768-75"

hoặc::

# fbset -g 1024 768 1024 768 32

Kiểm tra tệp "/etc/fb.modes" để tìm các chế độ hiển thị có sẵn.

3. Đặt độ sâu màu::

# fbset -độ sâu <giá trị>

ví dụ::

# fbset-độ sâu 16


Định cấu hình viafb qua /proc
-------------------------
Các tệp sau tồn tại trong /proc/viafb

được hỗ trợ_output_devices
	Tệp chỉ đọc này chứa danh sách đầy đủ được phân tách bằng ',' chứa tất cả
	thiết bị đầu ra có thể có sẵn trên nền tảng của bạn. Có khả năng
	rằng không phải tất cả chúng đều có đầu nối trên phần cứng của bạn nhưng nó sẽ
	cung cấp một điểm khởi đầu tốt để tìm ra tên nào phù hợp
	một đầu nối thực sự.

Ví dụ::

# cat /proc/viafb/supported_output_devices

iga1/output_devices, iga2/output_devices
	Hai tập tin này có thể đọc và ghi được. iga1 và iga2 là hai
	đơn vị độc lập tạo ra hình ảnh trên màn hình. Những hình ảnh đó có thể
	chuyển tiếp tới một hoặc nhiều thiết bị đầu ra. Đọc những tập tin đó là một cách
	để truy vấn thiết bị đầu ra nào hiện đang được iga sử dụng.

Ví dụ::

# cat /proc/viafb/iga1/output_devices

Nếu không có thiết bị đầu ra nào được in thì đầu ra của iga này sẽ bị mất.
	Điều này có thể xảy ra chẳng hạn nếu chỉ sử dụng một (cái kia) iga.
	Việc ghi vào các tập tin này cho phép điều chỉnh các thiết bị đầu ra trong quá trình
	thời gian chạy. Người ta có thể thêm thiết bị mới, xóa thiết bị hiện có hoặc chuyển đổi
	giữa các igas. Về cơ bản, bạn có thể viết một danh sách thiết bị được phân tách bằng ','
	tên (hoặc một tên duy nhất) có cùng định dạng với đầu ra cho các tên đó
	tập tin. Bạn có thể thêm '+' hoặc '-' làm tiền tố cho phép phép cộng đơn giản
	và loại bỏ các thiết bị. Vì vậy, tiền tố '+' sẽ thêm các thiết bị từ danh sách của bạn
	đối với những thiết bị hiện có, '-' sẽ xóa các thiết bị được liệt kê khỏi
	những cái hiện có và nếu không có tiền tố thì nó sẽ thay thế tất cả những cái hiện có
	với những cái được liệt kê. Nếu bạn loại bỏ các thiết bị, chúng sẽ chuyển sang
	tắt. Nếu bạn thêm các thiết bị đã là một phần của iga khác thì chúng sẽ
	loại bỏ ở đó và thêm vào cái mới.

Ví dụ:

Thêm CRT làm thiết bị đầu ra cho iga1::

# echo +CRT > /proc/viafb/iga1/output_devices

Loại bỏ (tắt) DVP1 và LVDS1 làm thiết bị đầu ra của iga2::

# echo -DVP1,LVDS1 > /proc/viafb/iga2/output_devices

Thay thế tất cả các thiết bị đầu ra iga1 bằng CRT::

# echo CRT > /proc/viafb/iga1/output_devices


Khởi động với viafb
-----------------

Thêm dòng sau vào grub.conf của bạn::

chắp thêm = "video=viafb:viafb_mode=1024x768,viafb_bpp=32,viafb_refresh=85"


Chế độ bộ đệm khung VIA
=====================

.. include:: viafb.modes
   :literal:
