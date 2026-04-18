.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/dvb/dmx-set-filter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: DTV.dmx

.. _DMX_SET_FILTER:

================
DMX_SET_FILTER
==============

Tên
----

DMX_SET_FILTER

Tóm tắt
--------

.. c:macro:: DMX_SET_FILTER

ZZ0000ZZ

Đối số
---------

ZZ0001ZZ
    Bộ mô tả tệp được trả về bởi ZZ0000ZZ.

ZZ0000ZZ

Con trỏ tới cấu trúc chứa tham số bộ lọc.

Sự miêu tả
-----------

Cuộc gọi ioctl này thiết lập bộ lọc theo bộ lọc và mặt nạ
các thông số được cung cấp. Thời gian chờ có thể được xác định bằng số giây
để chờ một phần được tải. Giá trị 0 có nghĩa là không có thời gian chờ
nên được áp dụng. Cuối cùng có một trường cờ nơi bạn có thể
nêu rõ liệu một phần có nên được kiểm tra CRC hay không, liệu bộ lọc có nên
là bộ lọc "một lần", tức là nếu hoạt động lọc phải được thực hiện
dừng lại sau khi nhận được phần đầu tiên và liệu quá trình lọc có
hoạt động phải được bắt đầu ngay lập tức (không cần đợi
Cuộc gọi ioctl ZZ0000ZZ). Nếu bộ lọc đã được thiết lập trước đó thì điều này
bộ lọc sẽ bị hủy và bộ đệm nhận sẽ bị xóa.

Giá trị trả về
------------

Khi thành công 0 được trả về.

Khi có lỗi -1 được trả về và biến ZZ0000ZZ được đặt
một cách thích hợp.

Các mã lỗi chung được mô tả tại
Chương ZZ0000ZZ.