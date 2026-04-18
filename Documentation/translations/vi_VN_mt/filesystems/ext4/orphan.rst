.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/orphan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tập tin mồ côi
-----------

Trong unix có thể có các nút không được liên kết khỏi hệ thống phân cấp thư mục nhưng
vẫn còn sống vì chúng được mở. Trong trường hợp gặp sự cố, hệ thống tập tin phải
dọn sạch các nút này nếu không chúng (và các khối được tham chiếu từ chúng)
sẽ bị rò rỉ. Tương tự, nếu chúng ta cắt bớt hoặc mở rộng tệp, chúng ta không thể
để thực hiện thao tác trong một giao dịch ghi nhật ký duy nhất. Trong trường hợp như vậy chúng tôi
theo dõi inode dưới dạng mồ côi để trong trường hợp xảy ra sự cố, các khối bổ sung được phân bổ cho
tập tin bị cắt bớt.

Theo truyền thống, ext4 theo dõi các nút mồ côi dưới dạng danh sách liên kết đơn trong đó
siêu khối chứa số inode của inode mồ côi cuối cùng (s_last_orphan
trường) và sau đó mỗi inode chứa số inode của phần mồ côi trước đó
inode (chúng tôi nạp chồng trường i_dtime inode cho việc này). Tuy nhiên hệ thống tập tin này
danh sách liên kết đơn toàn cầu là một nút thắt cổ chai về khả năng mở rộng đối với khối lượng công việc dẫn đến
trong việc tạo ra nhiều inode mồ côi. Khi tính năng tập tin mồ côi
(COMPAT_ORPHAN_FILE) được bật, hệ thống tập tin có một nút đặc biệt
(được tham chiếu từ siêu khối đến s_orphan_file_inum) với một số
khối. Mỗi khối này có cấu trúc:

============== ================================ ===================================
Loại offset Tên Mô tả
============== ================================ ===================================
0x0 Mảng inode mồ côi Mỗi mục nhập __le32 là một trong hai
              __le32 mục nhập trống (0) hoặc chứa
	                                       số inode của trẻ mồ côi
					       inode.
blocksize-8 __le32 ob_magic Giá trị ma thuật được lưu trữ ở dạng mồ côi
                                               chặn đuôi (0x0b10ca04)
blocksize-4 __le32 ob_checksum Tổng kiểm tra của khối mồ côi.
============== ================================ ===================================

Khi một hệ thống tệp có tính năng tệp mồ côi được gắn kết có thể ghi, chúng tôi đặt
Tính năng RO_COMPAT_ORPHAN_PRESENT trong siêu khối để cho biết có thể có
là các mục mồ côi hợp lệ. Trong trường hợp chúng tôi thấy tính năng này khi gắn
hệ thống tập tin, chúng tôi đọc toàn bộ tệp mồ côi và xử lý tất cả các nút mồ côi được tìm thấy
ở đó như thường lệ. Khi ngắt kết nối hoàn toàn hệ thống tập tin, chúng tôi sẽ xóa
Tính năng RO_COMPAT_ORPHAN_PRESENT để tránh việc quét trẻ mồ côi không cần thiết
tập tin và cũng làm cho hệ thống tập tin hoàn toàn tương thích với các hạt nhân cũ hơn.