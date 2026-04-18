.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/pci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Quản lý năng lượng PCI
====================

Bản quyền (c) 2010 Rafael J. Wysocki <rjw@sisk.pl>, Novell Inc.

Tổng quan về các khái niệm và giao diện của nhân Linux liên quan đến sức mạnh PCI
quản lý.  Dựa trên tác phẩm trước đây của Patrick Mochel <mochel@transmeta.com>
(và những người khác).

Tài liệu này chỉ đề cập đến các khía cạnh quản lý năng lượng dành riêng cho PCI
thiết bị.  Để biết mô tả chung về các giao diện của kernel liên quan đến thiết bị
quản lý năng lượng tham khảo Documentation/driver-api/pm/device.rst và
Tài liệu/sức mạnh/runtime_pm.rst.

.. contents:

   1. Hardware and Platform Support for PCI Power Management
   2. PCI Subsystem and Device Power Management
   3. PCI Device Drivers and Power Management
   4. Resources


1. Hỗ trợ phần cứng và nền tảng cho quản lý năng lượng PCI
=========================================================

1.1. Quản lý năng lượng dựa trên nền tảng và gốc
-----------------------------------------------

Nói chung, quản lý năng lượng là một tính năng cho phép người ta tiết kiệm năng lượng bằng cách đặt
thiết bị sang trạng thái tiêu thụ ít năng lượng hơn (trạng thái năng lượng thấp) ở mức
giá của chức năng hoặc hiệu suất giảm.

Thông thường, một thiết bị sẽ ở trạng thái năng lượng thấp khi không được sử dụng đúng mức hoặc
hoàn toàn không hoạt động.  Tuy nhiên, khi cần sử dụng thiết bị một lần
một lần nữa, nó phải được đưa trở lại trạng thái "đầy đủ chức năng" (đầy đủ năng lượng).
trạng thái).  Điều này có thể xảy ra khi có một số dữ liệu cần thiết bị xử lý hoặc
do một sự kiện bên ngoài yêu cầu thiết bị phải hoạt động, điều này có thể
được báo hiệu bởi chính thiết bị đó.

Các thiết bị PCI có thể được đưa vào trạng thái năng lượng thấp theo hai cách, bằng cách sử dụng thiết bị
các khả năng được giới thiệu bởi Đặc tả giao diện quản lý nguồn xe buýt PCI,
hoặc với sự trợ giúp của chương trình cơ sở nền tảng, chẳng hạn như ACPI BIOS.  trong lần đầu tiên
phương pháp tiếp cận này, được gọi là quản lý năng lượng PCI gốc (PCI PM gốc)
trong phần tiếp theo, trạng thái nguồn của thiết bị được thay đổi do việc ghi một
giá trị cụ thể vào một trong các thanh ghi cấu hình tiêu chuẩn của nó.  thứ hai
Cách tiếp cận này yêu cầu phần sụn nền tảng cung cấp các phương pháp đặc biệt có thể
được kernel sử dụng để thay đổi trạng thái nguồn của thiết bị.

Các thiết bị hỗ trợ PCI PM gốc thường có thể tạo ra tín hiệu đánh thức được gọi là
Sự kiện quản lý nguồn (PME) để cho kernel biết về các sự kiện bên ngoài
yêu cầu thiết bị phải hoạt động.  Sau khi nhận được PME, kernel được cho là
để đưa thiết bị đã gửi nó vào trạng thái toàn năng.  Tuy nhiên, Xe buýt PCI
Đặc tả giao diện quản lý nguồn không xác định bất kỳ phương pháp tiêu chuẩn nào của
phân phối PME từ thiết bị tới CPU và nhân hệ điều hành.
Giả định rằng phần sụn nền tảng sẽ thực hiện nhiệm vụ này và do đó,
mặc dù thiết bị PCI được thiết lập để tạo PME, nhưng cũng có thể cần phải
chuẩn bị chương trình cơ sở nền tảng để thông báo cho CPU về các PME đến từ
thiết bị (ví dụ: bằng cách tạo ra các ngắt).

Đổi lại, nếu các phương thức được cung cấp bởi phần sụn nền tảng được sử dụng để thay đổi
trạng thái nguồn của thiết bị, thông thường nền tảng cũng cung cấp phương pháp để
chuẩn bị cho thiết bị phát ra tín hiệu đánh thức.  Tuy nhiên, trong trường hợp đó, nó
thường cũng cần thiết để chuẩn bị thiết bị tạo PME bằng cách sử dụng
Cơ chế PCI PM gốc, vì phương thức được nền tảng cung cấp phụ thuộc vào
đó.

Do đó, trong nhiều tình huống, cả quản lý năng lượng gốc và dựa trên nền tảng đều
cơ chế phải được sử dụng đồng thời để đạt được kết quả mong muốn.

1.2. Quản lý năng lượng PCI gốc
--------------------------------

Đặc tả giao diện quản lý nguồn bus PCI (Thông số PCI PM) là
được giới thiệu giữa Thông số kỹ thuật PCI 2.1 và PCI 2.2.  Nó đã định nghĩa một
giao diện chuẩn để thực hiện các hoạt động khác nhau liên quan đến nguồn điện
quản lý.

Việc triển khai PCI PM Spec là tùy chọn cho các thiết bị PCI thông thường,
nhưng nó là bắt buộc đối với các thiết bị PCI Express.  Nếu thiết bị hỗ trợ PCI PM
Thông số kỹ thuật, nó có trường khả năng quản lý nguồn 8 byte trong PCI của nó
không gian cấu hình.  Trường này được sử dụng để mô tả và kiểm soát tiêu chuẩn
các tính năng liên quan đến quản lý năng lượng PCI gốc.

PCI PM Spec xác định 4 trạng thái hoạt động cho thiết bị (D0-D3) và cho xe buýt
(B0-B3).  Con số càng cao thì thiết bị hoặc bus càng tiêu thụ ít điện năng hơn
ở trạng thái đó.  Tuy nhiên, số càng cao thì độ trễ càng dài.
thiết bị hoặc bus trở về trạng thái nguồn đầy đủ (tương ứng là D0 hoặc B0).

Có hai biến thể của trạng thái D3 được xác định theo thông số kỹ thuật.  đầu tiên
một là D3hot, được gọi là phần mềm có thể truy cập D3, vì các thiết bị có thể
được lập trình để đi vào đó.  Cái thứ hai, D3cold, là trạng thái mà thiết bị PCI
vào khi điện áp cung cấp (Vcc) bị loại bỏ khỏi chúng.  Không thể được
để lập trình cho thiết bị PCI đi vào D3cold, mặc dù có thể có một thiết bị có thể lập trình được
giao diện để đưa bus của thiết bị vào trạng thái Vcc
được xóa khỏi tất cả các thiết bị trên xe buýt.

Tuy nhiên, quản lý nguồn bus PCI không được nhân Linux hỗ trợ tại
thời điểm viết bài này và do đó nó không được đề cập trong tài liệu này.

Lưu ý rằng mọi thiết bị PCI đều có thể ở trạng thái toàn năng (D0) hoặc ở D3cold,
bất kể nó có triển khai PCI PM Spec hay không.  Ngoài ra
rằng, nếu PCI PM Spec được thiết bị triển khai thì nó phải hỗ trợ D3hot
cũng như D0.  Việc hỗ trợ trạng thái nguồn D1 và D2 ​​là tùy chọn.

Các thiết bị PCI hỗ trợ PCI PM Spec có thể được lập trình để truy cập bất kỳ
hỗ trợ các trạng thái năng lượng thấp (ngoại trừ D3cold).  Trong khi ở D1-D3hot
các thanh ghi cấu hình tiêu chuẩn của thiết bị phải có thể truy cập được bằng phần mềm
(tức là thiết bị được yêu cầu phản hồi các truy cập cấu hình PCI), mặc dù
I/O và không gian bộ nhớ của nó sau đó sẽ bị vô hiệu hóa.  Điều này cho phép thiết bị có thể
được lập trình đưa vào D0.  Do đó kernel có thể chuyển thiết bị trở lại và
giữa D0 và các trạng thái năng lượng thấp được hỗ trợ (ngoại trừ D3cold) và
các chuyển đổi trạng thái nguồn có thể xảy ra mà thiết bị có thể trải qua như sau:

+-----------------------------+
ZZ0000ZZ Trạng thái mới |
+-----------------------------+
ZZ0001ZZ D1, D2, D3 |
+-----------------------------+
ZZ0002ZZ D2, D3 |
+-----------------------------+
ZZ0003ZZ D3 |
+-----------------------------+
ZZ0004ZZ D0 |
+-----------------------------+

Quá trình chuyển đổi từ D3cold sang D0 xảy ra khi điện áp nguồn được cung cấp cho
thiết bị (tức là nguồn điện được phục hồi).  Trong trường hợp đó thiết bị trở về D0 với
trình tự đặt lại bật nguồn đầy đủ và các giá trị mặc định khi bật nguồn được khôi phục về
thiết bị bằng phần cứng giống như lúc bật nguồn ban đầu.

Các thiết bị PCI hỗ trợ PCI PM Spec có thể được lập trình để tạo PME
khi ở bất kỳ trạng thái nguồn nào (D0-D3), nhưng họ không bắt buộc phải có khả năng
tạo ra PME từ tất cả các trạng thái năng lượng được hỗ trợ.  Đặc biệt,
khả năng tạo PME từ D3cold là tùy chọn và phụ thuộc vào
sự hiện diện của điện áp bổ sung (3,3Vaux) cho phép thiết bị duy trì
đủ hoạt động để tạo ra tín hiệu đánh thức.

1.3. Quản lý năng lượng thiết bị ACPI
---------------------------------

Hỗ trợ phần sụn nền tảng để quản lý năng lượng của các thiết bị PCI là
mang tính hệ thống cụ thể.  Tuy nhiên, nếu hệ thống được đề cập tuân thủ các
Thông số kỹ thuật cấu hình nâng cao và giao diện nguồn (ACPI), như
phần lớn các hệ thống dựa trên x86, nó được cho là sẽ triển khai sức mạnh của thiết bị
giao diện quản lý được xác định theo tiêu chuẩn ACPI.

Với mục đích này, ACPI BIOS cung cấp các chức năng đặc biệt gọi là "điều khiển
Method" có thể được kernel thực thi để thực hiện các tác vụ cụ thể, chẳng hạn như
đưa thiết bị vào trạng thái năng lượng thấp.  Các phương pháp điều khiển này được mã hóa
sử dụng ngôn ngữ mã byte đặc biệt gọi là Ngôn ngữ máy ACPI (AML) và
được lưu trữ trong BIOS của máy.  Hạt nhân tải chúng từ BIOS và thực thi
chúng khi cần bằng cách sử dụng trình thông dịch AML để dịch mã byte AML sang
tính toán và truy cập bộ nhớ hoặc không gian I/O.  Theo lý thuyết, theo cách này, BIOS
người viết có thể cung cấp cho kernel một phương tiện để thực hiện các hành động tùy thuộc vào
về thiết kế hệ thống theo cách dành riêng cho hệ thống.

Các phương pháp điều khiển ACPI có thể được chia thành các phương pháp điều khiển chung, không
được liên kết với bất kỳ thiết bị cụ thể nào và các phương pháp điều khiển thiết bị có
được xác định riêng cho từng thiết bị được xử lý với sự trợ giúp của
nền tảng.  Điều này đặc biệt có nghĩa là các phương pháp điều khiển thiết bị ACPI có thể
chỉ được sử dụng để xử lý các thiết bị mà người viết BIOS đã biết trước.  các
Các phương pháp ACPI được sử dụng để quản lý nguồn điện của thiết bị thuộc loại đó.

Thông số ACPI giả định rằng các thiết bị có thể ở một trong bốn trạng thái nguồn
được gắn nhãn là D0, D1, D2 và D3 gần tương ứng với PCI PM gốc
Trạng thái D0-D3 (mặc dù không tính đến sự khác biệt giữa D3hot và D3cold
được tính đến bởi ACPI).  Hơn nữa, đối với mỗi trạng thái năng lượng của thiết bị có một
tập hợp các nguồn năng lượng phải được kích hoạt để đưa thiết bị vào
trạng thái đó.  Các nguồn năng lượng này được kiểm soát (tức là được bật hoặc tắt)
với sự trợ giúp của các phương pháp điều khiển riêng của họ, _ON và _OFF, phải
được xác định riêng cho từng người trong số họ.

Để đặt thiết bị vào trạng thái nguồn ACPI Dx (trong đó x là một số từ 0 đến
3) hạt nhân có nhiệm vụ (1) kích hoạt các nguồn năng lượng cần thiết
bởi thiết bị ở trạng thái này bằng các phương pháp điều khiển _ON của họ và (2) thực thi
_Phương thức điều khiển PSx được xác định cho thiết bị.  Ngoài ra, nếu thiết bị
sẽ được đưa vào trạng thái năng lượng thấp (D1-D3) và được cho là sẽ tạo ra
tín hiệu đánh thức từ trạng thái đó, _DSW (hoặc _PSW, được thay thế bằng _DSW bởi ACPI
3.0) được xác định cho nó phải được thực thi trước _PSx.  quyền lực
các tài nguyên không được thiết bị yêu cầu ở trạng thái nguồn mục tiêu và
không được yêu cầu nữa bởi bất kỳ thiết bị nào khác sẽ bị vô hiệu hóa (bằng cách thực thi
Phương pháp điều khiển _OFF).  Nếu trạng thái nguồn hiện tại của thiết bị là D3, nó có thể
chỉ được đưa vào D0 theo cách này.

Tuy nhiên, trạng thái nguồn của thiết bị thường xuyên bị thay đổi trong quá trình sử dụng.
chuyển toàn hệ thống sang trạng thái ngủ hoặc trở lại trạng thái làm việc.  ACPI
xác định bốn trạng thái ngủ của hệ thống, S1, S2, S3 và S4 và biểu thị hệ thống
trạng thái làm việc là S0.  Nói chung, trạng thái ngủ (hoặc làm việc) của hệ thống đích
xác định trạng thái công suất cao nhất (số thấp nhất) mà thiết bị có thể được đặt
vào và kernel có nhiệm vụ lấy thông tin này bằng cách thực thi lệnh
phương thức điều khiển _SxD của thiết bị (trong đó x là một số nằm trong khoảng từ 0 đến 4).
Nếu thiết bị được yêu cầu đánh thức hệ thống từ trạng thái ngủ mục tiêu,
Trạng thái có công suất thấp nhất (số cao nhất) mà nó có thể được đưa vào cũng được xác định bởi
trạng thái mục tiêu của hệ thống.  Hạt nhân sau đó được cho là sẽ sử dụng
_Phương pháp điều khiển SxW để lấy số trạng thái đó.  Nó cũng được cho là
sử dụng phương pháp điều khiển _PRW của thiết bị để tìm hiểu nguồn năng lượng nào cần được
được kích hoạt để thiết bị có thể tạo tín hiệu đánh thức.

1.4. Báo hiệu thức dậy
---------------------

Tín hiệu đánh thức được tạo bởi các thiết bị PCI, dưới dạng PME PCI gốc hoặc dưới dạng
là kết quả của việc thực hiện phương pháp điều khiển _DSW (hoặc _PSW) ACPI trước đó
đưa thiết bị vào trạng thái pin yếu, phải bắt và xử lý như
thích hợp.  Nếu chúng được gửi trong khi hệ thống đang ở trạng thái hoạt động
(ACPI S0), chúng nên được dịch thành các ngắt để kernel có thể
đưa các thiết bị tạo ra chúng vào trạng thái hoạt động hết công suất và xử lý
những sự kiện đã kích hoạt chúng.  Ngược lại, nếu chúng được gửi trong khi hệ thống đang
đang ngủ, chúng sẽ khiến logic cốt lõi của hệ thống kích hoạt hoạt động đánh thức.

Trên các hệ thống dựa trên ACPI, tín hiệu đánh thức được gửi bởi các thiết bị PCI thông thường là
được chuyển đổi thành Sự kiện mục đích chung ACPI (GPE) là tín hiệu phần cứng
từ logic cốt lõi của hệ thống được tạo ra để đáp ứng với các sự kiện khác nhau cần
được hành động.  Mỗi GPE được liên kết với một hoặc nhiều nguồn có khả năng
sự kiện thú vị.  Cụ thể, GPE có thể được liên kết với thiết bị PCI
có khả năng báo hiệu sự thức dậy.  Thông tin về kết nối giữa các GPE
và các nguồn sự kiện được ghi lại trong ACPI BIOS của hệ thống từ nơi có thể
được đọc bởi kernel.

Nếu một thiết bị PCI được biết đến với tín hiệu ACPI BIOS của hệ thống, thì GPE
liên kết với nó (nếu có) được kích hoạt.  Các GPE được liên kết với PCI
cầu nối cũng có thể được kích hoạt để đáp lại tín hiệu đánh thức từ một trong các
các thiết bị bên dưới cầu (điều này cũng xảy ra với cầu gốc) và, đối với
ví dụ: PME PCI gốc từ các thiết bị không xác định đối với ACPI BIOS của hệ thống có thể
xử lý theo cách này.

GPE có thể được kích hoạt khi hệ thống đang ngủ (tức là khi nó ở một trong các chế độ
trạng thái ACPI S1-S4), trong trường hợp đó, việc đánh thức hệ thống được bắt đầu bằng logic cốt lõi của nó
(thiết bị là nguồn tín hiệu gây ra hiện tượng đánh thức hệ thống
có thể được xác định sau).  GPE được sử dụng trong những tình huống như vậy được gọi là
đánh thức GPE.

Tuy nhiên, thông thường, GPE cũng được kích hoạt khi hệ thống đang hoạt động.
trạng thái (ACPI S0) và trong trường hợp đó logic cốt lõi của hệ thống tạo ra một Hệ thống
Kiểm soát ngắt (SCI) để thông báo cho kernel về sự kiện.  Sau đó, SCI
trình xử lý xác định GPE gây ra ngắt được tạo ra,
lần lượt, cho phép kernel xác định nguồn gốc của sự kiện (có thể là
thiết bị PCI báo hiệu đánh thức).  GPE được sử dụng để thông báo cho kernel của
các sự kiện xảy ra khi hệ thống đang ở trạng thái làm việc được gọi là
GPE thời gian chạy.

Thật không may, không có cách tiêu chuẩn nào để xử lý các tín hiệu đánh thức được gửi bởi
các thiết bị PCI thông thường trên các hệ thống không dựa trên ACPI, nhưng có một
cho các thiết bị PCI Express.  Cụ thể, PCI Express Base đã giới thiệu Thông số kỹ thuật
một cơ chế riêng để chuyển đổi PME PCI gốc thành các ngắt được tạo bởi
cổng gốc.  Đối với các thiết bị PCI thông thường, PME gốc nằm ngoài băng tần, vì vậy chúng
được định tuyến riêng và chúng không cần phải đi qua cầu (về nguyên tắc chúng
có thể được định tuyến trực tiếp đến logic cốt lõi của hệ thống), nhưng đối với các thiết bị PCI Express
chúng là các tin nhắn trong băng tần phải đi qua hệ thống phân cấp PCI Express,
bao gồm cổng gốc trên đường dẫn từ thiết bị tới Root Complex.  Như vậy
có thể giới thiệu một cơ chế mà cổng gốc tạo ra một
ngắt bất cứ khi nào nó nhận được tin nhắn PME từ một trong các thiết bị bên dưới nó.
Sau đó, ID người yêu cầu nhanh PCI của thiết bị đã gửi tin nhắn PME là
được ghi vào một trong các thanh ghi cấu hình của cổng gốc từ nơi nó có thể được lưu trữ.
được đọc bởi trình xử lý ngắt cho phép nhận dạng thiết bị.  [PME
các tin nhắn được gửi bởi các điểm cuối PCI Express được tích hợp với Root Complex thì không
đi qua các cổng gốc, nhưng thay vào đó chúng gây ra Trình thu thập sự kiện phức tạp gốc
(nếu có) để tạo ra các ngắt.]

Về nguyên tắc, tín hiệu PCI Express PME gốc cũng có thể được sử dụng trên nền tảng ACPI
các hệ thống cùng với GPE, nhưng để sử dụng nó, kernel phải yêu cầu hệ thống
ACPI BIOS để giải phóng quyền kiểm soát các thanh ghi cấu hình cổng gốc.  ACPI
Tuy nhiên, BIOS không bắt buộc phải cho phép kernel kiểm soát các thanh ghi này
và nếu không làm được điều đó thì kernel không được sửa đổi nội dung của chúng.  Tất nhiên
kernel không thể sử dụng tín hiệu PCI Express PME gốc trong trường hợp đó.


2. Quản lý nguồn thiết bị và hệ thống con PCI
============================================

2.1. Lệnh gọi lại quản lý nguồn thiết bị
--------------------------------------

Hệ thống con PCI tham gia quản lý năng lượng của các thiết bị PCI theo cách
số cách.  Trước hết, nó cung cấp một lớp mã trung gian giữa
lõi quản lý nguồn thiết bị (lõi PM) và trình điều khiển thiết bị PCI.
Cụ thể, trường chiều của đối tượng struct bus_type của hệ thống con PCI,
pci_bus_type, trỏ tới đối tượng struct dev_pm_ops, pci_dev_pm_ops, chứa
con trỏ tới một số lệnh gọi lại quản lý nguồn thiết bị::

const struct dev_pm_ops pci_dev_pm_ops = {
	.prepare = pci_pm_prepare,
	.complete = pci_pm_complete,
	.suspend = pci_pm_suspend,
	.resume = pci_pm_resume,
	.freeze = pci_pm_freeze,
	.thaw = pci_pm_thaw,
	.poweroff = pci_pm_poweroff,
	.restore = pci_pm_restore,
	.suspend_noirq = pci_pm_suspend_noirq,
	.resume_noirq = pci_pm_resume_noirq,
	.freeze_noirq = pci_pm_freeze_noirq,
	.thaw_noirq = pci_pm_thaw_noirq,
	.poweroff_noirq = pci_pm_poweroff_noirq,
	.restore_noirq = pci_pm_restore_noirq,
	.runtime_suspend = pci_pm_runtime_suspend,
	.runtime_resume = pci_pm_runtime_resume,
	.runtime_idle = pci_pm_runtime_idle,
  };

Các cuộc gọi lại này được thực thi bởi lõi PM trong các tình huống khác nhau liên quan đến
quản lý năng lượng của thiết bị và lần lượt chúng thực hiện các cuộc gọi lại quản lý năng lượng
được cung cấp bởi trình điều khiển thiết bị PCI.  Họ cũng thực hiện các hoạt động quản lý năng lượng
liên quan đến một số thanh ghi cấu hình tiêu chuẩn của thiết bị PCI mà thiết bị đó
người lái xe không cần biết hoặc quan tâm.

Cấu trúc đại diện cho thiết bị PCI, struct pci_dev, chứa một số trường
rằng các lệnh gọi lại này hoạt động trên::

cấu trúc pci_dev {
	...
pci_power_t current_state;  /* Trạng thái hoạt động hiện tại. */
	int pm_cap;		/* Độ lệch khả năng PM trong
					   không gian cấu hình */
	unsigned int pme_support:5;	/* Bitmask của các trạng thái mà PME#
					   can được tạo ra */
	unsigned int pme_poll:1;	/* Bit trạng thái PME của thiết bị thăm dò */
	unsigned int d1_support:1;	/* Trạng thái năng lượng thấp D1 được hỗ trợ */
	unsigned int d2_support:1;	/* Trạng thái năng lượng thấp D2 được hỗ trợ */
	unsign int no_d1d2:1;	/* D1 và D2 bị cấm */
	int unsign Wakeup_prepared:1;  /* Thiết bị được chuẩn bị đánh thức */
	unsigned int d3hot_delay;	/* D3hot->Thời gian chuyển tiếp D0 tính bằng ms */
	...
  };

Họ cũng gián tiếp sử dụng một số trường của thiết bị cấu trúc được nhúng trong
cấu trúc pci_dev.

2.2. Khởi tạo thiết bị
--------------------------

Nhiệm vụ đầu tiên của hệ thống con PCI liên quan đến quản lý nguồn điện của thiết bị là
chuẩn bị thiết bị để quản lý nguồn và khởi tạo các trường cấu trúc
pci_dev được sử dụng cho mục đích này.  Điều này xảy ra trong hai hàm được xác định trong
trình điều khiển/pci/, pci_pm_init() và pci_acpi_setup().

Chức năng đầu tiên trong số này sẽ kiểm tra xem thiết bị có hỗ trợ PCI PM gốc hay không
và nếu đúng như vậy thì sự bù đắp của cấu trúc năng lực quản lý năng lượng của nó
trong không gian cấu hình được lưu trữ trong trường pm_cap của cấu trúc của thiết bị
đối tượng pci_dev.  Tiếp theo, chức năng kiểm tra trạng thái năng lượng thấp của PCI
được thiết bị hỗ trợ và từ đó thiết bị có thể tạo ra trạng thái năng lượng thấp
PME PCI bản địa.  Các trường quản lý năng lượng của cấu trúc pci_dev của thiết bị và
thiết bị cấu trúc được nhúng trong nó được cập nhật tương ứng và việc tạo ra
PME của thiết bị bị vô hiệu hóa.

Chức năng thứ hai kiểm tra xem thiết bị có thể sẵn sàng phát tín hiệu đánh thức bằng
sự trợ giúp của phần sụn nền tảng, chẳng hạn như ACPI BIOS.  Nếu đúng như vậy,
hàm cập nhật các trường đánh thức trong thiết bị cấu trúc được nhúng trong
struct pci_dev của thiết bị và sử dụng phương pháp do phần sụn cung cấp để ngăn chặn
thiết bị khỏi báo hiệu đánh thức.

Tại thời điểm này, thiết bị đã sẵn sàng để quản lý nguồn điện.  Đối với các thiết bị không có trình điều khiển,
tuy nhiên, chức năng này bị giới hạn ở một số thao tác cơ bản được thực hiện
trong quá trình chuyển đổi toàn hệ thống sang trạng thái ngủ và quay lại trạng thái làm việc.

2.3. Quản lý nguồn thiết bị trong thời gian chạy
------------------------------------

Hệ thống con PCI đóng vai trò quan trọng trong việc quản lý năng lượng thời gian chạy của PCI
thiết bị.  Với mục đích này, nó sử dụng quản lý năng lượng thời gian chạy chung
(runtime PM) được mô tả trong Documentation/power/runtime_pm.rst.
Cụ thể, nó cung cấp các cuộc gọi lại ở cấp hệ thống con::

pci_pm_runtime_suspend()
	pci_pm_runtime_resume()
	pci_pm_runtime_idle()

được thực thi bởi các thủ tục PM thời gian chạy cốt lõi.  Nó cũng thực hiện các
toàn bộ cơ chế cần thiết để xử lý tín hiệu đánh thức thời gian chạy từ các thiết bị PCI
ở các trạng thái năng lượng thấp, tại thời điểm viết bài này có hiệu quả đối với cả người bản địa
Tín hiệu PCI Express PME và tín hiệu đánh thức dựa trên ACPI GPE được mô tả trong
Phần 1.

Đầu tiên, thiết bị PCI được đưa vào trạng thái năng lượng thấp hoặc bị treo với sự trợ giúp
của pm_schedule_suspend() hoặc pm_runtime_suspend() dành cho thiết bị PCI gọi
pci_pm_runtime_suspend() để thực hiện công việc thực tế.  Để làm việc này, thiết bị
trình điều khiển phải cung cấp lệnh gọi lại pm->runtime_suspend() (xem bên dưới), đó là
được điều hành bởi pci_pm_runtime_suspend() làm hành động đầu tiên.  Nếu tài xế gọi lại
trả về thành công, các thanh ghi cấu hình tiêu chuẩn của thiết bị được lưu,
thiết bị được chuẩn bị để tạo ra tín hiệu đánh thức và cuối cùng, nó được đưa vào
trạng thái năng lượng thấp mục tiêu.

Trạng thái nguồn điện thấp để đưa thiết bị vào là nguồn điện thấp nhất (số cao nhất)
trạng thái mà nó có thể báo hiệu sự thức dậy.  Phương pháp chính xác để báo hiệu sự thức dậy là
phụ thuộc vào hệ thống và được xác định bởi hệ thống con PCI trên cơ sở
khả năng được báo cáo của thiết bị và phần sụn nền tảng.  Để chuẩn bị
thiết bị báo hiệu đánh thức và đưa nó vào trạng thái năng lượng thấp đã chọn,
Hệ thống con PCI có thể sử dụng chương trình cơ sở nền tảng cũng như PCI gốc của thiết bị
Khả năng PM, nếu được hỗ trợ.

Dự kiến lệnh gọi lại pm->runtime_suspend() của trình điều khiển thiết bị sẽ
không cố gắng chuẩn bị cho thiết bị báo hiệu đánh thức hoặc đặt thiết bị vào trạng thái
trạng thái năng lượng thấp.  Người lái xe nên giao các nhiệm vụ này cho hệ thống con PCI
có tất cả thông tin cần thiết để thực hiện chúng.

Một thiết bị bị treo được đưa trở lại trạng thái "hoạt động" hoặc được tiếp tục lại,
với sự trợ giúp của pm_request_resume() hoặc pm_runtime_resume() mà cả hai đều gọi
pci_pm_runtime_resume() cho thiết bị PCI.  Một lần nữa, điều này chỉ hoạt động nếu thiết bị
trình điều khiển cung cấp lệnh gọi lại pm->runtime_resume() (xem bên dưới).  Tuy nhiên, trước
lệnh gọi lại của trình điều khiển được thực thi, pci_pm_runtime_resume() mang thiết bị đến
trở lại trạng thái toàn năng, ngăn không cho nó báo hiệu sự thức dậy khi ở trạng thái đó
trạng thái và khôi phục các thanh ghi cấu hình tiêu chuẩn của nó.  Như vậy người lái xe
gọi lại không cần phải lo lắng về các khía cạnh dành riêng cho PCI của sơ yếu lý lịch thiết bị.

Lưu ý rằng nói chung pci_pm_runtime_resume() có thể được gọi theo hai cách khác nhau
tình huống.  Đầu tiên, nó có thể được gọi theo yêu cầu của trình điều khiển thiết bị, vì
ví dụ nếu có một số dữ liệu để nó xử lý.  Thứ hai, nó có thể được gọi là
do tín hiệu đánh thức từ chính thiết bị (điều này đôi khi
được gọi là "đánh thức từ xa").  Tất nhiên, với mục đích này, tín hiệu đánh thức
được xử lý theo một trong những cách được mô tả ở Phần 1 và cuối cùng được chuyển thành
thông báo cho hệ thống con PCI sau khi thiết bị nguồn được kết nối
được xác định.

Hàm pci_pm_runtime_idle(), được gọi cho các thiết bị PCI bởi pm_runtime_idle()
và pm_request_idle(), thực thi lệnh pm->runtime_idle() của trình điều khiển thiết bị
gọi lại, nếu được xác định và nếu lệnh gọi lại đó không trả về mã lỗi (hoặc không
hiện tại), tạm dừng thiết bị với sự trợ giúp của pm_runtime_suspend().
Đôi khi pci_pm_runtime_idle() được gọi tự động bởi lõi PM (đối với
ví dụ, nó được gọi ngay sau khi thiết bị vừa được nối lại), trong đó
trường hợp dự kiến ​​sẽ tạm dừng thiết bị nếu điều đó hợp lý.  Thông thường,
tuy nhiên, hệ thống con PCI không thực sự biết liệu thiết bị có thực sự có thể hoạt động được hay không.
bị tạm dừng, do đó nó cho phép trình điều khiển của thiết bị quyết định bằng cách chạy
gọi lại pm->runtime_idle().

2.4. Chuyển đổi quyền lực trên toàn hệ thống
----------------------------------
Có một số loại chuyển đổi quyền lực trên toàn hệ thống khác nhau, được mô tả trong
Tài liệu/driver-api/pm/devices.rst.  Mỗi người trong số họ yêu cầu các thiết bị phải
được xử lý theo một cách cụ thể và lõi PM thực thi quyền lực ở cấp hệ thống con
cuộc gọi lại quản lý cho mục đích này.  Chúng được thực hiện theo từng giai đoạn sao cho
mỗi giai đoạn liên quan đến việc thực hiện lệnh gọi lại cấp hệ thống con giống nhau cho mọi thiết bị
thuộc về hệ thống con đã cho trước khi giai đoạn tiếp theo bắt đầu.  Những giai đoạn này
luôn chạy sau khi nhiệm vụ đã bị đóng băng.

2.4.1. Hệ thống tạm dừng
^^^^^^^^^^^^^^^^^^^^^

Khi hệ thống chuyển sang trạng thái ngủ, trong đó nội dung của bộ nhớ sẽ
được bảo tồn, chẳng hạn như một trong các trạng thái ngủ của ACPI S1-S3, các giai đoạn là:

chuẩn bị, đình chỉ, đình chỉ_noirq.

Các lệnh gọi lại của loại bus PCI sau đây, tương ứng, được sử dụng trong các giai đoạn sau::

pci_pm_prepare()
	pci_pm_suspend()
	pci_pm_suspend_noirq()

Quy trình pci_pm_prepare() trước tiên sẽ đưa thiết bị vào trạng thái "đầy đủ chức năng"
trạng thái với sự trợ giúp của pm_runtime_resume().  Sau đó, nó thực thi thiết bị
lệnh gọi lại pm->prepare() của trình điều khiển nếu được xác định (tức là nếu cấu trúc của trình điều khiển
đối tượng dev_pm_ops hiện diện và con trỏ chuẩn bị trong đối tượng đó hợp lệ).

Quy trình pci_pm_suspend() trước tiên sẽ kiểm tra xem trình điều khiển của thiết bị có thực hiện
Các thói quen tạm dừng PCI kế thừa (xem Phần 3), trong trường hợp đó, kế thừa của trình điều khiển
tạm dừng cuộc gọi lại được thực thi, nếu có và kết quả của nó được trả về.  Tiếp theo, nếu
trình điều khiển của thiết bị không cung cấp đối tượng struct dev_pm_ops (chứa
con trỏ tới các lệnh gọi lại của trình điều khiển), pci_pm_default_suspend() được gọi,
chỉ cần tắt khả năng tổng thể bus của thiết bị và chạy
pcibios_disable_device() để tắt nó, trừ khi thiết bị là cầu nối (PCI
các cây cầu bị bỏ qua bởi thói quen này).  Tiếp theo, trình điều khiển thiết bị pm->suspend()
cuộc gọi lại được thực thi nếu được xác định và kết quả của nó được trả về nếu thất bại.
Cuối cùng, pci_fixup_device() được gọi để áp dụng các vấn đề liên quan đến đình chỉ phần cứng
vào thiết bị nếu cần thiết.

Lưu ý rằng giai đoạn tạm dừng được thực hiện không đồng bộ đối với các thiết bị PCI, vì vậy
lệnh gọi lại pci_pm_suspend() có thể được thực thi song song cho bất kỳ cặp PCI nào
các thiết bị không phụ thuộc lẫn nhau theo một cách đã biết (tức là không có đường dẫn nào
trong cây thiết bị từ cầu gốc đến thiết bị lá chứa cả hai).

Thói quen pci_pm_suspend_noirq() được thực thi sau khi đình chỉ_device_irqs() có
được gọi, điều đó có nghĩa là trình xử lý ngắt của trình điều khiển thiết bị sẽ không được
được gọi trong khi thủ tục này đang chạy.  Đầu tiên nó sẽ kiểm tra xem trình điều khiển của thiết bị có
triển khai các thói quen tạm dừng PCI kế thừa (Phần 3), trong trường hợp đó, kế thừa
quy trình tạm dừng muộn được gọi và kết quả của nó được trả về (tiêu chuẩn
các thanh ghi cấu hình của thiết bị sẽ được lưu nếu lệnh gọi lại của trình điều khiển không thực hiện được
đã làm điều đó).  Thứ hai, nếu đối tượng struct dev_pm_ops của trình điều khiển thiết bị không
hiện tại, các thanh ghi cấu hình tiêu chuẩn của thiết bị sẽ được lưu và quy trình
trả về thành công.  Nếu không, lệnh gọi lại pm->suspend_noirq() của trình điều khiển thiết bị sẽ là
được thực thi nếu có và kết quả của nó sẽ được trả về nếu thất bại.  Tiếp theo, nếu
thanh ghi cấu hình tiêu chuẩn của thiết bị chưa được lưu (một trong những
lệnh gọi lại của trình điều khiển thiết bị được thực hiện trước đó có thể thực hiện điều đó), pci_pm_suspend_noirq()
lưu chúng, chuẩn bị cho thiết bị phát tín hiệu đánh thức (nếu cần) và đặt thiết bị vào
trạng thái năng lượng thấp.

Trạng thái nguồn điện thấp để đưa thiết bị vào là nguồn điện thấp nhất (số cao nhất)
trạng thái mà từ đó nó có thể báo hiệu sự thức dậy trong khi hệ thống đang ở trạng thái ngủ mục tiêu
trạng thái.  Giống như trong trường hợp PM thời gian chạy được mô tả ở trên, cơ chế của
việc đánh thức tín hiệu phụ thuộc vào hệ thống và được xác định bởi hệ thống con PCI, hệ thống này
cũng chịu trách nhiệm chuẩn bị cho thiết bị phát tín hiệu đánh thức từ hệ thống.
nhắm mục tiêu trạng thái ngủ khi thích hợp.

Trình điều khiển thiết bị PCI (không triển khai lệnh gọi lại quản lý nguồn cũ) là
nói chung là không dự kiến ​​sẽ chuẩn bị các thiết bị báo hiệu đánh thức hoặc đặt chúng
sang trạng thái có năng lượng thấp.  Tuy nhiên, nếu một trong các lệnh gọi lại tạm dừng của trình điều khiển
(pm->suspend() hoặc pm->suspend_noirq()) lưu cấu hình chuẩn của thiết bị
thanh ghi, pci_pm_suspend_noirq() sẽ cho rằng thiết bị đã được chuẩn bị
để ra hiệu cho người lái xe báo thức và đưa vào trạng thái năng lượng thấp (người lái xe đang
sau đó được cho là đã sử dụng các chức năng trợ giúp do hệ thống con PCI cung cấp cho
mục đích này).  Trình điều khiển thiết bị PCI không được khuyến khích làm điều đó, nhưng trong một số
trường hợp hiếm hoi làm điều đó trong trình điều khiển có thể là cách tiếp cận tối ưu.

2.4.2. Tiếp tục hệ thống
^^^^^^^^^^^^^^^^^^^^

Khi hệ thống đang trải qua quá trình chuyển đổi từ trạng thái ngủ, trong đó
nội dung của bộ nhớ đã được bảo toàn, chẳng hạn như một trong các trạng thái ngủ của ACPI
S1-S3, vào trạng thái làm việc (ACPI S0), các pha là:

sơ yếu lý lịch_noirq, sơ yếu lý lịch, hoàn thành.

Các lệnh gọi lại của loại bus PCI sau đây, tương ứng, được thực thi trong các
giai đoạn::

pci_pm_resume_noirq()
	pci_pm_resume()
	pci_pm_complete()

Quy trình pci_pm_resume_noirq() trước tiên sẽ đặt thiết bị ở trạng thái hoạt động hết công suất
trạng thái, khôi phục các thanh ghi cấu hình tiêu chuẩn của nó và áp dụng sơ yếu lý lịch sớm
các vấn đề về phần cứng liên quan đến thiết bị, nếu cần thiết.  Việc này được thực hiện
vô điều kiện, bất kể trình điều khiển của thiết bị có thực hiện hay không
các cuộc gọi lại quản lý nguồn PCI kế thừa (theo cách này, tất cả các thiết bị PCI đều ở trong
trạng thái đầy đủ năng lượng và các thanh ghi cấu hình tiêu chuẩn của chúng đã được khôi phục
khi trình xử lý ngắt của chúng được gọi lần đầu tiên trong quá trình tiếp tục,
cho phép kernel tránh các vấn đề với việc xử lý các ngắt được chia sẻ
bởi những người lái xe có thiết bị vẫn bị treo).  Nếu quản lý nguồn PCI kế thừa
các lệnh gọi lại (xem Phần 3) được thực hiện bởi trình điều khiển của thiết bị, phiên bản kế thừa
lệnh gọi lại sơ yếu lý lịch sớm được thực hiện và kết quả của nó được trả về.  Nếu không,
Lệnh gọi lại pm->resume_noirq() của trình điều khiển thiết bị được thực thi, nếu được xác định và
kết quả được trả về.

Quy trình pci_pm_resume() trước tiên sẽ kiểm tra xem cấu hình tiêu chuẩn của thiết bị có
các thanh ghi đã được khôi phục và khôi phục chúng nếu không đúng như vậy (điều này
chỉ cần thiết trong đường dẫn lỗi trong quá trình tạm dừng không thành công).  Tiếp theo, tiếp tục
các vấn đề về phần cứng liên quan đến thiết bị sẽ được áp dụng, nếu cần thiết và nếu
trình điều khiển của thiết bị triển khai các lệnh gọi lại quản lý nguồn PCI kế thừa (xem
Phần 3), lệnh gọi lại sơ yếu lý lịch kế thừa của trình điều khiển được thực thi và kết quả của nó là
đã quay trở lại.  Nếu không, cơ chế báo hiệu đánh thức của thiết bị sẽ bị chặn và
lệnh gọi lại pm->resume() của trình điều khiển của nó được thực thi, nếu được xác định (lệnh gọi lại của
kết quả sau đó được trả về).

Giai đoạn tiếp tục được thực hiện không đồng bộ cho các thiết bị PCI, như
giai đoạn tạm dừng được mô tả ở trên, điều đó có nghĩa là nếu hai thiết bị PCI không phụ thuộc
với nhau theo một cách đã biết, thủ tục pci_pm_resume() có thể được thực thi cho
cả hai đều song song.

Quy trình pci_pm_complete() chỉ thực thi lệnh pm->complete() của trình điều khiển thiết bị
gọi lại, nếu được xác định.

2.4.3. Ngủ đông hệ thống
^^^^^^^^^^^^^^^^^^^^^^^^^

Chế độ ngủ đông của hệ thống phức tạp hơn việc tạm dừng hệ thống vì nó yêu cầu
một hình ảnh hệ thống sẽ được tạo và ghi vào một phương tiện lưu trữ liên tục.  các
hình ảnh được tạo ra một cách nguyên tử và tất cả các thiết bị đều ở trạng thái không hoạt động hoặc bị đóng băng trước đó
xảy ra.

Việc đóng băng thiết bị được thực hiện sau khi đã giải phóng đủ bộ nhớ (lúc
tại thời điểm viết bài này, việc tạo hình ảnh yêu cầu ít nhất 50% hệ thống RAM
được tự do) trong ba giai đoạn sau:

chuẩn bị, đóng băng, đóng băng_noirq

tương ứng với các lệnh gọi lại của loại bus PCI::

pci_pm_prepare()
	pci_pm_freeze()
	pci_pm_freeze_noirq()

Điều này có nghĩa là giai đoạn chuẩn bị hoàn toàn giống với giai đoạn tạm dừng hệ thống.
Tuy nhiên, hai giai đoạn còn lại thì khác nhau.

Quy trình pci_pm_freeze() khá giống với pci_pm_suspend(), nhưng nó chạy
Lệnh gọi lại pm->freeze() của trình điều khiển thiết bị, nếu được xác định, thay vì pm->suspend(),
và nó không áp dụng các yêu cầu kỳ quặc về phần cứng liên quan đến hệ thống treo.  Nó được thực thi
không đồng bộ cho các thiết bị PCI khác nhau không phụ thuộc vào nhau trong một
cách đã biết.

Ngược lại, quy trình pci_pm_freeze_noirq() tương tự như
pci_pm_suspend_noirq(), nhưng nó gọi pm->freeze_noirq() của trình điều khiển thiết bị
thói quen thay vì pm->suspend_noirq().  Nó cũng không cố gắng chuẩn bị
thiết bị báo hiệu đánh thức và đưa nó vào trạng thái năng lượng thấp.  Tuy nhiên nó vẫn tiết kiệm
các thanh ghi cấu hình tiêu chuẩn của thiết bị nếu chúng chưa được lưu bởi một
các cuộc gọi lại của người lái xe.

Khi hình ảnh đã được tạo, nó phải được lưu.  Tuy nhiên, vào thời điểm này tất cả
các thiết bị bị treo và chúng không thể xử lý I/O, trong khi khả năng xử lý của chúng
I/O rõ ràng là cần thiết cho việc lưu hình ảnh.  Vì vậy chúng phải được đưa
trở lại trạng thái chức năng đầy đủ và việc này được thực hiện theo các giai đoạn sau:

thaw_noirq, tan băng, hoàn thành

bằng cách sử dụng lệnh gọi lại của loại bus PCI sau::

pci_pm_thaw_noirq()
	pci_pm_thaw()
	pci_pm_complete()

tương ứng.

Cái đầu tiên trong số đó, pci_pm_thaw_noirq(), tương tự như pci_pm_resume_noirq().
Nó đặt thiết bị ở trạng thái nguồn đầy đủ và khôi phục tiêu chuẩn của nó
các thanh ghi cấu hình.  Nó cũng thực thi lệnh pm->thaw_noirq() của trình điều khiển thiết bị
gọi lại, nếu được xác định, thay vì pm->resume_noirq().

Quy trình pci_pm_thaw() tương tự như pci_pm_resume() nhưng chạy thiết bị
lệnh gọi lại của trình điều khiển pm->thaw() thay vì pm->resume().  Nó được thực thi
không đồng bộ cho các thiết bị PCI khác nhau không phụ thuộc vào nhau trong một
cách đã biết.

Giai đoạn hoàn chỉnh cũng giống như giai đoạn sơ yếu lý lịch hệ thống.

Sau khi lưu hình ảnh, các thiết bị cần phải tắt nguồn trước khi hệ thống có thể
nhập trạng thái ngủ mục tiêu (ACPI S4 dành cho các hệ thống dựa trên ACPI).  Việc này được thực hiện ở
ba giai đoạn:

chuẩn bị, tắt nguồn, tắt nguồn_noirq

trong đó giai đoạn chuẩn bị hoàn toàn giống với giai đoạn tạm dừng hệ thống.  Cái khác
hai giai đoạn tương tự như giai đoạn đình chỉ và đình chỉ_noirq tương ứng.
Các lệnh gọi lại cấp hệ thống con PCI tương ứng với::

pci_pm_poweroff()
	pci_pm_poweroff_noirq()

hoạt động tương tự với pci_pm_suspend() và pci_pm_suspend_noirq(), tương ứng,
mặc dù họ không cố gắng lưu cấu hình tiêu chuẩn của thiết bị
sổ đăng ký.

2.4.4. Khôi phục hệ thống
^^^^^^^^^^^^^^^^^^^^^

Khôi phục hệ thống yêu cầu tải hình ảnh ngủ đông vào bộ nhớ và
Nội dung bộ nhớ trước khi ngủ đông sẽ được khôi phục trước hệ thống trước khi ngủ đông
hoạt động có thể được tiếp tục.

Như được mô tả trong Documentation/driver-api/pm/devices.rst, hình ảnh ngủ đông
được tải vào bộ nhớ bởi một phiên bản mới của kernel, được gọi là kernel khởi động,
lần lượt được tải và chạy bởi bộ tải khởi động theo cách thông thường.  Sau khi
kernel boot đã tải image, nó cần thay thế mã và dữ liệu của chính nó bằng
mã và dữ liệu của hạt nhân "ngủ đông" được lưu trữ trong ảnh, được gọi là
hạt nhân hình ảnh.  Với mục đích này, tất cả các thiết bị sẽ bị đóng băng giống như trước khi tạo
hình ảnh trong thời gian ngủ đông, trong

chuẩn bị, đóng băng, đóng băng_noirq

các giai đoạn được mô tả ở trên.  Tuy nhiên, các thiết bị bị ảnh hưởng bởi các giai đoạn này chỉ
những người có trình điều khiển trong kernel khởi động; các thiết bị khác sẽ vẫn ở đó
nêu rõ bộ tải khởi động đã để lại chúng.

Nếu việc khôi phục nội dung bộ nhớ trước khi ngủ đông không thành công, quá trình khởi động
kernel sẽ trải qua quy trình "làm tan băng" được mô tả ở trên, sử dụng
giai đoạn tan băng, tan băng và hoàn thành (điều đó sẽ chỉ ảnh hưởng đến các thiết bị có
driver trong kernel khởi động), rồi tiếp tục chạy bình thường.

Nếu nội dung bộ nhớ trước khi ngủ đông được khôi phục thành công, đó là
Trong trường hợp thông thường, quyền điều khiển được chuyển tới hạt nhân hình ảnh, sau đó hạt nhân này trở thành
chịu trách nhiệm đưa hệ thống trở lại trạng thái làm việc.  Để đạt được điều này,
nó phải khôi phục chức năng trước khi ngủ đông của thiết bị, việc này được thực hiện rất nhiều
giống như thức dậy từ trạng thái ngủ ký ức, mặc dù nó liên quan đến nhiều vấn đề khác nhau
giai đoạn:

khôi phục_noirq, khôi phục, hoàn thành

Hai giai đoạn đầu tiên trong số này tương tự như các giai đoạn sơ yếu lý lịch và tiếp tục
được mô tả ở trên tương ứng và tương ứng với hệ thống con PCI sau
cuộc gọi lại::

pci_pm_restore_noirq()
	pci_pm_restore()

Các lệnh gọi lại này hoạt động tương tự với pci_pm_resume_noirq() và pci_pm_resume(),
tương ứng, nhưng chúng thực thi lệnh pm->restore_noirq() và của trình điều khiển thiết bị
lệnh gọi lại pm->restore(), nếu có.

Giai đoạn hoàn chỉnh được thực hiện chính xác giống như trong quá trình hệ thống
tiếp tục.


3. Trình điều khiển thiết bị và quản lý nguồn PCI
==========================================

3.1. Lệnh gọi lại quản lý nguồn
-------------------------------

Trình điều khiển thiết bị PCI tham gia quản lý năng lượng bằng cách cung cấp các cuộc gọi lại để
được thực thi bởi các quy trình quản lý năng lượng của hệ thống con PCI được mô tả ở trên và bởi
kiểm soát việc quản lý năng lượng thời gian chạy của thiết bị của họ.

Tại thời điểm viết bài này, có hai cách để xác định quản lý năng lượng
gọi lại cho trình điều khiển thiết bị PCI, trình điều khiển được đề xuất, dựa trên việc sử dụng
cấu trúc dev_pm_ops được mô tả trong Tài liệu/driver-api/pm/devices.rst và
cái "cũ", trong đó các lệnh gọi lại .suspend() và .resume() từ struct
pci_driver được sử dụng.  Tuy nhiên, cách tiếp cận kế thừa không cho phép người ta xác định
các cuộc gọi lại quản lý năng lượng thời gian chạy và không thực sự phù hợp với bất kỳ cuộc gọi mới nào
trình điều khiển.  Do đó nó không được đề cập trong tài liệu này (tham khảo mã nguồn
để tìm hiểu thêm về nó).

Chúng tôi khuyên tất cả trình điều khiển thiết bị PCI nên xác định đối tượng struct dev_pm_ops
chứa các con trỏ tới các lệnh gọi lại quản lý nguồn (PM) sẽ được thực thi bởi
các hoạt động PM của hệ thống con PCI trong nhiều trường hợp khác nhau.  Một con trỏ tới
Đối tượng struct dev_pm_ops của trình điều khiển phải được gán cho trường driver.pm trong
đối tượng struct pci_driver của nó.  Khi điều đó đã xảy ra, lệnh gọi lại PM "cũ"
trong struct pci_driver bị bỏ qua (ngay cả khi chúng không phải là NULL).

Lệnh gọi lại PM trong struct dev_pm_ops là không bắt buộc và nếu không thì
được xác định (tức là các trường tương ứng của struct dev_pm_ops không được đặt) PCI
hệ thống con sẽ xử lý thiết bị theo cách mặc định đơn giản hóa.  Nếu họ là
Tuy nhiên, được xác định, chúng dự kiến sẽ hoạt động như được mô tả sau đây
tiểu mục.

3.1.1. chuẩn bị()
^^^^^^^^^^^^^^^^

Lệnh gọi lại prepare() được thực thi trong khi hệ thống tạm dừng, trong khi ngủ đông
(khi hình ảnh ngủ đông sắp được tạo), trong khi tắt nguồn sau
lưu hình ảnh ngủ đông và trong quá trình khôi phục hệ thống, khi hình ảnh ngủ đông
vừa được tải vào bộ nhớ.

Lệnh gọi lại này chỉ cần thiết nếu thiết bị của trình điều khiển có các phần tử con trong
chung có thể được đăng ký bất cứ lúc nào.  Trong trường hợp đó, vai trò của prepare()
gọi lại là để ngăn chặn việc đăng ký con mới của thiết bị cho đến khi
một trong các lệnh gọi lại Resume_noirq(), thaw_noirq() hoặc Restore_noirq() đang chạy.

Ngoài ra, lệnh gọi lại prepare() có thể thực hiện một số thao tác
chuẩn bị cho thiết bị bị treo, mặc dù nó không được phân bổ bộ nhớ
(nếu cần thêm bộ nhớ để tạm dừng thiết bị thì nó phải
được phân bổ trước đó, ví dụ như trong trình thông báo tạm dừng/ngủ đông như được mô tả
trong Tài liệu/driver-api/pm/notifiers.rst).

3.1.2. đình chỉ()
^^^^^^^^^^^^^^^^

Cuộc gọi lại đình chỉ() chỉ được thực hiện trong khi hệ thống tạm dừng, sau khi chuẩn bị()
lệnh gọi lại đã được thực thi cho tất cả các thiết bị trong hệ thống.

Lệnh gọi lại này dự kiến sẽ tắt thiết bị và chuẩn bị đưa thiết bị vào trạng thái
trạng thái năng lượng thấp bởi hệ thống con PCI.  Nó không bắt buộc (trên thực tế nó thậm chí còn
không được khuyến nghị) rằng lệnh gọi lại đình chỉ () của trình điều khiển PCI sẽ lưu tiêu chuẩn
các thanh ghi cấu hình của thiết bị, chuẩn bị cho việc đánh thức hệ thống hoặc
đưa nó vào trạng thái năng lượng thấp.  Tất cả các hoạt động này có thể được thực hiện rất tốt
được chăm sóc bởi hệ thống con PCI mà không có sự tham gia của người lái xe.

Tuy nhiên, trong một số trường hợp hiếm hoi, việc thực hiện các thao tác này một cách thuận tiện
trình điều khiển PCI.  Sau đó, pci_save_state(), pci_prepare_to_sleep() và
nên sử dụng pci_set_power_state() để lưu cấu hình chuẩn của thiết bị
đăng ký, để chuẩn bị cho việc đánh thức hệ thống (nếu cần) và đưa nó vào một
trạng thái năng lượng thấp, tương ứng.  Hơn nữa, nếu trình điều khiển gọi pci_save_state(),
hệ thống con PCI sẽ không thực thi pci_prepare_to_sleep() hoặc
pci_set_power_state() cho thiết bị của nó, do đó trình điều khiển sẽ chịu trách nhiệm về
xử lý thiết bị một cách thích hợp.

Trong khi lệnh gọi lại Suspend() đang được thực thi, trình xử lý ngắt của trình điều khiển
có thể được gọi để xử lý ngắt từ thiết bị, vì vậy tất cả các hoạt động liên quan đến tạm dừng
các hoạt động dựa vào khả năng của người lái xe để xử lý các ngắt
được thực hiện trong cuộc gọi lại này.

3.1.3. đình chỉ_noirq()
^^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại Suspend_noirq() chỉ được thực thi trong khi hệ thống tạm dừng, sau
các cuộc gọi lại đình chỉ() đã được thực thi cho tất cả các thiết bị trong hệ thống và
sau khi các ngắt thiết bị đã bị lõi PM vô hiệu hóa.

Sự khác biệt giữa đình chỉ_noirq() và đình chỉ() là trình điều khiển
trình xử lý ngắt sẽ không được gọi khi Suspend_noirq() đang chạy.  Như vậy
Suspend_noirq() có thể thực hiện các hoạt động khiến điều kiện chạy đua bị ảnh hưởng
phát sinh nếu chúng được thực hiện trong hệ thống treo().

3.1.4. đông cứng()
^^^^^^^^^^^^^^^

Lệnh gọi lại Freeze() dành riêng cho chế độ ngủ đông và được thực thi trong hai trường hợp,
trong khi ngủ đông, sau khi lệnh gọi lại prepare() được thực thi cho tất cả các thiết bị
để chuẩn bị cho việc tạo hình ảnh hệ thống và trong quá trình khôi phục,
sau khi hình ảnh hệ thống được tải vào bộ nhớ từ bộ lưu trữ liên tục và
các lệnh gọi lại prepare() đã được thực thi cho tất cả các thiết bị.

Vai trò của lệnh gọi lại này tương tự như vai trò của lệnh gọi lại đình chỉ()
được mô tả ở trên.  Trên thực tế, chúng chỉ cần khác nhau trong những trường hợp hiếm hoi khi
người lái xe có trách nhiệm đưa thiết bị vào chế độ điện năng thấp
trạng thái.

Trong trường hợp đó, lệnh gọi lại đóng băng() sẽ không chuẩn bị cho việc đánh thức hệ thống thiết bị
hoặc đặt nó vào trạng thái năng lượng thấp.  Tuy nhiên, nó hoặc Freeze_noirq() nên
lưu các thanh ghi cấu hình tiêu chuẩn của thiết bị bằng pci_save_state().

3.1.5. đóng băng_noirq()
^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại Freeze_noirq() dành riêng cho chế độ ngủ đông.  Nó được thực hiện trong thời gian
chế độ ngủ đông, sau khi các lệnh gọi lại chuẩn bị() và đóng băng() đã được thực thi cho tất cả
thiết bị để chuẩn bị cho việc tạo hình ảnh hệ thống và trong quá trình khôi phục,
sau khi hình ảnh hệ thống được tải vào bộ nhớ và sau khi chuẩn bị() và
các lệnh gọi lại đóng băng() đã được thực thi cho tất cả các thiết bị.  Nó luôn được thực thi
sau khi các ngắt thiết bị đã bị lõi PM vô hiệu hóa.

Vai trò của lệnh gọi lại này tương tự như vai trò của Suspend_noirq()
gọi lại được mô tả ở trên và rất hiếm khi cần xác định
đóng băng_noirq().

Sự khác biệt giữa Freeze_noirq() và Freeze() tương tự như
sự khác biệt giữa đình chỉ_noirq() và đình chỉ().

3.1.6. tắt nguồn()
^^^^^^^^^^^^^^^^^

Lệnh gọi lại poweroff() dành riêng cho chế độ ngủ đông.  Nó được thực thi khi hệ thống
sắp bị tắt nguồn sau khi lưu hình ảnh ngủ đông vào một liên tục
lưu trữ.  các cuộc gọi lại prepare() được thực thi cho tất cả các thiết bị trước khi poweroff() được thực hiện
được gọi.

Vai trò của lệnh gọi lại này tương tự như vai trò của tạm dừng() và đóng băng()
các cuộc gọi lại được mô tả ở trên, mặc dù nó không cần lưu nội dung của
các thanh ghi của thiết bị.  Đặc biệt, nếu người lái xe muốn đưa thiết bị
chuyển sang trạng thái năng lượng thấp thay vì cho phép hệ thống con PCI làm điều đó,
cuộc gọi lại poweroff() nên sử dụng pci_prepare_to_sleep() và
pci_set_power_state() để chuẩn bị cho thiết bị đánh thức hệ thống và đặt thiết bị
tương ứng sang trạng thái năng lượng thấp nhưng không cần lưu tiêu chuẩn của thiết bị
các thanh ghi cấu hình.

3.1.7. poweroff_noirq()
^^^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại poweroff_noirq() dành riêng cho chế độ ngủ đông.  Nó được thực thi sau
lệnh gọi lại poweroff() đã được thực thi cho tất cả các thiết bị trong hệ thống.

Vai trò của lệnh gọi lại này tương tự như vai trò của Suspend_noirq() và
Freeze_noirq() gọi lại được mô tả ở trên, nhưng không cần lưu
nội dung của các thanh ghi của thiết bị.

Sự khác biệt giữa poweroff_noirq() và poweroff() tương tự như
sự khác biệt giữa đình chỉ_noirq() và đình chỉ().

3.1.8. sơ yếu lý lịch_noirq()
^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại Resume_noirq() chỉ được thực thi trong quá trình tiếp tục hệ thống, sau khi
Lõi PM đã kích hoạt các CPU không khởi động được.  Trình xử lý ngắt của trình điều khiển sẽ không
được gọi trong khi sơ yếu lý lịch_noirq() đang chạy, vì vậy cuộc gọi lại này có thể thực hiện
các hoạt động có thể chạy đua với trình xử lý ngắt.

Vì hệ thống con PCI đưa tất cả các thiết bị vào trạng thái hoạt động hoàn toàn vô điều kiện
trạng thái trong giai đoạn sơ yếu lý lịch_noirq của hệ thống tiếp tục và khôi phục tiêu chuẩn của chúng
thanh ghi cấu hình, sơ yếu lý lịch_noirq() thường không cần thiết.  Nói chung
nó chỉ nên được sử dụng để thực hiện các hoạt động dẫn đến cuộc đua
điều kiện nếu được thực hiện bởi sơ yếu lý lịch().

3.1.9. bản tóm tắt()
^^^^^^^^^^^^^^^

Lệnh gọi lại Resume() chỉ được thực thi trong quá trình tiếp tục hệ thống, sau
các lệnh gọi lại Resume_noirq() đã được thực thi cho tất cả các thiết bị trong hệ thống và
ngắt thiết bị đã được kích hoạt bởi lõi PM.

Cuộc gọi lại này chịu trách nhiệm khôi phục cấu hình tạm dừng trước của
thiết bị và đưa nó trở lại trạng thái hoạt động đầy đủ.  Thiết bị này nên được
có thể xử lý I/O theo cách thông thường sau khi CV() được trả về.

3.1.10. tan_noirq()
^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại thaw_noirq() dành riêng cho chế độ ngủ đông.  Nó được thực thi sau một
hình ảnh hệ thống đã được tạo và các CPU không khởi động đã được PM kích hoạt
core, trong giai đoạn tan băng của chế độ ngủ đông.  Nó cũng có thể được thực thi nếu
tải hình ảnh ngủ đông không thành công trong quá trình khôi phục hệ thống (sau đó nó được thực thi
sau khi kích hoạt các CPU không khởi động).  Trình xử lý ngắt của trình điều khiển sẽ không được
được gọi khi thaw_noirq() đang chạy.

Vai trò của lệnh gọi lại này tương tự như vai trò của sơ yếu lý lịch_noirq().  các
điểm khác biệt giữa hai lệnh gọi lại này là thaw_noirq() được thực thi sau
đóng băng() và đóng băng_noirq(), vì vậy nói chung không cần sửa đổi
nội dung của các thanh ghi của thiết bị.

3.1.11. tan băng()
^^^^^^^^^^^^^^

Lệnh gọi lại thaw() dành riêng cho chế độ ngủ đông.  Nó được thực thi sau thaw_noirq()
lệnh gọi lại đã được thực thi cho tất cả các thiết bị trong hệ thống và sau khi thiết bị
các ngắt đã được kích hoạt bởi lõi PM.

Cuộc gọi lại này chịu trách nhiệm khôi phục cấu hình đóng băng trước của
thiết bị để thiết bị sẽ hoạt động theo cách thông thường sau khi tan băng() quay trở lại.

3.1.12. khôi phục_noirq()
^^^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại Restore_noirq() dành riêng cho chế độ ngủ đông.  Nó được thực thi trong
giai đoạn khôi phục_noirq của chế độ ngủ đông, khi kernel khởi động đã chuyển quyền kiểm soát sang
hạt nhân hình ảnh và các CPU không khởi động đã được kích hoạt bởi hạt nhân hình ảnh
lõi PM.

Cuộc gọi lại này tương tự như sơ yếu lý lịch_noirq() ngoại trừ việc nó không thể
đưa ra bất kỳ giả định nào về trạng thái trước đó của thiết bị, ngay cả khi BIOS (hoặc
nói chung là phần sụn nền tảng) được biết là duy trì trạng thái đó trong một thời gian
chu kỳ đình chỉ-tiếp tục.

Đối với đại đa số trình điều khiển thiết bị PCI, không có sự khác biệt giữa
sơ yếu lý lịch_noirq() và khôi phục_noirq().

3.1.13. khôi phục()
^^^^^^^^^^^^^^^^^

Lệnh gọi lại Restore() dành riêng cho chế độ ngủ đông.  Nó được thực thi sau
Lệnh gọi lại Restore_noirq() đã được thực thi cho tất cả các thiết bị trong hệ thống và
sau khi lõi PM đã cho phép gọi trình xử lý ngắt của trình điều khiển thiết bị.

Cuộc gọi lại này tương tự như sơ yếu lý lịch(), giống như khôi phục_noirq() tương tự
tới sơ yếu lý lịch_noirq().  Do đó, sự khác biệt giữa Restore_noirq() và
khôi phục() tương tự như sự khác biệt giữa sơ yếu lý lịch_noirq() và sơ yếu lý lịch().

Đối với đại đa số trình điều khiển thiết bị PCI, không có sự khác biệt giữa
sơ yếu lý lịch() và khôi phục().

3.1.14. hoàn thành()
^^^^^^^^^^^^^^^^^^

Lệnh gọi lại Complete() được thực thi trong các trường hợp sau:

- trong quá trình tiếp tục hệ thống, sau khi các lệnh gọi lại sơ yếu lý lịch() đã được thực thi cho tất cả
    thiết bị,
  - trong khi ngủ đông, trước khi lưu hình ảnh hệ thống, sau khi gọi lại tan băng()
    đã được thực thi cho tất cả các thiết bị,
  - trong quá trình khôi phục hệ thống, khi hệ thống quay trở lại trạng thái ngủ đông trước
    trạng thái, sau khi lệnh gọi lại khôi phục() đã được thực thi cho tất cả các thiết bị.

Nó cũng có thể được thực thi nếu việc tải hình ảnh ngủ đông vào bộ nhớ không thành công
(trong trường hợp đó nó được chạy sau khi lệnh gọi lại thaw() được thực thi cho tất cả
thiết bị có trình điều khiển trong kernel khởi động).

Cuộc gọi lại này là hoàn toàn tùy chọn, mặc dù nó có thể cần thiết nếu
Chuẩn bị() gọi lại thực hiện các hoạt động cần được đảo ngược.

3.1.15. thời gian chạy_suspend()
^^^^^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại thời gian chạy_suspend() dành riêng cho việc quản lý năng lượng thời gian chạy của thiết bị
(PM thời gian chạy).  Nó được thực thi bởi khung PM thời gian chạy của lõi PM khi
thiết bị sắp bị treo (tức là đã ngừng hoạt động và chuyển sang trạng thái năng lượng thấp)
vào thời gian chạy.

Cuộc gọi lại này chịu trách nhiệm đóng băng thiết bị và chuẩn bị cho nó hoạt động.
đưa vào trạng thái năng lượng thấp, nhưng nó phải cho phép hệ thống con PCI thực hiện tất cả
trong số các hành động dành riêng cho PCI cần thiết để tạm dừng thiết bị.

3.1.16. thời gian chạy_resume()
^^^^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại thời gian chạy_resume() dành riêng cho PM thời gian chạy của thiết bị.  Nó được thực thi
bởi khung PM thời gian chạy của lõi PM khi thiết bị sắp được khởi động lại
(tức là đưa vào trạng thái toàn năng và được lập trình để xử lý I/O bình thường) tại
thời gian chạy.

Cuộc gọi lại này có trách nhiệm khôi phục chức năng bình thường của
thiết bị sau khi được hệ thống con PCI đưa vào trạng thái toàn năng.
Thiết bị được mong đợi có thể xử lý I/O theo cách thông thường sau
thời gian chạy_resume() đã trở lại.

3.1.17. thời gian chạy_idle()
^^^^^^^^^^^^^^^^^^^^^^

Lệnh gọi lại Runtime_idle() dành riêng cho PM thời gian chạy của thiết bị.  Nó được thực thi
bởi khung PM thời gian chạy của lõi PM bất cứ khi nào có thể muốn tạm dừng
thiết bị theo thông tin của lõi PM.  Đặc biệt, nó là
được thực thi tự động ngay sau khi thời gian chạy_resume() quay trở lại trong trường hợp
sơ yếu lý lịch của thiết bị đã xảy ra do một sự kiện giả mạo.

Cuộc gọi lại này là tùy chọn, nhưng nếu nó không được triển khai hoặc nếu nó trả về 0 thì
Hệ thống con PCI sẽ gọi pm_runtime_suspend() cho thiết bị, do đó sẽ
khiến lệnh gọi lại run_suspend() của trình điều khiển được thực thi.

3.1.18. Trỏ nhiều con trỏ gọi lại vào một quy trình
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mặc dù về nguyên tắc, mỗi lệnh gọi lại được mô tả ở phần trước
các phần phụ có thể được định nghĩa như một chức năng riêng biệt, điều này thường thuận tiện cho việc
trỏ hai hoặc nhiều thành viên của struct dev_pm_ops vào cùng một quy trình.  có
một vài macro tiện lợi có thể được sử dụng cho mục đích này.

DEFINE_SIMPLE_DEV_PM_OPS() khai báo một đối tượng struct dev_pm_ops bằng một
tạm dừng quy trình được chỉ định bởi .suspend(), .freeze() và .poweroff()
các thành viên và một quy trình sơ yếu lý lịch được chỉ ra bởi .resume(), .thaw() và
thành viên .restore().  Các con trỏ hàm khác trong cấu trúc dev_pm_ops này là
bỏ đặt.

DEFINE_RUNTIME_DEV_PM_OPS() tương tự như DEFINE_SIMPLE_DEV_PM_OPS(), nhưng nó
Ngoài ra, đặt con trỏ .runtime_resume() thành pm_runtime_force_resume()
và con trỏ .runtime_suspend() tới pm_runtime_force_suspend().

SYSTEM_SLEEP_PM_OPS() có thể được sử dụng bên trong khai báo struct
dev_pm_ops để chỉ ra rằng một quy trình tạm dừng sẽ được chỉ ra bởi
Các thành viên .suspend(), .freeze() và .poweroff() và một quy trình tiếp tục là
được chỉ ra bởi các thành viên .resume(), .thaw() và .restore().

3.1.19. Cờ trình điều khiển để quản lý nguồn
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lõi PM cho phép trình điều khiển thiết bị đặt các cờ ảnh hưởng đến việc xử lý
quản lý năng lượng cho các thiết bị bằng chính lõi và bằng mã lớp giữa
bao gồm loại xe buýt PCI.  Các cờ phải được đặt một lần ở đầu dò trình điều khiển
thời gian với sự trợ giúp của hàm dev_pm_set_driver_flags() và chúng sẽ không
sẽ được cập nhật trực tiếp sau đó.

Cờ DPM_FLAG_NO_DIRECT_COMPLETE ngăn lõi PM sử dụng
cơ chế hoàn thiện trực tiếp cho phép thiết bị tạm dừng/tiếp tục gọi lại bị bỏ qua
nếu thiết bị đang ở trạng thái tạm dừng khi hệ thống bắt đầu tạm dừng.  Điều đó cũng
ảnh hưởng đến tất cả tổ tiên của thiết bị, vì vậy cờ này chỉ nên được sử dụng nếu
hoàn toàn cần thiết.

Cờ DPM_FLAG_SMART_PREPARE khiến loại bus PCI trả về giá trị dương
giá trị từ pci_pm_prepare() chỉ khi lệnh gọi lại ->prepare được cung cấp bởi
trình điều khiển của thiết bị trả về giá trị dương.  Điều đó cho phép người lái xe lựa chọn
không còn sử dụng cơ chế hoàn thành trực tiếp một cách linh hoạt (trong khi cài đặt
DPM_FLAG_NO_DIRECT_COMPLETE có nghĩa là từ chối vĩnh viễn).

Cờ DPM_FLAG_SMART_SUSPEND cho loại xe buýt PCI biết rằng từ trình điều khiển
phối cảnh thiết bị có thể được giữ an toàn trong thời gian tạm dừng trong hệ thống
đình chỉ.  Điều đó gây ra pci_pm_suspend(), pci_pm_freeze() và pci_pm_poweroff()
để tránh tiếp tục thiết bị sau khi tạm dừng thời gian chạy trừ khi có PCI dành riêng cho
lý do để làm điều đó.  Ngoài ra, nó còn gây ra pci_pm_suspend_late/noirq() và
pci_pm_poweroff_late/noirq() để quay lại sớm nếu thiết bị vẫn đang chạy
tạm dừng trong giai đoạn "muộn" của quá trình chuyển đổi toàn hệ thống đang diễn ra.
Hơn nữa, nếu thiết bị đang trong thời gian chạy tạm dừng trong pci_pm_resume_noirq() hoặc
pci_pm_restore_noirq(), trạng thái PM thời gian chạy của nó sẽ được thay đổi thành "hoạt động" (vì nó
sẽ được đưa vào D0 trong tương lai).

Đặt cờ DPM_FLAG_MAY_SKIP_RESUME có nghĩa là trình điều khiển cho phép
Các cuộc gọi lại tiếp tục "noirq" và "sớm" sẽ bị bỏ qua nếu có thể để lại thiết bị
tạm dừng sau khi toàn hệ thống chuyển sang trạng thái làm việc.  Lá cờ này là
được lõi PM xem xét cùng với power.may_skip_resume
bit trạng thái của thiết bị được thiết lập bởi pci_pm_suspend_noirq() trong một số trường hợp nhất định
tình huống.  Nếu lõi PM xác định rằng trình điều khiển "noirq" và "sớm"
nên bỏ qua các cuộc gọi lại tiếp tục, hàm trợ giúp dev_pm_skip_resume()
sẽ trả về "true" và điều đó sẽ gây ra pci_pm_resume_noirq() và
pci_pm_resume_early() để trả trước mà không cần chạm vào thiết bị và
thực hiện các cuộc gọi lại trình điều khiển.

3.2. Quản lý năng lượng thời gian chạy thiết bị
------------------------------------

Ngoài việc cung cấp các cuộc gọi lại quản lý năng lượng thiết bị PCI trình điều khiển thiết bị
chịu trách nhiệm kiểm soát việc quản lý năng lượng thời gian chạy (runtime PM) của
thiết bị của họ.

PM thời gian chạy thiết bị PCI là tùy chọn, nhưng khuyến nghị rằng thiết bị PCI
trình điều khiển thực hiện nó ít nhất trong trường hợp có một cách đáng tin cậy để
xác minh rằng thiết bị không được sử dụng (như khi tháo cáp mạng
từ bộ chuyển đổi Ethernet hoặc không có thiết bị nào được gắn vào bộ điều khiển USB).

Để hỗ trợ PM thời gian chạy PCI, trước tiên trình điều khiển cần triển khai
các lệnh gọi lại thời gian chạy_suspend() và thời gian chạy_resume().  Nó cũng có thể cần phải thực hiện
lệnh gọi lại run_idle() để ngăn thiết bị bị treo lần nữa
mỗi lần ngay sau khi lệnh gọi lại run_resume() quay trở lại
(cách khác, lệnh gọi lại run_suspend() sẽ phải kiểm tra xem
thiết bị thực sự nên bị treo và trả về -EAGAIN nếu không phải như vậy).

PM thời gian chạy của thiết bị PCI được lõi PCI bật theo mặc định.  PCI
trình điều khiển thiết bị không cần kích hoạt nó và không nên cố gắng làm như vậy.
Tuy nhiên, nó bị chặn bởi pci_pm_init() chạy pm_runtime_forbid()
chức năng trợ giúp.  Ngoài ra, bộ đếm sử dụng PM thời gian chạy của
mỗi thiết bị PCI được tăng thêm local_pci_probe() trước khi thực hiện
thăm dò cuộc gọi lại được cung cấp bởi trình điều khiển của thiết bị.

Nếu trình điều khiển PCI triển khai lệnh gọi lại PM thời gian chạy và có ý định sử dụng
khung PM thời gian chạy được cung cấp bởi lõi PM và hệ thống con PCI, nó cần
để giảm bộ đếm mức sử dụng PM thời gian chạy của thiết bị trong cuộc gọi lại thăm dò của nó
chức năng.  Nếu không làm như vậy thì bộ đếm sẽ luôn khác với
0 cho thiết bị và thiết bị sẽ không bao giờ bị treo trong thời gian chạy.  Đơn giản nhất
cách để làm điều đó là gọi pm_runtime_put_noille(), nhưng nếu trình điều khiển
muốn lên lịch tự động gửi ngay lập tức, ví dụ: nó có thể gọi
pm_runtime_put_autosuspend() thay thế cho mục đích này.  Nói chung, nó
chỉ cần gọi một hàm làm giảm bộ đếm sử dụng thiết bị
từ quy trình thăm dò của nó để làm cho PM thời gian chạy hoạt động cho thiết bị.

Điều quan trọng cần nhớ là lệnh gọi lại thời gian chạy_suspend() của trình điều khiển
có thể được thực thi ngay sau khi bộ đếm sử dụng đã giảm đi, bởi vì
không gian người dùng có thể đã gây ra chức năng trợ giúp pm_runtime_allow()
bỏ chặn PM thời gian chạy của thiết bị để chạy qua sysfs nên driver phải
sẵn sàng đương đầu với điều đó.

Tuy nhiên, bản thân trình điều khiển không nên gọi pm_runtime_allow().  Thay vào đó, nó
nên để không gian người dùng hoặc một số mã dành riêng cho nền tảng thực hiện điều đó (không gian người dùng có thể
thực hiện thông qua sysfs như đã nêu ở trên), nhưng nó phải được chuẩn bị để xử lý
thời gian chạy PM của thiết bị một cách chính xác ngay khi pm_runtime_allow() được gọi
(điều này có thể xảy ra bất cứ lúc nào, ngay cả trước khi tải trình điều khiển).

Khi lệnh gọi lại loại bỏ trình điều khiển chạy, nó phải cân bằng mức giảm
bộ đếm mức sử dụng PM thời gian chạy của thiết bị tại thời điểm thăm dò.  Vì lý do này,
nếu nó đã giảm bộ đếm trong cuộc gọi lại thăm dò, nó phải chạy
pm_runtime_get_noresume() trong cuộc gọi lại loại bỏ của nó.  [Vì lõi mang
đưa ra sơ yếu lý lịch thời gian chạy của thiết bị và tăng bộ đếm mức sử dụng của thiết bị
trước khi chạy lệnh gọi lại loại bỏ trình điều khiển, PM thời gian chạy của thiết bị
thực sự bị vô hiệu hóa trong suốt thời gian thực hiện xóa và tất cả
Các chức năng trợ giúp PM thời gian chạy tăng bộ đếm mức sử dụng của thiết bị là
sau đó thực sự tương đương với pm_runtime_get_noresume().]

Khung PM thời gian chạy hoạt động bằng cách xử lý các yêu cầu tạm dừng hoặc tiếp tục
thiết bị hoặc để kiểm tra xem chúng có ở trạng thái rảnh không (trong trường hợp đó, việc
sau đó yêu cầu họ bị đình chỉ).  Những yêu cầu này được thể hiện
theo các mục công việc được đưa vào hàng công việc quản lý nguồn, pm_wq.  Mặc dù ở đó
Có một số tình huống trong đó các yêu cầu quản lý năng lượng được tự động
được lõi PM xếp hàng (ví dụ: sau khi xử lý yêu cầu tiếp tục
thiết bị, lõi PM sẽ tự động xếp hàng yêu cầu để kiểm tra xem thiết bị có
nhàn rỗi), trình điều khiển thiết bị thường chịu trách nhiệm quản lý nguồn hàng đợi
yêu cầu đối với thiết bị của họ.  Với mục đích này họ nên sử dụng PM thời gian chạy
các chức năng trợ giúp do lõi PM cung cấp, được thảo luận trong
Tài liệu/sức mạnh/runtime_pm.rst.

Các thiết bị cũng có thể bị tạm dừng và tiếp tục lại một cách đồng bộ mà không cần đặt lệnh
yêu cầu vào pm_wq.  Trong phần lớn các trường hợp, điều này cũng được thực hiện bởi
trình điều khiển sử dụng các chức năng trợ giúp do lõi PM cung cấp cho mục đích này.

Để biết thêm thông tin về thời gian chạy PM của thiết bị, hãy tham khảo
Tài liệu/sức mạnh/runtime_pm.rst.


4. Tài nguyên
============

Thông số kỹ thuật xe buýt địa phương PCI, Phiên bản 3.0

Thông số kỹ thuật giao diện quản lý nguồn bus PCI, Phiên bản 1.2

Thông số kỹ thuật về cấu hình nâng cao và giao diện nguồn (ACPI), Phiên bản 3.0b

Thông số kỹ thuật cơ sở nhanh PCI, Phiên bản 2.0

Tài liệu/driver-api/pm/devices.rst

Tài liệu/sức mạnh/runtime_pm.rst
