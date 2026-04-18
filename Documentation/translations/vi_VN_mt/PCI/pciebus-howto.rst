.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/PCI/pciebus-howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===============================================
Hướng dẫn lái xe buýt cổng tốc hành PCI HOWTO
===============================================

:Tác giả: Tom L Nguyễn tom.l.nguyen@intel.com 03/11/2004
:Bản quyền: ZZ0000ZZ 2004 Tập đoàn Intel

Giới thiệu về hướng dẫn này
===========================

Hướng dẫn này mô tả những điều cơ bản về trình điều khiển Bus cổng tốc hành PCI
và cung cấp thông tin về cách kích hoạt trình điều khiển dịch vụ để
đăng ký/hủy đăng ký với Trình điều khiển xe buýt cổng tốc hành PCI.


Trình điều khiển xe buýt cổng tốc hành PCI là gì
================================================

Cổng tốc hành PCI là cấu trúc cầu PCI-PCI hợp lý. Ở đó
có hai loại Cổng tốc hành PCI: Cổng gốc và Cổng chuyển mạch
Cảng. Cổng gốc tạo liên kết PCI Express từ PCI Express
Root Complex và Switch Port kết nối các liên kết PCI Express với
các bus PCI logic nội bộ. Cổng Switch, có cổng phụ
bus đại diện cho logic định tuyến nội bộ của switch, được gọi là
Cổng ngược dòng của switch. Cổng hạ lưu của switch đang kết nối từ
bus định tuyến nội bộ của chuyển đổi sang một bus đại diện cho luồng xuống
Liên kết PCI Express từ PCI Express Switch.

Cổng tốc hành PCI có thể cung cấp tối đa bốn chức năng riêng biệt,
trong tài liệu này được gọi là dịch vụ, tùy thuộc vào loại cổng của nó.
Các dịch vụ của PCI Express Port bao gồm hỗ trợ cắm nóng gốc (HP),
hỗ trợ sự kiện quản lý nguồn (PME), báo cáo lỗi nâng cao
hỗ trợ (AER) và hỗ trợ kênh ảo (VC). Những dịch vụ này có thể
được xử lý bởi một trình điều khiển phức tạp hoặc được phân phối riêng lẻ
và được xử lý bởi trình điều khiển dịch vụ tương ứng.

Tại sao nên sử dụng Trình điều khiển xe buýt cổng tốc hành PCI?
===============================================================

Trong các nhân Linux hiện có, Mô hình trình điều khiển thiết bị Linux cho phép
thiết bị vật lý chỉ được xử lý bởi một trình điều khiển duy nhất. PCI
Express Port là thiết bị Cầu nối PCI-PCI với nhiều cổng riêng biệt
dịch vụ. Để duy trì một giải pháp sạch sẽ và đơn giản cho mỗi dịch vụ
có thể có trình điều khiển dịch vụ phần mềm riêng. Trong trường hợp này một số
trình điều khiển dịch vụ sẽ cạnh tranh để giành được một thiết bị Cầu nối PCI-PCI.
Ví dụ: nếu dịch vụ cắm nóng gốc PCI Express Root Port
trình điều khiển được tải trước tiên, nó yêu cầu Cổng gốc cầu nối PCI-PCI. các
do đó kernel không tải trình điều khiển dịch vụ khác cho Root đó
Cảng. Nói cách khác, không thể có nhiều dịch vụ
trình điều khiển tải và chạy đồng thời trên thiết bị PCI-PCI Bridge
sử dụng mô hình trình điều khiển hiện tại.

Để kích hoạt nhiều trình điều khiển dịch vụ chạy đồng thời, cần có
có trình điều khiển PCI Express Port Bus, quản lý tất cả dân cư
PCI Express Ports và phân phối tất cả các yêu cầu dịch vụ được cung cấp
tới các trình điều khiển dịch vụ tương ứng theo yêu cầu. Một số chìa khóa
những ưu điểm của việc sử dụng trình điều khiển PCI Express Port Bus được liệt kê bên dưới:

- Cho phép nhiều trình điều khiển dịch vụ chạy đồng thời trên
    thiết bị Cổng cầu PCI-PCI.

- Cho phép thực hiện các trình điều khiển dịch vụ một cách độc lập
    cách tiếp cận theo giai đoạn.

- Cho phép một trình điều khiển dịch vụ chạy trên nhiều cầu PCI-PCI
    Các thiết bị cổng.

- Quản lý và phân phối tài nguyên của Cổng cầu PCI-PCI
    thiết bị tới trình điều khiển dịch vụ được yêu cầu.

Định cấu hình Trình điều khiển xe buýt cổng tốc hành PCI so với trình điều khiển dịch vụ
========================================================================================

Bao gồm Hỗ trợ trình điều khiển xe buýt cổng tốc hành PCI vào hạt nhân
----------------------------------------------------------------------

Việc bao gồm trình điều khiển PCI Express Port Bus phụ thuộc vào việc PCI có
Hỗ trợ nhanh được bao gồm trong cấu hình kernel. Hạt nhân sẽ
tự động bao gồm trình điều khiển PCI Express Port Bus làm kernel
trình điều khiển khi hỗ trợ PCI Express được bật trong kernel.

Kích hoạt hỗ trợ trình điều khiển dịch vụ
-----------------------------------------

Trình điều khiển thiết bị PCI được triển khai dựa trên Mô hình trình điều khiển thiết bị Linux.
Tất cả các trình điều khiển dịch vụ đều là trình điều khiển thiết bị PCI. Như đã thảo luận ở trên, đó là
không thể tải bất kỳ trình điều khiển dịch vụ nào khi kernel đã tải
Trình điều khiển xe buýt cổng tốc hành PCI. Để gặp Tài xế xe buýt cổng tốc hành PCI
Mô hình yêu cầu một số thay đổi tối thiểu trên trình điều khiển dịch vụ hiện có
không ảnh hưởng đến chức năng của trình điều khiển dịch vụ hiện có.

Trình điều khiển dịch vụ được yêu cầu sử dụng hai API hiển thị bên dưới để
đăng ký dịch vụ của mình với trình điều khiển PCI Express Port Bus (xem
phần 5.2.1 & 5.2.2). Điều quan trọng là một trình điều khiển dịch vụ
khởi tạo cấu trúc dữ liệu pcie_port_service_driver, được bao gồm trong
tệp tiêu đề /include/linux/pcieport_if.h, trước khi gọi các API này.
Nếu không làm như vậy sẽ dẫn đến nhận dạng không khớp, điều này ngăn cản
trình điều khiển Xe buýt cổng tốc hành PCI tải trình điều khiển dịch vụ.

pcie_port_service_register
~~~~~~~~~~~~~~~~~~~~~~~~~~
::

int pcie_port_service_register(struct pcie_port_service_driver *mới)

API này thay thế pci_register_driver API của Mô hình Trình điều khiển Linux. A
trình điều khiển dịch vụ phải luôn gọi pcie_port_service_register tại
mô-đun init. Lưu ý rằng sau khi tải trình điều khiển dịch vụ, các cuộc gọi
chẳng hạn như pci_enable_device(dev) và pci_set_master(dev) không còn nữa
cần thiết vì các cuộc gọi này được thực hiện bởi trình điều khiển Bus cổng PCI.

pcie_port_service_unregister
~~~~~~~~~~~~~~~~~~~~~~~~~~~~
::

void pcie_port_service_unregister(struct pcie_port_service_driver *mới)

pcie_port_service_unregister thay thế Mô hình trình điều khiển Linux
pci_unregister_driver. Nó luôn được gọi bởi trình điều khiển dịch vụ khi
mô-đun thoát ra.

Mã mẫu
~~~~~~~~~~~

Dưới đây là mã trình điều khiển dịch vụ mẫu để khởi tạo dịch vụ cổng
cấu trúc dữ liệu điều khiển
:::::::::::::::::::::::::::

cấu trúc tĩnh pcie_port_service_id service_id[] = { {
    .nhà cung cấp = PCI_ANY_ID,
    .thiết bị = PCI_ANY_ID,
    .port_type = PCIE_RC_PORT,
    .service_type = PCIE_PORT_SERVICE_AER,
    }, { /* end: toàn số 0 */ }
  };

cấu trúc tĩnh pcie_port_service_driver root_aerdrv = {
    .name = (char *)device_name,
    .id_table = dịch vụ_id,

.probe = aerdrv_load,
    .remove = aerdrv_unload,

.suspend = aerdrv_suspend,
    .resume = aerdrv_resume,
  };

Dưới đây là mã mẫu để đăng ký/hủy đăng ký dịch vụ
người lái xe.
:::::::::::::

int tĩnh __init aerdrv_service_init(void)
  {
    int retval = 0;

retval = pcie_port_service_register(&root_aerdrv);
    nếu (!retval) {
      /*
      * FIX TÔI
      */
    }
    trả lại;
  }

khoảng trống tĩnh __exit aerdrv_service_exit(void)
  {
    pcie_port_service_unregister(&root_aerdrv);
  }

module_init(aerdrv_service_init);
  module_exit(aerdrv_service_exit);

Xung đột tài nguyên có thể xảy ra
=================================

Vì tất cả trình điều khiển dịch vụ của thiết bị Cổng cầu PCI-PCI đều
được phép chạy đồng thời, bên dưới liệt kê một số tài nguyên có thể
xung đột với các giải pháp được đề xuất.

Tài nguyên vectơ MSI và MSI-X
-----------------------------

Khi các ngắt MSI hoặc MSI-X được bật trên một thiết bị, nó vẫn ở trạng thái này
chế độ này cho đến khi chúng bị tắt trở lại.  Vì trình điều khiển dịch vụ giống nhau
Cổng cầu PCI-PCI chia sẻ cùng một thiết bị vật lý, nếu một cá nhân
trình điều khiển dịch vụ bật hoặc tắt chế độ MSI/MSI-X, điều này có thể dẫn đến
hành vi không thể đoán trước.

Để tránh tình trạng này, tất cả các tài xế dịch vụ không được phép
chuyển chế độ ngắt trên thiết bị của nó. Trình điều khiển xe buýt cổng tốc hành PCI
chịu trách nhiệm xác định chế độ ngắt và điều này phải được thực hiện
minh bạch đối với trình điều khiển dịch vụ. Trình điều khiển dịch vụ chỉ cần biết
vectơ IRQ được gán cho trường irq của struct pcie_device, trong đó
được chuyển vào khi trình điều khiển PCI Express Port Bus thăm dò từng dịch vụ
người lái xe. Trình điều khiển dịch vụ nên sử dụng (struct pcie_device*)dev->irq để
gọi request_irq/free_irq. Ngoài ra, chế độ ngắt được lưu trữ
trong trường ngắt_mode của cấu trúc pcie_device.

Vùng được ánh xạ bộ nhớ/IO PCI
------------------------------

Trình điều khiển dịch vụ cho PCI Express Power Management (PME), Nâng cao
Truy cập Báo cáo Lỗi (AER), Hot-Plug (HP) và Kênh ảo (VC)
Không gian cấu hình PCI trên cổng PCI Express. Trong mọi trường hợp
các thanh ghi được truy cập độc lập với nhau. Bản vá này giả định
rằng tất cả trình điều khiển dịch vụ sẽ hoạt động tốt và không bị ghi đè
cài đặt cấu hình của trình điều khiển dịch vụ khác.

Thanh ghi cấu hình PCI
----------------------

Mỗi trình điều khiển dịch vụ tự chạy các hoạt động cấu hình PCI của nó
cấu trúc khả năng ngoại trừ cấu trúc khả năng PCI Express,
được chia sẻ giữa nhiều trình điều khiển bao gồm cả trình điều khiển dịch vụ.
Trình truy cập khả năng RMW (pcie_capability_clear_and_set_word(),
pcie_capability_set_word() và pcie_capability_clear_word()) bảo vệ
một bộ Thanh ghi khả năng Express PCI đã chọn:

* Đăng ký điều khiển liên kết
* Đăng ký kiểm soát gốc
* Liên kết điều khiển 2 Đăng ký

Mọi thay đổi đối với các thanh ghi đó phải được thực hiện bằng cách sử dụng các bộ truy cập RMW để
tránh các vấn đề do cập nhật đồng thời. Để có danh sách cập nhật mới nhất
các thanh ghi được bảo vệ, xem pcie_capability_clear_and_set_word().