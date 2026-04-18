.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/cec-core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hỗ trợ hạt nhân CEC
==================

Khung CEC cung cấp giao diện hạt nhân hợp nhất để sử dụng với HDMI CEC
phần cứng. Nó được thiết kế để xử lý nhiều loại phần cứng (máy thu,
máy phát, dongle USB). Khung này cũng cung cấp tùy chọn để quyết định
phải làm gì trong trình điều khiển kernel và những gì nên được xử lý bởi không gian người dùng
ứng dụng. Ngoài ra nó còn tích hợp tính năng điều khiển từ xa
tính năng vào khung điều khiển từ xa của kernel.


Giao thức CEC
----------------

Giao thức CEC cho phép các thiết bị điện tử tiêu dùng giao tiếp với nhau
khác thông qua kết nối HDMI. Giao thức sử dụng các địa chỉ logic trong
giao tiếp. Địa chỉ logic được kết nối chặt chẽ với chức năng
được cung cấp bởi thiết bị. TV đóng vai trò là trung tâm liên lạc luôn
địa chỉ được gán 0. Địa chỉ vật lý được xác định bởi địa chỉ vật lý
kết nối giữa các thiết bị.

Khung CEC được mô tả ở đây được cập nhật với thông số kỹ thuật CEC 2.0.
Nó được ghi lại trong đặc tả HDMI 1.4 với các bit 2.0 mới được ghi lại
trong thông số kỹ thuật HDMI 2.0. Nhưng đối với hầu hết các tính năng, có sẵn miễn phí
Thông số kỹ thuật HDMI 1.3a là đủ:

ZZ0000ZZ


Giao diện bộ chuyển đổi CEC
---------------------

Cấu trúc cec_adapter đại diện cho phần cứng bộ điều hợp CEC. Nó được tạo ra bởi
gọi cec_allocate_adapter() và xóa bằng cách gọi cec_delete_adapter():

.. c:function::
   struct cec_adapter *cec_allocate_adapter(const struct cec_adap_ops *ops, \
					    void *priv, const char *name, \
					    u32 caps, u8 available_las);

.. c:function::
   void cec_delete_adapter(struct cec_adapter *adap);

Để tạo bộ chuyển đổi, bạn cần chuyển thông tin sau:

rất tiếc:
	các hoạt động của bộ điều hợp được gọi bởi khung CEC và bạn
	phải thực hiện.

riêng tư:
	sẽ được lưu trữ trong adap->priv và có thể được sử dụng bởi các bộ điều hợp.
	Sử dụng cec_get_drvdata(adap) để lấy con trỏ riêng tư.

tên:
	tên của bộ chuyển đổi CEC. Lưu ý: tên này sẽ được sao chép.

mũ:
	khả năng của bộ chuyển đổi CEC. Những khả năng này quyết định
	khả năng của phần cứng và những phần nào sẽ được xử lý
	theo không gian người dùng và phần nào được xử lý bởi không gian hạt nhân. các
	khả năng được trả về bởi CEC_ADAP_G_CAPS.

có sẵn_las:
	số lượng địa chỉ logic đồng thời mà điều này
	bộ chuyển đổi có thể xử lý. Phải là 1 <= có sẵn_las <= CEC_MAX_LOG_ADDRS.

Để có được con trỏ riêng, hãy sử dụng hàm trợ giúp này:

.. c:function::
	void *cec_get_drvdata(const struct cec_adapter *adap);

Để đăng ký nút thiết bị /dev/cecX và thiết bị điều khiển từ xa (nếu
CEC_CAP_RC đã được đặt) bạn gọi:

.. c:function::
	int cec_register_adapter(struct cec_adapter *adap, \
				 struct device *parent);

trong đó cha mẹ là thiết bị mẹ.

Để hủy đăng ký thiết bị, hãy gọi:

.. c:function::
	void cec_unregister_adapter(struct cec_adapter *adap);

Lưu ý: nếu cec_register_adapter() không thành công thì hãy gọi cec_delete_adapter() tới
dọn dẹp. Nhưng nếu cec_register_adapter() thành công thì chỉ gọi
cec_unregister_adapter() để dọn dẹp, không bao giờ cec_delete_adapter(). các
chức năng hủy đăng ký sẽ tự động xóa bộ điều hợp sau khi người dùng cuối cùng
của thiết bị /dev/cecX đó đã đóng phần xử lý tệp của nó.


Triển khai Bộ điều hợp CEC cấp thấp
--------------------------------------

Các hoạt động của bộ điều hợp cấp thấp sau đây phải được thực hiện trong
tài xế của bạn:

.. c:struct:: cec_adap_ops

.. code-block:: none

	struct cec_adap_ops
	{
		/* Low-level callbacks */
		int (*adap_enable)(struct cec_adapter *adap, bool enable);
		int (*adap_monitor_all_enable)(struct cec_adapter *adap, bool enable);
		int (*adap_monitor_pin_enable)(struct cec_adapter *adap, bool enable);
		int (*adap_log_addr)(struct cec_adapter *adap, u8 logical_addr);
		void (*adap_unconfigured)(struct cec_adapter *adap);
		int (*adap_transmit)(struct cec_adapter *adap, u8 attempts,
				      u32 signal_free_time, struct cec_msg *msg);
		void (*adap_nb_transmit_canceled)(struct cec_adapter *adap,
						  const struct cec_msg *msg);
		void (*adap_status)(struct cec_adapter *adap, struct seq_file *file);
		void (*adap_free)(struct cec_adapter *adap);

		/* Error injection callbacks */
		...

		/* High-level callback */
		...
	};

Các hoạt động cấp thấp này xử lý các khía cạnh khác nhau của việc điều khiển bộ chuyển đổi CEC
phần cứng. Tất cả chúng đều được gọi với mutex adap->lock được giữ.


Để bật/tắt phần cứng::

int (*adap_enable)(struct cec_adapter *adap, kích hoạt bool);

Lệnh gọi lại này kích hoạt hoặc vô hiệu hóa phần cứng CEC. Kích hoạt phần cứng CEC
có nghĩa là cấp nguồn cho nó ở trạng thái không có địa chỉ logic nào được xác nhận. các
địa chỉ vật lý sẽ luôn hợp lệ nếu CEC_CAP_NEEDS_HPD được đặt. Nếu đó
khả năng không được đặt thì địa chỉ vật lý có thể thay đổi trong khi CEC
phần cứng được kích hoạt. Trình điều khiển CEC không nên đặt CEC_CAP_NEEDS_HPD trừ khi
thiết kế phần cứng yêu cầu điều đó vì điều này sẽ khiến nó không thể đánh thức được
hiển thị kéo HPD xuống thấp khi ở chế độ chờ.  ban đầu
trạng thái của bộ điều hợp CEC sau khi gọi cec_allocate_adapter() bị tắt.

Lưu ý rằng adap_enable phải trả về 0 nếu kích hoạt sai.


Để bật/tắt chế độ 'giám sát tất cả'::

int (*adap_monitor_all_enable)(struct cec_adapter *adap, kích hoạt bool);

Nếu được bật thì bộ chuyển đổi sẽ được đặt ở chế độ giám sát tin nhắn
điều đó không dành cho chúng tôi. Không phải tất cả phần cứng đều hỗ trợ tính năng này và chức năng này chỉ
được gọi nếu khả năng CEC_CAP_MONITOR_ALL được đặt. Cuộc gọi lại này là tùy chọn
(một số phần cứng có thể luôn ở chế độ 'giám sát tất cả').

Lưu ý rằng adap_monitor_all_enable phải trả về 0 nếu kích hoạt sai.


Để bật/tắt chế độ 'pin màn hình'::

int (*adap_monitor_pin_enable)(struct cec_adapter *adap, kích hoạt bool);

Nếu được bật thì bộ chuyển đổi phải được đặt ở chế độ để giám sát chân CEC
những thay đổi. Không phải tất cả phần cứng đều hỗ trợ điều này và chức năng này chỉ được gọi nếu
khả năng CEC_CAP_MONITOR_PIN được thiết lập. Cuộc gọi lại này là tùy chọn
(một số phần cứng có thể luôn ở chế độ 'chân màn hình').

Lưu ý rằng adap_monitor_pin_enable phải trả về 0 nếu kích hoạt sai.


Để lập trình một địa chỉ logic mới::

int (*adap_log_addr)(struct cec_adapter *adap, u8 logic_addr);

Nếu logic_addr == CEC_LOG_ADDR_INVALID thì tất cả các địa chỉ logic được lập trình
sẽ bị xóa. Nếu không thì địa chỉ logic đã cho sẽ được lập trình.
Nếu vượt quá số lượng địa chỉ logic khả dụng tối đa thì nó
nên trả về -ENXIO. Khi địa chỉ logic được lập trình, phần cứng CEC
có thể nhận được tin nhắn trực tiếp đến địa chỉ đó.

Lưu ý rằng adap_log_addr phải trả về 0 nếu logic_addr là CEC_LOG_ADDR_INVALID.


Được gọi khi bộ chuyển đổi chưa được định cấu hình::

khoảng trống (*adap_unconfigured)(struct cec_adapter *adap);

Bộ chuyển đổi chưa được định cấu hình. Nếu người lái xe phải thực hiện các hành động cụ thể sau
hủy cấu hình thì việc đó có thể được thực hiện thông qua lệnh gọi lại tùy chọn này.


Để truyền một tin nhắn mới::

int (*adap_transmit)(struct cec_adapter *adap, u8 lần thử,
			     u32 signal_free_time, struct cec_msg *msg);

Điều này truyền đi một tin nhắn mới. Đối số số lần thử là số lượng được đề xuất
nỗ lực truyền tải.

signal_free_time là số khoảng thời gian bit dữ liệu mà bộ điều hợp sẽ
đợi khi đường dây rảnh trước khi thử gửi tin nhắn. Giá trị này
phụ thuộc vào việc truyền tải này là một lần thử lại, một tin nhắn từ người khởi tạo mới hay
một tin nhắn mới cho cùng một người khởi xướng. Hầu hết phần cứng sẽ xử lý việc này
tự động, nhưng trong một số trường hợp thông tin này là cần thiết.

Macro CEC_FREE_TIME_TO_USEC có thể được sử dụng để chuyển đổi signal_free_time thành
micro giây (một chu kỳ bit dữ liệu là 2,4 ms).


Để truyền kết quả của quá trình truyền không chặn bị hủy::

khoảng trống (*adap_nb_transmit_canceled)(struct cec_adapter *adap,
					  const struct cec_msg *msg);

Cuộc gọi lại tùy chọn này có thể được sử dụng để nhận được kết quả của lệnh hủy
truyền không chặn với thông điệp số thứ tự->trình tự. Đây là
được gọi nếu quá trình truyền bị hủy, quá trình truyền đã hết thời gian chờ (tức là
phần cứng không bao giờ báo hiệu rằng quá trình truyền đã kết thúc) hoặc quá trình truyền
đã thành công nhưng việc chờ đợi phản hồi dự kiến đã bị hủy bỏ
hoặc nó đã hết thời gian.


Để ghi lại trạng thái phần cứng CEC hiện tại::

khoảng trống (tệp *adap_status)(struct cec_adapter *adap, struct seq_file *);

Cuộc gọi lại tùy chọn này có thể được sử dụng để hiển thị trạng thái của phần cứng CEC.
Trạng thái có sẵn thông qua debugfs: cat /sys/kernel/debug/cec/cecX/status

Để giải phóng mọi tài nguyên khi bộ điều hợp bị xóa::

khoảng trống (*adap_free)(struct cec_adapter *adap);

Cuộc gọi lại tùy chọn này có thể được sử dụng để giải phóng mọi tài nguyên có thể đã bị
do người lái xe phân bổ. Nó được gọi từ cec_delete_adapter.


Trình điều khiển bộ điều hợp của bạn cũng sẽ phải phản ứng với các sự kiện (thường là ngắt
được điều khiển) bằng cách gọi vào khung trong các tình huống sau:

Khi quá trình truyền kết thúc (thành công hoặc không)::

void cec_transmit_done(struct cec_adapter *adap, trạng thái u8,
			       u8 arb_lost_cnt, u8 nack_cnt, u8 low_drive_cnt,
			       u8 error_cnt);

hoặc::

void cec_transmit_attempt_done(struct cec_adapter *adap, trạng thái u8);

Trạng thái có thể là một trong:

CEC_TX_STATUS_OK:
	việc truyền tải đã thành công.

CEC_TX_STATUS_ARB_LOST:
	trọng tài đã bị mất: một người khởi xướng CEC khác
	đã nắm quyền kiểm soát dòng CEC và bạn đã thua trong việc phân xử.

CEC_TX_STATUS_NACK:
	tin nhắn đã bị khóa (đối với tin nhắn được chỉ dẫn) hoặc
	đã được xác nhận (đối với tin nhắn quảng bá). Cần phải truyền lại.

CEC_TX_STATUS_LOW_DRIVE:
	ổ đĩa thấp đã được phát hiện trên bus CEC. Điều này chỉ ra rằng
	một người theo dõi đã phát hiện ra lỗi trên xe buýt và yêu cầu
	truyền lại.

CEC_TX_STATUS_ERROR:
	đã xảy ra một số lỗi không xác định: đây có thể là một trong ARB_LOST
	hoặc LOW_DRIVE nếu phần cứng không thể phân biệt được hoặc gì đó
	hoàn toàn khác. Một số phần cứng chỉ hỗ trợ OK và FAIL
	kết quả của một lần truyền, tức là không có cách nào để phân biệt
	giữa các lỗi khác nhau có thể xảy ra. Trong trường hợp đó, bản đồ FAIL
	tới CEC_TX_STATUS_NACK chứ không phải CEC_TX_STATUS_ERROR.

CEC_TX_STATUS_MAX_RETRIES:
	không thể truyền tin nhắn sau khi thử nhiều lần.
	Chỉ nên được thiết lập bởi trình điều khiển nếu nó có hỗ trợ phần cứng cho
	đang thử lại tin nhắn. Nếu được đặt thì khung sẽ giả định rằng nó
	không cần phải thực hiện một nỗ lực nào khác để truyền tải thông điệp
	vì phần cứng đã làm điều đó rồi.

Phần cứng phải có khả năng phân biệt giữa OK, NACK và 'thứ gì đó
khác'.

Các đối số \*_cnt là số lượng điều kiện lỗi đã được nhìn thấy.
Giá trị này có thể bằng 0 nếu không có thông tin. Trình điều khiển không hỗ trợ
thử lại phần cứng chỉ có thể đặt bộ đếm tương ứng với lỗi truyền
thành 1, nếu phần cứng hỗ trợ thử lại thì hãy đặt các bộ đếm này thành
0 nếu phần cứng không cung cấp phản hồi về lỗi nào đã xảy ra và có bao nhiêu lỗi
lần hoặc điền vào các giá trị chính xác theo báo cáo của phần cứng.

Xin lưu ý rằng việc gọi các chức năng này có thể ngay lập tức bắt đầu một quá trình truyền mới.
nếu có một cái đang chờ xử lý trong hàng đợi. Vì vậy hãy đảm bảo rằng phần cứng đã sẵn sàng
trạng thái nơi các lần truyền mới có thể được bắt đầu ZZ0000ZZ gọi các chức năng này.

Hàm cec_transmit_attempt_done() là một trợ giúp cho các trường hợp
phần cứng không bao giờ thử lại nên quá trình truyền luôn chỉ diễn ra trong một lần
cố gắng. Nó sẽ lần lượt gọi cec_transmit_done(), điền vào 1 cho
đối số đếm tương ứng với trạng thái. Hoặc tất cả là 0 nếu trạng thái ổn.

Khi nhận được tin nhắn CEC:

.. c:function::
	void cec_received_msg(struct cec_adapter *adap, struct cec_msg *msg);

Nói cho chính nó.

Thực hiện xử lý ngắt
----------------------------------

Thông thường, phần cứng CEC cung cấp các tín hiệu ngắt khi truyền
đã hoàn thành và liệu nó có thành công hay không, đồng thời nó cung cấp và làm gián đoạn
khi nhận được tin nhắn CEC.

Trình điều khiển CEC phải luôn xử lý các ngắt truyền trước khi
xử lý ngắt nhận. Khung này mong đợi sẽ thấy cec_transmit_done
gọi trước cuộc gọi cec_receured_msg, nếu không nó có thể bị nhầm lẫn nếu
tin nhắn nhận được đã trả lời tin nhắn được truyền đi.

Tùy chọn: Triển khai hỗ trợ chèn lỗi
----------------------------------------------

Nếu bộ điều hợp CEC hỗ trợ chức năng Chèn lỗi thì điều đó có thể
bị lộ thông qua lệnh gọi lại Chèn lỗi:

.. code-block:: none

	struct cec_adap_ops {
		/* Low-level callbacks */
		...

		/* Error injection callbacks */
		int (*error_inj_show)(struct cec_adapter *adap, struct seq_file *sf);
		bool (*error_inj_parse_line)(struct cec_adapter *adap, char *line);

		/* High-level CEC message callback */
		...
	};

Nếu cả hai lệnh gọi lại được đặt thì tệp ZZ0000ZZ sẽ xuất hiện trong debugfs.
Cú pháp cơ bản như sau:

Khoảng trắng/tab hàng đầu bị bỏ qua. Nếu ký tự tiếp theo là ZZ0000ZZ hoặc kết thúc
đã đạt đến dòng thì toàn bộ dòng sẽ bị bỏ qua. Nếu không thì sẽ có một lệnh.

Việc phân tích cú pháp cơ bản này được thực hiện trong CEC Framework. Tùy tài xế quyết định
những lệnh nào để thực hiện. Yêu cầu duy nhất là lệnh ZZ0000ZZ không có
mọi đối số phải được triển khai và nó sẽ loại bỏ tất cả lỗi chèn hiện tại
lệnh.

Điều này đảm bảo rằng bạn luôn có thể thực hiện ZZ0000ZZ để xóa mọi lỗi
tiêm mà không cần phải biết chi tiết về các lệnh dành riêng cho trình điều khiển.

Lưu ý rằng đầu ra của ZZ0000ZZ sẽ hợp lệ như đầu vào của ZZ0001ZZ.
Vì vậy, điều này phải hoạt động:

.. code-block:: none

	$ cat error-inj >einj.txt
	$ cat einj.txt >error-inj

Cuộc gọi lại đầu tiên được gọi khi tệp này được đọc và nó sẽ hiển thị
trạng thái tiêm lỗi hiện tại::

int (*error_inj_show)(struct cec_adapter *adap, struct seq_file *sf);

Bạn nên bắt đầu bằng khối nhận xét với cách sử dụng cơ bản
thông tin. Nó trả về 0 nếu thành công và nếu không thì trả về lỗi.

Lệnh gọi lại thứ hai sẽ phân tích các lệnh được ghi vào tệp ZZ0000ZZ ::

bool (*error_inj_parse_line)(struct cec_adapter *adap, char *line);

Đối số ZZ0000ZZ trỏ đến điểm bắt đầu của lệnh. Bất kỳ hàng đầu
dấu cách hoặc tab đã bị bỏ qua. Nó chỉ là một dòng duy nhất (vì vậy có
không có dòng mới được nhúng) và nó bị chấm dứt ở mức 0. Việc gọi lại là miễn phí
sửa đổi nội dung của bộ đệm. Nó chỉ được gọi cho các dòng có chứa
nên lệnh gọi lại này không bao giờ được gọi đối với các dòng trống hoặc dòng chú thích.

Trả về true nếu lệnh hợp lệ hoặc sai nếu có lỗi cú pháp.

Triển khai Bộ điều hợp CEC cấp cao
---------------------------------------

Các hoạt động cấp thấp điều khiển phần cứng, các hoạt động cấp cao được điều khiển
Điều khiển giao thức CEC. Các cuộc gọi lại cấp cao được gọi mà không có adap->lock
mutex đang được giữ. Có sẵn các lệnh gọi lại cấp cao sau đây:

.. code-block:: none

	struct cec_adap_ops {
		/* Low-level callbacks */
		...

		/* Error injection callbacks */
		...

		/* High-level CEC message callback */
		void (*configured)(struct cec_adapter *adap);
		int (*received)(struct cec_adapter *adap, struct cec_msg *msg);
	};

Được gọi khi bộ chuyển đổi được cấu hình::

khoảng trống (*configured)(struct cec_adapter *adap);

Bộ điều hợp được cấu hình đầy đủ, tức là tất cả các địa chỉ logic đã được
đã yêu cầu thành công. Nếu người lái xe phải thực hiện các hành động cụ thể sau
cấu hình, thì việc đó có thể được thực hiện thông qua lệnh gọi lại tùy chọn này.


Cuộc gọi lại đã nhận () cho phép trình điều khiển tùy chọn xử lý một lệnh mới
đã nhận được tin nhắn CEC::

int (*received)(struct cec_adapter *adap, struct cec_msg *msg);

Nếu trình điều khiển muốn xử lý thông báo CEC thì nó có thể thực hiện điều này
gọi lại. Nếu nó không muốn xử lý tin nhắn này thì nó sẽ trả về
-ENOMSG, nếu không thì khung CEC cho rằng nó đã xử lý thông báo này và
nó sẽ không làm gì với nó.


Chức năng khung CEC
-----------------------

Trình điều khiển Bộ điều hợp CEC có thể gọi các hàm khung CEC sau:

.. c:function::
   int cec_transmit_msg(struct cec_adapter *adap, struct cec_msg *msg, \
			bool block);

Truyền tin nhắn CEC. Nếu chặn là đúng thì đợi cho đến khi tin nhắn được gửi xong
được truyền đi, nếu không thì chỉ cần xếp hàng và quay lại.

.. c:function::
   void cec_s_phys_addr(struct cec_adapter *adap, u16 phys_addr, bool block);

Thay đổi địa chỉ vật lý. Hàm này sẽ đặt adap->phys_addr và
gửi một sự kiện nếu nó đã thay đổi. Nếu cec_s_log_addrs() đã được gọi và
địa chỉ vật lý đã trở nên hợp lệ thì khung CEC sẽ bắt đầu
yêu cầu các địa chỉ logic. Nếu khối là đúng thì chức năng này sẽ không
trở lại cho đến khi quá trình này kết thúc.

Khi địa chỉ vật lý được đặt thành giá trị hợp lệ, bộ điều hợp CEC sẽ
được bật (xem op adap_enable). Khi nó được đặt thành CEC_PHYS_ADDR_INVALID,
thì bộ chuyển đổi CEC sẽ bị tắt. Nếu bạn thay đổi địa chỉ vật lý hợp lệ
đến một địa chỉ vật lý hợp lệ khác thì trước tiên chức năng này sẽ thiết lập địa chỉ
tới CEC_PHYS_ADDR_INVALID trước khi kích hoạt địa chỉ vật lý mới.

.. c:function::
   void cec_s_phys_addr_from_edid(struct cec_adapter *adap, \
				  const struct edid *edid);

Hàm trợ giúp trích xuất địa chỉ vật lý từ cấu trúc edid
và gọi cec_s_phys_addr() bằng địa chỉ đó hoặc CEC_PHYS_ADDR_INVALID
nếu EDID không chứa địa chỉ vật lý hoặc edid là con trỏ NULL.

.. c:function::
	int cec_s_log_addrs(struct cec_adapter *adap, \
			    struct cec_log_addrs *log_addrs, bool block);

Yêu cầu địa chỉ logic CEC. Không bao giờ được gọi nếu CEC_CAP_LOG_ADDRS
được thiết lập. Nếu khối là đúng thì đợi cho đến khi địa chỉ logic được
đã được yêu cầu, nếu không thì chỉ cần xếp hàng và quay lại. Để hủy cấu hình tất cả logic
địa chỉ gọi hàm này với log_addrs được đặt thành NULL hoặc với
log_addrs->num_log_addrs được đặt thành 0. Đối số khối bị bỏ qua khi
đang hủy cấu hình. Hàm này sẽ chỉ trả về nếu địa chỉ vật lý là
không hợp lệ. Khi địa chỉ vật lý trở nên hợp lệ thì khung sẽ
cố gắng yêu cầu các địa chỉ logic này.

Khung pin CEC
-----------------

Hầu hết phần cứng CEC hoạt động trên các thông báo CEC đầy đủ mà phần mềm cung cấp
thông báo và phần cứng xử lý giao thức CEC cấp thấp. Nhưng một số
phần cứng chỉ điều khiển chân CEC và phần mềm phải xử lý mức độ thấp
Giao thức CEC. Khung pin CEC được tạo để xử lý các thiết bị như vậy.

Lưu ý rằng do yêu cầu gần với thời gian thực nên không bao giờ có thể đảm bảo được
để làm việc 100%. Khung này sử dụng bộ tính giờ độ phân giải cao trong nội bộ, nhưng nếu
đồng hồ hẹn giờ tắt quá muộn hơn 300 micro giây, kết quả có thể sai
xảy ra. Trong thực tế, nó có vẻ khá đáng tin cậy.

Một ưu điểm của việc triển khai ở mức độ thấp này là nó có thể được sử dụng như
một máy phân tích CEC giá rẻ, đặc biệt nếu các ngắt có thể được sử dụng để phát hiện
Chân CEC chuyển từ thấp lên cao hoặc ngược lại.

.. kernel-doc:: include/media/cec-pin.h

Khung thông báo CEC
----------------------

Hầu hết các triển khai drm HDMI đều có triển khai CEC tích hợp và không có
hỗ trợ thông báo là cần thiết. Nhưng một số có triển khai CEC độc lập
có tài xế riêng. Đây có thể là khối IP cho SoC hoặc
chip hoàn toàn riêng biệt xử lý chân CEC. Đối với những trường hợp đó một
Trình điều khiển drm có thể cài đặt trình thông báo và sử dụng trình thông báo để thông báo cho
Trình điều khiển CEC về những thay đổi trong địa chỉ vật lý.

.. kernel-doc:: include/media/cec-notifier.h