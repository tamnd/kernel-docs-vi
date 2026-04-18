.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/arm_dsu_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
ARM Thiết bị chia sẻ DynamIQ (DSU) PMU
======================================

Thiết bị chia sẻ ARM DynamIQ tích hợp một hoặc nhiều lõi với hệ thống bộ nhớ L3,
logic điều khiển và các giao diện bên ngoài để tạo thành một cụm đa lõi. PMU
cho phép đếm các sự kiện khác nhau liên quan đến bộ đệm L3, Bộ điều khiển Snoop
v.v., sử dụng bộ đếm độc lập 32 bit. Nó cũng cung cấp bộ đếm chu kỳ 64bit.

PMU chỉ có thể được truy cập thông qua các thanh ghi hệ thống CPU và được dùng chung cho
lõi được kết nối với cùng một DSU. Giống như hầu hết các PMU không cốt lõi khác, DSU
PMU không hỗ trợ các sự kiện cụ thể của quy trình và không thể sử dụng ở chế độ lấy mẫu.

DSU cung cấp bitmap cho một tập hợp con các sự kiện được triển khai thông qua phần cứng
sổ đăng ký. Không có cách nào để người lái xe xác định liệu các sự kiện khác có
có sẵn hay không. Do đó trình điều khiển chỉ hiển thị những sự kiện được quảng cáo
bởi DSU, trong thư mục "sự kiện" bên dưới::

/sys/bus/event_sources/devices/arm_dsu_<N>/

Người dùng nên tham khảo TRM của sản phẩm để tìm hiểu các sự kiện được hỗ trợ
và sử dụng mã sự kiện thô cho các sự kiện không được liệt kê.

Trình điều khiển cũng hiển thị các CPU được kết nối với phiên bản DSU trong "liên kết_cpus".


ví dụ: cách sử dụng::

chỉ số hoàn hảo -a -e arm_dsu_0/cycles/
