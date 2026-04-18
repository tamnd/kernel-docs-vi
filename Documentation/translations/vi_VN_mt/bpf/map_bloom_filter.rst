.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_bloom_filter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

===========================
BPF_MAP_TYPE_BLOOM_FILTER
===========================

.. note::
   - ``BPF_MAP_TYPE_BLOOM_FILTER`` was introduced in kernel version 5.16

ZZ0000ZZ cung cấp bản đồ bộ lọc nở hoa BPF. nở hoa
bộ lọc là cấu trúc dữ liệu xác suất tiết kiệm không gian được sử dụng để
nhanh chóng kiểm tra xem một phần tử có tồn tại trong một tập hợp hay không. Trong một bộ lọc nở hoa,
dương tính giả là có thể xảy ra trong khi âm tính giả thì không.

Bản đồ bộ lọc nở không có khóa, chỉ có giá trị. Khi nở hoa
bản đồ bộ lọc được tạo, nó phải được tạo với ZZ0000ZZ bằng 0.
bản đồ bộ lọc nở hỗ trợ hai hoạt động:

- push: thêm một phần tử vào bản đồ
- nhìn trộm: xác định xem một phần tử có hiện diện trên bản đồ hay không

Các chương trình BPF phải sử dụng ZZ0000ZZ để thêm một phần tử vào
bản đồ bộ lọc nở và ZZ0001ZZ để truy vấn bản đồ. Những cái này
các hoạt động được tiếp xúc với các ứng dụng không gian người dùng bằng cách sử dụng
Tòa nhà ZZ0002ZZ theo cách sau:

- ZZ0000ZZ -> đẩy
- ZZ0001ZZ -> nhìn trộm

Kích thước ZZ0000ZZ được chỉ định tại thời điểm tạo bản đồ sẽ được sử dụng
để ước tính kích thước bitmap hợp lý cho bộ lọc nở và không
mặt khác được thực thi nghiêm ngặt. Nếu người dùng muốn chèn thêm mục
vào bộ lọc nở hơn ZZ0001ZZ, điều này có thể dẫn đến hiệu suất cao hơn
tỷ lệ dương tính giả.

Số lượng băm sử dụng cho bộ lọc nở có thể được định cấu hình bằng cách sử dụng
4 bit thấp hơn của ZZ0000ZZ trong ZZ0001ZZ khi tạo bản đồ
thời gian. Nếu không có số nào được chỉ định thì mặc định được sử dụng sẽ là hàm băm 5
chức năng. Nói chung, sử dụng nhiều giá trị băm hơn sẽ làm giảm cả giá trị sai
tỷ lệ tích cực và tốc độ tra cứu.

Không thể xóa các phần tử khỏi bản đồ bộ lọc nở hoa. Một bông hoa nở
bản đồ lọc có thể được sử dụng làm bản đồ bên trong. Người dùng chịu trách nhiệm về
đồng bộ hóa các cập nhật và tra cứu đồng thời để đảm bảo không có kết quả âm tính giả
tra cứu xảy ra.

Cách sử dụng
=====

Hạt nhân BPF
----------

bpf_map_push_elem()
~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_push_elem(struct bpf_map *map, const void *value, u64 flags)

ZZ0000ZZ có thể được thêm vào bộ lọc nở bằng cách sử dụng
Người trợ giúp ZZ0001ZZ. Tham số ZZ0002ZZ phải được đặt thành
ZZ0003ZZ khi thêm mục vào bộ lọc nở hoa. Người trợ giúp này
trả về ZZ0004ZZ khi thành công hoặc trả về lỗi âm trong trường hợp thất bại.

bpf_map_peek_elem()
~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   long bpf_map_peek_elem(struct bpf_map *map, void *value)

Trình trợ giúp ZZ0000ZZ được sử dụng để xác định xem
ZZ0001ZZ hiện diện trong bản đồ bộ lọc nở hoa. Người trợ giúp này trả về ZZ0002ZZ
nếu ZZ0003ZZ có thể xuất hiện trên bản đồ hoặc ZZ0004ZZ nếu ZZ0005ZZ
chắc chắn không có trên bản đồ.

Không gian người dùng
---------

bpf_map_update_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_update_elem (int fd, const void *key, const void *value, __u64 flags)

Chương trình không gian người dùng có thể thêm ZZ0000ZZ vào bộ lọc nở hoa bằng libbpf's
Chức năng ZZ0001ZZ. Tham số ZZ0002ZZ phải được đặt thành
ZZ0003ZZ và ZZ0004ZZ phải được đặt thành ZZ0005ZZ. Trả về ZZ0006ZZ trên
thành công hoặc lỗi tiêu cực trong trường hợp thất bại.

bpf_map_lookup_elem()
~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

   int bpf_map_lookup_elem (int fd, const void *key, void *value)

Một chương trình không gian người dùng có thể xác định sự hiện diện của ZZ0000ZZ đang nở rộ
lọc bằng chức năng ZZ0001ZZ của libbpf. ZZ0002ZZ
tham số phải được đặt thành ZZ0003ZZ. Trả về ZZ0004ZZ nếu ZZ0005ZZ là
có thể có trên bản đồ hoặc ZZ0006ZZ nếu ZZ0007ZZ chắc chắn có
không có mặt trên bản đồ.

Ví dụ
========

Hạt nhân BPF
----------

Đoạn mã này cho biết cách khai báo bộ lọc nở trong chương trình BPF:

.. code-block:: c

    struct {
            __uint(type, BPF_MAP_TYPE_BLOOM_FILTER);
            __type(value, __u32);
            __uint(max_entries, 1000);
            __uint(map_extra, 3);
    } bloom_filter SEC(".maps");

Đoạn mã này cho thấy cách xác định sự hiện diện của một giá trị đang nở rộ
bộ lọc trong chương trình BPF:

.. code-block:: c

    void *lookup(__u32 key)
    {
            if (bpf_map_peek_elem(&bloom_filter, &key) == 0) {
                    /* Verify not a false positive and fetch an associated
                     * value using a secondary lookup, e.g. in a hash table
                     */
                    return bpf_map_lookup_elem(&hash_table, &key);
            }
            return 0;
    }

Không gian người dùng
---------

Đoạn mã này cho thấy cách sử dụng libbpf để tạo bản đồ bộ lọc nở hoa từ
không gian người dùng:

.. code-block:: c

    int create_bloom()
    {
            LIBBPF_OPTS(bpf_map_create_opts, opts,
                        .map_extra = 3);             /* number of hashes */

            return bpf_map_create(BPF_MAP_TYPE_BLOOM_FILTER,
                                  "ipv6_bloom",      /* name */
                                  0,                 /* key size, must be zero */
                                  sizeof(ipv6_addr), /* value size */
                                  10000,             /* max entries */
                                  &opts);            /* create options */
    }

Đoạn mã này cho thấy cách thêm một phần tử vào bộ lọc nở hoa từ
không gian người dùng:

.. code-block:: c

    int add_element(struct bpf_map *bloom_map, __u32 value)
    {
            int bloom_fd = bpf_map__fd(bloom_map);
            return bpf_map_update_elem(bloom_fd, NULL, &value, BPF_ANY);
    }

Tài liệu tham khảo
==========

ZZ0000ZZ