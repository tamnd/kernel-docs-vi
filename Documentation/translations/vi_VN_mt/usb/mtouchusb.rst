.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/mtouchusb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
trình điều khiển mtouchusb
==========================

Thay đổi
=======

- 0,3 - Được tạo dựa trên máy quét & INSTALL từ màn hình cảm ứng gốc
  trình điều khiển trên mã miễn phí (ZZ0000ZZ
- Đã sửa đổi cho linux-2.4.18, rồi 2.4.19

- 0,5 - Viết lại hoàn toàn bằng cách sử dụng Đầu vào Linux trong 2.6.3
  Rất tiếc là không có hỗ trợ hiệu chuẩn vào thời điểm này

- 1.4 - Nhiều thay đổi để hỗ trợ EXII 5000UC và dọn dẹp nhà cửa
  Đã thay đổi thiết lập lại từ thiết lập lại nhà phát triển USB tiêu chuẩn thành thiết lập lại nhà cung cấp
  Đã thay đổi dữ liệu được gửi tới máy chủ từ tọa độ bù sang tọa độ thô
  Đã loại bỏ thông số mô-đun nhà cung cấp/sản phẩm
  Đã thực hiện nhiều thử nghiệm thành công với EXII-5010UC

Phần cứng được hỗ trợ
==================

::

Tất cả các bộ điều khiển đều có Nhà cung cấp: 0x0596 & Sản phẩm: 0x0001


Bộ điều khiển Mô tả Mã sản phẩm
        ------------------------------------------------------

Điện dung USB - Vỏ ngọc trai 14-205 (Ngưng sản xuất)
        Điện dung USB - Vỏ đen 14-124 (Ngưng sản xuất)
        USB Điện dung - Không có vỏ 14-206 (Ngưng sản xuất)

Điện dung USB - Vỏ ngọc trai EXII-5010UC
        Điện dung USB - Vỏ đen EXII-5030UC
        Điện dung USB - Không có vỏ EXII-5050UC

Ghi chú của người lái xe
============

Việc cài đặt rất đơn giản, bạn chỉ cần thêm Linux input, Linux USB và
trình điều khiển vào kernel.  Trình điều khiển cũng có thể được xây dựng tùy chọn dưới dạng mô-đun.

Trình điều khiển này dường như là một trong 2 màn hình cảm ứng đầu vào Linux USB
trình điều khiển.  Mặc dù 3M chỉ tạo ra trình điều khiển nhị phân dành cho
tải xuống, tôi vẫn kiên trì cập nhật trình điều khiển này vì tôi muốn sử dụng
màn hình cảm ứng dành cho các ứng dụng nhúng sử dụng QTEmbedded, DirectFB, v.v. Vì vậy, tôi cảm thấy
lựa chọn hợp lý là sử dụng Đầu vào Linux.

Hiện tại không có cách nào để hiệu chỉnh thiết bị thông qua trình điều khiển này.  Kể cả nếu
thiết bị có thể được hiệu chỉnh, trình điều khiển kéo dữ liệu tọa độ thô từ
người điều khiển.  Điều này có nghĩa là việc hiệu chuẩn phải được thực hiện trong vòng
không gian người dùng.

Độ phân giải màn hình bộ điều khiển hiện là 0 đến 16384 cho cả báo cáo X và Y
dữ liệu cảm ứng thô.  Điều này giống nhau đối với USB điện dung cũ và mới
bộ điều khiển.

Có lẽ tại một thời điểm nào đó, một hàm trừu tượng sẽ được đặt vào evdev nên
các chức năng chung như hiệu chuẩn, đặt lại và thông tin nhà cung cấp có thể được thực hiện
được yêu cầu từ không gian người dùng (Và trình điều khiển sẽ xử lý nhà cung cấp cụ thể
nhiệm vụ).

TODO
====

Triển khai lại urb điều khiển để xử lý các yêu cầu đến và đi từ thiết bị
chẳng hạn như hiệu chuẩn, v.v. một lần/nếu nó có sẵn.

Tuyên bố miễn trừ trách nhiệm
==========

Tôi không phải là nhân viên của MicroTouch/3M và cũng chưa từng làm vậy.  3M không hỗ trợ
tài xế này!  Nếu bạn muốn trình điều khiển cảm ứng chỉ được hỗ trợ trong X, vui lòng truy cập:

ZZ0000ZZ

Cảm ơn
======

Xin chân thành cảm ơn 3M Touch Systems về bộ điều khiển EXII-5010UC cho
thử nghiệm!
