.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/power-management.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _usb-power-management:

Quản lý năng lượng cho USB
~~~~~~~~~~~~~~~~~~~~~~~~~~

:Tác giả: Alan Stern <stern@rowland.harvard.edu>
:Ngày: Cập nhật lần cuối: Tháng 2 năm 2014

..
	Contents:
	---------
	* What is Power Management?
	* What is Remote Wakeup?
	* When is a USB device idle?
	* Forms of dynamic PM
	* The user interface for dynamic PM
	* Changing the default idle-delay time
	* Warnings
	* The driver interface for Power Management
	* The driver interface for autosuspend and autoresume
	* Other parts of the driver interface
	* Mutual exclusion
	* Interaction between dynamic PM and system PM
	* xHCI hardware link PM
	* USB Port Power Control
	* User Interface for Port Power Control
	* Suggested Userspace Port Power Policy


Quản lý năng lượng là gì?
-------------------------

Quản lý năng lượng (PM) là thực hành tiết kiệm năng lượng bằng cách tạm dừng
các bộ phận của hệ thống máy tính khi chúng không được sử dụng.  Trong khi một
thành phần là ZZ0000ZZ nó ở trạng thái năng lượng thấp không hoạt động; nó
thậm chí có thể bị tắt hoàn toàn.  Một thành phần bị đình chỉ có thể
ZZ0001ZZ (trở lại trạng thái hoạt động hết công suất) khi kernel
cần sử dụng nó.  (Ngoài ra còn có các dạng PM trong đó các thành phần được
được đặt ở trạng thái ít chức năng hơn nhưng vẫn có thể sử dụng được thay vì
bị đình chỉ; một ví dụ là giảm tốc độ xung nhịp của CPU.  Cái này
tài liệu sẽ không thảo luận về các hình thức khác.)

Khi các bộ phận bị treo bao gồm CPU và hầu hết các bộ phận còn lại
hệ thống, chúng tôi gọi nó là "sự đình chỉ hệ thống".  Khi một điều cụ thể
thiết bị bị tắt trong khi toàn bộ hệ thống vẫn chạy, chúng tôi
gọi nó là "tạm dừng động" (còn được gọi là "tạm dừng thời gian chạy" hoặc
"đình chỉ có chọn lọc").  Tài liệu này tập trung chủ yếu vào cách
PM động được triển khai trong hệ thống con USB, mặc dù hệ thống PM được
được đề cập ở một mức độ nào đó (xem ZZ0000ZZ để biết thêm
thông tin về hệ thống PM).

Hỗ trợ PM hệ thống chỉ hiện diện nếu kernel được xây dựng bằng
Đã bật ZZ0000ZZ hoặc ZZ0001ZZ.  Hỗ trợ PM động

đối với USB luôn có mặt bất cứ khi nào
hạt nhân được xây dựng với kích hoạt ZZ0000ZZ.

[Trước đây, hỗ trợ PM động cho USB chỉ hiện diện nếu
kernel đã được xây dựng với kích hoạt ZZ0000ZZ (tùy thuộc vào
ZZ0001ZZ).  Bắt đầu với bản phát hành kernel 3.10, PM động
hỗ trợ cho USB luôn có mặt bất cứ khi nào kernel được xây dựng bằng
Đã bật ZZ0002ZZ.  Tùy chọn ZZ0003ZZ đã được
bị loại.]


Đánh thức từ xa là gì?
----------------------

Khi một thiết bị bị tạm dừng, nó thường không hoạt động trở lại cho đến khi
máy tính bảo nó làm như vậy.  Tương tự như vậy, nếu toàn bộ máy tính đã được
bị treo, nó thường không tiếp tục cho đến khi người dùng yêu cầu, chẳng hạn
bằng cách nhấn nút nguồn hoặc mở nắp.

Tuy nhiên, một số thiết bị có khả năng tự tiếp tục hoặc
yêu cầu kernel tiếp tục chúng hoặc thậm chí báo cho toàn bộ máy tính
để tiếp tục.  Khả năng này có nhiều tên như "Wake On
LAN"; chúng tôi sẽ gọi nó một cách tổng quát là "đánh thức từ xa".  Khi một
thiết bị được kích hoạt để đánh thức từ xa và nó bị treo, nó có thể tiếp tục
chính nó (hoặc gửi yêu cầu để được tiếp tục) để đáp lại một số yêu cầu bên ngoài
sự kiện.  Các ví dụ bao gồm bàn phím bị treo tiếp tục hoạt động khi một phím được
được nhấn hoặc trung tâm USB bị treo sẽ tiếp tục hoạt động khi thiết bị được cắm vào.


Khi nào thiết bị USB không hoạt động?
-------------------------------------

Một thiết bị ở trạng thái rảnh bất cứ khi nào hạt nhân cho rằng nó không bận làm việc
bất cứ điều gì quan trọng và do đó có thể bị đình chỉ.  các
định nghĩa chính xác phụ thuộc vào trình điều khiển của thiết bị; người lái xe được phép
để tuyên bố rằng một thiết bị không ở trạng thái rảnh ngay cả khi không có thiết bị thực sự
giao tiếp diễn ra.  (Ví dụ: một trung tâm không được coi là không hoạt động
trừ khi tất cả các thiết bị cắm vào trung tâm đó đã bị treo.)
Ngoài ra, một thiết bị không được coi là không hoạt động miễn là chương trình vẫn tiếp tục
tập tin usbfs của nó mở, cho dù có bất kỳ I/O nào đang diễn ra hay không.

Nếu thiết bị USB không có trình điều khiển, tệp usbfs của nó không mở được và không
được truy cập thông qua sysfs thì chắc chắn nó không hoạt động.


Các dạng PM động
-------------------

Đình chỉ động xảy ra khi kernel quyết định tạm dừng ở chế độ không hoạt động
thiết bị.  Cái này được gọi tắt là ZZ0000ZZ.  Nhìn chung, một thiết bị
sẽ không bị treo tự động trừ khi nó không hoạt động trong một khoảng thời gian tối thiểu
về thời gian, còn được gọi là thời gian trễ-không tải.

Tất nhiên, hạt nhân không tự mình làm bất cứ điều gì nên
ngăn cản máy tính hoặc các thiết bị của nó hoạt động bình thường.  Nếu một
thiết bị đã được tự động treo và một chương trình cố gắng sử dụng nó,
kernel sẽ tự động tiếp tục thiết bị (autoresume).  Đối với
lý do tương tự, một thiết bị được treo tự động thường sẽ có chế độ đánh thức từ xa
được bật nếu thiết bị hỗ trợ đánh thức từ xa.

Điều đáng nói là nhiều driver USB không hỗ trợ
tự động treo.  Trên thực tế, tại thời điểm viết bài này (Linux 2.6.23),
chỉ những trình điều khiển hỗ trợ nó là trình điều khiển trung tâm, kaweth, asix,
usblp, usblcd và usb-skeleton (không tính).  Nếu một
trình điều khiển không hỗ trợ sẽ bị ràng buộc với một thiết bị, thiết bị đó sẽ không được
tự động treo.  Trên thực tế, kernel giả vờ như thiết bị không bao giờ
nhàn rỗi.

Chúng ta có thể phân loại các sự kiện quản lý năng lượng thành hai loại lớn:
bên ngoài và bên trong.  Các sự kiện bên ngoài là những sự kiện được kích hoạt bởi một số
tác nhân bên ngoài ngăn xếp USB: tạm dừng/tiếp tục hệ thống (được kích hoạt bởi
không gian người dùng), sơ yếu lý lịch động thủ công (cũng được kích hoạt bởi không gian người dùng) và
đánh thức từ xa (được kích hoạt bởi thiết bị).  Các sự kiện nội bộ là những sự kiện
được kích hoạt trong ngăn xếp USB: autosuspend và autoresume.  Lưu ý rằng
tất cả các sự kiện tạm dừng động đều là nội bộ; tác nhân bên ngoài không
được phép ban hành lệnh đình chỉ động.


Giao diện người dùng cho PM động
---------------------------------

Giao diện người dùng để điều khiển PM động được đặt trong ZZ0000ZZ
thư mục con của thư mục sysfs của mỗi thiết bị USB, nghĩa là trong
ZZ0001ZZ trong đó "..." là ID của thiết bị.  các
các tệp thuộc tính có liên quan là: đánh thức, kiểm soát và
ZZ0002ZZ.  (Cũng có thể có một tệp có tên ZZ0003ZZ; tệp này
tập tin không được dùng nữa kể từ kernel 2.6.35 và được thay thế bằng
Tệp ZZ0004ZZ.  Trong 2.6.38, tệp ZZ0005ZZ sẽ không được dùng nữa
và được thay thế bằng tệp ZZ0006ZZ.  Sự khác biệt duy nhất
là tệp mới hơn biểu thị độ trễ tính bằng mili giây trong khi tệp
tập tin cũ hơn sử dụng giây.  Điều khó hiểu là cả hai tệp đều có trong 2.6.37
nhưng chỉ ZZ0007ZZ hoạt động.)

ZZ0000ZZ

Tập tin này trống nếu thiết bị không hỗ trợ
		thức dậy từ xa.  Nếu không thì tệp có chứa
		từ ZZ0000ZZ hoặc từ ZZ0001ZZ, và bạn có thể
		viết những từ đó vào tập tin.  Cài đặt xác định
		đánh thức từ xa có được bật hay không khi
		thiết bị sẽ bị đình chỉ tiếp theo.  (Nếu cài đặt được thay đổi
		trong khi thiết bị bị treo, thay đổi sẽ không được thực hiện
		có hiệu lực cho đến lần đình chỉ tiếp theo.)

ZZ0000ZZ

Tệp này chứa một trong hai từ: ZZ0000ZZ hoặc ZZ0001ZZ.
		Bạn có thể viết những từ đó vào tập tin để thay đổi
		cài đặt của thiết bị.

- ZZ0000ZZ có nghĩa là thiết bị sẽ được nối lại và
		  tự động treo không được phép.  (Tất nhiên, hệ thống
		  việc đình chỉ vẫn được cho phép.)

- ZZ0000ZZ là trạng thái bình thường của kernel
		  được phép tự động treo và tự động tiếp tục thiết bị.

(Trong các hạt nhân lên tới 2.6.32, bạn cũng có thể chỉ định
		ZZ0000ZZ, nghĩa là thiết bị sẽ vẫn được giữ nguyên
		bị đình chỉ và tự động tiếp tục không được phép.  Cái này
		cài đặt không còn được hỗ trợ.)

ZZ0000ZZ

Tệp này chứa một giá trị số nguyên, đó là
		số mili giây thiết bị sẽ không hoạt động
		trước khi hạt nhân tự động gửi nó (độ trễ nhàn rỗi
		thời gian).  Mặc định là 2000. 0 có nghĩa là tự động gửi
		ngay khi thiết bị không hoạt động và âm tính
		giá trị có nghĩa là không bao giờ tự động gửi.  Bạn có thể viết một
		số vào tập tin để thay đổi autosuspend
		thời gian nhàn rỗi-trễ.

Viết ZZ0000ZZ gửi ZZ0001ZZ và viết ZZ0002ZZ tới
ZZ0003ZZ về cơ bản thực hiện điều tương tự -- cả hai đều ngăn chặn
thiết bị không bị treo tự động.  Vâng, đây là sự dư thừa trong
API.

(Trong 2.6.21 việc ghi ZZ0000ZZ vào ZZ0001ZZ sẽ ngăn thiết bị
khỏi bị treo tự động; hành vi đã được thay đổi trong 2.6.22.  các
Thuộc tính ZZ0002ZZ không tồn tại trước 2.6.21 và
Thuộc tính ZZ0003ZZ không tồn tại trước phiên bản 2.6.22.  ZZ0004ZZ
đã được thêm vào trong 2.6.34 và ZZ0005ZZ đã được thêm vào
2.6.37 nhưng không hoạt động cho đến 2.6.38.)


Thay đổi thời gian trễ không hoạt động mặc định
-----------------------------------------------

Thời gian trễ không tải tự động treo mặc định (tính bằng giây) được kiểm soát bởi
một tham số mô-đun trong usbcore.  Bạn có thể chỉ định giá trị khi usbcore
được tải.  Ví dụ: để đặt thành 5 giây thay vì 2, bạn sẽ
làm::

modprobe usbcore autosuspend=5

Tương tự, bạn có thể thêm vào tệp cấu hình trong /etc/modprobe.d
một dòng nói::

tùy chọn usbcore autosuspend=5

Một số bản phân phối tải mô-đun usbcore từ rất sớm trong quá trình khởi động
quá trình, bằng một chương trình hoặc tập lệnh chạy từ initramfs
hình ảnh.  Để thay đổi giá trị tham số, bạn sẽ phải xây dựng lại giá trị đó
hình ảnh.

Nếu usbcore được biên dịch vào kernel thay vì được xây dựng dưới dạng có thể tải được
mô-đun, bạn có thể thêm ::

usbcore.autosuspend=5

vào dòng lệnh khởi động của kernel.

Cuối cùng, giá trị tham số có thể được thay đổi trong khi hệ thống
đang chạy.  Nếu bạn làm::

echo 5 >/sys/module/usbcore/parameter/autosuspend

thì mỗi thiết bị USB mới sẽ có độ trễ nhàn rỗi tự động treo
được khởi tạo thành 5. (Các giá trị độ trễ không hoạt động cho các thiết bị hiện có
sẽ không bị ảnh hưởng.)

Việc đặt độ trễ không hoạt động mặc định ban đầu thành -1 sẽ ngăn chặn bất kỳ
tự động treo của bất kỳ thiết bị USB nào.  Điều này có lợi ích là cho phép bạn
sau đó để bật tính năng tự động gửi cho các thiết bị đã chọn.


Cảnh báo
--------

Thông số kỹ thuật USB nêu rõ rằng tất cả các thiết bị USB phải hỗ trợ nguồn điện
quản lý.  Tuy nhiên, một thực tế đáng buồn là nhiều thiết bị không
hỗ trợ nó rất tốt.  Bạn có thể tạm dừng chúng lại, nhưng khi bạn
cố gắng tiếp tục lại chúng, chúng tự ngắt kết nối khỏi bus USB hoặc
họ ngừng hoạt động hoàn toàn.  Điều này dường như đặc biệt phổ biến
giữa máy in và máy quét, nhưng rất nhiều loại thiết bị khác có
sự thiếu hụt tương tự.

Vì lý do này, theo mặc định, kernel vô hiệu hóa tính năng tự động treo (
Thuộc tính ZZ0000ZZ được khởi tạo thành ZZ0001ZZ) cho tất cả các thiết bị khác
hơn các trung tâm.  Ít nhất, các trung tâm dường như hoạt động khá tốt trong
liên quan này.

(Trong 2.6.21 và 2.6.22 thì không như vậy. Tính năng tự động treo đã được bật
theo mặc định cho hầu hết tất cả các thiết bị USB.  Một số người đã trải nghiệm
kết quả là có vấn đề.)

Điều này có nghĩa là các thiết bị không phải là trung tâm sẽ không được tự động treo trừ khi người dùng
hoặc một chương trình rõ ràng cho phép nó.  Theo văn bản này không có
bất kỳ chương trình rộng rãi nào sẽ thực hiện việc này; chúng tôi hy vọng rằng trong thời gian gần
các nhà quản lý thiết bị trong tương lai như HAL sẽ đảm nhận việc bổ sung này
trách nhiệm.  Trong khi chờ đợi, bạn luôn có thể thực hiện
các thao tác cần thiết bằng tay hoặc thêm chúng vào tập lệnh udev.  bạn có thể
cũng thay đổi thời gian trễ không hoạt động; 2 giây không phải là lựa chọn tốt nhất cho
mọi thiết bị.

Nếu người lái xe biết rằng thiết bị của mình có hỗ trợ tạm dừng/tiếp tục phù hợp,
nó có thể tự kích hoạt tính năng tự động gửi.  Ví dụ, video
trình điều khiển cho webcam của máy tính xách tay có thể thực hiện việc này (trong các hạt nhân gần đây, chúng
làm), vì những thiết bị này hiếm khi được sử dụng và do đó thường nên được sử dụng
tự động treo.

Đôi khi hóa ra là ngay cả khi một thiết bị vẫn hoạt động tốt với
autosuspend vẫn có vấn đề.  Ví dụ: trình điều khiển usbhid,
quản lý bàn phím và chuột, có hỗ trợ tự động treo.  Thử nghiệm với
một số bàn phím cho thấy việc gõ trên bàn phím treo, trong khi
Tuy nhiên, việc đánh thức bàn phím từ xa sẽ ổn thôi
thường xuyên dẫn đến mất tổ hợp phím.  Các thử nghiệm trên chuột cho thấy một số
trong số họ sẽ đưa ra yêu cầu đánh thức từ xa để phản hồi nút
nhấn nhưng không chuyển động, và một số không phản ứng gì.

Kernel sẽ không ngăn bạn kích hoạt tính năng tự động treo trên thiết bị
điều đó không thể xử lý được.  Về mặt lý thuyết, thậm chí có thể làm hỏng một
thiết bị bằng cách tạm dừng nó không đúng lúc.  (Rất khó xảy ra, nhưng
có thể.) Hãy cẩn thận.


Giao diện trình điều khiển cho Quản lý nguồn
--------------------------------------------

Các yêu cầu đối với trình điều khiển USB để hỗ trợ quản lý nguồn điện bên ngoài
khá khiêm tốn; trình điều khiển chỉ cần xác định::

.đình chỉ
	.sơ yếu lý lịch
	.reset_resume

các phương thức trong cấu trúc ZZ0000ZZ của nó và phương thức ZZ0001ZZ
là tùy chọn.  Công việc của các phương pháp khá đơn giản:

- Phương thức ZZ0001ZZ được gọi để cảnh báo người lái xe rằng
	thiết bị sẽ bị đình chỉ.  Nếu người lái xe trả lại một
	mã lỗi âm, việc đình chỉ sẽ bị hủy bỏ.  Thông thường
	trình điều khiển sẽ trả về 0, trong trường hợp đó nó phải hủy tất cả
	URB chưa thanh toán (ZZ0000ZZ) và không gửi thêm nữa.

- Phương thức ZZ0000ZZ được gọi để thông báo cho trình điều khiển rằng
	thiết bị đã được nối lại và trình điều khiển có thể trở lại bình thường
	hoạt động.  URB có thể được gửi lại một lần nữa.

- Phương thức ZZ0000ZZ được gọi để thông báo cho trình điều khiển rằng
	thiết bị đã được nối lại và nó cũng đã được đặt lại.
	Trình điều khiển nên thực hiện lại mọi khởi tạo thiết bị cần thiết,
	vì thiết bị có thể đã mất hầu hết hoặc toàn bộ trạng thái
	(mặc dù các giao diện sẽ có cùng cài đặt thay thế như
	trước khi đình chỉ).

Nếu thiết bị bị ngắt kết nối hoặc tắt nguồn trong khi bị treo,
phương thức ZZ0000ZZ sẽ được gọi thay vì ZZ0001ZZ hoặc
Phương pháp ZZ0002ZZ.  Điều này cũng rất có thể xảy ra khi
thức dậy sau chế độ ngủ đông, vì nhiều hệ thống không duy trì trạng thái tạm dừng
hiện tại tới bộ điều khiển máy chủ USB trong thời gian ngủ đông.  (Đó là
có thể giải quyết vấn đề ngắt kết nối lực lượng ngủ đông bằng cách
sử dụng cơ sở USB Persist.)

Phương pháp ZZ0001ZZ được sử dụng bởi cơ sở USB Persist (xem
ZZ0000ZZ) và nó cũng có thể được sử dụng trong một số trường hợp nhất định
trường hợp khi ZZ0002ZZ không được kích hoạt.  Hiện nay, nếu một
thiết bị được đặt lại trong quá trình tiếp tục và trình điều khiển không có
ZZ0003ZZ, người lái xe sẽ không nhận được bất kỳ thông báo nào về
sơ yếu lý lịch.  Các hạt nhân sau này sẽ gọi phương thức ZZ0004ZZ của trình điều khiển;
2.6.23 không làm được điều này.

Trình điều khiển USB bị ràng buộc với các giao diện, vì vậy ZZ0000ZZ và ZZ0001ZZ của chúng
các phương thức được gọi khi giao diện bị tạm dừng hoặc được tiếp tục lại.  trong
nguyên tắc người ta có thể muốn tạm dừng một số giao diện trên thiết bị (ví dụ:
buộc các trình điều khiển cho giao diện đó dừng mọi hoạt động) mà không cần
đình chỉ các giao diện khác.  Lõi USB không cho phép điều này; tất cả
giao diện bị treo khi chính thiết bị bị treo và tất cả
giao diện được nối lại khi thiết bị được nối lại.  Điều đó là không thể
để tạm dừng hoặc tiếp tục một số nhưng không phải tất cả giao diện của thiết bị.  các
gần nhất bạn có thể làm là hủy liên kết trình điều khiển của giao diện.


Giao diện trình điều khiển cho autosuspend và autoresume
--------------------------------------------------------

Để hỗ trợ tính năng tự động gửi và tự động tiếp tục, trình điều khiển nên triển khai tất cả
ba trong số các phương pháp được liệt kê ở trên.  Ngoài ra, một người lái xe chỉ ra
rằng nó hỗ trợ tính năng tự động gửi bằng cách đặt cờ ZZ0000ZZ
trong cấu trúc usb_driver của nó.  Sau đó có trách nhiệm thông báo cho
Lõi USB bất cứ khi nào một trong các giao diện của nó trở nên bận hoặc không hoạt động.  các
trình điều khiển thực hiện điều đó bằng cách gọi sáu chức năng sau::

int usb_autopm_get_interface(struct usb_interface *intf);
	void usb_autopm_put_interface(struct usb_interface *intf);
	int usb_autopm_get_interface_async(struct usb_interface *intf);
	void usb_autopm_put_interface_async(struct usb_interface *intf);
	void usb_autopm_get_interface_no_resume(struct usb_interface *intf);
	void usb_autopm_put_interface_no_suspend(struct usb_interface *intf);

Các chức năng này hoạt động bằng cách duy trì bộ đếm mức sử dụng trong
Cấu trúc thiết bị nhúng của usb_interface.  Khi bộ đếm > 0
thì giao diện được coi là bận và kernel sẽ không
tự động treo thiết bị của giao diện.  Khi bộ đếm sử dụng là = 0
thì giao diện được coi là không hoạt động và kernel có thể
tự động treo thiết bị.

Người lái xe phải cẩn thận để cân bằng những thay đổi tổng thể của họ đối với việc sử dụng
quầy.  Các lệnh "get" không cân bằng sẽ vẫn có hiệu lực khi trình điều khiển
không bị ràng buộc khỏi giao diện của nó, ngăn không cho thiết bị đi vào
tạm dừng thời gian chạy nếu giao diện được liên kết lại với trình điều khiển.  Bật
mặt khác, người lái xe được phép đạt được sự cân bằng này bằng cách gọi
ZZ0000ZZ hoạt động ngay cả sau quy trình ZZ0001ZZ của chúng
đã quay trở lại -- chẳng hạn như từ trong quy trình xếp hàng công việc -- miễn là họ
giữ lại một tham chiếu hoạt động đến giao diện (thông qua ZZ0002ZZ và
ZZ0003ZZ).

Trình điều khiển sử dụng quy trình không đồng bộ phải chịu trách nhiệm về chính mình
đồng bộ hóa và loại trừ lẫn nhau.

ZZ0000ZZ tăng bộ đếm mức sử dụng và
	thực hiện tự động tiếp tục nếu thiết bị bị treo.  Nếu
	autoresume không thành công, bộ đếm bị giảm trở lại.

ZZ0000ZZ giảm bộ đếm sử dụng và
	thử tự động gửi nếu giá trị mới là = 0.

ZZ0000ZZ và
	ZZ0001ZZ thực hiện gần như những việc tương tự như
	các đối tác không đồng bộ của họ.  Sự khác biệt lớn nhất là họ
	sử dụng hàng đợi công việc để thực hiện sơ yếu lý lịch hoặc tạm dừng một phần công việc của họ
	việc làm.  Kết quả là chúng có thể được gọi trong bối cảnh nguyên tử,
	chẳng hạn như trình xử lý hoàn thành của URB, nhưng khi chúng trả về
	thiết bị nói chung sẽ chưa ở trạng thái mong muốn.

ZZ0000ZZ và
	ZZ0001ZZ chỉ tăng hoặc
	giảm bộ đếm sử dụng; họ không cố gắng thực hiện
	một autoresume hoặc một autosuspend.  Do đó chúng có thể được gọi vào
	một bối cảnh nguyên tử.

Kiểu sử dụng đơn giản nhất là trình điều khiển gọi
ZZ0000ZZ trong thói quen mở và
ZZ0001ZZ trong quy trình đóng hoặc giải phóng.  Nhưng khác
các mẫu có thể thực hiện được.

Các nỗ lực tự động treo được đề cập ở trên thường sẽ thất bại trong một
lý do này hay lý do khác.  Ví dụ: thuộc tính ZZ0000ZZ có thể là
được đặt thành ZZ0001ZZ hoặc giao diện khác trong cùng thiết bị có thể không được
nhàn rỗi.  Điều này là hoàn toàn bình thường.  Nếu lý do thất bại là vì
thiết bị không ở trạng thái rảnh đủ lâu, bộ hẹn giờ được lên lịch để
thực hiện thao tác tự động khi độ trễ nhàn rỗi tự động treo
đã hết hạn.

Các nỗ lực tự động tiếp tục cũng có thể thất bại, mặc dù thất bại có nghĩa là
thiết bị không còn tồn tại hoặc hoạt động bình thường nữa.  Không giống
tự động gửi, không có độ trễ nhàn rỗi đối với tính năng tự động tiếp tục.


Các phần khác của giao diện trình điều khiển
--------------------------------------------

Trình điều khiển có thể kích hoạt tính năng tự động treo cho thiết bị của họ bằng cách gọi ::

usb_enable_autosuspend(struct usb_device *udev);

trong quy trình ZZ0000ZZ của họ, nếu họ biết rằng thiết bị có khả năng
tạm dừng và tiếp tục một cách chính xác.  Điều này hoàn toàn tương đương với
ghi ZZ0001ZZ vào thuộc tính ZZ0002ZZ của thiết bị.  Tương tự như vậy,
trình điều khiển có thể vô hiệu hóa tính năng tự động gửi bằng cách gọi::

usb_disable_autosuspend(struct usb_device *udev);

Điều này hoàn toàn giống với việc ghi ZZ0000ZZ vào thuộc tính ZZ0001ZZ.

Đôi khi, trình điều khiển cần đảm bảo rằng tính năng đánh thức từ xa đã được bật
trong thời gian tự động treo.  Ví dụ, không có nhiều điểm
tự động treo bàn phím nếu người dùng không thể khiến bàn phím thực hiện
đánh thức từ xa bằng cách gõ vào nó.  Nếu trình điều khiển thiết lập
ZZ0000ZZ thành 1, hạt nhân sẽ không tự động treo
thiết bị nếu tính năng đánh thức từ xa không khả dụng.  (Nếu thiết bị đã
Tuy nhiên, được tự động treo, việc đặt cờ này sẽ không khiến kernel
tự động tiếp tục nó.  Thông thường trình điều khiển sẽ đặt cờ này trong ZZ0001ZZ của nó
phương pháp, tại thời điểm đó thiết bị được đảm bảo không bị
tự động treo.)

Nếu trình điều khiển thực hiện I/O không đồng bộ trong ngữ cảnh ngắt, nó
nên gọi ZZ0000ZZ trước khi bắt đầu xuất và
ZZ0001ZZ khi hàng đợi đầu ra cạn kiệt.  Khi nào
nó nhận được một sự kiện đầu vào, nó sẽ gọi ::

usb_mark_last_busy(struct usb_device *udev);

trong trình xử lý sự kiện.  Điều này cho lõi PM biết rằng thiết bị vừa mới được
bận và do đó, lần hết hạn tự động trì hoãn tiếp theo sẽ
bị đẩy lùi.  Nhiều thói quen usb_autopm_* cũng thực hiện cuộc gọi này,
vì vậy người lái xe chỉ cần lo lắng khi có đầu vào điều khiển ngắt.

Hoạt động không đồng bộ luôn phải chịu các cuộc đua.  Ví dụ, một
người lái xe có thể gọi quy trình ZZ0000ZZ tại một thời điểm
khi lõi vừa hoàn tất, quyết định thiết bị không hoạt động trong
đủ lâu nhưng vẫn chưa kịp gọi số ZZ0001ZZ của tài xế
phương pháp.  Phương thức ZZ0002ZZ phải chịu trách nhiệm đồng bộ hóa với
quy trình yêu cầu I/O và trình xử lý hoàn thành URB; nó nên
gây ra lỗi tự động treo với -EBUSY nếu trình điều khiển cần sử dụng
thiết bị.

Các cuộc gọi tạm dừng bên ngoài không bao giờ được phép thất bại theo cách này,
chỉ tự động tạm dừng cuộc gọi.  Người lái xe có thể phân biệt chúng bằng cách áp dụng
macro ZZ0000ZZ vào đối số thông báo tới ZZ0001ZZ
phương pháp; nó sẽ trả về True cho các sự kiện PM nội bộ (autosuspend) và
Sai đối với các sự kiện PM bên ngoài.


Loại trừ lẫn nhau
-----------------

Đối với các sự kiện bên ngoài -- nhưng không nhất thiết dành cho việc tự động treo hoặc
autoresume -- semaphore của thiết bị (udev->dev.sem) sẽ được giữ khi
Phương thức ZZ0000ZZ hoặc ZZ0001ZZ được gọi.  Điều này ngụ ý rằng bên ngoài
các sự kiện tạm dừng/tiếp tục loại trừ lẫn nhau với các lệnh gọi tới ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ; lõi USB đảm bảo rằng
điều này cũng đúng với các sự kiện autosuspend/autoresume.

Nếu người lái xe muốn chặn tất cả các cuộc gọi tạm dừng/tiếp tục trong một số thời điểm
phần quan trọng, cách tốt nhất là khóa máy và gọi
ZZ0000ZZ (và làm ngược lại ở cuối
phần quan trọng).  Giữ semaphore của thiết bị sẽ chặn tất cả
các cuộc gọi PM bên ngoài và ZZ0001ZZ sẽ ngăn chặn mọi cuộc gọi
cuộc gọi PM nội bộ, ngay cả khi nó thất bại.  (Bài tập: Tại sao?)


Tương tác giữa PM động và PM hệ thống
--------------------------------------------

Quản lý năng lượng động và quản lý năng lượng hệ thống có thể tương tác trong
một vài cách.

Thứ nhất, một thiết bị có thể đã được tự động tạm dừng khi hệ thống tạm dừng
xảy ra.  Vì việc tạm dừng hệ thống được cho là minh bạch như
có thể, thiết bị sẽ vẫn bị treo theo hệ thống
tiếp tục.  Nhưng lý thuyết này có thể không áp dụng tốt trong thực tế; theo thời gian
hành vi của kernel về vấn đề này đã thay đổi.  Kể từ ngày 2.6.37,
chính sách là tiếp tục lại tất cả các thiết bị trong quá trình hệ thống tiếp tục và để chúng
xử lý việc tạm dừng thời gian chạy của chính họ sau đó.

Thứ hai, một sự kiện quản lý năng lượng động có thể xảy ra khi một hệ thống
đình chỉ đang được tiến hành.  Khoảng thời gian cho việc này rất ngắn, vì hệ thống
việc đình chỉ không mất nhiều thời gian (thường là vài giây), nhưng nó có thể xảy ra.
Ví dụ: một thiết bị bị treo có thể gửi tín hiệu đánh thức từ xa trong khi
hệ thống đang tạm dừng.  Việc đánh thức từ xa có thể thành công, điều này sẽ
khiến hệ thống tạm dừng để hủy bỏ.  Nếu đánh thức từ xa không
thành công, nó có thể vẫn còn hoạt động và do đó khiến hệ thống
tiếp tục ngay sau khi quá trình tạm dừng hệ thống hoàn tất.  Hoặc điều khiển từ xa
việc thức dậy có thể thất bại và bị lạc.  Kết quả nào xảy ra phụ thuộc vào thời gian
và về thiết kế phần cứng và phần sụn.


Liên kết phần cứng xHCI PM
--------------------------

Bộ điều khiển máy chủ xHCI cung cấp khả năng quản lý nguồn liên kết phần cứng tới usb2.0
(tính năng xHCI 1.0) và các thiết bị usb3.0 hỗ trợ link PM. Bởi
kích hoạt phần cứng LPM, máy chủ có thể tự động đưa thiết bị vào
trạng thái năng lượng thấp hơn (L1 cho thiết bị usb2.0 hoặc U1/U2 cho thiết bị usb3.0),
thiết bị trạng thái nào có thể vào và tiếp tục rất nhanh.

Giao diện người dùng để điều khiển phần cứng LPM nằm trong
Thư mục con ZZ0000ZZ của thư mục sysfs của mỗi thiết bị USB, nghĩa là trong
ZZ0001ZZ trong đó "..." là ID của thiết bị. các
các tệp thuộc tính có liên quan là ZZ0002ZZ và ZZ0003ZZ.

ZZ0000ZZ

Khi thiết bị USB2 hỗ trợ LPM được cắm vào
		Hub gốc máy chủ xHCI hỗ trợ phần mềm LPM,
		máy chủ sẽ chạy thử nghiệm phần mềm LPM cho nó; nếu thiết bị
		vào trạng thái L1 và tiếp tục thành công và máy chủ
		hỗ trợ phần cứng USB2 LPM, tập tin này sẽ hiển thị và
		trình điều khiển sẽ kích hoạt phần cứng LPM cho thiết bị. bạn
		có thể ghi y/Y/1 hoặc n/N/0 vào tập tin để bật/tắt
		Phần cứng USB2 LPM theo cách thủ công. Đây là mục đích thử nghiệm chủ yếu.

ZZ0000ZZ
	ZZ0001ZZ

Khi thiết bị có khả năng USB 3.0 lpm được cắm vào ổ cắm
		Máy chủ xHCI hỗ trợ liên kết PM, nó sẽ kiểm tra xem U1
		và độ trễ thoát U2 đã được đặt trong BOS
		mô tả; nếu kiểm tra được thông qua và máy chủ
		hỗ trợ phần cứng USB3 LPM, phần cứng USB3 LPM sẽ
		được bật cho thiết bị và các tệp này sẽ được tạo.
		Các tệp giữ một giá trị chuỗi (bật hoặc tắt)
		cho biết phần cứng USB3 LPM U1 hay U2
		được kích hoạt cho thiết bị.

Điều khiển nguồn cổng USB
-------------------------

Ngoài việc tạm dừng các thiết bị đầu cuối và cho phép phần cứng
quản lý năng lượng liên kết được kiểm soát, hệ thống con USB cũng có
khả năng vô hiệu hóa nguồn điện cho các cổng trong một số điều kiện.  Quyền lực là
được điều khiển thông qua các yêu cầu ZZ0000ZZ tới một trung tâm.
Trong trường hợp trung tâm gốc hoặc nền tảng nội bộ, bộ điều khiển máy chủ
trình điều khiển chuyển các yêu cầu ZZ0001ZZ sang phần sụn nền tảng (ACPI)
gọi phương thức để thiết lập trạng thái nguồn của cổng. Để biết thêm thông tin, hãy xem
Hội nghị thợ sửa ống nước Linux 2012 slide [#f1]_ và video [#f2]_:

Khi nhận được yêu cầu ZZ0000ZZ, cổng USB sẽ được
tắt một cách logic và có thể gây ra sự mất mát thực sự của VBUS đối với cổng [#f3]_.
VBUS có thể được duy trì trong trường hợp một hub kết hợp nhiều cổng vào
một giếng quyền lực được chia sẻ khiến quyền lực được duy trì cho đến khi tất cả các cổng trong nhóm
bị tắt.  VBUS cũng có thể được duy trì bởi các cổng trung tâm được cấu hình cho
một ứng dụng sạc.  Trong mọi trường hợp, một cổng tắt hợp lý sẽ bị mất
kết nối với thiết bị của nó, không phản hồi với các sự kiện cắm nóng và không
đáp ứng các sự kiện đánh thức từ xa.

.. warning::

   turning off a port may result in the inability to hot add a device.
   Please see "User Interface for Port Power Control" for details.

Về tác động lên bản thân thiết bị, nó tương tự như tác dụng của một thiết bị
trải qua trong quá trình hệ thống tạm dừng, tức là phiên cấp nguồn bị mất.  bất kỳ
Thiết bị hoặc trình điều khiển USB hoạt động sai khi tạm dừng hệ thống sẽ bị
bị ảnh hưởng tương tự bởi sự kiện chu kỳ nguồn điện của cổng.  Vì lý do này
việc triển khai chia sẻ cùng một đường dẫn khôi phục thiết bị (và tôn vinh cùng một đường dẫn
quirks) làm đường dẫn tiếp tục hệ thống cho trung tâm.

.. [#f1]

  http://dl.dropbox.com/u/96820575/sarah-sharp-lpt-port-power-off2-mini.pdf

.. [#f2]

  http://linuxplumbers.ubicast.tv/videos/usb-port-power-off-kerneluserspace-api/

.. [#f3]

  USB 3.1 Section 10.12

  wakeup note: if a device is configured to send wakeup events the port
  power control implementation will block poweroff attempts on that
  port.


Giao diện người dùng để điều khiển nguồn cổng
---------------------------------------------

Cơ chế điều khiển nguồn cổng sử dụng hệ thống thời gian chạy PM.  Tắt nguồn là
được yêu cầu bằng cách xóa cờ ZZ0000ZZ của thiết bị cổng
(mặc định là 1).  Nếu cổng bị ngắt kết nối, nó sẽ ngay lập tức nhận được một
Yêu cầu ZZ0001ZZ.  Nếu không thì sẽ vinh danh chiều
quy tắc thời gian chạy và yêu cầu thiết bị con đính kèm cũng như tất cả thiết bị con cháu phải
bị đình chỉ. Cơ chế này phụ thuộc vào sức mạnh của cổng quảng cáo trung tâm
chuyển đổi trong bộ mô tả trung tâm của nó (chuyển đổi nguồn logic wHubCharacteristics
trường chế độ).

Lưu ý, một số thiết bị/trình điều khiển giao diện không hỗ trợ tính năng tự động treo.  Không gian người dùng có thể
cần hủy liên kết trình điều khiển giao diện trước khi ZZ0000ZZ thực hiện
đình chỉ.  Theo mặc định, một thiết bị giao diện không liên kết sẽ bị treo.  Khi cởi trói,
hãy cẩn thận để hủy liên kết trình điều khiển giao diện, không phải trình điều khiển của usb gốc
thiết bị.  Ngoài ra, hãy để các trình điều khiển giao diện trung tâm bị ràng buộc.  Nếu có driver cho usb
thiết bị (không phải giao diện) không được liên kết, kernel không thể tiếp tục quá trình
thiết bị.  Nếu trình điều khiển giao diện trung tâm không bị ràng buộc, việc kiểm soát các cổng con của nó sẽ bị hủy bỏ.
bị mất và tất cả các thiết bị con kèm theo sẽ ngắt kết nối.  Một nguyên tắc nhỏ là
rằng nếu liên kết 'trình điều khiển/mô-đun' của một thiết bị trỏ đến
ZZ0001ZZ sau đó hủy liên kết nó sẽ ảnh hưởng đến nguồn điện của cổng
kiểm soát.

Ví dụ về các tập tin có liên quan để kiểm soát nguồn điện cổng.  Lưu ý, trong ví dụ này
những tệp này có liên quan đến thiết bị trung tâm usb (tiền tố)::

tiền tố=/sys/devices/pci0000:00/0000:00:14.0/usb3/3-1

thiết bị con đính kèm +
                  thiết bị cổng trung tâm + |
     thiết bị giao diện trung tâm + ZZ0000ZZ
                          v v v
                  tiền tố $/3-1:1.0/3-1-port1/thiết bị

$prefix/3-1:1.0/3-1-port1/power/pm_qos_no_power_off
     $prefix/3-1:1.0/3-1-port1/device/power/control
     $prefix/3-1:1.0/3-1-port1/device/3-1.1:<intf0>/driver/unbind
     $prefix/3-1:1.0/3-1-port1/device/3-1.1:<intf1>/driver/unbind
     ...
$prefix/3-1:1.0/3-1-port1/device/3-1.1:<intfN>/driver/unbind

Ngoài các tệp này, một số cổng có thể có liên kết 'ngang hàng' tới một cổng trên
một trung tâm khác.  Kỳ vọng là tất cả các cổng siêu tốc đều có
ngang hàng tốc độ cao::

$prefix/3-1:1.0/3-1-port1/peer -> ../../../usb2/2-1/2-1:1.0/2-1-port1
  ../../../../usb2/2-1/2-1:1.0/2-1-port1/peer -> ../../../../usb3/3-1/3-1:1.0/3-1-port1

Khác biệt với 'cổng đồng hành' hoặc 'cổng chuyển đổi chia sẻ ehci/xhci'
cổng ngang hàng chỉ đơn giản là các chân giao diện tốc độ cao và siêu tốc
được kết hợp thành một đầu nối usb3 duy nhất.  Các cổng ngang hàng chia sẻ giống nhau
thiết bị XHCI tổ tiên.

Trong khi cổng siêu tốc bị tắt, thiết bị có thể hạ cấp cổng đó
kết nối và cố gắng kết nối với các chân tốc độ cao.  các
việc triển khai thực hiện các bước để ngăn chặn điều này:

1. Việc tạm dừng cổng được sắp xếp theo trình tự để đảm bảo rằng các cổng tốc độ cao bị tắt nguồn
   trước khi thiết bị ngang hàng siêu tốc của chúng được phép tắt nguồn.  Ý nghĩa là
   rằng việc cài đặt ZZ0000ZZ về 0 trên cổng siêu tốc có thể
   không làm cho cổng tắt nguồn cho đến khi cổng ngang hàng tốc độ cao của nó đã đi đến
   trạng thái tạm dừng thời gian chạy.  Không gian người dùng phải cẩn thận để ra lệnh đình chỉ
   nếu nó muốn đảm bảo rằng cổng siêu tốc sẽ tắt nguồn.

2. Sơ yếu lý lịch của cổng được sắp xếp theo trình tự để buộc cổng siêu tốc bật nguồn trước khi nó hoạt động.
   ngang hàng tốc độ cao.

3. Sơ yếu lý lịch cổng luôn kích hoạt thiết bị con được đính kèm tiếp tục.  Sau một
   mất phiên nguồn, thiết bị có thể đã bị xóa hoặc cần đặt lại.
   Việc tiếp tục lại thiết bị con khi cổng mẹ lấy lại được nguồn sẽ giải quyết những vấn đề đó.
   nêu và kẹp tần số chu kỳ nguồn tối đa của cổng ở mức
   thiết bị con có thể tạm dừng (autosuspend-delay) và tiếp tục (reset-resume)
   độ trễ).

Các tệp Sysfs có liên quan đến kiểm soát nguồn cổng:

ZZ0000ZZ:
		Cờ có thể ghi này kiểm soát trạng thái của một cổng nhàn rỗi.
		Một khi tất cả con cái và con cháu đã đình chỉ
		cổng có thể tạm dừng/tắt nguồn với điều kiện là
		pm_qos_no_power_off là '0'.  Nếu pm_qos_no_power_off là
		'1' cổng sẽ vẫn hoạt động/được cấp nguồn bất kể
		số liệu thống kê của con cháu.  Mặc định là 1.

ZZ0000ZZ:
		Tệp này phản ánh xem cổng có 'hoạt động' hay không (bật nguồn)
		hoặc 'bị treo' (tắt về mặt logic).  Không có dấu hiệu nào cho thấy
		không gian người dùng xem VBUS có còn được cung cấp hay không.

ZZ0000ZZ:
		Cờ chỉ đọc tư vấn cho không gian người dùng cho biết
		vị trí và kiểu kết nối của cổng.  Nó trở lại
		một trong bốn giá trị 'hotplug', 'hardwired', 'not used',
		và 'không rõ'.  Tất cả các giá trị, ngoài giá trị chưa biết, được đặt bởi
		phần mềm nền tảng.

ZZ0000ZZ cho biết có thể kết nối/hiển thị bên ngoài
		cổng trên nền tảng.  Thông thường không gian người dùng sẽ chọn
		để duy trì một cổng như vậy được cấp nguồn để xử lý thiết bị mới
		sự kiện kết nối.

ZZ0000ZZ đề cập đến một cổng không hiển thị nhưng
		có thể kết nối được. Ví dụ là các cổng nội bộ cho USB
		bluetooth có thể bị ngắt kết nối thông qua thiết bị bên ngoài
		chuyển đổi hoặc một cổng có camera USB có dây cứng.  Đó là
		dự kiến sẽ an toàn để cho phép các cảng này tạm dừng
		với điều kiện pm_qos_no_power_off được phối hợp với bất kỳ
		chuyển đổi các kết nối cổng đó.  Không gian người dùng phải sắp xếp
		để thiết bị được kết nối trước cổng
		tắt nguồn hoặc kích hoạt cổng trước khi bật
		kết nối thông qua một switch.

ZZ0000ZZ đề cập đến một cổng nội bộ được mong đợi
		để không bao giờ có một thiết bị kết nối với nó.  Đây có thể là
		các cổng nội bộ trống hoặc các cổng không có
		được phơi bày trên một nền tảng.  Được coi là an toàn
		tắt nguồn luôn.

ZZ0000ZZ có nghĩa là phần mềm nền tảng không cung cấp
		thông tin cho cổng này.  Thông thường nhất đề cập đến
		cổng trung tâm bên ngoài nên được coi là 'hotplug'
		cho các quyết định chính sách.

		.. note::

			- since we are relying on the BIOS to get this ACPI
			  information correct, the USB port descriptions may
			  be missing or wrong.

			- Take care in clearing ``pm_qos_no_power_off``. Once
			  power is off this port will
			  not respond to new connect events.

Khi một thiết bị con được gắn vào, các ràng buộc bổ sung sẽ được
	được áp dụng trước khi cổng được phép tắt nguồn.

ZZ0000ZZ:
		Phải là ZZ0001ZZ và cổng sẽ không
		tắt nguồn cho đến khi ZZ0002ZZ
		phản ánh trạng thái 'bị treo'.  Mặc định
		giá trị được điều khiển bởi trình điều khiển thiết bị con.

ZZ0000ZZ:
		Giá trị mặc định này là ZZ0001ZZ cho hầu hết các thiết bị và cho biết liệu
		kernel có thể duy trì cấu hình của thiết bị trên một
		mất phiên nguồn (sự kiện tạm dừng / nguồn cổng).  Khi nào
		giá trị này là ZZ0002ZZ (thiết bị kỳ quặc), cổng tắt nguồn là
		bị vô hiệu hóa.

ZZ0000ZZ:
		Các thiết bị có khả năng đánh thức sẽ chặn việc tắt nguồn cổng.  Tại
		lần này cơ chế duy nhất để xóa nội bộ usb
		khả năng đánh thức cho một thiết bị giao diện là hủy liên kết
		trình điều khiển của nó.

Tóm tắt các cài đặt cần thiết khi tắt nguồn liên quan đến thiết bị cổng::

echo 0 > nguồn/pm_qos_no_power_off
	echo 0 > ngang hàng/power/pm_qos_no_power_off # if nó tồn tại
	echo auto > power/control # this là giá trị mặc định
	echo auto > <child>/power/control
	echo 1 > <child>/power/persist # this là giá trị mặc định

Chính sách nguồn cổng không gian người dùng được đề xuất
--------------------------------------------------------

Như đã lưu ý ở trên, không gian người dùng cần phải cẩn thận và cân nhắc về những gì
cổng được kích hoạt để tắt nguồn.

Cấu hình mặc định là tất cả các cổng đều bắt đầu bằng
ZZ0000ZZ được đặt thành ZZ0001ZZ khiến các cổng luôn được giữ nguyên
hoạt động.

Được tin tưởng vào mô tả cổng của phần sụn nền tảng
(Bản ghi ACPI _PLD cho một cổng điền 'connect_type') không gian người dùng có thể
xóa pm_qos_no_power_off cho tất cả các cổng 'không được sử dụng'.  Điều tương tự có thể được
được thực hiện cho các cổng 'có dây cứng' với điều kiện việc tắt nguồn được phối hợp với bất kỳ cổng nào
công tắc kết nối cho cổng.

Chính sách không gian người dùng tích cực hơn là cho phép tắt nguồn cổng USB cho
tất cả các cổng (đặt ZZ0000ZZ thành ZZ0001ZZ) khi
một số yếu tố bên ngoài cho thấy người dùng đã ngừng tương tác với
hệ thống.  Ví dụ: một bản phân phối có thể muốn tắt nguồn tất cả USB
cổng khi màn hình trống và cấp lại nguồn cho chúng khi màn hình trở nên
hoạt động.  Điện thoại thông minh và máy tính bảng có thể muốn tắt nguồn cổng USB khi
người dùng nhấn nút nguồn.
