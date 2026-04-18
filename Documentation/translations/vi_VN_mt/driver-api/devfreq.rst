.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/devfreq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Chia tần số thiết bị
========================

Giới thiệu
------------

Khung này cung cấp giao diện hạt nhân tiêu chuẩn cho Điện áp động và
Chuyển đổi tần số trên các thiết bị tùy ý.

Nó hiển thị các điều khiển để điều chỉnh tần số thông qua các tệp sysfs
tương tự như hệ thống con cpufreq.

Các thiết bị có thể đo được mức sử dụng hiện tại có thể có tần số
được điều chỉnh tự động bởi các thống đốc.

API
---

Trình điều khiển thiết bị cần khởi tạo ZZ0000ZZ và gọi
Hàm ZZ0001ZZ để tạo phiên bản ZZ0002ZZ.

.. kernel-doc:: include/linux/devfreq.h
.. kernel-doc:: include/linux/devfreq-event.h
.. kernel-doc:: drivers/devfreq/devfreq.c
        :export:
.. kernel-doc:: drivers/devfreq/devfreq-event.c
        :export: