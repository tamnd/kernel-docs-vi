.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/faq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

FAQ
===

.. note::

     1. With Digital TV, a single physical channel may have different
	contents inside it. The specs call each one as a *service*.
	This is what a TV user would call "channel". So, in order to
	avoid confusion, we're calling *transponders* as the physical
	channel on this FAQ, and *services* for the logical channel.
     2. The LinuxTV community maintains some Wiki pages with contain
        a lot of information related to the media subsystem. If you
        don't find an answer for your needs here, it is likely that
        you'll be able to get something useful there. It is hosted
	at:

	https://www.linuxtv.org/wiki/

Một số câu hỏi thường gặp về hỗ trợ Linux Digital TV

1. Tín hiệu dường như mất đi vài giây sau khi điều chỉnh.

Đó không phải là một lỗi, đó là một tính năng. Bởi vì giao diện người dùng có
	yêu cầu năng lượng đáng kể (và do đó rất nóng), chúng
	sẽ bị tắt nguồn nếu không được sử dụng (tức là nếu thiết bị giao diện người dùng
	đã đóng cửa). Tham số mô-đun ZZ0000ZZ ZZ0001ZZ
	cho phép bạn thay đổi thời gian chờ (mặc định là 5 giây). Thiết lập
	thời gian chờ về 0 sẽ vô hiệu hóa tính năng hết thời gian chờ.

2. Làm sao tôi có thể xem TV?

Cùng với nhân Linux, các nhà phát triển TV kỹ thuật số hỗ trợ
	một số tiện ích đơn giản chủ yếu nhằm mục đích thử nghiệm
	và để chứng minh cách DVB API hoạt động. Cái này được gọi là DVB v5
	công cụ và được nhóm cùng với kho git ZZ0000ZZ:

ZZ0000ZZ

Bạn có thể tìm thêm thông tin tại wiki LinuxTV:

ZZ0000ZZ

Bước đầu tiên là lấy danh sách các dịch vụ được truyền đi.

Điều này được thực hiện bằng cách sử dụng một số công cụ hiện có. Bạn có thể sử dụng
	ví dụ như công cụ ZZ0000ZZ. Bạn có thể tìm thêm thông tin
	về nó tại:

ZZ0000ZZ

Có một số ứng dụng khác như ZZ0000ZZ [#]_ thực hiện
	quét mù, cố gắng hết sức để tìm tất cả các kênh có thể, nhưng
	những thứ đó tiêu tốn một lượng lớn thời gian để chạy.

	.. [#] https://www.linuxtv.org/wiki/index.php/W_scan

Ngoài ra, một số ứng dụng như ZZ0000ZZ có mã riêng
	để quét các dịch vụ. Vì vậy, bạn không cần phải sử dụng bên ngoài
	đơn xin có được danh sách đó.

Hầu hết các công cụ như vậy cần một tệp chứa danh sách kênh
	bộ tiếp sóng có sẵn trên khu vực của bạn. Vì vậy, các nhà phát triển LinuxTV
	duy trì các bảng của bộ tiếp sóng kênh truyền hình kỹ thuật số, nhận
	các bản vá lỗi từ cộng đồng để cập nhật chúng.

Danh sách này được lưu trữ tại:

ZZ0000ZZ

Và được đóng gói trên một số bản phân phối.

Kaffeine có một số hỗ trợ quét mù cho một số tiêu chuẩn trên mặt đất.
	Nó cũng dựa trên các bảng quét DTV, mặc dù nó có chứa một bản sao
	của nó trong nội bộ (và, nếu người dùng yêu cầu, nó sẽ tải xuống
	phiên bản mới hơn của nó).

Nếu may mắn, bạn chỉ có thể sử dụng một trong các kênh được cung cấp
	bộ tiếp sóng. Nếu không, bạn có thể cần tìm kiếm thông tin đó tại
	Internet và tạo một tập tin mới. Có một số trang web với
	chứa danh sách kênh vật lý. Đối với cáp và vệ tinh, thông thường
	biết cách điều chỉnh vào một kênh duy nhất là đủ cho
	công cụ quét để xác định các kênh khác. Ở một số nơi,
	điều này cũng có thể áp dụng cho việc truyền tải trên mặt đất.

Khi bạn có danh sách bộ tiếp sóng, bạn cần tạo một dịch vụ
	list bằng công cụ như ZZ0000ZZ.

Hầu như tất cả các card TV kỹ thuật số hiện đại đều không có phần cứng tích hợp
	Bộ giải mã MPEG. Vì vậy, việc nhận MPEG-TS là tùy thuộc vào ứng dụng
	luồng do bo mạch cung cấp, chia nó thành âm thanh, video và các luồng khác
	dữ liệu và giải mã.

3. Ứng dụng truyền hình số nào tồn tại?

Một số ứng dụng trình phát đa phương tiện có khả năng điều chỉnh
	các kênh truyền hình kỹ thuật số, bao gồm Kaffeine, Vlc, mplayer và MythTV.

Kaffeine đặt mục tiêu rất thân thiện với người dùng và được duy trì
	bởi một trong những nhà phát triển trình điều khiển hạt nhân.

Bạn có thể tìm thấy danh sách đầy đủ các ứng dụng đó và các ứng dụng khác tại:

ZZ0000ZZ

Một số trong những cái phổ biến nhất được liên kết dưới đây:

ZZ0000ZZ
		Trình phát đa phương tiện KDE, tập trung vào hỗ trợ TV kỹ thuật số

ZZ0000ZZ
		Máy ghi đĩa video của Klaus Schmidinger

ZZ0001ZZ và ZZ0002ZZ
		Truyền hình kỹ thuật số và các ứng dụng liên quan đến phương tiện truyền thông khác và
		Trình điều khiển hạt nhân. Gói ZZ0000ZZ có chứa
		một số công cụ dao Thụy Sĩ để sử dụng với TV kỹ thuật số.

ZZ0000ZZ
		Gói dvbtools của Dave Chapman, bao gồm
		dvbstream và dvbtune

ZZ0000ZZ
		LinuxDVB trên dBox2

ZZ0000ZZ
		TuxBox CVS nhiều ứng dụng DVB thú vị và dBox2
		Nguồn DVB

ZZ0000ZZ
		MPSYS: thư viện và công cụ hệ thống MPEG2

ZZ0000ZZ
		vlc

ZZ0000ZZ
		MPlayer

ZZ0000ZZ và ZZ0001ZZ
		xine

ZZ0000ZZ
		MythTV - Truyền hình analog và truyền hình kỹ thuật số PVR

ZZ0000ZZ
		Chương trình sniffer DVB để giám sát, phân tích, gỡ lỗi, kết xuất
		hoặc xem thông tin luồng dvb/mpeg/dsm-cc/mhp (TS,
		PES, SECTION)

4. Không thể điều chỉnh tín hiệu chính xác

Đó có thể là do rất nhiều vấn đề. Theo kinh nghiệm cá nhân của tôi,
	thông thường card TV cần tín hiệu mạnh hơn TV và hơn thế nữa
	nhạy cảm với tiếng ồn. Vì vậy, có lẽ bạn chỉ cần một ăng-ten tốt hơn hoặc
	cáp. Tuy nhiên, nó cũng có thể là một số vấn đề về phần cứng hoặc trình điều khiển.

Ví dụ: nếu bạn đang sử dụng thẻ Technotrend/Hauppauge DVB-C
	Mô-đun tương tự ZZ0000ZZ, bạn có thể phải sử dụng tham số mô-đun
	adac=-1 (dvb-ttpci.o).

Vui lòng xem trang FAQ tại linuxtv.org, vì nó có thể chứa một số
	thông tin có giá trị:

ZZ0000ZZ

Nếu cách đó không hiệu quả, hãy kiểm tra kho lưu trữ ML linux-media để
	xem có ai khác gặp vấn đề tương tự với phần cứng của bạn không
	và/hoặc nhà cung cấp dịch vụ truyền hình kỹ thuật số:

ZZ0000ZZ

Nếu cách này không hiệu quả, bạn có thể thử gửi e-mail đến
	linux-media ML và xem liệu người khác có thể làm sáng tỏ điều gì không.
	Email là linux-media AT vger.kernel.org.

5. Thiết bị dvb_net không cung cấp cho tôi bất kỳ gói tin nào

Chạy ZZ0000ZZ trên giao diện ZZ0001ZZ. Điều này đặt giao diện
	sang chế độ lăng nhăng để nó chấp nhận mọi gói từ PID
	bạn đã cấu hình với tiện ích ZZ0002ZZ. Kiểm tra xem có
	có bất kỳ gói nào có địa chỉ IP và địa chỉ MAC mà bạn có không
	được định cấu hình với ZZ0003ZZ hoặc với ZZ0004ZZ.

Nếu ZZ0000ZZ không cung cấp cho bạn bất kỳ kết quả nào, hãy kiểm tra số liệu thống kê
	ZZ0001ZZ hoặc ZZ0002ZZ xuất ra. (Lưu ý: Nếu MAC
	địa chỉ sai, ZZ0003ZZ sẽ không nhận được bất kỳ thông tin đầu vào nào; do đó bạn phải
	chạy ZZ0004ZZ trước khi kiểm tra số liệu thống kê.) Nếu không có
	các gói thì có thể PID sai. Nếu có gói tin bị lỗi,
	thì PID sai hoặc luồng không tuân thủ
	tiêu chuẩn MPE (EN 301 192, ZZ0006ZZ Bạn có thể
	sử dụng ví dụ ZZ0005ZZ để gỡ lỗi.

6. Thiết bị ZZ0000ZZ không cung cấp cho tôi bất kỳ gói multicast nào

Kiểm tra các tuyến đường của bạn nếu chúng bao gồm phạm vi địa chỉ multicast.
	Ngoài ra, hãy đảm bảo rằng "xác thực nguồn bằng đường dẫn đảo ngược
	tra cứu" bị vô hiệu hóa::

$ "echo 0 > /proc/sys/net/ipv4/conf/dvb0/rp_filter"

7. Tất cả những mô-đun cần được tải là gì?

Để làm cho nó linh hoạt hơn và hỗ trợ các phần cứng khác nhau
	kết hợp, hệ thống con phương tiện được viết theo cách mô-đun.

Vì vậy, bên cạnh mô-đun phần cứng TV kỹ thuật số cho chipset chính,
	nó cũng cần tải trình điều khiển giao diện người dùng, cùng với TV kỹ thuật số
	cốt lõi. Nếu bo mạch cũng có bộ điều khiển từ xa, nó cũng sẽ
	cần lõi điều khiển từ xa và các bảng điều khiển từ xa.
	Điều tương tự cũng xảy ra nếu bo mạch hỗ trợ TV analog:
	hỗ trợ cốt lõi cho video4linux cần được tải.

Tên mô-đun thực tế là dành riêng cho phiên bản nhân Linux, như,
	theo thời gian, mọi thứ thay đổi, để làm cho phương tiện truyền thông
	hỗ trợ linh hoạt hơn.