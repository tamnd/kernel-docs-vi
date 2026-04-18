.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/pci-endpoint-test.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Trình điều khiển cho chức năng kiểm tra điểm cuối PCI
=====================================

Trình điều khiển này nên được sử dụng làm trình điều khiển phía máy chủ nếu phức hợp gốc
được kết nối với điểm cuối PCI có thể định cấu hình đang chạy chức năng ZZ0000ZZ
trình điều khiển được định cấu hình theo [1]_.

Trình điều khiển "pci_endpoint_test" có thể được sử dụng để thực hiện các kiểm tra sau.

Trình điều khiển PCI cho thiết bị thử nghiệm thực hiện các thử nghiệm sau:

#) xác minh địa chỉ được lập trình trong BAR
	#) nâng cao di sản IRQ
	#) nâng MSI IRQ
	#) nâng MSI-X IRQ
	#) đọc dữ liệu
	#) ghi dữ liệu
	#) sao chép dữ liệu

Trình điều khiển linh tinh này tạo /dev/pci-endpoint-test.<num> cho mọi
Hàm ZZ0000ZZ được kết nối với tổ hợp gốc và "ioctls"
nên được sử dụng để thực hiện các bài kiểm tra trên.

ioctl
-----

PCITEST_BAR:
	      Kiểm tra BAR. Số lượng BAR được kiểm tra
	      nên được thông qua làm đối số.
 PCITEST_LEGACY_IRQ:
	      Kiểm tra di sản IRQ
 PCITEST_MSI:
	      Kiểm tra thông báo báo hiệu ngắt. Số MSI
	      được kiểm tra phải được thông qua dưới dạng đối số.
 PCITEST_MSIX:
	      Kiểm tra thông báo báo hiệu ngắt. Số MSI-X
	      được kiểm tra phải được thông qua dưới dạng đối số.
 PCITEST_SET_IRQTYPE:
	      Thay đổi cấu hình loại trình điều khiển IRQ. Loại IRQ
	      phải được chuyển làm đối số (0: Legacy, 1:MSI, 2:MSI-X).
 PCITEST_GET_IRQTYPE:
	      Nhận cấu hình loại trình điều khiển IRQ.
 PCITEST_WRITE:
	      Thực hiện các bài kiểm tra viết. Kích thước của bộ đệm phải được thông qua
	      như lý lẽ.
 PCITEST_READ:
	      Thực hiện các bài kiểm tra đọc. Kích thước của bộ đệm phải được thông qua
	      như lý lẽ.
 PCITEST_COPY:
	      Thực hiện các bài kiểm tra đọc. Kích thước của bộ đệm phải được thông qua
	      như lý lẽ.

.. [1] Documentation/PCI/endpoint/function/binding/pci-test.rst