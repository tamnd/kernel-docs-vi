.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Hướng dẫn công nghệ truy tìm Linux
====================================

Truy tìm trong nhân Linux là một cơ chế mạnh mẽ cho phép
nhà phát triển và quản trị viên hệ thống để phân tích và gỡ lỗi hệ thống
hành vi. Hướng dẫn này cung cấp tài liệu về các cách truy vết khác nhau
các khung và công cụ có sẵn trong nhân Linux.

Giới thiệu về Truy tìm
-----------------------

Phần này cung cấp cái nhìn tổng quan về cơ chế theo dõi Linux
và các phương pháp gỡ lỗi.

.. toctree::
   :maxdepth: 1

   debugging
   tracepoints
   tracepoint-analysis
   ring-buffer-map

Khung theo dõi cốt lõi
-----------------------

Sau đây là các khung theo dõi chính được tích hợp vào
nhân Linux.

.. toctree::
   :maxdepth: 1

   ftrace
   ftrace-design
   ftrace-uses
   kprobes
   kprobetrace
   fprobetrace
   eprobetrace
   fprobe
   ring-buffer-design

Theo dõi và phân tích sự kiện
-----------------------------

Giải thích chi tiết về cơ chế theo dõi sự kiện và các cơ chế của chúng
ứng dụng.

.. toctree::
   :maxdepth: 1

   events
   events-kmem
   events-power
   events-nmi
   events-msr
   events-pci
   events-pci-controller
   boottime-trace
   histogram
   histogram-design

Theo dõi phần cứng và hiệu suất
--------------------------------

Phần này bao gồm các tính năng theo dõi giám sát phần cứng
tương tác và hiệu suất hệ thống.

.. toctree::
   :maxdepth: 1

   intel_th
   stm
   sys-t
   coresight/index
   rv/index
   hisi-ptt
   mmiotrace
   hwlat_detector
   osnoise-tracer
   timerlat-tracer

Theo dõi không gian người dùng
------------------------------

Những công cụ này cho phép theo dõi các ứng dụng trong không gian người dùng và
tương tác.

.. toctree::
   :maxdepth: 1

   user_events
   uprobetracer

Theo dõi từ xa
--------------

Phần này trình bày khuôn khổ để đọc các bộ đệm vòng tương thích, được viết bởi
các thực thể bên ngoài kernel (rất có thể là phần sụn hoặc bộ ảo hóa)

.. toctree::
   :maxdepth: 1

   remotes

Tài nguyên bổ sung
--------------------

Để biết thêm chi tiết, hãy tham khảo tài liệu tương ứng của từng
công cụ và khuôn khổ truy tìm.
