.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/mediactl/media-controller-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _media-controller-intro:

Giới thiệu
============

Các thiết bị đa phương tiện ngày càng xử lý nhiều chức năng liên quan. Nhiều USB
máy ảnh bao gồm micrô, phần cứng quay video cũng có thể xuất ra
giao diện video hoặc camera SoC cũng thực hiện các hoạt động từ bộ nhớ đến bộ nhớ
tương tự như codec video.

Các chức năng độc lập, ngay cả khi được triển khai trong cùng một phần cứng, có thể
được mô hình hóa thành các thiết bị riêng biệt. Máy ảnh USB có micrô sẽ
được trình bày cho các ứng dụng không gian người dùng dưới dạng thiết bị chụp V4L2 và ALSA.
Mối quan hệ của các thiết bị (khi sử dụng webcam, người dùng cuối không nên
phải chọn thủ công micrô USB được liên kết), trong khi chưa thực hiện
có sẵn trực tiếp cho các ứng dụng bởi trình điều khiển, thường có thể
được lấy từ sysfs.

Với ngày càng nhiều thiết bị SoC tiên tiến được giới thiệu, hiện tại
cách tiếp cận sẽ không mở rộng quy mô. Cấu trúc liên kết thiết bị ngày càng trở nên
phức tạp và không phải lúc nào cũng có thể được biểu diễn bằng cấu trúc cây. Phần cứng
các khối được chia sẻ giữa các chức năng khác nhau, tạo ra sự phụ thuộc
giữa các thiết bị dường như không liên quan.

Các API trừu tượng hạt nhân như V4L2 và ALSA cung cấp phương tiện cho
các ứng dụng để truy cập các thông số phần cứng. Khi phần cứng mới hơn bộc lộ một
số lượng các thông số đó ngày càng cao, người lái xe cần phải đoán xem điều gì
các ứng dụng thực sự yêu cầu dựa trên thông tin hạn chế, do đó
thực hiện các chính sách thuộc về không gian người dùng.

Bộ điều khiển phương tiện API nhằm mục đích giải quyết những vấn đề đó.