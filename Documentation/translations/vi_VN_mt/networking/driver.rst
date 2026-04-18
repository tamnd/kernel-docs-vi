.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Sự cố trình điều khiển Softnet
=====================

Hướng dẫn thăm dò
==================

Xác thực địa chỉ
------------------

Bất kỳ địa chỉ lớp phần cứng nào bạn có được cho thiết bị của mình đều phải
được xác minh.  Ví dụ: đối với ethernet, hãy kiểm tra nó với
linux/etherdevice.h:is_valid_ether_addr()

Hướng dẫn đóng/dừng
=====================

Im lặng
----------

Sau khi thủ tục ndo_stop được gọi, phần cứng phải
không nhận hoặc truyền bất kỳ dữ liệu nào.  Tất cả các gói trong chuyến bay phải
bị hủy bỏ. Nếu cần thiết, hãy thăm dò ý kiến hoặc chờ hoàn thành
bất kỳ lệnh đặt lại nào.

Tự động đóng
----------

Thói quen ndo_stop sẽ được gọi bởi unregister_netdevice
nếu thiết bị vẫn LÊN.

Hướng dẫn đường truyền
========================

Dừng xếp hàng trước
----------------------

Phương thức ndo_start_xmit không được trả về NETDEV_TX_BUSY trong
mọi trường hợp bình thường.  Nó được coi là một lỗi cứng trừ khi
không có cách nào thiết bị của bạn có thể biết trước khi nào nó
chức năng truyền tải sẽ trở nên bận rộn.

Thay vào đó nó phải duy trì hàng đợi đúng cách.  Ví dụ,
đối với trình điều khiển triển khai thu thập phân tán, điều này có nghĩa là:

.. code-block:: c

	static u32 drv_tx_avail(struct drv_ring *dr)
	{
		u32 used = READ_ONCE(dr->prod) - READ_ONCE(dr->cons);

		return dr->tx_ring_size - (used & bp->tx_ring_mask);
	}

	static netdev_tx_t drv_hard_start_xmit(struct sk_buff *skb,
					       struct net_device *dev)
	{
		struct drv *dp = netdev_priv(dev);
		struct netdev_queue *txq;
		struct drv_ring *dr;
		int idx;

		idx = skb_get_queue_mapping(skb);
		dr = dp->tx_rings[idx];
		txq = netdev_get_tx_queue(dev, idx);

		//...
		/* This should be a very rare race - log it. */
		if (drv_tx_avail(dr) <= skb_shinfo(skb)->nr_frags + 1) {
			netif_stop_queue(dev);
			netdev_warn(dev, "Tx Ring full when queue awake!\n");
			return NETDEV_TX_BUSY;
		}

		//... queue packet to card ...

		netdev_tx_sent_queue(txq, skb->len);

		//... update tx producer index using WRITE_ONCE() ...

		if (!netif_txq_maybe_stop(txq, drv_tx_avail(dr),
					  MAX_SKB_FRAGS + 1, 2 * MAX_SKB_FRAGS))
			dr->stats.stopped++;

		//...
		return NETDEV_TX_OK;
	}

Và sau đó khi kết thúc quá trình xử lý sự kiện thu hồi TX của bạn:

.. code-block:: c

	//... update tx consumer index using WRITE_ONCE() ...

	netif_txq_completed_wake(txq, cmpl_pkts, cmpl_bytes,
				 drv_tx_avail(dr), 2 * MAX_SKB_FRAGS);

Macro trợ giúp dừng/đánh thức hàng đợi không khóa
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/net/netdev_queues.h
   :doc: Lockless queue stopping / waking helpers.

Không có quyền sở hữu độc quyền
----------------------

Phương thức ndo_start_xmit không được sửa đổi các phần được chia sẻ của
nhân bản SKB.

Hoàn thành kịp thời
------------------

Đừng quên rằng khi bạn trả lại NETDEV_TX_OK từ
ndo_start_xmit, tài xế của bạn có trách nhiệm giải phóng
nâng cấp SKB và trong một khoảng thời gian hữu hạn.

Ví dụ: điều này có nghĩa là nó không được phép đối với TX của bạn
kế hoạch giảm nhẹ để cho phép các gói TX "đi chơi" trong TX
đổ chuông mãi mãi không được nhận lại nếu không có gói TX mới nào được gửi.
Lỗi này có thể gây bế tắc ổ cắm đang chờ gửi phòng đệm
để được giải thoát.

Nếu bạn trả về NETDEV_TX_BUSY từ phương thức ndo_start_xmit, bạn
không được giữ bất kỳ tham chiếu nào đến SKB đó và bạn không được thử
để giải phóng nó.