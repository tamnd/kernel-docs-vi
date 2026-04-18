.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/gadget_uvc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Trình điều khiển tiện ích Linux UVC
=======================

Tổng quan
--------
Trình điều khiển Tiện ích UVC là trình điều khiển cho phần cứng ở phía ZZ0000ZZ của USB
kết nối. Nó được thiết kế để chạy trên hệ thống Linux có phía thiết bị USB
phần cứng như bo mạch có cổng OTG.

Trên hệ thống thiết bị, khi trình điều khiển được liên kết, nó sẽ xuất hiện dưới dạng thiết bị V4L2 với
khả năng đầu ra.

Ở phía máy chủ (sau khi được kết nối qua cáp USB), một thiết bị chạy Tiện ích UVC
trình điều khiển ZZ0000ZZ sẽ xuất hiện dưới dạng UVC
máy ảnh tuân thủ thông số kỹ thuật và hoạt động phù hợp với bất kỳ chương trình nào
được thiết kế để xử lý chúng. Chương trình không gian người dùng đang chạy trên hệ thống thiết bị có thể
xếp hàng bộ đệm hình ảnh từ nhiều nguồn khác nhau để truyền qua USB
kết nối. Thông thường, điều này có nghĩa là chuyển tiếp bộ đệm từ cảm biến máy ảnh
ngoại vi, nhưng nguồn của bộ đệm hoàn toàn phụ thuộc vào không gian người dùng
chương trình đồng hành.

Cấu hình kernel thiết bị
-----------------------------
Các tùy chọn Kconfig USB_CONFIGFS, USB_LIBCOMPOSITE, USB_CONFIGFS_F_UVC và
USB_F_UVC phải được chọn để kích hoạt hỗ trợ cho tiện ích UVC.

Định cấu hình tiện ích thông qua configfs
---------------------------------------
Tiện ích UVC dự kiến ​​sẽ được định cấu hình thông qua configfs bằng chức năng UVC.
Điều này cho phép mức độ linh hoạt đáng kể, vì nhiều thiết bị UVC
cài đặt có thể được kiểm soát theo cách này.

Không phải tất cả các thuộc tính có sẵn đều được mô tả ở đây. Để liệt kê đầy đủ
xem Tài liệu/ABI/testing/configfs-usb-gadget-uvc

Giả định
~~~~~~~~~~~
Phần này giả định rằng bạn đã gắn các cấu hình tại ZZ0000ZZ và
đã tạo một tiện ích có tên ZZ0001ZZ.

Chức năng UVC
~~~~~~~~~~~~~~~~

Bước đầu tiên là tạo hàm UVC:

.. code-block:: bash

	# These variables will be assumed throughout the rest of the document
	CONFIGFS="/sys/kernel/config"
	GADGET="$CONFIGFS/usb_gadget/g1"
	FUNCTION="$GADGET/functions/uvc.0"

	mkdir -p $FUNCTION

Định dạng và Khung
~~~~~~~~~~~~~~~~~~

Bạn cũng phải định cấu hình tiện ích bằng cách cho nó biết bạn hỗ trợ những định dạng nào
như kích thước khung hình và khoảng thời gian khung hình được hỗ trợ cho từng định dạng. trong
việc triển khai hiện tại không có cách nào để tiện ích từ chối đặt
định dạng mà máy chủ hướng dẫn nó thiết lập, vì vậy điều quan trọng là bước này phải được thực hiện
đã hoàn thành ZZ0000ZZ để đảm bảo rằng máy chủ không bao giờ yêu cầu định dạng
không thể được cung cấp.

Các định dạng được tạo theo cấu hình phát trực tuyến/không nén và phát trực tuyến/mjpeg
các nhóm, với các kích thước khung được tạo theo các định dạng sau
cấu trúc:

::

uvc.0 +
	      |
	      + phát trực tuyến +
			  |
			  + mjpeg +
			  ZZ0000ZZ
			  |       + mjpeg +
			  ZZ0001ZZ
			  |	       + 720p
			  ZZ0002ZZ
			  |	       + 1080p
			  |
			  + không nén +
					 |
					 + yuyv +
						|
						+ 720p
						|
						+ 1080p

Sau đó, mỗi khung có thể được cấu hình với chiều rộng và chiều cao, cộng với giá trị tối đa
kích thước bộ đệm cần thiết để lưu trữ một khung hình duy nhất và cuối cùng với hỗ trợ
khoảng thời gian khung cho định dạng và kích thước khung hình đó. Chiều rộng và chiều cao được liệt kê trong
đơn vị pixel, khoảng thời gian khung hình theo đơn vị 100ns. Để tạo ra cấu trúc
ở trên với các khoảng thời gian khung hình 2, 15 và 100 khung hình/giây cho mỗi kích thước khung hình, chẳng hạn như bạn
có thể làm:

.. code-block:: bash

	create_frame() {
		# Example usage:
		# create_frame <width> <height> <group> <format name>

		WIDTH=$1
		HEIGHT=$2
		FORMAT=$3
		NAME=$4

		wdir=$FUNCTION/streaming/$FORMAT/$NAME/${HEIGHT}p

		mkdir -p $wdir
		echo $WIDTH > $wdir/wWidth
		echo $HEIGHT > $wdir/wHeight
		echo $(( $WIDTH * $HEIGHT * 2 )) > $wdir/dwMaxVideoFrameBufferSize
		cat <<EOF > $wdir/dwFrameInterval
	666666
	100000
	5000000
	EOF
	}

	create_frame 1280 720 mjpeg mjpeg
	create_frame 1920 1080 mjpeg mjpeg
	create_frame 1280 720 uncompressed yuyv
	create_frame 1920 1080 uncompressed yuyv

Định dạng không nén duy nhất hiện được hỗ trợ là YUYV, được trình bày chi tiết tại
Tài liệu/userspace-api/media/v4l/pixfmt-packed-yuv.rst.

Bộ mô tả khớp màu
~~~~~~~~~~~~~~~~~~~~~~~~~~
Có thể chỉ định một số thông tin đo màu cho từng định dạng bạn tạo.
Bước này là tùy chọn và thông tin mặc định sẽ được đưa vào nếu bước này được
bỏ qua; các giá trị mặc định đó tuân theo các giá trị được xác định trong Bộ mô tả khớp màu
phần của đặc tả UVC.

Để tạo Bộ mô tả khớp màu, hãy tạo một mục configfs và đặt ba
thuộc tính cho cài đặt mong muốn của bạn và sau đó liên kết với nó từ định dạng bạn muốn
nó được liên kết với:

.. code-block:: bash

	# Create a new Color Matching Descriptor

	mkdir $FUNCTION/streaming/color_matching/yuyv
	pushd $FUNCTION/streaming/color_matching/yuyv

	echo 1 > bColorPrimaries
	echo 1 > bTransferCharacteristics
	echo 4 > bMatrixCoefficients

	popd

	# Create a symlink to the Color Matching Descriptor from the format's config item
	ln -s $FUNCTION/streaming/color_matching/yuyv $FUNCTION/streaming/uncompressed/yuyv

Để biết chi tiết về các giá trị hợp lệ, hãy tham khảo thông số kỹ thuật UVC. Lưu ý rằng một
bộ mô tả khớp màu mặc định tồn tại và được sử dụng bởi bất kỳ định dạng nào có
không có liên kết đến Bộ mô tả khớp màu khác. Có thể
thay đổi cài đặt thuộc tính cho bộ mô tả mặc định, vì vậy hãy nhớ rằng nếu
bạn làm như vậy là bạn đang thay đổi các giá trị mặc định cho bất kỳ định dạng nào không liên kết tới
một cái khác.


Liên kết tiêu đề
~~~~~~~~~~~~~~

Đặc tả UVC yêu cầu các bộ mô tả Định dạng và Khung phải được đặt trước bởi
Tiêu đề nêu chi tiết những thứ như số lượng và kích thước tích lũy của các phần khác nhau
Định dạng mô tả theo sau. Hoạt động này và các hoạt động tương tự đạt được trong
configfs bằng cách liên kết giữa mục configfs đại diện cho tiêu đề và
các mục cấu hình đại diện cho các bộ mô tả khác đó, theo cách này:

.. code-block:: bash

	mkdir $FUNCTION/streaming/header/h

	# This section links the format descriptors and their associated frames
	# to the header
	cd $FUNCTION/streaming/header/h
	ln -s ../../uncompressed/yuyv
	ln -s ../../mjpeg/mjpeg

	# This section ensures that the header will be transmitted for each
	# speed's set of descriptors. If support for a particular speed is not
	# needed then it can be skipped here.
	cd ../../class/fs
	ln -s ../../header/h
	cd ../../class/hs
	ln -s ../../header/h
	cd ../../class/ss
	ln -s ../../header/h
	cd ../../../control
	mkdir header/h
	ln -s header/h class/fs
	ln -s header/h class/ss


Hỗ trợ đơn vị mở rộng
~~~~~~~~~~~~~~~~~~~~~~

Thiết bị mở rộng UVC (XU) về cơ bản cung cấp một thiết bị riêng biệt cho bộ điều khiển
và nhận được yêu cầu có thể được giải quyết. Ý nghĩa của những yêu cầu kiểm soát đó là
hoàn toàn phụ thuộc vào việc triển khai nhưng có thể được sử dụng để kiểm soát các cài đặt bên ngoài
của thông số kỹ thuật UVC (ví dụ: bật hoặc tắt hiệu ứng video). Một
XU có thể được lắp vào chuỗi đơn vị UVC hoặc treo tự do.

Việc định cấu hình thiết bị mở rộng bao gồm việc tạo một mục nhập trong
thư mục và thiết lập các thuộc tính của nó một cách thích hợp, như vậy:

.. code-block:: bash

	mkdir $FUNCTION/control/extensions/xu.0
	pushd $FUNCTION/control/extensions/xu.0

	# Set the bUnitID of the Processing Unit as the source for this
	# Extension Unit
	echo 2 > baSourceID

	# Set this XU as the source of the default output terminal. This inserts
	# the XU into the UVC chain between the PU and OT such that the final
	# chain is IT > PU > XU.0 > OT
	cat bUnitID > ../../terminal/output/default/baSourceID

	# Flag some controls as being available for use. The bmControl field is
	# a bitmap with each bit denoting the availability of a particular
	# control. For example to flag the 0th, 2nd and 3rd controls available:
	echo 0x0d > bmControls

	# Set the GUID; this is a vendor-specific code identifying the XU.
	echo -e -n "\x01\x02\x03\x04\x05\x06\x07\x08\x09\x0a\x0b\x0c\x0d\x0e\x0f\x10" > guidExtensionCode

	popd

Thuộc tính bmControls và thuộc tính baSourceID là thuộc tính đa giá trị.
Điều này có nghĩa là bạn có thể viết nhiều giá trị được phân tách bằng dòng mới cho chúng. cho
ví dụ để gắn cờ các điều khiển thứ 1, thứ 2, thứ 9 và thứ 10 khi có sẵn, bạn sẽ
cần ghi hai giá trị vào bmControls, như sau:

.. code-block:: bash

	cat << EOF > bmControls
	0x03
	0x03
	EOF

Bản chất đa giá trị của thuộc tính baSourceID trái ngược với thực tế là XU có thể
có nhiều đầu vào, mặc dù lưu ý rằng điều này hiện không có tác dụng đáng kể.

Thuộc tính bControlSize phản ánh kích thước của thuộc tính bmControls và
tương tự bNrInPins phản ánh kích thước của thuộc tính baSourceID. Cả hai
các thuộc tính được tự động tăng/giảm khi bạn đặt bmControls và
baSourceID. Cũng có thể tăng giảm thủ công bControlSize
có tác dụng cắt bớt các mục nhập theo kích thước mới hoặc các mục đệm
out với 0x00, ví dụ:

::

$ cat bmControls
	0x03
	0x05

$ mèo bControlSize
	2

$ echo 1 > bControlSize
	$ cat bmControls
	0x03

$ echo 2 > bControlSize
	$ cat bmControls
	0x03
	0x00

bNrInPins và baSourceID hoạt động theo cách tương tự.

Định cấu hình các điều khiển được hỗ trợ cho thiết bị đầu cuối và bộ xử lý camera
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thiết bị đầu cuối camera và bộ xử lý trong chuỗi UVC cũng có bmControls
các thuộc tính có chức năng tương tự với cùng một trường trong Đơn vị mở rộng.
Tuy nhiên, không giống như XU, ý nghĩa của bitflag đối với các đơn vị này được xác định trong
đặc điểm kỹ thuật UVC; bạn nên tham khảo "Bộ mô tả thiết bị đầu cuối máy ảnh" và
Phần "Bộ mô tả đơn vị xử lý" để liệt kê các cờ.

.. code-block:: bash

        # Set the Processing Unit's bmControls, flagging Brightness, Contrast
        # and Hue as available controls:
        echo 0x05 > $FUNCTION/control/processing/default/bmControls

        # Set the Camera Terminal's bmControls, flagging Focus Absolute and
        # Focus Relative as available controls:
        echo 0x60 > $FUNCTION/control/terminal/camera/default/bmControls

Nếu bạn không đặt các trường này thì theo mặc định, điều khiển Chế độ phơi sáng tự động
cho Thiết bị đầu cuối Camera và điều khiển Độ sáng cho Bộ xử lý sẽ
được gắn cờ khi có sẵn; nếu chúng không được hỗ trợ, bạn nên đặt trường thành
0x00.

Lưu ý rằng kích thước của trường bmControls cho Thiết bị đầu cuối Camera hoặc Đang xử lý
Đơn vị được cố định bởi đặc tả UVC và do đó thuộc tính bControlSize là
chỉ đọc ở đây.

Hỗ trợ chuỗi tùy chỉnh
~~~~~~~~~~~~~~~~~~~~~~

Bộ mô tả chuỗi cung cấp mô tả bằng văn bản cho các phần khác nhau của một
Thiết bị USB có thể được xác định ở vị trí thông thường trong cấu hình USB và sau đó có thể
được liên kết đến từ gốc chức năng UVC hoặc từ các thư mục Đơn vị mở rộng tới
gán các chuỗi đó làm mô tả:

.. code-block:: bash

	# Create a string descriptor in us-EN and link to it from the function
	# root. The name of the link is significant here, as it declares this
	# descriptor to be intended for the Interface Association Descriptor.
	# Other significant link names at function root are vs0_desc and vs1_desc
	# For the VideoStreaming Interface 0/1 Descriptors.

	mkdir -p $GADGET/strings/0x409/iad_desc
	echo -n "Interface Associaton Descriptor" > $GADGET/strings/0x409/iad_desc/s
	ln -s $GADGET/strings/0x409/iad_desc $FUNCTION/iad_desc

	# Because the link to a String Descriptor from an Extension Unit clearly
	# associates the two, the name of this link is not significant and may
	# be set freely.

	mkdir -p $GADGET/strings/0x409/xu.0
	echo -n "A Very Useful Extension Unit" > $GADGET/strings/0x409/xu.0/s
	ln -s $GADGET/strings/0x409/xu.0 $FUNCTION/control/extensions/xu.0

Điểm cuối ngắt
~~~~~~~~~~~~~~~~~~~~~~

Giao diện VideoControl có điểm cuối ngắt tùy chọn theo mặc định
bị vô hiệu hóa. Điều này nhằm hỗ trợ các yêu cầu bộ điều khiển phản hồi bị trì hoãn cho
UVC (sẽ phản hồi thông qua điểm cuối ngắt thay vì buộc
điểm cuối 0). Hiện tại chưa hỗ trợ gửi dữ liệu qua điểm cuối này
và do đó nó bị vô hiệu hóa để tránh nhầm lẫn. Nếu bạn muốn kích hoạt nó, bạn có thể
làm như vậy thông qua thuộc tính configfs:

.. code-block:: bash

	echo 1 > $FUNCTION/control/enable_interrupt_ep

Cấu hình băng thông
~~~~~~~~~~~~~~~~~~~~~~~

Có ba thuộc tính kiểm soát băng thông của kết nối USB.
Chúng nằm trong thư mục gốc của hàm và có thể được đặt trong giới hạn:

.. code-block:: bash

	# streaming_interval sets bInterval. Values range from 1..255
	echo 1 > $FUNCTION/streaming_interval

	# streaming_maxpacket sets wMaxPacketSize. Valid values are 1024/2048/3072
	echo 3072 > $FUNCTION/streaming_maxpacket

	# streaming_maxburst sets bMaxBurst. Valid values are 1..15
	echo 1 > $FUNCTION/streaming_maxburst


Các giá trị được truyền ở đây sẽ được gắn với các giá trị hợp lệ theo UVC
thông số kỹ thuật (phụ thuộc vào tốc độ kết nối USB). Để hiểu
cách cài đặt ảnh hưởng đến băng thông, bạn nên tham khảo thông số kỹ thuật của UVC,
nhưng nguyên tắc nhỏ là việc tăng cài đặt streaming_maxpacket sẽ
cải thiện băng thông (và do đó tốc độ khung hình tối đa có thể), trong khi điều tương tự là
đúng cho streaming_maxburst với điều kiện kết nối USB đang chạy ở SuperSpeed.
Tăng streaming_interval sẽ giảm băng thông và tốc độ khung hình.

Ứng dụng không gian người dùng
-------------------------
Bản thân trình điều khiển Tiện ích UVC không thể làm được điều gì đặc biệt thú vị. Nó
phải được ghép nối với chương trình không gian người dùng đáp ứng các yêu cầu kiểm soát UVC và
điền vào bộ đệm để xếp hàng vào thiết bị V4L2 mà trình điều khiển tạo ra. Làm thế nào những điều đó
những điều đạt được phụ thuộc vào việc thực hiện và nằm ngoài phạm vi của điều này
tài liệu, nhưng có thể tìm thấy ứng dụng tham khảo tại ZZ0000ZZ
