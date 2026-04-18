.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/arm-ni.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Kết nối chip mạng trên cánh tay PMU
====================================

NI-700 và những người bạn triển khai PMU riêng biệt cho từng miền đồng hồ trong
kết nối với nhau. Tương ứng, trình điều khiển hiển thị nhiều thiết bị PMU có tên
arm_ni_<x>_cd_<y>, trong đó <x> là mã định danh phiên bản (tùy ý) và <y> là
ID miền đồng hồ trong trường hợp cụ thể đó. Nếu nhiều phiên bản NI
tồn tại trong một hệ thống, các thiết bị PMU có thể tương quan với cơ sở
phiên bản phần cứng thông qua nguồn gốc sysfs.

Mỗi PMU hiển thị các bí danh sự kiện cơ bản cho các loại giao diện có trong đồng hồ của nó
miền. Những điều này yêu cầu đủ điều kiện với các tham số "eventid" và "nodeid"
để chỉ định mã sự kiện cần đếm và giao diện để đếm nó
(theo ID phần cứng được định cấu hình như được phản ánh trong thanh ghi xxNI_NODE_INFO).
Ngoại lệ là bí danh "chu kỳ" cho bộ đếm chu kỳ PMU, được mã hóa
với loại nút PMU và không cần trình độ chuyên môn cao hơn.
