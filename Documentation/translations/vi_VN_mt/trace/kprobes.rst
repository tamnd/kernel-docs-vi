.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/kprobes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Đầu dò hạt nhân (Kprobes)
=======================

:Tác giả: Jim Keniston <jkenisto@us.ibm.com>
:Tác giả: Prasanna S Panchamukhi <prasanna.panchamukhi@gmail.com>
:Tác giả: Masami Hiramatsu <mhiramat@kernel.org>

.. CONTENTS

  1. Concepts: Kprobes, and Return Probes
  2. Architectures Supported
  3. Configuring Kprobes
  4. API Reference
  5. Kprobes Features and Limitations
  6. Probe Overhead
  7. TODO
  8. Kprobes Example
  9. Kretprobes Example
  10. Deprecated Features
  Appendix A: The kprobes debugfs interface
  Appendix B: The kprobes sysctl interface
  Appendix C: References

Các khái niệm: Kprobes và Return Probes
=========================================

Kprobes cho phép bạn tự động đột nhập vào bất kỳ quy trình kernel nào và
thu thập thông tin gỡ lỗi và hiệu suất một cách không gián đoạn. bạn
có thể bẫy ở hầu hết mọi địa chỉ mã hạt nhân [1]_, chỉ định trình xử lý
thường trình được gọi khi điểm dừng được nhấn.

.. [1] some parts of the kernel code can not be trapped, see
       :ref:`kprobes_blacklist`)

Hiện tại có hai loại đầu dò: kprobes và kretprobes
(còn gọi là đầu dò quay trở lại).  Một kprobe có thể được chèn vào hầu như
bất kỳ lệnh nào trong kernel.  Đầu dò quay trở lại kích hoạt khi được chỉ định
hàm trả về.

Trong trường hợp điển hình, thiết bị dựa trên Kprobes được đóng gói dưới dạng
một mô-đun hạt nhân.  Chức năng init của mô-đun cài đặt ("đăng ký")
một hoặc nhiều đầu dò và chức năng thoát sẽ hủy đăng ký chúng.  A
chức năng đăng ký như register_kprobe() chỉ định vị trí
đầu dò sẽ được chèn vào và trình xử lý nào sẽ được gọi khi
đầu dò bị va đập.

Ngoài ra còn có các chức năng ZZ0000ZZ cho hàng loạt
đăng ký/hủy đăng ký một nhóm ZZ0001ZZ. Những chức năng này
có thể tăng tốc quá trình hủy đăng ký khi bạn phải hủy đăng ký
nhiều đầu dò cùng một lúc.

Bốn tiểu mục tiếp theo giải thích các loại khác nhau của
đầu dò hoạt động và cách tối ưu hóa bước nhảy hoạt động.  Họ giải thích một số
những điều cần biết để sử dụng hiệu quả nhất
Kprobes -- ví dụ: sự khác biệt giữa pre_handler và
post_handler và cách sử dụng các trường maxactive và nmissed của
một chiếc kretprobe.  Nhưng nếu bạn đang vội bắt đầu sử dụng Kprobes, bạn
có thể bỏ qua tới ZZ0000ZZ.

Kprobe hoạt động như thế nào?
-----------------------

Khi một kprobe được đăng ký, Kprobes sẽ tạo một bản sao của
lệnh và thay thế (các) byte đầu tiên của lệnh được thăm dò
với lệnh điểm dừng (ví dụ: int3 trên i386 và x86_64).

Khi CPU chạm vào lệnh điểm dừng, một bẫy sẽ xảy ra, CPU
các thanh ghi được lưu lại và điều khiển được chuyển đến Kprobes thông qua
cơ chế notifier_call_chain.  Kprobes thực thi "pre_handler"
được liên kết với kprobe, chuyển cho trình xử lý địa chỉ của
cấu trúc kprobe và các thanh ghi đã lưu.

Tiếp theo, Kprobes thực hiện từng bước sao chép lệnh được thăm dò.
(Sẽ đơn giản hơn nếu thực hiện từng bước hướng dẫn thực tế tại chỗ,
nhưng sau đó Kprobes sẽ phải tạm thời loại bỏ breakpoint
hướng dẫn.  Điều này sẽ mở ra một cửa sổ thời gian nhỏ khi một CPU khác
có thể đi thẳng qua điểm thăm dò.)

Sau khi lệnh được thực hiện một bước, Kprobes sẽ thực hiện
"post_handler," nếu có, được liên kết với kprobe.
Việc thực thi sau đó tiếp tục với lệnh theo điểm thăm dò.

Thay đổi đường dẫn thực thi
-----------------------

Vì kprobe có thể thăm dò mã kernel đang chạy nên nó có thể thay đổi
tập thanh ghi, bao gồm cả con trỏ lệnh. Hoạt động này đòi hỏi
chăm sóc tối đa, chẳng hạn như giữ khung ngăn xếp, khôi phục quá trình thực thi
path, v.v. Vì nó hoạt động trên kernel đang chạy và cần kiến thức sâu
của kiến trúc máy tính và điện toán đồng thời, bạn có thể dễ dàng chụp
bàn chân của bạn.

Nếu bạn thay đổi con trỏ lệnh (và thiết lập các
registers) trong pre_handler, bạn phải quay lại !0 để kprobe dừng lại
bước duy nhất và chỉ quay trở lại địa chỉ đã cho.
Điều này cũng có nghĩa là post_handler không nên được gọi nữa.

Lưu ý rằng thao tác này có thể khó hơn trên một số kiến trúc sử dụng
TOC (Mục lục) cho lệnh gọi hàm, vì bạn phải thiết lập một địa chỉ mới
TOC cho chức năng của bạn trong mô-đun và khôi phục chức năng cũ sau đó
trở về từ nó.

Trả lại đầu dò
-------------

Đầu dò quay trở lại hoạt động như thế nào?
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khi bạn gọi register_kretprobe(), Kprobes sẽ thiết lập kprobe tại
đầu vào của hàm.  Khi hàm thăm dò được gọi và điều này
đầu dò bị tấn công, Kprobes lưu một bản sao của địa chỉ trả về và thay thế
địa chỉ trả lại với địa chỉ của một "tấm bạt lò xo".  tấm bạt lò xo
là một đoạn mã tùy ý -- thường chỉ là một lệnh nop.
Khi khởi động, Kprobes đăng ký kprobe tại tấm bạt lò xo.

Khi hàm được thăm dò thực hiện lệnh trả về của nó, điều khiển
đi tới tấm bạt lò xo và đầu dò đó bị bắn trúng.  Tấm bạt lò xo của Kprobes
trình xử lý gọi trình xử lý trả về do người dùng chỉ định được liên kết với
kretprobe, sau đó đặt con trỏ lệnh đã lưu thành kết quả trả về đã lưu
địa chỉ và đó là nơi quá trình thực thi tiếp tục khi trở về từ bẫy.

Trong khi hàm được thăm dò đang thực thi, địa chỉ trả về của nó là
được lưu trữ trong một đối tượng thuộc loại kretprobe_instance.  Trước khi gọi
register_kretprobe(), người dùng đặt trường hoạt động tối đa của
cấu trúc kretprobe để chỉ định số lượng phiên bản của đối tượng được chỉ định
chức năng có thể được thăm dò đồng thời.  register_kretprobe()
phân bổ trước số lượng đối tượng kretprobe_instance được chỉ định.

Ví dụ: nếu hàm không đệ quy và được gọi với
spinlock được giữ, maxactive = 1 là đủ.  Nếu chức năng là
không đệ quy và không bao giờ có thể từ bỏ CPU (ví dụ: thông qua một semaphore
hoặc quyền ưu tiên), NR_CPUS là đủ.  Nếu hoạt động tối đa <= 0 thì đó là
được đặt thành giá trị mặc định: max(10, 2*NR_CPUS).

Sẽ không phải là thảm họa nếu bạn đặt mức kích hoạt tối đa quá thấp; bạn sẽ bỏ lỡ
một số đầu dò.  Trong cấu trúc kretprobe, trường nmissed được đặt thành
bằng 0 khi đầu dò quay lại được đăng ký và được tăng lên sau mỗi lần
thời điểm hàm thăm dò được nhập nhưng không có kretprobe_instance
đối tượng có sẵn để thiết lập thăm dò trở lại.

Trình xử lý mục nhập Kretprobe
^^^^^^^^^^^^^^^^^^^^^^^

Kretprobes cũng cung cấp một trình xử lý tùy chọn do người dùng chỉ định để chạy
về mục nhập chức năng. Trình xử lý này được chỉ định bằng cách đặt entry_handler
trường của cấu trúc kretprobe. Bất cứ khi nào kretprobe được đặt bởi kretprobe ở
mục nhập hàm được nhấn, entry_handler do người dùng xác định, nếu có, sẽ được gọi.
Nếu entry_handler trả về 0 (thành công) thì trình xử lý trả về tương ứng
được đảm bảo được gọi khi hàm trả về. Nếu entry_handler
trả về một lỗi khác 0 thì Kprobes giữ nguyên địa chỉ trả về và
kretprobe không có tác dụng gì thêm đối với phiên bản hàm cụ thể đó.

Nhiều lời gọi xử lý mục nhập và trả về được khớp bằng cách sử dụng
đối tượng kretprobe_instance được liên kết với chúng. Ngoài ra, một người dùng
cũng có thể chỉ định dữ liệu riêng tư trên mỗi phiên bản trả về là một phần của mỗi
đối tượng kretprobe_instance. Điều này đặc biệt hữu ích khi chia sẻ riêng tư
dữ liệu giữa các trình xử lý mục nhập và trả về của người dùng tương ứng. Kích thước của mỗi
đối tượng dữ liệu riêng tư có thể được chỉ định tại thời điểm đăng ký kretprobe bởi
thiết lập trường data_size của cấu trúc kretprobe. Dữ liệu này có thể được
được truy cập thông qua trường dữ liệu của từng đối tượng kretprobe_instance.

Trong trường hợp chức năng thăm dò được nhập nhưng không có kretprobe_instance
đối tượng có sẵn, thì ngoài việc tăng số lượng đã bỏ qua,
lệnh gọi entry_handler của người dùng cũng bị bỏ qua.

.. _kprobes_jump_optimization:

Tối ưu hóa bước nhảy hoạt động như thế nào?
--------------------------------

Nếu kernel của bạn được xây dựng với CONFIG_OPTPROBES=y (hiện tại cờ này
được tự động đặt 'y' trên x86/x86-64, kernel không được ưu tiên) và
tham số kernel "debug.kprobes_optimization" được đặt thành 1 (xem
sysctl(8)), Kprobes cố gắng giảm chi phí đầu dò bằng cách sử dụng bước nhảy
lệnh thay vì lệnh điểm dừng tại mỗi điểm thăm dò.

Bắt đầu một Kprobe
^^^^^^^^^^^^^

Khi một thăm dò được đăng ký, trước khi thử tối ưu hóa này,
Kprobes chèn một kprobe thông thường, dựa trên điểm dừng tại điểm được chỉ định
địa chỉ. Vì vậy, ngay cả khi không thể tối ưu hóa điều này
thăm dò, sẽ có một thăm dò ở đó.

Kiểm tra an toàn
^^^^^^^^^^^^

Trước khi tối ưu hóa đầu dò, Kprobes thực hiện các bước kiểm tra an toàn sau:

- Kprobes xác minh rằng vùng sẽ được thay thế bằng bước nhảy
  lệnh ("vùng được tối ưu hóa") nằm hoàn toàn trong một chức năng.
  (Một lệnh nhảy có nhiều byte và do đó có thể chồng lên nhiều byte
  hướng dẫn.)

- Kprobes phân tích toàn bộ chức năng và xác minh rằng không có
  nhảy vào vùng tối ưu hóa.  Cụ thể:

- chức năng không có bước nhảy gián tiếp;
  - hàm không chứa lệnh gây ra ngoại lệ (vì
    mã sửa lỗi được kích hoạt bởi ngoại lệ có thể quay trở lại
    vùng được tối ưu hóa -- Kprobes kiểm tra các bảng ngoại lệ để xác minh điều này);
  - không có bước nhảy gần đến vùng được tối ưu hóa (trừ vùng đầu tiên
    byte).

- Đối với mỗi lệnh trong vùng được tối ưu hóa, Kprobes xác minh rằng
  lệnh có thể được thực hiện ngoài dòng.

Đang chuẩn bị đệm đường vòng
^^^^^^^^^^^^^^^^^^^^^^^

Tiếp theo, Kprobes chuẩn bị một bộ đệm "đi vòng", chứa các thông tin sau:
trình tự hướng dẫn:

- mã để đẩy các thanh ghi của CPU (mô phỏng bẫy điểm dừng)
- lệnh gọi đến mã tấm bạt lò xo gọi bộ xử lý đầu dò của người dùng.
- mã để khôi phục sổ đăng ký
- hướng dẫn từ vùng được tối ưu hóa
- quay trở lại đường dẫn thực hiện ban đầu.

Tối ưu hóa trước
^^^^^^^^^^^^^^^^

Sau khi chuẩn bị bộ đệm đường vòng, Kprobes xác minh rằng không có
tồn tại các tình huống sau:

- Đầu dò có post_handler.
- Các lệnh khác trong vùng được tối ưu hóa được thăm dò.
- Đầu dò bị vô hiệu hóa.

Trong bất kỳ trường hợp nào ở trên, Kprobes sẽ không bắt đầu tối ưu hóa đầu dò.
Vì đây chỉ là tình huống tạm thời nên Kprobes cố gắng bắt đầu
tối ưu hóa nó một lần nữa nếu tình hình được thay đổi.

Nếu kprobe có thể được tối ưu hóa, Kprobe sẽ xếp kprobe vào hàng đợi
danh sách tối ưu hóa và khởi động chuỗi công việc của trình tối ưu hóa kprobe để tối ưu hóa
nó.  Nếu điểm thăm dò cần tối ưu hóa bị tấn công trước khi được tối ưu hóa,
Kprobes trả điều khiển về đường dẫn lệnh ban đầu bằng cách thiết lập
con trỏ lệnh của CPU tới mã được sao chép trong bộ đệm đường vòng
- do đó ít nhất là tránh được một bước.

Tối ưu hóa
^^^^^^^^^^^^

Trình tối ưu hóa Kprobe không chèn lệnh nhảy ngay lập tức;
đúng hơn, nó gọi sync_rcu() để đảm bảo an toàn trước tiên, bởi vì nó
CPU có thể bị gián đoạn khi đang thực hiện
vùng được tối ưu hóa [3]_.  Như bạn đã biết, sync_rcu() có thể đảm bảo
rằng tất cả các gián đoạn đang hoạt động khi sync_rcu()
được gọi là xong, nhưng chỉ khi CONFIG_PREEMPT=n.  Vì vậy, phiên bản này
tối ưu hóa kprobe chỉ hỗ trợ các hạt nhân có CONFIG_PREEMPT=n [4]_.

Sau đó, trình tối ưu hóa Kprobe gọi stop_machine() để thay thế
vùng được tối ưu hóa với lệnh nhảy tới bộ đệm đường vòng,
sử dụng text_poke_smp().

Không tối ưu hóa
^^^^^^^^^^^^^^

Khi một kprobe được tối ưu hóa không được đăng ký, bị vô hiệu hóa hoặc bị chặn bởi
một kprobe khác, nó sẽ không được tối ưu hóa.  Nếu điều này xảy ra trước
quá trình tối ưu hóa đã hoàn tất, kprobe vừa được loại bỏ khỏi hàng đợi
danh sách tối ưu.  Nếu việc tối ưu hóa đã được thực hiện, bước nhảy là
được thay thế bằng mã gốc (ngoại trừ điểm dừng int3 trong
byte đầu tiên) bằng cách sử dụng text_poke_smp().

.. [3] Please imagine that the 2nd instruction is interrupted and then
   the optimizer replaces the 2nd instruction with the jump *address*
   while the interrupt handler is running. When the interrupt
   returns to original address, there is no valid instruction,
   and it causes an unexpected result.

.. [4] This optimization-safety checking may be replaced with the
   stop-machine method that ksplice uses for supporting a CONFIG_PREEMPT=y
   kernel.

NOTE dành cho người đam mê công nghệ:
Tối ưu hóa bước nhảy thay đổi hành vi pre_handler của kprobe.
Nếu không được tối ưu hóa, pre_handler có thể thay đổi cách thực thi của kernel
đường dẫn bằng cách thay đổi regs->ip và trả về 1. Tuy nhiên, khi đầu dò
được tối ưu hóa, sửa đổi đó sẽ bị bỏ qua.  Vì vậy, nếu bạn muốn
điều chỉnh đường dẫn thực thi của kernel, bạn cần ngăn chặn tối ưu hóa,
sử dụng một trong các kỹ thuật sau:

- Chỉ định một hàm trống cho post_handler của kprobe.

hoặc

- Thực thi 'sysctl -w debug.kprobes_optimization=n'

.. _kprobes_blacklist:

Danh sách đen
---------

Kprobes có thể thăm dò hầu hết kernel ngoại trừ chính nó. Điều này có nghĩa
rằng có một số chức năng mà kprobe không thể thăm dò. thăm dò
(bẫy) các hàm như vậy có thể gây ra bẫy đệ quy (ví dụ: gấp đôi
error) hoặc trình xử lý thăm dò lồng nhau có thể không bao giờ được gọi.
Kprobes quản lý các chức năng như danh sách đen.
Nếu bạn muốn thêm một chức năng vào danh sách đen, bạn chỉ cần
(1) bao gồm linux/kprobes.h và (2) sử dụng macro NOKPROBE_SYMBOL()
để chỉ định một chức năng được liệt kê trong danh sách đen.
Kprobes kiểm tra địa chỉ thăm dò đã cho theo danh sách đen và
từ chối đăng ký nếu địa chỉ đã cho nằm trong danh sách đen.

.. _kprobes_archs_supported:

Kiến trúc được hỗ trợ
=======================

Kprobes và thăm dò trở lại được thực hiện như sau
kiến trúc:

- i386 (Hỗ trợ tối ưu hóa bước nhảy)
- x86_64 (AMD-64, EM64T) (Hỗ trợ tối ưu hóa bước nhảy)
- ppc64
- sparc64 (Trả lại thăm dò chưa được triển khai.)
- cánh tay
- PPC
- mips
- s390
- parisc
- loongarch
- riscv

Cấu hình Kprobe
===================

Khi định cấu hình kernel bằng make menuconfig/xconfig/oldconfig,
đảm bảo rằng CONFIG_KPROBES được đặt thành "y", hãy tìm "Kprobes" bên dưới
"Các tùy chọn phụ thuộc vào kiến trúc chung".

Để bạn có thể tải và dỡ bỏ các mô-đun thiết bị dựa trên Kprobes,
đảm bảo "Hỗ trợ mô-đun có thể tải" (CONFIG_MODULES) và "Mô-đun
dỡ tải" (CONFIG_MODULE_UNLOAD) được đặt thành "y".

Đồng thời đảm bảo rằng CONFIG_KALLSYMS và thậm chí có thể là CONFIG_KALLSYMS_ALL
được đặt thành "y", vì kallsyms_lookup_name() được sử dụng bởi kernel trong
mã phân giải địa chỉ kprobe.

Nếu bạn cần chèn đầu dò vào giữa hàm, bạn có thể tìm thấy
thật hữu ích khi "Biên dịch hạt nhân với thông tin gỡ lỗi" (CONFIG_DEBUG_INFO),
vì vậy bạn có thể sử dụng "objdump -d -l vmlinux" để xem nguồn-đối tượng
ánh xạ mã.

Tham khảo API
=============

Kprobes API bao gồm chức năng "đăng ký" và "hủy đăng ký"
chức năng cho từng loại đầu dò. API cũng bao gồm "đầu dò register_*"
và các hàm "unregister_*probes" để (hủy) đăng ký mảng thăm dò.
Dưới đây là các thông số kỹ thuật ngắn gọn, trong trang man cho các chức năng này và
các trình xử lý thăm dò liên quan mà bạn sẽ viết. Xem các tập tin trong
samples/kprobes/ thư mục con để biết ví dụ.

đăng ký_kprobe
---------------

::

#include <linux/kprobes.h>
	int register_kprobe(struct kprobe *kp);

Đặt điểm ngắt tại địa chỉ kp->addr.  Khi điểm ngắt được chạm tới, Kprobes
gọi kp->pre_handler.  Sau khi lệnh được thăm dò là một bước, Kprobe
gọi kp->post_handler.  Bất kỳ hoặc tất cả các trình xử lý đều có thể là NULL. Nếu kp->flags được đặt
KPROBE_FLAG_DISABLED, kp đó sẽ được đăng ký nhưng bị vô hiệu hóa, do đó, trình xử lý của nó
không được nhấn cho đến khi gọi Enable_kprobe(kp).

.. note::

   1. With the introduction of the "symbol_name" field to struct kprobe,
      the probepoint address resolution will now be taken care of by the kernel.
      The following will now work::

	kp.symbol_name = "symbol_name";

      (64-bit powerpc intricacies such as function descriptors are handled
      transparently)

   2. Use the "offset" field of struct kprobe if the offset into the symbol
      to install a probepoint is known. This field is used to calculate the
      probepoint.

   3. Specify either the kprobe "symbol_name" OR the "addr". If both are
      specified, kprobe registration will fail with -EINVAL.

   4. With CISC architectures (such as i386 and x86_64), the kprobes code
      does not validate if the kprobe.addr is at an instruction boundary.
      Use "offset" with caution.

register_kprobe() trả về 0 nếu thành công hoặc nếu không thì trả về lỗi âm.

Trình xử lý trước của người dùng (kp->pre_handler)::

#include <linux/kprobes.h>
	#include <linux/ptrace.h>
	int pre_handler(struct kprobe *p, struct pt_regs *regs);

Được gọi với p trỏ đến kprobe được liên kết với điểm dừng,
và reg trỏ đến cấu trúc chứa các thanh ghi được lưu khi
điểm dừng đã được nhấn.  Trả về 0 tại đây trừ khi bạn là người đam mê Kprobes.

Trình xử lý bài của người dùng (kp->post_handler)::

#include <linux/kprobes.h>
	#include <linux/ptrace.h>
	void post_handler(struct kprobe *p, struct pt_regs *regs,
			  cờ dài không dấu);

p và reg giống như mô tả cho pre_handler.  cờ dường như luôn luôn
bằng không.

đăng ký_kretprobe
------------------

::

#include <linux/kprobes.h>
	int register_kretprobe(struct kretprobe *rp);

Thiết lập một thăm dò trả về cho hàm có địa chỉ là
rp->kp.addr.  Khi hàm đó trả về, Kprobes gọi rp->handler.
Bạn phải đặt rp->maxactive một cách thích hợp trước khi gọi
register_kretprobe(); xem "Đầu dò quay trở lại hoạt động như thế nào?" để biết chi tiết.

register_kretprobe() trả về 0 nếu thành công hoặc có lỗi âm
mặt khác.

Trình xử lý thăm dò trả về của người dùng (rp->handler)::

#include <linux/kprobes.h>
	#include <linux/ptrace.h>
	int kretprobe_handler(struct kretprobe_instance *ri,
			      cấu trúc pt_regs *reg);

regs giống như mô tả cho kprobe.pre_handler.  ri chỉ vào
đối tượng kretprobe_instance, trong đó các trường sau có thể là
quan tâm:

- ret_addr: địa chỉ trả về
- rp: trỏ tới đối tượng kretprobe tương ứng
- task: trỏ tới cấu trúc task tương ứng
- dữ liệu: trỏ đến dữ liệu riêng tư trên mỗi phiên bản trả về; xem "Kretprobe
	trình xử lý mục nhập" để biết chi tiết.

Macro regs_return_value(regs) cung cấp một sự trừu tượng hóa đơn giản cho
trích xuất giá trị trả về từ thanh ghi thích hợp như được xác định bởi
ABI của kiến trúc.

Giá trị trả về của trình xử lý hiện bị bỏ qua.

hủy đăng ký_*thăm dò
------------------

::

#include <linux/kprobes.h>
	void unregister_kprobe(struct kprobe *kp);
	void unregister_kretprobe(struct kretprobe *rp);

Loại bỏ đầu dò được chỉ định.  Chức năng hủy đăng ký có thể được gọi
bất cứ lúc nào sau khi cuộc thăm dò đã được đăng ký.

.. note::

   If the functions find an incorrect probe (ex. an unregistered probe),
   they clear the addr field of the probe.

thăm dò register_*
----------------

::

#include <linux/kprobes.h>
	int register_kprobes(struct kprobe **kps, int num);
	int register_kretprobes(struct kretprobe **rps, int num);

Đăng ký từng đầu dò số trong mảng được chỉ định.  Nếu có
xảy ra lỗi trong quá trình đăng ký, tất cả các đầu dò trong mảng, tối đa
đầu dò xấu, được hủy đăng ký một cách an toàn trước đầu dò register_*
hàm trả về.

- kps/rps: một mảng các con trỏ tới cấu trúc dữ liệu ZZ0000ZZ
- num: số phần tử của mảng.

.. note::

   You have to allocate(or define) an array of pointers and set all
   of the array entries before using these functions.

hủy đăng ký_* thăm dò
------------------

::

#include <linux/kprobes.h>
	void unregister_kprobes(struct kprobe **kps, int num);
	void unregister_kretprobes(struct kretprobe **rps, int num);

Loại bỏ từng đầu dò num trong mảng đã chỉ định cùng một lúc.

.. note::

   If the functions find some incorrect probes (ex. unregistered
   probes) in the specified array, they clear the addr field of those
   incorrect probes. However, other probes in the array are
   unregistered correctly.

vô hiệu hóa_* thăm dò
--------------

::

#include <linux/kprobes.h>
	int vô hiệu hóa_kprobe(struct kprobe *kp);
	int vô hiệu hóa_kretprobe(struct kretprobe *rp);

Tạm thời vô hiệu hóa ZZ0000ZZ được chỉ định. Bạn có thể kích hoạt lại nó bằng cách sử dụng
Enable_*probe(). Bạn phải chỉ định đầu dò đã được đăng ký.

kích hoạt_*thăm dò
-------------

::

#include <linux/kprobes.h>
	int Enable_kprobe(struct kprobe *kp);
	int Enable_kretprobe(struct kretprobe *rp);

Kích hoạt ZZ0000ZZ đã bị vô hiệu hóa bởi lệnh vô hiệu_*probe(). Bạn phải chỉ định
thăm dò đã được đăng ký.

Các tính năng và hạn chế của Kprobes
================================

Kprobes cho phép nhiều đầu dò ở cùng một địa chỉ. Ngoài ra,
không thể tối ưu hóa điểm thăm dò có post_handler.
Vì vậy, nếu bạn cài đặt kprobe với post_handler, ở mức tối ưu hóa
điểm thăm dò, điểm thăm dò sẽ tự động không được tối ưu hóa.

Nói chung, bạn có thể cài đặt đầu dò ở bất kỳ đâu trong kernel.
Đặc biệt, bạn có thể thăm dò các trình xử lý ngắt.  Các trường hợp ngoại lệ đã biết
được thảo luận trong phần này.

Các hàm thăm dò register_* sẽ trả về -EINVAL nếu bạn thử
để cài đặt một đầu dò trong mã triển khai Kprobes (chủ yếu là
kernel/kprobes.c và ZZ0000ZZ, nhưng cũng có chức năng như vậy
như do_page_fault và notifier_call_chain).

Nếu bạn cài đặt một đầu dò trong một chức năng có khả năng nội tuyến, Kprobes sẽ thực hiện
không cố gắng truy đuổi tất cả các phiên bản nội tuyến của hàm và
cài đặt đầu dò ở đó.  gcc có thể nội tuyến một hàm mà không cần được hỏi,
vì vậy hãy ghi nhớ điều này nếu bạn không nhìn thấy kết quả thăm dò như mong đợi.

Trình xử lý thăm dò có thể sửa đổi môi trường của hàm được thăm dò
-- ví dụ: bằng cách sửa đổi cấu trúc dữ liệu hạt nhân hoặc bằng cách sửa đổi
nội dung của cấu trúc pt_regs (được khôi phục vào sổ đăng ký
khi trở về từ điểm dừng).  Vì vậy, Kprobes có thể được sử dụng, ví dụ:
để cài đặt bản sửa lỗi hoặc đưa các lỗi vào để kiểm tra.  Kprobes, của
Tất nhiên, không có cách nào để phân biệt các lỗi cố tình tiêm vào
từ những điều vô tình.  Đừng uống rượu và thăm dò.

Kprobes không cố gắng ngăn cản người xử lý đầu dò giẫm lên
lẫn nhau -- ví dụ: thăm dò printk() và sau đó gọi printk() từ một
người xử lý đầu dò.  Nếu bộ xử lý đầu dò chạm vào đầu dò, thì đầu dò thứ hai đó
trình xử lý sẽ không được chạy trong trường hợp đó và thành viên kprobe.nmissed
của đầu dò thứ hai sẽ được tăng lên.

Kể từ Linux v2.6.15-rc1, nhiều trình xử lý (hoặc nhiều phiên bản của
cùng một trình xử lý) có thể chạy đồng thời trên các CPU khác nhau.

Kprobes không sử dụng mutexes hoặc phân bổ bộ nhớ ngoại trừ trong thời gian
đăng ký và hủy đăng ký.

Trình xử lý thăm dò được chạy với tính năng ưu tiên bị vô hiệu hóa hoặc bị vô hiệu hóa ngắt,
điều này phụ thuộc vào kiến trúc và trạng thái tối ưu hóa.  (ví dụ:
trình xử lý kretprobe và trình xử lý kprobe được tối ưu hóa chạy mà không bị gián đoạn
bị vô hiệu hóa trên x86/x86-64).  Trong mọi trường hợp, người xử lý của bạn không được nhường bước
CPU (ví dụ: bằng cách cố gắng thu được một đèn hiệu hoặc chờ I/O).

Vì thăm dò trả lại được thực hiện bằng cách thay thế trả lại
địa chỉ với địa chỉ của tấm bạt lò xo, ngăn xếp các dấu vết ngược và các cuộc gọi
đến __buildin_return_address() thường sẽ mang lại tấm bạt lò xo
address thay vì địa chỉ trả về thực cho các hàm kretprobed.
(Theo như chúng tôi có thể biết, __buildin_return_address() chỉ được sử dụng
dành cho thiết bị đo đạc và báo cáo lỗi.)

Nếu số lần gọi hàm không khớp với số
số lần nó trả về, việc đăng ký thăm dò trả về trên hàm đó có thể
tạo ra những kết quả không mong muốn. Trong trường hợp như vậy, một dòng:
kretprobe BUG!: Đang xử lý kretprobe d0000000000041aa8 @ c00000000004f48c
được in. Với thông tin này, người ta sẽ có thể liên hệ giữa
trường hợp chính xác của kretprobe đã gây ra sự cố. Chúng tôi có
trường hợp do_exit() được bảo hiểm. do_execve() và do_fork() không phải là vấn đề.
Chúng tôi không biết về các trường hợp cụ thể khác mà điều này có thể là vấn đề.

Nếu khi vào hoặc thoát khỏi một chức năng, CPU đang chạy trên
một ngăn xếp khác với tác vụ hiện tại, đăng ký trả về
thăm dò chức năng đó có thể tạo ra kết quả không mong muốn.  Vì điều này
lý do, Kprobes không hỗ trợ các đầu dò trả lại (hoặc kprobes)
trên phiên bản x86_64 của __switch_to(); các chức năng đăng ký
trả về -EINVAL.

Trên x86/x86-64, do Tối ưu hóa Bước nhảy của Kprobe sửa đổi
hướng dẫn rộng rãi, có một số hạn chế để tối ưu hóa. Đến
giải thích nó, chúng tôi giới thiệu một số thuật ngữ. Hãy tưởng tượng một hướng dẫn 3
chuỗi bao gồm hai lệnh 2 byte và một lệnh 3 byte
hướng dẫn.

::

IA
		|
	[-2] [-1] [0] [1] [2] [3] [4] [5] [6]
		[ins1][ins2][ins3 ]
		[<- DCR ->]
		[<- JTPR ->]

ins1: Lệnh đầu tiên
	ins2: Lệnh thứ 2
	ins3: Lệnh thứ 3
	IA: Địa chỉ chèn
	JTPR: Vùng cấm mục tiêu nhảy
	DCR: Vùng mã đường vòng

Các hướng dẫn trong DCR được sao chép vào bộ đệm ngoại tuyến
của kprobe, vì các byte trong DCR được thay thế bằng
lệnh nhảy 5 byte. Vì vậy, có một số hạn chế.

a) Các lệnh trong DCR phải có khả năng định vị lại được.
b) Các lệnh trong DCR không được bao gồm lệnh gọi.
c) JTPR không được nhắm mục tiêu bởi bất kỳ lệnh nhảy hoặc lệnh gọi nào.
d) DCR không được nằm giữa ranh giới giữa các chức năng.

Dù sao đi nữa, những hạn chế này được kiểm tra bằng lệnh trong kernel
bộ giải mã nên bạn không cần phải lo lắng về điều đó.

thăm dò trên cao
==============

Trên một chiếc CPU điển hình được sử dụng vào năm 2005, một lần nhấn kprobe mất 0,5 đến 1,0
micro giây để xử lý.  Cụ thể, một điểm chuẩn có cùng điểm
thăm dò liên tục, mỗi lần thực hiện một trình xử lý đơn giản, báo cáo 1-2
triệu lượt truy cập mỗi giây, tùy thuộc vào kiến trúc.  Một đầu dò quay trở lại
lần truy cập thường mất nhiều thời gian hơn 50-75% so với lần truy cập kprobe.
Khi bạn đã đặt đầu dò quay lại trên một hàm, hãy thêm kprobe vào
mục nhập vào chức năng đó về cơ bản không có chi phí bổ sung.

Dưới đây là số liệu chi phí mẫu (trong usec) cho các kiến ​​trúc khác nhau::

k = kprobe; r = trả lại đầu dò; kr = kprobe + thăm dò trở lại
  trên cùng một chức năng

i386: Intel Pentium M, 1495 MHz, 2957,31 bogomips
  k = 0,57 usec; r = 0,92; kr = 0,99

x86_64: AMD Opteron 246, 1994 MHz, 3971,48 bogomips
  k = 0,49 usec; r = 0,80; kr = 0,82

ppc64: POWER5 (gr), 1656 MHz (SMT bị tắt, 1 CPU ảo trên mỗi CPU vật lý)
  k = 0,77 usec; r = 1,26; kr = 1,45

Chi phí thăm dò được tối ưu hóa
------------------------

Thông thường, một lần truy cập kprobe được tối ưu hóa sẽ mất 0,07 đến 0,1 micro giây để
quá trình. Dưới đây là số liệu chi phí mẫu (trong usec) cho kiến ​​trúc x86::

k = kprobe chưa được tối ưu hóa, b = được tăng cường (bỏ qua một bước), o = kprobe được tối ưu hóa,
  r = kretprobe chưa được tối ưu hóa, rb = kretprobe được tăng cường, ro = kretprobe được tối ưu hóa.

i386: Intel(R) Xeon(R) E5410, 2,33GHz, 4656,90 bogomips
  k = 0,80 usec; b = 0,33; o = 0,05; r = 1,10; rb = 0,61; ro = 0,33

x86-64: Intel(R) Xeon(R) E5410, 2.33GHz, 4656.90 bogomips
  k = 0,99 usec; b = 0,43; o = 0,06; r = 1,24; rb = 0,68; ro = 0,30

TODO
====

Một. SystemTap (ZZ0000ZZ Cung cấp một cách đơn giản hóa
   giao diện lập trình cho thiết bị dựa trên đầu dò.  Hãy thử nó.
b. Đầu dò trả về hạt nhân cho sparc64.
c. Hỗ trợ cho các kiến trúc khác.
d. Thăm dò không gian người dùng.
đ. Các đầu dò điểm quan sát (kích hoạt các tham chiếu dữ liệu).

Ví dụ về Kprobe
===============

Xem mẫu/kprobes/kprobe_example.c

Ví dụ về Kretprobe
==================

Xem mẫu/kprobes/kretprobe_example.c

Tính năng không được dùng nữa
===================

Jprobes hiện là một tính năng không được dùng nữa. Những người phụ thuộc vào nó nên
di chuyển sang các tính năng theo dõi khác hoặc sử dụng hạt nhân cũ hơn. Hãy cân nhắc để
di chuyển công cụ của bạn sang một trong các tùy chọn sau:

- Sử dụng sự kiện theo dõi để theo dõi hàm mục tiêu bằng các đối số.

sự kiện theo dõi có chi phí thấp (và hầu như không có chi phí hiển thị nếu nó
  bị tắt) giao diện sự kiện được xác định tĩnh. Bạn có thể xác định các sự kiện mới
  và theo dõi nó thông qua ftrace hoặc bất kỳ công cụ theo dõi nào khác.

Xem các url sau:

-ZZ0000ZZ
    -ZZ0001ZZ
    -ZZ0002ZZ

- Sử dụng các sự kiện động ftrace (sự kiện kprobe) với perf-probe.

Nếu bạn xây dựng hạt nhân của mình với thông tin gỡ lỗi (CONFIG_DEBUG_INFO=y), bạn có thể
  tìm thanh ghi/ngăn xếp nào được gán cho biến hoặc đối số cục bộ nào
  bằng cách sử dụng perf-probe và thiết lập sự kiện mới để theo dõi nó.

Xem các tài liệu sau:

- Tài liệu/trace/kprobetrace.rst
  - Tài liệu/dấu vết/events.rst
  - tools/perf/Documentation/perf-probe.txt


Giao diện debugfs của kprobes
=============================


Với các hạt nhân gần đây (> 2.6.20), danh sách các kprobe đã đăng ký sẽ hiển thị
trong thư mục /sys/kernel/debug/kprobes/ (giả sử các debugf được gắn tại //sys/kernel/debug).

/sys/kernel/debug/kprobes/list: Liệt kê tất cả các đầu dò đã đăng ký trên hệ thống::

c015d71a k vfs_read+0x0
	c03dedc5 r tcp_v4_rcv+0x0

Cột đầu tiên cung cấp địa chỉ kernel nơi đầu dò được chèn vào.
Cột thứ hai xác định loại đầu dò (k - kprobe và r - kretprobe)
trong khi cột thứ ba chỉ định ký hiệu + độ lệch của đầu dò.
Nếu hàm được thăm dò thuộc về một mô-đun thì tên mô-đun cũng là
được chỉ định. Các cột sau hiển thị trạng thái thăm dò. Nếu đầu dò bật
một địa chỉ ảo không còn hợp lệ (các phần init mô-đun, mô-đun
địa chỉ ảo tương ứng với các mô-đun đã được tải xuống),
các đầu dò như vậy được đánh dấu bằng [GONE]. Nếu đầu dò tạm thời bị vô hiệu hóa,
các đầu dò như vậy được đánh dấu bằng [DISABLED]. Nếu đầu dò được tối ưu hóa thì
được đánh dấu bằng [OPTIMIZED]. Nếu đầu dò dựa trên ftrace, nó được đánh dấu bằng
[FTRACE].

/sys/kernel/debug/kprobes/enabled: Buộc bật kprobes/OFF.

Cung cấp một nút xoay để bật toàn bộ và buộc các kprobes đã đăng ký BẬT hoặc OFF.
Theo mặc định, tất cả các kprobe đều được bật. Bằng cách lặp lại "0" vào tập tin này, tất cả
các tàu thăm dò đã đăng ký sẽ bị vô hiệu hóa cho đến khi số "1" được lặp lại ở đây
tập tin. Lưu ý rằng núm này chỉ vô hiệu hóa và kích hoạt tất cả các đầu dò chứ không
thay đổi trạng thái vô hiệu hóa của từng đầu dò. Điều này có nghĩa là các đầu dò k bị vô hiệu hóa (được đánh dấu
[DISABLED]) sẽ không được bật nếu bạn BẬT tất cả đầu dò bằng núm này.


Giao diện sysctl của kprobes
============================

/proc/sys/debug/kprobes-optimization: BẬT tối ưu hóa kprobes/OFF.

Khi CONFIG_OPTPROBES=y, giao diện sysctl này xuất hiện và nó cung cấp
một núm xoay để tối ưu hóa bước nhảy toàn cầu và buộc phải chuyển (xem phần
ZZ0000ZZ) BẬT hoặc OFF. Theo mặc định, tối ưu hóa bước nhảy
được cho phép (BẬT). Nếu bạn lặp lại "0" cho tệp này hoặc đặt
"debug.kprobes_optimization" thành 0 thông qua sysctl, tất cả các thăm dò được tối ưu hóa sẽ
chưa được tối ưu hóa và mọi thăm dò mới được đăng ký sau đó sẽ không được tối ưu hóa.

Lưu ý rằng núm ZZ0000ZZ này ở trạng thái tối ưu. Điều này có nghĩa là đã tối ưu hóa
đầu dò (được đánh dấu [OPTIMIZED]) sẽ không được tối ưu hóa (thẻ [OPTIMIZED] sẽ được
bị loại bỏ). Nếu bật núm, chúng sẽ được tối ưu hóa trở lại.

Tài liệu tham khảo
==========

Để biết thêm thông tin về Kprobes, hãy tham khảo các URL sau:

-ZZ0000ZZ
-ZZ0001ZZ

