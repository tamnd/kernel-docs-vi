.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ebpf/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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