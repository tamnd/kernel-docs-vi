.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/userspace-tools.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Công cụ không gian người dùng
===============

Giới thiệu
------------

Hầu hết các bo mạch chủ đều có chip cảm biến để theo dõi tình trạng hệ thống (như nhiệt độ,
điện áp, tốc độ quạt). Chúng thường được kết nối thông qua bus I2C, nhưng một số
cũng được kết nối trực tiếp thông qua bus ISA.

Trình điều khiển hạt nhân làm cho dữ liệu từ các chip cảm biến có sẵn trong /sys
hệ thống tập tin ảo. Sau đó, các công cụ không gian người dùng được sử dụng để hiển thị kết quả đo được
giá trị hoặc cấu hình chip theo cách thân thiện hơn.

Cảm biến Lm
----------

Bộ tiện ích cốt lõi cho phép bạn lấy thông tin sức khỏe,
thiết lập giới hạn giám sát, v.v. Bạn có thể lấy chúng trên trang chủ của họ
ZZ0000ZZ hoặc dưới dạng gói từ bản phân phối Linux của bạn.

Nếu từ trang web:
Nhận cảm biến lm từ trang web của dự án. Xin lưu ý, bạn chỉ cần không gian người dùng
một phần, vì vậy hãy biên dịch bằng "make user" và cài đặt bằng "make user_install".

Gợi ý chung để mọi thứ hoạt động:

0) nhận tiện ích không gian người dùng của cảm biến lm
1) biên dịch tất cả các trình điều khiển trong phần I2C và Giám sát phần cứng dưới dạng mô-đun
   trong hạt nhân của bạn
2) chạy tập lệnh phát hiện cảm biến, nó sẽ cho bạn biết bạn cần tải mô-đun nào.
3) tải chúng và chạy lệnh "cảm biến", bạn sẽ thấy một số kết quả.
4) sửa lỗi cảm biến.conf, nhãn, giới hạn, ước số quạt
5) nếu có thêm vấn đề, hãy tham khảo FAQ hoặc tài liệu

Tiện ích khác
---------------

Nếu bạn muốn có một số chỉ báo đồ họa về tình trạng hệ thống, hãy tìm các ứng dụng
như: gkrellm, ksensors, xsensors, wmtemp, wmsensors, wmgtemp, ksysguardd,
màn hình phần cứng

Nếu bạn là quản trị viên máy chủ, bạn có thể thử snmpd hoặc mrtgutils.
