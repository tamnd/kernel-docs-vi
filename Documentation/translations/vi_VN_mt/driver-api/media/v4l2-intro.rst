.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giới thiệu
------------

Trình điều khiển V4L2 có xu hướng rất phức tạp do sự phức tạp của
phần cứng: hầu hết các thiết bị đều có nhiều IC, xuất nhiều nút thiết bị trong
/dev và cũng tạo các thiết bị không phải V4L2 như DVB, ALSA, FB, I2C và đầu vào
(IR) thiết bị.

Đặc biệt là driver V4L2 phải setup IC hỗ trợ để
việc trộn/mã hóa/giải mã âm thanh/video làm cho nó phức tạp hơn hầu hết.
Thông thường các IC này được kết nối với trình điều khiển cầu chính thông qua một hoặc
nhiều xe buýt I2C hơn, nhưng cũng có thể sử dụng các xe buýt khác. Những thiết bị như vậy được
được gọi là 'thiết bị phụ'.

Trong một thời gian dài, khung này bị giới hạn ở cấu trúc video_device dành cho
tạo các nút thiết bị V4L và video_buf để xử lý bộ đệm video
(lưu ý rằng tài liệu này không thảo luận về khung video_buf).

Điều này có nghĩa là tất cả các trình điều khiển phải thực hiện việc thiết lập phiên bản thiết bị và
tự kết nối với các thiết bị phụ. Một số điều này khá phức tạp
làm đúng và nhiều tài xế chưa bao giờ làm đúng.

Ngoài ra còn có rất nhiều mã phổ biến không bao giờ có thể được cấu trúc lại do
thiếu một khuôn khổ.

Vì vậy, khuôn khổ này thiết lập các khối xây dựng cơ bản mà tất cả các trình điều khiển
cần và cùng một khuôn khổ này sẽ giúp việc tái cấu trúc dễ dàng hơn nhiều
mã chung thành các chức năng tiện ích được chia sẻ bởi tất cả các trình điều khiển.

Một ví dụ điển hình để tham khảo là v4l2-pci-skeleton.c
nguồn có sẵn trong samples/v4l/. Nó là một trình điều khiển khung cho
thẻ chụp PCI và trình bày cách sử dụng trình điều khiển V4L2
khuôn khổ. Nó có thể được sử dụng làm mẫu cho trình điều khiển quay video PCI thực sự.

Cấu trúc của trình điều khiển V4L
-------------------------

Tất cả các trình điều khiển có cấu trúc sau:

1) Cấu trúc cho từng phiên bản thiết bị chứa trạng thái thiết bị.

2) Cách khởi tạo và ra lệnh cho các thiết bị con (nếu có).

3) Tạo các nút thiết bị V4L2 (/dev/videoX, /dev/vbiX và /dev/radioX)
   và theo dõi dữ liệu cụ thể của nút thiết bị.

4) Các cấu trúc dành riêng cho tước hiệu tệp chứa dữ liệu trên mỗi tước hiệu tệp;

5) xử lý bộ đệm video.

Đây là một sơ đồ sơ bộ về cách tất cả liên quan:

.. code-block:: none

    device instances
      |
      +-sub-device instances
      |
      \-V4L2 device nodes
	  |
	  \-filehandle instances


Cấu trúc của khung V4L2
-------------------------------

Khung này gần giống với cấu trúc trình điều khiển: nó có v4l2_device
struct cho dữ liệu phiên bản thiết bị, cấu trúc v4l2_subdev để tham chiếu đến
phiên bản thiết bị phụ, cấu trúc video_device lưu trữ dữ liệu nút thiết bị V4L2
và cấu trúc v4l2_fh theo dõi các trường hợp xử lý tệp.

Khung V4L2 cũng tùy chọn tích hợp với khung phương tiện. Nếu một
trình điều khiển đặt trường mdev struct v4l2_device, thiết bị phụ và nút video
sẽ tự động xuất hiện trong khung phương tiện dưới dạng thực thể.