.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget_serial.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Trình điều khiển nối tiếp tiện ích Linux v2.0
=============================================

20/11/2004

(cập nhật ngày 8 tháng 5 năm 2008 cho v2.3)


Giấy phép và Tuyên bố từ chối trách nhiệm
----------------------
Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc
sửa đổi nó theo các điều khoản của Giấy phép Công cộng GNU như
được xuất bản bởi Tổ chức Phần mềm Tự do; hoặc phiên bản 2 của
Giấy phép hoặc (tùy theo lựa chọn của bạn) bất kỳ phiên bản nào mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
Giấy phép Công cộng GNU để biết thêm chi tiết.

Bạn hẳn đã nhận được một bản sao của GNU General Public
Giấy phép cùng với chương trình này; nếu không, hãy viết thư cho Free
Software Foundation, Inc., 59 Temple Place, Suite 330, Boston,
MA 02111-1307 USA.

Tài liệu này và bản thân trình điều khiển nối tiếp của tiện ích là
Bản quyền (C) 2004 của Al Borchers (alborchers@steinerpoint.com).

Nếu bạn có thắc mắc, vấn đề hoặc đề xuất cho trình điều khiển này
vui lòng liên hệ với Al Borchers tại alborchers@steinerpoint.com.


Điều kiện tiên quyết
-------------
Các phiên bản của trình điều khiển nối tiếp tiện ích có sẵn cho
2.4 nhân Linux, nhưng tài liệu này giả sử bạn đang sử dụng
phiên bản 2.3 trở lên của trình điều khiển nối tiếp tiện ích trong phiên bản 2.6
Hạt nhân Linux.

Tài liệu này giả định rằng bạn đã quen thuộc với Linux và
Windows và biết cách cấu hình, xây dựng nhân Linux, chạy
tiện ích tiêu chuẩn, sử dụng minicom và HyperTerminal, và làm việc với
USB và các thiết bị nối tiếp.  Nó cũng giả sử bạn định cấu hình Linux
tiện ích và trình điều khiển usb dưới dạng mô-đun.

Với phiên bản 2.3 của trình điều khiển, các nút thiết bị chính và phụ được
không còn được xác định tĩnh nữa.  Hệ thống dựa trên Linux của bạn nên gắn kết
sysfs trong /sys và sử dụng "mdev" (trong Busybox) hoặc "udev" để tạo
Các nút /dev khớp với các tệp sysfs /sys/class/tty.



Tổng quan
--------
Trình điều khiển nối tiếp tiện ích là trình điều khiển tiện ích Linux USB, thiết bị USB
tài xế phụ.  Nó chạy trên hệ thống Linux có phía thiết bị USB
phần cứng; ví dụ: PDA, hệ thống Linux nhúng hoặc PC
với thẻ phát triển USB.

Trình điều khiển nối tiếp tiện ích trao đổi USB với trình điều khiển CDC ACM
hoặc trình điều khiển nối tiếp USB chung chạy trên PC chủ ::

Máy chủ
   --------------------------------------
  ZZ0000ZZ
  ZZ0001ZZ hoặc ZZ0002ZZ USB
  ZZ0003ZZ Chung USB ZZ0004ZZ--------
  ZZ0005ZZ Nối tiếp ZZ0006ZZ |
  ZZ0007ZZ |
   -------------------------------------- |
                                                  |
                                                  |
                                                  |
   Tiện ích |
   -------------------------------------- |
  ZZ0008ZZ |
  ZZ0009ZZ Tiện ích ZZ0010ZZ |
  ZZ0011ZZ Nối tiếp ZZ0012ZZ--------
  Trình điều khiển ZZ0013ZZ ZZ0014ZZ
  ZZ0015ZZ
   --------------------------------------

Trên hệ thống Linux phía thiết bị, trình điều khiển nối tiếp tiện ích trông
giống như một thiết bị nối tiếp.

Trên hệ thống phía máy chủ, thiết bị nối tiếp tiện ích trông giống như một
Thiết bị lớp tuân thủ CDC ACM hoặc thiết bị đơn giản dành riêng cho nhà cung cấp
với các điểm cuối vào và ra hàng loạt và nó được xử lý tương tự
đến các thiết bị nối tiếp khác.

Trình điều khiển phía máy chủ có thể là bất kỳ trình điều khiển tương thích ACM nào
hoặc bất kỳ trình điều khiển nào có thể giao tiếp với một thiết bị có chức năng vào/ra hàng loạt đơn giản
giao diện.  Chuỗi tiện ích đã được thử nghiệm với trình điều khiển Linux ACM,
trình điều khiển Windows usbser.sys ACM và chuỗi chung Linux USB
người lái xe.

Với trình điều khiển nối tiếp tiện ích và phía máy chủ ACM hoặc chung
trình điều khiển nối tiếp đang chạy, bạn sẽ có thể giao tiếp giữa
hệ thống phía máy chủ và tiện ích như thể chúng được kết nối bởi một
cáp nối tiếp.

Trình điều khiển nối tiếp tiện ích chỉ cung cấp dữ liệu đơn giản không đáng tin cậy
giao tiếp.  Nó chưa xử lý việc kiểm soát luồng hoặc nhiều thứ khác
tính năng của các thiết bị nối tiếp thông thường.


Cài đặt Trình điều khiển Nối tiếp Tiện ích
-----------------------------------
Để sử dụng trình điều khiển nối tiếp tiện ích, bạn phải định cấu hình tiện ích Linux
hạt nhân bên cho "Hỗ trợ các tiện ích USB", cho "Thiết bị ngoại vi USB
Controller" (ví dụ: net2280) và cho "Tiện ích nối tiếp"
người lái xe.  Tất cả điều này được liệt kê trong phần "Hỗ trợ tiện ích USB" khi
cấu hình hạt nhân.  Sau đó xây dựng lại và cài đặt kernel hoặc
mô-đun.

Sau đó, bạn phải tải trình điều khiển nối tiếp tiện ích.  Để tải nó dưới dạng
Thiết bị ACM (được khuyến nghị để có khả năng tương tác), hãy làm điều này::

modprobe g_serial

Để tải nó dưới dạng thiết bị vào/ra hàng loạt dành riêng cho nhà cung cấp, hãy thực hiện việc này::

modprobe g_serial use_acm=0

Điều này cũng sẽ tự động tải thiết bị ngoại vi tiện ích cơ bản
trình điều khiển.  Việc này phải được thực hiện mỗi khi bạn khởi động lại tiện ích
bên hệ thống Linux.  Bạn có thể thêm phần này vào tập lệnh khởi động, nếu
mong muốn.

Hệ thống của bạn nên sử dụng mdev (từ busybox) hoặc udev để tạo
các nút thiết bị.  Sau khi trình điều khiển tiện ích này đã được thiết lập, bạn nên
sau đó xem nút/dev/ttyGS0::

# ls -l /dev/ttyGS0 | con mèo
  crw-rw---- 1 gốc gốc 253, 0 ngày 8 tháng 5 14:10 /dev/ttyGS0
  #

Lưu ý rằng số chính (253, ở trên) là dành riêng cho hệ thống.  Nếu
bạn cần tạo các nút/dev bằng tay, chọn đúng số để sử dụng
sẽ nằm trong tệp /sys/class/tty/ttyGS0/dev.

Khi bạn liên kết trình điều khiển tiện ích này sớm, thậm chí có thể là tĩnh,
bạn có thể muốn thiết lập một mục /etc/inittab để chạy "getty" trên đó.
Dòng /dev/ttyGS0 sẽ hoạt động giống như hầu hết mọi cổng nối tiếp khác.


Nếu nối tiếp tiện ích được tải dưới dạng thiết bị ACM, bạn sẽ muốn sử dụng
trình điều khiển Windows hoặc Linux ACM ở phía máy chủ.  Nếu tiện ích
serial được tải dưới dạng thiết bị vào/ra số lượng lớn, bạn sẽ muốn sử dụng
Trình điều khiển nối tiếp chung của Linux ở phía máy chủ.  Thực hiện theo thích hợp
hướng dẫn bên dưới để cài đặt trình điều khiển phía máy chủ.


Cài đặt Trình điều khiển Windows Host ACM
--------------------------------------
Để sử dụng trình điều khiển Windows ACM, bạn phải có "linux-cdc-acm.inf"
tập tin (được cung cấp cùng với tài liệu này) hỗ trợ tất cả các phiên bản gần đây
của Windows.

Khi trình điều khiển nối tiếp tiện ích được tải và thiết bị USB được kết nối
đến máy chủ Windows bằng cáp USB, Windows sẽ nhận ra
thiết bị nối tiếp tiện ích và yêu cầu trình điều khiển.  Yêu cầu Windows tìm
trình điều khiển trong thư mục chứa tệp "linux-cdc-acm.inf".

Ví dụ: trên Windows XP, khi thiết bị nối tiếp tiện ích lần đầu tiên
cắm vào, "Trình hướng dẫn phần cứng mới được tìm thấy" sẽ khởi động.  chọn
"Cài đặt từ danh sách hoặc vị trí cụ thể (Nâng cao)", sau đó trên
màn hình tiếp theo chọn "Bao gồm vị trí này trong tìm kiếm" và nhập
đường dẫn hoặc duyệt đến thư mục chứa tệp "linux-cdc-acm.inf".
Windows sẽ phàn nàn rằng trình điều khiển Gadget Serial chưa được thông qua
Kiểm tra Logo Windows nhưng chọn "Vẫn tiếp tục" và hoàn tất
cài đặt trình điều khiển.

Trên Windows XP, trong "Trình quản lý thiết bị" (trong "Bảng điều khiển",
"Hệ thống", "Phần cứng") mở rộng mục nhập "Cổng (COM & LPT)" và bạn
sẽ thấy "Sê-ri Tiện ích" được liệt kê làm trình điều khiển cho một trong các COM
cổng.

Để gỡ cài đặt trình điều khiển Windows XP cho "Gadget Serial", nhấp chuột phải
trên mục nhập "Sê-ri Tiện ích" trong "Trình quản lý thiết bị" và chọn
"Gỡ cài đặt".


Cài đặt trình điều khiển ACM của máy chủ Linux
------------------------------------
Để sử dụng trình điều khiển Linux ACM, bạn phải định cấu hình phía máy chủ Linux
kernel cho "Hỗ trợ USB phía máy chủ" và cho "Modem USB (CDC ACM)
hỗ trợ".

Khi trình điều khiển nối tiếp tiện ích được tải và thiết bị USB được kết nối
đến máy chủ Linux bằng cáp USB, hệ thống máy chủ sẽ nhận ra
thiết bị nối tiếp tiện ích.  Ví dụ: lệnh::

cat /sys/kernel/debug/usb/thiết bị

sẽ hiển thị một cái gì đó như thế này :::

T: Bus=01 Lev=01 Prnt=01 Cổng=01 Cnt=02 Dev#= 5 Spd=480 MxCh= 0
  D: Ver= 2,00 Cls=02(comm.) Sub=00 Prot=00 MxPS=64 #Cfgs= 1
  P: Nhà cung cấp=0525 ProdID=a4a7 Rev= 2,01
  S: Nhà sản xuất=Linux 2.6.8.1 với net2280
  S: Sản phẩm=Sê-ri tiện ích
  S: Số sê-ri=0
  C:* #Ifs= 2 Cfg#= 2 Atr=c0 MxPwr= 2mA
  I: If#= 0 Alt= 0 #EPs= 1 Cls=02(comm.) Sub=02 Prot=01 Driver=acm
  E: Ad=83(I) Atr=03(Int.) MxPS= 8 Ivl=32ms
  I: If#= 1 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=acm
  E: Quảng cáo=81(I) Atr=02(Số lượng lớn) MxPS= 512 Ivl=0ms
  E: Ad=02(O) Atr=02(Số lượng lớn) MxPS= 512 Ivl=0ms

Nếu hệ thống Linux phía máy chủ được cấu hình đúng cách, trình điều khiển ACM
nên được tải tự động.  Lệnh "lsmod" sẽ hiển thị
mô-đun "acm" đã được tải.


Cài đặt Trình điều khiển nối tiếp USB chung của máy chủ Linux
---------------------------------------------------
Để sử dụng trình điều khiển nối tiếp USB chung của Linux, bạn phải định cấu hình
Nhân phía máy chủ Linux dành cho "Hỗ trợ USB phía máy chủ", dành cho "USB
Hỗ trợ Bộ chuyển đổi nối tiếp" và cho "Trình điều khiển nối tiếp chung USB".

Khi trình điều khiển nối tiếp tiện ích được tải và thiết bị USB được kết nối
đến máy chủ Linux bằng cáp USB, hệ thống máy chủ sẽ nhận ra
thiết bị nối tiếp tiện ích.  Ví dụ: lệnh::

cat /sys/kernel/debug/usb/thiết bị

sẽ hiển thị một cái gì đó như thế này :::

T: Bus=01 Lev=01 Prnt=01 Cổng=01 Cnt=02 Dev#= 6 Spd=480 MxCh= 0
  D: Ver= 2,00 Cls=ff(vend.) Sub=00 Prot=00 MxPS=64 #Cfgs= 1
  P: Nhà cung cấp=0525 ProdID=a4a6 Rev= 2,01
  S: Nhà sản xuất=Linux 2.6.8.1 với net2280
  S: Sản phẩm=Sê-ri tiện ích
  S: Số sê-ri=0
  C:* #Ifs= 1 Cfg#= 1 Atr=c0 MxPwr= 2mA
  I: If#= 0 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=serial
  E: Quảng cáo=81(I) Atr=02(Số lượng lớn) MxPS= 512 Ivl=0ms
  E: Ad=02(O) Atr=02(Số lượng lớn) MxPS= 512 Ivl=0ms

Bạn phải tải trình điều khiển usbserial và đặt rõ ràng các tham số của nó
để định cấu hình nó để nhận dạng thiết bị nối tiếp tiện ích, như sau::

echo 0x0525 0xA4A6 >/sys/bus/usb-serial/drivers/generic/new_id

Cách cũ là sử dụng các tham số mô-đun ::

nhà cung cấp usbserial modprobe=0x0525 sản phẩm=0xA4A6

Nếu mọi thứ đều hoạt động, usbserial sẽ in một thông báo trong
nhật ký hệ thống có nội dung như "Bộ chuyển đổi nối tiếp tiện ích ngay bây giờ
được đính kèm với ttyUSB0".


Thử nghiệm với Minicom hoặc HyperTerminal
-------------------------------------
Sau khi cả trình điều khiển nối tiếp tiện ích và trình điều khiển máy chủ đều được cài đặt,
và cáp USB kết nối thiết bị tiện ích với máy chủ, bạn nên
có thể giao tiếp qua USB giữa tiện ích và hệ thống máy chủ.
Bạn có thể sử dụng minicom hoặc HyperTerminal để thử điều này.

Về phía tiện ích, hãy chạy "minicom -s" để định cấu hình một minicom mới
phiên.  Trong phần "Thiết lập cổng nối tiếp", đặt "/dev/ttygserial" làm
"Thiết bị nối tiếp".  Đặt tốc độ truyền, bit dữ liệu, tính chẵn lẻ và bit dừng,
đến 9600, 8, không có và 1--những cài đặt này hầu như không quan trọng.
Trong "Modem và quay số" hãy xóa tất cả các chuỗi modem và quay số.

Trên máy chủ Linux chạy trình điều khiển ACM, hãy định cấu hình minicom tương tự
nhưng sử dụng "/dev/ttyACM0" làm "Thiết bị nối tiếp".  (Nếu bạn có khác
Đã kết nối các thiết bị ACM, hãy thay đổi tên thiết bị phù hợp.)

Trên máy chủ Linux chạy trình điều khiển nối tiếp chung USB, hãy định cấu hình
minicom tương tự, nhưng sử dụng "/dev/ttyUSB0" làm "Thiết bị nối tiếp".
(Nếu bạn đã kết nối các thiết bị nối tiếp USB khác, hãy thay đổi thiết bị
đặt tên cho phù hợp.)

Trên máy chủ Windows, hãy định cấu hình phiên HyperTerminal mới để sử dụng
Cổng COM được gán cho Gadget Serial.  "Cài đặt cổng" sẽ là
được thiết lập tự động khi HyperTerminal kết nối với serial tiện ích
thiết bị, do đó bạn có thể để chúng được đặt ở các giá trị mặc định--những giá trị này
cài đặt hầu như không quan trọng.

Với minicom được cấu hình và chạy ở phía tiện ích và với
minicom hoặc HyperTerminal được cấu hình và chạy ở phía máy chủ,
bạn sẽ có thể gửi dữ liệu qua lại giữa tiện ích
hệ thống bên và phía máy chủ.  Bất cứ điều gì bạn gõ trên thiết bị đầu cuối
cửa sổ ở phía tiện ích sẽ xuất hiện trong cửa sổ đầu cuối trên
phía chủ nhà và ngược lại.
