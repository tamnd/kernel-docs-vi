.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/open.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _open:

****************************
Thiết bị mở và đóng
***************************

.. _v4l2_hardware_control:

Điều khiển thiết bị ngoại vi phần cứng thông qua V4L2
==========================================

Phần cứng được hỗ trợ bằng uAPI V4L2 thường bao gồm nhiều
thiết bị hoặc thiết bị ngoại vi, mỗi thiết bị đều có trình điều khiển riêng.

Trình điều khiển cầu hiển thị một hoặc nhiều nút thiết bị V4L2
(xem ZZ0000ZZ).

Có các trình điều khiển khác cung cấp hỗ trợ cho các thành phần khác của
phần cứng, cũng có thể hiển thị các nút thiết bị, được gọi là thiết bị phụ V4L2.

Khi các thiết bị phụ V4L2 như vậy được hiển thị, chúng cho phép điều khiển những thiết bị đó
các thành phần phần cứng khác - thường được kết nối qua bus nối tiếp (như
I²C, SMBus hoặc SPI). Tùy thuộc vào trình điều khiển cầu nối, các thiết bị phụ đó
có thể được điều khiển gián tiếp thông qua trình điều khiển cầu hoặc rõ ràng thông qua
ZZ0000ZZ và thông qua
ZZ0001ZZ.

Các thiết bị yêu cầu sử dụng
ZZ0000ZZ được gọi là ZZ0001ZZ
thiết bị. Các thiết bị được điều khiển hoàn toàn thông qua các nút thiết bị V4L2
được gọi là ZZ0002ZZ.

Không gian người dùng có thể kiểm tra xem thiết bị ngoại vi phần cứng V4L2 có tập trung vào MC hay không bằng cách
gọi ZZ0000ZZ và kiểm tra
ZZ0001ZZ.

Nếu thiết bị trả về cờ ZZ0000ZZ tại ZZ0001ZZ,
thì nó lấy MC làm trung tâm, nếu không thì lấy nút video làm trung tâm.

Trình điều khiển lấy MC làm trung tâm cần phải xác định V4L2
các thiết bị phụ và cấu hình các đường ống thông qua
ZZ0000ZZ trước khi sử dụng thiết bị ngoại vi.
Ngoài ra, cấu hình của các thiết bị phụ sẽ được điều khiển thông qua
ZZ0001ZZ.

.. note::

   A video-node-centric may still provide media-controller and
   sub-device interfaces as well.

  However, in that case the media-controller and the sub-device
  interfaces are read-only and just provide information about the
  device. The actual configuration is done via the video nodes.

.. _v4l2_device_naming:

Đặt tên nút thiết bị V4L2
=======================

Trình điều khiển V4L2 được triển khai dưới dạng mô-đun hạt nhân, được tải thủ công bởi
quản trị viên hệ thống hoặc tự động khi thiết bị được phát hiện lần đầu tiên.
Các mô-đun trình điều khiển cắm vào mô-đun hạt nhân ZZ0000ZZ. Nó cung cấp
các chức năng trợ giúp và giao diện ứng dụng chung được chỉ định trong phần này
tài liệu.

Do đó, mỗi trình điều khiển được tải sẽ đăng ký một hoặc nhiều nút thiết bị có chức năng chính
số 81. Các số nhỏ được phân bổ động trừ khi kernel
được biên dịch với tùy chọn kernel CONFIG_VIDEO_FIXED_MINOR_RANGES.
Trong trường hợp đó, các số thứ yếu được phân bổ theo phạm vi tùy thuộc vào
loại nút thiết bị.

Các nút thiết bị được hệ thống con Video4Linux hỗ trợ là:

==================================================================================
Tên nút thiết bị mặc định Cách sử dụng
==================================================================================
ZZ0000ZZ Video và siêu dữ liệu cho thiết bị ghi/xuất
ZZ0001ZZ Dữ liệu trống dọc (tức là phụ đề chi tiết, teletext)
ZZ0002ZZ Bộ điều chỉnh và điều chế đài phát thanh
ZZ0003ZZ Bộ điều chỉnh và điều chế sóng vô tuyến được xác định bằng phần mềm
Cảm biến cảm ứng ZZ0004ZZ
ZZ0005ZZ Thiết bị phụ video (được sử dụng bởi cảm biến và các thiết bị khác
			 các thành phần của thiết bị ngoại vi phần cứng)\ [#]_
==================================================================================

Trong đó ZZ0000ZZ là số nguyên không âm.

.. note::

   1. The actual device node name is system-dependent, as udev rules may apply.
   2. There is no guarantee that ``X`` will remain the same for the same
      device, as the number depends on the device driver's probe order.
      If you need an unique name, udev default rules produce
      ``/dev/v4l/by-id/`` and ``/dev/v4l/by-path/`` directories containing
      links that can be used uniquely to identify a V4L2 device node::

	$ tree /dev/v4l
	/dev/v4l
	├── by-id
	│   └── usb-OmniVision._USB_Camera-B4.04.27.1-video-index0 -> ../../video0
	└── by-path
	    └── pci-0000:00:14.0-usb-0:2:1.0-video-index0 -> ../../video0

.. [#] **V4L2 sub-device nodes** (e. g. ``/dev/v4l-subdevX``) use a different
       set of system calls, as covered at :ref:`subdev`.

Nhiều trình điều khiển hỗ trợ mô-đun "video_nr", "radio_nr" hoặc "vbi_nr"
tùy chọn để chọn số nút video/radio/vbi cụ thể. Điều này cho phép
người dùng yêu cầu nút thiết bị được đặt tên, ví dụ: /dev/video5 thay vào đó
để nó có cơ hội. Khi trình điều khiển hỗ trợ nhiều thiết bị của
cùng một loại, nhiều số nút thiết bị có thể được chỉ định,
cách nhau bằng dấu phẩy:

.. code-block:: none

   # modprobe mydriver video_nr=0,1 radio_nr=0,1

Trong ZZ0000ZZ điều này có thể được viết là:

::

tùy chọn mydriver video_nr=0,1 radio_nr=0,1

Khi không có số nút thiết bị nào được cung cấp dưới dạng tùy chọn mô-đun, trình điều khiển sẽ cung cấp
một mặc định.

Thông thường udev sẽ tự động tạo các nút thiết bị trong /dev cho
bạn. Nếu udev chưa được cài đặt thì bạn cần kích hoạt
Tùy chọn kernel CONFIG_VIDEO_FIXED_MINOR_RANGES để có thể
liên kết chính xác một số phụ với số nút thiết bị. Tức là bạn cần
để chắc chắn rằng số 5 phụ sẽ ánh xạ tới tên nút thiết bị video5. Với
tùy chọn kernel này, các loại thiết bị khác nhau có số thứ tự khác nhau
phạm vi. Các phạm vi này được liệt kê trong ZZ0000ZZ.

Việc tạo các tệp ký tự đặc biệt (với mknod) là một đặc quyền
hoạt động và thiết bị không thể được mở bằng số lớn và số phụ. Đó
có nghĩa là các ứng dụng không thể quét ZZ0000ZZ để tải hoặc cài đặt
trình điều khiển. Người dùng phải nhập tên thiết bị hoặc ứng dụng có thể thử
tên thiết bị thông thường.

.. _related:

Thiết bị liên quan
===============

Thiết bị có thể hỗ trợ một số chức năng. Ví dụ: quay video, VBI
hỗ trợ thu thập và vô tuyến.

V4L2 API tạo các nút thiết bị V4L2 khác nhau cho từng chức năng này.

V4L2 API được thiết kế với ý tưởng rằng một nút thiết bị có thể
hỗ trợ mọi chức năng. Tuy nhiên, trong thực tế điều này không bao giờ có tác dụng: điều này
'tính năng' chưa bao giờ được các ứng dụng sử dụng và nhiều trình điều khiển cũng không
ủng hộ nó và nếu họ làm vậy thì chắc chắn nó chưa bao giờ được thử nghiệm. Ngoài ra,
chuyển đổi một nút thiết bị giữa các chức năng khác nhau chỉ hoạt động khi
sử dụng I/O API phát trực tuyến, không phải với
ZZ0000ZZ/\ ZZ0001ZZ API.

Ngày nay, mỗi nút thiết bị V4L2 chỉ hỗ trợ một chức năng.

Bên cạnh đầu vào hoặc đầu ra video, phần cứng cũng có thể hỗ trợ âm thanh
lấy mẫu hoặc phát lại. Nếu vậy, các chức năng này được triển khai dưới dạng ALSA PCM
các thiết bị có thiết bị trộn âm thanh ALSA tùy chọn.

Một vấn đề với tất cả các thiết bị này là V4L2 API không
điều khoản để tìm các nút thiết bị V4L2 có liên quan này. Một số thực sự phức tạp
phần cứng sử dụng Bộ điều khiển phương tiện (xem ZZ0000ZZ) có thể
được sử dụng cho mục đích này. Nhưng một số trình điều khiển không sử dụng nó, và trong khi một số
tồn tại mã sử dụng sysfs để khám phá các nút thiết bị V4L2 có liên quan (xem
libmedia_dev trong
ZZ0001ZZ git
kho lưu trữ), chưa có thư viện nào có thể cung cấp một API duy nhất
đối với cả thiết bị dựa trên Bộ điều khiển phương tiện và thiết bị không sử dụng
Bộ điều khiển phương tiện. Nếu bạn muốn làm việc này xin vui lòng viết thư cho
danh sách gửi thư linux-media:
ZZ0002ZZ.

Nhiều lần mở
==============

Các thiết bị V4L2 có thể được mở nhiều lần. [#f1]_ Khi điều này được hỗ trợ
bởi trình điều khiển, ví dụ, người dùng có thể khởi động ứng dụng "bảng điều khiển" để
thay đổi các điều khiển như độ sáng hoặc âm lượng, trong khi các điều khiển khác
ứng dụng ghi lại video và âm thanh. Nói cách khác, các ứng dụng bảng điều khiển
có thể so sánh với ứng dụng trộn âm thanh ALSA. Chỉ cần mở V4L2
thiết bị không nên thay đổi trạng thái của thiết bị. [#f2]_

Khi một ứng dụng đã phân bổ bộ đệm bộ nhớ cần thiết cho
truyền dữ liệu (bằng cách gọi ZZ0000ZZ
hoặc ZZ0001ZZ ioctls, hoặc
ngầm bằng cách gọi ZZ0002ZZ hoặc
chức năng ZZ0003ZZ) ứng dụng đó (filehandle)
trở thành chủ sở hữu của thiết bị. Nó không còn được phép thực hiện thay đổi
điều đó sẽ ảnh hưởng đến kích thước bộ đệm (ví dụ: bằng cách gọi
ZZ0004ZZ ioctl) và các ứng dụng khác
không còn được phép phân bổ bộ đệm hoặc bắt đầu hoặc dừng phát trực tuyến. các
Thay vào đó, mã lỗi EBUSY sẽ được trả về.

Chỉ mở thiết bị V4L2 không cấp quyền truy cập độc quyền. [#f3]_
Tuy nhiên, việc bắt đầu trao đổi dữ liệu sẽ gán quyền đọc hoặc ghi
loại dữ liệu được yêu cầu và thay đổi các thuộc tính liên quan đối với tệp này
mô tả. Ứng dụng có thể yêu cầu đặc quyền truy cập bổ sung bằng cách sử dụng
cơ chế ưu tiên được mô tả trong ZZ0000ZZ.

Luồng dữ liệu được chia sẻ
===================

Trình điều khiển V4L2 không được hỗ trợ nhiều ứng dụng đọc hoặc ghi
cùng một luồng dữ liệu trên một thiết bị bằng cách sao chép bộ đệm, ghép kênh thời gian
hoặc các phương tiện tương tự. Điều này được xử lý tốt hơn bởi ứng dụng proxy trong user
không gian.

Chức năng
=========

Để mở và đóng các ứng dụng trên thiết bị V4L2, hãy sử dụng
Chức năng ZZ0000ZZ và ZZ0001ZZ,
tương ứng. Các thiết bị được lập trình bằng cách sử dụng
Chức năng ZZ0002ZZ như được giải thích sau đây
phần.

.. [#f1]
   There are still some old and obscure drivers that have not been
   updated to allow for multiple opens. This implies that for such
   drivers :c:func:`open()` can return an ``EBUSY`` error code
   when the device is already in use.

.. [#f2]
   Unfortunately, opening a radio device often switches the state of the
   device to radio mode in many drivers. This behavior should be fixed
   eventually as it violates the V4L2 specification.

.. [#f3]
   Drivers could recognize the ``O_EXCL`` open flag. Presently this is
   not required, so applications cannot know if it really works.