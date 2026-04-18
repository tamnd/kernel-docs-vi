.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/extended-controls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _extended-controls:

**********************
Điều khiển mở rộng API
**********************


Giới thiệu
============

Cơ chế điều khiển như được thiết kế ban đầu nhằm mục đích sử dụng cho
cài đặt người dùng (độ sáng, độ bão hòa, v.v.). Tuy nhiên, hóa ra
là một mô hình rất hữu ích để triển khai các API trình điều khiển phức tạp hơn
trong đó mỗi trình điều khiển chỉ thực hiện một tập hợp con của API lớn hơn.

Mã hóa MPEG API là động lực đằng sau việc thiết kế và
thực hiện cơ chế điều khiển mở rộng này: tiêu chuẩn MPEG khá
mỗi bộ mã hóa MPEG phần cứng lớn và hiện được hỗ trợ
thực hiện một tập hợp con của tiêu chuẩn này. Hơn nữa, nhiều thông số
liên quan đến cách video được mã hóa thành luồng MPEG dành riêng cho
chip mã hóa MPEG vì tiêu chuẩn MPEG chỉ xác định định dạng
của luồng MPEG thu được, chứ không phải cách video thực sự được mã hóa thành
định dạng đó.

Thật không may, điều khiển ban đầu API thiếu một số tính năng cần thiết cho
những cách sử dụng mới này và do đó nó đã được mở rộng sang (ban đầu không quá tệ
được đặt tên) điều khiển mở rộng API.

Mặc dù mã hóa MPEG API là nỗ lực đầu tiên sử dụng
Extended Control API, hiện nay còn có các lớp Extended khác
Các điều khiển, chẳng hạn như Điều khiển máy ảnh và Điều khiển máy phát FM. các
Điều khiển mở rộng API cũng như tất cả các lớp Điều khiển mở rộng đều có
được mô tả trong văn bản sau.


Bộ điều khiển mở rộng API
=========================

Ba ioctls mới có sẵn:
ZZ0000ZZ,
ZZ0001ZZ và
ZZ0002ZZ. Những ioctls này hoạt động
trên mảng điều khiển (ngược lại với
ZZ0003ZZ và
ZZ0004ZZ ioctls hoạt động trên một thiết bị duy nhất
kiểm soát). Điều này là cần thiết vì nó thường được yêu cầu thay đổi về mặt nguyên tử
nhiều điều khiển cùng một lúc.

Mỗi ioctls mới mong đợi một con trỏ tới một cấu trúc
ZZ0000ZZ. Cấu trúc này
chứa một con trỏ tới mảng điều khiển, đếm số lượng
điều khiển trong mảng đó và một lớp điều khiển. Các lớp điều khiển được sử dụng để
nhóm các điều khiển tương tự vào một lớp duy nhất. Ví dụ, lớp điều khiển
ZZ0002ZZ chứa tất cả các điều khiển của người dùng (tức là tất cả các điều khiển
cũng có thể được thiết lập bằng ZZ0001ZZ cũ
ioctl). Lớp điều khiển ZZ0003ZZ chứa các điều khiển
liên quan đến codec

Tất cả các điều khiển trong mảng điều khiển phải thuộc về điều khiển được chỉ định
lớp học. Một lỗi được trả về nếu đây không phải là trường hợp.

Cũng có thể sử dụng mảng điều khiển trống (ZZ0000ZZ == 0) để kiểm tra
liệu lớp điều khiển đã chỉ định có được hỗ trợ hay không.

Mảng điều khiển là một cấu trúc
Mảng ZZ0000ZZ. các
struct ZZ0001ZZ rất giống với
struct ZZ0002ZZ, ngoại trừ thực tế là
nó cũng cho phép truyền các giá trị và con trỏ 64 bit.

Do cấu trúc ZZ0000ZZ hỗ trợ
con trỏ giờ đây cũng có thể có các điều khiển với các kiểu ghép
chẳng hạn như mảng và/hoặc cấu trúc N chiều. Bạn cần chỉ định
ZZ0001ZZ khi liệt kê các điều khiển thực tế
có thể nhìn thấy các điều khiển phức hợp như vậy. Nói cách khác, những điều khiển này
với các loại ghép chỉ nên được sử dụng theo chương trình.

Vì các biện pháp kiểm soát phức hợp như vậy cần cung cấp thêm thông tin về
bản thân hơn là có thể với ZZ0000ZZ
ZZ0001ZZ ioctl đã được thêm vào. trong
cụ thể, ioctl này cung cấp kích thước của mảng N chiều nếu
điều khiển này bao gồm nhiều hơn một phần tử.

.. note::

   #. It is important to realize that due to the flexibility of controls it is
      necessary to check whether the control you want to set actually is
      supported in the driver and what the valid range of values is. So use
      :ref:`VIDIOC_QUERYCTRL` to check this.

   #. It is possible that some of the menu indices in a control of
      type ``V4L2_CTRL_TYPE_MENU`` may not be supported (``VIDIOC_QUERYMENU``
      will return an error). A good example is the list of supported MPEG
      audio bitrates. Some drivers only support one or two bitrates, others
      support a wider range.

Tất cả các điều khiển đều sử dụng độ bền của máy.


Liệt kê các điều khiển mở rộng
==============================

Cách được đề xuất để liệt kê các điều khiển mở rộng là sử dụng
ZZ0000ZZ kết hợp với
Cờ ZZ0001ZZ:


.. code-block:: c

    struct v4l2_queryctrl qctrl;

    qctrl.id = V4L2_CTRL_FLAG_NEXT_CTRL;
    while (0 == ioctl (fd, VIDIOC_QUERYCTRL, &qctrl)) {
	/* ... */
	qctrl.id |= V4L2_CTRL_FLAG_NEXT_CTRL;
    }

ID điều khiển ban đầu được đặt thành 0 HOẶC với
Cờ ZZ0000ZZ. ZZ0001ZZ ioctl sẽ
trả về điều khiển đầu tiên có ID cao hơn điều khiển được chỉ định. Khi nào
không tìm thấy điều khiển nào như vậy, lỗi sẽ được trả về.

Nếu bạn muốn có được tất cả các điều khiển trong một lớp điều khiển cụ thể, thì
bạn có thể đặt giá trị ZZ0000ZZ ban đầu cho lớp điều khiển và thêm
một kiểm tra bổ sung để thoát khỏi vòng lặp khi sự kiểm soát của người khác
lớp điều khiển được tìm thấy:


.. code-block:: c

    qctrl.id = V4L2_CTRL_CLASS_CODEC | V4L2_CTRL_FLAG_NEXT_CTRL;
    while (0 == ioctl(fd, VIDIOC_QUERYCTRL, &qctrl)) {
	if (V4L2_CTRL_ID2CLASS(qctrl.id) != V4L2_CTRL_CLASS_CODEC)
	    break;
	/* ... */
	qctrl.id |= V4L2_CTRL_FLAG_NEXT_CTRL;
    }

Giá trị ZZ0000ZZ 32 bit được chia thành ba phạm vi bit:
4 bit trên cùng được dành riêng cho cờ (ví dụ: ZZ0001ZZ)
và không thực sự là một phần của ID. 28 bit còn lại tạo thành
ID điều khiển, trong đó 12 bit quan trọng nhất xác định điều khiển
lớp và 16 bit có ý nghĩa nhỏ nhất xác định điều khiển trong
lớp điều khiển. Nó được đảm bảo rằng 16 bit cuối cùng này luôn
khác không cho các điều khiển. Phạm vi từ 0x1000 trở lên được dành riêng cho
điều khiển dành riêng cho người lái xe. Macro ZZ0002ZZ trả về
ID lớp điều khiển dựa trên ID điều khiển.

Nếu trình điều khiển không hỗ trợ các điều khiển mở rộng thì
ZZ0001ZZ sẽ thất bại khi sử dụng kết hợp với
ZZ0002ZZ. Trong trường hợp đó, phương pháp liệt kê cũ
nên sử dụng điều khiển (xem ZZ0000ZZ). Nhưng nếu nó là
được hỗ trợ thì nó được đảm bảo liệt kê tất cả các điều khiển,
bao gồm cả điều khiển riêng của người lái xe.


Tạo bảng điều khiển
=======================

Có thể tạo bảng điều khiển cho giao diện người dùng đồ họa
nơi người dùng có thể chọn các điều khiển khác nhau. Về cơ bản bạn sẽ có
để lặp lại tất cả các điều khiển bằng phương pháp được mô tả ở trên. Mỗi
lớp điều khiển bắt đầu bằng một loại điều khiển
ZZ0000ZZ. ZZ0001ZZ sẽ trả lại tên
của lớp điều khiển này có thể được sử dụng làm tiêu đề của trang tab
trong một bảng điều khiển.

Trường cờ của cấu trúc ZZ0000ZZ cũng
chứa gợi ý về hành vi của điều khiển. Xem
Tài liệu ZZ0001ZZ để biết thêm
chi tiết.