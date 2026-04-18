.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/hyperv/vmbus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

VMBus
=====
VMBus là một cấu trúc phần mềm được Hyper-V cung cấp cho các máy ảo khách.  Nó
bao gồm một đường dẫn điều khiển và các phương tiện chung được sử dụng bởi tổng hợp
các thiết bị mà Hyper-V trình bày cho các máy ảo khách.   Đường điều khiển là
được sử dụng để cung cấp các thiết bị tổng hợp cho VM khách và trong một số trường hợp,
hủy bỏ các thiết bị đó.   Các tiện ích chung bao gồm phần mềm
các kênh để liên lạc giữa trình điều khiển thiết bị trong VM khách
và việc triển khai thiết bị tổng hợp là một phần của Hyper-V và
báo hiệu nguyên thủy để cho phép Hyper-V và khách gián đoạn
lẫn nhau.

VMBus được mô hình hóa trong Linux dưới dạng xe buýt, với /sys/bus/vmbus dự kiến
mục nhập trong một máy khách Linux đang chạy.  Trình điều khiển VMBus (drivers/hv/vmbus_drv.c)
thiết lập đường dẫn điều khiển VMBus với máy chủ Hyper-V, sau đó
tự đăng ký làm trình điều khiển xe buýt Linux.  Nó thực hiện tiêu chuẩn
chức năng bus để thêm và xóa các thiết bị vào/ra khỏi bus.

Hầu hết các thiết bị tổng hợp do Hyper-V cung cấp đều có Linux tương ứng
trình điều khiển thiết bị.  Những thiết bị này bao gồm:

* Bộ điều khiển SCSI
* NIC
* Bộ đệm khung đồ họa
* Bàn phím
* Chuột
* Truyền qua thiết bị PCI
* Nhịp tim
* Đồng bộ hóa thời gian
* Tắt máy
* Bóng trí nhớ
* Trao đổi cặp khóa/giá trị (KVP) với Hyper-V
* Sao lưu trực tuyến Hyper-V (còn gọi là VSS)

Máy ảo khách có thể có nhiều phiên bản SCSI tổng hợp
bộ điều khiển, thiết bị truyền qua NIC tổng hợp và PCI.  Khác
các thiết bị tổng hợp được giới hạn ở một phiên bản duy nhất cho mỗi VM.  Không
liệt kê ở trên là một số lượng nhỏ các thiết bị tổng hợp được cung cấp bởi
Hyper-V chỉ được sử dụng bởi khách Windows và Linux
không có người lái xe.

Hyper-V sử dụng thuật ngữ "VSP" và "VSC" để mô tả tổng hợp
thiết bị.  "VSP" đề cập đến mã Hyper-V thực hiện một
thiết bị tổng hợp cụ thể, trong khi "VSC" dùng để chỉ trình điều khiển cho
thiết bị trong VM khách.  Ví dụ: trình điều khiển Linux cho
NIC tổng hợp được gọi là "netvsc" và trình điều khiển Linux cho
bộ điều khiển SCSI tổng hợp là "storvsc".  Các trình điều khiển này chứa
các hàm có tên như "storvsc_connect_to_vsp".

kênh VMBus
--------------
Một phiên bản của thiết bị tổng hợp sử dụng các kênh VMBus để liên lạc
giữa VSP và VSC.  Các kênh là hai chiều và được sử dụng
để chuyển tin nhắn.   Hầu hết các thiết bị tổng hợp đều sử dụng một kênh duy nhất,
nhưng bộ điều khiển SCSI tổng hợp và NIC tổng hợp có thể sử dụng nhiều
kênh để đạt được hiệu suất cao hơn và tính song song cao hơn.

Mỗi kênh bao gồm hai bộ đệm vòng.  Đây là chiếc nhẫn cổ điển
bộ đệm từ sách giáo khoa cấu trúc dữ liệu của trường đại học.  Nếu đọc
và con trỏ ghi bằng nhau, bộ đệm vòng được coi là
trống, do đó bộ đệm vòng đầy luôn có ít nhất một byte không được sử dụng.
Bộ đệm vòng "in" dành cho các tin nhắn từ máy chủ Hyper-V tới
khách và bộ đệm vòng "out" dành cho các tin nhắn từ khách đến
máy chủ Hyper-V.  Trong Linux, ký hiệu "trong" và "ngoài" giống như
được phía khách xem.  Bộ đệm vòng là bộ nhớ được
được chia sẻ giữa khách và chủ nhà và họ tuân theo tiêu chuẩn
mô hình nơi bộ nhớ được cấp phát bởi khách, với danh sách
của GPA tạo nên bộ đệm vòng được truyền tới máy chủ.  Mỗi
Bộ đệm vòng bao gồm một trang tiêu đề (4 Kbyte) với dữ liệu đọc và
ghi các chỉ số và một số cờ điều khiển, theo sau là bộ nhớ cho
chiếc nhẫn thực tế.  Kích thước của vòng được xác định bởi VSC trong
khách và dành riêng cho từng thiết bị tổng hợp.   Danh sách GPA
việc tạo thành vòng được truyền tới máy chủ Hyper-V qua
Đường dẫn điều khiển VMBus dưới dạng Danh sách mô tả GPA (GPADL).  Xem chức năng
vmbus_etablish_gpadl().

Mỗi bộ đệm vòng được ánh xạ vào ảo nhân Linux liền kề
không gian thành ba phần: 1) trang tiêu đề 4 Kbyte, 2) bộ nhớ
tạo nên chính chiếc nhẫn và 3) ánh xạ thứ hai của bộ nhớ
điều đó tạo nên chiếc nhẫn.  Vì (2) và (3) kề nhau
trong không gian ảo kernel, mã sao chép dữ liệu đến và đi từ
Bộ đệm vòng không cần phải quan tâm đến việc bao bọc bộ đệm vòng.
Khi thao tác sao chép đã hoàn tất, chỉ mục đọc hoặc ghi có thể
cần phải được đặt lại để trỏ lại ánh xạ đầu tiên, nhưng
bản sao dữ liệu thực tế không cần phải chia thành hai phần.  Cái này
Cách tiếp cận này cũng cho phép dễ dàng truy cập các cấu trúc dữ liệu phức tạp
trực tiếp vào vòng mà không cần xử lý sự bao bọc xung quanh.

Trên arm64 có kích thước trang > 4 Kbyte, trang tiêu đề vẫn phải là
được chuyển tới Hyper-V dưới dạng vùng 4 Kbyte.  Nhưng ký ức về thực tế
vòng phải được căn chỉnh theo PAGE_SIZE và có kích thước là bội số
của PAGE_SIZE để có thể thực hiện thủ thuật ánh xạ trùng lặp.  Do đó
một phần của trang tiêu đề không được sử dụng và không được truyền đạt tới
Hyper-V.  Trường hợp này được xử lý bởi vmbus_etablish_gpadl().

Hyper-V thực thi giới hạn về tổng dung lượng bộ nhớ khách
có thể được chia sẻ với máy chủ thông qua GPADL.  Giới hạn này đảm bảo
rằng một vị khách lừa đảo không thể ép chủ nhà tiêu thụ quá mức
tài nguyên.  Đối với Windows Server 2019 trở lên, giới hạn này là
khoảng 1280 Mbyte.  Đối với các phiên bản trước Windows Server
2019, giới hạn là khoảng 384 Mbyte.

Tin nhắn kênh VMBus
----------------------
Tất cả các tin nhắn được gửi trong kênh VMBus đều có tiêu đề chuẩn bao gồm
độ dài tin nhắn, độ lệch của tải trọng tin nhắn, một số cờ và
ID giao dịch.  Phần tin nhắn sau tiêu đề là
duy nhất cho mỗi cặp VSP/VSC.

Tin nhắn tuân theo một trong hai mẫu:

* Đơn hướng: Một trong hai bên gửi tin nhắn và không
  mong đợi một tin nhắn phản hồi
* Yêu cầu/phản hồi: Một bên (thường là khách) gửi tin nhắn
  và mong đợi một phản hồi

ID giao dịch (còn gọi là "requestID") dùng để khớp các yêu cầu &
những phản hồi.  Một số thiết bị tổng hợp cho phép thực hiện nhiều yêu cầu
chuyến bay đồng thời, do đó khách chỉ định ID giao dịch khi
gửi yêu cầu.  Hyper-V gửi lại cùng một ID giao dịch trong
phản ứng phù hợp.

Tin nhắn được truyền giữa VSP và VSC là tin nhắn điều khiển.  cho
Ví dụ: một tin nhắn được gửi từ trình điều khiển storvsc có thể là "thực thi
lệnh SCSI này".   Nếu một tin nhắn cũng bao hàm một số chuyển giao dữ liệu
giữa máy khách và máy chủ Hyper-V, dữ liệu thực tế sẽ được
được truyền đi có thể được nhúng cùng với thông báo điều khiển hoặc có thể
được chỉ định làm bộ đệm dữ liệu riêng biệt mà máy chủ Hyper-V sẽ
truy cập dưới dạng hoạt động DMA.  Trường hợp trước được sử dụng khi kích thước của
dữ liệu nhỏ và chi phí sao chép dữ liệu đến và đi từ
bộ đệm vòng là tối thiểu.  Ví dụ: tin nhắn đồng bộ hóa thời gian từ
Máy chủ Hyper-V dành cho khách chứa giá trị thời gian thực tế.  Khi
dữ liệu lớn hơn, một bộ đệm dữ liệu riêng biệt sẽ được sử dụng.  Trong trường hợp này,
thông báo điều khiển chứa danh sách GPA mô tả dữ liệu
bộ đệm.  Ví dụ: trình điều khiển storvsc sử dụng phương pháp này để
chỉ định bộ đệm dữ liệu đến/từ đó việc I/O đĩa được thực hiện.

Có ba chức năng để gửi tin nhắn kênh VMBus:

1. vmbus_sendpacket(): Tin nhắn chỉ điều khiển và tin nhắn có
   dữ liệu nhúng - không có GPA
2. vmbus_sendpacket_pagebuffer(): Tin nhắn kèm danh sách GPA
   xác định dữ liệu cần chuyển.  Một phần bù và chiều dài là
   được liên kết với mỗi GPA sao cho có nhiều vùng không liên tục
   bộ nhớ của khách có thể được nhắm mục tiêu.
3. vmbus_sendpacket_mpb_desc(): Tin nhắn kèm danh sách GPA
   xác định dữ liệu cần chuyển.  Một phần bù và chiều dài duy nhất là
   được liên kết với danh sách GPA.  GPA phải mô tả một
   vùng logic duy nhất của bộ nhớ khách được nhắm mục tiêu.

Trong lịch sử, khách Linux đã tin cậy Hyper-V để gửi các
và các thông báo hợp lệ cũng như trình điều khiển Linux cho các thiết bị tổng hợp thì không
xác nhận đầy đủ tin nhắn.  Với sự ra đời của bộ xử lý
công nghệ mã hóa hoàn toàn bộ nhớ khách và cho phép
khách không tin tưởng vào trình ảo hóa (AMD SEV-SNP, Intel TDX), tin tưởng
máy chủ Hyper-V không còn là giả định hợp lệ nữa.  Các trình điều khiển cho
Các thiết bị tổng hợp VMBus đang được cập nhật để xác thực đầy đủ mọi
các giá trị được đọc từ bộ nhớ được chia sẻ với Hyper-V, bao gồm
tin nhắn từ thiết bị VMBus.  Để tạo điều kiện thuận lợi cho việc xác nhận như vậy,
tin nhắn được khách đọc từ bộ đệm vòng "in" được sao chép vào
bộ đệm tạm thời không được chia sẻ với Hyper-V.  Xác thực là
được thực hiện trong bộ đệm tạm thời này mà không gặp rủi ro về Hyper-V
sửa đổi một cách ác ý tin nhắn sau khi nó được xác thực nhưng trước đó
nó được sử dụng.

Bộ điều khiển ngắt tổng hợp (synic)
--------------------------------------
Hyper-V cung cấp cho mỗi khách CPU một bộ điều khiển ngắt tổng hợp
được VMBus sử dụng để liên lạc giữa máy chủ và khách. Trong khi mỗi đồng bộ
định nghĩa 16 ngắt tổng hợp (SINT), Linux chỉ sử dụng một trong 16 ngắt
(VMBUS_MESSAGE_SINT). Tất cả các ngắt liên quan đến giao tiếp giữa
máy chủ Hyper-V và máy khách CPU sử dụng SINT đó.

SINT được ánh xạ tới một ngắt kiến trúc trên mỗi CPU (tức là
vectơ ngắt x86/x64 8 bit hoặc arm64 PPI INTID). Bởi vì
mỗi CPU trong máy khách có một đồng bộ và có thể nhận các ngắt VMBus,
chúng được mô hình hóa tốt nhất trong Linux dưới dạng các ngắt theo CPU. Mô hình này hoạt động
tốt trên arm64 nơi một CPU Linux IRQ duy nhất được phân bổ cho
VMBUS_MESSAGE_SINT. IRQ này xuất hiện trong /proc/interrupt dưới dạng IRQ được gắn nhãn
"Hyper-V VMbus". Vì x86/x64 thiếu hỗ trợ cho IRQ trên mỗi CPU nên x86
vectơ ngắt được phân bổ tĩnh (HYPERVISOR_CALLBACK_VECTOR)
trên tất cả các CPU và được mã hóa rõ ràng để gọi vmbus_isr(). Trong trường hợp này,
không có Linux IRQ và các ngắt được hiển thị tổng hợp trong
/proc/ngắt trên dòng "HYP".

Synic cung cấp phương tiện để phân kênh ngắt kiến trúc thành
một hoặc nhiều ngắt logic và định tuyến ngắt logic đến đúng
Trình xử lý VMBus trong Linux. Việc phân kênh này được thực hiện bởi vmbus_isr() và
các chức năng liên quan truy cập cấu trúc dữ liệu đồng bộ.

Synic không được mô hình hóa trong Linux dưới dạng chip irq hoặc miền irq,
và các ngắt logic được phân kênh không phải là IRQ của Linux. Như vậy,
chúng không xuất hiện trong /proc/interrupts hoặc /proc/irq. CPU
ái lực đối với một trong những ngắt logic này được điều khiển thông qua một
mục trong /sys/bus/vmbus như được mô tả bên dưới.

VMBus ngắt
----------------
VMBus cung cấp cơ chế để khách làm gián đoạn máy chủ khi
khách đã xếp hàng tin nhắn mới vào bộ đệm vòng.  chủ nhà
hy vọng rằng khách sẽ chỉ gửi một ngắt khi "ra"
chuyển đổi bộ đệm vòng từ trống sang không trống.  Nếu khách gửi
ngắt vào những thời điểm khác, máy chủ coi những ngắt đó là
không cần thiết.  Nếu khách gửi quá nhiều thông tin không cần thiết
bị gián đoạn, máy chủ có thể điều tiết vị khách đó bằng cách tạm dừng
thực thi trong vài giây để ngăn chặn cuộc tấn công từ chối dịch vụ.

Tương tự, máy chủ sẽ ngắt lời khách thông qua synic khi
nó sẽ gửi một tin nhắn mới trên đường dẫn điều khiển VMBus hoặc khi một VMBus
chuyển đổi bộ đệm vòng "in" của kênh từ trống sang không trống do
máy chủ chèn tin nhắn kênh VMBus mới. Luồng thông báo điều khiển
và mỗi bộ đệm vòng "trong" kênh VMBus là các ngắt logic riêng biệt
được phân kênh bởi vmbus_isr(). Nó tách kênh bằng cách kiểm tra đầu tiên
đối với các ngắt kênh bằng cách gọi vmbus_chan_sched(), xem xét một đồng bộ
bitmap để xác định kênh nào có các ngắt đang chờ xử lý trên CPU này.
Nếu nhiều kênh có các ngắt đang chờ xử lý cho CPU này thì chúng sẽ
được xử lý tuần tự.  Khi tất cả các ngắt kênh đã được xử lý,
vmbus_isr() kiểm tra và xử lý mọi tin nhắn nhận được trên VMBus
đường điều khiển.

CPU khách mà kênh VMBus sẽ làm gián đoạn được chọn bởi
khách khi kênh được tạo và máy chủ được thông báo về điều đó
lựa chọn.  Các thiết bị VMBus được nhóm thành hai loại:

1. Thiết bị "chậm" chỉ cần một kênh VMBus.  Các thiết bị
   (chẳng hạn như bàn phím, chuột, nhịp tim và đồng bộ hóa thời gian) tạo ra
   tương đối ít ngắt.  Các kênh VMBus của họ đều là
   được giao nhiệm vụ ngắt VMBUS_CONNECT_CPU, luôn luôn
   CPU 0.

2. Các thiết bị "tốc độ cao" có thể sử dụng nhiều kênh VMBus để
   tính song song và hiệu suất cao hơn.  Những thiết bị này bao gồm
   bộ điều khiển SCSI tổng hợp và NIC tổng hợp.  VMBus của họ
   các ngắt kênh được gán cho các CPU được dàn trải
   giữa các CPU có sẵn trong VM để làm gián đoạn
   nhiều kênh có thể được xử lý song song.

Việc gán các ngắt kênh VMBus cho CPU được thực hiện trong
hàm init_vp_index().  Nhiệm vụ này được thực hiện bên ngoài
cơ chế ái lực ngắt thông thường của Linux, do đó các ngắt được
không có sự gián đoạn "không được quản lý" hay "được quản lý".

Có thể thấy CPU mà kênh VMBus sẽ làm gián đoạn trong
/sys/bus/vmbus/devices/<deviceGUID>/ kênh/<channelRelID>/cpu.
Khi chạy trên các phiên bản Hyper-V mới hơn, CPU có thể được thay đổi
bằng cách viết một giá trị mới vào mục nhập sysfs này. Vì kênh VMBus
các ngắt không phải là IRQ của Linux, không có mục nào trong/proc/interrupt
hoặc /proc/irq tương ứng với các ngắt kênh VMBus riêng lẻ.

CPU trực tuyến trong máy khách Linux có thể không được đưa vào chế độ ngoại tuyến nếu nó có
Các ngắt kênh VMBus được gán cho nó. Bắt đầu từ kernel v6.15,
mọi ngắt như vậy sẽ tự động được gán lại cho một số CPU khác
tại thời điểm ngoại tuyến. CPU "khác" được chọn bởi
triển khai và không được cân bằng tải hoặc nói cách khác là không thông minh
xác định. Nếu CPU được trực tuyến trở lại, kênh sẽ bị gián đoạn trước đó
được gán cho nó sẽ không được chuyển trở lại. Kết quả là sau nhiều CPU
đã được ngoại tuyến và có thể được trực tuyến trở lại, ngắt tới CPU
ánh xạ có thể bị xáo trộn và không tối ưu. Trong trường hợp như vậy, tối ưu
nhiệm vụ phải được thiết lập lại bằng tay. Đối với hạt nhân v6.14 và
trước đó, mọi ngắt kênh xung đột trước tiên phải được xử lý thủ công
được gán lại cho một CPU khác như mô tả ở trên. Rồi khi không có kênh
các ngắt được gán cho CPU, nó có thể được chuyển sang chế độ ngoại tuyến.

Mã xử lý ngắt kênh VMBus được thiết kế để hoạt động
chính xác ngay cả khi nhận được ngắt trên CPU không phải là
CPU được gán cho kênh.  Cụ thể, mã không sử dụng
Loại trừ dựa trên CPU để đảm bảo tính chính xác.  Trong hoạt động bình thường, Hyper-V
sẽ làm gián đoạn CPU được chỉ định.  Nhưng khi CPU được gán cho một
kênh đang được thay đổi thông qua sysfs, khách không biết chính xác
khi nào Hyper-V sẽ thực hiện quá trình chuyển đổi.  Mã phải hoạt động chính xác
ngay cả khi có độ trễ về thời gian trước khi Hyper-V bắt đầu làm gián đoạn quá trình
CPU mới.  Xem nhận xét trong target_cpu_store().

Tạo/xóa thiết bị VMBus
------------------------------
Hyper-V và máy khách Linux có đường dẫn truyền tin nhắn riêng
được sử dụng để tạo và xóa thiết bị tổng hợp. Cái này
đường dẫn không sử dụng kênh VMBus.  Xem vmbus_post_msg() và
vmbus_on_msg_dpc().

Bước đầu tiên là để khách kết nối với chung
Cơ chế Hyper-V VMBus.  Là một phần của việc thiết lập kết nối này,
khách và Hyper-V đồng ý về phiên bản giao thức VMBus mà họ sẽ
sử dụng.  Sự đàm phán này cho phép các hạt nhân Linux mới hơn chạy trên các nền tảng cũ hơn
Phiên bản Hyper-V và ngược lại.

Sau đó, khách yêu cầu Hyper-V "gửi phiếu mua hàng".  Hyper-V gửi một
đưa ra thông báo cho khách về từng thiết bị tổng hợp mà VM
được cấu hình để có. Mỗi loại thiết bị VMBus có một GUID cố định
được gọi là "ID lớp" và mỗi phiên bản thiết bị VMBus cũng
được xác định bởi GUID. Thông báo ưu đãi từ Hyper-V chứa
cả hai GUID để nhận dạng duy nhất (trong VM) thiết bị.
Có một thông báo ưu đãi cho từng phiên bản thiết bị, do đó, một VM có
hai NIC tổng hợp sẽ nhận được hai thông báo ưu đãi với NIC
ID lớp. Thứ tự của các thông báo ưu đãi có thể khác nhau tùy theo từng lần khởi động
và không được coi là nhất quán trong mã Linux. ưu đãi
tin nhắn cũng có thể đến rất lâu sau khi Linux khởi động lần đầu
vì Hyper-V hỗ trợ thêm thiết bị, chẳng hạn như NIC tổng hợp,
để chạy VM. Một thông báo ưu đãi mới được xử lý bởi
vmbus_process_offer(), gián tiếp gọi vmbus_add_channel_work().

Khi nhận được tin nhắn ưu đãi, khách nhận diện thiết bị
gõ dựa trên ID lớp và gọi trình điều khiển chính xác để thiết lập
thiết bị.  Việc kết hợp trình điều khiển/thiết bị được thực hiện bằng cách sử dụng tiêu chuẩn
Cơ chế Linux.

Chức năng thăm dò trình điều khiển thiết bị sẽ mở kênh VMBus chính để
VSP tương ứng. Nó phân bổ bộ nhớ khách cho kênh
bộ đệm vòng và chia sẻ bộ đệm vòng với máy chủ Hyper-V bằng cách
cung cấp cho máy chủ danh sách GPA cho bộ nhớ đệm vòng.  Xem
vmbus_etablish_gpadl().

Khi bộ đệm vòng được thiết lập, trình điều khiển thiết bị và trao đổi VSP
thông báo thiết lập qua kênh chính.  Những tin nhắn này có thể bao gồm
đàm phán phiên bản giao thức thiết bị sẽ được sử dụng giữa Linux
VSC và VSP trên máy chủ Hyper-V.  Các thông báo thiết lập cũng có thể
bao gồm việc tạo các kênh VMBus bổ sung, phần nào
bị đặt tên sai là "kênh phụ" vì chúng có chức năng
tương đương với kênh chính khi chúng được tạo.

Cuối cùng, trình điều khiển thiết bị có thể tạo các mục trong /dev như với
bất kỳ trình điều khiển thiết bị nào.

Máy chủ Hyper-V có thể gửi tin nhắn "hủy bỏ" cho khách để
loại bỏ một thiết bị đã được cung cấp trước đó. Trình điều khiển Linux phải
xử lý một tin nhắn hủy bỏ như vậy bất cứ lúc nào. Hủy bỏ một thiết bị
gọi chức năng "xóa" trình điều khiển thiết bị để tắt sạch
xuống thiết bị và loại bỏ nó. Một khi một thiết bị tổng hợp được
bị hủy bỏ, cả Hyper-V lẫn Linux đều không giữ lại bất kỳ trạng thái nào về
sự tồn tại trước đó của nó. Một thiết bị như vậy có thể được bổ sung lại sau này,
trong trường hợp đó nó được coi như một thiết bị hoàn toàn mới. Xem
vmbus_onoffer_rescind().

Đối với một số thiết bị, chẳng hạn như thiết bị KVP, Hyper-V sẽ tự động
gửi tin nhắn hủy khi kênh chính bị đóng,
có thể là do việc hủy liên kết thiết bị khỏi trình điều khiển của nó.
Việc hủy bỏ khiến Linux phải gỡ bỏ thiết bị. Nhưng rồi Hyper-V
ngay lập tức cung cấp lại thiết bị cho khách, gây ra một thiết bị mới
phiên bản của thiết bị được tạo trong Linux. Đối với người khác
các thiết bị, chẳng hạn như các thiết bị SCSI và NIC tổng hợp, đóng
kênh chính khiến ZZ0000ZZ dẫn đến việc Hyper-V gửi lệnh hủy bỏ
tin nhắn. Thiết bị tiếp tục tồn tại trong Linux trên VMBus,
nhưng không có trình điều khiển bị ràng buộc với nó. Trình điều khiển tương tự hoặc trình điều khiển mới
sau đó có thể được liên kết với phiên bản hiện có của thiết bị.