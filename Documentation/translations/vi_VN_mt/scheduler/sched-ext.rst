.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-ext.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _sched-ext:

=============================
Lớp lập lịch mở rộng
=============================

sched_ext là lớp lập lịch có hành vi có thể được xác định bởi một tập hợp BPF
các chương trình - bộ lập lịch BPF.

* sched_ext xuất giao diện lập lịch đầy đủ để mọi lịch trình đều có thể
  thuật toán có thể được thực hiện trên đầu trang.

* Bộ lập lịch BPF có thể nhóm các CPU theo cách nó thấy phù hợp và lên lịch cho chúng
  cùng nhau, vì các tác vụ không bị ràng buộc với các CPU cụ thể tại thời điểm thức dậy.

* Bộ lập lịch BPF có thể được bật và tắt linh hoạt bất cứ lúc nào.

* Tính toàn vẹn của hệ thống được duy trì bất kể bộ lập lịch BPF làm gì.
  Hành vi lập lịch mặc định được khôi phục bất cứ khi nào phát hiện ra lỗi,
  một tác vụ có thể chạy được bị treo hoặc khi gọi chuỗi khóa SysRq
  ZZ0000ZZ.

* Khi bộ lập lịch BPF gây ra lỗi, thông tin gỡ lỗi sẽ được chuyển sang
  hỗ trợ gỡ lỗi. Kết xuất gỡ lỗi được chuyển đến và in ra bởi
  lập lịch nhị phân. Kết xuất gỡ lỗi cũng có thể được truy cập thông qua
  Điểm theo dõi ZZ0000ZZ. Chuỗi khóa SysRq ZZ0001ZZ
  kích hoạt kết xuất gỡ lỗi. Điều này không chấm dứt bộ lập lịch BPF và có thể
  chỉ được đọc thông qua tracepoint.

Chuyển sang và từ sched_ext
===============================

ZZ0000ZZ là tùy chọn cấu hình để bật sched_ext và
ZZ0001ZZ chứa các bộ lập lịch mẫu. Cấu hình sau
các tùy chọn nên được kích hoạt để sử dụng sched_ext:

.. code-block:: none

    CONFIG_BPF=y
    CONFIG_SCHED_CLASS_EXT=y
    CONFIG_BPF_SYSCALL=y
    CONFIG_BPF_JIT=y
    CONFIG_DEBUG_INFO_BTF=y
    CONFIG_BPF_JIT_ALWAYS_ON=y
    CONFIG_BPF_JIT_DEFAULT_ON=y

sched_ext chỉ được sử dụng khi bộ lập lịch BPF được tải và chạy.

Nếu một tác vụ đặt chính sách lập lịch của nó một cách rõ ràng thành ZZ0000ZZ, thì nó sẽ
được coi là ZZ0001ZZ và được lập lịch bởi bộ lập lịch cấp công bằng cho đến khi
Bộ lập lịch BPF đã được tải.

Khi bộ lập lịch BPF được tải và ZZ0000ZZ chưa được đặt
trong ZZ0001ZZ, tất cả ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và
Nhiệm vụ ZZ0005ZZ được lên lịch bởi sched_ext.

Tuy nhiên, khi bộ lập lịch BPF được tải và ZZ0000ZZ được
được đặt trong ZZ0001ZZ, chỉ các tác vụ có chính sách ZZ0002ZZ mới được lên lịch
bởi sched_ext, trong khi các tác vụ với ZZ0003ZZ, ZZ0004ZZ và
Các chính sách của ZZ0005ZZ được lên lịch bởi bộ lập lịch phân loại công bằng có
mức độ ưu tiên của sched_class cao hơn ZZ0006ZZ.

Chấm dứt chương trình lập lịch sched_ext, kích hoạt ZZ0000ZZ, hoặc
phát hiện bất kỳ lỗi nội bộ nào bao gồm các tác vụ có thể chạy bị đình trệ sẽ hủy bỏ
Bộ lập lịch BPF và hoàn nguyên tất cả các tác vụ về bộ lập lịch công bằng.

.. code-block:: none

    # make -j16 -C tools/sched_ext
    # tools/sched_ext/build/bin/scx_simple
    local=0 global=3
    local=5 global=24
    local=9 global=44
    local=13 global=56
    local=17 global=72
    ^CEXIT: BPF scheduler unregistered

Trạng thái hiện tại của bộ lập lịch BPF có thể được xác định như sau:

.. code-block:: none

    # cat /sys/kernel/sched_ext/state
    enabled
    # cat /sys/kernel/sched_ext/root/ops
    simple

Bạn có thể kiểm tra xem có bộ lập lịch BPF nào đã được tải kể từ khi khởi động hay không bằng cách kiểm tra
bộ đếm tăng đơn điệu này (giá trị bằng 0 biểu thị rằng không có BPF
bộ lập lịch đã được tải):

.. code-block:: none

    # cat /sys/kernel/sched_ext/enable_seq
    1

Mỗi bộ lập lịch đang chạy cũng hiển thị một tệp ZZ0000ZZ cho mỗi bộ lập lịch trong
ZZ0001ZZ theo dõi chẩn đoán
quầy. Mỗi bộ đếm chiếm một dòng ZZ0002ZZ:

.. code-block:: none

    # cat /sys/kernel/sched_ext/simple/events
    SCX_EV_SELECT_CPU_FALLBACK 0
    SCX_EV_DISPATCH_LOCAL_DSQ_OFFLINE 0
    SCX_EV_DISPATCH_KEEP_LAST 123
    SCX_EV_ENQ_SKIP_EXITING 0
    SCX_EV_ENQ_SKIP_MIGRATION_DISABLED 0
    SCX_EV_REENQ_IMMED 0
    SCX_EV_REENQ_LOCAL_REPEAT 0
    SCX_EV_REFILL_SLICE_DFL 456789
    SCX_EV_BYPASS_DURATION 0
    SCX_EV_BYPASS_DISPATCH 0
    SCX_EV_BYPASS_ACTIVATE 0
    SCX_EV_INSERT_NOT_OWNED 0
    SCX_EV_SUB_BYPASS_DISPATCH 0

Bộ đếm được mô tả trong ZZ0000ZZ; ngắn gọn:

* ZZ0000ZZ: ops.select_cpu() trả về CPU không sử dụng được bởi
  nhiệm vụ và bộ lập lịch cốt lõi đã âm thầm chọn một CPU dự phòng.
* ZZ0001ZZ: một công văn DSQ cục bộ đã được chuyển hướng
  tới DSQ toàn cầu vì CPU mục tiêu đã ngoại tuyến.
* ZZ0002ZZ: một tác vụ tiếp tục chạy vì không có tác vụ nào khác
  nhiệm vụ đã có sẵn (chỉ khi ZZ0003ZZ chưa được đặt).
* ZZ0004ZZ: một tác vụ thoát đã được gửi đến DSQ cục bộ
  trực tiếp, bỏ qua ops.enqueue() (chỉ khi ZZ0005ZZ không được đặt).
* ZZ0006ZZ: tác vụ bị vô hiệu hóa di chuyển
  được gửi trực tiếp đến DSQ cục bộ của nó (chỉ khi
  ZZ0007ZZ chưa được đặt).
* ZZ0008ZZ: một nhiệm vụ được gửi đi với ZZ0009ZZ đã được
  được xếp lại hàng vì CPU mục tiêu không có sẵn để thực thi ngay lập tức.
* ZZ0010ZZ: kích hoạt lại hàng đợi của DSQ cục bộ
  một lần nữa; số lần đếm định kỳ cho thấy ZZ0011ZZ không chính xác
  xử lý trong bộ lập lịch BPF.
* ZZ0012ZZ: lát thời gian của nhiệm vụ đã được nạp lại bằng
  giá trị mặc định (ZZ0013ZZ).
* ZZ0014ZZ: tổng số nano giây dành cho chế độ bỏ qua.
* ZZ0015ZZ: số lượng tác vụ được gửi khi ở chế độ bỏ qua.
* ZZ0016ZZ: số lần kích hoạt chế độ bypass.
* ZZ0017ZZ: đã cố gắng chèn một tác vụ không thuộc sở hữu của tác vụ này
  lập lịch vào DSQ; những nỗ lực như vậy đều bị âm thầm bỏ qua.
* ZZ0018ZZ: nhiệm vụ được gửi đi từ đường vòng của bộ lập lịch phụ
  DSQ (chỉ phù hợp với ZZ0019ZZ).

ZZ0000ZZ là tập lệnh drgn hiển thị nhiều hơn
thông tin chi tiết:

.. code-block:: none

    # tools/sched_ext/scx_show_state.py
    ops           : simple
    enabled       : 1
    switching_all : 1
    switched_all  : 1
    enable_state  : enabled (2)
    bypass_depth  : 0
    nr_rejected   : 0
    enable_seq    : 1

Việc một nhiệm vụ nhất định có nằm trên sched_ext hay không có thể được xác định như sau:

.. code-block:: none

    # grep ext /proc/self/sched
    ext.enabled                                  :                    1

Khái niệm cơ bản
==========

Không gian người dùng có thể triển khai bộ lập lịch BPF tùy ý bằng cách tải một bộ BPF
các chương trình triển khai ZZ0000ZZ. Trường bắt buộc duy nhất
là ZZ0001ZZ phải là tên đối tượng BPF hợp lệ. Mọi hoạt động đều
tùy chọn. Đoạn trích được sửa đổi sau đây là từ
ZZ0002ZZ hiển thị bộ lập lịch FIFO toàn cầu tối thiểu.

.. code-block:: c

    /*
     * Decide which CPU a task should be migrated to before being
     * enqueued (either at wakeup, fork time, or exec time). If an
     * idle core is found by the default ops.select_cpu() implementation,
     * then insert the task directly into SCX_DSQ_LOCAL and skip the
     * ops.enqueue() callback.
     *
     * Note that this implementation has exactly the same behavior as the
     * default ops.select_cpu implementation. The behavior of the scheduler
     * would be exactly same if the implementation just didn't define the
     * simple_select_cpu() struct_ops prog.
     */
    s32 BPF_STRUCT_OPS(simple_select_cpu, struct task_struct *p,
                       s32 prev_cpu, u64 wake_flags)
    {
            s32 cpu;
            /* Need to initialize or the BPF verifier will reject the program */
            bool direct = false;

            cpu = scx_bpf_select_cpu_dfl(p, prev_cpu, wake_flags, &direct);

            if (direct)
                    scx_bpf_dsq_insert(p, SCX_DSQ_LOCAL, SCX_SLICE_DFL, 0);

            return cpu;
    }

    /*
     * Do a direct insertion of a task to the global DSQ. This ops.enqueue()
     * callback will only be invoked if we failed to find a core to insert
     * into in ops.select_cpu() above.
     *
     * Note that this implementation has exactly the same behavior as the
     * default ops.enqueue implementation, which just dispatches the task
     * to SCX_DSQ_GLOBAL. The behavior of the scheduler would be exactly same
     * if the implementation just didn't define the simple_enqueue struct_ops
     * prog.
     */
    void BPF_STRUCT_OPS(simple_enqueue, struct task_struct *p, u64 enq_flags)
    {
            scx_bpf_dsq_insert(p, SCX_DSQ_GLOBAL, SCX_SLICE_DFL, enq_flags);
    }

    s32 BPF_STRUCT_OPS_SLEEPABLE(simple_init)
    {
            /*
             * By default, all SCHED_EXT, SCHED_OTHER, SCHED_IDLE, and
             * SCHED_BATCH tasks should use sched_ext.
             */
            return 0;
    }

    void BPF_STRUCT_OPS(simple_exit, struct scx_exit_info *ei)
    {
            exit_type = ei->type;
    }

    SEC(".struct_ops")
    struct sched_ext_ops simple_ops = {
            .select_cpu             = (void *)simple_select_cpu,
            .enqueue                = (void *)simple_enqueue,
            .init                   = (void *)simple_init,
            .exit                   = (void *)simple_exit,
            .name                   = "simple",
    };

Hàng chờ gửi
---------------

Để phù hợp với trở kháng giữa lõi bộ lập lịch và bộ lập lịch BPF,
sched_ext sử dụng DSQ (hàng đợi gửi) có thể hoạt động như cả FIFO và
hàng đợi ưu tiên. Theo mặc định, có một FIFO toàn cầu (ZZ0000ZZ),
và một DSQ cục bộ cho mỗi CPU (ZZ0001ZZ). Bộ lập lịch BPF có thể quản lý
số lượng DSQ tùy ý sử dụng ZZ0002ZZ và
ZZ0003ZZ.

CPU luôn thực thi một tác vụ từ DSQ cục bộ của nó. Một nhiệm vụ được "chèn" vào một
DSQ. Một tác vụ trong DSQ không cục bộ sẽ được "di chuyển" vào DSQ cục bộ của CPU đích.

Khi CPU đang tìm kiếm tác vụ tiếp theo để chạy, nếu DSQ cục bộ không có
trống, nhiệm vụ đầu tiên được chọn. Nếu không, CPU sẽ cố gắng di chuyển một tác vụ
từ DSQ toàn cầu. Nếu điều đó cũng không mang lại tác vụ có thể chạy được,
ZZ0000ZZ được gọi.

Chu kỳ lập kế hoạch
----------------

Phần sau đây trình bày ngắn gọn cách lập lịch và thực thi một tác vụ đánh thức.

1. Khi một tác vụ được đánh thức, ZZ0000ZZ là thao tác đầu tiên
   được gọi. Điều này phục vụ hai mục đích. Đầu tiên, tối ưu hóa lựa chọn CPU
   gợi ý. Thứ hai, đánh thức CPU đã chọn nếu không hoạt động.

CPU được ZZ0000ZZ chọn là một gợi ý tối ưu hóa chứ không phải
   ràng buộc. Quyết định thực tế được đưa ra ở bước cuối cùng của việc lập kế hoạch.
   Tuy nhiên, hiệu suất sẽ tăng lên một chút nếu CPU
   ZZ0001ZZ trả về khớp với CPU mà nhiệm vụ cuối cùng sẽ được thực hiện.

Một tác dụng phụ của việc chọn CPU là đánh thức nó ở chế độ không hoạt động. Trong khi BPF
   bộ lập lịch có thể đánh thức bất kỳ CPU nào bằng trình trợ giúp ZZ0000ZZ,
   sử dụng ZZ0001ZZ một cách thận trọng có thể đơn giản và hiệu quả hơn.

Lưu ý rằng lõi bộ lập lịch sẽ bỏ qua lựa chọn CPU không hợp lệ, vì
   ví dụ: nếu nó nằm ngoài cpumask cho phép của tác vụ.

Một tác vụ có thể được chèn ngay vào DSQ từ ZZ0000ZZ
   bằng cách gọi ZZ0001ZZ hoặc ZZ0002ZZ.

Nếu tác vụ được chèn vào ZZ0000ZZ từ
   ZZ0001ZZ, nó sẽ được thêm vào DSQ cục bộ của bất kỳ CPU nào
   được trả về từ ZZ0002ZZ. Ngoài ra, chèn trực tiếp
   từ ZZ0003ZZ sẽ khiến cuộc gọi lại ZZ0004ZZ trở lại
   được bỏ qua.

Bất kỳ nỗ lực nào khác để lưu trữ một tác vụ trong cấu trúc dữ liệu nội bộ BPF từ
   ZZ0000ZZ không ngăn cản việc ZZ0001ZZ bị
   được gọi. Điều này không được khuyến khích vì nó có thể gây ra hành vi thiếu tôn trọng hoặc
   trạng thái không nhất quán.

2. Khi CPU đích được chọn, ZZ0000ZZ sẽ được gọi (trừ khi
   nhiệm vụ được chèn trực tiếp từ ZZ0001ZZ). ZZ0002ZZ
   có thể đưa ra một trong các quyết định sau:

* Ngay lập tức chèn tác vụ vào DSQ toàn cầu hoặc cục bộ bằng cách
     gọi ZZ0000ZZ bằng một trong các tùy chọn sau:
     ZZ0001ZZ, ZZ0002ZZ hoặc ZZ0003ZZ.

* Ngay lập tức chèn tác vụ vào DSQ tùy chỉnh bằng cách gọi
     ZZ0000ZZ có ID DSQ nhỏ hơn 2^63.

* Xếp hàng nhiệm vụ ở phía BPF.

ZZ0000ZZ

Một tác vụ nằm trong "sự giám sát của bộ lập lịch BPF" khi bộ lập lịch BPF được
   chịu trách nhiệm quản lý vòng đời của nó. Một nhiệm vụ sẽ được giám sát khi nó được
   được gửi đến người dùng DSQ hoặc được lưu trữ trong dữ liệu nội bộ của bộ lập lịch BPF
   các cấu trúc. Quyền giám hộ chỉ được nhập từ ZZ0000ZZ cho những người
   hoạt động. Ngoại lệ duy nhất là gửi tới người dùng DSQ từ
   ZZ0001ZZ: mặc dù nhiệm vụ chưa có về mặt kỹ thuật trong BPF
   quyền giám sát của người lập lịch trình tại thời điểm đó, công văn có cùng ngữ nghĩa
   có hiệu lực như việc gửi đi từ ZZ0002ZZ cho các vấn đề liên quan đến quyền giám hộ
   mục đích.

Khi ZZ0000ZZ được gọi, nhiệm vụ có thể được quản lý hoặc không
   tùy thuộc vào những gì người lập lịch thực hiện:

* ZZ0004ZZ (ZZ0000ZZ,
     ZZ0001ZZ hoặc ZZ0002ZZ): bộ lập lịch BPF
     đã hoàn thành nhiệm vụ - nó sẽ chuyển thẳng đến hoạt động cục bộ của CPU
     queue hoặc tới DSQ toàn cầu làm phương án dự phòng. Nhiệm vụ không bao giờ được đưa vào (hoặc
     thoát) quyền giám hộ BPF và ZZ0003ZZ sẽ không được gọi.

* ZZ0001ZZ (DSQ tùy chỉnh): tác vụ sẽ vào
     Quyền giám hộ của người lập lịch trình BPF. Khi nhiệm vụ sau đó rời khỏi quyền giám hộ BPF
     (được gửi đến thiết bị đầu cuối DSQ, được chọn theo lịch trình lõi hoặc được xếp hàng đợi cho
     thay đổi giấc ngủ/thuộc tính), ZZ0000ZZ sẽ được gọi chính xác
     một lần.

* ZZ0002ZZ (ví dụ: hàng đợi BPF nội bộ):
     nhiệm vụ đang được quản lý bởi BPF. ZZ0000ZZ sẽ được gọi khi nó
     rời đi (ví dụ: khi ZZ0001ZZ di chuyển nó đến thiết bị đầu cuối DSQ, hoặc
     về thay đổi thuộc tính/ngủ).

Khi một tác vụ rời khỏi quyền giám hộ của bộ lập lịch BPF, ZZ0000ZZ sẽ được gọi.
   Dequeue có thể xảy ra vì nhiều lý do khác nhau, được phân biệt bằng cờ:

1. ZZ0002ZZ: khi một nhiệm vụ được quản lý bởi BPF được gửi đến một
      thiết bị đầu cuối DSQ từ ZZ0000ZZ (để lại quyền giám hộ BPF cho
      thực thi), ZZ0001ZZ được kích hoạt mà không có bất kỳ cờ đặc biệt nào.

2. ZZ0003ZZ: khi ZZ0000ZZ được bật và
      lập lịch lõi chọn một tác vụ để thực thi trong khi nó vẫn ở BPF
      quyền giám hộ, ZZ0001ZZ được gọi với
      Cờ ZZ0002ZZ.

3. ZZ0005ZZ: khi thuộc tính tác vụ thay đổi (thông qua
      các hoạt động như ZZ0000ZZ, ZZ0001ZZ,
      thay đổi mức độ ưu tiên, di chuyển CPU, v.v.) trong khi tác vụ vẫn đang được thực hiện
      Quyền giám hộ BPF, ZZ0002ZZ được gọi với
      Cờ ZZ0003ZZ được đặt trong ZZ0004ZZ.

ZZ0001ZZ: Khi một nhiệm vụ đã rời khỏi quyền giám hộ của BPF (ví dụ: sau khi được
   được gửi đến thiết bị đầu cuối DSQ), các thay đổi thuộc tính sẽ không được kích hoạt
   ZZ0000ZZ, do tác vụ không còn được BPF quản lý nữa
   lịch trình.

3. Khi CPU sẵn sàng lên lịch, trước tiên nó sẽ xem DSQ cục bộ của nó. Nếu
   trống, sau đó nó sẽ nhìn vào DSQ toàn cầu. Nếu vẫn không có nhiệm vụ nào để
   run, ZZ0000ZZ được gọi có thể sử dụng hai lệnh sau
   có chức năng điền vào DSQ cục bộ.

* ZZ0000ZZ chèn một tác vụ vào DSQ. Bất kỳ mục tiêu DSQ nào cũng có thể
     đã qua sử dụng - ZZ0001ZZ, ZZ0002ZZ,
     ZZ0003ZZ hoặc DSQ tùy chỉnh. Trong khi ZZ0004ZZ
     hiện không thể gọi khi khóa BPF đang được giữ, việc này đang được xử lý
     và sẽ được hỗ trợ. Chèn lịch trình ZZ0005ZZ
     thay vì thực hiện chúng ngay lập tức. Có thể có tới
     ZZ0006ZZ nhiệm vụ đang chờ xử lý.

* ZZ0000ZZ di chuyển một tác vụ từ vùng không cục bộ được chỉ định
     DSQ tới DSQ điều động. Chức năng này không thể được gọi với bất kỳ BPF nào
     ổ khóa được giữ. ZZ0001ZZ xóa các phần chèn đang chờ xử lý
     nhiệm vụ trước khi cố gắng di chuyển khỏi DSQ được chỉ định.

4. Sau khi ZZ0000ZZ trả về, nếu có nhiệm vụ trong DSQ cục bộ,
   CPU chạy cái đầu tiên. Nếu trống, các bước sau sẽ được thực hiện:

* Cố gắng di chuyển từ DSQ toàn cầu. Nếu thành công, hãy chạy tác vụ.

* Nếu ZZ0000ZZ đã gửi bất kỳ nhiệm vụ nào, hãy thử lại #3.

* Nếu tác vụ trước đó là tác vụ SCX và vẫn có thể chạy được, hãy tiếp tục thực thi
     nó (xem ZZ0000ZZ).

* Đi nhàn rỗi.

Lưu ý rằng bộ lập lịch BPF luôn có thể chọn gửi nhiệm vụ ngay lập tức
trong ZZ0000ZZ như được minh họa trong ví dụ đơn giản ở trên. Nếu chỉ có
DSQ tích hợp được sử dụng, không cần triển khai ZZ0001ZZ như
một tác vụ không bao giờ được xếp hàng đợi trên bộ lập lịch BPF và cả cục bộ và toàn cục
DSQ được thực thi tự động.

ZZ0000ZZ chèn nhiệm vụ vào FIFO của DSQ mục tiêu. sử dụng
ZZ0001ZZ cho hàng đợi ưu tiên. DSQ nội bộ như
ZZ0002ZZ và ZZ0003ZZ không hỗ trợ hàng đợi ưu tiên
gửi đi và phải được gửi đến cùng với ZZ0004ZZ. Xem
tài liệu chức năng và cách sử dụng trong ZZ0005ZZ
để biết thêm thông tin.

Vòng đời nhiệm vụ
--------------

Mã giả sau đây trình bày tổng quan sơ bộ về toàn bộ vòng đời
của một tác vụ được quản lý bởi bộ lập lịch sched_ext:

.. code-block:: c

    ops.init_task();            /* A new task is created */
    ops.enable();               /* Enable BPF scheduling for the task */

    while (task in SCHED_EXT) {
        if (task can migrate)
            ops.select_cpu();   /* Called on wakeup (optimization) */

        ops.runnable();         /* Task becomes ready to run */

        while (task_is_runnable(task)) {
            if (task is not in a DSQ || task->scx.slice == 0) {
                ops.enqueue();  /* Task can be added to a DSQ */

                /* Task property change (i.e., affinity, nice, etc.)? */
                if (sched_change(task)) {
                    ops.dequeue(); /* Exiting BPF scheduler custody */
                    ops.quiescent();

                    /* Property change callback, e.g. ops.set_weight() */

                    ops.runnable();
                    continue;
                }

                /* Any usable CPU becomes available */

                ops.dispatch();     /* Task is moved to a local DSQ */
                ops.dequeue();      /* Exiting BPF scheduler custody */
            }

            ops.running();      /* Task starts running on its assigned CPU */

            while (task_is_runnable(task) && task->scx.slice > 0) {
                ops.tick();     /* Called every 1/HZ seconds */

                if (task->scx.slice == 0)
                    ops.dispatch(); /* task->scx.slice can be refilled */
            }

            ops.stopping();     /* Task stops running (time slice expires or wait) */
        }

        ops.quiescent();        /* Task releases its assigned CPU (wait) */
    }

    ops.disable();              /* Disable BPF scheduling for the task */
    ops.exit_task();            /* Task is destroyed */

Lưu ý rằng mã giả ở trên không bao gồm tất cả các chuyển đổi trạng thái có thể có
và các trường hợp đặc biệt, có thể kể tên một vài ví dụ:

* ZZ0000ZZ có thể không chuyển được nhiệm vụ sang DSQ cục bộ do đua xe
  thay đổi thuộc tính của tác vụ đó, trong trường hợp đó ZZ0001ZZ sẽ là
  đã thử lại.

* Nhiệm vụ có thể được gửi trực tiếp đến DSQ cục bộ từ ZZ0000ZZ,
  trong trường hợp đó ZZ0001ZZ và ZZ0002ZZ bị bỏ qua và chúng ta tiếp tục
  thẳng tới ZZ0003ZZ.

* Những thay đổi về thuộc tính có thể xảy ra ở hầu hết mọi thời điểm trong vòng đời của nhiệm vụ,
  không chỉ khi nhiệm vụ được xếp hàng và chờ được gửi đi. Ví dụ,
  thay đổi thuộc tính của tác vụ đang chạy sẽ dẫn đến chuỗi gọi lại
  ZZ0000ZZ -> ZZ0001ZZ -> (gọi lại thay đổi thuộc tính) ->
  ZZ0002ZZ -> ZZ0003ZZ.

* Một tác vụ sched_ext có thể được ưu tiên bởi một tác vụ có mức độ ưu tiên cao hơn
  lớp, trong trường hợp đó nó sẽ thoát khỏi vòng lặp đánh dấu công văn mặc dù nó có thể chạy được
  và có một lát cắt khác 0.

Xem phần "Chu kỳ lập kế hoạch" để biết mô tả chi tiết hơn về cách
một nhiệm vụ mới được đánh thức sẽ được thực hiện trên CPU.

Nơi để tìm
=============

* ZZ0000ZZ xác định cấu trúc dữ liệu cốt lõi, bảng ops
  và các hằng số.

* ZZ0000ZZ chứa các trình trợ giúp và triển khai lõi sched_ext.
  Các chức năng có tiền tố ZZ0001ZZ có thể được gọi từ BPF
  lịch trình.

* ZZ0000ZZ chứa chính sách lựa chọn CPU nhàn rỗi được tích hợp sẵn.

* Ví dụ về máy chủ ZZ0000ZZ triển khai bộ lập lịch BPF.

* ZZ0000ZZ: Ví dụ về bộ lập lịch FIFO toàn cầu tối thiểu sử dụng
    tùy chỉnh DSQ.

* ZZ0000ZZ: Bộ lập lịch FIFO đa cấp hỗ trợ năm
    mức độ ưu tiên được triển khai với ZZ0001ZZ.

* ZZ0000ZZ: Bộ lập lịch FIFO trung tâm nơi tất cả các lịch trình
    các quyết định được đưa ra trên một CPU, thể hiện việc gửi ZZ0001ZZ,
    hoạt động tích tắc và ưu tiên kthread.

* ZZ0000ZZ: Bộ lập lịch xếp hàng tất cả các tác vụ vào DSQ được chia sẻ
    và chỉ gửi chúng trên CPU0 theo thứ tự FIFO. Hữu ích cho việc thử nghiệm bỏ qua
    hành vi.

* ZZ0000ZZ: Bộ lập lịch phân cấp cgroup được làm phẳng
    triển khai điều khiển nhóm CPU dựa trên trọng số phân cấp bằng cách gộp
    mỗi nhóm chia sẻ ở mọi cấp độ thành một lớp lập kế hoạch phẳng duy nhất.

* ZZ0000ZZ: Một ví dụ về lập lịch cốt lõi luôn tạo ra
    Các cặp CPU anh chị em thực hiện các nhiệm vụ từ cùng một nhóm CPU.

* ZZ0000ZZ: Một biến thể của ZZ0001ZZ thể hiện BPF
    quản lý bộ nhớ đấu trường cho dữ liệu trên mỗi tác vụ.

* ZZ0000ZZ: Bộ lập lịch tối thiểu thể hiện không gian người dùng
    lập kế hoạch. Các nhiệm vụ có mối quan hệ CPU được gửi trực tiếp theo thứ tự FIFO;
    tất cả những thứ khác được lên lịch trong không gian người dùng bằng một bộ lập lịch vruntime đơn giản.

Thông số mô-đun
=================

sched_ext hiển thị hai tham số mô-đun dưới tiền tố ZZ0000ZZ
kiểm soát hành vi của chế độ bỏ qua. Những nút bấm này chủ yếu dùng để gỡ lỗi; ở đó
thường không có lý do gì để thay đổi chúng trong quá trình hoạt động bình thường. Chúng có thể được đọc
và được viết khi chạy (chế độ 0600) thông qua
ZZ0001ZZ.

ZZ0000ZZ (mặc định: 5000 µs)
    Phần thời gian được gán cho tất cả các tác vụ khi bộ lập lịch ở chế độ bỏ qua,
    tức là trong quá trình tải, dỡ tải và phục hồi lỗi của bộ lập lịch BPF. Phạm vi hợp lệ là
    100 µs đến 100 ms.

ZZ0000ZZ (mặc định: 500000 µs)
    Khoảng thời gian mà bộ cân bằng tải ở chế độ bỏ qua phân phối lại các tác vụ
    trên các CPU. Đặt thành 0 để tắt cân bằng tải trong chế độ bỏ qua. hợp lệ
    phạm vi là 0 đến 10 giây.

ABI không ổn định
===============

Các API được cung cấp bởi sched_ext cho các chương trình lập lịch BPF không có tính ổn định
sự đảm bảo. Điều này bao gồm các cuộc gọi lại và các hằng số trong bảng ops được xác định trong
ZZ0000ZZ, cũng như các kfuncs ZZ0001ZZ được xác định trong
ZZ0002ZZ và ZZ0003ZZ.

Mặc dù chúng tôi sẽ cố gắng cung cấp bề mặt API tương đối ổn định khi
có thể, chúng có thể thay đổi mà không có cảnh báo giữa kernel
các phiên bản.
