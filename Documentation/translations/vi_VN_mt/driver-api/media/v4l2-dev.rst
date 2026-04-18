.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/v4l2-dev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Biểu diễn bên trong của thiết bị video
=======================================

Các nút thiết bị thực tế trong thư mục ZZ0001ZZ được tạo bằng cách sử dụng
Cấu trúc ZZ0000ZZ (ZZ0002ZZ). Cấu trúc này có thể là
được phân bổ động hoặc được nhúng trong một cấu trúc lớn hơn.

Để phân bổ động, hãy sử dụng ZZ0000ZZ:

.. code-block:: c

	struct video_device *vdev = video_device_alloc();

	if (vdev == NULL)
		return -ENOMEM;

	vdev->release = video_device_release;

Nếu bạn nhúng nó vào cấu trúc lớn hơn thì bạn phải đặt ZZ0000ZZ
gọi lại chức năng của riêng bạn:

.. code-block:: c

	struct video_device *vdev = &my_vdev->vdev;

	vdev->release = my_vdev_release;

Cuộc gọi lại ZZ0000ZZ phải được đặt và nó được gọi khi người dùng cuối cùng
của thiết bị video thoát ra.

Lệnh gọi lại ZZ0000ZZ mặc định hiện tại
chỉ cần gọi ZZ0001ZZ để giải phóng bộ nhớ được phân bổ.

Ngoài ra còn có chức năng ZZ0000ZZ
không có gì (trống) và nên được sử dụng nếu cấu trúc được nhúng và ở đó
không có gì để làm khi nó được phát hành.

Bạn cũng nên đặt các trường này của ZZ0000ZZ:

- ZZ0000ZZ->v4l2_dev: phải được đặt thành ZZ0001ZZ
  thiết bị mẹ.

- ZZ0000ZZ->name: đặt thành nội dung mang tính mô tả và độc đáo.

- ZZ0000ZZ->vfl_dir: đặt thành ZZ0001ZZ để chụp
  thiết bị (ZZ0002ZZ có giá trị 0, vì vậy đây thường là
  mặc định), được đặt thành ZZ0003ZZ cho thiết bị đầu ra và ZZ0004ZZ cho thiết bị mem2mem (codec).

- ZZ0000ZZ->fops: đặt thành ZZ0001ZZ
  struct.

- ZZ0000ZZ->ioctl_ops: nếu bạn sử dụng ZZ0001ZZ
  để đơn giản hóa việc bảo trì ioctl (rất khuyến khích sử dụng cái này và nó có thể
  trở thành bắt buộc trong tương lai!), sau đó đặt cái này vào
  Cấu trúc ZZ0002ZZ. ZZ0003ZZ->vfl_type và
  Các trường ZZ0004ZZ->vfl_dir được sử dụng để vô hiệu hóa các hoạt động không
  khớp với sự kết hợp loại/dir. Ví dụ. Hoạt động VBI bị vô hiệu hóa đối với các nút không phải VBI,
  và các hoạt động đầu ra bị vô hiệu hóa đối với thiết bị chụp. Điều này làm cho nó có thể
  chỉ cung cấp một cấu trúc ZZ0005ZZ cho cả vbi và
  các nút video.

- ZZ0000ZZ->lock: để ZZ0002ZZ nếu bạn muốn thực hiện tất cả
  khóa tài xế. Ngược lại bạn cho nó một con trỏ tới một cấu trúc
  ZZ0003ZZ và trước ZZ0001ZZ->unlocked_ioctl
  thao tác tập tin được gọi là khóa này sẽ được lấy bởi lõi và giải phóng
  sau đó. Xem phần tiếp theo để biết thêm chi tiết.

- ZZ0000ZZ->queue: con trỏ tới struct vb2_queue
  được liên kết với nút thiết bị này.
  Nếu hàng đợi không phải là ZZ0003ZZ và hàng đợi-> khóa không phải là ZZ0004ZZ thì hàng đợi-> khóa
  được sử dụng cho các ioctls xếp hàng (ZZ0005ZZ, ZZ0006ZZ,
  ZZ0007ZZ, ZZ0008ZZ, ZZ0009ZZ, ZZ0010ZZ, ZZ0011ZZ và
  ZZ0012ZZ) thay vì khóa ở trên.
  Bằng cách đó, khung xếp hàng ZZ0001ZZ không có
  để chờ ioctls khác.   Con trỏ hàng đợi này cũng được sử dụng bởi
  Chức năng trợ giúp ZZ0002ZZ để kiểm tra
  quyền sở hữu hàng đợi (tức là tước hiệu tệp gọi nó được phép thực hiện
  hoạt động).

- ZZ0000ZZ->prio: theo dõi mức độ ưu tiên. Đã từng
  triển khai ZZ0003ZZ và ZZ0004ZZ.
  Nếu để ZZ0005ZZ thì nó sẽ sử dụng struct v4l2_prio_state
  trong ZZ0001ZZ. Nếu bạn muốn có trạng thái ưu tiên riêng cho mỗi
  (nhóm) nút thiết bị, sau đó bạn có thể trỏ nó vào cấu trúc của riêng bạn
  ZZ0002ZZ.

- ZZ0000ZZ->dev_parent: bạn chỉ thiết lập điều này nếu có v4l2_device
  đã đăng ký với ZZ0002ZZ làm cấu trúc ZZ0003ZZ gốc. Điều này chỉ xảy ra
  trong trường hợp một thiết bị phần cứng có nhiều thiết bị PCI dùng chung
  lõi ZZ0001ZZ tương tự.

Trình điều khiển cx88 là một ví dụ về điều này: cấu trúc ZZ0000ZZ một lõi,
  nhưng nó được sử dụng bởi cả thiết bị PCI video thô (cx8800) và thiết bị MPEG PCI
  (cx8802). Vì ZZ0001ZZ không thể liên kết với hai PCI
  thiết bị cùng lúc được thiết lập mà không cần thiết bị mẹ. Nhưng khi
  struct video_device được khởi tạo bạn ZZ0003ZZ biết cha mẹ nào
  Thiết bị PCI sẽ sử dụng và do đó bạn đặt ZZ0002ZZ về đúng thiết bị PCI.

Nếu bạn sử dụng ZZ0000ZZ thì bạn nên đặt
ZZ0001ZZ->unlocked_ioctl thành ZZ0002ZZ trong
Cấu trúc ZZ0003ZZ.

Trong một số trường hợp, bạn muốn nói với lõi rằng hàm bạn đã chỉ định trong
ZZ0000ZZ của bạn sẽ bị bỏ qua. Bạn có thể đánh dấu ioctls như vậy bằng cách
gọi hàm này trước ZZ0001ZZ được gọi:

ZZ0000ZZ
	(ZZ0001ZZ, cmd).

Điều này có xu hướng cần thiết nếu dựa trên các yếu tố bên ngoài (ví dụ: thẻ nào được
đang được sử dụng) bạn muốn tắt một số tính năng nhất định trong ZZ0000ZZ
mà không cần phải tạo một cấu trúc mới.

Cấu trúc ZZ0000ZZ là tập hợp con của file_Operations.
Sự khác biệt chính là đối số inode bị bỏ qua vì nó không bao giờ
đã sử dụng.

Nếu cần tích hợp với khung phương tiện, bạn phải khởi tạo
Cấu trúc ZZ0000ZZ được nhúng trong cấu trúc ZZ0001ZZ
(trường thực thể) bằng cách gọi ZZ0002ZZ:

.. code-block:: c

	struct media_pad *pad = &my_vdev->pad;
	int err;

	err = media_entity_pads_init(&vdev->entity, 1, pad);

Mảng đệm phải được khởi tạo trước đó. Không cần thiết phải
đặt thủ công các trường tên và loại struct media_entity.

Một tham chiếu đến thực thể sẽ được tự động thu thập/giải phóng khi
thiết bị video được mở/đóng.

ioctls và khóa
------------------

Lõi V4L cung cấp dịch vụ khóa tùy chọn. Dịch vụ chính là
trường khóa trong struct video_device, là một con trỏ tới một mutex.
Nếu bạn đặt con trỏ này, thì nó sẽ được unlock_ioctl sử dụng để
tuần tự hóa tất cả ioctls.

Nếu bạn đang sử dụng ZZ0000ZZ thì có
là khóa thứ hai mà bạn có thể đặt: ZZ0001ZZ->queue->lock. Nếu
được đặt thì khóa này sẽ được sử dụng thay cho ZZ0002ZZ->lock
để tuần tự hóa tất cả các ioctls đang xếp hàng (xem phần trước
để biết danh sách đầy đủ các ioctls đó).

Ưu điểm của việc sử dụng một khóa khác cho các ioctls xếp hàng là đối với một số
trình điều khiển (đặc biệt là trình điều khiển USB) một số lệnh nhất định như cài đặt điều khiển
có thể mất nhiều thời gian, vì vậy bạn muốn sử dụng một khóa riêng cho hàng đợi bộ đệm
ioctls. Bằng cách đó ZZ0000ZZ của bạn không bị chết máy vì tài xế bận
thay đổi ví dụ độ phơi sáng của webcam.

Tất nhiên, bạn luôn có thể tự mình thực hiện tất cả việc khóa bằng cách để cả hai khóa
con trỏ tại ZZ0000ZZ.

Trong trường hợp ZZ0000ZZ bạn phải đặt ZZ0001ZZ
con trỏ tới khóa bạn sử dụng để tuần tự hóa các ioctls xếp hàng. Điều này đảm bảo rằng
khóa đó được giải phóng trong khi chờ bộ đệm đến trong ZZ0002ZZ,
và nó được lấy lại sau đó.

Việc thực hiện ngắt kết nối phích cắm nóng cũng sẽ lấy khóa từ
ZZ0000ZZ trước khi gọi v4l2_device_disconnect. Nếu bạn cũng vậy
sử dụng ZZ0001ZZ->queue->lock thì trước tiên bạn phải khóa
ZZ0002ZZ->hàng->khóa, theo sau là ZZ0003ZZ->khóa.
Bằng cách đó bạn có thể chắc chắn rằng không có ioctl nào đang chạy khi bạn gọi
ZZ0004ZZ.

Đăng ký thiết bị video
-------------------------

Tiếp theo bạn đăng ký thiết bị video với ZZ0000ZZ.
Điều này sẽ tạo ra thiết bị nhân vật cho bạn.

.. code-block:: c

	err = video_register_device(vdev, VFL_TYPE_VIDEO, -1);
	if (err) {
		video_device_release(vdev); /* or kfree(my_vdev); */
		return err;
	}

Nếu thiết bị mẹ ZZ0000ZZ không có trường mdev ZZ0001ZZ,
thực thể thiết bị video sẽ được đăng ký tự động với phương tiện
thiết bị.

Thiết bị nào được đăng ký tùy thuộc vào đối số loại. Sau đây
tồn tại các loại:

================================================ ==================================
ZZ0000ZZ Tên thiết bị Cách sử dụng
================================================ ==================================
ZZ0001ZZ ZZ0002ZZ dành cho thiết bị đầu vào/đầu ra video
ZZ0003ZZ ZZ0004ZZ cho dữ liệu trống dọc (tức là
						 phụ đề chi tiết, teletext)
ZZ0005ZZ ZZ0006ZZ dành cho bộ dò đài
ZZ0007ZZ ZZ0008ZZ dành cho thiết bị con V4L2
ZZ0009ZZ ZZ0010ZZ dành cho đài phát thanh được xác định bằng phần mềm
						 Bộ điều chỉnh (SDR)
ZZ0011ZZ ZZ0012ZZ cho cảm biến cảm ứng
================================================ ==================================

Đối số cuối cùng cung cấp cho bạn một mức độ kiểm soát nhất định đối với thiết bị
số nút được sử dụng (tức là X trong ZZ0000ZZ). Thông thường bạn sẽ vượt qua -1
để khung v4l2 chọn số miễn phí đầu tiên. Nhưng đôi khi người dùng
muốn chọn một số nút cụ thể. Thông thường người lái xe cho phép
người dùng chọn số nút thiết bị cụ thể thông qua mô-đun trình điều khiển
tùy chọn. Số đó sau đó được chuyển đến hàm này và video_register_device
sẽ cố gắng chọn số nút thiết bị đó. Nếu con số đó đã
đang được sử dụng thì số nút thiết bị trống tiếp theo sẽ được chọn và nó
sẽ gửi cảnh báo tới nhật ký kernel.

Một trường hợp sử dụng khác là nếu trình điều khiển tạo ra nhiều thiết bị. Trong trường hợp đó nó có thể
hữu ích khi đặt các thiết bị video khác nhau trong các phạm vi riêng biệt. Ví dụ,
thiết bị quay video bắt đầu từ 0, thiết bị xuất video bắt đầu từ 16.
Vì vậy, bạn có thể sử dụng đối số cuối cùng để chỉ định số nút thiết bị tối thiểu
và khung v4l2 sẽ cố gắng chọn số miễn phí đầu tiên bằng
hoặc cao hơn mức bạn đã vượt qua. Nếu thất bại thì nó sẽ chỉ chọn
số miễn phí đầu tiên.

Vì trong trường hợp này bạn không quan tâm đến cảnh báo về việc không thể
để chọn số nút thiết bị được chỉ định, bạn có thể gọi hàm
Thay vào đó là ZZ0000ZZ.

Bất cứ khi nào một nút thiết bị được tạo, một số thuộc tính cũng được tạo cho bạn.
Nếu bạn nhìn vào ZZ0000ZZ, bạn sẽ thấy các thiết bị. Đi vào ví dụ
ZZ0001ZZ và bạn sẽ thấy các thuộc tính 'name', 'dev_debug' và 'index'. các
Thuộc tính 'name' là trường 'name' của cấu trúc video_device. các
Thuộc tính 'dev_debug' có thể được sử dụng để kích hoạt tính năng gỡ lỗi lõi. Xem phần tiếp theo
phần để biết thêm thông tin chi tiết về điều này.

Thuộc tính 'index' là chỉ mục của nút thiết bị: đối với mỗi lệnh gọi tới
ZZ0000ZZ chỉ số chỉ tăng thêm 1.
nút thiết bị video đầu tiên bạn đăng ký luôn bắt đầu bằng chỉ mục 0.

Người dùng có thể thiết lập các quy tắc udev sử dụng thuộc tính chỉ mục để tạo sự ưa thích
tên thiết bị (ví dụ: 'ZZ0000ZZ' cho các nút thiết bị quay video MPEG).

Sau khi thiết bị được đăng ký thành công, bạn có thể sử dụng các trường sau:

- ZZ0000ZZ->vfl_type: loại thiết bị được truyền tới
  ZZ0001ZZ.
- ZZ0002ZZ->minor: số phụ của thiết bị được gán.
- ZZ0003ZZ->num: số nút thiết bị (tức là X trong
  ZZ0005ZZ).
- ZZ0004ZZ->index: số chỉ mục của thiết bị.

Nếu đăng ký không thành công thì bạn cần gọi
ZZ0000ZZ để giải phóng ZZ0001ZZ được phân bổ
struct hoặc giải phóng cấu trúc của riêng bạn nếu ZZ0002ZZ được nhúng vào
nó. Cuộc gọi lại ZZ0003ZZ sẽ không bao giờ được gọi nếu đăng ký
không thành công, bạn cũng không nên thử hủy đăng ký thiết bị nếu
đăng ký không thành công.

gỡ lỗi thiết bị video
----------------------

Thuộc tính 'dev_debug' được tạo cho mỗi video, vbi, radio hoặc swradio
thiết bị trong ZZ0000ZZ cho phép bạn kích hoạt tính năng ghi nhật ký
hoạt động tập tin.

Nó là một bitmask và các bit sau có thể được đặt:

.. tabularcolumns:: |p{5ex}|L|

===== =====================================================================
Mô tả mặt nạ
===== =====================================================================
0x01 Ghi tên ioctl và mã lỗi. Các ioctl VIDIOC_(D)QBUF là
      chỉ được ghi nếu bit 0x08 cũng được đặt.
0x02 Ghi lại các đối số tên ioctl và mã lỗi. VIDIOC_(D)QBUF
      ioctls là
      chỉ được ghi nếu bit 0x08 cũng được đặt.
0x04 Ghi nhật ký các thao tác mở, phát hành, đọc, ghi, mmap và
      get_unmapped_area. Các thao tác đọc và ghi chỉ
      được ghi lại nếu bit 0x08 cũng được đặt.
0x08 Ghi nhật ký các thao tác đọc và ghi tệp cũng như VIDIOC_QBUF và
      VIDIOC_DQBUF ioctls.
0x10 Ghi nhật ký hoạt động của tệp thăm dò ý kiến.
0x20 Ghi lại lỗi và thông báo trong hoạt động điều khiển.
===== =====================================================================

Dọn dẹp thiết bị video
--------------------

Khi các nút thiết bị video phải được loại bỏ, trong quá trình dỡ tải
của trình điều khiển hoặc do thiết bị USB bị ngắt kết nối thì bạn nên
hủy đăng ký chúng với:

ZZ0000ZZ
	(ZZ0001ZZ);

Điều này sẽ xóa các nút thiết bị khỏi sysfs (khiến udev xóa chúng
từ ZZ0000ZZ).

Sau khi ZZ0000ZZ trả về, bạn không thể thực hiện mở mới.
Tuy nhiên, trong trường hợp thiết bị USB, một số ứng dụng vẫn có thể có một trong
các nút thiết bị này mở. Vì vậy sau khi hủy đăng ký tất cả các thao tác với tệp (ngoại trừ
tất nhiên là phát hành) cũng sẽ trả về lỗi.

Khi người dùng cuối cùng của nút thiết bị video thoát ra thì ZZ0000ZZ
gọi lại được gọi và bạn có thể thực hiện việc dọn dẹp cuối cùng ở đó.

Đừng quên dọn sạch thực thể phương tiện được liên kết với thiết bị video nếu
nó đã được khởi tạo:

ZZ0000ZZ
	(&vdev->thực thể);

Điều này có thể được thực hiện từ cuộc gọi lại phát hành.


chức năng trợ giúp
----------------

Có một số chức năng trợ giúp hữu ích:

- tập tin và dữ liệu riêng tư ZZ0000ZZ

Bạn có thể đặt/nhận dữ liệu riêng tư của trình điều khiển trong cấu trúc video_device bằng cách sử dụng:

ZZ0000ZZ
	(ZZ0001ZZ);

ZZ0000ZZ
	(ZZ0001ZZ);

Lưu ý bạn có thể yên tâm gọi ZZ0000ZZ trước khi gọi
ZZ0001ZZ.

Và chức năng này:

ZZ0000ZZ
	(tệp cấu trúc \*tệp);

trả về video_device thuộc tệp struct.

Chức năng ZZ0000ZZ kết hợp ZZ0001ZZ
với ZZ0002ZZ:

ZZ0000ZZ
	(tệp cấu trúc \*tệp);

Bạn có thể chuyển từ cấu trúc ZZ0000ZZ sang cấu trúc v4l2_device bằng cách sử dụng:

.. code-block:: c

	struct v4l2_device *v4l2_dev = vdev->v4l2_dev;

- Tên nút thiết bị

Tên hạt nhân nút ZZ0000ZZ có thể được truy xuất bằng cách sử dụng:

ZZ0000ZZ
	(ZZ0001ZZ);

Tên này được sử dụng làm gợi ý bởi các công cụ không gian người dùng như udev. chức năng
nên được sử dụng khi có thể thay vì truy cập video_device::num và
video_device::các trường nhỏ.

chức năng video_device và cấu trúc dữ liệu
------------------------------------------

.. kernel-doc:: include/media/v4l2-dev.h