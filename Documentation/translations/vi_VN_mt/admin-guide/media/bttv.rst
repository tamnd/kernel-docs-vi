.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/bttv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
tài xế bttv
===============

Ghi chú phát hành cho bttv
----------------------

Bạn sẽ cần ít nhất các tùy chọn cấu hình này cho bttv::

./scripts/config -e PCI
    ./scripts/config -m I2C
    ./scripts/config -m INPUT
    ./scripts/config -m MEDIA_SUPPORT
    ./scripts/config -e MEDIA_PCI_SUPPORT
    ./scripts/config -e MEDIA_ANALOG_TV_SUPPORT
    ./scripts/config -e MEDIA_DIGITAL_TV_SUPPORT
    ./scripts/config -e MEDIA_RADIO_SUPPORT
    ./scripts/config -e RC_CORE
    ./scripts/config -m VIDEO_BT848

Nếu bo mạch của bạn có TV kỹ thuật số, bạn cũng sẽ cần::

./scripts/config -m DVB_BT8XX

Trong trường hợp này, vui lòng xem Tài liệu/admin-guide/media/bt8xx.rst
để biết thêm ghi chú.

Làm cho bttv hoạt động với thẻ của bạn
-----------------------------

Nếu bạn đã biên dịch và cài đặt bttv, chỉ cần khởi động Kernel
là đủ để nó thử thăm dò nó. Tuy nhiên, tùy
trên mô hình, Kernel có thể yêu cầu thông tin bổ sung về
phần cứng, vì thiết bị có thể không cung cấp được thông tin đó
trực tiếp vào hạt nhân.

Nếu không, bttv có thể không tự động phát hiện thẻ của bạn và cần một số
tùy chọn insmod.  Tùy chọn insmod quan trọng nhất cho bttv là "card=n"
để chọn đúng loại thẻ.  Nếu bạn nhận được video nhưng không có âm thanh thì bạn đã
rất có thể đã chỉ định sai (hoặc không có) loại thẻ.  Danh sách được hỗ trợ
thẻ nằm trong Tài liệu/admin-guide/media/bttv-cardlist.rst.

Nếu bttv tải rất lâu (đôi khi xảy ra với các thiết bị giá rẻ
thẻ không có bộ dò sóng), hãy thử thêm phần này vào cấu hình mô-đun của bạn
tệp (thông thường, đó là ZZ0000ZZ hoặc một số tệp tại
ZZ0001ZZ, nhưng địa điểm thực tế phụ thuộc vào bạn
phân phối)::

tùy chọn i2c-algo-bit bit_test=1

Một số thẻ có thể yêu cầu tệp chương trình cơ sở bổ sung để hoạt động. Ví dụ,
đối với WinTV/PVR, bạn cần một tệp chương trình cơ sở từ CD trình điều khiển của nó,
được gọi là: ZZ0000ZZ. Nó nằm trong file zip tự giải nén
được gọi là ZZ0001ZZ.  Chỉ cần đặt nó ở ZZ0002ZZ
thư mục phải đủ để nó được tự động tải trong quá trình cài đặt trình điều khiển
chế độ thăm dò (ví dụ: khi Kernel khởi động hoặc khi trình điều khiển được
được tải thủ công thông qua lệnh ZZ0003ZZ).

Nếu thẻ của bạn không được liệt kê trong Documentation/admin-guide/media/bttv-cardlist.rst
hoặc nếu bạn gặp khó khăn khi thực hiện âm thanh, vui lòng đọc ZZ0000ZZ.


Tự động phát hiện thẻ
-------------------

bttv sử dụng ID hệ thống con PCI để tự động phát hiện loại thẻ.  danh sách lspci
ID hệ thống con ở dòng thứ hai trông như thế này:

.. code-block:: none

	00:0a.0 Multimedia video controller: Brooktree Corporation Bt878 (rev 02)
		Subsystem: Hauppauge computer works Inc. WinTV/GO
		Flags: bus master, medium devsel, latency 32, IRQ 5
		Memory at e2000000 (32-bit, prefetchable) [size=4K]

chỉ các thẻ dựa trên bt878 mới có thể có ID hệ thống con (điều đó không có nghĩa là
rằng mỗi thẻ thực sự có một).  Thẻ bt848 không thể có Hệ thống con
ID và do đó không thể được tự động phát hiện.  Có một danh sách có ID
tại Tài liệu/admin-guide/media/bttv-cardlist.rst
(trong trường hợp bạn quan tâm hoặc muốn gửi các bản vá có bản cập nhật qua thư).


.. _still_doesnt_work:

Vẫn không hoạt động?
-------------------

Tôi có NOT có một phòng thí nghiệm với hơn 30 bảng kẹp khác nhau và một
Bộ tạo tín hiệu thử nghiệm PAL/NTSC/SECAM tại nhà nên tôi thường không thể
tái tạo vấn đề của bạn.  Điều này làm cho việc gỡ lỗi rất khó khăn đối với tôi.

Nếu bạn có chút kiến thức và thời gian rảnh hãy thử khắc phục lỗi này nhé
chính bạn (tất nhiên là rất hoan nghênh các bản vá...) Bạn biết đấy: Linux
khẩu hiệu là "Tự mình làm".

Có một danh sách gửi thư tại
ZZ0000ZZ

Nếu bạn gặp sự cố với một số card TV cụ thể, hãy thử hỏi ở đó
thay vì gửi thư trực tiếp cho tôi.  Cơ hội mà ai đó có
cùng một thẻ nghe có cao hơn nhiều ...

Đối với vấn đề về âm thanh: Có rất nhiều hệ thống khác nhau được sử dụng
cho âm thanh TV trên toàn thế giới.  Và cũng có nhiều loại chip khác nhau
giải mã tín hiệu âm thanh.  Báo cáo về vấn đề âm thanh ("âm thanh nổi
không hoạt động") khá vô dụng trừ khi bạn đưa vào một số chi tiết
về phần cứng của bạn và sơ đồ âm thanh TV được sử dụng ở quốc gia của bạn (hoặc
ít nhất là quốc gia bạn đang sống).

Tùy chọn modprobe
----------------

.. note::


   The following argument list can be outdated, as we might add more
   options if ever needed. In case of doubt, please check with
   ``modinfo <module>``.

   This command prints various information about a kernel
   module, among them a complete and up-to-date list of insmod options.



bttv
	Trình điều khiển bt848/878 (chip Grabber)

insmod lập luận::

card=n loại thẻ, xem CARDLIST để biết danh sách.
	    tuner=n loại bộ điều chỉnh, xem CARDLIST để biết danh sách.
	    radio=0/1 thẻ hỗ trợ radio
	    pll=0/1/2 pll cài đặt

0: không sử dụng PLL
			    1: 28 MHz tinh thể được cài đặt
			    2: Đã cài đặt tinh thể 35 MHz

triton1=0/1 để tương thích với Triton1 (+khác)
	    vsfx=0/1 một bit tương thích lỗi chipset khác
			    xem README.quirks để biết chi tiết về hai điều này.

bigendian=n Đặt độ cuối của bộ đệm khung gfx.
			    Mặc định là endian gốc.
	    fieldnr=0/1 Đếm các trường.  Một số phần mềm giải mã tivi
			    cần điều này, đối với những người khác nó chỉ tạo ra
			    50 IRQ vô dụng/giây.  mặc định là 0 (tắt).
	    autoload=0/1 mô-đun trợ giúp tự động tải (bộ chỉnh âm, âm thanh).
			    mặc định là 1 (bật).
	    bttv_verbose=0/1/2 mức độ chi tiết (tại thời điểm hiện tại, trong khi
			    nhìn vào phần cứng).  mặc định là 1.
	    bttv_debug=0/1 thông báo gỡ lỗi (để chụp).
			    mặc định là 0 (tắt).
	    irq_debug=0/1 thông báo gỡ lỗi trình xử lý irq.
			    mặc định là 0 (tắt).
	    gbuffers=2-32 số lượng bộ đệm chụp để chụp trong mmap.
			    mặc định là 4.
	    gbufsize= kích thước của bộ đệm chụp. mặc định và
			    giá trị tối đa là 0x208000 (~2MB)
	    no_overlay=0 Bật lớp phủ trên phần cứng bị hỏng.  Ở đó
			    là một số chipset (ví dụ SIS)
			    được biết là có vấn đề với PCI DMA
			    đẩy được sử dụng bởi bttv.  bttv sẽ vô hiệu hóa lớp phủ
			    theo mặc định trên phần cứng này để tránh sự cố.
			    Với tùy chọn insmod này, bạn có thể ghi đè lên tùy chọn này.
	    no_overlay=1 Tắt lớp phủ. Nó nên được sử dụng bởi bị hỏng
			    phần cứng không hỗ trợ trực tiếp PCI2PCI
			    chuyển khoản.
	    automute=0/1 Tự động tắt âm thanh nếu có
			    không có tín hiệu TV, bật theo mặc định.  Bạn có thể thử
			    để tắt tính năng này nếu bạn có tín hiệu đầu vào kém
			    chất lượng dẫn đến âm thanh không mong muốn
			    bỏ học.
	    chroma_agc=0/1 AGC của tín hiệu sắc độ, tắt theo mặc định.
	    adc_crush=0/1 Luminance ADC crush, được bật theo mặc định.
	    i2c_udelay= Cho phép giảm tốc độ I2C. Mặc định là 5 usec
			    (nghĩa là 66,67 Kbps). Mặc định là
			    tốc độ được hỗ trợ tối đa bởi kernel bitbang
			    thuật toán. Bạn có thể sử dụng số thấp hơn nếu I2C
			    tin nhắn bị mất (16 tin nhắn được biết là hoạt động trên
			    tất cả các thẻ được hỗ trợ).

bttv_gpio=0/1
	    gpiomask=
	    âm thanh=
	    audiomux=
			    Xem Sound-FAQ để biết mô tả chi tiết.

ánh xạ lại, thẻ, radio và pll chấp nhận tối đa bốn đối số được phân tách bằng dấu phẩy
	(đối với nhiều bảng).

bộ chỉnh âm
	Trình điều khiển bộ chỉnh.  Bạn cần điều này trừ khi bạn chỉ muốn sử dụng
	với máy ảnh hoặc bo mạch không cung cấp khả năng điều chỉnh TV analog.

insmod lập luận::

debug=1 in một số thông tin gỡ lỗi vào nhật ký hệ thống
		type=n loại chip điều chỉnh. n như sau:
				xem CARDLIST để biết danh sách đầy đủ.
		pal=[bdgil] chọn biến thể PAL (được sử dụng cho một số bộ chỉnh
				chỉ, quan trọng đối với nhà cung cấp âm thanh).

tvaudio
	Cung cấp một trình điều khiển duy nhất cho tất cả các điều khiển âm thanh i2c đơn giản
	khoai tây chiên (tda/trà*).

insmod lập luận::

tda8425 = 1 bật/tắt hỗ trợ cho
		tda9840 = 1 loại chip khác nhau.
		tda9850 = 1 Tea6300 không thể được tự động phát hiện và được
		tda9855 = 1 do đó tắt theo mặc định, nếu bạn có
		tda9873 = 1 cái này trên thẻ của bạn (STB sử dụng những cái này)
		tda9874a = 1 bạn phải kích hoạt nó một cách rõ ràng.
		tea6300 = 0 Hai chip tda985x dùng chung i2c
		trà6420 = 1 địa chỉ và không thể tách ra khỏi
		pic16c54 = 1 nhau, có thể bạn phải tắt
				cái sai.
		debug = 1 in thông báo gỡ lỗi

msp3400
	Trình điều khiển cho chip xử lý âm thanh msp34xx. Nếu bạn có một
	card âm thanh nổi, có thể bạn muốn cài đặt cái này.

insmod lập luận::

debug=1/2 in một số thông tin gỡ lỗi vào nhật ký hệ thống,
				2 dài dòng hơn.
		simple=1 Sử dụng phương pháp "lập trình ngắn".  Mới hơn
				phiên bản msp34xx hỗ trợ điều này.  Bạn cần cái này
				cho âm thanh nổi dbx.  Mặc định là bật nếu được hỗ trợ bởi
				con chip.
		một lần=1 Không kiểm tra chế độ âm thanh của đài truyền hình
				cứ sau vài giây, nhưng chỉ một lần sau đó
				các chuyển mạch kênh.
		amsound=1 Sóng mang âm thanh là AM/NICAM ở tần số 6,5 Mhz.  Cái này
				nên cải thiện mọi thứ cho người dân Pháp,
				tính năng tự động quét của nhà cung cấp dịch vụ dường như chỉ hoạt động với FM...

Nếu hộp đóng băng cứng với bttv
---------------------------------

Nó có thể là một lỗi trình điều khiển bttv.  Nó cũng có thể là phần cứng xấu.  Nó cũng
có thể là cái gì khác...

Chỉ gửi thư cho tôi "bttv đóng băng" sẽ không giúp được gì nhiều.  README này
có một số gợi ý về cách bạn có thể giúp giải quyết vấn đề.


lỗi bttv
~~~~~~~~~

Nếu một số phiên bản hoạt động còn phiên bản khác thì không, rất có thể đó là trình điều khiển
lỗi.  Sẽ rất hữu ích nếu bạn có thể biết chính xác nó bị hỏng ở đâu
(tức là phiên bản hoạt động cuối cùng và phiên bản bị hỏng đầu tiên).

Với việc đóng băng cứng, bạn có thể không tìm thấy bất kỳ thứ gì trong tệp nhật ký.
Cách duy nhất để nắm bắt bất kỳ thông báo kernel nào là kết nối một serial
console và để một số ứng dụng đầu cuối ghi lại các tin nhắn.  /tôi sử dụng
màn hình.  Xem Tài liệu/admin-guide/serial-console.rst để biết chi tiết về
thiết lập một bảng điều khiển nối tiếp.

Đọc Tài liệu/admin-guide/bug-hunting.rst để tìm hiểu cách nhận được bất kỳ thông tin hữu ích nào
thông tin ra khỏi một thanh ghi + kết xuất ngăn xếp được in bởi kernel trên
lỗi bảo vệ (còn gọi là "lỗi hạt nhân").

Nếu bạn gặp phải một số loại bế tắc, bạn có thể thử bỏ dấu vết cuộc gọi
cho mỗi quy trình sử dụng sysrq-t (xem Tài liệu/admin-guide/sysrq.rst).
Bằng cách này, có thể tìm ra nơi ZZ0000ZZ có một số quy trình trong "D"
trạng thái bị mắc kẹt.

Tôi đã thấy các báo cáo rằng bttv 0.7.x gặp sự cố trong khi 0.8.x hoạt động ổn định
đối với một số người.  Vì vậy có lẽ một chiếc buglet nhỏ còn sót lại ở đâu đó trong bttv
0.7.x.  Tôi không biết chính xác ở đâu, nó hoạt động ổn định đối với tôi và rất nhiều người.
những người khác.  Nhưng trong trường hợp bạn gặp vấn đề với phiên bản 0.7.x, bạn
có thể thử 0,8.x ...


lỗi phần cứng
~~~~~~~~~~~~~

Một số phần cứng không thể xử lý việc truyền PCI-PCI (tức là Grabber => vga).
Đôi khi vấn đề xuất hiện với bttv chỉ vì tải quá cao
xe buýt PCI. Các chip bt848/878 có một số cách giải quyết đã biết
sự không tương thích, xem README.quirks.

Một số người báo cáo rằng việc tăng độ trễ pci cũng có ích,
cho đến nay tôi không chắc chắn khi nào điều này thực sự khắc phục được vấn đề hoặc
chỉ làm cho nó ít có khả năng xảy ra hơn.  Cả bttv và btaudio đều có
tùy chọn insmod để đặt độ trễ PCI của thiết bị.

Một số mainboard có vấn đề để xử lý chính xác với nhiều thiết bị
làm DMA cùng một lúc.  bttv + ide đôi khi có vẻ gây ra điều này,
nếu đây là trường hợp bạn có thể chỉ thấy tình trạng treo video và đĩa cứng
truy cập cùng một lúc.  Cập nhật trình điều khiển IDE để có phiên bản mới nhất và
cách giải quyết tốt nhất cho các lỗi phần cứng có thể khắc phục được những sự cố này.


khác
~~~~~

Nếu bạn sử dụng một số yink chỉ nhị phân (như mô-đun nvidia), hãy thử sao chép
vấn đề mà không có.

Chia sẻ IRQ được biết là gây ra sự cố trong một số trường hợp.  Nó hoạt động chỉ
ổn về mặt lý thuyết và nhiều cấu hình.  Dù thế nào đi nữa nó vẫn có giá trị
cố gắng xáo trộn các thẻ PCI để trao cho bttv một IRQ khác hoặc tạo
nó chia sẻ IRQ với một số phần cứng khác.  Chia sẻ IRQ với
Thẻ VGA đôi khi có vẻ gây rắc rối.  Tôi cũng thấy buồn cười
hiệu ứng với bttv chia sẻ IRQ với cầu ACPI (và
hạt nhân hỗ trợ apci).

những điều kỳ quặc của Bttv
-----------

Dưới đây là những gì cuốn sách dữ liệu bt878 nói về khả năng tương thích lỗi PCI
các chế độ của chip bt878.

Tùy chọn insmod triton1 đặt bit EN_TBFX trong thanh ghi điều khiển.
Tùy chọn insmod vsfx thực hiện tương tự đối với bit EN_VSFX.  Nếu bạn có
vấn đề về độ ổn định bạn có thể thử nếu một trong các tùy chọn này làm cho hộp của bạn
làm việc vững chắc.

driver/pci/quirks.c biết về những vấn đề này, theo cách này, các bit này được
được bật tự động cho các chipset có lỗi đã biết (xem kernel
tin nhắn, bttv nói với bạn).

Chế độ PCI bình thường
~~~~~~~~~~~~~~~

Tín hiệu PCI REQ là tín hiệu logic hoặc của các yêu cầu chức năng đến.
Các tín hiệu GNT[0:1] bên trong được kiểm soát không đồng bộ với GNT và
được tách kênh bằng tín hiệu yêu cầu âm thanh. Vì vậy, trọng tài mặc định
chức năng video khi bật nguồn và dừng ở đó khi không có yêu cầu
truy cập xe buýt. Điều này là mong muốn vì video sẽ yêu cầu xe buýt nhiều hơn
thường xuyên. Tuy nhiên, âm thanh sẽ có mức độ ưu tiên truy cập xe buýt cao nhất. Như vậy
âm thanh sẽ có quyền truy cập đầu tiên vào xe buýt ngay cả khi đưa ra yêu cầu
sau yêu cầu video nhưng trước khi trọng tài bên ngoài PCI chấp thuận
truy cập vào Bt879. Không chức năng nào có thể chiếm trước chức năng kia một lần trên
xe buýt. Thời lượng để làm trống toàn bộ video PCI FIFO trên bus PCI là
rất ngắn so với độ trễ truy cập xe buýt, âm thanh PCI FIFO có thể
chịu đựng.


Chế độ tương thích 430FX
~~~~~~~~~~~~~~~~~~~~~~~~

Khi sử dụng 430FX PCI, các quy tắc sau sẽ đảm bảo
khả năng tương thích:

(1) Xác nhận lại REQ cùng lúc với xác nhận FRAME.
 (2) Không xác nhận lại REQ để yêu cầu giao dịch xe buýt khác cho đến sau
     kết thúc giao dịch trước đó

Vì các chủ xe buýt riêng lẻ không có quyền kiểm soát trực tiếp REQ, nên
các yêu cầu logic-hoặc âm thanh đơn giản sẽ vi phạm các quy tắc.
Do đó, cả trọng tài và người khởi xướng đều có khả năng tương thích 430FX
logic chế độ. Để bật chế độ 430FX, hãy đặt bit EN_TBFX như được chỉ ra trong
Đăng ký điều khiển thiết bị ở trang 104.

Khi EN_TBFX được bật, trọng tài đảm bảo rằng cả hai tính tương thích
quy tắc được thỏa mãn. Trước khi GNT được trọng tài PCI xác nhận, điều này
trọng tài nội bộ vẫn có thể hợp lý-hoặc hai yêu cầu. Tuy nhiên, một lần
GNT được phát hành, trọng tài này phải chốt quyết định của mình và bây giờ định tuyến
chỉ yêu cầu được chấp nhận đối với chân REQ. Khóa quyết định của trọng tài
xảy ra bất kể trạng thái của FRAME vì nó không biết khi nào
FRAME sẽ được xác nhận (thông thường - mỗi người khởi tạo sẽ xác nhận FRAME trên
chu trình sau GNT). Khi FRAME được xác nhận, đó là điểm khởi tạo
có trách nhiệm loại bỏ yêu cầu của mình cùng một lúc. Đó là
trọng tài có trách nhiệm cho phép yêu cầu này được chuyển tới REQ và
không cho phép yêu cầu khác giữ REQ được xác nhận. Khóa quyết định có thể
sẽ bị xóa khi kết thúc giao dịch: ví dụ: khi xe buýt
nhàn rỗi (FRAME và IRDY). Quyết định của trọng tài sau đó có thể tiếp tục
không đồng bộ cho đến khi GNT được xác nhận lại.


Giao tiếp với logic lõi không tuân thủ PCI 2.1
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một tỷ lệ nhỏ thiết bị logic lõi có thể bắt đầu giao dịch bus
trong cùng chu kỳ mà GNT bị hủy xác nhận. Đây không phải là PCI 2.1
tuân thủ. Để đảm bảo khả năng tương thích khi sử dụng PC với các PCI này
bộ điều khiển, bit EN_VSFX phải được bật (tham khảo Điều khiển thiết bị
Đăng ký ở trang 104). Khi ở chế độ này, trọng tài không vượt qua GNT
tới các chức năng bên trong trừ khi REQ được xác nhận. Điều này ngăn chặn một chiếc xe buýt
giao dịch bắt đầu cùng chu kỳ với GNT bị hủy xác nhận. Cái này
cũng có tác dụng phụ là không tận dụng được xe buýt
đậu xe, do đó làm giảm hiệu suất trọng tài. Trình điều khiển Bt879 phải
truy vấn các thiết bị không tuân thủ này và chỉ đặt bit EN_VSFX nếu
được yêu cầu.


Các phần tử khác của mảng tvcards
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn đang cố gắng làm cho một tấm thẻ mới hoạt động được thì bạn có thể thấy nó hữu ích
biết các phần tử khác trong mảng tvcards có tác dụng gì::

video_inputs - Đầu vào video # of mà thẻ có
	audio_inputs - hành trình lịch sử, không được sử dụng nữa.
	bộ chỉnh âm - đầu vào nào là bộ chỉnh âm
	svhs - đầu vào nào là svhs (tất cả những cái khác được gắn nhãn tổng hợp)
	muxsel - mux video, đầu vào->ánh xạ giá trị đăng ký
	pll - giống như tùy chọn pll= insmod
	tuner_type - giống như tùy chọn tuner= insmod
	*_modulename - gợi ý bất cứ khi nào một số thẻ cần âm thanh này hoặc âm thanh kia
			mô-đun được tải để hoạt động bình thường.
	has_radio - bất cứ khi nào card TV này có bộ thu sóng radio.
	no_msp34xx - "1" tắt tải mô-đun msp3400.o
	no_tda9875 - "1" tắt tải mô-đun tda9875.o
	Need_tvaudio - đặt thành "1" để tải mô-đun tvaudio.o

Nếu một số mục cấu hình được chỉ định cả từ mảng tvcards và dưới dạng
tùy chọn insmod, tùy chọn insmod được ưu tiên.

Thẻ
-----

.. note::

   For a more updated list, please check
   https://linuxtv.org/wiki/index.php/Hardware_Device_Information

Thẻ được hỗ trợ: Thẻ Bt848/Bt848a/Bt849/Bt878/Bt879
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tất cả các thẻ có Bt848/Bt848a/Bt849/Bt878/Bt879 và bình thường
Hỗ trợ đầu vào tổng hợp/S-VHS.  Hỗ trợ Teletext và Intercast
(chỉ PAL) cho thẻ ALL thông qua giải mã mẫu VBI trong phần mềm.

Một số thẻ có thêm tính năng ghép kênh đầu vào hoặc các tính năng bổ sung khác
chip ưa thích chỉ được hỗ trợ một phần (trừ khi thông số kỹ thuật của
nhà sản xuất thẻ được đưa ra).  Khi một thẻ được liệt kê ở đây thì không phải vậy
nhất thiết phải được hỗ trợ đầy đủ.

Tất cả các thẻ khác chỉ khác nhau ở các thành phần bổ sung như bộ chỉnh, âm thanh
bộ giải mã, EEPROM, bộ giải mã teletext ...


Tầm nhìn MATRIX
~~~~~~~~~~~~~

MV-Delta
- Bt848A
- 4 đầu vào tổng hợp, 1 đầu vào S-VHS (chia sẻ với tổng hợp thứ 4)
-EEPROM

ZZ0000ZZ

Thẻ này không có bộ chỉnh nhưng hỗ trợ cả 4 composite (1 chia sẻ với một
Đầu vào S-VHS) của Bt848A.
Thẻ rất đẹp nếu bạn chỉ có truyền hình vệ tinh nhưng đã kết nối một số bộ dò sóng
vào thẻ thông qua composite.

Rất cám ơn Matrix-Vision đã tặng chúng tôi 2 thẻ miễn phí.
Có thể hỗ trợ vận hành đơn tinh thể Bt848a/Bt849!!!



Miro/Đỉnh cao PCTV
~~~~~~~~~~~~~~~~~~

- Bt848
  một số (tất cả??) đi kèm với 2 tinh thể cho PAL/SECAM và NTSC
- Bộ điều chỉnh TV PAL, SECAM hoặc NTSC (Philips hoặc TEMIC)
- Bộ giải mã âm thanh MSP34xx được tích hợp sẵn trên bo mạch
  bộ giải mã được hỗ trợ nhưng AFAIK chưa hoạt động
  (cần cài đặt âm thanh MUX khác trong cổng GPIO ??? ai đó đã sửa lỗi này ???)
- 1 bộ chỉnh tần, 1 đầu vào tổng hợp và 1 đầu vào S-VHS
- loại bộ chỉnh được tự động phát hiện

ZZ0000ZZ
ZZ0001ZZ


Cảm ơn rất nhiều vì thẻ miễn phí đã hỗ trợ NTSC lần đầu tiên
vào năm 1997!


Hauppauge Win/TV pci
~~~~~~~~~~~~~~~~~~~~

Có nhiều phiên bản khác nhau của các lá bài Hauppauge với các đặc điểm khác nhau.
bộ điều chỉnh (TV+Radio ...), bộ giải mã teletext.
Lưu ý rằng ngay cả những thẻ có cùng số kiểu máy cũng có (tùy thuộc vào phiên bản)
chip khác nhau trên đó.

- Bt848 (và những loại khác nhưng luôn hoạt động ở chế độ 2 pha lê ???)
  thẻ mới hơn có Bt878

- PAL, SECAM, NTSC hoặc bộ chỉnh tần có hoặc không có hỗ trợ Radio

ví dụ.:

-PAL:

- TDA5737: VHF, hyperband và bộ trộn/dao động UHF cho TV và bộ điều chỉnh 3 băng tần VCR
  - TSA5522: Bộ tổng hợp điều khiển I2C-bus 1,4 GHz, I2C 0xc2-0xc3

-NTSC:

- TDA5731: VHF, hyperband và bộ trộn/dao động UHF cho TV và bộ điều chỉnh 3 băng tần VCR
  - TSA5518: không có bảng dữ liệu trên trang web của Philips

- Chip giải mã Teletext Philips SAA5246 hoặc SAA5284 (hoặc không)
  với bộ đệm RAM (ví dụ: Winbond W24257AS-35: 32Kx8 CMOS tĩnh RAM)
  Hỗ trợ SAA5246 (I2C 0x22)

- 256 byte EEPROM: Microchip 24LC02B hoặc Philips 8582E2Y
  có thông tin cấu hình
  Địa chỉ I2C 0xa0 (24LC02B cũng đáp ứng 0xa2-0xaf)

- 1 bộ chỉnh tần, 1 bộ tổng hợp và (tùy theo kiểu máy) 1 đầu vào S-VHS

- 14052B: mux để chọn nguồn âm thanh

- bộ giải mã âm thanh: TDA9800, MSP34xx (card âm thanh nổi)


Askey CPH-Dòng
~~~~~~~~~~~~~~~~
Được phát triển bởi TelSignal(?), OEMed bởi nhiều nhà cung cấp (Typhoon, Anubis, Dynalink)

- Dòng thẻ:
  - CPH01x: Chỉ chụp BT848
  - CPH03x: BT848
  - CPH05x: BT878 có FM
  - CPH06x: BT878 (không có FM)
  - CPH07x: Chỉ chụp BT878

- Tiêu chuẩn truyền hình:
  - CPH0x0: NTSC-M/M
  - CPH0x1: PAL-B/G
  - CPH0x2: PAL-I/I
  - CPH0x3: PAL-D/K
  - CPH0x4: SECAM-L/L
  - CPH0x5: SECAM-B/G
  - CPH0x6: SECAM-D/K
  - CPH0x7: PAL-N/N
  -CPH0x8: PAL-B/H
  - CPH0x9: PAL-M/M

- CPH03x thường được bán với tên gọi "TV capture".

Xác định:

#) 878 thẻ có thể được xác định bằng ID hệ thống con PCI:
     - 144f:3000 = CPH06x
     - 144F:3002 = CPH05x có FM
     - 144F:3005 = CPH06x_LC (không có điều khiển từ xa)
  #) Thẻ có nhãn dán kiểu "CPH" ở mặt sau.
  #) Các thẻ này có in số trên PCB ngay phía trên hộp kim loại bắt sóng:
     - "80-CP2000300-x" = CPH03X
     - "80-CP2000500-x" = CPH05X
     - "80-CP2000600-x" = CPH06X/CPH06x_LC

Askey bán các thẻ này với tên gọi "Dòng Magic TView", Thương hiệu "MagicXpress".
  OEM khác thường gọi đây là "Tview", "TView99" hoặc cách khác.

Dòng sản phẩm Flyvideo của Lifeview:
~~~~~~~~~~~~~~~~~~~~~~~~~

Việc đặt tên cho những bộ truyện này khác nhau về thời gian và không gian.

Xác định:
  #) Một số kiểu máy có thể được xác định bằng ID hệ thống con PCI:

- 1852:1852 = Flyvideo 98 FM
     - 1851:1850 = Flyvideo 98
     - 1851:1851 = Flyvideo 98 EZ (chỉ quay)

#) Có một bản in trên PCB:

- LR25 = Flyvideo (Zoran ZR36120, SAA7110A)
     - LR26 Rev.N = Flyvideo II (Bt848)
     - LR26 Rev.O = Flyvideo II (Bt878)
     - LR37 Rev.C = Flyvideo EZ (Chỉ chụp, ZR36120 + SAA7110)
     - LR38 Rev.A1= Flyvideo II EZ (chỉ chụp Bt848)
     - LR50 Rev.Q = Flyvideo 98 (có eeprom và ID hệ thống con PCI)
     - LR50 Rev.W = Flyvideo 98 (không có eeprom)
     - LR51 Rev.E = Flyvideo 98 EZ (chỉ quay)
     - LR90 = Flyvideo 2000 (Bt878)
     - LR90 Flyvideo 2000S (Bt878) w/Stereo TV (Gói bao gồm bo mạch con LR91)
     - LR91 = Thẻ con gái âm thanh nổi cho LR90
     - LR97 = Flyvideo DVBS
     - LR99 Rev.E = Card cấu hình thấp để tích hợp OEM (chỉ âm thanh bên trong!) bt878
     - LR136 = Flyvideo 2100/3100 (Cấu hình thấp, SAA7130/SAA7134)
     - LR137 = Flyvideo DV2000/DV3000 (SAA7130/SAA7134 + IEEE1394)
     - LR138 Rev.C= Flyvideo 2000 (SAA7130)
     - LR138 Flyvideo 3000 (SAA7134) có TV âm thanh nổi

- Chúng tồn tại dưới dạng các biến thể w/FM và w/Remote đôi khi được ký hiệu
	  bởi hậu tố "FM" và "R".

#) Bạn có laptop (thẻ miniPCI):

- Sản phẩm = FlyTV Platinum Mini
      - Model/Chip = LR212/saa7135

- Lifeview.com.tw tuyên bố (tháng 2 năm 2002):
        "Tên sản phẩm FlyVideo2000 và FlyVideo2000s đã được đổi tên thành FlyVideo98."
        Thẻ Bt8x8 của họ được liệt kê là đã ngừng sản xuất.
      - Flyvideo 2000S có lẽ đã được bán dưới tên Flyvideo 3000 ở một số quốc gia (Châu Âu?).
        Flyvideo 2000/3000 mới dựa trên SAA7130/SAA7134.

"Flyvideo II" ngày nay là tên của 848 thẻ (ở Đức)
tên này được sử dụng lại cho LR50 Rev.W.

Trang web Lifeview đã có lúc đề cập đến Flyvideo III, nhưng một thẻ như vậy
vẫn chưa được nhìn thấy (có lẽ đó là tên tiếng Đức của LR90 [âm thanh nổi]).
Những thẻ này cũng được bán bởi nhiều OEM.

FlyVideo A2 (Elta 8680)= LR90 Rev.F (có Điều khiển từ xa, không có FM, TV âm thanh nổi của tda9821) {Đức}

Lifeview 3000 (Elta 8681) được bán bởi Plus(tháng 4 năm 2002), Đức = LR138 w/ saa7134

mã hóa cấu hình lifeview trên chân gpio 0-9
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Phiên bản LR50. Q ("PARTS: 7031505116), Bộ điều chỉnh wurde als Nr. 5 erkannt, Eingänge
  SVideo, TV, Composite, Âm thanh, Điều khiển từ xa:

- CP9..1=100001001 (1: 0-Ohm-Widerstand gegen GND unbestückt; 0: bestückt)


Dòng thẻ Typhoon TV:
~~~~~~~~~~~~~~~~~~~~~~~

Đây có thể là dòng CPH, Flyvideo, Pixelview hoặc KNC1.

Typhoon là thương hiệu của Anubis.

Model 50680 đã được sử dụng lại, một số model no. có nội dung khác nhau theo thời gian.

Mô hình:

- 50680 "TV Tuner PCI Pal BG"(cũ,gói màu đỏ)=có thể là CPH03x(bt848) hoặc CPH06x(bt878)
  - 50680 "TV Tuner Pal BG" (gói màu xanh)= Pixelview PV-BT878P+ (Rev 9B)
  - 50681 "TV Tuner PCI Pal I" (biến thể 50680)
  - 50682 "TView TV/FM Tuner Pal BG" = Flyvideo 98FM (LR50 Rev.Q)

  .. note::

Gói hàng có hình ảnh CPH05x (có thể là TView thật)

- 50683 "Bộ điều chỉnh TV PCI SECAM" (biến thể 50680)
  - 50684 "TV Tuner Pal BG" = Pixelview 878TV(Rev.3D)
  - 50686 "Bộ thu sóng TV" = Đài truyền hình KNC1
  - 50687 "TV Tuner stereo" = KNC1 Đài truyền hình chuyên nghiệp
  - 50688 "TV Tuner RDS" (gói màu đen) = KNC1 Đài truyền hình RDS
  - 50689 Tivi SAT DVB-S CARD CI PCI (SAA7146AH, SU1278?) = "KNC1 Đài Truyền Hình DVB-S"
  - 50692 "Bộ thu sóng TV/FM" (PCB nhỏ)
  - Tivi 50694 TUNER CARD RDS (PHILIPS CHIPSET SAA7134HL)
  - Tivi 50696 TUNER STEREO (PHILIPS CHIPSET SAA7134HL, MK3ME Tuner)
  - 50804 PC-SAT TV/Audio Karte = Techni-PC-Sat (ZORAN 36120PQC, Bộ dò:Alps)
  - 50866 TVIEW SAT RECEIVER+ADR
  - 50868 "Bộ điều chỉnh TV/FM Pal I" (biến thể của 50682)
  - 50999 "Bộ điều chỉnh TV/FM Secam" (biến thể của 50682)

Guillemot
~~~~~~~~~

Mô hình:

- Tivi Maxi PCI (ZR36120)
- Video Maxi TV 2 = LR50 Rev.Q (FI1216MF, PAL BG+SECAM)
- Video Maxi Tivi 3 = CPH064 (PAL BG + SECAM)

Người hướng dẫn
~~~~~~

Card Mentor TV ("55-878TV-U1") = Pixelview 878TV(Rev.3F) (có FM w/Điều khiển từ xa)

Prolink
~~~~~~~

- Card truyền hình:

- PixelView Play TV pro - (Model: PV-BT878P+ REV 8E)
  - PixelView Play TV pro - (Model: PV-BT878P+ REV 9D)
  - PixelView Play TV pro - (Model: PV-BT878P+ REV 4C / 8D / 10A )
  - PixelView Play TV - (Model: PV-BT848P+)
  - 878TV - (Model: PV-BT878TV)

- Các gói truyền hình đa phương tiện (card + gói phần mềm):

- PixelView Play TV Theater - (Model: PV-M4200) = PixelView Play TV pro + Phần mềm
  - PixelView Play TV PAK - (Model: PV-BT878P+ REV 4E)
  - PixelView Play TV/VCR - (Model: PV-M3200 REV 4C/8D/10A )
  - PixelView Studio PAK - (Model: M2200 REV 4C/8D/10A )
  - PixelView PowerStudio PAK - (Model: PV-M3600 REV 4E)
  - PixelView DigitalVCR PAK - (Model: PV-M2400 REV 4C/8D/10A )
  - PixelView PlayTV PAK II (TV/thẻ FM + camera usb) PV-M3800
  - PixelView PlayTV XP PV-M4700,PV-M4700(w/FM)
  - Nội dung gói PixelView PlayTV DVR PV-M4600: PixelView PlayTV pro, windvr & videoMail s/w

- Thẻ bổ sung:

- PV-BT878P+rev.9B (Play TV Pro, tùy chọn w/FM w/NICAM)
  - PV-BT878P+rev.2F
  - PV-BT878P Rev.1D (bt878, chỉ chụp)

- XCapture PV-CX881P (cx23881)
  - PlayTV HD PV-CX881PL+, PV-CX881PL+(w/FM) (cx23881)

- DTV3000 PV-DTV3000P+ DVB-S CI = Twinhan VP-1030
  - DTV2000 DVB-S = Twinhan VP-1020

- Hội nghị truyền hình:

- PixelView Meet PAK - (Model: PV-BT878P)
  - PixelView Meet PAK Lite - (Model: PV-BT878P)
  - PixelView Meet PAK plus - (Model: PV-BT878P+rev 4C/8D/10A)
  - Chụp PixelView - (Model: PV-BT848P)
  - PixelView PlayTV USB chuyên nghiệp
  - Model No. PV-NT1004+, PV-NT1004+ (w/FM) = Chip giải mã NT1004 USB + Chip giải mã video SAA7113

Dynalink
~~~~~~~~

Đây là dòng CPH.

Phoebemicro
~~~~~~~~~~~

- Bậc thầy truyền hình = CPH030 hoặc CPH060
- TV Master FM = CPH050

Thiên tài/Kye
~~~~~~~~~~

- Video Wonder/Genius Internet Video Kit = LR37 Rev.C
- Video Wonder Pro II (848 hoặc 878) = LR26

Tekram
~~~~~~

- VideoCap C205 (Bt848)
- VideoCap C210 (zr36120 +Philips)
- CaptureTV M200 (ISA)
- CaptureTV M205 (Bt848)

Ngôi sao may mắn
~~~~~~~~~~

- Hình ảnh TV Hội nghị Thế giới = LR50 Rev. Q

Leadtek
~~~~~~~

- WinView 601 (Bt848)
- WinView 610 (Zoran)
- WinFast2000
- WinFast2000XP

Hỗ trợ cho Leadtek WinView 601 TV/FM
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tác giả của phần này: Jon Tombs <jon@gte.esi.us.es>

Thẻ này về cơ bản giống với tất cả các thẻ còn lại (Bt484A, bộ chỉnh Philips),
sự khác biệt chính là họ đã gắn bộ suy giảm có thể lập trình vào 3
Dòng GPIO để điều khiển âm lượng. Họ cũng đã mắc kẹt một
điều khiển từ xa hồng ngoại được giải mã trên bảng, tôi sẽ thêm hỗ trợ cho việc này
khi tôi có thời gian (nó đơn giản tạo ra một ngắt cho mỗi lần nhấn phím, với
mã khóa được đặt trong cổng GPIO).

Tôi chưa có ứng dụng nào để kiểm tra hỗ trợ radio. Bộ chỉnh
cài đặt tần số sẽ hoạt động nhưng có thể bộ ghép kênh âm thanh
là sai. Nếu nó không hoạt động, gửi email cho tôi.


- Không, Cảm ơn Leadtek, họ đã từ chối trả lời bất kỳ câu hỏi nào về
  phần cứng. Trình điều khiển được viết bằng cách kiểm tra trực quan thẻ. Nếu bạn
  sử dụng trình điều khiển này, gửi email xúc phạm họ và nói với họ rằng bạn sẽ không
  tiếp tục mua phần cứng của họ trừ khi họ hỗ trợ Linux.

- Xin chân thành cảm ơn Princeton Technology Corp (ZZ0000ZZ
  người làm bộ suy giảm âm thanh. Bảng dữ liệu có sẵn công khai của họ có sẵn
  trên trang web của họ không bao gồm thông tin lập trình chip! Ẩn
  trên máy chủ của họ có đầy đủ các bảng dữ liệu, nhưng đừng hỏi làm sao tôi tìm thấy nó.

Để sử dụng trình điều khiển, tôi sử dụng các tùy chọn sau, cài đặt bộ chỉnh và pll có thể
trở nên khác biệt ở đất nước của bạn Bạn có thể buộc nó thông qua các tham số modprobe.
Ví dụ::

modprobe bttv tuner=1 pll=28 radio=1 card=17

Đặt bộ điều chỉnh loại 1 (Philips PAL_I), PLL với tinh thể 28 MHz, cho phép
Đài FM và chọn thẻ bttv ID 17 (Leadtek WinView 601).


KNC Một
~~~~~~~

- Đài truyền hình
- TV-Station SE (+Gói phần mềm)
- TV-Station pro (+TV âm thanh nổi)
- Đài truyền hình FM (+Radio)
- Đài truyền hình RDS (+RDS)
- Đài truyền hình SAT (analog vệ tinh)
- Đài truyền hình DVB-S

.. note:: newer Cards have saa7134, but model name stayed the same?

Cung cấp
~~~~~~~~

- PV951 hoặc PV-951, hiện có tên là PV-951T
   (cũng được bán dưới dạng:
   Thẻ ghi video Boeder TV-FM,
   Giám sát Titanmedia TV-2400,
   Cung cấp PV951 TF,
   3Demon PV951,
   MediaForte TV-Vision PV951,
   Yoko PV951,
   Thẻ điều chỉnh Vivanco PCI Art.-Nr.: 68404
   )

- Chuỗi giám sát:

- PV-141
 - PV-143
 - PV-147
 - PV-148 (chỉ chụp)
 - PV-150
 - PV-151

- Dòng TV-FM:

- PV-951TDV (bộ thu sóng tivi + 1394)
 - PV-951T/TF
 - PV-951PT/TF
 - Cấu hình thấp PV-956T/TF
 - PV-911

Màn hình cao
~~~~~~~~~~

Mô hình:

- TV Karte = LR50 Rev.S
- TV-Boostar = Terratec Terra TV+ Phiên bản 1.0 (Bt848, tda9821) "ceb105.pcb"

Zoltrix
~~~~~~~

Mô hình:

- Chụp trực diện (chỉ chụp Bt848) (PCB "VP-2848")
- Tivi Trực Tiếp MAX (Bt848) (PCB "VP-8482 Rev1.3")
- Genie TV (Bt878) (PCB "VP-8790 Rev 2.1")
- Genie Wonder Pro

AVerMedia
~~~~~~~~~

- AVer FunTV Lite (chip ISA, AV3001) "M101.C"
- AVerTV
- Âm thanh nổi AVerTV
- AVerTV Studio (có FM)
- AVerMedia TV98 có điều khiển từ xa
- AVerMedia TV/FM98 Âm thanh nổi
- AVerMedia TVCAM98
- Chụp TV (Bt848)
- Điện thoại truyền hình (Bt848)
- TVCapture98 ("AVerMedia TV98" trong USA) (Bt878)
- TVPhone98 (Bt878, có FM)

======== =========================== ======= ====== ======== ==========================
PCB PCI-ID Tên mẫu Eeprom Tuner Âm thanh Quốc gia
======== =========================== ======= ====== ======== ==========================
M101.C ISA!
M108-B Bt848 -- FR1236 Hoa Kỳ [#f2]_, [#f3]_
M1A8-A Bt848 AVer TV-Phone FM1216 --
M168-T 1461:0003 AVerTV Studio 48:17 FM1216 TDA9840T D [#f1]_ w/FM w/Điều khiển từ xa
M168-U 1461:0004 TVCapture98 40:11 FI1216 -- D w/Điều khiển từ xa
M168II-B 1461:0003 Medion MD9592 48:16 FM1216 TDA9873H D w/FM
======== =========================== ======= ====== ======== ==========================

.. [#f1] Daughterboard MB68-A with TDA9820T and TDA9840T
.. [#f2] Sony NE41S soldered (stereo sound?)
.. [#f3] Daughterboard M118-A w/ pic 16c54 and 4 MHz quartz

- Trang web của Hoa Kỳ có các trình điều khiển khác nhau cho (tính đến tháng 09/2002):

- EZ Capture/InterCam PCI (chip BT-848)
  - EZ Capture/InterCam PCI (chip BT-878)
  - Tivi-Phone (chip BT-848)
  - TV98 (chip BT-848)
  - TV98 Có Remote (chip BT-848)
  - TV98 (chip BT-878)
  - TV98 có điều khiển từ xa (BT-878)
  - Tivi/FM98 (chip BT-878)
  - AVerTV
  - Âm thanh nổi AverTV
  - AVerTV Studio

Mũ DE đa dạng Treiber fuer diese Modelle (Stand 09/2002):

- TVPhone (848) với bộ thu sóng Philips FR12X6 (có đài FM)
  - TVPhone (848) với bộ thu sóng Philips FM12X6 (có đài FM)
  - TVCapture (848) với bộ điều chỉnh Philips FI12X6
  - Bộ điều chỉnh TVCapture (848) không phải của Philips
  - TVCapture98 (Bt878)
  - TVPhone98 (Bt878)
  - AVerTV và TVCapture98 w/VCR (Bt 878)
  - AVerTVStudio và TVPhone98 với VCR (Bt878)
  - Dòng AVerTV GO (Đầu vào Kein SVideo)
  - AVerTV98 (chip BT-878)
  - AVerTV98 với Fernbedienung (chip BT-878)
  - AVerTV/FM98 (chip BT-878)

- VDOmate (www.averm.com.cn) = M168U ?

Mục tiêu
~~~~~~~

Mô hình:

- Đường cao tốc video hoặc "Đường cao tốc video TR200" (ISA)
- Đường cao tốc video Xtreme (còn gọi là "VHX") (Bt848, FM w/ TEA5757)

IXMicro (trước đây: IMS=Giải pháp vi mô tích hợp)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- IXTV BT848 (=TurboTV)
- IXTV BT878
- IMS TurboTV (Bt848)

Lifetec/Medion/Tevion/Aldi
~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- LT9306/MD9306 = CPH061
- LT9415/MD9415 = LR90 Rev.F hoặc Rev.G
- MD9592 = Avermedia TVphone98 (PCI_ID=1461:0003), PCB-Rev=M168II-B (w/TDA9873H)
- MD9717 = KNC One (Rev D4, saa7134, FM1216 MK2 bộ điều chỉnh)
- MD5044 = KNC One (Rev D4, saa7134, FM1216ME MK3 bộ điều chỉnh)

Công nghệ mô-đun (www.modulartech.com) Vương quốc Anh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- MM100 PCTV (Bt848)
- MM201 PCTV (Bt878, Bt832) w/ Camera Quartzsight
- MM202 PCTV (Bt878, Bt832, tda9874)
- MM205 PCTV (Bt878)
- MM210 PCTV (Bt878) (Galaxy TV, Galaxymedia?)

đất nung
~~~~~~~~

Mô hình:

- Terra TV+ Phiên bản 1.0 (Bt848), "ceb105.PCB" được in trên PCB, TDA9821
- Terra TV+ Phiên bản 1.1 (Bt878), "LR74 Rev.E" được in trên PCB, TDA9821
- Terra TValueRadio, "LR102 Rev.C" được in trên PCB
- Terra TV/Radio+ Phiên bản 1.0, "80-CP2830100-0" TTTV3 được in trên PCB,
  "CPH010-E83" ở mặt sau, SAA6588T, TDA9873H
- Terra TValue Phiên bản BT878, "80-CP2830110-0 TTTV4" được in trên PCB,
  "CPH011-D83" ở mặt sau
- Terra TValue Version 1.0 "ceb105.PCB" (rất giống với Terra TV+ Version 1.0)
- Terra TValue Bản sửa đổi mới "LR102 Rec.C"
- Nâng cấp đài phát thanh chủ động Terra (tea5757h, saa6588t)

- LR74 là phiên bản PCB mới hơn của ceb105 (cả hai đều bao gồm đầu nối để nâng cấp Active Radio)

- Cinergy 400 (saa7134), “E877 11(S)”, “PM820092D” in trên PCB
- Điện ảnh 600 (saa7134)

kỹ thuật
~~~~~~~~~

Mô hình:

- Discos ADR PC-Karte ISA (không có TV!)
- Discos ADR PC-Karte PCI (chắc không có TV nhỉ?)
- Techni-PC-Sat (Sat. analog)
  Phiên bản 1.2 (zr36120, vpx3220, stv0030, saa5246, BSJE3-494A)
- Mediafocus I (zr36120/zr36125, drp3510, Sat. analog + Đài ADR)
- Mediafocus II (saa7146, Sat. analog)
- SatADR Phiên bản 2.1 (saa7146a, saa7113h, stv0056a, msp3400c, drp3510a, BSKE3-307A)
- SkyStar 1 DVB (AV7110) = Technotrend Premium
- SkyStar 2 DVB (B2C2) (=Sky2PC)

Siemens
~~~~~~~

Bảng mở rộng đa phương tiện (MXB) (SAA7146, SAA7111)

Màu mạnh
~~~~~~~~~~

Mô hình:

-MTV878
       Gói đi kèm với nội dung khác nhau:

a) pcb "MTV878" (CARD=75)
           b) Pixelview Rev. 4\_

- MTV878R có Điều khiển từ xa
- MTV878F có Điều khiển từ xa có đài FM

Đỉnh cao
~~~~~~~~

Các mẫu PCTV:

- Mirovideo PCTV (Bt848)
- Mirovideo PCTV SE (Bt848)
- Mirovideo PCTV Pro (Bt848 + Bảng mạch con cho TV âm thanh nổi và FM)
- Studio PCTV Rave (Phiên bản Bt848 = Mirovideo PCTV)
- Studio PCTV Rave (gói Bt878 không có hồng ngoại)
- Studio PCTV (Bt878)
- Studio PCTV Pro (âm thanh nổi Bt878 có FM)
- Đỉnh cao PCTV (Bt878, MT2032)
- Đỉnh cao PCTV Pro (Bt878, MT2032)
- Pinncale PCTV Sat (bt878a, HM1821/1221) ["Conexant CX24110 với bộ điều chỉnh CX24108, hay còn gọi là HM1221/HM1811"]
- Đỉnh cao PCTV Sát XE

Các mẫu chụp và phát lại M(J)PEG:

- DC1+ (ISA)
- DC10 (zr36057, zr36060, saa7110, Adv7176)
- DC10+ (zr36067, zr36060, saa7110, Adv7176)
- DC20 (ql16x24b,zr36050, zr36016, saa7110, saa7187...)
- DC30 (zr36057, zr36050, zr36016, vpx3220, Adv7176, ad1843, trà6415, miro FST97A1)
- DC30+ (zr36067, zr36050, zr36016, vpx3220, Adv7176)
- DC50 (zr36067, zr36050, zr36016, saa7112, Adv7176 (2 chiếc.?), ad1843, miro FST97A1, Lưới ???)

Lenco
~~~~~

Mô hình:

- MXR-9565 (=Technisat Mediafocus?)
- MXR-9571 (Bt848) (=CPH031?)
-MXR-9575
- MXR-9577 (Bt878) (=Prolink 878TV Rev.3x)
- MXTV-9578CP (Bt878) (= Prolink PV-BT878P+4E)

omega
~~~~~~

Buz (zr36067, zr36060, saa7111, saa7185)

LML
~~~
LML33 (zr36067, zr36060, bt819, bt856)

Grandtec
~~~~~~~~

Mô hình:

- Quay video lớn (Bt848)
- Thẻ chụp đa năng (Bt878)

kotech
~~~~~~~

Mô hình:

- KW-606 (Bt848)
- KW-607 (chỉ chụp Bt848)
- KW-606RSF
- KW-607A (chỉ chụp)
- KW-608 (Chỉ chụp Zoran)

IODATA (jp)
~~~~~~~~~~~

Mô hình:

- GV-BCTV/PCI
- GV-BCTV2/PCI
- GV-BCTV3/PCI
- GV-BCTV4/PCI
- GV-VCP/PCI (chỉ chụp)
- GV-VCP2/PCI (chỉ chụp)

Canopus (jp)
~~~~~~~~~~~~

WinDVR = Kworld "KW-TVL878RF"

www.sigmacom.co.kr
~~~~~~~~~~~~~~~~~~

Sigma Cyber ​​TV II

www.saem.co.kr
~~~~~~~~~~~~~~~

Litte OnAir TV

hama
~~~~

Card TV/Radio-Tuner, PCI (Model 44677) = CPH051

Thiết Kế Sigma
~~~~~~~~~~~~~

Hollywood plus (em8300, em9010, Adv7175), (PCB "M340-10") Bộ giải mã MPEG DVD

định dạng
~~~~~~

Mô hình:

- iProTV (Thẻ dành cho khe cắm iMac Mezzanine, Bt848+SCSI)
- ProTV (Bt848)
- ProTV II = ProTV Stereo (Bt878) ["stereo" nghĩa là FM stereo, tv vẫn là mono]

ATI
~~~

Mô hình:

- TV-Wonder
- TV-Wonder VE

Đa phương tiện kim cương
~~~~~~~~~~~~~~~~~~

DTV2000 (Bt848, tda9875)

Aopen
~~~~~

- VA1000 Plus (có âm thanh nổi)
-VA1000 Lite
- VA1000 (=LR90)

Intel
~~~~~

Mô hình:

- Đầu ghi video thông minh (ISA toàn thời gian)
- Đầu ghi video thông minh chuyên nghiệp (ISA nửa chiều dài)
- Đầu ghi video thông minh III (Bt848)

STB
~~~

Mô hình:

- Cổng STB 6000704 (bt878)
- Cổng STB 6000699 (bt848)
- Cổng STB 6000402 (bt848)
- STB TV130 PCI

Videologic
~~~~~~~~~~

Mô hình:

- Captivator Pro/TV (ISA?)
- Captivator PCI/VC (Bt848 đi kèm camera) (chỉ chụp)

xu hướng công nghệ
~~~~~~~~~~~~

Mô hình:

- TT-SAT PCI (PCB "Sat-PCI Rev.:1.3.1"; zr36125, vpx3225d, stc0056a, Bộ điều chỉnh:BSKE6-155A
- TT-DVB-Sat
   - phiên bản 1.1, 1.3, 1.5, 1.6 và 2.1
   - Thẻ này được bán dưới dạng OEM từ:

- Thẻ Siemens DVB-s
	- Hauppauge WinTV DVB-S
	- Technisat SkyStar 1 DVB
	- Thiên Hà DVB Thứ Bảy

- Hiện nay thẻ này có tên là TT-PCline Premium Family
   - TT-Ngân sách (saa7146, bsru6-701a)
     Thẻ này được bán dưới dạng OEM từ:

- Hauppauge WinTV Nova
	- Tiêu chuẩn vệ tinh PCI (DVB-S)
   - TT-DVB-C PCI

Kính thiên văn
~~~~~

DVB-s (Rev. 2.2, BSRV2-301A, chỉ dữ liệu?)

Tầm nhìn từ xa
~~~~~~~~~~~~~

MX RV605 (chỉ chụp Bt848)

Boeder
~~~~~~

Mô hình:

- PC ChatCam (Model 68252) (chỉ chụp Bt848)
- Card thu hình TV/Fm (Model 68404) = PV951

Media-Surfer (esc-kathrein.de)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Thứ Bảy-Lướt Sóng (ISA)
- Thứ Bảy-Lướt PCI = Techni-PC-Sat
- Người lướt cáp 1
- Lướt Cáp 2
- Cable Surfer PCI (zr36120)
- Audio-Surfer (thẻ Radio ISA)

Đường bay phản lực (www.jetway.com.tw)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- JW-TV 878M
- JW-TV 878 = KWorld KW-TV878RF

thiên hà
~~~~~~~

Mô hình:

- Thẻ S CI của Galaxis DVB
- Galaxis DVB Thẻ C CI
- Thẻ Galaxy DVB S
- Thẻ Galaxy C DVB C
- Galaxis plug.in S [Tên mới: Galaxis DVB Card S CI

Hauppauge
~~~~~~~~~

Mô hình:

- rất nhiều mẫu WinTV...
- WinTV DVBs = Technotrend Premium 1.3
- WinTV NOVA = Ngân sách Technotrend 1.1 "S-DVB DATA"
- WinTV NOVA-CI "SDVBACI"
- WinTV Nova USB (=Technotrend USB 1.0)
- WinTV-Nexus-s (=Technotrend Premium 2.1 hoặc 2.2)
- WinTV PVR
- WinTV PVR 250
- WinTV PVR 450

người mẫu Mỹ

-990 WinTV-PVR-350 (249USD) (iTVC15 chipset + đài)
-980 WinTV-PVR-250 (149USD) (chipset iTVC15)
-880 WinTV-PVR-PCI (199USD) (chipset KFIR + bt878)
-881 WinTV-PVR-USB
-190 WinTV-GO
-191 WinTV-GO-FM
-404 WinTV
-401 Đài phát thanh WinTV
-495 WinTV-Nhà hát
-602 WinTV-USB
-621 WinTV-USB-FM
-600 USB-Live
-698 WinTV-HD
-697 WinTV-D
-564 WinTV-Nexus-S

Mô hình Deutsche:

-603 WinTV GO
-719 WinTV Primio-FM
-718 WinTV PCI-FM
-497 Rạp WinTV
-569 WinTV USB
-568 WinTV USB-FM
-882 WinTV PVR
-981 WinTV PVR 250
-891 WinTV-PVR-USB
-541 WinTV Nova
-488 WinTV Nova-Ci
-564 WinTV-Nexus-s
-727 WinTV-DVB-c
-545 Giao diện chung
-898 WinTV-Nova-USB

Người mẫu Anh:

-607 WinTV Go
-693,793 WinTV Primio FM
-647,747 WinTV PCI FM
-498 Rạp WinTV
-883 WinTV PVR
-893 WinTV PVR USB (Mục trùng lặp)
-566 WinTV USB (Anh)
-573 WinTV USB FM
-429 Tác Động VCB (bt848)
-600 USB Trực tiếp (Video-In 1x Comp, 1xSVHS)
-542 WinTV Nova
-717 WinTV DVB-S
-909 Nova-t PCI
-893 Nova-t USB (Mục trùng lặp)
-802 MyTV
-804 MyView
-809Video của tôi
-872 MyTV2Go FM
-546 WinTV Nova-S CI
-543 WinTV Nova
-907 Nova-S USB
-908 Nova-T USB
-717 WinTV Nexus-S
-157 DEC3000-s Độc lập + USB

Tây ban nha:

-685 WinTV-Go
-690 WinTV-PrimioFM
-416 WinTV-PCI Nicam Estereo
-677 WinTV-PCI-FM
-699 WinTV-Nhà hát
-683 WinTV-USB
-678 WinTV-USB-FM
-983 WinTV-PVR-250
-883 WinTV-PVR-PCI
-993 WinTV-PVR-350
-893 WinTV-PVR-USB
-728 WinTV-DVB-C PCI
-832 MyTV2Go
-869 MyTV2Go-FM
-805 MyVideo (USB)


Tầm nhìn ma trận
~~~~~~~~~~~~~

Mô hình:

- MATRIX-Vision MV-Delta
-MATRIX-Vision MV-Delta 2
- MVsigma-SLC (Bt848)

Khái niệm (.net)
~~~~~~~~~~~~~~~~~~~

Mô hình:

- TVCON FM, card TV w/ FM = CPH05x
- TVCON = CPH06x

Dữ liệu tốt nhất
~~~~~~~~

Mô hình:

- HCC100 = VCC100rev1 + máy ảnh
-VCC100 rev1 (bt848)
-VCC100 rev2 (bt878)

Gallant (www.gallantcom.com) www.minton.com.tw
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Intervision IV-510 (chỉ chụp bt8x8)
- Nội dung IV-550 (bt8x8)
- Intervision IV-100 (zoran)
- Intervision IV-1000 (bt8x8)

Asonic (www.asonic.com.cn) (trang web ngừng hoạt động)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tivi SkyEye 878

hoontech
~~~~~~~~

878TV/FM

Teppro (www.itcteppro.com.tw)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- ITC PCITV (Thẻ Ver 1.0) "Thẻ Teppro TV1/TVFM1"
- ITC PCITV (Thẻ phiên bản 2.0)
- ITC PCITV (Thẻ phiên bản 3.0) = "PV-BT878P+ (REV.9D)"
- ITC PCITV (Thẻ phiên bản 4.0)
- TEPPRO IV-550 (Dành cho Chip chính BT848)
- ITC DSTTV (bt878, vệ tinh)
- Trình tạo video ITC (saa7146, StreamMachine sm2110, tvtuner) "PV-SM2210P+ (REV:1C)"

Kworld (www.kworld.com.tw)
~~~~~~~~~~~~~~~~~~~~~~~~~~

Đài truyền hình PC:

- Tivi KWORLD KW-TV878R (không có đài)
- Tivi KWORLD KW-TV878RF (có đài)
- KWORLD KW-TVL878RF (cấu hình thấp)
-KWORLD KW-TV713XRF (saa7134)


Đài truyền hình MPEG (các thẻ tương tự như trên cộng với phần mềm WinDVR MPEG en/bộ giải mã)

- KWORLD KW-TV878R -Pro TV (không có Radio)
- Tivi KWORLD KW-TV878RF-Pro (có đài)
- KWORLD KW-TV878R -Ultra TV (không có Radio)
- Tivi KWORLD KW-TV878RF-Ultra (có Radio)

JTT/ Công ty Justy(ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

JTT-02 (JTT TV) "TV watchmate pro" (bt848)

ADS www.adstech.com
~~~~~~~~~~~~~~~~~~~

Mô hình:

- Kênh Surfer TV ( CHX-950 )
- Kênh Surfer TV+FM ( CHX-960FM )

AVEC www.prochips.com
~~~~~~~~~~~~~~~~~~~~~

Giao thoa AVEC (bt848, trà6320)

Không có thương hiệu
~~~~~~~

TV Excel = Tên Úc cho "PV-BT878P+ 8E" hoặc "878TV Rev.3\_"

Mach www.machspeed.com
~~~~~~~~~~~~~~~~~~~~~~

Mach TV 878

Eline www.eline-net.com/
~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Eline Vision TVMaster / TVMaster FM (ELV-TVM/ ELV-TVM-FM) = LR26 (bt878)
- Eline Vision TVMaster-2000 (ELV-TVM-2000, ELV-TVM-2000-FM)= LR138 (saa713x)

Tinh thần
~~~~~~

- Thẻ ghi video/Bộ điều chỉnh TV Spirit (bt848)

Boser www.boser.com.tw
~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Thẻ bổ trợ chụp ảnh HS-878 Mini PCI
- Thẻ bổ trợ thu âm và ghi âm 3D HS-879 Mini PCI (w/ ES1938 Solo-1)

Satelco www.citycom-gmbh.de, www.satelco.de
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- TV-FM =KNC1 saa7134
- PCI tiêu chuẩn (DVB-S) = Ngân sách Technotrend
- Tiêu chuẩn PCI (DVB-S) w/ CI
- Satelco Highend PCI (DVB-S) = Technotrend Premium


Cảm biến www.sensoray.com
~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Cảm biến 311 (xe PC/104)
- Cảm biến 611 (PCI)

CEI (Chartered Electronics Industries Pte Ltd [CEI] [FCC ID HBY])
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Bộ thu sóng TV - HBY-33A-RAFFLES Brooktree Bt848KPF + Philips
- Bộ thu sóng TV MG9910 - HBY33A-TVO CEI + Philips SAA7110 + OKI M548262 + ST STV8438CV
- Truyền hình giờ vàng (ISA)

- được mua lại bởi Singapore Technologies
  - hiện đang hoạt động với tư cách là Nhà sản xuất chất bán dẫn được cấp phép
  - Nhà sản xuất card màn hình được liệt kê là:

- Công nghiệp điện tử Cogent [CEI]

AITech
~~~~~~

Mô hình:

- Tivi Wavewatcher (ISA)
- AITech WaveWatcher TV-PCI = có thể là LR26 (Bt848) hoặc LR50 (BT878)
- Thẻ TV/FM WaveWatcher TVR-202 (ISA)

MAXRON
~~~~~~

Maxron MaxTV/Đài FM (KW-TV878-FNT) = Kworld hoặc JW-TV878-FBK

www.ids-imaging.de
~~~~~~~~~~~~~~~~~~

Mô hình:

- Dòng Falcon (chỉ chụp)

Trong USA: ZZ0000ZZ
-DFG/LC1

www.sknet-web.co.jp
~~~~~~~~~~~~~~~~~~~

SKnet Monster TV (saa7134)

A-Max www.amaxhk.com (Colormax, Amax, Napa)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

APAC Viewcomp 878

Giải trí mạng
~~~~~~~~~~~~~

Mô hình:

- Bộ email video CyberMail AV w/ Thẻ chụp PCI (chỉ chụp)
- CyberMail Xtreme

Đây là Flyvideo

VCR (ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình bắt video 16

songhan
~~~~~~~

Mô hình:

- Thẻ DST/DST-IP (bt878, Twinhan asic) VP-1020
  - Được bán dưới dạng:

- Thẻ truyền hình vệ tinh KWorld DVBS
    - Thẻ điều chỉnh vệ tinh Powercolor DSTV
    - Prolink Pixelview DTV2000
    - Thẻ điều chỉnh truyền hình vệ tinh kỹ thuật số Provideo PV-911 với giao diện chung?

- Thẻ DST-CI (Vệ tinh DVB) VP-1030
- Thẻ DCT (cáp DVB)

MSI
~~~

Mô hình:

- MSI Thẻ điều chỉnh TV@nywhere (MS-8876) (CX23881/883) Không tương thích với Bt878.
- MS-8401 DVB-S

Tập trung www.focusinfo.com
~~~~~~~~~~~~~~~~~~~~~~~

Trong Video PCI (bt878)

Sdisilk www.sdisilk.com/
~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

- SDI Tơ 100
- Thẻ đầu vào SDI Silk 200 SDI

www.euresys.com
~~~~~~~~~~~~~~~

Dòng PICOLO

PMC/Tốc độ
~~~~~~~~

Trang web www.pacecom.co.uk đã đóng cửa

Mercury www.kobian.com (Anh và Pháp)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô hình:

-LR50
- LR138RBG-Rx == LR138

Âm thanh TEC
~~~~~~~~~

TV-Mate = Zoltrix VP-8482

Mặc dù tìm kiếm trên Google có trình độ học vấn cao đã tìm thấy: www.techmakers.com

(gói và sách hướng dẫn không có bất kỳ thông tin nào khác của nhà sản xuất) TecSound

Lorenzen www.lorenzen.de
~~~~~~~~~~~~~~~~~~~~~~~~

SL DVB-S PCI = Ngân sách Technotrend PCI (phiên bản su1278 hoặc bsru)

Origo (.uk) www.origo2000.com
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thẻ PC TV = LR50

I/O Magic www.iomagic.com
~~~~~~~~~~~~~~~~~~~~~~~~~

PC PVR - Máy tính để bàn TV Đầu ghi video cá nhân DR-PCTV100 = Pinnacle ROB2D-51009464 4.0 + Cyberlink PowerVCR II

cá rồng
~~~~~~~

TV-Karte / Poso Power TV (?) = Zoltrix VP-8482 (?)

bo mạch iTVC15
~~~~~~~~~~~~~

kuroutoshikou.com ITVC15
yuan.com TV MPG160 PCI (Thẻ mã hóa PCI MPEG2 bên trong cộng với bộ dò TV)

Asus www.asuscom.com
~~~~~~~~~~~~~~~~~~~~

Mô hình:

- Asus TV Tuner Card 880 NTSC (cấu hình thấp, cx23880)
- Tivi Asus (saa7134)

hoontech
~~~~~~~~

ZZ0000ZZ

- HART Tầm Nhìn 848 (H-ART Tầm Nhìn 848)
- HART Tầm Nhìn 878 (H-Art Tầm Nhìn 878)



Chip được sử dụng tại các thiết bị bttv
--------------------------

- tất cả các bảng:

- Brooktree Bt848/848A/849/878/879: chip quay video

- Ban cụ thể

- Miro PCTV:

- Bộ điều chỉnh Philips hoặc Temia

- Hauppauge Win/TV pci (phiên bản 405):

- Microchip 24LC02B hoặc Philips 8582E2Y:

- 256 Byte EEPROM kèm thông tin cấu hình
       - I2C 0xa0-0xa1, (24LC02B cũng đáp ứng 0xa2-0xaf)

- Philips SAA5246AGP/E: Chip giải mã videotext, I2C 0x22-0x23

- TDA9800: bộ giải mã âm thanh

- Winbond W24257AS-35: 32Kx8 CMOS tĩnh RAM (Mem đệm videotext)

- 14052B: công tắc analog để chọn nguồn âm thanh

-PAL:

- TDA5737: VHF, hyperband và bộ trộn/dao động UHF cho TV và bộ điều chỉnh 3 băng tần VCR
  - TSA5522: Bộ tổng hợp điều khiển I2C-bus 1,4 GHz, I2C 0xc2-0xc3

-NTSC:

- TDA5731: VHF, hyperband và bộ trộn/dao động UHF cho TV và bộ điều chỉnh 3 băng tần VCR
  - TSA5518: không có bảng dữ liệu trên trang web của Philips

- pci tivi STB:

- ???
  - nếu bạn muốn được hỗ trợ tốt hơn cho thẻ STB, hãy gửi thông tin cho tôi!
    Nhìn vào bảng! Những con chip nào trên đó?




Thông số kỹ thuật
-----

Philips ZZ0000ZZ

Conexant ZZ0000ZZ

Micronas ZZ0000ZZ

Cảm ơn
------

Cảm ơn rất nhiều đến:

- Markus Schroeder <schroedm@uni-duesseldorf.de> để biết thông tin về Bt848
  và lập trình bộ chỉnh và chương trình điều khiển xtvc của anh ấy.

- Martin Buck <martin-2.buck@student.uni-ulm.de> vì Videotext tuyệt vời của anh ấy
  gói.

- Gerd Hoffmann về việc hỗ trợ MSP3400 và mô-đun
  Hỗ trợ I2C, bộ chỉnh âm, ....


- MATRIX Vision đã tặng chúng tôi 2 thẻ miễn phí, hỗ trợ
  hoạt động đơn tinh thể có thể.

- MIRO để được cung cấp thẻ PCTV miễn phí và thông tin chi tiết về
  các thành phần trên thẻ của họ. (Ví dụ: cách phát hiện loại bộ điều chỉnh)
  Nếu không có thẻ của họ, tôi không thể gỡ lỗi chế độ NTSC.

- Hauppauge để biết cách chọn đầu vào âm thanh và thành phần nào
  họ làm và sẽ sử dụng trên thẻ radio của họ.
  Cũng xin cảm ơn rất nhiều vì đã gửi fax cho tôi bảng dữ liệu FM1216.

Người đóng góp
------------

Michael Chu <mmchu@pobox.com>
  Sửa lỗi AverMedia và nhận dạng thẻ linh hoạt hơn

Alan Cox <alan@lxorguk.ukuu.org.uk>
  Giao diện Video4Linux và thích ứng kernel 2.1.x

Chris Kleitsch
  Phần cứng I2C

Gerd Hoffmann
  Card radio (bộ xử lý âm thanh ITT)

chân to <bigfoot@net-way.net>

Ragnar Hojland Espinosa <ragnar@macula.net>
  Thẻ TV hội nghị


+ nhiều hơn nữa (vui lòng gửi thư cho tôi nếu bạn thiếu trong danh sách này và sẽ
	     thích được nhắc đến)