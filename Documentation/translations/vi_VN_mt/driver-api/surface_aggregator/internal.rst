.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/internal.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |ssh_ptl| replace:: :c:type:`struct ssh_ptl <ssh_ptl>`
.. |ssh_ptl_submit| replace:: :c:func:`ssh_ptl_submit`
.. |ssh_ptl_cancel| replace:: :c:func:`ssh_ptl_cancel`
.. |ssh_ptl_shutdown| replace:: :c:func:`ssh_ptl_shutdown`
.. |ssh_ptl_rx_rcvbuf| replace:: :c:func:`ssh_ptl_rx_rcvbuf`
.. |ssh_rtl| replace:: :c:type:`struct ssh_rtl <ssh_rtl>`
.. |ssh_rtl_submit| replace:: :c:func:`ssh_rtl_submit`
.. |ssh_rtl_cancel| replace:: :c:func:`ssh_rtl_cancel`
.. |ssh_rtl_shutdown| replace:: :c:func:`ssh_rtl_shutdown`
.. |ssh_packet| replace:: :c:type:`struct ssh_packet <ssh_packet>`
.. |ssh_packet_get| replace:: :c:func:`ssh_packet_get`
.. |ssh_packet_put| replace:: :c:func:`ssh_packet_put`
.. |ssh_packet_ops| replace:: :c:type:`struct ssh_packet_ops <ssh_packet_ops>`
.. |ssh_packet_base_priority| replace:: :c:type:`enum ssh_packet_base_priority <ssh_packet_base_priority>`
.. |ssh_packet_flags| replace:: :c:type:`enum ssh_packet_flags <ssh_packet_flags>`
.. |SSH_PACKET_PRIORITY| replace:: :c:func:`SSH_PACKET_PRIORITY`
.. |ssh_frame| replace:: :c:type:`struct ssh_frame <ssh_frame>`
.. |ssh_command| replace:: :c:type:`struct ssh_command <ssh_command>`
.. |ssh_request| replace:: :c:type:`struct ssh_request <ssh_request>`
.. |ssh_request_get| replace:: :c:func:`ssh_request_get`
.. |ssh_request_put| replace:: :c:func:`ssh_request_put`
.. |ssh_request_ops| replace:: :c:type:`struct ssh_request_ops <ssh_request_ops>`
.. |ssh_request_init| replace:: :c:func:`ssh_request_init`
.. |ssh_request_flags| replace:: :c:type:`enum ssh_request_flags <ssh_request_flags>`
.. |ssam_controller| replace:: :c:type:`struct ssam_controller <ssam_controller>`
.. |ssam_device| replace:: :c:type:`struct ssam_device <ssam_device>`
.. |ssam_device_driver| replace:: :c:type:`struct ssam_device_driver <ssam_device_driver>`
.. |ssam_client_bind| replace:: :c:func:`ssam_client_bind`
.. |ssam_client_link| replace:: :c:func:`ssam_client_link`
.. |ssam_request_sync| replace:: :c:type:`struct ssam_request_sync <ssam_request_sync>`
.. |ssam_event_registry| replace:: :c:type:`struct ssam_event_registry <ssam_event_registry>`
.. |ssam_event_id| replace:: :c:type:`struct ssam_event_id <ssam_event_id>`
.. |ssam_nf| replace:: :c:type:`struct ssam_nf <ssam_nf>`
.. |ssam_nf_refcount_inc| replace:: :c:func:`ssam_nf_refcount_inc`
.. |ssam_nf_refcount_dec| replace:: :c:func:`ssam_nf_refcount_dec`
.. |ssam_notifier_register| replace:: :c:func:`ssam_notifier_register`
.. |ssam_notifier_unregister| replace:: :c:func:`ssam_notifier_unregister`
.. |ssam_cplt| replace:: :c:type:`struct ssam_cplt <ssam_cplt>`
.. |ssam_event_queue| replace:: :c:type:`struct ssam_event_queue <ssam_event_queue>`
.. |ssam_request_sync_submit| replace:: :c:func:`ssam_request_sync_submit`

===============================
Nội bộ trình điều khiển cốt lõi
===============================

Tổng quan về kiến trúc của lõi Mô-đun tổng hợp hệ thống bề mặt (SSAM)
và trình điều khiển Surface Serial Hub (SSH). Để biết tài liệu về API, hãy tham khảo:

.. toctree::
   :maxdepth: 2

   internal-api


Tổng quan
=========

Việc triển khai lõi SSAM được cấu trúc theo các lớp, phần nào tuân theo
Cấu trúc giao thức SSH:

Vận chuyển gói cấp thấp hơn được triển khai trong lớp vận chuyển gói *
(PTL)*, xây dựng trực tiếp trên thiết bị nối tiếp (serdev)
cơ sở hạ tầng của hạt nhân. Như tên đã chỉ ra, lớp này xử lý
logic vận chuyển gói và xử lý những việc như xác thực gói,
thời gian chờ xác nhận (ACKing), thời gian chờ gói (truyền lại) và chuyển tiếp
tải trọng gói đến các lớp cấp cao hơn.

Phía trên này là ZZ0000ZZ. Lớp này được căn giữa
xung quanh tải trọng gói loại lệnh, tức là các yêu cầu (được gửi từ máy chủ đến EC),
phản hồi của EC đối với các yêu cầu và sự kiện đó (được gửi từ EC đến máy chủ).
Đặc biệt, nó phân biệt các sự kiện với các phản hồi yêu cầu, so khớp
phản hồi các yêu cầu tương ứng của họ và thực hiện thời gian chờ yêu cầu.

Lớp ZZ0002ZZ đang được xây dựng dựa trên điều này và về cơ bản quyết định
cách phản hồi yêu cầu và đặc biệt là các sự kiện được xử lý. Nó cung cấp một
hệ thống thông báo sự kiện, xử lý việc kích hoạt/hủy kích hoạt sự kiện, cung cấp
hàng công việc để hoàn thành sự kiện và yêu cầu không đồng bộ, đồng thời quản lý
bộ đếm thông báo cần thiết để xây dựng thông báo lệnh (ZZ0000ZZ,
ZZ0001ZZ). Lớp này về cơ bản cung cấp giao diện cơ bản cho SAM
EC để sử dụng trong các trình điều khiển hạt nhân khác.

Trong khi lớp điều khiển đã cung cấp giao diện cho kernel khác
trình điều khiển, máy khách ZZ0000ZZ mở rộng giao diện này để cung cấp hỗ trợ cho
các thiết bị SSAM gốc, tức là các thiết bị không được xác định trong ACPI và không
được triển khai dưới dạng thiết bị nền tảng, thông qua ZZ0001ZZ và ZZ0002ZZ
đơn giản hóa việc quản lý các thiết bị khách và trình điều khiển máy khách.

Tham khảo Tài liệu/driver-api/surface_aggregator/client.rst để biết
tài liệu liên quan đến thiết bị/trình điều khiển máy khách API và các tùy chọn giao diện
cho các trình điều khiển kernel khác. Nên làm quen với
chương đó và Tài liệu/driver-api/surface_aggregator/ssh.rst
trước khi tiếp tục với tổng quan về kiến trúc bên dưới.


Lớp vận chuyển gói
======================

Lớp vận chuyển gói được biểu diễn thông qua ZZ0000ZZ và được cấu trúc
xung quanh các khái niệm cơ bản sau:

Gói
-------

Các gói là đơn vị truyền tải cơ bản của giao thức SSH. Họ là
được quản lý bởi lớp vận chuyển gói, về cơ bản là lớp thấp nhất
của trình điều khiển và được xây dựng dựa trên các thành phần khác của lõi SSAM.
Các gói được truyền bởi lõi SSAM được thể hiện qua ZZ0000ZZ
(ngược lại, các gói được nhận bởi lõi không có bất kỳ thông tin cụ thể nào.
cấu trúc và được quản lý hoàn toàn thông qua ZZ0001ZZ thô).

Cấu trúc này chứa các trường bắt buộc để quản lý gói bên trong
lớp vận chuyển cũng như tham chiếu đến bộ đệm chứa dữ liệu tới
được truyền đi (tức là tin nhắn được gói trong ZZ0001ZZ). Đáng chú ý nhất là nó
chứa số tham chiếu nội bộ, được sử dụng để quản lý
trọn đời (có thể truy cập qua ZZ0002ZZ và ZZ0003ZZ). Khi điều này
bộ đếm đạt đến 0, lệnh gọi lại ZZ0000ZZ được cung cấp cho gói thông qua
Tham chiếu ZZ0004ZZ của nó được thực thi, sau đó có thể giải phóng
gói hoặc cấu trúc kèm theo của nó (ví dụ ZZ0005ZZ).

Ngoài lệnh gọi lại ZZ0000ZZ, tham chiếu ZZ0004ZZ cũng
cung cấp một cuộc gọi lại ZZ0001ZZ, được chạy sau khi gói được
đã hoàn thành và cung cấp trạng thái hoàn thành này, tức là không thành công
hoặc giá trị errno âm trong trường hợp có lỗi. Một khi gói tin đã được
được gửi đến lớp truyền tải gói, cuộc gọi lại ZZ0002ZZ được thực hiện
luôn được đảm bảo được thực thi trước lệnh gọi lại ZZ0003ZZ, tức là
gói sẽ luôn được hoàn thành, hoặc thành công, có lỗi hoặc đến hạn.
hủy bỏ trước khi nó được phát hành.

Trạng thái của gói được quản lý thông qua cờ ZZ0000ZZ của nó
(ZZ0001ZZ), cũng chứa loại gói. Đặc biệt,
đáng chú ý những điểm sau:

* ZZ0000ZZ: Bit này được thiết lập khi hoàn thành
  thông qua lỗi hoặc thành công, sắp xảy ra. Nó chỉ ra rằng không còn nữa
  nên lấy các tham chiếu của gói và mọi tham chiếu hiện có
  nên bỏ càng sớm càng tốt. Quá trình thiết lập bit này là
  chịu trách nhiệm xóa mọi tham chiếu đến gói này khỏi gói
  hàng đợi và bộ đang chờ xử lý.

* ZZ0000ZZ: Bit này được thiết lập bởi quá trình chạy chương trình
  Gọi lại ZZ0001ZZ và được sử dụng để đảm bảo rằng cuộc gọi lại này chỉ chạy
  một lần.

* ZZ0000ZZ: Bit này được thiết lập khi gói được xếp hàng đợi
  hàng đợi gói và bị xóa khi nó được loại bỏ.

* ZZ0000ZZ: Bit này được thiết lập khi gói được thêm vào
  bộ đang chờ xử lý và bị xóa khi nó bị xóa khỏi nó.

Hàng đợi gói
------------

Hàng đợi gói là hàng đợi đầu tiên trong hai tập hợp cơ bản trong
lớp vận chuyển gói. Đây là hàng đợi ưu tiên, với mức độ ưu tiên của
các gói tương ứng dựa trên loại gói (chính) và số lần thử
(nhỏ). Xem ZZ0000ZZ để biết thêm chi tiết về giá trị ưu tiên.

Tất cả các gói được truyền bởi lớp vận chuyển phải được gửi đến
hàng đợi này thông qua ZZ0000ZZ. Lưu ý rằng điều này bao gồm các gói điều khiển
được gửi bởi chính lớp vận chuyển. Trong nội bộ, các gói dữ liệu có thể được
được gửi lại vào hàng đợi này do hết thời gian chờ hoặc các gói NAK do EC gửi.

Bộ đang chờ xử lý
-----------------

Bộ đang chờ xử lý là bộ sưu tập thứ hai trong số hai bộ sưu tập cơ bản trong
lớp vận chuyển gói. Nó lưu trữ các tham chiếu đến các gói đã được
đã được truyền đi nhưng hãy chờ xác nhận (ví dụ: ACK tương ứng
gói) bởi EC.

Lưu ý rằng một gói có thể đang chờ xử lý và được xếp hàng đợi nếu nó đã được
được gửi lại do hết thời gian chờ xác nhận gói hoặc NAK. Trên một
gửi lại, các gói sẽ không bị xóa khỏi bộ đang chờ xử lý.

Chủ đề máy phát
------------------

Dây truyền chịu trách nhiệm cho hầu hết các công việc thực tế liên quan đến
truyền gói tin. Trong mỗi lần lặp, nó (chờ và) kiểm tra xem
gói tiếp theo trong hàng đợi (nếu có) có thể được truyền đi và nếu có thì sẽ loại bỏ nó
từ hàng đợi và tăng bộ đếm của nó đối với số lần truyền
nỗ lực, tức là cố gắng. Nếu gói được sắp xếp theo thứ tự, tức là yêu cầu ACK bằng
EC, gói sẽ được thêm vào tập đang chờ xử lý. Tiếp theo, dữ liệu của gói được
được gửi tới hệ thống con serdev. Trong trường hợp có lỗi hoặc hết thời gian chờ trong quá trình
lần gửi này, gói được hoàn thành bởi luồng máy phát với
giá trị trạng thái của lệnh gọi lại được đặt tương ứng. Trong trường hợp gói tin được
không có trình tự, tức là không yêu cầu ACK bởi EC, gói được hoàn thành
với thành công trên sợi truyền.

Việc truyền các gói theo trình tự bị giới hạn bởi số lượng gói đồng thời
các gói đang chờ xử lý, tức là giới hạn số lượng gói có thể đang chờ ACK
từ EC song song. Giới hạn này hiện được đặt thành một (xem
Documentation/driver-api/surface_aggregator/ssh.rst cho lý do đằng sau
cái này). Các gói điều khiển (tức là ACK và NAK) luôn có thể được truyền đi.

Chủ đề nhận
---------------

Mọi dữ liệu nhận được từ EC sẽ được đưa vào bộ đệm FIFO để tiếp tục
xử lý. Quá trình xử lý này xảy ra trên luồng nhận. Người nhận
luồng phân tích cú pháp và xác thực tin nhắn đã nhận vào ZZ0000ZZ của nó và
tải trọng tương ứng. Nó chuẩn bị và gửi ACK cần thiết (và trên
lỗi xác thực hoặc gói dữ liệu không hợp lệ NAK) cho các tin nhắn đã nhận.

Chuỗi này cũng xử lý các xử lý tiếp theo, chẳng hạn như khớp các tin nhắn ACK
đến gói đang chờ xử lý tương ứng (thông qua ID chuỗi) và hoàn thành nó, như
cũng như bắt đầu gửi lại tất cả các gói tin hiện đang chờ xử lý trên
nhận được tin nhắn NAK (gửi lại trong trường hợp NAK tương tự như
gửi lại do hết thời gian chờ, xem bên dưới để biết thêm chi tiết về điều đó). Lưu ý rằng
việc hoàn thành thành công một gói được sắp xếp theo thứ tự sẽ luôn chạy trên
luồng nhận (trong khi mọi quá trình hoàn thành chỉ báo lỗi sẽ chạy trên
quá trình xảy ra lỗi).

Mọi dữ liệu tải trọng đều được chuyển tiếp thông qua lệnh gọi lại tới lớp trên tiếp theo, tức là.
lớp vận chuyển yêu cầu.

Máy gặt hết thời gian
---------------------

Thời gian chờ xác nhận gói là thời gian chờ cho mỗi gói để xử lý theo trình tự
các gói, bắt đầu khi gói tương ứng bắt đầu truyền (lại) (tức là
thời gian chờ này được trang bị một lần cho mỗi lần truyền trên máy phát
chủ đề). Nó được sử dụng để kích hoạt gửi lại hoặc khi số lần thử
đã vượt quá, hãy hủy gói được đề cập.

Thời gian chờ này được xử lý thông qua một tác vụ gặt chuyên dụng, về cơ bản là một tác vụ
mục công việc (lại) được lên lịch để chạy khi gói tiếp theo được đặt hết thời gian chờ. các
mục công việc sau đó kiểm tra tập hợp các gói đang chờ xem có gói nào có
vượt quá thời gian chờ và nếu còn gói nào, hãy lên lịch lại
đến thời điểm thích hợp tiếp theo.

Nếu máy gặt phát hiện thời gian chờ, gói sẽ được
được gửi lại nếu nó vẫn còn một số lần thử còn lại hoặc đã hoàn thành với
ZZ0000ZZ làm trạng thái nếu không. Lưu ý rằng việc nộp lại, trong trường hợp này và
được kích hoạt khi nhận được NAK, có nghĩa là gói được thêm vào hàng đợi
với số lần thử ngày càng tăng, mang lại mức độ ưu tiên cao hơn. các
thời gian chờ cho gói sẽ bị vô hiệu hóa cho đến lần truyền tiếp theo
và gói vẫn ở trạng thái chờ xử lý.

Lưu ý rằng do thời gian chờ truyền và xác nhận gói, gói
Lớp vận chuyển luôn được đảm bảo tiến bộ nếu chỉ thông qua
hết thời gian chờ các gói và sẽ không bao giờ chặn hoàn toàn.

Đồng thời và khóa
-----------------------

Có hai khóa chính trong lớp vận chuyển gói: Một khóa bảo vệ quyền truy cập
vào hàng đợi gói và một quyền truy cập bảo vệ vào tập hợp đang chờ xử lý. Những cái này
bộ sưu tập chỉ có thể được truy cập và sửa đổi theo khóa tương ứng. Nếu
cần có quyền truy cập vào cả hai bộ sưu tập, phải có được khóa đang chờ xử lý
trước khi khóa hàng đợi để tránh bế tắc.

Ngoài việc bảo vệ các bộ sưu tập, sau khi gửi gói đầu tiên
một số trường gói nhất định chỉ có thể được truy cập theo một trong các khóa.
Cụ thể, mức độ ưu tiên của gói chỉ được truy cập khi giữ nút
khóa hàng đợi và dấu thời gian gói chỉ được truy cập trong khi giữ
khóa đang chờ xử lý.

Các phần khác của lớp vận chuyển gói được bảo vệ độc lập. tiểu bang
cờ được quản lý bởi các hoạt động bit nguyên tử và, nếu cần thiết, bộ nhớ
rào cản. Sửa đổi mục công việc gặt thời gian chờ và ngày hết hạn
được bảo vệ bởi khóa riêng của họ.

Tham chiếu của gói đến lớp vận chuyển gói (ZZ0000ZZ) là
hơi đặc biệt. Nó được đặt khi yêu cầu lớp trên được gửi
hoặc, nếu không có, khi gói được gửi lần đầu tiên. Sau khi được thiết lập,
nó sẽ không thay đổi giá trị của nó. Các chức năng có thể chạy đồng thời với
việc gửi, tức là hủy, không thể dựa vào tham chiếu ZZ0001ZZ để được
thiết lập. Quyền truy cập vào nó trong các chức năng này được bảo vệ bởi ZZ0002ZZ, trong khi
cài đặt ZZ0003ZZ được bảo vệ như nhau với ZZ0004ZZ về tính đối xứng.

Một số trường gói có thể được đọc bên ngoài các khóa bảo vệ tương ứng
chúng, mức độ ưu tiên và trạng thái cụ thể để truy tìm. Trong những trường hợp đó, thích hợp
quyền truy cập được đảm bảo bằng cách sử dụng ZZ0000ZZ và ZZ0001ZZ. Như vậy
quyền truy cập chỉ đọc chỉ được phép khi các giá trị cũ không quan trọng.

Đối với giao diện của các lớp cao hơn, việc gửi gói
(ZZ0000ZZ), hủy gói (ZZ0001ZZ), nhận dữ liệu
(ZZ0002ZZ) và tắt lớp (ZZ0003ZZ) luôn có thể
được thực hiện đồng thời đối với nhau. Lưu ý gói tin đó
việc gửi có thể không chạy đồng thời với chính nó cho cùng một gói.
Tương tự, việc tắt máy và nhận dữ liệu cũng có thể không chạy đồng thời với
chính chúng (nhưng có thể chạy đồng thời với nhau).


Yêu cầu lớp vận chuyển
=======================

Lớp vận chuyển yêu cầu được thể hiện thông qua ZZ0000ZZ và được xây dựng trên cùng
của lớp vận chuyển gói. Nó xử lý các yêu cầu, tức là các gói SSH được gửi
bởi máy chủ chứa ZZ0001ZZ làm tải trọng khung. Lớp này
tách biệt các phản hồi đối với các yêu cầu khỏi các sự kiện cũng được EC gửi
thông qua tải trọng ZZ0002ZZ. Trong khi các phản hồi được xử lý ở lớp này,
các sự kiện được chuyển tiếp đến lớp trên tiếp theo, tức là lớp điều khiển, thông qua
cuộc gọi lại tương ứng. Lớp vận chuyển yêu cầu được cấu trúc xung quanh
những khái niệm chủ yếu sau:

Lời yêu cầu
-----------

Yêu cầu là các gói có tải trọng kiểu lệnh, được gửi từ máy chủ đến EC tới
truy vấn dữ liệu từ hoặc kích hoạt một hành động trên đó (hoặc cả hai cùng một lúc). Họ
được đại diện bởi ZZ0000ZZ, bao bọc ZZ0001ZZ bên dưới
lưu trữ dữ liệu tin nhắn của nó (tức là khung SSH có tải trọng lệnh). Lưu ý rằng
tất cả các đại diện cấp cao nhất, ví dụ: ZZ0002ZZ được xây dựng dựa trên điều này
struct.

Khi ZZ0001ZZ mở rộng ZZ0002ZZ, thời gian tồn tại của nó cũng được quản lý bởi
bộ đếm tham chiếu bên trong cấu trúc gói (có thể được truy cập thông qua
ZZ0003ZZ và ZZ0004ZZ). Khi bộ đếm đạt tới số 0,
Cuộc gọi lại ZZ0000ZZ của tham chiếu ZZ0005ZZ của yêu cầu là
được gọi.

Các yêu cầu có thể có phản hồi tùy chọn được gửi đều qua SSH
tin nhắn có tải trọng loại lệnh (từ EC đến máy chủ). Đảng xây dựng
yêu cầu phải biết liệu có phản hồi hay không và đánh dấu điều này trong yêu cầu
cờ được cung cấp cho ZZ0000ZZ, để lớp truyền tải yêu cầu
có thể chờ đợi phản hồi này.

Tương tự như ZZ0001ZZ, ZZ0002ZZ cũng có lệnh gọi lại ZZ0000ZZ
được cung cấp thông qua tham chiếu hoạt động yêu cầu của nó và được đảm bảo hoàn thành
trước khi nó được phát hành sau khi nó đã được gửi đến yêu cầu vận chuyển
lớp thông qua ZZ0003ZZ. Đối với một yêu cầu không có phản hồi, thành công
hoàn thành sẽ xảy ra khi gói cơ bản đã được thành công
được truyền bởi lớp vận chuyển gói (tức là từ bên trong gói
gọi lại hoàn thành). Đối với một yêu cầu có phản hồi, hoàn thành thành công
sẽ xảy ra sau khi nhận được phản hồi và khớp với yêu cầu
thông qua ID yêu cầu của nó (xảy ra trên dữ liệu nhận được của lớp gói
gọi lại đang chạy trên luồng nhận). Nếu yêu cầu được hoàn thành với
một lỗi, giá trị trạng thái sẽ được đặt thành lỗi (âm) tương ứng
giá trị.

Trạng thái của yêu cầu lại được quản lý thông qua cờ ZZ0000ZZ của nó
(ZZ0001ZZ), cũng mã hóa loại yêu cầu. Đặc biệt,
đáng chú ý những điểm sau:

* ZZ0000ZZ: Bit này được thiết lập khi hoàn thành
  thông qua lỗi hoặc thành công, sắp xảy ra. Nó chỉ ra rằng không còn nữa
  nên lấy các tài liệu tham khảo của yêu cầu và mọi tài liệu tham khảo hiện có
  nên bỏ càng sớm càng tốt. Quá trình thiết lập bit này là
  chịu trách nhiệm xóa mọi tham chiếu đến yêu cầu này khỏi yêu cầu
  hàng đợi và bộ đang chờ xử lý.

* ZZ0000ZZ: Bit này được thiết lập bởi quá trình chạy chương trình
  Gọi lại ZZ0001ZZ và được sử dụng để đảm bảo rằng cuộc gọi lại này chỉ chạy
  một lần.

* ZZ0000ZZ: Bit này được thiết lập khi yêu cầu được xếp hàng đợi
  hàng đợi yêu cầu và bị xóa khi nó được loại bỏ.

* ZZ0000ZZ: Bit này được thiết lập khi yêu cầu được thêm vào
  bộ đang chờ xử lý và bị xóa khi nó bị xóa khỏi nó.

Hàng đợi yêu cầu
----------------

Hàng đợi yêu cầu là hàng đợi đầu tiên trong hai bộ sưu tập cơ bản trong
yêu cầu lớp vận chuyển. Ngược lại với hàng đợi gói của gói
lớp vận chuyển, nó không phải là hàng đợi ưu tiên và đơn giản là đến trước
áp dụng nguyên tắc giao bóng.

Tất cả các yêu cầu được truyền bởi lớp vận chuyển yêu cầu phải được
được gửi tới hàng đợi này thông qua ZZ0000ZZ. Sau khi được gửi, các yêu cầu có thể
không được gửi lại và sẽ không được gửi lại tự động khi hết thời gian chờ.
Thay vào đó, yêu cầu được hoàn thành với lỗi hết thời gian chờ. Nếu muốn,
người gọi có thể tạo và gửi yêu cầu mới để thử lại, nhưng không được
gửi lại yêu cầu tương tự.

Bộ đang chờ xử lý
-----------------

Bộ đang chờ xử lý là bộ sưu tập thứ hai trong số hai bộ sưu tập cơ bản trong
yêu cầu lớp vận chuyển. Bộ sưu tập này lưu trữ các tham chiếu đến tất cả các
yêu cầu, tức là các yêu cầu đang chờ phản hồi từ EC (tương tự như yêu cầu
tập đang chờ xử lý của lớp vận chuyển gói dành cho các gói).

Nhiệm vụ phát
----------------

Nhiệm vụ truyền được lên lịch khi có yêu cầu mới cho
truyền tải. Nó kiểm tra xem yêu cầu tiếp theo trong hàng đợi yêu cầu có thể được thực hiện hay không
được truyền đi và, nếu vậy, sẽ gửi gói cơ bản của nó tới gói
lớp vận chuyển. Việc kiểm tra này đảm bảo rằng chỉ một số lượng hạn chế các
các yêu cầu có thể đang chờ xử lý, tức là chờ phản hồi cùng một lúc. Nếu
yêu cầu yêu cầu phản hồi, yêu cầu sẽ được thêm vào nhóm đang chờ xử lý
trước khi gói của nó được gửi đi.

Gọi lại hoàn thành gói
--------------------------

Lệnh gọi lại hoàn thành gói được thực thi khi gói cơ bản của
yêu cầu đã được hoàn thành. Trong trường hợp hoàn thành có lỗi,
yêu cầu tương ứng được hoàn thành với giá trị lỗi được cung cấp trong này
gọi lại.

Khi hoàn thành gói thành công, việc xử lý tiếp theo tùy thuộc vào yêu cầu.
Nếu yêu cầu mong đợi phản hồi, nó sẽ được đánh dấu là đã truyền và
thời gian chờ yêu cầu được bắt đầu. Nếu yêu cầu không mong đợi phản hồi thì đó là
hoàn thành thành công.

Gọi lại dữ liệu đã nhận
-----------------------

Dữ liệu nhận được gọi lại thông báo cho lớp dữ liệu vận chuyển yêu cầu
được lớp vận chuyển gói bên dưới nhận thông qua kiểu dữ liệu
khung. Nói chung, đây dự kiến ​​sẽ là một tải trọng kiểu lệnh.

Nếu ID yêu cầu của lệnh là một trong những ID yêu cầu dành riêng cho
các sự kiện (bao gồm một tới ZZ0000ZZ), nó sẽ được chuyển tiếp tới
gọi lại sự kiện đã đăng ký trong lớp truyền tải yêu cầu. Nếu ID yêu cầu
cho biết phản hồi cho một yêu cầu, yêu cầu tương ứng sẽ được tra cứu trong
tập đang chờ xử lý và, nếu được tìm thấy và đánh dấu là đã truyền, sẽ hoàn thành với
thành công.

Máy gặt hết thời gian
---------------------

Yêu cầu-phản hồi-hết thời gian chờ là thời gian chờ cho mỗi yêu cầu đối với các yêu cầu mong đợi
một phản hồi. Nó được sử dụng để đảm bảo rằng một yêu cầu không chờ đợi vô thời hạn
dựa trên phản hồi từ EC và được bắt đầu sau khi gói cơ bản được
được hoàn thành thành công.

Thời gian chờ này tương tự như thời gian chờ xác nhận gói trên gói
lớp vận chuyển, được xử lý thông qua một tác vụ gặt chuyên dụng. Nhiệm vụ này là
về cơ bản là một mục công việc (lại) được lên lịch để chạy khi yêu cầu tiếp theo được đặt
để hết thời gian. Sau đó, mục công việc sẽ quét tập hợp các yêu cầu đang chờ xử lý để tìm bất kỳ
các yêu cầu đã hết thời gian chờ và hoàn thành chúng với ZZ0000ZZ như
trạng thái. Yêu cầu sẽ không được gửi lại tự động. Thay vào đó, nhà phát hành
của yêu cầu phải xây dựng và gửi yêu cầu mới, nếu muốn.

Lưu ý rằng thời gian chờ này, kết hợp với việc truyền gói và
hết thời gian xác nhận, đảm bảo rằng lớp yêu cầu sẽ luôn thực hiện
tiến bộ, ngay cả khi chỉ thông qua việc định thời gian chờ các gói và không bao giờ chặn hoàn toàn.

Đồng thời và khóa
-----------------------

Tương tự như lớp vận chuyển gói, có hai khóa chính trong
Lớp vận chuyển yêu cầu: Một lớp bảo vệ quyền truy cập vào hàng đợi yêu cầu và một lớp
bảo vệ quyền truy cập vào bộ đang chờ xử lý. Những bộ sưu tập này chỉ có thể được truy cập
và sửa đổi theo khóa tương ứng.

Các phần khác của lớp vận chuyển yêu cầu được bảo vệ độc lập. tiểu bang
các cờ được (một lần nữa) quản lý bởi các hoạt động bit nguyên tử và, nếu cần, bộ nhớ
rào cản. Sửa đổi mục công việc gặt thời gian chờ và ngày hết hạn
được bảo vệ bởi khóa riêng của họ.

Một số trường yêu cầu có thể được đọc bên ngoài các khóa bảo vệ tương ứng
chúng, đặc biệt là trạng thái để truy tìm. Trong những trường hợp đó, quyền truy cập thích hợp là
được đảm bảo bằng cách sử dụng ZZ0000ZZ và ZZ0001ZZ. Chỉ đọc như vậy
quyền truy cập chỉ được phép khi các giá trị cũ không quan trọng.

Đối với giao diện của các lớp cao hơn, việc gửi yêu cầu
(ZZ0000ZZ), hủy yêu cầu (ZZ0001ZZ) và lớp
tắt máy (ZZ0002ZZ) luôn có thể được thực thi đồng thời với
tôn trọng lẫn nhau. Lưu ý rằng việc gửi yêu cầu có thể không chạy đồng thời
với chính nó cho cùng một yêu cầu (và cũng chỉ có thể được gọi một lần cho mỗi
yêu cầu). Tương tự, việc tắt máy cũng có thể không chạy đồng thời với chính nó.


Lớp điều khiển
================

Lớp điều khiển mở rộng trên lớp vận chuyển yêu cầu để cung cấp
giao diện dễ sử dụng cho trình điều khiển máy khách. Nó được đại diện bởi
ZZ0000ZZ và trình điều khiển SSH. Trong khi các lớp vận chuyển cấp thấp hơn
đảm nhiệm việc truyền và xử lý các gói và yêu cầu, bộ điều khiển
lớp đảm nhận vai trò quản lý nhiều hơn. Cụ thể, nó xử lý thiết bị
khởi tạo, quản lý năng lượng và xử lý sự kiện, bao gồm cả sự kiện
giao hàng và đăng ký thông qua hệ thống hoàn thành (sự kiện) (ZZ0001ZZ).

Đăng ký sự kiện
------------------

Nói chung, một sự kiện (hay đúng hơn là một lớp sự kiện) phải được xác định rõ ràng.
được máy chủ yêu cầu trước khi EC gửi nó (các sự kiện đầu vào HID dường như
là ngoại lệ). Điều này được thực hiện thông qua yêu cầu kích hoạt sự kiện (tương tự,
các sự kiện sẽ bị vô hiệu hóa thông qua yêu cầu vô hiệu hóa sự kiện một lần nữa
mong muốn).

Yêu cầu cụ thể được sử dụng để bật (hoặc tắt) một sự kiện được đưa ra thông qua
cơ quan đăng ký sự kiện, tức là cơ quan quản lý sự kiện này (có thể nói như vậy),
được đại diện bởi ZZ0000ZZ. Là tham số cho yêu cầu này,
danh mục mục tiêu và tùy thuộc vào sổ đăng ký sự kiện, ID phiên bản của
sự kiện được kích hoạt phải được cung cấp. ID phiên bản (tùy chọn) này phải là
0 nếu sổ đăng ký không sử dụng nó. Cùng nhau, danh mục mục tiêu và ví dụ
ID tạo thành ID sự kiện, được biểu thị bằng ZZ0001ZZ. Tóm lại, cả hai, sự kiện
ID đăng ký và sự kiện, được yêu cầu để xác định duy nhất một lớp tương ứng
của các sự kiện.

Lưu ý rằng phải cung cấp thêm tham số ZZ0001ZZ cho
yêu cầu kích hoạt sự kiện. Tham số này không ảnh hưởng đến loại sự kiện
đang được bật mà thay vào đó được đặt làm ID yêu cầu (RQID) trên mỗi sự kiện của
lớp này được gửi bởi EC. Nó được sử dụng để xác định các sự kiện (dưới dạng giới hạn
số lượng ID yêu cầu chỉ được dành riêng để sử dụng trong các sự kiện, cụ thể là một
bao gồm ZZ0000ZZ) và cũng ánh xạ các sự kiện tới các sự kiện cụ thể của chúng
lớp học. Hiện tại, bộ điều khiển luôn đặt tham số này cho mục tiêu
danh mục được chỉ định trong ZZ0002ZZ.

Vì nhiều trình điều khiển máy khách có thể dựa vào cùng một lớp (hoặc chồng chéo)
các sự kiện và các cuộc gọi bật/tắt đều hoàn toàn nhị phân (tức là bật/tắt),
bộ điều khiển phải quản lý quyền truy cập vào các sự kiện này. Nó làm như vậy thông qua tài liệu tham khảo
đếm, lưu trữ bộ đếm bên trong ánh xạ dựa trên cây RB với sự kiện
sổ đăng ký và ID làm khóa (không có danh sách sổ đăng ký sự kiện hợp lệ và
kết hợp ID sự kiện). Xem ZZ0000ZZ, ZZ0001ZZ và
ZZ0002ZZ để biết chi tiết.

Việc quản lý này được thực hiện cùng với việc đăng ký người thông báo (được mô tả trong phần
phần tiếp theo) thông qua ZZ0000ZZ cấp cao nhất và
Chức năng ZZ0001ZZ.

Phân phối sự kiện
-----------------

Để nhận sự kiện, trình điều khiển máy khách phải đăng ký trình thông báo sự kiện thông qua
ZZ0000ZZ. Điều này làm tăng bộ đếm tham chiếu cho điều đó
lớp sự kiện cụ thể (như được trình bày chi tiết ở phần trước), cho phép
class trên EC (nếu nó chưa được kích hoạt) và cài đặt
cung cấp cuộc gọi lại thông báo.

Lệnh gọi lại của trình thông báo được lưu trữ trong danh sách, với một danh sách (RCU) cho mỗi mục tiêu
danh mục (được cung cấp thông qua ID sự kiện; NB: có một số lượng cố định đã biết
loại mục tiêu). Không có mối liên quan nào được biết đến từ sự kết hợp của
đăng ký sự kiện và ID sự kiện vào dữ liệu lệnh (ID mục tiêu, danh mục mục tiêu,
ID lệnh và ID phiên bản) có thể được cung cấp bởi một lớp sự kiện, ngoài
từ danh mục mục tiêu và ID phiên bản được cung cấp thông qua ID sự kiện.

Lưu ý rằng do cách lưu trữ (hoặc đúng hơn là phải) các trình thông báo, ứng dụng khách
người lái xe có thể nhận được các sự kiện mà họ không yêu cầu và cần phải tính đến
cho họ. Cụ thể, theo mặc định, họ sẽ nhận tất cả các sự kiện từ
cùng một loại mục tiêu. Để đơn giản hóa việc giải quyết vấn đề này, hãy lọc các sự kiện theo
ID mục tiêu (được cung cấp qua sổ đăng ký sự kiện) và ID phiên bản (được cung cấp qua
ID sự kiện) có thể được yêu cầu khi đăng ký người thông báo. Quá trình lọc này
được áp dụng khi lặp qua các trình thông báo tại thời điểm chúng được thực thi.

Tất cả các lệnh gọi lại của trình thông báo được thực thi trên một hàng làm việc chuyên dụng, được gọi là
hoàn thành công việc. Sau khi một sự kiện đã được nhận thông qua cuộc gọi lại
được cài đặt trong lớp yêu cầu (chạy trên luồng nhận của gói
lớp vận chuyển), nó sẽ được đưa vào hàng đợi sự kiện tương ứng
(ZZ0000ZZ). Từ hàng đợi sự kiện này, hạng mục công việc hoàn thành của sự kiện đó
hàng đợi (chạy trên hàng đợi hoàn thành) sẽ nhận sự kiện và
thực hiện cuộc gọi lại thông báo. Điều này được thực hiện để tránh bị chặn trên
sợi nhận.

Có một hàng đợi sự kiện cho mỗi sự kết hợp giữa ID mục tiêu và danh mục mục tiêu.
Điều này được thực hiện để đảm bảo rằng các cuộc gọi lại của trình thông báo được thực hiện theo trình tự cho
các sự kiện có cùng ID mục tiêu và danh mục mục tiêu. Cuộc gọi lại có thể được thực hiện
song song cho các sự kiện có sự kết hợp khác nhau giữa ID mục tiêu và mục tiêu
thể loại.

Đồng thời và khóa
-----------------------

Hầu hết các đảm bảo an toàn liên quan đến đồng thời của bộ điều khiển đều
được cung cấp bởi lớp vận chuyển yêu cầu cấp thấp hơn. Thêm vào đó,
đăng ký sự kiện (không) được bảo vệ bằng khóa riêng của nó.

Quyền truy cập vào trạng thái bộ điều khiển được bảo vệ bằng khóa trạng thái. Khóa này là một
đọc/ghi semaphore. Phần reader có thể được sử dụng để đảm bảo rằng trạng thái
không thay đổi trong khi các chức năng tùy thuộc vào trạng thái giữ nguyên
(ví dụ: ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ và các công cụ phái sinh) được thực thi và đảm bảo này
chưa được cung cấp theo cách khác (ví dụ: thông qua ZZ0003ZZ hoặc
ZZ0004ZZ). Phần người viết bảo vệ mọi chuyển đổi sẽ thay đổi
trạng thái, tức là khởi tạo, hủy bỏ, đình chỉ và tiếp tục.

Trạng thái bộ điều khiển có thể được truy cập (chỉ đọc) bên ngoài khóa trạng thái đối với
kiểm tra khói đối với việc sử dụng API không hợp lệ (ví dụ: trong ZZ0002ZZ).
Lưu ý rằng việc kiểm tra như vậy không có nghĩa vụ (và sẽ không) bảo vệ khỏi tất cả
những cách sử dụng không hợp lệ mà nhằm mục đích giúp nắm bắt chúng. Trong những trường hợp đó, thích hợp
quyền truy cập thay đổi được đảm bảo bằng cách sử dụng ZZ0000ZZ và ZZ0001ZZ.

Giả sử mọi điều kiện tiên quyết về trạng thái không thay đổi đều được thỏa mãn,
tất cả các chức năng không khởi tạo và không tắt máy có thể chạy đồng thời với
lẫn nhau. Điều này bao gồm ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, cũng như tất cả các chức năng được xây dựng dựa trên những chức năng đó.