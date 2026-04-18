.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/ehci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Trình điều khiển EHCI
=====================

27-12-2002

Trình điều khiển EHCI được sử dụng để giao tiếp với các thiết bị USB 2.0 tốc độ cao bằng cách sử dụng
Phần cứng bộ điều khiển máy chủ có khả năng USB 2.0.  Tiêu chuẩn USB 2.0 là
tương thích với tiêu chuẩn USB 1.1. Nó xác định ba tốc độ truyền:

- "Tốc độ cao" 480 Mbit/giây (60 MByte/giây)
    - "Tốc độ tối đa" 12 Mbit/giây (1,5 MByte/giây)
    - "Tốc độ thấp" 1,5 Mbit/giây

USB 1.1 chỉ xử lý tốc độ tối đa và tốc độ thấp.  Thiết bị tốc độ cao
có thể được sử dụng trên các hệ thống USB 1.1, nhưng chúng làm chậm tốc độ USB 1.1.

Các thiết bị USB 1.1 cũng có thể được sử dụng trên hệ thống USB 2.0.  Khi cắm
vào bộ điều khiển EHCI, chúng được trao cho "người bạn đồng hành" USB 1.1
bộ điều khiển, là bộ điều khiển OHCI hoặc UHCI thường được sử dụng với
những thiết bị như vậy.  Khi các thiết bị USB 1.1 cắm vào hub USB 2.0, chúng sẽ
tương tác với bộ điều khiển EHCI thông qua "Trình dịch giao dịch"
(TT) trong trung tâm, biến các giao dịch tốc độ thấp hoặc tốc độ tối đa thành
"giao dịch phân chia" tốc độ cao không lãng phí băng thông truyền tải.

Tại thời điểm viết bài này, người ta đã thấy trình điều khiển này hoạt động với các triển khai
của EHCI từ (theo thứ tự bảng chữ cái): Intel, NEC, Philips và VIA.
Các triển khai EHCI khác đang có sẵn từ các nhà cung cấp khác;
bạn cũng nên mong đợi trình điều khiển này hoạt động với họ.

Trong khi các thiết bị lưu trữ USB đã có từ giữa năm 2001 (hoạt động
khá nhanh trên phiên bản 2.4 của trình điều khiển này), các trung tâm chỉ có
đã có từ cuối năm 2001 và các loại thiết bị tốc độ cao khác
dường như đang bị trì hoãn cho đến khi có nhiều hệ thống hơn được tích hợp sẵn USB 2.0.
Những hệ thống mới như vậy đã có từ đầu năm 2002 và trở nên phổ biến.
điển hình hơn vào nửa cuối năm 2002.

Lưu ý rằng hỗ trợ USB 2.0 không chỉ liên quan đến EHCI.  Nó đòi hỏi
những thay đổi khác đối với API lõi Linux-USB, bao gồm trình điều khiển trung tâm,
nhưng những thay đổi đó không thực sự cần thiết để thay đổi "usbcore" cơ bản
API tiếp xúc với trình điều khiển thiết bị USB.

- David Brownell
  <dbronell@users.sourceforge.net>


Chức năng
=============

Trình điều khiển này được kiểm tra thường xuyên trên phần cứng x86 và cũng đã được
được sử dụng trên phần cứng PPC nên các vấn đề về tuổi thọ lớn/nhỏ sẽ không còn nữa.
Người ta tin rằng nó có thể thực hiện tất cả các phép thuật phù hợp của PCI để I/O hoạt động ngay cả trên
các hệ thống có vấn đề ánh xạ DMA thú vị.

Các loại chuyển khoản
--------------

Tại thời điểm viết bài này, người lái xe phải thoải mái xử lý mọi điều khiển, số lượng lớn,
và truyền gián đoạn, bao gồm các yêu cầu tới các thiết bị USB 1.1 thông qua
bộ dịch giao dịch (TT) trong các trung tâm USB 2.0.  Nhưng bạn có thể tìm thấy lỗi.

Hỗ trợ truyền đồng bộ tốc độ cao (ISO) cũng có chức năng, nhưng
tại thời điểm viết bài này, chưa có trình điều khiển Linux nào sử dụng hỗ trợ đó.

Hỗ trợ chuyển giao đồng bộ tốc độ tối đa, thông qua các trình dịch giao dịch,
vẫn chưa có sẵn.  Lưu ý rằng hỗ trợ giao dịch chia nhỏ cho ISO
chuyển khoản không thể chia sẻ nhiều mã với mã chuyển ISO tốc độ cao,
vì EHCI thể hiện những thứ này bằng cấu trúc dữ liệu khác.  Vậy bây giờ,
hầu hết các thiết bị âm thanh và video USB không thể kết nối với xe buýt tốc độ cao.

Hành vi của người lái xe
---------------

Chuyển tất cả các loại có thể được xếp hàng đợi.  Điều này có nghĩa là việc chuyển giao quyền kiểm soát
từ trình điều khiển trên một giao diện (hoặc thông qua usbfs) sẽ không can thiệp vào
những cái này từ trình điều khiển khác và việc truyền ngắt đó có thể sử dụng dấu chấm
của một khung hình mà không gặp rủi ro mất dữ liệu do chi phí xử lý bị gián đoạn.

Mã trung tâm gốc EHCI chuyển giao các thiết bị USB 1.1 cho người bạn đồng hành của nó
bộ điều khiển.  Người lái xe này không cần biết gì về những điều đó
trình điều khiển; trình điều khiển OHCI hoặc UHCI đã hoạt động thì không cần thay đổi
chỉ vì trình điều khiển EHCI cũng có mặt.

Có một số vấn đề với việc quản lý nguồn điện; tạm dừng/tiếp tục không
cư xử khá đúng lúc này.

Ngoài ra, một số phím tắt đã được thực hiện với việc lập kế hoạch định kỳ
giao dịch (ngắt và chuyển giao đẳng thời).  Những nơi này một số
giới hạn về số lượng giao dịch định kỳ có thể được lên lịch,
và ngăn chặn việc sử dụng khoảng thời gian thăm dò ít hơn một khung.


Sử dụng bởi
======

Giả sử bạn có bộ điều khiển EHCI (trên thẻ hoặc bo mạch chủ PCI)
và đã biên dịch trình điều khiển này dưới dạng một mô-đun, tải cái này như sau ::

# modprobe ehci-hcd

và loại bỏ nó bằng cách::

# rmmod ehci-hcd

Bạn cũng nên có trình điều khiển cho "bộ điều khiển đồng hành", chẳng hạn như
"ohci-hcd" hoặc "uhci-hcd".  Trong trường hợp có bất kỳ sự cố nào với trình điều khiển EHCI,
loại bỏ mô-đun của nó và sau đó trình điều khiển cho bộ điều khiển đồng hành đó sẽ
tiếp quản (ở tốc độ thấp hơn) tất cả các thiết bị đã được xử lý trước đó
bởi trình điều khiển EHCI.

Các tham số mô-đun (chuyển tới "modprobe") bao gồm:

log2_irq_thresh (mặc định 0):
	Log2 của độ trễ ngắt mặc định, tính bằng microframe.  Mặc định
	giá trị là 0, biểu thị 1 microframe (125 usec).  Giá trị tối đa
	là 6, biểu thị 2^6 = 64 microframe.  Điều này kiểm soát tần suất
	bộ điều khiển EHCI có thể phát ra các ngắt.

Nếu bạn đang sử dụng trình điều khiển này trên kernel 2.5 và bạn đã bật USB
hỗ trợ gỡ lỗi, bạn sẽ thấy ba tệp trong thư mục "sysfs" dành cho
bất kỳ bộ điều khiển EHCI nào:

"không đồng bộ"
		loại bỏ lịch trình không đồng bộ, được sử dụng để kiểm soát
		và chuyển khoản số lượng lớn.  Hiển thị từng qh hoạt động và qtds
		đang chờ xử lý, thường là một qtd cho mỗi đô thị.  (Nhìn nó với
		bộ lưu trữ usb thực hiện I/O đĩa; xem hàng đợi yêu cầu!)
	"định kỳ"
		hủy bỏ lịch trình định kỳ, được sử dụng để ngắt
		và chuyển giao đẳng thời.  Không hiển thị qtds.
	"đăng ký"
		hiển thị trạng thái đăng ký bộ điều khiển và

Nội dung của những tập tin đó có thể giúp xác định các vấn đề về trình điều khiển.


Trình điều khiển thiết bị không cần quan tâm liệu chúng có chạy trên EHCI hay không,
nhưng họ có thể muốn kiểm tra "usb_device->speed == USB_SPEED_HIGH".
Các thiết bị tốc độ cao có thể làm những việc mà tốc độ tối đa (hoặc tốc độ thấp)
không thể, chẳng hạn như truyền định kỳ (ngắt hoặc ISO) "băng thông cao".
Ngoài ra, một số giá trị trong bộ mô tả thiết bị (chẳng hạn như khoảng thời gian bỏ phiếu cho
chuyển định kỳ) sử dụng các bảng mã khác nhau khi hoạt động ở tốc độ cao.

Tuy nhiên, hãy chú ý kiểm tra trình điều khiển thiết bị thông qua các trung tâm USB 2.0.
Các trung tâm đó báo cáo một số lỗi, chẳng hạn như ngắt kết nối, một cách khác nhau khi
trình dịch giao dịch đang được sử dụng; một số tài xế đã được nhìn thấy cư xử
thật tệ khi họ thấy các lỗi khác với báo cáo OHCI hoặc UHCI.


Hiệu suất
===========

Thông lượng USB 2.0 được kiểm soát bởi hai yếu tố chính: tốc độ của máy chủ
bộ điều khiển có thể xử lý các yêu cầu và tốc độ các thiết bị có thể phản hồi
họ.  "Tốc độ truyền thô" 480 Mbit/giây được tuân thủ bởi tất cả các thiết bị,
nhưng thông lượng tổng hợp cũng bị ảnh hưởng bởi các vấn đề như sự chậm trễ giữa
các gói tốc độ cao riêng lẻ, trí thông minh của trình điều khiển và tất nhiên là
tải tổng thể của hệ thống.  Độ trễ cũng là một mối quan tâm về hiệu suất.

Chuyển khoản số lượng lớn thường được sử dụng khi thông lượng là một vấn đề.  Đó là
cần lưu ý rằng việc chuyển số lượng lớn luôn ở dạng gói 512 byte,
và tối đa 13 trong số đó vừa với một microframe USB 2.0.  Tám USB 2.0
microframe vừa với khung USB 1.1; một microframe là 1 mili giây/8 = 125 usec.

Vì vậy, hơn 50 MByte/giây có sẵn để truyền số lượng lớn, khi cả hai
phần cứng và phần mềm điều khiển thiết bị cho phép điều đó.  Chế độ chuyển định kỳ
(đẳng thời gian và ngắt) cho phép kích thước gói lớn hơn cho phép bạn
đạt đến tốc độ truyền 480 MBit/giây được trích dẫn.

Hiệu suất phần cứng
--------------------

Tại thời điểm viết bài này, các thiết bị USB 2.0 riêng lẻ có xu hướng hoạt động tối đa ở khoảng
Tốc độ truyền 20 MByte/giây.  Tất nhiên điều này có thể thay đổi;
và một số thiết bị hiện hoạt động nhanh hơn, trong khi những thiết bị khác hoạt động chậm hơn.

Việc triển khai NEC đầu tiên của EHCI dường như có một nút cổ chai về phần cứng
với tốc độ truyền tổng hợp khoảng 28 MByte/giây.  Trong khi điều này rõ ràng
đủ cho một thiết bị ở tốc độ 20 MByte/giây, đặt ba thiết bị như vậy
lên một chiếc xe buýt không giúp bạn có được 60 MByte/giây.  Vấn đề dường như là
rằng phần cứng bộ điều khiển sẽ không thực hiện truy cập USB và PCI đồng thời,
nên nó chỉ thử sáu (hoặc có thể là bảy) giao dịch USB mỗi giao dịch
microframe chứ không phải là mười ba.  (Có vẻ như một sự đánh đổi hợp lý
cho một sản phẩm đánh bại tất cả những sản phẩm khác trên thị trường trong hơn một năm!)

Người ta hy vọng rằng các triển khai mới hơn sẽ cải thiện điều này, ném
nhiều bất động sản silicon hơn ở vấn đề để chip bo mạch chủ mới
các bộ sẽ tiến gần hơn đến mục tiêu 60 MByte/giây đó.  Điều đó bao gồm một
cập nhật triển khai từ NEC, cũng như silicon của các nhà cung cấp khác.

Có độ trễ tối thiểu là một microframe (125 usec) cho máy chủ
để nhận các ngắt từ bộ điều khiển EHCI cho biết đã hoàn thành
của các yêu cầu.  Độ trễ đó có thể điều chỉnh được; có một tùy chọn mô-đun.  Bởi
trình điều khiển ehci-hcd mặc định sử dụng độ trễ tối thiểu, có nghĩa là nếu
bạn đưa ra yêu cầu kiểm soát hoặc hàng loạt mà bạn thường có thể mong đợi biết được điều đó
nó hoàn thành trong chưa đầy 250 usec (tùy thuộc vào kích thước truyền).

Hiệu suất phần mềm
--------------------

Để đạt được tốc độ truyền thậm chí 20 MByte/giây, trình điều khiển thiết bị Linux-USB sẽ
cần giữ hàng đợi EHCI luôn đầy.  Điều đó có nghĩa là đưa ra những yêu cầu lớn,
hoặc sử dụng hàng đợi hàng loạt nếu cần đưa ra một loạt yêu cầu nhỏ.
Khi người lái xe không làm điều đó, kết quả hoạt động của họ sẽ thể hiện điều đó.

Trong các tình huống điển hình, vòng lặp usb_bulk_msg() ghi ra các đoạn 4 KB là
sẽ lãng phí hơn một nửa băng thông USB 2.0.  Độ trễ giữa
Quá trình hoàn thành I/O và trình điều khiển đưa ra yêu cầu tiếp theo sẽ mất nhiều thời gian hơn
hơn I/O.  Nếu vòng lặp tương tự đó sử dụng các đoạn 16 KB thì sẽ tốt hơn; một
chuỗi khối 128 KB sẽ lãng phí ít hơn rất nhiều.

Nhưng thay vì phụ thuộc vào bộ đệm I/O lớn như vậy để thực hiện đồng bộ
I/O hiệu quả, tốt hơn là chỉ xếp hàng một số yêu cầu (hàng loạt)
tới HC và đợi tất cả chúng hoàn tất (hoặc bị hủy do nhầm lẫn).
Việc xếp hàng URB như vậy cũng sẽ hoạt động với tất cả các trình điều khiển USB 1.1 HC.

Trong nhân Linux 2.5, các lệnh gọi api usb_sg_*() mới đã được xác định; họ
xếp hàng tất cả các bộ đệm từ danh sách phân tán.  Họ cũng sử dụng danh sách phân tán DMA
ánh xạ (có thể áp dụng IOMMU) và giảm IRQ, tất cả đều sẽ
giúp truyền tốc độ cao chạy nhanh nhất có thể.


TBD:
   Các vấn đề về hiệu suất truyền gián đoạn và ISO.  Những định kỳ đó
   việc chuyển tiền đã được lên lịch đầy đủ nên vấn đề chính có thể là làm thế nào
   để kích hoạt chế độ "băng thông cao".

TBD:
   Có thể phân bổ băng thông định kỳ nhiều hơn 80% tiêu chuẩn
   thông qua tham số sysfs uframe_ Periodic_max. Hãy mô tả điều đó.
