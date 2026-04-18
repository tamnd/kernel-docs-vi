.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/gadget.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Tiện ích USB API cho Linux
========================

:Tác giả: David Brownell
:Ngày: 20 tháng 8 năm 2004

Giới thiệu
============

Tài liệu này trình bày chế độ hạt nhân "Tiện ích" Linux-USB API, để sử dụng
trong các thiết bị ngoại vi và các thiết bị USB khác nhúng Linux. Nó cung cấp
tổng quan về cấu trúc API và cho thấy cấu trúc đó phù hợp với hệ thống như thế nào
dự án phát triển. Đây là API đầu tiên được phát hành trên Linux
giải quyết một số vấn đề quan trọng, bao gồm:

- Hỗ trợ USB 2.0, dành cho các thiết bị tốc độ cao có thể truyền dữ liệu với tốc độ
   vài chục megabyte mỗi giây.

- Xử lý các thiết bị có hàng tá điểm cuối cũng như các thiết bị có
   chỉ có hai chức năng cố định. Trình điều khiển tiện ích có thể được viết như vậy
   chúng dễ dàng chuyển sang phần cứng mới.

- Đủ linh hoạt để bộc lộ các khả năng phức tạp hơn của thiết bị USB như
   như nhiều cấu hình, nhiều giao diện, nhiều thiết bị tổng hợp,
   và cài đặt giao diện thay thế.

- Hỗ trợ USB "On-The-Go" (OTG), kết hợp với các bản cập nhật cho
   Phía máy chủ Linux-USB.

- Chia sẻ cấu trúc dữ liệu và mô hình API với phía máy chủ Linux-USB
   API. Điều này giúp hỗ trợ OTG và mong muốn có sự đối xứng hơn
   các khung (trong đó cùng một mô hình I/O được sử dụng bởi cả máy chủ và thiết bị
   trình điều khiển bên).

- Tối giản nên dễ dàng hỗ trợ phần cứng điều khiển thiết bị mới hơn.
   Xử lý I/O không ngụ ý nhu cầu lớn về bộ nhớ hoặc CPU
   tài nguyên.

Hầu hết các nhà phát triển Linux sẽ không thể sử dụng API này vì họ có
Phần cứng USB ZZ0000ZZ trong PC, máy trạm hoặc máy chủ. Người dùng Linux với
các hệ thống nhúng có nhiều khả năng có phần cứng ngoại vi USB. Đến
phân biệt các trình điều khiển chạy bên trong phần cứng đó với các trình điều khiển quen thuộc hơn
Linux "Trình điều khiển thiết bị USB", là proxy phía máy chủ cho USB thực
thiết bị, một thuật ngữ khác được sử dụng: trình điều khiển bên trong thiết bị ngoại vi
là "Trình điều khiển tiện ích USB". Trong các tương tác giao thức USB, thiết bị
trình điều khiển là trình điều khiển chính (hoặc "trình điều khiển máy khách") và trình điều khiển tiện ích là
nô lệ (hoặc "trình điều khiển chức năng").

Tiện ích API giống với Linux-USB API phía máy chủ ở chỗ cả hai đều sử dụng
hàng đợi các đối tượng yêu cầu để đóng gói bộ đệm I/O và những yêu cầu đó có thể
được nộp hoặc bị hủy bỏ. Họ chia sẻ các định nghĩa chung cho tiêu chuẩn
Thông báo, cấu trúc và hằng số USB ZZ0000ZZ. Ngoài ra, cả hai API
liên kết và hủy liên kết trình điều khiển với thiết bị. Các API khác nhau về chi tiết, vì
Khung URB hiện tại của phía máy chủ cho thấy một số cách triển khai
chi tiết và giả định không phù hợp với tiện ích API. Trong khi
mô hình chuyển giao điều khiển và quản lý cấu hình là
nhất thiết phải khác nhau (một bên là chủ trung lập về phần cứng, bên kia là chủ
là nô lệ nhận biết phần cứng), điểm cuối I/0 API được sử dụng ở đây cũng phải
có thể sử dụng được cho phía máy chủ API có chi phí hoạt động giảm.

Cấu trúc của trình điều khiển tiện ích
===========================

Một hệ thống chạy bên trong thiết bị ngoại vi USB thường có ít nhất ba
các lớp bên trong kernel để xử lý việc xử lý giao thức USB và có thể có
các lớp bổ sung trong mã không gian người dùng. ZZ0000ZZ API được sử dụng bởi
lớp giữa để tương tác với cấp thấp nhất (xử lý trực tiếp
phần cứng).

Trong Linux, từ dưới lên, các lớp này là:

ZZ0001ZZ
    Đây là cấp độ phần mềm thấp nhất. Đây là lớp duy nhất nói chuyện
    đến phần cứng, thông qua các thanh ghi, fifos, dma, irqs và những thứ tương tự. các
    ZZ0000ZZ API trừu tượng hóa bộ điều khiển ngoại vi
    phần cứng điểm cuối. Phần cứng đó được hiển thị thông qua điểm cuối
    các đối tượng chấp nhận các luồng bộ đệm IN/OUT và thông qua
    cuộc gọi lại tương tác với trình điều khiển tiện ích. Vì USB bình thường
    các thiết bị chỉ có một cổng ngược dòng, chúng chỉ có một trong các cổng này
    trình điều khiển. Trình điều khiển bộ điều khiển có thể hỗ trợ bất kỳ số lượng khác nhau
    trình điều khiển tiện ích, nhưng mỗi lần chỉ có thể sử dụng một trong số chúng.

Ví dụ về phần cứng bộ điều khiển như vậy bao gồm NetChip dựa trên PCI
    Bộ điều khiển tốc độ cao 2280 USB 2.0, SA-11x0 hoặc PXA-25x UDC
    (được tìm thấy trong nhiều PDA) và nhiều loại sản phẩm khác.

ZZ0000ZZ
    Ranh giới dưới của trình điều khiển này triển khai USB trung tính về phần cứng
    chức năng, sử dụng các cuộc gọi đến trình điều khiển bộ điều khiển. Bởi vì như vậy
    phần cứng rất khác nhau về khả năng và hạn chế, và được sử dụng
    trong các môi trường nhúng nơi không gian ở mức cao, tiện ích
    trình điều khiển thường được cấu hình tại thời điểm biên dịch để hoạt động với các điểm cuối
    được hỗ trợ bởi một bộ điều khiển cụ thể. Trình điều khiển tiện ích có thể
    di động tới một số bộ điều khiển khác nhau, sử dụng điều kiện
    biên soạn. (Các hạt nhân gần đây đơn giản hóa đáng kể công việc
    tham gia hỗ trợ phần cứng mới, bởi các điểm cuối ZZ0001ZZ
    tự động cho nhiều trình điều khiển định hướng hàng loạt.) Trình điều khiển tiện ích
    trách nhiệm bao gồm:

- có thể xử lý các yêu cầu thiết lập (phản hồi giao thức ep0)
       bao gồm chức năng dành riêng cho lớp

- trả về cấu hình và mô tả chuỗi

- (lại) cài đặt cấu hình và cài đặt thay thế giao diện, bao gồm
       kích hoạt và định cấu hình điểm cuối

- xử lý các sự kiện trong vòng đời, chẳng hạn như quản lý các ràng buộc với
       phần cứng, tạm dừng/tiếp tục USB, đánh thức và ngắt kết nối từ xa
       từ máy chủ USB.

- quản lý chuyển IN và OUT trên tất cả các điểm cuối hiện được kích hoạt

Các trình điều khiển như vậy có thể là các mô-đun mã độc quyền, mặc dù
    cách tiếp cận này không được khuyến khích trong cộng đồng Linux.

ZZ0000ZZ
    Hầu hết các trình điều khiển tiện ích đều có ranh giới trên kết nối với một số
    Trình điều khiển hoặc khung Linux trong Linux. Qua ranh giới đó chảy
    dữ liệu mà trình điều khiển tiện ích tạo ra và/hoặc tiêu thụ thông qua
    chuyển giao thức qua USB. Ví dụ bao gồm:

- mã chế độ người dùng, sử dụng chung (tiện ích) hoặc ứng dụng cụ thể
       các tập tin trong ZZ0000ZZ

- hệ thống con mạng (dành cho các thiết bị mạng, như CDC Ethernet
       Trình điều khiển tiện ích mẫu)

- trình điều khiển thu thập dữ liệu, có thể là video4Linux hoặc trình điều khiển máy quét; hoặc
       phần cứng kiểm tra và đo lường.

- hệ thống con đầu vào (dành cho tiện ích HID)

- hệ thống con âm thanh (dành cho thiết bị âm thanh)

- hệ thống tập tin (dành cho tiện ích PTP)

- chặn hệ thống con i/o (đối với các tiện ích lưu trữ usb)

- ... và hơn thế nữa

ZZ0004ZZ
    Các lớp khác có thể tồn tại. Chúng có thể bao gồm các lớp hạt nhân, chẳng hạn như
    ngăn xếp giao thức mạng, cũng như xây dựng ứng dụng chế độ người dùng
    trên các API gọi hệ thống POSIX tiêu chuẩn như ZZ0000ZZ, ZZ0001ZZ,
    ZZ0002ZZ và ZZ0003ZZ. Trên các hệ thống mới hơn, các lệnh gọi I/O không đồng bộ của POSIX có thể
    là một lựa chọn. Mã chế độ người dùng như vậy sẽ không nhất thiết phải tuân theo
    Giấy phép Công cộng Chung GNU (GPL).

Các hệ thống có khả năng OTG cũng sẽ cần bao gồm máy chủ Linux-USB tiêu chuẩn
ngăn xếp bên, với ZZ0000ZZ, một hoặc nhiều ZZ0001ZZ
(HCD), ZZ0002ZZ để hỗ trợ OTG "Thiết bị ngoại vi nhắm mục tiêu
Danh sách", v.v. Cũng sẽ có một chiếc ZZ0003ZZ,
mà các nhà phát triển trình điều khiển thiết bị và tiện ích chỉ hiển thị một cách gián tiếp.
Điều đó giúp bộ điều khiển USB phía máy chủ và thiết bị triển khai hai
giao thức OTG mới (HNP và SRP). Chuyển đổi vai trò (máy chủ sang thiết bị ngoại vi hoặc
ngược lại) sử dụng HNP trong quá trình xử lý tạm dừng USB và SRP có thể
được xem như một loại giao thức đánh thức thiết bị thân thiện với pin hơn.

Theo thời gian, các tiện ích có thể tái sử dụng đang phát triển để giúp tạo ra một số tiện ích
nhiệm vụ điều khiển đơn giản hơn. Ví dụ: xây dựng mô tả cấu hình
từ các vectơ mô tả cho các giao diện cấu hình và
điểm cuối hiện đã được tự động hóa và nhiều trình điều khiển hiện sử dụng tính năng tự động cấu hình
để chọn điểm cuối phần cứng và khởi tạo bộ mô tả của chúng. A
ví dụ tiềm năng được quan tâm đặc biệt là tiêu chuẩn triển khai mã
Giao thức USB-IF cho HID, mạng, lưu trữ hoặc lớp âm thanh. Một số
các nhà phát triển quan tâm đến các hook KDB hoặc KGDB, để cho phép phần cứng mục tiêu
được gỡ lỗi từ xa. Hầu hết mã giao thức USB như vậy không cần phải
dành riêng cho phần cứng, hơn bất kỳ giao thức mạng nào như X11, HTTP hoặc
NFS là. Các trình điều khiển giao diện phía tiện ích như vậy cuối cùng sẽ được
kết hợp, để thực hiện các thiết bị tổng hợp.

Tiện ích chế độ hạt nhân API
======================

Trình điều khiển tiện ích tự khai báo thông qua cấu trúc
ZZ0000ZZ, chịu trách nhiệm cho hầu hết các phần liệt kê
cho cấu trúc usb_gadget. Phản hồi cho set_configuration thường
liên quan đến việc kích hoạt một hoặc nhiều đối tượng struct usb_ep được hiển thị bởi
tiện ích và gửi một hoặc nhiều bộ đệm cấu trúc usb_request tới
truyền dữ liệu. Hiểu bốn loại dữ liệu đó và hoạt động của chúng,
và bạn sẽ hiểu API này hoạt động như thế nào.

.. Note::

    Other than the "Chapter 9" data types, most of the significant data
    types and functions are described here.

    However, some relevant information is likely omitted from what you
    are reading. One example of such information is endpoint
    autoconfiguration. You'll have to read the header file, and use
    example source code (such as that for "Gadget Zero"), to fully
    understand the API.

    The part of the API implementing some basic driver capabilities is
    specific to the version of the Linux kernel that's in use. The 2.6
    and upper kernel versions include a *driver model* framework that has
    no analogue on earlier kernels; so those parts of the gadget API are
    not fully portable. (They are implemented on 2.4 kernels, but in a
    different way.) The driver model state is another part of this API that is
    ignored by the kerneldoc tools.

Lõi API không hiển thị mọi tính năng phần cứng có thể có, chỉ có
những cái có sẵn rộng rãi nhất. Có những tính năng phần cứng quan trọng,
chẳng hạn như DMA giữa thiết bị với thiết bị (không có bộ nhớ tạm thời trong bộ nhớ
buffer) sẽ được thêm bằng API dành riêng cho phần cứng.

API này cho phép trình điều khiển sử dụng trình biên dịch có điều kiện để xử lý
khả năng điểm cuối của phần cứng khác nhau, nhưng không yêu cầu điều đó.
Phần cứng có xu hướng có những hạn chế tùy tiện, liên quan đến việc chuyển giao
loại, địa chỉ, kích thước gói, bộ đệm và tính sẵn sàng. Như một quy luật,
những khác biệt như vậy chỉ quan trọng đối với logic "điểm cuối 0" xử lý
cấu hình và quản lý thiết bị. API hỗ trợ thời gian chạy giới hạn
phát hiện các khả năng, thông qua quy ước đặt tên cho điểm cuối.
Nhiều trình điều khiển sẽ có thể tự động cấu hình ít nhất một phần
chính họ. Đặc biệt, các phần init driver thường sẽ có endpoint
logic cấu hình tự động quét danh sách điểm cuối của phần cứng để
tìm những cái phù hợp với yêu cầu của trình điều khiển (dựa vào những cái đó
quy ước), để loại bỏ một số lý do phổ biến nhất cho
biên soạn có điều kiện.

Giống như API phía máy chủ Linux-USB, API này bộc lộ tính chất "mạnh mẽ"
của các tin nhắn USB: Các yêu cầu I/O dưới dạng một hoặc nhiều "gói" và
ranh giới gói được hiển thị cho trình điều khiển. So với nối tiếp RS-232
giao thức, USB giống với các giao thức đồng bộ như HDLC (N byte mỗi
frame, địa chỉ đa điểm, máy chủ là trạm chính và các thiết bị là
trạm thứ cấp) nhiều hơn trạm không đồng bộ (kiểu tty: 8 bit dữ liệu
trên mỗi khung hình, không có tính chẵn lẻ, một bit dừng). Vì vậy, ví dụ bộ điều khiển
trình điều khiển sẽ không đệm hai byte ghi vào một USB hai byte
IN gói, mặc dù trình điều khiển tiện ích có thể làm như vậy khi chúng triển khai
các giao thức trong đó ranh giới gói (và "gói ngắn") không được xác định
đáng kể.

Vòng đời của người lái xe
-----------------

Trình điều khiển tiện ích thực hiện các yêu cầu I/O điểm cuối tới phần cứng mà không cần phải
biết nhiều chi tiết về phần cứng, nhưng mã cài đặt/cấu hình trình điều khiển
cần giải quyết một số khác biệt. Sử dụng API như thế này:

1. Đăng ký trình điều khiển cho bộ điều khiển usb phía thiết bị cụ thể
   phần cứng, chẳng hạn như net2280 trên PCI (USB 2.0), sa11x0 hoặc pxa25x như
   được tìm thấy trong các PDA Linux, v.v. Tại thời điểm này, thiết bị hợp lý
   ở trạng thái ban đầu USB ch9 (ZZ0000ZZ), không có điện và không
   có thể sử dụng được (vì nó chưa hỗ trợ liệt kê). Bất kỳ máy chủ nào cũng nên
   không thấy thiết bị, vì nó chưa kích hoạt tính năng kéo dòng dữ liệu
   được máy chủ sử dụng để phát hiện thiết bị, ngay cả khi có nguồn điện VBUS.

2. Đăng ký trình điều khiển tiện ích triển khai một số thiết bị cấp cao hơn
   chức năng. Sau đó, nó sẽ liên kết() với ZZ0000ZZ, kích hoạt
   đôi khi kéo lên dòng dữ liệu sau khi phát hiện VBUS.

3. Bây giờ trình điều khiển phần cứng có thể bắt đầu liệt kê. Các bước nó xử lý
   phải chấp nhận các yêu cầu USB ZZ0000ZZ và ZZ0001ZZ. Các bước khác là
   được xử lý bởi trình điều khiển tiện ích. Nếu mô-đun trình điều khiển tiện ích không được tải
   trước khi máy chủ bắt đầu liệt kê, các bước trước bước 7 sẽ bị bỏ qua.

4. Lệnh gọi ZZ0000ZZ của trình điều khiển tiện ích trả về các bộ mô tả usb, dựa trên cả hai
   về những gì phần cứng giao diện bus cung cấp và về chức năng
   đang được triển khai. Điều đó có thể liên quan đến các cài đặt thay thế hoặc
   cấu hình, trừ khi phần cứng ngăn chặn hoạt động đó. Dành cho OTG
   thiết bị, mỗi bộ mô tả cấu hình bao gồm một bộ mô tả OTG.

5. Trình điều khiển tiện ích xử lý bước liệt kê cuối cùng khi USB
   máy chủ thực hiện cuộc gọi ZZ0000ZZ. Nó cho phép tất cả các điểm cuối được sử dụng
   trong cấu hình đó, với tất cả các giao diện trong cài đặt mặc định của chúng.
   Điều đó liên quan đến việc sử dụng danh sách các điểm cuối của phần cứng, cho phép mỗi điểm cuối
   điểm cuối theo mô tả của nó. Nó cũng có thể liên quan đến việc sử dụng
   ZZ0001ZZ để lấy thêm năng lượng từ VBUS, như
   được cấu hình đó cho phép. Đối với các thiết bị OTG, cài đặt
   cấu hình cũng có thể liên quan đến việc báo cáo các khả năng của HNP thông qua
   giao diện người dùng.

6. Thực hiện công việc thực tế và thực hiện truyền dữ liệu, có thể liên quan đến những thay đổi
   sang cài đặt giao diện hoặc chuyển sang cấu hình mới, cho đến khi
   thiết bị bị ngắt kết nối() khỏi máy chủ. Xếp hàng bất kỳ số lượng chuyển khoản
   yêu cầu tới từng điểm cuối. Nó có thể bị đình chỉ và tiếp tục lại vài lần
   lần trước khi bị ngắt kết nối. Khi ngắt kết nối, trình điều khiển quay trở lại
   đến bước 3 (ở trên).

7. Khi mô-đun trình điều khiển tiện ích đang được dỡ xuống, trình điều khiển sẽ hủy liên kết()
   cuộc gọi lại được phát hành. Điều đó cho phép trình điều khiển bộ điều khiển được dỡ bỏ.

Các trình điều khiển thông thường sẽ được sắp xếp sao cho chỉ cần tải trình điều khiển tiện ích
mô-đun (hoặc liên kết tĩnh nó vào nhân Linux) cho phép
thiết bị ngoại vi được liệt kê, nhưng một số trình điều khiển sẽ trì hoãn
liệt kê cho đến khi một số thành phần cấp cao hơn (như daemon chế độ người dùng)
cho phép nó. Lưu ý rằng ở mức thấp nhất này không có chính sách nào về
logic cấu hình ep0 được triển khai như thế nào, ngoại trừ việc nó phải tuân theo
Thông số kỹ thuật USB. Những vấn đề như vậy thuộc về trình điều khiển tiện ích,
bao gồm cả việc biết về các ràng buộc triển khai do một số USB áp đặt
bộ điều khiển hoặc hiểu rằng các thiết bị tổng hợp có thể xảy ra
được xây dựng bằng cách tích hợp các thành phần có thể tái sử dụng.

Lưu ý rằng vòng đời ở trên có thể hơi khác đối với các thiết bị OTG.
Ngoài việc cung cấp bộ mô tả OTG bổ sung trong mỗi cấu hình,
chỉ những khác biệt liên quan đến HNP mới được người lái xe nhìn thấy rõ ràng
mã. Chúng liên quan đến các yêu cầu báo cáo trong ZZ0000ZZ
yêu cầu và tùy chọn gọi HNP trong một số lệnh gọi lại tạm dừng.
Ngoài ra, SRP thay đổi một chút ngữ nghĩa của ZZ0001ZZ.

USB 2.0 Chương 9 Các loại và hằng số
-------------------------------------

Trình điều khiển tiện ích dựa trên các cấu trúc và hằng số USB phổ biến được xác định trong
tệp tiêu đề ZZ0000ZZ, là tệp tiêu chuẩn trong
Hạt nhân Linux 2.6+. Đây là các loại và hằng số giống nhau được sử dụng bởi phía máy chủ
trình điều khiển (và usbcore).

Đối tượng và phương pháp cốt lõi
------------------------

Chúng được khai báo trong ZZ0000ZZ và được sử dụng bởi tiện ích
trình điều khiển để tương tác với trình điều khiển bộ điều khiển ngoại vi USB.

.. kernel-doc:: include/linux/usb/gadget.h
   :internal:

Tiện ích tùy chọn
------------------

Lõi API đủ để viết Trình điều khiển tiện ích USB, nhưng một số
các tiện ích tùy chọn được cung cấp để đơn giản hóa các tác vụ thông thường. Những cái này
các tiện ích bao gồm tự động cấu hình điểm cuối.

.. kernel-doc:: drivers/usb/gadget/usbstring.c
   :export:

.. kernel-doc:: drivers/usb/gadget/config.c
   :export:

Khung thiết bị tổng hợp
--------------------------

Lõi API đủ để viết trình điều khiển cho các thiết bị USB tổng hợp
(có nhiều hơn một chức năng trong một cấu hình nhất định), đồng thời
thiết bị đa cấu hình (cũng có nhiều hơn một chức năng, nhưng không
nhất thiết phải chia sẻ một cấu hình nhất định). Tuy nhiên có một tùy chọn
framework giúp tái sử dụng và kết hợp các chức năng dễ dàng hơn.

Các thiết bị sử dụng khung này cung cấp cấu trúc usb_composite_driver,
do đó cung cấp một hoặc nhiều cấu trúc usb_configuration
trường hợp. Mỗi cấu hình như vậy bao gồm ít nhất một cấu trúc
ZZ0000ZZ, đóng gói vai trò hiển thị của người dùng chẳng hạn như "mạng
liên kết" hoặc "thiết bị lưu trữ dung lượng lớn". Chức năng quản lý cũng có thể tồn tại,
chẳng hạn như "Nâng cấp chương trình cơ sở thiết bị".

.. kernel-doc:: include/linux/usb/composite.h
   :internal:

.. kernel-doc:: drivers/usb/gadget/composite.c
   :export:

Chức năng thiết bị tổng hợp
--------------------------

Tại thời điểm viết bài này, một số trình điều khiển tiện ích hiện tại đã được chuyển đổi
vào khuôn khổ này. Các kế hoạch ngắn hạn bao gồm chuyển đổi tất cả chúng,
ngoại trừ ZZ0000ZZ.

Trình điều khiển ngoại vi
=============================

Phần cứng đầu tiên hỗ trợ API này là bộ điều khiển NetChip 2280,
hỗ trợ USB 2.0 tốc độ cao và dựa trên PCI. Đây là
Mô-đun trình điều khiển ZZ0000ZZ. Trình điều khiển hỗ trợ nhân Linux phiên bản 2.4
và 2,6; liên hệ với NetChip Technologies để biết bảng phát triển và sản phẩm
thông tin.

Phần cứng khác hoạt động trong khung ZZ0000ZZ bao gồm: PXA của Intel
Bộ xử lý dòng 25x và IXP42x (ZZ0001ZZ), Toshiba TC86c001
"Goku-S" (ZZ0002ZZ), Renesas SH7705/7727 (ZZ0003ZZ), MediaQ 11xx
(ZZ0004ZZ), Hynix HMS30C7202 (ZZ0005ZZ), Quốc gia 9303/4
(ZZ0006ZZ), Texas Instruments OMAP (ZZ0007ZZ), Sharp LH7A40x
(ZZ0008ZZ), v.v. Hầu hết trong số đó là bộ điều khiển tốc độ đầy đủ.

Tại thời điểm viết bài này, có những người đang nghiên cứu các trình điều khiển trong khuôn khổ này
cho một số bộ điều khiển thiết bị USB khác, với kế hoạch tạo ra nhiều
chúng phải được phổ biến rộng rãi.

Trình mô phỏng USB một phần, trình điều khiển ZZ0000ZZ, hiện có sẵn. Nó có thể
hoạt động giống như net2280, pxa25x hoặc sa11x0 về mặt khả dụng
điểm cuối và tốc độ thiết bị; và nó mô phỏng khả năng điều khiển, số lượng lớn và đối với một số
mức độ chuyển giao gián đoạn. Điều đó cho phép bạn phát triển một số phần của tiện ích
trình điều khiển trên một PC bình thường, không có bất kỳ phần cứng đặc biệt nào và có lẽ với
sự hỗ trợ của các công cụ như GDB chạy với Chế độ người dùng Linux. Tại
ít nhất một người đã bày tỏ sự quan tâm đến việc điều chỉnh cách tiếp cận đó,
nối nó với một bộ mô phỏng cho vi điều khiển. Những mô phỏng như vậy có thể
giúp gỡ lỗi các hệ thống con nơi phần cứng thời gian chạy không thân thiện với
phát triển phần mềm hoặc chưa có sẵn.

Hỗ trợ cho các bộ điều khiển khác dự kiến sẽ được phát triển và
đóng góp theo thời gian khi khung trình điều khiển này phát triển.

Trình điều khiển tiện ích
==============

Ngoài ZZ0000ZZ (được sử dụng chủ yếu để thử nghiệm và phát triển
với trình điều khiển cho phần cứng bộ điều khiển usb), các trình điều khiển tiện ích khác vẫn tồn tại.

Có trình điều khiển tiện ích ZZ0000ZZ, triển khai một trong những trình điều khiển tiện ích nhất
các mẫu ZZ0001ZZ (CDC) hữu ích. Một trong những tiêu chuẩn
đối với khả năng tương tác của modem cáp thậm chí còn chỉ định việc sử dụng ethernet này
model là một trong hai lựa chọn bắt buộc. Các tiện ích sử dụng mã này trông giống như một
Máy chủ USB như thể chúng là bộ chuyển đổi Ethernet. Nó cung cấp quyền truy cập vào một
mạng trong đó CPU của tiện ích là một máy chủ, có thể dễ dàng bị
bắc cầu, định tuyến hoặc tường lửa truy cập vào các mạng khác. Vì một số
phần cứng không thể thực hiện đầy đủ các yêu cầu Ethernet CDC, điều này
trình điều khiển cũng triển khai tập hợp con "chỉ các bộ phận tốt" của CDC Ethernet. (Đó
tập hợp con không tự quảng cáo là CDC Ethernet, để tránh tạo
vấn đề.)

Hỗ trợ cho giao thức ZZ0000ZZ của Microsoft đã được đóng góp bởi
Pengutronix và Auerswald GmbH. Cái này giống như CDC Ethernet, nhưng nó chạy
trên phần cứng USB hơn một chút (nhưng ít hơn tập hợp con CDC). Tuy nhiên,
tuyên bố nổi tiếng chính của nó là có thể kết nối trực tiếp với gần đây
các phiên bản Windows, sử dụng trình điều khiển được Microsoft đóng gói và hỗ trợ,
làm cho việc kết nối mạng với Windows trở nên đơn giản hơn nhiều.

Ngoài ra còn có hỗ trợ cho trình điều khiển tiện ích chế độ người dùng, sử dụng ZZ0000ZZ.
Điều này cung cấp ZZ0003ZZ trình bày mỗi điểm cuối dưới dạng một
bộ mô tả tập tin. I/O được thực hiện bằng các lệnh gọi ZZ0001ZZ và ZZ0002ZZ thông thường.
Các công cụ quen thuộc như GDB và pthread có thể được sử dụng để phát triển và gỡ lỗi
trình điều khiển chế độ người dùng, để khi có sẵn trình điều khiển bộ điều khiển mạnh mẽ
nhiều ứng dụng cho nó sẽ không yêu cầu phần mềm chế độ kernel mới. Linux
Có sẵn hỗ trợ 2.6 ZZ0004ZZ, do đó phần mềm chế độ người dùng
có thể truyền dữ liệu chỉ với chi phí cao hơn một chút so với trình điều khiển hạt nhân.

Có trình điều khiển lớp Lưu trữ lớn USB, cung cấp một trải nghiệm khác
giải pháp cho khả năng tương tác với các hệ thống như MS-Windows và MacOS.
Trình điều khiển ZZ0001ZZ đó sử dụng tệp hoặc thiết bị khối làm kho lưu trữ dự phòng
cho một ổ đĩa, như trình điều khiển ZZ0000ZZ. Máy chủ USB sử dụng BBB, CB hoặc
Các phiên bản CBI của đặc tả lớp lưu trữ dung lượng lớn, sử dụng trong suốt
SCSI ra lệnh truy cập dữ liệu từ kho lưu trữ dự phòng.

Có trình điều khiển "dòng nối tiếp", hữu ích cho hoạt động kiểu TTY trên USB.
Phiên bản mới nhất của trình điều khiển đó hỗ trợ hoạt động kiểu CDC ACM, như
modem USB, v.v., trên hầu hết phần cứng, nó có thể tương tác dễ dàng với
MS-Windows. Một cách sử dụng thú vị của trình điều khiển đó là trong phần sụn khởi động (như
BIOS), đôi khi có thể sử dụng mô hình đó với các hệ thống rất nhỏ
không có dòng nối tiếp thực sự.

Hỗ trợ cho các loại tiện ích khác dự kiến sẽ được phát triển và
đóng góp theo thời gian khi khung trình điều khiển này phát triển.

USB khi đang di chuyển (OTG)
===================

USB OTG hỗ trợ trên Linux 2.6 ban đầu được phát triển bởi Texas
Dụng cụ dành cho dòng ZZ0000ZZ 16xx và 17xx
bộ xử lý. Các hệ thống OTG khác sẽ hoạt động theo cách tương tự, nhưng
chi tiết cấp độ phần cứng có thể rất khác nhau.

Các hệ thống cần hỗ trợ phần cứng chuyên dụng để triển khai OTG, đặc biệt là
bao gồm giắc cắm ZZ0003ZZ đặc biệt và bộ thu phát liên quan để hỗ trợ
Hoạt động ZZ0004ZZ: chúng có thể hoạt động như một máy chủ, sử dụng tiêu chuẩn
Ngăn xếp trình điều khiển phía máy chủ Linux-USB hoặc như một thiết bị ngoại vi, sử dụng cái này
Khung ZZ0002ZZ. Để làm được điều đó, phần mềm hệ thống dựa vào
bổ sung cho các giao diện lập trình đó và trên một giao diện nội bộ mới
thành phần (ở đây gọi là "Bộ điều khiển OTG") ảnh hưởng đến ngăn xếp trình điều khiển nào
kết nối với cổng OTG. Trong mỗi vai trò, hệ thống có thể tái sử dụng
nhóm trình điều khiển trung tính về phần cứng hiện có, được xếp chồng lên trên
giao diện trình điều khiển bộ điều khiển (ZZ0000ZZ hoặc ZZ0001ZZ).
Những trình điều khiển như vậy cần nhiều nhất những thay đổi nhỏ và hầu hết các lệnh gọi được thêm vào
hỗ trợ OTG cũng có thể mang lại lợi ích cho các sản phẩm không phải OTG.

- Trình điều khiển tiện ích kiểm tra cờ ZZ0000ZZ và sử dụng cờ này để xác định
   có hay không bao gồm bộ mô tả OTG trong mỗi bộ mô tả của chúng
   cấu hình.

- Trình điều khiển tiện ích có thể cần thay đổi để hỗ trợ hai giao thức OTG mới,
   được hiển thị trong các thuộc tính tiện ích mới như cờ ZZ0000ZZ. HNP
   hỗ trợ phải được báo cáo thông qua giao diện người dùng (hai đèn LED có thể
   đủ) và được kích hoạt trong một số trường hợp khi máy chủ tạm dừng
   ngoại vi. Hỗ trợ SRP có thể được người dùng thực hiện giống như điều khiển từ xa
   thức dậy, có thể bằng cách nhấn nút tương tự.

- Về phía máy chủ, trình điều khiển thiết bị USB cần được dạy để kích hoạt HNP
   vào những thời điểm thích hợp, sử dụng ZZ0000ZZ. Điều đó cũng
   tiết kiệm pin, rất hữu ích ngay cả đối với những người không phải OTG
   cấu hình.

- Ngoài ra ở phía máy chủ, trình điều khiển phải hỗ trợ OTG "Targeted
   Danh sách ngoại vi". Đó chỉ là danh sách trắng, dùng để từ chối các thiết bị ngoại vi
   không được hỗ trợ với máy chủ Linux OTG nhất định. *Danh sách trắng này là
   sản phẩm cụ thể; mỗi sản phẩm phải sửa đổi* ZZ0000ZZ *thành
   phù hợp với đặc điểm kỹ thuật khả năng tương tác của nó.*

Các máy chủ Linux không phải OTG, như PC và máy trạm, thường có một số
   giải pháp bổ sung trình điều khiển để các thiết bị ngoại vi không có
   được công nhận cuối cùng có thể được hỗ trợ. Cách làm đó là không hợp lý
   đối với các sản phẩm tiêu dùng có thể không bao giờ được nâng cấp chương trình cơ sở,
   và nơi thường không thực tế khi mong đợi truyền thống
   Các loại mô hình hỗ trợ PC/máy trạm/máy chủ để hoạt động. Ví dụ,
   việc thay đổi chương trình cơ sở của thiết bị thường là không thực tế khi sản phẩm đã có
   đã được phân phối, do đó lỗi trình điều khiển thường không thể sửa được nếu chúng
   được tìm thấy sau khi vận chuyển.

Cần có những thay đổi bổ sung bên dưới ZZ0000ZZ trung tính về phần cứng
và giao diện trình điều khiển ZZ0001ZZ; những điều đó không được thảo luận ở đây trong bất kỳ
chi tiết. Những điều này ảnh hưởng đến mã dành riêng cho phần cứng cho từng Máy chủ USB hoặc
Bộ điều khiển ngoại vi và cách HCD khởi chạy (vì OTG có thể
chỉ hoạt động trên một cổng duy nhất). Chúng cũng liên quan đến cái có thể được gọi là
ZZ0002ZZ, quản lý bộ thu phát OTG và trạng thái OTG
logic máy cũng như phần lớn hoạt động của trung tâm gốc cho cổng OTG.
Trình điều khiển bộ điều khiển OTG cần kích hoạt và hủy kích hoạt USB
bộ điều khiển tùy thuộc vào vai trò của thiết bị có liên quan. Một số thay đổi liên quan
cần thiết bên trong usbcore để nó có thể xác định các thiết bị có khả năng OTG
và phản hồi thích hợp với các giao thức HNP hoặc SRP.
