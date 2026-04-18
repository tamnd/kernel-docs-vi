.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-output.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _output:

**********************
Giao diện đầu ra video
**********************

Thiết bị đầu ra video mã hóa ảnh tĩnh hoặc chuỗi hình ảnh dưới dạng video analog
tín hiệu. Với giao diện này các ứng dụng có thể điều khiển việc mã hoá
xử lý và di chuyển hình ảnh từ không gian người dùng sang trình điều khiển.

Thông thường các thiết bị đầu ra video V4L2 được truy cập thông qua ký tự
các tập tin đặc biệt của thiết bị có tên ZZ0000ZZ và ZZ0001ZZ để
ZZ0002ZZ có số chính 81 và số phụ từ 0 đến 63.
ZZ0003ZZ thường là một liên kết tượng trưng đến video ưa thích
thiết bị.

.. note:: The same device file names are used also for video capture devices.

Khả năng truy vấn
=====================

Các thiết bị hỗ trợ giao diện đầu ra video đặt
Cờ ZZ0003ZZ hoặc ZZ0004ZZ trong
trường cấu trúc ZZ0005ZZ
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Là thiết bị phụ
các chức năng họ cũng có thể hỗ trợ ZZ0002ZZ
(ZZ0006ZZ) giao diện. Ít nhất một trong các thao tác đọc/ghi hoặc
các phương thức I/O phát trực tuyến phải được hỗ trợ. Bộ điều biến và đầu ra âm thanh
là tùy chọn.

Chức năng bổ sung
======================

Các thiết bị đầu ra video phải hỗ trợ ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ và
ZZ0004ZZ ioctls khi cần thiết. các
ZZ0005ZZ ioctls phải được hỗ trợ bởi tất cả video
các thiết bị đầu ra.

Thỏa thuận định dạng hình ảnh
=============================

Đầu ra được xác định bởi các thông số cắt xén và định dạng hình ảnh. các
trước đây hãy chọn một vùng của hình ảnh video nơi hình ảnh sẽ xuất hiện,
sau này là cách hình ảnh được lưu trữ trong bộ nhớ, tức là. đ. ở định dạng RGB hoặc YUV,
số bit trên mỗi pixel hoặc chiều rộng và chiều cao. Cùng nhau họ cũng
xác định cách thu nhỏ hình ảnh trong quá trình này.

Như thường lệ các thông số này được reset ZZ0001ZZ tại ZZ0000ZZ
đã đến lúc cho phép các chuỗi công cụ Unix, lập trình một thiết bị và sau đó viết
với nó như thể nó là một tập tin đơn giản. Các ứng dụng V4L2 được viết tốt đảm bảo
họ thực sự có được những gì họ muốn, bao gồm cả việc cắt xén và chia tỷ lệ.

Việc khởi tạo cắt xén ở mức tối thiểu yêu cầu đặt lại các tham số thành
mặc định. Một ví dụ được đưa ra trong ZZ0000ZZ.

Để truy vấn các ứng dụng định dạng hình ảnh hiện tại, hãy đặt trường ZZ0004ZZ của
một cấu trúc ZZ0000ZZ để
ZZ0005ZZ hoặc ZZ0006ZZ
và gọi ZZ0001ZZ ioctl bằng một con trỏ
đến cấu trúc này. Trình điều khiển điền vào cấu trúc
ZZ0002ZZ ZZ0007ZZ hoặc cấu trúc
ZZ0003ZZ ZZ0008ZZ
thành viên của công đoàn ZZ0009ZZ.

Để yêu cầu các ứng dụng tham số khác nhau, hãy đặt trường ZZ0005ZZ của
struct ZZ0000ZZ như trên và khởi tạo tất cả
các trường của cấu trúc ZZ0001ZZ
ZZ0006ZZ là thành viên của liên minh ZZ0007ZZ, hoặc tốt hơn là chỉ cần sửa đổi kết quả
của ZZ0002ZZ và gọi ZZ0003ZZ
ioctl bằng một con trỏ tới cấu trúc này. Người lái xe có thể điều chỉnh
các tham số và cuối cùng trả về các tham số thực tế là ZZ0004ZZ
có.

Giống như ZZ0000ZZ ZZ0001ZZ ioctl
có thể được sử dụng để tìm hiểu về các giới hạn phần cứng mà không cần tắt I/O hoặc
có thể tốn thời gian chuẩn bị phần cứng.

Nội dung của struct ZZ0000ZZ và
cấu trúc ZZ0001ZZ là
được thảo luận trong ZZ0002ZZ. Xem thêm thông số kỹ thuật của
Các ioctls ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ cho
chi tiết. Các thiết bị đầu ra video phải triển khai cả ZZ0006ZZ
và ZZ0007ZZ ioctl, ngay cả khi ZZ0008ZZ bỏ qua tất cả
yêu cầu và luôn trả về các tham số mặc định như ZZ0009ZZ.
ZZ0010ZZ là tùy chọn.

Viết hình ảnh
==============

Thiết bị đầu ra video có thể hỗ trợ ZZ0000ZZ
và/hoặc phát trực tuyến (ZZ0001ZZ hoặc
ZZ0002ZZ) I/O. Xem ZZ0003ZZ để biết chi tiết.