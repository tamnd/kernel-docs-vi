.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/format.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _format:

*****************
Định dạng dữ liệu
*****************

Đàm phán định dạng dữ liệu
=======================

Các thiết bị khác nhau trao đổi các loại dữ liệu khác nhau với các ứng dụng,
ví dụ: hình ảnh video, dữ liệu VBI thô hoặc được cắt lát, gói dữ liệu RDS. Thậm chí
trong một loại có thể có nhiều định dạng khác nhau, đặc biệt có một
sự phong phú của các định dạng hình ảnh. Mặc dù trình điều khiển phải cung cấp mặc định và
việc lựa chọn vẫn tiếp tục khi đóng và mở lại thiết bị,
các ứng dụng phải luôn thương lượng về định dạng dữ liệu trước khi tham gia vào
trao đổi dữ liệu. Đàm phán có nghĩa là ứng dụng yêu cầu một điều kiện cụ thể
định dạng và trình điều khiển sẽ chọn và báo cáo điều tốt nhất mà phần cứng có thể làm
để đáp ứng yêu cầu. Tất nhiên các ứng dụng cũng có thể chỉ cần truy vấn
lựa chọn hiện tại.

Có một cơ chế duy nhất để đàm phán tất cả các định dạng dữ liệu bằng cách sử dụng
cấu trúc tổng hợp ZZ0000ZZ và
ZZ0001ZZ và
ZZ0002ZZ ioctls. Ngoài ra
ZZ0003ZZ ioctl có thể được sử dụng để kiểm tra
phần cứng ZZ0006ZZ làm gì mà không thực sự chọn dữ liệu mới
định dạng. Các định dạng dữ liệu được V4L2 API hỗ trợ được đề cập trong
phần thiết bị tương ứng trong ZZ0004ZZ. Để có cái nhìn sâu hơn về
định dạng hình ảnh xem ZZ0005ZZ.

ZZ0000ZZ ioctl là một bước ngoặt lớn trong
trình tự khởi tạo. Trước thời điểm này, nhiều ứng dụng bảng điều khiển
có thể truy cập đồng thời vào cùng một thiết bị để chọn đầu vào hiện tại,
thay đổi điều khiển hoặc sửa đổi các thuộc tính khác. ZZ0001ZZ đầu tiên
chỉ định một luồng logic (dữ liệu video, dữ liệu VBI, v.v.) dành riêng cho một luồng
bộ mô tả tập tin.

Độc quyền có nghĩa là không có ứng dụng nào khác, chính xác hơn là không có tệp nào khác
bộ mô tả, có thể lấy luồng này hoặc thay đổi thuộc tính thiết bị
không phù hợp với các thông số đã thỏa thuận. Thay đổi tiêu chuẩn video cho
Ví dụ: khi tiêu chuẩn mới sử dụng số dòng quét khác nhau,
có thể làm mất hiệu lực định dạng hình ảnh đã chọn. Vì vậy chỉ có tập tin
bộ mô tả sở hữu luồng có thể thực hiện các thay đổi vô hiệu. Theo đó
nhiều bộ mô tả tệp lấy các luồng logic khác nhau
ngăn chặn nhau can thiệp vào cài đặt của họ. Khi nào cho
lớp phủ video ví dụ sắp bắt đầu hoặc đang diễn ra,
việc quay video đồng thời có thể bị hạn chế ở cùng một mức cắt xén và
kích thước hình ảnh.

Khi các ứng dụng bỏ qua ZZ0000ZZ ioctl phía khóa của nó
các hiệu ứng được ngụ ý ở bước tiếp theo, việc lựa chọn phương pháp I/O
với ZZ0001ZZ ioctl hoặc ẩn
với ZZ0002ZZ đầu tiên hoặc
Cuộc gọi ZZ0003ZZ.

Nói chung chỉ có thể gán một luồng logic cho bộ mô tả tệp,
ngoại lệ là trình điều khiển cho phép quay video đồng thời và
lớp phủ sử dụng cùng một bộ mô tả tệp để tương thích với V4L và
các phiên bản trước của V4L2. Chuyển luồng logic hoặc quay lại
Có thể thực hiện "chế độ bảng điều khiển" bằng cách đóng và mở lại thiết bị. Trình điều khiển
ZZ0001ZZ hỗ trợ switch sử dụng ZZ0000ZZ.

Tất cả các trình điều khiển trao đổi dữ liệu với các ứng dụng phải hỗ trợ
ZZ0000ZZ và ZZ0001ZZ ioctl. Thực hiện các
ZZ0002ZZ rất được khuyến khích nhưng không bắt buộc.

Bảng liệt kê định dạng hình ảnh
========================

Ngoài các chức năng đàm phán định dạng chung, một ioctl đặc biệt để
liệt kê tất cả các định dạng hình ảnh được hỗ trợ bởi quay video, lớp phủ hoặc
thiết bị đầu ra có sẵn. [#f1]_

ZZ0000ZZ ioctl phải được hỗ trợ
bởi tất cả các trình điều khiển trao đổi dữ liệu hình ảnh với các ứng dụng.

.. important::

    Drivers are not supposed to convert image formats in kernel space.
    They must enumerate only formats directly supported by the hardware.
    If necessary driver writers should publish an example conversion
    routine or library for integration into applications.

.. [#f1]
   Enumerating formats an application has no a-priori knowledge of
   (otherwise it could explicitly ask for them and need not enumerate)
   seems useless, but there are applications serving as proxy between
   drivers and the actual video applications for which this is useful.