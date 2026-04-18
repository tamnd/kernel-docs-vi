.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/caif/linux_caif.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

===========
Linux CAIF
==========

Bản quyền ZZ0000ZZ ST-Ericsson AB 2010

:Tác giả: Sjur Brendeland/ sjur.brandeland@stericsson.com
:Điều khoản cấp phép: Giấy phép công cộng chung GNU (GPL) phiên bản 2


Giới thiệu
============

CAIF là giao thức MUX được sử dụng bởi modem di động ST-Ericsson cho
giao tiếp giữa Modem và máy chủ. Các tiến trình máy chủ có thể mở AT ảo
kênh, khởi tạo kết nối Dữ liệu GPRS, Kênh video và Kênh tiện ích.
Kênh tiện ích là các đường ống có mục đích chung giữa modem và máy chủ.

Modem ST-Ericsson hỗ trợ một số đường truyền giữa các modem
và chủ nhà. Hiện tại, UART và Loopback có sẵn cho Linux.


Ngành kiến ​​​​trúc
============

Việc triển khai CAIF được chia thành:

* Lớp ổ cắm CAIF và Giao diện IP GPRS.
* Triển khai giao thức lõi CAIF
* Lớp liên kết CAIF, được triển khai dưới dạng thiết bị NET.

::

RTNL
   !
   !	      +------+ +------+
   !	     +------+!	+------+!
   !	     !	IP!!	!Ổ cắm!!
   +-------> !interf!+ ! API !+ <- API máy khách CAIF
   !	     +------+ +------!
   !		!	    !
   !		+----------+
   !		      !
   !		   +------+ <- Giao thức lõi CAIF
   !		   ! CAIF!
   !		   ! Cốt lõi !
   !		   +------+
   !	   +----------!----------+
   !	   !	      !		!
   !	+------+ +------+ +------+
   +--> ! HSI!   ! TTY!   ! USB!	<- Lớp liên kết (Thiết bị mạng)
	+------+ +------+ +------+



Thực hiện
==============


Lớp giao thức lõi CAIF
------------------------

Lớp lõi CAIF thực hiện giao thức CAIF theo định nghĩa của ST-Ericsson.
Nó triển khai ngăn xếp giao thức CAIF theo cách tiếp cận phân lớp, trong đó
mỗi lớp được mô tả trong đặc tả được triển khai dưới dạng một lớp riêng biệt.
Kiến trúc được lấy cảm hứng từ các mẫu thiết kế "Lớp giao thức" và
"Gói giao thức".

Cấu trúc CAIF
^^^^^^^^^^^^^^

Việc triển khai Core CAIF chứa:

- Triển khai CAIF đơn giản.
      - Kiến trúc phân lớp (a la Streams), mỗi lớp trong CAIF
	đặc tả được triển khai trong một tệp c riêng biệt.
      - Khách hàng phải gọi chức năng cấu hình để thêm lớp PHY.
      - Khách hàng phải triển khai lớp CAIF để tiêu thụ/sản xuất
	Tải trọng CAIF có chức năng nhận và truyền.
      - Khách hàng phải gọi hàm cấu hình để thêm và kết nối
	Lớp khách hàng.
      - Khi nhận / truyền Gói CAIF (cfpkt), quyền sở hữu được chuyển
	đến chức năng được gọi (ngoại trừ chức năng nhận của các lớp khung)

Kiến trúc lớp
====================

Giao thức CAIF có thể được chia thành hai phần: Chức năng hỗ trợ và Giao thức
Thực hiện. Các chức năng hỗ trợ bao gồm:

- Gói CFPKT CAIF. Triển khai gói giao thức CAIF. các
	Gói CAIF có chức năng tạo, hủy và thêm nội dung
	và để thêm/trích xuất tiêu đề và đoạn cuối vào các gói giao thức.

Việc triển khai Giao thức CAIF bao gồm:

- Lớp cấu hình CFCNFG CAIF. Định cấu hình Giao thức CAIF
	Ngăn xếp và cung cấp giao diện Máy khách để thêm Lớp liên kết và
	Giao diện trình điều khiển trên CAIF Stack.

- Lớp điều khiển CFCTRL CAIF. Mã hóa và giải mã các thông điệp điều khiển
	chẳng hạn như liệt kê và thiết lập kênh. Cũng phù hợp với yêu cầu và
	các tin nhắn phản hồi.

- CFSERVL Chức năng lớp dịch vụ CAIF chung; xử lý dòng chảy
	yêu cầu điều khiển và tắt máy từ xa.

- Lớp CFVEI CAIF VEI. Xử lý CAIF AT Kênh trên VEI (Ảo
	Giao diện bên ngoài). Lớp này mã hóa/giải mã các khung VEI.

- Lớp dữ liệu CFDGML CAIF. Xử lý lớp Datagram CAIF (IP
	lưu lượng truy cập), mã hóa/giải mã các khung Datagram.

- Lớp Mux CFMUX CAIF. Xử lý ghép kênh giữa nhiều
	các vật mang vật lý và nhiều kênh như VEI, Datagram, v.v.
	MUX theo dõi các Kênh CAIF hiện có và
	Phiên bản vật lý và chọn phiên bản phù hợp dựa trên
	trên Id kênh và ID vật lý.

- Lớp khung CFFRML CAIF. Xử lý khung tức là chiều dài khung
	và tổng kiểm tra khung.

- Lớp nối tiếp CFSERL CAIF. Xử lý nối/tách khung
	vào các Khung CAIF với độ dài chính xác.

::

+----------+
		    ZZ0000ZZ
		    ZZ0001ZZ
		    +----------+
			 !
    +----------+ +----------+ +----------+
    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ
    ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
    +----------+ +----------+ +----------+
	   \_____________!______________/
			 !
		    +----------+
		    ZZ0008ZZ
		    ZZ0009ZZ
		    +----------+
		    _____!_____
		   / \
	    +----------+ +----------+
	    ZZ0010ZZ ZZ0011ZZ
	    ZZ0012ZZ ZZ0013ZZ
	    +----------+ +----------+
		 !		!
	    +----------+ +----------+
	    ZZ0014ZZ ZZ0015ZZ
	    ZZ0016ZZ ZZ0017ZZ
	    +----------+ +----------+


Trong cách tiếp cận theo lớp này, các "quy tắc" sau sẽ được áp dụng.

- Tất cả các lớp nhúng cùng một cấu trúc "struct cflayer"
      - Một lớp không phụ thuộc vào dữ liệu riêng tư của bất kỳ lớp nào khác.
      - Các lớp được xếp chồng lên nhau bằng cách thiết lập con trỏ::

lớp-> lên, lớp-> dn

- Để gửi dữ liệu lên trên, mỗi lớp nên thực hiện::

lớp-> lên-> nhận (lớp-> lên, gói);

- Để gửi dữ liệu xuống dưới, mỗi lớp nên thực hiện::

lớp->dn->truyền(lớp->dn, gói);


Giao diện IP và ổ cắm CAIF
============================

Giao diện IP và ổ cắm CAIF API được triển khai trên
Giao thức lõi CAIF. Giao diện IP và ổ cắm CAIF có phiên bản của
'struct clayer', giống như ngăn xếp giao thức CAIF Core.
Thiết bị Net và Ổ cắm thực hiện chức năng 'receive()' được xác định bởi
'struct clayer', giống như phần còn lại của ngăn xếp CAIF. Bằng cách này, truyền tải và
việc nhận các gói được xử lý như các lớp còn lại: 'dn->transmit()'
hàm được gọi để truyền dữ liệu.

Cấu hình lớp liên kết
---------------------------
Lớp liên kết được triển khai dưới dạng thiết bị mạng Linux (struct net_device).
Việc xử lý và đăng ký tải trọng được thực hiện bằng các cơ chế Linux tiêu chuẩn.

Giao thức CAIF dựa trên lớp liên kết không mất dữ liệu mà không cần triển khai
truyền lại. Điều này ngụ ý rằng việc rớt gói không được xảy ra.
Do đó, cơ chế kiểm soát luồng được thực hiện ở nơi vật lý
giao diện có thể bắt đầu dừng luồng cho tất cả các Kênh CAIF.