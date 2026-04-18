.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/switch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
chuyển đổi dm
=============

Mục tiêu chuyển đổi trình ánh xạ thiết bị tạo ra một thiết bị hỗ trợ
ánh xạ tùy ý các vùng I/O có kích thước cố định trên một tập hợp cố định
những con đường.  Đường dẫn được sử dụng cho bất kỳ khu vực cụ thể nào có thể được chuyển đổi
một cách linh hoạt bằng cách gửi cho mục tiêu một tin nhắn.

Nó ánh xạ I/O tới các thiết bị khối cơ bản một cách hiệu quả khi có một lượng lớn
số vùng địa chỉ có kích thước cố định nhưng không có mẫu đơn giản
điều đó sẽ cho phép biểu diễn nhỏ gọn ánh xạ, chẳng hạn như
dm-sọc.

Lý lịch
----------

Dell EqualLogic và một số mảng lưu trữ iSCSI khác sử dụng hệ thống phân tán
kiến trúc không khung.  Trong kiến trúc này, nhóm lưu trữ
bao gồm một số mảng lưu trữ riêng biệt ("thành viên"), mỗi mảng có
bộ điều khiển độc lập, bộ lưu trữ đĩa và bộ điều hợp mạng.  Khi một chiếc LUN
được tạo ra và nó được trải rộng trên nhiều thành viên.  Các chi tiết của
sự lan truyền bị ẩn khỏi những người khởi tạo được kết nối với hệ thống lưu trữ này.
Nhóm lưu trữ hiển thị một cổng khám phá mục tiêu duy nhất, bất kể
có bao nhiêu thành viên đang được sử dụng.  Khi phiên iSCSI được tạo, mỗi phiên
phiên được kết nối với một cổng eth trên một thành viên.  Dữ liệu tới LUN
có thể được gửi trên bất kỳ phiên iSCSI nào và nếu các khối đang được truy cập
được lưu trữ trên một thành viên khác, I/O sẽ được chuyển tiếp theo yêu cầu.  Cái này
việc chuyển tiếp là vô hình đối với người khởi xướng.  Cách bố trí lưu trữ cũng
động và các khối được lưu trữ trên đĩa có thể được di chuyển từ thành viên này sang thành viên khác
thành viên khi cần thiết để cân bằng tải.

Kiến trúc này đơn giản hóa việc quản lý và cấu hình cả hai
nhóm lưu trữ và người khởi xướng.  Trong cấu hình đa đường, nó
có thể thiết lập nhiều phiên iSCSI để sử dụng nhiều mạng
giao diện trên cả máy chủ và mục tiêu để tận dụng lợi thế của
tăng băng thông mạng.  Người khởi xướng có thể sử dụng một vòng đơn giản
thuật toán robin để gửi I/O qua tất cả các đường dẫn và để mảng lưu trữ
các thành viên chuyển tiếp nó khi cần thiết, nhưng có một lợi thế về hiệu suất để
gửi dữ liệu trực tiếp đến đúng thành viên.

Bảng ánh xạ thiết bị đã cho phép bạn ánh xạ các vùng khác nhau của một
thiết bị vào các mục tiêu khác nhau.  Tuy nhiên trong kiến trúc này LUN là
trải rộng với kích thước vùng địa chỉ theo thứ tự 10 MB,
có nghĩa là bảng kết quả có thể có hơn một triệu mục và
tiêu tốn quá nhiều bộ nhớ.

Bằng cách sử dụng mục tiêu chuyển đổi trình ánh xạ thiết bị này, giờ đây chúng ta có thể xây dựng một mô hình hai lớp
phân cấp thiết bị:

Tầng trên - Xác định thành viên mảng nào mà I/O sẽ được gửi tới.
    Cấp thấp hơn - Cân bằng tải giữa các đường dẫn đến một thành viên cụ thể.

Tầng dưới bao gồm một thiết bị đa đường dm duy nhất cho mỗi thành viên.
Mỗi thiết bị đa đường này chứa tập hợp các đường dẫn trực tiếp đến
thành viên mảng trong một nhóm ưu tiên và tận dụng đường dẫn hiện có
bộ chọn để cân bằng tải giữa các đường dẫn này.  Chúng tôi cũng xây dựng một
nhóm ưu tiên không ưu tiên chứa đường dẫn đến các thành viên mảng khác cho
lý do chuyển đổi thất bại.

Tầng trên bao gồm một thiết bị dm-switch duy nhất.  Thiết bị này sử dụng
một bitmap để tra cứu vị trí của I/O và chọn vị trí thích hợp
thiết bị cấp thấp hơn để định tuyến I/O.  Bằng cách sử dụng bitmap chúng ta có thể
sử dụng 4 bit cho mỗi dải địa chỉ trong nhóm 16 thành viên (rất
lớn đối với chúng tôi).  Đây là một biểu diễn dày đặc hơn nhiều so với bảng dm
b-cây có thể đạt được.

Thông số xây dựng
=======================

<num_paths> <khu vực_size> <num_Option_args> [<tùy chọn_args>...] [<dev_path> <offset>]+
	<num_path>
	    Số lượng đường dẫn để phân phối I/O.

<khu vực_kích thước>
	    Số lượng cung 512 byte trong một vùng. Mỗi khu vực có thể được chuyển hướng
	    đến bất kỳ đường dẫn có sẵn nào.

<num_Option_args>
	    Số lượng đối số tùy chọn. Hiện tại, không có đối số tùy chọn
	    được hỗ trợ và do đó giá trị này phải bằng 0.

<dev_path>
	    Thiết bị khối đại diện cho một đường dẫn cụ thể đến thiết bị.

<bù đắp>
	    Độ lệch của điểm bắt đầu dữ liệu trên <dev_path> cụ thể (tính bằng đơn vị
	    của các cung 512 byte). Số này được thêm vào số ngành khi
	    chuyển tiếp yêu cầu đến đường dẫn cụ thể. Thông thường nó bằng không.

Tin nhắn
========

set_khu vực_mappings <index>:<path_nr> [<index>]:<path_nr> [<index>]:<path_nr>...

Sửa đổi bảng vùng bằng cách chỉ định vùng nào được chuyển hướng đến
những con đường nào.

<chỉ mục>
    Số vùng (kích thước vùng được chỉ định trong tham số hàm tạo).
    Nếu chỉ mục bị bỏ qua, vùng tiếp theo (chỉ mục trước + 1) sẽ được sử dụng.
    Được biểu thị bằng hệ thập lục phân (WITHOUT bất kỳ tiền tố nào như 0x).

<path_nr>
    Số đường dẫn trong phạm vi 0 ... (<num_paths> - 1).
    Được biểu thị bằng hệ thập lục phân (WITHOUT bất kỳ tiền tố nào như 0x).

R<n>,<m>
    Tham số này cho phép tải các mẫu lặp đi lặp lại một cách nhanh chóng. <n> và <m>
    là các số thập lục phân. Ánh xạ <n> cuối cùng được lặp lại trong <m> tiếp theo
    khe cắm.

Trạng thái
======

Không có dòng trạng thái nào được báo cáo.

Ví dụ
=======

Giả sử rằng bạn có các tập vg1/switch0 vg1/switch1 vg1/switch2 với
cùng kích thước.

Tạo một thiết bị chuyển mạch có kích thước vùng 64kB::

dmsetup tạo công tắc --bảng "0 ZZ0000ZZ
	chuyển 3 128 0 /dev/vg1/switch0 0 /dev/vg1/switch1 0 /dev/vg1/switch2 0"

Đặt ánh xạ cho 7 mục đầu tiên để trỏ đến các thiết bị switch0, switch1,
switch2, switch0, switch1, switch2, switch1::

chuyển đổi thông báo dmsetup 0 set_khu vực_mappings 0:0 :1 :2 :0 :1 :2 :1

Đặt ánh xạ lặp đi lặp lại. Lệnh này::

chuyển đổi thông báo dmsetup 0 set_khu vực_mappings 1000:1 :2 R2,10

tương đương với::

chuyển đổi thông báo dmsetup 0 set_khu vực_mappings 1000:1 :2 :1 :2 :1 :2 :1 :2 \
	:1 :2 :1 :2 :1 :2 :1 :2 :1 :2
