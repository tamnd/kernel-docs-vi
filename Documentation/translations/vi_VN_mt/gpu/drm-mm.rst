.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-mm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Quản lý bộ nhớ DRM
=====================

Các hệ thống Linux hiện đại yêu cầu lượng bộ nhớ đồ họa lớn để lưu trữ
bộ đệm khung, kết cấu, đỉnh và dữ liệu liên quan đến đồ họa khác. Cho
tính chất rất năng động của nhiều dữ liệu đó, quản lý bộ nhớ đồ họa
do đó, hiệu quả là rất quan trọng đối với ngăn xếp đồ họa và đóng vai trò trung tâm
vai trò trong cơ sở hạ tầng DRM.

Lõi DRM bao gồm hai trình quản lý bộ nhớ, đó là Trình quản lý bảng dịch
(TTM) và Trình quản lý thực thi đồ họa (GEM). TTM là bộ nhớ DRM đầu tiên
người quản lý cần được phát triển và cố gắng trở thành một người phù hợp với tất cả họ
giải pháp. Nó cung cấp một không gian người dùng API duy nhất để đáp ứng nhu cầu
tất cả phần cứng, hỗ trợ cả thiết bị Kiến trúc bộ nhớ hợp nhất (UMA)
và các thiết bị có video chuyên dụng RAM (tức là hầu hết các card màn hình rời).
Điều này dẫn đến một đoạn mã lớn, phức tạp hóa ra là
khó sử dụng để phát triển trình điều khiển.

GEM bắt đầu như một dự án được Intel tài trợ để phản đối TTM
sự phức tạp. Triết lý thiết kế của nó hoàn toàn khác: thay vì
cung cấp giải pháp cho mọi vấn đề liên quan đến bộ nhớ đồ họa, GEM
xác định mã chung giữa các trình điều khiển và tạo thư viện hỗ trợ để
chia sẻ nó. GEM có yêu cầu khởi tạo và thực thi đơn giản hơn
TTM, nhưng không có khả năng quản lý video RAM và do đó bị giới hạn ở
Thiết bị UMA.

Trình quản lý bảng dịch (TTM)
===================================

.. kernel-doc:: drivers/gpu/drm/ttm/ttm_module.c
   :doc: TTM

.. kernel-doc:: include/drm/ttm/ttm_caching.h
   :internal:

Tham chiếu đối tượng thiết bị TTM
---------------------------

.. kernel-doc:: include/drm/ttm/ttm_device.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/ttm/ttm_device.c
   :export:

Tham khảo vị trí tài nguyên TTM
--------------------------------

.. kernel-doc:: include/drm/ttm/ttm_placement.h
   :internal:

Tham chiếu đối tượng tài nguyên TTM
-----------------------------

.. kernel-doc:: include/drm/ttm/ttm_resource.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/ttm/ttm_resource.c
   :export:

Tham chiếu đối tượng TTM TT
-----------------------

.. kernel-doc:: include/drm/ttm/ttm_tt.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/ttm/ttm_tt.c
   :export:

Tham khảo nhóm trang TTM
-----------------------

.. kernel-doc:: include/drm/ttm/ttm_pool.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/ttm/ttm_pool.c
   :export:

Trình quản lý thực thi đồ họa (GEM)
====================================

Phương pháp thiết kế GEM đã mang lại một trình quản lý bộ nhớ không
cung cấp đầy đủ thông tin về tất cả (hoặc thậm chí tất cả các trường hợp sử dụng phổ biến) trong
không gian người dùng hoặc kernel API. GEM trưng bày một bộ tiêu chuẩn liên quan đến bộ nhớ
các hoạt động đối với không gian người dùng và một tập hợp các chức năng trợ giúp cho trình điều khiển và
cho phép các trình điều khiển thực hiện các hoạt động dành riêng cho phần cứng bằng chính hoạt động của họ
API riêng tư.

Không gian người dùng GEM API được mô tả trong bài viết ZZ0000ZZ trên LWN. Trong khi
hơi lỗi thời, tài liệu cung cấp cái nhìn tổng quan tốt về GEM API
nguyên tắc. Phân bổ bộ đệm và các hoạt động đọc và ghi, được mô tả
như một phần của GEM API phổ biến, hiện đang được triển khai bằng cách sử dụng
ioctls dành riêng cho trình điều khiển.

GEM không phân biệt dữ liệu. Nó quản lý các đối tượng đệm trừu tượng mà không cần biết
bộ đệm riêng lẻ chứa gì. API yêu cầu kiến thức về bộ đệm
nội dung hoặc mục đích, chẳng hạn như phân bổ hoặc đồng bộ hóa bộ đệm
nguyên thủy, do đó nằm ngoài phạm vi của GEM và phải được triển khai
sử dụng ioctls dành riêng cho trình điều khiển.

Ở cấp độ cơ bản, GEM bao gồm một số hoạt động:

- Cấp phát và giải phóng bộ nhớ
- Thực hiện lệnh
- Quản lý khẩu độ tại thời điểm thực hiện lệnh

Việc phân bổ đối tượng bộ đệm tương đối đơn giản và phần lớn
được cung cấp bởi lớp shmem của Linux, lớp này cung cấp bộ nhớ để sao lưu mỗi
đối tượng.

Các hoạt động dành riêng cho thiết bị, chẳng hạn như thực thi lệnh, ghim, đệm
việc đọc và ghi, ánh xạ và chuyển quyền sở hữu tên miền được để lại cho
ioctls dành riêng cho trình điều khiển.

Khởi tạo GEM
------------------

Trình điều khiển sử dụng GEM phải đặt bit DRIVER_GEM trong cấu trúc
Trình điều khiển ZZ0000ZZ_tính năng
lĩnh vực. Khi đó lõi DRM sẽ tự động khởi tạo lõi GEM
trước khi gọi hoạt động tải. Phía sau hiện trường, điều này sẽ tạo ra một
Đối tượng Trình quản lý bộ nhớ DRM cung cấp nhóm không gian địa chỉ cho
phân bổ đối tượng.

Trong cấu hình KMS, trình điều khiển cần phân bổ và khởi tạo một
bộ đệm vòng lệnh sau khi khởi tạo lõi GEM nếu được yêu cầu bởi
phần cứng. Các thiết bị UMA thường có bộ nhớ "bị đánh cắp"
vùng cung cấp không gian cho bộ đệm khung ban đầu và vùng lớn,
vùng nhớ liền kề mà thiết bị yêu cầu. Không gian này là
thường không được quản lý bởi GEM và phải được khởi tạo riêng thành
đối tượng DRM MM của chính nó.

Tạo đối tượng GEM
--------------------

GEM chia tách việc tạo các đối tượng GEM và phân bổ bộ nhớ
hỗ trợ chúng trong hai hoạt động riêng biệt.

Các đối tượng GEM được biểu diễn bằng một thể hiện của struct ZZ0000ZZ. Người lái xe thường phải
mở rộng các đối tượng GEM bằng thông tin cá nhân và do đó tạo ra một
Kiểu cấu trúc đối tượng GEM dành riêng cho trình điều khiển nhúng một phiên bản của
cấu trúc ZZ0001ZZ.

Để tạo một đối tượng GEM, trình điều khiển sẽ phân bổ bộ nhớ cho một phiên bản của nó
loại đối tượng GEM cụ thể và khởi tạo cấu trúc được nhúng
ZZ0000ZZ có cuộc gọi
tới drm_gem_object_init(). Hàm lấy một con trỏ
tới thiết bị DRM, một con trỏ tới đối tượng GEM và đối tượng bộ đệm
kích thước tính bằng byte.

GEM sử dụng shmem để phân bổ bộ nhớ có thể phân trang ẩn danh.
drm_gem_object_init() sẽ tạo một tệp shmfs của
kích thước được yêu cầu và lưu nó vào trường filp struct ZZ0000ZZ. Bộ nhớ là
được sử dụng làm bộ lưu trữ chính cho đối tượng khi phần cứng đồ họa
sử dụng bộ nhớ hệ thống trực tiếp hoặc làm kho lưu trữ dự phòng. Trình điều khiển
có thể gọi drm_gem_huge_mnt_create() để tạo, gắn kết và sử dụng một lượng lớn
điểm gắn kết shmem thay vì điểm mặc định ('shm_mnt'). Dành cho bản dựng
khi bật CONFIG_TRANSPARENT_HUGEPAGE, các cuộc gọi tiếp theo tới
drm_gem_object_init() sẽ cho phép shmem phân bổ các trang lớn khi
có thể.

Trình điều khiển chịu trách nhiệm phân bổ các trang vật lý thực tế theo
gọi shmem_read_mapping_page_gfp() cho mỗi trang.
Lưu ý rằng họ có thể quyết định phân bổ các trang khi khởi tạo GEM
đối tượng hoặc trì hoãn việc cấp phát cho đến khi cần bộ nhớ (ví dụ:
khi xảy ra lỗi trang do truy cập bộ nhớ không gian người dùng hoặc
khi trình điều khiển cần bắt đầu truyền DMA liên quan đến bộ nhớ).

Chẳng hạn, việc phân bổ bộ nhớ có thể phân trang ẩn danh không phải lúc nào cũng được mong muốn
khi phần cứng yêu cầu bộ nhớ hệ thống liền kề về mặt vật lý như
thường xảy ra trong các thiết bị nhúng. Trình điều khiển có thể tạo các đối tượng GEM bằng
không hỗ trợ shmfs (được gọi là đối tượng GEM riêng tư) bằng cách khởi tạo chúng bằng lệnh gọi
tới drm_gem_private_object_init() thay vì drm_gem_object_init(). Lưu trữ cho
các đối tượng GEM riêng tư phải được quản lý bởi trình điều khiển.

Tuổi thọ của đối tượng GEM
--------------------

Tất cả các đối tượng GEM đều được tính tham chiếu bởi lõi GEM. Tài liệu tham khảo có thể
được mua và giải phóng bằng cách gọi drm_gem_object_get() và drm_gem_object_put()
tương ứng.

Khi tham chiếu cuối cùng đến đối tượng GEM được giải phóng, các lệnh gọi lõi GEM
ZZ0000ZZ miễn phí
hoạt động. Thao tác đó là bắt buộc đối với trình điều khiển hỗ trợ GEM và phải
giải phóng đối tượng GEM và tất cả các tài nguyên liên quan.

khoảng trống (\*free) (struct drm_gem_object \*obj); Trình điều khiển là
chịu trách nhiệm giải phóng tất cả tài nguyên đối tượng GEM. Điều này bao gồm
tài nguyên được tạo bởi lõi GEM, cần được phát hành cùng với
drm_gem_object_release().

Đặt tên đối tượng GEM
------------------

Giao tiếp giữa không gian người dùng và kernel đề cập đến các đối tượng GEM
sử dụng các thẻ điều khiển cục bộ, tên chung hoặc gần đây hơn là bộ mô tả tệp.
Tất cả đều là giá trị nguyên 32 bit; giới hạn nhân Linux thông thường
áp dụng cho các bộ mô tả tập tin.

Các thẻ điều khiển GEM là cục bộ của tệp DRM. Các ứng dụng có thể xử lý GEM
đối tượng thông qua ioctl dành riêng cho trình điều khiển và có thể sử dụng thẻ điều khiển đó để tham chiếu
tới đối tượng GEM trong ioctls tiêu chuẩn hoặc dành riêng cho trình điều khiển khác. Đóng một
Trình xử lý tệp DRM giải phóng tất cả các trình xử lý GEM của nó và hủy đăng ký
các đối tượng GEM liên quan.

Để tạo một điều khiển cho trình điều khiển đối tượng GEM, hãy gọi drm_gem_handle_create(). các
hàm lấy một con trỏ tới tệp DRM và đối tượng GEM và trả về một
tay cầm độc đáo tại địa phương.  Khi tay cầm không còn cần thiết, trình điều khiển sẽ xóa nó
với lệnh gọi tới drm_gem_handle_delete(). Cuối cùng đối tượng GEM được liên kết với một
điều khiển có thể được lấy ra bằng cách gọi tới drm_gem_object_lookup().

Các bộ điều khiển không có quyền sở hữu các đối tượng GEM, chúng chỉ lấy một tham chiếu
tới vật sẽ rơi ra khi tay cầm bị phá hủy. Đến
tránh làm rò rỉ các vật thể GEM, người lái xe phải đảm bảo rằng họ đã đánh rơi
(các) tham chiếu mà họ sở hữu (chẳng hạn như tham chiếu ban đầu được lấy tại đối tượng
thời gian tạo) nếu thích hợp mà không có bất kỳ sự xem xét đặc biệt nào đối với
xử lý. Ví dụ: trong trường hợp cụ thể của đối tượng GEM kết hợp và
xử lý việc tạo trong quá trình triển khai hoạt động câm_create,
trình điều khiển phải loại bỏ tham chiếu ban đầu tới đối tượng GEM trước
trả lại tay cầm.

Tên GEM có mục đích tương tự như các thẻ điều khiển nhưng không cục bộ đối với DRM
tập tin. Chúng có thể được chuyển giữa các tiến trình để tham chiếu đối tượng GEM
trên toàn cầu. Không thể sử dụng tên trực tiếp để chỉ các đối tượng trong DRM
API, ứng dụng phải chuyển đổi thẻ điều khiển thành tên và tên thành thẻ điều khiển
sử dụng ioctls DRM_IOCTL_GEM_FLINK và DRM_IOCTL_GEM_OPEN
tương ứng. Việc chuyển đổi được xử lý bởi lõi DRM mà không cần bất kỳ
hỗ trợ dành riêng cho người lái xe.

GEM cũng hỗ trợ chia sẻ bộ đệm với bộ mô tả tệp dma-buf thông qua
PRIME. Trình điều khiển dựa trên GEM phải sử dụng các chức năng trợ giúp được cung cấp để
thực hiện xuất, nhập chính xác. Nhìn thấy ?. Kể từ khi chia sẻ
bộ mô tả tập tin vốn đã an toàn hơn những bộ mô tả dễ đoán và
toàn cầu GEM đặt tên nó là cơ chế chia sẻ bộ đệm ưa thích. Chia sẻ
bộ đệm thông qua tên GEM chỉ được hỗ trợ cho không gian người dùng cũ.
Hơn nữa PRIME cũng cho phép chia sẻ bộ đệm giữa các thiết bị vì nó
dựa trên dma-bufs.

Ánh xạ đối tượng GEM
-------------------

Bởi vì các thao tác lập bản đồ khá nặng nên GEM ưa chuộng
quyền truy cập giống như đọc/ghi vào bộ đệm, được thực hiện thông qua trình điều khiển cụ thể
ioctls, ánh xạ vùng đệm tới không gian người dùng. Tuy nhiên, khi truy cập ngẫu nhiên
vào bộ đệm là cần thiết (ví dụ để thực hiện kết xuất phần mềm),
truy cập trực tiếp vào đối tượng có thể hiệu quả hơn.

Lệnh gọi hệ thống mmap không thể được sử dụng trực tiếp để ánh xạ các đối tượng GEM, vì chúng
không có tập tin xử lý riêng của họ. Hai phương pháp thay thế hiện nay
cùng tồn tại để ánh xạ các đối tượng GEM vào không gian người dùng. Phương pháp đầu tiên sử dụng một
ioctl dành riêng cho trình điều khiển để thực hiện thao tác ánh xạ, gọi
do_mmap() dưới mui xe. Điều này thường được coi
không rõ ràng, dường như không được khuyến khích đối với các trình điều khiển hỗ trợ GEM mới và sẽ
do đó không được mô tả ở đây.

Phương pháp thứ hai sử dụng lệnh gọi hệ thống mmap trên phần xử lý tệp DRM. trống rỗng
\*mmap(void \*addr, độ dài size_t, int prot, cờ int, int fd, off_t
bù đắp); DRM xác định đối tượng GEM được ánh xạ bằng một offset giả
được chuyển qua đối số offset mmap. Trước khi được lập bản đồ, GEM
do đó đối tượng phải được liên kết với một phần bù giả. Để làm được điều đó, các tài xế
phải gọi drm_gem_create_mmap_offset() trên đối tượng.

Sau khi được phân bổ, giá trị offset giả phải được chuyển đến ứng dụng
theo cách dành riêng cho trình điều khiển và sau đó có thể được sử dụng làm phần bù mmap
lý lẽ.

Lõi GEM cung cấp phương thức trợ giúp drm_gem_mmap() để
xử lý ánh xạ đối tượng. Phương thức có thể được đặt trực tiếp dưới dạng tệp mmap
người xử lý hoạt động. Nó sẽ tra cứu đối tượng GEM dựa trên offset
giá trị và đặt các hoạt động VMA thành trường ZZ0000ZZ gem_vm_ops. Lưu ý rằng drm_gem_mmap() không ánh xạ bộ nhớ tới
không gian người dùng, nhưng dựa vào trình xử lý lỗi do trình điều khiển cung cấp để ánh xạ các trang
riêng lẻ.

Để sử dụng drm_gem_mmap(), trình điều khiển phải điền vào trường struct ZZ0000ZZ gem_vm_ops bằng một con trỏ tới các hoạt động VM.

Các hoạt động của VM là ZZ0000ZZ
được tạo thành từ nhiều lĩnh vực, những lĩnh vực thú vị hơn là:

.. code-block:: c

	struct vm_operations_struct {
		void (*open)(struct vm_area_struct * area);
		void (*close)(struct vm_area_struct * area);
		vm_fault_t (*fault)(struct vm_fault *vmf);
	};


Các thao tác mở và đóng phải cập nhật tham chiếu đối tượng GEM
đếm. Trình điều khiển có thể sử dụng trình trợ giúp drm_gem_vm_open() và drm_gem_vm_close()
hoạt động trực tiếp như các trình xử lý mở và đóng.

Trình xử lý hoạt động lỗi có trách nhiệm ánh xạ các trang tới
không gian người dùng khi xảy ra lỗi trang. Tùy thuộc vào việc phân bổ bộ nhớ
sơ đồ, trình điều khiển có thể phân bổ các trang vào thời điểm có lỗi hoặc có thể quyết định
cấp phát bộ nhớ cho đối tượng GEM tại thời điểm đối tượng được tạo.

Trình điều khiển muốn ánh xạ trước đối tượng GEM thay vì trang xử lý
các lỗi có thể triển khai trình xử lý thao tác tệp mmap của riêng chúng.

Để giảm chi phí bảng trang, nếu điểm gắn kết shmem nội bộ
"shm_mnt" được định cấu hình để sử dụng các trang lớn trong suốt (dành cho các bản dựng có
Đã bật CONFIG_TRANSPARENT_HUGEPAGE) và nếu cửa hàng hỗ trợ shmem
quản lý để phân bổ một trang lớn cho một địa chỉ bị lỗi, trình xử lý lỗi
trước tiên sẽ cố gắng chèn trang khổng lồ đó vào VMA trước khi rơi xuống
quay lại chèn trang cá nhân. Căn chỉnh địa chỉ người dùng mmap() cho GEM
các đối tượng được xử lý bằng cách cung cấp tệp get_unmapped_area tùy chỉnh
hoạt động chuyển tiếp đến cửa hàng hỗ trợ shmem. Đối với hầu hết người lái xe,
theo mặc định không tạo ra một điểm gắn kết lớn hoặc thông qua một mô-đun
tham số, các trang lớn trong suốt có thể được bật bằng cách đặt
tham số hạt nhân "transparent_hugepage_shmem" hoặc
Núm sysfs "/sys/kernel/mm/transparent_hugepage/shmem_enabled".

Đối với các nền tảng không có MMU, lõi GEM cung cấp phương thức trợ giúp
drm_gem_dma_get_unmapped_area(). Các thủ tục mmap() sẽ gọi điều này để có được
địa chỉ đề xuất cho việc lập bản đồ.

Để sử dụng drm_gem_dma_get_unmapped_area(), trình điều khiển phải điền vào cấu trúc
Trường ZZ0000ZZ get_unmapped_area với
một con trỏ trên drm_gem_dma_get_unmapped_area().

Thông tin chi tiết hơn về get_unmapped_area có thể được tìm thấy trong
Tài liệu/admin-guide/mm/nommu-mmap.rst

Sự mạch lạc của bộ nhớ
----------------

Khi được ánh xạ tới thiết bị hoặc được sử dụng trong bộ đệm lệnh, các trang sao lưu cho
một đối tượng được đưa vào bộ nhớ và được đánh dấu ghi kết hợp để
kết hợp với GPU. Tương tự, nếu CPU truy cập một đối tượng sau
GPU đã kết xuất xong đối tượng thì đối tượng phải được tạo
phù hợp với quan điểm bộ nhớ của CPU, thường liên quan đến bộ đệm GPU
xả nước các loại. Quản lý kết hợp CPU<->GPU cốt lõi này là
được cung cấp bởi ioctl dành riêng cho thiết bị, đánh giá hiện tại của đối tượng
miền và thực hiện mọi thao tác xóa hoặc đồng bộ hóa cần thiết để đưa
đối tượng vào miền kết hợp mong muốn (lưu ý rằng đối tượng có thể
bận, tức là mục tiêu hiển thị đang hoạt động; trong trường hợp đó, việc đặt tên miền
chặn máy khách và chờ kết xuất hoàn tất trước khi thực hiện
bất kỳ hoạt động xả nước cần thiết nào).

Thực thi lệnh
-----------------

Có lẽ chức năng GEM quan trọng nhất đối với các thiết bị GPU là cung cấp
giao diện thực thi lệnh cho máy khách. Xây dựng chương trình khách hàng
bộ đệm lệnh chứa các tham chiếu đến bộ nhớ được phân bổ trước đó
đối tượng, sau đó gửi chúng tới GEM. Vào thời điểm đó, GEM sẽ quan tâm đến
liên kết tất cả các đối tượng vào GTT, thực thi bộ đệm và cung cấp
đồng bộ hóa cần thiết giữa các máy khách truy cập vào cùng một bộ đệm.
Điều này thường liên quan đến việc trục xuất một số đối tượng khỏi GTT và liên kết lại
những hoạt động khác (một hoạt động khá tốn kém) và cung cấp hỗ trợ di dời
ẩn các phần bù GTT cố định khỏi máy khách. Khách hàng phải cẩn thận không
để gửi bộ đệm lệnh tham chiếu nhiều đối tượng hơn mức có thể chứa vừa
GTT; nếu không, GEM sẽ từ chối chúng và sẽ không có kết xuất nào xảy ra.
Tương tự, nếu một số đối tượng trong bộ đệm yêu cầu thanh ghi hàng rào để
được phân bổ để hiển thị chính xác (ví dụ: blit 2D trên chip trước 965),
phải cẩn thận để không yêu cầu nhiều sổ đăng ký hàng rào hơn mức
có sẵn cho khách hàng. Việc quản lý tài nguyên như vậy nên được trừu tượng hóa
từ máy khách trong libdrm.

Tham khảo chức năng GEM
----------------------

.. kernel-doc:: include/drm/drm_gem.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_gem.c
   :export:

Tham khảo chức năng trợ giúp GEM DMA
----------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_gem_dma_helper.c
   :doc: dma helpers

.. kernel-doc:: include/drm/drm_gem_dma_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_gem_dma_helper.c
   :export:

Tham khảo chức năng trợ giúp GEM SHMEM
-----------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_gem_shmem_helper.c
   :doc: overview

.. kernel-doc:: include/drm/drm_gem_shmem_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_gem_shmem_helper.c
   :export:

Tham khảo chức năng trợ giúp GEM VRAM
-----------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_gem_vram_helper.c
   :doc: overview

.. kernel-doc:: include/drm/drm_gem_vram_helper.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_gem_vram_helper.c
   :export:

Tham khảo chức năng trợ giúp GEM TTM
-----------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_gem_ttm_helper.c
   :doc: overview

.. kernel-doc:: drivers/gpu/drm/drm_gem_ttm_helper.c
   :export:

Trình quản lý bù đắp VMA
==================

.. kernel-doc:: drivers/gpu/drm/drm_vma_manager.c
   :doc: vma offset manager

.. kernel-doc:: include/drm/drm_vma_manager.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_vma_manager.c
   :export:

.. _prime_buffer_sharing:

Chia sẻ bộ đệm PRIME
====================

PRIME là khung chia sẻ bộ đệm thiết bị chéo trong drm, ban đầu
được tạo cho dòng OPTIMUS của nền tảng đa gpu. Đến không gian người dùng PRIME
bộ đệm là các bộ mô tả tệp dựa trên dma-buf.

Tổng quan và quy tắc trọn đời
---------------------------

.. kernel-doc:: drivers/gpu/drm/drm_prime.c
   :doc: overview and lifetime rules

Chức năng trợ giúp PRIME
----------------------

.. kernel-doc:: drivers/gpu/drm/drm_prime.c
   :doc: PRIME Helpers

Tài liệu tham khảo chức năng PRIME
-------------------------

.. kernel-doc:: include/drm/drm_prime.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_prime.c
   :export:

Bộ phân bổ phạm vi DRM MM
======================

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/drm_mm.c
   :doc: Overview

Hỗ trợ quét/đuổi LRU
-------------------------

.. kernel-doc:: drivers/gpu/drm/drm_mm.c
   :doc: lru scan roster

Tài liệu tham khảo chức năng cấp phát phạm vi DRM MM
------------------------------------------

.. kernel-doc:: include/drm/drm_mm.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_mm.c
   :export:

.. _drm_gpuvm:

DRM GPUVM
=========

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/drm_gpuvm.c
   :doc: Overview

Tách và hợp nhất
---------------

.. kernel-doc:: drivers/gpu/drm/drm_gpuvm.c
   :doc: Split and Merge

.. _drm_gpuvm_locking:

Khóa
-------

.. kernel-doc:: drivers/gpu/drm/drm_gpuvm.c
   :doc: Locking

Ví dụ
--------

.. kernel-doc:: drivers/gpu/drm/drm_gpuvm.c
   :doc: Examples

Tài liệu tham khảo chức năng DRM GPUVM
-----------------------------

.. kernel-doc:: include/drm/drm_gpuvm.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_gpuvm.c
   :export:

Bộ phân bổ bạn bè DRM
===================

Tài liệu tham khảo chức năng phân bổ Buddy (bạn thân GPU)
-----------------------------------------------

.. kernel-doc:: drivers/gpu/buddy.c
   :export:

Tài liệu tham khảo về chức năng ghi nhật ký cụ thể của DRM Buddy
----------------------------------------------

.. kernel-doc:: drivers/gpu/drm/drm_buddy.c
   :export:

Xử lý bộ nhớ đệm DRM và memcpy WC nhanh()
=======================================

.. kernel-doc:: drivers/gpu/drm/drm_cache.c
   :export:

.. _drm_sync_objects:

Đối tượng đồng bộ hóa DRM
================

.. kernel-doc:: drivers/gpu/drm/drm_syncobj.c
   :doc: Overview

.. kernel-doc:: include/drm/drm_syncobj.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_syncobj.c
   :export:

Bối cảnh thực thi DRM
=====================

.. kernel-doc:: drivers/gpu/drm/drm_exec.c
   :doc: Overview

.. kernel-doc:: include/drm/drm_exec.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/drm_exec.c
   :export:

Bộ lập lịch GPU
=============

Tổng quan
--------

.. kernel-doc:: drivers/gpu/drm/scheduler/sched_main.c
   :doc: Overview

Kiểm soát dòng chảy
------------

.. kernel-doc:: drivers/gpu/drm/scheduler/sched_main.c
   :doc: Flow Control

Tài liệu tham khảo chức năng lập lịch trình
-----------------------------

.. kernel-doc:: include/drm/gpu_scheduler.h
   :internal:

.. kernel-doc:: drivers/gpu/drm/scheduler/sched_main.c
   :export:

.. kernel-doc:: drivers/gpu/drm/scheduler/sched_entity.c
   :export:
