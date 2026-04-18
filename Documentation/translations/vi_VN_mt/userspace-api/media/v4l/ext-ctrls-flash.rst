.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-flash.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _flash-controls:

*****************************
Tham khảo điều khiển đèn nháy
*****************************

Điều khiển đèn flash V4L2 nhằm mục đích cung cấp quyền truy cập chung vào đèn flash
các thiết bị điều khiển. Các thiết bị điều khiển flash thường được sử dụng trong
máy ảnh kỹ thuật số.

Giao diện có thể hỗ trợ cả thiết bị flash LED và xenon. Kể từ
viết bài này, không có trình điều khiển flash xenon sử dụng giao diện này.


.. _flash-controls-use-cases:

Các trường hợp sử dụng được hỗ trợ
===================


Đèn flash LED không đồng bộ (nhấp nháy phần mềm)
------------------------------------------

Đèn flash LED không đồng bộ được máy chủ điều khiển trực tiếp dưới dạng
cảm biến. Người chủ trì phải bật đèn flash trước khi tiếp xúc với đèn flash.
hình ảnh bắt đầu và bị vô hiệu hóa khi nó kết thúc. Chủ nhà hoàn toàn chịu trách nhiệm
về thời gian của đèn flash.

Ví dụ về thiết bị như vậy: Nokia N900.


Đèn flash LED được đồng bộ hóa (nhấp nháy phần cứng)
----------------------------------------

Đèn flash LED được đồng bộ hóa được máy chủ lập trình sẵn (nguồn và
hết thời gian chờ) nhưng được điều khiển bởi cảm biến thông qua tín hiệu nhấp nháy từ
cảm biến tới đèn flash.

Cảm biến kiểm soát thời lượng và thời gian flash. Thông tin này
thường phải được cung cấp cho cảm biến.


LED flash như đèn pin
------------------

Đèn flash LED có thể được sử dụng làm đèn pin kết hợp với trường hợp sử dụng khác
liên quan đến máy ảnh hoặc cá nhân.


.. _flash-control-id:

ID điều khiển flash
-----------------

ZZ0000ZZ
    Bộ mô tả lớp FLASH.

.. _v4l2-cid-flash-led-mode:

ZZ0000ZZ
    Xác định chế độ của đèn flash LED, kèm theo LED màu trắng công suất cao
    tới bộ điều khiển đèn flash. Việc thiết lập điều khiển này có thể không thực hiện được ở
    sự hiện diện của một số lỗi. Xem V4L2_CID_FLASH_FAULT.


.. tabularcolumns:: |p{5.7cm}|p{11.8cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_FLASH_LED_MODE_NONE``
      - Off.
    * - ``V4L2_FLASH_LED_MODE_FLASH``
      - Flash mode.
    * - ``V4L2_FLASH_LED_MODE_TORCH``
      - Torch mode.

        See V4L2_CID_FLASH_TORCH_INTENSITY.



.. _v4l2-cid-flash-strobe-source:

ZZ0000ZZ
    Xác định nguồn nhấp nháy của đèn flash LED.

.. tabularcolumns:: |p{7.5cm}|p{7.5cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_FLASH_STROBE_SOURCE_SOFTWARE``
      - The flash strobe is triggered by using the
	V4L2_CID_FLASH_STROBE control.
    * - ``V4L2_FLASH_STROBE_SOURCE_EXTERNAL``
      - The flash strobe is triggered by an external source. Typically
	this is a sensor, which makes it possible to synchronise the
	flash strobe start to exposure start.
        This method of controlling flash LED strobe has two additional
        prerequisites: the strobe source's :ref:`strobe output
        <v4l2-cid-flash-strobe-oe>` must be enabled (if available)
        and the flash controller's :ref:`flash LED mode
        <v4l2-cid-flash-led-mode>` must be set to
        ``V4L2_FLASH_LED_MODE_FLASH``.



ZZ0000ZZ
    Nhấp nháy nhấp nháy. Hợp lệ khi V4L2_CID_FLASH_LED_MODE được đặt thành
    V4L2_FLASH_LED_MODE_FLASH và V4L2_CID_FLASH_STROBE_SOURCE
    được đặt thành V4L2_FLASH_STROBE_SOURCE_SOFTWARE. Cài đặt cái này
    việc điều khiển có thể không thực hiện được khi có một số lỗi. Xem
    V4L2_CID_FLASH_FAULT.

ZZ0000ZZ
    Dừng nhấp nháy flash ngay lập tức.

ZZ0000ZZ
    Trạng thái nhấp nháy: đèn flash có nhấp nháy vào lúc này hay không.
    Đây là điều khiển chỉ đọc.

ZZ0000ZZ
    Đã hết thời gian chờ phần cứng cho flash. Nhấp nháy đèn flash sẽ dừng sau đó
    khoảng thời gian đã trôi qua kể từ khi bắt đầu nhấp nháy.

ZZ0000ZZ
    Cường độ nhấp nháy của đèn flash khi đèn flash LED ở chế độ đèn flash
    (V4L2_FLASH_LED_MODE_FLASH). Đơn vị phải là milliamp (mA)
    nếu có thể.

ZZ0000ZZ
    Cường độ đèn flash LED ở chế độ đèn pin
    (V4L2_FLASH_LED_MODE_TORCH). Đơn vị phải là milliamp (mA)
    nếu có thể. Việc thiết lập điều khiển này có thể không thực hiện được khi có
    một số lỗi. Xem V4L2_CID_FLASH_FAULT.

ZZ0000ZZ
    Cường độ của chỉ báo LED. Chỉ báo LED có thể hoàn toàn
    độc lập với đèn flash LED. Thiết bị phải là microamp (uA) nếu
    có thể.

ZZ0000ZZ
    Các lỗi liên quan đến đèn flash. Các lỗi nói về các vấn đề cụ thể
    trong chính chip flash hoặc các đèn LED gắn vào nó. Lỗi có thể
    ngăn chặn việc tiếp tục sử dụng một số điều khiển đèn nháy. Đặc biệt,
    V4L2_CID_FLASH_LED_MODE được đặt thành V4L2_FLASH_LED_MODE_NONE
    nếu lỗi ảnh hưởng đến đèn flash LED. Chính xác thì có những lỗi nào như vậy
    một hiệu ứng phụ thuộc vào chip. Đọc lỗi đặt lại điều khiển
    và đưa chip về trạng thái có thể sử dụng được nếu có thể.

.. tabularcolumns:: |p{8.4cm}|p{9.1cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_FLASH_FAULT_OVER_VOLTAGE``
      - Flash controller voltage to the flash LED has exceeded the limit
	specific to the flash controller.
    * - ``V4L2_FLASH_FAULT_TIMEOUT``
      - The flash strobe was still on when the timeout set by the user ---
	V4L2_CID_FLASH_TIMEOUT control --- has expired. Not all flash
	controllers may set this in all such conditions.
    * - ``V4L2_FLASH_FAULT_OVER_TEMPERATURE``
      - The flash controller has overheated.
    * - ``V4L2_FLASH_FAULT_SHORT_CIRCUIT``
      - The short circuit protection of the flash controller has been
	triggered.
    * - ``V4L2_FLASH_FAULT_OVER_CURRENT``
      - Current in the LED power supply has exceeded the limit specific to
	the flash controller.
    * - ``V4L2_FLASH_FAULT_INDICATOR``
      - The flash controller has detected a short or open circuit
	condition on the indicator LED.
    * - ``V4L2_FLASH_FAULT_UNDER_VOLTAGE``
      - Flash controller voltage to the flash LED has been below the
	minimum limit specific to the flash controller.
    * - ``V4L2_FLASH_FAULT_INPUT_VOLTAGE``
      - The input voltage of the flash controller is below the limit under
	which strobing the flash at full current will not be possible.The
	condition persists until this flag is no longer set.
    * - ``V4L2_FLASH_FAULT_LED_OVER_TEMPERATURE``
      - The temperature of the LED has exceeded its allowed upper limit.



ZZ0000ZZ
    Bật hoặc tắt tính năng sạc của tụ đèn flash xenon.

ZZ0000ZZ
    Đèn flash đã sẵn sàng nhấp nháy chưa? Đèn flash xenon cần có tụ điện
    sạc trước khi nhấp nháy. Đèn flash LED thường yêu cầu thời gian hồi chiêu
    sau lần nhấp nháy trong đó không thể thực hiện được lần nhấp nháy khác. Cái này
    là một điều khiển chỉ đọc.

.. _v4l2-cid-flash-duration:

ZZ0000ZZ
    Khoảng thời gian của xung nhấp nháy flash được tạo ra bởi nguồn nhấp nháy, khi
    sử dụng nhấp nháy bên ngoài. Việc kiểm soát này sẽ được thực hiện bởi thiết bị
    tạo ra tín hiệu nhấp nháy flash phần cứng, điển hình là cảm biến máy ảnh,
    được kết nối với bộ điều khiển flash.

Bộ điều khiển đèn flash ZZ0000ZZ
    phải được cấu hình thành ZZ0001ZZ cho việc này
    phương thức hoạt động. Để biết thêm chi tiết xin vui lòng xem thêm tại
    tài liệu ở đó.

Đơn vị phải là micro giây (µs) nếu có thể.

.. _v4l2-cid-flash-strobe-oe:

ZZ0000ZZ
    Cho phép đầu ra tín hiệu nhấp nháy phần cứng từ nguồn nhấp nháy,
    khi sử dụng đèn nhấp nháy bên ngoài. Việc kiểm soát này sẽ được thực hiện bởi thiết bị
    tạo ra tín hiệu nhấp nháy flash phần cứng, điển hình là cảm biến máy ảnh,
    được kết nối với bộ điều khiển flash.

Với điều kiện trình điều khiển thiết bị tạo tín hiệu hỗ trợ nó, độ dài của
    tín hiệu nhấp nháy có thể được cấu hình bằng cách điều chỉnh
    ZZ0000ZZ.

Bộ điều khiển đèn flash ZZ0000ZZ
    phải được cấu hình thành ZZ0001ZZ cho việc này
    phương thức hoạt động. Để biết thêm chi tiết xin vui lòng xem thêm tại
    tài liệu ở đó.