.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/htm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _htm:

======================================
HTM (Macro theo dõi phần cứng)
======================================

Athira Rajeev, ngày 2 tháng 3 năm 2025

.. contents::
    :depth: 3


Tổng quan cơ bản
================

H_HTM được sử dụng làm giao diện để thực thi Macro theo dõi phần cứng (HTM)
các chức năng, bao gồm thiết lập, cấu hình, kiểm soát và kết xuất dữ liệu HTM.
Để sử dụng HTM, cần phải thiết lập bộ đệm HTM và các thao tác HTM có thể
được điều khiển bằng hcall H_HTM. hcall có thể được gọi cho bất kỳ lõi/chip nào
của hệ thống từ bên trong một phân vùng. Để sử dụng tính năng này, một debugfs
thư mục có tên "htmdump" nằm trong /sys/kernel/debug/powerpc.


Ví dụ sử dụng gỡ lỗi HTM
=========================

.. code-block:: sh

  #  ls /sys/kernel/debug/powerpc/htmdump/
  coreindexonchip  htmcaps  htmconfigure  htmflags  htminfo  htmsetup
  htmstart  htmstatus  htmtype  nodalchipindex  nodeindex  trace

Chi tiết trên từng file:

* nodeindex, nodalchipindex, coreindexonchip chỉ định phân vùng nào sẽ cấu hình HTM.
* htmtype: chỉ định loại HTM. Mục tiêu được hỗ trợ là hardwareTarget.
* dấu vết: là để đọc dữ liệu HTM.
* htmconfigure: Cấu hình/Giải cấu hình HTM. Ghi 1 vào tệp sẽ định cấu hình dấu vết, ghi 0 vào tệp sẽ thực hiện giải cấu hình.
* htmstart: bắt đầu/Dừng HTM. Viết 1 vào tệp sẽ bắt đầu theo dõi, ghi 0 vào tệp sẽ dừng việc theo dõi.
* htmstatus: lấy trạng thái của HTM. Điều này là cần thiết để hiểu trạng thái HTM sau mỗi thao tác.
* htmsetup: đặt kích thước bộ đệm HTM. Kích thước của bộ đệm HTM có sức mạnh bằng 2
* htminfo: cung cấp chi tiết cấu hình bộ xử lý hệ thống. Điều này là cần thiết để hiểu các giá trị thích hợp cho nodeindex, nodalchipindex, coreindexonchip.
* htmcaps : cung cấp các khả năng của HTM như kích thước bộ đệm tối thiểu/tối đa, loại truy tìm mà HTM hỗ trợ, v.v.
* htmflags : cho phép truyền cờ tới hcall. Hiện hỗ trợ kiểm soát việc gói bộ đệm HTM.

Để xem chi tiết cấu hình bộ xử lý hệ thống:

.. code-block:: sh

  # cat /sys/kernel/debug/powerpc/htmdump/htminfo > htminfo_file

Kết quả có thể được giải thích bằng cách sử dụng hexdump.

Để thu thập dấu vết HTM cho phân vùng được biểu thị bằng nodeindex dưới dạng
0, nodalchipindex là 1 và coreindexonchip là 12

.. code-block:: sh

  # cd /sys/kernel/debug/powerpc/htmdump/
  # echo 2 > htmtype
  # echo 33 > htmsetup ( sets 8GB memory for HTM buffer, number is size in power of 2 )

Điều này yêu cầu khởi động lại CEC để phân bổ bộ đệm HTM.

.. code-block:: sh

  # cd /sys/kernel/debug/powerpc/htmdump/
  # echo 2 > htmtype
  # echo 0 > nodeindex
  # echo 1 > nodalchipindex
  # echo 12 > coreindexonchip
  # echo 1 > htmflags     # to set noWrap for HTM buffers
  # echo 1 > htmconfigure # Configure the HTM
  # echo 1 > htmstart     # Start the HTM
  # echo 0 > htmstart     # Stop the HTM
  # echo 0 > htmconfigure # Deconfigure the HTM
  # cat htmstatus         # Dump the status of HTM entries as data

Ở trên sẽ đặt chi tiết htmtype và cốt lõi, sau đó thực hiện thao tác HTM tương ứng.

Đọc dữ liệu theo dõi HTM
========================

Sau khi bắt đầu thu thập dấu vết, hãy chạy khối lượng công việc
quan tâm. Dừng thu thập dấu vết sau khoảng thời gian yêu cầu
về thời gian và đọc tệp dấu vết.

.. code-block:: sh

  # cat /sys/kernel/debug/powerpc/htmdump/trace > trace_file

Tệp theo dõi này sẽ chứa các dấu vết hướng dẫn có liên quan
được thu thập trong quá trình thực hiện khối lượng công việc. Và có thể được sử dụng như
tập tin đầu vào cho bộ giải mã dấu vết để hiểu dữ liệu.

Lợi ích của việc sử dụng giao diện debugfs HTM
==============================================

Hiện tại có thể thu thập dấu vết cho một lõi/chip cụ thể
từ bên trong bất kỳ phân vùng nào của hệ thống và giải mã nó. Thông qua
khả năng này, một phân vùng nhỏ có thể được dành riêng để thu thập
theo dõi dữ liệu và phân tích để cung cấp thông tin quan trọng cho Hiệu suất
phân tích, điều chỉnh phần mềm hoặc gỡ lỗi phần cứng.