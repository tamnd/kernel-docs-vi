.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/sound/alsa-configuration.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================================================================
Kiến trúc âm thanh Linux nâng cao - Hướng dẫn cấu hình trình điều khiển
==============================================================


Cấu hình hạt nhân
====================

Để kích hoạt hỗ trợ ALSA, bạn cần ít nhất xây dựng kernel bằng
hỗ trợ card âm thanh chính (ZZ0000ZZ).  Vì ALSA có thể mô phỏng
OSS, bạn không cần phải chọn bất kỳ mô-đun OSS nào.

Kích hoạt "mô phỏng OSS API" (ZZ0000ZZ) và cả bộ trộn OSS
và PCM hỗ trợ nếu bạn muốn chạy các ứng dụng OSS với ALSA.

Nếu bạn muốn hỗ trợ chức năng WaveTable trên các thẻ như
SB trực tiếp! sau đó bạn cần kích hoạt "Hỗ trợ trình tự sắp xếp"
(ZZ0000ZZ).

Để làm cho thông báo gỡ lỗi ALSA dài dòng hơn, hãy bật "Verbose printk"
và tùy chọn "Gỡ lỗi".  Để kiểm tra rò rỉ bộ nhớ, hãy bật "Gỡ lỗi bộ nhớ"
quá.  "Phát hiện gỡ lỗi" sẽ thêm kiểm tra để phát hiện thẻ.

Xin lưu ý rằng tất cả trình điều khiển ALSA ISA đều hỗ trợ Linux isapnp API
(nếu thẻ hỗ trợ ISA PnP).  Bạn không cần phải cấu hình các thẻ
sử dụng isapnptools.


Thông số mô-đun
=================

Người dùng có thể tải các mô-đun với các tùy chọn. Nếu mô-đun hỗ trợ nhiều hơn
một thẻ và bạn có nhiều thẻ cùng loại thì bạn có thể
chỉ định nhiều giá trị cho tùy chọn được phân tách bằng dấu phẩy.


mô-đun snd
----------

Mô-đun ALSA cốt lõi.  Nó được sử dụng bởi tất cả các trình điều khiển thẻ ALSA.
Phải mất các tùy chọn sau có hiệu ứng toàn cầu.

chính
    số chính cho trình điều khiển âm thanh;
    Mặc định: 116
thẻ_giới hạn
    giới hạn chỉ số thẻ để tự động nạp (1-8);
    Mặc định: 1;
    Để tự động tải nhiều thẻ, hãy chỉ định tùy chọn này
    cùng với bí danh snd-card-X.
khe cắm
    Dự trữ chỉ số vị trí cho trình điều khiển nhất định;
    Tùy chọn này có nhiều chuỗi.
    Xem phần ZZ0001ZZ để biết chi tiết.
gỡ lỗi
    Chỉ định mức thông báo gỡ lỗi;
    (0 = tắt tính năng in gỡ lỗi, 1 = thông báo gỡ lỗi thông thường,
    2 = thông báo gỡ lỗi dài dòng);
    Tùy chọn này chỉ xuất hiện khi ZZ0000ZZ.
    Tùy chọn này có thể được thay đổi linh hoạt thông qua sysfs
    /sys/module/snd/parameters/tệp gỡ lỗi.
  
Mô-đun snd-pcm-oss
------------------

Mô-đun mô phỏng PCM OSS.
Mô-đun này có các tùy chọn thay đổi ánh xạ của thiết bị.

dsp_map
    Bản đồ số thiết bị PCM được gán cho thiết bị OSS đầu tiên;
    Mặc định: 0
bản đồ quảng cáo
    Bản đồ số thiết bị PCM được gán cho thiết bị OSS thứ 2;
    Mặc định: 1
không chặn_open
    Đừng chặn việc mở các thiết bị PCM bận rộn;
    Mặc định: 1

Ví dụ: khi ZZ0000ZZ, /dev/dsp sẽ được ánh xạ tới PCM #2 của
thẻ #0.  Tương tự, khi ZZ0001ZZ, /dev/adsp sẽ được ánh xạ
tới PCM #0 của thẻ #0.
Để thay đổi thẻ thứ hai hoặc mới hơn, hãy chỉ định tùy chọn với
dấu phẩy, chẳng hạn như ZZ0002ZZ.

Tùy chọn ZZ0000ZZ được sử dụng để thay đổi hành vi của PCM
về việc mở thiết bị.  Khi tùy chọn này khác 0,
mở thiết bị OSS PCM bận sẽ không bị chặn mà quay lại
ngay lập tức với EAGAIN (giống như cờ O_NONBLOCK).
    
Mô-đun snd-rawmidi
------------------

Mô-đun này có các tùy chọn thay đổi ánh xạ của thiết bị.
tương tự như mô-đun snd-pcm-oss.

midi_map
    Bản đồ số thiết bị MIDI được gán cho thiết bị OSS đầu tiên;
    Mặc định: 0
amidi_map
    Bản đồ số thiết bị MIDI được gán cho thiết bị OSS thứ 2;
    Mặc định: 1

Mô-đun snd-soc-core
-------------------

Mô-đun lõi xã hội. Nó được sử dụng bởi tất cả các trình điều khiển thẻ ALSA.
Phải mất các tùy chọn sau có hiệu ứng toàn cầu.

prealloc_buffer_size_kbytes
    Chỉ định kích thước bộ đệm prealloc tính bằng kbyte (mặc định: 512).

Thông số chung cho các module card âm thanh hàng đầu
--------------------------------------------

Mỗi mô-đun card âm thanh cấp cao nhất có các tùy chọn sau.

chỉ mục
    chỉ số (khe #) của card âm thanh;
    Giá trị: 0 đến 31 hoặc âm;
    Nếu không âm, hãy gán số chỉ mục đó;
    nếu âm, diễn giải dưới dạng bitmask của các chỉ số cho phép;
    chỉ số được phép miễn phí đầu tiên được chỉ định;
    Mặc định: -1
danh tính
    ID thẻ (số nhận dạng hoặc tên);
    Có thể dài tối đa 15 ký tự;
    Mặc định: loại thẻ;
    Một thư mục có tên này được tạo trong /proc/asound/
    chứa thông tin về thẻ;
    ID này có thể được sử dụng thay cho số chỉ mục trong
    xác định thẻ
kích hoạt
    kích hoạt thẻ;
    Mặc định: được bật, đối với thẻ PnP PCI và ISA

Các tùy chọn này được sử dụng để xác định thứ tự của các phiên bản hoặc
kiểm soát việc bật và tắt từng thiết bị nếu có
là nhiều thiết bị được liên kết với cùng một trình điều khiển. Ví dụ, có
nhiều máy có hai bộ điều khiển âm thanh HD (một cho HDMI/DP
âm thanh và một cái khác cho analog tích hợp). Trong hầu hết các trường hợp, trường hợp thứ hai là
trong cách sử dụng chính và mọi người muốn chỉ định nó là tên đầu tiên
thẻ xuất hiện. Họ có thể làm điều đó bằng cách chỉ định mô-đun "index=1,0"
tham số này sẽ hoán đổi các vị trí gán.

Ngày nay, với phần phụ trợ âm thanh như PulseAudio và PipeWire
hỗ trợ cấu hình động, nó ít được sử dụng, nhưng đó là một
trợ giúp cho cấu hình tĩnh trong quá khứ.

mô-đun snd-adlib
----------------

Mô-đun cho thẻ AdLib FM.

hải cảng
    cổng # for OPL chip

Mô-đun này hỗ trợ nhiều thẻ. Nó không hỗ trợ autoprobe, vì vậy
cổng phải được chỉ định. Đối với thẻ AdLib FM thực tế, nó sẽ là 0x388.
Lưu ý rằng thẻ này không hỗ trợ PCM và không có bộ trộn; chỉ đài FM
tổng hợp.

Đảm bảo bạn có sẵn ZZ0000ZZ từ gói công cụ alsa và,
sau khi tải mô-đun, hãy tìm cổng trình sắp xếp ALSA được chỉ định
số thông qua ZZ0001ZZ.

Đầu ra ví dụ:
::

Cổng Tên khách hàng Tên cổng
      64:0 OPL2 FM tổng hợp Cổng FM OPL2

Tải các bản vá ZZ0000ZZ và ZZ0001ZZ cũng do ZZ0002ZZ cung cấp:
::

sbiload -p 64:0 std.sb trống.sb

Nếu bạn sử dụng trình điều khiển này để lái OPL3, bạn có thể sử dụng ZZ0000ZZ và ZZ0001ZZ
thay vào đó. Để thẻ tạo ra âm thanh, hãy sử dụng ZZ0002ZZ từ alsa-utils:
::

aplaymidi -p 64:0 foo.mid

Mô-đun snd-ad1816a
------------------

Mô-đun dành cho card âm thanh dựa trên chip AD1816A/AD1815 ISA của Thiết bị Analog.

tần số đồng hồ
    Tần số xung nhịp cho chip AD1816A (mặc định = 0, 33000Hz)
    
Mô-đun này hỗ trợ nhiều thẻ, autoprobe và PnP.
    
Mô-đun snd-ad1848
-----------------

Mô-đun dành cho card âm thanh dựa trên chip AD1848/AD1847/CS4248 ISA.

hải cảng
    cổng # for AD1848 chip
không ổn
    Chip IRQ # for AD1848
dma1
    Chip DMA # for AD1848 (0,1,3)
    
Mô-đun này hỗ trợ nhiều thẻ.  Nó không hỗ trợ tự động thăm dò
do đó cổng chính phải được chỉ định!!! Các cổng khác là tùy chọn.
    
Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-ad1889
-----------------

Mô-đun dành cho chip AD1889 của Thiết bị Analog.

ac97_quirk
    Giải pháp AC'97 cho phần cứng lạ;
    Xem mô tả của mô-đun intel8x0 để biết chi tiết.

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-ali5451
------------------

Mô-đun cho chip ALi M5451 PCI.

pcm_channels
    Số kênh phần cứng được chỉ định cho PCM
spdif
    Hỗ trợ I/O SPDIF;
    Mặc định: bị vô hiệu hóa

Mô-đun này hỗ trợ một chip và đầu dò tự động.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-als100
-----------------

Mô-đun dành cho card âm thanh dựa trên chip Avance Logic ALS100/ALS120 ISA.

Mô-đun này hỗ trợ nhiều thẻ, autoprobe và PnP.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-als300
-----------------

Mô-đun cho Avance Logic ALS300 và ALS300+

Mô-đun này hỗ trợ nhiều thẻ.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-als4000
------------------

Mô-đun cho card âm thanh dựa trên chip Avance Logic ALS4000 PCI.

cần điều khiển_port
    hỗ trợ cần điều khiển kế thừa cổng # for;
    0 = tắt (mặc định), 1 = tự động phát hiện
    
Mô-đun này hỗ trợ nhiều thẻ, autoprobe và PnP.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-asihpi
-----------------

Mô-đun cho card âm thanh AudioScience ASI

kích hoạt_hpi_hwdep
    bật HPI hwdep cho soundcard AudioScience

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-atiixp
-----------------

Mô-đun dành cho bộ điều khiển ATI IXP 150/200/250/400 AC97.

ac97_clock
    Đồng hồ AC'97 (mặc định = 48000)
ac97_quirk
    Giải pháp AC'97 cho phần cứng lạ;
    Xem phần ZZ0000ZZ bên dưới.
ac97_codec
    Giải pháp để chỉ định codec AC'97 nào thay vì thăm dò.
    Nếu cách này hiệu quả với bạn thì hãy gửi lỗi với đầu ra ZZ0001ZZ của bạn.
    (-2 = Bắt buộc thăm dò, -1 = Hành vi mặc định, 0-2 = Sử dụng
    codec được chỉ định.)
spdif_aclink
    Truyền S/PDIF qua liên kết AC (mặc định = 1)

Mô-đun này hỗ trợ một thẻ và tự động thăm dò.

ATI IXP có hai phương pháp khác nhau để điều khiển đầu ra SPDIF.  Một là
qua liên kết AC và một cái khác qua đầu ra SPDIF "trực tiếp".  các
việc triển khai phụ thuộc vào bo mạch chủ và bạn sẽ cần phải
chọn đúng thông qua tùy chọn mô-đun spdif_aclink.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-atiixp-modem
-----------------------

Mô-đun dành cho bộ điều khiển modem ATI IXP 150/200/250 AC97.

Mô-đun này hỗ trợ một thẻ và tự động thăm dò.

Lưu ý: Giá trị chỉ mục mặc định của mô-đun này là -2, tức là giá trị đầu tiên
khe cắm được loại trừ.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-au8810, snd-au8820, snd-au8830
-----------------------------------------

Mô-đun dành cho thiết bị Aureal Vortex, Vortex2 và Advantage.

pcifix
    Kiểm soát cách giải quyết PCI;
    0 = Vô hiệu hóa tất cả các cách giải quyết,
    1 = Buộc độ trễ PCI của thẻ Aureal về 0xff,
    2 = Buộc mở rộng Master nội bộ PCI#2 để đạt hiệu quả
    Xử lý các yêu cầu giả trên cầu VIA KT133 AGP,
    3 = Buộc cả hai cài đặt,
    255 = Tự động phát hiện những gì được yêu cầu (mặc định)

Mô-đun này hỗ trợ tất cả các kênh ADB PCM, bộ trộn ac97, SPDIF, phần cứng
EQ, mpu401, cổng trò chơi. Hỗ trợ A3D và wavetable vẫn đang được phát triển.
Công việc phát triển và kỹ thuật đảo ngược đang được điều phối tại
ZZ0001ZZ
Đầu ra SPDIF có một bản sao của đầu ra codec AC97, trừ khi bạn sử dụng
Thiết bị pcm ZZ0000ZZ, cho phép truyền dữ liệu thô.
Phần cứng EQ phần cứng và SPDIF chỉ có trong Vortex2 và 
Lợi thế.

Lưu ý: Một số ứng dụng bộ trộn ALSA không xử lý tốc độ mẫu SPDIF 
kiểm soát một cách chính xác. Nếu bạn gặp vấn đề liên quan đến điều này, hãy thử
một bộ trộn tương thích ALSA khác (alsamixer hoạt động).

Mô-đun snd-azt1605
------------------

Mô-đun dành cho card âm thanh Aztech Sound Galaxy dựa trên Aztech AZT1605
chipset.

hải cảng
    cổng # for BASE (0x220,0x240,0x260,0x280)
wss_port
    cổng # for WSS (0x530,0x604,0xe80,0xf40)
không ổn
    IRQ # for WSS (7,9,10,11)
dma1
    Phát lại DMA # for WSS (0,1,3)
dma2
    Chụp DMA # for WSS (0,1), -1 = tắt (mặc định)
mpu_port
    cổng # for MPU-401 UART (0x300,0x330), -1 = bị tắt (mặc định)
mpu_irq
    IRQ # for MPU-401 UART (3,5,7,9), -1 = tắt (mặc định)
fm_port
    cổng # for OPL3 (0x388), -1 = bị tắt (mặc định)

Mô-đun này hỗ trợ nhiều thẻ. Nó không hỗ trợ autoprobe:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ phải được chỉ định.
Các giá trị khác là tùy chọn.

ZZ0000ZZ cần khớp với jumper BASE ADDRESS trên thẻ (0x220 hoặc 0x240)
hoặc giá trị được lưu trong EEPROM của thẻ đối với các thẻ có EEPROM và
jumper "CONFIG MODE" của họ được đặt thành "EEPROM SETTING". Các giá trị khác có thể
được lựa chọn tự do từ các lựa chọn được liệt kê ở trên.

Nếu ZZ0000ZZ được chỉ định và khác với ZZ0001ZZ, thẻ sẽ hoạt động ở chế độ
chế độ song công hoàn toàn. Khi ZZ0002ZZ, chỉ ZZ0003ZZ là hợp lệ và cách duy nhất để
cho phép chụp vì chỉ có các kênh 0 và 1 có sẵn để chụp.

Cài đặt chung là ZZ0000ZZ.

Dù bạn chọn kênh IRQ và DMA nào, hãy nhớ đặt trước chúng cho
ISA kế thừa trong BIOS của bạn.

Mô-đun snd-azt2316
------------------

Mô-đun dành cho card âm thanh Aztech Sound Galaxy dựa trên Aztech AZT2316
chipset.

hải cảng
    cổng # for BASE (0x220,0x240,0x260,0x280)
wss_port
    cổng # for WSS (0x530,0x604,0xe80,0xf40)
không ổn
    IRQ # for WSS (7,9,10,11)
dma1
    Phát lại DMA # for WSS (0,1,3)
dma2
    Chụp DMA # for WSS (0,1), -1 = tắt (mặc định)
mpu_port
    cổng # for MPU-401 UART (0x300,0x330), -1 = bị tắt (mặc định)
mpu_irq
    IRQ # for MPU-401 UART (5,7,9,10), -1 = tắt (mặc định)
fm_port
    cổng # for OPL3 (0x388), -1 = bị tắt (mặc định)

Mô-đun này hỗ trợ nhiều thẻ. Nó không hỗ trợ autoprobe:
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ phải được chỉ định.
Các giá trị khác là tùy chọn.

ZZ0000ZZ cần khớp với jumper BASE ADDRESS trên thẻ (0x220 hoặc 0x240)
hoặc giá trị được lưu trong EEPROM của thẻ đối với các thẻ có EEPROM và
jumper "CONFIG MODE" của họ được đặt thành "EEPROM SETTING". Các giá trị khác có thể
được lựa chọn tự do từ các lựa chọn được liệt kê ở trên.

Nếu ZZ0000ZZ được chỉ định và khác với ZZ0001ZZ, thẻ sẽ hoạt động ở chế độ
chế độ song công hoàn toàn. Khi ZZ0002ZZ, chỉ ZZ0003ZZ là hợp lệ và cách duy nhất để
cho phép chụp vì chỉ có các kênh 0 và 1 có sẵn để chụp.

Cài đặt chung là ZZ0000ZZ.

Dù bạn chọn kênh IRQ và DMA nào, hãy nhớ đặt trước chúng cho
ISA kế thừa trong BIOS của bạn.

Mô-đun snd-aw2
--------------

Mô-đun cho card âm thanh Audiowerk2

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-azt2320
------------------

Mô-đun dành cho card âm thanh dựa trên chip Aztech System AZT2320 ISA (chỉ PnP).

Mô-đun này hỗ trợ nhiều thẻ, PnP và autoprobe.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-azt3328
------------------

Mô-đun cho card âm thanh dựa trên chip Aztech AZF3328 PCI.

cần điều khiển
    Bật cần điều khiển (tắt mặc định)

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-bt87x
----------------

Mô-đun cho card màn hình dựa trên chip Bt87x.

tỷ lệ kỹ thuật số
    Ghi đè tốc độ kỹ thuật số mặc định (Hz)
tải_tất cả
    Tải trình điều khiển ngay cả khi không biết mẫu thẻ

Mô-đun này hỗ trợ nhiều thẻ.

Lưu ý: Giá trị chỉ mục mặc định của mô-đun này là -2, tức là giá trị đầu tiên
khe cắm được loại trừ.

Mô-đun snd-ca0106
-----------------

Mô-đun dành cho Creative Audigy LS và SB Live 24bit

Mô-đun này hỗ trợ nhiều thẻ.


Mô-đun snd-cmi8330
------------------

Mô-đun cho card âm thanh dựa trên chip C-Media CMI8330 ISA.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

thể thao
    cổng # for CMI8330 chip (WSS)
wssirq
    Chip IRQ # for CMI8330 (WSS)
wssdma
    Chip DMA # for CMI8330 đầu tiên (WSS)
cổng
    cổng # for CMI8330 chip (SB16)
sbirq
    Chip IRQ # for CMI8330 (SB16)
sbdma8
    Chip 8 bit DMA # for CMI8330 (SB16)
sbdma16
    Chip 16bit DMA # for CMI8330 (SB16)
nhập khẩu
    (tùy chọn) Cổng I/O OPL3
chuyển tải
    (tùy chọn) Cổng I/O MPU401
mpuirq
    (tùy chọn) MPU401 irq #

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-cmipci
-----------------

Mô-đun dành cho card âm thanh C-Media CMI8338/8738/8768/8770 PCI.

mpu_port
    địa chỉ cổng của giao diện MIDI (chỉ 8338):
    0x300,0x310,0x320,0x330 = cổng cũ,
    1 = cổng PCI tích hợp (mặc định trên 8738),
    0 = vô hiệu hóa
fm_port
    địa chỉ cổng của bộ tổng hợp FM OPL-3 (chỉ 8x38):
    0x388 = cổng kế thừa,
    1 = cổng PCI tích hợp (mặc định trên 8738),
    0 = vô hiệu hóa
mềm_ac3
    Chuyển đổi phần mềm các gói SPDIF thô (chỉ kiểu 033) (mặc định = 1)
cần điều khiển_port
    Địa chỉ cổng cần điều khiển (0 = tắt, 1 = tự động phát hiện)

Mô-đun này hỗ trợ autoprobe và nhiều thẻ.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-cs4231
-----------------

Mô-đun cho card âm thanh dựa trên chip CS4231 ISA.

hải cảng
    cổng # for CS4231 chip
mpu_port
    cổng # for MPU-401 UART (tùy chọn), -1 = tắt
không ổn
    Chip IRQ # for CS4231
mpu_irq
    IRQ # for MPU-401 UART
dma1
    chip DMA # for CS4231 đầu tiên
dma2
    chip DMA # for CS4231 thứ hai

Mô-đun này hỗ trợ nhiều thẻ. Mô-đun này không hỗ trợ thăm dò tự động
do đó cổng chính phải được chỉ định!!! Các cổng khác là tùy chọn.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-cs4236
-----------------

Mô-đun cho card âm thanh dựa trên CS4232/CS4232A,
Các chip CS4235/CS4236/CS4236B/CS4237B/CS4238B/CS4239 ISA.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng # for CS4236 chip (thiết lập PnP - 0x534)
cảng
    cổng điều khiển # for CS4236 chip (thiết lập PnP - 0x120,0x210,0xf00)
mpu_port
    cổng # for MPU-401 UART (thiết lập PnP - 0x300), -1 = tắt
fm_port
    Cổng FM # for CS4236 chip (thiết lập PnP - 0x388), -1 = tắt
không ổn
    Chip IRQ # for CS4236 (5,7,9,11,12,15)
mpu_irq
    IRQ # for MPU-401 UART (9,11,12,15)
dma1
    chip DMA # for CS4236 đầu tiên (0,1,3)
dma2
    chip DMA # for CS4236 thứ hai (0,1,3), -1 = tắt

Mô-đun này hỗ trợ nhiều thẻ. Mô-đun này không hỗ trợ thăm dò tự động
(nếu không sử dụng ISA PnP) do đó cổng chính và cổng điều khiển phải được kết nối
quy định!!! Các cổng khác là tùy chọn.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun này có bí danh là snd-cs4232 vì nó cung cấp giao thức cũ
chức năng snd-cs4232 nữa.

Mô-đun snd-cs4281
-----------------

Mô-đun cho chip âm thanh Cirrus Logic CS4281.

codec kép
    ID codec phụ (0 = tắt, mặc định)

Mô-đun này hỗ trợ nhiều thẻ.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-cs46xx
-----------------

Mô-đun cho card âm thanh PCI dựa trên CS4610/CS4612/CS4614/CS4615/CS4622/
Chip CS4624/CS4630/CS4280 PCI.

bên ngoài_amp
    Buộc kích hoạt bộ khuếch đại bên ngoài.
thinkpad
    Buộc kích hoạt điều khiển CLKRUN của Thinkpad.
mmap_valid
    Hỗ trợ chế độ mmap OSS (mặc định = 0).

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.
Thông thường, bộ điều khiển amp bên ngoài và CLKRUN được phát hiện tự động
từ id nhà cung cấp/thiết bị phụ PCI.  Nếu chúng không hoạt động, hãy đưa ra các tùy chọn
trên một cách rõ ràng.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-cs5530
-----------------

Mô-đun cho chip Cyrix/NatSemi Geode 5530.

Mô-đun snd-cs5535audio
----------------------

Mô-đun dành cho thiết bị PCI đồng hành đa chức năng CS5535

Việc quản lý năng lượng được hỗ trợ.

mô-đun snd-ctxfi
----------------

Mô-đun dành cho bảng X-Fi Creative Sound Blaster (chip 20k1 / 20k2)

* Dòng sản phẩm vô địch Creative Sound Blaster X-Fi Titanium Fatal1ty
* Dòng sản phẩm Creative Sound Blaster X-Fi Titanium Fatal1ty Professional
* Âm thanh chuyên nghiệp Creative Sound Blaster X-Fi Titanium
* Creative Sound Blaster X-Fi Titanium
* Creative Sound Blaster X-Fi Elite Pro
* Creative Sound Blaster X-Fi Platinum
* Creative Sound Blaster X-Fi Fatal1ty
* Creative Sound Blaster X-Fi XtremeGamer
* Creative Sound Blaster X-Fi XtremeMusic
	
tỷ lệ tham chiếu
    tốc độ mẫu tham chiếu, 44100 hoặc 48000 (mặc định)
nhiều
    nhiều để ref. tốc độ mẫu, 1 hoặc 2 (mặc định)
hệ thống con
    ghi đè PCI SSID để thăm dò;
    giá trị bao gồm SSVID << 16 | SSDID.
    Giá trị mặc định là 0, có nghĩa là không ghi đè.

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-darla20
------------------

Mô-đun cho Echoaudio Darla20

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-darla24
------------------

Mô-đun cho Echoaudio Darla24

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-dt019x
-----------------

Mô-đun dành cho Diamond Technologies DT-019X / Avance Logic ALS-007 (PnP
chỉ)

Mô-đun này hỗ trợ nhiều thẻ.  Mô-đun này chỉ được kích hoạt với
Hỗ trợ PnP ISA.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-giả
----------------

Mô-đun cho card âm thanh giả. "Thẻ" này không thực hiện bất kỳ đầu ra nào
hoặc đầu vào, nhưng bạn có thể sử dụng mô-đun này cho bất kỳ ứng dụng nào
yêu cầu card âm thanh (như RealPlayer).

pcm_devs
    Số lượng thiết bị PCM được gán cho mỗi thẻ (mặc định = 1, tối đa 4)
pcm_substreams
    Số lượng luồng con PCM được gán cho mỗi PCM (mặc định = 8, tối đa 128)
đồng hồ bấm giờ
    Sử dụng bộ hẹn giờ (=1, mặc định) hoặc bộ hẹn giờ hệ thống (=0)
bộ đệm giả
    Phân bổ bộ đệm giả (mặc định = 1)

Khi nhiều thiết bị PCM được tạo, snd-dummy sẽ khác nhau
hành vi của từng thiết bị PCM:
* 0 = xen kẽ với hỗ trợ mmap
* 1 = không xen kẽ với hỗ trợ mmap
* 2 = xen kẽ không có mmap 
* 3 = không xen kẽ mà không có mmap

Theo mặc định, trình điều khiển snd-dummy không phân bổ bộ đệm thực
nhưng bỏ qua việc đọc/ghi hoặc mmap một trang giả cho tất cả
các trang đệm để tiết kiệm tài nguyên.  Nếu ứng dụng của bạn cần
dữ liệu bộ đệm đọc/ghi phải nhất quán, chuyển fake_buffer=0
tùy chọn.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-echo3g
-----------------

Mô-đun cho thẻ Echoaudio 3G (Gina3G/Layla3G)

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-emu10k1
------------------

Mô-đun dành cho card âm thanh PCI dựa trên EMU10K1/EMU10k2.

* Âm thanh Blaster trực tiếp!
* Máy phát âm thanh PCI 512
* Âm thanh Blaster Audigy
* E-MU APS (được hỗ trợ một phần)
* E-MU DAS

tuyệt chủng
    bitmap của các đầu vào bên ngoài có sẵn cho FX8010 (xem bên dưới)
thoát ra ngoài
    bitmap của các đầu ra bên ngoài có sẵn cho FX8010 (xem bên dưới)
seq_port
    cổng tuần tự được phân bổ (4 theo mặc định)
max_synth_voices
    giới hạn giọng nói được sử dụng cho wavetable (64 theo mặc định)
max_buffer_size
    chỉ định kích thước tối đa của bộ đệm wavetable/pcm được tính bằng MB
    đơn vị.  Giá trị mặc định là 128.
kích hoạt_ir
    kích hoạt IR

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Cấu hình đầu vào và đầu ra [extin/extout]
* Thẻ sáng tạo có/Đầu ra kỹ thuật số [0x0003/0x1f03]
* Thẻ sáng tạo có đầu ra kỹ thuật số [0x0003/0x1f0f]
* Thẻ sáng tạo có CD kỹ thuật số [0x000f/0x1f0f]
* Thẻ sáng tạo có/Đầu ra kỹ thuật số + LiveDrive [0x3fc3/0x1fc3]
* Thẻ sáng tạo có Digital out + LiveDrive [0x3fc3/0x1fcf]
* Thẻ sáng tạo có CD kỹ thuật số + LiveDrive [0x3fcf/0x1fcf]
* Thẻ sáng tạo có/Đầu ra kỹ thuật số + I/O kỹ thuật số 2 [0x0fc3/0x1f0f]
* Thẻ sáng tạo có đầu ra kỹ thuật số + I/O kỹ thuật số 2 [0x0fc3/0x1f0f]
* Thẻ sáng tạo có đầu vào CD kỹ thuật số + I/O kỹ thuật số 2 [0x0fcf/0x1f0f]
* Creative Card 5.1/w Đầu ra kỹ thuật số + LiveDrive [0x3fc3/0x1fff]
* Thẻ sáng tạo 5.1 (c) 2003 [0x3fc3/0x7cff]
* Thẻ sáng tạo tất cả các chi tiết [0x3fff/0x7fff]
  
Việc quản lý năng lượng được hỗ trợ.
  
Mô-đun snd-emu10k1x
-------------------

Mô-đun dành cho Creative Emu10k1X (phiên bản SB Live Dell OEM)

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-ens1370
------------------

Mô-đun dành cho card âm thanh Ensoniq AudioPCI ES1370 PCI.

* SoundBlaster PCI 64
* SoundBlaster PCI 128
    
cần điều khiển
    Bật cần điều khiển (tắt mặc định)
  
Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-ens1371
------------------

Mô-đun dành cho card âm thanh Ensoniq AudioPCI ES1371 PCI.

* SoundBlaster PCI 64
* SoundBlaster PCI 128
* SoundBlaster Vibra PCI
      
cần điều khiển_port
    cần điều khiển cổng # for (0x200,0x208,0x210,0x218), 0 = tắt
    (mặc định), 1 = tự động phát hiện
  
Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-es1688
-----------------

Mô-đun cho card âm thanh ESS AudioDrive ES-1688 và ES-688.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)
mpu_port
    cổng # for MPU-401 cổng (0x300,0x310,0x320,0x330), -1 = tắt (mặc định)
mpu_irq
    Cổng IRQ # for MPU-401 (5,7,9,10)
fm_port
    cổng # for OPL3 (tùy chọn; chia sẻ cùng một cổng như mặc định)

với ZZ0000ZZ, có sẵn các tùy chọn bổ sung sau:

hải cảng
    cổng chip # for ES-1688 (0x220,0x240,0x260)
không ổn
    Chip IRQ # for ES-1688 (5,7,9,10)
dma8
    Chip DMA # for ES-1688 (0,1,3)

Mô-đun này hỗ trợ nhiều thẻ và autoprobe (không có cổng MPU-401)
và PnP với chip ES968.

Mô-đun snd-es18xx
-----------------

Mô-đun cho card âm thanh ESS AudioDrive ES-18xx.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng chip # for ES-18xx (0x220,0x240,0x260)
mpu_port
    cổng # for MPU-401 cổng (0x300,0x310,0x320,0x330), -1 = tắt (mặc định)
fm_port
    cổng # for FM (tùy chọn, không được sử dụng)
không ổn
    Chip IRQ # for ES-18xx (5,7,9,10)
dma1
    chip DMA # for ES-18xx đầu tiên (0,1,3)
dma2
    chip DMA # for ES-18xx đầu tiên (0,1,3)

Mô-đun này hỗ trợ nhiều thẻ, ISA PnP và autoprobe (không có MPU-401
port nếu các thói quen ISA PnP gốc không được sử dụng).
Khi ZZ0000ZZ bằng ZZ0001ZZ, trình điều khiển hoạt động ở chế độ bán song công.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-es1938
-----------------

Mô-đun dành cho card âm thanh dựa trên chip ESS Solo-1 (ES1938,ES1946).

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-es1968
-----------------

Mô-đun dành cho card âm thanh dựa trên chip ESS Maestro-1/2/2E (ES1968/ES1978).

tổng_bufsize
    tổng kích thước bộ đệm tính bằng kB (1-4096kB)
pcm_substreams_p
    kênh phát lại (1-8, mặc định=2)
pcm_substreams_c
    kênh chụp (1-8, mặc định=0)
đồng hồ
    đồng hồ (0 = tự động phát hiện)
sử dụng_pm
    hỗ trợ quản lý năng lượng (0 = tắt, 1 = bật, 2 = tự động (mặc định))
kích hoạt_mpu
    bật MPU401 (0 = tắt, 1 = bật, 2 = tự động (mặc định))
cần điều khiển
    bật cần điều khiển (tắt mặc định)

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-fm801
----------------

Mô-đun dành cho card âm thanh PCI dựa trên ForteMedia FM801.

trà575x_tuner
    Kích hoạt bộ điều chỉnh TEA575x;
    1 = MediaForte 256-PCS,
    2 = MediaForte 256-PCPR,
    3 = MediaForte 64-PCR
    16 bit cao là số thiết bị video (radio) + 1;
    ví dụ: 0x10002 (MediaForte 256-PCPR, thiết bị 1)
	  
Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-gina20
-----------------

Mô-đun cho Echoaudio Gina20

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-gina24
-----------------

Mô-đun cho Echoaudio Gina24

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-gusclassic
---------------------

Mô-đun dành cho card âm thanh Gravis UltraSound Classic.

hải cảng
    cổng # for GF1 chip (0x220,0x230,0x240,0x250,0x260)
không ổn
    Chip IRQ # for GF1 (3,5,9,11,12,15)
dma1
    Chip DMA # for GF1 (1,3,5,6,7)
dma2
    Chip DMA # for GF1 (1,3,5,6,7,-1=tắt)
cần điều khiển_dac
    0 đến 31, (0,59V-4,52V hoặc 0,389V-2,98V)
tiếng nói
    Giới hạn giọng nói GF1 (14-32)
pcm_voices
    giọng nói PCM dành riêng

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Mô-đun snd-gusextreme
---------------------

Mô-đun dành cho card âm thanh Gravis UltraSound Extreme (Synergy ViperMax).

hải cảng
    cổng # for ES-1688 chip (0x220,0x230,0x240,0x250,0x260)
gf1_port
    cổng # for GF1 chip (0x210,0x220,0x230,0x240,0x250,0x260,0x270)
mpu_port
    cổng # for MPU-401 cổng (0x300,0x310,0x320,0x330), -1 = tắt
không ổn
    Chip IRQ # for ES-1688 (5,7,9,10)
gf1_irq
    Chip IRQ # for GF1 (3,5,9,11,12,15)
mpu_irq
    Cổng IRQ # for MPU-401 (5,7,9,10)
dma8
    Chip DMA # for ES-1688 (0,1,3)
dma1
    Chip DMA # for GF1 (1,3,5,6,7)
cần điều khiển_dac
    0 đến 31, (0,59V-4,52V hoặc 0,389V-2,98V)
tiếng nói
    Giới hạn giọng nói GF1 (14-32)
pcm_voices
    giọng nói PCM dành riêng

Mô-đun này hỗ trợ nhiều thẻ và autoprobe (không có cổng MPU-401).

Mô-đun snd-gusmax
-----------------

Mô-đun cho card âm thanh Gravis UltraSound MAX.

hải cảng
    cổng # for GF1 chip (0x220,0x230,0x240,0x250,0x260)
không ổn
    Chip IRQ # for GF1 (3,5,9,11,12,15)
dma1
    Chip DMA # for GF1 (1,3,5,6,7)
dma2
    Chip DMA # for GF1 (1,3,5,6,7,-1=tắt)
cần điều khiển_dac
    0 đến 31, (0,59V-4,52V hoặc 0,389V-2,98V)
tiếng nói
    Giới hạn giọng nói GF1 (14-32)
pcm_voices
    giọng nói PCM dành riêng

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Mô-đun snd-hda-intel
--------------------

Mô-đun cho âm thanh Intel HD (ICH6, ICH6M, ESB2, ICH7, ICH8, ICH9, ICH10,
PCH, SCH), ATI SB450, SB600, R600, RS600, RS690, RS780, RV610, RV620,
RV630, RV635, RV670, RV770, VIA VT8251/VT8237A, SIS966, ULI M5461

[Nhiều tùy chọn cho từng phiên bản thẻ]

người mẫu
    buộc tên mô hình
vị trí_fix
    Sửa con trỏ DMA;
    -1 = mặc định hệ thống: chọn cái thích hợp cho mỗi phần cứng bộ điều khiển,
    0 = auto: quay trở lại LPIB khi POSBUF không hoạt động,
    1 = sử dụng LPIB,
    2 = POSBUF: sử dụng bộ đệm vị trí,
    3 = VIACOMBO: Cách giải quyết dành riêng cho VIA để chụp,
    4 = COMBO: sử dụng LPIB để phát lại, tự động để ghi luồng
    5 = SKL+: áp dụng tính toán độ trễ có sẵn trên các chip Intel gần đây
    6 = FIFO: sửa vị trí với kích thước FIFO cố định, đối với các chip AMD gần đây
thăm dò_mask
    Bitmask để thăm dò codec (mặc định = -1, nghĩa là tất cả các vị trí);
    Khi bit 8 (0x100) được đặt, 8 bit thấp hơn sẽ được sử dụng
    như các khe cắm codec "cố định"; tức là người lái xe thăm dò
    khe cắm bất kể phần cứng nào báo cáo lại
chỉ thăm dò
    Chỉ thăm dò và không khởi tạo codec (mặc định=tắt);
    Hữu ích để kiểm tra trạng thái codec ban đầu để gỡ lỗi
bdl_pos_adj
    Chỉ định độ trễ thời gian DMA IRQ trong các mẫu.
    Vượt -1 sẽ khiến người lái xe phải lựa chọn phù hợp
    giá trị dựa trên chip điều khiển.
vá
    Chỉ định các tệp "bản vá" sớm để sửa đổi thiết lập âm thanh HD
    trước khi khởi tạo codec.
    Tùy chọn này chỉ khả dụng khi ZZ0000ZZ
    được thiết lập.  Xem hd-audio/notes.rst để biết chi tiết.
chế độ bíp
    Chọn chế độ đăng ký tiếng bíp (0=tắt, 1=bật);
    giá trị mặc định được đặt qua ZZ0001ZZ kconfig.

[Tùy chọn đơn (toàn cầu)]

đơn_cmd
    Sử dụng các lệnh tức thời để giao tiếp với codec
    (chỉ để gỡ lỗi)
kích hoạt_msi
    Bật ngắt tín hiệu tin nhắn (MSI) (mặc định = tắt)
power_save
    Tự động hết thời gian tiết kiệm năng lượng (tính bằng giây, 0 = tắt)
power_save_controller
    Đặt lại bộ điều khiển âm thanh HD ở chế độ tiết kiệm năng lượng (mặc định = bật)
chiều_danh sách đen
    Bật/tắt danh sách từ chối quản lý nguồn (mặc định = tra cứu PM
    danh sách từ chối, 0 = bỏ qua danh sách từ chối PM, 1 = buộc tắt PM thời gian chạy)
căn_buffer_size
    Buộc làm tròn kích thước bộ đệm/thời gian thành bội số của 128 byte.
    Điều này hiệu quả hơn về mặt truy cập bộ nhớ nhưng không
    được yêu cầu bởi thông số HDA và ngăn người dùng chỉ định
    kích thước khoảng thời gian/bộ đệm chính xác. (mặc định = bật)
rình mò
    Bật/tắt tính năng rình mò (mặc định = bật)

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Xem hd-audio/notes.rst để biết thêm chi tiết về trình điều khiển âm thanh HD.

Mỗi codec có thể có một bảng mô hình cho các cấu hình khác nhau.
Nếu máy của bạn không được liệt kê ở đó thì mặc định (thường là tối thiểu)
cấu hình được thiết lập.  Bạn có thể chuyển tùy chọn ZZ0000ZZ cho
chỉ định một mô hình nhất định trong trường hợp như vậy.  Có khác nhau
mô hình tùy thuộc vào chip codec.  Danh sách các mẫu có sẵn
được tìm thấy trong hd-audio/models.rst.

Tên model ZZ0000ZZ được coi là trường hợp đặc biệt.  Khi điều này
mô hình được đưa ra, trình điều khiển sử dụng bộ phân tích cú pháp codec chung mà không
"codec-patch".  Đôi khi nó tốt cho việc thử nghiệm và gỡ lỗi.

Tùy chọn mô hình cũng có thể được sử dụng để đặt bí danh cho PCI hoặc codec khác
SSID.  Khi nó được chuyển ở dạng ZZ0000ZZ trong đó XXXX
và YYYY là ID nhà cung cấp phụ và ID thiết bị phụ ở dạng số hex,
tương ứng, trình điều khiển sẽ gọi SSID đó như một tham chiếu đến
cái bàn kỳ quặc.

Nếu cấu hình mặc định không hoạt động và một trong các cách trên
phù hợp với thiết bị của bạn, hãy báo cáo nó cùng với alsa-info.sh
đầu ra (với tùy chọn ZZ0000ZZ) sang kernel bugzilla hoặc alsa-devel
ML (xem phần ZZ0001ZZ).

Tùy chọn ZZ0000ZZ và ZZ0001ZZ để tiết kiệm năng lượng
chế độ.  Xem powersave.rst để biết chi tiết.

Lưu ý 2: Nếu bạn nhận được tiếng click ở đầu ra, hãy thử tùy chọn mô-đun
ZZ0000ZZ hoặc ZZ0001ZZ.  ZZ0002ZZ sẽ sử dụng SD_LPIB
giá trị đăng ký mà không cần hiệu chỉnh kích thước FIFO như giá trị hiện tại
Con trỏ DMA.  ZZ0003ZZ sẽ làm cho trình điều khiển sử dụng
bộ đệm vị trí thay vì đọc thanh ghi SD_LPIB.
(Thông thường thanh ghi SD_LPIB chính xác hơn thanh ghi
bộ đệm vị trí.)

ZZ0000ZZ dành riêng cho các thiết bị VIA.  vị trí
của luồng chụp được kiểm tra từ cả LPIB và POSBUF
các giá trị.  ZZ0001ZZ là chế độ kết hợp, sử dụng LPIB
để phát lại và POSBUF để chụp.

Lưu ý: Nếu bạn nhận được nhiều tin nhắn ZZ0000ZZ tại
đang tải, có thể đó là sự cố gián đoạn (ví dụ: ACPI irq
định tuyến).  Hãy thử khởi động với các tùy chọn như ZZ0001ZZ.  Ngoài ra, bạn
có thể thử tùy chọn mô-đun ZZ0002ZZ.  Điều này sẽ chuyển đổi
phương thức giao tiếp giữa bộ điều khiển HDA và codec với
các lệnh tức thời duy nhất thay vì CORB/RIRB.  Về cơ bản,
chế độ lệnh đơn chỉ được cung cấp cho BIOS và bạn sẽ không nhận được
những sự kiện không mong muốn nữa.  Nhưng ít nhất, điều này hoạt động độc lập
từ iq.  Hãy nhớ rằng đây là biện pháp cuối cùng và nên
tránh xa nhất có thể...

MORE NOTES TRÊN ZZ0000ZZ PROBLEMS:
Trên một số phần cứng, bạn có thể cần thêm tùy chọn thăm dò_mask thích hợp
thay vào đó, để tránh sự cố ZZ0001ZZ ở trên.
Điều này xảy ra khi quyền truy cập vào khe cắm codec không tồn tại hoặc không hoạt động
(có thể là modem) gây ra tình trạng ngừng liên lạc qua âm thanh HD
xe buýt.  Bạn có thể xem khe codec nào được thăm dò bằng cách bật
ZZ0002ZZ, hay đơn giản là từ tên file của codec
tập tin proc.  Sau đó giới hạn các vị trí để thăm dò bằng tùy chọn thăm dò_mask.
Ví dụ: ZZ0003ZZ có nghĩa là chỉ thăm dò khe đầu tiên và
ZZ0004ZZ chỉ có nghĩa là khe thứ ba.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-hdsp
---------------

Mô-đun cho (các) giao diện âm thanh RME Hammerfall DSP

Mô-đun này hỗ trợ nhiều thẻ.

Lưu ý: Dữ liệu phần sụn có thể được tải tự động qua hotplug
khi ZZ0000ZZ được đặt.  Nếu không, bạn cần phải tải
phần sụn thông qua tiện ích hdsploader có trong alsa-tools
gói.
Dữ liệu phần sụn được tìm thấy trong gói alsa-firmware.

Lưu ý: mô-đun snd-page-alloc thực hiện công việc snd-hammerfall-mem
module đã làm trước đây.  Nó sẽ phân bổ bộ đệm trước
khi tìm thấy bất kỳ thẻ HDSP nào.  Để làm bộ đệm
phân bổ chắc chắn, tải mô-đun snd-page-alloc sớm
giai đoạn của trình tự khởi động.  Xem ZZ0000ZZ
phần.

Mô-đun snd-hdspm
----------------

Mô-đun cho bo mạch RME HDSP MADI.

chính xác_ptr
    Bật con trỏ chính xác hoặc tắt.
line_outs_monitor
    Theo mặc định, gửi luồng phát lại tới đầu ra analog.
kích hoạt_monitor
    Bật Analog Out trên Kênh 63/64 theo mặc định.

Xem hdspm.rst để biết chi tiết.

Mô-đun snd-ice1712
------------------

Mô-đun dành cho card âm thanh PCI dựa trên Envy24 (ICE1712).

* Âm Thanh MidiMan M Delta 1010
* MidiMan M Audio Delta 1010LT
* MidiMan M Audio Delta DiO 2496
* MidiMan M Audio Delta 66
* Âm thanh MidiMan M Delta 44
* MidiMan M Audio Delta 410
* MidiMan M Audio Audiophile 2496
* TerraTec EWS 88MT
* TerraTec EWS 88D
* TerraTec EWX 24/96
* TerraTec DMX 6Fire
* TerraTec Giai đoạn 88
* Hoontech SoundTrack DSP 24
* Giá trị Hoontech SoundTrack DSP 24
* Hoontech SoundTrack DSP 24 Media 7.1
* Điện tử sự kiện, EZ8
* Chữ số VX442
* Lionstracs, Mediastaton
* Terrasoniq TS 88
			
người mẫu
    Sử dụng mô hình bảng đã cho, một trong những mô hình sau:
    delta1010, dio2496, delta66, delta44, audiophile, delta410,
    delta1010lt, vx442, ewx2496, ews88mt, ews88mt_new, ews88d,
    dmx6fire, dsp24, dsp24_value, dsp24_71, ez8,
    giai đoạn88, trung gian
toàn thể
    Hỗ trợ Omni I/O cho MidiMan M-Audio Delta44/66
cs8427_timeout
    đặt lại thời gian chờ cho chip CS8427 (bộ thu phát S/PDIF) tính bằng mili giây
    độ phân giải, giá trị mặc định là 500 (0,5 giây)

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.
Lưu ý: Phần tiêu dùng không được sử dụng với tất cả các thẻ dựa trên Envy24 (đối với
ví dụ trong con đực MidiMan Delta).

Lưu ý: Bo mạch được hỗ trợ được phát hiện bằng cách đọc EEPROM hoặc PCI
SSID (nếu EEPROM không có sẵn).  Bạn có thể ghi đè
mô hình bằng cách chuyển tùy chọn mô-đun ZZ0000ZZ trong trường hợp
trình điều khiển không được cấu hình đúng cách hoặc bạn muốn thử trình điều khiển khác
loại để thử nghiệm.

Mô-đun snd-ice1724
------------------

Mô-đun dành cho card âm thanh PCI dựa trên Envy24HT (VT/ICE1724), Envy24PT (VT1720).

* Cuộc cách mạng âm thanh MidiMan M 5.1
* Cuộc cách mạng âm thanh MidiMan M 7.1
* MidiMan M Audio Audiophile 192
* AMP Ltd AUDIO2000
* Bầu trời TerraTec Aureon 5.1
* Không gian TerraTec Aureon 7.1
* Vũ trụ TerraTec Aureon 7.1
* TerraTec Giai đoạn 22
* TerraTec Giai đoạn 28
* Thần đồng AudioTrak 7.1
* Thần đồng AudioTrak 7.1 LT
* Thần đồng AudioTrak 7.1 XT
* Thần đồng AudioTrak 7.1 HIFI
* Thần đồng AudioTrak 7.1 HD2
* Thần đồng AudioTrak 192
* Pontis MS300
* Albatron K8X800 Pro II 
* Xích công nghệ ZNF3-150
* Xích công nghệ ZNF3-250
* Chaintech 9CJS
* Chaintech AV-710
* Tàu con thoi SN25P
* Onkyo SE-90PCI
* Onkyo SE-200PCI
* ESI Juli@
* ESI Maya44
* Hercules Fortissimo IV
* Đầu cuối sóng EGO-SYS 192M
			
người mẫu
    Sử dụng mô hình bảng đã cho, một trong những mô hình sau:
    revo51, revo71, amp2000, thần đồng71, thần đồng71lt,
    thần đồng71xt, thần đồng71hifi, thần đồng2, thần đồng192,
    tháng bảy, aureon51, aureon71, vũ trụ, ap192, k8x800,
    giai đoạn22, giai đoạn28, ms300, av710, se200pci, se90pci,
    fortissimo4, sn25p, WT192M, maya44
  
Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Lưu ý: Bo mạch được hỗ trợ được phát hiện bằng cách đọc EEPROM hoặc PCI
SSID (nếu EEPROM không có sẵn).  Bạn có thể ghi đè
mô hình bằng cách chuyển tùy chọn mô-đun ZZ0000ZZ trong trường hợp
trình điều khiển không được cấu hình đúng cách hoặc bạn muốn thử trình điều khiển khác
loại để thử nghiệm.

Mô-đun snd-màu chàm
-----------------

Mô-đun cho Echoaudio Indigo

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-indigodj
-------------------

Mô-đun cho Echoaudio Indigo DJ

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-màu chàm
-------------------

Mô-đun cho Echoaudio Indigo IO

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-intel8x0
-------------------

Mô-đun dành cho bo mạch chủ AC'97 của Intel và các bo mạch tương thích.

* Intel i810/810E, i815, i820, i830, i84x, MX440 ICH5, ICH6, ICH7,
  6300ESB, ESB2 
* SiS 7012 (SiS 735)
* NVidia NForce, NForce2, NForce3, MCP04, CK804 CK8, CK8S, MCP501
* AMD AMD768, AMD8111
* ALi m5455
	  
ac97_clock
    Đế đồng hồ codec AC'97 (0 = tự động phát hiện)
ac97_quirk
    Giải pháp AC'97 cho phần cứng lạ;
    Xem phần ZZ0000ZZ bên dưới.
buggy_irq
    Kích hoạt giải pháp khắc phục các lỗi gián đoạn trên một số bo mạch chủ
    (mặc định là có trên chip nForce, nếu không thì tắt)
buggy_semaphore
    Bật giải pháp thay thế cho phần cứng có lỗi ngữ nghĩa (ví dụ: trên một số
    Máy tính xách tay ASUS) (tắt mặc định)
spdif_aclink
    Sử dụng S/PDIF qua liên kết AC thay vì kết nối trực tiếp từ
    chip điều khiển (0 = tắt, 1 = bật, -1 = mặc định)

Mô-đun này hỗ trợ một chip và đầu dò tự động.

Lưu ý: driver mới nhất hỗ trợ tự động nhận diện xung nhịp chip.
nếu bạn vẫn gặp phải tình trạng phát lại quá nhanh, hãy chỉ định đồng hồ
rõ ràng thông qua tùy chọn mô-đun ZZ0000ZZ.

Các cổng cần điều khiển/MIDI không được trình điều khiển này hỗ trợ.  Nếu bạn
bo mạch chủ có các thiết bị này, hãy sử dụng ns558 hoặc snd-mpu401
các mô-đun tương ứng.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-intel8x0m
--------------------

Mô-đun dành cho modem MC97 của chipset Intel ICH (i8x0).

* Intel i810/810E, i815, i820, i830, i84x, MX440 ICH5, ICH6, ICH7
* SiS 7013 (SiS 735)
* NVidia NForce, NForce2, NForce2s, NForce3
* AMD AMD8111
* ALi m5455
	  
ac97_clock
    Đế đồng hồ codec AC'97 (0 = tự động phát hiện)
  
Mô-đun này hỗ trợ một thẻ và tự động thăm dò.

Lưu ý: Giá trị chỉ mục mặc định của mô-đun này là -2, tức là giá trị đầu tiên
khe cắm được loại trừ.

Việc quản lý năng lượng được hỗ trợ.

Module snd-interwave
--------------------

Mô-đun dành cho Gravis UltraSound PnP, Dynasonic 3-D/Pro, STB Sound Rage 32
và các card âm thanh khác dựa trên chip AMD InterWave (tm).

cần điều khiển_dac
    0 đến 31, (0,59V-4,52V hoặc 0,389V-2,98V)
midi
    1 = MIDI UART bật, 0 = MIDI UART tắt (mặc định)
pcm_voices
    giọng nói PCM dành riêng cho bộ tổng hợp (mặc định 2)
hiệu ứng
    1 = Bật hiệu ứng InterWave (mặc định 0); yêu cầu 8 giọng nói
isapnp
    Phát hiện ISA PnP - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng # for Chip InterWave (0x210,0x220,0x230,0x240,0x250,0x260)
không ổn
    Chip liên sóng IRQ # for (3,5,9,11,12,15)
dma1
    Chip liên sóng DMA # for (0,1,3,5,6,7)
dma2
    Chip InterWave DMA # for (0,1,3,5,6,7,-1=tắt)

Mô-đun này hỗ trợ nhiều thẻ, autoprobe và ISA PnP.

Mô-đun snd-interwave-stb
------------------------

Mô-đun cho UltraSound 32-Pro (card âm thanh từ STB được Compaq sử dụng)
và các card âm thanh khác dựa trên chip AMD InterWave (tm) với TEA6330T
mạch để điều khiển mở rộng âm trầm, âm bổng và âm lượng chính.

cần điều khiển_dac
    0 đến 31, (0,59V-4,52V hoặc 0,389V-2,98V)
midi
    1 = MIDI UART bật, 0 = MIDI UART tắt (mặc định)
pcm_voices
    giọng nói PCM dành riêng cho bộ tổng hợp (mặc định 2)
hiệu ứng
    1 = Bật hiệu ứng InterWave (mặc định 0); yêu cầu 8 giọng nói
isapnp
    Phát hiện ISA PnP - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng # for Chip InterWave (0x210,0x220,0x230,0x240,0x250,0x260)
cổng_tc
    cổng điều khiển âm thanh (bus i2c) # for TEA6330T chip (0x350,0x360,0x370,0x380)
không ổn
    Chip InterWave IRQ # for (3,5,9,11,12,15)
dma1
    Chip liên sóng DMA # for (0,1,3,5,6,7)
dma2
    Chip InterWave DMA # for (0,1,3,5,6,7,-1=tắt)

Mô-đun này hỗ trợ nhiều thẻ, autoprobe và ISA PnP.

Mô-đun snd-jazz16
-------------------

Mô-đun dành cho chipset Media Vision Jazz16. Chipset bao gồm 3 chip:
MVD1216 + MVA416 + MVA514.

hải cảng
    cổng # for SB DSP chip (0x210,0x220,0x230,0x240,0x250,0x260)
không ổn
    Chip IRQ # for SB DSP (3,5,7,9,10,15)
dma8
    Chip DMA # for SB DSP (1,3)
dma16
    Chip DMA # for SB DSP (5,7)
mpu_port
    Cổng MPU-401 # (0x300,0x310,0x320,0x330)
mpu_irq
    MPU-401 irq # (2,3,5,7)

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-korg1212
-------------------

Mô-đun cho thẻ Korg 1212 IO PCI

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-layla20
------------------

Mô-đun cho Echoaudio Layla20

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-layla24
------------------

Mô-đun cho Echoaudio Layla24

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-lola
---------------

Mô-đun cho bo mạch Digigram Lola PCI-e

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-lx6464es
-------------------

Mô-đun cho bo mạch Digigram LX6464ES

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-maestro3
-------------------

Mô-đun cho chip Allegro/Maestro3

bên ngoài_amp
    bật amp bên ngoài (được bật theo mặc định)
amp_gpio
    Số chân GPIO cho bộ khuếch đại bên ngoài (0-15) hoặc -1 cho chân mặc định (8
    cho allegro, 1 cho những người khác)

Mô-đun này hỗ trợ autoprobe và nhiều chip.

Lưu ý: ràng buộc của bộ khuếch đại phụ thuộc vào phần cứng.
Nếu không có âm thanh mặc dù tất cả các kênh đều được bật tiếng, hãy thử
chỉ định kết nối gpio khác thông qua tùy chọn amp_gpio. 
Ví dụ: máy tính xách tay Panasonic có thể cần ZZ0000ZZ
tùy chọn.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-mia
---------------

Mô-đun cho Echoaudio Mia

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-miro
---------------

Mô-đun cho card âm thanh Miro: miroSOUND PCM 1 pro, miroSOUND PCM 12,
Đài phát thanh miroSOUND PCM 20.

hải cảng
    Cổng # (0x530,0x604,0xe80,0xf40)
không ổn
    IRQ#(5,7,9,10,11)
dma1
    DMA đầu tiên # (0,1,3)
dma2
    DMA thứ 2 # (0,1)
mpu_port
    Cổng MPU-401 # (0x300,0x310,0x320,0x330)
mpu_irq
    MPU-401 irq # (5,7,9,10)
fm_port
    Cổng FM # (0x388)
cái gì
    bật chế độ WSS
ý tưởng
    kích hoạt hỗ trợ ide trên tàu

Mô-đun snd-mixart
-----------------

Mô-đun cho card âm thanh Digigram miXart8.

Mô-đun này hỗ trợ nhiều thẻ.
Lưu ý: Một bảng miXart8 sẽ được thể hiện dưới dạng 4 thẻ alsa.
Xem Tài liệu/sound/cards/mixart.rst để biết chi tiết.

Khi trình điều khiển được biên dịch dưới dạng mô-đun và chương trình cơ sở cắm nóng
được hỗ trợ, dữ liệu phần sụn sẽ tự động được tải qua hotplug.
Cài đặt các tập tin phần sụn cần thiết trong gói alsa-firmware.
Khi không có sẵn trình tải hotplug fw, bạn cần tải
firmware thông qua tiện ích mixartloader trong gói alsa-tools.

Mô-đun snd-mona
---------------

Mô-đun cho Echoaudio Mona

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-mpu401
-----------------

Mô-đun dành cho thiết bị MPU-401 UART.

hải cảng
    số cổng hoặc -1 (tắt)
không ổn
    Số IRQ hoặc -1 (tắt)
pnp
    Phát hiện PnP - 0 = tắt, 1 = bật (mặc định)

Mô-đun này hỗ trợ nhiều thiết bị và PnP.

Mô-đun snd-msnd-cổ điển
-----------------------

Mô-đun dành cho Turtle Beach MultiSound Classic, Tahiti hoặc Monterey
card âm thanh.

io
    Cổng # for thẻ msnd-classic
không ổn
    IRQ # for thẻ msnd-cổ điển
nhớ
    Địa chỉ bộ nhớ (0xb0000, 0xc8000, 0xd0000, 0xd8000, 0xe0000 hoặc 0xe8000)
viết_ndelay
    kích hoạt ghi ndelay (mặc định = 1)
hiệu chỉnh_signal
    hiệu chỉnh tín hiệu (mặc định = 0)
isapnp
    Phát hiện ISA PnP - 0 = tắt, 1 = bật (mặc định)
kỹ thuật số
    Hiện tại có bo mạch con kỹ thuật số (mặc định = 0)
cfg
    Cổng cấu hình (0x250, 0x260 hoặc 0x270) mặc định = PnP
đặt lại
    Đặt lại tất cả các thiết bị
mpu_io
    Cổng I/O MPU401
mpu_irq
    MPU401 irq#
ide_io0
    Cổng IDE #0
ide_io1
    Cổng IDE #1
ide_irq
    IDE irq#
joystick_io
    Cổng I/O cần điều khiển

Trình điều khiển yêu cầu các tập tin phần sụn ZZ0000ZZ và
ZZ0001ZZ trong thư mục phần mềm thích hợp.

Xem Documentation/sound/cards/multisound.sh để biết thông tin quan trọng
về người lái xe này.  Lưu ý rằng nó đã bị ngưng, nhưng 
Mục cơ sở kiến thức của Voyetra Turtle Beach vẫn có sẵn
tại
ZZ0000ZZ

Mô-đun snd-msnd-đỉnh cao
------------------------

Mô-đun dành cho card âm thanh Turtle Beach MultiSound Pinnacle/Fiji.

io
    Cổng # for đỉnh cao/thẻ fiji
không ổn
    IRQ # for thẻ pinnalce/fiji
nhớ
    Địa chỉ bộ nhớ (0xb0000, 0xc8000, 0xd0000, 0xd8000, 0xe0000 hoặc 0xe8000)
viết_ndelay
    kích hoạt ghi ndelay (mặc định = 1)
hiệu chỉnh_signal
    hiệu chỉnh tín hiệu (mặc định = 0)
isapnp
    Phát hiện ISA PnP - 0 = tắt, 1 = bật (mặc định)

Trình điều khiển yêu cầu các tập tin phần sụn ZZ0000ZZ và
ZZ0001ZZ trong thư mục phần mềm thích hợp.

Mô-đun snd-mtpav
----------------

Mô-đun cho MOTU MidiTimePiece AV đa cổng MIDI (trên song song
cổng).

hải cảng
    Cổng I/O # for MTPAV (0x378,0x278, mặc định=0x378)
không ổn
    IRQ # for MTPAV (7,5, mặc định=7)
hwport
    số cổng phần cứng được hỗ trợ, mặc định = 8.

Mô-đun chỉ hỗ trợ 1 thẻ.  Mô-đun này không có tùy chọn kích hoạt.

Mô-đun snd-mts64
----------------

Mô-đun cho Hệ thống Bản ngã (ESI) Thiết bị đầu cuối trung gian 4140

Mô-đun này hỗ trợ nhiều thiết bị.
Yêu cầu sân bay (ZZ0000ZZ).

Mô-đun snd-nm256
----------------

Mô-đun cho chip NeoMagic NM256AV/ZX

phát lại_bufsize
    kích thước khung phát lại tối đa tính bằng kB (4-128kB)
chụp_bufsize
    kích thước khung hình chụp tối đa tính bằng kB (4-128kB)
lực_ac97
    0 hoặc 1 (bị tắt theo mặc định)
đệm_top
    chỉ định địa chỉ đầu của bộ đệm
use_cache
    0 hoặc 1 (bị tắt theo mặc định)
vaio_hack
    bí danh buffer_top=0x25a800
reset_workaround
    kích hoạt giải pháp AC97 RESET cho một số máy tính xách tay
reset_workaround2
    kích hoạt giải pháp AC97 RESET mở rộng cho một số máy tính xách tay khác

Mô-đun này hỗ trợ một chip và đầu dò tự động.

Việc quản lý năng lượng được hỗ trợ.

Lưu ý: trên một số máy tính xách tay không thể phát hiện được địa chỉ bộ đệm
tự động hoặc gây treo máy trong quá trình khởi tạo.
Trong trường hợp như vậy, hãy chỉ định rõ ràng địa chỉ trên cùng của bộ đệm thông qua
tùy chọn buffer_top.
Ví dụ,
Sony F250: đệm_top=0x25a800
Sony F270: đệm_top=0x272800
Trình điều khiển chỉ hỗ trợ codec ac97.  Có thể ép buộc
để khởi tạo/sử dụng ac97 mặc dù nó không được phát hiện.  Trong một
trường hợp, hãy sử dụng tùy chọn ZZ0000ZZ - nhưng ZZ0001ZZ đảm bảo liệu nó có
hoạt động!

Lưu ý: Chip NM256 có thể được liên kết nội bộ với chip không phải AC97
codec.  Trình điều khiển này chỉ hỗ trợ codec AC97 và sẽ không hoạt động
với các máy có chip khác (rất có thể là CS423x hoặc OPL3SAx),
mặc dù thiết bị được phát hiện trong lspci.  Trong trường hợp như vậy, hãy thử
các trình điều khiển khác, ví dụ: snd-cs4232 hoặc snd-opl3sa2.  Một số có ISA-PnP
nhưng một số không có ISA PnP.  Bạn sẽ cần chỉ định ZZ0000ZZ
và các thông số phần cứng phù hợp trong trường hợp không có ISA PnP.

Lưu ý: một số máy tính xách tay cần có giải pháp thay thế cho AC97 RESET.  Đối với
phần cứng được biết đến như Dell Latitude LS và Sony PCG-F305, điều này
cách giải quyết được kích hoạt tự động.  Đối với các máy tính xách tay khác có
đóng băng cứng, bạn có thể thử tùy chọn ZZ0000ZZ.

Lưu ý: Máy tính xách tay Dell Latitude CSx có một vấn đề khác liên quan đến
AC97 RESET.  Trên các máy tính xách tay này, tùy chọn reset_workaround2 là
được bật làm mặc định.  Tùy chọn này đáng để thử nếu
tùy chọn reset_workaround trước đó không giúp ích được gì.

Lưu ý: Trình điều khiển này thực sự rất tệ.  Đó là một cổng từ
Trình điều khiển OSS, là kết quả của kỹ thuật đảo ngược ma thuật đen.
Việc phát hiện codec sẽ không thành công nếu trình điều khiển được tải ZZ0000ZZ
Máy chủ X như được mô tả ở trên.  Bạn có thể buộc phải tải
mô-đun, nhưng nó có thể dẫn đến treo máy.   Do đó, hãy đảm bảo rằng
bạn tải mô-đun này ZZ0001ZZ X nếu bạn gặp phải loại này
vấn đề.

Mô-đun snd-opl3sa2
------------------

Mô-đun dành cho card âm thanh Yamaha OPL3-SA2/SA3.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng điều khiển chip # for OPL3-SA (0x370)
sb_port
    Cổng SB chip # for OPL3-SA (0x220,0x240)
wss_port
    Cổng WSS Chip # for OPL3-SA (0x530,0xe80,0xf40,0x604)
cổng midi
    cổng # for MPU-401 UART (0x300,0x330), -1 = tắt
fm_port
    Cổng FM # for OPL3-SA chip (0x388), -1 = tắt
không ổn
    Chip IRQ # for OPL3-SA (5,7,9,10)
dma1
    Chip DMA # for Yamaha OPL3-SA đầu tiên (0,1,3)
dma2
    chip DMA # for Yamaha OPL3-SA thứ hai (0,1,3), -1 = tắt

Mô-đun này hỗ trợ nhiều thẻ và ISA PnP.  Nó không hỗ trợ
autoprobe (nếu ISA PnP không được sử dụng) do đó tất cả các cổng phải được chỉ định!!!

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-opti92x-ad1848
-------------------------

Mô-đun dành cho card âm thanh dựa trên chip OPTi 82c92x và Analog Devices AD1848.
Mô-đun này cũng hoạt động với thẻ Mozart OAK.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng # for WSS chip (0x530,0xe80,0xf40,0x604)
mpu_port
    cổng # for MPU-401 UART (0x300,0x310,0x320,0x330)
fm_port
    cổng # for thiết bị OPL3 (0x388)
không ổn
    Chip IRQ # for WSS (5,7,9,10,11)
mpu_irq
    IRQ # for MPU-401 UART (5,7,9,10)
dma1
    chip DMA # for WSS đầu tiên (0,1,3)

Mô-đun này chỉ hỗ trợ một thẻ, autoprobe và PnP.

Mô-đun snd-opti92x-cs4231
-------------------------

Mô-đun dành cho card âm thanh dựa trên chip OPTi 82c92x và Crystal CS4231.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng # for WSS chip (0x530,0xe80,0xf40,0x604)
mpu_port
    cổng # for MPU-401 UART (0x300,0x310,0x320,0x330)
fm_port
    cổng # for thiết bị OPL3 (0x388)
không ổn
    Chip IRQ # for WSS (5,7,9,10,11)
mpu_irq
    IRQ # for MPU-401 UART (5,7,9,10)
dma1
    chip DMA # for WSS đầu tiên (0,1,3)
dma2
    chip DMA # for WSS thứ hai (0,1,3)

Mô-đun này chỉ hỗ trợ một thẻ, autoprobe và PnP.

Mô-đun snd-opti93x
------------------

Mô-đun cho card âm thanh dựa trên chip OPTi 82c93x.

isapnp
    Phát hiện PnP ISA - 0 = tắt, 1 = bật (mặc định)

với ZZ0000ZZ, có các tùy chọn sau:

hải cảng
    cổng # for WSS chip (0x530,0xe80,0xf40,0x604)
mpu_port
    cổng # for MPU-401 UART (0x300,0x310,0x320,0x330)
fm_port
    cổng # for thiết bị OPL3 (0x388)
không ổn
    Chip IRQ # for WSS (5,7,9,10,11)
mpu_irq
    IRQ # for MPU-401 UART (5,7,9,10)
dma1
    chip DMA # for WSS đầu tiên (0,1,3)
dma2
    chip DMA # for WSS thứ hai (0,1,3)

Mô-đun này chỉ hỗ trợ một thẻ, autoprobe và PnP.

Mô-đun snd-oxy
-----------------

Mô-đun cho card âm thanh dựa trên chip C-Media CMI8786/8787/8788:

* Âm thanh A-8788
* Asus Xonar DG/DGX
* AuzenTech X-Meridian
* AuzenTech X-Meridian 2G
* Bgears b-Enspirer
* Nhà hát Club3D DTS
* HT-Omega Claro (cộng)
* Quầng HT-Omega Claro (XT)
* Kuroutoshikou CMI8787-HG2PCI
* Razer Barracuda AC-1
* Địa ngục Sondigo
* TempoTec HiFier Fantasia
* Bản hòa tấu TempoTec HiFier
    
Mô-đun này hỗ trợ autoprobe và nhiều thẻ.
  
Mô-đun snd-pcsp
---------------

Mô-đun cho loa PC bên trong.

nopcm
    Tắt âm thanh PC-Loa PCM. Chỉ còn lại tiếng bíp.
nforce_wa
    kích hoạt giải pháp thay thế chipset NForce. Mong đợi âm thanh xấu.

Mô-đun này hỗ trợ tiếng bíp của hệ thống, một số loại phát lại PCM và
thậm chí một vài điều khiển máy trộn.

Mô-đun snd-pcxhr
----------------

Mô-đun cho bo mạch Digigram PCXHR

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-portman2x4
---------------------

Mô-đun cho giao diện cổng song song Midiman Portman 2x4 MIDI

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-powermac (chỉ trên ppc)
---------------------------------

Mô-đun dành cho chip âm thanh tích hợp PowerMac, iMac và iBook

kích hoạt_bíp
    bật tiếng bíp bằng PCM (được bật làm mặc định)

Mô-đun hỗ trợ tự động thăm dò một con chip.

Lưu ý: trình điều khiển có thể gặp vấn đề về độ bền.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-pxa2xx-ac97 (chỉ trên cánh tay)
------------------------------------

Mô-đun cho trình điều khiển AC97 cho chip Intel PXA2xx

Chỉ dành cho kiến ​​trúc ARM.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-riptide
------------------

Mô-đun cho chip Conexant Riptide

cần điều khiển_port
    Cổng cần điều khiển # (mặc định: 0x200)
mpu_port
    Cổng MPU401 # (mặc định: 0x330)
opl3_port
    Cổng OPL3 # (mặc định: 0x388)

Mô-đun này hỗ trợ nhiều thẻ.
Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.
Bạn cần cài đặt file firmware ZZ0000ZZ theo chuẩn
đường dẫn phần sụn (ví dụ: /lib/firmware).

Mô-đun snd-rme32
----------------

Mô-đun dành cho RME Digi32, Digi32 Pro và Digi32/8 (Sek'd Prodif32, 
Card âm thanh Prodif96 và Prodif Gold).

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-rme96
----------------

Mô-đun dành cho card âm thanh RME Digi96, Digi96/8 và Digi96/8 PRO/PAD/PST.

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-rme9652
------------------

Mô-đun dành cho card âm thanh RME Digi9652 (Hammerfall, Hammerfall-Light).

chính xác_ptr
    Kích hoạt con trỏ chính xác (không hoạt động đáng tin cậy). (mặc định = 0)

Mô-đun này hỗ trợ nhiều thẻ.

Lưu ý: mô-đun snd-page-alloc thực hiện công việc snd-hammerfall-mem
module đã làm trước đây.  Nó sẽ phân bổ bộ đệm trước
khi tìm thấy bất kỳ thẻ RME9652 nào.  Để làm bộ đệm
phân bổ chắc chắn, tải mô-đun snd-page-alloc sớm
giai đoạn của trình tự khởi động.  Xem ZZ0000ZZ
phần.

Mô-đun snd-sa11xx-uda1341 (chỉ trên cánh tay)
---------------------------------------

Mô-đun cho Philips UDA1341TS trên card âm thanh Compaq iPAQ H3600.

Mô-đun chỉ hỗ trợ một thẻ.
Mô-đun không có tùy chọn kích hoạt và lập chỉ mục.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-sb8
--------------

Mô-đun dành cho thẻ SoundBlaster 8 bit: SoundBlaster 1.0, SoundBlaster 2.0,
SoundBlaster Pro

hải cảng
    cổng # for SB DSP chip (0x220,0x240,0x260)
không ổn
    Chip IRQ # for SB DSP (5,7,9,10)
dma8
    Chip DMA # for SB DSP (1,3)

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-sb16 và snd-sbawe
-----------------------------

Mô-đun dành cho thẻ SoundBlaster 16-bit: SoundBlaster 16 (PnP),
SoundBlaster AWE 32 (PnP), SoundBlaster AWE 64 PnP

mic_agc
    Mic Auto-Gain-Control - 0 = tắt, 1 = bật (mặc định)
csp
    Hỗ trợ chip ASP/CSP - 0 = tắt (mặc định), 1 = bật
isapnp
    Phát hiện ISA PnP - 0 = tắt, 1 = bật (mặc định)

với isapnp=0, có các tùy chọn sau:

hải cảng
    cổng # for SB DSP 4.x chip (0x220,0x240,0x260)
mpu_port
    cổng # for MPU-401 UART (0x300,0x330), -1 = tắt
kinh ngạc
    cổng cơ sở # for Bộ tổng hợp EMU8000 (0x620,0x640,0x660) (snd-sbawe
    chỉ mô-đun)
không ổn
    Chip IRQ # for SB DSP 4.x (5,7,9,10)
dma8
    Chip 8-bit DMA # for SB DSP 4.x (0,1,3)
dma16
    Chip 16-bit DMA # for SB DSP 4.x (5,6,7)

Mô-đun này hỗ trợ nhiều thẻ, autoprobe và ISA PnP.

Lưu ý: Để sử dụng thẻ Vibra16X ở chế độ bán song công 16-bit, bạn phải
vô hiệu hóa DMA 16bit với tham số mô-đun dma16 = -1.
Ngoài ra, tất cả các loại thẻ Sound Blaster 16 đều có thể hoạt động ở chế độ 16-bit.
chế độ bán song công thông qua kênh DMA 8 bit bằng cách vô hiệu hóa chúng
Kênh DMA 16 bit.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-sc6000
-----------------

Mô-đun cho card âm thanh Gallant SC-6000 và các mẫu mới hơn: SC-6600 và
SC-7000.

hải cảng
    Cổng # (0x220 hoặc 0x240)
mss_port
    Cổng MSS # (0x530 hoặc 0xe80)
không ổn
    IRQ#(5,7,9,10,11)
mpu_irq
    MPU-401 IRQ # (5,7,9,10),0 - không có MPU-401 irq
dma
    DMA#(1,3,0)
cần điều khiển
    Bật gameport - 0 = tắt (mặc định), 1 = bật

Mô-đun này hỗ trợ nhiều thẻ.

Thẻ này còn được gọi là Audio Excel DSP 16 hoặc Zoltrix AV302.

Mô-đun snd-sscape
-----------------

Mô-đun cho thẻ SoundScape ENSONIQ.

hải cảng
    Cổng # (thiết lập PnP)
wss_port
    Cổng WSS # (thiết lập PnP)
không ổn
    IRQ # (thiết lập PnP)
mpu_irq
    MPU-401 IRQ # (thiết lập PnP)
dma
    DMA # (thiết lập PnP)
dma2
    DMA # thứ 2 (Thiết lập PnP, -1 để tắt)
cần điều khiển
    Bật gameport - 0 = tắt (mặc định), 1 = bật

Mô-đun này hỗ trợ nhiều thẻ.

Trình điều khiển yêu cầu hỗ trợ trình tải chương trình cơ sở trên kernel.

Mô-đun snd-sun-amd7930 (chỉ trên sparc)
--------------------------------------

Mô-đun cho chip âm thanh AMD7930 được tìm thấy trên Sparcs.

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-sun-cs4231 (chỉ trên sparc)
-------------------------------------

Mô-đun cho chip âm thanh CS4231 được tìm thấy trên Sparcs.

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-sun-dbri (chỉ trên sparc)
-----------------------------------

Mô-đun cho chip âm thanh DBRI được tìm thấy trên Sparcs.

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-mặt sóng
--------------------

Mô-đun dành cho card âm thanh Turtle Beach Maui, Tropez và Tropez+.

use_cs4232_midi
    Sử dụng giao diện CS4232 MPU-401
    (không thể truy cập được bên trong máy tính của bạn)
isapnp
    Phát hiện ISA PnP - 0 = tắt, 1 = bật (mặc định)

với isapnp=0, có các tùy chọn sau:

cs4232_pcm_port
    Cổng # for CS4232 PCM giao diện.
cs4232_pcm_irq
    Giao diện IRQ # for CS4232 PCM (5,7,9,11,12,15).
cs4232_mpu_port
    Cổng # for CS4232 MPU-401 giao diện.
cs4232_mpu_irq
    Giao diện IRQ # for CS4232 MPU-401 (9,11,12,15).
ics2115_port
    Cổng # for ICS2115
ics2115_irq
    IRQ # for ICS2115
fm_port
    Cổng FM OPL-3 #
dma1
    Giao diện DMA1 # for CS4232 PCM.
dma2
    Giao diện DMA2 # for CS4232 PCM.

Dưới đây là các tùy chọn cho các tính năng wavefront_synth:

wf_raw
    Giả sử rằng chúng ta cần khởi động HĐH (mặc định: không);
    Nếu có thì trong quá trình tải trình điều khiển, trạng thái của bo mạch là
    bị bỏ qua và chúng tôi vẫn đặt lại bo mạch và tải chương trình cơ sở.
fx_raw
    Giả sử rằng quy trình FX cần trợ giúp (mặc định:có);
    Nếu sai, chúng tôi sẽ để bộ xử lý FX ở bất kỳ trạng thái nào
    khi trình điều khiển được tải.  Mặc định là tải xuống
    vi chương trình và các hệ số liên quan để thiết lập nó cho
    hoạt động "mặc định", bất kể điều đó có nghĩa là gì.
debug_default
    Gỡ lỗi các thông số khởi tạo thẻ
chờ_usecs
    Chờ bao lâu mà không ngủ, usecs (mặc định: 150);
    Con số kỳ diệu này dường như mang lại thông lượng khá tối ưu
    dựa trên thử nghiệm hạn chế của tôi. 
    Nếu bạn muốn thử nghiệm nó và tìm một giá trị tốt hơn, hãy
    khách của tôi. Hãy nhớ rằng, ý tưởng là lấy một con số khiến chúng ta
    chỉ bận chờ càng nhiều lệnh WaveFront càng tốt,
    mà không đưa ra một con số lớn đến mức chúng ta chiếm toàn bộ
    CPU. 
    Cụ thể, với con số này, trong số khoảng 134.000 trạng thái
    chờ đợi, chỉ có khoảng 250 kết quả trong một giấc ngủ. 
khoảng thời gian ngủ
    Ngủ bao lâu khi chờ trả lời (mặc định: 100)
ngủ_thử
    Thử ngủ bao nhiêu lần trong thời gian chờ đợi (mặc định: 50)
người điều hành
    Tên đường dẫn tới chương trình cơ sở hệ điều hành ICS2115 đã xử lý (mặc định: wavefront.os);
    Tên đường dẫn của phần sụn hệ điều hành ISC2115.  Trong thời gian gần đây
    phiên bản, nó được xử lý thông qua khung tải chương trình cơ sở, vì vậy nó
    phải được cài đặt theo đường dẫn thích hợp, thông thường,
    /lib/chương trình cơ sở.
đặt lại_thời gian
    Mất bao lâu để việc thiết lập lại có hiệu lực (mặc định:2)
ramcheck_time
    Mất bao nhiêu giây để chờ kiểm tra RAM (mặc định: 20)
osrun_time
    Hệ điều hành ICS2115 phải chờ bao nhiêu giây (mặc định: 10)

Mô-đun này hỗ trợ nhiều thẻ và ISA PnP.

Lưu ý: tệp chương trình cơ sở ZZ0000ZZ được đặt ở phiên bản trước
phiên bản trong/etc.  Bây giờ nó được tải thông qua trình tải chương trình cơ sở và
phải ở trong đường dẫn phần sụn thích hợp, chẳng hạn như /lib/firmware.
Sao chép (hoặc liên kết tượng trưng) tệp một cách thích hợp nếu bạn gặp lỗi
liên quan đến việc tải xuống firmware sau khi nâng cấp kernel.

Mô-đun snd-sonicvibes
---------------------

Mô-đun cho card âm thanh S3 SonicVibes PCI.
* PINE Schubert 32 PCI
  
hồi âm
    Bật hồi âm - 1 = bật, 0 = tắt (mặc định);
    SoundCard phải có SRAM trên bo mạch để thực hiện việc này.
mge
    Bật Mic Gain - 1 = bật, 0 = tắt (mặc định)

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Mô-đun snd-serial-u16550
------------------------

Mô-đun cho các cổng MIDI nối tiếp UART16550A.

hải cảng
    cổng # for UART16550A chip
không ổn
    Chip IRQ # for UART16550A, -1 = chế độ thăm dò ý kiến
tốc độ
    tốc độ baud (9600,19200,38400,57600,115200)
    38400 = mặc định
căn cứ
    cơ sở cho số chia theo baud (57600,115200,230400,460800)
    115200 = mặc định
ra ngoài
    số cổng MIDI trong một cổng nối tiếp (1-4)
    1 = mặc định
bộ chuyển đổi
    Loại bộ chuyển đổi.
	0 = Soundcanvas, 1 = MS-124T, 2 = MS-124W S/A,
	3 = MS-124W M/B, 4 = Thuốc gốc

Mô-đun này hỗ trợ nhiều thẻ. Mô-đun này không hỗ trợ thăm dò tự động
do đó cổng chính phải được chỉ định!!! Các tùy chọn khác là tùy chọn.

Mô-đun snd-đinh ba
------------------

Mô-đun dành cho card âm thanh Trident 4DWave DX/NX.
* Liên Hoa Hậu Giai Điệu Hay Nhất 4DWave PCI
* HIS 4DWave PCI
* Tốc độ cong vênh ONSpeed 4DWave PCI
* AzTech PCI 64-Q3D
* Addonics SV 750
* CHIC Âm thanh trung thực 4Dwave
* Cá mập Predator4D-PCI
* Jaton SonicWave 4D
* Âm thanh SiS SI7018 PCI
* Hoontech SoundTrack Digital 4DWave NX
		    
pcm_channels
    kênh tối đa (giọng nói) dành riêng cho PCM
kích thước bảng sóng
    kích thước bảng sóng tối đa tính bằng kB (4-?kb)

Mô-đun này hỗ trợ nhiều thẻ và tự động thăm dò.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-ua101
----------------

Mô-đun cho giao diện âm thanh Edirol UA-101/UA-1000/MIDI.

Mô-đun này hỗ trợ nhiều thiết bị, tự động thăm dò và cắm nóng.

Mô-đun snd-usb-âm thanh
--------------------

Mô-đun dành cho thiết bị âm thanh USB và USB MIDI.

video
    ID nhà cung cấp cho thiết bị (tùy chọn)
pid
    ID sản phẩm cho thiết bị (tùy chọn)
nrpack
    Tối đa. số lượng gói trên mỗi URB (mặc định: 8)
thiết lập thiết bị
    Số ma thuật cụ thể của thiết bị (tùy chọn);
    Ảnh hưởng phụ thuộc vào thiết bị
    Mặc định: 0x0000 
bỏ qua_ctl_error
    Bỏ qua mọi bộ điều khiển USB liên quan đến giao diện bộ trộn (mặc định: không)
    ZZ0000ZZ có thể giúp ích khi bạn gặp lỗi khi truy cập
    phần tử bộ trộn chẳng hạn như lỗi URB -22.  Điều này xảy ra trên một số
    thiết bị USB có lỗi hoặc bộ điều khiển.  Cách giải quyết này tương ứng với
    ZZ0001ZZ bit 14 cũng vậy.
đồng hồ tự động
    Bật lựa chọn đồng hồ tự động cho thiết bị UAC2 (mặc định: có)
độ trễ thấp
    Bật chế độ phát lại có độ trễ thấp (mặc định: có).
    Có thể vô hiệu hóa nó để chuyển về chế độ cũ nếu gặp phải tình trạng hồi quy.
quirk_alias
    Danh sách bí danh Quirk, chuyển các chuỗi như ZZ0002ZZ,
    áp dụng cách giải quyết hiện có cho thiết bị 5678: thịt bò cho một thiết bị mới
    thiết bị 0123:abcd.
ngầm_fb
    Áp dụng chế độ đồng bộ hóa phản hồi ngầm chung.  Khi điều này được thiết lập
    và chế độ đồng bộ hóa luồng phát lại là ASYNC, trình điều khiển sẽ cố gắng
    liên kết luồng chụp ASYNC liền kề làm phản hồi ngầm
    nguồn.  Điều này tương đương với bit quirk_flags 17.
use_vmalloc
    Sử dụng vmalloc() để phân bổ bộ đệm PCM (mặc định: có).
    Đối với các kiến trúc có bộ nhớ không kết hợp như ARM hoặc MIPS,
    quyền truy cập mmap có thể cho kết quả không nhất quán với vmalloc'ed
    bộ đệm.  Nếu mmap được sử dụng trên các kiến trúc như vậy, hãy tắt tính năng này
    tùy chọn, để bộ đệm kết hợp DMA được phân bổ và sử dụng
    thay vào đó.
bị trì hoãn_đăng ký
    Tùy chọn này cần thiết cho các thiết bị có nhiều luồng
    được xác định trong nhiều giao diện USB.  Người lái xe có thể gọi
    đăng ký nhiều lần (một lần trên mỗi giao diện) và điều này có thể
    dẫn đến việc liệt kê thiết bị không đầy đủ.
    Tùy chọn này nhận được một chuỗi các chuỗi và bạn có thể chuyển
    ID:INTERFACE thích ZZ0003ZZ vì đã thực hiện trì hoãn
    đăng ký vào thiết bị nhất định.  Trong ví dụ này, khi USB
    máy 0123:abcd bị thăm dò, tài xế chờ đăng ký
    cho đến khi giao diện USB 4 được thăm dò.
    Trình điều khiển in thông báo như "Tìm thấy thiết bị sau đăng ký
    gán: 1234abcd:04" cho thiết bị đó để người dùng có thể
    nhận thấy sự cần thiết.
Skip_validation
    Bỏ qua xác thực mô tả đơn vị (mặc định: không).
    Tùy chọn này được sử dụng để bỏ qua các lỗi xác thực với hexdump
    của bộ mô tả đơn vị thay vì lỗi thăm dò trình điều khiển, để chúng ta
    có thể kiểm tra chi tiết của nó.
quirk_flags
    Tùy chọn này cung cấp khả năng kiểm soát tinh tế và linh hoạt để áp dụng quirk
    cờ.  Nó cho phép chỉ định các cờ quirk cho từng thiết bị và có thể
    được sửa đổi linh hoạt thông qua sysfs.
    Cách sử dụng cũ chấp nhận một mảng các số nguyên, mỗi số đều áp dụng một cách ngẫu nhiên
    cờ trên thiết bị theo thứ tự thăm dò.
    Ví dụ: ZZ0004ZZ áp dụng get_sample_rate cho lần đầu tiên
    thiết bị và share_media_device cho thiết bị thứ hai.
    Cách sử dụng mới chấp nhận một chuỗi ở định dạng
    ZZ0005ZZ, trong đó ZZ0006ZZ và ZZ0007ZZ
    chỉ định thiết bị và ZZ0008ZZ chỉ định các cờ sẽ được áp dụng.
    ZZ0009ZZ và ZZ0010ZZ là các số thập lục phân gồm 4 chữ số và có thể
    được chỉ định là ZZ0011ZZ để khớp với bất kỳ giá trị nào.  ZZ0012ZZ có thể là một bộ
    cờ được đặt theo tên, được phân tách bằng ZZ0013ZZ hoặc số thập lục phân
    đại diện cho các cờ bit.  Tên cờ có sẵn được liệt kê dưới đây.
    Dấu chấm than có thể được đặt trước tên cờ để phủ định cờ.
    Ví dụ: ZZ0014ZZ
    áp dụng cờ ZZ0015ZZ và xóa
    Cờ ZZ0016ZZ cho thiết bị 1234:abcd và áp dụng
    Cờ ZZ0017ZZ cho tất cả các thiết bị.

*bit 0: ZZ0000ZZ
          Bỏ qua tốc độ đọc mẫu cho thiết bị
        * bit 1: ZZ0001ZZ
          Tạo các mục API của Bộ điều khiển phương tiện
        *bit 2: ZZ0002ZZ
          Cho phép căn chỉnh trên khe phụ âm thanh khi truyền
        * bit 3: ZZ0003ZZ
          Thêm thông số xác định độ dài để chuyển
        *bit 4: ZZ0004ZZ
          Bắt đầu phát lại luồng đầu tiên ở chế độ phản hồi triển khai
        *bit 5: ZZ0005ZZ
          Bỏ qua thiết lập bộ chọn đồng hồ
        *bit 6: ZZ0006ZZ
          Bỏ qua lỗi từ tìm kiếm nguồn đồng hồ
        *bit 7: ZZ0007ZZ
          Cho biết DAC dựa trên ITF-USB DSD
        *bit 8: ZZ0008ZZ
          Thêm độ trễ 20ms ở mỗi lần xử lý thông báo điều khiển
        *bit 9: ZZ0009ZZ
          Thêm độ trễ 1-2ms ở mỗi lần xử lý thông báo điều khiển
        *bit 10: ZZ0010ZZ
          Thêm độ trễ 5-6ms ở mỗi lần xử lý thông báo điều khiển
        *bit 11: ZZ0011ZZ
          Thêm độ trễ 50ms ở mỗi lần thiết lập giao diện
        *bit 12: ZZ0012ZZ
          Thực hiện xác nhận tỷ lệ mẫu tại đầu dò
        *bit 13: ZZ0013ZZ
          Tắt tính năng tự động treo PM thời gian chạy
        *bit 14: ZZ0014ZZ
          Bỏ qua các lỗi khi truy cập bộ trộn
        *bit 15: ZZ0015ZZ
          Hỗ trợ định dạng DSD thô chung U32_BE
        *bit 16: ZZ0016ZZ
          Thiết lập giao diện lúc đầu như UAC1
        *bit 17: ZZ0017ZZ
          Áp dụng chế độ đồng bộ phản hồi ngầm chung
        *bit 18: ZZ0018ZZ
          Không áp dụng chế độ đồng bộ hóa phản hồi ngầm
        *bit 19: ZZ0019ZZ
          Không đóng giao diện trong khi cài đặt tốc độ mẫu
        *bit 20: ZZ0020ZZ
          Buộc thiết lập lại giao diện bất cứ khi nào dừng và khởi động lại luồng
        *bit 21: ZZ0021ZZ
          Không đặt tốc độ (tần số) PCM khi chỉ có một tốc độ
          cho điểm cuối nhất định
        *bit 22: ZZ0022ZZ
          Đặt độ phân giải cố định 16 cho Mic Capture Volume
        *bit 23: ZZ0023ZZ
          Đặt độ phân giải cố định 384 cho Mic Capture Volume
        *bit 24: ZZ0024ZZ
          Đặt giá trị điều khiển âm lượng tối thiểu là tắt tiếng cho các thiết bị có
          giá trị phát lại thấp nhất thể hiện trạng thái tắt tiếng thay vì mức tối thiểu
          âm lượng nghe được
        *bit 25: ZZ0025ZZ
          Tương tự như bit 24 nhưng dành cho luồng chụp
        *bit 26: ZZ0026ZZ
          Bỏ qua phần thiết lập giao diện thời gian thăm dò (usb_set_interface,
          init_pitch, init_sample_rate); dư thừa với
          snd_usb_endpoint_prepare() tại thời điểm mở luồng
        *bit 27: ZZ0027ZZ
          Đặt ánh xạ âm lượng tuyến tính cho các thiết bị có âm lượng phát lại
          giá trị điều khiển được ánh xạ tuyến tính tới mức điện áp (thay vì dB).
          Tóm lại: ZZ0028ZZ;
          ZZ0029ZZ; ZZ0030ZZ. Ghi đè bit 24
        *bit 28: ZZ0031ZZ
          Tương tự như bit 27 nhưng dành cho luồng chụp. Ghi đè bit 25

Mô-đun này hỗ trợ nhiều thiết bị, tự động thăm dò và cắm nóng.

Lưu ý: Tham số ZZ0000ZZ có thể được sửa đổi linh hoạt thông qua sysfs.
Đừng đặt giá trị trên 20. Thay đổi thông qua sysfs không có ý nghĩa gì
kiểm tra.

Lưu ý: ZZ0000ZZ chỉ cung cấp một cách nhanh chóng để giải quyết vấn đề
vấn đề.  Nếu bạn có một thiết bị có lỗi yêu cầu những điều kỳ quặc này, vui lòng
báo cáo lên thượng nguồn.

Lưu ý: Tùy chọn ZZ0000ZZ chỉ được cung cấp để thử nghiệm/phát triển.
Nếu bạn muốn có sự hỗ trợ phù hợp hãy liên hệ với thượng nguồn để được hỗ trợ
thêm tĩnh các lỗi phù hợp vào mã trình điều khiển.
Tương tự với ZZ0001ZZ.  Nếu một thiết bị được biết là có yêu cầu cụ thể
cách giải quyết, vui lòng báo cáo lên thượng nguồn.

Mô-đun snd-usb-caiaq
--------------------

Mô-đun cho giao diện âm thanh caiaq UB,

* Dụng cụ bản địa RigKontrol2
* Bộ điều khiển nhạc cụ bản địa Kore
* Kiểm soát âm thanh nhạc cụ bản địa 1
* Nhạc cụ bản địa Audio 8 DJ
	
Mô-đun này hỗ trợ nhiều thiết bị, tự động thăm dò và cắm nóng.
  
Mô-đun snd-usb-usx2y
--------------------

Mô-đun dành cho thiết bị Tascam USB US-122, US-224 và US-428.

Mô-đun này hỗ trợ nhiều thiết bị, tự động thăm dò và cắm nóng.

Lưu ý: bạn cần nạp firmware qua tiện ích ZZ0000ZZ đi kèm
trong các gói alsa-tools và alsa-firmware.

Mô-đun snd-via82xx
------------------

Mô-đun cho bo mạch chủ AC'97 dựa trên VIA 82C686A/686B, 8233, 8233A,
Cầu 8233C, 8235, 8237 (phía nam).

mpu_port
    0x300,0x310,0x320,0x330, nếu không thì lấy thiết lập BIOS
    [Chỉ VIA686A/686B]
cần điều khiển
    Bật cần điều khiển (mặc định tắt) [Chỉ VIA686A/686B]
ac97_clock
    Đế đồng hồ codec AC'97 (mặc định 48000Hz)
dxs_support
    hỗ trợ các kênh DXS, 0 = tự động (mặc định), 1 = bật, 2 = tắt,
    3 = chỉ 48k, 4 = không có VRA, 5 = bật bất kỳ tốc độ mẫu nào và khác nhau
    tốc độ mẫu trên các kênh khác nhau [chỉ VIA8233/C, 8235, 8237]
ac97_quirk
    Giải pháp AC'97 cho phần cứng lạ;
    Xem phần ZZ0000ZZ bên dưới.

Mô-đun này hỗ trợ một chip và đầu dò tự động.

Lưu ý: trên một số bo mạch chủ SMP như MSI 694D, các ngắt có thể xảy ra
không được tạo ra đúng cách.  Trong trường hợp như vậy, hãy cố gắng
đặt phiên bản SMP (hoặc MPS) trên BIOS thành 1.1 thay vì
giá trị mặc định 1.4.  Khi đó số ngắt sẽ là
được chỉ định dưới 15 tuổi. Bạn cũng có thể nâng cấp BIOS của mình.

Lưu ý: VIA8233/5/7 (không phải VIA8233A) có thể hỗ trợ DXS (âm thanh trực tiếp)
các kênh như PCM đầu tiên.  Trên các kênh này, có tới 4
các luồng có thể được phát cùng lúc và bộ điều khiển
có thể thực hiện chuyển đổi tỷ lệ mẫu với các tỷ lệ riêng biệt cho
mỗi kênh.
Theo mặc định (ZZ0000ZZ), tỷ lệ cố định 48k được chọn
ngoại trừ các thiết bị đã biết vì đầu ra thường
ồn ào ngoại trừ 48k trên một số bo mạch chủ do
lỗi của BIOS.
Vui lòng thử một lần ZZ0001ZZ và nếu nó hoạt động trên thiết bị khác
tốc độ mẫu (ví dụ: 44,1kHz khi phát lại mp3), vui lòng cho chúng tôi biết
biết id thiết bị/nhà cung cấp hệ thống con PCI (đầu ra của
ZZ0002ZZ).
Nếu ZZ0003ZZ không hoạt động, hãy thử ZZ0004ZZ; nếu nó
cũng không hoạt động, hãy thử dxs_support=1.  (dxs_support=1 là
thường dành cho bo mạch chủ cũ.  Việc thực hiện đúng
bảng sẽ hoạt động với 4 hoặc 5.) Nếu vẫn không
hoạt động và cài đặt mặc định là ổn, ZZ0005ZZ là
sự lựa chọn đúng đắn.  Nếu cài đặt mặc định hoàn toàn không hoạt động,
thử ZZ0006ZZ để tắt các kênh DXS.
Trong mọi trường hợp, vui lòng cho chúng tôi biết kết quả và
id nhà cung cấp/thiết bị của hệ thống con.  Xem ZZ0007ZZ
bên dưới.

Lưu ý: đối với MPU401 trên VIA823x, hãy sử dụng trình điều khiển snd-mpu401
Ngoài ra.  Tùy chọn mpu_port chỉ dành cho chip VIA686.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-via82xx-modem
------------------------

Mô-đun cho modem VIA82xx AC97

ac97_clock
    Đế đồng hồ codec AC'97 (mặc định 48000Hz)

Mô-đun này hỗ trợ một thẻ và tự động thăm dò.

Lưu ý: Giá trị chỉ mục mặc định của mô-đun này là -2, tức là giá trị đầu tiên
khe cắm được loại trừ.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-virmidi
------------------

Mô-đun cho các thiết bị rawmidi ảo.
Mô-đun này tạo ra các thiết bị rawmidi ảo giao tiếp
đến các cổng tuần tự ALSA tương ứng.

midi_devs
    Thiết bị MIDI # (1-4, mặc định=4)

Mô-đun này hỗ trợ nhiều thẻ.

Mô-đun snd-đạo đức
-------------------

Mô-đun cho card âm thanh dựa trên chip Asus AV66/AV100/AV200,
tức là Xonar D1, DX, D2, D2X, DS, DSX, Essence ST (Deluxe),
Tinh chất STX (II), HDAV1.3 (Deluxe) và HDAV1.3 Slim.

Mô-đun này hỗ trợ autoprobe và nhiều thẻ.

Mô-đun snd-vx222
----------------

Mô-đun cho thẻ Digigram VX-Pocket VX222, V222 v2 và Mic.

micrô
    Bật Micrô trên Mic V222 (NYI)
ibl
    Chụp kích thước IBL. (mặc định = 0, kích thước tối thiểu)

Mô-đun này hỗ trợ nhiều thẻ.

Khi trình điều khiển được biên dịch dưới dạng mô-đun và chương trình cơ sở cắm nóng
được hỗ trợ, dữ liệu phần sụn sẽ tự động được tải qua hotplug.
Cài đặt các tập tin phần sụn cần thiết trong gói alsa-firmware.
Khi không có sẵn trình tải hotplug fw, bạn cần tải
firmware thông qua tiện ích vxloader trong gói alsa-tools.  Để gọi
vxloader tự động, thêm phần sau vào /etc/modprobe.d/alsa.conf

::

cài đặt snd-vx222 /sbin/modprobe --lần đầu tiên -i snd-vx222\
    && /usr/bin/vxloader

(đối với hạt nhân 2.2/2.4, thêm ZZ0000ZZ vào
thay vào đó là /etc/modules.conf.)
Kích thước IBL xác định khoảng thời gian ngắt cho PCM.  Kích thước nhỏ hơn
cho độ trễ nhỏ hơn nhưng cũng dẫn đến mức tiêu thụ CPU nhiều hơn.
Kích thước thường được căn chỉnh thành 126. Theo mặc định (=0), giá trị nhỏ nhất
kích thước được chọn.  Các giá trị IBL có thể được tìm thấy trong
/proc/asound/cardX/vx-status tập tin proc.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-vxpocket
-------------------

Mô-đun cho thẻ Digigram VX-Pocket VX2 và 440 PCMCIA.

ibl
    Chụp kích thước IBL. (mặc định = 0, kích thước tối thiểu)

Mô-đun này hỗ trợ nhiều thẻ.  Mô-đun chỉ được biên dịch khi
PCMCIA được hỗ trợ trên kernel.

Với kernel 2.6.x cũ hơn thì kích hoạt driver qua thẻ
người quản lý, bạn sẽ cần thiết lập /etc/pcmcia/vxpocket.conf.  Xem
âm thanh/pcmcia/vx/vxpocket.c.  Kernel 2.6.13 trở lên không yêu cầu
còn yêu cầu một tập tin cấu hình.

Khi trình điều khiển được biên dịch dưới dạng mô-đun và chương trình cơ sở cắm nóng
được hỗ trợ, dữ liệu phần sụn sẽ tự động được tải qua hotplug.
Cài đặt các tập tin phần sụn cần thiết trong gói alsa-firmware.
Khi không có sẵn trình tải hotplug fw, bạn cần tải
firmware thông qua tiện ích vxloader trong gói alsa-tools.

Về chụp IBL, hãy xem mô tả của mô-đun snd-vx222.

Lưu ý: trình điều khiển snd-vxp440 được hợp nhất với trình điều khiển snd-vxpocket kể từ
ALSA 1.0.10.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-ymfpci
-----------------

Mô-đun dành cho chip Yamaha PCI (YMF72x, YMF74x & YMF75x).

mpu_port
    0x300,0x330,0x332,0x334, 0 (tắt) theo mặc định,
    1 (chỉ tự động phát hiện đối với YMF744/754)
fm_port
    0x388,0x398,0x3a0,0x3a8, 0 (tắt) theo mặc định
    1 (chỉ tự động phát hiện đối với YMF744/754)
cần điều khiển_port
    0x201,0x202,0x204,0x205, 0 (tắt) theo mặc định,
    1 (tự động phát hiện)
công tắc phía sau
    bật công tắc đầu vào/phía sau được chia sẻ (bool)

Mô-đun này hỗ trợ autoprobe và nhiều chip.

Việc quản lý năng lượng được hỗ trợ.

Mô-đun snd-pdaudiocf
--------------------

Mô-đun cho card âm thanh Sound Core PDAudioCF.

Việc quản lý năng lượng được hỗ trợ.


Tùy chọn Quirk AC97
=================

Tùy chọn ac97_quirk được sử dụng để bật/ghi đè giải pháp thay thế cho
các thiết bị cụ thể trên trình điều khiển dành cho bộ điều khiển AC'97 trên bo mạch như
snd-intel8x0.  Một số phần cứng đã hoán đổi chân đầu ra giữa Master
và Tai nghe hoặc Âm thanh vòm (do nhầm lẫn giữa AC'97
thông số kỹ thuật từ phiên bản này sang phiên bản khác :-)

Trình điều khiển cung cấp tính năng tự động phát hiện các thiết bị có vấn đề đã biết,
nhưng một số có thể không xác định được hoặc bị phát hiện sai.  Trong trường hợp như vậy, hãy vượt qua
giá trị thích hợp với tùy chọn này.

Các chuỗi sau được chấp nhận:

mặc định
    Đừng ghi đè cài đặt mặc định
không có
    Vô hiệu hóa sự kỳ quặc
hp_only
    Điều khiển Bind Master và Headphone dưới dạng một điều khiển duy nhất
trao đổi_hp
    Hoán đổi tai nghe và điều khiển chính
trao đổi_bao quanh
    Hoán đổi điều khiển chính và âm thanh vòm
chia sẻ quảng cáo
    Đối với AD1985, hãy bật bit OMS và sử dụng tai nghe
alc_jack
    Đối với ALC65x, bật chế độ cảm biến jack
inv_eapd
    Thực hiện đảo ngược EAPD
tắt tiếng
    Liên kết bit EAPD để bật/tắt tắt tiếng LED

Để tương thích ngược, giá trị nguyên tương ứng -1, 0, ...
cũng được chấp nhận.

Ví dụ: nếu điều khiển âm lượng ZZ0000ZZ không có tác dụng trên thiết bị của bạn
nhưng chỉ ZZ0001ZZ mới có, chuyển tùy chọn mô-đun ac97_quirk=hp_only.


Định cấu hình thẻ không phải ISAPNP
============================

Khi kernel được cấu hình với sự hỗ trợ ISA-PnP, các mô-đun
hỗ trợ thẻ isapnp sẽ có các tùy chọn mô-đun ZZ0000ZZ.
Nếu tùy chọn này được đặt, các thiết bị ZZ0002ZZ, ISA-PnP sẽ được thăm dò.
Để thăm dò các thẻ không phải ISA-PnP, bạn phải chuyển tùy chọn ZZ0001ZZ
cùng với cấu hình i/o và irq thích hợp.

Khi kernel được cấu hình mà không hỗ trợ ISA-PnP, tùy chọn isapnp
sẽ không được tích hợp sẵn.


Hỗ trợ tự động tải mô-đun
==========================

Trình điều khiển ALSA có thể được tải tự động theo yêu cầu bằng cách xác định
bí danh mô-đun.  Chuỗi ZZ0000ZZ được yêu cầu cho ALSA gốc
các thiết bị trong đó ZZ0001ZZ là số card âm thanh từ 0 đến 7.

Để tự động tải trình điều khiển ALSA cho các dịch vụ OSS, hãy xác định chuỗi
ZZ0000ZZ trong đó ZZ0001ZZ có nghĩa là số vị trí dành cho OSS,
tương ứng với chỉ số thẻ của ALSA.  Thông thường, xác định điều này
giống như mô-đun thẻ tương tự.

Cấu hình ví dụ cho một thẻ emu10k1 như sau:
::

----- /etc/modprobe.d/alsa.conf
    bí danh snd-card-0 snd-emu10k1
    bí danh sound-slot-0 snd-emu10k1
    ----- /etc/modprobe.d/alsa.conf

Số lượng card âm thanh tự động tải có sẵn tùy thuộc vào mô-đun
tùy chọn ZZ0000ZZ của mô-đun snd.  Theo mặc định, nó được đặt thành 1.
Để kích hoạt tính năng tự động nạp nhiều thẻ, hãy chỉ định số lượng thẻ
card âm thanh trong tùy chọn đó.

Khi có nhiều thẻ, tốt hơn nên chỉ định chỉ mục
số cho mỗi thẻ thông qua tùy chọn mô-đun cũng vậy, để thứ tự của
thẻ được giữ nhất quán.

Một cấu hình ví dụ cho hai card âm thanh như dưới đây:
::

----- /etc/modprobe.d/alsa.conf
    Phần # ZZ0000ZZ
    tùy chọn thẻ snd_limit=2
    bí danh snd-card-0 snd-interwave
    bí danh snd-card-1 snd-ens1371
    tùy chọn snd-interwave chỉ số = 0
    tùy chọn snd-ens1371 chỉ số = 1
    # ZZ0001ZZ/Phần miễn phí
    bí danh sound-slot-0 snd-interwave
    bí danh sound-slot-1 snd-ens1371
    ----- /etc/modprobe.d/alsa.conf

Trong ví dụ này, thẻ xen kẽ luôn được nạp làm thẻ đầu tiên
(chỉ số 0) và ens1371 là thứ hai (chỉ số 1).

Cách thay thế (và mới) để khắc phục việc gán vị trí là sử dụng
Tùy chọn ZZ0000ZZ của mô-đun snd.  Trong trường hợp trên, hãy chỉ định như
sau đây: 
::

tùy chọn snd slot=snd-interwave,snd-ens1371

Sau đó, khe đầu tiên (#0) được dành riêng cho trình điều khiển snd-interwave và
cái thứ hai (#1) cho snd-ens1371.  Bạn có thể bỏ qua tùy chọn chỉ mục trong mỗi
trình điều khiển nếu tùy chọn khe cắm được sử dụng (mặc dù bạn vẫn có thể có chúng tại
cùng lúc miễn là chúng không xung đột).

Tùy chọn vị trí đặc biệt hữu ích để tránh những điều có thể xảy ra
cắm nóng và dẫn đến xung đột khe cắm.  Ví dụ, trong
trường hợp trên một lần nữa, hai vị trí đầu tiên đã được đặt trước.  Nếu có
trình điều khiển khác (ví dụ: snd-usb-audio) được tải trước snd-interwave hoặc
snd-ens1371, nó sẽ được gán vào vị trí thứ ba trở lên.

Khi tên mô-đun được đặt bằng '!', vị trí sẽ được cấp cho bất kỳ
mô-đun nhưng tên đó.  Ví dụ: ZZ0000ZZ sẽ dự trữ
khe đầu tiên cho bất kỳ mô-đun nào ngoại trừ snd-pcsp.


Ánh xạ thiết bị ALSA PCM sang thiết bị OSS
=======================================
::

/dev/snd/pcmC0D0[c|p] -> /dev/audio0 (/dev/audio) -> nhỏ 4
    /dev/snd/pcmC0D0[c|p] -> /dev/dsp0 (/dev/dsp) -> nhỏ 3
    /dev/snd/pcmC0D1[c|p] -> /dev/adsp0 (/dev/adsp) -> nhỏ 12
    /dev/snd/pcmC1D0[c|p] -> /dev/audio1 -> thứ 4+16 = 20
    /dev/snd/pcmC1D0[c|p] -> /dev/dsp1 -> nhỏ 3+16 = 19
    /dev/snd/pcmC1D1[c|p] -> /dev/adsp1 -> phụ 12+16 = 28
    /dev/snd/pcmC2D0[c|p] -> /dev/audio2 -> thứ 4+32 = 36
    /dev/snd/pcmC2D0[c|p] -> /dev/dsp2 -> nhỏ 3+32 = 39
    /dev/snd/pcmC2D1[c|p] -> /dev/adsp2 -> phụ 12+32 = 44

Số đầu tiên trong biểu thức ZZ0000ZZ có nghĩa là
số card âm thanh và số thứ hai có nghĩa là số thiết bị.  Các thiết bị ALSA
có hậu tố ZZ0001ZZ hoặc ZZ0002ZZ cho biết hướng, chụp và
phát lại, tương ứng.

Xin lưu ý rằng ánh xạ thiết bị ở trên có thể thay đổi thông qua mô-đun
tùy chọn của mô-đun snd-pcm-oss.


Giao diện Proc (/proc/asound)
==============================

/proc/asound/card#/pcm#[cp]/oss
-------------------------------
xóa
    xóa tất cả thông tin bổ sung về ứng dụng OSS

<tên ứng dụng> <đoạn> <kích thước đoạn> [<tùy chọn>]
    <tên ứng dụng>
	tên ứng dụng có (mức độ ưu tiên cao hơn) hoặc không có đường dẫn
    <mảnh vỡ>
	 số mảnh hoặc bằng 0 nếu tự động
    <kích thước mảnh>
	 kích thước của đoạn tính bằng byte hoặc bằng 0 nếu tự động
    <tùy chọn>
	thông số tùy chọn

vô hiệu hóa
	    ứng dụng cố gắng mở một thiết bị pcm để
	    kênh này nhưng không muốn sử dụng nó.
	    (Gây ra lỗi hoặc nhu cầu mmap)
	    Nó tốt cho Quake v.v...
	trực tiếp
	    không sử dụng plugin
	khối
	     chế độ chặn bắt buộc (rvplayer)
	không chặn
	    buộc chế độ không chặn
	nguyên mảnh
	    chỉ viết toàn bộ đoạn (tối ưu hóa ảnh hưởng đến
	    chỉ phát lại)
	không im lặng
	    đừng lấp đầy sự im lặng phía trước để tránh nhấp chuột
	lỗi-ptr
	    Trả về các khối khoảng trắng trong GETOPTR ioctl
	    thay vì các khối đầy

Ví dụ:
::

echo "x11amp 128 16384" > /proc/asound/card0/pcm0p/oss
    echo "tắt tiếng kêu 0 0" > /proc/asound/card0/pcm0c/oss
    echo "khối rvplayer 0 0"> /proc/asound/card0/pcm0p/oss


Phân bổ bộ đệm sớm
=======================

Một số trình điều khiển (ví dụ: hdsp) yêu cầu bộ đệm liền kề lớn và
đôi khi đã quá muộn để tìm những khoảng trống như vậy khi mô-đun trình điều khiển
thực sự được tải do phân mảnh bộ nhớ.  Bạn có thể phân bổ trước
Bộ đệm PCM bằng cách tải mô-đun snd-page-alloc và ghi lệnh vào bộ đệm của nó
proc trước đó, chẳng hạn như trong giai đoạn khởi động sớm như
Tập lệnh ZZ0000ZZ.

Đọc tệp proc /proc/drivers/snd-page-alloc hiển thị hiện tại
cách sử dụng phân bổ trang.  Bằng văn bản, bạn có thể gửi những thông tin sau
lệnh tới trình điều khiển snd-page-alloc:

* thêm VENDOR DEVICE MASK SIZE BUFFERS

VENDOR và DEVICE là ID nhà cung cấp và thiết bị PCI.  Họ lấy
số nguyên (tiền tố 0x là cần thiết cho hex).
MASK là mặt nạ PCI DMA.  Vượt qua 0 nếu không bị hạn chế.
SIZE là kích thước của mỗi bộ đệm cần phân bổ.  Bạn có thể vượt qua
hậu tố k và m cho KB và MB.  Số lượng tối đa là 16 MB.
BUFFERS là số lượng bộ đệm cần phân bổ.  Nó phải lớn hơn
hơn 0. Số tối đa là 4.

* xóa

Điều này sẽ xóa tất cả các bộ đệm được phân bổ trước không có trong
sử dụng.


Liên kết và địa chỉ
===================

Trang chủ dự án ALSA
    ZZ0000ZZ
Hạt nhân Bugzilla
    ZZ0001ZZ
Nhà phát triển ALSA ML
    mailto:alsa-devel@alsa-project.org
tập lệnh alsa-info.sh
    ZZ0002ZZ
