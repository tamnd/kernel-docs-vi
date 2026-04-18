.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/automount-support.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Hỗ trợ tự động
===================


Hỗ trợ có sẵn cho các hệ thống tập tin muốn thực hiện tự động đếm
hỗ trợ (chẳng hạn như kAFS có thể tìm thấy trong fs/afs/ và NFS trong
fs/nfs/). Cơ sở này bao gồm việc cho phép gắn kết trong kernel
được thực hiện và yêu cầu xuống cấp điểm gắn kết. Cái sau có thể
cũng được yêu cầu bởi không gian người dùng.


Tự động hóa trong hạt nhân
======================

Xem phần "Mount Traps" của Documentation/filesystems/autofs.rst

Sau đó, từ không gian người dùng, bạn có thể thực hiện một số việc như ::

[root@andromeda root]# mount -t afs \#root.afs. /afs
	[root@andromeda root]# ls /afs
	asd cambridge cambridge.redhat.com grand.central.org
	[root@andromeda root]# ls /afs/cambridge
	afsdoc
	[root@andromeda root]# ls /afs/cambridge/afsdoc/
	ChangeLog html LICENSE pdf RELNOTES-1.2.2

Và sau đó nếu bạn nhìn vào danh mục điểm gắn kết, bạn sẽ thấy một cái gì đó như ::

[root@andromeda root]# cat /proc/mounts
	...
#root.afs. /afs afs rw 0 0
	#root.cell. /afs/cambridge.redhat.com afs rw 0 0
	#afsdoc. /afs/cambridge.redhat.com/afsdoc afs rw 0 0


Tự động hết hạn điểm gắn kết
===========================

Việc tự động hết hạn các điểm gắn kết thật dễ dàng, miễn là bạn đã gắn kết
điểm gắn kết đã hết hạn trong quy trình tự động đếm được nêu riêng.

Để thực hiện hết hạn, bạn cần làm theo các bước sau:

(1) Tạo ít nhất một danh sách mà vfsmounts có thể hết hạn
     treo.

(2) Khi một điểm gắn kết mới được tạo theo phương thức ->d_automount, hãy thêm
     mnt vào danh sách bằng cách sử dụng mnt_set_expiry()::

mnt_set_expiry(newmnt, &afs_vfsmounts);

(3) Khi bạn muốn hết điểm gắn kết, hãy gọi mark_mounts_for_expiry()
     với một con trỏ tới danh sách này. Việc này sẽ xử lý danh sách, đánh dấu mọi
     vfsmount trên đó để biết khả năng hết hạn trong cuộc gọi tiếp theo.

Nếu một vfsmount đã được gắn cờ hết hạn và nếu số lần sử dụng của nó là 1
     (nó chỉ được tham chiếu bởi vfsmount cha của nó), sau đó nó sẽ bị xóa
     khỏi không gian tên và bị vứt đi (đã được ngắt kết nối một cách hiệu quả).

Có thể đơn giản nhất là chỉ cần gọi điều này đều đặn, sử dụng
     một số loại sự kiện được tính thời gian để thúc đẩy nó.

Cờ hết hạn được xóa bằng lệnh gọi tới mntput. Điều này có nghĩa là hết hạn
sẽ chỉ xảy ra ở yêu cầu hết hạn thứ hai sau lần cuối cùng
điểm gắn kết đã được truy cập.

Nếu một điểm gắn kết được di chuyển, nó sẽ bị xóa khỏi danh sách hết hạn. Nếu một ràng buộc
mount được thực hiện trên một mount có thể hết hạn, vfsmount mới sẽ không có trên
danh sách hết hạn và sẽ không hết hạn.

Nếu một không gian tên được sao chép, tất cả các điểm gắn kết chứa trong đó sẽ được sao chép,
và bản sao của những thứ nằm trong danh sách hết hạn sẽ được thêm vào
cùng một danh sách hết hạn.


Hết hạn theo hướng không gian người dùng
=======================

Thay vào đó, không gian người dùng có thể yêu cầu hết hạn bất kỳ
điểm gắn kết (mặc dù một số sẽ bị từ chối - ý tưởng của quy trình hiện tại về
rootfs chẳng hạn). Nó thực hiện điều này bằng cách chuyển cờ MNT_EXPIRE tới
umount(). Cờ này được coi là không tương thích với MNT_FORCE và MNT_DETACH.

Nếu điểm gắn kết được đề cập được tham chiếu bởi một cái gì đó không phải là
umount() hoặc điểm gắn kết mẹ của nó, lỗi EBUSY sẽ được trả về và
điểm gắn kết sẽ không được đánh dấu là hết hạn hoặc chưa được gắn kết.

Nếu điểm gắn kết chưa được đánh dấu hết hạn tại thời điểm đó, EAGAIN
lỗi sẽ được đưa ra và nó sẽ không được ngắt kết nối.

Ngược lại, nếu nó đã được đánh dấu và không được tham chiếu, việc ngắt kết nối sẽ
diễn ra như thường lệ.

Một lần nữa, cờ hết hạn sẽ bị xóa mỗi khi có bất kỳ điều gì khác ngoài umount()
nhìn vào một điểm gắn kết.