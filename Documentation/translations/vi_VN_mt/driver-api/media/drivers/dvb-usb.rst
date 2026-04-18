.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/dvb-usb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Ý tưởng đằng sau dvb-usb-framework
==================================

.. note::

   #) This documentation is outdated. Please check at the DVB wiki
      at https://linuxtv.org/wiki for more updated info.

   #) **deprecated:** Newer DVB USB drivers should use the dvb-usb-v2 framework.

Vào tháng 3 năm 2005, tôi nhận được thiết bị Twinhan USB2.0 DVB-T mới. Họ cung cấp thông số kỹ thuật
và một phần sụn.

Khá quan tâm, tôi muốn đưa trình điều khiển (tất nhiên là có một số điều kỳ quặc) vào dibusb.
Sau khi đọc một số thông số kỹ thuật và thực hiện một số nghiên cứu về USB, nó nhận ra rằng
dibusb-driver sau đó sẽ hoàn toàn là một mớ hỗn độn. Vì vậy tôi quyết định thực hiện điều đó một cách
cách khác: Với sự trợ giúp của dvb-usb-framework.

Khung này cung cấp các hàm chung (chủ yếu là các lệnh gọi API kernel), chẳng hạn như:

- Xử lý luồng truyền tải URB kết hợp với dvb-demux-feed-control
  (số lượng lớn và isoc được hỗ trợ)
- đăng ký thiết bị cho DVB-API
- đăng ký bộ chuyển đổi I2C nếu có
- xử lý thiết bị đầu vào/điều khiển từ xa
- yêu cầu và tải chương trình cơ sở (hiện chỉ dành cho Cypress USB
  bộ điều khiển)
- các chức năng/phương thức khác có thể được chia sẻ bởi một số trình điều khiển (chẳng hạn như
  chức năng cho các lệnh điều khiển hàng loạt)
- TODO: một khối I2C. Nó tạo ra các khối truy cập đăng ký dành riêng cho thiết bị
  tùy thuộc vào độ dài của thanh ghi và số lượng giá trị có thể được
  đa văn bản và đa đọc.

Mã nguồn của các thiết bị DVB USB cụ thể chỉ thực hiện giao tiếp
với thiết bị thông qua xe buýt. Kết nối giữa chức năng DVB-API
được thực hiện thông qua các lệnh gọi lại, được gán trong mô tả thiết bị tĩnh (struct
dvb_usb_device) mỗi trình điều khiển thiết bị phải có.

Để biết ví dụ, hãy xem driver/media/usb/dvb-usb/vp7045*.

Mục tiêu là di chuyển tất cả các thiết bị USB (dibusb, cinergyT2, có thể là
ttusb; flexcop-usb đã được hưởng lợi từ thiết bị flexcop chung) để sử dụng
dvb-usb-lib.

TODO: bật và tắt động bộ lọc pid liên quan đến số lượng
nguồn cấp dữ liệu được yêu cầu.

Thiết bị được hỗ trợ
--------------------

Xem LinuxTV DVB Wiki tại ZZ0000ZZ để biết danh sách đầy đủ các
thẻ/trình điều khiển/chương trình cơ sở:
ZZ0001ZZ

0. Lịch sử & Tin tức:

30-06-2005

- thêm hỗ trợ cho WideView WT-220U (Cảm ơn Steve Chang)

30-05-2005

- đã thêm hỗ trợ đẳng thời cơ bản cho dvb-usb-framework
  - thêm hỗ trợ cho thiết kế tham chiếu Conexant Hybrid và Tinh vân
	       DigiTV USB

17-04-2005

- tất cả các thiết bị dibusb được chuyển để sử dụng dvb-usb-framework

2005-04-02

- kích hoạt lại và cải thiện mã điều khiển từ xa.

31-03-2005

- đã chuyển thiết bị Yakumo/Hama/Typhoon DVB-T USB2.0 sang dvb-usb.

30-03-2005

- cam kết đầu tiên của mô-đun dvb-usb dựa trên nguồn dibusb.
    Thiết bị đầu tiên là trình điều khiển mới cho
    TwinhanDTV Alpha / MagicBox II USB2.0 chỉ dành cho thiết bị DVB-T.
  - (chuyển từ dvb-dibusb sang dvb-usb)

28-03-2005

- thêm hỗ trợ cho thiết bị AVerMedia AverTV DVB-T USB2.0
    (Cảm ơn Glen Harris và Jiun-Kuei Jung, AVerMedia)

14-03-2005

- thêm hỗ trợ cho Typhoon/Yakumo/HAMA DVB-T di động USB2.0

2005-02-11

- thêm hỗ trợ cho KWorld/ADSTech Instant DVB-T USB2.0.
    Cảm ơn Joachim von Caron rất nhiều

2005-02-02
  - thêm hỗ trợ cho Hauppauge Win-TV Nova-T USB2

31-01-2005
  - không còn phát trực tuyến bị méo đối với các thiết bị USB1.1

13-01-2005

- đã chuyển pid_filter_table được phản chiếu trở lại dvb-dibusb
    phiên bản gần như hoạt động đầu tiên cho HanfTek UMT-010
    phát hiện ra rằng Yakumo/HAMA/Typhoon là tiền thân của HanfTek UMT-010

2005-01-10

- tái cấu trúc đã hoàn tất, bây giờ mọi thứ rất thú vị

- các vấn đề về bộ điều chỉnh đối với một số thiết bị kỳ lạ (thiết bị Artec T1 AN2235 đôi khi có một
    Bộ điều chỉnh Panasonic được lắp ráp). Tunerprobing được triển khai.
    Cảm ơn Gunnar Wittich rất nhiều.

29-12-2004

- sau nhiều ngày vật lộn với lỗi không trả lại URB nào được sửa.

26-12-2004

- tái cấu trúc trình điều khiển dibusb, chia thành các tệp riêng biệt
  - kích hoạt thăm dò i2c

06-12-2004

- khả năng thăm dò địa chỉ i2c demo
  - ID usb mới (Compro, Artec)

23-11-2004

- các thay đổi được hợp nhất từ DiB3000MC_ver2.1
  - sửa lại phần gỡ lỗi
  - khả năng cung cấp TS hoàn chỉnh cho USB2.0

21-11-2004

- phiên bản hoạt động đầu tiên của trình điều khiển lối vào dib3000mc/p.

2004-11-12

- bổ sung thêm các phím điều khiển từ xa. Cảm ơn Uwe Hanke.

07-11-2004

- thêm hỗ trợ điều khiển từ xa. Cảm ơn David Matthews.

05-11-2004

- thêm hỗ trợ cho các thiết bị mới (Grandtec/Avermedia/Artec)
  - đã hợp nhất các thay đổi của tôi (đối với dib3000mb/dibusb) với FE_REFACTORING, vì nó đã trở thành HEAD
  - có vẻ như đã chuyển điều khiển chuyển (bộ lọc pid, điều khiển fifo) từ trình điều khiển usb sang giao diện người dùng
    giải quyết tốt hơn ở đó (đã thêm xfer_ops-struct)
  - đã tạo một tệp chung cho giao diện người dùng (mc/p/mb)

28-09-2004

- thêm hỗ trợ cho thiết bị mới (Không xác định, ID nhà cung cấp là Hyper-Paltek)

20-09-2004

- đã thêm hỗ trợ cho thiết bị mới (Compro DVB-U2000), cảm ơn
    tới Amaury Demol để báo cáo
  - đã thay đổi phương thức truyền USB TS (một số urbs, dừng truyền
    trước khi thiết lập một pid mới)

13-09-2004

- đã thêm hỗ trợ cho thiết bị mới (Artec T1 USB TVBOX), cảm ơn
    tới Christian Motschke để báo cáo

2004-09-05

- phát hành thiết bị dibusb và trình điều khiển dib3000mb-frontend
    (tin cũ cho vp7041.c)

15-07-2004

- tình cờ phát hiện ra rằng thiết bị có TUA6010XS cho PLL

2004-07-12

- đã tìm ra rằng người lái xe cũng nên làm việc với
    CTS Portable (Hệ thống truyền hình Trung Quốc)

08-07-2004

- đã giải quyết được vấn đề về firmware-extraction-2.422, trình điều khiển hiện đang hoạt động
    đúng với firmware được trích xuất từ 2.422
  - #if cho 2.6.4 (dvb), vấn đề biên dịch
  - đã thay đổi cách xử lý phần sụn, xem vp7041.txt giây 1.1

2004-07-02

- một số sửa đổi bộ điều chỉnh, v0.1, dọn dẹp, công khai lần đầu

28-06-2004

- hiện đang sử dụng dvb_dmx_swfilter_packets, mọi thứ đều chạy tốt

27-06-2004

- có thể xem và chuyển kênh (pre-alpha)
  - chưa lọc phần nào

2004-06-06

- TS đầu tiên đã nhận được, nhưng kernel rất tiếc:/

14-05-2004

- trình tải firmware đang hoạt động

2004-05-11

- bắt đầu viết trình điều khiển

Làm thế nào để sử dụng?
-----------------------

Phần sụn
~~~~~~~~

Hầu hết trình điều khiển USB cần tải chương trình cơ sở về thiết bị trước khi bắt đầu
đang làm việc.

Hãy xem trang Wikipage về trình điều khiển DVB-USB để tìm hiểu phần sụn nào
bạn cần cho thiết bị của mình:

ZZ0000ZZ

Biên dịch
~~~~~~~~~

Vì trình điều khiển nằm trong nhân linux nên việc kích hoạt trình điều khiển trong
môi trường cấu hình yêu thích của bạn là đủ. tôi khuyên bạn nên
để biên dịch trình điều khiển dưới dạng mô-đun. Hotplug thực hiện phần còn lại.

Nếu bạn sử dụng dvb-kernel, hãy nhập thư mục build-2.6 chạy 'make' và 'insmod.sh
tải' sau đó.

Đang tải trình điều khiển
~~~~~~~~~~~~~~~~~~~~~~~~~

Hotplug có thể tải trình điều khiển khi cần thiết (vì bạn đã cắm
trong thiết bị).

Nếu bạn muốn bật đầu ra gỡ lỗi, bạn phải tải trình điều khiển theo cách thủ công và
từ bên trong kho cvs dvb-kernel.

trước tiên hãy xem mức độ gỡ lỗi hiện có:

.. code-block:: none

	# modinfo dvb-usb
	# modinfo dvb-usb-vp7045

	etc.

.. code-block:: none

	modprobe dvb-usb debug=<level>
	modprobe dvb-usb-vp7045 debug=<level>
	etc.

nên thực hiện thủ thuật này.

Khi trình điều khiển được tải thành công, tập tin phần sụn đã ở trong
đúng nơi và thiết bị được kết nối, "Power"-LED phải là
đã bật.

Tại thời điểm này, bạn sẽ có thể khởi động một ứng dụng có khả năng dvb. tôi đang sử dụng
(t|s)zap, mplayer và dvbscan để kiểm tra những điều cơ bản. VDR-xine cung cấp
kịch bản thử nghiệm dài hạn.

Các vấn đề và lỗi đã biết
-------------------------

- Không tháo thiết bị USB khi đang chạy ứng dụng DVB, hệ thống của bạn
  rất có thể sẽ phát điên hoặc chết.

Thêm hỗ trợ cho thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO

USB1.1 Giới hạn băng thông
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Rất nhiều thiết bị hiện được hỗ trợ là USB1.1 và do đó chúng có
băng thông tối đa khoảng 5-6 MBit/s khi được kết nối với trung tâm USB2.0.
Điều này là không đủ để nhận được luồng truyền tải hoàn chỉnh của một
Kênh DVB-T (khoảng 16 MBit/s). Thông thường đây không phải là một
vấn đề, nếu bạn chỉ muốn xem TV (điều này không áp dụng cho HDTV),
nhưng đang xem một kênh trong khi đang ghi một kênh khác trên cùng một kênh
tần số đơn giản là không hoạt động tốt. Điều này áp dụng cho tất cả USB1.1
Thiết bị DVB-T, không chỉ thiết bị dvb-usb)

Lỗi TS bị biến dạng do sử dụng thiết bị nhiều đã không còn nữa
chắc chắn. Tất cả các thiết bị dvb-usb tôi đang sử dụng (Twinhan, Kworld, DiBcom) đều
bây giờ đang hoạt động rất quyến rũ với VDR. Đôi khi tôi thậm chí còn có thể ghi lại một kênh
và xem cái khác.

Bình luận
~~~~~~~~~

Các bản vá, nhận xét và đề xuất đều rất được hoan nghênh.

3. Lời cảm ơn
-------------------

Amaury Demol (Amaury.Demol@parrot.com) và Francois Kanounnikoff từ DiBcom cho
   cung cấp thông số kỹ thuật, mã và trợ giúp, trên đó dvb-dibusb, dib3000mb và
   dib3000mc đều dựa trên.

David Matthews vì đã xác định loại thiết bị mới (Artec T1 với AN2235)
   và để mở rộng dibusb bằng cách xử lý sự kiện điều khiển từ xa. Cảm ơn.

Alex Woods vì đã thường xuyên giải đáp thắc mắc về usb và dvb
   công cụ, một lời cảm ơn lớn.

Bernd Wagner đã giúp đỡ trong việc báo cáo và thảo luận về các lỗi lớn.

Gunnar Wittich và Joachim von Caron vì sự tin tưởng của họ trong việc cung cấp
   root-shell trên máy của họ để triển khai hỗ trợ cho các thiết bị mới.

Allan Third và Michael Hutchinson vì sự giúp đỡ của họ trong việc viết Tinh vân
   trình điều khiển chữ số.

Glen Harris vì đã nêu lên rằng có một thiết bị dibusb mới và Jiun-Kuei
   Jung từ AVerMedia, người đã vui lòng cung cấp phần sụn đặc biệt để nhận thiết bị
   thiết lập và chạy trên Linux.

Jennifer Chen, Jeff và Jack từ Twinhan đã nhiệt tình hỗ trợ
   viết trình điều khiển vp7045.

Steve Chang từ WideView vì đã cung cấp thông tin cho các thiết bị mới và
   tập tin phần sụn.

Michael Paxton đã gửi sơ đồ bàn phím điều khiển từ xa.

Một số người trong danh sách gửi thư linux-dvb đã khuyến khích tôi.

Peter Schildmann >peter.schildmann-nospam-at-web.de< vì
   trình tải chương trình cơ sở ở cấp độ người dùng, giúp tiết kiệm rất nhiều thời gian
   (khi viết trình điều khiển vp7041)

Ulf Hermenau đã giúp tôi học tiếng Trung phồn thể.

André Smoktun và Christian Frömmel đã hỗ trợ tôi
   phần cứng và lắng nghe vấn đề của tôi rất kiên nhẫn.