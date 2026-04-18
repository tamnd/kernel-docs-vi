.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/clearing-warn-once.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Xóa WARN_ONCE
------------------

WARN_ONCE/WARN_ON_ONCE/printk_once chỉ phát ra thông báo một lần.

echo 1 > /sys/kernel/debug/clear_warn_once

xóa trạng thái và cho phép các cảnh báo được in lại một lần nữa.
Điều này có thể hữu ích sau khi bộ thử nghiệm chạy để tái hiện các vấn đề.
