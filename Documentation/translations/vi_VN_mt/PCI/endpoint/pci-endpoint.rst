.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-endpoint.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Tài liệu này là hướng dẫn sử dụng Khung điểm cuối PCI để tạo
trình điều khiển bộ điều khiển điểm cuối, trình điều khiển chức năng điểm cuối và sử dụng configfs
giao diện để liên kết trình điều khiển chức năng với trình điều khiển bộ điều khiển.

Giới thiệu
============

Linux có hệ thống con PCI toàn diện để hỗ trợ bộ điều khiển PCI
hoạt động ở chế độ Root Complex. Hệ thống con có khả năng quét bus PCI,
gán tài nguyên bộ nhớ và tài nguyên IRQ, tải trình điều khiển PCI (dựa trên
ID nhà cung cấp, ID thiết bị), hỗ trợ các dịch vụ khác như cắm nóng, quản lý nguồn,
báo cáo lỗi nâng cao và các kênh ảo.

Tuy nhiên, IP bộ điều khiển PCI được tích hợp trong một số SoC có khả năng hoạt động
ở chế độ Root Complex hoặc chế độ Endpoint. Khung điểm cuối PCI sẽ
thêm hỗ trợ chế độ điểm cuối trong Linux. Điều này sẽ giúp chạy Linux trong một
Hệ thống EP có thể có nhiều trường hợp sử dụng khác nhau từ thử nghiệm hoặc
xác nhận, bộ tăng tốc đồng xử lý, v.v.

Lõi điểm cuối PCI
=================

Lớp lõi điểm cuối PCI bao gồm 3 thành phần: Bộ điều khiển điểm cuối
thư viện, thư viện Hàm điểm cuối và lớp configfs để liên kết
chức năng điểm cuối với bộ điều khiển điểm cuối.

Thư viện bộ điều khiển điểm cuối PCI (EPC)
------------------------------------------

Thư viện EPC cung cấp các API để bộ điều khiển có thể hoạt động
ở chế độ điểm cuối. Nó cũng cung cấp các API để trình điều khiển/thư viện chức năng sử dụng
để thực hiện một chức năng điểm cuối cụ thể.

API cho Trình điều khiển bộ điều khiển PCI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phần này liệt kê các API mà lõi Điểm cuối PCI cung cấp để sử dụng
bởi trình điều khiển bộ điều khiển PCI.

* devm_pci_epc_create()/pci_epc_create()

Trình điều khiển bộ điều khiển PCI phải triển khai các hoạt động sau:

* write_header: hoạt động để điền tiêu đề không gian cấu hình
	 * set_bar: chọn cấu hình BAR
	 * clear_bar: op để thiết lập lại BAR
	 * alloc_addr_space: hoạt động để phân bổ trong không gian địa chỉ của bộ điều khiển PCI
	 * free_addr_space: hoạt động để giải phóng không gian địa chỉ được phân bổ
	 * raise_irq: hoạt động để nâng cao di sản, ngắt MSI hoặc MSI-X
	 * bắt đầu: ops để bắt đầu liên kết PCI
	 * dừng: ops để dừng liên kết PCI

Trình điều khiển bộ điều khiển PCI sau đó có thể tạo một thiết bị EPC mới bằng cách gọi
   devm_pci_epc_create()/pci_epc_create().

* pci_epc_destroy()

Trình điều khiển bộ điều khiển PCI có thể phá hủy thiết bị EPC được tạo bởi
   pci_epc_create() bằng pci_epc_destroy().

* pci_epc_linkup()

Để thông báo cho tất cả các thiết bị chức năng mà thiết bị EPC đang sử dụng
   chúng được liên kết đã thiết lập liên kết với máy chủ, bộ điều khiển PCI
   trình điều khiển nên gọi pci_epc_linkup().

* pci_epc_mem_init()

Khởi tạo cấu trúc pci_epc_mem được sử dụng để phân bổ không gian địa chỉ EPC.

* pci_epc_mem_exit()

Dọn dẹp cấu trúc pci_epc_mem được phân bổ trong pci_epc_mem_init().


API EPC cho Trình điều khiển chức năng điểm cuối PCI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phần này liệt kê các API mà lõi Điểm cuối PCI cung cấp để sử dụng
bởi trình điều khiển chức năng điểm cuối PCI.

* pci_epc_write_header()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_write_header() để
   ghi tiêu đề cấu hình tiêu chuẩn vào bộ điều khiển điểm cuối.

* pci_epc_set_bar()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_set_bar() để định cấu hình
   Đăng ký địa chỉ cơ sở để máy chủ chỉ định không gian địa chỉ PCI.
   Không gian đăng ký của trình điều khiển chức năng thường được cấu hình
   sử dụng API này.

Một số bộ điều khiển điểm cuối cũng hỗ trợ gọi lại pci_epc_set_bar()
   cho cùng một BAR (không gọi pci_epc_clear_bar()) để cập nhật gửi đến
   dịch địa chỉ sau khi máy chủ đã lập trình địa chỉ cơ sở BAR.
   Trình điều khiển chức năng điểm cuối có thể kiểm tra khả năng này thông qua
   bit tính năng Dynamic_inbound_mapping EPC.

Khi pci_epf_bar.num_submap khác 0, trình điều khiển chức năng điểm cuối sẽ
   yêu cầu ánh xạ phạm vi con BAR bằng pci_epf_bar.submap. Điều này đòi hỏi
   EPC để quảng cáo hỗ trợ thông qua bit tính năng EPC subrange_mapping.

Khi trình điều khiển EPF muốn sử dụng ánh xạ dải phụ gửi đến
   tính năng này, nó yêu cầu địa chỉ cơ sở BAR đã được lập trình bởi
   máy chủ trong quá trình liệt kê. Vì vậy, nó cần gọi pci_epc_set_bar()
   hai lần cho cùng một BAR (yêu cầu Dynamic_inbound_mapping): lần đầu tiên với
   num_submap được đặt thành 0 và định cấu hình kích thước BAR, sau đó là PCIe
   liên kết được kích hoạt và máy chủ liệt kê điểm cuối và lập trình BAR
   địa chỉ cơ sở, một lần nữa với num_submap được đặt thành giá trị khác 0.

Lưu ý rằng khi sử dụng tính năng ánh xạ dải ô con gửi đến,
   Trình điều khiển EPF không được gọi pci_epc_clear_bar() giữa hai trình điều khiển
   cuộc gọi pci_epc_set_bar(), vì việc xóa BAR có thể xóa/vô hiệu hóa
   Đăng ký BAR hoặc giải mã BAR trên điểm cuối trong khi máy chủ vẫn mong đợi
   địa chỉ BAR được chỉ định vẫn hợp lệ.

* pci_epc_clear_bar()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_clear_bar() để đặt lại
   BAR.

* pci_epc_raise_irq()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_raise_irq() để nâng cao
   Ngắt kế thừa, Ngắt MSI hoặc MSI-X.

* pci_epc_mem_alloc_addr()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_mem_alloc_addr(), để
   phân bổ địa chỉ bộ nhớ từ không gian địa chỉ EPC cần thiết để truy cập
   Bộ đệm của RC

* pci_epc_mem_free_addr()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_mem_free_addr() để
   giải phóng không gian bộ nhớ được phân bổ bằng pci_epc_mem_alloc_addr().

* pci_epc_map_addr()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_map_addr() để ánh xạ tới RC
  PCI đánh địa chỉ CPU của bộ nhớ cục bộ thu được bằng
  pci_epc_mem_alloc_addr().

* pci_epc_unmap_addr()

Trình điều khiển chức năng điểm cuối PCI nên sử dụng pci_epc_unmap_addr() để hủy ánh xạ
  Địa chỉ CPU của bộ nhớ cục bộ được ánh xạ tới địa chỉ RC với pci_epc_map_addr().

* pci_epc_mem_map()

Bộ điều khiển điểm cuối PCI có thể áp đặt các ràng buộc trên các địa chỉ RC PCI
  có thể được lập bản đồ. Hàm pci_epc_mem_map() cho phép chức năng điểm cuối
  trình điều khiển để phân bổ và ánh xạ bộ nhớ bộ điều khiển trong khi xử lý các
  những hạn chế. Chức năng này sẽ xác định kích thước của bộ nhớ phải được
  được phân bổ bằng pci_epc_mem_alloc_addr() để ánh xạ thành công RC PCI
  phạm vi địa chỉ. Chức năng này cũng sẽ cho biết kích thước của địa chỉ PCI
  phạm vi đã được ánh xạ thực sự, có thể nhỏ hơn kích thước được yêu cầu, như
  cũng như phần bù vào bộ nhớ được phân bổ để sử dụng cho việc truy cập vào bản đồ
  Dải địa chỉ RC PCI.

* pci_epc_mem_unmap()

Trình điều khiển chức năng điểm cuối PCI có thể sử dụng pci_epc_mem_unmap() để hủy ánh xạ và giải phóng
  bộ nhớ bộ điều khiển được phân bổ và ánh xạ bằng pci_epc_mem_map().


Các API EPC khác
~~~~~~~~~~~~~~~~

Có các API khác được cung cấp bởi thư viện EPC. Chúng được sử dụng để ràng buộc
thiết bị EPF với thiết bị EPC. pci-ep-cfs.c có thể được sử dụng làm tài liệu tham khảo cho
sử dụng các API này.

* pci_epc_get()

Nhận tham chiếu đến bộ điều khiển điểm cuối PCI dựa trên tên thiết bị của
   người điều khiển.

* pci_epc_put()

Giải phóng tham chiếu đến bộ điều khiển điểm cuối PCI thu được bằng cách sử dụng
   pci_epc_get()

* pci_epc_add_epf()

Thêm chức năng điểm cuối PCI vào bộ điều khiển điểm cuối PCI. Một thiết bị PCIe
   có thể có tới 8 chức năng theo đặc điểm kỹ thuật.

* pci_epc_remove_epf()

Xóa chức năng điểm cuối PCI khỏi bộ điều khiển điểm cuối PCI.

* pci_epc_start()

Trình điều khiển chức năng điểm cuối PCI sẽ gọi pci_epc_start() sau khi nó
   đã cấu hình chức năng điểm cuối và muốn khởi động liên kết PCI.

* pci_epc_stop()

Trình điều khiển chức năng điểm cuối PCI sẽ gọi pci_epc_stop() để dừng
   PCI LINK.


Thư viện chức năng điểm cuối PCI (EPF)
--------------------------------------

Thư viện EPF cung cấp các API để trình điều khiển chức năng và EPC sử dụng
thư viện để cung cấp chức năng chế độ điểm cuối.

API EPF cho Trình điều khiển chức năng điểm cuối PCI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phần này liệt kê các API mà lõi Điểm cuối PCI cung cấp để sử dụng
bởi trình điều khiển chức năng điểm cuối PCI.

* pci_epf_register_driver()

Trình điều khiển Chức năng điểm cuối PCI phải triển khai các hoạt động sau:
	 * liên kết: hoạt động để thực hiện khi thiết bị EPC đã được liên kết với thiết bị EPF
	 * hủy liên kết: hoạt động để thực hiện khi mất liên kết giữa EPC
	   thiết bị và thiết bị EPF
	 * add_cfs: các hoạt động tùy chọn để tạo các cấu hình cụ thể cho chức năng
	   thuộc tính

Sau đó, trình điều khiển Chức năng PCI có thể đăng ký trình điều khiển PCI EPF bằng cách sử dụng
  pci_epf_register_driver().

* pci_epf_unregister_driver()

Trình điều khiển chức năng PCI có thể hủy đăng ký trình điều khiển PCI EPF bằng cách sử dụng
  pci_epf_unregister_driver().

* pci_epf_alloc_space()

Trình điều khiển chức năng PCI có thể phân bổ không gian cho một BAR cụ thể bằng cách sử dụng
  pci_epf_alloc_space().

* pci_epf_free_space()

Trình điều khiển chức năng PCI có thể giải phóng không gian được phân bổ
  (sử dụng pci_epf_alloc_space) bằng cách gọi pci_epf_free_space().

API cho Thư viện bộ điều khiển điểm cuối PCI
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phần này liệt kê các API mà lõi Điểm cuối PCI cung cấp để sử dụng
bởi thư viện bộ điều khiển điểm cuối PCI.

* pci_epf_linkup()

Thư viện bộ điều khiển điểm cuối PCI gọi pci_epf_linkup() khi
   Thiết bị EPC đã thiết lập kết nối với máy chủ.

Các API EPF khác
~~~~~~~~~~~~~~~~

Có các API khác được cung cấp bởi thư viện EPF. Chúng được sử dụng để thông báo
trình điều khiển chức năng khi thiết bị EPF được liên kết với thiết bị EPC.
pci-ep-cfs.c có thể được sử dụng làm tài liệu tham khảo cho việc sử dụng các API này.

* pci_epf_create()

Tạo một thiết bị PCI EPF mới bằng cách chuyển tên của thiết bị PCI EPF.
   Tên này sẽ được sử dụng để liên kết thiết bị EPF với trình điều khiển EPF.

* pci_epf_destroy()

Phá hủy thiết bị PCI EPF đã tạo.

* pci_epf_bind()

pci_epf_bind() nên được gọi khi thiết bị EPF được liên kết với
   một thiết bị EPC.

* pci_epf_unbind()

pci_epf_unbind() nên được gọi khi liên kết giữa thiết bị EPC
   và thiết bị EPF bị mất.