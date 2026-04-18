.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/RCU/Design/Data-Structures/Data-Structures.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Tham quan qua cấu trúc dữ liệu của TREE_RCU [LWN.net]
===================================================

Ngày 18 tháng 12 năm 2016

Bài viết này được đóng góp bởi Paul E. McKenney

Giới thiệu
============

Tài liệu này mô tả các cấu trúc dữ liệu chính của RCU và mối quan hệ của chúng
với nhau.

Mối quan hệ cấu trúc dữ liệu
============================

RCU là một cỗ máy trạng thái lớn về mọi mặt và
cấu trúc dữ liệu duy trì trạng thái theo cách cho phép người đọc RCU
để thực thi cực kỳ nhanh chóng, đồng thời xử lý thời gian gia hạn RCU
được yêu cầu bởi những người cập nhật một cách hiệu quả và có khả năng mở rộng cực kỳ cao.
Hiệu quả và khả năng mở rộng của các trình cập nhật RCU được cung cấp chủ yếu
bằng cây kết hợp như hình dưới đây:

.. kernel-figure:: BigTreeClassicRCU.svg

Sơ đồ này hiển thị cấu trúc ZZ0000ZZ kèm theo có chứa một cây
của cấu trúc ZZ0001ZZ. Mỗi nút lá của cây ZZ0002ZZ có
đến 16 cấu trúc ZZ0003ZZ được liên kết với nó, do đó có
ZZ0004ZZ Số lượng cấu trúc ZZ0005ZZ, một cho mỗi CPU có thể.
Cấu trúc này được điều chỉnh vào lúc khởi động, nếu cần, để xử lý các lỗi chung
trường hợp ZZ0006ZZ nhỏ hơn nhiều so với ZZ0007ZZ.
Ví dụ: một số bản phân phối Linux đặt ZZ0008ZZ,
dẫn đến cây ZZ0009ZZ ba cấp.
Nếu phần cứng thực tế chỉ có 16 CPU, RCU sẽ tự điều chỉnh
khi khởi động, dẫn đến cây ZZ0010ZZ chỉ có một nút duy nhất.

Mục đích của cây kết hợp này là cho phép các sự kiện trên mỗi CPU
chẳng hạn như trạng thái tĩnh, chuyển tiếp không hoạt động,
và hoạt động cắm nóng CPU được xử lý hiệu quả
và có thể mở rộng.
Các trạng thái không hoạt động được ghi lại bởi các cấu trúc per-CPU ZZ0000ZZ,
và các sự kiện khác được ZZ0001ZZ cấp lá ghi lại
các cấu trúc.
Tất cả các sự kiện này được kết hợp ở mỗi cấp độ của cây cho đến khi cuối cùng
thời gian ân hạn được hoàn thành ở gốc cây ZZ0002ZZ
cấu trúc.
Thời gian gia hạn có thể được hoàn thành ở thư mục gốc một lần mỗi CPU
(hoặc, trong trường hợp ZZ0003ZZ, nhiệm vụ)
đã qua trạng thái tĩnh lặng.
Khi thời gian ân hạn đã hoàn thành, hồ sơ về sự việc đó sẽ được phổ biến
quay xuống gốc cây.

Như có thể thấy từ sơ đồ, trên hệ thống 64 bit
một cây hai cấp với 64 lá có thể chứa 1.024 CPU, có một fanout
64 ở gốc và 16 ở lá.

+--------------------------------------------------------------------------------------- +
ZZ0011ZZ
+--------------------------------------------------------------------------------------- +
ZZ0012ZZ
+--------------------------------------------------------------------------------------- +
ZZ0013ZZ
+--------------------------------------------------------------------------------------- +
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
ZZ0028ZZ
ZZ0029ZZ
ZZ0030ZZ
ZZ0031ZZ
ZZ0032ZZ
ZZ0033ZZ
+--------------------------------------------------------------------------------------- +

Nếu hệ thống của bạn có nhiều hơn 1.024 CPU (hoặc hơn 512 CPU trên một
hệ thống 32-bit), sau đó RCU sẽ tự động thêm nhiều cấp độ hơn vào cây.
Ví dụ: nếu bạn đủ điên rồ để xây dựng một hệ thống 64-bit với
65.536 CPU, RCU sẽ cấu hình cây ZZ0000ZZ như sau:

.. kernel-figure:: HugeTreeClassicRCU.svg

RCU hiện cho phép tối đa cây bốn cấp, trên hệ thống 64 bit
chứa tới 4.194.304 CPU, mặc dù chỉ có 524.288 CPU cho
Hệ thống 32-bit. Mặt khác, bạn có thể đặt cả hai
ZZ0000ZZ và ZZ0001ZZ nhỏ như
2, sẽ dẫn đến thử nghiệm 16-CPU bằng cách sử dụng cây 4 cấp độ. Đây có thể là
hữu ích để kiểm tra khả năng của hệ thống lớn trên các máy kiểm tra nhỏ.

Cây kết hợp đa cấp độ này cho phép chúng ta đạt được hầu hết hiệu suất
và lợi ích về khả năng mở rộng của việc phân vùng, mặc dù thời gian ân hạn của RCU
phát hiện vốn là một hoạt động toàn cầu. Bí quyết ở đây chỉ là
CPU cuối cùng báo cáo trạng thái không hoạt động thành ZZ0000ZZ nhất định
cấu trúc cần nâng cao lên cấu trúc ZZ0001ZZ ở cấp độ tiếp theo
lên cây. Điều này có nghĩa là ở cấu trúc ZZ0002ZZ cấp lá,
chỉ có một quyền truy cập trong số mười sáu quyền truy cập sẽ tiến lên cây. Đối với
cấu trúc ZZ0003ZZ bên trong, tình hình thậm chí còn cực đoan hơn:
Chỉ một trong số 64 quyền truy cập sẽ tiến lên cây. Bởi vì
phần lớn các CPU không tiến lên theo cây, khóa
sự tranh chấp vẫn gần như không đổi trên cây. Cho dù có bao nhiêu CPU
có trong hệ thống, tối đa 64 báo cáo trạng thái không hoạt động cho mỗi lần gia hạn
giai đoạn này sẽ tiến tới cấu trúc ZZ0004ZZ gốc,
do đó đảm bảo rằng việc tranh chấp khóa trên root đó ZZ0005ZZ
cấu trúc vẫn ở mức thấp có thể chấp nhận được.

Trong thực tế, cây kết hợp hoạt động giống như một bộ giảm xóc lớn, giữ cho
khóa sự tranh chấp dưới sự kiểm soát ở tất cả các cấp độ cây bất kể cấp độ
tải trên hệ thống.

Người cập nhật RCU chờ thời gian gia hạn bình thường bằng cách đăng ký lệnh gọi lại RCU,
trực tiếp qua ZZ0000ZZ hoặc gián tiếp qua
ZZ0001ZZ và những người bạn. Lệnh gọi lại RCU được biểu thị bằng
Cấu trúc ZZ0002ZZ, được xếp hàng trên cấu trúc ZZ0003ZZ
trong khi họ đang chờ thời gian gia hạn trôi qua, như được trình bày trong
hình sau:

.. kernel-figure:: BigTreePreemptRCUBHdyntickCB.svg

Hình này cho thấy dữ liệu chính của ZZ0000ZZ và ZZ0001ZZ
các cấu trúc có liên quan. Cấu trúc dữ liệu ít hơn sẽ được giới thiệu với
các thuật toán sử dụng chúng.

Lưu ý rằng mỗi cấu trúc dữ liệu trong hình trên đều có cấu trúc riêng
đồng bộ hóa:

#. Mỗi cấu trúc ZZ0000ZZ có một khóa và một mutex và một số trường
   được bảo vệ bởi khóa của cấu trúc ZZ0001ZZ gốc tương ứng.
#. Mỗi cấu trúc ZZ0002ZZ đều có một khóa xoay.
#. Các trường trong ZZ0003ZZ là riêng tư đối với CPU tương ứng,
   mặc dù một số ít có thể được đọc và ghi bởi các CPU khác.

Điều quan trọng cần lưu ý là các cấu trúc dữ liệu khác nhau có thể có rất nhiều
những ý tưởng khác nhau về trạng thái của RCU tại bất kỳ thời điểm nào. Chỉ vì một
ví dụ: nhận thức về sự bắt đầu hoặc kết thúc của thời gian gia hạn RCU nhất định
lan truyền chậm qua các cấu trúc dữ liệu. Sự lan truyền chậm này là
thực sự cần thiết để RCU có hiệu suất đọc tốt. Nếu điều này
Việc triển khai balkan hóa có vẻ xa lạ với bạn, một mẹo hữu ích là
coi mỗi phiên bản của các cấu trúc dữ liệu này là khác nhau
người, mỗi người có cái nhìn hơi khác nhau về thực tế.

Vai trò chung của từng cấu trúc dữ liệu này như sau:

#. ZZ0000ZZ: Cấu trúc này tạo thành sự kết nối giữa
   Cấu trúc ZZ0001ZZ và ZZ0002ZZ, theo dõi thời gian ân hạn,
   đóng vai trò là kho lưu trữ ngắn hạn cho các cuộc gọi lại mồ côi bởi CPU-hotplug
   sự kiện, duy trì trạng thái ZZ0003ZZ, theo dõi tiến độ
   trạng thái thời gian ân hạn và duy trì trạng thái được sử dụng để buộc không hoạt động
   nêu rõ khi thời gian ân hạn kéo dài quá lâu,
#. ZZ0004ZZ: Cấu trúc này tạo thành cây kết hợp lan truyền
   thông tin ở trạng thái tĩnh từ lá đến gốc, và cả
   truyền bá thông tin về thời gian gia hạn từ gốc đến các lá. Nó
   cung cấp các bản sao cục bộ của trạng thái thời gian gia hạn để cho phép
   thông tin này có thể được truy cập một cách đồng bộ mà không cần
   phải chịu những hạn chế về khả năng mở rộng nếu không sẽ bị áp đặt
   bằng cách khóa toàn cầu. Trong hạt nhân ZZ0005ZZ, nó quản lý
   danh sách các tác vụ đã bị chặn khi ở phía đọc RCU hiện tại của chúng
   phần quan trọng. Trong ZZ0006ZZ với
   ZZ0007ZZ, nó quản lý mỗi ZZ0008ZZ
   các luồng hạt nhân tăng cường mức độ ưu tiên (kthread) và trạng thái. Cuối cùng, nó
   ghi lại trạng thái CPU-hotplug để xác định CPU nào sẽ được
   bị bỏ qua trong một thời gian ân hạn nhất định.
#. ZZ0009ZZ: Cấu trúc mỗi CPU này là trọng tâm của trạng thái không hoạt động
   phát hiện và xếp hàng gọi lại RCU. Nó cũng theo dõi mối quan hệ của nó
   tới cấu trúc ZZ0010ZZ lá tương ứng để cho phép
   truyền hiệu quả hơn các trạng thái không hoạt động lên ZZ0011ZZ
   cây kết hợp Giống như cấu trúc ZZ0012ZZ, nó cung cấp một địa chỉ cục bộ
   bản sao thông tin trong thời gian gia hạn để cho phép đồng bộ hóa miễn phí
   truy cập thông tin này từ CPU tương ứng. Cuối cùng, điều này
   cấu trúc ghi lại trạng thái không hoạt động trong quá khứ cho CPU tương ứng
   và cũng theo dõi số liệu thống kê.
#. ZZ0013ZZ: Cấu trúc này đại diện cho các lệnh gọi lại RCU và là
   cấu trúc duy nhất được phân bổ và quản lý bởi người dùng RCU. ZZ0014ZZ
   cấu trúc thường được nhúng trong dữ liệu được bảo vệ RCU
   cấu trúc.

Nếu tất cả những gì bạn muốn từ bài viết này là khái niệm chung về cách hoạt động của RCU
cấu trúc dữ liệu có liên quan, bạn đã hoàn tất. Nếu không thì mỗi
các phần sau cung cấp thêm thông tin chi tiết về ZZ0000ZZ, ZZ0001ZZ
và cấu trúc dữ liệu ZZ0002ZZ.

Cấu trúc ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấu trúc ZZ0000ZZ là cấu trúc cơ sở đại diện cho
trạng thái RCU trong hệ thống. Cấu trúc này tạo thành mối liên kết
giữa các cấu trúc ZZ0001ZZ và ZZ0002ZZ, theo dõi sự duyên dáng
dấu chấm, chứa khóa được sử dụng để đồng bộ hóa với các sự kiện CPU-hotplug,
và duy trì trạng thái được sử dụng để buộc các trạng thái không hoạt động khi thời gian ân hạn
kéo dài quá lâu,

Một số trường của cấu trúc ZZ0000ZZ được thảo luận riêng lẻ và
theo nhóm ở các phần sau. Các lĩnh vực chuyên biệt hơn là
được đề cập trong cuộc thảo luận về việc sử dụng chúng.

Mối quan hệ với cấu trúc rcu_node và rcu_data
''''''''''''''''''''''''''''''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 nút cấu trúc rcu_node[NUM_RCU_NODES];
     2 cấu trúc rcu_node *level[NUM_RCU_LVLS + 1];
     3 cấu trúc rcu_data __percpu *rda;

+--------------------------------------------------------------------------------------- +
ZZ0003ZZ
+--------------------------------------------------------------------------------------- +
ZZ0004ZZ
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
+--------------------------------------------------------------------------------------- +

Cây ZZ0000ZZ được nhúng vào mảng ZZ0001ZZ như được hiển thị
trong hình sau:

.. kernel-figure:: TreeMapping.svg

Một hệ quả thú vị của việc ánh xạ này là chiều rộng đầu tiên
Việc duyệt cây được thực hiện như một phép quét tuyến tính đơn giản của
mảng, thực tế đó là những gì ZZ0000ZZ
vĩ mô thì có. Macro này được sử dụng ở đầu và cuối ân sủng
thời kỳ.

Mỗi mục của mảng ZZ0000ZZ đều tham chiếu đến ZZ0001ZZ đầu tiên
cấu trúc ở cấp độ tương ứng của cây, ví dụ như được hiển thị
dưới đây:

.. kernel-figure:: TreeMappingLevel.svg

Phần tử zero\ZZ0000ZZ của mảng tham chiếu gốc
Cấu trúc ZZ0001ZZ, phần tử đầu tiên tham chiếu đến phần tử con đầu tiên của
gốc ZZ0002ZZ và cuối cùng là phần tử thứ hai tham chiếu đến
Cấu trúc ZZ0003ZZ lá đầu tiên.

Dù sao đi nữa, nếu bạn vẽ cái cây có hình dạng cây
hơn là dạng mảng, rất dễ dàng để vẽ một biểu diễn phẳng:

.. kernel-figure:: TreeLevel.svg

Cuối cùng, trường ZZ0000ZZ tham chiếu con trỏ per-CPU tới
cấu trúc ZZ0001ZZ của CPU tương ứng.

Tất cả các trường này không đổi sau khi quá trình khởi tạo hoàn tất và
nên không cần bảo vệ.

Theo dõi thời gian ân hạn
'''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 gp_seq dài không dấu;

Thời gian gia hạn RCU được đánh số và trường ZZ0000ZZ chứa
số thứ tự thời gian gia hạn hiện tại. Hai bit dưới cùng là trạng thái
của thời gian ân hạn hiện tại, có thể bằng 0 nếu chưa bắt đầu hoặc
một cho đang tiến hành. Nói cách khác, nếu hai bit dưới cùng của
ZZ0001ZZ bằng 0 thì RCU ở chế độ chờ. Bất kỳ giá trị nào khác ở phía dưới
hai bit chỉ ra rằng một cái gì đó bị hỏng. Trường này được bảo vệ bởi
trường ZZ0003ZZ của cấu trúc ZZ0002ZZ gốc.

Có các trường ZZ0000ZZ trong ZZ0001ZZ và ZZ0002ZZ
các cấu trúc là tốt. Các trường trong cấu trúc ZZ0003ZZ đại diện cho
giá trị hiện tại nhất và giá trị của các cấu trúc khác được so sánh
để phát hiện sự bắt đầu và kết thúc của thời gian ân hạn trong một
thời trang phân tán. Các giá trị chảy từ ZZ0004ZZ đến ZZ0005ZZ
(xuống cây từ gốc tới lá) thành ZZ0006ZZ.

+--------------------------------------------------------------------------------------- +
ZZ0002ZZ
+--------------------------------------------------------------------------------------- +
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
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
ZZ0023ZZ
ZZ0024ZZ
ZZ0025ZZ
ZZ0026ZZ
ZZ0027ZZ
ZZ0028ZZ
+--------------------------------------------------------------------------------------- +

Linh tinh
'''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 gp_max dài không dấu;
     2 ký tự viết tắt;
     3 ký tự *tên;

Trường ZZ0000ZZ theo dõi thời gian gia hạn dài nhất
trong nháy mắt. Nó được bảo vệ bởi ZZ0002ZZ của root ZZ0001ZZ.

Các trường ZZ0000ZZ và ZZ0001ZZ phân biệt giữa RCU được ưu tiên
(“rcu_preempt” và “p”) và RCU không được ưu tiên (“rcu_sched” và “s”).
Các trường này được sử dụng cho mục đích chẩn đoán và truy tìm.

Cấu trúc ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~

Các cấu trúc ZZ0000ZZ tạo thành cây kết hợp lan truyền
thông tin ở trạng thái tĩnh từ lá đến gốc và cả thông tin đó
truyền bá thông tin về thời gian gia hạn từ gốc xuống các lá.
Họ cung cấp các bản sao cục bộ của trạng thái thời gian gia hạn để cho phép
thông tin này có thể được truy cập một cách đồng bộ mà không cần
phải chịu những hạn chế về khả năng mở rộng mà nếu không sẽ bị áp đặt bởi
khóa toàn cầu. Trong hạt nhân ZZ0001ZZ, chúng quản lý danh sách
của các tác vụ đã bị chặn trong khi ở trạng thái quan trọng phía đọc RCU hiện tại của chúng
phần. Trong ZZ0002ZZ với ZZ0003ZZ, chúng
quản lý các luồng hạt nhân tăng cường mức độ ưu tiên trên mỗi\ZZ0004ZZ
(kthreads) và trạng thái. Cuối cùng, họ ghi lại trạng thái cắm nóng CPU để
xác định CPU nào sẽ bị bỏ qua trong thời gian gia hạn nhất định.

Các trường của cấu trúc ZZ0000ZZ được thảo luận riêng lẻ và theo nhóm,
trong các phần sau.

Kết nối với cây kết hợp
''''''''''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 cấu trúc rcu_node *parent;
     cấp 2 u8;
     3 u8 grpnum;
     4 grpmask dài không dấu;
     5 int grplo;
     6 int grphi;

Con trỏ ZZ0000ZZ tham chiếu ZZ0001ZZ lên một cấp trong
cây và là ZZ0002ZZ cho gốc ZZ0003ZZ. Việc triển khai RCU
sử dụng nhiều trường này để đẩy các trạng thái tĩnh lên trên cây. các
Trường ZZ0004ZZ cung cấp cấp độ trong cây, với gốc ở
cấp 0, con của nó ở cấp một, v.v. Trường ZZ0005ZZ
đưa ra vị trí của nút này trong các nút con của nút cha của nó, vì vậy điều này
số có thể nằm trong khoảng từ 0 đến 31 trên hệ thống 32 bit và từ 0 đến 63
trên hệ thống 64-bit. Các trường ZZ0006ZZ và ZZ0007ZZ chỉ được sử dụng
trong quá trình khởi tạo và truy tìm. Trường ZZ0008ZZ là trường
bản sao bitmask của ZZ0009ZZ và do đó luôn có chính xác
thiết lập một bit. Mặt nạ này được sử dụng để xóa bit tương ứng với
Cấu trúc ZZ0010ZZ trong bitmasks của cha mẹ nó, được mô tả
sau này. Cuối cùng, các trường ZZ0011ZZ và ZZ0012ZZ chứa
CPU được đánh số thấp nhất và cao nhất được phục vụ bởi cấu trúc ZZ0013ZZ này,
tương ứng.

Tất cả các trường này là không đổi và do đó không yêu cầu bất kỳ
đồng bộ hóa.

Đồng bộ hóa
'''''''''''''''

Trường này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 khóa raw_spinlock_t;

Trường này được sử dụng để bảo vệ các trường còn lại trong cấu trúc này,
trừ khi có quy định khác. Điều đó nói rằng, tất cả các trường trong cấu trúc này
có thể được truy cập mà không cần khóa cho mục đích truy tìm. Vâng, điều này có thể
dẫn đến những dấu vết khó hiểu, nhưng một số dấu vết nhầm lẫn còn tốt hơn là
heisenbug đã biến mất.

.. _grace-period-tracking-1:

Theo dõi thời gian ân hạn
'''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 gp_seq dài không dấu;
     2 gp_seq_ Need dài không dấu;

Các trường ZZ0001ZZ của cấu trúc ZZ0000ZZ là bản sao của
trường cùng tên trong cấu trúc ZZ0002ZZ. Mỗi người họ có thể
tụt lại phía sau một bước so với đối tác ZZ0003ZZ của họ. Nếu đáy
hai bit của trường ZZ0005ZZ của cấu trúc ZZ0004ZZ nhất định bằng 0,
thì cấu trúc ZZ0006ZZ này tin rằng RCU không hoạt động.

Trường ZZ0000ZZ của mỗi cấu trúc ZZ0001ZZ được cập nhật tại
đầu và cuối mỗi thời gian ân hạn.

Các trường ZZ0000ZZ ghi lại ân sủng xa nhất trong tương lai
yêu cầu khoảng thời gian được nhìn thấy bởi cấu trúc ZZ0001ZZ tương ứng. các
yêu cầu được coi là hoàn thành khi giá trị của trường ZZ0002ZZ
bằng hoặc vượt quá trường ZZ0003ZZ.

+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
+--------------------------------------------------------------------------------------- +
ZZ0011ZZ
+--------------------------------------------------------------------------------------- +
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
+--------------------------------------------------------------------------------------- +

Theo dõi trạng thái tĩnh
''''''''''''''''''''''''

Các trường này quản lý việc truyền bá các trạng thái không hoạt động trong quá trình kết hợp
cây.

Phần này của cấu trúc ZZ0000ZZ có các trường như sau:

::

1 qsmask dài không dấu;
     2 expmask dài không dấu;
     3 qsmaskinit dài không dấu;
     4 expmaskinit dài không dấu;

Trường ZZ0000ZZ theo dõi cấu trúc ZZ0001ZZ này
trẻ em vẫn cần báo cáo trạng thái không hoạt động trong thời gian bình thường hiện tại
thời gian ân hạn. Những đứa trẻ như vậy sẽ có giá trị là 1 trong
bit tương ứng. Lưu ý rằng cấu trúc lá ZZ0002ZZ phải là
được coi là có cấu trúc ZZ0003ZZ như con của chúng.
Tương tự, trường ZZ0004ZZ theo dõi ZZ0005ZZ này
con của cấu trúc vẫn cần báo cáo trạng thái không hoạt động cho
thời gian ân hạn cấp tốc hiện tại. Thời gian ân hạn cấp tốc cũng có cùng
thuộc tính khái niệm như một thời gian gia hạn thông thường, nhưng thời gian được đẩy nhanh
việc triển khai chấp nhận chi phí CPU cực cao để đạt được mức thấp hơn nhiều
ví dụ: độ trễ trong thời gian gia hạn, tiêu tốn vài chục micro giây
giá trị thời gian CPU để giảm thời gian gia hạn từ mili giây xuống
hàng chục micro giây. Trường ZZ0006ZZ theo dõi điều nào trong số này
Cấu trúc con của ZZ0007ZZ bao gồm ít nhất một CPU trực tuyến.
Mặt nạ này được sử dụng để khởi tạo ZZ0008ZZ và ZZ0009ZZ là
được sử dụng để khởi tạo ZZ0010ZZ và bắt đầu hoạt động bình thường và
thời gian gia hạn nhanh tương ứng.

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
ZZ0028ZZ
ZZ0029ZZ
ZZ0030ZZ
ZZ0031ZZ
ZZ0032ZZ
+--------------------------------------------------------------------------------------- +

Quản lý tác vụ bị chặn
'''''''''''''''''''''''

ZZ0000ZZ cho phép các nhiệm vụ được ưu tiên ở giữa RCU của họ
các phần quan trọng phía đọc và các tác vụ này phải được theo dõi một cách rõ ràng.
Chi tiết về lý do chính xác và cách chúng được theo dõi sẽ được trình bày trong
bài viết riêng về xử lý bên đọc RCU. Hiện tại chỉ cần như vậy là đủ
biết rằng cấu trúc ZZ0001ZZ theo dõi chúng.

::

1 cấu trúc list_head blkd_tasks;
     2 cấu trúc list_head *gp_tasks;
     3 cấu trúc list_head *exp_tasks;
     4 bool wait_blkd_tasks;

Trường ZZ0000ZZ là tiêu đề danh sách cho danh sách bị chặn và
nhiệm vụ ưu tiên. Khi các tác vụ trải qua quá trình chuyển đổi ngữ cảnh trong phía đọc RCU
các phần quan trọng, cấu trúc ZZ0001ZZ của chúng được xếp hàng đợi (thông qua
trường ZZ0003ZZ của ZZ0002ZZ) lên đầu của
Danh sách ZZ0004ZZ cho cấu trúc lá ZZ0005ZZ tương ứng
tới CPU nơi thực hiện chuyển đổi ngữ cảnh đi. Như những nhiệm vụ này
sau đó thoát khỏi các phần quan trọng bên đọc RCU của họ, họ tự xóa
từ danh sách. Do đó, danh sách này được sắp xếp theo thứ tự thời gian ngược lại, do đó nếu
một trong những nhiệm vụ là chặn thời gian gia hạn hiện tại, tất cả các nhiệm vụ tiếp theo
các nhiệm vụ cũng phải chặn khoảng thời gian gia hạn đó. Vì vậy, một đơn
con trỏ vào danh sách này đủ để theo dõi tất cả các tác vụ chặn một
thời gian ân hạn. Con trỏ đó được lưu trữ trong ZZ0006ZZ để sử dụng bình thường
và trong ZZ0007ZZ cho thời gian gia hạn nhanh. Những cái cuối cùng này
hai trường là ZZ0008ZZ nếu không có thời gian gia hạn trong chuyến bay hoặc
nếu không có nhiệm vụ nào bị chặn ngăn cản thời gian gia hạn đó
hoàn thiện. Nếu một trong hai con trỏ này đang tham chiếu đến một tác vụ
tự xóa nó khỏi danh sách ZZ0009ZZ thì tác vụ đó phải
đưa con trỏ tới tác vụ tiếp theo trong danh sách hoặc đặt con trỏ thành
ZZ0010ZZ nếu không có nhiệm vụ tiếp theo nào trong danh sách.

Ví dụ: giả sử rằng các nhiệm vụ T1, T2 và T3 đều có liên quan chặt chẽ
đến CPU có số lớn nhất trong hệ thống. Sau đó, nếu tác vụ T1 bị chặn trong
Phần quan trọng bên đọc RCU, sau đó bắt đầu thời gian gia hạn nhanh,
sau đó tác vụ T2 bị chặn trong phần quan trọng bên đọc RCU, sau đó tác vụ bình thường
thời gian gia hạn bắt đầu và cuối cùng nhiệm vụ 3 bị chặn trong phần đọc RCU
phần quan trọng, sau đó là trạng thái của lá cuối cùng ZZ0000ZZ
danh sách nhiệm vụ bị chặn của cấu trúc sẽ như dưới đây:

.. kernel-figure:: blkd_task.svg

Nhiệm vụ T1 đang chặn cả hai khoảng thời gian gia hạn, nhiệm vụ T2 chỉ chặn
thời gian gia hạn thông thường và nhiệm vụ T3 không chặn thời gian gia hạn. Lưu ý
rằng những nhiệm vụ này sẽ không tự xóa chúng khỏi danh sách này ngay lập tức
khi tiếp tục thực hiện. Thay vào đó, họ sẽ vẫn ở trong danh sách cho đến khi họ
thực thi ZZ0000ZZ ngoài cùng kết thúc RCU của họ
phần quan trọng phía đọc.

Trường ZZ0000ZZ cho biết liệu dòng điện hiện tại có
thời gian gia hạn đang chờ đợi một nhiệm vụ bị chặn.

Định cỡ mảng ZZ0000ZZ
'''''''''''''''''''''''''''''

Mảng ZZ0000ZZ được định kích thước thông qua một loạt bộ tiền xử lý C
biểu thức như sau:

::

1 #ifdef CONFIG_RCU_FANOUT
    2 #define RCU_FANOUT CONFIG_RCU_FANOUT
    3 #else
    4 # ifdef CONFIG_64BIT
    5 # define RCU_FANOUT 64
    6 # else
    7 # define RCU_FANOUT 32
    8 # endif
    9 #endif
   10
   11 #ifdef CONFIG_RCU_FANOUT_LEAF
   12 #define RCU_FANOUT_LEAF CONFIG_RCU_FANOUT_LEAF
   13 #else
   14 # ifdef CONFIG_64BIT
   15 # define RCU_FANOUT_LEAF 64
   16 # else
   17 # define RCU_FANOUT_LEAF 32
   18 # endif
   19 #endif
   20
   21 #define RCU_FANOUT_1 (RCU_FANOUT_LEAF)
   22 #define RCU_FANOUT_2 (RCU_FANOUT_1 * RCU_FANOUT)
   23 #define RCU_FANOUT_3 (RCU_FANOUT_2 * RCU_FANOUT)
   24 #define RCU_FANOUT_4 (RCU_FANOUT_3 * RCU_FANOUT)
   25
   26 #if NR_CPUS <= RCU_FANOUT_1
   27 #  define RCU_NUM_LVLS 1
   28 #  define NUM_RCU_LVL_0 1
   29 #  define NUM_RCU_NODES NUM_RCU_LVL_0
   30 #  define NUM_RCU_LVL_INIT { NUM_RCU_LVL_0 }
   31 #  define RCU_NODE_NAME_INIT { "rcu_node_0" }
   32 #  define RCU_FQS_NAME_INIT { "rcu_node_fqs_0" }
   33 #  define RCU_EXP_NAME_INIT { "rcu_node_exp_0" }
   34 #elif NR_CPUS <= RCU_FANOUT_2
   35 #  define RCU_NUM_LVLS 2
   36 #  define NUM_RCU_LVL_0 1
   37 #  define NUM_RCU_LVL_1 DIV_ROUND_UP(NR_CPUS, RCU_FANOUT_1)
   38 #  define NUM_RCU_NODES (NUM_RCU_LVL_0 + NUM_RCU_LVL_1)
   39 #  define NUM_RCU_LVL_INIT { NUM_RCU_LVL_0, NUM_RCU_LVL_1 }
   40 #  define RCU_NODE_NAME_INIT { "rcu_node_0", "rcu_node_1" }
   41 #  define RCU_FQS_NAME_INIT { "rcu_node_fqs_0", "rcu_node_fqs_1" }
   42 #  define RCU_EXP_NAME_INIT { "rcu_node_exp_0", "rcu_node_exp_1" }
   43 #elif NR_CPUS <= RCU_FANOUT_3
   44 #  define RCU_NUM_LVLS 3
   45 #  define NUM_RCU_LVL_0 1
   46 #  define NUM_RCU_LVL_1 DIV_ROUND_UP(NR_CPUS, RCU_FANOUT_2)
   47 #  define NUM_RCU_LVL_2 DIV_ROUND_UP(NR_CPUS, RCU_FANOUT_1)
   48 #  define NUM_RCU_NODES (NUM_RCU_LVL_0 + NUM_RCU_LVL_1 + NUM_RCU_LVL_2)
   49 #  define NUM_RCU_LVL_INIT { NUM_RCU_LVL_0, NUM_RCU_LVL_1, NUM_RCU_LVL_2 }
   50 #  define RCU_NODE_NAME_INIT { "rcu_node_0", "rcu_node_1", "rcu_node_2" }
   51 #  define RCU_FQS_NAME_INIT { "rcu_node_fqs_0", "rcu_node_fqs_1", "rcu_node_fqs_2" }
   52 #  define RCU_EXP_NAME_INIT { "rcu_node_exp_0", "rcu_node_exp_1", "rcu_node_exp_2" }
   53 #elif NR_CPUS <= RCU_FANOUT_4
   54 #  define RCU_NUM_LVLS 4
   55 #  define NUM_RCU_LVL_0 1
   56 #  define NUM_RCU_LVL_1 DIV_ROUND_UP(NR_CPUS, RCU_FANOUT_3)
   57 #  define NUM_RCU_LVL_2 DIV_ROUND_UP(NR_CPUS, RCU_FANOUT_2)
   58 #  define NUM_RCU_LVL_3 DIV_ROUND_UP(NR_CPUS, RCU_FANOUT_1)
   59 #  define NUM_RCU_NODES (NUM_RCU_LVL_0 + NUM_RCU_LVL_1 + NUM_RCU_LVL_2 + NUM_RCU_LVL_3)
   60 #  define NUM_RCU_LVL_INIT { NUM_RCU_LVL_0, NUM_RCU_LVL_1, NUM_RCU_LVL_2, NUM_RCU_LVL_3 }
   61 #  define RCU_NODE_NAME_INIT { "rcu_node_0", "rcu_node_1", "rcu_node_2", "rcu_node_3" }
   62 #  define RCU_FQS_NAME_INIT { "rcu_node_fqs_0", "rcu_node_fqs_1", "rcu_node_fqs_2", "rcu_node_fqs_3" }
   63 #  define RCU_EXP_NAME_INIT { "rcu_node_exp_0", "rcu_node_exp_1", "rcu_node_exp_2", "rcu_node_exp_3" }
   64 #else
   65 # error "CONFIG_RCU_FANOUT không đủ cho NR_CPUS"
   66 #endif

Số cấp độ tối đa trong cấu trúc ZZ0000ZZ hiện là
giới hạn ở bốn, như được chỉ định trong dòng 21-24 và cấu trúc của
câu lệnh “nếu” tiếp theo. Đối với hệ thống 32-bit, điều này cho phép
16*32*32*32=524.288 CPU, đủ cho một số CPU tiếp theo
ít nhất là nhiều năm. Đối với hệ thống 64 bit, CPU 16*64*64*64=4.194.304 là
được phép, điều này sẽ xảy ra với chúng ta trong khoảng thập kỷ tới. Cái này
cây bốn cấp cũng cho phép xây dựng hạt nhân bằng ZZ0001ZZ
để hỗ trợ tới 4096 CPU, có thể hữu ích trong các hệ thống rất lớn
có tám CPU trên mỗi socket (nhưng xin lưu ý rằng chưa có ai hiển thị
bất kỳ sự suy giảm hiệu suất nào có thể đo lường được do ổ cắm bị lệch và
ranh giới ZZ0002ZZ). Ngoài ra, việc xây dựng các hạt nhân với đầy đủ bốn
các cấp độ của cây ZZ0003ZZ cho phép thử nghiệm RCU tốt hơn
mã cây kết hợp.

Biểu tượng ZZ0000ZZ kiểm soát số lượng trẻ em được phép ở
mỗi cấp độ không có lá của cây ZZ0001ZZ. Nếu
Tùy chọn Kconfig ZZ0002ZZ không được chỉ định, nó được thiết lập dựa trên
về kích thước từ của hệ thống, đây cũng là mặc định của Kconfig.

Biểu tượng ZZ0000ZZ kiểm soát số lượng CPU được xử lý bởi
mỗi cấu trúc ZZ0001ZZ lá. Kinh nghiệm đã chỉ ra rằng việc cho phép một
cấu trúc lá ZZ0002ZZ đã cho để xử lý 64 CPU, theo sự cho phép của
số bit trong trường ZZ0003ZZ trên hệ thống 64 bit, dẫn đến
tranh chấp quá mức đối với cấu trúc ZZ0004ZZ của lá ZZ0005ZZ
lĩnh vực. Do đó, số lượng CPU trên mỗi cấu trúc ZZ0006ZZ lá là
giới hạn ở 16 với giá trị mặc định là ZZ0007ZZ. Nếu
ZZ0008ZZ chưa được chỉ định, giá trị được chọn dựa trên
về kích thước chữ của hệ thống, giống như đối với ZZ0009ZZ.
Các dòng 11-19 thực hiện phép tính này.

Các dòng 21-24 tính toán số lượng CPU tối đa được hỗ trợ bởi một
cấp độ đơn (chứa cấu trúc ZZ0000ZZ duy nhất),
cây ZZ0001ZZ hai cấp, ba cấp và bốn cấp tương ứng,
dựa trên fanout được chỉ định bởi ZZ0002ZZ và ZZ0003ZZ.
Số lượng CPU này được giữ lại trong ZZ0004ZZ,
Bộ tiền xử lý C ZZ0005ZZ, ZZ0006ZZ và ZZ0007ZZ
các biến tương ứng.

Các biến này được sử dụng để điều khiển câu lệnh ZZ0000ZZ của bộ tiền xử lý C
các dòng kéo dài 26-66 tính toán số lượng cấu trúc ZZ0001ZZ
cần thiết cho mỗi cấp độ của cây, cũng như số cấp độ
được yêu cầu. Số cấp độ được đặt trong ZZ0002ZZ
Biến tiền xử lý C theo dòng 27, 35, 44 và 54. Số lượng
Cấu trúc ZZ0003ZZ cho cấp cao nhất của cây luôn
chính xác là một, và giá trị này được đặt vô điều kiện vào
ZZ0004ZZ theo dòng 28, 36, 45 và 55. Các cấp độ còn lại
(nếu có) của cây ZZ0005ZZ được tính bằng cách chia giá trị lớn nhất
số lượng CPU theo fanout được hỗ trợ bởi số cấp độ từ
mức hiện tại xuống, làm tròn lên. Tính toán này được thực hiện bởi
các dòng 37, 46-47 và 56-58. Các dòng 31-33, 40-42, 50-52 và 62-63 tạo
công cụ khởi tạo cho tên lớp khóa lockdep. Cuối cùng, dòng 64-66 tạo ra
lỗi nếu số lượng CPU tối đa quá lớn so với quy định
fanout.

Cấu trúc ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấu trúc ZZ0000ZZ duy trì một danh sách gọi lại được phân đoạn
như sau:

::

1 #define RCU_DONE_TAIL 0
    2 #define RCU_WAIT_TAIL 1
    3 #define RCU_NEXT_READY_TAIL 2
    4 #define RCU_NEXT_TAIL 3
    5 #define RCU_CBLIST_NSEGS 4
    6
    7 cấu trúc rcu_segcblist {
    8 cấu trúc rcu_head *head;
    9 cấu trúc rcu_head **tails[RCU_CBLIST_NSEGS];
   10 gp_seq dài không dấu [RCU_CBLIST_NSEGS];
   11 len dài;
   dài 12 len_lazy;
   13 };

Các phân đoạn như sau:

#. ZZ0000ZZ: Lệnh gọi lại đã hết thời gian gia hạn. Những cái này
   cuộc gọi lại đã sẵn sàng để được gọi.
#. ZZ0001ZZ: Lệnh gọi lại đang chờ thời hạn hiện tại
   kỳ. Lưu ý rằng các CPU khác nhau có thể có những ý tưởng khác nhau về việc
   đang có thời gian gia hạn, do đó có trường ZZ0002ZZ.
#. ZZ0003ZZ: Cuộc gọi lại chờ thời gian gia hạn tiếp theo
   để bắt đầu.
#. ZZ0004ZZ: Lệnh gọi lại chưa được liên kết với
   thời gian ân hạn.

Con trỏ ZZ0000ZZ tham chiếu lệnh gọi lại đầu tiên hoặc là ZZ0001ZZ nếu
danh sách không chứa lệnh gọi lại (ZZ0007ZZ giống như trống).
Mỗi phần tử của mảng ZZ0002ZZ đều tham chiếu đến ZZ0003ZZ
con trỏ của lệnh gọi lại cuối cùng trong phân đoạn tương ứng của danh sách,
hoặc con trỏ ZZ0004ZZ của danh sách nếu phân đoạn đó và tất cả các phân đoạn trước đó
phân đoạn trống. Nếu đoạn tương ứng trống nhưng một số
đoạn trước không trống thì phần tử mảng giống hệt với
tiền thân của nó. Các cuộc gọi lại cũ hơn ở gần đầu danh sách hơn và
các cuộc gọi lại mới được thêm vào ở phần đuôi. Mối quan hệ này giữa
Con trỏ ZZ0005ZZ, mảng ZZ0006ZZ và các lệnh gọi lại được hiển thị
trong sơ đồ này:

.. kernel-figure:: nxtlist.svg

Trong hình này, con trỏ ZZ0000ZZ tham chiếu lệnh gọi lại RCU đầu tiên
trong danh sách. Phần tử mảng ZZ0001ZZ tham chiếu đến
Bản thân con trỏ ZZ0002ZZ, cho biết rằng không có lệnh gọi lại nào được
sẵn sàng kêu gọi. Tham chiếu phần tử mảng ZZ0003ZZ
gọi lại Con trỏ ZZ0004ZZ của CB 2, cho biết rằng CB 1 và CB 2
cả hai đều đang chờ đợi thời gian ân hạn hiện tại, cho hoặc nhận có thể
những bất đồng về chính xác thời gian gia hạn nào là thời gian hiện tại. các
Phần tử mảng ZZ0005ZZ tham chiếu cùng RCU
gọi lại mà ZZ0006ZZ thực hiện, điều này cho biết rằng
không có cuộc gọi lại nào đang chờ trong thời gian gia hạn RCU tiếp theo. các
Phần tử mảng ZZ0007ZZ tham chiếu ZZ0008ZZ của CB 4
con trỏ, cho biết rằng tất cả các cuộc gọi lại RCU còn lại vẫn chưa
đã được chỉ định vào thời gian gia hạn RCU. Lưu ý rằng
Phần tử mảng ZZ0009ZZ luôn tham chiếu RCU cuối cùng
con trỏ ZZ0010ZZ của lệnh gọi lại trừ khi danh sách gọi lại trống, trong
trường hợp này nó tham chiếu đến con trỏ ZZ0011ZZ.

Có thêm một trường hợp đặc biệt quan trọng đối với
Phần tử mảng ZZ0000ZZ: Nó có thể là ZZ0001ZZ khi điều này
danh sách là ZZ0002ZZ. Danh sách bị vô hiệu hóa khi CPU tương ứng bị vô hiệu hóa
ngoại tuyến hoặc khi các cuộc gọi lại của CPU tương ứng được chuyển sang
kthread, cả hai đều được mô tả ở nơi khác.

CPU chuyển các lệnh gọi lại của chúng từ ZZ0000ZZ sang
ZZ0001ZZ tới ZZ0002ZZ tới
ZZ0003ZZ liệt kê các phân đoạn khi thời gian gia hạn tăng lên.

Mảng ZZ0000ZZ ghi lại các số trong thời gian gia hạn tương ứng với
các phân đoạn danh sách. Đây là điều cho phép các CPU khác nhau có các
ý tưởng về thời gian gia hạn hiện tại trong khi vẫn tránh được
việc gọi lại sớm các cuộc gọi lại của họ. Đặc biệt, điều này cho phép CPU
không hoạt động trong thời gian dài để xác định cuộc gọi lại nào của họ
đã sẵn sàng để được gọi sau khi thức tỉnh lại.

Bộ đếm ZZ0000ZZ chứa số lượng cuộc gọi lại trong ZZ0001ZZ,
và ZZ0002ZZ chứa số lượng các cuộc gọi lại đó
chỉ được biết đến với bộ nhớ trống và do đó lệnh gọi của nó có thể được thực hiện một cách an toàn
hoãn lại.

.. important::

   Trường ZZ0000ZZ xác định xem có hay không
   không có cuộc gọi lại nào được liên kết với ZZ0001ZZ này
   cấu trúc, ZZ0012ZZ con trỏ ZZ0002ZZ. Lý do cho điều này là tất cả
   các lệnh gọi lại sẵn sàng gọi (nghĩa là các lệnh gọi trong ZZ0003ZZ
   phân đoạn) được trích xuất cùng một lúc tại thời điểm gọi lại
   (ZZ0004ZZ), do đó ZZ0005ZZ có thể được đặt thành NULL nếu có
   không có lệnh gọi lại nào chưa được thực hiện còn lại trong ZZ0006ZZ. Nếu
   việc gọi lại phải được hoãn lại, ví dụ, bởi vì một
   quy trình có mức độ ưu tiên cao vừa được kích hoạt trên CPU này, sau đó các quy trình còn lại
   các cuộc gọi lại được đặt trở lại trên phân đoạn ZZ0007ZZ và
   ZZ0008ZZ một lần nữa chỉ điểm bắt đầu của phân đoạn. Tóm lại,
   trường đầu có thể ngắn gọn là ZZ0009ZZ mặc dù CPU có lệnh gọi lại
   trình bày suốt thời gian qua. Vì vậy, việc kiểm tra các
   Con trỏ ZZ0010ZZ cho ZZ0011ZZ.
Ngược lại, số lượng ZZ0000ZZ và ZZ0001ZZ chỉ được điều chỉnh
sau khi các cuộc gọi lại tương ứng đã được gọi. Điều này có nghĩa là
Số lượng ZZ0002ZZ chỉ bằng 0 nếu cấu trúc ZZ0003ZZ thực sự
không có cuộc gọi lại. Tất nhiên, lấy mẫu CPU của ZZ0004ZZ
số lượng yêu cầu sử dụng cẩn thận sự đồng bộ hóa thích hợp, ví dụ:
rào cản trí nhớ. Sự đồng bộ hóa này có thể hơi tinh tế, đặc biệt
trong trường hợp ZZ0005ZZ.

Cấu trúc ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ duy trì trạng thái per-CPU cho hệ thống con RCU. các
các trường trong cấu trúc này chỉ có thể được truy cập từ CPU tương ứng
(và từ việc truy tìm) trừ khi có quy định khác. Cấu trúc này là trọng tâm
phát hiện trạng thái không hoạt động và xếp hàng gọi lại RCU. Nó cũng theo dõi
mối quan hệ của nó với cấu trúc ZZ0001ZZ lá tương ứng với
cho phép truyền các trạng thái không hoạt động hiệu quả hơn lên ZZ0002ZZ
cây kết hợp Giống như cấu trúc ZZ0003ZZ, nó cung cấp một địa chỉ cục bộ
bản sao thông tin trong thời gian gia hạn để cho phép đồng bộ hóa miễn phí
truy cập thông tin này từ CPU tương ứng. Cuối cùng, điều này
cấu trúc ghi lại trạng thái không hoạt động trong quá khứ cho CPU tương ứng và
cũng theo dõi số liệu thống kê.

Các trường của cấu trúc ZZ0000ZZ được thảo luận riêng lẻ và theo nhóm,
trong các phần sau.

Kết nối với các cấu trúc dữ liệu khác
'''''''''''''''''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 CPU int;
     2 cấu trúc rcu_node *mynode;
     3 grpmask dài không dấu;
     4 bool đã trực tuyến;

Trường ZZ0000ZZ chứa số CPU tương ứng và
Trường ZZ0001ZZ tham chiếu cấu trúc ZZ0002ZZ tương ứng.
ZZ0003ZZ được sử dụng để truyền các trạng thái tĩnh lên quá trình kết hợp
cây. Hai trường này là hằng số và do đó không yêu cầu
đồng bộ hóa.

Trường ZZ0000ZZ biểu thị bit trong ZZ0001ZZ
tương ứng với cấu trúc ZZ0002ZZ này và cũng được sử dụng khi
lan truyền trạng thái tĩnh. Cờ ZZ0003ZZ được đặt bất cứ khi nào
CPU tương ứng xuất hiện trực tuyến, có nghĩa là việc theo dõi các lỗi gỡ lỗi
không cần loại bỏ bất kỳ cấu trúc ZZ0004ZZ nào mà cờ này không có
thiết lập.

Theo dõi trạng thái không hoạt động và thời gian gia hạn
'''''''''''''''''''''''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 gp_seq dài không dấu;
     2 gp_seq_ Need dài không dấu;
     3 bool cpu_no_qs;
     4 bool core_needs_qs;
     5 bool gpwrap;

Trường ZZ0000ZZ là bản sao của trường cùng tên
trong cấu trúc ZZ0001ZZ và ZZ0002ZZ. các
Trường ZZ0003ZZ là bản sao của trường tương tự
tên trong cấu trúc rcu_node. Mỗi người có thể tụt lại phía sau một người
ZZ0004ZZ tương đương, nhưng ở ZZ0005ZZ và
Hạt nhân ZZ0006ZZ có thể bị tụt lại phía sau tùy ý so với CPU trong
chế độ dyntick-idle (nhưng các bộ đếm này sẽ bắt kịp khi thoát khỏi
chế độ dyntick-không tải). Nếu hai bit thấp hơn của ZZ0007ZZ nhất định
ZZ0008ZZ của cấu trúc bằng 0, thì cấu trúc ZZ0009ZZ này
tin rằng RCU không hoạt động.

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
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
+--------------------------------------------------------------------------------------- +

Cờ ZZ0000ZZ cho biết CPU chưa vượt qua
qua trạng thái không hoạt động, trong khi cờ ZZ0001ZZ biểu thị
rằng lõi RCU cần trạng thái không hoạt động từ CPU tương ứng.
Trường ZZ0002ZZ chỉ ra rằng CPU tương ứng vẫn được giữ nguyên
không hoạt động quá lâu khiến bộ đếm ZZ0003ZZ có nguy cơ bị tràn,
điều này sẽ khiến CPU bỏ qua các giá trị của bộ đếm trên
lần thoát tiếp theo khỏi chế độ chờ.

Xử lý gọi lại RCU
'''''''''''''''''''''

Trong trường hợp không có sự kiện CPU-hotplug, lệnh gọi lại RCU sẽ được gọi bởi
cùng CPU đã đăng ký chúng. Đây thực sự là một địa phương bộ đệm
tối ưu hóa: lệnh gọi lại có thể và thực sự được gọi trên các CPU không phải là
một trong đó đã đăng ký chúng. Rốt cuộc, nếu CPU đã đăng ký một địa chỉ nhất định
cuộc gọi lại đã ngoại tuyến trước khi cuộc gọi lại có thể được gọi, ở đó
thực sự không còn lựa chọn nào khác.

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 danh sách cblist rcu_segcblist;
    2 qlen_last_fqs_check dài;
    3 n_cbs_invoked dài không dấu;
    4 n_nocbs_invoked dài không dấu;
    5 n_cbs_orphaned dài không dấu;
    6 n_cbs_adopted dài không dấu;
    7 n_force_qs_snap dài không dấu;
    8 giới hạn dài;

Cấu trúc ZZ0000ZZ là danh sách gọi lại được phân đoạn được mô tả
trước đó. CPU nâng cao các lệnh gọi lại trong cấu trúc ZZ0001ZZ của nó
bất cứ khi nào nó thông báo rằng một thời gian gia hạn RCU khác đã hoàn thành. CPU
phát hiện việc hoàn thành thời gian gia hạn RCU bằng cách nhận thấy rằng giá trị
của trường ZZ0003ZZ của cấu trúc ZZ0002ZZ của nó khác với trường của
cấu trúc lá ZZ0004ZZ của nó. Hãy nhớ lại rằng mỗi ZZ0005ZZ
Trường ZZ0006ZZ của cấu trúc được cập nhật ở phần đầu và phần cuối của
từng thời gian ân hạn.

ZZ0000ZZ và ZZ0001ZZ phối hợp
buộc ZZ0002ZZ và bạn bè phải chuyển sang trạng thái không hoạt động khi
danh sách gọi lại phát triển quá dài.

ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ
các trường đếm số lượng cuộc gọi lại được gọi, được gửi đến các CPU khác khi
CPU này ngoại tuyến và được nhận từ các CPU khác khi các CPU khác
CPU ngoại tuyến. ZZ0003ZZ được sử dụng khi CPU
các cuộc gọi lại được giảm tải xuống một kthread.

Cuối cùng, bộ đếm ZZ0000ZZ là số lần gọi lại RCU tối đa
có thể được gọi vào một thời điểm nhất định.

Xử lý nhàn rỗi Dyntick
'''''''''''''''''''''

Phần này của cấu trúc ZZ0000ZZ được khai báo như sau:

::

1 int đang xem_snap;
     2 dynticks_fqs dài không dấu;

Trường ZZ0000ZZ được sử dụng để chụp ảnh nhanh
trạng thái không tải dyntick tương ứng của CPU khi buộc các trạng thái không hoạt động,
và do đó được truy cập từ các CPU khác. Cuối cùng,
Trường ZZ0001ZZ dùng để đếm số lần CPU này
được xác định là ở trạng thái không hoạt động và được sử dụng để theo dõi và
mục đích gỡ lỗi.

Phần này của cấu trúc rcu_data được khai báo như sau:

::

1 tổ dài;
     2 nmi_lồng dài;
     3 dyntick nguyên tử;
     4 bool rcu_need_heavy_qs;
     5 bool rcu_surgical_qs;

Các trường này trong cấu trúc rcu_data duy trì trạng thái không hoạt động trên mỗi CPU
trạng thái cho CPU tương ứng. Các trường chỉ có thể được truy cập từ
CPU tương ứng (và từ truy tìm) trừ khi có quy định khác.

Trường ZZ0000ZZ đếm độ sâu lồng ghép của quy trình
thực thi, sao cho trong trường hợp bình thường bộ đếm này có giá trị bằng 0
hoặc một. NMI, irq và công cụ theo dõi được tính bằng
Trường ZZ0001ZZ. Bởi vì NMI không thể bị che giấu nên những thay đổi
biến này phải được thực hiện cẩn thận bằng thuật toán
được cung cấp bởi Andy Lutomirski. Quá trình chuyển đổi ban đầu từ trạng thái không hoạt động sẽ thêm một,
và các chuyển tiếp lồng nhau thêm hai, sao cho mức độ lồng ghép là năm
được biểu thị bằng giá trị ZZ0002ZZ là chín. quầy này
do đó có thể được coi là đếm số lý do tại sao điều này
CPU không được phép vào chế độ không tải, ngoại trừ
chuyển đổi cấp độ quá trình.

Tuy nhiên, hóa ra là khi chạy trong bối cảnh kernel không nhàn rỗi,
Nhân Linux hoàn toàn có khả năng nhập các trình xử lý ngắt mà không bao giờ
thoát ra và có lẽ ngược lại. Vì vậy, bất cứ khi nào
Trường ZZ0000ZZ được tăng lên từ 0,
Trường ZZ0001ZZ được đặt thành số dương lớn và
bất cứ khi nào trường ZZ0002ZZ giảm xuống 0,
trường ZZ0003ZZ được đặt thành 0. Giả sử rằng
số lượng các ngắt lồng sai không đủ để làm tràn bộ nhớ
bộ đếm, phương pháp này sẽ sửa trường ZZ0004ZZ
mỗi khi CPU tương ứng bước vào vòng lặp nhàn rỗi từ quá trình
bối cảnh.

Trường ZZ0000ZZ đếm các lần chuyển tiếp của CPU tương ứng sang
và từ chế độ dyntick-idle hoặc chế độ người dùng, để bộ đếm này có
giá trị chẵn khi CPU ở chế độ không tải hoặc chế độ người dùng và giá trị lẻ
giá trị khác. Cần phải tính các chuyển đổi sang/từ chế độ người dùng
để biết hỗ trợ các dấu kiểm thích ứng ở chế độ người dùng (xem Tài liệu/bộ hẹn giờ/no_hz.rst).

Trường ZZ0000ZZ được sử dụng để ghi lại thực tế là
Mã lõi RCU thực sự muốn thấy trạng thái không hoạt động từ
tương ứng với CPU, nhiều đến mức sẵn sàng yêu cầu
hoạt động truy cập dyntick hạng nặng. Cờ này được kiểm tra bởi RCU
chuyển ngữ cảnh và mã ZZ0001ZZ, cung cấp tạm thời
nhàn rỗi để đáp lại.

Cuối cùng, trường ZZ0000ZZ được sử dụng để ghi lại thực tế rằng
mã lõi RCU thực sự muốn thấy trạng thái không hoạt động từ
CPU tương ứng, với các trường khác cho biết cách
thật tệ là RCU muốn trạng thái không hoạt động này. Cờ này được kiểm tra bởi RCU
đường dẫn chuyển ngữ cảnh (ZZ0001ZZ) và cond_resched
mã.

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
+--------------------------------------------------------------------------------------- +

Các trường bổ sung có sẵn cho một số bản dựng có mục đích đặc biệt và được
được thảo luận riêng.

Cấu trúc ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~

Mỗi cấu trúc ZZ0000ZZ đại diện cho một lệnh gọi lại RCU. Những cấu trúc này
thường được nhúng trong các cấu trúc dữ liệu được bảo vệ RCU có
thuật toán sử dụng thời gian gia hạn không đồng bộ. Ngược lại, khi sử dụng
thuật toán chặn chờ thời gian gia hạn RCU, người dùng RCU không cần
cung cấp cấu trúc ZZ0001ZZ.

Cấu trúc ZZ0000ZZ có các trường như sau:

::

1 cấu trúc rcu_head *next;
     2 khoảng trống (*func)(struct rcu_head *head);

Trường ZZ0000ZZ được sử dụng để liên kết các cấu trúc ZZ0001ZZ
cùng nhau trong các danh sách trong cấu trúc ZZ0002ZZ. ZZ0003ZZ
trường là một con trỏ tới hàm được gọi khi lệnh gọi lại được thực hiện
sẵn sàng được gọi và hàm này được truyền một con trỏ tới
Cấu trúc ZZ0004ZZ. Tuy nhiên, ZZ0005ZZ sử dụng ZZ0006ZZ
trường để ghi lại phần bù của cấu trúc ZZ0007ZZ trong
kèm theo cấu trúc dữ liệu được bảo vệ RCU.

Cả hai trường này đều được RCU sử dụng nội bộ. Từ quan điểm của
Người dùng RCU, cấu trúc này là một “cookie” mờ đục.

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
+--------------------------------------------------------------------------------------- +

Các trường cụ thể của RCU trong cấu trúc ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Việc triển khai ZZ0000ZZ sử dụng một số trường bổ sung trong
cấu trúc ZZ0001ZZ:

::

1 #ifdef CONFIG_PREEMPT_RCU
    2 int rcu_read_lock_nesting;
    3 đoàn rcu_special rcu_read_unlock_special;
    4 cấu trúc list_head rcu_node_entry;
    5 cấu trúc rcu_node *rcu_blocked_node;
    6 #endif /* #ifdef CONFIG_PREEMPT_RCU */
    7 #ifdef CONFIG_TASKS_RCU
    8 rcu_tasks_nvcsw dài không dấu;
    9 bool rcu_tasks_holdout;
   10 cấu trúc list_head rcu_tasks_holdout_list;
   11 int rcu_tasks_idle_cpu;
   12 #endif /* #ifdef CONFIG_TASKS_RCU */

Trường ZZ0000ZZ ghi lại mức lồng nhau cho RCU
các phần quan trọng phía đọc và trường ZZ0001ZZ
là một bitmask ghi lại các điều kiện đặc biệt yêu cầu
ZZ0002ZZ để làm công việc bổ sung. ZZ0003ZZ
trường được sử dụng để tạo danh sách các tác vụ đã bị chặn trong
preemptible-RCU phần quan trọng bên đọc và
Trường ZZ0004ZZ tham chiếu cấu trúc ZZ0005ZZ có
liệt kê tác vụ này là thành viên của hoặc ZZ0006ZZ nếu nó không bị chặn trong một
preemptible-RCU phần quan trọng bên đọc.

Trường ZZ0000ZZ theo dõi số lượng bối cảnh tự nguyện
các chuyển đổi mà tác vụ này đã trải qua khi bắt đầu nhiệm vụ hiện tại
nhiệm vụ-RCU thời gian gia hạn, ZZ0001ZZ được đặt nếu hiện tại
nhiệm vụ-RCU thời gian gia hạn đang chờ nhiệm vụ này,
ZZ0002ZZ là một phần tử danh sách thực hiện nhiệm vụ này trên
danh sách giữ lại và ZZ0003ZZ theo dõi CPU nào
tác vụ nhàn rỗi đang chạy, nhưng chỉ khi tác vụ đó hiện đang chạy thì
là nếu CPU hiện không hoạt động.

Hàm truy cập
~~~~~~~~~~~~~~~~~~

Danh sách sau đây cho thấy ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ
chức năng và macro:

::

1 cấu trúc tĩnh rcu_node *rcu_get_root(struct rcu_state *rsp)
     2 {
     3 trả về &rsp->node[0];
     4 }
     5
     6 #define rcu_for_each_node_breadth_first(rsp, rnp) \
     7 cho ((rnp) = &(rsp)->node[0]; \
     8 (rnp) < &(rsp)->node[NUM_RCU_NODES]; (rnp)++)
     9
    10 #define rcu_for_each_leaf_node(rsp, rnp) \
    11 cho ((rnp) = (rsp)->level[NUM_RCU_LVLS - 1]; \
    12 (rnp) < &(rsp)->node[NUM_RCU_NODES]; (rnp)++)

ZZ0000ZZ chỉ đơn giản trả về một con trỏ tới phần tử đầu tiên của
Mảng ZZ0002ZZ của cấu trúc ZZ0001ZZ được chỉ định, là mảng
cấu trúc gốc ZZ0003ZZ.

Như đã lưu ý trước đó, macro ZZ0000ZZ sử dụng
lợi thế của cách bố trí các cấu trúc ZZ0001ZZ trong
Mảng ZZ0003ZZ của cấu trúc ZZ0002ZZ, thực hiện thao tác theo chiều rộng
duyệt bằng cách duyệt mảng theo thứ tự. Tương tự, các
Macro ZZ0004ZZ chỉ đi qua phần cuối cùng của
mảng, do đó chỉ đi qua các cấu trúc ZZ0005ZZ lá.

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
+--------------------------------------------------------------------------------------- +

Bản tóm tắt
~~~~~~~

Vì vậy, trạng thái của RCU được biểu thị bằng cấu trúc ZZ0000ZZ,
chứa một cây kết hợp các cấu trúc ZZ0001ZZ và ZZ0002ZZ.
Cuối cùng, trong các hạt nhân ZZ0003ZZ, trạng thái không hoạt động của mỗi CPU
được theo dõi bởi các trường liên quan đến dynticks trong cấu trúc ZZ0004ZZ. Nếu
bạn đã làm được đến mức này, bạn đã chuẩn bị tốt để đọc mã
hướng dẫn trong các bài viết khác trong loạt bài này.

Lời cảm ơn
~~~~~~~~~~~~~~~

Tôi nợ Cyrill Gorcunov, Mathieu Desnoyers, Dhaval Giani, Paul
Turner, Abhishek Srivastava, Matt Kowalczyk và Serge Hallyn cho
giúp tôi đưa tài liệu này vào trạng thái dễ đọc hơn.

Tuyên bố pháp lý
~~~~~~~~~~~~~~~

Tác phẩm này thể hiện quan điểm của tác giả và không nhất thiết
đại diện cho quan điểm của IBM.

Linux là nhãn hiệu đã đăng ký của Linus Torvalds.

Tên công ty, sản phẩm và dịch vụ khác có thể là nhãn hiệu hoặc dịch vụ
dấu ấn của người khác.
