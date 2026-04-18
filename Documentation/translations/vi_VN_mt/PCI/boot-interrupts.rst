.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/boot-interrupts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Ngắt khởi động
=================

:Tác giả: - Sean V Kelley <sean.v.kelley@linux.intel.com>

Tổng quan
=========

Trên PCI Express, các ngắt được biểu diễn bằng MSI hoặc inbound
thông báo ngắt (Assert_INTx/Deassert_INTx). IO-APIC tích hợp trong một
Core IO đã cho sẽ chuyển đổi các thông báo ngắt kế thừa từ PCI Express thành
MSI ngắt.  Nếu IO-APIC bị tắt (thông qua các bit mặt nạ trong
IO-APIC trong bảng), các tin nhắn sẽ được chuyển đến PCH cũ. Cái này
Cơ chế ngắt trong băng tần theo truyền thống là cần thiết cho các hệ thống
không hỗ trợ IO-APIC và để khởi động. Intel trước đây đã sử dụng
thuật ngữ "ngắt khởi động" để mô tả cơ chế này. Hơn nữa, PCI Express
giao thức mô tả cơ chế INTx ngắt dây kế thừa trong băng tần này cho
Các thiết bị I/O để báo hiệu các ngắt mức kiểu PCI. Các đoạn tiếp theo
mô tả các vấn đề với việc xử lý Core IO của việc định tuyến tin nhắn INTx tới
PCH và biện pháp giảm thiểu trong BIOS và HĐH.


Vấn đề
======

Khi các tin nhắn INTx kế thừa trong băng tần được chuyển tiếp tới PCH, chúng sẽ lần lượt
kích hoạt một ngắt mới mà hệ điều hành có thể thiếu trình xử lý. Khi một
ngắt không được xử lý theo thời gian, chúng sẽ được nhân Linux theo dõi dưới dạng
Ngắt giả. IRQ sẽ bị nhân Linux vô hiệu hóa sau đó
đạt đến số lượng cụ thể với lỗi "không ai quan tâm". Điều này đã vô hiệu hóa IRQ
bây giờ ngăn chặn việc sử dụng hợp lệ bởi một ngắt hiện có có thể xảy ra để chia sẻ
dòng IRQ::

irq 19: không ai quan tâm (thử khởi động với tùy chọn "irqpoll")
  CPU: 0 PID: 2988 Comm: irq/34-nipalk Bị nhiễm độc: 4.14.87-rt49-02410-g4a640ec-dirty #1
  Tên phần cứng: National Instruments NI PXIe-8880/NI PXIe-8880, BIOS 2.1.5f1 01/09/2020
  Theo dõi cuộc gọi:

<IRQ>
   ? dump_stack+0x46/0x5e
   ? __report_bad_irq+0x2e/0xb0
   ? note_interrupt+0x242/0x290
   ? nNIKAL100_memoryRead16+0x8/0x10 [nikal]
   ? xử lý_irq_event_percpu+0x55/0x70
   ? xử lý_irq_event+0x4f/0x80
   ? xử lý_fasteoi_irq+0x81/0x180
   ? xử lý_irq+0x1c/0x30
   ? do_IRQ+0x41/0xd0
   ? common_interrupt+0x84/0x84
  </IRQ>

người xử lý:
  irq_default_primary_handler luồng usb_hcd_irq
  Vô hiệu hóa IRQ #19


Điều kiện
==========

Việc sử dụng các ngắt theo luồng là điều kiện có khả năng nhất để kích hoạt
vấn đề này ngày hôm nay. Các ngắt theo luồng có thể không được kích hoạt lại sau IRQ
người xử lý thức dậy. Các điều kiện "một lần" này có nghĩa là ngắt theo luồng
cần phải che dấu dòng ngắt cho đến khi trình xử lý luồng chạy.
Đặc biệt khi xử lý các ngắt tốc độ dữ liệu cao, luồng cần phải
chạy đến khi hoàn thành; nếu không thì một số trình xử lý sẽ bị tràn ngăn xếp
vì ngắt của thiết bị phát hành vẫn còn hoạt động.

Chipset bị ảnh hưởng
====================

Cơ chế chuyển tiếp ngắt kế thừa tồn tại ngày nay trong một số
các thiết bị bao gồm nhưng không giới hạn ở các chipset từ AMD/ATI, Broadcom và
Intel. Những thay đổi được thực hiện thông qua các biện pháp giảm thiểu dưới đây đã được áp dụng cho
trình điều khiển/pci/quirks.c

Bắt đầu với ICX, không còn bất kỳ IO-APIC nào trong Core IO nữa
thiết bị.  IO-APIC chỉ có trong PCH.  Các thiết bị được kết nối với Core IO
Cổng gốc PCIe sẽ sử dụng cơ chế MSI/MSI-X gốc.

Giảm nhẹ
===========

Các biện pháp giảm nhẹ có dạng đặc biệt của PCI. Sở thích đã là
trước tiên hãy xác định và sử dụng phương tiện để vô hiệu hóa định tuyến tới PCH.
Trong trường hợp như vậy, có thể thực hiện một cách giải quyết là vô hiệu hóa việc tạo ngắt khởi động.
đã thêm vào. [1]_

Trung tâm điều khiển I/O Intel® 6300ESB
  Đăng ký địa chỉ cơ sở thay thế:
   BIE: Kích hoạt ngắt khởi động

===============================
	  0 Ngắt khởi động được bật.
	  1 Ngắt khởi động bị vô hiệu hóa.
	  ===============================

Intel® Sandy Bridge thông qua máy chủ Xeon dựa trên Sky Lake:
  Kiểm soát ngắt giao thức giao diện mạch lạc
   dis_intx_route2pch/dis_intx_route2ich/dis_intx_route2dmi2:
	  Khi bit này được thiết lập. Tin nhắn INTx cục bộ nhận được từ
	  Các cổng Intel® Quick Data DMA/PCI Express không được định tuyến tới phiên bản cũ
	  PCH - chúng được chuyển đổi thành MSI thông qua IO-APIC tích hợp
	  (nếu bit mặt nạ IO-APIC rõ ràng trong các mục thích hợp)
	  hoặc không gây ra hành động nào nữa (khi bit mặt nạ được đặt)

Trong trường hợp không có cách nào để vô hiệu hóa trực tiếp việc định tuyến, một cách tiếp cận khác
đã sử dụng chốt ngắt PCI cho các bảng định tuyến INTx cho
mục đích chuyển hướng trình xử lý ngắt sang ngắt được định tuyến lại
dòng theo mặc định.  Do đó, trên các chipset không thể thực hiện định tuyến INTx này.
bị vô hiệu hóa, nhân Linux sẽ định tuyến lại ngắt hợp lệ về kế thừa của nó
ngắt lời. Sự chuyển hướng này của trình xử lý sẽ ngăn chặn sự xuất hiện của
phát hiện ngắt giả thường sẽ vô hiệu hóa IRQ
dòng do số lượng chưa được xử lý quá mức. [2]_

Tùy chọn cấu hình X86_REROUTE_FOR_BROKEN_BOOT_IRQS tồn tại để kích hoạt (hoặc
vô hiệu hóa) việc chuyển hướng trình xử lý ngắt sang ngắt PCH
dòng. Tùy chọn này có thể được ghi đè bằng pci=ioapicreroute hoặc
pci=noioapicreroute. [3]_


Thêm tài liệu
==================

Có một cái nhìn tổng quan về cách xử lý ngắt kế thừa trong một số biểu dữ liệu
(6300ESB và 6700PXH bên dưới). Mặc dù phần lớn giống nhau nhưng nó cung cấp cái nhìn sâu sắc
vào sự phát triển của việc xử lý nó với chipset.

Ví dụ về việc vô hiệu hóa ngắt khởi động
------------------------------------------

- Trung tâm điều khiển I/O Intel® 6300ESB (Tài liệu # 300641-004US)
	5.7.3 Ngắt khởi động
	ZZ0000ZZ

- Dòng sản phẩm Bộ xử lý Intel® Xeon® E5-1600/2400/2600/4600 v3
	Bảng dữ liệu - Tập 2: Các thanh ghi (Tài liệu # 330784-003)
	6.6.41 Kiểm soát ngắt giao thức giao diện mạch lạc cipintrc
	ZZ0000ZZ

Ví dụ về việc định tuyến lại trình xử lý
----------------------------------------

- Trung tâm PCI 64-bit Intel® 6700PXH (Tài liệu # 302628)
	2.15.2 PCI Express Legacy Hỗ trợ INTx và ngắt khởi động
	ZZ0000ZZ


Nếu bạn có bất kỳ câu hỏi gián đoạn PCI cũ nào chưa được trả lời, hãy gửi email cho tôi.

Chúc mừng,
    Sean V Kelley
    sean.v.kelley@linux.intel.com

.. [1] https://lore.kernel.org/r/12131949181903-git-send-email-sassmann@suse.de/
.. [2] https://lore.kernel.org/r/12131949182094-git-send-email-sassmann@suse.de/
.. [3] https://lore.kernel.org/r/487C8EA7.6020205@suse.de/