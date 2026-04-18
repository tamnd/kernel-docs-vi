.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/dma-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================================
Ánh xạ DMA động bằng thiết bị chung
============================================

:Tác giả: James E.J. Bottomley <James.Bottomley@HansenPartnership.com>

Tài liệu này mô tả DMA API.  Để giới thiệu nhẹ nhàng hơn
của API (và các ví dụ thực tế), hãy xem Tài liệu/core-api/dma-api-howto.rst.

API này được chia thành hai phần.  Phần I mô tả API cơ bản.
Phần II mô tả các phần mở rộng để hỗ trợ bộ nhớ không kết hợp
máy móc.  Trừ khi bạn biết rằng tài xế của bạn tuyệt đối phải hỗ trợ
nền tảng không mạch lạc (thường chỉ là nền tảng cũ) bạn
chỉ nên sử dụng API được mô tả ở phần I.

Phần I - DMA API
----------------

Để có được DMA API, bạn phải #include <linux/dma-mapping.h>.  Cái này
cung cấp dma_addr_t và các giao diện được mô tả bên dưới.

Một dma_addr_t có thể chứa bất kỳ địa chỉ DMA hợp lệ nào cho nền tảng.  Nó có thể
được cung cấp cho một thiết bị để sử dụng làm nguồn hoặc đích DMA.  CPU không thể tham chiếu
trực tiếp dma_addr_t vì có thể có sự dịch chuyển giữa vật lý của nó
không gian địa chỉ và không gian địa chỉ DMA.

Phần Ia - Sử dụng bộ đệm kết hợp DMA lớn
------------------------------------------

::

trống *
	dma_alloc_coherent(thiết bị cấu trúc *dev, kích thước size_t,
			   dma_addr_t *dma_handle, cờ gfp_t)

Bộ nhớ mạch lạc là bộ nhớ mà thiết bị hoặc
bộ xử lý có thể được đọc ngay lập tức bởi bộ xử lý hoặc thiết bị
mà không phải lo lắng về hiệu ứng bộ nhớ đệm.  (Tuy nhiên bạn có thể cần
để đảm bảo xóa bộ đệm ghi của bộ xử lý trước khi yêu cầu
thiết bị để đọc bộ nhớ đó.)

Thủ tục này phân bổ một vùng có <size> byte bộ nhớ nhất quán.

Nó trả về một con trỏ tới vùng được phân bổ (trong vùng ảo của bộ xử lý
không gian địa chỉ) hoặc NULL nếu việc phân bổ không thành công.

Nó cũng trả về một <dma_handle> có thể được ép kiểu thành một số nguyên không dấu
có cùng chiều rộng với bus và được cấp cho thiết bị dưới dạng cơ sở địa chỉ DMA của
khu vực.

Lưu ý: bộ nhớ mạch lạc có thể đắt tiền trên một số nền tảng và
độ dài phân bổ tối thiểu có thể lớn bằng một trang, vì vậy bạn nên
củng cố yêu cầu của bạn về trí nhớ mạch lạc càng nhiều càng tốt.
Cách đơn giản nhất để làm điều đó là sử dụng lệnh gọi dma_pool (xem bên dưới).

Tham số cờ cho phép người gọi chỉ định cờ ZZ0000ZZ (xem
kmalloc()) để phân bổ (việc triển khai có thể bỏ qua các cờ ảnh hưởng đến
vị trí của bộ nhớ được trả về, như GFP_DMA).

::

trống rỗng
	dma_free_coherent(thiết bị cấu trúc *dev, size_t size, void *cpu_addr,
			  dma_addr_t dma_handle)

Giải phóng một vùng bộ nhớ nhất quán được phân bổ trước đó.  dev, kích thước và dma_handle
tất cả đều phải giống với những gì được truyền vào dma_alloc_coherent().  cpu_addr phải
là địa chỉ ảo được trả về bởi dma_alloc_coherent().

Lưu ý rằng không giống như lời gọi phân bổ anh em, thủ tục này chỉ có thể được gọi
với IRQ được kích hoạt.


Phần Ib - Sử dụng bộ đệm kết hợp DMA nhỏ
------------------------------------------

Để có được phần này của DMA API, bạn phải #include <linux/dmapool.h>

Nhiều trình điều khiển cần nhiều vùng bộ nhớ kết hợp DMA nhỏ cho DMA
bộ mô tả hoặc bộ đệm I/O.  Thay vì phân bổ theo đơn vị của một trang
hoặc nhiều hơn bằng cách sử dụng dma_alloc_coherent(), bạn có thể sử dụng nhóm DMA.  Những công việc này
giống như struct kmem_cache, ngoại trừ việc chúng sử dụng bộ cấp phát kết hợp DMA,
không phải __get_free_pages().  Ngoài ra, họ hiểu những hạn chế chung về phần cứng
để căn chỉnh, chẳng hạn như các đầu hàng đợi cần được căn chỉnh trên ranh giới N-byte.

.. kernel-doc:: mm/dmapool.c
   :export:

.. kernel-doc:: include/linux/dmapool.h


Phần Ic - Giới hạn địa chỉ của DMA
------------------------------------

Mặt nạ DMA là mặt nạ bit của vùng có thể định địa chỉ cho thiết bị. Nói cách khác,
nếu áp dụng mặt nạ DMA (thao tác AND theo bit) cho địa chỉ DMA của một
vùng bộ nhớ không xóa bất kỳ bit nào trong địa chỉ thì thiết bị có thể
thực hiện DMA cho vùng bộ nhớ đó.

Tất cả các chức năng đặt mặt nạ DMA bên dưới có thể không thành công nếu mặt nạ được yêu cầu
không thể sử dụng được với thiết bị hoặc nếu thiết bị không có khả năng thực hiện DMA.

::

int
	dma_set_mask_and_coherent(thiết bị cấu trúc *dev, mặt nạ u64)

Cập nhật cả mặt nạ DMA phát trực tuyến và mạch lạc.

Trả về: 0 nếu thành công và lỗi âm nếu không.

::

int
	dma_set_mask(thiết bị cấu trúc *dev, mặt nạ u64)

Chỉ cập nhật mặt nạ DMA phát trực tuyến.

Trả về: 0 nếu thành công và lỗi âm nếu không.

::

int
	dma_set_coherent_mask(thiết bị cấu trúc *dev, mặt nạ u64)

Chỉ cập nhật mặt nạ DMA mạch lạc.

Trả về: 0 nếu thành công và lỗi âm nếu không.

::

u64
	dma_get_required_mask(thiết bị cấu trúc *dev)

API này trả về mặt nạ mà nền tảng yêu cầu
hoạt động hiệu quả.  Thông thường điều này có nghĩa là mặt nạ được trả lại
là mức tối thiểu cần thiết để bao phủ toàn bộ bộ nhớ.  Kiểm tra
mặt nạ bắt buộc cung cấp cho trình điều khiển có kích thước mô tả thay đổi
cơ hội sử dụng các mô tả nhỏ hơn nếu cần thiết.

Yêu cầu mặt nạ cần thiết không làm thay đổi mặt nạ hiện tại.  Nếu bạn
muốn tận dụng lợi thế của nó, bạn nên đưa ra dma_set_mask()
gọi để đặt mặt nạ thành giá trị được trả về.

::

kích thước_t
	dma_max_mapping_size(thiết bị cấu trúc *dev);

Trả về kích thước tối đa của ánh xạ cho thiết bị. Thông số kích thước
của các hàm ánh xạ như dma_map_single(), dma_map_page() và
những cái khác không được lớn hơn giá trị trả về.

::

kích thước_t
	dma_opt_mapping_size(thiết bị cấu trúc *dev);

Trả về kích thước tối ưu tối đa của ánh xạ cho thiết bị.

Việc ánh xạ các vùng đệm lớn hơn có thể mất nhiều thời gian hơn trong một số trường hợp nhất định. trong
Ngoài ra, đối với ánh xạ phát trực tuyến trong thời gian ngắn tốc độ cao, thời gian trả trước
chi phí cho việc lập bản đồ có thể chiếm một phần đáng kể trong tổng chi phí
yêu cầu trọn đời. Như vậy, nếu việc chia nhỏ các yêu cầu lớn hơn sẽ không phát sinh
phạt hiệu suất đáng kể, thì trình điều khiển thiết bị nên
giới hạn tổng chiều dài ánh xạ phát trực tuyến DMA ở giá trị được trả về.

::

bool
	dma_need_sync(thiết bị cấu trúc *dev, dma_addr_t dma_addr);

Trả về %true nếu lệnh gọi dma_sync_single_for_{device,cpu} được yêu cầu để
chuyển quyền sở hữu bộ nhớ.  Trả về %false nếu những cuộc gọi đó có thể bị bỏ qua.

::

dài không dấu
	dma_get_merge_boundary(thiết bị cấu trúc *dev);

Trả về ranh giới hợp nhất DMA. Nếu thiết bị không thể hợp nhất bất kỳ địa chỉ DMA nào
phân đoạn, hàm trả về 0.

Id phần - Truyền ánh xạ DMA
--------------------------------

Truyền phát DMA cho phép ánh xạ bộ đệm hiện có để chuyển DMA và sau đó
hủy bản đồ nó khi hoàn tất.  Các chức năng bản đồ không được đảm bảo sẽ thành công, vì vậy
giá trị trả về phải được kiểm tra.

.. note::

	In particular, mapping may fail for memory not addressable by the
	device, e.g. if it is not within the DMA mask of the device and/or a
	connecting bus bridge.  Streaming DMA functions try to overcome such
	addressing constraints, either by using an IOMMU (a device which maps
	I/O DMA addresses to physical memory addresses), or by copying the
	data to/from a bounce buffer if the kernel is configured with a
	:doc:`SWIOTLB <swiotlb>`.  However, these methods are not always
	available, and even if they are, they may still fail for a number of
	reasons.

	In short, a device driver may need to be wary of where buffers are
	located in physical memory, especially if the DMA mask is less than 32
	bits.

::

dma_addr_t
	dma_map_single(thiết bị cấu trúc *dev, void *cpu_addr, kích thước size_t,
		       hướng enum dma_data_direction)

Ánh xạ một phần bộ nhớ ảo của bộ xử lý để nó có thể được truy cập bởi
thiết bị và trả về địa chỉ DMA của bộ nhớ.

DMA API sử dụng một bộ liệt kê được định kiểu mạnh cho hướng của nó:

=========================================================================
DMA_NONE không có hướng (dùng để gỡ lỗi)
Dữ liệu DMA_TO_DEVICE đang đi từ bộ nhớ đến thiết bị
Dữ liệu DMA_FROM_DEVICE đang truyền từ thiết bị vào bộ nhớ
Hướng DMA_BIDIRECTIONAL không được biết
=========================================================================

.. note::

	Contiguous kernel virtual space may not be contiguous as
	physical memory.  Since this API does not provide any scatter/gather
	capability, it will fail if the user tries to map a non-physically
	contiguous piece of memory.  For this reason, memory to be mapped by
	this API should be obtained from sources which guarantee it to be
	physically contiguous (like kmalloc).

.. warning::

	Memory coherency operates at a granularity called the cache
	line width.  In order for memory mapped by this API to operate
	correctly, the mapped region must begin exactly on a cache line
	boundary and end exactly on one (to prevent two separately mapped
	regions from sharing a single cache line).  Since the cache line size
	may not be known at compile time, the API will not enforce this
	requirement.  Therefore, it is recommended that driver writers who
	don't take special care to determine the cache line size at run time
	only map virtual regions that begin and end on page boundaries (which
	are guaranteed also to be cache line boundaries).

	DMA_TO_DEVICE synchronisation must be done after the last modification
	of the memory region by the software and before it is handed off to
	the device.  Once this primitive is used, memory covered by this
	primitive should be treated as read-only by the device.  If the device
	may write to it at any point, it should be DMA_BIDIRECTIONAL (see
	below).

	DMA_FROM_DEVICE synchronisation must be done before the driver
	accesses data that may be changed by the device.  This memory should
	be treated as read-only by the driver.  If the driver needs to write
	to it at any point, it should be DMA_BIDIRECTIONAL (see below).

	DMA_BIDIRECTIONAL requires special handling: it means that the driver
	isn't sure if the memory was modified before being handed off to the
	device and also isn't sure if the device will also modify it.  Thus,
	you must always sync bidirectional memory twice: once before the
	memory is handed off to the device (to make sure all memory changes
	are flushed from the processor) and once before the data may be
	accessed after being used by the device (to make sure any processor
	cache lines are updated with data that the device may have changed).

::

trống rỗng
	dma_unmap_single(thiết bị cấu trúc *dev, dma_addr_t dma_addr, kích thước size_t,
			 hướng enum dma_data_direction)

Hủy bản đồ khu vực đã được ánh xạ trước đó.  Tất cả các tham số được truyền vào
phải giống với các giá trị được truyền tới (và được trả về bởi) dma_map_single().

::

dma_addr_t
	dma_map_page(thiết bị cấu trúc *dev, struct page *page,
		     phần bù dài không dấu, kích thước size_t,
		     hướng enum dma_data_direction)

trống rỗng
	dma_unmap_page(cấu trúc thiết bị *dev, dma_addr_t dma_address, kích thước size_t,
		       hướng enum dma_data_direction)

API để ánh xạ và hủy ánh xạ cho các trang.  Tất cả các ghi chú và cảnh báo
đối với các API ánh xạ khác áp dụng tại đây.  Ngoài ra, mặc dù <offset>
và các tham số <size> được cung cấp để thực hiện ánh xạ một phần trang, đó là
khuyên bạn không bao giờ sử dụng những thứ này trừ khi bạn thực sự biết những gì
chiều rộng bộ đệm là.

::

dma_addr_t
	dma_map_resource(struct device *dev, Phys_addr_t Phys_addr, size_t size,
			 thư mục enum dma_data_direction, attr dài không dấu)

trống rỗng
	dma_unmap_resource(struct device *dev, dma_addr_t addr, size_t size,
			   thư mục enum dma_data_direction, attr dài không dấu)

API để ánh xạ và hủy ánh xạ các tài nguyên MMIO. Tất cả các ghi chú và
cảnh báo cho các API ánh xạ khác áp dụng ở đây. API chỉ nên
được sử dụng để ánh xạ tài nguyên MMIO của thiết bị, không được phép ánh xạ RAM.

::

int
	dma_mapping_error(thiết bị cấu trúc *dev, dma_addr_t dma_addr)

Trong một số trường hợp dma_map_single(), dma_map_page() và dma_map_resource()
sẽ không tạo được bản đồ. Người lái xe có thể kiểm tra những lỗi này bằng cách kiểm tra
địa chỉ DMA được trả về với dma_mapping_error(). Giá trị trả về khác 0
có nghĩa là không thể tạo bản đồ và trình điều khiển phải thực hiện các biện pháp thích hợp
hành động (ví dụ: giảm mức độ sử dụng hoặc độ trễ ánh xạ DMA hiện tại và thử lại sau).

::

int
	dma_map_sg(thiết bị cấu trúc *dev, struct scatterlist *sg,
		   int nents, hướng enum dma_data_direction)

Ánh xạ danh sách phân tán/tập hợp cho DMA. Trả về số lượng phân đoạn địa chỉ DMA
được ánh xạ, có thể nhỏ hơn <nents> được truyền vào nếu nhiều lần liên tiếp
các mục nhập sglist được hợp nhất (ví dụ: với IOMMU hoặc nếu một số phân đoạn liền kề
chỉ tình cờ tiếp giáp về mặt vật lý).

Xin lưu ý rằng sg không thể được ánh xạ lại nếu nó đã được ánh xạ một lần.
Quá trình ánh xạ được phép hủy thông tin trong sg.

Cũng như các giao diện ánh xạ khác, dma_map_sg() có thể bị lỗi. Khi nó
không, 0 sẽ được trả về và người lái xe phải thực hiện hành động thích hợp. Đó là
quan trọng là trình điều khiển phải làm điều gì đó, trong trường hợp trình điều khiển khối
việc hủy bỏ yêu cầu hoặc thậm chí rất tiếc vẫn tốt hơn là không làm gì và
làm hỏng hệ thống tập tin.

Với danh sách phân tán, bạn sử dụng ánh xạ kết quả như sau::

int i, count = dma_map_sg(dev, sglist, nents, Direction);
	danh sách phân tán cấu trúc *sg;

for_each_sg(sglist, sg, count, i) {
		hw_address[i] = sg_dma_address(sg);
		hw_len[i] = sg_dma_len(sg);
	}

trong đó nents là số mục trong sglist.

Việc triển khai có thể tự do hợp nhất một số mục sglist liên tiếp
thành một.  Số được trả về là số mục thực tế của nó
ánh xạ chúng tới. Khi thất bại, 0 được trả về.

Sau đó, bạn nên đếm số lần lặp (lưu ý: số lần này có thể nhỏ hơn số lần)
và sử dụng macro sg_dma_address() và sg_dma_len() mà trước đây bạn
truy cập sg->address và sg->length như được hiển thị ở trên.

::

trống rỗng
	dma_unmap_sg(thiết bị cấu trúc *dev, struct scatterlist *sg,
		     int nents, hướng enum dma_data_direction)

Bỏ ánh xạ danh sách phân tán/thu thập được ánh xạ trước đó.  Tất cả các thông số
phải giống với những cái đó và được chuyển vào ánh xạ phân tán/thu thập
API.

Lưu ý: <nents> phải là số bạn đã nhập, ZZ0000ZZ là số
Các mục địa chỉ DMA được trả về.

::

trống rỗng
	dma_sync_single_for_cpu(cấu trúc thiết bị *dev, dma_addr_t dma_handle,
				kích thước size_t,
				hướng enum dma_data_direction)

trống rỗng
	dma_sync_single_for_device(cấu trúc thiết bị *dev, dma_addr_t dma_handle,
				   kích thước size_t,
				   hướng enum dma_data_direction)

trống rỗng
	dma_sync_sg_for_cpu(thiết bị cấu trúc *dev, struct scatterlist *sg,
			    int,
			    hướng enum dma_data_direction)

trống rỗng
	dma_sync_sg_for_device(thiết bị cấu trúc *dev, struct scatterlist *sg,
			       int,
			       hướng enum dma_data_direction)

Đồng bộ hóa một ánh xạ liền kề hoặc phân tán/thu thập cho CPU
và thiết bị. Với sync_sg API, tất cả các thông số phải giống nhau
khi chúng được chuyển vào ánh xạ sg API. Với sync_single API,
bạn có thể sử dụng các tham số dma_handle và size không giống với
những cái đó được chuyển vào ánh xạ đơn API để thực hiện đồng bộ hóa một phần.


.. note::

   You must do this:

   - Before reading values that have been written by DMA from the device
     (use the DMA_FROM_DEVICE direction)
   - After writing values that will be written to the device using DMA
     (use the DMA_TO_DEVICE) direction
   - before *and* after handing memory to the device if the memory is
     DMA_BIDIRECTIONAL

Xem thêm dma_map_single().

::

dma_addr_t
	dma_map_single_attrs(thiết bị cấu trúc *dev, void *cpu_addr, kích thước size_t,
			     thư mục enum dma_data_direction,
			     attr dài không dấu)

trống rỗng
	dma_unmap_single_attrs(thiết bị cấu trúc *dev, dma_addr_t dma_addr,
			       kích thước size_t, thư mục enum dma_data_direction,
			       attr dài không dấu)

int
	dma_map_sg_attrs(thiết bị cấu trúc *dev, struct scatterlist *sgl,
			 int nents, thư mục enum dma_data_direction,
			 attr dài không dấu)

trống rỗng
	dma_unmap_sg_attrs(thiết bị cấu trúc *dev, struct scatterlist *sgl,
			   int nents, thư mục enum dma_data_direction,
			   attr dài không dấu)

Bốn chức năng trên cũng giống như các chức năng đối ứng
không có hậu tố _attrs, ngoại trừ việc chúng chuyển một tùy chọn
dma_attrs.

Việc giải thích các thuộc tính DMA tùy thuộc vào kiến trúc cụ thể và
mỗi thuộc tính nên được ghi lại trong
Tài liệu/core-api/dma-attributes.rst.

Nếu dma_attrs bằng 0 thì ngữ nghĩa của từng hàm này
giống hệt với hàm tương ứng
không có hậu tố _attrs. Kết quả là dma_map_single_attrs()
nói chung có thể thay thế dma_map_single(), v.v.

Dưới đây là ví dụ về cách sử dụng các hàm ZZ0000ZZ
bạn có thể chuyển thuộc tính DMA_ATTR_FOO khi ánh xạ bộ nhớ
cho DMA::

#include <linux/dma-mapping.h>
	/* DMA_ATTR_FOO phải được định nghĩa trong linux/dma-mapping.h và
	* được ghi lại trong Documentation/core-api/dma-attributes.rst */
	...

		unsigned long attr;
		attr |= DMA_ATTR_FOO;
		....
		n = dma_map_sg_attrs(dev, sg, nents, DMA_TO_DEVICE, attr);
		....

Các kiến trúc quan tâm đến DMA_ATTR_FOO sẽ kiểm tra
sự hiện diện của họ trong việc triển khai ánh xạ và hủy ánh xạ
thói quen, ví dụ:::

void whizco_dma_map_sg_attrs(thiết bị cấu trúc *dev, dma_addr_t dma_addr,
				     kích thước size_t, thư mục enum dma_data_direction,
				     attr dài không dấu)
	{
		....
nếu (attrs & DMA_ATTR_FOO)
			/* vặn vòi phun */
		....
	}

Phần Ie - Ánh xạ DMA dựa trên IOVA
---------------------------------

Các API này cho phép ánh xạ rất hiệu quả khi sử dụng IOMMU.  Họ là một
đường dẫn tùy chọn yêu cầu thêm mã và chỉ được khuyến nghị cho trình điều khiển
trong đó hiệu suất ánh xạ DMA hoặc mức sử dụng không gian để lưu trữ địa chỉ DMA
vấn đề.  Tất cả những cân nhắc từ phần trước cũng được áp dụng ở đây.

::

bool dma_iova_try_alloc(thiết bị cấu trúc *dev, struct dma_iova_state *state,
		Phys_addr_t Phys, kích thước size_t);

Được sử dụng để cố gắng phân bổ không gian IOVA cho hoạt động ánh xạ.  Nếu nó trở lại
sai API này không thể được sử dụng cho thiết bị nhất định và phát trực tuyến thông thường
Nên sử dụng ánh xạ DMA API.  ZZ0000ZZ được phân bổ
bởi người lái xe và phải được giữ lại cho đến khi hết thời gian lập bản đồ.

::

bool nội tuyến tĩnh dma_use_iova(struct dma_iova_state *state)

Trình điều khiển có thể được sử dụng để kiểm tra xem IOVA dựa trên IOVA có được sử dụng sau một
gọi tới dma_iova_try_alloc.  Điều này có thể hữu ích trong đường dẫn unmap.

::

int dma_iova_link(thiết bị cấu trúc *dev, struct dma_iova_state *state,
		Phys_addr_t Phys, offset size_t, kích thước size_t,
		thư mục enum dma_data_direction, attr dài không dấu);

Được sử dụng để liên kết các phạm vi với IOVA được phân bổ trước đó.  Sự khởi đầu của tất cả
nhưng lệnh gọi đầu tiên tới dma_iova_link cho một trạng thái nhất định phải được căn chỉnh
đến ranh giới hợp nhất DMA được ZZ0000ZZ trả về và
kích thước của tất cả trừ phạm vi cuối cùng phải được căn chỉnh theo ranh giới hợp nhất DMA
cũng vậy.

::

int dma_iova_sync(cấu trúc thiết bị *dev, struct dma_iova_state *state,
		offset size_t, kích thước size_t);

Phải được gọi để đồng bộ hóa các bảng trang IOMMU cho phạm vi IOVA được ánh xạ bởi một hoặc
nhiều cuộc gọi hơn tới ZZ0000ZZ.

Đối với các trình điều khiển sử dụng ánh xạ một lần, tất cả các phạm vi có thể được hủy ánh xạ và
IOVA được giải phóng bằng cách gọi:

::

void dma_iova_destroy(thiết bị cấu trúc *dev, struct dma_iova_state *state,
		size_t mapped_len, thư mục enum dma_data_direction,
                attr dài không dấu);

Ngoài ra, trình điều khiển có thể quản lý động không gian IOVA bằng cách hủy ánh xạ
và lập bản đồ các vùng riêng lẻ.  Trong trường hợp đó

::

void dma_iova_unlink(thiết bị cấu trúc *dev, struct dma_iova_state *state,
		offset size_t, kích thước size_t, thư mục enum dma_data_direction,
		attr dài không dấu);

được sử dụng để hủy ánh xạ một phạm vi được ánh xạ trước đó và

::

void dma_iova_free(thiết bị cấu trúc *dev, struct dma_iova_state *state);

được sử dụng để giải phóng không gian IOVA.  Tất cả các khu vực phải được hủy ánh xạ bằng cách sử dụng
ZZ0000ZZ trước khi gọi ZZ0001ZZ.

Phần II - Phân bổ DMA không nhất quán
--------------------------------------

Các API này cho phép phân bổ các trang được đảm bảo có thể định địa chỉ DMA
bởi thiết bị được truyền vào nhưng cần quản lý rõ ràng quyền sở hữu bộ nhớ
cho kernel và thiết bị.

Nếu bạn không hiểu cách hoạt động liên kết dòng bộ đệm giữa bộ xử lý và
thiết bị I/O, bạn không nên sử dụng phần này của API.

::

trang cấu trúc *
	dma_alloc_pages(thiết bị cấu trúc *dev, size_t size, dma_addr_t *dma_handle,
			thư mục enum dma_data_direction, gfp_t gfp)

Thủ tục này phân bổ một vùng có <size> byte bộ nhớ không kết hợp.  Nó
trả về một con trỏ tới trang cấu trúc đầu tiên cho vùng hoặc NULL nếu
phân bổ không thành công. Trang cấu trúc kết quả có thể được sử dụng cho mọi thứ
trang struct phù hợp cho.

Nó cũng trả về một <dma_handle> có thể được ép kiểu thành một số nguyên không dấu
có cùng chiều rộng với bus và được cấp cho thiết bị dưới dạng cơ sở địa chỉ DMA của
khu vực.

Tham số dir được chỉ định nếu dữ liệu được đọc và/hoặc ghi bởi thiết bị,
xem dma_map_single() để biết chi tiết.

Tham số gfp cho phép người gọi chỉ định cờ ZZ0000ZZ (xem
kmalloc()) để phân bổ nhưng từ chối các cờ được sử dụng để chỉ định bộ nhớ
vùng như GFP_DMA hoặc GFP_HIGHMEM.

Trước khi cấp bộ nhớ cho thiết bị, dma_sync_single_for_device() cần
được gọi và trước khi đọc bộ nhớ được ghi bởi thiết bị,
dma_sync_single_for_cpu(), giống như để phát trực tuyến ánh xạ DMA
tái sử dụng.

::

trống rỗng
	dma_free_pages(thiết bị cấu trúc *dev, size_t size, struct page *page,
			dma_addr_t dma_handle, enum dma_data_direction thư mục)

Giải phóng một vùng bộ nhớ đã được phân bổ trước đó bằng dma_alloc_pages().
dev, size, dma_handle và dir đều phải giống với những gì được truyền vào
dma_alloc_pages().  trang phải là con trỏ được trả về bởi dma_alloc_pages().

::

int
	dma_mmap_pages(thiết bị cấu trúc *dev, struct vm_area_struct *vma,
		       kích thước size_t, cấu trúc trang *trang)

Ánh xạ phân bổ được trả về từ dma_alloc_pages() vào không gian địa chỉ người dùng.
dev và kích thước phải giống với kích thước được truyền vào dma_alloc_pages().
trang phải là con trỏ được trả về bởi dma_alloc_pages().

::

trống *
	dma_alloc_noncoherent(thiết bị cấu trúc *dev, kích thước size_t,
			dma_addr_t *dma_handle, enum dma_data_direction thư mục,
			gfp_t gfp)

Thủ tục này là một trình bao bọc thuận tiện xung quanh dma_alloc_pages trả về
địa chỉ ảo kernel cho bộ nhớ được phân bổ thay vì cấu trúc trang.

::

trống rỗng
	dma_free_noncoherent(thiết bị cấu trúc *dev, size_t size, void *cpu_addr,
			dma_addr_t dma_handle, enum dma_data_direction thư mục)

Giải phóng một vùng bộ nhớ đã được phân bổ trước đó bằng dma_alloc_noncoherent().
dev, size, dma_handle và dir đều phải giống với những gì được truyền vào
dma_alloc_noncoherent().  cpu_addr phải là địa chỉ ảo được trả về bởi
dma_alloc_noncoherent().

::

cấu trúc sg_table *
	dma_alloc_noncontiguous(cấu trúc thiết bị *dev, size_t size,
				thư mục enum dma_data_direction, gfp_t gfp,
				attr dài không dấu);

Thủ tục này phân bổ <size> byte không mạch lạc và có thể không liền kề
trí nhớ.  Nó trả về một con trỏ tới struct sg_table mô tả địa chỉ được phân bổ
và bộ nhớ được ánh xạ DMA hoặc NULL nếu việc phân bổ không thành công. Bộ nhớ kết quả
có thể được sử dụng cho trang cấu trúc được ánh xạ vào danh sách phân tán phù hợp.

Bảng trả về sg_table được đảm bảo có 1 phân đoạn được ánh xạ DMA duy nhất như
được chỉ định bởi sgt->nents, nhưng nó có thể có nhiều phân đoạn bên CPU như
được chỉ định bởi sgt->orig_nents.

Tham số dir được chỉ định nếu dữ liệu được đọc và/hoặc ghi bởi thiết bị,
xem dma_map_single() để biết chi tiết.

Tham số gfp cho phép người gọi chỉ định cờ ZZ0000ZZ (xem
kmalloc()) để phân bổ nhưng từ chối các cờ được sử dụng để chỉ định bộ nhớ
vùng như GFP_DMA hoặc GFP_HIGHMEM.

Đối số attrs phải là 0 hoặc DMA_ATTR_ALLOC_SINGLE_PAGES.

Trước khi cấp bộ nhớ cho thiết bị, dma_sync_sgtable_for_device() cần
được gọi và trước khi đọc bộ nhớ được ghi bởi thiết bị,
dma_sync_sgtable_for_cpu(), giống như để phát trực tuyến ánh xạ DMA
tái sử dụng.

::

trống rỗng
	dma_free_noncontiguous(cấu trúc thiết bị *dev, kích thước size_t,
			       cấu trúc sg_table *sgt,
			       thư mục enum dma_data_direction)

Bộ nhớ trống đã được phân bổ trước đó bằng dma_alloc_noncontiguous().  phát triển, kích thước,
và tất cả thư mục phải giống với những thư mục được chuyển vào dma_alloc_noncontiguous().
sgt phải là con trỏ được trả về bởi dma_alloc_noncontiguous().

::

trống *
	dma_vmap_noncontiguous(cấu trúc thiết bị *dev, kích thước size_t,
		cấu trúc sg_table *sgt)

Trả về ánh xạ hạt nhân liền kề cho phân bổ được trả về từ
dma_alloc_noncontiguous().  dev và kích thước phải giống với kích thước được truyền vào
dma_alloc_noncontiguous().  sgt phải là con trỏ được trả về bởi
dma_alloc_noncontiguous().

Sau khi phân bổ không liền kề được ánh xạ bằng hàm này,
Phải sử dụng API Flush_kernel_vmap_range() và không hợp lệ_kernel_vmap_range()
để quản lý sự mạch lạc giữa ánh xạ hạt nhân, thiết bị và không gian người dùng
bản đồ (nếu có).

::

trống rỗng
	dma_vunmap_noncontiguous(thiết bị cấu trúc *dev, void *vaddr)

Hủy ánh xạ ánh xạ hạt nhân được trả về bởi dma_vmap_noncontiguous().  nhà phát triển phải là
tương tự cái được chuyển vào dma_alloc_noncontiguous().  vaddr phải là con trỏ
được trả về bởi dma_vmap_noncontiguous().


::

int
	dma_mmap_noncontiguous(thiết bị cấu trúc *dev, struct vm_area_struct *vma,
			       kích thước size_t, cấu trúc sg_table *sgt)

Ánh xạ phân bổ được trả về từ dma_alloc_noncontiguous() vào địa chỉ người dùng
không gian.  dev và kích thước phải giống với kích thước được truyền vào
dma_alloc_noncontiguous().  sgt phải là con trỏ được trả về bởi
dma_alloc_noncontiguous().

::

int
	dma_get_cache_alignment(void)

Trả về căn chỉnh bộ đệm của bộ xử lý.  Đây là mức tối thiểu tuyệt đối
căn chỉnh chiều rộng ZZ0000ZZ mà bạn phải quan sát khi ánh xạ
bộ nhớ hoặc thực hiện xóa một phần.

.. note::

	This API may return a number *larger* than the actual cache
	line, but it will guarantee that one or more cache lines fit exactly
	into the width returned by this call.  It will also always be a power
	of two for easy alignment.


Phần III - Gỡ lỗi driver sử dụng của DMA API
-------------------------------------------

DMA API như được mô tả ở trên có một số hạn chế. Địa chỉ DMA phải là
được phát hành với chức năng tương ứng với cùng kích thước chẳng hạn. Với
sự ra đời của IOMMU phần cứng, điều đó ngày càng trở nên quan trọng hơn đối với các trình điều khiển
không vi phạm những ràng buộc đó. Trong trường hợp xấu nhất, sự vi phạm đó có thể
dẫn đến hỏng dữ liệu cho đến các hệ thống tập tin bị phá hủy.

Để gỡ lỗi trình điều khiển và tìm lỗi trong việc sử dụng mã kiểm tra DMA API, bạn có thể
được biên dịch vào kernel và nó sẽ cho nhà phát triển biết về những điều đó
vi phạm. Nếu kiến trúc của bạn hỗ trợ nó, bạn có thể chọn nút "Bật
tùy chọn gỡ lỗi sử dụng DMA API" trong cấu hình kernel của bạn. Kích hoạt tính năng này
tùy chọn có tác động hiệu suất. Không kích hoạt nó trong hạt nhân sản xuất.

Nếu bạn khởi động, kernel kết quả sẽ chứa mã thực hiện một số công việc kế toán
về bộ nhớ DMA được phân bổ cho thiết bị nào. Nếu mã này phát hiện một
lỗi, nó sẽ in một thông báo cảnh báo kèm theo một số chi tiết vào nhật ký kernel của bạn. Một
thông báo cảnh báo ví dụ có thể trông như thế này::

WARNING: tại /data2/repos/linux-2.6-iommu/lib/dma-debug.c:448
		check_unmap+0x203/0x490()
	Tên phần cứng:
	buộc 0000:00:08.0: DMA-API: trình điều khiển thiết bị giải phóng bộ nhớ DMA sai
		chức năng [địa chỉ thiết bị=0x00000000640444be] [kích thước=66 byte] [được ánh xạ dưới dạng
	single] [chưa được ánh xạ dưới dạng trang]
	Các mô-đun được liên kết trong: nfsdexportfs bridge stp llc r8169
	Pid: 0, comm: bộ trao đổi Bị nhiễm độc: G W 2.6.28-dmatest-09289-g8bb99c0 #1
	Theo dõi cuộc gọi:
	<IRQ> [<ffffffff80240b22>] Warn_slowpath+0xf2/0x130
	[<ffffffff80647b70>] _spin_unlock+0x10/0x30
	[<ffffffff80537e75>] usb_hcd_link_urb_to_ep+0x75/0xc0
	[<ffffffff80647c22>] _spin_unlock_irqrestore+0x12/0x40
	[<ffffffff8055347f>] ohci_urb_enqueue+0x19f/0x7c0
	[<ffffffff80252f96>] queue_work+0x56/0x60
	[<ffffffff80237e10>] enqueue_task_fair+0x20/0x50
	[<ffffffff80539279>] usb_hcd_submit_urb+0x379/0xbc0
	[<ffffffff803b78c3>] cpumask_next_and+0x23/0x40
	[<ffffffff80235177>] find_busiest_group+0x207/0x8a0
	[<ffffffff8064784f>] _spin_lock_irqsave+0x1f/0x50
	[<ffffffff803c7ea3>] check_unmap+0x203/0x490
	[<ffffffff803c8259>] debug_dma_unmap_phys+0x49/0x50
	[<ffffffff80485f26>] nv_tx_done_optimized+0xc6/0x2c0
	[<ffffffff80486c13>] nv_nic_irq_optimized+0x73/0x2b0
	[<ffffffff8026df84>] xử lý_IRQ_event+0x34/0x70
	[<ffffffff8026ffe9>] hand_edge_irq+0xc9/0x150
	[<ffffffff8020e3ab>] do_IRQ+0xcb/0x1c0
	[<ffffffff8020c093>] ret_from_intr+0x0/0xa
	<EOI> <4>---[ dấu vết cuối f6435a98e2a38c0e ]---

Nhà phát triển trình điều khiển có thể tìm thấy trình điều khiển và thiết bị bao gồm cả dấu vết ngăn xếp
của cuộc gọi DMA API đã gây ra cảnh báo này.

Theo mặc định, chỉ có lỗi đầu tiên mới dẫn đến thông báo cảnh báo. Tất cả khác
lỗi sẽ chỉ được tính âm thầm. Hạn chế này tồn tại để ngăn chặn mã
khỏi làm ngập nhật ký kernel của bạn. Để hỗ trợ gỡ lỗi trình điều khiển thiết bị, điều này có thể
bị vô hiệu hóa thông qua debugfs. Xem tài liệu giao diện debugfs bên dưới để biết
chi tiết.

Thư mục debugfs cho mã gỡ lỗi DMA API được gọi là dma-api/. trong
thư mục này hiện có thể tìm thấy các tập tin sau:

====================================================================================
dma-api/all_errors Tệp này chứa một giá trị số. Nếu điều này
				giá trị không bằng 0 mã gỡ lỗi
				sẽ in cảnh báo cho mọi lỗi nó tìm thấy
				vào nhật ký hạt nhân. Hãy cẩn thận với điều này
				tùy chọn, vì nó có thể dễ dàng làm ngập nhật ký của bạn.

dma-api/disabled Tệp chỉ đọc này chứa ký tự 'Y'
				nếu mã gỡ lỗi bị vô hiệu hóa. Điều này có thể
				xảy ra khi nó hết bộ nhớ hoặc nếu nó
				bị vô hiệu hóa khi khởi động

dma-api/dump Tệp chỉ đọc này chứa DMA hiện tại
				ánh xạ.

dma-api/error_count Tệp này ở chế độ chỉ đọc và hiển thị tổng số
				số lỗi được tìm thấy.

dma-api/num_errors Số trong tệp này hiển thị có bao nhiêu
				cảnh báo sẽ được in vào nhật ký kernel
				trước khi nó dừng lại. Số này được khởi tạo thành
				một khi khởi động hệ thống và được thiết lập bằng cách ghi vào
				tập tin này

dma-api/min_free_entries Tệp chỉ đọc này có thể được đọc để lấy
				số lượng dma_debug_entries miễn phí tối thiểu
				người cấp phát đã từng thấy. Nếu giá trị này đi
				xuống 0 mã sẽ cố gắng tăng
				nr_total_entries để bù đắp.

dma-api/num_free_entries Số lượng dma_debug_entries miễn phí hiện tại
				trong bộ cấp phát.

dma-api/nr_total_entries Tổng số dma_debug_entries trong
				cấp phát, cả miễn phí và được sử dụng.

dma-api/driver_filter Bạn có thể viết tên trình điều khiển vào tệp này
				để giới hạn đầu ra gỡ lỗi đối với các yêu cầu từ đó
				người lái xe cụ thể. Viết một chuỗi trống vào
				tập tin đó để tắt bộ lọc và xem
				lại toàn lỗi.
====================================================================================

Nếu bạn biên dịch mã này vào kernel của mình thì nó sẽ được bật theo mặc định.
Nếu bạn muốn khởi động mà không cần ghi sổ kế toán, bạn có thể cung cấp
'dma_debug=off' làm tham số khởi động. Điều này sẽ vô hiệu hóa việc gỡ lỗi DMA API.
Lưu ý rằng bạn không thể kích hoạt lại nó khi chạy. Bạn phải khởi động lại để làm
vậy.

Nếu bạn chỉ muốn xem thông báo gỡ lỗi cho trình điều khiển thiết bị đặc biệt, bạn có thể
chỉ định tham số dma_debug_driver=<drivername>. Điều này sẽ cho phép
bộ lọc trình điều khiển khi khởi động. Mã gỡ lỗi sẽ chỉ in lỗi cho điều đó
tài xế sau đó. Bộ lọc này có thể bị vô hiệu hóa hoặc thay đổi sau này bằng cách sử dụng debugfs.

Khi mã tự vô hiệu hóa khi chạy, điều này rất có thể là do nó đã chạy
hết dma_debug_entries và không thể phân bổ thêm theo yêu cầu. 65536
các mục được phân bổ trước khi khởi động - nếu mức này quá thấp để bạn khởi động bằng
'dma_debug_entries=<your_desired_number>' để ghi đè mặc định. Lưu ý
rằng mã phân bổ các mục theo đợt, do đó số lượng chính xác của
các mục nhập được phân bổ trước có thể lớn hơn số lượng thực tế được yêu cầu. các
mã sẽ in ra nhật ký kernel mỗi khi nó được phân bổ động
nhiều mục như đã được phân bổ trước ban đầu. Điều này là để chỉ ra rằng một
kích thước phân bổ trước lớn hơn có thể phù hợp hoặc nếu nó xảy ra liên tục
rằng trình điều khiển có thể đang rò rỉ bản đồ.

::

trống rỗng
	debug_dma_mapping_error(thiết bị cấu trúc *dev, dma_addr_t dma_addr);

giao diện dma-debug debug_dma_mapping_error() để gỡ lỗi các trình điều khiển bị lỗi
để kiểm tra lỗi ánh xạ DMA trên các địa chỉ được trả về bởi dma_map_single() và
giao diện dma_map_page(). Giao diện này xóa cờ được đặt bởi
debug_dma_map_phys() để cho biết rằng dma_mapping_error() đã được gọi bởi
người lái xe. Khi trình điều khiển hủy ánh xạ, debug_dma_unmap() sẽ kiểm tra cờ và nếu
cờ này vẫn được đặt, in thông báo cảnh báo bao gồm dấu vết cuộc gọi
dẫn đến unmap. Giao diện này có thể được gọi từ dma_mapping_error()
các thói quen để bật gỡ lỗi kiểm tra lỗi ánh xạ DMA.

Chức năng và cấu trúc
========================

.. kernel-doc:: include/linux/scatterlist.h
.. kernel-doc:: lib/scatterlist.c
