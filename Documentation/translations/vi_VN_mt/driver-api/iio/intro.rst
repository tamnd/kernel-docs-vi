.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/iio/intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============
Giới thiệu
=============

Mục đích chính của hệ thống con I/O công nghiệp (IIO) là cung cấp hỗ trợ
đối với các thiết bị theo một nghĩa nào đó thực hiện hoặc
chuyển đổi tương tự sang số (ADC) hoặc chuyển đổi kỹ thuật số sang tương tự (DAC)
hoặc cả hai. Mục đích là để lấp đầy khoảng trống giữa hwmon hơi giống nhau và
Hệ thống con ZZ0000ZZ. Hwmon hướng tới tốc độ mẫu thấp
cảm biến dùng để giám sát và điều khiển chính hệ thống, như điều khiển tốc độ quạt
hoặc đo nhiệt độ. ZZ0001ZZ, đúng như tên gọi của nó,
tập trung vào các thiết bị đầu vào tương tác của con người (bàn phím, chuột, màn hình cảm ứng).
Trong một số trường hợp, có sự chồng chéo đáng kể giữa những điều này và IIO.

Các thiết bị thuộc loại này bao gồm:

* Bộ chuyển đổi tương tự sang số (ADC)
* gia tốc kế
* điện dung cho bộ chuyển đổi kỹ thuật số (CDC)
* Bộ chuyển đổi kỹ thuật số sang analog (DAC)
* con quay hồi chuyển
* đơn vị đo quán tính (IMU)
* Cảm biến màu sắc và ánh sáng
* từ kế
* cảm biến áp suất
* cảm biến tiệm cận
* cảm biến nhiệt độ

Thông thường các cảm biến này được kết nối qua ZZ0000ZZ hoặc
ZZ0001ZZ. Trường hợp sử dụng phổ biến của các thiết bị cảm biến là có
chức năng kết hợp (ví dụ: ánh sáng cộng với cảm biến tiệm cận).
