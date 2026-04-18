.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/imc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _imc:

======================================
IMC (Bộ đếm bộ nhớ trong bộ nhớ)
===================================

Anju T Sudhakar, ngày 10 tháng 5 năm 2019

.. contents::
    :depth: 3


Tổng quan cơ bản
==============

IMC (Bộ đếm bộ nhớ trong bộ nhớ) là một cơ sở giám sát phần cứng
thu thập số lượng lớn các sự kiện hiệu suất phần cứng ở cấp độ Nest (đây là
trên chip nhưng ngoài lõi), cấp độ lõi và cấp độ luồng.

Bộ đếm Nest PMU được xử lý bằng vi mã Nest IMC chạy trong OCC
(Bộ điều khiển trên chip) phức tạp. Vi mã thu thập dữ liệu bộ đếm và di chuyển
dữ liệu bộ đếm IMC vào bộ nhớ.

Bộ đếm Core và Thread IMC PMU được xử lý trong lõi. Cấp độ cốt lõi PMU
bộ đếm cung cấp cho chúng tôi dữ liệu của bộ đếm IMC trên mỗi lõi và cấp độ luồng. Bộ đếm PMU
cung cấp cho chúng tôi dữ liệu của bộ đếm IMC trên mỗi luồng CPU.

OPAL lấy IMC PMU và thông tin sự kiện được hỗ trợ từ Danh mục IMC
và chuyển tới kernel thông qua cây thiết bị. Thông tin sự kiện
chứa:

- Tên sự kiện
- Bù đắp sự kiện
- Mô tả sự kiện

và cũng có thể:

- Quy mô sự kiện
- Đơn vị sự kiện

Một số PMU có thể có thang đo và giá trị đơn vị chung cho tất cả các
sự kiện. Đối với những trường hợp đó, thuộc tính tỷ lệ và đơn vị cho những sự kiện đó phải là
được kế thừa từ PMU.

Phần bù sự kiện trong bộ nhớ là nơi tích lũy dữ liệu bộ đếm.

Danh mục IMC có sẵn tại:
	ZZ0000ZZ

Hạt nhân khám phá thông tin bộ đếm IMC trong cây thiết bị tại
Nút thiết bị ZZ0000ZZ có trường tương thích
ZZ0001ZZ. Từ cây thiết bị, hạt nhân phân tích các PMU
và thông tin sự kiện của họ, đồng thời đăng ký PMU và các thuộc tính của nó trong
hạt nhân.

Ví dụ sử dụng IMC
=================

.. code-block:: sh

  # perf list
  [...]
  nest_mcs01/PM_MCS01_64B_RD_DISP_PORT01/            [Kernel PMU event]
  nest_mcs01/PM_MCS01_64B_RD_DISP_PORT23/            [Kernel PMU event]
  [...]
  core_imc/CPM_0THRD_NON_IDLE_PCYC/                  [Kernel PMU event]
  core_imc/CPM_1THRD_NON_IDLE_INST/                  [Kernel PMU event]
  [...]
  thread_imc/CPM_0THRD_NON_IDLE_PCYC/                [Kernel PMU event]
  thread_imc/CPM_1THRD_NON_IDLE_INST/                [Kernel PMU event]

Để xem dữ liệu trên mỗi chip cho Nest_mcs0/PM_MCS_DOWN_128B_DATA_XFER_MC0/:

.. code-block:: sh

  # ./perf stat -e "nest_mcs01/PM_MCS01_64B_WR_DISP_PORT01/" -a --per-socket

Để xem hướng dẫn không rảnh cho lõi 0:

.. code-block:: sh

  # ./perf stat -e "core_imc/CPM_NON_IDLE_INST/" -C 0 -I 1000

Để xem hướng dẫn không rảnh cho "thực hiện":

.. code-block:: sh

  # ./perf stat -e "thread_imc/CPM_NON_IDLE_PCYC/" make


Chế độ theo dõi IMC
===============

POWER9 hỗ trợ hai chế độ cho IMC là chế độ Tích lũy và Theo dõi
chế độ. Ở chế độ Tích lũy, số lượng sự kiện được tích lũy trong Bộ nhớ hệ thống.
Sau đó, Hypervisor sẽ đọc số lượng đã đăng theo định kỳ hoặc khi được yêu cầu. Trong IMC
Chế độ theo dõi, giá trị SCOM theo dõi 64 bit được khởi tạo cùng với sự kiện
thông tin. CPMCxSEL và CPMC_LOAD trong dấu vết SCOM, chỉ định sự kiện
cần theo dõi và thời gian lấy mẫu. Mỗi lần tràn CPMCxSEL,
phần cứng chụp nhanh bộ đếm chương trình cùng với số lượng sự kiện và ghi vào
bộ nhớ được chỉ định bởi LDBAR.

LDBAR là mục đích đặc biệt 64 bit cho mỗi thanh ghi luồng, nó có các bit để biểu thị
liệu phần cứng có được cấu hình ở chế độ tích lũy hay theo dõi hay không.

Bố cục đăng ký LDBAR
---------------------

+-------+----------------------+
  ZZ0000ZZ Bật/Tắt |
  +-------+----------------------+
  ZZ0001ZZ 0: Chế độ tích lũy |
  |       +----------------------+
  ZZ0002ZZ 1: Chế độ theo dõi |
  +-------+----------------------+
  ZZ0003ZZ Dành riêng |
  +-------+----------------------+
  ZZ0004ZZ PB phạm vi |
  +-------+----------------------+
  ZZ0005ZZ Dành riêng |
  +-------+----------------------+
  Địa chỉ quầy ZZ0006ZZ |
  +-------+----------------------+
  ZZ0007ZZ Dành riêng |
  +-------+----------------------+

Biểu diễn bit TRACE_IMC_SCOM
---------------------------------

+-------+-------------+
  ZZ0000ZZ SAMPSEL |
  +-------+-------------+
  ZZ0001ZZ CPMC_LOAD |
  +-------+-------------+
  ZZ0002ZZ CPMC1SEL |
  +-------+-------------+
  ZZ0003ZZ CPMC2SEL |
  +-------+-------------+
  ZZ0004ZZ BUFFERSIZE |
  +-------+-------------+
  ZZ0005ZZ RESERVED |
  +-------+-------------+

CPMC_LOAD chứa thời lượng lấy mẫu. SAMPSEL và CPMCxSEL xác định
sự kiện cần đếm. BUFFERSIZE cho biết phạm vi bộ nhớ. Trên mỗi lần tràn,
phần cứng chụp nhanh bộ đếm chương trình cùng với số lượng sự kiện và cập nhật
bộ nhớ và tải lại giá trị CMPC_LOAD cho thời gian lấy mẫu tiếp theo. IMC
phần cứng không hỗ trợ ngoại lệ, vì vậy nó lặng lẽ xử lý nếu bộ nhớ
bộ đệm đạt đến cuối.

ZZ0000ZZ

Theo dõi cách sử dụng ví dụ IMC
=======================

.. code-block:: sh

  # perf list
  [....]
  trace_imc/trace_cycles/                            [Kernel PMU event]

Để ghi lại một ứng dụng/quy trình với sự kiện trace-imc:

.. code-block:: sh

  # perf record -e trace_imc/trace_cycles/ yes > /dev/null
  [ perf record: Woken up 1 times to write data ]
  [ perf record: Captured and wrote 0.012 MB perf.data (21 samples) ]

ZZ0000ZZ được tạo, có thể được đọc bằng báo cáo hiệu suất.

Lợi ích của việc sử dụng chế độ theo dõi IMC
================================

Tránh xử lý ngắt PMI (Ngắt giám sát hiệu suất) vì IMC
chế độ theo dõi sẽ chụp nhanh bộ đếm chương trình và cập nhật vào bộ nhớ. Và cái này
cũng cung cấp một cách để hệ điều hành thực hiện lấy mẫu lệnh trong thực tế
thời gian mà không cần xử lý PMI.

Dữ liệu hiệu suất sử dụng ZZ0000ZZ có và không có sự kiện trace-imc.

PMI ngắt số lần đếm khi lệnh ZZ0000ZZ được thực thi mà không có sự kiện trace-imc.

.. code-block:: sh

  # grep PMI /proc/interrupts
  PMI:          0          0          0          0   Performance monitoring interrupts
  # ./perf top
  ...
  # grep PMI /proc/interrupts
  PMI:      39735       8710      17338      17801   Performance monitoring interrupts
  # ./perf top -e trace_imc/trace_cycles/
  ...
  # grep PMI /proc/interrupts
  PMI:      39735       8710      17338      17801   Performance monitoring interrupts


Nghĩa là, số lần ngắt PMI không tăng khi sử dụng sự kiện ZZ0000ZZ.