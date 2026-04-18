.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/spufs/spu_run.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
spu_run
=======


Tên
====
spu_run - thực thi bối cảnh spu


Tóm tắt
========

       ::

#include <sys/spu.h>

int spu_run(int fd, unsigned int *npc, unsigned int *event);

Sự miêu tả
===========
Lệnh gọi hệ thống spu_run được sử dụng trên các máy PowerPC triển khai
       Kiến trúc Công cụ Băng thông rộng Di động để truy cập Synergistic Pro-
       Đơn vị cessor (SPU).  Nó sử dụng fd được trả về từ spu_cre-
       eat(2) để giải quyết bối cảnh SPU cụ thể. Khi bối cảnh được lên lịch-
       được dẫn đến SPU vật lý, nó bắt đầu thực thi tại con trỏ lệnh
       được thông qua trong npc.

Việc thực thi mã SPU diễn ra đồng bộ, nghĩa là spu_run thực hiện
       không quay trở lại trong khi SPU vẫn đang chạy. Nếu có nhu cầu thực hiện
       mã SPU dễ thương song song với mã khác trên CPU chính hoặc
       các SPU khác, trước tiên bạn cần tạo một luồng thực thi mới, ví dụ:
       sử dụng lệnh gọi pthread_create(3).

Khi spu_run trả về, giá trị hiện tại của con trỏ lệnh SPU
       được ghi lại vào npc, vì vậy bạn có thể gọi lại spu_run mà không cần cập nhật
       các con trỏ.

sự kiện có thể là con trỏ NULL hoặc trỏ đến mã trạng thái mở rộng
       được lấp đầy khi spu_run quay trở lại. Nó có thể là một trong những điều sau đây
       câu nói:

SPE_EVENT_DMA_ALIGNMENT
              Lỗi căn chỉnh DMA

SPE_EVENT_SPE_DATA_SEGMENT
              Lỗi phân đoạn DMA

SPE_EVENT_SPE_DATA_STORAGE
              Lỗi lưu trữ DMA

Nếu NULL được chuyển làm đối số sự kiện, những lỗi này sẽ dẫn đến
       tín hiệu được chuyển đến quá trình gọi.

Giá trị trả về
============
spu_run trả về giá trị của thanh ghi spu_status hoặc -1 để biểu thị
       lỗi và đặt errno thành một trong các mã lỗi được liệt kê bên dưới.   các
       Giá trị thanh ghi spu_status chứa một mặt nạ bit gồm các mã trạng thái và
       tùy chọn mã 14 bit được trả về từ lệnh dừng và tín hiệu
       trên SPU. Mặt nạ bit cho mã trạng thái là:

0x02
	      SPU đã bị dừng bằng tín hiệu dừng.

0x04
	      SPU đã bị dừng lại.

0x08
	      SPU đang chờ kênh.

0x10
	      SPU ở chế độ một bước.

0x20
	      SPU đã cố thực hiện một lệnh không hợp lệ.

0x40
	      SPU đã cố truy cập kênh không hợp lệ.

0x3fff0000
              Các bit được che bằng giá trị này chứa mã được trả về từ
              dừng và báo hiệu.

Luôn có một hoặc nhiều trong số 8 bit thấp hơn được đặt hoặc có lỗi
       mã được trả về từ spu_run.

Lỗi
======
EAGAIN hoặc EWOULDBLOCK
              fd ở chế độ không chặn và spu_run sẽ chặn.

EBADF fd không phải là bộ mô tả tệp hợp lệ.

EFAULT npc không phải là con trỏ hợp lệ hoặc trạng thái không phải là NULL cũng như không hợp lệ
              con trỏ.

EINTR Đã xảy ra tín hiệu khi đang tiến hành spu_run.  Giá trị npc
              đã được cập nhật lên giá trị bộ đếm chương trình mới nếu cần thiết.

EINVAL fd không phải là bộ mô tả tệp được trả về từ spu_create(2).

ENOMEM Không đủ bộ nhớ để xử lý kết quả lỗi trang-
              từ truy cập bộ nhớ trực tiếp MFC.

ENOSYS chức năng này không được cung cấp bởi hệ thống hiện tại, bởi vì
              phần cứng không cung cấp SPU hoặc mô-đun spufs
              không được tải.


Ghi chú
=====
spu_run được sử dụng từ các thư viện triển khai nhiều hơn
       giao diện trừu tượng cho SPU, không được sử dụng từ các ứng dụng thông thường.
       Xem ZZ0000ZZ để biết thông tin
       các thư viện được đề xuất.


Phù hợp với
=============
Cuộc gọi này dành riêng cho Linux và chỉ được triển khai bởi ppc64
       kiến trúc. Các chương trình sử dụng lệnh gọi hệ thống này không thể di chuyển được.


Lỗi
====
Mã chưa triển khai đầy đủ tất cả các tính năng được nêu ở đây.


Tác giả
======
Arnd Bergmann <arndb@de.ibm.com>

Xem thêm
========
khả năng(7), close(2), spu_create(2), spufs(7)