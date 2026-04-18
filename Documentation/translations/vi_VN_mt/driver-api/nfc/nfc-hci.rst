.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/nfc/nfc-hci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================
Phần phụ trợ HCI cho Lõi NFC
============================

- Tác giả: Eric Lapuyade, Samuel Ortiz
- Liên hệ: eric.lapuyade@intel.com, samuel.ortiz@intel.com

Tổng quan
-------

Lớp HCI triển khai phần lớn thông số kỹ thuật ETSI TS 102 622 V10.2.0. Nó
cho phép dễ dàng viết trình điều khiển NFC dựa trên HCI. Lớp HCI chạy dưới dạng lõi NFC
phụ trợ, triển khai một thiết bị nfc trừu tượng và dịch NFC Core API
tới các lệnh và sự kiện HCI.

HCI
---

HCI đăng ký làm thiết bị nfc với NFC Core. Các yêu cầu đến từ không gian người dùng là
được định tuyến qua các ổ cắm netlink tới NFC Core và sau đó đến HCI. Từ thời điểm này,
chúng được dịch theo một chuỗi các lệnh HCI được gửi đến lớp HCI trong
bộ điều khiển máy chủ (chip). Các lệnh có thể được thực hiện đồng bộ (việc gửi
khối ngữ cảnh đang chờ phản hồi) hoặc không đồng bộ (phản hồi được trả về
từ bối cảnh HCI Rx).
Các sự kiện HCI cũng có thể được nhận từ bộ điều khiển máy chủ. Họ sẽ được xử lý
và bản dịch sẽ được chuyển tiếp tới NFC Core nếu cần. Có móc để
hãy để trình điều khiển HCI xử lý các sự kiện độc quyền hoặc ghi đè hành vi tiêu chuẩn.
HCI sử dụng 2 bối cảnh thực thi:

- một để thực thi các lệnh: nfc_hci_msg_tx_work(). Chỉ có một lệnh
  có thể được thực thi tại bất kỳ thời điểm nào.
- một để gửi các sự kiện và lệnh đã nhận: nfc_hci_msg_rx_work().

HCI Khởi tạo phiên
--------------------------

Việc khởi tạo Phiên là một tiêu chuẩn HCI, rất tiếc phải
hỗ trợ các cổng độc quyền. Đây là lý do tài xế sẽ vượt qua danh sách
các cổng độc quyền phải là một phần của phiên. HCI sẽ đảm bảo tất cả
những cổng đó có đường ống được kết nối khi thiết bị hci được thiết lập.
Trong trường hợp chip hỗ trợ cổng mở sẵn và ống giả tĩnh, trình điều khiển
có thể chuyển thông tin đó đến lõi HCI.

Cổng và ống HCI
-------------------

Một cổng xác định 'cổng' nơi có thể tìm thấy một số dịch vụ. Để truy cập
một dịch vụ, người ta phải tạo một đường dẫn đến cổng đó và mở nó. Trong này
thực hiện, các đường ống được ẩn hoàn toàn. API công khai chỉ biết cổng.
Điều này phù hợp với nhu cầu của người lái xe gửi lệnh đến các cổng độc quyền
mà không biết đường ống kết nối với nó.

Giao diện trình điều khiển
----------------

Một trình điều khiển thường được viết thành hai phần: quản lý liên kết vật lý và
quản lý HCI. Điều này làm cho việc duy trì trình điều khiển cho chip dễ dàng hơn
có thể được kết nối bằng nhiều phy khác nhau (i2c, spi, ...)

Quản lý HCI
--------------

Trình điều khiển thường sẽ tự đăng ký với HCI và cung cấp thông tin sau
điểm vào::

cấu trúc nfc_hci_ops {
	int (*open)(struct nfc_hci_dev *hdev);
	khoảng trống (*close)(struct nfc_hci_dev *hdev);
	int (*hci_ready) (struct nfc_hci_dev *hdev);
	int (ZZ0003Zhdev, struct sk_buff *skb);
	int (*start_poll) (struct nfc_hci_dev *hdev,
			   u32 im_protocols, u32 tm_protocols);
	int (*dep_link_up)(struct nfc_hci_dev *hdev, struct nfc_target *target,
			   u8 comm_mode, u8 *gb, size_t gb_len);
	int (*dep_link_down)(struct nfc_hci_dev *hdev);
	int (*target_from_gate) (struct nfc_hci_dev *hdev, cổng u8,
				 struct nfc_target *target);
	int (ZZ0008Zhdev, cổng u8,
					   struct nfc_target *target);
	int (*im_transceive) (struct nfc_hci_dev *hdev,
			      cấu trúc nfc_target *target, struct sk_buff *skb,
			      data_exchange_cb_t cb, void *cb_context);
	int (*tm_send)(struct nfc_hci_dev *hdev, struct sk_buff *skb);
	int (*check_presence)(struct nfc_hci_dev *hdev,
			      struct nfc_target *target);
	int (*event_received)(struct nfc_hci_dev *hdev, cổng u8, sự kiện u8,
			      cấu trúc sk_buff *skb);
  };

- open() và close() sẽ bật và tắt phần cứng.
- hci_ready() là một điểm vào tùy chọn được gọi ngay sau hci
  phiên đã được thiết lập. Trình điều khiển có thể sử dụng nó để thực hiện khởi tạo bổ sung
  phải được thực hiện bằng lệnh HCI.
- xmit() chỉ cần ghi một khung vào liên kết vật lý.
- start_poll() là một điểm vào tùy chọn sẽ đặt phần cứng ở chế độ bỏ phiếu
  chế độ. Điều này chỉ phải được thực hiện nếu phần cứng sử dụng các cổng độc quyền hoặc một
  cơ chế hơi khác so với tiêu chuẩn HCI.
- dep_link_up() được gọi sau khi phát hiện mục tiêu p2p, để kết thúc
  thiết lập kết nối p2p với các thông số phần cứng cần được chuyển lại
  đến lõi nfc.
- dep_link_down() được gọi để đưa liên kết p2p xuống.
- target_from_gate() là một điểm vào tùy chọn để trả về các giao thức nfc
  tương ứng với một cổng độc quyền.
- Complete_target_discovered() là một điểm vào tùy chọn để cho phép trình điều khiển
  thực hiện xử lý độc quyền bổ sung cần thiết để tự động kích hoạt
  mục tiêu được phát hiện.
- im_transceive() phải được trình điều khiển triển khai nếu các lệnh HCI độc quyền
  được yêu cầu gửi dữ liệu tới thẻ. Một số loại thẻ sẽ yêu cầu tùy chỉnh
  các lệnh khác, các lệnh khác có thể được ghi bằng cách sử dụng các lệnh HCI tiêu chuẩn. Người lái xe
  có thể kiểm tra loại thẻ và thực hiện xử lý độc quyền hoặc trả về 1 để hỏi
  để xử lý tiêu chuẩn. Lệnh trao đổi dữ liệu phải được gửi
  không đồng bộ.
- tm_send() được gọi để gửi dữ liệu trong trường hợp kết nối p2p
- check_presence() là một điểm vào tùy chọn sẽ được gọi thường xuyên
  bởi lõi để kiểm tra xem thẻ đã kích hoạt có còn ở trường hay không. Nếu đây là
  không được triển khai, lõi sẽ không thể đẩy các sự kiện tag_lost tới người dùng
  không gian
- event_receured() được gọi để xử lý một sự kiện đến từ chip. Người lái xe
  có thể xử lý sự kiện hoặc trả về 1 để HCI thử xử lý tiêu chuẩn.

Trên đường dẫn rx, trình điều khiển có trách nhiệm đẩy các khung HCP đến HCI
sử dụng nfc_hci_recv_frame(). HCI sẽ đảm nhiệm việc tổng hợp lại và xử lý
Điều này phải được thực hiện từ một bối cảnh có thể ngủ.

Quản lý PHY
--------------

Việc quản lý liên kết vật lý (i2c, ...) được xác định theo cấu trúc sau::

cấu trúc nfc_phy_ops {
	int (*write)(void *dev_id, struct sk_buff *skb);
	int (*enable)(void *dev_id);
	khoảng trống (*disable)(void *dev_id);
  };

kích hoạt():
	bật phy (bật nguồn), sẵn sàng truyền dữ liệu
vô hiệu hóa():
	tắt phy
viết():
	Gửi khung dữ liệu tới chip. Lưu ý rằng để kích hoạt cao hơn
	các lớp như llc để lưu trữ khung để tái phát xạ, điều này
	chức năng không được thay đổi skb. Nó cũng không được trả về kết quả tích cực
	kết quả (trả về 0 nếu thành công, âm nếu thất bại).

Dữ liệu từ chip sẽ được gửi trực tiếp đến nfc_hci_recv_frame().

LLC
---

Giao tiếp giữa CPU và chip thường yêu cầu một số lớp liên kết
giao thức. Chúng được tách biệt dưới dạng các mô-đun được quản lý bởi lớp HCI. có
hiện có hai mô-đun: nop (chuyển thô) và shdlc.
Một LLC mới phải triển khai các chức năng sau::

cấu trúc nfc_llc_ops {
	void *(*init) (struct nfc_hci_dev *hdev, xmit_to_drv_t xmit_to_drv,
		       rcv_to_hci_t rcv_to_hci, int tx_headroom,
		       int tx_tailroom, int *rx_headroom, int *rx_tailroom,
		       llc_failure_t llc_failure);
	khoảng trống (*deinit) (struct nfc_llc *llc);
	int (*start) (struct nfc_llc *llc);
	int (*stop) (struct nfc_llc *llc);
	khoảng trống (*rcv_from_drv) (struct nfc_llc *llc, struct sk_buff *skb);
	int (*xmit_from_hci) (struct nfc_llc *llc, struct sk_buff *skb);
  };

init():
	phân bổ và khởi tạo bộ nhớ riêng của bạn
deinit():
	dọn dẹp
bắt đầu():
	thiết lập kết nối logic
dừng lại ():
	chấm dứt kết nối logic
RCv_from_drv():
	xử lý dữ liệu đến từ chip, đi tới HCI
xmit_from_hci():
	xử lý dữ liệu được gửi bởi HCI, đi vào chip

LLC phải được đăng ký với nfc trước khi có thể sử dụng. Làm điều đó bằng cách
đang gọi::

nfc_llc_register(const char *name, const struct nfc_llc_ops *ops);

Một lần nữa, hãy lưu ý rằng llc không xử lý liên kết vật lý. Vì thế nó rất
dễ dàng kết hợp bất kỳ liên kết vật lý nào với bất kỳ llc nào cho trình điều khiển chip nhất định.

Trình điều khiển đi kèm
----------------

Trình điều khiển dựa trên HCI dành cho NXP PN544, được kết nối qua bus I2C và sử dụng
shdlc được bao gồm.

Bối cảnh thực thi
------------------

Các bối cảnh thực hiện như sau:
- Bộ xử lý IRQ (IRQH):
nhanh, không ngủ được. gửi các khung hình đến HCI nơi chúng được chuyển đến
LLC hiện tại. Trong trường hợp shdlc, khung được xếp hàng trong hàng đợi shdlc rx.

- Công nhân máy nhà nước SHDLC (SMW)

Chỉ khi llc_shdlc được sử dụng: xử lý hàng đợi shdlc rx & tx.

Gửi phản hồi cmd HCI.

- Nhân viên HCI Tx Cmd (MSGTXWQ)

Tuần tự hóa việc thực thi các lệnh HCI.

Hoàn thành việc thực thi trong trường hợp hết thời gian phản hồi.

- Công nhân HCI Rx (MSGRXWQ)

Gửi các lệnh hoặc sự kiện HCI đến.

- Bối cảnh hệ thống từ cuộc gọi không gian người dùng (SYSCALL)

Bất kỳ điểm vào nào trong HCI được gọi từ NFC Core

Quy trình thực hiện lệnh HCI (sử dụng shdlc)
-----------------------------------------------

Việc thực thi lệnh HCI có thể dễ dàng được thực hiện đồng bộ bằng cách sử dụng
sau API::

int nfc_hci_send_cmd (struct nfc_hci_dev *hdev, cổng u8, u8 cmd,
			const u8 ZZ0000ZZ*skb)

API phải được gọi từ ngữ cảnh có thể ngủ. Hầu hết thời gian, điều này
sẽ là bối cảnh syscall. skb sẽ trả về kết quả đã nhận được trong
sự phản hồi.

Trong nội bộ, việc thực thi không đồng bộ. Vì vậy, tất cả những gì API làm là để xếp hàng
Lệnh HCI, thiết lập hàng đợi cục bộ trên ngăn xếp và wait_event() để hoàn thành.
Việc chờ đợi không bị gián đoạn vì nó được đảm bảo rằng lệnh sẽ
dù sao cũng hoàn thành sau một thời gian chờ ngắn.

Bối cảnh MSGTXWQ sau đó sẽ được lên lịch và gọi nfc_hci_msg_tx_work().
Hàm này sẽ loại bỏ lệnh đang chờ xử lý tiếp theo và gửi các đoạn HCP của nó
đến lớp thấp hơn là shdlc. Sau đó nó sẽ bắt đầu hẹn giờ
có thể hoàn thành lệnh với lỗi hết thời gian chờ nếu không có phản hồi.

Ngữ cảnh SMW được lên lịch và gọi nfc_shdlc_sm_work(). Chức năng này
xử lý việc đóng khung shdlc vào và ra. Nó sử dụng trình điều khiển xmit để gửi khung và
nhận các khung hình đến trong hàng đợi skb được điền từ trình xử lý IRQ của trình điều khiển.
Tải trọng khung SHDLC I(thông tin) là các đoạn HCP. Chúng được tổng hợp để
tạo thành các khung HCI hoàn chỉnh, có thể là phản hồi, lệnh hoặc sự kiện.

Phản hồi HCI được gửi ngay lập tức từ bối cảnh này để bỏ chặn
chờ thực hiện lệnh. Xử lý phản hồi liên quan đến việc gọi sự hoàn thành
cuộc gọi lại được cung cấp bởi nfc_hci_msg_tx_work() khi nó gửi lệnh.
Cuộc gọi lại hoàn thành sau đó sẽ đánh thức bối cảnh cuộc gọi chung.

Cũng có thể thực thi lệnh không đồng bộ bằng cách sử dụng API:: này

int tĩnh nfc_hci_execute_cmd_async(struct nfc_hci_dev *hdev, ống u8, u8 cmd,
				       const u8 *param, size_t param_len,
				       data_exchange_cb_t cb, void *cb_context)

Quy trình làm việc giống nhau, ngoại trừ lệnh gọi API sẽ trả về ngay lập tức và
lệnh gọi lại sẽ được gọi với kết quả từ ngữ cảnh SMW.

Quy trình làm việc nhận sự kiện hoặc lệnh HCI
------------------------------------------

Các lệnh hoặc sự kiện HCI không được gửi đi từ ngữ cảnh SMW. Thay vào đó, họ
được xếp hàng tới HCI rx_queue và sẽ được gửi đi từ nhân viên HCI rx
bối cảnh (MSGRXWQ). Điều này được thực hiện theo cách này để cho phép trình xử lý cmd hoặc sự kiện
để thực thi các lệnh khác (ví dụ: xử lý
Sự kiện NFC_HCI_EVT_TARGET_DISCOVERED từ PN544 yêu cầu phát hành một
ANY_GET_PARAMETER tới đầu đọc Một cổng để lấy thông tin về mục tiêu
điều đó đã được phát hiện).

Thông thường, một sự kiện như vậy sẽ được truyền tới NFC Core từ ngữ cảnh MSGRXWQ.

Quản lý lỗi
----------------

Các lỗi xảy ra đồng bộ với việc thực hiện yêu cầu Core NFC là
chỉ được trả về dưới dạng kết quả thực hiện của yêu cầu. Đây là những điều dễ dàng.

Lỗi xảy ra không đồng bộ (ví dụ: trong luồng xử lý giao thức nền)
phải được báo cáo sao cho các tầng lớp trên không thể không biết rằng có điều gì đó
đã sai dưới đây và biết rằng các sự kiện dự kiến có thể sẽ không bao giờ xảy ra.
Việc xử lý các lỗi này được thực hiện như sau:

- trình điều khiển (pn544) không gửi được khung đến: nó lưu lỗi như vậy
  rằng bất kỳ lệnh gọi trình điều khiển nào tiếp theo sẽ dẫn đến lỗi này. Sau đó nó
  gọi nfc_shdlc_recv_frame() tiêu chuẩn với đối số NULL để báo cáo
  vấn đề trên. shdlc lưu trữ trạng thái dính EREMOTEIO, trạng thái này sẽ kích hoạt
  SMW lần lượt báo cáo ở trên.

- SMW về cơ bản là một thread nền để xử lý shdlc vào và ra
  khung. Chủ đề này cũng sẽ kiểm tra trạng thái dính của shdlc và báo cáo cho HCI
  khi nó phát hiện ra nó không thể chạy được nữa vì không thể phục hồi được
  lỗi xảy ra trong shdlc hoặc thấp hơn. Nếu sự cố xảy ra trong quá trình shdlc
  kết nối, lỗi được báo cáo thông qua việc hoàn tất kết nối.

- HCI: nếu xảy ra lỗi HCI nội bộ (mất khung) hoặc HCI được báo cáo
  lỗi từ lớp thấp hơn, HCI sẽ hoàn thành quá trình thực thi hiện tại
  lệnh có lỗi đó hoặc thông báo trực tiếp cho NFC Core nếu không có lệnh nào
  thực thi.

- NFC Core: khi NFC Core được thông báo có lỗi từ bên dưới và quá trình bỏ phiếu được thực hiện
  đang hoạt động, nó sẽ gửi một sự kiện được phát hiện thẻ có danh sách thẻ trống cho người dùng
  không gian để cho nó biết rằng hoạt động thăm dò ý kiến sẽ không bao giờ có thể phát hiện được
  thẻ. Nếu bỏ phiếu không hoạt động và lỗi xảy ra, các cấp độ thấp hơn sẽ
  trả lại nó ở lần gọi tiếp theo.
