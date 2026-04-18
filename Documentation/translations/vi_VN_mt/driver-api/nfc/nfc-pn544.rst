.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/nfc/nfc-pn544.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================================================
Trình điều khiển hạt nhân cho chip Giao tiếp trường gần NXP của Chất bán dẫn PN544
==================================================================================


Tổng quan
---------

PN544 là mô-đun truyền dẫn tích hợp dành cho thiết bị không tiếp xúc
giao tiếp. Trình điều khiển nằm trong ổ đĩa/nfc/ và được biên dịch dưới dạng
mô-đun có tên là "pn544".

Giao diện máy chủ: I2C, SPI và HSU, trình điều khiển này hiện chỉ hỗ trợ I2C.

Giao thức
---------

Ở chế độ bình thường (HCI) và ở chế độ cập nhật chương trình cơ sở, đọc và
các hàm ghi hoạt động hơi khác một chút vì các định dạng tin nhắn
hoặc các giao thức khác nhau.

Ở chế độ bình thường (HCI), giao thức được sử dụng có nguồn gốc từ ETSI
Đặc điểm kỹ thuật HCI. Phần sụn được cập nhật bằng một giao thức cụ thể,
khác với HCI.

Tin nhắn HCI bao gồm tiêu đề 8 bit và nội dung tin nhắn. các
tiêu đề chứa độ dài tin nhắn. Kích thước tối đa cho tin nhắn HCI là
33. Ở chế độ HCI, tin nhắn đã gửi được kiểm tra xem có đúng không
tổng kiểm tra. Thông báo cập nhật firmware có độ dài tính bằng giây (MSB)
và byte thứ ba (LSB) của tin nhắn. Độ dài tin nhắn FW tối đa là
1024 byte.

Để biết thông số kỹ thuật ETSI HCI, hãy xem
ZZ0000ZZ
