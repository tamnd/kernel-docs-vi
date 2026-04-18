.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-subdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị phụ V4L2
----------------

Nhiều trình điều khiển cần giao tiếp với các thiết bị phụ. Các thiết bị này có thể làm tất cả
loại nhiệm vụ, nhưng thông thường nhất là chúng xử lý việc trộn âm thanh và/hoặc video,
mã hóa hoặc giải mã. Đối với webcam các thiết bị phụ phổ biến là cảm biến và camera
bộ điều khiển.

Thông thường đây là những thiết bị I2C, nhưng không nhất thiết phải như vậy. Để cung cấp các
trình điều khiển có giao diện nhất quán với các thiết bị phụ này
Cấu trúc ZZ0000ZZ (v4l2-subdev.h) đã được tạo.

Mỗi trình điều khiển thiết bị phụ phải có cấu trúc ZZ0000ZZ. Cấu trúc này
có thể độc lập cho các thiết bị phụ đơn giản hoặc nó có thể được nhúng trong một thiết bị lớn hơn
struct nếu cần lưu trữ thêm thông tin trạng thái. Thông thường có một
cấu trúc thiết bị cấp thấp (ví dụ ZZ0004ZZ) chứa dữ liệu thiết bị dưới dạng
thiết lập bởi kernel. Nên lưu trữ con trỏ đó ở chế độ riêng tư
dữ liệu của ZZ0001ZZ sử dụng ZZ0002ZZ. Điều đó làm cho
thật dễ dàng để chuyển từ ZZ0003ZZ sang xe buýt cấp thấp thực tế cụ thể
dữ liệu thiết bị.

Bạn cũng cần một cách để chuyển từ cấu trúc cấp thấp sang ZZ0000ZZ.
Đối với cấu trúc i2c_client thông thường, lệnh gọi i2c_set_clientdata() được sử dụng để lưu trữ
một con trỏ ZZ0001ZZ, đối với các xe buýt khác, bạn có thể phải sử dụng con trỏ khác
phương pháp.

Các cầu nối cũng có thể cần lưu trữ dữ liệu riêng tư của mỗi nhóm con, chẳng hạn như một con trỏ tới
dữ liệu riêng tư dành riêng cho mỗi subdev. Cấu trúc ZZ0000ZZ
cung cấp dữ liệu riêng tư của máy chủ cho mục đích đó có thể được truy cập bằng
ZZ0001ZZ và ZZ0002ZZ.

Từ góc độ trình điều khiển cầu nối, bạn tải mô-đun thiết bị phụ và bằng cách nào đó
lấy con trỏ ZZ0000ZZ. Đối với các thiết bị i2c, điều này thật dễ dàng: bạn gọi
ZZ0001ZZ. Đối với các xe buýt khác, điều tương tự cũng cần phải được thực hiện.
Các chức năng trợ giúp tồn tại cho các thiết bị phụ trên bus I2C thực hiện hầu hết việc này
công việc khó khăn cho bạn.

Mỗi ZZ0000ZZ chứa các con trỏ hàm mà trình điều khiển thiết bị phụ
có thể thực hiện (hoặc để lại ZZ0001ZZ nếu không áp dụng được). Vì các thiết bị phụ có thể
làm rất nhiều việc khác nhau và bạn không muốn kết thúc với một cấu trúc hoạt động khổng lồ
trong đó chỉ có một số ít hoạt động được triển khai phổ biến, các con trỏ hàm
được sắp xếp theo danh mục và mỗi danh mục có cấu trúc ops riêng.

Cấu trúc ops cấp cao nhất chứa các con trỏ tới các cấu trúc ops danh mục, trong đó
có thể là NULL nếu trình điều khiển subdev không hỗ trợ bất kỳ thứ gì thuộc danh mục đó.

Nó trông như thế này:

.. code-block:: c

	struct v4l2_subdev_core_ops {
		int (*log_status)(struct v4l2_subdev *sd);
		int (*init)(struct v4l2_subdev *sd, u32 val);
		...
	};

	struct v4l2_subdev_tuner_ops {
		...
	};

	struct v4l2_subdev_audio_ops {
		...
	};

	struct v4l2_subdev_video_ops {
		...
	};

	struct v4l2_subdev_pad_ops {
		...
	};

	struct v4l2_subdev_ops {
		const struct v4l2_subdev_core_ops  *core;
		const struct v4l2_subdev_tuner_ops *tuner;
		const struct v4l2_subdev_audio_ops *audio;
		const struct v4l2_subdev_video_ops *video;
		const struct v4l2_subdev_pad_ops *video;
	};

Các hoạt động cốt lõi là chung cho tất cả các nhà phát triển phụ, các danh mục khác được triển khai
tùy thuộc vào thiết bị phụ. Ví dụ. một thiết bị video không thể hỗ trợ
hoạt động âm thanh và ngược lại.

Thiết lập này giới hạn số lượng con trỏ hàm trong khi vẫn làm cho nó dễ dàng
để thêm các hoạt động và danh mục mới.

Trình điều khiển thiết bị phụ khởi tạo cấu trúc ZZ0000ZZ bằng cách sử dụng:

ZZ0000ZZ
	(ZZ0001ZZ, &\ZZ0002ZZ).


Sau đó, bạn cần khởi tạo ZZ0000ZZ->name bằng một
tên duy nhất và đặt chủ sở hữu mô-đun. Điều này được thực hiện cho bạn nếu bạn sử dụng
chức năng trợ giúp i2c.

Nếu cần tích hợp với khung phương tiện, bạn phải khởi tạo
Cấu trúc ZZ0000ZZ được nhúng trong cấu trúc ZZ0001ZZ
(trường thực thể) bằng cách gọi ZZ0002ZZ, nếu thực thể có
miếng đệm:

.. code-block:: c

	struct media_pad *pads = &my_sd->pads;
	int err;

	err = media_entity_pads_init(&sd->entity, npads, pads);

Mảng đệm phải được khởi tạo trước đó. Không cần thiết phải
thiết lập thủ công các trường tên và hàm struct media_entity, nhưng
trường sửa đổi phải được khởi tạo nếu cần.

Một tham chiếu đến thực thể sẽ được tự động thu thập/giải phóng khi
nút thiết bị subdev (nếu có) được mở/đóng.

Đừng quên dọn sạch thực thể phương tiện trước khi thiết bị phụ bị hủy:

.. code-block:: c

	media_entity_cleanup(&sd->entity);

Nếu trình điều khiển thiết bị phụ triển khai các miếng đệm chìm, trình điều khiển subdev có thể đặt
trường link_validate trong ZZ0000ZZ để cung cấp liên kết riêng
chức năng xác nhận. Đối với mỗi liên kết trong đường dẫn, bảng link_validate
hoạt động của đầu cuối sink của liên kết được gọi. Trong cả hai trường hợp người lái xe đều
vẫn chịu trách nhiệm xác nhận tính đúng đắn của cấu hình định dạng
giữa các thiết bị phụ và các nút video.

Nếu link_validate op không được đặt, chức năng mặc định
ZZ0000ZZ được sử dụng thay thế. Chức năng này
đảm bảo rằng chiều rộng, chiều cao và mã pixel bus phương tiện bằng nhau trên cả hai nguồn
và phần chìm của liên kết. Trình điều khiển Subdev cũng được tự do sử dụng chức năng này để
thực hiện các kiểm tra nêu trên ngoài việc kiểm tra của chính họ.

Đăng ký subdev
~~~~~~~~~~~~~~~~~~~

Hiện tại có hai cách để đăng ký thiết bị con với lõi V4L2. các
khả năng đầu tiên (truyền thống) là có các thiết bị con được đăng ký bởi bridge
trình điều khiển. Điều này có thể được thực hiện khi người điều khiển cầu có thông tin đầy đủ
về các thiết bị con được kết nối với nó và biết chính xác thời điểm đăng ký chúng. Cái này
thường là trường hợp của các thiết bị con nội bộ, như bộ xử lý dữ liệu video
trong SoC hoặc bo mạch PCI(e) phức tạp, cảm biến camera trong camera USB hoặc được kết nối
tới SoC, chuyển thông tin về chúng tới các trình điều khiển cầu nối, thường là trong
dữ liệu nền tảng.

Tuy nhiên, cũng có những trường hợp các thiết bị phụ phải được đăng ký
không đồng bộ với các thiết bị cầu nối. Một ví dụ về cấu hình như vậy là Thiết bị
Hệ thống dựa trên cây nơi thông tin về các thiết bị con được cung cấp cho
hệ thống độc lập với các thiết bị cầu nối, ví dụ: khi thiết bị con được xác định
trong DT dưới dạng nút thiết bị I2C. API được sử dụng trong trường hợp thứ hai này được mô tả thêm
bên dưới.

Việc sử dụng phương thức đăng ký này hay phương thức đăng ký khác chỉ ảnh hưởng đến quá trình thăm dò,
Tương tác cầu nối-thiết bị phụ trong thời gian chạy trong cả hai trường hợp đều giống nhau.

Đăng ký thiết bị phụ đồng bộ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong trường hợp ZZ0001ZZ, trình điều khiển thiết bị (cầu nối) cần đăng ký
ZZ0000ZZ với v4l2_device:

ZZ0000ZZ
	(ZZ0001ZZ, ZZ0002ZZ).

Điều này có thể thất bại nếu mô-đun subdev biến mất trước khi nó được đăng ký.
Sau khi hàm này được gọi thành công, trường subdev->dev trỏ tới
ZZ0000ZZ.

Nếu thiết bị mẹ v4l2_device có trường mdev không phải NULL thì thiết bị phụ
thực thể sẽ được đăng ký tự động với thiết bị đa phương tiện.

Bạn có thể hủy đăng ký một thiết bị phụ bằng cách sử dụng:

ZZ0000ZZ
	(ZZ0001ZZ).

Sau đó, mô-đun subdev có thể được tải xuống và
ZZ0000ZZ->dev == ZZ0001ZZ.

.. _media-registering-async-subdevs:

Đăng ký thiết bị phụ không đồng bộ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong trường hợp ZZ0003ZZ, việc thăm dò thiết bị con có thể được gọi độc lập với
sự sẵn có của trình điều khiển cầu. Trình điều khiển thiết bị phụ sau đó phải xác minh xem
tất cả các yêu cầu để thăm dò thành công đều được đáp ứng. Điều này có thể bao gồm một
kiểm tra tính khả dụng của đồng hồ chính. Nếu bất kỳ điều kiện nào không được thỏa mãn
người lái xe có thể quyết định trả lại ZZ0002ZZ để yêu cầu kiểm tra lại
những nỗ lực. Khi tất cả các điều kiện được đáp ứng, thiết bị phụ sẽ được đăng ký bằng cách sử dụng
chức năng ZZ0000ZZ. Hủy đăng ký là
được thực hiện bằng lệnh gọi ZZ0001ZZ. Thiết bị phụ
được đăng ký theo cách này sẽ được lưu trữ trong danh sách toàn cầu các thiết bị con, sẵn sàng
được người lái cầu đón.

Trình điều khiển phải hoàn thành tất cả quá trình khởi tạo thiết bị phụ trước khi
đăng ký nó bằng ZZ0000ZZ, bao gồm
kích hoạt PM thời gian chạy. Điều này là do thiết bị phụ có thể truy cập được
ngay khi nó được đăng ký.

Trình thông báo thiết bị phụ không đồng bộ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trình điều khiển cầu lần lượt phải đăng ký một đối tượng thông báo. Việc này được thực hiện
bằng cách sử dụng cuộc gọi ZZ0000ZZ. Để hủy đăng ký người thông báo,
tài xế phải gọi ZZ0001ZZ. Trước khi giải phóng bộ nhớ
của một trình thông báo chưa đăng ký, nó phải được dọn sạch bằng cách gọi
ZZ0002ZZ.

Trước khi đăng ký trình thông báo, người điều khiển cầu nối phải thực hiện hai việc: thứ nhất,
trình thông báo phải được khởi tạo bằng ZZ0000ZZ.  Thứ hai,
trình điều khiển cầu sau đó có thể bắt đầu tạo danh sách các bộ mô tả kết nối không đồng bộ
mà thiết bị cầu nối cần cho
hoạt động. ZZ0001ZZ,
ZZ0002ZZ và ZZ0003ZZ

Bộ mô tả kết nối không đồng bộ mô tả các kết nối với các thiết bị phụ bên ngoài
trình điều khiển chưa được thăm dò. Dựa trên kết nối không đồng bộ, dữ liệu phương tiện
hoặc liên kết phụ trợ có thể được tạo khi thiết bị phụ liên quan trở nên
có sẵn. Có thể có một hoặc nhiều kết nối không đồng bộ với một thiết bị phụ nhất định nhưng
điều này chưa được biết tại thời điểm thêm kết nối vào trình thông báo. Không đồng bộ
các kết nối bị ràng buộc khi tìm thấy từng thiết bị phụ không đồng bộ phù hợp.

Trình thông báo thiết bị phụ không đồng bộ cho các thiết bị phụ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trình điều khiển đăng ký một thiết bị phụ không đồng bộ cũng có thể đăng ký một
trình thông báo không đồng bộ. Đây được gọi là trình thông báo thiết bị phụ không đồng bộ và
Quá trình này tương tự như quá trình của trình điều khiển cầu ngoại trừ trình thông báo
thay vào đó được khởi tạo bằng ZZ0000ZZ. Một thiết bị phụ
trình thông báo chỉ có thể hoàn thành sau khi thiết bị V4L2 khả dụng, tức là có
một đường dẫn thông qua các thiết bị phụ không đồng bộ và trình thông báo tới trình thông báo không phải là
trình thông báo thiết bị phụ không đồng bộ.

Trình trợ giúp đăng ký thiết bị phụ không đồng bộ cho trình điều khiển cảm biến máy ảnh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

ZZ0000ZZ là chức năng trợ giúp cho cảm biến
trình điều khiển đăng ký kết nối không đồng bộ của riêng họ, nhưng nó cũng đăng ký trình thông báo
và đăng ký thêm các kết nối không đồng bộ cho các thiết bị ống kính và đèn flash được tìm thấy trong
phần sụn. Trình thông báo cho thiết bị phụ chưa được đăng ký và được dọn sạch bằng
thiết bị phụ không đồng bộ, sử dụng ZZ0001ZZ.

Ví dụ về trình thông báo thiết bị phụ không đồng bộ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các hàm này phân bổ một bộ mô tả kết nối không đồng bộ thuộc loại struct
ZZ0000ZZ được nhúng trong cấu trúc dành riêng cho trình điều khiển. &cấu trúc
ZZ0001ZZ sẽ là thành viên đầu tiên của cấu trúc này:

.. code-block:: c

	struct my_async_connection {
		struct v4l2_async_connection asc;
		...
	};

	struct my_async_connection *my_asc;
	struct fwnode_handle *ep;

	...

	my_asc = v4l2_async_nf_add_fwnode_remote(&notifier, ep,
						 struct my_async_connection);
	fwnode_handle_put(ep);

	if (IS_ERR(my_asc))
		return PTR_ERR(my_asc);

Lệnh gọi lại của trình thông báo thiết bị phụ không đồng bộ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Sau đó, lõi V4L2 sẽ sử dụng các bộ mô tả kết nối này để khớp không đồng bộ
thiết bị con đã đăng ký cho họ. Nếu phát hiện thấy kết quả trùng khớp, trình thông báo ZZ0000ZZ
cuộc gọi lại được gọi. Sau khi tất cả các kết nối đã được ràng buộc, .complete()
cuộc gọi lại được gọi. Khi một kết nối bị ngắt khỏi hệ thống,
Phương thức ZZ0001ZZ được gọi. Tất cả ba lệnh gọi lại đều là tùy chọn.

Trình điều khiển có thể lưu trữ bất kỳ loại dữ liệu tùy chỉnh nào trong trình điều khiển cụ thể của họ
Vỏ bọc ZZ0000ZZ. Nếu bất kỳ dữ liệu nào trong số đó yêu cầu đặc biệt
xử lý khi cấu trúc được giải phóng, trình điều khiển phải triển khai ZZ0002ZZ
gọi lại thông báo. Khung công tác sẽ gọi nó ngay trước khi giải phóng
ZZ0001ZZ.

Gọi các hoạt động subdev
~~~~~~~~~~~~~~~~~~~~~~~~~

Ưu điểm của việc sử dụng ZZ0000ZZ là nó có cấu trúc chung và
không chứa bất kỳ kiến thức nào về phần cứng cơ bản. Vì vậy người lái xe có thể
chứa một số nhà phát triển con sử dụng bus I2C, nhưng cũng có một nhà phát triển con sử dụng bus I2C.
được điều khiển thông qua các chân GPIO. Sự khác biệt này chỉ có liên quan khi thiết lập
thiết bị được bật lên, nhưng khi subdev được đăng ký thì nó hoàn toàn trong suốt.

Khi subdev đã được đăng ký, bạn có thể gọi hàm ops
trực tiếp:

.. code-block:: c

	err = sd->ops->core->g_std(sd, &norm);

nhưng tốt hơn và dễ dàng hơn khi sử dụng macro này:

.. code-block:: c

	err = v4l2_subdev_call(sd, core, g_std, &norm);

Macro sẽ thực hiện kiểm tra con trỏ ZZ0004ZZ đúng và trả về ZZ0005ZZ
nếu ZZ0000ZZ là ZZ0006ZZ, ZZ0007ZZ nếu một trong hai
ZZ0001ZZ->core hoặc ZZ0002ZZ->core->g_std là ZZ0008ZZ, hoặc kết quả thực tế của
ZZ0003ZZ->ops->core->g_std op.

Cũng có thể gọi tất cả hoặc một tập hợp con của các thiết bị phụ:

.. code-block:: c

	v4l2_device_call_all(v4l2_dev, 0, core, g_std, &norm);

Bất kỳ nhà phát triển con nào không hỗ trợ hoạt động này đều bị bỏ qua và kết quả lỗi là
bị phớt lờ. Nếu bạn muốn kiểm tra lỗi, hãy sử dụng:

.. code-block:: c

	err = v4l2_device_call_until_err(v4l2_dev, 0, core, g_std, &norm);

Bất kỳ lỗi nào ngoại trừ ZZ0000ZZ sẽ thoát khỏi vòng lặp có lỗi đó. Nếu không
xảy ra lỗi (ngoại trừ ZZ0001ZZ), sau đó trả về 0.

Đối số thứ hai cho cả hai cuộc gọi là ID nhóm. Nếu là 0 thì tất cả các nhà phát triển phụ đều
được gọi. Nếu khác 0 thì chỉ những người có ID nhóm khớp với giá trị đó mới
được gọi. Trước khi trình điều khiển cầu đăng ký một subdev, nó có thể thiết lập
ZZ0000ZZ->grp_id thành bất kỳ giá trị nào nó muốn (là 0 x
mặc định). Giá trị này thuộc sở hữu của trình điều khiển cầu nối và trình điều khiển thiết bị phụ
sẽ không bao giờ sửa đổi hoặc sử dụng nó.

ID nhóm cung cấp cho trình điều khiển cầu nối nhiều quyền kiểm soát hơn về cách gọi lại.
Ví dụ: có thể có nhiều chip âm thanh trên một bo mạch, mỗi chip có khả năng
thay đổi âm lượng. Nhưng thông thường chỉ có một cái sẽ thực sự được sử dụng khi
người dùng muốn thay đổi âm lượng. Bạn có thể đặt ID nhóm cho subdev đó thành
ví dụ: AUDIO_CONTROLLER và chỉ định đó làm giá trị ID nhóm khi gọi
ZZ0000ZZ. Điều đó đảm bảo rằng nó sẽ chỉ đi đến subdev
cái đó cần nó.

Nếu thiết bị phụ cần thông báo cho thiết bị mẹ v4l2_device của nó về một sự kiện thì
nó có thể gọi ZZ0000ZZ. Kiểm tra macro này
liệu có lệnh gọi lại ZZ0001ZZ được xác định hay không và trả về ZZ0002ZZ nếu không.
Nếu không, kết quả của lệnh gọi ZZ0003ZZ sẽ được trả về.

Không gian người dùng thiết bị phụ V4L2 API
-----------------------------

Trình điều khiển cầu nối theo truyền thống hiển thị một hoặc nhiều nút video tới không gian người dùng,
và điều khiển các thiết bị con thông qua các hoạt động ZZ0000ZZ trong
đáp ứng với các hoạt động của nút video. Điều này che giấu sự phức tạp của cơ bản
phần cứng từ các ứng dụng. Đối với các thiết bị phức tạp, việc kiểm soát chi tiết hơn
thiết bị hơn những gì các nút video cung cấp có thể được yêu cầu. Trong những trường hợp đó, cầu
trình điều khiển triển khai ZZ0001ZZ có thể
chọn thực hiện các hoạt động của thiết bị con có thể truy cập trực tiếp từ không gian người dùng.

Các nút thiết bị có tên ZZ0000ZZ\ ZZ0003ZZ có thể được tạo trong ZZ0001ZZ để truy cập
thiết bị phụ trực tiếp. Nếu thiết bị phụ hỗ trợ cấu hình không gian người dùng trực tiếp
nó phải đặt cờ ZZ0002ZZ trước khi được đăng ký.

Sau khi đăng ký thiết bị phụ, trình điều khiển ZZ0000ZZ có thể tạo
nút thiết bị cho tất cả các thiết bị phụ đã đăng ký được đánh dấu bằng
ZZ0002ZZ bằng cách gọi
ZZ0001ZZ. Các nút thiết bị đó sẽ được
tự động bị xóa khi các thiết bị phụ chưa được đăng ký.

Nút thiết bị xử lý một tập hợp con của V4L2 API.

ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ,
ZZ0003ZZ,
ZZ0004ZZ,
ZZ0005ZZ và
ZZ0006ZZ:

Các điều khiển ioctls giống hệt với các điều khiển được xác định trong V4L2. Họ
	hành xử giống hệt nhau, ngoại trừ duy nhất là họ chỉ giải quyết
	điều khiển được thực hiện trong thiết bị phụ. Tùy thuộc vào người lái xe, những
	các điều khiển cũng có thể được truy cập thông qua một (hoặc một số) thiết bị V4L2
	nút.

ZZ0000ZZ,
ZZ0001ZZ và
ZZ0002ZZ

Các sự kiện ioctls giống hệt với các sự kiện được xác định trong V4L2. Họ
	hành xử giống hệt nhau, ngoại trừ duy nhất là họ chỉ giải quyết
	các sự kiện do thiết bị phụ tạo ra. Tùy thuộc vào người lái xe, những
	các sự kiện cũng có thể được báo cáo bởi một (hoặc một số) nút thiết bị V4L2.

Trình điều khiển thiết bị phụ muốn sử dụng sự kiện cần phải đặt
	ZZ0002ZZ ZZ0000ZZ.flags trước khi đăng ký
	thiết bị phụ. Sau khi đăng ký, các sự kiện có thể được xếp hàng đợi như bình thường trên
	Nút thiết bị ZZ0001ZZ.devnode.

Để hỗ trợ chính xác các sự kiện, thao tác với tệp ZZ0000ZZ cũng được thực hiện
	được thực hiện.

Ioctl riêng tư

Tất cả ioctls không có trong danh sách trên sẽ được chuyển trực tiếp đến thiết bị phụ
	trình điều khiển thông qua hoạt động core::ioctl.

Không gian người dùng thiết bị phụ chỉ đọc API
----------------------------------

Trình điều khiển cầu nối điều khiển các thiết bị con được kết nối của chúng thông qua các cuộc gọi trực tiếp tới
kernel API được thực hiện bằng cấu trúc ZZ0000ZZ thường không
muốn không gian người dùng có thể thay đổi các tham số tương tự thông qua thiết bị con
nút thiết bị và do đó thường không đăng ký bất kỳ nút nào.

Đôi khi việc báo cáo tới không gian người dùng thiết bị con hiện tại sẽ rất hữu ích
cấu hình thông qua API chỉ đọc, không cho phép các ứng dụng
thay đổi các thông số thiết bị nhưng cho phép giao tiếp với thiết bị con
nút để kiểm tra chúng.

Ví dụ: để triển khai máy ảnh dựa trên chụp ảnh tính toán, không gian người dùng
cần biết cấu hình cảm biến camera chi tiết (về vấn đề bỏ qua,
gộp, cắt xén và chia tỷ lệ) cho từng độ phân giải đầu ra được hỗ trợ. Để hỗ trợ
những trường hợp sử dụng như vậy, trình điều khiển cầu nối có thể hiển thị các hoạt động của thiết bị con tới không gian người dùng
thông qua API chỉ đọc.

Để tạo một nút thiết bị chỉ đọc cho tất cả các thiết bị con đã đăng ký với
Bộ ZZ0002ZZ thì driver ZZ0000ZZ nên gọi
ZZ0001ZZ.

Quyền truy cập vào các ioctls sau dành cho ứng dụng không gian người dùng bị hạn chế trên
các nút thiết bị phụ được đăng ký với
ZZ0000ZZ.

ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ:

Các ioctl này chỉ được phép trên nút thiết bị con chỉ đọc
	cho ZZ0000ZZ
	định dạng và lựa chọn hình chữ nhật.

ZZ0000ZZ,
ZZ0001ZZ,
ZZ0002ZZ:

Những ioctl này không được phép trên nút thiết bị con chỉ đọc.

Trong trường hợp ioctl không được phép hoặc định dạng cần sửa đổi được đặt thành
ZZ0000ZZ, lõi trả về mã lỗi âm và
biến errno được đặt thành ZZ0001ZZ.

Trình điều khiển thiết bị phụ I2C
----------------------

Vì các trình điều khiển này rất phổ biến nên có sẵn các chức năng trợ giúp đặc biệt để
dễ dàng sử dụng các trình điều khiển này (ZZ0000ZZ).

Phương pháp được đề xuất để thêm hỗ trợ ZZ0000ZZ vào trình điều khiển I2C
là nhúng cấu trúc ZZ0001ZZ vào cấu trúc trạng thái
được tạo cho mỗi phiên bản thiết bị I2C. Các thiết bị rất đơn giản không có trạng thái
struct và trong trường hợp đó bạn có thể tạo trực tiếp ZZ0002ZZ.

Cấu trúc trạng thái điển hình sẽ trông như thế này (trong đó 'chipname' được thay thế bằng
tên của chip):

.. code-block:: c

	struct chipname_state {
		struct v4l2_subdev sd;
		...  /* additional state fields */
	};

Khởi tạo cấu trúc ZZ0000ZZ như sau:

.. code-block:: c

	v4l2_i2c_subdev_init(&state->sd, client, subdev_ops);

Chức năng này sẽ điền vào tất cả các trường của ZZ0000ZZ để đảm bảo rằng
ZZ0001ZZ và i2c_client đều trỏ đến nhau.

Bạn cũng nên thêm một hàm nội tuyến trợ giúp để đi từ ZZ0000ZZ
con trỏ tới cấu trúc chipname_state:

.. code-block:: c

	static inline struct chipname_state *to_state(struct v4l2_subdev *sd)
	{
		return container_of(sd, struct chipname_state, sd);
	}

Sử dụng công cụ này để chuyển từ cấu trúc ZZ0000ZZ sang ZZ0001ZZ
cấu trúc:

.. code-block:: c

	struct i2c_client *client = v4l2_get_subdevdata(sd);

Và điều này sẽ chuyển từ cấu trúc ZZ0001ZZ sang cấu trúc ZZ0000ZZ:

.. code-block:: c

	struct v4l2_subdev *sd = i2c_get_clientdata(client);

Đảm bảo gọi
ZZ0000ZZ\ (ZZ0001ZZ)
khi lệnh gọi lại ZZ0002ZZ được gọi. Thao tác này sẽ hủy đăng ký thiết bị phụ
từ người lái cầu. Có thể gọi điều này một cách an toàn ngay cả khi thiết bị phụ đã được
chưa bao giờ đăng ký.

Bạn cần phải làm điều này vì khi bridge driver phá hủy adapter i2c
các cuộc gọi lại ZZ0002ZZ được gọi của các thiết bị i2c trên bộ chuyển đổi đó.
Sau đó, cấu trúc v4l2_subdev tương ứng không hợp lệ, vì vậy chúng
phải được hủy đăng ký trước. Đang gọi
ZZ0000ZZ\ (ZZ0001ZZ)
từ cuộc gọi lại ZZ0003ZZ đảm bảo rằng việc này luôn được thực hiện chính xác.


Trình điều khiển cầu nối cũng có một số chức năng trợ giúp mà nó có thể sử dụng:

.. code-block:: c

	struct v4l2_subdev *sd = v4l2_i2c_new_subdev(v4l2_dev, adapter,
					"module_foo", "chipid", 0x36, NULL);

Cái này tải mô-đun đã cho (có thể là ZZ0001ZZ nếu không cần tải mô-đun nào)
và gọi ZZ0000ZZ với ZZ0002ZZ đã cho và
đối số chip/địa chỉ. Nếu mọi việc suôn sẻ thì nó sẽ đăng ký subdev với
v4l2_device.

Bạn cũng có thể sử dụng đối số cuối cùng của ZZ0000ZZ để chuyển
một mảng các địa chỉ I2C có thể có mà nó cần thăm dò. Các địa chỉ thăm dò này
chỉ được sử dụng nếu đối số trước đó là 0. Đối số khác 0 có nghĩa là bạn
biết chính xác địa chỉ i2c nên trong trường hợp đó sẽ không có việc thăm dò nào diễn ra.

Cả hai hàm đều trả về ZZ0000ZZ nếu có sự cố.

Lưu ý rằng chipid bạn chuyển tới ZZ0000ZZ thường là
giống như tên mô-đun. Nó cho phép bạn chỉ định một biến thể chip, ví dụ:
"saa7114" hoặc "saa7115". Nói chung mặc dù trình điều khiển i2c tự động phát hiện điều này.
Việc sử dụng chipid là điều cần được xem xét kỹ hơn
ngày sau đó. Nó khác nhau giữa các trình điều khiển i2c và do đó có thể gây nhầm lẫn.
Để xem những biến thể chip nào được hỗ trợ, bạn có thể xem mã trình điều khiển i2c
cho bảng i2c_device_id. Điều này liệt kê tất cả các khả năng.

Có thêm một chức năng trợ giúp:

ZZ0000ZZ sử dụng cấu trúc ZZ0001ZZ
được chuyển tới trình điều khiển i2c và thay thế irq, platform_data và addr
lý lẽ.

Nếu subdev hỗ trợ các op lõi s_config thì op đó được gọi với
các đối số irq và platform_data sau khi thiết lập subdev.

Hàm ZZ0000ZZ sẽ gọi
ZZ0001ZZ, điền nội bộ một
Cấu trúc ZZ0002ZZ sử dụng ZZ0003ZZ và
ZZ0004ZZ để điền vào nó.

Trạng thái hoạt động của subdev được quản lý tập trung
-------------------------------------

Theo truyền thống, trình điều khiển subdev V4L2 duy trì trạng thái bên trong cho hoạt động
cấu hình thiết bị. Điều này thường được thực hiện như ví dụ: một mảng cấu trúc
v4l2_mbus_framefmt, một mục nhập cho mỗi bảng và tương tự để cắt và soạn thảo
hình chữ nhật.

Ngoài cấu hình hoạt động, mỗi phần xử lý tệp subdev có một cấu trúc
v4l2_subdev_state, được quản lý bởi lõi V4L2, chứa phần thử
cấu hình.

Để đơn giản hóa trình điều khiển subdev, V4L2 subdev API hiện hỗ trợ tùy chọn một
cấu hình hoạt động được quản lý tập trung đại diện bởi
ZZ0000ZZ. Một thể hiện của trạng thái, chứa hoạt động
cấu hình thiết bị, được lưu trữ trong chính thiết bị phụ như một phần của
cấu trúc ZZ0001ZZ, trong khi lõi liên kết trạng thái thử với
mỗi phần xử lý tệp đang mở, để lưu trữ cấu hình thử liên quan đến tệp đó
xử lý.

Trình điều khiển thiết bị phụ có thể chọn tham gia và sử dụng trạng thái để quản lý cấu hình hoạt động của chúng
bằng cách khởi tạo trạng thái thiết bị con bằng lệnh gọi tới v4l2_subdev_init_finalize()
trước khi đăng ký thiết bị phụ. Họ cũng phải gọi v4l2_subdev_cleanup()
để giải phóng tất cả tài nguyên được phân bổ trước khi hủy đăng ký thiết bị phụ.
Lõi tự động phân bổ và khởi tạo trạng thái cho mỗi tệp đang mở
xử lý để lưu trữ các cấu hình thử và giải phóng nó khi đóng tệp
xử lý.

Các hoạt động của thiết bị phụ V4L2 sử dụng cả ZZ0000ZZ sẽ nhận được trạng thái chính xác để hoạt động thông qua
tham số 'trạng thái'. Trạng thái phải được khóa và mở khóa bởi
người gọi bằng cách gọi ZZ0001ZZ và
ZZ0002ZZ. Người gọi có thể làm như vậy bằng cách gọi subdev
hoạt động thông qua macro ZZ0003ZZ.

Các hoạt động không nhận tham số trạng thái sẽ hoạt động ngầm trên
trạng thái hoạt động của thiết bị con, mà trình điều khiển có thể truy cập độc quyền bằng
đang gọi ZZ0000ZZ. Thiết bị phụ đang hoạt động
trạng thái phải được giải phóng như nhau bằng cách gọi ZZ0001ZZ.

Trình điều khiển không bao giờ được truy cập thủ công trạng thái được lưu trữ trong ZZ0000ZZ
hoặc trong phần xử lý tệp mà không cần thông qua những người trợ giúp được chỉ định.

Trong khi lõi V4L2 chuyển trạng thái thử hoặc trạng thái hoạt động chính xác cho thiết bị con
hoạt động, nhiều trình điều khiển thiết bị hiện có chuyển trạng thái NULL khi gọi
hoạt động với ZZ0000ZZ. Cấu trúc kế thừa này gây ra
sự cố với trình điều khiển thiết bị phụ cho phép lõi V4L2 quản lý trạng thái hoạt động,
vì họ mong đợi nhận được trạng thái thích hợp làm tham số. Để giúp
chuyển đổi trình điều khiển thiết bị phụ sang trạng thái hoạt động được quản lý mà không cần phải
chuyển đổi tất cả người gọi cùng một lúc, một lớp bao bọc bổ sung đã được
được thêm vào v4l2_subdev_call(), xử lý trường hợp NULL bằng cách lấy và khóa
trạng thái hoạt động của callee với ZZ0001ZZ,
và mở khóa trạng thái sau cuộc gọi.

Toàn bộ trạng thái subdev trên thực tế được chia thành ba phần:
v4l2_subdev_state, điều khiển subdev và trạng thái bên trong của trình điều khiển subdev. trong
trong tương lai những phần này sẽ được kết hợp thành một trạng thái duy nhất. Hiện tại
chúng ta cần có cách xử lý việc khóa các bộ phận này. Điều này có thể được thực hiện
bằng cách chia sẻ một khóa. v4l2_ctrl_handler đã hỗ trợ điều này thông qua 'khóa' của nó
con trỏ và mô hình tương tự được sử dụng với các trạng thái. Người lái xe có thể làm như sau
trước khi gọi v4l2_subdev_init_finalize():

.. code-block:: c

	sd->ctrl_handler->lock = &priv->mutex;
	sd->state_lock = &priv->mutex;

Điều này chia sẻ mutex riêng tư của trình điều khiển giữa các điều khiển và trạng thái.

Luồng, miếng đệm đa phương tiện và định tuyến nội bộ
----------------------------------------------------

Trình điều khiển thiết bị con có thể triển khai hỗ trợ cho các luồng đa kênh bằng cách cài đặt
cờ subdev V4L2_SUBDEV_FL_STREAMS và triển khai hỗ trợ cho
trạng thái hoạt động của subdev được quản lý tập trung, định tuyến và dựa trên luồng
cấu hình.

Cấu trúc dữ liệu và chức năng của thiết bị phụ V4L2
---------------------------------------------

.. kernel-doc:: include/media/v4l2-subdev.h