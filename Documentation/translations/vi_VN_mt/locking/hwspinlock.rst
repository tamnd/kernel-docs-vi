.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/hwspinlock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Khung Spinlock phần cứng
===========================

Giới thiệu
============

Các mô-đun spinlock phần cứng cung cấp hỗ trợ phần cứng để đồng bộ hóa
và loại trừ lẫn nhau giữa các bộ xử lý không đồng nhất và những bộ xử lý không hoạt động
dưới một hệ điều hành chung, duy nhất.

Ví dụ: OMAP4 có Cortex-A9 kép, Cortex-M3 kép và C64x+ DSP,
mỗi trong số đó đang chạy một Hệ điều hành khác nhau (chính, A9,
thường chạy Linux và các bộ xử lý phụ, M3 và DSP,
đang chạy một số hương vị của RTOS).

Khung hwspinlock chung cho phép các trình điều khiển độc lập với nền tảng sử dụng
thiết bị hwspinlock để truy cập các cấu trúc dữ liệu được chia sẻ
giữa các bộ xử lý từ xa, nếu không thì không có cơ chế thay thế
để thực hiện các hoạt động đồng bộ hóa và loại trừ lẫn nhau.

Ví dụ: điều này là cần thiết đối với liên lạc giữa các bộ xử lý:
trên OMAP4, các tác vụ đa phương tiện đòi hỏi nhiều CPU sẽ được máy chủ chuyển tải sang
bộ xử lý phụ M3 và/hoặc C64x+ từ xa (bởi hệ thống con IPC có tên Syslink).

Để đạt được thông tin liên lạc dựa trên tin nhắn nhanh, hỗ trợ kernel tối thiểu
là cần thiết để gửi tin nhắn đến từ bộ xử lý từ xa tới
quy trình sử dụng thích hợp.

Giao tiếp này dựa trên cấu trúc dữ liệu đơn giản được chia sẻ giữa
bộ xử lý từ xa và quyền truy cập vào nó được đồng bộ hóa bằng cách sử dụng hwspinlock
mô-đun (bộ xử lý từ xa đặt trực tiếp các tin nhắn mới vào dữ liệu được chia sẻ này
cấu trúc).

Giao diện hwspinlock phổ biến giúp có thể có nền tảng chung,
độc lập, lái xe.

Người dùng API
========

::

cấu trúc hwspinlock *hwspin_lock_request_special(id int không dấu);

Chỉ định một id hwspinlock cụ thể và trả về địa chỉ của nó hoặc NULL
nếu hwspinlock đó đã được sử dụng. Thông thường mã bảng sẽ
đang gọi hàm này để dự trữ hwspinlock cụ thể
id cho các mục đích được xác định trước.

Nên được gọi từ bối cảnh quá trình (có thể ngủ).

::

int of_hwspin_lock_get_id(struct device_node *np, int index);

Truy xuất id khóa chung cho khóa cụ thể dựa trên phân đoạn OF.
Chức năng này cung cấp phương tiện cho người dùng DT của mô-đun hwspinlock
để lấy id khóa chung của một hwspinlock cụ thể để nó có thể
được yêu cầu bằng cách sử dụng hwspin_lock_request_special() API thông thường.

Hàm trả về số id khóa khi thành công, -EPROBE_DEFER nếu
thiết bị hwspinlock chưa được đăng ký với lõi hoặc thiết bị khác
các giá trị lỗi.

Nên được gọi từ bối cảnh quá trình (có thể ngủ).

::

int hwspin_lock_free(struct hwspinlock *hwlock);

Giải phóng hwspinlock đã được chỉ định trước đó; trả về 0 nếu thành công hoặc
mã lỗi thích hợp khi xảy ra lỗi (ví dụ: -EINVAL nếu hwspinlock
đã miễn phí rồi).

Nên được gọi từ bối cảnh quá trình (có thể ngủ).

::

int hwspin_lock_bust(struct hwspinlock *hwlock, unsigned int id);

Sau khi xác minh chủ sở hữu của hwspinlock, hãy phát hành bản đã mua trước đó
hwspinlock; trả về 0 nếu thành công hoặc mã lỗi thích hợp nếu thất bại
(ví dụ: -EOPNOTSUPP nếu hoạt động bán thân không được xác định cho cụ thể
hwspinlock).

Nên được gọi từ bối cảnh quá trình (có thể ngủ).

::

int hwspin_lock_timeout(struct hwspinlock *hwlock, unsigned int timeout);

Khóa hwspinlock được chỉ định trước đó với giới hạn thời gian chờ (được chỉ định trong
mili giây). Nếu hwspinlock đã được sử dụng, hàm sẽ bận lặp lại
chờ đợi nó được phát hành, nhưng bỏ cuộc khi hết thời gian chờ.
Khi trở về thành công từ chức năng này, quyền ưu tiên bị vô hiệu hóa nên
người gọi không được ngủ và nên nhả hwspinlock khi
càng sớm càng tốt, để giảm thiểu việc bỏ phiếu lõi từ xa trên
kết nối phần cứng.

Trả về 0 khi thành công và ngược lại là mã lỗi thích hợp (hầu hết
đặc biệt là -ETIMEDOUT nếu hwspinlock vẫn bận sau khi hết thời gian chờ ms).
Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_lock_timeout_irq(struct hwspinlock *hwlock, unsigned int timeout);

Khóa hwspinlock được chỉ định trước đó với giới hạn thời gian chờ (được chỉ định trong
mili giây). Nếu hwspinlock đã được sử dụng, hàm sẽ bận lặp lại
chờ đợi nó được phát hành, nhưng bỏ cuộc khi hết thời gian chờ.
Khi trở về thành công từ chức năng này, quyền ưu tiên và địa phương
các ngắt bị vô hiệu hóa, do đó người gọi không được ngủ và nên
giải phóng hwspinlock càng sớm càng tốt.

Trả về 0 khi thành công và ngược lại là mã lỗi thích hợp (hầu hết
đặc biệt là -ETIMEDOUT nếu hwspinlock vẫn bận sau khi hết thời gian chờ ms).
Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_lock_timeout_irqsave(struct hwspinlock *hwlock, unsigned int to,
				  cờ * dài không dấu);

Khóa hwspinlock được chỉ định trước đó với giới hạn thời gian chờ (được chỉ định trong
mili giây). Nếu hwspinlock đã được sử dụng, hàm sẽ bận lặp lại
chờ đợi nó được phát hành, nhưng bỏ cuộc khi hết thời gian chờ.
Khi trở về thành công từ chức năng này, quyền ưu tiên bị vô hiệu hóa,
các ngắt cục bộ bị vô hiệu hóa và trạng thái trước đó của chúng được lưu vào
giữ chỗ cờ đã cho. Người gọi không được ngủ và được khuyên nên
giải phóng hwspinlock càng sớm càng tốt.

Trả về 0 khi thành công và ngược lại là mã lỗi thích hợp (hầu hết
đặc biệt là -ETIMEDOUT nếu hwspinlock vẫn bận sau khi hết thời gian chờ ms).

Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_lock_timeout_raw(struct hwspinlock *hwlock, unsigned int timeout);

Khóa hwspinlock được chỉ định trước đó với giới hạn thời gian chờ (được chỉ định trong
mili giây). Nếu hwspinlock đã được sử dụng, hàm sẽ bận lặp lại
chờ đợi nó được phát hành, nhưng bỏ cuộc khi hết thời gian chờ.

Thận trọng: Người dùng phải bảo vệ thói quen lấy khóa phần cứng bằng mutex
hoặc spinlock để tránh khóa chết, điều đó sẽ cho phép người dùng có thể thực hiện một số thao tác tốn thời gian
hoặc các hoạt động có thể ngủ dưới khóa phần cứng.

Trả về 0 khi thành công và ngược lại là mã lỗi thích hợp (hầu hết
đặc biệt là -ETIMEDOUT nếu hwspinlock vẫn bận sau khi hết thời gian chờ ms).

Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_lock_timeout_in_atomic(struct hwspinlock *hwlock, unsigned int to);

Khóa hwspinlock được chỉ định trước đó với giới hạn thời gian chờ (được chỉ định trong
mili giây). Nếu hwspinlock đã được sử dụng, hàm sẽ bận lặp lại
chờ đợi nó được phát hành, nhưng bỏ cuộc khi hết thời gian chờ.

Hàm này chỉ được gọi từ bối cảnh nguyên tử và thời gian chờ
giá trị không được vượt quá vài ms.

Trả về 0 khi thành công và ngược lại là mã lỗi thích hợp (hầu hết
đặc biệt là -ETIMEDOUT nếu hwspinlock vẫn bận sau khi hết thời gian chờ ms).

Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_trylock(struct hwspinlock *hwlock);


Cố gắng khóa một hwspinlock được gán trước đó, nhưng ngay lập tức thất bại nếu
nó đã được sử dụng rồi.

Khi trở về thành công từ chức năng này, quyền ưu tiên bị vô hiệu hóa nên
người gọi không được ngủ và nên mở khóa hwspinlock ngay khi
có thể, để giảm thiểu việc thăm dò lõi từ xa trên phần cứng
kết nối với nhau.

Trả về 0 nếu thành công và nếu không thì sẽ có mã lỗi phù hợp (hầu hết
đặc biệt là -EBUSY nếu hwspinlock đã được sử dụng).
Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_trylock_irq(struct hwspinlock *hwlock);


Cố gắng khóa một hwspinlock được gán trước đó, nhưng ngay lập tức thất bại nếu
nó đã được sử dụng rồi.

Khi trở về thành công từ chức năng này, quyền ưu tiên và địa phương
các ngắt bị vô hiệu hóa nên người gọi không được ngủ và nên
giải phóng hwspinlock càng sớm càng tốt.

Trả về 0 nếu thành công và nếu không thì sẽ có mã lỗi phù hợp (hầu hết
đặc biệt là -EBUSY nếu hwspinlock đã được sử dụng).

Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_trylock_irqsave(struct hwspinlock *hwlock, unsigned long *flags);

Cố gắng khóa một hwspinlock được gán trước đó, nhưng ngay lập tức thất bại nếu
nó đã được sử dụng rồi.

Khi trở về thành công từ chức năng này, quyền ưu tiên bị vô hiệu hóa,
các ngắt cục bộ bị vô hiệu hóa và trạng thái trước đó của chúng được lưu lại
tại phần giữ chỗ cờ đã cho. Người gọi không được ngủ và được khuyên
để giải phóng hwspinlock càng sớm càng tốt.

Trả về 0 nếu thành công và nếu không thì sẽ có mã lỗi phù hợp (hầu hết
đặc biệt là -EBUSY nếu hwspinlock đã được sử dụng).
Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_trylock_raw(struct hwspinlock *hwlock);

Cố gắng khóa một hwspinlock được gán trước đó, nhưng ngay lập tức thất bại nếu
nó đã được sử dụng rồi.

Thận trọng: Người dùng phải bảo vệ thói quen lấy khóa phần cứng bằng mutex
hoặc spinlock để tránh khóa chết, điều đó sẽ cho phép người dùng có thể thực hiện một số thao tác tốn thời gian
hoặc các hoạt động có thể ngủ dưới khóa phần cứng.

Trả về 0 nếu thành công và nếu không thì sẽ có mã lỗi phù hợp (hầu hết
đặc biệt là -EBUSY nếu hwspinlock đã được sử dụng).
Chức năng này sẽ không bao giờ ngủ.

::

int hwspin_trylock_in_atomic(struct hwspinlock *hwlock);

Cố gắng khóa một hwspinlock được gán trước đó, nhưng ngay lập tức thất bại nếu
nó đã được sử dụng rồi.

Hàm này chỉ được gọi từ bối cảnh nguyên tử.

Trả về 0 nếu thành công và nếu không thì sẽ có mã lỗi phù hợp (hầu hết
đặc biệt là -EBUSY nếu hwspinlock đã được sử dụng).
Chức năng này sẽ không bao giờ ngủ.

::

void hwspin_unlock(struct hwspinlock *hwlock);

Mở khóa hwspinlock đã bị khóa trước đó. Luôn thành công và có thể được gọi là
từ bất kỳ ngữ cảnh nào (chức năng không bao giờ ngủ).

.. note::

  code should **never** unlock an hwspinlock which is already unlocked
  (there is no protection against this).

::

void hwspin_unlock_irq(struct hwspinlock *hwlock);

Mở khóa hwspinlock đã bị khóa trước đó và kích hoạt các ngắt cục bộ.
Người gọi phải ZZ0000ZZ mở khóa hwspinlock đã được mở khóa.

Làm như vậy được coi là một lỗi (không có biện pháp bảo vệ nào chống lại điều này).
Khi trở về thành công từ chức năng này, quyền ưu tiên và địa phương
ngắt được kích hoạt. Chức năng này sẽ không bao giờ ngủ.

::

trống rỗng
  hwspin_unlock_irqrestore(struct hwspinlock *hwlock, unsigned long *flags);

Mở khóa hwspinlock đã bị khóa trước đó.

Người gọi phải ZZ0000ZZ mở khóa hwspinlock đã được mở khóa.
Làm như vậy được coi là một lỗi (không có biện pháp bảo vệ nào chống lại điều này).
Sau khi quay trở lại thành công từ chức năng này, quyền ưu tiên sẽ được kích hoạt lại,
và trạng thái của các ngắt cục bộ được khôi phục về trạng thái được lưu tại
các lá cờ đã cho. Chức năng này sẽ không bao giờ ngủ.

::

void hwspin_unlock_raw(struct hwspinlock *hwlock);

Mở khóa hwspinlock đã bị khóa trước đó.

Người gọi phải ZZ0000ZZ mở khóa hwspinlock đã được mở khóa.
Làm như vậy được coi là một lỗi (không có biện pháp bảo vệ nào chống lại điều này).
Chức năng này sẽ không bao giờ ngủ.

::

void hwspin_unlock_in_atomic(struct hwspinlock *hwlock);

Mở khóa hwspinlock đã bị khóa trước đó.

Người gọi phải ZZ0000ZZ mở khóa hwspinlock đã được mở khóa.
Làm như vậy được coi là một lỗi (không có biện pháp bảo vệ nào chống lại điều này).
Chức năng này sẽ không bao giờ ngủ.

Cách sử dụng điển hình
=============

::

#include <linux/hwspinlock.h>
	#include <linux/err.h>

int hwspinlock_example(void)
	{
		struct hwspinlock *hwlock;
		int ret;

/*
		* chỉ định một id hwspinlock cụ thể - cái này nên được gọi sớm
		* theo mã init của bảng.
		*/
		hwlock = hwspin_lock_request_spec(PREDEFINED_LOCK_ID);
		nếu (! hwlock)
			...

/*cố gắng lấy nó, nhưng đừng quay nó */
		ret = hwspin_trylock(hwlock);
		nếu (!ret) {
			pr_info("khóa đã được sử dụng\n");
			trả về -EBUSY;
		}

/*
		* chúng tôi đã lấy khóa, làm việc của mình ngay bây giờ, nhưng NOT có ngủ không
		*/

/*mở khóa*/
		hwspin_unlock(hwlock);

/*mở khóa*/
		ret = hwspin_lock_free(hwlock);
		nếu (ret)
			...

trở lại ret;
	}


API dành cho người triển khai
====================

::

int hwspin_lock_register(struct hwspinlock_device *bank, struct device *dev,
		const struct hwspinlock_ops *ops, int base_id, int num_locks);

Để được gọi từ việc triển khai dành riêng cho nền tảng cơ bản, trong
để đăng ký một thiết bị hwspinlock mới (thường là một ngân hàng
nhiều ổ khóa). Nên được gọi từ bối cảnh quy trình (hàm này
có thể ngủ).

Trả về 0 nếu thành công hoặc mã lỗi thích hợp nếu thất bại.

::

int hwspin_lock_unregister(struct hwspinlock_device *bank);

Được gọi từ việc triển khai dành riêng cho nhà cung cấp cơ bản, để
để hủy đăng ký một thiết bị hwspinlock (thường là một ngân hàng gồm nhiều thiết bị
ổ khóa).

Nên được gọi từ bối cảnh quy trình (chức năng này có thể ngủ).

Trả về địa chỉ của hwspinlock nếu thành công hoặc NULL nếu có lỗi (ví dụ:
nếu hwspinlock vẫn đang được sử dụng).

Cấu trúc quan trọng
=================

struct hwspinlock_device là một thiết bị thường chứa ngân hàng
của các khóa phần cứng. Nó được đăng ký bởi hwspinlock cơ bản
triển khai bằng cách sử dụng hwspin_lock_register() API.

::

/**
	* struct hwspinlock_device - một thiết bị thường trải rộng trên nhiều hwspinlocks
	* @dev: thiết bị cơ bản, sẽ được sử dụng để gọi api PM thời gian chạy
	* @ops: trình xử lý hwspinlock dành riêng cho nền tảng
	* @base_id: chỉ số id của khóa đầu tiên trên thiết bị này
	* @num_locks: số lượng ổ khóa trên thiết bị này
	* @lock: mảng được cấp phát động của 'struct hwspinlock'
	*/
	cấu trúc hwspinlock_device {
		thiết bị cấu trúc *dev;
		const struct hwspinlock_ops *ops;
		int base_id;
		int num_locks;
		cấu trúc khóa hwspinlock[0];
	};

struct hwspinlock_device chứa một mảng các cấu trúc hwspinlock, mỗi cấu trúc
trong đó đại diện cho một khóa phần cứng duy nhất::

/**
	* struct hwspinlock - cấu trúc này đại diện cho một phiên bản hwspinlock duy nhất
	* @bank: cấu trúc hwspinlock_device sở hữu khóa này
	* @lock: được khởi tạo và sử dụng bởi lõi hwspinlock
	* @priv: dữ liệu riêng tư, được sở hữu bởi drv hwspinlock dành riêng cho nền tảng cơ bản
	*/
	cấu trúc hwspinlock {
		cấu trúc hwspinlock_device *ngân hàng;
		khóa spinlock_t;
		void *priv;
	};

Khi đăng ký ngân hàng ổ khóa, trình điều khiển hwspinlock chỉ cần
thiết lập các thành viên riêng tư của ổ khóa. Các thành viên còn lại được thiết lập và
được khởi tạo bởi chính lõi hwspinlock.

Lệnh gọi lại triển khai
========================

Có ba lệnh gọi lại có thể được xác định trong 'struct hwspinlock_ops'::

cấu trúc hwspinlock_ops {
		int (*trylock)(struct hwspinlock *lock);
		khoảng trống (*unlock)(struct hwspinlock *lock);
		khoảng trống (*relax)(struct hwspinlock *lock);
	};

Hai cuộc gọi lại đầu tiên là bắt buộc:

Cuộc gọi lại ->trylock() sẽ thực hiện một lần thử lấy khóa và
trả về 0 khi thất bại và 1 khi thành công. Cuộc gọi lại này có thể ZZ0000ZZ ở chế độ ngủ.

Lệnh gọi lại ->unlock() giải phóng khóa. Nó luôn thành công, và nó cũng vậy,
ZZ0000ZZ có thể ngủ được không.

Lệnh gọi lại ->relax() là tùy chọn. Nó được gọi bởi lõi hwspinlock trong khi
quay trên một khóa và có thể được triển khai cơ bản sử dụng để buộc
độ trễ giữa hai lần gọi ->trylock() liên tiếp. Nó có thể ZZ0000ZZ ngủ.
