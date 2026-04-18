.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/streaming-par.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _streaming-par:

********************
Thông số phát trực tuyến
********************

Các thông số phát trực tuyến nhằm mục đích tối ưu hóa quá trình quay video
cũng như I/O. Hiện nay các ứng dụng có thể yêu cầu chất lượng cao
chế độ chụp với ZZ0000ZZ ioctl.

Tiêu chuẩn video hiện tại xác định số lượng khung hình danh nghĩa cho mỗi
thứ hai. Nếu số lượng khung hình được chụp hoặc xuất ra ít hơn số lượng này,
ứng dụng có thể yêu cầu bỏ qua hoặc sao chép khung trên trình điều khiển
bên. Điều này đặc biệt hữu ích khi sử dụng
ZZ0000ZZ hoặc ZZ0001ZZ, đó là
không được tăng cường bởi dấu thời gian hoặc bộ đếm trình tự và để tránh
sao chép dữ liệu không cần thiết.

Cuối cùng, những ioctls này có thể được sử dụng để xác định số lượng bộ đệm được sử dụng
bên trong bởi trình điều khiển ở chế độ đọc/ghi. Để biết ý nghĩa, hãy xem
phần thảo luận về chức năng ZZ0000ZZ.

Để nhận và thiết lập các thông số phát trực tuyến, các ứng dụng hãy gọi
ZZ0000ZZ và
ZZ0001ZZ ioctl tương ứng. Họ lấy
một con trỏ tới cấu trúc ZZ0002ZZ,
chứa một liên kết chứa các tham số riêng biệt cho đầu vào và đầu ra
thiết bị.

Các ioctls này là tùy chọn, trình điều khiển không cần triển khai chúng. Nếu vậy thì họ
trả về mã lỗi ZZ0000ZZ.