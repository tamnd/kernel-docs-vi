.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/zoran.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Người lái xe Zoran
================

trình điều khiển zoran hợp nhất (zr360x7, zoran, buz, dc10(+), dc30(+), lml33)

trang web: ZZ0000ZZ


Câu hỏi thường gặp
--------------------------

Những thẻ nào được hỗ trợ
------------------------

Iomega Buz, Phòng thí nghiệm truyền thông Linux LML33/LML33R10, Đỉnh cao/Miro
DC10/DC10+/DC30/DC30+ và các bo mạch liên quan (có nhiều tên khác nhau).

Iomega Buz
~~~~~~~~~~

* Bộ điều khiển Zoran zr36067 PCI
* Bộ giải mã Zoran zr36060 MJPEG
* Bộ giải mã TV Philips saa7111
* Bộ mã hóa TV Philips saa7185

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
bộ giải mã video, saa7111, saa7185, zr36060, zr36067

Đầu vào/đầu ra: Composite và S-video

Định mức: PAL, SECAM (720x576 @ 25 khung hình/giây), NTSC (720x480 @ 29,97 khung hình/giây)

Số thẻ: 7

AverMedia 6 Mắt AVS6EYES
~~~~~~~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36067 PCI
* Bộ giải mã Zoran zr36060 MJPEG
* Bộ giải mã tivi Samsung ks0127
* Bộ mã hóa TV Conexant bt866

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
bộ giải mã video, ks0127, bt866, zr36060, zr36067

Đầu vào/đầu ra:
	Sáu đầu vào vật lý. 1-6 là hợp số,
	1-2, 3-4, 5-6 tăng gấp đôi dưới dạng S-video,
	1-3 bộ ba là thành phần.
	Một đầu ra tổng hợp.

Định mức: PAL, SECAM (720x576 @ 25 khung hình/giây), NTSC (720x480 @ 29,97 khung hình/giây)

Số thẻ: 8

.. note::

   Not autodetected, card=8 is necessary.

Phòng thí nghiệm truyền thông Linux LML33
~~~~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36067 PCI
* Bộ giải mã Zoran zr36060 MJPEG
* Bộ giải mã TV Brooktree bt819
* Bộ mã hóa TV Brooktree bt856

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
bộ giải mã video, bt819, bt856, zr36060, zr36067

Đầu vào/đầu ra: Composite và S-video

Định mức: PAL (720x576 @ 25 khung hình/giây), NTSC (720x480 @ 29,97 khung hình/giây)

Số thẻ: 5

Phòng thí nghiệm truyền thông Linux LML33R10
~~~~~~~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36067 PCI
* Bộ giải mã Zoran zr36060 MJPEG
* Bộ giải mã TV Philips saa7114
* Bộ mã hóa TV Analog Devices Adv7170

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
bộ giải mã video, saa7114, Adv7170, zr36060, zr36067

Đầu vào/đầu ra: Composite và S-video

Định mức: PAL (720x576 @ 25 khung hình/giây), NTSC (720x480 @ 29,97 khung hình/giây)

Số thẻ: 6

Đỉnh cao/Miro DC10 (mới)
~~~~~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36057 PCI
* Bộ giải mã Zoran zr36060 MJPEG
* Bộ giải mã TV Philips saa7110a
* Bộ mã hóa TV Analog Devices Adv7176

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
bộ giải mã video, saa7110, Adv7175, zr36060, zr36067

Đầu vào/đầu ra: Composite, S-video và Internal

Định mức: PAL, SECAM (768x576 @ 25 khung hình/giây), NTSC (640x480 @ 29,97 khung hình/giây)

Số thẻ: 1

Đỉnh cao/Miro DC10+
~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36067 PCI
* Bộ giải mã Zoran zr36060 MJPEG
* Bộ giải mã TV Philips saa7110a
* Bộ mã hóa TV Analog Devices Adv7176

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
bộ giải mã video, saa7110, Adv7175, zr36060, zr36067

Đầu vào/đầu ra: Composite, S-video và Internal

Định mức: PAL, SECAM (768x576 @ 25 khung hình/giây), NTSC (640x480 @ 29,97 khung hình/giây)

Số thẻ: 2

Đỉnh cao/Miro DC10 (cũ)
~~~~~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36057 PCI
* Bộ giải mã Zoran zr36050 MJPEG
* Giao diện người dùng video Zoran zr36016 hoặc Giao diện người dùng video Fuji md0211 (bản sao?)
* Bộ giải mã tivi Micronas vpx3220a
* Bộ mã hóa TV mse3000 hoặc Bộ mã hóa TV Analog Devices Adv7176

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
mã video, vpx3220, mse3000/adv7175, zr36050, zr36016, zr36067

Đầu vào/đầu ra: Composite, S-video và Internal

Định mức: PAL, SECAM (768x576 @ 25 khung hình/giây), NTSC (640x480 @ 29,97 khung hình/giây)

Số thẻ: 0

Đỉnh cao/Miro DC30
~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36057 PCI
* Bộ giải mã Zoran zr36050 MJPEG
* Giao diện người dùng video Zoran zr36016
* Bộ giải mã TV Micronas vpx3225d/vpx3220a/vpx3216b
* Bộ mã hóa TV Analog Devices Adv7176

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
mã video, vpx3220/vpx3224, Adv7175, zr36050, zr36016, zr36067

Đầu vào/đầu ra: Composite, S-video và Internal

Định mức: PAL, SECAM (768x576 @ 25 khung hình/giây), NTSC (640x480 @ 29,97 khung hình/giây)

Số thẻ: 3

Đỉnh cao/Miro DC30+
~~~~~~~~~~~~~~~~~~~

* Bộ điều khiển Zoran zr36067 PCI
* Bộ giải mã Zoran zr36050 MJPEG
* Giao diện người dùng video Zoran zr36016
* Bộ giải mã TV Micronas vpx3225d/vpx3220a/vpx3216b
* Bộ mã hóa TV Analog Devices Adv7176

Trình điều khiển sử dụng: videodev, i2c-core, i2c-algo-bit,
mã video, vpx3220/vpx3224, Adv7175, zr36050, zr36015, zr36067

Đầu vào/đầu ra: Composite, S-video và Internal

Định mức: PAL, SECAM (768x576 @ 25 khung hình/giây), NTSC (640x480 @ 29,97 khung hình/giây)

Số thẻ: 4

.. note::

   #) No module for the mse3000 is available yet
   #) No module for the vpx3224 is available yet

1.1 Bộ giải mã TV có thể làm gì và không làm được gì
------------------------------------------

Các tiêu chuẩn TV được biết đến nhiều nhất là NTSC/PAL/SECAM. nhưng để giải mã một khung hình
thông tin là không đủ. Có một số định dạng của tiêu chuẩn TV.
Và không phải bộ giải mã TV nào cũng có thể xử lý mọi định dạng. Ngoài ra mọi
sự kết hợp được hỗ trợ bởi người lái xe. Hiện tại có 11 loại khác nhau
các định dạng phát sóng truyền hình trên toàn thế giới.

CCIR xác định các tham số cần thiết để phát tín hiệu.
CCIR đã xác định các tiêu chuẩn khác nhau: A,B,D,E,F,G,D,H,I,K,K1,L,M,N,...
CCIR không nói nhiều về hệ màu được sử dụng !!!
Và nói về hệ thống màu sắc không nói lên nhiều về cách nó được phát sóng.

Các tiêu chuẩn CCIR A, E, F không còn được sử dụng nữa.

Khi bạn nói về NTSC, bạn thường muốn nói đến tiêu chuẩn: CCIR - M sử dụng
hệ màu NTSC được sử dụng ở USA, Nhật Bản, Mexico, Canada
và một vài người khác.

Khi bạn nói về PAL, ý bạn thường là: CCIR - B/G sử dụng PAL
hệ thống màu được sử dụng ở nhiều quốc gia.

Khi bạn nói về SECAM, ý bạn là: CCIR - L sử dụng Hệ thống màu SECAM
được sử dụng ở Pháp và một số nước khác.

Có phiên bản khác của SECAM, CCIR - D/K được sử dụng ở Bulgaria, Trung Quốc,
Slovakai, Hungary, Hàn Quốc (Cộng hòa), Ba Lan, Rumania và các nước khác.

CCIR - H sử dụng hệ màu PAL (đôi khi là SECAM) và được sử dụng trong
Ai Cập, Libya, Sri Lanka, Syrain Ả Rập. Trả lời.

CCIR - Tôi sử dụng hệ màu PAL và được sử dụng ở Vương quốc Anh, Hồng Kông,
Ireland, Nigeria, Nam Phi.

CCIR - N sử dụng hệ màu PAL và kích thước khung hình PAL nhưng tốc độ khung hình NTSC,
và được sử dụng ở Argentina, Uruguay và một số nước khác

Chúng tôi không nói về cách phát sóng âm thanh!

Một trang web khá hay về các tiêu chuẩn truyền hình là:
ZZ0000ZZ
ZZ0001ZZ
và ZZ0002ZZ

Những điều kỳ lạ khác xung quanh: NTSC 4.43 là một NTSC đã được sửa đổi, chủ yếu là
được sử dụng trong PAL VCR có khả năng phát lại NTSC. PAL 60 có vẻ giống nhau
như NTSC 4.43. Bảng dữ liệu cũng nói về NTSC 44, Có vẻ như nó sẽ
giống như NTSC 4.43.
NTSC Combs dường như là chế độ giải mã trong đó bộ giải mã sử dụng bộ lọc lược
để phân chia hôn mê và luma thay vì dòng Trì hoãn.

Nhưng tôi đã không ngần ngại tìm hiểu NTSC Comb là gì.

Bộ giải mã tivi Philips saa7111
~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1997, được sử dụng trong BUZ và
- có thể xử lý: PAL B/G/H/I, PAL N, PAL M, NTSC M, NTSC N, NTSC 4.43 và SECAM

Bộ giải mã tivi Philips saa7110a
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1995, được sử dụng trong Pinnacle/Miro DC10(mới), DC10+ và
- có thể xử lý: PAL B/G, NTSC M và SECAM

Bộ giải mã tivi Philips saa7114
~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 2000, được sử dụng trong LML33R10 và
- có thể xử lý: PAL B/G/D/H/I/N, PAL N, PAL M, NTSC M, NTSC 4.43 và SECAM

Bộ giải mã TV Brooktree bt819
~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1996 và được sử dụng trong LML33 và
- có thể xử lý: PAL B/D/G/H/I, NTSC M

Bộ giải mã TV Micronas vpx3220a
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1996, được sử dụng trong DC30 và DC30+ và
- có thể xử lý: PAL B/G/H/I, PAL N, PAL M, NTSC M, NTSC 44, PAL 60, SECAM,NTSC Lược

Bộ giải mã tivi Samsung ks0127
~~~~~~~~~~~~~~~~~~~~~~~~~

- được sử dụng trong thẻ AVS6EYES và
- có thể xử lý: NTSC-M/N/44, PAL-M/N/B/G/H/I/D/K/L và SECAM


Bộ mã hóa TV có thể làm gì và không làm được gì
--------------------------------------

Bộ mã hóa TV đang hoạt động "tương tự" như bộ giải mã nhưng theo hướng khác.
Bạn cung cấp cho chúng dữ liệu kỹ thuật số và tạo tín hiệu Tổng hợp hoặc SVHS.
Để biết thông tin về hệ màu và tiêu chuẩn TV, hãy xem trong
Phần giải mã TV.

Bộ mã hóa TV Philips saa7185
~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1996, được sử dụng trong BUZ
- có thể tạo: PAL B/G, NTSC M

Bộ mã hóa TV Brooktree bt856
~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1994, được sử dụng trong LML33
- có thể tạo ra: PAL B/D/G/H/I/N, PAL M, NTSC M, PAL-N (Argentina)

Thiết bị analog Adv7170 Bộ mã hóa TV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 2000, được sử dụng trong LML300R10
- có thể tạo ra: PAL B/D/G/H/I/N, PAL M, NTSC M, PAL 60

Thiết bị analog Adv7175 Bộ mã hóa TV
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1996, được sử dụng trong DC10, DC10+, DC10 cũ, DC30, DC30+
- có thể tạo ra: PAL B/D/G/H/I/N, PAL M, NTSC M

Bộ mã hóa TV ITT mse3000
~~~~~~~~~~~~~~~~~~~~~~

- được giới thiệu vào năm 1991, được sử dụng trong DC10 cũ
- có thể tạo: PAL, NTSC, SECAM

Bộ mã hóa TV Conexant bt866
~~~~~~~~~~~~~~~~~~~~~~~~~

- được sử dụng trong AVS6EYES, và
- có thể tạo: NTSC/PAL, PAL-M, PAL-N

Adv717x có thể tạo ra PAL N. Nhưng bạn không tìm thấy gì PAL N
cụ thể trong sổ đăng ký. Có vẻ như bạn phải sử dụng lại một tiêu chuẩn khác
để tạo PAL N, có thể nó sẽ hoạt động nếu bạn sử dụng cài đặt PAL M.

Làm cách nào để cái thứ chết tiệt này hoạt động được
------------------------------------

Tải zr36067.o. Nếu nó không thể tự động phát hiện thẻ của bạn, hãy sử dụng card=X insmod
tùy chọn với X là số thẻ như được nêu ở phần trước.
Để có nhiều hơn một thẻ, hãy sử dụng card=X1[,X2[,X3,[X4[..]]]]

Để tự động hóa việc này, hãy thêm phần sau vào /etc/modprobe.d/zoran.conf của bạn:

tùy chọn zr36067 card=X1[,X2[,X3[,X4[..]]]]
bí danh char-major-81-0 zr36067

Một điều cần lưu ý là cái này chưa tải zr36067.o. Nó
chỉ tự động tải. Nếu bạn bắt đầu sử dụng xawtv, thiết bị sẽ không tải
một số hệ thống, vì bạn đang cố tải các mô-đun với tư cách là người dùng, điều này không phải
được phép ("quyền bị từ chối"). Cách giải quyết nhanh là thêm 'Tải "v4l"' vào
XF86Config-4 khi bạn sử dụng X theo mặc định hoặc để chạy 'v4l-conf -c <device>' trong
một trong các tập lệnh khởi động của bạn (thường là RC.local) nếu bạn không sử dụng X. Cả hai
đảm bảo rằng các mô-đun được tải khi khởi động, trong tài khoản root.

Tôi nên sử dụng bo mạch chủ nào (hoặc tại sao thẻ của tôi không hoạt động)
---------------------------------------------------------


<chèn tuyên bố từ chối trách nhiệm tệ hại vào đây>. Tóm lại: tốt=SiS/Intel, xấu=VIA.

Kinh nghiệm cho chúng ta biết rằng những người có Buz nhìn chung gặp nhiều vấn đề hơn
hơn người dùng có DC10+/LML33. Ngoài ra, nó cho chúng ta biết rằng những người sở hữu VIA-
Mainboard (ktXXX, MVP3) gặp nhiều vấn đề hơn người dùng có Mainboard
dựa trên một chipset khác. Dưới đây là một số ghi chú của Andrew Stevens:

Đây là trải nghiệm của tôi khi sử dụng LML33 và Buz trên nhiều bo mạch chủ khác nhau:

- VIA MVP3
	- Quên nó đi. Vô nghĩa. Không hoạt động.
- Intel 430FX (Pentium 200)
	- LML33 hoàn hảo, chấp nhận được Buz (giảm 3 hoặc 4 khung hình trên mỗi phim)
- Intel 440BX (bước đầu)
	- LML33 có thể chấp nhận được. Buz bắt đầu khó chịu (6-10 khung hình/giờ)
- Intel 440BX (bước muộn)
	- Buz chấp nhận được, LML3 gần như hoàn hảo (thỉnh thoảng bị rớt một khung hình)
-SiS735
	- LML33 hoàn hảo, Buz chấp nhận được.
- VIA KT133(*)
	- LML33 bắt đầu khó chịu rồi, Buz tội nghiệp quá nên tôi phải lên.

- Cả hai bo mạch 440BX đều là phiên bản CPU kép.

Bernhard Praschinger sau đó đã nói thêm:

-AMD 751
	- Buz hoàn hảo-có thể chịu đựng được
-AMD 760
	- Buz hoàn hảo-có thể chịu đựng được

Nói chung, những người trong danh sách gửi thư của người dùng sẽ không cho bạn nhiều cơ hội
nếu bạn có bo mạch chủ dựa trên VIA. Chúng có thể rẻ, nhưng đôi khi, bạn sẽ
thay vì muốn chi thêm tiền cho những tấm ván tốt hơn. Nói chung, VIA
Hiệu suất IDE/PCI của bo mạch chính cũng sẽ rất tệ so với các bo mạch khác.
Bạn sẽ nhận thấy DC10+/DC30+ không được đề cập ở bất kỳ đâu trong phần tổng quan.
Về cơ bản, bạn có thể cho rằng nếu Buz hoạt động thì LML33 cũng sẽ hoạt động. Nếu
LML33 hoạt động, DC10+/DC30+ cũng sẽ hoạt động. Họ có khả năng chịu đựng tốt nhất
chipset bo mạch chính khác nhau từ tất cả các thẻ được hỗ trợ.

Nếu bạn gặp phải tình trạng hết thời gian chờ trong khi chụp, hãy mua bo mạch chính tốt hơn hoặc thấp hơn
chất lượng/kích thước bộ đệm trong quá trình chụp (xem phần 'Liên quan đến kích thước bộ đệm, chất lượng,
kích thước đầu ra, v.v.'). Nếu nó bị treo thì hiện tại chúng tôi không thể làm được gì nhiều. Kiểm tra
IRQ của bạn và đảm bảo thẻ có các ngắt riêng.

Giao diện lập trình
---------------------

Trình điều khiển này phù hợp với video4linux2. Hỗ trợ cho V4L1 và tùy chỉnh
zoran ioctls đã bị xóa trong kernel 2.6.38.

Để biết ví dụ về lập trình, vui lòng xem mã lavrec.c và lavplay.c trong
công cụ MJPEG (ZZ0000ZZ

Ghi chú bổ sung dành cho nhà phát triển phần mềm:

Trình điều khiển trả về các tham số maxwidth và maxheight theo
   tiêu chuẩn truyền hình hiện hành (chuẩn mực). Vì vậy, phần mềm mà
   giao tiếp với người lái xe và "yêu cầu" các thông số này
   đầu tiên thiết lập các tiêu chuẩn chính xác. Chà, có vẻ đúng về mặt logic: TV
   tiêu chuẩn là "không đổi" đối với quốc gia hiện tại so với hình học
   cài đặt của nhiều loại thẻ ghi TV có thể hoạt động trong ITU hoặc
   dạng pixel vuông.

Ứng dụng
------------

Các ứng dụng được biết là hoạt động với trình điều khiển này:

xem truyền hình:

* xawtv
* kwintv
* có thể là bất kỳ ứng dụng TV nào hỗ trợ video4linux hoặc video4linux2.

Chụp/phát lại MJPEG:

* mjpegtools/lavtools (hoặc Linux Video Studio)
* người truyền phát
* người chơi

Chụp thô chung:

* xawtv
* người truyền phát
* có thể là bất kỳ ứng dụng nào hỗ trợ video4linux hoặc video4linux2

Chỉnh sửa video:

* Rạp chiếu phim
* Diễn viên chính
* mjpegtools (hoặc Linux Video Studio)


Liên quan đến kích thước bộ đệm, chất lượng, kích thước đầu ra, v.v.
--------------------------------------------------


Zr36060 có thể nén JPEG 1:2. Đây thực sự là lý thuyết
mức tối đa mà chipset có thể đạt tới. Tuy nhiên, trình điều khiển có thể hạn chế việc nén
đến (kích thước) tối đa là 1:4. Lý do cho điều này là một số thẻ (ví dụ Buz)
không thể xử lý nén 1:2 mà không dừng chụp chỉ sau vài phút.
Với 1:4, nó hầu như sẽ hoạt động. Nếu bạn có Buz, hãy sử dụng 'low_bitrate=1' để truy cập
tối đa 1:4 chế độ nén.

Do đó, chất lượng 100% JPEG là nén 1:2 trong thực tế. Vì vậy để có một khung hình PAL đầy đủ
(kích thước 720x576). Các trường JPEG được lưu trữ ở định dạng YUY2, do đó kích thước của
các trường là 720x288x16/2 bit/trường (2 trường/khung) = 207360 byte/trường x 2 =
414720 byte/khung (thêm một số byte cho tiêu đề và DHT (huffman)/DQT
(lượng tử hóa) và bạn sẽ đạt được khoảng 512kB mỗi khung hình cho
nén 1:2. Để nén 1:4, bạn sẽ có khung hình có kích thước bằng một nửa.

Một số lời giải thích bổ sung của Martin Samuelsson, cũng giải thích
tầm quan trọng của kích thước bộ đệm:
--
> Hmm, tôi không nghĩ thực sự là như vậy. Với hiện tại (đã tải xuống
> lúc 18:00 Thứ Hai), tôi nhận được kích thước đầu ra đó trong 10 giây:
> -q 50 -b 128 : 24.283.332 Byte
> -q 50 -b 256 : 48.442.368
> -q 25 -b 128 : 24.655.992
> -q 25 -b 256 : 25.859.820

Tôi thức dậy và không thể ngủ lại được nữa. Tôi sẽ giết thời gian để giải thích tại sao
điều này có vẻ không lạ đối với tôi.

Hãy thực hiện một số phép toán bằng cách sử dụng chiều rộng 704 pixel. Tôi không chắc liệu Buz có
có thực sự sử dụng con số đó hay không, nhưng điều đó bây giờ không quá quan trọng.

704x288 pixel, một trường, là 202752 pixel. Chia cho 64 pixel mỗi khối;
3168 khối trên mỗi trường. Mỗi pixel bao gồm hai byte; 128 byte mỗi khối;
1024 bit mỗi khối. 100% trong trình điều khiển mới có nghĩa là nén 1:2; tối đa
đầu ra trở thành 512 bit trên mỗi khối. Thực tế là 510, nhưng 512 dễ sử dụng hơn
cho các tính toán.

Giả sử chúng tôi chỉ định d1q50. Do đó chúng tôi muốn 256 bit cho mỗi khối; lần 3168
trở thành 811008 bit; 101376 byte cho mỗi trường. Chúng ta đang nói về bit và byte thô
ở đây, vì vậy chúng ta không cần thực hiện bất kỳ chỉnh sửa cầu kỳ nào cho bit-per-pixel hoặc tương tự
mọi thứ. 101376 byte cho mỗi trường.

video d1 chứa hai trường trên mỗi khung hình. Tổng số đó lên tới 202752 byte mỗi
frame và một trong những khung đó sẽ đi vào từng bộ đệm.

Nhưng đợi một chút! -b128 cung cấp bộ đệm 128kB! Không thể nhồi nhét được
202752 byte dữ liệu JPEG thành 128kB!

Đây là điều mà người lái xe nhận thấy và tự động bù đắp cho bạn.
ví dụ. Hãy làm một số phép toán bằng cách sử dụng thông tin này:

128kB là 131072 byte. Trong bộ đệm này, chúng tôi muốn lưu trữ hai trường, trong đó
để lại 65536 byte cho mỗi trường. Sử dụng 3168 khối cho mỗi trường, chúng tôi nhận được
20.68686868... số byte có sẵn trên mỗi khối; 165 bit. Chúng tôi không thể cho phép
yêu cầu 256 bit cho mỗi khối khi chỉ có 165 bit! -q50
tùy chọn bị ghi đè âm thầm và tùy chọn -b128 được ưu tiên, để lại
us tương đương với -q32.

Điều này mang lại cho chúng tôi tốc độ dữ liệu 165 bit trên mỗi khối, nhân với 3168, tổng cộng
tới 65340 byte cho mỗi trường, trong số 65536 byte được phép. Trình điều khiển hiện tại có
một mức giới hạn tỷ lệ khác; nó sẽ không chấp nhận các giá trị -q lấp đầy nhiều hơn
6/8 của bộ đệm được chỉ định. (Tôi không chắc tại sao. "Chơi an toàn" dường như là
một sự đánh cược an toàn. Cá nhân tôi nghĩ rằng tôi sẽ giảm số bit được yêu cầu trên mỗi khối
bằng một hoặc thứ gì đó tương tự.) Chúng ta không thể sử dụng 165 bit cho mỗi khối, mà phải
lại hạ thấp nó xuống còn 6/8 dung lượng bộ đệm khả dụng: Chúng tôi kết thúc với 124 bit
mỗi khối, tương đương với -q24. Với bộ đệm 128kB, bạn không thể sử dụng bộ đệm lớn hơn
hơn -q24 tại -d1. (Và PAL, và chiều rộng 704 pixel...)

Ví dụ thứ ba được giới hạn ở -q24 thông qua quy trình tương tự. thứ hai
ví dụ: sử dụng các phép tính rất giống nhau, bị giới hạn ở -q48. duy nhất
ví dụ thực sự lấy giá trị -q đã chỉ định là ví dụ cuối cùng,
có thể nhìn thấy rõ ràng khi nhìn vào kích thước tập tin.
--

Kết luận: chất lượng của phim thu được phụ thuộc vào kích thước bộ đệm, chất lượng,
cho dù bạn có sử dụng tùy chọn 'low_bitrate=1' làm tùy chọn insmod cho zr36060.c hay không
mô-đun để thực hiện nén 1:4 thay vì nén 1:2, v.v.

Nếu bạn gặp phải tình trạng hết thời gian chờ, giảm chất lượng/kích thước bộ đệm hoặc sử dụng
'low_bitrate=1 làm tùy chọn insmod cho zr36060.o thực sự có thể hữu ích, cũng như vậy
được chứng minh bởi Buz.

Nó bị treo/bị treo/không thành công/sao cũng được! Giúp đỡ!
---------------------------------------

Đảm bảo rằng thẻ có các ngắt riêng (xem/proc/interrupt), kiểm tra
đầu ra của dmesg ở mức độ chi tiết cao (tải zr36067.o với debug=2,
tải tất cả các mô-đun khác với debug=1). Kiểm tra xem bo mạch chủ của bạn có thuận lợi không
(xem câu 2) còn nếu không được thì test card ở máy tính khác. Cũng xem
ghi chú được đưa ra trong câu hỏi 3 và thử giảm chất lượng/kích thước bộ đệm/chụp kích thước
nếu việc ghi không thành công sau một khoảng thời gian.

Nếu tất cả những điều này không giúp ích được gì, hãy mô tả rõ ràng vấn đề bao gồm
thông tin phần cứng chi tiết (bộ nhớ+nhãn hiệu, bo mạch chủ+chipset+nhãn hiệu,
Thẻ MJPEG, bộ xử lý, các thẻ PCI khác có thể được quan tâm), hãy cung cấp
thông tin PnP của hệ thống (/proc/interrupt, /proc/dma, /proc/devices) và cung cấp
phiên bản kernel, phiên bản trình điều khiển, phiên bản glibc, phiên bản gcc và bất kỳ phiên bản nào khác
những thông tin có thể sẽ được quan tâm. Đồng thời cung cấp đầu ra dmesg
ở mức độ chi tiết cao. Xem phần 'Liên hệ' để biết cách liên hệ với nhà phát triển.

Người bảo trì/Liên hệ
----------------------

Những người bảo trì/phát triển trước đây của trình điều khiển này là
- Laurent Pinchart <laurent.pinchart@skynet.be>
- Ronald Bultje rbultje@ronald.bitfreak.net
- Serguei Miridonov <mirsev@cicese.mx>
- Wolfgang Scherr <scherr@net4you.net>
- Dave Perks <dperks@ibm.net>
- Rainer Johanni <Rainer@Johanni.de>

Giấy phép lái xe
----------------

Trình điều khiển này được phân phối theo các điều khoản của Giấy phép Công cộng Chung.

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
    nó theo các điều khoản của Giấy phép Công cộng GNU được xuất bản bởi
    Tổ chức Phần mềm Tự do; phiên bản 2 của Giấy phép, hoặc
    (theo lựa chọn của bạn) bất kỳ phiên bản mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
    nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
    MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
    Giấy phép Công cộng GNU để biết thêm chi tiết.

Xem ZZ0000ZZ để biết thêm thông tin.