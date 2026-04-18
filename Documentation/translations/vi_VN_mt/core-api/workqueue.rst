.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/workqueue.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Hàng làm việc
=============

:Ngày: Tháng 9 năm 2010
:Tác giả: Tejun Heo <tj@kernel.org>
:Tác giả: Florian Mickler <florian@mickler.org>


Giới thiệu
============

Có nhiều trường hợp bối cảnh thực thi quy trình không đồng bộ
là cần thiết và hàng đợi công việc (wq) API được sử dụng phổ biến nhất
cơ chế cho những trường hợp như vậy.

Khi cần một bối cảnh thực thi không đồng bộ như vậy, một mục công việc
mô tả chức năng nào sẽ thực thi được đưa vào hàng đợi.  Một
luồng độc lập đóng vai trò là bối cảnh thực thi không đồng bộ.  các
hàng đợi được gọi là hàng làm việc và luồng được gọi là worker.

Trong khi có các mục công việc trên hàng đợi công việc, nhân viên sẽ thực hiện
các chức năng liên quan đến các hạng mục công việc lần lượt.  Khi nào
không còn mục công việc nào trên hàng công việc, nhân viên sẽ không hoạt động.
Khi một mục công việc mới được xếp vào hàng đợi, nhân viên sẽ bắt đầu thực thi lại.


Tại sao phải có hàng đợi công việc được quản lý đồng thời?
==================================

Trong triển khai wq ban đầu, wq đa luồng (MT) có một
luồng công nhân trên mỗi CPU và một luồng đơn (ST) wq có một công nhân
chủ đề trên toàn hệ thống.  Cần một MT wq duy nhất để giữ nguyên
số lượng công nhân bằng số lượng CPU.  Hạt nhân phát triển rất nhiều MT
người dùng wq qua các năm và với số lượng lõi CPU liên tục
tăng lên, một số hệ thống đã bão hòa dung lượng PID 32k mặc định khi chỉ khởi động
lên.

Mặc dù MT wq lãng phí rất nhiều tài nguyên nhưng mức độ xử lý đồng thời
cung cấp không đạt yêu cầu.  Hạn chế này là chung cho cả ST và
MT wq mặc dù ít nghiêm trọng hơn trên MT.  Mỗi wq duy trì riêng
hồ công nhân.  MT wq chỉ có thể cung cấp một ngữ cảnh thực thi cho mỗi CPU
trong khi một ST wq one cho toàn bộ hệ thống.  Các hạng mục công việc phải cạnh tranh
những bối cảnh thực thi rất hạn chế đó dẫn đến nhiều vấn đề khác nhau
bao gồm cả nguy cơ bế tắc xung quanh bối cảnh thực thi đơn lẻ.

Sự căng thẳng giữa mức độ đồng thời được cung cấp và tài nguyên
việc sử dụng cũng buộc người dùng phải thực hiện những đánh đổi không cần thiết như libata
chọn sử dụng ST wq để thăm dò PIO và chấp nhận một yêu cầu không cần thiết
hạn chế là không có hai PIO thăm dò nào có thể tiến triển cùng một lúc.  Như
MT wq không cung cấp khả năng xử lý đồng thời tốt hơn nhiều, những người dùng yêu cầu
mức độ đồng thời cao hơn, như async hoặc fscache, phải triển khai
nhóm chủ đề của riêng họ.

Hàng đợi công việc được quản lý đồng thời (cmwq) là sự triển khai lại của wq với
tập trung vào các mục tiêu sau.

* Duy trì khả năng tương thích với hàng công việc ban đầu API.

* Sử dụng nhóm công nhân thống nhất trên mỗi CPU được chia sẻ bởi tất cả wq để cung cấp
  mức độ đồng thời linh hoạt theo yêu cầu mà không lãng phí nhiều
  tài nguyên.

* Tự động điều chỉnh nhóm công nhân và mức độ đồng thời để
  người dùng API không cần phải lo lắng về những chi tiết như vậy.


Thiết kế
==========

Để dễ dàng thực hiện các chức năng không đồng bộ, một
sự trừu tượng, hạng mục công việc, được giới thiệu.

Một mục công việc là một cấu trúc đơn giản chứa một con trỏ tới hàm
nghĩa là được thực thi không đồng bộ.  Bất cứ khi nào một trình điều khiển hoặc hệ thống con
muốn một hàm được thực thi không đồng bộ thì nó phải thiết lập một công việc
mục trỏ đến chức năng đó và xếp hàng mục công việc đó trên một
hàng đợi công việc.

Một mục công việc có thể được thực thi trong một luồng hoặc trong ngữ cảnh BH (softirq).

Đối với hàng đợi công việc theo luồng, các luồng có mục đích đặc biệt, được gọi là [k]workers, thực thi
các chức năng ra khỏi hàng đợi, lần lượt từng chức năng. Nếu không có công việc nào được xếp hàng đợi,
các luồng công nhân trở nên nhàn rỗi. Các luồng công nhân này được quản lý trong
nhóm công nhân.

Thiết kế cmwq phân biệt giữa các hàng công việc hướng tới người dùng
hệ thống con và trình điều khiển xếp hàng các mục công việc trên và cơ chế phụ trợ
quản lý nhóm công nhân và xử lý các mục công việc được xếp hàng đợi.

Có hai nhóm công nhân, một nhóm dành cho các hạng mục công việc thông thường và nhóm còn lại
cho những cái có mức độ ưu tiên cao, cho mỗi CPU có thể và một số bổ sung
nhóm công nhân để phục vụ các mục công việc được xếp hàng đợi trên các hàng công việc không liên kết -
số lượng các nhóm hỗ trợ này là động.

Hàng đợi công việc của BH sử dụng cùng một khung. Tuy nhiên, vì chỉ có thể có một
bối cảnh thực thi đồng thời, không cần phải lo lắng về việc thực hiện đồng thời.
Mỗi nhóm công nhân trên mỗi CPU BH chỉ chứa một công nhân giả đại diện cho
bối cảnh thực thi BH. Hàng đợi làm việc BH có thể được coi là sự tiện lợi
giao diện với softirq.

Các hệ thống con và trình điều khiển có thể tạo và xếp hàng các mục công việc thông qua các
Workqueue API hoạt động theo cách họ thấy phù hợp. Họ có thể ảnh hưởng đến một số
các khía cạnh về cách thực hiện các mục công việc bằng cách đặt cờ trên
Workqueue họ đang đưa mục công việc vào. Những lá cờ này bao gồm
những thứ như địa phương CPU, giới hạn đồng thời, mức độ ưu tiên và hơn thế nữa.  Đến
có được cái nhìn tổng quan chi tiết, hãy tham khảo mô tả API của
ZZ0000ZZ bên dưới.

Khi một mục công việc được xếp hàng vào hàng công việc, nhóm công nhân đích sẽ là
được xác định theo các tham số hàng đợi và thuộc tính hàng đợi công việc
và được thêm vào danh sách công việc chung của nhóm công nhân.  Ví dụ,
trừ khi được ghi đè cụ thể, một mục công việc của hàng đợi công việc bị ràng buộc sẽ
được xếp hàng trong danh sách công việc của nhóm công nhân bình thường hoặc highpri
được liên kết với CPU mà nhà phát hành đang chạy.

Đối với bất kỳ việc triển khai nhóm luồng nào, việc quản lý mức đồng thời
(có bao nhiêu bối cảnh thực thi đang hoạt động) là một vấn đề quan trọng.  cmwq
cố gắng giữ sự đồng thời ở mức tối thiểu nhưng đủ.
Tối thiểu để tiết kiệm tài nguyên và đủ để hệ thống được sử dụng tại
hết công suất của nó.

Mỗi nhóm công nhân được liên kết với một CPU thực tế sẽ thực hiện đồng thời
quản lý bằng cách nối vào bộ lập lịch.  Nhóm công nhân được thông báo
bất cứ khi nào một công nhân đang hoạt động thức dậy hoặc ngủ và theo dõi tình hình
số lượng công nhân hiện có thể chạy được.  Nhìn chung, các hạng mục công việc được
dự kiến ​​sẽ không sử dụng CPU và tiêu thụ nhiều chu kỳ.  Điều đó có nghĩa
duy trì sự đồng thời vừa đủ để ngăn việc xử lý công việc khỏi
đình trệ nên là tối ưu.  Miễn là có một hoặc nhiều có thể chạy được
công nhân trên CPU, nhóm công nhân không bắt đầu thực thi một công việc mới
làm việc, nhưng khi nhân viên đang chạy cuối cùng đi ngủ, nó ngay lập tức
lên lịch cho một nhân viên mới để CPU không ngồi yên khi ở đó
đang chờ các hạng mục công việc.  Điều này cho phép sử dụng số lượng công nhân tối thiểu
mà không làm mất băng thông thực thi.

Giữ những công nhân nhàn rỗi xung quanh không tốn kém gì ngoài không gian bộ nhớ
đối với kthread, vì vậy cmwq sẽ giữ những cái không hoạt động một lúc trước khi tắt
họ.

Đối với hàng đợi công việc không liên kết, số lượng nhóm sao lưu là động.
Hàng đợi công việc không liên kết có thể được gán các thuộc tính tùy chỉnh bằng cách sử dụng
ZZ0000ZZ và hàng công việc sẽ tự động tạo
hỗ trợ nhóm công nhân phù hợp với các thuộc tính.  Trách nhiệm của
việc điều chỉnh mức độ đồng thời thuộc về người dùng.  Ngoài ra còn có một lá cờ
đánh dấu một wq bị ràng buộc để bỏ qua việc quản lý đồng thời.  Vui lòng tham khảo
phần API để biết chi tiết.

Bảo đảm tiến độ chuyển tiếp dựa vào việc người lao động có thể được tạo ra khi
cần nhiều bối cảnh thực thi hơn, do đó được đảm bảo
thông qua việc sử dụng nhân viên cứu hộ.  Tất cả các hạng mục công việc có thể được sử dụng
trên các đường dẫn mã xử lý việc lấy lại bộ nhớ được yêu cầu xếp hàng đợi trên
wq có nhân viên cứu hộ dành riêng để thực thi trong bộ nhớ
áp lực.  Nếu không, có thể sự bế tắc của nhóm công nhân đang chờ
để giải phóng bối cảnh thực thi.


Giao diện lập trình ứng dụng (API)
=======================================

ZZ0000ZZ phân bổ wq.  Bản gốc
Các chức năng ZZ0001ZZ không được dùng nữa và được lên lịch cho
loại bỏ.  ZZ0002ZZ có ba đối số - ZZ0003ZZ,
ZZ0004ZZ và ZZ0005ZZ.  ZZ0006ZZ là tên của wq và
cũng được sử dụng làm tên của chuỗi cứu hộ nếu có.

Một wq không còn quản lý tài nguyên thực thi nữa mà phục vụ như một miền cho
đảm bảo tiến độ chuyển tiếp, thuộc tính tuôn ra và mục công việc. ZZ0000ZZ
và ZZ0001ZZ kiểm soát cách thực hiện các mục công việc
tài nguyên, được lập lịch và thực hiện.


ZZ0000ZZ
---------

ZZ0000ZZ
  Hàng đợi làm việc BH có thể được coi là giao diện thuận tiện cho softirq. BH
  hàng công việc luôn theo CPU và tất cả các mục công việc BH được thực thi trong
  xếp hàng bối cảnh softirq của CPU theo thứ tự xếp hàng.

Tất cả hàng đợi công việc BH phải có 0 ZZ0000ZZ và ZZ0001ZZ là
  chỉ được phép bổ sung cờ.

Các hạng mục công việc của BH không thể ngủ được. Tất cả các tính năng khác như xếp hàng chậm,
  xả và hủy bỏ được hỗ trợ.

ZZ0000ZZ
  Các mục công việc được xếp hàng theo wq trên mỗi CPU được liên kết với một CPU cụ thể.
  Cờ này là lựa chọn đúng đắn khi vị trí CPU quan trọng.

Cờ này là phần bổ sung của ZZ0000ZZ.

ZZ0000ZZ
  Các mục công việc được xếp hàng vào một wq không liên kết được phục vụ bởi đặc biệt
  nhóm công nhân chứa các công nhân không bị ràng buộc với bất kỳ
  CPU cụ thể.  Điều này làm cho wq hoạt động như một sự thực thi đơn giản
  nhà cung cấp bối cảnh mà không có quản lý đồng thời.  Không bị ràng buộc
  nhóm công nhân cố gắng bắt đầu thực hiện các hạng mục công việc ngay khi
  có thể.  Wq không ràng buộc hy sinh địa phương nhưng hữu ích cho
  những trường hợp sau đây.

* Sự dao động rộng về yêu cầu mức độ đồng thời là
    mong đợi và sử dụng wq bị ràng buộc có thể sẽ tạo ra số lượng lớn
    hầu hết các công nhân không được sử dụng trên các CPU khác nhau với tư cách là nhà phát hành
    nhảy qua các CPU khác nhau.

* Khối lượng công việc chuyên sâu CPU chạy dài có thể tốt hơn
    được quản lý bởi bộ lập lịch hệ thống.

ZZ0000ZZ
  Một wq có thể đóng băng tham gia vào giai đoạn đóng băng của hệ thống
  đình chỉ hoạt động.  Các hạng mục công việc trên wq đã cạn kiệt và không còn
  mục công việc mới bắt đầu thực hiện cho đến khi tan băng.

ZZ0000ZZ
  Tất cả wq có thể được sử dụng trong đường dẫn lấy lại bộ nhớ ZZ0001ZZ
  đặt cờ này.  wq được đảm bảo có ít nhất một
  bối cảnh thực thi bất kể áp lực bộ nhớ.

ZZ0000ZZ
  Các mục công việc của một highpri wq được xếp hàng đợi vào highpri
  nhóm công nhân của cpu mục tiêu.  Nhóm công nhân Highpri là
  được phục vụ bởi các luồng công nhân với mức độ tốt đẹp được nâng cao.

Lưu ý rằng nhóm công nhân bình thường và highpri không tương tác với
  lẫn nhau.  Mỗi bên duy trì một nhóm công nhân riêng biệt và
  thực hiện quản lý đồng thời giữa các công nhân của mình.

ZZ0000ZZ
  Các hạng mục công việc của một wq chuyên sâu CPU không đóng góp vào
  mức độ đồng thời  Nói cách khác, CPU có thể chạy chuyên sâu
  các hạng mục công việc sẽ không ngăn cản các hạng mục công việc khác trong cùng
  nhóm công nhân từ khi bắt đầu thực hiện.  Điều này hữu ích cho việc ràng buộc
  các hạng mục công việc dự kiến sẽ sử dụng chu trình CPU để chúng
  việc thực hiện được điều chỉnh bởi bộ lập lịch hệ thống.

Mặc dù các hạng mục công việc chuyên sâu của CPU không góp phần vào
  mức độ đồng thời, việc bắt đầu thực thi chúng vẫn còn
  được điều chỉnh bởi quản lý đồng thời và có thể chạy được
  Các mục công việc không chuyên sâu về CPU có thể trì hoãn việc thực thi CPU
  hạng mục công việc chuyên sâu.

Cờ này vô nghĩa đối với wq không bị ràng buộc.


ZZ0000ZZ
--------------

ZZ0000ZZ xác định số lượng bối cảnh thực thi tối đa cho mỗi
CPU có thể được gán cho các hạng mục công việc của wq. Ví dụ, với
ZZ0001ZZ trong tổng số 16, tối đa 16 mục công việc của wq có thể được thực thi
đồng thời trên mỗi CPU. Đây luôn là thuộc tính cho mỗi CPU, ngay cả đối với
hàng đợi công việc không bị ràng buộc.

Giới hạn tối đa cho ZZ0000ZZ là 2048 và giá trị mặc định được sử dụng
khi 0 được chỉ định là 1024. Các giá trị này được chọn đủ cao
sao cho chúng không phải là yếu tố hạn chế trong khi cung cấp sự bảo vệ trong
những trường hợp bỏ trốn.

Số lượng hạng mục công việc đang hoạt động của một wq thường được quy định bởi
người dùng wq, cụ thể hơn là theo số lượng mục công việc mà người dùng
có thể xếp hàng cùng một lúc.  Trừ khi có nhu cầu cụ thể về
điều chỉnh số lượng mục công việc đang hoạt động, chỉ định '0' là
đề nghị.

Một số người dùng phụ thuộc vào thứ tự thực hiện nghiêm ngặt khi chỉ có một mục công việc
đang hoạt động tại bất kỳ thời điểm nào và các hạng mục công việc được xử lý trong
thứ tự xếp hàng. Trong khi sự kết hợp của ZZ0000ZZ của 1 và
ZZ0001ZZ đã từng đạt được hành vi này, đây không còn là
trường hợp. Thay vào đó hãy sử dụng alloc_ordered_workqueue().


Các kịch bản thực thi ví dụ
===========================

Các kịch bản thực thi ví dụ sau đây cố gắng minh họa cách cmwq
hoạt động dưới các cấu hình khác nhau.

Các mục công việc w0, w1, w2 được xếp hàng vào một wq q0 bị ràng buộc trên cùng một CPU.
 w0 đốt CPU trong 5 mili giây rồi ngủ trong 10 mili giây rồi đốt CPU trong 5 mili giây
 một lần nữa trước khi kết thúc.  w1 và w2 ghi CPU trong 5 mili giây rồi ngủ trong
 10 mili giây.

Bỏ qua tất cả các nhiệm vụ, công việc và chi phí xử lý khác và giả định
lập kế hoạch FIFO đơn giản, sau đây là một phiên bản được đơn giản hóa cao
các chuỗi sự kiện có thể xảy ra với wq ban đầu. ::

TIME TRONG MSECS EVENT
 0 w0 khởi động và đốt cháy CPU
 5 w0 ngủ
 15 w0 thức dậy và đốt cháy CPU
 20 w0 kết thúc
 20 w1 khởi động và đốt cháy CPU
 25 w1 ngủ
 35 w1 thức dậy và kết thúc
 35 w2 khởi động và đốt cháy CPU
 40 w2 ngủ
 50 w2 thức dậy và kết thúc

Và với cmwq có ZZ0000ZZ >= 3, ::

TIME TRONG MSECS EVENT
 0 w0 khởi động và đốt cháy CPU
 5 w0 ngủ
 5 w1 khởi động và đốt cháy CPU
 10 w1 ngủ
 10 w2 khởi động và đốt cháy CPU
 15 w2 ngủ
 15 w0 thức dậy và đốt cháy CPU
 20 w0 kết thúc
 20 w1 thức dậy và kết thúc
 25 w2 thức dậy và kết thúc

Nếu ZZ0000ZZ == 2, ::

TIME TRONG MSECS EVENT
 0 w0 khởi động và đốt cháy CPU
 5 w0 ngủ
 5 w1 khởi động và đốt cháy CPU
 10 w1 ngủ
 15 w0 thức dậy và đốt cháy CPU
 20 w0 kết thúc
 20 w1 thức dậy và kết thúc
 20 w2 khởi động và đốt cháy CPU
 25 w2 ngủ
 35 w2 thức dậy và kết thúc

Bây giờ, giả sử w1 và w2 được xếp hàng tới một wq q1 khác có
Bộ ZZ0000ZZ, ::

TIME TRONG MSECS EVENT
 0 w0 khởi động và đốt cháy CPU
 5 w0 ngủ
 5 w1 và w2 khởi động và ghi CPU
 10 w1 ngủ
 15 w2 ngủ
 15 w0 thức dậy và đốt cháy CPU
 20 w0 kết thúc
 20 w1 thức dậy và kết thúc
 25 w2 thức dậy và kết thúc


Hướng dẫn
==========

* Đừng quên sử dụng ZZ0000ZZ nếu wq có thể xử lý công việc
  các mục được sử dụng trong quá trình lấy lại bộ nhớ.  Mỗi wq với
  Bộ ZZ0001ZZ có bối cảnh thực thi dành riêng cho nó.  Nếu
  có sự phụ thuộc giữa nhiều mục công việc được sử dụng trong bộ nhớ
  đòi lại, chúng nên được xếp hàng để phân tách wq với nhau
  ZZ0002ZZ.

* Trừ khi yêu cầu đặt hàng nghiêm ngặt, không cần sử dụng ST wq.

* Trừ khi có nhu cầu cụ thể, sử dụng 0 cho @max_active là
  đề nghị.  Trong hầu hết các trường hợp sử dụng, mức độ đồng thời thường duy trì
  cũng dưới giới hạn mặc định.

* Một wq đóng vai trò như một miền để đảm bảo tiến độ chuyển tiếp
  (ZZ0000ZZ, thuộc tính tuôn ra và mục công việc. Mục công việc
  không liên quan đến việc lấy lại bộ nhớ và không cần phải
  được xóa như một phần của một nhóm hạng mục công việc và không yêu cầu bất kỳ
  thuộc tính đặc biệt, có thể sử dụng một trong các hệ thống wq.  không có
  sự khác biệt về đặc điểm thực thi giữa việc sử dụng wq chuyên dụng
  và một hệ thống wq.

Lưu ý: Nếu thứ gì đó có thể tạo ra nhiều hơn @max_active còn tồn đọng
  các hạng mục công việc (kiểm tra căng thẳng cho nhà sản xuất của bạn), nó có thể bão hòa một hệ thống
  wq và có khả năng dẫn đến bế tắc. Nó nên sử dụng cái riêng của nó
  hàng đợi công việc chuyên dụng thay vì hệ thống wq.

* Trừ khi các hạng mục công việc dự kiến sẽ tiêu tốn một lượng lớn CPU
  chu kỳ, sử dụng wq giới hạn thường có lợi do tăng
  mức độ địa phương trong hoạt động wq và thực hiện hạng mục công việc.


Phạm vi mối quan hệ
===============

Hàng đợi công việc không liên kết sẽ nhóm các CPU theo phạm vi quan hệ của nó để cải thiện
địa phương bộ đệm. Ví dụ: nếu một hàng công việc đang sử dụng mối quan hệ mặc định
phạm vi "cache_shard", nó sẽ nhóm các CPU thành các phân đoạn LLC phụ. Một hạng mục công việc
được xếp hàng đợi trên hàng đợi công việc sẽ được gán cho một nhân viên trên một trong các CPU
trong cùng phân đoạn với CPU đang phát hành.
Sau khi bắt đầu, nhân viên có thể được phép hoặc không được phép di chuyển ra ngoài phạm vi
tùy thuộc vào cài đặt ZZ0000ZZ của ống ngắm.

Workqueue hiện hỗ trợ các phạm vi mối quan hệ sau.

ZZ0000ZZ
  Sử dụng phạm vi trong tham số mô-đun ZZ0001ZZ
  luôn được đặt thành một trong các phạm vi bên dưới.

ZZ0000ZZ
  CPU không được nhóm lại. Một hạng mục công việc được phát hành trên một CPU được xử lý bởi một
  công nhân trên cùng một CPU. Điều này làm cho các hàng công việc không liên kết hoạt động theo từng CPU
  hàng đợi công việc mà không có sự quản lý đồng thời.

ZZ0000ZZ
  CPU được nhóm theo ranh giới SMT. Điều này thường có nghĩa là
  các luồng logic của mỗi lõi CPU vật lý được nhóm lại với nhau.

ZZ0000ZZ
  CPU được nhóm theo ranh giới bộ đệm. Bộ đệm cụ thể nào
  ranh giới được sử dụng được xác định bởi mã vòm. L3 được sử dụng trong rất nhiều
  trường hợp.

ZZ0000ZZ
  CPU được nhóm thành các phân đoạn LLC phụ, tối đa là ZZ0001ZZ
  lõi (mặc định 8, có thể điều chỉnh thông qua khởi động ZZ0002ZZ
  tham số). Các phân đoạn luôn được phân chia theo ranh giới lõi (nhóm SMT).
  Đây là phạm vi mối quan hệ mặc định.

ZZ0000ZZ
  CPU được nhóm theo ranh giới NUMA.

ZZ0000ZZ
  Tất cả các CPU được đặt trong cùng một nhóm. Workqueue không cần nỗ lực để xử lý một
  hạng mục công việc trên CPU gần với CPU đang phát hành.

Phạm vi mối quan hệ mặc định có thể được thay đổi bằng tham số mô-đun
ZZ0000ZZ và mối quan hệ của một hàng công việc cụ thể
phạm vi có thể được thay đổi bằng ZZ0001ZZ.

Nếu ZZ0000ZZ được đặt, hàng công việc sẽ có phạm vi mối quan hệ sau
các tệp giao diện liên quan trong ZZ0001ZZ của nó
thư mục.

ZZ0000ZZ
  Đọc để xem phạm vi mối quan hệ hiện tại. Viết để thay đổi.

Khi mặc định là phạm vi hiện tại, việc đọc tệp này cũng sẽ hiển thị
  phạm vi hiệu lực hiện tại trong ngoặc đơn, ví dụ: ZZ0000ZZ.

ZZ0000ZZ
  0 theo mặc định cho biết phạm vi mối quan hệ không nghiêm ngặt. Khi một công việc
  mục bắt đầu thực thi, hàng đợi công việc sẽ nỗ lực hết sức để đảm bảo
  rằng nhân viên đó nằm trong phạm vi mối quan hệ của nó, được gọi là
  hồi hương. Sau khi bắt đầu, người lập lịch có thể tự do di chuyển công nhân
  bất cứ nơi nào trong hệ thống khi nó thấy phù hợp. Điều này cho phép hưởng lợi từ phạm vi
  địa phương trong khi vẫn có thể sử dụng các CPU khác nếu cần thiết và
  có sẵn.

Nếu được đặt thành 1, tất cả công nhân trong phạm vi được đảm bảo luôn ở trong
  phạm vi. Điều này có thể hữu ích khi vượt qua phạm vi mối quan hệ có khác
  những tác động, ví dụ như về mức tiêu thụ điện năng hoặc khối lượng công việc
  sự cô lập. Phạm vi NUMA nghiêm ngặt cũng có thể được sử dụng để phù hợp với hàng công việc
  hành vi của hạt nhân cũ hơn.


Phạm vi mối quan hệ và hiệu suất
===============================

Sẽ là lý tưởng nếu hành vi của hàng đợi công việc không liên kết là tối ưu cho nhiều
phần lớn các trường hợp sử dụng mà không cần điều chỉnh thêm. Thật không may, trong hiện tại
hạt nhân, tồn tại sự cân bằng rõ rệt giữa địa phương và việc sử dụng
yêu cầu cấu hình rõ ràng khi hàng đợi công việc được sử dụng nhiều.

Địa phương cao hơn dẫn đến hiệu quả cao hơn, nơi có nhiều công việc được thực hiện hơn
cùng số chu kỳ CPU đã tiêu thụ. Tuy nhiên, địa phương cao hơn cũng có thể
gây ra mức sử dụng hệ thống tổng thể thấp hơn nếu các mục công việc không được dàn trải
đủ trong phạm vi mối quan hệ của các tổ chức phát hành. Hiệu suất sau đây
thử nghiệm với dm-crypt minh họa rõ ràng sự đánh đổi này.

Các bài kiểm tra được chạy trên CPU với 12 lõi/24 luồng được chia thành bốn L3
bộ nhớ đệm (AMD Ryzen 9 3900x). Tính năng tăng xung nhịp của CPU được tắt để đảm bảo tính nhất quán.
ZZ0000ZZ là thiết bị dm-crypt được tạo trên NVME SSD (Samsung 990 PRO) và
đã mở bằng ZZ0001ZZ với cài đặt mặc định.


Kịch bản 1: Có đủ số lượng người phát hành và công việc trải đều trên máy
-------------------------------------------------------------

Lệnh được sử dụng: ::

$ fio --filename=/dev/dm-0 --direct=1 --rw=randrw --bs=32k --ioengine=libaio \
    --iodeep=64 --runtime=60 --numjobs=24 --time_based --group_reporting \
    --name=iops-test-job --verify=sha512

Có 24 tổ chức phát hành, mỗi tổ chức phát hành 64 IO đồng thời. ZZ0000ZZ
làm cho ZZ0001ZZ tạo và đọc lại nội dung mỗi lần.
vấn đề địa phương thực thi giữa nhà phát hành và ZZ0002ZZ. Sau đây
là băng thông đọc và mức sử dụng CPU tùy thuộc vào mối quan hệ khác nhau
cài đặt phạm vi trên ZZ0003ZZ được đo trong năm lần chạy. Băng thông đang ở
MiBps và CPU sử dụng theo phần trăm.

.. list-table::
   :widths: 16 20 20
   :header-rows: 1

   * - Affinity
     - Bandwidth (MiBps)
     - CPU util (%)

   * - system
     - 1159.40 ±1.34
     - 99.31 ±0.02

   * - cache
     - 1166.40 ±0.89
     - 99.34 ±0.01

   * - cache (strict)
     - 1166.00 ±0.71
     - 99.35 ±0.01

Với đủ số tổ chức phát hành trải rộng trên toàn hệ thống, không có nhược điểm nào đối với
"bộ đệm", nghiêm ngặt hoặc ngược lại. Cả ba cấu hình đều bão hòa toàn bộ
nhưng máy cache-affine hoạt động tốt hơn 0,6% nhờ cải tiến
địa phương.


Kịch bản 2: Ít nhà phát hành hơn, đủ công việc để bão hòa
-----------------------------------------------------

Lệnh được sử dụng: ::

$ fio --filename=/dev/dm-0 --direct=1 --rw=randrw --bs=32k \
    --ioengine=libaio --iodeep=64 --runtime=60 --numjobs=8 \
    --time_based --group_reporting --name=iops-test-job --verify=sha512

Điểm khác biệt duy nhất so với kịch bản trước đó là ZZ0000ZZ. có
một phần ba số tổ chức phát hành nhưng vẫn có đủ tổng số công việc để bão hòa
hệ thống.

.. list-table::
   :widths: 16 20 20
   :header-rows: 1

   * - Affinity
     - Bandwidth (MiBps)
     - CPU util (%)

   * - system
     - 1155.40 ±0.89
     - 97.41 ±0.05

   * - cache
     - 1154.40 ±1.14
     - 96.15 ±0.09

   * - cache (strict)
     - 1112.00 ±4.64
     - 93.26 ±0.35

Công việc này là quá đủ để bão hòa hệ thống. Cả “hệ thống” và
"cache" gần như đã bão hòa máy nhưng chưa đầy đủ. "bộ đệm" đang sử dụng
ít CPU hơn nhưng hiệu quả tốt hơn đặt nó ở cùng băng thông như
"hệ thống".

Tám nhà phát hành di chuyển xung quanh bốn phạm vi bộ nhớ đệm L3 vẫn cho phép "bộ nhớ đệm
(nghiêm ngặt)" để làm bão hòa phần lớn máy nhưng mất khả năng bảo toàn công
hiện đang bắt đầu bị ảnh hưởng với việc mất băng thông 3,7%.


Kịch bản 3: Thậm chí còn ít tổ chức phát hành hơn, không đủ công việc để bão hòa
-----------------------------------------------------------

Lệnh được sử dụng: ::

$ fio --filename=/dev/dm-0 --direct=1 --rw=randrw --bs=32k \
    --ioengine=libaio --iodeep=64 --runtime=60 --numjobs=4 \
    --time_based --group_reporting --name=iops-test-job --verify=sha512

Một lần nữa, sự khác biệt duy nhất là ZZ0000ZZ. Với số lượng tổ chức phát hành
giảm xuống còn bốn, giờ không còn đủ công việc để bão hòa toàn bộ hệ thống
và băng thông trở nên phụ thuộc vào độ trễ hoàn thành.

.. list-table::
   :widths: 16 20 20
   :header-rows: 1

   * - Affinity
     - Bandwidth (MiBps)
     - CPU util (%)

   * - system
     - 993.60 ±1.82
     - 75.49 ±0.06

   * - cache
     - 973.40 ±1.52
     - 74.90 ±0.07

   * - cache (strict)
     - 828.20 ±4.49
     - 66.84 ±0.29

Giờ đây, sự cân bằng giữa địa phương và việc sử dụng đã rõ ràng hơn. hiển thị "bộ nhớ đệm"
Mất băng thông 2% so với "hệ thống" và "bộ đệm (cấu trúc)" chiếm tới 20%.


Kết luận và khuyến nghị
------------------------------

Trong các thử nghiệm trên, lợi thế hiệu quả của mối quan hệ "bộ đệm"
phạm vi trên "hệ thống" tuy nhất quán và đáng chú ý nhưng lại nhỏ. Tuy nhiên,
tác động phụ thuộc vào khoảng cách giữa các phạm vi và có thể nhiều hơn
được phát âm trong các bộ xử lý có cấu trúc liên kết phức tạp hơn.

Mặc dù việc mất khả năng bảo toàn công việc trong một số trường hợp nhất định có thể gây tổn hại nhưng nó có tác động rất lớn
tốt hơn "bộ đệm (nghiêm ngặt)" và tối đa hóa việc sử dụng hàng đợi công việc là
dù sao cũng khó có thể là trường hợp phổ biến. Như vậy, "bộ đệm" là mặc định
phạm vi mối quan hệ cho các nhóm không liên kết.

* Vì không có một tùy chọn nào phù hợp cho hầu hết các trường hợp, nên cách sử dụng hàng đợi công việc
  có thể tiêu thụ một lượng đáng kể CPU được khuyến nghị định cấu hình
  hàng công việc sử dụng ZZ0000ZZ và/hoặc kích hoạt
  ZZ0001ZZ.

* Hàng đợi công việc không liên kết có phạm vi quan hệ "cpu" nghiêm ngặt hoạt động giống như
  Hàng đợi công việc trên mỗi CPU ZZ0000ZZ. Không có lợi ích thực sự nào cho
  thứ hai và một hàng công việc không bị ràng buộc mang lại sự linh hoạt hơn rất nhiều.

* Phạm vi mối quan hệ được giới thiệu trong Linux v6.5. Để bắt chước trước đó
  hành vi, hãy sử dụng phạm vi quan hệ "numa" nghiêm ngặt.

* Có thể mất khả năng bảo toàn công việc trong phạm vi mối quan hệ không nghiêm ngặt
  bắt nguồn từ bộ lập lịch. Không có lý do lý thuyết nào giải thích tại sao
  kernel sẽ không thể làm điều đúng đắn và duy trì
  bảo toàn công việc trong hầu hết các trường hợp. Như vậy, có thể trong tương lai
  cải tiến bộ lập lịch có thể làm cho hầu hết các điều chỉnh này không cần thiết.


Kiểm tra cấu hình
=======================

Sử dụng tools/workqueue/wq_dump.py để kiểm tra mối quan hệ CPU không liên kết
cấu hình, nhóm công nhân và cách ánh xạ hàng đợi công việc tới nhóm: ::

$ công cụ/workqueue/wq_dump.py
  Phạm vi mối quan hệ
  =================
  wq_unbound_cpumask=0000000f

CPU
    nr_pod 4
    pod_cpus [0]=00000001 [1]=00000002 [2]=00000004 [3]=00000008
    pod_node [0]=0 [1]=0 [2]=1 [3]=1
    cpu_pod [0]=0 [1]=1 [2]=2 [3]=3

SMT
    nr_pod 4
    pod_cpus [0]=00000001 [1]=00000002 [2]=00000004 [3]=00000008
    pod_node [0]=0 [1]=0 [2]=1 [3]=1
    cpu_pod [0]=0 [1]=1 [2]=2 [3]=3

CACHE (mặc định)
    nr_pod 2
    pod_cpus [0]=00000003 [1]=0000000c
    pod_node [0]=0 [1]=1
    cpu_pod [0]=0 [1]=0 [2]=1 [3]=1

NUMA
    nr_pod 2
    pod_cpus [0]=00000003 [1]=0000000c
    pod_node [0]=0 [1]=1
    cpu_pod [0]=0 [1]=0 [2]=1 [3]=1

SYSTEM
    nr_pod 1
    pod_cpus [0]=0000000f
    pod_node [0]=-1
    cpu_pod [0]=0 [1]=0 [2]=0 [3]=0

Nhóm công nhân
  =============
  pool[00] ref= 1 nice= 0 nhàn rỗi/workers= 4/ 4 cpu= 0
  pool[01] ref= 1 nice=-20 nhàn rỗi/workers= 2/ 2 cpu= 0
  pool[02] ref= 1 nice= 0 nhàn rỗi/workers= 4/ 4 cpu= 1
  pool[03] ref= 1 nice=-20 nhàn rỗi/workers= 2/ 2 cpu= 1
  pool[04] ref= 1 nice= 0 nhàn rỗi/workers= 4/ 4 cpu= 2
  pool[05] ref= 1 nice=-20 nhàn rỗi/workers= 2/ 2 cpu= 2
  pool[06] ref= 1 nice= 0 nhàn rỗi/workers= 3/ 3 cpu= 3
  pool[07] ref= 1 nice=-20 nhàn rỗi/công nhân= 2/ 2 cpu= 3
  pool[08] ref=42 nice= 0 nhàn rỗi/công nhân= 6/ 6 cpus=0000000f
  pool[09] ref=28 nice= 0 nhàn rỗi/công nhân= 3/ 3 cpus=00000003
  pool[10] ref=28 nice= 0 nhàn rỗi/công nhân= 17/ 17 cpus=0000000c
  pool[11] ref= 1 nice=-20 nhàn rỗi/công nhân= 1/ 1 cpus=0000000f
  pool[12] ref= 2 nice=-20 nhàn rỗi/công nhân= 1/ 1 cpus=00000003
  pool[13] ref= 2 nice=-20 nhàn rỗi/công nhân= 1/ 1 cpus=0000000c

Hàng công việc CPU -> nhóm
  =======================
  [ hàng đợi công việc \ CPU 0 1 2 3 dfl]
  sự kiện percpu 0 2 4 6
  events_highpri percpu 1 3 5 7
  events_long percpu 0 2 4 6
  events_unbound Không liên kết 9 9 10 10 8
  events_freezable percpu 0 2 4 6
  events_power_performance percpu 0 2 4 6
  events_freezable_pwr_ef mỗi CPU 0 2 4 6
  rcu_gp percpu 0 2 4 6
  rcu_par_gp percpu 0 2 4 6
  slub_flushwq percpu 0 2 4 6
  netns đã đặt hàng 8 8 8 8 8
  ...

Xem thông báo trợ giúp của lệnh để biết thêm thông tin.


Giám sát
==========

Sử dụng tools/workqueue/wq_monitor.py để giám sát các hoạt động của hàng đợi công việc: ::

sự kiện $ tools/workqueue/wq_monitor.py
                              tổng thời gian CPU bị ảnh hưởng CPUhog CMW/RPR mayday được giải cứu
  sự kiện 18545 0 6.1 0 5 - -
  sự kiện_highpri 8 0 0,0 0 0 - -
  sự kiện_dài 3 0 0,0 0 0 - -
  events_unbound 38306 0 0,1 - 7 - -
  events_freezable 0 0 0.0 0 0 - -
  events_power_factor 29598 0 0,2 0 0 - -
  events_freezable_pwr_ef 10 0 0.0 0 0 - -
  sock_diag_events 0 0 0.0 0 0 - -

tổng thời gian CPU bị ảnh hưởng CPUhog CMW/RPR mayday được giải cứu
  sự kiện 18548 0 6.1 0 5 - -
  sự kiện_highpri 8 0 0,0 0 0 - -
  sự kiện_dài 3 0 0,0 0 0 - -
  events_unbound 38322 0 0,1 - 7 - -
  events_freezable 0 0 0.0 0 0 - -
  events_power_factor 29603 0 0,2 0 0 - -
  events_freezable_pwr_ef 10 0 0.0 0 0 - -
  sock_diag_events 0 0 0.0 0 0 - -

  ...

Xem thông báo trợ giúp của lệnh để biết thêm thông tin.


Gỡ lỗi
=========

Bởi vì các chức năng công việc được thực thi bởi các luồng công việc chung
có một vài thủ thuật cần thiết để làm sáng tỏ hành vi sai trái
người dùng hàng đợi công việc.

Các luồng công nhân hiển thị trong danh sách quy trình dưới dạng: ::

gốc 5671 0,0 0,0 0 0 ?        S 12:07 0:00 [kworker/0:1]
  gốc 5672 0,0 0,0 0 0 ?        S 12:07 0:00 [kworker/1:2]
  gốc 5673 0,0 0,0 0 0 ?        S 12:12 0:00 [kworker/0:0]
  gốc 5674 0,0 0,0 0 0 ?        S 12:13 0:00 [kworker/1:0]

Nếu công nhân phát điên (dùng quá nhiều cpu), có hai loại
của các vấn đề có thể xảy ra:

1. Một cái gì đó đang được lên kế hoạch liên tiếp
	2. Một hạng mục công việc tiêu tốn nhiều chu kỳ CPU

Cái đầu tiên có thể được theo dõi bằng cách sử dụng dấu vết: ::

$ echo Workqueue:workqueue_queue_work > /sys/kernel/tracing/set_event
	$ cat /sys/kernel/tracing/trace_pipe > out.txt
	(đợi vài giây)
	^C

Nếu có thứ gì đó đang bận lặp lại trong hàng đợi công việc, thì nó sẽ chiếm ưu thế
đầu ra và người phạm tội có thể được xác định bằng hạng mục công việc
chức năng.

Đối với loại vấn đề thứ hai, có thể chỉ cần kiểm tra
dấu vết ngăn xếp của luồng công nhân vi phạm. ::

$ cat /proc/THE_OFFENDING_KWORKER/stack

Chức năng của mục công việc sẽ hiển thị rõ ràng trong ngăn xếp
dấu vết.


Điều kiện không tái nhập
=========================

Hàng đợi công việc đảm bảo rằng một mục công việc không thể được nhập lại nếu:
các điều kiện được giữ nguyên sau khi một hạng mục công việc được xếp vào hàng đợi:

1. Chức năng làm việc không bị thay đổi.
        2. Không ai xếp hàng công việc này vào hàng công việc khác.
        3. Mục công việc chưa được khởi tạo lại.

Nói cách khác, nếu đáp ứng được các điều kiện trên thì hạng mục công trình được đảm bảo
được thực hiện bởi tối đa một công nhân trên toàn hệ thống tại bất kỳ thời điểm nào.

Lưu ý rằng việc yêu cầu mục công việc (vào cùng một hàng đợi) trong chức năng tự
không phá vỡ các điều kiện này, vì vậy nó an toàn để thực hiện. Nếu không, hãy thận trọng
cần thiết khi phá vỡ các điều kiện bên trong hàm công việc.


Tài liệu tham khảo nội tuyến hạt nhân
======================================

.. kernel-doc:: include/linux/workqueue.h

.. kernel-doc:: kernel/workqueue.c
