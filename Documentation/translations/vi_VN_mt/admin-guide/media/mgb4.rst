.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/mgb4.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển mgb4
=====================

Bản quyền ZZ0000ZZ 2023 - 2025 Digiteq Automotive
    tác giả: Martin Tůma <martin.tuma@digiteqautomotive.com>

Đây là trình điều khiển thiết bị v4l2 dành cho Digiteq Automotive FrameGrabber 4, một PCIe
thẻ có khả năng ghi và tạo các luồng video FPD-Link III và GMSL2/3
như được sử dụng trong ngành công nghiệp ô tô.

giao diện sysfs
---------------

Trình điều khiển mgb4 cung cấp giao diện sysfs, được sử dụng để định cấu hình video
các tham số liên quan đến luồng (một số trong số chúng phải được đặt chính xác trước v4l2
có thể mở thiết bị) và nhận trạng thái luồng/thiết bị video.

Có hai loại tham số - liên quan đến thẻ toàn cầu/PCI, được tìm thấy trong
ZZ0000ZZ và mô-đun cụ thể được tìm thấy bên dưới
ZZ0001ZZ.

Thông số toàn cầu (thẻ PCI)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ (R):
    Loại mô-đun.

| 0 - Không có mô-đun nào
    | 1 - FPDL3
    | 2 - GMSL3 (một bộ tuần tự hóa, hai bộ giải tuần tự nối chuỗi)
    | 3 - GMSL3 (một bộ tuần tự hóa, hai bộ giải tuần tự)
    | 4 - GMSL3 (hai bộ khử tuần tự với hai đầu ra chuỗi vòng)
    | 6 - GMSL1
    | 8 - GMSL3 dỗ

ZZ0000ZZ (R):
    Số phiên bản mô-đun. Bằng 0 trong trường hợp thiếu mô-đun.

ZZ0000ZZ (R):
    Loại phần sụn.

| 1 - FPDL3
    | 2 - GMSL3
    | 3 - GMSL1

ZZ0000ZZ (R):
    Số phiên bản phần sụn.

ZZ0000ZZ (R):
    Số sê-ri thẻ. Định dạng là::

PRODUCT-REVISION-SERIES-SERIAL

trong đó mỗi thành phần là một số 8b.

Thông số đầu vào FPDL3/GMSL phổ biến
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ (R):
    ID số đầu vào, dựa trên số 0.

ZZ0000ZZ (RW):
    Số làn đường đầu ra của bộ khử lưu huỳnh.

| 0 - đơn
    | 1 - kép (mặc định)

ZZ0000ZZ (RW):
    Ánh xạ các bit đến trong tín hiệu tới các bit màu của pixel.

| 0 - OLDI/JEIDA
    | 1 - SPWG/VESA (mặc định)
    | 2 - ZDML

ZZ0000ZZ (R):
    Trạng thái liên kết video. Nếu liên kết bị khóa, các chip được kết nối đúng cách và
    giao tiếp ở cùng tốc độ và giao thức. Liên kết có thể bị khóa mà không cần
    một luồng video đang hoạt động.

Giá trị 0 tương đương với cờ V4L2_IN_ST_NO_SYNC của V4L2
    Các bit trạng thái VIDIOC_ENUMINPUT.

| 0 - đã mở khóa
    | 1 - bị khóa

ZZ0000ZZ (R):
    Trạng thái luồng video. Một luồng được phát hiện nếu liên kết bị khóa, đầu vào
    đồng hồ pixel đang chạy và tín hiệu DE đang di chuyển.

Giá trị 0 tương đương với cờ V4L2_IN_ST_NO_SIGNAL của V4L2
    Các bit trạng thái VIDIOC_ENUMINPUT.

| 0 - không được phát hiện
    | 1 - được phát hiện

ZZ0000ZZ (R):
    Độ rộng luồng video. Đây là chiều rộng thực tế được phát hiện bởi CTNH.

Giá trị giống hệt với những gì VIDIOC_QUERY_DV_TIMINGS trả về về chiều rộng
    trường của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Chiều cao luồng video. Đây là chiều cao thực tế được phát hiện bởi CTNH.

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về ở chiều cao
    trường của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Loại xung VSYNC được phát hiện bởi trình phát hiện định dạng video.

Giá trị tương đương với các cờ được trả về bởi VIDIOC_QUERY_DV_TIMINGS trong
    trường phân cực của cấu trúc v4l2_bt_timings.

| 0 - hoạt động ở mức thấp
    | 1 - hoạt động cao
    | 2 - không có sẵn

ZZ0000ZZ (R):
    Loại xung HSYNC được phát hiện bởi trình phát hiện định dạng video.

Giá trị tương đương với các cờ được trả về bởi VIDIOC_QUERY_DV_TIMINGS trong
    trường phân cực của cấu trúc v4l2_bt_timings.

| 0 - hoạt động ở mức thấp
    | 1 - hoạt động cao
    | 2 - không có sẵn

ZZ0000ZZ (RW):
    Nếu tín hiệu video đến không có tính năng đồng bộ hóa VSYNC và
    Các xung HSYNC, các xung này phải được tạo bên trong FPGA để đạt được
    thứ tự khung chính xác. Giá trị này cho biết có bao nhiêu pixel "trống"
    (pixel có tín hiệu Kích hoạt dữ liệu đã được xác nhận lại) là cần thiết để tạo
    xung VSYNC bên trong.

ZZ0000ZZ (RW):
    Nếu tín hiệu video đến không có tính năng đồng bộ hóa VSYNC và
    Các xung HSYNC, các xung này phải được tạo bên trong FPGA để đạt được
    thứ tự khung chính xác. Giá trị này cho biết có bao nhiêu pixel "trống"
    (pixel có tín hiệu Kích hoạt dữ liệu đã được xác nhận lại) là cần thiết để tạo
    xung HSYNC bên trong. Giá trị phải lớn hơn 1 và nhỏ hơn
    vsync_gap_length.

ZZ0000ZZ (R):
    Tần số xung nhịp pixel đầu vào tính bằng kHz.

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường pixelclock của cấu trúc v4l2_bt_timings.

*Lưu ý: Trước tiên, tham số dãy tần số phải được đặt đúng để có được
    tần số hợp lệ ở đây.*

ZZ0000ZZ (R):
    Độ rộng của tín hiệu HSYNC trong tích tắc đồng hồ PCLK.

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường hsync của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Độ rộng của tín hiệu VSYNC trong tích tắc đồng hồ PCLK.

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường vsync của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Số lượng xung PCLK giữa lúc xác nhận lại tín hiệu HSYNC và lần đầu tiên
    pixel hợp lệ trong dòng video (được đánh dấu bằng DE=1).

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường hbackporch của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Số xung PCLK giữa điểm cuối cùng của pixel hợp lệ cuối cùng trong video
    dòng (được đánh dấu bằng DE=1) và xác nhận tín hiệu HSYNC.

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường hfrontporch của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Số dòng video giữa việc xác nhận lại tín hiệu VSYNC và video
    dòng có pixel hợp lệ đầu tiên (được đánh dấu bằng DE=1).

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường vbackporch của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (R):
    Số dòng video giữa cuối dòng pixel hợp lệ cuối cùng (được đánh dấu
    bởi DE=1) và xác nhận tín hiệu VSYNC.

Giá trị giống hệt với giá trị VIDIOC_QUERY_DV_TIMINGS trả về
    trường vfrontporch của cấu trúc v4l2_bt_timings.

ZZ0000ZZ (RW)
    Dải tần PLL của bộ tạo xung nhịp đầu vào OLDI. Tần số PLL là
    bắt nguồn từ Tần số đồng hồ pixel (PCLK) và bằng PCLK nếu
    oldi_lane_width được đặt thành "single" và PCLK/2 nếu oldi_lane_width được đặt thành
    "kép".

| 0 - PLL < 50 MHz (mặc định)
    | 1 - PLL >= 50 MHz

*Lưu ý: Thông số này không thể thay đổi khi thiết bị đầu vào v4l2 đang hoạt động.
    mở.*

Thông số đầu ra FPDL3/GMSL phổ biến
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ (R):
    ID số đầu ra, dựa trên số 0.

ZZ0000ZZ (RW):
    Nguồn video đầu ra. Nếu đặt thành 0 hoặc 1 thì nguồn là thẻ tương ứng
    thiết bị đầu vào và đầu ra v4l2 bị vô hiệu hóa. Nếu đặt thành 2 hoặc 3, nguồn
    là thiết bị đầu ra video v4l2 tương ứng. Mặc định là
    đầu ra v4l2 tương ứng, tức là 2 cho OUT1 và 3 cho OUT2.

| 0 - đầu vào 0
    | 1 - đầu vào 1
    | 2 - đầu ra v4l2 0
    | 3 - v4l2 đầu ra 1

*Lưu ý: Thông số này không thể thay đổi trong khi ANY của đầu vào/đầu ra v4l2
    thiết bị đang mở.*

ZZ0000ZZ (RW):
    Chiều rộng hiển thị. Không có tính năng tự động phát hiện màn hình được kết nối, do đó
    giá trị thích hợp phải được đặt trước khi bắt đầu truyền phát. Chiều rộng mặc định
    là 1280.

*Lưu ý: Thông số này không thể thay đổi khi thiết bị đầu ra v4l2 đang hoạt động.
    mở.*

ZZ0000ZZ (RW):
    Hiển thị chiều cao Không có tính năng tự động phát hiện màn hình được kết nối, do đó
    giá trị thích hợp phải được đặt trước khi bắt đầu truyền phát. Chiều cao mặc định
    là 640.

*Lưu ý: Thông số này không thể thay đổi khi thiết bị đầu ra v4l2 đang hoạt động.
    mở.*

ZZ0000ZZ (RW):
    Ánh xạ các bit đi trong tín hiệu tới các bit màu của pixel.

| 0 - OLDI/JEIDA
    | 1 - SPWG/VESA (mặc định)
    | 2 - ZDML

ZZ0000ZZ (RW):
    Giới hạn tốc độ khung hình tín hiệu video đầu ra tính bằng khung hình trên giây. do
    các bước đồng hồ pixel đầu ra bị hạn chế, thẻ không phải lúc nào cũng có thể tạo ra
    tốc độ khung hình hoàn toàn phù hợp với giá trị mà màn hình được kết nối yêu cầu.
    Sử dụng tham số này người ta có thể giới hạn tốc độ khung hình bằng cách "làm tê liệt" tín hiệu
    sao cho các dòng không bằng nhau (các hiên của dòng cuối cùng khác nhau) nhưng
    tín hiệu có vẻ như có tốc độ khung hình chính xác với màn hình được kết nối.
    Giới hạn tốc độ khung hình mặc định là 60Hz.

ZZ0000ZZ (RW):
    Phân cực tín hiệu HSYNC.

| 0 - hoạt động ở mức thấp (mặc định)
    | 1 - hoạt động cao

ZZ0000ZZ (RW):
    Phân cực tín hiệu VSYNC.

| 0 - hoạt động ở mức thấp (mặc định)
    | 1 - hoạt động cao

ZZ0000ZZ (RW):
    Phân cực tín hiệu DE.

| 0 - hoạt động ở mức thấp
    | 1 - hoạt động cao (mặc định)

ZZ0000ZZ (RW):
    Tần số xung nhịp pixel đầu ra. Giá trị được phép nằm trong khoảng 25000-190000(kHz)
    và có một bước phi tuyến tính giữa hai lần liên tiếp được phép
    tần số. Trình điều khiển tìm tần số được phép gần nhất với tần số đã cho
    giá trị và thiết lập nó. Khi đọc thuộc tính này, bạn sẽ có được thông tin chính xác
    tần số do người lái đặt. Tần số mặc định là 61150kHz.

*Lưu ý: Thông số này không thể thay đổi khi thiết bị đầu ra v4l2 đang hoạt động.
    mở.*

ZZ0000ZZ (RW):
    Độ rộng của tín hiệu HSYNC tính bằng pixel. Giá trị mặc định là 40.

ZZ0000ZZ (RW):
    Độ rộng của tín hiệu VSYNC trong các dòng video. Giá trị mặc định là 20.

ZZ0000ZZ (RW):
    Số lượng xung PCLK giữa lúc xác nhận lại tín hiệu HSYNC và lần đầu tiên
    pixel hợp lệ trong dòng video (được đánh dấu bằng DE=1). Giá trị mặc định là 50.

ZZ0000ZZ (RW):
    Số xung PCLK giữa điểm cuối cùng của pixel hợp lệ cuối cùng trong video
    dòng (được đánh dấu bằng DE=1) và xác nhận tín hiệu HSYNC. Giá trị mặc định
    là 50.

ZZ0000ZZ (RW):
    Số dòng video giữa việc xác nhận lại tín hiệu VSYNC và video
    dòng có pixel hợp lệ đầu tiên (được đánh dấu bằng DE=1). Giá trị mặc định là 31.

ZZ0000ZZ (RW):
    Số dòng video giữa cuối dòng pixel hợp lệ cuối cùng (được đánh dấu
    bởi DE=1) và xác nhận tín hiệu VSYNC. Giá trị mặc định là 30.

Thông số đầu vào cụ thể của FPDL3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ (RW):
    Số dòng đầu vào deserializer.

| 0 - tự động (mặc định)
    | 1 - độc thân
    | 2 - kép

Thông số đầu ra cụ thể của FPDL3
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ (RW):
    Số lượng dòng đầu ra serializer.

| 0 - tự động (mặc định)
    | 1 - độc thân
    | 2 - kép

Thông số đầu vào cụ thể của GMSL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ (RW):
    Chế độ tốc độ GMSL.

| 0 - 12Gb/s (mặc định)
    | 1 - 6Gb/giây
    | 2 - 3Gbps
    | 3 - 1,5Gb/giây

ZZ0000ZZ (RW):
    Đa luồng GMSL chứa tối đa bốn luồng video. Thông số này
    chọn luồng nào được ghi lại bởi đầu vào video. Giá trị là
    chỉ số dựa trên số không của luồng. Id luồng mặc định là 0.

*Lưu ý: Thông số này không thể thay đổi khi thiết bị đầu vào v4l2 đang hoạt động.
    mở.*

ZZ0000ZZ (RW):
    Sửa lỗi chuyển tiếp GMSL (FEC).

| 0 - bị vô hiệu hóa
    | 1 - đã bật (mặc định)

Phân vùng MTD
--------------

Trình điều khiển mgb4 tạo thiết bị MTD có hai phân vùng:
 - mgb4-fw.X - Phần mềm FPGA.
 - mgb4-data.X - Cài đặt gốc, ví dụ: số sê-ri thẻ.

Phân vùng ZZ0000ZZ có thể ghi và được sử dụng để cập nhật FW, ZZ0001ZZ là
chỉ đọc. ZZ0002ZZ kèm theo tên phân vùng tượng trưng cho số thẻ.
Tùy thuộc vào cấu hình kernel CONFIG_MTD_PARTITIONED_MASTER, bạn có thể
cũng có sẵn phân vùng thứ ba có tên ZZ0003ZZ trong hệ thống. Cái này
phân vùng đại diện cho toàn bộ bộ nhớ FLASH của thẻ, chưa được phân vùng và người ta nên
không đùa giỡn với nó...

IIO (kích hoạt)
---------------

Trình điều khiển mgb4 tạo một thiết bị I/O công nghiệp (IIO) cung cấp trình kích hoạt và
khả năng trạng thái mức tín hiệu. Các phần tử quét sau đây có sẵn:

ZZ0000ZZ:
	Các mức kích hoạt và trạng thái đang chờ xử lý.

| bit 1 - kích hoạt 1 đang chờ xử lý
	| bit 2 - kích hoạt 2 đang chờ xử lý
	| bit 5 - kích hoạt 1 cấp độ
	| bit 6 - kích hoạt cấp 2

ZZ0000ZZ:
	Dấu thời gian của sự kiện kích hoạt.

Thiết bị iio có thể hoạt động ở chế độ "thô" nơi bạn có thể lấy tín hiệu
cấp độ (bit hoạt động 5 và 6) bằng cách sử dụng quyền truy cập sysfs hoặc ở chế độ bộ đệm được kích hoạt.
Trong chế độ đệm được kích hoạt, bạn có thể theo dõi các thay đổi mức tín hiệu (hoạt động
bit 1 và 2) bằng thiết bị iio trong /dev. Nếu bạn bật dấu thời gian, bạn
cũng sẽ nhận được thời gian sự kiện kích hoạt chính xác có thể khớp với khung hình video
(mỗi khung hình video mgb4 đều có dấu thời gian với cùng một nguồn đồng hồ).

*Lưu ý: mặc dù mẫu hoạt động luôn chứa tất cả các bit trạng thái, nhưng nó tạo ra
không có ý nghĩa gì khi lấy các bit đang chờ xử lý ở chế độ thô hoặc các bit cấp độ trong chế độ được kích hoạt
chế độ đệm - các giá trị không biểu thị dữ liệu hợp lệ trong trường hợp đó.*