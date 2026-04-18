.. SPDX-License-Identifier: (LGPL-2.1 OR BSD-2-Clause)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/drgn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Công cụ drg BPF
==============

tập lệnh drgn là một cơ chế thuận tiện và dễ sử dụng để truy xuất tùy ý
cấu trúc dữ liệu hạt nhân. drgn không dựa vào kernel UAPI để đọc dữ liệu.
Thay vào đó nó đọc trực tiếp từ ZZ0000ZZ hoặc vmcore và các bản in đẹp
dữ liệu dựa trên thông tin gỡ lỗi DWARF từ vmlinux.

Tài liệu này mô tả các công cụ drgn liên quan đến BPF.

Xem ZZ0000ZZ để biết tất cả các công cụ hiện có và ZZ0001ZZ để biết
biết thêm chi tiết về chính drgn.

bpf_inspect.py
--------------

Sự miêu tả
===========

ZZ0000ZZ là một công cụ dùng để kiểm tra các chương trình và bản đồ BPF. Nó có thể
lặp lại tất cả các chương trình và bản đồ trong hệ thống và in thông tin cơ bản
về các đối tượng này, bao gồm id, loại và tên.

Vỏ ZZ0006ZZ trong trường hợp sử dụng chính là hiển thị các loại chương trình BPF
ZZ0000ZZ và ZZ0001ZZ được gắn vào BPF khác
các chương trình thông qua cơ chế ZZ0002ZZ/ZZ0003ZZ/ZZ0004ZZ/ZZ0005ZZ, vì
không có không gian người dùng API để lấy thông tin này.

Bắt đầu
===============

Liệt kê các chương trình BPF (tên đầy đủ được lấy từ BTF)::

% sudo bpf_inspect.py chương trình
        27: Điểm theo dõi BPF_PROG_TYPE_TRACEPOINT__tcp__tcp_send_reset
      4632: BPF_PROG_TYPE_CGROUP_SOCK_ADDR tw_ipt_bind
     49464: BPF_PROG_TYPE_RAW_TRACEPOINT raw_tracepoint__sched_process_exit

Liệt kê bản đồ BPF::

% sudo bpf_inspect.py bản đồ
        2577: BPF_MAP_TYPE_HASH tw_ipt_vips
        4050: BPF_MAP_TYPE_STACK_TRACE stack_traces
        4069: BPF_MAP_TYPE_PERCPU_ARRAY ned_dctcp_cntr

Tìm các chương trình BPF được đính kèm với chương trình BPF ZZ0000ZZ::

% sudo bpf_inspect.py p | grep test_pkt_access
         650: BPF_PROG_TYPE_SCHED_CLS test_pkt_access
         654: BPF_PROG_TYPE_TRACING test_main được liên kết:[650->25: BPF_TRAMP_FEXIT test_pkt_access->test_pkt_access()]
         655: BPF_PROG_TYPE_TRACING test_subprog1 được liên kết:[650->29: BPF_TRAMP_FEXIT test_pkt_access->test_pkt_access_subprog1()]
         656: BPF_PROG_TYPE_TRACING test_subprog2 được liên kết:[650->31: BPF_TRAMP_FEXIT test_pkt_access->test_pkt_access_subprog2()]
         657: BPF_PROG_TYPE_TRACING test_subprog3 được liên kết:[650->21: BPF_TRAMP_FEXIT test_pkt_access->test_pkt_access_subprog3()]
         658: BPF_PROG_TYPE_EXT new_get_skb_len được liên kết:[650->16: BPF_TRAMP_REPLACE test_pkt_access->get_skb_len()]
         659: BPF_PROG_TYPE_EXT new_get_skb_ifindex được liên kết:[650->23: BPF_TRAMP_REPLACE test_pkt_access->get_skb_ifindex()]
         660: BPF_PROG_TYPE_EXT new_get_constant được liên kết:[650->19: BPF_TRAMP_REPLACE test_pkt_access->get_constant()]

Có thể thấy là có chương trình ZZ0000ZZ, id 650 và ở đó
có nhiều chương trình truy tìm và mở rộng khác được gắn vào các chức năng trong
ZZ0001ZZ.

Ví dụ: dòng::

658: BPF_PROG_TYPE_EXT new_get_skb_len được liên kết:[650->16: BPF_TRAMP_REPLACE test_pkt_access->get_skb_len()]

, nghĩa là id chương trình BPF 658, gõ ZZ0000ZZ, tên
ZZ0001ZZ thay thế chức năng (ZZ0002ZZ) ZZ0003ZZ
có BTF id 16 trong chương trình BPF id 650, tên ZZ0004ZZ.

Nhận trợ giúp:

.. code-block:: none

    % sudo bpf_inspect.py
    usage: bpf_inspect.py [-h] {prog,p,map,m} ...

    drgn script to list BPF programs or maps and their properties
    unavailable via kernel API.

    See https://github.com/osandov/drgn/ for more details on drgn.

    optional arguments:
      -h, --help      show this help message and exit

    subcommands:
      {prog,p,map,m}
        prog (p)      list BPF programs
        map (m)       list BPF maps

Tùy chỉnh
=============

Tập lệnh được các nhà phát triển tùy chỉnh để in phù hợp
thông tin về các chương trình, bản đồ và các đối tượng khác của BPF.

Ví dụ: để in ZZ0000ZZ cho id chương trình BPF 53077:

.. code-block:: none

    % git diff
    diff --git a/tools/bpf_inspect.py b/tools/bpf_inspect.py
    index 650e228..aea2357 100755
    --- a/tools/bpf_inspect.py
    +++ b/tools/bpf_inspect.py
    @@ -112,7 +112,9 @@ def list_bpf_progs(args):
             if linked:
                 linked = f" linked:[{linked}]"

    -        print(f"{id_:>6}: {type_:32} {name:32} {linked}")
    +        if id_ == 53077:
    +            print(f"{id_:>6}: {type_:32} {name:32}")
    +            print(f"{bpf_prog.aux}")


     def list_bpf_maps(args):

Nó tạo ra đầu ra::

% sudo bpf_inspect.py p
     53077: BPF_PROG_TYPE_XDP tw_xdp_policer
    ZZ0000ZZ)0xffff8893fad4b400 = {
            .refcnt = (atomic64_t){
                    .counter = (dài)58,
            },
            .used_map_cnt = (u32)1,
            .max_ctx_offset = (u32)8,
            .max_pkt_offset = (u32)15,
            .max_tp_access = (u32)0,
            .stack_deep = (u32)8,
            .id = (u32)53077,
            .func_cnt = (u32)0,
            .func_idx = (u32)0,
            .attach_btf_id = (u32)0,
            .linked_prog = (struct bpf_prog *)0x0,
            .verifier_zext = (bool)0,
            .offload_requested = (bool)0,
            .attach_btf_trace = (bool)0,
            .func_proto_unreliable = (bool)0,
            .trampoline_prog_type = (enum bpf_tramp_prog_type)BPF_TRAMP_FENTRY,
            .trampoline = (struct bpf_trampoline *)0x0,
            .tramp_hlist = (struct hlist_node){
                    .next = (struct hlist_node *)0x0,
                    .pprev = (struct hlist_node **)0x0,
            },
            .attach_func_proto = (const struct btf_type *)0x0,
            .attach_func_name = (const char *)0x0,
            .func = (struct bpf_prog **)0x0,
            .jit_data = (void *)0x0,
            .poke_tab = (struct bpf_jit_poke_descriptor *)0x0,
            .size_poke_tab = (u32)0,
            .ksym_tnode = (struct chốt_tree_node){
                    .node = (struct rb_node [2]){
                            {
                                    .__rb_parent_color = (dài không dấu)18446612956263126665,
                                    .rb_right = (struct rb_node *)0x0,
                                    .rb_left = (struct rb_node *)0xffff88a0be3d0088,
                            },
                            {
                                    .__rb_parent_color = (dài không dấu)18446612956263126689,
                                    .rb_right = (struct rb_node *)0x0,
                                    .rb_left = (struct rb_node *)0xffff88a0be3d00a0,
                            },
                    },
            },
            .ksym_lnode = (struct list_head){
                    .next = (struct list_head *)0xffff88bf481830b8,
                    .prev = (struct list_head *)0xffff888309f536b8,
            },
            .ops = (const struct bpf_prog_ops *)xdp_prog_ops+0x0 = 0xffffffff820fa350,
            .used_maps = (struct bpf_map **)0xffff889ff795de98,
            .prog = (struct bpf_prog *)0xffffc9000cf2d000,
            .user = (struct user_struct *)root_user+0x0 = 0xffffffff82444820,
            .load_time = (u64)2408348759285319,
            .cgroup_storage = (struct bpf_map *[2]){},
            .name = (char [16])"tw_xdp_policer",
            .security = (void *)0xffff889ff795d548,
            .offload = (struct bpf_prog_offload *)0x0,
            .btf = (struct btf *)0xffff8890ce6d0580,
            .func_info = (struct bpf_func_info *)0xffff889ff795d240,
            .func_info_aux = (struct bpf_func_info_aux *)0xffff889ff795de20,
            .linfo = (struct bpf_line_info *)0xffff888a707afc00,
            .jited_linfo = (void **)0xffff8893fad48600,
            .func_info_cnt = (u32)1,
            .nr_linfo = (u32)37,
            .linfo_idx = (u32)0,
            .num_exentries = (u32)0,
            .extable = (struct ngoại lệ_table_entry *)0xffffffffa032d950,
            .stats = (struct bpf_prog_stats *)0x603fe3a1f6d0,
            .work = (struct Work_struct){
                    .data = (atomic_long_t){
                            .counter = (dài)0,
                    },
                    .entry = (struct list_head){
                            .next = (struct list_head *)0x0,
                            .prev = (struct list_head *)0x0,
                    },
                    .func = (work_func_t)0x0,
            },
            .rcu = (struct callback_head){
                    .next = (struct callback_head *)0x0,
                    .func = (void (ZZ0001ZZ))0x0,
            },
    }


.. Links
.. _drgn/doc: https://drgn.readthedocs.io/en/latest/
.. _drgn/tools: https://github.com/osandov/drgn/tree/master/tools
.. _bpf_inspect.py:
   https://github.com/osandov/drgn/blob/master/tools/bpf_inspect.py