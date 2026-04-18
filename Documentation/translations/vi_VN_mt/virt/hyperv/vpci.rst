.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/hyperv/vpci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị truyền qua PCI
=========================
Trong máy ảo khách Hyper-V, các thiết bị truyền qua PCI (còn được gọi là
thiết bị PCI ảo hoặc thiết bị vPCI) là thiết bị PCI vật lý
được ánh xạ trực tiếp vào không gian địa chỉ vật lý của VM.
Trình điều khiển thiết bị khách có thể tương tác trực tiếp với phần cứng
không có sự trung gian của nhà ảo hóa máy chủ.  Cách tiếp cận này
cung cấp quyền truy cập băng thông cao hơn vào thiết bị với tốc độ thấp hơn
độ trễ so với các thiết bị được ảo hóa bởi
siêu giám sát.  Thiết bị sẽ xuất hiện với khách giống như nó
khi chạy trên kim loại trần, do đó không cần thay đổi
tới trình điều khiển thiết bị Linux cho thiết bị.

Thuật ngữ Hyper-V cho thiết bị vPCI là "Thiết bị rời
Bài tập" (DDA).  Tài liệu công khai cho Hyper-V DDA là
có sẵn ở đây: ZZ0000ZZ

.. _DDA: https://learn.microsoft.com/en-us/windows-server/virtualization/hyper-v/plan/plan-for-deploying-devices-using-discrete-device-assignment

DDA thường được sử dụng cho bộ điều khiển lưu trữ, chẳng hạn như NVMe,
và cho GPU.  Một cơ chế tương tự cho NIC được gọi là SR-IOV
và tạo ra những lợi ích tương tự bằng cách cho phép thiết bị khách
driver tương tác trực tiếp với phần cứng.  Xem Hyper-V
tài liệu công khai ở đây: ZZ0000ZZ

.. _SR-IOV: https://learn.microsoft.com/en-us/windows-hardware/drivers/network/overview-of-single-root-i-o-virtualization--sr-iov-

Cuộc thảo luận về thiết bị vPCI này bao gồm DDA và SR-IOV
thiết bị.

Trình bày thiết bị
-------------------
Hyper-V cung cấp chức năng PCI đầy đủ cho thiết bị vPCI khi
nó đang hoạt động nên trình điều khiển thiết bị Linux cho thiết bị này có thể
được sử dụng không thay đổi, miễn là nó sử dụng đúng nhân Linux
API để truy cập không gian cấu hình PCI và để tích hợp khác
với Linux.  Nhưng việc phát hiện ban đầu về thiết bị PCI và
sự tích hợp của nó với hệ thống con Linux PCI phải sử dụng Hyper-V
những cơ chế cụ thể.  Do đó, các thiết bị vPCI trên Hyper-V
có một danh tính kép.  Ban đầu chúng được trình bày cho Linux
khách dưới dạng thiết bị VMBus thông qua "ưu đãi" VMBus tiêu chuẩn
cơ chế, vì vậy chúng có danh tính VMBus và xuất hiện dưới
/sys/bus/vmbus/thiết bị.  Trình điều khiển VMBus vPCI trong Linux tại
driver/pci/controller/pci-hyperv.c xử lý một giao diện mới được giới thiệu
thiết bị vPCI bằng cách chế tạo cấu trúc liên kết bus PCI và tạo tất cả
cấu trúc dữ liệu thiết bị PCI bình thường trong Linux sẽ
tồn tại nếu thiết bị PCI được phát hiện thông qua ACPI trên cơ sở
hệ thống kim loại.  Khi các cấu trúc dữ liệu đó được thiết lập,
thiết bị cũng có danh tính PCI bình thường trong Linux và thông thường
Trình điều khiển thiết bị Linux cho thiết bị vPCI có thể hoạt động như thể nó
đang chạy trên Linux trên nền tảng kim loại trần.  Bởi vì các thiết bị vPCI
được trình bày một cách linh hoạt thông qua cơ chế ưu đãi VMBus, chúng
không xuất hiện trong bảng ACPI của máy khách Linux.  thiết bị vPCI
có thể được thêm vào VM hoặc xóa khỏi VM bất cứ lúc nào trong quá trình
tuổi thọ của VM chứ không chỉ trong quá trình khởi động ban đầu.

Với cách tiếp cận này, thiết bị vPCI là thiết bị VMBus và
Thiết bị PCI cùng một lúc.  Để đáp lại lời đề nghị của VMBus
thông báo, hàm hv_pci_probe() sẽ chạy và thiết lập một
Kết nối VMBus với vPCI VSP trên máy chủ Hyper-V.  Đó
kết nối có một kênh VMBus duy nhất.  Kênh được sử dụng để
trao đổi tin nhắn với vPCI VSP nhằm mục đích thiết lập
thiết lập và định cấu hình thiết bị vPCI trong Linux.  Một khi thiết bị
được cấu hình đầy đủ trong Linux dưới dạng thiết bị PCI, VMBus
kênh chỉ được sử dụng nếu Linux thay đổi vCPU bị gián đoạn
trong máy khách hoặc nếu thiết bị vPCI bị xóa khỏi
VM trong khi VM đang chạy.  Hoạt động liên tục của
thiết bị xảy ra trực tiếp giữa trình điều khiển thiết bị Linux cho
thiết bị và phần cứng, với kênh VMBus và VMBus
không đóng vai trò gì.

Cài đặt thiết bị PCI
--------------------
Thiết lập thiết bị PCI tuân theo trình tự mà Hyper-V ban đầu
được tạo cho khách Windows và điều đó có thể không phù hợp với
Khách Linux do sự khác biệt trong cấu trúc tổng thể của
hệ thống con Linux PCI so với Windows.  Tuy nhiên,
với một chút hack trong trình điều khiển PCI ảo Hyper-V dành cho
Linux, thiết bị PCI ảo được thiết lập trong Linux để
mã hệ thống con Linux PCI chung và trình điều khiển Linux cho
thiết bị "chỉ hoạt động".

Mỗi thiết bị vPCI được thiết lập trong Linux có PCI riêng
tên miền với một cây cầu máy chủ.  ID miền PCI có nguồn gốc từ
byte 4 và 5 của phiên bản GUID được gán cho VMBus vPCI
thiết bị.  Máy chủ Hyper-V không đảm bảo rằng các byte này
là duy nhất, vì vậy hv_pci_probe() có thuật toán để giải quyết
va chạm.  Độ phân giải va chạm được thiết kế để ổn định
trên các lần khởi động lại của cùng một VM để các ID miền PCI không
thay đổi khi domainID xuất hiện trong không gian người dùng
cấu hình một số thiết bị

hv_pci_probe() phân bổ phạm vi MMIO khách sẽ được sử dụng làm PCI
không gian cấu hình cho thiết bị.  Phạm vi MMIO này được truyền đạt
tới máy chủ Hyper-V qua kênh VMBus như một phần của việc thông báo
máy chủ lưu trữ rằng thiết bị đã sẵn sàng nhập d0.  Xem
hv_pci_enter_d0().  Khi khách truy cập sau đó
Phạm vi MMIO, máy chủ Hyper-V chặn các truy cập và bản đồ
chúng vào không gian cấu hình PCI của thiết bị vật lý.

hv_pci_probe() cũng nhận thông tin BAR cho thiết bị từ
máy chủ Hyper-V và sử dụng thông tin này để phân bổ MMIO
không gian cho các BAR.  Không gian MMIO đó sau đó được thiết lập thành
được liên kết với cầu chủ để nó hoạt động khi dùng chung
Mã hệ thống con PCI trong Linux xử lý BAR.

Cuối cùng, hv_pci_probe() tạo bus PCI gốc.  Lúc này
cho biết việc hack trình điều khiển ảo PCI của Hyper-V đã hoàn tất và
Máy Linux PCI bình thường để quét bus gốc hoạt động
phát hiện thiết bị, thực hiện khớp trình điều khiển và
khởi tạo trình điều khiển và thiết bị.

Loại bỏ thiết bị PCI
--------------------
Máy chủ Hyper-V có thể bắt đầu loại bỏ thiết bị vPCI khỏi
VM khách bất cứ lúc nào trong vòng đời của VM.  Việc loại bỏ
được xúi giục bởi một hành động của quản trị viên được thực hiện trên máy chủ Hyper-V và
không nằm dưới sự kiểm soát của hệ điều hành khách.

VM khách được thông báo về việc xóa bởi một máy chủ không được yêu cầu
Tin nhắn "Eject" được gửi từ máy chủ đến khách qua VMBus
kênh được liên kết với thiết bị vPCI.  Khi nhận được như vậy
một thông báo, trình điều khiển PCI ảo Hyper-V trong Linux
gọi không đồng bộ các lệnh gọi hệ thống con PCI của nhân Linux tới
tắt máy và tháo thiết bị.  Khi những cuộc gọi đó được
hoàn tất, thông báo "Hoàn tất đẩy" sẽ được gửi lại cho
Hyper-V qua kênh VMBus cho biết thiết bị có
đã được gỡ bỏ.  Tại thời điểm này, Hyper-V gửi lệnh hủy bỏ VMBus
thông báo tới máy khách Linux, trình điều khiển VMBus trong Linux
xử lý bằng cách xóa danh tính VMBus cho thiết bị.  Một lần
quá trình xử lý đã hoàn tất, tất cả dấu tích của thiết bị có
đã có mặt đã biến mất khỏi nhân Linux.  Việc hủy bỏ
thông báo cũng cho khách biết rằng Hyper-V đã dừng
cung cấp hỗ trợ cho thiết bị vPCI trong máy khách.  Nếu
khách đã cố gắng truy cập vào không gian MMIO của thiết bị đó, nó
sẽ là một tài liệu tham khảo không hợp lệ. Hypercalls ảnh hưởng đến thiết bị
lỗi trả về và bất kỳ tin nhắn nào khác được gửi trong VMBus
kênh bị bỏ qua.

Sau khi gửi thông báo Eject, Hyper-V cho phép VM khách
60 giây để tắt thiết bị một cách sạch sẽ và phản hồi bằng
Quá trình loại bỏ hoàn tất trước khi gửi hủy bỏ VMBus
tin nhắn.  Nếu vì lý do nào đó các bước Đẩy ra không hoàn thành
trong vòng 60 giây cho phép, máy chủ Hyper-V buộc phải
thực hiện các bước hủy bỏ, điều này có thể sẽ dẫn đến
lỗi xếp tầng trong máy khách vì thiết bị hiện không có
hiện diện lâu hơn từ quan điểm của khách và tiếp cận
Dung lượng MMIO của thiết bị sẽ bị lỗi.

Bởi vì quá trình phóng ra không đồng bộ và có thể xảy ra bất cứ lúc nào
trong vòng đời của máy ảo khách, việc đồng bộ hóa thích hợp trong
Trình điều khiển PCI ảo Hyper-V rất phức tạp.  Sự phóng ra đã được
được quan sát ngay cả trước khi thiết bị vPCI mới được cung cấp
thiết lập đầy đủ.  Trình điều khiển PCI ảo Hyper-V đã được cập nhật
nhiều lần trong nhiều năm để khắc phục điều kiện cuộc đua khi
sự phóng điện xảy ra vào những thời điểm không thích hợp. Phải cẩn thận khi
sửa đổi mã này để ngăn chặn việc tái xuất hiện những vấn đề như vậy.
Xem nhận xét trong mã.

Phân công ngắt
--------------------
Trình điều khiển PCI ảo Hyper-V hỗ trợ các thiết bị vPCI sử dụng
MSI, multi-MSI hoặc MSI-X.  Chỉ định vCPU khách sẽ
nhận được ngắt cho một tin nhắn MSI hoặc MSI-X cụ thể là
phức tạp do cách thiết lập IRQ của Linux ánh xạ vào
các giao diện Hyper-V.  Đối với các trường hợp MSI và MSI-X đơn,
Linux gọi hv_compse_msi_msg() hai lần, với cuộc gọi đầu tiên
chứa một vCPU giả và lệnh gọi thứ hai chứa
vCPU thực sự.  Hơn nữa, hv_irq_unmask() cuối cùng cũng được gọi
(trên x86) hoặc các thanh ghi GICD được đặt (trên arm64) để chỉ định
vCPU thực sự nữa.  Mỗi cuộc gọi trong số ba cuộc gọi này tương tác
với Hyper-V, nó phải quyết định CPU vật lý nào sẽ
nhận ngắt trước khi nó được chuyển tiếp đến VM khách.
Thật không may, quá trình ra quyết định của Hyper-V hơi phức tạp.
bị hạn chế và có thể dẫn đến việc tập trung thể chất
bị gián đoạn trên một CPU, gây tắc nghẽn hiệu suất.
Xem chi tiết về cách giải quyết vấn đề này trong phạm vi rộng
nhận xét phía trên hàm hv_compose_msi_req_get_cpu().

Trình điều khiển PCI ảo Hyper-V thực hiện
irq_chip.irq_compose_msi_msg hoạt động như hv_compose_msi_msg().
Thật không may, trên Hyper-V việc triển khai yêu cầu gửi
một tin nhắn VMBus tới máy chủ Hyper-V và chờ ngắt
cho biết đã nhận được tin nhắn trả lời.  Kể từ khi
irq_chip.irq_compose_msi_msg có thể được gọi bằng khóa IRQ
giữ, sẽ không thể ngủ bình thường cho đến khi bị đánh thức bởi
sự gián đoạn. Thay vào đó hv_compose_msi_msg() phải gửi
Tin nhắn VMBus, sau đó thăm dò ý kiến ​​hoàn thành. Như
phức tạp hơn nữa, thiết bị vPCI có thể bị loại bỏ/hủy bỏ
trong khi cuộc bỏ phiếu đang diễn ra, vì vậy kịch bản này phải được thực hiện
cũng được phát hiện.  Xem nhận xét trong mã liên quan đến điều này
khu vực rất khó khăn.

Hầu hết mã trong trình điều khiển PCI ảo Hyper-V (pci-
hyperv.c) áp dụng cho khách Hyper-V và Linux chạy trên x86
và trên kiến trúc arm64.  Nhưng có sự khác biệt về cách
nhiệm vụ ngắt được quản lý.  Trên x86, Hyper-V
Trình điều khiển PCI ảo trong khách phải thực hiện siêu cuộc gọi để thông báo
Hyper-V vCPU khách nào sẽ bị gián đoạn bởi mỗi
Ngắt MSI/MSI-X và số vectơ ngắt x86
miền x86_vector IRQ đã chọn làm ngắt.  Cái này
hypercall được tạo bởi hv_arch_irq_unmask().  Trên arm64,
Trình điều khiển PCI ảo Hyper-V quản lý việc phân bổ SPI
cho mỗi ngắt MSI/MSI-X.  Trình điều khiển PCI ảo Hyper-V
lưu trữ SPI được phân bổ trong các thanh ghi GICD kiến trúc,
mà Hyper-V mô phỏng, do đó không cần hypercall như với
x86.  Hyper-V không hỗ trợ sử dụng LPI cho thiết bị vPCI trong
máy ảo khách arm64 vì nó không mô phỏng GICv3 ITS.

Trình điều khiển PCI ảo Hyper-V trong Linux hỗ trợ các thiết bị vPCI
có trình điều khiển tạo IRQ Linux được quản lý hoặc không được quản lý.  Nếu
smp_affinity cho IRQ không được quản lý được cập nhật thông qua /proc/irq
giao diện, trình điều khiển PCI ảo Hyper-V được gọi để thông báo
máy chủ Hyper-V để thay đổi mục tiêu ngắt và
mọi thứ đều hoạt động bình thường.  Tuy nhiên, trên x86 nếu x86_vector
Miền IRQ cần gán lại một vectơ ngắt do
hết vectơ trên CPU, không có đường dẫn nào để thông báo cho
Máy chủ Hyper-V thay đổi và mọi thứ bị phá vỡ.  May mắn thay,
VM khách hoạt động trong môi trường thiết bị bị hạn chế trong đó
việc sử dụng tất cả các vectơ trên CPU sẽ không xảy ra. Vì như vậy
vấn đề chỉ là vấn đề lý thuyết chứ không phải là vấn đề thực tế
mối quan tâm, nó vẫn chưa được giải quyết.

DMA
---
Theo mặc định, Hyper-V ghim tất cả bộ nhớ VM khách vào máy chủ
khi VM được tạo và lập trình IOMMU vật lý để
cho phép VM có quyền truy cập DMA vào tất cả bộ nhớ của nó.  Do đó
việc gán các thiết bị PCI cho VM là an toàn và cho phép
hệ điều hành khách để lập trình chuyển DMA.  các
IOMMU vật lý ngăn chặn một vị khách độc hại bắt đầu
DMA vào bộ nhớ thuộc về máy chủ hoặc các máy ảo khác trên
chủ nhà. Từ quan điểm của khách Linux, việc chuyển DMA như vậy
đang ở chế độ "trực tiếp" vì Hyper-V không cung cấp địa chỉ ảo
IOMMU trong khách.

Hyper-V giả định rằng các thiết bị PCI vật lý luôn hoạt động
DMA kết hợp bộ nhớ đệm.  Khi chạy trên x86, hành vi này là
được yêu cầu bởi kiến trúc.  Khi chạy trên arm64,
kiến trúc cho phép cả kết hợp bộ đệm và
các thiết bị không kết hợp với bộ đệm, với hoạt động của từng thiết bị
được chỉ định trong ACPI DSDT.  Nhưng khi thiết bị PCI được chỉ định
đối với VM khách, thiết bị đó không xuất hiện trong DSDT, do đó
Trình điều khiển Hyper-V VMBus truyền bá thông tin kết hợp bộ đệm
từ nút VMBus trong ACPI DSDT tới tất cả các thiết bị VMBus,
bao gồm các thiết bị vPCI (vì chúng có danh tính kép là VMBus
thiết bị và dưới dạng thiết bị PCI).  Xem vmbus_dma_configure().
Các phiên bản Hyper-V hiện tại luôn chỉ ra rằng VMBus
bộ nhớ đệm nhất quán, vì vậy các thiết bị vPCI trên arm64 luôn được đánh dấu là
bộ nhớ đệm nhất quán và CPU không thực hiện bất kỳ đồng bộ hóa nào
hoạt động như một phần của lệnh gọi dma_map/unmap_*().

Các phiên bản giao thức vPCI
----------------------------
Như đã mô tả trước đây, trong quá trình thiết lập và phân tích thiết bị vPCI
tin nhắn được chuyển qua kênh VMBus giữa Hyper-V
máy chủ và trình điều khiển Hyper-v vPCI trong máy khách Linux.  Một số
thông báo đã được sửa đổi trong các phiên bản mới hơn của Hyper-V, vì vậy
khách và máy chủ phải đồng ý về phiên bản giao thức vPCI để
được sử dụng.  Phiên bản được thương lượng khi giao tiếp qua
kênh VMBus được thiết lập lần đầu tiên.  Xem
hv_pci_protocol_negotiation(). Các phiên bản mới hơn của giao thức
mở rộng hỗ trợ cho các máy ảo có hơn 64 vCPU và cung cấp
thông tin bổ sung về thiết bị vPCI, chẳng hạn như
nút NUMA ảo của khách mà nó có liên quan chặt chẽ nhất
phần cứng cơ bản.

Mối quan hệ của nút NUMA khách
------------------------------
Khi phiên bản giao thức vPCI cung cấp nó, NUMA khách
mối quan hệ nút của thiết bị vPCI được lưu trữ như một phần của Linux
thông tin thiết bị để trình điều khiển Linux sử dụng sau này. Xem
hv_pci_sign_numa_node().  Nếu phiên bản giao thức được đàm phán
không hỗ trợ máy chủ cung cấp thông tin về mối quan hệ NUMA,
khách Linux mặc định nút NUMA của thiết bị là 0. Nhưng ngay cả
khi phiên bản giao thức được đàm phán bao gồm mối quan hệ NUMA
thông tin, khả năng của máy chủ để cung cấp thông tin đó
thông tin phụ thuộc vào các tùy chọn cấu hình máy chủ nhất định.  Nếu
khách nhận được giá trị nút NUMA là "0", điều đó có thể có nghĩa là NUMA
nút 0 hoặc có thể có nghĩa là "không có thông tin".
Rất tiếc là không thể phân biệt được hai trường hợp
từ phía khách.

Truy cập không gian cấu hình PCI trong máy ảo CoCo
--------------------------------------------------
Trình điều khiển thiết bị Linux PCI truy cập không gian cấu hình PCI bằng cách sử dụng
bộ chức năng tiêu chuẩn được cung cấp bởi hệ thống con Linux PCI.
Trong máy khách Hyper-V, các hàm tiêu chuẩn này ánh xạ tới các hàm
hv_pcifront_read_config() và hv_pcifront_write_config()
trong trình điều khiển PCI ảo Hyper-V.  Trong các máy ảo thông thường,
các hàm hv_pcifront_*() này truy cập trực tiếp vào cấu hình PCI
không gian và bẫy truy cập vào Hyper-V sẽ được xử lý.
Nhưng trong máy ảo CoCo, mã hóa bộ nhớ sẽ ngăn Hyper-V
từ việc đọc luồng hướng dẫn khách đến mô phỏng
truy cập, vì vậy các hàm hv_pcifront_*() phải gọi
siêu lệnh với các đối số rõ ràng mô tả quyền truy cập
thực hiện.

Cấu hình chặn kênh quay lại
---------------------------
Máy chủ Hyper-V và trình điều khiển PCI ảo Hyper-V trong Linux
cùng nhau thực hiện giao tiếp kênh sau không chuẩn
đường đi giữa chủ và khách.  Đường dẫn kênh sau sử dụng
tin nhắn được gửi qua kênh VMBus được liên kết với vPCI
thiết bị.  Các hàm hyperv_read_cfg_blk() và
hyperv_write_cfg_blk() là các giao diện chính được cung cấp cho
các phần khác của nhân Linux.  Theo văn bản này, những
giao diện chỉ được sử dụng bởi trình điều khiển Mellanox mlx5 để vượt qua
dữ liệu chẩn đoán tới máy chủ Hyper-V đang chạy ở nơi công cộng Azure
đám mây.  Các hàm hyperv_read_cfg_blk() và
hyperv_write_cfg_blk() được triển khai trong một mô-đun riêng
(pci-hyperv-intf.c, dưới CONFIG_PCI_HYPERV_INTERFACE)
loại bỏ chúng một cách hiệu quả khi chạy trong môi trường không phải Hyper-V
môi trường.