.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/RCU/Design/Expedited-Grace-Periods/Expedited-Grace-Periods.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================
Chuyến tham quan qua thời gian gia hạn nhanh của TREE_RCU
=================================================

Giới thiệu
============

Tài liệu này mô tả thời gian gia hạn nhanh của RCU.
Không giống như thời gian gia hạn thông thường của RCU, chấp nhận độ trễ dài để đạt được
hiệu quả cao và sự xáo trộn tối thiểu, thời gian ân hạn nhanh chóng được chấp nhận
hiệu quả thấp hơn và nhiễu loạn đáng kể để đạt được độ trễ ngắn hơn.

Có hai phiên bản của RCU (RCU-preempt và RCU-scheded), với phiên bản trước đó
hương vị RCU-bh thứ ba đã được triển khai theo hai hương vị còn lại.
Mỗi cách triển khai đều được trình bày trong phần riêng của nó.

Thiết kế thời gian gia hạn nhanh
=============================

Thời gian gia hạn RCU cấp tốc không thể bị buộc tội là tinh vi,
vì tất cả ý định và mục đích của họ đều tấn công mọi chiếc CPU mà
vẫn chưa cung cấp trạng thái không hoạt động cho tốc độ nhanh hiện tại
thời gian ân hạn.
Một điều may mắn là chiếc búa đã nhỏ đi một chút
theo thời gian: Cuộc gọi cũ tới ZZ0000ZZ đã được thực hiện
được thay thế bằng một tập hợp các lệnh gọi tới ZZ0001ZZ,
mỗi kết quả trong số đó dẫn đến IPI cho CPU mục tiêu.
Hàm xử lý tương ứng kiểm tra trạng thái của CPU, thúc đẩy
trạng thái không hoạt động nhanh hơn nếu có thể và kích hoạt báo cáo
của trạng thái tĩnh lặng đó.
Như mọi khi đối với RCU, một khi mọi thứ đã trải qua một thời gian im lặng
trạng thái, thời gian gia hạn cấp tốc đã hoàn tất.

Các chi tiết của bộ xử lý ZZ0000ZZ
hoạt động phụ thuộc vào hương vị RCU, như được mô tả sau đây
phần.

RCU-Thời gian ân hạn nhanh được ưu tiên
===================================

Hạt nhân ZZ0000ZZ triển khai tính năng ưu tiên RCU.
Quy trình tổng thể của việc xử lý CPU nhất định bằng quyền ưu tiên RCU
thời gian gia hạn nhanh được thể hiện trong sơ đồ sau:

.. kernel-figure:: ExpRCUFlow.svg

Mũi tên liền biểu thị hành động trực tiếp, ví dụ: lệnh gọi hàm.
Mũi tên chấm biểu thị hành động gián tiếp, ví dụ: IPI
hoặc một trạng thái đạt được sau một thời gian.

Nếu CPU nhất định đang ngoại tuyến hoặc không hoạt động, ZZ0000ZZ
sẽ bỏ qua nó vì CPU nhàn rỗi và ngoại tuyến đã cư trú
ở trạng thái tĩnh.
Nếu không, thời gian gia hạn nhanh sẽ được sử dụng
ZZ0001ZZ để gửi CPU một IPI,
được xử lý bởi ZZ0002ZZ.

Tuy nhiên, vì đây là ưu tiên RCU, ZZ0000ZZ
có thể kiểm tra xem CPU hiện có đang chạy ở phía đọc RCU không
phần quan trọng.
Nếu không, người xử lý có thể báo cáo ngay trạng thái không hoạt động.
Mặt khác, nó đặt cờ sao cho ZZ0001ZZ ngoài cùng
lệnh gọi sẽ cung cấp báo cáo trạng thái tĩnh cần thiết.
Việc cài đặt cờ này tránh được quyền ưu tiên bắt buộc trước đó của tất cả
CPU có thể có các phần quan trọng bên đọc RCU.
Ngoài ra, việc đặt cờ này được thực hiện để tránh tăng
chi phí chung của đường dẫn nhanh thông thường thông qua bộ lập lịch.

Một lần nữa vì đây là RCU được ưu tiên, phần quan trọng bên đọc RCU
có thể được ưu tiên.
Khi điều đó xảy ra, RCU sẽ xếp nhiệm vụ vào hàng đợi, việc này sẽ tiếp tục
chặn thời gian gia hạn cấp tốc hiện tại cho đến khi nó tiếp tục và tìm thấy thời gian gia hạn
ngoài cùng ZZ0000ZZ.
CPU sẽ báo cáo trạng thái không hoạt động ngay sau khi thực hiện nhiệm vụ vì
CPU không còn chặn thời gian gia hạn nữa.
Thay vào đó, nhiệm vụ được ưu tiên thực hiện việc chặn.
Danh sách tác vụ bị chặn được quản lý bởi ZZ0001ZZ,
được gọi từ ZZ0002ZZ,
lần lượt được gọi từ ZZ0003ZZ, trong đó
lượt được gọi từ bộ lập lịch.


+--------------------------------------------------------------------------------------- +
ZZ0004ZZ
+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
+--------------------------------------------------------------------------------------- +

Xin lưu ý rằng đây chỉ là quy trình tổng thể: Các biến chứng bổ sung
có thể phát sinh do các cuộc đua với CPU không hoạt động hoặc ngoại tuyến, trong số các lý do khác
mọi thứ.

Thời gian gia hạn nhanh theo lịch trình RCU
---------------------------------

Hạt nhân ZZ0000ZZ triển khai lịch trình RCU. Dòng chảy tổng thể của
việc xử lý một CPU nhất định theo thời gian gia hạn cấp tốc theo lịch trình của RCU là
thể hiện ở sơ đồ sau:

.. kernel-figure:: ExpSchedFlow.svg

Như với RCU-preempt, ZZ0000ZZ của RCU-sched bỏ qua
CPU ngoại tuyến và nhàn rỗi, một lần nữa vì chúng ở chế độ có thể phát hiện được từ xa
các trạng thái tĩnh. Tuy nhiên, vì ZZ0001ZZ và
ZZ0002ZZ không để lại dấu vết nào về lời kêu gọi của họ, trong
nói chung là không thể biết CPU hiện tại có ở trạng thái hay không
phần quan trọng phía đọc RCU. Điều tốt nhất mà RCU-sched
ZZ0003ZZ có thể làm là kiểm tra tình trạng không hoạt động, trong trường hợp không may
rằng CPU không hoạt động trong khi IPI đang bay. Nếu CPU không hoạt động,
sau đó ZZ0004ZZ báo cáo trạng thái không hoạt động.

Mặt khác, trình xử lý buộc chuyển đổi ngữ cảnh trong tương lai bằng cách đặt
Cờ NEED_RESCHED của cờ luồng của tác vụ hiện tại và quyền ưu tiên CPU
quầy. Tại thời điểm chuyển đổi ngữ cảnh, CPU báo cáo
trạng thái tĩnh lặng. Nếu CPU ngoại tuyến trước, nó sẽ báo cáo
trạng thái tĩnh lúc bấy giờ.

Thời gian gia hạn nhanh và Hotplug CPU
--------------------------------------

Bản chất cấp tốc của thời gian ân hạn cấp tốc đòi hỏi một quy định chặt chẽ hơn nhiều.
tương tác với các hoạt động cắm nóng CPU hơn mức cần thiết cho thông thường
các thời kỳ ân hạn. Ngoài ra, việc cố gắng sử dụng CPU ngoại tuyến IPI sẽ dẫn đến
trong các biểu tượng, nhưng việc không xử lý được CPU trực tuyến IPI có thể dẫn đến thời gian xử lý quá ngắn
thời kỳ. Không có tùy chọn nào được chấp nhận trong hạt nhân sản xuất.

Sự tương tác giữa thời gian gia hạn nhanh và hotplug CPU
hoạt động được thực hiện ở nhiều cấp độ:

#. Số lượng CPU đã từng trực tuyến được theo dõi bởi
   Trường ZZ0001ZZ của cấu trúc ZZ0000ZZ. ZZ0002ZZ
   trường ZZ0003ZZ của cấu trúc theo dõi số lượng CPU
   đã từng trực tuyến khi bắt đầu thời hạn ưu đãi cấp tốc RCU
   kỳ. Lưu ý rằng con số này không bao giờ giảm, ít nhất là trong
   sự vắng mặt của cỗ máy thời gian
#. Danh tính của các CPU đã từng trực tuyến được theo dõi bởi
   trường ZZ0005ZZ của cấu trúc ZZ0004ZZ. các
   Trường ZZ0007ZZ của cấu trúc ZZ0006ZZ theo dõi
   danh tính của các CPU đã trực tuyến ít nhất một lần tại
   bắt đầu thời gian ân hạn cấp tốc RCU gần đây nhất. các
   Các trường ZZ0009ZZ và ZZ0010ZZ của cấu trúc ZZ0008ZZ là
   được sử dụng để phát hiện khi CPU mới trực tuyến lần đầu tiên,
   nghĩa là, khi ZZ0012ZZ của cấu trúc ZZ0011ZZ
   trường đã thay đổi kể từ khi bắt đầu gia hạn nhanh RCU cuối cùng
   khoảng thời gian, kích hoạt cập nhật của từng cấu trúc ZZ0013ZZ
   Trường ZZ0014ZZ từ trường ZZ0015ZZ của nó.
#. Trường ZZ0017ZZ của mỗi cấu trúc ZZ0016ZZ được sử dụng để
   khởi tạo ZZ0018ZZ của cấu trúc đó ở đầu mỗi cấu trúc
   RCU thời gian gia hạn nhanh. Điều này có nghĩa là chỉ những CPU có
   đã trực tuyến ít nhất một lần sẽ được xem xét cho một ân huệ nhất định
   kỳ.
#. Bất kỳ CPU nào ngoại tuyến sẽ xóa bit của nó trong lá ZZ0019ZZ của nó
   trường ZZ0020ZZ của cấu trúc, do đó, bất kỳ CPU nào có bit đó
   clear có thể được bỏ qua một cách an toàn. Tuy nhiên, có thể CPU sắp ra mắt
   trực tuyến hoặc ngoại tuyến để thiết lập bit này trong một thời gian
   ZZ0021ZZ trả về ZZ0022ZZ.
#. Đối với mỗi CPU không rảnh mà RCU tin rằng hiện đang trực tuyến,
   thời gian gia hạn gọi ZZ0023ZZ. Nếu điều này
   thành công, CPU đã hoàn toàn trực tuyến. Lỗi chỉ ra rằng CPU đang
   trong quá trình trực tuyến hoặc ngoại tuyến, trong trường hợp đó là
   cần phải chờ một khoảng thời gian ngắn và thử lại. Mục đích
   việc chờ đợi này (hoặc một loạt các lần chờ đợi, tùy từng trường hợp) là cho phép một
   thao tác cắm nóng CPU đồng thời đã hoàn tất.
#. Trong trường hợp RCU-scheduled, một trong những hành động cuối cùng của CPU gửi đi là
   để gọi ZZ0024ZZ, báo cáo trạng thái không hoạt động cho
   CPU đó. Tuy nhiên, đây có thể là sự dư thừa do chứng hoang tưởng gây ra.

+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
+--------------------------------------------------------------------------------------- +
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
ZZ0026ZZ
ZZ0027ZZ
+--------------------------------------------------------------------------------------- +

Tinh chỉnh thời gian gia hạn nhanh
----------------------------------

Kiểm tra nhàn rỗi-CPU
~~~~~~~~~~~~~~~

Mỗi thời gian gia hạn nhanh sẽ kiểm tra các CPU nhàn rỗi khi hình thành lần đầu
mặt nạ của các CPU sẽ được IPI và một lần nữa ngay trước khi IPI một CPU (cả hai
việc kiểm tra được thực hiện bởi ZZ0000ZZ). Nếu CPU là
không hoạt động bất cứ lúc nào giữa hai thời điểm đó, CPU sẽ không bị IPIed.
Thay vào đó, nhiệm vụ đẩy thời gian gia hạn về phía trước sẽ bao gồm cả thời gian rảnh
CPU trong mặt nạ được chuyển tới ZZ0001ZZ.

Đối với RCU-scheduled, có một kiểm tra bổ sung: Nếu IPI bị gián đoạn
vòng lặp nhàn rỗi, sau đó ZZ0000ZZ gọi
ZZ0001ZZ để báo cáo trạng thái tĩnh tương ứng.

Đối với RCU-preempt, không có kiểm tra cụ thể nào về trạng thái rảnh trong trình xử lý IPI
(ZZ0000ZZ), nhưng vì các phần quan trọng phía đọc của RCU là
không được phép trong vòng lặp nhàn rỗi, nếu ZZ0001ZZ thấy điều đó
CPU nằm trong phần quan trọng phía đọc RCU, CPU không thể
có thể đang nhàn rỗi. Ngược lại, ZZ0002ZZ gọi
ZZ0003ZZ để báo cáo trạng thái không hoạt động tương ứng,
bất kể trạng thái không hoạt động đó có phải là do CPU hay không
đang nhàn rỗi.

Tóm lại, RCU đã tăng tốc thời gian gia hạn để kiểm tra tình trạng nhàn rỗi khi xây dựng
bitmask của CPU phải được IPIed, ngay trước khi gửi từng IPI và
(rõ ràng hoặc ngầm định) trong trình xử lý IPI.

Tạo khối thông qua bộ đếm trình tự
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu mỗi yêu cầu trong thời gian gia hạn được thực hiện riêng biệt thì thời gian gia hạn sẽ được đẩy nhanh
các giai đoạn sẽ có khả năng mở rộng kém và tải cao có vấn đề
đặc điểm. Bởi vì mỗi hoạt động trong thời gian gia hạn có thể phục vụ một
số lượng cập nhật không giới hạn, điều quan trọng đối với các yêu cầu ZZ0000ZZ, vì vậy
rằng một hoạt động trong thời gian ân hạn cấp tốc sẽ đáp ứng tất cả các yêu cầu
trong lô tương ứng.

Việc trộn này được điều khiển bởi một bộ đếm trình tự có tên
ZZ0000ZZ trong cấu trúc ZZ0001ZZ. quầy này
có giá trị lẻ khi đang có thời gian gia hạn nhanh và
nếu không thì là một giá trị chẵn, sao cho việc chia giá trị bộ đếm cho hai sẽ được
số thời gian gia hạn đã hoàn thành. Trong bất kỳ yêu cầu cập nhật nhất định nào,
bộ đếm phải chuyển từ chẵn sang lẻ rồi quay lại chẵn, do đó
cho biết thời gian ân hạn đã trôi qua. Vì vậy, nếu ban đầu
giá trị của bộ đếm là ZZ0002ZZ, bộ cập nhật phải đợi cho đến khi bộ đếm
đạt ít nhất giá trị ZZ0003ZZ. Bộ đếm này được quản lý bởi
chức năng truy cập sau:

#. ZZ0000ZZ, đánh dấu sự khởi đầu của một quá trình cấp tốc
   thời gian ân hạn.
#. ZZ0001ZZ, đánh dấu sự kết thúc của một ân sủng cấp tốc
   kỳ.
#. ZZ0002ZZ, thu được ảnh chụp nhanh của bộ đếm.
#. ZZ0003ZZ, trả về ZZ0004ZZ nếu hoàn thành nhanh
   thời gian gia hạn đã trôi qua kể từ cuộc gọi tương ứng tới
   ZZ0005ZZ.

Một lần nữa, chỉ có một yêu cầu trong một đợt nhất định thực sự cần thực hiện một
hoạt động trong thời gian ân hạn, có nghĩa là phải có một cách hiệu quả để
xác định yêu cầu nào trong số nhiều yêu cầu đồng thời sẽ bắt đầu thời hạn gia hạn
và rằng có một cách hiệu quả để giải quyết các yêu cầu còn lại
chờ thời gian gia hạn đó hoàn thành. Tuy nhiên, đó là chủ đề của
phần tiếp theo.

Khóa kênh và chờ/đánh thức
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cách tự nhiên để sắp xếp lô trình cập nhật nào sẽ bắt đầu
thời gian gia hạn nhanh là sử dụng cây kết hợp ZZ0000ZZ, như
được thực hiện bởi chức năng ZZ0001ZZ. Trình cập nhật đầu tiên
tương ứng với thời gian gia hạn nhất định đạt đến ZZ0002ZZ nhất định
cấu trúc ghi lại số thứ tự thời gian ân hạn mong muốn của nó trong
trường ZZ0003ZZ và di chuyển lên cấp độ tiếp theo trong cây.
Mặt khác, nếu trường ZZ0004ZZ đã chứa chuỗi
số cho thời gian gia hạn mong muốn hoặc số sau đó, trình cập nhật
chặn trên một trong bốn hàng đợi trong mảng ZZ0005ZZ, sử dụng
bit thứ hai từ dưới lên và bit thứ ba từ dưới lên làm chỉ mục. Một
Trường ZZ0006ZZ trong cấu trúc ZZ0007ZZ đồng bộ hóa quyền truy cập
tới các lĩnh vực này.

Một cây ZZ0000ZZ trống được hiển thị trong sơ đồ sau, với
các ô màu trắng đại diện cho trường ZZ0001ZZ và các ô màu đỏ
đại diện cho các phần tử của mảng ZZ0002ZZ.

.. kernel-figure:: Funnel0.svg

Sơ đồ tiếp theo cho thấy tình hình sau khi Nhiệm vụ A đến và
Nhiệm vụ B ở cấu trúc ZZ0000ZZ lá ngoài cùng bên trái và ngoài cùng bên phải,
tương ứng. Giá trị hiện tại của cấu trúc ZZ0001ZZ
Trường ZZ0002ZZ bằng 0, do đó, việc thêm ba và xóa
bit dưới cùng dẫn đến giá trị hai, cả hai tác vụ đều ghi vào
Trường ZZ0003ZZ của cấu trúc ZZ0004ZZ tương ứng của chúng:

.. kernel-figure:: Funnel1.svg

Mỗi Nhiệm vụ A và B sẽ chuyển lên cấu trúc ZZ0000ZZ gốc.
Giả sử Nhiệm vụ A thắng, ghi lại chuỗi thời gian gia hạn mong muốn
số và dẫn đến trạng thái hiển thị bên dưới:

.. kernel-figure:: Funnel2.svg

Nhiệm vụ A hiện tiến lên để bắt đầu thời gian gia hạn mới, trong khi Nhiệm vụ B chuyển sang
lên tới cấu trúc ZZ0000ZZ gốc và thấy rằng nó mong muốn
số thứ tự đã được ghi lại, chặn trên ZZ0001ZZ.

+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
+--------------------------------------------------------------------------------------- +
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
+--------------------------------------------------------------------------------------- +

Nếu Nhiệm vụ C và D cũng đến thời điểm này, chúng sẽ tính toán tương tự
số thứ tự thời gian gia hạn mong muốn và thấy rằng cả hai lá
Cấu trúc ZZ0000ZZ đã được ghi lại giá trị đó. Họ sẽ
do đó chặn cấu trúc ZZ0001ZZ tương ứng của chúng'
Các trường ZZ0002ZZ, như hiển thị bên dưới:

.. kernel-figure:: Funnel3.svg

Nhiệm vụ A hiện có được ZZ0001ZZ của cấu trúc ZZ0000ZZ và
bắt đầu thời gian gia hạn, tăng dần ZZ0002ZZ.
Do đó, nếu Nhiệm vụ E và F đến, chúng sẽ tính toán trình tự mong muốn
số 4 và sẽ ghi lại giá trị này như hình dưới đây:

.. kernel-figure:: Funnel4.svg

Nhiệm vụ E và F sẽ nhân rộng cây kết hợp ZZ0000ZZ, với
Chặn tác vụ F trên cấu trúc ZZ0001ZZ gốc và tác vụ E chờ
Nhiệm vụ A cần hoàn thành để có thể bắt đầu thời gian gia hạn tiếp theo. các
trạng thái kết quả như hình dưới đây:

.. kernel-figure:: Funnel5.svg

Sau khi thời gian gia hạn hoàn tất, Nhiệm vụ A sẽ bắt đầu đánh thức các nhiệm vụ
chờ thời gian ân hạn này hoàn thành, sẽ tăng
ZZ0000ZZ, mua lại ZZ0001ZZ và sau đó
phát hành ZZ0002ZZ. Điều này dẫn đến trạng thái sau:

.. kernel-figure:: Funnel6.svg

Sau đó, Nhiệm vụ E có thể nhận được ZZ0000ZZ và tăng dần
ZZ0001ZZ thành giá trị ba. Nếu nhiệm vụ mới G và H đến
và di chuyển lên cây kết hợp cùng lúc, trạng thái sẽ như sau
sau:

.. kernel-figure:: Funnel7.svg

Lưu ý rằng ba trong số hàng đợi của cấu trúc ZZ0000ZZ gốc hiện đã được
bị chiếm đóng. Tuy nhiên, tại một thời điểm nào đó, Nhiệm vụ A sẽ đánh thức các tác vụ bị chặn
trên hàng đợi ZZ0001ZZ, dẫn đến trạng thái sau:

.. kernel-figure:: Funnel8.svg

Quá trình thực thi sẽ tiếp tục với Nhiệm vụ E và H hoàn thành ân hạn của chúng
kinh nguyệt và thực hiện việc thức dậy của họ.

+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
+--------------------------------------------------------------------------------------- +

Sử dụng hàng đợi công việc
~~~~~~~~~~~~~~~~~

Trong các lần triển khai trước đó, nhiệm vụ yêu cầu gia hạn nhanh
cũng đã thúc đẩy nó hoàn thành. Cách tiếp cận đơn giản này đã
nhược điểm của việc cần tính đến các tín hiệu POSIX được gửi tới người dùng
các tác vụ, vì vậy các triển khai gần đây hơn sử dụng nhân Linux
hàng công việc (xem Tài liệu/core-api/workqueue.rst).

Tác vụ yêu cầu vẫn phản đối việc chụp nhanh và khóa kênh
đang xử lý, nhưng tác vụ đạt tới đỉnh của khóa kênh sẽ thực hiện một
ZZ0000ZZ (từ ZZ0001ZZ để
Workqueue kthread thực hiện quá trình xử lý trong thời gian gia hạn thực tế. Bởi vì
kthread trong hàng đợi công việc không chấp nhận tín hiệu POSIX, chờ trong thời gian gia hạn
việc xử lý không cần cho phép tín hiệu POSIX. Ngoài ra, cách tiếp cận này
cho phép đánh thức thời gian gia hạn cấp tốc trước đó bị chồng chéo
với việc xử lý cho thời gian gia hạn cấp tốc tiếp theo. Bởi vì có
chỉ có bốn bộ hàng chờ, cần phải đảm bảo rằng
thời gian đánh thức của thời gian gia hạn trước hoàn tất trước thời gian gia hạn tiếp theo
bắt đầu thức dậy. Điều này được xử lý bằng cách có bộ phận bảo vệ ZZ0002ZZ
xử lý thời gian gia hạn nhanh và bảo vệ ZZ0003ZZ
thức dậy. Điểm mấu chốt là ZZ0004ZZ không được phát hành cho đến khi
lần đánh thức đầu tiên đã hoàn tất, điều đó có nghĩa là ZZ0005ZZ
đã được mua lại vào thời điểm đó. Cách tiếp cận này đảm bảo rằng
việc đánh thức thời gian gia hạn trước đó có thể được thực hiện trong khi thời gian hiện tại
đang trong thời gian gia hạn nhưng những lần đánh thức này sẽ hoàn thành trước
thời gian ân hạn tiếp theo bắt đầu. Điều này có nghĩa là chỉ có ba hàng đợi
cần thiết, đảm bảo rằng bốn cái được cung cấp là đủ.

Cảnh báo gian hàng
~~~~~~~~~~~~~~

Việc đẩy nhanh thời gian gia hạn không có tác dụng gì để tăng tốc mọi thứ khi RCU
người đọc mất quá nhiều thời gian và do đó thời gian gia hạn được đẩy nhanh để kiểm tra
quầy hàng giống như thời gian gia hạn thông thường.

+--------------------------------------------------------------------------------------- +
ZZ0002ZZ
+--------------------------------------------------------------------------------------- +
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
+--------------------------------------------------------------------------------------- +

Các vòng lặp chức năng ZZ0000ZZ đang chờ
thời gian gia hạn cấp tốc sắp kết thúc nhưng có thời gian chờ được đặt thành hiện tại
RCU CPU thời gian cảnh báo ngừng hoạt động. Nếu vượt quá thời gian này, mọi CPU hoặc
Cấu trúc ZZ0001ZZ chặn thời gian gia hạn hiện tại sẽ được in.
Mỗi cảnh báo ngừng hoạt động sẽ dẫn đến một lần vượt qua vòng lặp khác, nhưng
lượt thứ hai và các lượt tiếp theo sử dụng thời gian dừng lâu hơn.

Hoạt động giữa lúc khởi động
~~~~~~~~~~~~~~~~~~

Việc sử dụng hàng đợi công việc có ưu điểm là thời gian gia hạn nhanh
mã không cần phải lo lắng về tín hiệu POSIX. Thật không may, nó có
nhược điểm tương ứng là hàng đợi công việc không thể được sử dụng cho đến khi chúng được
được khởi tạo, điều này không xảy ra cho đến một thời gian sau bộ lập lịch
sinh ra nhiệm vụ đầu tiên. Cho rằng có những phần của hạt nhân
thực sự muốn thực thi thời gian gia hạn trong thời gian “chết” giữa quá trình khởi động này
Zone”, thời gian gia hạn nhanh phải làm việc khác trong thời gian này.

Những gì họ làm là quay lại với thói quen cũ là yêu cầu
yêu cầu thúc đẩy nhiệm vụ trong thời gian gia hạn nhanh, như trường hợp trước đây
việc sử dụng hàng đợi công việc. Tuy nhiên, nhiệm vụ yêu cầu chỉ được yêu cầu
thúc đẩy thời gian gia hạn trong vùng chết giữa lúc khởi động. Trước khi khởi động giữa chừng, một
thời gian gia hạn đồng bộ là không hoạt động. Một thời gian sau khi khởi động giữa chừng,
hàng đợi công việc được sử dụng.

Thời gian gia hạn đồng bộ không phải SRCU không được giải quyết nhanh cũng phải hoạt động
bình thường trong quá trình khởi động. Việc này được xử lý bằng cách gây ra ân hạn không cấp tốc
khoảng thời gian để đi theo đường dẫn mã nhanh trong quá trình khởi động.

Mã hiện tại giả định rằng không có tín hiệu POSIX trong quá trình
vùng chết giữa khởi động. Tuy nhiên, nếu nhu cầu quá lớn về tín hiệu POSIX
nào đó phát sinh, có thể thực hiện những điều chỉnh phù hợp để giải quyết nhanh chóng
mã cảnh báo ngừng hoạt động. Một sự điều chỉnh như vậy sẽ khôi phục lại
kiểm tra cảnh báo ngừng hoạt động trước hàng đợi làm việc, nhưng chỉ trong thời gian chết giữa chừng
khu.

Với cải tiến này, thời gian gia hạn đồng bộ hiện có thể được sử dụng từ
bối cảnh nhiệm vụ hầu như bất kỳ lúc nào trong suốt vòng đời của kernel. Đó
là, ngoài một số điểm trong mã tạm dừng, ngủ đông hoặc tắt máy
con đường.

Bản tóm tắt
~~~~~~~

Thời gian gia hạn nhanh sử dụng cách tiếp cận theo số thứ tự để thúc đẩy
theo đợt, để một hoạt động trong thời gian gia hạn có thể phục vụ nhiều
yêu cầu. Khóa kênh được sử dụng để xác định hiệu quả một nhiệm vụ
của một nhóm đồng thời sẽ yêu cầu thời gian gia hạn. Tất cả thành viên của
nhóm sẽ chặn hàng đợi được cung cấp trong ZZ0000ZZ
cấu trúc. Việc xử lý thời gian gia hạn thực tế được thực hiện bởi một
hàng đợi công việc.

Các hoạt động của CPU-hotplug được ghi chú một cách lười biếng để ngăn chặn sự cần thiết của
đồng bộ hóa chặt chẽ giữa thời gian gia hạn nhanh và CPU-hotplug
hoạt động. Bộ đếm dyntick-idle được sử dụng để tránh gửi IPI tới
CPU nhàn rỗi, ít nhất là trong trường hợp thông thường. Sử dụng RCU-preempt và RCU-schedule
các trình xử lý IPI khác nhau và mã khác nhau để phản hồi trạng thái
những thay đổi được thực hiện bởi những trình xử lý đó, nhưng mặt khác lại sử dụng mã chung.

Các trạng thái không hoạt động được theo dõi bằng cây ZZ0000ZZ và một khi tất cả
trạng thái tĩnh cần thiết đã được báo cáo, tất cả các nhiệm vụ đang chờ đợi điều này
thời gian ân hạn cấp tốc được đánh thức. Một cặp mutexes được sử dụng để cho phép
thời gian đánh thức của một thời gian gia hạn để tiến hành đồng thời với thời gian gia hạn tiếp theo
quá trình xử lý kỳ.

Sự kết hợp các cơ chế này cho phép thời gian gia hạn được thực hiện nhanh chóng
hợp lý một cách hiệu quả. Tuy nhiên, đối với những nhiệm vụ không quan trọng về thời gian, thông thường
thay vào đó nên sử dụng thời gian ân hạn vì thời gian gia hạn của chúng dài hơn
cho phép mức độ phân khối cao hơn nhiều và do đó yêu cầu theo yêu cầu thấp hơn nhiều
chi phí chung.
