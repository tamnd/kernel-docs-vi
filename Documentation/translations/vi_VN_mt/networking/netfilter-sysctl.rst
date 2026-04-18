.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netfilter-sysctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

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