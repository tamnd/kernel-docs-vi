.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/timekeeping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================================================
Ảo hóa chấm công cho kiến trúc dựa trên X86
======================================================

:Tác giả: Zachary Amsden <zamsden@redhat.com>
:Bản quyền: (c) 2010, Red Hat.  Mọi quyền được bảo lưu.

.. Contents

   1) Overview
   2) Timing Devices
   3) TSC Hardware
   4) Virtualization Problems

1. Tổng quan
===========

Một trong những phần phức tạp nhất của nền tảng X86, cụ thể là
sự ảo hóa của nền tảng này là rất nhiều thiết bị tính thời gian có sẵn
và sự phức tạp của việc mô phỏng các thiết bị đó.  Ngoài ra, ảo hóa
thời gian đưa ra một loạt thách thức mới bởi vì nó đưa ra một hệ thống ghép kênh
phân chia thời gian ngoài tầm kiểm soát của khách CPU.

Đầu tiên, chúng tôi sẽ mô tả các phần cứng máy chấm công khác nhau hiện có, sau đó
trình bày một số vấn đề phát sinh và các giải pháp sẵn có, đưa ra
khuyến nghị cụ thể cho một số hạng khách KVM nhất định.

Mục đích của tài liệu này là thu thập dữ liệu và thông tin liên quan đến
việc chấm công có thể khó tìm thấy ở nơi khác, cụ thể là
thông tin liên quan đến KVM và ảo hóa dựa trên phần cứng.

2. Thiết bị hẹn giờ
=================

Đầu tiên chúng ta thảo luận về các thiết bị phần cứng cơ bản có sẵn.  TSC và những thứ liên quan
Đồng hồ KVM đủ đặc biệt để đảm bảo hiển thị đầy đủ và được mô tả trong
phần sau.

2.1. i8254 - PIT
----------------

Một trong những thiết bị hẹn giờ đầu tiên có sẵn là bộ hẹn giờ ngắt có thể lập trình,
hoặc PIT.  PIT có xung nhịp cơ bản 1,193182 MHz tần số cố định và ba
các kênh có thể được lập trình để cung cấp các ngắt định kỳ hoặc ngắt một lần.
Ba kênh này có thể được cấu hình ở các chế độ khác nhau và có các
quầy.  Kênh 1 và 2 không có sẵn để sử dụng chung trong bản gốc
PC IBM và trước đây được kết nối để điều khiển làm mới RAM và PC
loa.  Giờ đây PIT thường được tích hợp như một phần của chipset mô phỏng
và PIT vật lý riêng biệt không được sử dụng.

PIT sử dụng cổng I/O 0x40 - 0x43.  Việc truy cập vào bộ đếm 16 bit đã hoàn tất
sử dụng quyền truy cập một hoặc nhiều byte vào các cổng I/O.  Có 6 chế độ
có sẵn, nhưng không phải tất cả các chế độ đều có sẵn cho tất cả các bộ hẹn giờ, vì chỉ có bộ hẹn giờ 2
có đầu vào cổng được kết nối, cần thiết cho chế độ 1 và 5. Đường cổng là
được điều khiển bởi cổng 61h, bit 0, như minh họa trong sơ đồ sau::

-------------- -------
  ZZ0000ZZ ZZ0001ZZ
  ZZ0002ZZ---------->ZZ0003ZZ--------> IRQ 0
  ZZ0004ZZ ZZ0005ZZ |
  -------------- ZZ0006ZZ GATE TIMER 0 |
                   |        ----------------
                   |
                   |        ----------------
                   ZZ0007ZZ |
                   ZZ0008ZZ CLOCK OUT | ----------> 66.3 KHZ DRAM
                   ZZ0009ZZ |            (còn gọi là/dev/null)
                   ZZ0010ZZ GATE TIMER 1 |
                   |        ----------------
                   |
                   |        ----------------
                   ZZ0011ZZ |
                   ZZ0012ZZ CLOCK OUT | ----------> Cổng 61h, bit 5
                           ZZ0013ZZ |
  Cổng 61h, bit 0 -------->ZZ0014ZZ \_.---- ____
                            ---------------- _ZZ0015ZZLPF|---Loa
                                                    / *---- \___/
  Cổng 61h, bit 1 ---------------------------------/

Các chế độ hẹn giờ hiện đã được mô tả.

Chế độ 0: Hết giờ một lần.
 Đây là thời gian chờ phần mềm một lần đếm ngược
 khi cổng ở mức cao (luôn đúng với bộ định thời 0 và 1).  Khi đếm
 đạt đến 0, đầu ra tăng cao.

Chế độ 1: Kích hoạt một phát.
 Đầu ra ban đầu được đặt ở mức cao.  Khi cổng
 được đặt ở mức cao, quá trình đếm ngược được bắt đầu (không dừng nếu cổng được
 giảm xuống), trong thời gian đó đầu ra được đặt ở mức thấp.  Khi số đếm đạt tới số không,
 đầu ra tăng cao.

Chế độ 2: Trình tạo tốc độ.
 Đầu ra ban đầu được đặt ở mức cao.  Khi đếm ngược
 đạt đến 1, đầu ra xuống thấp trong một lần đếm và sau đó trở về mức cao.  giá trị
 được tải lại và quá trình đếm ngược tự động tiếp tục.  Nếu đường cổng đi
 thấp, quá trình đếm bị dừng lại.  Nếu đầu ra ở mức thấp khi cổng được hạ xuống,
 đầu ra tự động lên cao (điều này chỉ ảnh hưởng đến bộ định thời 2).

Chế độ 3: Sóng vuông.
 Điều này tạo ra một sóng vuông cao/thấp.  số lượng
 xác định độ dài của xung, xen kẽ giữa cao và thấp
 khi đạt đến số không.  Việc đếm chỉ tiến hành khi cổng ở mức cao và
 tự động tải lại khi đạt đến số không.  Số lượng được giảm hai lần tại
 mỗi đồng hồ để tạo ra một chu kỳ cao/thấp đầy đủ với tốc độ định kỳ đầy đủ.
 Nếu số đếm là chẵn, đồng hồ vẫn ở mức cao đối với N/2 số đếm và ở mức thấp đối với N/2
 đếm; nếu đồng hồ lẻ, đồng hồ ở mức cao đối với số đếm (N+1)/2 và ở mức thấp
 cho số lượng (N-1)/2.  Chỉ có các giá trị chẵn được bộ đếm chốt, nên là số lẻ
 giá trị không được quan sát khi đọc.  Đây là chế độ dự định cho bộ đếm thời gian 2,
 tạo ra các âm giống như hình sin bằng cách lọc thông thấp đầu ra sóng vuông.

Chế độ 4: Nhấp nháy phần mềm.
 Sau khi lập trình chế độ này và nạp bộ đếm,
 đầu ra vẫn ở mức cao cho đến khi bộ đếm đạt đến 0.  Sau đó đầu ra
 xuống mức thấp trong 1 chu kỳ đồng hồ và trở về mức cao.  Bộ đếm không được tải lại.
 Việc đếm chỉ xảy ra khi cổng ở mức cao.

Chế độ 5: Nhấp nháy phần cứng.
 Sau khi lập trình và nạp bộ đếm,
 sản lượng vẫn ở mức cao.  Khi cổng được nâng lên, quá trình đếm ngược sẽ bắt đầu
 (không dừng lại nếu cổng được hạ xuống).  Khi bộ đếm về 0,
 đầu ra xuống thấp trong 1 chu kỳ xung nhịp và sau đó trở về mức cao.  Bộ đếm là
 không được tải lại.

Ngoài tính năng đếm nhị phân thông thường, PIT còn hỗ trợ tính năng đếm BCD.  các
cổng lệnh, 0x43 được sử dụng để đặt bộ đếm và chế độ cho từng cổng trong số ba cổng này.
đồng hồ bấm giờ.

Các lệnh PIT, được cấp cho cổng 0x43, sử dụng mã hóa bit sau::

Bit 7-4: Lệnh (Xem bảng bên dưới)
  Bit 3-1: Chế độ (000 = Chế độ 0, 101 = Chế độ 5, 11X = không xác định)
  Bit 0: Nhị phân (0) / BCD (1)

Bảng lệnh::

0000 - Đếm bộ đếm thời gian chốt 0 cho cổng 0x40
	lấy mẫu và giữ số đếm cần đọc trong cổng 0x40;
	các lệnh bổ sung bị bỏ qua cho đến khi bộ đếm được đọc;
	bit chế độ bị bỏ qua.

0001 - Đặt chế độ Hẹn giờ 0 LSB cho cổng 0x40
	đặt bộ hẹn giờ để chỉ đọc LSB và buộc MSB về 0;
	chế độ bit thiết lập chế độ hẹn giờ

0010 - Đặt chế độ Hẹn giờ 0 MSB cho cổng 0x40
	đặt bộ hẹn giờ để chỉ đọc MSB và buộc LSB về 0;
	chế độ bit thiết lập chế độ hẹn giờ

0011 - Đặt chế độ Hẹn giờ 0 16 bit cho cổng 0x40
	đặt bộ hẹn giờ để đọc / ghi LSB trước, sau đó là MSB;
	chế độ bit thiết lập chế độ hẹn giờ

0100 - Đếm bộ đếm thời gian chốt 1 cho cổng 0x41 - như mô tả ở trên
  0101 - Đặt chế độ Hẹn giờ 1 LSB cho cổng 0x41 - như mô tả ở trên
  0110 - Đặt chế độ Hẹn giờ 1 MSB cho cổng 0x41 - như mô tả ở trên
  0111 - Đặt chế độ 16 bit của Bộ hẹn giờ 1 cho cổng 0x41 - như mô tả ở trên

1000 - Số lượng chốt hẹn giờ 2 cho cổng 0x42 - như được mô tả ở trên
  1001 - Đặt chế độ Hẹn giờ 2 LSB cho cổng 0x42 - như mô tả ở trên
  1010 - Đặt chế độ Hẹn giờ 2 MSB cho cổng 0x42 - như mô tả ở trên
  1011 - Đặt chế độ 16 bit của Bộ hẹn giờ 2 cho cổng 0x42 như mô tả ở trên

1101 - Chốt truy cập chung
	Chốt tổ hợp các bộ đếm vào các cổng tương ứng
	Bit 3 = Bộ đếm 2
	Bit 2 = Bộ đếm 1
	Bit 1 = Bộ đếm 0
	Bit 0 = Không sử dụng

1110 - Trạng thái hẹn giờ chốt
	Chốt kết hợp chế độ đếm vào các cổng tương ứng
	Bit 3 = Bộ đếm 2
	Bit 2 = Bộ đếm 1
	Bit 1 = Bộ đếm 0

Đầu ra của các cổng 0x40-0x42 theo lệnh này sẽ là:

Bit 7 = Chân đầu ra
	Bit 6 = Đã tải số đếm (0 nếu bộ đếm thời gian đã hết hạn)
	Bit 5-4 = Chế độ đọc/ghi
	    01 = chỉ MSB
	    10 = chỉ LSB
	    11 = LSB / MSB (16-bit)
	Bit 3-1 = Chế độ
	Bit 0 = Chế độ nhị phân (0) / BCD (1)

2.2. RTC
--------

Thiết bị thứ hai có sẵn trong PC gốc là MC146818 real
đồng hồ thời gian.  Thiết bị ban đầu hiện đã lỗi thời và thường được mô phỏng bởi
chipset hệ thống, đôi khi bằng HPET và một số định tuyến Frankenstein IRQ.

RTC được truy cập thông qua các biến CMOS, sử dụng thanh ghi chỉ mục để
kiểm soát byte nào được đọc.  Vì chỉ có một thanh ghi chỉ mục nên hãy đọc
của CMOS và việc đọc của RTC yêu cầu bảo vệ khóa (ngoài ra, nó còn
nguy hiểm khi cho phép các tiện ích không gian người dùng như hwclock có RTC trực tiếp
truy cập, vì chúng có thể làm hỏng việc đọc và ghi kernel của bộ nhớ CMOS).

RTC tạo ra một ngắt thường được định tuyến đến IRQ 8. Ngắt
có thể hoạt động như một bộ đếm thời gian định kỳ, một báo thức bổ sung mỗi ngày một lần và có thể phát ra
bị gián đoạn sau khi quá trình cập nhật các thanh ghi CMOS của MC146818 hoàn tất.
Loại ngắt được báo hiệu trong thanh ghi trạng thái RTC.

RTC sẽ cập nhật các trường thời gian hiện tại bằng nguồn pin ngay cả khi
hệ thống đã tắt.  Không nên đọc các trường thời gian hiện tại trong khi cập nhật
đang diễn ra, như được chỉ ra trong thanh ghi trạng thái.

Đồng hồ sử dụng tinh thể 32,768kHz, do đó các bit 6-4 của thanh ghi A phải là
được lập trình thành bộ chia 32kHz nếu RTC đếm giây.

Đây là bản đồ RAM ban đầu được sử dụng cho RTC/CMOS::

Vị trí Kích thước Mô tả
  ------------------------------------------
  00h byte giây hiện tại (BCD)
  Báo động giây 01h byte (BCD)
  02h byte Phút hiện tại (BCD)
  Báo động phút 03h byte (BCD)
  04h byte Giờ hiện tại (BCD)
  Báo giờ 05h byte (BCD)
  06h byte Ngày hiện tại trong tuần (BCD)
  07h byte Ngày hiện tại trong tháng (BCD)
  08h byte Tháng hiện tại (BCD)
  09h byte Năm hiện tại (BCD)
  0Ah byte Đăng ký A
                       bit 7 = Đang cập nhật
                       bit 6-4 = Bộ chia cho đồng hồ
                                  000 = 4,194 MHz
                                  001 = 1,049 MHz
                                  010 = 32 kHz
                                  10X = chế độ kiểm tra
                                  110 = đặt lại/tắt
                                  111 = đặt lại/tắt
                       bit 3-0 = Lựa chọn tốc độ cho ngắt định kỳ
                                  000 = tắt bộ hẹn giờ định kỳ
                                  001 = 3,90625 uS
                                  010 = 7,8125 uS
                                  011 = 0,122070 mS
                                  100 = 0,244141 mS
                                     ...
1101 = 125 mS
                                 1110 = 250 mS
                                 1111 = 500 mS
  Thanh ghi 0Bh byte B
                       bit 7 = Chạy (0) / Dừng (1)
                       bit 6 = Cho phép ngắt định kỳ
                       bit 5 = Cho phép ngắt cảnh báo
                       bit 4 = Cho phép ngắt kết thúc cập nhật
                       bit 3 = cho phép ngắt sóng vuông
                       bit 2 = lịch BCD (0) / Nhị phân (1)
                       bit 1 = chế độ 12 giờ (0) / chế độ 24 giờ (1)
                       bit 0 = 0 (tắt DST) / 1 (bật DST)
  Thanh ghi byte OCh C (chỉ đọc)
                       bit 7 = cờ yêu cầu ngắt (IRQF)
                       bit 6 = cờ ngắt định kỳ (PF)
                       bit 5 = cờ ngắt cảnh báo (AF)
                       bit 4 = cờ ngắt cập nhật (UF)
                       bit 3-0 = dành riêng
  Thanh ghi byte ODh D (chỉ đọc)
                       bit 7 = RTC có điện
                       bit 6-0 = dành riêng
  32h byte Thế kỷ hiện tại BCD (*)
  (*) vị trí cụ thể của nhà cung cấp và hiện được xác định từ bảng toàn cầu ACPI

2.3. APIC
---------

Trên các bộ xử lý Pentium và mới hơn, bộ hẹn giờ tích hợp có sẵn cho mỗi CPU
như một phần của Bộ điều khiển ngắt lập trình nâng cao.  APIC là
được truy cập thông qua các thanh ghi được ánh xạ bộ nhớ và cung cấp dịch vụ ngắt cho mỗi thanh ghi
CPU, được sử dụng cho IPI và ngắt hẹn giờ cục bộ.

Mặc dù về mặt lý thuyết, APIC là nguồn an toàn và ổn định cho các ngắt cục bộ,
trong thực tế đã xảy ra nhiều lỗi, trục trặc do tính chất đặc biệt của
phần cứng ánh xạ bộ nhớ cục bộ APIC CPU.  Hãy cẩn thận rằng lỗi CPU có thể ảnh hưởng đến
việc sử dụng APIC và các cách giải quyết đó có thể được yêu cầu.  Ngoài ra, một số
những cách giải quyết này đặt ra những hạn chế duy nhất cho việc ảo hóa - yêu cầu một trong hai
chi phí bổ sung phát sinh từ việc đọc thêm I/O được ánh xạ bộ nhớ hoặc bổ sung
chức năng có thể tốn kém hơn về mặt tính toán để thực hiện.

Vì APIC được ghi lại khá đầy đủ trong sách hướng dẫn sử dụng Intel và AMD nên chúng tôi sẽ
tránh lặp lại chi tiết ở đây.  Cần phải chỉ ra rằng APIC
bộ đếm thời gian được lập trình thông qua thanh ghi LVT (bộ đếm thời gian vector cục bộ), có khả năng
hoạt động một lần hoặc định kỳ và dựa trên đồng hồ xe buýt được chia nhỏ
bởi thanh ghi chia lập trình được.

2.4. HPET
---------

HPET khá phức tạp và ban đầu được dự định thay thế PIT / RTC
hỗ trợ của PC X86.  Vẫn còn phải xem liệu điều đó có xảy ra hay không, vì
tiêu chuẩn thực tế của phần cứng PC là mô phỏng các thiết bị cũ hơn này.  Một số
các hệ thống được chỉ định là không có di sản có thể chỉ hỗ trợ HPET làm bộ hẹn giờ phần cứng
thiết bị.

Thông số HPET khá lỏng lẻo và mơ hồ, yêu cầu ít nhất 3 bộ định thời phần cứng,
nhưng cho phép tự do thực hiện để hỗ trợ nhiều hơn nữa.  Nó cũng áp đặt không
tốc độ cố định trên tần số bộ định thời, nhưng áp đặt một số giá trị cực trị lên
tần số, lỗi và xoay.

Nhìn chung, HPET được khuyến nghị có độ chính xác cao (so với PIT /RTC)
nguồn thời gian độc lập với biến thiên cục bộ (vì chỉ có một HPET
trong bất kỳ hệ thống nhất định nào).  HPET cũng được ánh xạ bộ nhớ và sự hiện diện của nó là
được biểu thị qua các bảng ACPI bởi BIOS.

Thông số kỹ thuật chi tiết của HPET nằm ngoài phạm vi hiện tại của điều này
tài liệu, vì nó cũng được ghi chép rất đầy đủ ở nơi khác.

2.5. Bộ hẹn giờ ngoài khơi
--------------------

Một số thẻ, cả thẻ độc quyền (bảng giám sát) và thẻ thông thường (e1000) đều có
chip thời gian được tích hợp trong thẻ có thể có các thanh ghi có thể truy cập được
tới kernel hoặc trình điều khiển người dùng.  Theo hiểu biết của tác giả, việc sử dụng chúng để tạo ra
nguồn xung nhịp cho Linux hoặc kernel khác vẫn chưa được thử và đang ở trạng thái
Tướng quân tỏ ra khó chịu vì không chơi theo các quy tắc đã thỏa thuận của trò chơi.  Như vậy
thiết bị hẹn giờ sẽ yêu cầu hỗ trợ bổ sung để được ảo hóa đúng cách và
không được coi là quan trọng vào thời điểm này vì chưa có hệ điều hành nào thực hiện được điều này.

3. Phần cứng TSC
===============

Về mặt lý thuyết, TSC hoặc bộ đếm dấu thời gian tương đối đơn giản; nó có giá trị
chu kỳ hướng dẫn do bộ xử lý đưa ra, có thể được sử dụng như một thước đo
thời gian.  Trong thực tế, do có một số vấn đề nên đây là vấn đề phức tạp nhất
thiết bị chấm công để sử dụng.

TSC được thể hiện bên trong dưới dạng MSR 64-bit có thể được đọc bằng
Hướng dẫn RDMSR, RDTSC hoặc RDTSCP (nếu có).  Trước đây, phần cứng
những hạn chế khiến cho việc viết TSC có thể xảy ra, nhưng nhìn chung trên phần cứng cũ, nó
chỉ có thể ghi 32 bit thấp của bộ đếm 64 bit và phần trên
32 bit của bộ đếm đã bị xóa.  Tuy nhiên, hiện nay trên dòng bộ xử lý Intel
0Fh, đối với các mẫu 3, 4 và 6 và họ 06h, các mẫu e và f, hạn chế này
đã được dỡ bỏ và tất cả 64-bit đều có thể ghi được.  Trên hệ thống AMD, khả năng
viết TSC MSR không phải là sự đảm bảo về mặt kiến trúc.

TSC có thể truy cập được từ CPL-0 và có điều kiện, đối với phần mềm CPL > 0 bằng
nghĩa là bit CR4.TSD, khi được bật sẽ vô hiệu hóa quyền truy cập CPL > 0 TSC.

Một số nhà cung cấp đã triển khai một lệnh bổ sung, RDTSCP, trả về
về mặt nguyên tử không chỉ TSC mà còn là một chỉ báo tương ứng với
số bộ xử lý.  Điều này có thể được sử dụng để lập chỉ mục vào một mảng các biến TSC để
xác định thông tin bù đắp trong hệ thống SMP nơi TSC không được đồng bộ hóa.
Sự hiện diện của hướng dẫn này phải được xác định bằng cách tham khảo tính năng CPUID
bit.

Cả VMX và SVM đều cung cấp các trường mở rộng trong phần cứng ảo hóa.
cho phép TSC hiển thị của khách được bù bằng một hằng số.  Triển khai mới hơn
hứa sẽ cho phép TSC được mở rộng quy mô hơn nữa, nhưng phần cứng này thì không
nhưng vẫn có sẵn rộng rãi.

3.1. Đồng bộ hóa TSC
------------------------

TSC là đồng hồ cục bộ CPU trong hầu hết các triển khai.  Điều này có nghĩa là, trên SMP
nền tảng, TSC của các CPU khác nhau có thể khởi động vào những thời điểm khác nhau tùy theo
bật khi CPU được bật nguồn.  Nói chung, các CPU trên cùng một khuôn sẽ chia sẻ
cùng một chiếc đồng hồ, tuy nhiên, điều này không phải lúc nào cũng đúng.

BIOS có thể cố gắng đồng bộ lại TSC trong quá trình bật nguồn và
hệ điều hành hoặc phần mềm hệ thống khác cũng có thể cố gắng thực hiện việc này.
Một số hạn chế về phần cứng làm cho vấn đề trở nên tồi tệ hơn - nếu không thể
ghi đầy đủ 64-bit của TSC thì có thể không thể so sánh được với TSC trong
CPU mới đến với phần còn lại của hệ thống, dẫn đến
TSC không đồng bộ.  Việc này có thể được thực hiện bằng BIOS hoặc phần mềm hệ thống, nhưng trong
thực hành, việc có được TSC được đồng bộ hóa hoàn hảo sẽ không thể thực hiện được trừ khi tất cả
các giá trị được đọc từ cùng một đồng hồ, điều này thường chỉ có thể thực hiện được trên một
hệ thống ổ cắm hoặc những hệ thống có hỗ trợ phần cứng đặc biệt.

3.2. Phích cắm nóng TSC và CPU
------------------------

Như đã đề cập, CPU đến muộn hơn thời gian khởi động của hệ thống
có thể không có giá trị TSC được đồng bộ hóa với phần còn lại của hệ thống.
Phần mềm hệ thống, mã BIOS hoặc mã SMM thực sự có thể cố gắng thiết lập TSC
đến một giá trị khớp với phần còn lại của hệ thống, nhưng một kết quả khớp hoàn hảo thường không
một sự đảm bảo.  Điều này có thể có tác dụng đưa hệ thống từ trạng thái
Tuy nhiên, TSC được đồng bộ hóa trở lại trạng thái có lỗi đồng bộ hóa TSC
nhỏ, có thể tiếp xúc với hệ điều hành và bất kỳ môi trường ảo hóa nào.

3.3. TSC và nhiều ổ cắm / NUMA
--------------------------------

Hệ thống nhiều ổ cắm, đặc biệt là hệ thống nhiều ổ cắm lớn có thể có
nguồn đồng hồ riêng lẻ thay vì một đồng hồ duy nhất được phân phối trên toàn cầu.
Vì những chiếc đồng hồ này được điều khiển bởi các tinh thể khác nhau nên chúng sẽ không có
tần số hoàn toàn phù hợp, nhiệt độ và sự thay đổi điện sẽ
khiến đồng hồ CPU và do đó TSC bị trôi theo thời gian.  Tùy thuộc vào
thiết kế đồng hồ và bus chính xác, độ lệch có thể được cố định hoặc không một cách tuyệt đối
lỗi và có thể tích lũy theo thời gian.

Ngoài ra, các hệ thống rất lớn có thể cố tình xoay đồng hồ của từng cá nhân
lõi.  Kỹ thuật này, được gọi là xung nhịp trải phổ, làm giảm EMI ở mức
tần số xung nhịp và sóng hài của nó, có thể được yêu cầu vượt qua FCC
tiêu chuẩn cho thiết bị viễn thông và máy tính.

Bạn không nên tin tưởng vào việc TSC vẫn được đồng bộ hóa trên NUMA hoặc
nhiều hệ thống ổ cắm vì những lý do này.

3.4. Trạng thái TSC và C
---------------------

Trạng thái C hoặc trạng thái không hoạt động của bộ xử lý, đặc biệt là C1E và trạng thái ngủ sâu hơn
các trạng thái cũng có thể là vấn đề đối với TSC.  TSC có thể ngừng hoạt động trong trường hợp như vậy
một trạng thái, dẫn đến TSC nằm sau trạng thái của các CPU khác khi thực thi
được nối lại.  Những CPU như vậy phải được hệ điều hành phát hiện và gắn cờ
dựa trên CPU và nhận dạng chipset.

TSC trong trường hợp như vậy có thể được sửa bằng cách kết nối nó với một thiết bị bên ngoài đã biết.
clocksource.

3.5. TSC thay đổi tần số / trạng thái P
------------------------------------

Để làm cho mọi thứ thú vị hơn một chút, một số CPU có thể thay đổi tần số.  Họ
có thể hoặc không thể chạy TSC ở cùng tốc độ và do tần số thay đổi
có thể bị đảo lộn hoặc xoay, tại một số thời điểm, tốc độ TSC có thể không
được biết đến ngoài việc nằm trong một phạm vi giá trị.  Trong trường hợp này, TSC sẽ
không phải là nguồn thời gian ổn định và phải được hiệu chỉnh theo nguồn thời gian đã biết, ổn định,
đồng hồ bên ngoài để trở thành nguồn thời gian có thể sử dụng được.

TSC chạy ở tốc độ không đổi hay tỷ lệ với trạng thái P là mô hình
phụ thuộc và phải được xác định bằng cách kiểm tra CPUID, chipset hoặc nhà cung cấp
các trường MSR cụ thể.

Ngoài ra, một số nhà cung cấp đã biết lỗi trong đó trạng thái P thực sự
được bù thích hợp trong quá trình hoạt động bình thường, nhưng khi bộ xử lý
không hoạt động, trạng thái P có thể được nâng lên tạm thời do thiếu bộ nhớ đệm dịch vụ từ
bộ xử lý khác.  Trong những trường hợp như vậy, TSC trên CPU bị tạm dừng có thể hoạt động nhanh hơn
hơn so với các bộ xử lý không bị dừng.  Bộ xử lý AMD Turion được biết là có
vấn đề này.

3.6. Trạng thái TSC và STPCLK / T
------------------------------

Các tín hiệu bên ngoài được cung cấp cho bộ xử lý cũng có thể có tác dụng dừng
TSC.  Điều này thường được thực hiện để kiểm soát nguồn điện khẩn cấp về nhiệt để ngăn ngừa
tình trạng quá nóng và thông thường không có cách nào để phát hiện ra điều này
tình trạng đã xảy ra.

3.7. Ảo hóa TSC - VMX
-----------------------------

VMX cung cấp bẫy có điều kiện của RDTSC, RDMSR, WRMSR và RDTSCP
hướng dẫn, đủ để ảo hóa hoàn toàn TSC theo bất kỳ cách nào.  trong
Ngoài ra, VMX cho phép đi qua máy chủ TSC cộng thêm TSC_OFFSET bổ sung
trường được chỉ định trong VMCS.  Phải sử dụng các hướng dẫn đặc biệt để đọc và
viết trường VMCS.

3.8. Ảo hóa TSC - SVM
-----------------------------

SVM cung cấp bẫy có điều kiện của RDTSC, RDMSR, WRMSR và RDTSCP
hướng dẫn, đủ để ảo hóa hoàn toàn TSC theo bất kỳ cách nào.  trong
Ngoài ra, SVM cho phép đi qua máy chủ TSC cộng với phần bù bổ sung
trường được chỉ định trong khối điều khiển SVM.

3.9. Các bit tính năng TSC trong Linux
------------------------------

Tóm lại, không có cách nào để đảm bảo TSC vẫn ở trạng thái hoàn hảo
đồng bộ hóa trừ khi nó được đảm bảo rõ ràng bởi kiến trúc.  Thậm chí
nếu vậy, các TSC trong hệ thống nhiều ổ cắm hoặc NUMA vẫn có thể chạy độc lập
mặc dù nhất quán ở địa phương.

Các bit tính năng sau đây được Linux sử dụng để báo hiệu các thuộc tính TSC khác nhau,
nhưng chúng chỉ có thể được coi là có ý nghĩa đối với các hệ thống UP hoặc nút đơn.

=====================================================================
X86_FEATURE_TSC TSC có sẵn trong phần cứng
X86_FEATURE_RDTSCP Lệnh RDTSCP có sẵn
X86_FEATURE_CONSTANT_TSC Tỷ lệ TSC không thay đổi ở trạng thái P
X86_FEATURE_NONSTOP_TSC TSC không dừng ở trạng thái C
Kiểm tra đồng bộ hóa X86_FEATURE_TSC_RELIABLE TSC bị bỏ qua (VMware)
=====================================================================

4. Vấn đề ảo hóa
==========================

Việc chấm công đặc biệt có vấn đề đối với việc ảo hóa vì một số
những thách thức nảy sinh.  Vấn đề rõ ràng nhất là thời gian hiện được chia sẻ giữa
máy chủ và có thể là một số máy ảo.  Như vậy ảo
hệ điều hành không chạy khi sử dụng 100% CPU, mặc dù thực tế là
nó rất có thể đưa ra giả định đó.  Nó có thể mong đợi nó vẫn đúng đến mức rất
giới hạn chính xác khi các nguồn ngắt bị vô hiệu hóa, nhưng trên thực tế chỉ có giới hạn đó
các nguồn ngắt ảo bị vô hiệu hóa và máy vẫn có thể bị ưu tiên
bất cứ lúc nào.  Điều này gây ra các vấn đề như thời gian thực trôi qua, việc tiêm
ngắt máy và các nguồn đồng hồ liên quan không còn hoàn toàn
đồng bộ với thời gian thực.

Vấn đề tương tự này có thể xảy ra trên phần cứng gốc ở một mức độ nào đó, vì chế độ SMM có thể
đánh cắp các chu kỳ tự nhiên trên các hệ thống X86 khi chế độ SMM được sử dụng
BIOS, nhưng không theo kiểu cực đoan như vậy.  Tuy nhiên, thực tế là chế độ SMM có thể
gây ra những vấn đề tương tự như ảo hóa, điều này là lý do chính đáng để biện minh cho
giải quyết nhiều vấn đề này trên kim loại trần.

4.1. Đồng hồ ngắt
-----------------------

Một trong những vấn đề trực tiếp nhất xảy ra với hệ điều hành cũ
là quy trình chấm công của hệ thống thường được thiết kế để theo dõi
thời gian bằng cách đếm các ngắt định kỳ.  Những ngắt này có thể đến từ PIT
hoặc RTC, nhưng vấn đề là như nhau: công cụ ảo hóa máy chủ có thể không
có thể cung cấp số lượng ngắt thích hợp mỗi giây và do đó khách
thời gian có thể tụt lại phía sau.  Điều này đặc biệt có vấn đề nếu tốc độ ngắt cao
được chọn, chẳng hạn như 1000 HZ, không may là mặc định cho nhiều Linux
khách.

Có ba cách tiếp cận để giải quyết vấn đề này; đầu tiên, có thể là có thể
chỉ đơn giản là bỏ qua nó.  Khách có nguồn thời gian riêng để theo dõi
'đồng hồ treo tường' hoặc 'thời gian thực' có thể không cần bất kỳ sự điều chỉnh nào về các ngắt của chúng để
duy trì thời gian thích hợp.  Nếu điều này là không đủ, có thể cần phải tiêm
ngắt bổ sung vào khách để tăng hiệu quả
tốc độ gián đoạn.  Cách tiếp cận này dẫn đến sự phức tạp trong điều kiện khắc nghiệt,
trong đó tải của máy chủ hoặc độ trễ của khách quá lớn để bù đắp, và do đó một vấn đề khác
giải pháp cho vấn đề đã xuất hiện: khách có thể cần nhận thức được sự mất mát
tích tắc và bù đắp cho chúng trong nội bộ.  Mặc dù đầy hứa hẹn về mặt lý thuyết,
việc triển khai chính sách này trong Linux rất dễ xảy ra lỗi và
số lượng biến thể lỗi của việc bù đánh dấu bị mất được phân phối trên
các hệ thống Linux thường được sử dụng.

Windows sử dụng đồng hồ RTC định kỳ như một phương tiện để lưu giữ thời gian bên trong và
do đó yêu cầu quay gián đoạn để giữ thời gian thích hợp.  Nó sử dụng mức đủ thấp
(ed: có phải là 18,2 Hz không?) tuy nhiên nó vẫn chưa phải là vấn đề ở
luyện tập.

4.2. Lấy mẫu và tuần tự hóa TSC
-----------------------------------

Là nguồn thời gian có độ chính xác cao nhất hiện có, bộ đếm chu kỳ của CPU
đã thu hút được nhiều sự quan tâm từ các nhà phát triển.  Như đã giải thích ở trên, bộ đếm thời gian này có
nhiều vấn đề đặc trưng về bản chất của nó như một địa phương, có khả năng không ổn định và
nguồn có khả năng không đồng bộ.  Một vấn đề không chỉ xảy ra với TSC,
nhưng được nhấn mạnh vì tính chất rất chính xác của nó là độ trễ lấy mẫu.  Bởi
định nghĩa, bộ đếm, một khi đã đọc thì đã cũ.  Tuy nhiên, nó cũng
bộ đếm có thể được đọc trước khi sử dụng kết quả thực tế.
Đây là hệ quả của việc thực thi siêu vô hướng của luồng lệnh,
có thể thực hiện các hướng dẫn không theo thứ tự.  Việc thực hiện như vậy được gọi là
không được tuần tự hóa.  Việc buộc thực hiện tuần tự là cần thiết để đảm bảo độ chính xác
đo bằng TSC và yêu cầu lệnh tuần tự hóa, chẳng hạn như CPUID
hoặc đọc MSR.

Vì CPUID thực sự có thể được ảo hóa bằng cơ chế bẫy và mô phỏng, nên điều này
việc tuần tự hóa có thể gây ra vấn đề về hiệu suất cho việc ảo hóa phần cứng.  Một
do đó, việc đọc bộ đếm dấu thời gian chính xác có thể không phải lúc nào cũng có sẵn và
việc triển khai có thể cần thiết để bảo vệ chống lại việc đọc "ngược" của
TSC được nhìn thấy từ các CPU khác, ngay cả trong một môi trường được đồng bộ hóa hoàn hảo
hệ thống.

4.3. Bí danh thời gian
----------------------

Ngoài ra, việc thiếu số sê-ri từ TSC đặt ra một thách thức khác
khi sử dụng kết quả của TSC khi được đo dựa trên nguồn thời gian khác.  Như
TSC có độ chính xác cao hơn nhiều, có thể đọc được nhiều giá trị có thể có của TSC
trong khi một đồng hồ khác vẫn hiển thị cùng một giá trị.

Nghĩa là, bạn có thể đọc (T,T+10) trong khi đồng hồ bên ngoài C vẫn giữ nguyên giá trị.
Do các lần đọc không được tuần tự hóa, bạn thực sự có thể kết thúc với một phạm vi
dao động - từ (T-1.. T+10).  Như vậy, bất cứ lúc nào tính từ một TSC, nhưng
được hiệu chỉnh theo giá trị bên ngoài có thể có một phạm vi giá trị hợp lệ.
Việc hiệu chỉnh lại phép tính này thực sự có thể gây ra thời gian, như được tính sau
hiệu chuẩn, quay ngược lại so với thời gian được tính toán trước đó
hiệu chuẩn.

Vấn đề này đặc biệt rõ ràng với nguồn thời gian nội bộ trong Linux,
thời gian kernel, được thể hiện ở độ phân giải cao về mặt lý thuyết
timespec - nhưng đôi khi tiến bộ trong khoảng thời gian chi tiết lớn hơn nhiều
với tốc độ nhanh chóng và có thể ở chế độ bắt kịp, ở một bước lớn hơn nhiều.

Bí danh này đòi hỏi phải cẩn thận trong việc tính toán và hiệu chỉnh lại kvmclock
và bất kỳ giá trị nào khác bắt nguồn từ tính toán TSC (chẳng hạn như ảo hóa TSC
chính nó).

4.4. Di chuyển
--------------

Việc di chuyển máy ảo gây ra vấn đề về chấm công theo hai cách.
Đầu tiên, quá trình di chuyển có thể mất thời gian, trong thời gian đó không thể thực hiện được các ngắt.
được giao và sau đó, thời gian của khách có thể cần phải được đáp ứng.  NTP có thể
có thể giúp đỡ ở một mức độ nào đó vì việc điều chỉnh đồng hồ cần thiết là
thường đủ nhỏ để rơi vào cửa sổ có thể sửa được NTP.

Một mối quan tâm nữa là các bộ định thời dựa trên TSC (hoặc HPET, nếu bus thô
đồng hồ bị hở) hiện có thể đang chạy ở các tốc độ khác nhau, cần phải bù
theo một cách nào đó trong bộ ảo hóa bằng cách ảo hóa các bộ tính giờ này.  Ngoài ra,
việc di chuyển sang máy nhanh hơn có thể ngăn cản việc sử dụng TSC chuyển tiếp, như một
đồng hồ nhanh hơn không thể được hiển thị cho khách nếu không có tiềm năng về thời gian
tiến bộ nhanh hơn bình thường.  Đồng hồ chậm hơn ít gây ra vấn đề hơn vì nó có thể
luôn được bắt kịp với tỷ giá ban đầu.  Đồng hồ KVM tránh được những vấn đề này bằng cách
chỉ cần lưu trữ số nhân và độ lệch so với TSC để khách chuyển đổi
trở lại giá trị độ phân giải nano giây.

4.5. Lên lịch
---------------

Vì việc lập lịch có thể dựa trên thời gian chính xác và việc kích hoạt các ngắt, nên
Các thuật toán lập lịch của một hệ điều hành có thể bị ảnh hưởng bất lợi bởi
ảo hóa.  Về lý thuyết, hiệu ứng này là ngẫu nhiên và phải phổ biến
được phân phối, nhưng trong các tình huống giả định cũng như thực tế (truy cập thiết bị khách,
nguyên nhân dẫn đến thoát ảo hóa, chuyển đổi ngữ cảnh có thể xảy ra), điều này có thể không phải lúc nào cũng
cứ như vậy đi.  Tác dụng của việc này chưa được nghiên cứu kỹ.

Trong nỗ lực giải quyết vấn đề này, một số triển khai đã cung cấp một
đồng hồ lập lịch ảo hóa song song, cho thấy lượng thời gian thực sự của CPU cho
mà một máy ảo đang chạy.

4.6. Cơ quan giám sát
--------------

Bộ tính giờ của cơ quan giám sát, chẳng hạn như bộ phát hiện khóa trong Linux có thể vô tình kích hoạt khi
chạy dưới sự ảo hóa phần cứng do ngắt hẹn giờ bị trì hoãn hoặc
giải thích sai về sự trôi qua của thời gian thực.  Thông thường, những cảnh báo này được
giả mạo và có thể bị bỏ qua, nhưng trong một số trường hợp có thể cần phải
vô hiệu hóa phát hiện như vậy.

4.7. Độ trễ và thời gian chính xác
--------------------------------

Thời gian chính xác và độ trễ có thể không thực hiện được trong hệ thống ảo hóa.  Cái này
có thể xảy ra nếu hệ thống đang điều khiển phần cứng vật lý hoặc gây ra sự chậm trễ cho
bù đắp cho việc I/O đến và đi từ các thiết bị chậm hơn.  Vấn đề đầu tiên không thể giải quyết được
nói chung đối với một hệ thống ảo hóa; phần mềm điều khiển phần cứng không thể
được ảo hóa đầy đủ mà không cần có hệ điều hành thời gian thực đầy đủ, điều này sẽ
yêu cầu một nền tảng ảo hóa nhận biết RT.

Vấn đề thứ hai có thể gây ra vấn đề về hiệu suất, nhưng đây không phải là vấn đề
vấn đề quan trọng.  Trong nhiều trường hợp, sự chậm trễ này có thể được loại bỏ thông qua
cấu hình hoặc ảo hóa.

4.8. Các kênh bí mật và rò rỉ
------------------------------

Ngoài những vấn đề trên, thông tin về thời gian chắc chắn sẽ bị rò rỉ ra ngoài.
khách về máy chủ trong bất cứ điều gì ngoại trừ việc triển khai ảo hóa hoàn hảo
thời gian.  Điều này có thể cho phép khách suy ra sự hiện diện của một trình ảo hóa (như trong một
phát hiện loại thuốc đỏ) và nó có thể cho phép thông tin rò rỉ giữa các khách
bằng cách sử dụng chính CPU làm kênh báo hiệu.  Ngăn chặn như vậy
các vấn đề sẽ yêu cầu thời gian ảo bị cô lập hoàn toàn và có thể không theo dõi được
thời gian thực nữa.  Điều này có thể hữu ích trong một số bối cảnh bảo mật hoặc QA nhất định,
nhưng nói chung không được khuyến nghị cho các tình huống triển khai trong thế giới thực.