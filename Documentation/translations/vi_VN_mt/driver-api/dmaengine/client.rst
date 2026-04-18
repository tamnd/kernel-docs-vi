.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/dmaengine/client.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Hướng dẫn sử dụng động cơ DMA API
====================

Vinod Koul <vinod dot koul tại intel.com>

.. note:: For DMA Engine usage in async_tx please see:
          ``Documentation/crypto/async-tx-api.rst``


Dưới đây là hướng dẫn dành cho người viết trình điều khiển thiết bị về cách sử dụng Slave-DMA API của
Động cơ DMA. Điều này chỉ áp dụng cho việc sử dụng DMA phụ.

Cách sử dụng DMA
=========

Việc sử dụng DMA nô lệ bao gồm các bước sau:

- Phân bổ kênh nô lệ DMA

- Đặt thông số cụ thể của bộ điều khiển và nô lệ

- Nhận mô tả cho giao dịch

- Gửi giao dịch

- Đưa ra các yêu cầu đang chờ xử lý và chờ thông báo gọi lại

Chi tiết của các hoạt động này là:

1. Phân bổ kênh phụ DMA

Việc phân bổ kênh hơi khác một chút trong bối cảnh DMA phụ thuộc,
   trình điều khiển máy khách thường cần một kênh từ một DMA cụ thể
   chỉ bộ điều khiển và thậm chí trong một số trường hợp cần có một kênh cụ thể.
   Để yêu cầu một kênh dma_request_chan() API được sử dụng.

Giao diện:

   .. code-block:: c

      struct dma_chan *dma_request_chan(struct device *dev, const char *name);

Việc này sẽ tìm và trả về kênh ZZ0000ZZ DMA được liên kết với 'dev'
   thiết bị. Việc liên kết được thực hiện thông qua DT, ACPI hoặc dựa trên tệp bảng
   bảng khớp dma_slave_map.

Kênh được phân bổ thông qua giao diện này là dành riêng cho người gọi,
   cho đến khi dma_release_channel() được gọi.

2. Đặt tham số cụ thể của bộ điều khiển và nô lệ

Bước tiếp theo là chuyển một số thông tin cụ thể tới DMA
   người lái xe. Hầu hết các thông tin chung mà DMA phụ thuộc có thể sử dụng
   nằm trong cấu trúc dma_slave_config. Điều này cho phép khách hàng chỉ định
   Hướng DMA, địa chỉ DMA, độ rộng bus, độ dài cụm DMA, v.v.
   cho thiết bị ngoại vi.

Nếu một số bộ điều khiển DMA có nhiều tham số được gửi thì chúng
   nên cố gắng nhúng struct dma_slave_config vào bộ điều khiển của họ
   cấu trúc cụ thể. Điều đó mang lại sự linh hoạt cho khách hàng để chuyển nhiều hơn
   các thông số nếu được yêu cầu.

Giao diện:

   .. code-block:: c

      int dmaengine_slave_config(struct dma_chan *chan,
cấu trúc dma_slave_config *config)

Vui lòng xem định nghĩa cấu trúc dma_slave_config trong dmaengine.h
   để được giải thích chi tiết về các thành viên cấu trúc. Xin lưu ý
   rằng thành viên 'hướng' sẽ biến mất khi nó trùng lặp
   hướng được đưa ra trong lệnh gọi chuẩn bị.

3. Lấy mô tả giao dịch

Đối với việc sử dụng nô lệ, các chế độ chuyển giao nô lệ khác nhau được hỗ trợ bởi
  Động cơ DMA là:

- Slave_sg: DMA danh sách các bộ đệm thu thập phân tán từ/đến thiết bị ngoại vi

- ngoại vi_dma_vec: DMA một mảng các bộ đệm thu thập phân tán từ/đến một
    ngoại vi. Tương tự như Slav_sg, nhưng sử dụng mảng dma_vec
    cấu trúc thay vì một danh sách phân tán.

- dma_cycle: Thực hiện thao tác DMA theo chu kỳ từ/đến thiết bị ngoại vi cho đến khi
    hoạt động bị dừng rõ ràng.

- interleaved_dma: Điều này phổ biến đối với các máy khách Slave cũng như M2M. Dành cho nô lệ
    Địa chỉ fifo của thiết bị có thể đã được người lái xe biết.
    Nhiều loại hoạt động khác nhau có thể được thể hiện bằng cách thiết lập
    các giá trị thích hợp cho các thành viên 'dma_interleaved_template'. theo chu kỳ
    Cũng có thể chuyển DMA xen kẽ nếu được kênh hỗ trợ bởi
    thiết lập cờ chuyển DMA_PREP_REPEAT.

Việc trả lại không phải NULL của lần chuyển tiền này API đại diện cho một "bộ mô tả" cho
  giao dịch đã cho.

Giao diện:

  .. code-block:: c

     struct dma_async_tx_descriptor *dmaengine_prep_slave_sg(
cấu trúc dma_chan *chan, struct scatterlist *sgl,
		unsigned int sg_len, hướng enum dma_data_direction,
		cờ dài không dấu);

struct dma_async_tx_descriptor *dmaengine_prep_peripheral_dma_vec(
		cấu trúc dma_chan *chan, const struct dma_vec *vecs,
		size_t nents, hướng enum dma_data_direction,
		cờ dài không dấu);

cấu trúc dma_async_tx_descriptor *dmaengine_prep_dma_cycle(
		struct dma_chan *chan, dma_addr_t buf_addr, size_t buf_len,
		size_t Period_len, enum dma_data_direction);

struct dma_async_tx_descriptor *dmaengine_prep_interleaved_dma(
		cấu trúc dma_chan *chan, struct dma_interleaved_template *xt,
		cờ dài không dấu);

Trình điều khiển ngoại vi dự kiến sẽ ánh xạ danh sách phân tán cho
  thao tác DMA trước khi gọi dmaengine_prep_slave_sg() và phải
  giữ bản đồ danh sách phân tán cho đến khi thao tác DMA hoàn tất.
  Danh sách phân tán phải được ánh xạ bằng thiết bị cấu trúc DMA.
  Nếu sau này ánh xạ cần được đồng bộ hóa thì dma_sync_*_for_*() phải được
  cũng được gọi bằng thiết bị cấu trúc DMA.
  Vì vậy, thiết lập bình thường sẽ trông như thế này:

  .. code-block:: c

     struct device *dma_dev = dmaengine_get_dma_device(chan);

     nr_sg = dma_map_sg(dma_dev, sgl, sg_len);
nếu (nr_sg == 0)
		/*lỗi*/

desc = dmaengine_prep_slave_sg(chan, sgl, nr_sg, hướng, cờ);

Khi đã có được bộ mô tả, thông tin gọi lại có thể được
  được thêm vào và sau đó bộ mô tả phải được gửi. Một số động cơ DMA
  người lái xe có thể gặp khó khăn giữa việc chuẩn bị thành công và
  trình nên điều quan trọng là hai hoạt động này phải được kết hợp chặt chẽ
  ghép nối.

  .. note::

     Although the async_tx API specifies that completion callback
     routines cannot submit any new operations, this is not the
     case for slave/cyclic DMA.

     For slave DMA, the subsequent transaction may not be available
     for submission prior to callback function being invoked, so
     slave DMA callbacks are permitted to prepare and submit a new
     transaction.

     For cyclic DMA, a callback function may wish to terminate the
     DMA via dmaengine_terminate_async().

     Therefore, it is important that DMA engine drivers drop any
     locks before calling the callback function which may cause a
     deadlock.

     Note that callbacks will always be invoked from the DMA
     engines tasklet, never from interrupt context.

ZZ0000ZZ

DMAengine cung cấp hai cách để hỗ trợ siêu dữ liệu.

DESC_METADATA_CLIENT

Bộ đệm siêu dữ liệu được phân bổ/cung cấp bởi trình điều khiển máy khách và nó được
    gắn liền với bộ mô tả.

  .. code-block:: c

     int dmaengine_desc_attach_metadata(struct dma_async_tx_descriptor *desc,
				   void *data, size_t len);

DESC_METADATA_ENGINE

Bộ đệm siêu dữ liệu được phân bổ/quản lý bởi trình điều khiển DMA. khách hàng
    người lái xe có thể yêu cầu con trỏ, kích thước tối đa và kích thước hiện đang sử dụng của
    siêu dữ liệu và có thể trực tiếp cập nhật hoặc đọc nó.

Vì trình điều khiển DMA quản lý vùng bộ nhớ chứa siêu dữ liệu nên
    khách hàng phải đảm bảo rằng họ không cố truy cập hoặc lấy con trỏ
    sau khi lệnh gọi lại hoàn tất quá trình chuyển của họ đã chạy cho bộ mô tả.
    Nếu không có lệnh gọi lại hoàn thành nào được xác định cho quá trình chuyển, thì
    không được truy cập siêu dữ liệu sau issue_pending.
    Nói cách khác: nếu mục đích là đọc lại siêu dữ liệu sau khi quá trình truyền hoàn tất
    hoàn thành thì khách hàng phải sử dụng lệnh gọi lại hoàn thành.

  .. code-block:: c

     void *dmaengine_desc_get_metadata_ptr(struct dma_async_tx_descriptor *desc,
size_t *payload_len, size_t *max_len);

int dmaengine_desc_set_metadata_len(struct dma_async_tx_descriptor *desc,
		size_t tải trọng_len);

Trình điều khiển máy khách có thể truy vấn xem chế độ đã cho có được hỗ trợ hay không:

  .. code-block:: c

     bool dmaengine_is_metadata_mode_supported(struct dma_chan *chan,
chế độ enum dma_desc_metadata_mode);

Tùy thuộc vào chế độ sử dụng, trình điều khiển máy khách phải tuân theo quy trình khác nhau.

DESC_METADATA_CLIENT

-DMA_MEM_TO_DEV/DEV_MEM_TO_MEM:

1. chuẩn bị bộ mô tả (dmaengine_prep_*)
         xây dựng siêu dữ liệu trong bộ đệm của máy khách
      2. sử dụng dmaengine_desc_attach_metadata() để gắn bộ đệm vào
         sự mô tả
      3. nộp chuyển khoản

-DMA_DEV_TO_MEM:

1. chuẩn bị bộ mô tả (dmaengine_prep_*)
      2. sử dụng dmaengine_desc_attach_metadata() để gắn bộ đệm vào
         sự mô tả
      3. nộp chuyển khoản
      4. khi quá trình truyền hoàn tất, siêu dữ liệu sẽ có sẵn trong
         bộ đệm đính kèm

DESC_METADATA_ENGINE

-DMA_MEM_TO_DEV/DEV_MEM_TO_MEM:

1. chuẩn bị bộ mô tả (dmaengine_prep_*)
      2. sử dụng dmaengine_desc_get_metadata_ptr() để đưa con trỏ tới
         khu vực siêu dữ liệu của công cụ
      3. cập nhật siêu dữ liệu tại con trỏ
      4. sử dụng dmaengine_desc_set_metadata_len() để báo cho công cụ DMA biết
         lượng dữ liệu khách hàng đã đặt vào bộ đệm siêu dữ liệu
      5. nộp chuyển khoản

-DMA_DEV_TO_MEM:

1. chuẩn bị bộ mô tả (dmaengine_prep_*)
      2. nộp chuyển khoản
      3. khi hoàn tất chuyển giao, hãy sử dụng dmaengine_desc_get_metadata_ptr() để nhận
         con trỏ tới khu vực siêu dữ liệu của công cụ
      4. đọc siêu dữ liệu từ con trỏ

  .. note::

     When DESC_METADATA_ENGINE mode is used the metadata area for the descriptor
     is no longer valid after the transfer has been completed (valid up to the
     point when the completion callback returns if used).

     Mixed use of DESC_METADATA_CLIENT / DESC_METADATA_ENGINE is not allowed,
     client drivers must use either of the modes per descriptor.

4. Gửi giao dịch

Khi bộ mô tả đã được chuẩn bị và thông tin gọi lại
   đã thêm, nó phải được đặt trên hàng đợi chờ xử lý của trình điều khiển động cơ DMA.

Giao diện:

   .. code-block:: c

      dma_cookie_t dmaengine_submit(struct dma_async_tx_descriptor *desc)

Điều này trả về một cookie có thể được sử dụng để kiểm tra tiến trình của công cụ DMA
   hoạt động thông qua các lệnh gọi công cụ DMA khác không được đề cập trong tài liệu này.

dmaengine_submit() sẽ không bắt đầu hoạt động DMA, nó chỉ thêm
   nó vào hàng đợi chờ xử lý. Để biết điều này, hãy xem bước 5, dma_async_issue_pending.

   .. note::

      After calling ``dmaengine_submit()`` the submitted transfer descriptor
      (``struct dma_async_tx_descriptor``) belongs to the DMA engine.
      Consequently, the client must consider invalid the pointer to that
      descriptor.

5. Đưa ra các yêu cầu DMA đang chờ xử lý và chờ thông báo gọi lại

Các giao dịch trong hàng chờ chờ có thể được kích hoạt bằng cách gọi
   issue_pending API. Nếu kênh không hoạt động thì giao dịch đầu tiên trong
   hàng đợi được bắt đầu và những cái tiếp theo được xếp hàng.

Khi hoàn thành mỗi thao tác DMA, thao tác tiếp theo trong hàng đợi sẽ được bắt đầu và
   một tasklet được kích hoạt. Sau đó, tasklet sẽ gọi trình điều khiển máy khách
   thói quen gọi lại hoàn thành để thông báo, nếu được đặt.

Giao diện:

   .. code-block:: c

      void dma_async_issue_pending(struct dma_chan *chan);

API khác
------------

1. Chấm dứt API

   .. code-block:: c

      int dmaengine_terminate_sync(struct dma_chan *chan)
      int dmaengine_terminate_async(struct dma_chan *chan)
      int dmaengine_terminate_all(struct dma_chan *chan) /* DEPRECATED */

Điều này khiến mọi hoạt động của kênh DMA bị dừng và có thể
   loại bỏ dữ liệu trong DMA FIFO chưa được chuyển hoàn toàn.
   Sẽ không có chức năng gọi lại nào được gọi cho bất kỳ quá trình chuyển không hoàn tất nào.

Có sẵn hai biến thể của chức năng này.

dmaengine_terminate_async() có thể không đợi cho đến khi DMA được tải đầy đủ
   đã dừng hoặc cho đến khi mọi lệnh gọi lại hoàn chỉnh đang chạy kết thúc. Nhưng nó là
   có thể gọi dmaengine_terminate_async() từ ngữ cảnh nguyên tử hoặc từ
   trong một cuộc gọi lại hoàn chỉnh. dmaengine_synchronize() phải được gọi trước nó
   an toàn để giải phóng bộ nhớ được truy cập bằng cách truyền DMA hoặc giải phóng tài nguyên
   được truy cập từ bên trong cuộc gọi lại hoàn chỉnh.

dmaengine_terminate_sync() sẽ đợi quá trình chuyển và mọi thao tác đang chạy
   hoàn thành các cuộc gọi lại để kết thúc trước khi nó quay trở lại. Nhưng chức năng này không được
   được gọi từ ngữ cảnh nguyên tử hoặc từ bên trong một lệnh gọi lại hoàn chỉnh.

dmaengine_terminate_all() không được dùng nữa và không được sử dụng trong mã mới.

2. Tạm dừng API

   .. code-block:: c

      int dmaengine_pause(struct dma_chan *chan)

Việc này sẽ tạm dừng hoạt động trên kênh DMA mà không mất dữ liệu.

3. Tiếp tục API

   .. code-block:: c

       int dmaengine_resume(struct dma_chan *chan)

Tiếp tục kênh DMA đã tạm dừng trước đó. Việc tiếp tục lại là không hợp lệ
   kênh hiện không bị tạm dừng.

4. Kiểm tra Txn hoàn tất

   .. code-block:: c

      enum dma_status dma_async_is_tx_complete(struct dma_chan *chan,
cookie dma_cookie_t, dma_cookie_t *last, dma_cookie_t *used)

Điều này có thể được sử dụng để kiểm tra trạng thái của kênh. Xin vui lòng xem
   tài liệu trong include/linux/dmaengine.h để có thông tin đầy đủ hơn
   mô tả về API này.

Điều này có thể được sử dụng cùng với dma_async_is_complete() và
   cookie được trả về từ dmaengine_submit() để kiểm tra
   hoàn thành một giao dịch DMA cụ thể.

   .. note::

      Not all DMA engine drivers can return reliable information for
      a running DMA channel. It is recommended that DMA engine users
      pause or stop (via dmaengine_terminate_all()) the channel before
      using this API.

5. Đồng bộ hóa đầu cuối API

   .. code-block:: c

      void dmaengine_synchronize(struct dma_chan *chan)

Đồng bộ hóa việc chấm dứt kênh DMA với bối cảnh hiện tại.

Hàm này nên được sử dụng sau dmaengine_terminate_async() để đồng bộ hóa
   việc chấm dứt kênh DMA đối với bối cảnh hiện tại. Chức năng sẽ
   đợi quá trình chuyển và mọi lệnh gọi lại hoàn chỉnh đang chạy kết thúc trước khi thực hiện
   trở lại.

Nếu dmaengine_terminate_async() được sử dụng để dừng kênh DMA thì chức năng này
   phải được gọi trước khi an toàn để giải phóng bộ nhớ được truy cập trước đó
   mô tả đã gửi hoặc để giải phóng bất kỳ tài nguyên nào được truy cập trong phạm vi hoàn chỉnh
   gọi lại các mô tả đã gửi trước đó.

Hành vi của hàm này không được xác định nếu dma_async_issue_pending() có
   được gọi giữa dmaengine_terminate_async() và hàm này.
