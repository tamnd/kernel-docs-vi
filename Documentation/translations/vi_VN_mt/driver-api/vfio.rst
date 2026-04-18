.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/vfio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
VFIO - "I/O chức năng ảo" [1]_
=====================================

Nhiều hệ thống hiện đại hiện cung cấp DMA và làm gián đoạn cơ sở ánh xạ lại
để giúp đảm bảo các thiết bị I/O hoạt động trong giới hạn mà chúng đã đặt ra
được phân bổ.  Điều này bao gồm phần cứng x86 với AMD-Vi và Intel VT-d,
Hệ thống POWER có Điểm cuối có thể phân vùng (PE) và PowerPC nhúng
các hệ thống như Freescale PAMU.  Trình điều khiển VFIO là IOMMU/thiết bị
khuôn khổ bất khả tri để hiển thị quyền truy cập trực tiếp của thiết bị vào không gian người dùng, trong
một môi trường an toàn, được bảo vệ IOMMU.  Nói cách khác, điều này cho phép
an toàn [2]_, không có đặc quyền, trình điều khiển không gian người dùng.

Tại sao chúng ta muốn điều đó?  Máy ảo thường sử dụng thiết bị trực tiếp
quyền truy cập ("gán thiết bị") khi được định cấu hình ở mức cao nhất có thể
Hiệu suất vào/ra.  Từ góc độ thiết bị và máy chủ, điều này chỉ đơn giản là
biến VM thành trình điều khiển không gian người dùng, với các lợi ích của
giảm đáng kể độ trễ, băng thông cao hơn và sử dụng trực tiếp
trình điều khiển thiết bị kim loại trần [3]_.

Một số ứng dụng, đặc biệt là trong tính toán hiệu năng cao
lĩnh vực này, cũng được hưởng lợi từ việc truy cập thiết bị trực tiếp, chi phí thấp từ
không gian người dùng.  Các ví dụ bao gồm bộ điều hợp mạng (thường không dựa trên TCP/IP)
và máy gia tốc tính toán.  Trước VFIO, các trình điều khiển này phải
trải qua chu trình phát triển đầy đủ để trở thành thượng nguồn thích hợp
trình điều khiển, được duy trì ngoài cây hoặc sử dụng khung UIO,
không có khái niệm về bảo vệ IOMMU, hỗ trợ ngắt hạn chế,
và yêu cầu quyền root để truy cập những thứ như cấu hình PCI
không gian.

Khung trình điều khiển VFIO có ý định thống nhất những điều này, thay thế cả
KVM PCI Mã gán thiết bị cụ thể cũng như cung cấp thêm
môi trường trình điều khiển không gian người dùng an toàn, nhiều tính năng hơn UIO.

Nhóm, Thiết bị và IOMMU
---------------------------

Thiết bị là mục tiêu chính của bất kỳ trình điều khiển I/O nào.  Các thiết bị thường
tạo ra một giao diện lập trình bao gồm truy cập I/O, các ngắt,
và DMA.  Không đi sâu vào chi tiết của từng thứ này, DMA là
cho đến nay khía cạnh quan trọng nhất để duy trì một môi trường an toàn
vì việc cho phép thiết bị truy cập đọc-ghi vào bộ nhớ hệ thống sẽ áp đặt
rủi ro lớn nhất đối với tính toàn vẹn của hệ thống tổng thể.

Để giúp giảm thiểu rủi ro này, nhiều IOMMU hiện đại hiện nay đã kết hợp
các thuộc tính cách ly thành những gì, trong nhiều trường hợp, chỉ là một giao diện
dành cho việc dịch thuật (tức là giải quyết các vấn đề về địa chỉ của thiết bị
với không gian địa chỉ hạn chế).  Với điều này, giờ đây các thiết bị có thể được cách ly
với nhau và từ việc truy cập bộ nhớ tùy ý, do đó cho phép
những thứ như gán trực tiếp an toàn các thiết bị vào máy ảo.

Sự cô lập này không phải lúc nào cũng ở mức độ chi tiết của một thiết bị
mặc dù.  Ngay cả khi IOMMU có khả năng này, các thuộc tính của thiết bị,
mỗi kết nối và cấu trúc liên kết IOMMU có thể làm giảm sự cô lập này.
Ví dụ, một thiết bị riêng lẻ có thể là một phần của một thiết bị đa
bao vây chức năng.  Mặc dù IOMMU có thể phân biệt được
giữa các thiết bị bên trong vỏ bọc, vỏ bọc có thể không yêu cầu
giao dịch giữa các thiết bị để đạt được IOMMU.  Ví dụ về điều này
có thể là bất cứ thứ gì từ một thiết bị PCI đa chức năng có cửa sau
giữa các chức năng với một thiết bị không có khả năng PCI-ACS (Dịch vụ kiểm soát truy cập)
cầu cho phép chuyển hướng mà không cần đến IOMMU.  Cấu trúc liên kết
cũng có thể đóng vai trò quan trọng trong việc giấu thiết bị.  Một PCIe-to-PCI
bridge che giấu các thiết bị đằng sau nó, khiến giao dịch xuất hiện như thể
từ chính cây cầu.  Rõ ràng thiết kế IOMMU đóng vai trò quan trọng
cũng vậy.

Do đó, mặc dù phần lớn IOMMU có thể có cấp độ thiết bị
độ chi tiết, bất kỳ hệ thống nào cũng dễ bị giảm độ chi tiết.  các
Do đó, IOMMU API hỗ trợ khái niệm nhóm IOMMU.  Một nhóm là
một tập hợp các thiết bị có thể cách ly với tất cả các thiết bị khác trong
hệ thống.  Do đó, các nhóm là đơn vị sở hữu được VFIO sử dụng.

Trong khi nhóm là mức độ chi tiết tối thiểu phải được sử dụng để
đảm bảo quyền truy cập an toàn của người dùng, nó không nhất thiết phải là ưu tiên
độ chi tiết.  Trong IOMMU sử dụng bảng trang, có thể
có thể chia sẻ một tập hợp các bảng trang giữa các nhóm khác nhau,
giảm chi phí chung cho cả nền tảng (giảm rung lắc TLB,
giảm bảng trang trùng lặp) và cho người dùng (chỉ lập trình
một bộ dịch duy nhất).  Vì lý do này, VFIO sử dụng
một lớp chứa, có thể chứa một hoặc nhiều nhóm.  Một thùng chứa
được tạo bằng cách mở thiết bị ký tự /dev/vfio/vfio.

Bản thân container cung cấp rất ít chức năng, với tất cả
nhưng một vài phiên bản và giao diện truy vấn tiện ích mở rộng đã bị khóa.
Người dùng cần thêm một nhóm vào vùng chứa cho cấp độ tiếp theo
về chức năng.  Để làm được điều này, trước tiên người dùng cần xác định
nhóm được liên kết với thiết bị mong muốn.  Điều này có thể được thực hiện bằng cách sử dụng
các liên kết sysfs được mô tả trong ví dụ dưới đây.  Bằng cách cởi bỏ ràng buộc
thiết bị từ trình điều khiển máy chủ và liên kết nó với trình điều khiển VFIO, một trình điều khiển mới
Nhóm VFIO sẽ xuất hiện dưới dạng /dev/vfio/$GROUP, trong đó
$GROUP là số nhóm IOMMU mà thiết bị là thành viên.
Nếu nhóm IOMMU chứa nhiều thiết bị, mỗi thiết bị sẽ cần phải
được liên kết với trình điều khiển VFIO trước khi hoạt động trên nhóm VFIO
được cho phép (chỉ cần hủy liên kết thiết bị khỏi
trình điều khiển máy chủ nếu không có trình điều khiển VFIO; điều này sẽ làm cho
nhóm có sẵn nhưng không có thiết bị cụ thể đó).  TBD-giao diện
để vô hiệu hóa việc thăm dò/khóa thiết bị bằng trình điều khiển.

Khi nhóm đã sẵn sàng, nó có thể được thêm vào vùng chứa bằng cách mở
thiết bị ký tự nhóm VFIO (/dev/vfio/$GROUP) và sử dụng
VFIO_GROUP_SET_CONTAINER ioctl, chuyển bộ mô tả tệp của
tập tin vùng chứa đã mở trước đó.  Nếu muốn và nếu có trình điều khiển IOMMU
hỗ trợ chia sẻ bối cảnh IOMMU giữa các nhóm, nhiều nhóm có thể
được đặt vào cùng một vùng chứa.  Nếu một nhóm không được đặt thành vùng chứa
với các nhóm hiện có, một thùng chứa trống mới sẽ cần được sử dụng
thay vào đó.

Với một nhóm (hoặc các nhóm) được gắn vào một thùng chứa, phần còn lại
ioctls trở nên khả dụng, cho phép truy cập vào các giao diện VFIO IOMMU.
Ngoài ra, giờ đây có thể lấy các bộ mô tả tệp cho mỗi
thiết bị trong một nhóm sử dụng ioctl trên bộ mô tả tệp nhóm VFIO.

Thiết bị VFIO API bao gồm ioctls để mô tả thiết bị, I/O
các vùng và độ lệch đọc/ghi/mmap của chúng trên bộ mô tả thiết bị, như
cũng như các cơ chế mô tả và đăng ký ngắt
thông báo.

Ví dụ sử dụng VFIO
------------------

Giả sử người dùng muốn truy cập thiết bị PCI 0000:06:0d.0::

$ readlink /sys/bus/pci/devices/0000:06:0d.0/iommu_group
	../../../../kernel/iommu_groups/26

Do đó, thiết bị này nằm trong nhóm IOMMU 26. Thiết bị này nằm trên
bus pci, do đó người dùng sẽ sử dụng vfio-pci để quản lý
nhóm::

# modprobe vfio-pci

Liên kết thiết bị này với trình điều khiển vfio-pci sẽ tạo nhóm VFIO
thiết bị ký tự cho nhóm này::

$ lspci -n -s 0000:06:0d.0
	06:0d.0 0401: 1102:0002 (rev 08)
	# echo 0000:06:0d.0 > /sys/bus/pci/devices/0000:06:0d.0/driver/unbind
	# echo 1102 0002 > /sys/bus/pci/drivers/vfio-pci/new_id

Bây giờ chúng ta cần xem có những thiết bị nào khác trong nhóm để giải phóng
nó được sử dụng bởi VFIO::

$ ls -l /sys/bus/pci/devices/0000:06:0d.0/iommu_group/devices
	tổng 0
	lrwxrwxrwx. 1 gốc 0 23/04 16:13 0000:00:1e.0 ->
		../../../../devices/pci0000:00/0000:00:1e.0
lrwxrwxrwx. 1 gốc 0 23/04 16:13 0000:06:0d.0 ->
		../../../../devices/pci0000:00/0000:00:1e.0/0000:06:0d.0
lrwxrwxrwx. 1 gốc 0 23/04 16:13 0000:06:0d.1 ->
		../../../../devices/pci0000:00/0000:00:1e.0/0000:06:0d.1

Thiết bị này nằm phía sau cầu nối PCIe-to-PCI [4]_, do đó chúng tôi cũng
cần thêm thiết bị 0000:06:0d.1 vào nhóm tương tự
thủ tục như trên.  Thiết bị 0000:00:1e.0 là một cầu nối thực hiện
hiện không có trình điều khiển máy chủ, do đó không cần thiết phải
liên kết thiết bị này với trình điều khiển vfio-pci (vfio-pci hiện không có
hỗ trợ cầu PCI).

Bước cuối cùng là cung cấp cho người dùng quyền truy cập vào nhóm nếu
mong muốn hoạt động không có đặc quyền (lưu ý rằng /dev/vfio/vfio cung cấp
không có khả năng riêng và do đó dự kiến sẽ được đặt thành
chế độ 0666 của hệ thống)::

Người dùng # chown:người dùng/dev/vfio/26

Người dùng hiện có toàn quyền truy cập vào tất cả các thiết bị và iommu cho việc này
nhóm và có thể truy cập chúng như sau::

int container, nhóm, thiết bị, i;
	struct vfio_group_status nhóm_status =
					{ .argsz = sizeof(group_status) };
	struct vfio_iommu_type1_info iommu_info = { .argsz = sizeof(iommu_info) };
	struct vfio_iommu_type1_dma_map dma_map = { .argsz = sizeof(dma_map) };
	struct vfio_device_info device_info = { .argsz = sizeof(device_info) };

/*Tạo vùng chứa mới */
	container = open("/dev/vfio/vfio", O_RDWR);

if (ioctl(container, VFIO_GET_API_VERSION) != VFIO_API_VERSION)
		/* Phiên bản API không xác định */

if (!ioctl(container, VFIO_CHECK_EXTENSION, VFIO_TYPE1_IOMMU))
		/* Không hỗ trợ trình điều khiển IOMMU mà chúng tôi muốn. */

/*Mở nhóm*/
	nhóm = open("/dev/vfio/26", O_RDWR);

/* Kiểm tra xem nhóm có khả thi và sẵn sàng không */
	ioctl(nhóm, VFIO_GROUP_GET_STATUS, &group_status);

if (!(group_status.flags & VFIO_GROUP_FLAGS_VIABLE))
		/* Nhóm không khả thi (nghĩa là không phải tất cả các thiết bị đều được kết nối với vfio) */

/* Thêm nhóm vào vùng chứa */
	ioctl(nhóm, VFIO_GROUP_SET_CONTAINER, &container);

/* Kích hoạt mô hình IOMMU mà chúng tôi muốn */
	ioctl(thùng chứa, VFIO_SET_IOMMU, VFIO_TYPE1_IOMMU);

/* Nhận thêm thông tin IOMMU */
	ioctl(container, VFIO_IOMMU_GET_INFO, &iommu_info);

/* Phân bổ một số không gian và thiết lập ánh xạ DMA */
	dma_map.vaddr = mmap(0, 1024 * 1024, PROT_READ | PROT_WRITE,
			     MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	dma_map.size = 1024 * 1024;
	dma_map.iova = 0; /* 1MB bắt đầu từ 0x0 từ chế độ xem thiết bị */
	dma_map.flags = VFIO_DMA_MAP_FLAG_READ | VFIO_DMA_MAP_FLAG_WRITE;

ioctl(vùng chứa, VFIO_IOMMU_MAP_DMA, &dma_map);

/* Lấy bộ mô tả tập tin cho thiết bị */
	thiết bị = ioctl(nhóm, VFIO_GROUP_GET_DEVICE_FD, "0000:06:0d.0");

/*Kiểm tra và cài đặt thiết bị */
	ioctl(thiết bị, VFIO_DEVICE_GET_INFO, &device_info);

for (i = 0; i < device_info.num_khu vực; i++) {
		struct vfio_khu vực_info reg = { .argsz = sizeof(reg) };

reg.index = i;

ioctl(thiết bị, VFIO_DEVICE_GET_REGION_INFO, &reg);

/* Thiết lập ánh xạ... đọc/ghi offset, mmaps
		 * Đối với thiết bị PCI, không gian cấu hình là một vùng */
	}

for (i = 0; i < device_info.num_irqs; i++) {
		struct vfio_irq_info irq = { .argsz = sizeof(irq) };

irq.index = i;

ioctl(thiết bị, VFIO_DEVICE_GET_IRQ_INFO, &irq);

/* Thiết lập IRQ...eventfds, VFIO_DEVICE_SET_IRQS */
	}

/* Đặt lại và sử dụng thiết bị miễn phí... */
	ioctl(thiết bị, VFIO_DEVICE_RESET);

IOMMUFD và vfio_iommu_type1
----------------------------

IOMMUFD là người dùng mới API để quản lý các bảng trang I/O từ không gian người dùng.
Nó dự định trở thành cổng cung cấp không gian người dùng nâng cao DMA
các tính năng (bản dịch lồng nhau [5]_, PASID [6]_, v.v.) đồng thời cung cấp
giao diện tương thích ngược cho việc sử dụng VFIO_TYPE1v2_IOMMU hiện có
trường hợp.  Cuối cùng, trình điều khiển vfio_iommu_type1 cũng như phiên bản kế thừa
mô hình nhóm và vùng chứa vfio dự kiến sẽ không được dùng nữa.

Giao diện tương thích ngược IOMMUFD có thể được kích hoạt theo hai cách.
Trong phương pháp đầu tiên, kernel có thể được cấu hình bằng
CONFIG_IOMMUFD_VFIO_CONTAINER, trong trường hợp đó là hệ thống con IOMMUFD
cung cấp minh bạch toàn bộ cơ sở hạ tầng cho VFIO
container và giao diện phụ trợ IOMMU.  Chế độ tương thích có thể
cũng có thể được truy cập nếu giao diện vùng chứa VFIO, tức là. /dev/vfio/vfio là
chỉ đơn giản là liên kết tượng trưng đến/dev/iommu.  Lưu ý rằng tại thời điểm viết bài,
chế độ tương thích không hoàn toàn có đầy đủ tính năng so với
VFIO_TYPE1v2_IOMMU (ví dụ: DMA ánh xạ MMIO) và không cố gắng
cung cấp khả năng tương thích với giao diện VFIO_SPAPR_TCE_IOMMU.  Vì thế
thông thường vào thời điểm này không nên chuyển từ VFIO gốc
triển khai các giao diện tương thích IOMMUFD.

Về lâu dài, người dùng VFIO nên chuyển sang quyền truy cập thiết bị thông qua cdev
giao diện được mô tả bên dưới và quyền truy cập gốc thông qua IOMMUFD
các giao diện được cung cấp.

Cdev thiết bị VFIO
------------------

Theo truyền thống, người dùng mua thiết bị fd thông qua VFIO_GROUP_GET_DEVICE_FD
trong nhóm VFIO.

Với CONFIG_VFIO_DEVICE_CDEV=y, giờ đây người dùng có thể có được một thiết bị fd
bằng cách trực tiếp mở một thiết bị ký tự /dev/vfio/devices/vfioX trong đó
"X" là số được VFIO phân bổ duy nhất cho các thiết bị đã đăng ký.
Giao diện cdev không hỗ trợ các thiết bị noiommu nên người dùng nên sử dụng
giao diện nhóm kế thừa nếu cần có noiommu.

Cdev chỉ hoạt động với IOMMUFD.  Cả trình điều khiển và ứng dụng VFIO
phải thích ứng với mô hình bảo mật cdev mới yêu cầu sử dụng
VFIO_DEVICE_BIND_IOMMUFD yêu cầu quyền sở hữu DMA trước khi bắt đầu
thực sự sử dụng thiết bị.  Khi BIND thành công thì thiết bị VFIO có thể
người dùng có thể truy cập đầy đủ.

Cdev thiết bị VFIO không dựa vào trình điều khiển nhóm/container/iommu VFIO.
Do đó các mô-đun đó có thể được biên dịch đầy đủ trong môi trường
nơi không có ứng dụng VFIO kế thừa nào tồn tại.

Cho đến nay SPAPR chưa hỗ trợ IOMMUFD.  Vì vậy nó không thể hỗ trợ thiết bị
cdev cũng vậy.

Quyền truy cập cdev của thiết bị vfio vẫn bị ràng buộc bởi ngữ nghĩa nhóm IOMMU, tức là. ở đó
chỉ có thể là một chủ sở hữu DMA cho nhóm.  Các thiết bị giống nhau
nhóm không thể bị ràng buộc với nhiều iommufd_ctx hoặc được chia sẻ giữa các nhóm gốc
trình điều khiển bus kernel và vfio hoặc trình điều khiển khác hỗ trợ driver_managed_dma
cờ.  Việc vi phạm yêu cầu về quyền sở hữu này sẽ không thành công
VFIO_DEVICE_BIND_IOMMUFD ioctl, cổng truy cập toàn bộ thiết bị.

Ví dụ về cdev thiết bị
----------------------

Giả sử người dùng muốn truy cập thiết bị PCI 0000:6a:01.0::

$ ls /sys/bus/pci/devices/0000:6a:01.0/vfio-dev/
	vfio0

Do đó, thiết bị này được biểu diễn dưới dạng vfio0.  Người dùng có thể xác minh
sự tồn tại của nó::

$ ls -l /dev/vfio/devices/vfio0
	crw------- 1 root root 511, 0 ngày 16 tháng 2 01:22 /dev/vfio/devices/vfio0
	$ cat /sys/bus/pci/devices/0000:6a:01.0/vfio-dev/vfio0/dev
	511:0
	$ ls -l /dev/char/511\:0
	lrwxrwxrwx 1 root gốc 21 ngày 16 tháng 2 01:22 /dev/char/511:0 -> ../vfio/devices/vfio0

Sau đó cung cấp cho người dùng quyền truy cập vào thiết bị nếu không có đặc quyền
hoạt động mong muốn::

$ người dùng chown: người dùng /dev/vfio/devices/vfio0

Cuối cùng người dùng có thể nhận được cdev fd bằng cách::

cdev_fd = open("/dev/vfio/devices/vfio0", O_RDWR);

Một cdev_fd đã mở không cấp cho người dùng bất kỳ quyền truy cập nào
thiết bị ngoại trừ việc ràng buộc cdev_fd với iommufd.  Sau thời điểm đó
thì thiết bị hoàn toàn có thể truy cập được bao gồm cả việc gắn nó vào một
IOMMUFD IOAS/HWPT để kích hoạt không gian người dùng DMA::

struct vfio_device_bind_iommufd liên kết = {
		.argsz = sizeof(liên kết),
		.flags = 0,
	};
	cấu trúc iommu_ioas_alloc alloc_data = {
		.size = sizeof(alloc_data),
		.flags = 0,
	};
	struct vfio_device_attach_iommufd_pt Attach_data = {
		.argsz = sizeof(đính kèm_data),
		.flags = 0,
	};
	struct iommu_ioas_map bản đồ = {
		.size = sizeof(bản đồ),
		.flags = IOMMU_IOAS_MAP_READABLE |
			 IOMMU_IOAS_MAP_WRITEABLE |
			 IOMMU_IOAS_MAP_FIXED_IOVA,
		.__ dành riêng = 0,
	};

iommufd = open("/dev/iommu", O_RDWR);

bind.iommufd = iommufd;
	ioctl(cdev_fd, VFIO_DEVICE_BIND_IOMMUFD, &bind);

ioctl(iommufd, IOMMU_IOAS_ALLOC, &alloc_data);
	Attach_data.pt_id = alloc_data.out_ioas_id;
	ioctl(cdev_fd, VFIO_DEVICE_ATTACH_IOMMUFD_PT, &đính kèm_data);

/* Phân bổ một số không gian và thiết lập ánh xạ DMA */
	map.user_va = (int64_t)mmap(0, 1024 * 1024, PROT_READ | PROT_WRITE,
				    MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);
	bản đồ.iova = 0; /* 1MB bắt đầu từ 0x0 từ chế độ xem thiết bị */
	bản đồ.length = 1024 * 1024;
	map.ioas_id = alloc_data.out_ioas_id;

ioctl(iommufd, IOMMU_IOAS_MAP, &map);

/* Các hoạt động khác của thiết bị như đã nêu trong "Ví dụ sử dụng VFIO" */

VFIO Người dùng API
-------------------------------------------------------------------------------

Vui lòng xem include/uapi/linux/vfio.h để biết tài liệu API đầy đủ.

Tài xế xe buýt VFIO API
-------------------------------------------------------------------------------

Trình điều khiển bus VFIO, chẳng hạn như vfio-pci chỉ sử dụng một số giao diện
vào lõi VFIO.  Khi các thiết bị được liên kết và không liên kết với trình điều khiển,
Các giao diện sau đây được gọi khi các thiết bị được liên kết và
không bị ràng buộc từ trình điều khiển::

int vfio_register_group_dev(struct vfio_device *device);
	int vfio_register_emulated_iommu_dev(struct vfio_device *device);
	void vfio_unregister_group_dev(struct vfio_device *device);

Trình điều khiển nên nhúng vfio_device vào cấu trúc của chính nó và sử dụng
vfio_alloc_device() để phân bổ cấu trúc và có thể đăng ký
Lệnh gọi lại @init/@release để quản lý mọi trạng thái riêng tư bao bọc
vfio_device::

vfio_alloc_device(dev_struct, member, dev, ops);
	void vfio_put_device(struct vfio_device *device);

vfio_register_group_dev() chỉ ra lõi để bắt đầu theo dõi
iommu_group của nhà phát triển được chỉ định và đăng ký nhà phát triển thuộc sở hữu của bus VFIO
người lái xe. Khi vfio_register_group_dev() trả về, không gian người dùng có thể
bắt đầu truy cập trình điều khiển, do đó trình điều khiển phải đảm bảo rằng nó hoàn toàn
sẵn sàng trước khi gọi nó. Trình điều khiển cung cấp cấu trúc hoạt động cho các cuộc gọi lại
tương tự như cấu trúc hoạt động của tệp::

cấu trúc vfio_device_ops {
		char *tên;
		int (*init)(struct vfio_device *vdev);
		khoảng trống (*release)(struct vfio_device *vdev);
		int (*bind_iommufd)(struct vfio_device *vdev,
					cấu trúc iommufd_ctx *ictx, u32 *out_device_id);
		khoảng trống (*unbind_iommufd)(struct vfio_device *vdev);
		int (*attach_ioas)(struct vfio_device *vdev, u32 *pt_id);
		khoảng trống (*detach_ioas)(struct vfio_device *vdev);
		int (*open_device)(struct vfio_device *vdev);
		khoảng trống (*close_device)(struct vfio_device *vdev);
		ssize_t (*read)(struct vfio_device *vdev, char __user *buf,
				số lượng size_t, loff_t *ppos);
		ssize_t (*write)(struct vfio_device *vdev, const char __user *buf,
			 số lượng size_t, loff_t *kích thước);
		dài (*ioctl)(struct vfio_device *vdev, cmd int không dấu,
				 đối số dài không dấu);
		int (*mmap)(struct vfio_device *vdev, struct vm_area_struct *vma);
		void (*request)(struct vfio_device *vdev, số int không dấu);
		int (*match)(struct vfio_device *vdev, char *buf);
		khoảng trống (*dma_unmap)(struct vfio_device *vdev, u64 iova, chiều dài u64);
		int (*device_feature)(struct vfio_device *device, cờ u32,
					  void __user *arg, size_t argsz);
	};

Mỗi chức năng được chuyển vdev đã được đăng ký ban đầu
trong vfio_register_group_dev() hoặc vfio_register_emulated_iommu_dev()
gọi ở trên. Điều này cho phép người lái xe buýt có được dữ liệu riêng tư bằng cách sử dụng
container_of().

::

- Lệnh gọi lại init/release được đưa ra khi vfio_device được khởi tạo
	  và được thả ra.

- Lệnh gọi lại thiết bị mở/đóng được thực hiện khi lần đầu tiên
	  phiên bản của bộ mô tả tệp cho thiết bị được tạo (ví dụ:
	  qua VFIO_GROUP_GET_DEVICE_FD) cho phiên người dùng.

- Lệnh gọi lại ioctl cung cấp thông tin trực tiếp cho một số VFIO_DEVICE_*
	  ioctls.

- Lệnh gọi lại [un]bind_iommufd được phát ra khi thiết bị bị ràng buộc với
	  và không bị ràng buộc khỏi iommufd.

- Lệnh gọi lại [de]attach_ioas được phát ra khi thiết bị được gắn vào
	  và tách khỏi IOAS được quản lý bởi iommufd bị ràng buộc. Tuy nhiên,
	  IOAS đính kèm cũng có thể được tự động tháo ra khi thiết bị
	  không bị ràng buộc khỏi iommufd.

- Lệnh gọi lại đọc/ghi/mmap thực hiện quyền truy cập vùng thiết bị được xác định
	  bởi VFIO_DEVICE_GET_REGION_INFO ioctl của chính thiết bị.

- Yêu cầu gọi lại được đưa ra khi thiết bị sắp được hủy đăng ký,
	  chẳng hạn như khi cố gắng hủy liên kết thiết bị khỏi trình điều khiển xe buýt vfio.

- Lệnh gọi lại dma_unmap được đưa ra khi một phạm vi iovas chưa được ánh xạ
	  trong thùng chứa hoặc IOAS được gắn bởi thiết bị. Trình điều khiển tạo ra
	  việc sử dụng giao diện ghim trang vfio phải triển khai lệnh gọi lại này trong
	  để bỏ ghim các trang trong phạm vi dma_unmap. Lái xe phải chịu đựng
	  cuộc gọi lại này ngay cả trước khi gọi tới open_device().

Ghi chú triển khai sPAPR của PPC64
----------------------------------

Việc triển khai này có một số chi tiết cụ thể:

1) Trên các hệ thống cũ hơn (POWER7 với P5IOC2/IODA1) chỉ có một nhóm IOMMU cho mỗi
   container được hỗ trợ dưới dạng bảng IOMMU được phân bổ tại thời điểm khởi động,
   một bảng cho mỗi nhóm IOMMU là Điểm cuối có thể phân vùng (PE)
   (PE thường là miền PCI nhưng không phải lúc nào cũng vậy).

Các hệ thống mới hơn (POWER8 với IODA2) có thiết kế phần cứng được cải tiến cho phép
   để loại bỏ giới hạn này và có nhiều nhóm IOMMU trên mỗi VFIO
   thùng chứa.

2) Phần cứng hỗ trợ cái gọi là cửa sổ DMA - dải địa chỉ PCI
   trong đó DMA được phép chuyển, mọi nỗ lực truy cập vào không gian địa chỉ
   ra khỏi cửa sổ dẫn đến sự cô lập toàn bộ PE.

3) Khách PPC64 được ảo hóa song song nhưng không được mô phỏng hoàn toàn. Có một chiếc API
   để ánh xạ/hủy ánh xạ các trang cho DMA và nó thường ánh xạ 1,32 trang cho mỗi cuộc gọi và
   hiện tại không có cách nào để giảm số lượng cuộc gọi. Để làm cho
   mọi thứ nhanh hơn, việc xử lý bản đồ/hủy bản đồ đã được triển khai ở chế độ thực
   cung cấp một hiệu suất tuyệt vời nhưng có những hạn chế như
   không có khả năng thực hiện hạch toán các trang bị khóa trong thời gian thực.

4) Theo đặc tả sPAPR, Điểm cuối có thể phân vùng (PE) là I/O
   cây con có thể được coi như một đơn vị cho mục đích phân vùng và
   phục hồi lỗi. PE có thể là một IOA (Bộ điều hợp IO) đơn hoặc đa chức năng, một
   chức năng của IOA đa chức năng hoặc nhiều IOA (có thể bao gồm
   cấu trúc chuyển mạch và cầu nối phía trên nhiều IOA). PPC64 phát hiện khách
   PCI gặp lỗi và khôi phục chúng thông qua các dịch vụ EEH RTAS, hoạt động trên
   cơ sở của các lệnh ioctl bổ sung.

Vì vậy, 4 ioctls bổ sung đã được thêm vào:

VFIO_IOMMU_SPAPR_TCE_GET_INFO
		trả về kích thước và điểm bắt đầu của cửa sổ DMA trên bus PCI.

VFIO_IOMMU_ENABLE
		cho phép container. Kế toán các trang bị khóa
		được thực hiện vào thời điểm này. Điều này cho phép người dùng trước tiên biết được những gì
		cửa sổ DMA được thiết lập và điều chỉnh rlimit trước khi thực hiện bất kỳ công việc thực tế nào.

VFIO_IOMMU_DISABLE
		vô hiệu hóa container.

VFIO_EEH_PE_OP
		cung cấp API để thiết lập, phát hiện và phục hồi lỗi EEH.

Luồng mã từ ví dụ trên sẽ được thay đổi một chút ::

struct vfio_eeh_pe_op pe_op = { .argsz = sizeof(pe_op), .flags = 0 };

	.....
/* Thêm nhóm vào vùng chứa */
	ioctl(nhóm, VFIO_GROUP_SET_CONTAINER, &container);

/* Kích hoạt mô hình IOMMU mà chúng tôi muốn */
	ioctl(thùng chứa, VFIO_SET_IOMMU, VFIO_SPAPR_TCE_IOMMU)

/* Nhận thông tin bổ sung về sPAPR IOMMU */
	vfio_iommu_spapr_tce_info spapr_iommu_info;
	ioctl(container, VFIO_IOMMU_SPAPR_TCE_GET_INFO, &spapr_iommu_info);

if (ioctl(container, VFIO_IOMMU_ENABLE))
		/* Không thể bật vùng chứa, có thể giới hạn thấp */

/* Phân bổ một số không gian và thiết lập ánh xạ DMA */
	dma_map.vaddr = mmap(0, 1024 * 1024, PROT_READ | PROT_WRITE,
			     MAP_PRIVATE | MAP_ANONYMOUS, 0, 0);

dma_map.size = 1024 * 1024;
	dma_map.iova = 0; /* 1MB bắt đầu từ 0x0 từ chế độ xem thiết bị */
	dma_map.flags = VFIO_DMA_MAP_FLAG_READ | VFIO_DMA_MAP_FLAG_WRITE;

/* Kiểm tra ở đây xem .iova/.size có nằm trong cửa sổ DMA từ spapr_iommu_info */
	ioctl(container, VFIO_IOMMU_MAP_DMA, &dma_map);

/* Lấy bộ mô tả tập tin cho thiết bị */
	thiết bị = ioctl(nhóm, VFIO_GROUP_GET_DEVICE_FD, "0000:06:0d.0");

	....

/* Đặt lại và sử dụng thiết bị miễn phí... */
	ioctl(thiết bị, VFIO_DEVICE_RESET);

/* Đảm bảo EEH được hỗ trợ */
	ioctl(thùng chứa, VFIO_CHECK_EXTENSION, VFIO_EEH);

/* Kích hoạt chức năng EEH trên thiết bị */
	pe_op.op = VFIO_EEH_PE_ENABLE;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

/* Bạn nên tạo thêm cấu trúc dữ liệu để thể hiện
	 * PE và đặt các thiết bị con thuộc cùng nhóm IOMMU vào
	 * Ví dụ PE để tham khảo sau.
	 */

/* Kiểm tra trạng thái của PE và đảm bảo nó ở trạng thái hoạt động */
	pe_op.op = VFIO_EEH_PE_GET_STATE;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

/* Lưu trạng thái thiết bị bằng pci_save_state().
	 * EEH phải được bật trên thiết bị được chỉ định.
	 */

	....

/* Đưa ra lỗi EEH, lỗi này được cho là do 32-bit gây ra
	 * tải cấu hình.
	 */
	pe_op.op = VFIO_EEH_PE_INJECT_ERR;
	pe_op.err.type = EEH_ERR_TYPE_32;
	pe_op.err.func = EEH_ERR_FUNC_LD_CFG_ADDR;
	pe_op.err.addr = 0ul;
	pe_op.err.mask = 0ul;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

	....

/* Khi 0xFF được trả về sau khi đọc không gian cấu hình PCI hoặc IO BAR
	 * của thiết bị PCI. Kiểm tra trạng thái của PE để xem liệu điều đó có đúng không
	 * đông lạnh.
	 */
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

/* Đang chờ các giao dịch PCI đang chờ xử lý được hoàn thành và không
	 * tạo thêm bất kỳ lưu lượng truy cập PCI nào từ/đến PE bị ảnh hưởng cho đến khi
	 * quá trình phục hồi đã hoàn tất.
	 */

/* Kích hoạt IO cho PE bị ảnh hưởng và thu thập nhật ký. Thông thường,
	 * phần tiêu chuẩn của không gian cấu hình PCI, các thanh ghi AER bị hủy
	 * dưới dạng nhật ký để phân tích thêm.
	 */
	pe_op.op = VFIO_EEH_PE_UNFREEZE_IO;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

/*
	 * Vấn đề reset PE: reset nóng hoặc reset cơ bản. Thông thường, thiết lập lại nóng
	 * là đủ. Tuy nhiên, phần sụn của một số bộ điều hợp PCI sẽ
	 * yêu cầu thiết lập lại cơ bản.
	 */
	pe_op.op = VFIO_EEH_PE_RESET_HOT;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);
	pe_op.op = VFIO_EEH_PE_RESET_DEACTIVATE;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

/* Định cấu hình cầu nối PCI cho PE bị ảnh hưởng */
	pe_op.op = VFIO_EEH_PE_CONFIGURE;
	ioctl(container, VFIO_EEH_PE_OP, &pe_op);

/* Đã khôi phục trạng thái mà chúng ta đã lưu lúc khởi tạo. pci_restore_state()
	 * là đủ tốt để làm ví dụ.
	 */

/* Hy vọng lỗi được khắc phục thành công. Bây giờ, bạn có thể tiếp tục
	 * bắt đầu lưu lượng truy cập PCI đến/từ PE bị ảnh hưởng.
	 */

	....

5) Có v2 của SPAPR TCE IOMMU. Nó không dùng VFIO_IOMMU_ENABLE/
   VFIO_IOMMU_DISABLE và triển khai 2 ioctls mới:
   VFIO_IOMMU_SPAPR_REGISTER_MEMORY và VFIO_IOMMU_SPAPR_UNREGISTER_MEMORY
   (không được hỗ trợ trong v1 IOMMU).

PPC64 khách ảo hóa tạo ra rất nhiều yêu cầu bản đồ/hủy bản đồ,
   và việc xử lý những việc đó bao gồm ghim/bỏ ghim trang và cập nhật
   bộ đếm mm::locked_vm để đảm bảo chúng tôi không vượt quá rlimit.
   Phiên bản v2 IOMMU chia việc tính toán và ghim thành các hoạt động riêng biệt:

- VFIO_IOMMU_SPAPR_REGISTER_MEMORY/VFIO_IOMMU_SPAPR_UNREGISTER_MEMORY ioctls
     nhận địa chỉ không gian người dùng và kích thước của khối được ghim.
     Chia đôi không được hỗ trợ và VFIO_IOMMU_UNREGISTER_MEMORY dự kiến sẽ
     được gọi với địa chỉ và kích thước chính xác được sử dụng để đăng ký
     khối bộ nhớ. Không gian người dùng dự kiến ​​sẽ không gọi những thứ này thường xuyên.
     Các phạm vi được lưu trữ trong danh sách liên kết trong vùng chứa VFIO.

- VFIO_IOMMU_MAP_DMA/VFIO_IOMMU_UNMAP_DMA ioctls chỉ cập nhật thực tế
     Bảng IOMMU và không ghim; thay vào đó chúng sẽ kiểm tra xem không gian người dùng
     địa chỉ nằm trong phạm vi đã đăng ký trước.

Sự tách biệt này giúp tối ưu hóa DMA cho khách.

6) Thông số kỹ thuật sPAPR cho phép khách bật (các) cửa sổ DMA bổ sung
   một bus PCI có kích thước trang thay đổi. Hai ioctls đã được thêm vào để hỗ trợ
   cái này: VFIO_IOMMU_SPAPR_TCE_CREATE và VFIO_IOMMU_SPAPR_TCE_REMOVE.
   Nền tảng phải hỗ trợ chức năng nếu không lỗi sẽ được trả về
   không gian người dùng. Phần cứng hiện có hỗ trợ tối đa 2 cửa sổ DMA, một là
   Dài 2GB, sử dụng các trang 4K và được gọi là "cửa sổ 32bit mặc định"; người kia có thể
   lớn bằng toàn bộ RAM, sử dụng kích thước trang khác nhau, tùy chọn - khách
   tạo những thứ đó trong thời gian chạy nếu trình điều khiển khách hỗ trợ DMA 64bit.

VFIO_IOMMU_SPAPR_TCE_CREATE nhận được chuyển trang, kích thước cửa sổ DMA và
   một số cấp độ bảng TCE (nếu bảng TCE đủ lớn và
   hạt nhân có thể không có khả năng phân bổ đủ vùng vật lý liền kề
   trí nhớ). Nó tạo một cửa sổ mới trong khe có sẵn và trả về bus
   địa chỉ nơi cửa sổ mới bắt đầu. Do hạn chế về phần cứng nên người dùng
   space không thể chọn vị trí của cửa sổ DMA.

VFIO_IOMMU_SPAPR_TCE_REMOVE nhận địa chỉ bắt đầu xe buýt của cửa sổ
   và loại bỏ nó.

-------------------------------------------------------------------------------

.. [1] VFIO was originally an acronym for "Virtual Function I/O" in its
   initial implementation by Tom Lyon while as Cisco.  We've since
   outgrown the acronym, but it's catchy.

.. [2] "safe" also depends upon a device being "well behaved".  It's
   possible for multi-function devices to have backdoors between
   functions and even for single function devices to have alternative
   access to things like PCI config space through MMIO registers.  To
   guard against the former we can include additional precautions in the
   IOMMU driver to group multi-function PCI devices together
   (iommu=group_mf).  The latter we can't prevent, but the IOMMU should
   still provide isolation.  For PCI, SR-IOV Virtual Functions are the
   best indicator of "well behaved", as these are designed for
   virtualization usage models.

.. [3] As always there are trade-offs to virtual machine device
   assignment that are beyond the scope of VFIO.  It's expected that
   future IOMMU technologies will reduce some, but maybe not all, of
   these trade-offs.

.. [4] In this case the device is below a PCI bridge, so transactions
   from either function of the device are indistinguishable to the iommu::

	-[0000:00]-+-1e.0-[06]--+-0d.0
				\-0d.1

	00:1e.0 PCI bridge: Intel Corporation 82801 PCI Bridge (rev 90)

.. [5] Nested translation is an IOMMU feature which supports two stage
   address translations.  This improves the address translation efficiency
   in IOMMU virtualization.

.. [6] PASID stands for Process Address Space ID, introduced by PCI
   Express.  It is a prerequisite for Shared Virtual Addressing (SVA)
   and Scalable I/O Virtualization (Scalable IOV).
