.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/debugfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=======
Gỡ lỗiFS
=======

Bản quyền ZZ0000ZZ 2009 Jonathan Corbet <corbet@lwn.net>

Debugfs tồn tại như một cách đơn giản để các nhà phát triển kernel tạo ra thông tin
có sẵn cho không gian người dùng.  Không giống như /proc, chỉ dùng để cung cấp thông tin
về một quy trình hoặc sysfs, có quy tắc nghiêm ngặt một giá trị cho mỗi tệp,
debugfs không có quy tắc nào cả.  Nhà phát triển có thể đưa bất kỳ thông tin nào họ muốn
ở đó.  Hệ thống tập tin debugfs cũng nhằm mục đích không phục vụ như một hệ thống ổn định
ABI vào không gian người dùng; về mặt lý thuyết, không có ràng buộc về độ ổn định nào được đặt ra trên
các tập tin được xuất ở đó.  Tuy nhiên, thế giới thực không phải lúc nào cũng đơn giản như vậy [1]_;
ngay cả giao diện debugfs cũng được thiết kế tốt nhất với ý tưởng rằng họ sẽ cần
để được duy trì mãi mãi.

Debugfs thường được gắn bằng lệnh như ::

mount -t debugfs none /sys/kernel/debug

(Hoặc một dòng /etc/fstab tương đương).
Thư mục gốc debugfs chỉ có thể được truy cập bởi người dùng root
mặc định. Để thay đổi quyền truy cập vào cây, hãy gắn "uid", "gid" và "mode"
tùy chọn có thể được sử dụng.

Lưu ý rằng các bản gỡ lỗi API chỉ được xuất GPL sang các mô-đun.

Mã sử ​​dụng debugf phải bao gồm <linux/debugfs.h>.  Sau đó, lệnh đầu tiên
của doanh nghiệp sẽ là tạo ít nhất một thư mục để chứa một tập hợp
tập tin debugfs::

struct nha khoa *debugfs_create_dir(const char *name, struct nha khoa *parent);

Cuộc gọi này, nếu thành công, sẽ tạo một thư mục có tên name bên dưới
thư mục cha được chỉ định.  Nếu cha mẹ là NULL, thư mục sẽ là
được tạo trong thư mục gốc debugfs.  Khi thành công, giá trị trả về là một cấu trúc
con trỏ nha khoa có thể được sử dụng để tạo các tập tin trong thư mục (và để
làm sạch nó ở cuối).  Giá trị trả về ERR_PTR(-ERROR) chỉ ra rằng
có điều gì đó không ổn.  Nếu ERR_PTR(-ENODEV) được trả về, đó là một
dấu hiệu cho thấy kernel đã được xây dựng mà không có hỗ trợ debugfs và không có
trong số các chức năng được mô tả dưới đây sẽ hoạt động.

Cách tổng quát nhất để tạo một tệp trong thư mục debugfs là sử dụng ::

cấu trúc nha khoa *debugfs_create_file(const char *name, chế độ umode_t,
				       cấu trúc nha khoa *parent, void *data,
				       const struct file_Operations *fops);

Ở đây, name là tên file cần tạo, mode mô tả quyền truy cập
quyền mà tập tin phải có, cha mẹ chỉ ra thư mục chứa
nên giữ tệp, dữ liệu sẽ được lưu trữ trong trường i_private của
cấu trúc inode thu được và fops là một tập hợp các thao tác tệp
thực hiện hành vi của tập tin.  Ở mức tối thiểu, read() và/hoặc write()
hoạt động cần được cung cấp; những người khác có thể được bao gồm khi cần thiết.  Một lần nữa,
giá trị trả về sẽ là một con trỏ nha khoa tới tệp đã tạo,
ERR_PTR(-ERROR) bị lỗi hoặc ERR_PTR(-ENODEV) nếu hỗ trợ debugfs
thiếu.

Tạo một tệp có kích thước ban đầu, có thể sử dụng chức năng sau
thay vào đó::

void debugfs_create_file_size(const char *name, chế độ umode_t,
				  cấu trúc nha khoa *parent, void *data,
				  const struct file_Operations *fops,
				  loff_t file_size);

file_size là kích thước tệp ban đầu. Các thông số khác đều giống nhau
như hàm debugfs_create_file.

Trong một số trường hợp, việc tạo ra một tập hợp các thao tác tập tin không
thực sự cần thiết; mã debugfs cung cấp một số chức năng trợ giúp
cho những tình huống đơn giản.  Các tập tin chứa một giá trị số nguyên có thể được
được tạo bằng bất kỳ::

void debugfs_create_u8(const char *name, chế độ umode_t,
			   cấu trúc nha khoa *parent, u8 *value);
    void debugfs_create_u16(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, u16 *value);
    void debugfs_create_u32(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, u32 *value);
    void debugfs_create_u64(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, u64 *value);

Những tệp này hỗ trợ cả đọc và ghi giá trị đã cho; nếu một điều cụ thể
không nên ghi vào tệp, chỉ cần đặt các bit chế độ cho phù hợp.  các
các giá trị trong các tệp này ở dạng thập phân; nếu hệ thập lục phân thích hợp hơn,
các chức năng sau có thể được sử dụng thay thế::

void debugfs_create_x8(const char *name, chế độ umode_t,
			   cấu trúc nha khoa *parent, u8 *value);
    void debugfs_create_x16(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, u16 *value);
    void debugfs_create_x32(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, u32 *value);
    void debugfs_create_x64(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, u64 *value);

Các chức năng này hữu ích miễn là nhà phát triển biết kích thước của
giá trị cần xuất khẩu.  Một số loại có thể có chiều rộng khác nhau trên các
Tuy nhiên, kiến trúc lại làm phức tạp thêm tình hình một chút.  có
các chức năng nhằm trợ giúp trong những trường hợp đặc biệt như vậy ::

void debugfs_create_size_t(const char *name, chế độ umode_t,
			       cấu trúc nha khoa *parent, size_t *value);

Đúng như mong đợi, hàm này sẽ tạo một tệp debugfs để thể hiện
một biến kiểu size_t.

Tương tự, có các trợ giúp cho các biến có kiểu không dấu dài, ở dạng thập phân
và thập lục phân::

cấu trúc nha khoa *debugfs_create_ulong(const char *name, chế độ umode_t,
					cấu trúc nha khoa *cha mẹ,
					giá trị * dài không dấu);
    void debugfs_create_xul(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *parent, unsigned long *value);

Các giá trị Boolean có thể được đặt trong debugfs với::

void debugfs_create_bool(const char *name, chế độ umode_t,
                             cấu trúc nha khoa *parent, bool *value);

Việc đọc trên tệp kết quả sẽ mang lại Y (đối với các giá trị khác 0) hoặc
N, theo sau là một dòng mới.  Nếu được viết vào, nó sẽ chấp nhận chữ hoa hoặc chữ
giá trị chữ thường hoặc 1 hoặc 0. Mọi đầu vào khác sẽ bị bỏ qua âm thầm.

Ngoài ra, các giá trị Atomic_t có thể được đặt trong debugfs với::

void debugfs_create_atomic_t(const char *name, chế độ umode_t,
				 cấu trúc nha khoa *parent, atomic_t *value)

Việc đọc tệp này sẽ nhận được các giá trị Atomic_t và ghi tệp này
sẽ đặt giá trị Atomic_t.

Một tùy chọn khác là xuất một khối dữ liệu nhị phân tùy ý, với
cấu trúc và chức năng này::

cấu trúc debugfs_blob_wrapper {
	void *dữ liệu;
	kích thước dài không dấu;
    };

cấu trúc nha khoa *debugfs_create_blob(const char *name, chế độ umode_t,
				       cấu trúc nha khoa *cha mẹ,
				       cấu trúc debugfs_blob_wrapper *blob);

Việc đọc tệp này sẽ trả về dữ liệu được chỉ ra bởi
cấu trúc debugfs_blob_wrapper.  Một số trình điều khiển sử dụng "blobs" như một cách đơn giản
để trả về một số dòng đầu ra văn bản được định dạng (tĩnh).  Chức năng này
có thể được sử dụng để xuất thông tin nhị phân, nhưng dường như không có
bất kỳ mã nào làm như vậy trong dòng chính.  Lưu ý rằng tất cả các tệp được tạo bằng
debugfs_create_blob() ở chế độ chỉ đọc.

Nếu bạn muốn kết xuất một khối thanh ghi (điều gì đó xảy ra khá
thường xuyên trong quá trình phát triển, ngay cả khi rất ít mã như vậy đạt đến dòng chính),
debugfs cung cấp hai chức năng: một để tạo tệp chỉ đăng ký và
một cái khác để chèn một khối thanh ghi vào giữa một khối tuần tự khác
tập tin::

cấu trúc debugfs_reg32 {
	char *tên;
	phần bù dài không dấu;
    };

cấu trúc debugfs_regset32 {
	const struct debugfs_reg32 *regs;
	int nreg;
	void __iomem *cơ sở;
	thiết bị cấu trúc ZZ0000ZZ Thiết bị tùy chọn cho Runtime PM */
    };

debugfs_create_regset32(const char *name, chế độ umode_t,
			    cấu trúc nha khoa *cha mẹ,
			    cấu trúc debugfs_regset32 *regset);

void debugfs_print_regs32(struct seq_file *s, const struct debugfs_reg32 *regs,
			 int nreg, void __iomem *base, char *prefix);

Đối số "cơ sở" có thể là 0, nhưng bạn có thể muốn xây dựng mảng reg32
sử dụng __stringify và một số tên đăng ký (macro) thực tế là
độ lệch byte trên cơ sở cho khối thanh ghi.

Nếu bạn muốn kết xuất một mảng u32 trong debugfs, bạn có thể tạo một tệp có ::

cấu trúc debugfs_u32_array {
	u32 *mảng;
	u32 n_elements;
    };

void debugfs_create_u32_array(const char *name, chế độ umode_t,
			cấu trúc nha khoa *cha mẹ,
			cấu trúc debugfs_u32_array *mảng);

Đối số "mảng" bao bọc một con trỏ tới dữ liệu của mảng và số
của các phần tử của nó. Lưu ý: Khi mảng được tạo, kích thước của mảng không thể thay đổi.

Có một chức năng trợ giúp để tạo seq_file liên quan đến thiết bị::

void debugfs_create_devm_seqfile(thiết bị cấu trúc *dev,
				const char * tên,
				cấu trúc nha khoa *cha mẹ,
				int (*read_fn)(struct seq_file *,
					void *dữ liệu));

Đối số "dev" là thiết bị liên quan đến tệp debugfs này và
"read_fn" là một con trỏ hàm được gọi để in
nội dung seq_file.

Có một số chức năng trợ giúp hướng thư mục khác::

cấu trúc nha khoa *debugfs_change_name(struct dentry *dentry,
					  const char *fmt, ...);

cấu trúc nha khoa *debugfs_create_symlink(const char *name,
                                          cấu trúc nha khoa *cha mẹ,
				      	  const char *đích);

Lệnh gọi debugfs_change_name() sẽ đặt tên mới cho các debugf hiện có
tập tin, luôn trong cùng một thư mục.  new_name không được tồn tại trước đó
đến cuộc gọi; giá trị trả về là 0 nếu thành công và -E... nếu thất bại.
Liên kết tượng trưng có thể được tạo bằng debugfs_create_symlink().

Có một điều quan trọng mà tất cả người dùng debugfs phải tính đến:
không có tính năng tự động dọn dẹp bất kỳ thư mục nào được tạo trong debugfs.  Nếu một
mô-đun được tải xuống mà không loại bỏ rõ ràng các mục debugfs, kết quả là
sẽ có rất nhiều gợi ý cũ kỹ và không có hồi kết về hành vi phản xã hội cao độ.
Vì vậy tất cả người dùng debugfs - ít nhất là những người có thể được xây dựng dưới dạng mô-đun - phải
hãy chuẩn bị xóa tất cả các tập tin và thư mục họ tạo ở đó.  Một tập tin
hoặc thư mục có thể được gỡ bỏ bằng::

void debugfs_remove(struct nha khoa *dentry);

Giá trị nha khoa có thể là NULL hoặc một giá trị lỗi, trong trường hợp đó sẽ không có gì xảy ra.
được gỡ bỏ.  Lưu ý rằng chức năng này sẽ loại bỏ đệ quy tất cả các tập tin và
các thư mục bên dưới nó.  Trước đây, debugfs_remove_recursive() đã được sử dụng
để thực hiện nhiệm vụ đó, nhưng chức năng này bây giờ chỉ là bí danh của
debugfs_remove().  debugfs_remove_recursive() nên được xem xét
không được dùng nữa.

.. [1] http://lwn.net/Articles/309298/