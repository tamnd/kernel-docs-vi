.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/clearing-warn-once.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Xóa WARN_ONCE
------------------

WARN_ONCE/WARN_ON_ONCE/printk_once chỉ phát ra thông báo một lần.

echo 1 > /sys/kernel/debug/clear_warn_once

xóa trạng thái và cho phép các cảnh báo được in lại một lần nữa.
Điều này có thể hữu ích sau khi bộ thử nghiệm chạy để tái hiện các vấn đề.
