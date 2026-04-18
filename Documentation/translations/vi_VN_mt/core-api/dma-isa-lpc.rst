.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/dma-isa-lpc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
DMA với các thiết bị ISA và LPC
============================

:Tác giả: Pierre Ossman <drzeus@drzeus.cx>

Tài liệu này mô tả cách thực hiện chuyển DMA bằng ISA DMA cũ
bộ điều khiển. Mặc dù ngày nay ISA ít nhiều đã chết nhưng xe buýt LPC
sử dụng cùng hệ thống DMA nên nó sẽ tồn tại khá lâu.

Tiêu đề và phụ thuộc
------------------------

Để thực hiện kiểu ISA DMA, bạn cần bao gồm hai tiêu đề::

#include <linux/dma-mapping.h>
	#include <asm/dma.h>

Đầu tiên là DMA API chung được sử dụng để chuyển đổi địa chỉ ảo thành
địa chỉ xe buýt (xem Tài liệu/core-api/dma-api.rst để biết chi tiết).

Phần thứ hai chứa các quy trình cụ thể cho việc chuyển ISA DMA. Kể từ khi
điều này không có trên tất cả các nền tảng, hãy đảm bảo bạn xây dựng
Kconfig phụ thuộc vào ISA_DMA_API (không phải ISA) để không ai thử
để xây dựng trình điều khiển của bạn trên nền tảng không được hỗ trợ.

Phân bổ bộ đệm
-----------------

Bộ điều khiển ISA DMA có một số yêu cầu rất nghiêm ngặt về
bộ nhớ mà nó có thể truy cập nên phải hết sức cẩn thận khi cấp phát
bộ đệm.

(Bạn thường cần một bộ đệm đặc biệt để chuyển DMA thay vì
chuyển trực tiếp đến và từ cấu trúc dữ liệu thông thường của bạn.)

Không gian địa chỉ có thể sử dụng DMA là 16 MB bộ nhớ vật lý thấp nhất.
Ngoài ra, khối chuyển giao có thể không vượt qua ranh giới trang (là 64
hoặc 128 KiB tùy thuộc vào kênh bạn sử dụng).

Để phân bổ một phần bộ nhớ thỏa mãn tất cả những điều này
yêu cầu bạn chuyển cờ GFP_DMA tới kmalloc.

Thật không may, bộ nhớ khả dụng cho ISA DMA rất khan hiếm nên trừ khi bạn
phân bổ bộ nhớ trong khi khởi động, bạn cũng nên chuyển
__GFP_RETRY_MAYFAIL và __GFP_NOWARN để người cấp phát cố gắng hơn một chút.

(Sự khan hiếm này cũng có nghĩa là bạn nên phân bổ bộ đệm như
càng sớm càng tốt và không nhả nó cho đến khi tải xong trình điều khiển.)

Dịch địa chỉ
-------------------

Để dịch địa chỉ ảo sang địa chỉ bus, hãy sử dụng DMA bình thường
API. Đừng _not_ sử dụng isa_virt_to_bus() mặc dù nó cũng làm như vậy
thứ. Lý do cho điều này là hàm isa_virt_to_bus()
sẽ yêu cầu phụ thuộc Kconfig vào ISA, không chỉ ISA_DMA_API mà
thực sự là tất cả những gì bạn cần. Hãy nhớ rằng mặc dù bộ điều khiển DMA
có nguồn gốc từ ISA, nó được sử dụng ở nơi khác.

Lưu ý: x86_64 có DMA API bị hỏng khi chuyển sang ISA nhưng kể từ đó
đã được sửa. Nếu vòm của bạn có vấn đề thì hãy sửa DMA API thay vì
quay lại các chức năng ISA.

Kênh
--------

Bộ điều khiển ISA DMA bình thường có 8 kênh. Bốn phần dưới dành cho
Truyền 8 bit và bốn phần trên dành cho truyền 16 bit.

(Trên thực tế, bộ điều khiển DMA thực sự là hai bộ điều khiển riêng biệt, trong đó
kênh 4 được sử dụng để cấp quyền truy cập DMA cho bộ điều khiển thứ hai (0-3).
Điều này có nghĩa là trong số bốn kênh 16 bit chỉ có ba kênh có thể sử dụng được.)

Bạn phân bổ những thứ này theo cách tương tự như tất cả các tài nguyên cơ bản:

extern int request_dma(unsigned int dmanr, const char * device_id);
extern void free_dma(unsigned int dmanr);

Khả năng sử dụng truyền 16-bit hoặc 8-bit _không_ phụ thuộc vào bạn với tư cách là
tác giả trình điều khiển nhưng phụ thuộc vào những gì phần cứng hỗ trợ. Kiểm tra của bạn
thông số kỹ thuật hoặc thử nghiệm các kênh khác nhau.

Truyền dữ liệu
-------------

Bây giờ là phần hay nhất, việc chuyển DMA thực tế. :)

Trước khi sử dụng bất kỳ quy trình ISA DMA nào, bạn cần yêu cầu khóa DMA
sử dụng require_dma_lock(). Lý do là một số thao tác DMA bị
không phải nguyên tử nên chỉ có một trình điều khiển có thể thao tác với các thanh ghi tại một thời điểm
thời gian.

Lần đầu sử dụng bộ điều khiển DMA bạn nên gọi
Clear_dma_ff(). Thao tác này sẽ xóa sổ đăng ký nội bộ trong DMA
bộ điều khiển được sử dụng cho các hoạt động phi nguyên tử. Miễn là bạn
(và những người khác) sử dụng chức năng khóa thì bạn chỉ cần
thiết lập lại điều này một lần.

Tiếp theo, bạn cho người điều khiển biết bạn định thực hiện hướng nào
chuyển bằng set_dma_mode(). Hiện tại bạn có các tùy chọn
DMA_MODE_READ và DMA_MODE_WRITE.

Đặt địa chỉ từ nơi quá trình chuyển sẽ bắt đầu (việc này cần phải
được căn chỉnh 16 bit để truyền 16 bit) và cần bao nhiêu byte
chuyển nhượng. Lưu ý rằng đó là _bytes_. Các quy trình DMA sẽ thực hiện tất cả
yêu cầu dịch sang các giá trị mà bộ điều khiển DMA hiểu được.

Bước cuối cùng là kích hoạt kênh DMA và phát hành DMA
khóa.

Sau khi quá trình chuyển DMA kết thúc (hoặc hết thời gian chờ), bạn nên tắt
kênh nữa. Bạn cũng nên kiểm tra get_dma_residue() để thực hiện
chắc chắn rằng tất cả dữ liệu đã được chuyển giao.

Ví dụ::

cờ int, dư lượng;

cờ = require_dma_lock();

clear_dma_ff();

set_dma_mode(kênh, DMA_MODE_WRITE);
	set_dma_addr(kênh, Phys_addr);
	set_dma_count(kênh, num_byte);

dma_enable(kênh);

Release_dma_lock(cờ);

trong khi (!device_done());

cờ = require_dma_lock();

dma_disable(kênh);

dư lượng = dma_get_residue(kênh);
	nếu (dư lượng != 0)
		printk(KERN_ERR "trình điều khiển: Chuyển DMA chưa hoàn tất!"
			" %d byte còn lại!\n", dư lượng);

Release_dma_lock(cờ);

Tạm dừng/tiếp tục
--------------

Trách nhiệm của người lái xe là đảm bảo rằng máy không bị
bị tạm dừng trong khi quá trình chuyển DMA đang được tiến hành. Ngoài ra, tất cả các cài đặt DMA
bị mất khi hệ thống tạm dừng vì vậy nếu trình điều khiển của bạn dựa vào DMA
bộ điều khiển đang ở trạng thái nhất định thì bạn phải khôi phục chúng
đăng ký khi tiếp tục.
