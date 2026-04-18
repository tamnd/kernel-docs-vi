.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/kapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
API mạng và thiết bị mạng Linux
=============================================

Mạng Linux
================

Các loại cơ sở mạng
---------------------

.. kernel-doc:: include/linux/net.h
   :internal:

Chức năng đệm ổ cắm
-----------------------

.. kernel-doc:: include/linux/skbuff.h
   :internal:

.. kernel-doc:: include/net/sock.h
   :internal:

.. kernel-doc:: net/socket.c
   :export:

.. kernel-doc:: net/core/skbuff.c
   :export:

.. kernel-doc:: net/core/sock.c
   :export:

.. kernel-doc:: net/core/datagram.c
   :export:

.. kernel-doc:: net/core/stream.c
   :export:

Bộ lọc ổ cắm
-------------

.. kernel-doc:: net/core/filter.c
   :export:

Thống kê mạng chung
--------------------------

.. kernel-doc:: include/uapi/linux/gen_stats.h
   :internal:

.. kernel-doc:: net/core/gen_stats.c
   :export:

.. kernel-doc:: net/core/gen_estimator.c
   :export:

Hệ thống con SUN RPC
-----------------

.. kernel-doc:: net/sunrpc/xdr.c
   :export:

.. kernel-doc:: net/sunrpc/svc_xprt.c
   :export:

.. kernel-doc:: net/sunrpc/xprt.c
   :export:

.. kernel-doc:: net/sunrpc/sched.c
   :export:

.. kernel-doc:: net/sunrpc/socklib.c
   :export:

.. kernel-doc:: net/sunrpc/stats.c
   :export:

.. kernel-doc:: net/sunrpc/rpc_pipe.c
   :export:

.. kernel-doc:: net/sunrpc/rpcb_clnt.c
   :export:

.. kernel-doc:: net/sunrpc/clnt.c
   :export:

Hỗ trợ thiết bị mạng
======================

Hỗ trợ trình điều khiển
--------------

.. kernel-doc:: net/core/dev.c
   :export:

.. kernel-doc:: net/ethernet/eth.c
   :export:

.. kernel-doc:: net/sched/sch_generic.c
   :export:

.. kernel-doc:: include/linux/etherdevice.h
   :internal:

.. kernel-doc:: include/linux/netdevice.h
   :internal:

.. kernel-doc:: include/net/net_shaper.h
   :internal:

Hỗ trợ PHY
-----------

.. kernel-doc:: drivers/net/phy/phy.c
   :export:

.. kernel-doc:: drivers/net/phy/phy.c
   :internal:

.. kernel-doc:: drivers/net/phy/phy-core.c
   :export:

.. kernel-doc:: drivers/net/phy/phy-c45.c
   :export:

.. kernel-doc:: include/linux/phy.h
   :internal:

.. kernel-doc:: drivers/net/phy/phy_device.c
   :export:

.. kernel-doc:: drivers/net/phy/phy_device.c
   :internal:

.. kernel-doc:: drivers/net/phy/mdio_bus.c
   :export:

.. kernel-doc:: drivers/net/phy/mdio_bus.c
   :internal:

PHYLINK
-------

PHYLINK giao diện trình điều khiển mạng truyền thống với PHYLIB, liên kết cố định,
  và các mô-đun SFF (ví dụ: SFP có thể cắm nóng) có thể chứa PHY.  PHYLINK
  cung cấp khả năng quản lý trạng thái liên kết và các chế độ liên kết.

.. kernel-doc:: include/linux/phylink.h
   :internal:

.. kernel-doc:: drivers/net/phy/phylink.c

Hỗ trợ SFP
-----------

.. kernel-doc:: drivers/net/phy/sfp-bus.c
   :internal:

.. kernel-doc:: include/linux/sfp.h
   :internal:

.. kernel-doc:: drivers/net/phy/sfp-bus.c
   :export:
