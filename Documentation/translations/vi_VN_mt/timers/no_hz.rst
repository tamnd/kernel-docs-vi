.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/timers/no_hz.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
NO_HZ: Giảm tích tắc đồng hồ lập lịch
=========================================


Tài liệu này mô tả các tùy chọn Kconfig và các tham số khởi động có thể
giảm số lần ngắt đồng hồ lập lịch, từ đó cải thiện năng lượng
hiệu quả và giảm jitter hệ điều hành.  Giảm jitter hệ điều hành là điều quan trọng đối với
một số loại tính toán hiệu năng cao chuyên sâu về tính toán (HPC)
ứng dụng và cho các ứng dụng thời gian thực.

Có ba cách chính để quản lý các ngắt đồng hồ lập lịch
(còn được gọi là "tích tắc đồng hồ lập lịch" hoặc đơn giản là "tích tắc"):

1. Không bao giờ bỏ qua các tích tắc của đồng hồ lập kế hoạch (CONFIG_HZ_PERIODIC=y hoặc
	CONFIG_NO_HZ=n cho các hạt nhân cũ hơn).  Thông thường bạn sẽ -không-
	muốn chọn tùy chọn này.

2. Bỏ qua các tích tắc lập lịch đồng hồ trên các CPU nhàn rỗi (CONFIG_NO_HZ_IDLE=y hoặc
	CONFIG_NO_HZ=y cho các hạt nhân cũ hơn).  Đây là điều phổ biến nhất
	cách tiếp cận này và phải là mặc định.

3. Bỏ qua các dấu tích đồng hồ lập lịch trên các CPU không hoạt động hoặc
	chỉ có một tác vụ có thể chạy được (CONFIG_NO_HZ_FULL=y).  Trừ khi bạn
	đang chạy các ứng dụng thời gian thực hoặc một số loại HPC nhất định
	khối lượng công việc, thông thường bạn sẽ -không- muốn tùy chọn này.

Ba trường hợp này được mô tả trong ba phần sau đây, tiếp theo là
bởi phần thứ ba về những cân nhắc dành riêng cho RCU, phần thứ tư
thảo luận về việc kiểm tra và phần thứ năm cũng là phần cuối cùng liệt kê các vấn đề đã biết.


Không bao giờ bỏ qua các tích tắc lập lịch-đồng hồ
==================================================

Các phiên bản Linux rất cũ từ những năm 1990 và đầu những năm 2000
không có khả năng bỏ qua tiếng tích tắc của đồng hồ lập kế hoạch.  Hoá ra là thế
có một số tình huống mà cách tiếp cận kiểu cũ này vẫn là phương pháp
cách tiếp cận đúng đắn, chẳng hạn như trong khối lượng công việc nặng nề với nhiều nhiệm vụ
sử dụng các đợt CPU ngắn, trong đó rất thường xuyên có thời gian rảnh
nhưng những khoảng thời gian nhàn rỗi này cũng khá ngắn (hàng chục hoặc
hàng trăm micro giây).  Đối với những loại khối lượng công việc này, việc lập kế hoạch
ngắt đồng hồ thường sẽ được phân phối bằng mọi cách vì có
thường sẽ có nhiều tác vụ có thể chạy được trên mỗi CPU.  Trong những trường hợp này,
cố gắng tắt ngắt đồng hồ lập lịch sẽ không có hiệu lực
ngoài việc tăng chi phí chuyển đổi sang và từ nhàn rỗi và
chuyển đổi giữa thực thi người dùng và kernel.

Có thể chọn chế độ hoạt động này bằng cách sử dụng CONFIG_HZ_PERIODIC=y (hoặc
CONFIG_NO_HZ=n cho các hạt nhân cũ hơn).

Tuy nhiên, nếu thay vào đó bạn đang chạy một khối lượng công việc nhẹ với thời gian rảnh dài
thời gian, việc không bỏ qua các ngắt đồng hồ lập lịch sẽ dẫn đến
tiêu thụ điện năng quá mức.  Điều này đặc biệt tệ khi chạy bằng pin
thiết bị, khiến tuổi thọ pin cực kỳ ngắn.  Nếu bạn
đang chạy khối lượng công việc nhẹ, do đó bạn nên đọc phần sau
phần.

Ngoài ra, nếu bạn đang chạy khối lượng công việc thời gian thực hoặc HPC
khối lượng công việc với thời gian lặp lại ngắn, việc ngắt đồng hồ lập lịch có thể
làm giảm hiệu suất ứng dụng của bạn.  Nếu điều này mô tả khối lượng công việc của bạn,
bạn nên đọc hai phần sau.


Bỏ qua các tích tắc lập lịch-đồng hồ cho CPU nhàn rỗi
=====================================================

Nếu CPU không hoạt động thì việc gửi đồng hồ lập lịch cho nó sẽ chẳng ích gì
ngắt lời.  Suy cho cùng, mục đích chính của việc ngắt đồng hồ lập lịch
là buộc CPU bận rộn chuyển sự chú ý của nó sang nhiều nhiệm vụ,
và CPU nhàn rỗi không có nhiệm vụ phải chuyển sự chú ý của nó sang.

Một CPU nhàn rỗi không nhận được các ngắt đồng hồ lập lịch được cho là
là "dyntick-idle", "ở chế độ dyntick-idle", "ở chế độ nohz" hoặc "đang chạy
không có cảm giác nhột".  Phần còn lại của tài liệu này sẽ sử dụng "chế độ không tải".

Tùy chọn CONFIG_NO_HZ_IDLE=y Kconfig khiến kernel tránh gửi
lập lịch ngắt đồng hồ đối với các CPU nhàn rỗi, điều này cực kỳ quan trọng
cả các thiết bị chạy bằng pin và các máy tính lớn được ảo hóa cao.
Một thiết bị chạy bằng pin chạy hạt nhân CONFIG_HZ_PERIODIC=y sẽ
pin của nó tiêu hao rất nhanh, nhanh gấp 2-3 lần so với
cùng một thiết bị chạy kernel CONFIG_NO_HZ_IDLE=y.  Một máy tính lớn đang chạy
1.500 phiên bản hệ điều hành có thể thấy rằng một nửa thời gian CPU của nó đã bị tiêu tốn bởi
ngắt đồng hồ lập kế hoạch không cần thiết.  Trong những tình huống này, có
là động lực mạnh mẽ để tránh gửi các ngắt đồng hồ lập lịch tới
CPU nhàn rỗi.  Điều đó nói lên rằng, chế độ dyntick-idle không miễn phí:

1. Nó tăng số lượng lệnh được thực hiện trên đường dẫn
	đến và đi từ vòng lặp nhàn rỗi.

2. Trên nhiều kiến trúc, chế độ dyntick-idle cũng làm tăng
	số lượng các hoạt động lập trình lại đồng hồ đắt tiền.

Do đó, các hệ thống có các hạn chế về phản hồi theo thời gian thực tích cực thường
chạy hạt nhân CONFIG_HZ_PERIODIC=y (hoặc CONFIG_NO_HZ=n cho hạt nhân cũ hơn)
để tránh làm giảm độ trễ chuyển đổi từ trạng thái nhàn rỗi.

Ngoài ra còn có tham số khởi động "nohz=" có thể được sử dụng để tắt
chế độ không hoạt động trong hạt nhân CONFIG_NO_HZ_IDLE=y bằng cách chỉ định "nohz=off".
Theo mặc định, hạt nhân CONFIG_NO_HZ_IDLE=y khởi động với "nohz=on", cho phép
chế độ dyntick-không tải.


Bỏ qua các tích tắc lập lịch-đồng hồ cho các CPU chỉ có một tác vụ có thể chạy được
===================================================================================

Nếu CPU chỉ có một tác vụ có thể chạy được thì việc gửi nó sẽ chẳng có ý nghĩa gì
đồng hồ lập lịch bị gián đoạn vì không có nhiệm vụ nào khác để chuyển sang.
Lưu ý rằng việc bỏ tích tắc đồng hồ lập lịch cho các CPU chỉ có một khả năng chạy được
task cũng ngụ ý bỏ qua chúng đối với các CPU nhàn rỗi.

Tùy chọn CONFIG_NO_HZ_FULL=y Kconfig khiến kernel tránh
gửi các ngắt đồng hồ lập lịch tới CPU bằng một tác vụ có thể chạy được,
và những CPU như vậy được gọi là "CPU thích ứng".  Điều này quan trọng
cho các ứng dụng có hạn chế phản hồi thời gian thực mạnh mẽ vì
nó cho phép họ cải thiện tối đa thời gian phản hồi trong trường hợp xấu nhất
khoảng thời gian ngắt của đồng hồ lập lịch.  Nó cũng quan trọng đối với
khối lượng công việc lặp lại ngắn đòi hỏi nhiều tính toán: Nếu bất kỳ CPU nào được
bị trì hoãn trong một lần lặp nhất định, tất cả các CPU khác sẽ buộc phải
chờ nhàn rỗi trong khi CPU bị trì hoãn kết thúc.  Do đó, độ trễ được nhân lên
ít hơn một so với số lượng CPU.  Trong những tình huống này, có
một lần nữa động lực mạnh mẽ để tránh gửi các ngắt đồng hồ lập lịch.

Theo mặc định, không có CPU nào sẽ là CPU thích ứng.  "Nohz_full="
tham số khởi động chỉ định CPU có dấu tích thích ứng.  Ví dụ,
"nohz_full=1,6-8" nói rằng CPU 1, 6, 7 và 8 phải là các CPU thích ứng
CPU.  Lưu ý rằng bạn bị cấm đánh dấu tất cả các CPU là
CPU đánh dấu thích ứng: Phải duy trì ít nhất một CPU không thích ứng
trực tuyến để xử lý các công việc chấm công nhằm đảm bảo rằng hệ thống
các cuộc gọi như gettimeofday() trả về các giá trị chính xác trên CPU đánh dấu thích ứng.
(Đây không phải là vấn đề đối với CONFIG_NO_HZ_IDLE=y vì không có
người dùng xử lý để quan sát sự chênh lệch nhỏ trong tốc độ xung nhịp.) Lưu ý rằng điều này
có nghĩa là hệ thống của bạn phải có ít nhất hai CPU để
CONFIG_NO_HZ_FULL=y để làm bất cứ điều gì cho bạn.

Cuối cùng, CPU có tính năng thích ứng phải được giảm tải lệnh gọi lại RCU.
Điều này được đề cập trong phần "RCU IMPLICATIONS" bên dưới.

Thông thường, CPU vẫn ở chế độ tích tắc thích ứng càng lâu càng tốt.
Đặc biệt, việc chuyển sang chế độ kernel không tự động thay đổi
chế độ.  Thay vào đó, CPU sẽ chỉ thoát khỏi chế độ đánh dấu thích ứng nếu cần,
ví dụ: nếu CPU đó xếp hàng gọi lại RCU.

Cũng giống như chế độ dyntick-idle, lợi ích của chế độ Adaptive-tick là
không đến miễn phí:

1. CONFIG_NO_HZ_FULL chọn CONFIG_NO_HZ_COMMON nên không chạy được
	tích tắc thích ứng mà không cần chạy dyntick không tải.  Sự phụ thuộc này
	kéo dài đến việc thực hiện, do đó tất cả các chi phí
	của CONFIG_NO_HZ_IDLE cũng do CONFIG_NO_HZ_FULL phát sinh.

2. Quá trình chuyển đổi người dùng/kernel đắt hơn một chút do
	với nhu cầu thông báo cho các hệ thống con kernel (chẳng hạn như RCU) về
	sự thay đổi trong chế độ.

3. Bộ hẹn giờ POSIX CPU ngăn CPU chuyển sang chế độ đánh dấu thích ứng.
	Các ứng dụng thời gian thực cần thực hiện hành động dựa trên thời gian CPU
	tiêu dùng cần phải sử dụng các phương tiện khác để làm việc đó.

4. Nếu có nhiều sự kiện hoàn thiện đang chờ xử lý hơn mức phần cứng có thể
	thích ứng, chúng thường được vận chuyển theo vòng tròn để thu thập
	tất cả chúng theo thời gian.  Chế độ đánh dấu thích ứng có thể ngăn chặn điều này
	việc quay vòng không xảy ra.  Điều này có thể sẽ được khắc phục bởi
	ngăn chặn các CPU có số lượng lớn các sự kiện hoàn hảo đang chờ xử lý
	vào chế độ đánh dấu thích ứng.

5. Thống kê bộ lập lịch cho CPU đánh dấu thích ứng có thể được tính toán
	hơi khác so với các CPU không thích ứng.
	Điều này có thể làm xáo trộn việc cân bằng tải của các tác vụ thời gian thực.

Mặc dù những cải tiến được mong đợi theo thời gian, nhưng các bước thích ứng khá
hữu ích cho nhiều loại ứng dụng thời gian thực và tính toán chuyên sâu.
Tuy nhiên, những hạn chế được liệt kê ở trên có nghĩa là các dấu tích thích ứng không nên
(chưa) được bật theo mặc định.


Ý nghĩa của RCU
================

Có những tình huống trong đó CPU nhàn rỗi không thể được phép
vào chế độ dyntick-idle hoặc chế độ Adaptive-tick, hầu hết
điều phổ biến là khi CPU đó có lệnh gọi lại RCU đang chờ xử lý.

Tránh điều này bằng cách giảm tải quá trình xử lý cuộc gọi lại RCU thành kthread "rcuo"
bằng cách sử dụng tùy chọn CONFIG_RCU_NOCB_CPU=y Kconfig.  Các CPU cụ thể để
giảm tải có thể được chọn bằng cách sử dụng tham số khởi động kernel "rcu_nocbs=",
chẳng hạn, lấy danh sách CPU và phạm vi CPU được phân tách bằng dấu phẩy,
"1,3-5" chọn CPU 1, 3, 4 và 5. Lưu ý rằng CPU được chỉ định bởi
tham số khởi động kernel "nohz_full" cũng được giảm tải.

Các CPU được giảm tải sẽ không bao giờ xếp hàng các lệnh gọi lại RCU và do đó RCU
không bao giờ ngăn cản các CPU đã giảm tải chuyển sang chế độ dyntick-idle
hoặc chế độ đánh dấu thích ứng.  Điều đó nói lên rằng, hãy lưu ý rằng việc sử dụng tùy thuộc vào không gian người dùng
ghim kthread "rcuo" vào CPU cụ thể nếu muốn.  Nếu không,
bộ lập lịch sẽ quyết định nơi chạy chúng, có thể có hoặc không
nơi bạn muốn chúng chạy.


Kiểm tra
========

Vì vậy, bạn kích hoạt tất cả các tính năng OS-jitter được mô tả trong tài liệu này,
nhưng không thấy bất kỳ thay đổi nào trong cách xử lý khối lượng công việc của bạn.  Đây có phải là vì
khối lượng công việc của bạn không bị ảnh hưởng nhiều bởi hiện tượng giật hệ điều hành, hay là do
có điều gì khác đang cản đường?  Phần này giúp trả lời câu hỏi này
bằng cách cung cấp bộ kiểm tra OS-jitter đơn giản, có sẵn trên chi nhánh
chủ của kho lưu trữ git sau:

git://git.kernel.org/pub/scm/linux/kernel/git/frederic/dynticks-testing.git

Sao chép kho lưu trữ này và làm theo hướng dẫn trong tệp README.
Quy trình kiểm tra này sẽ tạo ra dấu vết cho phép bạn đánh giá
liệu bạn có thành công trong việc loại bỏ hiện tượng jitter hệ điều hành khỏi hệ thống của mình hay không.
Nếu dấu vết này cho thấy bạn đã loại bỏ hiện tượng jitter hệ điều hành nhiều như hiện tại
có thể thì bạn có thể kết luận rằng khối lượng công việc của bạn không chỉ có thế
nhạy cảm với jitter hệ điều hành.

Lưu ý: bài kiểm tra này yêu cầu hệ thống của bạn phải có ít nhất hai CPU.
Hiện tại chúng tôi không có cách nào tốt để loại bỏ jitter hệ điều hành khỏi CPU đơn lẻ
hệ thống.


Sự cố đã biết
=============

* Dyntick-idle làm chậm quá trình chuyển đổi sang chế độ chờ một chút.
	Trong thực tế, đây không phải là một vấn đề ngoại trừ hầu hết
	khối lượng công việc thời gian thực phức tạp, có tùy chọn vô hiệu hóa
	chế độ dyntick-idle, một tùy chọn mà hầu hết họ đều sử dụng.  Tuy nhiên,
	một số khối lượng công việc chắc chắn sẽ muốn sử dụng các dấu tích thích ứng để
	loại bỏ độ trễ ngắt đồng hồ lập lịch.  Đây là một số
	các tùy chọn cho các khối lượng công việc này:

Một.	Sử dụng PMQOS từ không gian người dùng để thông báo kernel của bạn
		yêu cầu về độ trễ (ưu tiên).

b.	Trên hệ thống x86, hãy sử dụng tham số khởi động "idle=mwait".

c.	Trên hệ thống x86, hãy sử dụng "intel_idle.max_cstate=" để giới hạn
	` độ sâu trạng thái C tối đa.

d.	Trên hệ thống x86, hãy sử dụng tham số khởi động "idle=poll".
		Tuy nhiên, xin lưu ý rằng việc sử dụng tham số này có thể gây ra
		CPU của bạn quá nóng, điều này có thể gây ra hiện tượng tiết lưu nhiệt
		để giảm độ trễ của bạn -- và sự xuống cấp này có thể
		thậm chí còn tệ hơn cả tình trạng dyntick-idle.  Hơn nữa,
		thông số này vô hiệu hóa hiệu quả Chế độ Turbo trên Intel
		CPU, có thể làm giảm đáng kể hiệu suất tối đa.

* Các dấu hiệu thích ứng làm chậm quá trình chuyển đổi người dùng/kernel một chút.
	Điều này dự kiến sẽ không phải là một vấn đề đối với các máy tính chuyên sâu
	khối lượng công việc có ít sự chuyển đổi như vậy.  Điểm chuẩn cẩn thận
	sẽ được yêu cầu xác định liệu các khối lượng công việc khác có
	bị ảnh hưởng đáng kể bởi hiệu ứng này.

* Bọ thích ứng không làm gì trừ khi chỉ có một
	tác vụ có thể chạy được cho một CPU nhất định, mặc dù có một số
	trong các tình huống khác mà đồng hồ lập lịch không có tích tắc
	cần thiết.  Để đưa ra một ví dụ, hãy xem xét một chiếc CPU có một
	nhiệm vụ SCHED_FIFO có mức độ ưu tiên cao có thể chạy được và một số tùy ý
	nhiệm vụ SCHED_OTHER có mức độ ưu tiên thấp.  Trong trường hợp này, CPU là
	cần thiết để chạy tác vụ SCHED_FIFO cho đến khi nó chặn hoặc
	một số nhiệm vụ có mức độ ưu tiên cao hơn khác được đánh thức (hoặc được giao cho)
	chiếc CPU này, vì vậy việc gửi đồng hồ lập lịch chẳng ích gì
	làm gián đoạn CPU này.	Tuy nhiên, việc thực hiện hiện nay
	tuy nhiên vẫn gửi các ngắt đồng hồ lập lịch tới các CPU có
	Nhiệm vụ SCHED_FIFO có thể chạy được một lần và SCHED_OTHER có thể chạy được nhiều lần
	nhiệm vụ, mặc dù những ngắt này là không cần thiết.

Và ngay cả khi có nhiều tác vụ có thể chạy được trên một CPU nhất định,
	có rất ít ý nghĩa khi làm gián đoạn CPU đó cho đến khi hiện tại
	thời gian của tác vụ đang chạy hết hạn, điều này hầu như luôn xảy ra
	dài hơn thời gian của lần ngắt đồng hồ lập kế hoạch tiếp theo.

Việc xử lý tốt hơn những tình huống này là công việc trong tương lai.

* Cần phải khởi động lại để cấu hình lại cả chế độ chờ thích ứng và RCU
	giảm tải cuộc gọi lại.  Cấu hình lại thời gian chạy có thể được cung cấp
	tuy nhiên, nếu cần, do sự phức tạp của việc cấu hình lại RCU tại
	thời gian chạy, cần phải có một lý do chính đáng đáng kinh ngạc.
	Đặc biệt là bạn có tùy chọn đơn giản là
	chỉ cần giảm tải các lệnh gọi lại RCU khỏi tất cả các CPU và ghim chúng
	nơi bạn muốn chúng bất cứ khi nào bạn muốn chúng được ghim.

* Cần có cấu hình bổ sung để xử lý các nguồn khác
	của jitter hệ điều hành, bao gồm các ngắt và các tác vụ tiện ích hệ thống
	và các quá trình.  Cấu hình này thường liên quan đến việc ràng buộc
	ngắt và thực hiện nhiệm vụ cho các CPU cụ thể.

* Hiện tại, một số nguồn gây nhiễu loạn hệ điều hành chỉ có thể được loại bỏ bằng cách
	hạn chế khối lượng công việc.  Ví dụ, cách duy nhất để loại bỏ
	Hệ điều hành bị giật do sự cố TLB toàn cầu nhằm tránh việc hủy ánh xạ
	các hoạt động (chẳng hạn như các hoạt động dỡ bỏ mô-đun hạt nhân)
	dẫn đến những vụ bắn hạ này.  Một ví dụ khác, lỗi trang
	và lỗi TLB có thể được giảm bớt (và trong một số trường hợp được loại bỏ) bằng cách
	sử dụng các trang lớn và bằng cách hạn chế dung lượng bộ nhớ được sử dụng
	bởi ứng dụng.  Lỗi trước của bộ làm việc cũng có thể
	hữu ích, đặc biệt khi kết hợp với mlock() và mlockall()
	các cuộc gọi hệ thống.

* Trừ khi tất cả các CPU không hoạt động, ít nhất một CPU phải giữ nguyên
	lập kế hoạch ngắt đồng hồ để hỗ trợ chính xác
	chấm công.

* Nếu có khả năng có một số CPU có tính năng thích ứng, thì có
	sẽ có ít nhất một CPU duy trì ngắt đồng hồ lập lịch
	đang hoạt động, ngay cả khi tất cả các CPU đều không hoạt động.

Việc xử lý tốt hơn tình huống này đang được tiến hành.

* Một số hoạt động xử lý quy trình thỉnh thoảng vẫn yêu cầu
	lập lịch-tích tắc đồng hồ.	Các hoạt động này bao gồm tính toán CPU
	tải, duy trì mức trung bình theo lịch trình, tính toán thời gian chạy thực thể CFS,
	tính toán avenrun và thực hiện cân bằng tải.  Họ là
	hiện được cung cấp bằng cách lập lịch đồng hồ tích tắc mỗi giây
	hoặc như vậy.	Công việc đang diễn ra sẽ loại bỏ sự cần thiết ngay cả đối với những
	tiếng tích tắc của đồng hồ lập kế hoạch không thường xuyên.
