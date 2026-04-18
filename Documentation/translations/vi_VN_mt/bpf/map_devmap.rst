.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_devmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

=====================================================
BPF_MAP_TYPE_DEVMAP và BPF_MAP_TYPE_DEVMAP_HASH
=====================================================

.. note::
   - ``BPF_MAP_TYPE_DEVMAP`` was introduced in kernel version 4.14
   - ``BPF_MAP_TYPE_DEVMAP_HASH`` was introduced in kernel version 5.4

ZZ0000ZZ và ZZ0001ZZ chủ yếu là các bản đồ BPF
được sử dụng làm bản đồ phụ trợ cho trình trợ giúp XDP BPF gọi ZZ0002ZZ.
ZZ0003ZZ được hỗ trợ bởi một mảng sử dụng khóa làm
chỉ mục để tra cứu tham chiếu đến thiết bị mạng. Trong khi ZZ0004ZZ
được hỗ trợ bởi bảng băm sử dụng khóa để tra cứu tham chiếu đến thiết bị mạng.
Người dùng cung cấp <ZZ0005ZZ/ ZZ0006ZZ> hoặc <ZZ0007ZZ/ ZZ0008ZZ>
cặp để cập nhật bản đồ với các thiết bị mạng mới.

.. note::
    - The key to a hash map doesn't have to be an ``ifindex``.
    - While ``BPF_MAP_TYPE_DEVMAP_HASH`` allows for densely packing the net devices
      it comes at the cost of a hash of the key when performing a look up.

Việc thiết lập và mã enqueue/gửi gói được chia sẻ giữa hai loại
bản đồ phát triển; chỉ có việc tra cứu và chèn là khác nhau.

Cách sử dụng
============
Hạt nhân BPF
------------
bpf_redirect_map()
^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_redirect_map(struct bpf_map *map, u32 key, u64 flags)

Chuyển hướng gói đến điểm cuối được tham chiếu bởi ZZ0000ZZ tại chỉ mục ZZ0001ZZ.
Đối với ZZ0002ZZ và ZZ0003ZZ, bản đồ này chứa
tham chiếu đến các thiết bị mạng (để chuyển tiếp gói qua các cổng khác).

Hai bit thấp hơn của ZZ0004ZZ được sử dụng làm mã trả về nếu tra cứu bản đồ
thất bại. Điều này là để giá trị trả về có thể là một trong các giá trị trả về của chương trình XDP
mã lên tới ZZ0000ZZ, do người gọi chọn. Các bit cao hơn của ZZ0001ZZ
có thể được đặt thành ZZ0002ZZ hoặc ZZ0003ZZ như được xác định
bên dưới.

Với ZZ0000ZZ, gói sẽ được phát tới tất cả các giao diện
trong bản đồ, với ZZ0001ZZ, giao diện xâm nhập sẽ bị loại trừ
từ buổi phát sóng.

.. note::
    - The key is ignored if BPF_F_BROADCAST is set.
    - The broadcast feature can also be used to implement multicast forwarding:
      simply create multiple DEVMAPs, each one corresponding to a single multicast group.

Người trợ giúp này sẽ trả về ZZ0000ZZ nếu thành công hoặc giá trị của cả hai
các bit thấp hơn của đối số ZZ0001ZZ nếu việc tra cứu bản đồ không thành công.

Bạn có thể tìm thêm thông tin về chuyển hướng ZZ0000ZZ

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

   void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Các mục nhập thiết bị mạng có thể được truy xuất bằng ZZ0000ZZ
người giúp đỡ.

Không gian người dùng
---------------------
.. note::
    DEVMAP entries can only be updated/deleted from user space and not
    from an eBPF program. Trying to call these functions from a kernel eBPF
    program will result in the program failing to load and a verifier warning.

bpf_map_update_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

   int bpf_map_update_elem(int fd, const void *key, const void *value, __u64 flags);

Các mục thiết bị mạng có thể được thêm hoặc cập nhật bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này thay thế các phần tử hiện có một cách nguyên tử. Thông số ZZ0001ZZ
có thể là ZZ0002ZZ hoặc ZZ0003ZZ đơn giản để quay ngược
khả năng tương thích.

 .. code-block:: c

    struct bpf_devmap_val {
        __u32 ifindex;   /* device index */
        union {
            int   fd;  /* prog fd on map write */
            __u32 id;  /* prog id on map read */
        } bpf_prog;
    };

Đối số ZZ0000ZZ có thể là một trong những đối số sau:
  - ZZ0001ZZ: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
  - ZZ0002ZZ: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
  - ZZ0003ZZ: Cập nhật phần tử hiện có.

DEVMAP có thể liên kết chương trình với mục nhập thiết bị bằng cách thêm ZZ0000ZZ
tới ZZ0001ZZ. Các chương trình được chạy sau ZZ0002ZZ và có
truy cập vào cả thiết bị Rx và thiết bị Tx. Chương trình liên kết với ZZ0003ZZ
phải có loại XDP với loại đính kèm dự kiến là ZZ0004ZZ.
Khi một chương trình được liên kết với một chỉ mục thiết bị, chương trình đó sẽ được chạy trên một
ZZ0005ZZ và trước khi bộ đệm được thêm vào hàng đợi trên mỗi CPU. Ví dụ
về cách đính kèm/sử dụng các progs xdp_devmap có thể được tìm thấy trong bản tự kiểm tra kernel:

-ZZ0000ZZ
-ZZ0001ZZ

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

.. c:function::
   int bpf_map_lookup_elem(int fd, const void *key, void *value);

Các mục nhập thiết bị mạng có thể được truy xuất bằng ZZ0000ZZ
người giúp đỡ.

bpf_map_delete_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

.. c:function::
   int bpf_map_delete_elem(int fd, const void *key);

Các mục nhập thiết bị mạng có thể bị xóa bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này sẽ trả về 0 nếu thành công hoặc có lỗi âm trong trường hợp
thất bại.

Ví dụ
========

Hạt nhân BPF
------------

Đoạn mã sau đây cho biết cách khai báo ZZ0000ZZ
được gọi là tx_port.

.. code-block:: c

    struct {
        __uint(type, BPF_MAP_TYPE_DEVMAP);
        __type(key, __u32);
        __type(value, __u32);
        __uint(max_entries, 256);
    } tx_port SEC(".maps");

Đoạn mã sau đây cho biết cách khai báo ZZ0000ZZ
được gọi là Forward_map.

.. code-block:: c

    struct {
        __uint(type, BPF_MAP_TYPE_DEVMAP_HASH);
        __type(key, __u32);
        __type(value, struct bpf_devmap_val);
        __uint(max_entries, 32);
    } forward_map SEC(".maps");

.. note::

    The value type in the DEVMAP above is a ``struct bpf_devmap_val``

Đoạn mã sau đây hiển thị một chương trình xdp_redirect_map đơn giản. Chương trình này
sẽ hoạt động với chương trình không gian người dùng chứa bản đồ dựa trên devmap ZZ0000ZZ
trên ifindexes xâm nhập. Chương trình BPF (bên dưới) đang chuyển hướng các gói bằng cách sử dụng
nhập ZZ0001ZZ dưới dạng ZZ0002ZZ.

.. code-block:: c

    SEC("xdp")
    int xdp_redirect_map_func(struct xdp_md *ctx)
    {
        int index = ctx->ingress_ifindex;

        return bpf_redirect_map(&forward_map, index, 0);
    }

Đoạn mã sau đây hiển thị một chương trình BPF đang phát các gói tới
tất cả các giao diện trong bản đồ phát triển ZZ0000ZZ.

.. code-block:: c

    SEC("xdp")
    int xdp_redirect_map_func(struct xdp_md *ctx)
    {
        return bpf_redirect_map(&tx_port, 0, BPF_F_BROADCAST | BPF_F_EXCLUDE_INGRESS);
    }

Không gian người dùng
---------------------

Đoạn mã sau đây cho biết cách cập nhật bản đồ nhà phát triển có tên ZZ0000ZZ.

.. code-block:: c

    int update_devmap(int ifindex, int redirect_ifindex)
    {
        int ret;

        ret = bpf_map_update_elem(bpf_map__fd(tx_port), &ifindex, &redirect_ifindex, 0);
        if (ret < 0) {
            fprintf(stderr, "Failed to update devmap_ value: %s\n",
                strerror(errno));
        }

        return ret;
    }

Đoạn mã sau đây cho biết cách cập nhật hash_devmap có tên ZZ0000ZZ.

.. code-block:: c

    int update_devmap(int ifindex, int redirect_ifindex)
    {
        struct bpf_devmap_val devmap_val = { .ifindex = redirect_ifindex };
        int ret;

        ret = bpf_map_update_elem(bpf_map__fd(forward_map), &ifindex, &devmap_val, 0);
        if (ret < 0) {
            fprintf(stderr, "Failed to update devmap_ value: %s\n",
                strerror(errno));
        }
        return ret;
    }

Tài liệu tham khảo
==================

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ