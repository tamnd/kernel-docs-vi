.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
Khóa
=======

Văn bản bên dưới mô tả các quy tắc khóa cho các phương pháp liên quan đến VFS.
Nó (được cho là) ​​cập nhật. ZZ0000ZZ, nếu bạn thay đổi bất cứ điều gì trong
nguyên mẫu hoặc giao thức khóa - cập nhật tệp này. Và cập nhật các thông tin liên quan
các phiên bản trong cây, đừng để việc đó cho người duy trì hệ thống tập tin/thiết bị/
v.v. Ít nhất, hãy đưa danh sách các trường hợp đáng ngờ vào cuối tập tin này.
Đừng biến nó thành nhật ký - những người duy trì mã ngoài luồng phải
có thể sử dụng khác biệt (1).

Điều hiện đang thiếu ở đây: thao tác ổ cắm. Alexey?

nha khoa_hoạt động
=================

nguyên mẫu::

int (ZZ0000ZZ, const struct qstr *,
			    struct nha khoa *, unsigned int);
	int (ZZ0001ZZ, int không dấu);
	int(ZZ0002ZZ, struct qstr*);
	int (ZZ0003ZZ,
			unsigned int, const char ZZ0004ZZ);
	int (ZZ0005ZZ);
	int (ZZ0006ZZ);
	khoảng trống (ZZ0007ZZ);
	void (ZZ0008ZZ, cấu trúc inode *);
	char *(*d_dname)((struct nha khoa *dentry, char *buffer, int buflen);
	struct vfsmount *(*d_automount)(đường dẫn struct *đường dẫn);
	int (ZZ0012ZZ, bool);
	cấu trúc nha khoa *(*d_real)(struct nha khoa *, loại enum d_real_type);
	bool (ZZ0014ZZ);
	khoảng trống (ZZ0015ZZ);

quy tắc khóa:

===================================== =============== =========
ops đổi tên_lock ->d_lock có thể chặn rcu-walk
===================================== =============== =========
d_revalidate: không không có (ref-walk) có thể
d_weak_revalidate: không không có không
d_hash không không không có thể
d_compare: vâng không không có lẽ
d_delete: không có không không
d_init: không không có không
d_release: không không có không
d_prune: không có không không
d_iput: không không có không
d_dname: không không không không
d_automount: không không có không
d_manage: không không có (ref-walk) có thể
d_real không không có không
d_unalias_trylock vâng không không không
d_unalias_unlock vâng không không không
===================================== =============== =========

inode_hoạt động
================

nguyên mẫu::

int (ZZ0000ZZ, struct inode ZZ0001ZZ,umode_t, bool);
	struct nha khoa * (ZZ0002ZZ,struct nha khoa *, unsigned int);
	int (ZZ0003ZZ,struct inode ZZ0004ZZ);
	int (ZZ0005ZZ,struct nha *);
	int (ZZ0006ZZ, struct inode ZZ0007ZZ,const char *);
	cấu trúc nha khoa *(*mkdir) (struct mnt_idmap ZZ0009ZZ,struct nha khoa *,umode_t);
	int (ZZ0010ZZ,struct nha *);
	int (ZZ0011ZZ, cấu trúc inode ZZ0012ZZ,umode_t,dev_t);
	int (ZZ0013ZZ, cấu trúc inode ZZ0014ZZ,
			cấu trúc inode ZZ0015ZZ, unsigned int);
	int (ZZ0016ZZ, char __user *,int);
	const char *(*get_link) (struct nha ZZ0018ZZ, struct delay_call *);
	khoảng trống (ZZ0019ZZ);
	int(ZZ0020ZZ, struct inode*, int, unsigned int);
	cấu trúc posix_acl * (ZZ0021ZZ, int, bool);
	int (ZZ0022ZZ, cấu trúc nha khoa ZZ0023ZZ);
	int (ZZ0024ZZ, đường dẫn cấu trúc const ZZ0025ZZ, u32, unsigned int);
	ssize_t (ZZ0026ZZ, char *, size_t);
	int (ZZ0027ZZ, struct fiemap_extent_info *, u64 start, u64 len);
	khoảng trống (*update_time)(struct inode *inode, loại enum fs_update_time,
			    cờ int);
	khoảng trống (*sync_lazytime)(struct inode *inode);
	int (ZZ0030ZZ, cấu trúc nha khoa *,
				tệp cấu trúc *, open_flag không dấu,
				umode_t create_mode);
	int (ZZ0031ZZ, cấu trúc inode *,
			tệp cấu trúc *, umode_t);
	int (*fileattr_set)(struct mnt_idmap *idmap,
			    cấu trúc nha khoa *dentry, struct file_kattr *fa);
	int (*fileattr_get)(struct dentry *dentry, struct file_kattr *fa);
	struct posix_acl*(ZZ0035ZZ, struct nha khoa*, int);
	struct offset_ctx *(*get_offset_ctx)(struct inode *inode);

quy tắc khóa:
	tất cả có thể chặn

======================================================================
hoạt động i_rwsem(inode)
======================================================================
tra cứu: chia sẻ
tạo: độc quyền
liên kết: độc quyền (cả hai)
mknod: độc quyền
liên kết tượng trưng: độc quyền
mkdir: độc quyền
hủy liên kết: độc quyền (cả hai)
rmdir: độc quyền (cả hai) (xem bên dưới)
đổi tên: độc quyền (cả cha mẹ, một số con cái) (xem bên dưới)
liên kết đọc: không
get_link: không
setattr: độc quyền
quyền: không (có thể không chặn nếu được gọi ở chế độ rcu-walk)
get_inode_acl: không
get_acl: không
getattr: không
listxattr: không
bản đồ phim: không
update_time: không
sync_lazytime: không
Atomic_open: được chia sẻ (độc quyền nếu O_CREAT được đặt trong cờ mở)
tmpfile: không
fileattr_get: không hoặc độc quyền
fileattr_set: độc quyền
get_offset_ctx không
======================================================================


Ngoài ra, ->rmdir(), ->unlink() và ->rename() có ->i_rwsem
	độc quyền trên nạn nhân.
	thư mục chéo ->rename() có (mỗi siêu khối) ->s_vfs_rename_sem.
	->unlink() và ->rename() có ->i_rwsem độc quyền trên tất cả các thư mục không phải thư mục
	có liên quan.
	->rename() có ->i_rwsem độc quyền trên bất kỳ thư mục con nào thay đổi cha mẹ.

Xem Tài liệu/hệ thống tập tin/thư mục-locking.rst để thảo luận chi tiết hơn
của sơ đồ khóa cho các hoạt động thư mục.

hoạt động xattr_handler
========================

nguyên mẫu::

bool (*list)(struct dentry *dentry);
	int (*get)(const struct xattr_handler *handler, struct nha khoa *dentry,
		   cấu trúc inode *inode, const char *name, void *buffer,
		   kích thước size_t);
	int (*set)(const struct xattr_handler *handler,
                   cấu trúc mnt_idmap *idmap,
                   cấu trúc nha khoa *dentry, struct inode *inode, const char *name,
                   const void *buffer, size_t, int flag);

quy tắc khóa:
	tất cả có thể chặn

===== ================
hoạt động i_rwsem(inode)
===== ================
danh sách: không
nhận được: không
bộ: độc quyền
===== ================

siêu hoạt động
================

nguyên mẫu::

cấu trúc inode *(*alloc_inode)(struct super_block *sb);
	khoảng trống (ZZ0001ZZ);
	khoảng trống (ZZ0002ZZ);
	void (ZZ0003ZZ, cờ int);
	int (ZZ0004ZZ, struct writeback_control *wbc);
	int (ZZ0005ZZ);
	khoảng trống (ZZ0006ZZ);
	khoảng trống (ZZ0007ZZ);
	int (*sync_fs)(struct super_block *sb, chờ int);
	int (ZZ0009ZZ);
	int (ZZ0010ZZ);
	int(ZZ0011ZZ, struct kstatfs*);
	khoảng trống (ZZ0012ZZ);
	int (ZZ0013ZZ, cấu trúc nha khoa *);
	ssize_t (ZZ0014ZZ, int, char *, size_t, loff_t);
	ssize_t (ZZ0015ZZ, int, const char *, size_t, loff_t);

quy tắc khóa:
	Tất cả có thể chặn [không đúng sự thật, xem bên dưới]

======================= ============= ===========================
ops_umount lưu ý
======================= ============= ===========================
phân bổ_inode:
free_inode: được gọi từ cuộc gọi lại RCU
hủy_inode:
dirty_inode:
viết_inode:
drop_inode: !!!inode->i_lock!!!
đuổi_inode:
put_super: viết
sync_fs: đọc
đóng băng_fs: viết
unfreeze_fs: viết
statfs: có thể(đọc) (xem bên dưới)
umount_begin: không
show_options: không (namespace_sem)
Quota_read: không (xem bên dưới)
Quota_write: không (xem bên dưới)
======================= ============= ===========================

->statfs() có s_umount (được chia sẻ) khi được gọi bởi ustat(2) (gốc hoặc
compat), nhưng đó là sự cố của API xấu; s_umount được sử dụng để ghim
siêu khối ngừng hoạt động khi chúng tôi chỉ có dev_t do vùng người dùng cấp cho chúng tôi để
xác định siêu khối  Mọi thứ khác (statfs(), fstatfs(), v.v.)
không giữ được nó khi gọi ->statfs() - siêu khối bị ghim xuống
bằng cách giải quyết tên đường dẫn được truyền tới syscall.

Các hàm ->quota_read() và ->quota_write() đều được đảm bảo
là những người duy nhất hoạt động trên tệp hạn ngạch theo mã hạn ngạch (thông qua
dqio_sem) (trừ khi quản trị viên thực sự muốn làm hỏng điều gì đó và
ghi vào các tập tin hạn ngạch có hạn ngạch). Để biết các chi tiết khác về khóa
xem thêm phần dquot_Operations.

file_system_type
================

nguyên mẫu::

khoảng trống (ZZ0000ZZ);

quy tắc khóa:

======= ==========
hoạt động có thể chặn
======= ==========
kill_sb vâng
======= ==========

->kill_sb() sử dụng một siêu khối bị khóa ghi, tất cả việc tắt máy có hoạt động trên nó không,
mở khóa và loại bỏ tham chiếu.

địa chỉ_space_hoạt động
========================
nguyên mẫu::

int (ZZ0001ZZ, cấu trúc folio *);
	int(ZZ0002ZZ, struct writeback_control *);
	bool (ZZ0003ZZ, struct folio *folio);
	khoảng trống (ZZ0004ZZ);
	int (ZZ0005ZZ, struct address_space *ánh xạ,
				loff_t pos, len không dấu,
				cấu trúc folio **foliop, void **fsdata);
	int (ZZ0006ZZ, struct address_space *ánh xạ,
				loff_t pos, len không dấu, sao chép không dấu,
				cấu trúc folio *folio, void *fsdata);
	ngành_t (ZZ0008ZZ, ngành_t);
	void (ZZ0009ZZ, size_t bắt đầu, size_t len);
	bool (ZZ0010ZZ, gfp_t);
	khoảng trống (ZZ0011ZZ);
	int (ZZ0012ZZ, struct iov_iter *iter);
	int (ZZ0013ZZ, cấu trúc folio *dst,
			struct folio *src, enum Migrate_mode);
	int (ZZ0014ZZ);
	bool (ZZ0015ZZ, size_t từ, số lượng size_t);
	int (ZZ0016ZZ, cấu trúc folio *);
	int (*swap_activate)(struct swap_info_struct *sis, tệp cấu trúc *f, sector_t *span)
	int (ZZ0019ZZ);
	int (*swap_rw)(struct kiocb *iocb, struct iov_iter *iter);

quy tắc khóa:
	Tất cả ngoại trừ dirty_folio và free_folio đều có thể chặn

=============================================== ===========================
ops folio đã khóa i_rwsem không hợp lệ_lock
=============================================== ===========================
read_folio: vâng, mở khóa được chia sẻ
trang viết:
dirty_folio: có thể
đọc trước: có, mở khóa được chia sẻ
write_begin: khóa độc quyền folio
write_end: vâng, mở khóa độc quyền
bản đồ:
không hợp lệ_folio: có độc quyền
phát hành_folio: có
free_folio: vâng
trực tiếp_IO:
di chuyển_folio: có (cả hai)
launder_folio: vâng
is_partially_uptodate: có
error_remove_folio: có
trao đổi_kích hoạt: không
swap_deactivate: không
swap_rw: vâng, mở khóa
=============================================== ===========================

->write_begin(), ->write_end() và ->read_folio() có thể được gọi từ
trình xử lý yêu cầu (/dev/loop).

->read_folio() mở khóa folio, đồng bộ hoặc thông qua I/O
hoàn thành.

->readahead() mở khóa các folio mà I/O được thử như ->read_folio().

->writepages() được sử dụng để ghi lại định kỳ và để khởi tạo hệ thống
hoạt động đồng bộ.  address_space phải bắt đầu I/O ít nhất
Các trang ZZ0000ZZ.  ZZ0001ZZ phải được giảm dần cho mỗi trang
được viết.  Việc triển khai address_space có thể ghi nhiều hơn (hoặc ít hơn)
trang hơn ZZ0002ZZ yêu cầu, nhưng nó phải cố gắng ở mức độ gần hợp lý.
Nếu nr_to_write là NULL, tất cả các trang bẩn phải được viết.

các trang ghi chỉ nên _chỉ_ viết các trang có trong
ánh xạ->i_pages.

->dirty_folio() được gọi từ nhiều nơi khác nhau trong kernel khi
folio mục tiêu được đánh dấu là cần viết lại.  Folio không thể được
bị cắt bớt vì người gọi giữ khóa folio hoặc người gọi
đã tìm thấy folio trong khi giữ khóa bảng trang sẽ chặn
cắt ngắn.

->bmap() hiện đang được sử dụng bởi ioctl() (FIBMAP) cũ do một số người cung cấp
hệ thống tập tin và bởi bộ trao đổi. Cái sau cuối cùng sẽ biến mất.  Làm ơn,
hãy giữ nguyên như vậy và đừng tạo ra những người gọi mới.

->invalidate_folio() được gọi khi hệ thống tập tin phải cố gắng loại bỏ
một số hoặc tất cả vùng đệm của trang khi nó bị cắt bớt. Nó
trả về 0 khi thành công.  Hệ thống tập tin phải có được độc quyền
không hợp lệ_lock trước khi vô hiệu hóa bộ đệm trang bằng cách cắt ngắn/đục lỗ
đường dẫn (và do đó gọi vào ->invalidate_folio) để chặn các cuộc đua giữa trang
vô hiệu hóa bộ đệm và chức năng điền bộ đệm trang (lỗi, đọc, ...).

->release_folio() được gọi khi MM muốn thực hiện thay đổi đối với
folio sẽ làm mất hiệu lực dữ liệu riêng tư của hệ thống tập tin.  Ví dụ,
nó có thể sắp bị xóa khỏi address_space hoặc bị chia tách.  trang bìa
đã bị khóa và không được viết lại.  Nó có thể bị bẩn.  tham số gfp
thường không được sử dụng để phân bổ mà đúng hơn là để chỉ ra những gì
hệ thống tập tin có thể làm để cố gắng giải phóng dữ liệu riêng tư.  Hệ thống tập tin có thể
trả về false để chỉ ra rằng dữ liệu riêng tư của folio không thể được giải phóng.
Nếu nó trả về true thì nó đã xóa dữ liệu riêng tư khỏi
tờ giấy.  Nếu hệ thống tập tin không cung cấp phương thức ->release_folio,
pagecache sẽ cho rằng dữ liệu riêng tư là buffer_heads và gọi
try_to_free_buffers().

->free_folio() được gọi khi kernel đã bỏ folio
từ bộ đệm trang.

->launder_folio() có thể được gọi trước khi phát hành folio nếu
nó vẫn bị phát hiện là bẩn. Nó trả về 0 nếu folio thành công
được làm sạch hoặc một giá trị lỗi nếu không. Lưu ý rằng để ngăn chặn folio
được ánh xạ trở lại và làm lại, nó cần phải được khóa
trong toàn bộ hoạt động.

->swap_activate() sẽ được gọi để chuẩn bị cho việc trao đổi tệp đã cho.  Nó
phải thực hiện bất kỳ sự xác nhận và chuẩn bị nào cần thiết để đảm bảo rằng
việc ghi có thể được thực hiện với sự phân bổ bộ nhớ tối thiểu.  Nó nên gọi
add_swap_extent() hoặc trình trợ giúp iomap_swapfile_activate() và trả về
số lượng phạm vi được thêm vào.  Nếu IO phải được gửi qua
->swap_rw(), cần đặt SWP_FS_OPS, nếu không IO sẽ được gửi
trực tiếp đến thiết bị khối ZZ0000ZZ.

->swap_deactivate() sẽ được gọi trong sys_swapoff()
đường dẫn sau ->swap_activate() trả về thành công.

->swap_rw sẽ được gọi cho IO trao đổi nếu SWP_FS_OPS được thiết lập bởi ->swap_activate().

tập tin_lock_hoạt động
====================

nguyên mẫu::

void (ZZ0000ZZ, struct file_lock *);
	khoảng trống (ZZ0001ZZ);


quy tắc khóa:

================================= ==========
ops inode->i_lock có thể chặn
================================= ==========
fl_copy_lock: có không
fl_release_private: có lẽ có thể[1]_
================================= ==========

.. [1]:
   ->fl_release_private for flock or POSIX locks is currently allowed
   to block. Leases however can still be freed while the i_lock is held and
   so fl_release_private called on a lease should not block.

lock_manager_hoạt động
=======================

nguyên mẫu::

khoảng trống (ZZ0000ZZ);  /*bỏ chặn cuộc gọi lại */
	int(ZZ0001ZZ, struct file_lock*, int);
	khoảng trống (ZZ0002ZZ); /* break_lease gọi lại */
	int (ZZ0003ZZ*, int);
	bool (ZZ0004ZZ);
        bool (ZZ0005ZZ);
        void (*lm_expire_lock)(void);

quy tắc khóa:

======================= ================================ ==========
ops flc_lock bị chặn_lock_lock có thể chặn
======================= ================================ ==========
lm_notify: không có không
lm_grant: không không không
lm_break: vâng không không
lm_change vâng không không
lm_breaker_owns_lease: vâng không không
lm_lock_expirable có không không
lm_expire_lock không không có
lm_open_conflict vâng không không
======================= ================================ ==========

đệm_head
===========

nguyên mẫu::

khoảng trống (*b_end_io)(struct buffer_head *bh, int cập nhật);

quy tắc khóa:

được gọi từ các ngắt. Nói cách khác, ở đây cần phải hết sức cẩn thận.
bh đã bị khóa, nhưng đó là tất cả những gì chúng tôi có ở đây. Hiện tại chỉ có RAID1,
highmem, fs/buffer.c và fs/ntfs/aops.c đang cung cấp những thứ này. Chặn thiết bị
gọi phương thức này sau khi hoàn thành IO.

block_device_hoạt động
=======================
nguyên mẫu::

int (ZZ0000ZZ, fmode_t);
	int (ZZ0001ZZ, fmode_t);
	int (ZZ0002ZZ, fmode_t, không dấu, dài không dấu);
	int (ZZ0003ZZ, fmode_t, không dấu, dài không dấu);
	int (ZZ0004ZZ, ngành_t, void **,
				dài không dấu *);
	khoảng trống (ZZ0005ZZ);
	int (ZZ0006ZZ, struct hd_geometry *);
	void (ZZ0007ZZ, dài không dấu);

quy tắc khóa:

=============================================
rất tiếc open_mutex
=============================================
mở: vâng
phát hành: vâng
ioctl: không
compat_ioctl: không
direct_access: không
unlock_native_capacity: không
getgeo: không
swap_slot_free_notify: không (xem bên dưới)
=============================================

swap_slot_free_notify được gọi bằng swap_lock và đôi khi là khóa trang
được tổ chức.


hoạt động tập tin
===============

nguyên mẫu::

loff_t (ZZ0001ZZ, loff_t, int);
	ssize_t (ZZ0002ZZ, char __user ZZ0003ZZ);
	ssize_t (ZZ0004ZZ, const char __user ZZ0005ZZ);
	ssize_t (ZZ0006ZZ, struct iov_iter *);
	ssize_t (ZZ0007ZZ, struct iov_iter *);
	int (*iopoll) (struct kiocb *kiocb, quay bool);
	int (ZZ0009ZZ, struct dir_context *);
	__poll_t (ZZ0010ZZ, cấu trúc poll_table_struct *);
	dài (ZZ0011ZZ, int không dấu, dài không dấu);
	dài (ZZ0012ZZ, int không dấu, dài không dấu);
	int (ZZ0013ZZ, struct vm_area_struct *);
	int (ZZ0014ZZ, tệp cấu trúc *);
	int (ZZ0015ZZ);
	int (ZZ0016ZZ, tệp cấu trúc *);
	int (ZZ0017ZZ, bắt đầu loff_t, kết thúc loff_t, int datasync);
	int (ZZ0018ZZ, int);
	int(ZZ0019ZZ, int, struct file_lock *);
	dài không dấu (ZZ0020ZZ, dài không dấu,
			dài không dấu, dài không dấu, dài không dấu);
	int (*check_flags)(int);
	int(ZZ0021ZZ, int, struct file_lock *);
	ssize_t (ZZ0022ZZ, tệp cấu trúc ZZ0023ZZ,
			size_t, int không dấu);
	kích thước_t (ZZ0024ZZ, loff_t ZZ0025ZZ,
			size_t, int không dấu);
	int (ZZ0026ZZ, dài, struct file_lock ZZ0000ZZ);
	dài (ZZ0027ZZ, int, loff_t, loff_t);
	void (*show_fdinfo)(struct seq_file *m, tệp cấu trúc *f);
	không dấu (ZZ0029ZZ);
	ssize_t (ZZ0030ZZ, loff_t, tệp cấu trúc *,
			loff_t, size_t, int không dấu);
	loff_t (*remap_file_range)(struct file *file_in, loff_t pos_in,
			tập tin cấu trúc *file_out, loff_t pos_out,
			loff_t len, unsigned int remap_flags);
	int (ZZ0032ZZ, loff_t, loff_t, int);

quy tắc khóa:
	Tất cả có thể chặn.

->khóa llseek() đã chuyển từ llseek sang llseek riêng lẻ
triển khai.  Nếu fs của bạn không sử dụng generic_file_llseek, bạn
cần lấy và giải phóng các khóa thích hợp trong ->llseek() của bạn.
Đối với nhiều hệ thống tập tin, việc lấy inode có thể là an toàn
mutex hoặc chỉ sử dụng i_size_read() thay thế.
Lưu ý: điều này không bảo vệ file->f_pos trước những sửa đổi đồng thời
vì đây là điều mà không gian người dùng phải quan tâm.

->iterate_shared() được gọi với i_rwsem được giữ để đọc và với
tập tin f_pos_lock được giữ độc quyền

->fasync() chịu trách nhiệm duy trì bit FASYNC trong filp->f_flags.
Hầu hết các phiên bản đều gọi fasync_helper(), thực hiện việc bảo trì đó, vì vậy nó
thông thường không phải là điều người ta cần phải lo lắng.  Giá trị trả về > 0 sẽ là
được ánh xạ tới 0 trong lớp VFS.

->readdir() và ->ioctl() trên các thư mục phải được thay đổi. Lý tưởng nhất là chúng ta sẽ
di chuyển ->readdir() sang inode_Operation và sử dụng một phương thức riêng cho thư mục
->ioctl() hoặc tiêu diệt hoàn toàn cái sau. Một trong những vấn đề là đối với
bất cứ thứ gì giống với Union-mount, chúng tôi sẽ không có tệp cấu trúc cho tất cả
thành phần. Và còn nhiều lý do khác khiến giao diện hiện tại trở nên lộn xộn...

-> việc đọc trên các thư mục có lẽ phải biến mất - chúng ta chỉ nên thực thi -EISDIR
trong sys_read() và bạn bè.

->hoạt động giải quyết nên gọi generic_setlease() trước hoặc sau khi cài đặt
hợp đồng thuê trong hệ thống tập tin riêng lẻ để ghi lại kết quả của
hoạt động

->việc triển khai sai sót phải thực sự cẩn thận để duy trì bộ nhớ đệm của trang
tính nhất quán khi đục lỗ hoặc thực hiện các thao tác khác làm mất hiệu lực
nội dung bộ đệm trang. Thông thường hệ thống tập tin cần gọi
truncate_inode_pages_range() để vô hiệu hóa phạm vi liên quan của bộ đệm trang.
Tuy nhiên, hệ thống tập tin thường cũng cần cập nhật nội bộ (và trên đĩa)
xem phần bù tập tin -> ánh xạ khối đĩa. Cho đến khi bản cập nhật này kết thúc,
hệ thống tập tin cần chặn lỗi trang và đọc từ việc tải lại trang cũ
nội dung bộ nhớ đệm từ đĩa. Vì VFS có được ánh xạ->invalidate_lock trong
chế độ chia sẻ khi tải trang từ đĩa (filemap_fault(), filemap_read(),
các đường dẫn đã đọc trước), việc triển khai dự phòng phải lấy không hợp lệ_lock để
ngăn chặn việc tải lại.

->copy_file_range và ->remap_file_range triển khai cần phải tuần tự hóa
chống lại việc sửa đổi dữ liệu tập tin trong khi hoạt động đang chạy. cho
chặn các thay đổi thông qua write(2) và các hoạt động tương tự inode->i_rwsem có thể
đã sử dụng. Để chặn các thay đổi đối với nội dung tệp thông qua ánh xạ bộ nhớ trong quá trình
hoạt động, hệ thống tập tin phải lấy ánh xạ->invalidate_lock để phối hợp
với ->page_mkwrite.

dquot_hoạt động
================

nguyên mẫu::

int (ZZ0000ZZ);
	int (ZZ0001ZZ);
	int (ZZ0002ZZ);
	int (ZZ0003ZZ);
	int (ZZ0004ZZ, int);

Các hoạt động này ít nhiều nhằm mục đích bao bọc các chức năng để đảm bảo
một khóa thích hợp sẽ ghi hệ thống tập tin và gọi các hoạt động hạn ngạch chung.

Hệ thống tập tin nào sẽ mong đợi từ các hàm hạn ngạch chung:

======================================================
ops đệ quy FS Giữ khóa khi được gọi
======================================================
write_dquot: vâng dqonoff_sem hoặc dqptr_sem
thu được_dquot: có dqonoff_sem hoặc dqptr_sem
Release_dquot: vâng dqonoff_sem hoặc dqptr_sem
mark_dirty: không -
write_info: vâng dqonoff_sem
======================================================

Đệ quy FS có nghĩa là gọi ->quota_read() và ->quota_write() từ siêu khối
hoạt động.

Bạn có thể tìm thêm thông tin chi tiết về khóa hạn ngạch trong fs/dquot.c.

vm_hoạt động_struct
====================

nguyên mẫu::

khoảng trống (ZZ0000ZZ);
	khoảng trống (ZZ0001ZZ);
	vm_fault_t (ZZ0002ZZ);
	vm_fault_t (ZZ0003ZZ, thứ tự int không dấu);
	vm_fault_t (ZZ0004ZZ, bắt đầu pgoff_t, kết thúc pgoff_t);
	vm_fault_t (ZZ0005ZZ, struct vm_fault *);
	vm_fault_t (ZZ0006ZZ, struct vm_fault *);
	int (ZZ0007ZZ, dài không dấu, void*, int, int);

quy tắc khóa:

=====================================================
ops mmap_lock PageLocked(trang)
=====================================================
mở: viết
đóng: đọc/ghi
lỗi: đọc có thể quay lại khi trang bị khóa
Huge_fault: có thể đọc
map_pages: có thể đọc
page_mkwrite: đọc có thể quay lại khi trang bị khóa
pfn_mkwrite: đọc
truy cập: đọc
=====================================================

->fault() được gọi khi một pte không tồn tại trước đó sắp bị lỗi
in. Hệ thống tập tin phải tìm và trả về trang được liên kết với thông tin được truyền vào
"pgoff" trong cấu trúc vm_fault. Nếu có khả năng trang đó có thể
bị cắt ngắn và/hoặc vô hiệu, thì hệ thống tập tin phải khóa không hợp lệ_lock,
sau đó đảm bảo trang chưa bị cắt bớt (invalidate_lock sẽ chặn
cắt ngắn tiếp theo), sau đó quay lại với VM_FAULT_LOCKED và trang
bị khóa. VM sẽ mở khóa trang.

->huge_fault() được gọi khi không có mục PUD hoặc PMD nào hiện diện.  Cái này
cung cấp cho hệ thống tập tin cơ hội cài đặt trang có kích thước PUD hoặc PMD.
Hệ thống tập tin cũng có thể sử dụng phương thức ->fault để trả về trang có kích thước PMD,
vì vậy việc thực hiện chức năng này có thể không cần thiết.  Đặc biệt,
hệ thống tập tin không nên gọi filemap_fault() từ ->huge_fault().
mmap_lock có thể không được giữ khi phương thức này được gọi.

->map_pages() được gọi khi VM yêu cầu ánh xạ các trang dễ truy cập.
Hệ thống tập tin sẽ tìm và ánh xạ các trang được liên kết với phần bù từ "start_pgoff"
cho đến "end_pgoff". ->map_pages() được gọi với khóa RCU được giữ và phải
không chặn.  Nếu không thể truy cập một trang mà không bị chặn,
hệ thống tập tin nên bỏ qua nó. Hệ thống tập tin nên sử dụng set_pte_range() để thiết lập
mục nhập bảng trang. Con trỏ tới mục liên kết với trang được chuyển vào
Trường "pte" trong cấu trúc vm_fault. Con trỏ tới các mục cho các giá trị bù trừ khác
nên được tính toán tương ứng với "pte".

->page_mkwrite() được gọi khi pte chỉ đọc trước đó sắp trở thành
có thể viết được. Hệ thống tập tin một lần nữa phải đảm bảo rằng không có
cắt bớt/vô hiệu hóa các chủng tộc hoặc các chủng tộc có hoạt động như ->remap_file_range
hoặc ->copy_file_range, sau đó quay lại với trang bị khóa. Thông thường
ánh xạ->invalidate_lock phù hợp để tuần tự hóa thích hợp. Nếu trang có
bị cắt bớt, hệ thống tập tin sẽ không tra cứu một trang mới như ->fault()
xử lý, nhưng chỉ cần quay lại bằng VM_FAULT_NOPAGE, điều này sẽ khiến VM
thử lại lỗi.

->pfn_mkwrite() giống như page_mkwrite nhưng khi pte là
VM_PFNMAP hoặc VM_MIXEDMAP với mục nhập ít trang. Lợi nhuận kỳ vọng là
VM_FAULT_NOPAGE. Hoặc một trong các loại VM_FAULT_ERROR. Hành vi mặc định
sau lệnh gọi này là thực hiện pte đọc-ghi, trừ khi pfn_mkwrite trả về
một lỗi.

->access() được gọi khi get_user_pages() không thành công
access_process_vm(), thường được sử dụng để gỡ lỗi một quy trình thông qua
/proc/pid/mem hoặc ptrace.  Chức năng này chỉ cần thiết cho
VM_IO | VM_PFNMAP VMAs.

--------------------------------------------------------------------------------

thứ đáng ngờ

(nếu bạn làm vỡ thứ gì đó hoặc nhận thấy nó bị hỏng mà không tự mình sửa chữa
- ít nhất hãy đặt nó ở đây)
