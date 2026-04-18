.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/nouveau.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
 Trình điều khiển drm/nouveau NVIDIA GPU
========================================

Trình điều khiển drm/nouveau cung cấp hỗ trợ cho nhiều loại GPU NVIDIA,
bao gồm các dòng GeForce, Quadro và Tesla, từ kiến trúc NV04 trở lên
đến các dòng Turing, Ampere, Ada mới nhất.

NVKM: Trình quản lý hạt nhân NVIDIA
===========================

Thành phần NVKM đóng vai trò là lớp trừu tượng cốt lõi trong tân tiến
trình điều khiển, chịu trách nhiệm quản lý phần cứng NVIDIA GPU ở cấp kernel.
NVKM cung cấp giao diện thống nhất để xử lý các kiến ​​trúc GPU khác nhau.

Nó cho phép quản lý tài nguyên, kiểm soát nguồn, xử lý bộ nhớ và ra lệnh
yêu cầu gửi để hoạt động bình thường của GPU NVIDIA theo
người lái xe tân tiến.

NVKM đóng một vai trò quan trọng trong việc trừu tượng hóa sự phức tạp của phần cứng và
cung cấp API nhất quán cho các lớp trên của ngăn xếp trình điều khiển.

Hỗ trợ GSP
------------------------

.. kernel-doc:: drivers/gpu/drm/nouveau/nvkm/subdev/gsp/rm/r535/rpc.c
   :doc: GSP message queue element

.. kernel-doc:: drivers/gpu/drm/nouveau/include/nvkm/subdev/gsp.h
   :doc: GSP message handling policy