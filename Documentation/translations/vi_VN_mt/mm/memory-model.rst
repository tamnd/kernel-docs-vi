.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/memory-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Mô hình bộ nhớ vật lý
=====================

Bộ nhớ vật lý trong một hệ thống có thể được xử lý theo nhiều cách khác nhau. các
trường hợp đơn giản nhất là khi bộ nhớ vật lý bắt đầu ở địa chỉ 0 và
kéo dài một phạm vi liền kề đến địa chỉ tối đa. Nó có thể là,
tuy nhiên, phạm vi này chứa các lỗ nhỏ không thể tiếp cận được
dành cho CPU. Sau đó có thể có một số phạm vi liền kề tại
địa chỉ hoàn toàn khác biệt Và đừng quên NUMA, ở đâu
các ngân hàng bộ nhớ khác nhau được gắn vào các CPU khác nhau.

Linux trừu tượng hóa sự đa dạng này bằng cách sử dụng một trong hai mô hình bộ nhớ:
FLATMEM và SPARSEMEM. Mỗi kiến trúc xác định những gì
các mô hình bộ nhớ mà nó hỗ trợ, mô hình bộ nhớ mặc định là gì và
liệu có thể ghi đè mặc định đó theo cách thủ công hay không.

Tất cả các mô hình bộ nhớ theo dõi trạng thái của các khung trang vật lý bằng cách sử dụng
trang cấu trúc được sắp xếp theo một hoặc nhiều mảng.

Bất kể mô hình bộ nhớ được chọn, đều tồn tại một-một
ánh xạ giữa số khung trang vật lý (PFN) và
ZZ0000ZZ tương ứng.

Mỗi kiểu bộ nhớ xác định ZZ0000ZZ và ZZ0001ZZ
những người trợ giúp cho phép chuyển đổi từ PFN sang ZZ0002ZZ và ngược lại
ngược lại.

FLATMEM
=======

Mẫu bộ nhớ đơn giản nhất là FLATMEM. Mô hình này phù hợp cho
các hệ thống không phải NUMA có các hệ thống vật lý liền kề hoặc gần như liền kề
trí nhớ.

Trong mô hình bộ nhớ FLATMEM, có một mảng ZZ0000ZZ toàn cầu
ánh xạ toàn bộ bộ nhớ vật lý. Đối với hầu hết các kiến trúc, các lỗ
có các mục trong mảng ZZ0001ZZ. Các đối tượng ZZ0002ZZ
tương ứng với các lỗ không bao giờ được khởi tạo đầy đủ.

Để phân bổ mảng ZZ0002ZZ, mã thiết lập kiến trúc cụ thể phải
gọi hàm ZZ0000ZZ. Tuy nhiên, mảng ánh xạ không
có thể sử dụng được cho đến khi có cuộc gọi đến ZZ0001ZZ chuyển tất cả
bộ nhớ tới bộ cấp phát trang.

Một kiến trúc có thể giải phóng các phần của mảng ZZ0001ZZ không bao gồm phần
các trang vật lý thực tế. Trong trường hợp như vậy, kiến trúc cụ thể
Việc triển khai ZZ0000ZZ sẽ khắc phục được những lỗ hổng trong
ZZ0002ZZ vào tài khoản.

Với FLATMEM, việc chuyển đổi giữa PFN và ZZ0000ZZ là
đơn giản: ZZ0001ZZ là một chỉ mục cho
Mảng ZZ0002ZZ.

ZZ0000ZZ xác định số khung trang đầu tiên cho
hệ thống có bộ nhớ vật lý bắt đầu tại địa chỉ khác 0.

SPARSEMEM
=========

SPARSEMEM là mẫu bộ nhớ linh hoạt nhất hiện có trong Linux và nó
là mẫu bộ nhớ duy nhất hỗ trợ một số tính năng nâng cao như
như cắm nóng và tháo nóng bộ nhớ vật lý, bộ nhớ thay thế
bản đồ cho các thiết bị bộ nhớ không khả biến và khởi tạo trì hoãn của
bản đồ bộ nhớ cho các hệ thống lớn hơn.

Mô hình SPARSEMEM trình bày bộ nhớ vật lý như một tập hợp các
phần. Một phần được biểu diễn bằng struct mem_section
chứa ZZ0000ZZ, về mặt logic, là một con trỏ tới một
mảng các trang cấu trúc. Tuy nhiên, nó được lưu trữ bằng một số phép thuật khác
hỗ trợ việc quản lý các bộ phận. Kích thước phần và số lượng tối đa
của phần được chỉ định bằng ZZ0001ZZ và
Các hằng số ZZ0002ZZ được xác định bởi từng kiến trúc
hỗ trợ SPARSEMEM. Trong khi ZZ0003ZZ là chiều rộng thực tế của một
địa chỉ vật lý mà kiến trúc hỗ trợ,
ZZ0004ZZ là một giá trị tùy ý.

Số phần tối đa được ký hiệu là ZZ0000ZZ và
được định nghĩa là

.. math::

   NR\_MEM\_SECTIONS = 2 ^ {(MAX\_PHYSMEM\_BITS - SECTION\_SIZE\_BITS)}

Các đối tượng ZZ0000ZZ được sắp xếp theo mảng hai chiều
được gọi là ZZ0001ZZ. Kích thước và vị trí của mảng này phụ thuộc
trên ZZ0002ZZ và số lượng tối đa có thể của
phần:

* Khi ZZ0000ZZ bị tắt, ZZ0001ZZ
  mảng là tĩnh và có các hàng ZZ0002ZZ. Mỗi hàng giữ một
  đối tượng ZZ0003ZZ duy nhất.
* Khi ZZ0004ZZ được bật, ZZ0005ZZ
  mảng được phân bổ động. Mỗi hàng chứa PAGE_SIZE có giá trị
  Đối tượng ZZ0006ZZ và số hàng được tính toán sao cho phù hợp
  tất cả các phần bộ nhớ.

Với SPARSEMEM, có hai cách có thể để chuyển đổi PFN thành
ZZ0000ZZ tương ứng - một "thưa thớt cổ điển" và "thưa thớt
vmemmap". Việc lựa chọn được thực hiện tại thời điểm xây dựng và nó được xác định bởi
giá trị của ZZ0001ZZ.

Kiểu thưa thớt cổ điển mã hóa số phần của một trang trong trang->cờ
và sử dụng bit cao của PFN để truy cập phần ánh xạ trang đó
khung. Bên trong một phần, PFN là chỉ mục cho mảng trang.

Vmemmap thưa thớt sử dụng bản đồ bộ nhớ ảo được ánh xạ để tối ưu hóa
hoạt động pfn_to_page và page_to_pfn. Có một con trỏ ZZ0000ZZ toàn cục trỏ đến một mảng gần như liền kề nhau
Đối tượng ZZ0001ZZ. PFN là một chỉ mục cho mảng đó và
phần bù của ZZ0002ZZ từ ZZ0003ZZ là PFN của điều đó
trang.

Để sử dụng vmemmap, một kiến trúc phải dự trữ một phạm vi ảo
địa chỉ sẽ ánh xạ các trang vật lý chứa bộ nhớ
bản đồ và đảm bảo rằng ZZ0002ZZ trỏ đến phạm vi đó. Ngoài ra,
kiến trúc nên triển khai phương pháp ZZ0000ZZ
sẽ cấp phát bộ nhớ vật lý và tạo các bảng trang cho
bản đồ bộ nhớ ảo Nếu một kiến trúc không có gì đặc biệt
yêu cầu đối với ánh xạ vmemmap, nó có thể sử dụng mặc định
ZZ0001ZZ được cung cấp bởi bộ nhớ chung
quản lý.

Bản đồ bộ nhớ ảo được ánh xạ cho phép lưu trữ các đối tượng ZZ0001ZZ
dành cho các thiết bị bộ nhớ liên tục trong bộ lưu trữ được phân bổ trước trên các thiết bị đó
thiết bị. Bộ lưu trữ này được biểu diễn bằng struct vmem_altmap
cuối cùng được chuyển đến vmemmap_populate() thông qua một chuỗi dài
của các cuộc gọi hàm. Việc triển khai vmemmap_populate() có thể sử dụng
ZZ0002ZZ cùng với trình trợ giúp ZZ0000ZZ để
phân bổ bản đồ bộ nhớ trên thiết bị bộ nhớ liên tục.

ZONE_DEVICE
===========
Cơ sở ZZ0004ZZ được xây dựng dựa trên ZZ0005ZZ để cung cấp
Dịch vụ ZZ0006ZZ ZZ0007ZZ dành cho trình điều khiển thiết bị vật lý được xác định
các dãy địa chỉ. Khía cạnh "thiết bị" của ZZ0008ZZ liên quan đến thực tế
rằng các đối tượng trang cho các phạm vi địa chỉ này không bao giờ được đánh dấu trực tuyến,
và rằng một tham chiếu phải được thực hiện đối với thiết bị chứ không chỉ trang
để giữ cho bộ nhớ được ghim để sử dụng tích cực. ZZ0009ZZ, thông qua
ZZ0000ZZ, thực hiện cắm nóng bộ nhớ vừa đủ để
bật ZZ0001ZZ, ZZ0002ZZ và
Dịch vụ ZZ0003ZZ cho phạm vi pfns nhất định. Kể từ khi
số lượng tham chiếu trang không bao giờ giảm xuống dưới 1 trang không bao giờ được theo dõi vì
bộ nhớ trống và không gian ZZ0010ZZ của trang được sử dụng lại
để tham chiếu ngược lại thiết bị/trình điều khiển máy chủ đã ánh xạ bộ nhớ.

Trong khi ZZ0002ZZ trình bày bộ nhớ dưới dạng tập hợp các phần,
tùy chọn được thu thập vào các khối bộ nhớ, người dùng ZZ0003ZZ có nhu cầu
để có độ chi tiết nhỏ hơn khi điền ZZ0004ZZ. Cho rằng
Bộ nhớ ZZ0005ZZ không bao giờ được đánh dấu trực tuyến, sau đó nó sẽ không bao giờ được đánh dấu
tùy thuộc vào phạm vi bộ nhớ của nó được hiển thị thông qua bộ nhớ sysfs
api hotplug trên ranh giới khối bộ nhớ. Việc thực hiện dựa vào
việc thiếu ràng buộc người dùng-api này để cho phép bộ nhớ có kích thước phần phụ
phạm vi được chỉ định cho ZZ0000ZZ, nửa trên của
cắm nóng bộ nhớ. Hỗ trợ phần phụ cho phép 2 MB làm vòm chéo
mức độ chi tiết liên kết chung cho ZZ0001ZZ.

Người dùng ZZ0000ZZ là:

* pmem: Bộ nhớ liên tục của nền tảng bản đồ sẽ được sử dụng làm mục tiêu I/O trực tiếp
  thông qua ánh xạ DAX.

* hmm: Mở rộng ZZ0000ZZ với ZZ0001ZZ và ZZ0002ZZ
  gọi lại sự kiện để cho phép trình điều khiển thiết bị phối hợp quản lý bộ nhớ
  các sự kiện liên quan đến bộ nhớ thiết bị, điển hình là bộ nhớ GPU. Xem
  Tài liệu/mm/hmm.rst.

* p2pdma: Tạo các đối tượng ZZ0000ZZ để cho phép các thiết bị ngang hàng trong một
  Cấu trúc liên kết PCI/-E để điều phối các hoạt động DMA trực tiếp giữa chúng,
  tức là bỏ qua bộ nhớ máy chủ.