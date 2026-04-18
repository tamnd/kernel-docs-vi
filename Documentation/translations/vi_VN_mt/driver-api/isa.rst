.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/isa.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Trình điều khiển ISA
====================

Văn bản sau đây được phỏng theo thông điệp cam kết của lần đầu tiên
cam kết của tài xế xe buýt ISA của tác giả Rene Herman.

Trong cuộc thảo luận gần đây về "trình điều khiển isa sử dụng thiết bị nền tảng"
đã chỉ ra rằng trình điều khiển ISA (ALSA) gặp phải vấn đề không có
tùy chọn không tải được trình điều khiển (đúng hơn là đăng ký thiết bị) khi không
tìm thấy phần cứng của họ do lỗi thăm dò() không được thông qua
thông qua mô hình điều khiển. Trong quá trình đó, tôi đã đề xuất một giải pháp riêng
Xe buýt ISA có thể là tốt nhất; Russell King đồng ý và đề nghị chiếc xe buýt này có thể
sử dụng phương thức .match() để khám phá thiết bị thực tế.

Phần đính kèm thực hiện điều này. Đối với ISA cũ không thể phát hiện được (nói chung) này
chỉ phần cứng của chính trình điều khiển mới có thể thực hiện việc khám phá, điều này khác với
platform_bus, isa_bus này cũng phân phối match() cho tới
người lái xe.

Một điểm khác biệt nữa: các thiết bị này chỉ tồn tại trong mô hình trình điều khiển do
cho trình điều khiển tạo ra chúng bởi vì nó có thể muốn điều khiển chúng, nghĩa là
rằng tất cả việc tạo thiết bị cũng đã được thực hiện nội bộ.

Mô hình sử dụng mà nó cung cấp rất hay và đã được xác nhận từ ALSA
bên cạnh Takashi Iwai và Jaroslav Kysela. Mô-đun trình điều khiển ALSA_init's
bây giờ (đối với trình điều khiển chỉ dành cho oldisa) trở thành::

int tĩnh __init alsa_card_foo_init(void)
	{
		trả về isa_register_driver(&snd_foo_isa_driver, SNDRV_CARDS);
	}

khoảng trống tĩnh __exit alsa_card_foo_exit(void)
	{
		isa_unregister_driver(&snd_foo_isa_driver);
	}

Do đó, khá giống các mẫu xe buýt khác. Điều này loại bỏ rất nhiều
mã init trùng lặp từ trình điều khiển ALSA ISA.

Cấu trúc isa_driver được truyền vào là cấu trúc trình điều khiển thông thường nhúng một
struct device_driver, thăm dò/xóa/tắt/tạm dừng/tiếp tục bình thường
cuộc gọi lại và như đã chỉ ra rằng cuộc gọi lại .match.

"SNDRV_CARDS" mà bạn thấy được truyền vào là "unsign int ndev"
tham số, cho biết có bao nhiêu thiết bị cần tạo và gọi các phương thức của chúng tôi
với.

Lệnh gọi lại platform_driver được gọi với thông số platform_device;
lệnh gọi lại isa_driver đang được gọi trực tiếp bằng cặp ZZ0000ZZ -- với việc tạo thiết bị hoàn toàn
bên trong xe buýt sẽ sạch sẽ hơn nhiều để không bị rò rỉ isa_dev khi đi qua
họ ở trong tất cả. Id là thứ duy nhất chúng ta muốn ngoài cái
struct thiết bị nào đó và nó làm cho mã đẹp hơn trong các lệnh gọi lại như
tốt.

Với lệnh gọi lại .match() bổ sung này, trình điều khiển ISA có tất cả các tùy chọn. Nếu
ALSA muốn giữ nguyên trạng thái không tải cũ, nó có thể dính tất cả
của .probe cũ trong .match, điều này sẽ chỉ giúp chúng được đăng ký sau
tất cả mọi thứ đã được tìm thấy hiện diện và tính toán. Nếu nó muốn
hành vi luôn tải như nó vô tình làm một lúc sau
chuyển sang thiết bị nền tảng, nó có thể không cung cấp .match() và
làm mọi thứ trong .probe() như trước.

Nếu đúng như vậy, như Takashi Iwai đã đề xuất trước đó như một cách làm theo
mô hình từ xe buýt saner chặt chẽ hơn, muốn tải khi liên kết sau
có thể thành công, nó có thể sử dụng .match() cho các điều kiện tiên quyết
(chẳng hạn như kiểm tra xem người dùng có muốn kích hoạt thẻ và cổng/irq/dma đó
các giá trị đã được chuyển vào) và .probe() cho mọi thứ khác. Đây là
mẫu mã đẹp nhất.

Đến mã...

Điều này chỉ xuất khẩu hai chức năng; isa_{,un}register_driver().

isa_register_driver() đăng ký struct device_driver, sau đó
lặp lại các thiết bị được tạo trong ndev và đăng ký chúng.
Điều này làm cho phương thức khớp xe buýt được gọi cho chúng, đó là::

int isa_bus_match(thiết bị cấu trúc *dev, struct device_driver *driver)
	{
		struct isa_driver *isa_driver = to_isa_driver(driver);

if (dev->platform_data == isa_driver) {
			if (!isa_driver->match ||
				isa_driver->match(dev, to_isa_dev(dev)->id))
				trả về 1;
			dev->platform_data = NULL;
		}
		trả về 0;
	}

Điều đầu tiên cần làm là kiểm tra xem thiết bị này có thực sự là một trong số này không
thiết bị của trình điều khiển bằng cách xem liệu con trỏ platform_data của thiết bị có được đặt hay không
cho người lái xe này. Các thiết bị nền tảng so sánh các chuỗi, nhưng chúng ta không cần
làm điều đó với mọi thứ đều là nội bộ, vì vậy việc lạm dụng isa_register_driver()
dev->platform_data làm con trỏ isa_driver mà chúng ta có thể kiểm tra tại đây.
Tôi tin rằng platform_data có sẵn cho việc này, nhưng nếu không, hãy di chuyển
con trỏ isa_driver tới cấu trúc riêng tư isa_dev tất nhiên là ổn vì
tốt.

Sau đó, nếu trình điều khiển không cung cấp .match thì nó sẽ khớp. Nếu vậy,
phương thức driver match() được gọi để xác định kết quả khớp.

Nếu nó khớp với ZZ0000ZZ, dev->platform_data sẽ được đặt lại để biểu thị điều này cho
isa_register_driver sau đó có thể hủy đăng ký lại thiết bị.

Nếu trong suốt quá trình này xảy ra lỗi hoặc không có thiết bị nào khớp
mọi thứ đều được sao lưu lại và lỗi hoặc -ENODEV được trả về.

isa_unregister_driver() chỉ hủy đăng ký các thiết bị phù hợp và
bản thân người lái xe.

module_isa_driver là macro trợ giúp cho trình điều khiển ISA không thực hiện được
bất cứ điều gì đặc biệt trong mô-đun init/exit. Điều này giúp loại bỏ rất nhiều
mã soạn sẵn. Mỗi mô-đun chỉ có thể sử dụng macro này một lần và gọi
nó thay thế module_init và module_exit.

max_num_isa_dev là macro để xác định số lượng tối đa có thể của
Các thiết bị ISA có thể được đăng ký trong không gian địa chỉ cổng I/O nhất định
phạm vi địa chỉ của thiết bị ISA.
