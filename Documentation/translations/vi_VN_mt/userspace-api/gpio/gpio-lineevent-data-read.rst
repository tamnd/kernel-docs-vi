.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-lineevent-data-read.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _GPIO_LINEEVENT_DATA_READ:

*************************
GPIO_LINEEVENT_DATA_READ
************************

.. warning::
    This ioctl is part of chardev_v1.rst and is obsoleted by
    gpio-v2-line-event-read.rst.

Tên
====

GPIO_LINEEVENT_DATA_READ - Đọc các sự kiện phát hiện cạnh từ một sự kiện đường.

Tóm tắt
========

ZZ0000ZZ

Đối số
=========

ZZ0001ZZ
    Bộ mô tả tập tin của thiết bị ký tự GPIO, như được trả về trong
    ZZ0000ZZ bởi gpio-get-lineevent-ioctl.rst.

ZZ0001ZZ
    Bộ đệm chứa ZZ0000ZZ.

ZZ0001ZZ
    Số byte có sẵn trong ZZ0002ZZ, phải ở mức
    ít nhất là kích thước của một chiếc ZZ0000ZZ.

Sự miêu tả
===========

Đọc các sự kiện phát hiện cạnh cho một dòng từ một sự kiện dòng.

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

Nguồn xung nhịp cho ZZ0000ZZ là
ZZ0002ZZ, ngoại trừ các hạt nhân trước Linux 5.7 khi nó được ra mắt
ZZ0003ZZ.  Không có dấu hiệu nào trong ZZ0001ZZ
về việc sử dụng nguồn đồng hồ nào, nó phải được xác định từ kernel
kiểm tra phiên bản hoặc độ tỉnh táo trên chính dấu thời gian.

Các sự kiện được đọc từ bộ đệm luôn có cùng thứ tự như trước đây
được phát hiện bởi kernel.

Kích thước của bộ đệm sự kiện kernel được cố định ở 16 sự kiện.

Bộ đệm có thể bị tràn nếu các sự kiện xảy ra nhanh hơn tốc độ chúng được đọc
theo không gian người dùng. Nếu tràn xảy ra thì sự kiện gần đây nhất sẽ bị loại bỏ.
Tràn không thể được phát hiện từ không gian người dùng.

Để giảm thiểu số lượng lệnh gọi cần thiết để sao chép các sự kiện từ kernel sang
không gian người dùng, ZZ0001ZZ hỗ trợ sao chép nhiều sự kiện. Số sự kiện
được sao chép là số thấp hơn trong số có sẵn trong bộ đệm kernel và
số sẽ vừa với bộ đệm không gian người dùng (ZZ0000ZZ).

ZZ0001ZZ sẽ chặn nếu không có sự kiện nào và ZZ0000ZZ thì không
đã được đặt ZZ0002ZZ.

Có thể kiểm tra sự hiện diện của một sự kiện bằng cách kiểm tra xem ZZ0000ZZ có
có thể đọc được bằng ZZ0001ZZ hoặc tương đương.

Giá trị trả về
============

Khi thành công, số byte được đọc sẽ là bội số của kích thước của
một sự kiện ZZ0000ZZ.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.