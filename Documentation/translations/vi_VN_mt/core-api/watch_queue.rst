.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/watch_queue.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Cơ chế thông báo chung
=================================

Cơ chế thông báo chung được xây dựng dựa trên trình điều khiển đường ống tiêu chuẩn
nhờ đó nó ghép các thông báo thông báo từ kernel vào các đường ống một cách hiệu quả
được mở bởi không gian người dùng.  Điều này có thể được sử dụng kết hợp với::

* Thông báo về phím/chìa khóa


Bộ đệm thông báo có thể được kích hoạt bằng cách:

"Thiết lập chung"/"Hàng đợi thông báo chung"
	(CONFIG_WATCH_QUEUE)

Tài liệu này có các phần sau:

.. contents:: :local:


Tổng quan
========

Cơ sở này xuất hiện dưới dạng một đường ống được mở ở chế độ đặc biệt.  Cái ống
bộ đệm vòng bên trong được sử dụng để chứa các thông báo được tạo bởi kernel.
Những tin nhắn này sau đó được đọc bởi read().  Mối nối và các tính năng tương tự bị vô hiệu hóa trên
những đường ống như vậy do họ muốn, trong một số trường hợp, hoàn nguyên
phần bổ sung cho chiếc nhẫn - có thể sẽ xen kẽ với thông báo
tin nhắn.

Chủ sở hữu của đường ống phải cho hạt nhân biết nguồn nào nó muốn
canh chừng qua đường ống đó.  Chỉ những nguồn đã được kết nối với đường ống mới có thể
chèn tin nhắn vào đó.  Lưu ý rằng một nguồn có thể được kết nối với nhiều đường ống và
chèn tin nhắn vào tất cả chúng cùng một lúc.

Các bộ lọc cũng có thể được đặt trên một đường ống sao cho một số loại nguồn và
các sự kiện phụ có thể bị bỏ qua nếu chúng không được quan tâm.

Một tin nhắn sẽ bị loại bỏ nếu không còn chỗ trống trong vòng hoặc nếu
không có bộ đệm tin nhắn được phân bổ trước.  Trong cả hai trường hợp này, read()
sẽ chèn thông báo WATCH_META_LOSS_NOTIFICATION vào bộ đệm đầu ra sau
tin nhắn cuối cùng hiện có trong bộ đệm đã được đọc.

Lưu ý rằng khi tạo thông báo, kernel không đợi
người tiêu dùng để thu thập nó, mà chỉ tiếp tục.  Điều này có nghĩa là
thông báo có thể được tạo trong khi khóa quay được giữ và cũng bảo vệ
kernel khỏi bị treo vô thời hạn do trục trặc về không gian người dùng.


Cấu trúc tin nhắn
=================

Tin nhắn thông báo bắt đầu bằng một tiêu đề ngắn::

cấu trúc watch_notification {
		__u32 loại:24;
		__u32 tiểu loại:8;
		__u32 thông tin;
	};

"loại" cho biết nguồn của bản ghi thông báo và "loại phụ" cho biết
loại bản ghi từ nguồn đó (xem phần Nguồn Xem bên dưới).  các
loại cũng có thể là "WATCH_TYPE_META".  Đây là loại bản ghi đặc biệt được tạo
nội bộ bởi chính hàng đợi theo dõi.  Có hai loại phụ:

* WATCH_META_REMOVAL_NOTIFICATION
  * WATCH_META_LOSS_NOTIFICATION

Dấu hiệu đầu tiên chỉ ra rằng vật thể gắn đồng hồ đã bị gỡ bỏ
hoặc bị phá hủy và thông báo thứ hai cho biết một số tin nhắn đã bị mất.

"thông tin" biểu thị nhiều thứ, bao gồm:

* Độ dài của tin nhắn tính bằng byte, bao gồm phần tiêu đề (mặt nạ có
    WATCH_INFO_LENGTH và dịch chuyển bằng WATCH_INFO_LENGTH__SHIFT).  Điều này cho thấy
    kích thước của bản ghi, có thể từ 8 đến 127 byte.

* ID đồng hồ (mặt nạ có WATCH_INFO_ID và shift bằng WATCH_INFO_ID__SHIFT).
    Điều này cho biết ID người gọi của đồng hồ, có thể nằm trong khoảng từ 0
    và 255. Nhiều đồng hồ có thể chia sẻ một hàng đợi và điều này cung cấp phương tiện để
    phân biệt chúng.

* Trường dành riêng cho loại (WATCH_INFO_TYPE_INFO).  Điều này được thiết lập bởi
    nhà sản xuất thông báo để chỉ ra một số ý nghĩa cụ thể đối với loại và
    tiểu loại.

Mọi thông tin ngoài độ dài đều có thể được sử dụng để lọc.

Tiêu đề có thể được theo sau bởi thông tin bổ sung.  Định dạng này là
theo quyết định được xác định bởi loại và loại phụ.


Danh sách theo dõi (Nguồn thông báo) API
====================================

"Danh sách theo dõi" là danh sách những người theo dõi đã đăng ký một nguồn
thông báo.  Một danh sách có thể được gắn vào một đối tượng (chẳng hạn như khóa hoặc siêu khối)
hoặc có thể mang tính toàn cầu (ví dụ như các sự kiện của thiết bị).  Từ góc độ không gian người dùng, một
danh sách theo dõi không toàn cầu thường được gọi bằng cách tham chiếu đến đối tượng mà nó
thuộc về (chẳng hạn như sử dụng KEYCTL_NOTIFY và cấp cho nó một số sê-ri chính cho
xem khóa cụ thể đó).

Để quản lý danh sách theo dõi, các chức năng sau được cung cấp:

  * ::

void init_watch_list(struct watch_list *wlist,
			     khoảng trống (*release_watch)(struct watch *wlist));

Khởi tạo một danh sách theo dõi.  Nếu ZZ0000ZZ không phải là NULL thì đây
    chỉ ra một hàm cần được gọi khi đối tượng watch_list được
    bị hủy để loại bỏ mọi tham chiếu mà danh sách theo dõi giữ trên đối tượng đã xem
    đối tượng.

* ZZ0000ZZ

Thao tác này sẽ xóa tất cả đồng hồ đã đăng ký vào watch_list và giải phóng chúng
    và sau đó phá hủy chính đối tượng watch_list.


Hàng đợi xem (Đầu ra thông báo) API
=====================================

"Hàng đợi theo dõi" là bộ đệm được phân bổ bởi ứng dụng thông báo
hồ sơ sẽ được ghi vào.  Hoạt động của việc này được ẩn hoàn toàn bên trong
của trình điều khiển thiết bị đường ống, nhưng cần phải có tham chiếu đến nó để thiết lập
một chiếc đồng hồ.  Chúng có thể được quản lý bằng:

* ZZ0000ZZ

Vì hàng đợi theo dõi được chỉ định tới kernel bằng fd của đường ống
    triển khai bộ đệm, không gian người dùng phải chuyển fd đó thông qua lệnh gọi hệ thống.
    Điều này có thể được sử dụng để tra cứu một con trỏ mờ tới hàng đợi theo dõi từ
    cuộc gọi hệ thống.

* ZZ0000ZZ

Điều này loại bỏ tham chiếu thu được từ ZZ0000ZZ.


Xem đăng ký API
======================

"Đồng hồ" là đăng ký trong danh sách theo dõi, cho biết hàng đợi theo dõi và
do đó, bộ đệm sẽ được ghi vào đó các bản ghi thông báo.  Đồng hồ
đối tượng hàng đợi cũng có thể mang các quy tắc lọc cho đối tượng đó, như được đặt bởi
không gian người dùng.  Một số phần của cấu trúc đồng hồ có thể được cài đặt bởi trình điều khiển ::

đồng hồ cấu trúc {
		công đoàn {
			thông tin u32_id;	/* ID sẽ được OR đưa vào trường thông tin */
			...
};
		void ZZ0000ZZ Dữ liệu riêng tư cho đối tượng được theo dõi */
		id u64;		/* Mã định danh nội bộ */
		...
	};

Giá trị ZZ0000ZZ phải là số 8 bit thu được từ không gian người dùng và
được dịch chuyển bởi WATCH_INFO_ID__SHIFT.  Đây là OR trong trường WATCH_INFO_ID của
struct watch_notification::info khi nào và nếu thông báo được ghi vào
bộ đệm hàng đợi theo dõi liên quan.

Trường ZZ0000ZZ là dữ liệu của trình điều khiển được liên kết với watch_list và
được làm sạch bằng phương pháp ZZ0001ZZ.

Trường ZZ0000ZZ là ID của nguồn.  Thông báo được đăng với
ID khác nhau sẽ bị bỏ qua.

Các chức năng sau đây được cung cấp để quản lý đồng hồ:

* ZZ0000ZZ

Khởi tạo một đối tượng đồng hồ, đặt con trỏ của nó vào hàng đợi đồng hồ, sử dụng
    rào cản thích hợp để tránh khiếu nại lockdep.

* ZZ0000ZZ

Đăng ký đồng hồ vào danh sách theo dõi (nguồn thông báo).  các
    các trường có thể cài đặt trình điều khiển trong cấu trúc đồng hồ phải được đặt trước đó
    được gọi.

  * ::

int Remove_watch_from_object(struct watch_list *wlist,
				     cấu trúc watch_queue *wqueue,
				     id u64, sai);

Xóa đồng hồ khỏi danh sách theo dõi, trong đó đồng hồ phải khớp với chỉ định
    hàng đợi theo dõi (ZZ0000ZZ) và mã nhận dạng đối tượng (ZZ0001ZZ).  Một thông báo
    (ZZ0002ZZ) được gửi đến hàng đợi theo dõi để
    cho biết đồng hồ đã bị tháo ra.

* ZZ0000ZZ

Xóa tất cả đồng hồ khỏi danh sách theo dõi.  Dự kiến đây sẽ là
    được gọi là chuẩn bị tiêu hủy và danh sách theo dõi sẽ được
    không thể tiếp cận với đồng hồ mới vào thời điểm này.  Một thông báo
    (ZZ0000ZZ) được gửi đến hàng đợi theo dõi của mỗi
    đồng hồ đã đăng ký để cho biết rằng đồng hồ đã bị xóa.


Đăng thông báo API
========================

Để đăng thông báo vào danh sách theo dõi để những người theo dõi đã đăng ký có thể nhìn thấy nó,
nên sử dụng chức năng sau ::

void post_watch_notification(struct watch_list *wlist,
				     cấu trúc watch_notification *n,
				     const struct cred *cred,
				     id u64);

Thông báo phải được định dạng trước và con trỏ tới tiêu đề (ZZ0000ZZ)
nên được chuyển vào. Thông báo có thể lớn hơn kích thước này và kích thước bằng
đơn vị khe đệm được ghi chú trong ZZ0001ZZ.

Cấu trúc ZZ0000ZZ cho biết thông tin xác thực của nguồn (chủ đề) và được
được chuyển đến các LSM, chẳng hạn như SELinux, để cho phép hoặc ngăn chặn việc ghi lại
ghi chú trong từng hàng đợi riêng lẻ theo thông tin xác thực của hàng đợi đó
(đối tượng).

ZZ0000ZZ là ID của đối tượng nguồn (chẳng hạn như số sê-ri trên khóa).
Chỉ những đồng hồ có cùng ID mới thấy thông báo này.


Nguồn xem
=============

Bất kỳ bộ đệm cụ thể nào cũng có thể được cung cấp từ nhiều nguồn.  Các nguồn bao gồm:

* WATCH_TYPE_KEY_NOTIFY

Thông báo thuộc loại này cho biết những thay đổi đối với chìa khóa và chuỗi móc khóa, bao gồm
    những thay đổi về nội dung khóa hoặc thuộc tính của khóa.

Xem Tài liệu/bảo mật/khóa/core.rst để biết thêm thông tin.


Lọc sự kiện
===============

Khi hàng đợi theo dõi đã được tạo, một bộ bộ lọc có thể được áp dụng để giới hạn
các sự kiện được nhận bằng cách sử dụng::

struct watch_notification_filter bộ lọc = {
		...
};
	ioctl(fd, IOC_WATCH_QUEUE_SET_FILTER, &bộ lọc)

Mô tả bộ lọc là một biến có kiểu::

cấu trúc watch_notification_filter {
		__u32 nr_filters;
		__u32 __reserved;
		cấu trúc bộ lọc watch_notification_type_filter[];
	};

Trong đó "nr_filters" là số lượng bộ lọc trong bộ lọc[] và "__reserved"
phải là 0. Mảng "bộ lọc" có các phần tử thuộc loại sau::

cấu trúc watch_notification_type_filter {
		__u32 loại;
		__u32 info_filter;
		__u32 thông tin_mask;
		__u32 subtype_filter[8];
	};

Ở đâu:

* ZZ0000ZZ là loại sự kiện cần lọc và phải giống như
    "WATCH_TYPE_KEY_NOTIFY"

* ZZ0000ZZ và ZZ0001ZZ hoạt động như một bộ lọc trên trường thông tin của
    bản ghi thông báo.  Thông báo chỉ được ghi vào bộ đệm nếu::

(watch.info & info_mask) == info_filter

Ví dụ: điều này có thể được sử dụng để bỏ qua các sự kiện không chính xác trên
    điểm được theo dõi trong cây gắn kết.

* ZZ0000ZZ là một mặt nạ bit cho biết các kiểu con thuộc về
    tiền lãi.  Bit 0 của subtype_filter[0] tương ứng với subtype 0, bit 1 đến
    tiểu loại 1, v.v.

Nếu đối số của ioctl() là NULL thì các bộ lọc sẽ bị xóa và
tất cả các sự kiện từ các nguồn đã xem sẽ diễn ra.


Ví dụ về mã không gian người dùng
======================

Một bộ đệm được tạo với nội dung như sau ::

pipe2(fds, O_TMPFILE);
	ioctl(fds[1], IOC_WATCH_QUEUE_SET_SIZE, 256);

Sau đó, nó có thể được đặt để nhận thông báo thay đổi khóa ::

keyctl(KEYCTL_WATCH_KEY, KEY_SPEC_SESSION_KEYRING, fds[1], 0x01);

Sau đó, các thông báo có thể được sử dụng bởi những thứ như sau ::

người tiêu dùng void tĩnh (int rfd, struct watch_queue_buffer *buf)
	{
		bộ đệm char không dấu [128];
		ssize_t buf_len;

trong khi (buf_len = read(rfd, buffer, sizeof(buffer)),
		       buf_len > 0
		       ) {
			void *p = bộ đệm;
			void *end = đệm + buf_len;
			trong khi (p < kết thúc) {
				công đoàn {
					struct watch_notification n;
					ký tự không dấu buf1[128];
				} N;
				size_t lớn nhất, len;

lớn nhất = cuối - p;
				nếu (lớn nhất > 128)
					lớn nhất = 128;
				memcpy(&n, p, lớn nhất);

len = (n->thông tin & WATCH_INFO_LENGTH) >>
					WATCH_INFO_LENGTH__SHIFT;
				if (len == 0 || len > lớn nhất)
					trở lại;

chuyển đổi (n.n.type) {
				vỏ WATCH_TYPE_META:
					got_meta(&n.n);
				vỏ WATCH_TYPE_KEY_NOTIFY:
					saw_key_change(&n.n);
					phá vỡ;
				}

p += len;
			}
		}
	}
