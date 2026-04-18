.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/linux-notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. contents::
.. sectnum::

=============================
Ghi chú triển khai Linux
==========================

Tài liệu này cung cấp thêm chi tiết cụ thể về việc triển khai nhân Linux của tập lệnh eBPF.

Hướng dẫn hoán đổi byte
======================

ZZ0000ZZ và ZZ0001ZZ tồn tại dưới dạng bí danh tương ứng cho ZZ0002ZZ và ZZ0003ZZ.

Hướng dẫn nhảy
=================

ZZ0000ZZ (0x8d), trong đó chức năng trợ giúp
số nguyên sẽ được đọc từ một thanh ghi được chỉ định, hiện không được hỗ trợ
bởi người xác minh.  Bất kỳ chương trình nào có hướng dẫn này sẽ không tải được
cho đến khi hỗ trợ đó được thêm vào.

Bản đồ
====

Linux chỉ hỗ trợ thao tác 'map_val(map)' trên bản đồ mảng với một phần tử duy nhất.

Linux sử dụng fd_array để lưu trữ các bản đồ được liên kết với chương trình BPF. Như vậy,
map_by_idx(imm) sử dụng fd tại chỉ mục đó trong mảng.

Biến
=========

Lệnh tức thời 64 bit sau đây chỉ định rằng một địa chỉ biến,
tương ứng với một số số nguyên được lưu trữ trong trường 'imm', nên được tải:

=============================== === =========================================================================
xây dựng opcode opcode src mã giả loại imm loại dst
=============================== === =========================================================================
BPF_IMM ZZ0000ZZ BPF_LD 0x18 0x3 dst = var_addr(imm) con trỏ dữ liệu id biến đổi
=============================== === =========================================================================

Trên Linux, số nguyên này là ID BTF.

Hướng dẫn truy cập gói BPF kế thừa
=====================================

Như đã đề cập trong ZZ0000ZZ,
Linux có các hướng dẫn eBPF đặc biệt để truy cập vào dữ liệu gói đã được
được chuyển từ BPF cổ điển để duy trì hiệu suất của ổ cắm cũ
các bộ lọc đang chạy trong trình thông dịch eBPF.

Hướng dẫn có hai dạng: ZZ0000ZZ và
ZZ0001ZZ.

Các lệnh này được sử dụng để truy cập dữ liệu gói và chỉ có thể được sử dụng khi
bối cảnh chương trình là một con trỏ tới gói mạng.  ZZ0000ZZ
truy cập dữ liệu gói ở độ lệch tuyệt đối được chỉ định bởi dữ liệu ngay lập tức
và ZZ0001ZZ truy cập dữ liệu gói ở độ lệch bao gồm giá trị của
một thanh ghi bên cạnh dữ liệu tức thời.

Các hướng dẫn này có bảy toán hạng ngầm định:

* Thanh ghi R6 là một đầu vào ẩn phải chứa một con trỏ tới một
  cấu trúc sk_buff.
* Thanh ghi R0 là đầu ra ẩn chứa dữ liệu được lấy từ
  gói tin.
* Các thanh ghi R1-R5 là các thanh ghi thô bị ghi đè bởi
  hướng dẫn.

Các hướng dẫn này cũng có điều kiện thoát chương trình ngầm. Nếu một
Chương trình eBPF cố gắng truy cập dữ liệu vượt quá ranh giới gói,
việc thực hiện chương trình sẽ bị hủy bỏ.

ZZ0000ZZ (0x20) có nghĩa là::

R0 = ntohl(ZZ0000ZZ) ((struct sk_buff *) R6->data + imm))

trong đó ZZ0000ZZ chuyển đổi giá trị 32 bit từ thứ tự byte mạng sang thứ tự byte máy chủ.

ZZ0000ZZ (0x40) có nghĩa là::

R0 = ntohl(ZZ0000ZZ) ((struct sk_buff *) R6->data + src + imm))
