.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/abituguru-datasheet.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
bảng dữ liệu uGuru
===============

Trước hết, những gì tôi biết về uGuru không phải là sự thật dựa trên bất kỳ trợ giúp, gợi ý hay
bảng dữ liệu từ Abit. Dữ liệu tôi có trên uGuru được tôi tập hợp thông qua
kiến thức yếu kém của tôi về "kỹ thuật ngược".
Và để ghi lại, bạn có thể nhận thấy uGuru không phải là con chip được phát triển bởi
Abit, như họ tuyên bố. Nó thực sự chỉ là một bộ vi xử lý (uC) được tạo bởi
Winbond (W83L950D). Và không, đọc hướng dẫn sử dụng cho uC cụ thể này hoặc
gửi thư cho Winbond để được trợ giúp sẽ không cung cấp bất kỳ dữ liệu hữu ích nào về uGuru, vì nó vốn là như vậy
chương trình bên trong uC đang đáp ứng các cuộc gọi.

Olle Sandberg <ollebull@gmail.com>, 25-05-2005


Phiên bản gốc của Olle Sandberg, người đã thực hiện phần lớn công việc ban đầu
kỹ thuật đảo ngược. Phiên bản này đã được viết lại gần như hoàn toàn cho rõ ràng
và được mở rộng với hỗ trợ ghi và thông tin về nhiều ngân hàng dữ liệu hơn, hỗ trợ ghi
một lần nữa được thiết kế ngược bởi Olle, các ngân hàng dữ liệu bổ sung đã được
được thiết kế ngược lại bởi tôi. Tôi muốn gửi lời cảm ơn tới Olle, điều này
tài liệu và trình điều khiển Linux không thể được viết nếu không có nỗ lực của anh ấy.

Lưu ý: do thiếu thông số kỹ thuật nên chỉ có phần cảm biến của uGuru là
được mô tả ở đây chứ không phải điều khiển điện áp và tần số CPU / RAM / etc.

Hans de Goede <j.w.r.degoede@hhs.nl>, 28-01-2006


Phát hiện
=========

Theo như những gì được biết, uGuru luôn được đặt tại và sử dụng các cổng I/O (ISA)
0xE0 và 0xE4, vì vậy chúng tôi không phải quét bất kỳ phạm vi cổng nào, chỉ cần kiểm tra xem hai cổng đó là gì
cổng đang giữ để phát hiện. Chúng tôi sẽ gọi 0xE0 là CMD (cổng lệnh)
và 0xE4 là DATA vì Abit gọi chúng bằng những tên này.

Nếu DATA giữ 0x00 hoặc 0x08 và CMD giữ 0x00 hoặc 0xAC thì uGuru có thể
hiện tại. Chúng tôi phải kiểm tra hai giá trị khác nhau tại cổng dữ liệu, bởi vì
sau khi khởi động lại, uGuru sẽ giữ 0x00 ở đây, nhưng nếu trình điều khiển bị xóa và
sau này, cổng dữ liệu được gắn lại sẽ giữ 0x08, sẽ nói thêm về điều này sau.

Sau khi thử nghiệm rộng rãi hơn trình điều khiển nhân Linux, một số biến thể của uGuru đã có
được bật lên sẽ giữ 0x00 thay vì 0xAC tại cổng CMD, do đó chúng tôi cũng
phải kiểm tra CMD để tìm hai giá trị khác nhau. Trên DATA của uGuru này ban đầu sẽ
giữ 0x09 và sẽ chỉ giữ 0x08 sau khi đọc CMD trước, vì vậy phải đọc CMD
đầu tiên!

Để thực sự chắc chắn rằng có uGuru, hãy đọc thử một hoặc nhiều đăng ký
bộ nên được thực hiện.


Đọc / Viết
=================

Địa chỉ
----------

uGuru có một số cấp địa chỉ khác nhau. Địa chỉ đầu tiên
cấp độ chúng tôi sẽ gọi là ngân hàng. Một ngân hàng lưu giữ dữ liệu cho một hoặc nhiều cảm biến. Dữ liệu
trong ngân hàng dành cho cảm biến có kích thước bằng một hoặc nhiều byte.

Số byte được cố định cho một ngân hàng nhất định, bạn phải luôn đọc hoặc ghi
nhiều byte thì đọc/ghi nhiều sẽ bị lỗi, kết quả khi ghi
ít hơn thì số byte cho một ngân hàng nhất định không được xác định.

Xem bên dưới để biết tất cả các địa chỉ ngân hàng đã biết, số lượng cảm biến trong ngân hàng đó,
số byte dữ liệu trên mỗi cảm biến và nội dung/ý nghĩa của các byte đó.

Mặc dù cả tài liệu này và trình điều khiển kernel đều giữ nguyên cảm biến
thuật ngữ để đánh địa chỉ trong ngân hàng, điều này không chính xác 100%, trong
ngân hàng 0x24 chẳng hạn, địa chỉ trong ngân hàng chọn đầu ra PWM không
một cảm biến.

Lưu ý rằng một số ngân hàng có cả địa chỉ đọc và địa chỉ ghi, đây là cách
uGuru xác định xem việc đọc hoặc ghi vào ngân hàng có đang diễn ra hay không, do đó
khi đọc bạn nên luôn sử dụng địa chỉ đọc và khi viết địa chỉ
viết địa chỉ. Địa chỉ ghi luôn nhiều hơn một (1) địa chỉ đọc.


uGuru đã sẵn sàng
-----------

Trước khi bạn có thể đọc hoặc viết vào uGuru, trước tiên bạn phải đặt uGuru
ở chế độ "sẵn sàng".

Để đặt uGuru ở chế độ sẵn sàng, trước tiên hãy viết 0x00 vào DATA và sau đó đợi DATA
để giữ 0x09, DATA phải đọc 0x09 trong vòng 250 chu kỳ đọc.

CMD tiếp theo _phải_ được đọc và phải giữ 0xAC, thông thường CMD sẽ giữ 0xAC
đọc lần đầu nhưng đôi khi phải mất một lúc trước khi CMD giữ 0xAC và do đó nó
phải được đọc nhiều lần (tối đa 50).

Sau khi đọc CMD, DATA sẽ giữ 0x08, điều đó có nghĩa là uGuru đã sẵn sàng
cho đầu vào. Như trên DATA thường sẽ giữ 0x08 trong lần đọc đầu tiên nhưng không phải lúc nào cũng vậy.
Bước này có thể được bỏ qua, nhưng vẫn chưa xác định được điều gì sẽ xảy ra nếu uGuru có
chưa báo 0x08 tại DATA và bạn tiến hành ghi địa chỉ ngân hàng.


Gửi địa chỉ ngân hàng và cảm biến tới uGuru
----------------------------------------------

Đầu tiên uGuru phải ở chế độ "sẵn sàng" như mô tả ở trên, DATA phải giữ
0x08 cho biết uGuru muốn đầu vào, trong trường hợp này là địa chỉ ngân hàng.

Tiếp theo ghi địa chỉ ngân hàng vào DATA. Sau khi ghi địa chỉ ngân hàng
đợi DATA giữ lại 0x08 cho biết rằng nó muốn/sẵn sàng cho
nhiều đầu vào hơn (tối đa 250 lần đọc).

Khi DATA giữ 0x08, hãy ghi lại địa chỉ cảm biến vào CMD.


Đọc
-------

Đầu tiên hãy gửi ngân hàng và địa chỉ cảm biến như mô tả ở trên.
Sau đó, với mỗi byte dữ liệu bạn muốn đọc, hãy đợi DATA giữ 0x01
cho biết uGuru đã sẵn sàng để đọc (tối đa 250 lần đọc) và một lần
DATA giữ 0x01 đọc byte từ CMD.

Khi tất cả byte đã được đọc, dữ liệu sẽ giữ 0x09, nhưng không có lý do gì để
kiểm tra cho việc này. Lưu ý rằng số byte phụ thuộc vào địa chỉ ngân hàng, xem
trên và dưới.

Sau khi hoàn thành quá trình đọc thành công, bạn nên đặt uGuru trở lại
chế độ sẵn sàng, để nó sẵn sàng cho chu kỳ đọc/ghi tiếp theo. Lối này
nếu chương trình/trình điều khiển của bạn được tải xuống và sau đó được tải lại thì phát hiện
thuật toán được mô tả ở trên sẽ vẫn hoạt động.



Viết
-------

Đầu tiên hãy gửi ngân hàng và địa chỉ cảm biến như mô tả ở trên.
Sau đó, với mỗi byte dữ liệu bạn muốn ghi, hãy đợi DATA giữ 0x00
cho biết uGuru đã sẵn sàng để viết (tối đa 250 lần đọc) và
khi DATA giữ 0x00, hãy ghi byte vào CMD.

Khi tất cả các byte đã được ghi, hãy đợi DATA giữ 0x01 (tối đa 250 lần đọc)
đừng hỏi tại sao lại như vậy.

Khi DATA giữ 0x01, hãy đọc CMD, bây giờ nó sẽ giữ 0xAC.

Sau khi hoàn thành việc viết thành công, bạn nên đặt uGuru trở lại
chế độ sẵn sàng, để nó sẵn sàng cho chu kỳ đọc/ghi tiếp theo. Lối này
nếu chương trình/trình điều khiển của bạn được tải xuống và sau đó được tải lại thì phát hiện
thuật toán được mô tả ở trên sẽ vẫn hoạt động.


vấn đề
-------

Sau khi thử nghiệm rộng rãi hơn trình điều khiển nhân Linux, một số biến thể của uGuru đã có
được bật lên không giữ 0x08 tại DATA trong vòng 250 lần đọc sau khi viết
địa chỉ ngân hàng. Với những phiên bản này điều này xảy ra khá thường xuyên, sử dụng lớn hơn
thời gian chờ không giúp ích gì, họ chỉ ngoại tuyến trong một hoặc hai giây, thực hiện một số thao tác
hiệu chuẩn nội bộ hoặc bất cứ điều gì. Mã của bạn nên được chuẩn bị để xử lý
điều này và trong trường hợp không có phản hồi trong trường hợp cụ thể này, chỉ cần đi ngủ một lát
một lúc rồi thử lại.


Bản đồ địa chỉ
===========

Báo động ngân hàng 0x20 (R)
--------------------
Ngân hàng này chứa 0 cảm biến, địa chỉ cảm biến sẽ bị bỏ qua (nhưng phải được
đã viết) chỉ cần sử dụng 0. Ngân hàng 0x20 chứa 3 byte:

Byte 0:
  Byte này giữ các cờ cảnh báo cho cảm biến 0-7 của Ngân hàng cảm biến1, với bit 0
  tương ứng với cảm biến 0, 1 đến 1, v.v.

Byte 1:
  Byte này chứa các cờ cảnh báo cho cảm biến 8-15 của Ngân hàng cảm biến1, với bit 0
  tương ứng với cảm biến 8, 1 đến 9, v.v.

Byte 2:
  Byte này chứa các cờ cảnh báo cho cảm biến 0-5 của Sensor Bank2, với bit 0
  tương ứng với cảm biến 0, 1 đến 1, v.v.


Giá trị cảm biến Bank 0x21 / Số đọc (R)
--------------------------------------------
Ngân hàng này chứa 16 cảm biến, mỗi cảm biến chứa 1 byte.
Cho đến nay, các cảm biến sau đây được biết là có sẵn trên tất cả các bo mạch chủ:

- Cảm biến nhiệt độ 0 CPU
- Cảm biến nhiệt độ 1 SYS
- Cảm biến 3 lõi volt CPU
- Cảm biến 4V DDR
- Cảm biến 10 DDR Vtt volt
- Cảm biến nhiệt độ 15 PWM

Byte 0:
  Byte này giữ việc đọc từ cảm biến. Cảm biến trong Bank1 có thể là cả hai
  cảm biến volt và nhiệt độ, đây là cảm biến dành riêng cho bo mạch chủ. Tuy nhiên uGuru thì có
  dường như biết (được lập trình với) loại cảm biến nào được gắn vào, xem Cảm biến
  Mô tả cài đặt Bank1.

Cảm biến volt sử dụng thang đo tuyến tính, giá trị 0 tương ứng với 0 volt và
số đọc là 255 với 3494 mV. Tuy nhiên, các cảm biến cho điện áp cao hơn là
được kết nối thông qua một mạch phân chia. Các mạch phân chia đã biết hiện nay
khi sử dụng cho kết quả trong phạm vi: 0-4361mV, 0-6248mV hoặc 0-14510mV. nguồn 3,3 volt
sử dụng phạm vi 0-4361mV, 5 volt ở 0-6248mV và 12 volt ở 0-14510mV.

Cảm biến nhiệt độ cũng sử dụng thang đo tuyến tính, số đọc 0 tương ứng với 0 độ
độ C và số đọc là 255 với số đọc là 255 độ C.


Cài đặt Ngân hàng Cảm biến 0x22 Ngân hàng1 (R) và Cài đặt Ngân hàng Cảm biến Ngân hàng 0x231 (W)
---------------------------------------------------------------------------

Các ngân hàng đó chứa 16 cảm biến, mỗi cảm biến chứa 3 byte. Mỗi
bộ 3 byte chứa các cài đặt cho cảm biến có cùng cảm biến
địa chỉ trong Ngân hàng 0x21 .

Byte 0:
  Hành vi cảnh báo cho cảm biến đã chọn. A 1 cho phép mô tả
  hành vi.

Bit 0:
  Đưa ra cảnh báo nếu nhiệt độ đo được vượt quá ngưỡng cảnh báo (RW) [1]_

Bit 1:
  Đưa ra cảnh báo nếu điện áp đo được vượt quá ngưỡng tối đa (RW) [2]_

Bit 2:
  Đưa ra cảnh báo nếu điện áp đo được nằm dưới ngưỡng tối thiểu (RW) [2]_

Bit 3:
  Tiếng bíp nếu báo động (RW)

Bit 4:
  1 nếu cảnh báo khiến nhiệt độ đo được vượt quá ngưỡng cảnh báo (R)

Bit 5:
  1 nếu cảnh báo khiến điện áp đo được vượt quá ngưỡng tối đa (R)

Bit 6:
  1 nếu cảnh báo gây ra điện áp đo được dưới ngưỡng tối thiểu (R)

Bit 7:
  - Cảm biến Volt: Tắt máy nếu báo động kéo dài hơn 4 giây (RW)
  - Cảm biến nhiệt độ: Tắt máy nếu nhiệt độ vượt quá ngưỡng tắt máy (RW)

.. [1] This bit is only honored/used by the uGuru if a temp sensor is connected

.. [2] This bit is only honored/used by the uGuru if a volt sensor is connected
       Note with some trickery this can be used to find out what kinda sensor
       is detected see the Linux kernel driver for an example with many
       comments on how todo this.

Byte 1:
  - Cảm biến nhiệt độ: ngưỡng cảnh báo (tỷ lệ như ngân hàng 0x21)
  - Cảm biến Volt: ngưỡng tối thiểu (tỷ lệ như ngân hàng 0x21)

Byte 2:
  - Cảm biến nhiệt độ: ngưỡng tắt máy (tỷ lệ như ngân hàng 0x21)
  - Cảm biến Volt: ngưỡng tối đa (tỷ lệ như ngân hàng 0x21)


Đầu ra Bank 0x24 PWM cho đầu ra FAN (R) và Bank 0x25 PWM cho FAN (W)
---------------------------------------------------------------------------

Các ngân hàng đó chứa 3 "cảm biến", mỗi cảm biến chứa 5 byte.
  - Cảm biến 0 thường điều khiển quạt CPU
  - Cảm biến 1 thường điều khiển quạt NB (hoặc chipset cho chip đơn)
  - Cảm biến 2 thường điều khiển quạt hệ thống

Byte 0:
  Gắn cờ 0x80 để bật điều khiển, Quạt chạy ở mức 100% khi bị tắt.
  địa chỉ cảm biến nibble (nhiệt độ) thấp tại ngân hàng 0x21 được sử dụng để điều khiển.

Byte 1:
  0-255 = 0-12v (tuyến tính), chỉ định điện áp mà quạt sẽ quay khi ở mức thấp
  nhiệt độ ngưỡng thấp (được chỉ định bằng byte 3)

Byte 2:
  0-255 = 0-12v (tuyến tính), chỉ định điện áp mà quạt sẽ quay khi ở trên
  nhiệt độ ngưỡng cao (được chỉ định ở byte 4)

Byte 3:
  Nhiệt độ ngưỡng thấp (tỷ lệ như ngân hàng 0x21)

byte 4:
  Nhiệt độ ngưỡng cao (tỷ lệ như ngân hàng 0x21)


Cảm biến Ngân hàng 0x26 Giá trị / Số đọc Ngân hàng2 (R)
---------------------------------------------

Ngân hàng này chứa 6 cảm biến (AFAIK), mỗi cảm biến chứa 1 byte.

Cho đến nay, các cảm biến sau đây được biết là có sẵn trên tất cả các bo mạch chủ:
  - Cảm biến 0: Tốc độ quạt CPU
  - Cảm biến 1: Tốc độ quạt NB (hoặc chipset dành cho chip đơn)
  - Cảm biến 2: Tốc độ quạt SYS

Byte 0:
  Byte này giữ việc đọc từ cảm biến. 0-255 = 0-15300 (tuyến tính)


Bộ cảm biến Bank 0x27 Cài đặt Bank2 (R) và Bộ cảm biến Bank 0x28 Cài đặt Bank2 (W)
-----------------------------------------------------------------------------

Các ngân hàng đó chứa 6 cảm biến (AFAIK), mỗi cảm biến chứa 2 byte.

Byte 0:
  Hành vi cảnh báo cho cảm biến đã chọn. A 1 cho phép hành vi được mô tả.

Bit 0:
  Đưa ra cảnh báo nếu vòng tua đo được dưới ngưỡng tối thiểu (RW)

Bit 3:
  Tiếng bíp nếu báo động (RW)

Bit 7:
  Tắt máy nếu báo động kéo dài hơn 4 giây (RW)

Byte 1:
  ngưỡng tối thiểu (tỷ lệ như ngân hàng 0x26)


Cảnh báo cho người ưa mạo hiểm
===========================

Một lời cảnh báo cho những ai muốn thử nghiệm và xem liệu họ có thể tìm ra
điện áp/đồng hồ lập trình ra, tôi thử đọc và chỉ đọc ngân hàng
0-0x30 với mã đọc được sử dụng cho dãy cảm biến (0x20-0x28) và mã này
dẫn đến việc lập trình lại _vĩnh viễn_ các điện áp, may mắn là tôi đã có
phần cảm biến được cấu hình để nó có thể tắt hệ thống của tôi khi không có thông số kỹ thuật
điện áp có thể đã bảo vệ máy tính của tôi (sau khi khởi động lại, tôi đã cố gắng
ngay lập tức nhập bios và tải lại mặc định). Điều này có lẽ có nghĩa là
chu kỳ đọc/ghi của phần không có cảm biến khác với phần có cảm biến.
