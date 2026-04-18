.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/files.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Quản lý tập tin trong nhân Linux
===================================

Tài liệu này mô tả cách khóa file (struct file)
và bảng mô tả tệp (tệp cấu trúc) hoạt động.

Cho đến phiên bản 2.6.12, bảng mô tả tệp đã được bảo vệ
bằng khóa (tệp->file_lock) và số tham chiếu (tệp->đếm).
->file_lock bảo vệ quyền truy cập vào tất cả các trường liên quan đến tệp
của cái bàn. ->count đã được sử dụng để chia sẻ bộ mô tả tập tin
bảng giữa các tác vụ được sao chép bằng cờ CLONE_FILES. Thông thường
đây sẽ là trường hợp của các chủ đề posix. Như với cái chung
mô hình đếm lại trong kernel, nhiệm vụ cuối cùng thực hiện
put_files_struct() giải phóng bảng mô tả tệp (fd).
Bản thân các tệp (tệp cấu trúc) được bảo vệ bằng cách sử dụng
số tham chiếu (->f_count).

Trong mô hình quản lý bộ mô tả tệp không khóa mới,
việc đếm tham chiếu là tương tự, nhưng việc khóa là
dựa trên RCU. Bảng mô tả tập tin chứa nhiều
các phần tử - bộ fd (open_fds và close_on_exec,
mảng con trỏ tệp, kích thước của tập hợp và mảng
v.v.). Để các bản cập nhật xuất hiện nguyên tử
một trình đọc không khóa, tất cả các thành phần của bộ mô tả tệp
bảng nằm trong một cấu trúc riêng biệt - struct fdtable.
files_struct chứa một con trỏ tới struct fdtable thông qua
mà bảng fd thực tế được truy cập. Ban đầu
fdtable được nhúng vào chính files_struct. Vào lần tiếp theo
mở rộng fdtable, một cấu trúc fdtable mới được phân bổ
và files->fdtab trỏ đến cấu trúc mới. bảng fdtable
cấu trúc được giải phóng với RCU và các đầu đọc không khóa
xem fdtable cũ hoặc fdtable mới thực hiện cập nhật
xuất hiện nguyên tử. Dưới đây là các quy tắc khóa cho
cấu trúc fdtable -

1. Tất cả các tham chiếu đến fdtable phải được thực hiện thông qua
   macro files_fdtable()::

cấu trúc fdtable *fdt;

rcu_read_lock();

fdt = files_fdtable(file);
	....
nếu (n <= fdt->max_fds)
		....
	...
rcu_read_unlock();

files_fdtable() sử dụng macro rcu_dereference() để xử lý
   các yêu cầu về rào cản bộ nhớ đối với việc hủy đăng ký không khóa.
   Con trỏ fdtable phải được đọc bên trong read-side
   phần quan trọng.

2. Việc đọc fdtable như mô tả ở trên phải được bảo vệ
   bởi rcu_read_lock()/rcu_read_unlock().

3. Đối với bất kỳ bản cập nhật nào cho bảng fd, files->file_lock phải
   được giữ lại.

4. Để tra cứu cấu trúc file cho trước một fd, reader
   phải sử dụng API lookup_fdget_rcu() hoặc files_lookup_fdget_rcu(). Những cái này
   quan tâm đến các yêu cầu về rào cản do tra cứu không khóa.

Một ví dụ::

tệp cấu trúc *tệp;

rcu_read_lock();
	tập tin = lookup_fdget_rcu(fd);
	rcu_read_unlock();
	nếu (tệp) {
		...
                fput(file);
	}
	....

5. Vì cả cấu trúc tệp và fdtable đều có thể được tra cứu
   không khóa, chúng phải được cài đặt bằng rcu_sign_pointer()
   API. Nếu chúng được tra cứu không khóa, rcu_dereference()
   phải được sử dụng. Tuy nhiên, nên sử dụng files_fdtable()
   và lookup_fdget_rcu()/files_lookup_fdget_rcu() sẽ xử lý những thứ này
   vấn đề.

6. Trong khi cập nhật, con trỏ fdtable phải được tra cứu trong khi
   đang giữ tập tin->file_lock. Nếu ->file_lock bị loại bỏ thì
   một luồng khác mở rộng các tập tin từ đó tạo ra một luồng mới
   fdtable và làm cho con trỏ fdtable trước đó trở nên cũ kỹ.

Ví dụ::

spin_lock(&files->file_lock);
	fd = định vị_fd(tệp, tệp, bắt đầu);
	nếu (fd >= 0) {
		/* định vị_fd() có thể đã mở rộng fdtable, hãy tải ptr */
		fdt = files_fdtable(file);
		__set_open_fd(fd, fdt);
		__clear_close_on_exec(fd, fdt);
		spin_unlock(&files->file_lock);
	.....

   Since locate_fd() can drop ->file_lock (and reacquire ->file_lock),
   the fdtable pointer (fdt) must be loaded after locate_fd().

Trên các hạt nhân mới hơn, việc tra cứu tệp dựa trên rcu đã được chuyển sang dựa vào
SLAB_TYPESAFE_BY_RCU thay vì call_rcu(). Nó không còn đủ nữa
để có được một tham chiếu đến tệp được đề cập trong rcu bằng cách sử dụng
Atomic_long_inc_not_zero() vì tệp có thể đã được
được tái chế và người khác có thể đã đánh cắp tài liệu tham khảo. Ở nơi khác
từ, người gọi có thể thấy số lượng tham chiếu tăng vọt từ những người dùng mới hơn. cho
đây là lý do cần phải xác minh rằng con trỏ giống nhau
trước và sau khi tăng số lượng tham chiếu. Có thể thấy mô hình này
trong get_file_rcu() và __files_get_rcu().

Ngoài ra, không thể truy cập hoặc kiểm tra các trường trong tệp cấu trúc
mà không cần lấy tham chiếu đầu tiên về nó khi tra cứu rcu. Không làm
điều đó luôn rất tinh vi và nó chỉ có thể sử dụng được cho dữ liệu không phải con trỏ
trong tập tin cấu trúc. Với SLAB_TYPESAFE_BY_RCU, người gọi cần
trước tiên hãy lấy tham chiếu hoặc họ phải giữ files_lock của
fdtable.