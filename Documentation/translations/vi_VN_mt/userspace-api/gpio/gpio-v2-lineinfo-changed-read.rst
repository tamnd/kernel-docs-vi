.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-v2-lineinfo-changed-read.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_V2_LINEINFO_CHANGED_READ:

*****************************
GPIO_V2_LINEINFO_CHANGED_READ
*****************************

Tên
====

GPIO_V2_LINEINFO_CHANGED_READ - Đọc thông tin dòng sự kiện đã thay đổi để xem
dòng từ chip.

Tóm tắt
========

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0001ZZ
    Bộ đệm chứa ZZ0000ZZ.

ZZ0001ZZ
    Số byte có sẵn trong ZZ0002ZZ, tối thiểu phải bằng kích thước
    của sự kiện ZZ0000ZZ.

Sự miêu tả
===========

Đọc các sự kiện đã thay đổi thông tin dòng cho các dòng đã xem từ chip.

.. note::
    Monitoring line info changes is not generally required, and would typically
    only be performed by a system monitoring component.

    These events relate to changes in a line's request state or configuration,
    not its value. Use gpio-v2-line-event-read.rst to receive events when a
    line changes value.

Một dòng phải được theo dõi bằng gpio-v2-get-lineinfo-watch-ioctl.rst để tạo
thông tin thay đổi sự kiện.  Sau đó, một yêu cầu, giải phóng hoặc cấu hình lại
của dòng sẽ tạo ra một sự kiện thay đổi thông tin.

Dấu thời gian của các sự kiện kernel khi chúng xảy ra và lưu trữ chúng trong bộ đệm
từ đó không gian người dùng có thể đọc chúng một cách thuận tiện bằng cách sử dụng ZZ0000ZZ.

Kích thước của bộ đệm sự kiện kernel được cố định ở mức 32 sự kiện trên mỗi ZZ0000ZZ.

Bộ đệm có thể bị tràn nếu các sự kiện xảy ra nhanh hơn tốc độ chúng được đọc
theo không gian người dùng. Nếu tràn xảy ra thì sự kiện gần đây nhất sẽ bị loại bỏ.
Tràn không thể được phát hiện từ không gian người dùng.

Các sự kiện được đọc từ bộ đệm luôn có cùng thứ tự như trước đây
được phát hiện bởi kernel, kể cả khi nhiều dòng đang được giám sát bởi
một chiếc ZZ0000ZZ.

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

Khi thành công, số byte được đọc sẽ là bội số của kích thước
của sự kiện ZZ0000ZZ.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.