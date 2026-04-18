.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/arm/hyp-abi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
ABI nội bộ giữa kernel và HYP
=======================================

Tệp này ghi lại sự tương tác giữa nhân Linux và
lớp ảo hóa khi chạy Linux với tư cách là một trình ảo hóa (ví dụ:
KVM). Nó không bao gồm sự tương tác của kernel với
hypervisor khi chạy với tư cách khách (dưới Xen, KVM hoặc bất kỳ loại nào khác
hypervisor) hoặc bất kỳ tương tác nào dành riêng cho hypervisor khi kernel
được sử dụng làm máy chủ.

Lưu ý: KVM/arm đã bị xóa khỏi kernel. API được mô tả
Tuy nhiên, đây vẫn hợp lệ vì nó cho phép kernel thực hiện kexec khi
đã khởi động tại HYP. Nó cũng có thể được sử dụng bởi một trình ảo hóa khác ngoài KVM
nếu cần thiết.

Trên arm và arm64 (không có VHE), kernel không chạy trong hypervisor
chế độ, nhưng vẫn cần phải tương tác với nó, cho phép tích hợp sẵn
hypervisor được cài đặt hoặc bị phá bỏ.

Để đạt được điều này, kernel phải được khởi động ở HYP (arm) hoặc
EL2 (arm64), cho phép nó cài đặt một bộ sơ khai trước khi thả xuống
SVC/EL1. Các sơ khai này có thể truy cập được bằng cách sử dụng lệnh 'hvc #0',
và chỉ hoạt động trên từng CPU riêng lẻ.

Trừ khi có quy định khác, mọi trình ảo hóa tích hợp đều phải triển khai
các hàm này (xem Arch/arm{,64}/include/asm/virt.h):

* ::

r0/x0 = HVC_SET_VECTORS
    r1/x1 = vectơ

Đặt HVBAR/VBAR_EL2 thành 'vectơ' để kích hoạt trình ảo hóa. 'vectơ'
  phải là một địa chỉ vật lý và tôn trọng các yêu cầu căn chỉnh
  của kiến trúc. Chỉ được thực hiện bởi các sơ khai ban đầu, không phải bởi
  Trình ảo hóa Linux.

* ::

r0/x0 = HVC_RESET_VECTORS

Tắt HYP/EL2 MMU và đặt lại HVBAR/VBAR_EL2 về tên viết tắt
  giá trị vectơ ngoại lệ của sơ khai. Điều này vô hiệu hóa một cách hiệu quả một
  siêu giám sát.

* ::

r0/x0 = HVC_SOFT_RESTART
    r1/x1 = địa chỉ khởi động lại
    x2 = giá trị của x0 khi nhập tải trọng tiếp theo (arm64)
    x3 = giá trị của x1 khi nhập tải trọng tiếp theo (arm64)
    x4 = giá trị của x2 khi nhập tải trọng tiếp theo (arm64)

Che giấu tất cả các ngoại lệ, vô hiệu hóa MMU, xóa các bit I+D, di chuyển các đối số
  vào đúng vị trí (chỉ arm64) và chuyển đến địa chỉ khởi động lại khi ở HYP/EL2.
  Hypercall này dự kiến ​​sẽ không quay trở lại với người gọi nó.

* ::

x0 = HVC_FINALISE_EL2 (chỉ arm64)

Hoàn tất việc định cấu hình EL2 tùy thuộc vào các tùy chọn dòng lệnh,
  bao gồm cả nỗ lực nâng cấp mức ngoại lệ của kernel từ
  EL1 sang EL2 bằng cách bật chế độ VHE. Điều này được điều chỉnh bởi CPU
  hỗ trợ VHE, EL2 MMU bị tắt và VHE không bị vô hiệu hóa bởi
  bất kỳ phương tiện nào khác (ví dụ: tùy chọn dòng lệnh).

Bất kỳ giá trị nào khác của r0/x0 sẽ kích hoạt việc xử lý dành riêng cho bộ điều khiển ảo hóa,
không được ghi lại ở đây.

Giá trị trả về của hypercall sơ khai được giữ bởi r0/x0 và bằng 0 trên
thành công và HVC_STUB_ERR bị lỗi. Một hypercall sơ khai được phép
ghi đè bất kỳ thanh ghi nào được người gọi lưu (x0-x18 trên arm64, r0-r3 và
ip trên cánh tay). Do đó, nên sử dụng lệnh gọi hàm để thực hiện
siêu cuộc gọi.