.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/cxl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Bộ giám sát hiệu suất CXL (CPMU)
=========================================

Thông số kỹ thuật CXL rev 3.0 cung cấp định nghĩa về Hiệu suất CXL
Đơn vị giám sát trong phần 13.2: Giám sát hiệu suất.

Các thành phần CXL (ví dụ: Cổng gốc, Cổng chuyển mạch ngược dòng, Điểm cuối) có thể có
bất kỳ số lượng phiên bản CPMU nào. Các khả năng của CPMU hoàn toàn có thể được khám phá từ
các thiết bị. Thông số kỹ thuật cung cấp các định nghĩa sự kiện cho tất cả giao thức CXL
các loại thông báo và một tập hợp các sự kiện bổ sung cho những thứ thường được tính vào
Thiết bị CXL (ví dụ: sự kiện DRAM).

Trình điều khiển CPMU
=====================

Trình điều khiển CPMU đăng ký PMU hoàn hảo với tên pmu_mem<X>.<Y> trên bus CXL
đại diện cho Yth CPMU cho memX.

/sys/bus/cxl/device/pmu_mem<X>.<Y>

PMU liên quan được đăng ký là

/sys/bus/event_sources/devices/cxl_pmu_mem<X>.<Y>

Điểm chung với các thiết bị bus CXL khác, id không có ý nghĩa cụ thể và
mối quan hệ với thiết bị CXL cụ thể phải được thiết lập thông qua thiết bị gốc
của thiết bị trên bus CXL.

Trình điều khiển PMU cung cấp mô tả về các sự kiện có sẵn và các tùy chọn bộ lọc trong sysfs.

Thư mục "format" mô tả tất cả các định dạng của cấu hình (id nhà cung cấp sự kiện,
id nhóm và mặt nạ) config1 (ngưỡng, bật bộ lọc) và config2 (bộ lọc
tham số) của cấu trúc perf_event_attr.  Thư mục "sự kiện"
mô tả tất cả các sự kiện được ghi lại trong danh sách hoàn hảo.

Các sự kiện được hiển thị trong danh sách hoàn hảo là những sự kiện chi tiết nhất với một
bit của bộ mặt nạ sự kiện. Các sự kiện chung hơn có thể được kích hoạt bằng cách cài đặt
nhiều bit mặt nạ trong config. Ví dụ: tất cả các Yêu cầu đọc từ thiết bị đến máy chủ
có thể được ghi lại trên một bộ đếm bằng cách đặt các bit cho tất cả

* d2h_req_rdcurr
* d2h_req_rdown
* d2h_req_rdshared
* d2h_req_rdany
* d2h_req_rdownnodata

Ví dụ về cách sử dụng::

Danh sách $#perf
  cxl_pmu_mem0.0/clock_ticks/ [Sự kiện hạt nhân PMU]
  cxl_pmu_mem0.0/d2h_req_rdshared/ [Sự kiện hạt nhân PMU]
  cxl_pmu_mem0.0/h2d_req_snpcur/ [Sự kiện hạt nhân PMU]
  cxl_pmu_mem0.0/h2d_req_snpdata/ [Sự kiện hạt nhân PMU]
  cxl_pmu_mem0.0/h2d_req_snpinv/ [Sự kiện hạt nhân PMU]
  ----------------------------------------------------------

$# perf thống kê -a -e cxl_pmu_mem0.0/clock_ticks/ -e cxl_pmu_mem0.0/d2h_req_rdshared/

Các sự kiện cụ thể của nhà cung cấp cũng có thể có sẵn và nếu có thì có thể được sử dụng thông qua

$# perf chỉ số -a -e cxl_pmu_mem0.0/vid=VID,gid=GID,mask=MASK/

Trình điều khiển không hỗ trợ lấy mẫu nên "bản ghi hoàn hảo" không được hỗ trợ.
Nó chỉ hỗ trợ tính toán trên toàn hệ thống nên việc gắn vào một tác vụ là điều không thể tránh khỏi.
không được hỗ trợ.