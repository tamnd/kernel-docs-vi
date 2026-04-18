.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/summary.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Giới thiệu về I2C và SMBus
================================

I²C (phát âm: Tôi bình phương C và viết I2C trong tài liệu kernel) là
một giao thức được phát triển bởi Philips. Nó là một giao thức hai dây có thể thay đổi
tốc độ (thường lên tới 400 kHz, chế độ tốc độ cao lên tới 5 MHz). Nó cung cấp
một bus rẻ tiền để kết nối nhiều loại thiết bị với tần số không thường xuyên hoặc
nhu cầu liên lạc băng thông thấp. I2C được sử dụng rộng rãi với nhúng
hệ thống. Một số hệ thống sử dụng các biến thể không đáp ứng yêu cầu về thương hiệu,
và do đó không được quảng cáo là I2C mà có tên khác,
ví dụ: TWI (Giao diện hai dây), IIC.

Thông số kỹ thuật I2C chính thức mới nhất là ZZ0000ZZ
được xuất bản bởi NXP Semiconductors, phiên bản 7 tính đến thời điểm viết bài này.

SMBus (Bus quản lý hệ thống) dựa trên giao thức I2C và chủ yếu
một tập hợp con của các giao thức và tín hiệu I2C. Nhiều thiết bị I2C sẽ hoạt động trên
SMBus, nhưng một số giao thức SMBus bổ sung thêm ngữ nghĩa ngoài những gì được yêu cầu để
đạt được thương hiệu I2C. Bo mạch chính PC hiện đại dựa trên SMBus. Phổ biến nhất
các thiết bị được kết nối qua SMBus là các mô-đun RAM được định cấu hình bằng EEPROM I2C,
và chip giám sát phần cứng.

Bởi vì SMBus chủ yếu là một tập hợp con của bus I2C tổng quát nên chúng ta có thể
sử dụng các giao thức của nó trên nhiều hệ thống I2C. Tuy nhiên, có những hệ thống không
đáp ứng cả hai ràng buộc về điện SMBus và I2C; và những thứ khác không thể
triển khai tất cả các thông báo hoặc ngữ nghĩa giao thức SMBus phổ biến.


Thuật ngữ
===========

Bus I2C kết nối một hoặc nhiều chip điều khiển và một hoặc nhiều chip mục tiêu.

.. kernel-figure::  i2c_bus.svg
   :alt:    Simple I2C bus with one controller and 3 targets

   Simple I2C bus

Chip ZZ0001ZZ là nút bắt đầu liên lạc với các mục tiêu. trong
Việc triển khai nhân Linux, nó còn được gọi là "bộ chuyển đổi" hoặc "bus". Bộ điều khiển
trình điều khiển thường nằm trong thư mục con ZZ0000ZZ.

ZZ0001ZZ chứa mã chung có thể được sử dụng để triển khai toàn bộ
lớp bộ điều khiển I2C. Mỗi trình điều khiển bộ điều khiển cụ thể phụ thuộc vào một
trình điều khiển thuật toán trong thư mục con ZZ0000ZZ hoặc bao gồm nó
việc thực hiện của riêng mình.

Chip ZZ0000ZZ là một nút phản hồi thông tin liên lạc khi được xử lý bởi một
bộ điều khiển. Trong quá trình triển khai nhân Linux, nó còn được gọi là "máy khách".
Trong khi các mục tiêu thường là các chip bên ngoài riêng biệt, Linux cũng có thể hoạt động như một
target (cần hỗ trợ phần cứng) và phản hồi với bộ điều khiển khác trên xe buýt.
Sau đó nó được gọi là ZZ0001ZZ. Ngược lại, một con chip bên ngoài được gọi là
một chiếc ZZ0002ZZ.

Trình điều khiển mục tiêu được lưu giữ trong một thư mục cụ thể cho tính năng mà chúng cung cấp,
ví dụ ZZ0000ZZ cho thiết bị mở rộng GPIO và ZZ0001ZZ cho
chip liên quan đến video.

Đối với cấu hình ví dụ trong hình trên, bạn sẽ cần một trình điều khiển cho
bộ điều khiển I2C và trình điều khiển cho các mục tiêu I2C của bạn. Thông thường một người lái xe cho
từng mục tiêu.

từ đồng nghĩa
--------

Như đã đề cập ở trên, việc triển khai Linux I2C trước đây sử dụng các thuật ngữ
"bộ chuyển đổi" cho bộ điều khiển và "máy khách" cho mục tiêu. Một số cấu trúc dữ liệu
có những từ đồng nghĩa trong tên của họ. Vì vậy, khi thảo luận chi tiết thực hiện,
bạn cũng nên biết về những điều khoản này. Cách diễn đạt chính thức được ưu tiên hơn,
mặc dù.

Thuật ngữ lỗi thời
--------------------

Trong thông số kỹ thuật I2C trước đó, bộ điều khiển được đặt tên là "chính" và mục tiêu là
được mệnh danh là “nô lệ”. Các thuật ngữ này đã lỗi thời với phiên bản 7 của đặc điểm kỹ thuật và
Việc sử dụng chúng cũng bị Bộ quy tắc ứng xử hạt nhân Linux không khuyến khích. Bạn có thể
vẫn tìm thấy chúng trong các tài liệu tham khảo chưa được cập nhật. các
Tuy nhiên, quan điểm chung là sử dụng các thuật ngữ bao hàm: người kiểm soát và
mục tiêu. Công việc thay thế thuật ngữ cũ trong Nhân Linux đang được tiến hành.
