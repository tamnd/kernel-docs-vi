.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_wwnr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Màn hình wwnr
=============

- Tên: wwrn - thức dậy khi không chạy
- Loại: máy tự động xác định theo nhiệm vụ
- Tác giả: Daniel Bristot de Oliveira <bristot@kernel.org>

Sự miêu tả
-----------

Đây là màn hình mẫu theo từng nhiệm vụ, với các thông tin sau
định nghĩa::

|
               |
               v
    thức dậy +-------------+
  +-------- ZZ0000ZZ
  ZZ0001ZZ không chạy |
  +--------> ZZ0002ZZ <+
             +-------------+ |
               ZZ0003ZZ
               Chuyển đổi ZZ0004ZZ_out
               v |
             +-------------+ |
             ZZ0005ZZ-+
             +-------------+

Mô hình này bị hỏng, lý do là một tác vụ có thể đang chạy
trong bộ xử lý mà không được đặt là RUNNABLE. Hãy nghĩ về một
nhiệm vụ sắp đi ngủ::

1: set_current_state(TASK_UNINTERRUPTIBLE);
  2: lịch();

Và sau đó hãy tưởng tượng một chiếc IRQ xảy ra ở giữa dòng một và dòng hai,
đánh thức nhiệm vụ. BOOM, việc đánh thức sẽ diễn ra trong khi nhiệm vụ được thực hiện
đang chạy.

- Tại sao chúng ta cần mô hình này?
- Để kiểm tra lò phản ứng.

Đặc điểm kỹ thuật
-----------------
Tệp Grapviz Dot trong tools/verification/models/wwnr.dot
