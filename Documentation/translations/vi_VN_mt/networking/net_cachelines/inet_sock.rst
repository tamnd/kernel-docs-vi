.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/net_cachelines/inet_sock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2023 Google LLC

==============================================
phân tích sử dụng đường dẫn nhanh cấu trúc inet_sock
==========================================

============================================== ==================== ===================== ==============================================================================================================
Loại Tên fastpath_tx_access fastpath_rx_access bình luận
============================================== ==================== ===================== ==============================================================================================================
struct sock sk read_mostly read_mostly tcp_init_buffer_space,tcp_init_transfer,tcp_finish_connect,tcp_connect,tcp_send_rcvq,tcp_send_syn_data
cấu trúc ipv6_pinfo* Pinet6
cấu trúc ipv6_fl_socklist* ipv6_fl_list read_mostly tcp_v6_connect,__ip6_datagram_connect,udpv6_sendmsg,rawv6_sendmsg
be16 inet_sport read_mostly __tcp_transmit_skb
be32 inet_daddr read_mostly ip_select_ident_segs
be32 inet_rcv_saddr
be16 inet_dport read_mostly __tcp_transmit_skb
u16 inet_num
be32 inet_saddr
s16 uc_ttl đọc_chủ yếu __ip_queue_xmit/ip_select_ttl
u16 cmsg_flags
struct ip_options_rcu* inet_opt read_mostly __ip_queue_xmit
u16 inet_id read_mostly ip_select_ident_segs
u8 tos read_mostly ip_queue_xmit
u8 phút_ttl
u8 mc_ttl
u8 chiềutudisc
khôi phục u8:1
u8:1 is_icsk
liên kết tự do u8:1
u8:1 hdrincl
u8:1 mc_loop
u8:1 trong suốt
u8:1 mc_all
phân đoạn nút u8:1
u8:1 bind_address_no_port
u8:1 recverr_rfc4884
u8:1 defer_connect read_mostly tcp_sendmsg_fastopen
u8 rcv_tos
u8 chuyển đổi_csum
int uc_index
int mc_index
be32 mc_addr
cấu trúc ip_mc_socklist* mc_list
struct inet_cork_full cork read_mostly __tcp_transmit_skb
cấu trúc local_port_range
============================================== ==================== ===================== ==============================================================================================================