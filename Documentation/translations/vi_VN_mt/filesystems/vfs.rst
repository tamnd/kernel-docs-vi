.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/vfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Tổng quan về hệ thống tệp ảo Linux
=========================================

Tác giả gốc: Richard Gooch <rgooch@atnf.csiro.au>

- Bản quyền (C) 1999 Richard Gooch
- Bản quyền (C) 2005 Pekka Enberg


Giới thiệu
============

Hệ thống tệp ảo (còn được gọi là Chuyển đổi hệ thống tệp ảo) là
lớp phần mềm trong kernel cung cấp giao diện hệ thống tập tin
tới các chương trình không gian người dùng.  Nó cũng cung cấp một sự trừu tượng trong
kernel cho phép các triển khai hệ thống tập tin khác nhau cùng tồn tại.

Hệ thống VFS gọi open(2), stat(2), read(2), write(2), chmod(2), v.v.
được gọi từ một bối cảnh quá trình.  Khóa hệ thống tập tin được mô tả trong
tài liệu Documentation/filesystems/locking.rst.


Bộ nhớ đệm mục nhập thư mục (dcache)
------------------------------

VFS triển khai hệ thống open(2), stat(2), chmod(2) và tương tự
cuộc gọi.  Đối số tên đường dẫn được truyền cho chúng được VFS sử dụng
để tìm kiếm thông qua bộ đệm mục nhập thư mục (còn được gọi là bộ nhớ nha khoa
bộ đệm hoặc dcache).  Điều này cung cấp một cơ chế tra cứu rất nhanh để
dịch tên đường dẫn (tên tệp) sang một nha khoa cụ thể.  Nha khoa trực tiếp
trong RAM và không bao giờ được lưu vào đĩa: chúng chỉ tồn tại để thực hiện.

Bộ đệm nha khoa có nghĩa là một chế độ xem toàn bộ không gian tệp của bạn.  Như
hầu hết các máy tính không thể lắp tất cả các răng trong RAM cùng một lúc, một số
bit của bộ đệm bị thiếu.  Để giải quyết tên đường dẫn của bạn thành một
nha khoa, VFS có thể phải tạo ra các nha khoa trên đường đi,
và sau đó tải inode.  Điều này được thực hiện bằng cách tra cứu inode.


Đối tượng Inode
----------------

Một nha khoa riêng lẻ thường có một con trỏ tới một nút.  Inode là
các đối tượng hệ thống tập tin như tập tin thông thường, thư mục, FIFO và các đối tượng khác
quái vật.  Chúng tồn tại trên đĩa (đối với hệ thống tập tin thiết bị khối) hoặc
trong bộ nhớ (đối với hệ thống tập tin giả).  Inode sống trên đĩa
được sao chép vào bộ nhớ khi được yêu cầu và các thay đổi đối với inode được thực hiện
ghi lại vào đĩa.  Một nút có thể được trỏ tới bởi nhiều nút
dentries (ví dụ như liên kết cứng, làm điều này).

Để tra cứu một inode yêu cầu VFS gọi phương thức lookup() của
inode thư mục mẹ.  Phương pháp này được cài đặt bởi cụ thể
triển khai hệ thống tập tin mà inode tồn tại. Khi VFS có
cần có nha khoa (và do đó là inode), chúng ta có thể làm tất cả những việc nhàm chán đó
như mở(2) tệp hoặc stat(2) tệp để xem dữ liệu inode.  các
Thao tác stat(2) khá đơn giản: một khi VFS có ngà răng, nó sẽ
xem qua dữ liệu inode và chuyển một số dữ liệu đó trở lại không gian người dùng.


Đối tượng tệp
---------------

Mở một tệp yêu cầu một thao tác khác: cấp phát tệp
cấu trúc (đây là cách triển khai phía kernel của bộ mô tả tệp).
Cấu trúc tệp mới được phân bổ được khởi tạo bằng một con trỏ tới
nha khoa và một tập hợp các chức năng thành viên hoạt động tập tin.  Đây là
lấy từ dữ liệu inode.  Phương thức tệp open() sau đó được gọi để
việc triển khai hệ thống tập tin cụ thể có thể thực hiện công việc của nó.  Bạn có thể thấy điều đó
đây là một công tắc khác được thực hiện bởi VFS.  Cấu trúc tập tin là
được đặt vào bảng mô tả tệp cho quy trình.

Đọc, ghi và đóng tệp (và các thao tác VFS khác)
được thực hiện bằng cách sử dụng bộ mô tả tệp không gian người dùng để lấy thông tin thích hợp
cấu trúc tệp, sau đó gọi phương thức cấu trúc tệp được yêu cầu để
làm bất cứ điều gì được yêu cầu.  Miễn là tập tin được mở, nó sẽ giữ nguyên
nha khoa đang được sử dụng, điều này có nghĩa là inode VFS vẫn đang được sử dụng.


Đăng ký và gắn hệ thống tập tin
=====================================

Để đăng ký và hủy đăng ký hệ thống tập tin, hãy sử dụng API sau
chức năng:

.. code-block:: c

	#include <linux/fs.h>

	extern int register_filesystem(struct file_system_type *);
	extern int unregister_filesystem(struct file_system_type *);

Cấu trúc file_system_type được truyền mô tả hệ thống tệp của bạn.  Khi một
yêu cầu được thực hiện để gắn hệ thống tập tin vào một thư mục trong
không gian tên, VFS sẽ gọi phương thức get_tree() thích hợp cho
hệ thống tập tin cụ thể.  Xem Tài liệu/hệ thống tập tin/mount_api.rst
để biết thêm chi tiết.

Bạn có thể thấy tất cả các hệ thống tập tin được đăng ký vào kernel trong
tập tin /proc/filesystems.


cấu trúc file_system_type
-----------------------

Điều này mô tả hệ thống tập tin.  Sau đây
thành viên được xác định:

.. code-block:: c

	struct file_system_type {
		const char *name;
		int fs_flags;
		int (*init_fs_context)(struct fs_context *);
		const struct fs_parameter_spec *parameters;
		void (*kill_sb) (struct super_block *);
		struct module *owner;
		struct file_system_type * next;
		struct hlist_head fs_supers;

		struct lock_class_key s_lock_key;
		struct lock_class_key s_umount_key;
		struct lock_class_key s_vfs_rename_key;
		struct lock_class_key s_writers_key[SB_FREEZE_LEVELS];

		struct lock_class_key i_lock_key;
		struct lock_class_key i_mutex_key;
		struct lock_class_key invalidate_lock_key;
		struct lock_class_key i_mutex_dir_key;
	};

ZZ0000ZZ
	tên của loại hệ thống tập tin, chẳng hạn như "ext2", "iso9660",
	"msdos" v.v.

ZZ0000ZZ
	các cờ khác nhau (ví dụ FS_REQUIRES_DEV, FS_NO_DCACHE, v.v.)

ZZ0000ZZ
	Khởi tạo các trường 'struct fs_context' ->ops và ->fs_private với
	dữ liệu cụ thể của hệ thống tập tin.

ZZ0000ZZ
	Con trỏ tới mảng mô tả tham số hệ thống tập tin
	'cấu trúc fs_parameter_spec'.
	Thông tin thêm trong Tài liệu/hệ thống tập tin/mount_api.rst.

ZZ0000ZZ
	phương thức gọi khi có một phiên bản của hệ thống tập tin này
	tắt


ZZ0000ZZ
	để sử dụng VFS nội bộ: bạn nên khởi tạo cái này thành THIS_MODULE
	trong hầu hết các trường hợp.

ZZ0000ZZ
	để sử dụng VFS nội bộ: bạn nên khởi tạo cái này thành NULL

ZZ0000ZZ
	để sử dụng VFS nội bộ: danh sách các phiên bản hệ thống tập tin (siêu khối)

s_lock_key, s_umount_key, s_vfs_rename_key, s_writers_key,
  i_lock_key, i_mutex_key, không hợp lệ_lock_key, i_mutex_dir_key: lockdep cụ thể

Đối tượng siêu khối
=====================

Một đối tượng siêu khối đại diện cho một hệ thống tập tin được gắn kết.


cấu trúc siêu hoạt động
-----------------------

Phần này mô tả cách VFS có thể thao tác siêu khối của bạn
hệ thống tập tin.  Các thành viên sau đây được xác định:

.. code-block:: c

	struct super_operations {
		struct inode *(*alloc_inode)(struct super_block *sb);
		void (*destroy_inode)(struct inode *);
		void (*free_inode)(struct inode *);

		void (*dirty_inode) (struct inode *, int flags);
		int (*write_inode) (struct inode *, struct writeback_control *wbc);
		int (*drop_inode) (struct inode *);
		void (*evict_inode) (struct inode *);
		void (*put_super) (struct super_block *);
		int (*sync_fs)(struct super_block *sb, int wait);
		int (*freeze_super) (struct super_block *sb,
					enum freeze_holder who);
		int (*freeze_fs) (struct super_block *);
		int (*thaw_super) (struct super_block *sb,
					enum freeze_wholder who);
		int (*unfreeze_fs) (struct super_block *);
		int (*statfs) (struct dentry *, struct kstatfs *);
		void (*umount_begin) (struct super_block *);

		int (*show_options)(struct seq_file *, struct dentry *);
		int (*show_devname)(struct seq_file *, struct dentry *);
		int (*show_path)(struct seq_file *, struct dentry *);
		int (*show_stats)(struct seq_file *, struct dentry *);

		ssize_t (*quota_read)(struct super_block *, int, char *, size_t, loff_t);
		ssize_t (*quota_write)(struct super_block *, int, const char *, size_t, loff_t);
		struct dquot **(*get_dquots)(struct inode *);

		long (*nr_cached_objects)(struct super_block *,
					struct shrink_control *);
		long (*free_cached_objects)(struct super_block *,
					struct shrink_control *);
	};

Tất cả các phương thức được gọi mà không có bất kỳ khóa nào được giữ, trừ khi có cách khác
ghi nhận.  Điều này có nghĩa là hầu hết các phương pháp đều có thể chặn một cách an toàn.  Tất cả các phương pháp đều
chỉ được gọi từ bối cảnh quy trình (tức là không phải từ trình xử lý ngắt
hoặc nửa dưới).

ZZ0000ZZ
	phương thức này được gọi bởi alloc_inode() để cấp phát bộ nhớ cho
	struct inode và khởi tạo nó.  Nếu chức năng này không
	được xác định, một 'inode cấu trúc' đơn giản sẽ được phân bổ.  Thông thường
	alloc_inode sẽ được sử dụng để phân bổ cấu trúc lớn hơn
	chứa một 'struct inode' được nhúng bên trong nó.

ZZ0000ZZ
	phương thức này được gọi bởi destroy_inode() để giải phóng tài nguyên
	được phân bổ cho struct inode.  Nó chỉ được yêu cầu nếu
	->alloc_inode đã được xác định và chỉ cần hoàn tác mọi thứ được thực hiện bởi
	->alloc_inode.

ZZ0000ZZ
	phương pháp này được gọi từ cuộc gọi lại RCU. Nếu bạn sử dụng call_rcu()
	trong ->destroy_inode để giải phóng bộ nhớ 'struct inode', thì đó là
	tốt hơn để giải phóng bộ nhớ trong phương pháp này.

ZZ0000ZZ
	phương pháp này được VFS gọi khi một nút được đánh dấu là bẩn.
	Điều này đặc biệt dành cho việc bản thân inode bị đánh dấu bẩn,
	không phải dữ liệu của nó.  Nếu bản cập nhật cần được duy trì bởi fdatasync(),
	thì I_DIRTY_DATASYNC sẽ được đặt trong đối số cờ.
	I_DIRTY_TIME sẽ được đặt trong cờ trong trường hợp thời gian lười biếng được bật
	và struct inode đã được cập nhật nhiều lần kể từ lần cuối ->dirty_inode
	gọi.

ZZ0000ZZ
	phương thức này được gọi khi VFS cần ghi inode vào
	đĩa.  Tham số thứ hai cho biết liệu có nên ghi hay không
	có đồng bộ hay không, không phải tất cả các hệ thống tập tin đều kiểm tra cờ này.

ZZ0000ZZ
	được gọi khi quyền truy cập cuối cùng vào nút bị hủy, với
	inode->i_lock spinlock được giữ.

Phương thức này phải là NULL (hệ thống tập tin UNIX bình thường
	ngữ nghĩa) hoặc "inode_just_drop" (đối với các hệ thống tập tin thực hiện
	không muốn lưu các inode vào bộ nhớ đệm - khiến cho "delete_inode" luôn ở đó
	được gọi bất kể giá trị của i_nlink)

Hành vi "inode_just_drop()" tương đương với hành vi cũ
	thực hành sử dụng "force_delete" trong trường hợp put_inode(), nhưng
	không có các cuộc đua mà phương pháp "force_delete()" có.

ZZ0000ZZ
	được gọi khi VFS muốn loại bỏ một inode. Người gọi thực hiện
	ZZ0001ZZ loại bỏ bộ đệm siêu dữ liệu liên quan đến pagecache hoặc inode;
	phương thức này phải sử dụng truncate_inode_pages_final() để loại bỏ
	trong số đó. Người gọi đảm bảo không thể chạy tính năng ghi lại không đồng bộ
	inode while (hoặc sau) ->evict_inode() được gọi. Không bắt buộc.

ZZ0000ZZ
	được gọi khi VFS muốn giải phóng siêu khối
	(tức là ngắt kết nối).  Điều này được gọi khi khóa siêu khối được giữ

ZZ0000ZZ
	được gọi khi VFS đang ghi tất cả dữ liệu bẩn liên quan đến một
	siêu khối.  Tham số thứ hai cho biết liệu phương thức
	nên đợi cho đến khi việc ghi ra được hoàn tất.  Không bắt buộc.

ZZ0000ZZ
	Được gọi thay vì ->freeze_fs gọi lại nếu được cung cấp.
	Điểm khác biệt chính là ->freeze_super được gọi mà không cần lấy
	down_write(&sb->s_umount). Nếu hệ thống tập tin thực hiện nó và muốn
	->freeze_fs cũng được gọi thì nó phải gọi ->freeze_fs
	rõ ràng từ cuộc gọi lại này. Không bắt buộc.

ZZ0000ZZ
	được gọi khi VFS đang khóa một hệ thống tập tin và buộc nó vào một
	trạng thái nhất quán.  Phương pháp này hiện đang được sử dụng bởi Logical
	Trình quản lý âm lượng (LVM) và ioctl(FIFREEZE). Không bắt buộc.

ZZ0000ZZ
	được gọi khi VFS đang mở khóa hệ thống tập tin và làm cho nó có thể ghi được
	một lần nữa sau ->freeze_super. Không bắt buộc.

ZZ0000ZZ
	được gọi khi VFS đang mở khóa hệ thống tập tin và làm cho nó có thể ghi được
	lại sau ->freeze_fs. Không bắt buộc.

ZZ0000ZZ
	được gọi khi VFS cần lấy số liệu thống kê hệ thống tập tin.

ZZ0000ZZ
	được gọi khi VFS đang ngắt kết nối hệ thống tập tin.

ZZ0000ZZ
	được VFS gọi để hiển thị các tùy chọn gắn kết cho /proc/<pid>/mounts
	và /proc/<pid>/mountinfo.
	(xem phần "Tùy chọn gắn kết")

ZZ0000ZZ
	Tùy chọn. Được VFS gọi để hiển thị tên thiết bị cho
	/proc/<pid>/{mounts,mountinfo,mountstats}. Nếu không được cung cấp thì
	'(struct mount).mnt_devname' sẽ được sử dụng.

ZZ0000ZZ
	Tùy chọn. Được gọi bởi VFS (cho /proc/<pid>/mountinfo) để hiển thị
	đường dẫn nha khoa gốc gắn kết tương ứng với gốc hệ thống tập tin.

ZZ0000ZZ
	Tùy chọn. Được gọi bởi VFS (cho /proc/<pid>/mountstats) để hiển thị
	thống kê gắn kết dành riêng cho hệ thống tập tin.

ZZ0000ZZ
	được VFS gọi để đọc từ tệp hạn ngạch hệ thống tệp.

ZZ0000ZZ
	được VFS gọi để ghi vào tệp hạn ngạch hệ thống tệp.

ZZ0000ZZ
	được gọi theo hạn ngạch để lấy mảng 'struct dquot' cho một nút cụ thể.
	Không bắt buộc.

ZZ0000ZZ
	được gọi bởi chức năng thu nhỏ bộ đệm sb cho hệ thống tập tin
	trả về số lượng đối tượng được lưu trong bộ nhớ đệm có thể giải phóng mà nó chứa.
	Không bắt buộc.

ZZ0000ZZ
	được gọi bởi chức năng thu nhỏ bộ đệm sb cho hệ thống tập tin
	quét số lượng đối tượng được chỉ định để cố gắng giải phóng chúng.
	Tùy chọn, nhưng bất kỳ hệ thống tập tin nào thực hiện phương pháp này đều cần phải
	cũng triển khai ->nr_cached_objects để nó được gọi
	một cách chính xác.

Chúng tôi không thể làm bất cứ điều gì với bất kỳ lỗi nào mà hệ thống tập tin có thể
	gặp phải, do đó có kiểu trả về void.  Điều này sẽ không bao giờ
	được gọi nếu VM đang cố lấy lại trong điều kiện GFP_NOFS,
	do đó phương pháp này không cần phải tự xử lý tình huống đó.

Việc triển khai phải bao gồm các cuộc gọi lên lịch lại có điều kiện bên trong
	bất kỳ vòng quét nào được thực hiện.  Điều này cho phép VFS
	xác định kích thước lô quét thích hợp mà không cần phải lo lắng
	về việc liệu việc triển khai có gây ra vấn đề trì hoãn do
	kích thước lô quét lớn.

Người lập inode có trách nhiệm điền "i_op"
lĩnh vực.  Đây là một con trỏ tới "struct inode_Operations" mô tả
các phương thức có thể được thực hiện trên các nút riêng lẻ.


cấu trúc xattr_handler
---------------------

Trên các hệ thống tệp hỗ trợ các thuộc tính mở rộng (xattrs), s_xattr
trường superblock trỏ đến một mảng trình xử lý xattr được kết thúc bằng NULL.
Các thuộc tính mở rộng là các cặp tên:giá trị.

ZZ0000ZZ
	Chỉ ra rằng trình xử lý khớp với các thuộc tính được chỉ định
	tên (chẳng hạn như "system.posix_acl_access"); trường tiền tố phải
	là NULL.

ZZ0000ZZ
	Cho biết rằng trình xử lý khớp tất cả các thuộc tính với
	tiền tố tên được chỉ định (chẳng hạn như "người dùng."); trường tên phải là
	NULL.

ZZ0000ZZ
	Xác định xem các thuộc tính có phù hợp với trình xử lý xattr này không
	được liệt kê cho một nha khoa cụ thể.  Được sử dụng bởi một số listxattr
	triển khai như generic_listxattr.

ZZ0000ZZ
	Được gọi bởi VFS để nhận giá trị của một phần mở rộng cụ thể
	thuộc tính.  Phương thức này được gọi bởi hệ thống getxattr(2)
	gọi.

ZZ0000ZZ
	Được gọi bởi VFS để đặt giá trị của một phần mở rộng cụ thể
	thuộc tính.  Khi giá trị mới là NULL, được gọi để loại bỏ một
	thuộc tính mở rộng cụ thể.  Phương thức này được gọi bởi
	lệnh gọi hệ thống setxattr(2) và Removexattr(2).

Khi không có trình xử lý xattr nào của hệ thống tệp khớp với quy định
tên thuộc tính hoặc khi hệ thống tập tin không hỗ trợ các thuộc tính mở rộng,
các lệnh gọi hệ thống ZZ0000ZZ khác nhau trả về -EOPNOTSUPP.


Đối tượng Inode
================

Một đối tượng inode đại diện cho một đối tượng trong hệ thống tập tin.


cấu trúc inode_Operation
-----------------------

Phần này mô tả cách VFS có thể thao tác một nút trong hệ thống tệp của bạn.
Kể từ kernel 2.6.22, các thành viên sau được xác định:

.. code-block:: c

	struct inode_operations {
		int (*create) (struct mnt_idmap *, struct inode *,struct dentry *, umode_t, bool);
		struct dentry * (*lookup) (struct inode *,struct dentry *, unsigned int);
		int (*link) (struct dentry *,struct inode *,struct dentry *);
		int (*unlink) (struct inode *,struct dentry *);
		int (*symlink) (struct mnt_idmap *, struct inode *,struct dentry *,const char *);
		struct dentry *(*mkdir) (struct mnt_idmap *, struct inode *,struct dentry *,umode_t);
		int (*rmdir) (struct inode *,struct dentry *);
		int (*mknod) (struct mnt_idmap *, struct inode *,struct dentry *,umode_t,dev_t);
		int (*rename) (struct mnt_idmap *, struct inode *, struct dentry *,
			       struct inode *, struct dentry *, unsigned int);
		int (*readlink) (struct dentry *, char __user *,int);
		const char *(*get_link) (struct dentry *, struct inode *,
					 struct delayed_call *);
		int (*permission) (struct mnt_idmap *, struct inode *, int);
		struct posix_acl * (*get_inode_acl)(struct inode *, int, bool);
		int (*setattr) (struct mnt_idmap *, struct dentry *, struct iattr *);
		int (*getattr) (struct mnt_idmap *, const struct path *, struct kstat *, u32, unsigned int);
		ssize_t (*listxattr) (struct dentry *, char *, size_t);
		void (*update_time)(struct inode *inode, enum fs_update_time type,
				    int flags);
		void (*sync_lazytime)(struct inode *inode);
		int (*atomic_open)(struct inode *, struct dentry *, struct file *,
				   unsigned open_flag, umode_t create_mode);
		int (*tmpfile) (struct mnt_idmap *, struct inode *, struct file *, umode_t);
		struct posix_acl * (*get_acl)(struct mnt_idmap *, struct dentry *, int);
	        int (*set_acl)(struct mnt_idmap *, struct dentry *, struct posix_acl *, int);
		int (*fileattr_set)(struct mnt_idmap *idmap,
				    struct dentry *dentry, struct file_kattr *fa);
		int (*fileattr_get)(struct dentry *dentry, struct file_kattr *fa);
	        struct offset_ctx *(*get_offset_ctx)(struct inode *inode);
	};

Một lần nữa, tất cả các phương thức được gọi mà không có bất kỳ khóa nào được giữ, trừ khi
ghi chú khác.

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống open(2) và create(2).  Chỉ yêu cầu
	nếu bạn muốn hỗ trợ các tập tin thông thường.  Nha khoa bạn nhận được nên
	không có nút (tức là nó phải là răng âm).  đây
	bạn có thể sẽ gọi d_instantiate() bằng hàm nha khoa và
	inode mới được tạo

ZZ0000ZZ
	được gọi khi VFS cần tra cứu inode trong cha mẹ
	thư mục.  Tên cần tìm được tìm thấy trong nha khoa.  Cái này
	phương thức phải gọi d_add() để chèn inode tìm thấy vào
	nha khoa.  Trường "i_count" trong cấu trúc inode phải là
	tăng lên.  Nếu inode được đặt tên không tồn tại thì inode NULL
	nên được đưa vào nha khoa (cái này được gọi là âm bản
	nha khoa).  Việc trả lại mã lỗi từ quy trình này chỉ được thực hiện
	được thực hiện trên một lỗi thực sự, nếu không thì tạo các nút bằng hệ thống
	các lệnh gọi như create(2), mknod(2), mkdir(2), v.v. sẽ thất bại.
	Nếu bạn muốn làm quá tải các phương pháp nha khoa thì bạn nên
	khởi tạo trường "d_dop" trong nha khoa; đây là một con trỏ tới
	một cấu trúc "dentry_Operation".  Phương thức này được gọi với
	thư mục semaphore inode được giữ

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống link(2).  Chỉ cần thiết nếu bạn muốn
	hỗ trợ liên kết cứng.  Có lẽ bạn sẽ cần phải gọi
	d_instantiate() giống như bạn làm trong phương thức create()

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống unlink(2).  Chỉ cần thiết nếu bạn muốn
	hỗ trợ xóa inode

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống symlink(2).  Chỉ cần thiết nếu bạn muốn
	để hỗ trợ các liên kết tượng trưng.  Có lẽ bạn sẽ cần phải gọi
	d_instantiate() giống như bạn làm trong phương thức create()

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống mkdir(2).  Chỉ cần thiết nếu bạn muốn
	để hỗ trợ tạo thư mục con.  Bạn có thể sẽ cần phải
	gọi d_instantiate_new() giống như bạn làm trong phương thức create().

Nếu d_instantiate_new() không được sử dụng và nếu fh_to_dentry()
	hoạt động xuất khẩu được cung cấp hoặc nếu việc lưu trữ có thể được
	có thể truy cập bằng một đường dẫn khác (ví dụ: với hệ thống tệp mạng)
	thì có thể cần phải chăm sóc nhiều hơn.  Điều quan trọng là d_instantate()
	không nên sử dụng với inode không còn là I_NEW nếu có
	bất kỳ khả năng nào mà nút này có thể đã được gắn vào một chiếc răng giả.
	Điều này là do một quy tắc cứng trong VFS mà một thư mục phải
	chỉ có một chiếc răng duy nhất.

Ví dụ: nếu hệ thống tệp NFS được gắn hai lần vào thư mục mới
	có thể hiển thị trên ngàm khác trước khi nó ở trên ngàm gốc
	mount và một cặp name_to_handle_at(), open_by_handle_at()
	các cuộc gọi có thể khởi tạo inode thư mục bằng IS_ROOT()
	nha khoa trước khi mkdir đầu tiên trở lại.

Nếu có khả năng điều này có thể xảy ra thì inode mới
	phải được d_drop() ed và đính kèm với d_splice_alias().  các
	hàm răng được trả lại (nếu có) phải được trả lại bởi ->mkdir().

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống rmdir(2).  Chỉ cần thiết nếu bạn muốn
	hỗ trợ xóa thư mục con

ZZ0000ZZ
	được gọi bởi lệnh gọi hệ thống mknod(2) để tạo một thiết bị (char,
	block) inode hoặc một ống có tên (FIFO) hoặc ổ cắm.  Chỉ được yêu cầu nếu
	bạn muốn hỗ trợ tạo các loại nút này.  Bạn sẽ
	có lẽ cần phải gọi d_instantiate() giống như bạn làm trong
	phương thức tạo()

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống đổi tên (2) để đổi tên đối tượng cần có
	cha và tên được cung cấp bởi inode và nha khoa thứ hai.

Hệ thống tập tin phải trả về -EINVAL cho bất kỳ tệp nào không được hỗ trợ hoặc
	cờ chưa biết.  Hiện tại các cờ sau được triển khai:
	(1) RENAME_NOREPLACE: cờ này cho biết nếu mục tiêu của
	việc đổi tên đã tồn tại, việc đổi tên sẽ thất bại với -EEXIST thay vì
	thay thế mục tiêu.  VFS đã kiểm tra sự tồn tại, vì vậy
	đối với các hệ thống tập tin cục bộ, việc triển khai RENAME_NOREPLACE là
	tương đương với việc đổi tên đơn giản.
	(2) RENAME_EXCHANGE: trao đổi nguồn và đích.  Cả hai đều phải
	tồn tại; điều này được kiểm tra bởi VFS.  Không giống như đổi tên đơn giản, nguồn
	và mục tiêu có thể thuộc loại khác nhau.

ZZ0000ZZ
	được gọi bởi VFS để đi theo một liên kết tượng trưng tới inode đó
	trỏ đến.  Chỉ bắt buộc nếu bạn muốn hỗ trợ các liên kết tượng trưng.
	Phương thức này trả về phần thân liên kết tượng trưng để duyệt qua (và có thể
	đặt lại vị trí hiện tại bằng nd_jump_link()).  Nếu cơ thể
	sẽ không biến mất cho đến khi hết inode, không cần gì khác;
	nếu nó cần được ghim theo cách khác, hãy sắp xếp để nó được phát hành bằng cách
	có get_link(..., ..., done) thực hiện set_delayed_call(done,
	hàm hủy, đối số).  Trong trường hợp đó hàm hủy (đối số) sẽ
	sẽ được gọi sau khi VFS hoàn thành xong phần thân mà bạn đã trả lại.  tháng 5
	được gọi ở chế độ RCU; được chỉ định bởi nha khoa NULL
	lý lẽ.  Nếu không thể xử lý yêu cầu mà không thoát khỏi chế độ RCU,
	yêu cầu nó trả về ERR_PTR(-ECHILD).

Nếu hệ thống tập tin lưu trữ mục tiêu liên kết tượng trưng trong ->i_link, thì
	VFS có thể sử dụng trực tiếp mà không cần gọi ->get_link(); tuy nhiên,
	->get_link() vẫn phải được cung cấp.  ->i_link không được
	được giải phóng cho đến sau thời gian gia hạn RCU.  Đang viết cho ->i_link
	thời gian post-iget() yêu cầu hàng rào bộ nhớ 'giải phóng'.

ZZ0000ZZ
	bây giờ đây chỉ là phần ghi đè để readlink(2) sử dụng cho
	các trường hợp khi ->get_link sử dụng nd_jump_link() hoặc đối tượng không có trong
	thực tế là một liên kết tượng trưng.  Thông thường hệ thống tập tin chỉ nên thực hiện
	->get_link cho các liên kết tượng trưng và readlink(2) sẽ tự động sử dụng
	đó.

ZZ0000ZZ
	được gọi bởi VFS để kiểm tra quyền truy cập trên thiết bị giống POSIX
	hệ thống tập tin.

Có thể được gọi ở chế độ rcu-walk (mặt nạ & MAY_NOT_BLOCK).  Nếu ở
	chế độ rcu-walk, hệ thống tập tin phải kiểm tra quyền mà không cần
	chặn hoặc lưu trữ vào inode.

Nếu gặp phải tình huống mà rcu-walk không thể xử lý được,
	trở về
	-ECHILD và nó sẽ được gọi lại ở chế độ đi lại.

ZZ0000ZZ
	được VFS gọi để đặt thuộc tính cho một tệp.  Phương pháp này là
	được gọi bởi chmod(2) và các cuộc gọi hệ thống liên quan.

ZZ0000ZZ
	được gọi bởi VFS để lấy thuộc tính của tệp.  Phương pháp này là
	được gọi bởi stat(2) và các cuộc gọi hệ thống liên quan.

ZZ0000ZZ
	được gọi bởi VFS để liệt kê tất cả các thuộc tính mở rộng cho một
	tập tin.  Phương thức này được gọi bằng lệnh gọi hệ thống listxattr(2).

ZZ0000ZZ
	được VFS gọi để cập nhật thời gian cụ thể hoặc i_version của
	một inode.  Nếu điều này không được xác định thì VFS sẽ cập nhật inode
	chính nó và gọi mark_inode_dirty_sync.

ZZ0000ZZ:
	được gọi bằng mã viết lại để cập nhật dấu thời gian lười biếng thành
	cập nhật dấu thời gian thường xuyên được đồng bộ hóa vào đĩa
	inode.

ZZ0000ZZ
	được gọi trên thành phần cuối cùng của một lệnh mở.  Sử dụng tùy chọn này
	phương thức mà hệ thống tập tin có thể tra cứu, có thể tạo và mở
	tập tin trong một hoạt động nguyên tử.  Nếu nó muốn rời khỏi thực tế
	mở cho người gọi (ví dụ: nếu tệp hóa ra là
	liên kết tượng trưng, ​​thiết bị hoặc chỉ một hệ thống tập tin nào đó sẽ không hoạt động nguyên tử
	open for), nó có thể báo hiệu điều này bằng cách trả về finish_no_open(file,
	nha khoa).  Phương thức này chỉ được gọi nếu thành phần cuối cùng là
	tiêu cực hoặc cần tra cứu.  Các răng giả tích cực được lưu trong bộ nhớ cache vẫn còn
	được xử lý bởi f_op->open().  Nếu tệp đã được tạo, FMODE_CREATED
	cờ phải được đặt trong tệp->f_mode.  Trong trường hợp O_EXCL
	phương thức chỉ phải thành công nếu tệp không tồn tại và do đó
	FMODE_CREATED sẽ luôn hướng tới thành công.

ZZ0000ZZ
	được gọi ở cuối O_TMPFILE open().  Tùy chọn, tương đương với
	nguyên tử tạo, mở và hủy liên kết một tập tin trong nhất định
	thư mục.  Khi thành công cần quay lại với file đã có
	mở; điều này có thể được thực hiện bằng cách gọi finish_open_simple() ngay tại
	sự kết thúc.

ZZ0000ZZ
	đã gọi ioctl(FS_IOC_GETFLAGS) và ioctl(FS_IOC_FSGETXATTR) tới
	truy xuất các cờ và thuộc tính tập tin linh tinh.  Còn được gọi là
	trước thao tác SET liên quan để kiểm tra những gì đang được thay đổi
	(trong trường hợp này với i_rwsem bị khóa độc quyền).  Nếu không đặt thì
	quay lại f_op->ioctl().

ZZ0000ZZ
	đã gọi ioctl(FS_IOC_SETFLAGS) và ioctl(FS_IOC_FSSETXATTR) tới
	thay đổi các cờ và thuộc tính tập tin linh tinh.  Người gọi giữ
	i_rwsem độc quyền.  Nếu không được đặt thì quay lại f_op->ioctl().
ZZ0001ZZ
	được gọi để lấy bối cảnh bù đắp cho một nút thư mục. A
        hệ thống tập tin phải xác định thao tác này để sử dụng
        simple_offset_dir_hoạt động.

Đối tượng không gian địa chỉ
========================

Đối tượng không gian địa chỉ dùng để nhóm và quản lý các trang trong trang
bộ đệm.  Nó có thể được sử dụng để theo dõi các trang trong một tập tin (hoặc bất cứ thứ gì
else) và cũng theo dõi việc ánh xạ các phần của tệp vào tiến trình
các không gian địa chỉ.

Có một số dịch vụ riêng biệt nhưng có liên quan đến nhau mà một
không gian địa chỉ có thể cung cấp.  Chúng bao gồm việc giao tiếp áp lực trí nhớ,
tra cứu trang theo địa chỉ và theo dõi các trang được gắn thẻ là Bẩn hoặc
Viết lại.

Cái đầu tiên có thể được sử dụng độc lập với những cái khác.  VM có thể cố gắng
phát hành các trang sạch để sử dụng lại chúng.  Để làm điều này nó có thể gọi
->release_folio trên các folio sạch sẽ với chế độ riêng tư
bộ cờ.  Làm sạch các trang không có PagePrivate và không có tài liệu tham khảo bên ngoài
sẽ được phát hành mà không cần thông báo cho address_space.

Để đạt được chức năng này, các trang cần được đặt trên LRU với
lru_cache_add và mark_page_active cần được gọi bất cứ khi nào trang
được sử dụng.

Các trang thường được lưu giữ trong chỉ mục cây cơ số theo ->index.  Cây này
duy trì thông tin về trạng thái PG_Dirty và PG_Writeback của mỗi
trang, để có thể tìm thấy các trang có một trong hai cờ này một cách nhanh chóng.

Thẻ Dirty chủ yếu được sử dụng bởi mpage_writepages - thẻ mặc định
-> phương pháp viết trang.  Nó sử dụng thẻ để tìm các trang bẩn để
viết lại.  Nếu mpage_writepages không được sử dụng (tức là địa chỉ
cung cấp ->writepages) của riêng nó, thẻ PAGECACHE_TAG_DIRTY gần như
chưa sử dụng.  write_inode_now và sync_inode sử dụng nó (thông qua
__sync_single_inode) để kiểm tra xem ->writepages có thành công trong
viết ra toàn bộ address_space.

Thẻ Writeback được sử dụng bởi các hàm filemap*wait* và sync_page*, thông qua
filemap_fdatawait_range, để đợi tất cả quá trình ghi lại hoàn tất.

Trình xử lý address_space có thể đính kèm thông tin bổ sung vào một trang,
thường sử dụng trường 'riêng tư' trong 'trang cấu trúc'.  Nếu như vậy
thông tin được đính kèm, cờ PG_Private phải được đặt.  Điều này sẽ
khiến các quy trình VM khác nhau thực hiện các cuộc gọi bổ sung vào address_space
trình xử lý để xử lý dữ liệu đó.

Không gian địa chỉ hoạt động như một trung gian giữa lưu trữ và
ứng dụng.  Dữ liệu được đọc vào không gian địa chỉ toàn bộ trang tại một
thời gian và được cung cấp cho ứng dụng bằng cách sao chép trang hoặc
bằng cách ánh xạ bộ nhớ trang.  Dữ liệu được ghi vào không gian địa chỉ bằng cách
ứng dụng, sau đó được ghi lại toàn bộ vào bộ lưu trữ
các trang, tuy nhiên address_space có khả năng kiểm soát kích thước ghi tốt hơn.

Quá trình đọc về cơ bản chỉ yêu cầu 'read_folio'.  Việc viết
quá trình phức tạp hơn và sử dụng write_begin/write_end hoặc
dirty_folio để ghi dữ liệu vào address_space và
writepages để ghi lại dữ liệu vào bộ lưu trữ.

Xóa các trang khỏi address_space yêu cầu giữ i_rwsem của inode
riêng, trong khi việc thêm trang vào address_space yêu cầu phải giữ
i_mapping->invalidate_lock của inode chỉ dành riêng.

Khi dữ liệu được ghi vào một trang, cờ PG_Dirty phải được đặt.  Nó
thường vẫn được đặt cho đến khi các trang viết yêu cầu viết nó.  Cái này
nên xóa PG_Dirty và đặt PG_Writeback.  Nó thực sự có thể được viết
tại bất kỳ thời điểm nào sau khi PG_Dirty được xóa sạch.  Một khi nó được biết là an toàn,
PG_Writeback bị xóa.

Writeback sử dụng cấu trúc writeback_control để điều khiển
hoạt động.  Điều này mang lại cho hoạt động viết trang một số
thông tin về bản chất và lý do của yêu cầu phản hồi,
và những hạn chế mà nó đang được thực hiện.  Nó cũng được sử dụng để
trả lại thông tin cho người gọi về kết quả của một
yêu cầu viết trang.


Xử lý lỗi trong quá trình viết lại
--------------------------------

Hầu hết các ứng dụng sử dụng I/O được đệm sẽ định kỳ gọi một tệp
cuộc gọi đồng bộ hóa (fsync, fdatasync, msync hoặc sync_file_range) tới
đảm bảo rằng dữ liệu được ghi đã được lưu vào kho dự phòng.  Khi ở đó
là một lỗi trong quá trình viết lại, họ mong đợi lỗi đó sẽ được báo cáo khi
một yêu cầu đồng bộ tập tin được thực hiện.  Sau khi một lỗi được báo cáo trên một
yêu cầu, các yêu cầu tiếp theo trên cùng một bộ mô tả tệp sẽ trả về
0, trừ khi xảy ra thêm lỗi ghi lại kể từ tệp trước đó
đồng bộ hóa.

Lý tưởng nhất là kernel sẽ chỉ báo cáo lỗi trên các mô tả tập tin trên
việc viết nào đã được thực hiện nhưng sau đó không thể viết lại được.  các
cơ sở hạ tầng pagecache chung không theo dõi mô tả tệp
Tuy nhiên, điều đó đã làm bẩn từng trang riêng lẻ, vì vậy việc xác định trang nào
bộ mô tả tập tin sẽ không thể nhận được lỗi.

Thay vào đó, cơ sở hạ tầng theo dõi lỗi ghi lại chung trong
kernel giải quyết các lỗi báo cáo cho fsync trên tất cả các mô tả tệp
đã mở vào thời điểm xảy ra lỗi.  Trong tình huống với
nhiều người viết, tất cả họ sẽ nhận được lỗi ở lần tiếp theo
fsync, ngay cả khi tất cả việc ghi được thực hiện thông qua tệp cụ thể đó
bộ mô tả đã thành công (hoặc ngay cả khi không có thao tác ghi nào vào tệp đó
mô tả nào cả).

Các hệ thống tập tin muốn sử dụng cơ sở hạ tầng này nên gọi
maps_set_error để ghi lại lỗi trong address_space khi nó
xảy ra.  Sau đó, sau khi ghi lại dữ liệu từ bộ đệm trang trong
file->hoạt động fsync, họ nên gọi file_check_and_advance_wb_err tới
đảm bảo rằng con trỏ lỗi của tệp cấu trúc đã chuyển sang đúng
điểm trong luồng lỗi do (các) thiết bị hỗ trợ phát ra.


cấu trúc địa chỉ_space_hoạt động
-------------------------------

Phần này mô tả cách VFS có thể thao tác ánh xạ tệp tới trang
bộ đệm trong hệ thống tập tin của bạn.  Các thành viên sau đây được xác định:

.. code-block:: c

	struct address_space_operations {
		int (*read_folio)(struct file *, struct folio *);
		int (*writepages)(struct address_space *, struct writeback_control *);
		bool (*dirty_folio)(struct address_space *, struct folio *);
		void (*readahead)(struct readahead_control *);
		int (*write_begin)(const struct kiocb *, struct address_space *mapping,
				   loff_t pos, unsigned len,
				   struct page **pagep, void **fsdata);
		int (*write_end)(const struct kiocb *, struct address_space *mapping,
				 loff_t pos, unsigned len, unsigned copied,
				 struct folio *folio, void *fsdata);
		sector_t (*bmap)(struct address_space *, sector_t);
		void (*invalidate_folio) (struct folio *, size_t start, size_t len);
		bool (*release_folio)(struct folio *, gfp_t);
		void (*free_folio)(struct folio *);
		ssize_t (*direct_IO)(struct kiocb *, struct iov_iter *iter);
		int (*migrate_folio)(struct mapping *, struct folio *dst,
				struct folio *src, enum migrate_mode);
		int (*launder_folio) (struct folio *);

		bool (*is_partially_uptodate) (struct folio *, size_t from,
					       size_t count);
		void (*is_dirty_writeback)(struct folio *, bool *, bool *);
		int (*error_remove_folio)(struct mapping *mapping, struct folio *);
		int (*swap_activate)(struct swap_info_struct *sis, struct file *f, sector_t *span)
		int (*swap_deactivate)(struct file *);
		int (*swap_rw)(struct kiocb *iocb, struct iov_iter *iter);
	};

ZZ0000ZZ
	Được gọi bởi bộ đệm trang để đọc folio từ kho lưu trữ dự phòng.
	Đối số 'file' cung cấp thông tin xác thực cho mạng
	hệ thống tập tin và thường không được sử dụng bởi các hệ thống tập tin dựa trên khối.
	Nó có thể là NULL nếu người gọi không có tệp đang mở (ví dụ: nếu
	hạt nhân đang thực hiện việc đọc cho chính nó chứ không phải thay mặt
	của quá trình không gian người dùng với một tệp đang mở).

Nếu ánh xạ không hỗ trợ các folio lớn, folio sẽ
	chứa một trang duy nhất.	Folio sẽ bị khóa khi read_folio
	được gọi.  Nếu quá trình đọc hoàn tất thành công, folio sẽ
	được đánh dấu cập nhật.  Hệ thống tập tin sẽ mở khóa folio
	sau khi đọc xong, cho dù nó có thành công hay không.
	Hệ thống tập tin không cần sửa đổi số tiền đếm lại trên folio;
	bộ đệm trang giữ số lượng tham chiếu và điều đó sẽ không
	được phát hành cho đến khi folio được mở khóa.

Hệ thống tập tin có thể triển khai ->read_folio() một cách đồng bộ.
	Trong hoạt động bình thường, folios được đọc qua ->readahead()
	phương pháp.  Chỉ khi điều này không thành công hoặc nếu người gọi cần đợi
	quá trình đọc hoàn tất sẽ gọi bộ đệm trang ->read_folio().
	Hệ thống tập tin không nên cố gắng thực hiện việc đọc trước của riêng mình
	trong thao tác ->read_folio().

Nếu hệ thống tập tin không thể thực hiện việc đọc vào lúc này, nó có thể
	mở khóa folio, thực hiện bất kỳ hành động nào cần thiết để đảm bảo rằng
	đọc sẽ thành công trong tương lai và trả về AOP_TRUNCATED_PAGE.
	Trong trường hợp này, người gọi nên tra cứu folio, khóa nó lại,
	và gọi lại ->read_folio.

Người gọi có thể gọi trực tiếp phương thức ->read_folio() nhưng sử dụng
	read_mapping_folio() sẽ đảm nhiệm việc khóa, chờ
	đọc để hoàn thành và xử lý các trường hợp như AOP_TRUNCATED_PAGE.

ZZ0000ZZ
	được VM gọi để ghi ra các trang liên quan đến
	đối tượng address_space.  Nếu wbc->sync_mode là WB_SYNC_ALL thì
	writeback_control sẽ chỉ định một phạm vi các trang phải được
	được viết ra.  Nếu là WB_SYNC_NONE thì nr_to_write là
	nhất định và nên viết nhiều trang nếu có thể.  Nếu không
	->writepages được cung cấp, sau đó mpage_writepages được sử dụng thay thế.
	Thao tác này sẽ chọn các trang từ không gian địa chỉ được gắn thẻ là
	DIRTY và sẽ viết lại.

ZZ0000ZZ
	được VM gọi để đánh dấu một folio là bẩn.  Điều này đặc biệt
	cần thiết nếu một không gian địa chỉ đính kèm dữ liệu riêng tư vào một folio và
	dữ liệu đó cần được cập nhật khi folio bị bẩn.  Đây là
	được gọi, ví dụ: khi một trang ánh xạ bộ nhớ được sửa đổi.
	Nếu được xác định, nó sẽ đặt cờ bẩn folio và
	Dấu tìm kiếm PAGECACHE_TAG_DIRTY trong i_pages.

ZZ0000ZZ
	Được VM gọi để đọc các trang được liên kết với address_space
	đối tượng.  Các trang liên tiếp trong bộ đệm trang và được
	bị khóa.  Việc triển khai sẽ làm giảm số lần đếm lại trang
	sau khi bắt đầu I/O trên mỗi trang.  Thông thường trang sẽ
	được mở khóa bởi trình xử lý hoàn thành I/O.  Tập hợp các trang là
	được chia thành một số trang đồng bộ, theo sau là một số trang không đồng bộ,
	rac->ra->async_size cung cấp số lượng trang không đồng bộ.  các
	hệ thống tập tin nên cố gắng đọc tất cả các trang đồng bộ nhưng có thể quyết định
	dừng lại khi nó đến các trang không đồng bộ.  Nếu nó quyết định
	ngừng thử I/O, nó có thể quay trở lại.  Người gọi sẽ
	xóa các trang còn lại khỏi không gian địa chỉ, mở khóa chúng
	và giảm số lần đếm lại trang.  Đặt PageUptodate nếu I/O
	hoàn tất thành công.

ZZ0000ZZ
	Được gọi bằng mã ghi đệm chung để hỏi hệ thống tập tin
	để chuẩn bị ghi len byte ở offset đã cho trong tệp.
	address_space nên kiểm tra xem thao tác ghi có thể thực hiện được không
	hoàn thành, bằng cách phân bổ không gian nếu cần thiết và thực hiện bất kỳ công việc nào khác
	dọn phòng nội bộ.  Nếu việc viết sẽ cập nhật các phần của bất kỳ
	các khối cơ bản trên bộ lưu trữ thì các khối đó phải được đọc trước
	(nếu chúng chưa được đọc) để các khối được cập nhật
	có thể được viết ra đúng cách.

Hệ thống tập tin phải trả về folio bộ đệm trang bị khóa cho
	phần bù được chỉ định, bằng ZZ0000ZZ, để người gọi ghi vào.

Nó phải có khả năng xử lý việc ghi ngắn (trong đó độ dài
	được chuyển tới write_begin lớn hơn số byte được sao chép
	vào tờ giấy).

Một khoảng trống * có thể được trả về trong fsdata, sau đó được chuyển vào
	viết_end.

Trả về 0 khi thành công; < 0 khi thất bại (là mã lỗi),
	trong trường hợp đó write_end không được gọi.

ZZ0000ZZ
	Sau khi write_begin và sao chép dữ liệu thành công, write_end phải được
	được gọi.  len là len gốc được truyền cho write_begin và
	được sao chép là số lượng có thể được sao chép.

Hệ thống tập tin phải đảm nhiệm việc mở khóa folio,
	giảm số lần đếm lại và cập nhật i_size.

Trả về < 0 nếu thất bại, nếu không thì số byte (<=
	'sao chép') có thể được sao chép vào pagecache.

ZZ0000ZZ
	được gọi bởi VFS để ánh xạ phần bù khối logic trong đối tượng tới
	số khối vật lý.  Phương pháp này được sử dụng bởi FIBMAP ioctl
	và để làm việc với các tập tin trao đổi.  Để có thể trao đổi sang một tập tin,
	tệp phải có ánh xạ ổn định tới thiết bị khối.  Trao đổi
	hệ thống không đi qua hệ thống tập tin mà thay vào đó sử dụng bmap
	để tìm ra các khối trong tệp nằm ở đâu và sử dụng chúng
	địa chỉ trực tiếp.

ZZ0000ZZ
	Nếu một folio có dữ liệu riêng tư thì không hợp lệ_folio sẽ là
	được gọi khi một phần hoặc toàn bộ folio bị xóa khỏi
	không gian địa chỉ.  Điều này thường tương ứng với một
	cắt ngắn, đục lỗ hoặc vô hiệu hóa hoàn toàn địa chỉ
	dấu cách (trong trường hợp sau 'offset' sẽ luôn là 0 và 'length'
	sẽ là folio_size()).  Bất kỳ dữ liệu riêng tư nào được liên kết với folio
	nên được cập nhật để phản ánh sự cắt ngắn này.  Nếu offset là 0
	và độ dài là folio_size() thì dữ liệu riêng tư sẽ là
	được phát hành, bởi vì folio phải có khả năng hoàn toàn
	bị loại bỏ.  Điều này có thể được thực hiện bằng cách gọi ->release_folio
	chức năng, nhưng trong trường hợp này việc phát hành MUST thành công.

ZZ0000ZZ
	Release_folio được gọi trên các folio có dữ liệu riêng tư để thông báo cho
	hệ thống tập tin mà folio sắp được giải phóng.  ->release_folio
	nên xóa mọi dữ liệu riêng tư khỏi folio và xóa
	cờ riêng.  Nếu Release_folio() không thành công, nó sẽ trả về sai.
	Release_folio() được sử dụng trong hai trường hợp riêng biệt nhưng có liên quan với nhau.
	Đầu tiên là khi VM muốn giải phóng một folio sạch mà không cần
	người dùng tích cực.  Nếu ->release_folio thành công, folio sẽ được
	bị xóa khỏi address_space và được giải phóng.

Trường hợp thứ hai là khi một yêu cầu được đưa ra nhằm vô hiệu hóa
	một số hoặc tất cả các folio trong một address_space.  Điều này có thể xảy ra
	thông qua lệnh gọi hệ thống fadvise(POSIX_FADV_DONTNEED) hoặc bằng
	hệ thống tập tin yêu cầu nó một cách rõ ràng như nfs và 9p (khi chúng
	tin rằng bộ đệm có thể đã lỗi thời với bộ lưu trữ) bằng cách gọi
	không hợp lệ_inode_pages2().  Nếu hệ thống tập tin thực hiện lệnh gọi như vậy,
	và cần phải chắc chắn rằng tất cả các folio đều vô hiệu, thì
	bản phát hành_folio của nó sẽ cần đảm bảo điều này.  Có thể nó có thể
	xóa cờ cập nhật nếu nó chưa thể giải phóng dữ liệu riêng tư.

ZZ0000ZZ
	free_folio được gọi khi folio không còn hiển thị trong
	bộ đệm trang để cho phép dọn sạch mọi dữ liệu riêng tư.
	Vì nó có thể được gọi bởi bộ thu hồi bộ nhớ nên nó không nên
	giả sử rằng ánh xạ address_space ban đầu vẫn tồn tại và
	nó không nên chặn.

ZZ0000ZZ
	được gọi bằng thủ tục đọc/ghi chung để thực hiện direct_IO -
	đó là các yêu cầu IO bỏ qua bộ đệm và chuyển trang
	dữ liệu trực tiếp giữa bộ lưu trữ và địa chỉ của ứng dụng
	không gian.

ZZ0000ZZ
	Điều này được sử dụng để thu gọn việc sử dụng bộ nhớ vật lý.  Nếu máy ảo
	muốn di dời một folio (có thể từ một thiết bị bộ nhớ
	báo hiệu sự thất bại sắp xảy ra) nó sẽ chuyển một tờ giấy mới và một tờ giấy cũ
	folio cho chức năng này.  Migrate_folio nên chuyển bất kỳ thông tin cá nhân nào
	dữ liệu và cập nhật bất kỳ tài liệu tham khảo nào có trong folio.

ZZ0000ZZ
	Được gọi trước khi giải phóng một folio - nó sẽ ghi lại folio bẩn.
	Để ngăn chặn việc làm bẩn lại folio, nó sẽ được khóa trong quá trình
	toàn bộ hoạt động.

ZZ0000ZZ
	Được gọi bởi VM khi đọc tệp qua pagecache khi
	kích thước khối cơ bản nhỏ hơn kích thước của folio.
	Nếu khối yêu cầu được cập nhật thì quá trình đọc có thể hoàn tất
	mà không cần I/O để cập nhật toàn bộ trang.

ZZ0000ZZ
	Được VM gọi khi cố gắng lấy lại folio.  VM sử dụng
	thông tin bẩn và viết lại để xác định xem nó có cần
	dừng lại để cho phép người xả rác có cơ hội hoàn thành một số IO.
	Thông thường nó có thể sử dụng folio_test_dirty và folio_test_writeback nhưng
	một số hệ thống tập tin có trạng thái phức tạp hơn (folio không ổn định trong NFS
	ngăn chặn việc lấy lại) hoặc không đặt các cờ đó do khóa
	vấn đề.  Cuộc gọi lại này cho phép một hệ thống tập tin chỉ ra
	VM nếu một folio bị coi là bẩn hoặc viết lại cho
	mục đích trì hoãn.

ZZ0000ZZ
	thường được đặt thành generic_error_remove_folio nếu cắt ngắn là được
	cho không gian địa chỉ này.  Được sử dụng để xử lý lỗi bộ nhớ.
	Đặt cài đặt này có nghĩa là bạn xử lý các trang sẽ biến mất dưới quyền bạn,
	trừ khi bạn khóa chúng hoặc tăng số lượng tham chiếu.

ZZ0000ZZ

Được gọi để chuẩn bị tập tin đã cho để trao đổi.  Nó sẽ thực hiện
	bất kỳ sự xác nhận và chuẩn bị cần thiết nào để đảm bảo rằng việc viết
	có thể được thực hiện với sự phân bổ bộ nhớ tối thiểu.  Nó nên gọi
	add_swap_extent() hoặc trình trợ giúp iomap_swapfile_activate() và
	trả về số lượng phạm vi được thêm vào.  Nếu IO phải được gửi
	thông qua ->swap_rw(), nó sẽ đặt SWP_FS_OPS, nếu không IO sẽ
	được gửi trực tiếp đến thiết bị khối ZZ0000ZZ.

ZZ0000ZZ
	Được gọi trong quá trình trao đổi trên các tệp có swap_activate
	thành công.

ZZ0000ZZ
	Được gọi để đọc hoặc ghi các trang hoán đổi khi SWP_FS_OPS được đặt.

Đối tượng tệp
===============

Một đối tượng file đại diện cho một file được mở bởi một tiến trình.  Điều này cũng được biết đến
dưới dạng "mô tả tệp mở" theo cách nói của POSIX.


cấu trúc tập tin_hoạt động
----------------------

Phần này mô tả cách VFS có thể thao tác với một tệp đang mở.  Về hạt nhân
4.18, các thành viên sau được xác định:

.. code-block:: c

	struct file_operations {
		struct module *owner;
		fop_flags_t fop_flags;
		loff_t (*llseek) (struct file *, loff_t, int);
		ssize_t (*read) (struct file *, char __user *, size_t, loff_t *);
		ssize_t (*write) (struct file *, const char __user *, size_t, loff_t *);
		ssize_t (*read_iter) (struct kiocb *, struct iov_iter *);
		ssize_t (*write_iter) (struct kiocb *, struct iov_iter *);
		int (*iopoll)(struct kiocb *kiocb, struct io_comp_batch *,
				unsigned int flags);
		int (*iterate_shared) (struct file *, struct dir_context *);
		__poll_t (*poll) (struct file *, struct poll_table_struct *);
		long (*unlocked_ioctl) (struct file *, unsigned int, unsigned long);
		long (*compat_ioctl) (struct file *, unsigned int, unsigned long);
		int (*mmap) (struct file *, struct vm_area_struct *);
		int (*open) (struct inode *, struct file *);
		int (*flush) (struct file *, fl_owner_t id);
		int (*release) (struct inode *, struct file *);
		int (*fsync) (struct file *, loff_t, loff_t, int datasync);
		int (*fasync) (int, struct file *, int);
		int (*lock) (struct file *, int, struct file_lock *);
		unsigned long (*get_unmapped_area)(struct file *, unsigned long, unsigned long, unsigned long, unsigned long);
		int (*check_flags)(int);
		int (*flock) (struct file *, int, struct file_lock *);
		ssize_t (*splice_write)(struct pipe_inode_info *, struct file *, loff_t *, size_t, unsigned int);
		ssize_t (*splice_read)(struct file *, loff_t *, struct pipe_inode_info *, size_t, unsigned int);
		void (*splice_eof)(struct file *file);
		int (*setlease)(struct file *, int, struct file_lease **, void **);
		long (*fallocate)(struct file *file, int mode, loff_t offset,
				  loff_t len);
		void (*show_fdinfo)(struct seq_file *m, struct file *f);
	#ifndef CONFIG_MMU
		unsigned (*mmap_capabilities)(struct file *);
	#endif
		ssize_t (*copy_file_range)(struct file *, loff_t, struct file *,
				loff_t, size_t, unsigned int);
		loff_t (*remap_file_range)(struct file *file_in, loff_t pos_in,
					   struct file *file_out, loff_t pos_out,
					   loff_t len, unsigned int remap_flags);
		int (*fadvise)(struct file *, loff_t, loff_t, int);
		int (*uring_cmd)(struct io_uring_cmd *ioucmd, unsigned int issue_flags);
		int (*uring_cmd_iopoll)(struct io_uring_cmd *, struct io_comp_batch *,
					unsigned int poll_flags);
		int (*mmap_prepare)(struct vm_area_desc *);
	};

Một lần nữa, tất cả các phương thức được gọi mà không có bất kỳ khóa nào được giữ, trừ khi
ghi chú khác.

ZZ0000ZZ
	được gọi khi VFS cần di chuyển chỉ mục vị trí tệp

ZZ0000ZZ
	được gọi bằng read(2) và các cuộc gọi hệ thống liên quan

ZZ0000ZZ
	có thể đọc không đồng bộ với iov_iter làm đích

ZZ0000ZZ
	được gọi bằng write(2) và các cuộc gọi hệ thống liên quan

ZZ0000ZZ
	có thể ghi không đồng bộ với iov_iter làm nguồn

ZZ0000ZZ
	được gọi khi aio muốn thăm dò ý kiến ​​hoàn thành trên HIPRI iocbs

ZZ0000ZZ
	được gọi khi VFS cần đọc nội dung thư mục

ZZ0000ZZ
	được gọi bởi VFS khi một tiến trình muốn kiểm tra xem có
	hoạt động trên tệp này và (tùy chọn) chuyển sang chế độ ngủ cho đến khi có
	là hoạt động.  Được gọi bằng lệnh gọi hệ thống select(2) và poll(2)

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống ioctl(2).

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống ioctl(2) khi lệnh gọi hệ thống 32 bit được thực hiện
	 được sử dụng trên hạt nhân 64 bit.

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống mmap(2). Không được ủng hộ
	ZZ0001ZZ.

ZZ0000ZZ
	được gọi bởi VFS khi cần mở một nút.  Khi VFS
	mở một tệp, nó sẽ tạo một "tệp cấu trúc" mới.  Sau đó nó gọi
	phương thức open cho cấu trúc tệp mới được phân bổ.  Bạn có thể
	nghĩ rằng phương thức mở thực sự thuộc về "struct
	inode_Operations" và bạn có thể đúng.  Tôi nghĩ nó đã xong
	Đó là vì nó làm cho việc triển khai hệ thống tập tin trở nên đơn giản hơn.
	Phương thức open() là một nơi tốt để khởi tạo
	Thành viên "private_data" trong cấu trúc tệp nếu bạn muốn trỏ
	đến cấu trúc thiết bị

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống close(2) để xóa một tập tin

ZZ0000ZZ
	được gọi khi tham chiếu cuối cùng tới một tệp đang mở bị đóng

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống fsync(2).  Cũng xem phần trên
	có tiêu đề "Xử lý lỗi trong quá trình viết lại".

ZZ0000ZZ
	được gọi bởi lệnh gọi hệ thống fcntl(2) khi không đồng bộ
	chế độ (không chặn) được bật cho một tệp

ZZ0000ZZ
	được gọi bởi hệ thống fcntl(2) gọi F_GETLK, F_SETLK và
	Các lệnh F_SETLKW

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống mmap(2)

ZZ0000ZZ
	được gọi bởi hệ thống fcntl(2) gọi lệnh F_SETFL

ZZ0000ZZ
	được gọi bởi cuộc gọi hệ thống đàn(2)

ZZ0000ZZ
	được gọi bởi VFS để ghép dữ liệu từ một đường ống thành một tệp.  Cái này
	phương thức được sử dụng bởi lệnh gọi hệ thống mối nối (2)

ZZ0000ZZ
	được VFS gọi để ghép dữ liệu từ tệp vào một đường ống.  Cái này
	phương thức được sử dụng bởi lệnh gọi hệ thống mối nối (2)

ZZ0000ZZ
	được gọi bởi VFS để thiết lập hoặc giải phóng hợp đồng thuê khóa tệp.  Địa phương
	các hệ thống tập tin muốn sử dụng triển khai cho thuê nội bộ kernel
	nên đặt giá trị này thành generic_setlease(). Các triển khai giải quyết khác
	nên gọi generic_setlease() để ghi lại hoặc xóa hợp đồng thuê trong inode
	sau khi thiết lập nó. Khi được đặt thành NULL, các nỗ lực đặt hoặc xóa hợp đồng thuê sẽ
	trả về -EINVAL.

ZZ0000ZZ
	được gọi bởi VFS để phân bổ trước các khối hoặc đục lỗ.

ZZ0000ZZ
	được gọi bằng lệnh gọi hệ thống copy_file_range(2).

ZZ0000ZZ
	được gọi bởi hệ thống ioctl(2) gọi FICLONERANGE và FICLONE
	và các lệnh FIDEDUPERANGE để ánh xạ lại phạm vi tệp.  Một
	việc triển khai nên ánh xạ lại các byte len tại pos_in của nguồn
	tập tin vào tập tin đích tại pos_out.  Việc triển khai phải xử lý
	người gọi đi vào len == 0; điều này có nghĩa là "ánh xạ lại đến cuối
	tập tin nguồn".  Giá trị trả về phải là số byte
	được ánh xạ lại hoặc mã lỗi âm thông thường nếu xảy ra lỗi
	trước khi bất kỳ byte nào được ánh xạ lại.  Tham số remap_flags
	chấp nhận cờ REMAP_FILE_*.  Nếu REMAP_FILE_DEDUP được đặt thì
	việc triển khai chỉ phải ánh xạ lại nếu phạm vi tệp được yêu cầu có
	nội dung giống nhau.  Nếu REMAP_FILE_CAN_SHORTEN được đặt, người gọi sẽ
	được với việc triển khai rút ngắn độ dài yêu cầu xuống
	đáp ứng các yêu cầu căn chỉnh hoặc EOF (hoặc bất kỳ lý do nào khác).

ZZ0000ZZ
	có thể được gọi bằng lệnh gọi hệ thống fadvise64().

ZZ0000ZZ
	Được gọi bằng lệnh gọi hệ thống mmap(2). Cho phép VFS thiết lập
	ánh xạ bộ nhớ dựa trên tập tin, đáng chú ý nhất là thiết lập có liên quan
	trạng thái riêng tư và lệnh gọi lại VMA.

Nếu cần có thêm hành động như điền trước bảng trang,
	điều này có thể được chỉ định bởi trường hành động vm_area_desc-> và có liên quan
	các thông số.

Lưu ý rằng các thao tác với tệp được thực hiện bởi
hệ thống tập tin trong đó inode cư trú.  Khi mở một nút thiết bị
(ký tự hoặc khối đặc biệt) hầu hết các hệ thống tập tin sẽ gọi đặc biệt
hỗ trợ các quy trình trong VFS sẽ định vị thiết bị được yêu cầu
thông tin tài xế.  Các thủ tục hỗ trợ này thay thế tệp hệ thống tập tin
các thao tác tương tự với các thao tác dành cho trình điều khiển thiết bị, sau đó tiến hành gọi
phương thức open() mới cho tệp.  Đây là cách mở tập tin thiết bị
trong hệ thống tập tin cuối cùng sẽ gọi trình điều khiển thiết bị open()
phương pháp.


Bộ nhớ đệm mục nhập thư mục (dcache)
==============================


struct nha khoa_hoạt động
------------------------

Điều này mô tả cách một hệ thống tập tin có thể làm quá tải bộ phận nha khoa tiêu chuẩn
hoạt động.  Dentries và dcache là miền của VFS và
triển khai hệ thống tập tin riêng lẻ.  Trình điều khiển thiết bị không có việc gì
ở đây.  Các phương thức này có thể được đặt thành NULL, vì chúng là tùy chọn hoặc
VFS sử dụng mặc định.  Kể từ kernel 2.6.22, các thành viên sau đây là
định nghĩa:

.. code-block:: c

	struct dentry_operations {
		int (*d_revalidate)(struct inode *, const struct qstr *,
				    struct dentry *, unsigned int);
		int (*d_weak_revalidate)(struct dentry *, unsigned int);
		int (*d_hash)(const struct dentry *, struct qstr *);
		int (*d_compare)(const struct dentry *,
				 unsigned int, const char *, const struct qstr *);
		int (*d_delete)(const struct dentry *);
		int (*d_init)(struct dentry *);
		void (*d_release)(struct dentry *);
		void (*d_iput)(struct dentry *, struct inode *);
		char *(*d_dname)(struct dentry *, char *, int);
		struct vfsmount *(*d_automount)(struct path *);
		int (*d_manage)(const struct path *, bool);
		struct dentry *(*d_real)(struct dentry *, enum d_real_type type);
		bool (*d_unalias_trylock)(const struct dentry *);
		void (*d_unalias_unlock)(const struct dentry *);
	};

ZZ0000ZZ
	được gọi khi VFS cần xác nhận lại nha khoa.  Đây là
	được gọi bất cứ khi nào việc tra cứu tên tìm thấy một nha khoa trong dcache.
	Hầu hết các hệ thống tập tin cục bộ để lại tên này là NULL, bởi vì tất cả các hệ thống tập tin của chúng
	nha khoa trong dcache là hợp lệ.  Hệ thống tập tin mạng là
	khác vì mọi thứ có thể thay đổi trên máy chủ mà không cần
	khách hàng nhất thiết phải nhận thức được nó.

Hàm này sẽ trả về giá trị dương nếu răng được
	vẫn hợp lệ và không có hoặc có mã lỗi âm nếu không.

d_revalidate có thể được gọi ở chế độ rcu-walk (cờ &
	LOOKUP_RCU).  Nếu ở chế độ rcu-walk, hệ thống tập tin phải
	xác nhận lại nha khoa mà không chặn hoặc lưu trữ vào nha khoa,
	Không nên sử dụng d_parent và d_inode một cách thiếu thận trọng (vì
	chúng có thể thay đổi và, trong trường hợp d_inode, thậm chí trở thành NULL theo
	chúng tôi).

Nếu gặp phải tình huống mà rcu-walk không thể xử lý được,
	trở về
	-ECHILD và nó sẽ được gọi lại ở chế độ đi lại.

ZZ0000ZZ
	được gọi khi VFS cần xác nhận lại một hàm răng "nhảy".  Cái này
	được gọi khi lối đi bộ kết thúc tại nha khoa không được thực hiện
	bằng cách thực hiện tra cứu trong thư mục mẹ.  Điều này bao gồm "/",
	"." và "..", cũng như các liên kết tượng trưng và điểm gắn kết kiểu Procfs
	đi qua.

Trong trường hợp này, chúng ta ít quan tâm đến việc liệu răng có
	vẫn hoàn toàn chính xác, nhưng đúng hơn là nút đó vẫn hợp lệ.
	Giống như d_revalidate, hầu hết các hệ thống tệp cục bộ sẽ đặt giá trị này thành
	NULL vì các mục dcache của chúng luôn hợp lệ.

Hàm này có cùng ngữ nghĩa mã trả về như
	d_xác nhận lại.

d_weak_revalidate chỉ được gọi sau khi thoát khỏi chế độ rcu-walk.

ZZ0000ZZ
	được gọi khi VFS thêm một răng vào bảng băm.  đầu tiên
	nha khoa được chuyển đến d_hash là thư mục mẹ có tên
	để được băm vào.

Quy tắc khóa và đồng bộ hóa tương tự như d_compare liên quan đến
	những gì là an toàn để hủy đăng ký, v.v.

ZZ0000ZZ
	được gọi để so sánh tên nha khoa với tên đã cho.  đầu tiên
	nha khoa là cha mẹ của nha khoa được so sánh, thứ hai là
	răng trẻ em.  chuỗi len và tên là các thuộc tính của
	nha khoa để so sánh.  qstr là tên để so sánh nó.

Phải là hằng số và bình thường, và không nên lấy khóa nếu
	có thể, và không nên hoặc cất giữ vào nha khoa.  không nên
	con trỏ dereference bên ngoài nha khoa mà không cần quan tâm nhiều
	(ví dụ: không nên sử dụng d_parent, d_inode, d_name).

Tuy nhiên, vfsmount của chúng tôi đã được ghim và RCU được giữ, vì vậy các răng giả
	và inode sẽ không biến mất, sb hoặc hệ thống tập tin của chúng tôi cũng vậy
	mô-đun.  ->d_sb có thể được sử dụng.

Đó là một quy ước gọi phức tạp vì nó cần được gọi
	trong "rcu-walk", tức là. không có bất kỳ khóa hoặc tài liệu tham khảo nào về mọi thứ.

ZZ0000ZZ
	được gọi khi tham chiếu cuối cùng đến một nha khoa bị loại bỏ và
	dcache đang quyết định có lưu nó vào bộ đệm hay không.  Trả lại 1 cho
	xóa ngay lập tức hoặc 0 để lưu vào bộ nhớ đệm của nha khoa.  Mặc định là NULL
	có nghĩa là luôn lưu trữ một nha khoa có thể tiếp cận được.  d_delete phải
	là hằng số và bình thường.

ZZ0000ZZ
	được gọi khi một nha khoa được phân bổ

ZZ0000ZZ
	được gọi khi một nha khoa thực sự được giải phóng

ZZ0000ZZ
	được gọi khi một nha khoa mất inode của nó (ngay trước khi nó được
	đã được giải phóng).  Mặc định khi đây là NULL thì VFS
	gọi iput().  Nếu bạn xác định phương thức này, bạn phải gọi iput()
	chính bạn

ZZ0000ZZ
	được gọi khi tên đường dẫn của một nha khoa sẽ được tạo.
	Hữu ích cho một số hệ thống tập tin giả (sockfs, pipefs, ...)
	trì hoãn việc tạo tên đường dẫn.  (Thay vì làm điều đó khi nha khoa
	được tạo, nó chỉ được thực hiện khi cần đường dẫn.).  thực
	hệ thống tập tin có thể không muốn sử dụng nó, bởi vì các răng của chúng
	có mặt trong hàm băm dcache toàn cầu, vì vậy hàm băm của chúng phải là một
	bất biến.  Vì không có khóa nào được giữ nên d_dname() không nên cố gắng
	tự sửa đổi nha khoa, trừ khi sử dụng giải pháp an toàn SMP thích hợp.
	Logic CAUTION : d_path() khá phức tạp.  Cách chính xác để
	ví dụ return "Xin chào" là đặt nó ở cuối
	đệm và trả về một con trỏ tới ký tự đầu tiên.
	Hàm trợ giúp Dynamic_dname() được cung cấp để xử lý
	cái này.

Ví dụ :

.. code-block:: c

	static char *pipefs_dname(struct dentry *dent, char *buffer, int buflen)
	{
		return dynamic_dname(dentry, buffer, buflen, "pipe:[%lu]",
				dentry->d_inode->i_ino);
	}

ZZ0000ZZ
	được gọi khi một răng giả tự động được đi qua (tùy chọn).
	Điều này sẽ tạo một bản ghi gắn VFS mới và trả về bản ghi
	tới người gọi.  Người gọi được cung cấp một tham số đường dẫn
	đưa ra thư mục automount để mô tả mục tiêu automount
	và bản ghi gắn kết VFS gốc để cung cấp khả năng gắn kết kế thừa
	các thông số.  NULL phải được trả lại nếu người khác quản lý
	thực hiện automount đầu tiên.  Nếu việc tạo vfsmount không thành công thì
	một mã lỗi sẽ được trả lại.  Nếu -EISDIR được trả về thì
	thư mục sẽ được coi như một thư mục bình thường và
	quay trở lại lối đi để tiếp tục đi bộ.

Nếu vfsmount được trả về, người gọi sẽ cố gắng gắn kết nó
	trên điểm gắn kết và sẽ xóa vfsmount khỏi điểm gắn kết của nó
	danh sách hết hạn trong trường hợp thất bại.

Chức năng này chỉ được sử dụng nếu DCACHE_NEED_AUTOMOUNT được bật
	nha khoa.  Điều này được thiết lập bởi __d_instantiate() nếu S_AUTOMOUNT là
	thiết lập trên inode đang được thêm vào.

ZZ0000ZZ
	được gọi để cho phép hệ thống tập tin quản lý quá trình chuyển đổi từ một
	nha khoa (tùy chọn).  Điều này cho phép các autofs, ví dụ, giữ nguyên
	khách hàng đang chờ khám phá phía sau 'điểm gắn kết' trong khi cho phép
	daemon đi qua và xây dựng cây con ở đó.  0 nên là
	quay trở lại để quá trình gọi tiếp tục.  -EISDIR có thể
	quay lại để yêu cầu pathwalk sử dụng thư mục này như một thư mục thông thường
	thư mục và bỏ qua mọi thứ được gắn trên đó và không kiểm tra
	cờ tự động đếm.  Bất kỳ mã lỗi nào khác sẽ hủy bỏ bước đi
	hoàn toàn.

Nếu tham số 'rcu_walk' là đúng thì người gọi đang thực hiện
	lối đi bộ ở chế độ đi bộ RCU.  Ngủ không được phép ở đây
	chế độ này và người gọi có thể được yêu cầu rời khỏi chế độ này và gọi lại bằng cách
	trở lại -ECHILD.  -EISDIR cũng có thể được trả lại để báo
	lối đi để bỏ qua d_automount hoặc bất kỳ thú cưỡi nào.

Chức năng này chỉ được sử dụng nếu DCACHE_MANAGE_TRANSIT được bật
	nha khoa đang được chuyển từ đó.

ZZ0000ZZ
	hệ thống tập tin loại lớp phủ/kết hợp thực hiện phương pháp này để trả về một
	các răng cưa cơ bản của một tệp thông thường bị ẩn bởi lớp phủ.

Đối số 'loại' nhận các giá trị D_REAL_DATA hoặc D_REAL_METADATA
	để trả về hàm răng thực sự bên dưới đề cập đến inode
	lưu trữ dữ liệu hoặc siêu dữ liệu của tệp tương ứng.

Đối với các tệp không thông thường, đối số 'dentry' được trả về.

ZZ0000ZZ
	nếu có, sẽ được gọi bởi d_splice_alias() trước khi di chuyển một
	bí danh đính kèm có sẵn.  Trả về sai sẽ ngăn cản __d_move(),
	làm cho d_splice_alias() thất bại với -ESTALE.

Lý do: cài đặt FS_RENAME_DOES_D_MOVE sẽ ngăn chặn d_move()
	và các cuộc gọi d_exchange() từ bên ngoài các phương thức hệ thống tập tin;
	tuy nhiên, điều đó không đảm bảo rằng răng gắn kèm sẽ không
	được đổi tên hoặc di chuyển bởi d_splice_alias() việc tìm kiếm một tồn tại từ trước
	bí danh cho một thư mục inode.  Thông thường chúng tôi sẽ không quan tâm;
	tuy nhiên, có điều gì đó muốn ổn định toàn bộ con đường đi đến
	root qua một hoạt động chặn có thể cần điều đó.  Xem 9p cho một
	(và hy vọng chỉ) ví dụ.

ZZ0000ZZ
	nên được ghép nối với ZZ0001ZZ; cái đó được gọi theo tên
	__d_move() gọi __d_unalias().


Mỗi nha khoa có một con trỏ tới nha khoa mẹ của nó, cũng như một danh sách băm
của răng trẻ em.  Các răng giả trẻ em về cơ bản giống như các tập tin trong một
thư mục.


Bộ nhớ đệm mục nhập thư mục API
--------------------------

Có một số chức năng được xác định cho phép một hệ thống tập tin
thao tác răng giả:

ZZ0000ZZ
	mở một tay cầm mới cho một hàm răng hiện có (điều này chỉ tăng lên
	số lần sử dụng)

ZZ0000ZZ
	đóng tay cầm cho một chiếc răng giả (giảm số lượng sử dụng).  Nếu
	số lượng sử dụng giảm xuống 0 và răng giả vẫn ở trạng thái đó
	hàm băm của cha mẹ, phương thức "d_delete" được gọi để kiểm tra xem
	nó nên được lưu trữ.  Nếu nó không được lưu vào bộ nhớ đệm hoặc nếu
	nha khoa không được băm, nó sẽ bị xóa.  Nếu không thì các nha khoa được lưu vào bộ nhớ đệm
	được đưa vào danh sách LRU để được thu hồi khi thiếu bộ nhớ.

ZZ0000ZZ
	thao tác này sẽ giải mã một nha khoa khỏi danh sách băm gốc của nó.  Tiếp theo
	gọi tới dput() sẽ phân bổ lại nha khoa nếu số lượng sử dụng của nó
	giảm xuống 0

ZZ0000ZZ
	xóa một nha khoa.  Nếu không có tài liệu tham khảo mở nào khác về
	hàm răng giả thì hàm răng đó sẽ biến thành hàm răng âm (
	phương thức d_iput() được gọi).  Nếu có tài liệu tham khảo khác thì
	thay vào đó, d_drop() được gọi

ZZ0000ZZ
	thêm một nha khoa vào danh sách băm cha mẹ của nó và sau đó gọi
	d_instantiate()

ZZ0000ZZ
	thêm một mục vào danh sách băm bí danh cho inode và các bản cập nhật
	thành viên "d_inode".  Thành viên "i_count" trong inode
	cấu trúc nên được thiết lập/tăng lên.  Nếu con trỏ inode là
	NULL, răng giả được gọi là "nha răng âm".  Chức năng này
	thường được gọi khi một nút được tạo cho một nút hiện có
	răng tiêu cực

ZZ0000ZZ
	tra cứu một nha khoa dựa trên thành phần tên đường dẫn và cha mẹ của nó.
	tra cứu tên con của tên đó từ hàm băm dcache
	cái bàn.  Nếu nó được tìm thấy, số lượng tham chiếu sẽ tăng lên và
	răng giả được trả lại.  Người gọi phải sử dụng dput() để giải phóng
	nha khoa khi sử dụng xong.


Tùy chọn gắn kết
=============


Tùy chọn phân tích cú pháp
---------------

Khi gắn kết và kết nối lại hệ thống tập tin được truyền một chuỗi chứa
danh sách các tùy chọn gắn kết được phân tách bằng dấu phẩy.  Các tùy chọn có thể có một trong hai
những hình thức này:

tùy chọn
  tùy chọn=giá trị

Tiêu đề <linux/parser.h> xác định API giúp phân tích những thứ này
tùy chọn.  Có rất nhiều ví dụ về cách sử dụng nó trong
hệ thống tập tin.


Hiển thị tùy chọn
---------------

Nếu một hệ thống tập tin chấp nhận các tùy chọn gắn kết, nó phải định nghĩa show_options() để
hiển thị tất cả các tùy chọn hiện đang hoạt động.  Các quy tắc là:

- tùy chọn MUST được hiển thị không phải là mặc định hoặc giá trị của chúng khác nhau
    từ mặc định

- các tùy chọn MAY được hiển thị được bật theo mặc định hoặc có
    giá trị mặc định

Các tùy chọn chỉ được sử dụng nội bộ giữa trình trợ giúp gắn kết và kernel (chẳng hạn như
dưới dạng mô tả tệp) hoặc chỉ có tác dụng trong quá trình cài đặt
(chẳng hạn như những cơ quan kiểm soát việc tạo ra một tạp chí) được miễn
quy định trên.

Lý do cơ bản của các quy tắc trên là để đảm bảo rằng thú cưỡi
có thể được sao chép chính xác (ví dụ: umounting và mount lại) dựa trên
dựa trên thông tin tìm thấy trong /proc/mounts.


Tài nguyên
=========

(Lưu ý một số tài nguyên này không cập nhật với kernel mới nhất
 phiên bản.)

Tạo hệ thống tập tin ảo Linux. 2002
    <ZZ0000ZZ

Lớp hệ thống tệp ảo Linux của Neil Brown. 1999
    <ZZ0000ZZ

Chuyến tham quan Linux VFS của Michael K. Johnson. 1996
    <ZZ0000ZZ

Một con đường nhỏ xuyên qua nhân Linux của Andries Brouwer. 2001
    <ZZ0000ZZ