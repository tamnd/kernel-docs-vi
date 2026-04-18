.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/gpio/gpio-get-lineevent-ioctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _GPIO_GET_LINEEVENT_IOCTL:

*************************
GPIO_GET_LINEEVENT_IOCTL
*************************

.. warning::
    This ioctl is part of chardev_v1.rst and is obsoleted by
    gpio-v2-get-line-ioctl.rst.

Tên
====

GPIO_GET_LINEEVENT_IOCTL - Yêu cầu một dòng có tính năng phát hiện cạnh từ kernel.

Tóm tắt
========

.. c:macro:: GPIO_GET_LINEEVENT_IOCTL

ZZ0000ZZ

Đối số
=========

ZZ0000ZZ
    Bộ mô tả tệp của thiết bị ký tự GPIO được trả về bởi ZZ0001ZZ.

ZZ0001ZZ
    ZZ0000ZZ chỉ định dòng
    để yêu cầu và cấu hình của nó.

Sự miêu tả
===========

Yêu cầu một dòng có tính năng phát hiện cạnh từ kernel.

Nếu thành công, quy trình yêu cầu được cấp quyền truy cập độc quyền vào dòng
giá trị và có thể nhận các sự kiện khi các cạnh được phát hiện trên đường thẳng, như
được mô tả trong gpio-lineevent-data-read.rst.

Trạng thái của một dòng được đảm bảo duy trì theo yêu cầu cho đến khi được trả về
bộ mô tả tập tin đã bị đóng. Khi bộ mô tả tập tin được đóng lại, trạng thái của
dòng trở nên không được kiểm soát từ góc độ không gian người dùng và có thể hoàn nguyên
về trạng thái mặc định của nó.

Yêu cầu một đường dây đã được sử dụng là một lỗi (ZZ0000ZZ).

Yêu cầu phát hiện cạnh trên một đường truyền không hỗ trợ ngắt là một
lỗi (ZZ0000ZZ).

Như với ZZ0000ZZ,
cấu hình thiên vị là nỗ lực tốt nhất.

Việc đóng ZZ0000ZZ không ảnh hưởng đến các sự kiện dòng hiện có.

Quy tắc cấu hình
-------------------

Các quy tắc cấu hình sau đây được áp dụng:

Sự kiện dòng được yêu cầu làm đầu vào, do đó không có cờ cụ thể cho dòng đầu ra,
ZZ0000ZZ, ZZ0001ZZ, hoặc
ZZ0002ZZ, có thể được đặt.

Chỉ có thể đặt một cờ thiên vị, ZZ0000ZZ.
Nếu không có cờ thiên vị nào được đặt thì cấu hình thiên vị sẽ không thay đổi.

Cờ biên, ZZ0000ZZ và
ZZ0001ZZ, có thể được kết hợp để phát hiện cả hai
và các cạnh rơi xuống.

Yêu cầu cấu hình không hợp lệ là một lỗi (ZZ0000ZZ).

Giá trị trả về
============

Khi thành công 0 và ZZ0000ZZ chứa tệp
mô tả cho yêu cầu.

Về lỗi -1 và biến ZZ0000ZZ được đặt phù hợp.
Các mã lỗi phổ biến được mô tả trong error-codes.rst.