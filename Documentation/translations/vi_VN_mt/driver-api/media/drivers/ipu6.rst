.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/ipu6.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Trình điều khiển Intel IPU6
==================

Tác giả: Bingbu Cao <bingbu.cao@intel.com>

Tổng quan
=========

Intel IPU6 là bộ xử lý hình ảnh Intel thế hệ thứ sáu được sử dụng trong một số
Các chipset Intel như Tiger Lake, Jasper Lake, Alder Lake, Raptor Lake và
Hồ sao băng. IPU6 bao gồm hai hệ thống chính: Hệ thống đầu vào (ISYS) và
Hệ thống xử lý (PSYS). IPU6 hiển thị trên bus PCI dưới dạng một thiết bị duy nhất, nó
có thể được tìm thấy bởi ZZ0000ZZ:

ZZ0000ZZ

IPU6 có BAR 16 MB trong Không gian cấu hình PCI dành cho các thanh ghi MMIO.
có thể nhìn thấy cho người lái xe.

trụ đỡ
=========

IPU6 đang kết nối với hệ thống bằng Buttress cho phép máy chủ
điều khiển IPU6, nó cũng cho phép IPU6 truy cập bộ nhớ hệ thống để
lưu trữ và tải các luồng pixel khung hình và bất kỳ siêu dữ liệu nào khác.

Buttress chủ yếu quản lý một số chức năng của hệ thống: quản lý năng lượng,
xử lý ngắt, xác thực chương trình cơ sở và đồng bộ hóa bộ đếm thời gian toàn cầu.

Dòng điện ISYS và PSYS
------------------------

Trình điều khiển IPU6 khởi tạo yêu cầu tăng hoặc giảm nguồn ISYS và PSYS bằng cách cài đặt
Thanh ghi điều khiển tần số trụ cho ISYS và PSYS
(ZZ0000ZZ và ZZ0001ZZ) trong
chức năng:

.. c:function:: int ipu6_buttress_power(...)

Buttress chuyển tiếp yêu cầu tới Punit, sau khi Punit thực hiện luồng tăng sức mạnh,
Buttress cho biết trình điều khiển rằng ISYS hoặc PSYS được cấp nguồn bằng cách cập nhật nguồn
các thanh ghi trạng thái.

.. Note:: ISYS power up needs take place prior to PSYS power up, ISYS power down
	  needs take place after PSYS power down due to hardware limitation.

Ngắt
---------

Ngắt IPU6 có thể được tạo dưới dạng MSI hoặc INTA, ngắt sẽ được kích hoạt khi
ISYS, PSYS, Sự kiện hoặc lỗi ở trụ đỡ xảy ra, trình điều khiển có thể nhận được nguyên nhân gây gián đoạn
bằng cách đọc thanh ghi trạng thái ngắt ZZ0000ZZ, trình điều khiển
xóa trạng thái irq và sau đó gọi trình xử lý irq ISYS hoặc PSYS cụ thể.

.. c:function:: irqreturn_t ipu6_buttress_isr(int irq, ...)

Xác thực bảo mật và phần sụn
-------------------------------------

Để giải quyết các mối lo ngại về bảo mật của phần sụn IPU6, phần sụn IPU6 cần phải
trải qua quá trình xác thực trước khi được phép thực thi trên IPU6
bộ xử lý bên trong. Trình điều khiển IPU6 sẽ hoạt động với Công cụ bảo mật hội tụ
(CSE) để hoàn tất quá trình xác thực. CSE chịu trách nhiệm
xác thực phần sụn IPU6. Tệp nhị phân phần sụn đã xác thực được sao chép
vào một vùng nhớ bị cô lập. Quá trình xác thực firmware được thực hiện
bởi CSE sau khi bắt tay IPC với trình điều khiển IPU6. Có một số trụ
các thanh ghi được sử dụng bởi CSE và trình điều khiển IPU6 để liên lạc với nhau thông qua
IPC.

.. c:function:: int ipu6_buttress_authenticate(...)

Đồng bộ hẹn giờ toàn cầu
-----------------

Trình điều khiển IPU6 khởi tạo luồng đồng bộ hóa Cảng Hammock mỗi lần nó
bắt đầu hoạt động của máy ảnh. IPU6 sẽ đồng bộ hóa bộ đếm nội bộ trong
Hỗ trợ bản sao thời gian SoC, bộ đếm này duy trì thời gian cập nhật
cho đến khi hoạt động của máy ảnh dừng lại. Trình điều khiển IPU6 có thể sử dụng bộ đếm thời gian này để
hiệu chỉnh dấu thời gian dựa trên dấu thời gian trong sự kiện phản hồi từ phần sụn.

.. c:function:: int ipu6_buttress_start_tsc_sync(...)

DMA và MMU
============

IPU6 có bộ xử lý vô hướng riêng nơi phần sụn chạy và một bộ xử lý bên trong
Không gian địa chỉ ảo 32 bit. IPU6 có phần cứng dịch địa chỉ MMU sang
cho phép các bộ xử lý vô hướng truy cập vào bộ nhớ trong và hệ thống bên ngoài
bộ nhớ thông qua địa chỉ ảo IPU6. Việc dịch địa chỉ dựa trên hai
mức độ của bảng tra cứu trang được lưu trữ trong bộ nhớ hệ thống được duy trì bởi
Trình điều khiển IPU6. Trình điều khiển IPU6 đặt địa chỉ cơ sở bảng trang cấp 1 thành MMU
đăng ký và cho phép MMU thực hiện tra cứu bảng trang.

Trình điều khiển IPU6 xuất các hoạt động DMA của riêng nó. Trình điều khiển IPU6 sẽ cập nhật
các mục trong bảng trang cho mỗi thao tác DMA và vô hiệu hóa MMU TLB sau mỗi thao tác
hủy bản đồ và miễn phí.

Định dạng tập tin phần sụn
====================

Phần sụn IPU6 có định dạng tệp Thư mục phân vùng mã (CPD). CPD
chương trình cơ sở chứa tiêu đề CPD, một số mục và thành phần CPD. CPD
thành phần bao gồm 3 mục - bảng kê khai, siêu dữ liệu và dữ liệu mô-đun. Bản kê khai và
siêu dữ liệu được xác định bởi CSE và được CSE sử dụng để xác thực. Dữ liệu mô-đun là
dành riêng cho IPU6 chứa dữ liệu nhị phân của phần sụn được gọi là gói
thư mục. Trình điều khiển IPU6 (cụ thể là ZZ0000ZZ) phân tích và xác thực
tệp chương trình cơ sở CPD và lấy dữ liệu nhị phân thư mục gói của IPU6
phần sụn, sao chép nó vào bộ đệm DMA cụ thể và đặt địa chỉ cơ sở của nó thành Buttress
Đăng ký ZZ0001ZZ. Cuối cùng CSE sẽ thực hiện xác thực cho việc này
phần mềm nhị phân.


Giao diện hệ thống
================

Trình điều khiển IPU6 giao tiếp với phần sụn thông qua Syscom ABI. Syscom là một
cơ chế giao tiếp giữa các bộ xử lý giữa bộ xử lý vô hướng IPU và
CPU. Có một số tài nguyên được chia sẻ giữa phần sụn và phần mềm.
Vùng bộ nhớ hệ thống nơi chứa hàng đợi tin nhắn, chương trình cơ sở có thể truy cập vào
vùng bộ nhớ thông qua IPU MMU. Hàng đợi Syscom là hàng đợi có độ sâu cố định FIFO
với số lượng mã thông báo (tin nhắn) có thể định cấu hình. Ngoài ra còn có IPU6 MMIO phổ biến
các thanh ghi chứa chỉ mục đọc và ghi của hàng đợi. Phần mềm và phần cứng
đóng vai trò là nhà sản xuất và người tiêu dùng mã thông báo trong hàng đợi và cập nhật ghi
và đọc các chỉ số riêng biệt khi gửi hoặc nhận từng tin nhắn.

Trình điều khiển IPU6 phải chuẩn bị và cấu hình số lượng đầu vào và đầu ra
hàng đợi, định cấu hình số lượng mã thông báo trên mỗi hàng đợi và kích thước của mỗi mã thông báo trước
bắt đầu và bắt đầu giao tiếp với phần sụn. Phần sụn và phần mềm
phải sử dụng cấu hình tương tự. IPU6 Buttress có một số firmware boot
các thanh ghi tham số có thể được sử dụng để lưu trữ địa chỉ cấu hình và
khởi tạo trạng thái Syscom, sau đó trình điều khiển có thể yêu cầu chương trình cơ sở khởi động và chạy qua
thiết lập thanh ghi trạng thái điều khiển bộ xử lý vô hướng.

Hệ thống đầu vào
============

Hệ thống đầu vào IPU6 bao gồm MIPI D-PHY và một số máy thu CSI-2.  Nó có thể
chụp dữ liệu pixel hình ảnh từ cảm biến máy ảnh hoặc các thiết bị đầu ra MIPI CSI-2 khác.

Lập bản đồ làn đường cổng D-PHY và CSI-2
-----------------------------------

IPU6 tích hợp các IP D-PHY khác nhau trên các SoC khác nhau, trên Tiger Lake và
Hồ Alder, IPU6 tích hợp MCD10 D-PHY, IPU6SE trên Hồ Jasper tích hợp JSL
D-PHY và IPU6EP trên Hồ Sao Băng tích hợp Synopsys DWC D-PHY. có một
lớp thích ứng giữa bộ điều khiển máy thu D-PHY và CSI-2 bao gồm cổng
cấu hình, trình bao bọc PHY hoặc giao diện thử nghiệm riêng cho D-PHY. Có 3
Trình điều khiển D-PHY ZZ0000ZZ, ZZ0001ZZ và
ZZ0002ZZ lập trình 3 D-PHY trên trong IPU6.

Các phiên bản IPU6 khác nhau có ánh xạ làn đường D-PHY khác nhau, Trên hồ Tiger,
có 12 làn dữ liệu và 8 làn đồng hồ, IPU6 hỗ trợ tối đa 8 cổng CSI-2,
xem bản đồ PPI trong ZZ0000ZZ để biết thêm thông tin. Trên Jasper
Lake và Alder Lake, D-PHY có 8 làn dữ liệu và 4 làn đồng hồ, IPU6 hỗ trợ
tối đa 4 cổng CSI-2. Đối với Hồ sao băng, D-PHY có 12 làn dữ liệu và 6 đồng hồ
làn đường nên IPU6 hỗ trợ tối đa 6 cổng CSI-2.

.. Note:: Each pair of CSI-2 two ports is a single unit that can share the data
	  lanes. For example, for CSI-2 port 0 and 1, CSI-2 port 0 support
	  maximum 4 data lanes, CSI-2 port 1 support maximum 2 data lanes, CSI-2
	  port 0 with 2 data lanes can work together with CSI-2 port 1 with 2
	  data lanes. If trying to use CSI-2 port 0 with 4 lanes, CSI-2 port 1
	  will not be available as the 4 data lanes are shared by CSI-2 port 0
	  and 1. The same applies to CSI ports 2/3, 4/5 and 7/8.

ABI phần mềm ISYS
------------------

Phần sụn IPU6 triển khai một loạt ABI để truy cập phần mềm. Nói chung,
trước tiên phần mềm chuẩn bị cấu hình luồng ZZ0000ZZ và gửi cấu hình tới chương trình cơ sở thông qua
gửi lệnh ZZ0001ZZ. Cấu hình luồng bao gồm các chân đầu vào và
chân đầu ra, chân đầu vào ZZ0002ZZ xác định
độ phân giải và loại dữ liệu của nguồn đầu vào, chân đầu ra ZZ0003ZZ xác định độ phân giải đầu ra, bước tiến và
định dạng khung, v.v.

Khi trình điều khiển nhận được ngắt từ chương trình cơ sở cho biết luồng đang mở
thành công, tài xế sẽ gửi ZZ0000ZZ và ZZ0001ZZ
lệnh yêu cầu chương trình cơ sở để bắt đầu chụp khung hình. ZZ0002ZZ
lệnh xếp hàng bộ đệm vào phần sụn với ZZ0003ZZ, sau đó phần mềm sẽ chờ ngắt và
phản hồi từ phần sụn, ZZ0004ZZ có nghĩa là bộ đệm đã sẵn sàng trên một thiết bị cụ thể
chân đầu ra và sau đó phần mềm có thể trả lại bộ đệm cho người dùng.

.. Note:: See :ref:`Examples<ipu6_isys_capture_examples>` about how to do
	  capture by IPU6 ISYS driver.