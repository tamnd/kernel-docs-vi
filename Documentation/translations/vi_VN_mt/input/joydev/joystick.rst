.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/joydev/joystick.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. _joystick-doc:

Giới thiệu
============

Trình điều khiển cần điều khiển cho Linux cung cấp hỗ trợ cho nhiều loại cần điều khiển
và các thiết bị tương tự. Nó dựa trên một dự án lớn hơn nhằm hỗ trợ tất cả
thiết bị đầu vào trong Linux.

Danh sách gửi thư cho dự án là:

linux-input@vger.kernel.org

gửi "đăng ký linux-input" tới Majordomo@vger.kernel.org để đăng ký nó.

Cách sử dụng
============

Để sử dụng cơ bản, bạn chỉ cần chọn các tùy chọn phù hợp trong cấu hình kernel và
bạn nên được thiết lập.

Tiện ích
---------

Để thử nghiệm và các mục đích khác (ví dụ: thiết bị nối tiếp), có một bộ
các tiện ích, chẳng hạn như ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ,
thường được đóng gói dưới dạng ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, v.v.

Cần có tiện ích ZZ0000ZZ nếu cần điều khiển của bạn được kết nối với
cổng nối tiếp.

Nút thiết bị
------------

Để các ứng dụng có thể sử dụng cần điều khiển, các nút thiết bị phải được
được tạo trong/dev. Thông thường việc này được hệ thống thực hiện tự động, nhưng
nó cũng có thể được thực hiện bằng tay::

cd /dev
    rm js*
    đầu vào mkdir
    đầu vào mknod/js0 c 13 0
    đầu vào mknod/js1 c 13 1
    đầu vào mknod/js2 c 13 2
    đầu vào mknod/js3 c 13 3
    ln -s đầu vào/js0 js0
    ln -s đầu vào/js1 js1
    ln -s đầu vào/js2 js2
    ln -s đầu vào/js3 js3

Để thử nghiệm với inpututils, việc tạo những thứ này cũng rất thuận tiện::

đầu vào/sự kiện mknod0 c 13 64
    đầu vào/sự kiện mknod1 c 13 65
    mknod đầu vào/sự kiện2 c 13 66
    đầu vào/sự kiện mknod3 c 13 67

Các mô-đun cần thiết
--------------------

Để tất cả các trình điều khiển cần điều khiển hoạt động, bạn sẽ cần giao diện người dùng
mô-đun trong kernel, được tải hoặc biên dịch trong ::

modprobe joydev

Đối với cần điều khiển gameport, bạn cũng sẽ phải tải trình điều khiển gameport ::

modprobe ns558

Và đối với cần điều khiển cổng nối tiếp, bạn sẽ cần dòng đầu vào nối tiếp
mô-đun kỷ luật đã được tải và tiện ích inputattach bắt đầu::

dịch vụ modprobe
	đầu vàođính kèm -xxx /dev/tts/X &

Ngoài ra, hầu hết bạn sẽ cần có mô-đun trình điều khiển cần điều khiển.
thông thường bạn sẽ có cần điều khiển analog::

modprobe tương tự

Để tải mô-đun tự động, một cái gì đó như thế này có thể hoạt động - điều chỉnh cho phù hợp
nhu cầu của bạn::

bí danh dịch vụ tty-ldisc-2
	đầu vào bí danh char-major-13
	ở trên đầu vào analog joydev ns558
	tùy chọn bản đồ analog=gamepad,none,2btn

Xác minh rằng nó hoạt động
--------------------------

Để kiểm tra chức năng trình điều khiển cần điều khiển, có jstest
chương trình trong gói tiện ích. Bạn chạy nó bằng cách gõ::

jstest/dev/đầu vào/js0

Và nó sẽ hiển thị một dòng có các giá trị cần điều khiển, cập nhật khi bạn
di chuyển thanh và nhấn các nút của nó. Tất cả các trục sẽ bằng 0 khi
cần điều khiển ở vị trí trung tâm. Họ không nên bồn chồn một mình để
các giá trị đóng khác và chúng cũng phải ổn định ở bất kỳ vị trí nào khác của
cây gậy. Chúng phải có phạm vi đầy đủ từ -32767 đến 32767. Nếu tất cả điều này
được đáp ứng thì mọi chuyện sẽ ổn và bạn có thể chơi trò chơi. :)

Nếu không, thì có thể có vấn đề. Hãy thử hiệu chỉnh cần điều khiển,
và nếu nó vẫn không hoạt động, hãy đọc phần trình điều khiển của tệp này,
phần khắc phục sự cố và FAQ.

Sự định cỡ
-----------

Đối với hầu hết các cần điều khiển, bạn sẽ không cần hiệu chỉnh thủ công vì
cần điều khiển phải được trình điều khiển tự động hiệu chỉnh. Tuy nhiên, với
một số cần điều khiển tương tự không sử dụng điện trở tuyến tính hoặc nếu bạn
muốn độ chính xác cao hơn, bạn có thể sử dụng chương trình jscal ::

jscal -c /dev/input/js0

được bao gồm trong gói cần điều khiển để thiết lập hệ số hiệu chỉnh tốt hơn
những gì người lái xe sẽ tự chọn.

Sau khi hiệu chỉnh cần điều khiển, bạn có thể xác minh xem bạn có thích cái mới không
hiệu chỉnh bằng lệnh jstest và nếu thực hiện như vậy thì bạn có thể lưu
hệ số hiệu chỉnh vào một tập tin::

jscal -p /dev/input/js0 > /etc/joystick.cal

Và thêm một dòng vào tập lệnh RC của bạn để thực thi tệp đó ::

nguồn /etc/joystick.cal

Bằng cách này, sau lần khởi động lại tiếp theo, phím điều khiển của bạn sẽ vẫn được hiệu chỉnh. bạn
cũng có thể thêm dòng ZZ0000ZZ vào tập lệnh tắt máy của bạn.

Thông tin trình điều khiển dành riêng cho phần cứng
===================================================

Trong phần này, mỗi trình điều khiển phần cứng riêng biệt sẽ được mô tả.

Cần điều khiển analog
---------------------

Trình điều khiển analog.c sử dụng đầu vào analog tiêu chuẩn của gameport và do đó
hỗ trợ tất cả các cần điều khiển và gamepad tiêu chuẩn. Nó sử dụng một công nghệ rất tiên tiến
thường lệ cho việc này, cho phép dữ liệu có độ chính xác cao mà không thể tìm thấy trên bất kỳ
hệ thống khác.

Nó cũng hỗ trợ các tiện ích mở rộng như mũ và nút bổ sung tương thích
với CH Flightstick Pro, ThrustMaster FCS hoặc gamepad 6 và 8 nút. saitek
Cần điều khiển 'kỹ thuật số' Cyborg cũng được trình điều khiển này hỗ trợ, bởi vì
về cơ bản họ đã cải tiến các que CHF.

Tuy nhiên, các loại duy nhất có thể được tự động phát hiện là:

* Cần điều khiển 2 trục, 4 nút
* Cần điều khiển 3 trục, 4 nút
* Cần điều khiển 4 trục, 4 nút
* Cần điều khiển 'kỹ thuật số' Saitek Cyborg

Hỗ trợ các loại cần điều khiển khác (nhiều/ít trục, mũ và nút)
bạn sẽ cần chỉ định các loại trên dòng lệnh kernel hoặc trên
dòng lệnh mô-đun, khi chèn analog vào kernel. các
các thông số là::

analog.map=<type1>,<type2>,<type3>,....

'loại' là loại cần điều khiển từ bảng bên dưới, xác định cần điều khiển
hiện diện trên các gameport trong hệ thống, bắt đầu bằng gameport0, 'loại' thứ hai
mục xác định cần điều khiển trên gameport1, v.v.

====================================================================
	Loại Ý nghĩa
	====================================================================
	không có cần điều khiển analog trên cổng đó
	cần điều khiển tự động phát hiện
	Cần điều khiển trục n 2 nút 2btn
	y-joy Hai cần điều khiển 2 nút 2 trục trên cáp chữ Y
	y-pad Hai gamepad 2 nút 2 trục trên cáp chữ Y
	Cần điều khiển tương thích fcs Thrustmaster FCS
	chf Cần điều khiển với mũ tương thích CH Flightstick
	fullchf CH Flightstick tương thích với 2 mũ và 6 nút
	gamepad Tay cầm chơi game n trục 4/6 nút
	gamepad8 Tay cầm chơi game 8 nút 2 trục
	====================================================================

Trong trường hợp cần điều khiển của bạn không phù hợp với bất kỳ loại nào ở trên, bạn có thể
chỉ định loại dưới dạng số bằng cách kết hợp các bit trong bảng bên dưới. Cái này
không được khuyến khích trừ khi bạn thực sự biết bạn đang làm gì. Nó không phải
nguy hiểm nhưng cũng không hề đơn giản.

==== ============================
	Ý nghĩa bit
	==== ============================
	 0 Trục X1
	 1 trục Y1
	 2 trục X2
	 3 trục Y2
	 4 nút A
	 5 nút B
	 6 nút C
	 7 Nút D
	 8 nút CHF X và Y
	 9 CHF Mũ 1
	10 CHF Mũ 2
	Mũ 11 FCS
	12 Nút Pad X
	13 Nút Pad Y
	14 Nút Pad U
	15 Nút Pad V
	16 Nút Saitek F1-F4
	17 Chế độ kỹ thuật số Saitek
	19 Máy chơi game
	20 Trục Joy2 X1
	21 Joy2 Trục Y1
	22 trục Joy2 X2
	23 Joy2 Trục Y2
	24 Nút Joy2 A
	25 Nút Joy2 B
	26 Nút Joy2 C
	27 Nút Joy2 D
	31 Tay cầm chơi game Joy2
	==== ============================

Cần điều khiển Microsoft SideWinder
-----------------------------------

Giao thức 'Digital Overdrive' của Microsoft được sidewinder.c hỗ trợ
mô-đun. Tất cả các cần điều khiển hiện được hỗ trợ:

* Microsoft SideWinder 3D Pro
* Microsoft SideWinder Force Phản hồi Pro
* Bánh xe phản hồi lực lượng Microsoft SideWinder
* Microsoft SideWinder FreeStyle Pro
* Microsoft SideWinder GamePad (tối đa bốn, được xâu chuỗi)
* Microsoft SideWinder Precision Pro
* Microsoft SideWinder Precision Pro USB

được tự động phát hiện và do đó không cần tham số mô-đun.

Có một lưu ý với 3D Pro. Có 9 nút báo cáo,
mặc dù cần điều khiển chỉ có 8. Nút thứ 9 là nút chuyển chế độ trên
mặt sau của cần điều khiển. Tuy nhiên, khi di chuyển nó, bạn sẽ đặt lại cần điều khiển,
và làm cho nó không phản hồi trong khoảng một phần ba giây. Hơn nữa,
cần điều khiển cũng sẽ tự căn giữa lại, giữ nguyên vị trí của nó trong khi
lần này là vị trí trung tâm mới. Sử dụng nó nếu bạn muốn, nhưng hãy suy nghĩ trước.

Tiêu chuẩn SideWinder không phải là cần điều khiển kỹ thuật số và do đó được hỗ trợ
bằng trình điều khiển analog được mô tả ở trên.

Thiết bị Logitech ADI
---------------------

Giao thức Logitech ADI được mô-đun adi.c hỗ trợ. Nó nên hỗ trợ
bất kỳ thiết bị Logitech nào sử dụng giao thức này. Điều này bao gồm, nhưng không giới hạn
đến:

* Logitech CyberMan 2
* Logitech ThunderPad kỹ thuật số
* Logitech WingMan Extreme Digital
* Công thức Logitech WingMan
* Thiết bị đánh chặn Logitech WingMan
* Máy chơi game Logitech WingMan
* Logitech WingMan GamePad USB
* Logitech WingMan GamePad Extreme
* Logitech WingMan Extreme Digital 3D

Các thiết bị ADI được tự động phát hiện và trình điều khiển hỗ trợ tối đa hai (bất kỳ
kết hợp) các thiết bị trên một cổng trò chơi duy nhất, sử dụng cáp chữ Y hoặc dây xích
cùng nhau.

Cần điều khiển Logitech WingMan, Logitech WingMan Attack, Logitech WingMan
Extreme và Logitech WingMan ThunderPad không phải là cần điều khiển kỹ thuật số và là
được xử lý bởi trình điều khiển tương tự được mô tả ở trên. Chiến binh Logitech WingMan và
Logitech Magellan được hỗ trợ bởi trình điều khiển nối tiếp được mô tả bên dưới.  Logitech
WingMan Force và Logitech WingMan Formula Force được hỗ trợ bởi
Trình điều khiển I-Force được mô tả bên dưới. Logitech CyberMan chưa được hỗ trợ.

Gravis GrIP
-----------

Giao thức Gravis GrIP được mô-đun Grip.c hỗ trợ. Nó hiện tại
hỗ trợ:

* Gravis GamePad Pro
* Gravis BlackHawk kỹ thuật số
* Kẻ hủy diệt Gravis
* Gravis Xterminator DualControl

Tất cả các thiết bị này đều được tự động phát hiện và thậm chí bạn có thể sử dụng bất kỳ kết hợp nào
tối đa hai miếng đệm này được nối với nhau hoặc sử dụng cáp chữ Y trên
cổng trò chơi duy nhất.

GrIP MultiPort chưa được hỗ trợ. Gravis Stinger là một thiết bị nối tiếp và được
được hỗ trợ bởi trình điều khiển ngòi. Các cần điều khiển Gravis khác được hỗ trợ bởi
trình điều khiển tương tự.

FPGaming A3D và MadCatz A3D
----------------------------

Giao thức Assassin 3D được tạo bởi FPGaming, được cả FPGaming sử dụng
của họ và được cấp phép cho MadCatz. Các thiết bị A3D được hỗ trợ bởi
mô-đun a3d.c. Nó hiện hỗ trợ:

* Sát thủ FPGaming 3D
* Báo MadCatz
* MadCatz Panther XL

Tất cả các thiết bị này đều được tự động phát hiện. Bởi vì Assassin 3D và Panther
cho phép kết nối cần điều khiển analog với chúng, bạn sẽ cần tải analog
người lái xe cũng có thể xử lý các cần điều khiển kèm theo.

Bi xoay sẽ hoạt động với mô-đun mousedev USB như một con chuột bình thường. Xem
tài liệu USB về cách thiết lập chuột USB.

ThrustMaster DirectConnect (BSP)
--------------------------------

Giao thức TM DirectConnect (BSP) được hỗ trợ bởi tmdc.c
mô-đun. Điều này bao gồm nhưng không giới hạn ở:

* Thiết bị chặn 3D ThrustMaster Millennium
* ThrustMaster 3D Rage Pad
* Bàn chơi game kỹ thuật số ThrustMaster Fusion

Các thiết bị không được hỗ trợ trực tiếp nhưng hy vọng sẽ hoạt động là:

* ThrustMaster FragMaster
* Van tiết lưu tấn công ThrustMaster

Nếu bạn có một trong những thứ này, hãy liên hệ với tôi.

Các thiết bị TMDC được tự động phát hiện và do đó không có tham số nào cho mô-đun
là cần thiết. Có thể kết nối tối đa hai thiết bị TMDC với một cổng trò chơi bằng cách sử dụng
một cáp chữ Y.

Blaster phòng thí nghiệm sáng tạo
---------------------------------

Giao thức Blaster được hỗ trợ bởi mô-đun cobra.c. Nó chỉ hỗ trợ
cái:

* Creative Blaster GamePad Cobra

Có thể sử dụng tối đa hai trong số này trên một cổng trò chơi bằng cáp chữ Y.

Cần điều khiển kỹ thuật số Genius
---------------------------------

Cần điều khiển giao tiếp kỹ thuật số Genius được hỗ trợ bởi gf2k.c
mô-đun. Điều này bao gồm:

* Cần điều khiển Genius Flight2000 F-23
* Cần điều khiển Genius Flight2000 F-31
* Tay cầm chơi game Genius G-09D

Các cần điều khiển kỹ thuật số Genius khác chưa được hỗ trợ nhưng có thể hỗ trợ
thêm vào khá dễ dàng.

Cần điều khiển kỹ thuật số InterAct
-----------------------------------

Cần điều khiển giao tiếp kỹ thuật số InterAct được hỗ trợ bởi
mô-đun tương tác.c. Điều này bao gồm:

* Tay cầm chơi game InterAct HammerHead/FX
* Tay cầm chơi game InterAct ProPad8

Các cần điều khiển kỹ thuật số InterAct khác chưa được hỗ trợ nhưng có thể hỗ trợ
thêm vào khá dễ dàng.

Thẻ game PDPI Lightning 4
--------------------------

Thẻ trò chơi PDPI Lightning 4 được hỗ trợ bởi mô-đun Lightning.c.
Sau khi mô-đun được tải, trình điều khiển analog có thể được sử dụng để xử lý
cần điều khiển. Cần điều khiển giao tiếp kỹ thuật số sẽ chỉ hoạt động trên cổng 0, trong khi
bằng cách sử dụng cáp chữ Y, bạn có thể kết nối tối đa 8 cần điều khiển analog với một L4 duy nhất
thẻ, 16 trong trường hợp bạn có hai thẻ trong hệ thống của mình.

Cây đinh ba 4DWave / Aureal Vortex
----------------------------------

Card âm thanh có chipset Trident 4DWave DX/NX hoặc Aureal Vortex/Vortex2
cung cấp chế độ "Cổng trò chơi nâng cao" trong đó soundcard xử lý việc bỏ phiếu
cần điều khiển.  Chế độ này được hỗ trợ bởi mô-đun pcigame.c. Sau khi tải
trình điều khiển analog có thể sử dụng các tính năng nâng cao của các gameport này..

Crystal SoundFusion
-------------------

Card âm thanh với chipset Crystal SoundFusion cung cấp "Trò chơi nâng cao"
Port", giống như 4DWave hoặc Vortex ở trên. Chế độ này và cả chế độ bình thường
đối với cổng SoundFusion được mô-đun cs461x.c hỗ trợ.

SoundBlaster trực tiếp!
-----------------------

Trực tiếp! có một gameport PCI đặc biệt, mặc dù nó không cung cấp
bất kỳ nội dung "Nâng cao" nào như 4DWave và bạn bè đều nhanh hơn một chút so với
đối tác ISA của nó. Nó cũng cần sự hỗ trợ đặc biệt, do đó
mô-đun emu10k1-gp.c cho nó thay vì mô-đun ns558.c thông thường.

SoundBlaster 64 và 128 - ES1370 và ES1371, ESS Solo1 và S3 SonicVibes
------------------------------------------------------------------------

Các card âm thanh PCI này có các cổng trò chơi cụ thể. Chúng được xử lý bởi
bản thân trình điều khiển âm thanh. Đảm bảo bạn chọn hỗ trợ gameport trong
menu phím điều khiển và hỗ trợ card âm thanh trong menu âm thanh phù hợp với bạn
thẻ.

Amiga
-----

Cần điều khiển Amiga, được kết nối với Amiga, được hỗ trợ bởi amijoy.c
người lái xe. Vì chúng không thể được tự động phát hiện nên trình điều khiển có một dòng lệnh:

amijoy.map=<a>,<b>

a và b xác định các cần điều khiển được kết nối với cổng JOY0DAT và JOY1DAT của
Amiga.

====================================
	Loại cần điều khiển giá trị
	====================================
	  0 Không có
	  1 cần điều khiển kỹ thuật số 1 nút
	====================================

Hiện tại không còn loại cần điều khiển nào được hỗ trợ nữa, nhưng điều đó sẽ thay đổi trong
tương lai nếu tôi có được một chiếc Amiga trong tầm tay.

Bảng điều khiển trò chơi và miếng đệm và cần điều khiển 8 bit
-------------------------------------------------------------

Những miếng đệm và cần điều khiển này không được thiết kế cho PC và các máy tính khác
Linux vẫn chạy và thường yêu cầu một đầu nối đặc biệt để gắn
chúng thông qua một cổng song song.

Xem ZZ0000ZZ để biết thêm thông tin.

Thiết bị SpaceTec/LabTec
------------------------

Các thiết bị nối tiếp SpaceTec giao tiếp bằng giao thức SpaceWare. Đó là
được hỗ trợ bởi trình điều khiển spaceorb.c và spaceball.c. Các thiết bị hiện nay
được hỗ trợ bởi spaceorb.c là:

* SpaceTec SpaceBall Avenger
* SpaceTec SpaceOrb 360

Các thiết bị hiện được Spaceball.c hỗ trợ là:

* SpaceTec SpaceBall 4000 FLX

Ngoài việc có các mô-đun quỹ đạo/quả cầu vũ trụ và dịch vụ trong
kernel, bạn cũng cần gắn một cổng nối tiếp vào nó. Để làm điều đó, hãy chạy
chương trình đính kèm đầu vào::

đầu vàođính kèm --spaceorb /dev/tts/x &

hoặc::

đầu vàođính kèm --spaceball /dev/tts/x &

trong đó /dev/tts/x là cổng nối tiếp mà thiết bị được kết nối. Sau
làm điều này, thiết bị sẽ được báo cáo và sẽ bắt đầu hoạt động.

Có một cảnh báo với SpaceOrb. Nút #6, nút ở phía dưới
bên của quả cầu, mặc dù được báo cáo là một nút thông thường, gây ra hiện tượng bên trong
việc thu hồi quả cầu không gian, di chuyển điểm 0 đến vị trí trong đó
quả bóng đang ở thời điểm nhấn nút. Vì vậy, hãy suy nghĩ trước khi
bạn liên kết nó với một số chức năng khác.

SpaceTec SpaceBall 2003 FLX và 3003 FLX chưa được hỗ trợ.

Thiết bị Logitech SWIFT
-----------------------

Giao thức nối tiếp SWIFT được hỗ trợ bởi mô-đun Warrior.c. Nó
hiện chỉ hỗ trợ:

* Chiến binh Logitech WingMan

nhưng trong tương lai, Logitech CyberMan (bản gốc, không phải CM2) có thể
cũng được hỗ trợ. Để sử dụng mô-đun, bạn cần chạy inputattach sau khi bạn
chèn/biên dịch mô-đun vào kernel của bạn ::

đầu vàođính kèm --chiến binh/dev/tts/x &

/dev/tts/x là cổng nối tiếp mà Warrior của bạn được gắn vào.

Magellan / Chuột không gian
---------------------------

Magellan (hoặc Chuột không gian), được sản xuất bởi LogiCad3d (trước đây là Space
Systems), đối với nhiều công ty khác (Logitech, HP, ...) được hỗ trợ bởi
mô-đun joy-magellan. Nó hiện chỉ hỗ trợ:

* Magellan 3D
* Chuột không gian

mô hình; các nút bổ sung trên phiên bản 'Plus' chưa được hỗ trợ.

Để sử dụng nó, bạn cần gắn cổng nối tiếp vào trình điều khiển bằng cách sử dụng ::

đầu vàođính kèm --magellan /dev/tts/x &

yêu cầu. Sau đó Magellan sẽ được phát hiện, khởi tạo, sẽ phát ra tiếng bíp,
và thiết bị /dev/input/jsX sẽ có thể sử dụng được.

Thiết bị I-Force
----------------

Tất cả các thiết bị I-Force đều được hỗ trợ bởi mô-đun iforce. Điều này bao gồm:

* AVB Mag Turbo Lực lượng
* AVB Pegasus bắn đỉnh
* Bánh xe đua phản hồi lực bắn hàng đầu AVB
* Bánh xe phản hồi lực Boeder
* Lực lượng Logitech WingMan
* Bánh xe lực Logitech WingMan
* Phản hồi của lực lượng lãnh đạo cuộc đua Guillemot
* Bánh xe đua phản hồi lực Guillemot
* Thrustmaster Motor Sport GT

Để sử dụng nó, bạn cần gắn cổng nối tiếp vào trình điều khiển bằng cách sử dụng ::

đầu vàođính kèm --iforce /dev/tts/x &

yêu cầu. Sau đó, thiết bị I-Force sẽ được phát hiện và
Thiết bị /dev/input/jsX sẽ có thể sử dụng được.

Trong trường hợp bạn đang sử dụng thiết bị qua cổng USB, lệnh inputattach
không cần thiết.

Trình điều khiển I-Force hiện hỗ trợ phản hồi lực thông qua giao diện sự kiện.

Xin lưu ý rằng các thiết bị Logitech WingMan 3D _không_ được hỗ trợ bởi điều này
mô-đun, thay vì ẩn. Phản hồi bắt buộc không được hỗ trợ cho các thiết bị đó.
Gamepad của Logitech cũng là thiết bị ẩn.

Tay cầm chơi game Gravis Stinger
--------------------------------

Tay cầm chơi game cổng nối tiếp Gravis Stinger, được thiết kế để sử dụng với máy tính xách tay
máy tính, được hỗ trợ bởi mô-đun Stinger.c. Để sử dụng nó, hãy đính kèm
cổng nối tiếp tới trình điều khiển bằng cách sử dụng::

đầu vàođính kèm --stinger /dev/tty/x &

trong đó x là số cổng nối tiếp.

Khắc phục sự cố
===============

Khả năng cao là bạn sẽ gặp phải một số vấn đề. cho
kiểm tra xem driver có hoạt động không, nếu nghi ngờ hãy sử dụng tiện ích jstest trong
một số chế độ của nó. Các chế độ hữu ích nhất là "bình thường" - đối với 1.x
giao diện và "cũ" cho giao diện "0.x". Bạn chạy nó bằng cách gõ::

jstest --normal/dev/input/js0
	jstest --old/dev/input/js0

Ngoài ra, bạn có thể thực hiện kiểm tra với tiện ích evtest ::

evtest /dev/input/event0

Ồ, và hãy đọc FAQ! :)

FAQ
===

:Q: Chạy 'jstest /dev/input/js0' dẫn đến lỗi "Không tìm thấy tệp". cái gì vậy
    nguyên nhân?
:A: Các tập tin thiết bị không tồn tại. Tạo chúng (xem phần 2.2).

:Q: Có thể kết nối cần điều khiển Atari/Commodore/Amiga/console cũ của tôi không
    hoặc pad sử dụng đầu nối Cannon loại D 9 chân tới cổng nối tiếp của máy tính của tôi
    Máy tính?
:A: Có, có thể được, nhưng nó sẽ đốt cháy cổng nối tiếp hoặc bảng đệm của bạn. Nó
    tất nhiên là sẽ không hiệu quả.

:Q: Cần điều khiển của tôi không hoạt động với Quake/Quake 2. Nguyên nhân là gì?
:A: Quake / Quake 2 không hỗ trợ cần điều khiển. Sử dụng joy2key để mô phỏng thao tác nhấn phím
    cho họ.
