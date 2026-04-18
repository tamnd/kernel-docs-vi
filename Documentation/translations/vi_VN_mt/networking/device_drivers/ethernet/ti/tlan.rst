.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/ti/tlan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Trình điều khiển TLAN cho Linux
===============================

:Phiên bản: 1.14a

(C) 1997-1998 Caldera, Inc.

(C) 1998 James Banks

(C) 1999-2001 Torben Mathiasen <tmm@image.dk, torben.mathiasen@compaq.com>

Để biết thông tin/cập nhật trình điều khiển, hãy truy cập ZZ0000ZZ





I. Thiết bị được hỗ trợ
=======================

Chỉ các thiết bị PCI mới hoạt động với trình điều khiển này.

Được hỗ trợ:

===================================================================
    ID nhà cung cấp ID thiết bị
    ===================================================================
    0e11 ae32 Compaq Nettelligent 10/100 TX PCI UTP
    0e11 ae34 Compaq Nettelligent 10 T PCI UTP
    0e11 ae35 Compaq Tích hợp NetFlex 3/P
    0e11 ae40 Compaq Nettelligent Dual 10/100 TX PCI UTP
    0e11 ae43 Compaq Nettelligent Tích hợp 10/100 TX UTP
    0e11 b011 Compaq Nettelligent 10/100 TX nhúng UTP
    0e11 b012 Compaq Nettelligent 10 T/2 PCI UTP/Coax
    0e11 b030 Compaq Nettelligent 10/100 TX UTP
    0e11 f130 Compaq NetFlex 3/P
    0e11 f150 Compaq NetFlex 3/P
    108d 0012 Olicom OC-2325
    108d 0013 Olicom OC-2183
    108d 0014 Olicom OC-2326
    ===================================================================


Hãy cẩn thận:

Tôi không chắc liệu bo mạch con 100BaseTX có phải không (đối với những thẻ có
    hỗ trợ những thứ như vậy) sẽ hoạt động.  Tôi chưa có bằng chứng chắc chắn nào
    dù thế nào đi nữa.

Tuy nhiên, nếu thẻ hỗ trợ 100BaseTx mà không yêu cầu thêm
    trên bo mạch con, nó sẽ hoạt động với 100BaseTx.

Thiết bị "Nettelligent 10 T/2 PCI UTP/Coax" (b012) chưa được kiểm tra,
    nhưng tôi không mong đợi bất kỳ vấn đề.


II. Tùy chọn trình điều khiển
=============================

1. Bạn có thể thêm debug=x vào cuối dòng insmod để có được
	   thông báo gỡ lỗi, trong đó x là trường bit trong đó các bit có nghĩa là
	   sau đây:

==== =========================================
	   0x01 Bật thông báo gỡ lỗi chung.
	   0x02 Bật nhận tin nhắn gỡ lỗi.
	   0x04 Bật truyền thông báo gỡ lỗi.
	   0x08 Bật danh sách thông báo gỡ lỗi.
	   ==== =========================================

2. Bạn có thể thêm aui=1 vào cuối dòng insmod để tạo ra
	   bộ chuyển đổi để sử dụng giao diện AUI thay vì 10 Base T
	   giao diện.  Đây cũng là việc cần làm nếu bạn muốn sử dụng BNC
	   đầu nối trên thiết bị dựa trên TLAN.  (Đặt tùy chọn này trên một
	   thiết bị không có đầu nối AUI/BNC có thể sẽ
	   khiến nó không hoạt động chính xác.)

3. Bạn có thể đặt duplex=1 để buộc bán song công và duplex=2 để buộc
	   buộc song công hoàn toàn.

4. Bạn có thể đặt tốc độ = 10 để buộc hoạt động 10Mbs và tốc độ = 100
	   để buộc hoạt động 100Mbs. (Tôi không chắc điều gì sẽ xảy ra
	   nếu thẻ chỉ hỗ trợ 10Mbs bị ép lên 100Mbs
	   chế độ.)

5. Bây giờ bạn phải sử dụng speed=X duplex=Y cùng nhau. Nếu bạn chỉ
	   thực hiện "insmod tlan.o speed=100" trình điều khiển sẽ thực hiện Tự động phủ định.
	   Để buộc liên kết Half-Duplex 10Mbps, hãy thực hiện "insmod tlan.o speed=10
	   song công = 1".

6. Nếu driver được tích hợp sẵn trong kernel thì bạn có thể sử dụng cái thứ 3
	   và tham số thứ 4 để đặt aui và debug tương ứng.  Ví dụ::

ether=0,0,0x1,0x7,eth0

Điều này đặt aui thành 0x1 và gỡ lỗi thành 0x7, giả sử eth0 là
	   thiết bị TLAN được hỗ trợ.

Các bit trong byte thứ ba được gán như sau:

==== =================
		0x01 aui
		0x02 sử dụng song công một nửa
		0x04 sử dụng song công hoàn toàn
		0x08 sử dụng 10BaseT
		0x10 sử dụng 100BaseTx
		==== =================

Bạn cũng cần đặt cả cài đặt tốc độ và in hai mặt khi buộc
	   tốc độ với các tham số kernel.
	   ether=0,0,0x12,0,eth0 sẽ buộc liên kết tới Half-Duplex 100Mbps.

7. Nếu bạn có nhiều bộ chuyển đổi tlan trong hệ thống, bạn có thể
	   sử dụng các tùy chọn trên trên cơ sở mỗi bộ chuyển đổi. Để buộc 100Mbit/HD
	   liên kết với bộ chuyển đổi eth1 của bạn, sử dụng::

tốc độ insmod tlan=0,100 song công=0,1

Bây giờ eth0 sẽ sử dụng auto-neg và eth1 sẽ bị buộc phải ở mức 100Mbit/HD.
	   Lưu ý rằng trình điều khiển tlan hỗ trợ tối đa 8 bộ điều hợp.


III. Những điều cần thử nếu bạn gặp vấn đề
==========================================

1. Đảm bảo id PCI của thẻ của bạn nằm trong số được liệt kê trong
	   phần I ở trên.
	2. Đảm bảo định tuyến là chính xác.
	3. Thử buộc cài đặt tốc độ/song công khác nhau


Ngoài ra còn có một danh sách gửi thư tlan mà bạn có thể tham gia bằng cách gửi "đăng ký tlan"
trong nội dung email gửi tới Majordomo@vuser.vu.union.edu.

Ngoài ra còn có website tlan tại ZZ0000ZZ
