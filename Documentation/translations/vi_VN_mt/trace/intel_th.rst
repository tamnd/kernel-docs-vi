.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/intel_th.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Trung tâm theo dõi Intel(R) (TH)
=======================

Tổng quan
--------

Intel(R) Trace Hub (TH) là một tập hợp các khối phần cứng tạo ra,
chuyển đổi và xuất dữ liệu theo dõi từ nhiều phần cứng và phần mềm
nguồn qua một số loại cổng đầu ra theo dõi được mã hóa trong Hệ thống
Giao thức theo dõi (MIPI STPv2) và nhằm thực hiện toàn bộ hệ thống
gỡ lỗi. Để biết thêm thông tin về phần cứng, hãy xem Intel(R) Trace
Hướng dẫn dành cho nhà phát triển Hub [1].

Nó bao gồm các nguồn theo dõi, các điểm đến theo dõi (đầu ra) và một
công tắc (Trung tâm theo dõi toàn cầu, GTH). Các thiết bị này được đặt trên một bus
của riêng họ ("intel_th"), nơi chúng có thể được phát hiện và định cấu hình
thông qua các thuộc tính sysfs.

Hiện tại, các thiết bị con (khối) Intel TH sau được hỗ trợ:
  - Software Trace Hub (STH), nguồn theo dõi, là System Trace
    Thiết bị mô-đun (STM),
  - Bộ nhớ lưu trữ (MSU), đầu ra theo dõi, cho phép lưu trữ
    theo dõi đầu ra trung tâm trong bộ nhớ hệ thống,
  - Đầu ra Giao diện theo dõi song song (PTI), đầu ra theo dõi ra bên ngoài
    gỡ lỗi máy chủ qua cổng PTI,
  - Global Trace Hub (GTH), là một công tắc và thành phần trung tâm
    kiến trúc Intel(R) Trace Hub.

Các thuộc tính chung của thiết bị đầu ra được mô tả trong
Tài liệu/ABI/testing/sysfs-bus-intel_th-output-devices, nhiều nhất
đáng chú ý trong số đó là "hoạt động", cho phép hoặc vô hiệu hóa đầu ra theo dõi
vào thiết bị đầu ra cụ thể đó.

GTH cho phép hướng các chủ STP khác nhau vào các cổng đầu ra khác nhau
thông qua nhóm thuộc tính "masters" của nó. Giao diện GTH chi tiết hơn
mô tả có tại Documentation/ABI/testing/sysfs-bus-intel_th-devices-gth.

STH đăng ký một thiết bị lớp stm, qua đó nó cung cấp giao diện
tới các nguồn theo dõi phần mềm không gian người dùng và không gian hạt nhân. Xem
Documentation/trace/stm.rst để biết thêm thông tin về điều đó.

MSU có thể được cấu hình để thu thập dữ liệu dấu vết vào bộ nhớ hệ thống
bộ đệm, sau này có thể được đọc từ các nút thiết bị của nó thông qua read() hoặc
giao diện mmap() và được chuyển hướng đến trình điều khiển "phần mềm chìm" sẽ
tiêu thụ dữ liệu và/hoặc chuyển tiếp nó hơn nữa.

Nhìn chung, Intel(R) Trace Hub không yêu cầu bất kỳ yêu cầu đặc biệt nào
phần mềm không gian người dùng hoạt động; mọi thứ đều có thể được cấu hình, bắt đầu
và được thu thập thông qua các thuộc tính sysfs và các nút thiết bị.

[1] ZZ0000ZZ

Xe buýt và thiết bị phụ
------------------

Đối với mỗi thiết bị Intel TH trong hệ thống, có một bus riêng
đã tạo và gán một số id phản ánh thứ tự TH
các thiết bị đã được liệt kê. Tất cả các thiết bị con TH (thiết bị trên bus intel_th)
bắt đầu với id này: 0-gth, 0-msc0, 0-msc1, 0-pti, 0-sth, tức là
theo sau là tên thiết bị và chỉ mục tùy chọn.

Các thiết bị đầu ra cũng nhận được một nút thiết bị trong /dev/intel_thN, trong đó N là
id thiết bị Intel TH. Ví dụ: bộ đệm bộ nhớ của MSU, khi
được phân bổ, có thể truy cập được thông qua /dev/intel_th0/msc{0,1}.

Ví dụ nhanh
-------------

# figure ra cổng GTH nào là bộ điều khiển bộ nhớ đầu tiên::

$ cat /sys/bus/intel_th/devices/0-msc0/port
	0

# looks giống như port 0, cấu hình master 33 gửi dữ liệu tới port 0::

$ echo 0 > /sys/bus/intel_th/devices/0-gth/masters/33

# allocate bộ đệm đa khối 2 cửa sổ trên bộ nhớ đầu tiên
# controller, mỗi trang 64 trang::

$ echo multi > /sys/bus/intel_th/devices/0-msc0/mode
	$ echo 64,64 > /sys/bus/intel_th/devices/0-msc0/nr_pages

Gói # enable cũng dành cho bộ điều khiển này ::

$ echo 1 > /sys/bus/intel_th/devices/0-msc0/wrap

# and cho phép truy tìm cổng này::

$ echo 1 > /sys/bus/intel_th/devices/0-msc0/active

# .. gửi dữ liệu tới master 33, xem stm.txt để biết thêm chi tiết ..
#..chờ dấu vết chồng chất lên..
# .. và dừng dấu vết::

$ echo 0 > /sys/bus/intel_th/devices/0-msc0/active

# and bây giờ bạn có thể thu thập dấu vết từ nút thiết bị::

$ cat /dev/intel_th0/msc0 > my_stp_trace

Chế độ gỡ lỗi máy chủ
------------------

Có thể định cấu hình Trace Hub và kiểm soát dấu vết của nó
chụp từ máy chủ gỡ lỗi từ xa, cần được kết nối thông qua một trong các
các giao diện gỡ lỗi phần cứng, sau đó sẽ được sử dụng cho cả
kiểm soát Intel Trace Hub và chuyển dữ liệu theo dõi của nó đến máy chủ gỡ lỗi.

Người lái xe cần được thông báo rằng sự sắp xếp như vậy đang diễn ra
để nó không chạm vào bất kỳ cấu hình chụp/cổng nào và tránh
xung đột với quyền truy cập cấu hình của máy chủ gỡ lỗi. duy nhất
hoạt động mà người lái xe sẽ thực hiện ở chế độ này đang thu thập
dấu vết phần mềm tới Software Trace Hub (một thiết bị lớp stm). các
người dùng vẫn chịu trách nhiệm thiết lập kênh chính/kênh phù hợp
ánh xạ mà bộ giải mã ở đầu nhận sẽ nhận ra.

Để bật chế độ máy chủ, hãy đặt tham số 'host_mode' của
mô-đun hạt nhân 'intel_th' thành 'y'. Không có thiết bị đầu ra ảo nào
sẽ hiển thị trên xe buýt intel_th. Ngoài ra, theo dõi cấu hình và
việc chụp các nhóm thuộc tính kiểm soát của thiết bị 'gth' sẽ không được
bị lộ. Thiết bị 'sth' sẽ hoạt động như bình thường.

Phần mềm chìm
--------------

Trình điều khiển Bộ nhớ lưu trữ (MSU) cung cấp API trong nhân cho
trình điều khiển tự đăng ký làm phần mềm chứa dữ liệu theo dõi.
Những trình điều khiển như vậy có thể xuất thêm dữ liệu qua các thiết bị khác, chẳng hạn như
Bộ điều khiển thiết bị hoặc card mạng USB.

API có hai phần chính::
 - thông báo cho phần mềm chìm rằng một cửa sổ cụ thể đã đầy và
   "khóa" cửa sổ đó, nghĩa là làm cho nó không thể theo dõi được
   bộ sưu tập; khi điều này xảy ra, trình điều khiển MSU sẽ tự động
   chuyển sang cửa sổ tiếp theo trong bộ đệm nếu nó được mở khóa hoặc dừng
   việc ghi lại dấu vết nếu không;
 - theo dõi trạng thái "bị khóa" của các cửa sổ và cung cấp cách thức để
   trình điều khiển chìm phần mềm để thông báo cho trình điều khiển MSU khi có cửa sổ
   đã được mở khóa và có thể được sử dụng lại để thu thập dữ liệu dấu vết.

Một ví dụ về trình điều khiển chìm, msu-sink minh họa việc triển khai một
chìm phần mềm. Về mặt chức năng, nó chỉ đơn giản là mở khóa các cửa sổ ngay khi chúng
đã đầy, giữ cho MSU chạy ở chế độ đệm tròn. Không giống như
chế độ "đa", nó sẽ điền vào tất cả các cửa sổ trong bộ đệm thay vì
chỉ đến cái đầu tiên. Nó có thể được kích hoạt bằng cách ghi "chìm" vào "chế độ"
tập tin (giả sử msu-sink.ko đã được tải).