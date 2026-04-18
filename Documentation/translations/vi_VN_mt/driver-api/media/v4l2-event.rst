.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-event.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Sự kiện V4L2
-----------

Các sự kiện V4L2 cung cấp một cách chung để chuyển các sự kiện tới không gian người dùng.
Trình điều khiển phải sử dụng ZZ0000ZZ để có thể hỗ trợ các sự kiện V4L2.

Các sự kiện được đăng ký trên mỗi filehandle. Một đặc tả sự kiện bao gồm một
ZZ0000ZZ và được liên kết tùy ý với một đối tượng được xác định thông qua
Trường ZZ0001ZZ. Nếu không được sử dụng thì ZZ0002ZZ là 0. Vì vậy, một sự kiện là duy nhất
được xác định bởi bộ ZZ0003ZZ.

Cấu trúc ZZ0000ZZ có một danh sách các sự kiện đã đăng ký trên
Trường ZZ0001ZZ.

Khi người dùng đăng ký một sự kiện, ZZ0000ZZ
struct được thêm vào ZZ0001ZZ\ ZZ0002ZZ, một cho mỗi
sự kiện đã đăng ký.

Mỗi cấu trúc ZZ0000ZZ kết thúc bằng một
Bộ đệm chuông ZZ0001ZZ, với kích thước do người gọi cung cấp
của ZZ0002ZZ. Bộ đệm chuông này được sử dụng để lưu trữ bất kỳ sự kiện nào
được tài xế nâng lên.

Vì vậy, mỗi bộ sự kiện ZZ0001ZZ sẽ có bộ sự kiện riêng
Bộ đệm chuông ZZ0000ZZ. Điều này đảm bảo rằng nếu người lái xe
tạo ra nhiều sự kiện thuộc một loại trong thời gian ngắn, thì điều đó sẽ
không ghi đè lên các sự kiện thuộc loại khác.

Nhưng nếu bạn nhận được nhiều sự kiện thuộc một loại hơn kích thước của
Bộ đệm chuông ZZ0000ZZ, sau đó sự kiện cũ nhất sẽ bị loại bỏ
và cái mới được thêm vào.

Cấu trúc ZZ0000ZZ liên kết với ZZ0003ZZ
danh sách cấu trúc ZZ0001ZZ nên ZZ0002ZZ sẽ
biết sự kiện nào cần loại bỏ trước tiên.

Cuối cùng, nếu đăng ký sự kiện được liên kết với một đối tượng cụ thể
chẳng hạn như điều khiển V4L2, thì đối tượng đó cũng cần biết về điều đó
để đối tượng đó có thể nêu lên một sự kiện. Vì vậy trường ZZ0001ZZ có thể
được sử dụng để liên kết cấu trúc ZZ0000ZZ vào một danh sách
những đồ vật như vậy.

Vì vậy, để tóm tắt:

- struct v4l2_fh có hai danh sách: một trong các sự kiện ZZ0000ZZ,
  và một trong những sự kiện ZZ0001ZZ.

- struct v4l2_subscribe_event có bộ đệm vòng tăng lên
  (đang chờ xử lý) các sự kiện thuộc loại cụ thể đó.

- Nếu struct v4l2_subscribe_event được liên kết với một sự kiện cụ thể
  đối tượng thì đối tượng đó sẽ có một danh sách nội bộ gồm
  struct v4l2_subscribe_event để biết ai đã đăng ký
  sự kiện đối với đối tượng đó.

Hơn nữa, cấu trúc bên trong v4l2_subscribe_event có
Lệnh gọi lại ZZ0000ZZ và ZZ0001ZZ mà trình điều khiển có thể đặt. Những cái này
cuộc gọi lại được gọi khi một sự kiện mới được đưa ra và không còn chỗ trống.

Lệnh gọi lại ZZ0000ZZ cho phép bạn thay thế tải trọng của sự kiện cũ
với sự kiện mới, hợp nhất mọi dữ liệu có liên quan từ tải trọng cũ
vào tải trọng mới thay thế nó. Nó được gọi khi loại sự kiện này có
một bộ đệm chuông có kích thước là một, tức là chỉ có một sự kiện có thể được lưu trữ trong
ringbuffer.

Lệnh gọi lại ZZ0000ZZ cho phép bạn hợp nhất tải trọng sự kiện cũ nhất vào
tải trọng sự kiện lâu đời thứ hai. Nó được gọi khi
bộ đệm chuông có kích thước lớn hơn một.

Bằng cách này không có thông tin trạng thái nào bị mất mà chỉ dẫn các bước trung gian
đến trạng thái đó.

Một ví dụ điển hình về các lệnh gọi lại ZZ0000ZZ/ZZ0001ZZ này có trong v4l2-event.c:
Lệnh gọi lại ZZ0002ZZ và ZZ0003ZZ cho sự kiện điều khiển.

.. note::
	these callbacks can be called from interrupt context, so they must
	be fast.

Để xếp hàng các sự kiện vào thiết bị video, người lái xe nên gọi:

ZZ0000ZZ
	(ZZ0001ZZ, ZZ0002ZZ)

Trách nhiệm duy nhất của người lái xe là điền vào loại và trường dữ liệu.
Các trường khác sẽ được điền bởi V4L2.

Đăng ký sự kiện
~~~~~~~~~~~~~~~~~~

Đăng ký một sự kiện là thông qua:

ZZ0000ZZ
	(ZZ0001ZZ, ZZ0002ZZ,
	các yếu tố, ZZ0003ZZ)


Chức năng này được sử dụng để triển khai ZZ0000ZZ->
ZZ0001ZZ-> ZZ0003ZZ,
nhưng tài xế phải kiểm tra trước xem tài xế có thể tạo sự kiện không
với id sự kiện được chỉ định và sau đó nên gọi
ZZ0002ZZ để đăng ký sự kiện.

Đối số elems là kích thước của hàng đợi sự kiện cho sự kiện này. Nếu là 0,
thì khung sẽ điền vào một giá trị mặc định (điều này phụ thuộc vào sự kiện
loại).

Đối số ops cho phép trình điều khiển chỉ định một số lệnh gọi lại:

.. tabularcolumns:: |p{1.5cm}|p{16.0cm}|

============================================================================
Mô tả gọi lại
============================================================================
add được gọi khi một người nghe mới được thêm vào (đăng ký cùng một
	 sự kiện hai lần sẽ chỉ khiến cuộc gọi lại này được gọi một lần)
del được gọi khi người nghe ngừng nghe
thay thế sự kiện 'cũ' bằng sự kiện 'mới'.
hợp nhất sự kiện hợp nhất 'cũ' vào sự kiện 'mới'.
============================================================================

Tất cả 4 lệnh gọi lại đều là tùy chọn, nếu bạn không muốn chỉ định bất kỳ lệnh gọi lại nào
bản thân đối số ops có thể là ZZ0000ZZ.

Hủy đăng ký một sự kiện
~~~~~~~~~~~~~~~~~~~~~~

Hủy đăng ký một sự kiện là thông qua:

ZZ0000ZZ
	(ZZ0001ZZ, ZZ0002ZZ)

Chức năng này được sử dụng để triển khai ZZ0000ZZ->
ZZ0001ZZ->ZZ0003ZZ.
Người lái xe có thể gọi trực tiếp ZZ0002ZZ trừ khi
muốn tham gia vào quá trình hủy đăng ký.

Loại đặc biệt ZZ0000ZZ có thể được sử dụng để hủy đăng ký tất cả các sự kiện. các
người lái xe có thể muốn xử lý việc này theo một cách đặc biệt.

Kiểm tra xem có sự kiện nào đang chờ xử lý không
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Kiểm tra xem có sự kiện đang chờ xử lý hay không thông qua:

ZZ0000ZZ
	(ZZ0001ZZ)


Hàm này trả về số lượng sự kiện đang chờ xử lý. Hữu ích khi thực hiện
thăm dò ý kiến.

Sự kiện hoạt động như thế nào
~~~~~~~~~~~~~~~

Các sự kiện được gửi đến không gian người dùng thông qua lệnh gọi hệ thống thăm dò ý kiến. Người lái xe
có thể sử dụng ZZ0000ZZ->wait (a Wait_queue_head_t) làm đối số cho
ZZ0001ZZ.

Có những sự kiện tiêu chuẩn và riêng tư. Các sự kiện tiêu chuẩn mới phải sử dụng
loại sự kiện nhỏ nhất có sẵn. Người lái xe phải phân bổ các sự kiện của họ từ
lớp học của riêng họ bắt đầu từ cơ sở lớp học. Cơ sở lớp học là
ZZ0000ZZ + n * 1000 trong đó n là số thấp nhất hiện có.
Loại sự kiện đầu tiên trong lớp được dành riêng để sử dụng trong tương lai, vì vậy loại sự kiện đầu tiên
loại sự kiện có sẵn là 'cơ sở lớp + 1'.

Bạn có thể tìm thấy ví dụ về cách sử dụng các sự kiện V4L2 trong OMAP
3 Trình điều khiển ISP (ZZ0000ZZ).

Một subdev có thể gửi trực tiếp một sự kiện tới thông báo ZZ0000ZZ
chức năng với ZZ0001ZZ. Điều này cho phép cây cầu lập bản đồ
subdev gửi sự kiện đến (các) nút video được liên kết với
subdev cần được thông báo về sự kiện như vậy.

Các hàm sự kiện và cấu trúc dữ liệu của V4L2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

.. kernel-doc:: include/media/v4l2-event.h
