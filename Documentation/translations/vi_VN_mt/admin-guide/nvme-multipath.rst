.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/nvme-multipath.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Đa đường Linux NVMe
====================

Tài liệu này mô tả đa đường dẫn NVMe và các chính sách lựa chọn đường dẫn được hỗ trợ
bởi trình điều khiển máy chủ Linux NVMe.


Giới thiệu
============

Tính năng đa đường NVMe trong Linux tích hợp các không gian tên với cùng một
định danh thành một thiết bị khối duy nhất. Sử dụng đa đường nâng cao độ tin cậy
và sự ổn định của truy cập I/O đồng thời cải thiện hiệu suất băng thông. Khi một người dùng
gửi I/O tới thiết bị khối đã hợp nhất này, cơ chế đa đường sẽ chọn một trong các
các thiết bị khối cơ bản (đường dẫn) theo chính sách đã định cấu hình.
Các chính sách khác nhau dẫn đến các lựa chọn đường dẫn khác nhau.


Chính sách
========

Tất cả các chính sách đều tuân theo cơ chế ANA (Truy cập không gian tên bất đối xứng), nghĩa là
rằng khi có sẵn một đường dẫn được tối ưu hóa, nó sẽ được chọn trên một đường dẫn không được tối ưu hóa
một. Các chính sách đa đường NVMe hiện tại bao gồm numa(mặc định), round-robin và
độ sâu hàng đợi.

Để đặt chính sách mong muốn (ví dụ: quay vòng), hãy sử dụng một trong các phương pháp sau:
   1. echo -n "round-robin" > /sys/module/nvme_core/parameters/iopolicy
   2. hoặc thêm "nvme_core.iopolicy=round-robin" vào cmdline.


NUMA
----

Chính sách NUMA chọn đường dẫn gần nhất với nút NUMA của CPU hiện tại cho
Phân phối I/O. Chính sách này duy trì các đường dẫn gần nhất tới mỗi nút NUMA
dựa trên các kết nối giao diện mạng.

Khi nào nên sử dụng chính sách NUMA:
  1. Hệ thống đa lõi: Tối ưu hóa khả năng truy cập bộ nhớ trong hệ thống đa lõi và
     hệ thống đa bộ xử lý, đặc biệt là theo kiến trúc NUMA.
  2. Khối lượng công việc có ái lực cao: Liên kết xử lý I/O với CPU để giảm
     sự chậm trễ trong giao tiếp và truyền dữ liệu giữa các nút.


Vòng tròn
-----------

Chính sách quay vòng phân bổ đồng đều các yêu cầu I/O trên tất cả các đường dẫn tới
nâng cao thông lượng và sử dụng tài nguyên. Mỗi thao tác I/O được gửi tới
đường dẫn tiếp theo theo thứ tự.

Khi nào nên sử dụng chính sách quay vòng:
  1. Khối lượng công việc cân bằng: Hiệu quả đối với khối lượng công việc cân bằng và có thể dự đoán được với
     kích thước và loại I/O tương tự.
  2. Hiệu suất đường dẫn đồng nhất: Sử dụng tất cả các đường dẫn một cách hiệu quả khi
     đặc tính hiệu suất (ví dụ: độ trễ, băng thông) là tương tự nhau.


Độ sâu hàng đợi
-----------

Chính sách độ sâu hàng đợi quản lý các yêu cầu I/O dựa trên độ sâu hàng đợi hiện tại
của mỗi đường dẫn, chọn đường dẫn có số lượng I/O đang hoạt động ít nhất.

Khi nào nên sử dụng chính sách độ sâu hàng đợi:
  1. Tải cao với I/O nhỏ: Cân bằng hiệu quả tải trên các đường dẫn khi
     tải cao và các hoạt động I/O bao gồm các thao tác nhỏ, tương đối
     yêu cầu có kích thước cố định.