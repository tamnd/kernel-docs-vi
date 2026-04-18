.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/event-codes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _input-event-codes:

===================
Nhập mã sự kiện
===================


Giao thức đầu vào sử dụng bản đồ các loại và mã để thể hiện giá trị thiết bị đầu vào
tới không gian người dùng. Tài liệu này mô tả các loại và mã cũng như cách thức và thời điểm chúng
có thể được sử dụng

Một sự kiện phần cứng sẽ tạo ra nhiều sự kiện đầu vào. Mỗi sự kiện đầu vào
chứa giá trị mới của một mục dữ liệu. Một loại sự kiện đặc biệt, EV_SYN, là
được sử dụng để phân tách các sự kiện đầu vào thành các gói thay đổi dữ liệu đầu vào xảy ra tại
cùng một thời điểm. Trong phần sau đây, thuật ngữ "sự kiện" đề cập đến một
sự kiện đầu vào bao gồm một loại, mã và giá trị.

Giao thức đầu vào là một giao thức có trạng thái. Các sự kiện chỉ được phát ra khi các giá trị
của mã sự kiện đã thay đổi. Tuy nhiên, trạng thái được duy trì trong Linux
hệ thống con đầu vào; người lái xe không cần phải duy trì trạng thái và có thể cố gắng
phát ra các giá trị không thay đổi mà không gây hại. Không gian người dùng có thể có được trạng thái hiện tại của
các giá trị mã sự kiện bằng cách sử dụng EVIOCG* ioctls được xác định trong linux/input.h. Sự kiện
các báo cáo được thiết bị hỗ trợ cũng được cung cấp bởi sysfs trong
lớp/đầu vào/sự kiện*/thiết bị/khả năng/ và các thuộc tính của thiết bị là
được cung cấp trong lớp/đầu vào/sự kiện*/thiết bị/thuộc tính.

Các loại sự kiện
================

Các loại sự kiện là các nhóm mã theo cấu trúc đầu vào logic. Mỗi
type có một bộ mã áp dụng được sử dụng để tạo sự kiện. Xem
Phần Codes để biết chi tiết về các mã hợp lệ cho từng loại.

*EV_SYN:

- Dùng làm điểm đánh dấu để phân biệt các sự kiện. Các sự kiện có thể được phân tách theo thời gian hoặc theo
    không gian, chẳng hạn như với giao thức cảm ứng đa điểm.

*EV_KEY:

- Dùng để mô tả sự thay đổi trạng thái của bàn phím, nút bấm hoặc các phím tương tự khác
    thiết bị.

*EV_REL:

- Được sử dụng để mô tả sự thay đổi giá trị trục tương đối, ví dụ: di chuyển chuột 5 đơn vị
    sang trái.

*EV_ABS:

- Được sử dụng để mô tả những thay đổi giá trị trục tuyệt đối, ví dụ: mô tả
    tọa độ của một cú chạm trên màn hình cảm ứng.

*EV_MSC:

- Dùng để mô tả những dữ liệu đầu vào linh tinh không khớp với các loại khác.

*EV_SW:

- Dùng để mô tả các chuyển mạch đầu vào ở trạng thái nhị phân.

*EV_LED:

- Dùng để bật tắt đèn LED trên các thiết bị.

*EV_SND:

- Dùng để xuất âm thanh ra các thiết bị.

*EV_REP:

- Được sử dụng cho các thiết bị tự động lặp lại.

*EV_FF:

- Dùng để gửi lệnh phản hồi lực tới thiết bị đầu vào.

*EV_PWR:

- Loại đặc biệt dành cho nút nguồn và công tắc đầu vào.

*EV_FF_STATUS:

- Dùng để nhận trạng thái thiết bị phản hồi lực.

Mã sự kiện
===========

Mã sự kiện xác định loại sự kiện chính xác.

EV_SYN
------

Giá trị sự kiện EV_SYN không được xác định. Việc sử dụng chúng chỉ được xác định khi chúng
được gửi trong luồng sự kiện evdev.

*SYN_REPORT:

- Dùng để đồng bộ và tách các sự kiện thành các gói dữ liệu đầu vào thay đổi
    xảy ra tại cùng một thời điểm. Ví dụ: chuyển động của chuột có thể đặt
    các giá trị REL_X và REL_Y cho một chuyển động, sau đó phát ra SYN_REPORT. Tiếp theo
    chuyển động sẽ phát ra nhiều giá trị REL_X và REL_Y hơn và gửi một SYN_REPORT khác.

*SYN_CONFIG:

-TBD

*SYN_MT_REPORT:

- Dùng để đồng bộ và tách biệt các sự kiện chạm. Xem
    tài liệu multi-touch-protocol.txt để biết thêm thông tin.

*SYN_DROPPED:

- Được sử dụng để biểu thị lỗi tràn bộ đệm trong hàng đợi sự kiện của máy khách evdev.
    Khách hàng nên bỏ qua tất cả các sự kiện cho đến và bao gồm cả SYN_REPORT tiếp theo
    sự kiện và truy vấn thiết bị (sử dụng EVIOCG* ioctls) để lấy thông tin
    trạng thái hiện tại.

EV_KEY
------

Các sự kiện EV_KEY có dạng KEY_<name> hoặc BTN_<name>. Ví dụ: KEY_A được sử dụng
để đại diện cho phím 'A' trên bàn phím. Khi một phím được ấn xuống, một sự kiện xảy ra với
mã của khóa được phát ra với giá trị 1. Khi khóa được giải phóng, một sự kiện sẽ xảy ra
được phát ra với giá trị 0. Một số phần cứng gửi sự kiện khi một phím được lặp lại. Những cái này
sự kiện có giá trị là 2. Nói chung, KEY_<name> được sử dụng cho các phím trên bàn phím và
BTN_<name> được sử dụng cho các loại sự kiện chuyển đổi tạm thời khác.

Một vài mã EV_KEY có ý nghĩa đặc biệt:

* BTN_TOOL_<tên>:

- Các mã này được sử dụng cùng với bàn di chuột đầu vào, máy tính bảng và
    màn hình cảm ứng. Các thiết bị này có thể được sử dụng bằng ngón tay, bút hoặc các công cụ khác.
    Khi một sự kiện xảy ra và một công cụ được sử dụng, BTN_TOOL_<name> tương ứng
    mã phải được đặt thành giá trị 1. Khi công cụ không còn tương tác nữa
    với thiết bị đầu vào, mã BTN_TOOL_<name> phải được đặt lại về 0. Tất cả
    bàn di chuột, máy tính bảng và màn hình cảm ứng nên sử dụng ít nhất một BTN_TOOL_<name>
    mã khi các sự kiện được tạo ra. Tương tự như vậy, tất cả bàn di chuột, máy tính bảng và
    màn hình cảm ứng chỉ được xuất một BTN_TOOL_<name> mỗi lần. Để không bị vỡ
    không gian người dùng hiện tại, bạn không nên chuyển đổi công cụ trong một khung EV_SYN
    nhưng trước tiên phát ra BTN_TOOL_<name> cũ ở mức 0, sau đó phát ra một SYN_REPORT
    và sau đó đặt BTN_TOOL_<name> mới ở mức 1.

*BTN_TOUCH:

BTN_TOUCH được sử dụng để liên lạc bằng cảm ứng. Trong khi một công cụ đầu vào được xác định là
    trong phạm vi tiếp xúc vật lý có ý nghĩa, giá trị của thuộc tính này phải được đặt
    1. Sự tiếp xúc vật lý có ý nghĩa có thể có nghĩa là bất kỳ sự tiếp xúc nào, hoặc có thể có nghĩa là
    liên hệ được điều chỉnh bởi một thuộc tính được xác định thực hiện. Ví dụ, một
    bàn di chuột chỉ có thể đặt giá trị thành 1 khi áp lực chạm tăng lên trên mức
    giá trị nhất định. BTN_TOUCH có thể được kết hợp với mã BTN_TOOL_<name>. cho
    Ví dụ: một máy tính bảng dạng bút có thể đặt BTN_TOOL_PEN thành 1 và BTN_TOUCH thành 0 trong khi
    bút lơ lửng nhưng không chạm vào bề mặt máy tính bảng.

Lưu ý: Để có chức năng phù hợp của trình điều khiển mô phỏng mousedev cũ,
BTN_TOUCH phải là mã evdev đầu tiên được phát ra trong khung đồng bộ hóa.

Lưu ý: Về mặt lịch sử, thiết bị cảm ứng có BTN_TOOL_FINGER và BTN_TOUCH là
được hiểu là một bàn di chuột theo không gian người dùng, trong khi một thiết bị tương tự không có
BTN_TOOL_FINGER được hiểu là màn hình cảm ứng. Để tương thích ngược
với không gian người dùng hiện tại, bạn nên tuân theo sự phân biệt này. trong
trong tương lai, sự khác biệt này sẽ không còn được dùng nữa và các thuộc tính của thiết bị ioctl
EVIOCGPROP, được xác định trong linux/input.h, sẽ được sử dụng để truyền tải loại thiết bị.

*BTN_TOOL_FINGER, BTN_TOOL_DOUBLETAP, BTN_TOOL_TRIPLETAP, BTN_TOOL_QUADTAP:

- Các mã này biểu thị sự tương tác một, hai, ba và bốn ngón tay trên một
    trackpad hoặc màn hình cảm ứng. Ví dụ: nếu người dùng sử dụng hai ngón tay và di chuyển
    chúng trên bàn di chuột nhằm cố gắng cuộn nội dung trên màn hình,
    BTN_TOOL_DOUBLETAP phải được đặt thành giá trị 1 trong suốt thời gian chuyển động.
    Lưu ý rằng tất cả các mã BTN_TOOL_<name> và mã BTN_TOUCH đều trực giao trong
    mục đích. Sự kiện trên bàn di chuột được tạo bằng cách chạm ngón tay sẽ tạo ra sự kiện
    cho một mã từ mỗi nhóm. Nhiều nhất chỉ một trong số BTN_TOOL_<name> này
    mã phải có giá trị 1 trong bất kỳ khung đồng bộ hóa nào.

Lưu ý: Trước đây, một số trình điều khiển đã phát ra nhiều mã đếm ngón tay cùng với
giá trị 1 trong cùng một khung đồng bộ. Việc sử dụng này không được dùng nữa.

Lưu ý: Trong trình điều khiển cảm ứng đa điểm, hàm input_mt_report_finger_count() sẽ
được sử dụng để phát ra các mã này. Vui lòng xem multi-touch-protocol.txt để biết chi tiết.

EV_REL
------

Sự kiện EV_REL mô tả những thay đổi tương đối trong một thuộc tính. Ví dụ, một con chuột có thể
sang trái một số đơn vị nhất định nhưng vị trí tuyệt đối của nó trong
không gian chưa được biết. Nếu biết vị trí tuyệt đối, nên sử dụng mã EV_ABS
thay vì mã EV_REL.

Một vài mã EV_REL có ý nghĩa đặc biệt:

* REL_WHEEL, REL_HWHEEL:

- Các mã này dùng cho bánh xe cuộn dọc và ngang,
    tương ứng. Giá trị là số lượng chốt di chuyển trên bánh xe,
    kích thước vật lý thay đổi tùy theo thiết bị. Dành cho bánh xe có độ phân giải cao
    đây có thể là giá trị gần đúng dựa trên các sự kiện cuộn có độ phân giải cao,
    xem REL_WHEEL_HI_RES. Các mã sự kiện này là mã kế thừa và
    REL_WHEEL_HI_RES và REL_HWHEEL_HI_RES nên được ưu tiên ở những nơi
    có sẵn.

* REL_WHEEL_HI_RES, REL_HWHEEL_HI_RES:

- Dữ liệu bánh xe cuộn có độ phân giải cao. Giá trị tích lũy 120 đại diện cho
    chuyển động bằng một chốt chặn. Đối với các thiết bị không cung cấp độ phân giải cao
    cuộn, giá trị luôn là bội số của 120. Đối với các thiết bị có
    cuộn có độ phân giải cao, giá trị có thể là một phần của 120.

Nếu con lăn dọc hỗ trợ cuộn có độ phân giải cao, mã này
    sẽ được phát ra ngoài REL_WHEEL hoặc REL_HWHEEL. REL_WHEEL
    và REL_HWHEEL có thể là giá trị gần đúng dựa trên độ phân giải cao
    sự kiện cuộn. Không có gì đảm bảo rằng dữ liệu có độ phân giải cao
    là bội số của 120 tại thời điểm REL_WHEEL hoặc REL_HWHEEL được mô phỏng
    sự kiện.

EV_ABS
------

Sự kiện EV_ABS mô tả những thay đổi tuyệt đối trong một thuộc tính. Ví dụ: bàn di chuột
có thể phát ra tọa độ cho một vị trí cảm ứng.

Một vài mã EV_ABS có ý nghĩa đặc biệt:

*ABS_DISTANCE:

- Dùng để mô tả khoảng cách từ một dụng cụ đến một bề mặt tương tác. Cái này
    sự kiện chỉ nên được phát ra khi công cụ đang di chuyển, nghĩa là ở gần
    khoảng cách của thiết bị và trong khi giá trị của mã BTN_TOUCH là 0. Nếu
    thiết bị đầu vào có thể được sử dụng tự do trong không gian ba chiều, hãy xem xét ABS_Z
    thay vào đó.
  - BTN_TOOL_<name> phải được đặt thành 1 khi công cụ ở trạng thái có thể phát hiện được
    độ gần và được đặt thành 0 khi công cụ rời khỏi vùng lân cận có thể phát hiện được.
    BTN_TOOL_<name> báo hiệu loại dao hiện được phát hiện bởi
    phần cứng và độc lập với ABS_DISTANCE và/hoặc BTN_TOUCH.

*ABS_PROFILE:

- Dùng để mô tả trạng thái của một switch profile đa giá trị.  Một sự kiện là
    chỉ phát ra khi cấu hình đã chọn thay đổi, cho biết cấu hình mới
    giá trị hồ sơ đã chọn.

*ABS_SND_PROFILE:

- Dùng để mô tả trạng thái của chuyển đổi cấu hình âm thanh đa giá trị.
    Một sự kiện chỉ được phát ra khi cấu hình đã chọn thay đổi,
    cho biết giá trị hồ sơ mới được chọn.

* ABS_MT_<tên>:

- Được sử dụng để mô tả các sự kiện nhập liệu bằng cảm ứng đa điểm. Xin vui lòng xem
    multi-touch-protocol.txt để biết chi tiết.

*ABS_PRESSURE/ABS_MT_PRESSURE:

- Đối với thiết bị cảm ứng, nhiều thiết bị đã chuyển đổi kích thước tiếp xúc thành áp suất.
     Một ngón tay bị xẹp xuống khi có áp lực, gây ra diện tích tiếp xúc lớn hơn và do đó
     áp suất và kích thước tiếp xúc có liên quan trực tiếp. Đây không phải là trường hợp
     đối với các thiết bị khác, ví dụ như bộ số hóa và bàn di chuột có chân thực
     cảm biến áp suất ("miếng đệm áp suất").

Thiết bị phải đặt độ phân giải của trục để cho biết liệu
     áp suất được tính bằng đơn vị đo được. Nếu độ phân giải bằng 0,
     dữ liệu áp suất được tính theo đơn vị tùy ý. Nếu độ phân giải khác 0,
     dữ liệu áp suất được tính bằng đơn vị/gram. Ví dụ: giá trị 10 với
     độ phân giải 1 đại diện cho 10 gam, giá trị 10 với độ phân giải là
     1000 đại diện cho 10 microgam.

EV_SW
-----

Các sự kiện EV_SW mô tả các chuyển mạch nhị phân có trạng thái. Ví dụ: mã SW_LID là
được sử dụng để biểu thị khi nắp máy tính xách tay được đóng lại.

Khi liên kết với một thiết bị hoặc tiếp tục tạm dừng, người lái xe phải báo cáo
trạng thái chuyển đổi hiện tại. Điều này đảm bảo rằng thiết bị, kernel và không gian người dùng
trạng thái được đồng bộ hóa.

Khi tiếp tục, nếu trạng thái chuyển đổi giống như trước khi tạm dừng thì đầu vào
hệ thống con sẽ lọc ra các báo cáo trạng thái chuyển đổi trùng lặp. Người lái xe làm
không cần phải giữ trạng thái của switch bất cứ lúc nào.

EV_MSC
------

Các sự kiện EV_MSC được sử dụng cho các sự kiện đầu vào và đầu ra không thuộc các sự kiện khác
các hạng mục.

Một vài mã EV_MSC có ý nghĩa đặc biệt:

*MSC_TIMESTAMP:

- Dùng để báo số micro giây kể từ lần reset gần nhất. Sự kiện này
    phải được mã hóa dưới dạng giá trị uint32, được phép bao quanh bằng
    không có hậu quả đặc biệt. Người ta cho rằng sự khác biệt về thời gian giữa hai
    các sự kiện liên tiếp là đáng tin cậy trên thang thời gian hợp lý (giờ).
    Việc đặt lại về 0 có thể xảy ra, trong trường hợp đó thời gian kể từ sự kiện cuối cùng là
    không rõ.  Nếu thiết bị không cung cấp thông tin này, người lái xe phải
    không cung cấp nó cho không gian người dùng.

EV_LED
------

Các sự kiện EV_LED được sử dụng cho đầu vào và đầu ra để thiết lập và truy vấn trạng thái của
đèn LED khác nhau trên các thiết bị.

EV_REP
------

Các sự kiện EV_REP được sử dụng để chỉ định các sự kiện tự động lặp lại.

EV_SND
------

Sự kiện EV_SND được sử dụng để gửi lệnh âm thanh đến đầu ra âm thanh đơn giản
thiết bị.

EV_FF
-----

Các sự kiện EV_FF được sử dụng để khởi tạo một thiết bị có khả năng phản hồi lực và gây ra
thiết bị như vậy để phản hồi.

EV_PWR
------

Sự kiện EV_PWR là một loại sự kiện đặc biệt được sử dụng riêng cho quyền lực
quản lý. Cách sử dụng của nó không được xác định rõ ràng. Sẽ được giải quyết sau.

Thuộc tính thiết bị
===================

Thông thường, không gian người dùng thiết lập một thiết bị đầu vào dựa trên dữ liệu mà nó phát ra,
tức là các loại sự kiện. Trong trường hợp hai thiết bị phát ra cùng một sự kiện
loại, thông tin bổ sung có thể được cung cấp dưới dạng thiết bị
tài sản.

INPUT_PROP_DIRECT + INPUT_PROP_POINTER
--------------------------------------

Thuộc tính INPUT_PROP_DIRECT cho biết tọa độ thiết bị phải là
ánh xạ trực tiếp tới tọa độ màn hình (không tính đến các tọa độ tầm thường
các phép biến đổi, chẳng hạn như chia tỷ lệ, lật và xoay). Đầu vào không trực tiếp
các thiết bị yêu cầu chuyển đổi không tầm thường, chẳng hạn như chuyển đổi tuyệt đối sang tương đối
chuyển đổi cho bàn di chuột. Các thiết bị nhập trực tiếp điển hình: màn hình cảm ứng,
máy tính bảng vẽ; thiết bị không trực tiếp: bàn di chuột, chuột.

Thuộc tính INPUT_PROP_POINTER cho biết thiết bị không được chuyển đổi
trên màn hình và do đó yêu cầu sử dụng con trỏ trên màn hình để theo dõi người dùng
các phong trào.  Các thiết bị con trỏ điển hình: bàn di chuột, máy tính bảng, chuột; không phải con trỏ
thiết bị: màn hình cảm ứng.

Nếu cả INPUT_PROP_DIRECT hoặc INPUT_PROP_POINTER đều không được đặt thì thuộc tính sẽ là
được coi là không xác định và loại thiết bị phải được suy ra trong
theo cách truyền thống, sử dụng các loại sự kiện được phát ra.

INPUT_PROP_BUTTONPAD
--------------------

Đối với bàn di chuột có nút được đặt bên dưới bề mặt, sao cho
nhấn xuống bảng sẽ gây ra nhấp chuột vào nút, thuộc tính này sẽ là
thiết lập. Phổ biến ở notebook Clickpad và Macbook từ năm 2009 trở đi.

Ban đầu, thuộc tính nút bấm được mã hóa vào trình điều khiển bcm5974
trường phiên bản dưới nút tích hợp tên. Để ngược lại
khả năng tương thích, cả hai phương pháp đều cần được kiểm tra trong không gian người dùng.

INPUT_PROP_SEMI_MT
------------------

Một số bàn di chuột, phổ biến nhất từ năm 2008 đến năm 2011, có thể phát hiện sự hiện diện
của nhiều liên hệ mà không giải quyết được các vị trí riêng lẻ; chỉ có
số lượng địa chỉ liên lạc và một hình chữ nhật được biết đến. Đối với như vậy
bàn di chuột, thuộc tính SEMI_MT phải được đặt.

Tùy thuộc vào thiết bị, hình chữ nhật có thể bao gồm tất cả các điểm chạm, giống như một
hộp giới hạn hoặc chỉ một số trong số chúng, ví dụ như hai hộp gần đây nhất
chạm vào. Sự đa dạng làm cho hình chữ nhật được sử dụng hạn chế, nhưng một số
cử chỉ thường có thể được trích xuất từ ​​nó.

Nếu INPUT_PROP_SEMI_MT không được đặt, thiết bị được coi là MT thực sự
thiết bị.

INPUT_PROP_TOPBUTTONPAD
-----------------------

Một số máy tính xách tay, đáng chú ý nhất là dòng Lenovo 40 có cung cấp trackstick
thiết bị nhưng không có nút vật lý liên kết với trackstick
thiết bị. Thay vào đó, khu vực trên cùng của bàn di chuột được đánh dấu để hiển thị
khu vực trực quan/xúc giác cho các nút trái, giữa, phải dự định sử dụng
bằng trackstick.

Nếu INPUT_PROP_TOPBUTTONPAD được đặt, không gian người dùng sẽ mô phỏng các nút
tương ứng. Thuộc tính này không ảnh hưởng đến hành vi của kernel.
Hạt nhân không cung cấp mô phỏng nút cho các thiết bị như vậy nhưng xử lý
chúng như mọi thiết bị INPUT_PROP_BUTTONPAD khác.

INPUT_PROP_ACCELEROMETER
------------------------

Các trục định hướng trên thiết bị này (tuyệt đối và/hoặc tương đối x, y, z) biểu thị
dữ liệu gia tốc kế. Một số thiết bị còn báo cáo dữ liệu con quay hồi chuyển, thiết bị nào
có thể báo cáo thông qua các trục quay (rx tuyệt đối và/hoặc tương đối rx, ry, rz).

Tất cả các trục khác vẫn giữ nguyên ý nghĩa của chúng. Một thiết bị không được trộn lẫn
trục định hướng thông thường và trục gia tốc trên cùng một nút sự kiện.

INPUT_PROP_PRESSUREPAD
----------------------

Thuộc tính INPUT_PROP_PRESSUREPAD cho biết thiết bị cung cấp
phản hồi xúc giác mô phỏng (ví dụ: động cơ rung nằm bên dưới bề mặt)
thay vì phản hồi xúc giác vật lý (ví dụ: bản lề). Thuộc tính này chỉ được thiết lập
nếu thiết bị:

- Có thể phân biệt được ít nhất 5 ngón tay
- sử dụng độ phân giải chính xác cho X/Y (đơn vị và giá trị)
- tuân theo giao thức MT loại B

Nếu không gian người dùng có thể kiểm soát phản hồi xúc giác mô phỏng thì thiết bị phải:

- hỗ trợ kích hoạt thủ công và tự động xúc giác đơn giản, và
- báo cáo lực chính xác trên mỗi lần chạm và sửa đơn vị cho chúng (newton hoặc gam) và
- cung cấp hiệu ứng phản hồi lực EV_FF FF_HAPTIC.

Tóm lại, các thiết bị như vậy tuân theo thông số kỹ thuật MS dành cho thiết bị đầu vào trong
Win8 và Win8.1, ngoài ra có thể hỗ trợ bộ điều khiển xúc giác đơn giản HID
bảng và báo cáo đơn vị chính xác của áp suất.

Nếu có thể, thuộc tính này được đặt ngoài INPUT_PROP_BUTTONPAD, nó
không thay thế thuộc tính đó.

Hướng dẫn
==========

Các nguyên tắc bên dưới đảm bảo chức năng chạm một lần và nhiều ngón tay thích hợp.
Để biết chức năng cảm ứng đa điểm, hãy xem tài liệu multi-touch-protocol.rst để biết
thêm thông tin.

Chuột
-----

REL_{X,Y} phải được báo cáo khi chuột di chuyển. BTN_LEFT phải được sử dụng để báo cáo
nhấn nút chính. BTN_{MIDDLE,RIGHT,4,5,etc.} nên được sử dụng để báo cáo
các nút khác của thiết bị. Nên sử dụng REL_WHEEL và REL_HWHEEL để báo cáo
sự kiện bánh xe cuộn nếu có.

Màn hình cảm ứng
----------------

ABS_{X,Y} phải được báo cáo cùng với vị trí của cảm ứng. BTN_TOUCH phải
được sử dụng để báo cáo khi một thao tác chạm được kích hoạt trên màn hình.
BTN_{MOUSE,LEFT,MIDDLE,RIGHT} không được báo cáo do thao tác chạm
liên hệ. Các sự kiện BTN_TOOL_<name> nên được báo cáo nếu có thể.

Đối với phần cứng mới, nên đặt INPUT_PROP_DIRECT.

Bàn di chuột
------------

Bàn di chuột cũ chỉ cung cấp thông tin vị trí tương đối phải báo cáo
các sự kiện như chuột được mô tả ở trên.

Bàn di chuột cung cấp vị trí cảm ứng tuyệt đối phải báo cáo ABS_{X,Y} cho
vị trí của cảm ứng. BTN_TOUCH nên được sử dụng để báo cáo khi một thao tác chạm được kích hoạt
trên bàn di chuột. Khi có hỗ trợ nhiều ngón tay, BTN_TOOL_<name> sẽ
được sử dụng để báo cáo số lần chạm hoạt động trên bàn di chuột.

Đối với phần cứng mới, nên đặt INPUT_PROP_POINTER.

Máy tính bảng
-------------

Các sự kiện BTN_TOOL_<name> phải được báo cáo khi bút cảm ứng hoặc công cụ khác đang hoạt động trên
máy tính bảng. ABS_{X,Y} phải được báo cáo cùng với vị trí của dao. BTN_TOUCH
nên được sử dụng để báo cáo khi dụng cụ tiếp xúc với máy tính bảng.
Nên sử dụng BTN_{STYLUS,STYLUS2} để báo cáo các nút trên chính công cụ đó. bất kỳ
nút có thể được sử dụng cho các nút trên máy tính bảng ngoại trừ BTN_{MOUSE,LEFT}.
BTN_{0,1,2,etc} là các mã chung tốt cho các nút không được gắn nhãn. không sử dụng
các nút có ý nghĩa, như BTN_FORWARD, trừ khi nút đó được gắn nhãn cho nút đó
mục đích trên thiết bị.

Đối với phần cứng mới, nên đặt cả INPUT_PROP_DIRECT và INPUT_PROP_POINTER.
