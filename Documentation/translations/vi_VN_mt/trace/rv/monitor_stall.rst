.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_stall.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Màn hình gian hàng
==================

- Tên: gian hàng - giám sát tác vụ bị đình trệ
- Loại: máy tự động lai theo nhiệm vụ
- Tác giả: Gabriele Monaco <gmonaco@redhat.com>

Sự miêu tả
-----------

Trình giám sát tác vụ bị đình trệ (stall) là một trình giám sát thời gian mẫu cho mỗi tác vụ để kiểm tra
nếu các tác vụ được lên lịch trong một ngưỡng xác định sau khi chúng sẵn sàng::

|
                        |
                        v
                      #=============================#
  +-----------------> H bị loại khỏi hàng đợi H
  |                   #===============================#
  ZZ0008ZZ
 lịch_switch_wait | lịch_wakeup;đặt lại(clk)
  |                     v
  |                   +--------------------------+ <+
  ZZ0001ZZ đã được xếp vào hàng đợi ZZ0002ZZ sched_wakeup
  ZZ0003ZZ clk < ngưỡng_jiffies | -+
  |                   +--------------------------+
  ZZ0004ZZ ^
  |              sched_switch_in sched_switch_preempt;đặt lại(clk)
  ZZ0005ZZ
  |                   +--------------------------+
  +---- ZZ0006ZZ
                      +--------------------------+
                        ^ lịch_switch_in |
                        ZZ0007ZZ
                        +----------------------+

Ngưỡng có thể được cấu hình như một tham số bằng cách khởi động bằng
Đối số ZZ0000ZZ hoặc ghi một giá trị mới vào
ZZ0001ZZ.

Đặc điểm kỹ thuật
-----------------
Tệp Graphviz Dot trong tools/verification/models/stall.dot
