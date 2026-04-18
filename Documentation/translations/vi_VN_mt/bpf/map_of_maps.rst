.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_of_maps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

=============================================================
BPF_MAP_TYPE_ARRAY_OF_MAPS và BPF_MAP_TYPE_HASH_OF_MAPS
=============================================================

.. note::
   - ``BPF_MAP_TYPE_ARRAY_OF_MAPS`` and ``BPF_MAP_TYPE_HASH_OF_MAPS`` were
     introduced in kernel version 4.12

ZZ0000ZZ và ZZ0001ZZ cung cấp chung
hỗ trợ mục đích cho bản đồ trong việc lưu trữ bản đồ. Một mức lồng nhau được hỗ trợ, trong đó
ví dụ: bản đồ bên ngoài chứa các phiên bản của một loại bản đồ bên trong
ZZ0002ZZ.

Khi tạo bản đồ bên ngoài, một thể hiện bản đồ bên trong được sử dụng để khởi tạo
siêu dữ liệu mà bản đồ bên ngoài chứa về bản đồ bên trong của nó. Bản đồ bên trong này có một
tách biệt thời gian tồn tại khỏi bản đồ bên ngoài và có thể bị xóa sau khi bản đồ bên ngoài đã
đã được tạo ra.

Bản đồ bên ngoài hỗ trợ tra cứu, cập nhật và xóa phần tử khỏi không gian người dùng bằng cách sử dụng
tòa nhà API. Chương trình BPF chỉ được phép thực hiện tra cứu phần tử ở bên ngoài
bản đồ.

.. note::
   - Multi-level nesting is not supported.
   - Any BPF map type can be used as an inner map, except for
     ``BPF_MAP_TYPE_PROG_ARRAY``.
   - A BPF program cannot update or delete outer map entries.

Đối với ZZ0000ZZ, khóa là chỉ mục số nguyên 32 bit không dấu
vào mảng. Mảng có kích thước cố định với các phần tử ZZ0001ZZ
không khởi tạo khi được tạo.

Đối với ZZ0000ZZ, loại khóa có thể được chọn khi xác định
bản đồ. Hạt nhân chịu trách nhiệm phân bổ và giải phóng các cặp khóa/giá trị, tối đa
giới hạn max_entries mà bạn chỉ định. Bản đồ băm sử dụng phân bổ trước hàm băm
các thành phần bảng theo mặc định. Cờ ZZ0001ZZ có thể được sử dụng để vô hiệu hóa
phân bổ trước khi nó quá tốn bộ nhớ.

Cách sử dụng
=====

Trình trợ giúp hạt nhân BPF
-----------------

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Bản đồ bên trong có thể được truy xuất bằng trình trợ giúp ZZ0000ZZ. Cái này
người trợ giúp trả về một con trỏ tới bản đồ bên trong hoặc ZZ0001ZZ nếu không tìm thấy mục nào.

Ví dụ
========

Ví dụ hạt nhân BPF
------------------

Đoạn mã này cho thấy cách tạo và khởi tạo một mảng bản đồ phát triển trong BPF
chương trình. Lưu ý rằng mảng bên ngoài chỉ có thể được sửa đổi từ không gian người dùng bằng cách sử dụng
tòa nhà API.

.. code-block:: c

    struct inner_map {
            __uint(type, BPF_MAP_TYPE_DEVMAP);
            __uint(max_entries, 10);
            __type(key, __u32);
            __type(value, __u32);
    } inner_map1 SEC(".maps"), inner_map2 SEC(".maps");

    struct {
            __uint(type, BPF_MAP_TYPE_ARRAY_OF_MAPS);
            __uint(max_entries, 2);
            __type(key, __u32);
            __array(values, struct inner_map);
    } outer_map SEC(".maps") = {
            .values = { &inner_map1,
                        &inner_map2 }
    };

Xem ZZ0000ZZ trong ZZ0001ZZ để biết thêm
ví dụ về khởi tạo khai báo của bản đồ bên ngoài.

Không gian người dùng
----------

Đoạn mã này cho thấy cách tạo bản đồ bên ngoài dựa trên mảng:

.. code-block:: c

    int create_outer_array(int inner_fd) {
            LIBBPF_OPTS(bpf_map_create_opts, opts, .inner_map_fd = inner_fd);
            int fd;

            fd = bpf_map_create(BPF_MAP_TYPE_ARRAY_OF_MAPS,
                                "example_array",       /* name */
                                sizeof(__u32),         /* key size */
                                sizeof(__u32),         /* value size */
                                256,                   /* max entries */
                                &opts);                /* create opts */
            return fd;
    }


Đoạn mã này cho biết cách thêm bản đồ bên trong vào bản đồ bên ngoài:

.. code-block:: c

    int add_devmap(int outer_fd, int index, const char *name) {
            int fd;

            fd = bpf_map_create(BPF_MAP_TYPE_DEVMAP, name,
                                sizeof(__u32), sizeof(__u32), 256, NULL);
            if (fd < 0)
                    return fd;

            return bpf_map_update_elem(outer_fd, &index, &fd, BPF_ANY);
    }

Tài liệu tham khảo
==========

-ZZ0000ZZ
-ZZ0001ZZ