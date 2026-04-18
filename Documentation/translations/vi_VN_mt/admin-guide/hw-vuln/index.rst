.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/hw-vuln/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Hardware vulnerabilities
========================

This section describes CPU vulnerabilities and provides an overview of the
possible mitigations along with guidance for selecting mitigations if they
are configurable at compile, boot or run time.

.. toctree::
   :maxdepth: 1

   attack_vector_controls
   spectre
   l1tf
   mds
   tsx_async_abort
   multihit
   special-register-buffer-data-sampling
   core-scheduling
   l1d_flush
   processor_mmio_stale_data
   cross-thread-rsb
   srso
   gather_data_sampling
   reg-file-data-sampling
   rsb
   old_microcode
   indirect-target-selection
   vmscape
