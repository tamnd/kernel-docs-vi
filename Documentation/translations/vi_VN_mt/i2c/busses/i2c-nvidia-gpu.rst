.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-nvidia-gpu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Trình điều khiển hạt nhân i2c-nvidia-gpu
========================================

Bảng dữ liệu: không có sẵn công khai.

tác giả:
	Ajay Gupta <ajayg@nvidia.com>

Sự miêu tả
-----------

i2c-nvidia-gpu là trình điều khiển cho bộ điều khiển I2C có trong NVIDIA Turing
và các GPU mới hơn và nó được sử dụng để giao tiếp với bộ điều khiển Type-C trên GPU.

Nếu danh sách ZZ0000ZZ của bạn hiển thị nội dung như sau::

01:00.3 Bộ điều khiển bus nối tiếp [0c80]: NVIDIA Corporation Device 1ad9 (rev a1)

thì trình điều khiển này sẽ hỗ trợ bộ điều khiển I2C của GPU của bạn.
