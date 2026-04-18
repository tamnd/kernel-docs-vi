.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/tph.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
Hỗ trợ TPH
===========

:Bản quyền: 2024 Advanced Micro Devices, Inc.
:Tác giả: - Eric van Tassell <eric.vantassell@amd.com>
          - Ngụy Hoàng <wei.huang2@amd.com>


Tổng quan
========

TPH (Gợi ý xử lý TLP) là một tính năng PCIe cho phép các thiết bị đầu cuối
để cung cấp gợi ý tối ưu hóa cho các yêu cầu nhắm mục tiêu không gian bộ nhớ.
Những gợi ý này, ở định dạng được gọi là Thẻ chỉ đạo (ST), được nhúng trong
tiêu đề TLP của người yêu cầu, cho phép phần cứng hệ thống, chẳng hạn như Root
Phức tạp, để quản lý tài nguyên nền tảng tốt hơn cho các yêu cầu này.

Ví dụ: trên các nền tảng có tính năng chèn bộ đệm dữ liệu trực tiếp dựa trên TPH
hỗ trợ, thiết bị đầu cuối có thể bao gồm các ST thích hợp trong DMA của nó
lưu lượng truy cập để chỉ định dữ liệu sẽ được ghi vào bộ đệm nào. Điều này cho phép
lõi CPU để có xác suất nhận dữ liệu từ bộ đệm cao hơn,
có khả năng cải thiện hiệu suất và giảm độ trễ trong dữ liệu
xử lý.


Cách sử dụng TPH
==============

TPH được trình bày dưới dạng khả năng mở rộng tùy chọn trong PCIe. Linux
kernel xử lý việc phát hiện TPH trong khi khởi động, nhưng điều đó tùy thuộc vào thiết bị
trình điều khiển yêu cầu kích hoạt TPH nếu nó được sử dụng. Sau khi được kích hoạt,
người lái xe sử dụng API được cung cấp để lấy Thẻ lái cho
bộ nhớ đích và lập trình ST vào bảng ST của thiết bị.

Kích hoạt hỗ trợ TPH trong Linux
---------------------------

Để hỗ trợ TPH, kernel phải được xây dựng với tùy chọn CONFIG_PCIE_TPH
đã bật.

Quản lý TPH
----------

Để bật TPH cho thiết bị, hãy sử dụng chức năng sau ::

int pcie_enable_tph(struct pci_dev *pdev, chế độ int);

Chức năng này cho phép hỗ trợ TPH cho thiết bị có chế độ ST cụ thể.
Các chế độ được hỗ trợ hiện tại bao gồm:

* PCI_TPH_ST_NS_MODE - KHÔNG CÓ Chế độ ST
  * PCI_TPH_ST_IV_MODE - Chế độ vectơ ngắt
  * PCI_TPH_ST_DS_MODE - Chế độ dành riêng cho thiết bị

ZZ0000ZZ kiểm tra xem chế độ được yêu cầu có thực sự hoạt động hay không
được thiết bị hỗ trợ trước khi kích hoạt. Trình điều khiển thiết bị có thể tìm ra
chế độ TPH nào được hỗ trợ và có thể được bật đúng cách dựa trên
giá trị trả về của ZZ0001ZZ.

Để tắt TPH, hãy sử dụng chức năng sau::

void pcie_disable_tph(struct pci_dev *pdev);

Quản lý ST
---------

Thẻ chỉ đạo là nền tảng cụ thể. Thông số PCIe không chỉ định ST ở đâu
đến từ. Thay vào đó, Thông số phần mềm PCI xác định phương thức ACPI _DSM
(xem ZZ0000ZZ) để truy xuất
ST cho bộ nhớ đích có nhiều thuộc tính khác nhau. Phương pháp này là những gì
được hỗ trợ trong việc triển khai này.

Để truy xuất Thẻ chỉ đạo cho bộ nhớ đích được liên kết với một mục tiêu cụ thể
CPU, sử dụng chức năng sau::

int pcie_tph_get_cpu_st(struct pci_dev *pdev, enum tph_mem_type type,
                          cpu int không dấu, thẻ u16 *);

Đối số ZZ0000ZZ được sử dụng để chỉ định loại bộ nhớ, có thể thay đổi
hoặc liên tục của bộ nhớ đích. Đối số ZZ0001ZZ chỉ định
CPU nơi bộ nhớ được liên kết tới.

Sau khi lấy được giá trị ST, trình điều khiển thiết bị có thể sử dụng thông tin sau
chức năng ghi ST vào thiết bị::

int pcie_tph_set_st_entry(struct pci_dev *pdev, chỉ mục int không dấu,
                            thẻ u16);

Đối số ZZ0000ZZ là chỉ mục mục nhập bảng ST mà thẻ ST sẽ là
được viết vào. ZZ0001ZZ sẽ tìm ra cách thích hợp
vị trí của bảng ST, trong bảng MSI-X hoặc trong TPH Extended
Không gian khả năng và ghi Thẻ chỉ đạo vào mục ST được chỉ bởi
đối số ZZ0002ZZ.

Người lái xe hoàn toàn có quyền quyết định cách sử dụng những chiếc TPH này
chức năng. Ví dụ: trình điều khiển thiết bị mạng có thể sử dụng API TPH ở trên
để cập nhật Thẻ chỉ đạo khi mối quan hệ gián đoạn của hàng đợi RX/TX có
đã được thay đổi. Đây là mã mẫu cho trình thông báo mối quan hệ IRQ:

.. code-block:: c

    static void irq_affinity_notified(struct irq_affinity_notify *notify,
                                      const cpumask_t *mask)
    {
         struct drv_irq *irq;
         unsigned int cpu_id;
         u16 tag;

         irq = container_of(notify, struct drv_irq, affinity_notify);
         cpumask_copy(irq->cpu_mask, mask);

         /* Pick a right CPU as the target - here is just an example */
         cpu_id = cpumask_first(irq->cpu_mask);

         if (pcie_tph_get_cpu_st(irq->pdev, TPH_MEM_TYPE_VM, cpu_id,
                                 &tag))
             return;

         if (pcie_tph_set_st_entry(irq->pdev, irq->msix_nr, tag))
             return;
    }

Vô hiệu hóa TPH trên toàn hệ thống
-----------------------

Có sẵn một tùy chọn dòng lệnh kernel để kiểm soát tính năng TPH:
    * "notph": TPH sẽ bị tắt đối với tất cả các thiết bị đầu cuối.