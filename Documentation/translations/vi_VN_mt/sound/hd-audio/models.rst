.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/hd-audio/models.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Model dành riêng cho codec âm thanh HD
======================================

ALC880
======
3 chồng
    3 giắc cắm ở phía sau và đầu ra tai nghe
đào 3 ngăn xếp
    3 giắc cắm ở phía sau, đầu ra HP và đầu ra SPDIF
5 chồng
    5 jack phía sau, 2 jack phía trước
đào 5 ngăn xếp
    5 giắc cắm phía sau, 2 giắc cắm phía trước, một đầu ra SPDIF
6 chồng
    6 jack phía sau, 2 jack phía trước
đào 6 ngăn
    6 giắc cắm có đầu ra SPDIF
6stack-tự động
    6-jack với khả năng phát hiện giắc cắm tai nghe

ALC260
======
gpio1
    Kích hoạt GPIO1
coef
    Kích hoạt EAPD qua bảng COEF
fujitsu
    Quirk cho FSC S7020
fujitsu-jwse
    Quirk cho FSC S7020 với chế độ giắc cắm và hỗ trợ mic HP

ALC262
======
inv-dmic
    Cách giải quyết đảo ngược mic bên trong
fsc-h270
    Bản sửa lỗi cho Fujitsu-Siemens C H270
fsc-s7110
    Các bản sửa lỗi cho Fujitsu-Siemens Lifebook S7110
hp-z200
    Sửa chữa cho HP Z200
ông trùm
    Sửa lỗi cho Tyan Thunder n6650W
lenovo-3000
    Sửa chữa cho Lenovo 3000
benq
    Bản sửa lỗi cho Benq ED8
benq-t31
    Bản sửa lỗi cho Benq T31
bayleybay
    Bản sửa lỗi cho Intel BayleyBay

ALC267/268
==========
inv-dmic
    Cách giải quyết đảo ngược mic bên trong
hp-eapd
    Vô hiệu hóa HP EAPD trên NID 0x15
spdif
    Kích hoạt đầu ra SPDIF trên NID 0x1e

ALC22x/23x/25x/269/27x/28x/29x (và các mẫu ALC3xxx dành riêng cho nhà cung cấp)
===================================================================
laptop-amic
    Laptops with analog-mic input
laptop-dmic
    Laptops with digital-mic input
alc269-dmic
    Enable ALC269(VA) digital mic workaround
alc271-dmic
    Enable ALC271X digital mic workaround
inv-dmic
    Inverted internal mic workaround
headset-mic
    Indicates a combined headset (headphone+mic) jack
headset-mode
    More comprehensive headset support for ALC269 & co
headset-mode-no-hp-mic
    Headset mode support without headphone mic
lenovo-dock
    Enables docking station I/O for some Lenovos
hp-gpio-led
    GPIO LED support on HP laptops
hp-dock-gpio-mic1-led
    HP dock with mic LED support
dell-headset-multi
    Headset jack, which can also be used as mic-in
dell-headset-dock
    Headset jack (without mic-in), and also dock I/O
dell-headset3
    Headset jack (without mic-in), and also dock I/O, variant 3
dell-headset4
    Headset jack (without mic-in), and also dock I/O, variant 4
alc283-dac-wcaps
    Fixups for Chromebook with ALC283
alc283-sense-combo
    Combo jack sensing on ALC283
tpt440-dock
    Pin configs for Lenovo Thinkpad Dock support
tpt440
    Lenovo Thinkpad T440s setup
tpt460
    Lenovo Thinkpad T460/560 setup
tpt470-dock
    Lenovo Thinkpad T470 dock setup
dual-codecs
    Lenovo laptops with dual codecs
alc700-ref
    Intel reference board with ALC700 codec
vaio
    Pin fixups for Sony VAIO laptops
dell-m101z
    COEF setup for Dell M101z
asus-g73jw
    Subwoofer pin fixup for ASUS G73JW
lenovo-eapd
    Inversed EAPD setup for Lenovo laptops
sony-hweq
    H/W EQ COEF setup for Sony laptops
pcm44k
    Fixed PCM 44kHz constraints (for buggy devices)
lifebook
    Dock pin fixups for Fujitsu Lifebook
lifebook-extmic
    Headset mic fixup for Fujitsu Lifebook
lifebook-hp-pin
    Headphone pin fixup for Fujitsu Lifebook
lifebook-u7x7
    Lifebook U7x7 fixups
alc269vb-amic
    ALC269VB analog mic pin fixups
alc269vb-dmic
    ALC269VB digital mic pin fixups
hp-mute-led-mic1
    Mute LED via Mic1 pin on HP
hp-mute-led-mic2
    Mute LED via Mic2 pin on HP
hp-mute-led-mic3
    Mute LED via Mic3 pin on HP
hp-gpio-mic1
    GPIO + Mic1 pin LED on HP
hp-line1-mic1
    Mute LED via Line1 + Mic1 pins on HP
noshutup
    Skip shutup callback
sony-nomic
    Headset mic fixup for Sony laptops
aspire-headset-mic
    Headset pin fixup for Acer Aspire
asus-x101
    ASUS X101 fixups
acer-ao7xx
    Acer AO7xx fixups
acer-aspire-e1
    Acer Aspire E1 fixups
acer-ac700
    Acer AC700 fixups
limit-mic-boost
    Limit internal mic boost on Lenovo machines
asus-zenbook
    ASUS Zenbook fixups
asus-zenbook-ux31a
    ASUS Zenbook UX31A fixups
ordissimo
    Ordissimo EVE2 (or Malata PC-B1303) fixups
asus-tx300
    ASUS TX300 fixups
alc283-int-mic
    ALC283 COEF setup for Lenovo machines
mono-speakers
    Subwoofer and headset fixupes for Dell Inspiron
alc290-subwoofer
    Subwoofer fixups for Dell Vostro
thinkpad
    Binding with thinkpad_acpi driver for Lenovo machines
dmic-thinkpad
    thinkpad_acpi binding + digital mic support
alc255-acer
    ALC255 fixups on Acer machines
alc255-asus
    ALC255 fixups on ASUS machines
alc255-dell1
    ALC255 fixups on Dell machines
alc255-dell2
    ALC255 fixups on Dell machines, variant 2
alc293-dell1
    ALC293 fixups on Dell machines
alc283-headset
    Headset pin fixups on ALC283
aspire-v5
    Acer Aspire V5 fixups
hp-gpio4
    GPIO and Mic1 pin mute LED fixups for HP
hp-gpio-led
    GPIO mute LEDs on HP
hp-gpio2-hotkey
    GPIO mute LED with hot key handling on HP
hp-dock-pins
    GPIO mute LEDs and dock support on HP
hp-dock-gpio-mic
    GPIO, Mic mute LED and dock support on HP
hp-9480m
    HP 9480m fixups
alc288-dell1
    ALC288 fixups on Dell machines
alc288-dell-xps13
    ALC288 fixups on Dell XPS13
dell-e7x
    Dell E7x fixups
alc293-dell
    ALC293 fixups on Dell machines
alc298-dell1
    ALC298 fixups on Dell machines
alc298-dell-aio
    ALC298 fixups on Dell AIO machines
alc275-dell-xps
    ALC275 fixups on Dell XPS models
lenovo-spk-noise
    Workaround for speaker noise on Lenovo machines
lenovo-hotkey
    Hot-key support via Mic2 pin on Lenovo machines
dell-spk-noise
    Workaround for speaker noise on Dell machines
alc255-dell1
    ALC255 fixups on Dell machines
alc295-disable-dac3
    Disable DAC3 routing on ALC295
alc280-hp-headset
    HP Elitebook fixups
alc221-hp-mic
    Front mic pin fixup on HP machines
alc298-spk-volume
    Speaker pin routing workaround on ALC298
dell-inspiron-7559
    Dell Inspiron 7559 fixups
ativ-book
    Samsung Ativ book 8 fixups
alc221-hp-mic
    ALC221 headset fixups on HP machines
alc256-asus-mic
    ALC256 fixups on ASUS machines
alc256-asus-aio
    ALC256 fixups on ASUS AIO machines
alc233-eapd
    ALC233 fixups on ASUS machines
alc294-lenovo-mic
    ALC294 Mic pin fixup for Lenovo AIO machines
alc225-wyse
    Dell Wyse fixups
alc274-dell-aio
    ALC274 fixups on Dell AIO machines
alc255-dummy-lineout
    Dell Precision 3930 fixups
alc255-dell-headset
    Dell Precision 3630 fixups
alc295-hp-x360
    HP Spectre X360 fixups
alc-sense-combo
    Headset button support for Chrome platform
huawei-mbx-stereo
    Enable initialization verbs for Huawei MBX stereo speakers;
    might be risky, try this at your own risk
alc298-samsung-headphone
    Samsung laptops with ALC298
alc256-samsung-headphone
    Samsung laptops with ALC256

ALC66x/67x/892
==============
khao khát
    Sửa chân cắm loa siêu trầm cho laptop Aspire
máy tính xách tay
    Sửa lỗi chân loa siêu trầm cho laptop Ideapad
mario
    Sửa lỗi mô hình Chromebook Mario
hp-rp5800
    Sửa chân cắm tai nghe cho HP RP5800
asus-mode1
    ASUS
asus-mode2
    ASUS
asus-mode3
    ASUS
asus-mode4
    ASUS
asus-mode5
    ASUS
asus-mode6
    ASUS
asus-mode7
    ASUS
asus-mode8
    ASUS
zotac-z68
    Sửa HP mặt trước cho Zotac Z68
inv-dmic
    Cách giải quyết đảo ngược mic bên trong
alc662-tai nghe-đa
    Giắc cắm tai nghe Dell, cũng có thể được sử dụng làm đầu vào mic (ALC662)
dell-tai nghe-đa
    Giắc cắm tai nghe, cũng có thể được sử dụng làm đầu vào mic
tai nghe alc662
    Hỗ trợ chế độ tai nghe trên ALC662
alc668-tai nghe
    Hỗ trợ chế độ tai nghe trên ALC668
âm trầm16
    Sửa loa trầm trên chân 0x16
bass1a
    Sửa loa trầm trên chân 0x1a
tự động hóa
    Bản sửa lỗi tự động tắt tiếng cho ALC668
dell-xps13
    Sửa lỗi Dell XPS13
asus-nx50
    Bản sửa lỗi ASUS Nx50
asus-nx51
    Bản sửa lỗi ASUS Nx51
asus-g751
    Bản sửa lỗi ASUS G751
alc891-tai nghe
    Hỗ trợ chế độ tai nghe trên ALC891
alc891-tai nghe-đa
    Giắc cắm tai nghe Dell, cũng có thể được sử dụng làm đầu vào mic (ALC891)
acer veriton
    Sửa lỗi chân loa Acer Veriton
asrock-mobo
    Sửa các chân 0x15/0x16 không hợp lệ
tai nghe usi
    Hỗ trợ tai nghe trên máy USI
codec kép
    Máy tính xách tay Lenovo có codec kép
alc285-hp-amp-init
    Máy tính xách tay HP yêu cầu khởi tạo bộ khuếch đại loa (ALC285)

ALC680
======
không áp dụng

ALC88x/898/1150/1220
====================
abit-aw9d
    Sửa lỗi pin cho Abit AW9D-MAX
lenovo-y530
    Sửa lỗi pin cho Lenovo Y530
Acer-aspire-7736
    Sửa lỗi Acer Aspire 7736
asus-w90v
    Sửa lỗi pin cho ASUS W90V
đĩa CD
    Kích hoạt chân CD âm thanh NID 0x1c
không có mặt trước-hp
    Vô hiệu hóa pin HP phía trước NID 0x1b
vaio-tt
    Sửa lỗi pin cho VAIO TT
ee1601
    Thiết lập COEF cho ASUS Eee 1601
alc882-eapd
    Thay đổi chế độ EAPD COEF trên ALC882
alc883-eapd
    Thay đổi chế độ EAPD COEF trên ALC883
gpio1
    Kích hoạt GPIO1
gpio2
    Kích hoạt GPIO2
gpio3
    Kích hoạt GPIO3
alc889-coef
    Cài đặt ALC889 COEF
asus-w2jc
    Bản sửa lỗi cho ASUS W2JC
Acer-aspire-4930g
    Acer Aspire 4930G/5930G/6530G/6930G/7730G
acer-aspire-8930g
    Acer Aspire 8330G/6935G
acer-aspire
    Acer Aspire khác
macpro-gpio
    Thiết lập GPIO cho Mac Pro
dac-route
    Cách giải quyết cho việc định tuyến DAC trên Acer Aspire
mbp-vref
    Thiết lập Vref cho Macbook Pro
imac91-vref
    Thiết lập Vref cho iMac 9,1
mba11-vref
    Thiết lập Vref cho MacBook Air 1.1
mba21-vref
    Thiết lập Vref cho MacBook Air 2.1
mp11-vref
    Thiết lập Vref cho Mac Pro 1.1
mp41-vref
    Thiết lập Vref cho Mac Pro 4.1
inv-dmic
    Cách giải quyết đảo ngược mic bên trong
không-chính-hp
    Cách giải quyết VAIO Z/VGC-LN51JGB (đối với loa cố định DAC)
asus-bass
    Thiết lập loa trầm cho ASUS ET2700
codec kép
    Codec kép ALC1220 cho mobo chơi game
clevo-p950
    Các bản sửa lỗi cho Clevo P950

ALC861/660
==========
không áp dụng

ALC861VD/660VD
==============
không áp dụng

CMI9880
=======
tối thiểu
    3 jack ở phía sau
phút_fp
    3 jack phía sau, 2 jack phía trước
đầy đủ
    6 jack phía sau, 2 jack phía trước
full_dig
    6 giắc cắm ở phía sau, 2 giắc cắm ở phía trước, I/O SPDIF
phân phát
    5 giắc cắm phía sau, 2 giắc cắm phía trước, đầu ra SPDIF
tự động
    tự động đọc cấu hình BIOS (mặc định)

AD1882 / AD1882A
================
3 chồng
    Chế độ 3 ngăn xếp
3stack-tự động
    3 ngăn với HP phía trước tự động tắt (mặc định)
6 chồng
    Chế độ 6 ngăn xếp

AD1884A / AD1883 / AD1984A / AD1984B
====================================
máy tính để bàn Máy tính để bàn 3 ngăn (mặc định)
máy tính xách tay máy tính xách tay có cảm biến giắc cắm HP
thiết bị di động di động có cảm biến giắc cắm HP
thinkpad Lenovo Thinkpad X300
cảm ứng thông minh HP Touchsmart

AD1884
======
không áp dụng

AD1981
======
3 jack cơ bản (mặc định)
hp hp nx6320
thinkpad Lenovo Thinkpad T60/X60/Z60
toshiba Toshiba U205

AD1983
======
không áp dụng

AD1984
======
cấu hình mặc định cơ bản
thinkpad Lenovo Thinkpad T61/X61
dell_máy tính để bàn Dell T3400

AD1986A
=======
3 chồng
    3 ngăn xếp, xung quanh được chia sẻ
máy tính xách tay
    Chỉ 2 kênh (FSC V2060, Samsung M50)
imic máy tính xách tay
    2 kênh có tích hợp mic
eapd
    Bật EAPD liên tục

AD1988/AD1988B/AD1989A/AD1989B
==============================
6 chồng
    6 giắc cắm
đào 6 ngăn
    tương tự với SPDIF
3 chồng
    3 giắc cắm
đào 3 ngăn
    tương tự với SPDIF
máy tính xách tay
    3-jack với hp-jack tự động
đào máy tính xách tay
    tương tự với SPDIF
tự động
    tự động đọc cấu hình BIOS (mặc định)

Liên kết 5045
=============
cap-mix-amp
    Sửa mức đầu vào tối đa trên tiện ích bộ trộn
toshiba-p105
    Điều kỳ lạ của Toshiba P105
hp-530
    HP 530 có gì đặc biệt

Liên kết 5047
=============
cap-mix-amp
    Sửa mức đầu vào tối đa trên tiện ích bộ trộn

Liên kết 5051
=============
lenovo-x200
    Điều kỳ lạ của Lenovo X200

Liên kết 5066
=============
dmic âm thanh nổi
    Giải pháp cho mic kỹ thuật số âm thanh nổi đảo ngược
gpio1
    Kích hoạt pin GPIO1
tai nghe-mic-pin
    Bật mic tai nghe NID 0x18 mà không phát hiện
tp410
    Thinkpad T400 và những điều kỳ lạ
thinkpad
    Vấn đề tắt tiếng/mic của Thinkpad LED
lemote-a1004
    Lemote A1004 giải quyết vấn đề
lemote-a1205
    Lemote A1205 giải quyết vấn đề
olpc-xo
    OLPC XO kỳ quặc
tắt tiếng-dẫn-eapd
    Điều khiển tắt tiếng LED qua EAPD
hp-dock
    Hỗ trợ đế cắm HP
tắt tiếng-led-gpio
    Điều khiển tắt tiếng LED qua GPIO
sửa lỗi hp-mic
    Sửa chân mic tai nghe trên hộp HP

STAC9200
========
giới thiệu
    Bảng tham khảo
oqo
    OQO Mẫu 2
dell-d21
    Dell (không rõ)
dell-d22
    Dell (không rõ)
dell-d23
    Dell (không rõ)
dell-m21
    Dell Inspiron 630m, Dell Inspiron 640m
dell-m22
    Dell Latitude D620, Dell Latitude D820
dell-m23
    Dell XPS M1710, Dell Chính Xác M90
dell-m24
    Dell Latitude 120L
dell-m25
    Dell Inspiron E1505n
dell-m26
    Dell Inspiron 1501
dell-m27
    Dell Inspiron E1705/9400
cổng-m4
    Máy tính xách tay cổng có điều khiển EAPD
cổng-m4-2
    Máy tính xách tay cổng có điều khiển EAPD
panasonic
    Panasonic CF-74
tự động
    Thiết lập BIOS (mặc định)

STAC9205/9254
=============
giới thiệu
    Bảng tham khảo
dell-m42
    Dell (không rõ)
dell-m43
    Dell chính xác
dell-m44
    Dell Inspiron
eapd
    Luôn bật EAPD (ví dụ: Cổng T1616)
tự động
    Cài đặt BIOS (mặc định)

STAC9220/9221
=============
giới thiệu
    Bảng tham khảo
3 chồng
    D945 3 ngăn
5 chồng
    D945 5 ngăn + SPDIF
intel-mac-v1
    Intel Mac Loại 1
intel-mac-v2
    Intel Mac Loại 2
intel-mac-v3
    Intel Mac Loại 3
intel-mac-v4
    Intel Mac Loại 4
intel-mac-v5
    Intel Mac Loại 5
intel-mac-auto
    Intel Mac (loại phát hiện theo id hệ thống con)
macmini
    Intel Mac Mini (tương đương loại 3)
macbook
    Intel Mac Book (tương đương loại 5)
macbook-pro-v1
    Intel Mac Book Pro thế hệ 1 (tương đương loại 3)
macbook-pro
    Intel Mac Book Pro thế hệ thứ 2 (tương đương loại 3)
imac-intel
    Intel iMac (tương đương loại 2)
imac-intel-20
    Intel iMac (phiên bản mới hơn) (eq. type 3)
ecs202
    Chip ECS/PC
dell-d81
    Dell (không rõ)
dell-d82
    Dell (không rõ)
dell-m81
    Dell (không rõ)
dell-m82
    Dell XPS M1210
tự động
    Thiết lập BIOS (mặc định)

STAC9202/9250/9251
==================
giới thiệu
    Bảng tham khảo, cấu hình cơ sở
m1
    Một số laptop dòng Gateway MX (NX560XL)
m1-2
    Một số laptop dòng Gateway MX (MX6453)
m2
    Một số laptop dòng Gateway MX (M255)
m2-2
    Một số laptop dòng Gateway MX
m3
    Một số laptop dòng Gateway MX
m5
    Một số laptop dòng Gateway MX (MP6954)
m6
    Một số laptop dòng Gateway NX
tự động
    Thiết lập BIOS (mặc định)

STAC9227/9228/9229/927x
=======================
giới thiệu
    Bảng tham khảo
ref-no-jd
    Bảng tham chiếu không phát hiện giắc cắm HP/Mic
3 chồng
    D965 3 ngăn
5 chồng
    D965 5 ngăn + SPDIF
5stack-no-fp
    D965 5 ngăn không có mặt trước
Dell-3stack
    Kích thước Dell E520
dell-bios
    Sửa lỗi với thiết lập Dell BIOS
dell-bios-amic
    Sửa lỗi với thiết lập Dell BIOS bao gồm mic analog
núm vặn
    Sửa lỗi với tiện ích núm âm lượng 0x24
tự động
    Thiết lập BIOS (mặc định)

STAC92HD71B*
============
giới thiệu
    Bảng tham khảo
dell-m4-1
    Máy tính để bàn Dell
dell-m4-2
    Máy tính để bàn Dell
dell-m4-3
    Máy tính để bàn Dell
hp-m4
    HP mini 1000
hp-dv5
    dòng máy in HP
hp-hdx
    Dòng HP HDX
hp-dv4-1222nr
    HP dv4-1222nr (có hỗ trợ LED)
tự động
    Cài đặt BIOS (mặc định)

STAC92HD73*
===========
giới thiệu
    Bảng tham khảo
không-jd
    Thiết lập BIOS nhưng không phát hiện giắc cắm
thông tin
    Điện thoại di động Intel DZZ0000ZZ
dell-m6-amic
    Máy tính để bàn/máy tính xách tay Dell có mic analog
dell-m6-dmic
    Máy tính để bàn/máy tính xách tay Dell có mic kỹ thuật số
dell-m6
    Máy tính để bàn/máy tính xách tay Dell có cả hai loại mic
dell-eq
    Máy tính để bàn/máy tính xách tay Dell
phần mềm ngoài hành tinh
    Phần mềm Alienware M17x
asus-mobo
    Cấu hình pin cho mobo ASUS có đầu ra 5.1/SPDIF
tự động
    Cài đặt BIOS (mặc định)

STAC92HD83*
===========
giới thiệu
    Bảng tham khảo
mic-ref
    Bảng tham chiếu quản lý nguồn cho các cổng
dell-s14
    máy tính xách tay Dell
dell-vostro-3500
    máy tính xách tay Dell Vostro 3500
hp-dv7-4000
    HP dv-7 4000
hp_cNB11_intquad
    Model HP CNB có 4 loa
hp-zephyr
    HP Zephyr
hp dẫn đầu
    HP bị hỏng BIOS để tắt tiếng LED
hp-inv-led
    HP bị hỏng BIOS để tắt tiếng ngược LED
hp-mic-led
    HP có tính năng tắt tiếng mic LED
jack tai nghe
    Dell Latitude có jack tai nghe 4 chân
hp-ghen tị-bass
    Sửa lỗi pin loa bass HP Envy (NID 0x0f)
hp-ghen tị-ts-bass
    Sửa lỗi pin loa bass HP Envy TS (NID 0x10)
hp-bnb13-eq
    Thiết lập bộ cân bằng phần cứng cho máy tính xách tay HP
hp-ghen tị-ts-bass
    Hỗ trợ âm trầm HP Envy TS
tự động
    Thiết lập BIOS (mặc định)

STAC92HD95
==========
hp dẫn đầu
    Hỗ trợ LED cho laptop HP
hp-bass
    Setup Bass HPF cho HP Spectre 13

STAC9872
========
vaio
    Máy tính xách tay VAIO không có SPDIF
tự động
    Cài đặt BIOS (mặc định)

Cirrus Logic CS4206/4207
========================
mbp53
    MacBook Pro 5,3
mbp55
    MacBook Pro 5,5
imac27
    iMac 27 Inch
imac27_122
    iMac 12,2
táo
    Câu nói chung chung của Apple
mbp101
    MacBookPro 10,1
mbp81
    MacBookPro 8.1
mba42
    MacBookAir 4.2
tự động
    Thiết lập BIOS (mặc định)

Cirrus Logic CS4208
===================
mba6
    MacBook Air 6,1 và 6,2
gpio0
    Kích hoạt GPIO 0 amp
mbp11
    MacBookPro 11,2
macmini
    MacMini 7.1
tự động
    Thiết lập BIOS (mặc định)

VIA VT17xx/VT18xx/VT20xx
========================
tự động
    Thiết lập BIOS (mặc định)
