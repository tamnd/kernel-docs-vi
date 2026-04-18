.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-image-process.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _image-process-controls:

*******************************
Tham chiếu kiểm soát quá trình hình ảnh
*******************************

Lớp điều khiển Quá trình Hình ảnh được thiết kế để kiểm soát mức độ thấp của
chức năng xử lý ảnh. Không giống như ZZ0000ZZ,
các điều khiển trong lớp này ảnh hưởng đến việc xử lý hình ảnh và không kiểm soát
việc nắm bắt nó.


.. _image-process-control-id:

ID kiểm soát quá trình hình ảnh
=========================

ZZ0000ZZ
    Bộ mô tả lớp IMAGE_PROC.

.. _v4l2-cid-link-freq:

ZZ0000ZZ
    Tần số của bus dữ liệu (ví dụ: song song hoặc CSI-2).

.. _v4l2-cid-pixel-rate:

ZZ0000ZZ
    Tốc độ lấy mẫu pixel trong mảng pixel của thiết bị. Sự kiểm soát này là
    chỉ đọc và đơn vị của nó là pixel/giây.

Một số thiết bị sử dụng khoảng trống ngang và dọc để định cấu hình khung
    tỷ lệ. Tốc độ khung hình có thể được tính từ tốc độ pixel, tốc độ cắt tương tự
    hình chữ nhật cũng như khoảng trống ngang và dọc. Tỷ lệ pixel
    điều khiển có thể có trong một thiết bị phụ khác với điều khiển trống
    và cấu hình hình chữ nhật cắt tương tự.

Việc cấu hình tốc độ khung hình được thực hiện bằng cách chọn tốc độ khung hình mong muốn
    khoảng trống ngang và dọc. Đơn vị của điều khiển này là Hz.

ZZ0000ZZ
    Một số thiết bị chụp/hiển thị/cảm biến có khả năng tạo ra
    hình ảnh mẫu thử nghiệm Các mẫu thử nghiệm phần cứng cụ thể này có thể
    được sử dụng để kiểm tra xem một thiết bị có hoạt động tốt không.

ZZ0001ZZ
    Chế độ khử xen kẽ video (chẳng hạn như Bob, Weave, ...). Các mục menu là
    trình điều khiển cụ thể và được ghi lại trong ZZ0000ZZ.

ZZ0000ZZ
    Tăng ích kỹ thuật số là giá trị mà tất cả các thành phần màu sắc
    được nhân với. Thông thường mức tăng kỹ thuật số được áp dụng là
    giá trị kiểm soát chia cho ví dụ 0x100, nghĩa là không nhận được
    mức tăng kỹ thuật số, giá trị điều khiển cần phải là 0x100. Việc không đạt được
    cấu hình cũng thường là mặc định.