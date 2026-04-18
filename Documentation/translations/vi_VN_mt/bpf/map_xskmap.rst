.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/map_xskmap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2022 Red Hat, Inc.

=====================
BPF_MAP_TYPE_XSKMAP
===================

.. note::
   - ``BPF_MAP_TYPE_XSKMAP`` was introduced in kernel version 4.18

ZZ0000ZZ được sử dụng làm bản đồ phụ trợ cho người trợ giúp XDP BPF
gọi hành động ZZ0001ZZ và ZZ0002ZZ, như 'devmap' và 'cpumap'.
Loại bản đồ này chuyển hướng các khung XDP thô sang các ổ cắm ZZ0003ZZ (XSK), một loại mới
Họ địa chỉ trong kernel cho phép chuyển hướng các khung từ trình điều khiển sang
không gian người dùng mà không cần phải duyệt qua toàn bộ ngăn xếp mạng. Ổ cắm AF_XDP
liên kết với một hàng đợi netdev duy nhất. Ánh xạ XSK tới hàng đợi được hiển thị bên dưới:

.. code-block:: none

    +---------------------------------------------------+
    |     xsk A      |     xsk B       |      xsk C     |<---+ User space
    =========================================================|==========
    |    Queue 0     |     Queue 1     |     Queue 2    |    |  Kernel
    +---------------------------------------------------+    |
    |                  Netdev eth0                      |    |
    +---------------------------------------------------+    |
    |                            +=============+        |    |
    |                            | key |  xsk  |        |    |
    |  +---------+               +=============+        |    |
    |  |         |               |  0  | xsk A |        |    |
    |  |         |               +-------------+        |    |
    |  |         |               |  1  | xsk B |        |    |
    |  | BPF     |-- redirect -->+-------------+-------------+
    |  | prog    |               |  2  | xsk C |        |
    |  |         |               +-------------+        |
    |  |         |                                      |
    |  |         |                                      |
    |  +---------+                                      |
    |                                                   |
    +---------------------------------------------------+

.. note::
    An AF_XDP socket that is bound to a certain <netdev/queue_id> will *only*
    accept XDP frames from that <netdev/queue_id>. If an XDP program tries to redirect
    from a <netdev/queue_id> other than what the socket is bound to, the frame will
    not be received on the socket.

Thông thường, XSKMAP được tạo cho mỗi netdev. Bản đồ này chứa một mảng Tệp XSK
Bộ mô tả (FD). Số lượng phần tử mảng thường được đặt hoặc điều chỉnh bằng cách sử dụng
tham số bản đồ ZZ0000ZZ. Đối với AF_XDP ZZ0001ZZ bằng số
hàng đợi được netdev hỗ trợ.

.. note::
    Both the map key and map value size must be 4 bytes.

Cách sử dụng
=====

Hạt nhân BPF
----------
bpf_redirect_map()
^^^^^^^^^^^^^^^^^^
.. code-block:: c

    long bpf_redirect_map(struct bpf_map *map, u32 key, u64 flags)

Chuyển hướng gói đến điểm cuối được tham chiếu bởi ZZ0000ZZ tại chỉ mục ZZ0001ZZ.
Đối với ZZ0002ZZ, bản đồ này chứa các tham chiếu đến XSK FD
cho các ổ cắm được gắn vào hàng đợi của netdev.

.. note::
    If the map is empty at an index, the packet is dropped. This means that it is
    necessary to have an XDP program loaded with at least one XSK in the
    XSKMAP to be able to get any traffic to user space through the socket.

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    void *bpf_map_lookup_elem(struct bpf_map *map, const void *key)

Có thể truy xuất các tham chiếu mục nhập XSK thuộc loại ZZ0000ZZ bằng cách sử dụng
Người trợ giúp ZZ0001ZZ.

Không gian người dùng
----------
.. note::
    XSK entries can only be updated/deleted from user space and not from
    a BPF program. Trying to call these functions from a kernel BPF program will
    result in the program failing to load and a verifier warning.

bpf_map_update_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

	int bpf_map_update_elem(int fd, const void *key, const void *value, __u64 flags)

Các mục XSK có thể được thêm hoặc cập nhật bằng ZZ0000ZZ
người giúp đỡ. Tham số ZZ0001ZZ bằng queue_id của hàng đợi XSK
đang gắn vào. Và tham số ZZ0002ZZ chính là giá trị FD của socket đó.

Dưới mui xe, chức năng cập nhật XSKMAP sử dụng giá trị XSK FD để truy xuất
phiên bản ZZ0000ZZ được liên kết.

Đối số flags có thể là một trong những đối số sau:

- BPF_ANY: Tạo phần tử mới hoặc cập nhật phần tử hiện có.
- BPF_NOEXIST: Chỉ tạo một phần tử mới nếu nó chưa tồn tại.
- BPF_EXIST: Cập nhật phần tử hiện có.

bpf_map_lookup_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_lookup_elem(int fd, const void *key, void *value)

Trả về ZZ0000ZZ hoặc lỗi âm trong trường hợp thất bại.

bpf_map_delete_elem()
^^^^^^^^^^^^^^^^^^^^^
.. code-block:: c

    int bpf_map_delete_elem(int fd, const void *key)

Các mục XSK có thể bị xóa bằng ZZ0000ZZ
người giúp đỡ. Trình trợ giúp này sẽ trả về 0 nếu thành công hoặc có lỗi âm trong trường hợp
thất bại.

.. note::
    When `libxdp`_ deletes an XSK it also removes the associated socket
    entry from the XSKMAP.

Ví dụ
========
hạt nhân
------

Đoạn mã sau đây cho thấy cách khai báo ZZ0000ZZ được gọi
ZZ0001ZZ và cách chuyển hướng gói đến XSK.

.. code-block:: c

	struct {
		__uint(type, BPF_MAP_TYPE_XSKMAP);
		__type(key, __u32);
		__type(value, __u32);
		__uint(max_entries, 64);
	} xsks_map SEC(".maps");


	SEC("xdp")
	int xsk_redir_prog(struct xdp_md *ctx)
	{
		__u32 index = ctx->rx_queue_index;

		if (bpf_map_lookup_elem(&xsks_map, &index))
			return bpf_redirect_map(&xsks_map, index, 0);
		return XDP_PASS;
	}

Không gian người dùng
----------

Đoạn mã sau đây cho biết cách cập nhật XSKMAP với mục nhập XSK.

.. code-block:: c

	int update_xsks_map(struct bpf_map *xsks_map, int queue_id, int xsk_fd)
	{
		int ret;

		ret = bpf_map_update_elem(bpf_map__fd(xsks_map), &queue_id, &xsk_fd, 0);
		if (ret < 0)
			fprintf(stderr, "Failed to update xsks_map: %s\n", strerror(errno));

		return ret;
	}

Để biết ví dụ về cách tạo ổ cắm AF_XDP, vui lòng xem ví dụ AF_XDP và
Các chương trình chuyển tiếp AF_XDP trong thư mục ZZ0000ZZ trong kho lưu trữ ZZ0001ZZ.
Để biết giải thích chi tiết về giao diện AF_XDP, vui lòng xem:

-ZZ0000ZZ.
- Tài liệu hạt nhân ZZ0001ZZ.

.. note::
    The most comprehensive resource for using XSKMAPs and AF_XDP is `libxdp`_.

.. _libxdp: https://github.com/xdp-project/xdp-tools/tree/master/lib/libxdp
.. _AF_XDP: https://www.kernel.org/doc/html/latest/networking/af_xdp.html
.. _bpf-examples: https://github.com/xdp-project/bpf-examples
.. _libxdp-readme: https://github.com/xdp-project/xdp-tools/tree/master/lib/libxdp#using-af_xdp-sockets