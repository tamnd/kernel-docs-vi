.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pci/p2pdma.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Hỗ trợ PCI ngang hàng DMA
===============================

Xe buýt PCI hỗ trợ khá tốt để thực hiện chuyển DMA
giữa hai thiết bị trên xe buýt. Loại giao dịch này từ nay trở đi
được gọi là ngang hàng (hoặc P2P). Tuy nhiên, có một số vấn đề
làm cho các giao dịch P2P trở nên khó thực hiện theo cách hoàn toàn an toàn.

Đối với PCIe, việc định tuyến các gói lớp giao dịch (TLP) được xác định rõ ràng
cho đến khi chúng đến được cầu nối máy chủ hoặc cổng gốc. Nếu đường dẫn bao gồm các bộ chuyển mạch PCIe
sau đó dựa trên cài đặt ACS, giao dịch có thể định tuyến hoàn toàn trong
phân cấp PCIe và không bao giờ đến được cổng gốc. Hạt nhân sẽ đánh giá
cấu trúc liên kết PCIe và luôn cho phép P2P trong những trường hợp được xác định rõ ràng này.

Tuy nhiên, nếu giao dịch P2P đến được cầu chủ thì nó có thể phải
kẹp tóc ra cùng một cổng gốc, được định tuyến bên trong CPU SOC khác
Cổng gốc PCIe hoặc định tuyến nội bộ đến SOC.

Thông số kỹ thuật PCIe không xác định việc chuyển tiếp giao dịch giữa
các miền phân cấp và mặc định của kernel để chặn việc định tuyến như vậy. có một
danh sách cho phép cho phép phát hiện CTNH tốt, trong trường hợp đó là P2P giữa bất kỳ
hai thiết bị PCIe sẽ được phép.

Vì P2P vốn thực hiện các giao dịch giữa hai thiết bị nên cần có hai
trình điều khiển hợp tác bên trong kernel. Người lái xe cung cấp phải truyền đạt
MMIO của nó cho trình điều khiển tiêu thụ. Để đáp ứng các quy định về vòng đời của mô hình trình điều khiển,
MMIO phải xóa tất cả ánh xạ DMA, ngăn chặn tất cả các truy cập CPU, tất cả các trang
ánh xạ bảng được hoàn tác trước khi trình điều khiển cung cấp hoàn tất việc xóa().

Điều này đòi hỏi người cung cấp và người tiêu dùng phải tích cực làm việc cùng nhau để
đảm bảo rằng trình điều khiển tiêu thụ đã ngừng sử dụng MMIO trong quá trình gỡ bỏ
chu kỳ. Điều này được thực hiện bằng cách tắt đồng bộ hoặc chờ
để tất cả số lần giới thiệu sử dụng về 0.

Ở mức thấp nhất, hệ thống con P2P cung cấp một cấu trúc p2p_provider trần trụi
ủy quyền quản lý vòng đời cho trình điều khiển cung cấp. Người ta mong đợi rằng
trình điều khiển sử dụng tùy chọn này sẽ bọc bộ nhớ MMIO của họ trong DMABUF và sử dụng DMABUF
để cung cấp một tắt máy vô hiệu. Các địa chỉ MMIO này không có trang cấu trúc và
nếu được sử dụng với mmap() phải tạo PTE đặc biệt. Như vậy có rất ít
uAPI kernel có thể chấp nhận con trỏ tới chúng; đặc biệt là chúng không thể được sử dụng
với read()/write(), bao gồm O_DIRECT.

Dựa trên điều này, hệ thống con cung cấp một lớp để bọc MMIO trong ZONE_DEVICE
pgmap của MEMORY_DEVICE_PCI_P2PDMA để tạo các trang cấu trúc. Vòng đời của
pgmap đảm bảo rằng khi pgmap bị phá hủy, tất cả các trình điều khiển khác đều dừng lại
sử dụng MMIO. Tùy chọn này hoạt động với các luồng O_DIRECT, trong một số trường hợp, nếu
hệ thống con cơ bản hỗ trợ xử lý MEMORY_DEVICE_PCI_P2PDMA thông qua
FOLL_PCI_P2PDMA. Việc sử dụng FOLL_LONGTERM bị ngăn chặn. Vì điều này phụ thuộc vào pgmap
nó cũng dựa vào sự hỗ trợ kiến trúc cùng với sự liên kết và kích thước tối thiểu
những hạn chế.


Hướng dẫn viết tài xế
=====================

Trong quá trình triển khai P2P nhất định, có thể có ba hoặc nhiều hơn
các loại trình điều khiển hạt nhân đang hoạt động:

* Nhà cung cấp - Trình điều khiển cung cấp hoặc xuất bản các tài nguyên P2P như
  bộ nhớ hoặc chuông cửa đăng ký cho các trình điều khiển khác.
* Máy khách - Trình điều khiển sử dụng tài nguyên bằng cách thiết lập một
  Giao dịch DMA đến hoặc đi từ nó.
* Orchestrator - Trình điều khiển điều phối luồng dữ liệu giữa
  khách hàng và nhà cung cấp.

Trong nhiều trường hợp có thể có sự chồng chéo giữa ba loại này (tức là,
thông thường người lái xe vừa là nhà cung cấp vừa là khách hàng).

Ví dụ: trong quá trình triển khai NVMe Target Copy Offload:

* Trình điều khiển NVMe PCI vừa là máy khách, nhà cung cấp vừa là người điều phối
  trong đó nó hiển thị bất kỳ CMB (Bộ đệm bộ nhớ điều khiển) nào dưới dạng bộ nhớ P2P
  tài nguyên (nhà cung cấp), nó chấp nhận các trang bộ nhớ P2P làm bộ đệm trong các yêu cầu
  được sử dụng trực tiếp (máy khách) và nó cũng có thể sử dụng CMB làm
  các mục hàng đợi gửi (người điều phối).
* Trình điều khiển RDMA là khách hàng trong sự sắp xếp này để RNIC
  có thể DMA trực tiếp vào bộ nhớ do thiết bị NVMe tiếp xúc.
* Trình điều khiển NVMe Target (nvmet) có thể sắp xếp dữ liệu từ RNIC
  tới bộ nhớ P2P (CMB) rồi đến thiết bị NVMe (và ngược lại).

Đây hiện là sự sắp xếp duy nhất được hỗ trợ bởi kernel nhưng
người ta có thể tưởng tượng những điều chỉnh nhỏ cho điều này sẽ cho phép thực hiện tương tự
chức năng. Ví dụ: nếu một RNIC cụ thể đã thêm BAR với một số
bộ nhớ đằng sau nó, trình điều khiển của nó có thể thêm hỗ trợ với tư cách là nhà cung cấp P2P và
thì NVMe Target có thể sử dụng bộ nhớ của RNIC thay vì CMB
trong trường hợp thẻ NVMe đang sử dụng không hỗ trợ CMB.


Trình điều khiển của nhà cung cấp
---------------------------------

Nhà cung cấp chỉ cần đăng ký BAR (hoặc một phần của BAR)
dưới dạng tài nguyên P2P DMA sử dụng ZZ0000ZZ.
Điều này sẽ đăng ký các trang cấu trúc cho tất cả bộ nhớ được chỉ định.

Sau đó, nó có thể tùy ý xuất bản tất cả các tài nguyên của mình dưới dạng
Bộ nhớ P2P sử dụng ZZ0000ZZ. Điều này sẽ cho phép
bất kỳ trình điều khiển dàn nhạc nào để tìm và sử dụng bộ nhớ. Khi được đánh dấu vào
bằng cách này, tài nguyên phải là bộ nhớ thông thường, không có tác dụng phụ.

Hiện tại, điều này còn khá thô sơ ở chỗ tất cả các nguồn lực
thường sẽ là bộ nhớ P2P. Công việc trong tương lai có thể sẽ mở rộng
điều này bao gồm các loại tài nguyên khác như chuông cửa.


Trình điều khiển máy khách
--------------------------

Trình điều khiển máy khách chỉ phải sử dụng ánh xạ API ZZ0000ZZ
và ZZ0001ZZ hoạt động như bình thường và việc triển khai
sẽ làm điều đúng đắn cho bộ nhớ có khả năng P2P.


Trình điều khiển dàn nhạc
-------------------------

Nhiệm vụ đầu tiên mà trình điều khiển dàn nhạc phải làm là biên soạn một danh sách
tất cả các thiết bị khách sẽ tham gia vào một giao dịch nhất định. cho
ví dụ: trình điều khiển NVMe Target tạo một danh sách bao gồm không gian tên
chặn thiết bị và RNIC đang sử dụng. Nếu người điều phối có quyền truy cập vào
một nhà cung cấp P2P cụ thể sử dụng nó có thể kiểm tra tính tương thích bằng cách sử dụng
ZZ0000ZZ nếu không nó có thể tìm nhà cung cấp bộ nhớ
tương thích với tất cả các máy khách sử dụng ZZ0001ZZ.
Nếu có nhiều hơn một nhà cung cấp được hỗ trợ, nhà cung cấp gần nhất với tất cả khách hàng sẽ
được chọn đầu tiên. Nếu có nhiều hơn một nhà cung cấp ở khoảng cách như nhau, thì
một cái được trả lại sẽ được chọn ngẫu nhiên (nó không phải là tùy ý mà là
thực sự ngẫu nhiên). Hàm này trả về thiết bị PCI để sử dụng cho nhà cung cấp
với một tài liệu tham khảo được lấy và do đó khi không cần thiết nữa thì nên
được trả về bằng pci_dev_put().

Khi một nhà cung cấp được chọn, người điều phối có thể sử dụng
ZZ0000ZZ và ZZ0001ZZ đến
phân bổ bộ nhớ P2P từ nhà cung cấp. ZZ0002ZZ
và ZZ0003ZZ là các chức năng tiện lợi cho
phân bổ danh sách thu thập phân tán với bộ nhớ P2P.

Hãy cẩn thận về trang cấu trúc
------------------------------

Mặc dù các trang MEMORY_DEVICE_PCI_P2PDMA có thể được cài đặt trong VMAs,
pin_user_pages() và các liên quan sẽ không trả lại chúng trừ khi FOLL_PCI_P2PDMA được đặt.

Các trang MEMORY_DEVICE_PCI_P2PDMA cần được chăm sóc để hỗ trợ trong kernel. các
KVA vẫn là MMIO và vẫn phải được truy cập thông qua cổng thông thường
người trợ giúp readX()/writeX()/etc. Truy cập trực tiếp CPU (ví dụ: memcpy) bị cấm, chỉ
giống như bất kỳ bản đồ MMIO nào khác. Mặc dù điều này thực sự sẽ có tác dụng với một số
kiến trúc khác, những kiến trúc khác sẽ bị hỏng hoặc chỉ gặp sự cố trong kernel.
Việc hỗ trợ FOLL_PCI_P2PDMA trong hệ thống con yêu cầu phải kiểm tra nó để đảm bảo không có CPU
truy cập xảy ra.


Cách sử dụng với DMABUF
=======================

DMABUF cung cấp một giải pháp thay thế cho cấu trúc dựa trên trang ở trên
hệ thống máy khách/nhà cung cấp/người điều phối và nên được sử dụng khi trang cấu trúc
không tồn tại. Ở chế độ này, trình điều khiển xuất sẽ gói
một số MMIO của nó trong DMABUF và cung cấp DMABUF FD cho không gian người dùng.

Sau đó, không gian người dùng có thể chuyển FD tới trình điều khiển nhập sẽ yêu cầu
trình điều khiển xuất khẩu để ánh xạ nó tới nhà nhập khẩu.

Trong trường hợp này, pci_devices khởi tạo và pci đích đã được biết và hệ thống con P2P
được sử dụng để xác định loại ánh xạ. DMA API dựa trên Phys_addr_t được sử dụng để
thiết lập dma_addr_t.

Vòng đời được điều khiển bởi DMABUF move_notify(). Khi tài xế xuất khẩu muốn
để loại bỏ(), nó phải thực hiện tắt máy không hợp lệ đối với tất cả quá trình nhập DMABUF
trình điều khiển thông qua move_notify() và đồng bộ hóa DMA hủy ánh xạ tất cả MMIO.

Không trình điều khiển nhập nào có thể tiếp tục có bản đồ DMA tới MMIO sau
trình điều khiển xuất đã phá hủy p2p_provider.


Thư viện hỗ trợ P2P DMA
=======================

.. kernel-doc:: drivers/pci/p2pdma.c
   :export: