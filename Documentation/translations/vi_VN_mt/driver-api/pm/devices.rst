.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pm/devices.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. _driverapi_pm_devices:

===================================================
Thông tin cơ bản về quản lý nguồn điện của thiết bị
===================================================

:Bản quyền: ZZ0000ZZ 2010-2011 Rafael J. Wysocki <rjw@sisk.pl>, Novell Inc.
:Bản quyền: ZZ0001ZZ 2010 Alan Stern <stern@rowland.harvard.edu>
:Bản quyền: ZZ0002ZZ 2016 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Hầu hết mã trong Linux là trình điều khiển thiết bị, vì vậy phần lớn sức mạnh của Linux
Mã quản lý (PM) cũng dành riêng cho trình điều khiển.  Hầu hết người lái xe sẽ làm rất
ít; những thứ khác, đặc biệt là đối với các nền tảng có pin nhỏ (như pin di động
điện thoại), sẽ làm được rất nhiều.

Bài viết này cung cấp cái nhìn tổng quan về cách các trình điều khiển tương tác với toàn hệ thống
mục tiêu quản lý năng lượng, nhấn mạnh vào các mô hình và giao diện
được chia sẻ bởi mọi thứ liên kết với lõi mô hình trình điều khiển.  Đọc nó như
nền tảng cho công việc dành riêng cho miền mà bạn sẽ thực hiện với bất kỳ trình điều khiển cụ thể nào.


Hai mô hình quản lý năng lượng cho thiết bị
===========================================

Trình điều khiển sẽ sử dụng một hoặc cả hai model này để đưa thiết bị vào chế độ tiêu thụ điện năng thấp.
tiểu bang:

Mô hình ngủ hệ thống:

Trình điều khiển có thể chuyển sang trạng thái năng lượng thấp như một phần của việc chuyển sang toàn hệ thống
	các trạng thái năng lượng thấp như "tạm dừng" (còn được gọi là "tạm dừng đến RAM") hoặc
	(chủ yếu dành cho các hệ thống có đĩa) "ngủ đông" (còn được gọi là
	"treo vào đĩa").

Đây là thứ mà trình điều khiển thiết bị, xe buýt và lớp cộng tác
	bằng cách thực hiện các phương pháp tạm dừng và tiếp tục theo vai trò cụ thể khác nhau để
	tắt nguồn hoàn toàn các hệ thống con phần cứng và phần mềm, sau đó kích hoạt lại
	chúng mà không bị mất dữ liệu.

Một số trình điều khiển có thể quản lý các sự kiện đánh thức phần cứng, khiến hệ thống
	rời khỏi trạng thái năng lượng thấp.  Tính năng này có thể được bật hoặc tắt
	bằng cách sử dụng tệp ZZ0000ZZ có liên quan (đối với
	Trình điều khiển Ethernet giao diện ioctl được sử dụng bởi ethtool cũng có thể được sử dụng
	cho mục đích này); việc kích hoạt nó có thể tốn một ít năng lượng sử dụng, nhưng hãy để
	toàn bộ hệ thống chuyển sang trạng thái năng lượng thấp thường xuyên hơn.

Mô hình quản lý năng lượng thời gian chạy:

Các thiết bị cũng có thể được đưa vào trạng thái năng lượng thấp trong khi hệ thống đang hoạt động.
	về nguyên tắc hoạt động độc lập với hoạt động quản lý năng lượng khác.
	Tuy nhiên, các thiết bị nhìn chung không độc lập với nhau (ví dụ:
	Ví dụ: một thiết bị gốc không thể bị treo trừ khi tất cả thiết bị con của nó
	thiết bị đã bị đình chỉ).  Hơn nữa, tùy thuộc vào loại xe buýt,
	thiết bị đang bật, có thể cần phải thực hiện một số thao tác dành riêng cho xe buýt
	hoạt động trên thiết bị cho mục đích này.  Thiết bị đưa vào nguồn điện thấp
	các trạng thái trong thời gian chạy có thể yêu cầu xử lý đặc biệt trong quá trình cấp nguồn toàn hệ thống
	chuyển tiếp (tạm dừng hoặc ngủ đông).

Vì những lý do này không chỉ bản thân trình điều khiển thiết bị mà còn cả
	trình điều khiển hệ thống con thích hợp (loại bus, loại thiết bị hoặc loại thiết bị) và
	lõi PM có liên quan đến việc quản lý năng lượng trong thời gian chạy.  Như trong hệ thống
	trường hợp quản lý năng lượng giấc ngủ, họ cần cộng tác bằng cách triển khai
	các phương pháp tạm dừng và tiếp tục cụ thể theo vai trò khác nhau để phần cứng
	được tắt nguồn hoàn toàn và kích hoạt lại mà không mất dữ liệu hoặc dịch vụ.

Không có nhiều điều để nói về những trạng thái có năng lượng thấp ngoại trừ việc chúng
rất cụ thể cho hệ thống và thường dành riêng cho thiết bị.  Ngoài ra, nếu có đủ thiết bị
đã được đưa vào trạng thái năng lượng thấp (trong thời gian chạy), hiệu ứng có thể rất giống nhau
chuyển sang trạng thái năng lượng thấp trên toàn hệ thống (hệ thống ngủ) ... và điều đó
tồn tại sự phối hợp, do đó một số trình điều khiển sử dụng PM thời gian chạy có thể khiến hệ thống
chuyển sang trạng thái có sẵn các tùy chọn tiết kiệm năng lượng sâu hơn.

Hầu hết các thiết bị bị treo sẽ ngừng hoạt động tất cả I/O: không còn DMA hoặc IRQ (ngoại trừ
cho các sự kiện đánh thức), không còn đọc hoặc ghi dữ liệu nữa và các yêu cầu từ thượng nguồn
trình điều khiển không còn được chấp nhận.  Một xe buýt hoặc sân ga nhất định có thể có các đường dẫn khác nhau
mặc dù yêu cầu.

Ví dụ về các sự kiện đánh thức phần cứng bao gồm báo thức từ đồng hồ thời gian thực,
gói đánh thức mạng LAN, hoạt động của bàn phím hoặc chuột và chèn phương tiện
hoặc xóa (đối với PCMCIA, MMC/SD, USB, v.v.).

Giao diện để vào trạng thái ngủ của hệ thống
============================================

Có các giao diện lập trình được cung cấp cho các hệ thống con (loại bus, loại thiết bị,
lớp thiết bị) và trình điều khiển thiết bị để cho phép chúng tham gia vào quyền lực
quản lý các thiết bị mà họ quan tâm.  Các giao diện này bao gồm cả
quản lý năng lượng thời gian chạy và chế độ ngủ của hệ thống.


Hoạt động quản lý nguồn điện của thiết bị
-----------------------------------------

Hoạt động quản lý nguồn điện của thiết bị, ở cấp độ hệ thống con cũng như ở cấp độ
cấp trình điều khiển thiết bị, được triển khai bằng cách xác định và điền các đối tượng thuộc loại
struct dev_pm_ops được xác định trong ZZ0000ZZ.  Vai trò của
các phương pháp có trong đó sẽ được giải thích ở phần sau.  Hiện tại thì nên như vậy
đủ để nhớ rằng ba phương pháp cuối cùng dành riêng cho sức mạnh thời gian chạy
quản lý trong khi những cái còn lại được sử dụng trong quá trình cấp nguồn toàn hệ thống
chuyển tiếp.

Ngoài ra còn có giao diện "cũ" hoặc "cũ" không được dùng nữa để quản lý nguồn
hoạt động có sẵn ít nhất cho một số hệ thống con.  Cách tiếp cận này không sử dụng
struct dev_pm_ops và nó chỉ phù hợp để triển khai hệ thống
phương pháp quản lý năng lượng giấc ngủ một cách hạn chế.  Vì vậy nó không được mô tả
trong tài liệu này, vì vậy vui lòng tham khảo trực tiếp mã nguồn để biết thêm
thông tin về nó.


Phương pháp cấp hệ thống con
----------------------------

Các phương pháp cốt lõi để tạm dừng và tiếp tục lại thiết bị nằm trong
struct dev_pm_ops được chỉ ra bởi thành viên ZZ0000ZZ của
struct dev_pm_domain hoặc bởi thành viên ZZ0001ZZ của struct bus_type,
struct device_type và lớp struct.  Họ chủ yếu quan tâm đến
những người viết cơ sở hạ tầng cho nền tảng và xe buýt, như PCI hoặc USB, hoặc
loại thiết bị và trình điều khiển lớp thiết bị.  Chúng cũng có liên quan đến các tác giả của
trình điều khiển thiết bị có hệ thống con (miền PM, loại thiết bị, lớp thiết bị và
các loại xe buýt) không cung cấp tất cả các phương pháp quản lý nguồn.

Trình điều khiển xe buýt thực hiện các phương pháp này phù hợp với phần cứng và
trình điều khiển sử dụng nó; PCI hoạt động khác với USB, v.v.  Không có nhiều người
viết trình điều khiển cấp hệ thống con; hầu hết mã trình điều khiển là một "trình điều khiển thiết bị" xây dựng
bên trên mã khung dành riêng cho xe buýt.

Để biết thêm thông tin về các cuộc gọi trình điều khiển này, hãy xem mô tả sau;
chúng được gọi theo từng giai đoạn cho mọi thiết bị, tôn trọng cha mẹ và con cái
trình tự trong cây mô hình trình điều khiển.


Các tập tin ZZ0000ZZ
-------------------------------------------

Tất cả các đối tượng thiết bị trong mô hình trình điều khiển đều chứa các trường kiểm soát việc xử lý
về các sự kiện đánh thức hệ thống (tín hiệu phần cứng có thể buộc hệ thống thoát khỏi tình trạng
trạng thái ngủ).  Các trường này được khởi tạo bằng mã trình điều khiển xe buýt hoặc thiết bị bằng cách sử dụng
ZZ0000ZZ và ZZ0001ZZ,
được xác định trong ZZ0002ZZ.

Cờ ZZ0000ZZ chỉ ghi lại xem thiết bị (và
driver) có thể hỗ trợ vật lý các sự kiện đánh thức.  các
Quy trình ZZ0001ZZ ảnh hưởng đến cờ này.  các
Trường ZZ0002ZZ là một con trỏ tới một đối tượng thuộc loại
struct Wakeup_source được sử dụng để kiểm soát xem thiết bị có nên sử dụng hay không
cơ chế đánh thức hệ thống của nó và để thông báo cho lõi PM về việc đánh thức hệ thống
sự kiện được báo hiệu bởi thiết bị.  Đối tượng này chỉ hiện diện cho khả năng đánh thức
các thiết bị (tức là các thiết bị có cờ ZZ0003ZZ được đặt) và được tạo
(hoặc bị xóa) bởi ZZ0004ZZ.

Thiết bị có khả năng đưa ra các sự kiện đánh thức hay không là do phần cứng
vấn đề và hạt nhân chịu trách nhiệm theo dõi nó.  Ngược lại,
việc thiết bị có khả năng đánh thức có nên đưa ra sự kiện đánh thức hay không là một chính sách
quyết định và nó được quản lý bởi không gian người dùng thông qua thuộc tính sysfs:
Tệp ZZ0000ZZ.  Không gian người dùng có thể viết "đã bật" hoặc "bị vô hiệu hóa"
xâu chuỗi vào nó để cho biết liệu thiết bị có được cho là hay không
để báo hiệu sự thức tỉnh của hệ thống.  Tập tin này chỉ hiện diện nếu
Đối tượng ZZ0001ZZ tồn tại cho thiết bị nhất định và được tạo (hoặc
đã xóa) cùng với đối tượng đó bởi ZZ0002ZZ.
Đọc từ tệp sẽ trả về chuỗi tương ứng.

Giá trị ban đầu trong tệp ZZ0000ZZ bị "vô hiệu hóa" đối với
phần lớn các thiết bị; các trường hợp ngoại lệ chính là nút nguồn, bàn phím và
Bộ điều hợp Ethernet có tính năng WoL (wake-on-LAN) đã được thiết lập bằng ethtool.
Nó cũng phải được mặc định là "đã bật" cho các thiết bị không tạo ra sự đánh thức
tự mình yêu cầu mà chỉ chuyển tiếp các yêu cầu đánh thức từ xe buýt này sang xe buýt khác
(như cổng PCI Express).

Thủ tục ZZ0000ZZ chỉ trả về true nếu
Đối tượng ZZ0001ZZ tồn tại và ZZ0002ZZ tương ứng
tập tin chứa chuỗi "đã bật".  Thông tin này được sử dụng bởi các hệ thống con,
như mã loại bus PCI, để xem có bật tính năng đánh thức thiết bị hay không
cơ chế.  Nếu cơ chế đánh thức thiết bị được bật hoặc tắt trực tiếp bởi
người lái xe, họ cũng nên sử dụng ZZ0003ZZ để quyết định phải làm gì
trong quá trình chuyển đổi giấc ngủ của hệ thống.  Tuy nhiên, trình điều khiển thiết bị không được mong đợi sẽ
gọi trực tiếp ZZ0004ZZ trong mọi trường hợp.

Cần lưu ý rằng việc đánh thức hệ thống về mặt khái niệm khác với "việc đánh thức từ xa".
Wakeup" được sử dụng bởi quản lý năng lượng thời gian chạy, mặc dù nó có thể được hỗ trợ bởi
cơ chế vật lý giống nhau.  Đánh thức từ xa là một tính năng cho phép các thiết bị ở
trạng thái năng lượng thấp để kích hoạt các ngắt cụ thể đối với các điều kiện tín hiệu trong đó
chúng nên được đưa vào trạng thái toàn năng.  Những ngắt đó có thể có hoặc không
được sử dụng để báo hiệu các sự kiện đánh thức hệ thống, tùy thuộc vào thiết kế phần cứng.  Bật
một số hệ thống không thể kích hoạt chúng từ trạng thái ngủ của hệ thống.  Trong bất kỳ
trong trường hợp này, tính năng đánh thức từ xa phải luôn được bật để quản lý nguồn điện trong thời gian chạy cho
tất cả các thiết bị và trình điều khiển hỗ trợ nó.


Các tập tin ZZ0000ZZ
--------------------------------------------

Mỗi thiết bị trong kiểu trình điều khiển đều có một cờ để kiểm soát xem thiết bị đó có bị ảnh hưởng hay không.
quản lý năng lượng thời gian chạy.  Cờ này, ZZ0000ZZ, được khởi tạo
theo mã loại bus (hoặc nói chung là hệ thống con) sử dụng ZZ0001ZZ
hoặc ZZ0002ZZ; mặc định là cho phép sức mạnh thời gian chạy
quản lý.

Cài đặt có thể được điều chỉnh theo không gian người dùng bằng cách viết "bật" hoặc "tự động" vào
tệp sysfs ZZ0000ZZ của thiết bị.  Viết cuộc gọi "tự động"
ZZ0001ZZ, đặt cờ và cho phép thiết bị
thời gian chạy được quản lý bởi trình điều khiển của nó.  Viết cuộc gọi "bật"
ZZ0002ZZ, xóa cờ, đưa máy về đầy
quyền lực nếu nó ở trạng thái năng lượng thấp và ngăn chặn
thiết bị khỏi bị quản lý năng lượng trong thời gian chạy.  Không gian người dùng có thể kiểm tra giá trị hiện tại
của cờ ZZ0003ZZ bằng cách đọc tệp đó.

Cờ ZZ0000ZZ của thiết bị không ảnh hưởng đến việc xử lý
chuyển đổi quyền lực trên toàn hệ thống.  Đặc biệt, thiết bị có thể (và trong
phần lớn các trường hợp nên và sẽ) được đưa vào trạng thái năng lượng thấp trong quá trình
chuyển đổi toàn hệ thống sang trạng thái ngủ mặc dù ZZ0001ZZ của nó
cờ rõ ràng.

Để biết thêm thông tin về khung quản lý năng lượng thời gian chạy, hãy tham khảo
Tài liệu/sức mạnh/runtime_pm.rst.


Gọi trình điều khiển để vào và rời khỏi trạng thái ngủ của hệ thống
===================================================================

Khi hệ thống chuyển sang trạng thái ngủ, trình điều khiển của mỗi thiết bị sẽ được yêu cầu
tạm dừng thiết bị bằng cách đặt thiết bị vào trạng thái tương thích với mục tiêu
trạng thái hệ thống.  Đó thường là một số phiên bản của "tắt", nhưng các chi tiết thì
mang tính hệ thống cụ thể.  Ngoài ra, các thiết bị hỗ trợ đánh thức thường sẽ ở lại một phần
hoạt động để đánh thức hệ thống.

Khi hệ thống rời khỏi trạng thái năng lượng thấp đó, trình điều khiển của thiết bị sẽ được yêu cầu
tiếp tục nó bằng cách đưa nó trở lại toàn bộ sức mạnh.  Việc tạm dừng và tiếp tục hoạt động
luôn đi cùng nhau và cả hai đều là các hoạt động nhiều giai đoạn.

Đối với các trình điều khiển đơn giản, việc tạm dừng có thể khiến thiết bị ngừng hoạt động bằng mã lớp
và sau đó tắt phần cứng của nó ở mức "tắt" nhất có thể trong quá trình đình chỉ_noirq.  các
các cuộc gọi tiếp tục phù hợp sau đó sẽ khởi động lại hoàn toàn phần cứng
trước khi kích hoạt lại hàng đợi I/O lớp của nó.

Nhiều trình điều khiển nhận biết năng lượng hơn có thể chuẩn bị cho các thiết bị kích hoạt đánh thức hệ thống
sự kiện.


Đảm bảo trình tự cuộc gọi
-------------------------

Để đảm bảo rằng các cầu nối và các liên kết tương tự cần giao tiếp với một thiết bị đều được
khả dụng khi thiết bị bị treo hoặc tiếp tục lại, hệ thống phân cấp thiết bị là
đi theo thứ tự từ dưới lên để tạm dừng các thiết bị.  Thứ tự từ trên xuống là
được sử dụng để tiếp tục các thiết bị đó.

Thứ tự của hệ thống phân cấp thiết bị được xác định theo thứ tự các thiết bị
được đăng ký: một đứa trẻ không bao giờ có thể được đăng ký, thăm dò hoặc tiếp tục trước đó
cha mẹ của nó; và không thể bị xóa hoặc đình chỉ sau phụ huynh đó.

Chính sách là hệ thống phân cấp thiết bị phải phù hợp với cấu trúc liên kết bus phần cứng.
[Hoặc ít nhất là bus điều khiển, dành cho các thiết bị sử dụng nhiều bus.]
Đặc biệt, điều này có nghĩa là việc đăng ký thiết bị có thể không thành công nếu cha mẹ của
thiết bị đang tạm dừng (tức là đã được lõi PM chọn làm thiết bị tiếp theo
thiết bị tạm dừng) hoặc đã bị tạm dừng, cũng như sau tất cả các thiết bị khác
các thiết bị đã bị đình chỉ.  Trình điều khiển thiết bị phải được chuẩn bị để đối phó với những vấn đề đó
tình huống.


Các giai đoạn quản lý nguồn hệ thống
------------------------------------

Việc tạm dừng hoặc tiếp tục hệ thống được thực hiện theo nhiều giai đoạn.  Các giai đoạn khác nhau
được sử dụng để tạm dừng ở chế độ không hoạt động, nông (chế độ chờ) và sâu ("tạm dừng đến RAM")
trạng thái ngủ và trạng thái ngủ đông ("tạm dừng vào đĩa").  Mỗi giai đoạn bao gồm
thực hiện lệnh gọi lại cho mọi thiết bị trước khi giai đoạn tiếp theo bắt đầu.  Không phải tất cả
xe buýt hoặc lớp học đều hỗ trợ tất cả các lệnh gọi lại này và không phải tất cả tài xế đều sử dụng tất cả
cuộc gọi lại.  Các giai đoạn khác nhau luôn chạy sau khi nhiệm vụ đã bị đóng băng và
trước khi chúng được rã đông.  Hơn nữa, các pha ZZ0000ZZ chạy cùng lúc
khi trình xử lý IRQ bị vô hiệu hóa (ngoại trừ những trình xử lý được đánh dấu bằng
Cờ IRQF_NO_SUSPEND).

Tất cả các giai đoạn đều sử dụng các lệnh gọi lại tên miền PM, bus, loại, lớp hoặc trình điều khiển (nghĩa là các phương thức
được xác định trong ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ hoặc ZZ0004ZZ).  Những cuộc gọi lại này được xem xét bởi
Lõi PM loại trừ lẫn nhau.  Hơn nữa, việc gọi lại tên miền PM luôn mất
được ưu tiên hơn tất cả các cuộc gọi lại khác và, ví dụ: các cuộc gọi lại kiểu mất
được ưu tiên hơn so với các cuộc gọi lại xe buýt, lớp và trình điều khiển.  Nói một cách chính xác, sau đây
quy tắc được sử dụng để xác định cuộc gọi lại nào sẽ thực hiện trong giai đoạn nhất định:

1. Nếu có ZZ0000ZZ, lõi PM sẽ chọn cuộc gọi lại
	được cung cấp bởi ZZ0001ZZ để thực thi.

2. Mặt khác, nếu có cả ZZ0000ZZ và ZZ0001ZZ, thì
	lệnh gọi lại do ZZ0002ZZ cung cấp sẽ được chọn để thực thi.

3. Ngược lại, nếu có cả ZZ0000ZZ và ZZ0001ZZ,
	lệnh gọi lại do ZZ0002ZZ cung cấp sẽ được chọn cho
	thi hành.

4. Ngược lại, nếu có cả ZZ0000ZZ và ZZ0001ZZ, thì
	lệnh gọi lại do ZZ0002ZZ cung cấp sẽ được chọn để thực thi.

Điều này cho phép các loại thiết bị và miền PM ghi đè các cuộc gọi lại do xe buýt cung cấp
loại hoặc lớp thiết bị nếu cần thiết.

Các cuộc gọi lại miền, loại, lớp và bus PM có thể lần lượt gọi thiết bị- hoặc
các phương thức dành riêng cho trình điều khiển được lưu trữ trong ZZ0000ZZ, nhưng chúng không phải thực hiện
đó.

Nếu lệnh gọi lại hệ thống con được chọn để thực thi không xuất hiện, lõi PM sẽ
thay vào đó hãy thực hiện phương thức tương ứng từ bộ ZZ0000ZZ nếu
có một cái.


Vào hệ thống tạm dừng
-----------------------

Khi hệ thống chuyển sang trạng thái đóng băng, chờ hoặc ngủ bộ nhớ,
các pha là: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ.

1. Giai đoạn ZZ0000ZZ nhằm ngăn chặn các cuộc đua bằng cách ngăn chặn các cuộc đua mới
	thiết bị không được đăng ký; lõi PM sẽ không bao giờ biết rằng tất cả
	trẻ em của một thiết bị đã bị đình chỉ nếu trẻ em mới có thể
	được đăng ký theo ý muốn.  [Ngược lại, từ quan điểm của lõi PM,
	thiết bị có thể bị hủy đăng ký bất cứ lúc nào.] Không giống như các thiết bị khác
	các giai đoạn liên quan đến đình chỉ, trong giai đoạn ZZ0001ZZ, thiết bị
	hệ thống phân cấp được duyệt từ trên xuống.

Sau khi phương thức gọi lại ZZ0000ZZ trả về, không có phần tử con mới nào có thể được
	đã đăng ký bên dưới thiết bị.  Phương pháp này cũng có thể chuẩn bị thiết bị hoặc
	điều khiển theo một cách nào đó cho quá trình chuyển đổi quyền lực hệ thống sắp tới, nhưng nó
	không nên đưa thiết bị vào trạng thái nguồn điện thấp.  Hơn nữa, nếu
	thiết bị hỗ trợ quản lý năng lượng thời gian chạy, gọi lại ZZ0001ZZ
	phương thức không được cập nhật trạng thái của nó trong trường hợp cần phải tiếp tục lại nó
	từ thời gian chạy tạm dừng sau này.

Đối với các thiết bị hỗ trợ quản lý nguồn điện trong thời gian chạy, giá trị trả về của
	chuẩn bị gọi lại có thể được sử dụng để báo cho lõi PM rằng nó có thể
	để thiết bị ở chế độ tạm dừng thời gian chạy một cách an toàn (nếu bị tạm dừng thời gian chạy
	đã có), với điều kiện là tất cả hậu duệ của thiết bị cũng được để lại trong
	tạm dừng thời gian chạy.  Cụ thể, nếu lệnh gọi lại chuẩn bị trả về kết quả dương
	số và điều đó cũng xảy ra với tất cả các thiết bị kế thừa,
	và tất cả chúng (bao gồm cả chính thiết bị) đều bị treo trong thời gian chạy,
	Lõi PM sẽ bỏ qua ZZ0000ZZ, ZZ0001ZZ và
	Các pha ZZ0002ZZ cũng như tất cả các pha tương ứng của
	sơ yếu lý lịch thiết bị tiếp theo cho tất cả các thiết bị này.	Trong trường hợp đó,
	lệnh gọi lại ZZ0003ZZ sẽ là lệnh gọi lại tiếp theo sau
	ZZ0004ZZ gọi lại và hoàn toàn chịu trách nhiệm đưa
	thiết bị sang trạng thái nhất quán khi thích hợp.

Lưu ý rằng quy trình hoàn thành trực tiếp này áp dụng ngay cả khi thiết bị
	bị vô hiệu hóa khi chạy PM; chỉ có trạng thái thời gian chạy-PM mới quan trọng.  Nó theo sau
	rằng nếu một thiết bị có lệnh gọi lại chế độ ngủ hệ thống nhưng không hỗ trợ thời gian chạy
	PM, thì lệnh gọi lại chuẩn bị của nó không bao giờ được trả về giá trị dương.  Cái này
	là bởi vì tất cả các thiết bị như vậy ban đầu được đặt ở chế độ tạm dừng thời gian chạy với
	thời gian chạy PM bị vô hiệu hóa.

Tính năng này cũng có thể được điều khiển bởi trình điều khiển thiết bị bằng cách sử dụng
	Trình điều khiển ZZ0001ZZ và ZZ0002ZZ
	cờ quản lý điện năng.  [Thông thường, chúng được đặt vào thời điểm trình điều khiển
	được thăm dò đối với thiết bị được đề cập bằng cách chuyển chúng tới
	Chức năng trợ giúp ZZ0000ZZ.] Nếu lần đầu tiên trong số
	những cờ này được đặt, lõi PM sẽ không áp dụng tính năng hoàn thành trực tiếp
	quy trình được mô tả ở trên đối với thiết bị nhất định và do đó đối với bất kỳ thiết bị nào
	của tổ tiên nó.  Cờ thứ hai, khi được đặt, sẽ thông báo cho lớp giữa
	mã (loại bus, loại thiết bị, miền PM, lớp) mà nó cần sử dụng
	giá trị trả về của lệnh gọi lại ZZ0003ZZ do trình điều khiển cung cấp
	được tính đến và nó chỉ có thể trả về một giá trị dương từ chính nó
	ZZ0004ZZ gọi lại nếu tài xế cũng trả về kết quả dương tính
	giá trị.

2. Các phương pháp ZZ0000ZZ sẽ tắt thiết bị để dừng thiết bị
	thực hiện I/O.  Họ cũng có thể lưu các thanh ghi thiết bị và đưa nó vào
	trạng thái năng lượng thấp thích hợp, tùy thuộc vào loại bus mà thiết bị
	bật và chúng có thể kích hoạt các sự kiện đánh thức.

Tuy nhiên, đối với các thiết bị hỗ trợ quản lý nguồn điện trong thời gian chạy,
	Các phương thức ZZ0003ZZ được cung cấp bởi các hệ thống con (loại bus và miền PM
	đặc biệt) phải tuân theo một quy tắc bổ sung về những gì có thể được thực hiện
	tới các thiết bị trước khi phương thức ZZ0004ZZ của trình điều khiển của chúng được gọi.
	Cụ thể, họ có thể khôi phục thiết bị sau khi tạm dừng thời gian chạy bằng cách
	gọi ZZ0000ZZ cho họ, nếu điều đó là cần thiết, nhưng
	họ không được cập nhật trạng thái của thiết bị theo bất kỳ cách nào khác
	thời gian (trong trường hợp trình điều khiển cần tiếp tục thiết bị từ thời gian chạy
	tạm dừng trong các phương thức ZZ0005ZZ của họ).  Trên thực tế, lõi PM ngăn chặn
	hệ thống con hoặc trình điều khiển đưa thiết bị vào thời gian chạy tạm dừng tại
	những lúc này bằng cách gọi ZZ0001ZZ trước khi phát hành
	lệnh gọi lại ZZ0006ZZ (và gọi ZZ0002ZZ sau
	phát hành lệnh gọi lại ZZ0007ZZ).

3. Đối với một số thiết bị, việc chia hệ thống treo thành các phần sẽ rất thuận tiện.
	giai đoạn "ngưng thiết bị" và "lưu trạng thái thiết bị", trong trường hợp đó
	ZZ0000ZZ được thiết kế để làm điều sau.  Nó luôn được thực thi sau
	quản lý năng lượng thời gian chạy đã bị tắt đối với thiết bị được đề cập.

4. Giai đoạn ZZ0000ZZ xảy ra sau khi trình xử lý IRQ bị vô hiệu hóa,
	điều đó có nghĩa là trình xử lý ngắt của trình điều khiển sẽ không được gọi trong khi
	phương thức gọi lại đang chạy.  Các phương pháp ZZ0001ZZ sẽ
	lưu các giá trị của các thanh ghi của thiết bị chưa được lưu trước đó
	và cuối cùng đưa thiết bị về trạng thái tiêu thụ điện năng thấp thích hợp.

Phần lớn các hệ thống con và trình điều khiển thiết bị không cần thực hiện điều này
	gọi lại.  Tuy nhiên, các loại bus cho phép các thiết bị chia sẻ ngắt
	các vectơ, như PCI, thường cần nó; nếu không người lái xe có thể gặp phải
	một lỗi trong giai đoạn tạm dừng bằng cách bảo vệ một ngắt được chia sẻ
	được tạo bởi một số thiết bị khác sau khi thiết bị của chính nó được đặt ở mức thấp
	quyền lực.

Khi kết thúc các giai đoạn này, trình điều khiển lẽ ra phải dừng tất cả các giao dịch I/O
(DMA, IRQ), đã lưu đủ trạng thái để họ có thể khởi tạo lại hoặc khôi phục trước đó
trạng thái (khi phần cứng cần) và đặt thiết bị ở trạng thái năng lượng thấp.
Trên nhiều nền tảng, chúng sẽ tắt một hoặc nhiều nguồn đồng hồ; đôi khi họ
cũng sẽ tắt nguồn điện hoặc giảm điện áp.  [Hỗ trợ trình điều khiển
PM thời gian chạy có thể đã thực hiện một số hoặc tất cả các bước này.]

Nếu ZZ0000ZZ trả về ZZ0003ZZ, thiết bị sẽ
được chuẩn bị để tạo tín hiệu đánh thức phần cứng nhằm kích hoạt sự kiện đánh thức hệ thống
khi hệ thống ở trạng thái ngủ.  Ví dụ: ZZ0001ZZ
có thể xác định các tín hiệu GPIO được nối với công tắc hoặc phần cứng bên ngoài khác,
và ZZ0002ZZ thực hiện điều gì đó tương tự với tín hiệu PCI PME.

Nếu bất kỳ lệnh gọi lại nào trong số này trả về lỗi, hệ thống sẽ không nhập kết quả mong muốn
trạng thái năng lượng thấp.  Thay vào đó, lõi PM sẽ ngừng hoạt động bằng cách tiếp tục tất cả
các thiết bị đã bị đình chỉ.


Rời khỏi hệ thống tạm dừng
--------------------------

Khi tiếp tục từ trạng thái đóng băng, chờ hoặc ngủ bộ nhớ, các giai đoạn là:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ.

1. Các phương thức gọi lại ZZ0000ZZ sẽ thực hiện bất kỳ hành động nào
	cần thiết trước khi gọi trình xử lý ngắt của trình điều khiển.  Cái này
	thường có nghĩa là hoàn tác các hành động của pha ZZ0001ZZ.  Nếu
	loại bus cho phép các thiết bị chia sẻ các vectơ ngắt, như PCI,
	phương pháp này sẽ đưa thiết bị và trình điều khiển của nó vào trạng thái
	trình điều khiển có thể nhận biết liệu thiết bị có phải là nguồn gây ra các ngắt đến hay không,
	nếu có và xử lý chúng một cách chính xác.

Ví dụ: ZZ0000ZZ của loại bus PCI đặt thiết bị
	sang trạng thái toàn năng (D0 trong thuật ngữ PCI) và khôi phục
	thanh ghi cấu hình tiêu chuẩn của thiết bị.  Sau đó nó gọi
	Phương pháp ZZ0001ZZ của trình điều khiển thiết bị để thực hiện dành riêng cho thiết bị
	hành động.

2. Các phương pháp ZZ0000ZZ cần chuẩn bị các thiết bị để thực thi
	của các phương pháp sơ yếu lý lịch.  Điều này thường liên quan đến việc hoàn tác các hành động của
	giai đoạn ZZ0001ZZ trước đó.

3. Các phương pháp ZZ0000ZZ sẽ đưa thiết bị trở lại hoạt động bình thường
	trạng thái để nó có thể thực hiện I/O bình thường.  Điều này thường liên quan đến
	hoàn tác các hành động của giai đoạn ZZ0001ZZ.

4. Pha ZZ0000ZZ sẽ hoàn tác các hành động của pha ZZ0001ZZ.
        Vì lý do này, không giống như các giai đoạn liên quan đến sơ yếu lý lịch khác, trong quá trình
        Giai đoạn ZZ0002ZZ hệ thống phân cấp thiết bị được duyệt từ dưới lên.

Tuy nhiên, lưu ý rằng trẻ em mới có thể được đăng ký bên dưới thiết bị với tư cách là
	ngay khi cuộc gọi lại ZZ0000ZZ xảy ra; không cần thiết phải chờ đợi
	cho đến khi giai đoạn ZZ0001ZZ chạy.

Hơn nữa, nếu lệnh gọi lại ZZ0000ZZ trước đó trả về kết quả dương
	số, thiết bị có thể đã bị treo trong thời gian chạy trong suốt thời gian chạy
	toàn bộ hệ thống tạm dừng và tiếp tục (ZZ0001ZZ, ZZ0002ZZ,
	ZZ0003ZZ, ZZ0004ZZ,
	Lệnh gọi lại ZZ0005ZZ và ZZ0006ZZ có thể đã được
	bỏ qua).  Trong trường hợp đó, lệnh gọi lại ZZ0007ZZ hoàn toàn
	chịu trách nhiệm đưa thiết bị về trạng thái nhất quán sau khi hệ thống
	đình chỉ nếu cần thiết.  [Ví dụ: nó có thể cần xếp hàng một thời gian chạy
	tiếp tục yêu cầu thiết bị cho mục đích này.] Để kiểm tra xem đó có phải là
	trong trường hợp này, lệnh gọi lại ZZ0008ZZ có thể tham khảo ý kiến của thiết bị
	Cờ ZZ0009ZZ.  Nếu cờ đó được đặt khi
	Cuộc gọi lại ZZ0010ZZ đang được chạy thì cơ chế hoàn thành trực tiếp
	đã được sử dụng và có thể cần phải thực hiện các hành động đặc biệt để thiết bị hoạt động
	chính xác sau đó.

Khi kết thúc các giai đoạn này, trình điều khiển sẽ hoạt động bình thường như trước
tạm dừng: I/O có thể được thực hiện bằng cách sử dụng DMA và IRQ, đồng thời các đồng hồ liên quan là
bị chặn lại.

Tuy nhiên, chi tiết ở đây có thể lại dành riêng cho từng nền tảng.  Ví dụ,
một số hệ thống hỗ trợ nhiều trạng thái "chạy" và chế độ có hiệu lực tại
phần cuối của sơ yếu lý lịch có thể không phải là phần trước khi bị đình chỉ.
Điều đó có nghĩa là tính khả dụng của một số đồng hồ hoặc nguồn điện nhất định đã thay đổi,
điều này có thể dễ dàng ảnh hưởng đến cách thức hoạt động của người lái xe.

Trình điều khiển cần có khả năng xử lý phần cứng đã được đặt lại kể từ khi tất cả
các phương thức đình chỉ đã được gọi, ví dụ như bằng cách khởi tạo lại hoàn toàn.
Đây có thể là phần khó nhất và là phần được bảo vệ nhiều nhất bởi các tài liệu NDA'd
và lỗi chip.  Đơn giản nhất là nếu trạng thái phần cứng không thay đổi kể từ
việc đình chỉ đã được thực hiện, nhưng điều đó chỉ có thể được đảm bảo nếu mục tiêu
hệ thống đã nhập trạng thái ngủ ở trạng thái tạm dừng ở trạng thái không hoạt động.  Đối với các trạng thái ngủ của hệ thống khác
điều đó có thể không xảy ra (và thường không dành cho chế độ ngủ hệ thống do ACPI xác định
trạng thái, như S3).

Trình điều khiển cũng phải chuẩn bị tinh thần để nhận biết thiết bị đã bị gỡ bỏ
trong khi hệ thống đã tắt nguồn, bất cứ khi nào có thể.
PCMCIA, MMC, USB, Firewire, SCSI và thậm chí IDE là những ví dụ phổ biến về xe buýt
nơi các nền tảng Linux phổ biến sẽ thấy việc loại bỏ như vậy.  Chi tiết về cách trình điều khiển
sẽ thông báo và xử lý việc xóa như vậy hiện dành riêng cho xe buýt và thường
liên quan đến một chủ đề riêng biệt.

Những cuộc gọi lại này có thể trả về giá trị lỗi, nhưng lõi PM sẽ bỏ qua những giá trị đó
lỗi vì nó không thể làm gì được ngoài việc in chúng vào
nhật ký hệ thống.


Bước vào trạng thái ngủ đông
----------------------------

Ngủ đông hệ thống phức tạp hơn việc đưa nó vào trạng thái ngủ,
bởi vì nó liên quan đến việc tạo và lưu hình ảnh hệ thống.  Vì thế có
nhiều giai đoạn ngủ đông hơn, với một nhóm lệnh gọi lại khác.  Những giai đoạn này
luôn chạy sau khi các tác vụ đã được đóng băng và đã giải phóng đủ bộ nhớ.

Quy trình chung để ngủ đông là tắt tất cả các thiết bị ("đóng băng"),
tạo hình ảnh của bộ nhớ hệ thống trong khi mọi thứ đều ổn định, kích hoạt lại tất cả
thiết bị ("làm tan băng"), ghi hình ảnh vào bộ lưu trữ vĩnh viễn và cuối cùng tắt
hệ thống ("tắt nguồn").  Các giai đoạn được sử dụng để thực hiện việc này là: ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ,
ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ, ZZ0009ZZ, ZZ0010ZZ,
ZZ0011ZZ.

1. Giai đoạn ZZ0000ZZ được thảo luận trong phần "Vào hệ thống tạm dừng"
	phần trên.

2. Các phương pháp ZZ0000ZZ sẽ tắt thiết bị để thiết bị không hoạt động
	tạo IRQ hoặc DMA và họ có thể cần lưu các giá trị của thiết bị
	sổ đăng ký.  Tuy nhiên, thiết bị không nhất thiết phải được đặt ở nơi có công suất thấp.
	trạng thái và để tiết kiệm thời gian, tốt nhất là không nên làm như vậy.  Ngoài ra, thiết bị nên
	không được chuẩn bị để tạo ra các sự kiện đánh thức.

3. Pha ZZ0000ZZ tương tự pha ZZ0001ZZ
	được mô tả trước đó, ngoại trừ việc không nên đặt thiết bị vào
	trạng thái năng lượng thấp và không được phép tạo ra các sự kiện đánh thức.

4. Pha ZZ0000ZZ tương tự pha ZZ0001ZZ
	đã thảo luận trước đó, ngoại trừ một lần nữa là không nên đưa thiết bị vào
	ở trạng thái năng lượng thấp và không được phép tạo ra các sự kiện đánh thức.

Tại thời điểm này, hình ảnh hệ thống được tạo ra.  Tất cả các thiết bị phải ở trạng thái không hoạt động và
nội dung của bộ nhớ sẽ không bị xáo trộn trong khi điều này xảy ra, để
hình ảnh tạo thành một ảnh chụp nhanh nguyên tử về trạng thái hệ thống.

5. Pha ZZ0000ZZ tương tự pha ZZ0001ZZ
	đã thảo luận trước đó.  Sự khác biệt chính là các phương pháp của nó có thể giả định
	thiết bị ở trạng thái tương tự như ở cuối ZZ0002ZZ
	giai đoạn.

6. Pha ZZ0000ZZ tương tự pha ZZ0001ZZ
	được mô tả ở trên.  Các phương pháp của nó sẽ hoàn tác các hành động trước đó
	ZZ0002ZZ, nếu cần.

7. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ đã thảo luận
	trước đó.  Các phương pháp của nó sẽ đưa thiết bị trở lại trạng thái hoạt động
	trạng thái, để nó có thể được sử dụng để lưu hình ảnh nếu cần thiết.

8. Giai đoạn ZZ0000ZZ được thảo luận trong phần "Rời khỏi hệ thống tạm dừng"
	phần trên.

Tại thời điểm này, hình ảnh hệ thống đã được lưu và các thiết bị sau đó cần được
chuẩn bị cho việc tắt hệ thống sắp tới.  Điều này giống như đình chỉ chúng
trước khi đưa hệ thống vào trạng thái tạm dừng, ngủ nông hoặc ngủ sâu,
và các pha giống nhau.

9. Giai đoạn ZZ0000ZZ đã được thảo luận ở trên.

10. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ.

11. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ.

12. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ.

Lệnh gọi lại ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ
về cơ bản nên làm những việc tương tự như ZZ0003ZZ, ZZ0004ZZ
và các lệnh gọi lại ZZ0005ZZ tương ứng.  Một sự khác biệt đáng chú ý là
rằng họ không cần lưu trữ các giá trị thanh ghi thiết bị, bởi vì các thanh ghi
lẽ ra đã được lưu trữ trong ZZ0006ZZ, ZZ0007ZZ hoặc
Pha ZZ0008ZZ.  Ngoài ra, trên nhiều máy, phần sụn sẽ tắt nguồn
toàn bộ hệ thống nên không cần thiết phải gọi lại để đưa thiết bị vào
trạng thái năng lượng thấp.


Rời khỏi trạng thái ngủ đông
----------------------------

Việc tiếp tục sau chế độ ngủ đông lại phức tạp hơn việc tiếp tục sau chế độ ngủ
trạng thái trong đó nội dung của bộ nhớ chính được bảo toàn vì nó yêu cầu
hình ảnh hệ thống sẽ được tải vào bộ nhớ và nội dung bộ nhớ trước khi ngủ đông
được khôi phục trước khi quyền điều khiển có thể được chuyển trở lại hạt nhân hình ảnh.

Mặc dù về nguyên tắc, hình ảnh có thể được tải vào bộ nhớ và
nội dung bộ nhớ trước khi ngủ đông được bộ tải khởi động khôi phục, trong thực tế điều này
không thể thực hiện được vì bộ tải khởi động không đủ thông minh và không có
giao thức được thiết lập để truyền thông tin cần thiết.  Vì vậy thay vào đó,
bộ tải khởi động tải một phiên bản mới của kernel, được gọi là "kernel khôi phục",
vào bộ nhớ và chuyển quyền điều khiển cho nó theo cách thông thường.  Sau đó khôi phục kernel
đọc hình ảnh hệ thống, khôi phục nội dung bộ nhớ trước khi ngủ đông và chuyển
điều khiển hạt nhân hình ảnh.  Do đó có hai phiên bản kernel khác nhau có liên quan
trong việc nối lại từ trạng thái ngủ đông.  Trên thực tế, kernel khôi phục có thể hoàn toàn
khác với hạt nhân hình ảnh: một cấu hình khác và thậm chí là một
phiên bản.  Điều này có những hậu quả quan trọng đối với trình điều khiển thiết bị và
các hệ thống con.

Để có thể tải ảnh hệ thống vào bộ nhớ, kernel khôi phục cần phải
bao gồm ít nhất một tập hợp con trình điều khiển thiết bị cho phép nó truy cập vào bộ lưu trữ
phương tiện chứa hình ảnh, mặc dù nó không cần bao gồm tất cả các
trình điều khiển có trong hạt nhân hình ảnh.  Sau khi hình ảnh được tải xong,
các thiết bị được quản lý bởi kernel khởi động cần được chuẩn bị để chuyển lại quyền điều khiển
vào hạt nhân hình ảnh.  Điều này rất giống với các bước đầu tiên liên quan đến
tạo một hình ảnh hệ thống và nó được thực hiện theo cách tương tự, sử dụng
Các pha ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ.  Tuy nhiên, các thiết bị
bị ảnh hưởng bởi các giai đoạn này chỉ là những giai đoạn có trình điều khiển trong kernel khôi phục;
các thiết bị khác sẽ vẫn ở trạng thái bất kỳ mà bộ tải khởi động để lại cho chúng.

Nếu việc khôi phục nội dung bộ nhớ trước khi ngủ đông không thành công, việc khôi phục
kernel sẽ trải qua quy trình "làm tan băng" được mô tả ở trên, sử dụng
Các giai đoạn ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ, sau đó
tiếp tục chạy bình thường.  Điều này hiếm khi xảy ra.  Thông thường nhất
Nội dung bộ nhớ trước khi ngủ đông được khôi phục thành công và quyền kiểm soát được thông qua
vào hạt nhân hình ảnh, sau đó hạt nhân này sẽ chịu trách nhiệm đưa hệ thống quay trở lại
sang trạng thái làm việc.

Để đạt được điều này, kernel hình ảnh phải khôi phục trạng thái ngủ đông trước của thiết bị
chức năng.  Hoạt động này giống như thức dậy từ trạng thái ngủ (với
nội dung bộ nhớ được bảo toàn), mặc dù nó bao gồm các giai đoạn khác nhau:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ.

1. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ.

2. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ.

3. Pha ZZ0000ZZ tương tự như pha ZZ0001ZZ.

4. Giai đoạn ZZ0000ZZ đã được thảo luận ở trên.

Sự khác biệt chính so với ZZ0000ZZ là ở chỗ
ZZ0001ZZ phải cho rằng thiết bị đã được truy cập và
được cấu hình lại bằng bộ tải khởi động hoặc kernel khôi phục.  Theo đó, nhà nước
của thiết bị có thể khác với trạng thái được ghi nhớ từ ZZ0002ZZ,
Các pha ZZ0003ZZ và ZZ0004ZZ.  Thiết bị thậm chí có thể cần phải
thiết lập lại và khởi tạo lại hoàn toàn.  Trong nhiều trường hợp sự khác biệt này không
vấn đề, vì vậy ZZ0005ZZ và ZZ0006ZZ
con trỏ phương thức có thể được đặt thành cùng một thói quen.  Tuy nhiên, khác nhau
con trỏ gọi lại được sử dụng trong trường hợp có tình huống thực sự xảy ra
vấn đề.


Trình thông báo quản lý nguồn
=============================

Có một số hoạt động mà người quản lý nguồn không thể thực hiện được
các cuộc gọi lại đã thảo luận ở trên, vì các cuộc gọi lại xảy ra quá muộn hoặc quá sớm.
Để xử lý những trường hợp này, hệ thống con và trình điều khiển thiết bị có thể đăng ký nguồn điện
thông báo quản lý được gọi trước khi nhiệm vụ bị đóng băng và sau khi chúng
đã tan băng.  Nói chung, trình thông báo PM phù hợp để thực hiện
các hành động yêu cầu phải có không gian của người dùng hoặc ít nhất là không
can thiệp vào không gian người dùng.

Để biết chi tiết, hãy tham khảo Tài liệu/driver-api/pm/notifiers.rst.


Trạng thái năng lượng thấp (tạm dừng) của thiết bị
==================================================

Trạng thái năng lượng thấp của thiết bị không phải là tiêu chuẩn.  Một thiết bị chỉ có thể xử lý
"bật" và "tắt", trong khi cái khác có thể hỗ trợ hàng chục phiên bản khác nhau của
"bật" (có bao nhiêu động cơ đang hoạt động?), cộng với trạng thái quay lại "bật"
nhanh hơn so với khi "tắt" hoàn toàn.

Một số xe buýt xác định các quy tắc về ý nghĩa của các trạng thái tạm dừng khác nhau.  PCI
đưa ra một ví dụ: sau khi chuỗi tạm dừng hoàn thành, một dữ liệu không kế thừa
Thiết bị PCI không được thực hiện DMA hoặc phát ra IRQ cũng như mọi sự kiện đánh thức nó
các vấn đề sẽ được phát hành thông qua tín hiệu PME# bus.  Thêm vào đó, có
một số trạng thái thiết bị tiêu chuẩn PCI, một số trạng thái là tùy chọn.

Ngược lại, các bộ xử lý tích hợp hệ thống trên chip thường sử dụng IRQ làm
nguồn sự kiện đánh thức (vì vậy trình điều khiển sẽ gọi ZZ0000ZZ) và
có thể coi việc hoàn thành DMA là một sự kiện đánh thức (đôi khi DMA có thể ở lại
cũng hoạt động, chỉ có CPU và một số thiết bị ngoại vi ở chế độ ngủ).

Một số chi tiết ở đây có thể dành riêng cho nền tảng.  Hệ thống có thể có các thiết bị
có thể hoạt động hoàn toàn ở một số trạng thái ngủ nhất định, chẳng hạn như màn hình LCD
được làm mới bằng DMA trong khi hầu hết hệ thống đang ngủ nhẹ ... và
bộ đệm khung của nó thậm chí có thể được cập nhật bởi DSP hoặc CPU không phải Linux khác trong khi
bộ xử lý điều khiển Linux không hoạt động.

Hơn nữa, các hành động cụ thể được thực hiện có thể phụ thuộc vào trạng thái hệ thống mục tiêu.
Một trạng thái hệ thống mục tiêu có thể cho phép một thiết bị nhất định hoạt động tốt;
một cái khác có thể yêu cầu tắt máy cứng và khởi tạo lại khi tiếp tục.
Và hai hệ thống mục tiêu khác nhau có thể sử dụng cùng một thiết bị ở những vị trí khác nhau.
cách; LCD nói trên có thể hoạt động ở chế độ "chế độ chờ" của một sản phẩm
nhưng một sản phẩm khác sử dụng cùng SOC có thể hoạt động khác.


Miền quản lý nguồn thiết bị
===============================

Đôi khi các thiết bị chia sẻ đồng hồ tham chiếu hoặc các nguồn năng lượng khác.  Trong đó
các trường hợp thường không thể đặt thiết bị ở trạng thái năng lượng thấp
riêng lẻ.  Thay vào đó, một tập hợp các thiết bị chia sẻ nguồn điện có thể được đặt
chuyển sang trạng thái năng lượng thấp cùng lúc bằng cách tắt thiết bị dùng chung
nguồn năng lượng.  Tất nhiên, chúng cũng cần được đưa vào trạng thái toàn năng.
cùng nhau, bằng cách bật nguồn năng lượng được chia sẻ.  Một bộ thiết bị có chức năng này
tài sản thường được gọi là một miền quyền lực. Một miền quyền lực cũng có thể
được lồng bên trong một miền quyền lực khác. Miền lồng nhau được gọi là
tên miền phụ của tên miền mẹ.

Hỗ trợ cho các miền điện được cung cấp thông qua trường ZZ0000ZZ của
thiết bị cấu trúc  Trường này là một con trỏ tới một đối tượng thuộc loại
struct dev_pm_domain, được xác định trong ZZ0001ZZ, cung cấp một bộ
các lệnh gọi lại quản lý năng lượng tương tự như trình điều khiển thiết bị và cấp hệ thống con
các cuộc gọi lại được thực thi cho thiết bị nhất định trong tất cả các lần chuyển đổi nguồn,
thay vì các lệnh gọi lại cấp hệ thống con tương ứng.  Cụ thể, nếu một
con trỏ ZZ0002ZZ của thiết bị không phải là NULL, lệnh gọi lại ZZ0003ZZ
từ đối tượng được nó trỏ đến sẽ được thực thi thay vì hệ thống con của nó
(ví dụ: loại xe buýt) gọi lại ZZ0004ZZ và tương tự cho tất cả các
cuộc gọi lại còn lại.  Nói cách khác, các cuộc gọi lại miền quản lý nguồn, nếu
được xác định cho thiết bị nhất định, luôn được ưu tiên hơn các lệnh gọi lại được cung cấp
bởi hệ thống con của thiết bị (ví dụ: loại xe buýt).

Việc hỗ trợ các miền quản lý nguồn thiết bị chỉ phù hợp với các nền tảng
cần sử dụng cùng một lệnh gọi lại quản lý nguồn của trình điều khiển thiết bị trong nhiều
các cấu hình miền quyền lực khác nhau và muốn tránh kết hợp
hỗ trợ các miền quyền lực thành các cuộc gọi lại ở cấp hệ thống con, ví dụ như bằng cách
sửa đổi loại bus nền tảng.  Các nền tảng khác không cần phải triển khai hoặc thực hiện
nó được tính đến theo bất kỳ cách nào.

Các thiết bị có thể được định nghĩa là IRQ-safe để cho lõi PM biết rằng chúng
lệnh gọi lại PM thời gian chạy có thể được gọi với các ngắt bị vô hiệu hóa (xem
Tài liệu/power/runtime_pm.rst để biết thêm thông tin).  Nếu một
Thiết bị IRQ-safe thuộc miền PM, thời gian chạy PM của miền sẽ là
không được phép, trừ khi bản thân tên miền được xác định là IRQ-safe. Tuy nhiên, nó
chỉ hợp lý khi xác định miền PM là IRQ-safe nếu tất cả các thiết bị trong đó
IRQ an toàn. Hơn nữa, nếu miền an toàn IRQ có miền gốc, thời gian chạy
PM của cha mẹ chỉ được phép nếu bản thân cha mẹ cũng an toàn với IRQ với
hạn chế bổ sung mà tất cả các miền con của cấp độ gốc an toàn IRQ cũng phải
hãy an toàn với IRQ.


Quản lý năng lượng thời gian chạy
=================================

Nhiều thiết bị có thể tự động tắt nguồn trong khi hệ thống vẫn hoạt động
đang chạy. Tính năng này hữu ích cho các thiết bị không được sử dụng và
có thể tiết kiệm điện năng đáng kể trên hệ thống đang chạy.  Những thiết bị này
thường hỗ trợ một loạt các trạng thái năng lượng thời gian chạy, có thể sử dụng các tên như
là "tắt", "ngủ", "không hoạt động", "hoạt động", v.v.  Những trạng thái đó sẽ ở một số
các trường hợp (như PCI) bị hạn chế một phần bởi bus mà thiết bị sử dụng và sẽ
thường bao gồm các trạng thái phần cứng cũng được sử dụng trong trạng thái ngủ của hệ thống.

Quá trình chuyển đổi nguồn trên toàn hệ thống có thể được bắt đầu khi một số thiết bị ở mức thấp
trạng thái năng lượng do quản lý năng lượng thời gian chạy.  Hệ thống ngủ PM gọi lại
nên nhận ra những tình huống như vậy và phản ứng lại chúng một cách thích hợp, nhưng
các hành động cần thiết là dành riêng cho hệ thống con.

Trong một số trường hợp, quyết định có thể được đưa ra ở cấp hệ thống con trong khi ở các trường hợp khác
trường hợp trình điều khiển thiết bị có thể được quyết định.  Trong một số trường hợp có thể
mong muốn để thiết bị treo ở trạng thái đó trong thời gian cấp nguồn toàn hệ thống
chuyển tiếp, nhưng trong các trường hợp khác, thiết bị phải được đưa trở lại chế độ hoạt động toàn bộ
trạng thái tạm thời, ví dụ như vậy để khả năng đánh thức hệ thống của nó có thể được
bị vô hiệu hóa.  Tất cả điều này phụ thuộc vào phần cứng và thiết kế của hệ thống con và
trình điều khiển thiết bị được đề cập.

Nếu cần khôi phục lại thiết bị sau khi tạm dừng thời gian chạy trong toàn hệ thống
chuyển sang trạng thái ngủ, điều đó có thể được thực hiện bằng cách gọi
ZZ0000ZZ từ lệnh gọi lại ZZ0001ZZ (hoặc ZZ0002ZZ
hoặc gọi lại ZZ0003ZZ để chuyển đổi liên quan đến chế độ ngủ đông) của
trình điều khiển của thiết bị hoặc hệ thống con của nó (ví dụ: loại bus hoặc miền PM).
Tuy nhiên, các hệ thống con không được thay đổi trạng thái thời gian chạy của thiết bị.
từ lệnh gọi lại ZZ0004ZZ và ZZ0005ZZ của họ (hoặc tương đương) ZZ0007ZZ
gọi lệnh gọi lại ZZ0006ZZ của trình điều khiển thiết bị (hoặc tương đương).

.. _smart_suspend_flag:

Cờ trình điều khiển ZZ0000ZZ
------------------------------------------

Một số loại bus và miền PM có chính sách tiếp tục tất cả các thiết bị từ thời gian chạy
tạm dừng trả trước trong lệnh gọi lại ZZ0002ZZ của họ, nhưng điều đó có thể không thực sự
cần thiết nếu trình điều khiển của thiết bị có thể xử lý được các thiết bị bị treo trong thời gian chạy.
Trình điều khiển có thể chỉ ra điều này bằng cách đặt ZZ0003ZZ trong
ZZ0000ZZ tại thời điểm thăm dò, với sự hỗ trợ của
Thói quen trợ giúp ZZ0001ZZ.

Đặt cờ đó gây ra lõi PM và mã lớp giữa
(loại xe buýt, tên miền PM, v.v.) để bỏ qua ZZ0001ZZ và
Lệnh gọi lại ZZ0002ZZ do trình điều khiển cung cấp nếu thiết bị vẫn ở chế độ
tạm dừng thời gian chạy trong suốt các giai đoạn tạm dừng trên toàn hệ thống (và
tương tự đối với các phần "đóng băng" và "tắt nguồn" của chế độ ngủ đông hệ thống).
[Nếu không thì cùng một trình điều khiển
cuộc gọi lại có thể được thực hiện hai lần liên tiếp cho cùng một thiết bị, điều này sẽ không
nói chung là hợp lệ.] Nếu có lệnh gọi lại PM trên toàn hệ thống lớp giữa
đối với thiết bị thì họ có trách nhiệm bỏ qua các lệnh gọi lại trình điều khiển này;
nếu không thì lõi PM sẽ bỏ qua chúng.  Các thủ tục gọi lại của hệ thống con có thể
xác định xem họ có cần bỏ qua lệnh gọi lại trình điều khiển hay không bằng cách kiểm tra kết quả trả về
giá trị từ hàm trợ giúp ZZ0000ZZ.

Ngoài ra, với bộ ZZ0000ZZ, ZZ0001ZZ của người lái
và lệnh gọi lại ZZ0002ZZ bị bỏ qua ở chế độ ngủ đông nếu thiết bị vẫn
tạm dừng trong thời gian chạy trong suốt quá trình chuyển đổi "đóng băng" trước đó.  Một lần nữa, nếu
các cuộc gọi lại lớp giữa hiện diện cho thiết bị, chúng chịu trách nhiệm
thực hiện việc này, nếu không thì lõi PM sẽ đảm nhiệm việc đó.


Cờ trình điều khiển ZZ0000ZZ
--------------------------------------------

Trong quá trình khôi phục toàn hệ thống từ trạng thái ngủ, cách dễ nhất là đưa thiết bị vào
trạng thái toàn năng, như được giải thích trong Documentation/power/runtime_pm.rst.
[Tham khảo tài liệu đó để biết thêm thông tin về vấn đề cụ thể này như
cũng như để biết thông tin về khung quản lý năng lượng thời gian chạy của thiết bị trong
chung.] Tuy nhiên, bạn nên để thiết bị ở trạng thái tạm dừng sau khi
hệ thống chuyển sang trạng thái làm việc, đặc biệt nếu các thiết bị đó đã ở trạng thái
tạm dừng thời gian chạy trước tạm dừng toàn hệ thống trước đó (hoặc tương tự)
chuyển tiếp.

Để đạt được mục đích đó, trình điều khiển thiết bị có thể sử dụng cờ ZZ0000ZZ để
cho biết lõi PM và mã lớp giữa rằng chúng cho phép "noirq" và
các cuộc gọi lại tiếp tục "sớm" sẽ bị bỏ qua nếu thiết bị có thể bị treo
sau khi PM toàn hệ thống chuyển sang trạng thái làm việc.  Có hay không đó là
trường hợp nói chung phụ thuộc vào trạng thái của thiết bị trước hệ thống nhất định
chu trình tạm dừng-tiếp tục và loại chuyển đổi hệ thống đang diễn ra.
Đặc biệt, các quá trình chuyển đổi "tan băng" và "khôi phục" liên quan đến chế độ ngủ đông là
hoàn toàn không bị ảnh hưởng bởi ZZ0001ZZ.  [Tất cả các lệnh gọi lại đều
được ban hành trong quá trình chuyển đổi "khôi phục" bất kể cài đặt cờ,
và có hay không có cuộc gọi lại trình điều khiển nào
được bỏ qua trong quá trình chuyển đổi "tan băng" tùy thuộc vào việc
Cờ ZZ0002ZZ được đặt (xem ZZ0003ZZ).
Ngoài ra, một thiết bị không được phép duy trì trạng thái tạm dừng thời gian chạy nếu bất kỳ lỗi nào của nó
trẻ em sẽ được trả lại toàn bộ sức mạnh.]

Cờ ZZ0003ZZ được tính đến khi kết hợp với
bit trạng thái ZZ0000ZZ được thiết lập bởi lõi PM trong quá trình
Giai đoạn "tạm dừng" của quá trình chuyển đổi kiểu tạm dừng.  Nếu trình điều khiển hoặc lớp giữa
có lý do để ngăn chặn việc tiếp tục gọi lại "noirq" và "sớm" của trình điều khiển từ
bị bỏ qua trong quá trình chuyển đổi tiếp tục hệ thống tiếp theo, nó sẽ
xóa ZZ0001ZZ trong ZZ0004ZZ, ZZ0005ZZ của nó
hoặc gọi lại ZZ0006ZZ.  [Lưu ý rằng cài đặt trình điều khiển
ZZ0007ZZ cần xóa ZZ0002ZZ trong
cuộc gọi lại ZZ0008ZZ của họ trong trường hợp hai cái còn lại bị bỏ qua.]

Đặt bit trạng thái ZZ0000ZZ cùng với
Cờ ZZ0002ZZ là cần thiết, nhưng nhìn chung là không đủ,
để bỏ qua các cuộc gọi lại tiếp tục "noirq" và "sớm" của người lái xe.  Có hay không
không nên bỏ qua chúng có thể được xác định bằng cách đánh giá
Chức năng trợ giúp ZZ0001ZZ.

Nếu hàm đó trả về ZZ0000ZZ, trình điều khiển sẽ tiếp tục "noirq" và "sớm"
nên bỏ qua các cuộc gọi lại và trạng thái PM thời gian chạy của thiết bị sẽ được đặt thành
"treo" bởi lõi PM.  Mặt khác, nếu thiết bị bị treo trong thời gian chạy
trong quá trình chuyển đổi tạm dừng toàn hệ thống trước đó và
ZZ0001ZZ được đặt, trạng thái PM thời gian chạy của nó sẽ được đặt thành
"hoạt động" bởi lõi PM.  [Do đó, các trình điều khiển không được thiết lập
ZZ0002ZZ không nên mong đợi trạng thái PM thời gian chạy của chúng
các thiết bị được lõi PM thay đổi từ "bị treo" thành "hoạt động" trong
chuyển đổi loại sơ yếu lý lịch trên toàn hệ thống.]

Nếu cờ ZZ0000ZZ không được đặt cho một thiết bị, nhưng
ZZ0001ZZ được thiết lập và chế độ tạm dừng "muộn" và "noirq" của người lái xe
các cuộc gọi lại bị bỏ qua, các cuộc gọi lại "noirq" và "sớm" trên toàn hệ thống sẽ tiếp tục lại, nếu
hiện tại, được gọi như bình thường và trạng thái PM thời gian chạy của thiết bị được đặt thành
"hoạt động" bởi lõi PM trước khi kích hoạt PM thời gian chạy cho nó.  Trong trường hợp đó,
người lái xe phải chuẩn bị sẵn sàng để đối phó với việc yêu cầu sơ yếu lý lịch trên toàn hệ thống của mình
gọi lại liên tục với ZZ0002ZZ của nó (không có
can thiệp vào ZZ0003ZZ và các lệnh gọi lại tạm dừng trên toàn hệ thống) và
trạng thái cuối cùng của thiết bị phải phản ánh trạng thái PM thời gian chạy "hoạt động" trong đó
trường hợp.  [Lưu ý rằng đây hoàn toàn không phải là vấn đề nếu trình điều khiển
Con trỏ gọi lại ZZ0004ZZ trỏ đến cùng chức năng với nó
ZZ0005ZZ một và con trỏ gọi lại ZZ0006ZZ của nó trỏ tới
chức năng tương tự như ZZ0007ZZ, trong khi không có chức năng nào khác
Ví dụ: có các lệnh gọi lại tạm dừng-tiếp tục trên toàn hệ thống của trình điều khiển.]

Tương tự, nếu ZZ0000ZZ được đặt cho một thiết bị, trình điều khiển của nó
các cuộc gọi lại tiếp tục "noirq" và "sớm" trên toàn hệ thống có thể bị bỏ qua trong khi "muộn"
và lệnh gọi lại tạm dừng "noirq" có thể đã được thực thi (về nguyên tắc, bất kể
về việc ZZ0001ZZ có được đặt hay không).  Trong trường hợp đó, người lái xe
cần có khả năng đối phó với lệnh gọi ZZ0002ZZ của nó
gọi lại liên tục với các lệnh tạm dừng "muộn" và "noirq".  [Ví dụ,
đó không phải là vấn đề đáng lo ngại nếu trình điều khiển đặt cả ZZ0003ZZ và
ZZ0004ZZ và sử dụng cùng một cặp gọi lại tạm dừng/tiếp tục
các chức năng dành cho PM thời gian chạy và tạm dừng/tiếp tục trên toàn hệ thống.]