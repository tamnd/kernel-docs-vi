.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/macsmc-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển hạt nhân macsmc-hwmon
==========================

Phần cứng được hỗ trợ

* Máy Mac Apple Silicon (M1 trở lên)

Tác giả: James Calligeros <jcalligeros99@gmail.com>

Sự miêu tả
-----------

macsmc-hwmon hiển thị bộ điều khiển Quản lý hệ thống của Apple
cảm biến nhiệt độ, điện áp, dòng điện và công suất, cũng như
tốc độ quạt và khả năng kiểm soát, thông qua hwmon.

Bởi vì mỗi chiếc Apple Silicon Mac đều có một bộ cảm biến khác nhau
(ví dụ: MacBook hiển thị dữ liệu đo từ xa về pin không có trên
máy Mac để bàn), các cảm biến có trên bất kỳ máy cụ thể nào đều được mô tả
thông qua Devicetree. Người lái xe nhặt những thứ này lên và đăng ký với
hwmon khi được thăm dò.

Tốc độ quạt thủ công được hỗ trợ thông qua tham số mô-đun fan_control. Cái này
bị tắt theo mặc định và được đánh dấu là không an toàn vì không thể chứng minh được điều đó
hệ thống sẽ không an toàn nếu quá nóng do điều khiển quạt bằng tay
đã sử dụng.

giao diện sysfs
---------------

hiện tạiX_input
    Giá trị ampe kế

currX_label
    Nhãn ampe kế

fanX_input
    Tốc độ quạt hiện tại

fanX_label
    Nhãn quạt

người hâm mộX_min
    Tốc độ quạt tối thiểu có thể

fanX_max
    Tốc độ quạt tối đa có thể

fanX_target
    Điểm đặt quạt hiện tại

inX_input
    Giá trị vôn kế

inX_label
    Nhãn vôn kế

powerX_input
    Giá trị đồng hồ đo điện

powerX_label
    Nhãn đồng hồ đo điện

tempX_input
    Giá trị cảm biến nhiệt độ

tempX_label
    Nhãn cảm biến nhiệt độ
