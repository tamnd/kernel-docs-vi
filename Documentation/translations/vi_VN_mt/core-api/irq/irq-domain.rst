.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/irq/irq-domain.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Thư viện ánh xạ số ngắt irq_domain
===============================================

Thiết kế hiện tại của nhân Linux sử dụng một số lượng lớn
không gian trong đó mỗi nguồn IRQ riêng biệt được gán một số duy nhất.
Điều này đơn giản khi chỉ có một bộ điều khiển ngắt. Nhưng ở
hệ thống có nhiều bộ điều khiển ngắt, hạt nhân phải đảm bảo
rằng mỗi người được phân bổ các phân bổ không chồng chéo của Linux
Số IRQ.

Số lượng bộ điều khiển ngắt được đăng ký dưới dạng irqchip duy nhất
cho thấy xu hướng tăng lên. Ví dụ: các trình điều khiển con thuộc các loại khác nhau
chẳng hạn như bộ điều khiển GPIO tránh thực hiện lại lệnh gọi lại giống hệt nhau
các cơ chế như hệ thống lõi IRQ bằng cách mô hình hóa các ngắt của chúng
trình xử lý như irqchips. tức là trong các bộ điều khiển ngắt xếp tầng có hiệu lực.

Vì vậy, trước đây, các số IRQ có thể được chọn sao cho phù hợp với
phần cứng IRQ vào bộ điều khiển ngắt gốc (tức là
thành phần thực sự kích hoạt đường ngắt tới CPU). Ngày nay,
con số này chỉ là một con số và con số này không có
mối quan hệ với số ngắt phần cứng.

Vì lý do này, chúng ta cần một cơ chế để tách riêng bộ điều khiển cục bộ
số ngắt, được gọi là IRQ phần cứng, từ số IRQ của Linux.

API irq_alloc_desc*() and irq_free_desc*() cung cấp khả năng phân bổ
Các số IRQ, nhưng chúng không cung cấp bất kỳ hỗ trợ nào cho việc ánh xạ ngược của
số IRQ (hwirq) cục bộ của bộ điều khiển vào số IRQ của Linux
không gian.

Thư viện irq_domain thêm ánh xạ giữa các số hwirq và IRQ trên
đầu của irq_alloc_desc*() API. Một irq_domain để quản lý ánh xạ
được ưu tiên hơn các trình điều khiển bộ điều khiển ngắt mở mã hóa của riêng họ
sơ đồ ánh xạ ngược.

irq_domain cũng thực hiện dịch từ một cấu trúc trừu tượng
irq_fwspec thành số hwirq (Cây thiết bị, nút chương trình cơ sở không phải DT, ACPI
GSI và nút phần mềm cho đến nay) và có thể dễ dàng mở rộng để hỗ trợ
các nguồn dữ liệu cấu trúc liên kết IRQ khác. Việc thực hiện được thực hiện
không có bất kỳ mã hỗ trợ nền tảng bổ sung nào.

Cách sử dụng irq_domain
================
struct irq_domain có thể được định nghĩa là bộ điều khiển miền irq. Đó
là, nó xử lý ánh xạ giữa phần cứng và ngắt ảo
số cho một miền ngắt nhất định. Cấu trúc miền là
thường được tạo bởi mã PIC cho một phiên bản PIC nhất định (mặc dù
tên miền có thể bao gồm nhiều PIC nếu chúng có mô hình số phẳng).
Đó là các cuộc gọi lại tên miền chịu trách nhiệm thiết lập
irq_chip trên irq_desc nhất định sau khi nó được ánh xạ.

Mã máy chủ và cấu trúc dữ liệu sử dụng con trỏ fwnode_handle để
xác định miền. Trong một số trường hợp, và để bảo toàn nguồn
khả năng tương thích mã, con trỏ fwnode này được "nâng cấp" thành DT
device_node. Đối với những cơ sở hạ tầng phần sụn không cung cấp
mã định danh duy nhất cho bộ điều khiển ngắt, mã irq_domain
cung cấp một bộ cấp phát fwnode.

Trình điều khiển bộ điều khiển ngắt tạo và đăng ký cấu trúc irq_domain
bằng cách gọi một trong các hàm irq_domain_create_*() (mỗi hàm ánh xạ
phương thức này có chức năng cấp phát khác, sẽ nói thêm về điều đó sau). các
hàm sẽ trả về một con trỏ tới struct irq_domain nếu thành công. các
người gọi phải cung cấp chức năng cấp phát với cấu trúc irq_domain_ops
con trỏ.

Trong hầu hết các trường hợp, irq_domain sẽ bắt đầu trống mà không có bất kỳ ánh xạ nào
giữa số hwirq và IRQ.  Ánh xạ được thêm vào irq_domain
bằng cách gọi irq_create_mapping() chấp nhận irq_domain và
số hwirq làm đối số. Nếu chưa có ánh xạ cho hwirq
tồn tại, irq_create_mapping() sẽ cấp phát một irq_desc Linux mới, các cộng sự
nó bằng hwirq và gọi ZZ0000ZZ
gọi lại. Trong đó, trình điều khiển có thể thực hiện bất kỳ phần cứng cần thiết nào
thiết lập.

Khi một ánh xạ đã được thiết lập, nó có thể được lấy ra hoặc sử dụng thông qua một
nhiều phương pháp khác nhau:

- irq_resolve_mapping() trả về một con trỏ tới cấu trúc irq_desc
  đối với một tên miền và số hwirq nhất định hoặc NULL nếu không có
  lập bản đồ.
- irq_find_mapping() trả về số IRQ Linux cho một miền nhất định và
  số hwirq hoặc 0 nếu không có ánh xạ
- generic_handle_domain_irq() xử lý một ngắt được mô tả bởi một
  tên miền và số hwirq

Lưu ý rằng việc tra cứu irq_domain phải diễn ra trong các bối cảnh
tương thích với phần quan trọng phía đọc RCU.

Hàm irq_create_mapping() phải được gọi là ZZ0000ZZ
trước bất kỳ lệnh gọi nào tới irq_find_mapping(), kẻo bộ mô tả sẽ không
được phân bổ.

Nếu trình điều khiển có số Linux IRQ hoặc con trỏ irq_data và
cần biết số hwirq liên quan (chẳng hạn như trong irq_chip
callbacks) thì nó có thể được lấy trực tiếp từ
ZZ0000ZZ.

Các loại ánh xạ irq_domain
============================

Có một số cơ chế có sẵn để ánh xạ ngược từ hwirq
sang Linux IRQ và mỗi cơ chế sử dụng một chức năng phân bổ khác nhau.
Loại bản đồ ngược nào nên được sử dụng tùy thuộc vào trường hợp sử dụng.  Mỗi
của các loại bản đồ ngược được mô tả dưới đây:

tuyến tính
------

::

irq_domain_create_tuyến tính()

Bản đồ đảo ngược tuyến tính duy trì một bảng có kích thước cố định được lập chỉ mục bởi
số hwirq.  Khi một hwirq được ánh xạ, irq_desc được phân bổ cho
hwirq và số IRQ được lưu trong bảng.

Bản đồ tuyến tính là một lựa chọn tốt khi số lượng hwirq tối đa là
cố định và số lượng tương đối nhỏ (~ < 256).  Ưu điểm của việc này
bản đồ là tra cứu theo thời gian cố định cho các số IRQ và irq_descs chỉ
được phân bổ cho các IRQ đang sử dụng.  Nhược điểm là bàn phải
lớn nhất có thể bằng số hwirq.

Phần lớn người lái xe nên sử dụng bản đồ tuyến tính.

Cây
----

::

irq_domain_create_tree()

Irq_domain duy trì bản đồ cây cơ số từ số hwirq đến Linux
IRQ.  Khi một hwirq được ánh xạ, một irq_desc được phân bổ và
hwirq được sử dụng làm khóa tra cứu cho cây cơ số.

Bản đồ cây là một lựa chọn tốt nếu số hwirq có thể rất lớn
vì nó không cần phân bổ một bảng lớn bằng bảng lớn nhất
số hwirq.  Điểm bất lợi là việc tra cứu số hwirq đến IRQ là
phụ thuộc vào số lượng mục trong bảng.

Rất ít trình điều khiển cần tới bản đồ này.

Không có bản đồ
------

::

irq_domain_create_nomap()

Ánh xạ Không có Bản đồ sẽ được sử dụng khi số hwirq là
lập trình được trong phần cứng.  Trong trường hợp này tốt nhất là lập trình
Số Linux IRQ vào chính phần cứng để không có ánh xạ
được yêu cầu.  Gọi irq_create_direct_mapping() sẽ phân bổ Linux
Số IRQ và gọi hàm gọi lại .map() để tài xế có thể lập trình
Số Linux IRQ vào phần cứng.

Hầu hết các trình điều khiển không thể sử dụng ánh xạ này và hiện tại nó đã được kiểm soát trên
Tùy chọn CONFIG_IRQ_DOMAIN_NOMAP. Vui lòng không giới thiệu sản phẩm mới
người dùng API này.

Di sản
------

::

irq_domain_create_simple()
	irq_domain_create_legacy()

Ánh xạ kế thừa là trường hợp đặc biệt dành cho trình điều khiển đã có
phạm vi irq_descs được phân bổ cho hwirqs.  Nó được sử dụng khi
trình điều khiển không thể được chuyển đổi ngay lập tức để sử dụng ánh xạ tuyến tính.  cho
Ví dụ: nhiều tệp hỗ trợ bo mạch hệ thống nhúng sử dụng bộ #defines
đối với các số IRQ được chuyển đến cấu trúc đăng ký thiết bị.  Trong đó
trường hợp số Linux IRQ không thể được gán động và Legacy
nên sử dụng bản đồ.

Đúng như tên gọi, các hàm \*_legacy() không được dùng nữa và chỉ
tồn tại để giảm bớt sự hỗ trợ của các nền tảng cổ xưa. Không nên có người dùng mới
đã thêm vào. Điều tương tự cũng xảy ra với các hàm \*_simple() khi việc sử dụng chúng có kết quả
trong hành vi kế thừa.

Bản đồ Legacy giả định một dãy số IRQ liền kề đã có
đã được phân bổ cho bộ điều khiển và số IRQ có thể được
được tính bằng cách thêm phần bù cố định vào số hwirq và
ngược lại.  Nhược điểm là nó yêu cầu ngắt
bộ điều khiển để quản lý việc phân bổ IRQ và nó yêu cầu phải có irq_desc
được phân bổ cho mọi hwirq, ngay cả khi nó không được sử dụng.

Bản đồ kế thừa chỉ nên được sử dụng nếu phải có ánh xạ IRQ cố định
được hỗ trợ.  Ví dụ: bộ điều khiển ISA sẽ sử dụng bản đồ Legacy cho
ánh xạ IRQ Linux 0-15 để trình điều khiển ISA hiện có nhận được IRQ chính xác
những con số.

Hầu hết người dùng ánh xạ cũ nên sử dụng irq_domain_create_simple()
sẽ chỉ sử dụng miền kế thừa nếu phạm vi IRQ được cung cấp bởi
hệ thống và mặt khác sẽ sử dụng ánh xạ miền tuyến tính. Ngữ nghĩa của
lệnh gọi này sao cho nếu phạm vi IRQ được chỉ định thì bộ mô tả
sẽ được phân bổ nhanh chóng cho nó và nếu không có phạm vi nào được chỉ định thì nó
sẽ chuyển sang irq_domain_create_Tuyến tính() có nghĩa là ZZ0000ZZ IRQ
mô tả sẽ được phân bổ.

Trường hợp sử dụng điển hình cho các miền đơn giản là nơi nhà cung cấp irqchip
đang hỗ trợ cả bài tập IRQ động và tĩnh.

Để tránh rơi vào tình huống miền tuyến tính
được sử dụng và không có bộ mô tả nào được phân bổ, điều rất quan trọng là phải đảm bảo
trình điều khiển sử dụng tên miền đơn giản gọi irq_create_mapping()
trước bất kỳ irq_find_mapping() nào vì cái sau sẽ thực sự hoạt động
đối với trường hợp gán IRQ tĩnh.

Tên miền IRQ phân cấp
--------------------

Trên một số kiến trúc, có thể có nhiều bộ điều khiển ngắt
liên quan đến việc cung cấp một ngắt từ thiết bị đến CPU mục tiêu.
Hãy xem đường dẫn phân phối ngắt điển hình trên nền tảng x86 ::

Thiết bị -> IOAPIC -> Bộ điều khiển ánh xạ lại ngắt -> APIC cục bộ -> CPU

Có ba bộ điều khiển ngắt liên quan:

1) Bộ điều khiển IOAPIC
2) Bộ điều khiển ánh xạ lại ngắt
3) Bộ điều khiển APIC cục bộ

Để hỗ trợ cấu trúc liên kết phần cứng như vậy và làm cho kiến trúc phần mềm phù hợp
kiến trúc phần cứng, cấu trúc dữ liệu irq_domain được xây dựng cho mỗi
bộ điều khiển ngắt và các irq_domain đó được tổ chức thành hệ thống phân cấp.
Khi xây dựng hệ thống phân cấp irq_domain, irq_domain gần thiết bị nhất là
con và irq_domain gần CPU nhất là cha mẹ. Vì vậy, một cấu trúc phân cấp
như bên dưới sẽ được xây dựng cho ví dụ trên::

CPU Vector irq_domain (root irq_domain để quản lý vectơ CPU)
		^
		|
	Ngắt ánh xạ lại irq_domain (quản lý các mục irq_remapping)
		^
		|
	IOAPIC irq_domain (quản lý các mục/ghim phân phối IOAPIC)

Có bốn giao diện chính để sử dụng phân cấp irq_domain:

1) irq_domain_alloc_irqs(): phân bổ các bộ mô tả và ngắt IRQ
   các tài nguyên liên quan đến bộ điều khiển để cung cấp các ngắt này.
2) irq_domain_free_irqs(): bộ mô tả và bộ điều khiển ngắt IRQ miễn phí
   các tài nguyên liên quan liên quan đến các ngắt này.
3) irq_domain_activate_irq(): kích hoạt phần cứng bộ điều khiển ngắt để
   cung cấp sự gián đoạn.
4) irq_domain_deactivate_irq(): tắt phần cứng bộ điều khiển ngắt
   để ngừng cung cấp ngắt.

Cần có những điều sau đây để hỗ trợ phân cấp irq_domain:

1) Trường ZZ0000ZZ trong struct irq_domain được sử dụng để
   duy trì thông tin phân cấp irq_domain.
2) Trường ZZ0001ZZ trong struct irq_data được sử dụng để
   xây dựng hệ thống phân cấp irq_data để phù hợp với irq_domains phân cấp. các
   irq_data được sử dụng để lưu trữ con trỏ irq_domain và irq phần cứng
   số.
3) ZZ0002ZZ, ZZ0003ZZ và các lệnh gọi lại khác trong
   struct irq_domain_ops để hỗ trợ các hoạt động irq_domain phân cấp.

Với sự hỗ trợ của phân cấp irq_domain và phân cấp irq_data đã sẵn sàng,
cấu trúc irq_domain được xây dựng cho mỗi bộ điều khiển ngắt và
Cấu trúc irq_data được phân bổ cho mỗi irq_domain được liên kết với một
IRQ.

Để trình điều khiển bộ điều khiển ngắt hỗ trợ phân cấp irq_domain, nó
cần phải:

1) Triển khai irq_domain_ops.alloc() và irq_domain_ops.free()
2) Tùy chọn, triển khai irq_domain_ops.activate() và
   irq_domain_ops.deactivate().
3) Tùy chọn, triển khai irq_chip để quản lý bộ điều khiển ngắt
   phần cứng.
4) Không cần triển khai irq_domain_ops.map() và
   irq_domain_ops.unmap(). Chúng không được sử dụng với hệ thống phân cấp irq_domain.

Lưu ý rằng hệ thống phân cấp irq_domain không dành riêng cho x86 và là
được sử dụng nhiều để hỗ trợ các kiến trúc khác, chẳng hạn như ARM, ARM64, v.v.

irq_chip xếp chồng
~~~~~~~~~~~~~~~~

Bây giờ, chúng ta có thể tiến thêm một bước nữa để hỗ trợ xếp chồng (phân cấp)
irq_chip. Nghĩa là, một irq_chip được liên kết với mỗi irq_data dọc theo
hệ thống phân cấp. Một irq_chip con có thể thực hiện một hành động bắt buộc bằng cách
chính nó hoặc bằng cách hợp tác với irq_chip mẹ của nó.

Với irq_chip xếp chồng lên nhau, trình điều khiển bộ điều khiển ngắt chỉ cần xử lý
với phần cứng do chính nó quản lý và có thể yêu cầu các dịch vụ từ phần cứng đó
irq_chip cha khi cần thiết. Vì vậy, chúng tôi có thể đạt được một kết quả sạch hơn nhiều
kiến trúc phần mềm.

Gỡ lỗi
=========

Hầu hết các phần bên trong của hệ thống con IRQ đều được hiển thị trong các bản gỡ lỗi bởi
đang bật CONFIG_GENERIC_IRQ_DEBUGFS.

Cấu trúc và chức năng công cộng được cung cấp
========================================

Chương này chứa tài liệu được tạo tự động của các cấu trúc
và xuất các hàm API hạt nhân được sử dụng cho các miền IRQ.

.. kernel-doc:: include/linux/irqdomain.h

.. kernel-doc:: kernel/irq/irqdomain.c
   :export:

Chức năng nội bộ được cung cấp
===========================

Chương này chứa tài liệu được tạo tự động của hệ thống nội bộ
chức năng.

.. kernel-doc:: kernel/irq/irqdomain.c
   :internal:
