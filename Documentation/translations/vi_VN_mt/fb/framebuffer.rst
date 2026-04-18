.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/framebuffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Thiết bị đệm khung
==========================

Sửa đổi lần cuối: ngày 10 tháng 5 năm 2001


0. Giới thiệu
---------------

Thiết bị đệm khung cung cấp sự trừu tượng hóa cho phần cứng đồ họa. Nó
đại diện cho bộ đệm khung của một số phần cứng video và cho phép ứng dụng
phần mềm để truy cập phần cứng đồ họa thông qua một giao diện được xác định rõ ràng, do đó
phần mềm không cần biết gì về cấp độ thấp (phần cứng
đăng ký) công cụ.

Thiết bị được truy cập thông qua các nút thiết bị đặc biệt, thường nằm trong
thư mục /dev, tức là /dev/fb*.


1. Góc nhìn của người dùng về /dev/fb*
--------------------------------------

Theo quan điểm của người dùng, thiết bị đệm khung trông giống như bất kỳ
thiết bị khác trong/dev. Đó là một thiết bị ký tự sử dụng 29 chính; trẻ vị thành niên
chỉ định số bộ đệm khung.

Theo quy ước, các nút thiết bị sau được sử dụng (các con số cho biết thiết bị
số thứ yếu)::

0 = /dev/fb0 Bộ đệm khung đầu tiên
      1 = /dev/fb1 Bộ đệm khung thứ hai
	  ...
     31 = /dev/fb31	32nd frame buffer

Để tương thích ngược, bạn có thể muốn tạo ký hiệu sau
liên kết::

/dev/fb0current -> fb0
    /dev/fb1current -> fb1

và vân vân...

Các thiết bị đệm khung cũng là thiết bị bộ nhớ ZZ0000ZZ, điều này có nghĩa là bạn có thể
đọc và viết nội dung của chúng. Ví dụ: bạn có thể tạo ảnh chụp màn hình bằng cách::

cp /dev/fb0 tập tin của tôi

Cũng có thể có nhiều bộ đệm khung cùng một lúc, ví dụ: nếu bạn có một
card đồ họa ngoài phần cứng tích hợp. Khung tương ứng
các thiết bị đệm (/dev/fb0 và /dev/fb1, v.v.) hoạt động độc lập.

Phần mềm ứng dụng sử dụng thiết bị đệm khung (ví dụ: máy chủ X) sẽ
sử dụng /dev/fb0 theo mặc định (phần mềm cũ hơn sử dụng /dev/fb0current). Bạn có thể chỉ định
một thiết bị đệm khung thay thế bằng cách đặt biến môi trường
$FRAMEBUFFER vào tên đường dẫn của thiết bị đệm khung, ví dụ: (đối với sh/bash
người dùng)::

xuất FRAMEBUFFER=/dev/fb1

hoặc (đối với người dùng csh)::

setenv FRAMEBUFFER /dev/fb1

Sau đó, máy chủ X sẽ sử dụng bộ đệm khung thứ hai.


2. Quan điểm của lập trình viên về /dev/fb*
-------------------------------------------

Như bạn đã biết, thiết bị đệm khung là một thiết bị bộ nhớ như /dev/mem và
nó có các tính năng tương tự. Bạn có thể đọc nó, viết nó, tìm kiếm một vị trí nào đó trong
it và mmap() nó (cách sử dụng chính). Sự khác biệt chỉ là trí nhớ
xuất hiện trong tệp đặc biệt không phải là toàn bộ bộ nhớ mà là bộ đệm khung của
một số phần cứng video.

/dev/fb* cũng cho phép một số ioctls trên đó, qua đó có rất nhiều thông tin về
phần cứng có thể được truy vấn và thiết lập. Việc xử lý bản đồ màu hoạt động thông qua ioctls,
quá. Hãy xem <linux/fb.h> để biết thêm thông tin về những gì ioctls tồn tại và trên đó
cấu trúc dữ liệu nào chúng hoạt động. Đây chỉ là một tổng quan ngắn gọn:

- Bạn có thể yêu cầu thông tin không thể thay đổi về phần cứng, như tên,
    tổ chức bộ nhớ màn hình (mặt phẳng, pixel đóng gói, ...) và địa chỉ
    và độ dài của bộ nhớ màn hình.

- Bạn có thể yêu cầu và thay đổi thông tin khác nhau về phần cứng, như
    hình học hiển thị và ảo, độ sâu, định dạng bản đồ màu, thời gian, v.v.
    Nếu bạn cố gắng thay đổi thông tin đó, trình điều khiển có thể sẽ làm tròn một số
    các giá trị để đáp ứng khả năng của phần cứng (hoặc trả về EINVAL nếu không
    có thể).

- Bạn có thể lấy và thiết lập các phần của bản đồ màu. Giao tiếp được thực hiện với 16
    bit cho mỗi phần màu (đỏ, lục, lam, trong suốt) để hỗ trợ tất cả
    phần cứng hiện có. Người lái xe thực hiện tất cả các tính toán cần thiết để áp dụng
    nó vào phần cứng (làm tròn nó thành ít bit hơn, có thể vứt đi
    minh bạch).

Tất cả sự trừu tượng hóa phần cứng này làm cho việc thực hiện các chương trình ứng dụng
dễ dàng hơn và di động hơn. Ví dụ. máy chủ X hoạt động hoàn toàn trên /dev/fb* và
do đó không cần phải biết, ví dụ, cách đăng ký màu sắc của bê tông
phần cứng được tổ chức. XF68_FBDev là máy chủ X chung dành cho ánh xạ bit,
phần cứng video không được tăng tốc. Điều duy nhất cần được xây dựng
chương trình ứng dụng là tổ chức màn hình (bitplanes hoặc chunky pixels
v.v.), vì nó hoạt động trực tiếp trên dữ liệu hình ảnh bộ đệm khung.

Trong tương lai, người ta dự kiến sẽ cung cấp các trình điều khiển bộ đệm khung cho card đồ họa và
tương tự có thể được triển khai dưới dạng mô-đun hạt nhân được tải khi chạy. Như vậy
trình điều khiển chỉ cần gọi register_framebuffer() và cung cấp một số chức năng.
Việc viết và phân phối các trình điều khiển như vậy một cách độc lập với kernel sẽ tiết kiệm được
nhiều rắc rối...


3. Bảo trì độ phân giải bộ đệm khung
--------------------------------------

Độ phân giải bộ đệm khung được duy trì bằng tiện ích ZZ0000ZZ. Nó có thể
thay đổi thuộc tính chế độ video của thiết bị đệm khung. Công dụng chính của nó là
để thay đổi chế độ video hiện tại, ví dụ: trong quá trình khởi động trên một trong các ZZ0001ZZ của bạn
hoặc các tệp ZZ0002ZZ.

Fbset sử dụng cơ sở dữ liệu chế độ video được lưu trữ trong tệp cấu hình, vì vậy bạn có thể
dễ dàng thêm các chế độ của riêng bạn và tham khảo chúng bằng một mã định danh đơn giản.


4. Máy chủ X
---------------

Máy chủ X (XF68_FBDev) là chương trình ứng dụng đáng chú ý nhất cho khung
thiết bị đệm. Bắt đầu với bản phát hành XFree86 3.2, máy chủ X là một phần của
XFree86 và có 2 chế độ:

- Nếu có phần con ZZ0000ZZ cho driver ZZ0001ZZ trong /etc/XF86Config
    tập tin chứa::

Chế độ "mặc định"

dòng, máy chủ X sẽ sử dụng sơ đồ được thảo luận ở trên, tức là nó sẽ bắt đầu
    lên ở độ phân giải được xác định bởi /dev/fb0 (hoặc $FRAMEBUFFER, nếu được đặt). bạn
    vẫn phải xác định độ sâu màu (sử dụng từ khóa Depth) và ảo
    độ phân giải (sử dụng từ khóa Virtual). Đây là mặc định cho
    tệp cấu hình được cung cấp cùng với XFree86. Đó là điều đơn giản nhất
    cấu hình nhưng nó có một số hạn chế.

- Vì vậy, cũng có thể chỉ định độ phân giải trong /etc/XF86Config
    tập tin. Điều này cho phép chuyển đổi độ phân giải nhanh chóng trong khi vẫn giữ nguyên
    cùng kích thước máy tính để bàn ảo. Thiết bị đệm khung được sử dụng vẫn
    /dev/fb0current (hoặc $FRAMEBUFFER), nhưng độ phân giải khả dụng là
    được xác định bởi /etc/XF86Config ngay bây giờ. Điều bất lợi là bạn phải
    chỉ định thời gian ở định dạng khác (nhưng ZZ0000ZZ có thể trợ giúp).

Để điều chỉnh chế độ video, bạn có thể sử dụng fbset hoặc xvidtune. Lưu ý rằng xvidtune không
hoạt động 100% với XF68_FBDev: giá trị đồng hồ được báo cáo luôn không chính xác.


5. Thời gian của chế độ video
-----------------------------

Một màn hình vẽ một hình ảnh lên màn hình bằng cách sử dụng chùm tia điện tử (3 electron
chùm tia cho mô hình màu, 1 chùm tia điện tử cho màn hình đơn sắc). Mặt trước của
màn hình được bao phủ bởi một mẫu phốt pho màu (pixel). Nếu là chất lân quang
bị một electron va vào, nó phát ra một photon và do đó trở nên nhìn thấy được.

Chùm tia điện tử vẽ các đường ngang (đường quét) từ trái sang phải và
từ trên xuống dưới màn hình. Bằng cách thay đổi cường độ của
chùm tia điện tử, các pixel với nhiều màu sắc và cường độ khác nhau có thể được hiển thị.

Sau mỗi lần quét, chùm electron phải di chuyển trở lại phía bên trái của
màn hình và đến dòng tiếp theo: đây được gọi là đường hồi quy ngang. Sau khi
toàn bộ màn hình (khung) đã được sơn, chùm tia di chuyển trở lại góc trên bên trái:
đây được gọi là đường hồi phục theo chiều dọc. Trong cả chiều ngang và chiều dọc
hồi tưởng, chùm tia điện tử bị tắt (để trống).

Tốc độ chùm tia điện tử vẽ các điểm ảnh được xác định bởi
dotclock trong bo mạch đồ họa. Đối với một đồng hồ chấm của ví dụ. 28,37516 MHz (hàng triệu
chu kỳ mỗi giây), mỗi pixel dài 35242 ps (pico giây)::

1/(28,37516E6 Hz) = 35,242E-9 giây

Nếu độ phân giải màn hình là 640x480 thì sẽ::

640*35.242E-9 giây = 22.555E-6 giây

để vẽ các pixel 640 (xres) trên một đường quét. Nhưng đường hồi quy theo chiều ngang
cũng mất thời gian (ví dụ: 272 ZZ0000ZZ), do đó, một dòng quét đầy đủ sẽ::

(640+272)*35.242E-9 giây = 32.141E-6 giây

Chúng tôi sẽ nói rằng tốc độ quét ngang là khoảng 31 kHz ::

1/(32,141E-6 giây) = 31,113E3 Hz

Toàn màn hình đếm được 480 (yres) dòng, nhưng chúng ta phải xem xét chiều dọc
cũng truy xuất lại (ví dụ: 49 ZZ0000ZZ). Vì vậy, toàn màn hình sẽ có::

(480+49)*32.141E-6 giây = 17.002E-3 giây

Tốc độ quét dọc là khoảng 59 Hz::

1/(17,002E-3 giây) = 58,815 Hz

Điều này có nghĩa là dữ liệu màn hình được làm mới khoảng 59 lần mỗi giây. Để có một
hình ảnh ổn định mà không bị nhấp nháy, VESA khuyến nghị tốc độ quét dọc là
ít nhất 72 Hz. Nhưng hiện tượng nhấp nháy được cảm nhận phụ thuộc rất nhiều vào con người: một số người
có thể sử dụng 50 Hz mà không gặp bất kỳ sự cố nào, trong khi tôi sẽ chú ý nếu nó nhỏ hơn 80 Hz.

Vì màn hình không biết khi nào một đường quét mới bắt đầu, bo mạch đồ họa
sẽ cung cấp xung đồng bộ hóa (đồng bộ ngang hoặc hsync) cho mỗi
scanline.  Tương tự, nó cung cấp xung đồng bộ hóa (đồng bộ dọc hoặc
vsync) cho mỗi khung hình mới. Vị trí của ảnh trên màn là
bị ảnh hưởng bởi thời điểm xảy ra xung đồng bộ.

Hình ảnh sau đây tóm tắt tất cả các thời gian. Thời gian truy hồi theo chiều ngang là
tổng của lề trái, lề phải và độ dài hsync, trong khi
thời gian truy xuất theo chiều dọc là tổng của lề trên, lề dưới và
độ dài vsync::

+----------+----------------------------------------------------------+----------+-------+
  ZZ0000ZZ ↑ ZZ0001ZZ |
  ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ
  ZZ0005ZZ ↓ ZZ0006ZZ |
  +----------##################################################----------+-------+
  ZZ0007ZZ |
  ZZ0008ZZ #          ZZ0067ZZ
  ZZ0010ZZ #          ZZ0069ZZ
  ZZ0012ZZ #          ZZ0071ZZ
  ZZ0014ZZ #  right ZZ0015ZZ
  ZZ0016ZZ xres #  margin ZZ0017ZZ
  ZZ0018ZZ<----->|
  ZZ0019ZZ #          ZZ0078ZZ
  ZZ0021ZZ #          ZZ0080ZZ
  ZZ0023ZZ #          ZZ0082ZZ
  |          #                |yres #          ZZ0083ZZ
  ZZ0027ZZ #          ZZ0085ZZ
  ZZ0029ZZ #          ZZ0087ZZ
  ZZ0031ZZ #          ZZ0089ZZ
  ZZ0033ZZ #          ZZ0091ZZ
  ZZ0035ZZ #          ZZ0093ZZ
  ZZ0037ZZ #          ZZ0095ZZ
  ZZ0039ZZ #          ZZ0097ZZ
  ZZ0041ZZ #          ZZ0099ZZ
  ZZ0043ZZ |
  +----------##################################################----------+-------+
  ZZ0044ZZ ↑ ZZ0045ZZ |
  ZZ0046ZZ ZZ0047ZZ ZZ0048ZZ
  ZZ0049ZZ ↓ ZZ0050ZZ |
  +----------+----------------------------------------------------------+----------+-------+
  ZZ0051ZZ ↑ ZZ0052ZZ |
  ZZ0053ZZ ZZ0054ZZ ZZ0055ZZ
  ZZ0056ZZ ↓ ZZ0057ZZ |
  +----------+----------------------------------------------------------+----------+-------+

Thiết bị đệm khung mong đợi tất cả thời gian theo chiều ngang theo số chấm
(tính bằng pico giây, 1E-12 giây) và thời gian dọc theo số dòng quét.


6. Chuyển đổi thời gian của thiết bị đệm khung thông tin giá trị thời gian XFree86
----------------------------------------------------------------------------------

Một dòng chế độ XFree86 bao gồm các trường sau::

"800x600" 50 800 856 976 1040 600 637 643 666
 < tên > DCF HR SH1 SH2 HFL VR SV1 SV2 VFL

Thiết bị đệm khung sử dụng các trường sau:

- pixclock: đồng hồ pixel tính bằng ps (pico giây)
  - left_margin: thời gian từ lúc đồng bộ đến hình ảnh
  - right_margin: thời gian từ ảnh đến khi đồng bộ
  - Upper_margin: thời gian từ lúc đồng bộ đến hình ảnh
  - low_margin: thời gian từ ảnh đến khi đồng bộ
  - hsync_len: độ dài đồng bộ ngang
  - vsync_len: độ dài đồng bộ dọc

1) Đồng hồ pixel:

xfree: tính bằng MHz

fb: tính bằng pico giây (ps)

đồng hồ điểm ảnh = 1000000 / DCF

2) thời gian theo chiều ngang:

lề_trái = HFL - SH2

lề phải = SH1 - HR

hsync_len = SH2 - SH1

3) thời gian theo chiều dọc:

lề_trên = VFL - SV2

lề_dưới = SV1 - VR

vsync_len = SV2 - SV1

Có thể tìm thấy các ví dụ hay về thời gian VESA trong cây nguồn XFree86,
trong "xc/programs/Xserver/hw/xfree86/doc/modeDB.txt".


7. Tài liệu tham khảo
---------------------

Để biết thêm thông tin cụ thể về thiết bị đệm khung và
các ứng dụng, vui lòng tham khảo trang web Linux-fbdev:

ZZ0000ZZ

và các tài liệu sau:

- Các trang hướng dẫn sử dụng fbset: fbset(8), fb.modes(5)
  - Các trang hướng dẫn sử dụng XFree86: XF68_FBDev(1), XF86Config(4/5)
  - Nguồn kernel hùng mạnh:

- linux/trình điều khiển/video/
      - linux/include/linux/fb.h
      - linux/bao gồm/video/



8. Danh sách gửi thư
--------------------

Có một danh sách gửi thư liên quan đến thiết bị đệm khung tại kernel.org:
linux-fbdev@vger.kernel.org.

Trỏ trình duyệt web của bạn tới ZZ0000ZZ để
thông tin đăng ký và duyệt lưu trữ.


9. Đang tải xuống
-----------------

Tất cả các tập tin cần thiết có thể được tìm thấy tại

ftp://ftp.uni-erlangen.de/pub/Linux/LOCAL/680x0/

và trên những tấm gương của nó.

Phiên bản mới nhất của fbset có thể được tìm thấy tại

ZZ0000ZZ


10. Tín dụng
------------

Bài đọc này được viết bởi Geert Uytterhoeven, một phần dựa trên bản gốc
ZZ0000ZZ của Roman Hodek và Martin Schaller. Phần 6 là
được cung cấp bởi Frank Neumann.

Sự trừu tượng hóa thiết bị đệm khung được thiết kế bởi Martin Schaller.
