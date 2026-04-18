.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/caching/backend-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Phần cuối bộ đệm API
=================

Hệ thống FS-Cache cung cấp API để có thể cung cấp bộ đệm thực tế cho
FS-Cache để nó sau đó phân phát tới các hệ thống tệp mạng và các hệ thống quan tâm khác
các bữa tiệc.  API này được sử dụng bởi::

#include <linux/fscache-cache.h>.


Tổng quan
========

Tương tác với API được xử lý ở ba cấp độ: bộ đệm, âm lượng và dữ liệu
lưu trữ và mỗi cấp độ có loại đối tượng cookie riêng:

=================================================
	COOKIE C TYPE
	=================================================
	Cấu trúc cookie bộ đệm fscache_cache
	Cấu trúc cookie khối lượng fscache_volume
	Cấu trúc cookie lưu trữ dữ liệu fscache_cookie
	=================================================

Cookie được sử dụng để cung cấp một số dữ liệu hệ thống tệp vào bộ đệm, quản lý trạng thái và
ghim bộ đệm trong quá trình truy cập ngoài việc đóng vai trò là điểm tham chiếu cho
Chức năng API.  Mỗi cookie có một ID gỡ lỗi được bao gồm trong các điểm theo dõi
để dễ dàng liên kết các dấu vết hơn.  Tuy nhiên, xin lưu ý rằng ID gỡ lỗi là
được phân bổ đơn giản từ các bộ đếm tăng dần và cuối cùng sẽ bao bọc.

Phần phụ trợ bộ đệm và hệ thống tệp mạng đều có thể yêu cầu cookie bộ đệm -
và nếu họ yêu cầu một cái có cùng tên, họ sẽ nhận được cùng một chiếc bánh quy.  khối lượng
tuy nhiên, cookie dữ liệu chỉ được tạo theo lệnh của hệ thống tệp.


Cookie bộ nhớ đệm
=============

Bộ đệm được thể hiện trong API bằng cookie bộ đệm.  Đây là những đối tượng của
loại::

cấu trúc fscache_cache {
		void *cache_priv;
		unsigned int debug_id;
		char *tên;
		...
	};

Có một số trường mà phần phụ trợ bộ đệm có thể quan tâm.
ZZ0000ZZ có thể được sử dụng để dò tìm các dòng đề cập đến cùng một bộ đệm
và ZZ0001ZZ là tên mà bộ đệm đã được đăng ký.  ZZ0002ZZ
thành viên là dữ liệu riêng tư được cung cấp bởi bộ nhớ đệm khi nó được đưa lên mạng.  các
các lĩnh vực khác là để sử dụng nội bộ.


Đăng ký bộ đệm
===================

Khi một chương trình phụ trợ bộ đệm muốn đưa bộ đệm trực tuyến, trước tiên nó phải đăng ký
tên bộ nhớ đệm và điều đó sẽ tạo cho nó một cookie bộ nhớ đệm.  Điều này được thực hiện với::

cấu trúc fscache_cache *fscache_acquire_cache(const char *name);

Điều này sẽ tra cứu và có khả năng tạo cookie bộ đệm.  Cookie bộ nhớ đệm có thể
đã được tạo bởi hệ thống tập tin mạng đang tìm kiếm nó, trong trường hợp đó
cookie bộ đệm đó sẽ được sử dụng.  Nếu cookie bộ đệm không được người khác sử dụng
cache, nó sẽ được chuyển sang trạng thái chuẩn bị, nếu không nó sẽ quay trở lại
bận rộn.

Nếu thành công, phần phụ trợ bộ đệm có thể bắt đầu thiết lập bộ đệm.  trong
trường hợp quá trình khởi tạo không thành công, phần phụ trợ bộ nhớ đệm sẽ gọi::

void fscache_relinquish_cache(struct fscache_cache *cache);

để đặt lại và loại bỏ cookie.


Đưa bộ đệm trực tuyến
=======================

Sau khi thiết lập bộ đệm, nó có thể được đưa trực tuyến bằng cách gọi ::

int fscache_add_cache(struct fscache_cache *cache,
			      const struct fscache_cache_ops *ops,
			      void *cache_priv);

Điều này lưu trữ con trỏ bảng hoạt động bộ đệm và dữ liệu riêng tư của bộ đệm vào
cookie bộ đệm và chuyển bộ đệm sang trạng thái hoạt động, từ đó cho phép truy cập
diễn ra.


Rút bộ đệm khỏi dịch vụ
================================

Phần phụ trợ bộ đệm có thể rút bộ đệm khỏi dịch vụ bằng cách gọi hàm này ::

void fscache_withdraw_cache(struct fscache_cache *cache);

Thao tác này sẽ chuyển bộ nhớ đệm sang trạng thái đã rút để ngăn bộ nhớ đệm mới- và
truy cập cấp âm lượng từ khi bắt đầu và sau đó chờ cấp độ bộ đệm vượt trội
truy cập để hoàn thành.

Bộ đệm sau đó phải đi qua các đối tượng lưu trữ dữ liệu mà nó có và thông báo cho fscache
để rút chúng, gọi::

void fscache_withdraw_cookie(struct fscache_cookie *cookie);

trên cookie mà mỗi đối tượng thuộc về.  Điều này lên lịch cho cookie được chỉ định
để rút tiền.  Điều này được giảm tải vào một hàng làm việc.  Phần phụ trợ bộ đệm có thể
chờ hoàn thành bằng cách gọi::

void fscache_wait_for_objects(struct fscache_cache *cache);

Sau khi tất cả cookie được rút, phần phụ trợ bộ đệm có thể rút tất cả
khối lượng, gọi::

void fscache_withdraw_volume(struct fscache_volume *volume);

để thông báo cho fscache rằng một tập đĩa đã bị rút.  Điều này chờ đợi tất cả
các truy cập còn tồn đọng trên ổ đĩa phải hoàn thành trước khi quay trở lại.

Khi bộ đệm được rút hoàn toàn, fscache sẽ được thông báo bởi
đang gọi::

void fscache_relinquish_cache(struct fscache_cache *cache);

để xóa các trường trong cookie và loại bỏ tham chiếu của người gọi trên đó.


Cookie khối lượng
==============

Trong bộ đệm, các đối tượng lưu trữ dữ liệu được tổ chức thành các khối logic.
Chúng được thể hiện trong API dưới dạng các đối tượng thuộc loại::

cấu trúc fscache_volume {
		struct fscache_cache *cache;
		void *cache_priv;
		unsigned int debug_id;
		phím char *;
		unsigned int key_hash;
		...
u8 mạch lạc_len;
		tính kết hợp u8[];
	};

Có một số trường ở đây được phụ trợ bộ nhớ đệm quan tâm:

* ZZ0000ZZ - Cookie bộ đệm gốc.

* ZZ0000ZZ - Nơi dành cho bộ đệm để lưu trữ dữ liệu riêng tư.

* ZZ0000ZZ - ID gỡ lỗi để đăng nhập các điểm theo dõi.

* ZZ0000ZZ - Một chuỗi có thể in được không có ký tự '/' trong đó đại diện cho
     phím chỉ mục cho âm lượng.  Khóa được kết thúc bằng NUL và được đệm vào
     bội số của 4 byte.

* ZZ0000ZZ - Hàm băm của khóa chỉ mục.  Việc này sẽ diễn ra giống nhau, không
     vấn đề về vòm cpu và độ bền.

* ZZ0000ZZ - Một phần dữ liệu mạch lạc cần được kiểm tra khi
     âm lượng được liên kết trong bộ đệm.

* ZZ0000ZZ - Lượng dữ liệu trong bộ đệm kết hợp.


Cookie lưu trữ dữ liệu
====================

Ổ đĩa là một nhóm logic các đối tượng lưu trữ dữ liệu, mỗi đối tượng được
được đại diện cho hệ thống tập tin mạng bằng một cookie.  Cookie được thể hiện trong
API là đối tượng thuộc loại::

cấu trúc fscache_cookie {
		struct fscache_volume *volume;
		void *cache_priv;
		cờ dài không dấu;
		unsigned int debug_id;
		int unsign inval_counter;
		loff_t object_size;
		lời khuyên của u8;
		u32 key_hash;
		u8 key_len;
		u8 aux_len;
		...
	};

Các trường trong cookie được phần phụ trợ bộ nhớ đệm quan tâm là:

* ZZ0000ZZ - Cookie khối lượng gốc.

* ZZ0000ZZ - Nơi dành cho bộ đệm để lưu trữ dữ liệu riêng tư.

* ZZ0000ZZ - Tập hợp các cờ bit, bao gồm:

* FSCACHE_COOKIE_NO_DATA_TO_READ - Không có sẵn dữ liệu trong
	cache được đọc khi cookie đã được tạo hoặc vô hiệu hóa.

* FSCACHE_COOKIE_NEEDS_UPDATE - Dữ liệu mạch lạc và/hoặc kích thước đối tượng có
	đã được thay đổi và cần phải cam kết.

* FSCACHE_COOKIE_LOCAL_WRITE - Dữ liệu của netfs đã được sửa đổi
	cục bộ, do đó đối tượng bộ đệm có thể ở trạng thái không mạch lạc
	đến máy chủ.

* FSCACHE_COOKIE_HAVE_DATA - Phần phụ trợ nên đặt cái này nếu nó
	lưu trữ thành công dữ liệu vào bộ đệm.

* FSCACHE_COOKIE_RETIRED - Cookie bị vô hiệu khi nó được sử dụng
	từ bỏ và dữ liệu được lưu trong bộ nhớ cache sẽ bị loại bỏ.

* ZZ0000ZZ - ID gỡ lỗi để đăng nhập các điểm theo dõi.

* ZZ0000ZZ - Số lần vô hiệu được thực hiện trên cookie.

* ZZ0000ZZ - Thông tin về cách sử dụng cookie.

* ZZ0000ZZ - Hàm băm của khóa chỉ mục.  Việc này sẽ diễn ra giống nhau, không
     vấn đề về vòm cpu và độ bền.

* ZZ0000ZZ - Độ dài của khóa chỉ mục.

* ZZ0000ZZ - Độ dài của bộ đệm dữ liệu mạch lạc.

Mỗi cookie có một khóa chỉ mục, khóa này có thể được lưu trữ nội tuyến trong cookie hoặc
ở nơi khác.  Một con trỏ tới đây có thể được lấy bằng cách gọi::

vô hiệu *fscache_get_key(struct fscache_cookie *cookie);

Khóa chỉ mục là một đốm màu nhị phân, bộ nhớ của nó được đệm vào một
bội số của 4 byte.

Mỗi cookie cũng có một bộ đệm cho dữ liệu mạch lạc.  Điều này cũng có thể là nội tuyến hoặc
được tách khỏi cookie và lấy được con trỏ bằng cách gọi ::

vô hiệu *fscache_get_aux(struct fscache_cookie *cookie);



Kế toán cookie
=================

Cookie lưu trữ dữ liệu được tính và điều này được sử dụng để chặn việc rút bộ đệm
hoàn thành cho đến khi tất cả các đối tượng đã bị phá hủy.  Các chức năng sau đây là
được cung cấp vào bộ đệm để giải quyết vấn đề đó::

void fscache_count_object(struct fscache_cache *cache);
	void fscache_uncount_object(struct fscache_cache *cache);
	void fscache_wait_for_objects(struct fscache_cache *cache);

Hàm đếm ghi lại sự phân bổ của một đối tượng trong bộ đệm và
hàm uncount ghi lại sự phá hủy của nó.  Cảnh báo: vào thời điểm đếm
hàm trả về, bộ đệm có thể đã bị hủy.

Chức năng chờ có thể được sử dụng trong quá trình rút tiền để chờ
fscache để hoàn tất việc rút tất cả các đối tượng trong bộ đệm.  Khi nó hoàn thành,
sẽ không còn đối tượng nào đề cập đến đối tượng bộ đệm hoặc bất kỳ ổ đĩa nào
đồ vật.


Quản lý bộ đệm API
====================

Phần phụ trợ bộ đệm thực hiện quản lý bộ đệm API bằng cách cung cấp một bảng
các hoạt động mà fscache có thể sử dụng để quản lý các khía cạnh khác nhau của bộ đệm.  Những cái này
được tổ chức trong một cấu trúc kiểu::

cấu trúc fscache_cache_ops {
		const char *tên;
		...
	};

Nó chứa tên có thể in được của trình điều khiển phụ trợ bộ nhớ đệm cùng với một số
con trỏ tới các phương thức cho phép fscache yêu cầu quản lý bộ đệm:

* Thiết lập cookie khối lượng [tùy chọn]::

khoảng trống (*acquire_volume)(struct fscache_volume *volume);

Phương thức này được gọi khi một khối lượng cookie đang được tạo.  người gọi
     giữ mã pin truy cập cấp bộ nhớ đệm để ngăn không cho bộ nhớ đệm biến mất trong
     thời lượng.  Phương pháp này sẽ thiết lập tài nguyên để truy cập vào một ổ đĩa
     trong bộ đệm và sẽ không quay trở lại cho đến khi hoàn thành việc đó.

Nếu thành công, nó có thể đặt ZZ0000ZZ thành dữ liệu của chính nó.


* Dọn dẹp cookie khối lượng [tùy chọn]::

khoảng trống (*free_volume)(struct fscache_volume *volume);

Phương thức này được gọi khi một tập cookie được phát hành nếu
     ZZ0000ZZ được thiết lập.


* Tra cứu cookie trong cache [bắt buộc]::

bool (*lookup_cookie)(struct fscache_cookie *cookie);

Phương thức này được gọi để tra cứu/tạo các tài nguyên cần thiết để truy cập
     lưu trữ dữ liệu cho một cookie.  Nó được gọi từ một luồng công nhân với một
     chốt truy cập mức âm lượng trong bộ đệm để ngăn không cho nó bị rút.

Đúng sẽ được trả về nếu thành công và sai nếu không.  Nếu sai là
     được trả về, lệnh rút_cookie (xem bên dưới) sẽ được gọi.

Nếu việc tra cứu không thành công nhưng đối tượng vẫn có thể được tạo (ví dụ: nó chưa
     đã được lưu vào bộ nhớ đệm trước đó), thì::

void fscache_cookie_lookup_ Negative(
			cấu trúc fscache_cookie *cookie);

có thể được gọi để cho phép hệ thống tập tin mạng tiến hành và bắt đầu tải xuống
     nội dung trong khi phần phụ trợ bộ nhớ đệm tiếp tục công việc tạo ra mọi thứ.

Nếu thành công, ZZ0000ZZ có thể được đặt.


* Rút một đối tượng mà không giữ bất kỳ quyền truy cập cookie nào [bắt buộc]::

khoảng trống (*withdraw_cookie)(struct fscache_cookie *cookie);

Phương thức này được gọi để rút cookie khỏi dịch vụ.  Nó sẽ là
     được gọi khi cookie bị netfs từ bỏ, bị rút hoặc loại bỏ
     bởi chương trình phụ trợ bộ đệm hoặc bị đóng sau một thời gian fscache không sử dụng.

Người gọi không giữ bất kỳ chân truy cập nào nhưng được gọi từ một
     mục công việc không được đăng ký lại để quản lý các cuộc đua giữa các cách khác nhau
     việc rút tiền có thể xảy ra.

Cookie sẽ có cờ ZZ0000ZZ được đặt trên đó nếu
     dữ liệu liên quan sẽ bị xóa khỏi bộ đệm.


* Thay đổi kích thước của đối tượng lưu trữ dữ liệu [bắt buộc]::

khoảng trống (*resize_cookie)(struct netfs_cache_resources *cres,
			      loff_t new_size);

Phương thức này được gọi để thông báo cho bộ đệm phụ trợ về sự thay đổi kích thước của
     tệp netfs do bị cắt bớt cục bộ.  Phần phụ trợ bộ đệm sẽ thực hiện tất cả
     về những thay đổi cần thực hiện trước khi quay trở lại vì việc này được thực hiện theo
     netfs inode mutex.

Người gọi giữ mã truy cập cấp cookie để ngăn cuộc đua với
     việc rút tiền và netfs phải đánh dấu cookie đang được sử dụng để ngăn chặn
     thu gom rác hoặc loại bỏ khỏi việc loại bỏ bất kỳ tài nguyên nào.


* Vô hiệu hóa đối tượng lưu trữ dữ liệu [bắt buộc]::

bool (*invalidate_cookie)(struct fscache_cookie *cookie);

Điều này được gọi khi hệ thống tập tin mạng phát hiện bên thứ ba
     sửa đổi hoặc khi việc ghi O_DIRECT được thực hiện cục bộ.  Yêu cầu này
     rằng phần phụ trợ bộ đệm sẽ loại bỏ tất cả dữ liệu trong bộ đệm cho
     đối tượng này và bắt đầu lại từ đầu.  Nó sẽ trả về true nếu thành công và
     sai nếu không.

Khi vào, các thao tác I/O mới bị chặn.  Khi bộ đệm ở vị trí
     để chấp nhận lại I/O, phần phụ trợ sẽ giải phóng khối bằng cách gọi ::

void fscache_resume_after_invalidation(struct fscache_cookie *cookie);

Nếu phương thức trả về sai, bộ nhớ đệm sẽ bị thu hồi đối với cookie này.


* Chuẩn bị thực hiện các sửa đổi cục bộ đối với bộ đệm [bắt buộc]::

khoảng trống (*prepare_to_write)(struct fscache_cookie *cookie);

Phương thức này được gọi khi hệ thống tập tin mạng thấy rằng nó đang hoạt động.
     cần sửa đổi nội dung của bộ đệm do ghi cục bộ hoặc
     sự cắt ngắn.  Điều này mang lại cho bộ đệm một cơ hội để lưu ý rằng một đối tượng bộ đệm
     có thể không mạch lạc với máy chủ và có thể cần viết lại
     sau này.  Điều này cũng có thể khiến dữ liệu được lưu trong bộ nhớ đệm bị loại bỏ sau này.
     cưỡng lại nếu không cam kết đúng cách.


* Bắt đầu hoạt động cho lib netfs [bắt buộc]::

bool (*begin_operation)(struct netfs_cache_resources *cres,
				enum fscache_want_state want_state);

Phương thức này được gọi khi một thao tác I/O đang được thiết lập (đọc, ghi
     hoặc thay đổi kích thước).  Người gọi giữ mã pin truy cập trên cookie và phải có
     đã đánh dấu cookie là đang sử dụng.

Nếu có thể, phần phụ trợ sẽ đính kèm mọi tài nguyên cần thiết để giữ lại
     tới đối tượng netfs_cache_resources và trả về true.

Nếu nó không thể hoàn tất quá trình thiết lập, nó sẽ trả về sai.

Tham số want_state cho biết trạng thái người gọi cần bộ đệm
     đối tượng sẽ ở trong đó và nó muốn làm gì trong quá trình hoạt động:

* ZZ0000ZZ - Người gọi chỉ muốn truy cập bộ đệm
	  tham số đối tượng; nó chưa cần thực hiện I/O dữ liệu.

* ZZ0000ZZ - Người gọi muốn đọc dữ liệu.

* ZZ0000ZZ - Người gọi muốn viết thư hoặc thay đổi kích thước
          đối tượng bộ đệm.

Lưu ý rằng không nhất thiết phải có bất cứ thứ gì gắn liền với cookie
     cache_priv nếu cookie vẫn đang được tạo.


Dữ liệu vào/ra API
============

Phần phụ trợ bộ đệm cung cấp I/O API dữ liệu thông qua ZZ0000ZZ của thư viện netfs được gắn vào ZZ0001ZZ bởi
Phương pháp ZZ0002ZZ được mô tả ở trên.

Xem Tài liệu/filesystems/netfs_library.rst để biết mô tả.


Chức năng khác
=======================

FS-Cache cung cấp một số tiện ích mà chương trình phụ trợ bộ đệm có thể sử dụng:

* Lưu ý khi xảy ra lỗi I/O trong bộ đệm::

void fscache_io_error(struct fscache_cache *cache);

Điều này cho FS-Cache biết rằng đã xảy ra lỗi I/O trong bộ đệm.  Cái này
     ngăn không cho bất kỳ I/O mới nào được khởi động trên bộ đệm.

Điều này không thực sự rút bộ đệm.  Việc đó phải được thực hiện riêng biệt.

* Lưu ý việc ngừng lưu vào bộ nhớ đệm trên cookie do lỗi::

void fscache_caching_failed(struct fscache_cookie *cookie);

Điều này lưu ý rằng việc lưu vào bộ nhớ đệm đang được thực hiện trên cookie không thành công trong
     bằng cách nào đó, chẳng hạn như bộ lưu trữ sao lưu không được tạo hoặc
     vô hiệu hóa không thành công và không có hoạt động I/O nào diễn ra nữa
     trên đó cho đến khi bộ đệm được thiết lập lại.

* Đếm số yêu cầu I/O::

void fscache_count_read(void);
	void fscache_count_write(void);

Bản ghi này đọc và ghi từ/vào bộ đệm.  Những con số là
     được hiển thị trong /proc/fs/fscache/stats.

* Đếm lỗi ngoài không gian::

void fscache_count_no_write_space(void);
	void fscache_count_no_create_space(void);

Những lỗi ENOSPC này ghi lại trong bộ đệm, được chia thành các lỗi dữ liệu
     ghi và lỗi khi tạo đối tượng hệ thống tập tin (ví dụ: mkdir).

* Đếm đối tượng bị tiêu hủy::

void fscache_count_culled(void);

Điều này ghi lại việc loại bỏ một đối tượng.

* Nhận cookie từ một bộ tài nguyên bộ nhớ đệm::

cấu trúc fscache_cookie *fscache_cres_cookie(struct netfs_cache_resources *cres)

Kéo con trỏ tới cookie từ tài nguyên bộ đệm.  Điều này có thể trả về một
     Cookie NULL nếu không có cookie nào được đặt.


Tham khảo chức năng API
======================

.. kernel-doc:: include/linux/fscache-cache.h