.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_cpumap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

=====================
BPF_MAP_TYPE_CPUMAP
===================

.. note::
   - ``BPF_MAP_TYPE_CPUMAP`` was introduced in kernel version 4.15

.. kernel-doc:: kernel/bpf/cpumap.c
 :doc: cpu map

Một trường hợp sử dụng ví dụ cho loại bản đồ này là Tỷ lệ bên nhận dựa trên phần mềm (RSS).

CPUMAP đại diện cho các CPU trong hệ thống được lập chỉ mục dưới dạng khóa bản đồ và
giá trị bản đồ là cài đặt cấu hình (mỗi mục nhập CPUMAP). Mỗi mục CPUMAP có một mục chuyên dụng
luồng hạt nhân được liên kết với CPU đã cho để đại diện cho đơn vị thực thi CPU từ xa.

Bắt đầu từ nhân Linux phiên bản 5.9, CPUMAP có thể chạy chương trình XDP thứ hai
trên điều khiển từ xa CPU. Điều này cho phép chương trình XDP phân chia quá trình xử lý của nó thành
nhiều CPU. Ví dụ: một kịch bản trong đó CPU ban đầu (thấy/nhận
các gói) cần thực hiện xử lý gói tối thiểu và CPU từ xa (để
gói được định hướng) có thể dành nhiều chu kỳ hơn để xử lý khung. các
CPU ban đầu là nơi chương trình chuyển hướng XDP được thực thi. Điều khiển từ xa CPU
nhận các đối tượng ZZ0000ZZ thô.

Cách sử dụng
=====

Hạt nhân BPF
----------
bpf_redirect_map()
^^^^^^^^^^^^^^^^^^
.. code-block:: c

     long bpf_redirect_map(struct bpf_map *map, u32 key, u64 flags)

Chuyển hướng gói đến điểm cuối được tham chiếu bởi ZZ0000ZZ tại chỉ mục ZZ0001ZZ.
Đối với ZZ0002ZZ, bản đồ này chứa các tham chiếu đến CPU.

Hai bit thấp hơn của ZZ0000ZZ được sử dụng làm mã trả về nếu tra cứu bản đồ
thất bại. Điều này là để giá trị trả về có thể là một trong các giá trị trả về của chương trình XDP
mã lên tới ZZ0001ZZ, do người gọi chọn.

Không gian người dùng
----------
.. note::
    CPUMAP entries can only be updated/looked up/deleted from user space and not
    from an eBPF program. Trying to call these functions from a kernel eBPF
    program will result in the program failing to load and a verifier warning.

bpf_map_update_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_update_elem(int fd, const void *key, const void *value, __u64 flags);

Các mục CPU có thể được thêm hoặc cập nhật bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này thay thế các phần tử hiện có một cách nguyên tử. Thông số ZZ0001ZZ
có thể là ZZ0002ZZ.

 .. code-block:: c

    struct bpf_cpumap_val {
        __u32 qsize;  /* queue size to remote target CPU */
        union {
            int   fd; /* prog fd on map write */
            __u32 id; /* prog id on map read */
        } bpf_prog;
    };

Đối số flags có thể là một trong những đối số sau:
  - BPF_ANY: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
  - BPF_NOEXIST: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
  - BPF_EXIST: Cập nhật phần tử hiện có.

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_lookup_elem(int fd, const void *key, void *value);

Các mục CPU có thể được truy xuất bằng ZZ0000ZZ
người giúp đỡ.

bpf_map_delete_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_delete_elem(int fd, const void *key);

Các mục CPU có thể bị xóa bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này sẽ trả về 0 nếu thành công hoặc có lỗi âm trong trường hợp
thất bại.

Ví dụ
========
hạt nhân
------

Đoạn mã sau đây cho thấy cách khai báo ZZ0000ZZ được gọi
ZZ0001ZZ và cách chuyển hướng các gói đến CPU từ xa bằng cách sử dụng sơ đồ vòng tròn.

.. code-block:: c

   struct {
        __uint(type, BPF_MAP_TYPE_CPUMAP);
        __type(key, __u32);
        __type(value, struct bpf_cpumap_val);
        __uint(max_entries, 12);
    } cpu_map SEC(".maps");

    struct {
        __uint(type, BPF_MAP_TYPE_ARRAY);
        __type(key, __u32);
        __type(value, __u32);
        __uint(max_entries, 12);
    } cpus_available SEC(".maps");

    struct {
        __uint(type, BPF_MAP_TYPE_PERCPU_ARRAY);
        __type(key, __u32);
        __type(value, __u32);
        __uint(max_entries, 1);
    } cpus_iterator SEC(".maps");

    SEC("xdp")
    int  xdp_redir_cpu_round_robin(struct xdp_md *ctx)
    {
        __u32 key = 0;
        __u32 cpu_dest = 0;
        __u32 *cpu_selected, *cpu_iterator;
        __u32 cpu_idx;

        cpu_iterator = bpf_map_lookup_elem(&cpus_iterator, &key);
        if (!cpu_iterator)
            return XDP_ABORTED;
        cpu_idx = *cpu_iterator;

        *cpu_iterator += 1;
        if (*cpu_iterator == bpf_num_possible_cpus())
            *cpu_iterator = 0;

        cpu_selected = bpf_map_lookup_elem(&cpus_available, &cpu_idx);
        if (!cpu_selected)
            return XDP_ABORTED;
        cpu_dest = *cpu_selected;

        if (cpu_dest >= bpf_num_possible_cpus())
            return XDP_ABORTED;

        return bpf_redirect_map(&cpu_map, cpu_dest, 0);
    }

Không gian người dùng
----------

Đoạn mã sau đây trình bày cách tự động đặt max_entries cho một
CPUMAP đến số lượng CPU tối đa có sẵn trên hệ thống.

.. code-block:: c

    int set_max_cpu_entries(struct bpf_map *cpu_map)
    {
        if (bpf_map__set_max_entries(cpu_map, libbpf_num_possible_cpus()) < 0) {
            fprintf(stderr, "Failed to set max entries for cpu_map map: %s",
                strerror(errno));
            return -1;
        }
        return 0;
    }

Tài liệu tham khảo
===========

-ZZ0000ZZ