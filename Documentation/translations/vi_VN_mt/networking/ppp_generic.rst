.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/ppp_generic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Giao diện kênh và trình điều khiển chung PPP
========================================

Paul Mackerras
			   paulus@samba.org

7 tháng 2 năm 2002

Trình điều khiển PPP chung trong linux-2.4 cung cấp cách triển khai
chức năng được sử dụng trong mọi triển khai PPP, bao gồm:

* đơn vị giao diện mạng (ppp0, v.v.)
* giao diện với mã mạng
* PPP multilink: chia tách datagram giữa nhiều liên kết và
  sắp xếp và kết hợp các mảnh nhận được
* giao diện với pppd, thông qua thiết bị ký tự /dev/ppp
* nén và giải nén gói
* Nén và giải nén tiêu đề TCP/IP
* phát hiện lưu lượng truy cập mạng để quay số theo yêu cầu và thời gian chờ không hoạt động
* lọc gói đơn giản

Để gửi và nhận các khung PPP, trình điều khiển PPP chung sẽ gọi
các dịch vụ của PPP ZZ0000ZZ.  Kênh PPP đóng gói một
cơ chế vận chuyển khung PPP từ máy này sang máy khác.  A
Việc triển khai kênh PPP có thể phức tạp tùy ý trong nội bộ nhưng
có giao diện rất đơn giản với mã PPP chung: nó chỉ có
để có thể gửi khung PPP, nhận khung PPP và tùy chọn
xử lý các yêu cầu ioctl.  Hiện tại đã có kênh PPP
triển khai cho các cổng nối tiếp không đồng bộ, cổng nối tiếp đồng bộ
cổng và cho PPP qua ethernet.

Kiến trúc này cho phép triển khai đa liên kết PPP trong một
cách tự nhiên và đơn giản, bằng cách cho phép nhiều hơn một kênh
được liên kết với mỗi đơn vị giao diện mạng ppp.  Lớp chung là
chịu trách nhiệm phân tách các datagram khi truyền và kết hợp lại chúng
khi nhận được.


kênh PPP API
---------------

Xem include/linux/ppp_channel.h để biết cách khai báo các loại và
các chức năng được sử dụng để giao tiếp giữa lớp PPP chung và PPP
các kênh.

Mỗi kênh phải cung cấp hai chức năng cho lớp PPP chung,
thông qua con trỏ ppp_channel.ops:

* start_xmit() được gọi bởi lớp chung khi nó có khung
  gửi.  Kênh có tùy chọn từ chối khung cho
  lý do kiểm soát dòng chảy  Trong trường hợp này, start_xmit() sẽ trả về 0
  và kênh sẽ gọi hàm ppp_output_wakeup() tại
  lần sau khi nó có thể chấp nhận lại các khung và lớp chung
  sau đó sẽ cố gắng truyền lại (các) khung bị từ chối.  Nếu khung
  được chấp nhận, hàm start_xmit() sẽ trả về 1.

* ioctl() cung cấp giao diện có thể được sử dụng bởi không gian người dùng
  chương trình để kiểm soát các khía cạnh của hành vi của kênh.  Cái này
  thủ tục sẽ được gọi khi chương trình không gian người dùng thực hiện ioctl
  lệnh gọi hệ thống trên một phiên bản của /dev/ppp được liên kết với
  kênh.  (Thông thường chỉ có pppd mới thực hiện được việc này.)

Lớp PPP chung cung cấp bảy chức năng cho các kênh:

* ppp_register_channel() được gọi khi một kênh đã được tạo, để
  thông báo cho lớp chung PPP về sự hiện diện của nó.  Ví dụ, thiết lập
  một cổng nối tiếp tới kỷ luật dòng PPPDISC gây ra lỗi ppp_async
  mã kênh để gọi chức năng này.

* ppp_unregister_channel() được gọi khi có một kênh
  bị phá hủy.  Ví dụ: mã kênh ppp_async gọi điều này khi
  một sự treo máy được phát hiện trên cổng nối tiếp.

* ppp_output_wakeup() được gọi bởi một kênh khi kênh đó đã gọi trước đó
  đã từ chối lệnh gọi tới hàm start_xmit của nó và hiện có thể chấp nhận thêm
  gói.

* ppp_input() được gọi bởi một kênh khi nó nhận được thông báo hoàn chỉnh
  Khung PPP.

* ppp_input_error() được gọi bởi một kênh khi nó phát hiện thấy một
  khung bị mất hoặc bị rơi (ví dụ: do FCS (khung
  check sequence) error).

* ppp_channel_index() trả về chỉ mục kênh được chỉ định bởi PPP
  lớp chung cho kênh này.  Kênh nên cung cấp một số cách
  (ví dụ: ioctl) để truyền thông tin này trở lại không gian người dùng, dưới dạng không gian người dùng
  sẽ cần nó để đính kèm một phiên bản của /dev/ppp vào kênh này.

* ppp_unit_number() trả về số đơn vị của mạng ppp
  giao diện mà kênh này được kết nối hoặc -1 nếu kênh
  không được kết nối.

Việc kết nối một kênh với lớp chung ppp được bắt đầu từ
mã kênh, chứ không phải từ lớp chung.  Kênh này là
dự kiến ​​sẽ có một số cách để quy trình cấp người dùng kiểm soát nó
độc lập với lớp chung ppp.  Ví dụ, với
kênh ppp_async, điều này được cung cấp bởi bộ mô tả tệp cho
cổng nối tiếp.

Nói chung, quy trình cấp người dùng sẽ khởi tạo cơ sở
phương tiện truyền thông và chuẩn bị cho nó thực hiện PPP.  Ví dụ, với một
tty không đồng bộ, điều này có thể liên quan đến việc thiết lập tốc độ và chế độ tty, đưa ra
các lệnh của modem, sau đó thực hiện một số loại hộp thoại với
hệ thống từ xa để gọi dịch vụ PPP ở đó.  Chúng tôi đề cập đến quá trình này
như ZZ0000ZZ.  Sau đó, quy trình ở cấp độ người dùng sẽ yêu cầu phương tiện
trở thành kênh PPP và tự đăng ký với lớp PPP chung.
Kênh sau đó phải báo cáo lại số kênh được gán cho nó
tới quy trình cấp người dùng.  Từ thời điểm đó, mã đàm phán PPP
trong daemon PPP (pppd) có thể tiếp quản và thực hiện PPP
đàm phán, truy cập kênh thông qua giao diện /dev/ppp.

Tại giao diện của lớp chung PPP, các khung PPP được lưu trữ trong
cấu trúc skbuff và bắt đầu với số giao thức PPP hai byte.
Khung ZZ0002ZZ bao gồm byte 0xff ZZ0000ZZ hoặc 0x03
Byte ZZ0001ZZ được sử dụng tùy chọn trong PPP không đồng bộ.  Cũng không có
bất kỳ sự thoát khỏi ký tự điều khiển nào, cũng như không có bất kỳ FCS hoặc khung nào
bao gồm các ký tự.  Đó hoàn toàn là trách nhiệm của kênh
mã, nếu nó cần thiết cho phương tiện cụ thể.  Đó là, skbuff
được trình bày cho hàm start_xmit() chỉ chứa 2 byte
số giao thức và dữ liệu cũng như skbuff được trình bày cho ppp_input()
phải có cùng định dạng.

Kênh phải cung cấp một phiên bản của cấu trúc ppp_channel để
đại diện cho kênh.  Kênh được sử dụng miễn phí trường ZZ0000ZZ
tuy nhiên nó muốn.  Kênh nên khởi tạo ZZ0001ZZ và
Các trường ZZ0002ZZ trước khi gọi ppp_register_channel() và không thay đổi
chúng cho đến khi ppp_unregister_channel() quay trở lại.  Trường ZZ0003ZZ
đại diện cho kích thước tối đa của phần dữ liệu của khung PPP, đó là
nghĩa là nó không bao gồm số giao thức 2 byte.

Nếu kênh cần một số khoảng trống trong các skbuff được cung cấp cho kênh đó
truyền (tức là, một số không gian trống trong vùng dữ liệu skbuff trước
bắt đầu của khung PPP), nó sẽ đặt trường ZZ0000ZZ của
cấu trúc ppp_channel theo số lượng khoảng trống cần thiết.  Cái chung
Lớp PPP sẽ cố gắng cung cấp nhiều khoảng trống như vậy nhưng kênh
vẫn nên kiểm tra xem có đủ khoảng trống không và sao chép skbuff
nếu không có.

Về phía đầu vào, các kênh lý tưởng nên cung cấp ít nhất 2 byte
khoảng trống trong skbuff được trình bày cho ppp_input().  PPP chung
mã không yêu cầu điều này nhưng sẽ hiệu quả hơn nếu điều này được thực hiện.


Bộ đệm và kiểm soát dòng chảy
--------------------------

Lớp PPP chung đã được thiết kế để giảm thiểu lượng dữ liệu
mà nó đệm theo hướng truyền.  Nó duy trì một hàng đợi
truyền gói cho thiết bị PPP (thiết bị giao diện mạng) cộng với
hàng đợi các gói truyền cho mỗi kênh được đính kèm.  Thông thường
hàng đợi truyền cho thiết bị sẽ chứa tối đa một gói; cái
trường hợp ngoại lệ là khi pppd gửi gói bằng cách ghi vào/dev/ppp và
khi mã mạng lõi gọi start_xmit() của lớp chung
hoạt động với hàng đợi bị dừng, tức là khi lớp chung có
được gọi là netif_stop_queue(), điều này chỉ xảy ra khi hết thời gian truyền.
Hàm start_xmit luôn chấp nhận và xếp hàng gói mà nó
được yêu cầu truyền tải.

Các gói truyền được loại bỏ khỏi hàng đợi truyền đơn vị PPP và
sau đó chịu nén tiêu đề TCP/IP và nén gói
(Nén xì hơi hoặc nén BSD-Compress), nếu thích hợp.  Sau này
điểm các gói không thể được sắp xếp lại nữa, vì quá trình giải nén
Các thuật toán dựa vào việc nhận các gói nén theo cùng thứ tự
chúng đã được tạo ra.

Nếu đa liên kết không được sử dụng, gói này sẽ được chuyển đến liên kết đính kèm.
hàm start_xmit() của kênh.  Nếu kênh từ chối nhận
gói, lớp chung sẽ lưu nó để truyền sau.  các
lớp chung sẽ gọi lại hàm start_xmit() của kênh
khi kênh gọi ppp_output_wakeup() hoặc khi lõi
mã mạng gọi hàm start_xmit() của lớp chung
một lần nữa.  Lớp chung không chứa thời gian chờ và truyền lại
logic; nó dựa vào mã mạng cốt lõi cho việc đó.

Nếu sử dụng nhiều liên kết, lớp chung sẽ chia gói thành một
hoặc nhiều đoạn và đặt tiêu đề đa liên kết trên mỗi đoạn.  Nó
quyết định sử dụng bao nhiêu đoạn dựa trên độ dài của gói
và số lượng kênh có khả năng chấp nhận một
mảnh vỡ vào lúc này.  Một kênh có khả năng có thể chấp nhận một
mảnh nếu nó không có bất kỳ mảnh nào hiện đang xếp hàng cho nó
để truyền tải.  Kênh vẫn có thể từ chối một đoạn; trong trường hợp này
đoạn được xếp hàng đợi để kênh truyền sau.  Cái này
sơ đồ có tác dụng là nhiều mảnh được trao cho cấp cao hơn
các kênh băng thông.  Nó cũng có nghĩa là dưới tải nhẹ, chung
lớp sẽ có xu hướng phân mảnh các gói lớn trên tất cả các kênh,
do đó làm giảm độ trễ, khi chịu tải nặng, các gói sẽ có xu hướng
được truyền dưới dạng các đoạn đơn, do đó làm giảm chi phí của
sự phân mảnh.


SMP an toàn
----------

Lớp chung PPP đã được thiết kế để đảm bảo an toàn cho SMP.  Ổ khóa được
được sử dụng xung quanh quyền truy cập vào cấu trúc dữ liệu nội bộ khi cần thiết
để đảm bảo tính toàn vẹn của chúng.  Là một phần của điều này, lớp chung
yêu cầu các kênh tuân thủ các yêu cầu nhất định và lần lượt
cung cấp những đảm bảo nhất định cho các kênh.  Về cơ bản các kênh
được yêu cầu cung cấp khóa thích hợp trên ppp_channel
các cấu trúc tạo thành cơ sở cho sự giao tiếp giữa các
kênh và lớp chung.  Điều này là do kênh cung cấp
nơi lưu trữ cấu trúc ppp_channel và do đó kênh này là
được yêu cầu cung cấp sự đảm bảo rằng kho lưu trữ này tồn tại và
có hiệu lực vào những thời điểm thích hợp.

Lớp chung yêu cầu những đảm bảo này từ kênh:

* Đối tượng ppp_channel phải tồn tại kể từ thời điểm đó
  ppp_register_channel() được gọi cho đến sau lệnh gọi tới
  ppp_unregister_channel() trả về.

* Không có chuỗi nào có thể được gọi đến bất kỳ ppp_input(), ppp_input_error() nào,
  ppp_output_wakeup(), ppp_channel_index() hoặc ppp_unit_number() cho một
  kênh tại thời điểm ppp_unregister_channel() được gọi cho việc đó
  kênh.

* ppp_register_channel() và ppp_unregister_channel() phải được gọi
  từ bối cảnh quá trình, không làm gián đoạn hoặc bối cảnh softirq/BH.

* Các hàm lớp chung còn lại có thể được gọi tại softirq/BH
  nhưng không được gọi từ trình xử lý ngắt phần cứng.

* Lớp chung có thể gọi hàm start_xmit() của kênh tại
  mức softirq/BH nhưng sẽ không gọi nó ở mức ngắt.  Vì thế
  Hàm start_xmit() có thể không chặn được.

* Lớp chung sẽ chỉ gọi hàm kênh ioctl() trong
  bối cảnh quá trình.

Lớp chung cung cấp những đảm bảo này cho các kênh:

* Lớp chung sẽ không gọi hàm start_xmit() cho
  kênh trong khi bất kỳ luồng nào đang thực thi chức năng đó
  kênh đó.

* Lớp chung sẽ không gọi hàm ioctl() cho một kênh
  trong khi bất kỳ luồng nào đã thực thi chức năng đó cho điều đó
  kênh.

* Vào thời điểm cuộc gọi tới ppp_unregister_channel() trả về, không có chuỗi nào
  sẽ thực hiện cuộc gọi từ lớp chung tới kênh đó
  start_xmit() hoặc ioctl() và lớp chung sẽ không
  gọi một trong những chức năng đó sau đó.


Giao diện với pppd
-----------------

Lớp chung PPP xuất giao diện thiết bị ký tự được gọi là
/dev/ppp.  Điều này được pppd sử dụng để điều khiển các đơn vị giao diện PPP và
các kênh.  Mặc dù chỉ có một /dev/ppp, nhưng mỗi phiên bản mở của
/dev/ppp hoạt động độc lập và có thể được gắn vào thiết bị PPP
hoặc kênh PPP.  Điều này đạt được bằng cách sử dụng trường file->private_data
để trỏ đến một đối tượng riêng biệt cho mỗi phiên bản mở của /dev/ppp.  trong
bằng cách này, thu được hiệu ứng tương tự như mở bản sao của Solaris,
cho phép chúng tôi kiểm soát số lượng giao diện PPP tùy ý và
các kênh mà không cần phải điền vào /dev hàng trăm tên thiết bị.

Khi /dev/ppp được mở, một phiên bản mới được tạo ra ban đầu
không bị ràng buộc.  Bằng cách sử dụng lệnh gọi ioctl, nó có thể được gắn vào một
đơn vị hiện có, gắn với đơn vị mới được tạo, hoặc gắn với đơn vị
kênh hiện có.  Một instance gắn liền với một đơn vị có thể được sử dụng để gửi
và nhận các khung điều khiển PPP, sử dụng hệ thống read() và write()
các cuộc gọi, cùng với poll() nếu cần thiết.  Tương tự, một trường hợp
được gắn vào một kênh có thể được sử dụng để gửi và nhận các khung PPP trên
kênh đó.

Trong thuật ngữ đa liên kết, đơn vị đại diện cho gói, trong khi các kênh
đại diện cho các liên kết vật lý riêng lẻ.  Do đó, khung PPP được gửi bởi một
ghi vào đơn vị (tức là vào một thể hiện của /dev/ppp được gắn vào
unit) sẽ bị nén ở cấp độ gói và bị phân mảnh
trên các liên kết riêng lẻ (nếu đa liên kết được sử dụng).  Ngược lại, một
Khung PPP được gửi bằng cách ghi vào kênh sẽ được gửi nguyên trạng trên đó
kênh mà không có bất kỳ tiêu đề đa liên kết nào.

Một kênh ban đầu không được gắn vào bất kỳ đơn vị nào.  Ở trạng thái này nó có thể
được sử dụng để đàm phán PPP nhưng không được sử dụng để truyền gói dữ liệu.
Sau đó, nó có thể được kết nối với thiết bị PPP bằng lệnh gọi ioctl, lệnh này
làm cho nó sẵn sàng để gửi và nhận các gói dữ liệu cho đơn vị đó.

Các cuộc gọi ioctl khả dụng trên phiên bản /dev/ppp phụ thuộc
về việc nó không được gắn vào, được gắn vào giao diện PPP hay được gắn vào
tới kênh PPP.  Các cuộc gọi ioctl có sẵn trên
trường hợp không được đính kèm là:

* PPPIOCNEWUNIT tạo giao diện PPP mới và tạo /dev/ppp này
  ví dụ "chủ sở hữu" của giao diện.  Lập luận nên chỉ ra
  một int là số đơn vị mong muốn nếu >= 0 hoặc -1 để gán
  số đơn vị chưa sử dụng thấp nhất.  Là chủ sở hữu của giao diện có nghĩa là
  rằng giao diện sẽ bị tắt nếu phiên bản /dev/ppp này bị
  đóng cửa.

* PPPIOCATTACH gắn phiên bản này vào giao diện PPP hiện có.
  Đối số phải trỏ đến một int chứa số đơn vị.
  Điều này không làm cho phiên bản này trở thành chủ sở hữu của giao diện PPP.

* PPPIOCATTCHAN gắn phiên bản này vào kênh PPP hiện có.
  Đối số phải trỏ đến một int chứa số kênh.

Các cuộc gọi ioctl có sẵn trên phiên bản /dev/ppp được gắn vào một
kênh là:

* PPPIOCCONNECT kết nối kênh này với giao diện PPP.  các
  đối số phải trỏ đến một int chứa đơn vị giao diện
  số.  Nó sẽ trả về lỗi EINVAL nếu kênh đã được
  được kết nối với một giao diện hoặc ENXIO nếu giao diện được yêu cầu thực hiện
  không tồn tại.

* PPPIOCDISCONN ngắt kết nối kênh này khỏi giao diện PPP
  nó được kết nối với.  Nó sẽ trả về lỗi EINVAL nếu kênh
  không được kết nối với một giao diện.

* PPPIOCBRIDGECHAN kết nối kênh này với kênh khác. Lập luận nên
  trỏ tới một int chứa số kênh của kênh tới bridge
  đến. Khi hai kênh được bắc cầu, các khung được hiển thị cho một kênh bằng
  ppp_input() được chuyển đến phiên bản cầu nối để truyền tiếp.
  Điều này cho phép các khung được chuyển từ kênh này sang kênh khác: ví dụ:
  ví dụ: để chuyển các khung PPPoE vào phiên PPPoL2TP. Vì kênh
  bắc cầu làm gián đoạn đường dẫn ppp_input() bình thường, một kênh nhất định có thể
  không được là một phần của cây cầu đồng thời là một phần của một đơn vị.
  Ioctl này sẽ trả về lỗi EALREADY nếu kênh đã
  một phần của cầu nối hoặc đơn vị hoặc ENXIO nếu kênh được yêu cầu không
  tồn tại.

* PPPIOCUNBRIDGECHAN thực hiện nghịch đảo PPPIOCBRIDGECHAN, hủy kết nối
  một cặp kênh.  Ioctl này sẽ trả về lỗi EINVAL nếu kênh
  không tạo thành một phần của cây cầu.

* Tất cả các lệnh ioctl khác được chuyển tới hàm kênh ioctl().

Các cuộc gọi ioctl có sẵn trên một phiên bản được đính kèm với
một đơn vị giao diện là:

* PPPIOCSMRU đặt MRU (đơn vị nhận tối đa) cho giao diện.
  Đối số sẽ trỏ đến một int chứa giá trị MRU mới.

* PPPIOCSFLAGS đặt cờ điều khiển hoạt động của
  giao diện.  Đối số phải là một con trỏ tới một int chứa
  giá trị cờ mới.  Các bit trong giá trị cờ có thể được đặt
  là:

==============================================================
	SC_COMP_TCP cho phép truyền nén tiêu đề TCP
	SC_NO_TCP_CCID tắt tính năng nén id kết nối cho
				Nén tiêu đề TCP
	SC_REJ_COMP_TCP vô hiệu hóa nhận giải nén tiêu đề TCP
	Giao thức điều khiển nén SC_CCP_OPEN (CCP) là
				mở, vì vậy hãy kiểm tra các gói CCP
	SC_CCP_UP CCP đã hoạt động, có thể (hủy) nén các gói
	SC_LOOP_TRAFFIC gửi lưu lượng IP tới pppd
	SC_MULTILINK kích hoạt phân mảnh đa liên kết PPP trên
				gói tin được truyền đi
	SC_MP_SHORTSEQ mong đợi chuỗi đa liên kết ngắn
				số trên các đoạn đa liên kết nhận được
	SC_MP_XSHORTSEQ truyền số chuỗi đa liên kết ngắn.
	==============================================================

Giá trị của các cờ này được xác định trong <linux/ppp-ioctl.h>.  Lưu ý
  rằng các giá trị của SC_MULTILINK, SC_MP_SHORTSEQ và
  Các bit SC_MP_XSHORTSEQ bị bỏ qua nếu tùy chọn CONFIG_PPP_MULTILINK
  không được chọn.

* PPPIOCGFLAGS trả về giá trị của cờ trạng thái/điều khiển cho
  đơn vị giao diện.  Đối số sẽ trỏ đến một int trong đó ioctl
  sẽ lưu trữ giá trị cờ.  Cũng như các giá trị được liệt kê ở trên cho
  PPPIOCSFLAGS, các bit sau có thể được đặt trong giá trị trả về:

==============================================================
	Máy nén SC_COMP_RUN CCP đang chạy
	Bộ giải nén SC_DECOMP_RUN CCP đang chạy
	Bộ giải nén SC_DC_ERROR CCP phát hiện lỗi không nghiêm trọng
	Bộ giải nén SC_DC_FERROR CCP phát hiện lỗi nghiêm trọng
	==============================================================

* PPPIOCSCOMPRESS đặt tham số cho việc nén gói hoặc
  giải nén.  Đối số phải trỏ đến ppp_option_data
  cấu trúc (được định nghĩa trong <linux/ppp-ioctl.h>), chứa một
  cặp con trỏ/độ dài sẽ mô tả một khối bộ nhớ
  chứa tùy chọn CCP chỉ định phương thức nén và phương thức nén của nó
  các thông số.  Cấu trúc ppp_option_data cũng chứa ZZ0000ZZ
  lĩnh vực.  Nếu đây là 0, ioctl sẽ ảnh hưởng đến đường dẫn nhận,
  nếu không thì đường truyền.

* PPPIOCGUNIT trả về đơn vị trong int được đối số trỏ đến
  số của đơn vị giao diện này.

* PPPIOCSDEBUG đặt cờ gỡ lỗi cho giao diện thành giá trị trong
  int được chỉ ra bởi đối số.  Chỉ có bit ít quan trọng nhất
  được sử dụng; nếu đây là 1 thì lớp chung sẽ in một số lỗi
  tin nhắn trong quá trình hoạt động của nó.  Điều này chỉ nhằm mục đích gỡ lỗi
  mã lớp PPP chung; nói chung là nó không hữu ích cho công việc
  lý do tại sao kết nối PPP không thành công.

* PPPIOCGDEBUG trả về cờ gỡ lỗi cho giao diện trong int
  được chỉ ra bởi lập luận.

* PPPIOCGIDLE trả về thời gian, tính bằng giây, kể từ dữ liệu cuối cùng
  các gói đã được gửi và nhận.  Lập luận nên hướng tới một
  cấu trúc ppp_idle (được định nghĩa trong <linux/ppp_defs.h>).  Nếu
  Tùy chọn CONFIG_PPP_FILTER được bật, tập hợp các gói được đặt lại
  bộ định thời nhàn rỗi truyền và nhận bị giới hạn ở những bộ định thời
  vượt qua bộ lọc gói ZZ0000ZZ.
  Có hai phiên bản của lệnh này để xử lý không gian người dùng
  thời gian mong đợi là time_t giây 32 bit hoặc 64 bit.

* PPPIOCSMAXCID đặt tham số ID kết nối tối đa (và do đó
  số lượng khe kết nối) cho máy nén tiêu đề TCP và
  máy giải nén.  16 bit thấp hơn của int được trỏ bởi
  đối số chỉ định ID kết nối tối đa cho máy nén.  Nếu
  16 bit trên của int đó khác 0, chúng chỉ định giá trị tối đa
  ID kết nối cho bộ giải nén, nếu không thì của bộ giải nén
  ID kết nối tối đa được đặt thành 15.

* PPPIOCSNPMODE đặt chế độ giao thức mạng cho một mạng nhất định
  giao thức.  Đối số phải trỏ tới một cấu trúc npioctl (được xác định
  trong <linux/ppp-ioctl.h>).  Trường ZZ0000ZZ cung cấp giao thức PPP
  số của giao thức bị ảnh hưởng và trường ZZ0001ZZ
  chỉ định những việc cần làm với các gói cho giao thức đó:

================================================================
	NPMODE_PASS hoạt động bình thường, truyền và nhận gói tin
	NPMODE_DROP âm thầm thả các gói cho giao thức này
	NPMODE_ERROR thả gói và trả về lỗi khi truyền
	NPMODE_QUEUE xếp hàng các gói để truyền, loại bỏ gói nhận
			gói
	================================================================

Hiện tại NPMODE_ERROR và NPMODE_QUEUE có tác dụng tương tự như
  NPMODE_DROP.

* PPPIOCGNPMODE trả về chế độ giao thức mạng cho một
  giao thức.  Đối số sẽ trỏ đến cấu trúc npioctl với
  Trường ZZ0000ZZ được đặt thành số giao thức PPP cho giao thức của
  tiền lãi.  Khi trả lại, trường ZZ0001ZZ sẽ được đặt thành mạng-
  chế độ giao thức cho giao thức đó.

* PPPIOCSPASS và PPPIOCSACTIVE đặt gói ZZ0000ZZ và ZZ0001ZZ
  bộ lọc.  Các ioctls này chỉ khả dụng nếu CONFIG_PPP_FILTER
  tùy chọn được chọn.  Đối số phải trỏ đến sock_fprog
  cấu trúc (được xác định trong <linux/filter.h>) chứa BPF đã biên dịch
  hướng dẫn sử dụng bộ lọc.  Các gói sẽ bị loại bỏ nếu chúng thất bại
  Bộ lọc ZZ0002ZZ; mặt khác, nếu bộ lọc ZZ0003ZZ không đạt thì chúng sẽ
  đã qua nhưng chúng không thiết lập lại bộ đếm thời gian nhàn rỗi truyền hoặc nhận.

* PPPIOCSMRRU kích hoạt hoặc vô hiệu hóa xử lý đa liên kết để nhận
  gói và thiết lập MRRU đa liên kết (nhận được tái tạo tối đa
  đơn vị).  Đối số sẽ trỏ đến một int chứa MRRU mới
  giá trị.  Nếu giá trị MRRU là 0, việc xử lý đa liên kết nhận được
  các mảnh bị vô hiệu hóa.  Ioctl này chỉ khả dụng nếu
  Tùy chọn CONFIG_PPP_MULTILINK được chọn.

Sửa đổi lần cuối: 7 tháng 2 năm 2002