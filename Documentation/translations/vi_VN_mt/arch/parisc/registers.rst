.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/parisc/registers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Đăng ký sử dụng Linux/PA-RISC
====================================

[dấu hoa thị được sử dụng cho việc sử dụng theo kế hoạch hiện chưa được triển khai]

Sổ đăng ký chung theo quy định của ABI
======================================

Thanh ghi điều khiển
--------------------

====================================================================================
CR 0 (Bộ đếm phục hồi) được sử dụng cho ptrace
CR 1-CR 7(không xác định) không sử dụng
Giá trị CR 8 (ID bảo vệ) trên mỗi quy trình*
CR 9, 12, 13 (PIDS) chưa sử dụng
CR10 (CCR) FPU lười tiết kiệm*
CR11 theo quy định của ABI (SAR)
CR14 (vector gián đoạn) được khởi tạo thành error_vector
CR15 (EIEM) được khởi tạo cho tất cả những cái*
CR16 (Bộ đếm thời gian) đọc để bắt đầu đếm/ghi chu kỳ Khoảng thời gian Tmr
Thông số gián đoạn CR17-CR22
Thanh ghi hướng dẫn ngắt CR19
Thanh ghi không gian ngắt CR20
CR21 Đăng ký bù đắp ngắt
CR22 Ngắt PSW
CR23 (EIRR) đọc cho các ngắt đang chờ xử lý/xóa các bit ghi
CR24 (TR 0) Con trỏ thư mục trang không gian hạt nhân
CR25 (TR 1) Con trỏ thư mục trang không gian người dùng
CR26 (TR 2) không được sử dụng
CR27 (TR 3) Con trỏ mô tả luồng
CR28 (TR 4) không được sử dụng
CR29 (TR 5) không được sử dụng
Dòng điện CR30 (TR 6) / 0
CR31 (TR 7) Đăng ký tạm thời, được sử dụng ở nhiều nơi
====================================================================================

Thanh ghi không gian (chế độ kernel)
------------------------------------

====================================================================================
Thanh ghi không gian tạm thời SR0
SR4-SR7 được đặt thành 0
Thanh ghi không gian tạm thời SR1
Kernel SR2 không nên chặn cái này
SR3 được sử dụng để truy cập không gian người dùng (quy trình hiện tại)
====================================================================================

Thanh ghi không gian (chế độ người dùng)
----------------------------------------

====================================================================================
Thanh ghi không gian tạm thời SR0
Thanh ghi không gian tạm thời SR1
SR2 giữ không gian của trang cổng linux
SR3 giữ giá trị không gian địa chỉ người dùng khi ở trong kernel
SR4-SR7 Xác định không gian địa chỉ ngắn cho người dùng/kernel
====================================================================================


Từ trạng thái bộ xử lý
----------------------

====================================================================================
W (địa chỉ 64 bit) 0
E (Little-endian) 0
S (Hẹn giờ khoảng thời gian an toàn) 0
T (Bẫy cành cây bị bắt) 0
H (Bẫy đặc quyền cao hơn) 0
L (Bẫy đặc quyền thấp hơn) 0
N (Vô hiệu hóa lệnh tiếp theo) được sử dụng bởi mã C
X (Tắt ngắt bộ nhớ dữ liệu) 0
B (Taken Branch) được sử dụng bởi mã C
C (dịch địa chỉ mã) 1, 0 trong khi thực thi mã chế độ thực
V (hiệu chỉnh bước chia) được sử dụng bởi mã C
M (Mặt nạ HPMC) 0, 1 trong khi thực thi trình xử lý HPMC*
C/B (bit mang/mượn) được sử dụng bởi mã C
O (theo thứ tự tham khảo) 1*
F (màn hình hiệu suất) 0
R (Bẫy phản hồi phục) 0
Q (trạng thái gián đoạn thu thập) 1 (0 trong mã ngay trước rfi)
P (Số nhận dạng bảo vệ) 1*
D (Dịch địa chỉ dữ liệu) 1, 0 trong khi thực thi mã chế độ thực
I (mặt nạ ngắt bên ngoài) được sử dụng bởi macro cli()/sti()
====================================================================================

Thanh ghi "vô hình"
---------------------

====================================================================================
PSW giá trị W mặc định 0
PSW giá trị E mặc định 0
Thanh ghi bóng được sử dụng bởi mã xử lý gián đoạn
TOC kích hoạt bit 1
====================================================================================

-------------------------------------------------------------------------

Kiến trúc PA-RISC định nghĩa 7 thanh ghi là "thanh ghi bóng".
Chúng được sử dụng trong lệnh RETURN FROM INTERRUPTION AND RESTORE để giảm
trạng thái tiết kiệm và khôi phục thời gian bằng cách loại bỏ nhu cầu đăng ký chung
(GR) lưu và khôi phục trong trình xử lý gián đoạn.
Các thanh ghi bóng là GR 1, 8, 9, 16, 17, 24 và 25.

-------------------------------------------------------------------------

Đăng ký ghi chú sử dụng, ban đầu từ John Marvin, với một số bổ sung
ghi chú của Randolph Chung.

Đối với sổ đăng ký chung:

r1,r2,r19-r26,r28,r29 & r31 có thể được sử dụng mà không cần lưu chúng trước. Và của
Tất nhiên, bạn cần lưu chúng nếu bạn quan tâm đến chúng trước khi gọi
thủ tục khác. Một số thanh ghi trên có ý nghĩa đặc biệt
mà bạn nên biết:

r1:
	Lệnh addil được cài đặt sẵn để đặt kết quả của nó vào r1,
	vì vậy nếu bạn sử dụng hướng dẫn đó hãy lưu ý điều đó.

r2:
	Đây là con trỏ trả về. Nói chung là bạn không muốn
	hãy sử dụng cái này, vì bạn cần con trỏ để quay lại
	người gọi. Tuy nhiên, nó được nhóm với bộ thanh ghi này
	vì người gọi không thể dựa vào giá trị giống nhau
	khi bạn quay lại, tức là bạn có thể sao chép r2 sang một thanh ghi khác
	và quay lại thanh ghi đó sau khi xóa r2, và
	điều đó sẽ không gây ra vấn đề gì cho thói quen gọi điện.

r19-r22:
	chúng thường được coi là sổ đăng ký tạm thời.
	Lưu ý rằng trong 64 bit chúng là arg7-arg4.

r23-r26:
	đây là arg3-arg0, tức là bạn có thể sử dụng chúng nếu bạn
	không quan tâm đến các giá trị được truyền vào nữa.

r28, r29:
	là ret0 và ret1. Chúng là những gì bạn chuyển giá trị trả về
	in. r28 là lợi nhuận chính. Khi trả lại các cấu trúc nhỏ
	r29 cũng có thể được sử dụng để truyền dữ liệu trở lại người gọi.

r30:
	con trỏ ngăn xếp

r31:
	lệnh ble đặt con trỏ trả về ở đây.


r3-r18,r27,r30 cần được lưu và khôi phục. r3-r18 chỉ là
    các thanh ghi mục đích chung. r27 là con trỏ dữ liệu và là
    được sử dụng để làm cho việc tham chiếu đến các biến toàn cục dễ dàng hơn. r30 là
    con trỏ ngăn xếp.
