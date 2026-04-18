.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/debugging-via-ohci1394.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================================================
Sử dụng DMA vật lý được cung cấp bởi bộ điều khiển FireWire OHCI-1394 để gỡ lỗi
===========================================================================

Giới thiệu
------------

Về cơ bản tất cả các bộ điều khiển FireWire đang được sử dụng ngày nay đều tuân thủ
theo thông số kỹ thuật OHCI-1394 xác định bộ điều khiển là PCI
bus master sử dụng DMA để giảm tải việc truyền dữ liệu từ CPU và có
một "Đơn vị phản hồi vật lý" thực hiện các yêu cầu cụ thể bằng cách sử dụng
PCI-Bus master DMA sau khi áp dụng các bộ lọc được xác định bởi trình điều khiển OHCI-1394.

Sau khi được cấu hình đúng cách, các máy từ xa có thể gửi các yêu cầu này tới
yêu cầu bộ điều khiển OHCI-1394 thực hiện các yêu cầu đọc và ghi trên
bộ nhớ hệ thống vật lý và, đối với các yêu cầu đọc, hãy gửi kết quả của
bộ nhớ vật lý đọc lại cho người yêu cầu.

Cùng với đó, có thể gỡ lỗi các vấn đề bằng cách đọc bộ nhớ thú vị
các vị trí như bộ đệm như bộ đệm printk hoặc bảng quy trình.

Cũng có thể truy xuất kết xuất bộ nhớ hệ thống đầy đủ qua FireWire,
sử dụng tốc độ truyền dữ liệu ở mức 10MB/s trở lên.

Với hầu hết các bộ điều khiển FireWire, quyền truy cập bộ nhớ bị giới hạn ở mức thấp 4 GB
của không gian địa chỉ vật lý.  Đây có thể là sự cố trên các máy có bộ nhớ
hầu hết nằm ở trên giới hạn đó, nhưng hiếm khi xảy ra sự cố trên các thiết bị phổ biến hơn.
phần cứng như x86, x86-64 và PowerPC.

Ít nhất bộ điều khiển LSI FW643e và FW643e2 được biết là hỗ trợ truy cập vào
địa chỉ vật lý trên 4 GB, nhưng tính năng này hiện không được kích hoạt bởi
Linux.

Cùng với việc khởi tạo sớm bộ điều khiển OHCI-1394 để gỡ lỗi,
cơ sở này tỏ ra hữu ích nhất cho việc kiểm tra nhật ký gỡ lỗi dài trong printk
đệm để gỡ lỗi các sự cố khởi động sớm trong các khu vực như ACPI nơi hệ thống
không khởi động được và các phương tiện khác để gỡ lỗi (cổng nối tiếp) cũng không
có sẵn (sổ tay) hoặc quá chậm đối với thông tin gỡ lỗi mở rộng (như ACPI).

Trình điều khiển
-------

Trình điều khiển firewire-ohci trong trình điều khiển/firewire sử dụng vật lý được lọc
DMA theo mặc định, an toàn hơn nhưng không phù hợp để gỡ lỗi từ xa.
Truyền tham số remote_dma=1 cho trình điều khiển để nhận DMA vật lý chưa được lọc.

Bởi vì trình điều khiển firewire-ohci phụ thuộc vào bảng liệt kê PCI để
đã hoàn thành, một quy trình khởi tạo chạy khá sớm đã được
được triển khai cho x86.  Quy trình này chạy rất lâu trước khi console_init() có thể
được gọi, tức là trước khi bộ đệm printk xuất hiện trên bảng điều khiển.

Để kích hoạt nó, hãy bật CONFIG_PROVIDE_OHCI1394_DMA_INIT (Menu hack kernel:
Gỡ lỗi từ xa qua FireWire sớm khi khởi động) và truyền tham số
"ohci1394_dma=early" vào kernel được biên dịch lại khi khởi động.

Công cụ
-----

firescope - Được phát triển ban đầu bởi Benjamin Herrenschmidt, Andi Kleen đã port
từ PowerPC đến x86 và x86_64 và chức năng được thêm vào, firescope giờ đây có thể
được sử dụng để xem bộ đệm printk của máy từ xa, ngay cả khi cập nhật trực tiếp.

Bernhard Kaindl tăng cường firescope để hỗ trợ truy cập máy 64-bit
từ kính ngắm 32 bit và ngược lại:
-ZZ0000ZZ

và anh ấy đã triển khai kết xuất hệ thống nhanh (phiên bản alpha - đọc README.txt):
-ZZ0000ZZ

Ngoài ra còn có proxy gdb cho firewire cho phép sử dụng gdb để truy cập
dữ liệu có thể được tham chiếu từ các ký hiệu được tìm thấy bởi gdb trong vmlinux:
-ZZ0000ZZ

Phiên bản mới nhất của proxy gdb này (fireproxy-0.34) có thể giao tiếp (không phải
chưa ổn định) với kgdb qua mô-đun giao tiếp dựa trên bộ nhớ (kgdbom).

Bắt đầu
---------------

Thông số kỹ thuật OHCI-1394 quy định rằng bộ điều khiển OHCI-1394 phải
vô hiệu hóa tất cả DMA vật lý trên mỗi lần đặt lại bus.

Điều này có nghĩa là nếu bạn muốn gỡ lỗi một sự cố ở trạng thái hệ thống
các ngắt bị vô hiệu hóa và không có sự thăm dò của bộ điều khiển OHCI-1394
để việc đặt lại xe buýt diễn ra, bạn phải thiết lập bất kỳ cáp FireWire nào
kết nối và khởi tạo đầy đủ tất cả phần cứng FireWire __trước__
hệ thống đi vào trạng thái như vậy.

Hướng dẫn từng bước để sử dụng firescope khi khởi tạo OHCI sớm:

1) Xác minh rằng phần cứng của bạn được hỗ trợ:

Tải mô-đun firewire-ohci và kiểm tra nhật ký kernel của bạn.
   Bạn sẽ thấy một dòng tương tự như::

firewire_ohci 0000:15:00.1: đã thêm thiết bị OHCI v1.0 dưới dạng card 2, 4 IR + 4 IT
     ... contexts, quirks 0x11

khi tải driver. Nếu bạn không có bộ điều khiển được hỗ trợ, nhiều PCI,
   CardBus và thậm chí một số thẻ Express hoàn toàn tuân thủ OHCI-1394
   đặc điểm kỹ thuật có sẵn. Nếu nó không yêu cầu trình điều khiển cho hệ điều hành Windows
   hệ thống, rất có thể là như vậy. Chỉ những cửa hàng chuyên doanh mới có thẻ không có
   tuân thủ, chúng dựa trên chip TI PCILynx và yêu cầu trình điều khiển cho Windows
   các hệ điều hành.

Thông báo nhật ký kernel được đề cập có chứa chuỗi "physUB" nếu
   bộ điều khiển thực hiện một thanh ghi Giới hạn trên vật lý có thể ghi được.  Đây là
   cần thiết cho DMA vật lý trên 4 GB (nhưng chưa được Linux sử dụng).

2) Thiết lập kết nối cáp FireWire đang hoạt động:

Bất kỳ cáp FireWire nào, miễn là nó cung cấp điện và cơ khí
   kết nối ổn định và có đầu nối phù hợp (có loại 4 chân nhỏ và
   cổng FireWire lớn 6 chân) sẽ làm được.

Nếu trình điều khiển đang chạy trên cả hai máy, bạn sẽ thấy một dòng như::

firewire_core 0000:15:00.1: thiết bị đã tạo fw1: GUID 00061b0020105917, S400

trên cả hai máy trong nhật ký kernel khi cắm cáp
   và kết nối hai máy.

3) Kiểm tra DMA vật lý bằng firescope:

Trên máy chủ gỡ lỗi, hãy đảm bảo rằng /dev/fw* có thể truy cập được,
   sau đó bắt đầu firescope::

$ kính lửa
	Cổng 0 (/dev/fw1) đã mở, phát hiện 2 nút

phạm vi lửa
	---------
	Mục tiêu: <không xác định>
	Thế hệ: 1
	[Ctrl-T] chọn mục tiêu
	[Ctrl-H] menu này
	[Ctrl-Q] thoát

------> Nhấn Ctrl-T ngay bây giờ, đầu ra sẽ tương tự như:

Có sẵn 2 nút, nút cục bộ là: 0
	 0: ffc0, uuid: 00000000 00000000 [LOCAL]
	 1: ffc1, uuid: 00279000 ba4bb801

Ngoài nút [LOCAL], nó phải hiển thị một nút khác không có thông báo lỗi.

4) Chuẩn bị gỡ lỗi với quá trình khởi tạo OHCI-1394 sớm:

4.1) Biên dịch và cài đặt hạt nhân trên mục tiêu gỡ lỗi

Biên dịch kernel để gỡ lỗi với CONFIG_PROVIDE_OHCI1394_DMA_INIT
   (Kernel hack: Cung cấp mã để kích hoạt DMA qua FireWire sớm khi khởi động)
   kích hoạt và cài đặt nó trên máy cần gỡ lỗi (mục tiêu gỡ lỗi).

4.2) Chuyển System.map của kernel đã được gỡ lỗi sang máy chủ gỡ lỗi

Sao chép System.map của hạt nhân được gỡ lỗi vào máy chủ gỡ lỗi (máy chủ
   được kết nối với máy đã được gỡ lỗi qua cáp FireWire).

5) Truy xuất nội dung bộ đệm printk:

Với cáp FireWire được kết nối, trình điều khiển OHCI-1394 đang gỡ lỗi
   máy chủ đã được tải, khởi động lại máy đã được sửa lỗi, khởi động kernel có
   Đã bật CONFIG_PROVIDE_OHCI1394_DMA_INIT với tùy chọn ohci1394_dma=early.

Sau đó, trên máy chủ gỡ lỗi, hãy chạy firescope, chẳng hạn bằng cách sử dụng -A::

firescope -A System.map-of-debug-target-kernel

Lưu ý: -A tự động gắn vào nút không cục bộ đầu tiên. Nó chỉ hoạt động
   đáng tin cậy nếu chỉ có hai máy được kết nối bằng FireWire.

Sau khi gắn vào mục tiêu gỡ lỗi, nhấn Ctrl-D để xem
   hoàn thành bộ đệm printk hoặc Ctrl-U để vào chế độ cập nhật tự động và nhận
   cập nhật chế độ xem trực tiếp của các thông báo kernel gần đây được ghi vào mục tiêu gỡ lỗi.

Gọi "firescope -h" để biết thêm thông tin về các tùy chọn của firescope.

Ghi chú
-----

Tài liệu và thông số kỹ thuật: ZZ0000ZZ

FireWire là nhãn hiệu của Apple Inc. - để biết thêm thông tin, vui lòng tham khảo:
ZZ0000ZZ
