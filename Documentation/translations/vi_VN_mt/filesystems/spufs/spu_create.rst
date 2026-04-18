.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/spufs/spu_create.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
spu_tạo
==========

Tên
====
spu_create - tạo bối cảnh spu mới


Tóm tắt
========

       ::

#include <sys/types.h>
         #include <sys/spu.h>

int spu_create(const char *tên đường dẫn, cờ int, chế độ mode_t);

Sự miêu tả
===========
Lệnh gọi hệ thống spu_create được sử dụng trên các máy PowerPC triển khai
       Kiến trúc Công cụ Băng thông rộng Di động để truy cập Synergistic
       Đơn vị xử lý (SPU). Nó tạo ra một bối cảnh logic mới cho SPU trong
       tên đường dẫn và trả về một thẻ điều khiển được liên kết với nó.   tên đường dẫn phải
       trỏ đến một thư mục không tồn tại trong điểm gắn kết của tệp SPU
       hệ thống (spufs).  Khi spu_create thành công, một thư mục sẽ được tạo
       ghi trên tên đường dẫn và nó được điền với các tập tin.

Việc xử lý tệp được trả về chỉ có thể được chuyển tới spu_run(2) hoặc bị đóng,
       các hoạt động khác không được xác định trên đó. Khi nó đóng lại, tất cả mọi người
       các mục nhập thư mục trong spufs sẽ bị xóa. Khi tập tin cuối cùng xử lý
       trỏ vào bên trong thư mục ngữ cảnh hoặc vào tệp này
       bộ mô tả bị đóng, bối cảnh SPU logic bị hủy.

Các cờ tham số có thể bằng 0 hoặc bất kỳ sự kết hợp bitwise hoặc'd nào của
       các hằng số sau:

SPU_RAWIO
              Cho phép ánh xạ một số thanh ghi phần cứng của SPU vào
              không gian người dùng. Cờ này yêu cầu khả năng CAP_SYS_RAWIO, xem
              khả năng(7).

Tham số chế độ chỉ định các quyền được sử dụng để tạo mới
       thư mục trong spufs.   chế độ được sửa đổi với giá trị umask(2) của người dùng
       và sau đó được sử dụng cho cả thư mục và các tập tin chứa trong đó. các
       quyền truy cập tệp che giấu một số bit chế độ hơn vì chúng thường
       chỉ hỗ trợ quyền truy cập đọc hoặc ghi. Xem stat(2) để biết danh sách đầy đủ các
       giá trị chế độ có thể.


Giá trị trả về
============
spu_create trả về một bộ mô tả tệp mới. Nó có thể trả về -1 để chỉ ra
       một tình trạng lỗi và đặt errno thành một trong các mã lỗi được liệt kê
       bên dưới.


Lỗi
======
EACCES
              Người dùng hiện tại không có quyền ghi trên mount spufs
              điểm.

EEXIST Bối cảnh SPU đã tồn tại ở tên đường dẫn đã cho.

Tên đường dẫn EFAULT không phải là con trỏ chuỗi hợp lệ trong địa chỉ hiện tại
              không gian.

Tên đường dẫn EINVAL không phải là một thư mục trong điểm gắn kết spufs.

ELOOP Đã tìm thấy quá nhiều liên kết tượng trưng khi phân giải tên đường dẫn.

EMFILE Quá trình đã đạt đến giới hạn tệp mở tối đa.

ENAMETOOLONG
              tên đường dẫn quá dài.

ENFILE Hệ thống đã đạt đến giới hạn tệp mở toàn cầu.

ENOENT Một phần tên đường dẫn không thể giải quyết được.

ENOMEM Hạt nhân không thể phân bổ tất cả các tài nguyên cần thiết.

ENOSPC Không có đủ tài nguyên SPU để tạo mới
              ngữ cảnh hoặc giới hạn cụ thể của người dùng đối với số lượng SPU
              văn bản đã đạt được.

ENOSYS chức năng này không được cung cấp bởi hệ thống hiện tại, bởi vì
              phần cứng không cung cấp SPU hoặc mô-đun spufs
              không được tải.

ENOTDIR
              Một phần của tên đường dẫn không phải là một thư mục.



Ghi chú
=====
spu_create được sử dụng từ các thư viện triển khai nhiều hơn
       giao diện trừu tượng cho SPU, không được sử dụng từ các ứng dụng thông thường.
       Xem ZZ0000ZZ để biết thông tin
       các thư viện được đề xuất.


Tập tin
=====
tên đường dẫn phải trỏ đến một vị trí bên dưới điểm gắn kết của spufs.  Bởi
       quy ước, nó được gắn vào /spu.


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
khả năng(7), close(2), spu_run(2), spufs(7)