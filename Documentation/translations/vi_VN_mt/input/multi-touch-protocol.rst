.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/multi-touch-protocol.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

===========================
Giao thức cảm ứng đa điểm (MT)
=========================

:Bản quyền: ZZ0000ZZ 2009-2010 Henrik Rydberg <rydberg@euromail.se>


Giới thiệu
------------

Để tận dụng tối đa sức mạnh của cảm ứng đa điểm và đa người dùng mới
thiết bị, một cách để báo cáo dữ liệu chi tiết từ nhiều địa chỉ liên hệ, tức là
các vật thể tiếp xúc trực tiếp với bề mặt thiết bị là cần thiết.  Cái này
tài liệu mô tả giao thức cảm ứng đa điểm (MT) cho phép kernel
trình điều khiển để báo cáo chi tiết về số lượng liên hệ tùy ý.

Giao thức được chia thành hai loại, tùy thuộc vào khả năng của
phần cứng. Đối với các thiết bị xử lý danh bạ ẩn danh (loại A), giao thức
mô tả cách gửi dữ liệu thô của tất cả các liên hệ đến người nhận. cho
các thiết bị có khả năng theo dõi các liên hệ có thể nhận dạng được (loại B), giao thức
mô tả cách gửi thông tin cập nhật cho từng liên hệ thông qua các thời điểm sự kiện.

.. note::
   MT protocol type A is obsolete, all kernel drivers have been
   converted to use type B.

Sử dụng giao thức
--------------

Chi tiết liên lạc được gửi tuần tự dưới dạng các gói riêng biệt của ABS_MT
sự kiện. Chỉ các sự kiện ABS_MT mới được công nhận là một phần của liên hệ
gói. Vì những sự kiện này bị bỏ qua bởi thao tác chạm một lần (ST) hiện tại
ứng dụng, giao thức MT có thể được triển khai trên giao thức ST
trong một trình điều khiển hiện có.

Trình điều khiển cho thiết bị loại A phân tách các gói liên lạc bằng cách gọi
input_mt_sync() ở cuối mỗi gói. Điều này tạo ra SYN_MT_REPORT
sự kiện hướng dẫn người nhận chấp nhận dữ liệu cho thời điểm hiện tại
liên hệ và chuẩn bị nhận một cái khác.

Trình điều khiển cho thiết bị loại B phân tách các gói liên lạc bằng cách gọi
input_mt_slot(), với một vị trí làm đối số, ở đầu mỗi gói.
Điều này tạo ra một sự kiện ABS_MT_SLOT, hướng dẫn người nhận
chuẩn bị cho các cập nhật của vị trí nhất định.

Tất cả các trình điều khiển đều đánh dấu sự kết thúc của quá trình truyền cảm ứng đa điểm bằng cách gọi thông thường
hàm input_sync(). Điều này hướng dẫn người nhận hành động theo các sự kiện
tích lũy kể từ EV_SYN/SYN_REPORT cuối cùng và chuẩn bị nhận bộ mới
của các sự kiện/gói.

Sự khác biệt chính giữa giao thức loại A không trạng thái và giao thức có trạng thái
Giao thức khe loại B nằm ở việc sử dụng các liên hệ có thể nhận dạng để giảm
lượng dữ liệu được gửi đến không gian người dùng. Giao thức khe yêu cầu sử dụng
ABS_MT_TRACKING_ID, được cung cấp bởi phần cứng hoặc được tính toán từ
dữ liệu thô [#f5]_.

Đối với các thiết bị loại A, trình điều khiển hạt nhân sẽ tạo ra một tập tin tùy ý
liệt kê toàn bộ các liên hệ ẩn danh hiện có trên
bề mặt. Thứ tự các gói xuất hiện trong luồng sự kiện không
quan trọng.  Lọc sự kiện và theo dõi ngón tay được để lại cho không gian người dùng [#f3]_.

Đối với các thiết bị loại B, trình điều khiển hạt nhân phải liên kết một khe cắm với mỗi thiết bị
liên hệ được xác định và sử dụng khe đó để truyền bá các thay đổi cho liên hệ.
Việc tạo, thay thế và hủy các liên hệ được thực hiện bằng cách sửa đổi
ABS_MT_TRACKING_ID của khe liên quan.  Id theo dõi không âm
được hiểu là một liên hệ và giá trị -1 biểu thị một vị trí không được sử dụng.  A
id theo dõi không có trước đây được coi là mới và id theo dõi không có
hiện diện lâu hơn được coi là loại bỏ.  Vì chỉ những thay đổi mới được lan truyền,
trạng thái đầy đủ của mỗi liên hệ được bắt đầu phải nằm ở bên nhận
kết thúc.  Khi nhận được một sự kiện MT, người ta chỉ cần cập nhật thông tin thích hợp
thuộc tính của vị trí hiện tại.

Một số thiết bị xác định và/hoặc theo dõi nhiều liên hệ hơn mức chúng có thể báo cáo cho
người lái xe.  Trình điều khiển cho thiết bị như vậy phải liên kết một khe loại B với mỗi khe
liên hệ được báo cáo bởi phần cứng.  Bất cứ khi nào danh tính của
liên hệ liên quan đến thay đổi vị trí, trình điều khiển sẽ vô hiệu hóa điều đó
khe cắm bằng cách thay đổi ABS_MT_TRACKING_ID của nó.  Nếu phần cứng báo hiệu rằng đó là
theo dõi nhiều liên hệ hơn mức hiện đang báo cáo, người lái xe nên sử dụng
sự kiện BTN_TOOL_*TAP để thông báo cho không gian người dùng về tổng số liên hệ
đang được theo dõi bởi phần cứng tại thời điểm đó.  Người lái xe nên làm điều này bằng cách
gửi rõ ràng sự kiện và cài đặt BTN_TOOL_*TAP tương ứng
use_count thành false khi gọi input_mt_report_pointer_emulation().
Trình điều khiển chỉ nên quảng cáo số lượng vị trí mà phần cứng có thể báo cáo.
Không gian người dùng có thể phát hiện ra rằng trình điều khiển có thể báo cáo tổng số liên hệ nhiều hơn vị trí
bằng cách lưu ý rằng sự kiện BTN_TOOL_*TAP được hỗ trợ lớn nhất sẽ lớn hơn sự kiện
tổng số vị trí loại B được báo cáo trong absinfo cho trục ABS_MT_SLOT.

Giá trị tối thiểu của trục ABS_MT_SLOT phải là 0.

Ví dụ về giao thức A
------------------

Đây là chuỗi sự kiện tối thiểu cho thao tác chạm hai lần liên hệ
như đối với thiết bị loại A::

ABS_MT_POSITION_X x[0]
   ABS_MT_POSITION_Y y[0]
   SYN_MT_REPORT
   ABS_MT_POSITION_X x[1]
   ABS_MT_POSITION_Y y[1]
   SYN_MT_REPORT
   SYN_REPORT

Trình tự sau khi di chuyển một trong các số liên lạc trông giống hệt nhau; cái
dữ liệu thô cho tất cả các liên hệ hiện tại được gửi giữa mỗi lần đồng bộ hóa
với SYN_REPORT.

Đây là trình tự sau khi nâng liên hệ đầu tiên::

ABS_MT_POSITION_X x[1]
   ABS_MT_POSITION_Y y[1]
   SYN_MT_REPORT
   SYN_REPORT

Và đây là trình tự sau khi nhấc liên hệ thứ hai::

SYN_MT_REPORT
   SYN_REPORT

Nếu trình điều khiển báo cáo một trong các BTN_TOUCH hoặc ABS_PRESSURE ngoài
Sự kiện ABS_MT, sự kiện SYN_MT_REPORT cuối cùng có thể bị bỏ qua. Nếu không,
SYN_REPORT cuối cùng sẽ bị lõi đầu vào loại bỏ, dẫn đến không có
sự kiện không tiếp xúc tiếp cận vùng người dùng.


Giao thức Ví dụ B
------------------

Đây là chuỗi sự kiện tối thiểu cho thao tác chạm hai lần liên hệ
giống như đối với thiết bị loại B::

ABS_MT_SLOT 0
   ABS_MT_TRACKING_ID 45
   ABS_MT_POSITION_X x[0]
   ABS_MT_POSITION_Y y[0]
   ABS_MT_SLOT 1
   ABS_MT_TRACKING_ID 46
   ABS_MT_POSITION_X x[1]
   ABS_MT_POSITION_Y y[1]
   SYN_REPORT

Đây là trình tự sau khi di chuyển tiếp điểm 45 theo hướng x::

ABS_MT_SLOT 0
   ABS_MT_POSITION_X x[0]
   SYN_REPORT

Đây là trình tự sau khi nhấc tiếp điểm ở khe 0::

ABS_MT_TRACKING_ID -1
   SYN_REPORT

Khe đang được sửa đổi đã là 0, vì vậy ABS_MT_SLOT bị bỏ qua.  các
thông báo loại bỏ sự liên kết của khe 0 với liên hệ 45, do đó
hủy liên hệ 45 và giải phóng khe 0 để sử dụng lại cho liên hệ khác.

Cuối cùng, đây là trình tự sau khi nhấc liên hệ thứ hai::

ABS_MT_SLOT 1
   ABS_MT_TRACKING_ID-1
   SYN_REPORT


Sử dụng sự kiện
-----------

Một tập hợp các sự kiện ABS_MT với các thuộc tính mong muốn được xác định. Các sự kiện
được chia thành các loại, để cho phép thực hiện một phần.  các
bộ tối thiểu bao gồm ABS_MT_POSITION_X và ABS_MT_POSITION_Y, trong đó
cho phép theo dõi nhiều liên hệ.  Nếu thiết bị hỗ trợ nó,
ABS_MT_TOUCH_MAJOR và ABS_MT_WIDTH_MAJOR có thể được sử dụng để cung cấp kích thước
diện tích tiếp xúc và dụng cụ tiếp cận tương ứng.

Các tham số TOUCH và WIDTH có cách diễn giải hình học; tưởng tượng
nhìn qua cửa sổ thấy ai đó đang nhẹ nhàng đặt ngón tay lên
kính.  Bạn sẽ thấy hai vùng, một vùng bên trong bao gồm phần
ngón tay thực sự chạm vào kính và một vùng bên ngoài được hình thành bởi
chu vi của ngón tay. Tâm của vùng tiếp xúc (a) là
ABS_MT_POSITION_X/Y và tâm của ngón tay đang tiếp cận (b) là
ABS_MT_TOOL_X/Y. Đường kính cảm ứng là ABS_MT_TOUCH_MAJOR và ngón tay
đường kính là ABS_MT_WIDTH_MAJOR. Bây giờ hãy tưởng tượng người đó đang ấn ngón tay
mạnh hơn vào kính. Vùng cảm ứng sẽ tăng lên và nói chung,
tỷ lệ ABS_MT_TOUCH_MAJOR / ABS_MT_WIDTH_MAJOR, luôn nhỏ hơn
hơn sự thống nhất, có liên quan đến áp lực tiếp xúc. Đối với các thiết bị dựa trên áp suất,
ABS_MT_PRESSURE có thể được sử dụng để tạo áp lực lên vùng tiếp xúc
thay vào đó. Các thiết bị có khả năng di chuột tiếp xúc có thể sử dụng ABS_MT_DISTANCE để
cho biết khoảng cách giữa tiếp điểm và bề mặt.

::


Linux MT Win8
         __________ _______________________
        / \ ZZ0000ZZ
       / \ ZZ0001ZZ
      / ____ \ ZZ0002ZZ
     / / \ \ ZZ0003ZZ
     \ \ a \ \ ZZ0004ZZ
      \ \____/ \ ZZ0005ZZ
       \ \ ZZ0006ZZ
        \ b \ ZZ0007ZZ
         \ \ ZZ0008ZZ
          \ \ ZZ0009ZZ
           \ \ ZZ0010ZZ
            \ / ZZ0011ZZ
             \ / ZZ0012ZZ
              \ / ZZ0013ZZ
               \__________/ ZZ0014ZZ


Ngoài các thông số MAJOR, hình bầu dục của cảm ứng và ngón tay
các vùng có thể được mô tả bằng cách thêm các tham số MINOR, chẳng hạn như MAJOR
và MINOR là trục chính và trục phụ của hình elip. Định hướng của
hình elip cảm ứng có thể được mô tả bằng tham số ORIENTATION và
hướng của hình elip ngón tay được cho bởi vectơ (a - b).

Đối với các thiết bị loại A, có thể có thêm thông số kỹ thuật về hình dạng cảm ứng
thông qua ABS_MT_BLOB_ID.

ABS_MT_TOOL_TYPE có thể được sử dụng để chỉ định liệu dụng cụ chạm có phải là
ngón tay hoặc một cây bút hoặc cái gì khác. Cuối cùng là sự kiện ABS_MT_TRACKING_ID
có thể được sử dụng để theo dõi các liên hệ được xác định theo thời gian [#f5]_.

Trong giao thức loại B, ABS_MT_TOOL_TYPE và ABS_MT_TRACKING_ID là
được xử lý ngầm bởi lõi đầu vào; thay vào đó, các tài xế nên gọi
input_mt_report_slot_state().


Ngữ nghĩa sự kiện
---------------

ABS_MT_TOUCH_MAJOR
    Độ dài trục chính của tiếp điểm. Độ dài nên được đưa ra trong
    các đơn vị bề mặt Nếu bề mặt có độ phân giải X nhân Y thì giá trị lớn nhất
    giá trị có thể có của ABS_MT_TOUCH_MAJOR là sqrt(X^2 + Y^2), đường chéo [#f4]_.

ABS_MT_TOUCH_MINOR
    Chiều dài, tính bằng đơn vị bề mặt, của trục nhỏ của tiếp điểm. Nếu
    liên hệ là hình tròn, sự kiện này có thể được bỏ qua [#f4]_.

ABS_MT_WIDTH_MAJOR
    Chiều dài, tính bằng đơn vị bề mặt, của trục chính của vật tiếp cận
    công cụ. Điều này nên được hiểu là kích thước của chính công cụ đó. các
    hướng của tiếp điểm và công cụ tiếp cận được coi là
    tương tự [#f4]_.

ABS_MT_WIDTH_MINOR
    Chiều dài, tính bằng đơn vị bề mặt, của trục nhỏ của điểm tiếp cận
    công cụ. Bỏ qua nếu tròn [#f4]_.

Bốn giá trị trên có thể được sử dụng để lấy thêm thông tin về
    liên lạc. Tỷ lệ ABS_MT_TOUCH_MAJOR / ABS_MT_WIDTH_MAJOR xấp xỉ
    khái niệm về áp suất Các ngón tay và lòng bàn tay đều có
    độ rộng đặc trưng khác nhau.

ABS_MT_PRESSURE
    Áp suất, theo đơn vị tùy ý, trên vùng tiếp xúc. Có thể được sử dụng thay thế
    của TOUCH và WIDTH cho các thiết bị dựa trên áp suất hoặc bất kỳ thiết bị nào có không gian
    phân bố cường độ tín hiệu.

Nếu độ phân giải bằng 0, dữ liệu áp suất sẽ ở đơn vị tùy ý.
    Nếu độ phân giải khác 0 thì dữ liệu áp suất được tính bằng đơn vị/gram. Xem
    ZZ0000ZZ để biết chi tiết.

ABS_MT_DISTANCE
    Khoảng cách, tính theo đơn vị bề mặt, giữa tiếp điểm và bề mặt. số không
    khoảng cách có nghĩa là tiếp điểm đang chạm vào bề mặt. Số dương có nghĩa là
    tiếp điểm đang lơ lửng trên bề mặt.

ABS_MT_ORIENTATION
    Hướng của hình elip tiếp xúc. Giá trị phải mô tả một chữ ký
    một phần tư vòng quay theo chiều kim đồng hồ quanh tâm cảm ứng. Giá trị đã ký
    phạm vi là tùy ý, nhưng phải trả về 0 cho hình elip được căn chỉnh với
    trục Y (phía bắc) của bề mặt, giá trị âm khi hình elip
    quay sang trái và có giá trị dương khi hình elip được quay sang
    đúng. Khi căn chỉnh với trục X theo hướng dương, phạm vi
    tối đa nên được trả lại; khi căn chỉnh với trục X theo chiều âm
    hướng, phạm vi -max sẽ được trả về.

Theo mặc định, các hình elip cảm ứng có tính chất đối xứng. Đối với các thiết bị có khả năng true 360
    hướng độ, hướng được báo cáo phải vượt quá phạm vi tối đa đến
    chỉ ra hơn một phần tư của một cuộc cách mạng. Đối với một ngón tay lộn ngược,
    phạm vi tối đa * 2 sẽ được trả lại.

Có thể bỏ qua hướng nếu vùng cảm ứng là hình tròn hoặc nếu
    thông tin không có sẵn trong trình điều khiển hạt nhân. Định hướng một phần
    Có thể hỗ trợ nếu thiết bị có thể phân biệt giữa hai trục, nhưng
    không (duy nhất) bất kỳ giá trị nào ở giữa. Trong những trường hợp như vậy, phạm vi của
    ABS_MT_ORIENTATION phải là [0, 1] [#f4]_.

ABS_MT_POSITION_X
    Tọa độ bề mặt X của tâm của hình elip tiếp xúc.

ABS_MT_POSITION_Y
    Tọa độ bề mặt Y của tâm của hình elip tiếp xúc.

ABS_MT_TOOL_X
    Tọa độ bề mặt X của tâm dụng cụ tiếp cận. Bỏ qua nếu
    thiết bị không thể phân biệt giữa điểm tiếp xúc dự kiến và điểm tiếp xúc
    bản thân công cụ.

ABS_MT_TOOL_Y
    Tọa độ bề mặt Y của tâm dụng cụ tiếp cận. Bỏ qua nếu
    thiết bị không thể phân biệt giữa điểm tiếp xúc dự định và công cụ
    chính nó.

Bốn giá trị vị trí có thể được sử dụng để phân tách vị trí của cảm ứng
    từ vị trí của dụng cụ. Nếu cả hai vị trí đều có mặt, chính
    trục dao hướng về điểm tiếp xúc [#f1]_. Nếu không, các trục công cụ sẽ
    căn chỉnh với trục cảm ứng.

ABS_MT_TOOL_TYPE
    Loại công cụ tiếp cận. Rất nhiều trình điều khiển kernel không thể phân biệt được
    giữa các loại công cụ khác nhau, chẳng hạn như ngón tay hoặc bút. Trong những trường hợp như vậy,
    sự kiện nên được bỏ qua. Giao thức hiện nay chủ yếu hỗ trợ
    MT_TOOL_FINGER, MT_TOOL_PEN, và MT_TOOL_PALM [#f2]_.
    Đối với thiết bị loại B, sự kiện này được xử lý bởi lõi đầu vào; người lái xe nên
    thay vào đó hãy sử dụng input_mt_report_slot_state(). ABS_MT_TOOL_TYPE của một liên hệ có thể
    thay đổi theo thời gian trong khi vẫn chạm vào thiết bị, vì phần sụn có thể
    không thể xác định được công cụ nào đang được sử dụng khi nó xuất hiện lần đầu.

ABS_MT_BLOB_ID
    BLOB_ID nhóm một số gói lại với nhau thành một hình dạng tùy ý
    liên hệ. Chuỗi các điểm tạo thành một đa giác xác định hình dạng của
    liên lạc. Đây là nhóm ẩn danh cấp thấp dành cho các thiết bị loại A và
    không nên nhầm lẫn với ID theo dõi cấp cao [#f5]_. Hầu hết loại A
    các thiết bị không có khả năng blob, vì vậy người lái xe có thể yên tâm bỏ qua sự kiện này.

ABS_MT_TRACKING_ID
    TRACKING_ID xác định một liên hệ được bắt đầu trong suốt vòng đời của nó
    [#f5]_. Phạm vi giá trị của TRACKING_ID phải đủ lớn để đảm bảo
    nhận dạng duy nhất của một liên hệ được duy trì trong một thời gian dài
    thời gian. Đối với thiết bị loại B, sự kiện này được xử lý bởi lõi đầu vào; trình điều khiển
    thay vào đó nên sử dụng input_mt_report_slot_state().


Tính toán sự kiện
-----------------

Hệ thống phần cứng khác nhau không thể tránh khỏi dẫn đến một số thiết bị phù hợp
giao thức MT tốt hơn các giao thức khác. Để đơn giản hóa và thống nhất việc ánh xạ,
phần này cung cấp các công thức tính toán các sự kiện nhất định.

Đối với các thiết bị báo cáo liên hệ dưới dạng hình chữ nhật, hướng có dấu
không thể có được. Giả sử X và Y là độ dài các cạnh của hình
chạm vào hình chữ nhật, đây là một công thức đơn giản giúp giữ lại nhiều nhất
thông tin có thể::

ABS_MT_TOUCH_MAJOR := tối đa(X, Y)
   ABS_MT_TOUCH_MINOR := phút(X, Y)
   ABS_MT_ORIENTATION := bool(X > Y)

Phạm vi của ABS_MT_ORIENTATION phải được đặt thành [0, 1], để chỉ ra rằng
thiết bị có thể phân biệt giữa một ngón tay dọc theo trục Y (0) và một
ngón tay dọc theo trục X (1).

Đối với các thiết bị Win8 có cả tọa độ T và C, ánh xạ vị trí là::

ABS_MT_POSITION_X :=T_X
   ABS_MT_POSITION_Y :=T_Y
   ABS_MT_TOOL_X :=C_X
   ABS_MT_TOOL_Y := C_Y

Thật không may, không có đủ thông tin để xác định cả cảm động
hình elip và hình elip công cụ, vì vậy người ta phải sử dụng các phép tính gần đúng.  một
sơ đồ đơn giản, tương thích với cách sử dụng trước đó, là::

ABS_MT_TOUCH_MAJOR := phút(X, Y)
   ABS_MT_TOUCH_MINOR := <không sử dụng>
   ABS_MT_ORIENTATION := <không sử dụng>
   ABS_MT_WIDTH_MAJOR := phút(X, Y) + khoảng cách(T, C)
   ABS_MT_WIDTH_MINOR := phút(X, Y)

Cơ sở lý luận: Chúng tôi không có thông tin về hướng chạm vào
hình elip, vì vậy hãy ước chừng nó bằng một đường tròn nội tiếp. công cụ
hình elip phải thẳng hàng với vectơ (T - C), do đó đường kính phải
tăng theo khoảng cách (T, C). Cuối cùng, giả sử rằng đường kính tiếp xúc là
bằng độ dày dụng cụ và chúng ta đi đến các công thức trên.

Theo dõi ngón tay
---------------

Quá trình theo dõi ngón tay, tức là gán một ID theo dõi duy nhất cho mỗi
sự tiếp xúc bắt đầu trên bề mặt, là sự kết hợp lưỡng cực Euclide
vấn đề.  Tại mỗi lần đồng bộ hóa sự kiện, tập hợp các liên hệ thực tế được
khớp với tập hợp liên hệ từ lần đồng bộ hóa trước đó. đầy đủ
việc triển khai có thể được tìm thấy trong [#f3]_.


Cử chỉ
--------

Trong ứng dụng cụ thể là tạo sự kiện cử chỉ, TOUCH và WIDTH
các thông số có thể được sử dụng để, ví dụ, áp lực ngón tay gần đúng hoặc phân biệt
giữa ngón trỏ và ngón cái. Với việc bổ sung các tham số MINOR,
người ta cũng có thể phân biệt giữa ngón tay quét và ngón tay trỏ,
và với ORIENTATION, người ta có thể phát hiện tình trạng xoắn ngón tay.


Ghi chú
-----

Để duy trì khả năng tương thích với các ứng dụng hiện có, dữ liệu được báo cáo
trong gói ngón tay không được coi là sự kiện một lần chạm.

Đối với thiết bị loại A, tất cả dữ liệu ngón tay đều bỏ qua quá trình lọc đầu vào, vì
các sự kiện tiếp theo cùng loại đề cập đến các ngón tay khác nhau.

.. [#f1] Also, the difference (TOOL_X - POSITION_X) can be used to model tilt.
.. [#f2] The list can of course be extended.
.. [#f3] The mtdev project: http://bitmath.org/code/mtdev/.
.. [#f4] See the section on event computation.
.. [#f5] See the section on finger tracking.
