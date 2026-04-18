.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/caching/netfs-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Bộ nhớ đệm hệ thống tệp mạng API
==============================

Fscache cung cấp API mà hệ thống tệp mạng có thể sử dụng địa chỉ cục bộ
cơ sở lưu trữ bộ nhớ đệm.  API được bố trí theo một số nguyên tắc:

(1) Bộ đệm được tổ chức hợp lý thành các khối và đối tượng lưu trữ dữ liệu
     trong những tập đó.

(2) Các khối và đối tượng lưu trữ dữ liệu được thể hiện bằng nhiều loại
     bánh quy.

(3) Cookie có khóa để phân biệt chúng với các cookie ngang hàng.

(4) Cookie có dữ liệu mạch lạc cho phép bộ đệm xác định xem
     dữ liệu được lưu trong bộ nhớ cache vẫn hợp lệ.

(5) I/O được thực hiện không đồng bộ nếu có thể.

API này được sử dụng bởi::

#include <linux/fscache.h>.

.. This document contains the following sections:

	 (1) Overview
	 (2) Volume registration
	 (3) Data file registration
	 (4) Declaring a cookie to be in use
	 (5) Resizing a data file (truncation)
	 (6) Data I/O API
	 (7) Data file coherency
	 (8) Data file invalidation
	 (9) Write back resource management
	(10) Caching of local modifications
	(11) Page release and invalidation


Tổng quan
========

Hệ thống phân cấp fscache được tổ chức theo hai cấp độ từ hệ thống tệp mạng
quan điểm.  Cấp trên đại diện cho "khối lượng" và cấp dưới
đại diện cho "đối tượng lưu trữ dữ liệu".  Chúng được thể hiện bằng hai loại
cookie, sau đây gọi là "cookie khối lượng" và "cookie".

Hệ thống tệp mạng thu được cookie âm lượng cho một âm lượng bằng phím âm lượng,
đại diện cho tất cả thông tin xác định ổ đĩa đó (ví dụ: tên ô
hoặc địa chỉ máy chủ, ID ổ đĩa hoặc tên chia sẻ).  Điều này phải được hiển thị dưới dạng
chuỗi có thể in được có thể được sử dụng làm tên thư mục (ví dụ: không có ký tự '/'
và không nên bắt đầu bằng dấu '.').  Độ dài tên tối đa là một ít hơn độ dài tên
kích thước tối đa của thành phần tên tệp (cho phép bộ đệm phụ trợ một ký tự cho
mục đích riêng của nó).

Một hệ thống tập tin thường có cookie dung lượng cho mỗi siêu khối.

Sau đó, hệ thống tệp sẽ thu thập cookie cho mỗi tệp trong ổ đĩa đó bằng cách sử dụng
khóa đối tượng.  Khóa đối tượng là các đốm màu nhị phân và chỉ cần là duy nhất trong
khối lượng cha mẹ của họ.  Phần phụ trợ bộ đệm chịu trách nhiệm hiển thị nhị phân
blob vào thứ gì đó nó có thể sử dụng và có thể sử dụng bảng băm, cây hoặc bất cứ thứ gì để
cải thiện khả năng tìm thấy một đối tượng.  Điều này là minh bạch đối với mạng
hệ thống tập tin.

Một hệ thống tập tin thường có một cookie cho mỗi nút và sẽ lấy nó
trong iget và từ bỏ nó khi gỡ bỏ cookie.

Sau khi có cookie, hệ thống tệp cần đánh dấu cookie là đang được sử dụng.
Điều này khiến fscache gửi phần phụ trợ bộ đệm để tra cứu/tạo tài nguyên
đối với cookie ở chế độ nền, để kiểm tra tính mạch lạc của nó và, nếu cần, để
đánh dấu đối tượng đang được sửa đổi.

Một hệ thống tệp thường "sử dụng" cookie trong quy trình mở tệp của nó và
không sử dụng nó trong bản phát hành tệp và nó cần sử dụng cookie xung quanh các lệnh gọi tới
cắt bớt cookie cục bộ.  ZZ0000ZZ cần sử dụng cookie khi
pagecache trở nên bẩn và không sử dụng nó khi quá trình ghi lại hoàn tất.  Đây là
hơi phức tạp và đã có sẵn điều khoản cho việc đó.

Khi thực hiện đọc, ghi hoặc thay đổi kích thước trên cookie, trước tiên hệ thống tệp phải
bắt đầu một hoạt động.  Điều này sao chép các tài nguyên vào một cấu trúc đang lưu giữ và đặt
ghim thêm vào bộ nhớ đệm để ngăn việc rút bộ nhớ đệm khỏi làm hỏng
các cấu trúc đang được sử dụng.  Hoạt động thực tế sau đó có thể được ban hành và xung đột
sự vô hiệu có thể được phát hiện sau khi hoàn thành.

Hệ thống tập tin dự kiến sẽ sử dụng netfslib để truy cập bộ đệm, nhưng điều đó không phải
thực sự cần thiết và nó có thể sử dụng trực tiếp fscache I/O API.


Đăng ký khối lượng
===================

Bước đầu tiên đối với hệ thống tệp mạng là lấy cookie khối lượng cho
khối lượng nó muốn truy cập::

cấu trúc fscache_volume *
	fscache_acquire_volume(const char *volume_key,
			       const char *cache_name,
			       const void *coherency_data,
			       size_t mạch lạc_len);

Hàm này tạo cookie âm lượng với phím âm lượng được chỉ định làm tên của nó
và ghi lại dữ liệu mạch lạc.

Phím âm lượng phải là một chuỗi có thể in được và không có ký tự '/' trong đó.  Nó
phải bắt đầu bằng tên của hệ thống tập tin và không dài hơn 254
nhân vật.  Nó phải đại diện duy nhất cho âm lượng và sẽ khớp với
những gì được lưu trữ trong bộ đệm.

Người gọi cũng có thể chỉ định tên của bộ đệm sẽ sử dụng.  Nếu được chỉ định,
fscache sẽ tra cứu hoặc tạo cookie bộ đệm có tên đó và sẽ sử dụng bộ đệm
của tên đó nếu nó trực tuyến hoặc trực tuyến.  Nếu không có tên bộ đệm được chỉ định,
nó sẽ sử dụng bộ đệm đầu tiên có sẵn và đặt tên cho bộ nhớ đệm đó.

Dữ liệu mạch lạc được chỉ định sẽ được lưu trữ trong cookie và sẽ được so khớp
chống lại dữ liệu mạch lạc được lưu trữ trên đĩa.  Con trỏ dữ liệu có thể là NULL nếu không có dữ liệu
được cung cấp.  Nếu dữ liệu mạch lạc không khớp, toàn bộ khối lượng bộ đệm sẽ
bị vô hiệu.

Chức năng này có thể trả về các lỗi như EBUSY nếu phím âm lượng đã được bật
sử dụng bởi khối lượng thu được hoặc ENOMEM nếu xảy ra lỗi phân bổ.  Nó có thể
cũng trả về cookie khối lượng NULL nếu fscache không được bật.  Nó là an toàn để
chuyển cookie NULL cho bất kỳ chức năng nào sử dụng cookie khối lượng.  Điều này sẽ
khiến chức năng đó không làm gì cả.


Khi hệ thống tập tin mạng đã hoàn tất việc sử dụng một ổ đĩa, nó sẽ từ bỏ nó
bằng cách gọi::

void fscache_relinquish_volume(struct fscache_volume *volume,
				       const void *coherency_data,
				       bool vô hiệu);

Điều này sẽ làm cho tập đĩa bị cam kết hoặc bị loại bỏ, và nếu bị niêm phong thì
dữ liệu mạch lạc sẽ được đặt thành giá trị được cung cấp.  Lượng dữ liệu đồng bộ
phải phù hợp với độ dài được chỉ định khi thu được âm lượng.  Lưu ý rằng tất cả
cookie dữ liệu thu được trong tập này phải được hủy bỏ trước khi tập đó được
từ bỏ.


Đăng ký tệp dữ liệu
======================

Khi nó có cookie khối lượng, hệ thống tệp mạng có thể sử dụng nó để có được
cookie để lưu trữ dữ liệu::

cấu trúc fscache_cookie *
	fscache_acquire_cookie(struct fscache_volume *volume,
			       lời khuyên của u8,
			       const void *index_key,
			       kích thước_t chỉ mục_key_len,
			       const void *aux_data,
			       size_t aux_data_len,
			       loff_t object_size)

Điều này tạo ra cookie trong ổ đĩa bằng cách sử dụng khóa chỉ mục được chỉ định.  chỉ số
khóa là một đốm màu nhị phân có độ dài nhất định và phải là duy nhất cho ổ đĩa.
Điều này được lưu vào cookie.  Không có hạn chế về nội dung, nhưng
độ dài của nó không được vượt quá khoảng 3/4 độ dài tối đa của tên tệp
để cho phép mã hóa.

Người gọi cũng phải chuyển một phần dữ liệu mạch lạc trong aux_data.  Một bộ đệm
có kích thước aux_data_len sẽ được phân bổ và dữ liệu kết hợp được sao chép vào. Đó là
cho rằng kích thước không đổi theo thời gian.  Dữ liệu mạch lạc được sử dụng để
kiểm tra tính hợp lệ của dữ liệu trong bộ đệm.  Các chức năng được cung cấp theo đó
dữ liệu mạch lạc có thể được cập nhật.

Kích thước tệp của đối tượng đang được lưu vào bộ nhớ đệm cũng phải được cung cấp.  Đây có thể là
được sử dụng để cắt bớt dữ liệu và sẽ được lưu trữ cùng với dữ liệu mạch lạc.

Hàm này không bao giờ trả về lỗi, mặc dù nó có thể trả về cookie NULL trên
lỗi phân bổ hoặc nếu fscache không được kích hoạt.  Vượt qua NULL là an toàn
cookie khối lượng và chuyển cookie NULL được trả về cho bất kỳ chức năng nào sử dụng nó.
Điều này sẽ khiến chức năng đó không làm gì cả.


Khi hệ thống tập tin mạng đã hoàn tất việc sử dụng cookie, nó sẽ từ bỏ nó
bằng cách gọi::

void fscache_relinquish_cookie(struct fscache_cookie *cookie,
				       bool nghỉ hưu);

Điều này sẽ khiến fscache cam kết lưu trữ sao lưu cookie hoặc
xóa nó.


Đánh dấu một cookie đang được sử dụng
=======================

Khi cookie đã được hệ thống tệp mạng thu được, hệ thống tệp sẽ
báo cho fscache biết khi nào nó có ý định sử dụng cookie (thường được thực hiện khi mở tệp)
và sẽ nói khi nào nó kết thúc (thường là khi đóng tệp)::

void fscache_use_cookie(struct fscache_cookie *cookie,
				bool will_modify);
	void fscache_unuse_cookie(struct fscache_cookie *cookie,
				  const void *aux_data,
				  const loff_t *object_size);

Hàm ZZ0000ZZ cho fscache biết rằng nó sẽ sử dụng cookie và ngoài ra,
cho biết liệu người dùng có ý định sửa đổi nội dung cục bộ hay không.  Nếu chưa
xong, việc này sẽ kích hoạt phần phụ trợ bộ đệm hoạt động và thu thập các tài nguyên mà nó
cần truy cập/lưu trữ dữ liệu trong bộ đệm.  Việc này được thực hiện ở chế độ nền và
vì vậy có thể không hoàn thành vào thời điểm hàm trả về.

Hàm ZZ0000ZZ cho biết hệ thống tệp đã hoàn tất việc sử dụng cookie.
Nó tùy chọn cập nhật dữ liệu mạch lạc được lưu trữ và kích thước đối tượng, sau đó
giảm bộ đếm đang sử dụng.  Khi người dùng cuối cùng không sử dụng cookie, đó là
đã lên lịch thu gom rác.  Nếu không được tái sử dụng trong thời gian ngắn,
tài nguyên sẽ được giải phóng để giảm mức tiêu thụ tài nguyên hệ thống.

Cookie phải được đánh dấu là đang sử dụng trước khi có thể truy cập để đọc, ghi hoặc
thay đổi kích thước - và phải giữ lại dấu đang sử dụng trong khi có dữ liệu bẩn trong
pagecache để tránh lỗi do cố mở tệp trong quá trình
thoát ra.

Lưu ý rằng điểm đang sử dụng sẽ được tích lũy.  Mỗi lần cookie được đánh dấu
đang sử dụng, nó phải không được sử dụng.


Thay đổi kích thước tệp dữ liệu (cắt ngắn)
=================================

Nếu tệp hệ thống tệp mạng được thay đổi kích thước cục bộ bằng cách cắt bớt, thì như sau
nên được gọi để thông báo bộ đệm::

void fscache_resize_cookie(struct fscache_cookie *cookie,
				   loff_t new_size);

Người gọi trước tiên phải đánh dấu cookie đang được sử dụng.  Bánh quy và cái mới
size được chuyển vào và bộ đệm được thay đổi kích thước đồng bộ.  Điều này dự kiến sẽ
được gọi từ hoạt động inode ZZ0000ZZ dưới khóa inode.


Dữ liệu vào/ra API
============

Để thực hiện các thao tác I/O dữ liệu trực tiếp thông qua cookie, các chức năng sau
có sẵn::

int fscache_begin_read_Operation(struct netfs_cache_resources *cres,
					 cấu trúc fscache_cookie *cookie);
	int fscache_read(struct netfs_cache_resources *cres,
			 loff_t bắt đầu_pos,
			 cấu trúc iov_iter *iter,
			 enum netfs_read_from_hole read_hole,
			 netfs_io_terminated_t term_func,
			 void *term_func_priv);
	int fscache_write(struct netfs_cache_resources *cres,
			  loff_t bắt đầu_pos,
			  cấu trúc iov_iter *iter,
			  netfs_io_terminated_t term_func,
			  void *term_func_priv);

Hàm ZZ0000ZZ thiết lập một thao tác, gắn các tài nguyên cần thiết vào
khối tài nguyên bộ nhớ đệm khỏi cookie.  Giả sử nó không trả về lỗi
(ví dụ: nó sẽ trả về -ENOBUFS nếu được cung cấp cookie NULL, nhưng nếu không thì sẽ trả về
không có gì), thì một trong hai chức năng còn lại có thể được ban hành.

Các chức năng ZZ0000ZZ và ZZ0001ZZ khởi tạo hoạt động IO trực tiếp.  Cả hai đều lấy
khối tài nguyên bộ đệm được thiết lập trước đó, một dấu hiệu của tệp bắt đầu
vị trí và một trình vòng lặp I/O mô tả bộ đệm và cho biết số lượng
dữ liệu.

Hàm đọc cũng nhận một tham số để chỉ ra cách xử lý một
vùng dân cư một phần (một lỗ) trong nội dung đĩa.  Điều này có thể bị bỏ qua
nó, bỏ qua lỗ ban đầu và đặt số 0 vào bộ đệm hoặc báo lỗi.

Các chức năng đọc và ghi có thể được cung cấp một chức năng kết thúc tùy chọn
sẽ được chạy khi hoàn thành::

typedef
	void (*netfs_io_terminated_t)(void *priv, ssize_t đã chuyển_or_error,
				      bool was_async);

Nếu chức năng kết thúc được đưa ra, thao tác sẽ được chạy không đồng bộ
và chức năng chấm dứt sẽ được gọi sau khi hoàn thành.  Nếu không được đưa ra,
hoạt động sẽ được chạy đồng bộ.  Lưu ý rằng trong trường hợp không đồng bộ, đó là
có thể thực hiện thao tác hoàn tất trước khi hàm trả về.

Cả hai chức năng đọc và ghi đều kết thúc thao tác khi chúng hoàn thành,
tách bất kỳ tài nguyên được ghim.

Hoạt động đọc sẽ thất bại với ESTALE nếu xảy ra hiện tượng vô hiệu trong khi
hoạt động đang diễn ra.


Sự mạch lạc của tệp dữ liệu
===================

Để yêu cầu cập nhật dữ liệu mạch lạc và kích thước tệp trên cookie,
sau đây nên được gọi::

void fscache_update_cookie(struct fscache_cookie *cookie,
				   const void *aux_data,
				   const loff_t *object_size);

Điều này sẽ cập nhật dữ liệu mạch lạc và/hoặc kích thước tệp của cookie.


Vô hiệu hóa tệp dữ liệu
======================

Đôi khi cần phải vô hiệu hóa một đối tượng chứa dữ liệu.
Thông thường, điều này sẽ cần thiết khi máy chủ thông báo hệ thống tệp mạng
về sự thay đổi từ xa của bên thứ ba - tại thời điểm đó hệ thống tập tin phải gửi
loại bỏ trạng thái và dữ liệu được lưu trong bộ nhớ cache mà nó có cho một tệp và tải lại từ
máy chủ.

Để chỉ ra rằng một đối tượng bộ nhớ đệm sẽ bị vô hiệu hóa, bạn nên làm như sau:
được gọi là::

void fscache_invalidate(struct fscache_cookie *cookie,
				const void *aux_data,
				kích thước loff_t,
				cờ int không dấu);

Điều này làm tăng bộ đếm vô hiệu trong cookie gây ra lỗi chưa xử lý
đọc không thành công với -ESTALE, đặt dữ liệu mạch lạc và kích thước tệp từ
thông tin được cung cấp, chặn I/O mới trên cookie và gửi bộ đệm tới
đi và loại bỏ dữ liệu cũ.

Sự vô hiệu hóa chạy không đồng bộ trong một luồng công việc để nó không bị chặn
quá nhiều.


Quản lý tài nguyên ghi lại
==============================

Để ghi dữ liệu vào bộ đệm từ quá trình ghi lại hệ thống tệp mạng, bộ đệm
các tài nguyên cần thiết cần phải được ghim tại thời điểm sửa đổi được thực hiện (đối với
dụ khi trang bị đánh dấu bẩn) vì không thể mở tệp ở
một chủ đề đang thoát.

Các cơ sở sau đây được cung cấp để quản lý việc này:

* Cờ inode, ZZ0000ZZ, được cung cấp để chỉ ra rằng
   việc sử dụng được giữ lại trên cookie cho nút này.  Nó chỉ có thể được thay đổi nếu
   khóa inode được giữ.

* Một lá cờ, ZZ0000ZZ được đặt trong ZZ0001ZZ
   cấu trúc được thiết lập nếu ZZ0002ZZ xóa
   ZZ0003ZZ vì tất cả các trang bẩn đã được xóa.

Để hỗ trợ điều này, các chức năng sau được cung cấp ::

bool fscache_dirty_folio(struct address_space *mapping,
				 struct folio *folio,
				 cấu trúc fscache_cookie *cookie);
	void fscache_unpin_writeback(struct writeback_control *wbc,
				     cấu trúc fscache_cookie *cookie);
	void fscache_clear_inode_writeback(struct fscache_cookie *cookie,
					   cấu trúc inode * inode,
					   const void *aux);

Hàm ZZ0003ZZ được dự định sẽ được gọi từ hệ thống tập tin
Hoạt động không gian địa chỉ ZZ0000ZZ.  Nếu ZZ0001ZZ không
được đặt, nó sẽ đặt cờ đó và tăng số lần sử dụng trên cookie (người gọi
phải đã gọi ZZ0002ZZ).

Hàm ZZ0001ZZ được dự định sẽ được gọi từ hệ thống tập tin
Hoạt động siêu khối ZZ0000ZZ.  Nó dọn dẹp sau khi viết bằng cách không sử dụng
cookie nếu unpinned_fscache_wb được đặt trong cấu trúc writeback_control.

Hàm ZZ0004ZZ được dự định sẽ được gọi từ ZZ0000ZZ của netfs
hoạt động siêu khối.  Nó phải được gọi là ZZ0005ZZ
ZZ0001ZZ, nhưng ZZ0006ZZ ZZ0002ZZ.  Điều này làm sạch
treo bất kỳ ZZ0003ZZ nào.  Nó cũng cho phép dữ liệu mạch lạc
được cập nhật.


Bộ nhớ đệm các sửa đổi cục bộ
==============================

Nếu một hệ thống tập tin mạng có dữ liệu được sửa đổi cục bộ mà nó muốn ghi vào
cache, nó cần đánh dấu các trang để cho biết rằng quá trình ghi đang được tiến hành và
nếu nhãn hiệu đã có sẵn thì trước tiên nó cần phải đợi nhãn hiệu đó được xóa đi
(có lẽ là do một hoạt động đang được tiến hành).  Điều này ngăn chặn nhiều
DIO cạnh tranh ghi vào cùng một bộ lưu trữ trong bộ đệm.

Đầu tiên, netfs nên xác định xem bộ nhớ đệm có khả dụng hay không bằng cách thực hiện một số thao tác
thích::

bộ nhớ đệm bool = fscache_cookie_enabled(cookie);

Nếu muốn thử lưu vào bộ đệm, các trang sẽ được đợi và sau đó được đánh dấu bằng cách sử dụng
các chức năng sau được cung cấp bởi thư viện trợ giúp netfs ::

void set_page_fscache(struct page *page);
	void wait_on_page_fscache(trang cấu trúc *trang);
	int wait_on_page_fscache_killable(trang cấu trúc *trang);

Khi tất cả các trang trong span được đánh dấu, netfs có thể yêu cầu fscache
lên lịch viết cho khu vực đó::

void fscache_write_to_cache(struct fscache_cookie *cookie,
				    struct address_space *ánh xạ,
				    loff_t bắt đầu, size_t len, loff_t i_size,
				    netfs_io_terminated_t term_func,
				    vô hiệu *term_func_priv,
				    bộ nhớ đệm bool)

Và nếu xảy ra lỗi trước khi đạt đến điểm đó, điểm có thể bị xóa
bằng cách gọi::

void fscache_clear_page_bits(struct address_space *mapping,
				     bắt đầu loff_t, size_t len,
				     bộ nhớ đệm bool)

Trong các hàm này, một con trỏ tới ánh xạ tới các trang nguồn
đính kèm được chuyển vào và bắt đầu và len cho biết kích thước của vùng đó
sẽ được viết (không nhất thiết phải căn chỉnh theo ranh giới trang,
nhưng nó phải căn chỉnh theo ranh giới DIO trên hệ thống tệp sao lưu).  các
tham số bộ nhớ đệm cho biết có nên bỏ qua bộ nhớ đệm hay không và nếu sai thì
chức năng không làm gì cả.

Hàm ghi có một số tham số bổ sung: cookie đại diện cho
đối tượng bộ đệm được ghi vào, i_size cho biết kích thước của tệp netfs
và term_func biểu thị chức năng hoàn thành tùy chọn, theo đó
term_func_priv sẽ được chuyển cùng với lỗi hoặc số tiền được ghi.

Lưu ý rằng chức năng ghi sẽ luôn chạy không đồng bộ và sẽ bỏ đánh dấu tất cả
các trang sau khi hoàn thành trước khi gọi term_func.


Phát hành và vô hiệu hóa trang
=============================

Fscache theo dõi xem chúng tôi có bất kỳ dữ liệu nào trong bộ đệm cho bộ đệm hay không
đối tượng chúng ta vừa tạo.  Nó biết nó không cần phải thực hiện bất kỳ việc đọc nào cho đến khi nó
đã thực hiện viết và sau đó trang viết từ đó đã được VM phát hành,
sau đó dùng ZZ0000ZZ để tìm trong bộ đệm.

Để thông báo cho fscache rằng một trang hiện có thể nằm trong bộ đệm, hàm sau
nên được gọi từ không gian địa chỉ ZZ0000ZZ op::

void fscache_note_page_release(struct fscache_cookie *cookie);

nếu trang đã được phát hành (tức là Release_folio trả về true).

Việc phát hành trang và vô hiệu hóa trang cũng phải đợi bất kỳ dấu hiệu nào còn sót lại trên
trang để nói rằng quá trình viết DIO đang được tiến hành từ trang đó::

void wait_on_page_fscache(trang cấu trúc *trang);
	int wait_on_page_fscache_killable(trang cấu trúc *trang);


Tham khảo chức năng API
======================

.. kernel-doc:: include/linux/fscache.h