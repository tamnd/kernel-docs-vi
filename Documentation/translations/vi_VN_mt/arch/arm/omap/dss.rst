.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/omap/dss.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Hệ thống con hiển thị OMAP2/3
=========================

Đây là bản viết lại gần như toàn bộ trình điều khiển OMAP FB trong trình điều khiển/video/omap
(hãy gọi nó là DSS1). Sự khác biệt chính giữa DSS1 và DSS2 là DSI,
Hỗ trợ đầu ra TV và nhiều màn hình, nhưng có rất nhiều cải tiến nhỏ
cũng được.

Trình điều khiển DSS2 (mô-đun omapdss) nằm trong Arch/arm/plat-omap/dss/ và FB,
trình điều khiển bảng điều khiển và bộ điều khiển nằm trong driver/video/omap2/. DSS1 và DSS2 trực tiếp
hiện đang ở cạnh nhau, bạn có thể chọn cái nào để sử dụng.

Đặc trưng
--------

Các tính năng hoạt động và thử nghiệm bao gồm:

- Đầu ra MIPI DPI (song song)
- Đầu ra MIPI DSI ở chế độ lệnh
- Đầu ra MIPI DBI (RFBI)
- Đầu ra SDI
- Đầu ra tivi
- Tất cả các phần có thể được biên dịch dưới dạng mô-đun hoặc bên trong kernel
- Sử dụng DISPC để cập nhật bất kỳ đầu ra nào
- Sử dụng CPU để cập nhật đầu ra RFBI hoặc DSI
- Máy bay OMAP DISPC
- RGB16, RGB24 đã đóng gói, RGB24 đã giải nén
- YUV2, UYVY
- Chia tỷ lệ
- Điều chỉnh DSS FCK để tìm đồng hồ pixel tốt
- Dùng DSI DPLL để tạo DSS FCK

Các bảng được thử nghiệm bao gồm:
- Bảng OMAP3 SDP
- Bảng chó săn
-N810

trình điều khiển omapdss
--------------

Bản thân trình điều khiển DSS không có bất kỳ hỗ trợ nào cho bộ đệm khung Linux, V4L hoặc
giống như những cái hiện tại, nhưng nó có nhân bên trong API cấp cao hơn
trình điều khiển có thể sử dụng.

Trình điều khiển DSS mô hình các lớp phủ, trình quản lý lớp phủ và hiển thị của OMAP trong một
cách linh hoạt để kích hoạt cấu hình đa màn hình không phổ biến. Ngoài ra
mô hình hóa lớp phủ phần cứng, omapdss hỗ trợ lớp phủ ảo và lớp phủ
các nhà quản lý. Chúng có thể được sử dụng khi cập nhật màn hình với CPU hoặc hệ thống DMA.

hỗ trợ trình điều khiển omapdss cho âm thanh
--------------------------------
Tồn tại một số công nghệ và tiêu chuẩn hiển thị hỗ trợ âm thanh như
tốt. Do đó, việc cập nhật trình điều khiển thiết bị DSS để cung cấp âm thanh là điều cần thiết.
giao diện có thể được sử dụng bởi trình điều khiển âm thanh hoặc bất kỳ trình điều khiển nào khác quan tâm đến
chức năng.

Chức năng audio_enable nhằm mục đích chuẩn bị các thông tin liên quan
IP để phát lại (ví dụ: bật FIFO âm thanh, đưa vào/ra khỏi thiết lập lại
một số IP, cho phép chip đồng hành, v.v.). Nó dự định được gọi trước
âm thanh_start. Hàm audio_disable thực hiện thao tác ngược lại và được
dự định được gọi sau audio_stop.

Mặc dù trình điều khiển thiết bị DSS nhất định có thể hỗ trợ âm thanh, nhưng có thể đối với
âm thanh của một số cấu hình nhất định không được hỗ trợ (ví dụ: màn hình HDMI sử dụng
Thời gian quay video VESA). Hàm audio_supported nhằm mục đích truy vấn xem
cấu hình hiện tại của màn hình hỗ trợ âm thanh.

Chức năng audio_config nhằm mục đích định cấu hình tất cả âm thanh có liên quan
các thông số của màn hình. Để làm cho chức năng này độc lập với bất kỳ
trình điều khiển thiết bị DSS cụ thể, cấu trúc omap_dss_audio được xác định. Mục đích của nó
là chứa tất cả các tham số cần thiết cho cấu hình âm thanh. Tại
thời điểm này, cấu trúc như vậy chứa các con trỏ tới từ trạng thái kênh IEC-60958
và cấu trúc khung thông tin âm thanh CEA-861. Điều này là đủ để hỗ trợ
HDMI và DisplayPort, vì cả hai đều dựa trên CEA-861 và IEC-60958.

Các chức năng audio_enable/disable, audio_config và audio_supported có thể là
được thực hiện như các chức năng có thể ngủ. Vì thế không nên gọi chúng là
trong khi giữ một spinlock hoặc một readlock.

Chức năng audio_start/audio_stop nhằm mục đích bắt đầu/dừng âm thanh một cách hiệu quả
phát lại sau khi cấu hình đã diễn ra. Các chức năng này được thiết kế
được sử dụng trong bối cảnh nguyên tử. Do đó, audio_start sẽ quay trở lại nhanh chóng và được
chỉ được gọi sau khi tất cả các tài nguyên cần thiết để phát lại âm thanh (FIFO âm thanh,
Các kênh DMA, chip đồng hành, v.v.) đã được kích hoạt để bắt đầu truyền dữ liệu.
audio_stop được thiết kế để chỉ dừng việc truyền âm thanh. Các tài nguyên được sử dụng
for playback are released using audio_disable.

Enum omap_dss_audio_state có thể được sử dụng để trợ giúp việc triển khai
giao diện để theo dõi trạng thái âm thanh. Trạng thái ban đầu là _DISABLED;
sau đó, trạng thái chuyển sang _CONFIGURED và sau đó, khi nó sẵn sàng
phát âm thanh tới _ENABLED. Trạng thái _PLAYING được sử dụng khi âm thanh đang được
được kết xuất.


Trình điều khiển bảng điều khiển và bộ điều khiển
----------------------------

Các trình điều khiển triển khai chức năng cụ thể của bảng điều khiển hoặc bộ điều khiển và không
thường hiển thị cho người dùng ngoại trừ thông qua trình điều khiển omapfb.  Họ đăng ký
tới trình điều khiển DSS.

trình điều khiển omapfb
-------------

Trình điều khiển omapfb triển khai số lượng bộ đệm khung linux tiêu chuẩn tùy ý.
Các bộ đệm khung này có thể được định tuyến linh hoạt tới bất kỳ lớp phủ nào, do đó cho phép rất
kiến trúc hiển thị động.

Trình điều khiển xuất một số ioctls cụ thể của omapfb, tương thích với
ioctls trong trình điều khiển cũ.

Phần còn lại của các tính năng không chuẩn được xuất qua sysfs. Liệu có phải là trận chung kết
việc triển khai sẽ sử dụng sysfs hoặc ioctls vẫn đang mở.

Trình điều khiển V4L2
------------

V4L2 đang được triển khai ở TI.

Theo quan điểm của omapdss, trình điều khiển V4L2 phải tương tự như bộ đệm khung
người lái xe.

Ngành kiến ​​​​trúc
--------------------

Một số làm rõ những gì các thành phần khác nhau làm:

- Bộ đệm khung là vùng bộ nhớ bên trong SRAM/SDRAM của OMAP chứa
      dữ liệu pixel cho hình ảnh. Bộ đệm khung có chiều rộng, chiều cao và màu sắc
      chiều sâu.
    - Lớp phủ xác định vị trí các pixel được đọc từ đâu và chúng đi đến đâu trên
      màn hình. Lớp phủ có thể nhỏ hơn bộ đệm khung, do đó chỉ hiển thị
      một phần của bộ đệm khung. Vị trí của lớp phủ có thể được thay đổi nếu
      lớp phủ nhỏ hơn màn hình.
    - Trình quản lý lớp phủ kết hợp các lớp phủ vào một hình ảnh và cung cấp chúng cho
      hiển thị.
    - Màn hình là thiết bị hiển thị vật lý thực tế.

Bộ đệm khung có thể được kết nối với nhiều lớp phủ để hiển thị cùng một dữ liệu pixel
trên tất cả các lớp phủ. Lưu ý rằng trong trường hợp này kích thước đầu vào của lớp phủ phải là
giống nhau, nhưng trong trường hợp lớp phủ video, kích thước đầu ra có thể khác. bất kỳ
bộ đệm khung có thể được kết nối với bất kỳ lớp phủ nào.

Lớp phủ có thể được kết nối với một trình quản lý lớp phủ. Lớp phủ DISPC cũng có thể
chỉ được kết nối với trình quản lý lớp phủ DISPC và lớp phủ ảo chỉ có thể
được kết nối với lớp phủ ảo.

Trình quản lý lớp phủ có thể được kết nối với một màn hình. Có một số
hạn chế loại màn hình mà trình quản lý lớp phủ có thể được kết nối:

- Trình quản lý lớp phủ TV DISPC chỉ có thể được kết nối với màn hình TV.
    - Trình quản lý lớp phủ ảo chỉ có thể được kết nối với màn hình DBI hoặc DSI.
    - Trình quản lý lớp phủ DISPC LCD có thể được kết nối với tất cả các màn hình, ngoại trừ TV
      hiển thị.

hệ thống
-----
Giao diện sysfs chủ yếu được sử dụng để thử nghiệm. Tôi không nghĩ sysfs
giao diện này là tốt nhất cho phiên bản cuối cùng, nhưng tôi không biết rõ lắm
đâu sẽ là giao diện tốt nhất cho những thứ này.

Giao diện sysfs được chia thành hai phần: DSS và FB.

/sys/class/đồ họa/fb? thư mục:
gương 0=tắt, 1=bật
xoay Xoay 0-3 cho 0, 90, 180, 270 độ
xoay_type 0 = xoay DMA, 1 = xoay VRFB
lớp phủ Danh sách các số lớp phủ mà pixel bộ đệm khung đi tới
Phys_addr Địa chỉ vật lý của bộ đệm khung
virt_addr Địa chỉ ảo của bộ đệm khung
kích thước Kích thước của bộ đệm khung

/sys/thiết bị/nền tảng/omapdss/lớp phủ? thư mục:
đã bật 0=tắt, 1=bật
input_size chiều rộng, chiều cao (tức là kích thước bộ đệm khung)
tên người quản lý lớp phủ đích
tên
out_size chiều rộng, chiều cao
vị trí x, y
chiều rộng screen_width
Global_alpha alpha toàn cầu 0-255 0=trong suốt 255=đục

/sys/thiết bị/nền tảng/omapdss/người quản lý? thư mục:
hiển thị Hiển thị điểm đến
tên
alpha_blend_enabled 0=tắt, 1=bật
trans_key_enabled 0=tắt, 1=bật
trans_key_type gfx-destination, nguồn video
Phím màu trong suốt trans_key_value (RGB24)
default_color Màu nền mặc định (RGB24)

/sys/thiết bị/nền tảng/omapdss/hiển thị? thư mục:

==================================================================================
ctrl_name Tên bộ điều khiển
gương 0=tắt, 1=bật
update_mode 0=tắt, 1=tự động, 2=thủ công
đã bật 0=tắt, 1=bật
tên
xoay Xoay 0-3 cho 0, 90, 180, 270 độ
thời gian Hiển thị thời gian (pixclock,xres/hfp/hbp/hsw,yres/vfp/vbp/vsw)
		Khi viết, hai thời điểm đặc biệt được chấp nhận cho TV-out:
		"bạn" và "ntsc"
bảng_name
Tears_elim Loại bỏ xé 0=tắt, 1=bật
Output_type Loại đầu ra (chỉ bộ mã hóa video): "composite" hoặc "svideo"
==================================================================================

Ngoài ra còn có một số tệp debugfs tại <debugfs>/omapdss/ hiển thị thông tin
về đồng hồ và sổ đăng ký.

Ví dụ
--------

Các định nghĩa sau đây đã được đưa ra cho các ví dụ dưới đây::

ovl0=/sys/devices/platform/omapdss/overlay0
	ovl1=/sys/devices/platform/omapdss/overlay1
	ovl2=/sys/devices/platform/omapdss/overlay2

mgr0=/sys/devices/platform/omapdss/manager0
	mgr1=/sys/devices/platform/omapdss/manager1

lcd=/sys/devices/platform/omapdss/display0
	dvi=/sys/devices/platform/omapdss/display1
	tv=/sys/devices/platform/omapdss/display2

fb0=/sys/class/graphics/fb0
	fb1=/sys/class/graphics/fb1
	fb2=/sys/class/đồ họa/fb2

Thiết lập mặc định trên OMAP3 SDP
--------------------------

Đây là thiết lập mặc định trên bo mạch OMAP3 SDP. Tất cả các máy bay đều đi đến LCD. DVI
và đầu ra TV không được sử dụng. Các cột từ trái sang phải là:
bộ đệm khung, lớp phủ, trình quản lý lớp phủ, màn hình. Bộ đệm khung là
được xử lý bởi omapfb và phần còn lại được xử lý bởi DSS ::

FB0 --- GFX -\ DVI
	FB1 --- VID1 ---+- LCD ---- LCD
	FB2 --- VID2 -/ Tivi ----- Tivi

Ví dụ: Chuyển từ LCD sang DVI
-------------------------------

::

w=ZZ0000ZZ
	h=ZZ0001ZZ

echo "0" > $lcd/đã bật
	echo "" > $mgr0/hiển thị
	fbset -fb /dev/fb0 -xres $w -yres $h -vxres $w -vyres $h
	# at điểm này bạn phải chuyển đổi công tắc nhúng dvi/lcd từ bảng omap
	echo "dvi" > $mgr0/hiển thị
	echo "1" > $dvi/đã bật

Sau này, cấu hình trông như sau:::

FB0 --- GFX -\ -- DVI
	FB1 --- VID1 ---+- LCD -/ LCD
	FB2 --- VID2 -/ Tivi ----- Tivi

Ví dụ: Sao chép lớp phủ GFX sang LCD và TV
----------------------------------------

::

w=ZZ0000ZZ
	h=ZZ0001ZZ

echo "0" > $ovl0/đã bật
	echo "0" > $ovl1/đã bật

echo "" > $fb1/lớp phủ
	echo "0,1" > $fb0/lớp phủ

echo "$w,$h" > $ovl1/output_size
	echo "tv" > $ovl1/người quản lý

echo "1" > $ovl0/đã bật
	echo "1" > $ovl1/đã bật

echo "1" > $tv/đã bật

Sau đó, cấu hình trông như sau (chỉ hiển thị những phần có liên quan)::

FB0 +-- GFX ---- LCD ---- LCD
	\- VID1 ---- Tivi ---- Tivi

ghi chú linh tinh
----------

OMAP FB phân bổ bộ nhớ đệm khung bằng bộ cấp phát dma tiêu chuẩn. bạn
có thể kích hoạt Bộ cấp phát bộ nhớ liền kề (CONFIG_CMA) để cải thiện dma
bộ cấp phát và nếu CMA được bật, bạn sử dụng tham số kernel "cma=" để tăng
vùng bộ nhớ chung cho CMA.

Sử dụng DSI DPLL để tạo đồng hồ pixel, có thể tạo đồng hồ pixel
là 86,5 MHz (tối đa có thể) và nhờ đó bạn nhận được đầu ra 1280x1024@57 từ DVI.

Xoay và phản chiếu hiện chỉ hỗ trợ chế độ RGB565 và RGB8888. VRFB
không hỗ trợ phản chiếu.

Xoay VRFB yêu cầu nhiều bộ nhớ hơn so với bộ đệm khung không xoay, vì vậy bạn
có thể cần phải tăng cài đặt vram trước khi sử dụng chế độ xoay VRFB. Ngoài ra,
nhiều ứng dụng có thể không hoạt động với VRFB nếu chúng không chú ý đến tất cả
các tham số bộ đệm khung.

Đối số khởi động hạt nhân
---------------------

omapfb.mode=<display>:<mode>[,...]
	- Chế độ video mặc định cho màn hình được chỉ định. Ví dụ,
	  "dvi:800x400MR-24@60".  Xem trình điều khiển/video/modedb.c.
	  Ngoài ra còn có hai chế độ đặc biệt: "pal" và "ntsc"
	  có thể được sử dụng để truyền hình ra.

omapfb.vram=<fbnum>:<size>[@<physaddr>][,...]
	- VRAM được phân bổ cho bộ đệm khung. Thông thường omapfb phân bổ vram
	  tùy thuộc vào kích thước hiển thị. Với điều này bạn có thể phân bổ thủ công
	  hơn hoặc xác định địa chỉ vật lý của từng bộ đệm khung. Ví dụ,
	  "1:4M" để phân bổ 4M cho fb1.

omapfb.debug=<y|n>
	- Kích hoạt tính năng in gỡ lỗi. Bạn phải bật hỗ trợ gỡ lỗi OMAPFB
	  trong cấu hình kernel.

omapfb.test=<y|n>
	- Vẽ mẫu thử vào bộ đệm khung bất cứ khi nào cài đặt bộ đệm khung thay đổi.
	  Bạn cần bật hỗ trợ gỡ lỗi OMAPFB trong cấu hình kernel.

omapfb.vrfb=<y|n>
	- Sử dụng xoay VRFB cho tất cả các bộ đệm khung.

omapfb.rotate=<góc>
	- Xoay mặc định áp dụng cho tất cả các bộ đệm khung.
	  Xoay 0 - 0 độ
	  Xoay 1 - 90 độ
	  Xoay 2 - 180 độ
	  Xoay 3 - 270 độ

omapfb.mirror=<y|n>
	- Gương mặc định cho tất cả các bộ đệm khung. Chỉ hoạt động với vòng quay DMA.

omapdss.def_disp=<hiển thị>
	- Tên của màn hình mặc định mà tất cả các lớp phủ sẽ được kết nối.
	  Các ví dụ phổ biến là "lcd" hoặc "tv".

omapdss.debug=<y|n>
	- Kích hoạt tính năng in gỡ lỗi. Bạn phải bật hỗ trợ gỡ lỗi DSS trong
	  cấu hình hạt nhân.

TODO
----

Khóa DSS

Kiểm tra lỗi

- Rất nhiều kiểm tra bị thiếu hoặc được triển khai giống như BUG()

Cập nhật hệ thống DMA cho DSI

- Có thể sử dụng cho chế độ RGB16 và RGB24P. Có lẽ không dành cho RGB24U (làm thế nào
  để bỏ qua byte trống?)

Hỗ trợ OMAP1

- Không biết có cần thiết không
