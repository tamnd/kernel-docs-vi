.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/iommufd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
IOMMUFD
=======

:Tác giả: Jason Gunthorpe
:Tác giả: Kevin Tian

Tổng quan
========

IOMMUFD là người dùng API để điều khiển hệ thống con IOMMU vì nó liên quan đến việc quản lý
Bảng trang IO từ không gian người dùng bằng cách sử dụng bộ mô tả tệp. Nó có ý định chung chung
và có thể sử dụng được bởi bất kỳ trình điều khiển nào muốn đưa DMA vào không gian người dùng. Những cái này
các trình điều khiển cuối cùng được cho là sẽ không dùng nữa bất kỳ logic IOMMU nội bộ nào
họ có thể đã/đã triển khai trong lịch sử (ví dụ: vfio_iommu_type1.c).

Ở mức tối thiểu iommufd cung cấp hỗ trợ chung cho việc quản lý không gian địa chỉ I/O và
Các bảng trang I/O cho tất cả IOMMU, có chỗ trong thiết kế để thêm các trang không chung chung
các tính năng để phục vụ cho chức năng phần cứng cụ thể.

Trong ngữ cảnh này, chữ in hoa (IOMMUFD) đề cập đến hệ thống con trong khi
chữ cái nhỏ (iommufd) đề cập đến các bộ mô tả tệp được tạo thông qua /dev/iommu cho
sử dụng bởi không gian người dùng.

Các khái niệm chính
============

Đối tượng hiển thị của người dùng
--------------------

Các đối tượng IOMMUFD sau đây được hiển thị trong không gian người dùng:

- IOMMUFD_OBJ_IOAS, đại diện cho không gian địa chỉ I/O (IOAS), cho phép ánh xạ/hủy ánh xạ
  bộ nhớ không gian người dùng thành các phạm vi Địa chỉ ảo I/O (IOVA).

IOAS là sự thay thế chức năng cho thùng chứa VFIO và giống như VFIO
  container, nó sao chép bản đồ IOVA vào danh sách iommu_domain được giữ trong đó.

- IOMMUFD_OBJ_DEVICE, đại diện cho một thiết bị được liên kết với iommufd bởi một
  trình điều khiển bên ngoài.

- IOMMUFD_OBJ_HWPT_PAGING, đại diện cho bảng trang I/O phần cứng thực tế
  (tức là một cấu trúc iommu_domain duy nhất) được quản lý bởi trình điều khiển iommu. "PAGING"
  chủ yếu chỉ ra loại HWPT này phải được liên kết với IOAS. Nó cũng
  chỉ ra rằng nó được hỗ trợ bởi iommu_domain với __IOMMU_DOMAIN_PAGING
  cờ tính năng Đây có thể là miền UNMANAGED giai đoạn 1 cho thiết bị
  chạy trong không gian người dùng hoặc miền cha mẹ giai đoạn 2 lồng nhau để ánh xạ
  từ địa chỉ vật lý cấp khách đến địa chỉ vật lý cấp máy chủ.

IOAS có một danh sách các HWPT_PAGING có chung ánh xạ IOVA và
  nó sẽ đồng bộ hóa ánh xạ của nó với từng thành viên HWPT_PAGING.

- IOMMUFD_OBJ_HWPT_NESTED, đại diện cho bảng trang I/O phần cứng thực tế
  (tức là một cấu trúc iommu_domain duy nhất) được quản lý bởi không gian người dùng (ví dụ: hệ điều hành khách).
  "NESTED" chỉ ra rằng loại HWPT này phải được liên kết với HWPT_PAGING.
  Nó cũng chỉ ra rằng nó được hỗ trợ bởi iommu_domain có một loại
  IOMMU_DOMAIN_NESTED. Đây phải là miền giai đoạn 1 cho thiết bị chạy trong
  không gian người dùng (ví dụ: trong máy ảo khách cho phép dịch lồng nhau IOMMU
  tính năng.) Như vậy, nó phải được tạo bằng giai đoạn 2 cha mẹ lồng nhau nhất định
  tên miền để liên kết tới. Bảng trang giai đoạn 1 lồng nhau này do người dùng quản lý
  không gian thường có ánh xạ từ các địa chỉ ảo I/O cấp độ khách tới
  địa chỉ vật lý cấp độ.

- IOMMUFD_FAULT, đại diện cho hàng đợi phần mềm cho trang IO báo cáo HWPT
  lỗi khi sử dụng PRI (Giao diện yêu cầu trang) của IOMMU HW. Đối tượng xếp hàng này
  cung cấp cho người dùng không gian một FD để thăm dò các sự kiện lỗi trang và cũng để phản hồi
  đến những sự kiện đó. Đối tượng FAULT phải được tạo trước tiên để nhận được error_id
  sau đó có thể được sử dụng để phân bổ HWPT bị lỗi thông qua IOMMU_HWPT_ALLOC
  lệnh bằng cách đặt bit IOMMU_HWPT_FAULT_ID_VALID trong trường cờ của nó.

- IOMMUFD_OBJ_VIOMMU, đại diện cho một phần của phiên bản IOMMU vật lý,
  được chuyển tới hoặc chia sẻ với VM. Nó có thể là một số ảo hóa được tăng tốc CTNH
  các tính năng và một số tài nguyên SW được VM sử dụng. Ví dụ:

* Không gian tên bảo mật cho ID do khách sở hữu, ví dụ: thẻ bộ đệm do khách kiểm soát
  * Báo cáo sự kiện không liên kết với thiết bị, ví dụ: lỗi hàng đợi vô hiệu
  * Truy cập vào bảng phân trang gốc lồng nhau có thể chia sẻ trên các IOMMU vật lý
  * Ảo hóa các ID nền tảng khác nhau, ví dụ: RID và những thứ khác
  * Cung cấp tính năng vô hiệu hóa ảo hóa
  * Hàng đợi vô hiệu được chỉ định trực tiếp
  * Ngắt được gán trực tiếp

Một đối tượng vIOMMU như vậy thường có quyền truy cập vào một bảng phân trang cha mẹ lồng nhau
  để hỗ trợ một số tính năng ảo hóa được tăng tốc CTNH. Vì vậy, một đối tượng vIOMMU
  phải được tạo dựa trên đối tượng HWPT_PAGING cha lồng nhau và sau đó nó sẽ
  đóng gói đối tượng HWPT_PAGING đó. Vì vậy, một đối tượng vIOMMU có thể được sử dụng
  để phân bổ một đối tượng HWPT_NESTED thay cho HWPT_PAGING được đóng gói.

  .. note::

     The name "vIOMMU" isn't necessarily identical to a virtualized IOMMU in a
     VM. A VM can have one giant virtualized IOMMU running on a machine having
     multiple physical IOMMUs, in which case the VMM will dispatch the requests
     or configurations from this single virtualized IOMMU instance to multiple
     vIOMMU objects created for individual slices of different physical IOMMUs.
     In other words, a vIOMMU object is always a representation of one physical
     IOMMU, not necessarily of a virtualized IOMMU. For VMMs that want the full
     virtualization features from physical IOMMUs, it is suggested to build the
     same number of virtualized IOMMUs as the number of physical IOMMUs, so the
     passed-through devices would be connected to their own virtualized IOMMUs
     backed by corresponding vIOMMU objects, in which case a guest OS would do
     the "dispatch" naturally instead of VMM trappings.

- IOMMUFD_OBJ_VDEVICE, đại diện cho một thiết bị ảo cho IOMMUFD_OBJ_DEVICE
  chống lại IOMMUFD_OBJ_VIOMMU. Thiết bị ảo này giữ ảo của thiết bị
  thông tin hoặc thuộc tính (liên quan đến vIOMMU) trong VM. Một vDATA ngay lập tức
  ví dụ có thể là ID ảo của thiết bị trên vIOMMU, là ID duy nhất
  VMM gán cho thiết bị cho kênh/cổng dịch của vIOMMU,
  ví dụ: vSID của ARM SMMUv3, vDeviceID của AMD IOMMU và vRID của Intel VT-d cho
  Bảng ngữ cảnh. Các trường hợp sử dụng tiềm năng của một số thông tin bảo mật nâng cao có thể
  cũng được chuyển tiếp qua đối tượng này, chẳng hạn như mức độ bảo mật hoặc thông tin về lĩnh vực
  trong Kiến trúc điện toán bí mật. VMM sẽ tạo một đối tượng vDEVICE
  để chuyển tiếp tất cả thông tin thiết bị trong VM khi nó kết nối một thiết bị với
  vIOMMU, là một lệnh gọi ioctl riêng biệt với việc gắn cùng một thiết bị vào một
  HWPT_PAGING mà vIOMMU nắm giữ.

- IOMMUFD_OBJ_VEVENTQ, đại diện cho hàng đợi phần mềm để vIOMMU báo cáo
  các sự kiện như lỗi dịch thuật xảy ra ở giai đoạn 1 lồng nhau (không bao gồm I/O
  lỗi trang phải trải qua IOMMUFD_OBJ_FAULT) và các sự kiện dành riêng cho CTNH.
  Đối tượng hàng đợi này cung cấp cho người dùng không gian FD để thăm dò/đọc các sự kiện vIOMMU. A
  Đối tượng vIOMMU phải được tạo trước tiên để lấy viommu_id của nó, sau đó có thể là
  được sử dụng để phân bổ vEVENTQ. Mỗi vIOMMU có thể hỗ trợ nhiều loại vEVENTS,
  nhưng được giới hạn ở một vEVENTQ cho mỗi loại vEVENTQ.

- IOMMUFD_OBJ_HW_QUEUE, đại diện cho hàng đợi được tăng tốc phần cứng, dưới dạng tập hợp con
  trong số các tính năng ảo hóa của IOMMU, để IOMMU HW đọc hoặc ghi trực tiếp
  bộ nhớ hàng đợi ảo thuộc sở hữu của hệ điều hành khách. Tính năng tăng tốc CTNH này có thể
  cho phép VM hoạt động trực tiếp với IOMMU HW mà không cần Thoát VM, để giảm
  chi phí từ các siêu cuộc gọi. Cùng với đối tượng HW QUEUE, iommufd cung cấp
  không gian người dùng một giao diện mmap cho VMM để mmap vùng MMIO vật lý từ
  lưu trữ không gian địa chỉ vật lý vào không gian địa chỉ vật lý của khách, cho phép
  Hệ điều hành khách để điều khiển trực tiếp HW QUEUE được phân bổ. Vì vậy, khi phân bổ một
  HW QUEUE, VMM phải yêu cầu một cặp thông tin mmap (độ lệch/độ dài) và chuyển vào
  chính xác tới một tòa nhà cao tầng mmap thông qua các đối số độ dài và độ lệch của nó.

Tất cả các đối tượng mà người dùng nhìn thấy đều bị hủy thông qua uAPI IOMMU_DESTROY.

Các sơ đồ bên dưới hiển thị mối quan hệ giữa các đối tượng mà người dùng nhìn thấy được và kernel
cơ sở hạ tầng (bên ngoài iommufd), với các số được đề cập đến các hoạt động
tạo các đối tượng và liên kết::

_______________________________________________________________________
 ZZ0000ZZ
 ZZ0001ZZ
 ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
 ZZ0008ZZ IOAS ZZ0009ZZ HWPT_PAGING ZZ0010ZZ DEVICE ZZ0011ZZ
 ZZ0012ZZ________________ZZ0013ZZ_____________ZZ0014ZZ________ZZ0015ZZ
 ZZ0016ZZ ZZ0017ZZ |
 ZZ0018ZZ____________________ZZ0019ZZ_____|
           ZZ0020ZZ |
           |              ______v_____ ___v__
           ZZ0021ZZ (phân trang) |                        |struct|
           |------------>|iommu_domain|<-----------------------|device|
                         ZZ0025ZZ ZZ0026ZZ

_______________________________________________________________________
 ZZ0000ZZ
 ZZ0001ZZ
 ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ
 ZZ0009ZZ IOAS ZZ0010ZZ HWPT_PAGING ZZ0011ZZ HWPT_NESTED ZZ0012ZZ DEVICE ZZ0013ZZ
 ZZ0014ZZ________________ZZ0015ZZ_____________ZZ0016ZZ_____________ZZ0017ZZ________ZZ0018ZZ
 ZZ0019ZZ ZZ0020ZZ ZZ0021ZZ
 ZZ0022ZZ____________________ZZ0023ZZ_______________ZZ0024ZZ
           ZZ0025ZZ ZZ0026ZZ
           |              ______v_____ ______v_____ ___v__
           ZZ0027ZZ (phân trang) ZZ0028ZZ (lồng nhau) |     |struct|
           |------------>|iommu_domain|<----|iommu_domain|<----|device|
                         ZZ0033ZZ ZZ0034ZZ ZZ0035ZZ

_______________________________________________________________________
 ZZ0000ZZ
 ZZ0001ZZ
 ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
 ZZ0007ZZ----------------ZZ0008ZZ<---ZZ0009ZZ<----ZZ0010ZZ
 ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ
 ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ
 ZZ0018ZZ [1] ZZ0019ZZ [4] ZZ0020ZZ
 ZZ0021ZZ ______ ZZ0022ZZ _____________ _ZZ0023ZZ
 ZZ0024ZZ ZZ0025ZZ ZZ0026ZZ ZZ0027ZZ ZZ0028ZZ |
 ZZ0029ZZ ZZ0030ZZ<---ZZ0031ZZ<---ZZ0032ZZ<--ZZ0033ZZ |
 ZZ0034ZZ ZZ0035ZZ ZZ0036ZZ ZZ0037ZZ ZZ0038ZZ |
 ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ |
 ZZ0042ZZ________ZZ0043ZZ__________________ZZ0044ZZ_____|
        ZZ0045ZZ ZZ0046ZZ |
  ______v_____ |        ______v_____ ______v_____ ___v__
 ZZ0047ZZ ZZ0048ZZ (phân trang) ZZ0049ZZ (lồng nhau) |     |struct|
 ZZ0051ZZ |------>|iommu_domain|<----|iommu_domain|<----|device|
 ZZ0055ZZ lưu trữ|____________| ZZ0057ZZ ZZ0058ZZ

1. IOMMUFD_OBJ_IOAS được tạo thông qua uAPI IOMMU_IOAS_ALLOC. Một iommufd có thể
   giữ nhiều đối tượng IOAS. IOAS là đối tượng chung nhất và không
   hiển thị các giao diện dành riêng cho trình điều khiển IOMMU đơn lẻ. Mọi hoạt động
   trên IOAS phải hoạt động bình đẳng trên mỗi iommu_domain bên trong nó.

2. IOMMUFD_OBJ_DEVICE được tạo khi trình điều khiển bên ngoài gọi IOMMUFD kAPI
   để liên kết một thiết bị với iommufd. Người lái xe dự kiến sẽ thực hiện một bộ
   ioctls để cho phép không gian người dùng bắt đầu thao tác liên kết. thành công
   việc hoàn thành hoạt động này sẽ thiết lập quyền sở hữu DMA mong muốn đối với
   thiết bị. Trình điều khiển cũng phải đặt cờ driver_managed_dma và không được
   chạm vào thiết bị cho đến khi thao tác này thành công.

3. IOMMUFD_OBJ_HWPT_PAGING có thể được tạo theo hai cách:

* IOMMUFD_OBJ_HWPT_PAGING được tạo tự động khi có trình điều khiển bên ngoài
     gọi IOMMUFD kAPI để gắn thiết bị được liên kết vào IOAS. Tương tự như vậy
     trình điều khiển bên ngoài uAPI cho phép không gian người dùng bắt đầu thao tác đính kèm.
     Nếu một đối tượng HWPT_PAGING thành viên tương thích tồn tại trong HWPT_PAGING của IOAS
     danh sách, sau đó nó sẽ được sử dụng lại. Mặt khác, HWPT_PAGING mới đại diện cho
     iommu_domain cho không gian người dùng sẽ được tạo và sau đó được thêm vào danh sách.
     Việc hoàn thành thành công hoạt động này sẽ thiết lập các mối liên kết giữa IOAS,
     thiết bị và iommu_domain. Khi việc này hoàn tất, thiết bị có thể thực hiện DMA.

* IOMMUFD_OBJ_HWPT_PAGING có thể được tạo thủ công thông qua IOMMU_HWPT_ALLOC
     uAPI, đã cung cấp ioas_id qua @pt_id để liên kết HWPT_PAGING mới với
     đối tượng IOAS tương ứng. Lợi ích của việc phân bổ thủ công này là
     cho phép cờ phân bổ (được xác định trong enum iommufd_hwpt_alloc_flags), ví dụ: nó
     phân bổ HWPT_PAGING cha mẹ lồng nhau nếu IOMMU_HWPT_ALLOC_NEST_PARENT
     cờ đã được thiết lập.

4. IOMMUFD_OBJ_HWPT_NESTED chỉ có thể được tạo thủ công thông qua IOMMU_HWPT_ALLOC
   uAPI, đã cung cấp hwpt_id hoặc viommu_id của đối tượng vIOMMU đóng gói một
   lồng nhau HWPT_PAGING cha thông qua @pt_id để liên kết đối tượng HWPT_NESTED mới
   tới đối tượng HWPT_PAGING tương ứng. Đối tượng HWPT_PAGING liên kết
   phải là cấp độ gốc lồng nhau được phân bổ thủ công thông qua cùng uAPI trước đó với
   cờ IOMMU_HWPT_ALLOC_NEST_PARENT, nếu không việc phân bổ sẽ thất bại. các
   việc phân bổ sẽ được xác nhận thêm bởi trình điều khiển IOMMU để đảm bảo rằng
   miền cha lồng nhau và miền lồng nhau được phân bổ đều tương thích.
   Việc hoàn thành thành công thao tác này sẽ thiết lập các liên kết giữa IOAS, thiết bị,
   và iommu_domains. Khi quá trình này hoàn tất, thiết bị có thể thực hiện DMA thông qua quy trình 2 giai đoạn
   bản dịch, hay còn gọi là bản dịch lồng nhau. Lưu ý rằng nhiều đối tượng HWPT_NESTED
   có thể được phân bổ bởi (và sau đó được liên kết với) cùng một cha mẹ lồng nhau.

   .. note::

      Either a manual IOMMUFD_OBJ_HWPT_PAGING or an IOMMUFD_OBJ_HWPT_NESTED is
      created via the same IOMMU_HWPT_ALLOC uAPI. The difference is at the type
      of the object passed in via the @pt_id field of struct iommufd_hwpt_alloc.

5. IOMMUFD_OBJ_VIOMMU chỉ có thể được tạo thủ công thông qua IOMMU_VIOMMU_ALLOC
   uAPI, đã cung cấp dev_id (dành cho IOMMU vật lý của thiết bị để hỗ trợ vIOMMU)
   và hwpt_id (để liên kết vIOMMU với HWPT_PAGING cha lồng nhau). các
   lõi iommufd sẽ liên kết đối tượng vIOMMU với cấu trúc iommu_device mà
   thiết bị cấu trúc ở phía sau. Và trình điều khiển IOMMU có thể triển khai viommu_alloc op
   để phân bổ cấu trúc dữ liệu vIOMMU của riêng nó nhúng cấu trúc cấp độ cốt lõi
   iommufd_viommu và một số dữ liệu dành riêng cho trình điều khiển. Nếu cần, người lái xe có thể
   cũng định cấu hình tính năng ảo hóa CTNH của nó cho vIOMMU đó (và do đó cho
   máy ảo). Việc hoàn thành thành công hoạt động này sẽ thiết lập mối liên kết giữa
   đối tượng vIOMMU và HWPT_PAGING thì đối tượng vIOMMU này có thể được sử dụng
   làm đối tượng cha lồng nhau để phân bổ đối tượng HWPT_NESTED được mô tả ở trên.

6. IOMMUFD_OBJ_VDEVICE chỉ có thể được tạo thủ công thông qua IOMMU_VDEVICE_ALLOC
   uAPI, đã cung cấp viommu_id cho đối tượng iommufd_viommu và dev_id cho đối tượng
   đối tượng iommufd_device. Đối tượng vDEVICE sẽ là sự ràng buộc giữa các đối tượng này
   hai đối tượng cha. Một @virt_id khác cũng sẽ được đặt thông qua việc cung cấp uAPI
   lõi iommufd là một chỉ mục để lưu trữ đối tượng vDEVICE vào một mảng vDEVICE trên mỗi
   viOMMU. Nếu cần, trình điều khiển IOMMU có thể chọn triển khai vdevce_alloc
   op để khởi tạo tính năng CTNH cho ảo hóa liên quan đến vDEVICE. thành công
   việc hoàn thành thao tác này sẽ thiết lập mối liên kết giữa vIOMMU và thiết bị.

Một thiết bị chỉ có thể liên kết với iommufd do yêu cầu quyền sở hữu DMA và đính kèm vào lúc
hầu hết một đối tượng IOAS (chưa hỗ trợ PASID).

Cơ sở hạ tầng hạt nhân
--------------------

Các đối tượng hiển thị của người dùng được hỗ trợ bởi các cơ sở dữ liệu sau:

- iommufd_ioas cho IOMMUFD_OBJ_IOAS.
- iommufd_device cho IOMMUFD_OBJ_DEVICE.
- iommufd_hwpt_paging cho IOMMUFD_OBJ_HWPT_PAGING.
- iommufd_hwpt_nested cho IOMMUFD_OBJ_HWPT_NESTED.
- iommufd_fault cho IOMMUFD_OBJ_FAULT.
- iommufd_viommu cho IOMMUFD_OBJ_VIOMMU.
- iommufd_vdevice cho IOMMUFD_OBJ_VDEVICE.
- iommufd_veventq cho IOMMUFD_OBJ_VEVENTQ.
- iommufd_hw_queue cho IOMMUFD_OBJ_HW_QUEUE.

Một số thuật ngữ khi xem xét các cơ sở hạ tầng này:

- Miền tự động - đề cập đến miền iommu được tạo tự động khi
  gắn thiết bị vào đối tượng IOAS. Điều này phù hợp với ngữ nghĩa của
  VFIO loại1.

- Miền thủ công - đề cập đến miền iommu được người dùng chỉ định làm
  bảng phân trang mục tiêu được gắn vào bởi một thiết bị. Mặc dù hiện nay có
  không có uAPI nào để trực tiếp tạo miền, cơ sở hạ tầng và thuật toán đó
  đã sẵn sàng để xử lý trường hợp sử dụng đó.

- Người dùng trong kernel - đề cập đến thứ gì đó giống như mdev VFIO đang sử dụng
  Giao diện truy cập IOMMUFD để truy cập IOAS. Điều này bắt đầu bằng việc tạo ra một
  Đối tượng iommufd_access tương tự như miền liên kết với thiết bị vật lý
  sẽ làm được. Đối tượng truy cập sau đó sẽ cho phép chuyển đổi phạm vi IOVA thành cấu trúc
  trang * hoặc thực hiện đọc/ghi trực tiếp vào IOVA.

iommufd_ioas đóng vai trò là cơ sở hạ tầng siêu dữ liệu để quản lý phạm vi IOVA
được ánh xạ tới các trang bộ nhớ, bao gồm:

- struct io_pagetable giữ bản đồ IOVA
- struct iopt_area đại diện cho các phần dân cư của IOVA
- struct iopt_pages thể hiện việc lưu trữ PFN
- struct iommu_domain đại diện cho bảng trang IO trong IOMMU
- struct iopt_pages_access đại diện cho người dùng PFN trong kernel
- struct xarray pinned_pfns chứa danh sách các trang được ghim bởi người dùng trong kernel

Mỗi iopt_pages đại diện cho một mảng tuyến tính logic của các PFN đầy đủ. Các PFN là
cuối cùng có nguồn gốc từ VA không gian người dùng thông qua mm_struct. Một khi họ đã
đã ghim các PFN được lưu trữ trong IOPTE của iommu_domain hoặc bên trong pinned_pfns
xarray nếu chúng đã được ghim thông qua iommufd_access.

PFN phải được sao chép giữa tất cả các kết hợp vị trí lưu trữ, tùy thuộc vào
về những miền hiện có và loại người dùng "truy cập phần mềm" trong kernel
tồn tại. Cơ chế này đảm bảo rằng một trang chỉ được ghim một lần.

Một io_pagetable bao gồm iopt_areas trỏ vào iopt_pages, cùng với một
danh sách iommu_domain phản ánh bản đồ IOVA đến PFN.

Nhiều io_pagetable-s, thông qua iopt_area-s của chúng, có thể chia sẻ một
iopt_pages để tránh việc ghim nhiều trang và tính toán hai lần trang
tiêu thụ.

iommufd_ioas có thể chia sẻ giữa các hệ thống con, ví dụ: VFIO và VDPA, miễn là
các thiết bị được quản lý bởi các hệ thống con khác nhau được liên kết với cùng một iommufd.

IOMMUFD Người dùng API
================

.. kernel-doc:: include/uapi/linux/iommufd.h

Hạt nhân IOMMUFD API
==================

KAPI IOMMUFD lấy thiết bị làm trung tâm với các thủ thuật liên quan đến nhóm được quản lý đằng sau
cảnh. Điều này cho phép các trình điều khiển bên ngoài gọi kAPI đó để thực hiện một cách đơn giản
uAPI tập trung vào thiết bị để kết nối thiết bị của nó với iommufd, thay vì
áp đặt rõ ràng ngữ nghĩa nhóm trong uAPI của nó giống như VFIO.

.. kernel-doc:: drivers/iommu/iommufd/device.c
   :export:

.. kernel-doc:: drivers/iommu/iommufd/main.c
   :export:

VFIO và IOMMUFD
----------------

Việc kết nối thiết bị VFIO với iommufd có thể được thực hiện theo hai cách.

Đầu tiên là cách tương thích với VFIO bằng cách triển khai trực tiếp /dev/vfio/vfio
chứa IOCTL bằng cách ánh xạ chúng vào các hoạt động io_pagetable. Làm như vậy cho phép
việc sử dụng iommufd trong các ứng dụng VFIO cũ bằng cách liên kết tượng trưng/dev/vfio/vfio với
/dev/iommufd hoặc mở rộng VFIO thành SET_CONTAINER bằng iommufd thay vì a
container fd.

Cách tiếp cận thứ hai trực tiếp mở rộng VFIO để hỗ trợ một nhóm thiết bị mới tập trung vào
người dùng API dựa trên kernel IOMMUFD API đã nói ở trên. Nó yêu cầu không gian người dùng
thay đổi nhưng phù hợp hơn với ngữ nghĩa IOMMUFD API và dễ hỗ trợ mới hơn
iommufd khi so sánh nó với cách tiếp cận đầu tiên.

Hiện tại cả hai phương pháp vẫn đang được tiến hành.

Vẫn còn một số lỗ hổng cần giải quyết để bắt kịp VFIO loại 1, như
được ghi lại trong iommufd_vfio_check_extension().

TODO trong tương lai
============

Hiện tại IOMMUFD chỉ hỗ trợ bảng trang I/O do kernel quản lý, tương tự như VFIO
loại1. Các tính năng mới trên radar bao gồm:

- Liên kết iommu_domain với PASID/SSID
 - Bảng trang không gian người dùng, dành cho ARM, x86 và S390
 - Kernel bypass'd vô hiệu hóa các bảng trang của người dùng
 - Tái sử dụng bảng trang KVM trong IOMMU
 - Theo dõi trang bẩn trong IOMMU
 - Tăng/Giảm thời gian chạy của kích thước IOPTE
 - Hỗ trợ PRI giải quyết các lỗi trong không gian người dùng