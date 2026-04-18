.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/swiotlb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
DMA và swiotlb
===============

swiotlb là trình cấp phát bộ nhớ đệm được sử dụng bởi lớp DMA của nhân Linux. Đó là
thường được sử dụng khi thiết bị thực hiện DMA không thể truy cập trực tiếp vào bộ nhớ đích
đệm vì những hạn chế về phần cứng hoặc các yêu cầu khác. Trong trường hợp như vậy,
lớp DMA gọi swiotlb để phân bổ bộ đệm bộ nhớ tạm thời phù hợp với
đến những hạn chế. DMA được thực hiện đến/từ bộ đệm bộ nhớ tạm thời này và
CPU sao chép dữ liệu giữa bộ đệm tạm thời và mục tiêu ban đầu
bộ nhớ đệm. Cách tiếp cận này thường được gọi là "bộ đệm thoát" và
Bộ nhớ đệm tạm thời được gọi là "bộ đệm thoát".

Trình điều khiển thiết bị không tương tác trực tiếp với swiotlb. Thay vào đó, tài xế thông báo
lớp DMA của thuộc tính DMA của thiết bị họ đang quản lý và sử dụng
bản đồ DMA thông thường, hủy ánh xạ và đồng bộ hóa các API khi lập trình một thiết bị để thực hiện DMA.
Các API này sử dụng thuộc tính DMA của thiết bị và cài đặt toàn bộ kernel để xác định
nếu việc đệm thoát là cần thiết. Nếu vậy, lớp DMA sẽ quản lý việc phân bổ,
giải phóng và đồng bộ hóa bộ đệm thoát. Vì các thuộc tính DMA là cho mỗi
thiết bị, một số thiết bị trong hệ thống có thể sử dụng bộ đệm thoát trong khi những thiết bị khác thì không.

Bởi vì CPU sao chép dữ liệu giữa bộ đệm thoát và mục tiêu ban đầu
đệm bộ nhớ, việc đệm thoát sẽ chậm hơn so với thực hiện DMA trực tiếp vào
bộ nhớ đệm gốc và tiêu tốn nhiều tài nguyên CPU hơn. Vì vậy nó chỉ được sử dụng
khi cần thiết để cung cấp chức năng DMA.

Kịch bản sử dụng
---------------
swiotlb ban đầu được tạo ra để xử lý DMA cho các thiết bị có địa chỉ
những hạn chế. Khi kích thước bộ nhớ vật lý tăng vượt quá 4 GiB, một số thiết bị có thể
chỉ cung cấp địa chỉ DMA 32 bit. Bằng cách phân bổ bộ nhớ đệm thoát bên dưới
dòng 4 GiB, những thiết bị có giới hạn về địa chỉ này vẫn có thể hoạt động và
làm DMA.

Gần đây hơn, các máy ảo Máy tính bí mật (CoCo) có bộ nhớ của máy ảo khách
được mã hóa theo mặc định và bộ nhớ không thể truy cập được bởi bộ ảo hóa máy chủ
và VMM. Để máy chủ thực hiện I/O thay mặt cho khách, I/O phải được
hướng đến bộ nhớ khách không được mã hóa. Máy ảo CoCo đặt tùy chọn toàn kernel
để buộc tất cả I/O DMA sử dụng bộ đệm thoát và bộ nhớ đệm thoát được đặt
lên dưới dạng không được mã hóa. Máy chủ thực hiện I/O DMA đến/từ bộ nhớ đệm thoát và
lớp DMA của nhân Linux thực hiện các hoạt động "đồng bộ hóa" để khiến CPU sao chép
dữ liệu đến/từ bộ nhớ đệm đích ban đầu. Cầu nối sao chép CPU giữa
bộ nhớ không được mã hóa và bộ nhớ được mã hóa. Việc sử dụng bộ đệm thoát này cho phép
trình điều khiển thiết bị "chỉ hoạt động" trong máy ảo CoCo mà không cần sửa đổi
cần thiết để xử lý độ phức tạp của mã hóa bộ nhớ.

Các trường hợp cạnh khác phát sinh đối với bộ đệm thoát. Ví dụ: khi IOMMU
ánh xạ được thiết lập cho hoạt động DMA đến/từ một thiết bị được coi là
"không đáng tin cậy", thiết bị chỉ được cấp quyền truy cập vào bộ nhớ chứa
dữ liệu đang được chuyển giao. Nhưng nếu bộ nhớ đó chỉ chiếm một phần của IOMMU
granule, các phần khác của granule có thể chứa dữ liệu kernel không liên quan. Kể từ khi
Kiểm soát truy cập IOMMU được thực hiện theo từng hạt, thiết bị không đáng tin cậy có thể truy cập vào
dữ liệu hạt nhân không liên quan. Vấn đề này được giải quyết bằng cách đệm trả lại DMA
hoạt động và đảm bảo rằng các phần không được sử dụng của bộ đệm thoát không
chứa bất kỳ dữ liệu hạt nhân không liên quan.

Chức năng cốt lõi
------------------
Các API swiotlb chính là swiotlb_tbl_map_single() và
swiotlb_tbl_unmap_single(). "Bản đồ" API phân bổ bộ đệm thoát của
kích thước được chỉ định theo byte và trả về địa chỉ vật lý của bộ đệm. các
bộ nhớ đệm là liền kề về mặt vật lý. Kỳ vọng là lớp DMA
ánh xạ địa chỉ bộ nhớ vật lý tới địa chỉ DMA và trả về địa chỉ DMA
tới trình điều khiển để lập trình vào thiết bị. Nếu thao tác DMA chỉ định
nhiều phân đoạn bộ nhớ đệm, một bộ đệm thoát riêng biệt phải được phân bổ cho
từng phân đoạn. swiotlb_tbl_map_single() luôn thực hiện thao tác "đồng bộ hóa" (nghĩa là
bản sao CPU) để khởi tạo bộ đệm thoát để khớp với nội dung của bản gốc
bộ đệm.

swiotlb_tbl_unmap_single() thì ngược lại. Nếu thao tác DMA có thể có
đã cập nhật bộ nhớ đệm thoát và DMA_ATTR_SKIP_CPU_SYNC chưa được đặt,
unmap thực hiện thao tác "đồng bộ hóa" để tạo bản sao dữ liệu CPU từ thư bị trả lại
đệm trở lại bộ đệm ban đầu. Sau đó bộ nhớ đệm thoát được giải phóng.

swiotlb cũng cung cấp các API "đồng bộ hóa" tương ứng với các API dma_sync_*()
trình điều khiển có thể sử dụng khi điều khiển chuyển đổi bộ đệm giữa CPU và
thiết bị. API "đồng bộ hóa" swiotlb gây ra bản sao dữ liệu CPU giữa
bộ đệm ban đầu và bộ đệm bị trả lại. Giống như các API dma_sync_*(), swiotlb
API "đồng bộ hóa" hỗ trợ thực hiện đồng bộ hóa một phần, trong đó chỉ một tập hợp con của thư bị trả lại
bộ đệm được sao chép vào/từ bộ đệm ban đầu.

Các hạn chế về chức năng cốt lõi
------------------------------
Các API bản đồ/unmap/đồng bộ hóa swiotlb phải hoạt động mà không bị chặn, như chúng vốn có
được gọi bởi các API DMA tương ứng có thể chạy trong các ngữ cảnh không thể
khối. Do đó, nhóm bộ nhớ mặc định để phân bổ swiotlb phải là
được phân bổ trước khi khởi động (nhưng xem Dynamic swiotlb bên dưới). Bởi vì swiotlb
phân bổ phải liền kề về mặt vật lý, toàn bộ nhóm bộ nhớ mặc định là
được phân bổ dưới dạng một khối liền kề duy nhất.

Nhu cầu phân bổ trước nhóm swiotlb mặc định sẽ tạo ra sự cân bằng về thời gian khởi động.
Nhóm phải đủ lớn để đảm bảo rằng các yêu cầu bộ đệm bị trả lại có thể
luôn hài lòng vì yêu cầu không chặn có nghĩa là yêu cầu không thể chờ đợi
để không gian có sẵn. Nhưng một vùng lưu trữ lớn có khả năng gây lãng phí bộ nhớ, vì
bộ nhớ được cấp phát trước này không có sẵn cho các mục đích sử dụng khác trong hệ thống. các
sự cân bằng đặc biệt nghiêm trọng trong các máy ảo CoCo sử dụng bộ đệm thoát cho tất cả DMA
Tôi/O. Các máy ảo này sử dụng phương pháp phỏng đoán để đặt kích thước nhóm mặc định thành ~6% bộ nhớ,
với tối đa 1 GiB, có khả năng gây lãng phí bộ nhớ.
Ngược lại, heuristic có thể tạo ra kích thước không đủ, tùy thuộc vào
về các mẫu I/O của khối lượng công việc trong VM. Tính năng swiotlb động
được mô tả dưới đây có thể hữu ích nhưng có những hạn chế. Quản lý swiotlb tốt hơn
kích thước nhóm bộ nhớ mặc định vẫn là một vấn đề mở.

Một lần phân bổ từ swiotlb được giới hạn ở IO_TLB_SIZE * IO_TLB_SEGSIZE
byte, tức là 256 KiB với định nghĩa hiện tại. Khi cài đặt DMA của thiết bị
sao cho thiết bị có thể sử dụng swiotlb, kích thước tối đa của phân đoạn DMA
phải được giới hạn ở mức 256 KiB đó. Giá trị này được truyền đạt tới cấp cao hơn
mã hạt nhân thông qua dma_map_mapping_size() và swiotlb_max_mapping_size(). Nếu
mã cấp cao hơn không tính đến giới hạn này, nó có thể đưa ra các yêu cầu
quá lớn đối với swiotlb và gặp lỗi "swiotlb đầy".

Cài đặt DMA của thiết bị chính là "min_align_mask", có lũy thừa bằng 2 trừ 1
sao cho một số bit bậc thấp được đặt hoặc có thể bằng 0. swiotlb
phân bổ đảm bảo các bit min_align_mask này của địa chỉ vật lý của
bộ đệm thoát khớp với các bit giống nhau trong địa chỉ của bộ đệm gốc. Khi nào
min_align_mask khác 0, nó có thể tạo ra "độ lệch căn chỉnh" trong địa chỉ
của bộ đệm thoát làm giảm nhẹ kích thước tối đa của phân bổ.
Độ lệch căn chỉnh tiềm năng này được phản ánh trong giá trị được trả về bởi
swiotlb_max_mapping_size(), có thể hiển thị ở những nơi như
/sys/block/<device>/queue/max_sectors_kb. Ví dụ: nếu một thiết bị không sử dụng
swiotlb, max_sectors_kb có thể là 512 KiB hoặc lớn hơn. Nếu một thiết bị có thể sử dụng
swiotlb, max_sector_kb sẽ là 256 KiB. Khi min_align_mask khác 0,
max_sectors_kb có thể còn nhỏ hơn nữa, chẳng hạn như 252 KiB.

swiotlb_tbl_map_single() cũng nhận tham số "alloc_align_mask". Cái này
tham số chỉ định việc phân bổ không gian bộ đệm thoát phải bắt đầu tại
địa chỉ vật lý với các bit alloc_align_mask được đặt thành 0. Nhưng thực tế
bộ đệm thoát có thể bắt đầu ở địa chỉ lớn hơn nếu min_align_mask khác 0.
Do đó có thể có không gian đệm trước được phân bổ trước khi bắt đầu
bộ đệm thoát. Tương tự, phần cuối của bộ đệm thoát được làm tròn thành một
ranh giới alloc_align_mask, có khả năng dẫn đến không gian đệm sau. bất kỳ
Khoảng trống đệm trước hoặc đệm sau không được khởi tạo bằng mã swiotlb. các
Tham số "alloc_align_mask" được mã IOMMU sử dụng khi ánh xạ cho không đáng tin cậy
thiết bị. Nó được đặt ở kích thước hạt - 1 để bộ đệm thoát được
được phân bổ hoàn toàn từ các hạt không được sử dụng cho bất kỳ mục đích nào khác.

Khái niệm cấu trúc dữ liệu
------------------------
Bộ nhớ được sử dụng cho bộ đệm thoát swiotlb được phân bổ từ bộ nhớ hệ thống tổng thể
dưới dạng một hoặc nhiều "nhóm". Nhóm mặc định được phân bổ trong quá trình khởi động hệ thống với
kích thước mặc định là 64 MiB. Kích thước nhóm mặc định có thể được sửa đổi bằng
Tham số dòng khởi động kernel "swiotlb=". Kích thước mặc định cũng có thể được điều chỉnh
do các điều kiện khác, chẳng hạn như chạy trong máy ảo CoCo, như mô tả ở trên. Nếu
CONFIG_SWIOTLB_DYNAMIC được bật, các nhóm bổ sung có thể được phân bổ sau
cuộc sống của hệ thống. Mỗi nhóm phải là một phạm vi vật lý liền kề
trí nhớ. Nhóm mặc định được phân bổ bên dưới dòng địa chỉ vật lý 4 GiB nên
nó hoạt động cho các thiết bị chỉ có thể xử lý bộ nhớ vật lý 32 bit (trừ khi
mã dành riêng cho kiến trúc cung cấp cờ SWIOTLB_ANY). Trong máy ảo CoCo,
bộ nhớ nhóm phải được giải mã trước khi sử dụng swiotlb.

Mỗi nhóm được chia thành các "khe" có kích thước IO_TLB_SIZE, tức là 2 KiB với
các định nghĩa hiện hành. IO_TLB_SEGSIZE các khe liền kề (128 khe) tạo thành
cái có thể được gọi là "bộ khe". Khi bộ đệm thoát được cấp phát, nó
chiếm một hoặc nhiều vị trí liền kề. Một vị trí không bao giờ được chia sẻ bởi nhiều người
bộ đệm bị trả lại. Hơn nữa, bộ đệm thoát phải được phân bổ từ một
bộ khe, dẫn đến kích thước bộ đệm thoát tối đa là IO_TLB_SIZE *
IO_TLB_SEGSIZE. Nhiều bộ đệm thoát nhỏ hơn có thể cùng tồn tại trong một khe
được đặt nếu có thể đáp ứng các ràng buộc về căn chỉnh và kích thước.

Các vị trí cũng được nhóm thành các "khu vực", với ràng buộc là tồn tại một bộ vị trí
hoàn toàn trong một khu vực duy nhất. Mỗi khu vực có khóa xoay riêng phải được giữ để
thao tác với các slot trong khu vực đó. Việc chia thành các khu vực tránh sự tranh chấp
dành cho một khóa xoay toàn cục duy nhất khi swiotlb được sử dụng nhiều, chẳng hạn như trong CoCo
VM. Số lượng khu vực mặc định bằng số lượng CPU trong hệ thống dành cho
độ song song tối đa, nhưng vì diện tích không thể nhỏ hơn IO_TLB_SEGSIZE
khe cắm, có thể cần phải gán nhiều CPU cho cùng một khu vực. các
số vùng cũng có thể được đặt thông qua tham số khởi động kernel "swiotlb=".

Khi phân bổ bộ đệm thoát, nếu vùng được liên kết với CPU đang gọi
không có đủ dung lượng trống, các khu vực được liên kết với các CPU khác sẽ được thử
một cách tuần tự. Đối với mỗi khu vực đã thử, phải lấy được khóa xoay của khu vực đó trước
đang thử phân bổ, do đó sự tranh chấp có thể xảy ra nếu swiotlb tương đối bận
tổng thể. Nhưng yêu cầu phân bổ sẽ không thành công trừ khi tất cả các khu vực không có
đủ không gian trống.

IO_TLB_SIZE, IO_TLB_SEGSIZE và số vùng đều phải là lũy thừa của 2 như
mã sử dụng dịch chuyển và mặt nạ bit để thực hiện nhiều phép tính. các
số diện tích được làm tròn lên lũy thừa 2 nếu cần thiết để đáp ứng điều này
yêu cầu.

Nhóm mặc định được phân bổ với căn chỉnh PAGE_SIZE. Nếu một alloc_align_mask
đối số cho swiotlb_tbl_map_single() chỉ định căn chỉnh lớn hơn, một hoặc nhiều
các vị trí ban đầu trong mỗi bộ vị trí có thể không đáp ứng tiêu chí alloc_align_mask.
Bởi vì việc phân bổ bộ đệm thoát không thể vượt qua ranh giới của bộ vị trí, loại bỏ
những khe ban đầu đó làm giảm kích thước tối đa của bộ đệm thoát một cách hiệu quả.
Hiện tại không có vấn đề gì vì alloc_align_mask được đặt dựa trên IOMMU
kích thước hạt và hạt không thể lớn hơn PAGE_SIZE. Nhưng nếu điều đó xảy ra
thay đổi trong tương lai, việc phân bổ nhóm ban đầu có thể cần phải được thực hiện với
căn chỉnh lớn hơn PAGE_SIZE.

swiotlb năng động
---------------
Khi CONFIG_SWIOTLB_DYNAMIC được bật, swiotlb có thể thực hiện mở rộng theo yêu cầu
lượng bộ nhớ có sẵn để phân bổ dưới dạng bộ đệm thoát. Nếu bị trả lại
yêu cầu bộ đệm không thành công do thiếu dung lượng trống, nền không đồng bộ
nhiệm vụ được khởi động để phân bổ bộ nhớ từ bộ nhớ hệ thống chung và biến nó thành
vào một hồ bơi swiotlb. Việc tạo một nhóm bổ sung phải được thực hiện không đồng bộ
vì việc phân bổ bộ nhớ có thể bị chặn và như đã lưu ý ở trên, các yêu cầu swiotlb
không được phép chặn. Sau khi tác vụ nền được khởi động, hệ thống sẽ thoát
yêu cầu bộ đệm tạo ra một "nhóm tạm thời" để tránh trả về "swiotlb đầy"
lỗi. Nhóm tạm thời có kích thước bằng yêu cầu bộ đệm thoát và được
bị xóa khi bộ đệm thoát được giải phóng. Bộ nhớ cho nhóm tạm thời này đi kèm
từ nhóm nguyên tử bộ nhớ chung của hệ thống để việc tạo không bị chặn.
Việc tạo nhóm tạm thời có chi phí tương đối cao, đặc biệt là trong máy ảo CoCo
nơi bộ nhớ phải được giải mã, do đó nó chỉ được thực hiện như một biện pháp tạm thời cho đến khi
tác vụ nền có thể thêm một nhóm không tạm thời khác.

Việc thêm một nhóm động có những hạn chế. Giống như nhóm mặc định, bộ nhớ
phải liền kề nhau về mặt vật lý, do đó kích thước được giới hạn ở các trang MAX_PAGE_ORDER
(ví dụ: 4 MiB trên hệ thống x86 thông thường). Do bị phân mảnh bộ nhớ, kích thước tối đa
phân bổ có thể không có sẵn. Bộ cấp phát nhóm động thử các kích thước nhỏ hơn
cho đến khi thành công, nhưng với kích thước tối thiểu là 1 MiB. Với hệ thống đủ
phân mảnh bộ nhớ, việc thêm động một nhóm có thể không thành công chút nào.

Số lượng khu vực trong một nhóm động có thể khác với số lượng khu vực
trong nhóm mặc định. Bởi vì kích thước nhóm mới thường tối đa là vài MiB,
số lượng khu vực có thể sẽ nhỏ hơn. Ví dụ: với kích thước nhóm mới
trong số 4 MiB và kích thước vùng tối thiểu 256 KiB, chỉ có thể tạo 16 vùng. Nếu
hệ thống có nhiều hơn 16 CPU, nhiều CPU phải chia sẻ một vùng, tạo ra
tranh chấp khóa nhiều hơn.

Nhóm mới được thêm thông qua swiotlb động được liên kết với nhau trong danh sách tuyến tính.
mã swiotlb thường xuyên phải tìm kiếm nhóm chứa một mã cụ thể
địa chỉ vật lý swiotlb, do đó tìm kiếm tuyến tính và không hiệu quả với
số lượng lớn các hồ năng động. Cấu trúc dữ liệu có thể được cải thiện cho
tìm kiếm nhanh hơn.

Nhìn chung, swiotlb động hoạt động tốt nhất cho các cấu hình nhỏ với tương đối
ít CPU. Nó cho phép nhóm swiotlb mặc định nhỏ hơn để bộ nhớ được
không bị lãng phí, với các nhóm động tạo ra nhiều không gian hơn nếu cần (miễn là
vì sự phân mảnh không phải là một trở ngại). Nó ít hữu ích hơn đối với các máy ảo CoCo lớn.

Chi tiết cấu trúc dữ liệu
----------------------
swiotlb được quản lý bằng bốn cấu trúc dữ liệu chính: io_tlb_mem, io_tlb_pool,
io_tlb_area và io_tlb_slot. io_tlb_mem mô tả bộ cấp phát bộ nhớ swiotlb,
bao gồm nhóm bộ nhớ mặc định và mọi nhóm động hoặc tạm thời
liên kết với nó. Số liệu thống kê hạn chế về việc sử dụng swiotlb được lưu giữ trên mỗi bộ cấp phát bộ nhớ
và được lưu trữ trong cấu trúc dữ liệu này. Những số liệu thống kê này có sẵn dưới
/sys/kernel/debug/swiotlb khi CONFIG_DEBUG_FS được đặt.

io_tlb_pool mô tả nhóm bộ nhớ, nhóm mặc định, nhóm động,
hoặc một nhóm tạm thời. Mô tả bao gồm địa chỉ bắt đầu và kết thúc của
bộ nhớ trong nhóm, một con trỏ tới một mảng cấu trúc io_tlb_area và một
con trỏ tới một mảng cấu trúc io_tlb_slot được liên kết với nhóm.

io_tlb_area mô tả một khu vực. Trường chính là khóa quay được sử dụng để
tuần tự hóa quyền truy cập vào các vị trí trong khu vực. Mảng io_tlb_area cho một nhóm có
mục nhập cho từng khu vực và được truy cập bằng chỉ mục khu vực dựa trên 0 bắt nguồn từ
gọi ID bộ xử lý. Các khu vực tồn tại chỉ để cho phép truy cập song song vào swiotlb
từ nhiều CPU.

io_tlb_slot mô tả một khe bộ nhớ riêng lẻ trong nhóm, với kích thước
IO_TLB_SIZE (hiện tại là 2 KiB). Mảng io_tlb_slot được lập chỉ mục theo vị trí
chỉ mục được tính từ địa chỉ bộ đệm thoát liên quan đến bộ nhớ bắt đầu
địa chỉ của hồ bơi. Kích thước của struct io_tlb_slot là 24 byte, do đó
chi phí chiếm khoảng 1% kích thước khe cắm.

Mảng io_tlb_slot được thiết kế để đáp ứng một số yêu cầu. Đầu tiên, DMA
API và API swiotlb tương ứng sử dụng địa chỉ bộ đệm thoát làm
mã định danh cho bộ đệm thoát. Địa chỉ này được trả về bởi
swiotlb_tbl_map_single(), rồi chuyển làm đối số cho
các hàm swiotlb_tbl_unmap_single() và swiotlb_sync_*().  Bản gốc
địa chỉ bộ nhớ đệm rõ ràng phải được chuyển làm đối số cho
swiotlb_tbl_map_single(), nhưng nó không được chuyển sang các API khác. Do đó,
Cấu trúc dữ liệu swiotlb phải lưu địa chỉ bộ nhớ đệm ban đầu để nó
có thể được sử dụng khi thực hiện các thao tác đồng bộ hóa. Địa chỉ ban đầu này được lưu trong
mảng io_tlb_slot.

Thứ hai, mảng io_tlb_slot phải xử lý các yêu cầu đồng bộ hóa một phần. Trong những trường hợp như vậy,
đối số của swiotlb_sync_*() không phải là địa chỉ bắt đầu trả lại
bộ đệm mà là một địa chỉ ở đâu đó ở giữa bộ đệm thoát và
địa chỉ bắt đầu của bộ đệm thoát không được mã swiotlb biết đến. Nhưng
mã swiotlb phải có khả năng tính toán bộ nhớ đệm gốc tương ứng
địa chỉ để thực hiện sao chép CPU do "đồng bộ hóa" quyết định. Vì vậy, một bản gốc được điều chỉnh
địa chỉ bộ nhớ đệm được điền vào struct io_tlb_slot cho mỗi slot
bị chiếm bởi bộ đệm thoát. "alloc_size" được điều chỉnh của bộ đệm thoát là
cũng được ghi lại trong mỗi cấu trúc io_tlb_slot để có thể thực hiện kiểm tra độ chính xác trên
kích thước của hoạt động "đồng bộ hóa". Trường "alloc_size" không được sử dụng ngoại trừ
việc kiểm tra sự tỉnh táo.

Thứ ba, mảng io_tlb_slot được sử dụng để theo dõi các vị trí có sẵn. Trường "danh sách"
trong struct io_tlb_slot ghi lại có bao nhiêu vị trí có sẵn liền kề tồn tại bắt đầu
tại khe đó. "0" cho biết khe đã bị chiếm dụng. Giá trị của "1"
chỉ cho biết khe hiện tại có sẵn. Giá trị "2" cho biết
khe hiện tại và khe tiếp theo đều có sẵn, v.v. Giá trị tối đa là
IO_TLB_SEGSIZE, có thể xuất hiện ở vị trí đầu tiên trong bộ vị trí và biểu thị
rằng toàn bộ bộ vị trí có sẵn. Các giá trị này được sử dụng khi tìm kiếm
các khe có sẵn để sử dụng cho bộ đệm thoát mới. Chúng được cập nhật khi phân bổ
bộ đệm thoát mới và khi giải phóng bộ đệm thoát. Tại thời điểm tạo nhóm,
Trường "danh sách" được khởi tạo thành IO_TLB_SEGSIZE xuống còn 1 cho các vị trí trong mỗi
bộ khe cắm.

Thứ tư, mảng io_tlb_slot theo dõi bất kỳ "khe đệm" nào được phân bổ cho
đáp ứng các yêu cầu alloc_align_mask được mô tả ở trên. Khi nào
swiotlb_tbl_map_single() phân bổ không gian bộ đệm thoát để đáp ứng alloc_align_mask
yêu cầu, nó có thể phân bổ không gian đệm trước trên 0 hoặc nhiều vị trí. Nhưng
khi swiotlb_tbl_unmap_single() được gọi với địa chỉ bộ đệm thoát,
giá trị alloc_align_mask chi phối việc phân bổ và do đó
việc phân bổ bất kỳ khe đệm nào không được biết đến. Bản ghi trường "pad_slots"
số lượng vùng đệm để swiotlb_tbl_unmap_single() có thể giải phóng chúng.
Giá trị "pad_slots" chỉ được ghi trong vùng không đệm đầu tiên được phân bổ
tới bộ đệm thoát.

Nhóm bị hạn chế
----------------
Máy móc swiotlb cũng được sử dụng cho "nhóm hạn chế", là nhóm
bộ nhớ tách biệt với nhóm swiotlb mặc định và được dành riêng cho DMA
sử dụng bởi một thiết bị cụ thể. Nhóm bị hạn chế cung cấp mức bộ nhớ DMA
bảo vệ trên các hệ thống có khả năng bảo vệ phần cứng hạn chế, chẳng hạn như
những người thiếu IOMMU. Việc sử dụng như vậy được chỉ định bởi các mục DeviceTree và
yêu cầu CONFIG_DMA_RESTRICTED_POOL được thiết lập. Mỗi nhóm bị hạn chế dựa trên
trên cấu trúc dữ liệu io_tlb_mem của riêng nó, độc lập với swiotlb chính
io_tlb_mem.

Nhóm bị hạn chế thêm API swiotlb_alloc() và swiotlb_free(), được gọi là
từ API dma_alloc_*() and dma_free_*(). API swiotlb_alloc/free()
phân bổ/giải phóng các vị trí từ/đến nhóm bị hạn chế một cách trực tiếp và không đi qua
swiotlb_tbl_map/unmap_single().