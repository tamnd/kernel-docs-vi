.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-line-event-read.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _GPIO_V2_LINE_EVENT_READ:

***********************
GPIO_V2_LINE_EVENT_READ
***********************

Tên
====

GPIO_V2_LINE_EVENT_READ - Đọc các sự kiện phát hiện cạnh cho các dòng từ một yêu cầu.

Tóm tắt
========

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tập tin của thiết bị ký tự GPIO, như được trả về trong
    ZZ0000ZZ bởi gpio-v2-get-line-ioctl.rst.

ZZ0001ZZ
    Bộ đệm chứa ZZ0000ZZ.

ZZ0001ZZ
    Số byte có sẵn trong ZZ0002ZZ, phải ở mức
    ít nhất là kích thước của một chiếc ZZ0000ZZ.

Sự miêu tả
===========

Đọc các sự kiện phát hiện cạnh cho các dòng từ một yêu cầu.

Tính năng phát hiện cạnh phải được bật cho dòng đầu vào bằng cách sử dụng một trong hai
ZZ0000ZZ hoặc ZZ0001ZZ, hoặc
cả hai. Các sự kiện biên sau đó được tạo ra bất cứ khi nào phát hiện thấy các ngắt biên trên
dòng đầu vào.

Các cạnh được xác định theo các thay đổi đối với giá trị dòng logic, do đó, một cạnh không hoạt động
sang quá trình chuyển đổi tích cực là một lợi thế đang gia tăng.  Nếu ZZ0000ZZ là
được đặt thì cực logic ngược lại với cực vật lý và
ZZ0001ZZ khi đó tương ứng với một cạnh vật lý rơi xuống.

Hạt nhân ghi lại và đánh dấu thời gian các sự kiện cạnh càng gần với sự kiện của chúng càng tốt.
xảy ra và lưu trữ chúng trong bộ đệm để từ đó chúng có thể được đọc bởi
không gian người dùng một cách thuận tiện bằng cách sử dụng ZZ0000ZZ.

Các sự kiện được đọc từ bộ đệm luôn có cùng thứ tự như trước đây
được phát hiện bởi kernel, kể cả khi nhiều dòng đang được giám sát bởi
một yêu cầu.

Kích thước của bộ đệm sự kiện kernel được cố định tại thời điểm yêu cầu dòng
sáng tạo và có thể bị ảnh hưởng bởi
ZZ0000ZZ.
Kích thước mặc định là 16 lần số dòng được yêu cầu.

Bộ đệm có thể bị tràn nếu các sự kiện xảy ra nhanh hơn tốc độ chúng được đọc
theo không gian người dùng. Nếu xảy ra tràn thì sự kiện được lưu vào bộ đệm cũ nhất là
bị loại bỏ. Tràn có thể được phát hiện từ không gian người dùng bằng cách theo dõi sự kiện
số thứ tự.

Để giảm thiểu số lượng lệnh gọi cần thiết để sao chép các sự kiện từ kernel sang
không gian người dùng, ZZ0001ZZ hỗ trợ sao chép nhiều sự kiện. Số sự kiện
được sao chép là số thấp hơn trong số có sẵn trong bộ đệm kernel và
số sẽ vừa với bộ đệm không gian người dùng (ZZ0000ZZ).

Thay đổi cờ phát hiện cạnh bằng gpio-v2-line-set-config-ioctl.rst
không xóa hoặc sửa đổi các sự kiện đã có trong sự kiện kernel
bộ đệm.

ZZ0001ZZ sẽ chặn nếu không có sự kiện nào và ZZ0000ZZ thì không
đã được đặt ZZ0002ZZ.

Có thể kiểm tra sự hiện diện của một sự kiện bằng cách kiểm tra xem ZZ0000ZZ có
có thể đọc được bằng ZZ0001ZZ hoặc tương đương.

Giá trị trả về
============

Khi thành công, số byte được đọc sẽ là bội số của kích thước của một
Sự kiện ZZ0000ZZ.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.