.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/metronomefb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Metronomefb
===========

Được duy trì bởi Jaya Kumar <jayakumar.lkml.gmail.com>

Sửa đổi lần cuối: Ngày 10 tháng 3 năm 2008

Metronomefb là trình điều khiển cho bộ điều khiển hiển thị Metronome. Bộ điều khiển
là của Tập đoàn E-Ink. Nó được thiết kế để sử dụng để điều khiển E-Ink
Phương tiện hiển thị Vizplex. E-Ink lưu trữ một số chi tiết của bộ điều khiển này và
hiển thị phương tiện ở đây ZZ0000ZZ .

Metronome được giao tiếp với máy chủ CPU thông qua giao diện AMLCD. các
máy chủ CPU tạo thông tin điều khiển và hình ảnh trong bộ đệm khung
sau đó được gửi đến giao diện AMLCD bằng phương pháp cụ thể của máy chủ.
Mỗi trạng thái hiển thị và lỗi được kéo qua các GPIO riêng lẻ.

Metronomefb độc lập với nền tảng và phụ thuộc vào trình điều khiển cụ thể của bo mạch
để thực hiện tất cả công việc IO vật lý. Hiện tại, một ví dụ được triển khai cho
Bo mạch PXA được sử dụng trong bộ công cụ phát triển AM-200 EPD. Ví dụ này là am200epd.c

Metronomefb yêu cầu thông tin dạng sóng được gửi qua AMLCD
giao diện với bộ điều khiển máy đếm nhịp. Thông tin dạng sóng dự kiến sẽ
được phân phối từ không gian người dùng thông qua giao diện lớp phần sụn. Tập tin dạng sóng
có thể được nén miễn là tập lệnh udev hoặc hotplug của bạn nhận thức được nhu cầu
để giải nén nó trước khi gửi nó. Metronomefb sẽ yêu cầu metronome.wbf
thường đi vào /lib/firmware/metronome.wbf tùy thuộc vào
thiết lập udev/hotplug. Tôi chỉ thử nghiệm với một tệp dạng sóng duy nhất được
ban đầu được dán nhãn 23P01201_60_WT0107_MTC. Tôi không biết nó tượng trưng cho cái gì.
Cần thận trọng khi thao tác với dạng sóng vì có thể có
khả năng là nó có thể có một số ảnh hưởng lâu dài trên phương tiện hiển thị.
Tôi không có quyền truy cập cũng như không biết chính xác dạng sóng này làm gì về mặt
các phương tiện truyền thông vật lý.

Metronomefb sử dụng giao diện IO trì hoãn để có thể cung cấp bộ nhớ
bộ đệm khung có thể ánh xạ. Nó đã được thử nghiệm với tinyx (Xfbdev). Nó được biết
để làm việc vào lúc này với xeyes, xclock, xloadimage, xpdf.
