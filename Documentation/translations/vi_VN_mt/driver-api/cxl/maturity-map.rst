.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/maturity-map.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============================================================
Tính toán bản đồ trưởng thành của hệ thống con liên kết nhanh
=============================================================

Hệ thống con Linux CXL theo dõi ZZ0000ZZ động
tiếp tục đáp ứng các trường hợp sử dụng mới với các tính năng, khả năng mới
cập nhật và sửa lỗi. Tại bất kỳ thời điểm nào, một số khía cạnh của hệ thống con được
trưởng thành hơn những người khác. Trong khi các yêu cầu kéo định kỳ tóm tắt
ZZ0001ZZ,
những điều đó không phải lúc nào cũng truyền tải sự tiến bộ so với điểm xuất phát và
mục tiêu cuối cùng trong tương lai.

Phần tiếp theo là sự phân tích thô về các chức năng chính của hệ thống con
trách nhiệm cùng với điểm trưởng thành. Kỳ vọng là thế
lịch sử thay đổi của tài liệu này cung cấp một bản tóm tắt tổng quan về
sự trưởng thành của hệ thống con theo thời gian.

Điểm trưởng thành là:

- [3] Trưởng thành: Công việc trong lĩnh vực này đã hoàn tất và không có thay đổi nào trong tương lai.
  Lưu ý rằng điểm này có thể giảm dần từ bản phát hành kernel này sang bản phát hành kernel tiếp theo.
  dựa trên kết quả thử nghiệm mới hoặc báo cáo của người dùng cuối.

- [2] Ổn định: Chức năng chính hoạt động, các trường hợp thường gặp là
  các trường hợp góc đã hoàn thiện nhưng đã biết vẫn đang trong quá trình hoàn thiện.

- [1] Ban đầu: Khả năng đã thoát khỏi giai đoạn Chứng minh khái niệm, nhưng
  có thể vẫn còn những khoảng trống đáng kể cần phải thu hẹp và khắc phục để áp dụng như thực tế
  thử nghiệm thế giới xảy ra.

- [0] Khoảng trống đã biết: Tính năng này nằm trong khoảng thời gian trung và dài hạn để
  thực hiện.  Nếu đặc tả có một tính năng thậm chí không có
  điểm '0' trong tài liệu này thì rất có thể không có ai trong
  cộng đồng linux-cxl@vger.kernel.org đã bắt đầu xem xét nó.

- X: Ngoài phạm vi kích hoạt kernel hoặc không cần kích hoạt kernel

Tính năng và khả năng
========================

Liệt kê/Cung cấp
--------------------------
Tất cả các phép liệt kê cơ bản của một mô hình đối tượng của hệ thống con là
tại chỗ, nhưng có một số trường hợp góc đang chờ xử lý.


* [2] Bảng liệt kê cửa sổ CXL

* [2] ZZ0000ZZ
  * [0] Lỗ bộ nhớ thấp
  * [X] Hetero-xen kẽ

* [2] Bảng liệt kê chuyển đổi

* [0] Phụ thuộc liên kết liên kết đăng ký CXL

* [2] Cấu hình bộ giải mã HDM

* [0] Các ràng buộc về mục tiêu và mức độ chi tiết của bộ giải mã

* [2] Bảng liệt kê hiệu suất

* [3] Điểm cuối CDAT
  * [3] Công tắc CDAT
  * [1] Tích hợp CDAT vào Core-mm

* [1] x86
    * [0] Cánh tay64
    * [0] Tất cả các vòm khác.

* [0] Liên kết được chia sẻ

* [2] Cắm nóng
  (xem Bảng liệt kê cửa sổ CXL)

* [0] Xử lý xung đột dành riêng mềm

* [0] ZZ0000ZZ
* [0] Vải / G-FAM (chương 7)
* [0] Điểm cuối truy cập toàn cầu


RAS
---
Theo nhiều cách, CXL có thể được coi là một tiêu chuẩn hóa của những gì thông thường
được xử lý bởi trình điều khiển EDAC tùy chỉnh. Sự phát triển mở ở đây là
chủ yếu do các trường hợp góc liệt kê ở trên gây ra.

* [3] Sự kiện thành phần (OS)
* [2] Sự kiện thành phần (FFM)
* [1] Lỗi giao thức điểm cuối (OS)
* [1] Lỗi giao thức điểm cuối (FFM)
* [0] Lỗi giao thức chuyển đổi (OS)
* [1] Lỗi giao thức chuyển đổi (FFM)
* [2] DPA->HPA Dịch địa chỉ

* [1] Bản dịch xen kẽ XOR
      (xem Bảng liệt kê cửa sổ CXL)

* [1] Phối hợp suy giảm trí nhớ
* [0] Kiểm soát chà
* [2] Chèn lỗi ACPI EINJ

* [0] EINJ v2
  * [X] Tuân thủ DOE

* [2] Chèn lỗi gốc
* [3] Xử lý lỗi RCH
* [1] Xử lý lỗi VH
* [0] PPR
* [0] Tiết kiệm
* [0] Thiết bị được tích hợp thử nghiệm


Lệnh hộp thư
----------------

* [3] Cập nhật chương trình cơ sở
* [3] Sức khỏe / Cảnh báo
* [1] ZZ0000ZZ
* [3] Vệ sinh
* [3] Lệnh bảo mật
* [3] Thông qua gỡ lỗi lệnh RAW
* [0] Thông qua xác thực chỉ CEL
* [0] Công tắc CCI
* [3] Dấu thời gian
* [1] Nhãn PMEM
* [3] PMEM GPF / Tắt máy bẩn
* [0] Quét phương tiện

PMU
---
* [1] Loại 3 PMU
* [0] Switch USP/ DSP, Cổng gốc

Bảo vệ
--------

* [X] Giao thức bảo mật môi trường thực thi đáng tin cậy CXL (TSP)
* [X] CXL IDE (được gộp bởi TSP)

Tổng hợp bộ nhớ
---------------

* [1] Hotplug của LD (thông qua hotplug PCI)
* [0] Hỗ trợ thiết bị công suất động (DCD)

Chia sẻ nhiều máy chủ
---------------------

* [0] Bộ nhớ chia sẻ gắn kết phần cứng
* [0] Bộ nhớ chia sẻ kết hợp được quản lý bằng phần mềm

Bộ nhớ nhiều máy chủ
--------------------

* [0] Hỗ trợ thiết bị năng lực động
* [0] Chia sẻ

Máy gia tốc
-----------

* [0] Bộ đếm bộ nhớ tăng tốc HDM-D (CXL 1.1/2.0 Loại-2)
* [0] Bộ đếm bộ nhớ tăng tốc HDM-DB (CXL 3.0 Type-2)
* [0] CXL.cache 68b (CXL 2.0)
* [0] ID bộ đệm CXL.cache 256b (CXL 3.0)

Hỗ trợ luồng người dùng
-----------------------

* [2] Tiêm & thải độc theo vùng bù trừ

Chi tiết
========

.. _extended-linear:

* ZZ0001ZZ: Một đề xuất HMAT để liệt kê sự hiện diện của một
  bộ đệm phía bộ nhớ trong đó dung lượng bộ đệm mở rộng địa chỉ SRAT
  công suất phạm vi. ZZ0000ZZ
  để biết thêm chi tiết:

.. _rch-link-status:

* Cấu trúc liên kết ZZ0000ZZ: RCH (Máy chủ CXL bị hạn chế), cuối cùng
  ẩn một số thanh ghi tiêu chuẩn như Trạng thái / Khả năng liên kết PCIe trong
  CXL RCRB (Khối đăng ký phức hợp gốc).

.. _background-commands:

* ZZ0001ZZ: Cơ chế lệnh nền CXL là
  khó xử vì vị trí đơn lẻ có khả năng bị độc quyền vô thời hạn bởi
  các lệnh khác nhau. MỘT ZZ0000ZZ
  cần có cơ sở để đảm bảo hạt nhân có thể đảm bảo tiến độ chuyển tiếp
  của các lệnh ưu tiên.