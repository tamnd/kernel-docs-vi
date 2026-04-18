.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-fh.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

V4L2 Xử lý tập tin
------------------

struct v4l2_fh cung cấp một cách để dễ dàng giữ tệp xử lý dữ liệu cụ thể
được sử dụng bởi khung V4L2. Việc sử dụng nó là bắt buộc trong tất cả các trình điều khiển.

struct v4l2_fh được phân bổ trong trình xử lý thao tác tệp ZZ0006ZZ của trình điều khiển.
Nó thường được nhúng trong một cấu trúc dành riêng cho trình điều khiển lớn hơn. các
ZZ0000ZZ phải được khởi tạo bằng lệnh gọi tới ZZ0001ZZ,
và thêm vào thiết bị video bằng ZZ0002ZZ. Điều này liên kết với
ZZ0003ZZ với ZZ0004ZZ bằng cách đặt ZZ0007ZZ thành
trỏ tới ZZ0005ZZ.

Tương tự, struct v4l2_fh được giải phóng trong tệp ZZ0002ZZ của trình điều khiển
người xử lý hoạt động. Nó phải được xóa khỏi thiết bị video bằng
ZZ0000ZZ và dọn dẹp bằng ZZ0001ZZ trước khi
được giải thoát.

Trình điều khiển không được truy cập trực tiếp vào ZZ0003ZZ. Họ có thể lấy lại
ZZ0000ZZ được liên kết với ZZ0001ZZ bằng cách gọi
ZZ0002ZZ. Trình điều khiển có thể trích xuất cấu trúc xử lý tệp của riêng họ
bằng cách sử dụng macro container_of.

Ví dụ:

.. code-block:: c

	struct my_fh {
		int blah;
		struct v4l2_fh fh;
	};

	...

	int my_open(struct file *file)
	{
		struct my_fh *my_fh;
		struct video_device *vfd;
		int ret;

		...

		my_fh = kzalloc(sizeof(*my_fh), GFP_KERNEL);

		...

		v4l2_fh_init(&my_fh->fh, vfd);

		...

		v4l2_fh_add(&my_fh->fh, file);
		return 0;
	}

	int my_release(struct file *file)
	{
		struct v4l2_fh *fh = file_to_v4l2_fh(file);
		struct my_fh *my_fh = container_of(fh, struct my_fh, fh);

		...
		v4l2_fh_del(&my_fh->fh, file);
		v4l2_fh_exit(&my_fh->fh);
		kfree(my_fh);
		return 0;
	}

Dưới đây là mô tả ngắn gọn về các chức năng ZZ0000ZZ được sử dụng:

ZZ0000ZZ
(ZZ0001ZZ, ZZ0002ZZ)

- Khởi tạo phần xử lý tập tin. ZZ0001ZZ này được thực hiện trong trình điều khiển
  Trình xử lý ZZ0000ZZ->open().

ZZ0000ZZ
(ZZ0001ZZ, tệp cấu trúc \*filp)

- Thêm danh sách xử lý tệp ZZ0000ZZ vào ZZ0001ZZ.
  Phải được gọi khi phần xử lý tệp được khởi tạo hoàn toàn.

ZZ0000ZZ
(ZZ0001ZZ, tệp cấu trúc \*filp)

- Hủy liên kết phần xử lý tệp khỏi ZZ0000ZZ. Xử lý tập tin
  chức năng thoát bây giờ có thể được gọi.

ZZ0000ZZ
(ZZ0001ZZ)

- Khởi tạo lại trình xử lý tập tin. Sau khi chưa khởi tạo ZZ0000ZZ
  bộ nhớ có thể được giải phóng.

ZZ0000ZZ
(tệp cấu trúc \*filp)

- Truy xuất phiên bản ZZ0000ZZ được liên kết với ZZ0001ZZ.

Nếu struct v4l2_fh không được nhúng thì bạn có thể sử dụng các hàm trợ giúp sau:

ZZ0000ZZ
(tệp cấu trúc \*filp)

- Việc này cấp phát một cấu trúc v4l2_fh, khởi tạo nó và thêm nó vào
  cấu trúc video_device được liên kết với tệp struct.

ZZ0000ZZ
(tệp cấu trúc \*filp)

- Thao tác này sẽ xóa nó khỏi cấu trúc video_device được liên kết với
  cấu trúc tệp, chưa khởi tạo ZZ0000ZZ và giải phóng nó.

Hai chức năng này có thể được cắm vào ZZ0000ZZ của v4l2_file_Operation
và hoạt động của ZZ0001ZZ.

Một số trình điều khiển cần thực hiện điều gì đó khi phần xử lý tệp đầu tiên được mở và
khi xử lý tập tin cuối cùng đóng lại. Hai chức năng trợ giúp đã được thêm vào để kiểm tra
liệu cấu trúc ZZ0000ZZ có phải là tước hiệu tệp mở duy nhất của
nút thiết bị liên quan:

ZZ0000ZZ
(ZZ0001ZZ)

- Trả về 1 nếu phần xử lý tệp là phần xử lý tệp duy nhất đang mở, nếu không thì trả về 0.

ZZ0000ZZ
(tệp cấu trúc \*filp)

- Tương tự nhưng nó gọi v4l2_fh_is_singular với filp->private_data.


V4L2 fh chức năng và cấu trúc dữ liệu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. kernel-doc:: include/media/v4l2-fh.h