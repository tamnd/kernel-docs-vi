.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/alps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

---------------------------
Giao thức bàn di chuột ALPS
---------------------------

Giới thiệu
------------
Hiện tại trình điều khiển bàn di chuột ALPS hỗ trợ bảy phiên bản giao thức được sử dụng bởi
Bàn di chuột ALPS, gọi là phiên bản 1, 2, 3, 4, 5, 6, 7 và 8.

Kể từ khoảng giữa năm 2010, một số bàn di chuột ALPS mới đã được phát hành và
tích hợp vào nhiều loại máy tính xách tay và netbook.  Những bàn di chuột mới này
có đủ sự khác biệt về hành vi mà định nghĩa Alps_model_data
bảng mô tả các thuộc tính của các phiên bản khác nhau không còn
đầy đủ.  Các lựa chọn thiết kế là để xác định lại dãy Alps_model_data
bảng, với nguy cơ kiểm tra hồi quy các thiết bị hiện có hoặc cô lập
các thiết bị mới bên ngoài bảng Alps_model_data.  Thiết kế sau này
sự lựa chọn đã được thực hiện.  Các chữ ký trên bàn di chuột mới có tên: "Rushmore",
"Đỉnh cao" và "Cá heo" mà bạn sẽ thấy trong mã Alps.c.
Với mục đích của tài liệu này, nhóm bàn di chuột ALPS này sẽ
thường được gọi là "bàn di chuột ALPS mới".

Chúng tôi đã thử nghiệm thăm dò giao diện ACPI _HID (ID phần cứng)/_CID
(ID tương thích) như một cách để nhận dạng duy nhất
các biến thể ALPS khác nhau nhưng dường như không có ánh xạ 1:1.
Trên thực tế, nó dường như là một ánh xạ m:n giữa _HID và thực tế.
loại phần cứng.

Phát hiện
---------

Tất cả bàn di chuột ALPS phải phản hồi chuỗi lệnh "Báo cáo E6":
E8-E6-E6-E6-E9. Bàn di chuột ALPS sẽ phản hồi bằng 00-00-0A hoặc
00-00-64 nếu không có nút nào được nhấn. Các bit 0-2 của byte đầu tiên sẽ là 1s
nếu một số nút được nhấn.

Nếu báo cáo E6 thành công, kiểu bàn di chuột sẽ được xác định bằng cách sử dụng "E7
report" trình tự: E8-E7-E7-E7-E9. Phản hồi là chữ ký mẫu và là
khớp với các mô hình đã biết trong dãy Alps_model_data_array.

Đối với các bàn di chuột cũ hơn hỗ trợ giao thức phiên bản 3 và 4, báo cáo E7
chữ ký mẫu luôn là 73-02-64. Để phân biệt giữa những điều này
phiên bản, phản hồi từ trình tự "Nhập chế độ lệnh" phải là
được kiểm tra như mô tả dưới đây.

Bàn di chuột ALPS mới có chữ ký E7 là 73-03-50 hoặc 73-03-0A nhưng
dường như được phân biệt rõ hơn nhờ phản hồi của Chế độ lệnh EC.

Chế độ lệnh
------------

Giao thức phiên bản 3 và 4 có chế độ lệnh được sử dụng để đọc và ghi
thiết bị một byte đăng ký trong không gian địa chỉ 16 bit. Trình tự lệnh
EC-EC-EC-E9 đặt thiết bị ở chế độ lệnh và thiết bị sẽ phản hồi
với 88-07 theo sau là byte thứ ba. Byte thứ ba này có thể được sử dụng để xác định
liệu thiết bị sử dụng giao thức phiên bản 3 hay 4.

Để thoát khỏi chế độ lệnh, PSMOUSE_CMD_SETSTREAM (EA) được gửi đến bàn di chuột.

Khi ở chế độ lệnh, địa chỉ thanh ghi có thể được đặt bằng cách trước tiên gửi một
lệnh cụ thể, EC cho thiết bị v3 hoặc F5 cho thiết bị v4. Sau đó
địa chỉ được gửi từng phần một, trong đó mỗi phần được mã hóa thành một
lệnh với dữ liệu tùy chọn. Mã hóa này hơi khác một chút giữa v3 và
giao thức v4.

Khi một địa chỉ đã được thiết lập, thanh ghi địa chỉ có thể được đọc bằng cách gửi
PSMOUSE_CMD_GETINFO (E9). Hai byte đầu tiên của phản hồi chứa
địa chỉ của thanh ghi đang được đọc và địa chỉ thứ ba chứa giá trị của
đăng ký. Các thanh ghi được viết bằng cách ghi từng giá trị một
sử dụng cùng một mã hóa được sử dụng cho địa chỉ.

Đối với bàn di chuột ALPS mới, lệnh EC được sử dụng để nhập lệnh
chế độ. Phản hồi trên bàn di chuột ALPS mới khác biệt đáng kể,
và quan trọng hơn trong việc xác định hành vi.  Mã này đã được
tách khỏi bảng Alps_model_data ban đầu và đặt vào
hàm Alps_identify.  Ví dụ, dường như có hai phần cứng init
trình tự cho bàn di chuột "Dolphin" được xác định bởi byte thứ hai
về phản ứng của EC.

Định dạng gói
-------------

Trong các bảng sau, ký hiệu sau được sử dụng::

CAPITALS = thanh, cực nhỏ = bàn di chuột

?'s có thể có ý nghĩa khác nhau trên các mẫu xe khác nhau, chẳng hạn như vòng quay của bánh xe,
các nút phụ, các nút dính trên điểm kép, v.v.

Định dạng gói PS/2
------------------

::

byte 0: 0 0 YSGN XSGN 1 M R L
 byte 1: X7 X6 X5 X4 X3 X2 X1 X0
 byte 2: Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0

Lưu ý thiết bị không bao giờ báo hiệu tình trạng tràn.

Đối với các thiết bị giao thức phiên bản 2 khi sử dụng trackpoint và không có ngón tay
nằm trên bàn di chuột, các bit M R L báo hiệu trạng thái kết hợp của cả hai
nút trỏ và bàn di chuột.

Chế độ tuyệt đối ALPS - Phiên bản giao thức 1
---------------------------------------

::

byte 0: 1 0 0 0 1 x9 x8 x7
 byte 1: 0 x6 x5 x4 x3 x2 x1 x0
 byte 2: 0?    ?    tôi r?  vây
 byte 3: 0?    ?    ?    ?   y9 y8 y7
 byte 4: 0 y6 y5 y4 y3 y2 y1 y0
 byte 5: 0 z6 z5 z4 z3 z2 z1 z0

Chế độ tuyệt đối ALPS - Phiên bản giao thức 2
---------------------------------------

::

byte 0: 1?    ?    ?    1 PSM PSR PSL
 byte 1: 0 x6 x5 x4 x3 x2 x1 x0
 byte 2: 0 x10 x9 x8 x7?  vây
 byte 3: 0 y9 y8 y7 1 M R L
 byte 4: 0 y6 y5 y4 y3 y2 y1 y0
 byte 5: 0 z6 z5 z4 z3 z2 z1 z0

Các thiết bị DualPoint giao thức phiên bản 2 gửi các gói chuột PS/2 tiêu chuẩn cho
Thanh DualPoint. Các bit M, R và L báo hiệu trạng thái kết hợp của cả hai
các nút trỏ và bàn di chuột, ngoại trừ các thiết bị điểm kép của Dell
nơi các nút trỏ được báo cáo riêng trong PSM, PSR
và các bit PSL.

Thiết bị Dualpoint - định dạng gói xen kẽ
---------------------------------------------

::

byte 0: 1 1 0 0 1 1 1 1
 byte 1: 0 x6 x5 x4 x3 x2 x1 x0
 byte 2: 0 x10 x9 x8 x7 0 vây
 byte 3: 0 0 YSGN XSGN 1 1 1 1
 byte 4: X7 X6 X5 X4 X3 X2 X1 X0
 byte 5: Y7 Y6 Y5 Y4 Y3 Y2 Y1 Y0
 byte 6: 0 y9 y8 y7 1 m r l
 byte 7: 0 y6 y5 y4 y3 y2 y1 y0
 byte 8: 0 z6 z5 z4 z3 z2 z1 z0

Các thiết bị sử dụng định dạng xen kẽ thường gửi chuột PS/2 tiêu chuẩn
các gói dành cho gói DualPoint Stick + ALPS Chế độ tuyệt đối dành cho
bàn di chuột, chuyển sang định dạng gói xen kẽ khi cả thanh và
bàn di chuột được sử dụng cùng một lúc.

Chế độ tuyệt đối ALPS - Phiên bản giao thức 3
---------------------------------------

Giao thức ALPS phiên bản 3 có ba định dạng gói khác nhau. Hai cái đầu tiên là
được liên kết với các sự kiện trên bàn di chuột và sự kiện thứ ba được liên kết với trackstick
sự kiện.

Loại đầu tiên là gói vị trí bàn di chuột::

byte 0: 1?   x1 x0 1 1 1 1
 byte 1: 0 x10 x9 x8 x7 x6 x5 x4
 byte 2: 0 y10 y9 y8 y7 y6 y5 y4
 byte 3: 0 M R L 1 m r l
 byte 4: 0 mt x3 x2 y3 y2 y1 y0
 byte 5: 0 z6 z5 z4 z3 z2 z1 z0

Lưu ý rằng đối với một số thiết bị, các nút trackstick được báo cáo trong gói này,
và trên những nơi khác, nó được báo cáo trong các gói trackstick.

Loại gói thứ hai chứa các bitmap biểu thị trục x và y. trong
bitmap một bit nhất định được đặt nếu có một ngón tay che vị trí đó trên
trục đã cho. Do đó, gói bitmap có thể được sử dụng cho cảm ứng đa điểm có độ phân giải thấp.
dữ liệu, mặc dù không thể theo dõi ngón tay.  Gói này cũng mã hóa
số lượng liên hệ (f1 và f0 trong bảng bên dưới)::

byte 0: 1 1 x1 x0 1 1 1 1
 byte 1: 0 x8 x7 x6 x5 x4 x3 x2
 byte 2: 0 y7 y6 y5 y4 y3 y2 y1
 byte 3: 0 y10 y9 y8 1 1 1 1
 byte 4: 0 x14 x13 x12 x11 x10 x9 y0
 byte 5: 0 1?    ?    ?    ?   f1 f0

Gói này chỉ xuất hiện sau gói vị trí có tập bit mt và
thường chỉ xuất hiện khi có từ hai địa chỉ liên hệ trở lên (mặc dù
đôi khi nó được nhìn thấy chỉ với một liên hệ duy nhất).

Loại gói v3 cuối cùng là gói trackstick ::

byte 0: 1 1 x7 y7 1 1 1 1
 byte 1: 0 x6 x5 x4 x3 x2 x1 x0
 byte 2: 0 y6 y5 y4 y3 y2 y1 y0
 byte 3: 0 1 TP SW 1 M R L
 byte 4: 0 z6 z5 z4 z3 z2 z1 z0
 byte 5: 0 0 1 1 1 1 1 1

TP có nghĩa là trạng thái Nhấn vào SW khi xử lý nhấn được bật hoặc Trạng thái nhấn khi nhấn
xử lý được kích hoạt. SW có nghĩa là cuộn lên khi có sẵn 4 nút.

Chế độ tuyệt đối ALPS - Phiên bản giao thức 4
---------------------------------------

Giao thức phiên bản 4 có định dạng gói 8 byte::

byte 0: 1?   x1 x0 1 1 1 1
 byte 1: 0 x10 x9 x8 x7 x6 x5 x4
 byte 2: 0 y10 y9 y8 y7 y6 y5 y4
 byte 3: 0 1 x3 x2 y3 y2 y1 y0
 byte 4: 0?    ?    ?    1 ?    r tôi
 byte 5: 0 z6 z5 z4 z3 z2 z1 z0
 byte 6: dữ liệu bitmap (được mô tả bên dưới)
 byte 7: dữ liệu bitmap (được mô tả bên dưới)

Hai byte cuối cùng biểu thị gói bitmap một phần, với 3 gói đầy đủ
cần thiết để xây dựng một gói bitmap hoàn chỉnh.  Sau khi được lắp ráp, 6 byte
gói bitmap có định dạng sau::

byte 0: 0 1 x7 x6 x5 x4 x3 x2
 byte 1: 0 x1 x0 y4 y3 y2 y1 y0
 byte 2: 0 0?  x14 x13 x12 x11 x10
 byte 3: 0 x9 x8 y9 y8 y7 y6 y5
 byte 4: 0 0 0 0 0 0 0 0
 byte 5: 0 0 0 0 0 0 0 y10

Có một số điều đáng lưu ý ở đây.

1) Trong dữ liệu bitmap, bit 6 của byte 0 đóng vai trò là byte đồng bộ với
    xác định đoạn đầu tiên của gói bitmap.

2) Các bitmap biểu thị dữ liệu giống như trong các gói bitmap v3, mặc dù
    cách bố trí gói là khác nhau.

3) Dường như không có số lượng điểm liên hệ ở bất kỳ đâu trong v4
    gói giao thức. Việc lấy số lượng điểm tiếp xúc phải được thực hiện bằng cách
    phân tích các bitmap.

4) Có tỷ lệ 3:1 giữa các gói vị trí và các gói bitmap. Vì thế
    Vị trí MT chỉ có thể được cập nhật cho mỗi lần cập nhật vị trí ST thứ ba và
    số lượng điểm liên lạc chỉ có thể được cập nhật mỗi gói thứ ba vì
    tốt.

Cho đến nay chưa gặp thiết bị v4 nào có trackstick.

Chế độ tuyệt đối ALPS - Phiên bản giao thức 5
---------------------------------------
Về cơ bản đây là Giao thức phiên bản 3 nhưng có logic khác cho gói
giải mã.  Nó sử dụng lệnh gọi Alps_process_touchpad_packet_v3 tương tự với
con trỏ hàm giải mã_fields chuyên dụng để diễn giải chính xác
gói.  Điều này dường như chỉ được sử dụng bởi các thiết bị Dolphin.

Đối với một lần chạm, định dạng gói 6 byte là::

byte 0: 1 1 0 0 1 0 0 0
 byte 1: 0 x6 x5 x4 x3 x2 x1 x0
 byte 2: 0 y6 y5 y4 y3 y2 y1 y0
 byte 3: 0 M R L 1 m r l
 byte 4: y10 y9 y8 y7 x10 x9 x8 x7
 byte 5: 0 z6 z5 z4 z3 z2 z1 z0

Đối với mt, định dạng là::

byte 0: 1 1 1 n3 1 n2 n1 x24
 byte 1: 1 y7 y6 y5 y4 y3 y2 y1
 byte 2: ?   x2 x1 y12 y11 y10 y9 y8
 byte 3: 0 x23 x22 x21 x20 x19 x18 x17
 byte 4: 0 x9 x8 x7 x6 x5 x4 x3
 byte 5: 0 x16 x15 x14 x13 x12 x11 x10

Chế độ tuyệt đối ALPS - Phiên bản giao thức 6
---------------------------------------

Đối với gói trackstick, định dạng là::

byte 0: 1 1 1 1 1 1 1 1
 byte 1: 0 X6 X5 X4 X3 X2 X1 X0
 byte 2: 0 Y6 Y5 Y4 Y3 Y2 Y1 Y0
 byte 3: ?   Y7 X7 ?    ?    M R L
 byte 4: Z7 Z6 Z5 Z4 Z3 Z2 Z1 Z0
 byte 5: 0 1 1 1 1 1 1 1

Đối với gói bàn di chuột, định dạng là::

byte 0: 1 1 1 1 1 1 1 1
 byte 1: 0 0 0 0 x3 x2 x1 x0
 byte 2: 0 0 0 0 y3 y2 y1 y0
 byte 3: ?   x7 x6 x5 x4?    r tôi
 byte 4: ?   y7 y6 y5 y4 ?    ?    ?
 byte 5: z7 z6 z5 z4 z3 z2 z1 z0

(Touchpad v6 không có nút giữa)

Chế độ tuyệt đối ALPS - Phiên bản giao thức 7
---------------------------------------

Đối với gói trackstick, định dạng là::

byte 0: 0 1 0 0 1 0 0 0
 byte 1: 1 1 * * 1 M R L
 byte 2: X7 1 X5 X4 X3 X2 X1 X0
 byte 3: Z6 1 Y6 X6 1 Y2 Y1 Y0
 byte 4: Y7 0 Y5 Y4 Y3 1 1 0
 byte 5: T&P 0 Z5 Z4 Z3 Z2 Z1 Z0

Đối với gói bàn di chuột, định dạng là::

gói-fmt b7 b6 b5 b4 b3 b2 b1 b0
 byte 0: TWO & MULTI L 1 R M 1 Y0-2 Y0-1 Y0-0
 byte 0: NEW L 1 X1-5 1 1 Y0-2 Y0-1 Y0-0
 byte 1: Y0-10 Y0-9 Y0-8 Y0-7 Y0-6 Y0-5 Y0-4 Y0-3
 byte 2: X0-11 1 X0-10 X0-9 X0-8 X0-7 X0-6 X0-5
 byte 3: X1-11 1 X0-4 X0-3 1 X0-2 X0-1 X0-0
 byte 4: TWO X1-10 TWO X1-9 X1-8 X1-7 X1-6 X1-5 X1-4
 byte 4: MULTI X1-10 TWO X1-9 X1-8 X1-7 X1-6 Y1-5 1
 byte 4: NEW X1-10 TWO X1-9 X1-8 X1-7 X1-6 0 0
 byte 5: TWO & NEW Y1-10 0 Y1-9 Y1-8 Y1-7 Y1-6 Y1-5 Y1-4
 byte 5: MULTI Y1-10 0 Y1-9 Y1-8 Y1-7 Y1-6 F-1 F-0

L: Nút trái
 R/M: Không có clickpad: Nút Phải/Giữa
            Bàn di chuột: Khi > 2 ngón tay úp xuống và một số ngón tay
            nằm trong vùng nút thì báo 2 tọa độ
            dành cho các ngón tay bên ngoài vùng nút và những báo cáo này
            ngón tay phụ hiện diện ở nút phải / trái
            khu vực. Lưu ý những ngón tay này không được thêm vào trường F!
            vì vậy nếu nhận được gói TWO và R = 1 thì có
            3 ngón tay xuống, v.v.
 TWO: 1: Hiện tại có hai lần chạm, byte 0/4/5 nằm trong TWO fmt
            0: Nếu byte 4 bit 0 là 1 thì byte 0/4/5 nằm trong MULTI fmt
               nếu không thì byte 0 bit 4 phải được đặt và byte 0/4/5 là
               trong NEW fmt
 F: Số ngón tay - 3, 0 nghĩa là 3 ngón tay, 1 nghĩa là 4 ...


Chế độ tuyệt đối ALPS - Phiên bản giao thức 8
---------------------------------------

Được phát triển bởi phần cứng SS4 (73 03 14) và SS5 (73 03 28).

Loại gói được cung cấp bởi trường APD, bit 4-5 của byte 3.

Gói bàn di chuột (APD = 0x2)::

b7 b6 b5 b4 b3 b2 b1 b0
 byte 0: SWM SWR SWL 1 1 0 0 X7
 byte 1: 0 X6 X5 X4 X3 X2 X1 X0
 byte 2: 0 Y6 Y5 Y4 Y3 Y2 Y1 Y0
 byte 3: 0 T&P 1 0 1 0 0 Y7
 byte 4: 0 Z6 Z5 Z4 Z3 Z2 Z1 Z0
 byte 5: 0 0 0 0 0 0 0 0

SWM, SWR, SWL: Trạng thái nút Giữa, Phải và Trái

Bàn di chuột 1 Gói ngón tay (APD = 0x0)::

b7 b6 b5 b4 b3 b2 b1 b0
 byte 0: SWM SWR SWL 1 1 X2 X1 X0
 byte 1: X9 X8 X7 1 X6 X5 X4 X3
 byte 2: 0 X11 X10 LFB Y3 Y2 Y1 Y0
 byte 3: Y5 Y4 0 0 1 TAPF2 TAPF1 TAPF0
 byte 4: Zv7 Y11 Y10 1 Y9 Y8 Y7 Y6
 byte 5: Zv6 Zv5 Zv4 0 Zv3 Zv2 Zv1 Zv0

TAPF: ???
LFB: ???

Gói Touchpad 2 Finger (APD = 0x1)::

b7 b6 b5 b4 b3 b2 b1 b0
 byte 0: SWM SWR SWL 1 1 AX6 AX5 AX4
 byte 1: AX11 AX10 AX9 AX8 AX7 AZ1 AY4 AZ0
 byte 2: AY11 AY10 AY9 CONT AY8 AY7 AY6 AY5
 byte 3: 0 0 0 1 1 BX6 BX5 BX4
 byte 4: BX11 BX10 BX9 BX8 BX7 BZ1 BY4 BZ0
 byte 5: BY11 BY10 BY9 0 BY8 BY7 BY5 BY5

CONT: Tiếp theo là gói 3 hoặc 4 ngón tay

Gói ngón tay 3 hoặc 4 trên bàn di chuột (APD = 0x3)::

b7 b6 b5 b4 b3 b2 b1 b0
 byte 0: SWM SWR SWL 1 1 AX6 AX5 AX4
 byte 1: AX11 AX10 AX9 AX8 AX7 AZ1 AY4 AZ0
 byte 2: AY11 AY10 AY9 OVF AY8 AY7 AY6 AY5
 byte 3: 0 0 1 1 1 BX6 BX5 BX4
 byte 4: BX11 BX10 BX9 BX8 BX7 BZ1 BY4 BZ0
 byte 5: BY11 BY10 BY9 0 BY8 BY7 BY5 BY5

OVF: Đã phát hiện ngón tay thứ 5
