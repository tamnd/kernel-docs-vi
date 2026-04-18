.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/hw-vuln/old_microcode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Old Microcode
=============

The kernel keeps a table of released microcode. Systems that had
microcode older than this at boot will say "Vulnerable".  This means
that the system was vulnerable to some known CPU issue. It could be
security or functional, the kernel does not know or care.

You should update the CPU microcode to mitigate any exposure. This is
usually accomplished by updating the files in
/lib/firmware/intel-ucode/ via normal distribution updates. Intel also
distributes these files in a github repo:

	https://github.com/intel/Intel-Linux-Processor-Microcode-Data-Files.git

Just like all the other hardware vulnerabilities, exposure is
determined at boot. Runtime microcode updates do not change the status
of this vulnerability.