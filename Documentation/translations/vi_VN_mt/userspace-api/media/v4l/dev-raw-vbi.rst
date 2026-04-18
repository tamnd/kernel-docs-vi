.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-raw-vbi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _raw-vbi:

**********************
Giao diện dữ liệu VBI thô
**********************

VBI là tên viết tắt của Khoảng thời gian trống dọc, một khoảng trống trong
chuỗi các dòng của tín hiệu video analog. Trong VBI không có hình ảnh
thông tin được truyền đi, cho phép một thời gian trong khi chùm tia điện tử
của ống tia âm cực TV quay trở lại phía trên màn hình. Sử dụng một
máy hiện sóng bạn sẽ tìm thấy ở đây các xung đồng bộ dọc và
gói dữ liệu ngắn ASK được điều chế [#f1]_ trên tín hiệu video. Đây là
truyền tải các dịch vụ như Teletext hoặc Closed Caption.

Chủ đề của loại giao diện này là dữ liệu VBI thô, được lấy mẫu từ video
tín hiệu hoặc được thêm vào tín hiệu đầu ra. Định dạng dữ liệu là
tương tự như hình ảnh video không nén, số dòng nhân với số
mẫu trên mỗi dòng, chúng tôi gọi đây là hình ảnh VBI.

Thông thường các thiết bị V4L2 VBI được truy cập thông qua thiết bị ký tự
các tệp đặc biệt có tên ZZ0000ZZ và ZZ0001ZZ đến ZZ0002ZZ
với số chính 81 và các số phụ từ 224 đến 255. ZZ0003ZZ là
thường là một liên kết tượng trưng đến thiết bị VBI ưa thích. Công ước này
áp dụng cho cả thiết bị đầu vào và đầu ra.

Để giải quyết các vấn đề tìm kiếm video liên quan và thiết bị VBI VBI
thu thập và xuất cũng có sẵn dưới dạng chức năng của thiết bị trong
ZZ0001ZZ. Để thu thập hoặc xuất dữ liệu VBI thô bằng các thiết bị này
các ứng dụng phải gọi ZZ0000ZZ ioctl.
Được truy cập dưới dạng ZZ0002ZZ, việc chụp hoặc xuất VBI thô là mặc định
chức năng thiết bị.

Khả năng truy vấn
=====================

Các thiết bị hỗ trợ VBI thu hoặc xuất API thô sẽ đặt
Cờ ZZ0002ZZ hoặc ZZ0003ZZ tương ứng,
trong trường ZZ0004ZZ của cấu trúc
ZZ0000ZZ được trả lại bởi
ZZ0001ZZ ioctl. Ít nhất một trong số
Các phương thức đọc/ghi hoặc truyền phát I/O phải được hỗ trợ. VBI
các thiết bị có thể có hoặc không có bộ điều chỉnh hoặc bộ điều biến.

Chức năng bổ sung
======================

Các thiết bị VBI sẽ hỗ trợ ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ
ioctls khi cần thiết. Các ioctls ZZ0003ZZ cung cấp
do đó, thông tin quan trọng để lập trình thiết bị VBI phải được hỗ trợ.

Đàm phán định dạng VBI thô
==========================

Khả năng lấy mẫu VBI thô có thể khác nhau, đặc biệt là lấy mẫu
tần số. Để giải thích chính xác dữ liệu V4L2 chỉ định ioctl cho
truy vấn các tham số lấy mẫu. Hơn nữa, để cho phép sự linh hoạt
các ứng dụng cũng có thể đề xuất các thông số khác nhau.

Như thường lệ các thông số này được reset ZZ0001ZZ tại ZZ0000ZZ
đã đến lúc cho phép các chuỗi công cụ Unix, lập trình một thiết bị và sau đó đọc
từ nó như thể nó là một tập tin đơn giản. Các ứng dụng V4L2 được viết tốt nên
luôn đảm bảo họ thực sự đạt được điều họ muốn, yêu cầu hợp lý
tham số và sau đó kiểm tra xem các tham số thực tế có phù hợp hay không.

Để truy vấn các ứng dụng tham số chụp VBI thô hiện tại, hãy đặt
Trường ZZ0003ZZ của cấu trúc ZZ0000ZZ để
ZZ0004ZZ hoặc ZZ0005ZZ và gọi
ioctl ZZ0001ZZ với một con trỏ tới đây
cấu trúc. Trình điều khiển điền vào cấu trúc
ZZ0002ZZ ZZ0006ZZ thành viên của
Công đoàn ZZ0007ZZ.

Để yêu cầu các ứng dụng tham số khác nhau, hãy đặt trường ZZ0008ZZ của
struct ZZ0000ZZ như trên và khởi tạo tất cả
các trường của cấu trúc ZZ0001ZZ
ZZ0009ZZ là thành viên của liên minh ZZ0010ZZ, hoặc tốt hơn là chỉ cần sửa đổi kết quả
của ZZ0002ZZ và gọi ZZ0003ZZ
ioctl bằng một con trỏ tới cấu trúc này. Trình điều khiển trả về lỗi ZZ0011ZZ
chỉ mã khi các tham số đã cho không rõ ràng, nếu không chúng sẽ sửa đổi
các thông số theo khả năng phần cứng và trả về
các thông số thực tế. Khi trình điều khiển phân bổ tài nguyên vào thời điểm này, nó
có thể trả về mã lỗi ZZ0012ZZ để cho biết các tham số được trả về là
hợp lệ nhưng các tài nguyên cần thiết hiện không có sẵn. Điều đó có thể
chẳng hạn xảy ra khi vùng video và VBI cần quay sẽ
chồng chéo hoặc khi trình điều khiển hỗ trợ mở nhiều lần và một quy trình khác
đã yêu cầu chụp hoặc xuất VBI. Dù sao đi nữa, các ứng dụng phải
mong đợi các điểm phân bổ tài nguyên khác có thể trả về ZZ0013ZZ, tại
ZZ0004ZZ ioctl và ZZ0005ZZ đầu tiên
, cuộc gọi ZZ0006ZZ và ZZ0007ZZ.

Các thiết bị VBI phải triển khai cả ZZ0000ZZ và
ZZ0001ZZ ioctl, ngay cả khi ZZ0002ZZ bỏ qua tất cả các yêu cầu
và luôn trả về các tham số mặc định như ZZ0003ZZ.
ZZ0004ZZ là tùy chọn.

.. tabularcolumns:: |p{1.6cm}|p{4.2cm}|p{11.5cm}|

.. c:type:: v4l2_vbi_format

.. cssclass:: longtable

.. flat-table:: struct v4l2_vbi_format
    :header-rows:  0
    :stub-columns: 0
    :widths:       1 1 2

    * - __u32
      - ``sampling_rate``
      - Samples per second, i. e. unit 1 Hz.
    * - __u32
      - ``offset``
      - Horizontal offset of the VBI image, relative to the leading edge
	of the line synchronization pulse and counted in samples: The
	first sample in the VBI image will be located ``offset`` /
	``sampling_rate`` seconds following the leading edge. See also
	:ref:`vbi-hsync`.
    * - __u32
      - ``samples_per_line``
      -
    * - __u32
      - ``sample_format``
      - Defines the sample format as in :ref:`pixfmt`, a
	four-character-code. [#f2]_ Usually this is ``V4L2_PIX_FMT_GREY``,
	i. e. each sample consists of 8 bits with lower values oriented
	towards the black level. Do not assume any other correlation of
	values with the signal level. For example, the MSB does not
	necessarily indicate if the signal is 'high' or 'low' because 128
	may not be the mean value of the signal. Drivers shall not convert
	the sample format by software.
    * - __u32
      - ``start``\ [#f2]_
      - This is the scanning system line number associated with the first
	line of the VBI image, of the first and the second field
	respectively. See :ref:`vbi-525` and :ref:`vbi-625` for valid
	values. The ``V4L2_VBI_ITU_525_F1_START``,
	``V4L2_VBI_ITU_525_F2_START``, ``V4L2_VBI_ITU_625_F1_START`` and
	``V4L2_VBI_ITU_625_F2_START`` defines give the start line numbers
	for each field for each 525 or 625 line format as a convenience.
	Don't forget that ITU line numbering starts at 1, not 0. VBI input
	drivers can return start values 0 if the hardware cannot reliable
	identify scanning lines, VBI acquisition may not require this
	information.
    * - __u32
      - ``count``\ [#f2]_
      - The number of lines in the first and second field image,
	respectively.
    * - :cspan:`2`

	Drivers should be as flexibility as possible. For example, it may
	be possible to extend or move the VBI capture window down to the
	picture area, implementing a 'full field mode' to capture data
	service transmissions embedded in the picture.

	An application can set the first or second ``count`` value to zero
	if no data is required from the respective field; ``count``\ [1]
	if the scanning system is progressive, i. e. not interlaced. The
	corresponding start value shall be ignored by the application and
	driver. Anyway, drivers may not support single field capturing and
	return both count values non-zero.

	Both ``count`` values set to zero, or line numbers are outside the
	bounds depicted\ [#f4]_, or a field image covering lines of two
	fields, are invalid and shall not be returned by the driver.

	To initialize the ``start`` and ``count`` fields, applications
	must first determine the current video standard selection. The
	:ref:`v4l2_std_id <v4l2-std-id>` or the ``framelines`` field
	of struct :c:type:`v4l2_standard` can be evaluated
	for this purpose.
    * - __u32
      - ``flags``
      - See :ref:`vbifmt-flags` below. Currently only drivers set flags,
	applications must set this field to zero.
    * - __u32
      - ``reserved``\ [#f2]_
      - This array is reserved for future extensions. Drivers and
	applications must set it to zero.

.. tabularcolumns:: |p{4.4cm}|p{1.5cm}|p{11.4cm}|

.. _vbifmt-flags:

.. flat-table:: Raw VBI Format Flags
    :header-rows:  0
    :stub-columns: 0
    :widths:       3 1 4

    * - ``V4L2_VBI_UNSYNC``
      - 0x0001
      - This flag indicates hardware which does not properly distinguish
	between fields. Normally the VBI image stores the first field
	(lower scanning line numbers) first in memory. This may be a top
	or bottom field depending on the video standard. When this flag is
	set the first or second field may be stored first, however the
	fields are still in correct temporal order with the older field
	first in memory. [#f3]_
    * - ``V4L2_VBI_INTERLACED``
      - 0x0002
      - By default the two field images will be passed sequentially; all
	lines of the first field followed by all lines of the second field
	(compare :ref:`field-order` ``V4L2_FIELD_SEQ_TB`` and
	``V4L2_FIELD_SEQ_BT``, whether the top or bottom field is first in
	memory depends on the video standard). When this flag is set, the
	two fields are interlaced (cf. ``V4L2_FIELD_INTERLACED``). The
	first line of the first field followed by the first line of the
	second field, then the two second lines, and so on. Such a layout
	may be necessary when the hardware has been programmed to capture
	or output interlaced video images and is unable to separate the
	fields for VBI capturing at the same time. For simplicity setting
	this flag implies that both ``count`` values are equal and
	non-zero.


.. _vbi-hsync:

.. kernel-figure:: vbi_hsync.svg
    :alt:   vbi_hsync.svg
    :align: center

    Line synchronization

.. _vbi-525:

.. kernel-figure:: vbi_525.svg
    :alt:   vbi_525.svg
    :align: center

    ITU-R 525 line numbering (M/NTSC and M/PAL)

.. _vbi-625:

.. kernel-figure:: vbi_625.svg
    :alt:   vbi_625.svg
    :align: center

    ITU-R 625 line numbering

Hãy nhớ định dạng hình ảnh VBI phụ thuộc vào tiêu chuẩn video đã chọn,
do đó ứng dụng phải chọn một tiêu chuẩn mới hoặc truy vấn
tiêu chuẩn hiện hành đầu tiên. Cố gắng đọc hoặc ghi dữ liệu trước định dạng
thương lượng hoặc sau khi chuyển đổi tiêu chuẩn video có thể làm mất hiệu lực
các thông số VBI đã thương lượng sẽ bị người lái xe từ chối. Một định dạng
không được phép thay đổi trong quá trình I/O đang hoạt động.

Đọc và ghi hình ảnh VBI
==============================

Để đảm bảo đồng bộ với số trường và dễ dàng hơn
thực hiện, đơn vị dữ liệu nhỏ nhất được truyền tại một thời điểm là một khung,
bao gồm hai trường hình ảnh VBI ngay sau trong bộ nhớ.

Tổng kích thước của một khung được tính như sau:

.. code-block:: c

    (count[0] + count[1]) * samples_per_line * sample size in bytes

Kích thước mẫu rất có thể luôn là một byte, các ứng dụng phải kiểm tra
Tuy nhiên, trường ZZ0000ZZ để hoạt động bình thường với các trường khác
trình điều khiển.

Thiết bị VBI có thể hỗ trợ ZZ0000ZZ và/hoặc phát trực tuyến
(ZZ0001ZZ hoặc ZZ0002ZZ) I/O.
Cái sau có khả năng đồng bộ hóa video và dữ liệu VBI bằng cách
sử dụng dấu thời gian đệm.

Hãy nhớ ZZ0000ZZ ioctl và
đầu tiên là ZZ0001ZZ, ZZ0002ZZ và
Cuộc gọi ZZ0003ZZ có thể được phân bổ tài nguyên
điểm trả về mã lỗi ZZ0004ZZ nếu tài nguyên phần cứng cần thiết
tạm thời không khả dụng, ví dụ như thiết bị đã được sử dụng bởi
một quá trình khác.

.. [#f1]
   ASK: Amplitude-Shift Keying. A high signal level represents a '1'
   bit, a low level a '0' bit.

.. [#f2]
   A few devices may be unable to sample VBI data at all but can extend
   the video capture window to the VBI region.

.. [#f3]
   Most VBI services transmit on both fields, but some have different
   semantics depending on the field number. These cannot be reliable
   decoded or encoded when ``V4L2_VBI_UNSYNC`` is set.

.. [#f4]
   The valid values ar shown at :ref:`vbi-525` and :ref:`vbi-625`.