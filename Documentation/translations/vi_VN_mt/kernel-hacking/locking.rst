.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kernel-hacking/locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernel_hacking_lock:

=================================
Hướng dẫn khóa không đáng tin cậy
=================================

:Tác giả: Rusty Russell

Giới thiệu
============

Chào mừng bạn đến với Hướng dẫn khóa hạt nhân không đáng tin cậy đáng chú ý của Rusty
vấn đề. Tài liệu này mô tả các hệ thống khóa trong Linux Kernel
trong 2.6.

Với sự sẵn có rộng rãi của HyperThreading và quyền ưu tiên trong
Hạt nhân Linux, mọi người hack hạt nhân đều cần biết
nguyên tắc cơ bản về đồng thời và khóa cho SMP.

Vấn đề với sự đồng thời
============================

(Bỏ qua phần này nếu bạn biết Điều kiện cuộc đua là gì).

Trong một chương trình bình thường, bạn có thể tăng bộ đếm như sau:

::

very_important_count++;


Đây là những gì họ mong đợi sẽ xảy ra:


.. table:: Expected Results

  +------------------------------------+------------------------------------+
  | Instance 1                         | Instance 2                         |
  +====================================+====================================+
  | read very_important_count (5)      |                                    |
  +------------------------------------+------------------------------------+
  | add 1 (6)                          |                                    |
  +------------------------------------+------------------------------------+
  | write very_important_count (6)     |                                    |
  +------------------------------------+------------------------------------+
  |                                    | read very_important_count (6)      |
  +------------------------------------+------------------------------------+
  |                                    | add 1 (7)                          |
  +------------------------------------+------------------------------------+
  |                                    | write very_important_count (7)     |
  +------------------------------------+------------------------------------+

Đây là những gì có thể xảy ra:

.. table:: Possible Results

  +------------------------------------+------------------------------------+
  | Instance 1                         | Instance 2                         |
  +====================================+====================================+
  | read very_important_count (5)      |                                    |
  +------------------------------------+------------------------------------+
  |                                    | read very_important_count (5)      |
  +------------------------------------+------------------------------------+
  | add 1 (6)                          |                                    |
  +------------------------------------+------------------------------------+
  |                                    | add 1 (6)                          |
  +------------------------------------+------------------------------------+
  | write very_important_count (6)     |                                    |
  +------------------------------------+------------------------------------+
  |                                    | write very_important_count (6)     |
  +------------------------------------+------------------------------------+


Điều kiện cuộc đua và khu vực quan trọng
------------------------------------

Sự chồng chéo này, trong đó kết quả phụ thuộc vào thời gian tương đối của
nhiều nhiệm vụ, được gọi là điều kiện chạy đua. Đoạn mã chứa
vấn đề tương tranh được gọi là một khu vực quan trọng. Và đặc biệt là từ khi
Linux bắt đầu chạy trên các máy SMP, chúng đã trở thành một trong những máy chính
các vấn đề trong thiết kế và triển khai hạt nhân.

Quyền ưu tiên có thể có tác dụng tương tự, ngay cả khi chỉ có một CPU: bởi
ưu tiên một nhiệm vụ trong khu vực quan trọng, chúng tôi có chính xác như nhau
tình trạng cuộc đua. Trong trường hợp này, luồng ưu tiên có thể chạy
bản thân khu vực quan trọng.

Giải pháp là nhận biết khi nào những truy cập đồng thời này xảy ra và
sử dụng khóa để đảm bảo rằng chỉ một phiên bản có thể vào được điểm quan trọng
khu vực bất cứ lúc nào. Có rất nhiều nguyên thủy thân thiện trong Linux
kernel để giúp bạn làm điều này. Và sau đó là những người không thân thiện
nguyên thủy, nhưng tôi sẽ coi như chúng không tồn tại.

Khóa trong hạt nhân Linux
===========================

Nếu tôi có thể cho bạn một lời khuyên về việc khóa: ZZ0000ZZ.

Hãy miễn cưỡng giới thiệu ổ khóa mới.

Hai loại khóa hạt nhân chính: Spinlocks và Mutexes
-----------------------------------------------------

Có hai loại khóa kernel chính. Loại cơ bản là
spinlock (ZZ0000ZZ), rất đơn giản
khóa một tay cầm: nếu không lấy được khóa xoay, bạn tiếp tục thử
(quay) cho đến khi bạn có thể. Spinlocks rất nhỏ và nhanh, và có thể
được sử dụng ở bất cứ đâu.

Loại thứ hai là mutex (ZZ0000ZZ): nó giống như một
spinlock, nhưng bạn có thể chặn việc giữ mutex. Nếu bạn không thể khóa một mutex,
nhiệm vụ của bạn sẽ tự tạm dừng và được đánh thức khi mutex
được thả ra. Điều này có nghĩa là CPU có thể làm việc khác trong khi bạn
đang chờ đợi. Có nhiều trường hợp bạn không thể ngủ được (xem
ZZ0001ZZ),
và do đó phải sử dụng một spinlock thay thế.

Cả hai loại khóa đều không đệ quy: xem
ZZ0000ZZ.

Khóa và hạt nhân bộ xử lý
------------------------------

Đối với các hạt nhân được biên dịch không có ZZ0000ZZ và không có
Spinlock ZZ0001ZZ hoàn toàn không tồn tại. Đây là một điều tuyệt vời
quyết định thiết kế: khi không có ai khác có thể chạy cùng lúc thì không có
lý do phải có khóa

Nếu kernel được biên dịch không có ZZ0000ZZ, nhưng ZZ0001ZZ
được thiết lập thì spinlock chỉ cần vô hiệu hóa quyền ưu tiên, điều này là đủ để
ngăn cản mọi cuộc đua. Đối với hầu hết các mục đích, chúng ta có thể coi quyền ưu tiên là
tương đương với SMP và không phải lo lắng về nó một cách riêng biệt.

Bạn phải luôn kiểm tra mã khóa của mình bằng ZZ0000ZZ và
Đã bật ZZ0001ZZ, ngay cả khi bạn không có hộp kiểm tra SMP,
bởi vì nó vẫn sẽ bắt được một số loại lỗi khóa.

Mutexes vẫn tồn tại vì chúng cần thiết cho việc đồng bộ hóa
giữa các bối cảnh của người dùng, như chúng ta sẽ thấy bên dưới.

Chỉ khóa trong ngữ cảnh người dùng
----------------------------

Nếu bạn có cấu trúc dữ liệu chỉ được truy cập từ người dùng
ngữ cảnh, thì bạn có thể sử dụng một mutex đơn giản (ZZ0000ZZ) để
bảo vệ nó. Đây là trường hợp tầm thường nhất: bạn khởi tạo mutex.
Sau đó, bạn có thể gọi mutex_lock_interruptible() để lấy
mutex và mutex_unlock() để giải phóng nó. Ngoài ra còn có một
mutex_lock(), điều này nên tránh vì nó sẽ
không quay trở lại nếu nhận được tín hiệu.

Ví dụ: ZZ0000ZZ cho phép đăng ký mới
các lệnh gọi setsockopt() và getsockopt(), với
nf_register_sockopt(). Đăng ký và hủy đăng ký
chỉ được thực hiện khi tải và dỡ tải mô-đun (và thời gian khởi động, khi có
không đồng thời) và danh sách đăng ký chỉ được tư vấn cho một
hệ thống setsockopt() hoặc getsockopt() không xác định
gọi. ZZ0001ZZ là giải pháp hoàn hảo để bảo vệ điều này, đặc biệt là
vì các lệnh gọi setsockopt và getsockopt có thể ngủ yên.

Khóa giữa bối cảnh người dùng và Softirqs
-----------------------------------------

Nếu softirq chia sẻ dữ liệu với ngữ cảnh của người dùng, bạn sẽ gặp hai vấn đề.
Thứ nhất, bối cảnh người dùng hiện tại có thể bị gián đoạn bởi softirq và
thứ hai, vùng quan trọng có thể được nhập từ một CPU khác. Đây là
trong đó spin_lock_bh() (ZZ0000ZZ) là
đã sử dụng. Nó vô hiệu hóa softirq trên CPU đó, sau đó lấy khóa.
spin_unlock_bh() thì ngược lại. (Hậu tố '_bh' là
một tài liệu tham khảo lịch sử về "Nửa dưới", tên cũ của phần mềm
ngắt quãng. Nó thực sự nên được gọi là spin_lock_softirq()' theo cách
thế giới hoàn hảo).

Lưu ý rằng bạn cũng có thể sử dụng spin_lock_irq() hoặc
spin_lock_irqsave() ở đây, ngăn chặn sự gián đoạn phần cứng
cũng vậy: xem ZZ0000ZZ.

Điều này cũng hoạt động hoàn hảo cho UP: khóa xoay biến mất và điều này
macro đơn giản trở thành local_bh_disable()
(ZZ0000ZZ), bảo vệ bạn khỏi phần mềm
đang được điều hành.

Khóa giữa bối cảnh người dùng và tác vụ
-----------------------------------------

Điều này hoàn toàn giống như trên, vì các tác vụ thực sự được chạy
từ một softirq.

Khóa giữa bối cảnh người dùng và bộ hẹn giờ
---------------------------------------

Điều này cũng hoàn toàn giống như trên, vì bộ tính giờ thực sự được chạy
từ một softirq. Từ quan điểm khóa, các tác vụ và bộ tính giờ được
giống hệt nhau.

Khóa giữa các tác vụ/bộ hẹn giờ
-------------------------------

Đôi khi một tác vụ hoặc bộ đếm thời gian có thể muốn chia sẻ dữ liệu với người khác
tasklet hoặc bộ đếm thời gian.

Cùng một tác vụ/bộ hẹn giờ
~~~~~~~~~~~~~~~~~~~~~~

Vì một tasklet không bao giờ chạy trên hai CPU cùng một lúc nên bạn không cần phải
lo lắng về việc tasklet của bạn được thực hiện lại (chạy hai lần cùng một lúc), thậm chí
trên SMP.

Tác vụ/Bộ hẹn giờ khác nhau
~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu một tác vụ/bộ hẹn giờ khác muốn chia sẻ dữ liệu với tác vụ hoặc bộ hẹn giờ của bạn
, cả hai bạn sẽ cần sử dụng spin_lock() và
cuộc gọi spin_unlock(). spin_lock_bh() là
không cần thiết ở đây, vì bạn đã ở trong một tác vụ nhỏ và sẽ không có tác vụ nào được chạy
trên cùng một CPU.

Khóa giữa Softirqs
------------------------

Thông thường, một softirq có thể muốn chia sẻ dữ liệu với chính nó hoặc một tasklet/timer.

Cùng một Softirq
~~~~~~~~~~~~~~~~

Phần mềm tương tự có thể chạy trên các CPU khác: bạn có thể sử dụng mảng trên mỗi CPU
(xem ZZ0000ZZ) để có hiệu suất tốt hơn. Nếu bạn là
đi xa hơn khi sử dụng softirq, bạn có thể quan tâm đến khả năng mở rộng
hiệu suất đủ để biện minh cho sự phức tạp thêm.

Bạn sẽ cần sử dụng spin_lock() và
spin_unlock() cho dữ liệu được chia sẻ.

Softirq khác nhau
~~~~~~~~~~~~~~~~~~

Bạn sẽ cần sử dụng spin_lock() và
spin_unlock() cho dữ liệu được chia sẻ, cho dù đó là bộ đếm thời gian,
tasklet, softirq khác nhau hoặc softirq giống nhau hoặc softirq khác: bất kỳ trong số chúng
có thể đang chạy trên CPU khác.

Bối cảnh cứng IRQ
================

Các ngắt phần cứng thường giao tiếp với một tasklet hoặc softirq.
Thông thường, điều này liên quan đến việc xếp công việc vào hàng đợi, phần mềm sẽ
lấy ra.

Khóa giữa IRQ cứng và Softirqs/Tasklets
----------------------------------------------

Nếu trình xử lý irq phần cứng chia sẻ dữ liệu với softirq, bạn có hai
mối quan tâm. Thứ nhất, quá trình xử lý softirq có thể bị gián đoạn bởi một
ngắt phần cứng và thứ hai, vùng quan trọng có thể được nhập
bởi một sự gián đoạn phần cứng trên một CPU khác. Đây là nơi
spin_lock_irq() được sử dụng. Nó được định nghĩa để vô hiệu hóa
ngắt trên cpu đó, sau đó lấy khóa.
spin_unlock_irq() thì ngược lại.

Trình xử lý irq không cần sử dụng spin_lock_irq(), bởi vì
softirq không thể chạy trong khi trình xử lý irq đang chạy: nó có thể sử dụng
spin_lock(), nhanh hơn một chút. Ngoại lệ duy nhất
sẽ xảy ra nếu một trình xử lý irq phần cứng khác sử dụng cùng một khóa:
spin_lock_irq() sẽ ngăn việc đó làm gián đoạn chúng ta.

Điều này cũng hoạt động hoàn hảo cho UP: khóa xoay biến mất và điều này
macro đơn giản trở thành local_irq_disable()
(ZZ0000ZZ), bảo vệ bạn khỏi softirq/tasklet/BH
đang được điều hành.

spin_lock_irqsave() (ZZ0000ZZ) là một
biến thể lưu lại xem các ngắt được bật hay tắt trong một từ gắn cờ,
được chuyển tới spin_unlock_irqrestore(). Điều này có nghĩa
rằng cùng một mã có thể được sử dụng bên trong một trình xử lý irq cứng (trong đó
các ngắt đã bị tắt) và trong softirqs (nơi vô hiệu hóa irq
bắt buộc).

Lưu ý rằng các softirq (và do đó các tác vụ và bộ tính giờ) được chạy khi quay trở lại
do gián đoạn phần cứng, do đó spin_lock_irq() cũng dừng
những cái này. Theo nghĩa đó, spin_lock_irqsave() là tốt nhất
chức năng khóa chung và mạnh mẽ.

Khóa giữa hai bộ xử lý IRQ cứng
-------------------------------------

Rất hiếm khi phải chia sẻ dữ liệu giữa hai trình xử lý IRQ, nhưng nếu bạn
nên sử dụng spin_lock_irqsave(): đó là
kiến trúc cụ thể xem tất cả các ngắt có bị vô hiệu hóa bên trong irq hay không
bản thân người xử lý.

Bảng cheat để khóa
=======================

Pete Zaitcev đưa ra tóm tắt sau:

- Nếu bạn đang ở trong một ngữ cảnh quy trình (bất kỳ cuộc gọi tòa nhà nào) và muốn khóa các cuộc gọi khác
   xử lý, sử dụng một mutex. Bạn có thể uống mutex và ngủ
   (ZZ0000ZZ hoặc ZZ0001ZZ).

- Ngược lại (== dữ liệu có thể bị chạm vào khi bị gián đoạn), hãy sử dụng
   spin_lock_irqsave() và
   spin_unlock_irqrestore().

- Tránh giữ spinlock quá 5 dòng mã và trên bất kỳ dòng nào
   gọi hàm (ngoại trừ các trình truy cập như readb()).

Bảng yêu cầu tối thiểu
-----------------------------

Bảng sau liệt kê các yêu cầu khóa ZZ0000ZZ giữa
bối cảnh khác nhau. Trong một số trường hợp, bối cảnh tương tự chỉ có thể chạy trên
mỗi lần một CPU, do đó không cần khóa cho ngữ cảnh đó (ví dụ:
một luồng cụ thể chỉ có thể chạy trên một CPU tại một thời điểm, nhưng nếu nó cần
chia sẻ dữ liệu với một luồng khác, cần phải khóa).

Hãy nhớ lời khuyên ở trên: bạn luôn có thể sử dụng
spin_lock_irqsave(), là siêu tập hợp của tất cả các tập hợp khác
spinlock nguyên thủy.

=============== ============================================= ========= ========= ======= ====================== ===============
.              Trình xử lý IRQ A Trình xử lý IRQ B Softirq A Softirq B Tác vụ A Tác vụ B Bộ hẹn giờ A Bộ hẹn giờ B Ngữ cảnh người dùng A Ngữ cảnh người dùng B
=============== ============================================= ========= ========= ======= ====================== ===============
Trình xử lý IRQ A Không có
Trình xử lý IRQ B SLIS Không có
Softirq A SLI SLI SL
Softirq B SLI SLI SL SL
Nhiệm vụ A SLI SLI SL SL Không có
Nhiệm vụ B SLI SLI SL SL SL Không có
Bộ hẹn giờ A SLI SLI SL SL SL SL Không có
Bộ hẹn giờ B SLI SLI SL SL SL SL SL Không có
Bối cảnh người dùng A SLI SLI SLBH SLBH SLBH SLBH SLBH SLBH Không có
Bối cảnh người dùng B SLI SLI SLBH SLBH SLBH SLBH SLBH SLBH MLI Không có
=============== ============================================= ========= ========= ======= ====================== ===============

Bảng: Bảng yêu cầu khóa

+--------+------------------------------------------+
ZZ0000ZZ spin_lock_irqsave |
+--------+------------------------------------------+
ZZ0001ZZ spin_lock_irq |
+--------+------------------------------------------+
ZZ0002ZZ spin_lock |
+--------+------------------------------------------+
ZZ0003ZZ spin_lock_bh |
+--------+------------------------------------------+
ZZ0004ZZ mutex_lock_interruptible |
+--------+------------------------------------------+

Bảng: Chú giải về Bảng yêu cầu khóa

Chức năng khóa thử
=====================

Có những chức năng cố gắng lấy khóa chỉ một lần và ngay lập tức
trả về một giá trị cho biết việc lấy được khóa thành công hay thất bại.
Chúng có thể được sử dụng nếu bạn không cần truy cập vào dữ liệu được bảo vệ bằng
lock khi một số luồng khác đang giữ khóa. Bạn nên có được
khóa sau nếu sau đó bạn cần truy cập vào dữ liệu được bảo vệ bằng khóa.

spin_trylock() không quay nhưng trả về khác 0 nếu nó
có được spinlock trong lần thử đầu tiên hoặc 0 nếu không. Chức năng này có thể
được sử dụng trong mọi ngữ cảnh như spin_lock(): bạn phải có
đã vô hiệu hóa các bối cảnh có thể làm gián đoạn bạn và thu được vòng quay
khóa.

mutex_trylock() không tạm dừng nhiệm vụ của bạn mà trả về
khác 0 nếu nó có thể khóa mutex trong lần thử đầu tiên hoặc 0 nếu không. Cái này
chức năng không thể được sử dụng một cách an toàn khi bị gián đoạn phần cứng hoặc phần mềm
bối cảnh mặc dù không ngủ.

Ví dụ phổ biến
===============

Chúng ta hãy xem qua một ví dụ đơn giản: bộ đệm chứa ánh xạ số và tên.
Bộ nhớ đệm sẽ đếm tần suất sử dụng của từng đối tượng và
khi nó đầy, hãy vứt đi cái ít được sử dụng nhất.

Tất cả trong bối cảnh người dùng
-------------------

Trong ví dụ đầu tiên của chúng tôi, chúng tôi giả định rằng tất cả các hoạt động đều trong ngữ cảnh của người dùng
(tức là từ các cuộc gọi hệ thống), để chúng ta có thể ngủ. Điều này có nghĩa là chúng ta có thể sử dụng mutex
để bảo vệ bộ đệm và tất cả các đối tượng bên trong nó. Đây là mã::

#include <linux/list.h>
    #include <linux/slab.h>
    #include <linux/string.h>
    #include <linux/mutex.h>
    #include <asm/errno.h>

đối tượng cấu trúc
    {
            danh sách struct list_head;
            int id;
            tên char[32];
            int phổ biến;
    };

/* Bảo vệ bộ đệm, cache_num và các đối tượng trong đó */
    DEFINE_MUTEX tĩnh (cache_lock);
    LIST_HEAD tĩnh (bộ đệm);
    int cache_num tĩnh không dấu = 0;
    #define MAX_CACHE_SIZE 10

/* Phải giữ cache_lock */
    đối tượng cấu trúc tĩnh *__cache_find(int id)
    {
            đối tượng cấu trúc *i;

list_for_each_entry(i, &cache, list)
                    nếu (i->id == id) {
                            i->sự nổi tiếng++;
                            trả lại tôi;
                    }
            trả lại NULL;
    }

/* Phải giữ cache_lock */
    static void __cache_delete(đối tượng struct *obj)
    {
            BUG_ON(!obj);
            list_del(&obj->list);
            kfree(obj);
            cache_num--;
    }

/* Phải giữ cache_lock */
    khoảng trống tĩnh __cache_add(đối tượng cấu trúc *obj)
    {
            list_add(&obj->list, &cache);
            nếu (++cache_num > MAX_CACHE_SIZE) {
                    đối tượng cấu trúc *i, *outcast = NULL;
                    list_for_each_entry(i, &cache, list) {
                            if (!outcast || i->popularity < outcast->popularity)
                                    bị ruồng bỏ = tôi;
                    }
                    __cache_delete(bị ruồng bỏ);
            }
    }

int cache_add(int id, const char *name)
    {
            đối tượng cấu trúc *obj;

if ((obj = kmalloc(sizeof(*obj), GFP_KERNEL)) == NULL)
                    trả về -ENOMEM;

strscpy(obj->name, name, sizeof(obj->name));
            obj->id = id;
            obj->phổ biến = 0;

mutex_lock(&cache_lock);
            __cache_add(obj);
            mutex_unlock(&cache_lock);
            trả về 0;
    }

void cache_delete(int id)
    {
            mutex_lock(&cache_lock);
            __cache_delete(__cache_find(id));
            mutex_unlock(&cache_lock);
    }

int cache_find(int id, char *name)
    {
            đối tượng cấu trúc *obj;
            int ret = -ENOENT;

mutex_lock(&cache_lock);
            obj = __cache_find(id);
            nếu (obj) {
                    ret = 0;
                    strcpy(tên, obj->tên);
            }
            mutex_unlock(&cache_lock);
            trở lại ret;
    }

Lưu ý rằng chúng tôi luôn đảm bảo có cache_lock khi thêm,
xóa hoặc tra cứu bộ đệm: cả cơ sở hạ tầng bộ đệm và
nội dung của các đối tượng được bảo vệ bằng khóa. Trong trường hợp này nó
thật dễ dàng vì chúng tôi sao chép dữ liệu cho người dùng và không bao giờ cho phép họ truy cập
các đối tượng một cách trực tiếp.

Có một sự tối ưu hóa nhỏ (và phổ biến) ở đây: trong
cache_add() chúng tôi đã thiết lập các trường của đối tượng trước đó
nắm lấy ổ khóa. Điều này an toàn vì không ai khác có thể truy cập nó cho đến khi chúng tôi
đặt nó vào bộ nhớ đệm.

Truy cập từ bối cảnh ngắt
--------------------------------

Bây giờ hãy xem xét trường hợp có thể gọi cache_find()
từ bối cảnh ngắt: ngắt phần cứng hoặc phần mềm. Một
ví dụ sẽ là bộ hẹn giờ xóa đối tượng khỏi bộ đệm.

Thay đổi được hiển thị bên dưới, ở định dạng bản vá tiêu chuẩn: ZZ0000ZZ là các dòng
đã bị xóa đi và ZZ0001ZZ là những dòng được thêm vào.

::

--- cache.c.usercontext 2003-12-09 13:58:54.000000000 +1100
    +++ cache.c.interrupt 2003-12-09 14:07:49.000000000 +1100
    @@ -12,7 +12,7 @@
             int phổ biến;
     };

-static DEFINE_MUTEX(cache_lock);
    + DEFINE_SPINLOCK tĩnh(cache_lock);
     LIST_HEAD tĩnh (bộ đệm);
     int cache_num tĩnh không dấu = 0;
     #define MAX_CACHE_SIZE 10
    @@ -55,6 +55,7 @@
     int cache_add(int id, const char *name)
     {
             đối tượng cấu trúc *obj;
    + cờ dài không dấu;

if ((obj = kmalloc(sizeof(*obj), GFP_KERNEL)) == NULL)
                     trả về -ENOMEM;
    @@ -63,30 +64,33 @@
             obj->id = id;
             obj->phổ biến = 0;

- mutex_lock(&cache_lock);
    + spin_lock_irqsave(&cache_lock, flag);
             __cache_add(obj);
    - mutex_unlock(&cache_lock);
    + spin_unlock_irqrestore(&cache_lock, flag);
             trả về 0;
     }

void cache_delete(int id)
     {
    - mutex_lock(&cache_lock);
    + cờ dài không dấu;
    +
    + spin_lock_irqsave(&cache_lock, flag);
             __cache_delete(__cache_find(id));
    - mutex_unlock(&cache_lock);
    + spin_unlock_irqrestore(&cache_lock, flag);
     }

int cache_find(int id, char *name)
     {
             đối tượng cấu trúc *obj;
             int ret = -ENOENT;
    + cờ dài không dấu;

- mutex_lock(&cache_lock);
    + spin_lock_irqsave(&cache_lock, flag);
             obj = __cache_find(id);
             nếu (obj) {
                     ret = 0;
                     strcpy(tên, obj->tên);
             }
    - mutex_unlock(&cache_lock);
    + spin_unlock_irqrestore(&cache_lock, flag);
             trở lại ret;
     }

Lưu ý rằng spin_lock_irqsave() sẽ tắt
ngắt nếu chúng được bật, nếu không thì không làm gì cả (nếu chúng ta đã ở trong
một trình xử lý ngắt), do đó các hàm này an toàn để gọi từ bất kỳ
bối cảnh.

Thật không may, cache_add() gọi kmalloc()
với cờ ZZ0000ZZ, cờ này chỉ hợp pháp trong ngữ cảnh của người dùng. tôi
đã giả định rằng cache_add() vẫn chỉ được gọi trong
ngữ cảnh của người dùng, nếu không thì điều này sẽ trở thành một tham số cho
bộ nhớ cache_add().

Hiển thị các đối tượng bên ngoài tệp này
----------------------------------

Nếu các đối tượng của chúng ta chứa nhiều thông tin hơn thì có thể không đủ để
sao chép thông tin vào và ra: các phần khác của mã có thể muốn
giữ con trỏ tới các đối tượng này, ví dụ, thay vì tìm kiếm
id mọi lúc. Điều này tạo ra hai vấn đề.

Vấn đề đầu tiên là chúng ta sử dụng ZZ0000ZZ để bảo vệ đồ vật:
chúng ta cần làm cho nó không tĩnh để phần còn lại của mã có thể sử dụng nó.
Điều này làm cho việc khóa trở nên phức tạp hơn vì tất cả mọi thứ không còn ở một nơi nữa.

Vấn đề thứ hai là vấn đề trọn đời: nếu một cấu trúc khác giữ một
con trỏ tới một đối tượng, có lẽ nó mong đợi con trỏ đó vẫn còn
hợp lệ. Thật không may, điều này chỉ được đảm bảo khi bạn giữ khóa,
nếu không thì ai đó có thể gọi cache_delete() và thậm chí
tệ hơn, thêm một đối tượng khác, sử dụng lại cùng một địa chỉ.

Vì chỉ có một ổ khóa nên bạn không thể giữ nó mãi được: không ai khác có thể
hoàn thành mọi công việc.

Giải pháp cho vấn đề này là sử dụng số lượng tham chiếu: tất cả những người
có một con trỏ tới đối tượng sẽ tăng nó khi họ lấy đối tượng lần đầu tiên,
và giảm số lượng tham chiếu khi họ hoàn thành nó. Bất cứ ai
giảm nó xuống 0 thì biết nó không được sử dụng và thực sự có thể xóa nó.

Đây là mã::

--- cache.c.interrupt 2003-12-09 14:25:43.000000000 +1100
    +++ cache.c.refcnt 2003-12-09 14:33:05.000000000 +1100
    @@ -7,6 +7,7 @@
     đối tượng cấu trúc
     {
             danh sách struct list_head;
    + số nguyên không dấu;
             int id;
             tên char[32];
             int phổ biến;
    @@ -17,6 +18,35 @@
     int cache_num tĩnh không dấu = 0;
     #define MAX_CACHE_SIZE 10

+static void __object_put(đối tượng cấu trúc *obj)
    +{
    + if (--obj->refcnt == 0)
    + kfree(obj);
    +}
    +
    +static void __object_get(đối tượng cấu trúc *obj)
    +{
    + obj->refcnt++;
    +}
    +
    +void object_put(đối tượng struct *obj)
    +{
    + cờ dài không dấu;
    +
    + spin_lock_irqsave(&cache_lock, flag);
    + __object_put(obj);
    + spin_unlock_irqrestore(&cache_lock, flag);
    +}
    +
    +void object_get(đối tượng struct *obj)
    +{
    + cờ dài không dấu;
    +
    + spin_lock_irqsave(&cache_lock, flag);
    + __object_get(obj);
    + spin_unlock_irqrestore(&cache_lock, flag);
    +}
    +
     /* Phải giữ cache_lock */
     đối tượng cấu trúc tĩnh *__cache_find(int id)
     {
    @@ -35,6 +65,7 @@
     {
             BUG_ON(!obj);
             list_del(&obj->list);
    + __object_put(obj);
             cache_num--;
     }

@@ -63,6 +94,7 @@
             strscpy(obj->name, name, sizeof(obj->name));
             obj->id = id;
             obj->phổ biến = 0;
    + obj->refcnt = 1; /* Bộ đệm chứa một tham chiếu */

spin_lock_irqsave(&cache_lock, flag);
             __cache_add(obj);
    @@ -79,18 +111,15 @@
             spin_unlock_irqrestore(&cache_lock, flag);
     }

-int cache_find(int id, char *name)
    +đối tượng cấu trúc *cache_find(int id)
     {
             đối tượng cấu trúc *obj;
    - int ret = -ENOENT;
             cờ dài không dấu;

spin_lock_irqsave(&cache_lock, flag);
             obj = __cache_find(id);
    - nếu (obj) {
    - ret = 0;
    - strcpy(tên, obj->tên);
    - }
    + nếu (obj)
    + __object_get(obj);
             spin_unlock_irqrestore(&cache_lock, flag);
    - trả lại ret;
    + trả về đối tượng;
     }

Chúng tôi gói gọn việc đếm tham chiếu trong tiêu chuẩn 'get' và 'put'
chức năng. Bây giờ chúng ta có thể trả lại chính đối tượng đó từ
cache_find() có lợi thế là người dùng có thể
bây giờ ngủ đang giữ đối tượng (ví dụ: copy_to_user() thành
đặt tên cho không gian người dùng).

Điểm khác cần lưu ý là tôi đã nói nên giữ lại một tài liệu tham khảo cho
mọi con trỏ tới đối tượng: do đó số tham chiếu là 1 khi lần đầu tiên
được chèn vào bộ đệm. Trong một số phiên bản, khung này không có
số lượng tham chiếu, nhưng chúng phức tạp hơn.

Sử dụng các phép toán nguyên tử cho số lượng tham chiếu
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trong thực tế, ZZ0000ZZ thường được sử dụng cho refcnt. có một
số phép toán nguyên tử được xác định trong ZZ0001ZZ: những
được đảm bảo có thể nhìn thấy nguyên tử từ tất cả các CPU trong hệ thống, vì vậy không
khóa là cần thiết. Trong trường hợp này, nó đơn giản hơn việc sử dụng spinlocks,
mặc dù đối với bất cứ điều gì không tầm thường, việc sử dụng spinlocks sẽ rõ ràng hơn. các
Atomic_inc() và Atomic_dec_and_test()
được sử dụng thay cho các toán tử tăng và giảm tiêu chuẩn, và
khóa không còn được sử dụng để bảo vệ số tham chiếu nữa.

::

--- cache.c.refcnt 2003-12-09 15:00:35.000000000 +1100
    +++ cache.c.refcnt-atomic 2003-12-11 15:49:42.000000000 +1100
    @@ -7,7 +7,7 @@
     đối tượng cấu trúc
     {
             danh sách struct list_head;
    - unsigned int refcnt;
    + phản ánh nguyên tử_t;
             int id;
             tên char[32];
             int phổ biến;
    @@ -18,33 +18,15 @@
     int cache_num tĩnh không dấu = 0;
     #define MAX_CACHE_SIZE 10

-static void __object_put(đối tượng cấu trúc *obj)
    -{
    - if (--obj->refcnt == 0)
    - kfree(obj);
    -}
    -
    -static void __object_get(đối tượng cấu trúc *obj)
    -{
    - obj->refcnt++;
    -}
    -
     void object_put(đối tượng struct *obj)
     {
    - cờ dài không dấu;
    -
    - spin_lock_irqsave(&cache_lock, cờ);
    - __object_put(obj);
    - spin_unlock_irqrestore(&cache_lock, flag);
    + if (atomic_dec_and_test(&obj->refcnt))
    + kfree(obj);
     }

void object_get(đối tượng struct *obj)
     {
    - cờ dài không dấu;
    -
    - spin_lock_irqsave(&cache_lock, cờ);
    - __object_get(obj);
    - spin_unlock_irqrestore(&cache_lock, flag);
    + Atomic_inc(&obj->refcnt);
     }

/* Phải giữ cache_lock */
    @@ -65,7 +47,7 @@
     {
             BUG_ON(!obj);
             list_del(&obj->list);
    - __object_put(obj);
    + object_put(obj);
             cache_num--;
     }

@@ -94,7 +76,7 @@
             strscpy(obj->name, name, sizeof(obj->name));
             obj->id = id;
             obj->phổ biến = 0;
    - obj->refcnt = 1; /* Bộ đệm chứa một tham chiếu */
    + Atomic_set(&obj->refcnt, 1); /* Bộ đệm chứa một tham chiếu */

spin_lock_irqsave(&cache_lock, flag);
             __cache_add(obj);
    @@ -119,7 +101,7 @@
             spin_lock_irqsave(&cache_lock, flag);
             obj = __cache_find(id);
             nếu (obj)
    - __object_get(obj);
    + object_get(obj);
             spin_unlock_irqrestore(&cache_lock, flag);
             trả lại đối tượng;
     }

Tự bảo vệ các đối tượng
---------------------------------

Trong các ví dụ này, chúng tôi giả định rằng các đối tượng (ngoại trừ tham chiếu
count) không bao giờ thay đổi khi chúng được tạo. Nếu chúng ta muốn cho phép
tên để thay đổi, có ba khả năng:

- Bạn có thể làm cho ZZ0000ZZ ở trạng thái không tĩnh và bảo mọi người lấy nó
   lock trước khi thay đổi tên trong bất kỳ đối tượng nào.

- Bạn có thể cung cấp cache_obj_rename() để lấy cái này
   khóa và thay đổi tên người gọi, đồng thời yêu cầu mọi người sử dụng
   chức năng đó.

- Bạn có thể đặt ZZ0000ZZ chỉ bảo vệ bộ đệm và
   sử dụng một khóa khác để bảo vệ tên.

Về mặt lý thuyết, bạn có thể làm cho các ổ khóa mịn như một ổ khóa dành cho
mọi lĩnh vực, mọi đối tượng. Trong thực tế, các biến thể phổ biến nhất
là:

- Một khóa bảo vệ cơ sở hạ tầng (danh sách ZZ0000ZZ trong
   ví dụ này) và tất cả các đối tượng. Đây là những gì chúng tôi đã làm cho đến nay.

- Một khóa bảo vệ cơ sở hạ tầng (bao gồm cả danh sách
   con trỏ bên trong đối tượng) và một khóa bên trong đối tượng
   bảo vệ phần còn lại của đối tượng đó.

- Nhiều khóa để bảo vệ cơ sở hạ tầng (ví dụ: một khóa cho mỗi hàm băm
   chuỗi), có thể có khóa riêng cho từng đối tượng.

Đây là cách triển khai "khóa cho mỗi đối tượng":

::

--- cache.c.refcnt-atomic 2003-12-11 15:50:54.000000000 +1100
    +++ cache.c.perobjectlock 2003-12-11 17:15:03.000000000 +1100
    @@ -6,11 +6,17 @@

đối tượng cấu trúc
     {
    + /* Hai cái này được bảo vệ bởi cache_lock. */
             danh sách struct list_head;
    + mức độ phổ biến;
    +
             nguyên tử_t phản ánh;
    +
    + /* Không thay đổi sau khi tạo. */
             int id;
    +
    + khóa spinlock_t; /* Bảo vệ tên */
             tên char[32];
    - int phổ biến;
     };

DEFINE_SPINLOCK tĩnh (cache_lock);
    @@ -77,6 +84,7 @@
             obj->id = id;
             obj->phổ biến = 0;
             Atomic_set(&obj->refcnt, 1); /* Bộ đệm chứa một tham chiếu */
    + spin_lock_init(&obj->lock);

spin_lock_irqsave(&cache_lock, flag);
             __cache_add(obj);

Lưu ý rằng tôi quyết định rằng số lượng phổ biến cần được bảo vệ bởi
ZZ0001ZZ chứ không phải khóa theo từng đối tượng: điều này là do nó (như
ZZ0000ZZ bên trong đối tượng)
về mặt logic là một phần của cơ sở hạ tầng. Bằng cách này, tôi không cần phải lấy
khóa của mọi đối tượng trong __cache_add() khi tìm kiếm
ít phổ biến nhất.

Tôi cũng đã quyết định rằng thành viên id là không thể thay đổi nên tôi không cần phải thay đổi
lấy từng khóa đối tượng trong __cache_find() để kiểm tra
id: khóa đối tượng chỉ được sử dụng bởi người gọi muốn đọc hoặc viết
trường tên.

Cũng lưu ý rằng tôi đã thêm nhận xét mô tả dữ liệu nào được bảo vệ bởi
ổ khóa nào. Điều này cực kỳ quan trọng vì nó mô tả thời gian chạy
hành vi của mã và khó có thể đạt được chỉ bằng cách đọc. Và như
Alan Cox nói: “Khóa dữ liệu, không phải mã hóa”.

Các vấn đề thường gặp
===============

Bế tắc: Đơn giản và nâng cao
-----------------------------

Có một lỗi mã hóa trong đó một đoạn mã cố lấy một spinlock
hai lần: nó sẽ quay mãi mãi, chờ ổ khóa được giải phóng
(spinlocks, rwlocks và mutexes không đệ quy trong Linux). Đây là
tầm thường để chẩn đoán: không phải là một
vấn đề là thức-năm-đêm-nói-với-mật-lông-thỏ.

Đối với trường hợp phức tạp hơn một chút, hãy tưởng tượng bạn có một vùng được chia sẻ bởi một
softirq và bối cảnh người dùng. Nếu bạn sử dụng lệnh gọi spin_lock()
để bảo vệ nó, có thể bối cảnh của người dùng sẽ bị gián đoạn
bởi softirq trong khi nó giữ khóa và softirq sau đó sẽ quay
mãi mãi cố gắng để có được cùng một khóa.

Cả hai điều này đều được gọi là bế tắc và như đã trình bày ở trên, nó có thể xảy ra ngay cả khi
với một CPU duy nhất (mặc dù không có trong UP biên dịch, vì spinlocks biến mất
trên kernel biên dịch với ZZ0000ZZ\ =n. Bạn vẫn sẽ nhận được dữ liệu
tham nhũng trong ví dụ thứ hai).

Việc khóa hoàn chỉnh này rất dễ chẩn đoán: trên các hộp SMP, cơ quan giám sát
hẹn giờ hoặc biên dịch với bộ ZZ0000ZZ
(ZZ0001ZZ) sẽ hiển thị thông tin này ngay lập tức khi nó
xảy ra.

Một vấn đề phức tạp hơn được gọi là 'cái ôm chết người', liên quan đến hai
hoặc nhiều ổ khóa. Giả sử bạn có một bảng băm: mỗi mục trong bảng là một
spinlock và một chuỗi các đối tượng được băm. Bên trong trình xử lý softirq, bạn
đôi khi muốn thay đổi một đối tượng từ nơi này sang nơi khác trong hàm băm:
bạn lấy spinlock của chuỗi băm cũ và spinlock của chuỗi mới
chuỗi băm và xóa đối tượng khỏi đối tượng cũ và chèn nó vào
cái mới.

Có hai vấn đề ở đây. Đầu tiên, nếu mã của bạn cố gắng di chuyển
đối tượng vào cùng một chuỗi, nó sẽ bế tắc với chính nó khi nó cố gắng
khóa nó hai lần. Thứ hai, nếu cùng một phần mềm trên CPU khác đang cố gắng
di chuyển một vật thể khác theo hướng ngược lại, điều sau đây có thể
xảy ra:

+--------------+-----------------------+
ZZ0000ZZ CPU 2 |
+============================================================================================================
ZZ0001ZZ Khóa Grab B -> OK |
+--------------+-----------------------+
ZZ0002ZZ Grab khóa A -> quay |
+--------------+-----------------------+

Bảng: Hậu quả

Hai CPU sẽ quay mãi mãi, chờ đợi CPU kia từ bỏ nhiệm vụ của mình.
khóa. Nó sẽ trông, có mùi và cảm giác giống như một vụ tai nạn.

Ngăn ngừa bế tắc
-------------------

Sách giáo khoa sẽ cho bạn biết rằng nếu bạn luôn khóa theo cùng một thứ tự, bạn
sẽ không bao giờ gặp phải tình trạng bế tắc như thế này. Thực hành sẽ cho bạn biết rằng điều này
cách tiếp cận không mở rộng quy mô: khi tôi tạo một khóa mới, tôi không hiểu
đủ nhân để tìm ra vị trí của nó trong hệ thống phân cấp khóa 5000
sẽ phù hợp.

Các khóa tốt nhất được gói gọn: chúng không bao giờ bị lộ trong các tiêu đề và
không bao giờ được thực hiện xung quanh các cuộc gọi đến các hàm không tầm thường bên ngoài cùng một
tập tin. Bạn có thể đọc qua mã này và thấy rằng nó sẽ không bao giờ
bế tắc, bởi vì nó không bao giờ cố lấy một khóa khác trong khi nó có khóa đó
một. Những người sử dụng mã của bạn thậm chí không cần biết bạn đang sử dụng
khóa.

Một vấn đề kinh điển ở đây là khi bạn cung cấp lệnh gọi lại hoặc hook: nếu bạn
gọi những thứ này với khóa được giữ, bạn có nguy cơ bị bế tắc đơn giản hoặc một tình huống chết người
ôm lấy (ai biết cuộc gọi lại sẽ làm gì?).

Quá nhiệt tình ngăn ngừa bế tắc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bế tắc là một vấn đề nhưng không tệ như hỏng dữ liệu. Mã mà
lấy khóa đọc, tìm kiếm danh sách, không tìm thấy thứ nó muốn, đánh rơi
khóa đọc, lấy khóa ghi và chèn đối tượng có một cuộc đua
điều kiện.

Đồng hồ tính giờ đua xe: Trò tiêu khiển hạt nhân
-------------------------------

Bộ tính giờ có thể tạo ra những vấn đề đặc biệt của riêng họ với các cuộc đua. Hãy xem xét một
tập hợp các đối tượng (danh sách, hàm băm, v.v.) trong đó mỗi đối tượng có bộ đếm thời gian
đó là do phá hủy nó.

Nếu bạn muốn hủy toàn bộ bộ sưu tập (ví dụ như loại bỏ mô-đun),
bạn có thể làm như sau::

/* THIS CODE BAD BAD BAD BAD: NẾU NÓ WAS ANY WORSE NÓ WOULD USE
               HUNGARIAN NOTATION */
            spin_lock_bh(&list_lock);

trong khi (danh sách) {
                    struct foo *next = list->next;
                    time_delete(&list->timer);
                    kfree(danh sách);
                    danh sách = tiếp theo;
            }

spin_unlock_bh(&list_lock);


Sớm hay muộn, điều này sẽ gặp sự cố trên SMP, vì bộ hẹn giờ có thể chỉ
đã tắt trước spin_lock_bh() và nó sẽ chỉ nhận được
khóa sau khi chúng ta quay_unlock_bh(), rồi thử giải phóng
phần tử (đã được giải phóng!).

Điều này có thể tránh được bằng cách kiểm tra kết quả của
time_delete(): nếu trả về 1 thì bộ hẹn giờ đã bị xóa.
Nếu 0, điều đó có nghĩa (trong trường hợp này) là nó hiện đang chạy, vì vậy chúng ta có thể
làm::

thử lại:
                    spin_lock_bh(&list_lock);

trong khi (danh sách) {
                            struct foo *next = list->next;
                            if (!timer_delete(&list->timer)) {
                                    /* Cho bộ đếm thời gian một cơ hội để xóa cái này */
                                    spin_unlock_bh(&list_lock);
                                    hãy thử lại;
                            }
                            kfree(danh sách);
                            danh sách = tiếp theo;
                    }

spin_unlock_bh(&list_lock);


Một vấn đề phổ biến khác là xóa bộ hẹn giờ tự khởi động lại (bằng cách
gọi add_timer() ở cuối chức năng hẹn giờ của chúng).
Vì đây là trường hợp khá phổ biến và dễ bị đua xe nên bạn nên
sử dụng clock_delete_sync() (ZZ0000ZZ) để xử lý trường hợp này.

Trước khi giải phóng bộ hẹn giờ, cần phải có time_shutdown() hoặctimer_shutdown_sync()
được gọi sẽ giữ cho nó không bị tái vũ trang. Bất kỳ nỗ lực tiếp theo nào nhằm
sắp xếp lại bộ hẹn giờ sẽ bị mã lõi âm thầm bỏ qua.


Tốc độ khóa
=============

Có ba điều chính cần lo lắng khi xem xét tốc độ của
một số mã khóa. Đầu tiên là sự đồng thời: có bao nhiêu thứ
sẽ đợi trong khi người khác đang giữ khóa. Thứ hai là
thời gian cần thiết để thực sự có được và giải phóng một khóa không được kiểm soát. Thứ ba là
sử dụng ít hơn hoặc khóa thông minh hơn. Tôi cho rằng khóa được sử dụng công bằng
thường xuyên: nếu không, bạn sẽ không quan tâm đến hiệu quả.

Tính đồng thời phụ thuộc vào thời gian khóa thường được giữ: bạn nên
giữ khóa bao lâu tùy thích, nhưng không còn nữa. Trong bộ đệm
Ví dụ, chúng ta luôn tạo đối tượng mà không cần giữ khóa, sau đó
chỉ lấy khóa khi chúng tôi sẵn sàng chèn nó vào danh sách.

Thời gian thu nhận phụ thuộc vào mức độ thiệt hại của hoạt động khóa đối với
đường ống (các gian hàng trong đường ống) và khả năng chiếc CPU này bị
người cuối cùng lấy khóa (tức là bộ đệm khóa đang nóng cho CPU này):
trên máy có nhiều CPU hơn, khả năng này giảm xuống nhanh chóng. Hãy xem xét một
Intel Pentium III 700 MHz: một lệnh mất khoảng 0,7ns, một nguyên tử
mức tăng mất khoảng 58ns, một khóa nóng trong bộ nhớ đệm trên CPU này mất
160ns và quá trình truyền bộ đệm từ một CPU khác mất thêm 170
đến 360ns. (Những số liệu này từ ZZ0000ZZ của Paul McKenney).

Hai mục đích này xung đột nhau: việc giữ khóa trong thời gian ngắn có thể được thực hiện
bằng cách chia các khóa thành nhiều phần (chẳng hạn như trong khóa mỗi đối tượng cuối cùng của chúng tôi
ví dụ), nhưng điều này làm tăng số lượng mua lại khóa và
kết quả thường chậm hơn so với việc có một khóa duy nhất. Đây là một cái khác
lý do để ủng hộ việc khóa đơn giản.

Mối quan tâm thứ ba được giải quyết dưới đây: có một số phương pháp để giảm
số lượng khóa cần phải được thực hiện.

Các biến thể khóa đọc/ghi
------------------------

Cả spinlock và mutex đều có các biến thể đọc/ghi: ZZ0001ZZ và
ZZ0000ZZ. Những điều này phân chia
người dùng thành hai lớp: người đọc và người viết. Nếu bạn chỉ
đọc dữ liệu, bạn có thể có khóa đọc, nhưng để ghi dữ liệu bạn
cần khóa ghi. Nhiều người có thể giữ khóa đọc, nhưng người viết thì phải
trở thành người nắm giữ duy nhất.

Nếu mã của bạn phân chia gọn gàng dọc theo các dòng đầu đọc/ghi (như mã bộ đệm của chúng tôi
có) và khóa được người đọc giữ trong một khoảng thời gian đáng kể,
sử dụng những ổ khóa này có thể giúp ích. Chúng chậm hơn một chút so với bình thường
mặc dù có khóa, vì vậy trong thực tế ZZ0000ZZ thường không có giá trị.

Tránh bị khóa: Đọc bản cập nhật sao chép
--------------------------------

Có một phương pháp khóa đọc/ghi đặc biệt gọi là Cập nhật bản sao đọc.
Sử dụng RCU, người đọc có thể tránh được việc lấy khóa hoàn toàn: như chúng tôi mong đợi
bộ nhớ đệm của chúng ta cần được đọc thường xuyên hơn là cập nhật (nếu không thì bộ nhớ đệm sẽ là một
lãng phí thời gian), nó là một ứng cử viên cho việc tối ưu hóa này.

Làm thế nào để chúng ta thoát khỏi khóa đọc? Loại bỏ các khóa đọc có nghĩa là
người viết có thể đang thay đổi danh sách bên dưới người đọc. Đó là
thực sự khá đơn giản: chúng ta có thể đọc một danh sách liên kết trong khi một phần tử
được thêm vào nếu người viết thêm phần tử đó một cách cẩn thận. Ví dụ,
thêm ZZ0000ZZ vào một danh sách liên kết duy nhất có tên ZZ0001ZZ::

mới->tiếp theo = danh sách->tiếp theo;
            wmb();
            danh sách->tiếp theo = mới;


wmb() là rào cản bộ nhớ ghi. Nó đảm bảo rằng
thao tác đầu tiên (thiết lập con trỏ ZZ0000ZZ của phần tử mới) đã hoàn tất
và sẽ được tất cả các CPU nhìn thấy trước khi thao tác thứ hai được thực hiện (đặt
phần tử mới vào danh sách). Điều này rất quan trọng vì hiện đại
trình biên dịch và CPU hiện đại đều có thể sắp xếp lại các lệnh trừ khi được yêu cầu
mặt khác: chúng tôi muốn người đọc hoàn toàn không nhìn thấy phần tử mới hoặc
xem phần tử mới có con trỏ ZZ0001ZZ trỏ chính xác vào
phần còn lại của danh sách.

May mắn thay, có một chức năng để thực hiện việc này cho tiêu chuẩn
Danh sách ZZ0000ZZ:
danh sách_add_rcu() (ZZ0001ZZ).

Việc xóa một phần tử khỏi danh sách thậm chí còn đơn giản hơn: chúng ta thay thế
con trỏ tới phần tử cũ bằng con trỏ tới phần tử kế tiếp của nó và trình đọc
sẽ nhìn thấy nó hoặc bỏ qua nó.

::

danh sách->tiếp theo = cũ->tiếp theo;


Có list_del_rcu() (ZZ0000ZZ)
thực hiện điều này (phiên bản bình thường đầu độc đối tượng cũ, điều mà chúng tôi không làm
muốn).

Người đọc cũng phải cẩn thận: một số CPU có thể xem qua ZZ0000ZZ
con trỏ để bắt đầu đọc nội dung của phần tử tiếp theo sớm, nhưng
không nhận ra rằng nội dung được tìm nạp trước là sai khi ZZ0001ZZ
con trỏ thay đổi bên dưới chúng. Một lần nữa, có một
list_for_each_entry_rcu() (ZZ0002ZZ)
để giúp bạn. Tất nhiên, người viết chỉ có thể sử dụng
list_for_each_entry(), vì không thể có hai
các nhà văn đồng thời

Vấn đề nan giải cuối cùng của chúng ta là: khi nào chúng ta thực sự có thể phá hủy những thứ đã bị loại bỏ?
phần tử? Hãy nhớ rằng, người đọc có thể lướt qua phần này trong
danh sách ngay bây giờ: nếu chúng ta giải phóng phần tử này và con trỏ ZZ0000ZZ
thay đổi, người đọc sẽ rơi vào thùng rác và gặp sự cố. Chúng ta cần phải
đợi cho đến khi chúng tôi biết rằng tất cả độc giả đã duyệt qua danh sách
khi chúng tôi xóa phần tử là xong. Chúng tôi sử dụng
call_rcu() để đăng ký một cuộc gọi lại thực sự sẽ
hủy đối tượng sau khi tất cả các trình đọc có sẵn đã hoàn tất.
Ngoài ra, sync_rcu() có thể được sử dụng để chặn
cho đến khi tất cả những gì có sẵn đã hoàn tất.

Nhưng làm thế nào để Read Copy Update biết khi nào người đọc đọc xong? các
phương pháp là thế này: thứ nhất, người đọc luôn duyệt qua danh sách bên trong
Các cặp rcu_read_lock()/rcu_read_unlock():
những điều này chỉ đơn giản là vô hiệu hóa quyền ưu tiên để người đọc không ngủ trong khi
đọc danh sách.

RCU sau đó đợi cho đến khi mọi CPU khác đã ngủ ít nhất một lần: kể từ
độc giả không thể ngủ được, chúng tôi biết rằng bất kỳ độc giả nào đang duyệt qua
danh sách trong quá trình xóa hoàn tất và lệnh gọi lại được kích hoạt.
Mã Cập nhật bản sao đọc thực sự được tối ưu hóa hơn thế này một chút, nhưng
đây là ý tưởng cơ bản.

::

--- cache.c.perobjectlock 2003-12-11 17:15:03.000000000 +1100
    +++ cache.c.rcupdate 2003-12-11 17:55:14.000000000 +1100
    @@ -1,15 +1,18 @@
     #include <linux/list.h>
     #include <linux/slab.h>
     #include <linux/string.h>
    +#include <linux/rcupdate.h>
     #include <linux/mutex.h>
     #include <asm/errno.h>

đối tượng cấu trúc
     {
    - /* Hai cái này được bảo vệ bởi cache_lock. */
    + /* Điều này được bảo vệ bởi RCU */
             danh sách struct list_head;
             int phổ biến;

+ struct rcu_head rcu;
    +
             nguyên tử_t phản ánh;

/* Không thay đổi khi được tạo. */
    @@ -40,7 +43,7 @@
     {
             đối tượng cấu trúc *i;

- list_for_each_entry(i, &cache, list) {
    + list_for_each_entry_rcu(i, &cache, list) {
                     nếu (i->id == id) {
                             i->sự nổi tiếng++;
                             trả lại tôi;
    @@ -49,19 +52,25 @@
             trả lại NULL;
     }

+/* Việc loại bỏ cuối cùng được thực hiện khi chúng tôi biết không có độc giả nào đang tìm kiếm. */
    +static void cache_delete_rcu(void *arg)
    +{
    + object_put(arg);
    +}
    +
     /* Phải giữ cache_lock */
     static void __cache_delete(đối tượng struct *obj)
     {
             BUG_ON(!obj);
    - list_del(&obj->list);
    - object_put(obj);
    + list_del_rcu(&obj->list);
             cache_num--;
    + call_rcu(&obj->rcu, cache_delete_rcu);
     }

/* Phải giữ cache_lock */
     khoảng trống tĩnh __cache_add(đối tượng cấu trúc *obj)
     {
    - list_add(&obj->list, &cache);
    + list_add_rcu(&obj->list, &cache);
             nếu (++cache_num > MAX_CACHE_SIZE) {
                     đối tượng cấu trúc *i, *outcast = NULL;
                     list_for_each_entry(i, &cache, list) {
    @@ -104,12 +114,11 @@
     đối tượng cấu trúc *cache_find(int id)
     {
             đối tượng cấu trúc *obj;
    - cờ dài không dấu;

- spin_lock_irqsave(&cache_lock, cờ);
    + rcu_read_lock();
             obj = __cache_find(id);
             nếu (obj)
                     object_get(obj);
    - spin_unlock_irqrestore(&cache_lock, flag);
    + rcu_read_unlock();
             trả lại đối tượng;
     }

Lưu ý rằng người đọc sẽ thay đổi thành phần phổ biến trong
__cache_find() và hiện tại nó không có khóa. một
giải pháp là biến nó thành ZZ0000ZZ, nhưng với cách sử dụng này, chúng tôi
không thực sự quan tâm đến các cuộc đua: một kết quả gần đúng là đủ tốt, vì vậy
Tôi đã không thay đổi nó.

Kết quả là cache_find() không yêu cầu
đồng bộ hóa với bất kỳ chức năng nào khác, tốc độ trên SMP gần như nhanh như
nó sẽ ở trên UP.

Có thể tối ưu hóa thêm ở đây: hãy nhớ bản gốc của chúng tôi
mã bộ đệm, nơi không có số lượng tham chiếu và người gọi chỉ cần
giữ khóa bất cứ khi nào sử dụng đối tượng? Điều này vẫn có thể xảy ra: nếu bạn
giữ khóa, không ai có thể xóa đối tượng, vì vậy bạn không cần phải lấy
và đặt số lượng tham chiếu.

Bây giờ, vì 'khóa đọc' trong RCU chỉ đơn giản là vô hiệu hóa quyền ưu tiên, một
người gọi luôn bị vô hiệu hóa quyền ưu tiên giữa các cuộc gọi
cache_find() và object_put() thì không
thực sự cần lấy và đặt số lượng tham chiếu: chúng ta có thể phơi bày
__cache_find() bằng cách làm cho nó không tĩnh, v.v.
người gọi có thể chỉ cần gọi như vậy.

Lợi ích ở đây là số lượng tham chiếu không được ghi vào:
đối tượng không bị thay đổi theo bất kỳ cách nào, nhanh hơn nhiều trên máy SMP
do bộ nhớ đệm.

Dữ liệu trên mỗi CPU
------------

Một kỹ thuật khác để tránh bị khóa được sử dụng khá rộng rãi là
thông tin trùng lặp cho mỗi CPU. Ví dụ: nếu bạn muốn giữ một
đếm một tình trạng phổ biến, bạn có thể sử dụng một khóa xoay và một
quầy. Đẹp và đơn giản.

Nếu tốc độ đó quá chậm (thường là không, nhưng nếu bạn có tốc độ thực sự lớn
máy để kiểm tra và có thể cho thấy điều đó), thay vào đó bạn có thể sử dụng
bộ đếm cho mỗi CPU, thì không cái nào trong số chúng cần một khóa độc quyền. Xem
DEFINE_PER_CPU(), get_cpu_var() và
put_cpu_var() (ZZ0000ZZ).

Việc sử dụng cụ thể cho các bộ đếm trên mỗi CPU đơn giản là loại ZZ0000ZZ,
và cpu_local_inc() và các hàm liên quan, đó là
hiệu quả hơn mã đơn giản trên một số kiến trúc
(ZZ0001ZZ).

Lưu ý rằng không có cách nào đơn giản và đáng tin cậy để có được giá trị chính xác của
một bộ đếm như vậy mà không cần giới thiệu thêm ổ khóa. Đây không phải là vấn đề
cho một số mục đích sử dụng.

Dữ liệu được sử dụng chủ yếu bởi Trình xử lý IRQ
----------------------------------------

Nếu dữ liệu luôn được truy cập từ bên trong cùng một trình xử lý IRQ, thì bạn không
cần một khóa nào cả: hạt nhân đã đảm bảo rằng trình xử lý irq
sẽ không chạy đồng thời trên nhiều CPU.

Manfred Spraul chỉ ra rằng bạn vẫn có thể làm điều này, ngay cả khi dữ liệu
đôi khi được truy cập trong ngữ cảnh người dùng hoặc softirqs/tasklets. các
Trình xử lý irq không sử dụng khóa và tất cả các truy cập khác được thực hiện như vậy ::

mutex_lock(&lock);
        vô hiệu hóa_irq(irq);
        ...
Enable_irq(irq);
        mutex_unlock(&lock);

Vô hiệu hóa_irq() ngăn trình xử lý irq chạy
(và đợi nó kết thúc nếu nó hiện đang chạy trên các CPU khác).
Spinlock ngăn chặn bất kỳ truy cập nào khác xảy ra cùng một lúc.
Đương nhiên, điều này chậm hơn chỉ một spin_lock_irq()
gọi, vì vậy sẽ chỉ có ý nghĩa nếu kiểu truy cập này xảy ra cực kỳ
hiếm khi.

Những chức năng nào an toàn để gọi từ các ngắt?
================================================

Nhiều hàm trong kernel ngủ (tức là gọi lịch trình()) trực tiếp hoặc
gián tiếp: bạn không bao giờ có thể gọi họ khi đang giữ spinlock hoặc với
quyền ưu tiên bị vô hiệu hóa. Điều này cũng có nghĩa là bạn cần phải ở trong bối cảnh của người dùng:
gọi họ từ một sự gián đoạn là bất hợp pháp.

Một số chức năng ngủ
--------------------------

Những cái phổ biến nhất được liệt kê dưới đây, nhưng bạn thường phải đọc
mã để tìm hiểu xem các cuộc gọi khác có an toàn không. Nếu những người khác gọi nó
ngủ được, có lẽ bạn cũng cần ngủ được. Đặc biệt,
chức năng đăng ký và hủy đăng ký thường được gọi là
khỏi ngữ cảnh của người dùng và có thể ngủ.

- Truy cập vào không gian người dùng:

- copy_from_user()

- sao chép_to_user()

- get_user()

- put_user()

- kmalloc(GP_KERNEL) <kmalloc>`

- mutex_lock_interruptible() và
   mutex_lock()

Có một mutex_trylock() không ngủ.
   Tuy nhiên, nó không được sử dụng bên trong ngữ cảnh ngắt vì nó
   việc thực hiện không an toàn cho điều đó. mutex_unlock()
   cũng sẽ không bao giờ ngủ. Nó cũng không thể được sử dụng trong bối cảnh ngắt
   vì một mutex phải được giải phóng bởi cùng một tác vụ đã thu được nó.

Một số chức năng không ngủ
--------------------------------

Một số chức năng có thể gọi an toàn từ bất kỳ ngữ cảnh nào hoặc giữ hầu hết mọi chức năng.
khóa.

- printk()

- kfree()

- add_timer() và hẹn giờ_delete()

Tham khảo Mutex API
===================

.. kernel-doc:: include/linux/mutex.h
   :internal:

.. kernel-doc:: kernel/locking/mutex.c
   :export:

Tài liệu tham khảo Futex API
===================

.. kernel-doc:: kernel/futex/core.c
   :internal:

.. kernel-doc:: kernel/futex/futex.h
   :internal:

.. kernel-doc:: kernel/futex/pi.c
   :internal:

.. kernel-doc:: kernel/futex/requeue.c
   :internal:

.. kernel-doc:: kernel/futex/waitwake.c
   :internal:

Đọc thêm
===============

- ZZ0000ZZ: Khóa xoay của Linus Torvalds
   hướng dẫn trong các nguồn kernel.

- Hệ thống Unix cho kiến trúc hiện đại: Đa xử lý đối xứng và
   Bộ nhớ đệm dành cho lập trình viên hạt nhân:

Lời giới thiệu rất hay của Curt Schimmel về khóa cấp độ kernel (không phải
   được viết cho Linux, nhưng gần như mọi thứ đều có thể áp dụng được). Cuốn sách là
   đắt tiền nhưng thực sự đáng giá từng xu để hiểu về khóa SMP.
   [ISBN: 0201633388]

Cảm ơn
======

Cảm ơn Telsa Gwynne vì DocBooking đã làm gọn gàng và bổ sung thêm phong cách.

Cảm ơn Martin Pool, Philipp Rumpf, Stephen Rothwell, Paul Mackerras,
Ruedi Aschwanden, Alan Cox, Manfred Spraul, Tim Waugh, Pete Zaitcev,
James Morris, Robert Love, Paul McKenney, John Ashby đã hiệu đính,
chữa bài, nhận xét, nhận xét.

Cảm ơn hội vì không có ảnh hưởng đến tài liệu này.

Thuật ngữ
========

quyền ưu tiên
  Trước 2.5 hoặc khi ZZ0000ZZ không được đặt, xử lý trong người dùng
  bối cảnh bên trong kernel sẽ không ưu tiên lẫn nhau (tức là bạn đã có cái đó
  CPU cho đến khi bạn từ bỏ nó, ngoại trừ những lần bị gián đoạn). Với việc bổ sung
  ZZ0001ZZ trong 2.5.4, điều này đã thay đổi: khi ở trong ngữ cảnh của người dùng, giá trị cao hơn
  các nhiệm vụ ưu tiên có thể "cắt ngang": các khóa xoay đã được thay đổi thành vô hiệu hóa
  quyền ưu tiên, ngay cả trên UP.

bh
  Nửa dưới: vì lý do lịch sử, thường có '_bh' trong đó
  bây giờ hãy đề cập đến bất kỳ phần mềm nào bị gián đoạn, ví dụ: spin_lock_bh()
  chặn mọi gián đoạn phần mềm trên CPU hiện tại. Nửa dưới là
  không được dùng nữa và cuối cùng sẽ được thay thế bằng các tác vụ nhỏ. Chỉ có một đáy
  một nửa sẽ chạy bất cứ lúc nào.

Ngắt phần cứng / Phần cứng IRQ
  Yêu cầu ngắt phần cứng. in_hardirq() trả về true trong
  xử lý ngắt phần cứng.

Bối cảnh ngắt
  Không phải bối cảnh người dùng: xử lý irq phần cứng hoặc irq phần mềm. được chỉ định
  bởi macro in_interrupt() trả về true.

SMP
  Bộ xử lý đa bộ đối xứng: hạt nhân được biên dịch cho nhiều máy CPU.
  (ZZ0000ZZ).

Ngắt phần mềm / softirq
  Phần mềm xử lý ngắt. in_hardirq() trả về sai;
  in_softirq() trả về đúng. Cả tasklets và softirq đều
  rơi vào danh mục 'ngắt phần mềm'.

Nói đúng ra softirq là một trong 32 phần mềm được liệt kê
  các ngắt có thể chạy trên nhiều CPU cùng một lúc. Đôi khi đã quen
  cũng đề cập đến các tác vụ nhỏ (tức là tất cả các phần mềm bị gián đoạn).

tập nhiệm vụ
  Một ngắt phần mềm có thể đăng ký động, được đảm bảo
  mỗi lần chỉ chạy trên một CPU.

hẹn giờ
  Một ngắt phần mềm có thể đăng ký động, được chạy ở (hoặc đóng
  đến) một thời điểm nhất định. Khi chạy, nó giống như một tasklet (thực tế là chúng
  được gọi từ ZZ0000ZZ).

LÊN
  Bộ xử lý đơn: Non-SMP. (ZZ0000ZZ).

Bối cảnh người dùng
  Kernel thực thi thay mặt cho một tiến trình cụ thể (tức là một hệ thống
  gọi hoặc bẫy) hoặc luồng hạt nhân. Bạn có thể biết quá trình nào với
  Macro ZZ0000ZZ.) Đừng nhầm lẫn với không gian người dùng. có thể
  bị gián đoạn bởi sự gián đoạn phần mềm hoặc phần cứng.

Không gian người dùng
  Một tiến trình thực thi mã riêng của nó bên ngoài kernel.
