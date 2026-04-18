.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-sliced-vbi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _sliced:

**********************************
Giao diện dữ liệu VBI được cắt lát
**********************************

VBI là viết tắt của Khoảng trống theo chiều dọc, một khoảng trống trong chuỗi
dòng tín hiệu video analog. Trong VBI không có thông tin hình ảnh
truyền đi, chờ một thời gian để chùm electron của tia catôt
TV ống trở lại đầu màn hình.

Các thiết bị VBI được cắt lát sử dụng phần cứng để giải điều chế dữ liệu được truyền trong
VBI. Trình điều khiển V4L2 sẽ ZZ0001ZZ thực hiện việc này bằng phần mềm, xem thêm
ZZ0000ZZ. Dữ liệu được truyền dưới dạng ngắn
các gói có kích thước cố định, mỗi gói bao gồm một dòng quét. Số lượng
các gói trên mỗi khung hình video có thể thay đổi.

Các thiết bị thu và xuất VBI được cắt lát được truy cập thông qua cùng một
các tệp ký tự đặc biệt dưới dạng thiết bị VBI thô. Khi một trình điều khiển hỗ trợ cả hai
giao diện, chức năng mặc định của thiết bị ZZ0001ZZ là ZZ0003ZZ VBI
chụp hoặc xuất và chức năng VBI được cắt lát chỉ khả dụng sau
gọi ZZ0000ZZ ioctl như được định nghĩa
bên dưới. Tương tự, thiết bị ZZ0002ZZ có thể hỗ trợ VBI API được cắt lát,
tuy nhiên chức năng mặc định ở đây là quay hoặc xuất video.
Phải sử dụng các bộ mô tả tệp khác nhau để truyền dữ liệu VBI thô và được cắt lát
đồng thời, nếu điều này được trình điều khiển hỗ trợ.

Khả năng truy vấn
=====================

Các thiết bị hỗ trợ VBI chụp hoặc xuất API được cắt lát sẽ đặt
Cờ ZZ0003ZZ hoặc ZZ0004ZZ
tương ứng, trong trường ZZ0005ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Ít nhất một trong số
đọc/ghi hoặc phát trực tuyến ZZ0002ZZ phải
được hỗ trợ. Các thiết bị VBI được cắt lát có thể có bộ điều chỉnh hoặc bộ điều biến.

Chức năng bổ sung
======================

Các thiết bị VBI được cắt lát sẽ hỗ trợ ZZ0000ZZ
và ZZ0001ZZ ioctls nếu họ có những thứ này
khả năng và chúng có thể hỗ trợ ioctls ZZ0002ZZ.
ZZ0003ZZ ioctls cung cấp thông tin quan trọng
để lập trình một thiết bị VBI được cắt lát, do đó phải được hỗ trợ.

.. _sliced-vbi-format-negotiation:

Cắt lát định dạng VBI
=============================

Để tìm hiểu dịch vụ dữ liệu nào được phần cứng hỗ trợ
các ứng dụng có thể gọi
ZZ0000ZZ ioctl.
Tất cả các trình điều khiển triển khai giao diện VBI được cắt lát phải hỗ trợ điều này
ioctl. Kết quả có thể khác với kết quả của
ZZ0001ZZ ioctl khi số VBI
các dòng mà phần cứng có thể chụp hoặc xuất ra trên mỗi khung hình hoặc số lượng
các dịch vụ mà nó có thể xác định trên một đường dây nhất định đều bị hạn chế. Ví dụ trên PAL
dòng 16 phần cứng có thể tìm kiếm tín hiệu VPS hoặc Teletext,
nhưng không phải cả hai cùng một lúc.

Để xác định các ứng dụng dịch vụ hiện được chọn, hãy đặt
Trường ZZ0003ZZ của cấu trúc ZZ0000ZZ tới
ZZ0004ZZ hoặc
ZZ0005ZZ và
ZZ0001ZZ ioctl lấp đầy ZZ0006ZZ
thành viên, một cấu trúc
ZZ0002ZZ.

Các ứng dụng có thể yêu cầu các tham số khác nhau bằng cách khởi tạo hoặc
sửa đổi thành viên ZZ0002ZZ và gọi
ZZ0000ZZ ioctl với một con trỏ tới
cấu trúc ZZ0001ZZ.

VBI API được cắt lát phức tạp hơn VBI API thô vì
phần cứng phải được cho biết dịch vụ VBI nào sẽ được mong đợi trên mỗi dòng quét. Không
tất cả các dịch vụ có thể được hỗ trợ bởi phần cứng trên tất cả các dòng (đây là
đặc biệt đúng với đầu ra VBI nơi Teletext thường không được hỗ trợ và
các dịch vụ khác chỉ có thể được chèn vào một dòng cụ thể). Ở nhiều nơi
tuy nhiên, trong các trường hợp, chỉ cần đặt trường ZZ0000ZZ là đủ
đến các dịch vụ được yêu cầu và để tài xế điền vào ZZ0001ZZ
mảng theo khả năng phần cứng. Chỉ khi kiểm soát chính xác hơn
là cần thiết nếu lập trình viên thiết lập mảng ZZ0002ZZ
một cách rõ ràng.

ZZ0000ZZ ioctl sửa đổi các thông số
theo khả năng phần cứng. Khi người lái xe phân bổ tài nguyên
tại thời điểm này, nó có thể trả về mã lỗi ZZ0005ZZ nếu được yêu cầu
tài nguyên tạm thời không có sẵn. Điểm phân bổ nguồn lực khác
có thể trả về ZZ0006ZZ có thể là
ZZ0001ZZ ioctl và lần đầu tiên
ZZ0002ZZ, ZZ0003ZZ và
Cuộc gọi ZZ0004ZZ.

.. c:type:: v4l2_sliced_vbi_format

cấu trúc v4l2_sliced_vbi_format
-----------------------------

.. raw:: latex

    \begingroup
    \scriptsize
    \setlength{\tabcolsep}{2pt}

.. tabularcolumns:: |p{.85cm}|p{3.3cm}|p{4.45cm}|p{4.45cm}|p{4.45cm}|

.. cssclass:: longtable

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 3 2 2 2

    * - __u16
      - ``service_set``
      - :cspan:`2`

	If ``service_set`` is non-zero when passed with
	:ref:`VIDIOC_S_FMT <VIDIOC_G_FMT>` or
	:ref:`VIDIOC_TRY_FMT <VIDIOC_G_FMT>`, the ``service_lines``
	array will be filled by the driver according to the services
	specified in this field. For example, if ``service_set`` is
	initialized with ``V4L2_SLICED_TELETEXT_B | V4L2_SLICED_WSS_625``,
	a driver for the cx25840 video decoder sets lines 7-22 of both
	fields [#f1]_ to ``V4L2_SLICED_TELETEXT_B`` and line 23 of the first
	field to ``V4L2_SLICED_WSS_625``. If ``service_set`` is set to
	zero, then the values of ``service_lines`` will be used instead.

	On return the driver sets this field to the union of all elements
	of the returned ``service_lines`` array. It may contain less
	services than requested, perhaps just one, if the hardware cannot
	handle more services simultaneously. It may be empty (zero) if
	none of the requested services are supported by the hardware.
    * - __u16
      - ``service_lines``\ [2][24]
      - :cspan:`2`

	Applications initialize this array with sets of data services the
	driver shall look for or insert on the respective scan line.
	Subject to hardware capabilities drivers return the requested set,
	a subset, which may be just a single service, or an empty set.
	When the hardware cannot handle multiple services on the same line
	the driver shall choose one. No assumptions can be made on which
	service the driver chooses.

	Data services are defined in :ref:`vbi-services2`. Array indices
	map to ITU-R line numbers\ [#f2]_ as follows:
    * -
      -
      - Element
      - 525 line systems
      - 625 line systems
    * -
      -
      - ``service_lines``\ [0][1]
      - 1
      - 1
    * -
      -
      - ``service_lines``\ [0][23]
      - 23
      - 23
    * -
      -
      - ``service_lines``\ [1][1]
      - 264
      - 314
    * -
      -
      - ``service_lines``\ [1][23]
      - 286
      - 336
    * -
      -
      - :cspan:`2` Drivers must set ``service_lines`` [0][0] and
	``service_lines``\ [1][0] to zero. The
	``V4L2_VBI_ITU_525_F1_START``, ``V4L2_VBI_ITU_525_F2_START``,
	``V4L2_VBI_ITU_625_F1_START`` and ``V4L2_VBI_ITU_625_F2_START``
	defines give the start line numbers for each field for each 525 or
	625 line format as a convenience. Don't forget that ITU line
	numbering starts at 1, not 0.
    * - __u32
      - ``io_size``
      - :cspan:`2` Maximum number of bytes passed by one
	:c:func:`read()` or :c:func:`write()` call,
	and the buffer size in bytes for the
	:ref:`VIDIOC_QBUF` and
	:ref:`VIDIOC_DQBUF <VIDIOC_QBUF>` ioctl. Drivers set this field
	to the size of struct
	:c:type:`v4l2_sliced_vbi_data` times the
	number of non-zero elements in the returned ``service_lines``
	array (that is the number of lines potentially carrying data).
    * - __u32
      - ``reserved``\ [2]
      - :cspan:`2` This array is reserved for future extensions.

	Applications and drivers must set it to zero.

.. raw:: latex

    \endgroup

.. _vbi-services2:

Dịch vụ VBI cắt lát
-------------------

.. raw:: latex

    \footnotesize

.. tabularcolumns:: |p{4.2cm}|p{1.1cm}|p{2.1cm}|p{2.0cm}|p{6.5cm}|

.. flat-table::
    :header-rows:  1
    :stub-columns: 0
    :widths:       2 1 1 2 2

    * - Symbol
      - Value
      - Reference
      - Lines, usually
      - Payload
    * - ``V4L2_SLICED_TELETEXT_B`` (Teletext System B)
      - 0x0001
      - :ref:`ets300706`,

	:ref:`itu653`
      - PAL/SECAM line 7-22, 320-335 (second field 7-22)
      - Last 42 of the 45 byte Teletext packet, that is without clock
	run-in and framing code, lsb first transmitted.
    * - ``V4L2_SLICED_VPS``
      - 0x0400
      - :ref:`ets300231`
      - PAL line 16
      - Byte number 3 to 15 according to Figure 9 of ETS 300 231, lsb
	first transmitted.
    * - ``V4L2_SLICED_CAPTION_525``
      - 0x1000
      - :ref:`cea608`
      - NTSC line 21, 284 (second field 21)
      - Two bytes in transmission order, including parity bit, lsb first
	transmitted.
    * - ``V4L2_SLICED_WSS_625``
      - 0x4000
      - :ref:`itu1119`,

	:ref:`en300294`
      - PAL/SECAM line 23
      -  See :ref:`v4l2-sliced-wss-625-payload` below.
    * - ``V4L2_SLICED_VBI_525``
      - 0x1000
      - :cspan:`2` Set of services applicable to 525 line systems.
    * - ``V4L2_SLICED_VBI_625``
      - 0x4401
      - :cspan:`2` Set of services applicable to 625 line systems.

.. raw:: latex

    \normalsize

Trình điều khiển có thể trả về mã lỗi ZZ0005ZZ khi các ứng dụng cố gắng
đọc hoặc ghi dữ liệu mà không cần thỏa thuận định dạng trước, sau khi chuyển đổi
tiêu chuẩn video (có thể làm mất hiệu lực các tham số VBI đã thương lượng) và
sau khi chuyển đổi đầu vào video (có thể thay đổi tiêu chuẩn video thành
một tác dụng phụ). ZZ0000ZZ ioctl có thể
trả về mã lỗi ZZ0006ZZ khi các ứng dụng cố gắng thay đổi
định dạng trong khi quá trình nhập/xuất đang diễn ra (giữa một
ZZ0001ZZ và
Cuộc gọi ZZ0002ZZ và sau cuộc gọi đầu tiên
Cuộc gọi ZZ0003ZZ hoặc ZZ0004ZZ).

.. _v4l2-sliced-wss-625-payload:

Tải trọng V4L2_SLICED_WSS_625
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tải trọng cho ZZ0000ZZ là:

+------+-------------------+--------------+
	   ZZ0000ZZ 0 ZZ0001ZZ
           +------+--------+---------+-------------+----------+
	   ZZ0002ZZ msb ZZ0003ZZ msb ZZ0004ZZ
           |     +-+-+-+--+--+-+-+--+--+-+--+---+---+--+-+--+
	   ZZ0005ZZ7ZZ0006ZZ5ZZ0007ZZ 3|2|1|0 | x|x|13|12 | 11|10|9|8 |
           +------+-+-+-+--+--+-+-+--+--+-+--+---+---+--+-+--+

Đọc và ghi dữ liệu VBI được cắt lát
===================================

Một chiếc ZZ0000ZZ hoặc ZZ0001ZZ
cuộc gọi phải chuyển tất cả dữ liệu thuộc một khung hình video. Đó là một mảng
của cấu trúc ZZ0002ZZ với một hoặc
nhiều phần tử hơn và tổng kích thước không vượt quá byte ZZ0004ZZ. Tương tự như vậy
trong chế độ I/O phát trực tuyến, một bộ đệm byte ZZ0005ZZ phải chứa dữ liệu
của một khung hình video. ZZ0006ZZ chưa sử dụng
Các phần tử struct ZZ0003ZZ phải bằng 0.

.. c:type:: v4l2_sliced_vbi_data

cấu trúc v4l2_sliced_vbi_data
---------------------------

.. tabularcolumns:: |p{1.2cm}|p{2.2cm}|p{13.9cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - __u32
      - ``id``
      - A flag from :ref:`vbi-services` identifying the type of data in
	this packet. Only a single bit must be set. When the ``id`` of a
	captured packet is zero, the packet is empty and the contents of
	other fields are undefined. Applications shall ignore empty
	packets. When the ``id`` of a packet for output is zero the
	contents of the ``data`` field are undefined and the driver must
	no longer insert data on the requested ``field`` and ``line``.
    * - __u32
      - ``field``
      - The video field number this data has been captured from, or shall
	be inserted at. ``0`` for the first field, ``1`` for the second
	field.
    * - __u32
      - ``line``
      - The field (as opposed to frame) line number this data has been
	captured from, or shall be inserted at. See :ref:`vbi-525` and
	:ref:`vbi-625` for valid values. Sliced VBI capture devices can
	set the line number of all packets to ``0`` if the hardware cannot
	reliably identify scan lines. The field number must always be
	valid.
    * - __u32
      - ``reserved``
      - This field is reserved for future extensions. Applications and
	drivers must set it to zero.
    * - __u8
      - ``data``\ [48]
      - The packet payload. See :ref:`vbi-services` for the contents and
	number of bytes passed for each data type. The contents of padding
	bytes at the end of this array are undefined, drivers and
	applications shall ignore them.

Các gói luôn được truyền theo thứ tự số dòng tăng dần, không có
số dòng trùng lặp. Chức năng ZZ0000ZZ và
ioctl ZZ0001ZZ phải trả về ZZ0004ZZ
mã lỗi khi ứng dụng vi phạm quy tắc này. Họ cũng phải trả lại một
Mã lỗi EINVAL khi ứng dụng chuyển trường hoặc dòng không chính xác
số hoặc sự kết hợp của ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ chưa có
đã được đàm phán với ZZ0002ZZ hoặc
ZZ0003ZZ ioctl. Khi số dòng là
trình điều khiển không xác định phải chuyển các gói theo thứ tự được truyền. các
trình điều khiển có thể chèn các gói trống với ZZ0008ZZ được đặt thành 0 ở bất kỳ đâu trong
mảng gói.

Để đảm bảo đồng bộ hóa và phân biệt với hiện tượng rớt khung hình, khi một
khung đã chụp không mang bất kỳ trình điều khiển dịch vụ dữ liệu nào được yêu cầu
phải chuyển một hoặc nhiều gói trống. Khi một ứng dụng không vượt qua được
Dữ liệu VBI kịp thời xuất ra, trình điều khiển phải xuất VPS và WSS cuối cùng
gói lại và vô hiệu hóa đầu ra của Phụ đề chi tiết và Teletext
dữ liệu hoặc dữ liệu đầu ra bị Closed Caption và Teletext bỏ qua
bộ giải mã.

Thiết bị VBI được cắt lát có thể hỗ trợ ZZ0000ZZ và/hoặc
phát trực tuyến (ZZ0001ZZ và/hoặc
ZZ0002ZZ) I/O. Cái sau có khả năng
đồng bộ hóa dữ liệu video và VBI bằng cách sử dụng dấu thời gian đệm.

Dữ liệu VBI được cắt lát trong luồng MPEG
===============================

Nếu một thiết bị có thể tạo ra luồng đầu ra MPEG, nó có thể có khả năng
cung cấp
ZZ0000ZZ
dưới dạng dữ liệu được nhúng trong luồng MPEG. Người dùng hoặc ứng dụng kiểm soát điều này
chèn dữ liệu VBI được cắt lát bằng
ZZ0001ZZ
kiểm soát.

Nếu người lái xe không cung cấp
ZZ0000ZZ
điều khiển hoặc chỉ cho phép điều khiển đó được đặt thành
ZZ0001ZZ,
thì thiết bị không thể nhúng dữ liệu VBI được cắt lát vào luồng MPEG.

các
ZZ0000ZZ
điều khiển không ngầm thiết lập trình điều khiển thiết bị để chụp cũng như dừng
thu thập dữ liệu VBI được cắt lát. Điều khiển chỉ cho biết nhúng cắt lát
Dữ liệu VBI trong luồng MPEG, nếu một ứng dụng đã thương lượng VBI được cắt lát
dịch vụ được nắm bắt.

Cũng có thể xảy ra trường hợp một thiết bị chỉ có thể nhúng dữ liệu VBI được cắt lát trong
một số loại luồng MPEG nhất định: ví dụ như trong MPEG-2 PS nhưng không phải là
MPEG-2 TS. Trong tình huống này, nếu yêu cầu chèn dữ liệu VBI được cắt lát,
dữ liệu VBI được cắt lát sẽ được nhúng vào các loại luồng MPEG khi
được hỗ trợ và âm thầm bị bỏ qua khỏi các loại luồng MPEG trong đó VBI được cắt lát
thiết bị không hỗ trợ chèn dữ liệu.

Các phần phụ sau đây chỉ định định dạng của VBI được cắt lát được nhúng
dữ liệu.

MPEG Luồng được nhúng, được cắt lát Định dạng dữ liệu VBI: NONE
--------------------------------------------------

các
ZZ0000ZZ
định dạng VBI được cắt lát được nhúng sẽ được trình điều khiển hiểu là một điều khiển
ngừng nhúng dữ liệu VBI được cắt lát vào luồng MPEG. Cả thiết bị đều không
trình điều khiển cũng không được chèn các gói dữ liệu VBI được cắt lát "trống" vào
Luồng MPEG khi định dạng này được đặt. Không có cấu trúc dữ liệu luồng MPEG nào
được chỉ định cho định dạng này.

MPEG Luồng được nhúng, được cắt lát Định dạng dữ liệu VBI: IVTV
--------------------------------------------------

các
ZZ0000ZZ
định dạng VBI được cắt lát được nhúng, khi được hỗ trợ, sẽ báo cho trình điều khiển biết
nhúng tối đa 36 dòng dữ liệu VBI được cắt lát trên mỗi khung hình trong MPEG-2 *Private
Gói PES* luồng 1 được đóng gói trong MPEG-2 ZZ0001ZZ trong
Luồng MPEG.

ZZ0002ZZ: Đặc tả định dạng này bắt nguồn từ một
định dạng dữ liệu VBI tùy chỉnh, được nhúng, cắt lát được sử dụng bởi trình điều khiển ZZ0000ZZ.
Định dạng này đã được chỉ định không chính thức trong nguồn kernel
trong tệp ZZ0001ZZ . các
kích thước tối đa của tải trọng và các khía cạnh khác của định dạng này được điều khiển
bởi khả năng và giới hạn của bộ giải mã CX23415 MPEG
để trích xuất, giải mã và hiển thị dữ liệu VBI được cắt lát được nhúng bên trong
một luồng MPEG.

Việc sử dụng định dạng này là ZZ0002ZZ dành riêng cho trình điều khiển ZZ0000ZZ ZZ0003ZZ
dành riêng cho các thiết bị CX2341x, dưới dạng chèn gói dữ liệu VBI được cắt lát
vào luồng MPEG được triển khai trong phần mềm trình điều khiển. Ít nhất là
Trình điều khiển ZZ0001ZZ cung cấp tính năng chèn dữ liệu VBI được cắt lát vào MPEG-2 PS trong
định dạng này là tốt.

Các định nghĩa sau đây chỉ định tải trọng của MPEG-2 *Private
Truyền 1 gói PES* chứa dữ liệu VBI được cắt lát khi
ZZ0000ZZ
được thiết lập. (Tiêu đề gói MPEG-2 ZZ0001ZZ và
Tiêu đề đóng gói MPEG-2 ZZ0002ZZ không được trình bày chi tiết ở đây. làm ơn
tham khảo thông số kỹ thuật MPEG-2 để biết chi tiết về các tiêu đề gói đó.)

Tải trọng của các gói MPEG-2 ZZ0001ZZ có chứa
dữ liệu VBI được cắt lát được chỉ định bởi struct
ZZ0000ZZ. các
tải trọng có độ dài thay đổi, tùy thuộc vào số dòng thực tế của
dữ liệu VBI được cắt lát có trong khung hình video. Tải trọng có thể được đệm ở
phần cuối có byte điền không xác định để căn chỉnh phần cuối của tải trọng với một
Ranh giới 4 byte. Tải trọng không bao giờ vượt quá 1552 byte (2 trường
với 18 dòng/trường với 43 byte dữ liệu/dòng và phép thuật 4 byte
số).

.. c:type:: v4l2_mpeg_vbi_fmt_ivtv

cấu trúc v4l2_mpeg_vbi_fmt_ivtv
-----------------------------

.. tabularcolumns:: |p{4.2cm}|p{2.0cm}|p{11.1cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u8
      - ``magic``\ [4]
      - A "magic" constant from :ref:`v4l2-mpeg-vbi-fmt-ivtv-magic` that
	indicates this is a valid sliced VBI data payload and also
	indicates which member of the anonymous union, ``itv0`` or
	``ITV0``, to use for the payload data.
    * - union {
      - (anonymous)
    * - struct :c:type:`v4l2_mpeg_vbi_itv0`
      - ``itv0``
      - The primary form of the sliced VBI data payload that contains
	anywhere from 1 to 35 lines of sliced VBI data. Line masks are
	provided in this form of the payload indicating which VBI lines
	are provided.
    * - struct :ref:`v4l2_mpeg_vbi_ITV0 <v4l2-mpeg-vbi-itv0-1>`
      - ``ITV0``
      - An alternate form of the sliced VBI data payload used when 36
	lines of sliced VBI data are present. No line masks are provided
	in this form of the payload; all valid line mask bits are
	implicitly set.
    * - }
      -

.. _v4l2-mpeg-vbi-fmt-ivtv-magic:

Hằng số ma thuật cho trường ma thuật struct v4l2_mpeg_vbi_fmt_ivtv
-------------------------------------------------------------

.. tabularcolumns:: |p{6.6cm}|p{2.2cm}|p{8.5cm}|

.. flat-table::
    :header-rows:  1
    :stub-columns: 0
    :widths:       3 1 4

    * - Defined Symbol
      - Value
      - Description
    * - ``V4L2_MPEG_VBI_IVTV_MAGIC0``
      - "itv0"
      - Indicates the ``itv0`` member of the union in struct
	:c:type:`v4l2_mpeg_vbi_fmt_ivtv` is
	valid.
    * - ``V4L2_MPEG_VBI_IVTV_MAGIC1``
      - "ITV0"
      - Indicates the ``ITV0`` member of the union in struct
	:c:type:`v4l2_mpeg_vbi_fmt_ivtv` is
	valid and that 36 lines of sliced VBI data are present.


.. c:type:: v4l2_mpeg_vbi_itv0

.. c:type:: v4l2_mpeg_vbi_ITV0

cấu trúc v4l2_mpeg_vbi_itv0 và v4l2_mpeg_vbi_ITV0
-------------------------------------------------

.. raw:: latex

   \footnotesize

.. tabularcolumns:: |p{4.6cm}|p{2.0cm}|p{10.7cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __le32
      - ``linemask``\ [2]
      - Bitmasks indicating the VBI service lines present. These
	``linemask`` values are stored in little endian byte order in the
	MPEG stream. Some reference ``linemask`` bit positions with their
	corresponding VBI line number and video field are given below.
	b\ :sub:`0` indicates the least significant bit of a ``linemask``
	value:


	::

	    linemask[0] b0:     line  6  first field
	    linemask[0] b17:    line 23  first field
	    linemask[0] b18:    line  6  second field
	    linemask[0] b31:    line 19  second field
	    linemask[1] b0:     line 20  second field
	    linemask[1] b3:     line 23  second field
	    linemask[1] b4-b31: unused and set to 0
    * - struct
	:c:type:`v4l2_mpeg_vbi_itv0_line`
      - ``line``\ [35]
      - This is a variable length array that holds from 1 to 35 lines of
	sliced VBI data. The sliced VBI data lines present correspond to
	the bits set in the ``linemask`` array, starting from b\ :sub:`0`
	of ``linemask``\ [0] up through b\ :sub:`31` of ``linemask``\ [0],
	and from b\ :sub:`0` of ``linemask``\ [1] up through b\ :sub:`3` of
	``linemask``\ [1]. ``line``\ [0] corresponds to the first bit
	found set in the ``linemask`` array, ``line``\ [1] corresponds to
	the second bit found set in the ``linemask`` array, etc. If no
	``linemask`` array bits are set, then ``line``\ [0] may contain
	one line of unspecified data that should be ignored by
	applications.

.. raw:: latex

   \normalsize

.. _v4l2-mpeg-vbi-itv0-1:

cấu trúc v4l2_mpeg_vbi_ITV0
-------------------------

.. tabularcolumns:: |p{5.2cm}|p{2.4cm}|p{9.7cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - struct
	:c:type:`v4l2_mpeg_vbi_itv0_line`
      - ``line``\ [36]
      - A fixed length array of 36 lines of sliced VBI data. ``line``\ [0]
	through ``line``\ [17] correspond to lines 6 through 23 of the
	first field. ``line``\ [18] through ``line``\ [35] corresponds to
	lines 6 through 23 of the second field.


.. c:type:: v4l2_mpeg_vbi_itv0_line

cấu trúc v4l2_mpeg_vbi_itv0_line
------------------------------

.. tabularcolumns:: |p{4.4cm}|p{4.4cm}|p{8.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u8
      - ``id``
      - A line identifier value from
	:ref:`ITV0-Line-Identifier-Constants` that indicates the type of
	sliced VBI data stored on this line.
    * - __u8
      - ``data``\ [42]
      - The sliced VBI data for the line.


.. _ITV0-Line-Identifier-Constants:

Mã định danh dòng cho trường id struct v4l2_mpeg_vbi_itv0_line
------------------------------------------------------------

.. tabularcolumns:: |p{7.0cm}|p{1.8cm}|p{8.5cm}|

.. flat-table::
    :header-rows:  1
    :stub-columns: 0
    :widths:       3 1 4

    * - Defined Symbol
      - Value
      - Description
    * - ``V4L2_MPEG_VBI_IVTV_TELETEXT_B``
      - 1
      - Refer to :ref:`Sliced VBI services <vbi-services2>` for a
	description of the line payload.
    * - ``V4L2_MPEG_VBI_IVTV_CAPTION_525``
      - 4
      - Refer to :ref:`Sliced VBI services <vbi-services2>` for a
	description of the line payload.
    * - ``V4L2_MPEG_VBI_IVTV_WSS_625``
      - 5
      - Refer to :ref:`Sliced VBI services <vbi-services2>` for a
	description of the line payload.
    * - ``V4L2_MPEG_VBI_IVTV_VPS``
      - 7
      - Refer to :ref:`Sliced VBI services <vbi-services2>` for a
	description of the line payload.


.. [#f1]
   According to :ref:`ETS 300 706 <ets300706>` lines 6-22 of the first
   field and lines 5-22 of the second field may carry Teletext data.

.. [#f2]
   See also :ref:`vbi-525` and :ref:`vbi-625`.