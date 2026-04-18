.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/PCI/endpoint/pci-test-function.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Chức năng kiểm tra PCI
=================

:Tác giả: Kishon Vijay Abraham I <kishon@ti.com>

Theo truyền thống PCI RC luôn được xác nhận bằng cách sử dụng tiêu chuẩn
Thẻ PCI như thẻ ethernet PCI hoặc thẻ USB PCI hoặc thẻ SATA PCI.
Tuy nhiên, với việc bổ sung EP-core trong kernel linux, có thể
để định cấu hình bộ điều khiển PCI có thể hoạt động ở chế độ EP để hoạt động như
một thiết bị thử nghiệm

Thiết bị kiểm tra điểm cuối PCI là thiết bị ảo (được xác định trong phần mềm)
được sử dụng để kiểm tra chức năng điểm cuối và đóng vai trò là trình điều khiển mẫu
cho các thiết bị đầu cuối PCI khác (để sử dụng khung EP).

Thiết bị kiểm tra điểm cuối PCI có các thanh ghi sau:

1) PCI_ENDPOINT_TEST_MAGIC
	2) PCI_ENDPOINT_TEST_COMMAND
	3) PCI_ENDPOINT_TEST_STATUS
	4) PCI_ENDPOINT_TEST_SRC_ADDR
	5) PCI_ENDPOINT_TEST_DST_ADDR
	6) PCI_ENDPOINT_TEST_SIZE
	7) PCI_ENDPOINT_TEST_CHECKSUM
	8) PCI_ENDPOINT_TEST_IRQ_TYPE
	9) PCI_ENDPOINT_TEST_IRQ_NUMBER

* PCI_ENDPOINT_TEST_MAGIC

Thanh ghi này sẽ được sử dụng để kiểm tra BAR0. Một mẫu đã biết sẽ được viết
và đọc lại từ thanh ghi MAGIC để xác minh BAR0.

* PCI_ENDPOINT_TEST_COMMAND

Thanh ghi này sẽ được trình điều khiển máy chủ sử dụng để chỉ ra chức năng
mà thiết bị đầu cuối phải thực hiện.

==============================================================================
Mô tả trường bit
==============================================================================
Bit 0 nâng cao IRQ kế thừa
Bit 1 tăng MSI IRQ
Bit 2 tăng MSI-X IRQ
Lệnh đọc bit 3 (đọc dữ liệu từ bộ đệm RC)
Lệnh ghi bit 4 (ghi dữ liệu vào bộ đệm RC)
Lệnh sao chép bit 5 (sao chép dữ liệu từ bộ đệm RC này sang bộ đệm RC khác)
==============================================================================

* PCI_ENDPOINT_TEST_STATUS

Thanh ghi này phản ánh trạng thái của thiết bị đầu cuối PCI.

=========================================
Mô tả trường bit
=========================================
Bit 0 đọc thành công
Đọc bit 1 không thành công
Bit 2 ghi thành công
Ghi bit 3 không thành công
Sao chép bit 4 thành công
Sao chép bit 5 không thành công
Bit 6 IRQ tăng lên
Địa chỉ nguồn bit 7 không hợp lệ
Địa chỉ đích bit 8 không hợp lệ
=========================================

* PCI_ENDPOINT_TEST_SRC_ADDR

Thanh ghi này chứa địa chỉ nguồn (địa chỉ bộ đệm RC) cho
Lệnh COPY/READ.

* PCI_ENDPOINT_TEST_DST_ADDR

Thanh ghi này chứa địa chỉ đích (địa chỉ bộ đệm RC) cho
lệnh COPY/WRITE.

* PCI_ENDPOINT_TEST_IRQ_TYPE

Thanh ghi này chứa loại ngắt (Legacy/MSI) được kích hoạt
cho các lệnh READ/WRITE/COPY và nâng cao các lệnh IRQ (Legacy/MSI).

Các loại có thể:

====== ==
Di sản 0
MSI 1
MSI-X 2
====== ==

* PCI_ENDPOINT_TEST_IRQ_NUMBER

Thanh ghi này chứa ngắt ID được kích hoạt.

Giá trị được chấp nhận:

====== ============
Di sản 0
MSI [1 .. 32]
MSI-X [1 .. 2048]
====== ============