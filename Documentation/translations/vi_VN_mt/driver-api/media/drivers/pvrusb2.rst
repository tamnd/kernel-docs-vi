.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/pvrusb2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển pvrusb2
========================

Tác giả: Mike Isely <isely@pobox.com>

Lý lịch
----------

Trình điều khiển này dành cho "Hauppauge WinTV PVR USB 2.0",
là Bộ điều chỉnh TV được lưu trữ trên máy USB 2.0.  Trình điều khiển này là một công việc đang được tiến hành.
Lịch sử của nó bắt đầu với nỗ lực kỹ thuật đảo ngược của Björn
Danielsson <pvrusb2@dax.nu> có thể tìm thấy trang web của ông ở đây:
ZZ0000ZZ

Từ đó Aurelien Allaume <slts@free.fr> bắt đầu nỗ lực
tạo trình điều khiển tương thích video4linux.  Tôi bắt đầu với Aurelien
ảnh chụp nhanh được biết đến lần cuối và phát triển trình điều khiển về trạng thái hiện tại
ở đây.

Thông tin thêm về trình điều khiển này có thể được tìm thấy tại:
ZZ0000ZZ


Trình điều khiển này có sự tách lớp mạnh mẽ.  Họ rất
đại khái:

1. Triển khai giao thức dây ở mức độ thấp với thiết bị.

2. Triển khai bộ chuyển đổi I2C và trình điều khiển máy khách I2C tương ứng
   được triển khai ở nơi khác trong V4L.

3. Triển khai trình điều khiển phần cứng cấp cao phối hợp tất cả
   các hoạt động đảm bảo hoạt động chính xác của thiết bị.

4. Lớp "ngữ cảnh" quản lý việc khởi tạo trình điều khiển, thiết lập,
   phá bỏ, phân xử và tương tác với cấp cao
   giao diện phù hợp khi các thiết bị được cắm nóng vào
   hệ thống.

5. Giao diện cấp cao gắn kết trình điều khiển với nhiều loại được xuất bản
   API Linux (V4L, sysfs, có thể là DVB trong tương lai).

Lớp cắt quan trọng nhất nằm giữa 2 lớp trên cùng.  A
trình điều khiển đã phải làm rất nhiều việc để đảm bảo rằng bất kỳ loại
API có thể tưởng tượng được có thể được đặt trên trình điều khiển cốt lõi.  (Vâng,
trình điều khiển tận dụng nội bộ V4L để thực hiện công việc của nó nhưng điều đó thực sự có
không liên quan gì đến API do driver công bố ra bên ngoài
world.) Kiến trúc cho phép các API khác nhau
đồng thời truy cập trình điều khiển.  Tôi có ý thức mạnh mẽ về sự công bằng
về API và cũng cảm thấy rằng đó là một nguyên tắc thiết kế tốt cần tuân thủ
thực hiện và giao diện tách biệt với nhau.  Như vậy trong khi
hiện tại giao diện cấp cao V4L là đầy đủ nhất,
giao diện cấp cao của sysfs sẽ hoạt động tốt như nhau cho các ứng dụng tương tự
hoạt động tốt, và không có lý do gì mà ngay bây giờ tôi thấy tại sao nó không nên như vậy
có thể tạo ra giao diện cấp cao DVB có thể ngồi đúng
cùng với V4L.

Xây dựng
--------

Để xây dựng các mô-đun này về cơ bản chỉ cần chạy "Tạo",
nhưng bạn cần cây nguồn kernel ở gần và có thể bạn cũng sẽ
muốn đặt một vài biến môi trường kiểm soát trước theo thứ tự
để liên kết mọi thứ với cây nguồn đó.  Vui lòng xem Makefile
ở đây để nhận xét giải thích cách thực hiện điều đó.

Danh sách tập tin nguồn/tổng ​​quan về chức năng
------------------------------------------------

(Lưu ý: Thuật ngữ "mô-đun" được sử dụng dưới đây thường đề cập đến một cách lỏng lẻo
các đơn vị chức năng được xác định trong trình điều khiển pvrusb2 và không có
liên quan đến khái niệm mô-đun có thể tải của nhân Linux.)

pvrusb2-audio.[ch] - Đây là logic gắn kết nằm giữa điều này
    trình điều khiển và trình điều khiển máy khách msp3400.ko I2C (được tìm thấy
    ở nơi khác trong V4L).

pvrusb2-context.[ch] - Mô-đun này triển khai ngữ cảnh cho một
    trường hợp của người lái xe.  Mọi thứ khác cuối cùng đều gắn kết lại với nhau
    hoặc được thể hiện khác trong cấu trúc dữ liệu được triển khai
    ở đây.  Việc cắm nóng cuối cùng được phối hợp ở đây.  Tất cả đều ở cấp độ cao
    giao diện gắn vào trình điều khiển thông qua mô-đun này.  mô-đun này
    giúp phân xử quyền truy cập của mỗi giao diện vào lõi trình điều khiển thực tế,
    và được thiết kế để cho phép truy cập đồng thời thông qua nhiều
    phiên bản của nhiều giao diện (ví dụ như bạn có thể thay đổi
    tần số của bộ điều chỉnh thông qua sysfs trong khi truyền phát đồng thời
    video từ V4L đến phiên bản của mplayer).

pvrusb2-debug.h - Tiêu đề này xác định trình bao bọc printk() và mặt nạ
    định nghĩa bit gỡ lỗi cho các loại gỡ lỗi khác nhau
    thông báo có thể được kích hoạt trong trình điều khiển.

pvrusb2-debugifc.[ch] - Mô-đun này thực hiện một dòng lệnh thô
    giao diện gỡ lỗi định hướng vào trình điều khiển.  Ngoài việc là một phần
    của quy trình thực hiện trích xuất chương trình cơ sở thủ công (xem
    trang web pvrusb2 đã đề cập trước đó), có lẽ tôi là người duy nhất
    ai đã từng sử dụng cái này.  Nó chủ yếu là một trợ giúp gỡ lỗi.

pvrusb2-eeprom.[ch] - Đây là logic gắn kết nằm giữa điều này
    điều khiển mô-đun tveeprom.ko, mô-đun này được triển khai
    ở nơi khác trong V4L.

pvrusb2-encoding.[ch] - Mô-đun này thực hiện tất cả giao thức cần thiết để
    tương tác với chip mã hóa Conexant mpeg2 trong pvrusb2
    thiết bị.  Đó là tiếng vang thô thiển của logic tương ứng trong ivtv,
    tuy nhiên, mục tiêu thiết kế (cách ly nghiêm ngặt) và lớp vật lý
    (proxy thông qua USB thay vì PCI) đủ khác biệt để điều này
    việc thực hiện phải hoàn toàn khác nhau.

pvrusb2-hdw-internal.h - Tiêu đề này xác định cấu trúc dữ liệu cốt lõi
    trong trình điều khiển được sử dụng để theo dõi trạng thái bên trong ALL liên quan đến điều khiển
    của phần cứng.  Không ai ngoài việc xử lý phần cứng cốt lõi
    các mô-đun nên có bất kỳ doanh nghiệp nào sử dụng tiêu đề này.  Tất cả bên ngoài
    quyền truy cập vào trình điều khiển phải thông qua một trong những cấp độ cao
    các giao diện (ví dụ: V4L, sysfs, v.v.) và trên thực tế, ngay cả những giao diện cao
    giao diện cấp độ được giới hạn ở API được xác định trong
    pvrusb2-hdw.h và NOT tiêu đề này.

pvrusb2-hdw.h - Tiêu đề này xác định API nội bộ đầy đủ cho
    điều khiển phần cứng.  Giao diện cấp cao (ví dụ: V4L, sysfs)
    sẽ làm việc ở đây.

pvrusb2-hdw.c - Mô-đun này thực hiện tất cả các bit logic khác nhau
    xử lý việc kiểm soát tổng thể của một thiết bị pvrusb2 cụ thể.
    (Chính sách, khởi tạo và phân xử các thiết bị pvrusb2 không được áp dụng
    trong phạm vi quyền hạn của bối cảnh pvrusb không có ở đây).

pvrusb2-i2c-chips-\*.c - Các mô-đun này triển khai logic keo để
    liên kết với nhau và định cấu hình các mô-đun I2C khác nhau khi chúng gắn vào
    xe buýt I2C.  Có hai phiên bản của tập tin này.  "v4l2"
    phiên bản được dự định sẽ được sử dụng trên cây cùng với V4L, nơi chúng tôi
    chỉ thực hiện logic có ý nghĩa đối với V4L thuần túy
    môi trường.  Phiên bản "tất cả" được thiết kế để sử dụng bên ngoài
    V4L, nơi chúng ta có thể gặp phải các mô-đun có thể "thách thức" khác
    từ ivtv hoặc các ảnh chụp nhanh kernel cũ hơn (hoặc thậm chí các mô-đun hỗ trợ
    trong ảnh chụp nhanh độc lập).

pvrusb2-i2c-cmd-v4l1.[ch] - Mô-đun này triển khai V4L1 chung
    các lệnh tương thích với các mô-đun I2C.  Đây là nơi nhà nước
    những thay đổi bên trong trình điều khiển pvrusb2 được dịch sang V4L1
    các lệnh lần lượt được gửi đến các mô-đun I2C khác nhau.

pvrusb2-i2c-cmd-v4l2.[ch] - Mô-đun này triển khai V4L2 chung
    các lệnh tương thích với các mô-đun I2C.  Đây là nơi nhà nước
    những thay đổi bên trong trình điều khiển pvrusb2 được dịch sang V4L2
    các lệnh lần lượt được gửi đến các mô-đun I2C khác nhau.

pvrusb2-i2c-core.[ch] - Mô-đun này cung cấp cách triển khai một
    Trình điều khiển bộ điều hợp I2C thân thiện với kernel, thông qua đó các thiết bị bên ngoài khác
    Trình điều khiển máy khách I2C (ví dụ: msp3400, tuner, lirc) có thể kết nối và
    vận hành các chip tương ứng trong thiết bị pvrusb2.  Đó là
    thông qua đây mà các mô-đun V4L khác có thể tiếp cận trình điều khiển này để
    vận hành các phần cụ thể (và các mô-đun đó lần lượt được điều khiển bởi
    logic keo được điều phối bởi pvrusb2-hdw, được phân bổ bởi
    pvrusb2-context và cuối cùng được cung cấp cho người dùng
    thông qua một trong các giao diện cấp cao).

pvrusb2-io.[ch] - Mô-đun này triển khai một vòng cấp độ rất thấp của
    bộ đệm chuyển, cần thiết để truyền dữ liệu từ
    thiết bị.  Mô-đun này là ZZ0000ZZ cấp thấp.  Nó chỉ vận hành
    vùng đệm và không cố gắng xác định bất kỳ chính sách hoặc cơ chế nào cho
    bộ đệm như thế nào có thể được sử dụng.

pvrusb2-ioread.[ch] - Mô-đun này xếp chồng lên trên pvrusb2-io.[ch]
    để cung cấp một API phát trực tuyến có thể sử dụng được theo kiểu gọi hệ thống read() của
    Tôi/O.  Hiện tại đây là lớp duy nhất trên pvrusb2-io.[ch],
    tuy nhiên kiến trúc cơ bản ở đây được thiết kế để cho phép
    các kiểu I/O khác sẽ được triển khai với các mô-đun bổ sung, như
    bộ đệm mmap()'ed hoặc thứ gì đó thậm chí còn kỳ lạ hơn.

pvrusb2-main.c - Đây là cấp cao nhất của trình điều khiển.  Cấp độ mô-đun
    và các điểm vào cốt lõi của USB đều có ở đây.  Đây là "chính" của chúng tôi.

pvrusb2-sysfs.[ch] - Đây là giao diện cấp cao gắn kết
    trình điều khiển pvrusb2 vào sysfs.  Thông qua giao diện này bạn có thể làm
    mọi thứ với trình điều khiển ngoại trừ truyền dữ liệu thực sự.

pvrusb2-tuner.[ch] - Đây là logic gắn kết nằm giữa điều này
    trình điều khiển và trình điều khiển máy khách tuner.ko I2C (được tìm thấy
    ở nơi khác trong V4L).

pvrusb2-util.h - Tiêu đề này xác định một số macro phổ biến được sử dụng
    khắp người lái xe.  Các macro này không thực sự cụ thể cho
    người lái xe, nhưng họ phải đi đâu đó.

pvrusb2-v4l2.[ch] - Đây là giao diện cấp cao gắn kết
    trình điều khiển pvrusb2 vào video4linux.  Chính nhờ đây mà V4L
    các ứng dụng có thể mở và vận hành trình điều khiển trong V4L thông thường
    cách.  Lưu ý rằng chức năng ZZ0000ZZ V4L chỉ được xuất bản
    qua đây và không nơi nào khác.

pvrusb2-video-\*.[ch] - Đây là logic gắn kết nằm giữa điều này
    trình điều khiển và trình điều khiển máy khách saa711x.ko I2C (được tìm thấy
    ở nơi khác trong V4L).  Lưu ý rằng saa711x.ko từng được gọi là
    saa7115.ko trong ivtv.  Có hai phiên bản này; một là
    được chọn tùy thuộc vào saa711[5x].ko cụ thể được tìm thấy.

pvrusb2.h - Tiêu đề này chứa các tham số có thể điều chỉnh thời gian biên dịch
    (và hiện tại người lái xe có rất ít thứ cần phải
    điều chỉnh).