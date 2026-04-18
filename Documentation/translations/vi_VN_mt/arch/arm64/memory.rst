.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/memory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Bố cục bộ nhớ trên AArch64 Linux
=================================

Tác giả: Catalin Marinas <catalin.marinas@arm.com>

Tài liệu này mô tả bố cục bộ nhớ ảo được AArch64 sử dụng
Hạt nhân Linux. Kiến trúc cho phép tối đa 4 cấp độ dịch thuật
các bảng có kích thước trang 4KB và tối đa 3 cấp độ với kích thước trang 64KB.

AArch64 Linux sử dụng bảng dịch 3 cấp hoặc 4 cấp
với cấu hình trang 4KB, cho phép 39-bit (512GB) hoặc 48-bit
(256TB) địa chỉ ảo tương ứng cho cả người dùng và kernel. Với
Trang 64KB, chỉ có 2 cấp độ bảng dịch, cho phép 42-bit (4TB)
địa chỉ ảo, được sử dụng nhưng cách bố trí bộ nhớ giống nhau.

ARMv8.2 bổ sung hỗ trợ tùy chọn cho không gian Địa chỉ ảo lớn. Đây là
chỉ khả dụng khi chạy với kích thước trang 64KB và mở rộng
số lượng mô tả ở cấp độ dịch đầu tiên.

Lựa chọn TTBRx được đưa ra bởi bit 55 của địa chỉ ảo. các
swapper_pg_dir chỉ chứa ánh xạ kernel (toàn cầu) trong khi người dùng pgd
chỉ chứa ánh xạ người dùng (không phải toàn cầu).  Địa chỉ swapper_pg_dir là
được ghi vào TTBR1 và không bao giờ được ghi vào TTBR0.

Khi sử dụng KVM mà không có Tiện ích mở rộng máy chủ ảo hóa,
bộ ảo hóa ánh xạ các trang hạt nhân trong EL2 tại một vị trí cố định (và có thể
ngẫu nhiên) khỏi ánh xạ tuyến tính. Xem macro kern_hyp_va và
chức năng kvm_update_va_mask để biết thêm chi tiết. Các thiết bị MMIO như
GICv2 được ánh xạ bên cạnh trang idmap HYP, cũng như các vectơ khi
ARM64_SPECTRE_V3A được kích hoạt cho các CPU cụ thể.

Khi sử dụng KVM với Tiện ích mở rộng máy chủ ảo hóa, không cần bổ sung
ánh xạ được tạo vì hạt nhân máy chủ chạy trực tiếp trong EL2.

Hỗ trợ VA 52-bit trong kernel
-------------------------------
Nếu có tính năng tùy chọn ARMv8.2-LVA và chúng tôi đang chạy
với kích thước trang 64KB; thì có thể sử dụng địa chỉ 52 bit
không gian cho cả không gian người dùng và địa chỉ kernel. Tuy nhiên, bất kỳ hạt nhân nào
nhị phân hỗ trợ 52 bit cũng phải có khả năng quay lại 48 bit
vào thời điểm khởi động sớm nếu tính năng phần cứng không có.

Cơ chế dự phòng này yêu cầu hạt nhân .text phải nằm trong
địa chỉ cao hơn sao cho chúng bất biến đối với VA 48/52-bit. Đến hạn
bóng kasan là một phần của toàn bộ không gian VA kernel,
phần cuối của bóng kasan cũng phải ở nửa trên của
không gian VA kernel cho cả 48/52-bit. (Chuyển từ 48 bit sang 52 bit,
phần cuối của bóng kasan là bất biến và phụ thuộc vào ~0UL,
trong khi địa chỉ bắt đầu sẽ "phát triển" về phía các địa chỉ thấp hơn).

Để tối ưu hóa Phys_to_virt và virt_to_phys, PAGE_OFFSET
được giữ không đổi ở 0xFFF00000000000000 (tương ứng với 52-bit),
điều này loại bỏ sự cần thiết phải đọc thêm biến. thể chất
offset và vmemmap offset được tính toán khi khởi động sớm để kích hoạt
logic này.

Vì một nhị phân đơn sẽ cần hỗ trợ cả VA 48 bit và 52 bit
không gian, VMEMMAP phải có kích thước đủ lớn cho VA 52 bit và
cũng phải có kích thước đủ lớn để chứa một chiếc PAGE_OFFSET cố định.

Hầu hết mã trong kernel không cần phải xem xét VA_BITS, vì
mã cần biết kích thước VA của các biến là
được xác định như sau:

VA_BITS hằng số kích thước không gian ZZ0000ZZ VA

VA_BITS_MIN hằng số kích thước không gian ZZ0000ZZ VA

biến vabits_actual kích thước không gian ZZ0000ZZ VA


Kích thước tối đa và tối thiểu có thể hữu ích để đảm bảo rằng bộ đệm được
có kích thước đủ lớn hoặc địa chỉ đó được đặt ở vị trí đủ gần để
trường hợp "xấu nhất".

VA không gian người dùng 52-bit
-------------------------------
Để duy trì khả năng tương thích với phần mềm dựa trên ARMv8.0
Kích thước tối đa của không gian VA là 48 bit, theo mặc định, hạt nhân sẽ
trả lại địa chỉ ảo cho không gian người dùng từ phạm vi 48 bit.

Phần mềm có thể "chọn tham gia" nhận VA từ không gian 52 bit bằng cách
chỉ định tham số gợi ý mmap lớn hơn 48-bit.

Ví dụ:

.. code-block:: c

   maybe_high_address = mmap(~0UL, size, prot, flags,...);

Cũng có thể xây dựng một hạt nhân gỡ lỗi trả về địa chỉ
từ không gian 52 bit bằng cách bật các tùy chọn cấu hình kernel sau:

.. code-block:: sh

   CONFIG_EXPERT=y && CONFIG_ARM64_FORCE_52BIT=y

Lưu ý rằng tùy chọn này chỉ dành cho việc gỡ lỗi ứng dụng
và không nên được sử dụng trong sản xuất.
