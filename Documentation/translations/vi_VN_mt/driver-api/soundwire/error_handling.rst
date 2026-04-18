.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/soundwire/error_handling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Xử lý lỗi SoundWire
===========================

SoundWire PHY được thiết kế cẩn thận và các lỗi trên xe buýt sẽ xảy ra
rất khó xảy ra và nếu chúng xảy ra thì nên giới hạn ở một bit
lỗi. Ví dụ về thiết kế này có thể được tìm thấy trong việc đồng bộ hóa
cơ chế (mất đồng bộ sau hai lỗi) và CRC ngắn được sử dụng cho Hàng loạt
Đăng ký quyền truy cập.

Các lỗi có thể được phát hiện bằng nhiều cơ chế:

1. Lỗi xung đột bus hoặc lỗi chẵn lẻ: Cơ chế này dựa vào các trình phát hiện cấp thấp
   độc lập với tải trọng và cách sử dụng và chúng bao gồm cả quyền kiểm soát
   và dữ liệu âm thanh. Việc triển khai hiện tại chỉ ghi lại những lỗi như vậy.
   Những cải tiến có thể làm vô hiệu toàn bộ trình tự lập trình và
   khởi động lại từ một vị trí đã biết. Trong trường hợp có những lỗi như vậy nằm ngoài phạm vi
   trình tự điều khiển/lệnh, không có sự che giấu hoặc phục hồi cho âm thanh
   dữ liệu được kích hoạt bởi giao thức SoundWire thì vị trí xảy ra lỗi cũng sẽ
   tác động đến khả năng nghe của nó (các bit quan trọng nhất sẽ bị ảnh hưởng nhiều hơn trong PCM),
   và sau khi phát hiện một số lỗi như vậy, xe buýt có thể được đặt lại. Lưu ý
   bus đó xung đột do lỗi lập trình (hai luồng sử dụng cùng một bit
   khe cắm) hoặc các sự cố về điện trong quá trình chuyển đổi truyền/nhận không thể
   được phân biệt, mặc dù xung đột bus định kỳ khi bật âm thanh là một
   dấu hiệu của một vấn đề phân bổ xe buýt. Cơ chế ngắt cũng có thể giúp
   xác định các Slave đã phát hiện Bus Clash hoặc Parity Error, nhưng chúng có thể
   không chịu trách nhiệm về các lỗi nên việc đặt lại từng lỗi không phải là một
   chiến lược phục hồi khả thi.

2. Trạng thái lệnh: Mỗi lệnh gắn với một trạng thái, chỉ
   bao gồm việc truyền dữ liệu giữa các thiết bị. Trạng thái ACK cho biết
   rằng lệnh đã được nhận và sẽ được thực thi vào cuối
   khung hiện tại. NAK chỉ ra rằng lệnh bị lỗi và sẽ không
   được áp dụng. Trong trường hợp lập trình xấu (lệnh được gửi đến không tồn tại
   Phụ thuộc hoặc đăng ký không được triển khai) hoặc sự cố về điện, không có phản hồi
   báo hiệu lệnh đã bị bỏ qua. Một số triển khai Master cho phép
   lệnh được truyền lại nhiều lần.  Nếu việc truyền lại không thành công,
   quay lại và khởi động lại toàn bộ trình tự lập trình có thể là một
   giải pháp. Ngoài ra, một số triển khai có thể trực tiếp phát hành xe buýt
   đặt lại và liệt kê lại tất cả các thiết bị.

3. Hết giờ: Trong một số trường hợp như ChannelPrepare hoặc
   ClockStopPrepare, tài xế xe buýt có nhiệm vụ thăm dò trường đăng ký cho đến khi
   nó chuyển sang giá trị NotFinished bằng 0. Thông số kỹ thuật SoundWire MIPI 1.1
   không xác định thời gian chờ nhưng tài liệu MIPI SoundWire DisCo bổ sung thêm
   khuyến nghị về thời gian chờ. Nếu các cấu hình như vậy không hoàn tất,
   trình điều khiển sẽ trả về -ETIMEOUT. Thời gian chờ như vậy là triệu chứng của lỗi
   Thiết bị nô lệ và có khả năng không thể phục hồi được.

Các lỗi trong quá trình cấu hình lại toàn cục là cực kỳ khó khắc phục.
xử lý:

1. BankSwitch: Lỗi trong lệnh cuối cùng phát hành BankSwitch là
   khó quay lại. Việc truyền lại lệnh Chuyển ngân hàng có thể
   có thể thực hiện được trong một thiết lập phân đoạn đơn, nhưng điều này có thể dẫn đến việc đồng bộ hóa
   vấn đề khi kích hoạt nhiều đoạn bus (một lệnh có tác dụng phụ
   chẳng hạn như việc cấu hình lại khung sẽ được xử lý ở các thời điểm khác nhau). Một toàn cầu
   thiết lập lại cứng có thể là giải pháp tốt nhất.

Lưu ý rằng SoundWire không cung cấp cơ chế phát hiện các giá trị không hợp lệ
được ghi vào các sổ đăng ký hợp lệ. Trong một số trường hợp, tiêu chuẩn thậm chí còn đề cập đến
rằng Slave có thể hành xử theo những cách được xác định khi thực hiện. xe buýt
việc triển khai không cung cấp cơ chế phục hồi cho những lỗi như vậy, Slave
hoặc Người triển khai trình điều khiển chính có trách nhiệm ghi các giá trị hợp lệ vào
đăng ký hợp lệ và thực hiện kiểm tra phạm vi bổ sung nếu cần.
