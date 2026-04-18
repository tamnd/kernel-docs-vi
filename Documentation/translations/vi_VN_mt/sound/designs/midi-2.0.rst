.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/midi-2.0.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
MIDI 2.0 trên Linux
===================

Tổng quan
=======

MIDI 2.0 là một giao thức mở rộng để cung cấp độ phân giải cao hơn và
nhiều điều khiển tốt hơn so với MIDI 1.0 cũ.  Những thay đổi cơ bản
được giới thiệu để hỗ trợ MIDI 2.0 là:

- Hỗ trợ gói Universal MIDI (UMP)
- Hỗ trợ các tin nhắn giao thức MIDI 2.0
- Chuyển đổi trong suốt giữa UMP và luồng 1.0 byte MIDI kế thừa
- MIDI-CI cho cấu hình thuộc tính và cấu hình

UMP là định dạng chứa mới để chứa tất cả giao thức MIDI 1.0 và MIDI
Thông báo giao thức 2.0.  Không giống như luồng byte trước đây, nó là 32 bit
được căn chỉnh và mỗi tin nhắn có thể được đặt trong một gói duy nhất.  UMP có thể gửi
các sự kiện lên tới 16 "Nhóm UMP", trong đó mỗi Nhóm UMP chứa tối đa
16 kênh MIDI.

Giao thức MIDI 2.0 là giao thức mở rộng để đạt được hiệu suất cao hơn
độ phân giải và nhiều điều khiển hơn so với giao thức MIDI 1.0 cũ.

MIDI-CI là giao thức cấp cao có thể giao tiếp với thiết bị MIDI
cho các cấu hình và cấu hình linh hoạt.  Nó được thể hiện trong
dạng SysEx đặc biệt.

Đối với việc triển khai Linux, kernel hỗ trợ vận chuyển UMP và
mã hóa/giải mã các giao thức MIDI trên UMP, trong khi MIDI-CI là
được hỗ trợ trong không gian người dùng qua SysEx tiêu chuẩn.

Tính đến thời điểm viết bài này, chỉ có thiết bị USB MIDI hỗ trợ UMP và Linux
2.0 nguyên bản.  Bản thân sự hỗ trợ của UMP khá chung chung, do đó nó
có thể được sử dụng bởi các lớp vận chuyển khác, mặc dù nó có thể
cũng được triển khai theo cách khác (ví dụ như máy khách trình sắp xếp ALSA).

Quyền truy cập vào các thiết bị UMP được cung cấp theo hai cách: truy cập qua
thiết bị rawmidi và truy cập thông qua trình sắp xếp ALSA API.

Trình sắp xếp ALSA API đã được mở rộng để cho phép tải trọng các gói UMP.
Nó được phép kết nối tự do giữa trình sắp xếp MIDI 1.0 và MIDI 2.0
khách hàng và các sự kiện được chuyển đổi một cách minh bạch.


Cấu hình hạt nhân
====================

Các cấu hình mới sau đây được thêm vào để hỗ trợ MIDI 2.0:
ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ và
ZZ0004ZZ.  Cái nhìn thấy đầu tiên là
ZZ0005ZZ và khi bạn chọn nó (để đặt ZZ0006ZZ),
hỗ trợ cốt lõi cho UMP (ZZ0007ZZ) và liên kết trình sắp xếp chuỗi
(ZZ0008ZZ) sẽ được chọn tự động.

Ngoài ra, ZZ0000ZZ sẽ kích hoạt
hỗ trợ cho thiết bị MIDI thô cũ cho Điểm cuối UMP.


Thiết bị Rawmidi với USB MIDI 2.0
================================

Khi một thiết bị hỗ trợ MIDI 2.0, trình điều khiển âm thanh USB sẽ thăm dò và sử dụng
giao diện MIDI 2.0 (luôn được tìm thấy ở tập hợp 1) như
mặc định thay vì giao diện MIDI 1.0 (ở altset 0).  bạn có thể
chuyển về liên kết với giao diện MIDI 1.0 cũ bằng cách chuyển
Tùy chọn ZZ0000ZZ cho mô-đun trình điều khiển âm thanh snd-usb.

Trình điều khiển âm thanh USB cố gắng truy vấn Điểm cuối UMP và Chức năng UMP
Chặn thông tin được cung cấp kể từ UMP v1.1 và xây dựng
cấu trúc liên kết dựa trên những thông tin đó.  Khi thiết bị cũ hơn và
không trả lời các câu hỏi UMP mới, người lái xe lùi lại và
xây dựng cấu trúc liên kết dựa trên thông tin Khối thiết bị đầu cuối nhóm (GTB)
từ bộ mô tả USB.  Một số thiết bị có thể bị hỏng do
lệnh UMP bất ngờ; trong trường hợp như vậy, hãy chuyển ZZ0000ZZ
tùy chọn cho trình điều khiển âm thanh snd-usb để bỏ qua các yêu cầu UMP v1.1.

Khi thiết bị MIDI 2.0 được thăm dò, kernel sẽ tạo một rawmidi
thiết bị cho mỗi Điểm cuối UMP của thiết bị.  Tên thiết bị của nó là
ZZ0000ZZ và khác với tên thiết bị rawmidi tiêu chuẩn
ZZ0001ZZ dành cho MIDI 1.0, để tránh nhầm lẫn
các ứng dụng cũ truy cập nhầm vào thiết bị UMP.

Bạn có thể đọc và ghi dữ liệu gói UMP trực tiếp từ/đến UMP này
thiết bị rawmidi.  Ví dụ, đọc qua ZZ0000ZZ như bên dưới sẽ
hiển thị các gói UMP đến của thẻ 0 thiết bị 0 ở dạng hex
định dạng::

% hexdump -C /dev/snd/umpC0D0
  00000000 01 07 b0 20 00 07 b0 20 64 3c 90 20 64 3c 80 20 ZZ0000ZZ

Không giống như luồng 1.0 byte MIDI, UMP là gói 32 bit và kích thước
để đọc hoặc ghi thiết bị cũng được căn chỉnh theo 32bit (là 4
byte).

Các từ 32 bit trong tải trọng gói UMP luôn ở dạng gốc CPU
độ bền.  Người điều khiển phương tiện vận tải có trách nhiệm chuyển đổi từ UMP
từ/đến độ bền của hệ thống đến độ bền/byte vận chuyển được yêu cầu
đặt hàng.

Khi ZZ0000ZZ được đặt, trình điều khiển sẽ tạo
Ngoài ra còn có một thiết bị MIDI thô tiêu chuẩn khác là ZZ0001ZZ.
Điều này chứa 16 luồng con và mỗi luồng con tương ứng với một
(dựa trên 0) Nhóm UMP.  Các ứng dụng kế thừa có thể truy cập vào các ứng dụng được chỉ định
nhóm thông qua mỗi luồng con ở định dạng luồng 1.0 byte MIDI.  Với
ALSA rawmidi API, bạn có thể mở luồng con tùy ý, trong khi chỉ cần
việc mở ZZ0002ZZ sẽ kết thúc bằng việc mở cái đầu tiên
dòng phụ.

Mỗi Điểm cuối UMP có thể cung cấp thông tin bổ sung, được xây dựng
từ thông tin được yêu cầu qua tin nhắn luồng UMP 1.1 hoặc USB MIDI
mô tả 2.0.  Và Điểm cuối UMP có thể chứa một hoặc nhiều UMP
Các khối, trong đó Khối UMP là một bản tóm tắt được giới thiệu trong ALSA UMP
triển khai để đại diện cho các liên kết giữa các Nhóm UMP.  UMP
Khối tương ứng với Khối chức năng trong thông số kỹ thuật UMP 1.1.  Khi nào
Thông tin Khối chức năng UMP 1.1 không có sẵn, nó đã được điền
một phần từ Khối thiết bị đầu cuối nhóm (GTB) như được xác định trong USB MIDI 2.0
thông số kỹ thuật.

Thông tin về Điểm cuối UMP và Khối UMP được tìm thấy trong quy trình
tập tin ZZ0000ZZ.  Ví dụ::

% mèo /proc/asound/card1/midi0
  ProtoZOA MIDI
  
Loại: UMP
  Tên EP: ProtoZOA
  ID sản phẩm EP: ABCD12345678
  Phiên bản UMP: 0x0000
  Giới hạn giao thức: 0x00000100
  Giao thức: 0x00000100
  Số khối: 3
  
Khối 0 (ProtoZOA Chính)
    Hướng: hai chiều
    Đang hoạt động: Có
    Nhóm: 1-1
    Là MIDI1: Không

Khối 1 (ProtoZOA Ext IN)
    Hướng: đầu ra
    Đang hoạt động: Có
    Nhóm: 2-2
    Là MIDI1: Có (Tốc độ thấp)
  ....

Lưu ý rằng trường ZZ0000ZZ hiển thị trong tệp Proc ở trên cho biết
Số nhóm UMP dựa trên 1 (từ đến).

Những thông tin bổ sung về Điểm cuối UMP và Khối UMP có thể được
thu được thông qua ioctls ZZ0000ZZ mới và
ZZ0001ZZ, tương ứng.

Tên rawmidi và tên Điểm cuối UMP thường giống hệt nhau và
trong trường hợp USB MIDI, nó được lấy từ ZZ0000ZZ của
bộ mô tả giao diện USB MIDI tương ứng.  Nếu nó không được cung cấp,
nó được sao chép từ ZZ0001ZZ của bộ mô tả thiết bị USB dưới dạng
dự phòng.

ID sản phẩm điểm cuối là một trường chuỗi và được coi là duy nhất.
Nó được sao chép từ ZZ0000ZZ của thiết bị cho USB MIDI.

Các khả năng của giao thức và các bit giao thức thực tế được xác định trong
ZZ0000ZZ.


Bộ tuần tự ALSA với USB MIDI 2.0
================================

Ngoài các giao diện rawmidi, giao diện trình sắp xếp ALSA
cũng hỗ trợ thiết bị UMP MIDI 2.0 mới.  Bây giờ, mỗi trình sắp xếp ALSA
khách hàng có thể đặt phiên bản MIDI (0, 1 hoặc 2) để tuyên bố chính nó là
hoặc là thiết bị cũ, UMP MIDI 1.0 hoặc UMP MIDI 2.0 tương ứng.
Ứng dụng khách kế thừa đầu tiên là ứng dụng gửi/nhận dữ liệu cũ
sự kiện trình tự sắp xếp như cũ.  Trong khi đó, khách hàng UMP MIDI 1.0 và 2.0 gửi
và nhận được trong bản ghi sự kiện mở rộng cho UMP.  Phiên bản MIDI là
được thấy trong trường ZZ0000ZZ mới của ZZ0001ZZ.

Gói UMP có thể được gửi/nhận trong sự kiện trình tự sắp xếp được nhúng bởi
chỉ định bit cờ sự kiện mới ZZ0000ZZ.  Khi điều này
cờ được đặt, sự kiện có tải trọng dữ liệu 16 byte (128 bit) để giữ
gói UMP.  Nếu không có cờ bit ZZ0001ZZ, sự kiện
được coi như một sự kiện kế thừa (với dữ liệu tối đa 12 byte
tải trọng).

Với bộ cờ ZZ0000ZZ, trường loại của trình sắp xếp UMP
sự kiện bị bỏ qua (nhưng nó phải được đặt thành 0 làm mặc định).

Loại của từng khách hàng có thể được nhìn thấy trong ZZ0000ZZ.
Ví dụ::

% mèo /proc/asound/seq/clients
  Thông tin khách hàng
    khách hàng hiện tại :3
  ....
Khách hàng 14: "Midi Through" [Kernel Legacy]
    Cổng 0 : "Midi qua cổng-0" (RWe-)
  Khách hàng 20: "ProtoZOA" [Hạt nhân UMP MIDI1]
    Điểm cuối UMP: ProtoZOA
    UMP Khối 0: ProtoZOA Chính [Hoạt động]
      Nhóm: 1-1
    UMP Khối 1: ProtoZOA Ext IN [Hoạt động]
      Nhóm: 2-2
    UMP Khối 2: ProtoZOA Ext OUT [Hoạt động]
      Nhóm: 3-3
    Cổng 0 : "MIDI 2.0" (RWeX) [Vào/Ra]
    Cổng 1 : "ProtoZOA Main" (RWeX) [Vào/Ra]
    Cổng 2 : "ProtoZOA Ext IN" (-We-) [Out]
    Cổng 3 : "ProtoZOA Ext OUT" (R-e-) [In]

Tại đây bạn có thể tìm thấy hai loại máy khách kernel, "Legacy" cho máy khách 14,
và "UMP MIDI1" cho máy khách 20, là thiết bị USB MIDI 2.0.
Máy khách USB MIDI 2.0 luôn cung cấp cổng 0 là "MIDI 2.0" và
các cổng còn lại từ 1 cho mỗi Nhóm UMP (ví dụ: cổng 1 cho Nhóm 1).
Trong ví dụ này, thiết bị có ba nhóm hoạt động (Main, Ext IN và
Ext OUT) và chúng được hiển thị dưới dạng cổng tuần tự từ 1 đến 3.
Cổng "MIDI 2.0" dành cho Điểm cuối UMP và điểm khác biệt của nó so với
các cổng khác của Nhóm UMP là cổng Điểm cuối UMP gửi các sự kiện từ
tất cả các cổng trên thiết bị ("bắt tất cả"), trong khi mỗi cổng của Nhóm UMP
chỉ gửi các sự kiện từ Nhóm UMP đã cho.
Ngoài ra, các tin nhắn không nhóm UMP (chẳng hạn như loại tin nhắn UMP 0x0f) là
chỉ được gửi đến cổng Điểm cuối UMP.

Lưu ý rằng, mặc dù mỗi máy khách trình sắp xếp UMP thường tạo 16
cổng, những cổng không thuộc về bất kỳ Khối UMP nào (hoặc thuộc về
đến Khối UMP không hoạt động) được đánh dấu là không hoạt động và chúng không xuất hiện
trong các đầu ra của quá trình.  Trong ví dụ trên, các cổng tuần tự từ 4
đến 16 có mặt nhưng không được hiển thị ở đó.

Tệp Proc ở trên cũng hiển thị thông tin Khối UMP.  giống nhau
mục (nhưng với thông tin chi tiết hơn) được tìm thấy trong rawmidi
đầu ra của quá trình.

Khi máy khách được kết nối giữa các phiên bản MIDI khác nhau, các sự kiện
được dịch tự động tùy thuộc vào phiên bản của khách hàng, không phải
chỉ giữa loại cũ và loại UMP MIDI 1.0/2.0 mà còn
giữa các loại UMP MIDI 1.0 và 2.0.  Ví dụ như chạy
Chương trình ZZ0000ZZ trên cổng chính ProtoZOA ở chế độ cũ sẽ
cung cấp cho bạn đầu ra như::

% aseqdump -p 20:1
  Đang chờ dữ liệu. Nhấn Ctrl+C để kết thúc.
  Dữ liệu sự kiện nguồn
   20:1 nốt 0, nốt 60, vận tốc 100
   20:1 Note off 0, note 60, vận tốc 100
   20:1 Thay đổi điều khiển 0, bộ điều khiển 11, giá trị 4

Khi bạn chạy ZZ0000ZZ ở chế độ MIDI 2.0, nó sẽ nhận được tín hiệu cao
dữ liệu chính xác như::

% aseqdump -u 2 -p 20:1
  Đang chờ dữ liệu. Nhấn Ctrl+C để kết thúc.
  Dữ liệu sự kiện nguồn
   20:1 Note về 0, note 60, vận tốc 0xc924, attr type = 0, data = 0x0
   20:1 Ghi chú tắt 0, ghi chú 60, vận tốc 0xc924, loại attr = 0, dữ liệu = 0x0
   20:1 Thay đổi điều khiển 0, bộ điều khiển 11, giá trị 0x2000000

trong khi dữ liệu được tự động chuyển đổi bởi lõi trình tự ALSA.


Phần mở rộng Rawmidi API
======================

* Thông tin điểm cuối UMP bổ sung có thể được lấy thông qua
  ioctl ZZ0000ZZ.  Nó chứa các liên kết
  số thẻ và thiết bị, cờ bit, giao thức, số lượng
  Khối UMP, chuỗi tên của điểm cuối, v.v.

Các giao thức được chỉ định trong hai trường, khả năng của giao thức
  và giao thức hiện tại.  Cả hai đều chứa các cờ bit chỉ định
  Phiên bản giao thức MIDI (ZZ0000ZZ hoặc
  ZZ0001ZZ) ở byte trên và jitter
  dấu thời gian giảm (ZZ0002ZZ và
  ZZ0003ZZ) ở byte thấp hơn.

Điểm cuối UMP có thể chứa tối đa 32 Khối UMP và số lượng
  các khối hiện được chỉ định được hiển thị trong thông tin Điểm cuối.

* Mỗi thông tin Khối UMP có thể được lấy thông qua một ioctl mới khác
  ZZ0000ZZ.  Số ID khối (dựa trên 0) phải
  được chuyển cho khối để truy vấn.  Dữ liệu nhận được chứa
  liên kết hướng của khối, ID nhóm liên kết đầu tiên
  (dựa trên 0) và số nhóm, chuỗi tên của khối,
  v.v.

Hướng là ZZ0000ZZ,
  ZZ0001ZZ hoặc ZZ0002ZZ.

* Đối với thiết bị hỗ trợ UMP v1.1, giao thức UMP MIDI có thể
  được chuyển qua thông báo "Yêu cầu cấu hình luồng" (UMP loại 0x0f,
  trạng thái 0x05).  Khi lõi UMP nhận được thông báo như vậy, nó sẽ cập nhật
  Thông tin UMP EP và các máy khách trình sắp xếp tương ứng.

* Số thiết bị rawmidi cũ được tìm thấy trong ZZ0000ZZ mới
  trường thông tin rawmidi.
  Mặt khác, số thiết bị rawmidi UMP được tìm thấy trong
  Trường ZZ0001ZZ của thông tin rawmidi cũ cũng vậy.

* Mỗi luồng con của rawmidi kế thừa có thể được bật / tắt
  động tùy thuộc vào trạng thái UMP FB.
  Khi luồng con được chọn không hoạt động, nó được biểu thị bằng bit
  0x10 (ZZ0000ZZ) trong trường ZZ0001ZZ của
  thông tin rawmidi kế thừa.


Kiểm soát tiện ích mở rộng API
======================

* ioctl ZZ0000ZZ mới được giới thiệu cho
  truy vấn thiết bị rawmidi UMP tiếp theo, trong khi ioctl hiện có
  ZZ0001ZZ chỉ truy vấn di sản
  thiết bị rawmidi.

Để cài đặt thiết bị con (số luồng phụ) sẽ được mở, hãy sử dụng
  ioctl ZZ0000ZZ như bình thường
  rawmidi.

* Hai ioctls mới ZZ0000ZZ và
  ZZ0001ZZ cung cấp Điểm cuối UMP và UMP
  Chặn thông tin của thiết bị UMP được chỉ định thông qua điều khiển ALSA API
  mà không cần mở thiết bị rawmidi thực tế (UMP).
  Trường ZZ0002ZZ bị bỏ qua khi yêu cầu, luôn gắn với thẻ
  của giao diện điều khiển.


Phần mở rộng trình tự API
========================

* Trường ZZ0000ZZ được thêm vào ZZ0001ZZ để biểu thị
  phiên bản MIDI hiện tại (0, 1 hoặc 2) của mỗi khách hàng.
  Khi ZZ0002ZZ là 1 hoặc 2, căn chỉnh đọc từ UMP
  máy khách trình sắp xếp chuỗi cũng được thay đổi từ 28 byte trước đây thành 32
  byte cho tải trọng mở rộng.  Kích thước căn chỉnh cho văn bản
  không thay đổi nhưng quy mô của mỗi sự kiện có thể khác nhau tùy thuộc vào sự kiện mới
  cờ bit bên dưới.

* Bit cờ ZZ0000ZZ được thêm vào cho mỗi sự kiện của trình sắp xếp thứ tự
  cờ.  Khi cờ bit này được đặt, sự kiện tuần tự sẽ được mở rộng
  để có tải trọng lớn hơn 16 byte thay vì 12 byte cũ
  byte và sự kiện chứa gói UMP trong tải trọng.

* Bit loại cổng trình sắp xếp mới (ZZ0000ZZ)
  cho biết cổng có khả năng UMP.

* Các cổng của bộ tuần tự có các bit khả năng mới để biểu thị
  cổng không hoạt động (ZZ0000ZZ) và Điểm cuối UMP
  cổng (ZZ0001ZZ).

* Việc chuyển đổi sự kiện của các máy khách trình sắp xếp ALSA có thể bị chặn
  bit bộ lọc mới ZZ0000ZZ được đặt thành thông tin khách hàng.
  Ví dụ: máy khách chuyển qua kernel (ZZ0001ZZ) đặt
  cờ này trong nội bộ.

* Thông tin cổng thu được trường mới ZZ0000ZZ để biểu thị
  hướng của cổng (ZZ0001ZZ,
  ZZ0002ZZ hoặc ZZ0003ZZ).

* Một trường bổ sung khác cho thông tin cổng là ZZ0000ZZ
  trong đó chỉ định Số nhóm UMP được liên kết (dựa trên 1).
  Khi nó khác 0, trường nhóm UMP trong gói UMP được cập nhật
  khi gửi đến nhóm được chỉ định (được sửa thành dựa trên 0).
  Mỗi cổng trình sắp xếp chuỗi có nhiệm vụ đặt trường này nếu đó là cổng
  cụ thể cho một nhóm UMP nhất định.

* Mỗi khách hàng có thể đặt bộ lọc sự kiện bổ sung cho Nhóm UMP trong
  Bản đồ bit ZZ0000ZZ.  Bộ lọc bao gồm bitmap dựa trên 1
  Số nhóm.  Ví dụ: khi bit 1 được đặt, tin nhắn từ
  Nhóm 1 (tức là nhóm đầu tiên) được lọc và không được phân phối.
  Bit 0 được sử dụng để lọc các tin nhắn không nhóm UMP.

* Hai ioctls mới được thêm vào cho các máy khách có khả năng UMP:
  ZZ0000ZZ và
  ZZ0001ZZ.  Chúng được sử dụng để lấy và thiết lập
  dữ liệu ZZ0002ZZ hoặc ZZ0003ZZ
  được liên kết với máy khách trình sắp xếp thứ tự.  Trình điều khiển USB MIDI cung cấp
  những thông tin đó từ rawmidi UMP cơ bản, trong khi
  ứng dụng khách trong không gian người dùng có thể cung cấp dữ liệu của riêng mình thông qua ZZ0004ZZ ioctl.
  Đối với dữ liệu Điểm cuối, chuyển 0 vào trường ZZ0005ZZ, trong khi đối với Khối
  dữ liệu, chuyển số khối + 1 vào trường ZZ0006ZZ.
  Việc đặt dữ liệu cho máy khách kernel sẽ dẫn đến lỗi.

* Với UMP 1.1, thông tin Khối chức năng có thể được thay đổi
  một cách năng động.  Khi nhận được bản cập nhật của Khối chức năng từ
  thiết bị, lõi trình sắp xếp ALSA thay đổi cổng trình sắp xếp tương ứng
  tên và thuộc tính tương ứng, đồng thời thông báo những thay đổi thông qua
  thông báo tới cổng hệ thống trình sắp xếp ALSA, tương tự như
  thông báo thay đổi cổng thông thường.

* Có hai loại sự kiện mở rộng để thông báo Điểm cuối UMP và
  Khối chức năng thay đổi thông qua cổng thông báo của hệ thống:
  loại 68 (ZZ0000ZZ) và loại 69
  (ZZ0001ZZ). Họ lấy loại mới,
  ZZ0002ZZ trong tải trọng, cho biết số máy khách
  và số FB được thay đổi.


Trình điều khiển chức năng tiện ích MIDI2 USB
================================

Hạt nhân mới nhất hỗ trợ tiện ích USB MIDI 2.0
trình điều khiển chức năng, có thể được sử dụng để tạo mẫu và gỡ lỗi MIDI
tính năng 2.0.

ZZ0000ZZ, ZZ0001ZZ và
ZZ0002ZZ cần được kích hoạt cho tiện ích MIDI2
người lái xe.

Ngoài ra, để sử dụng trình điều khiển tiện ích, bạn cần có trình điều khiển UDC đang hoạt động.
Trong ví dụ bên dưới, chúng tôi sử dụng trình điều khiển ZZ0000ZZ (được bật qua
ZZ0001ZZ) có sẵn trên PC và VM để gỡ lỗi
mục đích.  Có các trình điều khiển UDC khác tùy thuộc vào nền tảng và
thay vào đó, chúng cũng có thể được sử dụng cho một thiết bị thực.

Đầu tiên, trên hệ thống chạy tiện ích, hãy tải mô-đun ZZ0000ZZ::

% modprobe libcomposite

và bạn sẽ có thư mục con ZZ0000ZZ trong không gian configfs
(thường là ZZ0001ZZ trên hệ điều hành hiện đại).  Sau đó tạo một tiện ích
instance và thêm cấu hình ở đó, ví dụ::

% cd /sys/kernel/config
  % mkdir usb_gadget/g1

% cd usb_gadget/g1
  % cấu hình mkdir/c.1
  % hàm mkdir/midi2.usb0

% echo 0x0004 > idProduct
  % echo 0x17b3 > idVendor
  % chuỗi mkdir/0x409
  % echo "Doanh nghiệp ACME" > strings/0x409/nhà sản xuất
  % echo "ACMESynth" > chuỗi/0x409/sản phẩm
  % echo "ABCD12345" > chuỗi/0x409/số sê-ri

% mkdir config/c.1/strings/0x409
  % echo "Monosynth" > configs/c.1/strings/0x409/configuration
  % echo 120 > configs/c.1/MaxPower

Tại thời điểm này, phải có thư mục con ZZ0000ZZ và đó là thư mục con
cấu hình cho Điểm cuối UMP.  Bạn có thể điền vào Điểm cuối
thông tin như::

% echo "ACMESynth" > hàm/midi2.usb0/iface_name
  % echo "ACMESynth" > hàm/midi2.usb0/ep.0/ep_name
  % echo "ABCD12345" > hàm/midi2.usb0/ep.0/product_id
  % echo 0x0123 > hàm/midi2.usb0/ep.0/family
  % echo 0x4567 > hàm/midi2.usb0/ep.0/model
  % echo 0x123456 > hàm/midi2.usb0/ep.0/nhà sản xuất
  % echo 0x12345678 > hàm/midi2.usb0/ep.0/sw_revision

Giao thức MIDI mặc định có thể được đặt 1 hoặc 2::

% echo 2 > hàm/midi2.usb0/ep.0/giao thức

Và, bạn có thể tìm thấy thư mục con ZZ0000ZZ trong Điểm cuối này
thư mục con.  Điều này xác định thông tin Khối chức năng::

% echo "Monosynth" > hàm/midi2.usb0/ep.0/block.0/name
  % echo 0 > hàm/midi2.usb0/ep.0/block.0/first_group
  % echo 1 > hàm/midi2.usb0/ep.0/block.0/num_groups

Cuối cùng, liên kết cấu hình và kích hoạt nó ::

% ln -s hàm/midi2.usb0 configs/c.1
  % echo dummy_udc.0 > UDC

trong đó ZZ0000ZZ là một trường hợp ví dụ và nó khác nhau tùy thuộc vào
hệ thống.  Bạn có thể tìm thấy các phiên bản UDC trong ZZ0001ZZ và chuyển
thay vào đó, tên được tìm thấy::

% ls /sys/class/udc
  dummy_udc.0

Bây giờ, thiết bị tiện ích MIDI 2.0 đã được bật và máy chủ tiện ích
tạo một phiên bản card âm thanh mới chứa thiết bị rawmidi UMP bằng cách
Trình điều khiển ZZ0000ZZ::

% mèo /proc/asound/cards
  ....
1 [Tiện ích]: f_midi2 - Tiện ích MIDI 2.0
                       Tiện ích MIDI 2.0

Và trên máy chủ được kết nối, một thẻ tương tự cũng sẽ xuất hiện, nhưng với
tên thẻ và thiết bị được cung cấp trong cấu hình ở trên::

% mèo /proc/asound/cards
  ....
2 [ACMESynth ]: USB-Audio - ACMESynth
                       ACME Enterprises ACMESynth tại usb-dummy_hcd.0-1, tốc độ cao

Bạn có thể phát tệp MIDI ở phía tiện ích::

% aplaymidi -p 20:1 to_host.mid

và điều này sẽ xuất hiện dưới dạng đầu vào từ thiết bị MIDI trên thiết bị được kết nối
chủ nhà::

% aseqdump -p 20:0 -u 2

Ngược lại, quá trình phát lại trên máy chủ được kết nối sẽ hoạt động như một đầu vào trên
tiện ích này cũng vậy.

Mỗi Khối chức năng có thể có hướng và gợi ý UI khác nhau,
được chỉ định thông qua các thuộc tính ZZ0000ZZ và ZZ0001ZZ.
Việc chuyển ZZ0002ZZ chỉ dành cho đầu vào, ZZ0003ZZ chỉ dành cho đầu ra và ZZ0004ZZ dành cho
hai chiều (giá trị mặc định).  Ví dụ::

% echo 2 > hàm/midi2.usb0/ep.0/block.0/direction
  % echo 2 > hàm/midi2.usb0/ep.0/block.0/ui_hint

Khi bạn cần nhiều Khối chức năng, bạn có thể tạo
thư mục con ZZ0000ZZ, ZZ0001ZZ, v.v. một cách linh hoạt và định cấu hình
chúng trong quy trình cấu hình ở trên trước khi liên kết.
Ví dụ: để tạo Khối chức năng thứ hai cho bàn phím ::

% hàm mkdir/midi2.usb0/ep.0/block.1
  % echo "Bàn phím" > hàm/midi2.usb0/ep.0/block.1/name
  % echo 1 > hàm/midi2.usb0/ep.0/block.1/first_group
  % echo 1 > hàm/midi2.usb0/ep.0/block.1/num_groups
  % echo 1 > hàm/midi2.usb0/ep.0/block.1/direction
  % echo 1 > hàm/midi2.usb0/ep.0/block.1/ui_hint

Các thư mục con ZZ0000ZZ cũng có thể được loại bỏ một cách linh hoạt (ngoại trừ
đối với ZZ0001ZZ liên tục).

Để gán Khối chức năng cho I/O MIDI 1.0, hãy thiết lập trong ZZ0000ZZ
thuộc tính.  1 dành cho MIDI 1.0 và 2 dành cho MIDI 1.0 với tốc độ thấp
kết nối::

% echo 2 > hàm/midi2.usb0/ep.0/block.1/is_midi1

Để vô hiệu hóa việc xử lý tin nhắn Luồng UMP trong tiện ích
trình điều khiển, chuyển thuộc tính ZZ0000ZZ sang ZZ0001ZZ trong cấu hình cấp cao nhất::

% echo 0 > hàm/midi2.usb0/process_ump

Giao diện MIDI 1.0 ở altset 0 được hỗ trợ bởi trình điều khiển tiện ích,
quá.  Khi máy chủ được kết nối chọn giao diện MIDI 1.0,
I/O UMP trên tiện ích được dịch từ/sang các gói USB MIDI 1.0
tương ứng trong khi trình điều khiển tiện ích tiếp tục liên lạc với
không gian người dùng trên UMP rawmidi.

Các cổng MIDI 1.0 được thiết lập từ cấu hình trong mỗi Khối chức năng.
Ví dụ::

% echo 0 > hàm/midi2.usb0/ep.0/block.0/midi1_first_group
  % echo 1 > hàm/midi2.usb0/ep.0/block.0/midi1_num_groups

Cấu hình ở trên sẽ kích hoạt Nhóm 1 (chỉ số 0) cho MIDI
Giao diện 1.0.  Lưu ý rằng những nhóm đó phải nằm trong nhóm được xác định
cho chính Khối chức năng.

Trình điều khiển tiện ích cũng hỗ trợ nhiều Điểm cuối UMP.
Tương tự như Khối chức năng, bạn có thể tạo thư mục con mới
ZZ0000ZZ (nhưng trong cấu hình cấp cao nhất của thẻ) để bật Điểm cuối mới::

% hàm mkdir/midi2.usb0/ep.1

và tạo Khối chức năng mới ở đó.  Ví dụ: để tạo 4
Các nhóm dành cho Khối chức năng của Điểm cuối mới này::

% hàm mkdir/midi2.usb0/ep.1/block.0
  % echo 4 > hàm/midi2.usb0/ep.1/block.0/num_groups

Bây giờ, bạn sẽ có tổng cộng 4 thiết bị rawmidi: hai thiết bị đầu tiên là UMP
thiết bị rawmidi cho Điểm cuối 0 và Điểm cuối 1 và hai thiết bị khác dành cho Điểm cuối
các thiết bị rawmidi MIDI 1.0 kế thừa tương ứng với cả EP 0 và EP 1.

Cài đặt thay thế hiện tại trên tiện ích có thể được thông báo thông qua điều khiển
phần tử "Chế độ hoạt động" với iface ZZ0000ZZ.  ví dụ. bạn có thể đọc nó
thông qua chương trình ZZ0001ZZ chạy trên máy chủ tiện ích như::

% amixer -c1 cget iface=RAWMIDI,name='Chế độ hoạt động'
  ; type=INTEGER,access=r--v----,values=1,min=0,max=2,step=0
  : giá trị=2

Giá trị (hiển thị ở dòng trả về thứ hai với ZZ0000ZZ)
biểu thị 1 cho MIDI 1.0 (altset 0), 2 cho MIDI 2.0 (altset 1) và 0
để không đặt.

Hiện tại, không thể thay đổi cấu hình sau khi liên kết.
