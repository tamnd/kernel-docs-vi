.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/cpumasks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _cpumasks-header-label:

====================
BPF cpumask kfuncs
==================

1. Giới thiệu
===============

ZZ0000ZZ là cấu trúc dữ liệu bitmap trong kernel có các chỉ mục
phản ánh các CPU trên hệ thống. Thông thường, cpumasks được sử dụng để theo dõi CPU nào
một nhiệm vụ được xác định rõ ràng nhưng chúng cũng có thể được sử dụng để làm ví dụ. theo dõi lõi nào
được liên kết với miền lập kế hoạch, lõi nào trên máy không hoạt động,
v.v.

BPF cung cấp các chương trình với một bộ ZZ0000ZZ có thể
được sử dụng để phân bổ, thay đổi, truy vấn và giải phóng cpumask.

2. Đối tượng cpumask BPF
======================

Có hai loại mặt nạ cpu khác nhau có thể được các chương trình BPF sử dụng.

2.1 ZZ0000ZZ
----------------------------

ZZ0000ZZ là một cpumask được phân bổ bởi BPF, thay mặt cho một
Chương trình BPF và vòng đời của nó được kiểm soát hoàn toàn bởi BPF. Những cpumask này
được bảo vệ bởi RCU, có thể bị đột biến, có thể được sử dụng làm kptr và có thể được truyền một cách an toàn
tới ZZ0001ZZ.

2.1.1 Vòng đời của ZZ0000ZZ
----------------------------------------

ZZ0000ZZ được phân bổ, mua lại và phát hành bằng cách sử dụng
các chức năng sau:

.. kernel-doc:: kernel/bpf/cpumask.c
  :identifiers: bpf_cpumask_create

.. kernel-doc:: kernel/bpf/cpumask.c
  :identifiers: bpf_cpumask_acquire

.. kernel-doc:: kernel/bpf/cpumask.c
  :identifiers: bpf_cpumask_release

Ví dụ:

.. code-block:: c

        struct cpumask_map_value {
                struct bpf_cpumask __kptr * cpumask;
        };

        struct array_map {
                __uint(type, BPF_MAP_TYPE_ARRAY);
                __type(key, int);
                __type(value, struct cpumask_map_value);
                __uint(max_entries, 65536);
        } cpumask_map SEC(".maps");

        static int cpumask_map_insert(struct bpf_cpumask *mask, u32 pid)
        {
                struct cpumask_map_value local, *v;
                long status;
                struct bpf_cpumask *old;
                u32 key = pid;

                local.cpumask = NULL;
                status = bpf_map_update_elem(&cpumask_map, &key, &local, 0);
                if (status) {
                        bpf_cpumask_release(mask);
                        return status;
                }

                v = bpf_map_lookup_elem(&cpumask_map, &key);
                if (!v) {
                        bpf_cpumask_release(mask);
                        return -ENOENT;
                }

                old = bpf_kptr_xchg(&v->cpumask, mask);
                if (old)
                        bpf_cpumask_release(old);

                return 0;
        }

        /**
         * A sample tracepoint showing how a task's cpumask can be queried and
         * recorded as a kptr.
         */
        SEC("tp_btf/task_newtask")
        int BPF_PROG(record_task_cpumask, struct task_struct *task, u64 clone_flags)
        {
                struct bpf_cpumask *cpumask;
                int ret;

                cpumask = bpf_cpumask_create();
                if (!cpumask)
                        return -ENOMEM;

                if (!bpf_cpumask_full(task->cpus_ptr))
                        bpf_printk("task %s has CPU affinity", task->comm);

                bpf_cpumask_copy(cpumask, task->cpus_ptr);
                return cpumask_map_insert(cpumask, task->pid);
        }

----

2.1.1 ZZ0000ZZ dưới dạng kptr
---------------------------------------

Như đã đề cập và minh họa ở trên, các đối tượng ZZ0000ZZ này có thể
cũng được lưu trữ trong bản đồ và được sử dụng dưới dạng kptrs. Nếu ZZ0001ZZ ở trong
một bản đồ, tham chiếu có thể được xóa khỏi bản đồ bằng bpf_kptr_xchg() hoặc
có được một cách tình cờ bằng RCU:

.. code-block:: c

	/* struct containing the struct bpf_cpumask kptr which is stored in the map. */
	struct cpumasks_kfunc_map_value {
		struct bpf_cpumask __kptr * bpf_cpumask;
	};

	/* The map containing struct cpumasks_kfunc_map_value entries. */
	struct {
		__uint(type, BPF_MAP_TYPE_ARRAY);
		__type(key, int);
		__type(value, struct cpumasks_kfunc_map_value);
		__uint(max_entries, 1);
	} cpumasks_kfunc_map SEC(".maps");

	/* ... */

	/**
	 * A simple example tracepoint program showing how a
	 * struct bpf_cpumask * kptr that is stored in a map can
	 * be passed to kfuncs using RCU protection.
	 */
	SEC("tp_btf/cgroup_mkdir")
	int BPF_PROG(cgrp_ancestor_example, struct cgroup *cgrp, const char *path)
	{
		struct bpf_cpumask *kptr;
		struct cpumasks_kfunc_map_value *v;
		u32 key = 0;

		/* Assume a bpf_cpumask * kptr was previously stored in the map. */
		v = bpf_map_lookup_elem(&cpumasks_kfunc_map, &key);
		if (!v)
			return -ENOENT;

		bpf_rcu_read_lock();
		/* Acquire a reference to the bpf_cpumask * kptr that's already stored in the map. */
		kptr = v->cpumask;
		if (!kptr) {
			/* If no bpf_cpumask was present in the map, it's because
			 * we're racing with another CPU that removed it with
			 * bpf_kptr_xchg() between the bpf_map_lookup_elem()
			 * above, and our load of the pointer from the map.
			 */
			bpf_rcu_read_unlock();
			return -EBUSY;
		}

		bpf_cpumask_setall(kptr);
		bpf_rcu_read_unlock();

		return 0;
	}

----

2.2 ZZ0000ZZ
----------------------

ZZ0000ZZ là đối tượng thực sự chứa bitmap cpumask
đang được truy vấn, bị thay đổi, v.v. ZZ0001ZZ bao bọc ZZ0002ZZ, đó là lý do tại sao việc sử dụng nó như vậy là an toàn (tuy nhiên, hãy lưu ý rằng nó là
ZZ0005ZZ an toàn khi truyền ZZ0003ZZ sang ZZ0004ZZ và
người xác minh sẽ từ chối bất kỳ chương trình nào cố gắng làm như vậy).

Như chúng ta sẽ thấy bên dưới, bất kỳ kfunc nào làm thay đổi đối số cpumask của nó sẽ phải chịu một
ZZ0000ZZ làm đối số đó. Bất kỳ đối số nào chỉ đơn giản truy vấn
thay vào đó, cpumask sẽ lấy ZZ0001ZZ.

3. cpumask kfuncs
=================

Ở trên, chúng tôi đã mô tả các kfunc có thể được sử dụng để phân bổ, thu thập, giải phóng,
v.v. ZZ0000ZZ. Phần này của tài liệu sẽ mô tả
kfuncs để thay đổi và truy vấn cpumasks.

3.1 Thay đổi cpumask
---------------------

Một số kfunc cpumask là "chỉ đọc" ở chỗ chúng không làm thay đổi bất kỳ phần nào của chúng.
đối số, trong khi những đối số khác làm thay đổi ít nhất một đối số (có nghĩa là
đối số phải là ZZ0000ZZ, như được mô tả ở trên).

Phần này sẽ mô tả tất cả các kfunc cpumask biến đổi ít nhất một
lý lẽ. ZZ0000ZZ bên dưới mô tả kfuncs chỉ đọc.

3.1.1 Thiết lập và xóa CPU
-------------------------------

bpf_cpumask_set_cpu() và bpf_cpumask_clear_cpu() có thể được sử dụng để thiết lập và xóa
CPU trong ZZ0000ZZ tương ứng:

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_set_cpu bpf_cpumask_clear_cpu

Những kfunc này khá đơn giản và có thể được sử dụng chẳng hạn như
sau:

.. code-block:: c

        /**
         * A sample tracepoint showing how a cpumask can be queried.
         */
        SEC("tp_btf/task_newtask")
        int BPF_PROG(test_set_clear_cpu, struct task_struct *task, u64 clone_flags)
        {
                struct bpf_cpumask *cpumask;

                cpumask = bpf_cpumask_create();
                if (!cpumask)
                        return -ENOMEM;

                bpf_cpumask_set_cpu(0, cpumask);
                if (!bpf_cpumask_test_cpu(0, cast(cpumask)))
                        /* Should never happen. */
                        goto release_exit;

                bpf_cpumask_clear_cpu(0, cpumask);
                if (bpf_cpumask_test_cpu(0, cast(cpumask)))
                        /* Should never happen. */
                        goto release_exit;

                /* struct cpumask * pointers such as task->cpus_ptr can also be queried. */
                if (bpf_cpumask_test_cpu(0, task->cpus_ptr))
                        bpf_printk("task %s can use CPU %d", task->comm, 0);

        release_exit:
                bpf_cpumask_release(cpumask);
                return 0;
        }

----

bpf_cpumask_test_and_set_cpu() và bpf_cpumask_test_and_clear_cpu() là
kfuncs bổ sung cho phép người gọi kiểm tra và thiết lập (hoặc xóa) một cách nguyên tử
CPU:

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_test_and_set_cpu bpf_cpumask_test_and_clear_cpu

----

Chúng ta cũng có thể thiết lập và xóa toàn bộ đối tượng ZZ0000ZZ trong một
hoạt động sử dụng bpf_cpumask_setall() và bpf_cpumask_clear():

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_setall bpf_cpumask_clear

3.1.2 Thao tác giữa các cpumask
---------------------------------

Ngoài việc thiết lập và xóa từng CPU trong một cpumask,
người gọi cũng có thể thực hiện các thao tác theo bit giữa nhiều cpumask bằng cách sử dụng
bpf_cpumask_and(), bpf_cpumask_or() và bpf_cpumask_xor():

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_and bpf_cpumask_or bpf_cpumask_xor

Sau đây là một ví dụ về cách chúng có thể được sử dụng. Lưu ý rằng một số
kfuncs hiển thị trong ví dụ này sẽ được đề cập chi tiết hơn ở bên dưới.

.. code-block:: c

        /**
         * A sample tracepoint showing how a cpumask can be mutated using
           bitwise operators (and queried).
         */
        SEC("tp_btf/task_newtask")
        int BPF_PROG(test_and_or_xor, struct task_struct *task, u64 clone_flags)
        {
                struct bpf_cpumask *mask1, *mask2, *dst1, *dst2;

                mask1 = bpf_cpumask_create();
                if (!mask1)
                        return -ENOMEM;

                mask2 = bpf_cpumask_create();
                if (!mask2) {
                        bpf_cpumask_release(mask1);
                        return -ENOMEM;
                }

                // ...Safely create the other two masks... */

                bpf_cpumask_set_cpu(0, mask1);
                bpf_cpumask_set_cpu(1, mask2);
                bpf_cpumask_and(dst1, (const struct cpumask *)mask1, (const struct cpumask *)mask2);
                if (!bpf_cpumask_empty((const struct cpumask *)dst1))
                        /* Should never happen. */
                        goto release_exit;

                bpf_cpumask_or(dst1, (const struct cpumask *)mask1, (const struct cpumask *)mask2);
                if (!bpf_cpumask_test_cpu(0, (const struct cpumask *)dst1))
                        /* Should never happen. */
                        goto release_exit;

                if (!bpf_cpumask_test_cpu(1, (const struct cpumask *)dst1))
                        /* Should never happen. */
                        goto release_exit;

                bpf_cpumask_xor(dst2, (const struct cpumask *)mask1, (const struct cpumask *)mask2);
                if (!bpf_cpumask_equal((const struct cpumask *)dst1,
                                       (const struct cpumask *)dst2))
                        /* Should never happen. */
                        goto release_exit;

         release_exit:
                bpf_cpumask_release(mask1);
                bpf_cpumask_release(mask2);
                bpf_cpumask_release(dst1);
                bpf_cpumask_release(dst2);
                return 0;
        }

----

Nội dung của toàn bộ cpumask có thể được sao chép sang cái khác bằng cách sử dụng
bpf_cpumask_copy():

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_copy

----

.. _cpumasks-querying-label:

3.2 Truy vấn cpumasks
---------------------

Ngoài các kfunc trên, còn có một tập hợp kfunc chỉ đọc
có thể được sử dụng để truy vấn nội dung của cpumasks.

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_first bpf_cpumask_first_zero bpf_cpumask_first_and
                 bpf_cpumask_test_cpu bpf_cpumask_weight

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_equal bpf_cpumask_intersects bpf_cpumask_subset
                 bpf_cpumask_empty bpf_cpumask_full

.. kernel-doc:: kernel/bpf/cpumask.c
   :identifiers: bpf_cpumask_any_distribute bpf_cpumask_any_and_distribute

----

Một số ví dụ về cách sử dụng các kfunc truy vấn này đã được trình bày ở trên. Chúng tôi sẽ không
nhân rộng những ví dụ đó ở đây. Tuy nhiên, hãy lưu ý rằng tất cả những điều trên
kfuncs đã được thử nghiệm trong ZZ0000ZZ, vì vậy
vui lòng xem ở đó nếu bạn đang tìm thêm ví dụ về cách chúng có thể
đã sử dụng.

.. _tools/testing/selftests/bpf/progs/cpumask_success.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/tools/testing/selftests/bpf/progs/cpumask_success.c


4. Thêm kfuncs cpumask BPF
============================

Bộ cpumask kfuncs BPF được hỗ trợ chưa (chưa) khớp 1-1 với
hoạt động của cpumask trong include/linux/cpumask.h. Bất kỳ hoạt động cpumask nào
có thể dễ dàng được gói gọn trong một kfunc mới nếu và khi được yêu cầu. Nếu bạn muốn
để hỗ trợ hoạt động cpumask mới, vui lòng gửi bản vá. Nếu bạn
hãy thêm một cpumask kfunc mới, vui lòng ghi lại nó ở đây và thêm bất kỳ thông tin liên quan nào
các trường hợp kiểm thử selftest cho tới bộ selftest cpumask.