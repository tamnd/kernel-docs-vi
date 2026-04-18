.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ebpf/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Không gian người dùng eBPF API
==================

eBPF là một cơ chế hạt nhân để cung cấp môi trường thời gian chạy hộp cát trong
Nhân Linux để mở rộng thời gian chạy và thiết bị đo đạc mà không cần thay đổi nhân
mã nguồn hoặc tải các mô-đun hạt nhân. Các chương trình eBPF có thể được gắn vào nhiều
các hệ thống con hạt nhân, bao gồm các mô-đun mạng, truy tìm và bảo mật Linux
(LSM).

Để biết tài liệu hạt nhân nội bộ về eBPF, hãy xem Documentation/bpf/index.rst.

.. toctree::
   :maxdepth: 1

   syscall