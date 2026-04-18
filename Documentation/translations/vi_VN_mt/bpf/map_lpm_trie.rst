.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_lpm_trie.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

=======================
BPF_MAP_TYPE_LPM_TRIE
=======================

.. note::
   - ``BPF_MAP_TYPE_LPM_TRIE`` was introduced in kernel version 4.11

ZZ0000ZZ cung cấp thuật toán khớp tiền tố dài nhất
có thể được sử dụng để khớp địa chỉ IP với một bộ tiền tố được lưu trữ.
Trong nội bộ, dữ liệu được lưu trữ trong một bộ ba nút không cân bằng sử dụng
Cặp ZZ0001ZZ làm khóa của nó. ZZ0002ZZ được diễn giải theo
thứ tự byte mạng, tức là endian lớn, vì vậy ZZ0003ZZ lưu trữ nhiều nhất
byte đáng kể.

Các lần thử LPM có thể được tạo với độ dài tiền tố tối đa là bội số
của 8, trong khoảng từ 8 đến 2048. Khóa dùng để tra cứu và cập nhật
hoạt động là ZZ0000ZZ, được mở rộng bởi
byte ZZ0001ZZ.

- Đối với địa chỉ IPv4 độ dài dữ liệu là 4 byte
- Đối với địa chỉ IPv6 độ dài dữ liệu là 16 byte

Loại giá trị được lưu trữ trong bộ ba LPM có thể là bất kỳ loại nào do người dùng xác định.

.. note::
   When creating a map of type ``BPF_MAP_TYPE_LPM_TRIE`` you must set the
   ``BPF_F_NO_PREALLOC`` flag.

Cách sử dụng
============

Hạt nhân BPF
------------

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Mục nhập tiền tố dài nhất cho một giá trị dữ liệu nhất định có thể được tìm thấy bằng cách sử dụng
Người trợ giúp ZZ0000ZZ. Trình trợ giúp này trả về một con trỏ tới
giá trị được liên kết với ZZ0001ZZ phù hợp dài nhất hoặc ZZ0002ZZ nếu không
mục nhập đã được tìm thấy.

ZZ0000ZZ nên đặt ZZ0001ZZ thành ZZ0002ZZ khi
thực hiện tra cứu tiền tố dài nhất. Ví dụ: khi tìm kiếm
khớp tiền tố dài nhất cho địa chỉ IPv4, ZZ0003ZZ phải được đặt thành
ZZ0004ZZ.

bpf_map_update_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_update_elem(struct bpf_map *map, const void *key, const void *value, u64 flags)

Các mục tiền tố có thể được thêm hoặc cập nhật bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này thay thế các phần tử hiện có một cách nguyên tử.

ZZ0000ZZ trả về ZZ0001ZZ nếu thành công hoặc có lỗi tiêu cực trong
trường hợp thất bại.

 .. note::
    The flags parameter must be one of BPF_ANY, BPF_NOEXIST or BPF_EXIST,
    but the value is ignored, giving BPF_ANY semantics.

bpf_map_delete_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_delete_elem(struct bpf_map *map, const void *key)

Các mục tiền tố có thể được xóa bằng ZZ0000ZZ
người giúp đỡ. Người trợ giúp này sẽ trả về 0 nếu thành công hoặc có lỗi tiêu cực trong trường hợp
của sự thất bại.

Không gian người dùng
---------------------

Truy cập từ không gian người dùng sử dụng API libbpf có cùng tên như trên, với
bản đồ được xác định bởi ZZ0000ZZ.

bpf_map_get_next_key()
~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_get_next_key (int fd, const void *cur_key, void *next_key)

Một chương trình không gian người dùng có thể lặp qua các mục trong bộ ba LPM bằng cách sử dụng
chức năng ZZ0000ZZ của libbpf. Chìa khóa đầu tiên có thể là
được tìm nạp bằng cách gọi ZZ0001ZZ với ZZ0002ZZ được đặt thành
ZZ0003ZZ. Các cuộc gọi tiếp theo sẽ lấy khóa tiếp theo theo sau
khóa hiện tại. ZZ0004ZZ trả về ZZ0005ZZ nếu thành công,
ZZ0006ZZ nếu ZZ0007ZZ là khóa cuối cùng trong bộ ba hoặc âm
lỗi trong trường hợp thất bại.

ZZ0000ZZ sẽ lặp qua ba phần tử LPM
từ lá ngoài cùng bên trái đầu tiên. Điều này có nghĩa là việc lặp lại sẽ trả về nhiều hơn
các khóa cụ thể trước các khóa ít cụ thể hơn.

Ví dụ
========

Vui lòng xem ZZ0000ZZ để biết ví dụ
LPM thử sử dụng từ không gian người dùng. Các đoạn mã dưới đây chứng minh
Cách sử dụng API.

Hạt nhân BPF
------------

Đoạn mã BPF sau đây cho biết cách khai báo bộ ba LPM mới cho IPv4
tiền tố địa chỉ:

.. code-block:: c

    #include <linux/bpf.h>
    #include <bpf/bpf_helpers.h>

    struct ipv4_lpm_key {
            __u32 prefixlen;
            __u32 data;
    };

    struct {
            __uint(type, BPF_MAP_TYPE_LPM_TRIE);
            __type(key, struct ipv4_lpm_key);
            __type(value, __u32);
            __uint(map_flags, BPF_F_NO_PREALLOC);
            __uint(max_entries, 255);
    } ipv4_lpm_map SEC(".maps");

Đoạn mã BPF sau đây hướng dẫn cách tra cứu theo địa chỉ IPv4:

.. code-block:: c

    void *lookup(__u32 ipaddr)
    {
            struct ipv4_lpm_key key = {
                    .prefixlen = 32,
                    .data = ipaddr
            };

            return bpf_map_lookup_elem(&ipv4_lpm_map, &key);
    }

Không gian người dùng
---------------------

Đoạn mã sau đây cho biết cách chèn mục nhập tiền tố IPv4 vào một
LPM thử:

.. code-block:: c

    int add_prefix_entry(int lpm_fd, __u32 addr, __u32 prefixlen, struct value *value)
    {
            struct ipv4_lpm_key ipv4_key = {
                    .prefixlen = prefixlen,
                    .data = addr
            };
            return bpf_map_update_elem(lpm_fd, &ipv4_key, value, BPF_ANY);
    }

Đoạn mã sau hiển thị một chương trình không gian người dùng duyệt qua các mục
của bộ ba LPM:


.. code-block:: c

    #include <bpf/libbpf.h>
    #include <bpf/bpf.h>

    void iterate_lpm_trie(int map_fd)
    {
            struct ipv4_lpm_key *cur_key = NULL;
            struct ipv4_lpm_key next_key;
            struct value value;
            int err;

            for (;;) {
                    err = bpf_map_get_next_key(map_fd, cur_key, &next_key);
                    if (err)
                            break;

                    bpf_map_lookup_elem(map_fd, &next_key, &value);

                    /* Use key and value here */

                    cur_key = &next_key;
            }
    }