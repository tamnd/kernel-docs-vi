.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-amd756.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển hạt nhân i2c-amd756
========================

Bộ điều hợp được hỗ trợ:
  * AMD 756
  * AMD 766
  * AMD 768
  * AMD 8111

Bảng dữ liệu: Có sẵn công khai trên trang web AMD

* nVidia nForce

Bảng dữ liệu: Không có sẵn

tác giả:
	- Frodo Looijaard <frodol@dds.nl>,
	- Philip Edelbrock <phil@netroedge.com>

Sự miêu tả
-----------

Trình điều khiển này hỗ trợ Bus ngoại vi AMD 756, 766, 768 và 8111
Bộ điều khiển và nVidia nForce.

Lưu ý rằng đối với 8111, có hai bộ điều hợp SMBus. Bộ chuyển đổi SMBus 1.0
được hỗ trợ bởi trình điều khiển này và bộ điều hợp SMBus 2.0 được hỗ trợ bởi
trình điều khiển i2c-amd8111.
