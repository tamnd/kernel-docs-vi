.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/scpi-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân scpi-hwmon
========================

Chip được hỗ trợ:

* Chip dựa trên giao diện bộ xử lý điều khiển hệ thống ARM

Địa chỉ được quét: -

Bảng dữ liệu: ZZ0000ZZ

Tác giả: Punit Agrawal <punit.agrawal@arm.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ giám sát phần cứng cho SoC dựa trên ARM
Bộ xử lý điều khiển hệ thống (SCP) thực hiện Kiểm soát hệ thống
Giao diện bộ xử lý (SCPI). Các loại cảm biến sau được hỗ trợ
bởi SCP:

* nhiệt độ
  * điện áp
  * hiện tại
  * quyền lực

Giao diện SCP cung cấp API để truy vấn các cảm biến có sẵn và
giá trị của chúng sau đó được trình điều khiển này xuất sang không gian người dùng.

Ghi chú sử dụng
-----------

Trình điều khiển dựa vào nút cây thiết bị để biểu thị sự hiện diện của SCPI
hỗ trợ trong hạt nhân. Xem
Documentation/devicetree/binds/firmware/arm,scpi.yaml để biết chi tiết về
nút cây thiết bị.
