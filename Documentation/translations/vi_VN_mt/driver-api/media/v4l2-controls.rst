.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-controls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Điều khiển V4L2
=============

Giới thiệu
------------

Điều khiển V4L2 API có vẻ đơn giản nhưng nhanh chóng trở nên rất khó thực hiện.
thực hiện chính xác trong trình điều khiển. Nhưng phần lớn mã cần thiết để xử lý các điều khiển
thực tế không phải là trình điều khiển cụ thể và có thể được chuyển sang khung lõi V4L.

Rốt cuộc, phần duy nhất mà nhà phát triển trình điều khiển quan tâm là:

1) Làm cách nào để thêm điều khiển?
2) Làm cách nào để đặt giá trị của điều khiển? (tức là s_ctrl)

Và thỉnh thoảng:

3) Làm cách nào để nhận được giá trị của điều khiển? (tức là g_volatile_ctrl)
4) Làm cách nào để xác thực giá trị kiểm soát được đề xuất của người dùng? (tức là try_ctrl)

Tất cả những việc còn lại có thể được thực hiện một cách tập trung.

Khung kiểm soát được tạo ra để thực hiện tất cả các quy tắc của
Thông số kỹ thuật V4L2 liên quan đến các điều khiển ở vị trí trung tâm. Và để làm
cuộc sống dễ dàng nhất có thể cho nhà phát triển trình điều khiển.

Lưu ý rằng khung điều khiển dựa vào sự hiện diện của cấu trúc
ZZ0000ZZ cho trình điều khiển V4L2 và struct v4l2_subdev cho
trình điều khiển thiết bị phụ.


Các đối tượng trong khuôn khổ
------------------------

Có hai đối tượng chính:

Đối tượng ZZ0000ZZ mô tả các thuộc tính điều khiển và giữ
theo dõi giá trị của điều khiển (cả giá trị hiện tại và giá trị mới được đề xuất
giá trị).

ZZ0000ZZ là đối tượng theo dõi các điều khiển. Nó
duy trì một danh sách các đối tượng v4l2_ctrl mà nó sở hữu và một danh sách khác
tham chiếu đến các điều khiển, có thể là các điều khiển thuộc sở hữu của những người xử lý khác.


Cách sử dụng cơ bản cho V4L2 và trình điều khiển thiết bị phụ
-------------------------------------------

1) Chuẩn bị trình điều khiển:

.. code-block:: c

	#include <media/v4l2-ctrls.h>

1.1) Thêm trình xử lý vào cấu trúc cấp cao nhất của trình điều khiển của bạn:

Đối với trình điều khiển V4L2:

.. code-block:: c

	struct foo_dev {
		...
		struct v4l2_device v4l2_dev;
		...
		struct v4l2_ctrl_handler ctrl_handler;
		...
	};

Đối với trình điều khiển thiết bị phụ:

.. code-block:: c

	struct foo_dev {
		...
		struct v4l2_subdev sd;
		...
		struct v4l2_ctrl_handler ctrl_handler;
		...
	};

1.2) Khởi tạo trình xử lý:

.. code-block:: c

	v4l2_ctrl_handler_init(&foo->ctrl_handler, nr_of_controls);

Đối số thứ hai là gợi ý cho hàm biết có bao nhiêu điều khiển này
trình xử lý dự kiến ​​sẽ xử lý. Nó sẽ phân bổ một bảng băm dựa trên điều này
thông tin. Nó chỉ là một gợi ý.

1.3) Móc bộ xử lý điều khiển vào trình điều khiển:

Đối với trình điều khiển V4L2:

.. code-block:: c

	foo->v4l2_dev.ctrl_handler = &foo->ctrl_handler;

Đối với trình điều khiển thiết bị phụ:

.. code-block:: c

	foo->sd.ctrl_handler = &foo->ctrl_handler;

1.4) Dọn dẹp phần xử lý ở cuối:

.. code-block:: c

	v4l2_ctrl_handler_free(&foo->ctrl_handler);

ZZ0000ZZ không chạm vào trường ZZ0001ZZ của trình xử lý.

2) Thêm điều khiển:

Bạn thêm các điều khiển ngoài menu bằng cách gọi ZZ0000ZZ:

.. code-block:: c

	struct v4l2_ctrl *v4l2_ctrl_new_std(struct v4l2_ctrl_handler *hdl,
			const struct v4l2_ctrl_ops *ops,
			u32 id, s32 min, s32 max, u32 step, s32 def);

Điều khiển menu và menu số nguyên được thêm bằng cách gọi
ZZ0000ZZ:

.. code-block:: c

	struct v4l2_ctrl *v4l2_ctrl_new_std_menu(struct v4l2_ctrl_handler *hdl,
			const struct v4l2_ctrl_ops *ops,
			u32 id, s32 max, s32 skip_mask, s32 def);

Điều khiển menu với menu dành riêng cho trình điều khiển được thêm bằng cách gọi
ZZ0000ZZ:

.. code-block:: c

       struct v4l2_ctrl *v4l2_ctrl_new_std_menu_items(
                       struct v4l2_ctrl_handler *hdl,
                       const struct v4l2_ctrl_ops *ops, u32 id, s32 max,
                       s32 skip_mask, s32 def, const char * const *qmenu);

Điều khiển phức hợp tiêu chuẩn có thể được thêm bằng cách gọi
ZZ0000ZZ:

.. code-block:: c

       struct v4l2_ctrl *v4l2_ctrl_new_std_compound(struct v4l2_ctrl_handler *hdl,
                       const struct v4l2_ctrl_ops *ops, u32 id,
                       const union v4l2_ctrl_ptr p_def);

Có thể thêm các điều khiển menu số nguyên với menu cụ thể của trình điều khiển bằng cách gọi
ZZ0000ZZ:

.. code-block:: c

	struct v4l2_ctrl *v4l2_ctrl_new_int_menu(struct v4l2_ctrl_handler *hdl,
			const struct v4l2_ctrl_ops *ops,
			u32 id, s32 max, s32 def, const s64 *qmenu_int);

Các hàm này thường được gọi ngay sau
ZZ0000ZZ:

.. code-block:: c

	static const s64 exp_bias_qmenu[] = {
	       -2, -1, 0, 1, 2
	};
	static const char * const test_pattern[] = {
		"Disabled",
		"Vertical Bars",
		"Solid Black",
		"Solid White",
	};

	v4l2_ctrl_handler_init(&foo->ctrl_handler, nr_of_controls);
	v4l2_ctrl_new_std(&foo->ctrl_handler, &foo_ctrl_ops,
			V4L2_CID_BRIGHTNESS, 0, 255, 1, 128);
	v4l2_ctrl_new_std(&foo->ctrl_handler, &foo_ctrl_ops,
			V4L2_CID_CONTRAST, 0, 255, 1, 128);
	v4l2_ctrl_new_std_menu(&foo->ctrl_handler, &foo_ctrl_ops,
			V4L2_CID_POWER_LINE_FREQUENCY,
			V4L2_CID_POWER_LINE_FREQUENCY_60HZ, 0,
			V4L2_CID_POWER_LINE_FREQUENCY_DISABLED);
	v4l2_ctrl_new_int_menu(&foo->ctrl_handler, &foo_ctrl_ops,
			V4L2_CID_EXPOSURE_BIAS,
			ARRAY_SIZE(exp_bias_qmenu) - 1,
			ARRAY_SIZE(exp_bias_qmenu) / 2 - 1,
			exp_bias_qmenu);
	v4l2_ctrl_new_std_menu_items(&foo->ctrl_handler, &foo_ctrl_ops,
			V4L2_CID_TEST_PATTERN, ARRAY_SIZE(test_pattern) - 1, 0,
			0, test_pattern);
	...
	if (foo->ctrl_handler.error)
		return v4l2_ctrl_handler_free(&foo->ctrl_handler);

Hàm ZZ0000ZZ trả về con trỏ v4l2_ctrl tới
điều khiển mới, nhưng nếu bạn không cần truy cập con trỏ bên ngoài
kiểm soát các hoạt động thì không cần phải lưu trữ nó.

Hàm ZZ0000ZZ sẽ điền vào hầu hết các trường dựa trên
ID điều khiển ngoại trừ các giá trị tối thiểu, tối đa, bước và mặc định. Đây là
được thông qua trong bốn đối số cuối cùng. Các giá trị này là trình điều khiển cụ thể trong khi
các thuộc tính điều khiển như loại, tên, cờ đều mang tính toàn cục. Sự kiểm soát
giá trị hiện tại sẽ được đặt thành giá trị mặc định.

Chức năng ZZ0000ZZ rất giống nhau nhưng nó
được sử dụng để điều khiển menu. Không có đối số tối thiểu vì nó luôn bằng 0 đối với
điều khiển menu và thay vì một bước, có đối số Skip_mask: if bit
X là 1 thì mục menu X sẽ bị bỏ qua.

Chức năng ZZ0000ZZ tạo ra một tiêu chuẩn mới
điều khiển menu số nguyên với các mục dành riêng cho trình điều khiển trong menu. Nó khác
từ v4l2_ctrl_new_std_menu ở chỗ nó không có đối số mặt nạ và
lấy đối số cuối cùng là một mảng các số nguyên 64-bit có dấu tạo thành một
danh sách mục menu chính xác.

Chức năng ZZ0000ZZ rất giống với
v4l2_ctrl_new_std_menu nhưng có thêm một tham số qmenu, đó là
menu cụ thể của trình điều khiển để có điều khiển menu tiêu chuẩn khác. Một ví dụ tốt
đối với điều khiển này là điều khiển mẫu thử nghiệm để chụp/hiển thị/cảm biến
các thiết bị có khả năng tạo ra các mẫu thử nghiệm. Những bài kiểm tra này
các mẫu có phần cứng cụ thể nên nội dung của menu sẽ khác nhau tùy theo
thiết bị này sang thiết bị khác.

Lưu ý rằng nếu có lỗi xảy ra, hàm sẽ trả về NULL hoặc có lỗi và
đặt ctrl_handler->error thành mã lỗi. Nếu ctrl_handler->đã có lỗi
được đặt, sau đó nó sẽ quay trở lại và không làm gì cả. Điều này cũng đúng với
v4l2_ctrl_handler_init nếu nó không thể phân bổ cấu trúc dữ liệu nội bộ.

Điều này giúp dễ dàng khởi tạo trình xử lý và chỉ cần thêm tất cả các điều khiển và chỉ kiểm tra
mã lỗi ở cuối. Tiết kiệm rất nhiều việc kiểm tra lỗi lặp đi lặp lại.

Nên thêm các điều khiển theo thứ tự ID điều khiển tăng dần: nó sẽ là
theo cách đó nhanh hơn một chút.

3) Tùy chọn buộc thiết lập điều khiển ban đầu:

.. code-block:: c

	v4l2_ctrl_handler_setup(&foo->ctrl_handler);

Điều này sẽ gọi s_ctrl cho tất cả các điều khiển vô điều kiện. Thực tế điều này
khởi tạo phần cứng về các giá trị điều khiển mặc định. Nó được khuyến khích
bạn làm điều này vì điều này đảm bảo rằng cả cấu trúc dữ liệu nội bộ và
phần cứng được đồng bộ.

4) Cuối cùng: triển khai ZZ0000ZZ

.. code-block:: c

	static const struct v4l2_ctrl_ops foo_ctrl_ops = {
		.s_ctrl = foo_s_ctrl,
	};

Thông thường tất cả những gì bạn cần là s_ctrl:

.. code-block:: c

	static int foo_s_ctrl(struct v4l2_ctrl *ctrl)
	{
		struct foo *state = container_of(ctrl->handler, struct foo, ctrl_handler);

		switch (ctrl->id) {
		case V4L2_CID_BRIGHTNESS:
			write_reg(0x123, ctrl->val);
			break;
		case V4L2_CID_CONTRAST:
			write_reg(0x456, ctrl->val);
			break;
		}
		return 0;
	}

Các hoạt động điều khiển được gọi với con trỏ v4l2_ctrl làm đối số.
Giá trị kiểm soát mới đã được xác thực, vì vậy tất cả những gì bạn cần làm là
để thực sự cập nhật các thanh ghi phần cứng.

Bạn đã hoàn tất! Và điều này là đủ cho hầu hết các trình điều khiển chúng tôi có. không cần
để thực hiện bất kỳ xác nhận nào về các giá trị điều khiển hoặc triển khai QUERYCTRL, QUERY_EXT_CTRL
và QUERYMENU. Và G/S_CTRL cũng như G/TRY/S_EXT_CTRLS được hỗ trợ tự động.


.. note::

   The remainder sections deal with more advanced controls topics and scenarios.
   In practice the basic usage as described above is sufficient for most drivers.


Kế thừa các điều khiển thiết bị phụ
------------------------------

Khi một thiết bị phụ được đăng ký với trình điều khiển V4L2 bằng cách gọi
v4l2_device_register_subdev() và các trường ctrl_handler của cả v4l2_subdev
và v4l2_device được đặt thì các điều khiển của subdev sẽ trở thành
cũng tự động có sẵn trong trình điều khiển V4L2. Nếu trình điều khiển subdev
chứa các điều khiển đã tồn tại trong trình điều khiển V4L2, thì những điều khiển đó sẽ
bị bỏ qua (vì vậy trình điều khiển V4L2 luôn có thể ghi đè điều khiển subdev).

Điều xảy ra ở đây là các lệnh gọi v4l2_device_register_subdev()
v4l2_ctrl_add_handler() thêm các điều khiển của subdev vào các điều khiển
của v4l2_device.


Truy cập các giá trị điều khiển
------------------------

Liên kết sau đây được sử dụng bên trong khung điều khiển để kiểm soát truy cập
giá trị:

.. code-block:: c

	union v4l2_ctrl_ptr {
		s32 *p_s32;
		s64 *p_s64;
		char *p_char;
		void *p;
	};

Cấu trúc v4l2_ctrl chứa các trường này có thể được sử dụng để truy cập cả
giá trị hiện tại và mới:

.. code-block:: c

	s32 val;
	struct {
		s32 val;
	} cur;


	union v4l2_ctrl_ptr p_new;
	union v4l2_ctrl_ptr p_cur;

Nếu điều khiển có loại s32 đơn giản thì:

.. code-block:: c

	&ctrl->val == ctrl->p_new.p_s32
	&ctrl->cur.val == ctrl->p_cur.p_s32

Đối với tất cả các loại khác, hãy sử dụng ctrl->p_cur.p<something>. Về cơ bản giá trị
và các trường cur.val có thể được coi là bí danh vì chúng được sử dụng thường xuyên.

Trong các hoạt động kiểm soát, bạn có thể tự do sử dụng chúng. Val và cur.val nói lên điều đó
chính họ. Con trỏ p_char trỏ tới vùng đệm ký tự có độ dài
ctrl->maximum + 1 và luôn kết thúc bằng 0.

Trừ khi điều khiển được đánh dấu là không ổn định, trường p_cur trỏ đến
giá trị điều khiển được lưu trong bộ nhớ đệm hiện tại. Khi bạn tạo một điều khiển mới, giá trị này được tạo
giống với giá trị mặc định. Sau khi gọi v4l2_ctrl_handler_setup() cái này
giá trị được chuyển đến phần cứng. Nói chung nên gọi đây là một ý tưởng hay
chức năng.

Bất cứ khi nào một giá trị mới được đặt, giá trị mới đó sẽ tự động được lưu vào bộ đệm. Điều này có nghĩa
rằng hầu hết các trình điều khiển không cần triển khai lệnh g_volatile_ctrl(). các
ngoại lệ dành cho các điều khiển trả về một thanh ghi dễ thay đổi, chẳng hạn như tín hiệu
chỉ số cường độ thay đổi liên tục. Trong trường hợp đó bạn sẽ cần phải
triển khai g_volatile_ctrl như thế này:

.. code-block:: c

	static int foo_g_volatile_ctrl(struct v4l2_ctrl *ctrl)
	{
		switch (ctrl->id) {
		case V4L2_CID_BRIGHTNESS:
			ctrl->val = read_reg(0x123);
			break;
		}
	}

Lưu ý rằng bạn cũng sử dụng liên kết 'giá trị mới' trong g_volatile_ctrl. Nói chung
các điều khiển cần triển khai g_volatile_ctrl là các điều khiển chỉ đọc. Nếu họ
không, V4L2_EVENT_CTRL_CH_VALUE sẽ không được tạo khi điều khiển
những thay đổi.

Để đánh dấu một điều khiển là dễ bay hơi, bạn phải đặt V4L2_CTRL_FLAG_VOLATILE:

.. code-block:: c

	ctrl = v4l2_ctrl_new_std(&sd->ctrl_handler, ...);
	if (ctrl)
		ctrl->flags |= V4L2_CTRL_FLAG_VOLATILE;

Đối với try/s_ctrl, các giá trị mới (tức là được người dùng chuyển vào) được điền vào và
bạn có thể sửa đổi chúng trong try_ctrl hoặc đặt chúng trong s_ctrl. Liên minh 'cur'
chứa giá trị hiện tại mà bạn có thể sử dụng (nhưng không thay đổi!).

Nếu s_ctrl trả về 0 (OK), thì khung điều khiển sẽ sao chép bản cuối cùng mới
giá trị cho liên minh 'cur'.

Khi ở g_volatile/s/try_ctrl, bạn có thể truy cập giá trị của tất cả các điều khiển được sở hữu
bởi cùng một trình xử lý vì khóa của trình xử lý được giữ. Nếu bạn cần truy cập
giá trị của các điều khiển thuộc sở hữu của những người xử lý khác, thì bạn phải hết sức cẩn thận
không gây ra bế tắc.

Ngoài các hoạt động điều khiển, bạn phải chuyển sang các chức năng trợ giúp để có được
hoặc đặt một giá trị điều khiển duy nhất một cách an toàn trong trình điều khiển của bạn:

.. code-block:: c

	s32 v4l2_ctrl_g_ctrl(struct v4l2_ctrl *ctrl);
	int v4l2_ctrl_s_ctrl(struct v4l2_ctrl *ctrl, s32 val);

Các chức năng này đi qua khung điều khiển giống như VIDIOC_G/S_CTRL ioctls
làm. Tuy nhiên, đừng sử dụng những thứ này bên trong các lệnh điều khiển g_volatile/s/try_ctrl.
sẽ dẫn đến bế tắc vì những người trợ giúp này cũng khóa trình xử lý.

Bạn cũng có thể tự mình xử lý khóa:

.. code-block:: c

	mutex_lock(&state->ctrl_handler.lock);
	pr_info("String value is '%s'\n", ctrl1->p_cur.p_char);
	pr_info("Integer value is '%s'\n", ctrl2->cur.val);
	mutex_unlock(&state->ctrl_handler.lock);


Điều khiển menu
-------------

Cấu trúc v4l2_ctrl chứa liên kết này:

.. code-block:: c

	union {
		u32 step;
		u32 menu_skip_mask;
	};

Để điều khiển menu menu_skip_mask được sử dụng. Những gì nó làm là nó cho phép bạn
để dễ dàng loại trừ các mục menu nhất định. Điều này được sử dụng trong VIDIOC_QUERYMENU
triển khai nơi bạn có thể trả về -EINVAL nếu một mục menu nhất định không có
hiện tại. Lưu ý rằng VIDIOC_QUERYCTRL luôn trả về giá trị bước 1 cho
điều khiển thực đơn.

Một ví dụ điển hình là điều khiển menu Bitrate MPEG Audio Layer II trong đó
menu là danh sách các tốc độ bit được chuẩn hóa có thể. Nhưng trong thực tế phần cứng
việc triển khai sẽ chỉ hỗ trợ một tập hợp con trong số đó. Bằng cách thiết lập bỏ qua
mặt nạ, bạn có thể cho khung biết nên bỏ qua mục menu nào. Cài đặt
nó về 0 có nghĩa là tất cả các mục menu đều được hỗ trợ.

Bạn đặt mặt nạ này thông qua cấu trúc v4l2_ctrl_config cho tùy chỉnh
control hoặc bằng cách gọi v4l2_ctrl_new_std_menu().


Điều khiển tùy chỉnh
---------------

Các điều khiển cụ thể của trình điều khiển có thể được tạo bằng v4l2_ctrl_new_custom():

.. code-block:: c

	static const struct v4l2_ctrl_config ctrl_filter = {
		.ops = &ctrl_custom_ops,
		.id = V4L2_CID_MPEG_CX2341X_VIDEO_SPATIAL_FILTER,
		.name = "Spatial Filter",
		.type = V4L2_CTRL_TYPE_INTEGER,
		.flags = V4L2_CTRL_FLAG_SLIDER,
		.max = 15,
		.step = 1,
	};

	ctrl = v4l2_ctrl_new_custom(&foo->ctrl_handler, &ctrl_filter, NULL);

Đối số cuối cùng là con trỏ riêng có thể được đặt thành trình điều khiển cụ thể
dữ liệu riêng tư.

Cấu trúc v4l2_ctrl_config cũng có một trường để đặt cờ is_private.

Nếu trường tên không được đặt thì khung sẽ cho rằng đây là tiêu chuẩn
control và sẽ điền vào các trường tên, loại và cờ tương ứng.


Điều khiển hoạt động và nắm bắt
---------------------------

Nếu bạn có được mối quan hệ phức tạp hơn giữa các điều khiển thì bạn có thể phải
kích hoạt và hủy kích hoạt điều khiển. Ví dụ: nếu điều khiển Chroma AGC là
bật thì điều khiển Chroma Gain sẽ không hoạt động. Nghĩa là, bạn có thể đặt nó, nhưng
giá trị sẽ không được phần cứng sử dụng miễn là mức tăng tự động
điều khiển đang bật. Thông thường, giao diện người dùng có thể vô hiệu hóa các trường nhập liệu như vậy.

Bạn có thể đặt trạng thái 'hoạt động' bằng v4l2_ctrl_activate(). Theo mặc định tất cả
điều khiển đang hoạt động. Lưu ý rằng khung không kiểm tra cờ này.
Nó hoàn toàn dành cho GUI. Hàm này thường được gọi từ bên trong
s_ctrl.

Cờ còn lại là cờ 'lấy'. Điều khiển bị nắm lấy có nghĩa là bạn không thể
thay đổi nó vì nó đang được sử dụng bởi một số tài nguyên. Ví dụ điển hình là MPEG
điều khiển tốc độ bit không thể thay đổi trong khi đang tiến hành chụp.

Nếu một điều khiển được đặt thành 'lấy' bằng cách sử dụng v4l2_ctrl_grab(), thì khung
sẽ trả về -EBUSY nếu cố gắng thiết lập điều khiển này. các
Hàm v4l2_ctrl_grab() thường được gọi từ trình điều khiển khi nó
bắt đầu hoặc dừng truyền phát.


Cụm điều khiển
----------------

Theo mặc định, tất cả các điều khiển đều độc lập với những điều khiển khác. Nhưng trong hơn
các tình huống phức tạp, bạn có thể nhận được sự phụ thuộc từ điều khiển này sang điều khiển khác.
Trong trường hợp đó bạn cần phải 'phân cụm' chúng:

.. code-block:: c

	struct foo {
		struct v4l2_ctrl_handler ctrl_handler;
	#define AUDIO_CL_VOLUME (0)
	#define AUDIO_CL_MUTE   (1)
		struct v4l2_ctrl *audio_cluster[2];
		...
	};

	state->audio_cluster[AUDIO_CL_VOLUME] =
		v4l2_ctrl_new_std(&state->ctrl_handler, ...);
	state->audio_cluster[AUDIO_CL_MUTE] =
		v4l2_ctrl_new_std(&state->ctrl_handler, ...);
	v4l2_ctrl_cluster(ARRAY_SIZE(state->audio_cluster), state->audio_cluster);

Từ bây giờ bất cứ khi nào một hoặc nhiều điều khiển thuộc về cùng một
cụm được đặt (hoặc 'nhận được' hoặc 'đã thử'), chỉ các hoạt động kiểm soát của cụm đầu tiên
control ('âm lượng' trong ví dụ này) được gọi. Bạn tạo một cái mới một cách hiệu quả
điều khiển tổng hợp. Tương tự như cách 'struct' hoạt động trong C.

Vì vậy, khi s_ctrl được gọi với V4L2_CID_AUDIO_VOLUME làm đối số, bạn nên đặt
tất cả hai điều khiển thuộc về audio_cluster:

.. code-block:: c

	static int foo_s_ctrl(struct v4l2_ctrl *ctrl)
	{
		struct foo *state = container_of(ctrl->handler, struct foo, ctrl_handler);

		switch (ctrl->id) {
		case V4L2_CID_AUDIO_VOLUME: {
			struct v4l2_ctrl *mute = ctrl->cluster[AUDIO_CL_MUTE];

			write_reg(0x123, mute->val ? 0 : ctrl->val);
			break;
		}
		case V4L2_CID_CONTRAST:
			write_reg(0x456, ctrl->val);
			break;
		}
		return 0;
	}

Trong ví dụ trên, những điều sau đây tương đương với trường hợp VOLUME:

.. code-block:: c

	ctrl == ctrl->cluster[AUDIO_CL_VOLUME] == state->audio_cluster[AUDIO_CL_VOLUME]
	ctrl->cluster[AUDIO_CL_MUTE] == state->audio_cluster[AUDIO_CL_MUTE]

Trong thực tế sử dụng mảng cụm như thế này sẽ rất mệt mỏi. Vì vậy thay vào đó
phương pháp tương đương sau đây được sử dụng:

.. code-block:: c

	struct {
		/* audio cluster */
		struct v4l2_ctrl *volume;
		struct v4l2_ctrl *mute;
	};

Cấu trúc ẩn danh được sử dụng để 'phân cụm' hai con trỏ điều khiển này một cách rõ ràng,
nhưng nó không phục vụ mục đích nào khác. Hiệu ứng này giống như việc tạo một
mảng có hai con trỏ điều khiển. Vì vậy, bạn chỉ có thể làm:

.. code-block:: c

	state->volume = v4l2_ctrl_new_std(&state->ctrl_handler, ...);
	state->mute = v4l2_ctrl_new_std(&state->ctrl_handler, ...);
	v4l2_ctrl_cluster(2, &state->volume);

Và trong foo_s_ctrl bạn có thể sử dụng trực tiếp các con trỏ này: state->mute->val.

Lưu ý rằng các điều khiển trong cụm có thể là NULL. Ví dụ, nếu đối với một số
lý do tắt tiếng không bao giờ được thêm vào (vì phần cứng không hỗ trợ điều đó
tính năng cụ thể), thì tắt tiếng sẽ là NULL. Vì vậy, trong trường hợp đó chúng ta có một
cụm gồm 2 điều khiển, trong đó chỉ có 1 điều khiển thực sự được khởi tạo. các
hạn chế duy nhất là điều khiển đầu tiên của cụm phải luôn được
hiện tại, vì đó là quyền kiểm soát 'chính' của cụm. chủ nhân
điều khiển là điều khiển xác định cụm và cung cấp
con trỏ tới cấu trúc v4l2_ctrl_ops được sử dụng cho cụm đó.

Rõ ràng, tất cả các điều khiển trong mảng cụm phải được khởi tạo thành một trong hai
một điều khiển hợp lệ hoặc tới NULL.

Trong một số trường hợp hiếm hoi, bạn có thể muốn biết điều khiển nào của cụm thực sự
được người dùng thiết lập một cách rõ ràng. Để làm điều này, bạn có thể kiểm tra cờ 'is_new' của
mỗi điều khiển. Ví dụ: trong trường hợp cụm âm lượng/tắt tiếng, 'is_new'
cờ của điều khiển tắt tiếng sẽ được đặt nếu người dùng gọi VIDIOC_S_CTRL để
chỉ tắt tiếng. Nếu người dùng gọi VIDIOC_S_EXT_CTRLS cho cả tắt tiếng và âm lượng
điều khiển thì cờ 'is_new' sẽ là 1 cho cả hai điều khiển.

Cờ 'is_new' luôn là 1 khi được gọi từ v4l2_ctrl_handler_setup().


Xử lý các điều khiển loại tăng/tăng tự động bằng Cụm tự động
-------------------------------------------------------

Một loại cụm điều khiển phổ biến là loại xử lý 'auto-foo/foo'-type
điều khiển. Các ví dụ điển hình là autogain/gain, autoexposure/exposure,
tự động cân bằng trắng/cân bằng đỏ/cân bằng xanh. Trong mọi trường hợp, bạn có một điều khiển
xác định liệu một điều khiển khác có được phần cứng xử lý tự động hay không,
hoặc liệu nó có được người dùng kiểm soát thủ công hay không.

Nếu cụm ở chế độ tự động thì nên điều khiển bằng tay
được đánh dấu là không hoạt động và dễ bay hơi. Khi các điều khiển dễ bay hơi được đọc
Hoạt động g_volatile_ctrl sẽ trả về giá trị tự động của phần cứng
chế độ được thiết lập tự động.

Nếu cụm được đặt ở chế độ thủ công thì các điều khiển thủ công sẽ trở thành
hoạt động trở lại và cờ dễ bay hơi bị xóa (vì vậy g_volatile_ctrl không còn
được gọi khi ở chế độ thủ công). Ngoài ra ngay trước khi chuyển sang chế độ thủ công
các giá trị hiện tại được xác định bởi chế độ tự động sẽ được sao chép dưới dạng hướng dẫn sử dụng mới
các giá trị.

Cuối cùng, V4L2_CTRL_FLAG_UPDATE phải được đặt để điều khiển tự động vì
việc thay đổi điều khiển đó sẽ ảnh hưởng đến cờ điều khiển của điều khiển thủ công.

Để đơn giản hóa điều này, một biến thể đặc biệt của v4l2_ctrl_cluster đã được
đã giới thiệu:

.. code-block:: c

	void v4l2_ctrl_auto_cluster(unsigned ncontrols, struct v4l2_ctrl **controls,
				    u8 manual_val, bool set_volatile);

Hai đối số đầu tiên giống hệt v4l2_ctrl_cluster. Đối số thứ ba
cho khung biết giá trị nào sẽ chuyển cụm sang chế độ thủ công. các
đối số cuối cùng sẽ tùy chọn đặt V4L2_CTRL_FLAG_VOLATILE cho các điều khiển không tự động.
Nếu nó sai thì các điều khiển thủ công sẽ không bao giờ thay đổi. Bạn thường sẽ
hãy sử dụng nó nếu phần cứng không cung cấp cho bạn tùy chọn đọc lại các giá trị như
được xác định bởi chế độ tự động (ví dụ: nếu tính năng tự động bật, phần cứng không cho phép
bạn để có được giá trị đạt được hiện tại).

Điều khiển đầu tiên của cụm được coi là điều khiển 'tự động'.

Sử dụng chức năng này sẽ đảm bảo rằng bạn không cần phải xử lý tất cả các công việc phức tạp.
cờ và xử lý dễ bay hơi.


Hỗ trợ VIDIOC_LOG_STATUS
-------------------------

Ioctl này cho phép bạn chuyển trạng thái hiện tại của trình điều khiển vào nhật ký kernel.
v4l2_ctrl_handler_log_status(ctrl_handler, tiền tố) có thể được sử dụng để kết xuất
giá trị của các điều khiển thuộc sở hữu của trình xử lý nhất định đối với nhật ký. Bạn có thể cung cấp một
tiền tố là tốt. Nếu tiền tố không kết thúc bằng dấu cách thì ':' sẽ được thêm vào
dành cho bạn.


Trình xử lý khác nhau cho các nút video khác nhau
--------------------------------------------

Thông thường trình điều khiển V4L2 chỉ có một bộ xử lý điều khiển chung cho
tất cả các nút video. Nhưng bạn cũng có thể chỉ định các trình xử lý điều khiển khác nhau cho
các nút video khác nhau. Bạn có thể làm điều đó bằng cách cài đặt thủ công ctrl_handler
trường cấu trúc video_device.

Sẽ không có vấn đề gì nếu không có nhà phát triển phụ nào tham gia nhưng nếu có thì
bạn cần chặn việc tự động hợp nhất các điều khiển subdev với toàn cầu
trình xử lý điều khiển. Bạn làm điều đó bằng cách chỉ cần đặt trường ctrl_handler trong
struct v4l2_device thành NULL. Bây giờ v4l2_device_register_subdev() sẽ không còn
hợp nhất các điều khiển subdev.

Sau khi mỗi subdev được thêm vào, bạn sẽ phải gọi v4l2_ctrl_add_handler
theo cách thủ công để thêm trình xử lý điều khiển của subdev (sd->ctrl_handler) vào mong muốn
trình xử lý điều khiển. Trình xử lý điều khiển này có thể dành riêng cho video_device hoặc
cho một tập hợp con của video_device. Ví dụ: các nút thiết bị vô tuyến chỉ có
điều khiển âm thanh, trong khi các nút thiết bị video và vbi có chung điều khiển
trình xử lý cho các điều khiển âm thanh và video.

Nếu bạn muốn có một trình xử lý (ví dụ: đối với nút thiết bị vô tuyến), hãy có một tập hợp con
của một trình xử lý khác (ví dụ: đối với nút thiết bị video), thì trước tiên bạn nên thêm
các điều khiển cho trình xử lý đầu tiên, thêm các điều khiển khác vào trình xử lý thứ hai
handler và cuối cùng thêm trình xử lý đầu tiên vào trình xử lý thứ hai. Ví dụ:

.. code-block:: c

	v4l2_ctrl_new_std(&radio_ctrl_handler, &radio_ops, V4L2_CID_AUDIO_VOLUME, ...);
	v4l2_ctrl_new_std(&radio_ctrl_handler, &radio_ops, V4L2_CID_AUDIO_MUTE, ...);
	v4l2_ctrl_new_std(&video_ctrl_handler, &video_ops, V4L2_CID_BRIGHTNESS, ...);
	v4l2_ctrl_new_std(&video_ctrl_handler, &video_ops, V4L2_CID_CONTRAST, ...);
	v4l2_ctrl_add_handler(&video_ctrl_handler, &radio_ctrl_handler, NULL);

Đối số cuối cùng của v4l2_ctrl_add_handler() là hàm lọc cho phép
bạn lọc những điều khiển nào sẽ được thêm vào. Đặt nó thành NULL nếu bạn muốn thêm
tất cả các điều khiển.

Hoặc bạn có thể thêm các điều khiển cụ thể vào trình xử lý:

.. code-block:: c

	volume = v4l2_ctrl_new_std(&video_ctrl_handler, &ops, V4L2_CID_AUDIO_VOLUME, ...);
	v4l2_ctrl_new_std(&video_ctrl_handler, &ops, V4L2_CID_BRIGHTNESS, ...);
	v4l2_ctrl_new_std(&video_ctrl_handler, &ops, V4L2_CID_CONTRAST, ...);

Điều bạn không nên làm là tạo hai điều khiển giống hệt nhau cho hai trình xử lý.
Ví dụ:

.. code-block:: c

	v4l2_ctrl_new_std(&radio_ctrl_handler, &radio_ops, V4L2_CID_AUDIO_MUTE, ...);
	v4l2_ctrl_new_std(&video_ctrl_handler, &video_ops, V4L2_CID_AUDIO_MUTE, ...);

Điều này sẽ rất tệ vì việc tắt tiếng radio sẽ không thay đổi chế độ tắt tiếng video
kiểm soát. Quy tắc là có một điều khiển cho mỗi 'nút' phần cứng mà bạn
có thể xoay vòng.


Tìm điều khiển
----------------

Thông thường bạn đã tự tạo các điều khiển và bạn có thể lưu trữ cấu trúc
con trỏ v4l2_ctrl vào cấu trúc của riêng bạn.

Nhưng đôi khi bạn cần tìm một điều khiển từ một trình xử lý khác mà bạn làm
không sở hữu. Ví dụ: nếu bạn phải tìm bộ điều khiển âm lượng từ một subdev.

Bạn có thể làm điều đó bằng cách gọi v4l2_ctrl_find:

.. code-block:: c

	struct v4l2_ctrl *volume;

	volume = v4l2_ctrl_find(sd->ctrl_handler, V4L2_CID_AUDIO_VOLUME);

Vì v4l2_ctrl_find sẽ khóa trình xử lý nên bạn phải cẩn thận khi
sử dụng nó. Ví dụ: đây không phải là một ý tưởng hay:

.. code-block:: c

	struct v4l2_ctrl_handler ctrl_handler;

	v4l2_ctrl_new_std(&ctrl_handler, &video_ops, V4L2_CID_BRIGHTNESS, ...);
	v4l2_ctrl_new_std(&ctrl_handler, &video_ops, V4L2_CID_CONTRAST, ...);

...and in video_ops.s_ctrl:

.. code-block:: c

	case V4L2_CID_BRIGHTNESS:
		contrast = v4l2_find_ctrl(&ctrl_handler, V4L2_CID_CONTRAST);
		...

Khi s_ctrl được gọi bởi khung thì ctrl_handler.lock đã được sử dụng, vì vậy
cố gắng tìm một điều khiển khác từ cùng một trình xử lý sẽ bế tắc.

Không nên sử dụng chức năng này từ bên trong các hoạt động điều khiển.


Ngăn chặn kế thừa Kiểm soát
-------------------------------

Khi một trình xử lý điều khiển được thêm vào một trình xử lý khác bằng v4l2_ctrl_add_handler, thì
theo mặc định, tất cả các điều khiển từ cái này được hợp nhất với cái kia. Nhưng một subdev có thể
có các điều khiển cấp thấp phù hợp với một số hệ thống nhúng nâng cao, nhưng
không phải khi nó được sử dụng trong phần cứng cấp độ người tiêu dùng. Trong trường hợp đó bạn muốn giữ
những điều khiển cấp thấp cục bộ cho subdev. Bạn có thể làm điều này bằng cách đơn giản
đặt cờ 'is_private' của điều khiển thành 1:

.. code-block:: c

	static const struct v4l2_ctrl_config ctrl_private = {
		.ops = &ctrl_custom_ops,
		.id = V4L2_CID_...,
		.name = "Some Private Control",
		.type = V4L2_CTRL_TYPE_INTEGER,
		.max = 15,
		.step = 1,
		.is_private = 1,
	};

	ctrl = v4l2_ctrl_new_custom(&foo->ctrl_handler, &ctrl_private, NULL);

Bây giờ, các điều khiển này sẽ bị bỏ qua khi v4l2_ctrl_add_handler được gọi.


Điều khiển V4L2_CTRL_TYPE_CTRL_CLASS
----------------------------------

Các điều khiển thuộc loại này có thể được GUI sử dụng để lấy tên của lớp điều khiển.
GUI đầy đủ tính năng có thể tạo hộp thoại nhiều tab với mỗi tab
chứa các điều khiển thuộc về một lớp điều khiển cụ thể. Tên của
mỗi tab có thể được tìm thấy bằng cách truy vấn một điều khiển đặc biệt có ID <control class | 1>.

Người lái xe không cần phải quan tâm đến điều này. Khung sẽ tự động thêm
điều khiển thuộc loại này bất cứ khi nào điều khiển đầu tiên thuộc về điều khiển mới
lớp được thêm vào.


Thêm thông báo gọi lại
-----------------------

Đôi khi người điều khiển nền tảng hoặc cầu cần được thông báo khi có cơ quan điều khiển
từ những thay đổi của trình điều khiển thiết bị phụ. Bạn có thể thiết lập một cuộc gọi lại thông báo bằng cách gọi
chức năng này:

.. code-block:: c

	void v4l2_ctrl_notify(struct v4l2_ctrl *ctrl,
		void (*notify)(struct v4l2_ctrl *ctrl, void *priv), void *priv);

Bất cứ khi nào điều khiển đưa ra thay đổi giá trị, lệnh gọi lại thông báo sẽ được gọi
với một con trỏ tới điều khiển và con trỏ riêng được truyền bằng
v4l2_ctrl_notify. Lưu ý rằng khóa xử lý của điều khiển được giữ khi
chức năng thông báo được gọi.

Chỉ có thể có một chức năng thông báo cho mỗi trình xử lý điều khiển. Bất kỳ nỗ lực nào
để thiết lập một chức năng thông báo khác sẽ gây ra WARN_ON.

Hàm v4l2_ctrl và cấu trúc dữ liệu
---------------------------------------

.. kernel-doc:: include/media/v4l2-ctrls.h