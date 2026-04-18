.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/acm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Trình điều khiển Linux ACM v0.16
======================

Bản quyền (c) 1999 Vojtech Pavlik <vojtech@suse.cz>

Được tài trợ bởi SuSE

0. Tuyên bố từ chối trách nhiệm
~~~~~~~~~~~~~
Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi nó
theo các điều khoản của Giấy phép Công cộng GNU do Free
Quỹ phần mềm; phiên bản 2 của Giấy phép hoặc (tùy theo lựa chọn của bạn)
bất kỳ phiên bản sau này.

Chương trình này được phân phối với hy vọng nó sẽ hữu ích, nhưng
WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của MERCHANTABILITY
hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem Giấy phép Công cộng GNU để biết
biết thêm chi tiết.

Bạn hẳn đã nhận được bản sao Giấy phép Công cộng GNU cùng với
với chương trình này; nếu không, hãy viết thư cho Free Software Foundation, Inc., 59
Temple Place, Suite 330, Boston, MA 02111-1307 USA

Nếu bạn cần liên hệ với tôi, tác giả, bạn có thể làm như vậy bằng e-mail -
gửi tin nhắn của bạn tới <vojtech@suse.cz> hoặc bằng thư giấy: Vojtech Pavlik,
Ucitelska 1576, Praha 8, 182 00 Cộng hòa Séc

Để thuận tiện cho bạn, Giấy phép Công cộng GNU phiên bản 2 được bao gồm
trong gói: Xem tệp COPYING.

1. Cách sử dụng
~~~~~~~~
Trình điều khiển/usb/class/cdc-acm.c hoạt động với modem USB và thiết bị đầu cuối USB ISDN
các bộ điều hợp phù hợp với Lớp thiết bị liên lạc bus nối tiếp vạn năng
Thông số kỹ thuật của Mô hình điều khiển trừu tượng (USB CDC ACM).

Nhiều modem cũng vậy, đây là danh sách những modem tôi biết:

- 3Com OfficeConnect 56k
	- Modem Fax thoại 3Com Pro
	- Xe thể thao 3Com
	- MultiTech MultiModem 56k
	- Modem Fax Zoom 2986L
	- Modem Fax Compaq 56k
	- ELSA Microlink 56k

Tôi biết một ISDN TA hoạt động với trình điều khiển acm:

- 3Com USR ISDN Pro TA

Một số điện thoại di động cũng kết nối qua USB. Tôi biết các điện thoại sau hoạt động:

- SonyEricsson K800i

Thật không may, nhiều modem và hầu hết ISDN TA sử dụng giao diện độc quyền và
do đó sẽ không hoạt động với trình điều khiển này. Kiểm tra sự tuân thủ ACM trước khi mua.

Để sử dụng modem, bạn cần tải các mô-đun sau::

usbcore.ko
	uhci-hcd.ko ohci-hcd.ko hoặc ehci-hcd.ko
	cdc-acm.ko

Sau đó, [các] modem sẽ có thể truy cập được. Bạn sẽ có thể sử dụng
minicom, ppp và mgetty với họ.

2. Xác minh rằng nó hoạt động
~~~~~~~~~~~~~~~~~~~~~~~~~~

Bước đầu tiên là kiểm tra/sys/kernel/debug/usb/devices, nó sẽ trông như thế này
như thế này::

T: Bus=01 Lev=00 Prnt=00 Cổng=00 Cnt=00 Dev#= 1 Spd=12 MxCh= 2
  B: Phân bổ= 0/900 us ( 0%), #Int= 0, #Iso= 0
  D: Ver= 1,00 Cls=09(hub ) Sub=00 Prot=00 MxPS= 8 #Cfgs= 1
  P: Nhà cung cấp=0000 ProdID=0000 Rev= 0,00
  S: Sản phẩm=USB UHCI Root Hub
  S: Số sê-ri=6800
  C:* #Ifs= 1 Cfg#= 1 Atr=40 MxPwr= 0mA
  I: If#= 0 Alt= 0 #EPs= 1 Cls=09(hub ) Sub=00 Prot=00 Driver=hub
  E: Ad=81(I) Atr=03(Int.) MxPS= 8 Ivl=255ms
  T: Bus=01 Lev=01 Prnt=01 Cổng=01 Cnt=01 Dev#= 2 Spd=12 MxCh= 0
  D: Ver= 1,00 Cls=02(comm.) Sub=00 Prot=00 MxPS= 8 #Cfgs= 2
  P: Nhà cung cấp=04c1 ProdID=008f Rev= 2,07
  S: Nhà sản xuất=3Com Inc.
  S: Product=3Com US Robotics Pro ISDN TA
  S: Số sê-ri=UFT53A49BVT7
  C: #Ifs= 1 Cfg#= 1 Atr=60 MxPwr= 0mA
  I: If#= 0 Alt= 0 #EPs= 3 Cls=ff(vend.) Sub=ff Prot=ff Driver=acm
  E: Ad=85(I) Atr=02(Số lượng lớn) MxPS= 64 Ivl= 0ms
  E: Ad=04(O) Atr=02(Số lượng lớn) MxPS= 64 Ivl= 0ms
  E: Ad=81(I) Atr=03(Int.) MxPS= 16 Ivl=128ms
  C:* #Ifs= 2 Cfg#= 2 Atr=60 MxPwr= 0mA
  I: If#= 0 Alt= 0 #EPs= 1 Cls=02(comm.) Sub=02 Prot=01 Driver=acm
  E: Ad=81(I) Atr=03(Int.) MxPS= 16 Ivl=128ms
  I: If#= 1 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=acm
  E: Ad=85(I) Atr=02(Số lượng lớn) MxPS= 64 Ivl= 0ms
  E: Ad=04(O) Atr=02(Số lượng lớn) MxPS= 64 Ivl= 0ms

Sự hiện diện của ba dòng này (và các lớp Cls= 'comm' và 'data')
quan trọng thì có nghĩa đó là thiết bị ACM. Driver=acm có nghĩa là acm
trình điều khiển được sử dụng cho thiết bị. Nếu bạn chỉ thấy Cls=ff(vend.) thì bạn đã bị loại
thật may mắn, bạn có một thiết bị có giao diện dành riêng cho nhà cung cấp ::

D: Ver= 1,00 Cls=02(comm.) Sub=00 Prot=00 MxPS= 8 #Cfgs= 2
  I: If#= 0 Alt= 0 #EPs= 1 Cls=02(comm.) Sub=02 Prot=01 Driver=acm
  I: If#= 1 Alt= 0 #EPs= 2 Cls=0a(data ) Sub=00 Prot=00 Driver=acm

Trong nhật ký hệ thống, bạn sẽ thấy::

usb.c: USB kết nối thiết bị mới, thiết bị được gán số 2
  usb.c: kmalloc IF c7691fa0, numif 1
  usb.c: kmalloc IF c7b5f3e0, numif 2
  usb.c: bỏ qua 4 bộ mô tả giao diện cụ thể của lớp/nhà cung cấp
  usb.c: chuỗi thiết bị mới: Mfr=1, Product=2, SerialNumber=3
  usb.c: USB số thiết bị 2 ID ngôn ngữ mặc định 0x409
  Nhà sản xuất: 3Com Inc.
  Sản phẩm: 3Com U.S. Robotics Pro ISDN TA
  Số Serial: UFT53A49BVT7
  acm.c: thăm dò cấu hình 1
  acm.c: thăm dò cấu hình 2
  ttyACM0: Thiết bị USB ACM
  acm.c: acm_control_msg: rq: 0x22 val: 0x0 len: 0x0 kết quả: 0
  acm.c: acm_control_msg: rq: 0x20 val: 0x0 len: 0x7 kết quả: 7
  usb.c: giao diện được yêu cầu trình điều khiển acm c7b5f3e0
  usb.c: giao diện được yêu cầu trình điều khiển acm c7b5f3f8
  usb.c: giao diện được yêu cầu trình điều khiển acm c7691fa0

Nếu tất cả điều này có vẻ ổn, hãy kích hoạt minicom và thiết lập nó để nói chuyện với ttyACM
thiết bị và thử gõ 'at'. Nếu nó phản hồi bằng 'OK' thì mọi thứ đều ổn
đang làm việc.
