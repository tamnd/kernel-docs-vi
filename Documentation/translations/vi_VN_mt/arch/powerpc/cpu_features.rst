.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/cpu_features.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Tính năng CPU
=============

Hollis Blanchard <hollis@austin.ibm.com>
5 tháng 6 năm 2002

Tài liệu này mô tả hệ thống (bao gồm cả mã tự sửa đổi) được sử dụng trong
Nhân Linux PPC để hỗ trợ nhiều loại CPU PowerPC mà không yêu cầu
lựa chọn thời gian biên dịch.

Trong quá trình khởi động sớm, hạt nhân ppc32 sẽ phát hiện loại CPU hiện tại và
chọn một tập hợp các tính năng tương ứng. Một số ví dụ bao gồm hỗ trợ Altivec,
phân chia bộ đệm lệnh và dữ liệu và nếu CPU hỗ trợ DOZE và NAP
các chế độ ngủ.

Việc phát hiện bộ tính năng rất đơn giản. Một danh sách các bộ xử lý có thể được tìm thấy trong
Arch/powerpc/kernel/cputable.c. Thanh ghi PVR được che dấu và so sánh với
mỗi giá trị trong danh sách. Nếu tìm thấy kết quả khớp, cpu_features của cur_cpu_spec
được gán cho bitmask tính năng cho bộ xử lý này và __setup_cpu
hàm được gọi.

Mã C có thể kiểm tra 'cur_cpu_spec[smp_processor_id()]->cpu_features' để tìm
bit tính năng cụ thể. Điều này được thực hiện ở khá nhiều nơi, ví dụ
trong ppc_setup_l2cr().

Việc triển khai tính năng cpu trong quá trình lắp ráp có liên quan nhiều hơn một chút. có
một số đường dẫn quan trọng về hiệu năng và sẽ bị ảnh hưởng nếu một mảng
chỉ mục, tham chiếu cấu trúc và nhánh có điều kiện đã được thêm vào. Để tránh
phạt hiệu suất nhưng vẫn cho phép thời gian chạy (chứ không phải thời gian biên dịch) CPU
lựa chọn, mã không sử dụng sẽ được thay thế bằng hướng dẫn 'nop'. Việc này là
dựa trên khả năng của CPU 0, do đó, một hệ thống đa bộ xử lý có
bộ xử lý sẽ không hoạt động (nhưng hệ thống như vậy có thể gặp các vấn đề khác
dù sao đi nữa).

Sau khi phát hiện loại bộ xử lý, kernel sẽ vá các phần mã
không nên sử dụng bằng cách viết chữ nop lên trên nó. Sử dụng cpufeatures yêu cầu
chỉ có 2 macro (được tìm thấy trong Arch/powerpc/include/asm/cputable.h), như đã thấy trong head.S
transfer_to_handler::

#ifdef CONFIG_ALTIVEC
	BEGIN_FTR_SECTION
		mfspr r22,SPRN_VRSAVE /* nếu G4, lưu giá trị thanh ghi vrsave */
		stw r22,THREAD_VRSAVE(r23)
	END_FTR_SECTION_IFSET(CPU_FTR_ALTIVEC)
	#endif /* CONFIG_ALTIVEC */

Nếu CPU 0 hỗ trợ Altivec, mã sẽ không bị ảnh hưởng. Nếu không thì cả hai
hướng dẫn được thay thế bằng nop.

Macro END_FTR_SECTION có hai biến thể đơn giản hơn: END_FTR_SECTION_IFSET
và END_FTR_SECTION_IFCLR. Chúng chỉ đơn giản kiểm tra xem cờ có được đặt hay không (trong
cur_cpu_spec[0]->cpu_features) hoặc bị xóa tương ứng. Hai macro này
nên được sử dụng trong phần lớn các trường hợp.

Các macro END_FTR_SECTION được triển khai bằng cách lưu trữ thông tin về điều này
mã trong phần '__ftr_fixup' ELF. Khi do_cpu_ftr_fixups
(arch/powerpc/kernel/misc.S) được gọi, nó sẽ lặp lại các bản ghi trong
__ftr_fixup và nếu không có tính năng được yêu cầu, nó sẽ ghi lặp
nop từ mỗi BEGIN_FTR_SECTION đến END_FTR_SECTION.
