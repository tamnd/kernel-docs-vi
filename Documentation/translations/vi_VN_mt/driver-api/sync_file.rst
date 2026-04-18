.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/sync_file.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hướng dẫn đồng bộ file API
==========================

:Tác giả: Gustavo Padovan <gustavo at padovan dot org>

Tài liệu này phục vụ như một hướng dẫn cho người viết trình điều khiển thiết bị về những gì
sync_file API là gì và trình điều khiển có thể hỗ trợ nó như thế nào. Tệp đồng bộ hóa là nhà cung cấp
hàng rào (struct dma_fence) cần thiết để đồng bộ hóa giữa các trình điều khiển hoặc
xuyên qua các ranh giới của quá trình.

sync_file API được sử dụng để gửi và nhận thông tin hàng rào
đến/từ không gian người dùng. Nó cho phép không gian người dùng thực hiện hàng rào rõ ràng, thay vào đó
gắn hàng rào vào bộ đệm bằng trình điều khiển của nhà sản xuất (chẳng hạn như GPU hoặc V4L
driver) gửi hàng rào liên quan đến bộ đệm tới không gian người dùng thông qua sync_file.

Sau đó, sync_file có thể được gửi đến người tiêu dùng (ví dụ: trình điều khiển DRM),
sẽ không sử dụng bộ đệm cho bất cứ điều gì trước tín hiệu của hàng rào, tức là
trình điều khiển đã tạo hàng rào không còn sử dụng/xử lý bộ đệm nữa, vì vậy nó
báo hiệu bộ đệm đã sẵn sàng để sử dụng. Và ngược lại đối với người tiêu dùng ->
phần của nhà sản xuất trong chu trình.

Tệp đồng bộ hóa cho phép nhận biết không gian người dùng về đồng bộ hóa chia sẻ bộ đệm giữa
trình điều khiển.

Tệp đồng bộ hóa ban đầu được thêm vào nhân Android nhưng Máy tính để bàn Linux hiện tại
có thể hưởng lợi rất nhiều từ nó.

hàng rào trong và ngoài hàng rào
------------------------

Các tệp đồng bộ hóa có thể đến hoặc từ không gian người dùng. Khi một sync_file được gửi từ
trình điều khiển cho không gian người dùng mà chúng tôi gọi là hàng rào chứa 'hàng rào ngoài'. Họ là
liên quan đến bộ đệm mà trình điều khiển đang xử lý hoặc sắp xử lý, vì vậy
người lái xe tạo ra một hàng rào bên ngoài để có thể thông báo, thông qua
dma_fence_signal(), khi nó sử dụng xong (hoặc xử lý) bộ đệm đó.
Hàng rào ngoài là hàng rào do người lái xe tạo ra.

Mặt khác, nếu trình điều khiển nhận được (các) hàng rào thông qua sync_file từ
không gian người dùng, chúng tôi gọi (các) hàng rào này là 'trong hàng rào'. Nhận hàng rào có nghĩa là
chúng ta cần đợi (các) hàng rào phát tín hiệu trước khi sử dụng bất kỳ bộ đệm nào liên quan đến
các hàng rào trong.

Tạo tập tin đồng bộ hóa
-------------------

Khi trình điều khiển cần gửi không gian người dùng ngoài hàng rào, nó sẽ tạo một tệp sync_file.

Giao diện::

cấu trúc sync_file *sync_file_create(struct dma_fence *fence);

Người gọi vượt qua hàng rào và lấy lại sync_file. Đó chỉ là
Bước đầu tiên, tiếp theo là cài đặt fd trên tệp sync_file->. Vì vậy nó nhận được một
fd::

fd = get_unused_fd_flags(O_CLOEXEC);

và cài đặt nó trên sync_file->file::

fd_install(fd, sync_file->file);

Bây giờ, fd sync_file có thể được gửi tới không gian người dùng.

Nếu quá trình tạo không thành công hoặc sync_file cần được phát hành bởi bất kỳ ai
lý do khác fput(sync_file->file) nên được sử dụng.

Nhận tệp đồng bộ hóa từ không gian người dùng
-----------------------------------

Khi không gian người dùng cần gửi hàng rào đến trình điều khiển, nó sẽ chuyển bộ mô tả tệp
của Tệp Đồng bộ hóa với kernel. Hạt nhân sau đó có thể lấy hàng rào
từ nó.

Giao diện::

struct dma_fence *sync_file_get_fence(int fd);


Tham chiếu trả về thuộc sở hữu của người gọi và phải được xử lý
sau đó sử dụng dma_fence_put(). Trong trường hợp có lỗi, NULL sẽ được trả về thay thế.

Tài liệu tham khảo:

1. Cấu trúc sync_file trong include/linux/sync_file.h
2. Tất cả các giao diện được đề cập ở trên được xác định trong include/linux/sync_file.h
