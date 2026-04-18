.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/BusLogic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================================
Trình điều khiển BusLogic MultiMaster và FlashPoint SCSI cho Linux
==================================================================

Phiên bản 2.0.15 cho Linux 2.0

Phiên bản 2.1.15 cho Linux 2.1

PRODUCTION RELEASE

17 tháng 8 năm 1998

Leonard N. Zubkoff

Bồ công anh kỹ thuật số

lnz@dandelion.com

Bản quyền 1995-1998 của Leonard N. Zubkoff <lnz@dandelion.com>


Giới thiệu
============

BusLogic, Inc. đã thiết kế và sản xuất nhiều loại SCSI hiệu suất cao
bộ điều hợp máy chủ chia sẻ giao diện lập trình chung trên nhiều nền tảng khác nhau
bộ sưu tập kiến trúc xe buýt nhờ công nghệ MultiMaster ASIC của họ.
BusLogic được Mylex Corporation mua lại vào tháng 2 năm 1996, nhưng các sản phẩm
được trình điều khiển này hỗ trợ có nguồn gốc dưới tên BusLogic và do đó tên đó là
được giữ lại trong mã nguồn và tài liệu.

Trình điều khiển này hỗ trợ tất cả các Bộ điều hợp máy chủ BusLogic MultiMaster hiện có và sẽ
hỗ trợ mọi thiết kế MultiMaster trong tương lai với ít hoặc không cần sửa đổi.  Thêm
gần đây, BusLogic đã giới thiệu Bộ điều hợp máy chủ FlashPoint, ít hơn
tốn kém và dựa vào máy chủ CPU, thay vì bao gồm bộ xử lý tích hợp.
Mặc dù không có CPU tích hợp, Bộ điều hợp máy chủ FlashPoint hoạt động rất tốt.
tốt và có độ trễ lệnh rất thấp.  BusLogic gần đây đã cung cấp cho tôi
Bộ công cụ dành cho nhà phát triển trình điều khiển FlashPoint, bao gồm tài liệu và miễn phí
mã nguồn có thể phân phối lại cho Trình quản lý FlashPoint SCCB.  Trình quản lý SCCB
là thư viện mã chạy trên máy chủ CPU và thực hiện các chức năng
tương tự như phần sụn trên Bộ điều hợp máy chủ MultiMaster.  Nhờ họ
đã cung cấp Trình quản lý SCCB, trình điều khiển này hiện hỗ trợ Máy chủ FlashPoint
Bộ điều hợp là tốt.

Mục tiêu chính của tôi khi viết trình điều khiển BusLogic hoàn toàn mới này cho Linux là
để đạt được hiệu suất tối đa mà Bộ điều hợp máy chủ BusLogic SCSI và các bộ điều hợp hiện đại
Các thiết bị ngoại vi SCSI có khả năng cung cấp trình điều khiển mạnh mẽ có thể
được phụ thuộc vào các ứng dụng quan trọng với nhiệm vụ hiệu suất cao.  Tất cả
các tính năng hiệu suất chính có thể được cấu hình từ lệnh nhân Linux
dòng hoặc tại thời điểm khởi tạo mô-đun, cho phép cài đặt riêng lẻ
điều chỉnh hiệu suất trình điều khiển và phục hồi lỗi theo nhu cầu cụ thể của họ.

Thông tin mới nhất về việc hỗ trợ Linux cho Bộ điều hợp máy chủ BusLogic SCSI, như
cũng như bản phát hành mới nhất của trình điều khiển này và phần sụn mới nhất cho
BT-948/958/958D, sẽ luôn có sẵn trên Trang chủ Linux của tôi tại URL
"ZZ0000ZZ

Báo cáo lỗi phải được gửi qua thư điện tử tới "lnz@dandelion.com".  làm ơn
kèm theo báo cáo lỗi các thông báo cấu hình đầy đủ được báo cáo bởi
trình điều khiển và hệ thống con SCSI khi khởi động, cùng với mọi thông báo hệ thống tiếp theo
liên quan đến hoạt động của SCSI và mô tả chi tiết về hệ thống của bạn
cấu hình phần cứng.

Mylex là một công ty tuyệt vời để hợp tác và tôi đặc biệt giới thiệu họ
sản phẩm cho cộng đồng Linux.  Vào tháng 11 năm 1995, tôi được mời làm việc
cơ hội trở thành trang web thử nghiệm beta cho sản phẩm MultiMaster mới nhất của họ,
Bộ điều hợp máy chủ BT-948 PCI Ultra SCSI và sau đó lại dành cho BT-958 PCI Wide
Bộ điều hợp máy chủ Ultra SCSI vào tháng 1 năm 1996. Điều này mang lại lợi ích chung kể từ
Mylex đã nhận được bằng cấp và loại bài kiểm tra mà nhóm thử nghiệm của họ không thể làm được
dễ dàng đạt được và cộng đồng Linux có sẵn máy chủ hiệu suất cao
các bộ điều hợp đã được thử nghiệm kỹ lưỡng với Linux ngay cả trước khi được đưa lên
thị trường.  Mối quan hệ này cũng đã cho tôi cơ hội được tiếp xúc
trực tiếp với nhân viên kỹ thuật của họ, để hiểu thêm về nội bộ
hoạt động của sản phẩm và từ đó giáo dục họ về nhu cầu và
tiềm năng của cộng đồng Linux.

Gần đây hơn, Mylex đã tái khẳng định sự quan tâm của công ty trong việc hỗ trợ
Cộng đồng Linux và hiện tôi đang làm việc trên trình điều khiển Linux cho DAC960 PCI RAID
Bộ điều khiển.  Sự quan tâm và hỗ trợ của Mylex được đánh giá rất cao.

Không giống như một số nhà cung cấp khác, nếu bạn liên hệ với bộ phận Hỗ trợ Kỹ thuật của Mylex bằng
vấn đề và đang chạy Linux, họ sẽ không cho bạn biết rằng việc bạn sử dụng phần mềm của họ
sản phẩm không được hỗ trợ.  Tài liệu tiếp thị sản phẩm mới nhất của họ thậm chí còn nêu rõ
"Bộ điều hợp máy chủ Mylex SCSI tương thích với tất cả các hệ điều hành chính
bao gồm: ... Linux ...".

Tập đoàn Mylex có trụ sở tại 34551 Ardenwood Blvd., Fremont, California
94555, USA và có thể liên lạc theo số 510/796-6100 hoặc trên World Wide Web tại
ZZ0000ZZ Mylex HBA Hỗ trợ kỹ thuật có thể liên hệ bằng điện tử
gửi thư tại techsup@mylex.com, bằng Thoại theo số 510/608-2400 hoặc bằng FAX theo số 510/745-7715.
Thông tin liên hệ của các văn phòng ở Châu Âu và Nhật Bản có sẵn trên Web
trang web.


Tính năng trình điều khiển
==========================

Báo cáo và kiểm tra cấu hình
-----------------------------------

Trong quá trình khởi tạo hệ thống, trình điều khiển sẽ báo cáo rộng rãi về máy chủ
  cấu hình phần cứng bộ điều hợp, bao gồm các tham số truyền đồng bộ
  được yêu cầu và đàm phán với từng thiết bị mục tiêu.  Cài đặt AutoSCSI cho
  Đàm phán đồng bộ, đàm phán rộng và ngắt kết nối/kết nối lại là
  được báo cáo cho từng thiết bị mục tiêu, cũng như trạng thái Xếp hàng được gắn thẻ.
  Nếu cài đặt tương tự có hiệu lực cho tất cả các thiết bị mục tiêu thì một từ duy nhất
  hoặc cụm từ được sử dụng; mặt khác, một lá thư sẽ được cung cấp cho mỗi thiết bị mục tiêu để
  cho biết trạng thái cá nhân.  Các ví dụ sau
  nên làm rõ định dạng báo cáo này:

Đàm phán đồng bộ: Ultra

Đàm phán đồng bộ được kích hoạt cho tất cả các thiết bị mục tiêu và máy chủ
      bộ điều hợp sẽ cố gắng thương lượng để có tốc độ truyền tải lớn là 20,0/giây.

Đàm phán đồng bộ: Nhanh chóng

Đàm phán đồng bộ được kích hoạt cho tất cả các thiết bị mục tiêu và máy chủ
      bộ điều hợp sẽ cố gắng đàm phán để đạt được tốc độ truyền 10,0 mega/giây.

Đàm phán đồng bộ: Chậm

Đàm phán đồng bộ được kích hoạt cho tất cả các thiết bị mục tiêu và máy chủ
      bộ điều hợp sẽ cố gắng thương lượng để có tốc độ truyền tải lớn là 5,0 mega/giây.

Đàm phán đồng bộ: Đã tắt

Đàm phán đồng bộ bị vô hiệu hóa và tất cả các thiết bị mục tiêu bị giới hạn ở
      hoạt động không đồng bộ.

Đàm phán đồng bộ: UFSNUUU#ZZ0001ZZ

Đã bật đàm phán đồng bộ với Tốc độ cực cao cho các thiết bị mục tiêu 0
      và 4 đến 15, tới Tốc độ nhanh cho thiết bị mục tiêu 1, tới Tốc độ chậm cho
      thiết bị đích 2 và không được phép nhắm mục tiêu thiết bị 3. Máy chủ
      ID SCSI của bộ điều hợp được biểu thị bằng "#".

Trạng thái Đàm phán rộng, Ngắt kết nối/Kết nối lại và Xếp hàng được gắn thẻ
    được báo cáo là "Đã bật", Đã tắt" hoặc một chuỗi các chữ cái "Y" và "N".

Tính năng hiệu suất
--------------------

Bộ điều hợp máy chủ BusLogic SCSI trực tiếp triển khai Hàng đợi được gắn thẻ SCSI-2, v.v.
  hỗ trợ đã được bao gồm trong trình điều khiển để sử dụng hàng đợi được gắn thẻ với bất kỳ
  thiết bị mục tiêu báo cáo có khả năng xếp hàng được gắn thẻ.  Được gắn thẻ
  xếp hàng cho phép đưa ra nhiều lệnh nổi bật cho từng mục tiêu
  thiết bị hoặc đơn vị logic và có thể cải thiện đáng kể hiệu suất I/O.  trong
  Ngoài ra, Chế độ Robin vòng nghiêm ngặt của BusLogic được sử dụng để tối ưu hóa bộ điều hợp máy chủ
  hiệu suất và I/O phân tán/thu thập có thể hỗ trợ nhiều phân đoạn nhất có thể
  được sử dụng hiệu quả bởi hệ thống con I/O của Linux.  Kiểm soát việc sử dụng
  xếp hàng được gắn thẻ cho từng thiết bị mục tiêu cũng như lựa chọn riêng lẻ
  Độ sâu hàng đợi được gắn thẻ có sẵn thông qua các tùy chọn trình điều khiển được cung cấp trên kernel
  dòng lệnh hoặc tại thời điểm khởi tạo mô-đun.  Theo mặc định, độ sâu hàng đợi
  được xác định tự động dựa trên tổng độ sâu hàng đợi của bộ điều hợp máy chủ và
  số lượng, loại, tốc độ và khả năng của các thiết bị mục tiêu được tìm thấy.  trong
  Ngoài ra, việc xếp hàng được gắn thẻ sẽ tự động bị tắt bất cứ khi nào bộ điều hợp máy chủ
  phiên bản chương trình cơ sở được biết là không triển khai chính xác hoặc bất cứ khi nào được gắn thẻ
  độ sâu hàng đợi là 1 được chọn.  Xếp hàng được gắn thẻ cũng bị vô hiệu hóa đối với cá nhân
  thiết bị mục tiêu nếu ngắt kết nối/kết nối lại bị tắt cho thiết bị đó.

Tính năng mạnh mẽ
-------------------

Trình điều khiển thực hiện các thủ tục khắc phục lỗi rộng rãi.  Khi càng cao
  các bộ phận cấp độ của hệ thống con SCSI yêu cầu đặt lại lệnh hết thời gian chờ,
  lựa chọn được thực hiện giữa thiết lập lại cứng bộ điều hợp máy chủ đầy đủ và thiết lập lại bus SCSI
  so với việc gửi tin nhắn đặt lại thiết bị bus đến từng thiết bị mục tiêu
  dựa trên khuyến nghị của hệ thống con SCSI.  Chiến lược khắc phục lỗi
  có thể lựa chọn thông qua các tùy chọn trình điều khiển riêng cho từng thiết bị mục tiêu,
  và cũng bao gồm việc gửi thiết lập lại thiết bị bus đến thiết bị mục tiêu cụ thể
  liên quan đến lệnh được đặt lại, cũng như ngăn chặn lỗi
  phục hồi hoàn toàn để tránh làm nhiễu loạn thiết bị hoạt động không đúng cách.  Nếu
  chiến lược khôi phục lỗi thiết lập lại thiết bị bus được chọn và gửi một bus
  thiết lập lại thiết bị không khôi phục hoạt động chính xác, lệnh tiếp theo là
  reset sẽ buộc thiết lập lại cứng toàn bộ bộ điều hợp máy chủ và thiết lập lại bus SCSI.  xe buýt SCSI
  các lần đặt lại do các thiết bị khác gây ra và được bộ điều hợp máy chủ phát hiện cũng được
  được xử lý bằng cách thiết lập lại mềm cho bộ điều hợp máy chủ và khởi tạo lại.
  Cuối cùng, nếu hàng đợi được gắn thẻ đang hoạt động và xảy ra nhiều lần đặt lại lệnh
  trong khoảng thời gian 10 phút hoặc nếu việc đặt lại lệnh xảy ra trong vòng 10 phút đầu tiên
  phút hoạt động thì việc xếp hàng được gắn thẻ sẽ bị vô hiệu hóa đối với mục tiêu đó
  thiết bị.  Các tùy chọn khôi phục lỗi này cải thiện độ bền của hệ thống tổng thể bằng cách
  ngăn chặn các thiết bị sai sót riêng lẻ khiến toàn bộ hệ thống gặp sự cố
  khóa hoặc gặp sự cố, và do đó cho phép tắt máy và khởi động lại sạch sẽ sau
  thành phần vi phạm sẽ bị loại bỏ.

Hỗ trợ cấu hình PCI
-------------------------

Trên các hệ thống PCI chạy hạt nhân được biên dịch có hỗ trợ PCI BIOS, điều này
  trình điều khiển sẽ thẩm vấn không gian cấu hình PCI và sử dụng cổng I/O
  địa chỉ được chỉ định bởi hệ thống BIOS, thay vì I/O tương thích ISA
  địa chỉ cổng.  Địa chỉ cổng I/O tương thích ISA sau đó bị vô hiệu hóa bởi
  người lái xe.  Trên các hệ thống PCI, chúng tôi cũng khuyến nghị nên cài đặt tiện ích AutoSCSI
  được sử dụng để vô hiệu hóa hoàn toàn cổng I/O tương thích ISA vì điều đó là không cần thiết.
  Cổng I/O tương thích ISA bị tắt theo mặc định trên BT-948/958/958D.

/proc Hỗ trợ hệ thống tệp
-------------------------

Bản sao thông tin cấu hình bộ điều hợp máy chủ cùng với các thông tin cập nhật
  thống kê truyền dữ liệu và phục hồi lỗi có sẵn thông qua
  giao diện /proc/scsi/BusLogic/<N>.

Hỗ trợ ngắt được chia sẻ
-------------------------

Trên các hệ thống hỗ trợ các ngắt được chia sẻ, bất kỳ số lượng BusLogic Host nào cũng có thể
  Bộ điều hợp có thể chia sẻ cùng một kênh yêu cầu ngắt.


Bộ điều hợp máy chủ được hỗ trợ
===============================

Danh sách sau đây bao gồm Bộ điều hợp máy chủ BusLogic SCSI được hỗ trợ kể từ
ngày của tài liệu này.  Chúng tôi khuyên mọi người mua BusLogic
Bộ điều hợp máy chủ không có trong bảng sau, hãy liên hệ trước với tác giả để xác minh
rằng nó đang hoặc sẽ được hỗ trợ.

Bộ điều hợp máy chủ FlashPoint Series PCI:

=========================================================================
FlashPoint LT (BT-930) Ultra SCSI-3
FlashPoint LT (BT-930R) Ultra SCSI-3 với RAIDPlus
FlashPoint LT (BT-920) Ultra SCSI-3 (BT-930 không có BIOS)
FlashPoint DL (BT-932) Kênh đôi Ultra SCSI-3
FlashPoint DL (BT-932R) Kênh đôi Ultra SCSI-3 với RAIDPlus
FlashPoint LW (BT-950) Wide Ultra SCSI-3
FlashPoint LW (BT-950R) Wide Ultra SCSI-3 với RAIDPlus
FlashPoint DW (BT-952) Kênh đôi siêu rộng SCSI-3
FlashPoint DW (BT-952R) Dual Channel Wide Ultra SCSI-3 với RAIDPlus
=========================================================================

Bộ điều hợp máy chủ dòng MultiMaster "W":

======= === =================================
BT-948 PCI Siêu SCSI-3
BT-958 PCI Wide Ultra SCSI-3
BT-958D PCI Vi sai rộng Ultra SCSI-3
======= === =================================

Bộ điều hợp máy chủ dòng MultiMaster "C":

======== ==== =================================
BT-946C PCI SCSI-2 nhanh
BT-956C PCI Rộng Nhanh SCSI-2
BT-956CD PCI vi sai rộng nhanh SCSI-2
BT-445C VLB Nhanh SCSI-2
BT-747C EISA SCSI-2 nhanh
BT-757C EISA Rộng Nhanh SCSI-2
BT-757CD EISA vi sai rộng nhanh SCSI-2
======== ==== =================================

Bộ điều hợp máy chủ dòng MultiMaster "S":

======= ==== =================================
BT-445S VLB SCSI-2 nhanh
BT-747S EISA SCSI-2 nhanh
BT-747D EISA Vi sai nhanh SCSI-2
BT-757S EISA Rộng Nhanh SCSI-2
BT-757D EISA vi sai rộng nhanh SCSI-2
BT-742A EISA SCSI-2 (bản sửa đổi 742A H)
======= ==== =================================

Bộ điều hợp máy chủ dòng MultiMaster "A":

======= ==== =================================
BT-742A EISA SCSI-2 (742A phiên bản A - G)
======= ==== =================================

Bộ điều hợp máy chủ FastDisk AMI là bản sao BusLogic MultiMaster thực sự cũng được
được hỗ trợ bởi trình điều khiển này.

Bộ điều hợp máy chủ BusLogic SCSI được đóng gói dưới dạng bảng mạch trần và dưới dạng
bộ dụng cụ bán lẻ.  Số model BT- ở trên đề cập đến bao bì bìa cứng.
Số kiểu bộ sản phẩm bán lẻ được tìm thấy bằng cách thay thế BT- bằng KT- ở trên
danh sách.  Bộ sản phẩm bán lẻ bao gồm bảng mạch trần và sách hướng dẫn sử dụng cũng như cáp và
phương tiện điều khiển và tài liệu không được cung cấp kèm bảng mạch trần.


Ghi chú cài đặt FlashPoint
=============================

Hỗ trợ RAIDPlus
----------------

Bộ điều hợp máy chủ FlashPoint hiện bao gồm RAIDPlus, phần mềm có thể khởi động của Mylex
  RAID.  RAIDPlus không được hỗ trợ trên Linux và không có kế hoạch hỗ trợ
  nó.  Trình điều khiển MD trong Linux 2.0 cung cấp khả năng ghép nối (LINEAR) và
  phân dải (RAID-0) và hỗ trợ phản chiếu (RAID-1), tính chẵn lẻ cố định (RAID-4),
  và chẵn lẻ phân phối (RAID-5) có sẵn riêng biệt.  Linux tích hợp
  Hỗ trợ RAID nhìn chung linh hoạt hơn và dự kiến sẽ hoạt động tốt hơn
  hơn RAIDPlus, do đó có rất ít động lực để đưa hỗ trợ RAIDPlus vào
  Trình điều khiển BusLogic.

Kích hoạt chuyển UltraSCSI
----------------------------

Bộ điều hợp máy chủ FlashPoint được cung cấp với cấu hình được đặt thành "Nhà máy
  Mặc định" cài đặt thận trọng và không cho phép tốc độ UltraSCSI
  để được thương lượng.  Điều này dẫn đến ít vấn đề hơn khi các bộ điều hợp máy chủ này
  được cài đặt trong các hệ thống có hệ thống cáp hoặc đầu cuối không đủ
  cho hoạt động UltraSCSI hoặc khi các thiết bị SCSI hiện tại không hoạt động đúng cách
  đáp ứng đàm phán truyền đồng bộ cho tốc độ UltraSCSI.  AutoSCSI
  có thể được sử dụng để tải cài đặt "Hiệu suất tối ưu" cho phép UltraSCSI
  tốc độ được thương lượng với tất cả các thiết bị hoặc tốc độ UltraSCSI có thể được bật trên
  một cơ sở cá nhân.  Bạn nên tắt SCAM theo cách thủ công sau
  cài đặt "Hiệu suất tối ưu" đã được tải.


Lưu ý cài đặt BT-948/958/958D
==================================

Bộ điều hợp máy chủ BT-948/958/958D PCI Ultra SCSI có một số tính năng có thể
cần chú ý trong một số trường hợp khi cài đặt Linux.

Bài tập cổng I/O PCI
------------------------

Khi được cấu hình về cài đặt mặc định của nhà sản xuất, BT-948/958/958D sẽ chỉ
  nhận biết các phép gán cổng I/O PCI do PCI BIOS của bo mạch chủ thực hiện.
  BT-948/958/958D sẽ không phản hồi với bất kỳ cổng I/O tương thích ISA nào
  mà Bộ điều hợp máy chủ BusLogic SCSI trước đó phản hồi.  Trình điều khiển này hỗ trợ
  gán cổng I/O PCI, vì vậy đây là cấu hình ưu tiên.
  Tuy nhiên, nếu trình điều khiển BusLogic lỗi thời phải được sử dụng vì bất kỳ lý do gì, chẳng hạn như
  một bản phân phối Linux chưa sử dụng trình điều khiển này trong nhân khởi động của nó,
  BusLogic đã cung cấp tùy chọn cấu hình AutoSCSI để kích hoạt ISA cũ
  cổng I/O tương thích.

Để kích hoạt tùy chọn tương thích ngược này, hãy gọi tiện ích AutoSCSI thông qua
  Ctrl-B khi khởi động hệ thống và chọn "Cấu hình bộ điều hợp", "Xem/Sửa đổi
  Configuration", sau đó thay đổi cài đặt "Cổng tương thích ISA" từ
  "Tắt" thành "Chính" hoặc "Thay thế".  Khi trình điều khiển này đã được cài đặt,
  tùy chọn "Cổng tương thích ISA" phải được đặt lại thành "Tắt" để tránh
  xung đột cổng I/O có thể xảy ra trong tương lai.  BT-946C/956C/956CD cũ hơn cũng có
  tùy chọn cấu hình này, nhưng cài đặt mặc định của nhà sản xuất là "Chính".

Thứ tự quét khe PCI
-----------------------

Trong các hệ thống có nhiều Bộ điều hợp máy chủ BusLogic PCI, thứ tự
  Các khe PCI được quét có thể xuất hiện đảo ngược với BT-948/958/958D như
  so với BT-946C/956C/956CD.  Để khởi động từ đĩa SCSI hoạt động
  chính xác, điều cần thiết là BIOS của bộ điều hợp máy chủ và kernel phải đồng ý
  thiết bị khởi động trên đĩa nào, yêu cầu họ nhận ra PCI
  bộ điều hợp máy chủ theo cùng một thứ tự.  PCI BIOS của bo mạch chủ cung cấp một
  cách tiêu chuẩn để liệt kê các bộ điều hợp máy chủ PCI, được Linux sử dụng
  hạt nhân.  Một số triển khai PCI BIOS liệt kê các vị trí PCI theo thứ tự
  tăng số lượng bus và số thiết bị, trong khi số khác làm ngược lại
  hướng.

Thật không may, Microsoft đã quyết định rằng Windows 95 sẽ luôn liệt kê các
  Các khe PCI theo thứ tự tăng số lượng bus và số lượng thiết bị bất kể
  bảng liệt kê PCI BIOS và yêu cầu lược đồ của chúng phải được hỗ trợ bởi
  BIOS của bộ điều hợp máy chủ để nhận được chứng nhận Windows 95.  Vì vậy,
  cài đặt mặc định gốc của BT-948/958/958D liệt kê các bộ điều hợp máy chủ
  bằng cách tăng số lượng xe buýt và số lượng thiết bị.  Để tắt tính năng này, hãy gọi
  tiện ích AutoSCSI thông qua Ctrl-B khi khởi động hệ thống và chọn "Adapter
  Cấu hình", "Xem/Sửa đổi cấu hình", nhấn Ctrl-F10, rồi thay đổi
  "Sử dụng trình tự quét xe buýt và thiết bị # For PCI." tùy chọn vào OFF.

Trình điều khiển này sẽ thẩm vấn cài đặt của tùy chọn Trình tự quét PCI
  để nhận biết các bộ điều hợp máy chủ theo thứ tự như chúng được liệt kê
  bởi BIOS của bộ điều hợp máy chủ.

Kích hoạt chuyển UltraSCSI
----------------------------

Tàu BT-948/958/958D có cấu hình được đặt thành "Mặc định của nhà máy"
  cài đặt thận trọng và không cho phép tốc độ UltraSCSI
  đã thương lượng.  Điều này dẫn đến ít vấn đề hơn khi các bộ điều hợp máy chủ này được
  được lắp đặt trong các hệ thống có hệ thống cáp hoặc đầu cuối không đủ khả năng
  Hoạt động UltraSCSI hoặc khi các thiết bị SCSI hiện có không phản hồi đúng cách
  để đàm phán truyền đồng bộ cho tốc độ UltraSCSI.  AutoSCSI có thể
  được sử dụng để tải cài đặt "Hiệu suất tối ưu" cho phép tốc độ UltraSCSI
  được đàm phán với tất cả các thiết bị hoặc tốc độ UltraSCSI có thể được bật trên
  cơ sở cá nhân.  Bạn nên tắt SCAM theo cách thủ công sau khi
  Cài đặt "Hiệu suất tối ưu" được tải.


Tùy chọn trình điều khiển
=========================

Tùy chọn trình điều khiển BusLogic có thể được chỉ định thông qua Lệnh hạt nhân Linux
Đường dây hoặc thông qua Cơ sở cài đặt mô-đun hạt nhân có thể tải.  Tùy chọn trình điều khiển
đối với nhiều bộ điều hợp máy chủ có thể được chỉ định bằng cách tách tùy chọn
chuỗi bằng dấu chấm phẩy hoặc bằng cách chỉ định nhiều chuỗi "BusLogic=" trên
dòng lệnh.  Thông số kỹ thuật tùy chọn riêng cho một bộ điều hợp máy chủ duy nhất là
cách nhau bằng dấu phẩy.  Tùy chọn thăm dò và gỡ lỗi áp dụng cho tất cả máy chủ
bộ điều hợp trong khi các tùy chọn còn lại chỉ áp dụng riêng cho
bộ điều hợp máy chủ đã chọn.

Các tùy chọn thăm dò trình điều khiển BusLogic bao gồm:

Không có thăm dò

Tùy chọn "NoProbe" vô hiệu hóa tất cả việc thăm dò và do đó không có Máy chủ BusLogic
  Bộ điều hợp sẽ được phát hiện.

Không có đầu dòPCI

Tùy chọn "NoProbePCI" vô hiệu hóa việc thẩm vấn Cấu hình PCI
  Không gian và do đó chỉ Bộ điều hợp máy chủ đa năng ISA mới được phát hiện, vì
  cũng như Bộ điều hợp máy chủ đa năng PCI có I/O tương thích ISA
  Cổng được đặt thành "Chính" hoặc "Thay thế".

NoSortPCI

Tùy chọn "NoSortPCI" buộc Bộ điều hợp máy chủ MultiMaster PCI phải được
  được liệt kê theo thứ tự do PCI BIOS cung cấp, bỏ qua mọi cài đặt của
  AutoSCSI "Sử dụng Bus và thiết bị # For PCI Trình tự quét." lựa chọn.

MultiMasterĐầu tiên

Tùy chọn "MultiMasterFirst" buộc Bộ điều hợp máy chủ MultiMaster phải được thăm dò
  trước Bộ điều hợp máy chủ FlashPoint.  Theo mặc định, nếu cả FlashPoint và PCI
  Có bộ điều hợp máy chủ MultiMaster, trình điều khiển này sẽ thăm dò
  Bộ điều hợp máy chủ FlashPoint trước trừ khi đĩa chính BIOS được kiểm soát
  bởi Bộ điều hợp máy chủ MultiMaster PCI đầu tiên, trong trường hợp đó là MultiMaster Host
  Bộ điều hợp sẽ được thăm dò đầu tiên.

FlashPointĐầu tiên

Tùy chọn "FlashPointFirst" buộc Bộ điều hợp máy chủ FlashPoint phải được thăm dò
  trước Bộ điều hợp máy chủ MultiMaster.

Tùy chọn xếp hàng được gắn thẻ trình điều khiển BusLogic cho phép chỉ định rõ ràng
Độ sâu hàng đợi và liệu Hàng đợi được gắn thẻ có được phép cho từng Mục tiêu hay không
Thiết bị (giả sử rằng Thiết bị đích hỗ trợ Xếp hàng được gắn thẻ).  Hàng đợi
Độ sâu là số lượng Lệnh SCSI được phép thực hiện đồng thời
được trình bày để thực thi (đến Bộ điều hợp máy chủ hoặc Thiết bị đích).  Lưu ý
việc bật Hàng đợi được gắn thẻ một cách rõ ràng có thể dẫn đến các vấn đề; tùy chọn để
bật hoặc tắt Hàng đợi được gắn thẻ được cung cấp chủ yếu để cho phép tắt
Xếp hàng được gắn thẻ trên các thiết bị mục tiêu không triển khai chính xác.  các
các tùy chọn sau đây có sẵn:

Độ sâu hàng đợi:<số nguyên>

Tùy chọn "QueueDepth:" hoặc QD:" chỉ định Độ sâu hàng đợi để sử dụng cho tất cả
  Thiết bị mục tiêu hỗ trợ Hàng đợi được gắn thẻ, cũng như Hàng đợi tối đa
  Độ sâu cho các thiết bị không hỗ trợ Hàng đợi được gắn thẻ.  Nếu không có độ sâu hàng đợi
  được cung cấp, Độ sâu hàng đợi sẽ được xác định tự động dựa trên
  về Tổng độ sâu hàng đợi của Bộ điều hợp máy chủ và số lượng, loại, tốc độ và
  khả năng của Thiết bị mục tiêu được phát hiện.  Thiết bị mục tiêu
  không hỗ trợ Hàng đợi được gắn thẻ luôn đặt Độ sâu hàng đợi của họ thành
  BusLogic_UntaggedQueueDepth hoặc BusLogic_UntaggedQueueDepthBB, trừ khi
  tùy chọn Độ sâu hàng đợi thấp hơn được cung cấp.  Độ sâu hàng đợi 1 tự động
  vô hiệu hóa hàng đợi được gắn thẻ.

QueueDepth:[<integer>,<integer>...]

Tùy chọn "QueueDepth:[...]" hoặc "QD:[...]" chỉ định Độ sâu hàng đợi
  riêng cho từng Thiết bị mục tiêu.  Nếu một <số nguyên> bị bỏ qua,
  Thiết bị mục tiêu được liên kết sẽ tự động chọn Độ sâu hàng đợi.

Được gắn thẻXếp hàng:Mặc định

Tùy chọn "TaggedQueuing:Default" hoặc "TQ:Default" cho phép xếp hàng được gắn thẻ
  dựa trên phiên bản phần sụn của Bộ điều hợp máy chủ BusLogic và dựa trên
  Độ sâu hàng đợi có cho phép xếp hàng nhiều lệnh hay không.

Được gắn thẻXếp hàng:Bật

Tùy chọn "TaggedQueuing:Enable" hoặc "TQ:Enable" bật Hàng đợi được gắn thẻ cho
  tất cả các Thiết bị đích trên Bộ điều hợp máy chủ này, ghi đè mọi giới hạn
  nếu không sẽ được áp dụng dựa trên phiên bản chương trình cơ sở Bộ điều hợp Máy chủ.

Được gắn thẻXếp hàng:Vô hiệu hóa

Tùy chọn "TaggedQueuing:Disable" hoặc "TQ:Disable" sẽ tắt Hàng đợi được gắn thẻ
  cho tất cả các Thiết bị đích trên Bộ điều hợp máy chủ này.

Được gắn thẻXếp hàng:<Target-Spec>

Các điều khiển tùy chọn "TaggedQueuing:<Target-Spec>" hoặc "TQ:<Target-Spec>"
  Được gắn thẻ Xếp hàng riêng cho từng Thiết bị đích.  <Thông số mục tiêu> là một
  chuỗi các ký tự "Y", "N" và "X".  "Y" cho phép xếp hàng được gắn thẻ, "N"
  vô hiệu hóa Hàng đợi được gắn thẻ và "X" chấp nhận mặc định dựa trên chương trình cơ sở
  phiên bản.  Ký tự đầu tiên đề cập đến Thiết bị đích 0, ký tự thứ hai đề cập đến
  Thiết bị mục tiêu 1, v.v.; nếu chuỗi ký tự "Y", "N" và "X"
  không bao gồm tất cả các Thiết bị mục tiêu, giả sử các ký tự không xác định
  là "X".

Các tùy chọn linh tinh của trình điều khiển BusLogic bao gồm:

Thời gian giải quyết xe buýt:<giây>

Tùy chọn "BusSettleTime:" hoặc "BST:" chỉ định Thời gian giải quyết xe buýt trong
  giây.  Thời gian giải quyết xe buýt là khoảng thời gian chờ đợi giữa một Máy chủ
  Thiết lập lại cứng bộ điều hợp khởi tạo thiết lập lại bus SCSI và phát hành bất kỳ SCSI nào
  Lệnh.  Nếu không được chỉ định, nó sẽ mặc định là BusLogic_DefaultBusSettleTime.

Ức chế mục tiêuYêu cầu

Tùy chọn "InhibitTargetInquiry" ngăn chặn việc thực hiện Truy vấn
  Thiết bị mục tiêu hoặc Truy vấn lệnh Thiết bị đã cài đặt trên Máy chủ MultiMaster
  Bộ điều hợp.  Điều này có thể cần thiết với một số Thiết bị đích cũ hơn không
  phản hồi chính xác khi Đơn vị logic trên 0 được xử lý.

Các tùy chọn gỡ lỗi trình điều khiển BusLogic bao gồm:

Dấu vết thăm dò

Tùy chọn "TraceProbe" cho phép theo dõi việc thăm dò bộ điều hợp máy chủ.

Dấu vếtPhần cứngThiết lập lại

Tùy chọn "TraceHardwareReset" cho phép theo dõi Phần cứng bộ điều hợp máy chủ
  Đặt lại.

Cấu hình dấu vết

Tùy chọn "TraceConfiguration" cho phép theo dõi Bộ điều hợp máy chủ
  Cấu hình.

Dấu vếtLỗi

Tùy chọn "TraceErrors" cho phép theo dõi các lệnh SCSI trả về một
  lỗi từ Thiết bị đích.  CDB và Sense Data sẽ được in cho
  mỗi Lệnh SCSI không thành công.

Gỡ lỗi

Tùy chọn "Gỡ lỗi" cho phép tất cả các tùy chọn gỡ lỗi.

Các ví dụ sau đây minh họa cách đặt Độ sâu hàng đợi cho Thiết bị mục tiêu
1 và 2 trên bộ điều hợp máy chủ đầu tiên thành 7 và 15, Độ sâu hàng đợi cho tất cả Mục tiêu
Các thiết bị trên bộ điều hợp máy chủ thứ hai thành 31 và Thời gian giải quyết xe buýt trên
bộ chuyển đổi máy chủ thứ hai thành 30 giây.

Dòng lệnh hạt nhân Linux::

linux BusLogic=QueueDepth:[,7,15];QueueDepth:31,BusSettleTime:30

Trình tải khởi động Linux LILO (trong /etc/lilo.conf)::

chắp thêm = "BusLogic=QueueDepth:[,7,15];QueueDepth:31,BusSettleTime:30"

Cơ sở cài đặt mô-đun hạt nhân có thể tải INSMOD::

insmod BusLogic.o \
      'BusLogic="QueueDepth:[,7,15];QueueDepth:31,BusSettleTime:30"'


.. Note::

      Module Utilities 2.1.71 or later is required for correct parsing
      of driver options containing commas.


Cài đặt trình điều khiển
========================

Bản phân phối này đã được chuẩn bị cho nhân Linux phiên bản 2.0.35, nhưng phải được
tương thích với 2.0.4 hoặc bất kỳ hạt nhân dòng 2.0 nào sau này.

Để cài đặt trình điều khiển BusLogic SCSI mới, bạn có thể sử dụng các lệnh sau:
thay thế "/usr/src" bằng bất cứ nơi nào bạn giữ cây nguồn nhân Linux của mình::

cd /usr/src
  tar -xvzf BusLogic-2.0.15.tar.gz
  mv README.* LICENSE.* BusLogic.[ch] FlashPoint.c linux/drivers/scsi
  patch -p0 < BusLogic.patch (chỉ dành cho 2.0.33 trở xuống)
  cd linux
  tạo cấu hình
  tạo zImage

Sau đó cài đặt "arch/x86/boot/zImage" làm kernel chuẩn của bạn, chạy lilo nếu
thích hợp và khởi động lại.


Danh sách gửi thư thông báo BusLogic
====================================

Danh sách gửi thư thông báo BusLogic cung cấp một diễn đàn để thông báo cho Linux
người dùng các bản phát hành trình điều khiển mới và các thông báo khác liên quan đến hỗ trợ Linux
dành cho Bộ điều hợp máy chủ BusLogic SCSI.  Để tham gia danh sách gửi thư, hãy gửi tin nhắn tới
"buslogic-announce-request@dandelion.com" với dòng "đăng ký" trong
nội dung tin nhắn.