.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/lsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright (C) 2022 Casey Schaufler <casey@schaufler-ca.com>
.. Copyright (C) 2022 Intel Corporation

========================================
Mô-đun bảo mật Linux
=====================================

:Tác giả: Casey Schaufler
:Ngày: Tháng 7 năm 2023

Các mô-đun bảo mật Linux (LSM) cung cấp cơ chế để thực hiện
kiểm soát truy cập bổ sung vào các chính sách bảo mật của Linux.

Các mô-đun bảo mật khác nhau có thể hỗ trợ bất kỳ thuộc tính nào sau đây:

ZZ0000ZZ là bối cảnh bảo mật tích cực hiện tại của
quá trình.
Hệ thống tập tin Proc cung cấp giá trị này trong ZZ0001ZZ.
Điều này được hỗ trợ bởi các mô-đun bảo mật SELinux, Smack và AppArmor.
Smack cũng cung cấp giá trị này trong ZZ0002ZZ.
AppArmor cũng cung cấp giá trị này trong ZZ0003ZZ.

ZZ0000ZZ là bối cảnh bảo mật của quy trình tại thời điểm
hình ảnh hiện tại đã được thực thi.
Hệ thống tập tin Proc cung cấp giá trị này trong ZZ0001ZZ.
Điều này được hỗ trợ bởi các mô-đun bảo mật SELinux và AppArmor.
AppArmor cũng cung cấp giá trị này trong ZZ0002ZZ.

ZZ0000ZZ là bối cảnh bảo mật của quy trình được sử dụng khi
tạo các đối tượng hệ thống tập tin.
Hệ thống tập tin Proc cung cấp giá trị này trong ZZ0001ZZ.
Điều này được hỗ trợ bởi mô-đun bảo mật SELinux.

ZZ0000ZZ là bối cảnh bảo mật của quy trình được sử dụng khi
tạo ra các đối tượng chính.
Hệ thống tập tin Proc cung cấp giá trị này trong ZZ0001ZZ.
Điều này được hỗ trợ bởi mô-đun bảo mật SELinux.

ZZ0000ZZ là bối cảnh bảo mật của quy trình tại thời điểm
bối cảnh bảo mật hiện tại đã được thiết lập.
Hệ thống tập tin Proc cung cấp giá trị này trong ZZ0001ZZ.
Điều này được hỗ trợ bởi các mô-đun bảo mật SELinux và AppArmor.
AppArmor cũng cung cấp giá trị này trong ZZ0002ZZ.

ZZ0000ZZ là bối cảnh bảo mật của quy trình được sử dụng khi
tạo các đối tượng socket.
Hệ thống tập tin Proc cung cấp giá trị này trong ZZ0001ZZ.
Điều này được hỗ trợ bởi mô-đun bảo mật SELinux.

Giao diện hạt nhân
================

Đặt thuộc tính bảo mật của quy trình hiện tại
-----------------------------------------------

.. kernel-doc:: security/lsm_syscalls.c
    :identifiers: sys_lsm_set_self_attr

Nhận các thuộc tính bảo mật được chỉ định của quy trình hiện tại
------------------------------------------------------------

.. kernel-doc:: security/lsm_syscalls.c
    :identifiers: sys_lsm_get_self_attr

.. kernel-doc:: security/lsm_syscalls.c
    :identifiers: sys_lsm_list_modules

Tài liệu bổ sung
========================

* Tài liệu/bảo mật/lsm.rst
* Tài liệu/bảo mật/lsm-development.rst