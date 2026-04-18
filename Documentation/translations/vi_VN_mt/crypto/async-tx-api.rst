.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/async-tx-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Chuyển/chuyển đổi không đồng bộ API
=====================================

.. Contents

  1. INTRODUCTION

  2 GENEALOGY

  3 USAGE
  3.1 General format of the API
  3.2 Supported operations
  3.3 Descriptor management
  3.4 When does the operation execute?
  3.5 When does the operation complete?
  3.6 Constraints
  3.7 Example

  4 DMAENGINE DRIVER DEVELOPER NOTES
  4.1 Conformance points
  4.2 "My application needs exclusive control of hardware channels"

  5 SOURCE

1. Giới thiệu
===============

async_tx API cung cấp các phương thức để mô tả chuỗi không đồng bộ
chuyển/chuyển đổi bộ nhớ số lượng lớn với sự hỗ trợ cho liên giao dịch
sự phụ thuộc.  Nó được triển khai như một máy khách dmaengine giúp xử lý trơn tru
chi tiết về việc triển khai công cụ giảm tải phần cứng khác nhau.  Mã
được ghi vào API có thể tối ưu hóa cho hoạt động không đồng bộ và
API sẽ phù hợp với chuỗi hoạt động với mức giảm tải sẵn có
tài nguyên.

2.Phả hệ
===========

API ban đầu được thiết kế để giảm tải bản sao bộ nhớ và
tính toán xor-parity của trình điều khiển md-raid5 bằng cách sử dụng công cụ giảm tải
có trong dòng bộ xử lý I/O Intel(R) Xscale.  Nó cũng được xây dựng
trên lớp 'dmaengine' được phát triển để giảm tải các bản sao bộ nhớ trong
ngăn xếp mạng sử dụng công cụ Intel(R) I/OAT.  Thiết kế sau đây
kết quả là các tính năng nổi lên:

1. đường dẫn đồng bộ ngầm: người dùng API không cần biết liệu
   nền tảng họ đang chạy có khả năng giảm tải.  các
   hoạt động sẽ được giảm tải khi có động cơ và được thực hiện
   trong phần mềm khác.
2. chuỗi phụ thuộc kênh chéo: API cho phép chuỗi phụ thuộc
   các thao tác cần gửi, như xor->copy->xor trong trường hợp raid5.  các
   API tự động xử lý các trường hợp chuyển từ một thao tác
   sang cái khác ngụ ý chuyển đổi kênh phần cứng.
3. tiện ích mở rộng dmaengine để hỗ trợ nhiều máy khách và loại hoạt động
   ngoài 'memcpy'

3. Cách sử dụng
========

3.1 Định dạng chung của API
-----------------------------

::

cấu trúc dma_async_tx_descriptor *
  async_<hoạt động>(<op tham số cụ thể>, struct async_submit_ctl *gửi)

3.2 Các hoạt động được hỗ trợ
------------------------

==================================================================================
sao chép bộ nhớ memcpy giữa bộ đệm nguồn và bộ đệm đích
memset điền vào bộ đệm đích bằng giá trị byte
xor xor một loạt bộ đệm nguồn và ghi kết quả vào một
	  bộ đệm đích
xor_val xor một loạt bộ đệm nguồn và đặt cờ nếu
	  kết quả là bằng không.  Việc thực hiện cố gắng ngăn chặn
	  ghi vào bộ nhớ
pq tạo p+q (hội chứng raid6) từ một loạt bộ đệm nguồn
pq_val xác nhận rằng bộ đệm p và hoặc q được đồng bộ hóa với một loạt các bộ đệm nhất định
	  nguồn
datap (raid6_datap_recov) khôi phục khối dữ liệu raid6 và khối p
	  từ các nguồn nhất định
2data (raid6_2data_recov) khôi phục 2 khối dữ liệu raid6 từ đã cho
	  nguồn
==================================================================================

3.3 Quản lý bộ mô tả
-------------------------

Giá trị trả về không phải là NULL và trỏ đến 'bộ mô tả' khi thao tác
đã được xếp hàng đợi để thực thi không đồng bộ.  Mô tả được tái chế
tài nguyên, dưới sự kiểm soát của trình điều khiển động cơ giảm tải, sẽ được tái sử dụng dưới dạng
hoạt động hoàn tất.  Khi một ứng dụng cần gửi một chuỗi
hoạt động nó phải đảm bảo rằng bộ mô tả không được tự động tái sử dụng
trước khi phần phụ thuộc được gửi.  Điều này đòi hỏi tất cả các mô tả phải được
được ứng dụng thừa nhận trước khi trình điều khiển động cơ giảm tải được phép
tái chế (hoặc miễn phí) bộ mô tả.  Một bộ mô tả có thể được xác nhận bởi một trong những
các phương pháp sau:

1. đặt cờ ASYNC_TX_ACK nếu không có thao tác con nào được gửi
2. gửi một bộ mô tả không được thừa nhận như một phần phụ thuộc vào một bộ mô tả khác
   Cuộc gọi async_tx sẽ ngầm đặt trạng thái được xác nhận.
3. gọi async_tx_ack() trên bộ mô tả.

3.4 Khi nào hoạt động được thực hiện?
------------------------------------

Các hoạt động không được thực hiện ngay lập tức sau khi trở về từ
cuộc gọi async_<oper>.  Giảm tải các hoạt động hàng loạt của trình điều khiển động cơ sang
cải thiện hiệu suất bằng cách giảm số chu kỳ mmio cần thiết để
quản lý kênh.  Sau khi đạt đến ngưỡng dành riêng cho trình điều khiển, trình điều khiển
tự động đưa ra các hoạt động đang chờ xử lý.  Một ứng dụng có thể buộc điều này
sự kiện bằng cách gọi async_tx_issue_pending_all().  Điều này hoạt động trên tất cả
các kênh vì ứng dụng không có kiến thức về kênh hoạt động
lập bản đồ.

3.5 Khi nào hoạt động hoàn tất?
-------------------------------------

Có hai phương pháp để ứng dụng tìm hiểu về việc hoàn thành
của một hoạt động.

1. Gọi dma_wait_for_async_tx().  Cuộc gọi này khiến CPU quay trong khi
   nó thăm dò ý kiến để hoàn thành hoạt động.  Nó xử lý sự phụ thuộc
   chuỗi và phát hành các hoạt động đang chờ xử lý.
2. Chỉ định lệnh gọi lại hoàn thành.  Thói quen gọi lại chạy trong tasklet
   ngữ cảnh nếu trình điều khiển công cụ giảm tải hỗ trợ các ngắt hoặc
   được gọi trong ngữ cảnh ứng dụng nếu thao tác được thực hiện
   đồng bộ trên phần mềm.  Cuộc gọi lại có thể được đặt trong cuộc gọi đến
   async_<opera> hoặc khi ứng dụng cần gửi một chuỗi
   độ dài không xác định, nó có thể sử dụng quy trình async_trigger_callback() để đặt
   hoàn thành ngắt/gọi lại ở cuối chuỗi.

3.6 Ràng buộc
---------------

1. Không được phép gọi tới async_<Operation> trong ngữ cảnh IRQ.  Khác
   ngữ cảnh được cho phép miễn là ràng buộc #2 không bị vi phạm.
2. Các quy trình gọi lại hoàn thành không thể gửi các hoạt động mới.  Cái này
   dẫn đến đệ quy trong trường hợp đồng bộ và spin_locks
   thu được hai lần trong trường hợp không đồng bộ.

3.7 Ví dụ
-----------

Thực hiện thao tác xor->copy->xor trong đó mỗi thao tác phụ thuộc vào
kết quả từ hoạt động trước đó::

#include <linux/async_tx.h>

gọi lại void tĩnh (void *param)
    {
	    hoàn thành(param);
    }

#define NDISKS 2

static void run_xor_copy_xor(trang cấu trúc **xor_srcs,
				 trang cấu trúc *xor_dest,
				 size_t xor_len,
				 trang cấu trúc *copy_src,
				 trang cấu trúc *copy_dest,
				 size_t copy_len)
    {
	    cấu trúc dma_async_tx_descriptor *tx;
	    cấu trúc async_submit_ctl gửi;
	    addr_conv_t addr_conv[NDISKS];
	    cmp hoàn thành cấu trúc;

init_async_submit(&gửi, ASYNC_TX_XOR_DROP_DST, NULL, NULL, NULL,
			    addr_conv);
	    tx = async_xor(xor_dest, xor_srcs, 0, NDISKS, xor_len, &gửi);

submit.depend_tx = tx;
	    tx = async_memcpy(copy_dest, copy_src, 0, 0, copy_len, &submit);

init_completion(&cmp);
	    init_async_submit(&gửi, ASYNC_TX_XOR_DROP_DST | ASYNC_TX_ACK, tx,
			    gọi lại, &cmp, addr_conv);
	    tx = async_xor(xor_dest, xor_srcs, 0, NDISKS, xor_len, &gửi);

async_tx_issue_pending_all();

wait_for_completion(&cmp);
    }

Xem include/linux/async_tx.h để biết thêm thông tin về cờ.  Xem
các quy trình ops_run_* và ops_complete_* trong driver/md/raid5.c để biết thêm
các ví dụ thực hiện

4. Ghi chú phát triển trình điều khiển
===========================

4.1 Điểm phù hợp
----------------------

Có một số điểm tuân thủ cần có trong trình điều khiển dmaengine để
điều chỉnh các giả định được đưa ra bởi các ứng dụng sử dụng async_tx API:

1. Lệnh gọi lại hoàn thành dự kiến sẽ xảy ra trong bối cảnh tasklet
2. Các trường dma_async_tx_descriptor không bao giờ được thao tác trong ngữ cảnh IRQ
3. Sử dụng async_tx_run_dependency() trong đường dẫn dọn dẹp bộ mô tả tới
   xử lý việc gửi các hoạt động phụ thuộc

4.2 "Ứng dụng của tôi cần kiểm soát độc quyền các kênh phần cứng"
-----------------------------------------------------------------

Chủ yếu yêu cầu này phát sinh từ trường hợp trình điều khiển động cơ DMA
đang được sử dụng để hỗ trợ các hoạt động từ thiết bị đến bộ nhớ.  Một kênh đó là
thực hiện các hoạt động này không thể, vì nhiều lý do cụ thể của nền tảng,
được chia sẻ.  Đối với những trường hợp này, giao diện dma_request_channel() là
được cung cấp.

Giao diện là::

struct dma_chan *dma_request_channel(dma_cap_mask_t mặt nạ,
				       dma_filter_fn filter_fn,
				       void *filter_param);

Trong đó dma_filter_fn được định nghĩa là::

bool typedef (*dma_filter_fn)(struct dma_chan *chan, void *filter_param);

Khi tham số 'filter_fn' tùy chọn được đặt thành NULL
dma_request_channel chỉ cần trả về kênh đầu tiên thỏa mãn
mặt nạ năng lực  Mặt khác, khi tham số mặt nạ không đủ cho
chỉ định kênh cần thiết, thủ tục filter_fn có thể được sử dụng để
sắp xếp các kênh có sẵn trong hệ thống. Quy trình filter_fn
được gọi một lần cho mỗi kênh rảnh trong hệ thống.  Khi nhìn thấy một
kênh phù hợp filter_fn trả về DMA_ACK gắn cờ kênh đó
là giá trị trả về từ dma_request_channel.  Một kênh được phân bổ thông qua
giao diện này dành riêng cho người gọi, cho đến khi dma_release_channel()
được gọi.

Cờ khả năng DMA_PRIVATE được sử dụng để gắn thẻ các thiết bị dma cần
không được sử dụng bởi người cấp phát mục đích chung.  Nó có thể được đặt ở
thời gian khởi tạo nếu biết rằng kênh sẽ luôn được
riêng tư.  Ngoài ra, nó được đặt khi dma_request_channel() tìm thấy
kênh "công cộng" không được sử dụng.

Một số lưu ý cần lưu ý khi triển khai trình điều khiển và người tiêu dùng:

1. Khi một kênh đã được phân bổ riêng, kênh đó sẽ không còn được cấp phát nữa.
   được người cấp phát đa năng xem xét ngay cả sau khi có lệnh gọi đến
   dma_release_channel().
2. Vì các khả năng được chỉ định ở cấp thiết bị nên dma_device
   với nhiều kênh sẽ có tất cả các kênh công khai hoặc tất cả
   kênh riêng tư.

5. Nguồn
---------

bao gồm/linux/dmaengine.h:
    tệp tiêu đề cốt lõi cho trình điều khiển DMA và người dùng api
trình điều khiển/dma/dmaengine.c:
    giảm tải quy trình quản lý kênh động cơ
trình điều khiển/dma/:
    vị trí cho trình điều khiển động cơ giảm tải
bao gồm/linux/async_tx.h:
    tệp tiêu đề cốt lõi cho api async_tx
mật mã/async_tx/async_tx.c:
    giao diện async_tx với dmaengine và mã chung
mật mã/async_tx/async_memcpy.c:
    sao chép giảm tải
mật mã/async_tx/async_xor.c:
    giảm tải xor và xor tổng bằng 0