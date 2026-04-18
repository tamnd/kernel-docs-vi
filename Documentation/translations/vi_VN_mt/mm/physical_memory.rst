.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/physical_memory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Bộ nhớ vật lý
=================

Linux có sẵn cho nhiều loại kiến trúc nên cần có một
sự trừu tượng hóa độc lập với kiến trúc để thể hiện bộ nhớ vật lý. Cái này
chương mô tả các cấu trúc được sử dụng để quản lý bộ nhớ vật lý trong một hệ thống đang chạy.
hệ thống.

Khái niệm cơ bản đầu tiên phổ biến trong quản lý bộ nhớ là
ZZ0000ZZ.
Với máy đa lõi và nhiều socket, bộ nhớ có thể được sắp xếp thành các dãy
phải chịu một chi phí khác nhau để truy cập tùy thuộc vào “khoảng cách” từ
bộ xử lý. Ví dụ: có thể có một dãy bộ nhớ được gán cho mỗi CPU hoặc
một bộ nhớ rất phù hợp cho DMA gần các thiết bị ngoại vi.

Mỗi ngân hàng được gọi là một nút và khái niệm này được thể hiện trong Linux bằng một
ZZ0000ZZ ngay cả khi kiến trúc là UMA. Cấu trúc này là
luôn được tham chiếu bởi typedef ZZ0001ZZ của nó. Cấu trúc ZZ0002ZZ
đối với một nút cụ thể có thể được tham chiếu bởi macro ZZ0003ZZ trong đó
ZZ0004ZZ là ID của nút đó.

Đối với kiến trúc NUMA, cấu trúc nút được phân bổ theo kiến trúc
mã cụ thể sớm trong khi khởi động. Thông thường, các cấu trúc này được phân bổ
cục bộ trên ngân hàng bộ nhớ mà họ đại diện. Đối với kiến trúc UMA, chỉ có một
cấu trúc ZZ0001ZZ tĩnh gọi là ZZ0002ZZ được sử dụng. Các nút sẽ
sẽ được thảo luận thêm trong Phần ZZ0000ZZ

Toàn bộ không gian địa chỉ vật lý được phân chia thành một hoặc nhiều khối
được gọi là các vùng đại diện cho các phạm vi trong bộ nhớ. Các phạm vi này thường
được xác định bởi các ràng buộc kiến trúc để truy cập bộ nhớ vật lý.
Phạm vi bộ nhớ trong một nút tương ứng với một vùng cụ thể là
được mô tả bởi ZZ0000ZZ. Mỗi vùng có
một trong những loại được mô tả dưới đây.

* ZZ0000ZZ và ZZ0001ZZ trong lịch sử đại diện cho bộ nhớ phù hợp cho
  DMA bởi các thiết bị ngoại vi không thể truy cập tất cả địa chỉ
  trí nhớ. Trong nhiều năm, có nhiều giao diện tốt hơn và mạnh mẽ hơn để có được
  bộ nhớ với các yêu cầu cụ thể của DMA (Tài liệu/core-api/dma-api.rst),
  nhưng ZZ0002ZZ và ZZ0003ZZ vẫn đại diện cho các dải bộ nhớ có
  hạn chế về cách chúng có thể được truy cập.
  Tùy thuộc vào kiến trúc, một trong hai loại vùng này hoặc thậm chí cả hai
  có thể bị vô hiệu hóa tại thời điểm xây dựng bằng ZZ0004ZZ và
  Tùy chọn cấu hình ZZ0005ZZ. Một số nền tảng 64-bit có thể cần
  cả hai vùng vì chúng hỗ trợ các thiết bị ngoại vi có địa chỉ DMA khác nhau
  những hạn chế.

* ZZ0000ZZ dành cho bộ nhớ bình thường có thể được truy cập bởi kernel
  thời gian. Các hoạt động DMA có thể được thực hiện trên các trang trong vùng này nếu DMA
  các thiết bị hỗ trợ chuyển đến tất cả các bộ nhớ có địa chỉ. ZZ0001ZZ là
  luôn được kích hoạt.

* ZZ0000ZZ là một phần của bộ nhớ vật lý không được bao phủ bởi
  ánh xạ vĩnh viễn trong các bảng trang kernel. Bộ nhớ trong vùng này chỉ
  có thể truy cập vào kernel bằng cách sử dụng ánh xạ tạm thời. Vùng này có sẵn
  chỉ trên một số kiến trúc 32-bit và được kích hoạt với ZZ0001ZZ.

* ZZ0000ZZ dành cho bộ nhớ có thể truy cập thông thường, giống như ZZ0001ZZ.
  Sự khác biệt là nội dung của hầu hết các trang trong ZZ0002ZZ là
  di chuyển được. Điều đó có nghĩa là mặc dù địa chỉ ảo của các trang này không
  thay đổi, nội dung của chúng có thể di chuyển giữa các trang vật lý khác nhau. Thường xuyên
  ZZ0003ZZ được đưa vào trong quá trình cắm nóng bộ nhớ, nhưng có thể
  cũng được đưa vào khi khởi động bằng một trong các ZZ0004ZZ, ZZ0005ZZ và
  Tham số dòng lệnh kernel ZZ0006ZZ. Xem
  Tài liệu/mm/page_migration.rst và
  Documentation/admin-guide/mm/memory-hotplug.rst để biết thêm chi tiết.

* ZZ0001ZZ đại diện cho bộ nhớ nằm trên các thiết bị như PMEM và GPU.
  Nó có các đặc điểm khác với các loại vùng RAM và nó tồn tại để cung cấp
  ZZ0000ZZ và dịch vụ bản đồ bộ nhớ cho trình điều khiển thiết bị
  phạm vi địa chỉ vật lý được xác định. ZZ0002ZZ được kích hoạt với
  tùy chọn cấu hình ZZ0003ZZ.

Điều quan trọng cần lưu ý là nhiều thao tác kernel chỉ có thể diễn ra bằng cách sử dụng
ZZ0001ZZ vì vậy đây là vùng quan trọng nhất về hiệu suất. Các khu vực là
được thảo luận thêm trong Phần ZZ0000ZZ.

Mối quan hệ giữa phạm vi nút và vùng được xác định bởi bộ nhớ vật lý
bản đồ được báo cáo bởi phần sụn, các ràng buộc về kiến trúc cho việc đánh địa chỉ bộ nhớ
và một số tham số nhất định trong dòng lệnh kernel.

Ví dụ: với kernel 32-bit trên máy x86 UMA có 2 Gbyte RAM,
toàn bộ bộ nhớ sẽ nằm trên nút 0 và sẽ có ba vùng: ZZ0000ZZ,
ZZ0001ZZ và ZZ0002ZZ::

0 2G
  +-------------------------------------------------------------------------- +
  ZZ0000ZZ
  +-------------------------------------------------------------------------- +

0 16M 896M 2G
  +----------+--------------+-----------------+
  ZZ0000ZZ ZONE_NORMAL ZZ0001ZZ
  +----------+--------------+-----------------+


Với một kernel được xây dựng với ZZ0000ZZ bị vô hiệu hóa và ZZ0001ZZ được kích hoạt và
được khởi động với tham số ZZ0002ZZ trên máy arm64 có 16 Gbyte
RAM được chia đều cho hai nút, sẽ có ZZ0003ZZ,
ZZ0004ZZ và ZZ0005ZZ trên nút 0, ZZ0006ZZ và
ZZ0007ZZ trên nút 1::


1G 9G 17G
  +--------------------------------+ +--------------------------+
  ZZ0000ZZ ZZ0001ZZ
  +--------------------------------+ +--------------------------+

1G 4G 4200M 9G 9320M 17G
  +----------+----------+-------------+ +-------------+-------------+
  ZZ0000ZZ NORMAL ZZ0001ZZ ZZ0002ZZ MOVABLE |
  +----------+----------+-------------+ +-------------+-------------+


Ngân hàng bộ nhớ có thể thuộc về các nút xen kẽ. Trong ví dụ bên dưới x86
máy có 16 Gbyte RAM trong 4 ngân hàng bộ nhớ, thậm chí các ngân hàng thuộc nút 0
và ngân hàng lẻ thuộc nút 1::


0 4G 8G 12G 16G
  +-------------+ +-------------+ +-------------+ +-------------+
  ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
  +-------------+ +-------------+ +-------------+ +-------------+

0 16M 4G
  +------+-------+ +-------------+ +-------------+ +-------------+
  ZZ0000ZZ DMA32 ZZ0001ZZ NORMAL ZZ0002ZZ NORMAL ZZ0003ZZ NORMAL |
  +------+-------+ +-------------+ +-------------+ +-------------+

Trong trường hợp này, nút 0 sẽ trải dài từ 0 đến 12 Gbyte và nút 1 sẽ trải dài từ
4 đến 16 Gbyte.

.. _nodes:

Nút
=====

Như chúng tôi đã đề cập, mỗi nút trong bộ nhớ được mô tả bởi một ZZ0000ZZ.
là một typedef cho ZZ0001ZZ. Khi phân bổ một trang, theo mặc định
Linux sử dụng chính sách phân bổ nút cục bộ để phân bổ bộ nhớ từ nút
gần nhất với CPU đang chạy. Vì các tiến trình có xu hướng chạy trên cùng một CPU, nên
có khả năng bộ nhớ từ nút hiện tại sẽ được sử dụng. Chính sách phân bổ có thể
được kiểm soát bởi người dùng như được mô tả trong
Tài liệu/admin-guide/mm/numa_memory_policy.rst.

Hầu hết các kiến trúc NUMA đều duy trì một loạt các con trỏ tới nút
các cấu trúc. Các cấu trúc thực tế được phân bổ sớm trong quá trình khởi động khi
mã cụ thể của kiến trúc phân tích bản đồ bộ nhớ vật lý được báo cáo bởi
phần sụn. Phần lớn quá trình khởi tạo nút diễn ra muộn hơn một chút trong
quá trình khởi động bằng hàm free_area_init(), được mô tả sau trong Phần
ZZ0000ZZ.


Cùng với các cấu trúc nút, kernel duy trì một mảng ZZ0000ZZ
mặt nạ bit được gọi là ZZ0001ZZ. Mỗi bitmask trong mảng này đại diện cho một tập hợp
các nút có thuộc tính cụ thể được xác định bởi ZZ0002ZZ:

ZZ0000ZZ
  Nút có thể trực tuyến vào một lúc nào đó.
ZZ0001ZZ
  Nút này đang trực tuyến.
ZZ0002ZZ
  Nút có bộ nhớ thường xuyên.
ZZ0003ZZ
  Nút có bộ nhớ thông thường hoặc cao. Khi ZZ0004ZZ bị tắt
  bí danh là ZZ0005ZZ.
ZZ0006ZZ
  Nút có bộ nhớ (thông thường, cao, có thể di chuyển)
ZZ0007ZZ
  Nút có một hoặc nhiều CPU
ZZ0008ZZ
  Nút có một hoặc nhiều Bộ khởi tạo chung

Đối với mỗi nút có thuộc tính được mô tả ở trên, bit tương ứng với
ID nút trong bitmask ZZ0000ZZ được đặt.

Ví dụ: đối với nút 2 có bộ nhớ và CPU thông thường, bit 2 sẽ được đặt trong ::

nút_states[N_POSSIBLE]
  nút_states[N_ONLINE]
  nút_states[N_NORMAL_MEMORY]
  nút_states[N_HIGH_MEMORY]
  nút_states[N_MEMORY]
  nút_states[N_CPU]

Để biết các hoạt động khác nhau có thể thực hiện được với nodemasks, vui lòng tham khảo
ZZ0000ZZ.

Trong số những thứ khác, mặt nạ nút được sử dụng để cung cấp macro cho việc truyền tải nút,
cụ thể là ZZ0000ZZ và ZZ0001ZZ.

Ví dụ: để gọi hàm foo() cho mỗi nút trực tuyến::

for_each_online_node(nid) {
		pg_data_t *pgdat = NODE_DATA(nid);

foo(pgdat);
	}

Cấu trúc nút
--------------

Cấu trúc nút ZZ0000ZZ được khai báo trong
ZZ0001ZZ. Ở đây chúng tôi mô tả ngắn gọn các lĩnh vực này
cấu trúc:

Tổng quan
~~~~~~~

ZZ0000ZZ
  Các vùng cho nút này.  Không phải tất cả các khu vực đều có thể có dân cư sinh sống, nhưng nó
  danh sách đầy đủ. Nó được tham chiếu bởi node_zonelists của nút này cũng như
  node_zonelists của nút khác.

ZZ0000ZZ
  Danh sách tất cả các vùng trong tất cả các nút. Danh sách này xác định thứ tự các vùng
  việc phân bổ đó được ưu tiên hơn. ZZ0001ZZ được thiết lập bởi
  ZZ0002ZZ trong ZZ0003ZZ trong quá trình khởi tạo
  cấu trúc quản lý bộ nhớ cốt lõi.

ZZ0000ZZ
  Số vùng dân cư trong nút này.

ZZ0000ZZ
  Đối với các hệ thống UMA sử dụng kiểu bộ nhớ FLATMEM, nút 0
  ZZ0001ZZ là mảng các trang cấu trúc đại diện cho từng khung vật lý.

ZZ0000ZZ
  Đối với các hệ thống UMA sử dụng kiểu bộ nhớ FLATMEM, nút 0
  ZZ0001ZZ là mảng mở rộng của các trang cấu trúc. Chỉ có sẵn
  trong các hạt nhân được xây dựng với kích hoạt ZZ0002ZZ.

ZZ0000ZZ
  Số khung trang của khung trang bắt đầu trong nút này.

ZZ0000ZZ
  Tổng số trang vật lý có trong nút này.

ZZ0000ZZ
  Tổng kích thước của phạm vi trang vật lý, bao gồm cả các lỗ.

ZZ0000ZZ
  Một khóa bảo vệ các trường xác định phạm vi nút. Chỉ được xác định khi
  ít nhất một trong số ZZ0001ZZ hoặc
  Tùy chọn cấu hình ZZ0002ZZ được bật.
  ZZ0003ZZ và ZZ0004ZZ được cung cấp cho
  thao tác ZZ0005ZZ mà không kiểm tra ZZ0006ZZ
  hoặc ZZ0007ZZ.

ZZ0000ZZ
  ID nút (NID) của nút, bắt đầu từ 0.

ZZ0000ZZ
  Đây là bản dự trữ trên mỗi nút của các trang không có sẵn cho không gian người dùng
  phân bổ.

ZZ0000ZZ
  Nếu việc khởi tạo bộ nhớ trên các máy lớn bị trì hoãn thì đây là lần đầu tiên
  PFN cần được khởi tạo. Chỉ xác định khi
  ZZ0001ZZ được kích hoạt

ZZ0000ZZ
  Hàng đợi mỗi nút của các trang lớn mà việc phân chia của chúng đã bị trì hoãn. Chỉ được xác định khi ZZ0001ZZ được bật.

ZZ0000ZZ
  lruvec trên mỗi nút chứa danh sách LRU và các tham số liên quan. Chỉ được sử dụng khi
  nhóm bộ nhớ bị vô hiệu hóa. Nó không nên được truy cập trực tiếp, sử dụng
  ZZ0001ZZ để tra cứu lruvecs.

Đòi lại quyền kiểm soát
~~~~~~~~~~~~~~~

Xem thêm Tài liệu/mm/page_reclaim.rst.

ZZ0000ZZ
  Phiên bản trên mỗi nút của luồng hạt nhân kswapd.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ
  Hàng đợi công việc được sử dụng để đồng bộ hóa các tác vụ lấy lại bộ nhớ

ZZ0000ZZ
  Số lượng tác vụ được điều chỉnh đang chờ dọn dẹp trên các trang bẩn.

ZZ0000ZZ
  Số lượng trang được viết trong khi lấy lại được điều chỉnh để chờ viết lại.

ZZ0000ZZ
  Kiểm soát thứ tự kswapd cố gắng lấy lại

ZZ0000ZZ
  Chỉ số vùng cao nhất được kswapd lấy lại

ZZ0000ZZ
  Số lần chạy kswapd không thể lấy lại bất kỳ trang nào

ZZ0000ZZ
  Số lượng tối thiểu các trang hỗ trợ tệp chưa được ánh xạ và không thể lấy lại được.
  Được xác định bởi ZZ0001ZZ sysctl. Chỉ được xác định khi
  ZZ0002ZZ được kích hoạt.

ZZ0000ZZ
  Số lượng trang SLAB tối thiểu không thể lấy lại được. Xác định bởi
  ZZ0001ZZ. Chỉ được xác định khi ZZ0002ZZ được bật

ZZ0000ZZ
  Cờ kiểm soát hành vi thu hồi.

Kiểm soát nén
~~~~~~~~~~~~~~~~~~

ZZ0000ZZ
  Thứ tự trang mà kcompactd nên cố gắng đạt được.

ZZ0000ZZ
  Chỉ số vùng cao nhất được nén bởi kcompactd.

ZZ0000ZZ
  Hàng đợi được sử dụng để đồng bộ hóa các tác vụ nén bộ nhớ.

ZZ0000ZZ
  Phiên bản trên mỗi nút của luồng hạt nhân kcompactd.

ZZ0000ZZ
  Xác định xem tính năng nén chủ động có được bật hay không. Kiểm soát bởi
  Hệ thống ZZ0001ZZ.

Thống kê
~~~~~~~~~~

ZZ0000ZZ
  Thống kê Per-CPU VM cho nút

ZZ0000ZZ
  Thống kê VM cho nút.

.. _zones:

Khu vực
=====
Như chúng tôi đã đề cập, mỗi vùng trong bộ nhớ được mô tả bởi ZZ0000ZZ
là một phần tử của mảng ZZ0001ZZ của nút mà nó thuộc về.
ZZ0002ZZ là cấu trúc dữ liệu cốt lõi của bộ cấp phát trang. Một khu vực
đại diện cho một phạm vi bộ nhớ vật lý và có thể có lỗ hổng.

Bộ cấp phát trang sử dụng cờ GFP, xem ZZ0000ZZ, được chỉ định bởi
phân bổ bộ nhớ để xác định vùng cao nhất trong một nút mà từ đó
cấp phát bộ nhớ có thể cấp phát bộ nhớ. Bộ cấp phát trang đầu tiên cấp phát bộ nhớ
từ vùng đó, nếu người cấp phát trang không thể phân bổ số lượng được yêu cầu
bộ nhớ từ vùng đó, nó sẽ phân bổ bộ nhớ từ vùng thấp hơn tiếp theo trong vùng đó.
nút, quá trình tiếp tục đến và bao gồm cả vùng thấp nhất. Ví dụ, nếu
một nút chứa ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ và
vùng phân bổ bộ nhớ cao nhất là ZZ0004ZZ, thứ tự của các vùng
từ đó bộ cấp phát trang phân bổ bộ nhớ là ZZ0005ZZ >
ZZ0006ZZ > ZZ0007ZZ.

Trong thời gian chạy, các trang miễn phí trong một vùng nằm trong Bộ trang Per-CPU (PCP) hoặc các khu vực miễn phí
của khu vực. Bộ trang Per-CPU là một cơ chế quan trọng trong bộ nhớ của kernel
hệ thống quản lý. Bằng cách xử lý các phân bổ thường xuyên nhất và giải phóng cục bộ trên
mỗi CPU, Bộ trang Per-CPU đều cải thiện hiệu suất và khả năng mở rộng, đặc biệt là
trên các hệ thống có nhiều lõi. Bộ cấp phát trang trong kernel sử dụng cơ chế hai bước
chiến lược phân bổ bộ nhớ, bắt đầu với Bộ trang Per-CPU trước
quay trở lại với người cấp phát bạn bè. Các trang được chuyển giữa Per-CPU
Các trang và khu vực miễn phí toàn cầu (được quản lý bởi người cấp phát bạn bè) theo đợt.
Điều này giảm thiểu chi phí tương tác thường xuyên với người bạn toàn cầu
người cấp phát.

Mã cụ thể của kiến ​​trúc gọi free_area_init() để khởi tạo các vùng.

Cấu trúc vùng
--------------
Cấu trúc vùng ZZ0000ZZ được xác định trong ZZ0001ZZ.
Ở đây chúng tôi mô tả ngắn gọn các trường của cấu trúc này:

Tổng quan
~~~~~~~

ZZ0000ZZ
  Hình mờ cho vùng này. Khi số lượng trang trống trong một vùng thấp hơn
  hình mờ tối thiểu, việc tăng cường bị bỏ qua, việc phân bổ có thể kích hoạt trực tiếp
  thu hồi và nén trực tiếp, nó cũng được sử dụng để điều tiết thu hồi trực tiếp.
  Khi số lượng trang trống trong một vùng thấp hơn hình mờ thấp, kswapd là
  thức dậy. Khi số lượng trang trống trong một vùng cao hơn hình mờ cao,
  kswapd ngừng thu hồi (một vùng được cân bằng) khi
  Bit ZZ0001ZZ của ZZ0002ZZ thì không
  thiết lập. Hình mờ quảng cáo được sử dụng để phân tầng bộ nhớ và cân bằng NUMA. Khi nào
  số lượng trang miễn phí trong một vùng cao hơn hình mờ quảng cáo, kswapd sẽ dừng
  lấy lại khi bit ZZ0003ZZ của
  ZZ0004ZZ được thiết lập. Hình mờ được thiết lập bởi
  ZZ0005ZZ. Hình mờ tối thiểu được tính theo
  Hệ thống ZZ0006ZZ. Ba hình mờ còn lại được đặt theo
  đến khoảng cách giữa hai hình mờ. Khoảng cách chính nó được tính toán
  tính đến ZZ0007ZZ sysctl.

ZZ0000ZZ
  Số lượng trang được sử dụng để tăng hình mờ nhằm tăng khả năng thu hồi
  áp lực giảm khả năng xảy ra tình trạng dự phòng trong tương lai và đánh thức kswapd ngay bây giờ
  vì nút có thể được cân bằng về tổng thể và kswapd sẽ không hoạt động một cách tự nhiên.

ZZ0000ZZ
  Số lượng trang được dành riêng cho phân bổ nguyên tử bậc cao.

ZZ0000ZZ
  Số lượng trang miễn phí trong các khối trang nguyên tử cao dành riêng

ZZ0000ZZ
  Mảng số lượng bộ nhớ dành riêng trong vùng này cho bộ nhớ
  phân bổ. Ví dụ: nếu vùng cao nhất thì việc cấp phát bộ nhớ có thể
  phân bổ bộ nhớ từ là ZZ0001ZZ, dung lượng bộ nhớ dành riêng trong
  vùng dành cho phân bổ này là ZZ0002ZZ khi
  cố gắng phân bổ bộ nhớ từ vùng này. Đây là cơ chế của trang
  bộ cấp phát sử dụng để ngăn chặn việc phân bổ có thể sử dụng ZZ0003ZZ
  quá nhiều ZZ0004ZZ. Đối với một số khối lượng công việc chuyên biệt trên máy ZZ0005ZZ,
  thật nguy hiểm cho kernel nếu cho phép bộ nhớ tiến trình được phân bổ từ
  vùng ZZ0006ZZ. Điều này là do bộ nhớ đó sau đó có thể được ghim thông qua
  Cuộc gọi hệ thống ZZ0007ZZ hoặc do không có không gian trao đổi.
  ZZ0008ZZ sysctl xác định mức độ tích cực của kernel trong
  bảo vệ các khu vực thấp hơn này. Mảng này được tính toán lại bằng
  ZZ0009ZZ khi chạy nếu ZZ0010ZZ
  thay đổi sysctl.

ZZ0000ZZ
  Chỉ mục của nút mà vùng này thuộc về. Chỉ có sẵn khi
  ZZ0001ZZ được bật vì chỉ có một vùng trong hệ thống UMA.

ZZ0000ZZ
  Con trỏ tới ZZ0001ZZ của nút mà vùng này thuộc về.

ZZ0000ZZ
  Con trỏ tới Bộ trang Per-CPU (PCP) được phân bổ và khởi tạo bởi
  ZZ0001ZZ. Bằng cách xử lý việc phân bổ và giải phóng thường xuyên nhất
  cục bộ trên mỗi CPU, PCP cải thiện hiệu suất và khả năng mở rộng trên các hệ thống có
  nhiều lõi.

ZZ0000ZZ
  Đã sao chép vào ZZ0001ZZ của Bộ trang Per-CPU để truy cập nhanh hơn.

ZZ0000ZZ
  Đã sao chép vào ZZ0001ZZ của Bộ trang Per-CPU để truy cập nhanh hơn.

ZZ0000ZZ
  Đã sao chép vào ZZ0001ZZ của Bộ trang Per-CPU để truy cập nhanh hơn. các
  ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ của Bộ trang Per-CPU được sử dụng để
  tính toán số phần tử mà Bộ trang Per-CPU lấy được từ người bạn
  bộ cấp phát dưới một lần giữ khóa để đạt hiệu quả. Chúng cũng được sử dụng
  để quyết định xem các Trang Per-CPU có trả lại các trang cho bộ cấp phát bạn bè trong trang hay không
  quá trình miễn phí.

ZZ0000ZZ
  Con trỏ tới các cờ dành cho các khối trang trong vùng (xem
  ZZ0001ZZ cho danh sách cờ). Bộ nhớ được phân bổ
  trong ZZ0002ZZ. Mỗi khối trang chiếm các bit ZZ0003ZZ.
  Chỉ được xác định khi ZZ0004ZZ được bật. Các cờ được lưu trữ trong
  ZZ0005ZZ khi ZZ0006ZZ được bật.

ZZ0000ZZ
  Pfn bắt đầu của khu vực. Nó được khởi tạo bởi
  ZZ0001ZZ.

ZZ0000ZZ
  Các trang hiện tại được quản lý bởi hệ thống bạn bè, được tính như sau:
  ZZ0001ZZ = ZZ0002ZZ - ZZ0003ZZ, ZZ0004ZZ
  bao gồm các trang được cấp phát bởi bộ cấp phát memblock. Nó nên được sử dụng theo trang
  bộ cấp phát và máy quét vm để tính toán tất cả các loại hình mờ và ngưỡng.
  Nó được truy cập bằng các hàm ZZ0005ZZ. Nó được khởi tạo trong
  ZZ0006ZZ và sau đó được khởi tạo lại khi cấp phát memblock
  giải phóng các trang vào hệ thống bạn bè.

ZZ0000ZZ
  Tổng số trang được kéo dài theo vùng, bao gồm cả các lỗ, được tính như sau:
  ZZ0001ZZ = ZZ0002ZZ - ZZ0003ZZ. Nó được khởi tạo
  bởi ZZ0004ZZ.

ZZ0000ZZ
  Các trang vật lý tồn tại trong vùng, được tính như sau:
  ZZ0001ZZ = ZZ0002ZZ - ZZ0003ZZ (trang có lỗ). Nó
  có thể được sử dụng bằng cách cắm nóng bộ nhớ hoặc logic quản lý nguồn bộ nhớ để tìm ra
  các trang không được quản lý bằng cách kiểm tra (ZZ0004ZZ - ZZ0005ZZ). Viết
  quyền truy cập vào ZZ0006ZZ khi chạy phải được bảo vệ bởi
  ZZ0007ZZ. Bất kỳ độc giả nào không thể chịu đựng được sự trôi dạt của
  ZZ0008ZZ nên sử dụng ZZ0009ZZ để có giá trị ổn định. Nó
  được khởi tạo bởi ZZ0010ZZ.

ZZ0000ZZ
  Các trang hiện tại tồn tại trong vùng nằm trên bộ nhớ khả dụng kể từ
  khởi động sớm, không bao gồm bộ nhớ cắm nóng. Chỉ xác định khi
  ZZ0001ZZ được kích hoạt và khởi tạo bởi
  ZZ0002ZZ.

ZZ0000ZZ
  Các trang dành riêng cho CMA sử dụng. Các trang này hoạt động giống như ZZ0001ZZ khi
  chúng không được sử dụng cho CMA. Chỉ được xác định khi ZZ0002ZZ được bật.

ZZ0000ZZ
  Tên của khu vực. Nó là một con trỏ tới phần tử tương ứng của
  mảng ZZ0001ZZ.

ZZ0000ZZ
  Số lượng khối trang bị cô lập. Nó được sử dụng để giải quyết việc đếm trang miễn phí không chính xác
  vấn đề do việc truy xuất loại di chuyển của khối trang không phù hợp. Được bảo vệ bởi
  ZZ0001ZZ. Chỉ được xác định khi ZZ0002ZZ được bật.

ZZ0000ZZ
  Seqlock để bảo vệ ZZ0001ZZ và ZZ0002ZZ. Đó là một
  seqlock vì nó phải được đọc bên ngoài ZZ0003ZZ và nó được thực hiện trong
  đường dẫn cấp phát chính. Tuy nhiên, seqlock được viết khá ít.
  Chỉ được xác định khi ZZ0004ZZ được bật.

ZZ0000ZZ
  Cờ cho biết vùng đó có được khởi tạo hay không. Đặt bởi
  ZZ0001ZZ trong khi khởi động.

ZZ0000ZZ
  Mảng các vùng tự do, trong đó mỗi phần tử tương ứng với một thứ tự cụ thể
  đó là sức mạnh của hai. Bộ cấp phát bạn bè sử dụng cấu trúc này để quản lý
  giải phóng bộ nhớ một cách hiệu quả. Khi cấp phát, nó cố gắng tìm giá trị nhỏ nhất
  khối đủ, nếu khối đủ nhỏ nhất lớn hơn khối
  kích thước được yêu cầu, nó sẽ được chia đệ quy thành các khối nhỏ hơn tiếp theo
  cho đến khi đạt kích thước yêu cầu. Khi một trang được giải phóng, nó có thể được hợp nhất
  với bạn của nó để tạo thành một khối lớn hơn. Nó được khởi tạo bởi
  ZZ0001ZZ.

ZZ0000ZZ
  Danh sách các trang được chấp nhận Tất cả các trang trong danh sách là ZZ0001ZZ.
  Chỉ được xác định khi ZZ0002ZZ được bật.

ZZ0000ZZ
  Cờ vùng. Ba bit ít nhất được sử dụng và xác định bởi
  ZZ0001ZZ. ZZ0002ZZ (bit 0): vùng được tăng cường gần đây
  hình mờ. Xóa khi kswapd được đánh thức. ZZ0003ZZ (bit 1):
  kswapd có thể đang quét vùng. ZZ0004ZZ (bit 2): vùng bên dưới
  hình mờ cao.

ZZ0000ZZ
  Khóa chính bảo vệ cấu trúc dữ liệu nội bộ của bộ cấp phát trang
  dành riêng cho vùng, đặc biệt là bảo vệ ZZ0001ZZ.

ZZ0000ZZ
  Khi các trang trống ở dưới điểm này, các bước bổ sung sẽ được thực hiện khi đọc
  số lượng trang trống để tránh hiện tượng trôi bộ đếm trên mỗi CPU cho phép có hình mờ
  bị vi phạm. Nó được cập nhật trong ZZ0001ZZ.

Kiểm soát nén
~~~~~~~~~~~~~~~~~~

ZZ0000ZZ
  PFN nơi máy quét không nén sẽ bắt đầu trong lần quét tiếp theo.

ZZ0000ZZ
  Các PFN nơi trình quét di chuyển nén sẽ bắt đầu trong lần quét tiếp theo.
  Mảng này có hai phần tử: phần tử đầu tiên được sử dụng ở chế độ ZZ0001ZZ,
  và cái còn lại được sử dụng ở chế độ ZZ0002ZZ.

ZZ0000ZZ
  Quá trình di chuyển ban đầu PFN được khởi tạo thành 0 khi khởi động và đến
  chặn trang đầu tiên với các trang có thể di chuyển trong vùng sau khi nén hoàn toàn
  kết thúc. Nó được sử dụng để kiểm tra xem quét có phải là quét toàn vùng hay không.

ZZ0000ZZ
  PFN miễn phí ban đầu được khởi tạo về 0 khi khởi động và đến lần cuối cùng
  chặn trang với các trang ZZ0001ZZ miễn phí trong vùng. Nó được sử dụng để kiểm tra
  nếu đó là sự bắt đầu của quá trình quét.

ZZ0000ZZ
  Số lần nén được thực hiện kể từ lần thất bại cuối cùng. Nó được thiết lập lại trong
  ZZ0001ZZ khi việc nén không thành công dẫn đến việc phân bổ trang
  thành công. Nó được tăng thêm 1 trong ZZ0002ZZ khi nén
  nên được bỏ qua. ZZ0003ZZ được gọi trước
  ZZ0004ZZ được gọi, ZZ0005ZZ được gọi khi
  ZZ0006ZZ trả về ZZ0007ZZ, ZZ0008ZZ là
  được gọi khi ZZ0009ZZ trả về ZZ0010ZZ hoặc
  ZZ0011ZZ.

ZZ0000ZZ
  Số lần nén bị bỏ qua trước khi thử lại là
  ZZ0001ZZ. Nó được tăng thêm 1 trong ZZ0002ZZ.
  Nó được đặt lại trong ZZ0003ZZ khi có kết quả nén trực tiếp
  trong việc phân bổ trang thành công. Giá trị tối đa của nó là ZZ0004ZZ.

ZZ0000ZZ
  Thứ tự nén tối thiểu không thành công. Nó được đặt trong ZZ0001ZZ
  khi quá trình nén thành công và trong ZZ0002ZZ khi quá trình nén
  không dẫn đến việc phân bổ trang thành công.

ZZ0000ZZ
  Đặt thành true khi trình quét di chuyển nén và trình quét miễn phí gặp nhau, điều này
  có nghĩa là các bit ZZ0001ZZ phải bị xóa.

ZZ0000ZZ
  Đặt thành true khi vùng liền kề (nói cách khác, không có lỗ hổng).

Thống kê
~~~~~~~~~~

ZZ0000ZZ
  Thống kê VM cho vùng. Các mục được theo dõi được xác định bởi
  ZZ0001ZZ.

ZZ0000ZZ
  Thống kê sự kiện VM NUMA cho vùng. Các mục được theo dõi được xác định bởi
  ZZ0001ZZ.

ZZ0000ZZ
  Thống kê Per-CPU VM cho vùng. Nó ghi lại số liệu thống kê VM và sự kiện VM NUMA
  thống kê trên cơ sở mỗi CPU. Nó giảm các bản cập nhật cho ZZ0001ZZ toàn cầu
  và các trường ZZ0002ZZ của vùng để cải thiện hiệu suất.

.. _pages:

Trang
=====

.. admonition:: Stub

   This section is incomplete. Please list and describe the appropriate fields.

.. _folios:

Folios
======

.. admonition:: Stub

   This section is incomplete. Please list and describe the appropriate fields.

.. _initialization:

Khởi tạo
==============

.. admonition:: Stub

   This section is incomplete. Please list and describe the appropriate fields.