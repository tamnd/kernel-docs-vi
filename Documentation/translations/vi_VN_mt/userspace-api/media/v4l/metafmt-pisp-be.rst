.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-pisp-be.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-rpi-be-cfg:

*************************
V4L2_META_FMT_RPI_BE_CFG
*************************

Định dạng cấu hình Raspberry Pi PiSP Back End
===============================================

Bộ xử lý tín hiệu hình ảnh từ bộ nhớ đến bộ nhớ Raspberry PiSP Back End là
được cấu hình bởi không gian người dùng bằng cách cung cấp bộ đệm các tham số cấu hình
tới nút thiết bị video đầu ra ZZ0001ZZ bằng cách sử dụng
Giao diện ZZ0000ZZ.

PiSP Back End xử lý hình ảnh theo từng ô và cấu hình của nó yêu cầu
chỉ định hai bộ tham số khác nhau bằng cách điền các thành viên của
ZZ0000ZZ được xác định trong tệp tiêu đề ZZ0001ZZ.

ZZ0000ZZ
cung cấp mô tả chi tiết về cấu hình và lập trình back end ISP
mô hình.

Dữ liệu cấu hình toàn cầu
-------------------------

Dữ liệu cấu hình chung mô tả cách các pixel trong một hình ảnh cụ thể
được xử lý và do đó được chia sẻ trên tất cả các ô của hình ảnh. Vì vậy
ví dụ: các tham số LSC (Hiệu chỉnh bóng mờ ống kính) hoặc Khử nhiễu sẽ phổ biến
trên tất cả các ô từ cùng một khung.

Dữ liệu cấu hình chung được chuyển tới ISP bằng cách điền thành viên của
ZZ0000ZZ.

Thông số ô
---------------

Khi ISP xử lý hình ảnh theo ô, mỗi bộ tham số ô sẽ mô tả cách
một ô trong hình ảnh sẽ được xử lý. Một bộ gạch duy nhất
các tham số bao gồm 160 byte dữ liệu và để xử lý một loạt các khối ảnh
bộ tham số ô được yêu cầu.

Các tham số ô được chuyển tới ISP bằng cách điền thành viên của
Các trường ZZ0001ZZ và ZZ0002ZZ của ZZ0000ZZ.

Các kiểu dữ liệu uAPI của Raspberry Pi PiSP Back End
==========================================

Phần này mô tả các loại dữ liệu được Raspberry Pi tiếp xúc với không gian người dùng
Phần cuối của PiSP. Phần này chỉ mang tính thông tin, mô tả chi tiết về
mỗi trường đề cập đến ZZ0000ZZ.

.. kernel-doc:: include/uapi/linux/media/raspberrypi/pisp_be_config.h