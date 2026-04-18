.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/prog_lsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2020 Google LLC.

====================
Chương trình LSM BPF
====================

Các chương trình BPF này cho phép thiết bị đo thời gian chạy của móc LSM theo đặc quyền
người dùng triển khai MAC (Kiểm soát truy cập bắt buộc) và Kiểm tra trên toàn hệ thống
chính sách sử dụng eBPF.

Kết cấu
---------

Ví dụ hiển thị chương trình eBPF có thể được gắn vào ZZ0000ZZ
Móc LSM:

.. c:function:: int file_mprotect(struct vm_area_struct *vma, unsigned long reqprot, unsigned long prot);

Bạn có thể tìm thấy các móc LSM khác có thể được trang bị tại
ZZ0000ZZ.

Các chương trình eBPF sử dụng Documentation/bpf/btf.rst không cần bao gồm kernel
các tiêu đề để truy cập thông tin từ ngữ cảnh của chương trình eBPF đính kèm.
Họ có thể chỉ cần khai báo các cấu trúc trong chương trình eBPF và chỉ xác định
các trường cần được truy cập.

.. code-block:: c

	struct mm_struct {
		unsigned long start_brk, brk, start_stack;
	} __attribute__((preserve_access_index));

	struct vm_area_struct {
		unsigned long start_brk, brk, start_stack;
		unsigned long vm_start, vm_end;
		struct mm_struct *vm_mm;
	} __attribute__((preserve_access_index));


.. note:: The order of the fields is irrelevant.

Điều này có thể được đơn giản hóa hơn nữa (nếu ai đó có quyền truy cập vào thông tin BTF tại
thời gian xây dựng) bằng cách tạo ZZ0000ZZ với:

.. code-block:: console

	# bpftool btf dump file <path-to-btf-vmlinux> format c > vmlinux.h

.. note:: ``path-to-btf-vmlinux`` can be ``/sys/kernel/btf/vmlinux`` if the
	  build environment matches the environment the BPF programs are
	  deployed in.

ZZ0000ZZ sau đó có thể được đưa vào các chương trình BPF mà không cần
yêu cầu định nghĩa các loại.

Các chương trình eBPF có thể được khai báo bằng cách sử dụng``BPF_PROG``
macro được xác định trong ZZ0001ZZ. Trong này
ví dụ:

* ZZ0000ZZ biểu thị hook LSM mà chương trình phải
	  được gắn liền với
	* ZZ0001ZZ là tên của chương trình eBPF

.. code-block:: c

	SEC("lsm/file_mprotect")
	int BPF_PROG(mprotect_audit, struct vm_area_struct *vma,
		     unsigned long reqprot, unsigned long prot, int ret)
	{
		/* ret is the return value from the previous BPF program
		 * or 0 if it's the first hook.
		 */
		if (ret != 0)
			return ret;

		int is_heap;

		is_heap = (vma->vm_start >= vma->vm_mm->start_brk &&
			   vma->vm_end <= vma->vm_mm->brk);

		/* Return an -EPERM or write information to the perf events buffer
		 * for auditing
		 */
		if (is_heap)
			return -EPERM;
	}

ZZ0000ZZ là một tính năng kêu vang cho phép
trình xác minh BPF để cập nhật các chênh lệch cho quyền truy cập trong thời gian chạy bằng cách sử dụng
Thông tin tài liệu/bpf/btf.rst. Vì trình xác minh BPF biết về
các loại, nó cũng xác nhận tất cả các truy cập được thực hiện cho các loại khác nhau trong
chương trình eBPF.

Đang tải
-------

Các chương trình eBPF có thể được tải bằng syscall của ZZ0000ZZ
ZZ0001ZZ hoạt động:

.. code-block:: c

	struct bpf_object *obj;

	obj = bpf_object__open("./my_prog.o");
	bpf_object__load(obj);

Điều này có thể được đơn giản hóa bằng cách sử dụng tiêu đề khung được tạo bởi ZZ0000ZZ:

.. code-block:: console

	# bpftool gen skeleton my_prog.o > my_prog.skel.h

và chương trình có thể được tải bằng cách bao gồm ZZ0000ZZ và sử dụng
trình trợ giúp được tạo, ZZ0001ZZ.

Đính kèm vào móc LSM
-----------------------

LSM cho phép đính kèm các chương trình eBPF dưới dạng móc LSM bằng ZZ0000ZZ
hoạt động ZZ0001ZZ của syscall hoặc đơn giản hơn bằng cách
sử dụng trình trợ giúp libbpf ZZ0002ZZ.

Chương trình có thể được tách khỏi móc LSM bằng ZZ0003ZZ ZZ0000ZZ
liên kết được ZZ0001ZZ trả về bằng ZZ0002ZZ.

Người ta cũng có thể sử dụng các trợ giúp được tạo trong ZZ0000ZZ, tức là.
ZZ0001ZZ để đính kèm và ZZ0002ZZ để dọn dẹp.

Ví dụ
--------

Một chương trình eBPF ví dụ có thể được tìm thấy trong
ZZ0000ZZ và tương ứng
mã không gian người dùng trong ZZ0001ZZ

.. Links
.. _tools/lib/bpf/bpf_tracing.h:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/tools/lib/bpf/bpf_tracing.h
.. _tools/testing/selftests/bpf/progs/lsm.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/tools/testing/selftests/bpf/progs/lsm.c
.. _tools/testing/selftests/bpf/prog_tests/test_lsm.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/tools/testing/selftests/bpf/prog_tests/test_lsm.c