.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netfilter-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Các biến Netfilter Sysfs
=========================

/proc/sys/net/netfilter/* Các biến:
====================================

nf_log_all_netns - BOOLEAN
	- 0 - bị vô hiệu hóa (mặc định)
	- không phải 0 - đã bật

Theo mặc định, chỉ không gian tên init_net mới có thể ghi các gói vào nhật ký kernel
	với mục tiêu LOG; điều này nhằm mục đích ngăn chặn các container làm ngập máy chủ
	nhật ký hạt nhân. Nếu được bật, mục tiêu này cũng hoạt động trong mạng khác
	không gian tên. Biến này chỉ có thể truy cập được từ init_net.