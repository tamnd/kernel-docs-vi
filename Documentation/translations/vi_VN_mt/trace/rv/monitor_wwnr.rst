.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_wwnr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Màn hình wwnr
============

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
-------------
Tệp Grapviz Dot trong tools/verification/models/wwnr.dot
