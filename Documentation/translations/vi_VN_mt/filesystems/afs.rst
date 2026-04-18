.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/afs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
kAFS: AFS FILESYSTEM
====================

.. Contents:

 - Overview.
 - Usage.
 - Mountpoints.
 - Dynamic root.
 - Proc filesystem.
 - The cell database.
 - Security.
 - The @sys substitution.


Tổng quan
========

Hệ thống tệp này cung cấp trình điều khiển hệ thống tệp AFS an toàn khá đơn giản. Đó là
đang được phát triển và chưa cung cấp bộ tính năng đầy đủ.  các tính năng
nó hỗ trợ bao gồm:

(*) Bảo mật (hiện tại chỉ có vé AFS kaserver và KerberosIV).

(*) Đọc và ghi tập tin.

(*) Tự động gắn kết.

(*) Bộ nhớ đệm cục bộ (thông qua fscache).

Nó chưa hỗ trợ các tính năng AFS sau:

(*) lệnh gọi hệ thống pioctl().


biên soạn
===========

Hệ thống tập tin phải được kích hoạt bằng cách bật cấu hình kernel
tùy chọn::

CONFIG_AF_RXRPC - Vận chuyển giao thức RxRPC
	CONFIG_RXKAD - Trình xử lý bảo mật RxRPC Kerberos
	CONFIG_AFS_FS - Hệ thống tập tin AFS

Ngoài ra, có thể bật tính năng sau để hỗ trợ gỡ lỗi::

CONFIG_AF_RXRPC_DEBUG - Cho phép bật tính năng gỡ lỗi AF_RXRPC
	CONFIG_AFS_DEBUG - Cho phép bật tính năng gỡ lỗi AFS

Chúng cho phép bật các thông báo gỡ lỗi một cách linh hoạt bằng cách thao tác
các mặt nạ trong các tập tin sau::

/sys/module/af_rxrpc/tham số/gỡ lỗi
	/sys/module/kafs/tham số/gỡ lỗi


Cách sử dụng
=====

Khi chèn các mô-đun trình điều khiển, ô gốc phải được chỉ định cùng với một
danh sách địa chỉ IP của máy chủ vị trí khối lượng::

modprobe rxrpc
	modprobe kafs rootcell=cambridge.redhat.com:172.16.18.73:172.16.18.91

Mô-đun đầu tiên là trình điều khiển giao thức mạng AF_RXRPC.  Điều này cung cấp
Giao thức hoạt động từ xa RxRPC và cũng có thể được truy cập từ không gian người dùng.  Nhìn thấy:

Tài liệu/mạng/rxrpc.rst

Mô-đun thứ hai là trình điều khiển bảo mật kerberos RxRPC và mô-đun thứ ba
là trình điều khiển hệ thống tệp thực tế cho hệ thống tệp AFS.

Khi mô-đun đã được tải, có thể thêm nhiều mô-đun hơn bằng cách sau
thủ tục::

echo add grand.central.org 18.9.48.14:128.2.203.61:130.237.48.87 >/proc/fs/afs/cells

Trong đó các tham số của lệnh "thêm" là tên của một ô và danh sách các ô
máy chủ định vị khối trong ô đó, với ô sau được phân tách bằng dấu hai chấm.

Hệ thống tập tin có thể được gắn ở bất cứ đâu bằng các lệnh tương tự như sau ::

mount -t afs "%cambridge.redhat.com:root.afs." /afs
	mount -t afs "#cambridge.redhat.com:root.cell." /afs/cambridge
	gắn kết -t afs "#root.afs." /afs
	mount -t afs "#root.cell." /afs/cambridge

Trong đó ký tự đầu tiên là ký hiệu băm hoặc ký hiệu phần trăm tùy thuộc vào
liệu bạn có chắc chắn muốn âm lượng R/W (phần trăm) hay bạn muốn
Âm lượng R/O, nhưng sẵn sàng sử dụng âm lượng R/W thay thế (băm).

Tên của ổ đĩa có thể có hậu tố là ".backup" hoặc ".readonly" để
chỉ định kết nối với các ổ đĩa thuộc loại đó.

Tên của ô là tùy chọn và nếu không được cung cấp trong quá trình gắn kết thì
khối lượng được đặt tên sẽ được tra cứu trong ô được chỉ định trong quá trình modprobe.

Các ô bổ sung có thể được thêm thông qua /proc (xem phần sau).


Điểm gắn kết
===========

AFS có khái niệm về điểm gắn kết. Theo thuật ngữ AFS, chúng được định dạng đặc biệt
các liên kết tượng trưng (có cùng dạng với "tên thiết bị" được truyền cho mount).  kAFS
trình bày chúng cho người dùng dưới dạng các thư mục có khả năng liên kết theo dõi
(tức là: ngữ nghĩa liên kết tượng trưng).  Nếu bất cứ ai cố gắng truy cập chúng, họ sẽ
tự động khiến ổ đĩa đích được gắn vào (nếu có thể) trên trang web đó.

Hệ thống tập tin được gắn tự động sẽ được tự động ngắt kết nối trong khoảng
hai mươi phút sau khi chúng được sử dụng lần cuối.  Ngoài ra, chúng có thể được ngắt kết nối
trực tiếp bằng lệnh gọi hệ thống umount().

Việc ngắt kết nối ổ đĩa AFS theo cách thủ công sẽ khiến mọi hoạt động gắn kết phụ không hoạt động trên ổ đĩa đó bị hủy.
tiêu hủy đầu tiên.  Nếu tất cả đều bị loại bỏ thì khối lượng yêu cầu cũng sẽ được
chưa được gắn kết, nếu không lỗi EBUSY sẽ được trả về.

Quản trị viên có thể sử dụng điều này để cố gắng ngắt kết nối toàn bộ cây AFS
được gắn trên /afs một lần bằng cách thực hiện ::

số lượng /afs


Gốc động
============

Tùy chọn gắn kết có sẵn để tạo một gắn kết không có máy chủ chỉ có thể sử dụng được
để tra cứu động.  Việc tạo một giá treo như vậy có thể được thực hiện bằng cách, ví dụ::

mount -t afs none /afs -o dyn

Điều này tạo ra một mount chỉ có một thư mục trống ở thư mục gốc.  Đang cố gắng
tra cứu tên trong thư mục này sẽ tạo ra một điểm gắn kết
tra cứu một ô có cùng tên, ví dụ::

ls /afs/grand.central.org/


Hệ thống tập tin Proc
===============

Mô-đun AFS tạo thư mục "/proc/fs/afs/" và điền vào nó:

(*) Tệp "ô" liệt kê các ô hiện được mô-đun afs biết đến và
      số lần sử dụng của họ::

[root@andromeda ~]# cat /proc/fs/afs/cells
	USE NAME
	  3 cambridge.redhat.com

(*) Một thư mục trên mỗi ô chứa các tệp liệt kê vị trí ổ đĩa
      máy chủ, ổ đĩa và máy chủ đang hoạt động được biết đến trong ô đó::

[root@andromeda ~]# cat /proc/fs/afs/cambridge.redhat.com/servers
	USE ADDR STATE
	  4 172.16.18.91 0
	[root@andromeda ~]# cat /proc/fs/afs/cambridge.redhat.com/vlservers
	ADDRESS
	172.16.18.91
	[root@andromeda ~]# cat /proc/fs/afs/cambridge.redhat.com/volumes
	USE STT VLID[0] VLID[1] VLID[2] NAME
	  1 Giá trị 20000000 20000001 20000002 root.afs


Cơ sở dữ liệu di động
=================

Hệ thống tập tin duy trì một cơ sở dữ liệu nội bộ của tất cả các ô mà nó biết và
Địa chỉ IP của máy chủ định vị khối cho các ô đó.  Tế bào mà
hệ thống thuộc về sẽ được thêm vào cơ sở dữ liệu khi modprobe được thực hiện bởi
đối số "rootcell=" hoặc, nếu được biên dịch, sử dụng đối số "kafs.rootcell=" trên
dòng lệnh hạt nhân.

Các ô khác có thể được thêm bằng các lệnh tương tự như sau ::

echo thêm CELLNAME VLADDR[:VLADDR][:VLADDR]... >/proc/fs/afs/cells
	echo add grand.central.org 18.9.48.14:128.2.203.61:130.237.48.87 >/proc/fs/afs/cells

Không có hoạt động cơ sở dữ liệu di động nào khác có sẵn tại thời điểm này.


Bảo vệ
========

Hoạt động an toàn được bắt đầu bằng cách lấy khóa bằng chương trình klog.  A
chương trình klog rất nguyên thủy có sẵn tại:

ZZ0000ZZ

Điều này nên được biên soạn bởi::

tạo klog LDLIBS="-lcrypto -lcrypt -lkrb4 -lkeyutils"

Và sau đó chạy như::

./klog

Giả sử nó thành công, điều này sẽ thêm một khóa loại RxRPC, được đặt tên cho dịch vụ
và ô, ví dụ: "afs@<cellname>".  Điều này có thể được xem bằng chương trình keyctl hoặc
bằng cách cat'ing /proc/keys::

[root@andromeda ~]# keyctl hiển thị
	Khóa phiên
	       -3 --alswrv 0 0 móc khóa: _ses.3268
		2 --alswrv 0 0 \_ móc khóa: _uid.0
	111416553 --als--v 0 0 \_ rxrpc: afs@CAMBRIDGE.REDHAT.COM

Hiện tại tên người dùng, vương quốc, mật khẩu và thời gian tồn tại của vé được đề xuất là
biên soạn vào chương trình.

Không bắt buộc phải có khóa trước khi sử dụng các thiết bị AFS, nhưng nếu có
không được mua lại thì mọi hoạt động sẽ được quản lý bởi các bộ phận người dùng ẩn danh
của ACL.

Nếu có được một khóa, thì tất cả các hoạt động của AFS, bao gồm cả gắn kết và tự động gắn kết,
được thực hiện bởi người sở hữu khóa đó sẽ được bảo mật bằng khóa đó.

Nếu một tệp được mở bằng một khóa cụ thể và sau đó bộ mô tả tệp là
được chuyển tới một quy trình không có khóa đó (có thể qua AF_UNIX
socket), thì các thao tác trên tệp sẽ được thực hiện bằng khóa đã được sử dụng để
mở tập tin.


Sự thay thế @sys
=====================

Danh sách thay thế tối đa 16 @sys cho không gian tên mạng hiện tại có thể
được định cấu hình bằng cách viết danh sách vào /proc/fs/afs/sysname::

[root@andromeda ~]# echo foo amd64_linux_26 >/proc/fs/afs/sysname

hoặc xóa hoàn toàn bằng cách viết một danh sách trống::

[root@andromeda ~]# echo >/proc/fs/afs/sysname

Danh sách hiện tại cho không gian tên mạng hiện tại có thể được truy xuất bằng cách::

[root@andromeda ~]# cat /proc/fs/afs/sysname
	foo
	amd64_linux_26

Khi @sys được thay thế, mỗi phần tử của danh sách sẽ được thử trong
mệnh lệnh đã cho.

Theo mặc định, danh sách sẽ chứa một mục phù hợp với mẫu
"<arch>_linux_26", amd64 là tên của x86_64.