.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/xpad.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
xpad - Trình điều khiển Linux USB cho bộ điều khiển tương thích Xbox
=======================================================

Trình điều khiển này hiển thị tất cả các tính năng tương thích với Xbox của bên thứ nhất và bên thứ ba
bộ điều khiển. Nó có một lịch sử lâu dài và được sử dụng đáng kể
vì thư viện xinput của Windows khiến hầu hết các trò chơi trên PC tập trung vào Xbox
khả năng tương thích của bộ điều khiển.

Do khả năng tương thích ngược nên tất cả các nút đều được báo cáo là kỹ thuật số.
Điều này chỉ ảnh hưởng đến bộ điều khiển Xbox gốc. Tất cả các mẫu bộ điều khiển sau này
chỉ có nút mặt kỹ thuật số.

Rumble được hỗ trợ trên một số kiểu bộ điều khiển Xbox 360 nhưng không được hỗ trợ trên
Bộ điều khiển Xbox gốc cũng như trên bộ điều khiển Xbox One. Khi viết
Giao thức ầm ầm của Xbox One không được thiết kế ngược nhưng trong
tương lai có thể được hỗ trợ.


Ghi chú
=====

Số lượng nút/trục được báo cáo thay đổi dựa trên 3 điều:

- nếu bạn đang sử dụng bộ điều khiển đã biết
- nếu bạn đang sử dụng một bàn nhảy đã biết
- nếu sử dụng một thiết bị không xác định (thiết bị không được liệt kê bên dưới), những gì bạn đặt trong
  cấu hình mô-đun cho "Ánh xạ D-PAD tới các nút thay vì các trục không xác định
  miếng đệm" (tùy chọn mô-đun dpad_to_buttons)

Nếu bạn đặt dpad_to_buttons thành N và bạn đang sử dụng một thiết bị không xác định
trình điều khiển sẽ ánh xạ bảng định hướng tới các trục (X/Y).
Nếu bạn nói Y, nó sẽ ánh xạ d-pad tới các nút cần thiết cho khiêu vũ
trò chơi phong cách để hoạt động chính xác. Mặc định là Y

dpad_to_buttons không có tác dụng đối với các miếng đệm đã biết. Một thông báo cam kết sai
dpad_to_buttons được tuyên bố có thể được sử dụng để buộc hành vi trên các thiết bị đã biết.
Điều này không đúng. Cả dpad_to_buttons và triggers_to_buttons đều chỉ ảnh hưởng
bộ điều khiển chưa biết.


Bộ điều khiển thông thường
------------------

Với bộ điều khiển thông thường, bảng định hướng được ánh xạ tới trục X/Y của chính nó.
Chương trình jstest từ joystick-1.2.15 (jstest-version 2.1.0) sẽ báo cáo 8
trục và 10 nút.

Tất cả 8 trục đều hoạt động, mặc dù chúng đều có cùng phạm vi (-32768..32767)
và cài đặt 0 không chính xác cho trình kích hoạt (tôi không biết liệu điều đó có
là một số hạn chế của jstest, vì thiết lập thiết bị đầu vào sẽ ổn. tôi
chưa xem qua jstest).

Tất cả 10 nút đều hoạt động (ở chế độ kỹ thuật số). Sáu nút trên
bên phải (A, B, X, Y, đen, trắng) được gọi là "analog" và
báo cáo giá trị của chúng là 8 bit không dấu, không chắc điều này tốt cho mục đích gì.

Tôi đã thử nghiệm bộ điều khiển với quake3, cấu hình và
trong trò chơi chức năng vẫn ổn. Tuy nhiên, tôi thấy khá khó khăn để
chơi game bắn súng góc nhìn thứ nhất bằng một miếng đệm. Số dặm của bạn có thể thay đổi.


Tấm đệm nhảy Xbox
---------------

Khi sử dụng một dance pad đã biết, jstest sẽ báo cáo 6 trục và 14 nút.

Đối với các miếng đệm theo phong cách khiêu vũ (như miếng đệm redoctane), một số thay đổi
đã được thực hiện.  Trình điều khiển cũ sẽ ánh xạ d-pad tới các trục, dẫn đến
trong trình điều khiển không thể báo cáo khi người dùng nhấn cả hai
trái+phải hoặc lên+xuống, khiến các trò chơi kiểu DDR không thể chơi được.

Các miếng đệm nhảy đã biết sẽ tự động ánh xạ d-pad tới các nút và sẽ hoạt động
một cách chính xác ra khỏi hộp.

Nếu bàn nhảy của bạn được người lái nhận ra nhưng thay vào đó lại sử dụng trục
của các nút, xem phần 0.3 - Bộ điều khiển không xác định

Tôi đã thử nghiệm điều này với Stepmania và nó hoạt động khá tốt.


Bộ điều khiển không xác định
-------------------

Nếu bạn có bộ điều khiển Xbox không xác định, nó sẽ hoạt động tốt với
các cài đặt mặc định.

HOWEVER nếu bạn có một bàn nhảy không xác định không được liệt kê bên dưới thì nó sẽ không
hoạt động UNLESS bạn đặt "dpad_to_buttons" thành 1 trong cấu hình mô-đun.


Bộ chuyển đổi USB
============

Tất cả các thế hệ bộ điều khiển Xbox đều nói USB qua dây.

- Bộ điều khiển Xbox gốc sử dụng đầu nối độc quyền và yêu cầu bộ điều hợp.
- Bộ điều khiển Xbox 360 không dây yêu cầu 'Bộ thu trò chơi không dây Xbox 360
  dành cho Windows'
- Bộ điều khiển Xbox 360 có dây sử dụng đầu nối USB tiêu chuẩn.
- Bộ điều khiển Xbox One có thể không dây nhưng nói được Wi-Fi Direct và không
  vẫn được hỗ trợ.
- Bộ điều khiển Xbox One có thể được nối dây và sử dụng đầu nối Micro-USB tiêu chuẩn.



Bộ điều hợp Xbox USB gốc
--------------------------

Sử dụng trình điều khiển này với bộ điều khiển Xbox gốc yêu cầu
cáp bộ chuyển đổi để ngắt các chân của đầu nối độc quyền tới USB.
Bạn có thể mua những thứ này trực tuyến khá rẻ hoặc tự xây dựng.

Một cáp như vậy là khá dễ dàng để xây dựng. Bản thân Bộ điều khiển là USB
thiết bị phức hợp (một hub có ba cổng cho hai khe cắm mở rộng và
thiết bị điều khiển) với sự khác biệt duy nhất ở đầu nối không chuẩn
(5 chân so với 4 chân trên đầu nối USB 1.0 tiêu chuẩn).

Bạn chỉ cần hàn đầu nối USB vào cáp và giữ nguyên
dây màu vàng chưa được kết nối. Các chân khác có cùng thứ tự trên cả hai
kết nối nên không có phép thuật cho nó. Thông tin chi tiết về những vấn đề này
có thể tìm thấy trên mạng ([1]_, [2]_, [3]_).

Nhờ có bộ chia hành trình trên cáp, bạn thậm chí không cần phải cắt
bản gốc. Bạn có thể mua một cáp mở rộng và cắt nó để thay thế. Bằng cách đó,
bạn vẫn có thể sử dụng bộ điều khiển với Xbox nếu có;)



Cài đặt trình điều khiển
===================

Khi bạn đã có cáp bộ chuyển đổi, nếu cần và bộ điều khiển được kết nối
mô-đun xpad sẽ được tải tự động. Để xác nhận bạn có thể mèo
/sys/kernel/debug/usb/devices. Cần có một mục như thế:

.. code-block:: none
   :caption: dump from InterAct PowerPad Pro (Germany)

    T:  Bus=01 Lev=03 Prnt=04 Port=00 Cnt=01 Dev#=  5 Spd=12  MxCh= 0
    D:  Ver= 1.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS=32 #Cfgs=  1
    P:  Vendor=05fd ProdID=107a Rev= 1.00
    C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=100mA
    I:  If#= 0 Alt= 0 #EPs= 2 Cls=58(unk. ) Sub=42 Prot=00 Driver=(none)
    E:  Ad=81(I) Atr=03(Int.) MxPS=  32 Ivl= 10ms
    E:  Ad=02(O) Atr=03(Int.) MxPS=  32 Ivl= 10ms

.. code-block:: none
   :caption: dump from Redoctane Xbox Dance Pad (US)

    T:  Bus=01 Lev=02 Prnt=09 Port=00 Cnt=01 Dev#= 10 Spd=12  MxCh= 0
    D:  Ver= 1.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS= 8 #Cfgs=  1
    P:  Vendor=0c12 ProdID=8809 Rev= 0.01
    S:  Product=XBOX DDR
    C:* #Ifs= 1 Cfg#= 1 Atr=80 MxPwr=100mA
    I:  If#= 0 Alt= 0 #EPs= 2 Cls=58(unk. ) Sub=42 Prot=00 Driver=xpad
    E:  Ad=82(I) Atr=03(Int.) MxPS=  32 Ivl=4ms
    E:  Ad=02(O) Atr=03(Int.) MxPS=  32 Ivl=4ms


Bộ điều khiển được hỗ trợ
=====================

Để biết danh sách đầy đủ các bộ điều khiển được hỗ trợ cũng như nhà cung cấp và sản phẩm liên quan
ID xem xpad_device[] array\ [4]_.

Kể từ phiên bản lịch sử 0.0.6 (2006-10-10), các thiết bị sau
đã được hỗ trợ::

Bộ điều khiển Microsoft XBOX gốc (Mỹ), nhà cung cấp=0x045e, sản phẩm=0x0202
 bộ điều khiển Microsoft XBOX nhỏ hơn (US), nhà cung cấp=0x045e, sản phẩm=0x0289
 Bộ điều khiển Microsoft XBOX gốc (Nhật Bản), nhà cung cấp=0x045e, sản phẩm=0x0285
 InterAct PowerPad Pro (Đức), nhà cung cấp=0x05fd, sản phẩm=0x107a
 RedOctane Xbox Dance Pad (US), nhà cung cấp=0x0c12, sản phẩm=0x8809

Các mẫu bộ điều khiển Xbox không được nhận dạng sẽ hoạt động như Generic
Bộ điều khiển Xbox. Bộ điều khiển Dance Pad không được nhận dạng yêu cầu cài đặt
tùy chọn mô-đun 'dpad_to_buttons'.

Nếu bạn có bộ điều khiển không được nhận dạng, vui lòng xem 0.3 - Bộ điều khiển không xác định


Kiểm tra thủ công
==============

Để kiểm tra chức năng của trình điều khiển này, bạn có thể sử dụng 'jstest'.

Ví dụ::

> modprobe xpad
    > modprobe joydev
    > jstest /dev/js0

Nếu bạn đang sử dụng bộ điều khiển thông thường, sẽ có một dòng hiển thị
18 đầu vào (8 trục, 10 nút) và giá trị của nó sẽ thay đổi nếu bạn di chuyển
gậy và nhấn nút.  Nếu bạn đang sử dụng bàn nhảy thì nên
hiển thị 20 đầu vào (6 trục, 14 nút).

Nó hoạt động? Thì đấy, bạn đã hoàn tất;)



Cảm ơn
======

Tôi phải cảm ơn ITO Takayuki vì thông tin chi tiết trên trang web của anh ấy
    ZZ0000ZZ

Thông tin hữu ích của anh ấy và cả bộ xương USB cũng như trình điều khiển đầu vào iforce
(Greg Kroah-Hartmann; Vojtech Pavlik) đã giúp ích rất nhiều trong việc tạo mẫu nhanh
chức năng cơ bản.



Tài liệu tham khảo
==========

.. [1] http://euc.jp/periphs/xbox-controller.ja.html (ITO Takayuki)
.. [2] http://xpad.xbox-scene.com/
.. [3] http://www.markosweb.com/www/xboxhackz.com/
.. [4] https://elixir.bootlin.com/linux/latest/ident/xpad_device


Chỉnh sửa lịch sử
==============

16-07-2002 - Marko Friedemann <mfr@bmx-chemnitz.de>
 - tài liệu gốc

19-03-2005 - Dominic Cerquetti <binary1230@yahoo.com>
 - đã thêm nội dung cho các miếng đệm nhảy, ánh xạ trục d-pad-> mới

Những thay đổi sau này có thể được xem bằng
'git log --follow Tài liệu/input/devices/xpad.rst'
