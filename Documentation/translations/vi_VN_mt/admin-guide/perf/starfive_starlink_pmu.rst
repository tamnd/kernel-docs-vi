.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/starfive_starlink_pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Thiết bị giám sát hiệu suất StarFive StarLink (PMU)
====================================================

Thiết bị giám sát hiệu suất StarFive StarLink (PMU) tồn tại trong
Mạng kết hợp StarLink trên Chip (CNoC) kết nối nhiều CPU
cụm với hệ thống bộ nhớ L3.

PMU uncore hỗ trợ ngắt tràn, tối đa 16 64 bit có thể lập trình
bộ đếm sự kiện và bộ đếm chu kỳ 64 bit độc lập.
PMU chỉ có thể được truy cập thông qua I/O được ánh xạ bộ nhớ và phổ biến cho
lõi được kết nối với cùng một PMU.

Trình điều khiển hiển thị các sự kiện PMU được hỗ trợ trong thư mục "sự kiện" sysfs trong::

/sys/bus/event_source/devices/staryear_starlink_pmu/events/

Trình điều khiển hiển thị cpu được sử dụng để xử lý các sự kiện PMU trong thư mục "cpumask" của sysfs
dưới::

/sys/bus/event_source/devices/staryear_starlink_pmu/cpumask/

Trình điều khiển mô tả định dạng của cấu hình (ID sự kiện) trong thư mục "định dạng" sysfs
dưới::

/sys/bus/event_source/devices/staryear_starlink_pmu/format/

Ví dụ về cách sử dụng hoàn hảo::

danh sách hoàn hảo $

staryear_starlink_pmu/cycles/ [Sự kiện hạt nhân PMU]
	star five_starlink_pmu/read_hit/ [Sự kiện hạt nhân PMU]
	star five_starlink_pmu/read_miss/ [Sự kiện hạt nhân PMU]
	staryear_starlink_pmu/read_request/ [Sự kiện hạt nhân PMU]
	staryear_starlink_pmu/release_request/ [Sự kiện hạt nhân PMU]
	star five_starlink_pmu/write_hit/ [Sự kiện hạt nhân PMU]
	staryear_starlink_pmu/write_miss/ [Sự kiện hạt nhân PMU]
	star five_starlink_pmu/write_request/ [Sự kiện hạt nhân PMU]
	staryear_starlink_pmu/writeback/ [Sự kiện hạt nhân PMU]


$ perf stat -a -e /starnăm_starlink_pmu/cycles/ ngủ 1

Lấy mẫu không được hỗ trợ. Kết quả là "bản ghi hoàn hảo" không được hỗ trợ.
Việc đính kèm vào một tác vụ không được hỗ trợ, chỉ hỗ trợ tính toán trên toàn hệ thống.
