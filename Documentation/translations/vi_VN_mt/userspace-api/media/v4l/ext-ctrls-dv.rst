.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-dv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _dv-controls:

*******************************
Tài liệu tham khảo điều khiển video kỹ thuật số
*******************************

Lớp điều khiển Video Kỹ thuật số nhằm mục đích điều khiển máy thu và
máy phát cho ZZ0003ZZ,
ZZ0004ZZ
(Giao diện hình ảnh kỹ thuật số), HDMI (ZZ0000ZZ) và DisplayPort
(ZZ0001ZZ). Những biện pháp kiểm soát này thường được cho là riêng tư đối với
thiết bị con thu hoặc phát thực hiện chúng, vì vậy chúng
chỉ hiển thị trên nút thiết bị ZZ0002ZZ.

.. note::

   Note that these devices can have multiple input or output pads which are
   hooked up to e.g. HDMI connectors. Even though the subdevice will
   receive or transmit video from/to only one of those pads, the other pads
   can still be active when it comes to EDID (Extended Display
   Identification Data, :ref:`vesaedid`) and HDCP (High-bandwidth Digital
   Content Protection System, :ref:`hdcp`) processing, allowing the
   device to do the fairly slow EDID/HDCP handling in advance. This allows
   for quick switching between connectors.

Những miếng đệm này xuất hiện trong một số điều khiển trong phần này dưới dạng
mặt nạ bit, một bit cho mỗi miếng đệm. Bit 0 tương ứng với pad 0, bit 1 tương ứng với pad
1, v.v. Giá trị tối đa của điều khiển là tập hợp các miếng đệm hợp lệ.


.. _dv-control-id:

ID điều khiển video kỹ thuật số
=========================

ZZ0000ZZ
    Bộ mô tả lớp Video kỹ thuật số.

ZZ0000ZZ
    Nhiều đầu nối có chân cắm nóng cao nếu EDID
    có sẵn từ nguồn. Điều khiển này hiển thị trạng thái của
    chốt cắm nóng mà máy phát nhìn thấy. Mỗi bit tương ứng với một
    pad đầu ra trên máy phát. Nếu bảng đầu ra không có
    pin cắm nóng liên quan thì bit của miếng đệm đó sẽ là 0. Điều này
    điều khiển chỉ đọc được áp dụng cho DVI-D, HDMI và DisplayPort
    đầu nối.

ZZ0000ZZ
    Rx Sense là tính năng phát hiện các pull-up trên dòng đồng hồ TMDS. Cái này
    thông thường có nghĩa là bồn rửa đã rời/vào chế độ chờ (tức là
    máy phát có thể cảm nhận được rằng máy thu đã sẵn sàng nhận video).
    Mỗi bit tương ứng với một bảng đầu ra trên máy phát. Nếu một
    bảng đầu ra không có Rx Sense liên quan thì bit dành cho
    phần đệm đó sẽ bằng 0. Điều khiển chỉ đọc này có thể áp dụng cho DVI-D
    và các thiết bị HDMI.

ZZ0000ZZ
    Khi máy phát nhìn thấy tín hiệu cắm nóng từ máy thu, nó
    sẽ cố gắng đọc EDID. Nếu được đặt thì máy phát đã đọc
    ít nhất là khối đầu tiên (= 128 byte). Mỗi bit tương ứng với một
    pad đầu ra trên máy phát. Nếu bảng đầu ra không hỗ trợ
    EDID thì bit của phần đệm đó sẽ là 0. Điều khiển chỉ đọc này
    có thể áp dụng cho các đầu nối VGA, DVI-A/D, HDMI và DisplayPort.

ZZ0000ZZ
    (enum)

enum v4l2_dv_tx_mode -
    Máy phát HDMI có thể truyền ở chế độ DVI-D (chỉ video) hoặc ở HDMI
    chế độ (video + âm thanh + dữ liệu phụ trợ). Điều khiển này chọn cái nào
    chế độ sử dụng: V4L2_DV_TX_MODE_DVI_D hoặc V4L2_DV_TX_MODE_HDMI.
    Điều khiển này có thể áp dụng cho đầu nối HDMI.

ZZ0000ZZ
    (enum)

enum v4l2_dv_rgb_range -
    Chọn phạm vi lượng tử hóa cho đầu ra RGB. V4L2_DV_RANGE_AUTO
    tuân theo phạm vi lượng tử hóa RGB được chỉ định trong tiêu chuẩn cho
    giao diện video (ví dụ: ZZ0000ZZ cho HDMI).
    V4L2_DV_RANGE_LIMITED và V4L2_DV_RANGE_FULL ghi đè
    tiêu chuẩn để tương thích với các bồn rửa chưa triển khai
    tiêu chuẩn chính xác (không may là khá phổ biến đối với HDMI và DVI-D).
    Phạm vi đầy đủ cho phép sử dụng tất cả các giá trị có thể trong khi bị giới hạn
    phạm vi đặt phạm vi thành (16 << (N-8)) - (235 << (N-8)) trong đó N là
    số bit trên mỗi thành phần. Điều khiển này có thể áp dụng cho VGA,
    Đầu nối DVI-A/D, HDMI và DisplayPort.

ZZ0000ZZ
    (enum)

enum v4l2_dv_it_content_type -
    Định cấu hình Loại nội dung CNTT của video được truyền. Cái này
    thông tin được gửi qua đầu nối HDMI và DisplayPort như một phần của
    Khung thông tin AVI. Thuật ngữ 'Nội dung CNTT' được sử dụng cho nội dung
    bắt nguồn từ máy tính chứ không phải nội dung từ chương trình truyền hình
    hoặc một nguồn tương tự. Enum v4l2_dv_it_content_type xác định
    các loại nội dung có thể có:

.. tabularcolumns:: |p{7.3cm}|p{10.2cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_DV_IT_CONTENT_TYPE_GRAPHICS``
      - Graphics content. Pixel data should be passed unfiltered and
	without analog reconstruction.
    * - ``V4L2_DV_IT_CONTENT_TYPE_PHOTO``
      - Photo content. The content is derived from digital still pictures.
	The content should be passed through with minimal scaling and
	picture enhancements.
    * - ``V4L2_DV_IT_CONTENT_TYPE_CINEMA``
      - Cinema content.
    * - ``V4L2_DV_IT_CONTENT_TYPE_GAME``
      - Game content. Audio and video latency should be minimized.
    * - ``V4L2_DV_IT_CONTENT_TYPE_NO_ITC``
      - No IT Content information is available and the ITC bit in the AVI
	InfoFrame is set to 0.



ZZ0000ZZ
    Phát hiện xem máy thu có nhận được nguồn điện từ nguồn hay không (ví dụ:
    HDMI mang 5V trên một trong các chân). Điều này thường được sử dụng để cung cấp năng lượng cho một
    eeprom chứa thông tin EDID, sao cho nguồn có thể
    đọc EDID ngay cả khi bồn rửa ở chế độ chờ/tắt nguồn. Mỗi bit
    tương ứng với một bảng đầu vào trên máy thu. Nếu một bảng đầu vào
    không thể phát hiện xem có nguồn điện hay không, thì bit dành cho miếng đệm đó
    sẽ bằng 0. Điều khiển chỉ đọc này có thể áp dụng cho DVI-D, HDMI và
    Các đầu nối DisplayPort.

ZZ0000ZZ
    (enum)

enum v4l2_dv_rgb_range -
    Chọn phạm vi lượng tử hóa cho đầu vào RGB. V4L2_DV_RANGE_AUTO
    tuân theo phạm vi lượng tử hóa RGB được chỉ định trong tiêu chuẩn cho
    giao diện video (ví dụ: ZZ0000ZZ cho HDMI).
    V4L2_DV_RANGE_LIMITED và V4L2_DV_RANGE_FULL ghi đè
    tiêu chuẩn để tương thích với các nguồn chưa triển khai
    tiêu chuẩn chính xác (không may là khá phổ biến đối với HDMI và DVI-D).
    Phạm vi đầy đủ cho phép sử dụng tất cả các giá trị có thể trong khi bị giới hạn
    phạm vi đặt phạm vi thành (16 << (N-8)) - (235 << (N-8)) trong đó N là
    số bit trên mỗi thành phần. Điều khiển này có thể áp dụng cho VGA,
    Đầu nối DVI-A/D, HDMI và DisplayPort.

ZZ0000ZZ
    (enum)

enum v4l2_dv_it_content_type -
    Đọc Loại nội dung CNTT của video đã nhận. Thông tin này là
    được gửi qua đầu nối HDMI và DisplayPort như một phần của AVI
    InfoFrame. Thuật ngữ 'Nội dung CNTT' được sử dụng cho nội dung bắt nguồn từ
    từ máy tính trái ngược với nội dung từ chương trình truyền hình hoặc
    nguồn tương tự. Xem ZZ0000ZZ để biết
    các loại nội dung có sẵn.