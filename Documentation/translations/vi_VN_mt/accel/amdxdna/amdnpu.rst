.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/accel/amdxdna/amdnpu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

==========
 AMD NPU
=========

:Bản quyền: ZZ0000ZZ 2024 Advanced Micro Devices, Inc.
:Tác giả: Sonal Santan <sonal.santan@amd.com>

Tổng quan
========

AMD NPU (Bộ xử lý thần kinh) là một công cụ tăng tốc suy luận AI cho nhiều người dùng
được tích hợp vào máy khách AMD APU. NPU cho phép thực hiện Máy hiệu quả
Các ứng dụng học tập như CNN, LLM, v.v. NPU dựa trên
ZZ0000ZZ. NPU được quản lý bởi trình điều khiển ZZ0001ZZ.


Mô tả phần cứng
====================

AMD NPU bao gồm các thành phần phần cứng sau:

Mảng AMD XDNA
--------------

AMD XDNA Array bao gồm mảng 2D của các ô tính toán và bộ nhớ được xây dựng bằng
ZZ0000ZZ. Mỗi cột có 4 hàng ô tính toán và 1
hàng ô nhớ. Mỗi ô điện toán chứa bộ xử lý VLIW có bộ xử lý riêng
chương trình và bộ nhớ dữ liệu chuyên dụng. Ô bộ nhớ hoạt động như bộ nhớ L2. 2D
mảng có thể được phân vùng tại một ranh giới cột tạo ra sự cô lập về mặt không gian
phân vùng có thể được liên kết với bối cảnh khối lượng công việc.

Mỗi cột cũng có các công cụ DMA chuyên dụng để di chuyển dữ liệu giữa máy chủ DDR và
ô ký ức.

Máy khách AMD Phoenix và AMD Hawk Point NPU có cấu trúc liên kết 4x5, tức là 4 hàng
tính toán các ô xếp thành 5 cột. AMD Máy khách Strix Point APU có 4x8
cấu trúc liên kết, tức là 4 hàng ô tính toán được sắp xếp thành 8 cột.

Bộ nhớ L2 dùng chung
----------------

Một hàng ô nhớ duy nhất tạo ra một nhóm phần mềm được quản lý trên chip L2
trí nhớ. Công cụ DMA được sử dụng để di chuyển dữ liệu giữa máy chủ DDR và các ô nhớ.
NPU AMD Phoenix và AMD Hawk Point có tổng bộ nhớ L2 là 2560 KB.
AMD Strix Point NPU có tổng cộng 4096 KB bộ nhớ L2.

vi điều khiển
---------------

Một bộ vi điều khiển chạy Firmware NPU chịu trách nhiệm xử lý lệnh,
Thiết lập phân vùng mảng XDNA, cấu hình mảng XDNA, bối cảnh khối lượng công việc
quản lý và điều phối công việc.

NPU Firmware sử dụng một phiên bản chuyên dụng của bối cảnh không có đặc quyền bị cô lập
được gọi là ERT để phục vụ từng bối cảnh khối lượng công việc. ERT cũng được sử dụng để thực thi lệnh của người dùng
đã cung cấp ZZ0000ZZ liên quan đến bối cảnh khối lượng công việc.

NPU Firmware sử dụng một bối cảnh đặc quyền riêng biệt duy nhất được gọi là MERT để phục vụ
lệnh quản lý từ trình điều khiển amdxdna.

Hộp thư
---------

Bộ vi điều khiển và trình điều khiển amdxdna sử dụng kênh đặc quyền để quản lý
các nhiệm vụ như thiết lập ngữ cảnh, đo từ xa, truy vấn, xử lý lỗi, thiết lập
kênh người dùng, v.v. Như đã đề cập trước đó, các yêu cầu kênh đặc quyền được
được phục vụ bởi MERT. Kênh đặc quyền được liên kết với một hộp thư duy nhất.

Bộ vi điều khiển và trình điều khiển amdxdna sử dụng kênh người dùng chuyên dụng cho mỗi
bối cảnh khối lượng công việc. Kênh người dùng chủ yếu được sử dụng để gửi tác phẩm tới
NPU. Như đã đề cập trước đó, các yêu cầu kênh người dùng được phục vụ bởi một
phiên bản của ERT. Mỗi kênh người dùng được liên kết với hộp thư chuyên dụng của riêng nó.

PCIe EP
-------

NPU hiển thị với máy chủ x86 CPU dưới dạng thiết bị PCIe có nhiều BAR và một số
Các vectơ ngắt MSI-X. NPU sử dụng kết cấu cấp độ SoC băng thông cao chuyên dụng
để đọc hoặc ghi vào bộ nhớ máy chủ. Mỗi phiên bản của ERT đều có phiên bản riêng
ngắt MSI-X chuyên dụng. MERT nhận được một phiên bản ngắt MSI-X.

Số lượng thanh PCIe khác nhau tùy thuộc vào thiết bị cụ thể. Dựa trên của họ
các chức năng, thanh PCIe thường có thể được phân loại thành các loại sau.

* PSP BAR: Hiển thị chức năng AMD PSP (Bộ xử lý bảo mật nền tảng)
* SMU BAR: Hiển thị chức năng AMD SMU (System Management Unit)
* SRAM BAR: Hiển thị bộ đệm vòng cho hộp thư
* Mailbox BAR: Hiển thị các thanh ghi điều khiển hộp thư (head, tail và ISR
  sổ đăng ký, v.v.)
* Sổ đăng ký công khai BAR: Hiển thị các sổ đăng ký công khai

Trên các thiết bị cụ thể, loại BAR nêu trên có thể được kết hợp thành một
PCIe vật lý đơn BAR. Hoặc một mô-đun có thể yêu cầu hai thanh PCIe vật lý để
có đầy đủ chức năng. Ví dụ,

* Trên thiết bị AMD Phoenix, PSP, SMU, BAR Đăng ký công khai nằm trên chỉ số PCIe BAR 0.
* Trên thiết bị AMD Strix Point, Hộp thư và Thanh đăng ký công cộng nằm trên PCIe BAR
  chỉ số 0. PSP có một số thanh ghi trong PCIe BAR chỉ số 0 (Đăng ký công khai BAR)
  và PCIe BAR chỉ số 4 (PSP BAR).

Phần cứng cách ly quy trình
--------------------------

Như đã giải thích trước đó, Mảng XDNA có thể được chia động thành các thành phần riêng biệt
các phân vùng không gian, mỗi phân vùng có thể có một hoặc nhiều cột. Không gian
phân vùng được thiết lập bằng cách lập trình các thanh ghi cách ly cột bằng
vi điều khiển. Mỗi phân vùng không gian được liên kết với một PASID.
cũng được lập trình bởi vi điều khiển. Do đó nhiều phân vùng không gian trong
NPU có thể thực hiện truy cập máy chủ đồng thời được bảo vệ bởi PASID.

Bản thân NPU FW sử dụng các bối cảnh biệt lập được thực thi bởi vi điều khiển MMU cho
phục vụ các yêu cầu của người dùng và kênh đặc quyền.


Lập kế hoạch không gian và thời gian hỗn hợp
=====================================

Kiến trúc AMD XDNA hỗ trợ hỗn hợp không gian và thời gian (chia sẻ thời gian)
lập lịch của mảng 2D. Điều này có nghĩa là các phân vùng không gian có thể được thiết lập và
được chia nhỏ linh hoạt để đáp ứng các khối lượng công việc khác nhau. Phân vùng ZZ0000ZZ
có thể ZZ0001ZZ bị ràng buộc với một bối cảnh khối lượng công việc trong khi một phân vùng khác có thể
ZZ0002ZZ bị ràng buộc với nhiều bối cảnh khối lượng công việc. Bộ vi điều khiển
cập nhật PASID cho phân vùng được chia sẻ tạm thời để phù hợp với bối cảnh
đã bị ràng buộc vào phân vùng bất cứ lúc nào.

Bộ giải tài nguyên
---------------

Thành phần Bộ giải tài nguyên của trình điều khiển amdxdna quản lý việc phân bổ
của mảng 2D giữa các khối lượng công việc khác nhau. Mỗi khối lượng công việc mô tả số lượng
số cột cần thiết để chạy tệp nhị phân NPU trong siêu dữ liệu của nó. Bộ giải tài nguyên
thành phần sử dụng các gợi ý được truyền qua khối lượng công việc và các phương pháp phỏng đoán riêng của nó để
quyết định chiến lược phân vùng (tái) mảng 2D và ánh xạ khối lượng công việc cho không gian và
chia sẻ tạm thời của các cột. FW thực thi tài nguyên theo ngữ cảnh tới (các) cột
các quyết định ràng buộc được thực hiện bởi Bộ giải tài nguyên.

AMD Phoenix và AMD Máy khách Hawk Point NPU có thể hỗ trợ 6 khối lượng công việc đồng thời
bối cảnh. AMD Strix Point có thể hỗ trợ 16 bối cảnh khối lượng công việc đồng thời.


Tệp nhị phân ứng dụng
====================

Khối lượng công việc ứng dụng NPU bao gồm hai tệp nhị phân riêng biệt.
được tạo bởi trình biên dịch NPU.

1. Lớp phủ mảng AMD XDNA, được sử dụng để định cấu hình phân vùng không gian NPU.
   Lớp phủ chứa hướng dẫn thiết lập chuyển đổi luồng
   cấu hình và ELF cho các ô tính toán. Lớp phủ được tải trên
   phân vùng không gian được liên kết với khối lượng công việc bởi phiên bản ERT được liên kết.
   Tham khảo
   ZZ0000ZZ để biết thêm chi tiết.

2. ZZ0000ZZ, được sử dụng để sắp xếp lớp phủ được tải trên không gian
   phân vùng. ZZ0001ZZ được thực thi bởi ERT chạy ở chế độ được bảo vệ trên
   vi điều khiển trong bối cảnh khối lượng công việc. ZZ0002ZZ được tạo thành
   của một chuỗi các opcode có tên ZZ0003ZZ. Tham khảo
   ZZ0004ZZ để biết thêm chi tiết.


Bộ đệm máy chủ đặc biệt
====================

Bộ đệm hướng dẫn theo ngữ cảnh
------------------------------

Mọi bối cảnh khối lượng công việc đều sử dụng bộ đệm 64 MB lưu trữ trên máy chủ là bộ nhớ
được ánh xạ vào phiên bản ERT được tạo để phục vụ khối lượng công việc. ZZ0000ZZ
khối lượng công việc sử dụng sẽ được sao chép vào bộ nhớ đặc biệt này. Bộ đệm này là
được bảo vệ bởi PASID giống như tất cả các bộ đệm đầu vào/đầu ra khác được khối lượng công việc đó sử dụng.
Bộ đệm lệnh cũng được ánh xạ vào không gian người dùng của khối lượng công việc.

Bộ đệm đặc quyền toàn cầu
------------------------

Ngoài ra, trình điều khiển còn cấp phát một bộ đệm duy nhất cho các tác vụ bảo trì
như ghi lỗi từ MERT. Bộ đệm toàn cầu này sử dụng IOMMU toàn cầu
tên miền và chỉ có MERT mới có thể truy cập được.


Luồng sử dụng cấp cao
===================

Dưới đây là các bước để chạy khối lượng công việc trên AMD NPU:

1. Biên dịch khối lượng công việc thành lớp phủ và tệp nhị phân ZZ0000ZZ.
2. Không gian người dùng mở ngữ cảnh trong trình điều khiển và cung cấp lớp phủ.
3. Trình điều khiển kiểm tra với Bộ giải tài nguyên để cung cấp một tập hợp các cột
    cho khối lượng công việc.
4. Sau đó, trình điều khiển sẽ yêu cầu MERT tạo ngữ cảnh trên thiết bị với mong muốn
    cột.
5. MERT sau đó tạo một phiên bản ERT. MERT cũng ánh xạ Bộ đệm lệnh
    vào bộ nhớ ERT.
6. Sau đó, không gian người dùng sao chép ZZ0001ZZ vào Bộ đệm lệnh.
7. Sau đó, không gian người dùng sẽ tạo bộ đệm lệnh với các con trỏ tới đầu vào, đầu ra và
    bộ đệm lệnh; sau đó nó gửi bộ đệm lệnh với trình điều khiển và đi
    ngủ chờ hoàn thành.
8. Trình điều khiển gửi lệnh qua Hộp thư đến ERT.
9. ERT ZZ0005ZZ ZZ0002ZZ trong bộ đệm lệnh.
10. Việc thực thi ZZ0003ZZ khởi động DMA đến và đi từ máy chủ DDR trong khi
    Mảng AMD XDNA đang chạy.
11. Khi ERT đến cuối ZZ0004ZZ, nó sẽ gửi MSI-X để gửi hoàn thành
    tín hiệu cho người lái xe để đánh thức khối lượng công việc đang chờ.


Luồng khởi động
=========

Trình điều khiển amdxdna sử dụng PSP để tải NPU FW đã ký một cách an toàn và khởi động quá trình khởi động
của vi điều khiển NPU. Trình điều khiển amdxdna sau đó sẽ đợi tín hiệu còn sống trong
một vị trí đặc biệt trên BAR 0. NPU bị tắt trong quá trình tạm dừng SoC và
được bật sau khi tiếp tục trong đó NPU FW được tải lại và quá trình bắt tay được thực hiện
được thực hiện lại.


Thành phần không gian người dùng
====================

Trình biên dịch
--------

Peano là trình biên dịch lõi đơn nguồn mở dựa trên LLVM cho AMD XDNA Array
tính toán gạch. Peano có sẵn tại:
ZZ0000ZZ

IRON là trình biên dịch mảng nguồn mở cho AMD XDNA NPU dựa trên mảng sử dụng
Đậu phộng bên dưới. IRON có sẵn tại:
ZZ0000ZZ

Trình điều khiển chế độ người dùng (UMD)
---------------------

Giao diện ngăn xếp thời gian chạy XRT mã nguồn mở với trình điều khiển hạt nhân amdxdna. XRT
có thể được tìm thấy tại:
ZZ0000ZZ

Bạn có thể tìm thấy miếng chêm XRT mã nguồn mở cho NPU tại:
ZZ0000ZZ


Hoạt động DMA
=============

Hướng dẫn vận hành DMA được mã hóa trong ZZ0000ZZ dưới dạng
Mã hoạt động ZZ0001ZZ. Khi ERT thực thi ZZ0002ZZ, DMA
các hoạt động giữa máy chủ DDR và bộ nhớ L2 được thực hiện.


Xử lý lỗi
==============

Khi MERT phát hiện lỗi trong Mảng AMD XDNA, nó sẽ tạm dừng thực thi lỗi đó
bối cảnh khối lượng công việc và gửi một thông báo không đồng bộ đến trình điều khiển qua
kênh đặc quyền. Trình điều khiển sau đó gửi một con trỏ đệm tới MERT để ghi lại
trạng thái đăng ký cho phân vùng liên quan đến bối cảnh khối lượng công việc bị lỗi. các
trình điều khiển sau đó giải mã lỗi bằng cách đọc nội dung của con trỏ đệm.


Đo từ xa
=========

MERT có thể báo cáo nhiều loại thông tin đo từ xa như sau:

* Bộ đếm ngắt L1
* Bộ đếm DMA
* Bộ đếm giấc ngủ sâu
* v.v.


Tài liệu tham khảo
==========

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ