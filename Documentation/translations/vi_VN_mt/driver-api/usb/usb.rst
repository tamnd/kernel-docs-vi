.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/usb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _usb-hostside-api:

==============================
Phía máy chủ Linux-USB API
===========================

Giới thiệu về USB trên Linux
============================

Bus nối tiếp đa năng (USB) được sử dụng để kết nối máy chủ, chẳng hạn như PC hoặc
máy trạm đến một số thiết bị ngoại vi. USB sử dụng cây
cấu trúc, với máy chủ là gốc (chính của hệ thống), các trung tâm là
các nút bên trong và các thiết bị ngoại vi là các lá (và nô lệ). PC hiện đại
thường hỗ trợ một số cây thiết bị USB như vậy
một vài USB 3.0 (5 GBit/s) hoặc USB 3.1 (10 GBit/s) và một số phiên bản cũ
Xe buýt USB 2.0 (480 MBit/s) đề phòng.

Sự bất đối xứng chủ/nô lệ đó được thiết kế sẵn vì một số lý do, một
dễ sử dụng. Về mặt vật lý, không thể nhầm lẫn ngược dòng và
xuôi dòng hoặc không thành vấn đề với phích cắm loại C (hoặc chúng được tích hợp vào
ngoại vi). Ngoài ra, phần mềm máy chủ không cần phải xử lý
cấu hình tự động được phân phối kể từ nút chính được chỉ định trước
quản lý tất cả điều đó.

Các nhà phát triển hạt nhân đã sớm bổ sung hỗ trợ USB cho Linux trong hạt nhân 2.2
loạt và đã phát triển nó hơn nữa kể từ đó. Ngoài sự hỗ trợ
đối với mỗi thế hệ USB mới, nhiều bộ điều khiển máy chủ khác nhau đã được hỗ trợ,
trình điều khiển mới cho thiết bị ngoại vi đã được thêm vào và các tính năng nâng cao cho độ trễ
đo lường và cải thiện quản lý năng lượng được giới thiệu.

Linux có thể chạy bên trong các thiết bị USB cũng như trên các máy chủ điều khiển
các thiết bị. Nhưng trình điều khiển thiết bị USB chạy bên trong các thiết bị ngoại vi đó
không làm những việc tương tự như những thứ chạy bên trong máy chủ, vì vậy chúng
được đặt một cái tên khác: ZZ0000ZZ. Tài liệu này không
che trình điều khiển tiện ích.

USB Model API phía máy chủ
=======================

Trình điều khiển phía máy chủ dành cho thiết bị USB giao tiếp với API "usbcore". có
hai. Một cái dành cho trình điều khiển ZZ0000ZZ (được tiếp xúc qua
khung trình điều khiển) và khung còn lại dành cho các trình điều khiển *một phần của
trình điều khiển core*. Such core drivers include the *hub* (quản lý cây
của thiết bị USB) và một số loại *bộ điều khiển máy chủ khác nhau
trình điều khiển*, điều khiển xe buýt riêng lẻ.

Mẫu thiết bị mà trình điều khiển USB nhìn thấy tương đối phức tạp.

- USB hỗ trợ bốn loại truyền dữ liệu (điều khiển, số lượng lớn, ngắt,
   và đẳng thời). Hai trong số chúng (kiểm soát và số lượng lớn) sử dụng băng thông như
   nó có sẵn, trong khi hai cái còn lại (ngắt và đẳng thời) là
   được lên lịch để cung cấp băng thông được đảm bảo.

- Mô hình mô tả thiết bị bao gồm một hoặc nhiều "cấu hình"
   trên mỗi thiết bị, tại một thời điểm chỉ có một thiết bị hoạt động. Các thiết bị được cho là
   có khả năng hoạt động ở mức thấp hơn mức cao nhất của họ
   tốc độ và có thể cung cấp bộ mô tả BOS hiển thị tốc độ thấp nhất mà chúng
   vẫn hoạt động đầy đủ tại.

- Từ USB 3.0 trở đi cấu hình có một hoặc nhiều “chức năng”
   cung cấp một chức năng chung và được nhóm lại với nhau cho các mục đích
   về quản lý điện năng.

- Cấu hình hoặc chức năng có một hoặc nhiều "giao diện", mỗi giao diện có thể có
   "cài đặt thay thế". Các giao diện có thể được chuẩn hóa bởi "Class" USB
   thông số kỹ thuật hoặc có thể dành riêng cho nhà cung cấp hoặc thiết bị.

Trình điều khiển thiết bị USB thực sự liên kết với giao diện chứ không phải thiết bị. nghĩ về
   chúng là "trình điều khiển giao diện", mặc dù bạn có thể không thấy nhiều thiết bị
   nơi mà sự khác biệt là quan trọng. *Hầu hết các thiết bị USB đều đơn giản,
   chỉ với một chức năng, một cấu hình, một giao diện và một thay thế
   cài đặt.*

- Giao diện có một hoặc nhiều "điểm cuối", mỗi giao diện hỗ trợ một
   loại và hướng truyền dữ liệu chẳng hạn như "xuất hàng loạt" hoặc "ngắt
   trong". Toàn bộ cấu hình có thể có tới 16 điểm cuối trong
   mỗi hướng, được phân bổ khi cần thiết giữa tất cả các giao diện.

- Truyền dữ liệu trên USB được đóng gói; mỗi điểm cuối có mức tối đa
   kích thước gói. Người lái xe thường phải nhận thức được các quy ước như
   gắn cờ kết thúc chuyển khoản số lượng lớn bằng cách sử dụng "ngắn" (bao gồm cả số 0
   chiều dài) gói.

- Linux USB API hỗ trợ các cuộc gọi đồng bộ để điều khiển và hàng loạt
   tin nhắn. Nó cũng hỗ trợ các cuộc gọi không đồng bộ cho tất cả các loại dữ liệu
   truyền tải, sử dụng cấu trúc yêu cầu được gọi là "URB" (USB Yêu cầu
   Khối).

Theo đó, USB Core API lộ trình điều khiển thiết bị bao gồm khá nhiều
nhiều lãnh thổ. Có lẽ bạn sẽ cần tham khảo USB 3.0
thông số kỹ thuật, có sẵn trực tuyến miễn phí từ www.usb.org, cũng như
thông số kỹ thuật của lớp hoặc thiết bị.

Trình điều khiển phía máy chủ duy nhất thực sự chạm vào phần cứng (đọc/ghi
thanh ghi, xử lý IRQ, v.v.) là các HCD. Về lý thuyết, tất cả các HCD
cung cấp chức năng tương tự thông qua cùng một API. Trong thực tế, đó là
trở nên đúng hơn nhưng vẫn có những khác biệt
điều này xảy ra đặc biệt khi xử lý lỗi trên các bộ điều khiển ít phổ biến hơn.
Bộ điều khiển khác nhau không
nhất thiết phải báo cáo các khía cạnh tương tự của các lỗi và việc phục hồi từ
vẫn chưa có lỗi (kể cả lỗi do phần mềm gây ra như hủy liên kết URB)
hoàn toàn nhất quán. Các tác giả trình điều khiển thiết bị nên lưu ý thực hiện
kiểm tra ngắt kết nối (trong khi thiết bị đang hoạt động) với từng máy chủ khác nhau
trình điều khiển, để đảm bảo trình điều khiển không có lỗi riêng như
cũng như để đảm bảo rằng họ không dựa vào một số hành vi dành riêng cho HCD.

.. _usb_chapter9:

USB-Loại tiêu chuẩn
==================

Trong ZZ0000ZZ bạn sẽ tìm thấy các kiểu dữ liệu USB được xác định
trong chương 9 của đặc tả USB. Các kiểu dữ liệu này được sử dụng xuyên suốt
USB và trong các API bao gồm API phía máy chủ này, API tiện ích, ký tự usb
thiết bị và giao diện debugfs. Bản thân tập tin đó được bao gồm bởi
ZZ0001ZZ, cũng chứa các khai báo của một số
các thủ tục tiện ích để thao tác các loại dữ liệu này; việc triển khai
đang ở ZZ0002ZZ.

.. kernel-doc:: drivers/usb/common/common.c
   :export:

Ngoài ra, một số chức năng hữu ích cho việc tạo đầu ra gỡ lỗi là
được xác định trong ZZ0000ZZ.

.. _usb_header:

Các kiểu dữ liệu và macro phía máy chủ
===============================

Phía máy chủ API hiển thị một số lớp cho trình điều khiển, một số trong đó là
cần thiết hơn những người khác. Các mô hình vòng đời hỗ trợ này cho phía máy chủ
trình điều khiển và thiết bị, đồng thời hỗ trợ truyền bộ đệm qua usbcore tới một số
HCD thực hiện I/O cho trình điều khiển thiết bị.

.. kernel-doc:: include/linux/usb.h
   :internal:

API lõi USB
=============

Có hai mô hình I/O cơ bản trong USB API. Nguyên tố nhất là
không đồng bộ: trình điều khiển gửi yêu cầu dưới dạng URB và
Lệnh gọi lại hoàn thành của URB sẽ xử lý bước tiếp theo. Tất cả các loại truyền USB
hỗ trợ mô hình đó, mặc dù có những trường hợp đặc biệt đối với URB điều khiển
(luôn có các giai đoạn thiết lập và trạng thái, nhưng có thể không có dữ liệu
giai đoạn) và URB đẳng thời (cho phép các gói lớn và bao gồm
báo cáo lỗi trên mỗi gói). Được xây dựng trên đó là API đồng bộ
hỗ trợ, trong đó trình điều khiển gọi một quy trình phân bổ một hoặc nhiều URB,
gửi chúng và đợi cho đến khi chúng hoàn thành. Có đồng bộ
các trình bao bọc để kiểm soát bộ đệm đơn và chuyển số lượng lớn (điều này thật khó xử
để sử dụng trong một số trường hợp ngắt kết nối trình điều khiển) và dựa trên danh sách phân tán
truyền phát i/o (số lượng lớn hoặc gián đoạn).

Trình điều khiển USB cần cung cấp bộ đệm có thể được sử dụng cho DMA, mặc dù
họ không nhất thiết phải tự cung cấp bản đồ DMA. Ở đó
là các API được sử dụng khi phân bổ bộ đệm DMA, điều này có thể ngăn cản việc sử dụng
bộ đệm bị trả lại trên một số hệ thống. Trong một số trường hợp, người lái xe có thể
dựa vào DMA 64bit để loại bỏ một loại bộ đệm thoát khác.

.. kernel-doc:: drivers/usb/core/urb.c
   :export:

.. c:namespace:: usb_core
.. kernel-doc:: drivers/usb/core/message.c
   :export:

.. kernel-doc:: drivers/usb/core/file.c
   :export:

.. kernel-doc:: drivers/usb/core/driver.c
   :export:

.. kernel-doc:: drivers/usb/core/usb.c
   :export:

.. kernel-doc:: drivers/usb/core/hub.c
   :export:

API bộ điều khiển máy chủ
====================

Các API này chỉ được sử dụng bởi trình điều khiển bộ điều khiển máy chủ, hầu hết trong số đó
triển khai các giao diện đăng ký tiêu chuẩn như XHCI, EHCI, OHCI hoặc UHCI. UHCI
là một trong những giao diện đầu tiên do Intel thiết kế và cũng được VIA sử dụng;
nó không làm được gì nhiều về phần cứng. OHCI được thiết kế sau này để có
phần cứng thực hiện nhiều công việc hơn (chuyển lớn hơn, theo dõi trạng thái giao thức, v.v.
trên). EHCI được thiết kế với USB 2.0; thiết kế của nó có những tính năng
giống với OHCI (phần cứng hoạt động được nhiều hơn) cũng như UHCI (một số phần
hỗ trợ ISO, xử lý danh sách TD). XHCI được thiết kế với USB 3.0. Nó
tiếp tục chuyển hỗ trợ chức năng sang phần cứng.

Có các bộ điều khiển máy chủ khác ngoài "bộ ba lớn", mặc dù hầu hết PCI
bộ điều khiển dựa trên (và một số bộ điều khiển không dựa trên PCI) sử dụng một trong những bộ điều khiển đó
giao diện. Không phải tất cả bộ điều khiển máy chủ đều sử dụng DMA; một số sử dụng PIO, và có
cũng là một trình mô phỏng và bộ điều khiển máy chủ ảo để truyền USB qua mạng.

Các API cơ bản tương tự có sẵn cho trình điều khiển của tất cả các bộ điều khiển đó.
Vì lý do lịch sử, chúng có hai lớp: ZZ0000ZZ là một lớp khá mỏng đã có sẵn
trong hạt nhân 2.2, trong khi ZZ0001ZZ
là một lớp có nhiều tính năng hơn
cho phép HCD chia sẻ mã chung, giảm kích thước trình điều khiển và
giảm đáng kể các hành vi cụ thể của hcd.

.. kernel-doc:: drivers/usb/core/hcd.c
   :export:

.. kernel-doc:: drivers/usb/core/hcd-pci.c
   :export:

.. kernel-doc:: drivers/usb/core/buffer.c
   :internal:

Các nút thiết bị ký tự USB
==============================

Chương này trình bày các nút thiết bị ký tự Linux. Bạn có thể thích
để tránh viết mã hạt nhân mới cho trình điều khiển USB của bạn. Thiết bị chế độ người dùng
trình điều khiển thường được đóng gói dưới dạng ứng dụng hoặc thư viện và có thể sử dụng
thiết bị ký tự thông qua một số thư viện lập trình bao bọc nó.
Các thư viện như vậy bao gồm:

- ZZ0000ZZ cho C/C++, và
 - ZZ0001ZZ cho Java.

Một số thông tin cũ về nó có thể được xem tại "Hệ thống tệp thiết bị USB"
phần của Hướng dẫn USB. Có thể tìm thấy bản sao mới nhất của Hướng dẫn USB
tại ZZ0000ZZ

.. note::

  - They were used to be implemented via *usbfs*, but this is not part of
    the sysfs debug interface.

   - This particular documentation is incomplete, especially with respect
     to the asynchronous mode. As of kernel 2.5.66 the code and this
     (new) documentation need to be cross-reviewed.

Những tập tin nào trong "devtmpfs"?
-----------------------------

Được gắn thông thường tại ZZ0000ZZ, các tính năng của usbfs bao gồm:

- ZZ0000ZZ... file ma thuật hiển thị thông tin của từng thiết bị
   mô tả cấu hình và hỗ trợ một loạt ioctls cho
   thực hiện các yêu cầu thiết bị, bao gồm cả I/O cho thiết bị. (Hoàn toàn để truy cập
   theo chương trình.)

Mỗi xe buýt được cấp một số (ZZ0000ZZ) dựa trên thời điểm nó được liệt kê; bên trong
mỗi bus, mỗi thiết bị được cấp một số tương tự (ZZ0001ZZ). Những chiếc ZZ0002ZZ đó
đường dẫn không phải là định danh "ổn định"; mong đợi họ thay đổi ngay cả khi bạn
luôn để các thiết bị được cắm vào cùng một cổng trung tâm. *Thậm chí không
hãy nghĩ đến việc lưu chúng vào các tệp cấu hình ứng dụng.* Ổn định
số nhận dạng có sẵn, dành cho các ứng dụng chế độ người dùng muốn sử dụng
họ. HID và các thiết bị mạng hiển thị các ID ổn định này, do đó,
Ví dụ: bạn có thể chắc chắn rằng bạn đã yêu cầu UPS bên phải tắt nguồn của nó
máy chủ thứ hai. Xin lưu ý rằng nó không (chưa) tiết lộ những ID đó.

/dev/bus/usb/BBB/DDD
--------------------

Sử dụng các tệp này theo một trong những cách cơ bản sau:

- ZZ0000ZZ tạo bộ mô tả thiết bị đầu tiên (18 byte) và
  sau đó là phần mô tả cho cấu hình hiện tại. Xem thông số USB 2.0
  để biết chi tiết về các định dạng dữ liệu nhị phân đó. Bạn sẽ cần phải chuyển đổi hầu hết
  giá trị nhiều byte từ định dạng endian nhỏ đến byte máy chủ gốc của bạn
  thứ tự, mặc dù một số trường trong bộ mô tả thiết bị (cả hai
  các trường được mã hóa BCD cũng như ID nhà cung cấp và sản phẩm) sẽ là
  trao đổi byte cho bạn. Lưu ý rằng mô tả cấu hình bao gồm
  mô tả cho giao diện, cài đặt thay thế, điểm cuối và có thể bổ sung
  các mô tả lớp.

- ZZ0001ZZ sử dụng các yêu cầu ZZ0002ZZ để tạo I/O điểm cuối
  yêu cầu (đồng bộ hoặc không đồng bộ) hoặc quản lý thiết bị. Những cái này
  các yêu cầu cần có khả năng ZZ0000ZZ, cũng như hệ thống tệp
  quyền truy cập. Chỉ có thể thực hiện một yêu cầu ioctl trên một trong những yêu cầu này
  tập tin thiết bị tại một thời điểm. Điều này có nghĩa là nếu bạn đang đọc đồng bộ
  điểm cuối của một luồng, bạn sẽ không thể ghi vào một luồng khác
  điểm cuối từ một luồng khác cho đến khi quá trình đọc hoàn tất. Điều này làm việc cho
  Các giao thức ZZ0003ZZ, nhưng nếu không thì bạn sẽ sử dụng i/o không đồng bộ
  yêu cầu.

Mỗi thiết bị USB được kết nối có một tệp.  ZZ0000ZZ cho biết xe buýt
số.  ZZ0001ZZ cho biết địa chỉ thiết bị trên xe buýt đó.  Cả hai
trong số các số này được gán tuần tự và có thể được sử dụng lại, vì vậy
bạn không thể dựa vào chúng để truy cập ổn định vào các thiết bị.  Ví dụ,
việc các thiết bị liệt kê lại trong khi chúng đang hoạt động là điều tương đối phổ biến.
vẫn được kết nối (có lẽ ai đó đã chen vào nguồn điện, trung tâm,
hoặc cáp USB), do đó, thiết bị có thể là ZZ0002ZZ khi bạn kết nối lần đầu
nó và ZZ0003ZZ sau đó.

Những tập tin này có thể được đọc dưới dạng dữ liệu nhị phân.  Dữ liệu nhị phân bao gồm
đầu tiên là bộ mô tả thiết bị, sau đó là bộ mô tả cho từng thiết bị
cấu hình của thiết bị.  Các trường nhiều byte trong bộ mô tả thiết bị
được hạt nhân chuyển đổi thành độ bền của máy chủ.  Cấu hình
mô tả có định dạng bus endian! Bộ mô tả cấu hình
cách nhau wTotalLength byte. Nếu một thiết bị trả về ít cấu hình hơn
dữ liệu mô tả hơn được chỉ ra bởi wTotalLength sẽ có một lỗ hổng trong
tập tin cho các byte bị thiếu.  Thông tin này cũng được hiển thị
ở dạng văn bản bằng tệp ZZ0000ZZ, được mô tả sau.

Những tệp này cũng có thể được sử dụng để ghi trình điều khiển cấp người dùng cho USB
thiết bị.  Bạn sẽ mở đọc/ghi tệp ZZ0000ZZ,
đọc phần mô tả của nó để đảm bảo đó là thiết bị bạn mong đợi, sau đó
liên kết với một giao diện (hoặc có thể là một số giao diện) bằng cách sử dụng lệnh gọi ioctl.  bạn
sẽ phát hành nhiều ioctls hơn cho thiết bị để liên lạc với thiết bị bằng cách sử dụng
kiểm soát, số lượng lớn hoặc các loại chuyển USB khác.  IOCTL là
được liệt kê trong tệp ZZ0001ZZ và tại thời điểm này, hãy viết
mã nguồn (ZZ0002ZZ) là tài liệu tham khảo chính
để biết cách truy cập các thiết bị thông qua các tệp đó.

Lưu ý rằng theo mặc định, các tệp ZZ0000ZZ này chỉ có thể ghi được bằng
root, chỉ root mới có thể viết trình điều khiển chế độ người dùng như vậy.  Bạn có thể chọn lọc
cấp quyền đọc/ghi cho người dùng khác bằng cách sử dụng ZZ0001ZZ.  Ngoài ra,
các tùy chọn gắn kết usbfs như ZZ0002ZZ có thể hữu ích.


Vòng đời của trình điều khiển chế độ người dùng
-------------------------------

Trình điều khiển như vậy trước tiên cần tìm tệp thiết bị cho thiết bị mà nó biết
làm thế nào để xử lý. Có lẽ nó được kể về nó bởi vì ZZ0001ZZ
tác nhân xử lý sự kiện đã chọn trình điều khiển đó để xử lý thiết bị mới. Hoặc
có thể đó là một ứng dụng quét tất cả các tệp thiết bị ZZ0002ZZ,
và bỏ qua hầu hết các thiết bị. Trong cả hai trường hợp, nó phải là ZZ0000ZZ
tất cả các bộ mô tả từ tệp thiết bị và kiểm tra chúng dựa trên những gì nó
biết cách xử lý. Nó có thể từ chối mọi thứ ngoại trừ một điều cụ thể
ID nhà cung cấp và sản phẩm hoặc cần một chính sách phức tạp hơn.

Đừng bao giờ cho rằng sẽ chỉ có một thiết bị như vậy trên hệ thống tại một thời điểm!
Nếu mã của bạn không thể xử lý nhiều thiết bị cùng một lúc, thì ít nhất
phát hiện khi có nhiều hơn một và yêu cầu người dùng của bạn chọn cái nào
thiết bị để sử dụng.

Khi trình điều khiển chế độ người dùng của bạn biết nên sử dụng thiết bị nào, nó sẽ tương tác với
nó theo một trong hai phong cách. Phong cách đơn giản là chỉ thực hiện kiểm soát
yêu cầu; một số thiết bị không cần những tương tác phức tạp hơn những thiết bị đó.
(Ví dụ có thể là phần mềm sử dụng các yêu cầu kiểm soát dành riêng cho nhà cung cấp để
một số tác vụ khởi tạo hoặc cấu hình, với trình điều khiển hạt nhân cho
nghỉ ngơi.)

Nhiều khả năng, bạn cần một trình điều khiển kiểu phức tạp hơn: một trình điều khiển sử dụng tính năng không điều khiển
điểm cuối, đọc hoặc ghi dữ liệu và yêu cầu sử dụng độc quyền một
giao diện. Chuyển ZZ0000ZZ dễ sử dụng nhất, nhưng chỉ có anh chị em của họ
Chuyển ZZ0001ZZ hoạt động với các thiết bị tốc độ thấp. Cả hai đều làm gián đoạn và
Chuyển ZZ0002ZZ cung cấp đảm bảo dịch vụ vì băng thông của chúng
được bảo lưu. Việc chuyển tiền "định kỳ" như vậy rất khó sử dụng thông qua usbfs,
trừ khi bạn đang sử dụng các cuộc gọi không đồng bộ. Tuy nhiên, việc truyền ngắt
cũng có thể được sử dụng theo kiểu "một phát" đồng bộ.

Trình điều khiển ở chế độ người dùng của bạn sẽ không bao giờ phải lo lắng về việc dọn dẹp
trạng thái yêu cầu khi thiết bị bị ngắt kết nối, mặc dù thiết bị sẽ đóng
bộ mô tả tệp đang mở của nó ngay khi nó bắt đầu thấy lỗi ENODEV.

Các yêu cầu ioctl()
--------------------

Để sử dụng các ioctls này, bạn cần bao gồm các tiêu đề sau trong
chương trình không gian người dùng::

#include <linux/usb.h>
    #include <linux/usbdevice_fs.h>
    #include <asm/byteorder.h>

Yêu cầu mẫu thiết bị USB tiêu chuẩn, từ "Chương 9" của USB 2.0
đặc điểm kỹ thuật, được tự động đưa vào ZZ0000ZZ
tiêu đề.

Trừ khi có ghi chú khác, các yêu cầu ioctl được mô tả ở đây sẽ cập nhật
thời gian sửa đổi trên tệp usbfs mà chúng được áp dụng
(trừ khi họ thất bại). Kết quả trả về bằng 0 biểu thị thành công; mặt khác, một
mã lỗi USB tiêu chuẩn được trả về (Những mã này được ghi lại trong
ZZ0000ZZ).

Mỗi tệp này ghép kênh truy cập vào một số luồng I/O, mỗi luồng một luồng
điểm cuối. Mỗi thiết bị có một điểm cuối điều khiển (điểm cuối số 0)
hỗ trợ truy cập RPC kiểu RPC có giới hạn. Các thiết bị được cấu hình bởi
hub_wq (trong kernel) thiết lập ZZ0000ZZ trên toàn thiết bị
ảnh hưởng đến những thứ như mức tiêu thụ điện năng và chức năng cơ bản. các
điểm cuối là một phần của USB ZZ0001ZZ, có thể có ZZ0002ZZ
ảnh hưởng đến những thứ như điểm cuối nào có sẵn. Chỉ nhiều thiết bị
có một cấu hình và giao diện duy nhất, do đó các trình điều khiển dành cho chúng sẽ
bỏ qua cấu hình và cài đặt thay thế.

Yêu cầu quản lý/trạng thái
~~~~~~~~~~~~~~~~~~~~~~~~~~

Một số yêu cầu usbfs không xử lý trực tiếp với I/O của thiết bị.
Chúng chủ yếu liên quan đến quản lý và trạng thái thiết bị. Đây là tất cả
các yêu cầu đồng bộ.

USBDEVFS_CLAIMINTERFACE
    Điều này được sử dụng để buộc các usbfs yêu cầu một giao diện cụ thể, có
    trước đây chưa được xác nhận quyền sở hữu bởi usbfs hoặc bất kỳ trình điều khiển hạt nhân nào khác. các
    Tham số ioctl là một số nguyên chứa số lượng giao diện
    (bSố giao diện từ bộ mô tả).

Lưu ý rằng nếu trình điều khiển của bạn không yêu cầu giao diện trước khi thử
    sử dụng một trong các điểm cuối của nó và không có trình điều khiển nào khác ràng buộc với nó, sau đó
    giao diện được tự động xác nhận bởi usbfs.

Khiếu nại này sẽ được đưa ra bởi RELEASEINTERFACE ioctl hoặc bởi
    đóng bộ mô tả tập tin. Thời gian sửa đổi tập tin không được cập nhật
    bởi yêu cầu này.

USBDEVFS_CONNECTINFO
    Cho biết thiết bị có tốc độ thấp hay không. Tham số ioctl trỏ đến một
    cấu trúc như thế này::

cấu trúc usbdevfs_connectinfo {
		unsigned int devnum;
		char không dấu chậm;
	};

Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

*Bạn không thể biết liệu thiết bị "không chậm" có được kết nối ở mức cao hay không
    tốc độ (480 MBit/giây) hoặc tốc độ tối đa (12 MBit/giây).* Bạn nên
    biết giá trị devnum rồi đó là giá trị DDD của file thiết bị
    tên.

USBDEVFS_GET_SPEED
    Trả về tốc độ của thiết bị. Tốc độ được trả về dưới dạng
    giá trị số theo enum usb_device_speed

Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

USBDEVFS_GETDRIVER
    Trả về tên của trình điều khiển kernel được liên kết với một giao diện nhất định (một
    chuỗi). Tham số là một con trỏ tới cấu trúc này, đó là
    đã sửa đổi::

cấu trúc usbdevfs_getdriver {
		giao diện int không dấu;
		trình điều khiển char [USBDEVFS_MAXDRIVERNAME + 1];
	};

Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

USBDEVFS_IOCTL
    Chuyển yêu cầu từ không gian người dùng tới trình điều khiển hạt nhân có
    một mục ioctl trong ZZ0000ZZ mà nó đã đăng ký::

cấu trúc usbdevfs_ioctl {
		int nếu không;
		int ioctl_code;
		void *dữ liệu;
	};

/* lệnh gọi chế độ người dùng trông như thế này.
	 * 'request' trở thành tham số driver->ioctl() 'code'.
	 * kích thước của 'param' được mã hóa trong 'request' và dữ liệu đó
	 * được sao chép vào hoặc từ tham số driver->ioctl() 'buf'.
	 */
	int tĩnh
	usbdev_ioctl (int fd, int ifno, yêu cầu chưa được ký, void *param)
	{
		trình bao bọc cấu trúc usbdevfs_ioctl;

Wrapper.ifno = ifno;
		bao bọc.ioctl_code = yêu cầu;
		Wrapper.data = param;

trả về ioctl (fd, USBDEVFS_IOCTL, &wrapper);
	}

Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

Yêu cầu này cho phép trình điều khiển kernel nói chuyện với mã chế độ người dùng thông qua
    hoạt động của hệ thống tập tin ngay cả khi chúng không tạo ra một ký tự hoặc
    chặn thiết bị đặc biệt. Nó cũng được sử dụng để làm những việc như hỏi
    thiết bị nên sử dụng tập tin đặc biệt nào của thiết bị. Hai được xác định trước
    ioctls được sử dụng để ngắt kết nối và kết nối lại trình điều khiển hạt nhân, do đó
    mã chế độ người dùng hoàn toàn có thể quản lý việc liên kết và cấu hình của
    thiết bị.

USBDEVFS_RELEASEINTERFACE
    Điều này được sử dụng để giải phóng các usbf xác nhận quyền sở hữu được thực hiện trên giao diện
    ngầm hoặc do lệnh gọi USBDEVFS_CLAIMINTERFACE, trước
    bộ mô tả tập tin đã bị đóng. Tham số ioctl là một số nguyên chứa
    số lượng giao diện (bInterfaceNumber từ bộ mô tả); Tập tin
    thời gian sửa đổi không được cập nhật theo yêu cầu này.

    .. warning::

*Không có kiểm tra bảo mật nào được thực hiện để đảm bảo rằng nhiệm vụ được thực hiện
	yêu cầu bồi thường là yêu cầu phát hành nó. Điều này có nghĩa là người dùng
	trình điều khiển chế độ có thể can thiệp vào những trình điều khiển khác.*

USBDEVFS_RESETEP
    Đặt lại giá trị chuyển đổi dữ liệu cho điểm cuối (hàng loạt hoặc ngắt) thành
    DATA0. Tham số ioctl là số điểm cuối nguyên (1 đến 15,
    như được xác định trong bộ mô tả điểm cuối), có thêm USB_DIR_IN
    nếu điểm cuối của thiết bị gửi dữ liệu đến máy chủ.

    .. Warning::

ZZ0000ZZ sử dụng
	điều đó thường có nghĩa là thiết bị và trình điều khiển sẽ mất nút chuyển đổi
	đồng bộ hóa. Nếu bạn thực sự bị mất đồng bộ hóa, có thể bạn
	cần bắt tay hoàn toàn với thiết bị, sử dụng yêu cầu
	như CLEAR_HALT hoặc SET_INTERFACE.

USBDEVFS_DROP_PRIVILEGES
    Điều này được sử dụng để từ bỏ khả năng thực hiện một số hoạt động nhất định
    được coi là đặc quyền trên bộ mô tả tệp usbfs.
    Điều này bao gồm việc xác nhận quyền sở hữu các giao diện tùy ý, đặt lại thiết bị trên
    hiện có các giao diện được xác nhận quyền sở hữu từ những người dùng khác và
    phát hành cuộc gọi USBDEVFS_IOCTL. Tham số ioctl là mặt nạ 32 bit
    trong số các giao diện mà người dùng được phép yêu cầu trên bộ mô tả tệp này.
    Bạn có thể phát hành ioctl này nhiều lần để thu hẹp mặt nạ nói trên.

Hỗ trợ I/O đồng bộ
~~~~~~~~~~~~~~~~~~~~~~~

Các yêu cầu đồng bộ liên quan đến việc chặn kernel cho đến chế độ người dùng
yêu cầu hoàn tất, bằng cách hoàn thành thành công hoặc bằng cách báo cáo
lỗi. Trong hầu hết các trường hợp, đây là cách đơn giản nhất để sử dụng usbfs, mặc dù
đã lưu ý ở trên, nó ngăn cản việc thực hiện I/O tới nhiều điểm cuối tại
một thời gian.

USBDEVFS_BULK
    Đưa ra yêu cầu đọc hoặc ghi hàng loạt cho thiết bị. ioctl
    tham số là một con trỏ tới cấu trúc này::

cấu trúc usbdevfs_bulktransfer {
		unsign int ep;
		int len ​​không dấu;
		hết thời gian chờ int; /* tính bằng mili giây */
		void *dữ liệu;
	};

Giá trị ZZ0000ZZ xác định số điểm cuối hàng loạt (1 đến 15, như
    được xác định trong bộ mô tả điểm cuối), được che dấu bằng USB_DIR_IN khi
    đề cập đến điểm cuối gửi dữ liệu đến máy chủ từ
    thiết bị. Độ dài của bộ đệm dữ liệu được xác định bởi ZZ0001ZZ; Gần đây
    hạt nhân hỗ trợ các yêu cầu lên tới khoảng 128KByte. *FIXME nói cách đọc
    độ dài được trả về và cách xử lý các lần đọc ngắn.*.

USBDEVFS_CLEAR_HALT
    Xóa việc tạm dừng điểm cuối (trạng thái dừng) và đặt lại chuyển đổi điểm cuối. Đây là
    chỉ có ý nghĩa đối với các điểm cuối số lượng lớn hoặc gián đoạn. tham số ioctl
    là số điểm cuối nguyên (1 đến 15, như được xác định trong điểm cuối
    mô tả), được che bằng USB_DIR_IN khi đề cập đến điểm cuối
    gửi dữ liệu đến máy chủ từ thiết bị.

Sử dụng tính năng này trên các điểm cuối số lượng lớn hoặc bị gián đoạn đã bị đình trệ,
    trả lại trạng thái ZZ0000ZZ cho yêu cầu truyền dữ liệu. Không phát hành
    yêu cầu điều khiển một cách trực tiếp, vì điều đó có thể làm mất hiệu lực của máy chủ
    bản ghi chuyển đổi dữ liệu.

USBDEVFS_CONTROL
    Đưa ra yêu cầu điều khiển cho thiết bị. Các điểm tham số ioctl
    đến một cấu trúc như thế này::

cấu trúc usbdevfs_ctrltransfer {
		__u8 bRequestType;
		__u8 bYêu cầu;
		__u16 wGiá trị;
		__u16 wIndex;
		__u16 wChiều dài;
		__u32 hết thời gian chờ;  /* tính bằng mili giây */
		void *dữ liệu;
	};

Tám byte đầu tiên của cấu trúc này là nội dung của
    Gói SETUP được gửi đến thiết bị; xem thông số kỹ thuật USB 2.0
    để biết chi tiết. Giá trị bRequestType được tạo bằng cách kết hợp một
    Giá trị ZZ0000ZZ, giá trị ZZ0001ZZ và ZZ0002ZZ
    giá trị (từ ZZ0003ZZ). Nếu wLength khác 0, nó mô tả
    độ dài của bộ đệm dữ liệu được ghi vào thiết bị
    (USB_DIR_OUT) hoặc đọc từ thiết bị (USB_DIR_IN).

Tại thời điểm viết bài này, bạn không thể chuyển nhiều hơn 4 KByte dữ liệu sang hoặc
    từ một thiết bị; usbfs có giới hạn và một số trình điều khiển bộ điều khiển máy chủ
    có một giới hạn. (Đó thường không phải là vấn đề.) ZZ0000ZZ không thể nào
    để nói rằng việc nhận lại một đoạn đọc ngắn từ thiết bị là không ổn.

USBDEVFS_RESET
    Thiết lập lại thiết bị cấp USB. Tham số ioctl bị bỏ qua. Sau
    thiết lập lại, điều này sẽ khởi động lại tất cả các giao diện thiết bị. Sửa đổi tập tin
    thời gian không được cập nhật bởi yêu cầu này.

.. warning::

	*Avoid using this call* until some usbcore bugs get fixed, since
	it does not fully synchronize device, interface, and driver (not
	just usbfs) state.

USBDEVFS_SETINTERFACE
    Đặt cài đặt thay thế cho một giao diện. Tham số ioctl là
    một con trỏ tới một cấu trúc như thế này::

cấu trúc usbdevfs_setinterface {
		giao diện int không dấu;
		cài đặt int không dấu;
	};

Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

Các thành viên cấu trúc đó đến từ một số bộ mô tả giao diện áp dụng cho
    cấu hình hiện tại. Số giao diện là
    b Giá trị số giao diện và số cài đặt thay thế là
    bGiá trị cài đặt thay thế. (Điều này đặt lại từng điểm cuối trong
    giao diện.)

USBDEVFS_SETCONFIGURATION
    Đưa ra lệnh gọi ZZ0000ZZ cho
    thiết bị. Tham số là một số nguyên chứa số của một
    cấu hình (bConfigurationValue từ bộ mô tả). Tập tin
    thời gian sửa đổi không được cập nhật theo yêu cầu này.

.. warning::

	*Avoid using this call* until some usbcore bugs get fixed, since
	it does not fully synchronize device, interface, and driver (not
	just usbfs) state.

Hỗ trợ I/O không đồng bộ
~~~~~~~~~~~~~~~~~~~~~~~~

Như đã đề cập ở trên, có những tình huống có thể quan trọng để
bắt đầu các hoạt động đồng thời từ mã chế độ người dùng. Điều này đặc biệt
quan trọng đối với việc truyền định kỳ (ngắt và đẳng thời), nhưng nó có thể
cũng có thể được sử dụng cho các loại yêu cầu USB khác. Trong những trường hợp như vậy,
các yêu cầu không đồng bộ được mô tả ở đây là cần thiết. Thay vì
gửi một yêu cầu và có khối kernel cho đến khi nó hoàn thành,
việc chặn là riêng biệt.

Các yêu cầu này được đóng gói thành một cấu trúc giống với URB được sử dụng
bởi trình điều khiển thiết bị hạt nhân. (Xin lỗi, không hỗ trợ I/O Async POSIX ở đây.) Nó
xác định loại điểm cuối (ZZ0000ZZ), điểm cuối
(số, được che bằng USB_DIR_IN nếu thích hợp), bộ đệm và độ dài,
và phân phát giá trị "ngữ cảnh" của người dùng để xác định duy nhất từng yêu cầu.
(Nó thường là một con trỏ tới dữ liệu theo yêu cầu.) Cờ có thể sửa đổi các yêu cầu
(không nhiều như được hỗ trợ cho trình điều khiển kernel).

Mỗi yêu cầu có thể chỉ định số tín hiệu thời gian thực (giữa SIGRTMIN và
SIGRTMAX, bao gồm) để yêu cầu gửi tín hiệu khi có yêu cầu
hoàn thành.

Khi usbfs trả về các urbs này, giá trị trạng thái sẽ được cập nhật và
bộ đệm có thể đã được sửa đổi. Ngoại trừ việc truyền đẳng thời,
Real_length được cập nhật để cho biết số lượng byte đã được truyền; nếu
Cờ USBDEVFS_URB_DISABLE_SPD được đặt ("gói ngắn không được chấp nhận"), nếu
số byte được đọc ít hơn số byte được yêu cầu thì bạn nhận được báo cáo lỗi ::

cấu trúc usbdevfs_iso_packet_desc {
	    chiều dài int không dấu;
	    unsigned intactual_length;
	    trạng thái int không dấu;
    };

cấu trúc usbdevfs_urb {
	    loại char không dấu;
	    điểm cuối char không dấu;
	    trạng thái int;
	    cờ int không dấu;
	    void *bộ đệm;
	    int buffer_length;
	    int thực tế_length;
	    int start_frame;
	    int number_of_packets;
	    int error_count;
	    dấu hiệu int không dấu;
	    void * bối cảnh người dùng;
	    cấu trúc usbdevfs_iso_packet_desc iso_frame_desc[];
    };

Đối với những yêu cầu không đồng bộ này, thời gian sửa đổi tệp phản ánh
khi yêu cầu được bắt đầu. Điều này trái ngược với việc sử dụng chúng với
các yêu cầu đồng bộ, nơi nó phản ánh thời điểm các yêu cầu hoàn tất.

USBDEVFS_DISCARDURB
    ZZ0000ZZ Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

USBDEVFS_DISCSIGNAL
    ZZ0000ZZ Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

USBDEVFS_REAPURB
    ZZ0000ZZ Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

USBDEVFS_REAPURBNDELAY
    ZZ0000ZZ Thời gian sửa đổi tệp không được cập nhật theo yêu cầu này.

USBDEVFS_SUBMITURB
    ZZ0000ZZ

Các thiết bị USB
===============

Các thiết bị USB hiện được xuất qua debugfs:

- ZZ0000ZZ... một file văn bản hiển thị từng USB
   các thiết bị được biết đến trong kernel và bộ mô tả cấu hình của chúng.
   Bạn cũng có thể thăm dò ý kiến() này để tìm hiểu về các thiết bị mới.

/sys/kernel/gỡ lỗi/usb/thiết bị
-----------------------------

Tệp này tiện dụng cho các công cụ xem trạng thái ở chế độ người dùng, có thể quét
định dạng văn bản và bỏ qua hầu hết nó. Trạng thái thiết bị chi tiết hơn
(bao gồm trạng thái lớp và nhà cung cấp) có sẵn từ thiết bị cụ thể
tập tin. Để biết thông tin về định dạng hiện tại của tệp này, hãy xem bên dưới.

Tệp này, kết hợp với lệnh gọi hệ thống poll(), cũng có thể được sử dụng
để phát hiện khi thiết bị được thêm hoặc xóa ::

int fd;
    cấu trúc thăm dò ý kiến ​​pfd;

fd = open("/sys/kernel/debug/usb/devices", O_RDONLY);
    pfd = {fd, POLLIN, 0 };
    cho (;;) {
	/* Lần đầu tiên thực hiện cuộc gọi này sẽ quay trở lại ngay lập tức. */
	thăm dò ý kiến(&pfd, 1, -1);

/* Để xem những gì đã thay đổi, hãy so sánh tệp trước đó và hiện tại
	   nội dung hoặc quét hệ thống tập tin.  (Quét chính xác hơn.) */
    }

Lưu ý rằng hành vi này nhằm mục đích sử dụng cho mục đích cung cấp thông tin và
mục đích gỡ lỗi. Sẽ thích hợp hơn nếu sử dụng các chương trình như
udev hoặc HAL để khởi tạo thiết bị hoặc khởi động chương trình trợ giúp chế độ người dùng,
chẳng hạn.

Trong tệp này, đầu ra của mỗi thiết bị có nhiều dòng đầu ra ASCII.

Tôi đã cố ý tạo nó thành ASCII thay vì nhị phân để ai đó
có thể lấy được một số dữ liệu hữu ích từ nó mà không cần sử dụng
chương trình phụ trợ.  Tuy nhiên, với một chương trình phụ trợ, số
trong 4 cột đầu tiên của mỗi dòng ZZ0000ZZ (thông tin cấu trúc liên kết:
Lev, Prnt, Port, Cnt) có thể được sử dụng để xây dựng sơ đồ cấu trúc liên kết USB.

Mỗi dòng được gắn thẻ ID một ký tự cho dòng đó ::

T = Cấu trúc liên kết (v.v.)
	B = Băng thông (chỉ áp dụng cho bộ điều khiển máy chủ USB,
	ảo hóa như các trung tâm gốc)
	D = Thông tin mô tả thiết bị.
	P = Thông tin ID sản phẩm. (từ phần mô tả thiết bị, nhưng chúng không vừa
	cùng nhau trên một dòng)
	S = Bộ mô tả chuỗi.
	C = Thông tin mô tả cấu hình. (* = cấu hình hoạt động)
	I = Thông tin mô tả giao diện.
	E = Thông tin mô tả điểm cuối.

/sys/kernel/debug/usb/định dạng đầu ra của thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Truyền thuyết::
  d = số thập phân (có thể có dấu cách ở đầu hoặc số 0)
  x = số thập lục phân (có thể có khoảng trắng ở đầu hoặc số 0)
  s = chuỗi



Thông tin cấu trúc liên kết
^^^^^^^^^^^^^

::

T: Bus=dd Lev=dd Prnt=dd Cổng=dd Cnt=dd Dev#=ddd Spd=dddd MxCh=dd
	ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ |__MaxChildren
	ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ |        |__Tốc độ thiết bị tính bằng Mbps
	ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ |__Số thiết bị
	ZZ0011ZZ ZZ0012ZZ |       |__Số lượng thiết bị ở cấp độ này
	ZZ0014ZZ ZZ0015ZZ |__Đầu nối/Cổng trên Parent cho thiết bị này
	ZZ0016ZZ |      |__Số thiết bị gốc
	ZZ0018ZZ |__Cấp độ cấu trúc liên kết cho xe buýt này
	|   |__Số xe buýt
	|__Thẻ thông tin cấu trúc liên kết

Tốc độ có thể là:

======= ===========================================================
	1,5 Mbit/s cho USB tốc độ thấp
	12 Mbit/s cho tốc độ tối đa USB
	480 Mbit/s cho USB tốc độ cao (được thêm cho USB 2.0)
	5000 Mbit/s cho SuperSpeed USB (được thêm cho USB 3.0)
	======= ===========================================================

Vì những lý do bị thất lạc theo thời gian, số Cổng luôn là
quá thấp bằng 1. Ví dụ: một thiết bị cắm vào cổng 4 sẽ
xuất hiện với ZZ0000ZZ.

Thông tin băng thông
^^^^^^^^^^^^^^

::

B: Alloc=ddd/ddd us (xx%), #Int=ddd, #Iso=ddd
	ZZ0000ZZ |         |__Số lượng yêu cầu đẳng thời gian
	ZZ0002ZZ |__Số lượng yêu cầu ngắt
	|   |__Tổng băng thông được phân bổ cho xe buýt này
	|__Thẻ thông tin băng thông

Phân bổ băng thông là xấp xỉ bao nhiêu khung hình
(mili giây) đang được sử dụng.  Nó chỉ phản ánh các khoản chuyển tiền định kỳ, mà
là những lần chuyển duy nhất có băng thông dự trữ.  Kiểm soát và số lượng lớn
truyền tải sử dụng tất cả băng thông khác, bao gồm cả băng thông dành riêng
không được sử dụng để truyền (chẳng hạn như đối với các gói ngắn).

Tỷ lệ phần trăm là bao nhiêu băng thông "dành riêng" được lên lịch bởi
những lần chuyển giao đó.  Đối với xe buýt tốc độ thấp hoặc tốc độ tối đa (đại khái là "USB 1.1"),
90% băng thông bus được dành riêng.  Đối với xe buýt tốc độ cao (lỏng lẻo,
"USB 2.0") 80% được bảo lưu.


Thông tin mô tả thiết bị và thông tin ID sản phẩm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

D: Ver=x.xx Cls=xx(s) Sub=xx Prot=xx MxPS=dd #Cfgs=dd
	P: Nhà cung cấp=xxxx ProdID=xxxx Rev=xx.xx

Ở đâu::

D: Ver=x.xx Cls=xx(sssss) Sub=xx Prot=xx MxPS=dd #Cfgs=dd
	ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ |__NumberConfigurations
	ZZ0003ZZ ZZ0004ZZ |       |__MaxPacketSize của điểm cuối mặc định
	ZZ0006ZZ ZZ0007ZZ |__Giao thức thiết bị
	ZZ0008ZZ |             |__DeviceSubClass
	ZZ0010ZZ |__Lớp thiết bị
	|   |__Phiên bản thiết bị USB
	|__ Tag thông tin thiết bị #1

Ở đâu::

P: Nhà cung cấp=xxxx ProdID=xxxx Rev=xx.xx
	ZZ0000ZZ |           |__Số sửa đổi sản phẩm
	ZZ0002ZZ |__Mã ID sản phẩm
	|   |__Mã ID nhà cung cấp
	|__ Tag thông tin thiết bị #2


Thông tin mô tả chuỗi
^^^^^^^^^^^^^^^^^^^^^^
::

S: Nhà sản xuất=ssss
	|   |__Nhà sản xuất thiết bị này được đọc từ thiết bị.
	|      Đối với trình điều khiển bộ điều khiển máy chủ USB (trung tâm gốc ảo), điều này có thể
	|      bị bỏ qua hoặc (đối với trình điều khiển mới hơn) sẽ xác định kernel
	|      phiên bản và trình điều khiển cung cấp mô phỏng trung tâm này.
	|__Thẻ thông tin chuỗi

S: Sản phẩm=ssss
	|   |__Mô tả sản phẩm của thiết bị này được đọc từ thiết bị.
	|      Đối với trình điều khiển bộ điều khiển máy chủ USB cũ hơn (trung tâm gốc ảo), điều này
	|      chỉ ra người lái xe; đối với những cái mới hơn, đó là một sản phẩm (và nhà cung cấp)
	|      mô tả thường đến từ cơ sở dữ liệu ID PCI của kernel.
	|__Thẻ thông tin chuỗi

S: Số sê-ri=ssss
	|   |__Số sê-ri của thiết bị này được đọc từ thiết bị.
	|      Đối với trình điều khiển bộ điều khiển máy chủ USB (trung tâm gốc ảo), đây là
	|      một số ID duy nhất, thường là ID bus (địa chỉ hoặc tên khe cắm)
	|      không thể chia sẻ với bất kỳ thiết bị nào khác.
	|__Thẻ thông tin chuỗi



Thông tin mô tả cấu hình
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

C:* #Ifs=dd Cfg#=dd Atr=xx MPwr=dddmA
	ZZ0000ZZ ZZ0001ZZ |      |__Công suất tối đa tính bằng mA
	ZZ0003ZZ ZZ0004ZZ |__Thuộc tính
	ZZ0005ZZ |       |__ConfigurationNumber
	ZZ0007ZZ |__SốGiao Diện
	ZZ0008ZZ__ "*" cho biết cấu hình đang hoạt động (các cấu hình khác là " ")
	|__Thẻ thông tin cấu hình

Thiết bị USB có thể có nhiều cấu hình, mỗi cấu hình hoạt động
khá khác biệt.  Ví dụ: cấu hình hỗ trợ bus
có thể có khả năng kém hơn nhiều so với máy tự cấp nguồn.  Chỉ
một cấu hình thiết bị có thể hoạt động tại một thời điểm; hầu hết các thiết bị
chỉ có một cấu hình.

Mỗi cấu hình bao gồm một hoặc nhiều giao diện.  Mỗi
giao diện phục vụ một "chức năng" riêng biệt, thường bị ràng buộc
sang trình điều khiển thiết bị USB khác.  Một ví dụ phổ biến là USB
loa có giao diện âm thanh để phát lại và giao diện HID
để sử dụng với điều khiển âm lượng phần mềm.

Thông tin mô tả giao diện (có thể nhiều cho mỗi Cấu hình)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
::

I:* If#=dd Alt=dd #EPs=dd Cls=xx(sssss) Sub=xx Prot=xx Driver=ssss
	ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ |__Tên người lái xe
	ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ hoặc "(không có)"
	ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ |      |__Giao thức giao diện
	ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ |__Giao diệnSubClass
	ZZ0015ZZ ZZ0016ZZ |       |__Giao diện
	ZZ0018ZZ ZZ0019ZZ |__Số điểm cuối
	ZZ0020ZZ |      |__Số cài đặt thay thế
	ZZ0022ZZ |__Số giao diện
	ZZ0023ZZ__ "*" biểu thị cài đặt thay thế đang hoạt động (các cài đặt khác là " ")
	|__Thẻ thông tin giao diện

Một giao diện nhất định có thể có một hoặc nhiều cài đặt "thay thế".
Ví dụ: cài đặt mặc định có thể không sử dụng nhiều hơn một
lượng băng thông định kỳ.  Để sử dụng các phân số có ý nghĩa
về băng thông bus, trình điều khiển phải chọn cài đặt thay thế không mặc định.

Mỗi lần chỉ có một cài đặt cho giao diện có thể hoạt động và
mỗi lần chỉ có một trình điều khiển có thể liên kết với một giao diện.  Hầu hết các thiết bị
chỉ có một cài đặt thay thế cho mỗi giao diện.


Thông tin mô tả điểm cuối (có thể nhiều trên mỗi Giao diện)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

::

E: Ad=xx(s) Atr=xx(ssss) MxPS=dddd Ivl=dddss
	ZZ0000ZZ ZZ0001ZZ |__Khoảng thời gian (tối đa) giữa các lần chuyển
	ZZ0002ZZ |            |__EndpointMaxPacketSize
	ZZ0004ZZ |__Thuộc tính(EndpointType)
	|   |__EndpointAddress(I=In,O=Out)
	|__Thẻ thông tin điểm cuối

Khoảng thời gian khác 0 đối với tất cả các chu kỳ (ngắt hoặc đẳng thời)
điểm cuối.  Đối với các điểm cuối tốc độ cao, khoảng thời gian chuyển giao có thể là
được đo bằng micro giây thay vì mili giây.

Đối với các điểm cuối định kỳ tốc độ cao, ZZ0000ZZ phản ánh
kích thước truyền dữ liệu trên mỗi microframe.  Đối với "băng thông cao"
điểm cuối, có thể phản ánh hai hoặc ba gói (tối đa
3KByte cứ sau 125 usec) cho mỗi điểm cuối.

Với ngăn xếp Linux-USB, việc đặt trước băng thông định kỳ sử dụng
khoảng thời gian truyền và kích thước do URB cung cấp, có thể ít hơn
hơn những gì được tìm thấy trong bộ mô tả điểm cuối.

Ví dụ sử dụng
~~~~~~~~~~~~~~

Nếu người dùng hoặc tập lệnh chỉ quan tâm đến thông tin cấu trúc liên kết, ví dụ:
ví dụ: sử dụng cái gì đó như ZZ0000ZZ
chỉ dành cho các dòng Topology.  Một lệnh như
ZZ0001ZZ có thể được sử dụng để liệt kê
chỉ những dòng bắt đầu bằng các ký tự trong ngoặc vuông,
trong đó các ký tự hợp lệ là TDPCIE.  Với khả năng hơn một chút
tập lệnh, nó có thể hiển thị bất kỳ dòng nào được chọn (ví dụ: chỉ T, D,
và dòng P) và thay đổi định dạng đầu ra của chúng.  (ZZ0002ZZ
Kịch bản Perl là sự khởi đầu của ý tưởng này.  Nó sẽ chỉ liệt kê
các dòng đã chọn [được chọn từ TBDPSCIE] hoặc các dòng "Tất cả" từ
ZZ0003ZZ.)

Các dòng cấu trúc liên kết có thể được sử dụng để tạo ra một đồ họa/hình ảnh
của các thiết bị USB trên trung tâm gốc của hệ thống.  (Xem thêm bên dưới
về cách thực hiện việc này.)

Các dòng Giao diện có thể được sử dụng để xác định trình điều khiển là gì
đang được sử dụng cho từng thiết bị và cài đặt thay thế nào được kích hoạt.

Các dòng Cấu hình có thể được sử dụng để liệt kê công suất tối đa
(tính bằng milliamp) mà thiết bị USB của hệ thống đang sử dụng.
Ví dụ: ZZ0000ZZ.


Đây là một ví dụ, từ một hệ thống có trung tâm gốc UHCI,
một hub bên ngoài được kết nối với hub gốc, một con chuột và
một bộ chuyển đổi nối tiếp được kết nối với hub bên ngoài.

::

T: Bus=00 Lev=00 Prnt=00 Cổng=00 Cnt=00 Dev#= 1 Spd=12 MxCh= 2
	B: Phân bổ= 28/900 us ( 3%), #Int= 2, #Iso= 0
	D: Ver= 1,00 Cls=09(hub ) Sub=00 Prot=00 MxPS= 8 #Cfgs= 1
	P: Nhà cung cấp=0000 ProdID=0000 Rev= 0,00
	S: Sản phẩm=USB UHCI Root Hub
	S: Số sê-ri=dce0
	C:* #Ifs= 1 Cfg#= 1 Atr=40 MxPwr= 0mA
	I: If#= 0 Alt= 0 #EPs= 1 Cls=09(hub ) Sub=00 Prot=00 Driver=hub
	E: Ad=81(I) Atr=03(Int.) MxPS= 8 Ivl=255ms

T: Bus=00 Lev=01 Prnt=01 Cổng=00 Cnt=01 Dev#= 2 Spd=12 MxCh= 4
	D: Ver= 1,00 Cls=09(hub ) Sub=00 Prot=00 MxPS= 8 #Cfgs= 1
	P: Nhà cung cấp=0451 ProdID=1446 Rev= 1,00
	C:* #Ifs= 1 Cfg#= 1 Atr=e0 MxPwr=100mA
	I: If#= 0 Alt= 0 #EPs= 1 Cls=09(hub ) Sub=00 Prot=00 Driver=hub
	E: Ad=81(I) Atr=03(Int.) MxPS= 1 Ivl=255ms

T: Bus=00 Lev=02 Prnt=02 Cổng=00 Cnt=01 Dev#= 3 Spd=1,5 MxCh= 0
	D: Ver= 1,00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS= 8 #Cfgs= 1
	P: Nhà cung cấp=04b4 ProdID=0001 Rev= 0,00
	C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=100mA
	I: If#= 0 Alt= 0 #EPs= 1 Cls=03(HID ) Sub=01 Prot=02 Trình điều khiển=chuột
	E: Ad=81(I) Atr=03(Int.) MxPS= 3 Ivl= 10ms

T: Bus=00 Lev=02 Prnt=02 Cổng=02 Cnt=02 Dev#= 4 Spd=12 MxCh= 0
	D: Ver= 1,00 Cls=00(>ifc ) Sub=00 Prot=00 MxPS= 8 #Cfgs= 1
	P: Nhà cung cấp=0565 ProdID=0001 Rev= 1,08
	S: Nhà sản xuất=Peracom Networks, Inc.
	S: Sản phẩm=Bộ chuyển đổi Peracom USB sang nối tiếp
	C:* #Ifs= 1 Cfg#= 1 Atr=a0 MxPwr=100mA
	I: If#= 0 Alt= 0 #EPs= 3 Cls=00(>ifc ) Sub=00 Prot=00 Driver=serial
	E: Quảng cáo=81(I) Atr=02(Số lượng lớn) MxPS= 64 Ivl= 16 mili giây
	E: Quảng cáo=01(O) Atr=02(Số lượng lớn) MxPS= 16 Ivl= 16 mili giây
	E: Ad=82(I) Atr=03(Int.) MxPS= 8 Ivl= 8ms


Chỉ chọn các dòng ZZ0000ZZ và ZZ0001ZZ từ đây (ví dụ: bằng cách sử dụng
ZZ0002ZZ), chúng tôi có

::

T: Bus=00 Lev=00 Prnt=00 Cổng=00 Cnt=00 Dev#= 1 Spd=12 MxCh= 2
	T: Bus=00 Lev=01 Prnt=01 Cổng=00 Cnt=01 Dev#= 2 Spd=12 MxCh= 4
	I: If#= 0 Alt= 0 #EPs= 1 Cls=09(hub ) Sub=00 Prot=00 Driver=hub
	T: Bus=00 Lev=02 Prnt=02 Cổng=00 Cnt=01 Dev#= 3 Spd=1,5 MxCh= 0
	I: If#= 0 Alt= 0 #EPs= 1 Cls=03(HID ) Sub=01 Prot=02 Trình điều khiển=chuột
	T: Bus=00 Lev=02 Prnt=02 Cổng=02 Cnt=02 Dev#= 4 Spd=12 MxCh= 0
	I: If#= 0 Alt= 0 #EPs= 3 Cls=00(>ifc ) Sub=00 Prot=00 Driver=serial


Về mặt vật lý, nó trông giống như (hoặc có thể được chuyển đổi thành)::

+-------------------+
                      ZZ0000ZZ Dev# = 1
                      +-------------------+ (nn) là Mbps.
    Cấp 0 ZZ0001ZZ CN.1 |   [CN = số đầu nối/cổng]
                      +-------------------+
                          /
                         /
            +--------------+
  Cấp 1 ZZ0002ZZ
            +--------------+
            ZZ0003ZZCN.1 ZZ0004ZZCN.3 |
            +--------------+
                \ \____________________
                 \_____ \
                       \ \
               +-------------------+ +----------------------+
  Cấp 2 ZZ0005ZZ ZZ0006ZZ
               +-------------------+ +----------------------+



Hoặc, trong một cấu trúc giống cây hơn (các cổng [Kết nối] không có
các kết nối có thể bị bỏ qua)::

PC: Dev# 1, hub gốc, 2 cổng, 12 Mbps
	|_ CN.0: Dev# 2, hub, 4 cổng, 12 Mbps
	     |_ CN.0: Dev #3, chuột, 1,5 Mbps
	     |_ CN.1:
	     |_ CN.2: Dev #4, nối tiếp, 12 Mbps
	     |_ CN.3:
	|_ CN.1:
