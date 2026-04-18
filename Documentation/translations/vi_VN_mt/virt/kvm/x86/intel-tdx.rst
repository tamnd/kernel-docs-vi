.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/intel-tdx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Phần mở rộng miền tin cậy của Intel (TDX)
=========================================

Tổng quan
========
Tiện ích mở rộng miền tin cậy của Intel (TDX) bảo vệ các máy ảo khách bí mật khỏi
máy chủ và các cuộc tấn công vật lý.  Mô-đun phần mềm được chứng nhận CPU có tên là 'TDX
module' chạy bên trong phạm vi cách ly CPU mới để cung cấp các chức năng cho
quản lý và chạy các máy ảo được bảo vệ, còn gọi là TDX khách hoặc TD.

Vui lòng tham khảo [1] để biết báo cáo chính thức, thông số kỹ thuật và các tài nguyên khác.

Tài liệu này mô tả các ABI KVM dành riêng cho TDX.  Mô-đun TDX cần được
được khởi tạo trước khi KVM có thể sử dụng nó để chạy bất kỳ máy khách TDX nào.  chủ nhà
core-kernel cung cấp hỗ trợ khởi tạo mô-đun TDX,
được mô tả trong Tài liệu/arch/x86/tdx.rst.

Mô tả API
===============

KVM_MEMORY_ENCRYPT_OP
---------------------
:Loại: vm ioctl, vcpu ioctl

Đối với các hoạt động TDX, KVM_MEMORY_ENCRYPT_OP được tái mục đích thành hoạt động chung
ioctl với các lệnh sub-ioctl() cụ thể của TDX.

::

/* Các lệnh phụ của Tiện ích mở rộng miền tin cậy sub-ioctl(). */
  enum kvm_tdx_cmd_id {
          KVM_TDX_CAPABILITIES = 0,
          KVM_TDX_INIT_VM,
          KVM_TDX_INIT_VCPU,
          KVM_TDX_INIT_MEM_REGION,
          KVM_TDX_FINALIZE_VM,
          KVM_TDX_GET_CPUID,

KVM_TDX_CMD_NR_MAX,
  };

cấu trúc kvm_tdx_cmd {
        /* enum kvm_tdx_cmd_id */
        __u32 id;
        /* cờ cho lệnh phụ. Nếu lệnh phụ không sử dụng lệnh này, hãy đặt số 0. */
        __u32 cờ;
        /*
         * dữ liệu cho từng lệnh phụ. Một ngay lập tức hoặc một con trỏ đến thực tế
         * dữ liệu trong địa chỉ ảo của quá trình.  Nếu lệnh phụ không sử dụng nó,
         * đặt số không.
         */
        __u64 dữ liệu;
        /*
         * Mã lỗi phụ trợ.  Lệnh phụ có thể trả về TDX SEAMCALL
         * mã trạng thái ngoài -Exxx.
         */
        __u64 hw_error;
  };

KVM_TDX_CAPABILITIES
--------------------
:Type: vm ioctl
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Trả lại các khả năng của TDX mà KVM hiện tại hỗ trợ với TDX cụ thể
mô-đun được tải trong hệ thống.  Nó báo cáo những tính năng/khả năng nào được phép
được cấu hình cho máy khách TDX.

- id: KVM_TDX_CAPABILITIES
- cờ: phải là 0
- dữ liệu: con trỏ tới struct kvm_tdx_capabilities
- hw_error: phải bằng 0

::

cấu trúc kvm_tdx_capabilities {
        __u64 được hỗ trợ_attrs;
        __u64 được hỗ trợ_xfam;

/* Siêu lệnh gọi TDG.VP.VMCALL được thực thi trong kernel và chuyển tiếp tới
         * không gian người dùng, tương ứng
         */
        __u64 kernel_tdvmcallinfo_1_r11;
        __u64 user_tdvmcallinfo_1_r11;

/* Lệnh TDG.VP.VMCALL thực thi các hàm con được thực thi trong kernel
         * và được chuyển tiếp đến không gian người dùng tương ứng
         */
        __u64 kernel_tdvmcallinfo_1_r12;
        __u64 user_tdvmcallinfo_1_r12;

__u64 dành riêng[250];

/* Các bit CPUID có thể định cấu hình cho không gian người dùng */
        cấu trúc kvm_cpuid2 cpuid;
  };


KVM_TDX_INIT_VM
---------------
:Type: vm ioctl
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Thực hiện khởi tạo VM cụ thể TDX.  Điều này cần phải được gọi sau
KVM_CREATE_VM và trước khi tạo bất kỳ VCPU nào.

- id: KVM_TDX_INIT_VM
- cờ: phải là 0
- dữ liệu: con trỏ tới struct kvm_tdx_init_vm
- hw_error: phải bằng 0

::

cấu trúc kvm_tdx_init_vm {
          __u64 thuộc tính;
          __u64 xfam;
          __u64 mrconfigid[6];          /* thông báo sha384 */
          __u64 mrower[6];             /* thông báo sha384 */
          __u64 mrowerconfig[6];       /* thông báo sha384 */

/* Tổng dung lượng cho TD_PARAMS trước CPUID là 256 byte */
          __u64 dành riêng[12];

/*
         * Gọi KVM_TDX_INIT_VM trước khi tạo vcpu, tức là trước
         *KVM_SET_CPUID2.
         * Cấu hình này thay thế KVM_SET_CPUID2 cho VCPU vì
         * Mô-đun TDX trực tiếp ảo hóa các CPUID đó mà không cần VMM.  Người dùng
         * khoảng trống VMM, ví dụ: qemu, nên làm cho KVM_SET_CPUID2 phù hợp với
         * những giá trị đó.  Nếu không, KVM có thể đã hiểu sai về vCPUID của
         * khách và KVM có thể mô phỏng sai CPUID hoặc MSR mà TDX
         * mô-đun không ảo hóa.
         */
          cấu trúc kvm_cpuid2 cpuid;
  };


KVM_TDX_INIT_VCPU
-----------------
:Type: vcpu ioctl
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Thực hiện khởi tạo VCPU cụ thể cho TDX.

- id: KVM_TDX_INIT_VCPU
- cờ: phải là 0
- dữ liệu: giá trị ban đầu của khách TD VCPU RCX
- hw_error: phải bằng 0

KVM_TDX_INIT_MEM_REGION
-----------------------
:Type: vcpu ioctl
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Khởi tạo bộ nhớ riêng của khách @nr_pages TDX bắt đầu từ @gpa với không gian người dùng
dữ liệu được cung cấp từ @source_addr. @source_addr phải được căn chỉnh theo PAGE_SIZE.

Lưu ý, trước khi gọi lệnh phụ này, thuộc tính bộ nhớ của phạm vi
[gpa, gpa + nr_pages] cần được đặt ở chế độ riêng tư.  Không gian người dùng có thể sử dụng
KVM_SET_MEMORY_ATTRIBUTES để đặt thuộc tính.

Nếu cờ KVM_TDX_MEASURE_MEMORY_REGION được chỉ định, nó cũng mở rộng phép đo.

- id: KVM_TDX_INIT_MEM_REGION
- cờ: hiện tại chỉ xác định KVM_TDX_MEASURE_MEMORY_REGION
- dữ liệu: con trỏ tới struct kvm_tdx_init_mem_zone
- hw_error: phải bằng 0

::

#define KVM_TDX_MEASURE_MEMORY_REGION (1UL << 0)

cấu trúc kvm_tdx_init_mem_khu vực {
          __u64 nguồn_addr;
          __u64 gpa;
          __u64 nr_pages;
  };


KVM_TDX_FINALIZE_VM
-------------------
:Type: vm ioctl
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Hoàn thành việc đo lường nội dung TD ban đầu và đánh dấu nó đã sẵn sàng để chạy.

- id: KVM_TDX_FINALIZE_VM
- cờ: phải là 0
- dữ liệu: phải là 0
- hw_error: phải bằng 0


KVM_TDX_GET_CPUID
-----------------
:Type: vcpu ioctl
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Nhận các giá trị CPUID mà mô-đun TDX ảo hóa cho khách TD.
Khi nó trả về -E2BIG, không gian người dùng sẽ phân bổ bộ đệm lớn hơn và
thử lại. Kích thước bộ đệm tối thiểu được cập nhật trong trường nent của
cấu trúc kvm_cpuid2.

- id: KVM_TDX_GET_CPUID
- cờ: phải là 0
- dữ liệu: con trỏ tới struct kvm_cpuid2 (vào/ra)
- hw_error: phải bằng 0 (ra)

::

cấu trúc kvm_cpuid2 {
	  __u32 không;
	  __u32 đệm;
	  struct kvm_cpuid_entry2 mục [0];
  };

cấu trúc kvm_cpuid_entry2 {
	  __u32 chức năng;
	  chỉ số __u32;
	  __u32 cờ;
	  __u32 eax;
	  __u32 ebx;
	  __u32 ecx;
	  __u32 edx;
	  __u32 đệm [3];
  };

Luồng tạo KVM TDX
=====================
Ngoài luồng KVM tiêu chuẩn, cần phải gọi các ioctls TDX mới.  các
luồng điều khiển như sau:

#. Kiểm tra khả năng toàn hệ thống

* KVM_CAP_VM_TYPES: Kiểm tra xem loại VM có được hỗ trợ không và KVM_X86_TDX_VM có được hỗ trợ không
     được hỗ trợ.

#. Tạo máy ảo

* KVM_CREATE_VM
   * KVM_TDX_CAPABILITIES: Truy vấn các khả năng của TDX để tạo khách TDX.
   * KVM_CHECK_EXTENSION(KVM_CAP_MAX_VCPUS): Truy vấn VCPU tối đa mà TD có thể
     hỗ trợ ở cấp độ VM (TDX có giới hạn riêng về vấn đề này).
   * KVM_SET_TSC_KHZ: Định cấu hình tần số TSC của TD nếu tần số TSC khác
     hơn máy chủ mong muốn.  Đây là tùy chọn.
   * KVM_TDX_INIT_VM: Truyền các tham số VM cụ thể của TDX.

#. Tạo VCPU

* KVM_CREATE_VCPU
   * KVM_TDX_INIT_VCPU: Truyền các tham số VCPU cụ thể của TDX.
   * KVM_SET_CPUID2: Cấu hình CPUID của TD.
   * KVM_SET_MSRS: Cấu hình MSR của TD.

#. Khởi tạo bộ nhớ khách ban đầu

* Chuẩn bị nội dung ký ức ban đầu của khách.
   * KVM_TDX_INIT_MEM_REGION: Thêm bộ nhớ khách ban đầu.
   * KVM_TDX_FINALIZE_VM: Hoàn thiện phép đo của khách TDX.

#. Chạy VCPU

Tài liệu tham khảo
==========

ZZ0000ZZ