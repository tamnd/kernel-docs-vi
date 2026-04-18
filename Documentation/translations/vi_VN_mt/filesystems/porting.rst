.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/porting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Những thay đổi kể từ phiên bản 2.5.0:
====================

---

ZZ0000ZZ

Người trợ giúp mới: sb_bread(), sb_getblk(), sb_find_get_block(), set_bh(),
sb_set_blocksize() và sb_min_blocksize().

Sử dụng chúng.

(sb_find_get_block() thay thế get_hash_table() của 2.4)

---

ZZ0000ZZ

Phương thức mới: ->alloc_inode() và ->destroy_inode().

Xóa inode->u.foo_inode_i

Tuyên bố::

cấu trúc foo_inode_info {
		/* fs-riêng tư */
		cấu trúc inode vfs_inode;
	};
	cấu trúc nội tuyến tĩnh foo_inode_info *FOO_I(struct inode *inode)
	{
		trả về list_entry(inode, struct foo_inode_info, vfs_inode);
	}

Sử dụng FOO_I(inode) thay vì &inode->u.foo_inode_i;

Thêm foo_alloc_inode() và foo_destroy_inode() - cái trước sẽ phân bổ
foo_inode_info và trả về địa chỉ của ->vfs_inode, địa chỉ sau sẽ miễn phí
FOO_I(inode) (xem ví dụ về hệ thống tệp trong cây).

Tạo chúng ->alloc_inode và ->destroy_inode trong super_Operation của bạn.

Hãy nhớ rằng bây giờ bạn cần khởi tạo rõ ràng dữ liệu riêng tư
thường là giữa việc gọi iget_locked() và mở khóa inode.

Đến một lúc nào đó điều đó sẽ trở thành bắt buộc.

ZZ0000ZZ

foo_inode_info phải luôn được phân bổ thông qua alloc_inode_sb() thay vì
hơn kmem_cache_alloc() hoặc kmalloc() liên quan đến việc thiết lập bối cảnh lấy lại inode
một cách chính xác.

---

ZZ0000ZZ

Thay đổi phương thức file_system_type (->read_super thành ->get_sb)

->read_super() không còn nữa.  Tương tự cho DECLARE_FSTYPE và DECLARE_FSTYPE_DEV.

Biến foo_read_super() của bạn thành một hàm sẽ trả về 0 trong trường hợp
thành công và số âm trong trường hợp có lỗi (-EINVAL trừ khi bạn có nhiều hơn
giá trị lỗi thông tin cần báo cáo).  Gọi nó là foo_fill_super().  Bây giờ khai báo::

int foo_get_sb(struct file_system_type *fs_type,
	cờ int, const char *dev_name, void *data, struct vfsmount *mnt)
  {
	trả về get_sb_bdev(fs_type, flags, dev_name, data, foo_fill_super,
			   mnt);
  }

(hoặc tương tự với s/bdev/nodev/ hoặc s/bdev/single/, tùy thuộc vào loại
hệ thống tập tin).

Thay thế DECLARE_FSTYPE... bằng trình khởi tạo rõ ràng và đặt ->get_sb làm
foo_get_sb.

---

ZZ0000ZZ

Khóa thay đổi: ->s_vfs_rename_sem chỉ được thực hiện bằng cách đổi tên nhiều thư mục.
Rất có thể không cần thay đổi gì cả, nhưng nếu bạn dựa vào
loại trừ toàn cầu giữa các lần đổi tên cho một số mục đích nội bộ - bạn cần phải
thay đổi khóa bên trong của bạn.  Nếu không thì bảo đảm loại trừ vẫn là
giống nhau (tức là cha mẹ và nạn nhân bị khóa, v.v.).

---

ZZ0000ZZ

Bây giờ chúng ta có sự loại trừ giữa ->lookup() và việc xóa thư mục (bởi
->rmdir() và ->rename()).  Nếu bạn đã từng cần sự loại trừ đó và làm
nó bằng cách khóa bên trong (hầu hết các hệ thống tập tin không thể quan tâm hơn) - bạn
có thể thư giãn khóa của bạn.

---

ZZ0000ZZ

->lookup(), ->truncate(), ->create(), ->unlink(), ->mknod(), ->mkdir(),
->rmdir(), ->link(), ->lseek(), ->symlink(), ->rename()
và ->readdir() hiện được gọi mà không có BKL.  Lấy nó khi nhập cảnh, thả khi trở về
- điều đó sẽ đảm bảo khóa giống như bạn đã từng có.  Nếu phương pháp của bạn hoặc của nó
các bộ phận không cần BKL - tốt hơn nữa, bây giờ bạn có thể thay đổi lock_kernel() và
unlock_kernel() để họ có thể bảo vệ chính xác những gì cần có
được bảo vệ.

---

ZZ0000ZZ

BKL cũng được di chuyển từ các hoạt động xung quanh. BKL đáng lẽ phải được chuyển sang
các hàm fs sb_op riêng lẻ.  Nếu bạn không cần nó, hãy loại bỏ nó.

---

ZZ0000ZZ

việc kiểm tra mục tiêu ->link() không phải là một thư mục được thực hiện bởi người gọi.  cảm nhận
tự do thả nó đi...

---

ZZ0000ZZ

->link() người gọi giữ ->i_mutex trên đối tượng mà chúng ta đang liên kết tới.  Một số của bạn
vấn đề có thể đã kết thúc...

---

ZZ0000ZZ

phương thức file_system_type mới - kill_sb(superblock).  Nếu bạn đang chuyển đổi
một hệ thống tập tin hiện có, hãy đặt nó theo ->fs_flags::

FS_REQUIRES_DEV - kill_block_super
	FS_LITTER - kill_litter_super
	cũng không - kill_anon_super

FS_LITTER đã biến mất - chỉ cần xóa nó khỏi fs_flags.

---

ZZ0000ZZ

FS_SINGLE đã biến mất (thực ra, điều đó đã xảy ra khi ->get_sb()
đã đi vào - và chưa được ghi lại ;-/).  Chỉ cần xóa nó khỏi fs_flags
(và xem mục ->get_sb() để biết các hành động khác).

---

ZZ0000ZZ

->setattr() hiện được gọi mà không có BKL.  Người gọi _always_ giữ ->i_mutex, vì vậy
để ý ->mã lấy ->i_mutex có thể được ->setattr() của bạn sử dụng.
Người gọi thông báo_change() cần ->i_mutex ngay bây giờ.

---

ZZ0000ZZ

Trường super_block mới ZZ0000ZZ cho
hỗ trợ rõ ràng cho việc xuất khẩu, ví dụ: thông qua NFS.  Cấu trúc hoàn toàn
được ghi lại khi khai báo trong include/linux/fs.h và trong
Tài liệu/hệ thống tập tin/nfs/exporting.rst.

Tóm lại, nó cho phép định nghĩa các hoạt động giải mã_fh và mã hóa_fh
để mã hóa và giải mã các thẻ xử lý tệp và cho phép hệ thống tệp sử dụng
một chức năng trợ giúp tiêu chuẩn cho giải mã_fh và cung cấp hệ thống tệp cụ thể
hỗ trợ cho người trợ giúp này, đặc biệt là get_parent.

Theo kế hoạch, điều này sẽ được yêu cầu để xuất khi mã
lắng xuống một chút.

ZZ0000ZZ

s_export_op hiện được yêu cầu để xuất hệ thống tệp.
isof, ext2, ext3, mỡ
có thể được sử dụng làm ví dụ về các hệ thống tập tin rất khác nhau.

---

ZZ0000ZZ

iget4() và lệnh gọi lại read_inode2 đã được thay thế bởi iget5_locked()
có nguyên mẫu sau::

cấu trúc inode *iget5_locked(struct super_block *sb, ino dài không dấu,
				int (ZZ0001ZZ, void *),
				int (ZZ0002ZZ, void *),
				void *dữ liệu);

'kiểm tra' là một chức năng bổ sung có thể được sử dụng khi inode
số không đủ để xác định đối tượng tệp thực tế. 'đặt'
phải là một hàm không chặn để khởi tạo các phần đó của một
inode mới được tạo để cho phép chức năng kiểm tra thành công. 'dữ liệu' là
được chuyển dưới dạng giá trị mờ cho cả hàm kiểm tra và hàm cài đặt.

Khi inode được tạo bởi iget5_locked(), nó sẽ được trả về cùng với
Cờ I_NEW được đặt và vẫn sẽ bị khóa.  Hệ thống tập tin sau đó cần phải hoàn thiện
việc khởi tạo. Khi inode được khởi tạo, nó phải được mở khóa bằng
gọi unlock_new_inode().

Hệ thống tập tin chịu trách nhiệm thiết lập (và có thể kiểm tra) i_ino
khi thích hợp. Ngoài ra còn có một hàm iget_locked đơn giản hơn
chỉ cần lấy số siêu khối và số inode làm đối số và thực hiện
kiểm tra và thiết lập cho bạn.

ví dụ.::

inode = iget_locked(sb, ino);
	if (inode_state_read_once(inode) & I_NEW) {
		lỗi = read_inode_from_disk(inode);
		nếu (lỗi < 0) {
			iget_failed(inode);
			trả lại lỗi;
		}
		unlock_new_inode(inode);
	}

Lưu ý rằng nếu quá trình thiết lập inode mới không thành công thì iget_failed()
nên được gọi trên inode để khiến nó chết và một lỗi thích hợp
nên được chuyển lại cho người gọi.

---

ZZ0000ZZ

->getattr() cuối cùng cũng được sử dụng.  Xem các phiên bản trong nfs, minix, v.v.

---

ZZ0000ZZ

->xác nhận lại() đã biến mất.  Nếu hệ thống tập tin của bạn có nó - hãy cung cấp ->getattr()
và để nó gọi bất cứ thứ gì bạn có là ->revlidate() + (đối với các liên kết tượng trưng
đã ->revalidate()) thêm cuộc gọi vào ->follow_link()/->readlink().

---

ZZ0000ZZ

->Các thay đổi d_parent không còn được BKL bảo vệ nữa.  Truy cập đọc là an toàn
nếu ít nhất một trong những điều sau đây là đúng:

* hệ thống tập tin không có đổi tên thư mục chéo()
	* chúng tôi biết rằng cấp độ gốc đã bị khóa (ví dụ: chúng tôi đang xem xét
	  ->d_parent của đối số ->lookup()).
	* chúng ta được gọi từ ->rename().
	* của trẻ ->d_lock được giữ

Kiểm tra mã của bạn và thêm khóa nếu cần.  Chú ý rằng bất cứ nơi nào
không được bảo vệ bởi các điều kiện trên sẽ rất nguy hiểm ngay cả ở cây cổ thụ - bạn
đã dựa vào BKL và điều đó dễ xảy ra trục trặc.  Cây cổ thụ đã khá
một vài lỗ hổng kiểu đó - quyền truy cập không được bảo vệ vào ->d_parent dẫn đến
bất cứ điều gì từ rất tiếc đến hỏng bộ nhớ im lặng.

---

ZZ0000ZZ

FS_NOMOUNT đã biến mất.  Nếu bạn sử dụng nó - chỉ cần đặt SB_NOUSER trong cờ
(xem rootfs để biết một loại giải pháp và bdev/socket/pipe để biết loại giải pháp khác).

---

ZZ0000ZZ

Sử dụng bdev_read_only(bdev) thay vì is_read_only(kdev).  Cái sau
vẫn còn sống, nhưng chỉ vì sự lộn xộn trong driver/s390/block/dasd.c.
Ngay sau khi được sửa, is_read_only() sẽ chết.

---

ZZ0000ZZ

->permission() hiện được gọi mà không có BKL. Lấy nó khi vào, thả khi
return - điều đó sẽ đảm bảo khóa giống như bạn đã từng có.  Nếu
phương pháp của bạn hoặc các bộ phận của nó không cần BKL - tốt hơn nữa, bây giờ bạn có thể
shift lock_kernel() và unlock_kernel() để chúng bảo vệ
chính xác những gì cần được bảo vệ.

---

ZZ0000ZZ

->statfs() hiện được gọi mà không cần giữ BKL.  BKL lẽ ra phải được
được chuyển sang các hàm fs sb_op riêng lẻ mà không rõ điều đó
thật an toàn để loại bỏ nó.  Nếu bạn không cần nó, hãy loại bỏ nó.

---

ZZ0000ZZ

is_read_only() không còn nữa; thay vào đó hãy sử dụng bdev_read_only().

---

ZZ0000ZZ

destroy_buffers() không còn nữa; sử dụng không hợp lệ_bdev().

---

ZZ0000ZZ

fsync_dev() không còn nữa; sử dụng fsync_bdev().  NOTE: vỡ lvm là
cố ý; ngay khi struct block_device * được truyền bá một cách hợp lý
bằng cách đó việc sửa mã sẽ trở nên tầm thường; cho đến lúc đó không có gì có thể được
xong.

ZZ0000ZZ

chặn việc cắt bớt khi thoát khỏi lỗi từ ->write_begin và ->direct_IO
được chuyển từ các phương thức chung (block_write_begin, cont_write_begin,
nobh_write_begin, blockdev_direct_IO*) cho người gọi.  Hãy nhìn vào
ext2_write_failed và người gọi làm ví dụ.

ZZ0000ZZ

-> cắt ngắn đã biến mất.  Toàn bộ chuỗi cắt ngắn cần phải được
được triển khai trong ->setattr, hiện bắt buộc đối với hệ thống tập tin
thực hiện thay đổi kích thước trên đĩa.  Bắt đầu với một bản sao của inode_setattr cũ
và vmtruncate, và sắp xếp lại chuỗi vmtruncate + foofs_vmtruncate thành
theo thứ tự các khối bằng 0 bằng cách sử dụng block_truncate_page hoặc các trình trợ giúp tương tự,
cập nhật kích thước và cuối cùng là cắt bớt trên đĩa, điều này sẽ không thất bại.
setattr_prepare (trước đây là inode_change_ok) hiện bao gồm kiểm tra kích thước
đối với ATTR_SIZE và phải được gọi ở đầu ->setattr vô điều kiện.

ZZ0000ZZ

->clear_inode() và ->delete_inode() không còn nữa; ->evict_inode() nên
được sử dụng thay thế.  Nó được gọi bất cứ khi nào inode bị loại bỏ, cho dù nó có
liên kết còn lại hay không.  Người gọi thực hiện ZZ0000ZZ loại bỏ bộ đệm trang hoặc liên kết với inode
bộ đệm siêu dữ liệu; phương thức này phải sử dụng truncate_inode_pages_final() để loại bỏ
trong số đó. Người gọi đảm bảo rằng việc ghi lại không đồng bộ không thể chạy cho inode trong khi
(hoặc sau) ->evict_inode() được gọi.

->drop_inode() bây giờ trả về int; nó được gọi vào iput() cuối cùng với
inode->i_lock được giữ và nó trả về true nếu hệ thống tập tin muốn inode đó
bị rơi.  Như trước đây, inode_generic_drop() vẫn là mặc định và nó đã được
được cập nhật phù hợp.  inode_just_drop() cũng còn sống và nó bao gồm
chỉ đơn giản là trả lại 1. Lưu ý rằng tất cả công việc trục xuất thực tế đều được thực hiện bởi người gọi sau
->drop_inode() trả về.

Như trước đây, clear_inode() phải được gọi chính xác một lần trong mỗi lệnh gọi của
->evict_inode() (như trước đây đối với mỗi lệnh gọi ->delete_inode()).  Không giống
trước đây, nếu bạn đang sử dụng bộ đệm siêu dữ liệu liên quan đến inode (tức là
mark_buffer_dirty_inode()), bạn có trách nhiệm gọi
không hợp lệ_inode_buffers() trước clear_inode().

NOTE: kiểm tra i_nlink ở đầu ->write_inode() và thoát ra
nếu nó bằng 0 thì ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ chưa đủ.  Cuối cùng hủy liên kết() và iput()
có thể xảy ra khi inode ở giữa ->write_inode(); ví dụ. nếu bạn mù quáng
giải phóng inode trên đĩa, bạn có thể sẽ làm điều đó trong khi ->write_inode() đang ghi
đến nó.

---

ZZ0000ZZ

.d_delete() bây giờ chỉ thông báo cho dcache biết có nên lưu vào bộ đệm hay không
các nha khoa không được tham chiếu và bây giờ chỉ được gọi khi số lần đếm lại nha khoa chuyển sang
0. Ngay cả khi chuyển đổi hoàn lại 0, nó phải có khả năng chịu được việc bị gọi là 0,
1 hoặc nhiều lần (ví dụ: hằng số, bình thường).

---

ZZ0000ZZ

.d_compare() quy tắc gọi và quy tắc khóa có ý nghĩa đáng kể
đã thay đổi. Đọc tài liệu cập nhật trong Documentation/filesystems/vfs.rst (và
xem ví dụ về các hệ thống tập tin khác) để được hướng dẫn.

---

ZZ0000ZZ

.d_hash() quy ước gọi và khóa có ý nghĩa đáng kể
đã thay đổi. Đọc tài liệu cập nhật trong Documentation/filesystems/vfs.rst (và
xem ví dụ về các hệ thống tập tin khác) để được hướng dẫn.

---

ZZ0000ZZ

dcache_lock không còn nữa, được thay thế bằng những chiếc khóa tinh xảo. Xem fs/dcache.c
để biết chi tiết về những khóa cần thay thế dcache_lock để bảo vệ
những điều cụ thể. Trong hầu hết các trường hợp, hệ thống tập tin chỉ cần ->d_lock,
bảo vệ ZZ0000ZZ trạng thái dcache của một hàm răng nhất định.

---

ZZ0000ZZ

Các hệ thống tập tin phải giải phóng RCU các nút của chúng, nếu chúng có thể được truy cập
thông qua rcu-walk path walk (về cơ bản, nếu tệp có thể có tên đường dẫn trong
không gian tên vfs).

Mặc dù i_dentry và i_rcu chia sẻ bộ nhớ trong một liên minh, chúng tôi sẽ
khởi tạo cái trước trong inode_init_always(), vì vậy hãy để nó một mình trong
cuộc gọi lại.  Trước đây cần phải làm sạch nó ở đó, nhưng giờ thì không còn nữa
(bắt đầu từ 3.2).

---

ZZ0000ZZ

vfs bây giờ cố gắng thực hiện việc đi bộ trên đường ở "chế độ rcu-walk", điều này tránh được
hoạt động nguyên tử và các mối nguy hiểm về khả năng mở rộng trên các răng cưa và nút (xem
Tài liệu/hệ thống tập tin/path-lookup.txt). thay đổi d_hash và d_compare
(ở trên) là ví dụ về những thay đổi cần thiết để hỗ trợ việc này. Để phức tạp hơn
gọi lại hệ thống tập tin, vfs sẽ thoát khỏi chế độ rcu-walk trước lệnh gọi fs, vì vậy
không có thay đổi nào được yêu cầu đối với hệ thống tập tin. Tuy nhiên, việc này tốn kém và mất
lợi ích của chế độ rcu-walk. Chúng tôi sẽ bắt đầu thêm các lệnh gọi lại hệ thống tập tin
có nhận biết về rcu-walk không, được hiển thị bên dưới. Hệ thống tập tin nên tận dụng điều này
nếu có thể.

---

ZZ0000ZZ

d_revalidate là lệnh gọi lại được thực hiện trên mọi phần tử đường dẫn (nếu
hệ thống tập tin cung cấp nó), yêu cầu thoát khỏi chế độ rcu-walk. Cái này
bây giờ có thể được gọi ở chế độ rcu-walk (nd->flags & LOOKUP_RCU). -ECHILD nên
được trả về nếu hệ thống tập tin không thể xử lý rcu-walk. Xem
Documentation/filesystems/vfs.rst để biết thêm chi tiết.

quyền là kiểm tra quyền inode được gọi trên nhiều hoặc tất cả
các nút thư mục trên đường đi bộ (để kiểm tra quyền thực thi). Nó
bây giờ phải nhận biết rcu-walk (mặt nạ & MAY_NOT_BLOCK).  Xem
Documentation/filesystems/vfs.rst để biết thêm chi tiết.

---

ZZ0000ZZ

Trong ->fallocate() bạn phải kiểm tra tùy chọn chế độ được truyền vào. Nếu
hệ thống tập tin không hỗ trợ đục lỗ (phân bổ không gian ở giữa
file), bạn phải trả về -EOPNOTSUPP nếu FALLOC_FL_PUNCH_HOLE được đặt ở chế độ.
Hiện tại bạn chỉ có thể có FALLOC_FL_PUNCH_HOLE với bộ FALLOC_FL_KEEP_SIZE,
vì vậy i_size sẽ không thay đổi khi đục lỗ, ngay cả khi nhấn phần cuối của
tắt một tập tin.

---

ZZ0000ZZ

->get_sb() và ->mount() không còn nữa. Chuyển sang sử dụng ngàm API mới. Xem
Tài liệu/filesystems/mount_api.rst để biết thêm chi tiết.

---

ZZ0000ZZ

->permission() và generic_permission() đã mất cờ
lập luận; thay vì chuyển IPERM_FLAG_RCU, chúng tôi thêm MAY_NOT_BLOCK vào mặt nạ.

generic_permission() cũng đã mất đối số check_acl; Kiểm tra ACL
đã được đưa tới VFS và các hệ thống tập tin cần cung cấp một địa chỉ không phải NULL
->i_op->get_inode_acl để đọc ACL từ đĩa.

---

ZZ0000ZZ

Nếu bạn triển khai ->llseek() của riêng mình, bạn phải xử lý SEEK_HOLE và
SEEK_DATA.  Bạn có thể xử lý việc này bằng cách trả về -EINVAL, nhưng sẽ tốt hơn nếu
ủng hộ nó theo một cách nào đó.  Trình xử lý chung giả định rằng toàn bộ tệp là
data và có một lỗ ảo ở cuối file.  Vì vậy nếu được cung cấp
phần bù nhỏ hơn i_size và SEEK_DATA được chỉ định, trả về cùng phần bù.
Nếu điều trên đúng với phần bù và bạn được cấp SEEK_HOLE, hãy trả lại phần cuối
của tập tin.  Nếu phần bù là i_size hoặc lớn hơn thì trả về -ENXIO trong cả hai trường hợp.

ZZ0000ZZ

Nếu bạn có ->fsync() của riêng mình, bạn phải đảm bảo gọi
filemap_write_and_wait_range() để tất cả các trang bẩn được đồng bộ hóa đúng cách.
Bạn cũng phải nhớ rằng ->fsync() không được gọi khi i_mutex được giữ
nữa, vì vậy nếu bạn yêu cầu khóa i_mutex, bạn phải đảm bảo mang theo nó và
tự mình thả nó ra.

---

ZZ0000ZZ

d_alloc_root() đã biến mất cùng với rất nhiều lỗi do code gây ra
lạm dụng nó.  Thay thế: d_make_root(inode).  Khi thành công d_make_root(inode)
phân bổ và trả về một nha khoa mới được khởi tạo bằng inode được truyền vào.
Khi bị lỗi, NULL được trả về và inode được truyền vào bị loại bỏ nên tham chiếu
to inode được sử dụng trong mọi trường hợp và việc xử lý lỗi không cần thực hiện bất kỳ thao tác dọn dẹp nào
cho inode.  Nếu d_make_root(inode) được truyền vào inode NULL, nó sẽ trả về NULL
và cũng không yêu cầu xử lý lỗi thêm. Cách sử dụng điển hình là::

inode = foofs_new_inode(....);
	s->s_root = d_make_root(inode);
	nếu (!s->s_root)
		/* Không cần gì cho việc dọn dẹp inode */
		trả về -ENOMEM;
	...

---

ZZ0000ZZ

Mụ phù thủy đã chết!  Thôi, dù sao cũng là 2/3.  ->d_revalidate() và
->lookup() làm ZZ0000ZZ lấy struct nameidata nữa; chỉ là những lá cờ

---

ZZ0000ZZ

->create() không lấy ZZ0000ZZ; không giống như trước đây
hai, nó nhận được "nó là O_EXCL hay tương đương?" đối số boolean.  Lưu ý rằng
các hệ thống tập tin cục bộ có thể bỏ qua đối số này - chúng được đảm bảo rằng
đối tượng không tồn tại.  Đó là những thứ từ xa/được phân phối có thể quan tâm ...

---

ZZ0000ZZ

FS_REVAL_DOT đã biến mất; nếu bạn đã từng có nó, hãy thêm ->d_weak_revalidate()
thay vào đó là trong hoạt động nha khoa của bạn.

---

ZZ0000ZZ

vfs_readdir() không còn nữa; thay vào đó hãy chuyển sang iterate_dir()

---

ZZ0000ZZ

->readdir() hiện đã biến mất; chuyển sang ->iterate_shared()

ZZ0000ZZ

vfs_follow_link đã bị xóa.  Hệ thống tập tin phải sử dụng nd_set_link
từ ->follow_link cho các liên kết tượng trưng thông thường hoặc nd_jump_link cho phép thuật
/proc/<pid> liên kết kiểu.

---

ZZ0000ZZ

Cuộc gọi lại iget5_locked()/ilookup5()/ilookup5_nowait() test() từng là
được gọi với cả hai ->i_lock và inode_hash_lock được giữ; trước đây là ZZ0000ZZ
được thực hiện nữa, vì vậy hãy xác minh rằng lệnh gọi lại của bạn không dựa vào nó (không có
của các phiên bản trong cây đã làm).  inode_hash_lock vẫn được giữ,
tất nhiên, vì vậy chúng vẫn được tuần tự hóa việc loại bỏ wrt khỏi hàm băm inode,
cũng như lệnh gọi lại wrt set() của iget5_locked().

---

ZZ0000ZZ

d_materialise_unique() không còn nữa; d_splice_alias() thực hiện mọi thứ bạn
cần bây giờ.  Hãy nhớ rằng họ có thứ tự lập luận trái ngược nhau ;-/

---

ZZ0000ZZ

f_dentry đã biến mất; sử dụng f_path.dentry, hoặc tốt hơn nữa là xem liệu bạn có thể tránh được
nó hoàn toàn.

---

ZZ0000ZZ

không bao giờ gọi ->read() và ->write() trực tiếp; sử dụng __vfs_{đọc,viết} hoặc
giấy gói; thay vì kiểm tra ->write hoặc ->read là NULL, hãy tìm
FMODE_CAN_{WRITE,READ} trong tệp->f_mode.

---

ZZ0000ZZ

_không_ sử dụng new_sync_{đọc,ghi} cho ->đọc/->ghi; để nó đi NULL
thay vào đó.

---

ZZ0000ZZ
	->aio_read/->aio_write không còn nữa.  Sử dụng ->read_iter/->write_iter.

---

ZZ0000ZZ

đối với các liên kết tượng trưng được nhúng ("nhanh"), chỉ cần đặt inode->i_link thành bất cứ nơi nào
nội dung liên kết tượng trưng và sử dụng simple_follow_link() dưới dạng ->follow_link().

---

ZZ0000ZZ

quy ước gọi ->follow_link() đã thay đổi.  Thay vì quay lại
cookie và sử dụng nd_set_link() để lưu trữ nội dung để duyệt qua, chúng tôi quay lại
phần thân để duyệt và lưu trữ cookie bằng cách sử dụng đối số void ** rõ ràng.
nameidata hoàn toàn không được thông qua - nd_jump_link() không cần nó và
nd_[gs]et_link() đã biến mất.

---

ZZ0000ZZ

quy ước gọi ->put_link() đã thay đổi.  Nó nhận được inode thay vì
nha khoa, nó hoàn toàn không nhận được nameidata và nó chỉ được gọi khi cookie
không phải là NULL.  Lưu ý rằng nội dung liên kết không còn tồn tại nữa, vì vậy nếu bạn cần,
lưu trữ nó dưới dạng cookie.

---

ZZ0000ZZ

bất kỳ liên kết tượng trưng nào có thể sử dụng page_follow_link_light/page_put_link() đều phải
có inode_nohighmem(inode) được gọi trước khi mọi thứ có thể bắt đầu chơi với
bộ đệm trang của nó.  Không có trang highmem nào được đưa vào bộ đệm trang như vậy
liên kết tượng trưng.  Điều đó bao gồm bất kỳ việc chèn sẵn nào có thể được thực hiện trong quá trình liên kết tượng trưng
sáng tạo.  page_symlink() sẽ tôn vinh các cờ gfp ánh xạ, vì vậy một lần
bạn đã thực hiện xong inode_nohighmem() thì việc sử dụng nó là an toàn, nhưng nếu bạn phân bổ và
chèn trang theo cách thủ công, hãy đảm bảo sử dụng đúng cờ gfp.

---

ZZ0000ZZ

->follow_link() được thay thế bằng ->get_link(); cùng API, ngoại trừ điều đó

* ->get_link() lấy inode làm đối số riêng
	* ->get_link() có thể được gọi ở chế độ RCU - trong trường hợp đó là NULL
	  nha khoa đã được thông qua

---

ZZ0000ZZ

->get_link() nhận được cấu trúc delay_call ZZ0000ZZ ngay bây giờ và nên làm như vậy
set_delayed_call() nơi nó được sử dụng để đặt ZZ0001ZZ.

->put_link() đã biến mất - chỉ cần cung cấp hàm hủy cho set_delayed_call()
trong ->get_link().

---

ZZ0000ZZ

->getxattr() và xattr_handler.get() nhận nha khoa và inode được chuyển riêng.
nha khoa có thể vẫn chưa được gắn vào inode, vì vậy hãy _not_ sử dụng ->d_inode của nó
trong các trường hợp.  Lý do: !@#!@# security_d_instantiate() cần phải
được gọi trước khi chúng ta gắn răng vào inode.

---

ZZ0000ZZ

các liên kết tượng trưng không còn là các nút duy nhất mà ZZ0000ZZ có i_bdev/i_cdev/
liên minh i_pipe/i_link bị loại bỏ khi loại bỏ inode.  Kết quả là bạn không thể
giả sử rằng giá trị không phải NULL trong ->i_nlink tại ->destroy_inode() ngụ ý rằng
đó là một liên kết tượng trưng.  Việc kiểm tra ->i_mode thực sự cần thiết ngay bây giờ.  Trên cây chúng tôi đã có
để sửa lỗi shmem_destroy_callback() được sử dụng để sử dụng loại phím tắt đó;
hãy cẩn thận vì phím tắt đó không còn hiệu lực nữa.

---

ZZ0000ZZ

->i_mutex được thay thế bằng ->i_rwsem ngay bây giờ.  inode_lock() và cộng sự. làm việc như
họ đã từng - họ chỉ coi đó là độc quyền.  Tuy nhiên, ->lookup() có thể
được gọi với cha mẹ bị khóa chia sẻ.  Các trường hợp của nó không được

* sử dụng riêng d_instantiate) và d_rehash() - sử dụng d_add() hoặc
	  thay vào đó là d_splice_alias().
	* chỉ sử dụng d_rehash() - thay vào đó hãy gọi d_add(new_dentry, NULL).
	* trong trường hợp không chắc chắn khi truy cập (chỉ đọc) vào hệ thống tập tin
	  cấu trúc dữ liệu cần loại trừ vì lý do nào đó, hãy sắp xếp nó
	  chính bạn.  Không có hệ thống tập tin trong cây nào cần điều đó.
	* dựa vào ->d_parent và ->d_name không thay đổi sau khi niềng răng
	  được đưa vào d_add() hoặc d_splice_alias().  Một lần nữa, không ai trong số
	  các trường hợp trong cây dựa vào đó.

Chúng tôi được đảm bảo rằng việc tra cứu cùng tên trong cùng một thư mục
sẽ không xảy ra song song ("tương tự" theo nghĩa ->d_compare() của bạn).
Việc tra cứu các tên khác nhau trong cùng một thư mục có thể và thực sự xảy ra trong
song song bây giờ.

---

ZZ0000ZZ

->iterate_shared() được thêm vào.
Loại trừ ở cấp độ tệp cấu trúc vẫn được cung cấp (cũng như
giữa nó và lseek trên cùng một tệp cấu trúc), nhưng nếu thư mục của bạn
đã được mở nhiều lần, bạn có thể gọi chúng song song.
Loại trừ giữa phương thức đó và tất cả các phương thức sửa đổi thư mục là
tất nhiên là vẫn được cung cấp.

Nếu bạn có bất kỳ cấu trúc dữ liệu trong lõi mỗi inode hoặc mỗi nha khoa nào được sửa đổi
bởi ->iterate_shared(), bạn có thể cần thứ gì đó để tuần tự hóa quyền truy cập
cho họ.  Nếu bạn thực hiện gieo hạt trước dcache, bạn sẽ cần chuyển sang
d_alloc_parallel() cho điều đó; tìm kiếm các ví dụ trong cây.

---

ZZ0000ZZ

->atomic_open() các cuộc gọi không có O_CREAT có thể xảy ra song song.

---

ZZ0000ZZ

->setxattr() và xattr_handler.set() nhận được nha khoa và inode được chuyển riêng.
xattr_handler.set() được chuyển qua vùng tên người dùng của mount inode
được nhìn thấy từ đó hệ thống tập tin có thể idmap i_uid và i_gid tương ứng.
nha khoa có thể vẫn chưa được gắn vào inode, vì vậy hãy _not_ sử dụng ->d_inode của nó
trong các trường hợp.  Lý do: !@#!@# security_d_instantiate() cần phải
được gọi trước khi chúng tôi gắn răng vào inode và !@#!@##!@$!$#!@#$!@$!@$ đập vào
->d_instantiate() không chỉ sử dụng ->getxattr() mà còn cả ->setxattr().

---

ZZ0000ZZ

->d_compare() không còn lấy cha mẹ làm đối số riêng biệt nữa.  Nếu bạn
đã sử dụng nó để tìm cấu trúc super_block có liên quan, dentry->d_sb sẽ
cũng làm việc tốt; nếu nó phức tạp hơn, hãy sử dụng dentry->d_parent.
Chỉ cần cẩn thận đừng cho rằng việc tìm nạp nó nhiều lần sẽ mang lại kết quả
cùng một giá trị - ở chế độ RCU, nó có thể thay đổi theo bạn.

---

ZZ0000ZZ

->rename() có thêm đối số cờ.  Bất kỳ cờ nào không được xử lý bởi
hệ thống tập tin sẽ dẫn đến việc trả về EINVAL.

---


ZZ0000ZZ

->readlink là tùy chọn cho liên kết tượng trưng.  Không đặt, trừ khi hệ thống tập tin cần
để giả mạo thứ gì đó cho readlink(2).

---

ZZ0000ZZ

->getattr() hiện được chuyển qua đường dẫn cấu trúc thay vì vfsmount và
nha khoa riêng biệt và hiện có các đối số request_mask và query_flags
để chỉ định các trường và loại đồng bộ hóa được yêu cầu bởi statx.  Hệ thống tập tin không
hỗ trợ bất kỳ tính năng cụ thể nào của statx có thể bỏ qua các đối số mới.

---

ZZ0000ZZ

->quy ước gọi Atomic_open() đã thay đổi.  Đã qua rồi ZZ0000ZZ,
cùng với FILE_OPENED/FILE_CREATED.  Thay cho những thứ chúng ta có
FMODE_OPENED/FMODE_CREATED, được đặt trong tệp->f_mode.  Ngoài ra, trả lại
giá trị cho trường hợp 'được gọi là finish_no_open(), hãy tự mở nó' đã trở thành
0, không phải 1. Vì bản thân finish_no_open() hiện đang trả về 0, nên phần đó
không cần bất kỳ thay đổi nào trong các trường hợp ->atomic_open().

---

ZZ0000ZZ

alloc_file() bây giờ đã trở thành tĩnh; thay vào đó, hai hàm bao sẽ được sử dụng.
alloc_file_pseudo(inode, vfsmount, name, flags, ops) dành cho các trường hợp
khi nào cần tạo răng giả; đó là phần lớn của alloc_file() cũ
người dùng.  Quy ước gọi: khi thành công, hãy tham chiếu đến tệp cấu trúc mới
được trả về và tham chiếu của người gọi tới inode được gộp vào đó.  Bật
không thành công, ERR_PTR() được trả về và không có tham chiếu nào của người gọi bị ảnh hưởng,
vì vậy người gọi cần loại bỏ tham chiếu inode mà nó đã giữ.
alloc_file_clone(file, flags, ops) không ảnh hưởng đến bất kỳ tham chiếu nào của người gọi.
Nếu thành công, bạn sẽ nhận được một tệp cấu trúc mới chia sẻ ngàm/nh răng với
nguyên bản, bị lỗi - ERR_PTR().

---

ZZ0000ZZ

->clone_file_range() và ->dedupe_file_range đã được thay thế bằng
->remap_file_range().  Xem Tài liệu/filesystems/vfs.rst để biết thêm
thông tin.

---

ZZ0000ZZ

->lookup() các trường hợp thực hiện tương đương với::

nếu (IS_ERR(inode))
		trả về ERR_CAST(inode);
	trả về d_splice_alias(inode, nha khoa);

không cần bận tâm đến việc kiểm tra - d_splice_alias() sẽ thực hiện
điều đúng đắn khi cho ERR_PTR(...) làm inode.  Hơn nữa, vượt qua NULL
inode tới d_splice_alias() cũng sẽ làm điều đúng đắn (tương đương với
d_add(nha khoa, NULL); trả về NULL;), nên những trường hợp đặc biệt đó
cũng không cần điều trị riêng.

---

ZZ0000ZZ

đưa các phần bị trì hoãn RCU của ->destroy_inode() vào một phương thức mới -
->free_inode().  Nếu ->destroy_inode() trở nên trống rỗng - thì càng tốt,
chỉ cần thoát khỏi nó.  Công việc đồng bộ (ví dụ: những việc không thể
được thực hiện từ lệnh gọi lại RCU hoặc bất kỳ WARN_ON() nào mà chúng tôi muốn
dấu vết ngăn xếp) ZZ0000ZZ có thể được chuyển sang ->evict_inode(); tuy nhiên,
điều đó chỉ dành cho những thứ không cần thiết để cân bằng thứ gì đó
được thực hiện bởi ->alloc_inode().  IOW, nếu nó đang dọn dẹp những thứ
có thể đã tích lũy trong suốt vòng đời của inode trong lõi, ->evict_inode()
có thể là phù hợp.

Quy tắc phá hủy inode:

* nếu ->destroy_inode() không phải là NULL, nó sẽ được gọi
	* nếu ->free_inode() không phải là NULL, nó sẽ được lên lịch bởi call_rcu()
	* sự kết hợp của NULL ->destroy_inode và NULL ->free_inode là
	  được coi là NULL/free_inode_nonrcu, để duy trì khả năng tương thích.

Lưu ý rằng lệnh gọi lại (có thể thông qua ->free_inode() hoặc call_rcu() rõ ràng
trong ->destroy_inode()) là ZZ0000ZZ đã ra lệnh phá hủy siêu khối wrt;
Trên thực tế, siêu khối và tất cả các cấu trúc liên quan
có thể đã đi rồi.  Trình điều khiển hệ thống tập tin được đảm bảo ở trạng thái tĩnh
đó, nhưng chỉ vậy thôi.  Giải phóng bộ nhớ khi gọi lại là được; đang làm
nhiều hơn thế là có thể, nhưng cần phải cẩn thận nhiều và tốt nhất là
tránh được.

---

ZZ0000ZZ

DCACHE_RCUACCESS đã biến mất; có độ trễ RCU khi giải phóng răng giả là
mặc định.  DCACHE_NORCU chọn không tham gia và chỉ d_alloc_pseudo() có bất kỳ
doanh nghiệp làm như vậy.

---

ZZ0000ZZ

d_alloc_pseudo() chỉ dành cho nội bộ; sử dụng bên ngoài alloc_file_pseudo() là
rất đáng ngờ (và sẽ không hoạt động trong các mô-đun).  Việc sử dụng như vậy rất có thể
bị viết sai chính tả d_alloc_anon().

---

ZZ0000ZZ

[đáng lẽ phải được thêm vào năm 2016] mặc dù vậy, nhận xét cũ trong finish_open(),
lỗi thoát ra trong các phiên bản ->atomic_open() nên có tệp ZZ0000ZZ fput(),
không có vấn đề gì.  Mọi thứ đều được xử lý bởi người gọi.

---

ZZ0000ZZ

clone_private_mount() hiện trả về một giá trị gắn kết dài hạn, vì vậy hàm hủy thích hợp của
kết quả của nó là kern_unmount() hoặc kern_unmount_array().

---

ZZ0000ZZ

Các đoạn bvec có độ dài bằng 0 không được phép, chúng phải được lọc ra trước
được chuyển tới một iterator.

---

ZZ0000ZZ

Đối với các trình vòng lặp dựa trên bvec bio_iov_iter_get_pages() hiện không sao chép bvecs nhưng
sử dụng cái được cung cấp. Bất kỳ ai phát hành kiocb-I/O đều phải đảm bảo rằng bvec và
tham chiếu trang vẫn tồn tại cho đến khi I/O hoàn thành, tức là cho đến khi ->ki_complete() có
được gọi hoặc trả về với mã không phải -EIOCBQUEUED.

---

ZZ0000ZZ

mnt_want_write_file() bây giờ chỉ có thể được ghép nối với mnt_drop_write_file(),
trong khi trước đây nó cũng có thể được ghép nối với mnt_drop_write().

---

ZZ0000ZZ

iov_iter_copy_from_user_atomic() không còn nữa; sử dụng copy_page_from_iter_atomic().
Sự khác biệt là copy_page_from_iter_atomic() nâng cao trình vòng lặp và
bạn không cần iov_iter_advance() sau nó.  Tuy nhiên, nếu bạn quyết định sử dụng
chỉ một phần dữ liệu thu được, bạn nên thực hiện iov_iter_revert().

---

ZZ0000ZZ

Quy ước gọi file_open_root() đã thay đổi; bây giờ nó có đường dẫn cấu trúc *
thay vì đi qua ngàm và răng riêng biệt.  Đối với những người gọi đã từng
chuyển cặp <mnt, mnt->mnt_root> (tức là gốc của mount đã cho), một trình trợ giúp mới
được cung cấp - file_open_root_mnt().  Người dùng trong cây đã điều chỉnh.

---

ZZ0000ZZ

no_llseek đã biến mất; đừng đặt .llseek ở đó - thay vào đó hãy để nó là NULL.
Kiểm tra "tệp đó có llseek(2) hay nó bị lỗi với ESPIPE"
nên được thực hiện bằng cách xem FMODE_LSEEK trong tệp->f_mode.

---

ZZ0000ZZ

quy ước gọi filldir_t (gọi lại readdir) đã thay đổi.  Thay vì
trả về 0 hoặc -E... nó trả về bool ngay bây giờ.  sai có nghĩa là "không còn nữa" (như -E... được sử dụng
to) và true - "tiếp tục" (bằng 0 trong quy ước gọi cũ).  Lý do:
dù sao thì người gọi cũng không bao giờ xem xét các giá trị -E... cụ thể. -> iterate_shared()
các trường hợp không yêu cầu thay đổi gì cả, tất cả các trường hợp filldir_t trong cây
đã chuyển đổi.

---

ZZ0000ZZ

Quy ước gọi ->tmpfile() đã thay đổi.  Bây giờ nó có một cấu trúc
con trỏ tập tin thay vì con trỏ cấu trúc nha khoa.  d_tmpfile() cũng tương tự
đã thay đổi để đơn giản hóa người gọi.  Tệp đã chuyển ở trạng thái không mở và đang bật
thành công phải được mở trước khi quay lại (ví dụ: bằng cách gọi
finish_open_simple()).

---

ZZ0000ZZ

Quy ước gọi cho ->huge_fault đã thay đổi.  Bây giờ nó mất một trang
đặt hàng thay vì enum page_entry_size và nó có thể được gọi mà không cần
mmap_lock được giữ.  Tất cả người dùng trong cây đã được kiểm tra và dường như không
phụ thuộc vào mmap_lock đang được giữ, nhưng người dùng ngoài cây nên xác minh
cho chính họ.  Nếu họ cần, họ có thể trả lại VM_FAULT_RETRY cho
được gọi với mmap_lock được giữ.

---

ZZ0000ZZ

Thứ tự mở các thiết bị khối và khớp hoặc tạo siêu khối có
đã thay đổi.

Logic cũ mở các thiết bị khối trước rồi mới cố gắng tìm một
siêu khối phù hợp để tái sử dụng dựa trên con trỏ thiết bị khối.

Logic mới cố gắng tìm một siêu khối phù hợp trước tiên dựa trên thiết bị
số và mở thiết bị khối sau đó.

Vì việc mở khối thiết bị không thể xảy ra dưới s_umount do khóa
yêu cầu đặt hàng s_umount hiện bị loại bỏ khi mở các thiết bị khối và
được yêu cầu lại trước khi gọi fill_super().

Theo logic cũ, các trình gắn kết đồng thời sẽ tìm thấy siêu khối trong danh sách
siêu khối cho loại hệ thống tập tin. Kể từ lần mở đầu tiên của thiết bị khối
sẽ giữ s_umount họ sẽ đợi cho đến khi siêu khối ra đời hoặc
đã bị loại bỏ do khởi tạo thất bại.

Vì logic mới giảm xuống, các bộ đếm đồng thời s_umount có thể lấy s_umount và
sẽ quay. Thay vào đó, giờ đây chúng được thực hiện để chờ bằng cách sử dụng chế độ chờ rõ ràng
cơ chế mà không cần phải giữ s_umount.

---

ZZ0000ZZ

Người nắm giữ thiết bị khối bây giờ là siêu khối.

Người nắm giữ thiết bị khối từng là file_system_type nhưng không phải
đặc biệt hữu ích. Không thể chuyển từ thiết bị khối sang sở hữu
siêu khối không khớp với con trỏ thiết bị được lưu trong siêu khối.
Cơ chế này sẽ chỉ hoạt động đối với một thiết bị duy nhất nên lớp khối không thể
tìm siêu khối sở hữu của bất kỳ thiết bị bổ sung nào.

Trong cơ chế cũ, việc tái sử dụng hoặc tạo siêu khối cho thú cưỡi đua(2) và
umount(2) dựa vào file_system_type làm chủ sở hữu. Điều này thật nghiêm trọng
Tuy nhiên, tài liệu không đầy đủ:

(1) Bất kỳ công cụ đếm đồng thời nào có thể lấy được một tham chiếu đang hoạt động trên một
    siêu khối hiện tại được tạo ra để đợi cho đến khi siêu khối trở thành
    sẵn sàng hoặc cho đến khi siêu khối được loại bỏ khỏi danh sách siêu khối của
    loại hệ thống tập tin. Nếu siêu khối đã sẵn sàng, người gọi sẽ đơn giản
    tái sử dụng nó.

(2) Nếu trình đếm đến sau deactive_locked_super() nhưng trước đó
    siêu khối đã bị xóa khỏi danh sách siêu khối của
    loại hệ thống tập tin, trình đếm sẽ đợi cho đến khi siêu khối tắt,
    tái sử dụng thiết bị khối và cấp phát một siêu khối mới.

(3) Nếu trình đếm đến sau deactive_locked_super() và sau đó
    siêu khối đã bị xóa khỏi danh sách siêu khối của
    loại hệ thống tập tin, trình đếm sẽ sử dụng lại thiết bị khối và phân bổ một thiết bị mới
    siêu khối (điểm bd_holder vẫn có thể được đặt thành loại hệ thống tệp).

Bởi vì chủ sở hữu của thiết bị khối là file_system_type bất kỳ đồng thời
người gắn kết có thể mở các thiết bị khối của bất kỳ siêu khối nào giống nhau
file_system_type mà không gặp rủi ro khi nhìn thấy EBUSY vì thiết bị khối đã bị
vẫn được sử dụng bởi một siêu khối khác.

Việc biến siêu khối thành chủ sở hữu của thiết bị khối sẽ thay đổi điều này với tư cách là chủ sở hữu
hiện là một siêu khối duy nhất và do đó không thể chặn các thiết bị được liên kết với nó
được tái sử dụng bởi những người gắn kết đồng thời. Vì vậy, một người đếm đồng thời trong (2) có thể đột nhiên
thấy EBUSY khi cố gắng mở một thiết bị khối có giá đỡ khác
siêu khối.

Do đó, logic mới sẽ đợi cho đến khi siêu khối và các thiết bị tắt trong
->kill_sb(). Loại bỏ siêu khối khỏi danh sách siêu khối của
loại hệ thống tập tin hiện được chuyển đến điểm sau khi đóng thiết bị:

(1) Bất kỳ người đăng ký đồng thời nào cũng quản lý để lấy một tài liệu tham khảo hoạt động trên một tài liệu hiện có
    siêu khối được thực hiện để đợi cho đến khi siêu khối sẵn sàng hoặc cho đến khi
    siêu khối và tất cả các thiết bị đều tắt trong ->kill_sb(). Nếu
    superblock đã sẵn sàng, người gọi sẽ chỉ cần sử dụng lại nó.

(2) Nếu trình đếm đến sau deactive_locked_super() nhưng trước
    siêu khối đã bị xóa khỏi danh sách siêu khối của
    loại hệ thống tập tin, trình đếm được thực hiện để đợi cho đến khi siêu khối và
    các thiết bị bị tắt trong ->kill_sb() và siêu khối bị xóa khỏi
    danh sách các siêu khối thuộc loại hệ thống tập tin. Người định giá sẽ phân bổ một
    superblock và giành quyền sở hữu thiết bị khối (con trỏ bd_holder của
    thiết bị khối sẽ được đặt thành siêu khối mới được phân bổ).

(3) Trường hợp này bây giờ được thu gọn thành (2) vì siêu khối vẫn còn trong danh sách
    siêu khối thuộc loại hệ thống tập tin cho đến khi tất cả các thiết bị tắt trong
    ->kill_sb(). Nói cách khác, nếu siêu khối không có trong danh sách
    siêu khối của loại hệ thống tập tin nữa thì nó đã từ bỏ quyền sở hữu
    tất cả các thiết bị khối liên quan (con trỏ bd_holder là NULL).

Vì đây là thay đổi cấp độ VFS nên nó không gây ra hậu quả thực tế nào đối với hệ thống tập tin
ngoài ra tất cả chúng đều phải sử dụng một trong những kill_litter_super() được cung cấp,
những người trợ giúp kill_anon_super() hoặc kill_block_super().

---

ZZ0000ZZ

Thứ tự khóa đã được thay đổi để s_umount lại được xếp hạng trên open_mutex.
Tất cả những nơi s_umount được sử dụng trong open_mutex đã được sửa.

---

ZZ0000ZZ

xuất_hoạt động ->encode_fh() không còn triển khai mặc định nữa
mã hóa các thẻ xử lý tệp FILEID_INO32_GEN*.
Các hệ thống tập tin sử dụng cách triển khai mặc định có thể sử dụng trình trợ giúp chung
generic_encode_ino32_fh() một cách rõ ràng.

---

ZZ0000ZZ

Nếu ->rename() cập nhật .. khi di chuyển qua thư mục cần loại trừ với
sửa đổi thư mục, ZZ0000ZZ có khóa thư mục con được đề cập trong
->rename() - việc này đã được người gọi thực hiện [mục đó lẽ ra phải được thêm vào
28ceeeda130f "fs: Khóa các thư mục đã di chuyển"].

---

ZZ0000ZZ

Trên cùng thư mục ->rename() bản cập nhật (tautoological) của .. không được bảo vệ
bằng bất kỳ ổ khóa nào; đừng làm điều đó nếu cha mẹ cũ giống với cha mẹ mới.
Chúng tôi thực sự không thể khóa hai thư mục con trong cùng một thư mục đổi tên - không phải không có
bế tắc.

---

ZZ0000ZZ

lock_rename() và lock_rename_child() có thể thất bại trong trường hợp thư mục chéo, nếu
lập luận của họ không có tổ tiên chung.  Trong trường hợp đó ERR_PTR(-EXDEV)
được trả lại mà không có khóa nào được lấy.  Người dùng trong cây đã được cập nhật; những cái ngoài cây
sẽ cần phải làm như vậy.

---

ZZ0000ZZ

Danh sách trẻ em neo đậu tại nha khoa phụ huynh giờ đã được chuyển thành danh sách hlist.
Tên trường đã được thay đổi (->d_children/->d_sib thay vì ->d_subdirs/->d_child
đối với các mục neo/mục tương ứng), vì vậy mọi địa điểm bị ảnh hưởng sẽ bị phát hiện ngay lập tức
bằng trình biên dịch.

---

ZZ0000ZZ

->d_delete() hiện được gọi cho các răng giả có ->d_lock được giữ
và số tiền hoàn lại bằng 0. Họ không được phép thả/lấy lại ->d_lock.
Không có trường hợp nào trong cây thực hiện bất kỳ điều gì thuộc loại đó.  Hãy chắc chắn rằng của bạn không...

---

ZZ0000ZZ

Các phiên bản ->d_prune() hiện được gọi mà không cần ->d_lock được giữ trên phiên bản mẹ.
->d_lock trên răng giả vẫn được giữ; nếu bạn cần loại trừ theo phụ huynh (không có
trong số các phiên bản trong cây đã làm), hãy sử dụng khóa xoay của riêng bạn.

->d_iput() và ->d_release() được gọi khi hàm răng của nạn nhân vẫn còn trong
danh sách con cái của cha mẹ.  Nó vẫn chưa được băm, bị đánh dấu là đã bị giết, v.v., chỉ là không
đã được xóa khỏi ->d_children của cha mẹ.

Bất kỳ ai duyệt qua danh sách các phần tử con đều cần phải biết về
những chiếc răng giả bị chết một nửa có thể được nhìn thấy ở đó; lấy ->d_lock theo ý muốn đó
thấy chúng âm, chưa băm và có số lần đếm âm, điều đó có nghĩa là hầu hết
trong số những người dùng trong kernel dù sao cũng đã làm điều đúng đắn mà không cần bất kỳ sự điều chỉnh nào.

---

ZZ0000ZZ

Chặn đóng băng và rã đông thiết bị đã được chuyển sang hoạt động của ngăn chứa.

Trước thay đổi này, get_active_super() sẽ chỉ có thể tìm thấy
siêu khối của thiết bị khối chính, tức là siêu khối được lưu trữ trong sb->s_bdev. Chặn
việc đóng băng thiết bị hiện hoạt động đối với mọi thiết bị khối thuộc sở hữu của một siêu khối nhất định, không phải
chỉ là thiết bị khối chính. Trình trợ giúp get_active_super() và bd_fsfreeze_sb
con trỏ đã biến mất.

---

ZZ0000ZZ

set_blocksize() bây giờ lấy tệp cấu trúc đã mở thay vì struct block_device
và nó ZZ0000ZZ được mở độc quyền.

---

ZZ0000ZZ

->d_revalidate() nhận thêm hai đối số - inode của thư mục mẹ và
tên nha khoa của chúng tôi dự kiến ​​sẽ có.  Cả hai đều ổn định (thư mục được ghim vào
không phải trường hợp RCU và sẽ ở lại trong suốt cuộc gọi trong trường hợp RCU và tên
được đảm bảo không thay đổi).  Ví dụ của bạn không phải sử dụng
cũng vậy, nhưng nó thường giúp tránh được nhiều điều đau đớn.
Lưu ý rằng mặc dù tên->tên ổn định và NUL bị chấm dứt, nó có thể (và
thường sẽ) có name->name[name->len] bằng '/' thay vì '\0' -
trong trường hợp bình thường, nó trỏ vào tên đường dẫn đang được tra cứu.
NOTE: nếu bạn cần thứ gì đó như đường dẫn đầy đủ từ thư mục gốc của hệ thống tập tin,
bạn vẫn tự mình làm - điều này hỗ trợ trong các trường hợp đơn giản, nhưng không phải vậy
ma thuật.

---

ZZ0000ZZ

kern_path_locked() và user_path_locked() không còn trả về giá trị âm nữa
nha khoa nên điều này không cần phải kiểm tra.  Nếu không tìm được tên,
ERR_PTR(-ENOENT) được trả về.

---

ZZ0000ZZ

lookup_one_qstr_excl() được thay đổi để trả về lỗi trong nhiều trường hợp hơn, vì vậy
những điều kiện này không yêu cầu kiểm tra rõ ràng:

- nếu LOOKUP_CREATE được cho là NOT thì hàm nha khoa sẽ không âm,
   Thay vào đó, ERR_PTR(-ENOENT) được trả về
 - nếu LOOKUP_EXCL được đưa ra thì hàm nha khoa sẽ không dương tính,
   ERR_PTR(-EEXIST) được trả về thay thế

LOOKUP_EXCL bây giờ có nghĩa là "mục tiêu không được tồn tại".  Nó có thể được kết hợp với
LOOK_CREATE hoặc LOOKUP_RENAME_TARGET.

---

ZZ0000ZZ
không hợp lệ_inodes() không còn nữa, hãy sử dụng evict_inodes() thay thế.

---

ZZ0000ZZ

->mkdir() bây giờ trả về một chiếc răng giả.  Nếu inode được tạo được tìm thấy
đã có trong bộ nhớ đệm và có một răng giả (thường là IS_ROOT()), nó sẽ cần phải
được ghép vào tên cụ thể thay cho răng giả nhất định. Nha khoa đó
bây giờ cần phải trả lại.  Nếu sử dụng răng giả ban đầu, NULL sẽ
được trả lại.  Mọi lỗi sẽ được trả về bằng ERR_PTR().

Nói chung, các hệ thống tập tin sử dụng d_instantiate_new() để cài đặt phiên bản mới
inode có thể trả về NULL một cách an toàn.  Các hệ thống tập tin có thể không có nút I_NEW
nên sử dụng d_drop();d_splice_alias() và trả về kết quả sau.

Nếu một răng giả tích cực không thể được trả lại vì lý do nào đó, in-kernel
các máy khách như cachefiles, nfsd, smb/server có thể không hoạt động lý tưởng nhưng
sẽ không an toàn.

---

ZZ0000ZZ

lookup_one(), lookup_one_unlocked(), lookup_one_posit_unlocked() ngay bây giờ
lấy qstr thay vì tên và len.  Những cái này, không phải "one_len"
phiên bản, nên được sử dụng bất cứ khi nào truy cập hệ thống tập tin từ bên ngoài
hệ thống tập tin đó, thông qua một điểm gắn kết - sẽ có mnt_idmap.

---

ZZ0000ZZ

Các hàm try_lookup_one_len(), lookup_one_len(),
lookup_one_len_unlocked() và lookup_posit_unlocked() đã được
được đổi tên thành try_lookup_noperm(), lookup_noperm(),
lookup_noperm_unlocked(), lookup_noperm_posit_unlocked().  Bây giờ họ
lấy qstr thay vì tên và độ dài riêng biệt.  QSTR() có thể được sử dụng
khi cần strlen() cho độ dài.

Chức năng này không còn thực hiện bất kỳ việc kiểm tra quyền nào nữa - trước đây chúng
đã kiểm tra xem người gọi có quyền 'X' đối với phụ huynh hay không.  Họ phải
ONLY được sử dụng nội bộ bởi chính hệ thống tập tin khi nó biết điều đó
các quyền không liên quan hoặc trong bối cảnh cần phải kiểm tra quyền
đã được thực hiện như sau vfs_path_parent_lookup()

---

ZZ0000ZZ

d_hash_and_lookup() không còn được xuất hoặc khả dụng bên ngoài VFS nữa.
Thay vào đó hãy sử dụng try_lookup_noperm().  Điều này thêm xác nhận tên và mất
các đối số theo thứ tự ngược lại nhưng giống hệt nhau.

Việc sử dụng try_lookup_noperm() sẽ yêu cầu phải bao gồm linux/namei.h.

---

ZZ0000ZZ

Quy ước gọi ->d_automount() đã thay đổi; chúng ta nên lấy ZZ0000ZZ
một tham chiếu bổ sung cho thú cưỡi mới - nó sẽ được trả về với số lần đếm lại 1.

---

Collect_mounts()/drop_collected_mounts()/iterate_mounts() hiện không còn nữa.
Thay thế là coll_paths()/drop_collected_path(), không có gì đặc biệt
cần có trình vòng lặp.  Thay vì cây gắn kết nhân bản, giao diện mới trả về
một mảng đường dẫn cấu trúc, một đường dẫn cho mỗi mount coll_mounts() sẽ có
được tạo ra.  Các đường dẫn cấu trúc này trỏ đến các vị trí trong không gian tên của người gọi
đó sẽ là gốc rễ của thú cưỡi nhân bản.

---

ZZ0000ZZ

Nếu hệ thống tập tin của bạn đặt nha khoa mặc định, hãy sử dụng set_default_d_op()
thay vì cài đặt thủ công sb->s_d_op.

---

ZZ0000ZZ

d_set_d_op() không còn được xuất (hoặc công khai nữa); _nếu_
hệ thống tập tin của bạn thực sự cần điều đó, hãy sử dụng d_splice_alias_ops()
để thiết lập chúng.  Tốt hơn hết, hãy suy nghĩ kỹ xem bạn có cần sự khác biệt không
->d_op cho các răng giả khác nhau - nếu không, chỉ cần sử dụng set_default_d_op()
tại thời điểm gắn kết và hoàn thành việc đó.  Hiện nay Procfs là duy nhất
thứ thực sự cần ->d_op khác nhau giữa các răng giả.

---

ZZ0000ZZ

Lệnh gọi lại hoạt động tệp mmap() không còn được dùng nữa để thay thế
mmap_prepare(). Điều này chuyển một con trỏ tới vm_area_desc để gọi lại
thay vì VMA, vì VMA ở giai đoạn này chưa hợp lệ.

vm_area_desc cung cấp thông tin cần thiết tối thiểu cho hệ thống tệp
để khởi tạo trạng thái dựa trên ánh xạ bộ nhớ của vùng được hỗ trợ bằng tệp và xuất ra
các tham số cho hệ thống tập tin để thiết lập trạng thái này.

Trong hầu hết các trường hợp, đây là tất cả những gì cần thiết cho một hệ thống tập tin. Tuy nhiên, nếu
một hệ thống tập tin cần thực hiện một thao tác như điền trước các bảng trang,
thì hành động đó có thể được chỉ định trong trường hành động vm_area_desc->, có thể
được định cấu hình bằng cách sử dụng trình trợ giúp mmap_action_*().

---

ZZ0000ZZ

Một số chức năng được đổi tên:

- kern_path_locked -> start_removing_path
- kern_path_create -> start_creating_path
- user_path_create -> start_creating_user_path
- user_path_locked_at -> start_removing_user_path_at
- done_path_create -> end_creating_path

---

ZZ0000ZZ

Quy ước gọi vfs_parse_fs_string() đã thay đổi; nó có ZZ0000ZZ
mất độ dài nữa (giá trị ? strlen(value) : 0 được sử dụng).  Nếu bạn muốn
có độ dài khác, hãy sử dụng

vfs_parse_fs_qstr(fc, key, &QSTR_LEN(value, len))

thay vì.

---

ZZ0000ZZ

vfs_mkdir() bây giờ trả về một hàm nha khoa - hàm được trả về bởi ->mkdir().  Nếu
hàm răng đó khác với hàm răng được đưa vào, kể cả nếu nó
một con trỏ nha khoa IS_ERR(), nha khoa ban đầu là dput().

Khi vfs_mkdir() trả về lỗi và do đó cả dputs() bản gốc
nha khoa và không cung cấp vật thay thế, nó cũng mở khóa cha mẹ.
Do đó, giá trị trả về từ vfs_mkdir() có thể được chuyển tới
end_creating() và cha mẹ sẽ được mở khóa chính xác khi cần thiết.

---

ZZ0000ZZ

kill_litter_super() không còn nữa; chuyển đổi sang sử dụng DCACHE_PERSISTENT (như tất cả
hệ thống tập tin trong cây đã thực hiện).

---

ZZ0000ZZ

Bây giờ ->setlease() file_Operation phải được đặt rõ ràng để cung cấp
hỗ trợ cho thuê. Khi được đặt thành NULL, kernel bây giờ sẽ trả về -EINVAL thành
cố gắng thiết lập một hợp đồng thuê. Các hệ thống tập tin muốn sử dụng hợp đồng thuê nội bộ kernel
việc triển khai nên đặt nó thành generic_setlease().

---

ZZ0000ZZ

các nguyên hàm fs/namei.c sử dụng các tham chiếu hệ thống tập tin (do_renameat2(),
do_linkat(), do_symlinkat(), do_mkdirat(), do_mknodat(), do_unlinkat()
và do_rmdir()) đã biến mất; chúng được thay thế bằng những chất tương tự không tiêu thụ
(tên tệp_renameat2(), v.v.)
Người gọi được điều chỉnh - trách nhiệm bỏ tên tập tin thuộc về
cho họ bây giờ.

---

ZZ0000ZZ

readlink_copy() hiện yêu cầu độ dài liên kết làm đối số thứ 4. Nhu cầu về độ dài đã nói
để khớp với những gì strlen() sẽ trả về nếu nó được chạy trên chuỗi.

Tuy nhiên, nếu chuỗi có thể truy cập tự do trong suốt thời gian hoạt động của inode
trọn đời, thay vào đó hãy cân nhắc sử dụng inode_set_cached_link().

---

ZZ0000ZZ

lookup_one_qstr_excl() không còn được xuất - sử dụng start_creating() hoặc
tương tự.
---

ZZ0000ZZ

lock_rename(), lock_rename_child(), unlock_rename() đều không
sẵn có lâu hơn.  Sử dụng start_renaming() hoặc tương tự.

