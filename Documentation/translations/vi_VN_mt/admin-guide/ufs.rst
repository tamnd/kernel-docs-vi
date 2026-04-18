.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/ufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========
Using UFS
=========

mount -t ufs -o ufstype=type_of_ufs device dir


UFS Options
===========

ufstype=type_of_ufs
	UFS is a file system widely used in different operating systems.
	The problem are differences among implementations. Features of
	some implementations are undocumented, so its hard to recognize
	type of ufs automatically. That's why user must specify type of
	ufs manually by mount option ufstype. Possible values are:

	old
                old format of ufs
		default value, supported as read-only

	44bsd
                used in FreeBSD, NetBSD, OpenBSD
		supported as read-write

	ufs2
                used in FreeBSD 5.x
		supported as read-write

	5xbsd
                synonym for ufs2

	sun
                used in SunOS (Solaris)
		supported as read-write

	sunx86
                used in SunOS for Intel (Solarisx86)
		supported as read-write

	hp
                used in HP-UX
		supported as read-only

	nextstep
		used in NextStep
		supported as read-only

	nextstep-cd
		used for NextStep CDROMs (block_size == 2048)
		supported as read-only

	openstep
		used in OpenStep
		supported as read-only


Possible Problems
-----------------

See next section, if you have any.


Bug Reports
-----------

Any ufs bug report you can send to daniel.pirkl@email.cz or
to dushistov@mail.ru (do not send partition tables bug reports).
