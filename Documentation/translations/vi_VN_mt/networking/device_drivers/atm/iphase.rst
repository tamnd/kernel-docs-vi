.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/atm/iphase.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Nguồn trình điều khiển Linux ATM (i)Chip IA Linux
=================================================

READ TÔI FIRST

--------------------------------------------------------------------------------

Hãy đọc phần này trước khi bạn bắt đầu!

--------------------------------------------------------------------------------

Sự miêu tả
===========

Đây là tệp README dành cho trình điều khiển Interphase PCI ATM (i)Chip IA Linux
phát hành nguồn.

Các tính năng và hạn chế của trình điều khiển này như sau:

- Hỗ trợ một VPI (giá trị VPI bằng 0).
    - Hỗ trợ 4K VC cho bo mạch máy chủ (với bộ nhớ điều khiển 512K) và 1K
      VC cho bo mạch khách (có bộ nhớ điều khiển 128K).
    - Hỗ trợ các danh mục dịch vụ UBR, ABR và CBR.
    - Chỉ hỗ trợ AAL5.
    - Hỗ trợ cài đặt PCR trên VC.
    - Hỗ trợ nhiều bộ điều hợp trong một hệ thống.
    - Tất cả các biến thể của Interphase ATM PCI (i) Thẻ bộ điều hợp chip đều được hỗ trợ,
      bao gồm x575 (OC3, bộ nhớ điều khiển 128K, 512K và bộ nhớ gói 128K,
      512K và 1M), x525 (UTP25) và x531 (DS3 và E3). Xem
      ZZ0000ZZ
      để biết chi tiết.
    - Chỉ hỗ trợ nền tảng x86.
    - SMP được hỗ trợ.


Trước khi bạn bắt đầu
=====================


Cài đặt
------------

1. Cài đặt bộ chuyển đổi vào hệ thống

Để cài đặt bộ điều hợp ATM trong hệ thống, hãy làm theo các bước bên dưới.

Một. Đăng nhập bằng root.
       b. Tắt hệ thống và tắt nguồn hệ thống.
       c. Cài đặt một hoặc nhiều bộ điều hợp ATM trong hệ thống.
       d. Kết nối từng bộ chuyển đổi với một cổng trên bộ chuyển mạch ATM. 'Liên kết' màu xanh lá cây
	  LED ở mặt trước của bộ chuyển đổi sẽ bật nếu bộ chuyển đổi được bật
	  được kết nối đúng cách với công tắc khi hệ thống được bật nguồn.
       đ. Bật nguồn và khởi động hệ thống.

2. [ Đã xóa ]

3. Xây dựng lại kernel với sự hỗ trợ của ABR

[ Một. và b. LOẠI BỎ ]

c. Cấu hình lại kernel, chọn trình điều khiển Interphase ia thông qua "make
       menuconfig" hoặc "tạo xconfig".
    d. Xây dựng lại kernel, các mô-đun có thể tải và các công cụ atm.
    đ. Cài đặt kernel và mô-đun mới được xây dựng và khởi động lại.

4. Tải trình điều khiển phần cứng bộ điều hợp (trình điều khiển ia) nếu nó được xây dựng dưới dạng mô-đun

Một. Đăng nhập bằng root.
       b. Thay đổi thư mục thành /lib/modules/<kernel-version>/atm.
       c. Chạy "insmod suni.o;insmod iphase.o"
	  “Trạng thái” LED màu vàng ở mặt trước của bộ chuyển đổi sẽ nhấp nháy
	  trong khi trình điều khiển được tải vào hệ thống.
       d. Để xác minh rằng trình điều khiển 'ia' đã được tải thành công, hãy chạy lệnh
	  lệnh sau::

mèo /proc/atm/thiết bị

Nếu trình điều khiển được tải thành công, đầu ra của lệnh sẽ
	  tương tự như các dòng sau::

Loại này ESI/"MAC"addr AAL(TX,err,RX,err,drop) ...
	      0 ia xxxxxxxxx 0 ( 0 0 0 0 0 ) 5 ( 0 0 0 0 0 )

Bạn cũng có thể kiểm tra tệp nhật ký hệ thống /var/log/messages để tìm tin nhắn
	  liên quan đến trình điều khiển ATM.

5. Cấu hình trình điều khiển Ia

5.1 Cấu hình bộ đệm của bộ điều hợp
    Các bo mạch (i)Chip có 3 biến thể kích thước gói RAM khác nhau: 128K, 512K và
    1 triệu. Kích thước RAM quyết định số lượng bộ đệm và kích thước bộ đệm. Mặc định
    kích thước và số lượng bộ đệm được đặt như sau:

========= ======= ====== ====== ====== ====== ======
	 Tổng cộng Rx RAM Tx RAM Rx Buf Tx Buf Rx buf Tx buf
	 RAM kích thước kích thước kích thước kích thước kích thước cnt cnt
	========= ======= ====== ====== ====== ====== ======
	   128K 64K 64K 10K 10K 6 6
	   512K 256K 256K 10K 10K 25 25
	     1M 512K 512K 10K 10K 51 51
	========= ======= ====== ====== ====== ====== ======

Những cài đặt này sẽ hoạt động tốt trong hầu hết các môi trường, nhưng có thể
       đã thay đổi bằng cách gõ lệnh sau ::

insmod <IA_DIR>/ia.o IA_RX_BUF=<RX_CNT> IA_RX_BUF_SZ=<RX_SIZE> \
		   IA_TX_BUF=<TX_CNT> IA_TX_BUF_SZ=<TX_SIZE>

Ở đâu:

- RX_CNT = số lượng bộ đệm nhận trong phạm vi (1-128)
	    - RX_SIZE = kích thước bộ đệm nhận trong phạm vi (48-64K)
	    - TX_CNT = số lượng bộ đệm truyền trong phạm vi (1-128)
	    - TX_SIZE = kích thước bộ đệm truyền trong phạm vi (48-64K)

1. Kích thước bộ đệm truyền và nhận phải là bội số của 4.
	    2. Cần cẩn thận để đảm bảo bộ nhớ cần thiết cho
	       bộ đệm truyền và nhận nhỏ hơn hoặc bằng
	       tổng bộ nhớ gói bộ điều hợp.

5.2 Bật theo dõi gỡ lỗi ia

Khi trình điều khiển ia được xây dựng với cờ CONFIG_ATM_IA_DEBUG, trình điều khiển
    có thể cung cấp thêm dấu vết gỡ lỗi nếu cần. Có một biến mặt nạ bit,
    IADebugFlag, kiểm soát đầu ra của dấu vết. Bạn có thể tìm thấy một chút
    bản đồ của IADebugFlag trong iphase.h.
    Theo dõi gỡ lỗi có thể được bật thông qua tùy chọn dòng lệnh insmod, ví dụ:
    ví dụ: "insmod iphase.o IADebugFlag=0xffffffff" có thể bật tất cả tính năng gỡ lỗi
    dấu vết cùng với việc tải trình điều khiển.

6. Kiểm tra trình điều khiển Ia bằng ttcp_atm và PVC

Để thiết lập PVC, các máy kiểm tra có thể được kết nối nối tiếp nhau hoặc
   thông qua một công tắc. Nếu kết nối thông qua công tắc thì công tắc phải
   được định cấu hình cho (các) PVC.

Một. Đối với thử nghiệm UBR:

Tại máy kiểm tra dự định nhận dữ liệu, gõ::

ttcp_atm -r -a -s 0.100

Tại máy kiểm tra khác, gõ::

ttcp_atm -t -a -s 0,100 -n 10000

Chạy "ttcp_atm -h" để hiển thị thêm tùy chọn của công cụ ttcp_atm.
   b. Đối với thử nghiệm ABR:

Nó giống như thử nghiệm UBR, nhưng có thêm tùy chọn lệnh ::

-Pabr:max_pcr=<xxx>

Ở đâu:

xxx = tốc độ cell cực đại tối đa, từ 170 - 353207.

Tùy chọn này phải được đặt trên cả hai máy.

c. Đối với thử nghiệm CBR:

Nó giống như thử nghiệm UBR, nhưng có thêm tùy chọn lệnh ::

-Pcbr:max_pcr=<xxx>

Ở đâu:

xxx = tốc độ cell cực đại tối đa, từ 170 - 353207.

Tùy chọn này chỉ có thể được đặt trên máy truyền.


Vấn đề nổi bật
==================



Thông tin liên hệ
-------------------

::

Hỗ trợ khách hàng:
	 Hoa Kỳ: Điện thoại: (214) 654-5555
			Fax: (214) 654-5500
			Email: intouch@iphase.com
	 Châu Âu: Điện thoại: 33 (0)1 41 15 44 00
			Số fax: 33 (0)1 41 15 12 13
     Mạng toàn cầu: ZZ0000ZZ
     FTP ẩn danh: ftp.iphase.com