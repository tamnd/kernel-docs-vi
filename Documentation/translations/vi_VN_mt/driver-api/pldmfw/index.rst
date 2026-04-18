.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pldmfw/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Thư viện cập nhật Flash Firmware PLDM
==================================

ZZ0000ZZ triển khai chức năng cập nhật flash trên thiết bị bằng cách sử dụng
PLDM dành cho tiêu chuẩn Cập nhật chương trình cơ sở
<ZZ0001ZZ

.. toctree::
   :maxdepth: 1

   file-format
   driver-ops

Tổng quan về thư viện ZZ0000ZZ
==================================

Thư viện ZZ0000ZZ được thiết kế để trình điều khiển thiết bị sử dụng cho
triển khai cập nhật flash thiết bị dựa trên các tệp chương trình cơ sở theo PLDM
định dạng tập tin phần sụn.

Nó được triển khai bằng cách sử dụng bảng ops cho phép trình điều khiển thiết bị cung cấp
chức năng cụ thể của thiết bị cơ bản.

ZZ0000ZZ triển khai logic để phân tích định dạng nhị phân đóng gói của PLDM
tập tin chương trình cơ sở vào cấu trúc dữ liệu và sau đó sử dụng chức năng được cung cấp
hoạt động để xác định xem tệp chương trình cơ sở có phù hợp với thiết bị hay không. Nếu
vì vậy, nó sẽ gửi bản ghi và dữ liệu thành phần tới phần sụn bằng thiết bị
triển khai cụ thể được cung cấp bởi trình điều khiển thiết bị. Một khi thiết bị
chương trình cơ sở cho biết rằng bản cập nhật có thể được thực hiện, dữ liệu chương trình cơ sở được
gửi đến thiết bị để lập trình.

Phân tích tệp PLDM
=====================

Định dạng tệp PLDM sử dụng dữ liệu nhị phân được đóng gói, với hầu hết các trường nhiều byte
được lưu trữ ở định dạng Little Endian. Một số phần dữ liệu có thể thay đổi
độ dài, bao gồm các chuỗi phiên bản và số lượng bản ghi và thành phần.
Do đó, việc lập chỉ mục bản ghi, bản ghi là không dễ dàng
mô tả, hoặc các thành phần.

Để tránh tăng cường truy cập vào dữ liệu nhị phân được đóng gói, ZZ0000ZZ
thư viện phân tích và trích xuất dữ liệu này thành các cấu trúc đơn giản hơn để dễ dàng
truy cập.

Để xử lý tệp chương trình cơ sở một cách an toàn, cần cẩn thận để tránh
quyền truy cập không được phân bổ của các trường nhiều byte và chuyển đổi chính xác từ Little
Định dạng máy chủ Endian sang CPU. Ngoài ra, các bản ghi, mô tả và
các thành phần được lưu trữ trong danh sách liên kết.

Thực hiện cập nhật flash
=========================

Để thực hiện cập nhật flash, mô-đun ZZ0000ZZ thực hiện như sau
bước

1. Phân tích tệp chương trình cơ sở để biết thông tin về bản ghi và thành phần
2. Quét qua các bản ghi và xác định xem thiết bị có khớp với bản ghi nào không
   trong tập tin. Bản ghi phù hợp đầu tiên sẽ được sử dụng.
3. Nếu bản ghi trùng khớp cung cấp dữ liệu gói, hãy gửi dữ liệu gói này tới
   thiết bị.
4. Đối với mỗi thành phần mà bản ghi chỉ ra, hãy gửi dữ liệu thành phần đó tới
   thiết bị. Đối với mỗi thành phần, phần sụn có thể phản hồi bằng một
   dấu hiệu cho biết bản cập nhật có phù hợp hay không. Nếu bất kỳ thành phần nào
   không phù hợp, bản cập nhật bị hủy.
5. Đối với mỗi thành phần, hãy gửi dữ liệu nhị phân đến chương trình cơ sở của thiết bị để
   đang cập nhật.
6. Sau khi tất cả các thành phần được lập trình, hãy thực hiện bất kỳ thao tác cuối cùng nào dành riêng cho thiết bị
   hành động để hoàn tất việc cập nhật.