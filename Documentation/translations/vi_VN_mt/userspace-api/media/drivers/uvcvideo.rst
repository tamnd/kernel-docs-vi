.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/uvcvideo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển Lớp video Linux USB (UVC)
======================================

Tệp này ghi lại một số khía cạnh dành riêng cho trình điều khiển của trình điều khiển UVC, chẳng hạn như
ioctls dành riêng cho trình điều khiển và ghi chú triển khai.

Các câu hỏi và nhận xét có thể được gửi đến danh sách gửi thư phát triển Linux UVC tại
linux-media@vger.kernel.org.


Hỗ trợ Đơn vị mở rộng (XU)
---------------------------

Giới thiệu
~~~~~~~~~~~~

Thông số kỹ thuật UVC cho phép các tiện ích mở rộng dành riêng cho nhà cung cấp thông qua tiện ích mở rộng
đơn vị (XU). Trình điều khiển Linux UVC hỗ trợ điều khiển thiết bị mở rộng (điều khiển XU)
thông qua hai cơ chế riêng biệt:

- thông qua ánh xạ các điều khiển XU tới các điều khiển V4L2
  - thông qua giao diện ioctl dành riêng cho trình điều khiển

Cái đầu tiên cho phép các ứng dụng V4L2 chung sử dụng các điều khiển XU bằng cách ánh xạ
một số điều khiển XU nhất định trên các điều khiển V4L2, sau đó sẽ hiển thị trong quá trình điều khiển thông thường
kiểm soát việc liệt kê.

Cơ chế thứ hai yêu cầu kiến thức cụ thể về uvcvideo để ứng dụng có thể
truy cập các điều khiển XU nhưng hiển thị toàn bộ khái niệm UVC XU cho không gian người dùng
sự linh hoạt tối đa.

Cả hai cơ chế này bổ sung cho nhau và được mô tả chi tiết hơn dưới đây.


Kiểm soát ánh xạ
~~~~~~~~~~~~~~~~

Trình điều khiển UVC cung cấp API cho các ứng dụng không gian người dùng để xác định cái gọi là
kiểm soát ánh xạ trong thời gian chạy. Những điều này cho phép điều khiển XU riêng lẻ hoặc byte
phạm vi của chúng sẽ được ánh xạ tới các điều khiển V4L2 mới. Những điều khiển như vậy xuất hiện và
hoạt động chính xác như các điều khiển V4L2 bình thường (tức là các điều khiển gốc, chẳng hạn như
độ sáng, độ tương phản, v.v.). Tuy nhiên, việc đọc hoặc ghi các điều khiển V4L2 như vậy
kích hoạt việc đọc hoặc ghi điều khiển XU liên quan.

Ioctl được sử dụng để tạo các ánh xạ điều khiển này được gọi là UVCIOC_CTRL_MAP.
Các phiên bản trình điều khiển trước đó (trước 0.2.0) yêu cầu sử dụng ioctl khác
trước (UVCIOC_CTRL_ADD) để chuyển thông tin điều khiển XU tới trình điều khiển UVC.
Điều này không còn cần thiết vì các phiên bản uvcvideo mới hơn truy vấn thông tin
trực tiếp từ thiết bị.

Để biết chi tiết về UVCIOC_CTRL_MAP ioctl, vui lòng tham khảo phần có tiêu đề
"Tham khảo IOCTL" bên dưới.


3. Giao diện điều khiển XU dành riêng cho trình điều khiển

Đối với các ứng dụng cần truy cập trực tiếp vào các điều khiển XU, ví dụ: để thử nghiệm
mục đích, tải lên chương trình cơ sở hoặc truy cập các điều khiển nhị phân, một cơ chế thứ hai để
các điều khiển truy cập XU được cung cấp dưới dạng ioctl dành riêng cho trình điều khiển, cụ thể là
UVCIOC_CTRL_QUERY.

Cuộc gọi tới ioctl này cho phép các ứng dụng gửi truy vấn tới trình điều khiển UVC
ánh xạ trực tiếp tới các yêu cầu điều khiển UVC cấp thấp.

Để thực hiện yêu cầu như vậy, ID thiết bị UVC của thiết bị mở rộng của điều khiển
và bộ chọn điều khiển cần phải được biết. Thông tin này hoặc cần phải được
được mã hóa cứng trong ứng dụng hoặc được truy vấn bằng các cách khác như phân tích cú pháp
Bộ mô tả UVC hoặc, nếu có, sử dụng bộ điều khiển phương tiện API để liệt kê một
các thực thể của thiết bị.

Trừ khi đã biết kích thước điều khiển, trước tiên cần phải thực hiện
UVC_GET_LEN yêu cầu để có thể phân bổ bộ đệm đủ lớn
và đặt kích thước bộ đệm thành giá trị chính xác. Tương tự, để tìm hiểu xem
UVC_GET_CUR hoặc UVC_SET_CUR là các yêu cầu hợp lệ cho một điều khiển nhất định, một
Yêu cầu UVC_GET_INFO nên được thực hiện. Các bit 0 (được hỗ trợ GET) và 1 (SET
được hỗ trợ) của byte kết quả cho biết yêu cầu nào hợp lệ.

Với việc bổ sung UVCIOC_CTRL_QUERY ioctl UVCIOC_CTRL_GET và
UVCIOC_CTRL_SET ioctls đã trở nên lỗi thời vì chức năng của chúng là một
tập hợp con của ioctl trước đây. Hiện tại họ vẫn được hỗ trợ nhưng
thay vào đó, các nhà phát triển ứng dụng được khuyến khích sử dụng UVCIOC_CTRL_QUERY.

Để biết chi tiết về UVCIOC_CTRL_QUERY ioctl, vui lòng tham khảo phần có tiêu đề
"Tham khảo IOCTL" bên dưới.


Bảo vệ
~~~~~~~~

API hiện không cung cấp cơ sở kiểm soát truy cập chi tiết. các
UVCIOC_CTRL_ADD và UVCIOC_CTRL_MAP ioctls yêu cầu quyền siêu người dùng.

Đề xuất về cách cải thiện điều này đều được chào đón.


Gỡ lỗi
~~~~~~~~~

Để gỡ lỗi các vấn đề liên quan đến điều khiển XU hoặc điều khiển nói chung,
được khuyến nghị kích hoạt bit UVC_TRACE_CONTROL trong tham số mô-đun 'dấu vết'.
Điều này khiến đầu ra bổ sung được ghi vào nhật ký hệ thống.


Tham khảo IOCTL
~~~~~~~~~~~~~~~

UVCIOC_CTRL_MAP - Ánh xạ điều khiển UVC sang điều khiển V4L2
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đối số: struct uvc_xu_control_mapping

ZZ0000ZZ:

Ioctl này tạo ánh xạ giữa điều khiển UVC hoặc một phần của UVC
	điều khiển và điều khiển V4L2. Khi ánh xạ được xác định, không gian người dùng
	các ứng dụng có thể truy cập điều khiển UVC do nhà cung cấp xác định thông qua V4L2
	điều khiển API.

Để tạo ánh xạ, các ứng dụng hãy điền vào uvc_xu_control_mapping
	cấu trúc với thông tin về điều khiển UVC hiện có được xác định bằng
	UVCIOC_CTRL_ADD và bộ điều khiển V4L2 mới.

Điều khiển UVC có thể được ánh xạ tới một số điều khiển V4L2. Ví dụ,
	điều khiển xoay/nghiêng UVC có thể được ánh xạ để tách xoay và nghiêng V4L2
	điều khiển. Điều khiển UVC được chia thành các trường không chồng chéo bằng cách sử dụng
	các trường 'kích thước' và 'bù' và sau đó được ánh xạ độc lập tới
	Điều khiển V4L2.

Đối với các điều khiển số nguyên có dấu V4L2, trường data_type phải được đặt thành
	UVC_CTRL_DATA_TYPE_SIGNED. Các giá trị khác hiện bị bỏ qua.

ZZ0000ZZ:

Khi thành công 0 được trả về. Khi có lỗi -1 được trả về và errno được đặt
	một cách thích hợp.

ENOMEM
		Không đủ bộ nhớ để thực hiện thao tác.
	EPERM
		Không đủ đặc quyền (cần có đặc quyền siêu người dùng).
	EINVAL
		Không có điều khiển UVC như vậy.
	EOVERFLOW
		Độ lệch và kích thước được yêu cầu sẽ vượt quá điều khiển UVC.
	EEXIST
		Bản đồ đã tồn tại.

ZZ0000ZZ:

.. code-block:: none

	* struct uvc_xu_control_mapping

	__u32	id		V4L2 control identifier
	__u8	name[32]	V4L2 control name
	__u8	entity[16]	UVC extension unit GUID
	__u8	selector	UVC control selector
	__u8	size		V4L2 control size (in bits)
	__u8	offset		V4L2 control offset (in bits)
	enum v4l2_ctrl_type
		v4l2_type	V4L2 control type
	enum uvc_control_data_type
		data_type	UVC control data type
	struct uvc_menu_info
		*menu_info	Array of menu entries (for menu controls only)
	__u32	menu_count	Number of menu entries (for menu controls only)

	* struct uvc_menu_info

	__u32	value		Menu entry value used by the device
	__u8	name[32]	Menu entry name


	* enum uvc_control_data_type

	UVC_CTRL_DATA_TYPE_RAW		Raw control (byte array)
	UVC_CTRL_DATA_TYPE_SIGNED	Signed integer
	UVC_CTRL_DATA_TYPE_UNSIGNED	Unsigned integer
	UVC_CTRL_DATA_TYPE_BOOLEAN	Boolean
	UVC_CTRL_DATA_TYPE_ENUM		Enumeration
	UVC_CTRL_DATA_TYPE_BITMASK	Bitmask
	UVC_CTRL_DATA_TYPE_RECT		Rectangular area


UVCIOC_CTRL_QUERY - Truy vấn điều khiển UVC XU
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Đối số: struct uvc_xu_control_query

ZZ0000ZZ:

Ioctl này truy vấn điều khiển UVC XU được xác định bởi ID đơn vị mở rộng của nó
	và bộ chọn điều khiển.

Có sẵn một số truy vấn khác nhau chặt chẽ
	tương ứng với các yêu cầu điều khiển cấp thấp được mô tả trong UVC
	đặc điểm kỹ thuật. Những yêu cầu này là:

UVC_GET_CUR
		Lấy giá trị hiện tại của điều khiển.
	UVC_GET_MIN
		Lấy giá trị nhỏ nhất của điều khiển.
	UVC_GET_MAX
		Lấy giá trị lớn nhất của điều khiển.
	UVC_GET_DEF
		Lấy giá trị mặc định của điều khiển.
	UVC_GET_RES
		Truy vấn độ phân giải của điều khiển, tức là kích thước bước của
		giá trị điều khiển cho phép.
	UVC_GET_LEN
		Truy vấn kích thước của điều khiển theo byte.
	UVC_GET_INFO
		Truy vấn bitmap thông tin điều khiển, cho biết liệu
		yêu cầu nhận/đặt được hỗ trợ.
	UVC_SET_CUR
		Cập nhật giá trị của điều khiển.

Các ứng dụng phải đặt trường 'kích thước' có độ dài chính xác cho
	kiểm soát. Ngoại lệ là các truy vấn UVC_GET_LEN và UVC_GET_INFO, dành cho
	trong đó kích thước phải được đặt tương ứng là 2 và 1. Trường 'dữ liệu'
	phải trỏ đến một bộ đệm có thể ghi hợp lệ đủ lớn để chứa thông tin được chỉ định
	số byte dữ liệu.

Dữ liệu được sao chép trực tiếp từ thiết bị mà không cần bất kỳ trình điều khiển nào
	xử lý. Các ứng dụng chịu trách nhiệm định dạng bộ đệm dữ liệu,
	bao gồm chuyển đổi endian nhỏ/endian lớn. Điều này đặc biệt
	quan trọng đối với kết quả của các yêu cầu UVC_GET_LEN, điều này luôn luôn
	được thiết bị trả về dưới dạng số nguyên 16 bit cuối nhỏ.

ZZ0000ZZ:

Khi thành công 0 được trả về. Khi có lỗi -1 được trả về và errno được đặt
	một cách thích hợp.

ENOENT
		Thiết bị không hỗ trợ điều khiển nhất định hoặc chỉ định
		đơn vị mở rộng không thể được tìm thấy.
	ENOBUFS
		Kích thước bộ đệm được chỉ định không chính xác (quá lớn hoặc quá nhỏ).
	EINVAL
		Mã yêu cầu không hợp lệ đã được thông qua.
	EBADRQC
		Yêu cầu đã cho không được hỗ trợ bởi điều khiển đã cho.
	EFAULT
		Con trỏ dữ liệu tham chiếu vùng bộ nhớ không thể truy cập được.

ZZ0000ZZ:

.. code-block:: none

	* struct uvc_xu_control_query

	__u8	unit		Extension unit ID
	__u8	selector	Control selector
	__u8	query		Request code to send to the device
	__u16	size		Control data size (in bytes)
	__u8	*data		Control value


Điều khiển V4L2 dành riêng cho trình điều khiển
-----------------------------

Trình điều khiển uvcvideo triển khai các điều khiển dành riêng cho UVC sau:

ZZ0001ZZ
	Điều khiển này xác định vùng quan tâm (ROI). ROI là một
	diện tích hình chữ nhật được biểu diễn bằng cấu trúc ZZ0000ZZ. các
	hình chữ nhật nằm trong tọa độ cảm biến toàn cầu sử dụng đơn vị pixel. Đó là
	độc lập với trường nhìn, không bị ảnh hưởng bởi bất kỳ việc cắt xén hoặc
	nhân rộng.

Sử dụng ZZ0000ZZ và ZZ0001ZZ để truy vấn
	phạm vi kích thước hình chữ nhật.

Đặt ROI cho phép máy ảnh tối ưu hóa khả năng chụp cho khu vực.
	Giá trị của điều khiển ZZ0000ZZ xác định
	hành vi chi tiết.

Một ví dụ về việc sử dụng điều khiển này có thể được tìm thấy trong:
	ZZ0000ZZ


ZZ0000ZZ
	Điều này xác định các tính năng trên máy bay, nếu có, sẽ theo dõi tới
	Vùng quan tâm được chỉ định bởi giá trị hiện tại của
	ZZ0001ZZ.

Giá trị tối đa là mặt nạ cho biết tất cả các Điều khiển tự động được hỗ trợ.

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_EXPOSURE``
      - Setting this bit causes automatic exposure to track the region of
	interest instead of the whole image.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_IRIS``
      - Setting this bit causes automatic iris to track the region of interest
        instead of the whole image.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_WHITE_BALANCE``
      - Setting this bit causes automatic white balance to track the region
	of interest instead of the whole image.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_FOCUS``
      - Setting this bit causes automatic focus adjustment to track the region
        of interest instead of the whole image.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_FACE_DETECT``
      - Setting this bit causes automatic face detection to track the region of
        interest instead of the whole image.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_DETECT_AND_TRACK``
      - Setting this bit enables automatic face detection and tracking. The
	current value of ``V4L2_CID_REGION_OF_INTEREST_RECT`` may be updated by
	the driver.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_IMAGE_STABILIZATION``
      - Setting this bit enables automatic image stabilization. The
	current value of ``V4L2_CID_REGION_OF_INTEREST_RECT`` may be updated by
	the driver.
    * - ``V4L2_UVC_REGION_OF_INTEREST_AUTO_HIGHER_QUALITY``
      - Setting this bit enables automatically capture the specified region
        with higher quality if possible.