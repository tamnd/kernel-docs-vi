.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/ixp4xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Ghi chú phát hành cho Linux trên Bộ xử lý mạng IXP4xx của Intel
================================================================

Được duy trì bởi Deepak Saxena <dsaxena@plexity.net>
-------------------------------------------------------------------------

1. Tổng quan

Bộ xử lý mạng IXP4xx của Intel là SOC tích hợp cao,
được nhắm mục tiêu cho các ứng dụng mạng, mặc dù nó đã trở nên phổ biến
trong điều khiển công nghiệp và các lĩnh vực khác do chi phí và điện năng thấp
tiêu thụ. Họ IXP4xx hiện nay bao gồm một số bộ xử lý
hỗ trợ các chức năng giảm tải mạng khác nhau như mã hóa,
định tuyến, tường lửa, v.v. Dòng IXP46x là phiên bản cập nhật
hỗ trợ tốc độ nhanh hơn, bộ nhớ mới và cấu hình flash, v.v.
tích hợp như bộ điều khiển I2C trên chip.

Để biết thêm thông tin về các phiên bản khác nhau của CPU, hãy xem:

ZZ0000ZZ

Intel cũng đã sản xuất IXCP1100 CPU đôi khi là IXP4xx
bị tước bỏ phần lớn thông tin mạng.

2. Hỗ trợ Linux

Linux hiện hỗ trợ các tính năng sau trên chip IXP4xx:

- Cổng nối tiếp kép
- Giao diện PCI
- Truy cập flash (MTD/JFFS)
- I2C đến GPIO trên IXP42x
- GPIO cho đầu vào/đầu ra/ngắt
  Xem Arch/arm/mach-ixp4xx/include/mach/platform.h để biết các chức năng truy cập.
- Bộ hẹn giờ (cơ quan giám sát, hệ điều hành)

Các thành phần sau của chip không được Linux hỗ trợ và
yêu cầu sử dụng phần mềm CSR độc quyền của Intel:

- Giao diện thiết bị USB
- Giao diện mạng (HSS, Utopia, NPE, v.v.)
- Chức năng giảm tải mạng

Nếu bạn cần sử dụng bất kỳ thứ nào ở trên, bạn cần tải xuống Intel
phần mềm từ:

ZZ0000ZZ

LÀM NOT POST QUESTIONS ĐẾN THE LINUX MAILING LISTS REGARDING THE PROPRIETARY
SOFTWARE.

Có một số trang web cung cấp hướng dẫn/gợi ý về cách sử dụng
Phần mềm của Intel:

-ZZ0000ZZ
     Hướng dẫn sử dụng uClinux và thư viện Intel dành cho nhà phát triển nguồn mở

-ZZ0000ZZ
     Tóm tắt một trang đơn giản về cách xây dựng cổng bằng IXP425 và Linux

-ZZ0000ZZ
     Trình điều khiển thiết bị ATM dành cho IXP425 dựa trên thư viện của Intel

3. Các vấn đề/Hạn chế đã biết

3a. Cửa sổ PCI gửi đến có giới hạn

Họ IXP4xx cho phép bộ nhớ lên tới 256 MB nhưng giao diện PCI
chỉ có thể hiển thị 64 MB bộ nhớ đó cho bus PCI. Điều này có nghĩa là nếu
bạn đang chạy với > 64MB, tất cả các bộ đệm PCI nằm ngoài vùng có thể truy cập được
phạm vi sẽ bị trả lại bằng cách sử dụng các quy trình trong Arch/arm/common/dmabounce.c.

3b. Cửa sổ PCI gửi đi có giới hạn

IXP4xx cung cấp hai phương thức truy cập không gian bộ nhớ PCI:

1) Cửa sổ được ánh xạ trực tiếp từ 0x48000000 đến 0x4bffffff (64MB).
   Để truy cập PCI qua không gian này, chúng ta chỉ cần ioremap() BAR
   vào kernel và chúng ta có thể sử dụng read[bwl]/write[bwl] tiêu chuẩn
   macro. Đây là phương pháp được ưa thích do tốc độ nhưng nó
   giới hạn hệ thống chỉ ở mức 64 MB bộ nhớ PCI. Đây có thể là
   có vấn đề nếu sử dụng card màn hình và các thiết bị nặng bộ nhớ khác.

2) If > 64MB of memory space is required, the IXP4xx can be
   được cấu hình để sử dụng các thanh ghi gián tiếp để truy cập PCI Điều này cho phép
   cho bộ nhớ lên tới 128 MB (0x48000000 đến 0x4fffffff) trên xe buýt.
   Nhược điểm của việc này là mọi truy cập PCI đều yêu cầu
   ba quyền truy cập đăng ký cục bộ cộng với một spinlock, nhưng trong một số
   trường hợp hiệu suất đạt được là chấp nhận được. Ngoài ra, bạn không thể
   mmap() Các thiết bị PCI trong trường hợp này do tính chất gián tiếp
   của cửa sổ PCI.

Theo mặc định, phương pháp trực tiếp được sử dụng vì lý do hiệu suất. Nếu
bạn cần thêm bộ nhớ PCI, hãy bật tùy chọn cấu hình IXP4XX_INDIRECT_PCI.

3c. GPIO làm ngắt

Hiện tại mã chỉ xử lý các ngắt GPIO theo mức độ

4. Nền tảng được hỗ trợ

Nền tảng tham chiếu cổng Coyote kỹ thuật ADI
ZZ0000ZZ

Nền tảng ADI Coyote là thiết kế tham khảo cho những tòa nhà đó
   cổng khu dân cư / văn phòng nhỏ. Một NPE được kết nối với 10/100
   giao diện, một đến 4 cổng chuyển đổi 10/100 và cổng thứ ba đến và ADSL
   giao diện. Ngoài ra, nó còn hỗ trợ các giao diện POT được kết nối
   thông qua SLIC. Lưu ý rằng những thứ đó không được Linux ATM hỗ trợ. Cuối cùng,
   nền tảng này có hai khe cắm mini-PCI được sử dụng cho thẻ 802.11[bga].
   Cuối cùng, có một cổng IDE treo trên bus mở rộng.

Nền tảng mạng Gateworks Avila
ZZ0000ZZ

Nền tảng Avila về cơ bản là IXDP425 với 4 khe PCI
   được thay thế bằng các khe cắm mini-PCI và giao diện CF IDE bị treo
   xe buýt mở rộng.

Nền tảng phát triển Intel IXDP425
ZZ0000ZZ

Đây là nền tảng tham chiếu tiêu chuẩn của Intel dành cho IXDP425 và được
   còn được gọi là bảng Richfield. Nó chứa 4 khe PCI, 16MB
   flash, hai cổng 10/100 và một cổng ADSL.

Nền tảng phát triển Intel IXDP465
ZZ0000ZZ

Về cơ bản, đây là một chiếc IXDP425 với IXP465 và 32M đèn flash
   chỉ mới 16.

Nền tảng phát triển Intel IXDPG425

Về cơ bản, đây là bo mạch ADI Coyote với bộ điều khiển NEC EHCI
   đã thêm vào. Một vấn đề với bo mạch này là chỉ có các khe cắm mini-PCI
   đã kết nối đường dây 3,3v, vì vậy bạn không thể sử dụng PCI cho mini-PCI
   bộ chuyển đổi với thẻ E100. Vì vậy, để root NFS, bạn cần sử dụng một trong hai
   CSR hoặc thẻ WiFi và đĩa RAM khởi động BOOTP và sau đó thực hiện
   một Pivot_root tới NFS.

Thẻ Mezanine Bộ xử lý Motorola PrPMC1100
ZZ0000ZZ

PrPMC1100 dựa trên IXCP1100 và được thiết kế để cắm vào
   và hệ thống IXP2400/2800 hoạt động như bộ điều khiển hệ thống. Nó đơn giản
   chứa CPU và 16MB flash trên bo mạch và cần phải được
   cắm vào board vận chuyển để hoạt động. Hiện tại chỉ có Linux
   hỗ trợ bo mạch vận chuyển Motorola PrPMC cho nền tảng này.

5. TODO LIST

- Thêm hỗ trợ cho Coyote IDE
- Thêm hỗ trợ cho các ngắt GPIO dựa trên cạnh
- Thêm hỗ trợ cho CF IDE trên bus mở rộng

6. Cảm ơn

Công trình IXP4xx được Intel Corp. và MontaVista Software, Inc. tài trợ.

Những người sau đây đã đóng góp các bản vá/bình luận/v.v.:

- Lennerty Buytenhek
- Lutz Jaenicke
- Justin Mayfield
- Robert E. Ranslam

[Tôi biết mình đã quên người khác, vui lòng gửi email cho tôi để được bổ sung]

-------------------------------------------------------------------------

Cập nhật lần cuối: 04/01/2005
