.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/method-tracing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=======================
Cơ sở theo dõi ACPICA
=======================

:Bản quyền: ZZ0000ZZ 2015, Tập đoàn Intel
:Tác giả: Lv Zheng <lv.zheng@intel.com>


Tóm tắt
========
Tài liệu này mô tả các chức năng và giao diện của
cơ sở truy tìm phương pháp.

Chức năng và ví dụ sử dụng
==================================

ACPICA cung cấp khả năng theo dõi phương pháp. Và hai chức năng là
hiện đang được triển khai bằng cách sử dụng khả năng này.

Giảm nhật ký
-----------

Hệ thống con ACPICA cung cấp đầu ra gỡ lỗi khi CONFIG_ACPI_DEBUG được kích hoạt
đã bật. Các thông báo gỡ lỗi được triển khai thông qua
Macro ACPI_DEBUG_PRINT() có thể được giảm ở 2 cấp độ - cho mỗi thành phần
cấp độ (được gọi là lớp gỡ lỗi, được định cấu hình thông qua
/sys/module/acpi/parameters/debug_layer) và cấp độ mỗi loại (được gọi là
mức gỡ lỗi, được định cấu hình qua /sys/module/acpi/parameters/debug_level).

Nhưng khi lớp/cấp cụ thể được áp dụng cho phương pháp điều khiển
đánh giá, số lượng đầu ra gỡ lỗi có thể vẫn còn quá nhiều
lớn để được đưa vào bộ đệm nhật ký kernel. Ý tưởng như vậy đã được thực hiện
để chỉ kích hoạt lớp/cấp gỡ lỗi cụ thể (thường chi tiết hơn)
ghi nhật ký khi quá trình đánh giá phương pháp điều khiển được bắt đầu và vô hiệu hóa
ghi nhật ký chi tiết khi dừng đánh giá phương pháp điều khiển.

Các ví dụ lệnh sau minh họa cách sử dụng "bộ giảm nhật ký"
chức năng:

Một. Lọc ra các nhật ký phù hợp với lớp/cấp gỡ lỗi khi các phương thức điều khiển
   đang được đánh giá::

# cd/sys/mô-đun/acpi/tham số
      # echo "0xXXXXXXXXX" > trace_debug_layer
      # echo "0xYYYYYYYY" > trace_debug_level
      # echo "bật" > trace_state

b. Lọc ra các nhật ký phù hợp với lớp/cấp gỡ lỗi khi được chỉ định
   phương pháp kiểm soát đang được đánh giá::

# cd/sys/mô-đun/acpi/tham số
      # echo "0xXXXXXXXXX" > trace_debug_layer
      # echo "0xYYYYYYYY" > trace_debug_level
      # echo "\PPPP.AAAA.TTTT.HHHH" > trace_method_name
      "Phương thức" # echo > /sys/module/acpi/parameters/trace_state

c. Lọc ra các nhật ký phù hợp với lớp/cấp gỡ lỗi khi được chỉ định
   phương pháp điều khiển đang được đánh giá lần đầu tiên::

# cd/sys/mô-đun/acpi/tham số
      # echo "0xXXXXXXXXX" > trace_debug_layer
      # echo "0xYYYYYYYY" > trace_debug_level
      # echo "\PPPP.AAAA.TTTT.HHHH" > trace_method_name
      # echo "phương thức một lần" > /sys/module/acpi/parameters/trace_state

Ở đâu:
   0xXXXXXXXXX/0xYYYYYYYY
     Tham khảo Tài liệu/firmware-guide/acpi/debug.rst để biết lớp/cấp độ gỡ lỗi có thể có
     che giấu các giá trị.
   \PPPP.AAAA.TTTT.HHHH
     Đường dẫn đầy đủ của phương thức điều khiển có thể tìm thấy trong không gian tên ACPI.
     Nó không cần phải là một mục đánh giá phương pháp kiểm soát.

Máy theo dõi AML
----------

Có các mục nhật ký đặc biệt được thêm vào bởi cơ sở theo dõi phương pháp tại
"điểm theo dõi" trình thông dịch AML bắt đầu/dừng để thực hiện điều khiển
phương thức hoặc opcode AML. Lưu ý rằng định dạng của các mục nhật ký là
có thể thay đổi::

[ 0.186427] exdebug-0398 ex_trace_point : Thực thi phương thức Bắt đầu [0xf58394d8:\_SB.PCI0.LPCB.ECOK].
   [ 0.186630] exdebug-0398 ex_trace_point : Opcode Bắt đầu thực thi [0xf5905c88:If].
   [ 0.186820] exdebug-0398 ex_trace_point : Opcode Bắt đầu thực thi [0xf5905cc0:LEqual].
   [ 0.187010] exdebug-0398 ex_trace_point : Opcode Bắt đầu thực thi [0xf5905a20:-NamePath-].
   [ 0.187214] exdebug-0398 ex_trace_point : Thực thi Opcode End [0xf5905a20:-NamePath-].
   [ 0.187407] exdebug-0398 ex_trace_point : Opcode Bắt đầu thực thi [0xf5905f60:One].
   [ 0.187594] exdebug-0398 ex_trace_point : Thực thi Opcode End [0xf5905f60:One].
   [ 0.187789] exdebug-0398 ex_trace_point : Thực thi Opcode End [0xf5905cc0:LEqual].
   [ 0.187980] exdebug-0398 ex_trace_point : Opcode Bắt đầu thực thi [0xf5905cc0:Return].
   [ 0.188146] exdebug-0398 ex_trace_point : Opcode Bắt đầu thực thi [0xf5905f60:One].
   [ 0.188334] exdebug-0398 ex_trace_point : Thực thi Opcode End [0xf5905f60:One].
   [ 0.188524] exdebug-0398 ex_trace_point : Thực thi Opcode End [0xf5905cc0:Return].
   [ 0.188712] exdebug-0398 ex_trace_point : Thực thi Opcode End [0xf5905c88:If].
   [ 0.188903] exdebug-0398 ex_trace_point : Thực thi Phương thức Kết thúc [0xf58394d8:\_SB.PCI0.LPCB.ECOK].

Các nhà phát triển có thể sử dụng các mục nhật ký đặc biệt này để theo dõi AML
giải thích, do đó có thể hỗ trợ gỡ lỗi và điều chỉnh hiệu suất. Lưu ý
rằng, vì nhật ký "AML tracer" được triển khai thông qua ACPI_DEBUG_PRINT()
macro, CONFIG_ACPI_DEBUG cũng cần được bật để kích hoạt
Nhật ký "AML tracer".

Các ví dụ lệnh sau minh họa cách sử dụng "AML tracer"
chức năng:

Một. Lọc nhật ký phương thức bắt đầu/dừng "AML tracer" khi điều khiển
   phương pháp đang được đánh giá::

# cd/sys/mô-đun/acpi/tham số
      # echo "0x80" > trace_debug_layer
      # echo "0x10" > trace_debug_level
      # echo "bật" > trace_state

b. Lọc ra phương thức bắt đầu/dừng "AML tracer" khi được chỉ định
   phương pháp kiểm soát đang được đánh giá::

# cd/sys/mô-đun/acpi/tham số
      # echo "0x80" > trace_debug_layer
      # echo "0x10" > trace_debug_level
      # echo "\PPPP.AAAA.TTTT.HHHH" > trace_method_name
      # echo "phương thức" > trace_state

c. Lọc nhật ký phương thức bắt đầu/dừng "AML tracer" khi được chỉ định
   phương pháp điều khiển đang được đánh giá lần đầu tiên::

# cd/sys/mô-đun/acpi/tham số
      # echo "0x80" > trace_debug_layer
      # echo "0x10" > trace_debug_level
      # echo "\PPPP.AAAA.TTTT.HHHH" > trace_method_name
      # echo "phương thức một lần" > trace_state

d. Lọc ra phương thức/opcode bắt đầu/dừng "AML tracer" khi
   phương pháp kiểm soát được chỉ định đang được đánh giá::

# cd/sys/mô-đun/acpi/tham số
      # echo "0x80" > trace_debug_layer
      # echo "0x10" > trace_debug_level
      # echo "\PPPP.AAAA.TTTT.HHHH" > trace_method_name
      # echo "mã lệnh" > trace_state

đ. Lọc ra phương thức/opcode bắt đầu/dừng "AML tracer" khi
   phương pháp kiểm soát được chỉ định đang được đánh giá lần đầu tiên::

# cd/sys/mô-đun/acpi/tham số
      # echo "0x80" > trace_debug_layer
      # echo "0x10" > trace_debug_level
      # echo "\PPPP.AAAA.TTTT.HHHH" > trace_method_name
      # echo "opcode-opcode" > trace_state

Lưu ý rằng tất cả các tham số mô-đun liên quan đến cơ sở theo dõi phương pháp trên có thể
được sử dụng làm tham số khởi động, ví dụ::

acpi.trace_debug_layer=0x80 acpi.trace_debug_level=0x10 \
   acpi.trace_method_name=\_SB.LID0._LID acpi.trace_state=opcode-once


Mô tả giao diện
======================

Tất cả các chức năng theo dõi phương pháp có thể được cấu hình thông qua mô-đun ACPI
các tham số có thể truy cập được tại /sys/module/acpi/parameters/:

trace_method_name
  Đường dẫn đầy đủ của phương pháp AML mà người dùng muốn theo dõi.

Lưu ý rằng đường dẫn đầy đủ không được chứa dấu "_" ở cuối
  phân đoạn tên nhưng có thể chứa "\" để tạo thành đường dẫn tuyệt đối.

trace_debug_layer
  Debug_layer tạm thời được sử dụng khi tính năng theo dõi được bật.

Sử dụng ACPI_EXECUTER (0x80) theo mặc định, đó là debug_layer
  được sử dụng để khớp với tất cả nhật ký "AML tracer".

trace_debug_level
  Debug_level tạm thời được sử dụng khi tính năng theo dõi được bật.

Sử dụng ACPI_LV_TRACE_POINT (0x10) theo mặc định, đây là
  debug_level được sử dụng để khớp với tất cả nhật ký "AML tracer".

dấu vết_trạng thái
  Trạng thái của tính năng theo dõi.

Người dùng có thể bật/tắt tính năng theo dõi gỡ lỗi này bằng cách thực thi
  lệnh sau::

Chuỗi # echo > /sys/module/acpi/parameter/trace_state

Trong đó "chuỗi" phải là một trong những thứ sau:

"vô hiệu hóa"
  Vô hiệu hóa tính năng theo dõi phương pháp.

"kích hoạt"
  Kích hoạt tính năng theo dõi phương pháp.
  
Thông báo gỡ lỗi ACPICA khớp với "trace_debug_layer/trace_debug_level"
  trong quá trình thực hiện bất kỳ phương thức nào sẽ được ghi lại.

"phương pháp"
  Kích hoạt tính năng theo dõi phương pháp.

Thông báo gỡ lỗi ACPICA khớp với "trace_debug_layer/trace_debug_level"
  trong quá trình thực thi phương thức "trace_method_name" sẽ được ghi lại.

"phương pháp một lần"
  Kích hoạt tính năng theo dõi phương pháp.

Thông báo gỡ lỗi ACPICA khớp với "trace_debug_layer/trace_debug_level"
  trong quá trình thực thi phương thức "trace_method_name" sẽ chỉ được ghi lại một lần.

"mã mã"
  Kích hoạt tính năng theo dõi phương pháp.

Thông báo gỡ lỗi ACPICA khớp với "trace_debug_layer/trace_debug_level"
  trong quá trình thực thi phương thức/opcode của "trace_method_name" sẽ được ghi lại.

"opcode-một lần"
  Kích hoạt tính năng theo dõi phương pháp.

Thông báo gỡ lỗi ACPICA khớp với "trace_debug_layer/trace_debug_level"
  trong quá trình thực thi phương thức/opcode của "trace_method_name" sẽ chỉ được ghi lại
  một lần.

Lưu ý rằng, sự khác biệt giữa tính năng "bật" và tính năng khác
các tùy chọn kích hoạt là:

1. Khi chỉ định "bật" vì
   "trace_debug_layer/trace_debug_level" sẽ áp dụng cho tất cả các điều khiển
   đánh giá phương pháp, sau khi định cấu hình "trace_state" thành "enable",
   "trace_method_name" sẽ được đặt lại thành NULL.
2. Khi "phương thức/mã hoạt động" được chỉ định, nếu
   "trace_method_name" là NULL khi "trace_state" được định cấu hình thành
   các tùy chọn này, "trace_debug_layer/trace_debug_level" sẽ
   áp dụng cho tất cả các đánh giá phương pháp kiểm soát.