.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/arm/vcpu-features.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================
Lựa chọn tính năng vCPU trên arm64
===============================

KVM/arm64 cung cấp hai cơ chế cho phép không gian người dùng định cấu hình
các tính năng CPU được giới thiệu cho khách.

KVM_ARM_VCPU_INIT
=================

ZZ0001ZZ ioctl chấp nhận một bitmap các cờ tính năng
(ZZ0002ZZ). Các tính năng được kích hoạt bởi giao diện này là
ZZ0003ZZ và có thể thay đổi/mở rộng UAPI. Xem ZZ0000ZZ để biết đầy đủ
tài liệu về các tính năng được kiểm soát bởi ioctl.

Mặt khác, tất cả các tính năng CPU được KVM hỗ trợ đều được mô tả bởi kiến trúc
sổ đăng ký ID.

Sổ đăng ký ID
================

Kiến trúc Arm chỉ định một phạm vi ZZ0000ZZ mô tả tập hợp
các tính năng kiến trúc được hỗ trợ bởi việc triển khai CPU. KVM khởi tạo
ID của khách đăng ký bộ tính năng CPU tối đa được hỗ trợ bởi
hệ thống. Các giá trị thanh ghi ID có thể nằm trong phạm vi VM trong KVM, nghĩa là
các giá trị có thể được chia sẻ cho tất cả các vCPU trong VM.

KVM cho phép không gian người dùng ZZ0004ZZ có một số tính năng CPU nhất định được ID mô tả
đăng ký bằng cách ghi giá trị cho chúng thông qua ZZ0001ZZ ioctl. ID
các thanh ghi có thể thay đổi cho đến khi VM khởi động, tức là không gian người dùng đã gọi
ZZ0002ZZ trên ít nhất một vCPU trong VM. Không gian người dùng có thể khám phá những trường nào
có thể thay đổi trong thanh ghi ID bằng ZZ0003ZZ.
Xem ZZ0000ZZ để biết thêm
chi tiết.

Không gian người dùng được phép sử dụng các tính năng ZZ0000ZZ hoặc ZZ0001ZZ CPU theo quy định
được phác thảo bởi kiến trúc trong DDI0487J.a D19.1.3 'Các nguyên tắc của ID
lược đồ cho các trường trong sổ đăng ký ID'. KVM không cho phép các giá trị thanh ghi ID
vượt quá khả năng của hệ thống.

.. warning::
   It is **strongly recommended** that userspace modify the ID register values
   before accessing the rest of the vCPU's CPU register state. KVM may use the
   ID register values to control feature emulation. Interleaving ID register
   modification with other system register accesses may lead to unpredictable
   behavior.