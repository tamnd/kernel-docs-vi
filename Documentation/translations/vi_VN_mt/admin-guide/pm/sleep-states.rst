.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/sleep-states.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

=====================
Trạng thái ngủ của hệ thống
===================

:Bản quyền: ZZ0000ZZ 2017 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Trạng thái ngủ là trạng thái năng lượng thấp toàn cầu của toàn bộ hệ thống mà người dùng
mã không gian không thể được thực thi và hoạt động tổng thể của hệ thống bị giảm đáng kể
giảm đi.


Các trạng thái ngủ có thể được hỗ trợ
==================================

Tùy thuộc vào cấu hình của nó và khả năng của nền tảng mà nó chạy trên đó,
nhân Linux có thể hỗ trợ tối đa bốn trạng thái ngủ của hệ thống, bao gồm
ngủ đông và tối đa ba biến thể của hệ thống tạm dừng.  Giấc ngủ nói rằng
có thể được hỗ trợ bởi kernel được liệt kê dưới đây.

.. _s2idle:

Tạm dừng để không hoạt động
---------------

Đây là một phần mềm chung, thuần túy, một biến thể nhẹ của hệ thống treo (cũng
được gọi là S2I hoặc S2Idle).  Nó cho phép tiết kiệm nhiều năng lượng hơn so với
thời gian chạy không hoạt động bằng cách đóng băng không gian người dùng, tạm dừng chấm công và đặt tất cả
thiết bị I/O sang trạng thái năng lượng thấp (có thể thấp hơn mức năng lượng sẵn có trong
trạng thái làm việc), sao cho bộ xử lý có thể dành thời gian ở trạng thái nhàn rỗi sâu nhất
trạng thái trong khi hệ thống bị đình chỉ.

Hệ thống được đánh thức khỏi trạng thái này bằng các ngắt trong băng tần, vì vậy về mặt lý thuyết
bất kỳ thiết bị nào có thể tạo ra ngắt ở trạng thái làm việc đều có thể
cũng được thiết lập làm thiết bị đánh thức cho S2Idle.

Trạng thái này có thể được sử dụng trên các nền tảng không hỗ trợ ZZ0000ZZ
hoặc ZZ0001ZZ, hoặc nó có thể được sử dụng cùng với bất kỳ
các biến thể tạm dừng hệ thống sâu hơn để giảm độ trễ tiếp tục.  Nó luôn luôn như vậy
được hỗ trợ nếu tùy chọn cấu hình kernel ZZ0002ZZ được đặt.

.. _standby:

Chế độ chờ
-------

Trạng thái này, nếu được hỗ trợ, sẽ mang lại mức tiết kiệm năng lượng vừa phải nhưng thực tế, trong khi
cung cấp một sự chuyển đổi tương đối đơn giản trở lại trạng thái làm việc.  Không
trạng thái vận hành bị mất (logic lõi hệ thống vẫn giữ lại nguồn), do đó hệ thống có thể
quay trở lại nơi nó đã dừng lại một cách dễ dàng.

Ngoài việc đóng băng không gian của người dùng, tạm dừng chấm công và đặt tất cả
Các thiết bị I/O chuyển sang trạng thái năng lượng thấp, điều này cũng được thực hiện cho ZZ0000ZZ, các CPU không khởi động được đưa ngoại tuyến và tất cả các chức năng hệ thống cấp thấp
bị đình chỉ trong quá trình chuyển sang trạng thái này.  Vì lý do này, nên
cho phép tiết kiệm nhiều năng lượng hơn so với ZZ0001ZZ, nhưng
độ trễ tiếp tục nói chung sẽ lớn hơn đối với trạng thái đó.

Bộ thiết bị có thể đánh thức hệ thống từ trạng thái này thường là
giảm so với ZZ0000ZZ và có thể cần phải
dựa vào nền tảng để thiết lập chức năng đánh thức cho phù hợp.

Trạng thái này được hỗ trợ nếu cấu hình kernel ZZ0000ZZ
tùy chọn được đặt và sự hỗ trợ cho nó được nền tảng đăng ký với
hệ thống lõi đình chỉ hệ thống con.  Trên các hệ thống dựa trên ACPI, trạng thái này được ánh xạ tới
trạng thái hệ thống S1 được xác định bởi ACPI.

.. _s2ram:

Đình chỉ-RAM
--------------

Trạng thái này (còn được gọi là STR hoặc S2RAM), nếu được hỗ trợ, sẽ cung cấp đáng kể
tiết kiệm năng lượng vì mọi thứ trong hệ thống đều được đưa vào trạng thái năng lượng thấp, ngoại trừ
cho bộ nhớ, cần được đặt ở chế độ tự làm mới để duy trì
nội dung.  Tất cả các bước thực hiện khi vào ZZ0000ZZ
cũng được thực hiện trong quá trình chuyển đổi sang S2RAM.  Các hoạt động bổ sung có thể
diễn ra tùy thuộc vào khả năng của nền tảng.  Đặc biệt, trên nền tảng ACPI
hệ thống hạt nhân chuyển quyền điều khiển cho phần sụn nền tảng (BIOS) là phần cuối cùng
bước trong quá trình chuyển đổi S2RAM và điều đó thường dẫn đến việc tắt nguồn một số
nhiều thành phần cấp thấp hơn không được kernel điều khiển trực tiếp.

Trạng thái của thiết bị và CPU được lưu và giữ trong bộ nhớ.  Tất cả các thiết bị đều
bị đình chỉ và đưa vào trạng thái năng lượng thấp.  Trong nhiều trường hợp, tất cả các bus ngoại vi
mất nguồn khi vào S2RAM nên thiết bị phải có khả năng xử lý quá trình chuyển đổi
trở lại trạng thái "bật".

Trên các hệ thống dựa trên ACPI, S2RAM yêu cầu một số mã đóng đai khởi động tối thiểu trong
phần sụn nền tảng để tiếp tục hệ thống từ nó.  Điều này có thể xảy ra ở trường hợp khác
nền tảng quá.

Bộ thiết bị có thể đánh thức hệ thống từ S2RAM thường bị giảm
liên quan đến ZZ0000ZZ và ZZ0001ZZ và nó
có thể cần phải dựa vào nền tảng để thiết lập chức năng đánh thức
sao cho phù hợp.

S2RAM được hỗ trợ nếu tùy chọn cấu hình kernel ZZ0000ZZ
được thiết lập và sự hỗ trợ cho nó được đăng ký bởi nền tảng với hệ thống cốt lõi
đình chỉ hệ thống con.  Trên các hệ thống dựa trên ACPI, nó được ánh xạ tới trạng thái hệ thống S3
được xác định bởi ACPI.

.. _hibernation:

ngủ đông
-----------

Trạng thái này (còn được gọi là Tạm dừng vào đĩa hoặc STD) cung cấp khả năng tốt nhất
tiết kiệm năng lượng và có thể được sử dụng ngay cả khi không có sự hỗ trợ nền tảng cấp thấp
để tạm dừng hệ thống.  Tuy nhiên, nó yêu cầu một số mã cấp thấp để tiếp tục quá trình
hệ thống hiện diện cho kiến trúc CPU cơ bản.

Ngủ đông khác biệt đáng kể so với bất kỳ biến thể đình chỉ hệ thống nào.
Phải mất ba lần thay đổi trạng thái hệ thống để đưa nó vào chế độ ngủ đông và hai lần thay đổi trạng thái hệ thống.
thay đổi trạng thái để tiếp tục nó.

Đầu tiên, khi chế độ ngủ đông được kích hoạt, kernel sẽ dừng mọi hoạt động của hệ thống và
tạo ra một ảnh chụp nhanh của bộ nhớ để ghi vào bộ lưu trữ liên tục.  Tiếp theo,
hệ thống chuyển sang trạng thái có thể lưu ảnh chụp nhanh, ảnh
được viết ra và cuối cùng hệ thống chuyển sang trạng thái năng lượng thấp mục tiêu trong
nguồn điện bị cắt ở hầu hết các thành phần phần cứng của nó, bao gồm cả bộ nhớ,
ngoại trừ một bộ thiết bị đánh thức hạn chế.

Khi ảnh chụp nhanh đã được ghi ra, hệ thống có thể nhập một
trạng thái năng lượng thấp đặc biệt (như ACPI S4) hoặc có thể đơn giản là nó có thể tự tắt nguồn.
Tắt nguồn có nghĩa là tiêu thụ điện năng tối thiểu và nó cho phép cơ chế này hoạt động bình thường
bất kỳ hệ thống nào.  Tuy nhiên, việc chuyển sang trạng thái năng lượng thấp đặc biệt có thể cho phép bổ sung
phương tiện đánh thức hệ thống sẽ được sử dụng (ví dụ: nhấn một phím trên bàn phím hoặc
mở nắp máy tính xách tay).

Sau khi thức dậy, quyền điều khiển sẽ chuyển đến phần sụn nền tảng chạy bộ tải khởi động
khởi động một phiên bản mới của kernel (điều khiển cũng có thể truy cập trực tiếp vào
bộ tải khởi động, tùy thuộc vào cấu hình hệ thống, nhưng dù sao nó cũng gây ra
một phiên bản mới của kernel sẽ được khởi động).  Phiên bản mới đó của kernel
(được gọi là ZZ0000ZZ) tìm kiếm hình ảnh ngủ đông trong
lưu trữ liên tục và nếu tìm thấy, nó sẽ được tải vào bộ nhớ.  Tiếp theo, tất cả
hoạt động trong hệ thống bị dừng và kernel khôi phục sẽ tự ghi đè bằng
nội dung hình ảnh và nhảy vào khu vực tấm bạt lò xo đặc biệt trong bản gốc
kernel được lưu trữ trong image (được gọi là ZZ0001ZZ), đây là nơi
cần có mã cấp thấp dành riêng cho kiến trúc đặc biệt.  Cuối cùng,
kernel image khôi phục hệ thống về trạng thái trước khi ngủ đông và cho phép người dùng
không gian để chạy lại.

Chế độ ngủ đông được hỗ trợ nếu kernel ZZ0000ZZ
tùy chọn cấu hình được thiết lập.  Tuy nhiên, tùy chọn này chỉ có thể được đặt nếu hỗ trợ
đối với kiến trúc CPU nhất định bao gồm mã cấp thấp cho sơ yếu lý lịch hệ thống.


Giao diện ZZ0000ZZ cơ bản để tạm dừng và ngủ đông hệ thống
=============================================================

Hệ thống con quản lý năng lượng cung cấp không gian người dùng với ZZ0002ZZ thống nhất
giao diện cho chế độ ngủ của hệ thống bất kể kiến trúc hệ thống cơ bản hay
nền tảng.  Giao diện đó nằm trong thư mục ZZ0000ZZ
(giả sử rằng ZZ0003ZZ được gắn tại ZZ0001ZZ) và nó bao gồm
các thuộc tính (tệp) sau:

ZZ0000ZZ
	Tệp này chứa danh sách các chuỗi biểu thị trạng thái ngủ được hỗ trợ
	bởi hạt nhân.  Viết một trong những chuỗi này vào nó sẽ khiến kernel
	để bắt đầu quá trình chuyển đổi hệ thống sang trạng thái ngủ được biểu thị bằng
	chuỗi đó.

Đặc biệt, các chuỗi "đĩa", "đóng băng" và "chờ" đại diện cho
	ZZ0000ZZ, ZZ0001ZZ và
	Trạng thái ngủ tương ứng của ZZ0002ZZ.  Chuỗi "mem"
	được diễn giải theo nội dung của tệp ZZ0003ZZ
	được mô tả dưới đây.

Nếu kernel không hỗ trợ bất kỳ trạng thái ngủ nào của hệ thống thì tệp này là
	không có mặt.

ZZ0000ZZ
	Tệp này chứa danh sách các chuỗi đại diện cho hệ thống được hỗ trợ
	tạm dừng các biến thể và cho phép không gian người dùng chọn biến thể
	được liên kết với chuỗi "mem" trong tệp ZZ0001ZZ được mô tả ở trên.

Các chuỗi có thể có trong tệp này là "s2idle", "shallow"
	và "sâu".  Chuỗi "s2idle" luôn đại diện cho ZZ0000ZZ và theo quy ước, chuỗi "nông" và "sâu" đại diện cho
	ZZ0001ZZ và ZZ0002ZZ,
	tương ứng.

Việc ghi một trong các chuỗi được liệt kê vào tệp này sẽ khiến hệ thống
	biến thể đình chỉ được đại diện bởi nó được liên kết với chuỗi "mem"
	trong tệp ZZ0000ZZ.  Chuỗi đại diện cho biến thể đình chỉ
	hiện được liên kết với chuỗi "mem" trong tệp ZZ0001ZZ là
	thể hiện trong dấu ngoặc vuông.

Nếu kernel không hỗ trợ hệ thống treo thì tệp này không có.

ZZ0000ZZ
	Tệp này kiểm soát chế độ hoạt động của chế độ ngủ đông (Tạm dừng vào đĩa).
	Cụ thể, nó cho kernel biết phải làm gì sau khi tạo một
	hình ảnh ngủ đông.

Đọc từ nó sẽ trả về danh sách các tùy chọn được hỗ trợ được mã hóa dưới dạng:

ZZ0000ZZ
		Đặt hệ thống vào trạng thái năng lượng thấp đặc biệt (ví dụ ACPI S4) để
		cung cấp các tùy chọn đánh thức bổ sung và có thể cho phép
		phần mềm nền tảng để thực hiện đường dẫn khởi tạo đơn giản hóa sau
		thức dậy.

Nó chỉ khả dụng nếu nền tảng cung cấp một dịch vụ đặc biệt
		cơ chế đưa hệ thống vào chế độ ngủ sau khi tạo
		hình ảnh ngủ đông (các nền tảng có ACPI thực hiện điều đó như một quy luật, đối với
		ví dụ).

ZZ0000ZZ
		Tắt nguồn hệ thống.

ZZ0000ZZ
		Khởi động lại hệ thống (hầu hết hữu ích cho việc chẩn đoán).

ZZ0000ZZ
		Hệ thống treo hybrid.  Đặt hệ thống vào chế độ ngủ tạm dừng
		trạng thái được chọn thông qua tệp ZZ0001ZZ được mô tả ở trên.
		Nếu hệ thống được đánh thức thành công từ trạng thái đó, hãy loại bỏ
		hình ảnh ngủ đông và tiếp tục.  Nếu không, hãy sử dụng hình ảnh
		để khôi phục lại trạng thái trước đó của hệ thống.

Nó có sẵn nếu hệ thống đình chỉ được hỗ trợ.

ZZ0000ZZ
		Hoạt động chẩn đoán.  Tải hình ảnh như thể hệ thống đã
		vừa thức dậy sau chế độ ngủ đông và kernel hiện đang chạy
		dụ là một kernel khôi phục và theo dõi toàn bộ hệ thống
		tiếp tục.

Viết một trong các chuỗi được liệt kê ở trên vào tệp này sẽ gây ra tùy chọn
	được đại diện bởi nó để được lựa chọn.

Tùy chọn hiện được chọn được hiển thị trong dấu ngoặc vuông, có nghĩa là
	rằng hoạt động được đại diện bởi nó sẽ được thực hiện sau khi tạo
	và lưu hình ảnh khi chế độ ngủ đông được kích hoạt bằng cách viết ZZ0001ZZ
	tới ZZ0000ZZ.

Nếu kernel không hỗ trợ chế độ ngủ đông thì tệp này không có.

ZZ0000ZZ
	Tập tin này kiểm soát kích thước của hình ảnh ngủ đông.

Nó có thể được viết một chuỗi biểu diễn một số nguyên không âm sẽ
	được sử dụng làm giới hạn trên nỗ lực tối đa của kích thước hình ảnh, tính bằng byte.  các
	lõi ngủ đông sẽ cố gắng hết sức để đảm bảo rằng kích thước hình ảnh sẽ không
	vượt quá con số đó, nhưng nếu điều đó trở nên không thể đạt được thì
	hình ảnh ngủ đông vẫn sẽ được tạo và kích thước của nó sẽ nhỏ như
	có thể.  Đặc biệt, việc ghi '0' vào tệp này sẽ gây ra kích thước của
	hình ảnh ngủ đông ở mức tối thiểu.

Việc đọc từ nó trả về giới hạn kích thước hình ảnh hiện tại, được đặt thành
	theo mặc định, khoảng 2/5 kích thước RAM có sẵn.

ZZ0000ZZ
	Tệp này kiểm soát cơ chế "theo dõi PM" lưu lần tạm dừng cuối cùng
	hoặc tiếp tục điểm sự kiện trong bộ nhớ RTC trong quá trình khởi động lại.  Nó giúp
	gỡ lỗi khóa cứng hoặc khởi động lại do xảy ra lỗi trình điều khiển thiết bị
	trong quá trình tạm dừng hoặc tiếp tục hệ thống (phổ biến hơn) hiệu quả hơn.

Nếu nó chứa "1", dấu vân tay của mỗi điểm sự kiện tạm dừng/tiếp tục
	lần lượt sẽ được lưu trữ trong bộ nhớ RTC (ghi đè RTC thực tế
	thông tin), vì vậy nó sẽ sống sót sau sự cố hệ thống nếu xảy ra đúng
	sau khi lưu trữ và nó có thể được sử dụng sau này để xác định trình điều khiển
	đã khiến vụ tai nạn xảy ra.

Nó chứa "0" theo mặc định, có thể thay đổi thành "1" bằng cách viết một
	chuỗi đại diện cho một số nguyên khác 0 vào đó.

Theo như trên, có hai cách để đưa hệ thống vào
Trạng thái ZZ0000ZZ.  Đầu tiên là viết "đóng băng"
trực tiếp tới ZZ0001ZZ.  Cách thứ hai là viết "s2idle" vào
ZZ0002ZZ và sau đó viết "mem" vào
ZZ0003ZZ.  Tương tự như vậy, có hai cách để làm cho hệ thống hoạt động
sang trạng thái ZZ0004ZZ (các chuỗi để ghi vào bộ điều khiển
các tệp trong trường hợp đó lần lượt là "chế độ chờ" hoặc "nông" và "mem) nếu điều đó
trạng thái được hỗ trợ bởi nền tảng.  Tuy nhiên, chỉ có một cách để làm cho
hệ thống chuyển sang trạng thái ZZ0005ZZ (viết "sâu" vào
ZZ0006ZZ và "mem" thành ZZ0007ZZ).

Biến thể tạm dừng mặc định (tức là biến thể được sử dụng mà không cần viết gì
vào ZZ0000ZZ) là "sâu" (trên phần lớn các hệ thống
hỗ trợ ZZ0001ZZ) hoặc "s2idle", nhưng nó có thể bị ghi đè
bằng giá trị của tham số ZZ0003ZZ trong dòng lệnh kernel.
Trên một số hệ thống có ACPI, tùy thuộc vào thông tin trong bảng ACPI,
mặc định có thể là "s2idle" ngay cả khi ZZ0002ZZ được hỗ trợ trong
nguyên tắc.