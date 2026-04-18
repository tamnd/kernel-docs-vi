.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kernel-hacking/hacking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernel_hacking_hack:

===================================================
Hướng dẫn không đáng tin cậy để hack hạt nhân Linux
===================================================

:Tác giả: Rusty Russell

Giới thiệu
============

Chào mừng độc giả thân mến đến với Hướng dẫn về Linux không đáng tin cậy đáng chú ý của Rusty
Hack hạt nhân. Tài liệu này mô tả các hoạt động thông thường và các
yêu cầu đối với mã hạt nhân: mục tiêu của nó là dùng làm mồi cho Linux
phát triển kernel cho các lập trình viên C có kinh nghiệm. Tôi tránh thực hiện
chi tiết: đó là mục đích của mã và tôi bỏ qua toàn bộ phần của
thói quen hữu ích.

Trước khi bạn đọc điều này, hãy hiểu rằng tôi không bao giờ muốn viết
tài liệu này, hoàn toàn không đủ tiêu chuẩn, nhưng tôi luôn muốn
đọc nó, và đây là cách duy nhất. Tôi hy vọng nó sẽ phát triển thành một
bản tóm tắt các phương pháp hay nhất, điểm khởi đầu chung và ngẫu nhiên
thông tin.

các cầu thủ
===========

Tại bất kỳ thời điểm nào, mỗi CPU trong hệ thống có thể:

- không liên quan đến bất kỳ quy trình nào, phục vụ ngắt phần cứng;

- không liên quan đến bất kỳ quy trình nào, phục vụ phần mềm hoặc tasklet;

- chạy trong không gian kernel, được liên kết với một tiến trình (ngữ cảnh người dùng);

- chạy một tiến trình trong không gian người dùng.

Có một thứ tự giữa những điều này. Hai người dưới cùng có thể giành quyền trước
khác, nhưng trên đó là một hệ thống phân cấp chặt chẽ: mỗi cái chỉ có thể được ưu tiên
bởi những cái ở trên nó. Ví dụ: trong khi softirq đang chạy trên CPU,
không có softirq nào khác có thể sử dụng trước nó, nhưng một phần cứng có thể làm gián đoạn. Tuy nhiên,
bất kỳ CPU nào khác trong hệ thống đều thực thi độc lập.

Chúng ta sẽ thấy một số cách mà ngữ cảnh người dùng có thể chặn các ngắt,
trở nên thực sự không thể đánh trước được.

Bối cảnh người dùng
-------------------

Bối cảnh của người dùng là khi bạn đến từ một cuộc gọi hệ thống hoặc cái bẫy khác:
giống như không gian người dùng, bạn có thể được ưu tiên thực hiện các nhiệm vụ quan trọng hơn và
ngắt quãng. Bạn có thể ngủ bằng cách gọi lịch trình().

.. note::

    You are always in user context on module load and unload, and on
    operations on the block device layer.

Trong ngữ cảnh người dùng, con trỏ ZZ0000ZZ (cho biết nhiệm vụ chúng ta đang thực hiện
hiện đang thực thi) là hợp lệ và in_interrupt()
(ZZ0001ZZ) là sai.

.. warning::

    Beware that if you have preemption or softirqs disabled (see below),
    in_interrupt() will return a false positive.

Ngắt phần cứng (IRQ cứng)
-------------------------------

Tích tắc hẹn giờ, card mạng và bàn phím là những ví dụ về phần cứng thực
tạo ra sự gián đoạn bất cứ lúc nào. Kernel chạy ngắt
trình xử lý, phục vụ phần cứng. Hạt nhân đảm bảo rằng điều này
trình xử lý không bao giờ được nhập lại: nếu cùng một ngắt đến, nó sẽ được xếp hàng đợi
(hoặc bị đánh rơi). Vì nó vô hiệu hóa các ngắt nên trình xử lý này phải được
nhanh: thường thì nó chỉ đơn giản là xác nhận sự gián đoạn, đánh dấu một 'phần mềm
ngắt' để thực thi và thoát.

Bạn có thể biết bạn đang bị gián đoạn phần cứng, vì in_hardirq() trả về
đúng.

.. warning::

    Beware that this will return a false positive if interrupts are
    disabled (see below).

Bối cảnh ngắt phần mềm: Softirqs và Tasklets
-------------------------------------------------

Bất cứ khi nào một cuộc gọi hệ thống sắp quay trở lại không gian người dùng hoặc phần cứng
thoát trình xử lý ngắt, mọi 'ngắt phần mềm' được đánh dấu
đang chờ xử lý (thường là do ngắt phần cứng) được chạy (ZZ0000ZZ).

Phần lớn công việc xử lý ngắt thực sự được thực hiện ở đây. Sớm trong
chuyển sang SMP, chỉ có 'nửa dưới' (BH), không có
tận dụng nhiều CPU. Ngay sau khi chúng tôi chuyển từ chế độ gió lên
máy tính làm từ que diêm và nước mũi, chúng ta đã từ bỏ giới hạn này
và chuyển sang 'softirqs'.

ZZ0000ZZ liệt kê các phần mềm khác nhau. Rất
softirq quan trọng là softirq hẹn giờ (ZZ0001ZZ): bạn
có thể đăng ký để nó gọi các chức năng cho bạn trong khoảng thời gian nhất định
thời gian.

Softirq thường khó xử lý vì cùng một softirq sẽ chạy
đồng thời trên nhiều CPU. Vì lý do này, các tasklet
(ZZ0000ZZ) thường được sử dụng nhiều hơn: chúng là
có thể đăng ký động (có nghĩa là bạn có thể có bao nhiêu tùy thích) và
họ cũng đảm bảo rằng bất kỳ tasklet nào cũng sẽ chỉ chạy trên một CPU bất kỳ lúc nào.
thời gian, mặc dù các tác vụ khác nhau có thể chạy đồng thời.

.. warning::

    The name 'tasklet' is misleading: they have nothing to do with
    'tasks'.

Bạn có thể biết mình đang ở trong softirq (hoặc tasklet) bằng cách sử dụng
macro in_softirq() (ZZ0000ZZ).

.. warning::

    Beware that this will return a false positive if a
    :ref:`bottom half lock <local_bh_disable>` is held.

Một số quy tắc cơ bản
=====================

Không bảo vệ bộ nhớ
    Nếu bạn làm hỏng bộ nhớ, cho dù trong bối cảnh người dùng hay bối cảnh gián đoạn,
    toàn bộ máy sẽ bị hỏng. Bạn có chắc là bạn không thể làm được điều bạn
    muốn trong không gian người dùng?

Không có dấu phẩy động hoặc MMX
    Bối cảnh FPU không được lưu; ngay cả trong bối cảnh người dùng, trạng thái FPU
    có thể sẽ không tương ứng với quy trình hiện tại: bạn sẽ làm rối tung
    với trạng thái FPU của một số quy trình người dùng. Nếu bạn thực sự muốn làm điều này,
    bạn sẽ phải lưu/khôi phục đầy đủ trạng thái FPU một cách rõ ràng (và
    tránh chuyển đổi ngữ cảnh). Nói chung đó là một ý tưởng tồi; sử dụng điểm cố định
    số học đầu tiên.

Giới hạn ngăn xếp cứng nhắc
    Tùy thuộc vào các tùy chọn cấu hình, ngăn xếp hạt nhân có dung lượng khoảng 3K đến
    6K cho hầu hết kiến trúc 32-bit: khoảng 14K trên hầu hết kiến trúc 64-bit
    vòm và thường được chia sẻ với các ngắt nên bạn không thể sử dụng hết.
    Tránh đệ quy sâu và mảng cục bộ lớn trên ngăn xếp (phân bổ
    thay vào đó chúng sẽ động).

Nhân Linux có thể mang theo được
    Hãy giữ nó như vậy. Mã của bạn phải sạch 64-bit và
    độc lập với endian. Bạn cũng nên giảm thiểu những nội dung cụ thể của CPU,
    ví dụ: lắp ráp nội tuyến phải được đóng gói sạch sẽ và giảm thiểu đến mức
    chuyển cổng dễ dàng. Nói chung nó nên được giới hạn ở
    phần phụ thuộc vào kiến trúc của cây hạt nhân.

ioctls: Không viết cuộc gọi hệ thống mới
========================================

Một cuộc gọi hệ thống thường trông như thế này::

asmlinkage dài sys_mycall(int arg)
    {
            trả về 0;
    }


Đầu tiên, trong hầu hết các trường hợp, bạn không muốn tạo cuộc gọi hệ thống mới. bạn
tạo một thiết bị ký tự và triển khai ioctl thích hợp cho nó.
Điều này linh hoạt hơn nhiều so với các cuộc gọi hệ thống, không cần phải nhập
trong ZZ0000ZZ của mọi kiến trúc và
ZZ0001ZZ và có nhiều khả năng được chấp nhận hơn
Linus.

Nếu tất cả công việc thường ngày của bạn là đọc hoặc ghi một số tham số, hãy xem xét
thay vào đó, hãy triển khai giao diện sysfs().

Bên trong ioctl, bạn đang ở trong bối cảnh người dùng của một quy trình. Khi có lỗi
xảy ra, bạn trả về một lỗi bị phủ định (xem
ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ),
nếu không bạn trả về 0.

Sau khi ngủ bạn nên kiểm tra xem có tín hiệu nào xuất hiện không: Unix/Linux
cách xử lý tín hiệu là tạm thời thoát khỏi cuộc gọi hệ thống bằng
Lỗi ZZ0000ZZ. Mã nhập cuộc gọi hệ thống sẽ chuyển về
ngữ cảnh người dùng, xử lý bộ xử lý tín hiệu và sau đó lệnh gọi hệ thống của bạn sẽ
được khởi động lại (trừ khi người dùng tắt tính năng đó). Vì vậy bạn nên chuẩn bị
để xử lý việc khởi động lại, ví dụ: nếu bạn đang trong quá trình thao túng
một số cấu trúc dữ liệu.

::

if (signal_pending(current))
            trả về -ERESTARTSYS;


Nếu bạn đang thực hiện các phép tính dài hơn: trước tiên hãy nghĩ đến không gian người dùng. Nếu bạn
ZZ0000ZZ muốn làm điều đó trong kernel bạn nên thường xuyên kiểm tra nếu cần
từ bỏ CPU (hãy nhớ rằng CPU có tính năng đa nhiệm hợp tác).
Thành ngữ::

cond_resched(); /*Sẽ ngủ*/


Một lưu ý ngắn về thiết kế giao diện: phương châm gọi hệ thống UNIX là "Cung cấp
cơ chế chứ không phải chính sách”.

Bí quyết cho sự bế tắc
======================

Bạn không thể gọi bất kỳ quy trình nào có thể ngủ, trừ khi:

- Bạn đang ở trong bối cảnh người dùng.

- Bạn không sở hữu bất kỳ spinlock nào.

- Bạn đã kích hoạt tính năng ngắt (thực ra, Andi Kleen nói rằng
   mã lập kế hoạch sẽ kích hoạt chúng cho bạn, nhưng điều đó có thể không
   những gì bạn muốn).

Lưu ý rằng một số chức năng có thể ngủ ngầm: những chức năng phổ biến là người dùng
hàm truy cập không gian (\*_user) và hàm cấp phát bộ nhớ
không có ZZ0000ZZ.

Bạn phải luôn biên dịch kernel ZZ0000ZZ của mình trên,
và nó sẽ cảnh báo bạn nếu bạn vi phạm các quy tắc này. Nếu bạn ZZ0001ZZ phá vỡ
quy tắc, cuối cùng bạn sẽ khóa hộp của bạn.

Thật sự.

Thói quen chung
===============

printk()
--------

Được xác định trong ZZ0000ZZ

printk() cung cấp các thông báo kernel tới bàn điều khiển, dmesg và
daemon nhật ký hệ thống. Nó rất hữu ích cho việc gỡ lỗi và báo cáo lỗi, và
có thể được sử dụng bên trong ngữ cảnh ngắt, nhưng hãy thận trọng khi sử dụng: một cái máy
bảng điều khiển chứa đầy thông báo printk không thể sử dụng được. Nó sử dụng
một chuỗi định dạng hầu như tương thích với ANSI C printf và chuỗi C
nối để cung cấp cho nó đối số "ưu tiên" đầu tiên::

printk(KERN_INFO "i = %u\n", i);


Xem ZZ0000ZZ; đối với các giá trị ZZ0001ZZ khác; đây là
được syslog hiểu là cấp độ. Trường hợp đặc biệt: để in IP
sử dụng địa chỉ::

__be32 ipaddress;
    printk(KERN_INFO "ip của tôi: %pI4\n", &ipaddress);


printk() sử dụng bộ đệm 1K bên trong và không bắt được
vượt quá. Hãy chắc chắn rằng điều đó sẽ là đủ.

.. note::

    You will know when you are a real kernel hacker when you start
    typoing printf as printk in your user programs :)

.. note::

    Another sidenote: the original Unix Version 6 sources had a comment
    on top of its printf function: "Printf should not be used for
    chit-chat". You should follow that advice.

copy_to_user() / copy_from_user() / get_user() / put_user()
-----------------------------------------------------------

Được xác định trong ZZ0000ZZ / ZZ0001ZZ

ZZ0000ZZ

put_user() và get_user() được sử dụng để lấy
và đặt các giá trị đơn lẻ (chẳng hạn như int, char hoặc long) từ và tới
không gian người dùng. Một con trỏ vào không gian người dùng không bao giờ được hủy đăng ký đơn giản:
dữ liệu nên được sao chép bằng cách sử dụng các thói quen này. Cả hai đều trả về ZZ0000ZZ hoặc
0.

copy_to_user() và copy_from_user() là
tổng quát hơn: họ sao chép một lượng dữ liệu tùy ý đến và đi từ
không gian người dùng.

.. warning::

    Unlike put_user() and get_user(), they
    return the amount of uncopied data (ie. 0 still means success).

[Vâng, giao diện khó chịu này làm tôi khó chịu. Cuộc chiến tranh lửa đến
lên mỗi năm hoặc lâu hơn. --RR.]

Các chức năng có thể ngủ ngầm. Điều này không bao giờ nên được gọi bên ngoài
bối cảnh người dùng (điều này vô nghĩa), với các ngắt bị vô hiệu hóa hoặc
spinlock được giữ.

kmalloc()/kfree()
-----------------

Được xác định trong ZZ0000ZZ

ZZ0000ZZ

Các thủ tục này được sử dụng để yêu cầu động các đoạn được căn chỉnh bằng con trỏ của
bộ nhớ, như malloc và free trong không gian người dùng, nhưng
kmalloc() nhận thêm một từ gắn cờ. Các giá trị quan trọng:

ZZ0000ZZ
    Có thể ngủ và trao đổi để giải phóng bộ nhớ. Chỉ được phép trong ngữ cảnh của người dùng, nhưng
    là cách đáng tin cậy nhất để cấp phát bộ nhớ.

ZZ0000ZZ
    Đừng ngủ. Ít tin cậy hơn ZZ0001ZZ, nhưng có thể được gọi là
    từ bối cảnh gián đoạn. Bạn nên có ZZ0002ZZ tốt
    chiến lược xử lý lỗi hết bộ nhớ.

ZZ0000ZZ
    Phân bổ ISA DMA thấp hơn 16MB. Nếu bạn không biết đó là bạn
    không cần nó. Rất không đáng tin cậy.

Nếu bạn thấy chức năng ngủ được gọi từ cảnh báo ngữ cảnh không hợp lệ
thì có thể bạn đã gọi hàm phân bổ chế độ ngủ từ
bối cảnh ngắt mà không có ZZ0000ZZ. Bạn thực sự nên khắc phục điều đó.
Chạy, đừng đi bộ.

Nếu bạn đang phân bổ ít nhất ZZ0000ZZ (ZZ0001ZZ hoặc
ZZ0002ZZ), hãy cân nhắc sử dụng __get_free_pages()
(ZZ0003ZZ). Nó nhận một đối số thứ tự (0 cho kích thước trang,
1 cho trang đôi, 2 cho bốn trang, v.v.) và cùng mức ưu tiên bộ nhớ
cờ từ như trên.

Nếu bạn đang phân bổ nhiều hơn một byte có giá trị trang, bạn có thể sử dụng
vmalloc(). Nó sẽ phân bổ bộ nhớ ảo trong kernel
bản đồ. Khối này không liền kề trong bộ nhớ vật lý, nhưng MMU tạo ra
có vẻ như nó dành cho bạn (vì vậy nó sẽ chỉ trông liền kề với CPU,
không cho trình điều khiển thiết bị bên ngoài). Nếu bạn thực sự cần vật chất lớn
bộ nhớ liền kề cho một số thiết bị lạ, bạn gặp vấn đề: đó là
được hỗ trợ kém trong Linux vì sau một thời gian bị phân mảnh bộ nhớ
trong kernel đang chạy làm cho nó khó khăn. Cách tốt nhất là phân bổ khối
sớm trong quá trình khởi động thông qua alloc_bootmem()
thường lệ.

Trước khi phát minh ra bộ nhớ đệm của riêng bạn cho các đối tượng thường được sử dụng, hãy cân nhắc việc sử dụng một
bộ đệm phiến trong ZZ0000ZZ

hiện hành
---------

Được xác định trong ZZ0000ZZ

Biến toàn cục này (thực sự là macro) chứa một con trỏ tới giá trị hiện tại
cấu trúc tác vụ, do đó chỉ hợp lệ trong ngữ cảnh của người dùng. Ví dụ, khi một
tiến trình thực hiện lời gọi hệ thống, điều này sẽ chỉ ra cấu trúc nhiệm vụ của
quá trình gọi điện. Đó là ZZ0000ZZ trong bối cảnh ngắt.

mdelay()/udelay()
-----------------

Được xác định trong ZZ0000ZZ / ZZ0001ZZ

Các hàm udelay() và ndelay() có thể
được sử dụng cho những khoảng dừng nhỏ. Không sử dụng các giá trị lớn với chúng vì bạn có nguy cơ
tràn - hàm trợ giúp mdelay() rất hữu ích ở đây, hoặc
hãy xem xét msleep().

cpu_to_be32()/be32_to_cpu()/cpu_to_le32()/le32_to_cpu()
-------------------------------------------------------

Được xác định trong ZZ0000ZZ

Họ cpu_to_be32() (trong đó "32" có thể được thay thế
bằng 64 hoặc 16, và "be" có thể được thay thế bằng "le") là cách chung
để thực hiện chuyển đổi endian trong kernel: chúng trả về giá trị được chuyển đổi.
Tất cả các biến thể cũng cung cấp điều ngược lại:
be32_to_cpu(), v.v.

Có hai biến thể chính của các hàm này: con trỏ
biến thể, chẳng hạn như cpu_to_be32p(), lấy một con trỏ
về loại đã cho và trả về giá trị được chuyển đổi. Biến thể khác
là họ "tại chỗ", chẳng hạn như cpu_to_be32s(),
chuyển đổi giá trị được con trỏ tham chiếu và trả về khoảng trống.

local_irq_save()/local_irq_restore()
------------------------------------

Được xác định trong ZZ0000ZZ

Các quy trình này vô hiệu hóa các ngắt cứng trên CPU cục bộ và khôi phục
họ. Họ đang quay trở lại; lưu trạng thái trước đó vào trạng thái của họ
Đối số ZZ0000ZZ. Nếu bạn biết rằng ngắt là
được bật, bạn chỉ cần sử dụng local_irq_disable() và
local_irq_enable().

.. _local_bh_disable:

local_bh_disable()/local_bh_enable()
------------------------------------

Được xác định trong ZZ0000ZZ


Các quy trình này vô hiệu hóa các ngắt mềm trên CPU cục bộ và khôi phục
họ. Họ đang quay trở lại; nếu các ngắt mềm đã bị vô hiệu hóa trước đó, chúng
vẫn sẽ bị vô hiệu hóa sau khi cặp chức năng này được gọi.
Chúng ngăn không cho softirq và tasklets chạy trên CPU hiện tại.

smp_processor_id()
------------------

Được xác định trong ZZ0000ZZ

get_cpu() vô hiệu hóa quyền ưu tiên (vì vậy bạn sẽ không đột nhiên nhận được
được chuyển sang CPU khác) và trả về số bộ xử lý hiện tại, trong khoảng từ
0 và ZZ0000ZZ. Lưu ý rằng các số CPU không nhất thiết phải
liên tục. Bạn trả lại nó bằng put_cpu() khi bạn
đã xong.

Nếu bạn biết bạn không thể bị ưu tiên bởi một nhiệm vụ khác (tức là bạn đang ở trong
làm gián đoạn bối cảnh hoặc bị vô hiệu hóa quyền ưu tiên), bạn có thể sử dụng
smp_processor_id().

ZZ0000ZZ/ZZ0001ZZ/ZZ0002ZZ
------------------------------------

Được xác định trong ZZ0000ZZ

Sau khi khởi động, kernel sẽ giải phóng một phần đặc biệt; chức năng được đánh dấu bằng
ZZ0000ZZ và cấu trúc dữ liệu được đánh dấu bằng ZZ0001ZZ bị loại bỏ
sau khi khởi động xong: các mô-đun tương tự sẽ loại bỏ bộ nhớ này sau
khởi tạo. ZZ0002ZZ được sử dụng để khai báo một hàm chỉ
bắt buộc khi thoát: chức năng sẽ bị loại bỏ nếu tệp này không
được biên dịch dưới dạng mô-đun. Xem tập tin tiêu đề để sử dụng. Lưu ý rằng nó làm cho không
ý nghĩa đối với một chức năng được đánh dấu bằng ZZ0003ZZ sẽ được xuất sang các mô-đun
với EXPORT_SYMBOL() hoặc EXPORT_SYMBOL_GPL()- cái này
sẽ vỡ.

__initcall()/module_init()
--------------------------

Được xác định trong ZZ0000ZZ / ZZ0001ZZ

Nhiều phần của kernel được phục vụ tốt như một mô-đun
(các phần có thể tải động của kernel). Sử dụng
module_init() và module_exit() macro nó
rất dễ viết mã mà không cần #ifdefs, có thể hoạt động cả dưới dạng mô-đun
hoặc được tích hợp vào kernel.

Macro module_init() xác định chức năng nào sẽ được thực hiện
được gọi tại thời điểm chèn mô-đun (nếu tệp được biên dịch dưới dạng mô-đun),
hoặc lúc khởi động: nếu tệp không được biên dịch thành một mô-đun thì
macro module_init() trở nên tương đương với
__initcall(), thông qua phép thuật liên kết đảm bảo rằng
chức năng được gọi khi khởi động.

Hàm có thể trả về số lỗi âm để gây ra việc tải mô-đun
thất bại (không may là điều này không có tác dụng nếu mô-đun được biên dịch
vào hạt nhân). Hàm này được gọi trong ngữ cảnh người dùng với
ngắt được kích hoạt, vì vậy nó có thể ngủ.

module_exit()
-------------

Được xác định trong ZZ0000ZZ

Macro này xác định chức năng được gọi tại thời điểm loại bỏ mô-đun (hoặc
không bao giờ, trong trường hợp tệp được biên dịch vào kernel). Nó sẽ chỉ
được gọi nếu số lượng sử dụng mô-đun đã đạt tới 0. Chức năng này có thể
cũng ngủ, nhưng không thể thất bại: mọi thứ phải được dọn dẹp trước thời gian
nó quay trở lại.

Lưu ý rằng macro này là tùy chọn: nếu nó không xuất hiện, mô-đun của bạn sẽ
không thể tháo rời được (ngoại trừ 'rmmod -f').

try_module_get()/module_put()
-----------------------------

Được xác định trong ZZ0000ZZ

Chúng thao túng số lượng sử dụng mô-đun, để bảo vệ chống lại việc loại bỏ (a
mô-đun cũng không thể bị xóa nếu một mô-đun khác sử dụng một trong các mô-đun đã xuất của nó
ký hiệu: xem bên dưới). Trước khi gọi vào mã mô-đun, bạn nên gọi
try_module_get() trên mô-đun đó: nếu thất bại thì
mô-đun đang bị xóa và bạn nên hành động như thể nó không có ở đó.
Nếu không, bạn có thể vào mô-đun một cách an toàn và gọi
module_put() khi bạn hoàn thành.

Hầu hết các cấu trúc có thể đăng ký đều có trường chủ sở hữu, chẳng hạn như trong
Cấu trúc ZZ0000ZZ.
Đặt trường này thành macro ZZ0001ZZ.

Hàng đợi ZZ0000ZZ
====================================

ZZ0000ZZ

Hàng đợi được sử dụng để đợi ai đó đánh thức bạn vào một thời điểm nhất định.
điều kiện là đúng. Chúng phải được sử dụng cẩn thận để đảm bảo không có
tình trạng cuộc đua. Bạn khai báo ZZ0000ZZ và sau đó xử lý
muốn chờ điều kiện đó hãy khai báo ZZ0001ZZ
đề cập đến chính họ và đặt nó vào hàng đợi.

Khai báo
---------

Bạn khai báo ZZ0000ZZ bằng cách sử dụng
macro DECLARE_WAIT_QUEUE_HEAD() hoặc sử dụng
thói quen init_waitqueue_head() trong quá trình khởi tạo của bạn
mã.

Xếp hàng
--------

Việc đặt mình vào hàng chờ khá phức tạp vì bạn phải
đặt mình vào hàng đợi trước khi kiểm tra điều kiện. có một
macro để thực hiện việc này: Wait_event_interruptible()
(ZZ0000ZZ) Đối số đầu tiên là đầu hàng chờ và
thứ hai là một biểu thức được đánh giá; macro trả về 0 khi
biểu thức này là đúng hoặc ZZ0001ZZ nếu nhận được tín hiệu. các
Phiên bản wait_event() bỏ qua tín hiệu.

Đánh thức các nhiệm vụ xếp hàng đợi
-----------------------------------

Gọi Wake_up() (ZZ0000ZZ), nó sẽ đánh thức
lên mọi tiến trình trong hàng đợi. Ngoại lệ là nếu một người có
ZZ0001ZZ được đặt, trong trường hợp đó phần còn lại của hàng đợi sẽ
không được đánh thức. Có sẵn các biến thể khác của chức năng cơ bản này
trong cùng một tiêu đề.

Hoạt động nguyên tử
===================

Một số hoạt động nhất định được đảm bảo nguyên tử trên tất cả các nền tảng. đầu tiên
lớp hoạt động hoạt động trên ZZ0000ZZ (ZZ0002ZZ);
cái này chứa một số nguyên có dấu (dài ít nhất 32 bit) và bạn phải sử dụng
các hàm này để thao tác hoặc đọc các biến ZZ0001ZZ.
Atomic_read() và Atomic_set() lấy và thiết lập
bộ đếm, Atomic_add(), Atomic_sub(),
Atomic_inc(), Atomic_dec() và
Atomic_dec_and_test() (trả về true nếu đúng
giảm xuống bằng không).

Đúng. Nó trả về true (tức là != 0) nếu biến nguyên tử bằng 0.

Lưu ý rằng các hàm này chậm hơn so với số học thông thường, và do đó
không nên sử dụng một cách không cần thiết.

Lớp hoạt động nguyên tử thứ hai là các hoạt động bit nguyên tử trên một
ZZ0000ZZ, được định nghĩa trong ZZ0001ZZ. Những cái này
các hoạt động thường lấy một con trỏ tới mẫu bit và một chút
số: 0 là bit ít quan trọng nhất. set_bit(),
Clear_bit() và Change_bit() được đặt, xóa,
và lật bit đã cho. test_and_set_bit(),
test_and_clear_bit() và
test_and_change_bit() làm điều tương tự, ngoại trừ return
đúng nếu bit đã được đặt trước đó; những điều này đặc biệt hữu ích cho
cờ cài đặt nguyên tử.

Có thể gọi các hoạt động này với chỉ số bit lớn hơn
ZZ0000ZZ. Hành vi kết quả là lạ trên big-endian
mặc dù vậy, tốt nhất là bạn không nên làm điều này.

Biểu tượng
==========

Trong kernel thích hợp, các quy tắc liên kết thông thường được áp dụng (nghĩa là trừ khi
biểu tượng được khai báo là phạm vi tệp với từ khóa ZZ0000ZZ, nó có thể
được sử dụng ở bất cứ đâu trong kernel). Tuy nhiên, đối với các mô-đun, một điều đặc biệt
bảng ký hiệu đã xuất được giữ lại để giới hạn các điểm vào
hạt nhân thích hợp. Các mô-đun cũng có thể xuất các ký hiệu.

EXPORT_SYMBOL()
---------------

Được xác định trong ZZ0000ZZ

Đây là phương pháp cổ điển để xuất biểu tượng: được tải động
các mô-đun sẽ có thể sử dụng biểu tượng như bình thường.

EXPORT_SYMBOL_GPL()
-------------------

Được xác định trong ZZ0000ZZ

Tương tự như EXPORT_SYMBOL() ngoại trừ các ký hiệu
được xuất bởi EXPORT_SYMBOL_GPL() chỉ có thể được nhìn thấy bởi
mô-đun có MODULE_LICENSE() chỉ định GPLv2
giấy phép tương thích. Nó ngụ ý rằng chức năng này được coi là một
vấn đề triển khai nội bộ và không thực sự là một giao diện. Một số
Tuy nhiên, người bảo trì và nhà phát triển có thể yêu cầu EXPORT_SYMBOL_GPL()
khi thêm bất kỳ API hoặc chức năng mới nào.

EXPORT_SYMBOL_NS()
------------------

Được xác định trong ZZ0000ZZ

Đây là biến thể của EXPORT_SYMBOL() cho phép chỉ định ký hiệu
không gian tên. Không gian tên biểu tượng được ghi lại trong
Tài liệu/core-api/symbol-namespaces.rst

EXPORT_SYMBOL_NS_GPL()
----------------------

Được xác định trong ZZ0000ZZ

Đây là biến thể của EXPORT_SYMBOL_GPL() cho phép chỉ định ký hiệu
không gian tên. Không gian tên biểu tượng được ghi lại trong
Tài liệu/core-api/symbol-namespaces.rst

Các thói quen và quy ước
========================

Danh sách liên kết đôi ZZ0000ZZ
--------------------------------------------

Đã từng có ba bộ quy trình danh sách liên kết trong kernel
tiêu đề, nhưng cái này là người chiến thắng. Nếu bạn không có một số đặc biệt
nhu cầu cấp thiết về một danh sách duy nhất, đó là một lựa chọn tốt.

Đặc biệt, list_for_each_entry() rất hữu ích.

Quy ước trả lại
------------------

Đối với mã được gọi trong ngữ cảnh của người dùng, việc vi phạm quy ước C là điều rất phổ biến,
và trả về 0 nếu thành công và số lỗi âm (ví dụ: ZZ0000ZZ) cho
thất bại. Điều này ban đầu có thể không trực quan nhưng nó khá phổ biến trong
hạt nhân.

Sử dụng ERR_PTR() (ZZ0000ZZ) để mã hóa một
số lỗi âm vào một con trỏ và IS_ERR() và
PTR_ERR() để lấy nó ra lần nữa: tránh tách biệt
tham số con trỏ cho số lỗi. Icky, nhưng theo một cách tốt.

Biên soạn đột phá
--------------------

Linus và các nhà phát triển khác đôi khi thay đổi chức năng hoặc cấu trúc
tên trong hạt nhân phát triển; việc này không được thực hiện chỉ để giữ mọi người tiếp tục
ngón chân của họ: nó phản ánh một sự thay đổi cơ bản (ví dụ: không còn có thể
được gọi khi bị gián đoạn hoặc thực hiện kiểm tra bổ sung hoặc không thực hiện kiểm tra
đã bị bắt trước đó). Thông thường điều này đi kèm với một khá
ghi chú đầy đủ vào danh sách gửi thư phát triển hạt nhân thích hợp; tìm kiếm
các kho lưu trữ. Chỉ cần thực hiện thay thế toàn cục trên tệp thường tạo ra
thứ ZZ0000ZZ.

Đang khởi tạo các thành viên cấu trúc
-------------------------------------

Phương pháp khởi tạo cấu trúc ưa thích là sử dụng được chỉ định
công cụ khởi tạo, như được xác định bởi ISO C99, ví dụ::

cấu trúc tĩnh block_device_Operation opt_fops = {
            .open = opt_open,
            .release = opt_release,
            .ioctl = opt_ioctl,
            .check_media_change = opt_media_change,
    };


Điều này giúp bạn dễ dàng grep và làm rõ cấu trúc nào
các trường được thiết lập. Bạn nên làm điều này vì nó trông rất ngầu.

Tiện ích mở rộng GNU
--------------------

Tiện ích mở rộng GNU được cho phép rõ ràng trong nhân Linux. Lưu ý rằng
một số cái phức tạp hơn không được hỗ trợ tốt, do thiếu
sử dụng chung, nhưng những điều sau đây được coi là tiêu chuẩn (xem GCC
phần trang thông tin "Tiện ích mở rộng C" để biết thêm chi tiết - Có, thực sự là thông tin
trang, trang man chỉ là một bản tóm tắt ngắn gọn về nội dung trong thông tin).

- Chức năng nội tuyến

- Biểu thức câu lệnh (tức là cấu trúc ({ và }).

- Khai báo thuộc tính của hàm/biến/kiểu
   (__thuộc tính__)

- loại

- Mảng có độ dài bằng không

- Các biến thể macro

- Tính toán trên con trỏ void

- Bộ khởi tạo không cố định

- Hướng dẫn lắp ráp (không nằm ngoài Arch/ và bao gồm/asm/)

- Tên hàm dưới dạng chuỗi (__func__).

- __buildin_constant_p()

Hãy thận trọng khi sử dụng long long trong kernel, mã gcc tạo ra cho
điều đó thật kinh khủng và tệ hơn nữa: phép chia và phép nhân không có tác dụng
i386 vì các chức năng thời gian chạy GCC cho nó bị thiếu trong
môi trường hạt nhân.

C++
---

Sử dụng C++ trong kernel thường là một ý tưởng tồi, vì kernel có
không cung cấp môi trường thời gian chạy cần thiết và các tệp bao gồm
không được thử nghiệm cho nó. Vẫn có thể, nhưng không được khuyến khích. Nếu bạn
thực sự muốn làm điều này, ít nhất hãy quên đi những ngoại lệ.

#if
---

Nói chung, việc sử dụng macro trong các tệp tiêu đề (hoặc tại
phần đầu của các tệp .c) để trừu tượng hóa các hàm thay vì sử dụng \`#if'
các câu lệnh tiền xử lý xuyên suốt mã nguồn.

Đưa nội dung của bạn vào hạt nhân
=================================

Để hoàn thiện nội dung của bạn để đưa vào chính thức, hoặc thậm chí để
tạo một bản vá gọn gàng, có công việc hành chính phải làm:

- Tìm ra ai là chủ sở hữu của mã bạn đang sửa đổi. Nhìn kìa
   ở đầu tệp nguồn, bên trong tệp ZZ0000ZZ và
   cuối cùng là trong tệp ZZ0001ZZ. Bạn nên phối hợp với những
   mọi người để đảm bảo rằng bạn không nỗ lực gấp đôi hoặc thử điều gì đó
   điều đó đã bị từ chối rồi.

Đảm bảo bạn đặt tên và địa chỉ email của mình ở đầu bất kỳ tệp nào
   bạn tạo hoặc sửa đổi đáng kể. Đây là nơi đầu tiên mọi người
   sẽ xem xét khi họ tìm thấy lỗi hoặc khi ZZ0000ZZ muốn thực hiện thay đổi.

- Thông thường bạn muốn có một tùy chọn cấu hình cho bản hack kernel của mình. Chỉnh sửa
   ZZ0000ZZ trong thư mục thích hợp. Ngôn ngữ cấu hình là
   sử dụng đơn giản bằng cách cắt và dán, đồng thời có tài liệu đầy đủ về
   Tài liệu/kbuild/kconfig-lingu.rst.

Trong mô tả của bạn về tùy chọn, hãy đảm bảo bạn giải quyết cả hai
   người dùng chuyên gia và người dùng không biết gì về tính năng của bạn.
   Đề cập đến sự không tương thích và các vấn đề ở đây. ZZ0000ZZ kết thúc của bạn
   mô tả với “nếu nghi ngờ, hãy nói N” (hoặc đôi khi, \`Y'); cái này
   dành cho những người không hiểu bạn đang nói về điều gì.

- Chỉnh sửa ZZ0000ZZ: các biến CONFIG được xuất ra đây nên bạn
   thường chỉ có thể thêm dòng "obj-$(CONFIG_xxx) += xxx.o". Cú pháp
   được ghi lại trong Documentation/kbuild/makefiles.rst.

- Hãy đặt mình vào ZZ0000ZZ nếu bạn cân nhắc những gì mình đã làm
   đáng chú ý, thường nằm ngoài một tệp duy nhất (tên của bạn phải ở
   ở đầu tệp nguồn). ZZ0001ZZ có nghĩa là bạn muốn trở thành
   được tư vấn khi có thay đổi đối với hệ thống con và nghe về lỗi;
   nó ngụ ý một cam kết vượt mức cho một số phần của mã.

- Cuối cùng, đừng quên đọc
   Tài liệu/quy trình/gửi-patches.rst.

Cantrip hạt nhân
================

Một số mục yêu thích từ việc duyệt nguồn. Hãy thêm vào danh sách này.

ZZ0000ZZ::

#define ndelay(n) (__buildin_constant_p(n) ? \
            ((n) > 20000 ? __bad_ndelay() : __const_udelay((n) * 5ul)) : \
            __ndelay(n))


ZZ0000ZZ::

/*
     * Con trỏ hạt nhân có thông tin dư thừa nên chúng ta có thể sử dụng
     * sơ đồ trong đó chúng tôi có thể trả về mã lỗi hoặc mã nha khoa
     * con trỏ có cùng giá trị trả về.
     *
     * Đây phải là thứ tùy theo từng kiến trúc, để cho phép các
     * quyết định lỗi và con trỏ.
     */
     #define ERR_PTR(err) ((void *)((dài)(err)))
     #define PTR_ERR(ptr) ((dài)(ptr))
     #define IS_ERR(ptr) ((dài không dấu)(ptr) > (dài không dấu)(-1000))

ZZ0000ZZ::

#define copy_to_user(đến,từ,n) \
            (__buildin_constant_p(n) ? \
             __constant_copy_to_user((to),(from),(n)) : \
             __generic_copy_to_user((đến),(từ),(n)))


ZZ0000ZZ::

/*
     * Sun người không thể đánh vần có giá trị chết tiệt. thực sự là "khả năng tương thích".
     * Ít nhất chúng tôi ZZ0000ZZ chúng tôi không thể đánh vần và sử dụng trình kiểm tra chính tả.
     */

/* Uh, thực ra Linus là tôi không biết đánh vần. Quá nhiều âm u
     * Sparc lắp ráp sẽ làm điều này với bạn.
     */
    C_LABEL(cputypvar):
            .asciz "khả năng tương thích"

/* Đã thử nghiệm trên SS-5, SS-10. Có lẽ ai đó ở Sun đã áp dụng trình kiểm tra chính tả. */
            .căn chỉnh 4
    C_LABEL(cputypvar_sun4m):
            .asciz "tương thích"


ZZ0000ZZ::

/* Sun, anh không thể đánh bại tôi, anh không thể.  Đừng cố gắng nữa
             * từ bỏ.  Tôi nghiêm túc đấy, tôi sẽ đá chết người
             * ra khỏi bạn, trò chơi kết thúc, tắt đèn.
             */


Cảm ơn
======

Cảm ơn Andi Kleen vì ý tưởng, trả lời các câu hỏi của tôi, sửa chữa
lỗi chính tả, điền nội dung, v.v. Philipp Rumpf để biết thêm chính tả và
sửa lỗi rõ ràng và một số điểm tuyệt vời không rõ ràng. Werner Almesberger
vì đã cho tôi một bản tóm tắt tuyệt vời về vô hiệu hóa_irq() và Jes
Sorensen và Andrea Arcangeli đã bổ sung thêm những cảnh báo. Michael Elizabeth Chastain
để kiểm tra và thêm vào phần Cấu hình. Telsa Gwynne cho
dạy tôi DocBook.
