.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mmc/mmc-dev-parts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Phân vùng thiết bị SD và MMC
============================

Phân vùng thiết bị là các thiết bị khối logic bổ sung có trên
Thiết bị SD/MMC.

Khi viết bài này, các phân vùng khởi động MMC được hỗ trợ và hiển thị như
/dev/mmcblkXboot0 và /dev/mmcblkXboot1, trong đó X là chỉ mục của
cha/dev/mmcblkX.

Phân vùng khởi động MMC
===================

Quyền truy cập đọc và ghi được cung cấp cho hai phân vùng khởi động MMC. do
tính chất nhạy cảm của nội dung phân vùng khởi động, thường lưu trữ
bảng cấu hình bootloader hoặc bootloader rất quan trọng để khởi động
nền tảng, quyền truy cập ghi bị tắt theo mặc định để giảm nguy cơ
gạch vô tình.

Để bật quyền truy cập ghi vào /dev/mmcblkXbootY, hãy tắt chế độ chỉ đọc bắt buộc
truy cập với::

echo 0 > /sys/block/mmcblkXbootY/force_ro

Để kích hoạt lại quyền truy cập chỉ đọc::

echo 1 > /sys/block/mmcblkXbootY/force_ro

Các phân vùng khởi động cũng có thể bị khóa chỉ đọc cho đến lần bật nguồn tiếp theo,
với::

echo 1 > /sys/block/mmcblkXbootY/ro_lock_until_next_power_on

Đây là một tính năng của thẻ chứ không phải của kernel. Nếu thẻ làm như vậy
không hỗ trợ khóa phân vùng khởi động, tập tin sẽ không tồn tại. Nếu
tính năng đã bị tắt trên thẻ, tập tin sẽ ở chế độ chỉ đọc.

Các phân vùng khởi động cũng có thể bị khóa vĩnh viễn nhưng tính năng này
không thể truy cập thông qua sysfs để tránh vô tình hoặc độc hại
đóng gạch.
