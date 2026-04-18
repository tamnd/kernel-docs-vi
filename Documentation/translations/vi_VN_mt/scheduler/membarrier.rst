.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/membarrier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
membarrier() Cuộc gọi hệ thống
==============================

MEMBARRIER_CMD_{PRIVATE,GLOBAL}_EXPEDITED - Yêu cầu về kiến ​​trúc
=====================================================================

Rào cản bộ nhớ trước khi cập nhật rq->curr
------------------------------------------

Các lệnh MEMBARRIER_CMD_PRIVATE_EXPEDITED và MEMBARRIER_CMD_GLOBAL_EXPEDITED
yêu cầu mỗi kiến trúc phải có hàng rào bộ nhớ đầy đủ sau khi đến từ
không gian người dùng, trước khi cập nhật rq->curr.  Rào cản này được ngụ ý bởi trình tự
rq_lock(); smp_mb__after_spinlock() trong __schedule().  Rào chắn phù hợp với đầy đủ
rào cản ở gần lối ra cuộc gọi hệ thống màng chắn, cf.
membarrier_{private,global__expedited().

Rào cản bộ nhớ sau khi cập nhật rq->curr
----------------------------------------

Các lệnh MEMBARRIER_CMD_PRIVATE_EXPEDITED và MEMBARRIER_CMD_GLOBAL_EXPEDITED
yêu cầu mỗi kiến trúc phải có hàng rào bộ nhớ đầy đủ sau khi cập nhật rq->curr,
trước khi quay trở lại không gian người dùng.  Các kế hoạch cung cấp rào cản này trên nhiều lĩnh vực khác nhau
kiến trúc như sau.

- alpha, arc, arm, hex, mips dựa vào rào cản đầy đủ ngụ ý bởi
   spin_unlock() trong finish_lock_switch().

- arm64 dựa vào rào cản đầy đủ được ngụ ý bởi switch_to().

- powerpc, riscv, s390, sparc, x86 dựa vào rào cản đầy đủ được ngụ ý bởi
   switch_mm(), nếu mm không phải là NULL; họ dựa vào rào cản đầy đủ ngụ ý
   bởi mmdrop(), nếu không thì.  Trên powerpc và riscv, switch_mm() dựa vào
   membarrier_arch_switch_mm().

Rào chắn khớp với một rào cản đầy đủ ở gần lệnh gọi hệ thống màng chắn
mục nhập, xem. membarrier_{private,global__expedited().