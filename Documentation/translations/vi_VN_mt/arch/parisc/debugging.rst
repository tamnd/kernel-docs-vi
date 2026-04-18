.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/parisc/debugging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Gỡ lỗi PA-RISC
=================

được rồi, đây là một số gợi ý để gỡ lỗi các phần cấp thấp hơn của
linux/parisc.


1. Địa chỉ tuyệt đối
=====================

Rất nhiều mã hợp ngữ hiện đang chạy ở chế độ thực, có nghĩa là
địa chỉ tuyệt đối được sử dụng thay vì địa chỉ ảo như trong
phần còn lại của hạt nhân.  Để dịch địa chỉ tuyệt đối sang địa chỉ ảo
địa chỉ bạn có thể tra cứu trong System.map, thêm __PAGE_OFFSET (0x10000000
hiện nay).


2. HPMC
========

Khi mã chế độ thực cố gắng truy cập vào bộ nhớ không tồn tại, bạn sẽ nhận được
một HPMC thay vì kernel rất tiếc.  Để gỡ lỗi HPMC, hãy thử tìm
địa chỉ của Người phản hồi/Người yêu cầu hệ thống.  Người yêu cầu hệ thống
địa chỉ phải khớp với (một trong) bộ xử lý HPA (địa chỉ cao trong
phạm vi I/O); địa chỉ Phản hồi hệ thống là địa chỉ ở chế độ thực
mã đã cố gắng truy cập.

Các giá trị tiêu biểu cho địa chỉ System Replyer là những địa chỉ lớn hơn
hơn __PAGE_OFFSET (0x10000000) có nghĩa là địa chỉ ảo không
được dịch sang địa chỉ vật lý trước khi mã chế độ thực cố gắng
truy cập nó.


3. Q hơi vui
============

Chắc chắn, mã rất quan trọng phải xóa bit Q trong PSW.  cái gì
xảy ra khi bit Q bị xóa là CPU không cập nhật
đăng ký xử lý gián đoạn đọc để tìm ra nơi máy
bị gián đoạn - vì vậy nếu bạn bị gián đoạn giữa hướng dẫn
xóa bit Q và RFI thiết lập lại nó mà bạn không biết
chính xác nó đã xảy ra ở đâu  Nếu bạn may mắn, IAOQ sẽ trỏ đến
hướng dẫn xóa bit Q, nếu bạn không thấy nó trỏ đến đâu
không hề.  Thông thường các vấn đề về bit Q sẽ hiển thị ở dạng không thể giải thích được.
hệ thống bị treo hoặc hết bộ nhớ vật lý.
