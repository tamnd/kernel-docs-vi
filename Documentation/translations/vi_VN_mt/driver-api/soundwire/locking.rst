.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/soundwire/locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Khóa SoundWire
=================

Tài liệu này giải thích cơ chế khóa của SoundWire Bus. Sử dụng xe buýt
theo các khóa để tránh tình trạng chạy đua trong hoạt động Xe buýt trên
tài nguyên được chia sẻ.

- Khóa xe buýt

- Khóa tin nhắn

Khóa xe buýt
========

Khóa Bus SoundWire là một mutex và là một phần của cấu trúc dữ liệu Bus
(sdw_bus) được sử dụng cho mọi phiên bản Bus. Khóa này dùng để
tuần tự hóa từng hoạt động sau trong phiên bản SoundWire Bus.

- Thêm và xóa (các) Slave, thay đổi trạng thái Slave.

- Chuẩn bị, kích hoạt, vô hiệu hóa và hủy chuẩn bị các hoạt động truyền phát.

- Truy cập cấu trúc dữ liệu Stream.

Khóa tin nhắn
============

Khóa chuyển tin nhắn SoundWire. Mutex này là một phần của
Cấu trúc dữ liệu xe buýt (sdw_bus). Khóa này được sử dụng để tuần tự hóa tin nhắn
truyền (đọc/ghi) trong phiên bản SoundWire Bus.

Các ví dụ dưới đây cho thấy cách lấy được khóa.

Ví dụ 1
---------

Chuyển tin nhắn.

1. Đối với mỗi lần chuyển tin nhắn

Một. Có được khóa tin nhắn.

b. Truyền tin nhắn (Đọc/Ghi) sang Slave1 hoặc phát tin nhắn trên
        Xe buýt trong trường hợp chuyển đổi ngân hàng.

c. Mở khóa tin nhắn

     ::

+----------+ +----------+
	ZZ0000ZZ ZZ0001ZZ
	ZZ0002ZZ ZZ0003ZZ
	ZZ0004ZZ ZZ0005ZZ
	ZZ0006ZZ ZZ0007ZZ
	+----+------+ +----+----+
	     ZZ0008ZZ
	     ZZ0009ZZ
	     <-------------------------------+ a. Nhận khóa tin nhắn
	     ZZ0010ZZ b. Chuyển tin nhắn
	     ZZ0011ZZ
	     +------------------------------->c. Mở khóa tin nhắn
	     ZZ0012ZZ d. Trả về thành công/lỗi
	     ZZ0013ZZ
	     + +

Ví dụ 2
---------

Chuẩn bị hoạt động.

1. Lấy khóa cho phiên bản Bus được liên kết với Master 1.

2. Đối với mỗi lần truyền tin nhắn trong thao tác Chuẩn bị

Một. Có được khóa tin nhắn.

b. Truyền tin nhắn (Đọc/Ghi) sang Slave1 hoặc phát tin nhắn trên
        Xe buýt trong trường hợp chuyển đổi ngân hàng.

c. Mở khóa tin nhắn.

3. Khóa nhả cho phiên bản Bus được liên kết với Master 1 ::

+----------+ +----------+
	ZZ0000ZZ ZZ0001ZZ
	ZZ0002ZZ ZZ0003ZZ
	ZZ0004ZZ ZZ0005ZZ
	ZZ0006ZZ ZZ0007ZZ
	+----+------+ +----+----+
	     ZZ0008ZZ
	     ZZ0009ZZ
	     <-------------------------------+ 1. Lấy khóa xe buýt
	     ZZ0010ZZ 2. Thực hiện chuẩn bị luồng
	     ZZ0011ZZ
	     ZZ0012ZZ
	     ZZ0013ZZ
	     <-------------------------------+ a. Nhận khóa tin nhắn
	     ZZ0014ZZ b. Chuyển tin nhắn
	     ZZ0015ZZ
	     +------------------------------->c. Mở khóa tin nhắn
	     ZZ0016ZZ d. Trả về thành công/lỗi
	     ZZ0017ZZ
	     ZZ0018ZZ
	     ZZ0019ZZ 3. Mở khóa xe buýt
	     +-------------------------------> 4. Trả về thành công/lỗi
	     ZZ0020ZZ
	     + +
