.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/bfq-iosched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
BFQ (Xếp hàng hội chợ ngân sách)
================================

BFQ là bộ lập lịch I/O chia sẻ theo tỷ lệ, với một số tính năng bổ sung
khả năng có độ trễ thấp. Ngoài sự hỗ trợ của cgroups (blkio hoặc io
bộ điều khiển), các tính năng chính của BFQ là:

- BFQ đảm bảo khả năng đáp ứng ứng dụng và hệ thống cao, đồng thời
  độ trễ thấp cho các ứng dụng nhạy cảm với thời gian, chẳng hạn như âm thanh hoặc video
  người chơi;
- BFQ phân phối băng thông, không chỉ thời gian, giữa các tiến trình hoặc
  các nhóm (chuyển về phân bổ thời gian khi cần thiết để giữ
  thông lượng cao).

Trong cấu hình mặc định, BFQ ưu tiên độ trễ hơn
thông lượng. Vì vậy, khi cần để đạt được độ trễ thấp hơn, BFQ sẽ xây dựng
lịch trình có thể dẫn đến thông lượng thấp hơn. Nếu chính hoặc duy nhất của bạn
mục tiêu, đối với một thiết bị nhất định, là đạt được mức tối đa có thể
thông lượng mọi lúc, sau đó tắt tất cả các phương pháp phỏng đoán có độ trễ thấp
đối với thiết bị đó, bằng cách đặt low_latency thành 0. Xem Phần 3 để biết
chi tiết về cách định cấu hình BFQ để có được sự cân bằng mong muốn giữa
độ trễ và thông lượng hoặc về cách tối đa hóa thông lượng.

Như mọi bộ lập lịch I/O, BFQ bổ sung thêm một số chi phí cho mỗi yêu cầu I/O
xử lý. Để đưa ra ý tưởng về chi phí chung này, tổng cộng,
thời gian xử lý theo yêu cầu, được bảo vệ bằng một khóa của BFQ---tức là
tổng số thời gian thực hiện của việc chèn, gửi yêu cầu và
móc hoàn thành---ví dụ: 1,9 us trên Intel Core i7-2760QM@2.40GHz
(ngày CPU dành cho máy tính xách tay; thời gian được đo bằng mã đơn giản
thiết bị đo đạc và sử dụng tập lệnh thông lượng-sync.sh của S
bộ [1], ở chế độ lập hồ sơ hiệu suất). Để đưa kết quả này vào
bối cảnh, tổng thời gian thực hiện theo yêu cầu, được bảo vệ bằng một khóa
trong số bộ lập lịch I/O nhẹ nhất hiện có trong blk-mq, mq-deadline, là 0,7
chúng tôi (thời hạn mq là ~800 LOC, so với ~10500 LOC đối với BFQ).

Chi phí lập kế hoạch tiếp tục giới hạn IOPS tối đa mà CPU có thể
quá trình (đã bị giới hạn bởi việc thực hiện phần còn lại của I/O
ngăn xếp). Để đưa ra ý tưởng về các giới hạn với BFQ, ở mức chậm hoặc trung bình
Các CPU, trước tiên, đây là các giới hạn của BFQ đối với ba CPU khác nhau, bật,
tương ứng là một máy tính xách tay trung bình, một máy tính để bàn cũ và một máy tính nhúng giá rẻ.
hệ thống, trong trường hợp hỗ trợ phân cấp đầy đủ được kích hoạt (tức là
CONFIG_BFQ_GROUP_IOSCHED được đặt), nhưng CONFIG_BFQ_CGROUP_DEBUG thì không
bộ (Phần 4-2):
- Intel i7-4850HQ: 400 KIOPS
-AMD A8-3850: 250 KIOPS
- ARM CortexTM-A53 Octa-core: 80 KIOPS

Nếu CONFIG_BFQ_CGROUP_DEBUG được đặt (và tất nhiên là có đầy đủ thứ bậc
hỗ trợ được bật), thì thông lượng bền vững với BFQ
giảm vì tất cả số liệu thống kê blkio.bfq* được tạo và cập nhật
(Phần 4-2). Đối với BFQ, điều này dẫn đến mức tối đa sau
thông lượng bền vững, trên cùng hệ thống như trên:
- Intel i7-4850HQ: 310 KIOPS
-AMD A8-3850: 200 KIOPS
- ARM CortexTM-A53 Octa-core: 56 KIOPS

BFQ cũng hoạt động với các thiết bị nhiều hàng đợi.

.. The table of contents follow. Impatients can just jump to Section 3.

.. CONTENTS

   1. When may BFQ be useful?
    1-1 Personal systems
    1-2 Server systems
   2. How does BFQ work?
   3. What are BFQ's tunables and how to properly configure BFQ?
   4. BFQ group scheduling
    4-1 Service guarantees provided
    4-2 Interface

1. Khi nào BFQ có thể hữu ích?
==============================

BFQ cung cấp các lợi ích sau trên hệ thống cá nhân và máy chủ.

1-1 Hệ thống cá nhân
--------------------

Độ trễ thấp cho các ứng dụng tương tác
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Bất kể khối lượng công việc nền thực tế như thế nào, BFQ đảm bảo rằng, đối với
các tác vụ tương tác, thiết bị lưu trữ hầu như phản ứng nhanh như thể
nó đã nhàn rỗi. Ví dụ: ngay cả khi một hoặc nhiều điều sau đây
khối lượng công việc nền đang được thực thi:

- một hoặc nhiều tệp lớn đang được đọc, ghi hoặc sao chép,
- một cây tệp nguồn đang được biên dịch,
- một hoặc nhiều máy ảo đang thực hiện I/O,
- đang cập nhật phần mềm,
- daemon lập chỉ mục đang quét các hệ thống tập tin và cập nhật chúng
  cơ sở dữ liệu,

khởi động một ứng dụng hoặc tải một tập tin từ bên trong một ứng dụng
mất khoảng thời gian tương tự như khi thiết bị lưu trữ không hoạt động. Như một
so sánh với CFQ, NOOP hoặc DEADLINE và trong cùng điều kiện,
các ứng dụng có độ trễ cao hoặc thậm chí không phản hồi
cho đến khi khối lượng công việc nền chấm dứt (cũng như trên SSD).

Độ trễ thấp cho các ứng dụng thời gian thực mềm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Ngoài ra các ứng dụng thời gian thực mềm, chẳng hạn như âm thanh và video
người chơi/người truyền phát, tận hưởng độ trễ thấp và tỷ lệ rớt thấp, bất kể
khối lượng công việc I/O nền. Kết quả là, các ứng dụng này
hầu như không gặp phải bất kỳ trục trặc nào do khối lượng công việc nền.

Tốc độ cao hơn cho các tác vụ phát triển mã
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nếu một số khối lượng công việc bổ sung được thực hiện song song thì
BFQ thực thi các thành phần liên quan đến I/O của quá trình phát triển mã điển hình
các tác vụ (biên dịch, kiểm tra, hợp nhất, v.v.) nhanh hơn nhiều so với CFQ,
NOOP hoặc DEADLINE.

Thông lượng cao
^^^^^^^^^^^^^^^

Trên đĩa cứng, BFQ đạt được thông lượng cao hơn tới 30% so với CFQ và
thông lượng cao hơn tới 150% so với DEADLINE và NOOP, với tất cả
khối lượng công việc tuần tự được xem xét trong các thử nghiệm của chúng tôi. Với khối lượng công việc ngẫu nhiên,
và với tất cả khối lượng công việc trên các thiết bị dựa trên flash, BFQ đạt được,
thay vào đó, có cùng thông lượng như các bộ lập lịch khác.

Đảm bảo tính công bằng, băng thông và độ trễ mạnh mẽ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

BFQ phân phối thông lượng thiết bị chứ không chỉ thời gian của thiết bị,
giữa các ứng dụng có giới hạn I/O tương ứng với trọng số của chúng, với bất kỳ
khối lượng công việc và bất kể các thông số thiết bị. Từ những băng thông này
đảm bảo, có thể tính toán độ trễ chặt chẽ trên mỗi I/O-yêu cầu
đảm bảo bằng một công thức đơn giản. Nếu không được cấu hình cho dịch vụ nghiêm ngặt
đảm bảo, BFQ chuyển sang chia sẻ tài nguyên theo thời gian (chỉ) cho
các ứng dụng có thể gây ra tổn thất thông lượng.

1-2 Hệ thống máy chủ
--------------------

Hầu hết các lợi ích cho hệ thống máy chủ đều xuất phát từ cùng một dịch vụ
tính chất như trên. Đặc biệt, bất kể có bổ sung hay không,
khối lượng công việc nặng có thể đang được phục vụ, BFQ đảm bảo:

* truyền phát âm thanh và video với độ giật và giảm bằng 0 hoặc rất thấp
  tỷ lệ;

* truy xuất nhanh các trang WEB và các đối tượng được nhúng;

* ghi dữ liệu theo thời gian thực trong các ứng dụng bán phá giá trực tiếp (ví dụ:
  ghi nhật ký gói);

* khả năng đáp ứng trong việc truy cập cục bộ và từ xa vào máy chủ.


2. BFQ hoạt động như thế nào?
=============================

BFQ là bộ lập lịch I/O chia sẻ theo tỷ lệ, có cấu trúc chung,
cộng với rất nhiều mã, được mượn từ CFQ.

- Mỗi tiến trình thực hiện I/O trên một thiết bị đều gắn liền với một trọng số và một
  ZZ0000ZZ.

- BFQ cấp quyền truy cập độc quyền vào thiết bị trong một thời gian cho một hàng đợi
  (xử lý) tại một thời điểm và triển khai mô hình dịch vụ này bằng cách
  liên kết mỗi hàng đợi với ngân sách, được đo bằng số lượng
  các lĩnh vực.

- Sau khi hàng đợi được cấp quyền truy cập vào thiết bị, ngân sách của
    hàng đợi được giảm đi, trên mỗi lần gửi yêu cầu, theo kích thước của
    yêu cầu.

- Hàng đợi trong dịch vụ đã hết hạn, tức là dịch vụ của nó bị tạm dừng,
    chỉ khi một trong các sự kiện sau xảy ra: 1) hàng đợi kết thúc
    ngân sách của nó, 2) hàng đợi trống, 3) "hết thời gian chờ ngân sách".

- Thời gian chờ ngân sách sẽ ngăn các quá trình thực hiện I/O ngẫu nhiên từ
      cầm máy quá lâu và giảm đáng kể
      thông lượng.

- Trên thực tế, như trong CFQ, một hàng đợi được liên kết với một tiến trình phát hành
      yêu cầu đồng bộ hóa có thể không hết hạn ngay lập tức khi nó trống. trong
      Ngược lại, BFQ có thể làm cho thiết bị không hoạt động trong một khoảng thời gian ngắn,
      cho quá trình cơ hội tiếp tục được phục vụ nếu nó có vấn đề
      một yêu cầu mới kịp thời. Thiết bị chạy không tải thường tăng cường
      thông lượng trên các thiết bị quay và trên nền tảng flash không xếp hàng
      thiết bị, nếu các tiến trình thực hiện I/O đồng bộ và tuần tự. trong
      Ngoài ra, trong BFQ, thiết bị chạy không tải cũng là công cụ trong
      đảm bảo tỷ lệ thông lượng mong muốn cho các quy trình
      đưa ra yêu cầu đồng bộ hóa (xem mô tả của slice_idle
      có thể điều chỉnh trong tài liệu này, hoặc [1, 2] để biết thêm chi tiết).

- Đối với trường hợp chạy không tải để đảm bảo dịch vụ, nếu có nhiều
	các tiến trình đang cạnh tranh giành thiết bị cùng một lúc, nhưng
	tất cả các tiến trình và nhóm đều có cùng trọng số thì BFQ
	đảm bảo phân phối thông lượng dự kiến mà không bao giờ
	thiết bị đang chạy không tải. Do đó, thông lượng càng cao càng tốt trong
	kịch bản chung này.

- Trên bộ lưu trữ dựa trên flash với các lệnh xếp hàng bên trong
       (thường là NCQ), việc thiết bị chạy không tải luôn gây bất lợi
       đến thông lượng. Vì vậy, với các thiết bị này, BFQ thực hiện chế độ chạy không tải
       chỉ khi thực sự cần thiết để đảm bảo dịch vụ, tức là đối với
       đảm bảo độ trễ hoặc tính công bằng thấp. Trong những trường hợp này, tổng thể
       thông lượng có thể chưa tối ưu. Hiện tại không có giải pháp nào để
       cung cấp cả sự đảm bảo dịch vụ mạnh mẽ và thông lượng tối ưu
       trên các thiết bị có hàng đợi nội bộ.

- Nếu bật chế độ độ trễ thấp (cấu hình mặc định), BFQ
    thực hiện một số chẩn đoán đặc biệt để phát hiện tính tương tác và phần mềm
    các ứng dụng thời gian thực (ví dụ: trình phát/truyền phát video hoặc âm thanh),
    và để giảm độ trễ của chúng. Hành động quan trọng nhất được thực hiện để
    đạt được mục tiêu này là cung cấp cho các hàng đợi liên kết với những
    ứng dụng nhiều hơn mức chia sẻ hợp lý của chúng trên thiết bị
    thông lượng. Để cho ngắn gọn, chúng tôi gọi nó chỉ là "tăng trọng lượng"
    tập hợp các hành động được BFQ thực hiện để đặc quyền cho các hàng đợi này. trong
    đặc biệt, BFQ cung cấp một hình thức tăng cân nhẹ nhàng hơn cho
    các ứng dụng tương tác và một hình thức mạnh mẽ hơn cho thời gian thực mềm
    ứng dụng.

- BFQ tự động tắt chế độ chạy không tải đối với các hàng đợi được sinh ra trong một loạt
    sáng tạo hàng đợi. Trong thực tế, những hàng đợi này thường được liên kết với
    các quy trình ứng dụng và dịch vụ được hưởng lợi chủ yếu
    từ thông lượng cao. Ví dụ như systemd trong khi khởi động hoặc git
    grep.

- Là CFQ, BFQ hợp nhất các hàng đợi thực hiện I/O xen kẽ, tức là
    thực hiện I/O ngẫu nhiên mà chủ yếu trở thành tuần tự nếu
    sáp nhập. Khác với CFQ, BFQ đạt được mục tiêu này với nhiều
    cơ chế phản ứng, được gọi là Hợp nhất hàng đợi sớm (EQM). EQM là vậy
    đáp ứng trong việc phát hiện I/O xen kẽ (các quy trình hợp tác),
    rằng nó cho phép BFQ đạt được thông lượng cao, bằng cách xếp hàng
    hợp nhất, ngay cả đối với các hàng đợi mà CFQ cần một hàng đợi khác
    cơ chế ưu tiên để đạt được thông lượng cao. Như vậy, EQM là một
    cơ chế thống nhất để đạt được thông lượng cao với sự xen kẽ
    Tôi/O.

- Hàng đợi được lên lịch theo một biến thể của WF2Q+, được đặt tên
    B-WF2Q+ và được triển khai bằng cách sử dụng cây rb tăng cường để duy trì
    O(log N) độ phức tạp tổng thể.  Xem [2] để biết thêm chi tiết. B-WF2Q+ là
    cũng sẵn sàng cho việc lập kế hoạch phân cấp, chi tiết trong Phần 4.

- B-WF2Q+ đảm bảo độ lệch chặt chẽ so với lý tưởng,
    dịch vụ hoàn toàn công bằng và trơn tru. Đặc biệt, B-WF2Q+
    đảm bảo rằng mỗi hàng đợi nhận được một phần của thiết bị
    thông lượng tỷ lệ thuận với trọng lượng của nó, ngay cả khi thông lượng
    dao động và không phụ thuộc vào: thông số thiết bị, dòng điện
    khối lượng công việc và ngân sách được giao cho hàng đợi.

- Tài sản cuối cùng, độc lập với ngân sách (mặc dù có lẽ
    phản trực giác ngay từ đầu) chắc chắn là có lợi, vì
    những lý do sau:

- Đầu tiên, với bất kỳ bộ lập lịch chia sẻ theo tỷ lệ nào, mức tối đa
      độ lệch so với một dịch vụ lý tưởng tỷ lệ thuận với
      ngân sách tối đa (lát) được chỉ định cho hàng đợi. Kết quả là,
      BFQ có thể giữ chặt độ lệch này, không chỉ vì
      dịch vụ chính xác của B-WF2Q+, mà còn vì BFQ ZZ0000ZZ
      cần chỉ định ngân sách lớn hơn cho hàng đợi để cho phép hàng đợi
      nhận được phần thông lượng thiết bị cao hơn.

- Thứ hai, BFQ có thể tự do lựa chọn, đối với mọi quy trình (hàng đợi),
      ngân sách phù hợp nhất với nhu cầu của quy trình hoặc tốt nhất
      tận dụng mẫu I/O của quy trình. Đặc biệt, BFQ
      cập nhật ngân sách hàng đợi bằng thuật toán vòng phản hồi đơn giản
      cho phép đạt được thông lượng cao trong khi vẫn cung cấp
      đảm bảo độ trễ chặt chẽ cho các ứng dụng nhạy cảm với thời gian. Khi nào
      hàng đợi trong dịch vụ hết hạn, thuật toán này sẽ tính toán tiếp theo
      ngân sách của hàng đợi để:

- Cuối cùng hãy để ngân sách lớn được xếp vào hàng đợi
	liên kết với các ứng dụng có giới hạn I/O thực hiện tuần tự
	I/O: trên thực tế, các ứng dụng này được phục vụ một lần càng lâu
	có quyền truy cập vào thiết bị thì thông lượng càng cao.

- Cuối cùng hãy để ngân sách nhỏ được xếp vào hàng đợi
	liên quan đến các ứng dụng nhạy cảm với thời gian (thường
	thực hiện I/O ngắn và lẻ tẻ), bởi vì, kích thước càng nhỏ
	ngân sách được giao cho hàng đợi dịch vụ thì càng sớm
	B-WF2Q+ sẽ phục vụ hàng đợi đó (Subsec 3.3 trong [2]).

- Nếu có nhiều tiến trình đang cạnh tranh thiết bị cùng một lúc,
  nhưng tất cả các tiến trình và nhóm đều có cùng trọng số thì BFQ
  đảm bảo phân phối thông lượng dự kiến mà không bao giờ chạy không tải
  thiết bị. Thay vào đó, nó sử dụng quyền ưu tiên. Thông lượng thì nhiều
  cao hơn trong kịch bản phổ biến này.

- các lớp ioprio được phục vụ theo thứ tự ưu tiên nghiêm ngặt, tức là
  hàng đợi có mức độ ưu tiên thấp hơn không được phục vụ miễn là có
  hàng đợi có mức độ ưu tiên cao hơn.  Trong số các hàng đợi trong cùng một lớp,
  băng thông được phân bổ tỷ lệ thuận với trọng lượng của mỗi
  xếp hàng. Tuy nhiên, băng thông bổ sung rất mỏng được đảm bảo
  lớp Nhàn rỗi, để tránh bị chết đói.


3. Khả năng điều chỉnh của BFQ là gì và cách cấu hình BFQ đúng cách?
====================================================================

Hầu hết các điều chỉnh BFQ đều ảnh hưởng đến đảm bảo dịch vụ (về cơ bản là độ trễ và
sự công bằng) và thông lượng. Để biết đầy đủ chi tiết về cách chọn
sự cân bằng mong muốn giữa đảm bảo dịch vụ và thông lượng, xem
các tham số slice_idle, strict_guarantees và low_latency. Để biết chi tiết
về cách tối đa hóa thông lượng, hãy xem slice_idle, timeout_sync và
ngân sách tối đa. Các thông số liên quan đến hiệu suất khác đã được
được kế thừa từ đó và được bảo tồn chủ yếu để tương thích với
CFQ. Cho đến nay, không có sự cải thiện hiệu suất nào được báo cáo sau khi
thay đổi các tham số sau trong BFQ.

Đặc biệt, các điều chỉnh back_seek-max, back_seek_penalty,
fifo_expire_async và fifo_expire_sync bên dưới giống như trong
CFQ. Mô tả của họ chỉ được sao chép từ đó cho CFQ. Một số
những cân nhắc trong phần mô tả slice_idle được sao chép từ CFQ
quá.

mỗi quá trình ioprio và trọng lượng
-----------------------------------

Trừ khi giao diện cgroups được sử dụng (xem "4. Lập lịch nhóm BFQ"),
trọng số chỉ có thể được gán cho các tiến trình một cách gián tiếp, thông qua I/O
mức độ ưu tiên và theo mối quan hệ:
trọng lượng = (IOPRIO_BE_NR - ioprio) * 10.

Hãy lưu ý rằng, nếu độ trễ thấp được đặt thì BFQ sẽ tự động tăng
trọng số của hàng đợi liên quan đến thời gian thực mềm và tương tác
ứng dụng. Bỏ cài đặt điều chỉnh này nếu bạn cần/muốn kiểm soát trọng lượng.

slice_idle
----------

Tham số này chỉ định thời gian BFQ sẽ không hoạt động cho lần I/O tiếp theo
yêu cầu, khi hàng đợi BFQ đồng bộ hóa nhất định trở nên trống. Theo mặc định
slice_idle là giá trị khác 0. Chạy không tải có mục đích kép: tăng tốc
thông lượng và đảm bảo rằng việc phân phối thông lượng mong muốn là
được tôn trọng (xem mô tả về cách BFQ hoạt động và, nếu cần,
giấy tờ được đề cập ở đó).

Về thông lượng, việc chạy không tải có thể rất hữu ích trên các phương tiện có lượng tìm kiếm cao
như đĩa SATA/SAS trục đơn nơi chúng ta có thể cắt giảm tổng thể
số lần tìm kiếm và thấy thông lượng được cải thiện.

Đặt slice_idle thành 0 sẽ loại bỏ tất cả trạng thái không hoạt động trên hàng đợi và một
sẽ thấy thông lượng tổng thể được cải thiện trên các thiết bị lưu trữ nhanh hơn
giống như nhiều đĩa SATA/SAS trong cấu hình phần cứng RAID
dưới dạng lưu trữ dựa trên flash với hàng đợi lệnh nội bộ (và
sự song song).

Vì vậy, tùy thuộc vào dung lượng lưu trữ và khối lượng công việc, có thể hữu ích khi đặt
slice_idle=0.  Nói chung đối với đĩa SATA/SAS và phần mềm RAID của
Các đĩa SATA/SAS luôn bật slice_idle sẽ rất hữu ích. Đối với bất kỳ
cấu hình trong đó có nhiều trục xoay phía sau LUN đơn
(Bộ điều khiển RAID phần cứng dựa trên máy chủ hoặc cho mảng lưu trữ) hoặc với
lưu trữ nhanh dựa trên flash, cài đặt slice_idle=0 có thể sẽ tốt hơn
thông lượng và độ trễ chấp nhận được.

Tuy nhiên, việc chạy không tải là cần thiết để đảm bảo dịch vụ được thực thi trong
trường hợp có trọng số khác nhau hoặc độ dài yêu cầu I/O khác nhau.
Để biết lý do tại sao, giả sử rằng hàng đợi BFQ A nhất định phải nhận được một số I/O
các yêu cầu được phân phát cho mỗi yêu cầu được phân phát cho hàng đợi khác B. Đang chạy không tải
đảm bảo rằng, nếu A thực hiện một yêu cầu I/O mới sau khi trở thành
trống thì không có yêu cầu nào của B được gửi đi giữa chừng, và do đó A
không mất khả năng nhận được nhiều hơn một yêu cầu được gửi đi
trước khi yêu cầu tiếp theo của B được gửi đi. Lưu ý rằng chạy không tải
đảm bảo cách xử lý khác biệt mong muốn của hàng đợi chỉ trong
điều khoản của việc gửi yêu cầu I/O. Để đảm bảo rằng dịch vụ thực tế
thứ tự sau đó tương ứng với thứ tự gửi đi, strict_guarantees
điều chỉnh cũng phải được thiết lập.

Có một mặt trái quan trọng của việc chạy không tải: ngoài các trường hợp trên
nơi nó cũng có lợi cho thông lượng, việc chạy không tải có thể ảnh hưởng nghiêm trọng
thông lượng. Một trường hợp quan trọng là khối lượng công việc ngẫu nhiên. Vì điều này
vấn đề, BFQ có xu hướng tránh chạy không tải nhiều nhất có thể, khi không
cũng có lợi cho thông lượng (như chi tiết trong Phần 2). Như một
hậu quả của hành vi này và các vấn đề khác được mô tả cho
strict_guarantees có thể điều chỉnh được, các đảm bảo dịch vụ ngắn hạn có thể
thỉnh thoảng bị vi phạm. Và trong một số trường hợp, những bảo đảm này có thể
quan trọng hơn việc đảm bảo thông lượng tối đa. Ví dụ, trong
phát/phát video, tỷ lệ rớt rất thấp có thể quan trọng hơn
hơn thông lượng tối đa. Trong những trường hợp này, hãy cân nhắc việc thiết lập
tham số strict_guarantees.

slice_idle_us
-------------

Kiểm soát tham số điều chỉnh tương tự như slice_idle, nhưng tính bằng micro giây.
Có thể sử dụng tính năng điều chỉnh để thiết lập hành vi chạy không tải.  Sau đó,
điều chỉnh khác sẽ phản ánh giá trị mới được đặt trong sysfs.

nghiêm ngặt_đảm bảo
-------------------

Nếu tham số này được đặt (mặc định: không được đặt), thì BFQ

- luôn thực hiện chạy không tải khi hàng đợi trong dịch vụ trống;

- buộc thiết bị phải phục vụ một yêu cầu I/O tại một thời điểm, bằng cách gửi một
  chỉ yêu cầu mới nếu không có yêu cầu tồn đọng.

Khi có trọng số hoặc kích thước yêu cầu I/O khác nhau, cả hai
các điều kiện trên là cần thiết để đảm bảo rằng mọi hàng đợi BFQ
nhận được phần băng thông được phân bổ. Điều kiện đầu tiên là
cần thiết vì những lý do được giải thích trong phần mô tả của slice_idle
có thể điều chỉnh được.  Điều kiện thứ hai là cần thiết bởi vì tất cả các kho lưu trữ hiện đại
các thiết bị sắp xếp lại các yêu cầu được xếp hàng nội bộ, có thể phá vỡ một cách tầm thường
các đảm bảo dịch vụ được thực thi bởi bộ lập lịch I/O.

Việc đặt strict_guarantees rõ ràng có thể ảnh hưởng đến thông lượng.

trở lại_seek_max
----------------

Điều này chỉ định, tính bằng Kbyte, "khoảng cách" tối đa để tìm kiếm ngược.
Khoảng cách là khoảng không gian từ vị trí đầu hiện tại đến
những ngành có khoảng cách xa.

Tham số này cho phép bộ lập lịch dự đoán các yêu cầu ở trạng thái "ngược"
hướng và coi họ là "người tiếp theo" nếu họ ở trong phạm vi này
khoảng cách từ vị trí đầu hiện tại.

back_seek_penalty
-----------------

Tham số này được sử dụng để tính toán chi phí tìm kiếm ngược. Nếu
khoảng cách lùi của yêu cầu chỉ là 1/back_seek_penalty tính từ "mặt trước"
yêu cầu thì chi phí tìm kiếm của hai yêu cầu được coi là tương đương.

Vì vậy, bộ lập lịch sẽ không thiên về yêu cầu này hoặc yêu cầu khác (nếu không thì bộ lập lịch sẽ
sẽ thiên về yêu cầu phía trước). Giá trị mặc định của back_seek_penalty là 2.

fifo_expire_async
-----------------

Tham số này được sử dụng để đặt thời gian chờ cho các yêu cầu không đồng bộ. Mặc định
giá trị của điều này là 250ms.

fifo_expire_sync
----------------

Tham số này được sử dụng để đặt thời gian chờ cho các yêu cầu đồng bộ. Mặc định
giá trị của điều này là 125ms. Trong trường hợp ưu tiên các yêu cầu đồng bộ hơn không đồng bộ
một, giá trị này sẽ giảm đi so với fifo_expire_async.

độ trễ thấp
-----------

Tham số này được sử dụng để bật/tắt chế độ độ trễ thấp của BFQ. Bởi
mặc định, chế độ độ trễ thấp được bật. Nếu được bật, tương tác và mềm mại
các ứng dụng thời gian thực được đặc quyền và có độ trễ thấp hơn,
như được giải thích chi tiết hơn trong phần mô tả cách hoạt động của BFQ.

DISABLE chế độ này nếu bạn cần toàn quyền kiểm soát băng thông
phân phối. Trên thực tế, nếu nó được bật thì BFQ sẽ tự động
tăng chia sẻ băng thông của các ứng dụng đặc quyền, vì mục đích chính
có nghĩa là đảm bảo độ trễ thấp hơn cho họ.

Ngoài ra, như đã nhấn mạnh ở phần đầu của tài liệu này,
DISABLE chế độ này nếu mục tiêu duy nhất của bạn là đạt được thông lượng cao.
Trên thực tế, việc ưu tiên I/O của một số ứng dụng so với phần còn lại có thể
đòi hỏi thông lượng thấp hơn. Để đạt được thông lượng cao nhất có thể
trên thiết bị không quay, cũng có thể cần đặt slice_idle thành 0
(với cái giá phải trả là từ bỏ bất kỳ sự đảm bảo mạnh mẽ nào về sự công bằng và chi phí thấp
độ trễ).

hết thời gian chờ_sync
----------------------

Lượng thời gian tối đa của thiết bị có thể được cấp cho một tác vụ (hàng đợi) một lần
nó đã được chọn để phục vụ. Trên các thiết bị có nhu cầu tìm kiếm tốn kém,
tăng thời gian này thường làm tăng thông lượng tối đa. Trên
đầu đối diện, việc tăng thời gian này sẽ làm thô thêm độ chi tiết của
đảm bảo băng thông và độ trễ ngắn hạn, đặc biệt nếu
tham số sau được đặt thành 0.

ngân sách tối đa
----------------

Lượng dịch vụ tối đa, được đo theo ngành, có thể được cung cấp
vào hàng đợi BFQ sau khi nó được đưa vào sử dụng (tất nhiên là trong giới hạn
trong thời gian chờ trên). Theo những gì đã nói trong phần mô tả của
thuật toán, giá trị lớn hơn sẽ tăng thông lượng tương ứng với
tỷ lệ phần trăm các yêu cầu I/O tuần tự được đưa ra. Giá lớn hơn
giá trị là chúng làm tăng độ chi tiết của băng thông ngắn hạn
và đảm bảo độ trễ.

Giá trị mặc định là 0, cho phép tự động điều chỉnh: BFQ đặt max_budget
tới số lượng lĩnh vực tối đa có thể được phục vụ trong
timeout_sync, theo tốc độ cao nhất ước tính.

Đối với các thiết bị cụ thể, một số người dùng đôi khi báo cáo có
đạt được thông lượng cao hơn bằng cách đặt max_budget một cách rõ ràng, tức là bằng
đặt max_budget thành giá trị cao hơn 0. Đặc biệt, họ có
đặt max_budget thành giá trị cao hơn giá trị mà BFQ lẽ ra đã đặt
nó với tính năng tự động điều chỉnh. Một cách khác để đạt được mục tiêu này là
chỉ cần tăng giá trị của timeout_sync, để max_budget bằng 0.

4. Lập lịch nhóm với BFQ
============================

BFQ hỗ trợ cả bộ điều khiển io cgroups-v1 và cgroups-v2, cụ thể là
blkio và io. Đặc biệt, BFQ hỗ trợ tỷ lệ cân nặng dựa trên trọng lượng
chia sẻ. Để kích hoạt hỗ trợ cgroups, hãy đặt BFQ_GROUP_IOSCHED.

4-1 Đảm bảo dịch vụ được cung cấp
---------------------------------

Với BFQ, tỷ lệ chia sẻ có nghĩa là tỷ lệ thực sự của
băng thông thiết bị, theo trọng lượng nhóm. Ví dụ, một nhóm
với trọng số 200 sẽ nhận được băng thông gấp đôi chứ không chỉ gấp đôi thời gian,
của một nhóm có trọng số 100.

BFQ hỗ trợ phân cấp (cây nhóm) ở mọi độ sâu. Băng thông là
được phân phối giữa các nhóm và quy trình theo cách mong đợi: cho mỗi
nhóm, trẻ em trong nhóm chia sẻ toàn bộ băng thông của
nhóm tương ứng với trọng lượng của chúng. Đặc biệt, điều này hàm ý
rằng, đối với mỗi nhóm lá, mọi tiến trình của nhóm đều nhận được
cùng một phần băng thông của cả nhóm, trừ khi ioprio của
quá trình được sửa đổi.

Việc đảm bảo chia sẻ tài nguyên cho một nhóm có thể một phần hoặc toàn bộ
chuyển từ băng thông sang thời gian, nếu cung cấp đảm bảo băng thông cho
nhóm làm giảm thông lượng quá nhiều. Sự chuyển đổi này xảy ra trên một
cơ sở mỗi quy trình: nếu một quy trình của nhóm lá gây ra mất thông lượng
nếu được phục vụ theo cách như vậy để nhận được phần băng thông của nó thì
BFQ chuyển về chế độ chia sẻ tỷ lệ theo thời gian cho điều đó
quá trình.

Giao diện 4-2
-------------

Để có được sự chia sẻ băng thông theo tỷ lệ với BFQ cho một thiết bị nhất định,
BFQ tất nhiên phải là bộ lập lịch hoạt động cho thiết bị đó.

Trong mỗi thư mục nhóm, tên của các tệp được liên kết với
Các tham số và số liệu thống kê nhóm dành riêng cho BFQ bắt đầu bằng "bfq."
tiền tố. Vì vậy, với cgroups-v1 hoặc cgroups-v2, tiền tố đầy đủ cho
Các tệp dành riêng cho BFQ là "blkio.bfq." hoặc "io.bfq." Ví dụ, nhóm
tham số để đặt trọng số của một nhóm với BFQ là blkio.bfq.weight
hoặc io.bfq.weight.

Đối với cgroups-v1 (bộ điều khiển blkio), tập hợp chính xác các tệp stat
được tạo và cập nhật bởi bfq, tùy thuộc vào việc
CONFIG_BFQ_CGROUP_DEBUG được thiết lập. Nếu nó được đặt thì bfq sẽ tạo tất cả
các tập tin stat được ghi lại trong
Tài liệu/admin-guide/cgroup-v1/blkio-controller.rst. Nếu thay vào đó,
CONFIG_BFQ_CGROUP_DEBUG không được đặt thì bfq chỉ tạo các tệp ::

blkio.bfq.io_service_bytes
  blkio.bfq.io_service_bytes_recursive
  blkio.bfq.io_serviced
  blkio.bfq.io_serviced_recursive

Giá trị của CONFIG_BFQ_CGROUP_DEBUG ảnh hưởng lớn đến mức tối đa
thông lượng bền vững với bfq, vì cập nhật blkio.bfq.*
số liệu thống kê khá tốn kém, đặc biệt đối với một số số liệu thống kê được kích hoạt bởi
CONFIG_BFQ_CGROUP_DEBUG.

Thông số
----------

Đối với mỗi nhóm, có thể đặt các tham số sau:

trọng lượng
        Điều này chỉ định trọng số mặc định cho cgroup bên trong cha mẹ của nó.
        Các giá trị khả dụng: 1..1000 (mặc định: 100).

Đối với cgroup v1, nó được đặt bằng cách ghi giá trị vào ZZ0000ZZ.

Đối với cgroup v2, nó được đặt bằng cách ghi giá trị vào ZZ0000ZZ.
        (với tiền tố tùy chọn là ZZ0001ZZ và khoảng trắng).

Ánh xạ tuyến tính giữa ioprio và trọng lượng, được mô tả ở phần đầu
        của phần có thể điều chỉnh được, vẫn hợp lệ, nhưng tất cả các trọng số cao hơn
        IOPRIO_BE_NR*10 được ánh xạ tới ioprio 0.

Hãy nhớ lại rằng, nếu độ trễ thấp được đặt thì BFQ sẽ tự động tăng
        trọng số của hàng đợi liên quan đến thời gian thực mềm và tương tác
        ứng dụng. Bỏ cài đặt điều chỉnh này nếu bạn cần/muốn kiểm soát trọng lượng.

trọng lượng_thiết bị
        Điều này chỉ định trọng lượng trên mỗi thiết bị cho nhóm. Cú pháp là
        ZZ0000ZZ. Trọng lượng ZZ0001ZZ có thể được sử dụng để đặt lại về mặc định
        trọng lượng.

Đối với cgroup v1, nó được đặt bằng cách ghi giá trị vào ZZ0000ZZ.

Đối với cgroup v2, tên tệp là ZZ0000ZZ.


[1]
    P. Valente, A. Avanzini, "Sự phát triển của I/O lưu trữ BFQ
    Scheduler", Kỷ yếu Hội thảo đầu tiên về Hệ thống di động
    Công nghệ (MST-2015), tháng 5 năm 2015.

ZZ0000ZZ

[2]
    P. Valente và M. Andreolini, "Cải thiện ứng dụng
    Khả năng phản hồi với Bộ lập lịch I/O đĩa BFQ", Kỷ yếu của
    Hội nghị lưu trữ và hệ thống quốc tế thường niên lần thứ 5
    (SYSTOR '12), tháng 6 năm 2012.

Phiên bản mở rộng một chút:

ZZ0000ZZ

[3]
   ZZ0000ZZ
