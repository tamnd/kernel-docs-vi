.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_wip.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Lau màn hình
============

- Tên: wip - đánh thức trong ưu tiên
- Loại: máy tự động xác định trên mỗi CPU
- Tác giả: Daniel Bristot de Oliveira <bristot@kernel.org>

Sự miêu tả
-----------

Màn hình đánh thức trong màn hình ưu tiên (wip) là màn hình mẫu trên mỗi CPU
xác minh xem các sự kiện đánh thức có luôn diễn ra với
quyền ưu tiên bị vô hiệu hóa::

|
                     |
                     v
                   #====================#
                   H ưu tiên H <+
                   #====================# |
                     ZZ0000ZZ
                     ZZ0001ZZ ưu tiên_enable
                     v |
    lịch_waking +-------------------+ |
  +-------------- ZZ0002ZZ |
  ZZ0003ZZ không ưu tiên ZZ0004ZZ
  +--------------> ZZ0005ZZ -+
                   +-------------------+

Sự kiện đánh thức luôn diễn ra với quyền ưu tiên bị vô hiệu hóa vì
của việc đồng bộ hóa bộ lập lịch. Tuy nhiên, vì preempt_count
và sự kiện dấu vết của nó không phải là nguyên tử đối với các ngắt, một số
những mâu thuẫn có thể xảy ra. Ví dụ::

ưu tiên_disable() {
	__preempt_count_add(1)
	-------> smp_apic_timer_interrupt() {
				ưu tiên_disable()
					không theo dõi (số lượng ưu tiên >= 1)

đánh thức một chủ đề

preempt_enable()
					 không theo dõi (số lượng ưu tiên >= 1)
			}
	<------
	trace_preempt_disable();
  }

Vấn đề này đã được báo cáo và thảo luận ở đây:
  ZZ0000ZZ

Đặc điểm kỹ thuật
-----------------
Tệp Grapviz Dot trong tools/verification/models/wip.dot
