.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/dma.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

USB DMA
~~~~~~~

Trong nhân Linux 2.5 (và phiên bản mới hơn), trình điều khiển thiết bị USB có quyền kiểm soát bổ sung
về cách DMA có thể được sử dụng để thực hiện các thao tác I/O.  Các API rất chi tiết
trong hướng dẫn lập trình kernel usb (kerneldoc, từ mã nguồn).

Tổng quan về API
================

Bức tranh lớn là trình điều khiển USB có thể tiếp tục bỏ qua hầu hết các vấn đề về DMA,
mặc dù họ vẫn phải cung cấp bộ đệm sẵn sàng cho DMA (xem
Tài liệu/core-api/dma-api-howto.rst).  Đó là cách họ đã vượt qua
các hạt nhân 2.4 (và cũ hơn) hoặc giờ đây chúng có thể nhận biết được DMA.

Trình điều khiển USB nhận biết DMA:

- Các cuộc gọi mới kích hoạt trình điều khiển nhận biết DMA, cho phép chúng phân bổ bộ đệm dma và
  quản lý ánh xạ dma cho bộ đệm sẵn sàng cho dma hiện có (xem bên dưới).

- URB có thêm trường "transfer_dma" cũng như transfer_flags
  bit nói nếu nó hợp lệ.  (Yêu cầu điều khiển cũng có "setup_dma", nhưng
  trình điều khiển không được sử dụng nó.)

- "usbcore" sẽ ánh xạ địa chỉ DMA này, nếu trình điều khiển nhận biết DMA không thực hiện
  trước tiên và đặt ZZ0000ZZ.  HCD
  không quản lý ánh xạ dma cho URB.

- Có một "DMA API chung" mới, các bộ phận của thiết bị USB có thể sử dụng được
  trình điều khiển.  Không bao giờ sử dụng dma_set_mask() trên bất kỳ giao diện hoặc thiết bị USB nào; đó
  có khả năng sẽ phá vỡ tất cả các thiết bị chia sẻ xe buýt đó.

Loại bỏ bản sao
==================

Tốt nhất là tránh để CPU sao chép dữ liệu một cách không cần thiết.  Chi phí có thể tăng lên,
và các hiệu ứng như xóa bộ nhớ đệm có thể gây ra những hình phạt tinh vi.

- Nếu bạn đang thực hiện nhiều lần truyền dữ liệu nhỏ từ cùng một bộ đệm
  vào thời điểm đó, điều đó thực sự có thể đốt cháy tài nguyên trên các hệ thống sử dụng
  IOMMU để quản lý ánh xạ DMA.  MUCH có thể tốn thêm chi phí để thiết lập và
  phá bỏ ánh xạ IOMMU với mỗi yêu cầu hơn là thực hiện I/O!

Đối với những trường hợp cụ thể đó, USB có các nguyên hàm để phân bổ ít tốn kém hơn
  trí nhớ.  Chúng hoạt động giống như các phiên bản kmalloc và kfree mang lại cho bạn quyền
  loại địa chỉ để lưu trữ trong urb->transfer_buffer và urb->transfer_dma.
  Bạn cũng sẽ đặt ZZ0000ZZ trong urb->transfer_flags::

void *usb_alloc_coherent (struct usb_device *dev, kích thước size_t,
		int mem_flags, dma_addr_t *dma);

void usb_free_coherent (struct usb_device *dev, kích thước size_t,
		void *addr, dma_addr_t dma);

Hầu hết các trình điều khiển ZZ0001ZZ nên sử dụng những nguyên thủy này; họ không cần
  để sử dụng loại bộ nhớ này ("dma-coherent") và bộ nhớ được trả về từ
  ZZ0000ZZ sẽ hoạt động tốt.

Bộ nhớ đệm được trả về là "dma-coherent"; đôi khi bạn có thể cần phải
  buộc phải có thứ tự truy cập bộ nhớ nhất quán bằng cách sử dụng các rào cản bộ nhớ.  Đó là
  không sử dụng ánh xạ DMA phát trực tuyến, vì vậy sẽ tốt cho việc chuyển khoản nhỏ trên
  các hệ thống trong đó I/O sẽ phá vỡ ánh xạ IOMMU.  (Xem
  Tài liệu/core-api/dma-api-howto.rst để biết định nghĩa về "mạch lạc" và
  "truyền phát" ánh xạ DMA.)

Yêu cầu 1/N trang (cũng như yêu cầu N trang) là hợp lý
  không gian hiệu quả.

Trên hầu hết các hệ thống, bộ nhớ được trả về sẽ không được lưu vào bộ nhớ đệm, vì
  ngữ nghĩa của bộ nhớ kết hợp dma yêu cầu bỏ qua bộ đệm CPU
  hoặc sử dụng phần cứng bộ nhớ đệm có hỗ trợ theo dõi bus.  Trong khi phần cứng x86
  có tính năng rình mò bus như vậy nên nhiều hệ thống khác dùng phần mềm để xóa bộ nhớ đệm
  để tránh xung đột DMA.

- Các thiết bị trên một số bộ điều khiển EHCI có thể xử lý DMA đến/từ bộ nhớ cao.

Thật không may, cơ sở hạ tầng Linux DMA hiện tại không có hệ thống an toàn.
  cách để bộc lộ những khả năng này ... và trong mọi trường hợp, HIGHMEM chủ yếu là một
  thiết kế mụn cóc dành riêng cho x86_32.  Vì vậy cách tốt nhất của bạn là đảm bảo bạn không bao giờ
  chuyển bộ đệm highmem vào trình điều khiển USB.  Điều đó thật dễ dàng; đó là mặc định
  hành vi.  Đừng ghi đè lên nó; ví dụ. với ZZ0000ZZ.

Điều này có thể buộc người gọi của bạn thực hiện một số thao tác đệm thoát, sao chép từ
  bộ nhớ cao đến bộ nhớ DMA "bình thường".  Nếu bạn có thể nghĩ ra một cách tốt
  để khắc phục sự cố này (đối với máy x86_32 có bộ nhớ trên 1 GB),
  vui lòng gửi bản vá.

Làm việc với bộ đệm hiện có
=============================

Bộ đệm hiện tại không thể sử dụng được cho DMA nếu không được ánh xạ vào
Không gian địa chỉ DMA của thiết bị.  Tuy nhiên, hầu hết các bộ đệm được chuyển đến
trình điều khiển có thể được sử dụng một cách an toàn với ánh xạ DMA như vậy.  (Xem phần đầu tiên
của Tài liệu/core-api/dma-api-howto.rst, có tiêu đề "Bộ nhớ nào có thể sử dụng được DMA?")

- Khi bạn có danh sách phân tán đã được ánh xạ cho bộ điều khiển USB,
  bạn có thể sử dụng lệnh gọi ZZ0000ZZ mới để chuyển sang danh sách phân tán
  vào URB::

int usb_sg_init(struct usb_sg_request *io, struct usb_device *dev,
		ống không dấu, dấu chấm không dấu, danh sách phân tán cấu trúc *sg,
		int nents, độ dài size_t, gfp_t mem_flags);

void usb_sg_wait(struct usb_sg_request *io);

void usb_sg_cancel(struct usb_sg_request *io);

Khi bộ điều khiển USB không hỗ trợ DMA, ZZ0000ZZ sẽ thử
  gửi URB theo cách PIO miễn là trang trong danh sách phân tán không nằm trong
  Highmem, có thể rất hiếm trong kiến trúc hiện đại.
