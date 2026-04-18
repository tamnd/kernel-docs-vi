.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/acpi/cppc_sysfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================================
Kiểm soát hiệu suất bộ xử lý cộng tác (CPPC)
======================================================

.. _cppc_sysfs:

CPPC
====

CPPC được xác định trong thông số ACPI mô tả cơ chế để HĐH quản lý
hiệu suất của bộ xử lý logic trên hiệu suất liền kề và trừu tượng
quy mô. CPPC hiển thị một bộ thanh ghi để mô tả thang đo hiệu suất trừu tượng,
để yêu cầu mức hiệu suất và đo lường hiệu suất được phân phối trên mỗi CPU.

Để biết thêm chi tiết về CPPC vui lòng tham khảo thông số kỹ thuật ACPI tại:

ZZ0000ZZ

Một số thanh ghi CPPC được hiển thị thông qua sysfs trong ::

/sys/devices/system/cpu/cpuX/acpi_cppc/

cho mỗi CPU X::

$ ls -lR /sys/devices/system/cpu/cpu0/acpi_cppc/
  /sys/devices/system/cpu/cpu0/acpi_cppc/:
  tổng 0
  -r--r--r-- 1 gốc gốc 65536 5 tháng 3 19:38 phản hồi_ctrs
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 cao nhất_perf
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 thấp nhất_freq
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 low_nonTuyến_perf
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 thấp nhất_perf
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 danh nghĩa_freq
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 danh nghĩa_perf
  -r--r--r-- 1 gốc gốc 65536 5 tháng 3 19:38 reference_perf
  -r--r--r-- 1 gốc gốc 65536 Ngày 5 tháng 3 19:38 bao quanh_time

*high_perf : Hiệu suất cao nhất của bộ xử lý này (thang trừu tượng).
* danh_perf : Hiệu suất bền vững cao nhất của bộ xử lý này
  (thang đo trừu tượng).
* low_nonTuyến_perf : Hiệu suất thấp nhất của bộ xử lý này với phi tuyến
  tiết kiệm năng lượng (thang trừu tượng).
* low_perf : Hiệu suất thấp nhất của bộ xử lý này (thang trừu tượng).

* low_freq : Tần số CPU tương ứng với low_perf (tính bằng MHz).
* danh_freq : Tần số CPU tương ứng với danh nghĩa_perf (tính bằng MHz).
  Các tần số trên chỉ nên được sử dụng để báo cáo hiệu suất của bộ xử lý trong
  tần số thay vì thang đo trừu tượng. Những giá trị này không nên được sử dụng cho bất kỳ
  các quyết định chức năng.

*feedback_ctrs : Bao gồm cả bộ đếm hiệu suất Tham chiếu và được phân phối.
  Bộ đếm tham chiếu tăng tỷ lệ thuận với hiệu suất tham chiếu của bộ xử lý.
  Số đếm được phân phối tăng tỷ lệ thuận với hiệu suất được phân phối của bộ xử lý.
* quấn quanh_time: Thời gian tối thiểu để bộ đếm phản hồi hoàn thành
  (giây).
* reference_perf : Mức hiệu suất tại đó bộ đếm hiệu suất tham chiếu
  tích lũy (thang đo trừu tượng).


Hiệu suất tính toán trung bình được phân phối
=======================================

Dưới đây mô tả các bước để tính hiệu suất trung bình được cung cấp bởi
chụp hai ảnh chụp nhanh khác nhau của bộ đếm phản hồi tại thời điểm T1 và T2.

T1: Đọc thông tin phản hồi_ctrs dưới dạng fbc_t1
      Chờ hoặc chạy một số khối lượng công việc

T2: Đọc thông tin phản hồi_ctrs dưới dạng fbc_t2

::

đã giao_counter_delta = fbc_t2[del] - fbc_t1[del]
  tham chiếu_counter_delta = fbc_t2[ref] - fbc_t1[ref]

đã giao_perf = (reference_perf x đã giao_counter_delta) / reference_counter_delta