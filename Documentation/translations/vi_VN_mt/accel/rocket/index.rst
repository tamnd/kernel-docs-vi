.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/accel/rocket/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
 Trình điều khiển tăng tốc/tên lửa Rockchip NPU
===============================================

Trình điều khiển accel/rocket hỗ trợ Bộ xử lý thần kinh (NPU) bên trong một số
Rockchip SoC như RK3588. Rockchip gọi nó là RKNN và đôi khi là RKNPU.

Phần cứng được mô tả trong chương 36 trong RK3588 TRM.

Trình điều khiển này chỉ bật và tắt phần cứng, phân bổ và ánh xạ bộ đệm tới
thiết bị và gửi công việc đến đơn vị giao diện người dùng. Mọi thứ khác được thực hiện trong
không gian người dùng, với tư cách là trình điều khiển Gallium (còn gọi là tên lửa) là một phần của Mesa3D
dự án.

Phần cứng hiện được hỗ trợ:

* RK3588