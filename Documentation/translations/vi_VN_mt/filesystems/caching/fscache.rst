.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/caching/fscache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Bộ nhớ đệm hệ thống tập tin chung
=================================

Tổng quan
=========

Cơ sở này là một bộ nhớ đệm có mục đích chung cho các hệ thống tập tin mạng, mặc dù nó
cũng có thể được sử dụng để lưu vào bộ nhớ đệm những thứ khác, chẳng hạn như hệ thống tệp ISO9660.

FS-Cache làm trung gian giữa các phần phụ trợ của bộ đệm (chẳng hạn như CacheFiles) và mạng
hệ thống tập tin::

+----------+
	ZZ0000ZZ +--------------+
	ZZ0001ZZ--+ ZZ0002ZZ
	ZZ0003ZZ ZZ0004ZZ CacheFS |
	+----------+ ZZ0005ZZ ZZ0006ZZ
	             ZZ0007ZZ ZZ0008ZZ +--------------+
	+----------+ +-------------->ZZ0009ZZ |
	ZZ0010ZZ +-------+ ZZ0011ZZ--+
	ZZ0012ZZ---->ZZ0013ZZ ZZ0014ZZ
	ZZ0015ZZ ZZ0016ZZ->ZZ0017ZZ--+
	+----------+ +-->ZZ0018ZZ ZZ0019ZZ |
	             ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ +--------------+
	+----------+ ZZ0023ZZ ZZ0024ZZ
	Tệp bộ đệm ZZ0025ZZ ZZ0026ZZ |
	ZZ0027ZZ--+ ZZ0028ZZ
	ZZ0029ZZ +--------------+
	+----------+

Hoặc nhìn theo cách khác, FS-Cache là một mô-đun cung cấp bộ nhớ đệm
tiện ích cho hệ thống tệp mạng sao cho bộ đệm trong suốt đối với
người dùng::

+----------+
	ZZ0000ZZ
	ZZ0001ZZ
	ZZ0002ZZ
	+----------+
	     |                  NETWORK
	~~~~|~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
	     |
	     |           +----------+
	     V ZZ0003ZZ
	+----------+ ZZ0004ZZ
	ZZ0005ZZ ZZ0006ZZ
	ZZ0007ZZ---->ZZ0008ZZ
	ZZ0009ZZ ZZ0010ZZ--+
	+----------+ ZZ0011ZZ |   +--------------+ +--------------+
	     ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ
	     V +----------+ +-->ZZ0016ZZ-->ZZ0017ZZ
	+----------+ ZZ0018ZZ ZZ0019ZZ
	ZZ0020ZZ +--------------+ +--------------+
	ZZ0021ZZ ^ ^
	ZZ0022ZZ ZZ0023ZZ
	+--------------+ +--------------+ |
	     ZZ0024ZZ |
	~~~~~ZZ0025ZZ~~~~~~|~~~~
	     ZZ0026ZZ |
	     V ZZ0027ZZ
	+--------------+ +--------------+
	ZZ0028ZZ ZZ0029ZZ
	ZZ0030ZZ ZZ0031ZZ
	ZZ0032ZZ ZZ0033ZZ
	+--------------+ +--------------+


FS-Cache không tuân theo ý tưởng tải hoàn toàn mọi tệp netfs
được mở toàn bộ vào bộ đệm trước khi cho phép truy cập và
sau đó phục vụ các trang từ bộ đệm đó thay vì inode netfs vì:

(1) Việc vận hành mà không cần bộ nhớ đệm phải thực tế.

(2) Kích thước của bất kỳ tệp có thể truy cập nào không được giới hạn ở kích thước của
     bộ đệm.

(3) Kích thước tổng hợp của tất cả các tệp đã mở (bao gồm các thư viện được ánh xạ)
     không được giới hạn kích thước của bộ đệm.

(4) Người dùng không nên bị buộc phải tải xuống toàn bộ tệp chỉ để thực hiện một thao tác
     quyền truy cập một lần vào một phần nhỏ của nó (chẳng hạn như có thể được thực hiện với
     chương trình "tập tin").

Thay vào đó, nó phục vụ bộ đệm theo từng khối khi được netfs yêu cầu
sử dụng nó.


FS-Cache cung cấp các tiện ích sau:

* Có thể sử dụng nhiều bộ đệm cùng một lúc.  Bộ nhớ đệm có thể được chọn
     rõ ràng bằng cách sử dụng các thẻ.

* Bộ nhớ đệm có thể được thêm/xóa bất cứ lúc nào, ngay cả khi đang được truy cập.

* Netfs được cung cấp một giao diện cho phép một trong hai bên
     rút các tiện ích bộ nhớ đệm khỏi một tệp (bắt buộc đối với (2)).

* Giao diện của netfs trả về càng ít lỗi càng tốt, ưu tiên
     thay vì để netfs không biết gì.

* Có ba loại cookie: cookie bộ đệm, khối lượng và tệp dữ liệu.
     Cookie bộ đệm đại diện cho toàn bộ bộ đệm và thường không hiển thị
     tới netfs; netfs nhận được một cookie khối lượng để thể hiện một bộ sưu tập
     các tập tin (thường là thứ mà netfs sẽ nhận được đối với siêu khối); và
     cookie tệp dữ liệu được sử dụng để lưu trữ dữ liệu vào bộ nhớ đệm (thứ gì đó có thể dành cho
     một nút).

* Các tập được khớp bằng cách sử dụng một phím.  Đây là một chuỗi có thể in được sử dụng
     để mã hóa tất cả thông tin có thể cần thiết để phân biệt một
     siêu khối, ví dụ, từ một người khác.  Đây sẽ là sự kết hợp của những thứ như
     tên ô hoặc địa chỉ máy chủ, tên ổ đĩa hoặc đường dẫn chia sẻ.  Nó phải là một
     tên đường dẫn hợp lệ.

* Cookie được khớp bằng khóa.  Đây là một đốm màu nhị phân và được sử dụng để
     đại diện cho đối tượng trong một tập (vì vậy phím âm lượng không cần phải tạo thành
     một phần của đốm màu).  Điều này có thể bao gồm những thứ như số inode và
     bộ xác định hoặc một trình xử lý tập tin.

* Tài nguyên cookie được thiết lập và ghim bằng cách đánh dấu cookie đang sử dụng.
     Điều này ngăn chặn các tài nguyên hỗ trợ bị loại bỏ.  rác hẹn giờ
     bộ sưu tập được sử dụng để loại bỏ các cookie chưa được sử dụng cho một
     trong thời gian ngắn, do đó làm giảm tình trạng quá tải tài nguyên.  Điều này dự định là
     được sử dụng khi một tập tin được mở hoặc đóng.

Một cookie có thể được đánh dấu đang sử dụng nhiều lần cùng một lúc; mỗi dấu hiệu
     phải không được sử dụng.

* Chức năng truy cập bắt đầu/kết thúc được cung cấp để trì hoãn việc rút bộ nhớ đệm cho
     thời gian hoạt động và ngăn không cho các cấu trúc được giải phóng trong khi
     chúng tôi đang nhìn vào họ.

* Dữ liệu I/O được thực hiện bởi DIO không đồng bộ đến/từ bộ đệm được mô tả bởi
     netfs bằng cách sử dụng iov_iter.

* Có sẵn cơ sở vô hiệu hóa để loại bỏ dữ liệu khỏi bộ đệm và
     để xử lý I/O đang được xử lý đang truy cập dữ liệu cũ.

* Cookie có thể bị "ngừng hoạt động" khi được phát hành, do đó khiến đối tượng bị
     bị xóa khỏi bộ đệm.


Có thể tìm thấy netfs API tới FS-Cache trong:

Tài liệu/hệ thống tập tin/bộ nhớ đệm/netfs-api.rst

Có thể tìm thấy phần phụ trợ bộ đệm API cho FS-Cache trong:

Tài liệu/hệ thống tập tin/bộ nhớ đệm/backend-api.rst


Thông tin thống kê
=======================

Nếu FS-Cache được biên dịch với các tùy chọn sau được bật::

CONFIG_FSCACHE_STATS=y

sau đó nó sẽ thu thập số liệu thống kê nhất định và hiển thị chúng thông qua:

/proc/fs/fscache/số liệu thống kê

Phần này hiển thị số lượng sự kiện có thể xảy ra trong FS-Cache:

+--------------+-------+-------------------------------------------------------+
ZZ0000ZZEVENT ZZ0001ZZ
+===============+========+=====================================================================================================
|Cookies       |n=N ZZ0003ZZ
+ +-------+---------------------------------------------------------- +
|              |v=N ZZ0005ZZ
+ +-------+---------------------------------------------------------- +
|              |vcol=N ZZ0007ZZ
+ +-------+---------------------------------------------------------- +
|              |voom=N ZZ0009ZZ
+--------------+-------+-------------------------------------------------------+
|Acquire       |n=N ZZ0011ZZ
+ +-------+---------------------------------------------------------- +
|              |ok=N ZZ0013ZZ
+ +-------+---------------------------------------------------------- +
|              |oom=N ZZ0015ZZ
+--------------+-------+-------------------------------------------------------+
|LRU           |n=N ZZ0017ZZ
+ +-------+---------------------------------------------------------- +
|              |exp=N ZZ0019ZZ
+ +-------+---------------------------------------------------------- +
|              |rmv=N ZZ0021ZZ
+ +-------+---------------------------------------------------------- +
|              |drp=N ZZ0023ZZ
+ +-------+---------------------------------------------------------- +
|              |at=N ZZ0025ZZ
+--------------+-------+-------------------------------------------------------+
|Invals        |n=N ZZ0027ZZ
+--------------+-------+-------------------------------------------------------+
|Updates       |n=N ZZ0029ZZ
+ +-------+---------------------------------------------------------- +
|              |rsz=N ZZ0031ZZ
+ +-------+---------------------------------------------------------- +
|              |rsn=N ZZ0033ZZ
+--------------+-------+-------------------------------------------------------+
|Relinqs       |n=N ZZ0035ZZ
+ +-------+---------------------------------------------------------- +
|              |rtr=N ZZ0037ZZ
+ +-------+---------------------------------------------------------- +
|              |drop=N ZZ0039ZZ
+--------------+-------+-------------------------------------------------------+
|NoSpace       |nwr=N ZZ0041ZZ
+ +-------+---------------------------------------------------------- +
|              |ncr=N ZZ0043ZZ
+ +-------+---------------------------------------------------------- +
|              |cull=N ZZ0045ZZ
+--------------+-------+-------------------------------------------------------+
|IO            |rd=N ZZ0047ZZ
+ +-------+---------------------------------------------------------- +
|              |wr=N ZZ0049ZZ
+--------------+-------+-------------------------------------------------------+

Netfslib cũng sẽ thêm một số bộ đếm số liệu thống kê của riêng nó.


Danh sách bộ đệm
================

FS-Cache cung cấp danh sách cookie bộ đệm:

/proc/fs/fscache/cookie

Điều này sẽ trông giống như::

# cat /proc/fs/fscache/cache
	CACHE REF VOLS OBJS ACCES S NAME
	============= ===== ===== ====== =================
	00000001 2 1 2123 1 Mặc định

nơi các cột ở:

======= =====================================================================
	COLUMN DESCRIPTION
	======= =====================================================================
	CACHE ID gỡ lỗi cookie bộ đệm (cũng xuất hiện trong dấu vết)
	REF Số lượng tham chiếu trên cookie bộ đệm
	VOLS Số lượng cookie trong bộ đệm này
	OBJS Số lượng đối tượng bộ nhớ đệm đang được sử dụng
	ACCES Số lượng truy cập ghim bộ đệm
	Trạng thái S
	NAME Tên của bộ đệm.
	======= =====================================================================

Trạng thái có thể là (-) Không hoạt động, (P) đang sửa chữa, (A) hoạt động, (E) lỗi hoặc (W) rút lui.


Danh sách tập
=============

FS-Cache cung cấp danh sách các cookie khối lượng:

/proc/fs/fscache/tập

Điều này sẽ trông giống như::

VOLUME REF nCOOK ACC FL CACHE KEY
	======== ===== ===== === ================= ==================
	00000001 55 54 1 00 afs mặc định,example.com,100058

nơi các cột ở:

======= =====================================================================
	COLUMN DESCRIPTION
	======= =====================================================================
	VOLUME ID gỡ lỗi cookie khối lượng (cũng xuất hiện trong dấu vết)
	REF Số lượng tài liệu tham khảo trên cookie khối lượng
	nCOOK Số lượng cookie trong ổ đĩa
	ACC Số lượng truy cập ghim bộ đệm
	Cờ FL trên cookie âm lượng
	CACHE Tên của bộ đệm hoặc "-"
	KEY Phím lập chỉ mục cho âm lượng
	======= =====================================================================


Danh sách cookie
================

FS-Cache cung cấp danh sách cookie:

/proc/fs/fscache/cookie

Điều này sẽ trông giống như::

# head /proc/fs/fscache/cookies
	COOKIE VOLUME REF ACT ACC S FL DEF
	======== ======== === === === = == =================
	00000435 00000001 1 0 -1 - 08 0000000201d0800700000000000000000, 00000000000000000
	00000436 00000001 1 0 -1 - 00 0000005601d0800800000000000000000, 0000000000000051
	00000437 00000001 1 0 -1 - 08 00023b3001d0823f00000000000000000, 00000000000000000
	00000438 00000001 1 0 -1 - 08 0000005801d0807b00000000000000000, 00000000000000000
	00000439 00000001 1 0 -1 - 08 00023b3201d080a100000000000000000, 0000000000000000
	0000043a 00000001 1 0 -1 - 08 00023b3401d080a300000000000000000, 0000000000000000
	0000043b 00000001 1 0 -1 - 08 00023b3601d080b300000000000000000, 0000000000000000
	0000043c 00000001 1 0 -1 - 08 00023b3801d080b400000000000000000, 0000000000000000

nơi các cột ở:

======= =====================================================================
	COLUMN DESCRIPTION
	======= =====================================================================
	COOKIE ID gỡ lỗi cookie (cũng xuất hiện trong dấu vết)
	VOLUME ID gỡ lỗi cookie khối lượng chính
	REF Số lượng tài liệu tham khảo trên cookie khối lượng
	ACT Số lần cookie được đánh dấu để sử dụng
	ACC Số lượng chân truy cập trong cookie
	S Trạng thái của cookie
	Cờ FL trên cookie
	DEF Key, dữ liệu phụ trợ
	======= =====================================================================


Gỡ lỗi
=========

Nếu CONFIG_NETFS_DEBUG được bật, cơ sở FS-Cache và hỗ trợ NETFS có thể
đã bật tính năng gỡ lỗi thời gian chạy bằng cách điều chỉnh giá trị trong::

/sys/mô-đun/netfs/tham số/gỡ lỗi

Đây là một bitmask của các luồng gỡ lỗi để kích hoạt:

============== ================================ ==========================
	BIT VALUE STREAM POINT
	============== ================================ ==========================
	0 1 Quản lý bộ nhớ đệm Dấu vết mục nhập chức năng
	1 2 Dấu vết thoát chức năng
	2 4 Tổng quát
	3 8 Quản lý cookie Dấu vết mục nhập chức năng
	4 16 Dấu vết thoát chức năng
	5 32 Tổng quát
	6-8 (Không sử dụng)
	9 512 Quản lý vận hành I/O Dấu vết mục nhập chức năng
	10 1024 Dấu vết thoát chức năng
	11 2048 Tổng hợp
	============== ================================ ==========================

Tập hợp các giá trị thích hợp phải được OR cùng nhau và kết quả được ghi vào
tập tin điều khiển.  Ví dụ::

echo $((1|8|512)) >/sys/module/netfs/parameters/debug

sẽ bật tất cả các mục gỡ lỗi chức năng.