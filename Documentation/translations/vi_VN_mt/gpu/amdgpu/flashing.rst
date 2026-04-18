.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/flashing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
 Phần mềm dGPU đang nhấp nháy
=======================

IFWI
----
Việc nhấp nháy hình ảnh chương trình cơ sở tích hợp dGPU (IFWI) được hỗ trợ bởi các GPU
sử dụng PSP để sắp xếp bản cập nhật (Navi3x hoặc GPU mới hơn).
Đối với các GPU được hỗ trợ, ZZ0000ZZ sẽ xuất một loạt tệp sysfs có thể được
được sử dụng cho quá trình flash.

Quá trình flash IFWI là:

1. Đảm bảo hình ảnh IFWI dành cho dGPU trên hệ thống.
2. "Ghi" hình ảnh IFWI vào tệp sysfs ZZ0000ZZ. Điều này sẽ đưa IFWI vào bộ nhớ.
3. "Đọc" từ tệp sysfs ZZ0001ZZ để bắt đầu quá trình flash.
4. Thăm dò tệp sysfs ZZ0002ZZ để xác định khi nào quá trình flash hoàn tất.

USB-C PD F/W
------------
Trên các GPU hỗ trợ flash hình ảnh chương trình cơ sở USB-C PD đã cập nhật, quy trình
được thực hiện bằng cách sử dụng tệp sysfs ZZ0000ZZ.

* Đọc tệp sẽ cung cấp phiên bản chương trình cơ sở hiện tại.
* Việc ghi tên của phần tải chương trình cơ sở được lưu trữ trong ZZ0000ZZ vào tệp sysfs sẽ bắt đầu quá trình flash.

Tải trọng phần sụn được lưu trữ trong ZZ0000ZZ có thể được đặt tên bất kỳ tên nào
miễn là nó không xung đột với các tệp nhị phân hiện có khác được sử dụng bởi
ZZ0001ZZ.

tập tin sysfs
-----------
.. kernel-doc:: drivers/gpu/drm/amd/amdgpu/amdgpu_psp.c
