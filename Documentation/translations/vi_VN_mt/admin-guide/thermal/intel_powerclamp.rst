.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/thermal/intel_powerclamp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Trình điều khiển Powerclamp Intel
=================================

Bởi:
  - Arjan van de Ven <arjan@linux.intel.com>
  - Jacob Pan <jacob.jun.pan@linux.intel.com>

.. Contents:

	(*) Introduction
	    - Goals and Objectives

	(*) Theory of Operation
	    - Idle Injection
	    - Calibration

	(*) Performance Analysis
	    - Effectiveness and Limitations
	    - Power vs Performance
	    - Scalability
	    - Calibration
	    - Comparison with Alternative Techniques

	(*) Usage and Interfaces
	    - Generic Thermal Layer (sysfs)
	    - Kernel APIs (TBD)

	(*) Module Parameters

INTRODUCTION
============

Hãy xem xét tình huống mà mức tiêu thụ điện năng của hệ thống phải
giảm trong thời gian chạy, do nguồn điện, hạn chế về nhiệt hoặc tiếng ồn
mức độ và nơi làm mát tích cực không được ưu tiên. Phần mềm được quản lý
việc giảm công suất thụ động phải được thực hiện để ngăn phần cứng
hành động được thiết kế cho các tình huống thảm khốc.

Hiện tại, trạng thái P, trạng thái T (điều chế đồng hồ) và ngoại tuyến CPU
được sử dụng để điều chỉnh CPU.

Trên CPU Intel, trạng thái C giúp giảm điện năng hiệu quả, nhưng cho đến nay
chúng chỉ được sử dụng một cách cơ hội, dựa trên khối lượng công việc. Với
phát triển trình điều khiển intel_powerclamp, phương pháp đồng bộ hóa
tính năng tiêm nhàn rỗi trên tất cả các luồng CPU trực tuyến đã được giới thiệu. mục tiêu
là đạt được tình trạng cư trú ở trạng thái C bắt buộc và có thể kiểm soát.

Kiểm tra/Phân tích đã được thực hiện trong các lĩnh vực sức mạnh, hiệu suất,
khả năng mở rộng và trải nghiệm người dùng. Trong nhiều trường hợp, lợi thế rõ ràng là
hiển thị về việc đưa CPU ngoại tuyến hoặc điều chỉnh đồng hồ CPU.


THEORY CỦA OPERATION
===================

Tiêm nhàn rỗi
--------------

Trên bộ xử lý Intel hiện đại (Nehalem trở lên), trạng thái C cấp gói
cư trú có sẵn trong MSR, do đó cũng có sẵn cho kernel.

Các MSR này là::

#define MSR_PKG_C2_RESIDENCY 0x60D
      #define MSR_PKG_C3_RESIDENCY 0x3F8
      #define MSR_PKG_C6_RESIDENCY 0x3F9
      #define MSR_PKG_C7_RESIDENCY 0x3FA

Nếu hạt nhân cũng có thể đưa thời gian nhàn rỗi vào hệ thống thì
hệ thống điều khiển vòng kín có thể được thiết lập để quản lý gói
trạng thái cấp C. Trình điều khiển intel_powerclamp được hình thành như một
hệ thống điều khiển, trong đó điểm đặt mục tiêu là điểm không hoạt động do người dùng chọn
tỷ lệ (dựa trên mức giảm công suất) và lỗi là sự khác biệt
giữa tỷ lệ cư trú ở trạng thái C cấp gói thực tế và tỷ lệ không hoạt động mục tiêu
tỷ lệ.

Việc tiêm được điều khiển bởi các luồng nhân có mức độ ưu tiên cao, được sinh ra cho
mỗi CPU trực tuyến.

Các luồng nhân này, với lớp SCHED_FIFO, được tạo để thực hiện
hành động kẹp của tỷ lệ nhiệm vụ được kiểm soát và thời gian. Mỗi mỗi CPU
luồng đồng bộ hóa thời gian và khoảng thời gian nhàn rỗi của nó, dựa trên việc làm tròn
nhanh chóng, do đó có thể ngăn ngừa được các lỗi tích lũy để tránh tình trạng bồn chồn
hiệu ứng. Các luồng cũng được liên kết với CPU sao cho chúng không thể bị
đã di chuyển, trừ khi CPU được đưa ngoại tuyến. Trong trường hợp này, chủ đề
thuộc về CPU ngoại tuyến sẽ bị chấm dứt ngay lập tức.

Chạy dưới dạng SCHED_FIFO và có mức độ ưu tiên tương đối cao, cũng cho phép như vậy
lược đồ để làm việc cho cả hạt nhân được ưu tiên và không được ưu tiên.
Căn chỉnh thời gian nhàn rỗi trong nháy mắt đảm bảo khả năng mở rộng cho HZ
các giá trị. Hiệu ứng này có thể được hình dung rõ hơn bằng cách sử dụng biểu đồ thời gian Perf.
Sơ đồ sau đây cho thấy hoạt động của luồng kernel
kidle_inject/cpu. Trong khi chạy không tải, nó chạy màn hình/mwait không hoạt động
trong một "thời lượng" nhất định, sau đó giao CPU cho các nhiệm vụ khác,
cho đến khoảng thời gian tiếp theo.

Đánh dấu lịch trình NOHZ bị vô hiệu hóa trong thời gian nhàn rỗi, nhưng làm gián đoạn
không bị che đậy. Các thử nghiệm cho thấy số lần đánh thức thêm từ bộ lập lịch đánh dấu
có tác động đáng kể đến hiệu quả của bộ điều khiển powerclamp
trên các hệ thống quy mô lớn (hệ thống Westmere với 80 bộ xử lý).

::

CPU0
		    ____________ ____________
  kidle_inject/0 ZZ0000ZZ chờ đợi ZZ0001ZZ
	  _________ZZ0002ZZ________ZZ0003ZZ_______
				 thời lượng
  CPU1
		    ____________ ____________
  kidle_inject/1 ZZ0004ZZ chờ đợi ZZ0005ZZ
	  _________ZZ0006ZZ________ZZ0007ZZ_______
				^
				|
				|
				làm tròn (nháy mắt, khoảng thời gian)

Chỉ một CPU được phép thu thập số liệu thống kê và cập nhật toàn cầu
các thông số điều khiển. CPU này được gọi là CPU điều khiển trong
tài liệu này. CPU điều khiển được chọn trong thời gian chạy, với
chính sách ủng hộ BSP, có tính đến khả năng có CPU
phích cắm nóng.

Xét về mặt động lực học của hệ thống điều khiển không tải, mức độ không tải của gói
thời gian được coi phần lớn là một hệ thống phi nhân quả trong đó hành vi của nó
không thể dựa trên đầu vào quá khứ hoặc hiện tại. Vì vậy,
Trình điều khiển intel_powerclamp cố gắng thực thi thời gian rảnh mong muốn
ngay lập tức như đầu vào nhất định (tỷ lệ nhàn rỗi mục tiêu). Sau khi tiêm,
powerclamp giám sát thời gian không hoạt động thực tế trong một khoảng thời gian nhất định và điều chỉnh
lần tiêm tiếp theo cho phù hợp để tránh điều chỉnh quá mức/thiếu.

Khi được sử dụng trong hệ thống kiểm soát nhân quả, chẳng hạn như kiểm soát nhiệt độ,
người sử dụng trình điều khiển này có quyền triển khai các thuật toán trong đó
các mẫu và kết quả đầu ra trong quá khứ được đưa vào phản hồi. Ví dụ, một
Bộ điều khiển nhiệt dựa trên PID có thể sử dụng trình điều khiển powerclamp để
duy trì nhiệt độ mục tiêu mong muốn, dựa trên cơ sở tích hợp và
lợi nhuận phái sinh của các mẫu trong quá khứ.



Sự định cỡ
-----------
Trong quá trình kiểm tra khả năng mở rộng, có thể thấy rằng các hành động được đồng bộ hóa
giữa các CPU trở nên khó khăn khi số lượng lõi tăng lên. Đây là
cũng đúng đối với khả năng hệ thống đi vào trạng thái C cấp gói.

Để đảm bảo trình điều khiển intel_powerclamp có quy mô tốt, hãy trực tuyến
hiệu chuẩn được thực hiện. Mục tiêu của việc hiệu chỉnh như vậy
là:

a) xác định phạm vi hiệu quả của tỷ lệ phun không tải
b) xác định mức bồi thường cần thiết ở mỗi tỷ lệ mục tiêu

Mức đền bù cho mỗi tỷ lệ mục tiêu bao gồm hai phần:

a) bù lỗi trạng thái ổn định

Điều này nhằm bù đắp lỗi xảy ra khi hệ thống có thể
	   vào chế độ chờ mà không cần đánh thức thêm (chẳng hạn như các ngắt bên ngoài).

b) bù lỗi động

Khi xảy ra quá nhiều lần đánh thức trong lúc không hoạt động,
	   tỷ lệ nhàn rỗi bổ sung có thể được thêm vào các ngắt yên tĩnh, bằng cách
	   làm chậm hoạt động của CPU.

Tệp debugfs được cung cấp để người dùng kiểm tra mức bồi thường
tiến độ và kết quả, chẳng hạn như trên hệ thống Westmere::

[jacob@nex01 ~]$ con mèo
  /sys/kernel/debug/intel_powerclamp/powerclamp_calib
  CPU điều khiển: 0
  niềm tin pct năng động ổn định (bù đắp)
  0 0 0 0
  1 1 0 0
  2 1 1 0
  3 3 1 0
  4 3 1 0
  5 3 1 0
  6 3 1 0
  7 3 1 0
  8 3 1 0
  ...
30 3 2 0
  31 3 2 0
  32 3 1 0
  33 3 2 0
  34 3 1 0
  35 3 2 0
  36 3 1 0
  37 3 2 0
  38 3 1 0
  39 3 2 0
  40 3 3 0
  41 3 1 0
  42 3 2 0
  43 3 1 0
  44 3 1 0
  45 3 2 0
  46 3 3 0
  47 3 0 0
  48 3 2 0
  49 3 3 0

Hiệu chuẩn xảy ra trong thời gian chạy. Không có phương pháp ngoại tuyến có sẵn.
Việc bù trạng thái ổn định chỉ được sử dụng khi mức độ tin cậy của tất cả
các tỷ số liền kề đã đạt mức thỏa đáng. Mức độ tin cậy
được tích lũy dựa trên dữ liệu sạch được thu thập trong thời gian chạy. dữ liệu
được thu thập trong khoảng thời gian không bị gián đoạn thêm được coi là
sạch sẽ.

Để bù đắp cho lượng thời gian thức dậy quá nhiều khi không hoạt động, hãy bổ sung
thời gian nhàn rỗi được đưa vào khi phát hiện tình trạng như vậy. Hiện tại,
chúng tôi có một thuật toán đơn giản để tăng gấp đôi tỷ lệ tiêm. Một khả năng
cải tiến có thể là điều tiết IRQ vi phạm, chẳng hạn như trì hoãn
EOI cho các ngắt kích hoạt theo mức. Nhưng đó là một thách thức để trở thành
không xâm phạm vào bộ lập lịch hoặc mã lõi IRQ.


CPU Trực tuyến/Ngoại tuyến
------------------
Các luồng nhân Per-CPU được khởi động/dừng khi nhận
thông báo về các hoạt động cắm nóng CPU. Trình điều khiển intel_powerclamp
theo dõi việc kẹp các luồng nhân, ngay cả sau khi chúng được di chuyển
sang các CPU khác sau sự kiện ngoại tuyến CPU.


Phân tích hiệu suất
====================
Phần này mô tả dữ liệu hiệu suất chung được thu thập trên
nhiều hệ thống, bao gồm Westmere (80P) và Ivy Bridge (4P, 8P).

Hiệu quả và hạn chế
-----------------------------
Phạm vi tối đa cho phép tiêm không tải được giới hạn ở mức 50
phần trăm. Như đã đề cập trước đó, vì các ngắt được cho phép trong quá trình
buộc phải có thời gian nhàn rỗi, sự gián đoạn quá mức có thể dẫn đến ít
hiệu quả. Trường hợp cực đoan sẽ thực hiện ping -f để tạo
mạng bị ngập bị gián đoạn mà không có nhiều xác nhận CPU. Trong này
trong trường hợp đó, có thể thực hiện được rất ít việc từ các luồng tiêm nhàn rỗi. Trong hầu hết
trường hợp bình thường, chẳng hạn như scp một tập tin lớn, các ứng dụng có thể được điều chỉnh
bởi trình điều khiển powerclamp, vì việc làm chậm CPU cũng làm chậm
xử lý giao thức mạng, từ đó làm giảm các ngắt.

Khi các tham số điều khiển thay đổi trong thời gian chạy bởi CPU điều khiển, nó
có thể mất thêm một khoảng thời gian để các CPU còn lại bắt kịp
với những thay đổi. Trong thời gian này, quá trình chèn không tải không đồng bộ,
do đó không thể vào trạng thái gói C- ở tỷ lệ mong đợi. Nhưng
hiệu ứng này là nhỏ, trong hầu hết các trường hợp thay đổi theo mục tiêu
tỷ lệ được cập nhật ít thường xuyên hơn nhiều so với việc tiêm nhàn rỗi
tần số.

Khả năng mở rộng
-----------
Các thử nghiệm cũng cho thấy sự khác biệt nhỏ nhưng có thể đo lường được giữa 4P/8P.
Hệ thống Ivy Bridge và máy chủ Westmere 80P có tỷ lệ nhàn rỗi dưới 50%.
Cần phải bồi thường nhiều hơn cho Westmere với cùng số tiền
tỷ lệ nhàn rỗi mục tiêu. Mức bồi thường cũng tăng theo tỷ lệ không tải
trở nên lớn hơn. Lý do trên cho thấy sự cần thiết của
mã hiệu chuẩn.

Trên hệ thống IVB 8P, so với CPU ngoại tuyến, powerclamp có thể
đạt được hiệu suất tốt hơn tới 40% trên mỗi watt. (được đo bằng vòng quay
bộ đếm được tổng hợp trên mỗi luồng đếm CPU được sinh ra cho tất cả các lần chạy
CPU).

Cách sử dụng và giao diện
====================
Trình điều khiển powerclamp được đăng ký vào lớp nhiệt chung dưới dạng
thiết bị làm mát. Hiện tại, nó không bị ràng buộc với bất kỳ vùng nhiệt nào::

jacob@chromoly:/sys/class/thermal/cooling_device14$ grep . *
  cur_state:0
  trạng thái tối đa:50
  loại: intel_powerclamp

cur_state cho phép người dùng đặt tỷ lệ phần trăm nhàn rỗi mong muốn. Viết 0 vào
cur_state sẽ dừng việc tiêm không tải. Viết một giá trị từ 1 đến
max_state sẽ bắt đầu quá trình tiêm không tải. Đọc cur_state trả về
tỷ lệ phần trăm nhàn rỗi thực tế và hiện tại. Giá trị này có thể không giống nhau
do người dùng đặt trong tỷ lệ phần trăm nhàn rỗi hiện tại tùy thuộc vào khối lượng công việc
và bao gồm nhàn rỗi tự nhiên. Khi tính năng chèn không tải bị vô hiệu hóa, việc đọc
cur_state trả về giá trị -1 thay vì 0 để tránh nhầm lẫn
Trạng thái bận 100% với trạng thái bị vô hiệu hóa.

Cách sử dụng ví dụ:

- Để thêm 25% thời gian nhàn rỗi::

$ sudo sh -c "echo 25 > /sys/class/thermal/cooling_device80/cur_state

Nếu hệ thống không bận và đã có hơn 25% thời gian rảnh,
thì trình điều khiển powerclamp sẽ không bắt đầu chạy không tải. Sử dụng hàng đầu
sẽ không hiển thị các luồng hạt nhân tiêm nhàn rỗi.

Nếu hệ thống đang bận (kiểm tra vòng quay bên dưới) và có ít hơn 25% tự nhiên
trong thời gian nhàn rỗi, các luồng hạt nhân powerclamp sẽ thực hiện thao tác chèn không tải. Bị ép buộc
thời gian nhàn rỗi được tính là nhàn rỗi bình thường trong đường dẫn mã chung đó là
được coi là nhiệm vụ nhàn rỗi.

Trong ví dụ này, 24,1% không hoạt động được hiển thị. Điều này giúp người quản trị hệ thống hoặc
người dùng xác định nguyên nhân gây chậm khi trình điều khiển powerclamp đang hoạt động::


Nhiệm vụ: Tổng cộng 197, 1 chạy, 196 ngủ, 0 dừng, 0 zombie
  (Các) CPU: 71,2%us, 4,7%sy, 0,0%ni, 24,1%id, 0,0%wa, 0,0%hi, 0,0%si, 0,0%st
  Mem: tổng cộng 3943228k, 1689632k đã sử dụng, 2253596k miễn phí, bộ đệm 74960k
  Hoán đổi: tổng cộng 4087804k, 0k được sử dụng, 4087804k miễn phí, 945336k được lưu trong bộ nhớ đệm

PID USER PR NI VIRT RES SHR S %CPU %MEM TIME+ COMMAND
   3352 jacob 20 0 262m 644 428 S 286 0,0 0:17,16 quay
   3341 gốc -51 0 0 0 0 D 25 0.0 0:01.62 kidle_inject/0
   3344 gốc -51 0 0 0 0 D 25 0.0 0:01.60 kidle_inject/3
   3342 gốc -51 0 0 0 0 D 25 0.0 0:01.61 kidle_inject/1
   3343 gốc -51 0 0 0 0 D 25 0.0 0:01.60 kidle_inject/2
   2935 jacob 20 0 696m 125m 35m S 5 3.3 0:31.11 firefox
   1546 gốc 20 0 158m 20m 6640 S 3 0,5 0:26,97 Xorg
   2100 jacob 20 0 1223m 88m 30m S 3 2.3 0:23.68 tính

Các thử nghiệm đã chỉ ra rằng bằng cách sử dụng bộ điều khiển kẹp nguồn làm bộ phận làm mát
thiết bị, bộ điều khiển nhiệt không gian người dùng dựa trên PID có thể quản lý
kiểm soát nhiệt độ CPU một cách hiệu quả khi không có ảnh hưởng nhiệt khác
được thêm vào. Ví dụ: người dùng UltraBook có thể biên dịch kernel theo
nhiệt độ nhất định (dưới hầu hết các điểm ngắt hoạt động).

Thông số mô-đun
=================

ZZ0000ZZ (RW)
	Một mặt nạ bit của CPU để thêm vào khi không hoạt động. Định dạng của mặt nạ bit giống như
	được sử dụng trong các hệ thống con khác như trong /proc/irq/\*/smp_affinity. Mặt nạ là
	các nhóm 32 bit được phân tách bằng dấu phẩy. Mỗi CPU là một bit. Ví dụ cho 256
	Hệ thống CPU mặt nạ đầy đủ là:
	ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff,ffffffff

Mặt nạ ngoài cùng bên phải dành cho CPU 0-32.

ZZ0000ZZ (RW)
	Thời gian nhàn rỗi được đưa vào tối đa so với tổng tỷ lệ thời gian CPU tính bằng phạm vi phần trăm
	từ 1 đến 100. Ngay cả khi trạng thái tối đa của thiết bị làm mát luôn là 100 (100%),
	tham số này cho phép thêm giới hạn phần trăm nhàn rỗi tối đa. Mặc định là 50,
	để phù hợp với việc triển khai hiện tại của trình điều khiển powerclamp. Cũng không
	cho phép giá trị lớn hơn 75, nếu cpumask bao gồm mọi CPU có trong
	hệ thống.
