.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/driver-model/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Mô hình thiết bị hạt nhân Linux
================================

Patrick Mochel <mochel@digitalimplant.org>

Soạn thảo ngày 26 tháng 8 năm 2002
Cập nhật ngày 31 tháng 1 năm 2006


Tổng quan
~~~~~~~~~

Mô hình trình điều khiển hạt nhân Linux là sự hợp nhất của tất cả các trình điều khiển khác nhau
các mô hình đã được sử dụng trước đó trong kernel. Nó nhằm mục đích tăng cường
trình điều khiển dành riêng cho xe buýt cho cầu và thiết bị bằng cách hợp nhất một bộ dữ liệu
và hoạt động vào các cấu trúc dữ liệu có thể truy cập được trên toàn cầu.

Các mô hình trình điều khiển truyền thống triển khai một số loại cấu trúc giống như cây
(đôi khi chỉ là một danh sách) cho các thiết bị mà họ điều khiển. không có bất kỳ
tính đồng nhất trên các loại xe buýt khác nhau.

Mô hình trình điều khiển hiện tại cung cấp một mô hình dữ liệu thống nhất, chung để mô tả
xe buýt và các thiết bị có thể xuất hiện bên dưới xe buýt. Xe buýt thống nhất
mô hình bao gồm một tập hợp các thuộc tính chung mà tất cả các xe buýt mang theo và một tập hợp
các cuộc gọi lại phổ biến, chẳng hạn như phát hiện thiết bị trong quá trình thăm dò xe buýt, xe buýt
tắt máy, quản lý nguồn điện xe buýt, v.v.

Giao diện thiết bị và cầu nối chung phản ánh mục tiêu của hệ thống hiện đại
máy tính: cụ thể là khả năng thực hiện liền mạch thiết bị "cắm và chạy", cấp nguồn
quản lý và cắm nóng. Đặc biệt, mô hình do Intel và
Microsoft (cụ thể là ACPI) đảm bảo rằng hầu hết mọi thiết bị trên hầu hết mọi xe buýt
trên hệ thống tương thích x86 có thể hoạt động trong mô hình này.  Tất nhiên,
không phải mọi xe buýt đều có thể hỗ trợ tất cả các hoạt động đó, mặc dù hầu hết
xe buýt hỗ trợ hầu hết các hoạt động đó.


Truy cập xuôi dòng
~~~~~~~~~~~~~~~~~~

Các trường dữ liệu chung đã được chuyển từ các lớp bus riêng lẻ sang một trường dữ liệu chung
cấu trúc dữ liệu. Các trường này vẫn phải được truy cập bởi các lớp bus,
và đôi khi bởi các trình điều khiển dành riêng cho thiết bị.

Các lớp bus khác được khuyến khích thực hiện những gì đã được thực hiện cho lớp PCI.
struct pci_dev bây giờ trông như thế này::

cấu trúc pci_dev {
	...

nhà phát triển thiết bị cấu trúc;     /*Giao diện thiết bị chung */
	...
  };

Trước tiên hãy lưu ý rằng struct device dev trong struct pci_dev là
được phân bổ tĩnh. Điều này có nghĩa là chỉ có một lần phân bổ khi khám phá thiết bị.

Cũng lưu ý rằng nhà phát triển thiết bị cấu trúc đó không nhất thiết phải được xác định tại
phía trước cấu trúc pci_dev.  Điều này khiến mọi người phải suy nghĩ về những gì
họ đang làm gì khi chuyển đổi giữa tài xế xe buýt và tài xế toàn cầu,
và để ngăn cản việc diễn xuất vô nghĩa và không chính xác giữa hai người.

Lớp bus PCI truy cập tự do vào các trường của thiết bị cấu trúc. Nó biết về
cấu trúc của struct pci_dev và nó phải biết cấu trúc của struct
thiết bị. Trình điều khiển thiết bị PCI riêng lẻ đã được chuyển đổi sang phiên bản hiện tại
mô hình trình điều khiển nói chung không và không nên chạm vào các trường của thiết bị cấu trúc,
trừ khi có lý do thuyết phục để làm như vậy.

Sự trừu tượng ở trên ngăn ngừa những đau đớn không cần thiết trong các giai đoạn chuyển tiếp.
Nếu nó không được thực hiện theo cách này thì khi một trường được đổi tên hoặc xóa, mọi
trình điều khiển xuôi dòng sẽ bị hỏng.  Mặt khác, nếu chỉ có lớp xe buýt
(và không phải lớp thiết bị) truy cập vào thiết bị cấu trúc, nó chỉ là bus
lớp cần thay đổi.


Giao diện người dùng
~~~~~~~~~~~~~~~~~~~~

Nhờ có cái nhìn phân cấp đầy đủ về tất cả các thiết bị trong
hệ thống, việc xuất một chế độ xem phân cấp hoàn chỉnh sang không gian người dùng trở nên tương đối
dễ dàng. Điều này đã được thực hiện bằng cách thực hiện một mục đích ảo ảo đặc biệt.
hệ thống tập tin có tên sysfs.

Hầu như tất cả các bản phân phối Linux chính thống đều tự động gắn hệ thống tệp này; bạn
có thể thấy một số biến thể sau trong đầu ra của lệnh "mount" ::

gắn kết $
  ...
không có trên /sys loại sysfs (rw,noexec,nosuid,nodev)
  ...
  $

Việc tự động gắn sysfs thường được thực hiện bằng một mục tương tự như
phần sau trong tệp /etc/fstab::

không có /sys sysfs mặc định 0 0

hoặc nội dung tương tự trong tệp /lib/init/fstab trên hệ thống dựa trên Debian::

không /sys sysfs nodev,noexec,nosuid 0 0

Nếu sysfs không được gắn tự động, bạn luôn có thể thực hiện thủ công với ::

# mount -t sysfs sysfs /sys

Bất cứ khi nào một thiết bị được đưa vào cây, một thư mục sẽ được tạo cho nó.
Thư mục này có thể được điền ở mỗi lớp khám phá - lớp toàn cầu,
lớp bus hoặc lớp thiết bị.

Lớp chung hiện đang tạo hai tệp - 'name' và 'power'. các
trước đây chỉ báo cáo tên của thiết bị. Sau này báo cáo
trạng thái nguồn hiện tại của thiết bị. Nó cũng sẽ được sử dụng để thiết lập dòng điện
trạng thái quyền lực.

Lớp bus cũng có thể tạo các tập tin cho các thiết bị mà nó tìm thấy trong khi thăm dò
xe buýt. Ví dụ: lớp PCI hiện tạo các tệp 'irq' và 'resource'
cho mỗi thiết bị PCI.

Trình điều khiển dành riêng cho thiết bị cũng có thể xuất các tệp trong thư mục của nó để hiển thị
dữ liệu dành riêng cho thiết bị hoặc giao diện có thể điều chỉnh.

Thông tin thêm về cách bố trí thư mục sysfs có thể được tìm thấy trong
các tài liệu khác trong thư mục này và trong tập tin
Tài liệu/hệ thống tập tin/sysfs.rst.
