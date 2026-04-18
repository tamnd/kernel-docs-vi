.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/autofs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
autofs - cách thức hoạt động
=====================

Mục đích
=======

Mục tiêu của autofs là cung cấp dịch vụ lắp đặt theo yêu cầu và không có cuộc đua
tự động ngắt kết nối các hệ thống tập tin khác.  Điều này cung cấp hai
Ưu điểm chính:

1. Không cần phải trì hoãn việc khởi động cho đến khi tất cả các hệ thống tập tin được
   có thể cần thiết được gắn kết.  Các quy trình cố gắng truy cập chúng
   hệ thống tập tin chậm có thể bị trì hoãn nhưng các quy trình khác có thể
   tiếp tục một cách tự do.  Điều này đặc biệt quan trọng đối với
   hệ thống tệp mạng (ví dụ NFS) hoặc hệ thống tệp được lưu trữ trên
   phương tiện truyền thông với một robot thay đổi phương tiện truyền thông.

2. Tên và vị trí của hệ thống tập tin có thể được lưu trữ trong
   một cơ sở dữ liệu từ xa và có thể thay đổi bất cứ lúc nào.  Nội dung
   trong cơ sở dữ liệu đó tại thời điểm truy cập sẽ được sử dụng để cung cấp
   một mục tiêu để truy cập.  Việc giải thích các tên trong
   hệ thống tập tin thậm chí có thể được lập trình thay vì được hỗ trợ bởi cơ sở dữ liệu,
   ví dụ: cho phép ký tự đại diện và có thể thay đổi tùy theo người dùng
   lần đầu tiên truy cập một tên.

Bối cảnh
=======

Mô-đun hệ thống tập tin "autofs" chỉ là một phần của hệ thống autofs.
Cũng cần có một chương trình không gian người dùng để tra cứu tên
và gắn kết hệ thống tập tin.  Đây thường sẽ là chương trình "tự động đếm",
mặc dù các công cụ khác bao gồm "systemd" có thể sử dụng "autofs".
Tài liệu này chỉ mô tả mô-đun hạt nhân và các tương tác
được yêu cầu với bất kỳ chương trình không gian người dùng nào.  Văn bản tiếp theo đề cập đến điều này
là "daemon tự động" hoặc đơn giản là "daemon".

"autofs" là mô-đun hạt nhân Linux cung cấp "autofs"
loại hệ thống tập tin.  Một số hệ thống tập tin "autofs" có thể được gắn kết và chúng
mỗi cái có thể được quản lý riêng biệt hoặc tất cả được quản lý bởi cùng một daemon.

Nội dung
=======

Một hệ thống tập tin autofs có thể chứa 3 loại đối tượng: thư mục,
liên kết tượng trưng và bẫy gắn kết.  Bẫy gắn kết là các thư mục có
các thuộc tính bổ sung như được mô tả trong phần tiếp theo.

Các đối tượng chỉ có thể được tạo bởi daemon automount: liên kết tượng trưng là
được tạo bằng lệnh gọi hệ thống ZZ0000ZZ thông thường, trong khi các thư mục và
bẫy gắn kết được tạo bằng ZZ0001ZZ.  Việc xác định liệu một
thư mục phải là một cái bẫy gắn kết dựa trên bản đồ chính. Thầy này
bản đồ được tham khảo bởi autofs để xác định thư mục nào được gắn kết
điểm. Điểm gắn kết có thể là ZZ0002ZZ/ZZ0003ZZ/ZZ0004ZZ.
Trên hầu hết các hệ thống, bản đồ chính mặc định nằm ở ZZ0005ZZ.

Nếu không có tùy chọn gắn ZZ0000ZZ hoặc ZZ0001ZZ nào được cung cấp (vì vậy
mount được coi là ZZ0002ZZ), thì thư mục gốc là
luôn là một thư mục thông thường, nếu không nó sẽ là một cái bẫy gắn kết khi nó được
trống và một thư mục thông thường khi không trống.  Lưu ý rằng ZZ0003ZZ và
ZZ0004ZZ được xử lý giống hệt nhau nên tóm tắt ngắn gọn là gốc
thư mục chỉ là bẫy gắn kết nếu hệ thống tập tin được gắn kết ZZ0005ZZ
và gốc trống rỗng.

Các thư mục được tạo trong thư mục gốc chỉ là các bẫy gắn kết nếu
hệ thống tập tin được gắn ZZ0000ZZ và chúng trống.

Các thư mục ở phía dưới cây phụ thuộc vào ngàm ZZ0000ZZ
tùy chọn và đặc biệt là liệu nó có nhỏ hơn năm hay không.
Khi ZZ0001ZZ là năm, không có thư mục nào ở phía dưới
cây luôn là bẫy gắn kết, chúng luôn là những thư mục thông thường.  Khi nào
ZZ0002ZZ có bốn (hoặc ba), những thư mục này là bẫy gắn kết
chính xác khi chúng trống rỗng.

Vì vậy: các thư mục không trống (tức là không có lá) không bao giờ là bẫy gắn kết. trống
các thư mục đôi khi là bẫy gắn kết và đôi khi không phụ thuộc vào
chúng ở đâu trong cây (gốc, cấp cao nhất hoặc thấp hơn), ZZ0000ZZ,
và giá đỡ có phải là ZZ0001ZZ hay không.

Gắn bẫy
===========

Yếu tố cốt lõi của việc triển khai autofs là Mount Traps
được cung cấp bởi Linux VFS.  Bất kỳ thư mục nào được cung cấp bởi một
hệ thống tập tin có thể được chỉ định là một cái bẫy.  Điều này liên quan đến hai
các tính năng hoạt động cùng nhau để cho phép autofs thực hiện công việc của mình.

ZZ0000ZZ

Nếu một nha khoa có cờ DCACHE_NEED_AUTOMOUNT được đặt (được đặt nếu
inode đã được đặt S_AUTOMOUNT hoặc có thể được đặt trực tiếp) thì đó là
(có khả năng) một cái bẫy gắn kết.  Bất kỳ quyền truy cập nào vào thư mục này ngoài
"ZZ0000ZZ" sẽ (thông thường) gây ra hoạt động của răng ZZ0001ZZ
để được gọi. Nhiệm vụ của phương pháp này là tìm hệ thống tập tin
nên được gắn vào thư mục và trả lại nó.  VFS là
chịu trách nhiệm thực sự gắn phần gốc của hệ thống tập tin này vào
thư mục.

autofs không tìm thấy hệ thống tập tin nhưng gửi tin nhắn đến
daemon automount yêu cầu nó tìm và gắn kết hệ thống tập tin.  các
autofs phương thức ZZ0000ZZ sau đó đợi daemon báo cáo rằng
mọi thứ đã sẵn sàng.  Sau đó nó sẽ trả về "ZZ0001ZZ" cho biết rằng
mount đã xảy ra rồi.  VFS không cố gắn bất cứ thứ gì ngoại trừ
đi theo thú cưỡi đã có sẵn ở đó.

Chức năng này đủ cho một số người dùng bẫy gắn kết như
như NFS tạo bẫy để các điểm gắn kết trên máy chủ có thể
phản ánh lên khách hàng.  Tuy nhiên nó không đủ cho autofs.  Như
việc gắn vào một thư mục được coi là "vượt quá ZZ0000ZZ",
daemon automount sẽ không thể gắn hệ thống tập tin vào 'bẫy'
thư mục mà không có cách nào để tránh bị mắc bẫy.  cho
mục đích đó có một lá cờ khác.

ZZ0000ZZ

Nếu một nha khoa có bộ DCACHE_MANAGE_TRANSIT thì hai cái rất khác nhau nhưng
các hành vi liên quan đều được gọi, cả hai đều sử dụng ZZ0000ZZ
phẫu thuật nha khoa.

Đầu tiên, trước khi kiểm tra xem có hệ thống tập tin nào được gắn trên
thư mục, d_manage() sẽ được gọi với bộ tham số ZZ0000ZZ
tới ZZ0001ZZ.  Nó có thể trả về một trong ba điều:

- Giá trị trả về bằng 0 cho biết không có gì đặc biệt
   về nha khoa này và các cuộc kiểm tra thông thường đối với giá đỡ và giá đỡ tự động
   nên tiếp tục.

autofs thường trả về 0, nhưng trước tiên hãy đợi bất kỳ
   hết hạn (tự động ngắt kết nối hệ thống tập tin được gắn) thành
   hoàn thành.  Điều này tránh các cuộc đua.

- Giá trị trả về của ZZ0000ZZ yêu cầu VFS bỏ qua mọi giá treo
   trên thư mục và không cân nhắc việc gọi ZZ0001ZZ.
   Điều này vô hiệu hóa cờ ZZ0002ZZ một cách hiệu quả
   khiến cho thư mục không phải là một cái bẫy gắn kết.

autofs trả về giá trị này nếu nó phát hiện ra rằng quá trình thực hiện
   tra cứu là daemon automount và mount đã được
   đã yêu cầu nhưng chưa hoàn thành.  Làm thế nào nó xác định được điều này
   thảo luận sau.  Điều này cho phép daemon automount không nhận được
   bị mắc vào bẫy gắn kết.

Có một sự tinh tế ở đây.  Có thể là lần tự động thứ hai
   hệ thống tập tin có thể được gắn bên dưới hệ thống đầu tiên và để cả hai đều
   được quản lý bởi cùng một daemon.  Để daemon có thể gắn kết
   thứ gì đó vào lúc thứ hai nó phải có khả năng "đi" qua
   đầu tiên.  Điều này có nghĩa là d_manage không thể ZZ0000ZZ trả về -EISDIR cho
   daemon tự động đếm.  Nó chỉ phải trả lại khi thú cưỡi có
   đã được yêu cầu nhưng vẫn chưa hoàn thành.

ZZ0000ZZ cũng trả về ZZ0001ZZ nếu răng giả không phải là
   gắn bẫy, vì nó là một liên kết tượng trưng hoặc vì nó
   không trống rỗng.

- Bất kỳ giá trị âm nào khác đều được coi là lỗi và được trả về
   tới người gọi.

autofs có thể quay lại

- -ENOENT nếu trình nền tự động gắn kết không thể gắn kết bất cứ thứ gì,
   - -ENOMEM nếu hết bộ nhớ,
   - -EINTR nếu có tín hiệu đến trong khi chờ hết hạn
     hoàn thành
   - hoặc bất kỳ lỗi nào khác được trình nền tự động gửi xuống.


Trường hợp sử dụng thứ hai chỉ xảy ra trong quá trình "RCU-walk" và ZZ0000ZZ cũng vậy
sẽ được thiết lập.

Đi bộ RCU là một quá trình nhanh chóng và nhẹ nhàng để đi bộ xuống một
đường dẫn tên tệp (tức là giống như chạy nhón chân).  RCU-walk không thể
đương đầu với mọi tình huống nên khi gặp khó khăn nó sẽ lùi lại
thành "REF-walk", chậm hơn nhưng mạnh mẽ hơn.

RCU-walk sẽ không bao giờ gọi ZZ0000ZZ; các hệ thống tập tin phải có sẵn
được gắn hoặc RCU-walk không thể xử lý đường dẫn.
Để xác định xem bẫy gắn có an toàn cho chế độ đi bộ RCU hay không, nó gọi
ZZ0001ZZ với ZZ0002ZZ được đặt thành ZZ0003ZZ.

Trong trường hợp này ZZ0000ZZ phải tránh chặn và tránh lấy
spinlocks nếu có thể.  Mục đích duy nhất của nó là xác định xem nó có
sẽ an toàn khi truy cập vào bất kỳ thư mục được gắn nào và thư mục duy nhất
lý do có thể không xảy ra là nếu giá treo hết hạn
đang được tiến hành.

Trong trường hợp ZZ0000ZZ, ZZ0001ZZ không thể trả về -EISDIR để thông báo
VFS rằng đây là thư mục không yêu cầu d_automount.  Nếu
ZZ0002ZZ nhìn thấy một chiếc răng có bộ DCACHE_NEED_AUTOMOUNT nhưng không có gì
được gắn, nó ZZ0005ZZ rơi trở lại REF-walk.  ZZ0003ZZ không thể thực hiện
VFS vẫn ở chế độ RCU-walk nhưng chỉ có thể yêu cầu nó thoát ra khỏi
Chế độ đi bộ RCU bằng cách quay lại ZZ0004ZZ.

Vì vậy, ZZ0000ZZ, khi được gọi với bộ ZZ0001ZZ, sẽ trả về
-ECHILD nếu có bất kỳ lý do nào cho rằng việc vào là không an toàn
hệ thống tập tin được gắn kết, nếu không nó sẽ trả về 0.

autofs sẽ trả về ZZ0000ZZ nếu hệ thống tập tin hết hạn
bắt đầu hoặc đang được xem xét, nếu không nó sẽ trả về 0.


Điểm gắn kết hết hạn
=================

VFS có cơ chế tự động hết hạn các giá treo không sử dụng,
vì nó có thể làm hết hạn mọi thông tin nha khoa chưa được sử dụng từ dcache.
Điều này được hướng dẫn bởi cờ MNT_SHRINKABLE.  Điều này chỉ áp dụng cho
các mount được tạo bởi ZZ0000ZZ sẽ trả về một hệ thống tập tin
gắn kết.  Vì autofs không trả về hệ thống tập tin như vậy mà để lại phần
gắn vào daemon automount, nó phải liên quan đến daemon automount
trong việc tháo lắp là tốt.  Điều này cũng có nghĩa là autofs có nhiều quyền kiểm soát hơn
quá hạn sử dụng.

VFS cũng hỗ trợ "hết hạn" các giá treo bằng cờ MNT_EXPIRE để
cuộc gọi hệ thống ZZ0000ZZ.  Việc ngắt kết nối bằng MNT_EXPIRE sẽ thất bại trừ khi
một nỗ lực trước đó đã được thực hiện và hệ thống tập tin không hoạt động
và không bị ảnh hưởng kể từ lần thử trước đó.  autofs không phụ thuộc vào
cái này nhưng có chức năng theo dõi nội bộ riêng để biết liệu hệ thống tập tin có bị
được sử dụng gần đây.  Điều này cho phép tên riêng lẻ trong thư mục autofs
hết hạn riêng biệt.

Với phiên bản 4 của giao thức, trình nền tự động đếm có thể thử
ngắt kết nối mọi hệ thống tệp được gắn trên hệ thống tệp autofs hoặc xóa mọi
liên kết tượng trưng hoặc thư mục trống bất cứ lúc nào nó muốn.  Nếu ngắt kết nối
hoặc xóa thành công hệ thống tập tin sẽ được trả về trạng thái
nó có trước khi gắn kết hoặc tạo, do đó bất kỳ quyền truy cập nào vào tên
sẽ kích hoạt xử lý tự động gắn kết bình thường.  Đặc biệt, ZZ0000ZZ và
ZZ0001ZZ không để lại các mục âm trong dcache như bình thường
hệ thống tập tin sẽ như vậy, do đó, nỗ lực truy cập vào một đối tượng bị xóa gần đây là
được chuyển tới autofs để xử lý.

Với phiên bản 5, điều này không an toàn ngoại trừ việc ngắt kết nối từ cấp cao nhất
thư mục.  Vì các thư mục cấp thấp hơn không bao giờ là bẫy gắn kết, các thư mục khác
các tiến trình sẽ thấy một thư mục trống ngay khi hệ thống tập tin được
chưa được gắn kết.  Vì vậy, nói chung là an toàn nhất khi sử dụng hết hạn tự động
giao thức được mô tả dưới đây.

Thông thường daemon chỉ muốn xóa các mục chưa được
sử dụng trong một thời gian.  Vì mục đích này, autofs duy trì "ZZ0000ZZ"
dấu thời gian trên mỗi thư mục hoặc liên kết tượng trưng.  Đối với các liên kết tượng trưng, nó thực sự
ghi lại lần cuối cùng liên kết tượng trưng được "sử dụng" hoặc theo dõi để tìm
ra nơi nó chỉ tới.  Đối với các thư mục, trường này được sử dụng một chút
khác nhau.  Trường được cập nhật tại thời điểm gắn kết và trong thời gian hết hạn
kiểm tra xem nó có được sử dụng hay không (ví dụ: mở bộ mô tả tập tin hoặc
xử lý thư mục làm việc) và trong quá trình đi bộ trên đường dẫn. Đã cập nhật xong
trong quá trình đi bộ trên đường ngăn chặn việc hết hạn thường xuyên và gắn kết ngay lập tức
tự động truy cập thường xuyên. Nhưng trong trường hợp GUI liên tục
truy cập hoặc một ứng dụng thường xuyên quét cây thư mục autofs
có thể có sự tích tụ của thú cưỡi mà thực tế không tồn tại
đã sử dụng. Để phục vụ cho trường hợp này, tùy chọn gắn autofs "ZZ0001ZZ"
có thể được sử dụng để tránh cập nhật "ZZ0002ZZ" khi đi bộ trên đường
ngăn chặn việc rõ ràng là không có khả năng hết hạn các thú cưỡi không có
thực sự đang được sử dụng.

Daemon có thể hỏi autofs xem có thứ gì sắp hết hạn hay không,
sử dụng ZZ0000ZZ như được thảo luận sau.  Đối với ngàm ZZ0001ZZ, autofs
xem xét liệu toàn bộ cây gắn kết có thể được ngắt kết nối hay không.  Đối với một
Mount ZZ0002ZZ, autofs xem xét từng tên ở cấp cao nhất
thư mục để xác định xem có bất kỳ thư mục nào trong số đó có thể được ngắt kết nối và làm sạch không
lên.

Có một tùy chọn gắn kết gián tiếp để xem xét từng lá
đã được gắn vào thay vì xem xét các tên cấp cao nhất.
Điều này ban đầu được dự định để tương thích với phiên bản 4 của autofs
và nên được coi là không được dùng nữa đối với bản đồ tự động đếm của Sun Format.
Tuy nhiên, nó có thể được sử dụng lại cho các bản đồ gắn kết định dạng amd (được
nói chung là các bản đồ gián tiếp) vì trình đếm tự động của AMD cho phép
thiết lập thời gian chờ hết hạn cho từng lần gắn kết. Nhưng có
một số khó khăn trong việc thực hiện những thay đổi cần thiết cho việc này.

Khi autofs xem xét một thư mục, nó sẽ kiểm tra thời gian ZZ0000ZZ và
so sánh nó với giá trị "hết thời gian" được đặt khi hệ thống tập tin
được gắn kết, mặc dù việc kiểm tra này bị bỏ qua trong một số trường hợp. Nó cũng kiểm tra xem
thư mục hoặc bất cứ thứ gì bên dưới nó đang được sử dụng.  Đối với các liên kết tượng trưng, ​​
chỉ có thời gian ZZ0001ZZ được xem xét.

Nếu cả hai đều hỗ trợ việc hết hạn thư mục hoặc liên kết tượng trưng, thì một hành động
được lấy.

Có hai cách để yêu cầu autofs xem xét thời hạn sử dụng.  Đầu tiên là để
sử dụng ZZ0001ZZ ioctl.  Điều này chỉ có tác dụng gián tiếp
gắn kết.  Nếu nó tìm thấy thứ gì đó trong thư mục gốc hết hạn, nó sẽ
trả lại tên của thứ đó.  Khi một tên đã được trả lại
daemon automount cần ngắt kết nối mọi hệ thống tập tin được gắn bên dưới
đặt tên bình thường.  Như đã mô tả ở trên, điều này không an toàn đối với các ứng dụng không phải cấp cao nhất.
gắn kết trong autofs phiên bản 5.  Vì lý do này, ZZ0000ZZ hiện tại
không sử dụng ioctl này.

Cơ chế thứ hai sử dụng ZZ0001ZZ hoặc
ZZ0002ZZ ioctl.  Điều này sẽ có tác dụng cho cả trực tiếp và
gắn kết gián tiếp.  Nếu nó chọn một đối tượng hết hạn, nó sẽ thông báo
daemon bằng cơ chế thông báo được mô tả bên dưới.  Cái này
sẽ chặn cho đến khi daemon xác nhận thông báo hết hạn.
Điều này ngụ ý rằng ioctl "ZZ0000ZZ" phải được gửi từ một địa chỉ khác
thread hơn là thread xử lý thông báo.

Trong khi ioctl đang chặn, mục nhập được đánh dấu là "hết hạn" và
ZZ0000ZZ sẽ chặn cho đến khi daemon xác nhận rằng việc ngắt kết nối đã hoàn tất
đã hoàn thành (cùng với việc xóa mọi thư mục có thể đã bị
cần thiết), hoặc đã bị hủy bỏ.

Giao tiếp với autofs: phát hiện daemon
===============================================

Có một số hình thức giao tiếp giữa daemon automount
và hệ thống tập tin.  Như chúng ta đã thấy, daemon có thể tạo và
xóa các thư mục và liên kết tượng trưng bằng các thao tác hệ thống tập tin thông thường.
autofs biết liệu một quy trình yêu cầu một số thao tác có phải là daemon hay không
hoặc không dựa trên số id nhóm quy trình của nó (xem getpgid(1)).

Khi hệ thống tập tin autofs được gắn pgid của quá trình gắn kết
các tiến trình được ghi lại trừ khi tùy chọn "pgrp=" được đưa ra, trong đó
trường hợp số đó được ghi lại thay thế.  Bất kỳ yêu cầu nào đến từ một
tiến trình trong nhóm tiến trình đó được coi là đến từ daemon.
Nếu daemon phải dừng lại và khởi động lại, một pgid mới có thể được
được cung cấp thông qua ioctl như sẽ được mô tả dưới đây.

Giao tiếp với autofs: ống sự kiện
=========================================

Khi hệ thống tập tin autofs được gắn kết, đầu 'ghi' của ống phải
được thông qua bằng cách sử dụng tùy chọn gắn kết 'fd='.  autofs sẽ viết
tin nhắn thông báo tới đường ống này để daemon phản hồi.
Đối với phiên bản 5, định dạng của tin nhắn là::

cấu trúc autofs_v5_packet {
		cấu trúc autofs_packet_hdr hdr;
		autofs_wqt_t wait_queue_token;
		__u32 nhà phát triển;
		__u64 nhé;
		__u32 uid;
		__u32 gid;
		__u32 pid;
		__u32 tgid;
		__u32 len;
		tên char[NAME_MAX+1];
        };

Và định dạng của tiêu đề là::

cấu trúc autofs_packet_hdr {
		int proto_version;		/*Phiên bản giao thức */
		kiểu int;			/*Loại gói tin*/
	};

trong đó loại là một trong ::

autofs_ptype_missing_indirect
	autofs_ptype_expire_indirect
	autofs_ptype_missing_direct
	autofs_ptype_expire_direct

vì vậy các tin nhắn có thể chỉ ra rằng một cái tên bị thiếu (có điều gì đó đã cố gắng
truy cập nhưng nó không có ở đó) hoặc nó đã được chọn để hết hạn.

Đường ống sẽ được đặt thành "chế độ gói" (tương đương với việc truyền
ZZ0000ZZ) thành _pipe2(2)_ để quá trình đọc từ đường ống sẽ quay trở lại tại
hầu hết một gói và mọi phần chưa đọc của gói sẽ bị loại bỏ.

ZZ0000ZZ là một số duy nhất có thể xác định một
yêu cầu cụ thể cần được thừa nhận.  Khi một tin nhắn được gửi qua
ống mà răng bị ảnh hưởng được đánh dấu là "hoạt động" hoặc
"hết hạn" và các quyền truy cập khác vào nó sẽ bị chặn cho đến khi tin nhắn được
được thừa nhận bằng cách sử dụng một trong các ioctls bên dưới với thông tin liên quan
ZZ0001ZZ.

Giao tiếp với autofs: thư mục gốc ioctls
================================================

Thư mục gốc của hệ thống tập tin autofs sẽ phản hồi một số
ioctls.  Quá trình phát hành ioctl phải có CAP_SYS_ADMIN
khả năng hoặc phải là daemon tự động.

Các lệnh ioctl có sẵn là:

-ZZ0002ZZ:
	một thông báo đã được xử lý.  Đối số
	với lệnh ioctl là số "wait_queue_token"
	tương ứng với thông báo được xác nhận.
-ZZ0003ZZ:
	tương tự như trên, nhưng biểu thị sự thất bại với
	mã lỗi ZZ0000ZZ.
-ZZ0004ZZ:
	Làm cho autofs chuyển sang trạng thái "catatonic"
	mode có nghĩa là nó ngừng gửi thông báo đến daemon.
	Chế độ này cũng được kích hoạt nếu quá trình ghi vào đường ống không thành công.
-ZZ0005ZZ:
	Điều này trả về phiên bản giao thức đang được sử dụng.
-ZZ0006ZZ:
	Trả về phiên bản phụ của giao thức
	thực sự là số phiên bản để triển khai.
-ZZ0007ZZ:
	Điều này chuyển một con trỏ tới một dấu không dấu
	dài.  Giá trị được sử dụng để đặt thời gian chờ hết hạn và
	giá trị thời gian chờ hiện tại được lưu lại thông qua con trỏ.
-ZZ0008ZZ:
	Trả về, trong ZZ0001ZZ được trỏ tới, 1 nếu
	hệ thống tập tin có thể được ngắt kết nối.  Đây chỉ là gợi ý vì
	tình hình có thể thay đổi bất cứ lúc nào.  Cuộc gọi này có thể
	được sử dụng để tránh nỗ lực ngắt kết nối hoàn toàn tốn kém hơn.
-ZZ0009ZZ:
	như được mô tả ở trên, điều này hỏi liệu có
	bất cứ điều gì phù hợp để hết hạn.  Một con trỏ tới một gói::

cấu trúc autofs_packet_expire_multi {
			cấu trúc autofs_packet_hdr hdr;
			autofs_wqt_t wait_queue_token;
			int len;
			tên char[NAME_MAX+1];
		};

được yêu cầu.  Cái này được điền với tên của một cái gì đó
	có thể được tháo hoặc gỡ bỏ.  Nếu không có gì có thể hết hạn,
	ZZ0000ZZ được đặt thành ZZ0001ZZ.  Mặc dù là ZZ0002ZZ
	có trong cấu trúc, không có "hàng đợi" nào được thiết lập
	và không cần sự thừa nhận.
-ZZ0003ZZ:
	Điều này tương tự như
	ZZ0004ZZ ngoại trừ việc nó khiến thông báo bị
	được gửi đến daemon và nó sẽ chặn cho đến khi daemon xác nhận.
	Đối số là một số nguyên có thể chứa hai cờ khác nhau.

ZZ0001ZZ khiến thời gian của ZZ0000ZZ bị bỏ qua
	và các đồ vật sẽ hết hạn nếu không được sử dụng.

ZZ0000ZZ khiến trạng thái đang sử dụng bị bỏ qua
	và các đối tượng đã hết hạn ngay cả khi chúng đang được sử dụng. Điều này giả định
	rằng daemon đã yêu cầu điều này bởi vì nó có khả năng
	thực hiện số lượng.

ZZ0000ZZ sẽ chọn một lá thay vì cấp cao nhất
	tên sắp hết hạn.  Điều này chỉ an toàn khi ZZ0001ZZ là 4.

Giao tiếp với autofs: char-device ioctls
=============================================

Không phải lúc nào cũng có thể mở được thư mục gốc của hệ thống tập tin autofs,
đặc biệt là hệ thống tập tin được gắn ZZ0000ZZ.  Nếu daemon tự động kết nối
được khởi động lại thì không có cách nào để lấy lại quyền kiểm soát hiện tại
gắn kết bằng cách sử dụng bất kỳ kênh liên lạc nào ở trên.  Để giải quyết vấn đề này
cần có một thiết bị ký tự "linh tinh" (chính 10, thứ 235)
có thể được sử dụng để giao tiếp trực tiếp với hệ thống tập tin autofs.
Nó yêu cầu CAP_SYS_ADMIN để truy cập.

'ioctl' có thể được sử dụng trên thiết bị này được mô tả trong một phần riêng
tài liệu ZZ0000ZZ, và được tóm tắt ngắn gọn ở đây.
Mỗi ioctl được truyền một con trỏ tới cấu trúc ZZ0001ZZ ::

cấu trúc autofs_dev_ioctl {
                __u32 ver_major;
                __u32 ver_minor;
                __u32 kích thước;             /* tổng kích thước dữ liệu được truyền vào
                                         * bao gồm cả cấu trúc này */
                __s32 ioctlfd;          /* lệnh tự động đếm fd */

/* Tham số lệnh */
		công đoàn {
			struct args_protover protover;
			struct args_protosubver protosubver;
			struct args_openmount openmount;
			struct args_ready đã sẵn sàng;
			cấu trúc args_fail thất bại;
			struct args_setpipefd setpipefd;
			struct args_timeout hết thời gian chờ;
			người yêu cầu struct args_requester;
			struct args_expire hết hạn;
			struct args_askumount yêu cầu;
			struct args_ismountpoint ismountpoint;
		};

đường dẫn char[];
        };

Đối với các lệnh ZZ0002ZZ và ZZ0003ZZ, mục tiêu
hệ thống tập tin được xác định bởi ZZ0000ZZ.  Tất cả các lệnh khác xác định
hệ thống tập tin của ZZ0001ZZ, một bộ mô tả tập tin được mở trên
root và có thể được trả về bởi ZZ0004ZZ.

ZZ0000ZZ và ZZ0001ZZ là các tham số vào/ra để kiểm tra xem
phiên bản được yêu cầu được hỗ trợ và báo cáo phiên bản tối đa
mà mô-đun hạt nhân có thể hỗ trợ.

Các lệnh là:

-ZZ0007ZZ:
	không làm gì cả, ngoại trừ xác nhận và
	đặt số phiên bản.
-ZZ0008ZZ:
	trả về một bộ mô tả tập tin đang mở
	trên thư mục gốc của hệ thống tập tin autofs.  Hệ thống tập tin được xác định
	theo tên và số thiết bị, được lưu trữ trong ZZ0000ZZ.
	Số thiết bị cho các hệ thống tập tin hiện có có thể được tìm thấy trong
	ZZ0001ZZ.
-ZZ0009ZZ:
	giống như ZZ0002ZZ.
-ZZ0010ZZ:
	nếu hệ thống tập tin ở trong
	chế độ catatonic, điều này có thể cung cấp đầu ghi của một đường ống mới
	trong ZZ0003ZZ để thiết lập lại liên lạc với daemon.
	Nhóm quy trình của quy trình gọi được sử dụng để xác định
	daemon.
-ZZ0011ZZ:
	ZZ0004ZZ phải là một
	tên trong hệ thống tập tin đã được tự động gắn vào.
	Khi trở về thành công, ZZ0005ZZ và ZZ0006ZZ sẽ
	UID và GID của quá trình đã kích hoạt quá trình gắn kết đó.
-ZZ0012ZZ:
	Kiểm tra xem đường dẫn có phải là một
	điểm gắn kết của một loại cụ thể - xem tài liệu riêng cho
	chi tiết.

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ
-ZZ0006ZZ
-ZZ0007ZZ

Tất cả những điều này đều giống nhau
hoạt động giống như ZZ0002ZZ ioctls có tên tương tự, ngoại trừ
ZZ0003ZZ có thể được cung cấp một số lỗi rõ ràng trong ZZ0000ZZ
thay vì giả sử ZZ0001ZZ và lệnh ZZ0004ZZ này
tương ứng với ZZ0005ZZ.

Chế độ catatonic
==============

Như đã đề cập, ngàm autofs có thể vào chế độ "catatonic".  Cái này
xảy ra nếu quá trình ghi vào ống thông báo không thành công hoặc nếu nó bị lỗi
được yêu cầu rõ ràng bởi ZZ0000ZZ.

Khi vào chế độ catatonic, đường ống sẽ đóng lại và mọi thứ đang chờ xử lý.
thông báo được xác nhận có lỗi ZZ0000ZZ.

Khi ở chế độ catatonic, các nỗ lực truy cập vào các tên không tồn tại sẽ
dẫn đến ZZ0000ZZ trong khi các nỗ lực truy cập vào các thư mục hiện có sẽ
được đối xử giống như thể chúng đến từ daemon, vì vậy hãy gắn kết
bẫy sẽ không bắn.

Khi hệ thống tập tin được gắn kết, _uid_ và _gid_ có thể được cung cấp
thiết lập quyền sở hữu các thư mục và liên kết tượng trưng.  Khi
hệ thống tập tin ở chế độ catatonic, bất kỳ quá trình nào có UID phù hợp đều có thể
tạo thư mục hoặc liên kết tượng trưng trong thư mục gốc, nhưng không phải trong thư mục khác
thư mục.

Chế độ catatonic chỉ có thể được duy trì thông qua
ZZ0001ZZ ioctl trên ZZ0000ZZ.

Tùy chọn gắn kết "bỏ qua"
=========================

Tùy chọn gắn kết "bỏ qua" có thể được sử dụng để cung cấp chỉ báo chung
đối với các ứng dụng mà mục gắn kết sẽ bị bỏ qua khi hiển thị
gắn kết thông tin.

Trong các hệ điều hành khác cung cấp tính năng tự động xác thực và cung cấp danh sách gắn kết cho người dùng
không gian dựa trên danh sách gắn kernel một tùy chọn gắn kết không hoạt động ("bỏ qua" là
được phép sử dụng một lần trên các hệ điều hành phổ biến nhất) để tệp autofs
người dùng hệ thống có thể tùy ý sử dụng nó.

Điều này được dự định sẽ được sử dụng bởi các chương trình không gian người dùng để loại trừ tự động
gắn kết khỏi sự cân nhắc khi đọc danh sách gắn kết.

autofs, không gian tên và gắn kết được chia sẻ
======================================

Với các liên kết gắn kết và không gian tên, có thể tự động
hệ thống tập tin xuất hiện ở nhiều nơi trong một hoặc nhiều hệ thống tập tin
không gian tên.  Để tính năng này hoạt động hợp lý, hệ thống tập tin autofs phải
luôn được gắn kết "chia sẻ". ví dụ. ::

mount --make-shared /autofs/mount/point

Trình nền tự động gắn kết chỉ có thể quản lý một vị trí gắn kết duy nhất cho
một hệ thống tập tin autofs và nếu các mount trên đó không được 'chia sẻ', thì hệ thống khác
vị trí sẽ không hoạt động như mong đợi.  Đặc biệt là khả năng tiếp cận những
các vị trí khác có thể sẽ dẫn đến lỗi ZZ0000ZZ ::

Quá nhiều cấp độ liên kết tượng trưng
