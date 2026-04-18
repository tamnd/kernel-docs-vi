.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/loongarch/hypercalls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Giao diện ảo LoongArch
===================================

Siêu cuộc gọi KVM sử dụng lệnh HVCL với mã 0x100 và siêu cuộc gọi
số được đặt trong a0. Có thể đặt tối đa năm đối số trong các thanh ghi a1 - a5.
Giá trị trả về được đặt trong v0 (bí danh là a0).

Mã nguồn cho giao diện này có thể được tìm thấy trong Arch/loongarch/kvm*.

Truy vấn sự tồn tại
======================

Để xác định xem máy chủ có chạy trên KVM hay không, chúng ta có thể sử dụng cpucfg()
chức năng ở chỉ số CPUCFG_KVM_BASE (0x40000000).

Phạm vi CPUCFG_KVM_BASE, trải dài từ 0x40000000 đến 0x400000FF, The
Phạm vi CPUCFG_KVM_BASE trong khoảng 0x40000000 - 0x400000FF được đánh dấu là dành riêng.
Do đó, tất cả các bộ xử lý hiện tại và tương lai sẽ không thực hiện bất kỳ
tính năng trong phạm vi này.

Trên hệ thống Linux ảo hóa KVM, thao tác đọc trên cpucfg() tại chỉ mục
CPUCFG_KVM_BASE (0x40000000) trả về chuỗi ma thuật 'KVM\0'.

Khi bạn đã xác định rằng máy chủ của bạn đang chạy trên cơ chế ảo hóa song song-
có khả năng KVM, giờ đây bạn có thể sử dụng siêu lệnh gọi như mô tả bên dưới.

KVM siêu cuộc gọi ABI
=================

KVM hypercall ABI rất đơn giản, với một thanh ghi đầu a0 (v0) và nhiều nhất là
năm thanh ghi chung (a1 - a5) được sử dụng làm tham số đầu vào. FP (Nổi-
thanh ghi điểm) và vectơ không được sử dụng làm thanh ghi đầu vào và phải
vẫn không được sửa đổi trong một siêu cuộc gọi.

Các hàm Hypercall có thể được nội tuyến vì nó chỉ sử dụng một thanh ghi đầu.

Các thông số như sau:

======== ====================================
	Đăng ký TẠI OUT
	======== ====================================
	số chức năng a0 Mã trả về
	tham số thứ nhất a1 -
	a2 tham số thứ 2 -
	a3 tham số thứ 3 -
	a4 tham số thứ 4 -
	tham số thứ 5 của a5 -
	======== ====================================

Mã trả lại có thể là một trong những mã sau:

==== ============================
	Ý nghĩa mã
	==== ============================
	0 Thành công
	-1 Hypercall không được triển khai
	-2 Tham số Hypercall không hợp lệ
	==== ============================

Tài liệu về siêu cuộc gọi KVM
============================

Mẫu cho mỗi hypercall như sau:

1. Tên siêu cuộc gọi
2. Mục đích

1. KVM_HCALL_FUNC_IPI
------------------------

:Mục đích: Gửi IPI tới nhiều vCPU.

- a0: KVM_HCALL_FUNC_IPI
- a1: Phần dưới của bitmap dành cho CPUID vật lý đích
- a2: Phần cao hơn của bitmap dành cho CPUID vật lý đích
- a3: CPUID vật lý thấp nhất trong bitmap

Hypercall cho phép khách gửi nhiều IPI (Ngắt giữa các quá trình) với
tối đa 128 điểm đến cho mỗi siêu cuộc gọi. Các điểm đến được thể hiện dưới dạng
bitmap chứa trong hai thanh ghi đầu vào đầu tiên (a1 và a2).

Bit 0 của a1 tương ứng với CPUID vật lý trong thanh ghi đầu vào thứ ba (a3)
và bit 1 tương ứng với CPUID vật lý trong a3+1, v.v.

PV IPI trên LoongArch bao gồm cả gửi phát đa hướng PV IPI và nhận PV IPI,
và SWI được sử dụng cho PV IPI tiêm vì không có lối thoát VM nào truy cập vào các thanh ghi SWI.