.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/msi-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

============================================
Hướng dẫn cài đặt trình điều khiển MSI HOWTO
============================================

:Tác giả: Tom L Nguyễn; Martine Silbermann; Matthew Wilcox

:Bản quyền: 2003, 2008 Tập đoàn Intel

Giới thiệu về hướng dẫn này
===========================

Hướng dẫn này mô tả những kiến thức cơ bản về Ngắt báo hiệu bằng tin nhắn (MSI),
những ưu điểm của việc sử dụng MSI so với các cơ chế ngắt truyền thống, làm thế nào
để thay đổi trình điều khiển của bạn để sử dụng MSI hoặc MSI-X và một số chẩn đoán cơ bản để
hãy thử nếu thiết bị không hỗ trợ MSI.


MSI là gì?
==============

Ngắt báo hiệu thông báo là việc ghi từ thiết bị tới một thiết bị đặc biệt
địa chỉ khiến CPU nhận được một ngắt.

Khả năng MSI lần đầu tiên được chỉ định trong PCI 2.2 và sau đó được nâng cao
trong PCI 3.0 để cho phép mỗi ngắt được che giấu riêng lẻ.  MSI-X
khả năng cũng được giới thiệu với PCI 3.0.  Nó hỗ trợ nhiều ngắt hơn
trên mỗi thiết bị hơn MSI và cho phép các ngắt được cấu hình độc lập.

Các thiết bị có thể hỗ trợ cả MSI và MSI-X, nhưng chỉ có thể bật một thiết bị tại
một thời gian.


Tại sao nên sử dụng MSI?
========================

Có ba lý do tại sao việc sử dụng MSI có thể mang lại lợi thế hơn
ngắt dựa trên pin truyền thống.

Các ngắt PCI dựa trên pin thường được chia sẻ giữa một số thiết bị.
Để hỗ trợ điều này, kernel phải gọi từng trình xử lý ngắt được liên kết
bị gián đoạn, dẫn đến giảm hiệu năng của hệ thống vì
một tổng thể.  MSI không bao giờ được chia sẻ nên vấn đề này không thể phát sinh.

Khi một thiết bị ghi dữ liệu vào bộ nhớ, sau đó thực hiện ngắt dựa trên pin,
có thể ngắt có thể đến trước khi tất cả dữ liệu được xử lý xong
đã đến bộ nhớ (điều này dễ xảy ra hơn với các thiết bị phía sau PCI-PCI
cầu).  Để đảm bảo rằng tất cả dữ liệu đã đến bộ nhớ,
trình xử lý ngắt phải đọc một thanh ghi trên thiết bị đã đưa ra
sự gián đoạn.  Quy tắc đặt hàng giao dịch PCI yêu cầu tất cả dữ liệu
đến bộ nhớ trước khi giá trị có thể được trả về từ thanh ghi.
Việc sử dụng MSI sẽ tránh được vấn đề này vì việc ghi tạo ngắt không thể thực hiện được.
truyền dữ liệu ghi, do đó vào thời điểm ngắt được thực hiện, trình điều khiển
biết rằng tất cả dữ liệu đã đến bộ nhớ.

Các thiết bị PCI chỉ có thể hỗ trợ một ngắt dựa trên pin duy nhất cho mỗi chức năng.
Thông thường các tài xế phải truy vấn thiết bị để tìm hiểu xem có sự kiện gì
xảy ra, làm chậm quá trình xử lý ngắt đối với trường hợp thông thường.  Với
MSI, một thiết bị có thể hỗ trợ nhiều ngắt hơn, cho phép mỗi ngắt
chuyên biệt hóa cho một mục đích khác.  Một thiết kế có thể mang lại
các điều kiện không thường xuyên (chẳng hạn như lỗi) ngắt riêng của chúng cho phép
trình điều khiển để xử lý đường dẫn xử lý ngắt thông thường hiệu quả hơn.
Các thiết kế khả thi khác bao gồm việc đưa ra một ngắt cho mỗi hàng đợi gói
trong card mạng hoặc mỗi cổng trong bộ điều khiển lưu trữ.


Cách sử dụng MSI
================

Các thiết bị PCI được khởi tạo để sử dụng các ngắt dựa trên pin.  thiết bị
trình điều khiển phải thiết lập thiết bị để sử dụng MSI hoặc MSI-X.  Không phải tất cả các máy
hỗ trợ MSI một cách chính xác và đối với các máy đó, các API được mô tả bên dưới
sẽ bị lỗi và thiết bị sẽ tiếp tục sử dụng các ngắt dựa trên pin.

Bao gồm hỗ trợ kernel cho MSI
-------------------------------

Để hỗ trợ MSI hoặc MSI-X, kernel phải được xây dựng bằng CONFIG_PCI_MSI
tùy chọn được kích hoạt.  Tùy chọn này chỉ có sẵn trên một số kiến trúc,
và nó có thể phụ thuộc vào một số tùy chọn khác cũng đang được đặt.  Ví dụ,
trên x86, bạn cũng phải bật X86_UP_APIC hoặc SMP để xem
Tùy chọn CONFIG_PCI_MSI.

Sử dụng MSI
-----------

Hầu hết công việc khó khăn được thực hiện đối với trình điều khiển trong lớp PCI.  Người lái xe
chỉ cần yêu cầu lớp PCI thiết lập khả năng MSI cho việc này
thiết bị.

Để tự động sử dụng các vectơ ngắt MSI hoặc MSI-X, hãy sử dụng như sau
chức năng::

int pci_alloc_irq_vectors(struct pci_dev *dev, unsigned int min_vecs,
		int max_vecs không dấu, cờ int không dấu);

phân bổ tối đa vectơ ngắt max_vecs cho thiết bị PCI.  Nó
trả về số vectơ được phân bổ hoặc lỗi âm.  Nếu thiết bị
có yêu cầu về số lượng vectơ tối thiểu mà người lái xe có thể vượt qua
Đối số min_vecs được đặt ở giới hạn này và lõi PCI sẽ trả về -ENOSPC
nếu nó không thể đáp ứng số lượng vectơ tối thiểu.

Đối số flags được sử dụng để chỉ định loại ngắt nào có thể được sử dụng
bởi thiết bị và trình điều khiển (PCI_IRQ_INTX, PCI_IRQ_MSI, PCI_IRQ_MSIX).
Cũng có sẵn một chiếc kim ngắn tiện lợi (PCI_IRQ_ALL_TYPES) để yêu cầu
bất kỳ loại gián đoạn nào có thể xảy ra.  Nếu cờ PCI_IRQ_AFFINITY được đặt,
pci_alloc_irq_vectors() sẽ truyền các ngắt xung quanh các CPU có sẵn.

Để nhận các số IRQ của Linux được chuyển tới request_irq() và free_irq() và
vectơ, hãy sử dụng hàm sau ::

int pci_irq_vector(struct pci_dev *dev, unsigned int nr);

Nếu trình điều khiển kích hoạt thiết bị bằng pcim_enable_device(), trình điều khiển
không nên gọi pci_free_irq_vectors() vì pcim_enable_device()
kích hoạt quản lý tự động cho vectơ IRQ. Nếu không, người lái xe phải
giải phóng mọi vectơ IRQ được phân bổ trước khi tháo thiết bị bằng cách sử dụng cách sau
chức năng::

void pci_free_irq_vectors(struct pci_dev *dev);

Nếu một thiết bị hỗ trợ cả khả năng MSI-X và MSI thì API này sẽ sử dụng
Ưu tiên các cơ sở MSI-X hơn các cơ sở MSI.  MSI-X hỗ trợ mọi
số lần ngắt từ 1 đến 2048. Ngược lại, MSI bị giới hạn ở
tối đa 32 ngắt (và phải là lũy thừa của hai).  Ngoài ra,
Các vectơ ngắt MSI phải được phân bổ liên tục, do đó hệ thống có thể
không thể phân bổ nhiều vectơ cho MSI như cho MSI-X.  Bật
trên một số nền tảng, tất cả các ngắt MSI đều phải được nhắm mục tiêu vào cùng một bộ CPU
trong khi các ngắt MSI-X đều có thể được nhắm mục tiêu vào các CPU khác nhau.

Nếu một thiết bị không hỗ trợ MSI-X hay MSI, thiết bị đó sẽ chuyển về trạng thái duy nhất
vectơ IRQ kế thừa.

Cách sử dụng điển hình của các ngắt MSI hoặc MSI-X là phân bổ càng nhiều vectơ càng tốt.
nhất có thể, có thể lên đến giới hạn được thiết bị hỗ trợ.  Nếu nvec là
lớn hơn số lượng được thiết bị hỗ trợ, nó sẽ tự động được
được giới hạn ở giới hạn được hỗ trợ, do đó không cần phải truy vấn số lượng
vectơ được hỗ trợ trước::

nvec = pci_alloc_irq_vectors(pdev, 1, nvec, PCI_IRQ_ALL_TYPES)
	nếu (nvec < 0)
		đi out_err;

Nếu trình điều khiển không thể hoặc không muốn xử lý số lượng MSI khác nhau
ngắt, nó có thể yêu cầu một số lượng ngắt cụ thể bằng cách chuyển
số cho hàm pci_alloc_irq_vectors() vừa là 'min_vecs' vừa
Thông số 'max_vecs'::

ret = pci_alloc_irq_vectors(pdev, nvec, nvec, PCI_IRQ_ALL_TYPES);
	nếu (ret < 0)
		đi out_err;

Ví dụ nổi tiếng nhất về loại yêu cầu được mô tả ở trên là cho phép
chế độ MSI duy nhất cho một thiết bị.  Nó có thể được thực hiện bằng cách chuyển hai số 1 như
'min_vecs' và 'max_vecs'::

ret = pci_alloc_irq_vectors(pdev, 1, 1, PCI_IRQ_ALL_TYPES);
	nếu (ret < 0)
		đi out_err;

Một số thiết bị có thể không hỗ trợ sử dụng các ngắt dòng truyền thống, trong trường hợp đó
trình điều khiển có thể chỉ định rằng chỉ MSI hoặc MSI-X mới được chấp nhận::

nvec = pci_alloc_irq_vectors(pdev, 1, nvec, PCI_IRQ_MSI | PCI_IRQ_MSIX);
	nếu (nvec < 0)
		đi out_err;

API kế thừa
-----------

Các API cũ sau đây để bật và tắt các ngắt MSI hoặc MSI-X nên
không được sử dụng trong mã mới::

pci_enable_msi() /* không được dùng nữa */
  pci_disable_msi() /* không được dùng nữa */
  pci_enable_msix_range() /* không dùng nữa */
  pci_enable_msix_exact() /* không được dùng nữa */
  pci_disable_msix() /* không được dùng nữa */

Ngoài ra còn có các API để cung cấp số lượng MSI hoặc MSI-X được hỗ trợ
vectơ: pci_msi_vec_count() và pci_msix_vec_count().  Nói chung những điều này
nên tránh để dành pci_alloc_irq_vectors() giới hạn
số vectơ.  Nếu bạn có trường hợp sử dụng đặc biệt hợp pháp cho số lượng
của các vectơ chúng ta có thể phải xem lại quyết định đó và thêm một
trình trợ giúp pci_nr_irq_vectors() xử lý MSI và MSI-X một cách minh bạch.

Những lưu ý khi sử dụng MSI
------------------------------

Spinlocks
~~~~~~~~~

Hầu hết các trình điều khiển thiết bị đều có khóa xoay cho mỗi thiết bị được thực hiện trong
trình xử lý ngắt.  Với các ngắt dựa trên pin hoặc một MSI đơn lẻ, thì không
cần thiết để vô hiệu hóa các ngắt (Linux đảm bảo ngắt tương tự sẽ
không được nhập lại).  Nếu một thiết bị sử dụng nhiều ngắt, trình điều khiển
phải vô hiệu hóa các ngắt trong khi khóa được giữ.  Nếu thiết bị gửi
một ngắt khác, trình điều khiển sẽ bế tắc khi cố gắng đệ quy
có được spinlock.  Những bế tắc như vậy có thể tránh được bằng cách sử dụng
spin_lock_irqsave() hoặc spin_lock_irq() vô hiệu hóa các ngắt cục bộ
và lấy khóa (xem Tài liệu/kernel-hacking/locking.rst).

Cách nhận biết MSI/MSI-X có được bật trên thiết bị hay không
------------------------------------------------------------

Sử dụng 'lspci -v' (với quyền root) có thể hiển thị một số thiết bị có "MSI", "Message
Khả năng ngắt tín hiệu" hoặc "MSI-X".  Mỗi khả năng này
có cờ 'Bật' theo sau là "+" (đã bật)
hoặc "-" (bị vô hiệu hóa).


MSI kỳ quặc
===========

Một số chipset hoặc thiết bị PCI được biết là không hỗ trợ MSI.
Ngăn xếp PCI cung cấp ba cách để tắt MSI:

1. trên toàn cầu
2. trên tất cả các thiết bị phía sau một cây cầu cụ thể
3. trên một thiết bị duy nhất

Vô hiệu hóa MSI trên toàn cầu
-----------------------------

Một số chipset chủ không hỗ trợ MSI đúng cách.  Nếu chúng ta
may mắn thay, nhà sản xuất biết điều này và đã chỉ ra nó trong ACPI
Bàn FADT.  Trong trường hợp này, Linux sẽ tự động tắt MSI.
Một số bảng không bao gồm thông tin này trong bảng và vì vậy chúng tôi có
để tự mình phát hiện ra chúng.  Danh sách đầy đủ những thứ này được tìm thấy ở gần
hàm quirk_disable_all_msi() trong driver/pci/quirks.c.

Nếu bo mạch của bạn gặp vấn đề với MSI, bạn có thể chuyển pci=nomsi
trên dòng lệnh kernel để tắt MSI trên tất cả các thiết bị.  Nó sẽ là
vì lợi ích tốt nhất của bạn, hãy báo cáo vấn đề tới linux-pci@vger.kernel.org
bao gồm cả 'lspci -v' đầy đủ để chúng tôi có thể thêm các điểm kỳ quặc vào kernel.

Vô hiệu hóa MSI bên dưới cây cầu
--------------------------------

Một số cầu nối PCI không thể định tuyến MSI giữa các xe buýt một cách chính xác.
Trong trường hợp này, MSI phải bị tắt trên tất cả các thiết bị phía sau cầu nối.

Một số cầu nối cho phép bạn kích hoạt MSI bằng cách thay đổi một số bit trong
Không gian cấu hình PCI (đặc biệt là các chipset Hypertransport như
như nVidia nForce và Serverworks HT2000).  Giống như các chipset chủ,
Linux hầu hết biết về chúng và tự động kích hoạt MSI nếu có thể.
Nếu bạn có một cầu nối mà Linux không biết, bạn có thể kích hoạt
MSI trong không gian cấu hình bằng bất kỳ phương pháp nào bạn biết là có hiệu quả, sau đó
kích hoạt MSI trên cây cầu đó bằng cách thực hiện::

echo 1 > /sys/bus/pci/devices/$bridge/msi_bus

trong đó $bridge là địa chỉ PCI của bridge bạn đã kích hoạt (ví dụ:
0000:00:0e.0).

Để tắt MSI, hãy echo 0 thay vì 1. Việc thay đổi giá trị này phải là
được thực hiện một cách thận trọng vì nó có thể phá vỡ việc xử lý gián đoạn cho tất cả các thiết bị
dưới cây cầu này.

Một lần nữa, vui lòng thông báo linux-pci@vger.kernel.org về bất kỳ cầu nối nào cần
xử lý đặc biệt.

Vô hiệu hóa MSI trên một thiết bị
---------------------------------

Một số thiết bị được biết là có lỗi triển khai MSI.  Thông thường điều này
được xử lý trong trình điều khiển thiết bị riêng lẻ, nhưng đôi khi điều đó là cần thiết
để xử lý việc này một cách khéo léo.  Một số trình điều khiển có tùy chọn tắt sử dụng
của MSI.  Mặc dù đây là giải pháp thuận tiện cho tác giả trình điều khiển,
đó không phải là cách làm tốt và không nên bắt chước.

Tìm lý do tại sao MSI bị tắt trên thiết bị
------------------------------------------

Từ 3 phần trên có thể thấy có rất nhiều nguyên nhân
tại sao MSI có thể không được kích hoạt cho một thiết bị nhất định.  Bước đầu tiên của bạn nên
hãy kiểm tra dmesg của bạn một cách cẩn thận để xác định xem MSI có được bật hay không
cho máy của bạn.  Bạn cũng nên kiểm tra .config để chắc chắn rằng bạn
đã kích hoạt CONFIG_PCI_MSI.

Sau đó, 'lspci -t' đưa ra danh sách các cầu nối phía trên thiết bị. Đọc
ZZ0000ZZ sẽ cho bạn biết MSI có được bật hay không (1)
hoặc bị vô hiệu hóa (0).  Nếu tìm thấy 0 trong bất kỳ tệp msi_bus nào thuộc về
để kết nối giữa root PCI và thiết bị, MSI sẽ bị vô hiệu hóa.

Bạn cũng nên kiểm tra trình điều khiển thiết bị để xem liệu nó có hỗ trợ MSI hay không.
Ví dụ: nó có thể chứa các lệnh gọi tới pci_alloc_irq_vectors() với
Cờ PCI_IRQ_MSI hoặc PCI_IRQ_MSIX.


Danh sách trình điều khiển thiết bị API MSI(-X)
===============================================

Hệ thống con PCI/MSI có tệp C dành riêng cho trình điều khiển thiết bị đã xuất của nó
API - ZZ0000ZZ. Các chức năng sau được xuất:

.. kernel-doc:: drivers/pci/msi/api.c
   :export: