.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/histogram-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Ghi chú thiết kế biểu đồ
======================

:Tác giả: Tom Zanussi <zanussi@kernel.org>

Tài liệu này cố gắng cung cấp mô tả về cách ftrace
biểu đồ hoạt động và cách các phần riêng lẻ ánh xạ tới dữ liệu
các cấu trúc được sử dụng để triển khai chúng trong trace_events_hist.c và
tracing_map.c.

.. note::
   All the ftrace histogram command examples assume the working
   directory is the ftrace /tracing directory. For example::

	# cd /sys/kernel/tracing

   Also, the histogram output displayed for those commands will be
   generally be truncated - only enough to make the point is displayed.

Tệp sự kiện theo dõi 'hist_debug'
==============================

Nếu kernel được biên dịch với bộ CONFIG_HIST_TRIGGERS_DEBUG, một
tệp sự kiện có tên 'hist_debug' sẽ xuất hiện trong mỗi sự kiện
thư mục con.  Tập tin này có thể được đọc bất cứ lúc nào và sẽ hiển thị một số
của nội bộ trình kích hoạt lịch sử được mô tả trong tài liệu này. Cụ thể
ví dụ và đầu ra sẽ được mô tả trong các trường hợp thử nghiệm bên dưới.

Biểu đồ cơ bản
================

Đầu tiên, biểu đồ cơ bản.  Dưới đây là điều đơn giản nhất mà bạn
có thể thực hiện với biểu đồ - tạo một biểu đồ bằng một phím duy nhất trên một biểu đồ
sự kiện và cat đầu ra::

# echo 'hist:keys=pid' >> sự kiện/lịch trình/lập lịch_waking/kích hoạt

Sự kiện/lịch biểu/lịch_waking/lịch sử # cat

{ pid: 18249 } số lần truy cập: 1
  { pid: 13399 } số lần truy cập: 1
  { pid: 17973 } số lần truy cập: 1
  { pid: 12572 } số lần truy cập: 1
  ...
{ pid: 10 } số lần truy cập: 921
  { pid: 18255 } số lần truy cập: 1444
  { pid: 25526 } số lần truy cập: 2055
  { pid: 5257 } số lần truy cập: 2055
  { pid: 27367 } số lần truy cập: 2055
  { pid: 1728 } số lần truy cập: 2161

Tổng số:
    Lượt truy cập: 21305
    Bài dự thi: 183
    Đã đánh rơi: 0

Điều này làm là tạo biểu đồ về sự kiện sched_waking bằng cách sử dụng
pid làm khóa và có một giá trị duy nhất là số lần truy cập, ngay cả khi không
được chỉ định rõ ràng, tồn tại cho mọi biểu đồ bất kể.

Giá trị hitcount là giá trị mỗi nhóm được tự động
tăng lên trên mỗi lần nhấn phím đã cho, trong trường hợp này là
pid.

Vì vậy, trong biểu đồ này, có một nhóm riêng biệt cho mỗi pid và mỗi nhóm
nhóm chứa một giá trị cho nhóm đó, đếm số lần
sched_waking đã được gọi cho pid đó.

Mỗi biểu đồ được biểu thị bằng cấu trúc hist_data
(cấu trúc hist_trigger_data).

Để theo dõi từng trường khóa và giá trị trong biểu đồ, hist_data
giữ một mảng các trường này có tên là field[].  Mảng trường [] là
một mảng chứa các biểu diễn struct hist_field của mỗi
biểu đồ val và khóa trong biểu đồ (các biến cũng được bao gồm
ở đây nhưng sẽ được thảo luận sau). Vì vậy, đối với biểu đồ trên, chúng ta có một
khóa và một giá trị; trong trường hợp này một giá trị là giá trị hitcount,
mà tất cả các biểu đồ đều có, bất kể chúng có xác định điều đó hay không
giá trị hay không, điều mà biểu đồ trên không có.

Mỗi cấu trúc hist_field chứa một con trỏ tới ftrace_event_field
từ trace_event_file của sự kiện cùng với nhiều bit khác nhau liên quan đến
chẳng hạn như kích thước, độ lệch, loại và hàm trường lịch sử,
được sử dụng để lấy dữ liệu của trường từ bộ đệm sự kiện ftrace
(trong hầu hết các trường hợp - một số trường hist_field như hitcount không ánh xạ trực tiếp
đến trường sự kiện trong bộ đệm theo dõi - trong những trường hợp này, hàm
việc triển khai nhận được giá trị của nó từ một nơi khác).  trường cờ
cho biết đó là loại trường nào - khóa, giá trị, biến, biến
tham chiếu, v.v., với giá trị là mặc định.

Cấu trúc dữ liệu hist_data quan trọng khác ngoài
mảng trường [] là phiên bản tracing_map được tạo cho biểu đồ,
được giữ trong thành viên .map.  tracing_map thực hiện
bảng băm không khóa được sử dụng để triển khai biểu đồ (xem
kernel/trace/tracing_map.h để biết thêm thảo luận về
cấu trúc dữ liệu cấp thấp triển khai tracing_map).  Đối với
mục đích của cuộc thảo luận này, tracing_map chứa một số
các nhóm, mỗi nhóm tương ứng với một tracing_map_elt cụ thể
đối tượng được băm bằng một khóa biểu đồ nhất định.

Dưới đây là sơ đồ, phần đầu tiên mô tả hist_data và
các trường khóa và giá trị liên quan cho biểu đồ được mô tả ở trên.  Như
bạn có thể thấy, có hai trường trong mảng trường, một trường val
cho số lần truy cập và một trường khóa cho khóa pid.

Bên dưới là sơ đồ ảnh chụp nhanh trong thời gian chạy về nội dung của tracing_map
có thể trông giống như một lần chạy nhất định.  Nó cố gắng hiển thị
mối quan hệ giữa các trường hist_data và tracing_map
các phần tử cho một vài khóa và giá trị giả định.::

+-------------------+
  ZZ0000ZZ
  +-------------------+ +----------------+
    ZZ0001ZZ---->ZZ0002ZZ--------------------------+
    +++ ----------------+ |
    ZZ0003ZZ ZZ0004ZZ |
    ++-------+ +--------------+ |
                             ZZ0005ZZ |
                             +--------------+ |
                             ZZ0006ZZ |
                             +--------------+ |
                                   .                                     |
                                   .                                     |
                                   .                                     |
                           ++-------+ <--- n_vals |
                           ZZ0007ZZ--------------------------------------|--+
                           +++ ZZ0008ZZ
                             ZZ0009ZZ ZZ0010ZZ
                             +--------------+ ZZ0011ZZ
                             ZZ0012ZZ ZZ0013ZZ
                             +--------------+ ZZ0014ZZ
                             ZZ0015ZZ ZZ0016ZZ
                           ++++ <--- n_fields ZZ0017ZZ
                           ZZ0018ZZ ZZ0019ZZ
                           +++ ZZ0020ZZ
                             ZZ0021ZZ ZZ0022ZZ
                             +--------------+ ZZ0023ZZ
                             ZZ0024ZZ ZZ0025ZZ
                             +--------------+ ZZ0026ZZ
                             ZZ0027ZZ ZZ0028ZZ
                             +--------------+ ZZ0029ZZ
                                            n_keys = n_fields - n_vals ZZ0030ZZ

Hist_data n_vals và n_fields mô tả phạm vi của các trường[]
mảng và tách các khóa khỏi các giá trị cho phần còn lại của mã.

Dưới đây là phần trình bày thời gian chạy của phần tracing_map của
biểu đồ, với các con trỏ từ các phần khác nhau của mảng trường []
tới các phần tương ứng của tracing_map.

tracing_map bao gồm một mảng tracing_map_entrys và một tập hợp
của tracing_map_elts được phân bổ trước (dưới đây viết tắt là map_entry và
bản đồ_elt).  Tổng số map_entrys trong mảng hist_data.map =
map->max_elts (thực ra là map->map_size nhưng chỉ có max_elts trong số đó là
đã sử dụng.  Đây là thuộc tính được yêu cầu bởi thuật toán map_insert()).

Nếu map_entry không được sử dụng, nghĩa là chưa có khóa nào được băm vào đó, thì
Giá trị .key là 0 và con trỏ .val của nó là NULL.  Khi một map_entry có
được xác nhận, giá trị .key chứa giá trị băm của khóa và
Thành viên .val trỏ tới một map_elt chứa khóa đầy đủ và một mục nhập
cho mỗi khóa hoặc giá trị trong mảng map_elt.fields[].  có một
mục trong mảng map_elt.fields[] tương ứng với mỗi hist_field
trong biểu đồ và đây là nơi tổng hợp liên tục
tương ứng với mỗi giá trị biểu đồ được giữ lại.

Sơ đồ cố gắng thể hiện mối quan hệ giữa
hist_data.fields[] và map_elt.fields[] với các liên kết được rút ra
giữa các sơ đồ::

+----------+ ZZ0000ZZ
  ZZ0001ZZ ZZ0002ZZ
  +----------+ ZZ0003ZZ
    ZZ0004ZZ ZZ0005ZZ
    +----------+ +-------------+ ZZ0006ZZ
    ZZ0007ZZ---->ZZ0008ZZ ZZ0009ZZ
    +----------+ +-------------+ ZZ0010ZZ
                      ZZ0011ZZ---> 0 ZZ0012ZZ
                      +----------+ ZZ0013ZZ
                      ZZ0014ZZ---> NULL ZZ0015ZZ
                    +----------+ ZZ0016ZZ
                    ZZ0017ZZ ZZ0018ZZ
                    +----------+ ZZ0019ZZ
                      ZZ0020ZZ---> pid = 999 ZZ0021ZZ
                      +----------+ +-------------+ ZZ0022ZZ
                      ZZ0023ZZ--->ZZ0024ZZ ZZ0025ZZ
                      +----------+ +-------------+ ZZ0026ZZ
                           .           ZZ0027ZZ---> phím đầy đủ * ZZ0028ZZ
                           .           +----------+ +--------------+ ZZ0029ZZ
			   .           ZZ0030ZZ--->ZZ0031ZZ<-+ |
                    +----------+ +----------+ ZZ0032ZZ ZZ0033ZZ
                    ZZ0034ZZ +--------------+ ZZ0035ZZ
                    +----------+ ZZ0036ZZ<----+
                      ZZ0037ZZ---> 0 ZZ0038ZZ ZZ0039ZZ
                      +----------+ +--------------+ ZZ0040ZZ
                      ZZ0041ZZ---> NULL .          ZZ0042ZZ
                    +----------+ .          ZZ0043ZZ
                    ZZ0044ZZ.          ZZ0045ZZ
                    +----------+ +--------------+ ZZ0046ZZ
                      ZZ0047ZZ ZZ0048ZZ ZZ0049ZZ
                      +----------+ +----------+ ZZ0050ZZ ZZ0051ZZ
                      ZZ0052ZZ--->ZZ0053ZZ +--------------+ ZZ0054ZZ
                    +----------+ +----------+ ZZ0055ZZ ZZ0056ZZ
                    ZZ0057ZZ ZZ0058ZZ ZZ0059ZZ
                    +----------+ +--------------+ ZZ0060ZZ
                      ZZ0061ZZ---> pid = 4444 ZZ0062ZZ
                      +----------+ +-------------+ ZZ0063ZZ
                      ZZ0064ZZ ZZ0065ZZ ZZ0066ZZ
                      +----------+ +-------------+ ZZ0067ZZ
                                       ZZ0068ZZ---> phím đầy đủ * ZZ0069ZZ
                                       +----------+ +--------------+ ZZ0070ZZ
			               ZZ0071ZZ--->ZZ0072ZZ<-+ |
                                       +----------+ ZZ0073ZZ |
                                                      +--------------+ |
                                                      ZZ0074ZZ<----+
                                                      ZZ0075ZZ
                                                      +--------------+
                                                              .
                                                              .
                                                              .
                                                      +--------------+
                                                      ZZ0076ZZ
                                                      ZZ0077ZZ
                                                      +--------------+
                                                      ZZ0078ZZ
                                                      ZZ0079ZZ
                                                      +--------------+

Các chữ viết tắt sử dụng trong sơ đồ::

hist_data = struct hist_trigger_data
  hist_data.fields = struct hist_field
  fn = hist_field_fn_t
  map_entry = struct tracing_map_entry
  map_elt = struct tracing_map_elt
  map_elt.fields = struct tracing_map_field

Bất cứ khi nào một sự kiện mới xảy ra và nó có trình kích hoạt lịch sử liên quan đến
nó, event_hist_trigger() được gọi.  sự kiện_hist_trigger() giao dịch đầu tiên
bằng khóa: với mỗi khóa con trong khóa (trong ví dụ trên, có
chỉ là một khóa con tương ứng với pid), hist_field mà
đại diện cho khóa con đó được lấy từ hist_data.fields[] và
hàm trường lịch sử được liên kết với trường đó, cùng với
kích thước và độ lệch của trường, được sử dụng để lấy dữ liệu của khóa con đó từ
hồ sơ theo dõi hiện tại.

Lưu ý, hàm trường lịch sử sử dụng làm con trỏ hàm trong
cấu trúc hist_field. Do giảm thiểu bóng ma, nó đã được chuyển đổi thành
fn_num và hist_fn_call() được sử dụng để gọi trường lịch sử liên quan
hàm tương ứng với fn_num của cấu trúc hist_field.

Khi khóa hoàn chỉnh đã được lấy ra, nó được sử dụng để tìm khóa đó
trong tracing_map.  Nếu không có tracing_map_elt liên kết với
khóa đó, một khóa trống sẽ được yêu cầu và chèn vào bản đồ cho khóa mới
chìa khóa.  Trong cả hai trường hợp, tracing_map_elt được liên kết với khóa đó là
đã quay trở lại.

Khi có sẵn tracing_map_elt, hist_trigger_elt_update() sẽ được gọi.
Như tên ngụ ý, điều này cập nhật phần tử, về cơ bản có nghĩa là
cập nhật các trường của phần tử.  Có một tracing_map_field được liên kết
với mỗi khóa và giá trị trong biểu đồ và mỗi khóa và giá trị này tương ứng
tới khóa và giá trị hist_fields được tạo khi biểu đồ được
được tạo ra.  hist_trigger_elt_update() đi qua từng giá trị hist_field
và, đối với các khóa, sử dụng chức năng, kích thước và phần bù của hist_field
để lấy giá trị của trường từ bản ghi theo dõi hiện tại.  Một khi nó có
giá trị đó, nó chỉ đơn giản thêm giá trị đó vào trường đó
thành viên tracing_map_field.sum được cập nhật liên tục.  Một số hist_field
các chức năng, chẳng hạn như đối với số lần truy cập, không thực sự lấy bất cứ thứ gì từ
bản ghi theo dõi (hàm hitcount chỉ tăng tổng bộ đếm lên 1),
nhưng ý tưởng là như nhau.

Khi tất cả các giá trị đã được cập nhật, hist_trigger_elt_update() là
xong và trả về.  Lưu ý rằng cũng có tracing_map_fields cho
mỗi khóa con trong khóa, nhưng hist_trigger_elt_update() không nhìn vào
chúng hoặc cập nhật bất cứ thứ gì - những thứ đó chỉ tồn tại để sắp xếp, có thể
xảy ra sau này.

Kiểm tra biểu đồ cơ bản
--------------------

Đây là một ví dụ tốt để thử.  Nó tạo ra 3 trường giá trị và 2 khóa
các trường ở đầu ra::

# echo 'hist:keys=common_pid,call_site.sym:values=bytes_req,bytes_alloc,hitcount' >> sự kiện/kmem/kmalloc/trigger

Để xem dữ liệu gỡ lỗi, hãy truy cập tệp 'hist_debug' của kmem/kmalloc. Nó
sẽ hiển thị thông tin kích hoạt của biểu đồ mà nó tương ứng, cùng với
với địa chỉ của hist_data được liên kết với biểu đồ,
sẽ trở nên hữu ích trong các ví dụ sau.  Sau đó nó hiển thị số lượng
tổng số trường hist_field được liên kết với biểu đồ cùng với số lượng
có bao nhiêu trong số đó tương ứng với các khóa và bao nhiêu trong số đó tương ứng với các giá trị.

Sau đó nó tiếp tục hiển thị chi tiết cho từng trường, bao gồm cả
cờ của trường và vị trí của từng trường trong hist_data's
mảng trường [], đây là thông tin hữu ích để xác minh rằng mọi thứ
bên trong có vẻ đúng hay không, và điều đó một lần nữa sẽ trở nên đồng đều
hữu ích hơn trong các ví dụ khác::

Sự kiện # cat/kmem/kmalloc/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=common_pid,call_site.sym:vals=hitcount,bytes_req,bytes_alloc:sort=hitcount:size=2048 [hoạt động]
  #

dữ liệu lịch sử: 000000005e48c9a5

n_vals: 3
  n_keys: 2
  n_field: 5

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        VAL: giá trị u64 bình thường
      Tên ftrace_event_field: byte_req
      gõ: size_t
      kích thước: 8
      được_ký: 0

hist_data->fields[2]:
      cờ:
        VAL: giá trị u64 bình thường
      Tên ftrace_event_field: byte_alloc
      gõ: size_t
      kích thước: 8
      được_ký: 0

các trường chính:

hist_data->fields[3]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: common_pid
      kiểu: int
      kích thước: 8
      được_ký: 1

hist_data->fields[4]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: call_site
      loại: dài không dấu
      kích thước: 8
      được_ký: 0

Các lệnh bên dưới có thể được sử dụng để dọn dẹp mọi thứ cho lần kiểm tra tiếp theo::

# echo '!hist:keys=common_pid,call_site.sym:values=bytes_req,bytes_alloc,hitcount' >> sự kiện/kmem/kmalloc/trigger

Biến
=========

Các biến cho phép dữ liệu từ một trình kích hoạt lịch sử được lưu bởi một lịch sử
trigger và được truy xuất bởi một trigger lịch sử khác.  Ví dụ, một trình kích hoạt
trong sự kiện sched_waking có thể ghi lại dấu thời gian cho một sự kiện cụ thể
pid và sau đó là sự kiện sched_switch chuyển sang sự kiện pid đó
có thể lấy dấu thời gian và sử dụng nó để tính toán khoảng thời gian giữa
hai sự kiện::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs' >>
          sự kiện/đã lên lịch/lập lịch_waking/kích hoạt

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0' >>
          sự kiện/đã lên lịch/sched_switch/kích hoạt

Về mặt cấu trúc dữ liệu biểu đồ, các biến được triển khai
dưới dạng một loại hist_field khác và cho một trình kích hoạt lịch sử nhất định được thêm vào
vào mảng hist_data.fields[] ngay sau tất cả các trường val.  Đến
để phân biệt chúng với các trường khóa và val hiện có, chúng sẽ được cấp một
loại cờ mới, HIST_FIELD_FL_VAR (viết tắt FL_VAR) và chúng cũng
tận dụng thành viên trường .var.idx mới trong struct hist_field,
ánh xạ chúng tới một chỉ mục trong mảng map_elt.vars[] mới được thêm vào
map_elt được thiết kế đặc biệt để lưu trữ và truy xuất các giá trị biến.
Sơ đồ bên dưới hiển thị các phần tử mới đó và thêm một biến mới
mục nhập ts0 tương ứng với biến ts0 trong sched_waking
kích hoạt ở trên.

biểu đồ lịch_thức
----------------------

.. code-block::

  +------------------+
  | hist_data        |<-------------------------------------------------------+
  +------------------+   +-------------------+                                |
    | .fields[]      |-->| val = hitcount    |                                |
    +----------------+   +-------------------+                                |
    | .map           |     | .size           |                                |
    +----------------+     +-----------------+                                |
                           | .offset         |                                |
                           +-----------------+                                |
                           | .fn()           |                                |
                           +-----------------+                                |
                           | .flags          |                                |
                           +-----------------+                                |
                           | .var.idx        |                                |
                         +-------------------+                                |
                         | var = ts0         |                                |
                         +-------------------+                                |
                           | .size           |                                |
                           +-----------------+                                |
                           | .offset         |                                |
                           +-----------------+                                |
                           | .fn()           |                                |
                           +-----------------+                                |
                           | .flags & FL_VAR |                                |
                           +-----------------+                                |
                           | .var.idx        |----------------------------+-+ |
                           +-----------------+                            | | |
			            .                                     | | |
				    .                                     | | |
                                    .                                     | | |
                         +-------------------+ <--- n_vals                | | |
                         | key = pid         |                            | | |
                         +-------------------+                            | | |
                           | .size           |                            | | |
                           +-----------------+                            | | |
                           | .offset         |                            | | |
                           +-----------------+                            | | |
                           | .fn()           |                            | | |
                           +-----------------+                            | | |
                           | .flags & FL_KEY |                            | | |
                           +-----------------+                            | | |
                           | .var.idx        |                            | | |
                         +-------------------+ <--- n_fields              | | |
                         | unused            |                            | | |
                         +-------------------+                            | | |
                           |                 |                            | | |
                           +-----------------+                            | | |
                           |                 |                            | | |
                           +-----------------+                            | | |
                           |                 |                            | | |
                           +-----------------+                            | | |
                           |                 |                            | | |
                           +-----------------+                            | | |
                           |                 |                            | | |
                           +-----------------+                            | | |
                                             n_keys = n_fields - n_vals   | | |
                                                                          | | |

Điều này rất giống với trường hợp cơ bản.  Trong sơ đồ trên, chúng ta có thể
thấy một thành viên .flags mới đã được thêm vào struct hist_field
struct và một mục mới được thêm vào hist_data.fields đại diện cho ts0
biến.  Đối với một val hist_field bình thường, .flags chỉ là 0 (modulo
cờ sửa đổi), nhưng nếu giá trị được xác định là một biến, thì .flags
chứa một tập hợp bit FL_VAR.

Như bạn có thể thấy, thành viên .var.idx của mục nhập ts0 chứa chỉ mục
vào mảng tracing_map_elts' .vars[] chứa các giá trị biến.
Idx này được sử dụng bất cứ khi nào giá trị của biến được đặt hoặc đọc.
Idx map_elt.vars được gán cho biến đã cho sẽ được gán và
được lưu trong .var.idx bởi create_tracing_map_fields() sau khi nó gọi
tracing_map_add_var().

Dưới đây là biểu diễn biểu đồ trong thời gian chạy,
điền vào bản đồ, cùng với sự tương ứng với hist_data ở trên và
cấu trúc dữ liệu hist_field.

Sơ đồ cố gắng thể hiện mối quan hệ giữa
hist_data.fields[] và map_elt.fields[] và map_elt.vars[] với
các liên kết được vẽ giữa các sơ đồ.  Đối với mỗi map_elts, bạn có thể
thấy rằng các thành viên .fields[] trỏ đến .sum hoặc .offset của một khóa
hoặc val và các thành viên .vars[] trỏ đến giá trị của một biến.  các
mũi tên giữa hai sơ đồ cho thấy mối liên kết giữa chúng
các thành viên tracing_map và các định nghĩa trường trong phần tương ứng
trường hist_data[] thành viên.::

  +-----------+		                                                  | | |
  | hist_data |		                                                  | | |
  +-----------+		                                                  | | |
    | .fields |		                                                  | | |
    +---------+     +-----------+		                          | | |
    | .map    |---->| map_entry |		                          | | |
    +---------+     +-----------+		                          | | |
                      | .key    |---> 0		                          | | |
                      +---------+		                          | | |
                      | .val    |---> NULL		                  | | |
                    +-----------+                                         | | |
                    | map_entry |                                         | | |
                    +-----------+                                         | | |
                      | .key    |---> pid = 999                           | | |
                      +---------+    +-----------+                        | | |
                      | .val    |--->| map_elt   |                        | | |
                      +---------+    +-----------+                        | | |
                           .           | .key    |---> full key *         | | |
                           .           +---------+    +---------------+   | | |
			   .           | .fields |--->| .sum (val)    |   | | |
                           .           +---------+    | 2345          |   | | |
                           .        +--| .vars   |    +---------------+   | | |
                           .        |  +---------+    | .offset (key) |   | | |
                           .        |                 | 0             |   | | |
                           .        |                 +---------------+   | | |
                           .        |                         .           | | |
                           .        |                         .           | | |
                           .        |                         .           | | |
                           .        |                 +---------------+   | | |
                           .        |                 | .sum (val) or |   | | |
                           .        |                 | .offset (key) |   | | |
                           .        |                 +---------------+   | | |
                           .        |                 | .sum (val) or |   | | |
                           .        |                 | .offset (key) |   | | |
                           .        |                 +---------------+   | | |
                           .        |                                     | | |
                           .        +---------------->+---------------+   | | |
			   .                          | ts0           |<--+ | |
                           .                          | 113345679876  |   | | |
                           .                          +---------------+   | | |
                           .                          | unused        |   | | |
                           .                          |               |   | | |
                           .                          +---------------+   | | |
                           .                                  .           | | |
                           .                                  .           | | |
                           .                                  .           | | |
                           .                          +---------------+   | | |
                           .                          | unused        |   | | |
                           .                          |               |   | | |
                           .                          +---------------+   | | |
                           .                          | unused        |   | | |
                           .                          |               |   | | |
                           .                          +---------------+   | | |
                           .                                              | | |
                    +-----------+                                         | | |
                    | map_entry |                                         | | |
                    +-----------+                                         | | |
                      | .key    |---> pid = 4444                          | | |
                      +---------+    +-----------+                        | | |
                      | .val    |--->| map_elt   |                        | | |
                      +---------+    +-----------+                        | | |
                           .           | .key    |---> full key *         | | |
                           .           +---------+    +---------------+   | | |
			   .           | .fields |--->| .sum (val)    |   | | |
                                       +---------+    | 2345          |   | | |
                                    +--| .vars   |    +---------------+   | | |
                                    |  +---------+    | .offset (key) |   | | |
                                    |                 | 0             |   | | |
                                    |                 +---------------+   | | |
                                    |                         .           | | |
                                    |                         .           | | |
                                    |                         .           | | |
                                    |                 +---------------+   | | |
                                    |                 | .sum (val) or |   | | |
                                    |                 | .offset (key) |   | | |
                                    |                 +---------------+   | | |
                                    |                 | .sum (val) or |   | | |
                                    |                 | .offset (key) |   | | |
                                    |                 +---------------+   | | |
                                    |                                     | | |
                                    |                 +---------------+   | | |
			            +---------------->| ts0           |<--+ | |
                                                      | 213499240729  |     | |
                                                      +---------------+     | |
                                                      | unused        |     | |
                                                      |               |     | |
                                                      +---------------+     | |
                                                              .             | |
                                                              .             | |
                                                              .             | |
                                                      +---------------+     | |
                                                      | unused        |     | |
                                                      |               |     | |
                                                      +---------------+     | |
                                                      | unused        |     | |
                                                      |               |     | |
                                                      +---------------+     | |

Đối với mỗi mục bản đồ được sử dụng, có một map_elt trỏ đến một mảng
.vars chứa giá trị hiện tại của các biến được liên kết với
mục nhập biểu đồ đó.  Vì vậy, ở trên, dấu thời gian liên quan đến
pid 999 là 113345679876 và biến dấu thời gian trong cùng
.var.idx cho pid 4444 là 213499240729.

biểu đồ sched_switch
----------------------

Biểu đồ sched_switch được ghép nối với sched_waking ở trên
biểu đồ được hiển thị dưới đây.  Khía cạnh quan trọng nhất của
biểu đồ sched_switch là nó tham chiếu một biến trên
biểu đồ sched_waking ở trên.

Biểu đồ biểu đồ rất giống với các biểu đồ khác được hiển thị cho đến nay,
nhưng nó thêm các tham chiếu biến.  Bạn có thể thấy số lần truy cập bình thường và
các trường khóa cùng với biến Wakeup_lat mới được triển khai trong
tương tự như biến sched_waking ts0, nhưng ngoài ra còn có một
mục nhập bằng cờ FL_VAR_REF (viết tắt của HIST_FIELD_FL_VAR_REF) mới.

Liên kết với trường var ref mới là một vài trường hist_field mới
thành viên, var.hist_data và var_ref_idx.  Đối với một tham chiếu biến,
var.hist_data đi cùng với var.idx, cùng nhau xác định duy nhất
một biến cụ thể trên một biểu đồ cụ thể.  var_ref_idx là
chỉ là chỉ mục trong mảng var_ref_vals[] lưu trữ các giá trị của
mỗi biến bất cứ khi nào trình kích hoạt lịch sử được cập nhật.  Những kết quả đó
các giá trị cuối cùng được truy cập bằng mã khác, chẳng hạn như hành động theo dõi
mã sử dụng các giá trị var_ref_idx để gán giá trị param.

Sơ đồ bên dưới mô tả tình huống của sched_switch
biểu đồ được đề cập trước đó::

  # echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0' >>
          events/sched/sched_switch/trigger
                                                                            | |
  +------------------+                                                      | |
  | hist_data        |                                                      | |
  +------------------+   +-----------------------+                          | |
    | .fields[]      |-->| val = hitcount        |                          | |
    +----------------+   +-----------------------+                          | |
    | .map           |     | .size               |                          | |
    +----------------+     +---------------------+                          | |
 +--| .var_refs[]    |     | .offset             |                          | |
 |  +----------------+     +---------------------+                          | |
 |                         | .fn()               |                          | |
 |   var_ref_vals[]        +---------------------+                          | |
 |  +-------------+        | .flags              |                          | |
 |  | $ts0        |<---+   +---------------------+                          | |
 |  +-------------+    |   | .var.idx            |                          | |
 |  |             |    |   +---------------------+                          | |
 |  +-------------+    |   | .var.hist_data      |                          | |
 |  |             |    |   +---------------------+                          | |
 |  +-------------+    |   | .var_ref_idx        |                          | |
 |  |             |    | +-----------------------+                          | |
 |  +-------------+    | | var = wakeup_lat      |                          | |
 |         .           | +-----------------------+                          | |
 |         .           |   | .size               |                          | |
 |         .           |   +---------------------+                          | |
 |  +-------------+    |   | .offset             |                          | |
 |  |             |    |   +---------------------+                          | |
 |  +-------------+    |   | .fn()               |                          | |
 |  |             |    |   +---------------------+                          | |
 |  +-------------+    |   | .flags & FL_VAR     |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .var.idx            |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .var.hist_data      |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .var_ref_idx        |                          | |
 |                     |   +---------------------+                          | |
 |                     |             .                                      | |
 |                     |             .                                      | |
 |                     |             .                                      | |
 |                     | +-----------------------+ <--- n_vals              | |
 |                     | | key = pid             |                          | |
 |                     | +-----------------------+                          | |
 |                     |   | .size               |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .offset             |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .fn()               |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .flags              |                          | |
 |                     |   +---------------------+                          | |
 |                     |   | .var.idx            |                          | |
 |                     | +-----------------------+ <--- n_fields            | |
 |                     | | unused                |                          | |
 |                     | +-----------------------+                          | |
 |                     |   |                     |                          | |
 |                     |   +---------------------+                          | |
 |                     |   |                     |                          | |
 |                     |   +---------------------+                          | |
 |                     |   |                     |                          | |
 |                     |   +---------------------+                          | |
 |                     |   |                     |                          | |
 |                     |   +---------------------+                          | |
 |                     |   |                     |                          | |
 |                     |   +---------------------+                          | |
 |                     |                         n_keys = n_fields - n_vals | |
 |                     |                                                    | |
 |                     |						    | |
 |                     | +-----------------------+                          | |
 +---------------------->| var_ref = $ts0        |                          | |
                       | +-----------------------+                          | |
                       |   | .size               |                          | |
                       |   +---------------------+                          | |
                       |   | .offset             |                          | |
                       |   +---------------------+                          | |
                       |   | .fn()               |                          | |
                       |   +---------------------+                          | |
                       |   | .flags & FL_VAR_REF |                          | |
                       |   +---------------------+                          | |
                       |   | .var.idx            |--------------------------+ |
                       |   +---------------------+                            |
                       |   | .var.hist_data      |----------------------------+
                       |   +---------------------+
                       +---| .var_ref_idx        |
                           +---------------------+

Các chữ viết tắt sử dụng trong sơ đồ::

hist_data = struct hist_trigger_data
  hist_data.fields = struct hist_field
  fn = hist_field_fn_t
  FL_KEY = HIST_FIELD_FL_KEY
  FL_VAR = HIST_FIELD_FL_VAR
  FL_VAR_REF = HIST_FIELD_FL_VAR_REF

Khi trình kích hoạt lịch sử sử dụng một biến, một trường hist_field mới sẽ được
được tạo bằng cờ HIST_FIELD_FL_VAR_REF.  Đối với trường VAR_REF,
var.idx và var.hist_data có cùng giá trị với tham chiếu
biến, cũng như kích thước, loại của biến được tham chiếu và
giá trị is_signed.  Tên .name của trường VAR_REF được đặt thành tên của
biến mà nó tham chiếu.  Nếu một tham chiếu biến được tạo bằng cách sử dụng
ký hiệu system.event.$var_ref rõ ràng, hệ thống của hist_field và
Các biến event_name cũng được đặt.

Vì vậy, để xử lý một sự kiện cho biểu đồ sched_switch,
bởi vì chúng ta có một tham chiếu đến một biến trên biểu đồ khác, chúng ta
cần giải quyết tất cả các tham chiếu biến trước tiên.  Việc này được thực hiện thông qua
các cuộc gọi giải quyết_var_refs() được thực hiện từ sự kiện_hist_trigger().  Cái gì thế này
thực hiện việc lấy mảng var_refs[] từ hist_data đại diện cho
biểu đồ sched_switch.  Đối với mỗi một trong số đó, tài liệu tham khảo
var.hist_data của biến cùng với khóa hiện tại được sử dụng để tra cứu
tracing_map_elt tương ứng trong biểu đồ đó.  Một khi được tìm thấy,
var.idx của biến tham chiếu được sử dụng để tra cứu giá trị của biến
sử dụng tracing_map_read_var(elt, var.idx), mang lại giá trị của
biến cho phần tử đó, ts0 trong trường hợp trên.  Lưu ý rằng cả hai
hist_fields đại diện cho cả biến và biến
tham chiếu có cùng var.idx, vì vậy việc này rất đơn giản.

Kiểm tra tham chiếu biến và biến
------------------------------------

Ví dụ này tạo một biến trong sự kiện sched_waking, ts0 và
sử dụng nó trong trình kích hoạt sched_switch.  Trình kích hoạt sched_switch cũng
tạo biến riêng của nó, Wakeup_lat, nhưng chưa có gì sử dụng nó ::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0' >> sự kiện/lịch trình/sched_switch/trigger

Nhìn vào đầu ra sched_waking 'hist_debug', ngoài
khóa và giá trị thông thường hist_fields, trong phần trường val chúng ta thấy một
trường có cờ HIST_FIELD_FL_VAR, cho biết trường đó
đại diện cho một biến.  Lưu ý rằng ngoài tên biến,
chứa trong trường var.name, nó bao gồm var.idx, là
lập chỉ mục vào mảng tracing_map_elt.vars[] của biến thực tế
vị trí.  Cũng lưu ý rằng kết quả đầu ra cho thấy các biến tồn tại trong
cùng một phần của mảng hist_data->fields[] như các giá trị bình thường::

Sự kiện # cat/đã lên lịch/sched_waking/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid:vals=hitcount:ts0=common_timestamp.usecs:sort=hitcount:size=2048:clock=global [hoạt động]
  #

dữ liệu lịch sử: 000000009536f554

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

Ngoài ra, hãy chuyển sang đầu ra hist_debug của trình kích hoạt sched_switch
đối với biến Wakeup_lat không được sử dụng, chúng tôi thấy một phần mới hiển thị
tham chiếu biến.  Các tham chiếu biến được hiển thị trong một phần riêng biệt
phần vì ngoài việc tách biệt về mặt logic với
các biến và giá trị, chúng thực sự tồn tại trong một hist_data riêng biệt
mảng, var_refs[].

Trong ví dụ này, trình kích hoạt sched_switch có tham chiếu đến một
biến trên trình kích hoạt sched_waking, $ts0.  Nhìn vào chi tiết,
chúng ta có thể thấy rằng giá trị var.hist_data của biến được tham chiếu
khớp với trình kích hoạt sched_waking được hiển thị trước đó và var.idx
giá trị khớp với giá trị var.idx được hiển thị trước đó cho giá trị đó
biến.  Cũng hiển thị là giá trị var_ref_idx cho biến đó
tham chiếu, đây là nơi giá trị của biến đó được lưu trữ trong bộ nhớ đệm
sử dụng khi trình kích hoạt được gọi::

Sự kiện # cat/đã lên lịch/sched_switch/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=next_pid:vals=hitcount:wakeup_lat=common_timestamp.usecs-$ts0:sort=hitcount:size=2048:clock=global [hoạt động]
  #

dữ liệu lịch sử: 00000000f4ee8006

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 0
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

trường tham chiếu biến:

hist_data->var_refs[0]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 000000009536f554
      var_ref_idx (vào hist_data->var_refs[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

Các lệnh bên dưới có thể được sử dụng để dọn dẹp mọi thứ cho lần kiểm tra tiếp theo::

# echo '!hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0' >> sự kiện/lịch trình/sched_switch/trigger

# echo '!hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

Hành động và xử lý
====================

Thêm vào ví dụ trước, bây giờ chúng ta sẽ làm gì đó với điều đó
biến Wakeup_lat, cụ thể là gửi nó và một trường khác dưới dạng tổng hợp
sự kiện.

Hành động onmatch() bên dưới về cơ bản nói lên rằng bất cứ khi nào chúng ta có một
sự kiện sched_switch, nếu chúng ta có sự kiện sched_waking phù hợp, thì trong sự kiện này
trường hợp nếu chúng ta có một pid trong biểu đồ sched_waking khớp với
trường next_pid trên sự kiện sched_switch này, chúng tôi truy xuất
các biến được chỉ định trong hành động theo dõi Wakeup_latency() và sử dụng
chúng để tạo sự kiện Wakeup_latency mới vào luồng theo dõi.

Lưu ý rằng cách các trình xử lý theo dõi như Wakeup_latency() (mà
tương đương có thể được viết trace(wakeup_latency,$wakeup_lat,next_pid)
được triển khai, các tham số được chỉ định cho trình xử lý theo dõi phải được
các biến.  Trong trường hợp này, $wakeup_lat rõ ràng là một biến, nhưng
next_pid thì không, vì nó chỉ đặt tên một trường trong sched_switch
sự kiện dấu vết.  Vì đây là thứ mà hầu hết mọi trace() và
save() thực hiện, một phím tắt đặc biệt được triển khai để cho phép trường
tên được sử dụng trực tiếp trong những trường hợp đó.  Cách thức hoạt động của nó là dưới
bìa, một biến tạm thời được tạo cho trường được đặt tên và
biến này thực sự được chuyển tới trình xử lý theo dõi.  trong
mã và tài liệu, loại biến này được gọi là 'trường
biến'.

Các trường trên biểu đồ của sự kiện theo dõi khác cũng có thể được sử dụng.  Trong đó
trường hợp chúng ta phải tạo một biểu đồ mới và một cái tên không may được đặt tên
'synthetic_field' (việc sử dụng tổng hợp ở đây không liên quan gì đến
sự kiện tổng hợp) và sử dụng trường biểu đồ đặc biệt đó làm biến.

Sơ đồ dưới đây minh họa các yếu tố mới được mô tả ở trên trong
ngữ cảnh của biểu đồ sched_switch bằng cách sử dụng trình xử lý onmatch() và
hành động trace().

Đầu tiên, chúng tôi xác định sự kiện tổng hợp Wakeup_latency::

# echo 'wakeup_latency u64 lat; pid_t pid' >> tổng hợp_events

Tiếp theo, lịch sử sched_waking sẽ được kích hoạt như trước::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs' >>
          sự kiện/đã lên lịch/lập lịch_waking/kích hoạt

Cuối cùng, chúng ta tạo một trình kích hoạt lịch sử cho sự kiện sched_switch để
tạo ra sự kiện theo dõi Wakeup_latency().  Trong trường hợp này chúng tôi vượt qua
next_pid vào lệnh gọi sự kiện tổng hợp Wakeup_latency,
có nghĩa là nó sẽ được tự động chuyển đổi thành biến trường ::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0: \
          onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid)' >>
	  /sys/kernel/tracing/events/sched/sched_switch/trigger

Sơ đồ cho sự kiện sched_switch tương tự như các ví dụ trước
nhưng hiển thị mảng field_vars[] bổ sung cho hist_data và hiển thị
các mối liên kết giữa field_vars với các biến và tham chiếu
được tạo để thực hiện các biến trường.  Các chi tiết được thảo luận
dưới đây::

    +------------------+
    | hist_data        |
    +------------------+   +-----------------------+
      | .fields[]      |-->| val = hitcount        |
      +----------------+   +-----------------------+
      | .map           |     | .size               |
      +----------------+     +---------------------+
  +---| .field_vars[]  |     | .offset             |
  |   +----------------+     +---------------------+
  |+--| .var_refs[]    |     | .offset             |
  ||  +----------------+     +---------------------+
  ||                         | .fn()               |
  ||   var_ref_vals[]        +---------------------+
  ||  +-------------+        | .flags              |
  ||  | $ts0        |<---+   +---------------------+
  ||  +-------------+    |   | .var.idx            |
  ||  | $next_pid   |<-+ |   +---------------------+
  ||  +-------------+  | |   | .var.hist_data      |
  ||+>| $wakeup_lat |  | |   +---------------------+
  ||| +-------------+  | |   | .var_ref_idx        |
  ||| |             |  | | +-----------------------+
  ||| +-------------+  | | | var = wakeup_lat      |
  |||        .         | | +-----------------------+
  |||        .         | |   | .size               |
  |||        .         | |   +---------------------+
  ||| +-------------+  | |   | .offset             |
  ||| |             |  | |   +---------------------+
  ||| +-------------+  | |   | .fn()               |
  ||| |             |  | |   +---------------------+
  ||| +-------------+  | |   | .flags & FL_VAR     |
  |||                  | |   +---------------------+
  |||                  | |   | .var.idx            |
  |||                  | |   +---------------------+
  |||                  | |   | .var.hist_data      |
  |||                  | |   +---------------------+
  |||                  | |   | .var_ref_idx        |
  |||                  | |   +---------------------+
  |||                  | |              .
  |||                  | |              .
  |||                  | |              .
  |||                  | |              .
  ||| +--------------+ | |              .
  +-->| field_var    | | |              .
   || +--------------+ | |              .
   ||   | var        | | |              .
   ||   +------------+ | |              .
   ||   | val        | | |              .
   || +--------------+ | |              .
   || | field_var    | | |              .
   || +--------------+ | |              .
   ||   | var        | | |              .
   ||   +------------+ | |              .
   ||   | val        | | |              .
   ||   +------------+ | |              .
   ||         .        | |              .
   ||         .        | |              .
   ||         .        | | +-----------------------+ <--- n_vals
   || +--------------+ | | | key = pid             |
   || | field_var    | | | +-----------------------+
   || +--------------+ | |   | .size               |
   ||   | var        |--+|   +---------------------+
   ||   +------------+ |||   | .offset             |
   ||   | val        |-+||   +---------------------+
   ||   +------------+ |||   | .fn()               |
   ||                  |||   +---------------------+
   ||                  |||   | .flags              |
   ||                  |||   +---------------------+
   ||                  |||   | .var.idx            |
   ||                  |||   +---------------------+ <--- n_fields
   ||                  |||
   ||                  |||                           n_keys = n_fields - n_vals
   ||                  ||| +-----------------------+
   ||                  |+->| var = next_pid        |
   ||                  | | +-----------------------+
   ||                  | |   | .size               |
   ||                  | |   +---------------------+
   ||                  | |   | .offset             |
   ||                  | |   +---------------------+
   ||                  | |   | .flags & FL_VAR     |
   ||                  | |   +---------------------+
   ||                  | |   | .var.idx            |
   ||                  | |   +---------------------+
   ||                  | |   | .var.hist_data      |
   ||                  | | +-----------------------+
   ||                  +-->| val for next_pid      |
   ||                  | | +-----------------------+
   ||                  | |   | .size               |
   ||                  | |   +---------------------+
   ||                  | |   | .offset             |
   ||                  | |   +---------------------+
   ||                  | |   | .fn()               |
   ||                  | |   +---------------------+
   ||                  | |   | .flags              |
   ||                  | |   +---------------------+
   ||                  | |   |                     |
   ||                  | |   +---------------------+
   ||                  | |
   ||                  | |
   ||                  | | +-----------------------+
   +|------------------|-|>| var_ref = $ts0        |
    |                  | | +-----------------------+
    |                  | |   | .size               |
    |                  | |   +---------------------+
    |                  | |   | .offset             |
    |                  | |   +---------------------+
    |                  | |   | .fn()               |
    |                  | |   +---------------------+
    |                  | |   | .flags & FL_VAR_REF |
    |                  | |   +---------------------+
    |                  | +---| .var_ref_idx        |
    |                  |   +-----------------------+
    |                  |   | var_ref = $next_pid   |
    |                  |   +-----------------------+
    |                  |     | .size               |
    |                  |     +---------------------+
    |                  |     | .offset             |
    |                  |     +---------------------+
    |                  |     | .fn()               |
    |                  |     +---------------------+
    |                  |     | .flags & FL_VAR_REF |
    |                  |     +---------------------+
    |                  +-----| .var_ref_idx        |
    |                      +-----------------------+
    |                      | var_ref = $wakeup_lat |
    |                      +-----------------------+
    |                        | .size               |
    |                        +---------------------+
    |                        | .offset             |
    |                        +---------------------+
    |                        | .fn()               |
    |                        +---------------------+
    |                        | .flags & FL_VAR_REF |
    |                        +---------------------+
    +------------------------| .var_ref_idx        |
                             +---------------------+

Như bạn có thể thấy, đối với một biến trường, hai trường hist_field được tạo: một
đại diện cho biến, trong trường hợp này là next_pid và một thực tế là
lấy giá trị của trường từ luồng theo dõi, giống như giá trị bình thường
lĩnh vực này.  Chúng được tạo riêng biệt với biến thông thường
tạo và được lưu trong mảng hist_data->field_vars[].  Xem
bên dưới để biết cách sử dụng chúng.  Ngoài ra, một hist_field tham chiếu là
cũng được tạo, cần thiết để tham chiếu các biến trường như
Biến $next_pid trong hành động trace().

Lưu ý rằng $wakeup_lat cũng là một tham chiếu biến, tham chiếu đến
giá trị của biểu thức common_timestamp-$ts0, và do đó cũng cần phải
có mục nhập trường lịch sử đại diện cho tham chiếu đó được tạo.

Khi hist_trigger_elt_update() được gọi để lấy khóa thông thường và
các trường giá trị, nó cũng gọi update_field_vars(), đi qua
mỗi field_var được tạo cho biểu đồ và có sẵn từ
hist_data->field_vars và gọi val->fn() để lấy dữ liệu từ
bản ghi theo dõi hiện tại, sau đó sử dụng var.idx của var để thiết lập
biến ở phần bù var.idx trong tracing_map_elt thích hợp
biến tại elt->vars[var.idx].

Khi tất cả các biến đã được cập nhật, Resolve_var_refs() có thể
được gọi từ event_hist_trigger(), và không chỉ $ts0 và
Các tham chiếu $next_pid được giải quyết nhưng tham chiếu $wakeup_lat như
tốt.  Tại thời điểm này, hành động trace() có thể chỉ cần truy cập các giá trị
được tập hợp trong mảng var_ref_vals[] và tạo sự kiện theo dõi.

Quá trình tương tự xảy ra đối với các biến trường liên quan đến
hành động lưu().

Các chữ viết tắt sử dụng trong sơ đồ::

hist_data = struct hist_trigger_data
  hist_data.fields = struct hist_field
  field_var = struct field_var
  fn = hist_field_fn_t
  FL_KEY = HIST_FIELD_FL_KEY
  FL_VAR = HIST_FIELD_FL_VAR
  FL_VAR_REF = HIST_FIELD_FL_VAR_REF

kiểm tra biến trường hành động trace()
----------------------------------

Ví dụ này bổ sung vào ví dụ thử nghiệm trước đó bằng cách sử dụng
của biến Wakeup_lat, nhưng ngoài ra còn tạo ra một vài
các biến trường sau đó đều được chuyển đến dấu vết Wakeup_latency()
hành động thông qua trình xử lý onmatch().

Đầu tiên, chúng ta tạo sự kiện tổng hợp Wakeup_latency::

# echo 'wakeup_latency u64 lat; pid_t pid; char comm[16]' >> tổng hợp_events

Tiếp theo, trình kích hoạt sched_waking từ các ví dụ trước::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

Cuối cùng, như trong ví dụ thử nghiệm trước, chúng tôi tính toán và gán giá trị
độ trễ đánh thức bằng cách sử dụng tham chiếu $ts0 từ trình kích hoạt sched_waking
vào biến Wakeup_lat và cuối cùng sử dụng nó cùng với một vài
các trường sự kiện sched_switch, next_pid và next_comm, để tạo
sự kiện theo dõi Wakeup_latency.  Các trường sự kiện next_pid và next_comm
được tự động chuyển đổi thành các biến trường cho mục đích này::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid,next_comm)' >> /sys/kernel/tracing/events/sched/sched_switch/trigger

Đầu ra sched_waking hist_debug hiển thị cùng dữ liệu như trong
ví dụ kiểm tra trước::

Sự kiện # cat/đã lên lịch/sched_waking/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid:vals=hitcount:ts0=common_timestamp.usecs:sort=hitcount:size=2048:clock=global [hoạt động]
  #

dữ liệu lịch sử: 00000000d60ff61f

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

Đầu ra sched_switch hist_debug hiển thị các trường khóa và giá trị giống nhau
như trong ví dụ kiểm tra trước - lưu ý rằng Wakeup_lat vẫn nằm trong
phần trường val, nhưng các biến trường mới không có ở đó -
mặc dù các biến trường là các biến nhưng chúng được giữ riêng biệt trong
mảng field_vars[] của hist_data.  Mặc dù các biến trường và
các biến thông thường được đặt ở những nơi riêng biệt, bạn có thể thấy rằng
vị trí biến thực tế cho các biến đó trong
tracing_map_elt.vars[] có chỉ số tăng như mong đợi:
Wakeup_lat lấy vị trí var.idx = 0, trong khi các biến trường cho
next_pid và next_comm có giá trị var.idx = 1 và var.idx = 2. Lưu ý
cũng đó là những giá trị tương tự được hiển thị cho biến
tham chiếu tương ứng với các biến đó trong tham chiếu biến
phần trường.  Vì có hai trình kích hoạt và do đó có hai hist_data
địa chỉ, những địa chỉ đó cũng cần được tính đến khi thực hiện
khớp - bạn có thể thấy biến đầu tiên đề cập đến 0
var.idx trên trình kích hoạt lịch sử trước đó (xem địa chỉ hist_data
được liên kết với trình kích hoạt đó), trong khi biến thứ hai đề cập đến
0 var.idx trên trình kích hoạt lịch sử sched_switch, cũng như tất cả các phần còn lại
tham chiếu biến.

Cuối cùng phần biến theo dõi hành động chỉ hiển thị hệ thống
và tên sự kiện cho trình xử lý onmatch()::

Sự kiện # cat/đã lên lịch/sched_switch/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=next_pid:vals=hitcount:wakeup_lat=common_timestamp.usecs-$ts0:sort=hitcount:size=2048:clock=global:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid,next_comm) [hoạt động]
  #

dữ liệu lịch sử: 0000000008f551b7

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 0
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

trường tham chiếu biến:

hist_data->var_refs[0]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 00000000d60ff61f
      var_ref_idx (vào hist_data->var_refs[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->var_refs[1]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 0000000008f551b7
      var_ref_idx (vào hist_data->var_refs[]): 1
      loại: u64
      kích thước: 0
      được_ký: 0

hist_data->var_refs[2]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: next_pid
      var.idx (vào tracing_map_elt.vars[]): 1
      var.hist_data: 0000000008f551b7
      var_ref_idx (vào hist_data->var_refs[]): 2
      gõ: pid_t
      kích thước: 4
      được_ký: 0

hist_data->var_refs[3]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: next_comm
      var.idx (vào tracing_map_elt.vars[]): 2
      var.hist_data: 0000000008f551b7
      var_ref_idx (vào hist_data->var_refs[]): 3
      loại: char[16]
      kích thước: 256
      được_ký: 0

biến trường:

hist_data->field_vars[0]:

field_vars[0].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: next_pid
      var.idx (vào tracing_map_elt.vars[]): 1

field_vars[0].val:
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 4
      được_ký: 1

hist_data->field_vars[1]:

field_vars[1].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: next_comm
      var.idx (vào tracing_map_elt.vars[]): 2

field_vars[1].val:
      Tên ftrace_event_field: next_comm
      loại: char[16]
      kích thước: 256
      được_ký: 0

các biến theo dõi hành động (đối với onmax()/onchange()/onmatch()):

hist_data->actions[0].match_data.event_system: đã lên lịch
    hist_data->actions[0].match_data.event: sched_waking

Các lệnh bên dưới có thể được sử dụng để dọn dẹp mọi thứ cho lần kiểm tra tiếp theo::

# echo '!hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid,next_comm)' >> /sys/kernel/tracing/events/sched/sched_switch/trigger

# echo '!hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

# echo '!wakeup_latency u64 lat; pid_t pid; char comm[16]' >> tổng hợp_events

action_data và hành động trace()
----------------------------------

Như đã đề cập ở trên, khi hành động trace() tạo ra một kết quả tổng hợp
sự kiện, tất cả các thông số cho sự kiện tổng hợp đều đã có sẵn
các biến hoặc được chuyển đổi thành các biến (thông qua các biến trường) và
cuối cùng tất cả các giá trị biến đó được thu thập thông qua các tham chiếu đến chúng
vào một mảng var_ref_vals[].

Tuy nhiên, các giá trị trong mảng var_ref_vals[] không nhất thiết
tuân theo thứ tự tương tự như các thông số sự kiện tổng hợp.  Để giải quyết
rằng, struct action_data chứa một mảng khác, var_ref_idx[]
ánh xạ các thông số hành động theo dõi tới các giá trị var_ref_vals[].  Dưới đây là một
sơ đồ minh họa điều đó cho sự kiện tổng hợp Wakeup_latency() ::

+------+ Wakeup_latency()
  Thông số sự kiện ZZ0000ZZ var_ref_vals[]
  +-------------------+ +-----------------+ +-----------------+
    ZZ0001ZZ--->ZZ0002ZZ---+ ZZ0003ZZ
    +++ +-------------------+ |    +-----------------+
    ZZ0004ZZ ZZ0005ZZ---ZZ0006ZZ $wakeup_lat giá trị |
    ++----------------+ +-----------------+ ZZ0007ZZ +-----------------+
                                   .            ZZ0008ZZ giá trị $next_pid |
                                   .            |    +-----------------+
                                   .            |           .
                          +-----------------+ |           .
			  ZZ0009ZZ |           .
			  +-----------------+ |    +-----------------+
                                                +--->ZZ0010ZZ
                                                     +-----------------+

Về cơ bản, làm thế nào điều này được sử dụng trong thăm dò sự kiện tổng hợp
hàm, trace_event_raw_event_synth(), như sau::

cho mỗi trường tôi trong .synth_event
    val_idx = .var_ref_idx[i]
    val = var_ref_vals[val_idx]

action_data và trình xử lý onXXX()
------------------------------------

Lịch sử kích hoạt các hành động onXXX() khác với onmatch(), chẳng hạn như onmax()
và onchange(), cũng tận dụng và tạo nội bộ các ẩn
các biến.  Thông tin này được chứa trong
Cấu trúc action_data.track_data và cũng hiển thị trong hist_debug
đầu ra như sẽ được mô tả trong ví dụ dưới đây.

Thông thường, các trình xử lý onmax() hoặc onchange() được sử dụng kết hợp
với các hành động save() và snapshot().  Ví dụ::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0: \
          onmax($wakeup_lat).save(next_comm,prev_pid,prev_prio,prev_comm)' >>
          /sys/kernel/tracing/events/sched/sched_switch/trigger

hoặc::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0: \
          onmax($wakeup_lat).snapshot()' >>
          /sys/kernel/tracing/events/sched/sched_switch/trigger

kiểm tra biến trường hành động save()
---------------------------------

Trong ví dụ này, thay vì tạo ra một sự kiện tổng hợp, hàm save()
hành động được sử dụng để lưu giá trị trường bất cứ khi nào trình xử lý onmax()
phát hiện rằng độ trễ tối đa mới đã đạt được.  Như ở phần trước
Ví dụ: các giá trị được lưu cũng là giá trị trường, nhưng trong trường hợp này
trường hợp này, được giữ trong một mảng hist_data riêng có tên save_vars[].

Như trong các ví dụ thử nghiệm trước, chúng tôi thiết lập trình kích hoạt sched_waking::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

Tuy nhiên, trong trường hợp này, chúng tôi thiết lập trình kích hoạt sched_switch để lưu một số
giá trị trường sched_switch bất cứ khi nào chúng tôi đạt đến độ trễ tối đa mới.  cho
cả trình xử lý onmax() và hành động save(), các biến sẽ được tạo,
mà chúng ta có thể sử dụng tệp hist_debug để kiểm tra ::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmax($wakeup_lat).save(next_comm,prev_pid,prev_prio,prev_comm)' >> sự kiện/lập lịch/sched_switch/trigger

Đầu ra sched_waking hist_debug hiển thị cùng dữ liệu như trong
ví dụ thử nghiệm trước đó::

Sự kiện # cat/đã lên lịch/sched_waking/hist_debug

#
  Thông tin về # trigger: hist:keys=pid:vals=hitcount:ts0=common_timestamp.usecs:sort=hitcount:size=2048:clock=global [hoạt động]
  #

dữ liệu lịch sử: 00000000e6290f48

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

Đầu ra của trình kích hoạt sched_switch hiển thị cùng một giá trị và khóa
các giá trị như trước nhưng cũng hiển thị một vài phần mới.

Đầu tiên, phần biến theo dõi hành động hiện hiển thị
actions[].track_data thông tin mô tả việc theo dõi đặc biệt
các biến và tham chiếu được sử dụng để theo dõi, trong trường hợp này, hoạt động
giá trị tối đa.  Thành viên actions[].track_data.var_ref chứa
tham chiếu đến biến đang được theo dõi, trong trường hợp này là $wakeup_lat
biến.  Để thực hiện hàm xử lý onmax(), có
cũng cần phải là một biến theo dõi mức tối đa hiện tại bằng cách nhận
được cập nhật bất cứ khi nào đạt mức tối đa mới.  Trong trường hợp này, chúng ta có thể thấy rằng
một biến được tạo tự động có tên ' __max' đã được tạo và
hiển thị trong biến actions[].track_data.track_var.

Cuối cùng, trong phần 'lưu biến hành động' mới, chúng ta có thể thấy rằng
4 thông số của hàm save() đã tạo ra 4 biến trường
được tạo ra nhằm mục đích lưu giữ các giá trị của tên được đặt tên
các trường khi đạt mức tối đa.  Các biến này được giữ riêng biệt
mảng save_vars[] nằm ngoài hist_data, do đó được hiển thị ở một phần riêng biệt
phần::

Sự kiện # cat/đã lên lịch/sched_switch/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=next_pid:vals=hitcount:wakeup_lat=common_timestamp.usecs-$ts0:sort=hitcount:size=2048:clock=global:onmax($wakeup_lat).save(next_comm,prev_pid,prev_prio,prev_comm) [hoạt động]
  #

dữ liệu lịch sử: 0000000057bcd28d

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 0
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

trường tham chiếu biến:

hist_data->var_refs[0]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 00000000e6290f48
      var_ref_idx (vào hist_data->var_refs[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->var_refs[1]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 0000000057bcd28d
      var_ref_idx (vào hist_data->var_refs[]): 1
      loại: u64
      kích thước: 0
      được_ký: 0

các biến theo dõi hành động (đối với onmax()/onchange()/onmatch()):

hist_data->actions[0].track_data.var_ref:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 0000000057bcd28d
      var_ref_idx (vào hist_data->var_refs[]): 1
      loại: u64
      kích thước: 0
      được_ký: 0

hist_data->actions[0].track_data.track_var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: __max
      var.idx (vào tracing_map_elt.vars[]): 1
      loại: u64
      kích thước: 8
      được_ký: 0

lưu các biến hành động (thông số save()):

hist_data->save_vars[0]:

save_vars[0].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: next_comm
      var.idx (vào tracing_map_elt.vars[]): 2

save_vars[0].val:
      Tên ftrace_event_field: next_comm
      loại: char[16]
      kích thước: 256
      được_ký: 0

hist_data->save_vars[1]:

save_vars[1].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: prev_pid
      var.idx (vào tracing_map_elt.vars[]): 3

save_vars[1].val:
      Tên ftrace_event_field: prev_pid
      gõ: pid_t
      kích thước: 4
      được_ký: 1

hist_data->save_vars[2]:

save_vars[2].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: prev_prio
      var.idx (vào tracing_map_elt.vars[]): 4

save_vars[2].val:
      Tên ftrace_event_field: prev_prio
      kiểu: int
      kích thước: 4
      được_ký: 1

hist_data->save_vars[3]:

save_vars[3].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: prev_comm
      var.idx (vào tracing_map_elt.vars[]): 5

save_vars[3].val:
      Tên ftrace_event_field: prev_comm
      loại: char[16]
      kích thước: 256
      được_ký: 0

Các lệnh bên dưới có thể được sử dụng để dọn dẹp mọi thứ cho lần kiểm tra tiếp theo::

# echo '!hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmax($wakeup_lat).save(next_comm,prev_pid,prev_prio,prev_comm)' >> sự kiện/lập lịch/sched_switch/trigger

# echo '!hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

Một số trường hợp đặc biệt
======================

Mặc dù phần trên bao gồm những điều cơ bản về phần bên trong của biểu đồ, nhưng có
là một vài trường hợp đặc biệt cần được thảo luận, vì chúng
có xu hướng tạo ra nhiều nhầm lẫn hơn.  Đó là những biến trường trên khác
biểu đồ và bí danh, cả hai đều được mô tả bên dưới thông qua các bài kiểm tra mẫu
bằng cách sử dụng tệp hist_debug.

Kiểm tra các biến trường trên các biểu đồ khác
-------------------------------------------

Ví dụ này tương tự như các ví dụ trước, nhưng trong trường hợp này,
trình kích hoạt sched_switch tham chiếu trường kích hoạt lịch sử trên một trường khác
sự kiện, cụ thể là sự kiện sched_waking.  Để thực hiện được điều này, một
biến trường được tạo cho sự kiện khác, nhưng vì một sự kiện hiện có
không thể sử dụng biểu đồ vì biểu đồ hiện có là bất biến, một biểu đồ mới
biểu đồ với một biến phù hợp được tạo và sử dụng, chúng ta sẽ thấy
được phản ánh trong đầu ra hist_debug được hiển thị bên dưới.

Đầu tiên, chúng ta tạo sự kiện tổng hợp Wakeup_latency.  Lưu ý
bổ sung trường ưu tiên::

# echo 'wakeup_latency u64 lat; pid_t pid; int prio' >> tổng hợp_events

Như trong các ví dụ thử nghiệm trước, chúng tôi thiết lập trình kích hoạt sched_waking::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

Ở đây chúng tôi thiết lập trình kích hoạt lịch sử trên sched_switch để gửi Wakeup_latency
sự kiện bằng cách sử dụng trình xử lý onmatch đặt tên cho sự kiện sched_waking.  Lưu ý
rằng thông số thứ ba được chuyển tới Wakeup_latency() là ưu tiên,
đó là tên trường cần phải tạo một biến trường cho
nó.  Tuy nhiên, không có trường ưu tiên nào trong sự kiện sched_switch nên
có vẻ như không thể tạo một biến trường
cho nó.  Sự kiện sched_waking phù hợp có trường ưu tiên, vì vậy nó
nên có thể sử dụng nó cho mục đích này.  vấn đề
với điều đó là hiện tại không thể xác định một biến mới
trên biểu đồ hiện có, do đó không thể thêm trường ưu tiên mới
biến theo biểu đồ sched_waking hiện có.  Tuy nhiên đó là
có thể tạo thêm biểu đồ sched_waking 'khớp' mới
cho cùng một sự kiện, nghĩa là nó sử dụng cùng một khóa và bộ lọc, đồng thời
xác định biến trường ưu tiên mới trên đó.

Đây là trình kích hoạt sched_switch::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid,prio)' >> sự kiện/sched/sched_switch/trigger

Và đây là đầu ra của thông tin hist_debug cho
trình kích hoạt lịch sử sched_waking.  Lưu ý rằng có hai biểu đồ
được hiển thị ở đầu ra: đầu tiên là sched_waking bình thường
biểu đồ chúng ta đã thấy trong các ví dụ trước và biểu đồ thứ hai là
biểu đồ đặc biệt mà chúng tôi đã tạo để cung cấp biến trường ưu tiên.

Nhìn vào biểu đồ thứ hai bên dưới, chúng ta thấy một biến có tên
tổng hợp_prio.  Đây là biến trường được tạo cho trường ưu tiên
trên biểu đồ sched_waking đó::

Sự kiện # cat/đã lên lịch/sched_waking/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid:vals=hitcount:ts0=common_timestamp.usecs:sort=hitcount:size=2048:clock=global [hoạt động]
  #

dữ liệu lịch sử: 00000000349570e4

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1


Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid:vals=hitcount:synthetic_prio=prio:sort=hitcount:size=2048 [hoạt động]
  #

dữ liệu lịch sử: 000000006920cf38

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      Tên ftrace_event_field: ưu tiên
      var.name: tổng hợp_prio
      var.idx (vào tracing_map_elt.vars[]): 0
      kiểu: int
      kích thước: 4
      được_ký: 1

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

Nhìn vào biểu đồ sched_switch bên dưới, chúng ta có thể thấy tham chiếu đến
biến tổng hợp_prio trên sched_waking và xem xét
địa chỉ hist_data được liên kết, chúng tôi thấy rằng nó thực sự được liên kết với
biểu đồ mới.  Cũng lưu ý rằng các tài liệu tham khảo khác là về một
biến bình thường, Wakeup_lat và biến trường bình thường, next_pid,
các chi tiết trong đó có trong phần biến trường ::

Sự kiện # cat/đã lên lịch/sched_switch/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=next_pid:vals=hitcount:wakeup_lat=common_timestamp.usecs-$ts0:sort=hitcount:size=2048:clock=global:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid,prio) [hoạt động]
  #

dữ liệu lịch sử: 00000000a73b67df

n_vals: 2
  n_keys: 1
  n_field: 3

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      loại: u64
      kích thước: 0
      được_ký: 0

các trường chính:

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

trường tham chiếu biến:

hist_data->var_refs[0]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: ts0
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 00000000349570e4
      var_ref_idx (vào hist_data->var_refs[]): 0
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->var_refs[1]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 00000000a73b67df
      var_ref_idx (vào hist_data->var_refs[]): 1
      loại: u64
      kích thước: 0
      được_ký: 0

hist_data->var_refs[2]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: next_pid
      var.idx (vào tracing_map_elt.vars[]): 1
      var.hist_data: 00000000a73b67df
      var_ref_idx (vào hist_data->var_refs[]): 2
      gõ: pid_t
      kích thước: 4
      được_ký: 0

hist_data->var_refs[3]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: tổng hợp_prio
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 000000006920cf38
      var_ref_idx (vào hist_data->var_refs[]): 3
      kiểu: int
      kích thước: 4
      được_ký: 1

biến trường:

hist_data->field_vars[0]:

field_vars[0].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: next_pid
      var.idx (vào tracing_map_elt.vars[]): 1

field_vars[0].val:
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 4
      được_ký: 1

các biến theo dõi hành động (đối với onmax()/onchange()/onmatch()):

hist_data->actions[0].match_data.event_system: đã lên lịch
    hist_data->actions[0].match_data.event: sched_waking

Các lệnh bên dưới có thể được sử dụng để dọn dẹp mọi thứ cho lần kiểm tra tiếp theo::

# echo '!hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,next_pid,prio)' >> sự kiện/sched/sched_switch/trigger

# echo '!hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

# echo '!wakeup_latency u64 lat; pid_t pid; int prio' >> tổng hợp_events

Kiểm tra bí danh
----------

Ví dụ này rất giống với các ví dụ trước, nhưng chứng tỏ
cờ bí danh.

Đầu tiên, chúng ta tạo sự kiện tổng hợp Wakeup_latency::

# echo 'wakeup_latency u64 lat; pid_t pid; char comm[16]' >> tổng hợp_events

Tiếp theo, chúng ta tạo trình kích hoạt sched_waking tương tự như các ví dụ trước,
nhưng trong trường hợp này chúng tôi lưu pid trong biến Wakeing_pid ::

# echo 'hist:keys=pid:waking_pid=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

Đối với trình kích hoạt sched_switch, thay vì sử dụng $waking_pid trực tiếp trong
lời gọi sự kiện tổng hợp Wakeup_latency, chúng tôi tạo bí danh là
$waking_pid có tên $woken_pid và sử dụng tên đó trong sự kiện tổng hợp
thay vào đó hãy gọi::

# echo 'hist:keys=next_pid:woken_pid=$waking_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,$woken_pid,next_comm)' >> sự kiện/lập lịch/sched_switch/trigger

Nhìn vào đầu ra sched_waking hist_debug, ngoài
các trường bình thường, chúng ta có thể thấy biến Wakeing_pid ::

Sự kiện # cat/đã lên lịch/sched_waking/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid:vals=hitcount:waking_pid=pid,ts0=common_timestamp.usecs:sort=hitcount:size=2048:clock=global [hoạt động]
  #

dữ liệu lịch sử: 00000000a250528c

n_vals: 3
  n_keys: 1
  n_field: 4

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
      Tên ftrace_event_field: pid
      var.name: Wake_pid
      var.idx (vào tracing_map_elt.vars[]): 0
      gõ: pid_t
      kích thước: 4
      được_ký: 1

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: ts0
      var.idx (vào tracing_map_elt.vars[]): 1
      loại: u64
      kích thước: 8
      được_ký: 0

các trường chính:

hist_data->fields[3]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

Đầu ra sched_switch hist_debug cho thấy một biến có tên
Waken_pid đã được tạo nhưng nó cũng có
Bộ cờ HIST_FIELD_FL_ALIAS.  Nó cũng có cờ HIST_FIELD_FL_VAR
set, đó là lý do tại sao nó xuất hiện trong phần trường val.

Bất chấp chi tiết triển khai đó, một biến bí danh thực sự phức tạp hơn
giống như một tham chiếu biến; trong thực tế nó có thể được coi là một tài liệu tham khảo
đến một tài liệu tham khảo.  Việc triển khai sao chép var_ref->fn() từ
tham chiếu biến đang được tham chiếu, trong trường hợp này là Wake_pid
fn(), đó là hist_field_var_ref() và biến nó thành fn() của
bí danh.  Hist_field_var_ref() fn() yêu cầu var_ref_idx của
tham chiếu biến mà nó đang sử dụng, do đó, var_ref_idx của Wake_pid cũng
được sao chép vào bí danh.  Kết quả cuối cùng là khi giá trị của bí danh
được lấy ra, cuối cùng nó chỉ làm điều tương tự như bản gốc
tham chiếu sẽ được thực hiện và lấy cùng một giá trị từ
mảng var_ref_vals[]  Bạn có thể xác minh điều này ở đầu ra bằng cách lưu ý
rằng var_ref_idx của bí danh, trong trường hợp này là Waken_pid, giống nhau
dưới dạng var_ref_idx của tham chiếu, Wakeing_pid, trong biến
phần trường tham chiếu.

Ngoài ra, khi nó nhận được giá trị đó, vì nó cũng là một biến, nên nó
sau đó lưu giá trị đó vào var.idx của nó.  Vì vậy, var.idx của
Bí danh Waken_pid là 0, nó chứa giá trị từ var_ref_idx 0
khi fn() của nó được gọi để tự cập nhật.  Bạn cũng sẽ nhận thấy rằng
có một Waken_pid var_ref trong phần refs biến.  Đó là
tham chiếu đến biến bí danh Waken_pid và bạn có thể thấy rằng nó
truy xuất giá trị từ cùng var.idx với bí danh Waken_pid, 0,
và sau đó lần lượt lưu giá trị đó vào khe var_ref_idx của chính nó, 3 và
giá trị ở vị trí này cuối cùng là giá trị được gán cho
Vị trí $woken_pid trong lệnh gọi sự kiện theo dõi::

Sự kiện # cat/đã lên lịch/sched_switch/hist_debug

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=next_pid:vals=hitcount:woken_pid=$waking_pid,wakeup_lat=common_timestamp.usecs-$ts0:sort=hitcount:size=2048:clock=global:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,$woken_pid,next_comm) [hoạt động]
  #

dữ liệu lịch sử: 0000000055d65ed0

n_vals: 3
  n_keys: 1
  n_field: 4

trường giá trị:

hist_data->fields[0]:
      cờ:
        VAL: HIST_FIELD_FL_HITCOUNT
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->fields[1]:
      cờ:
        HIST_FIELD_FL_VAR
        HIST_FIELD_FL_ALIAS
      var.name: Waken_pid
      var.idx (vào tracing_map_elt.vars[]): 0
      var_ref_idx (vào hist_data->var_refs[]): 0
      gõ: pid_t
      kích thước: 4
      được_ký: 1

hist_data->fields[2]:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 1
      loại: u64
      kích thước: 0
      được_ký: 0

các trường chính:

hist_data->fields[3]:
      cờ:
        HIST_FIELD_FL_KEY
      Tên ftrace_event_field: next_pid
      gõ: pid_t
      kích thước: 8
      được_ký: 1

trường tham chiếu biến:

hist_data->var_refs[0]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Wake_pid
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 00000000a250528c
      var_ref_idx (vào hist_data->var_refs[]): 0
      gõ: pid_t
      kích thước: 4
      được_ký: 1

hist_data->var_refs[1]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      tên: ts0
      var.idx (vào tracing_map_elt.vars[]): 1
      var.hist_data: 00000000a250528c
      var_ref_idx (vào hist_data->var_refs[]): 1
      loại: u64
      kích thước: 8
      được_ký: 0

hist_data->var_refs[2]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Wakeup_lat
      var.idx (vào tracing_map_elt.vars[]): 1
      var.hist_data: 0000000055d65ed0
      var_ref_idx (vào hist_data->var_refs[]): 2
      loại: u64
      kích thước: 0
      được_ký: 0

hist_data->var_refs[3]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: Waken_pid
      var.idx (vào tracing_map_elt.vars[]): 0
      var.hist_data: 0000000055d65ed0
      var_ref_idx (vào hist_data->var_refs[]): 3
      gõ: pid_t
      kích thước: 4
      được_ký: 1

hist_data->var_refs[4]:
      cờ:
        HIST_FIELD_FL_VAR_REF
      Tên: next_comm
      var.idx (vào tracing_map_elt.vars[]): 2
      var.hist_data: 0000000055d65ed0
      var_ref_idx (vào hist_data->var_refs[]): 4
      loại: char[16]
      kích thước: 256
      được_ký: 0

biến trường:

hist_data->field_vars[0]:

field_vars[0].var:
      cờ:
        HIST_FIELD_FL_VAR
      var.name: next_comm
      var.idx (vào tracing_map_elt.vars[]): 2

field_vars[0].val:
      Tên ftrace_event_field: next_comm
      loại: char[16]
      kích thước: 256
      được_ký: 0

các biến theo dõi hành động (đối với onmax()/onchange()/onmatch()):

hist_data->actions[0].match_data.event_system: đã lên lịch
    hist_data->actions[0].match_data.event: sched_waking

Các lệnh bên dưới có thể được sử dụng để dọn dẹp mọi thứ cho lần kiểm tra tiếp theo::

# echo '!hist:keys=next_pid:woken_pid=$waking_pid:wakeup_lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,$woken_pid,next_comm)' >> sự kiện/lập lịch/sched_switch/trigger

# echo '!hist:keys=pid:ts0=common_timestamp.usecs' >> sự kiện/lập lịch/sched_waking/trigger

# echo '!wakeup_latency u64 lat; pid_t pid; char comm[16]' >> tổng hợp_events