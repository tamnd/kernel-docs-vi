.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cifs/usage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
Cách sử dụng
=====

Mô-đun này hỗ trợ dòng giao thức mạng tiên tiến SMB3 (cũng như
như các phương ngữ cũ hơn, ban đầu được gọi là "CIFS" hoặc SMB1).

Mô-đun CIFS VFS dành cho Linux hỗ trợ nhiều hệ thống tệp mạng nâng cao
các tính năng như DFS phân cấp như không gian tên, liên kết cứng, khóa và hơn thế nữa.
Nó được thiết kế để tuân thủ Tài liệu tham khảo kỹ thuật SNIA CIFS (trong đó
thay thế Tiêu chuẩn SMB 1992 X/Open) cũng như để thực hiện phương pháp thực hành tốt nhất
khả năng tương tác thực tế với Windows 2000, Windows XP, Samba và tương đương
máy chủ.  Mã này được phát triển với sự tham gia của Protocol Freedom
Cơ sở thông tin.  CIFS và bây giờ SMB3 hiện đã trở thành defacto
tiêu chuẩn để tương tác giữa máy Mac và Windows và các thiết bị NAS chính.

Xin vui lòng xem
MS-SMB2 (để biết thông số kỹ thuật giao thức SMB2/SMB3/SMB3.1.1 chi tiết)
hoặc ZZ0000ZZ
để biết thêm chi tiết.


Mọi thắc mắc hoặc báo cáo lỗi vui lòng liên hệ:

smfrench@gmail.com

Xem trang dự án tại: ZZ0000ZZ

Hướng dẫn xây dựng
==================

Đối với Linux:

1) Tải xuống kernel (ví dụ: từ ZZ0000ZZ
   và thay đổi thư mục vào đầu cây thư mục kernel
   (ví dụ: /usr/src/linux-2.5.73)
2) tạo menuconfig (hoặc tạo xconfig)
3) chọn cifs từ trong các lựa chọn hệ thống tệp mạng
4) lưu và thoát
5) thực hiện


Hướng dẫn cài đặt
=========================

Nếu bạn đã xây dựng CIFS vfs dưới dạng mô-đun (thành công) một cách đơn giản
gõ ZZ0000ZZ (hoặc nếu bạn thích, hãy sao chép tệp theo cách thủ công vào
thư mục mô-đun, ví dụ: /lib/modules/6.3.0-060300-generic/kernel/fs/smb/client/cifs.ko).

Nếu bạn đã tích hợp vfs CIFS vào kernel, hãy làm theo hướng dẫn
để nhận bản phân phối của bạn về cách cài đặt kernel mới (thường là bạn
chỉ cần gõ ZZ0000ZZ).

Nếu bạn không có tiện ích mount.cifs (trong cây nguồn Samba 4.x trở lên
trang web CIFS VFS) sao chép nó vào cùng thư mục chứa trình trợ giúp gắn kết
cư trú (thường là /sbin).  Mặc dù phần mềm trợ giúp không
bắt buộc, nên sử dụng mount.cifs.  Hầu hết các bản phân phối đều có ZZ0000ZZ
gói bao gồm tiện ích này nên bạn nên cài đặt gói này.

Lưu ý rằng việc chạy mô-đun Winbind pam/nss (dịch vụ đăng nhập) trên tất cả các
Máy khách Linux rất hữu ích trong việc ánh xạ Uid và Gids một cách nhất quán trên
tên miền cho người dùng mạng thích hợp.  Trình trợ giúp gắn kết mount.cifs có thể là
được tìm thấy tại cifs-utils.git trên git.samba.org

Nếu cifs được xây dựng dưới dạng một mô-đun thì kích thước và số lượng bộ đệm mạng sẽ
và số lượng yêu cầu đồng thời tối đa đến một máy chủ có thể được cấu hình.
Không nên thay đổi những thứ này từ mặc định của chúng. Bằng cách thực thi modinfo::

modinfo <đường dẫn đến cifs.ko>

trên kernel/fs/smb/client/cifs.ko danh sách các thay đổi cấu hình có thể được thực hiện
tại thời điểm khởi tạo mô-đun (bằng cách chạy insmod cifs.ko) có thể được nhìn thấy.

Khuyến nghị
===============

Để cải thiện tính bảo mật, phương ngữ SMB2.1 trở lên (thường sẽ nhận được SMB3.1.1) hiện nay
mặc định mới. Để sử dụng các phương ngữ cũ (ví dụ: để gắn Windows XP), hãy sử dụng "vers=1.0"
trên mount (hoặc vers=2.0 cho Windows Vista).  Lưu ý rằng CIFS (vers=1.0) là
cũ hơn và kém an toàn hơn nhiều so với phương ngữ mặc định SMB3 bao gồm
nhiều tính năng bảo mật nâng cao như phát hiện tấn công hạ cấp
và các chia sẻ được mã hóa cũng như các thuật toán ký và xác thực mạnh hơn.
Có các tùy chọn gắn kết bổ sung có thể hữu ích để SMB3 có được
cải thiện hành vi POSIX (NB: có thể sử dụng vers=3 để buộc SMB3 trở lên, không bao giờ 2.1):

ZZ0000ZZ và ZZ0001ZZ hoặc ZZ0002ZZ (thường có ZZ0003ZZ)

Cho phép người dùng gắn kết
====================

Có thể cho phép người dùng gắn kết và ngắt kết nối các thư mục mà họ sở hữu
với cifs vfs.  Một cách để kích hoạt việc gắn kết như vậy là đánh dấu mount.cifs
tiện ích như suid (ví dụ ZZ0000ZZ). Để cho phép người dùng
số lượng cổ phần mà họ yêu cầu

1) mount.cifs phiên bản 1.4 trở lên
2) một mục chia sẻ trong /etc/fstab chỉ ra rằng người dùng có thể
   ngắt kết nối nó, ví dụ::

//server/usersharename /mnt/tên người dùng cifs người dùng 0 0

Lưu ý rằng khi tiện ích mount.cifs chạy suid (cho phép người dùng gắn kết),
để giảm thiểu rủi ro, cờ gắn ZZ0000ZZ được chuyển vào khi gắn vào
không cho phép thực thi chương trình sus được gắn trên mục tiêu từ xa.
Khi mount được thực thi với quyền root, nosuid không được truyền vào theo mặc định,
và việc thực thi các chương trình xử lý trên mục tiêu từ xa sẽ được kích hoạt
theo mặc định. Điều này có thể được thay đổi, như với nfs và các hệ thống tập tin khác,
bằng cách chỉ định ZZ0001ZZ trong số các tùy chọn gắn kết. Dành cho người dùng gắn kết
mặc dù để có thể chuyển cờ sus để gắn kết thì cần phải xây dựng lại
mount.cifs với cờ sau: CIFS_ALLOW_USR_SUID

Có một trang hướng dẫn tương ứng để gắn cifs vào Samba 3.0 và
cây nguồn sau này trong docs/manpages/mount.cifs.8

Cho phép người dùng ngắt kết nối
======================

Để cho phép người dùng ngắt kết nối các thư mục mà họ đã gắn kết (xem ở trên),
tiện ích umount.cifs có thể được sử dụng.  Nó có thể được gọi trực tiếp hoặc nếu
umount.cifs được đặt trong /sbin, umount có thể gọi trình trợ giúp cifs umount
(ít nhất là đối với hầu hết các phiên bản của tiện ích umount) cho umount cifs
mount, trừ khi umount được gọi bằng -i (điều này sẽ tránh gọi umount
người giúp việc). Giống như mount.cifs, để người dùng có thể ngắt kết nối, umount.cifs phải được đánh dấu
như suid (ví dụ ZZ0000ZZ) hoặc tương đương (một số bản phân phối
cho phép thêm các mục vào một tệp vào tệp /etc/permissions để đạt được
hiệu ứng tự sát tương đương).  Để tiện ích này thành công trên con đường đích
phải là giá đỡ cifs và uid của người dùng hiện tại phải khớp với uid
của người dùng đã gắn tài nguyên.

Cũng lưu ý rằng cách thông thường để cho phép người dùng gắn kết và ngắt kết nối là
(thay vì sử dụng mount.cifs và unmount.cifs làm suid) để thêm một dòng
vào tệp /etc/fstab cho mỗi //server/share mà bạn muốn gắn kết, nhưng
điều này có thể trở nên khó sử dụng khi các mục tiêu gắn kết tiềm năng bao gồm nhiều
hoặc những cái tên UNC khó đoán.

Cân nhắc Samba
====================

Hầu hết các máy chủ hiện tại đều hỗ trợ SMB2.1 và SMB3 an toàn hơn,
nhưng có các phần mở rộng giao thức hữu ích cho CIFS cũ kém an toàn hơn
phương ngữ, vì vậy để có được lợi ích tối đa nếu gắn kết bằng phương ngữ cũ hơn
(CIFS/SMB1), chúng tôi khuyên bạn nên sử dụng máy chủ hỗ trợ SNIA CIFS
Tiêu chuẩn Tiện ích mở rộng Unix (ví dụ: hầu hết mọi phiên bản của Samba tức là phiên bản
2.2.5 trở lên) nhưng CIFS vfs hoạt động tốt với nhiều loại máy chủ CIFS.
Lưu ý rằng các quyền của uid, gid và file sẽ hiển thị các giá trị mặc định nếu bạn làm như vậy.
không có máy chủ hỗ trợ các phần mở rộng Unix cho CIFS (chẳng hạn như Samba
2.2.5 trở lên).  Để bật Tiện ích mở rộng Unix CIFS trong máy chủ Samba, hãy thêm
dòng::

tiện ích mở rộng unix = có

vào tệp smb.conf của bạn trên máy chủ.  Lưu ý rằng các cài đặt smb.conf sau
cũng hữu ích (trên máy chủ Samba) khi phần lớn máy khách là Unix hoặc
Linux::

phân biệt chữ hoa chữ thường = có
	xóa chỉ đọc = có
	ea hỗ trợ = có

Lưu ý rằng cần có sự hỗ trợ của máy chủ để hỗ trợ xattrs từ Linux
cifs client và hỗ trợ EA đó có trong các phiên bản sau của Samba (ví dụ:
3.0.6 trở lên (hỗ trợ EA cũng hoạt động trong tất cả các phiên bản Windows, ít nhất là đối với
chia sẻ trên hệ thống tập tin NTFS).  Hỗ trợ Thuộc tính mở rộng (xattr) là tùy chọn
tính năng của hầu hết các hệ thống tập tin Linux có thể yêu cầu kích hoạt thông qua
tạo menuconfig. Hỗ trợ khách hàng cho các thuộc tính mở rộng (người dùng xattr) có thể
bị vô hiệu hóa trên cơ sở mỗi lần gắn kết bằng cách chỉ định ZZ0000ZZ trên lần gắn kết.

Máy khách CIFS có thể nhận và đặt ACL POSIX (getfacl, setfacl) cho máy chủ Samba
phiên bản 3.10 trở lên.  Việc đặt ACL POSIX yêu cầu bật cả XATTR và
sau đó hỗ trợ POSIX trong các tùy chọn cấu hình CIFS khi xây dựng cifs
mô-đun.  Có thể tắt hỗ trợ POSIX ACL trên mỗi ngàm cơ bản bằng cách chỉ định
ZZ0000ZZ trên ngàm.

Một số quản trị viên có thể muốn thay đổi smb.conf ZZ0000ZZ của Samba và
Thông số ZZ0001ZZ từ mặc định.  Trừ khi mặt nạ tạo được thay đổi
các tệp mới được tạo có thể có chế độ mặc định hạn chế không cần thiết,
có thể không phải là điều bạn muốn, mặc dù nếu phần mở rộng Unix CIFS
được bật trên máy chủ và máy khách, các lệnh gọi setattr tiếp theo (ví dụ: chmod) có thể
sửa chế độ.  Lưu ý rằng việc tạo các thiết bị đặc biệt (mknod) từ xa
có thể yêu cầu chỉ định hàm mkdev cho Samba nếu bạn không sử dụng
Samba 3.0.6 trở lên.  Để biết thêm thông tin về những điều này, hãy xem các trang hướng dẫn
(ZZ0002ZZ) trên hệ thống máy chủ Samba.  Lưu ý rằng cifs vfs,
không giống như smbfs vfs, không đọc smb.conf trên hệ thống máy khách
(thay vào đó, một số cài đặt tùy chọn được chuyển vào khi gắn kết thông qua tham số -o).
Lưu ý rằng Samba 2.2.7 trở lên bao gồm một bản sửa lỗi cho phép CIFS VFS xóa
mở các tệp (bắt buộc để tuân thủ nghiêm ngặt POSIX).  Máy chủ Windows đã có
đã hỗ trợ tính năng này. Máy chủ Samba không cho phép liên kết tượng trưng tham chiếu đến tệp
bên ngoài phần chia sẻ, vì vậy trong các phiên bản Samba trước 3.0.6, hầu hết các liên kết tượng trưng đến
các tệp có đường dẫn tuyệt đối (tức là bắt đầu bằng dấu gạch chéo), chẳng hạn như::

ln -s /mnt/foo thanh

sẽ bị cấm. Máy chủ Samba 3.0.6 trở lên bao gồm khả năng tạo
các liên kết tượng trưng đó một cách an toàn bằng cách chuyển đổi các liên kết tượng trưng không an toàn (tức là các liên kết tượng trưng đến máy chủ
các tệp nằm ngoài phần chia sẻ) sang định dạng samba cụ thể trên máy chủ
bị bỏ qua bởi các ứng dụng máy chủ cục bộ và các máy khách không phải cifs và điều đó sẽ
máy chủ Samba không được duyệt qua).  Điều này không rõ ràng đối với máy khách Linux
ứng dụng sử dụng cifs vfs. Liên kết tượng trưng tuyệt đối sẽ hoạt động với Samba 3.0.5 hoặc
sau này, nhưng chỉ dành cho các máy khách từ xa sử dụng tiện ích mở rộng Unix CIFS và sẽ
ẩn đối với các máy khách Windows và thường sẽ không ảnh hưởng đến các máy cục bộ
các ứng dụng chạy trên cùng một máy chủ với Samba.

Hướng dẫn sử dụng
================

Sau khi hỗ trợ CIFS VFS được tích hợp vào kernel hoặc được cài đặt dưới dạng mô-đun
(cifs.ko), bạn có thể sử dụng cú pháp mount như sau để truy cập Samba hoặc
Máy chủ Mac hoặc Windows::

mount -t cifs //9.53.216.11/e$ /mnt -o tên người dùng=myname,password=mypassword

Trước -o, tùy chọn -v có thể được chỉ định để tạo mount.cifs
trình trợ giúp gắn kết hiển thị các bước gắn kết chi tiết hơn.
Sau -o các tùy chọn cụ thể cifs vfs thường được sử dụng sau đây
được hỗ trợ::

tên người dùng=<tên người dùng>
  mật khẩu=<mật khẩu>
  tên miền=<tên miền>

Các tùy chọn gắn cifs khác được mô tả dưới đây.  Việc sử dụng tên TCP (ngoài
địa chỉ IP) khả dụng nếu trình trợ giúp gắn kết (mount.cifs) được cài đặt. Nếu
bạn không tin cậy vào máy chủ được gắn vào, hoặc nếu bạn không có
cifs đã được kích hoạt (và mạng vật lý không an toàn), hãy cân nhắc sử dụng
trong số các tùy chọn gắn tiêu chuẩn ZZ0000ZZ và ZZ0001ZZ để giảm nguy cơ
chạy tệp nhị phân đã thay đổi trên hệ thống cục bộ của bạn (được tải xuống từ máy chủ thù địch
hoặc bị thay đổi bởi bộ định tuyến thù địch).

Mặc dù việc gắn bằng định dạng tương ứng với thông số kỹ thuật CIFS URL là
chưa thể có trong mount.cifs, có thể sử dụng định dạng thay thế
cho máy chủ và tên chia sẻ (có phần giống với kiểu mount NFS
cú pháp) thay vì định dạng UNC được sử dụng rộng rãi hơn (tức là \\server\share)::

mount -t cifs tcp_name_of_server:share_name /mnt -o user=myname,pass=mypasswd

Khi sử dụng trình trợ giúp gắn kết mount.cifs, mật khẩu có thể được chỉ định thông qua thay thế
cơ chế, thay vì chỉ định nó sau -o bằng cú pháp ZZ0000ZZ thông thường
trên dòng lệnh:
1) Bằng cách đưa nó vào tệp thông tin xác thực. Chỉ định thông tin xác thực=tên tệp làm một
của các tùy chọn gắn kết. Tệp thông tin xác thực chứa hai dòng::

tên người dùng=một số người dùng
	mật khẩu=your_password

2) Bằng cách chỉ định mật khẩu trong biến môi trường PASSWD (tương tự
   tên người dùng có thể được lấy từ biến môi trường USER).
3) Bằng cách chỉ định mật khẩu trong tệp theo tên qua PASSWD_FILE
4) Bằng cách chỉ định mật khẩu trong một tệp theo bộ mô tả tệp thông qua PASSWD_FD

Nếu không cung cấp mật khẩu, mount.cifs sẽ nhắc nhập mật khẩu

Hạn chế
============

Máy chủ phải hỗ trợ "pure-TCP" (kết nối cổng 445 TCP/IP CIFS) hoặc RFC
Hỗ trợ 1001/1002 cho "Netbios-Over-TCP/IP." Đây không có khả năng là một
vấn đề vì hầu hết các máy chủ đều hỗ trợ điều này.

Tên tệp hợp lệ khác nhau giữa Windows và Linux.  Windows thường hạn chế
tên tệp chứa các ký tự dành riêng nhất định (ví dụ: ký tự:
được Windows sử dụng để phân định phần đầu của tên luồng), trong khi
Linux cho phép tập hợp các ký tự hợp lệ rộng hơn một chút trong tên tệp. cửa sổ
máy chủ có thể ánh xạ lại các ký tự đó khi ánh xạ rõ ràng được chỉ định trong
sổ đăng ký của Máy chủ.  Samba bắt đầu với phiên bản 3.10 sẽ cho phép điều đó
tên tệp (tức là những tên có chứa các ký tự Linux hợp lệ, thông thường
sẽ bị cấm đối với ngữ nghĩa của Windows/CIFS) miễn là máy chủ
được định cấu hình cho Tiện ích mở rộng Unix (và máy khách chưa tắt
/proc/fs/cifs/LinuxExtensionsEnabled). Ngoài ra, tùy chọn gắn kết
ZZ0000ZZ có thể được sử dụng trên CIFS (vers=1.0) để buộc ánh xạ
các ký tự Windows/NTFS/SMB không hợp lệ vào phạm vi ánh xạ lại (tham số gắn kết này
là mặc định cho SMB3). Phạm vi ánh xạ lại (ZZ0001ZZ) này cũng
tương thích với Mac (và "Dịch vụ dành cho Mac" trên một số Windows cũ hơn).
Khi Phần mở rộng POSIX cho SMB 3.1.1 được thương lượng, việc ánh xạ lại sẽ tự động được thực hiện
bị vô hiệu hóa.

Tùy chọn gắn CIFS VFS
======================
Sau đây là danh sách một phần các tùy chọn gắn kết được hỗ trợ:

  username
		The user name to use when trying to establish
		the CIFS session.
  password
		The user password.  If the mount helper is
		installed, the user will be prompted for password
		if not supplied.
  ip
		The ip address of the target server
  unc
		The target server Universal Network Name (export) to
		mount.
  domain
		Set the SMB/CIFS workgroup name prepended to the
		username during CIFS session establishment
  forceuid
		Set the default uid for inodes to the uid
		passed in on mount. For mounts to servers
		which do support the CIFS Unix extensions, such as a
		properly configured Samba server, the server provides
		the uid, gid and mode so this parameter should not be
		specified unless the server and clients uid and gid
		numbering differ.  If the server and client are in the
		same domain (e.g. running winbind or nss_ldap) and
		the server supports the Unix Extensions then the uid
		and gid can be retrieved from the server (and uid
		and gid would not have to be specified on the mount.
		For servers which do not support the CIFS Unix
		extensions, the default uid (and gid) returned on lookup
		of existing files will be the uid (gid) of the person
		who executed the mount (root, except when mount.cifs
		is configured setuid for user mounts) unless the ``uid=``
		(gid) mount option is specified. Also note that permission
		checks (authorization checks) on accesses to a file occur
		at the server, but there are cases in which an administrator
		may want to restrict at the client as well.  For those
		servers which do not report a uid/gid owner
		(such as Windows), permissions can also be checked at the
		client, and a crude form of client side permission checking
		can be enabled by specifying file_mode and dir_mode on
		the client.  (default)
  forcegid
		(similar to above but for the groupid instead of uid) (default)
  noforceuid
		Fill in file owner information (uid) by requesting it from
		the server if possible. With this option, the value given in
		the uid= option (on mount) will only be used if the server
		can not support returning uids on inodes.
  noforcegid
		(similar to above but for the group owner, gid, instead of uid)
  uid
		Set the default uid for inodes, and indicate to the
		cifs kernel driver which local user mounted. If the server
		supports the unix extensions the default uid is
		not used to fill in the owner fields of inodes (files)
		unless the ``forceuid`` parameter is specified.
  gid
		Set the default gid for inodes (similar to above).
  file_mode
		If CIFS Unix extensions are not supported by the server
		this overrides the default mode for file inodes.
  fsc
		Enable local disk caching using FS-Cache (off by default). This
		option could be useful to improve performance on a slow link,
		heavily loaded server and/or network where reading from the
		disk is faster than reading from the server (over the network).
		This could also impact scalability positively as the
		number of calls to the server are reduced. However, local
		caching is not suitable for all workloads for e.g. read-once
		type workloads. So, you need to consider carefully your
		workload/scenario before using this option. Currently, local
		disk caching is functional for CIFS files opened as read-only.
  dir_mode
		If CIFS Unix extensions are not supported by the server
		this overrides the default mode for directory inodes.
  port
		attempt to contact the server on this tcp port, before
		trying the usual ports (port 445, then 139).
  iocharset
		Codepage used to convert local path names to and from
		Unicode. Unicode is used by default for network path
		names if the server supports it.  If iocharset is
		not specified then the nls_default specified
		during the local client kernel build will be used.
		If server does not support Unicode, this parameter is
		unused.
  rsize
		default read size (usually 16K). The client currently
		can not use rsize larger than CIFSMaxBufSize. CIFSMaxBufSize
		defaults to 16K and may be changed (from 8K to the maximum
		kmalloc size allowed by your kernel) at module install time
		for cifs.ko. Setting CIFSMaxBufSize to a very large value
		will cause cifs to use more memory and may reduce performance
		in some cases.  To use rsize greater than 127K (the original
		cifs protocol maximum) also requires that the server support
		a new Unix Capability flag (for very large read) which some
		newer servers (e.g. Samba 3.0.26 or later) do. rsize can be
		set from a minimum of 2048 to a maximum of 130048 (127K or
		CIFSMaxBufSize, whichever is smaller)
  wsize
		default write size (default 57344)
		maximum wsize currently allowed by CIFS is 57344 (fourteen
		4096 byte pages)
  actimeo=n
		attribute cache timeout in seconds (default 1 second).
		After this timeout, the cifs client requests fresh attribute
		information from the server. This option allows to tune the
		attribute cache timeout to suit the workload needs. Shorter
		timeouts mean better the cache coherency, but increased number
		of calls to the server. Longer timeouts mean reduced number
		of calls to the server at the expense of less stricter cache
		coherency checks (i.e. incorrect attribute cache for a short
		period of time).
  rw
		mount the network share read-write (note that the
		server may still consider the share read-only)
  ro
		mount network share read-only
  version
		used to distinguish different versions of the
		mount helper utility (not typically needed)
  sep
		if first mount option (after the -o), overrides
		the comma as the separator between the mount
		parameters. e.g.::

-o người dùng=tên tôi,mật khẩu=mật khẩu của tôi,tên miền=mydom

thay vào đó có thể được chuyển bằng dấu chấm làm dấu phân cách bằng::

-o sep=.user=myname.password=mypassword.domain=mydom

		this might be useful when comma is contained within username
		or password or domain. This option is less important
		when the cifs mount helper cifs.mount (version 1.1 or later)
		is used.
  nosuid
		Do not allow remote executables with the suid bit
		program to be executed.  This is only meaningful for mounts
		to servers such as Samba which support the CIFS Unix Extensions.
		If you do not trust the servers in your network (your mount
		targets) it is recommended that you specify this option for
		greater security.
  exec
		Permit execution of binaries on the mount.
  noexec
		Do not permit execution of binaries on the mount.
  dev
		Recognize block devices on the remote mount.
  nodev
		Do not recognize devices on the remote mount.
  suid
		Allow remote files on this mountpoint with suid enabled to
		be executed (default for mounts when executed as root,
		nosuid is default for user mounts).
  credentials
		Although ignored by the cifs kernel component, it is used by
		the mount helper, mount.cifs. When mount.cifs is installed it
		opens and reads the credential file specified in order
		to obtain the userid and password arguments which are passed to
		the cifs vfs.
  guest
		Although ignored by the kernel component, the mount.cifs
		mount helper will not prompt the user for a password
		if guest is specified on the mount options.  If no
		password is specified a null password will be used.
  perm
		Client does permission checks (vfs_permission check of uid
		and gid of the file against the mode and desired operation),
		Note that this is in addition to the normal ACL check on the
		target machine done by the server software.
		Client permission checking is enabled by default.
  noperm
		Client does not do permission checks.  This can expose
		files on this mount to access by other users on the local
		client system. It is typically only needed when the server
		supports the CIFS Unix Extensions but the UIDs/GIDs on the
		client and server system do not match closely enough to allow
		access by the user doing the mount, but it may be useful with
		non CIFS Unix Extension mounts for cases in which the default
		mode is specified on the mount but is not to be enforced on the
		client (e.g. perhaps when MultiUserMount is enabled)
		Note that this does not affect the normal ACL check on the
		target machine done by the server software (of the server
		ACL against the user name provided at mount time).
  serverino
		Use server's inode numbers instead of generating automatically
		incrementing inode numbers on the client.  Although this will
		make it easier to spot hardlinked files (as they will have
		the same inode numbers) and inode numbers may be persistent,
		note that the server does not guarantee that the inode numbers
		are unique if multiple server side mounts are exported under a
		single share (since inode numbers on the servers might not
		be unique if multiple filesystems are mounted under the same
		shared higher level directory).  Note that some older
		(e.g. pre-Windows 2000) do not support returning UniqueIDs
		or the CIFS Unix Extensions equivalent and for those
		this mount option will have no effect.  Exporting cifs mounts
		under nfsd requires this mount option on the cifs mount.
		This is now the default if server supports the
		required network operation.
  noserverino
		Client generates inode numbers (rather than using the actual one
		from the server). These inode numbers will vary after
		unmount or reboot which can confuse some applications,
		but not all server filesystems support unique inode
		numbers.
  setuids
		If the CIFS Unix extensions are negotiated with the server
		the client will attempt to set the effective uid and gid of
		the local process on newly created files, directories, and
		devices (create, mkdir, mknod).  If the CIFS Unix Extensions
		are not negotiated, for newly created files and directories
		instead of using the default uid and gid specified on
		the mount, cache the new file's uid and gid locally which means
		that the uid for the file can change when the inode is
		reloaded (or the user remounts the share).
  nosetuids
		The client will not attempt to set the uid and gid on
		on newly created files, directories, and devices (create,
		mkdir, mknod) which will result in the server setting the
		uid and gid to the default (usually the server uid of the
		user who mounted the share).  Letting the server (rather than
		the client) set the uid and gid is the default. If the CIFS
		Unix Extensions are not negotiated then the uid and gid for
		new files will appear to be the uid (gid) of the mounter or the
		uid (gid) parameter specified on the mount.
  netbiosname
		When mounting to servers via port 139, specifies the RFC1001
		source name to use to represent the client netbios machine
		name when doing the RFC1001 netbios session initialize.
  direct
		Do not do inode data caching on files opened on this mount.
		This precludes mmapping files on this mount. In some cases
		with fast networks and little or no caching benefits on the
		client (e.g. when the application is doing large sequential
		reads bigger than page size without rereading the same data)
		this can provide better performance than the default
		behavior which caches reads (readahead) and writes
		(writebehind) through the local Linux client pagecache
		if oplock (caching token) is granted and held. Note that
		direct allows write operations larger than page size
		to be sent to the server.
  strictcache
		Use for switching on strict cache mode. In this mode the
		client read from the cache all the time it has Oplock Level II,
		otherwise - read from the server. All written data are stored
		in the cache, but if the client doesn't have Exclusive Oplock,
		it writes the data to the server.
  rwpidforward
		Forward pid of a process who opened a file to any read or write
		operation on that file. This prevent applications like WINE
		from failing on read and write if we use mandatory brlock style.
  acl
		Allow setfacl and getfacl to manage posix ACLs if server
		supports them.  (default)
  noacl
		Do not allow setfacl and getfacl calls on this mount
  user_xattr
		Allow getting and setting user xattrs (those attributes whose
		name begins with ``user.`` or ``os2.``) as OS/2 EAs (extended
		attributes) to the server.  This allows support of the
		setfattr and getfattr utilities. (default)
  nouser_xattr
		Do not allow getfattr/setfattr to get/set/list xattrs
  mapchars
		Translate six of the seven reserved characters (not backslash)::

			*?<>|:

		to the remap range (above 0xF000), which also
		allows the CIFS client to recognize files created with
		such characters by Windows's POSIX emulation. This can
		also be useful when mounting to most versions of Samba
		(which also forbids creating and opening files
		whose names contain any of these seven characters).
		This has no effect if the server does not support
		Unicode on the wire.
  nomapchars
		Do not translate any of these seven characters (default).
  nocase
		Request case insensitive path name matching (case
		sensitive is the default if the server supports it).
		(mount option ``ignorecase`` is identical to ``nocase``)
  posixpaths
		If CIFS Unix extensions are supported, attempt to
		negotiate posix path name support which allows certain
		characters forbidden in typical CIFS filenames, without
		requiring remapping. (default)
  noposixpaths
		If CIFS Unix extensions are supported, do not request
		posix path name support (this may cause servers to
		reject creatingfile with certain reserved characters).
  nounix
		Disable the CIFS Unix Extensions for this mount (tree
		connection). This is rarely needed, but it may be useful
		in order to turn off multiple settings all at once (ie
		posix acls, posix locks, posix paths, symlink support
		and retrieving uids/gids/mode from the server) or to
		work around a bug in server which implement the Unix
		Extensions.
  nobrl
		Do not send byte range lock requests to the server.
		This is necessary for certain applications that break
		with cifs style mandatory byte range locks (and most
		cifs servers do not yet support requesting advisory
		byte range locks).
  forcemandatorylock
		Even if the server supports posix (advisory) byte range
		locking, send only mandatory lock requests.  For some
		(presumably rare) applications, originally coded for
		DOS/Windows, which require Windows style mandatory byte range
		locking, they may be able to take advantage of this option,
		forcing the cifs client to only send mandatory locks
		even if the cifs server would support posix advisory locks.
		``forcemand`` is accepted as a shorter form of this mount
		option.
  nostrictsync
		If this mount option is set, when an application does an
		fsync call then the cifs client does not send an SMB Flush
		to the server (to force the server to write all dirty data
		for this file immediately to disk), although cifs still sends
		all dirty (cached) file data to the server and waits for the
		server to respond to the write.  Since SMB Flush can be
		very slow, and some servers may be reliable enough (to risk
		delaying slightly flushing the data to disk on the server),
		turning on this option may be useful to improve performance for
		applications that fsync too much, at a small risk of server
		crash.  If this mount option is not set, by default cifs will
		send an SMB flush request (and wait for a response) on every
		fsync call.
  nodfs
		Disable DFS (global name space support) even if the
		server claims to support it.  This can help work around
		a problem with parsing of DFS paths with Samba server
		versions 3.0.24 and 3.0.25.
  remount
		remount the share (often used to change from ro to rw mounts
		or vice versa)
  cifsacl
		Report mode bits (e.g. on stat) based on the Windows ACL for
		the file. (EXPERIMENTAL)
  servern
		Specify the server 's netbios name (RFC1001 name) to use
		when attempting to setup a session to the server.
		This is needed for mounting to some older servers (such
		as OS/2 or Windows 98 and Windows ME) since they do not
		support a default server name.  A server name can be up
		to 15 characters long and is usually uppercased.
  sfu
		When the CIFS Unix Extensions are not negotiated, attempt to
		create device files and fifos in a format compatible with
		Services for Unix (SFU).  In addition retrieve bits 10-12
		of the mode via the SETFILEBITS extended attribute (as
		SFU does).  In the future the bottom 9 bits of the
		mode also will be emulated using queries of the security
		descriptor (ACL).
  mfsymlinks
		Enable support for Minshall+French symlinks
		(see http://wiki.samba.org/index.php/UNIX_Extensions#Minshall.2BFrench_symlinks)
		This option is ignored when specified together with the
		'sfu' option. Minshall+French symlinks are used even if
		the server supports the CIFS Unix Extensions.
  sign
		Must use packet signing (helps avoid unwanted data modification
		by intermediate systems in the route).  Note that signing
		does not work with lanman or plaintext authentication.
  seal
		Must seal (encrypt) all data on this mounted share before
		sending on the network.  Requires support for Unix Extensions.
		Note that this differs from the sign mount option in that it
		causes encryption of data sent over this mounted share but other
		shares mounted to the same server are unaffected.
  locallease
		This option is rarely needed. Fcntl F_SETLEASE is
		used by some applications such as Samba and NFSv4 server to
		check to see whether a file is cacheable.  CIFS has no way
		to explicitly request a lease, but can check whether a file
		is cacheable (oplocked).  Unfortunately, even if a file
		is not oplocked, it could still be cacheable (ie cifs client
		could grant fcntl leases if no other local processes are using
		the file) for cases for example such as when the server does not
		support oplocks and the user is sure that the only updates to
		the file will be from this client. Specifying this mount option
		will allow the cifs client to check for leases (only) locally
		for files which are not oplocked instead of denying leases
		in that case. (EXPERIMENTAL)
  sec
		Security mode.  Allowed values are:

không có
				cố gắng kết nối với tư cách là người dùng null (không có tên)
			krb5
				Sử dụng xác thực Kerberos phiên bản 5
			krb5i
				Sử dụng xác thực Kerberos và ký gói
			ntlm
				Sử dụng băm mật khẩu NTLM (mặc định)
			ntlmi
				Sử dụng băm mật khẩu NTLM bằng cách ký (nếu
				/proc/fs/cifs/PacketSigningEnabled trên hoặc nếu
				máy chủ yêu cầu ký cũng có thể là mặc định)
			ntlmv2
				Sử dụng băm mật khẩu NTLMv2
			ntlmv2i
				Sử dụng băm mật khẩu NTLMv2 với ký gói
			lan man
				(nếu được cấu hình trong cấu hình kernel) hãy sử dụng phiên bản cũ hơn
				hàm băm lanman
  cứng
		Thử lại các thao tác với tệp nếu máy chủ không phản hồi
  mềm mại
		Giới hạn số lần thử lại đối với các máy chủ không phản hồi (thường chỉ
		thử lại một lần) trước khi trả về lỗi.  (mặc định)

Trình trợ giúp gắn kết mount.cifs cũng chấp nhận một số tùy chọn gắn kết trước -o
bao gồm:

=====================================================================================
	-S lấy mật khẩu từ stdin (tương đương với việc thiết lập môi trường
		biến ZZ0000ZZ
	-V in phiên bản mount.cifs
	-?      hiển thị thông tin sử dụng đơn giản
=====================================================================================

Với hầu hết các phiên bản kernel 2.6 của modutils, phiên bản kernel cifs
mô-đun có thể được hiển thị thông qua modinfo.

Thông tin cờ /proc/fs/cifs linh tinh và gỡ lỗi
=======================================

Các tập tin giả thông tin:

====================================================================================
DebugData Hiển thị thông tin về các phiên CIFS đang hoạt động và
			chia sẻ, tính năng được kích hoạt cũng như cifs.ko
			phiên bản.
Thống kê Liệt kê thông tin sử dụng tài nguyên tóm tắt cũng như theo
			chia sẻ số liệu thống kê.
open_files Liệt kê tất cả các thẻ xử lý tệp đang mở trên tất cả các phiên SMB đang hoạt động.
mount_params Danh sách tất cả các tham số gắn kết có sẵn cho mô-đun
====================================================================================

Tệp giả cấu hình:

====================================================================================
SecurityFlags Cờ kiểm soát đàm phán bảo mật và
			cũng ký gói. Xác thực (có thể/phải)
			cờ (ví dụ: cho NTLMv2) có thể được kết hợp với
			những lá cờ ký kết  Chỉ định hai mật khẩu khác nhau
			Mặt khác, cơ chế băm (là "phải sử dụng")
			không có nhiều ý nghĩa. Cờ mặc định là::

0x00C5

(Cho phép NTLMv2 và ký gói).  Một số cờ bảo mật
			có thể yêu cầu kích hoạt tùy chọn menuconfig tương ứng.

có thể sử dụng ký gói 0x00001
			  phải sử dụng ký gói 0x01001
			  có thể sử dụng NTLMv2 0x00004
			  phải sử dụng NTLMv2 0x04004
			  có thể sử dụng bảo mật Kerberos (krb5) 0x00008
			  phải sử dụng Kerberos 0x08008
			  có thể sử dụng NTLMSSP 0x00080
			  phải sử dụng NTLMSSP 0x80080
			  con dấu (mã hóa gói) 0x00040
			  phải đóng dấu 0x40040

cifsFYI Nếu được đặt thành giá trị khác 0, thông tin gỡ lỗi bổ sung
			sẽ được ghi vào nhật ký lỗi hệ thống.  Trường này
			chứa ba cờ kiểm soát các lớp khác nhau của
			các mục gỡ lỗi.  Giá trị tối đa có thể được đặt
			to là 7 cho phép tất cả các điểm gỡ lỗi (mặc định là 0).
			Một số câu lệnh gỡ lỗi không được biên dịch vào
			cifs kernel trừ khi CONFIG_CIFS_DEBUG2 được bật trong
			cấu hình hạt nhân. cifsFYI có thể được đặt thành một hoặc
			thêm các cờ sau (7 bộ tất cả)::

+-------------------------------------------------+------+
			  ZZ0000ZZ 0x01 |
			  +-------------------------------------------------+------+
			  ZZ0001ZZ 0x02 |
			  +-------------------------------------------------+------+
			  ZZ0002ZZ 0x04 |
			  ZZ0003ZZ |
			  ZZ0004ZZ |
			  ZZ0005ZZ |
			  +-------------------------------------------------+------+

traceSMB Nếu được đặt thành một, thông tin gỡ lỗi sẽ được ghi vào
			nhật ký lỗi hệ thống khi bắt đầu yêu cầu smb
			và phản hồi (mặc định 0)
LookupCacheEnable Nếu được đặt thành một, thông tin inode sẽ được lưu vào bộ đệm
			trong một giây cải thiện hiệu suất tra cứu
			(mặc định 1)
LinuxExtensionsEnabled Nếu được đặt thành một thì máy khách sẽ cố gắng
			sử dụng tiện ích mở rộng CIFS "UNIX" là tùy chọn
			cải tiến giao thức cho phép máy chủ CIFS
			để trả về thông tin UID/GID chính xác
			như hỗ trợ các liên kết tượng trưng. Nếu bạn sử dụng máy chủ
			chẳng hạn như Samba hỗ trợ CIFS Unix
			tiện ích mở rộng nhưng không muốn sử dụng liên kết tượng trưng
			hỗ trợ và muốn ánh xạ các trường uid và gid
			tới các giá trị được cung cấp khi gắn kết (chứ không phải
			giá trị thực tế, sau đó đặt giá trị này thành 0. (mặc định 1)
dfscache Liệt kê nội dung của bộ đệm DFS.
			Nếu được đặt thành 0, máy khách sẽ xóa bộ đệm.
====================================================================================

Những tính năng thử nghiệm và theo dõi này có thể được kích hoạt bằng cách thay đổi cờ trong
/proc/fs/cifs (sau khi mô-đun cifs đã được cài đặt hoặc tích hợp vào
hạt nhân, ví dụ:  insmod cif).  Để bật một tính năng, hãy đặt nó thành 1, ví dụ:  để kích hoạt
truy tìm loại nhật ký thông báo kernel::

echo 7 > /proc/fs/cifs/cifsFYI

cifsFYI hoạt động như một mặt nạ bit. Đặt nó thành 1 sẽ cho phép thêm kernel
ghi lại các thông điệp thông tin khác nhau.  2 cho phép ghi lại giá trị khác 0
SMB trả lại mã trong khi 4 cho phép ghi nhật ký các yêu cầu mất nhiều thời gian hơn
hơn một giây để hoàn thành (ngoại trừ các yêu cầu khóa phạm vi byte).
Đặt nó thành 4 yêu cầu CONFIG_CIFS_STATS2 phải được đặt trong cấu hình kernel
(.config). Đặt nó thành bảy sẽ kích hoạt cả ba.  Cuối cùng, truy tìm
việc bắt đầu yêu cầu và phản hồi smb có thể được kích hoạt thông qua ::

echo 1 > /proc/fs/cifs/traceSMB

Số liệu thống kê trên mỗi lượt chia sẻ (mỗi lần gắn kết khách hàng) có sẵn trong /proc/fs/cifs/Stats.
Thông tin bổ sung có sẵn nếu CONFIG_CIFS_STATS2 được bật trong
cấu hình hạt nhân (.config).  Số liệu thống kê được trả về bao gồm các bộ đếm
biểu thị số lần thử và không thành công (tức là mã trả về khác 0 từ
máy chủ) Các yêu cầu SMB3 (hoặc cifs) được nhóm theo loại yêu cầu (đọc, ghi, đóng, v.v.).
Cũng được ghi lại là tổng số byte đã đọc và số byte được ghi vào máy chủ cho
chia sẻ đó.  Lưu ý rằng do hiệu ứng bộ nhớ đệm của máy khách, giá trị này có thể nhỏ hơn giá trị
số byte được đọc và ghi bởi ứng dụng chạy trên máy khách.
Thống kê có thể được đặt lại về 0 bởi ZZ0000ZZ, điều này có thể
hữu ích nếu so sánh hiệu suất của hai kịch bản khác nhau.

Cũng lưu ý rằng ZZ0000ZZ sẽ hiển thị thông tin về
các phiên hoạt động và các chia sẻ được gắn kết.

Kích hoạt Kerberos (bảo mật mở rộng) hoạt động nhưng yêu cầu phiên bản 1.2 trở lên
của chương trình trợ giúp cifs.upcall hiện diện và được cấu hình trong
tệp /etc/request-key.conf.  Chương trình trợ giúp cifs.upcall đến từ Samba
dự án (ZZ0000ZZ NTLM và NTLMv2 và LANMAN không hỗ trợ
cần người trợ giúp này. Lưu ý rằng bảo mật NTLMv2 (không yêu cầu
chương trình trợ giúp cifs.upcall), thay vì sử dụng Kerberos, là đủ cho
một số trường hợp sử dụng.

Hỗ trợ DFS cho phép chuyển hướng minh bạch sang chia sẻ trong không gian tên MS-DFS.
Ngoài ra, DFS hỗ trợ cho các chia sẻ mục tiêu được chỉ định là UNC
tên bắt đầu bằng tên máy chủ (chứ không phải địa chỉ IP) yêu cầu
một người trợ giúp không gian người dùng (chẳng hạn như cifs.upcall) có mặt để
dịch tên máy chủ thành địa chỉ IP và người trợ giúp không gian người dùng cũng phải
được cấu hình trong tệp /etc/request-key.conf.  Samba, máy chủ Windows và
nhiều thiết bị NAS hỗ trợ DFS như một cách xây dựng tên tuổi toàn cầu
không gian để dễ dàng cấu hình mạng và cải thiện độ tin cậy.

Để sử dụng hỗ trợ cifs Kerberos và DFS, gói keyutils Linux phải là
được cài đặt và một cái gì đó giống như những dòng sau nên được thêm vào
Tệp /etc/request-key.conf::

tạo cifs.spnego * * /usr/local/sbin/cifs.upcall %k
  tạo dns_resolver * * /usr/local/sbin/cifs.upcall %k

Thông số mô-đun hạt nhân CIFS
=============================
Các tham số mô-đun này có thể được chỉ định hoặc sửa đổi trong thời gian
tải mô-đun hoặc trong thời gian chạy bằng cách sử dụng giao diện::

/sys/module/cifs/tham số/<param>

tức là::

echo "value" > /sys/module/cifs/parameters/<param>

Mô tả chi tiết hơn về các tham số mô-đun có sẵn và giá trị của chúng
có thể được nhìn thấy bằng cách thực hiện:

modinfo cifs (hoặc modinfo smb3)

=================================================================================
1. Enable_oplocks Bật hoặc tắt oplocks. Oplocks được bật theo mặc định.
		  [Có/năm/1]. Để tắt, hãy sử dụng bất kỳ [N/n/0] nào.
=================================================================================
