.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-camera.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _camera-controls:

***************************
Tham khảo điều khiển camera
***************************

Lớp Camera bao gồm các điều khiển cho cơ khí (hoặc tương đương)
kỹ thuật số) của một thiết bị như ống kính hoặc cảm biến có thể điều khiển được.


.. _camera-control-id:

ID điều khiển camera
==================

ZZ0001ZZ
    Bộ mô tả lớp Camera. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

.. _v4l2-exposure-auto-type:

ZZ0000ZZ
    (enum)

enum v4l2_exposure_auto_type -
    Cho phép tự động điều chỉnh thời gian phơi sáng và/hoặc mống mắt
    khẩu độ. Ảnh hưởng của việc thay đổi thủ công thời gian phơi sáng hoặc mống mắt
    khẩu độ trong khi các tính năng này được bật không được xác định, trình điều khiển
    nên bỏ qua những yêu cầu như vậy. Các giá trị có thể là:


.. tabularcolumns:: |p{7.1cm}|p{10.4cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_EXPOSURE_AUTO``
      - Automatic exposure time, automatic iris aperture.
    * - ``V4L2_EXPOSURE_MANUAL``
      - Manual exposure time, manual iris.
    * - ``V4L2_EXPOSURE_SHUTTER_PRIORITY``
      - Manual exposure time, auto iris.
    * - ``V4L2_EXPOSURE_APERTURE_PRIORITY``
      - Auto exposure time, manual iris.



ZZ0000ZZ
    Xác định thời gian phơi sáng của cảm biến máy ảnh. Thời gian phơi sáng
    bị giới hạn bởi khoảng thời gian khung. Người lái xe nên giải thích các
    giá trị là 100 µs đơn vị, trong đó giá trị 1 đại diện cho 1/10000 của a
    giây, 10000 trong 1 giây và 100000 trong 10 giây.

ZZ0000ZZ
    Khi ZZ0001ZZ được đặt thành ZZ0002ZZ hoặc
    ZZ0003ZZ, điều khiển này sẽ xác định xem thiết bị có thể
    tự động thay đổi tốc độ khung hình. Theo mặc định tính năng này bị tắt
    (0) và tốc độ khung hình phải không đổi.

ZZ0000ZZ
    Xác định mức bù phơi sáng tự động, nó chỉ có hiệu lực
    khi điều khiển ZZ0001ZZ được đặt thành ZZ0002ZZ,
    ZZ0003ZZ hoặc ZZ0004ZZ. Nó được thể hiện ở
    về EV, người lái xe nên hiểu các giá trị là 0,001 đơn vị EV,
    trong đó giá trị 1000 là viết tắt của +1 EV.

Việc tăng giá trị bù phơi sáng tương đương với
    giảm giá trị phơi sáng (EV) và sẽ tăng lượng
    ánh sáng ở cảm biến hình ảnh. Máy ảnh thực hiện phơi sáng
    bù bằng cách điều chỉnh thời gian phơi sáng tuyệt đối và/hoặc khẩu độ.

.. _v4l2-exposure-metering:

ZZ0000ZZ
    (enum)

enum v4l2_exposure_metering -
    Xác định cách máy ảnh đo lượng ánh sáng có sẵn cho
    độ phơi sáng của khung hình. Các giá trị có thể là:

.. tabularcolumns:: |p{8.7cm}|p{8.7cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_EXPOSURE_METERING_AVERAGE``
      - Use the light information coming from the entire frame and average
	giving no weighting to any particular portion of the metered area.
    * - ``V4L2_EXPOSURE_METERING_CENTER_WEIGHTED``
      - Average the light information coming from the entire frame giving
	priority to the center of the metered area.
    * - ``V4L2_EXPOSURE_METERING_SPOT``
      - Measure only very small area at the center of the frame.
    * - ``V4L2_EXPOSURE_METERING_MATRIX``
      - A multi-zone metering. The light intensity is measured in several
	points of the frame and the results are combined. The algorithm of
	the zones selection and their significance in calculating the
	final value is device dependent.



ZZ0000ZZ
    Điều khiển này xoay camera theo chiều ngang theo khoảng được chỉ định.
    Đơn vị không được xác định. Giá trị dương sẽ di chuyển camera tới
    phải (theo chiều kim đồng hồ khi nhìn từ trên xuống), một giá trị âm đối với
    trái. Giá trị bằng 0 không gây ra chuyển động. Đây là phiên bản chỉ ghi
    kiểm soát.

ZZ0000ZZ
    Điều khiển này xoay camera theo chiều dọc theo khoảng được chỉ định.
    Đơn vị không được xác định. Giá trị dương sẽ di chuyển camera lên trên, a
    giá trị âm giảm xuống. Giá trị bằng 0 không gây ra chuyển động. Đây là
    một điều khiển chỉ ghi.

ZZ0000ZZ
    Khi điều khiển này được thiết lập, máy ảnh sẽ di chuyển theo chiều ngang tới
    vị trí mặc định.

ZZ0000ZZ
    Khi cài đặt điều khiển này, camera sẽ di chuyển theo chiều dọc về vị trí mặc định
    vị trí.

ZZ0000ZZ
    Điều khiển này xoay camera theo chiều ngang tới vị trí được chỉ định
    vị trí. Giá trị dương di chuyển camera sang phải (theo chiều kim đồng hồ
    khi nhìn từ trên xuống), giá trị âm ở bên trái. Người lái xe nên
    diễn giải các giá trị dưới dạng cung giây, với các giá trị hợp lệ trong khoảng -180
    * Bao gồm 3600 và +180 * 3600.

ZZ0000ZZ
    Điều khiển này xoay camera theo chiều dọc đến vị trí được chỉ định.
    Giá trị dương sẽ di chuyển camera lên, giá trị âm sẽ di chuyển camera xuống. Trình điều khiển
    nên diễn giải các giá trị dưới dạng giây cung, với các giá trị hợp lệ
    trong khoảng từ -180 * 3600 đến +180 * 3600.

ZZ0000ZZ
    Điều khiển này đặt tiêu điểm của máy ảnh theo tiêu điểm đã chỉ định
    vị trí. Đơn vị không được xác định. Giá trị dương đặt trọng tâm
    càng gần camera thì giá trị âm càng tiến tới vô cùng.

ZZ0000ZZ
    Điều khiển này di chuyển tiêu điểm của máy ảnh theo hướng được chỉ định
    số tiền. Đơn vị không được xác định. Giá trị dương di chuyển tiêu điểm đến gần hơn
    đối với máy ảnh, giá trị âm hướng tới vô cùng. Đây là một
    điều khiển chỉ ghi.

ZZ0000ZZ
    Cho phép điều chỉnh lấy nét tự động liên tục. Tác dụng của hướng dẫn sử dụng
    điều chỉnh tiêu điểm trong khi tính năng này được bật là không xác định,
    người lái xe nên bỏ qua những yêu cầu như vậy.

ZZ0000ZZ
    Bắt đầu quá trình lấy nét tự động đơn. Tác dụng của việc thiết lập điều khiển này
    khi ZZ0001ZZ được đặt thành ZZ0002ZZ (1) không được xác định,
    người lái xe nên bỏ qua những yêu cầu như vậy.

ZZ0000ZZ
    Hủy bỏ việc lấy nét tự động đã bắt đầu với ZZ0001ZZ
    kiểm soát. Nó chỉ có hiệu quả khi lấy nét tự động liên tục
    bị tắt, đó là khi điều khiển ZZ0002ZZ được đặt thành
    ZZ0003ZZ (0).

.. _v4l2-auto-focus-status:

ZZ0000ZZ
    Trạng thái lấy nét tự động. Đây là điều khiển chỉ đọc.

Đặt bit khóa ZZ0000ZZ của ZZ0001ZZ
    kiểm soát có thể dừng cập nhật của ZZ0002ZZ
    giá trị điều khiển.

.. tabularcolumns:: |p{6.8cm}|p{10.7cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_AUTO_FOCUS_STATUS_IDLE``
      - Automatic focus is not active.
    * - ``V4L2_AUTO_FOCUS_STATUS_BUSY``
      - Automatic focusing is in progress.
    * - ``V4L2_AUTO_FOCUS_STATUS_REACHED``
      - Focus has been reached.
    * - ``V4L2_AUTO_FOCUS_STATUS_FAILED``
      - Automatic focus has failed, the driver will not transition from
	this state until another action is performed by an application.



.. _v4l2-auto-focus-range:

ZZ0000ZZ
    (enum)

enum v4l2_auto_focus_range -
    Xác định phạm vi khoảng cách lấy nét tự động mà ống kính có thể được điều chỉnh.

.. tabularcolumns:: |p{6.9cm}|p{10.6cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_AUTO_FOCUS_RANGE_AUTO``
      - The camera automatically selects the focus range.
    * - ``V4L2_AUTO_FOCUS_RANGE_NORMAL``
      - Normal distance range, limited for best automatic focus
	performance.
    * - ``V4L2_AUTO_FOCUS_RANGE_MACRO``
      - Macro (close-up) auto focus. The camera will use its minimum
	possible distance for auto focus.
    * - ``V4L2_AUTO_FOCUS_RANGE_INFINITY``
      - The lens is set to focus on an object at infinite distance.



ZZ0000ZZ
    Chỉ định tiêu cự của vật kính làm giá trị tuyệt đối. các
    đơn vị thu phóng dành riêng cho trình điều khiển và giá trị của nó phải là số dương
    số nguyên.

ZZ0000ZZ
    Chỉ định tiêu cự của vật kính tương ứng với tiêu cự hiện tại
    giá trị. Các giá trị dương sẽ di chuyển nhóm thấu kính zoom về phía
    hướng tele, giá trị âm hướng tới góc rộng
    hướng. Đơn vị thu phóng dành riêng cho trình điều khiển. Đây là phiên bản chỉ ghi
    kiểm soát.

ZZ0000ZZ
    Di chuyển nhóm vật kính ở tốc độ xác định cho đến khi nó
    đạt đến giới hạn thiết bị vật lý hoặc cho đến khi có yêu cầu dừng rõ ràng
    phong trào. Giá trị dương sẽ di chuyển nhóm thấu kính zoom về phía
    hướng chụp ảnh xa. Giá trị bằng 0 sẽ dừng nhóm ống kính zoom
    chuyển động. Giá trị âm sẽ di chuyển nhóm thấu kính zoom về phía
    hướng góc rộng. Đơn vị tốc độ thu phóng dành riêng cho trình điều khiển.

ZZ0000ZZ
    Điều khiển này đặt khẩu độ của máy ảnh thành giá trị được chỉ định. các
    đơn vị không được xác định Giá trị lớn hơn mở mống mắt rộng hơn, giá trị nhỏ hơn
    đóng nó lại.

ZZ0000ZZ
    Điều khiển này sửa đổi khẩu độ của máy ảnh theo mức được chỉ định.
    Đơn vị không được xác định. Giá trị dương mở mống mắt một bước
    hơn nữa, các giá trị âm sẽ đóng nó thêm một bước nữa. Đây là một
    điều khiển chỉ ghi.

ZZ0000ZZ
    Ngăn không cho máy ảnh thu được video. Khi điều khiển này
    được đặt thành ZZ0001ZZ (1), máy ảnh không thể chụp được hình ảnh nào.
    Các phương tiện phổ biến để thực thi quyền riêng tư là sự che khuất cơ học của
    xử lý hình ảnh cảm biến và phần sụn, nhưng thiết bị thì không
    hạn chế đối với các phương pháp này. Các thiết bị thực hiện quyền riêng tư
    điều khiển phải hỗ trợ quyền truy cập đọc và có thể hỗ trợ quyền truy cập ghi.

ZZ0000ZZ
    Bật hoặc tắt bộ lọc chặn dải của cảm biến máy ảnh hoặc chỉ định
    sức mạnh của nó. Các bộ lọc chặn dải như vậy có thể được sử dụng, ví dụ, để
    lọc thành phần ánh sáng huỳnh quang.

.. _v4l2-auto-n-preset-white-balance:

ZZ0000ZZ
    (enum)

enum v4l2_auto_n_preset_white_balance -
    Đặt cân bằng trắng thành tự động, thủ công hoặc cài đặt sẵn. Các cài đặt trước
    xác định nhiệt độ màu của ánh sáng để gợi ý cho máy ảnh về
    điều chỉnh cân bằng trắng mang lại màu sắc chính xác nhất
    đại diện. Các cài đặt trước cân bằng trắng sau đây được liệt kê trong
    thứ tự tăng dần nhiệt độ màu.

.. tabularcolumns:: |p{7.4cm}|p{10.1cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_WHITE_BALANCE_MANUAL``
      - Manual white balance.
    * - ``V4L2_WHITE_BALANCE_AUTO``
      - Automatic white balance adjustments.
    * - ``V4L2_WHITE_BALANCE_INCANDESCENT``
      - White balance setting for incandescent (tungsten) lighting. It
	generally cools down the colors and corresponds approximately to
	2500...3500 K color temperature range.
    * - ``V4L2_WHITE_BALANCE_FLUORESCENT``
      - White balance preset for fluorescent lighting. It corresponds
	approximately to 4000...5000 K color temperature.
    * - ``V4L2_WHITE_BALANCE_FLUORESCENT_H``
      - With this setting the camera will compensate for fluorescent H
	lighting.
    * - ``V4L2_WHITE_BALANCE_HORIZON``
      - White balance setting for horizon daylight. It corresponds
	approximately to 5000 K color temperature.
    * - ``V4L2_WHITE_BALANCE_DAYLIGHT``
      - White balance preset for daylight (with clear sky). It corresponds
	approximately to 5000...6500 K color temperature.
    * - ``V4L2_WHITE_BALANCE_FLASH``
      - With this setting the camera will compensate for the flash light.
	It slightly warms up the colors and corresponds roughly to
	5000...5500 K color temperature.
    * - ``V4L2_WHITE_BALANCE_CLOUDY``
      - White balance preset for moderately overcast sky. This option
	corresponds approximately to 6500...8000 K color temperature
	range.
    * - ``V4L2_WHITE_BALANCE_SHADE``
      - White balance preset for shade or heavily overcast sky. It
	corresponds approximately to 9000...10000 K color temperature.



.. _v4l2-wide-dynamic-range:

ZZ0000ZZ
    Bật hoặc tắt tính năng dải động rộng của máy ảnh. Cái này
    tính năng cho phép thu được hình ảnh rõ ràng trong các tình huống có cường độ
    độ chiếu sáng thay đổi đáng kể trong suốt khung cảnh, tức là.
    đồng thời có những vùng rất tối và rất sáng. Đó là hầu hết
    thường được thực hiện trong máy ảnh bằng cách kết hợp hai khung hình tiếp theo với
    thời gian phơi sáng khác nhau.  [#f1]_

.. _v4l2-image-stabilization:

ZZ0000ZZ
    Bật hoặc tắt tính năng ổn định hình ảnh.

ZZ0001ZZ
    Xác định ISO tương đương với cảm biến hình ảnh cho biết
    nhạy cảm với ánh sáng. Các số được biểu diễn dưới dạng thang số học,
    theo tiêu chuẩn ZZ0000ZZ, trong đó tăng gấp đôi cảm biến
    độ nhạy được biểu thị bằng cách nhân đôi giá trị số ISO.
    Các ứng dụng sẽ diễn giải các giá trị dưới dạng giá trị ISO tiêu chuẩn
    nhân với 1000, ví dụ: giá trị điều khiển 800 là viết tắt của ISO 0,8.
    Trình điều khiển thường sẽ chỉ hỗ trợ một tập hợp con các giá trị ISO tiêu chuẩn.
    Tác dụng của việc thiết lập điều khiển này trong khi
    Điều khiển ZZ0002ZZ được đặt thành giá trị khác
    hơn ZZ0003ZZ không được xác định, trình điều khiển
    nên bỏ qua những yêu cầu như vậy.

.. _v4l2-iso-sensitivity-auto-type:

ZZ0000ZZ
    (enum)

enum v4l2_iso_sensitive_type -
    Bật hoặc tắt điều chỉnh độ nhạy ISO tự động.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_CID_ISO_SENSITIVITY_MANUAL``
      - Manual ISO sensitivity.
    * - ``V4L2_CID_ISO_SENSITIVITY_AUTO``
      - Automatic ISO sensitivity adjustments.



.. _v4l2-scene-mode:

ZZ0000ZZ
    (enum)

enum v4l2_scene_mode -
    Điều khiển này cho phép chọn các chương trình cảnh khi máy ảnh tự động
    các chế độ được tối ưu hóa cho các cảnh chụp thông thường. Trong các chế độ này,
    máy ảnh xác định độ phơi sáng, khẩu độ, lấy nét, đo sáng tốt nhất,
    cân bằng trắng và độ nhạy tương đương. Sự kiểm soát của những
    các thông số bị ảnh hưởng bởi việc điều khiển chế độ cảnh. Một chính xác
    hoạt động ở mỗi chế độ tùy thuộc vào thông số kỹ thuật của máy ảnh.

Khi tính năng chế độ cảnh không được sử dụng, điều khiển này phải được đặt
    tới ZZ0000ZZ để đảm bảo cái khác có thể liên quan
    điều khiển có thể truy cập được. Các chương trình cảnh sau đây được xác định:

.. raw:: latex

    \small

.. tabularcolumns:: |p{5.9cm}|p{11.6cm}|

.. cssclass:: longtable

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_SCENE_MODE_NONE``
      - The scene mode feature is disabled.
    * - ``V4L2_SCENE_MODE_BACKLIGHT``
      - Backlight. Compensates for dark shadows when light is coming from
	behind a subject, also by automatically turning on the flash.
    * - ``V4L2_SCENE_MODE_BEACH_SNOW``
      - Beach and snow. This mode compensates for all-white or bright
	scenes, which tend to look gray and low contrast, when camera's
	automatic exposure is based on an average scene brightness. To
	compensate, this mode automatically slightly overexposes the
	frames. The white balance may also be adjusted to compensate for
	the fact that reflected snow looks bluish rather than white.
    * - ``V4L2_SCENE_MODE_CANDLELIGHT``
      - Candle light. The camera generally raises the ISO sensitivity and
	lowers the shutter speed. This mode compensates for relatively
	close subject in the scene. The flash is disabled in order to
	preserve the ambiance of the light.
    * - ``V4L2_SCENE_MODE_DAWN_DUSK``
      - Dawn and dusk. Preserves the colors seen in low natural light
	before dusk and after down. The camera may turn off the flash, and
	automatically focus at infinity. It will usually boost saturation
	and lower the shutter speed.
    * - ``V4L2_SCENE_MODE_FALL_COLORS``
      - Fall colors. Increases saturation and adjusts white balance for
	color enhancement. Pictures of autumn leaves get saturated reds
	and yellows.
    * - ``V4L2_SCENE_MODE_FIREWORKS``
      - Fireworks. Long exposure times are used to capture the expanding
	burst of light from a firework. The camera may invoke image
	stabilization.
    * - ``V4L2_SCENE_MODE_LANDSCAPE``
      - Landscape. The camera may choose a small aperture to provide deep
	depth of field and long exposure duration to help capture detail
	in dim light conditions. The focus is fixed at infinity. Suitable
	for distant and wide scenery.
    * - ``V4L2_SCENE_MODE_NIGHT``
      - Night, also known as Night Landscape. Designed for low light
	conditions, it preserves detail in the dark areas without blowing
	out bright objects. The camera generally sets itself to a
	medium-to-high ISO sensitivity, with a relatively long exposure
	time, and turns flash off. As such, there will be increased image
	noise and the possibility of blurred image.
    * - ``V4L2_SCENE_MODE_PARTY_INDOOR``
      - Party and indoor. Designed to capture indoor scenes that are lit
	by indoor background lighting as well as the flash. The camera
	usually increases ISO sensitivity, and adjusts exposure for the
	low light conditions.
    * - ``V4L2_SCENE_MODE_PORTRAIT``
      - Portrait. The camera adjusts the aperture so that the depth of
	field is reduced, which helps to isolate the subject against a
	smooth background. Most cameras recognize the presence of faces in
	the scene and focus on them. The color hue is adjusted to enhance
	skin tones. The intensity of the flash is often reduced.
    * - ``V4L2_SCENE_MODE_SPORTS``
      - Sports. Significantly increases ISO and uses a fast shutter speed
	to freeze motion of rapidly-moving subjects. Increased image noise
	may be seen in this mode.
    * - ``V4L2_SCENE_MODE_SUNSET``
      - Sunset. Preserves deep hues seen in sunsets and sunrises. It bumps
	up the saturation.
    * - ``V4L2_SCENE_MODE_TEXT``
      - Text. It applies extra contrast and sharpness, it is typically a
	black-and-white mode optimized for readability. Automatic focus
	may be switched to close-up mode and this setting may also involve
	some lens-distortion correction.

.. raw:: latex

    \normalsize


ZZ0000ZZ
    Điều khiển này khóa hoặc mở khóa lấy nét, phơi sáng và tự động
    cân bằng trắng. Việc điều chỉnh tự động có thể được tạm dừng một cách độc lập
    bằng cách đặt bit khóa tương ứng thành 1. Sau đó, máy ảnh sẽ giữ lại
    cài đặt cho đến khi bit khóa bị xóa. Các bit khóa sau
    được định nghĩa:

Khi thuật toán nhất định không được bật, trình điều khiển nên bỏ qua
    yêu cầu khóa nó và sẽ không trả lại lỗi. Một ví dụ có thể là
    bit cài đặt ứng dụng ZZ0000ZZ khi
    Điều khiển ZZ0001ZZ được đặt thành ZZ0002ZZ. các
    giá trị của điều khiển này có thể bị thay đổi do phơi sáng, cân bằng trắng hoặc
    điều khiển tập trung.



.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_LOCK_EXPOSURE``
      - Automatic exposure adjustments lock.
    * - ``V4L2_LOCK_WHITE_BALANCE``
      - Automatic white balance adjustments lock.
    * - ``V4L2_LOCK_FOCUS``
      - Automatic focus lock.



ZZ0000ZZ
    Điều khiển này xoay camera theo chiều ngang ở tốc độ cụ thể.
    Đơn vị không được xác định. Giá trị dương sẽ di chuyển camera tới
    phải (theo chiều kim đồng hồ khi nhìn từ trên xuống), một giá trị âm đối với
    trái. Giá trị bằng 0 sẽ dừng chuyển động nếu chuyển động đang diễn ra và có
    không có tác dụng khác.

ZZ0000ZZ
    Điều khiển này quay camera theo chiều dọc ở tốc độ được chỉ định. các
    đơn vị không được xác định Giá trị dương sẽ di chuyển camera lên, giá trị âm
    giá trị xuống. Giá trị bằng 0 sẽ dừng chuyển động nếu chuyển động đang diễn ra
    và không có tác dụng khác.

.. _v4l2-camera-sensor-orientation:

ZZ0000ZZ
    Điều khiển chỉ đọc này mô tả hướng của máy ảnh bằng cách báo cáo hướng của nó.
    vị trí lắp đặt trên thiết bị nơi lắp đặt camera. Sự kiểm soát
    giá trị không đổi và không thể sửa đổi bằng phần mềm. Sự kiểm soát này là
    đặc biệt có ý nghĩa đối với các thiết bị có định hướng được xác định rõ ràng,
    chẳng hạn như điện thoại, máy tính xách tay và thiết bị cầm tay vì quyền kiểm soát được thể hiện
    như một vị trí liên quan đến định hướng sử dụng dự định của thiết bị. cho
    ví dụ: một camera được cài đặt ở phía trước của điện thoại, máy tính bảng hoặc
    một thiết bị máy tính xách tay được cho là có ZZ0001ZZ
    hướng, trong khi camera được lắp ở phía đối diện với camera phía trước
    được cho là có hướng ZZ0002ZZ. Máy ảnh
    cảm biến không được gắn trực tiếp vào thiết bị hoặc được gắn theo cách
    cho phép chúng di chuyển tự do, chẳng hạn như webcam và máy ảnh kỹ thuật số, được cho là
    có hướng ZZ0003ZZ.


.. tabularcolumns:: |p{7.7cm}|p{9.8cm}|

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_CAMERA_ORIENTATION_FRONT``
      - The camera is oriented towards the user facing side of the device.
    * - ``V4L2_CAMERA_ORIENTATION_BACK``
      - The camera is oriented towards the back facing side of the device.
    * - ``V4L2_CAMERA_ORIENTATION_EXTERNAL``
      - The camera is not directly attached to the device and is freely movable.


.. _v4l2-camera-sensor-rotation:

ZZ0000ZZ
    Điều khiển chỉ đọc này mô tả việc điều chỉnh xoay theo độ trong
    hướng ngược chiều kim đồng hồ sẽ được áp dụng cho ảnh đã chụp một lần
    được ghi vào bộ nhớ để bù cho việc xoay gắn cảm biến máy ảnh.

Để biết định nghĩa chính xác về góc quay gắn cảm biến, hãy tham khảo
    mô tả chi tiết về thuộc tính 'xoay' trong cây thiết bị
    tệp liên kết 'video-interfaces.txt'.

Một vài ví dụ được báo cáo dưới đây, sử dụng một con cá mập bơi từ trái sang
    ngay trước mặt người dùng làm cảnh mẫu cần chụp. ::

0 trục X
               0 +--------------------------------------->
                 !
                 !
                 !
                 !           |\____)\___
                 !           ) _____ __`<
                 !           |/ )/
                 !
                 !
                 !
                 V.
               Trục Y

Ví dụ một - Webcam

Giả sử bạn có thể mang theo máy tính xách tay khi bơi cùng cá mập,
    mô-đun máy ảnh của máy tính xách tay được cài đặt trên phần hướng tới người dùng của
    vỏ màn hình máy tính xách tay và thường được sử dụng cho các cuộc gọi video. Người bị bắt
    hình ảnh được hiển thị ở chế độ ngang (chiều rộng > chiều cao) trên
    màn hình máy tính xách tay.

Máy ảnh thường được gắn lộn ngược để bù lại quang học của ống kính
    hiệu ứng đảo ngược. Trong trường hợp này giá trị của
    Điều khiển V4L2_CID_CAMERA_SENSOR_ROTATION là 0, không cần xoay để
    hiển thị hình ảnh chính xác cho người dùng.

Nếu cảm biến camera không được lắp lộn ngược thì phải bù lại
    hiệu ứng đảo ngược quang học của ống kính và giá trị của
    Điều khiển V4L2_CID_CAMERA_SENSOR_ROTATION là 180 độ, vì hình ảnh sẽ
    kết quả được xoay khi được ghi vào bộ nhớ. ::

+--------------------------------------+
                 !                                      !
                 !                                      !
                 !                                      !
                 !              __/(_____/| !
                 !            >.___ ____ ( !
                 !                 \( \| !
                 !                                      !
                 !                                      !
                 !                                      !
                 +--------------------------------------+

Phải áp dụng hiệu chỉnh xoay phần mềm 180 độ cho chính xác
    hiển thị hình ảnh trên màn hình người dùng. ::

+--------------------------------------+
                 !                                      !
                 !                                      !
                 !                                      !
                 !             |\____)\___ !
                 !             ) _____ __`< !
                 !             |/ )/ !
                 !                                      !
                 !                                      !
                 !                                      !
                 +--------------------------------------+

Ví dụ hai - Camera điện thoại

Sẽ thuận tiện hơn khi đi bơi cùng cá mập chỉ bằng điện thoại di động của bạn
    với bạn và chụp ảnh bằng camera được lắp ở mặt sau
    cạnh của thiết bị, quay mặt ra xa người dùng. Những hình ảnh được chụp có nghĩa là
    được hiển thị ở chế độ dọc (chiều cao > chiều rộng) để phù hợp với màn hình thiết bị
    hướng và hướng sử dụng thiết bị được sử dụng khi chụp ảnh.

Cảm biến máy ảnh thường được gắn với mảng pixel có cạnh dài hơn.
    căn chỉnh theo cạnh dài hơn của thiết bị, được gắn lộn ngược để bù đắp cho
    hiệu ứng đảo ngược quang học của ống kính

Các hình ảnh sau khi được chụp vào bộ nhớ sẽ được xoay và giá trị của
    V4L2_CID_CAMERA_SENSOR_ROTATION sẽ báo góc quay 90 độ. ::


+------------------------------------+
                 ZZ0000ZZ
                 ZZ0001ZZ
                 ZZ0002ZZ ZZ0003ZZ
                 ZZ0004ZZ ZZ0005ZZ
                 ZZ0006ZZ > |
                 ZZ0007ZZ |
                 ZZ0008ZZ ZZ0009ZZ
                 ZZ0010ZZ
                 ZZ0011ZZ
                 +------------------------------------+

Phải điều chỉnh 90 độ theo hướng ngược chiều kim đồng hồ
    được áp dụng để hiển thị chính xác hình ảnh ở chế độ dọc trên thiết bị
    màn hình. ::

+-------------------+
                          ZZ0000ZZ
                          ZZ0001ZZ
                          ZZ0002ZZ
                          ZZ0003ZZ
                          ZZ0004ZZ
                          ZZ0005ZZ
                          ZZ0006ZZ\____)\___ |
                          ZZ0007ZZ
                          ZZ0008ZZ/ )/ |
                          ZZ0009ZZ
                          ZZ0010ZZ
                          ZZ0011ZZ
                          ZZ0012ZZ
                          ZZ0013ZZ
                          +-------------------+


.. [#f1]
   This control may be changed to a menu control in the future, if more
   options are required.

ZZ0000ZZ
    Thay đổi chế độ HDR của cảm biến. Một hình ảnh HDR thu được bằng cách hợp nhất hai
    chụp cùng một cảnh bằng hai khoảng thời gian phơi sáng khác nhau. Chế độ HDR
    mô tả cách hợp nhất hai ảnh chụp này trong cảm biến.

Vì các chế độ khác nhau đối với mỗi cảm biến nên các mục menu không được chuẩn hóa theo tiêu chuẩn này.
    điều khiển và giao cho người lập trình.