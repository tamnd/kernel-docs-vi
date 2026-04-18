.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netmem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Hỗ trợ Netmem cho trình điều khiển mạng
==================================

Tài liệu này nêu ra các yêu cầu đối với trình điều khiển mạng để hỗ trợ netmem,
loại bộ nhớ trừu tượng kích hoạt các tính năng như bộ nhớ thiết bị TCP. Bởi
hỗ trợ netmem, trình điều khiển có thể hoạt động với nhiều loại bộ nhớ cơ bản khác nhau
với rất ít hoặc không có sửa đổi.

Lợi ích của Netmem:

* Tính linh hoạt: Netmem có thể được hỗ trợ bởi các loại bộ nhớ khác nhau (ví dụ: struct
  trang, DMA-buf), cho phép trình điều khiển hỗ trợ các trường hợp sử dụng khác nhau như thiết bị
  bộ nhớ TCP.
* Chứng minh tương lai: Trình điều khiển có hỗ trợ netmem đã sẵn sàng cho phiên bản sắp tới
  các tính năng dựa vào nó.
* Phát triển đơn giản hóa: Trình điều khiển tương tác với API nhất quán,
  bất kể việc triển khai bộ nhớ cơ bản.

Yêu cầu về trình điều khiển RX
======================

1. Trình điều khiển phải hỗ trợ page_pool.

2. Trình điều khiển phải hỗ trợ tùy chọn ethtool tcp-data-split.

3. Trình điều khiển phải sử dụng API netmem page_pool cho bộ nhớ tải trọng. netmem
   API hiện tại tương ứng 1-1 với API trang. Chuyển đổi sang netmem nên
   có thể đạt được bằng cách chuyển API trang sang API netmem và bộ nhớ theo dõi
   thông qua netmem_refs trong trình điều khiển chứ không phải trang struct * :

- page_pool_alloc -> page_pool_alloc_netmem
   - page_pool_get_dma_addr -> page_pool_get_dma_addr_netmem
   - page_pool_put_page -> page_pool_put_netmem

Hiện tại, không phải tất cả các API trang đều có tương đương netmem. Nếu tài xế của bạn
   dựa vào netmem API bị thiếu, vui lòng thêm và đề xuất với netdev@, hoặc
   hãy liên hệ với những người bảo trì và/hoặc almasrymina@google.com để được trợ giúp thêm
   netmem API.

4. Người lái xe phải sử dụng PP_FLAGS sau:

- PP_FLAG_DMA_MAP: trình điều khiển netmem không thể ánh xạ dma. Người lái xe
     phải ủy quyền ánh xạ dma cho page_pool để biết khi nào
     ánh xạ dma là (hoặc không) phù hợp.
   - PP_FLAG_DMA_SYNC_DEV: netmem dma addr không nhất thiết phải có khả năng đồng bộ hóa dma
     bởi người lái xe. Trình điều khiển phải ủy quyền đồng bộ hóa dma với page_pool,
     biết khi nào đồng bộ hóa dma là (hoặc không) phù hợp.
   -PP_FLAG_ALLOW_UNREADABLE_NETMEM. Người lái xe phải chỉ định cờ này
     tcp-data-split được kích hoạt.

5. Trình điều khiển không được cho rằng netmem có thể đọc được và/hoặc được hỗ trợ bởi các trang.
   Netmem được page_pool trả về có thể không đọc được, trong trường hợp đó
   netmem_address() sẽ trả về NULL. Người lái xe phải xử lý đúng
   netmem không thể đọc được, tức là đừng cố xử lý nội dung của nó khi
   netmem_address() là NULL.

Lý tưởng nhất là trình điều khiển không cần phải kiểm tra loại netmem cơ bản thông qua
   những người trợ giúp như netmem_is_net_iov() hoặc chuyển đổi netmem thành bất kỳ thứ gì của nó
   các loại cơ bản thông qua netmem_to_page() hoặc netmem_to_net_iov(). Trong hầu hết các trường hợp,
   Những người trợ giúp netmem hoặc page_pool tóm tắt sự phức tạp này được cung cấp
   (và có thể bổ sung thêm).

6. Trình điều khiển phải sử dụng page_pool_dma_sync_netmem_for_cpu() thay cho
   dma_sync_single_range_for_cpu(). Đối với một số nhà cung cấp bộ nhớ, dma_syncing dành cho
   CPU sẽ được thực hiện bởi page_pool, đối với những người khác (đặc biệt là bộ nhớ dmabuf
   nhà cung cấp), đồng bộ hóa dma cho CPU là trách nhiệm của không gian người dùng bằng cách sử dụng
   API dmabuf. Trình điều khiển phải ủy quyền toàn bộ hoạt động đồng bộ hóa dma cho
   page_pool sẽ thực hiện chính xác.

7. Tránh triển khai việc tái chế dành riêng cho trình điều khiển ở đầu page_pool. Trình điều khiển
   không thể giữ một trang cấu trúc để tự tái chế vì netmem có thể
   không được hỗ trợ bởi một trang cấu trúc. Tuy nhiên, bạn có thể giữ page_pool
   tham chiếu với page_pool_fragment_netmem() hoặc page_pool_ref_netmem() cho
   mục đích đó, nhưng hãy lưu ý rằng một số loại netmem có thể có thời gian dài hơn
   thời gian lưu hành, chẳng hạn như khi không gian người dùng chứa tham chiếu ở dạng zerocopy
   kịch bản.

Yêu cầu về trình điều khiển TX
======================

1. Trình điều khiển không được chuyển netmem dma_addr cho bất kỳ API ánh xạ dma nào
   trực tiếp. Điều này là do netmem dma_addrs có thể đến từ một nguồn như
   dma-buf không tương thích với API ánh xạ dma.

Những người trợ giúp như netmem_dma_unmap_page_attrs() & netmem_dma_unmap_addr_set()
   nên được sử dụng thay cho dma_unmap_page[_attrs](), dma_unmap_addr_set().
   Các biến thể netmem sẽ xử lý netmem dma_addrs một cách chính xác bất kể
   nguồn, ủy quyền cho các API ánh xạ dma khi thích hợp.

Hiện tại, không phải tất cả các API ánh xạ dma đều có tương đương netmem. Nếu bạn
   driver dựa trên netmem API bị thiếu, vui lòng bổ sung và đề xuất
   netdev@ hoặc liên hệ với người bảo trì và/hoặc almasrymina@google.com để biết
   giúp thêm netmem API.

2. Driver cần khai báo hỗ trợ bằng cách setting ZZ0000ZZ