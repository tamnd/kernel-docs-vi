.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/secrets/coco.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Bí mật bí mật máy tính
=================================

Tài liệu này mô tả cách xử lý việc đưa bí mật Máy tính Bí mật vào
từ phần sụn đến hệ điều hành, trong trình điều khiển EFI và efi_secret
mô-đun hạt nhân.


Giới thiệu
============

Phần cứng máy tính bí mật (coco) như AMD SEV (Mã hóa an toàn
Ảo hóa) cho phép chủ sở hữu khách đưa bí mật vào máy ảo
bộ nhớ mà máy chủ/hypervisor không thể đọc được chúng.  Trong SEV,
việc tiêm bí mật được thực hiện sớm trong quá trình khởi chạy VM, trước khi
khách bắt đầu chạy.

Mô-đun hạt nhân efi_secret cho phép các ứng dụng không gian người dùng truy cập vào các mô-đun này
bí mật thông qua securityfs.


Luồng dữ liệu bí mật
================

Phần sụn khách có thể dành một vùng bộ nhớ được chỉ định để tiêm bí mật,
và công bố vị trí của nó (cơ sở GPA và chiều dài) trong bảng cấu hình EFI
dưới mục ZZ0000ZZ
(ZZ0001ZZ).  Vùng nhớ này cần được đánh dấu
bởi phần sụn là ZZ0002ZZ, và do đó hạt nhân không nên
được sử dụng nó cho mục đích riêng của nó.

Trong quá trình khởi chạy VM, người quản lý máy ảo có thể đưa một bí mật vào đó
khu vực.  Trong AMD SEV và SEV-ES, việc này được thực hiện bằng cách sử dụng
Lệnh ZZ0000ZZ (xem [sev]_).  Cấu trúc của chất tiêm
Dữ liệu bí mật của Chủ sở hữu khách phải là bảng HƯỚNG DẪN chứa các giá trị bí mật; hệ nhị phân
định dạng được mô tả trong ZZ0001ZZ bên dưới
“Cấu trúc của khu vực bí mật EFI”.

Khi khởi động kernel, trình điều khiển EFI của kernel sẽ lưu vị trí của vùng bí mật
(lấy từ bảng cấu hình EFI) trong trường ZZ0000ZZ.
Sau đó, nó kiểm tra xem khu vực bí mật có được điền hay không: nó ánh xạ khu vực đó và kiểm tra
liệu nội dung của nó có bắt đầu bằng ZZ0001ZZ hay không
(ZZ0002ZZ).  Nếu khu vực bí mật có người ở,
trình điều khiển EFI sẽ tự động tải mô-đun hạt nhân efi_secret, hiển thị
bí mật đối với các ứng dụng không gian người dùng thông qua securityfs.  Các chi tiết của
Giao diện hệ thống tập tin efi_secret nằm trong [secrets-coco-abi]_.


Ví dụ sử dụng ứng dụng
=========================

Hãy xem xét một khách thực hiện tính toán trên các tập tin được mã hóa.  Chủ khách
cung cấp khóa giải mã (= bí mật) bằng cơ chế đưa bí mật.
Ứng dụng khách đọc bí mật từ hệ thống tệp efi_secret và
tiến hành giải mã các tập tin vào bộ nhớ và sau đó thực hiện các thao tác cần thiết
tính toán theo nội dung.

Trong ví dụ này, máy chủ không thể đọc tệp từ ảnh đĩa
vì chúng đã được mã hóa.  Máy chủ không thể đọc khóa giải mã vì
nó được truyền bằng cơ chế tiêm bí mật (= kênh bảo mật).
Máy chủ không thể đọc nội dung được giải mã từ bộ nhớ vì đó là
khách bí mật (được mã hóa bộ nhớ).

Đây là một ví dụ đơn giản về cách sử dụng mô-đun efi_secret trong máy khách
trong đó một khu vực bí mật EFI với 4 bí mật đã được đưa vào trong quá trình khởi chạy::

# ls -la /sys/kernel/security/secrets/coco
	tổng 0
	drwxr-xr-x 2 gốc gốc 0 28 tháng 6 11:54 .
	drwxr-xr-x 3 gốc gốc 0 28 tháng 6 11:54 ..
	-r--r------ 1 gốc gốc 0 28 tháng 6 11:54 736870e5-84f0-4973-92ec-06879ce3da0b
	-r--r------ 1 gốc gốc 0 28 tháng 6 11:54 83c83f7f-1356-4975-8b7e-d3a0b54312c6
	-r--r------ 1 gốc gốc 0 28/06 11:54 9553f55d-3da2-43ee-ab5d-ff17f78864d2
	-r--r------ 1 gốc gốc 0 28 tháng 6 11:54 e6f5a162-d67f-4750-a67c-5d065f2a9910

# hd/sys/kernel/security/secrets/coco/e6f5a162-d67f-4750-a67c-5d065f2a9910
	00000000 74 68 65 73 65 2d 61 72 65 2d 74 68 65 2d 6b 61 ZZ0000ZZ
	00000010 74 61 2d 73 65 63 72 65 74 73 00 01 02 03 04 05 ZZ0001ZZ
	00000020 06 07 ZZ0002ZZ
	00000022

# rm/sys/kernel/security/secrets/coco/e6f5a162-d67f-4750-a67c-5d065f2a9910

# ls -la /sys/kernel/security/secrets/coco
	tổng 0
	drwxr-xr-x 2 gốc gốc 0 28 tháng 6 11:55 .
	drwxr-xr-x 3 gốc gốc 0 28 tháng 6 11:54 ..
	-r--r------ 1 gốc gốc 0 28 tháng 6 11:54 736870e5-84f0-4973-92ec-06879ce3da0b
	-r--r------ 1 gốc gốc 0 28 tháng 6 11:54 83c83f7f-1356-4975-8b7e-d3a0b54312c6
	-r--r------ 1 gốc gốc 0 28/06 11:54 9553f55d-3da2-43ee-ab5d-ff17f78864d2


Tài liệu tham khảo
==========

Xem [sev-api-spec]_ để biết thêm thông tin về hoạt động của SEV ZZ0000ZZ.

.. [sev] Documentation/virt/kvm/x86/amd-memory-encryption.rst
.. [secrets-coco-abi] Documentation/ABI/testing/securityfs-secrets-coco
.. [sev-api-spec] https://www.amd.com/system/files/TechDocs/55766_SEV-KM_API_Specification.pdf