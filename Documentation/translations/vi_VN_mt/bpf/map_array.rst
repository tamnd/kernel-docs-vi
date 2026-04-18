.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_array.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

====================================================
BPF_MAP_TYPE_ARRAY và BPF_MAP_TYPE_PERCPU_ARRAY
================================================

.. note::
   - ``BPF_MAP_TYPE_ARRAY`` was introduced in kernel version 3.19
   - ``BPF_MAP_TYPE_PERCPU_ARRAY`` was introduced in version 4.6

ZZ0000ZZ và ZZ0001ZZ cung cấp mảng chung
lưu trữ. Loại khóa là số nguyên 32 bit không dấu (4 byte) và bản đồ là
có kích thước không đổi. Kích thước của mảng được xác định trong ZZ0002ZZ tại
thời gian sáng tạo. Tất cả các phần tử mảng được phân bổ trước và được khởi tạo bằng 0 khi
được tạo ra. ZZ0003ZZ sử dụng vùng bộ nhớ khác nhau cho mỗi vùng
CPU trong khi ZZ0004ZZ sử dụng cùng vùng bộ nhớ. giá trị
được lưu trữ có thể có kích thước bất kỳ cho ZZ0005ZZ và không lớn hơn
ZZ0006ZZ (32 kB) cho ZZ0007ZZ. Tất cả
các phần tử mảng được căn chỉnh thành 8 byte.

Kể từ kernel 5.5, ánh xạ bộ nhớ có thể được bật cho ZZ0000ZZ bằng cách
đặt cờ ZZ0001ZZ. Định nghĩa bản đồ được căn chỉnh theo trang và
bắt đầu ở trang đầu tiên. Các khối có kích thước trang và căn chỉnh trang đủ
bộ nhớ được phân bổ để lưu trữ tất cả các giá trị mảng, bắt đầu từ trang thứ hai,
trong một số trường hợp sẽ dẫn đến việc phân bổ bộ nhớ quá mức. Lợi ích của
sử dụng điều này sẽ tăng hiệu suất và dễ sử dụng vì các chương trình không gian người dùng
sẽ không bắt buộc phải sử dụng các chức năng trợ giúp để truy cập và thay đổi dữ liệu.

Cách sử dụng
=====

Hạt nhân BPF
----------

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Các phần tử mảng có thể được truy xuất bằng trình trợ giúp ZZ0000ZZ.
Trình trợ giúp này trả về một con trỏ vào phần tử mảng, để tránh chạy đua dữ liệu
với không gian người dùng đọc giá trị, người dùng phải sử dụng các giá trị nguyên thủy như
ZZ0001ZZ khi cập nhật giá trị tại chỗ.

bpf_map_update_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_update_elem(struct bpf_map *map, const void *key, const void *value, u64 flags)

Các phần tử mảng có thể được cập nhật bằng trình trợ giúp ZZ0000ZZ.

ZZ0000ZZ trả về 0 nếu thành công hoặc lỗi âm trong trường hợp
thất bại.

Vì mảng có kích thước không đổi nên ZZ0000ZZ không được hỗ trợ.
Để xóa một phần tử mảng, bạn có thể sử dụng ZZ0001ZZ để chèn một phần tử mảng
giá trị 0 cho chỉ mục đó.

Mỗi mảng CPU
-------------

Các giá trị được lưu trữ trong ZZ0000ZZ có thể được truy cập bởi nhiều chương trình
trên các CPU khác nhau. Để hạn chế lưu trữ vào một CPU, bạn có thể sử dụng
ZZ0001ZZ.

Khi sử dụng ZZ0000ZZ, ZZ0001ZZ và
Người trợ giúp ZZ0002ZZ tự động truy cập vào khe cắm hiện tại
CPU.

bpf_map_lookup_percpu_elem()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_map_lookup_percpu_elem(struct bpf_map *map, const void *key, u32 cpu)

Trình trợ giúp ZZ0000ZZ có thể được sử dụng để tra cứu mảng
giá trị cho một CPU cụ thể. Trả về giá trị khi thành công hoặc ZZ0001ZZ nếu không có mục nhập nào
được tìm thấy hoặc ZZ0002ZZ không hợp lệ.

Đồng thời
-----------

Kể từ phiên bản kernel 5.1, cơ sở hạ tầng BPF cung cấp ZZ0000ZZ
để đồng bộ hóa quyền truy cập.

Không gian người dùng
---------

Truy cập từ không gian người dùng sử dụng API libbpf có cùng tên như trên, với
bản đồ được xác định bởi ZZ0000ZZ của nó.

Ví dụ
========

Vui lòng xem thư mục ZZ0000ZZ để biết chức năng
ví dụ. Các mẫu mã bên dưới minh họa cách sử dụng API.

Hạt nhân BPF
----------

Đoạn mã này cho thấy cách khai báo một mảng trong chương trình BPF.

.. code-block:: c

    struct {
            __uint(type, BPF_MAP_TYPE_ARRAY);
            __type(key, u32);
            __type(value, long);
            __uint(max_entries, 256);
    } my_map SEC(".maps");


Chương trình BPF ví dụ này cho thấy cách truy cập một phần tử mảng.

.. code-block:: c

    int bpf_prog(struct __sk_buff *skb)
    {
            struct iphdr ip;
            int index;
            long *value;

            if (bpf_skb_load_bytes(skb, ETH_HLEN, &ip, sizeof(ip)) < 0)
                    return 0;

            index = ip.protocol;
            value = bpf_map_lookup_elem(&my_map, &index);
            if (value)
                    __sync_fetch_and_add(value, skb->len);

            return 0;
    }

Không gian người dùng
---------

BPF_MAP_TYPE_ARRAY
~~~~~~~~~~~~~~~~~~

Đoạn mã này cho thấy cách tạo một mảng, sử dụng ZZ0000ZZ để
đặt cờ.

.. code-block:: c

    #include <bpf/libbpf.h>
    #include <bpf/bpf.h>

    int create_array()
    {
            int fd;
            LIBBPF_OPTS(bpf_map_create_opts, opts, .map_flags = BPF_F_MMAPABLE);

            fd = bpf_map_create(BPF_MAP_TYPE_ARRAY,
                                "example_array",       /* name */
                                sizeof(__u32),         /* key size */
                                sizeof(long),          /* value size */
                                256,                   /* max entries */
                                &opts);                /* create opts */
            return fd;
    }

Đoạn mã này cho thấy cách khởi tạo các phần tử của một mảng.

.. code-block:: c

    int initialize_array(int fd)
    {
            __u32 i;
            long value;
            int ret;

            for (i = 0; i < 256; i++) {
                    value = i;
                    ret = bpf_map_update_elem(fd, &i, &value, BPF_ANY);
                    if (ret < 0)
                            return ret;
            }

            return ret;
    }

Đoạn mã này cho thấy cách truy xuất một giá trị phần tử từ một mảng.

.. code-block:: c

    int lookup(int fd)
    {
            __u32 index = 42;
            long value;
            int ret;

            ret = bpf_map_lookup_elem(fd, &index, &value);
            if (ret < 0)
                    return ret;

            /* use value here */
            assert(value == 42);

            return ret;
    }

BPF_MAP_TYPE_PERCPU_ARRAY
~~~~~~~~~~~~~~~~~~~~~~~~~

Đoạn mã này cho thấy cách khởi tạo các phần tử của mỗi mảng CPU.

.. code-block:: c

    int initialize_array(int fd)
    {
            int ncpus = libbpf_num_possible_cpus();
            long values[ncpus];
            __u32 i, j;
            int ret;

            for (i = 0; i < 256 ; i++) {
                    for (j = 0; j < ncpus; j++)
                            values[j] = i;
                    ret = bpf_map_update_elem(fd, &i, &values, BPF_ANY);
                    if (ret < 0)
                            return ret;
            }

            return ret;
    }

Đoạn mã này cho thấy cách truy cập các phần tử CPU của một giá trị mảng.

.. code-block:: c

    int lookup(int fd)
    {
            int ncpus = libbpf_num_possible_cpus();
            __u32 index = 42, j;
            long values[ncpus];
            int ret;

            ret = bpf_map_lookup_elem(fd, &index, &values);
            if (ret < 0)
                    return ret;

            for (j = 0; j < ncpus; j++) {
                    /* Use per CPU value here */
                    assert(values[j] == 42);
            }

            return ret;
    }

Ngữ nghĩa
=========

Như trong ví dụ trên, khi truy cập ZZ0000ZZ
trong không gian người dùng, mỗi giá trị là một mảng có các phần tử ZZ0001ZZ.

Khi gọi ZZ0000ZZ, không thể sử dụng cờ ZZ0001ZZ
cho những bản đồ này.