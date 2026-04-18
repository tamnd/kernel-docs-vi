.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/mount_api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hệ thống tập tin Mount API
==========================

.. CONTENTS

 (1) Overview.

 (2) The filesystem context.

 (3) The filesystem context operations.

 (4) Filesystem context security.

 (5) VFS filesystem context API.

 (6) Superblock creation helpers.

 (7) Parameter description.

 (8) Parameter helper functions.


Tổng quan
========

Việc tạo các giá treo mới bây giờ được thực hiện theo quy trình gồm nhiều bước:

(1) Tạo bối cảnh hệ thống tập tin.

(2) Phân tích các tham số và đính kèm chúng vào ngữ cảnh.  Các thông số là
     dự kiến sẽ được truyền riêng lẻ từ không gian người dùng, mặc dù hệ nhị phân kế thừa
     các thông số cũng có thể được xử lý.

(3) Xác thực và xử lý trước bối cảnh.

(4) Nhận hoặc tạo một siêu khối và root có thể gắn kết.

(5) Thực hiện việc gắn kết.

(6) Trả về thông báo lỗi kèm theo ngữ cảnh.

(7) Phá hủy bối cảnh.

Để hỗ trợ điều này, cấu trúc file_system_type có hai trường mới::

int (*init_fs_context)(struct fs_context *fc);
	const struct fs_parameter_description *tham số;

Cái đầu tiên được gọi để thiết lập các phần dành riêng cho hệ thống tệp của hệ thống tệp
bối cảnh, bao gồm cả không gian bổ sung và điểm thứ hai tới
mô tả tham số để xác thực tại thời điểm đăng ký và truy vấn bởi một
cuộc gọi hệ thống trong tương lai.

Lưu ý rằng việc khởi tạo bảo mật đã được thực hiện ZZ0000ZZ hệ thống tập tin được gọi như vậy
rằng các không gian tên có thể được điều chỉnh trước tiên.


Bối cảnh hệ thống tập tin
======================

Việc tạo và cấu hình lại siêu khối được quản lý bởi hệ thống tập tin
bối cảnh.  Điều này được thể hiện bằng cấu trúc fs_context::

cấu trúc fs_context {
		const struct fs_context_Operation *ops;
		cấu trúc file_system_type *fs_type;
		void *fs_private;
		struct nha khoa *root;
		cấu trúc user_namespace *user_ns;
		cấu trúc mạng *net_ns;
		const struct cred *cred;
		nguồn char *;
		char *loại phụ;
		vô hiệu * bảo mật;
		vô hiệu *s_fs_info;
		int sb_flags không dấu;
		unsigned int sb_flags_mask;
		s_iflags int không dấu;
		enum fs_context_Mục đích:8;
		...
	};

Các trường fs_context như sau:

   * ::

const struct fs_context_Operation *ops

Đây là những thao tác có thể được thực hiện trên ngữ cảnh hệ thống tập tin (xem
     bên dưới).  Điều này phải được thiết lập bởi ->init_fs_context() file_system_type
     hoạt động.

   * ::

cấu trúc file_system_type *fs_type

Một con trỏ tới file_system_type của hệ thống tập tin đang được
     được xây dựng hoặc cấu hình lại.  Điều này giữ lại một tham chiếu về chủ sở hữu loại.

   * ::

vô hiệu *fs_private

Một con trỏ tới dữ liệu riêng tư của hệ thống tập tin.  Đây là nơi hệ thống tập tin
     sẽ cần lưu trữ bất kỳ tùy chọn nào mà nó phân tích.

   * ::

cấu trúc nha khoa *gốc

Một con trỏ tới gốc của cây có thể gắn kết (và gián tiếp,
     siêu khối của chúng).  Điều này được điền bởi lệnh ->get_tree().  Nếu điều này
     được đặt, một tham chiếu hoạt động trên root->d_sb cũng phải được giữ.

   * ::

cấu trúc user_namespace *user_ns
       cấu trúc mạng *net_ns

Có một tập hợp con các không gian tên được quy trình gọi sử dụng.  Họ
     giữ lại các tham chiếu trên mỗi không gian tên.  Các không gian tên được đăng ký có thể là
     được thay thế bởi hệ thống tập tin để phản ánh các nguồn khác, chẳng hạn như nguồn gốc
     gắn siêu khối trên automount.

   * ::

const struct tín dụng *cred

Thông tin xác thực của người leo núi.  Điều này giữ lại một tài liệu tham khảo về thông tin xác thực.

   * ::

nguồn char *

Điều này chỉ định nguồn.  Nó có thể là một thiết bị khối (ví dụ:/dev/sda1) hoặc
     thứ gì đó kỳ lạ hơn, chẳng hạn như "host:/path" mà NFS mong muốn.

   * ::

char *loại phụ

Đây là một chuỗi được thêm vào loại được hiển thị trong /proc/mounts to
     đủ điều kiện (được sử dụng bởi FUSE).  Điều này có sẵn cho hệ thống tập tin để thiết lập nếu
     mong muốn.

   * ::

vô hiệu * bảo mật

Nơi để các LSM treo dữ liệu bảo mật của họ cho siêu khối.  các
     các hoạt động bảo mật liên quan được mô tả dưới đây.

   * ::

vô hiệu *s_fs_info

s_fs_info được đề xuất cho siêu khối mới, được đặt trong siêu khối bởi
     sget_fc().  Điều này có thể được sử dụng để phân biệt các siêu khối.

   * ::

int sb_flags không dấu
       int không dấu sb_flags_mask

Cờ SB_* bit nào sẽ được đặt/xóa trong super_block::s_flags.

   * ::

int không dấu s_iflags

Đây sẽ là bitwise-OR'd với s->s_iflags khi siêu khối được tạo.

   * ::

enum fs_context_pure

Điều này cho biết mục đích mà bối cảnh được hướng tới.  các
     các giá trị có sẵn là:

======================================================================
	FS_CONTEXT_FOR_MOUNT, Siêu khối mới để gắn kết rõ ràng
	FS_CONTEXT_FOR_SUBMOUNT Giá đỡ phụ tự động mới của giá treo hiện có
	FS_CONTEXT_FOR_RECONFIGURE Thay đổi giá treo hiện có
	======================================================================

Bối cảnh gắn kết được tạo bằng cách gọi vfs_new_fs_context() hoặc
vfs_dup_fs_context() và bị hủy bằng put_fs_context().  Lưu ý rằng
cấu trúc không được hoàn trả.

VFS, các tùy chọn gắn kết hệ thống tệp và bảo mật được đặt riêng với
vfs_parse_mount_option().  Các tùy chọn được cung cấp bởi lệnh gọi hệ thống mount(2) cũ dưới dạng
một trang dữ liệu có thể được phân tích cú pháp bằng generic_parse_monolithic().

Khi gắn kết, hệ thống tập tin được phép lấy dữ liệu từ bất kỳ con trỏ nào
và gắn nó vào siêu khối (hoặc bất cứ thứ gì), miễn là nó xóa con trỏ
trong bối cảnh gắn kết.

Hệ thống tập tin cũng được phép phân bổ tài nguyên và ghim chúng bằng
gắn kết bối cảnh.  Chẳng hạn, NFS có thể ghim phiên bản giao thức thích hợp
mô-đun.


Các hoạt động bối cảnh của hệ thống tập tin
=================================

Bối cảnh hệ thống tập tin trỏ đến một bảng hoạt động::

cấu trúc fs_context_operating {
		khoảng trống (*free)(struct fs_context *fc);
		int (*dup)(struct fs_context *fc, struct fs_context *src_fc);
		int (*parse_param)(struct fs_context *fc,
				   cấu trúc fs_parameter *param);
		int (*parse_monolithic)(struct fs_context *fc, void *dữ liệu);
		int (*get_tree)(struct fs_context *fc);
		int (*reconfigure)(struct fs_context *fc);
	};

Các hoạt động này được gọi ra bởi các giai đoạn khác nhau của thủ tục gắn kết để
quản lý bối cảnh hệ thống tập tin.  Chúng như sau:

   * ::

khoảng trống (*free)(struct fs_context *fc);

Được gọi để dọn sạch phần dành riêng cho hệ thống tệp của bối cảnh hệ thống tệp
     khi bối cảnh bị phá hủy.  Cần biết rằng các bộ phận của
     bối cảnh có thể đã bị xóa và NULL đã bị xóa bởi ->get_tree().

   * ::

int (*dup)(struct fs_context *fc, struct fs_context *src_fc);

Được gọi khi bối cảnh hệ thống tập tin đã được sao chép để sao chép
     dữ liệu riêng tư của hệ thống tập tin.  Một lỗi có thể được trả về để chỉ ra sự thất bại
     làm điều này.

     .. Warning::

         Note that even if this fails, put_fs_context() will be called
ngay sau đó, vì vậy ->dup() ZZ0000ZZ thực hiện
	 dữ liệu riêng tư của hệ thống tệp an toàn cho ->free().

   * ::

int (*parse_param)(struct fs_context *fc,
			   cấu trúc fs_parameter *param);

Được gọi khi một tham số đang được thêm vào ngữ cảnh hệ thống tập tin.  thông số
     trỏ đến tên khóa và có thể là một đối tượng giá trị.  Tùy chọn dành riêng cho VFS
     sẽ bị loại bỏ và fc->sb_flags được cập nhật trong ngữ cảnh.
     Các tùy chọn bảo mật cũng sẽ bị loại bỏ và fc->security sẽ được cập nhật.

Tham số này có thể được phân tích cú pháp bằng fs_parse() và fs_lookup_param().  Lưu ý
     rằng (các) nguồn được trình bày dưới dạng tham số có tên là "nguồn".

Nếu thành công, giá trị sẽ được trả về là 0 hoặc mã lỗi âm.

   * ::

int (*parse_monolithic)(struct fs_context *fc, void *dữ liệu);

Được gọi khi lệnh gọi hệ thống mount(2) được gọi để truyền toàn bộ dữ liệu
     trang trong một lần.  Nếu dự kiến đây chỉ là danh sách "key[=val]"
     các mục được phân tách bằng dấu phẩy thì mục này có thể được đặt thành NULL.

Giá trị trả về giống như ->parse_param().

Nếu hệ thống tập tin (ví dụ NFS) cần kiểm tra dữ liệu trước và sau đó
     thấy đó là danh sách khóa-val tiêu chuẩn thì nó có thể chuyển nó cho
     generic_parse_monolithic().

   * ::

int (*get_tree)(struct fs_context *fc);

Được gọi để lấy hoặc tạo root và superblock có thể gắn được, sử dụng
     thông tin được lưu trữ trong bối cảnh hệ thống tập tin (cấu hình lại đi qua một
     vectơ khác nhau).  Nó có thể tách bất kỳ tài nguyên nào nó mong muốn khỏi
     bối cảnh hệ thống tập tin và chuyển chúng vào siêu khối mà nó tạo ra.

Nếu thành công, nó sẽ đặt fc->root thành root có thể gắn kết và trả về 0. Trong
     trường hợp có lỗi thì sẽ trả về mã lỗi âm.

Giai đoạn trên bối cảnh hướng đến không gian người dùng sẽ được đặt thành chỉ cho phép điều này
     được gọi một lần trong bất kỳ bối cảnh cụ thể nào.

   * ::

int (*reconfigure)(struct fs_context *fc);

Được gọi để thực hiện việc cấu hình lại siêu khối bằng cách sử dụng thông tin được lưu trữ
     trong bối cảnh hệ thống tập tin.  Nó có thể tách bất kỳ tài nguyên nào nó mong muốn khỏi
     bối cảnh hệ thống tập tin và chuyển chúng vào siêu khối.  các
     superblock có thể được tìm thấy từ fc->root->d_sb.

Nếu thành công, nó sẽ trả về 0. Trong trường hợp có lỗi, nó sẽ trả về
     một mã lỗi tiêu cực.


Bối cảnh hệ thống tập tin Bảo mật
===========================

Bối cảnh hệ thống tập tin chứa một con trỏ bảo mật mà LSM có thể sử dụng để
xây dựng bối cảnh bảo mật cho siêu khối được gắn kết.  có một
số thao tác được sử dụng bởi mã gắn kết mới cho mục đích này:

   * ::

int security_fs_context_alloc(struct fs_context *fc,
				      struct nha khoa *tham khảo);

Được gọi để khởi tạo fc->security (được đặt trước cho NULL) và phân bổ
     bất kỳ nguồn lực cần thiết.  Nó sẽ trả về 0 nếu thành công hoặc có lỗi tiêu cực
     mã khi thất bại.

tham chiếu sẽ không phải là NULL nếu bối cảnh được tạo cho siêu khối
     cấu hình lại (FS_CONTEXT_FOR_RECONFIGURE) trong trường hợp đó nó chỉ ra
     phần gốc của siêu khối sẽ được cấu hình lại.  Nó cũng sẽ là
     không phải NULL trong trường hợp giá trị phụ (FS_CONTEXT_FOR_SUBMOUNT) trong trường hợp đó
     nó chỉ ra điểm tự động đếm.

   * ::

int security_fs_context_dup(struct fs_context *fc,
				    cấu trúc fs_context *src_fc);

Được gọi để khởi tạo fc->security (được đặt trước cho NULL) và phân bổ
     bất kỳ nguồn lực cần thiết.  Bối cảnh hệ thống tập tin ban đầu được trỏ đến bởi
     src_fc và có thể được sử dụng để tham khảo.  Nó sẽ trả về 0 nếu thành công hoặc
     mã lỗi tiêu cực khi thất bại.

   * ::

void security_fs_context_free(struct fs_context *fc);

Được gọi để dọn dẹp mọi thứ gắn liền với fc->security.  Lưu ý rằng
     nội dung có thể đã được chuyển sang siêu khối và con trỏ bị xóa
     trong get_tree.

   * ::

int security_fs_context_parse_param(struct fs_context *fc,
					    cấu trúc fs_parameter *param);

Được gọi cho từng tham số gắn kết, bao gồm cả nguồn.  Các lý lẽ là
     đối với phương thức ->parse_param().  Nó sẽ trả về 0 để chỉ ra rằng
     tham số phải được chuyển vào hệ thống tập tin, 1 để chỉ ra rằng
     tham số sẽ bị loại bỏ hoặc có lỗi cho biết rằng
     tham số nên bị từ chối.

Giá trị được trỏ đến bởi param có thể bị sửa đổi (nếu là một chuỗi) hoặc bị đánh cắp
     (với điều kiện là con trỏ giá trị là NULL).  Nếu nó bị đánh cắp, 1 phải là
     được trả về để ngăn nó được chuyển vào hệ thống tập tin.

   * ::

int security_fs_context_validate(struct fs_context *fc);

Được gọi sau khi tất cả các tùy chọn đã được phân tích cú pháp để xác thực bộ sưu tập
     nói chung và thực hiện bất kỳ sự phân bổ cần thiết nào để
     security_sb_get_tree() và security_sb_reconfigure() ít có khả năng
     thất bại.  Nó sẽ trả về 0 hoặc mã lỗi âm.

Trong trường hợp cấu hình lại, siêu khối mục tiêu sẽ có thể truy cập được
     thông qua fc->root.

   * ::

int security_sb_get_tree(struct fs_context *fc);

Được gọi trong quá trình gắn kết để xác minh rằng siêu khối được chỉ định
     được phép gắn kết và chuyển dữ liệu bảo mật đến đó.  Nó
     sẽ trả về 0 hoặc mã lỗi âm.

   * ::

void security_sb_reconfigure(struct fs_context *fc);

Được gọi để áp dụng bất kỳ cấu hình lại nào cho ngữ cảnh của LSM.  Nó không được
     thất bại.  Việc kiểm tra lỗi và phân bổ nguồn lực phải được thực hiện trước bởi
     các móc phân tích cú pháp và xác nhận tham số.

   * ::

int security_sb_mountpoint(struct fs_context *fc,
			           đường dẫn cấu trúc * điểm gắn kết,
				   unsigned int mnt_flags);

Được gọi trong quá trình gắn kết để xác minh rằng răng gốc đã được gắn vào
     vào ngữ cảnh được phép gắn vào điểm gắn kết được chỉ định.
     Nó sẽ trả về 0 nếu thành công hoặc mã lỗi âm nếu thất bại.


VFS Bối cảnh hệ thống tập tin API
==========================

Có bốn thao tác để tạo ngữ cảnh hệ thống tập tin và một thao tác để
phá hủy một bối cảnh:

   * ::

cấu trúc fs_context *fs_context_for_mount(struct file_system_type *fs_type,
					       int sb_flags không dấu);

Phân bổ bối cảnh hệ thống tập tin cho mục đích thiết lập một mount mới,
     cho dù đó là với siêu khối mới hay chia sẻ siêu khối hiện có.  Cái này
     đặt cờ siêu khối, khởi tạo bảo mật và gọi
     fs_type->init_fs_context() để khởi tạo dữ liệu riêng tư của hệ thống tệp.

fs_type chỉ định loại hệ thống tệp sẽ quản lý ngữ cảnh và
     sb_flags đặt trước các cờ siêu khối được lưu trữ trong đó.

   * ::

cấu trúc fs_context *fs_context_for_reconfigure(
		cấu trúc nha khoa *nha khoa,
		int sb_flags không dấu,
		unsigned int sb_flags_mask);

Phân bổ bối cảnh hệ thống tập tin nhằm mục đích cấu hình lại một
     siêu khối hiện có.  nha khoa cung cấp một tham chiếu đến siêu khối
     được cấu hình.  sb_flags và sb_flags_mask cho biết cờ siêu khối nào
     cần thay đổi và để làm gì.

   * ::

cấu trúc fs_context *fs_context_for_submount(
		cấu trúc file_system_type *fs_type,
		struct nha khoa *tham khảo);

Phân bổ bối cảnh hệ thống tập tin nhằm mục đích tạo một mount mới cho
     một điểm tự động đếm hoặc siêu khối dẫn xuất khác.  fs_type chỉ định
     loại hệ thống tập tin sẽ quản lý bối cảnh và nha khoa tham chiếu
     cung cấp các thông số  Không gian tên được truyền bá từ tham chiếu
     siêu khối của nha khoa cũng vậy.

Lưu ý rằng không yêu cầu răng hàm tham chiếu phải giống nhau
     loại hệ thống tập tin là fs_type.

   * ::

cấu trúc fs_context *vfs_dup_fs_context(struct fs_context *src_fc);

Sao chép bối cảnh hệ thống tập tin, sao chép bất kỳ tùy chọn nào được ghi chú và sao chép
     hoặc tham chiếu thêm bất kỳ tài nguyên nào có trong đó.  Cái này có sẵn
     để sử dụng khi hệ thống tập tin phải có được một giá treo trong một giá treo, chẳng hạn như NFS4
     thực hiện bằng cách gắn vào bên trong thư mục gốc của máy chủ mục tiêu và sau đó thực hiện
     lối đi riêng tới thư mục đích.

Mục đích trong bối cảnh mới được kế thừa từ bối cảnh cũ.

   * ::

void put_fs_context(struct fs_context *fc);

Phá hủy bối cảnh hệ thống tập tin, giải phóng mọi tài nguyên mà nó nắm giữ.  Cái này
     gọi hoạt động ->free().  Điều này được dự định sẽ được gọi bởi bất cứ ai
     đã tạo bối cảnh hệ thống tập tin.

     .. Warning::

        filesystem contexts are not refcounted, so this causes unconditional
sự phá hủy.

Trong tất cả các hoạt động trên, ngoài lệnh bán, lệnh trả về là một lệnh gắn kết
con trỏ ngữ cảnh hoặc mã lỗi âm.

Các thao tác còn lại nếu xảy ra lỗi sẽ có mã lỗi âm
đã quay trở lại.

   * ::

int vfs_parse_fs_param(struct fs_context *fc,
			       cấu trúc fs_parameter *param);

Cung cấp một tham số gắn kết duy nhất cho bối cảnh hệ thống tập tin.  Điều này bao gồm
     đặc điểm kỹ thuật của nguồn/thiết bị được chỉ định là "nguồn"
     tham số (có thể được chỉ định nhiều lần nếu hệ thống tập tin
     ủng hộ điều đó).

param chỉ định tên khóa tham số và giá trị.  Tham số là
     đầu tiên hãy kiểm tra xem nó có tương ứng với cờ gắn kết tiêu chuẩn không (trong đó
     trường hợp nó được sử dụng để đặt cờ SB_xxx và sử dụng) hoặc tùy chọn bảo mật
     (trong trường hợp đó LSM tiêu thụ nó) trước khi nó được chuyển tới
     hệ thống tập tin.

Giá trị tham số được nhập và có thể là một trong:

=====================================================
	fs_value_is_flag Tham số không được cung cấp giá trị
	fs_value_is_string Giá trị là một chuỗi
	fs_value_is_blob Giá trị là một blob nhị phân
	fs_value_is_filename Giá trị là tên tệp* + dirfd
	fs_value_is_file Giá trị là một tệp đang mở (tệp*)
	=====================================================

Nếu có một giá trị, giá trị đó sẽ được lưu trữ trong một liên kết trong cấu trúc trong một
     của param->{string,blob,name,file}.  Lưu ý rằng chức năng này có thể lấy cắp và
     xóa con trỏ, nhưng sau đó chịu trách nhiệm xử lý
     đối tượng.

   * ::

int vfs_parse_fs_qstr(struct fs_context *fc, const char *key,
			       const struct qstr *value);

Một trình bao bọc xung quanh vfs_parse_fs_param() sao chép chuỗi giá trị của nó
     đã qua.

   * ::

int vfs_parse_fs_string(struct fs_context *fc, const char *key,
			       giá trị const char *);

Một trình bao bọc xung quanh vfs_parse_fs_param() sao chép chuỗi giá trị của nó
     đã qua.

   * ::

int generic_parse_monolithic(struct fs_context *fc, void *data);

Phân tích trang dữ liệu sys_mount(), giả sử biểu mẫu là danh sách văn bản
     bao gồm các tùy chọn key[=val] được phân tách bằng dấu phẩy.  Mỗi mục trong
     danh sách được chuyển tới vfs_mount_option().  Đây là mặc định khi
     ->phương thức parse_monolithic() là NULL.

   * ::

int vfs_get_tree(struct fs_context *fc);

Nhận hoặc tạo root và superblock có thể gắn được, sử dụng các tham số trong
     bối cảnh hệ thống tập tin để chọn/cấu hình siêu khối.  Điều này gọi
     phương thức ->get_tree().

   * ::

cấu trúc vfsmount *vfs_create_mount(struct fs_context *fc);

Tạo một giá trị gắn kết với các tham số trong ngữ cảnh hệ thống tệp được chỉ định.
     Lưu ý rằng điều này không gắn giá đỡ vào bất cứ thứ gì.


Người trợ giúp tạo siêu khối
===========================

Một số trình trợ giúp VFS có sẵn để các hệ thống tệp sử dụng để tạo
hoặc tra cứu các siêu khối.

   * ::

cấu trúc super_block *
       sget_fc(struct fs_context *fc,
	       int (*test)(struct super_block *sb, struct fs_context *fc),
	       int (*set)(struct super_block *sb, struct fs_context *fc));

Đây là thói quen cốt lõi.  Nếu kết quả kiểm tra không phải là NULL, nó sẽ tìm kiếm một
     siêu khối hiện có phù hợp với tiêu chí được giữ trong fs_context, sử dụng
     chức năng kiểm tra để phù hợp với chúng.  Nếu không tìm thấy kết quả phù hợp, một siêu khối mới
     được tạo và hàm set được gọi để thiết lập nó.

Trước khi hàm set được gọi, fc->s_fs_info sẽ được chuyển
     tới sb->s_fs_info - và fc->s_fs_info sẽ bị xóa nếu set trả về
     thành công (tức là 0).

Tất cả những người trợ giúp sau đây đều gói sget_fc():

(1) vfs_get_single_super

Chỉ có một siêu khối như vậy có thể tồn tại trong hệ thống.  Hơn nữa
	    cố gắng có được một siêu khối mới sẽ nhận được siêu khối này (và bất kỳ tham số nào
	    sự khác biệt được bỏ qua).

(2) vfs_get_keyed_super

Nhiều siêu khối thuộc loại này có thể tồn tại và chúng được khóa
	    con trỏ s_fs_info của họ (ví dụ: điều này có thể đề cập đến một
	    không gian tên).

(3) vfs_get_independence_super

Nhiều siêu khối độc lập thuộc loại này có thể tồn tại.  Cái này
	    hàm không bao giờ khớp với hàm hiện có và luôn tạo một hàm mới
	    một.


Mô tả tham số
=====================

Các tham số được mô tả bằng các cấu trúc được xác định trong linux/fs_parser.h.
Có một cấu trúc mô tả cốt lõi liên kết mọi thứ lại với nhau ::

cấu trúc fs_parameter_description {
		const struct fs_parameter_spec *spec;
		const struct fs_parameter_enum *enums;
	};

Ví dụ::

liệt kê {
		Opt_autocell,
		Opt_bar,
		opt_dyn,
		chọn_foo,
		Opt_source,
	};

cấu trúc const tĩnh fs_parameter_description afs_fs_parameters = {
		.specs = afs_param_specs,
		.enums = afs_param_enums,
	};

Các thành viên như sau:

(1) ::

const struct fs_parameter_specization *thông số kỹ thuật;

Bảng thông số kỹ thuật tham số, được kết thúc bằng mục nhập rỗng, trong đó
     các mục có loại::

cấu trúc fs_parameter_spec {
		const char *tên;
		lựa chọn u8;
		enum fs_parameter_type loại:8;
		cờ ngắn không dấu;
	};

Trường 'tên' là một chuỗi khớp chính xác với khóa tham số (không
     ký tự đại diện, mẫu và không phân biệt chữ hoa chữ thường) và 'opt' là giá trị
     sẽ được hàm fs_parser() trả về trong trường hợp thành công
     trận đấu.

Trường 'loại' cho biết loại giá trị mong muốn và phải là một trong:

================================================ ========================
	TYPE NAME EXPECTED VALUE RESULT TRONG
	================================================ ========================
	fs_param_is_flag Không có giá trị n/a
	fs_param_is_bool Kết quả giá trị Boolean->boolean
	fs_param_is_u32 Kết quả int không dấu 32 bit->uint_32
	fs_param_is_u32_octal Kết quả int bát phân 32 bit->uint_32
	fs_param_is_u32_hex Kết quả int hex 32 bit->uint_32
	fs_param_is_s32 Kết quả int có chữ ký 32-bit->int_32
	fs_param_is_u64 Kết quả int không dấu 64-bit->uint_64
	fs_param_is_enum Kết quả tên giá trị Enum->uint_32
	fs_param_is_string Chuỗi tùy ý param->string
	fs_param_is_blockdev Đường dẫn Blockdev * Cần tra cứu
	fs_param_is_fd Kết quả mô tả tệp->int_32
	kết quả fs_param_is_uid ID người dùng (u32)->uid
	Kết quả fs_param_is_gid ID nhóm (u32)->gid
	================================================ ========================

Lưu ý rằng nếu giá trị thuộc loại fs_param_is_bool, fs_parse() sẽ thử
     để khớp bất kỳ giá trị chuỗi nào với "0", "1", "no", "yes", "false", "true".

Mỗi tham số cũng có thể được xác định bằng 'cờ':

=============================================================================
	fs_param_v_Optional Giá trị là tùy chọn
	kết quả fs_param_neg_with_no->được đặt phủ định nếu khóa có tiền tố là "không"
	kết quả fs_param_neg_with_empty->được đặt phủ định nếu giá trị là ""
	fs_param_deprecated Tham số này không còn được dùng nữa.
	=============================================================================

Chúng được gói bằng một số giấy gói tiện lợi:

============================================================================
	MACRO SPECIFIES
	============================================================================
	fsparam_flag() fs_param_is_flag
	fsparam_flag_no() fs_param_is_flag, fs_param_neg_with_no
	fsparam_bool() fs_param_is_bool
	fsparam_u32() fs_param_is_u32
	fsparam_u32oct() fs_param_is_u32_oct
	fsparam_s32() fs_param_is_s32
	fsparam_u64() fs_param_is_u64
	fsparam_enum() fs_param_is_enum
	fsparam_string() fs_param_is_string
	fsparam_bdev() fs_param_is_blockdev
	fsparam_fd() fs_param_is_fd
	fsparam_uid() fs_param_is_uid
	fsparam_gid() fs_param_is_gid
	============================================================================

tất cả đều có hai đối số, chuỗi tên và số tùy chọn - dành cho
     ví dụ::

cấu trúc const tĩnh fs_parameter_spec afs_param_specs[] = {
		fsparam_flag ("autocell", Opt_autocell),
		fsparam_flag ("dyn", Opt_dyn),
		fsparam_string ("nguồn", Opt_source),
		fsparam_flag_no ("foo", Opt_foo),
		{}
	};

Một macro bổ sung, __fsparam() được cung cấp để có thêm một cặp
     các đối số để chỉ định loại và cờ cho bất kỳ thứ gì không
     khớp với một trong các macro ở trên.

(2) ::

const struct fs_parameter_enum *enums;

Bảng tên giá trị enum thành ánh xạ số nguyên, được kết thúc bằng giá trị rỗng
     nhập cảnh.  Đây là loại::

cấu trúc fs_parameter_enum {
		lựa chọn u8;
		tên char[14];
		giá trị u8;
	};

Trong đó mảng là danh sách chưa được sắp xếp của { tham số ID, tên } có khóa
     các phần tử chỉ ra giá trị cần ánh xạ tới, ví dụ:::

cấu trúc const tĩnh fs_parameter_enum afs_param_enums[] = {
		{ Opt_bar, "x", 1},
		{ Opt_bar, "y", 23},
		{ Opt_bar, "z", 42},
	};

Nếu gặp tham số loại fs_param_is_enum, fs_parse() sẽ
     hãy thử tra cứu giá trị trong bảng enum và kết quả sẽ được lưu trữ
     trong kết quả phân tích cú pháp.

Trình phân tích cú pháp phải được trỏ tới bởi con trỏ trình phân tích cú pháp trong file_system_type
struct vì điều này sẽ cung cấp xác thực khi đăng ký (nếu
CONFIG_VALIDATE_FS_PARSER=y) và sẽ cho phép truy vấn mô tả từ
không gian người dùng bằng cách sử dụng lệnh gọi tòa nhà fsinfo().


Chức năng trợ giúp tham số
==========================

Một số chức năng trợ giúp được cung cấp để trợ giúp hệ thống tệp hoặc LSM
xử lý các tham số được đưa ra.

   * ::

int lookup_constant(const struct constant_table tbl[],
			   const char *name, int not_found);

Tra cứu một hằng số theo tên trong bảng tên -> ánh xạ số nguyên.  các
     bảng là một mảng gồm các phần tử có kiểu sau::

cấu trúc hằng_bảng {
		const char *tên;
		giá trị int;
	};

Nếu tìm thấy kết quả khớp, giá trị tương ứng sẽ được trả về.  Nếu một trận đấu
     không tìm thấy, thay vào đó giá trị not_found sẽ được trả về.

   * ::

bool fs_validate_description(const char *name,
                                    const struct fs_parameter_description *desc);

Điều này thực hiện một số kiểm tra xác nhận trên mô tả tham số.  Nó
     trả về true nếu mô tả tốt và sai nếu không.  Nó sẽ
     log lỗi vào bộ đệm nhật ký kernel nếu xác thực không thành công.

   * ::

int fs_parse(struct fs_context *fc,
		     const struct fs_parameter_description *desc,
		     cấu trúc fs_parameter *param,
		     cấu trúc fs_parse_result *kết quả);

Đây là trình thông dịch chính của các tham số.  Nó sử dụng tham số
     mô tả để tra cứu một tham số theo tên khóa và chuyển đổi nó thành một
     số tùy chọn (nó trả về).

Nếu thành công và nếu loại tham số cho biết kết quả là
     kiểu boolean, số nguyên, enum, uid hoặc gid, giá trị được chuyển đổi bằng cách này
     hàm và kết quả được lưu trữ trong
     kết quả->{boolean,int_32,uint_32,uint_64,uid,gid}.

Nếu ban đầu không khớp thì khóa sẽ có tiền tố là "không" và không
     giá trị hiện diện thì nỗ lực sẽ được thực hiện để tra cứu khóa bằng
     tiền tố bị loại bỏ.  Nếu điều này khớp với một tham số mà loại có cờ
     fs_param_neg_with_no được đặt, thì kết quả khớp sẽ được thực hiện và kết quả-> phủ định
     sẽ được đặt thành đúng.

Nếu tham số không khớp, -ENOPARAM sẽ được trả về; nếu
     tham số được khớp nhưng giá trị sai, -EINVAL sẽ là
     trở lại; nếu không thì số tùy chọn của tham số sẽ được trả về.

   * ::

int fs_lookup_param(struct fs_context *fc,
			   cấu trúc fs_parameter *giá trị,
			   bool muốn_bdev,
			   cờ int không dấu,
			   đường dẫn cấu trúc *_path);

Cái này lấy một tham số mang kiểu chuỗi hoặc tên tệp và thử
     để thực hiện tra cứu đường dẫn trên đó.  Nếu tham số mong đợi một blockdev, hãy kiểm tra
     được làm cho inode thực sự đại diện cho một.

Trả về 0 nếu thành công và ZZ0000ZZ sẽ được đặt; trả về số âm
     mã lỗi nếu không.