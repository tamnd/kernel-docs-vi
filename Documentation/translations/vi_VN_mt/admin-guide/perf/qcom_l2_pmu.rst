.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/qcom_l2_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================================
Đơn vị giám sát hiệu suất bộ nhớ đệm cấp 2 của Qualcomm Technologies (PMU)
=====================================================================

Trình điều khiển này hỗ trợ cụm bộ nhớ đệm L2 có trong Qualcomm Technologies
Centriq SoC. Có nhiều cụm bộ đệm L2 vật lý, mỗi cụm có
sở hữu PMU. Mỗi cụm có một hoặc nhiều CPU liên kết với nó.

Có một logic L2 PMU được hiển thị, tổng hợp các kết quả từ
các PMU vật lý.

Trình điều khiển cung cấp mô tả về các sự kiện và cấu hình có sẵn của nó
tùy chọn trong sysfs, xem /sys/bus/event_source/devices/l2cache_0.

Thư mục "format" mô tả định dạng của các sự kiện.

Các sự kiện có thể được hình dung như một mảng 2 chiều. Mỗi cột thể hiện
một nhóm sự kiện. Có 8 nhóm. Mỗi mục chỉ có một mục
nhóm có thể được sử dụng tại một thời điểm. Nếu nhiều sự kiện từ cùng một nhóm
được chỉ định thì các sự kiện xung đột không thể được tính cùng một lúc.

Các sự kiện được chỉ định là 0xCCG, trong đó CC là 2 chữ số hex chỉ định
mã (hàng mảng) và G chỉ định nhóm (cột) 0-7.

Ngoài ra còn có sự kiện bộ đếm chu kỳ được chỉ định bởi giá trị 0xFE
nằm ngoài sơ đồ trên.

Trình điều khiển cung cấp thuộc tính sysfs "cpumask" chứa mặt nạ
bao gồm một CPU trên mỗi cụm sẽ được sử dụng để xử lý tất cả PMU
các sự kiện trên cụm đó.

Ví dụ để sử dụng với perf::

chỉ số hoàn hảo -e l2cache_0/config=0x001/,l2cache_0/config=0x042/ -a sleep 1

chỉ số hoàn hảo -e l2cache_0/config=0xfe/ -C 2 ngủ 1

Trình điều khiển không hỗ trợ lấy mẫu, do đó "bản ghi hoàn hảo" sẽ
không làm việc. Phiên hoàn thiện mỗi nhiệm vụ không được hỗ trợ.
