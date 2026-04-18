.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/input/devices/joystick-parport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

.. _joystick-parport:

=================================
Trình điều khiển cần điều khiển cổng song song
==============================

:Bản quyền: ZZ0000ZZ 1998-2000 Vojtech Pavlik <vojtech@ucw.cz>
:Bản quyền: ZZ0001ZZ 1998 Andree Borrmann <a.borrmann@tu-bs.de>


Được tài trợ bởi SuSE

Tuyên bố miễn trừ trách nhiệm
==========

Mọi thông tin trong tập tin này được cung cấp nguyên trạng mà không có bất kỳ sự đảm bảo nào rằng
nó sẽ là sự thật. Vì vậy, sử dụng nó có nguy cơ của riêng bạn. Những thiệt hại có thể xảy ra
xảy ra bao gồm việc đốt cổng song song của bạn và/hoặc gậy và cần điều khiển
và thậm chí có thể hơn thế nữa. Giống như khi một tia sét giết chết bạn thì đó không phải là vấn đề của chúng tôi.

Giới thiệu
============

Trình điều khiển parport cần điều khiển được sử dụng cho cần điều khiển và gamepad không
ban đầu được thiết kế cho PC và các máy tính khác chạy Linux. Bởi vì
rằng PC thường thiếu cổng phù hợp để kết nối các thiết bị này. Song song
cổng, vì khả năng thay đổi từng bit theo ý muốn và cung cấp
cả hai bit đầu ra và đầu vào đều là cổng phù hợp nhất trên PC cho
kết nối các thiết bị như vậy.

Thiết bị được hỗ trợ
=================

Nhiều bảng điều khiển và gamepad máy tính 8-bit và cần điều khiển được hỗ trợ. các
các phần phụ sau đây thảo luận về cách sử dụng của từng phần.

NES và SNES
------------

Hệ thống giải trí Nintendo và Hệ thống giải trí Super Nintendo
gamepad có sẵn rộng rãi và dễ dàng mua được. Ngoài ra, chúng còn khá dễ dàng
kết nối với PC và không cần nhiều tốc độ xử lý (108 us cho NES và
165 us cho SNES, so với khoảng 1000 us cho gamepad PC) để giao tiếp
với họ.

Tất cả NES và SNES đều sử dụng cùng một giao thức nối tiếp đồng bộ, được chạy từ
phía máy tính (và do đó không nhạy cảm với thời gian). Để cho phép tối đa 5 NES
và/hoặc gamepad SNES và/hoặc chuột SNES được kết nối với cổng song song cùng một lúc,
các đường đầu ra của cổng song song được chia sẻ, trong khi một trong 5 đường có sẵn
dòng đầu vào được gán cho mỗi gamepad.

Giao thức này được xử lý bởi trình điều khiển gamecon.c, vì vậy đó là giao thức
bạn sẽ sử dụng cho gamepad NES, SNES và chuột SNES.

Vấn đề chính với các cổng song song của PC là chúng không có nguồn +5V
nguồn trên bất kỳ chân nào của họ. Vì vậy, nếu bạn muốn có một nguồn năng lượng đáng tin cậy
đối với các miếng đệm của bạn, hãy sử dụng bàn phím hoặc cổng cần điều khiển và thực hiện chuyển tiếp
cáp. Bạn cũng có thể rút nguồn trực tiếp từ nguồn điện (màu đỏ
dây là +5V).

Nếu bạn chỉ muốn sử dụng cổng song song, bạn có thể lấy nguồn từ
một số pin dữ liệu. Đối với hầu hết các triển khai gamepad và parport, chỉ có một pin là
cần thiết và tôi khuyên bạn nên sử dụng chân 9 cho bit dữ liệu cao nhất. Mặt khác
tay, nếu bạn không định sử dụng bất cứ thứ gì khác ngoài NES / SNES trên
cổng, mọi thứ ở giữa và bao gồm chân 4 và chân 9 sẽ hoạt động ::

(chân 9) ------> Nguồn

Thật không may, có những miếng đệm cần nhiều năng lượng hơn và song song
các cổng không thể cung cấp nhiều dòng điện qua các chân dữ liệu. Nếu đây là của bạn
trường hợp, bạn sẽ cần sử dụng điốt (để ngăn chặn việc phá hủy song song của bạn
port) và kết hợp dòng điện của hai hoặc nhiều bit dữ liệu với nhau ::

Điốt
    (chân 9) ----ZZ0000ZZ-------+------> Nguồn
			|
    (chân 8) ----ZZ0001ZZ-------+
			|
    (chân 7) ----ZZ0002ZZ-------+
			|
    <và vân vân> :
			|
    (chân 4) ----ZZ0003ZZ-------+

Việc tiếp đất khá dễ dàng. Trên cổng song song của PC, mặt đất nằm trên bất kỳ cổng nào
các chân từ chân 18 đến chân 25. Vì vậy, hãy sử dụng bất kỳ chân nào trong số này mà bạn thích cho nối đất::

(chân 18) -----> Nối đất

Các miếng đệm NES và SNES có hai bit đầu vào, Đồng hồ và Chốt, điều khiển
chuyển nối tiếp. Chúng được kết nối với chân 2 và 3 của cổng song song,
tương ứng::

(chân 2) -----> Đồng hồ
    (chân 3) ------> Chốt

Và thứ cuối cùng chính là dây dữ liệu NES/SNES. Chỉ có điều đó là không được chia sẻ và
mỗi pad cần pin dữ liệu riêng của mình. Các chân cổng song song là::

(chân 10) -----> Dữ liệu Pad 1
    (chân 11) ------> Dữ liệu Pad 2
    (chân 12) ------> Dữ liệu Pad 3
    (chân 13) -----> Dữ liệu Pad 4
    (chân 15) -----> Dữ liệu Pad 5

Lưu ý rằng chân 14 không được sử dụng vì nó không phải là chân đầu vào trên đường dây song song.
cổng.

Đây là mọi thứ bạn cần ở phía kết nối của PC, bây giờ hãy chuyển sang
phía gamepad. NES và SNES có các đầu nối khác nhau. Ngoài ra còn có
có khá nhiều bản sao NES và vì Nintendo đã sử dụng độc quyền
các đầu nối cho máy của họ, còn người nhân bản thì không thể và sử dụng D-Cannon tiêu chuẩn
đầu nối. Dù sao đi nữa, nếu bạn có một gamepad và nó có các nút A, B, Turbo
A, Turbo B, Chọn và Khởi động, và được kết nối qua 5 dây, thì đó là
bản sao NES hoặc NES và sẽ hoạt động với kết nối này. Tay cầm chơi game SNES
cũng dùng 5 dây nhưng có nhiều nút hơn. Tất nhiên, chúng cũng sẽ hoạt động::

Pinout cho gamepad NES Pinout cho gamepad và chuột SNES

+----> Nguồn +--------------\
             ZZ0000ZZ o o o o ZZ0001ZZ 1
   5 +----------+ 7 +--------------/
     ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ
     ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ +-> Mặt đất
   4 +-------------+ 1 ZZ0008ZZ |  +----------->Dữ liệu
       ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ +---------------> Chốt
       ZZ0012ZZ ZZ0013ZZ +------------------> Đồng hồ
       ZZ0014ZZ +----> Đồng hồ +-----------------------> Nguồn
       |  +-------> Chốt
       +----------> Dữ liệu

Sơ đồ chân cho gamepad bản sao (db9) NES Sơ đồ chân cho gamepad bản sao NES (db15)

+---------> Đồng hồ +-----------------> Dữ liệu
        ZZ0001ZZ +---> Mặt đất
        ZZ0002ZZ +------> Dữ liệu ZZ0003ZZ
        ZZ0004ZZ |                              ___________________
    _____________ 8 \ o x x x x x x o / 1
  5 \ x o o o x / 1 \ o x x o x x o /
     \ x o x o / 15 ZZ0000ZZ~~~~~~~' 6 ZZ0005ZZ |
         ZZ0006ZZ ZZ0007ZZ +----> Đồng hồ
         ZZ0008ZZ +----------> Chốt
         +--------> Nối đất +----------------> Nguồn điện

Cần điều khiển đa hệ thống
---------------------

Trong kỷ nguyên của máy 8 bit, có một thứ gì đó giống như tiêu chuẩn thực tế
cho các cổng cần điều khiển. Tất cả đều là kỹ thuật số và đều sử dụng chân D-Cannon 9
đầu nối (db9). Do đó, có thể sử dụng một cần điều khiển duy nhất mà không cần
rắc rối trên Atari (130, 800XE, 800XL, 2600, 7200), Amiga, Commodore C64,
Amstrad CPC, Sinclair ZX Spectrum và nhiều máy khác. Đó là lý do tại sao những điều này
cần điều khiển được gọi là "Đa hệ thống".

Bây giờ sơ đồ chân của họ ::

+--------> Đúng rồi
        | +-------> Trái
        ZZ0000ZZ +----> Xuống
        ZZ0001ZZ | +---> Lên
        ZZ0002ZZ ZZ0003ZZ
    _____________
  5 \ x o o o o / 1
     \ x o x o /
    9 '~~~~~~~' 6
         ZZ0004ZZ
         |   +----> Nút
         +--------> Mặt đất

Tuy nhiên, theo thời gian, các phần mở rộng của tiêu chuẩn này đã phát triển và những
không tương thích với nhau::


Atari 130, 800/XL/XE MSX

+-----------> Sức mạnh
        +---------> Đúng | +--------> Đúng rồi
        ZZ0001ZZ | +-------> Trái
        ZZ0002ZZ +-----> Xuống ZZ0003ZZ | +------ Xuống
        ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ | +---> Lên
        ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ |
    _____________ _____________
  5 \ x o o o o / 1 5 \ o o o o o / 1
     \ x o o o / \ o o o o /
    9 ZZ0000ZZ~~~~~~~' 6
         ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ |
         ZZ0014ZZ +----> Nút ZZ0015ZZ | +----> Nút 1
         ZZ0016ZZ | +------> Nút 2
         +--------> Mặt đất | +--------> Đầu ra 3
                                            +----------> Mặt đất

Amstrad CPC Hàng hóa C64

+----------->Tương tự Y
        +---------> Đúng | +--------> Đúng rồi
        ZZ0001ZZ | +-------> Trái
        ZZ0002ZZ +-----> Xuống ZZ0003ZZ | +------ Xuống
        ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ | +---> Lên
        ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ |
    _____________ _____________
  5 \ x o o o o / 1 5 \ o o o o o / 1
     \ x o o o / \ o o o o /
    9 ZZ0000ZZ~~~~~~~' 6
         ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ |
         ZZ0014ZZ +----> Nút 1 ZZ0015ZZ | +----> Nút
         ZZ0016ZZ | +------> Sức mạnh
         +--------> Mặt đất | +--------> Mặt đất
                                            +----------> Tương tự X

Phổ Sinclair +2A/+3 Amiga 1200

+-----------> Lên +-----------> Nút 3
      ZZ0001ZZ +--------> Đúng
      ZZ0002ZZ ZZ0003ZZ +-------> Còn lại
      ZZ0004ZZ +------> Nối đất ZZ0005ZZ | +------ Xuống
      ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ | +---> Lên
      ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
    _____________ _____________
  5 \ o o x o x / 1 5 \ o o o o o / 1
     \ o o o o / \ o o o o /
    9 ZZ0000ZZ~~~~~~~' 6
       ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ ZZ0016ZZ
       ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ +----> Nút 1
       ZZ0020ZZ +------> ZZ0021ZZ còn lại +------> Nguồn
       ZZ0022ZZ +--------> Mặt đất
       +----------> Xuống +----------> Nút 2

Và còn rất nhiều người khác nữa.

Cần điều khiển đa hệ thống sử dụng db9.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đối với cần điều khiển Đa hệ thống và các dẫn xuất của chúng, trình điều khiển db9.c
đã được viết. Nó chỉ cho phép một cần điều khiển/tay cầm chơi game trên mỗi cổng song song, nhưng
giao diện dễ xây dựng và hoạt động với hầu hết mọi thứ.

Đối với cần điều khiển Multisystem 1 nút cơ bản, bạn kết nối dây của nó với
cổng song song như thế này::

(chân 1) ------> Nguồn
    (chân 18) -----> Nối đất

(chân 2) -----> Lên
    (chân 3) ------> Xuống
    (chân 4) ------> Trái
    (chân 5) -----> Đúng
    (chân 6) -----> Nút 1

Tuy nhiên, nếu cần điều khiển dựa trên công tắc (ví dụ: nhấp chuột khi bạn di chuyển nó),
bạn có thể có hoặc không, tùy thuộc vào cổng song song của bạn, cần pullup 10 kOhm
điện trở trên mỗi tín hiệu hướng và nút, như thế này ::

(chân 2) ------------+------> Lên
              Điện trở |
    (chân 1) --[10kOhm]--+

Hãy thử mà không có, và nếu nó không hoạt động, hãy thêm chúng. Dành cho cần điều khiển dựa trên TTL /
gamepad, pullups là không cần thiết.

Đối với cần điều khiển có hai nút, bạn kết nối nút thứ hai với chốt 7 trên
cổng song song::

(chân 7) -----> Nút 2

Và thế là xong.

Ngoài ra, nếu bạn đã tạo một bộ chuyển đổi khác để sử dụng với
trình điều khiển cần điều khiển kỹ thuật số 0.8.0.2, điều này cũng được db9.c hỗ trợ
trình điều khiển, như loại thiết bị 8. (Xem phần 3.2)

Cần điều khiển đa hệ thống sử dụng gamecon.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đối với một số người, chỉ một cần điều khiển cho mỗi cổng song song là không đủ và/hoặc
muốn sử dụng chúng trên một cổng song song cùng với các miếng đệm NES/SNES/PSX. Đây là
có thể sử dụng gamecon.c. Nó hỗ trợ tối đa 5 thiết bị thuộc loại trên,
bao gồm 1 và 2 nút điều khiển Multisystem.

Tuy nhiên, không có gì miễn phí. Để cho phép sử dụng nhiều gậy hơn
một lần, bạn cần các gậy hoàn toàn dựa trên công tắc (đó không phải là TTL) và
không cần đến sức mạnh. Chỉ có sáu công tắc đơn giản bên trong. Nếu bạn
cần điều khiển có thể làm được nhiều việc hơn (ví dụ: turbofire), trước tiên bạn cần phải tắt nó hoàn toàn
nếu bạn muốn sử dụng gamecon.c.

Ngoài ra, kết nối phức tạp hơn một chút. Bạn sẽ cần một loạt đi-ốt,
và một điện trở pullup. Đầu tiên bạn kết nối Chỉ đường và nút
tương tự như đối với db9, tuy nhiên với các điốt giữa::

Điốt
    (chân 2) -----ZZ0000ZZ----> Lên
    (chân 3) -----ZZ0001ZZ----> Xuống
    (chân 4) -----ZZ0002ZZ----> Trái
    (chân 5) -----ZZ0003ZZ----> Phải
    (chân 6) -----ZZ0004ZZ----> Nút 1

Đối với hai gậy nút bạn cũng kết nối nút khác ::

(chân 7) -----ZZ0000ZZ----> Nút 2

Và cuối cùng bạn nối dây Ground của cần điều khiển như đã làm ở mục
sơ đồ nhỏ này về Nguồn và Dữ liệu trên cổng song song, như được mô tả
đối với các miếng đệm NES / SNES trong phần 2.1 của tệp này - nghĩa là một chân dữ liệu
cho mỗi cần điều khiển. Nguồn điện được chia sẻ::

Dữ liệu ------------+------> Mặt đất
              Điện trở |
    Nguồn --[10kOhm]--+

Và đó là tất cả, chúng ta bắt đầu thôi!

Cần điều khiển đa hệ thống sử dụng turbografx.c
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Giao diện TurboGraFX, được thiết kế bởi

Steffen Schwenke <schwenke@burg-halle.de>

cho phép tối đa 7 cần điều khiển đa hệ thống được kết nối với cổng song song. trong
Phiên bản của Steffen, có hỗ trợ tối đa 5 nút trên mỗi cần điều khiển.  Tuy nhiên,
vì điều này không hoạt động đáng tin cậy trên tất cả các cổng song song, trình điều khiển turbografx.c
chỉ hỗ trợ một nút cho mỗi phím điều khiển. Để biết thêm thông tin về cách xây dựng
giao diện, xem:

ZZ0000ZZ

Máy chơi game Sony
----------------

Bộ điều khiển PSX được gamecon.c hỗ trợ. Sơ đồ chân của PSX
bộ điều khiển (tương thích với DirectPadPro)::

+----------+----------+---------+
  9 ZZ0000ZZ o o o ZZ0001ZZ 1 song song
     \________ZZ0002ZZ________/ chân cổng
      ZZ0003ZZ ZZ0004ZZ ZZ0005ZZ
      ZZ0006ZZ ZZ0007ZZ |   +--------> Đồng hồ --- (4)
      ZZ0008ZZ ZZ0009ZZ +-----------> Chọn --- (3)
      ZZ0010ZZ |  +---------------> Sức mạnh --- (5-9)
      ZZ0011ZZ +-------------------> Mặt đất --- (18-25)
      |  +-------------------------> Lệnh --- (2)
      +---------------------------> Dữ liệu --- (một trong 10,11,12,13,15)

Trình điều khiển hỗ trợ các bộ điều khiển này:

* Tấm PSX tiêu chuẩn
 * Tấm NegCon PSX
 * Analog PSX Pad (chế độ màu đỏ)
 * Bảng tương tự PSX (chế độ màu xanh lá cây)
 * PSX Rumble Pad
 * Tấm lót PSX DDR

Sega
----

Tất cả các bộ điều khiển của Sega ít nhiều đều dựa trên 2 nút tiêu chuẩn
Cần điều khiển đa hệ thống. Tuy nhiên, vì họ không sử dụng switch và sử dụng TTL
logic, trình điều khiển duy nhất có thể sử dụng được với chúng là trình điều khiển db9.c.

Hệ thống Sega Master
~~~~~~~~~~~~~~~~~~

Gamepad SMS gần như giống hệt 2 nút thông thường
Cần điều khiển đa hệ thống. Đặt trình điều khiển ở chế độ Multi2, sử dụng chế độ tương ứng
các chân cổng song song và sơ đồ sau::

+-----------> Sức mạnh
      | +--------> Đúng rồi
      ZZ0000ZZ +-------> Còn lại
      ZZ0001ZZ | +------ Xuống
      ZZ0002ZZ ZZ0003ZZ +---> Lên
      ZZ0004ZZ ZZ0005ZZ |
    _____________
  5 \ o o o o o / 1
     \ o o x o /
    9 '~~~~~~~' 6
       ZZ0006ZZ |
       ZZ0007ZZ +----> Nút 1
       | +--------> Mặt đất
       +----------> Nút 2

Sega Genesis hay còn gọi là MegaDrive
~~~~~~~~~~~~~~~~~~~~~~~~~~

Các miếng đệm Sega Genesis (ở Châu Âu được bán dưới dạng Sega MegaDrive) là một phần mở rộng
đến các miếng đệm của Hệ thống Sega Master. Họ sử dụng nhiều nút hơn (3+1, 5+1, 6+1).  sử dụng
sơ đồ sau::

+-----------> Sức mạnh
        | +--------> Đúng rồi
        ZZ0000ZZ +-------> Còn lại
        ZZ0001ZZ | +------ Xuống
        ZZ0002ZZ ZZ0003ZZ +---> Lên
        ZZ0004ZZ ZZ0005ZZ |
      _____________
    5 \ o o o o o / 1
       \ o o o o /
      9 '~~~~~~~' 6
        ZZ0006ZZ ZZ0007ZZ
        ZZ0008ZZ | +----> Nút 1
        ZZ0009ZZ +------> Chọn
        | +--------> Mặt đất
        +----------> Nút 2

Chân Chọn đi đến chân 14 trên cổng song song ::

(chân 14) ------> Chọn

Phần còn lại tương tự như đối với cần điều khiển Multi2 sử dụng db9.c

Sega Saturn
~~~~~~~~~~~

Sega Saturn có tám nút và để chuyển nút đó mà không cần hack như
Sử dụng miếng đệm Genesis 6, nó cần thêm một chốt chọn. Dù sao thì nó vẫn thế
được xử lý bởi trình điều khiển db9.c. Sơ đồ chân của nó rất khác so với bất cứ thứ gì
khác.  Sử dụng sơ đồ này::

+-----------> Chọn 1
      | +--------> Sức mạnh
      ZZ0000ZZ +-------> Lên
      ZZ0001ZZ | +------ Xuống
      ZZ0002ZZ ZZ0003ZZ +---> Mặt đất
      ZZ0004ZZ ZZ0005ZZ |
    _____________
  5 \ o o o o o / 1
     \ o o o o /
    9 '~~~~~~~' 6
       ZZ0006ZZ ZZ0007ZZ
       ZZ0008ZZ | +----> Chọn 2
       ZZ0009ZZ +------> Đúng
       | +-------->Trái
       +----------> Sức mạnh

Chọn 1 là chân 14 trên cổng song song, Chọn 2 là chân 16 trên cổng
cổng song song::

(chân 14) -----> Chọn 1
    (chân 16) ------> Chọn 2

Các chân khác (Up, Down, Right, Left, Power, Ground) giống như đối với
Nhiều cần điều khiển sử dụng db9.c

Amiga CD32
----------

Bàn phím điều khiển Amiga CD32 sử dụng sơ đồ chân sau::

+-----------> Nút 3
        | +--------> Đúng rồi
        ZZ0000ZZ +-------> Còn lại
        ZZ0001ZZ | +------ Xuống
        ZZ0002ZZ ZZ0003ZZ +---> Lên
        ZZ0004ZZ ZZ0005ZZ |
      _____________
    5 \ o o o o o / 1
       \ o o o o /
      9 '~~~~~~~' 6
        ZZ0006ZZ ZZ0007ZZ
        ZZ0008ZZ | +----> Nút 1
        ZZ0009ZZ +------> Nguồn
        | +--------> Mặt đất
        +----------> Nút 2

Nó có thể được kết nối với cổng song song và được điều khiển bởi trình điều khiển db9.c. Nó cần hệ thống dây điện sau:

============= ==============
	CD32 pad Cổng song song
	============= ==============
	1 (Lên) 2 (D0)
	2 (Xuống) 3 (D1)
	3 (Trái) 4 (D2)
	4 (Phải) 5 (D3)
	5 (Nút 3) 14 (AUTOFD)
	6 (Nút 1) 17 (SELIN)
	7 (+5V) 1 (STROBE)
	8 (Gnd) 18 (Gnd)
	9 (Nút 2) 7 (D5)
	============= ==============

Các tài xế
===========

Có ba trình điều khiển cho giao diện cổng song song. Mỗi cái, như
được mô tả ở trên, cho phép kết nối một nhóm cần điều khiển và miếng đệm khác nhau.
Dưới đây là mô tả các dòng lệnh của họ:

gamecon.c
---------

Sử dụng gamecon.c, bạn có thể kết nối tối đa năm thiết bị với một cổng song song. Nó
sử dụng dòng lệnh kernel/module sau ::

gamecon.map=port,pad1,pad2,pad3,pad4,pad5

Trong đó ZZ0000ZZ là số của giao diện parport (ví dụ: 0 cho parport0).

Và ZZ0000ZZ đến ZZ0001ZZ là các loại pad được kết nối với các chân đầu vào dữ liệu khác nhau
(10,11,12,13,15), như được mô tả trong phần 2.1 của tệp này.

Các loại là:

===== ================================
	Loại Cần điều khiển/Pad
	===== ================================
	  0 Không có
	  1 miếng đệm SNES
	  2 miếng đệm NES
	  4 Cần điều khiển 1 nút đa hệ thống
	  5 Cần điều khiển 2 nút đa hệ thống
	  6 miếng đệm N64
	  7 Bộ điều khiển Sony PSX
	  8 Bộ điều khiển Sony PSX DDR
	  9 con chuột SNES
	===== ================================

Loại chính xác của loại bộ điều khiển PSX được tự động thăm dò khi sử dụng, vì vậy
trao đổi nóng sẽ hoạt động (nhưng không được khuyến khích).

Nếu bạn muốn sử dụng nhiều cổng song song cùng một lúc, bạn có thể sử dụng
gamecon.map2 và gamecon.map3 làm tham số dòng lệnh bổ sung cho hai
nhiều cổng song song hơn.

Có hai tùy chọn dành riêng cho phần trình điều khiển PSX.  bộ gamecon.psx_delay
độ trễ lệnh khi nói chuyện với bộ điều khiển. Mặc định là 25 nên
hoạt động nhưng bạn có thể thử giảm nó xuống để có hiệu suất tốt hơn. Nếu miếng đệm của bạn không
hãy thử nâng cao nó cho đến khi chúng hoạt động. Đặt loại thành 8 cho phép
trình điều khiển được sử dụng với Dance Dance Revolution hoặc các trò chơi tương tự. Phím mũi tên là
được đăng ký dưới dạng phím nhấn thay vì trục X và Y.

db9.c
-----

Ngoài việc tạo giao diện, không có gì khó khăn khi sử dụng
trình điều khiển db9.c. Nó sử dụng dòng lệnh kernel/module sau::

db9.dev=cổng, gõ

Trong đó ZZ0000ZZ là số của giao diện parport (ví dụ: 0 cho parport0).

Hãy cẩn thận ở đây: Trình điều khiển này chỉ hoạt động trên các cổng song song hai chiều. Nếu
cổng song song của bạn đủ mới, bạn sẽ không gặp khó khăn gì với điều này.
Các cổng song song cũ có thể không có tính năng này.

ZZ0000ZZ là loại cần điều khiển hoặc pad kèm theo:

================================================================
	Loại Cần điều khiển/Pad
	================================================================
	  0 Không có
	  1 cần điều khiển 1 nút đa hệ thống
	  2 Cần điều khiển 2 nút đa hệ thống
	  3 phím Genesis (nút 3+1)
	  5 phím Genesis (nút 5+1)
	  6 phím Genesis (nút 6+2)
	  7 phím Saturn (8 nút)
	  8 Cần điều khiển 1 nút đa hệ thống (pin-out v0.8.0.2)
	  9 Hai cần điều khiển 1 nút đa hệ thống (pin-out v0.8.0.2)
	 10 miếng đệm Amiga CD32
	================================================================

Nếu bạn muốn sử dụng nhiều hơn một trong các cần điều khiển/miếng đệm này cùng một lúc, bạn
có thể sử dụng db9.dev2 và db9.dev3 làm tham số dòng lệnh bổ sung cho hai
nhiều cần điều khiển/miếng đệm hơn.

turbografx.c
------------

Trình điều khiển turbografx.c sử dụng dòng lệnh kernel/mô-đun rất đơn giản ::

turbografx.map=port,js1,js2,js3,js4,js5,js6,js7

Trong đó ZZ0000ZZ là số của giao diện parport (ví dụ: 0 cho parport0).

ZZ0000ZZ là số nút mà cần điều khiển Đa hệ thống được kết nối với
cổng giao diện 1-7 có. Đối với cần điều khiển đa hệ thống tiêu chuẩn, đây là 1.

Nếu bạn muốn sử dụng nhiều giao diện cùng một lúc, bạn có thể
sử dụng turbografx.map2 và turbografx.map3 làm tham số dòng lệnh bổ sung
cho hai giao diện nữa.

Sơ đồ chân cổng song song của PC
=======================

::

.---------------------------------------.
   Tại PC: \ 13 12 11 10 9 8 7 6 5 4 3 2 1 /
                   \ 25 24 23 22 21 20 19 18 17 16 15 14 /
                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

====== ======= ==============
   Tên Pin Mô tả
====== ======= ==============
     1 /STROBE Nhấp nháy
   2-9 D0-D7 Bit dữ liệu 0-7
    10 /ACK Xác nhận
    11 BUSY bận
    12 đầu giấy PE
    13 SELIN Chọn vào
    14 /AUTOFD Tự động nạp
    15 /ERROR Lỗi
    16 /INIT Khởi tạo
    17 /SEL Chọn
 Mặt đất tín hiệu 18-25 GND
====== ======= ==============


Chỉ vậy thôi các bạn! Chúc vui vẻ!
