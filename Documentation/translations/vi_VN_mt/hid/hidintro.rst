.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hidintro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
Giới thiệu về bộ mô tả báo cáo HID
======================================

Chương này nhằm mục đích cung cấp một cái nhìn tổng quan về nội dung báo cáo của HID
mô tả là gì và cách một lập trình viên bình thường (không có kernel) có thể xử lý
với các thiết bị HID không hoạt động tốt với Linux.

.. contents::
    :local:
    :depth: 2

.. toctree::
   :maxdepth: 2

   hidreport-parsing


Giới thiệu
============

HID là viết tắt của Thiết bị giao diện con người và có thể là bất kỳ thiết bị nào bạn muốn.
đang sử dụng để tương tác với máy tính, có thể là chuột, bàn di chuột,
máy tính bảng, micro.

Nhiều thiết bị HID hoạt động tốt ngay cả khi phần cứng của chúng khác nhau.
Ví dụ, chuột có thể có số lượng nút tùy ý; họ có thể có một
bánh xe; độ nhạy chuyển động khác nhau giữa các kiểu máy khác nhau và do đó
trên. Tuy nhiên, hầu hết mọi thứ đều hoạt động bình thường mà không cần
cần phải có code chuyên dụng trong kernel cho từng mẫu chuột
phát triển từ năm 1970.

Điều này là do các thiết bị HID hiện đại quảng cáo khả năng của chúng
thông qua ZZ0000ZZ, một tập hợp byte cố định mô tả
chính xác những gì ZZ0001ZZ có thể được gửi giữa thiết bị và máy chủ
và ý nghĩa của từng bit riêng lẻ trong các báo cáo đó. Ví dụ,
Bộ mô tả báo cáo HID có thể chỉ định rằng "trong báo cáo có ID 3,
bit từ 8 đến 15 là tọa độ delta x của chuột".

Bản thân báo cáo HID sau đó chỉ mang các giá trị dữ liệu thực tế
mà không có bất kỳ thông tin meta bổ sung. Lưu ý rằng báo cáo HID có thể được gửi
từ thiết bị ("Báo cáo đầu vào", tức là sự kiện đầu vào), đến thiết bị
("Báo cáo đầu ra" ví dụ: thay đổi đèn LED) hoặc được sử dụng cho cấu hình thiết bị
("Báo cáo tính năng"). Một thiết bị có thể hỗ trợ một hoặc nhiều báo cáo HID.

Hệ thống con HID chịu trách nhiệm phân tích các bộ mô tả báo cáo HID,
và chuyển đổi các sự kiện HID thành giao diện thiết bị đầu vào thông thường (xem
Tài liệu/hid/hid-transport.rst). Thiết bị có thể hoạt động sai vì
Phần mô tả báo cáo HID do thiết bị cung cấp bị sai hoặc do nó
cần được giải quyết theo một cách đặc biệt, hoặc vì một số vấn đề đặc biệt
thiết bị hoặc chế độ tương tác không được xử lý bằng mã mặc định.

Định dạng của bộ mô tả báo cáo HID được mô tả bằng hai tài liệu,
có sẵn từ ZZ0000ZZ
Địa chỉ ZZ0001ZZ:

* ZZ0000ZZ (Thông số HID kể từ bây giờ)
 * ZZ0001ZZ (HUT kể từ bây giờ)

Hệ thống con HID có thể xử lý các trình điều khiển vận chuyển khác nhau
(USB, I2C, Bluetooth, v.v.). Xem Tài liệu/hid/hid-transport.rst.

Phân tích mô tả báo cáo HID
==============================

Bạn có thể tìm thấy danh sách hiện tại của các thiết bị HID tại ZZ0000ZZ.
Đối với mỗi thiết bị, giả sử ZZ0001ZZ,
người ta có thể đọc phần mô tả báo cáo tương ứng::

$ hexdump -C /sys/bus/hid/devices/0003\:093A\:2510.0002/report_descriptor
  00000000 05 01 09 02 a1 01 09 01 a1 00 05 09 19 01 29 03 ZZ0000ZZ
  00000010 15 00 25 01 75 01 95 03 81 02 75 05 95 01 81 01 ZZ0001ZZ
  00000020 05 01 09 30 09 31 09 38 15 81 25 7f 75 08 95 03 ZZ0002ZZ
  00000030 81 06 c0 c0 ZZ0003ZZ
  00000034

Tùy chọn: bộ mô tả báo cáo HID cũng có thể được đọc bởi
truy cập trực tiếp vào trình điều khiển hidraw [#hidraw]_.

Cấu trúc cơ bản của bộ mô tả báo cáo HID được xác định trong HID
spec, trong khi HUT "xác định các hằng số có thể được diễn giải bằng một
ứng dụng để xác định mục đích và ý nghĩa của trường dữ liệu trong một
Báo cáo HID". Mỗi mục được xác định bởi ít nhất hai byte, trong đó
cái đầu tiên xác định loại giá trị nào theo sau và được mô tả trong
thông số HID, trong khi thông số thứ hai mang giá trị thực và
được mô tả trong HUT.

Về nguyên tắc, các bộ mô tả báo cáo HID có thể được phân tích cú pháp một cách tỉ mỉ bởi
tay, từng byte một.

Phần giới thiệu ngắn gọn về cách thực hiện việc này được phác thảo trong
Tài liệu/hid/hidreport-parsing.rst; bạn chỉ cần hiểu nó
nếu bạn cần vá các bộ mô tả báo cáo HID.

Trong thực tế, bạn không nên phân tích các bộ mô tả báo cáo HID bằng tay; đúng hơn,
bạn nên sử dụng trình phân tích cú pháp hiện có. Trong số tất cả những cái có sẵn

* ZZ0000ZZ trực tuyến;
  * ZZ0001ZZ,
    cung cấp những mô tả rất chi tiết và có phần dài dòng
    (Mức độ chi tiết có thể hữu ích nếu bạn không quen với báo cáo HID
    mô tả);
  * ZZ0002ZZ,
    một bộ tiện ích hoàn chỉnh cho phép, trong số những thứ khác,
    để ghi lại và phát lại các báo cáo HID thô và gỡ lỗi
    và phát lại các thiết bị HID.
    Nó đang được các nhà bảo trì hệ thống con Linux HID tích cực phát triển.

Phân tích bộ mô tả báo cáo HID của chuột bằng ZZ0000ZZ dẫn đến
(giải thích xen kẽ)::

$ ./hid-decode /sys/bus/hid/devices/0003\:093A\:2510.0002/report_descriptor
    # device 0:0
    # 0x05, 0x01, // Trang sử dụng (Màn hình chung) 0
    # 0x09, 0x02, // Cách sử dụng (Chuột) 2
    # 0xa1, 0x01, // Bộ sưu tập (Ứng dụng) 4
    # 0x09, 0x01, // Cách sử dụng (Con trỏ) 6
    # 0xa1, 0x00, // Bộ sưu tập (Vật lý) 8
    # 0x05, 0x09, // Trang sử dụng (Nút) 10

những gì tiếp theo là một nút ::

# 0x19, 0x01, // Mức sử dụng tối thiểu (1) 12
    # 0x29, 0x03, // Mức sử dụng tối đa (3) 14

nút đầu tiên là nút số 1, nút cuối cùng là nút số 3 ::

# 0x15, 0x00, // Tối thiểu logic (0) 16
    # 0x25, 0x01, // Tối đa logic (1) 18

mỗi nút có thể gửi các giá trị từ 0 đến bao gồm 1
(tức là chúng là các nút nhị phân) ::

# 0x75, 0x01, // Kích thước báo cáo (1) 20

mỗi nút được gửi chính xác một bit ::

# 0x95, 0x03, // Số lượng báo cáo (3) 22

và có ba trong số các bit đó (khớp với ba nút)::

# 0x81, 0x02, // Đầu vào (Dữ liệu, Var, Abs) 24

đó là Dữ liệu thực tế (không phải phần đệm liên tục), chúng đại diện cho
một biến duy nhất (Var) và giá trị của chúng là Tuyệt đối (không tương đối);
Xem thông số HID Giây. 6.2.2.5 "Các mục đầu vào, đầu ra và tính năng" ::

# 0x75, 0x05, // Kích thước báo cáo (5) 26

năm bit đệm bổ sung, cần thiết để đạt được một byte ::

# 0x95, 0x01, // Số lượng báo cáo (1) 28

năm bit đó chỉ được lặp lại một lần ::

# 0x81, 0x01, // Đầu vào (Cnst,Arr,Abs) 30

và lấy các giá trị Hằng số (Cnst), tức là chúng có thể bị bỏ qua. ::

# 0x05, 0x01, // Trang sử dụng (Màn hình chung) 32
    # 0x09, 0x30, // Cách sử dụng (X) 34
    # 0x09, 0x31, // Cách sử dụng (Y) 36
    # 0x09, 0x38, // Cách sử dụng (Bánh xe) 38

Chuột cũng có hai vị trí vật lý (Cách sử dụng (X), Cách sử dụng (Y))
và một bánh xe (Cách sử dụng (Bánh xe)) ::

# 0x15, 0x81, // Tối thiểu logic (-127) 40
    # 0x25, 0x7f, // Tối đa logic (127) 42

mỗi người trong số họ có thể gửi các giá trị từ -127 đến bao gồm 127 ::

# 0x75, 0x08, // Kích thước báo cáo (8) 44

được biểu thị bằng tám bit ::

# 0x95, 0x03, // Số lượng báo cáo (3) 46

và có ba trong số tám bit đó, khớp với X, Y và Wheel. ::

# 0x81, 0x06, // Đầu vào (Dữ liệu, Var, Rel) 48

Lần này các giá trị dữ liệu là Tương đối (Rel), tức là chúng đại diện cho
sự thay đổi so với báo cáo (sự kiện) đã gửi trước đó ::

# 0xc0, // Kết thúc bộ sưu tập 50
    # 0xc0, // Kết thúc bộ sưu tập 51
    #
    R: 52 05 01 09 02 a1 01 09 01 a1 00 05 09 19 01 29 03 15 00 25 01 75 01 95 03 81 02 75 05 95 01 81 01 05 01 09 30 09 31 09 38 15 81 25 7f 75 08 95 03 81 06 c0 c0
    N: thiết bị 0:0
    Tôi: 3 0001 0001


Bộ mô tả báo cáo này cho chúng ta biết rằng đầu vào chuột sẽ
được truyền bằng bốn byte: byte đầu tiên dành cho các nút (ba byte
được sử dụng, 5 bit để đệm), 3 bit cuối cùng dành cho chuột X, Y và
bánh xe thay đổi tương ứng.

Thật vậy, đối với bất kỳ sự kiện nào, chuột sẽ gửi ZZ0002ZZ có dung lượng bốn byte.
Chúng tôi có thể kiểm tra các giá trị được gửi bằng cách sử dụng ví dụ: đến ZZ0001ZZ
công cụ, từ ZZ0000ZZ:
Chuỗi byte được gửi bằng cách nhấp và nhả nút 1, rồi nút 2, rồi nút 3 là::

$ sudo ./hid-recorder /dev/hidraw1

  ....
đầu ra của giải mã ẩn
  ....

#  Button: 1 0 0 ZZ0000ZZ X: 0 ZZ0001ZZ Bánh xe: 0
  Đ: 000000.000000 4 01 00 00 00
  #  Button: 0 0 0 ZZ0002ZZ X: 0 ZZ0003ZZ Bánh xe: 0
  E: 000000.183949 4 00 00 00 00
  #  Button: 0 1 0 ZZ0004ZZ X: 0 ZZ0005ZZ Bánh xe: 0
  E: 000001.959698 4 02 00 00 00
  #  Button: 0 0 0 ZZ0006ZZ X: 0 ZZ0007ZZ Bánh xe: 0
  E: 000002.103899 4 00 00 00 00
  #  Button: 0 0 1 ZZ0008ZZ X: 0 ZZ0009ZZ Bánh xe: 0
  E: 000004.855799 4 04 00 00 00
  #  Button: 0 0 0 ZZ0010ZZ X: 0 ZZ0011ZZ Bánh xe: 0
  E: 000005.103864 4 00 00 00 00

Ví dụ này cho thấy rằng khi nhấp vào nút 2,
các byte ZZ0000ZZ được gửi và ngay sau đó
sự kiện (ZZ0001ZZ) là việc nhả nút 2 (không có nút nào
nhấn, hãy nhớ rằng các giá trị dữ liệu là ZZ0002ZZ).

Thay vào đó, nếu nhấp và giữ nút 1, sau đó nhấp và giữ nút
2, nhả nút 1 và cuối cùng nhả nút 2, các báo cáo là::

#  Button: 1 0 0 ZZ0000ZZ X: 0 ZZ0001ZZ Bánh xe: 0
  E: 000044.175830 4 01 00 00 00
  #  Button: 1 1 0 ZZ0002ZZ X: 0 ZZ0003ZZ Bánh xe: 0
  E: 000045.975997 4 03 00 00 00
  #  Button: 0 1 0 ZZ0004ZZ X: 0 ZZ0005ZZ Bánh xe: 0
  E: 000047.407930 4 02 00 00 00
  #  Button: 0 0 0 ZZ0006ZZ X: 0 ZZ0007ZZ Bánh xe: 0
  E: 000049.199919 4 00 00 00 00

trong đó với ZZ0000ZZ cả hai nút đều được nhấn và với
nút ZZ0001ZZ tiếp theo 1 được nhả ra trong khi nút 2 vẫn còn
hoạt động.

Báo cáo đầu ra, đầu vào và tính năng
---------------------------------

Các thiết bị HID có thể có Báo cáo đầu vào, như trong ví dụ về chuột, Đầu ra
Báo cáo và Báo cáo tính năng. “Đầu ra” có nghĩa là thông tin được
được gửi đến thiết bị. Ví dụ: cần điều khiển có phản hồi lực sẽ
có một số đầu ra; đèn led của bàn phím cũng cần có đầu ra.
"Đầu vào" có nghĩa là dữ liệu đến từ thiết bị.

"Tính năng" không nhằm mục đích sử dụng bởi người dùng cuối và xác định
tùy chọn cấu hình cho thiết bị. Chúng có thể được truy vấn từ máy chủ;
khi được khai báo là ZZ0000ZZ, máy chủ sẽ thay đổi chúng.


Bộ sưu tập, ID báo cáo và sự kiện Evdev
========================================

Một thiết bị duy nhất có thể nhóm dữ liệu một cách hợp lý thành các thành phần độc lập khác nhau
bộ, được gọi là ZZ0000ZZ. Bộ sưu tập có thể được lồng nhau và có
các loại bộ sưu tập khác nhau (xem thông số HID 6.2.2.6
"Bộ sưu tập, Mục kết thúc bộ sưu tập" để biết chi tiết).

Các báo cáo khác nhau được xác định bằng các phương tiện ZZ0000ZZ khác nhau
các trường, tức là một số xác định cấu trúc của ngay lập tức
báo cáo sau.
Bất cứ khi nào cần ID báo cáo, nó sẽ được truyền dưới dạng byte đầu tiên của
bất kỳ báo cáo nào. Một thiết bị chỉ có một báo cáo HID được hỗ trợ (như chuột
ví dụ ở trên) có thể bỏ qua ID báo cáo.

Hãy xem xét phần mô tả báo cáo HID sau::

05 01 09 02 A1 01 85 01 05 09 19 01 29 05 15 00
  25 01 95 05 75 01 81 02 95 01 75 03 81 01 05 01
  09 30 09 31 16 00 F8 26 FF 07 75 0C 95 02 81 06
  09 38 15 80 25 7F 75 08 95 01 81 06 05 0C 0A 38
  02 15 80 25 7F 75 08 95 01 81 06 C0 05 01 09 02
  A1 01 85 02 05 09 19 01 29 05 15 00 25 01 95 05
  75 01 81 02 95 01 75 03 81 01 05 01 09 30 09 31
  16 00 F8 26 FF 07 75 0C 95 02 81 06 09 38 15 80
  25 7F 75 08 95 01 81 06 05 0C 0A 38 02 15 80 25
  7F 75 08 95 01 81 06 C0 05 01 09 07 A1 01 85 05
  05 07 15 00 25 01 09 29 09 3E 09 4B 09 4E 09 E3
  09 E8 09 E8 09 E8 75 01 95 08 81 02 95 00 81 01
  C0 05 0C 09 01 A1 01 85 06 15 00 25 01 75 01 95
  01 09 3F 81 06 09 3F 81 06 09 3F 81 06 09 3F 81
  06 09 3F 81 06 09 3F 81 06 09 3F 81 06 09 3F 81
  06 C0 05 0C 09 01 A1 01 85 03 09 05 15 00 26 FF
  00 75 08 95 02 B1 02 C0

Sau khi phân tích nó (cố gắng tự phân tích nó bằng cách sử dụng gợi ý
công cụ!) Người ta có thể thấy rằng thiết bị này trình bày hai Ứng dụng ZZ0000ZZ
Bộ sưu tập (với các báo cáo được xác định bởi ID báo cáo 1 và 2,
tương ứng), Bộ sưu tập ứng dụng ZZ0001ZZ (có báo cáo
được xác định bởi ID báo cáo 5) và hai ứng dụng ZZ0002ZZ
Bộ sưu tập, (với ID báo cáo lần lượt là 6 và 3). Tuy nhiên, lưu ý,
rằng một thiết bị có thể có các ID báo cáo khác nhau cho cùng một Ứng dụng
Bộ sưu tập.

Dữ liệu được gửi sẽ bắt đầu bằng byte ID báo cáo và sẽ được theo sau
bằng các thông tin tương ứng. Ví dụ, dữ liệu được truyền cho
sự kiểm soát của người tiêu dùng cuối cùng::

0x05, 0x0C, // Trang sử dụng (Người tiêu dùng)
  0x09, 0x01, // Cách sử dụng (Kiểm soát của người tiêu dùng)
  0xA1, 0x01, // Bộ sưu tập (Ứng dụng)
  0x85, 0x03, // ID báo cáo (3)
  0x09, 0x05, // Cách sử dụng (Tai nghe)
  0x15, 0x00, // Tối thiểu logic (0)
  0x26, 0xFF, 0x00, // Tối đa logic (255)
  0x75, 0x08, // Kích thước báo cáo (8)
  0x95, 0x02, // Số lượng báo cáo (2)
  0xB1, 0x02, // Tính năng (Dữ liệu, Var, Abs, Không bao bọc, Tuyến tính, Trạng thái ưa thích, Không có vị trí rỗng, Không biến động)
  0xC0, // Kết thúc bộ sưu tập

sẽ có ba byte: byte đầu tiên dành cho ID báo cáo (3), hai byte tiếp theo
cho tai nghe, với hai byte (ZZ0000ZZ)
(ZZ0001ZZ), mỗi giá trị nằm trong khoảng từ 0 (ZZ0002ZZ)
đến 255 (ZZ0003ZZ).

Tất cả dữ liệu đầu vào được gửi bởi thiết bị phải được dịch sang
các sự kiện Evdev tương ứng để phần còn lại của ngăn xếp có thể
biết chuyện gì đang xảy ra, ví dụ: bit cho nút đầu tiên chuyển thành
sự kiện ZZ0000ZZ evdev và chuyển động X tương đối được dịch
vào sự kiện ZZ0001ZZ evdev".

Sự kiện
======

Trong Linux, một ZZ0000ZZ được tạo cho mỗi ZZ0001ZZ. Quay lại ví dụ về chuột và lặp lại
trình tự trong đó một người nhấp và giữ nút 1, sau đó nhấp và giữ
nút 2, nhả nút 1 và cuối cùng nhả nút 2, người ta nhận được::

$ bản ghi libinput sudo /dev/input/event1
  Bản ghi # libinput
  phiên bản: 1
  nthiết bị: 1
  libinput:
    phiên bản: "1.23.0"
    git: "không rõ"
  hệ thống:
    os: "openuse-tumbleweed:20230619"
    kernel: "6.3.7-1-mặc định"
    dmi: "dmi:bvnHP:bvrU77Ver.01.05.00:bd03/24/2022:br5.0:efr20.29:svnHP:pnHPEliteBook64514inch G9NotebookPC:pvr:rvnHP:rn89D2:rvrKBCVversion14.1D.00:cvnHP:ct10:cvr:sku5Y3J1EA#ZZ0000ZZ:"
  thiết bị:
  - nút: /dev/input/event1
    evdev:
      # Name: Chuột quang PixArt HP USB
      # ID: nhà cung cấp bus 0x3 0x3f0 sản phẩm 0x94a phiên bản 0x111
      Sự kiện # Supported:
      # Event loại 0 (EV_SYN)
      # Event loại 1 (EV_KEY)
      #   Event mã 272 (BTN_LEFT)
      #   Event mã 273 (BTN_RIGHT)
      #   Event mã 274 (BTN_MIDDLE)
      # Event loại 2 (EV_REL)
      #   Event mã 0 (REL_X)
      #   Event mã 1 (REL_Y)
      #   Event mã 8 (REL_WHEEL)
      #   Event mã 11 (REL_WHEEL_HI_RES)
      # Event loại 4 (EV_MSC)
      #   Event mã 4 (MSC_SCAN)
      # Properties:
      Tên: "Chuột quang PixArt HP USB"
      mã số: [3, 1008, 2378, 273]
      mã:
  	0: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15] # ZZ0015ZZ
  	1: [272, 273, 274] # ZZ0016ZZ
  	2: [0, 1, 8, 11] # ZZ0017ZZ
  	4: [4] # ZZ0018ZZ
      thuộc tính: []
    trốn: [
      0x05, 0x01, 0x09, 0x02, 0xa1, 0x01, 0x09, 0x01, 0xa1, 0x00, 0x05, 0x09, 0x19, 0x01, 0x29, 0x03,
      0x15, 0x00, 0x25, 0x01, 0x95, 0x08, 0x75, 0x01, 0x81, 0x02, 0x05, 0x01, 0x09, 0x30, 0x09, 0x31,
      0x09, 0x38, 0x15, 0x81, 0x25, 0x7f, 0x75, 0x08, 0x95, 0x03, 0x81, 0x06, 0xc0, 0xc0
    ]
    udev:
      thuộc tính:
      -ID_INPUT=1
      -ID_INPUT_MOUSE=1
      - LIBINPUT_DEVICE_GROUP=3/3f0/94a:usb-0000:05:00.3-2
    những điều kỳ quặc:
    sự kiện:
    # Current thời gian là 12:31:56
    - evdev:
      - [ 0, 0, 4, 4, 30] # ZZ0022ZZ / MSC_SCAN 30 (bị xáo trộn)
      - [ 0, 0, 1, 272, 1] # ZZ0024ZZ / BTN_LEFT 1
      - [ 0, 0, 0, 0, 0] # ------------ SYN_REPORT (0) ---------- +0ms
    - evdev:
      - [ 1, 207892, 4, 4, 30] # ZZ0027ZZ / MSC_SCAN 30 (bị xáo trộn)
      - [ 1, 207892, 1, 273, 1] # ZZ0029ZZ / BTN_RIGHT 1
      - [ 1, 207892, 0, 0, 0] # ------------ SYN_REPORT (0) ---------- +1207ms
    - evdev:
      - [ 2, 367823, 4, 4, 30] # ZZ0032ZZ / MSC_SCAN 30 (bị xáo trộn)
      - [ 2, 367823, 1, 272, 0] # ZZ0034ZZ / BTN_LEFT 0
      - [ 2, 367823, 0, 0, 0] # ------------ SYN_REPORT (0) ---------- +1160ms
    # Current thời gian là 12:32:00
    - evdev:
      - [ 3, 247617, 4, 4, 30] # ZZ0037ZZ / MSC_SCAN 30 (bị xáo trộn)
      - [ 3, 247617, 1, 273, 0] # ZZ0039ZZ / BTN_RIGHT 0
      - [ 3, 247617, 0, 0, 0] # ------------ SYN_REPORT (0) ---------- +880ms

Lưu ý: nếu ZZ0000ZZ không có sẵn trên hệ thống của bạn, hãy thử sử dụng
ZZ0001ZZ.

Khi một cái gì đó không hoạt động
============================

Có thể có một số lý do khiến thiết bị không hoạt động
một cách chính xác. Ví dụ

* Phần mô tả báo cáo HID do thiết bị HID cung cấp có thể sai
  bởi vì ví dụ

* nó không tuân theo tiêu chuẩn, do đó kernel
    sẽ không thể hiểu được phần mô tả báo cáo HID;
  * mô tả báo cáo HID ZZ0000ZZ thực tế là gì
    được gửi bởi thiết bị (điều này có thể được xác minh bằng cách đọc HID thô
    dữ liệu);
* bộ mô tả báo cáo HID có thể cần một số "điều kỳ quặc" (xem phần sau).

Do đó, ZZ0000ZZ có thể không được tạo
cho mỗi Bộ sưu tập Ứng dụng và/hoặc các sự kiện
có thể không phù hợp với những gì bạn mong đợi.


Quirks
------

Có một số đặc điểm đã biết của thiết bị HID mà kernel
biết cách khắc phục - những điều này được gọi là những điều kỳ quặc của HID và một danh sách những điều đó
có sẵn trong ZZ0000ZZ.

Nếu đúng như vậy thì chỉ cần thêm những điều cần thiết là đủ
trong kernel, dành cho thiết bị HID trong tầm tay. Điều này có thể được thực hiện trong tập tin
ZZ0000ZZ. Cách thực hiện phải tương đối
đơn giản sau khi nhìn vào tập tin.

Danh sách các đặc điểm hiện được xác định, từ ZZ0000ZZ, là

.. kernel-doc:: include/linux/hid.h
   :doc: HID quirks

Có thể chỉ định các quirks cho thiết bị USB trong khi tải mô-đun usbhid,
xem ZZ0000ZZ, mặc dù cách khắc phục thích hợp sẽ được đưa vào
hid-quirks.c và ZZ0001ZZ.
Xem Tài liệu/quy trình/gửi-patches.rst để biết hướng dẫn về cách
để gửi một bản vá. Quirks cho các xe buýt khác cần phải đi vào hid-quirks.c.

Sửa mô tả báo cáo HID
-----------------------------

Nếu bạn cần vá các phần mô tả báo cáo HID, cách dễ nhất là
sử dụng eBPF, như được mô tả trong Documentation/hid/hid-bpf.rst.

Về cơ bản, bạn có thể thay đổi bất kỳ byte nào của báo cáo HID gốc
mô tả. Các ví dụ trong samples/hid phải là điểm khởi đầu tốt
để biết mã của bạn, hãy xem ví dụ: ZZ0000ZZ::

SEC("fmod_ret/hid_bpf_rdesc_fixup")
  int BPF_PROG(hid_rdesc_fixup, struct hid_bpf_ctx *hctx)
  {
    ....
       data[39] = 0x31;
       data[41] = 0x30;
trả về 0;
  }

Tất nhiên điều này cũng có thể được thực hiện trong mã nguồn kernel, xem ví dụ:
ZZ0000ZZ hoặc ZZ0001ZZ một chút
tập tin phức tạp hơn.

Kiểm tra Documentation/hid/hidreport-parsing.rst nếu bạn cần bất kỳ trợ giúp nào
điều hướng hướng dẫn sử dụng HID và hiểu ý nghĩa chính xác của
số hex mô tả báo cáo HID.

Dù bạn nghĩ ra giải pháp nào, hãy nhớ **gửi
sửa lỗi cho bộ bảo trì HID** để có thể tích hợp trực tiếp vào
kernel và thiết bị HID cụ thể đó sẽ bắt đầu hoạt động trong
mọi người khác. Xem Tài liệu/quy trình/gửi-patches.rst để biết
hướng dẫn về cách thực hiện việc này.


Sửa đổi dữ liệu được truyền nhanh chóng
-----------------------------------------

Sử dụng eBPF cũng có thể sửa đổi dữ liệu được trao đổi với
thiết bị. Xem lại các ví dụ trong ZZ0000ZZ.

Một lần nữa, ZZ0000ZZ, để nó có thể được tích hợp trong
hạt nhân!

Viết driver chuyên dụng
----------------------------

Đây thực sự nên là phương sách cuối cùng của bạn.


.. rubric:: Footnotes

.. [#hidraw] read hidraw: see Documentation/hid/hidraw.rst and
  file `samples/hidraw/hid-example.c` for an example.
  The output of ``hid-example`` would be, for the same mouse::

    $ sudo ./hid-example
    Report Descriptor Size: 52
    Report Descriptor:
    5 1 9 2 a1 1 9 1 a1 0 5 9 19 1 29 3 15 0 25 1 75 1 95 3 81 2 75 5 95 1 81 1 5 1 9 30 9 31 9 38 15 81 25 7f 75 8 95 3 81 6 c0 c0

    Raw Name: PixArt USB Optical Mouse
    Raw Phys: usb-0000:05:00.4-2.3/input0
    Raw Info:
            bustype: 3 (USB)
            vendor: 0x093a
            product: 0x2510
    ...