.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/ras.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
 Hỗ trợ AMDGPU RAS
====================

Các giao diện AMDGPU RAS được hiển thị thông qua sysfs (đối với các truy vấn thông tin) và
debugfs (để chèn lỗi).

Giao diện điều khiển và chèn lỗi RAS debugfs/sysfs
========================================================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_ras.c
   :doc: AMDGPU RAS debugfs control interface

Hành vi khởi động lại RAS đối với các lỗi không thể phục hồi
============================================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_ras.c
   :doc: AMDGPU RAS Reboot Behavior for Unrecoverable Errors

Giao diện đếm lỗi sysfs RAS
===============================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_ras.c
   :doc: AMDGPU RAS sysfs Error Count Interface

Giao diện gỡ lỗi RAS EEPROM
============================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_ras.c
   :doc: AMDGPU RAS debugfs EEPROM table reset interface

RAS VRAM Giao diện hệ thống trang xấu
==================================

.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_ras.c
   :doc: AMDGPU RAS sysfs gpu_vram_bad_pages Interface

Mã mẫu
===========
Mã mẫu để kiểm tra lỗi chèn có thể được tìm thấy ở đây:
ZZ0000ZZ

Đây là một phần của bài kiểm tra đơn vị libdrm amdgpu bao gồm một số lĩnh vực của GPU.
Có bốn bộ bài kiểm tra:

Kiểm tra cơ bản RAS

Quá trình kiểm tra sẽ xác minh trạng thái kích hoạt tính năng RAS và đảm bảo các tệp sysfs và debugfs cần thiết
đang có mặt.

Kiểm tra truy vấn RAS

Thử nghiệm này kiểm tra tính khả dụng và trạng thái hỗ trợ của RAS cho từng khối IP được hỗ trợ cũng như
lỗi được tính.

Kiểm tra tiêm RAS

Thử nghiệm này đưa ra lỗi cho từng IP.

Kiểm tra vô hiệu hóa RAS

Thử nghiệm này kiểm tra việc vô hiệu hóa các tính năng RAS cho từng khối IP.
