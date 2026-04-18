.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_queue_stack.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

=============================================
BPF_MAP_TYPE_QUEUE và BPF_MAP_TYPE_STACK
=============================================

.. note::
   - ``BPF_MAP_TYPE_QUEUE`` and ``BPF_MAP_TYPE_STACK`` were introduced
     in kernel version 4.20

ZZ0000ZZ cung cấp bộ lưu trữ FIFO và ZZ0001ZZ
cung cấp bộ lưu trữ LIFO cho các chương trình BPF. Những bản đồ này hỗ trợ xem nhanh, bật lên và
các hoạt động đẩy được tiếp xúc với các chương trình BPF thông qua tương ứng
những người giúp đỡ. Các hoạt động này được tiếp xúc với các ứng dụng không gian người dùng bằng cách sử dụng
tòa nhà cao tầng ZZ0002ZZ hiện có theo cách sau:

- ZZ0000ZZ -> nhìn trộm
- ZZ0001ZZ -> bật lên
- ZZ0002ZZ -> đẩy

ZZ0000ZZ và ZZ0001ZZ không hỗ trợ
ZZ0002ZZ.

Cách sử dụng
=====

Hạt nhân BPF
----------

bpf_map_push_elem()
~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_push_elem(struct bpf_map *map, const void *value, u64 flags)

Một phần tử ZZ0000ZZ có thể được thêm vào hàng đợi hoặc ngăn xếp bằng cách sử dụng
Người trợ giúp ZZ0001ZZ. Tham số ZZ0002ZZ phải được đặt thành
ZZ0003ZZ hoặc ZZ0004ZZ. Nếu ZZ0005ZZ được đặt thành ZZ0006ZZ thì
khi hàng đợi hoặc ngăn xếp đầy, phần tử cũ nhất sẽ bị xóa khỏi
nhường chỗ cho ZZ0007ZZ được thêm vào. Trả về ZZ0008ZZ khi thành công hoặc
lỗi tiêu cực trong trường hợp thất bại.

bpf_map_peek_elem()
~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_peek_elem(struct bpf_map *map, void *value)

Trình trợ giúp này tìm nạp phần tử ZZ0000ZZ từ hàng đợi hoặc ngăn xếp mà không cần
loại bỏ nó. Trả về ZZ0001ZZ nếu thành công hoặc có lỗi âm trong trường hợp
thất bại.

bpf_map_pop_elem()
~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_pop_elem(struct bpf_map *map, void *value)

Trình trợ giúp này xóa một phần tử vào ZZ0000ZZ khỏi hàng đợi hoặc
ngăn xếp. Trả về ZZ0001ZZ nếu thành công hoặc trả về lỗi âm trong trường hợp thất bại.


Không gian người dùng
---------

bpf_map_update_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_update_elem (int fd, const void *key, const void *value, __u64 flags)

Chương trình không gian người dùng có thể đẩy ZZ0000ZZ lên hàng đợi hoặc ngăn xếp bằng libbpf's
Chức năng ZZ0001ZZ. Tham số ZZ0002ZZ phải được đặt thành
ZZ0003ZZ và ZZ0004ZZ phải được đặt thành ZZ0005ZZ hoặc ZZ0006ZZ, với
ngữ nghĩa tương tự như trình trợ giúp hạt nhân ZZ0007ZZ. Trả về ZZ0008ZZ trên
thành công hoặc lỗi tiêu cực trong trường hợp thất bại.

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_lookup_elem (int fd, const void *key, void *value)

Chương trình không gian người dùng có thể xem ZZ0000ZZ ở đầu hàng đợi hoặc ngăn xếp
sử dụng hàm libbpf ZZ0001ZZ. Tham số ZZ0002ZZ phải là
được đặt thành ZZ0003ZZ.  Trả về ZZ0004ZZ nếu thành công hoặc có lỗi âm trong trường hợp
thất bại.

bpf_map_lookup_and_delete_elem()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_lookup_and_delete_elem (int fd, const void *key, void *value)

Chương trình không gian người dùng có thể lấy ZZ0000ZZ từ đầu hàng đợi hoặc ngăn xếp bằng cách sử dụng
hàm libbpf ZZ0001ZZ. Thông số ZZ0002ZZ
phải được đặt thành ZZ0003ZZ. Trả về ZZ0004ZZ nếu thành công hoặc có lỗi âm trong trường hợp
thất bại.

Ví dụ
========

Hạt nhân BPF
----------

Đoạn mã này cho biết cách khai báo hàng đợi trong chương trình BPF:

.. code-block:: c

    struct {
            __uint(type, BPF_MAP_TYPE_QUEUE);
            __type(value, __u32);
            __uint(max_entries, 10);
    } queue SEC(".maps");


Không gian người dùng
---------

Đoạn mã này cho thấy cách sử dụng API cấp thấp của libbpf để tạo hàng đợi từ
không gian người dùng:

.. code-block:: c

    int create_queue()
    {
            return bpf_map_create(BPF_MAP_TYPE_QUEUE,
                                  "sample_queue", /* name */
                                  0,              /* key size, must be zero */
                                  sizeof(__u32),  /* value size */
                                  10,             /* max entries */
                                  NULL);          /* create options */
    }


Tài liệu tham khảo
==========

ZZ0000ZZ