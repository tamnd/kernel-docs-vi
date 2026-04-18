.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/pci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Cách viết trình điều khiển Linux PCI
====================================

:Tác giả: - Martin Mares <mj@ucw.cz>
          - Grant Grundler <grundler@parisc-linux.org>

Thế giới của PCI rất rộng lớn và đầy rẫy những điều bất ngờ (hầu hết là khó chịu).
Vì mỗi kiến trúc CPU triển khai các bộ chip và thiết bị PCI khác nhau
có các yêu cầu khác nhau (erm, "tính năng"), kết quả là hỗ trợ PCI
trong nhân Linux không tầm thường như người ta mong muốn. Bài viết ngắn này
cố gắng giới thiệu tất cả các tác giả trình điều khiển tiềm năng với API Linux cho
Trình điều khiển thiết bị PCI.

Một nguồn tài nguyên đầy đủ hơn là phiên bản thứ ba của "Trình điều khiển thiết bị Linux"
của Jonathan Corbet, Alessandro Rubini và Greg Kroah-Hartman.
LDD3 có sẵn miễn phí (theo Giấy phép Creative Commons) từ:
ZZ0000ZZ

Tuy nhiên, hãy nhớ rằng tất cả các tài liệu đều có thể bị "thối bit".
Hãy tham khảo mã nguồn nếu mọi thứ không hoạt động như mô tả ở đây.

Vui lòng gửi câu hỏi/nhận xét/bản vá về Linux PCI API tới
Danh sách gửi thư "Linux PCI" <linux-pci@atrey.karlin.mff.cuni.cz>.


Cấu trúc driver PCI
========================
Trình điều khiển PCI "khám phá" các thiết bị PCI trong hệ thống thông qua pci_register_driver().
Thực ra thì ngược lại. Khi mã chung PCI phát hiện
một thiết bị mới, trình điều khiển có "mô tả" phù hợp sẽ được thông báo.
Chi tiết về điều này dưới đây.

pci_register_driver() để lại phần lớn việc thăm dò cho các thiết bị
lớp PCI và hỗ trợ chèn/xóa thiết bị trực tuyến [do đó
hỗ trợ PCI, CardBus và Express-Card có thể cắm nóng trong một trình điều khiển duy nhất].
Cuộc gọi pci_register_driver() yêu cầu chuyển vào bảng hàm
con trỏ và do đó quyết định cấu trúc cấp cao của trình điều khiển.

Sau khi người lái xe biết về thiết bị PCI và nắm quyền sở hữu,
trình điều khiển thường cần thực hiện việc khởi tạo sau:

- Kích hoạt thiết bị
  - Yêu cầu tài nguyên MMIO/IOP
  - Đặt kích thước mặt nạ DMA (cho cả DMA kết hợp và phát trực tuyến)
  - Phân bổ và khởi tạo dữ liệu điều khiển dùng chung (pci_allocate_coherent())
  - Truy cập không gian cấu hình thiết bị (nếu cần)
  - Đăng ký trình xử lý IRQ (request_irq())
  - Khởi tạo các phần không phải PCI (tức là các phần LAN/SCSI/etc của chip)
  - Kích hoạt DMA/công cụ xử lý

Khi sử dụng xong thiết bị và có lẽ cần phải dỡ mô-đun xuống,
người lái xe cần thực hiện các bước sau:

- Vô hiệu hóa thiết bị tạo IRQ
  - Giải phóng IRQ (free_irq())
  - Dừng mọi hoạt động của DMA
  - Phát hành bộ đệm DMA (cả phát trực tuyến và kết hợp)
  - Hủy đăng ký khỏi các hệ thống con khác (ví dụ scsi hoặc netdev)
  - Phát hành tài nguyên MMIO/IOP
  - Vô hiệu hóa thiết bị

Hầu hết các chủ đề này được đề cập trong các phần sau.
Đối với phần còn lại, hãy xem LDD3 hoặc <linux/pci.h> .

Nếu hệ thống con PCI không được định cấu hình (CONFIG_PCI chưa được đặt), hầu hết
các hàm PCI được mô tả bên dưới cũng được định nghĩa là các hàm nội tuyến
hoàn toàn trống hoặc chỉ trả lại mã lỗi thích hợp để tránh
rất nhiều ifdefs trong trình điều khiển.


cuộc gọi pci_register_driver()
==========================

Trình điều khiển thiết bị PCI gọi ZZ0000ZZ trong quá trình
khởi tạo bằng con trỏ tới cấu trúc mô tả trình điều khiển
(ZZ0001ZZ):

.. kernel-doc:: include/linux/pci.h
   :functions: pci_driver

Bảng ID là một mảng các mục ZZ0000ZZ kết thúc bằng một
mục nhập hoàn toàn bằng không.  Các định nghĩa có const tĩnh thường được ưa thích hơn.

.. kernel-doc:: include/linux/mod_devicetable.h
   :functions: pci_device_id

Hầu hết các trình điều khiển chỉ cần ZZ0000ZZ hoặc ZZ0001ZZ để thiết lập
một bảng pci_device_id.

ID PCI mới có thể được thêm vào bảng pci_ids của trình điều khiển thiết bị khi chạy
như hình dưới đây::

echo "nhà cung cấp thiết bị nhà cung cấp lớp thiết bị phụ class_mask driver_data"> \
  /sys/bus/pci/drivers/{driver}/new_id

Tất cả các trường được chuyển vào dưới dạng giá trị thập lục phân (không có 0x đứng đầu).
Các trường nhà cung cấp và thiết bị là bắt buộc, các trường khác là tùy chọn. Người dùng
chỉ cần chuyển nhiều trường tùy chọn nếu cần:

- các trường nhà cung cấp phụ và thiết bị phụ mặc định là PCI_ANY_ID (FFFFFFFF)
  - trường lớp và mặt nạ lớp mặc định là 0
  - driver_data mặc định là 0UL.
  - trường ghi đè_chỉ mặc định là 0.

Lưu ý rằng driver_data phải khớp với giá trị được sử dụng bởi bất kỳ pci_device_id nào
các mục được xác định trong trình điều khiển. Điều này làm cho trường driver_data bắt buộc
nếu tất cả các mục pci_device_id có giá trị driver_data khác 0.

Sau khi được thêm vào, quy trình thăm dò trình điều khiển sẽ được gọi cho bất kỳ thông tin nào chưa được xác nhận quyền sở hữu.
Các thiết bị PCI được liệt kê trong danh sách pci_ids (mới cập nhật).

Khi trình điều khiển thoát, nó chỉ gọi pci_unregister_driver() và lớp PCI
tự động gọi móc gỡ bỏ cho tất cả các thiết bị do trình điều khiển xử lý.


"Thuộc tính" cho chức năng/dữ liệu trình điều khiển
--------------------------------------

Vui lòng đánh dấu các chức năng khởi tạo và dọn dẹp khi thích hợp
(các macro tương ứng được xác định trong <linux/init.h>):

============================================================
	__init Mã khởi tạo. Bị vứt bỏ sau tài xế
			khởi tạo.
	__exit Mã thoát. Bỏ qua đối với trình điều khiển không mô-đun.
	============================================================

Lời khuyên về thời điểm/địa điểm sử dụng các thuộc tính trên:
	- Các hàm module_init()/module_exit() (và tất cả
	  các hàm khởi tạo được gọi là _only_ từ những hàm này)
	  nên được đánh dấu là __init/__exit.

- Không đánh dấu struct pci_driver.

- Hãy đánh dấu NOT vào một chức năng nếu bạn không chắc chắn nên sử dụng dấu nào.
	  Thà không đánh dấu chức năng còn hơn đánh dấu chức năng sai.


Cách tìm thiết bị PCI theo cách thủ công
================================

Trình điều khiển PCI phải có lý do thực sự chính đáng để không sử dụng
Giao diện pci_register_driver() để tìm kiếm thiết bị PCI.
Lý do chính khiến thiết bị PCI được điều khiển bởi nhiều trình điều khiển
là do một thiết bị PCI triển khai một số dịch vụ CTNH khác nhau.
Ví dụ. kết hợp cổng nối tiếp/song song/bộ điều khiển đĩa mềm.

Tìm kiếm thủ công có thể được thực hiện bằng cách sử dụng các cấu trúc sau:

Tìm kiếm theo ID nhà cung cấp và thiết bị::

struct pci_dev *dev = NULL;
	trong khi (dev = pci_get_device(VENDOR_ID, DEVICE_ID, dev))
		configure_device(dev);

Tìm kiếm theo ID lớp (lặp lại theo cách tương tự)::

pci_get_class(CLASS_ID, dev)

Tìm kiếm theo cả nhà cung cấp/thiết bị và ID nhà cung cấp/thiết bị hệ thống con::

pci_get_subsys(VENDOR_ID,DEVICE_ID, SUBSYS_VENDOR_ID, SUBSYS_DEVICE_ID, dev).

Bạn có thể sử dụng hằng số PCI_ANY_ID để thay thế ký tự đại diện cho
VENDOR_ID hoặc DEVICE_ID.  Điều này cho phép tìm kiếm bất kỳ thiết bị nào từ một
nhà cung cấp cụ thể, ví dụ.

Các chức năng này an toàn khi cắm nóng. Họ tăng số lượng tham chiếu trên
pci_dev mà họ trả lại. Cuối cùng bạn phải (có thể là lúc dỡ mô-đun)
giảm số lượng tham chiếu trên các thiết bị này bằng cách gọi pci_dev_put().


Các bước khởi tạo thiết bị
===========================

Như đã lưu ý trong phần giới thiệu, hầu hết trình điều khiển PCI đều cần các bước sau
để khởi tạo thiết bị:

- Kích hoạt thiết bị
  - Yêu cầu tài nguyên MMIO/IOP
  - Đặt kích thước mặt nạ DMA (cho cả DMA kết hợp và phát trực tuyến)
  - Phân bổ và khởi tạo dữ liệu điều khiển dùng chung (pci_allocate_coherent())
  - Truy cập không gian cấu hình thiết bị (nếu cần)
  - Đăng ký trình xử lý IRQ (request_irq())
  - Khởi tạo các phần không phải PCI (tức là các phần LAN/SCSI/etc của chip)
  - Kích hoạt DMA/công cụ xử lý.

Trình điều khiển có thể truy cập vào các thanh ghi không gian cấu hình PCI bất cứ lúc nào.
(À, gần như vậy. Khi chạy BIST, dung lượng cấu hình có thể biến mất...nhưng
điều đó sẽ chỉ dẫn đến việc hủy bỏ PCI Bus Master và đọc cấu hình
sẽ trả lại rác).


Kích hoạt thiết bị PCI
---------------------
Trước khi chạm vào bất kỳ thanh ghi thiết bị nào, trình điều khiển cần kích hoạt
thiết bị PCI bằng cách gọi pci_enable_device(). Điều này sẽ:

- đánh thức thiết bị nếu thiết bị ở trạng thái treo,
  - phân bổ vùng I/O và bộ nhớ của thiết bị (nếu BIOS không có),
  - phân bổ IRQ (nếu BIOS không có).

.. note::
   pci_enable_device() có thể thất bại! Kiểm tra giá trị trả về.
.. warning::
   OS BUG: chúng tôi không kiểm tra việc phân bổ tài nguyên trước khi kích hoạt chúng
   tài nguyên. Trình tự sẽ có ý nghĩa hơn nếu chúng ta gọi
   pci_request_resources() trước khi gọi pci_enable_device().
   Hiện tại, trình điều khiển thiết bị không thể phát hiện lỗi khi hai
   các thiết bị đã được phân bổ cùng một phạm vi. Đây không phải là điều phổ biến
   vấn đề và khó có thể được khắc phục sớm.

   Điều này đã được thảo luận trước đây nhưng không thay đổi kể từ phiên bản 2.6.19:
   ZZ0000ZZ
pci_set_master() sẽ kích hoạt DMA bằng cách đặt bit chính của bus
trong thanh ghi PCI_COMMAND. Nó cũng sửa giá trị bộ đếm thời gian trễ nếu
nó được đặt thành thứ gì đó không có thật bởi BIOS.  pci_clear_master() sẽ
vô hiệu hóa DMA bằng cách xóa bit chính của bus.

Nếu thiết bị PCI có thể sử dụng giao dịch PCI Memory-Write-Invalidate,
gọi pci_set_mwi().  Điều này kích hoạt bit PCI_COMMAND cho Mem-Wr-Inval
và cũng đảm bảo rằng thanh ghi kích thước dòng bộ đệm được đặt chính xác.
Kiểm tra giá trị trả về của pci_set_mwi() vì không phải tất cả các kiến trúc
hoặc bộ chip có thể hỗ trợ Bộ nhớ-Ghi-Không hợp lệ.  Ngoài ra,
nếu có Mem-Wr-Inval thì tốt nhưng không bắt buộc, hãy gọi
pci_try_set_mwi() để hệ thống nỗ lực hết sức trong việc kích hoạt
Mem-Wr-Không hợp lệ.


Yêu cầu tài nguyên MMIO/IOP
--------------------------
Bộ nhớ (MMIO) và địa chỉ cổng I/O nên được đọc trực tiếp NOT
từ không gian cấu hình thiết bị PCI. Sử dụng các giá trị trong cấu trúc pci_dev
vì "địa chỉ xe buýt" PCI có thể đã được ánh xạ lại thành "địa chỉ máy chủ vật lý"
địa chỉ bằng cách hỗ trợ hạt nhân cụ thể của Arch/chip-set.

Xem Documentation/driver-api/io-mapping.rst để biết cách truy cập vào sổ đăng ký thiết bị
hoặc bộ nhớ thiết bị.

Trình điều khiển thiết bị cần gọi pci_request_zone() để xác minh
không có thiết bị nào khác đang sử dụng cùng một tài nguyên địa chỉ.
Ngược lại, trình điều khiển nên gọi pci_release_khu vực() AFTER
đang gọi pci_disable_device().
Ý tưởng là ngăn chặn hai thiết bị xung đột trên cùng một dải địa chỉ.

.. tip::
   Xem nhận xét về OS BUG ở trên. Hiện tại (2.6.19), Người lái xe chỉ có thể
   xác định tính khả dụng của tài nguyên Cổng MMIO và IO _sau khi gọi
   pci_enable_device().
Hương vị chung của pci_request_khu vực() là request_mem_khu vực()
(đối với phạm vi MMIO) và request_khu vực() (đối với phạm vi Cổng IO).
Sử dụng chúng cho các tài nguyên địa chỉ không được mô tả bởi PCI "bình thường"
BAR.

Đồng thời xem pci_request_selected_zones() bên dưới.


Đặt kích thước mặt nạ DMA
---------------------
.. note::
   Nếu bất cứ điều gì dưới đây không có ý nghĩa, vui lòng tham khảo
   Tài liệu/core-api/dma-api.rst. Phần này chỉ là một lời nhắc nhở rằng
   trình điều khiển cần chỉ ra khả năng DMA của thiết bị và không
   một nguồn có thẩm quyền cho các giao diện DMA.
Mặc dù tất cả các trình điều khiển phải chỉ rõ khả năng của DMA
(ví dụ: 32 hoặc 64 bit) của bus chính PCI, các thiết bị có nhiều hơn
Khả năng chính của bus 32-bit để truyền dữ liệu cần có trình điều khiển
để "đăng ký" khả năng này bằng cách gọi dma_set_mask() với
các thông số thích hợp.  Nói chung điều này cho phép DMA hiệu quả hơn
trên các hệ thống có Hệ thống RAM tồn tại trên địa chỉ _physical_ 4G.

Trình điều khiển cho tất cả các thiết bị tuân thủ PCI-X và PCIe phải gọi
dma_set_mask() vì chúng là thiết bị DMA 64-bit.

Tương tự, trình điều khiển cũng phải “đăng ký” khả năng này nếu thiết bị
có thể xử lý trực tiếp "bộ nhớ mạch lạc" trong Hệ thống RAM trên vật lý 4G
địa chỉ bằng cách gọi dma_set_coherent_mask().
Một lần nữa, điều này bao gồm trình điều khiển cho tất cả các thiết bị tương thích PCI-X và PCIe.
Nhiều thiết bị "PCI" 64-bit (trước PCI-X) và một số thiết bị PCI-X
DMA 64-bit có khả năng tải dữ liệu ("truyền phát") nhưng không kiểm soát được
dữ liệu ("mạch lạc").


Thiết lập dữ liệu điều khiển dùng chung
-------------------------
Sau khi đặt mặt nạ DMA, trình điều khiển có thể phân bổ "kết hợp" (còn gọi là chia sẻ)
trí nhớ.  Xem Documentation/core-api/dma-api.rst để biết mô tả đầy đủ về
API DMA. Phần này chỉ là một lời nhắc nhở rằng nó cần phải được thực hiện
trước khi kích hoạt DMA trên thiết bị.


Khởi tạo thanh ghi thiết bị
---------------------------
Một số trình điều khiển sẽ cần các trường "khả năng" cụ thể được lập trình
hoặc đăng ký "nhà cung cấp cụ thể" khác được khởi tạo hoặc đặt lại.
Ví dụ. xóa các ngắt đang chờ xử lý.


Đăng ký trình xử lý IRQ
--------------------
Trong khi gọi request_irq() là bước cuối cùng được mô tả ở đây,
đây thường chỉ là một bước trung gian khác để khởi tạo thiết bị.
Bước này thường có thể được trì hoãn cho đến khi thiết bị được mở ra để sử dụng.

Tất cả các trình xử lý ngắt cho dòng IRQ phải được đăng ký với IRQF_SHARED
và sử dụng devid để ánh xạ IRQ tới các thiết bị (hãy nhớ rằng tất cả các dòng PCI IRQ
có thể được chia sẻ).

request_irq() sẽ liên kết trình xử lý ngắt và trình xử lý thiết bị
với một số ngắt. Các số gián đoạn trong lịch sử đại diện cho
Các dòng IRQ chạy từ thiết bị PCI đến Bộ điều khiển ngắt.
Với MSI và MSI-X (xem thêm bên dưới), số ngắt là "vectơ" CPU.

request_irq() cũng cho phép ngắt. Đảm bảo thiết bị được
đã ngừng hoạt động và không có bất kỳ gián đoạn nào đang chờ xử lý trước khi đăng ký
trình xử lý ngắt.

MSI và MSI-X là các khả năng của PCI. Cả hai đều là "Ngắt báo hiệu tin nhắn"
cung cấp các ngắt tới CPU thông qua DMA ghi vào APIC cục bộ.
Sự khác biệt cơ bản giữa MSI và MSI-X là số lượng
"vectơ" được phân bổ. MSI yêu cầu các khối vectơ liền kề
trong khi MSI-X có thể phân bổ một số cái riêng lẻ.

Khả năng MSI có thể được kích hoạt bằng cách gọi pci_alloc_irq_vectors() bằng
Cờ PCI_IRQ_MSI và/hoặc PCI_IRQ_MSIX trước khi gọi request_irq(). Cái này
khiến bộ phận hỗ trợ PCI lập trình dữ liệu vectơ CPU vào thiết bị PCI
các thanh ghi năng lực. Nhiều kiến trúc, bộ chip hoặc BIOS sử dụng NOT
hỗ trợ MSI hoặc MSI-X và gọi tới pci_alloc_irq_vectors chỉ bằng
cờ PCI_IRQ_MSI và PCI_IRQ_MSIX sẽ không thành công, vì vậy hãy cố gắng luôn
chỉ định PCI_IRQ_INTX.

Trình điều khiển có các trình xử lý ngắt khác nhau cho MSI/MSI-X và
INTx kế thừa nên chọn đúng dựa trên msi_enabled
và cờ msix_enabled trong cấu trúc pci_dev sau khi gọi
pci_alloc_irq_vectors.

Có (ít nhất) hai lý do thực sự chính đáng để sử dụng MSI:

1) Theo định nghĩa, MSI là một vectơ ngắt độc quyền.
   Điều này có nghĩa là trình xử lý ngắt không phải xác minh
   thiết bị của nó gây ra sự gián đoạn.

2) MSI tránh các điều kiện đua DMA/IRQ. DMA cho bộ nhớ máy chủ được đảm bảo
   được hiển thị với (các) máy chủ CPU khi MSI được phân phối. Cái này
   rất quan trọng đối với cả tính mạch lạc của dữ liệu và tránh dữ liệu kiểm soát cũ.
   Bảo đảm này cho phép người lái xe bỏ qua các lần đọc MMIO để xả
   luồng DMA.

Xem driver/infiniband/hw/mthca/ hoặc driver/net/tg3.c để biết ví dụ
mức sử dụng MSI/MSI-X.


Tắt thiết bị PCI
===================

Khi trình điều khiển thiết bị PCI đang được tải xuống, hầu hết những điều sau đây
các bước cần thực hiện:

- Vô hiệu hóa thiết bị tạo IRQ
  - Giải phóng IRQ (free_irq())
  - Dừng mọi hoạt động của DMA
  - Phát hành bộ đệm DMA (cả phát trực tuyến và kết hợp)
  - Hủy đăng ký khỏi các hệ thống con khác (ví dụ scsi hoặc netdev)
  - Vô hiệu hóa thiết bị phản hồi với các địa chỉ Cổng MMIO/IO
  - Giải phóng (các) tài nguyên Cổng MMIO/IO


Dừng IRQ trên thiết bị
-----------------------
Cách thực hiện việc này tùy thuộc vào chip/thiết bị cụ thể. Nếu chưa xong thì nó sẽ mở ra
khả năng xảy ra "sự gián đoạn la hét" nếu (và chỉ khi)
IRQ được chia sẻ với một thiết bị khác.

Khi trình xử lý IRQ được chia sẻ "không được kết nối", các thiết bị còn lại
sử dụng cùng dòng IRQ vẫn cần kích hoạt IRQ. Như vậy nếu
thiết bị "không nối" xác nhận dòng IRQ, hệ thống sẽ phản hồi giả định
nó là một trong những thiết bị còn lại khẳng định dòng IRQ. Vì không có
của các thiết bị khác sẽ xử lý IRQ, hệ thống sẽ "treo" cho đến khi
nó quyết định IRQ sẽ không được xử lý và che giấu IRQ (100.000
lần lặp lại sau). Sau khi IRQ được chia sẻ bị che, các thiết bị còn lại
sẽ ngừng hoạt động bình thường. Không phải là một tình huống tốt đẹp.

Đây là một lý do khác để sử dụng MSI hoặc MSI-X nếu có.
MSI và MSI-X được định nghĩa là các ngắt độc quyền và do đó
không dễ gặp phải vấn đề "la hét ngắt quãng".


Phát hành IRQ
---------------
Khi thiết bị không hoạt động (không còn IRQ nữa), người ta có thể gọi free_irq().
Chức năng này sẽ trả lại quyền kiểm soát khi mọi IRQ đang chờ xử lý được xử lý,
"tháo" trình xử lý IRQ của trình điều khiển khỏi IRQ đó và cuối cùng giải phóng
IRQ nếu không có ai khác đang sử dụng nó.


Dừng mọi hoạt động của DMA
---------------------
Điều cực kỳ quan trọng là phải dừng tất cả các hoạt động DMA mà BEFORE đang cố gắng thực hiện
để giải phóng dữ liệu điều khiển DMA. Không làm như vậy có thể dẫn đến mất trí nhớ
tham nhũng, treo máy và trên một số bộ chip gặp sự cố nghiêm trọng.

Dừng DMA sau khi dừng IRQ có thể tránh được các cuộc đua trong đó
Trình xử lý IRQ có thể khởi động lại động cơ DMA.

Mặc dù bước này nghe có vẻ hiển nhiên và tầm thường nhưng một số trình điều khiển "trưởng thành"
trước đây đã không thực hiện được bước này.


Phát hành bộ đệm DMA
-------------------
Sau khi dừng DMA, trước tiên hãy dọn dẹp luồng DMA.
tức là hủy ánh xạ bộ đệm dữ liệu và trả bộ đệm về "ngược dòng"
chủ sở hữu nếu có.

Sau đó dọn sạch bộ đệm "kết hợp" chứa dữ liệu điều khiển.

Xem Documentation/core-api/dma-api.rst để biết chi tiết về các giao diện hủy ánh xạ.


Hủy đăng ký khỏi các hệ thống con khác
--------------------------------
Hầu hết các trình điều khiển thiết bị PCI cấp thấp đều hỗ trợ một số hệ thống con khác
như USB, ALSA, SCSI, NetDev, Infiniband, v.v. Hãy đảm bảo rằng bạn
trình điều khiển không bị mất tài nguyên từ hệ thống con khác.
Nếu điều này xảy ra, triệu chứng thường là Rất tiếc (hoảng loạn) khi
hệ thống con cố gắng gọi vào trình điều khiển đã được dỡ tải.


Vô hiệu hóa Thiết bị phản hồi với các địa chỉ Cổng MMIO/IO
--------------------------------------------------------
io_unmap() MMIO hoặc tài nguyên Cổng IO rồi gọi pci_disable_device().
Đây là sự đối lập đối xứng của pci_enable_device().
Không truy cập vào thanh ghi thiết bị sau khi gọi pci_disable_device().


Phát hành (các) tài nguyên cổng MMIO/IO
--------------------------------
Gọi pci_release_khu vực() để đánh dấu phạm vi Cổng MMIO hoặc IO nếu có.
Việc không làm như vậy thường dẫn đến việc không thể tải lại trình điều khiển.


Cách truy cập không gian cấu hình PCI
==============================

Bạn có thể sử dụng ZZ0000ZZ để truy cập cấu hình
không gian của thiết bị được đại diện bởi ZZ0001ZZ. Tất cả các hàm này đều trả về
0 khi thành công hoặc mã lỗi (ZZ0002ZZ) có thể được dịch sang
chuỗi văn bản bởi pcibios_strerror. Hầu hết các trình điều khiển đều mong đợi quyền truy cập vào PCI hợp lệ
thiết bị không bị lỗi.

Nếu bạn không có sẵn struct pci_dev, bạn có thể gọi
ZZ0000ZZ để truy cập một thiết bị nhất định
và hoạt động trên xe buýt đó.

Nếu bạn truy cập các trường trong phần tiêu chuẩn của tiêu đề cấu hình, vui lòng
sử dụng tên tượng trưng của các vị trí và bit được khai báo trong <linux/pci.h>.

Nếu bạn cần truy cập vào các thanh ghi Khả năng PCI mở rộng, chỉ cần gọi
pci_find_capability() cho khả năng cụ thể và nó sẽ tìm thấy
khối đăng ký tương ứng cho bạn.


Các chức năng thú vị khác
===========================

===================================================================================
pci_get_domain_bus_and_slot() Tìm pci_dev tương ứng với tên miền đã cho,
				xe buýt và khe cắm và số. Nếu thiết bị là
				được tìm thấy, số lượng tham chiếu của nó được tăng lên.
pci_set_power_state() Đặt trạng thái Quản lý nguồn PCI (0=D0 ... 3=D3)
pci_find_capability() Tìm khả năng được chỉ định trong khả năng của thiết bị
				danh sách.
pci_resource_start() Trả về địa chỉ bắt đầu bus cho vùng PCI nhất định
pci_resource_end() Trả về địa chỉ cuối bus cho vùng PCI nhất định
pci_resource_len() Trả về độ dài byte của vùng PCI
pci_set_drvdata() Đặt con trỏ dữ liệu trình điều khiển riêng cho pci_dev
pci_get_drvdata() Trả về con trỏ dữ liệu trình điều khiển riêng cho pci_dev
pci_set_mwi() Kích hoạt các giao dịch Ghi-Ghi-Không hợp lệ.
pci_clear_mwi() Tắt các giao dịch Bộ nhớ-Ghi-Không hợp lệ.
===================================================================================


Gợi ý khác
===================

Khi hiển thị tên thiết bị PCI cho người dùng (ví dụ: khi trình điều khiển muốn
để cho người dùng biết thẻ đã được tìm thấy), vui lòng sử dụng pci_name(pci_dev).

Luôn tham khảo các thiết bị PCI bằng con trỏ tới cấu trúc pci_dev.
Tất cả các chức năng của lớp PCI đều sử dụng nhận dạng này và đây là chức năng duy nhất
hợp lý một. Không sử dụng số bus/khe/chức năng ngoại trừ rất
mục đích đặc biệt -- trên các hệ thống có nhiều bus chính, ngữ nghĩa của chúng
có thể khá phức tạp.

Đừng cố bật chức năng ghi Fast Back to Back trong trình điều khiển của bạn.  Tất cả các thiết bị
trên xe buýt cần có khả năng thực hiện việc đó, vì vậy đây là điều cần
được xử lý bởi nền tảng và mã chung, không phải trình điều khiển riêng lẻ.


Nhận dạng nhà cung cấp và thiết bị
=================================

Không thêm ID thiết bị hoặc ID nhà cung cấp mới vào include/linux/pci_ids.h trừ khi chúng
được chia sẻ trên nhiều trình điều khiển.  Bạn có thể thêm các định nghĩa riêng tư vào
trình điều khiển của bạn nếu chúng hữu ích hoặc chỉ sử dụng các hằng số hex đơn giản.

ID thiết bị là số hex tùy ý (do nhà cung cấp kiểm soát) và thường được sử dụng
chỉ ở một vị trí duy nhất, bảng pci_device_id.

Vui lòng gửi ID nhà cung cấp/thiết bị mới tới ZZ0000ZZ
Có bản sao của tệp pci.ids tại ZZ0001ZZ


Chức năng lỗi thời
==================

Có một số chức năng mà bạn có thể gặp phải khi cố gắng
chuyển trình điều khiển cũ sang giao diện PCI mới.  Họ không còn hiện diện
trong kernel vì chúng không tương thích với các miền hotplug hoặc PCI hoặc
có khóa lành mạnh.

=================================================================
pci_find_device() Được thay thế bởi pci_get_device()
pci_find_subsys() Được thay thế bởi pci_get_subsys()
pci_find_slot() Được thay thế bởi pci_get_domain_bus_and_slot()
pci_get_slot() Được thay thế bởi pci_get_domain_bus_and_slot()
=================================================================

Giải pháp thay thế là trình điều khiển thiết bị PCI truyền thống hướng dẫn PCI
danh sách thiết bị. Điều này vẫn có thể nhưng không được khuyến khích.


MMIO Không gian và "Viết bài"
==============================

Chuyển đổi trình điều khiển từ sử dụng không gian Cổng I/O sang sử dụng không gian MMIO
thường yêu cầu một số thay đổi bổ sung. Cụ thể là "viết bài"
cần phải được xử lý. Nhiều trình điều khiển (ví dụ: tg3, acenic, sym53c8xx_2)
đã làm điều này rồi. Không gian cổng I/O đảm bảo giao dịch ghi đạt PCI
thiết bị trước khi CPU có thể tiếp tục. Ghi vào không gian MMIO cho phép CPU
để tiếp tục trước khi giao dịch đến thiết bị PCI. tuần lễ CT
gọi đây là "Viết bài" vì việc hoàn thành viết được "đăng" lên
CPU trước khi giao dịch đến đích.

Do đó, mã nhạy cảm về thời gian nên thêm readl() trong đó CPU
dự kiến ​​sẽ chờ đợi trước khi làm công việc khác.  Cú "đập bit" kinh điển
trình tự hoạt động tốt đối với không gian Cổng I/O::

for (i = 8; --i; val >>= 1) {
               outb(val & 1, ioport_reg);      /*ghi bit*/
               độ trễ(10);
       }

Trình tự tương tự cho không gian MMIO phải là::

for (i = 8; --i; val >>= 1) {
               writeb(val & 1, mmio_reg);      /*ghi bit*/
               readb(safe_mmio_reg);           /* xóa đã đăng ghi */
               độ trễ(10);
       }

Điều quan trọng là "safe_mmio_reg" không có bất kỳ tác dụng phụ nào
cản trở hoạt động chính xác của thiết bị.

Một trường hợp khác cần chú ý là khi reset thiết bị PCI. Sử dụng PCI
Không gian cấu hình đọc để xóa writel(). Điều này sẽ duyên dáng
xử lý việc hủy bỏ chính PCI trên tất cả các nền tảng nếu thiết bị PCI
dự kiến sẽ không phản hồi với readl().  Hầu hết các nền tảng x86 sẽ cho phép
MMIO đọc để hủy bỏ chính (còn gọi là "Lỗi mềm") và trả lại rác
(ví dụ: ~0). Nhưng nhiều nền tảng RISC sẽ gặp sự cố (còn gọi là "Hard Fail").