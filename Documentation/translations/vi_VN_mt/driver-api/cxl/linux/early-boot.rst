.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/linux/early-boot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Linux Init (Khởi động sớm)
==========================

Cấu hình Linux được chia thành hai bước chính: Khởi động sớm và mọi bước khác.

Trong quá trình khởi động ban đầu, Linux thiết lập các tài nguyên bất biến (chẳng hạn như các nút numa), trong khi
các hoạt động sau này bao gồm những thứ như thăm dò trình điều khiển và cắm nóng bộ nhớ.  Linux có thể
đọc thông tin EFI và ACPI trong suốt quá trình này để định cấu hình logic
biểu diễn của các thiết bị.

Trong giai đoạn Khởi động sớm của Linux (các hàm trong kernel có __init
trang trí), hệ thống lấy tài nguyên được tạo bởi EFI/BIOS
(ZZ0000ZZ) và biến chúng thành tài nguyên mà
hạt nhân có thể tiêu thụ.


BIOS, Tùy chọn xây dựng và khởi động
====================================

Có 4 tùy chọn tiền khởi động cần được xem xét trong quá trình xây dựng kernel
quy định cách Linux sẽ quản lý bộ nhớ trong quá trình khởi động sớm.

* EFI_MEMORY_SP

* Tùy chọn BIOS/EFI cho biết bộ nhớ là SystemRAM hay
    Mục đích cụ thể.  Bộ nhớ mục đích cụ thể sẽ được hoãn lại
    trình điều khiển để quản lý - và không được hiển thị ngay lập tức như hệ thống RAM.

* CONFIG_EFI_SOFT_RESERVE

* Tùy chọn cấu hình Linux Build cho biết kernel có hỗ trợ hay không
    Bộ nhớ mục đích cụ thể.

* CONFIG_MHP_DEFAULT_ONLINE_TYPE

* Cấu hình Linux Build quyết định liệu bộ nhớ Mục đích Cụ thể có hay không và như thế nào
    được chuyển đổi sang thiết bị dax nên được quản lý (để lại dưới dạng DAX hoặc trực tuyến dưới dạng
    SystemRAM ở dạng ZONE_NORMAL hoặc ZONE_MOVABLE).

* không có phần mềm dự trữ

* Tùy chọn khởi động nhân Linux cho biết có nên sử dụng Dự trữ mềm hay không
    được hỗ trợ.  Tương tự với CONFIG_EFI_SOFT_RESERVE

Tạo bản đồ bộ nhớ
===================

Trong khi kernel phân tích bản đồ bộ nhớ EFI, nếu bộ nhớ ZZ0000ZZ
được hỗ trợ và phát hiện, nó sẽ đặt vùng này sang một bên làm
ZZ0001ZZ.

Nếu ZZ0000ZZ, ZZ0001ZZ, hoặc
ZZ0002ZZ - Linux sẽ mặc định vùng bộ nhớ thiết bị CXL thành
Hệ thốngRAM.  Điều này sẽ hiển thị bộ nhớ cho bộ cấp phát trang kernel trong
ZZ0003ZZ, giúp nó có sẵn để sử dụng cho hầu hết các phân bổ (bao gồm cả
ZZ0004ZZ và bảng trang).

Nếu ZZ0005ZZ được thiết lập và hỗ trợ, ZZ0000ZZ
cho biết bộ nhớ có được trực tuyến theo mặc định hay không (ZZ0001ZZ hoặc
ZZ0002ZZ) và nếu trực tuyến, vùng nào sẽ trực tuyến bộ nhớ này theo mặc định
(ZZ0003ZZ hoặc ZZ0004ZZ).

Nếu được đặt trong ZZ0000ZZ, hầu hết bộ nhớ sẽ không còn trống
phân bổ kernel (chẳng hạn như ZZ0001ZZ hoặc bảng trang).  Điều này có thể
hiệu suất tác động đáng kể tùy thuộc vào dung lượng bộ nhớ của hệ thống.


Đặt trước nút NUMA
=====================

Linux đề cập đến các miền lân cận (ZZ0000ZZ) được xác định trong ZZ0001ZZ để tạo các nút NUMA trong ZZ0002ZZ.
Thông thường, có mối quan hệ 1:1 giữa ID nút ZZ0003ZZ và NUMA.

SRAT là cách duy nhất được xác định bởi ACPI để xác định Miền lân cận. Linux
chọn tối đa ánh xạ 1:1 đó với các nút NUMA.
ZZ0000ZZ thêm mô tả về phạm vi SPA
Linux có thể ánh xạ tới một hoặc nhiều nút NUMA.

Nếu có các dãy CXL trong CFMWS nhưng không có trong SRAT thì đó là ZZ0000ZZ giả
được tạo (kể từ v6.15). Trong tương lai, Linux có thể từ chối CFMWS không được mô tả
bởi SRAT do sự mơ hồ của liên kết miền lân cận.

Điều quan trọng cần lưu ý là việc tạo nút NUMA không thể được thực hiện trong thời gian chạy. Tất cả
các nút NUMA có thể được xác định tại thời điểm ZZ0000ZZ, cụ thể hơn
trong ZZ0001ZZ. CEDT và SRAT phải chứa đủ ZZ0002ZZ
dữ liệu cho Linux để xác định các nút NUMA, vùng bộ nhớ liên quan của chúng.

Mã liên quan tồn tại trong: ZZ0000ZZ.

Xem ZZ0000ZZ
để biết thêm thông tin.

Tạo tầng bộ nhớ
=====================
Các tầng bộ nhớ là tập hợp các nút NUMA được nhóm theo đặc điểm hiệu suất.
Trong ZZ0000ZZ, Linux khởi tạo hệ thống với tầng bộ nhớ mặc định
chứa tất cả các nút được đánh dấu ZZ0001ZZ.

ZZ0000ZZ được gọi khi khởi động cho tất cả các nút có bộ nhớ trực tuyến bằng cách
mặc định. ZZ0001ZZ được gọi trong quá trình khởi tạo muộn để thiết lập nút
trong quá trình cấu hình trình điều khiển.

Các nút chỉ được đánh dấu là ZZ0000ZZ nếu chúng có bộ nhớ ZZ0001ZZ.

Thành viên cấp bậc có thể được kiểm tra trong ::

/sys/devices/virtual/memory_tiering/memory_tierN/nodelist
  0-1

Nếu các nút được nhóm lại có sự khác biệt rõ ràng về hiệu suất, hãy kiểm tra
Thông tin ZZ0000ZZ và CDAT cho các nút CXL. Tất cả
các nút mặc định ở tầng DRAM, trừ khi thông tin HMAT/CDAT được báo cáo cho
thành phần bộ nhớ_tier thông qua ZZ0001ZZ.

Để biết thêm, xem ZZ0000ZZ.

Phân bổ bộ nhớ liền kề
============================
Bộ cấp phát bộ nhớ liền kề (CMA) cho phép đặt trước bộ nhớ liền kề
các vùng trên các nút NUMA trong quá trình khởi động sớm.  Tuy nhiên, CMA không thể dự trữ bộ nhớ
trên các nút NUMA không trực tuyến trong quá trình khởi động sớm. ::

void __init Hugetlb_cma_reserve(void) {
    if (!node_online(nid))
      /*không cho phép đặt chỗ*/
  }

Điều này có nghĩa là nếu người dùng có ý định trì hoãn việc quản lý bộ nhớ CXL cho trình điều khiển, CMA
không thể được sử dụng để đảm bảo phân bổ trang lớn.  Nếu bật bộ nhớ CXL làm
SystemRAM trong ZZ0002ZZ trong quá trình khởi động sớm, việc đặt trước CMA trên mỗi nút có thể được thực hiện
được tạo bằng dòng lệnh kernel ZZ0000ZZ hoặc ZZ0001ZZ
các thông số.