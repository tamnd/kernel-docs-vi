.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/page_pool.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Nhóm trang API
==============

.. kernel-doc:: include/net/page_pool/helpers.h
   :doc: page_pool allocator

Tổng quan về kiến ​​trúc
========================

.. code-block:: none

    +------------------+
    |       Driver     |
    +------------------+
            ^
            |
            |
            |
            v
    +--------------------------------------------+
    |                request memory              |
    +--------------------------------------------+
        ^                                  ^
        |                                  |
        | Pool empty                       | Pool has entries
        |                                  |
        v                                  v
    +-----------------------+     +------------------------+
    | alloc (and map) pages |     |  get page from cache   |
    +-----------------------+     +------------------------+
                                    ^                    ^
                                    |                    |
                                    | cache available    | No entries, refill
                                    |                    | from ptr-ring
                                    |                    |
                                    v                    v
                          +-----------------+     +------------------+
                          |   Fast cache    |     |  ptr-ring cache  |
                          +-----------------+     +------------------+

Giám sát
==========
Thông tin về nhóm trang trên hệ thống có thể được truy cập thông qua netdev
họ Genetlink (xem Tài liệu/netlink/specs/netdev.yaml).

Giao diện API
=============
Số lượng nhóm được tạo ZZ0000ZZ khớp với số lượng hàng đợi phần cứng
trừ khi những hạn chế về phần cứng khiến điều đó là không thể. Điều này nếu không sẽ đánh bại
mục đích của nhóm trang, phân bổ các trang nhanh chóng từ bộ đệm mà không cần khóa.
Sự đảm bảo không khóa này đương nhiên xuất phát từ việc chạy dưới phần mềm NAPI.
Sự bảo vệ không nhất thiết phải là NAPI, mọi đảm bảo rằng việc phân bổ
một trang sẽ không có điều kiện chủng tộc là đủ.

.. kernel-doc:: net/core/page_pool.c
   :identifiers: page_pool_create

.. kernel-doc:: include/net/page_pool/types.h
   :identifiers: struct page_pool_params

.. kernel-doc:: include/net/page_pool/helpers.h
   :identifiers: page_pool_put_page page_pool_put_full_page
		 page_pool_recycle_direct page_pool_free_va
		 page_pool_dev_alloc_pages page_pool_dev_alloc_frag
		 page_pool_dev_alloc page_pool_dev_alloc_va
		 page_pool_get_dma_addr page_pool_get_dma_dir

.. kernel-doc:: net/core/page_pool.c
   :identifiers: page_pool_put_page_bulk page_pool_get_stats

Đồng bộ hóa DMA
---------------
Driver luôn chịu trách nhiệm đồng bộ các trang cho CPU.
Trình điều khiển cũng có thể chọn đảm nhận việc đồng bộ hóa cho thiết bị
hoặc đặt cờ ZZ0000ZZ để yêu cầu các trang đó
được phân bổ từ nhóm trang đã được đồng bộ hóa cho thiết bị.

Nếu ZZ0000ZZ được đặt, trình điều khiển phải thông báo cho lõi phần nào
của bộ đệm phải được đồng bộ hóa. Điều này cho phép lõi tránh đồng bộ hóa toàn bộ
trang khi trình điều khiển biết rằng thiết bị chỉ truy cập một phần của trang.

Hầu hết người lái xe sẽ dành khoảng không phía trước khung. Phần này
của bộ đệm không được thiết bị chạm vào, do đó để tránh đồng bộ hóa
trình điều khiển của nó có thể đặt trường ZZ0000ZZ trong struct page_pool_params
một cách thích hợp.

Đối với các trang được tái chế trên đường dẫn XDP xmit và skb, nhóm trang sẽ
sử dụng thành viên ZZ0000ZZ của struct page_pool_params để quyết định cách thức
phần lớn trang cần được đồng bộ hóa (bắt đầu từ ZZ0001ZZ).
Khi giải phóng trực tiếp các trang trong trình điều khiển (page_pool_put_page())
đối số ZZ0002ZZ chỉ định lượng bộ đệm cần
để được đồng bộ hóa.

Nếu nghi ngờ, hãy đặt ZZ0000ZZ thành 0, ZZ0001ZZ thành ZZ0002ZZ và
chuyển -1 thành ZZ0003ZZ. Sự kết hợp các lập luận đó luôn luôn
đúng.

Lưu ý rằng các tham số đồng bộ hóa dành cho toàn bộ trang.
Điều quan trọng cần nhớ khi sử dụng các đoạn (ZZ0000ZZ),
nơi bộ đệm được phân bổ có thể nhỏ hơn toàn bộ trang.
Trừ khi tác giả trình điều khiển thực sự hiểu nội bộ nhóm trang
bạn nên luôn sử dụng ZZ0001ZZ, ZZ0002ZZ
với các nhóm trang bị phân mảnh.

Thống kê API và cấu trúc
------------------------
Nếu kernel được cấu hình với ZZ0000ZZ, API
page_pool_get_stats() và các cấu trúc được mô tả bên dưới đều có sẵn.
Nó lấy một con trỏ tới ZZ0001ZZ và một con trỏ tới một cấu trúc
page_pool_stats do người gọi phân bổ.

Trình điều khiển cũ hơn hiển thị số liệu thống kê nhóm trang thông qua ethtool hoặc debugfs.
Các số liệu thống kê tương tự có thể được truy cập thông qua họ netlink netdev
theo kiểu không phụ thuộc vào người lái.

.. kernel-doc:: include/net/page_pool/types.h
   :identifiers: struct page_pool_recycle_stats
		 struct page_pool_alloc_stats
		 struct page_pool_stats

Ví dụ mã hóa
===============

Sự đăng ký
------------

.. code-block:: c

    /* Page pool registration */
    struct page_pool_params pp_params = { 0 };
    struct xdp_rxq_info xdp_rxq;
    int err;

    pp_params.order = 0;
    /* internal DMA mapping in page_pool */
    pp_params.flags = PP_FLAG_DMA_MAP;
    pp_params.pool_size = DESC_NUM;
    pp_params.nid = NUMA_NO_NODE;
    pp_params.dev = priv->dev;
    pp_params.napi = napi; /* only if locking is tied to NAPI */
    pp_params.dma_dir = xdp_prog ? DMA_BIDIRECTIONAL : DMA_FROM_DEVICE;
    page_pool = page_pool_create(&pp_params);

    err = xdp_rxq_info_reg(&xdp_rxq, ndev, 0);
    if (err)
        goto err_out;

    err = xdp_rxq_info_reg_mem_model(&xdp_rxq, MEM_TYPE_PAGE_POOL, page_pool);
    if (err)
        goto err_out;

Máy thăm dò NAPI
----------------


.. code-block:: c

    /* NAPI Rx poller */
    enum dma_data_direction dma_dir;

    dma_dir = page_pool_get_dma_dir(dring->page_pool);
    while (done < budget) {
        if (some error)
            page_pool_recycle_direct(page_pool, page);
        if (packet_is_xdp) {
            if XDP_DROP:
                page_pool_recycle_direct(page_pool, page);
        } else (packet_is_skb) {
            skb_mark_for_recycle(skb);
            new_page = page_pool_dev_alloc_pages(page_pool);
        }
    }

Thống kê
--------

.. code-block:: c

	#ifdef CONFIG_PAGE_POOL_STATS
	/* retrieve stats */
	struct page_pool_stats stats = { 0 };
	if (page_pool_get_stats(page_pool, &stats)) {
		/* perhaps the driver reports statistics with ethool */
		ethtool_print_allocation_stats(&stats.alloc_stats);
		ethtool_print_recycle_stats(&stats.recycle_stats);
	}
	#endif

Dỡ bỏ trình điều khiển
----------------------

.. code-block:: c

    /* Driver unload */
    page_pool_put_full_page(page_pool, page, false);
    xdp_rxq_info_unreg(&xdp_rxq);