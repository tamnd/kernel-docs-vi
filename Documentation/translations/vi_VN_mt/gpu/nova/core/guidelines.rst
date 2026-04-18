.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/core/guidelines.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Hướng dẫn
==========

Tài liệu này chứa các hướng dẫn dành cho nova-core. Ngoài ra, tất cả thông thường
hướng dẫn của dự án Nova được áp dụng.

Trình điều khiển API
==========

Một mục đích chính của nova-core là triển khai tính trừu tượng xung quanh
giao diện phần sụn của GSP và cung cấp phần sụn (phiên bản) API độc lập cho
Trình điều khiển cấp 2, chẳng hạn như trình điều khiển nova-drm hoặc trình quản lý vGPU VFIO.

Do đó, không được phép rò rỉ thông tin chi tiết về phần sụn (phiên bản) thông qua
trình điều khiển API, đến trình điều khiển cấp 2.

Tiêu chí chấp nhận
===================

- Trong phạm vi có thể, các bản vá được gửi tới nova-core phải được kiểm tra
  hồi quy với tất cả các trình điều khiển cấp 2.