.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-amd756.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

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
