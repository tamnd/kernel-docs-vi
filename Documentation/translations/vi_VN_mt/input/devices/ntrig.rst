.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/ntrig.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===========================
Trình điều khiển màn hình cảm ứng N-Trig
=========================

:Bản quyền: ZZ0000ZZ 2008-2010 Rafi Rubin <rafi@seas.upenn.edu>
:Bản quyền: ZZ0001ZZ 2009-2010 Stephane Chatty

Trình điều khiển này cung cấp hỗ trợ cho bút N-Trig và cảm biến cảm ứng đa điểm.  Độc thân
và các sự kiện cảm ứng đa điểm được dịch sang các giao thức thích hợp cho
hệ thống ẩn và đầu vào.  Các sự kiện bút được ẩn đầy đủ và tuân thủ
được để lại cho lõi ẩn.  Trình điều khiển cũng cung cấp tính năng lọc bổ sung
và các chức năng tiện ích có thể truy cập được bằng các tham số mô-đun và sysfs.

Trình điều khiển này đã được báo cáo là hoạt động bình thường với nhiều thiết bị N-Trig
đính kèm.


Thông số
----------

Lưu ý: các giá trị được đặt tại thời điểm tải là toàn cục và sẽ áp dụng cho tất cả các giá trị hiện hành.
thiết bị.  Việc điều chỉnh các tham số bằng sysfs sẽ ghi đè các giá trị thời gian tải,
nhưng chỉ dành cho một thiết bị đó.

Các tham số sau được sử dụng để định cấu hình bộ lọc nhằm giảm nhiễu:

+-----------------------+------------------------------------------------------+
|activate_slack		|Số lượng ngón tay cần bỏ qua trước khi xử lý sự kiện |
+-----------------------+------------------------------------------------------+
Ngưỡng kích thước |activation_height,	| kích hoạt ngay |
ZZ0002ZZ |
+-----------------------+------------------------------------------------------+
|min_height,		|size ngưỡng dưới mà ngón tay bị bỏ qua |
|min_width		|cả hai đều quyết định kích hoạt và trong quá trình hoạt động |
+-----------------------+------------------------------------------------------+
|deactivate_slack	|số lượng khung hình "không liên lạc" cần bỏ qua trước |
|			|tuyên truyền kết thúc sự kiện hoạt động |
+-----------------------+------------------------------------------------------+

Khi ngón tay cuối cùng được gỡ bỏ khỏi thiết bị, nó sẽ gửi một số trống
khung.  Bằng cách trì hoãn việc hủy kích hoạt trong một vài khung hình, chúng ta có thể chấp nhận sai sót
ngắt kết nối sai, trong đó cảm biến có thể không phát hiện nhầm ngón tay
vẫn còn hiện diện.  Do đó, deactive_slack giải quyết các vấn đề mà người dùng có thể
thấy các ngắt dòng trong khi vẽ hoặc thả một đối tượng khi kéo dài.


Các mục sysfs bổ sung
----------------------

Các nút này chỉ cung cấp khả năng truy cập dễ dàng vào phạm vi được thiết bị báo cáo.

+-----------------------+------------------------------------------------------+
ZZ0000ZZ phạm vi cho các vị trí được báo cáo trong quá trình hoạt động |
ZZ0001ZZ |
+-----------------------+------------------------------------------------------+
Phạm vi nội bộ ZZ0002ZZ không được sử dụng cho các sự kiện thông thường nhưng |
ZZ0003ZZ hữu ích cho việc điều chỉnh |
+-----------------------+------------------------------------------------------+

Tất cả các thiết bị N-Trig có id sản phẩm là 1 sự kiện báo cáo trong phạm vi

*X: 0-9600
* Y: 0-7200

Tuy nhiên không phải tất cả các thiết bị này đều có cùng kích thước vật lý.  Hầu hết
dường như là cảm biến 12" (Dell Latitude XT và XT2 và HP TX2), và
ít nhất một model (Dell Studio 17) có cảm biến 17".  Tỷ lệ vật lý
theo kích thước logic được sử dụng để điều chỉnh các tham số bộ lọc dựa trên kích thước.


Lọc
---------

Với việc phát hành các phần mềm cảm ứng đa điểm đầu tiên, nó ngày càng trở nên
rõ ràng là những cảm biến này dễ xảy ra các sự kiện sai sót.  Người dùng đã báo cáo
nhìn thấy cả liên hệ bị mất không thích hợp và bóng ma, liên hệ đã báo cáo
nơi không có ngón tay nào thực sự chạm vào màn hình.

Việc vô hiệu hóa độ trễ giúp ngăn ngừa tình trạng mất liên lạc khi sử dụng một lần chạm, nhưng không
không giải quyết được vấn đề mất một trong nhiều liên hệ trong khi các liên hệ khác
vẫn đang hoạt động.  Giảm trong bối cảnh cảm ứng đa điểm yêu cầu bổ sung
xử lý và phải được xử lý song song với việc xử lý.

Theo quan sát, việc tiếp xúc với bóng ma cũng tương tự như việc sử dụng cảm biến trong thực tế, nhưng chúng
dường như có hồ sơ khác nhau.  Hoạt động ma quái thường xuất hiện ở mức độ nhỏ
những cú chạm ngắn ngủi.  Như vậy, tôi cho rằng luồng liên tục càng dài
của các sự kiện thì những sự kiện đó càng có nhiều khả năng là từ một liên hệ thực sự và rằng
kích thước của mỗi liên hệ càng lớn thì càng có nhiều khả năng nó là thật.  Cân bằng các
mục tiêu ngăn chặn ma và chấp nhận sự kiện có thật một cách nhanh chóng (để giảm thiểu
độ trễ có thể quan sát được của người dùng), bộ lọc sẽ tích lũy độ tin cậy cho
các sự kiện cho đến khi đạt đến ngưỡng và bắt đầu lan truyền.  Trong sự quan tâm đến
giảm thiểu trạng thái lưu trữ cũng như chi phí hoạt động để đưa ra quyết định,
Tôi đã giữ quyết định đó đơn giản.

Thời gian được đo bằng số ngón tay được báo cáo chứ không phải khung hình vì
xác suất xuất hiện nhiều bóng ma đồng thời dự kiến sẽ giảm xuống
đáng kể với số lượng ngày càng tăng.  Thay vì tích lũy cân nặng như một
hàm kích thước, tôi chỉ sử dụng nó làm ngưỡng nhị phân.  Đủ lớn
liên hệ ngay lập tức ghi đè thời gian chờ đợi và dẫn đến kích hoạt.

Đặt ngưỡng kích thước kích hoạt thành giá trị lớn sẽ dẫn đến việc quyết định
chủ yếu là do kích hoạt chậm.  Nếu bạn nhìn thấy những bóng ma sống lâu hơn, hãy bật màn hình lên
độ trễ kích hoạt trong khi giảm ngưỡng kích thước có thể đủ để loại bỏ
những bóng ma trong khi vẫn giữ cho màn hình khá nhạy với những cú chạm chắc chắn.

Các liên hệ tiếp tục được lọc với min_height và min_width ngay cả sau khi
bộ lọc kích hoạt ban đầu được thỏa mãn.  Mục đích là để cung cấp
cơ chế lọc ma dưới dạng ngón tay phụ trong khi
bạn thực sự đang sử dụng màn hình.  Trong thực tế loại ma này có
ít vấn đề hơn hoặc tương đối hiếm và tôi đã để mặc định
được đặt thành 0 cho cả hai tham số, tắt bộ lọc đó một cách hiệu quả.

Tôi không biết giá trị tối ưu cho các bộ lọc này là gì.  Nếu mặc định
không phù hợp với bạn, vui lòng thử nghiệm với các thông số.  Nếu bạn tìm thấy khác
giá trị thoải mái hơn, tôi sẽ đánh giá cao phản hồi.

Việc hiệu chuẩn các thiết bị này không trôi theo thời gian.  Nếu ma hay liên lạc
tình trạng sụt giảm trở nên trầm trọng hơn và cản trở việc sử dụng bình thường của thiết bị, hãy thử
hiệu chỉnh lại nó.


Sự định cỡ
-----------

Các công cụ cửa sổ N-Trig cung cấp các quy trình hiệu chuẩn và kiểm tra.  Cũng là một
bộ công cụ không gian người dùng không được hỗ trợ không chính thức bao gồm bộ hiệu chuẩn
có sẵn tại:
ZZ0000ZZ


Theo dõi
--------

Cho đến nay, tất cả các phần cứng N-Trig đã được thử nghiệm đều không theo dõi ngón tay.  Khi nhiều
các liên hệ đang hoạt động, chúng dường như được sắp xếp chủ yếu theo vị trí Y.
