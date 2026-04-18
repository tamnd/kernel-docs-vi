.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/hd-audio/notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Lưu ý thêm về Driver HD-Audio
================================

Takashi Iwai <tiwai@suse.de>


Tổng quan
=========

Âm thanh HD là thành phần âm thanh tích hợp tiêu chuẩn mới trên PC hiện đại
sau AC97.  Mặc dù Linux đã hỗ trợ âm thanh HD từ lâu
thời gian trước, thường có vấn đề với máy mới.  Một phần của
vấn đề BIOS bị hỏng và phần còn lại là việc triển khai trình điều khiển.
Tài liệu này giải thích cách khắc phục sự cố và gỡ lỗi ngắn gọn
phương pháp dành cho phần cứng âm thanh HD.

Thành phần âm thanh HD bao gồm hai phần: chip điều khiển và
các chip codec trên bus âm thanh HD.  Linux cung cấp một trình điều khiển duy nhất
cho tất cả các bộ điều khiển, snd-hda-intel.  Mặc dù tên trình điều khiển có chứa
một từ của một nhà cung cấp phần cứng nổi tiếng, nó không dành riêng cho nó nhưng dành cho
tất cả các chip điều khiển của các công ty khác.  Vì âm thanh HD
bộ điều khiển được cho là tương thích, trình điều khiển snd-hda duy nhất
nên hoạt động trong hầu hết các trường hợp.  Nhưng không có gì ngạc nhiên khi có người biết
lỗi và sự cố cụ thể cho từng loại bộ điều khiển.  snd-hda-intel
driver có rất nhiều cách giải quyết cho những vấn đề này như được mô tả bên dưới.

Một bộ điều khiển có thể có nhiều codec.  Thông thường bạn có một âm thanh
codec và tùy chọn một codec modem.  Về lý thuyết, có thể có
nhiều codec âm thanh, ví dụ: cho đầu ra analog và kỹ thuật số, và
trình điều khiển có thể không hoạt động đúng do xung đột giữa các thành phần của bộ trộn.
Điều này sẽ được khắc phục trong tương lai nếu phần cứng đó thực sự tồn tại.

Trình điều khiển snd-hda-intel có một số trình phân tích cú pháp codec khác nhau tùy thuộc vào
trên bộ giải mã.  Nó có một trình phân tích cú pháp chung làm dự phòng, nhưng cái này
chức năng còn khá hạn chế cho đến bây giờ.  Thay vì chung chung
trình phân tích cú pháp, thường sử dụng trình phân tích cú pháp dành riêng cho codec (được mã hóa trong patch_*.c)
cho việc triển khai codec cụ thể.  Các chi tiết về
các vấn đề cụ thể về codec sẽ được giải thích trong các phần sau.

Nếu bạn quan tâm đến việc gỡ lỗi sâu cho âm thanh HD, hãy đọc phần
Thông số kỹ thuật âm thanh HD lúc đầu.  Thông số kỹ thuật được tìm thấy trên
Trang web của Intel, ví dụ:

* ZZ0000ZZ


Bộ điều khiển âm thanh HD
=========================

Vấn đề về vị trí DMA
--------------------
Vấn đề phổ biến nhất của bộ điều khiển là DMA không chính xác
báo cáo con trỏ.  Con trỏ DMA để phát lại và chụp có thể
đọc theo hai cách, thông qua thanh ghi LPIB hoặc qua bộ đệm vị trí
bản đồ.  Theo mặc định, trình điều khiển cố đọc từ bản đồ io
bộ đệm vị trí và quay trở lại LPIB nếu bộ đệm vị trí xuất hiện
đã chết.  Tuy nhiên, tính năng phát hiện này không hoàn hảo trên một số thiết bị.  Trong đó
trong trường hợp này, bạn có thể thay đổi phương thức mặc định thông qua tùy chọn ZZ0000ZZ.

ZZ0000ZZ có nghĩa là sử dụng phương pháp LPIB một cách rõ ràng.
ZZ0001ZZ có nghĩa là sử dụng bộ đệm vị trí.
ZZ0002ZZ có nghĩa là sử dụng kết hợp cả hai phương pháp, cần thiết
đối với một số bộ điều khiển VIA.  Vị trí luồng chụp đã được sửa
bằng cách so sánh cả giá trị LPIB và bộ đệm vị trí.
ZZ0003ZZ là một sự kết hợp khác dành cho tất cả các bộ điều khiển,
và sử dụng LPIB để phát lại và bộ đệm vị trí để chụp
suối.
Cho đến nay, ZZ0004ZZ dành riêng cho nền tảng Intel dành cho Skylake
và trở đi.  Nó áp dụng tính toán độ trễ cho vị trí chính xác
báo cáo.
ZZ0005ZZ là sửa vị trí bằng FIFO cố định
kích thước, chủ yếu nhắm mục tiêu cho bộ điều khiển AMD gần đây.
0 là giá trị mặc định cho tất cả các
bộ điều khiển, việc kiểm tra tự động và dự phòng cho LPIB như được mô tả trong
ở trên.  Nếu bạn gặp vấn đề về âm thanh lặp lại, tùy chọn này có thể
giúp đỡ.

Thêm vào đó, mọi bộ điều khiển đều được biết là bị hỏng liên quan đến
thời điểm thức dậy.  Nó thức dậy một vài mẫu trước khi thực sự
xử lý dữ liệu trên bộ đệm.  Điều này gây ra rất nhiều vấn đề, vì
ví dụ: với ALSA dmix hoặc JACK.  Kể từ kernel 2.6.27, trình điều khiển đặt
một sự chậm trễ nhân tạo đối với thời gian đánh thức.  Độ trễ này được kiểm soát
thông qua tùy chọn ZZ0000ZZ.

Khi ZZ0000ZZ là giá trị âm (theo mặc định), nó được gán cho
một giá trị thích hợp tùy thuộc vào chip điều khiển.  Dành cho Intel
chip, nó sẽ là 1 trong khi những người khác sẽ là 32.  Thông thường điều này hoạt động.
Chỉ trong trường hợp nó không hoạt động và bạn nhận được thông báo cảnh báo, bạn nên
thay đổi tham số này thành các giá trị khác.


Vấn đề thăm dò Codec
---------------------
Một vấn đề ít thường xuyên hơn nhưng nghiêm trọng hơn là việc thăm dò codec.  Khi nào
BIOS báo sai các khe codec có sẵn, trình điều khiển nhận được
bối rối và cố gắng truy cập vào khe codec không tồn tại.  Điều này thường xuyên
dẫn đến sự cố hoàn toàn và phá hủy giao tiếp tiếp theo
với chip codec.  Triệu chứng này thường xuất hiện dưới dạng thông báo lỗi
như:
::::

hda_intel: hết thời gian chờ azx_get_response, chuyển sang chế độ bỏ phiếu:
          cmd cuối cùng = 0x12345678
    hda_intel: hết thời gian chờ azx_get_response, chuyển sang chế độ single_cmd:
          cmd cuối cùng = 0x12345678

Dòng đầu tiên là cảnh báo và điều này thường tương đối vô hại.
Điều đó có nghĩa là phản hồi codec không được thông báo qua IRQ.  các
trình điều khiển sử dụng phương pháp bỏ phiếu rõ ràng để đọc phản hồi.  Nó mang lại
chi phí CPU rất nhỏ, nhưng bạn khó có thể nhận thấy nó.

Tuy nhiên, dòng thứ hai là một lỗi nghiêm trọng.  Nếu điều này xảy ra, thường
nó có nghĩa là có điều gì đó thực sự không ổn.  Rất có thể bạn là
truy cập vào một khe codec không tồn tại.

Vì vậy, nếu thông báo lỗi thứ hai xuất hiện, hãy cố gắng thu hẹp phạm vi được thăm dò.
khe cắm codec thông qua tùy chọn ZZ0000ZZ.  Đó là một bitmask, và mỗi bit
tương ứng với khe codec.  Ví dụ: chỉ thăm dò lần đầu tiên
khe cắm, vượt qua ZZ0001ZZ.  Đối với vị trí thứ nhất và thứ ba, hãy vượt qua
ZZ0002ZZ (trong đó 5 = 1 | 4), v.v.

Kể từ kernel 2.6.29, trình điều khiển có phương pháp thăm dò mạnh mẽ hơn, vì vậy
Tuy nhiên, lỗi này có thể hiếm khi xảy ra.

Trên máy có BIOS bị hỏng, đôi khi bạn cần buộc
trình điều khiển để thăm dò các khe cắm codec mà phần cứng không báo cáo để sử dụng.
Trong trường hợp như vậy, hãy bật bit 8 (0x100) của tùy chọn ZZ0000ZZ.
Sau đó, 8 bit còn lại được truyền dưới dạng khe codec để thăm dò
vô điều kiện.  Ví dụ: ZZ0001ZZ sẽ buộc phải thăm dò
các khe codec 0 và 1 bất kể báo cáo phần cứng như thế nào.


Xử lý ngắt
------------------
Trình điều khiển âm thanh HD sử dụng MSI làm mặc định (nếu có) kể từ phiên bản 2.6.33
kernel như MSI hoạt động tốt hơn trên một số máy và nói chung, nó
tốt hơn cho hiệu suất.  Tuy nhiên, bộ điều khiển Nvidia hiển thị không tốt
hồi quy với MSI (đặc biệt là khi kết hợp với chipset AMD),
do đó chúng tôi đã vô hiệu hóa MSI cho họ.

Có vẻ như vẫn còn các thiết bị khác không hoạt động với MSI.  Nếu bạn
xem hồi quy ghi lại chất lượng âm thanh (nói lắp, v.v.) hoặc bị khóa
trong kernel gần đây, hãy thử chuyển tùy chọn ZZ0000ZZ để tắt
MSI.  Nếu nó hoạt động, bạn có thể thêm thiết bị xấu đã biết vào danh sách đen
được xác định trong hda_intel.c.  Trong trường hợp như vậy, vui lòng báo cáo và đưa ra
vá lại cho nhà phát triển ngược dòng.


Bộ giải mã âm thanh HD
======================

Tùy chọn mẫu
------------
Vấn đề phổ biến nhất liên quan đến trình điều khiển âm thanh HD là
các tính năng codec không được hỗ trợ hoặc cấu hình thiết bị không khớp.
Hầu hết các mã dành riêng cho codec đều có một số mô hình cài sẵn, để
ghi đè thiết lập BIOS hoặc để cung cấp các tính năng toàn diện hơn.

Trình điều khiển kiểm tra PCI SSID và xem qua cấu hình tĩnh
table cho đến khi tìm thấy bất kỳ mục nào phù hợp.  Nếu bạn có một chiếc máy mới,
bạn có thể thấy một thông báo như dưới đây:
:::::::::::::::::::::::::::::::::::::::::::

hda_codec: ALC880: BIOS tự động thăm dò.

Trong khi đó, ở các phiên bản trước, bạn sẽ thấy thông báo như:
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

hda_codec: Model không xác định cho ALC880, đang thử tự động thăm dò từ BIOS...

Ngay cả khi bạn thấy thông báo như vậy, DON'T PANIC.  Hãy hít một hơi thật sâu và
giữ khăn của bạn.  Trước hết, đó là một tin nhắn thông tin, không
cảnh báo, không có lỗi.  Điều này có nghĩa là PCI SSID trên thiết bị của bạn không
được liệt kê trong danh sách mô hình cài sẵn (trắng-).  Nhưng, điều này không có nghĩa
là driver bị hỏng.  Nhiều trình điều khiển codec cung cấp tính năng tự động
cơ chế cấu hình dựa trên thiết lập BIOS.

Bộ giải mã âm thanh HD thường có các tiện ích "ghim" và BIOS đặt mặc định
cấu hình của mỗi chân, cho biết vị trí,
loại kết nối, màu giắc cắm, v.v. Trình điều khiển âm thanh HD có thể đoán
kết nối phù hợp được đánh giá dựa trên các giá trị cấu hình mặc định này.
Tuy nhiên -- một số mã hỗ trợ codec, chẳng hạn như patch_analog.c, thì không
hỗ trợ việc thăm dò tự động (kể từ 2.6.28).  Và, BIOS thường xuyên,
vâng, khá thường xuyên bị hỏng.  Nó thiết lập các giá trị sai và làm hỏng
người lái xe.

Mô hình cài sẵn (hoặc gần đây được gọi là "sửa chữa") được cung cấp
về cơ bản để khắc phục tình trạng như vậy.  Khi cài đặt trước phù hợp
mô hình được tìm thấy trong danh sách trắng, trình điều khiển sẽ giả định trạng thái tĩnh
cấu hình của cài đặt trước đó với thiết lập pin chính xác, v.v.
Do đó, nếu bạn có một máy mới hơn với PCI SSID hơi khác một chút
(hoặc codec SSID) từ mã hiện có, bạn có thể có cơ hội tốt để
sử dụng lại mô hình tương tự.  Bạn có thể chuyển tùy chọn ZZ0000ZZ để chỉ định
mô hình cài sẵn thay vì tra cứu PCI (và codec-) SSID.

Giá trị tùy chọn ZZ0000ZZ nào có sẵn tùy thuộc vào chip codec.
Kiểm tra chip codec của bạn từ tệp codec proc (xem "Codec Proc-File"
phần bên dưới).  Nó sẽ hiển thị tên nhà cung cấp/tên sản phẩm của codec của bạn
chip.  Sau đó, xem tệp Tài liệu/sound/hd-audio/models.rst,
phần trình điều khiển âm thanh HD.  Bạn có thể tìm thấy danh sách codec
và các tùy chọn ZZ0001ZZ thuộc từng codec.  Ví dụ: đối với Realtek
Chip codec ALC262, pass ZZ0002ZZ cho các thiết bị tương thích
với Samsung Q1 Ultra.

Vì vậy, điều đầu tiên bạn có thể làm đối với bất kỳ sản phẩm hoàn toàn mới, không được hỗ trợ và
phần cứng âm thanh HD không hoạt động là kiểm tra codec âm thanh HD và một số
các giá trị tùy chọn ZZ0000ZZ khác nhau.  Nếu bạn gặp may mắn, một số trong số họ
có thể phù hợp với thiết bị của bạn.

Có một vài giá trị tùy chọn mô hình đặc biệt:

* khi 'nofixup' được thông qua, các bản sửa lỗi dành riêng cho thiết bị trong codec
  trình phân tích cú pháp bị bỏ qua.
* khi ZZ0000ZZ được thông qua, trình phân tích cú pháp dành riêng cho codec sẽ bị bỏ qua và
  chỉ có trình phân tích cú pháp chung được sử dụng.

Một phong cách mới cho tùy chọn mô hình đã được giới thiệu kể từ kernel 5.15
là chuyển PCI hoặc codec SSID ở dạng ZZ0000ZZ
trong đó XXXX và YYYY là ID nhà cung cấp phụ và ID thiết bị phụ ở dạng hex
các số tương ứng.  Đây là một kiểu đặt bí danh cho một thiết bị khác;
khi biểu mẫu này được cung cấp, người lái xe sẽ gọi chiếc SSID đó là
tham chiếu đến bảng quirk.  Nó sẽ hữu ích đặc biệt khi
mục tiêu không được liệt kê trong bảng mô hình.  Ví dụ như đi qua
model=103c:8862 sẽ áp dụng giải pháp này cho HP ProBook 445 G8 (
không được tìm thấy trong bảng mô hình khi viết) miễn là thiết bị
được xử lý tương đương bởi cùng một trình điều khiển.


Đầu ra loa và tai nghe
----------------------------
Một trong những lỗi thường gặp (và hiển nhiên) nhất với âm thanh HD là
đầu ra im lặng từ một hoặc cả hai loa tích hợp và
giắc cắm tai nghe.  Nói chung, bạn nên thử đầu ra tai nghe ở mức
đầu tiên.  Đầu ra loa thường yêu cầu nhiều điều khiển bổ sung hơn như
các bit khuếch đại bên ngoài.  Do đó, đầu ra tai nghe có một chút
cơ hội tốt hơn.

Trước khi báo cáo lỗi, hãy kiểm tra kỹ xem bộ trộn đã được thiết lập chưa
một cách chính xác.  Phiên bản gần đây của trình điều khiển snd-hda-intel cung cấp hầu hết
Điều khiển âm lượng "Chính" cũng như âm lượng "Mặt trước" (trong đó Mặt trước
cho biết các kênh phía trước).  Ngoài ra, có thể có cá nhân
Điều khiển "Tai nghe" và "Loa".

Ditto cho đầu ra loa.  Có thể có "Bộ khuếch đại bên ngoài"
bật một số codec.  Bật cái này nếu có.

Một vấn đề liên quan khác là việc tự động tắt tiếng đầu ra loa bằng cách
cắm tai nghe.  Tính năng này được triển khai trong hầu hết các trường hợp, nhưng
không phải trên mọi mẫu máy cài sẵn hoặc mã hỗ trợ codec.

Dù sao đi nữa, hãy thử tùy chọn model khác nếu bạn gặp vấn đề như vậy.
Một số mô hình khác có thể phù hợp hơn và cung cấp cho bạn nhiều kết hợp hơn
chức năng.  Nếu không có mô hình nào hoạt động, hãy gửi lỗi
báo cáo.  Xem phần báo cáo lỗi để biết chi tiết.

Nếu bạn đủ bạo dâm để gỡ lỗi vấn đề trình điều khiển, hãy lưu ý
sau đây:

* Đầu ra loa (và cả tai nghe nữa) thường yêu cầu
  bộ khuếch đại bên ngoài.  Điều này có thể được thiết lập thường thông qua động từ EAPD hoặc một
  một số GPIO nhất định.  Nếu chân codec hỗ trợ EAPD, bạn có lựa chọn tốt hơn
  cơ hội thông qua động từ SET_EAPD_BTL (0x70c).  Trên các loại khác, chân GPIO (chủ yếu
  đó là GPIO0 hoặc GPIO1) có thể bật/tắt EAPD.
* Một số codec Realtek yêu cầu hệ số đặc biệt dành riêng cho nhà cung cấp để
  bật bộ khuếch đại.  Xem patch_realtek.c.
* Các codec IDT có thể có thêm các điều khiển bật/tắt nguồn trên mỗi codec
  chân tương tự.  Xem patch_sigmatel.c.
* Rất hiếm nhưng một số thiết bị không chấp nhận động từ phát hiện mã pin cho đến khi
  được kích hoạt.  Việc phát hành động từ GET_PIN_SENSE (0xf09) có thể dẫn đến
  gian hàng truyền thông codec.  Một số ví dụ được tìm thấy trong
  patch_realtek.c.


Nắm bắt vấn đề
----------------
Các vấn đề về chụp ảnh thường do thiếu thiết lập bộ trộn.
Vì vậy, trước khi gửi báo cáo lỗi, hãy đảm bảo rằng bạn đã thiết lập
máy trộn chính xác.  Ví dụ: cả "Chụp âm lượng" và "Chụp
Switch" phải được đặt đúng bên cạnh nút "Chụp" bên phải.
Lựa chọn Nguồn" hoặc "Nguồn đầu vào".  Một số thiết bị có "Mic Boost"
âm lượng hoặc chuyển đổi.

Khi thiết bị PCM được mở thông qua PCM "mặc định" (không có xung âm thanh
plugin), bạn cũng có thể có quyền kiểm soát "Âm lượng chụp kỹ thuật số".
Điều này được cung cấp để tăng thêm/suy giảm tín hiệu trong
phần mềm, đặc biệt là đối với các đầu vào không có âm lượng phần cứng
điều khiển như micro kỹ thuật số.  Trừ khi thực sự cần thiết, điều này
phải được đặt chính xác ở mức 50%, tương ứng với 0dB -- không tăng thêm
tăng cũng không suy giảm.  Khi bạn sử dụng "hw" PCM, tức là truy cập thô PCM,
Tuy nhiên, sự kiểm soát này sẽ không có ảnh hưởng.

Được biết, một số codec/thiết bị có mạch analog khá tệ,
và âm thanh được ghi có chứa một phần bù DC nhất định.  Đây không phải là lỗi
của người lái xe.

Hầu hết các máy tính xách tay hiện đại đều không có kết nối đầu vào CD tương tự.  Như vậy,
ghi từ đầu vào CD sẽ không hoạt động trong nhiều trường hợp mặc dù trình điều khiển
cung cấp nó như là nguồn chụp.  Thay vào đó hãy sử dụng CDDA.

Tự động chuyển đổi mic tích hợp và mic ngoài mỗi lần cắm
được triển khai trên một số mô hình codec nhưng không phải trên mọi mô hình.  một phần
vì sự lười biếng của tôi nhưng chủ yếu là thiếu người thử nghiệm.  Hãy thoải mái
gửi bản vá cải tiến cho tác giả.


Gỡ lỗi trực tiếp
----------------
Nếu không có tùy chọn mô hình nào mang lại cho bạn kết quả tốt hơn và bạn là một người cứng rắn
để chống lại cái ác, hãy thử gỡ lỗi bằng cách nhấn vào âm thanh HD thô
động từ codec vào thiết bị.  Một số công cụ có sẵn: hda-emu và
máy phân tích hda.  Mô tả chi tiết được tìm thấy trong các phần
bên dưới.  Bạn cần kích hoạt hwdep để sử dụng những công cụ này.  Xem "Hạt nhân
phần Cấu hình".


Các vấn đề khác
===============

Cấu hình hạt nhân
--------------------
Nói chung, tôi khuyên bạn nên bật tùy chọn gỡ lỗi âm thanh,
ZZ0000ZZ, bất kể bạn có gỡ lỗi hay không.

Đừng quên bật ZZ0000ZZ thích hợp
tùy chọn.  Lưu ý rằng mỗi cái đều tương ứng với chip codec chứ không phải
chip điều khiển.  Do đó, ngay cả khi lspci hiển thị bộ điều khiển Nvidia,
bạn có thể cần phải chọn tùy chọn cho các nhà cung cấp khác.  Nếu bạn là
không chắc chắn, chỉ cần chọn tất cả có.

ZZ0000ZZ là một tùy chọn hữu ích để gỡ lỗi trình điều khiển.
Khi tính năng này được bật, trình điều khiển sẽ tạo các thiết bị phụ thuộc vào phần cứng
(mỗi codec một cái) và bạn có quyền truy cập thô vào thiết bị thông qua
các tập tin thiết bị này.  Ví dụ: ZZ0001ZZ sẽ được tạo cho
khe codec #2 của thẻ đầu tiên (#0).  Đối với các công cụ gỡ lỗi như
hda-verb và hda-analyzer, thiết bị hwdep phải được bật.
Vì vậy, tốt hơn hết là bạn nên bật tính năng này luôn.

ZZ0000ZZ là một tùy chọn mới và điều này phụ thuộc vào
tùy chọn hwdep ở trên.  Khi được bật, bạn sẽ có một số tệp sysfs bên dưới
thư mục hwdep tương ứng.  Xem "Cấu hình lại âm thanh HD"
phần bên dưới.

Tùy chọn ZZ0000ZZ cho phép tính năng tiết kiệm năng lượng.
Xem phần "Tiết kiệm năng lượng" bên dưới.


Tệp Proc Codec
---------------
Tệp proc codec là một kho báu để gỡ lỗi âm thanh HD.
Nó hiển thị hầu hết các thông tin hữu ích của từng widget codec.

Tệp Proc nằm ở /proc/asound/card*/codec#*, mỗi tệp một tệp
mỗi khe codec.  Bạn có thể biết nhà cung cấp codec, id sản phẩm và
tên, loại của từng tiện ích, khả năng, v.v.
Tuy nhiên, cho đến nay, tệp này không hiển thị trạng thái cảm biến giắc cắm.  Cái này
là do cảm biến giắc cắm có thể phụ thuộc vào trạng thái kích hoạt.

Tệp này sẽ được các công cụ gỡ lỗi chọn và nó cũng có thể được cung cấp
tới trình mô phỏng làm thông tin codec chính.  Xem các công cụ gỡ lỗi
phần bên dưới.

Tệp Proc này cũng có thể được sử dụng để kiểm tra xem trình phân tích cú pháp chung có
đã sử dụng.  Khi sử dụng trình phân tích cú pháp chung, tên ID nhà cung cấp/sản phẩm
sẽ xuất hiện dưới dạng "Realtek ID 0262", thay vì "Realtek ALC262".


Cấu hình lại âm thanh HD
------------------------
Đây là tính năng thử nghiệm cho phép bạn định cấu hình lại âm thanh HD
codec động mà không cần tải lại trình điều khiển.  Các sysf sau đây
các tập tin có sẵn trong mỗi thư mục thiết bị codec-hwdep (ví dụ:
/sys/class/sound/hwC0D0):

nhà cung cấp_id
    Hiển thị số hex id nhà cung cấp codec 32bit.  Bạn có thể thay đổi
    giá trị id nhà cung cấp bằng cách ghi vào tệp này.
hệ thống con_id
    Hiển thị số hex id hệ thống con codec 32bit.  Bạn có thể thay đổi
    giá trị id hệ thống con bằng cách ghi vào tệp này.
sửa đổi_id
    Hiển thị số hex id sửa đổi codec 32 bit.  Bạn có thể thay đổi
    giá trị sửa đổi-id bằng cách ghi vào tệp này.
afg
    Hiển thị ID AFG.  Đây là chỉ đọc.
mfg
    Hiển thị ID MFG.  Đây là chỉ đọc.
tên
    Hiển thị chuỗi tên codec.  Có thể thay đổi bằng cách viết vào đây
    tập tin.
tên mẫu
    Hiển thị tùy chọn ZZ0000ZZ hiện được đặt.  Có thể thay đổi bằng cách viết
    vào tập tin này.
init_verb
    Các động từ bổ sung để thực hiện khi khởi tạo.  Bạn có thể thêm một động từ bằng cách
    ghi vào tập tin này.  Truyền ba số: nid, động từ và tham số
    (cách nhau bằng dấu cách).
gợi ý
    Hiển thị/lưu trữ chuỗi gợi ý cho trình phân tích cú pháp codec cho mọi mục đích sử dụng.
    Định dạng của nó là ZZ0001ZZ.  Ví dụ: chuyển ZZ0002ZZ
    sẽ vô hiệu hóa hoàn toàn việc phát hiện jack cắm của máy.
init_pin_configs
    Hiển thị các giá trị cấu hình mặc định của pin ban đầu do BIOS đặt.
driver_pin_configs
    Hiển thị rõ ràng các giá trị mặc định của mã pin do trình phân tích cú pháp codec đặt.
    Điều này không hiển thị tất cả các giá trị pin mà chỉ hiển thị các giá trị được thay đổi bởi
    trình phân tích cú pháp.  Tức là, nếu trình phân tích cú pháp không thay đổi mã pin mặc định
    config, nó sẽ không chứa gì cả.
user_pin_configs
    Hiển thị các giá trị cấu hình mặc định của pin để ghi đè thiết lập BIOS.
    Viết phần này (với hai số, NID và giá trị) sẽ thêm vào phần mới
    giá trị.  Giá trị đã cho sẽ được sử dụng thay cho giá trị BIOS ban đầu tại
    lần cấu hình lại tiếp theo.  Lưu ý rằng cấu hình này sẽ ghi đè
    ngay cả cấu hình pin trình điều khiển cũng vậy.
cấu hình lại
    Kích hoạt cấu hình lại codec.  Khi bất kỳ giá trị nào được ghi vào
    tập tin này, trình điều khiển sẽ khởi tạo lại và phân tích cây codec
    một lần nữa.  Tất cả những thay đổi được thực hiện bởi các mục sysfs ở trên đều được thực hiện
    tính đến.
rõ ràng
    Đặt lại codec, loại bỏ các phần tử bộ trộn và nội dung PCM của
    codec được chỉ định và xóa tất cả các động từ và gợi ý init.

Ví dụ: khi bạn muốn thay đổi cấu hình mặc định của pin
giá trị của tiện ích pin 0x14 đến 0x9993013f và để trình điều khiển
cấu hình lại dựa trên trạng thái đó, chạy như dưới đây:
:::::::::::::::::::::::::::::::::::::::::::::::::::::::

# echo 0x14 0x9993013f > /sys/class/sound/hwC0D0/user_pin_configs
    # echo 1 > /sys/class/sound/hwC0D0/reconfig


Chuỗi gợi ý
------------
Bộ phân tích cú pháp codec có một số công tắc và nút điều chỉnh để
phù hợp hơn với codec thực tế hoặc hoạt động của thiết bị.  Nhiều trong số
chúng có thể được điều chỉnh linh hoạt thông qua các chuỗi "gợi ý" như đã đề cập trong
phần trên.  Ví dụ: bằng cách truyền chuỗi ZZ0000ZZ
thông qua sysfs hoặc tệp vá, bạn có thể tắt tính năng phát hiện giắc cắm, do đó
trình phân tích cú pháp codec sẽ bỏ qua các tính năng như tự động tắt tiếng hoặc mic
tự động chuyển đổi.  Là giá trị boolean, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ,
ZZ0005ZZ hoặc ZZ0006ZZ có thể được thông qua.

Trình phân tích cú pháp chung hỗ trợ các gợi ý sau:

jack_Detect (bool)
    chỉ định xem tính năng phát hiện giắc cắm có sẵn trên thiết bị này hay không
    máy; mặc định đúng
inv_jack_Detect (bool)
    chỉ ra rằng logic phát hiện jack bị đảo ngược
trigger_sense (bool)
    chỉ ra rằng việc phát hiện jack cần có lệnh gọi rõ ràng của
    Động từ AC_VERB_SET_PIN_SENSE
inv_eapd (bool)
    chỉ ra rằng EAPD được triển khai theo logic đảo ngược
pcm_format_first (bool)
    đặt định dạng PCM trước thẻ luồng và ID kênh
dính_stream (bool)
    giữ định dạng PCM, thẻ luồng và ID càng lâu càng tốt;
    mặc định đúng
spdif_status_reset (bool)
    đặt lại các bit trạng thái SPDIF mỗi lần luồng SPDIF được đặt
    lên
pin_amp_workaround (bool)
    chân đầu ra có thể có nhiều giá trị amp
single_adc_amp (bool)
    ADC chỉ có thể có các ampe đầu vào duy nhất
auto_mute (bool)
    bật/tắt tính năng tự động tắt tiếng tai nghe; mặc định đúng
auto_mic (bool)
    bật/tắt tính năng tự động chuyển mic; mặc định đúng
line_in_auto_switch (bool)
    bật/tắt tính năng tự động chuyển đổi đầu vào; mặc định sai
need_dac_fix (bool)
    giới hạn DAC tùy thuộc vào số lượng kênh
chính_hp (bool)
    thăm dò giắc cắm tai nghe làm đầu ra chính; mặc định đúng
multi_io (bool)
    hãy thử thăm dò cấu hình nhiều I/O (ví dụ: đường truyền vào/vòm được chia sẻ,
    giắc cắm mic/clfe)
multi_cap_vol (bool)
    cung cấp nhiều khối lượng chụp
inv_dmic_split (bool)
    cung cấp công tắc/âm lượng mic bên trong được chia nhỏ để đảo pha
    micro kỹ thuật số
indep_hp (bool)
    cung cấp luồng tai nghe PCM độc lập và luồng tương ứng
    điều khiển máy trộn, nếu có
add_stereo_mix_input (bool)
    thêm hỗn hợp âm thanh nổi (hỗn hợp vòng lặp tương tự) vào mux đầu vào nếu
    có sẵn
add_jack_modes (bool)
    thêm các điều khiển enum "xxx Jack Mode" vào mỗi giắc I/O để cho phép
    thay đổi khả năng của amp tai nghe và mic VREF
power_save_node (bool)
    quản lý năng lượng tiên tiến cho từng widget, kiểm soát năng lượng
    trạng thái (D0/D3) của mỗi nút widget tùy thuộc vào mã pin thực tế và
    trạng thái luồng
power_down_unused (bool)
    tắt nguồn các tiện ích không sử dụng, một tập hợp con của power_save_node và
    sẽ bị loại bỏ trong tương lai
add_hp_mic (bool)
    thêm tai nghe để thu nguồn nếu có thể
hp_mic_ detect (bool)
    bật/tắt đầu vào chia sẻ hp/mic cho một mic tích hợp
    trường hợp; mặc định đúng
vmaster (bool)
    bật/tắt điều khiển Master ảo; mặc định đúng
bộ trộn_nid (int)
    chỉ định tiện ích NID của bộ trộn vòng lặp tương tự


Vá sớm
--------------
Khi ZZ0000ZZ được đặt, bạn có thể chuyển "bản vá"
dưới dạng tệp chương trình cơ sở để sửa đổi thiết lập âm thanh HD trước đó
khởi tạo codec.  Điều này về cơ bản có thể hoạt động giống như
cấu hình lại thông qua sysfs ở trên, nhưng nó thực hiện trước
cấu hình codec đầu tiên.

Tệp bản vá là một tệp văn bản đơn giản trông giống như bên dưới:

::

[codec]
    0x12345678 0xabcd1234 2

[mô hình]
    tự động

[pincfg]
    0x12 0x411111f0

[động từ]
    0x20 0x500 0x03
    0x20 0x400 0xff

[gợi ý]
    jack_Detect = không


Tệp cần phải có dòng ZZ0000ZZ.  Dòng tiếp theo phải chứa
ba số biểu thị id nhà cung cấp codec (0x12345678 trong
ví dụ), id hệ thống con codec (0xabcd1234) và địa chỉ (2) của
bộ giải mã.  Các mục vá còn lại được áp dụng cho codec được chỉ định này
cho đến khi một mục codec khác được đưa ra.  Truyền 0 hoặc số âm tới
giá trị thứ nhất hoặc thứ hai sẽ thực hiện việc kiểm tra tương ứng
trường được bỏ qua.  Nó sẽ hữu ích cho những thiết bị thực sự bị hỏng mà không
khởi tạo SSID đúng cách.

Dòng ZZ0000ZZ cho phép thay đổi tên model của từng codec.
Trong ví dụ trên, nó sẽ được đổi thành model=auto.
Lưu ý rằng điều này sẽ ghi đè tùy chọn mô-đun.

Sau dòng ZZ0000ZZ, nội dung được phân tích cú pháp như ban đầu
cấu hình pin mặc định giống như các hệ thống ZZ0001ZZ ở trên.
Các giá trị cũng có thể được hiển thị trong tệp sysfs user_pin_configs.

Tương tự, các dòng sau ZZ0000ZZ được phân tích thành ZZ0001ZZ
các mục sysfs và các dòng sau ZZ0002ZZ được phân tích cú pháp thành ZZ0003ZZ
các mục sysfs tương ứng.

Một ví dụ khác để ghi đè id nhà cung cấp codec từ 0x12345678 thành
0xdeadbeef giống như dưới đây:
::::::::::::::::::::::::::::::

[codec]
    0x12345678 0xabcd1234 2

[nhà cung cấp_id]
    0xdeadbeef


Theo cách tương tự, bạn có thể ghi đè codec subsystem_id thông qua
ZZ0000ZZ, id sửa đổi thông qua dòng ZZ0001ZZ.
Ngoài ra, tên chip codec có thể được viết lại thông qua dòng ZZ0002ZZ.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

[codec]
    0x12345678 0xabcd1234 2

[id_hệ thống con]
    0xffff1111

[revision_id]
    0x10

[tên chip]
    NEWS-0002 của riêng tôi


Trình điều khiển âm thanh hd đọc tệp qua request_firmware().  Như vậy,
một tập tin vá lỗi phải được đặt trên đường dẫn phần sụn thích hợp,
thông thường, /lib/firmware.  Ví dụ: khi bạn chuyển tùy chọn
ZZ0000ZZ, tệp /lib/firmware/hda-init.fw phải là
hiện tại.

Tùy chọn mô-đun bản vá dành riêng cho từng phiên bản thẻ và bạn
cần đặt một tên tệp cho mỗi phiên bản, cách nhau bằng dấu phẩy.
Ví dụ: nếu bạn có hai thẻ, một thẻ dành cho thiết bị tương tự trên bo mạch và một thẻ
đối với bảng video HDMI, bạn có thể chuyển tùy chọn bản vá như bên dưới:
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

tùy chọn snd-hda-intel patch=on-board-patch,hdmi-patch


Tiết kiệm điện
--------------
Tiết kiệm năng lượng là một kiểu tự động tạm dừng của thiết bị.  Khi
thiết bị không hoạt động trong một thời gian nhất định, thiết bị sẽ tự động
tắt để tiết kiệm điện.  Thời gian đi xuống được chỉ định thông qua
Tùy chọn mô-đun ZZ0000ZZ và tùy chọn này có thể được thay đổi linh hoạt
thông qua sysfs.

Tính năng tiết kiệm năng lượng sẽ không hoạt động khi bật vòng lặp tương tự
một số codec.  Đảm bảo rằng bạn tắt tiếng tất cả các tuyến tín hiệu không cần thiết khi
bạn muốn tiết kiệm điện.

Tính năng tiết kiệm năng lượng có thể gây ra tiếng click có thể nghe được ở mỗi lần
tắt/mở nguồn tùy theo thiết bị.  Một số trong số họ có thể là
có thể giải quyết được, nhưng một số thì khó, tôi e là vậy.  Một số distro như
openSUSE tự động kích hoạt tính năng tiết kiệm năng lượng khi mất điện.
cáp đã được rút ra.  Vì vậy, nếu bạn nghe thấy tiếng động, trước tiên hãy nghi ngờ
tiết kiệm điện.  Xem /sys/module/snd_hda_intel/parameters/power_save để
kiểm tra giá trị hiện tại.  Nếu khác 0 thì tính năng này sẽ được bật.

Hạt nhân gần đây hỗ trợ PM thời gian chạy cho bộ điều khiển âm thanh HD
chíp cũng vậy.  Điều đó có nghĩa là bộ điều khiển âm thanh HD cũng được cấp nguồn /
xuống một cách linh hoạt.  Tính năng này chỉ được bật cho một số bộ điều khiển nhất định
chip như Intel LynxPoint.  Bạn có thể bật/tắt tính năng này
cưỡng bức bằng cách cài đặt tùy chọn ZZ0000ZZ, cũng là
có sẵn tại thư mục /sys/module/snd_hda_intel/parameters.


Dấu vết
-----------
Trình điều khiển âm thanh hd cung cấp một số dấu vết cơ bản.
ZZ0000ZZ theo dõi từng thao tác ghi của CORB trong khi ZZ0001ZZ
theo dõi phản hồi từ RIRB (chỉ khi đọc từ trình điều khiển codec).
ZZ0002ZZ theo dõi việc thiết lập lại bus do lỗi nghiêm trọng, v.v.
ZZ0003ZZ theo dõi các sự kiện không được yêu cầu và
ZZ0004ZZ và ZZ0005ZZ theo dõi quá trình tăng/giảm nguồn
thông qua hành vi tiết kiệm năng lượng.

Việc kích hoạt tất cả các điểm theo dõi có thể được thực hiện như
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# echo 1 > /sys/kernel/tracing/events/hda/enable

sau đó sau một số lệnh, bạn có thể theo dõi từ
/sys/kernel/tập tin theo dõi/theo dõi.  Ví dụ, khi bạn muốn
theo dõi lệnh codec nào được gửi, kích hoạt tracepoint như:
:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

# cat/sys/kernel/truy tìm/dấu vết
    # tracer: không
    #
    #       ZZ0002ZZ-ZZ0003ZZ CPU#    ZZ0005ZZ FUNCTION
    #          ZZ0007ZZ ZZ0001ZZ |
	   <...>-7807 [002] 105147.774889: hda_send_cmd: [0:0] val=e3a019
	   <...>-7807 [002] 105147.774893: hda_send_cmd: [0:0] val=e39019
	   <...>-7807 [002] 105147.999542: hda_send_cmd: [0:0] val=e3a01a
	   <...>-7807 [002] 105147.999543: hda_send_cmd: [0:0] val=e3901a
	   <...>-26764 [001] 349222.837143: hda_send_cmd: [0:0] val=e3a019
	   <...>-26764 [001] 349222.837148: hda_send_cmd: [0:0] val=e39019
	   <...>-26764 [001] 349223.058539: hda_send_cmd: [0:0] val=e3a01a
	   <...>-26764 [001] 349223.058541: hda_send_cmd: [0:0] val=e3901a

Ở đây ZZ0000ZZ cho biết số thẻ và địa chỉ codec, đồng thời
ZZ0001ZZ hiển thị giá trị được gửi tới codec tương ứng.  Giá trị là
một giá trị được đóng gói và bạn có thể giải mã nó thông qua chương trình hda-decode-verb
có trong gói hda-emu bên dưới.  Ví dụ: giá trị e3a019 là
để đặt giá trị amp đầu ra bên trái thành 25.
::::::::::::::::::::::::::::::::::::::::::::

% hda-decode-động từ 0xe3a019
    giá trị thô = 0x00e3a019
    cid = 0, nid = 0x0e, động từ = 0x3a0, parm = 0x19
    giá trị thô: động từ = 0x3a0, parm = 0x19
    tên động từ = set_amp_gain_mute
    amp thô giá trị = 0xa019
    đầu ra, trái, idx=0, mute=0, val=25


Cây phát triển
----------------
Các mã phát triển mới nhất cho âm thanh HD được tìm thấy trên cây git âm thanh:

* git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/sound.git

Nhánh chính hoặc nhánh tiếp theo có thể được sử dụng làm nhánh chính
các ngành phát triển nói chung đồng thời với sự phát triển hiện nay
và các hạt nhân tiếp theo được tìm thấy trong các nhánh for-linus và for-next,
tương ứng.


Gửi báo cáo lỗi
--------------------
Nếu bất kỳ tùy chọn kiểu máy hoặc mô-đun nào không hoạt động cho thiết bị của bạn thì đã đến lúc
để gửi báo cáo lỗi cho nhà phát triển.  Đưa ra những điều sau đây trong
báo cáo lỗi:

* Tên nhà cung cấp phần cứng, sản phẩm và model
* Phiên bản hạt nhân (và phiên bản trình điều khiển ALSA nếu bạn xây dựng bên ngoài)
* Đầu ra ZZ0000ZZ; chạy với tùy chọn ZZ0001ZZ.  Xem
  phần bên dưới về thông tin alsa

Nếu đó là hồi quy, tốt nhất, hãy gửi kết quả đầu ra alsa-info của cả hai hoạt động
và hạt nhân không hoạt động.  Điều này thực sự hữu ích vì chúng ta có thể
so sánh trực tiếp các thanh ghi codec.

Gửi báo cáo lỗi như sau:

kernel-bugzilla
    ZZ0000ZZ
alsa-devel ML
    alsa-devel@alsa-project.org


Công cụ gỡ lỗi
==============

Phần này mô tả một số công cụ có sẵn để gỡ lỗi âm thanh HD
vấn đề.

thông tin alsa
--------------
Tập lệnh ZZ0000ZZ là một công cụ rất hữu ích để thu thập âm thanh
thông tin thiết bị.  Nó được bao gồm trong gói alsa-utils.  mới nhất
phiên bản có thể được tìm thấy trên kho git:

* git://git.alsa-project.org/alsa-utils.git

Tập lệnh cũng có thể được tìm nạp trực tiếp từ URL sau:

* ZZ0000ZZ

Chạy tập lệnh này với quyền root và nó sẽ thu thập thông tin quan trọng
chẳng hạn như danh sách mô-đun, tham số mô-đun, nội dung tệp Proc
bao gồm các tập tin codec proc, đầu ra bộ trộn và điều khiển
các phần tử.  Theo mặc định, nó sẽ lưu trữ thông tin trên máy chủ web
trên alsa-project.org.  Tuy nhiên, nếu bạn gửi báo cáo lỗi, tốt hơn hết là bạn nên gửi
chạy với tùy chọn ZZ0000ZZ và đính kèm tệp đã tạo.

Có một số tùy chọn hữu ích khác.  Xem đầu ra tùy chọn ZZ0000ZZ để biết
chi tiết.

Khi xảy ra lỗi thăm dò hoặc khi trình điều khiển rõ ràng chỉ định một
mô hình không khớp, sẽ rất hữu ích khi tải trình điều khiển bằng
Tùy chọn ZZ0000ZZ (tốt nhất là sau khi khởi động lại nguội) và chạy
alsa-info ở trạng thái này.  Với tùy chọn này, trình điều khiển sẽ không cấu hình
bộ trộn và PCM nhưng chỉ cố gắng thăm dò khe cắm codec.  Sau
đang thăm dò, tệp Proc có sẵn, vì vậy bạn có thể lấy codec thô
thông tin trước khi được người lái xe sửa đổi.  Tất nhiên, người lái xe
không thể sử dụng được với ZZ0001ZZ.  Nhưng bạn có thể tiếp tục
cấu hình thông qua tệp hwdep sysfs nếu tùy chọn hda-reconfig được bật.
Sử dụng mặt nạ ZZ0002ZZ 2 sẽ bỏ qua việc đặt lại codec HDA (sử dụng
ZZ0003ZZ làm tùy chọn mô-đun). Giao diện hwdep có thể được sử dụng
để xác định khởi tạo codec BIOS.


động từ hda
-----------
hda-verb là một chương trình nhỏ cho phép bạn truy cập âm thanh HD
codec trực tiếp.  Bạn có thể thực thi một động từ codec âm thanh HD thô bằng cách này.
Chương trình này truy cập vào thiết bị hwdep, do đó bạn cần kích hoạt
cấu hình kernel ZZ0000ZZ trước.

Chương trình hda-verb có bốn đối số: tệp thiết bị hwdep,
widget NID, động từ và tham số.  Khi bạn truy cập vào codec
trên khe 2 của thẻ 0, chuyển /dev/snd/hwC0D2 sang thẻ đầu tiên
lập luận, điển hình.  (Tuy nhiên, tên đường dẫn thực sự phụ thuộc vào
hệ thống.)

Tham số thứ hai là id số widget để truy cập.  thứ ba
tham số có thể là số hex/chữ số hoặc chuỗi tương ứng
tới một động từ.  Tương tự, tham số cuối cùng là giá trị cần ghi, hoặc
có thể là một chuỗi cho loại tham số.

::

% hda-động từ /dev/snd/hwC0D0 0x12 0x701 2
    nid = 0x12, động từ = 0x701, param = 0x2
    giá trị = 0x0

% hda-động từ /dev/snd/hwC0D0 0x0 PARAMETERS VENDOR_ID
    nid = 0x0, động từ = 0xf00, param = 0x0
    giá trị = 0x10ec0262

% hda-verb /dev/snd/hwC0D0 2 set_a 0xb080
    nid = 0x2, động từ = 0x300, param = 0xb080
    giá trị = 0x0


Mặc dù bạn có thể đưa ra bất kỳ động từ nào với chương trình này, trạng thái trình điều khiển
sẽ không được cập nhật luôn.  Ví dụ: các giá trị âm lượng thường là
được lưu vào bộ nhớ đệm trong trình điều khiển và do đó thay đổi trực tiếp giá trị amp của widget
thông qua hda-verb sẽ không thay đổi giá trị bộ trộn.

Chương trình hda-verb hiện được bao gồm trong alsa-tools:

* git://git.alsa-project.org/alsa-tools.git

Ngoài ra, gói độc lập cũ được tìm thấy trong thư mục ftp:

* ftp://ftp.suse.com/pub/people/tiwai/misc/

Ngoài ra còn có kho lưu trữ git:

* git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/hda-verb.git

Xem tệp README trong tarball để biết thêm chi tiết về động từ hda
chương trình.


máy phân tích hda
-----------------
hda-analyzer cung cấp giao diện đồ họa để truy cập âm thanh HD thô
kiểm soát, dựa trên liên kết pyGTK2.  Đây là phiên bản mạnh mẽ hơn của
động từ hda.  Chương trình cung cấp cho bạn nội dung GUI dễ sử dụng để hiển thị
thông tin tiện ích và điều chỉnh giá trị amp, cũng như
đầu ra tương thích với proc.

Máy phân tích hda:

* ZZ0000ZZ

là một phần của kho lưu trữ alsa.git trong alsa-project.org:

* git://git.alsa-project.org/alsa.git

Mật mã
----------
Codecgraph là một chương trình tiện ích để tạo biểu đồ và trực quan hóa
kết nối nút codec của chip codec.  Nó đặc biệt hữu ích khi
bạn phân tích hoặc gỡ lỗi một codec mà không có biểu dữ liệu thích hợp.  chương trình
phân tích tệp proc codec đã cho và chuyển đổi thành SVG thông qua graphiz
chương trình.

Cây tarball và GIT được tìm thấy trên trang web tại:

* ZZ0000ZZ


hda-emu
-------
hda-emu là trình giả lập âm thanh HD.  Mục đích chính của chương trình này là
để gỡ lỗi codec âm thanh HD mà không cần phần cứng thực.  Vì vậy, nó
không mô phỏng hành vi với I/O âm thanh thực mà chỉ
loại bỏ các thay đổi đăng ký codec và các thay đổi bên trong trình điều khiển ALSA
lúc thăm dò và vận hành trình điều khiển âm thanh HD.

Chương trình yêu cầu một tệp proc codec để mô phỏng.  Nhận một tập tin Proc
cho codec đích trước hoặc chọn codec mẫu từ
bộ sưu tập codec proc trong tarball.  Sau đó chạy chương trình với
proc và chương trình hda-emu sẽ bắt đầu phân tích tệp codec
và mô phỏng trình điều khiển âm thanh HD:

::

% codec hda-emu/stac9200-dell-d820-laptop
    # Parsing..
    hda_codec: Model không xác định cho STAC9200, sử dụng mặc định BIOS
    hda_codec: pin nid 08 cấu hình pin bios 40c003fa
    ....


Chương trình chỉ cung cấp cho bạn một giao diện dòng lệnh rất ngu ngốc.  bạn
có thể nhận kết xuất tệp proc ở trạng thái hiện tại, nhận danh sách kiểm soát
(bộ trộn), đặt/lấy giá trị phần tử điều khiển, mô phỏng PCM
hoạt động, mô phỏng cắm jack, v.v.

Chương trình được tìm thấy trong kho git bên dưới:

* git://git.kernel.org/pub/scm/linux/kernel/git/tiwai/hda-emu.git

Xem tệp README trong kho để biết thêm chi tiết về hda-emu
chương trình.


hda-jack-retask
---------------
hda-jack-retask là một chương trình GUI thân thiện với người dùng để thao tác
Kiểm soát chân cắm âm thanh HD để sắp xếp lại giắc cắm.  Nếu bạn có vấn đề về
nhiệm vụ jack, hãy thử chương trình này và kiểm tra xem bạn có thể nhận được
kết quả hữu ích.  Một khi bạn tìm ra cách gán pin thích hợp,
nó có thể được sửa trong mã trình điều khiển một cách tĩnh hoặc thông qua việc chuyển một
tập tin vá lỗi chương trình cơ sở (xem phần "Vá lỗi sớm").

Chương trình hiện được bao gồm trong alsa-tools:

* git://git.alsa-project.org/alsa-tools.git
