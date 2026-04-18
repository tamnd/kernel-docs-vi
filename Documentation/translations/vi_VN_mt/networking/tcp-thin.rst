.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tcp-thin.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Dòng mỏng và TCP
======================

Một loạt các dịch vụ dựa trên Internet sử dụng phương tiện truyền tải đáng tin cậy
các giao thức hiển thị cái mà chúng tôi gọi là thuộc tính dòng mỏng. Điều này có nghĩa
rằng ứng dụng gửi dữ liệu với tốc độ thấp đến mức
cơ chế truyền lại của giao thức vận chuyển không đầy đủ
hiệu quả. Trong các tình huống phụ thuộc vào thời gian (như trò chơi trực tuyến, điều khiển
hệ thống, giao dịch chứng khoán, v.v.) nơi trải nghiệm người dùng phụ thuộc
về độ trễ phân phối dữ liệu, việc mất gói có thể gây thiệt hại nghiêm trọng cho
chất lượng dịch vụ. Độ trễ cực cao là do TCP gây ra
phụ thuộc vào sự xuất hiện của dữ liệu mới từ ứng dụng để kích hoạt
truyền lại một cách hiệu quả thông qua truyền lại nhanh thay vì
chờ đợi thời gian chờ đợi lâu.

Sau khi phân tích một số lượng lớn các tương tác phụ thuộc vào thời gian
các ứng dụng, chúng tôi đã thấy rằng chúng thường tạo ra các dòng mỏng
và cũng tuân theo mô hình giao thông này trong suốt toàn bộ
tuổi thọ. Sự kết hợp giữa sự phụ thuộc vào thời gian và thực tế là
Thật đáng tiếc khi các luồng gây ra độ trễ cao khi sử dụng TCP.

Để giảm độ trễ của lớp ứng dụng khi gói tin bị mất,
một bộ cơ chế đã được tạo ra để giải quyết các vấn đề về độ trễ này
đối với dòng chảy mỏng. Nói tóm lại, nếu kernel phát hiện ra một luồng mỏng,
cơ chế truyền lại được sửa đổi theo cách sau:

1) Nếu luồng quá mỏng, hãy truyền lại nhanh trong lần sao chép đầu tiên.
2) Nếu luồng mỏng, không áp dụng thời gian chờ theo cấp số nhân.

Những cải tiến này chỉ được áp dụng nếu luồng được phát hiện là
mỏng. Điều này được thực hiện bằng cách xác định một ngưỡng cho số
của các gói tin trong chuyến bay. Nếu có ít hơn 4 gói trong chuyến bay,
không thể kích hoạt việc truyền lại nhanh và luồng dễ bị
để trải nghiệm độ trễ truyền lại cao.

Vì các cơ chế này nhắm vào các ứng dụng phụ thuộc vào thời gian,
chúng phải được kích hoạt cụ thể bởi ứng dụng bằng cách sử dụng
TCP_THIN_LINEAR_TIMEOUTS và TCP_THIN_DUPACK IOCTLS hoặc
tcp_thin_line_timeouts và tcp_thin_dupack sysctls. Cả hai
sửa đổi được tắt theo mặc định.

Tài liệu tham khảo
==========
Thông tin thêm về các sửa đổi, cũng như một loạt các
dữ liệu thử nghiệm có thể được tìm thấy ở đây:

"Cải thiện độ trễ cho các ứng dụng tương tác, luồng mỏng trên
vận chuyển đáng tin cậy"
ZZ0000ZZ