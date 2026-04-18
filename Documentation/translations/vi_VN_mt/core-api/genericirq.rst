.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/genericirq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============================
Xử lý IRQ chung của Linux
=============================

:Bản quyền: ZZ0000ZZ 2005-2010: Thomas Gleixner
:Bản quyền: ZZ0001ZZ 2005-2006: Ingo Molnar

Giới thiệu
============

Lớp xử lý ngắt chung được thiết kế để cung cấp một cách hoàn chỉnh
trừu tượng hóa việc xử lý ngắt cho trình điều khiển thiết bị. Nó có thể
xử lý tất cả các loại phần cứng bộ điều khiển ngắt khác nhau. Thiết bị
trình điều khiển sử dụng các chức năng API chung để yêu cầu, bật, tắt và giải phóng
ngắt quãng. Trình điều khiển không cần phải biết gì về ngắt
chi tiết phần cứng để chúng có thể được sử dụng trên các nền tảng khác nhau mà không cần
thay đổi mã.

Tài liệu này được cung cấp cho các nhà phát triển muốn triển khai một
hệ thống con ngắt dựa trên kiến trúc của chúng, với sự trợ giúp của
lớp xử lý IRQ chung.

Cơ sở lý luận
=========

Việc triển khai xử lý ngắt ban đầu trong Linux sử dụng
__do_IRQ() siêu xử lý, có thể xử lý mọi loại
ngắt logic.

Ban đầu, Russell King xác định các loại trình xử lý khác nhau để xây dựng
một bộ khá phổ biến để triển khai trình xử lý ngắt ARM trong
Linux 2.5/2.6. Ông phân biệt giữa:

- Loại cấp độ

- Loại cạnh

- Loại đơn giản

Trong quá trình thực hiện, chúng tôi đã xác định được một loại khác:

- Loại EOI nhanh

Trong thế giới SMP của siêu xử lý __do_IRQ(), một loại khác là
xác định:

- Mỗi loại CPU

Việc triển khai phân chia các trình xử lý IRQ cấp cao này cho phép chúng tôi
tối ưu hóa luồng xử lý ngắt cho từng ngắt cụ thể
loại. Điều này làm giảm độ phức tạp trong đường dẫn mã cụ thể đó và cho phép
việc xử lý tối ưu của một loại nhất định.

Triển khai IRQ chung ban đầu được sử dụng hw_interrupt_type
cấu trúc và các lệnh gọi lại ZZ0000ZZ, ZZ0001ZZ [v.v.] của chúng để phân biệt
điều khiển luồng trong bộ siêu xử lý. Điều này dẫn đến sự kết hợp giữa logic luồng
và logic phần cứng cấp thấp, đồng thời nó cũng dẫn đến việc sử dụng mã không cần thiết
trùng lặp: ví dụ trong i386, có ZZ0002ZZ và
ZZ0003ZZ IRQ-type chia sẻ nhiều chi tiết cấp thấp nhưng
có cách xử lý luồng khác nhau.

Một cách trừu tượng tự nhiên hơn là sự tách biệt rõ ràng giữa 'dòng irq' và
'chi tiết chip'.

Phân tích một số triển khai hệ thống con IRQ của kiến trúc
tiết lộ rằng hầu hết trong số họ có thể sử dụng một tập hợp chung các phương pháp 'dòng irq'
và chỉ cần thêm mã cụ thể ở cấp độ chip. Sự tách biệt là
cũng có giá trị đối với các kiến trúc (phụ) cần những đặc điểm riêng biệt trong
IRQ tự chảy nhưng không chảy trong các chi tiết chip - và do đó cung cấp nhiều hơn
thiết kế hệ thống con IRQ minh bạch.

Mỗi bộ mô tả ngắt được gán bộ xử lý luồng cấp cao riêng,
thường là một trong những cách triển khai chung. (Cấp cao này
Việc triển khai trình xử lý luồng cũng làm cho việc cung cấp trở nên đơn giản
các trình xử lý phân kênh có thể được tìm thấy trong các nền tảng nhúng trên
nhiều kiến trúc khác nhau.)

Sự tách biệt làm cho lớp xử lý ngắt chung linh hoạt hơn
và có thể mở rộng. Ví dụ: một kiến trúc (phụ) có thể sử dụng một kiến trúc chung
Triển khai luồng IRQ cho các ngắt 'loại cấp độ' và thêm một
(phụ)việc triển khai 'loại cạnh' cụ thể của kiến trúc.

Để giúp việc chuyển đổi sang mẫu mới dễ dàng hơn và ngăn ngừa hư hỏng
trong số các triển khai hiện có, siêu xử lý __do_IRQ() vẫn
có sẵn. Điều này dẫn đến một loại tính hai mặt trong thời điểm hiện tại. Theo thời gian
mô hình mới nên được sử dụng ngày càng nhiều trong kiến trúc, vì nó
cho phép các hệ thống con IRQ nhỏ hơn và sạch hơn. Nó không được dùng nữa trong ba
nhiều năm nay và sắp bị loại bỏ.

Lỗi đã biết và giả định
==========================

Không có (gõ vào gỗ).

Lớp trừu tượng
==================

Có ba mức độ trừu tượng chính trong mã ngắt:

1. Trình điều khiển cấp cao API

2. Trình xử lý luồng IRQ cấp cao

3. Đóng gói phần cứng cấp chip

Dòng điều khiển ngắt
----------------------

Mỗi ngắt được mô tả bằng cấu trúc mô tả ngắt
irq_desc. Ngắt được tham chiếu bằng số 'unsigned int'
giá trị chọn cấu trúc mô tả ngắt tương ứng trong
mảng cấu trúc mô tả. Cấu trúc mô tả chứa
thông tin trạng thái và con trỏ tới phương pháp luồng ngắt và
cấu trúc chip ngắt được gán cho ngắt này.

Bất cứ khi nào một ngắt kích hoạt, mã kiến trúc cấp thấp sẽ gọi
vào mã ngắt chung bằng cách gọi desc->handle_irq(). Cái này
chức năng xử lý IRQ cấp cao chỉ sử dụng desc->irq_data.chip
nguyên thủy được tham chiếu bởi cấu trúc mô tả chip được chỉ định.

Trình điều khiển cấp cao API
---------------------

Driver API cấp cao bao gồm các chức năng sau:

- request_irq()

- request_threaded_irq()

- free_irq()

- vô hiệu hóa_irq()

- kích hoạt_irq()

- vô hiệu hóa_irq_nosync() (chỉ SMP)

- đồng bộ hóa_irq () (chỉ SMP)

- irq_set_irq_type()

- irq_set_irq_wake()

- irq_set_handler_data()

- irq_set_chip()

- irq_set_chip_data()

Xem tài liệu về hàm được tạo tự động để biết chi tiết.

Trình xử lý luồng IRQ cấp cao
----------------------------

Lớp chung cung cấp một tập hợp các phương thức luồng irq được xác định trước:

- xử lý_level_irq()

- xử lý_edge_irq()

-hand_fasteoi_irq()

- xử lý_simple_irq()

- xử lý_percpu_irq()

-hand_edge_eoi_irq()

- xử lý_bad_irq()

Trình xử lý luồng ngắt (được xác định trước hoặc kiến trúc
cụ thể) được gán cho các ngắt cụ thể theo kiến trúc
trong quá trình khởi động hoặc trong quá trình khởi tạo thiết bị.

Triển khai luồng mặc định
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chức năng trợ giúp
^^^^^^^^^^^^^^^^

Các hàm trợ giúp gọi chip nguyên thủy và được sử dụng bởi
triển khai luồng mặc định. Các chức năng trợ giúp sau đây là
đã thực hiện (đoạn trích đơn giản hóa)::

default_enable(struct irq_data *data)
    {
        desc->irq_data.chip->irq_unmask(data);
    }

default_disable(struct irq_data *data)
    {
        if (!delay_disable(data))
            desc->irq_data.chip->irq_mask(dữ liệu);
    }

default_ack(struct irq_data *data)
    {
        chip->irq_ack(dữ liệu);
    }

default_mask_ack(struct irq_data *data)
    {
        if (chip->irq_mask_ack) {
            chip->irq_mask_ack(dữ liệu);
        } khác {
            chip->irq_mask(dữ liệu);
            chip->irq_ack(dữ liệu);
        }
    }

noop(struct irq_data *data)
    {
    }



Triển khai trình xử lý luồng mặc định
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình xử lý luồng IRQ cấp mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

hand_level_irq cung cấp cách triển khai chung cho cấp độ được kích hoạt
ngắt quãng.

Luồng điều khiển sau được triển khai (đoạn trích đơn giản hóa)::

desc->irq_data.chip->irq_mask_ack();
    xử lý_irq_event (desc->hành động);
    desc->irq_data.chip->irq_unmask();


Trình xử lý luồng EOI IRQ nhanh mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

hand_fasteoi_irq cung cấp cách triển khai chung cho các ngắt,
chỉ cần một EOI ở cuối trình xử lý.

Luồng điều khiển sau được triển khai (đoạn trích đơn giản hóa)::

xử lý_irq_event (desc->hành động);
    desc->irq_data.chip->irq_eoi();


Trình xử lý luồng IRQ của Edge mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

hand_edge_irq cung cấp cách triển khai chung cho kích hoạt cạnh
ngắt quãng.

Luồng điều khiển sau được triển khai (đoạn trích đơn giản hóa)::

if (desc->status & đang chạy) {
        desc->irq_data.chip->irq_mask_ack();
        desc->trạng thái ZZ0000ZZ bị che;
        trở lại;
    }
    desc->irq_data.chip->irq_ack();
    desc->trạng thái |= đang chạy;
    làm {
        if (desc->status & bị che)
            desc->irq_data.chip->irq_unmask();
        desc->trạng thái &= ~đang chờ xử lý;
        xử lý_irq_event (desc->hành động);
    } while (desc->trạng thái & đang chờ xử lý);
    desc->trạng thái &= ~đang chạy;


Trình xử lý luồng IRQ đơn giản mặc định
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

hand_simple_irq cung cấp cách triển khai chung cho đơn giản
ngắt quãng.

.. note::

   The simple flow handler does not call any handler/chip primitives.

Luồng điều khiển sau được triển khai (đoạn trích đơn giản hóa)::

xử lý_irq_event (desc->hành động);


Mặc định cho mỗi trình xử lý luồng CPU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

hand_percpu_irq cung cấp cách triển khai chung cho mỗi CPU
ngắt quãng.

Mỗi ngắt CPU chỉ khả dụng trên SMP và trình xử lý cung cấp một
phiên bản đơn giản hóa mà không cần khóa.

Luồng điều khiển sau được triển khai (đoạn trích đơn giản hóa)::

if (desc->irq_data.chip->irq_ack)
        desc->irq_data.chip->irq_ack();
    xử lý_irq_event (desc->hành động);
    if (desc->irq_data.chip->irq_eoi)
        desc->irq_data.chip->irq_eoi();


Bộ xử lý luồng EOI Edge IRQ
^^^^^^^^^^^^^^^^^^^^^^^^^

hand_edge_eoi_irq cung cấp một sự hủy bỏ của trình xử lý cạnh
chỉ được sử dụng để chế ngự bộ điều khiển IRQ bị hỏng nặng trên
máy tính/tế bào.

Trình xử lý luồng IRQ kém
^^^^^^^^^^^^^^^^^^^^

hand_bad_irq được sử dụng cho các ngắt giả không có thực tế
người xử lý được giao..

Quirks và tối ưu hóa
~~~~~~~~~~~~~~~~~~~~~~~~

Các chức năng chung dành cho kiến trúc và chip 'sạch',
không có yêu cầu xử lý IRQ dành riêng cho nền tảng. Nếu một kiến trúc
cần thực hiện các yêu cầu ở cấp độ 'dòng' thì nó có thể làm như vậy bằng cách
ghi đè trình xử lý luồng irq cấp cao.

Vô hiệu hóa ngắt bị trì hoãn
~~~~~~~~~~~~~~~~~~~~~~~~~

Tính năng có thể lựa chọn trên mỗi ngắt này được Russell giới thiệu
King trong việc triển khai ngắt ARM, không che dấu ngắt tại
mức độ phần cứng khi vô hiệu hóa_irq() được gọi. Sự gián đoạn được giữ
được bật và được ẩn trong trình xử lý luồng khi có sự kiện gián đoạn
xảy ra. Điều này ngăn chặn việc mất các ngắt cạnh trên phần cứng không
lưu trữ một sự kiện ngắt cạnh trong khi ngắt bị vô hiệu hóa tại
mức độ phần cứng. Khi có ngắt xuất hiện trong khi cờ IRQ_DISABLED
được thiết lập thì ngắt sẽ được che đi ở cấp độ phần cứng và
Bit IRQ_PENDING được thiết lập. Khi ngắt được kích hoạt lại bởi
Enable_irq() bit đang chờ xử lý được kiểm tra và nếu nó được đặt, thì ngắt
được gửi lại thông qua phần cứng hoặc bằng cơ chế gửi lại phần mềm. (Đó là
cần thiết để kích hoạt CONFIG_HARDIRQS_SW_RESEND khi bạn muốn sử dụng
tính năng vô hiệu hóa ngắt bị trì hoãn và phần cứng của bạn không có khả năng
kích hoạt lại một ngắt.) Việc vô hiệu hóa ngắt bị trì hoãn không được thực hiện
có thể cấu hình được.

Đóng gói phần cứng cấp chip
---------------------------------

Cấu trúc mô tả phần cứng cấp chip ZZ0000ZZ chứa tất cả
các chức năng liên quan đến chip trực tiếp, có thể được sử dụng bởi luồng irq
triển khai.

-ZZ0000ZZ

- ZZ0000ZZ - Tùy chọn, được khuyến nghị để thực hiện

-ZZ0000ZZ

-ZZ0000ZZ

- ZZ0000ZZ - Tùy chọn, bắt buộc đối với bộ xử lý luồng EOI

- ZZ0000ZZ - Tùy chọn

- ZZ0000ZZ - Tùy chọn

- ZZ0000ZZ - Tùy chọn

Những từ nguyên thủy này hoàn toàn nhằm mục đích diễn đạt những gì chúng nói: ack có nghĩa là
ACK, che giấu có nghĩa là che giấu dòng IRQ, v.v. Tùy theo dòng chảy
(các) trình xử lý để sử dụng các đơn vị chức năng cấp thấp cơ bản này.

__do_IRQ điểm vào
====================

Việc triển khai ban đầu __do_IRQ() là một điểm vào thay thế
cho tất cả các loại ngắt. Nó không còn tồn tại nữa.

Trình xử lý này hóa ra không phù hợp với tất cả phần cứng ngắt
và do đó đã được triển khai lại với chức năng phân chia cho
ngắt cạnh/cấp/đơn giản/percpu. Đây không chỉ là chức năng
tối ưu hóa. Nó cũng rút ngắn đường dẫn mã cho các ngắt.

Khóa trên SMP
==============

Việc khóa các thanh ghi chip phụ thuộc vào kiến trúc xác định
chip nguyên thủy. Cấu trúc per-irq được bảo vệ thông qua desc->lock, bởi
lớp chung.

Chip ngắt chung
======================

Để tránh các bản sao triển khai giống hệt nhau của chip IRQ, lõi
cung cấp triển khai chip ngắt chung có thể định cấu hình.
Các nhà phát triển nên kiểm tra cẩn thận xem chip chung có phù hợp với họ không
cần trước khi triển khai cùng một chức năng hơi khác một chút
chính họ.

.. kernel-doc:: kernel/irq/generic-chip.c
   :export:

Cấu trúc
==========

Chương này chứa tài liệu được tạo tự động của các cấu trúc
được sử dụng trong lớp IRQ chung.

.. kernel-doc:: include/linux/irq.h
   :internal:

.. kernel-doc:: include/linux/interrupt.h
   :internal:

Chức năng công cộng được cung cấp
=========================

Chương này chứa tài liệu được tạo tự động của kernel API
các chức năng được xuất khẩu.

.. kernel-doc:: kernel/irq/manage.c

.. kernel-doc:: kernel/irq/chip.c
   :export:

Chức năng nội bộ được cung cấp
===========================

Chương này chứa tài liệu được tạo tự động của hệ thống nội bộ
chức năng.

.. kernel-doc:: kernel/irq/irqdesc.c

.. kernel-doc:: kernel/irq/handle.c

.. kernel-doc:: kernel/irq/chip.c
   :internal:

Tín dụng
=======

Những người sau đây đã đóng góp cho tài liệu này:

1. Thomas Gleixner tglx@kernel.org

2. Ingo Molnar mingo@elte.hu
