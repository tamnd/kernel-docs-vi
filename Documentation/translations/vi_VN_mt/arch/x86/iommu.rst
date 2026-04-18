.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/iommu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Hỗ trợ x86 IOMMU
=================

Thông số kỹ thuật kiến ​​trúc có thể được lấy từ các trang web của nhà cung cấp.
Tìm kiếm các tài liệu sau để có được phiên bản mới nhất:

- Intel: Công nghệ ảo hóa Intel dành cho đặc tả kiến trúc I/O được định hướng (ID: D51397)
- AMD: Thông số kỹ thuật công nghệ ảo hóa I/O AMD (IOMMU) (ID: 48882)

Hướng dẫn này cung cấp bảng tóm tắt nhanh để bạn hiểu cơ bản.

Nội dung cơ bản
-----------

ACPI liệt kê và liệt kê các IOMMU khác nhau trên nền tảng và
mối quan hệ phạm vi thiết bị giữa các thiết bị và IOMMU điều khiển
họ.

Một số từ khóa ACPI:

- DMAR - Bảng ánh xạ lại Intel DMA
- DRHD - Định nghĩa đơn vị phần cứng ánh xạ lại Intel DMA
- RMRR - Cấu trúc báo cáo vùng bộ nhớ dự trữ của Intel
- IVRS - Cấu trúc báo cáo ảo hóa I/O AMD
- IVDB - Khối định nghĩa ảo hóa I/O AMD
- IVHD - Định nghĩa phần cứng ảo hóa I/O AMD

Intel RMRR là gì?
^^^^^^^^^^^^^^^^^^^

Có một số thiết bị BIOS điều khiển, ví dụ: thiết bị USB để thực hiện
Mô phỏng PS2. Các vùng bộ nhớ được sử dụng cho các thiết bị này được đánh dấu
dành riêng trong bản đồ e820. Khi chúng ta bật dịch DMA, DMA sang những
khu vực sẽ thất bại. Do đó BIOS sử dụng RMRR để chỉ định các vùng này cùng với
các thiết bị cần truy cập vào các khu vực này. Hệ điều hành dự kiến sẽ được thiết lập
ánh xạ thống nhất cho các vùng này để các thiết bị này truy cập vào các vùng này.

AMD IVRS là gì?
^^^^^^^^^^^^^^^^^

Kiến trúc xác định cấu trúc dữ liệu tương thích ACPI được gọi là I/O
Cấu trúc báo cáo ảo hóa (IVRS) được sử dụng để truyền tải thông tin
liên quan đến ảo hóa I/O cho phần mềm hệ thống.  IVRS mô tả
cấu hình và khả năng của IOMMU có trong nền tảng như
cũng như thông tin về các thiết bị mà mỗi IOMMU ảo hóa.

IVRS cung cấp thông tin về những điều sau:

- IOMMU có mặt trong nền tảng bao gồm khả năng và cấu hình phù hợp của chúng
- Cấu trúc liên kết I/O hệ thống phù hợp với từng IOMMU
- Các thiết bị ngoại vi không thể liệt kê được
- Vùng bộ nhớ được sử dụng bởi SMI/SMM, chương trình cơ sở nền tảng và phần cứng nền tảng. Đây thường là các phạm vi loại trừ được cấu hình bằng phần mềm hệ thống.

Địa chỉ ảo I/O (IOVA) được tạo như thế nào?
-----------------------------------------------

Trình điều khiển hoạt động tốt sẽ gọi các cuộc gọi dma_map_*() trước khi gửi lệnh tới thiết bị
cần thực hiện DMA. Khi DMA được hoàn thành và việc ánh xạ không còn nữa
được yêu cầu, trình điều khiển sẽ thực hiện lệnh gọi dma_unmap_*() để hủy ánh xạ khu vực.

Ghi chú cụ thể của Intel
--------------------

Vấn đề về đồ họa?
^^^^^^^^^^^^^^^^^^

Nếu bạn gặp sự cố với thiết bị đồ họa, bạn có thể thử thêm
tùy chọn intel_iommu=igfx_off để tắt công cụ đồ họa tích hợp.
Nếu điều này khắc phục được bất kỳ điều gì, vui lòng đảm bảo bạn gửi báo cáo lỗi cho sự cố.

Một số trường hợp ngoại lệ đối với IOVA
^^^^^^^^^^^^^^^^^^^^^^^

Phạm vi ngắt không được dịch địa chỉ, (0xfee00000 - 0xfeefffff).
Điều này cũng đúng với các giao dịch ngang hàng. Do đó chúng tôi bảo lưu
địa chỉ từ phạm vi PCI MMIO để chúng không được phân bổ cho các địa chỉ IOVA.

Ghi chú cụ thể của AMD
------------------

Vấn đề về đồ họa?
^^^^^^^^^^^^^^^^^^

Nếu bạn gặp sự cố với các thiết bị đồ họa tích hợp, bạn có thể thử thêm
tùy chọn iommu=pt vào dòng lệnh kernel sử dụng ánh xạ 1:1 cho IOMMU.  Nếu
điều này sẽ khắc phục mọi sự cố, vui lòng đảm bảo bạn gửi báo cáo lỗi cho sự cố.

Báo cáo lỗi
---------------
Khi có lỗi được báo cáo, IOMMU sẽ phát tín hiệu thông qua ngắt. Lỗi
lý do và thiết bị gây ra nó được in trên bảng điều khiển.


Mẫu nhật ký hạt nhân
------------------

Thông báo khởi động Intel
^^^^^^^^^^^^^^^^^^^

Một cái gì đó như thế này được in ra cho biết sự hiện diện của các bảng DMAR
trong ACPI:

::

ACPI: DMAR (v001 A M I ​​OEMDMAR 0x00000001 MSFT 0x00000097) @ 0x000000007f5b5ef0

Khi DMAR đang được ACPI xử lý và khởi tạo, hãy in các vị trí DMAR
và bất kỳ RMRR nào được xử lý:

::

ACPI DMAR: Chiều rộng địa chỉ máy chủ 36
	ACPI DMAR:DRHD (cờ: 0x00000000)cơ sở: 0x00000000fed90000
	ACPI DMAR:DRHD (cờ: 0x00000000)cơ sở: 0x00000000fed91000
	ACPI DMAR:DRHD (cờ: 0x00000001)cơ sở: 0x00000000fed93000
	ACPI DMAR:RMRR cơ sở: 0x00000000000ed000 kết thúc: 0x00000000000effff
	ACPI DMAR:RMRR cơ sở: 0x000000007f600000 kết thúc: 0x000000007fffffff

Khi DMAR được kích hoạt để sử dụng, bạn sẽ nhận thấy:

::

PCI-DMA: Sử dụng DMAR IOMMU

Báo cáo lỗi Intel
^^^^^^^^^^^^^^^^^^^^^

::

DMAR:[DMA Write] Yêu cầu thiết bị [00:02.0] lỗi addr 6df084000
	DMAR:[lý do lỗi 05] PTE Quyền truy cập ghi chưa được thiết lập
	DMAR:[DMA Write] Yêu cầu thiết bị [00:02.0] lỗi addr 6df084000
	DMAR:[lý do lỗi 05] PTE Quyền truy cập ghi chưa được thiết lập

Thông báo khởi động AMD
^^^^^^^^^^^^^^^^^

Một cái gì đó như thế này được in ra cho biết sự hiện diện của IOMMU:

::

iommu: Loại tên miền mặc định: Đã dịch
	iommu: Chính sách vô hiệu hóa tên miền DMA TLB: chế độ lười biếng

Báo cáo lỗi AMD
^^^^^^^^^^^^^^^^^^^

::

AMD-Vi: Đã ghi sự kiện [Miền IO_PAGE_FAULT=0x0007 địa chỉ=0xffffc02000 flags=0x0000]
	AMD-Vi: Đã ghi sự kiện [Thiết bị IO_PAGE_FAULT=07:00.0 miền=0x0007 địa chỉ=0xffffc02000 flags=0x0000]
