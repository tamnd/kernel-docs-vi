.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/80211/mac80211-advanced.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
hệ thống con mac80211 (nâng cao)
=============================

Thông tin trong phần này của cuốn sách chỉ được quan tâm
để tương tác nâng cao của mac80211 với trình điều khiển để khai thác thêm
khả năng phần cứng và cải thiện hiệu suất.

Hỗ trợ LED
===========

Mac80211 hỗ trợ nhiều cách nhấp nháy đèn LED khác nhau. Bất cứ nơi nào có thể,
đèn LED của thiết bị phải được hiển thị dưới dạng thiết bị lớp LED và được nối với
kích hoạt thích hợp, sau đó sẽ được kích hoạt một cách thích hợp bởi
mac80211.

.. kernel-doc:: include/net/mac80211.h
   :functions:
	ieee80211_get_tx_led_name
	ieee80211_get_rx_led_name
	ieee80211_get_assoc_led_name
	ieee80211_get_radio_led_name
	ieee80211_tpt_blink
	ieee80211_tpt_led_trigger_flags
	ieee80211_create_tpt_led_trigger

Tăng tốc tiền điện tử phần cứng
============================

.. kernel-doc:: include/net/mac80211.h
   :doc: Hardware crypto acceleration

.. kernel-doc:: include/net/mac80211.h
   :functions:
	set_key_cmd
	ieee80211_key_conf
	ieee80211_key_flags
	ieee80211_get_tkip_p1k
	ieee80211_get_tkip_p1k_iv
	ieee80211_get_tkip_p2k

Hỗ trợ tiết kiệm điện
=================

.. kernel-doc:: include/net/mac80211.h
   :doc: Powersave support

Hỗ trợ bộ lọc đèn hiệu
=====================

.. kernel-doc:: include/net/mac80211.h
   :doc: Beacon filter support

.. kernel-doc:: include/net/mac80211.h
   :functions: ieee80211_beacon_loss

Nhiều hàng đợi và hỗ trợ QoS
===============================

TBD

.. kernel-doc:: include/net/mac80211.h
   :functions: ieee80211_tx_queue_params

Hỗ trợ chế độ điểm truy cập
=========================

TBD

Thay vào đó, một số phần của if_conf nên được thảo luận ở đây

Chèn ghi chú về giao diện VLAN với hw crypto tại đây hoặc trong hw
chương mật mã.

hỗ trợ khách hàng tiết kiệm điện
-------------------------------

.. kernel-doc:: include/net/mac80211.h
   :doc: AP support for powersaving clients

.. kernel-doc:: include/net/mac80211.h
   :functions:
	ieee80211_get_buffered_bc
	ieee80211_beacon_get
	ieee80211_sta_eosp
	ieee80211_frame_release_type
	ieee80211_sta_ps_transition
	ieee80211_sta_ps_transition_ni
	ieee80211_sta_set_buffered
	ieee80211_sta_block_awake

Hỗ trợ nhiều giao diện ảo
======================================

TBD

Lưu ý: WDS có địa chỉ MAC giống hệt nhau hầu như luôn ổn

Chèn ghi chú về việc có nhiều giao diện ảo với MAC khác nhau
địa chỉ ở đây, lưu ý cấu hình nào được mac80211 hỗ trợ, thêm
lưu ý về việc hỗ trợ tiền điện tử với nó.

.. kernel-doc:: include/net/mac80211.h
   :functions:
	ieee80211_iterate_active_interfaces
	ieee80211_iterate_active_interfaces_atomic

Xử lý trạm
================

TODO

.. kernel-doc:: include/net/mac80211.h
   :functions:
	ieee80211_sta
	sta_notify_cmd
	ieee80211_find_sta
	ieee80211_find_sta_by_ifaddr

Giảm tải quét phần cứng
=====================

TBD

.. kernel-doc:: include/net/mac80211.h
   :functions: ieee80211_scan_completed

Tổng hợp
===========

Tổng hợp TX A-MPDU
---------------------

.. kernel-doc:: net/mac80211/agg-tx.c
   :doc: TX A-MPDU aggregation

.. WARNING: DOCPROC directive not supported: !Cnet/mac80211/agg-tx.c

Tổng hợp RX A-MPDU
---------------------

.. kernel-doc:: net/mac80211/agg-rx.c
   :doc: RX A-MPDU aggregation

.. WARNING: DOCPROC directive not supported: !Cnet/mac80211/agg-rx.c

.. kernel-doc:: include/net/mac80211.h
   :functions: ieee80211_ampdu_mlme_action

Tiết kiệm năng lượng ghép kênh không gian (SMPS)
=====================================

.. kernel-doc:: include/net/mac80211.h
   :doc: Spatial multiplexing power save

.. kernel-doc:: include/net/mac80211.h
   :functions:
	ieee80211_request_smps
	ieee80211_smps_mode

TBD

Phần này của cuốn sách mô tả giao diện thuật toán điều khiển tốc độ và
nó liên quan như thế nào đến mac80211 và trình điều khiển.

Kiểm soát tỷ lệ API
================

TBD

.. kernel-doc:: include/net/mac80211.h
   :functions:
	ieee80211_start_tx_ba_session
	ieee80211_start_tx_ba_cb_irqsafe
	ieee80211_stop_tx_ba_session
	ieee80211_stop_tx_ba_cb_irqsafe
	ieee80211_rate_control_changed
	ieee80211_tx_rate_control

TBD

Phần này của cuốn sách mô tả nội bộ mac80211.

Xử lý chìa khóa
============

Thông tin cơ bản về xử lý khóa
-------------------

.. kernel-doc:: net/mac80211/key.c
   :doc: Key handling basics

MORE TBD
--------

TBD

Nhận xử lý
==================

TBD

Xử lý truyền
===================

TBD

Xử lý thông tin trạm
=====================

Thông tin lập trình
-----------------------

.. kernel-doc:: net/mac80211/sta_info.h
   :functions:
	sta_info
	ieee80211_sta_info_flags

Quy tắc trọn đời của thông tin STA
------------------------------

.. kernel-doc:: net/mac80211/sta_info.c
   :doc: STA information lifetime rules

Hàm tổng hợp
=====================

.. kernel-doc:: net/mac80211/sta_info.h
   :functions:
	sta_ampdu_mlme
	tid_ampdu_tx
	tid_ampdu_rx

Chức năng đồng bộ hóa
=========================

TBD

Đang khóa, rất nhiều RCU
