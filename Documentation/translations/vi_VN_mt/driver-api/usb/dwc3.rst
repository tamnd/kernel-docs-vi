.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/dwc3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================================
Synopsys DesignWare Core SuperSpeed USB 3.0 Bộ điều khiển
===============================================================

:Tác giả: Felipe Balbi <felipe.balbi@linux.intel.com>
:Ngày: Tháng 4 năm 2017

Giới thiệu
============

ZZ0000ZZ
(sau đây gọi là ZZ0001ZZ) là sản phẩm tuân thủ USB SuperSpeed
bộ điều khiển có thể được cấu hình theo một trong 4 cách:

1. Cấu hình chỉ ngoại vi
	2. Cấu hình chỉ dành cho máy chủ
	3. Cấu hình vai trò kép
	4. Cấu hình trung tâm

Linux hiện hỗ trợ một số phiên bản của bộ điều khiển này. Trong tất cả
rất có thể phiên bản trong SoC của bạn đã được hỗ trợ. Vào thời điểm đó
Trong bài viết này, các phiên bản thử nghiệm đã biết nằm trong khoảng từ 2.02a đến 3.10a. Như một
theo nguyên tắc chung, mọi thứ trên 2,02a đều hoạt động tốt một cách đáng tin cậy.

Hiện tại, chúng tôi đã có nhiều người dùng biết đến trình điều khiển này. Theo thứ tự bảng chữ cái
đặt hàng:

1. Trứng cá
	2. Tập đoàn Intel
	3. Qualcomm
	4. Rockchip
	5. ST
	6. Samsung
	7. Dụng cụ Texas
	8. Xilinx

Tóm tắt các tính năng
======================

Để biết chi tiết về các tính năng được phiên bản DWC3 của bạn hỗ trợ, hãy tham khảo ý kiến
nhóm IP của bạn và/hoặc *Synopsys DesignWare Core SuperSpeed USB 3.0
Sổ dữ liệu điều khiển*. Sau đây là danh sách các tính năng được hỗ trợ bởi
lái xe tại thời điểm viết bài này:

1. Tối đa 16 điểm cuối hai chiều (bao gồm cả điểm kiểm soát
	   ống - ep0)
	2. Cấu hình điểm cuối linh hoạt
	3. Hỗ trợ chuyển đồng thời IN và OUT
	4. Hỗ trợ danh sách phân tán
	5. Lên tới 256 TRB [#trb]_ cho mỗi điểm cuối
	6. Hỗ trợ tất cả các loại truyền (ZZ0000ZZ, ZZ0001ZZ,
	   ZZ0002ZZ và ZZ0003ZZ)
	7. Luồng hàng loạt siêu tốc
	8. Quản lý nguồn liên kết
	9. Theo dõi sự kiện để gỡ lỗi
	10. Giao diện DebugFS [#debugfs]_

Tất cả các tính năng này đều đã được thực hiện với nhiều ZZ0000ZZ
trình điều khiển tiện ích. Chúng tôi đã xác minh cả ZZ0001ZZ [#configfs]_ và
trình điều khiển tiện ích cũ.

Thiết kế trình điều khiển
==============

Trình điều khiển DWC3 nằm trong thư mục ZZ0000ZZ. Tất cả các tập tin
liên quan đến trình điều khiển này nằm trong thư mục này. Điều này làm cho nó dễ dàng
dành cho người mới đọc mã và hiểu cách hoạt động của nó.

Do tính linh hoạt trong cấu hình của DWC3 nên trình điều khiển có một chút
phức tạp ở một số chỗ nhưng nó khá đơn giản để
hiểu.

Phần lớn nhất của trình điều khiển đề cập đến Gadget API.

Những hạn chế đã biết
===================

Giống như bất kỳ HW nào khác, DWC3 có những hạn chế riêng. Để tránh
những câu hỏi liên tục về những vấn đề như vậy, chúng tôi quyết định ghi lại chúng
ở đây và có một vị trí duy nhất để chúng tôi có thể hướng người dùng đến.

Yêu cầu về kích thước truyền OUT
---------------------------------

Theo Sổ dữ liệu Synopsys, tất cả các TRB truyền OUT [#trb]_ phải
đặt trường ZZ0001ZZ của họ thành một giá trị chia hết cho
ZZ0002ZZ của điểm cuối. Điều này có nghĩa là ZZ0003ZZ để
nhận Bộ lưu trữ lớn ZZ0004ZZ [#cbw]_, yêu cầu-> độ dài phải được đặt
thành một giá trị chia hết cho ZZ0005ZZ (1024 trên SuperSpeed,
512 trên HighSpeed, v.v.) hoặc trình điều khiển DWC3 phải thêm chỉ dẫn Chained TRB
vào bộ đệm vứt đi cho chiều dài còn lại. Không có điều này, OUT
quá trình chuyển ZZ0000ZZ sẽ bắt đầu.

Lưu ý rằng tại thời điểm viết bài này, điều này sẽ không thành vấn đề vì DWC3 là
hoàn toàn có khả năng gắn thêm TRB được xích cho chiều dài còn lại và
ẩn hoàn toàn chi tiết này khỏi trình điều khiển tiện ích. Nó vẫn có giá trị
đề cập đến vì đây dường như là nguồn truy vấn lớn nhất
về DWC3 và ZZ0000ZZ.

Giới hạn kích thước vòng TRB
-------------------------

Hiện tại, chúng tôi có giới hạn cứng là 256 TRB [#trb]_ cho mỗi điểm cuối,
với TRB cuối cùng là Link TRB [#link_trb]_ trỏ ngược lại
đầu tiên. Giới hạn này là tùy ý nhưng nó có lợi ích là cộng
chính xác là 4096 byte hoặc 1 Trang.

Trình điều khiển DWC3 sẽ cố gắng hết sức để đáp ứng hơn 255 yêu cầu và,
phần lớn, nó sẽ hoạt động bình thường. Tuy nhiên đây không phải là
một cái gì đó đã được thực hiện rất thường xuyên Nếu bạn trải nghiệm
bất kỳ vấn đề nào, hãy xem phần ZZ0000ZZ bên dưới.

Báo cáo lỗi
================

Bất cứ khi nào bạn gặp sự cố với DWC3, trước hết bạn
nên đảm bảo rằng:

1. Bạn đang chạy thẻ mới nhất từ ZZ0000ZZ
	2. Bạn có thể tái tạo lỗi mà không có bất kỳ thay đổi nào ngoài luồng
	   tới DWC3
	3. Bạn đã kiểm tra rằng đó không phải là lỗi trên máy chủ

Sau khi tất cả những điều này đã được xác minh, đây là cách để nắm bắt đủ
thông tin để chúng tôi có thể giúp ích gì cho bạn.

Thông tin bắt buộc
---------------------

DWC3 hoàn toàn dựa vào Sự kiện theo dõi để gỡ lỗi. Mọi thứ đều
được hiển thị ở đó, với một số bit bổ sung được hiển thị cho DebugFS
[#debugfs]_.

Để ghi lại Sự kiện theo dõi của DWC3, bạn nên chạy như sau
ra lệnh cho ZZ0000ZZ cắm cáp USB vào máy chủ:

.. code-block:: sh

		 # mkdir -p /d
		 # mkdir -p /t
		 # mount -t debugfs none /d
		 # mount -t tracefs none /t
		 # echo 81920 > /t/buffer_size_kb
		 # echo 1 > /t/events/dwc3/enable

Sau khi hoàn tất, bạn có thể kết nối cáp USB của mình và tái tạo
vấn đề. Ngay khi lỗi được sao chép, hãy tạo một bản sao của tập tin
ZZ0000ZZ và ZZ0001ZZ, như sau:

.. code-block:: sh

		# cp /t/trace /root/trace.txt
		# cat /d/*dwc3*/regdump > /root/regdump.txt

Đảm bảo nén ZZ0000ZZ và ZZ0001ZZ trong tarball
và gửi nó qua email tới ZZ0002ZZ với ZZ0003ZZ bằng Cc. Nếu bạn muốn trở thành người thừa
chắc chắn rằng tôi sẽ giúp bạn, hãy viết dòng chủ đề của bạn như sau
định dạng:

ZZ0000ZZ

Trên nội dung email, hãy đảm bảo nêu chi tiết những gì bạn làm, tiện ích nào
trình điều khiển bạn đang sử dụng, cách tái tạo sự cố, SoC của bạn là gì
đang sử dụng, hệ điều hành nào (và phiên bản của nó) đang chạy trên máy chủ.

Với tất cả thông tin này, chúng ta có thể hiểu được điều gì
đang diễn ra và có ích cho bạn.

Gỡ lỗi
===========

Đầu tiên và quan trọng nhất là tuyên bố từ chối trách nhiệm::

DISCLAIMER: Thông tin có sẵn trên DebugFS và/hoặc TraceFS có thể
  thay đổi bất cứ lúc nào tại bất kỳ Bản phát hành hạt nhân Linux chính nào. Nếu viết
  các tập lệnh, ZZ0000ZZ có giả định thông tin có sẵn trong
  định dạng hiện tại.

Bỏ chuyện đó đi, hãy tiếp tục.

Nếu bạn sẵn lòng giải quyết vấn đề của chính mình, bạn xứng đáng nhận được một
vỗ tay :-)

Dù sao thì cũng không có gì nhiều để nói ở đây ngoài việc Trace Events sẽ diễn ra.
thực sự hữu ích trong việc tìm ra vấn đề với DWC3. Ngoài ra, truy cập vào
Sổ dữ liệu tóm tắt sẽ có giá trị ZZ0000ZZ trong trường hợp này.

Đôi khi, USB Sniffer có thể hữu ích nhưng không hoàn toàn bắt buộc,
có rất nhiều điều có thể hiểu được mà không cần nhìn vào sợi dây.

Vui lòng gửi email cho ZZ0000ZZ và Cc ZZ0001ZZ nếu bạn cần bất kỳ trợ giúp nào.

ZZ0000ZZ
-------------

ZZ0000ZZ rất tốt để thu thập ảnh chụp nhanh về những gì đang diễn ra
với DWC3 và/hoặc bất kỳ điểm cuối nào.

Trên thư mục ZZ0000ZZ của DWC3, bạn sẽ tìm thấy các tệp và
thư mục:

ZZ0000ZZ
ZZ0001ZZ
ZZ0002ZZ
ZZ0003ZZ

ZZ0000ZZ
``````````````

Khi đọc, ZZ0000ZZ sẽ in ra một trong các ZZ0001ZZ, ZZ0002ZZ,
ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ,
ZZ0008ZZ, ZZ0009ZZ, ZZ0010ZZ, ZZ0011ZZ,
ZZ0012ZZ, ZZ0013ZZ, ZZ0014ZZ hoặc ZZ0015ZZ.

Tập tin này cũng có thể được ghi vào để buộc liên kết tới một trong các
các trạng thái trên.

ZZ0000ZZ
`````````````

Tên tập tin là tự giải thích. Khi đọc, ZZ0000ZZ sẽ in ra một
đăng ký kết xuất của DWC3. Lưu ý rằng tập tin này có thể được gắp để tìm
thông tin bạn muốn.

ZZ0000ZZ
``````````````

Khi đọc, ZZ0000ZZ sẽ in ra tên của một trong các đối tượng được chỉ định
Các chế độ thử nghiệm USB 2.0 (ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ,
ZZ0004ZZ, ZZ0005ZZ) hoặc chuỗi ZZ0006ZZ trong
trường hợp không có bài kiểm tra hiện đang được thực hiện.

Để bắt đầu bất kỳ chế độ kiểm tra nào, các chuỗi giống nhau có thể được
được ghi vào tệp và DWC3 sẽ vào chế độ kiểm tra được yêu cầu.


ZZ0000ZZ
``````````````````````

Đối với mỗi điểm cuối, chúng tôi hiển thị một thư mục theo cách đặt tên
quy ước ZZ0000ZZ ZZ0001ZZ. Bên trong mỗi
trong số các thư mục này, bạn sẽ tìm thấy các tệp sau:

ZZ0000ZZ
ZZ0001ZZ
ZZ0002ZZ
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ

Với quyền truy cập vào Sổ dữ liệu Synopsys, bạn có thể giải mã thông tin trên
họ.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~

Khi đọc, ZZ0000ZZ sẽ in ra một trong các ZZ0001ZZ,
ZZ0002ZZ, ZZ0003ZZ hoặc ZZ0004ZZ tùy thuộc vào điều gì
mô tả điểm cuối nói. Nếu điểm cuối chưa được kích hoạt, nó
sẽ in ZZ0005ZZ.

ZZ0000ZZ
~~~~~~~~~~~~~

Khi đọc, ZZ0000ZZ sẽ in ra thông tin chi tiết về tất cả TRB trên
chiếc nhẫn. Nó cũng sẽ cho bạn biết con trỏ enqueue và dequeue của chúng ta ở đâu
nằm trong vòng:

.. code-block:: sh
   
		buffer_addr,size,type,ioc,isp_imi,csp,chn,lst,hwo
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c75c000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c75c000,481,normal,1,0,1,0,0,0         
		000000002c784000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c784000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c784000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c784000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c75c000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c75c000,481,normal,1,0,1,0,0,0         
		000000002c780000,481,normal,1,0,1,0,0,0         
		000000002c784000,481,normal,1,0,1,0,0,0         
		000000002c788000,481,normal,1,0,1,0,0,0         
		000000002c78c000,481,normal,1,0,1,0,0,0         
		000000002c790000,481,normal,1,0,1,0,0,0         
		000000002c754000,481,normal,1,0,1,0,0,0         
		000000002c758000,481,normal,1,0,1,0,0,0         
		000000002c75c000,512,normal,1,0,1,0,0,1        D
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0       E 
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		0000000000000000,0,UNKNOWN,0,0,0,0,0,0         
		00000000381ab000,0,link,0,0,0,0,0,1


Theo dõi sự kiện
-------------

DWC3 cũng cung cấp một số sự kiện theo dõi giúp chúng tôi thu thập
thông tin về hành vi của trình điều khiển trong thời gian chạy.

Để sử dụng các sự kiện này, bạn phải kích hoạt ZZ0000ZZ trong
cấu hình kernel của bạn.

Để biết chi tiết về cách kích hoạt các sự kiện DWC3, hãy xem phần **Báo cáo
Lỗi**.

Các phần phụ sau đây sẽ cung cấp thông tin chi tiết về từng Lớp Sự kiện và
mỗi Sự kiện được xác định bởi DWC3.

MMIO
```````

Đôi khi rất hữu ích khi xem xét mọi truy cập MMIO khi tìm kiếm
lỗi. Do đó, DWC3 cung cấp hai Sự kiện theo dõi (một cho
dwc3_readl() và một cho dwc3_writel()). ZZ0000ZZ sau::

TP_printk("addr %p value %08x", __entry->base + __entry->offset,
  		__mục nhập->giá trị)

Sự kiện gián đoạn
````````````````

Mọi sự kiện IRQ đều có thể được ghi lại và giải mã thành dạng dữ liệu con người có thể đọc được
chuỗi. Vì mỗi sự kiện sẽ khác nhau nên chúng tôi không đưa ra
ví dụ khác với định dạng ZZ0000ZZ được sử dụng::

TP_printk("sự kiện (%08x): %s", __entry->sự kiện,
  		dwc3_decode_event(__entry->event, __entry->ep0state))

Yêu cầu kiểm soát
`````````````````

Mọi Yêu cầu Kiểm soát USB đều có thể được ghi vào bộ đệm theo dõi. các
định dạng đầu ra là::

TP_printk("%s", dwc3_decode_ctrl(__entry->bRequestType,
  				__entry->bRequest, __entry->wValue,
  				__entry->wIndex, __entry->wLength)
  )

Lưu ý rằng Yêu cầu Kiểm soát Tiêu chuẩn sẽ được giải mã thành
các chuỗi mà con người có thể đọc được với các đối số tương ứng của chúng. Lớp và
Yêu cầu của nhà cung cấp sẽ được in ra một chuỗi 8 byte ở dạng hex
định dạng.

Tuổi thọ của ZZ0000ZZ
```````````````````````````````````````

Toàn bộ thời gian tồn tại của ZZ0000ZZ có thể được theo dõi trên
bộ đệm dấu vết. Chúng tôi có một sự kiện cho mỗi lần phân bổ, miễn phí,
xếp hàng, loại bỏ hàng đợi và trả lại. Định dạng đầu ra là::

TP_printk("%s: req %p độ dài %u/%u %s%s%s ==> %d",
  	__get_str(tên), __entry->req, __entry->thực tế, __entry->độ dài,
  	__entry->không? "Z" : "z",
  	__entry->short_not_ok ? "S" : "s",
  	__entry->no_interrupt? "tôi" : "tôi",
  	__mục nhập->trạng thái
  )

Lệnh chung
````````````````````

Chúng tôi có thể ghi nhật ký và giải mã mọi Lệnh chung sau khi hoàn thành
mã. Định dạng là::

TP_printk("cmd '%s' [%x] thông số %08x --> trạng thái: %s",
  	dwc3_gadget_generic_cmd_string(__entry->cmd),
  	__entry->cmd, __entry->param,
  	dwc3_gadget_generic_cmd_status_string(__entry->status)
  )

Lệnh điểm cuối
````````````````````

Các lệnh điểm cuối cũng có thể được ghi lại cùng với việc hoàn thành
mã. Định dạng là::

TP_printk("%s: cmd '%s' [%d] thông số %08x %08x %08x --> trạng thái: %s",
  	__get_str(tên), dwc3_gadget_ep_cmd_string(__entry->cmd),
  	__entry->cmd, __entry->param0,
  	__entry->param1, __entry->param2,
  	dwc3_ep_cmd_status_string(__entry->cmd_status)
  )

Tuổi thọ của ZZ0000ZZ
``````````````````````

Tuổi thọ của ZZ0000ZZ rất đơn giản. Chúng tôi đang chuẩn bị ZZ0001ZZ hoặc
hoàn thành nó. Với hai sự kiện này, chúng ta có thể thấy ZZ0002ZZ thay đổi như thế nào
theo thời gian. Định dạng là::

TP_printk("%s: %d/%d trb %p buf %08x%08x kích thước %s%d ctrl %08x (%c%c%c%c:%c%c:%s)",
  	__get_str(tên), __entry->được xếp hàng đợi, __entry->được phân bổ,
  	__entry->trb, __entry->bph, __entry->bpl,
  	({char *s;
  	int pcm = ((__entry->size >> 24) & 3) + 1;
  	chuyển đổi (__entry->type) {
  	vỏ USB_ENDPOINT_XFER_INT:
  	vỏ USB_ENDPOINT_XFER_ISOC:
  		chuyển đổi (pcm) {
  		trường hợp 1:
  			s = "1x";
  			phá vỡ;
  		trường hợp 2:
  			s = "2x";
  			phá vỡ;
  		trường hợp 3:
  			s = "3x";
  			phá vỡ;
  		}
  	mặc định:
  		s = "";
  	} s; }),
  	DWC3_TRB_SIZE_LENGTH(__entry->kích thước), __entry->ctrl,
  	__entry->ctrl & DWC3_TRB_CTRL_HWO ? 'H' : 'h',
  	__entry->ctrl & DWC3_TRB_CTRL_LST ? 'L' : 'l',
  	__entry->ctrl & DWC3_TRB_CTRL_CHN ? 'C' : 'c',
  	__entry->ctrl & DWC3_TRB_CTRL_CSP ? 'S' : 's',
  	__entry->ctrl & DWC3_TRB_CTRL_ISP_IMI ? 'S' : 's',
  	__entry->ctrl & DWC3_TRB_CTRL_IOC ? 'C' : 'c',
      dwc3_trb_type_string(DWC3_TRBCTL_TYPE(__entry->ctrl))
  )

Tuổi thọ của điểm cuối
```````````````````````

Và thời gian tồn tại của điểm cuối được tóm tắt bằng kích hoạt và vô hiệu hóa
hoạt động, cả hai đều có thể được theo dõi. Định dạng là::

TP_printk("%s: mps %d/%d luồng %d bùng nổ %d đổ chuông %d/%d cờ %c:%c%c%c%c%c:%c:%c",
  	__get_str(tên), __entry->maxpacket,
  	__entry->maxpacket_limit, __entry->max_streams,
  	__entry->maxburst, __entry->trb_enqueue,
  	__entry->trb_dequeue,
  	__entry->cờ & DWC3_EP_ENABLED ? 'E' : 'e',
  	__entry->cờ & DWC3_EP_STALL ? 'S' : 's',
  	__entry->cờ & DWC3_EP_WEDGE ? 'W' : 'w',
  	__entry->cờ & DWC3_EP_TRANSFER_STARTED ? 'B' : 'b',
  	__entry->cờ & DWC3_EP_PENDING_REQUEST ? 'P' : 'p',
  	__entry->cờ & DWC3_EP_END_TRANSFER_PENDING ? 'E' : 'e',
  	__entry->hướng ? '<' : '>'
  )


Cấu trúc, phương pháp và định nghĩa
====================================

.. kernel-doc:: drivers/usb/dwc3/core.h
   :doc: main data structures
   :internal:

.. kernel-doc:: drivers/usb/dwc3/gadget.h
   :doc: gadget-only helpers
   :internal:

.. kernel-doc:: drivers/usb/dwc3/gadget.c
   :doc: gadget-side implementation
   :internal:

.. kernel-doc:: drivers/usb/dwc3/core.c
   :doc: core driver (probe, PM, etc)
   :internal:
   
.. [#trb] Transfer Request Block
.. [#link_trb] Transfer Request Block pointing to another Transfer
	       Request Block.
.. [#debugfs] The Debug File System
.. [#configfs] The Config File System
.. [#cbw] Command Block Wrapper
.. _Linus' tree: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/
.. _me: felipe.balbi@linux.intel.com
.. _linux-usb: linux-usb@vger.kernel.org
