.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/bios-and-efi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Cấu hình BIOS/EFI
========================

BIOS và EFI chịu trách nhiệm chính trong việc định cấu hình thông tin tĩnh về
các thiết bị (hoặc các thiết bị tiềm năng trong tương lai) để Linux có thể xây dựng hệ thống thích hợp
biểu diễn logic của các thiết bị này.

Ở mức độ cao, đây là những gì xảy ra trong giai đoạn cấu hình này.

* Bộ nạp khởi động khởi động BIOS/EFI.

* BIOS/EFI thực hiện thăm dò thiết bị sớm để xác định cấu hình tĩnh

* BIOS/EFI tạo Bảng ACPI mô tả cấu hình tĩnh cho HĐH

* BIOS/EFI tạo bản đồ bộ nhớ hệ thống (Bản đồ bộ nhớ EFI, E820, v.v.)

* BIOS/EFI gọi ZZ0000ZZ và bắt đầu quá trình Khởi động sớm Linux.

Phần lớn nội dung mà phần này đề cập đến là việc sản xuất và cung cấp Bảng ACPI.
cấu hình bản đồ bộ nhớ tĩnh. Chi tiết hơn về các bảng này có thể được tìm thấy
tại ZZ0000ZZ.

.. note::
   Platform Vendors should read carefully, as this sections has recommendations
   on physical memory region size and alignment, memory holes, HDM interleave,
   and what linux expects of HDM decoders trying to work with these features.


Kỳ vọng của Linux về phần mềm BIOS/EFI
=======================================
Linux mong muốn phần mềm BIOS/EFI xây dựng đủ các bảng ACPI (chẳng hạn như
CEDT, SRAT, HMAT, v.v.) và các cấu hình dành riêng cho nền tảng (chẳng hạn như khoảng trắng HPA
và cấu hình xen kẽ cầu máy chủ) để cho phép trình điều khiển Linux
sau đó định cấu hình các thiết bị trong kết cấu CXL khi chạy.

Không cần lập trình bộ giải mã và cổng chuyển đổi HDM và có thể
được chuyển sang trình điều khiển CXL dựa trên chính sách của quản trị viên (ví dụ: quy tắc udev).

Một số nền tảng có thể yêu cầu lập trình trước bộ giải mã HDM và khóa chúng
do những điều kỳ quặc (xem: bản dịch địa chỉ Zen5), nhưng đây không phải là điều bình thường,
đường dẫn cấu hình "dự kiến".  Điều này nên tránh nếu có thể.

Một số nền tảng có thể muốn định cấu hình trước các tài nguyên này để mang lại bộ nhớ
lên mà không cần hỗ trợ trình điều khiển CXL.  Những nhà cung cấp nền tảng này nên
kiểm tra cấu hình của chúng với trình điều khiển CXL hiện có và cung cấp trình điều khiển
hỗ trợ cấu hình tự động của chúng nếu cần có các tính năng như RAS.

Nền tảng yêu cầu lập trình thời gian khởi động và/hoặc khóa kết cấu CXL
các thành phần có thể ngăn cản hoạt động của các tính năng, chẳng hạn như phích cắm nóng của thiết bị.

Cài đặt UEFI
=============
Nếu nền tảng của bạn hỗ trợ nó, lệnh ZZ0000ZZ có thể được sử dụng để
đọc/ghi cài đặt EFI. Những thay đổi sẽ được phản ánh trong lần khởi động lại tiếp theo. Kexec
khởi động lại không đủ.

Một cấu hình đáng chú ý ở đây là bit EFI_MEMORY_SP (Mục đích cụ thể).
Khi tính năng này được bật, bit này sẽ yêu cầu linux trì hoãn việc quản lý bộ nhớ
vùng sang trình điều khiển (trong trường hợp này là trình điều khiển CXL). Nếu không thì bộ nhớ sẽ
được coi là "bộ nhớ bình thường" và được hiển thị cho bộ cấp phát trang trong
ZZ0000ZZ.

ví dụ về uefisettings
---------------------

ZZ0000ZZ ::

uefisettings xác định

bios_vendor: xxx
        bios_version: xxx
        bios_release: xxx
        bios_date: xxx
        tên_sản phẩm: xxx
        sản phẩm_họ: xxx
        phiên bản sản phẩm: xxx

Trên một số nền tảng AMD, bit ZZ0000ZZ được đặt thông qua trường ZZ0001ZZ.  Điều này có thể được gọi là cái gì đó khác trên nền tảng của bạn.

ZZ0000ZZ ::

bộ chọn: xxx
        ...
câu hỏi: Câu hỏi {
            tên: "Thuộc tính bộ nhớ CXL",
            câu trả lời: "Đã bật",
            ...
        }

Bản đồ bộ nhớ vật lý
====================

Căn chỉnh vùng địa chỉ vật lý
---------------------------------

Kể từ Linux v6.14, hệ thống bộ nhớ cắm nóng yêu cầu các vùng bộ nhớ phải được
thống nhất về kích thước và sự liên kết.  Trong khi thông số kỹ thuật CXL cho phép bộ nhớ
vùng nhỏ tới 256 MB, kích thước khối bộ nhớ được hỗ trợ và căn chỉnh cho
bộ nhớ cắm nóng được xác định theo kiến trúc.

Một khối bộ nhớ Linux có thể nhỏ tới 128MB và có sức mạnh tăng thêm hai.

* Trên ARM, kích thước khối và căn chỉnh mặc định là 128MB hoặc 256MB.

* Trên x86, kích thước khối mặc định là 256MB và tăng lên 2GB khi
  dung lượng của hệ thống tăng lên tới 64GB.

Để được hỗ trợ tốt nhất trên các phiên bản, nhà cung cấp nền tảng nên đặt bộ nhớ CXL ở
địa chỉ cơ sở được căn chỉnh 2GB và các vùng phải được căn chỉnh 2GB.  Điều này cũng giúp
ngăn chặn việc tạo ra hàng nghìn thiết bị bộ nhớ (mỗi khối một thiết bị).

Lỗ bộ nhớ
------------

Các lỗ hổng trên bản đồ bộ nhớ rất phức tạp.  Hãy xem xét một thiết bị 4GB đặt ở chân đế
địa chỉ 0x100000000, nhưng với bản đồ bộ nhớ sau ::

---------------------
  ZZ0000ZZ
  ZZ0001ZZ
  ZZ0002ZZ
  ---------------------
  ZZ0003ZZ
  ZZ0004ZZ
  ZZ0005ZZ
  ---------------------
  ZZ0006ZZ
  ZZ0007ZZ
  ZZ0008ZZ
  ---------------------

Có hai vấn đề cần xem xét:

* lập trình giải mã, và
* căn chỉnh khối bộ nhớ.

Nếu kiến trúc của bạn yêu cầu kích thước đồng nhất 2GB và các khối bộ nhớ được căn chỉnh, thì
dung lượng duy nhất Linux có khả năng ánh xạ (kể từ v6.14) sẽ là dung lượng
từ ZZ0000ZZ.  Công suất còn lại sẽ bị mắc kẹt, vì
chúng không có độ dài liên kết 2GB.

Giả sử cấu hình bộ nhớ và kiến trúc của bạn cho phép khối bộ nhớ 1GB,
bản đồ bộ nhớ này được hỗ trợ và bản đồ này sẽ được trình bày dưới dạng nhiều CFMWS
trong CEDT mô tả riêng từng mặt của lỗ bộ nhớ - cùng với
bộ giải mã phù hợp.

Nhiều bộ giải mã có thể (và nên) được sử dụng để quản lý lỗ bộ nhớ đó (xem
bên dưới), nhưng mỗi đoạn của lỗ bộ nhớ phải được căn chỉnh thành một khối hợp lý
kích thước (căn chỉnh lớn hơn luôn tốt hơn).  Nếu bạn có ý định có lỗ bộ nhớ
trong bản đồ bộ nhớ, dự kiến sẽ sử dụng một bộ giải mã cho mỗi đoạn máy chủ liền kề
bộ nhớ vật lý.

Kể từ v6.14, Linux đã cung cấp hỗ trợ cho việc cắm nóng bộ nhớ của nhiều
các vùng bộ nhớ vật lý được phân tách bằng một lỗ bộ nhớ được mô tả bởi một
Bộ giải mã HDM.


Lập trình giải mã
===================
Nếu BIOS/EFI có ý định lập trình bộ giải mã để được cấu hình tĩnh,
có một số điều cần cân nhắc để tránh những cạm bẫy lớn có thể xảy ra
ngăn chặn khả năng tương thích của Linux.  Một số khuyến nghị này không
được yêu cầu "theo thông số kỹ thuật", nhưng Linux không đảm bảo hỗ trợ
mặt khác.


Điểm dịch
-----------------
Theo thông số kỹ thuật, bộ giải mã duy nhất mà ZZ0000ZZ Host Vật lý
Địa chỉ (HPA) đến Địa chỉ vật lý của thiết bị (DPA) là ZZ0001ZZ.
Tất cả các bộ giải mã khác trong kết cấu đều nhằm mục đích định tuyến các truy cập mà không cần
dịch các địa chỉ

Điều này được ngụ ý rất nhiều bởi đặc điểm kỹ thuật, xem: ::

Đặc điểm kỹ thuật CXL 3.1
  8.2.4.20: Cấu trúc khả năng giải mã CXL HDM
  - Lưu ý triển khai: Luồng giải mã cầu máy chủ và cổng chuyển mạch ngược dòng CXL
  - Lưu ý thực hiện: Logic giải mã thiết bị

Vì điều này, Linux đưa ra một giả định mạnh mẽ rằng các bộ giải mã giữa CPU và
điểm cuối sẽ được lập trình với các dải địa chỉ là tập hợp con của
bộ giải mã gốc của chúng.

Do một số điểm mơ hồ về cách thức thực hiện các thông số kỹ thuật của Kiến trúc, ACPI, PCI và CXL
“Bàn giao” trách nhiệm giữa các miền, một số nền tảng áp dụng sớm
đã cố gắng dịch tại bộ điều khiển bộ nhớ gốc hoặc máy chủ
cầu.  Cấu hình này yêu cầu một phần mở rộng nền tảng cụ thể cho
driver và không được xác nhận chính thức - mặc dù được hỗ trợ.

ZZ0001ZZ ZZ0000ZZ là người thực hiện việc này; nếu không, bạn sẽ phải tự mình làm điều đó
để triển khai hỗ trợ trình điều khiển cho nền tảng của bạn.

Sự xen kẽ và tính linh hoạt của cấu hình
----------------------------------------
Nếu cung cấp xen kẽ cầu nối máy chủ, mục nhập CFMWS trong ZZ0000ZZ phải được trình bày cùng với cầu nối máy chủ đích cho xen kẽ
bộ thiết bị (có thể có nhiều bộ thiết bị phía sau mỗi cầu chủ).

Nếu cung cấp xen kẽ cầu nối nội bộ máy chủ, chỉ có 1 mục nhập CFMWS trong CEDT được
cần thiết cho cầu nối máy chủ đó - nếu nó bao phủ toàn bộ dung lượng của thiết bị
phía sau cầu chủ nhà.

Nếu có ý định cung cấp cho người dùng sự linh hoạt trong việc lập trình bộ giải mã ngoài
root, bạn có thể muốn cung cấp nhiều mục CFMWS trong CEDT dành cho
mục đích khác nhau.  Ví dụ: bạn có thể muốn xem xét thêm:

1) Một mục CFMWS để bao gồm tất cả các cầu nối máy chủ có thể kết nối được.
2) Mục nhập CFMWS để bao gồm tất cả các thiết bị trên một cầu nối máy chủ.
3) Mục nhập CFMWS để bao gồm từng thiết bị.

Một nền tảng có thể chọn thêm tất cả những thứ này hoặc thay đổi chế độ dựa trên BIOS
thiết lập.  Đối với mỗi mục nhập CFMWS, Linux mong đợi các mô tả về
vùng bộ nhớ trong ZZ0000ZZ để xác định số lượng
Các nút NUMA cần được dự trữ trong quá trình khởi động/init sớm.

Kể từ v6.14, Linux sẽ tạo nút NUMA cho mỗi mục nhập CEDT CFMWS, ngay cả khi
mục nhập SRAT phù hợp không tồn tại; tuy nhiên, điều này không được đảm bảo trong
trong tương lai và nên tránh cấu hình như vậy.

Lỗ bộ nhớ
------------
Nếu nền tảng của bạn bao gồm các lỗ bộ nhớ xen kẽ giữa bộ nhớ CXL, thì nó
nên sử dụng nhiều bộ giải mã để bao phủ các vùng bộ nhớ này,
thay vì cố gắng lập trình bộ giải mã để chấp nhận toàn bộ phạm vi và mong đợi
Linux để quản lý sự chồng chéo.

Ví dụ: hãy xem xét Lỗ bộ nhớ được mô tả ở trên ::

---------------------
  ZZ0000ZZ
  ZZ0001ZZ
  ZZ0002ZZ
  ---------------------
  ZZ0003ZZ
  ZZ0004ZZ
  ZZ0005ZZ
  ---------------------
  ZZ0006ZZ
  ZZ0007ZZ
  ZZ0008ZZ
  ---------------------

Giả sử điều này được cung cấp bởi một thiết bị duy nhất được gắn trực tiếp vào cầu chủ,
Linux sẽ mong đợi chương trình giải mã sau ::

-------------- --------------
     ZZ0000ZZ ZZ0001ZZ
     ZZ0002ZZ ZZ0003ZZ
     ZZ0004ZZ ZZ0005ZZ
     -------------- --------------
                ZZ0006ZZ
     -------------- --------------
     ZZ0007ZZ ZZ0008ZZ
     ZZ0009ZZ ZZ0010ZZ
     ZZ0011ZZ ZZ0012ZZ
     -------------- --------------
                ZZ0013ZZ
     -------------- --------------
     ZZ0014ZZ ZZ0015ZZ
     ZZ0016ZZ ZZ0017ZZ
     ZZ0018ZZ ZZ0019ZZ
     -------------- --------------

Với cấu hình CEDT với hai CFMWS mô tả bộ giải mã gốc ở trên.

Linux không đảm bảo hỗ trợ cho các tình huống lỗ hổng bộ nhớ lạ.

Thiết bị đa phương tiện
-----------------------
Trường CFMWS của CEDT có các bit hạn chế đặc biệt mô tả liệu
vùng bộ nhớ được mô tả cho phép bộ nhớ dễ bay hơi hoặc bộ nhớ liên tục (hoặc cả hai). Nếu
nền tảng dự định hỗ trợ:

1) Một thiết bị có nhiều phương tiện hoặc
2) Sử dụng thiết bị bộ nhớ liên tục làm bộ nhớ bình thường

Một nền tảng có thể muốn tạo nhiều mục CEDT CFMWS để mô tả cùng một mục
bộ nhớ, với mục đích cho phép người dùng cuối linh hoạt trong cách bộ nhớ đó
được cấu hình. Linux hiện nay không có yêu cầu cao trong lĩnh vực này.