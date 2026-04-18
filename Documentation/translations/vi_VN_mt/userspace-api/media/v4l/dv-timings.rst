.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dv-timings.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _dv-timings:

*******************************
Định giờ video kỹ thuật số (DV)
*******************************

Các tiêu chuẩn video được thảo luận cho đến nay đều liên quan đến Analog TV
và thời gian video tương ứng. Ngày nay có nhiều thứ khác nhau hơn
giao diện phần cứng như giao diện TV độ nét cao (HDMI), VGA,
Đầu nối DVI, v.v., mang tín hiệu video và cần phải
mở rộng API để chọn thời gian video cho các giao diện này. Kể từ khi
không thể mở rộng ZZ0000ZZ
do số lượng bit sẵn có có hạn nên một bộ ioctls mới đã được thêm vào
đặt/nhận thời gian video ở đầu vào và đầu ra.

Các ioctls này xử lý việc định giờ chi tiết của video kỹ thuật số xác định
từng định dạng video. Điều này bao gồm các tham số như video hoạt động
chiều rộng và chiều cao, phân cực tín hiệu, hiên trước, hiên sau, đồng bộ
chiều rộng, v.v. Tiêu đề ZZ0002ZZ có thể được sử dụng để lấy
thời gian của các định dạng trong ZZ0000ZZ và ZZ0001ZZ
tiêu chuẩn.

Để liệt kê và truy vấn các thuộc tính của thời gian DV được hỗ trợ bởi một
ứng dụng thiết bị sử dụng
ZZ0000ZZ và
ZZ0001ZZ ioctls. Để thiết lập
Định giờ DV cho các ứng dụng thiết bị sử dụng
ZZ0002ZZ ioctl và để nhận
thời gian DV hiện tại họ sử dụng
ZZ0003ZZ ioctl. Để phát hiện
thời gian DV mà các ứng dụng thu video nhìn thấy sử dụng
ZZ0004ZZ ioctl.

Khi phần cứng phát hiện sự thay đổi nguồn video (ví dụ:
tín hiệu xuất hiện hoặc biến mất hoặc độ phân giải video thay đổi), sau đó
nó sẽ phát hành một sự kiện ZZ0002ZZ. Sử dụng
ZZ0000ZZ và
ZZ0001ZZ để kiểm tra xem sự kiện này có được báo cáo hay không.

Nếu tín hiệu video thay đổi thì ứng dụng phải dừng
phát trực tuyến, giải phóng tất cả bộ đệm và gọi ZZ0000ZZ
để có được thời gian video mới và nếu chúng hợp lệ, nó có thể đặt
những người đó bằng cách gọi ZZ0001ZZ.
Điều này cũng sẽ cập nhật định dạng, vì vậy hãy sử dụng ZZ0002ZZ
để có được định dạng mới. Bây giờ ứng dụng có thể phân bổ bộ đệm mới
và bắt đầu truyền phát lại.

ZZ0000ZZ sẽ chỉ báo cáo những gì
phần cứng phát hiện, nó sẽ không bao giờ thay đổi cấu hình. Nếu
thời gian hiện được đặt và thời gian được phát hiện thực tế khác nhau, sau đó
thông thường điều này có nghĩa là bạn sẽ không thể nắm bắt được bất kỳ
video. Cách tiếp cận đúng là dựa vào ZZ0001ZZ
sự kiện để bạn biết khi nào có điều gì đó thay đổi.

Các ứng dụng có thể sử dụng ZZ0000ZZ và
Cờ ZZ0001ZZ để xác định xem kỹ thuật số
ioctls video có thể được sử dụng với đầu vào hoặc đầu ra nhất định.