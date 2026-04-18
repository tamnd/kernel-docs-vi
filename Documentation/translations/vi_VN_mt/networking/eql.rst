.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/eql.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Trình điều khiển EQL: Cân bằng tải IP nối tiếp HOWTO
==========================================

Simon "Guru Aleph-Null" Janes, simon@ncm.com

v1.1, ngày 27 tháng 2 năm 1995

Đây là hướng dẫn sử dụng trình điều khiển thiết bị EQL. EQL là một thiết bị phần mềm
  cho phép bạn cân bằng tải các liên kết nối tiếp IP (SLIP hoặc PPP không nén)
  để tăng băng thông của bạn. Nó sẽ không làm giảm độ trễ của bạn (tức là ping
  lần) ngoại trừ trường hợp bạn đã có nhiều lưu lượng truy cập trên
  liên kết của bạn, trong đó nó sẽ giúp họ. Trình điều khiển này đã được thử nghiệm
  với kernel 1.1.75 và được biết là đã vá sạch bằng
  1.1.86.  Một số thử nghiệm với 1.1.92 đã được thực hiện với bản vá v1.1
  chỉ được tạo để vá sạch trong kernel mới nhất
  cây nguồn. (Vâng, nó hoạt động tốt.)

1. Giới thiệu
===============

Cái nào tệ hơn? Một khoản phí khổng lồ cho một đường dây thuê riêng 56K hoặc hai đường dây điện thoại?
  Có lẽ là cái trước.  Nếu bạn thấy mình muốn có thêm băng thông,
  và có ISP linh hoạt, giờ đây có thể kết nối modem
  cùng nhau làm việc như một liên kết điểm-điểm để tăng cường
  băng thông.  Tất cả mà không cần phải có hộp đen đặc biệt trên đó
  bên.


Trình điều khiển eql chỉ được thử nghiệm với Livingston PortMaster-2e
  máy chủ đầu cuối. Tôi không biết liệu các máy chủ đầu cuối khác có hỗ trợ tải-
  cân bằng, nhưng tôi biết rằng PortMaster thực hiện điều đó và thực hiện điều đó
  gần như trình điều khiển eql dường như làm được điều đó (- Thật không may, trong
  thử nghiệm của tôi cho đến nay, khả năng cân bằng tải của Livingston PortMaster 2e là một
  tốt chậm hơn 1 đến 2 KB/s so với máy thử nghiệm hoạt động với tốc độ 28,8 Kbps
  và kết nối 14,4 Kbps.  Tuy nhiên, tôi không chắc chắn rằng nó thực sự là
  PortMaster hoặc nếu đó là trình điều khiển TCP của Linux. Tôi được bảo rằng Linux
  Tuy nhiên, việc triển khai TCP khá nhanh.--)


Tôi đề nghị với các ISP ở đó rằng việc tính phí có thể là hợp lý
  một khách hàng cân bằng tải 75% chi phí của tuyến thứ hai và 50%
  chi phí của dòng thứ ba, v.v...


Này, tất cả chúng ta đều có thể mơ, bạn biết đấy...


2. Cấu hình hạt nhân
=======================

Ở đây tôi mô tả các bước chung để thiết lập và chạy kernel
  với trình điều khiển eql.	Từ vá lỗi, xây dựng, đến cài đặt.


2.1. Vá hạt nhân
------------------------

Nếu bạn không có hoặc không thể lấy bản sao của kernel có eql
  trình điều khiển được gấp vào đó, hãy lấy bản sao trình điều khiển của bạn từ
  ftp://slaughter.ncm.com/pub/Linux/LOAD_BALANCING/eql-1.1.tar.gz.
  Giải nén kho lưu trữ này ở một nơi nào đó rõ ràng như /usr/local/src/.  Nó sẽ
  tạo các tập tin sau::

-rw-r--r-- guru/ncm 198 Ngày 19 tháng 1 18:53 1995 eql-1.1/NO-WARRANTY
       -rw-r--r-- guru/ncm 30620 27 tháng 2 21:40 1995 eql-1.1/eql-1.1.patch
       -rwxr-xr-x guru/ncm 16111 Ngày 12 tháng 1 22:29 1995 eql-1.1/eql_enslave
       -rw-r--r-- guru/ncm 2195 Ngày 10 tháng 1 21:48 1995 eql-1.1/eql_enslave.c

Giải nén kernel gần đây (thứ gì đó sau 1.1.92) ở nơi nào đó thuận tiện
  như nói /usr/src/linux-1.1.92.eql. Sử dụng các liên kết tượng trưng để trỏ
  /usr/src/linux vào thư mục phát triển này.


Áp dụng bản vá bằng cách chạy các lệnh ::

cd /usr/src
       vá </usr/local/src/eql-1.1/eql-1.1.patch


2.2. Xây dựng hạt nhân
------------------------

Sau khi vá kernel, hãy chạy make config và cấu hình kernel
  cho phần cứng của bạn.


Sau khi cấu hình xong hãy thực hiện và cài đặt theo thói quen của bạn.


3. Cấu hình mạng
========================

Cho đến nay, tôi chỉ sử dụng thiết bị eql có kết nối DSLIP SLIP
  quản lý của Matt Dillon (-- "Người đàn ông đã bán linh hồn của mình để viết mã rất nhiều
  nhanh quá."--).  Cách bạn định cấu hình nó cho "kết nối" khác
  người quản lý tùy thuộc vào bạn.  Hầu hết các trình quản lý kết nối khác mà tôi đã thấy
  không làm tốt công việc khi phải xử lý nhiều hơn một
  kết nối.


3.1. /etc/rc.d/rc.inet1
-----------------------

Trong RC.inet1, ifconfig thiết bị eql về địa chỉ IP bạn thường sử dụng
  cho máy của bạn và MTU bạn thích cho dòng SLIP của mình.	một
  có thể lập luận rằng MTU phải có kích thước gần bằng một nửa kích thước thông thường cho hai người
  modem, một phần ba cho ba, một phần tư cho bốn, v.v... Nhưng sẽ
  quá xa dưới 296 có lẽ là quá mức cần thiết. Đây là một ví dụ ifconfig
  lệnh thiết lập thiết bị eql::

ifconfig eql 198.67.33.239 mtu 1006

Khi thiết bị eql được thiết lập và chạy, hãy thêm tuyến mặc định tĩnh vào
  nó trong bảng định tuyến bằng cách sử dụng cú pháp tuyến đường mới thú vị tạo nên
  cuộc sống dễ dàng hơn rất nhiều::

tuyến đường thêm eql mặc định


3.2. Làm nô lệ thiết bị bằng tay
------------------------------

Thiết bị nô lệ bằng tay yêu cầu hai chương trình tiện ích: eql_enslave
  và eql_emancipate (- eql_emancipate chưa được viết vì khi
  một thiết bị nô lệ "chết", nó sẽ tự động bị đưa ra khỏi hàng đợi.
  Tôi vẫn chưa tìm được lý do chính đáng để viết nó... ngoài lý do
  sự trọn vẹn, nhưng đó không phải là động lực tốt phải không?--)


Cú pháp để bắt một thiết bị làm nô lệ là "eql_enslave <master-name>
  <tên nô lệ> <ước tính-bps>".  Dưới đây là một số ví dụ về chế độ nô lệ::

eql_enslave eql sl0 28800
       eql_enslave eql ppp0 14400
       eql_enslave eql sl1 57600

Khi bạn muốn giải phóng một thiết bị khỏi cuộc sống nô lệ của nó, bạn có thể
  hoặc tắt thiết bị bằng ifconfig (eql sẽ tự động chôn thiết bị
  nô lệ đã chết và xóa nó khỏi hàng đợi của nó) hoặc sử dụng eql_emancipate để giải phóng
  nó. (- Hoặc chỉ cần ifconfig nó xuống và trình điều khiển eql sẽ lấy nó ra
  dành cho bạn.--)::

eql_emancipate eql sl0
       eql_emancipate eql ppp0
       eql_emancipate eql sl1


3.3. Cấu hình DSLIP cho thiết bị eql
-------------------------------------------

Ý tưởng chung là hiển thị và duy trì càng nhiều kết nối SLIP càng tốt
  khi bạn cần, tự động.


3.3.1.  /etc/slip/runslip.conf
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đây là một ví dụ runslip.conf::

tên sl-line-1
	  đã bật
	  baud 38400
	  mtu 576
	  ducmd -e /etc/slip/dialout/cua2-288.xp -t 9
	  lệnh eql_enslave eql $interface 28800
	  địa chỉ 198.67.33.239
	  dòng /dev/cua2

tên sl-line-2
	  đã bật
	  baud 38400
	  mtu 576
	  ducmd -e /etc/slip/dialout/cua3-288.xp -t 9
	  lệnh eql_enslave eql $interface 28800
	  địa chỉ 198.67.33.239
	  dòng /dev/cua3


3.4. Sử dụng PPP và thiết bị eql
---------------------------------

Tôi chưa thực hiện bất kỳ thử nghiệm cân bằng tải nào cho các thiết bị PPP, chủ yếu là
  bởi vì tôi không có trình quản lý kết nối PPP như SLIP có
  DSLIP. Tôi đã tìm thấy một mẹo hay từ LinuxNET:Billy cho hiệu suất của PPP:
  đảm bảo bạn đã đặt asyncmap thành thứ gì đó để kiểm soát
  các ký tự không được thoát.


Tôi đã cố sửa tập lệnh/hệ thống PPP để gọi lại PPP bị mất
  kết nối để sử dụng với trình điều khiển eql vào cuối tuần ngày 25-26 tháng 2 năm 95
  (Sau đây được gọi là Lễ hội căm thù PPP kéo dài 8 giờ).  Có lẽ sau này
  năm.


4. Giới thiệu về thuật toán lập lịch nô lệ
======================================

Bộ lập lịch nô lệ có thể được thay thế bằng hàng tá bộ lập lịch khác
  mọi thứ và đẩy lưu lượng truy cập nhanh hơn nhiều.	Công thức trong bộ hiện tại
  trình điều khiển đã được điều chỉnh để xử lý nô lệ với các chế độ cực kỳ khác nhau
  "mức độ ưu tiên" bit trên giây.


Tất cả thử nghiệm tôi đã thực hiện với hai modem 28,8 V.FC, một kết nối
  ở tốc độ 28800 bps hoặc chậm hơn và cái còn lại kết nối ở tốc độ 14400 bps
  thời gian.


Một phiên bản của bộ lập lịch có thể đẩy tốc độ 5,3 K/s qua
  28800 và 14400, nhưng khi mức độ ưu tiên trên các liên kết bị
  rất rộng (57600 so với 14400), modem "nhanh hơn" nhận được tất cả
  lưu lượng truy cập và modem "chậm hơn" bị bỏ đói.


5. Báo cáo của người thử nghiệm
===================

Một số người đã thử nghiệm thiết bị eql với phiên bản mới hơn
  hạt nhân (hơn 1.1.75).  Kể từ đó tôi đã cập nhật trình điều khiển để vá
  rõ ràng trong các hạt nhân mới hơn nhờ việc loại bỏ "nô lệ" cũ
  tùy chọn cấu hình trình điều khiển cân bằng".


- Icee từ LinuxNET đã vá 1.1.86 mà không có bất kỳ sự từ chối nào và đã có thể
     để khởi động kernel và sử dụng một vài liên kết ISDN PPP.

5.1. Báo cáo thử nghiệm của Randolph Bentson
-----------------------------------

  ::

Từ bentson@grieg.seaslug.org Thứ Tư ngày 8 tháng 2 19:08:09 1995
    Ngày: Thứ ba, ngày 7 tháng 2 năm 95 22:57 PST
    Từ: Randolph Bentson <bentson@grieg.seaslug.org>
    Tới: guru@ncm.com
    Chủ đề: Kiểm tra trình điều khiển EQL


Tôi đã kiểm tra trình điều khiển eql của bạn.  (Làm tốt lắm, điều đó!)
    Mặc dù bạn có thể đã thực hiện việc kiểm tra hiệu suất này nhưng ở đây
    là một số dữ liệu tôi đã khám phá được.

Randolph Bentson
    bentson@grieg.seaslug.org

------------------------------------------------------------------


Trình điều khiển thiết bị giả, EQL, được viết bởi Simon Janes, có thể được sử dụng
  để gộp nhiều kết nối SLIP thành một thứ có vẻ như là một
  kết nối duy nhất.  Điều này cho phép người ta cải thiện mạng quay số
  kết nối dần dần mà không cần phải mua DSU/CSU đắt tiền
  phần cứng và dịch vụ.

Tôi đã thực hiện một số thử nghiệm phần mềm này với hai mục tiêu
  tâm trí: đầu tiên, để đảm bảo nó thực sự hoạt động như mô tả và
  thứ hai, như một phương pháp thực hiện trình điều khiển thiết bị của tôi.

Các phép đo hiệu suất sau đây được lấy từ một bộ
  trong số các kết nối SLIP chạy giữa hai hệ thống Linux (1.1.84) bằng cách sử dụng
  một chiếc 486DX2/66 với Cyclom-8Y và một chiếc 486SLC/40 với Cyclom-16Y.
  (Cổng 0,1,2,3 đã được sử dụng. Cấu hình sau này sẽ phân phối
  lựa chọn cổng trên các chip Cirrus khác nhau trên bo mạch.)
  Sau khi liên kết được thiết lập, tôi đã tính thời gian chuyển giao ftp nhị phân của
  289284 byte dữ liệu.	Nếu không có phí tổn (tiêu đề gói,
  độ trễ giữa các ký tự và giữa các gói, v.v.) việc truyền
  sẽ mất những thời gian sau::

bit/giây giây
      345600 8.3
      234600 12.3
      172800 16.7
      153600 18,8
      76800 37,6
      57600 50,2
      38400 75,3
      28800 100,4
      19200 150,6
      9600 301.3

Một dòng duy nhất chạy ở tốc độ thấp hơn và với các gói lớn
  đạt tới khoảng 2% trong số này.  Hiệu suất bị giới hạn ở mức cao hơn
  tốc độ (theo dự đoán của sổ dữ liệu Cirrus) đến tổng số
  khoảng 160 kbit/giây.	Vòng thử nghiệm tiếp theo sẽ phân phối
  tải trên hai hoặc nhiều chip Cirrus.

Tin tốt là người ta gần như có được toàn bộ lợi thế của
  băng thông của dòng thứ hai, thứ ba và thứ tư.  (Tin xấu là
  rằng thiết lập kết nối có vẻ mong manh đối với cấp độ cao hơn
  tốc độ.  Sau khi được thiết lập, kết nối có vẻ đủ mạnh.)

============== === ======== ======= ======= ===
  #lines tốc độ mtu giây lý thuyết thực tế% của
	  tốc độ tối đa trong thời gian kbit/giây
  ============== === ======== ======= ======= ===
  3 115200 900 _ 345600
  3 115200 400 18.1 345600 159825 46
  2 115200 900 _ 230400
  2 115200 600 18.1 230400 159825 69
  2 115200 400 19.3 230400 149888 65
  4 57600 900 _ 234600
  4 57600 600 _ 234600
  4 57600 400 _ 234600
  3 57600 600 20,9 172800 138413 80
  3 57600 900 21,2 172800 136455 78
  3 115200 600 21,7 345600 133311 38
  3 57600 400 22,5 172800 128571 74
  4 38400 900 25,2 153600 114795 74
  4 38400 600 26,4 153600 109577 71
  4 38400 400 27,3 153600 105965 68
  2 57600 900 29,1 115200 99410,3 86
  1 115200 900 30,7 115200 94229,3 81
  2 57600 600 30,2 115200 95789,4 83
  3 38400 900 30,3 115200 95473,3 82
  3 38400 600 31,2 115200 92719,2 80
  1 115200 600 31,3 115200 92423 80
  2 57600 400 32,3 115200 89561,6 77
  1 115200 400 32,8 115200 88196,3 76
  3 38400 400 33,5 115200 86353,4 74
  2 38400 900 43,7 76800 66197,7 86
  2 38400 600 44 76800 65746.4 85
  2 38400 400 47,2 76800 61289 79
  4 19200 900 50,8 76800 56945,7 74
  4 19200 400 53,2 76800 54376,7 70
  4 19200 600 53,7 76800 53870,4 70
  1 57600 900 54,6 57600 52982,4 91
  1 57600 600 56,2 57600 51474 89
  3 19200 900 60,5 57600 47815,5 83
  1 57600 400 60,2 57600 48053,8 83
  3 19200 600 62 57600 46658.7 81
  3 19200 400 64,7 57600 44711,6 77
  1 38400 900 79,4 38400 36433,8 94
  1 38400 600 82,4 38400 35107,3 91
  2 19200 900 84,4 38400 34275,4 89
  1 38400 400 86,8 38400 33327,6 86
  2 19200 600 87,6 38400 33023,3 85
  2 19200 400 91,2 38400 31719,7 82
  4 9600 900 94,7 38400 30547,4 79
  4 9600 400 106 38400 27290.9 71
  4 9600 600 110 38400 26298,5 68
  3 9600 900 118 28800 24515.6 85
  3 9600 600 120 28800 24107 83
  3 9600 400 131 28800 22082.7 76
  1 19200 900 155 19200 18663.5 97
  1 19200 600 161 19200 17968 93
  1 19200 400 170 19200 17016,7 88
  2 9600 600 176 19200 16436,6 85
  2 9600 900 180 19200 16071.3 83
  2 9600 400 181 19200 15982,5 83
  1 9600 900 305 9600 9484,72 98
  1 9600 600 314 9600 9212,87 95
  1 9600 400 332 9600 8713,37 90
  ============== === ======== ======= ======= ===

5.2. Báo cáo của Anthony Healy
---------------------------

  ::

Ngày: Thứ Hai, 13 tháng 2 năm 1995 16:17:29 +1100 (EST)
    Từ: Antony Healey <ahealey@st.nepean.uws.edu.au>
    Kính gửi: Simon Janes <guru@ncm.com>
    Chủ đề: Re: Cân bằng tải

Xin chào Simon,
	  Tôi đã cài đặt bản vá của bạn và nó hoạt động rất tốt. tôi đã thử
	  nó qua hai đường SL/IP, chỉ qua các modem rỗng, nhưng tôi đã
	  có thể truyền dữ liệu với tốc độ trên 48Kb/s [ISDN link -Simon]. Tôi đã quản lý một
	  truyền lên tới 7,5 Kbyte/s trong một lần, nhưng tính trung bình khoảng
	  6,4 Kbyte/s, tôi nghĩ là khá tuyệt.  :)