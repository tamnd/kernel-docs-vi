.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/cluster-pm-race-avoidance.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================
Thuật toán tránh cuộc đua tăng/tắt nguồn trên toàn cụm
==============================================================

Tệp này ghi lại thuật toán được sử dụng để phối hợp CPU và
các hoạt động thiết lập và phân chia cụm và để quản lý tính nhất quán của phần cứng
điều khiển một cách an toàn.

Phần "Cơ sở lý luận" giải thích thuật toán dùng để làm gì và tại sao
cần thiết.  "Mô hình cơ bản" giải thích các khái niệm chung bằng cách sử dụng chế độ xem đơn giản
của hệ thống.  Các phần khác giải thích chi tiết thực tế của
thuật toán đang sử dụng.


Cơ sở lý luận
---------

Trong một hệ thống có nhiều CPU, điều mong muốn là có
khả năng tắt từng CPU khi hệ thống không hoạt động, giảm
tiêu thụ điện năng và tản nhiệt.

Trong một hệ thống chứa nhiều cụm CPU, điều mong muốn là
để có khả năng tắt toàn bộ cụm.

Tắt và bật toàn bộ cụm là một công việc mạo hiểm, bởi vì nó
liên quan đến việc thực hiện các hoạt động có khả năng phá hoại ảnh hưởng đến một nhóm
CPU chạy độc lập trong khi hệ điều hành vẫn tiếp tục chạy.  Cái này
có nghĩa là chúng ta cần có sự phối hợp để đảm bảo rằng
các hoạt động ở cấp độ cụm chỉ được thực hiện khi thực sự an toàn
vậy.

Khóa đơn giản có thể không đủ để giải quyết vấn đề này, bởi vì
các cơ chế như spinlock của Linux có thể dựa vào các cơ chế mạch lạc
không được kích hoạt ngay lập tức khi một cụm bật nguồn.  Kể từ khi kích hoạt hoặc
việc vô hiệu hóa các cơ chế đó có thể là một hoạt động phi nguyên tử (chẳng hạn như
ghi một số thanh ghi phần cứng và vô hiệu hóa bộ đệm lớn), khác
Cần có các biện pháp phối hợp để đảm bảo an toàn
tắt nguồn và bật nguồn ở cấp độ cụm.

Cơ chế được trình bày trong tài liệu này mô tả một bộ nhớ mạch lạc
dựa trên giao thức để thực hiện sự phối hợp cần thiết.  Nó nhằm mục đích trở thành như
nhẹ nhất có thể, đồng thời cung cấp các đặc tính an toàn cần thiết.


Mô hình cơ bản
-----------

Mỗi cụm và CPU được gán một trạng thái như sau:

-DOWN
	-COMING_UP
	- LÊN
	-GOING_DOWN

::

+---------> LÊN ----------+
	    |                        v

COMING_UP GOING_DOWN

^ |
	    +-------- DOWN <--------+


DOWN:
	CPU hoặc cụm không mạch lạc và bị tắt nguồn hoặc
	bị đình chỉ hoặc sẵn sàng tắt nguồn hoặc tạm dừng.

COMING_UP:
	CPU hoặc cụm đã cam kết chuyển sang trạng thái UP.
	Nó có thể là một phần của quá trình khởi tạo và
	tạo điều kiện cho sự mạch lạc.

LÊN:
	CPU hoặc cụm đang hoạt động và mạch lạc ở phần cứng
	cấp độ.  CPU ở trạng thái này không nhất thiết phải được sử dụng
	tích cực bởi kernel.

GOING_DOWN:
	CPU hoặc cụm đã cam kết chuyển sang DOWN
	trạng thái.  Nó có thể là một phần của quá trình phân hủy và
	lối thoát mạch lạc.


Mỗi CPU được gán một trong các trạng thái này vào bất kỳ thời điểm nào.
Các trạng thái CPU được mô tả trong phần "Trạng thái CPU" bên dưới.

Mỗi cụm cũng được gán một trạng thái, nhưng cần phải phân chia
giá trị trạng thái thành hai phần (trạng thái "cụm" và trạng thái "vào") và
để giới thiệu các trạng thái bổ sung nhằm tránh các cuộc đua giữa các quốc gia khác nhau
Các CPU trong cụm đồng thời sửa đổi trạng thái.  Cụm-
trạng thái cấp độ được mô tả trong phần "Trạng thái cụm".

Để giúp phân biệt trạng thái CPU với trạng thái cụm trong phần này
thảo luận, tên trạng thái được đặt tiền tố ZZ0000ZZ cho các trạng thái CPU,
và tiền tố ZZ0001ZZ hoặc ZZ0002ZZ cho các trạng thái cụm.


Trạng thái CPU
---------

Trong thuật toán này, mỗi lõi riêng lẻ trong bộ xử lý đa lõi được
được gọi là "CPU".  CPU được coi là đơn luồng:
do đó, CPU chỉ có thể làm một việc tại một thời điểm.

Điều này có nghĩa là CPU rất phù hợp với mô hình cơ bản.

Thuật toán xác định các trạng thái sau cho mỗi CPU trong hệ thống:

-CPU_DOWN
	-CPU_COMING_UP
	-CPU_UP
	-CPU_GOING_DOWN

::

thiết lập cụm và
	Quyết định chính sách hoàn chỉnh thiết lập CPU
	      +----------->CPU_UP-------------+
	      |                                v

CPU_COMING_UP CPU_GOING_DOWN

^ |
	      +---------- CPU_DOWN <----------+
	 quyết định chính sách CPU đã hoàn tất việc phân tích
	hoặc sự kiện phần cứng


Các định nghĩa của bốn trạng thái tương ứng chặt chẽ với các trạng thái của
mô hình cơ bản.

Sự chuyển đổi giữa các trạng thái xảy ra như sau.

Một sự kiện kích hoạt (tự phát) có nghĩa là CPU có thể chuyển sang
trạng thái tiếp theo do chỉ đạt được tiến bộ cục bộ, không có
yêu cầu cho bất kỳ sự kiện bên ngoài nào xảy ra.


CPU_DOWN:
	CPU đạt trạng thái CPU_DOWN khi nó sẵn sàng
	tắt nguồn.  Khi đạt đến trạng thái này, CPU thường sẽ
	tự tắt nguồn hoặc tự tạm dừng thông qua lệnh WFI hoặc
	cuộc gọi phần mềm.

Trạng thái tiếp theo:
		CPU_COMING_UP
	Điều kiện:
		không có

Sự kiện kích hoạt:
		a) hoạt động bật nguồn phần cứng rõ ràng, dẫn đến
		   từ quyết định chính sách trên một chiếc CPU khác;

b) một sự kiện phần cứng, chẳng hạn như một sự gián đoạn.


CPU_COMING_UP:
	CPU không thể bắt đầu tham gia vào tính nhất quán phần cứng cho đến khi
	cụm được thiết lập và mạch lạc.  Nếu cụm chưa sẵn sàng,
	thì CPU sẽ đợi ở trạng thái CPU_COMING_UP cho đến khi
	cụm đã được thiết lập.

Trạng thái tiếp theo:
		CPU_UP
	Điều kiện:
		Cụm gốc của CPU phải nằm trong CLUSTER_UP.
	Sự kiện kích hoạt:
		Chuyển đổi cụm gốc sang CLUSTER_UP.

Tham khảo phần "Trạng thái cụm" để biết mô tả về
	Trạng thái CLUSTER_UP.


CPU_UP:
	Khi CPU đạt đến trạng thái CPU_UP, CPU có thể an toàn
	bắt đầu tham gia vào sự gắn kết địa phương.

Điều này được thực hiện bằng cách nhảy tới mã sơ yếu lý lịch CPU của kernel.

Lưu ý rằng định nghĩa của trạng thái này hơi khác một chút
	từ định nghĩa mô hình cơ bản: CPU_UP không có nghĩa là
	CPU vẫn mạch lạc nhưng điều đó có nghĩa là nó có thể tiếp tục an toàn
	hạt nhân.  Hạt nhân xử lý phần còn lại của sơ yếu lý lịch
	quy trình, do đó các bước còn lại sẽ không hiển thị như một phần của quy trình
	thuật toán tránh chủng tộc.

CPU vẫn ở trạng thái này cho đến khi có quyết định chính sách rõ ràng
	được thực hiện để tắt hoặc tạm dừng CPU.

Trạng thái tiếp theo:
		CPU_GOING_DOWN
	Điều kiện:
		không có
	Sự kiện kích hoạt:
		quyết định chính sách rõ ràng


CPU_GOING_DOWN:
	Khi ở trạng thái này, CPU thoát khỏi trạng thái kết hợp, bao gồm mọi
	các hoạt động cần thiết để đạt được điều này (chẳng hạn như làm sạch dữ liệu
	bộ nhớ đệm).

Trạng thái tiếp theo:
		CPU_DOWN
	Điều kiện:
		việc phân tích CPU cục bộ đã hoàn tất
	Sự kiện kích hoạt:
		(tự phát)


Trạng thái cụm
-------------

Cụm là một nhóm các CPU được kết nối với một số tài nguyên chung.
Bởi vì một cụm chứa nhiều CPU nên nó có thể thực hiện nhiều
mọi thứ cùng một lúc.  Điều này có một số ý nghĩa.  Đặc biệt, một
CPU có thể khởi động trong khi một CPU khác đang phá bỏ cụm.

Trong cuộc thảo luận này, "phía bên ngoài" là chế độ xem trạng thái cụm
như được thấy bởi một chiếc CPU đang xé nát cụm này.  “Bên vào” là
chế độ xem trạng thái cụm mà CPU nhìn thấy khi thiết lập CPU.

Để có thể phối hợp an toàn trong những tình huống như vậy, điều quan trọng là
rằng CPU đang thiết lập cụm có thể quảng cáo trạng thái của nó
độc lập với CPU đang phá bỏ cụm.  Vì điều này
lý do, trạng thái cụm được chia thành hai phần:

trạng thái "cụm": Trạng thái toàn cầu của cụm; hoặc nhà nước
	ở phía bên ngoài:

-CLUSTER_DOWN
		-CLUSTER_UP
		-CLUSTER_GOING_DOWN

trạng thái "inbound": Trạng thái của cụm ở phía gửi đến.

-INBOUND_NOT_COMING_UP
		-INBOUND_COMING_UP


Sự kết hợp khác nhau của các trạng thái này dẫn đến sáu khả năng
	trạng thái cho toàn bộ cụm::

CLUSTER_UP
	          +===========> INBOUND_NOT_COMING_UP -------------+
	          # |
	                                                          |
	     CLUSTER_UP <----+ |
	  INBOUND_COMING_UP |                                v

^ CLUSTER_GOING_DOWN CLUSTER_GOING_DOWN
	          #              ZZ0002ZZ <=== INBOUND_NOT_COMING_UP

CLUSTER_DOWN ZZ0000ZZ
	  INBOUND_COMING_UP <----+ |
	                                                          |
	          ^ |
	          +============ CLUSTER_DOWN <-------------+
	                       INBOUND_NOT_COMING_UP

Chuyển đổi -----> chỉ có thể được thực hiện bởi CPU đi và
	chỉ liên quan đến những thay đổi đối với trạng thái "cụm".

Việc chuyển đổi ===##> chỉ có thể được thực hiện bởi CPU gửi đến và chỉ
	liên quan đến những thay đổi đối với trạng thái "vào", trừ khi không có
	có thể chuyển đổi thêm ở phía bên ngoài (tức là,
	CPU gửi đi đã đưa cụm vào trạng thái CLUSTER_DOWN).

Thuật toán tránh cuộc đua không cung cấp cách xác định
	CPU chính xác nào trong cụm đóng những vai trò này.  Điều này phải
	được quyết định trước bằng một số phương tiện khác.  Tham khảo phần
	"Lựa chọn người đàn ông cuối cùng và người đàn ông đầu tiên" để được giải thích thêm.


CLUSTER_DOWN/INBOUND_NOT_COMING_UP là trạng thái duy nhất có
	cụm thực sự có thể được tắt nguồn.

Sự song song của CPU vào và ra được quan sát bởi
	sự tồn tại của hai đường dẫn khác nhau từ CLUSTER_GOING_DOWN/
	INBOUND_NOT_COMING_UP (tương ứng với GOING_DOWN ở dạng cơ bản
	mẫu) sang CLUSTER_DOWN/INBOUND_COMING_UP (tương ứng với
	COMING_UP trong mô hình cơ bản).  Đường dẫn thứ hai tránh cụm
	sự sụp đổ hoàn toàn.

CLUSTER_UP/INBOUND_COMING_UP tương đương với UP về cơ bản
	mô hình.  The final transition to CLUSTER_UP/INBOUND_NOT_COMING_UP
	là chuyện nhỏ và chỉ đơn thuần là thiết lập lại máy trạng thái sẵn sàng cho
	chu kỳ tiếp theo.

Chi tiết về các chuyển đổi được phép sau đây.

Trạng thái tiếp theo trong mỗi trường hợp được ký hiệu

<trạng thái cụm>/<trạng thái gửi đến> (<bộ chuyển tiếp>)

trong đó <transitioner> là phía mà quá trình chuyển đổi
	có thể xảy ra; bên trong hoặc bên ngoài.


CLUSTER_DOWN/INBOUND_NOT_COMING_UP:
	Trạng thái tiếp theo:
		CLUSTER_DOWN/INBOUND_COMING_UP (vào)
	Điều kiện:
		không có

Sự kiện kích hoạt:
		a) hoạt động bật nguồn phần cứng rõ ràng, dẫn đến
		   từ quyết định chính sách trên một chiếc CPU khác;

b) một sự kiện phần cứng, chẳng hạn như một sự gián đoạn.


CLUSTER_DOWN/INBOUND_COMING_UP:

Ở trạng thái này, CPU gửi đến sẽ thiết lập cụm, bao gồm
	cho phép gắn kết phần cứng ở cấp độ cụm và bất kỳ
	các hoạt động khác (chẳng hạn như vô hiệu hóa bộ đệm) được yêu cầu
	để đạt được điều này.

Mục đích của trạng thái này là thực hiện đủ các nhiệm vụ ở cấp độ cụm
	thiết lập để cho phép các CPU khác trong cụm có được sự gắn kết
	một cách an toàn.

Trạng thái tiếp theo:
		CLUSTER_UP/INBOUND_COMING_UP (vào)
	Điều kiện:
		thiết lập cấp độ cụm và hoàn tất sự gắn kết phần cứng
	Sự kiện kích hoạt:
		(tự phát)


CLUSTER_UP/INBOUND_COMING_UP:

Quá trình thiết lập ở cấp độ cụm đã hoàn tất và tính nhất quán của phần cứng đã được hoàn tất
	được kích hoạt cho cụm.  Các CPU khác trong cụm có thể an toàn
	nhập tính mạch lạc.

Đây là trạng thái nhất thời, dẫn ngay đến
	CLUSTER_UP/INBOUND_NOT_COMING_UP.  Tất cả các CPU khác trên cụm
	nên xem xét coi hai trạng thái này là tương đương.

Trạng thái tiếp theo:
		CLUSTER_UP/INBOUND_NOT_COMING_UP (vào)
	Điều kiện:
		không có
	Sự kiện kích hoạt:
		(tự phát)


CLUSTER_UP/INBOUND_NOT_COMING_UP:

Quá trình thiết lập ở cấp độ cụm đã hoàn tất và tính nhất quán của phần cứng đã được hoàn tất
	được kích hoạt cho cụm.  Các CPU khác trong cụm có thể an toàn
	nhập tính mạch lạc.

Cụm sẽ vẫn ở trạng thái này cho đến khi có quyết định chính sách
	được thực hiện để tắt nguồn của cụm.

Trạng thái tiếp theo:
		CLUSTER_GOING_DOWN/INBOUND_NOT_COMING_UP (đi)
	Điều kiện:
		không có
	Sự kiện kích hoạt:
		quyết định chính sách tắt nguồn cụm


CLUSTER_GOING_DOWN/INBOUND_NOT_COMING_UP:

Một CPU gửi đi đang phá hủy cụm.  CPU đã chọn
	phải đợi ở trạng thái này cho đến khi tất cả CPU trong cụm ở trạng thái
	Trạng thái CPU_DOWN.

Khi tất cả các CPU đều ở trạng thái CPU_DOWN, cluster có thể bị rách
	ngừng hoạt động, chẳng hạn bằng cách dọn dẹp bộ nhớ đệm dữ liệu và thoát
	tính nhất quán ở cấp độ cụm.

Để tránh các hoạt động xé bỏ lãng phí không cần thiết, đầu ra
	nên kiểm tra trạng thái cụm gửi đến xem có không đồng bộ không
	chuyển sang INBOUND_COMING_UP.  Ngoài ra, cá nhân
	CPU có thể được kiểm tra để vào CPU_COMING_UP hoặc CPU_UP.


Các trạng thái tiếp theo:

CLUSTER_DOWN/INBOUND_NOT_COMING_UP (đi)
		Điều kiện:
			cụm bị xé nát và sẵn sàng tắt nguồn
		Sự kiện kích hoạt:
			(tự phát)

CLUSTER_GOING_DOWN/INBOUND_COMING_UP (vào)
		Điều kiện:
			không có

Sự kiện kích hoạt:
			a) hoạt động bật nguồn phần cứng rõ ràng,
			   xuất phát từ một quyết định về chính sách đối với người khác
			   CPU;

b) một sự kiện phần cứng, chẳng hạn như một sự gián đoạn.


CLUSTER_GOING_DOWN/INBOUND_COMING_UP:

Cụm này đang (hoặc đã) bị phá bỏ, nhưng một chiếc CPU khác đã
	trực tuyến trong thời gian chờ đợi và đang cố gắng thiết lập cụm
	một lần nữa.

Nếu CPU gửi đi quan sát trạng thái này, nó có hai lựa chọn:

a) thoát khỏi tình trạng bị phá bỏ, khôi phục cụm về trạng thái ban đầu
		   Trạng thái CLUSTER_UP;

b) xé xong cụm xuống và đặt cụm vào
		   ở trạng thái CLUSTER_DOWN; CPU gửi đến sẽ
		   thiết lập lại cụm từ đó.

Lựa chọn (a) cho phép loại bỏ một số độ trễ bằng cách tránh
	các hoạt động thiết lập và chia nhỏ không cần thiết trong các tình huống
	cụm sẽ không thực sự bị tắt nguồn.


Các trạng thái tiếp theo:

CLUSTER_UP/INBOUND_COMING_UP (đi)
		Điều kiện:
				thiết lập và phần cứng cấp cụm
				mạch lạc hoàn thành

Sự kiện kích hoạt:
				(tự phát)

CLUSTER_DOWN/INBOUND_COMING_UP (đi)
		Điều kiện:
			cụm bị xé nát và sẵn sàng tắt nguồn

Sự kiện kích hoạt:
			(tự phát)


Lựa chọn người đàn ông cuối cùng và người đàn ông đầu tiên
--------------------------------

CPU thực hiện các thao tác chia nhỏ cụm ở phía bên ngoài
thường được gọi là "người đàn ông cuối cùng".

CPU thực hiện thiết lập cụm ở phía gửi đến thường
được mệnh danh là “người đàn ông đầu tiên”.

Thuật toán tránh cuộc đua được ghi lại ở trên không cung cấp
cơ chế để chọn CPU nào sẽ đóng những vai trò này.


Người đàn ông cuối cùng:

Khi tắt cụm, ban đầu tất cả các CPU có liên quan đều được
thực thi Linux và do đó mạch lạc.  Do đó, spinlocks thông thường có thể
được sử dụng để chọn người cuối cùng một cách an toàn, trước khi CPU trở nên
không mạch lạc.


Người đàn ông đầu tiên:

Bởi vì CPU có thể cấp nguồn không đồng bộ để đáp ứng với sự đánh thức bên ngoài
sự kiện, cần có một cơ chế động để đảm bảo rằng chỉ có một CPU
cố gắng đóng vai trò người đàn ông đầu tiên và thực hiện cấp độ cụm
khởi tạo: bất kỳ CPU nào khác phải đợi quá trình này hoàn tất trước khi
tiến hành.

Việc khởi tạo ở cấp độ cụm có thể bao gồm các hành động như cấu hình
điều khiển kết hợp trong kết cấu xe buýt.

Việc triển khai hiện tại trong mcpm_head.S sử dụng cơ chế loại trừ lẫn nhau riêng biệt
cơ chế thực hiện việc trọng tài này.  Cơ chế này được ghi lại trong
chi tiết trong vlocks.txt.


Tính năng và hạn chế
------------------------

Thực hiện:

Việc triển khai dựa trên ARM hiện tại được phân chia giữa
	Arch/arm/common/mcpm_head.S (các hoạt động CPU gửi đến ở mức độ thấp) và
	Arch/arm/common/mcpm_entry.c (mọi thứ khác):

__mcpm_cpu_ending_down() báo hiệu sự chuyển đổi của CPU sang
	Trạng thái CPU_GOING_DOWN.

__mcpm_cpu_down() báo hiệu sự chuyển đổi của CPU sang CPU_DOWN
	trạng thái.

CPU chuyển tiếp sang CPU_COMING_UP rồi đến CPU_UP thông qua
	mã tăng sức mạnh cấp thấp trong mcpm_head.S.  Điều này có thể
	liên quan đến mã thiết lập dành riêng cho CPU, nhưng hiện tại
	việc thực hiện nó không.

__mcpm_outbound_enter_critical() và __mcpm_outbound_leave_sensitive()
	xử lý quá trình chuyển đổi từ CLUSTER_UP sang CLUSTER_GOING_DOWN
	và từ đó đến CLUSTER_DOWN hoặc quay lại CLUSTER_UP (trong
	trường hợp tắt nguồn của cụm bị hủy bỏ).

Các hàm này phức tạp hơn __mcpm_cpu_*()
	hoạt động nhờ sự phối hợp giữa các CPU bổ sung
	là cần thiết để chuyển đổi an toàn ở cấp độ cụm.

Một cụm chuyển tiếp từ CLUSTER_DOWN trở lại CLUSTER_UP thông qua
	mã tăng sức mạnh cấp thấp trong mcpm_head.S.  Cái này
	thường liên quan đến mã thiết lập dành riêng cho nền tảng,
	được cung cấp bởi power_up_setup dành riêng cho nền tảng
	chức năng được đăng ký qua mcpm_sync_init.

Cấu trúc liên kết sâu:

Như được mô tả và triển khai hiện tại, thuật toán không
	hỗ trợ các cấu trúc liên kết CPU liên quan đến nhiều hơn hai cấp độ (nghĩa là
	cụm cụm không được hỗ trợ).  Thuật toán có thể là
	được mở rộng bằng cách sao chép các trạng thái cấp cụm cho
	các cấp độ tôpô bổ sung và sửa đổi quá trình chuyển đổi
	quy tắc cho các cấp độ cụm trung gian (không phải ngoài cùng).


colophon
--------

Được tạo ra và ghi lại lần đầu bởi Dave Martin cho Linaro Limited, trong
hợp tác với Nicolas Pitre và Achin Gupta.

Bản quyền (C) 2012-2013 Linaro Limited
Được phân phối theo các điều khoản của Phiên bản 2 của GNU General Public
Giấy phép, như được định nghĩa trong linux/COPYING.
