.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/watchdog/watchdog-parameters.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Thông số mô-đun WatchDog
=============================

Tập tin này cung cấp thông tin về các tham số mô-đun của nhiều
trình điều khiển cơ quan giám sát Linux.  Thông số kỹ thuật tham số trình điều khiển Watchdog nên
được liệt kê ở đây trừ khi trình điều khiển có thông tin cụ thể về trình điều khiển
tập tin.

Xem Tài liệu/admin-guide/kernel-parameters.rst để biết thông tin về
cung cấp các tham số kernel cho trình điều khiển dựng sẵn so với khả năng tải
mô-đun.

--------------------------------------------------

lõi cơ quan giám sát:
    open_timeout:
	Thời gian tối đa, tính bằng giây, mà khung giám sát sẽ sử dụng
	quan tâm đến việc ping cơ quan giám sát phần cứng đang chạy cho đến khi không gian người dùng mở
	thiết bị /dev/watchdogN tương ứng. Giá trị 0 có nghĩa là vô hạn
	hết thời gian chờ. Đặt giá trị này thành giá trị khác 0 có thể hữu ích để đảm bảo rằng
	không gian người dùng xuất hiện đúng cách hoặc bảng được đặt lại và cho phép
	logic dự phòng trong bộ nạp khởi động để thử cái gì khác.

--------------------------------------------------

thu đượcwdt:
    wdt_stop:
	Lấy cổng io “stop” của WDT (mặc định 0x43)
    wdt_start:
	Nhận cổng io 'start' WDT (mặc định 0x443)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

advantechwdt:
    wdt_stop:
	Cổng io 'stop' của Advantech WDT (mặc định 0x443)
    wdt_start:
	Cổng io 'bắt đầu' của Advantech WDT (mặc định 0x443)
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 1<= hết thời gian <=63, mặc định=60.
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

alim1535_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (0 < thời gian chờ < 18000, mặc định=60
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

alim7101_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1<=thời gian chờ<=3600, mặc định=30
    use_gpio:
	Sử dụng cơ quan giám sát gpio (được yêu cầu bởi bảng coban cũ).
	mặc định=0/tắt/không
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

ar7_wdt:
    lề:
	Biên độ cơ quan giám sát tính bằng giây (mặc định=60)
    không có gì:
	Vô hiệu hóa việc tắt cơ quan giám sát khi đóng
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

armada_37xx_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (mặc định=120)
    không có gì:
	Vô hiệu hóa việc tắt cơ quan giám sát khi đóng
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

tại91rm9200_wdt:
    wdt_time:
	Thời gian giám sát tính bằng giây. (mặc định=5)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

tại91sam9_wdt:
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây. (mặc định = 15)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

bcm47xx_wdt:
    wdt_time:
	Thời gian giám sát tính bằng giây. (mặc định=30)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

coh901327_wdt:
    lề:
	Biên độ giám sát tính bằng giây (mặc định là 60 giây)

--------------------------------------------------

cpwd:
    wd0_timeout:
	Thời gian chờ watchdog0 mặc định trong 1/10 giây
    wd1_timeout:
	Thời gian chờ watchdog1 mặc định trong 1/10 giây
    wd2_timeout:
	Thời gian chờ watchdog2 mặc định trong 1/10 giây

--------------------------------------------------

da9052wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 2<= hết thời gian <=131, mặc định=2,048 giây
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

davinci_wdt:
    nhịp tim:
	Khoảng thời gian nhịp tim của cơ quan giám sát tính bằng giây từ 1 đến 600, mặc định là 60

--------------------------------------------------

ebc-c384_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1<=thời gian chờ<=15300, mặc định=60)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu

--------------------------------------------------

ep93xx_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1<=thời gian chờ<=3600, mặc định=TBD)

--------------------------------------------------

eurotechwdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)
    tôi:
	Cổng Eurotech WDT io (mặc định=0x3f0)
    không hiểu:
	Eurotech WDT irq (mặc định=10)
    ev:
	Loại sự kiện Eurotech WDT (mặc định là ZZ0000ZZ)

--------------------------------------------------

gef_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

địa chất:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 1<= hết thời gian <=131, mặc định=60.
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

i6300esb:
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây. (1<nhịp tim<2046, mặc định=30)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

iTCO_wdt:
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây.
	(2<nhịp tim<39 (TCO v1) hoặc 613 (TCO v2), mặc định=30)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

ib700wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 0<= hết thời gian <=30, mặc định=30.
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

ibmasr:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

imx2_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây (mặc định là 60 giây)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

indydog:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

iop_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

it8712f_wdt:
    lề:
	Biên độ giám sát tính bằng giây (mặc định 60)
    không có gì:
	Vô hiệu hóa việc tắt cơ quan giám sát khi đóng
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

it87_wdt:
    nogameport:
	Cấm kích hoạt cổng game, mặc định=0
    nocir:
	Cấm sử dụng CIR (giải pháp cho một số thiết lập có lỗi); đặt thành 1 nếu
hệ thống đặt lại mặc dù daemon giám sát đang chạy, mặc định = 0
    độc quyền:
	Thiết bị độc quyền của cơ quan giám sát mở, mặc định = 1
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây, mặc định=60
    chế độ kiểm tra:
	Chế độ kiểm tra cơ quan giám sát (1 = không khởi động lại), mặc định=0
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

ixp4xx_wdt:
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây (mặc định là 60 giây)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

machzwd:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)
    hành động:
	sau khi thiết lập lại cơ quan giám sát, hãy tạo:
	0 = RESET(*) 1 = SMI 2 = NMI 3 = SCI

--------------------------------------------------

max63xx_wdt:
    nhịp tim:
	Khoảng thời gian nhịp tim của cơ quan giám sát tính bằng giây từ 1 đến 60, mặc định là 60
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)
    nút thắt:
	Buộc lựa chọn cài đặt thời gian chờ mà không có độ trễ ban đầu
	(chỉ tối đa6373/74, mặc định=0)

--------------------------------------------------

hỗn hợp:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

mpc8xxx_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng tích tắc. (0<thời gian chờ<65536, mặc định=65535)
    đặt lại:
	Chế độ ngắt/đặt lại cơ quan giám sát. 0 = ngắt, 1 = đặt lại
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

mv64x60_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

ni903x_wdt:
    hết thời gian:
	Thời gian chờ ban đầu của cơ quan giám sát tính bằng giây (0<thời gian chờ<516, mặc định=60)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

nic7018_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát ban đầu tính bằng giây (0<thời gian chờ<464, mặc định=80)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

omap_wdt:
    hẹn giờ_margin:
	thời gian chờ của cơ quan giám sát ban đầu (tính bằng giây)
    sớm_enable:
	Cơ quan giám sát được khởi động khi chèn mô-đun (mặc định=0
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

orion_wdt:
    nhịp tim:
	Nhịp tim cơ quan giám sát ban đầu tính bằng giây
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

pc87413_wdt:
    tôi:
	Cổng I/O pc87413 WDT (mặc định: io).
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng phút (mặc định=thời gian chờ).
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

pika_wdt:
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây. (mặc định = 15)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

pnx4008_wdt:
    nhịp tim:
	Khoảng thời gian nhịp tim của cơ quan giám sát tính bằng giây từ 1 đến 60, mặc định 19
    không có gì:
	Đặt thành 1 để duy trì cơ quan giám sát chạy sau khi phát hành thiết bị

--------------------------------------------------

pnx833x_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng Mhz. (đồng hồ 68Mhz), mặc định=2040000000 (30 giây)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)
    start_enabled:
	Cơ quan giám sát được bắt đầu khi chèn mô-đun (mặc định=1)

--------------------------------------------------

pseries-wdt:
    hành động:
	Hành động được thực hiện khi cơ quan giám sát hết hạn: 0 (tắt nguồn), 1 (khởi động lại),
	2 (đổ và khởi động lại). (mặc định=1)
    hết thời gian:
	Thời gian chờ của cơ quan giám sát ban đầu tính bằng giây. (mặc định=60)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu.
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

RC32434_wdt:
    hết thời gian:
	Giá trị thời gian chờ của cơ quan giám sát, tính bằng giây (mặc định=20)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

riowd:
    riowd_timeout:
	Thời gian chờ của cơ quan giám sát tính bằng phút (mặc định=1)

--------------------------------------------------

s3c2410_wdt:
    tmr_margin:
	Cơ quan giám sát tmr_margin trong vài giây. (mặc định=15)
    tmr_atboot:
	Cơ quan giám sát được khởi động khi khởi động nếu được đặt thành 1, mặc định = 0
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)
    soft_noboot:
	Hành động của cơ quan giám sát, đặt thành 1 để bỏ qua việc khởi động lại, 0 để khởi động lại
    gỡ lỗi:
	Gỡ lỗi cơ quan giám sát, đặt thành >1 để gỡ lỗi, (mặc định 0)

--------------------------------------------------

sa1100_wdt:
    lề:
	Biên độ giám sát tính bằng giây (mặc định là 60 giây)

--------------------------------------------------

sb_wdog:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng micro giây (tối đa/mặc định 8388607 hoặc 8,3 giây)

--------------------------------------------------

sbc60xxwdt:
    wdt_stop:
	Cổng io SBC60xx WDT “stop” (mặc định 0x45)
    wdt_start:
	Cổng io 'start' SBC60xx WDT (mặc định 0x443)
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1<=thời gian chờ<=3600, mặc định=30)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sbc7240_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1<=thời gian chờ<=255, mặc định=30)
    không có gì:
	Vô hiệu hóa cơ quan giám sát khi đóng tập tin thiết bị

--------------------------------------------------

sbc8360:
    hết thời gian:
	Lập chỉ mục vào bảng thời gian chờ (0-63) (mặc định=27 (60s))
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sbc_epx_c3:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sbc_fitpc2_wdt:
    lề:
	Biên độ giám sát tính bằng giây (mặc định là 60 giây)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu

--------------------------------------------------

sbsa_gwdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (mặc định là 10 giây)
    hành động:
	Hành động của cơ quan giám sát ở thời gian chờ ở giai đoạn đầu tiên,
	đặt thành 0 để bỏ qua, 1 để hoảng sợ. (mặc định=0)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sc1200wdt:
    isapnp:
	Khi được đặt thành 0, trình điều khiển ISA hỗ trợ PnP sẽ bị tắt (mặc định=1)
    tôi:
	cổng io
    hết thời gian:
	phạm vi là 0-255 phút, mặc định là 1
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sc520_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1 <= hết thời gian <= 3600, mặc định=30)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sch311x_wdt:
    buộc_id:
	Ghi đè ID thiết bị được phát hiện
    nhiệt_trip:
	ThermTrip có nên kích hoạt trình tạo thiết lập lại không
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 1<= hết thời gian <=15300, mặc định=60
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

scx200_wdt:
    lề:
	Biên độ giám sát tính bằng giây
    không có gì:
	Vô hiệu hóa việc tắt cơ quan giám sát khi đóng

--------------------------------------------------

shwdt:
    clock_division_ratio:
	Tỷ lệ phân chia đồng hồ. Phạm vi hợp lệ là từ 0x5 (1,31 mili giây)
	đến 0x7 (5,25 mili giây). (mặc định=7)
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây. (1 <= nhịp tim <= 3600, mặc định=30
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

smsc37b787_wdt:
    hết thời gian:
	phạm vi là 1-255 đơn vị, mặc định là 60
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

chó mềm:
    lề mềm:
	Cơ quan giám sát soft_margin trong vài giây.
	(0 < soft_margin < 65536, mặc định=60)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)
    soft_noboot:
	Hành động softdog, đặt thành 1 để bỏ qua việc khởi động lại, 0 để khởi động lại
	(mặc định=0)

--------------------------------------------------

stmp3xxx_wdt:
    nhịp tim:
	Khoảng thời gian nhịp tim của cơ quan giám sát tính bằng giây từ 1 đến 4194304, mặc định là 19

--------------------------------------------------

tegra_wdt:
    nhịp tim:
	Nhịp tim của cơ quan giám sát tính bằng giây. (mặc định = 120)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

ts72xx_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1 <= hết thời gian <= 8, mặc định=8)
    không có gì:
	Vô hiệu hóa việc tắt cơ quan giám sát khi đóng

--------------------------------------------------

twl4030_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

txx9wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (0<thời gian chờ<N, mặc định=60)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

uniphier_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát trong khoảng hai giây.
	(1 <= hết thời gian <= 128, mặc định=64)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

w83627hf_wdt:
    wdt_io:
	Cổng io w83627hf/thf WDT (mặc định 0x2E)
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 1 <= hết thời gian <= 255, mặc định=60.
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

w83877f_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. (1<=thời gian chờ<=3600, mặc định=30)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

w83977f_wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây (15..7635), mặc định=45)
    chế độ kiểm tra:
	Chế độ kiểm tra cơ quan giám sát (1 = không khởi động lại), mặc định=0
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

bánh quế5823wdt:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây. 1 <= hết thời gian <= 255, mặc định=60.
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

wdt285:
    lề mềm:
	Thời gian chờ của cơ quan giám sát tính bằng giây (mặc định=60)

--------------------------------------------------

wdt977:
    hết thời gian:
	Thời gian chờ của cơ quan giám sát tính bằng giây (60..15300, mặc định=60)
    chế độ kiểm tra:
	Chế độ kiểm tra cơ quan giám sát (1 = không khởi động lại), mặc định=0
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

wm831x_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

wm8350_wdt:
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
	(mặc định=tham số cấu hình kernel)

--------------------------------------------------

sun4v_wdt:
    thời gian chờ_ms:
	Thời gian chờ của cơ quan giám sát tính bằng mili giây 1..180000, mặc định=60000)
    không có gì:
	Cơ quan giám sát không thể dừng lại một khi đã bắt đầu
