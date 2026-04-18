.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/qcom_l3_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================================================
Thiết bị giám sát hiệu suất bộ nhớ đệm L3 của Qualcomm Datacenter Technologies (PMU)
====================================================================================

Trình điều khiển này hỗ trợ PMU bộ đệm L3 có trong Công nghệ trung tâm dữ liệu Qualcomm
Centriq SoC. Bộ đệm L3 trên các SOC này bao gồm nhiều lát, được chia sẻ
bởi tất cả các lõi trong một ổ cắm. Mỗi lát cắt được hiển thị dưới dạng một màn trình diễn uncore riêng biệt
PMU với tên thiết bị l3cache_<socket>_<instance>. Không gian người dùng chịu trách nhiệm
để tổng hợp trên các lát.

Trình điều khiển cung cấp mô tả về các sự kiện và cấu hình có sẵn của nó
tùy chọn trong sysfs, xem /sys/bus/event_source/devices/l3cache*. Cho rằng đây là những PMU không cốt lõi
trình điều khiển cũng hiển thị thuộc tính sysfs "cpumask" có chứa mặt nạ
bao gồm một CPU trên mỗi ổ cắm sẽ được sử dụng để xử lý tất cả PMU
các sự kiện trên socket đó.

Phần cứng triển khai bộ đếm sự kiện 32 bit và có không gian sự kiện 8 bit phẳng
được hiển thị thông qua thuộc tính định dạng "sự kiện". Ngoài 32bit vật lý
bộ đếm trình điều khiển hỗ trợ bộ đếm phần cứng 64bit ảo bằng cách sử dụng phần cứng
truy cập chuỗi. Tính năng này được hiển thị thông qua định dạng "lc" (bộ đếm dài)
cờ. Ví dụ.::

chỉ số hoàn hảo -e l3cache_0_0/read-miss,lc/

Do đây là các PMU không lõi nên trình điều khiển không hỗ trợ lấy mẫu, do đó
"Bản ghi hoàn hảo" sẽ không hoạt động. Phiên hoàn thiện mỗi nhiệm vụ không được hỗ trợ.
