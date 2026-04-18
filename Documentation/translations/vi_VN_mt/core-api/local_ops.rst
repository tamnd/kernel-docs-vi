.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/local_ops.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.


.. _local_ops:

=====================================================
Ngữ nghĩa và hành vi của các hoạt động nguyên tử cục bộ
=================================================

:Tác giả: Mathieu Desnoyers


Tài liệu này giải thích mục đích của các hoạt động nguyên tử tại địa phương, làm thế nào
để triển khai chúng cho bất kỳ kiến trúc nhất định nào và chỉ ra cách sử dụng chúng
đúng cách. Nó cũng nhấn mạnh đến những biện pháp phòng ngừa phải được thực hiện khi đọc
các biến cục bộ đó trên các CPU khi thứ tự ghi bộ nhớ có vấn đề.

.. note::

    Note that ``local_t`` based operations are not recommended for general
    kernel use. Please use the ``this_cpu`` operations instead unless there is
    really a special purpose. Most uses of ``local_t`` in the kernel have been
    replaced by ``this_cpu`` operations. ``this_cpu`` operations combine the
    relocation with the ``local_t`` like semantics in a single instruction and
    yield more compact and faster executing code.


Mục đích của hoạt động nguyên tử địa phương
==================================

Các hoạt động nguyên tử cục bộ nhằm cung cấp tốc độ quay trở lại nhanh và cao trên mỗi CPU
quầy. Chúng giảm thiểu chi phí thực hiện của các hoạt động nguyên tử tiêu chuẩn bằng cách
loại bỏ tiền tố LOCK và các rào cản bộ nhớ thường được yêu cầu để đồng bộ hóa
trên các CPU.

Việc có bộ đếm nguyên tử nhanh trên mỗi CPU là điều thú vị trong nhiều trường hợp: nó không
yêu cầu vô hiệu hóa các ngắt để bảo vệ khỏi các trình xử lý ngắt và nó cho phép
bộ đếm mạch lạc trong bộ xử lý NMI. Nó đặc biệt hữu ích cho mục đích truy tìm
và cho các quầy giám sát hiệu suất khác nhau.

Các hoạt động nguyên tử cục bộ chỉ đảm bảo tính nguyên tử sửa đổi biến đổi
CPU sở hữu dữ liệu. Vì vậy, phải cẩn thận để đảm bảo rằng chỉ có một
CPU ghi vào dữ liệu ZZ0000ZZ. Điều này được thực hiện bằng cách sử dụng dữ liệu trên mỗi CPU và
đảm bảo rằng chúng tôi sửa đổi nó từ trong bối cảnh an toàn được ưu tiên trước. Đó là
tuy nhiên được phép đọc dữ liệu ZZ0001ZZ từ bất kỳ CPU nào: sau đó nó sẽ xuất hiện
được ghi không theo thứ tự, ghi vào bộ nhớ khác do chủ sở hữu CPU ghi.


Triển khai cho một kiến ​​trúc nhất định
=======================================

Nó có thể được thực hiện bằng cách sửa đổi một chút các hoạt động nguyên tử tiêu chuẩn: chỉ
biến thể UP của họ phải được giữ lại. Nó thường có nghĩa là loại bỏ tiền tố LOCK (trên
i386 và x86_64) và mọi rào cản đồng bộ hóa SMP. Nếu kiến trúc làm
không có hành vi khác giữa SMP và UP, bao gồm
ZZ0000ZZ trong ZZ0001ZZ của kiến trúc của bạn là đủ.

Loại ZZ0000ZZ được định nghĩa là ZZ0001ZZ mờ bằng cách nhúng một
ZZ0002ZZ bên trong một cấu trúc. Điều này được thực hiện để dàn diễn viên từ loại này đến
ZZ0003ZZ bị lỗi. Định nghĩa trông giống như::

typedef struct { nguyên tử_long_t a; } local_t;


Các quy tắc cần tuân theo khi sử dụng các phép toán nguyên tử cục bộ
==================================================

* Các biến được thao tác cục bộ chạm vào phải theo biến CPU.
* ZZ0002ZZ, chủ sở hữu CPU của các biến này phải viết thư cho họ.
* CPU này có thể sử dụng các hoạt động cục bộ từ bất kỳ ngữ cảnh nào (process, irq, softirq, nmi, ...)
  để cập nhật các biến ZZ0000ZZ của nó.
* Quyền ưu tiên (hoặc ngắt) phải bị vô hiệu hóa khi sử dụng các hoạt động cục bộ trong
  bối cảnh quy trình để đảm bảo quy trình sẽ không được di chuyển sang một
  CPU khác nhau giữa việc nhận biến trên mỗi CPU và thực hiện
  hoạt động thực tế tại địa phương.
* Khi sử dụng các hoạt động cục bộ trong bối cảnh bị gián đoạn, không cần phải thận trọng đặc biệt
  lấy trên nhân dòng chính, vì chúng sẽ chạy trên CPU cục bộ với
  quyền ưu tiên đã bị vô hiệu hóa. Tuy nhiên, tôi đề nghị một cách rõ ràng
  vẫn vô hiệu hóa quyền ưu tiên để đảm bảo nó vẫn hoạt động chính xác trên
  -rt hạt nhân.
* Đọc biến CPU cục bộ sẽ cung cấp bản sao hiện tại của
  biến.
* Việc đọc các biến này có thể được thực hiện từ bất kỳ CPU nào, vì các bản cập nhật lên
  "ZZ0001ZZ", được căn chỉnh, các biến luôn là nguyên tố. Vì không có trí nhớ
  việc đồng bộ hóa được thực hiện bởi người viết CPU, một bản sao lỗi thời của
  biến có thể được đọc khi đọc một số biến của CPU ZZ0003ZZ.


Cách sử dụng các phép toán nguyên tử cục bộ
==================================

::

#include <linux/percpu.h>
    #include <asm/local.h>

DEFINE_PER_CPU tĩnh(local_t, bộ đếm) = LOCAL_INIT(0);


Đếm
========

Việc đếm được thực hiện trên tất cả các bit của một ký tự dài.

Trong bối cảnh có thể ưu tiên, hãy sử dụng ZZ0000ZZ và ZZ0001ZZ xung quanh
các hoạt động nguyên tử cục bộ: nó đảm bảo rằng quyền ưu tiên bị vô hiệu hóa khi ghi
truy cập vào biến mỗi cpu. Ví dụ::

local_inc(&get_cpu_var(bộ đếm));
    put_cpu_var(bộ đếm);

Nếu bạn đã ở trong bối cảnh an toàn trước quyền ưu tiên, bạn có thể sử dụng
ZZ0000ZZ thay vào đó::

local_inc(this_cpu_ptr(&counters));



Đọc bộ đếm
====================

Những bộ đếm cục bộ đó có thể được đọc từ các CPU nước ngoài để tính tổng. Lưu ý rằng
dữ liệu mà local_read nhìn thấy trên các CPU phải được coi là không đúng thứ tự
tương đối với việc ghi vào bộ nhớ khác xảy ra trên CPU sở hữu dữ liệu ::

tổng dài = 0;
    for_each_online_cpu(cpu)
            sum += local_read(&per_cpu(bộ đếm, cpu));

Nếu bạn muốn sử dụng local_read từ xa để đồng bộ hóa quyền truy cập vào tài nguyên
giữa các CPU, phải sử dụng các rào cản bộ nhớ ZZ0000ZZ và ZZ0001ZZ rõ ràng
tương ứng trên CPU ghi và CPU đọc. Sẽ là như vậy nếu bạn sử dụng
biến ZZ0002ZZ làm bộ đếm byte được ghi trong bộ đệm: cần có
là ZZ0003ZZ giữa ghi bộ đệm và tăng bộ đếm và cũng là một
ZZ0004ZZ giữa bộ đếm đọc và bộ đệm đọc.


Đây là một mô-đun mẫu triển khai bộ đếm cơ bản trên mỗi CPU bằng cách sử dụng
ZZ0000ZZ::

/* test-local.c
     *
     * Mô-đun mẫu để sử dụng local.h.
     */


#include <asm/local.h>
    #include <linux/module.h>
    #include <linux/timer.h>

DEFINE_PER_CPU tĩnh(local_t, bộ đếm) = LOCAL_INIT(0);

cấu trúc tĩnh time_list test_timer;

/* IPI được gọi trên mỗi CPU. */
    tĩnh void test_each(void *info)
    {
            /* Tăng bộ đếm từ ngữ cảnh không được ưu tiên */
            printk("Tăng CPU %d\n", smp_processor_id());
            local_inc(this_cpu_ptr(&counters));

/* Đây là cách tăng biến trong một
             * bối cảnh có thể ưu tiên (nó vô hiệu hóa quyền ưu tiên):
             *
             * local_inc(&get_cpu_var(bộ đếm));
             * put_cpu_var(bộ đếm);
             */
    }

static void do_test_timer(dữ liệu dài chưa được ký)
    {
            intcpu;

/* Tăng bộ đếm */
            on_each_cpu(test_each, NULL, 1);
            /* Đọc tất cả các bộ đếm */
            printk("Bộ đếm được đọc từ CPU %d\n", smp_processor_id());
            for_each_online_cpu(cpu) {
                    printk("Đọc: CPU %d, đếm %ld\n", cpu,
                            local_read(&per_cpu(bộ đếm, cpu)));
            }
            mod_timer(&test_timer, jiffies + 1000);
    }

int tĩnh __init test_init(void)
    {
            /* khởi tạo bộ đếm thời gian sẽ tăng bộ đếm */
            time_setup(&test_timer, do_test_timer, 0);
            mod_timer(&test_timer, jiffies + 1);

trả về 0;
    }

khoảng trống tĩnh __exit test_exit(void)
    {
            hẹn giờ_shutdown_sync(&test_timer);
    }

module_init(test_init);
    module_exit(test_exit);

MODULE_LICENSE("GPL");
    MODULE_AUTHOR("Mathieu Desnoyers");
    MODULE_DESCRIPTION("Hoạt động nguyên tử cục bộ");
