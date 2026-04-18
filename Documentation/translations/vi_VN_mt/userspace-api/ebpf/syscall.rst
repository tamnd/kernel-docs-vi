.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/ebpf/syscall.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hệ thống eBPF
------------

:Tác giả: - Alexei Starovoytov <ast@kernel.org>
          - Joe Stringer <joe@wand.net.nz>
          - Michael Kerrisk <mtk.manpages@gmail.com>

Thông tin chính cho tòa nhà cao tầng bpf có sẵn trong ZZ0000ZZ
cho ZZ0001ZZ.

tham chiếu lệnh phụ bpf()
~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/uapi/linux/bpf.h
   :doc: eBPF Syscall Preamble

.. kernel-doc:: include/uapi/linux/bpf.h
   :doc: eBPF Syscall Commands

.. Links:
.. _man-pages: https://www.kernel.org/doc/man-pages/
.. _bpf(2): https://man7.org/linux/man-pages/man2/bpf.2.html