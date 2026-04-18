.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/fuse/fuse-io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Chế độ I/O FUSE
================

Fuse hỗ trợ các chế độ I/O sau:

- trực tiếp-io
- được lưu vào bộ nhớ đệm
  + viết qua
  + bộ đệm ghi lại

Chế độ direct-io có thể được chọn bằng cờ FOPEN_DIRECT_IO trong
FUSE_OPEN trả lời.

Ở chế độ direct-io, bộ đệm trang hoàn toàn bị bỏ qua để đọc và ghi.
Không có việc đọc trước diễn ra. Mmap chia sẻ bị tắt theo mặc định. Để cho phép chia sẻ
mmap, cờ FUSE_DIRECT_IO_ALLOW_MMAP có thể được bật trong phản hồi FUSE_INIT.

Trong chế độ lưu đệm, các lần đọc có thể được đáp ứng từ bộ đệm trang và dữ liệu có thể được
được hạt nhân đọc trước để lấp đầy bộ đệm.  Bộ đệm luôn được giữ nhất quán
sau khi ghi vào tập tin.  Tất cả các chế độ mmap đều được hỗ trợ.

Chế độ được lưu trong bộ nhớ đệm có hai chế độ phụ kiểm soát cách xử lý ghi.  các
chế độ ghi là mặc định và được hỗ trợ trên tất cả các hạt nhân.  các
chế độ bộ đệm ghi lại có thể được chọn bằng cờ FUSE_WRITEBACK_CACHE trong
FUSE_INIT trả lời.

Trong chế độ ghi qua, mỗi lần ghi sẽ được gửi ngay lập tức tới không gian người dùng dưới dạng một hoặc nhiều
các yêu cầu WRITE, cũng như cập nhật bất kỳ trang nào được lưu trong bộ nhớ đệm (và bộ nhớ đệm trước đó
các trang không được lưu vào bộ nhớ cache nhưng được viết đầy đủ).  Không có yêu cầu READ nào được gửi để ghi,
vì vậy khi một trang không được lưu vào bộ đệm được viết một phần, trang đó sẽ bị loại bỏ.

Ở chế độ bộ đệm ghi lại (được bật bởi cờ FUSE_WRITEBACK_CACHE), ghi vào
chỉ bộ đệm, điều đó có nghĩa là tòa nhà ghi (2) thường có thể hoàn thành rất
nhanh chóng.  Các trang bẩn được viết lại một cách ngầm định (viết lại nền hoặc trang
lấy lại áp lực bộ nhớ) hoặc một cách rõ ràng (được gọi bằng close(2), fsync(2) và
khi tham chiếu cuối cùng của tệp được phát hành trên munmap(2)).  Chế độ này
giả định rằng tất cả các thay đổi đối với hệ thống tập tin đều đi qua mô-đun hạt nhân FUSE
(các thuộc tính size và atime/ctime/mtime được kernel cập nhật), vì vậy
nó thường không phù hợp với các hệ thống tập tin mạng.  Nếu một phần trang được
được viết thì trước tiên trang này cần được đọc từ không gian người dùng.  Điều này có nghĩa là
ngay cả đối với các tệp được mở cho O_WRONLY, có thể các yêu cầu READ sẽ được
được tạo ra bởi hạt nhân.