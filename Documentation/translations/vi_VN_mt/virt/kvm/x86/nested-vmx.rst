.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/nested-vmx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
VMX lồng nhau
=============

Tổng quan
---------

Trên bộ xử lý Intel, KVM sử dụng VMX (Extensions máy ảo) của Intel
để chạy các hệ điều hành khách một cách dễ dàng và hiệu quả. Thông thường, những vị khách này
Bản thân ZZ0000ZZ là những nhà ảo hóa điều hành khách của chính họ, bởi vì trong VMX,
khách không thể sử dụng hướng dẫn VMX.

Tính năng "Nested VMX" bổ sung thêm khả năng còn thiếu này - của ứng dụng khách đang chạy
các nhà ảo hóa (sử dụng VMX) với các khách lồng nhau của chính họ. Nó làm như vậy bằng cách
cho phép khách sử dụng hướng dẫn VMX một cách chính xác và hiệu quả
mô phỏng chúng bằng cách sử dụng cấp độ VMX duy nhất có sẵn trong phần cứng.

Chúng tôi mô tả chi tiết hơn nhiều về lý thuyết đằng sau tính năng VMX lồng nhau,
việc triển khai và đặc tính hiệu suất của nó, trong bài báo OSDI 2010
"Dự án The Turtles: Thiết kế và triển khai ảo hóa lồng nhau",
có sẵn tại:

ZZ0000ZZ


Thuật ngữ
-----------

Ảo hóa một cấp có hai cấp độ - máy chủ (KVM) và khách.
Trong ảo hóa lồng nhau, chúng tôi có ba cấp độ: Máy chủ (KVM), mà chúng tôi gọi là
L0, trình ảo hóa khách, mà chúng tôi gọi là L1, và khách lồng nhau của nó, mà chúng tôi
gọi L2.


Chạy VMX lồng nhau
------------------

Tính năng VMX lồng nhau được bật theo mặc định kể từ nhân Linux v4.20. cho
nhân Linux cũ hơn, nó có thể được kích hoạt bằng cách đưa ra tùy chọn "nested=1" cho
mô-đun kvm-intel.


Không cần sửa đổi không gian người dùng (qemu). Tuy nhiên, mặc định của qemu
Loại CPU mô phỏng (qemu64) không liệt kê tính năng CPU "VMX", vì vậy nó phải là
được bật rõ ràng, bằng cách cung cấp cho qemu một trong các tùy chọn sau:

- máy chủ cpu (CPU mô phỏng có tất cả các tính năng của CPU thật)

- cpu qemu64,+vmx (chỉ thêm tính năng vmx vào loại CPU có tên)


ABI
----

VMX lồng nhau nhằm mục đích trình bày một VMX tiêu chuẩn và (cuối cùng) có đầy đủ chức năng
việc triển khai để trình ảo hóa khách sử dụng. Như vậy, quan chức
thông số kỹ thuật của ABI mà nó cung cấp là thông số kỹ thuật VMX của Intel,
cụ thể là tập 3B của "Phần mềm kiến trúc Intel 64 và IA-32" của họ
Hướng dẫn dành cho nhà phát triển". Hiện tại không phải tất cả các tính năng của VMX đều được hỗ trợ đầy đủ,
nhưng mục tiêu cuối cùng là hỗ trợ tất cả chúng, bắt đầu với các tính năng VMX
được sử dụng trong thực tế bởi các trình ảo hóa phổ biến (KVM và các trình ảo hóa khác).

Khi triển khai VMX, VMX lồng nhau trình bày cấu trúc VMCS cho L1.
Theo yêu cầu của thông số kỹ thuật, ngoài hai trường rev_id và abort,
cấu trúc này là ZZ0000ZZ đối với người dùng, những người không được phép biết hoặc quan tâm
về cấu trúc bên trong của nó. Đúng hơn, cấu trúc được truy cập thông qua
Hướng dẫn VMREAD và VMWRITE.
Tuy nhiên, vì mục đích gỡ lỗi, các nhà phát triển KVM có thể muốn biết
phần bên trong của cấu trúc này; Đây là cấu trúc vmcs12 từ Arch/x86/kvm/vmx.c.

Tên "vmcs12" dùng để chỉ VMCS mà L1 chế tạo cho L2. Trong mã chúng tôi
cũng có "vmcs01", VMCS mà L0 chế tạo cho L1 và "vmcs02" là VMCS
L0 nào được xây dựng để thực sự chạy L2 - cách thực hiện việc này được giải thích trong phần
giấy nói trên.

Để thuận tiện, chúng tôi lặp lại nội dung của struct vmcs12 tại đây. Nếu nội bộ
do cấu trúc này thay đổi, điều này có thể phá vỡ quá trình di chuyển trực tiếp trên các phiên bản KVM.
VMCS12_REVISION (từ vmx.c) nên được thay đổi nếu struct vmcs12 hoặc bên trong của nó
struct Shadow_vmcs luôn được thay đổi.

::

typedef u64 Natural_width;
	cấu trúc __đóng gói vmcs12 {
		/* Theo thông số kỹ thuật của Intel, vùng VMCS phải bắt đầu bằng
		 * hai trường này người dùng có thể nhìn thấy */
		u32 sửa đổi_id;
		u32 hủy bỏ;

u32 launch_state; /* được đặt thành 0 bởi VMCLEAR, thành 1 bởi VMLAUNCH */
		phần đệm u32 [7]; /* dư địa để mở rộng trong tương lai */

u64 io_bitmap_a;
		u64 io_bitmap_b;
		u64 msr_bitmap;
		u64 vm_exit_msr_store_addr;
		u64 vm_exit_msr_load_addr;
		u64 vm_entry_msr_load_addr;
		u64 tsc_offset;
		u64 virtual_apic_page_addr;
		u64 apic_access_addr;
		u64 ep_pointer;
		u64 guest_physical_address;
		u64 vmcs_link_pointer;
		u64 guest_ia32_debugctl;
		u64 guest_ia32_pat;
		u64 guest_ia32_efer;
		u64 guest_pdptr0;
		u64 guest_pdptr1;
		u64 guest_pdptr2;
		u64 guest_pdptr3;
		u64 Host_ia32_pat;
		u64 Host_ia32_efer;
		u64 đệm64 [8]; /* dư địa để mở rộng trong tương lai */
		tự nhiên_width cr0_guest_host_mask;
		tự nhiên_width cr4_guest_host_mask;
		tự nhiên_width cr0_read_shadow;
		tự nhiên_width cr4_read_shadow;
		Natural_width dead_space[4]; /* Phần còn lại cuối cùng của cr3_target_value[0-3]. */
		tự nhiên_width exit_qualification;
		tự nhiên_width khách_tuyến_địa chỉ;
		tự nhiên_width guest_cr0;
		tự nhiên_width guest_cr3;
		tự nhiên_width guest_cr4;
		tự nhiên_width guest_es_base;
		tự nhiên_width guest_cs_base;
		tự nhiên_width guest_ss_base;
		tự nhiên_width guest_ds_base;
		tự nhiên_width guest_fs_base;
		tự nhiên_width guest_gs_base;
		tự nhiên_width guest_ldtr_base;
		tự nhiên_width guest_tr_base;
		tự nhiên_width guest_gdtr_base;
		tự nhiên_width guest_idtr_base;
		tự nhiên_width guest_dr7;
		tự nhiên_width guest_rsp;
		tự nhiên_width guest_rip;
		tự nhiên_width guest_rflags;
		tự nhiên_width guest_pending_dbg_Exceptions;
		tự nhiên_width guest_sysenter_esp;
		tự nhiên_width guest_sysenter_eip;
		tự nhiên_width Host_cr0;
		tự nhiên_width Host_cr3;
		tự nhiên_width Host_cr4;
		tự nhiên_width Host_fs_base;
		tự nhiên_width Host_gs_base;
		tự nhiên_width Host_tr_base;
		tự nhiên_width Host_gdtr_base;
		tự nhiên_width Host_idtr_base;
		tự nhiên_width Host_ia32_sysenter_esp;
		Natural_width Host_ia32_sysenter_eip;
		tự nhiên_width Host_rsp;
		tự nhiên_width Host_rip;
		phần đệm tự nhiên_widthl[8]; /* dư địa để mở rộng trong tương lai */
		u32 pin_based_vm_exec_control;
		u32 cpu_based_vm_exec_control;
		u32 ngoại lệ_bitmap;
		u32 trang_fault_error_code_mask;
		u32 trang_fault_error_code_match;
		u32 cr3_target_count;
		u32 vm_exit_controls;
		u32 vm_exit_msr_store_count;
		u32 vm_exit_msr_load_count;
		u32 vm_entry_controls;
		u32 vm_entry_msr_load_count;
		u32 vm_entry_intr_info_field;
		u32 vm_entry_Exception_error_code;
		u32 vm_entry_instruction_len;
		u32 tpr_threshold;
		u32 thứ cấp_vm_exec_control;
		u32 vm_instruction_error;
		u32 vm_exit_reason;
		u32 vm_exit_intr_info;
		u32 vm_exit_intr_error_code;
		u32 idt_vectoring_info_field;
		u32 idt_vectoring_error_code;
		u32 vm_exit_instruction_len;
		u32 vmx_instruction_info;
		u32 guest_es_limit;
		u32 guest_cs_limit;
		u32 guest_ss_limit;
		u32 guest_ds_limit;
		u32 guest_fs_limit;
		u32 guest_gs_limit;
		u32 guest_ldtr_limit;
		u32 guest_tr_limit;
		u32 guest_gdtr_limit;
		u32 guest_idtr_limit;
		u32 guest_es_ar_bytes;
		u32 guest_cs_ar_bytes;
		u32 guest_ss_ar_bytes;
		u32 guest_ds_ar_bytes;
		u32 guest_fs_ar_bytes;
		u32 guest_gs_ar_bytes;
		u32 guest_ldtr_ar_bytes;
		u32 guest_tr_ar_bytes;
		u32 guest_interruptibility_info;
		u32 guest_activity_state;
		u32 guest_sysenter_cs;
		u32 Host_ia32_sysenter_cs;
		u32 đệm32 [8]; /* dư địa để mở rộng trong tương lai */
		u16 virtual_processor_id;
		u16 guest_es_selector;
		u16 guest_cs_selector;
		u16 guest_ss_selector;
		u16 guest_ds_selector;
		u16 guest_fs_selector;
		u16 guest_gs_selector;
		u16 guest_ldtr_selector;
		u16 guest_tr_selector;
		u16 Host_es_selector;
		u16 Host_cs_selector;
		u16 Host_ss_selector;
		u16 Host_ds_selector;
		u16 Host_fs_selector;
		u16 Host_gs_selector;
		u16 máy chủ_tr_selector;
	};


tác giả
-------

Những bản vá này được viết bởi:
    - Abel Gordon, abelg <at> il.ibm.com
    - Nadav Har'El, nyh <at> il.ibm.com
    - Orit Wasserman, oritw <at> il.ibm.com
    - Ben-Ami Yassor, benami <at> il.ibm.com
    - Muli Ben-Yehuda, muli <at> il.ibm.com

Với sự đóng góp của:
    - Anthony Liguori, aliguori <at> us.ibm.com
    - Mike Day, mdday <at> us.ibm.com
    - Michael Factor, yếu tố <at> il.ibm.com
    - Zvi Dubitzky, dubi <at> il.ibm.com

Và những đánh giá có giá trị của:
    - Avi Kivity, avi <at> redhat.com
    - Gleb Natapov, gleb <at> redhat.com
    - Marcelo Tosatti, mtosatti <at> redhat.com
    - Kevin Tian, kevin.tian <at> intel.com
    - và những người khác.