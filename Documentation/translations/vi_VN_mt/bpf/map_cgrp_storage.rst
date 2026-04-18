.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_cgrp_storage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Meta Platforms, Inc. and affiliates.

===========================
BPF_MAP_TYPE_CGRP_STORAGE
=========================

Loại bản đồ ZZ0000ZZ đại diện cho một bản đồ có kích thước cố định cục bộ
lưu trữ cho cgroups. Nó chỉ khả dụng với ZZ0001ZZ.
Các chương trình được cung cấp bởi cùng một Kconfig. các
dữ liệu cho một nhóm cụ thể có thể được lấy bằng cách tra cứu bản đồ
với nhóm đó.

Tài liệu này mô tả cách sử dụng và ngữ nghĩa của
Loại bản đồ ZZ0000ZZ.

Cách sử dụng
=====

Khóa bản đồ phải là ZZ0000ZZ đại diện cho một nhóm fd.
Để truy cập bộ nhớ trong một chương trình, hãy sử dụng ZZ0001ZZ::

void *bpf_cgrp_storage_get(struct bpf_map *map, struct cgroup *cgroup, void *value, cờ u64)

ZZ0000ZZ có thể là 0 hoặc ZZ0001ZZ cho biết rằng
một bộ nhớ cục bộ mới sẽ được tạo nếu bộ nhớ đó không tồn tại.

Bộ nhớ cục bộ có thể được xóa bằng ZZ0000ZZ::

bpf_cgrp_storage_delete dài (struct bpf_map *map, struct cgroup *cgroup)

Bản đồ có sẵn cho tất cả các loại chương trình.

Ví dụ
========

Ví dụ về chương trình BPF với BPF_MAP_TYPE_CGRP_STORAGE::

#include <vmlinux.h>
    #include <bpf/bpf_helpers.h>
    #include <bpf/bpf_tracing.h>

cấu trúc {
            __uint(loại, BPF_MAP_TYPE_CGRP_STORAGE);
            __uint(map_flags, BPF_F_NO_PREALLOC);
            __type(khóa, int);
            __type(giá trị, dài);
    } cgrp_storage SEC(".maps");

SEC("tp_btf/sys_enter")
    int BPF_PROG(on_enter, struct pt_regs *regs, id dài)
    {
            struct task_struct *task = bpf_get_current_task_btf();
            dài *ptr;

ptr = bpf_cgrp_storage_get(&cgrp_storage, task->cgroups->dfl_cgrp, 0,
                                       BPF_LOCAL_STORAGE_GET_F_CREATE);
            nếu (ptr)
                __sync_fetch_and_add(ptr, 1);

trả về 0;
    }

Bản đồ truy cập không gian người dùng được khai báo ở trên::

#include <linux/bpf.h>
    #include <linux/libbpf.h>

__u32 map_lookup(struct bpf_map *map, int cgrp_fd)
    {
            __u32 *giá trị;
            giá trị = bpf_map_lookup_elem(bpf_map__fd(map), &cgrp_fd);
            nếu (giá trị)
                trả về giá trị *;
            trả về 0;
    }

Sự khác biệt giữa BPF_MAP_TYPE_CGRP_STORAGE và BPF_MAP_TYPE_CGROUP_STORAGE
============================================================================

Bản đồ lưu trữ cgroup cũ ZZ0000ZZ đã được đánh dấu là
không được dùng nữa (được đổi tên thành ZZ0001ZZ). cái mới
Thay vào đó nên sử dụng bản đồ ZZ0002ZZ. Sau đây
minh họa sự khác biệt chính giữa ZZ0003ZZ và
ZZ0004ZZ.

(1). ZZ0000ZZ có thể được sử dụng bởi tất cả các loại chương trình trong khi
     ZZ0001ZZ chỉ khả dụng cho các loại chương trình cgroup
     như BPF_CGROUP_INET_INGRESS hoặc BPF_CGROUP_SOCK_OPS, v.v.

(2). ZZ0000ZZ hỗ trợ lưu trữ cục bộ cho nhiều hơn một
     cgroup trong khi ZZ0001ZZ chỉ hỗ trợ một cgroup
     được đính kèm bởi chương trình BPF.

(3). ZZ0000ZZ phân bổ bộ nhớ cục bộ tại thời điểm đính kèm để
     ZZ0001ZZ luôn trả về bộ nhớ cục bộ không phải NULL.
     ZZ0002ZZ phân bổ bộ nhớ cục bộ khi chạy
     có thể ZZ0003ZZ có thể trả về bộ nhớ cục bộ rỗng.
     Để tránh vấn đề lưu trữ cục bộ rỗng như vậy, không gian người dùng có thể thực hiện
     ZZ0004ZZ để phân bổ trước bộ nhớ cục bộ trước chương trình BPF
     được đính kèm.

(4). ZZ0000ZZ hỗ trợ xóa bộ nhớ cục bộ bằng chương trình BPF
     trong khi ZZ0001ZZ chỉ xóa bộ nhớ trong
     thời gian tách prog.

Vì vậy, về tổng thể, ZZ0000ZZ hỗ trợ tất cả ZZ0001ZZ
chức năng và hơn thế nữa. Nên sử dụng ZZ0002ZZ
thay vì ZZ0003ZZ.