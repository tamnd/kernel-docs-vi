.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-isp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hỗ trợ các thông số và thống kê chung của V4L2 ISP
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Lý do thiết kế
================

Các thông số và thống kê cấu hình ISP được xử lý và thu thập bởi
trình điều khiển và trao đổi với không gian người dùng thông qua các loại dữ liệu thường
phản ánh bố cục thanh ghi ngoại vi ISP.

Mỗi trình điều khiển ISP xác định định dạng đầu ra siêu dữ liệu riêng cho các tham số và
một định dạng thu thập siêu dữ liệu để thống kê. Bố cục bộ đệm được thực hiện bởi một
tập hợp các cấu trúc C phản ánh bố cục của các thanh ghi. Số lượng và loại
của cấu trúc C được cố định bởi định nghĩa định dạng và trở thành một phần của Linux
giao diện uAPI/uABI hạt nhân.

Do yêu cầu khắt khe về khả năng tương thích ngược khi mở rộng
giao diện API/ABI của người dùng, sửa đổi siêu dữ liệu đầu ra hoặc chụp trình điều khiển ISP
định dạng sau khi nó đã được tuyến chính chấp nhận là rất khó nếu không muốn nói là không thể.

Trên thực tế, điều thường xảy ra là sau lần sửa đổi đầu tiên được chấp nhận của ISP
trình điều khiển, bố cục bộ đệm cần được sửa đổi để hỗ trợ phần cứng mới
khối, để sửa lỗi hoặc hỗ trợ các phiên bản phần cứng khác nhau.

Mỗi tình huống này sẽ yêu cầu xác định một định dạng siêu dữ liệu mới, làm cho nó
thực sự khó để duy trì và mở rộng trình điều khiển và yêu cầu không gian người dùng để sử dụng
định dạng đúng tùy thuộc vào phiên bản kernel đang sử dụng.

Thông số cấu hình V4L2 ISP
=================================

Vì những lý do này, Video4Linux2 xác định các loại chung cho cấu hình ISP
các thông số và thống kê. Người lái xe vẫn phải tự xác định
định dạng cho các nút chụp và đầu ra siêu dữ liệu của chúng, nhưng bố cục bộ đệm có thể
được xác định bằng cách sử dụng các kiểu mở rộng và phiên bản được xác định bởi
bao gồm/uapi/linux/media/v4l2-isp.h.

Các trình điều khiển dự kiến sẽ cung cấp định nghĩa về các khối ISP được hỗ trợ của chúng
và kích thước tối đa dự kiến của bộ đệm.

Dành cho các nhà phát triển trình điều khiển, một tập hợp các chức năng trợ giúp để hỗ trợ họ xác thực
bộ đệm nhận được từ không gian người dùng có sẵn trong
trình điều khiển/phương tiện/v4l2-core/v4l2-isp.c

Tài liệu hỗ trợ trình điều khiển V4L2 ISP
=====================================
.. kernel-doc:: include/media/v4l2-isp.h