.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-touch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _touch:

*************
Thiết bị cảm ứng
*************

Thiết bị cảm ứng được truy cập thông qua các tệp đặc biệt của thiết bị ký tự có tên
ZZ0000ZZ đến ZZ0001ZZ với số chính 81 và
được phân bổ động các số nhỏ từ 0 đến 255.

Tổng quan
========

Cảm biến có thể là Cảm biến quang học hoặc Cảm ứng điện dung dự kiến ​​(PCT).

Cần phải xử lý để phân tích dữ liệu thô và tạo ra các sự kiện đầu vào. trong
một số hệ thống, việc này có thể được thực hiện trên ASIC và dữ liệu thô hoàn toàn là
kênh bên để chẩn đoán hoặc điều chỉnh. Trong các hệ thống khác, ASIC đơn giản
thiết bị đầu cuối tương tự cung cấp dữ liệu cảm ứng ở tốc độ cao và bất kỳ cảm ứng nào
việc xử lý phải được thực hiện trên máy chủ.

Đối với cảm biến cảm ứng điện dung, màn hình cảm ứng bao gồm một dãy
dây dẫn ngang và dọc (còn gọi là hàng/cột, X/Y
dòng hoặc tx/rx). Điện dung tương hỗ được đo tại các nút nơi
dây dẫn chéo. Ngoài ra, Điện dung tự đo tín hiệu từ mỗi
cột và hàng độc lập.

Đầu vào cảm ứng có thể được xác định bằng cách so sánh phép đo điện dung thô với
phép đo tham chiếu không cần chạm (hoặc "đường cơ sở"):

Delta = Nguyên - Tham khảo

Phép đo tham chiếu có tính đến sự thay đổi điện dung trên
ma trận cảm biến cảm ứng, ví dụ như sự bất thường trong sản xuất,
tác động môi trường hoặc cạnh.

Khả năng truy vấn
=====================

Các thiết bị hỗ trợ giao diện cảm ứng đặt cờ ZZ0002ZZ
và cờ ZZ0003ZZ trong trường ZZ0004ZZ của
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl.

Ít nhất một trong các phương thức đọc/ghi hoặc truyền phát I/O phải được
được hỗ trợ.

Các định dạng được hỗ trợ bởi các thiết bị cảm ứng được ghi lại trong
ZZ0000ZZ.

Đàm phán định dạng dữ liệu
=======================

Một thiết bị cảm ứng có thể hỗ trợ bất kỳ phương thức I/O nào.