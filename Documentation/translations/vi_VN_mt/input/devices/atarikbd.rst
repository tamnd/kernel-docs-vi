.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/atarikbd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Giao thức bàn phím thông minh (ikbd)
====================================


Giới thiệu
============

Bàn phím thông minh Atari Corp. (ikbd) là bàn phím đa năng
Bộ điều khiển đủ linh hoạt để có thể sử dụng được trong nhiều
sản phẩm mà không cần sửa đổi. Bàn phím, với bộ vi điều khiển của nó,
cung cấp điểm kết nối thuận tiện cho chuột và cần điều khiển loại công tắc.
Bộ xử lý ikbd cũng duy trì đồng hồ thời gian trong ngày với một giây
độ phân giải.
Ikbd đã được thiết kế đủ tổng quát để có thể sử dụng nó với một
nhiều sản phẩm máy tính mới. Các biến thể của sản phẩm ở một số
công tắc phím, độ phân giải chuột, v.v. có thể được cung cấp.
Ikbd giao tiếp với bộ xử lý chính qua đường truyền hai chiều tốc độ cao
giao diện nối tiếp. Nó có thể hoạt động ở nhiều chế độ khác nhau để tạo điều kiện thuận lợi
các ứng dụng khác nhau của bàn phím, cần điều khiển hoặc chuột. Hạn chế sử dụng
bộ điều khiển có thể thực hiện được trong các ứng dụng chỉ có một chiều
phương tiện truyền thông có sẵn bằng cách thiết kế cẩn thận các chế độ mặc định.

Bàn phím
========

Bàn phím luôn trả về mã quét tạo/ngắt phím. Ikbd tạo ra
mã quét bàn phím cho mỗi lần nhấn và thả phím. Việc quét phím thực hiện (phím
mã đóng) bắt đầu từ 1 và được xác định trong Phụ lục A. Ví dụ:
Vị trí phím ISO trong bảng mã quét phải tồn tại ngay cả khi không có công tắc phím
tồn tại ở vị trí đó trên một bàn phím cụ thể. Mã ngắt cho từng phím
thu được bằng cách ORing 0x80 với mã tạo.

Các mã đặc biệt 0xF6 đến 0xFF được dành riêng để sử dụng như sau:

=============================================================================
    Lệnh mã
=============================================================================
    Báo cáo trạng thái 0xF6
    Bản ghi vị trí chuột tuyệt đối 0xF7
    Bản ghi vị trí chuột tương đối 0xF8-0xFB (lsbs được xác định bởi
                    trạng thái nút chuột)
    0xFC thời gian trong ngày
    Báo cáo cần điều khiển 0xFD (cả hai thanh)
    Cần điều khiển 0xFE 0 sự kiện
    Cần điều khiển 0xFF 1 sự kiện
=============================================================================

Hai phím shift trả về các mã quét khác nhau ở chế độ này. Phím ENTER
và phím RETurn cũng khác biệt.

Chuột
=====

Cổng chuột phải có khả năng hỗ trợ chuột có độ phân giải
khoảng 200 lần đếm (thay đổi pha hoặc 'tiếng tách') trên mỗi inch hành trình. các
chuột phải được quét ở tốc độ cho phép theo dõi chính xác ở
vận tốc lên tới 10 inch mỗi giây.
Ikbd có thể báo cáo chuyển động của chuột theo ba cách khác nhau. Nó có thể
báo chuyển động tương đối, chuyển động tuyệt đối trong hệ tọa độ được duy trì
trong ikbd hoặc bằng cách chuyển đổi chuyển động của chuột thành điều khiển con trỏ bàn phím
tương đương quan trọng.
Các nút chuột có thể được coi là một phần của chuột hoặc là phần bổ sung
phím bàn phím.

Báo cáo vị trí tương đối
---------------------------

Ở chế độ vị trí tương đối, ikbd sẽ trả về vị trí chuột tương đối
ghi lại bất cứ khi nào một sự kiện chuột xảy ra. Một sự kiện chuột bao gồm một con chuột
nút được nhấn hoặc nhả hoặc chuyển động ở một trong hai trục vượt quá một
ngưỡng chuyển động ổn định. Bất kể ngưỡng nào, tất cả các bit của
độ phân giải được trả về máy chủ.
Lưu ý rằng ikbd có thể trả về báo cáo vị trí tương đối của chuột với
nhiều hơn đáng kể so với ngưỡng delta x hoặc y. Điều này có thể xảy ra vì không
các sự kiện chuyển động chuột tương đối sẽ được tạo ra: (a) trong khi bàn phím có
đã bị 'tạm dừng' (sự kiện sẽ được lưu trữ cho đến khi giao tiếp bàn phím được thực hiện
được tiếp tục lại) (b) trong khi bất kỳ sự kiện nào đang được truyền đi.

Bản ghi vị trí chuột tương đối là bản ghi ba byte có dạng
(bất kể chế độ bàn phím)::

%111110xy ; cờ ghi vị trí chuột
                        ; trong đó y là trạng thái nút bên phải
                        ; và x là trạng thái nút bên trái
    X ; delta x là số nguyên bù hai
    Y ; delta y là số nguyên bù hai

Lưu ý rằng giá trị của các bit trạng thái nút phải hợp lệ ngay cả khi
MOUSE BUTTON ACTION đã thiết lập các nút hoạt động giống như một phần của bàn phím.
Nếu chuyển động tích lũy trước khi gói báo cáo được tạo ra vượt quá
Phạm vi +127...-128, chuyển động được chia thành nhiều gói.
Lưu ý rằng dấu của delta y được báo cáo là hàm của gốc Y
đã chọn.

Báo cáo vị trí tuyệt đối
---------------------------

Ikbd cũng có thể duy trì vị trí chuột tuyệt đối. Các lệnh tồn tại cho
đặt lại vị trí chuột, đặt tỷ lệ X/Y và thẩm vấn
vị trí chuột hiện tại.

Chế độ phím con trỏ chuột
---------------------

Ikbd có thể dịch chuyển động của chuột thành các lần nhấn phím con trỏ tương đương.
Số lần click chuột trên mỗi lần nhấn phím được lập trình độc lập theo
mỗi trục. Ikbd duy trì nội bộ thông tin chuyển động của chuột tới
độ phân giải cao nhất hiện có và chỉ tạo ra một cặp sự kiện phím con trỏ
cho mỗi bội số của hệ số tỷ lệ.
Chuyển động của chuột tạo ra phím con trỏ tạo mã ngay sau đó là
ngắt mã cho phím con trỏ thích hợp. Các nút chuột thực hiện quét
các mã cao hơn các mã thường được gán cho bàn phím được hình dung lớn nhất (tức là
LEFT=0x74 & RIGHT=0x75).

Cần điều khiển
========

Báo cáo sự kiện cần điều khiển
------------------------

Ở chế độ này, ikbd tạo bản ghi bất cứ khi nào vị trí cần điều khiển được đặt
đã thay đổi (tức là đối với mỗi lần mở hoặc đóng công tắc cần điều khiển hoặc bộ kích hoạt).

Bản ghi sự kiện cần điều khiển là hai byte có dạng::

%1111111x ; Điểm đánh dấu sự kiện cần điều khiển
                        ; trong đó x là Joystick 0 hoặc 1
    %x000yyyy ; vị trí cây gậy ở đâu yyyy
                        ; và x là kích hoạt

Thẩm vấn cần điều khiển
----------------------

Trạng thái hiện tại của các cổng cần điều khiển có thể được kiểm tra bất kỳ lúc nào trong
chế độ này bằng cách gửi lệnh 'Điều khiển thẩm vấn' tới ikbd.

Phản hồi ikbd đối với việc thẩm vấn cần điều khiển là một báo cáo ba byte có dạng::

0xFD; tiêu đề báo cáo cần điều khiển
    %x000yyyy ; Cần điều khiển 0
    %x000yyyy ; Cần điều khiển 1
                        ; trong đó x là trình kích hoạt
                        ; và yyy là vị trí dính

Giám sát cần điều khiển
-------------------

Có sẵn một chế độ dành gần như toàn bộ giao tiếp bằng bàn phím
đã đến lúc báo cáo trạng thái của các cổng cần điều khiển theo tỷ lệ do người dùng chỉ định.
Nó vẫn ở chế độ này cho đến khi được đặt lại hoặc được lệnh chuyển sang chế độ khác. PAUSE
lệnh ở chế độ này không chỉ dừng đầu ra mà còn tạm thời dừng
quét cần điều khiển (các mẫu không được xếp hàng đợi).

Giám sát nút lửa
----------------------

Một chế độ được cung cấp để cho phép giám sát một bit đầu vào ở tốc độ cao. trong
chế độ này, ikbd giám sát trạng thái của nút bắn Joystick 1 ở
tốc độ tối đa được phép bởi kênh truyền thông nối tiếp. Dữ liệu được đóng gói
8 bit mỗi byte để truyền tới máy chủ. Ikbd vẫn ở chế độ này
cho đến khi được đặt lại hoặc được lệnh chuyển sang chế độ khác. Lệnh PAUSE ở chế độ này không
chỉ dừng đầu ra mà còn tạm thời ngừng quét nút (mẫu
không được xếp hàng đợi).

Chế độ mã phím điều khiển
----------------------

Ikbd có thể được lệnh chuyển việc sử dụng một trong hai cần điều khiển sang
(các) tổ hợp phím điều khiển con trỏ tương đương. Ikbd cung cấp một điểm dừng duy nhất
con trỏ cần điều khiển tốc độ.
Các sự kiện cần điều khiển tạo mã tạo, ngay sau đó là mã ngắt
để có các phím chuyển động con trỏ thích hợp. Các nút kích hoạt hoặc bắn của
cần điều khiển tạo mã quét phím giả phía trên mã được sử dụng bởi phím lớn nhất
ma trận được hình dung (tức là JOYSTICK0=0x74, JOYSTICK1=0x75).

Đồng hồ thời gian trong ngày
=================

Ikbd cũng duy trì đồng hồ thời gian trong ngày cho hệ thống. Các lệnh là
có sẵn để thiết lập và thẩm vấn đồng hồ hẹn giờ trong ngày. Việc giữ thời gian là
duy trì ở độ phân giải một giây.

Truy vấn trạng thái
================

Trạng thái hiện tại của các chế độ và tham số ikbd có thể được tìm thấy bằng cách gửi trạng thái
các lệnh truy vấn tương ứng với các lệnh ikbd set.

Chế độ bật nguồn
=============

Bộ điều khiển bàn phím sẽ thực hiện tự kiểm tra đơn giản khi bật nguồn để phát hiện
lỗi chính của bộ điều khiển (tổng kiểm tra ROM và kiểm tra RAM) và những thứ như bị kẹt
phím. Bất kỳ phím nào bị tắt khi bật nguồn đều được cho là bị kẹt và BREAK của chúng
(sic) được trả về (không có mã MAKE trước đó là cờ cho một
lỗi bàn phím). Nếu quá trình tự kiểm tra bộ điều khiển hoàn tất mà không có lỗi, mã
0xF0 được trả về. (Mã này sẽ được sử dụng để chỉ ra phiên bản/bản phát hành của
bộ điều khiển ikbd. Bản phát hành đầu tiên của ikbd là phiên bản 0xF0, nên
có bản phát hành thứ hai, nó sẽ là 0xF1, v.v.)
Ikbd mặc định báo cáo vị trí chuột với ngưỡng 1 đơn vị trong
trục và gốc Y=0 ở đầu màn hình và sự kiện cần điều khiển
chế độ báo cáo cho phím điều khiển 1, với cả hai nút được gán hợp lý cho
con chuột. Sau bất kỳ lệnh cần điều khiển nào, ikbd giả định rằng cần điều khiển đã được
được kết nối với cả Joystick0 và Joystick1. Bất kỳ lệnh chuột nào (ngoại trừ MOUSE
DISABLE) sau đó khiến cổng 0 được quét lại như thể nó là một con chuột và
cả hai nút đều được kết nối hợp lý với nó. Nếu lệnh vô hiệu hóa chuột là
nhận được trong khi cổng 0 được coi là chuột, nút này hợp lý
được gán cho Joystick1 (cho đến khi chuột được kích hoạt lại bằng lệnh chuột khác).

Bộ lệnh ikbd
================

Phần này chứa danh sách các lệnh có thể được gửi tới ikbd. Lệnh
các mã (chẳng hạn như 0x00) không được chỉ định sẽ không thực hiện thao tác nào
(NOP).

RESET
-----

::

0x80
    0x01

N.B. Lệnh RESET là lệnh hai byte duy nhất được ikbd hiểu.
Bất kỳ byte nào theo sau byte lệnh 0x80 khác 0x01 đều bị bỏ qua (và khiến
0x80 sẽ bị bỏ qua).
Việc thiết lập lại cũng có thể được gây ra bằng cách gửi thời gian nghỉ kéo dài ít nhất 200mS tới
ikbd.
Thực hiện lệnh RESET sẽ đưa bàn phím về mặc định (bật nguồn)
cài đặt chế độ và tham số. Nó không ảnh hưởng đến đồng hồ thời gian trong ngày.
Lệnh hoặc chức năng RESET khiến ikbd thực hiện tự kiểm tra đơn giản.
Nếu thử nghiệm thành công, ikbd sẽ gửi mã 0xF0 trong vòng 300mS
khi nhận được lệnh RESET (hoặc kết thúc thời gian nghỉ hoặc bật nguồn). các
ikbd sau đó sẽ quét ma trận khóa để tìm bất kỳ phím nào bị kẹt (đã đóng). Bất kỳ chìa khóa nào được tìm thấy
đóng sẽ khiến mã quét ngắt được tạo ra (mã ngắt đến
không có mã tạo trước là cờ cho lỗi ma trận khóa).

SET MOUSE BUTTON ACTION
-----------------------

::

0x07
    %00000ms; hành động của nút chuột
                        ;       (m được coi là = 1 khi ở chế độ MOUSE KEYCODE)
                        ; mss=0xy, nhấn hoặc thả nút chuột sẽ khiến chuột
                        ;  báo cáo vị trí
                        ;  trong đó y=1, nhấn phím chuột sẽ tạo ra báo cáo tuyệt đối
                        ;  và x=1, nhả phím chuột gây ra báo cáo tuyệt đối
                        ; mss=100, nút chuột hoạt động giống như phím

Lệnh này đặt ra cách ikbd xử lý các nút trên chuột. các
chế độ hành động của nút chuột mặc định là %00000000, các nút được coi là một phần
của chuột một cách logic.
Khi các nút hoạt động giống như phím, LEFT=0x74 & RIGHT=0x75.

SET RELATIVE MOUSE POSITION REPORTING
-------------------------------------

::

0x08

Đặt báo cáo vị trí chuột tương đối. (DEFAULT) Các gói vị trí chuột được
được tạo ra không đồng bộ bởi ikbd bất cứ khi nào chuyển động vượt quá giá trị có thể cài đặt
ngưỡng ở một trong hai trục (xem SET MOUSE THRESHOLD). Tùy theo con chuột
chế độ phím, báo cáo vị trí chuột cũng có thể được tạo khi một trong hai con chuột
nút được nhấn hoặc thả ra. Nếu không thì các nút chuột hoạt động như thể chúng
là các phím bàn phím.

SET ABSOLUTE MOUSE POSITIONING
------------------------------

::

0x09
    XMSB ; X tối đa (trong số lần nhấp chuột được chia tỷ lệ)
    XLSB
    YMSB ; Y tối đa (trong số lần nhấp chuột được chia tỷ lệ)
    YLSB

Đặt bảo trì vị trí chuột tuyệt đối. Đặt lại ikbd duy trì X và Y
tọa độ.
Trong chế độ này, giá trị của tọa độ được duy trì bên trong sẽ bao bọc NOT
giữa 0 và số dương lớn. Chuyển động dư thừa dưới 0 sẽ bị bỏ qua. các
lệnh đặt giá trị dương tối đa có thể đạt được trong tỷ lệ
hệ tọa độ. Chuyển động vượt quá giá trị đó cũng bị bỏ qua.

SET MOUSE KEYCODE MODE
----------------------

::

0x0A
    deltax ; khoảng cách tính bằng X lần nhấp để quay lại (LEFT) hoặc (RIGHT)
    đồng bằng ; khoảng cách trong Y lần nhấp để quay lại (UP) hoặc (DOWN)

Đặt thói quen giám sát chuột để trả về mã phím chuyển động của con trỏ thay vì
bản ghi chuyển động RELATIVE hoặc ABSOLUTE. Ikbd trả về giá trị thích hợp
mã khóa con trỏ sau khi di chuyển chuột vượt quá vùng delta do người dùng chỉ định trong
một trong hai trục. Khi bàn phím ở chế độ quét mã phím, chuyển động của chuột sẽ
khiến mã tạo ngay sau đó là mã ngắt. Lưu ý rằng điều này
lệnh không bị ảnh hưởng bởi nguồn gốc chuyển động của chuột.

SET MOUSE THRESHOLD
-------------------

::

0x0B
    X ; ngưỡng x trong số lần đánh chuột (số nguyên dương)
    Y ; ngưỡng y trong tích tắc chuột (số nguyên dương)

Lệnh này đặt ngưỡng trước khi sự kiện chuột được tạo. Lưu ý rằng
NOT ảnh hưởng đến độ phân giải của dữ liệu được trả về máy chủ. Cái này
lệnh chỉ hợp lệ ở chế độ RELATIVE MOUSE POSITIONING. Các ngưỡng
mặc định là 1 tại RESET (hoặc bật nguồn).

SET MOUSE SCALE
---------------

::

0x0C
    X ; tích tắc chuột ngang trên mỗi X bên trong
    Y ; tích tắc chuột dọc trên mỗi Y bên trong

Lệnh này đặt hệ số tỷ lệ cho chế độ ABSOLUTE MOUSE POSITIONING.
Trong chế độ này, số lần thay đổi pha chuột được chỉ định ('lần nhấp chuột') phải
xảy ra trước khi tọa độ được duy trì bên trong bị thay đổi bởi một
(được chia tỷ lệ độc lập cho từng trục). Hãy nhớ rằng vị trí chuột
thông tin chỉ có sẵn bằng cách thẩm vấn ikbd trong ABSOLUTE MOUSE
Chế độ POSITIONING trừ khi ikbd được lệnh báo cáo về việc nhấn nút
hoặc phát hành (xem SET MOUSE BUTTON ACTION).

INTERROGATE MOUSE POSITION
--------------------------

::

0x0D
    Trả về:
            0xF7; tiêu đề vị trí chuột tuyệt đối
    BUTTONS
            0000dcba; nơi a là nút bên phải kể từ lần thẩm vấn cuối cùng
                       ; b là nút bên phải lên kể từ lần cuối
                       ; c là nút trái ở dưới kể từ lần cuối
                       ; d là nút bên trái lên kể từ lần cuối
            XMSB ; Tọa độ X
            XLSB
            YMSB ; Tọa độ Y
            YLSB

Lệnh INTERROGATE MOUSE POSITION hợp lệ khi ở trong ABSOLUTE MOUSE
Chế độ POSITIONING, bất kể cài đặt của MOUSE BUTTON ACTION.

LOAD MOUSE POSITION
-------------------

::

0x0E
    0x00; phụ
    XMSB ; Tọa độ X
    XLSB ; (trong hệ tọa độ tỷ lệ)
    YMSB ; Tọa độ Y
    YLSB

Lệnh này cho phép người dùng đặt trước giá trị tuyệt đối được duy trì nội bộ
vị trí chuột.

SET Y=0 TẠI BOTTOM
-----------------

::

0x0F

Lệnh này làm cho gốc của trục Y nằm ở đáy của
hệ tọa độ logic bên trong ikbd cho tất cả các giá trị tương đối hoặc tuyệt đối
chuyển động của chuột. Điều này làm cho chuyển động của chuột về phía người dùng mang dấu âm
và tránh xa người dùng để trở nên tích cực.

SET Y=0 TẠI TOP
--------------

::

0x10

Làm cho gốc của trục Y ở trên cùng của tọa độ logic
hệ thống trong ikbd cho tất cả chuyển động chuột tương đối hoặc tuyệt đối. (DEFAULT)
Điều này làm cho chuyển động của chuột về phía người dùng có dấu dương và tránh xa
người dùng trở nên tiêu cực.

RESUME
------

::

0x11

Tiếp tục gửi dữ liệu đến máy chủ. Vì bất kỳ lệnh nào được ikbd nhận sau
đầu ra của nó đã bị tạm dừng cũng gây ra RESUME tiềm ẩn, lệnh này có thể
được coi là lệnh NO OPERATION. Nếu lệnh này được ikbd nhận
và nó không phải là PAUSED, nó chỉ đơn giản là bị bỏ qua.

DISABLE MOUSE
-------------

::

0x12

Tất cả báo cáo sự kiện chuột đều bị tắt (và quá trình quét có thể được thực hiện nội bộ
bị vô hiệu hóa). Bất kỳ lệnh chế độ chuột hợp lệ nào sẽ tiếp tục theo dõi chuyển động của chuột. (Các
các lệnh chế độ chuột hợp lệ là SET RELATIVE MOUSE POSITION REPORTING, SET
ABSOLUTE MOUSE POSITIONING và SET MOUSE KEYCODE MODE. )
N.B. Nếu các nút chuột được lệnh hoạt động giống như các phím trên bàn phím thì điều này
lệnh DOES ảnh hưởng đến hành động của họ.

PAUSE OUTPUT
------------

::

0x13

Dừng gửi dữ liệu đến máy chủ cho đến khi nhận được lệnh hợp lệ khác. Chìa khóa
hoạt động của ma trận vẫn được theo dõi và quét mã hoặc ký tự ASCII được xếp hàng đợi
(tối đa được hỗ trợ bởi bộ vi điều khiển) sẽ được gửi khi máy chủ
cho phép đầu ra được tiếp tục. Nếu ở chế độ JOYSTICK EVENT REPORTING,
các sự kiện cần điều khiển cũng được xếp hàng đợi.
Chuyển động của chuột phải được tích lũy trong khi đầu ra bị tạm dừng. Nếu ikbd là
ở chế độ RELATIVE MOUSE POSITIONING REPORTING, chuyển động được tích lũy vượt quá
giới hạn ngưỡng thông thường để tạo ra số lượng gói tối thiểu cần thiết cho
truyền khi đầu ra được nối lại. Nhấn hoặc thả một trong hai nút chuột
khiến cho bất kỳ chuyển động tích lũy nào được xếp ngay lập tức dưới dạng gói tin, nếu
chuột đang ở chế độ RELATIVE MOUSE POSITION REPORTING.
Do những hạn chế của bộ nhớ vi điều khiển, lệnh này sẽ
được sử dụng một cách tiết kiệm và không nên tắt đầu ra quá <tbd>
mili giây mỗi lần.
Đầu ra chỉ dừng ở cuối 'chẵn' hiện tại. Nếu PAUSE
Lệnh OUTPUT được nhận ở giữa báo cáo nhiều byte, gói
vẫn sẽ được chuyển đến kết luận và sau đó PAUSE sẽ có hiệu lực.
Khi ikbd ở chế độ JOYSTICK MONITORING hoặc FIRE BUTTON
Chế độ MONITORING, lệnh PAUSE OUTPUT cũng tạm thời dừng hoạt động
quá trình giám sát (tức là các mẫu không được xếp vào hàng đợi để truyền).

SET JOYSTICK EVENT REPORTING
----------------------------

::

0x14

Vào chế độ JOYSTICK EVENT REPORTING (DEFAULT). Mỗi lần mở hoặc đóng của một
công tắc hoặc bộ kích hoạt cần điều khiển sẽ tạo ra bản ghi sự kiện cần điều khiển.

SET JOYSTICK INTERROGATION MODE
-------------------------------

::

0x15

Tắt JOYSTICK EVENT REPORTING. Máy chủ phải gửi JOYSTICK riêng lẻ
Lệnh INTERROGATE để cảm nhận trạng thái cần điều khiển.

JOYSTICK INTERROGATE
--------------------

::

0x16

Trả về bản ghi cho biết trạng thái hiện tại của cần điều khiển. Lệnh này
hợp lệ ở chế độ JOYSTICK EVENT REPORTING hoặc JOYSTICK
INTERROGATION MODE.

SET JOYSTICK MONITORING
-----------------------

::

0x17
    tỉ lệ ; thời gian giữa các mẫu tính bằng phần trăm giây
    Trả về: (trong gói gồm hai gói miễn là ở chế độ)
            %000000xy ; trong đó y là nút Bắn JOYSTICK1
                        ; và x là nút Bắn JOYSTICK0
            %nnnnmmmm ; trong đó m là trạng thái JOYSTICK1
                        ; và n là trạng thái JOYSTICK0

Đặt ikbd không làm gì ngoài việc giám sát dòng lệnh nối tiếp, duy trì
đồng hồ thời gian trong ngày và theo dõi cần điều khiển. Tỷ lệ thiết lập khoảng thời gian
giữa các mẫu cần điều khiển.
N.B. Người dùng không nên đặt tốc độ cao hơn tốc độ truyền thông nối tiếp
kênh sẽ cho phép các gói 2 byte được truyền đi.

SET FIRE BUTTON MONITORING
--------------------------

::

0x18
    Trả về: (miễn là ở chế độ)
            %bbbbbbbb ; trạng thái của nút kích hoạt JOYSTICK1 được đóng gói
                        ; 8 bit mỗi byte, mẫu đầu tiên nếu MSB

Đặt ikbd không làm gì ngoài việc giám sát dòng lệnh nối tiếp, duy trì
đồng hồ thời gian trong ngày và theo dõi nút bắn trên Cần điều khiển 1. Nút bắn
được quét với tốc độ đủ để tạo ra 8 mẫu trong thời gian cần thiết
byte trước đó được gửi đến máy chủ (tức là tốc độ quét = 8/10 * tốc độ truyền).
Khoảng thời gian lấy mẫu phải càng cố định càng tốt.

SET JOYSTICK KEYCODE MODE
-------------------------

::

0x19
    RX ; khoảng thời gian (tính bằng phần mười giây) cho đến khi
                        ; đạt đến điểm dừng vận tốc ngang
    RY ; khoảng thời gian (tính bằng phần mười giây) cho đến khi
                        ; đạt tới điểm dừng vận tốc thẳng đứng
    TX ; chiều dài (tính bằng phần mười giây) của việc đóng cần điều khiển
                        ; cho đến khi phím con trỏ ngang được tạo trước RX
                        ; đã trôi qua
    TY ; chiều dài (tính bằng phần mười giây) của việc đóng cần điều khiển
                        ; cho đến khi phím con trỏ dọc được tạo trước RY
                        ; đã trôi qua
    VX; chiều dài (tính bằng phần mười giây) của việc đóng cần điều khiển
                        ; cho đến khi tạo ra tổ hợp phím con trỏ ngang
                        ; sau khi RX đã trôi qua
    VY ; chiều dài (tính bằng phần mười giây) của việc đóng cần điều khiển
                        ; cho đến khi tạo ra tổ hợp phím con trỏ dọc
                        ; sau khi RY đã trôi qua

Ở chế độ này, cần điều khiển 0 được quét theo cách mô phỏng thao tác nhấn phím con trỏ.
Khi đóng lần đầu, một cặp phím tắt (make/break) được tạo ra. Sau đó lên đến Rn
phần mười giây sau, các cặp phím bấm được tạo ra cứ sau mỗi Tn phần mười giây
giây. Sau khi đạt đến điểm dừng Rn, các cặp phím tắt được tạo
mỗi Vn phần mười giây. Điều này cung cấp điểm dừng vận tốc (tự động lặp lại)
tính năng.
Lưu ý rằng bằng cách đặt RX và/hoặc Ry về 0, tính năng vận tốc có thể được
bị vô hiệu hóa. Các giá trị của TX và TY khi đó trở nên vô nghĩa và việc tạo ra
số lần nhấn phím của con trỏ được thiết lập bởi VX và VY.

DISABLE JOYSTICKS
-----------------

::

0x1A

Vô hiệu hóa việc tạo bất kỳ sự kiện cần điều khiển nào (và quá trình quét có thể được thực hiện nội bộ
bị vô hiệu hóa). Bất kỳ lệnh chế độ cần điều khiển hợp lệ nào sẽ tiếp tục giám sát cần điều khiển. (Các
các lệnh chế độ cần điều khiển là SET JOYSTICK EVENT REPORTING, SET JOYSTICK
INTERROGATION MODE, SET JOYSTICK MONITORING, SET FIRE BUTTON MONITORING, và
SET JOYSTICK KEYCODE MODE.)

TIME-OF-DAY CLOCK SET
---------------------

::

0x1B
    YY ; năm (2 chữ số có nghĩa ít nhất)
    MM ; tháng
    đ ; ngày
    ồ ; giờ
    mm ; phút
    ss ; thứ hai

Tất cả dữ liệu thời gian trong ngày phải được gửi đến ikbd ở định dạng BCD được đóng gói.
Bất kỳ chữ số nào không phải là chữ số BCD hợp lệ sẽ được coi là 'không quan tâm'
và không thay đổi trường cụ thể của ngày hoặc giờ. Điều này cho phép thiết lập
chỉ một số trường con của đồng hồ thời gian trong ngày.

INTERROGATE TIME-OF-DAT CLOCK
-----------------------------

::

0x1C
    Trả về:
            0xFC ; tiêu đề sự kiện thời gian trong ngày
            YY ; năm (2 chữ số có nghĩa ít nhất)
            MM ; tháng
            đ ; ngày
            ồ ; giờ
            mm ; phút
            ss ; thứ hai

Tất cả thời gian trong ngày được gửi ở định dạng BCD được đóng gói.

MEMORY LOAD
-----------

::

0x20
    ADRMSB ; địa chỉ trong bộ điều khiển
    ADRLSB ; bộ nhớ cần được tải
    NUM ; số byte (0-128)
    {dữ liệu }

Lệnh này cho phép máy chủ tải các giá trị tùy ý vào ikbd
bộ nhớ điều khiển. Thời gian giữa các byte dữ liệu phải nhỏ hơn 20ms.

MEMORY READ
-----------

::

0x21
    ADRMSB ; địa chỉ trong bộ điều khiển
    ADRLSB ; bộ nhớ được đọc
    Trả về:
            0xF6 ; tiêu đề trạng thái
            0x20; truy cập bộ nhớ
            { dữ liệu } ; 6 byte dữ liệu bắt đầu từ ADR

Lệnh này cho phép máy chủ đọc từ bộ nhớ của bộ điều khiển ikbd.

CONTROLLER EXECUTE
------------------

::

0x22
    ADRMSB ; địa chỉ của chương trình con trong
    ADRLSB ; bộ nhớ điều khiển được gọi

Lệnh này cho phép máy chủ ra lệnh thực hiện một chương trình con trong
bộ nhớ điều khiển ikbd.

STATUS INQUIRIES
----------------

::

Các lệnh trạng thái được hình thành bằng cách gộp ORing 0x80 với
    lệnh SET có liên quan.

Ví dụ:
    0x88 (hoặc 0x89 hoặc 0x8A); yêu cầu chế độ chuột
    Trả về:
            0xF6 ; tiêu đề phản hồi trạng thái
            chế độ ; 0x08 là RELATIVE
                        ; 0x09 là ABSOLUTE
                        ; 0x0A là KEYCODE
            thông số1; 0 là RELATIVE
                        ; XMSB tối đa nếu ABSOLUTE
                        ; DELTA X là KEYCODE
            thông số2; 0 là RELATIVE
                        ; YMSB tối đa nếu ABSOLUTE
                        ; DELTA Y là KEYCODE
            thông số3; 0 nếu RELATIVE
                        ; hoặc KEYCODE
                        ; YMSB là ABSOLUTE
            thông số4; 0 nếu RELATIVE
                        ; hoặc KEYCODE
                        ; YLSB là ABSOLUTE
            0 ; đệm
            0

Các lệnh STATUS INQUIRY yêu cầu ikbd trả về chế độ hiện tại
hoặc các tham số liên quan đến một lệnh nhất định. Tất cả các báo cáo trạng thái đều
được đệm để tạo thành các gói trả về dài 8 byte. Các phản hồi về trạng thái
các yêu cầu được thiết kế sao cho máy chủ có thể lưu trữ chúng đi (sau khi loại bỏ
tắt byte tiêu đề báo cáo trạng thái) và sau đó gửi chúng trở lại dưới dạng lệnh tới
ikbd để khôi phục trạng thái của nó. Các byte đệm 0 sẽ được coi là NOP bởi
ikbd.

Các lệnh STATUS INQUIRY hợp lệ là::

Hành động nút chuột 0x87
            Chế độ chuột 0x88
            0x89
            0x8A
            Ngưỡng mnuse 0x8B
            Cân chuột 0x8C
            Tọa độ dọc chuột 0x8F
            0x90 ( trả về 0x0F Y=0 ở dưới cùng
                            0x10 Y=0 ở trên cùng)
            Bật/tắt chuột 0x92
                    (trả về 0x00 được bật)
                            0x12 bị vô hiệu hóa)
            Chế độ cần điều khiển 0x94
            0x95
            0x96
            Bật/tắt cần điều khiển 0x9A
                    (trả về 0x00 được bật
                            0x1A bị vô hiệu hóa)

Trách nhiệm của lập trình viên (máy chủ) là chỉ có một câu trả lời chưa được trả lời
yêu cầu trong quá trình tại một thời điểm.
Các lệnh STATUS INQUIRY không hợp lệ nếu ikbd nằm trong JOYSTICK MONITORING
chế độ hoặc chế độ FIRE BUTTON MONITORING.


SCAN CODES
==========

Mã quét chính được ikbd trả về được chọn để đơn giản hóa việc
triển khai GSX.

Ánh xạ bàn phím tiêu chuẩn GSX

======= =============
Bàn phím lục giác
======= =============
01 Esc
02 1
03 2
04 3
05 4
06 5
07 6
08 7
09 8
0A 9
0B 0
0C \-
0D \=
0E BS
0F TAB
10 câu hỏi
11 W
12 E
13 R
14 T
15 năm
16 U
17 tôi
18 O
19 P
1A [
1B ]
1C RET
1D CTRL
1E A
1F S
20 D
21 F
22G
23 giờ
24 J
25 K
26 lít
27 ;
28'
29 \`
2A (LEFT) SHIFT
2B \\
2C Z
2DX
2E C
2F V
30 B
31 N
32 triệu
33 ,
34 .
35 /
36 (RIGHT) SHIFT
37 { NOT USED }
38 ALT
39 SPACE BAR
3A CAPS LOCK
3B F1
3C F2
3D F3
3E F4
3F F5
40 F6
41 F7
42 F8
43 F9
44 F10
45 { NOT USED }
46 { NOT USED }
47 HOME
48 LÊN ARROW
49 { NOT USED }
4A KEYPAD -
4B LEFT ARROW
4C { NOT USED }
4D RIGHT ARROW
4E KEYPAD +
4F { NOT USED }
50 DOWN ARROW
51 { NOT USED }
52 INSERT
53 DEL
54 { NOT USED }
5F { NOT USED }
60 ISO KEY
61 UNDO
62 HELP
63 KEYPAD (
64 KEYPAD /
65 KEYPAD *
66 KEYPAD *
67 KEYPAD 7
68 KEYPAD 8
69 KEYPAD 9
6A KEYPAD 4
6B KEYPAD 5
6C KEYPAD 6
6D KEYPAD 1
6E KEYPAD 2
6F KEYPAD 3
70 KEYPAD 0
71 KEYPAD .
72 KEYPAD ENTER
======= =============
