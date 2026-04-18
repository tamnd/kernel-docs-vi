.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-image-source.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _image-source-controls:

*******************************
Tham chiếu kiểm soát nguồn hình ảnh
******************************

Lớp điều khiển Nguồn hình ảnh được thiết kế để kiểm soát mức độ thấp của
các thiết bị nguồn hình ảnh như cảm biến hình ảnh. Các thiết bị có tính năng
bộ chuyển đổi tương tự sang số và một bộ phát bus để truyền tín hiệu
dữ liệu hình ảnh ra khỏi thiết bị.


.. _image-source-control-id:

ID kiểm soát nguồn hình ảnh
========================

ZZ0000ZZ
    Bộ mô tả lớp IMAGE_SOURCE.

ZZ0000ZZ
    Làm trống theo chiều dọc. Khoảng thời gian nhàn rỗi sau mỗi khung hình trong đó không có
    dữ liệu hình ảnh được tạo ra. Đơn vị của khoảng trống dọc là đường thẳng.
    Mỗi dòng có chiều dài bằng chiều rộng của hình ảnh cộng với khoảng trống ngang ở
    tốc độ pixel được xác định bởi điều khiển ZZ0001ZZ trong
    cùng một thiết bị phụ.

ZZ0000ZZ
    Khoảng trống ngang. Khoảng thời gian nhàn rỗi sau mỗi dòng dữ liệu hình ảnh
    trong thời gian đó không có dữ liệu hình ảnh nào được tạo ra. Đơn vị ngang
    khoảng trống là pixel.

ZZ0000ZZ
    Độ lợi tương tự là độ lợi ảnh hưởng đến tất cả các thành phần màu trong pixel
    ma trận. Hoạt động khuếch đại được thực hiện trong miền tương tự
    trước khi chuyển đổi A/D.

ZZ0000ZZ
    Mẫu thử thành phần màu đỏ.

ZZ0000ZZ
    Thành phần màu xanh lá cây (bên cạnh màu đỏ) của mẫu thử nghiệm.

ZZ0000ZZ
    Mẫu thử thành phần màu xanh.

ZZ0000ZZ
    Thành phần màu xanh lá cây (bên cạnh màu xanh lam) của mẫu thử nghiệm.

ZZ0001ZZ
    Điều khiển này trả về kích thước ô đơn vị tính bằng nanomet. Cấu trúc
    ZZ0000ZZ cung cấp chiều rộng và chiều cao riêng biệt
    các trường cần xem xét các pixel không đối xứng.
    Việc kiểm soát này không tính đến bất kỳ phần cứng nào có thể xảy ra
    đóng thùng.
    Ô đơn vị bao gồm toàn bộ diện tích của pixel, nhạy cảm và
    không nhạy cảm.
    Điều khiển này là cần thiết để tự động hiệu chỉnh cảm biến/máy ảnh.

.. c:type:: v4l2_area

.. flat-table:: struct v4l2_area
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``width``
      - Width of the area.
    * - __u32
      - ``height``
      - Height of the area.

ZZ0000ZZ
    Cảm biến được thông báo mức tăng nào sẽ được áp dụng cho các mục đích khác nhau
    kênh màu bằng quá trình xử lý tiếp theo (chẳng hạn như bằng ISP). các
    cảm biến chỉ được thông báo về những giá trị này trong trường hợp nó thực hiện
    quá trình xử lý yêu cầu chúng, nhưng bản thân nó không áp dụng chúng cho
    các pixel đầu ra.

Hiện tại nó chỉ được định nghĩa cho các cảm biến của Bayer và là một mảng
    điều khiển lấy 4 giá trị khuếch đại, là mức tăng cho mỗi giá trị
    kênh Bayer. Độ lợi luôn theo thứ tự B, Gb, Gr và R,
    bất kể thứ tự chính xác của cảm biến Bayer.

Việc sử dụng mảng cho phép điều khiển này được mở rộng tới các cảm biến
    chẳng hạn như các CFA không phải của Bayer (mảng lọc màu).

Đơn vị cho các giá trị khuếch đại là tuyến tính, với giá trị mặc định
    đại diện cho mức tăng chính xác là 1,0. Ví dụ: nếu giá trị mặc định này
    được báo cáo là (giả sử) là 128 thì giá trị 192 sẽ đại diện cho
    mức tăng chính xác là 1,5.