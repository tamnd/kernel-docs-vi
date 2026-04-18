.. SPDX-License-Identifier: (GPL-2.0-only OR BSD-2-Clause)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/tls-offload.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Giảm tải hạt nhân TLS
=====================

Hoạt động của hạt nhân TLS
==========================

Nhân Linux cung cấp cơ sở hạ tầng giảm tải kết nối TLS. Từng là TCP
kết nối ở trạng thái ZZ0001ZZ, không gian người dùng có thể kích hoạt TLS Upper
Giao thức lớp (ULP) và cài đặt trạng thái kết nối mật mã.
Để biết chi tiết về giao diện người dùng, hãy tham khảo TLS
tài liệu trong ZZ0000ZZ.

ZZ0000ZZ có thể hoạt động ở ba chế độ:

* Chế độ mã hóa phần mềm (ZZ0000ZZ) - CPU xử lý mật mã.
   Trong hầu hết các trường hợp cơ bản, chỉ có hoạt động mã hóa đồng bộ với CPU
   có thể được sử dụng, nhưng tùy thuộc vào ngữ cảnh gọi CPU có thể sử dụng
   máy gia tốc tiền điện tử không đồng bộ. Việc sử dụng máy gia tốc mang lại thêm
   độ trễ khi đọc ổ cắm (quá trình giải mã chỉ bắt đầu khi lệnh đọc tòa nhà
   được thực hiện) và tải I/O bổ sung trên hệ thống.
 * Chế độ giảm tải NIC dựa trên gói (ZZ0001ZZ) - NIC xử lý tiền điện tử
   trên cơ sở từng gói, miễn là các gói đến theo thứ tự.
   Chế độ này tích hợp tốt nhất với kernel stack và được mô tả chi tiết
   trong phần còn lại của tài liệu này
   (ZZ0002ZZ cờ ZZ0003ZZ và ZZ0004ZZ).
 * Chế độ giảm tải TCP NIC đầy đủ (ZZ0005ZZ) - chế độ hoạt động trong đó
   Trình điều khiển và chương trình cơ sở NIC thay thế ngăn xếp mạng hạt nhân
   với khả năng xử lý TCP của riêng nó, nó không thể sử dụng được trong môi trường sản xuất
   sử dụng ngăn xếp mạng Linux chẳng hạn như bất kỳ tường lửa nào
   khả năng hoặc QoS và lập lịch gói (cờ ZZ0006ZZ ZZ0007ZZ).

Chế độ hoạt động được chọn tự động dựa trên cấu hình thiết bị,
tính năng chọn tham gia hoặc chọn không tham gia giảm tải trên cơ sở mỗi kết nối hiện không được hỗ trợ.

TX
--

Ở cấp độ cao, yêu cầu ghi của người dùng được chuyển thành danh sách phân tán, TLS ULP
chặn chúng, chèn khung bản ghi, thực hiện mã hóa (trong ZZ0000ZZ
mode) và sau đó đưa danh sách phân tán đã sửa đổi cho lớp TCP. Từ đây
điểm trên ngăn xếp TCP tiến hành như bình thường.

Ở chế độ ZZ0000ZZ, mã hóa không được thực hiện trong TLS ULP.
Thay vì các gói đến trình điều khiển thiết bị, trình điều khiển sẽ đánh dấu các gói
để giảm tải tiền điện tử dựa trên ổ cắm mà gói được gắn vào,
và gửi chúng đến thiết bị để mã hóa và truyền tải.

RX
--

Về phía nhận, nếu thiết bị xử lý việc giải mã và xác thực
thành công, trình điều khiển sẽ thiết lập bit được giải mã trong liên kết
ZZ0000ZZ. Các gói đến ngăn xếp TCP và
đều được xử lý bình thường. ZZ0001ZZ được thông báo khi dữ liệu được xếp hàng vào ổ cắm
và cơ chế ZZ0002ZZ được sử dụng để phân định các bản ghi. Khi đọc
yêu cầu, các bản ghi được lấy từ ổ cắm và chuyển sang quy trình giải mã.
Nếu thiết bị đã giải mã tất cả các phân đoạn của bản ghi thì quá trình giải mã sẽ bị bỏ qua,
nếu không thì đường dẫn phần mềm sẽ xử lý việc giải mã.

.. kernel-figure::  tls-offload-layers.svg
   :alt:	TLS offload layers
   :align:	center
   :figwidth:	28em

   Layers of Kernel TLS stack

Cấu hình thiết bị
====================

Trong quá trình khởi tạo trình điều khiển, thiết bị đặt ZZ0003ZZ và
Tính năng và cài đặt của ZZ0004ZZ
ZZ0000ZZ
con trỏ trong thành viên ZZ0001ZZ của
ZZ0002ZZ.

Khi trạng thái kết nối mật mã TLS được cài đặt trên ổ cắm ZZ0000ZZ
(lưu ý rằng nó được thực hiện hai lần, một lần cho hướng RX và một lần cho hướng TX,
và cả hai hoàn toàn độc lập), kernel sẽ kiểm tra xem phần cơ bản có
thiết bị mạng có khả năng giảm tải và thử giảm tải. Trường hợp giảm tải
không thành công, kết nối được xử lý hoàn toàn bằng phần mềm sử dụng cơ chế tương tự
như thể việc giảm tải chưa bao giờ được thử.

Yêu cầu giảm tải được thực hiện thông qua lệnh gọi lại ZZ0000ZZ của
ZZ0001ZZ:

.. code-block:: c

	int (*tls_dev_add)(struct net_device *netdev, struct sock *sk,
			   enum tls_offload_ctx_dir direction,
			   struct tls_crypto_info *crypto_info,
			   u32 start_offload_tcp_sn);

ZZ0001ZZ cho biết liệu thông tin mật mã có dành cho
các gói được nhận hoặc truyền. Driver sử dụng tham số ZZ0002ZZ
để truy xuất kết nối 5-tuple và họ ổ cắm (IPv4 so với IPv6).
Thông tin mật mã trong ZZ0003ZZ bao gồm khóa, iv, salt
cũng như số thứ tự bản ghi TLS. ZZ0004ZZ chỉ ra
số thứ tự TCP tương ứng với phần đầu của bản ghi với
số thứ tự từ ZZ0005ZZ. Người lái xe có thể thêm trạng thái của nó
ở cuối cấu trúc hạt nhân (xem các thành viên ZZ0000ZZ
trong ZZ0006ZZ) để tránh phân bổ và con trỏ bổ sung
sự hủy bỏ quy định.

TX
--

Sau khi trạng thái TX được cài đặt, ngăn xếp đảm bảo rằng phân đoạn đầu tiên
của luồng sẽ bắt đầu chính xác ở chuỗi ZZ0000ZZ
số, đơn giản hóa việc khớp số thứ tự TCP.

Việc giảm tải TX được khởi tạo hoàn toàn không có nghĩa là tất cả các phân đoạn đi qua
thông qua trình điều khiển và thuộc về ổ cắm đã giảm tải sẽ được thực hiện sau
số thứ tự dự kiến và sẽ có thông tin bản ghi kernel.
Đặc biệt, dữ liệu đã được mã hóa có thể đã được xếp hàng đợi vào ổ cắm
trước khi cài đặt trạng thái kết nối trong kernel.

RX
--

Theo hướng RX, ngăn xếp mạng cục bộ có ít quyền kiểm soát
phân đoạn, do đó số thứ tự TCP của bản ghi ban đầu có thể ở bất kỳ đâu
bên trong phân khúc.

Hoạt động bình thường
=====================

Ở mức tối thiểu, thiết bị duy trì trạng thái sau cho mỗi kết nối, trong
từng hướng:

* bí mật về tiền điện tử (khóa, iv, muối)
 * trạng thái xử lý mật mã (khối một phần, thẻ xác thực một phần, v.v.)
 * ghi lại siêu dữ liệu (số thứ tự, độ lệch xử lý và độ dài)
 * số thứ tự TCP dự kiến

Không có sự đảm bảo nào về độ dài bản ghi hoặc phân đoạn bản ghi. Đặc biệt
các phân đoạn có thể bắt đầu tại bất kỳ điểm nào của bản ghi và chứa bất kỳ số lượng bản ghi nào.
Giả sử các phân đoạn được nhận theo thứ tự, thiết bị sẽ có thể thực hiện
hoạt động và xác thực mật mã bất kể phân đoạn. Vì điều này
để có thể thực hiện được, thiết bị phải giữ một lượng nhỏ dữ liệu phân đoạn
trạng thái. Điều này bao gồm ít nhất:

* tiêu đề một phần (nếu một phân đoạn chỉ mang một phần của tiêu đề TLS)
 * khối dữ liệu một phần
 * thẻ xác thực một phần (tất cả dữ liệu đã được nhìn thấy nhưng một phần của
   thẻ xác thực phải được ghi hoặc đọc từ phân đoạn tiếp theo)

Việc lắp ráp lại bản ghi là không cần thiết để giảm tải TLS. Nếu các gói đến
để thiết bị có thể xử lý chúng một cách riêng biệt và thực hiện
tiến bộ phía trước.

TX
--

Ngăn xếp hạt nhân thực hiện không gian dành riêng cho khung bản ghi để xác thực
gắn thẻ và điền tất cả các trường tiêu đề và đuôi TLS khác.

Cả thiết bị và trình điều khiển đều duy trì số thứ tự TCP dự kiến
do khả năng truyền lại và thiếu phần mềm dự phòng
khi gói tin đến được thiết bị.
Đối với các phân đoạn được truyền theo thứ tự, trình điều khiển đánh dấu các gói bằng
một mã định danh kết nối (lưu ý rằng tra cứu 5 bộ là không đủ để xác định
các gói yêu cầu giảm tải CTNH, xem phần ZZ0000ZZ)
và đưa chúng vào thiết bị. Thiết bị xác định gói theo yêu cầu
TLS xử lý và xác nhận số thứ tự khớp với mong đợi của nó.
Thiết bị thực hiện mã hóa và xác thực dữ liệu hồ sơ.
Nó thay thế thẻ xác thực và tổng kiểm tra TCP bằng các giá trị chính xác.

RX
--

Trước khi gói được DMA đến máy chủ (nhưng sau chuyển mạch nhúng của NIC
và các chức năng chuyển đổi gói), thiết bị sẽ xác nhận Lớp 4
tổng kiểm tra và thực hiện tra cứu 5 bộ dữ liệu để tìm bất kỳ kết nối TLS nào trong gói
có thể thuộc về (về mặt kỹ thuật là 4 bộ
tra cứu là đủ - địa chỉ IP và số cổng TCP, làm giao thức
luôn là TCP). Nếu gói được khớp với một kết nối, thiết bị sẽ xác nhận
nếu số thứ tự TCP là số được mong đợi và tiến hành xử lý TLS
(phân định bản ghi, giải mã, xác thực cho từng bản ghi trong gói).
Thiết bị giữ nguyên khung bản ghi, ngăn xếp sẽ xử lý bản ghi
sự giải mã. Thiết bị cho biết việc xử lý thành công việc giảm tải TLS trong
bối cảnh trên mỗi gói (bộ mô tả) được truyền đến máy chủ.

Khi nhận được gói đã giảm tải TLS, trình điều khiển sẽ thiết lập
dấu ZZ0000ZZ trong ZZ0001ZZ
tương ứng với đoạn đó. Ngăn xếp mạng đảm bảo được giải mã
và các phân đoạn không được giải mã sẽ không được kết hợp lại (ví dụ: bởi GRO hoặc lớp ổ cắm)
và đảm nhiệm việc giải mã một phần.

Xử lý đồng bộ lại
=================

Khi bị rớt gói hoặc sắp xếp lại gói mạng, thiết bị có thể bị mất
đồng bộ hóa với luồng TLS và yêu cầu đồng bộ lại với kernel
Ngăn xếp TCP.

Lưu ý rằng đồng bộ lại chỉ được thử đối với các kết nối đã thành công
được thêm vào bảng thiết bị và ở chế độ TLS_HW. Ví dụ,
nếu bảng đầy khi trạng thái mật mã được cài đặt trong kernel,
kết nối như vậy sẽ không bao giờ bị giảm tải. Vì vậy yêu cầu đồng bộ lại
không mang bất kỳ trạng thái kết nối mật mã nào.

TX
--

Các phân đoạn được truyền từ ổ cắm không tải có thể không đồng bộ
theo những cách tương tự với việc truyền lại bên nhận - giảm cục bộ
là có thể, mặc dù việc sắp xếp lại mạng thì không. Hiện tại có
hai cơ chế để xử lý các phân đoạn không theo thứ tự.

Xây dựng lại trạng thái tiền điện tử
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bất cứ khi nào một phân đoạn không theo thứ tự được truyền đi, trình điều khiển sẽ cung cấp
thiết bị có đủ thông tin để thực hiện các hoạt động mã hóa.
Điều này có nghĩa rất có thể là phần của bản ghi trước bản ghi hiện tại
phân đoạn phải được chuyển đến thiết bị như một phần của bối cảnh gói,
cùng với số thứ tự TCP và số bản ghi TLS của nó. thiết bị
sau đó có thể khởi tạo trạng thái mật mã của nó, xử lý và loại bỏ trạng thái trước đó
data (để có thể chèn thẻ xác thực) và chuyển sang xử lý
gói thực tế.

Ở chế độ này tùy thuộc vào việc triển khai, người lái xe có thể yêu cầu
để tiếp tục với trạng thái mật mã và số thứ tự mới
(phân đoạn dự kiến tiếp theo là phân đoạn sau phân đoạn không đúng thứ tự) hoặc tiếp tục
với trạng thái luồng trước đó - giả sử rằng phân đoạn không đúng thứ tự
chỉ là một sự truyền lại. Cách thứ nhất đơn giản hơn và không cần
phát hiện truyền lại do đó đây là phương pháp được khuyến nghị cho đến khi
lúc đó nó được chứng minh là không hiệu quả.

Đồng bộ hóa bản ghi tiếp theo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bất cứ khi nào phát hiện một phân đoạn không đúng thứ tự, trình điều khiển sẽ yêu cầu
rằng mã dự phòng phần mềm ZZ0000ZZ mã hóa nó. Nếu phân khúc của
số thứ tự thấp hơn mong đợi trình điều khiển giả định truyền lại
và không thay đổi trạng thái thiết bị. Nếu phân đoạn đó ở trong tương lai, nó
có thể ngụ ý sự sụt giảm cục bộ, trình điều khiển sẽ yêu cầu ngăn xếp đồng bộ hóa thiết bị
sang trạng thái bản ghi tiếp theo và quay trở lại phần mềm.

Yêu cầu đồng bộ lại được biểu thị bằng:

.. code-block:: c

  void tls_offload_tx_resync_request(struct sock *sk, u32 got_seq, u32 exp_seq)

Cho đến khi quá trình đồng bộ lại hoàn tất, trình điều khiển sẽ không truy cập được TCP dự kiến của nó
số thứ tự (vì nó sẽ được cập nhật từ một ngữ cảnh khác).
Nên sử dụng trình trợ giúp sau để kiểm tra xem quá trình đồng bộ lại đã hoàn tất chưa:

.. code-block:: c

  bool tls_offload_tx_resync_pending(struct sock *sk)

Lần tới ZZ0000ZZ đẩy một bản ghi, trước tiên nó sẽ gửi số thứ tự TCP của nó
và số bản ghi TLS cho người lái xe. Stack cũng sẽ đảm bảo rằng
bản ghi mới sẽ bắt đầu trên một ranh giới phân đoạn (giống như khi
kết nối ban đầu được thêm vào).

RX
--

Một lượng nhỏ sự kiện sắp xếp lại RX có thể không yêu cầu đồng bộ lại hoàn toàn.
Đặc biệt máy không bị mất đồng bộ
khi ranh giới bản ghi có thể được phục hồi:

.. kernel-figure::  tls-offload-reorder-good.svg
   :alt:	reorder of non-header segment
   :align:	center

   Reorder of non-header segment

Các phân đoạn màu xanh lá cây được giải mã thành công, các phân đoạn màu xanh lam được chuyển qua
khi nhận được trên dây, sọc đỏ đánh dấu sự bắt đầu của kỷ lục mới.

Trong trường hợp trên, phân đoạn 1 đã được nhận và giải mã thành công.
Phân khúc 2 đã bị loại bỏ nên phân khúc 3 không còn hoạt động. Thiết bị biết
bản ghi tiếp theo bắt đầu bên trong 3, dựa trên độ dài bản ghi trong phân đoạn 1.
Phân đoạn 3 được bỏ qua nguyên do thiếu dữ liệu từ phân đoạn 2
phần còn lại của bản ghi trước đó trong phân đoạn 3 không thể được xử lý.
Tuy nhiên, thiết bị có thể thu thập trạng thái của thuật toán xác thực
và chặn một phần bản ghi mới ở phân đoạn 3 và khi 4 và 5
đến tiếp tục giải mã. Cuối cùng khi 2 đến thì nó hoàn toàn ở bên ngoài
cửa sổ dự kiến của thiết bị để nó được thông qua mà không cần đặc biệt
xử lý. Dự phòng phần mềm ZZ0000ZZ xử lý việc giải mã bản ghi
trải rộng trên các phân đoạn 1, 2 và 3. Thiết bị không bị mất đồng bộ,
mặc dù hai phân đoạn không được giải mã.

Đồng bộ hóa hạt nhân có thể cần thiết nếu phân đoạn bị mất chứa
tiêu đề bản ghi và đến sau khi tiêu đề bản ghi tiếp theo đã trôi qua:

.. kernel-figure::  tls-offload-reorder-bad.svg
   :alt:	reorder of header segment
   :align:	center

   Reorder of segment with a TLS header

Trong ví dụ này, phân đoạn 2 bị loại bỏ và chứa tiêu đề bản ghi.
Thiết bị chỉ có thể phát hiện phân đoạn 4 đó cũng chứa tiêu đề TLS
nếu nó biết độ dài của bản ghi trước đó từ phân đoạn 2. Trong trường hợp này
thiết bị sẽ mất đồng bộ hóa với luồng.

Đồng bộ hóa lại quét luồng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi thiết bị không đồng bộ và luồng đạt đến chuỗi TCP
nhiều hơn bản ghi kích thước tối đa vượt quá số thứ tự TCP dự kiến,
thiết bị bắt đầu quét mẫu tiêu đề đã biết. Ví dụ
đối với TLS 1.2 và TLS 1.3, các byte giá trị tiếp theo ZZ0000ZZ xảy ra
trong trường phiên bản SSL/TLS của tiêu đề. Sau khi mẫu được khớp
thiết bị tiếp tục thử phân tích tiêu đề tại các vị trí dự kiến
(dựa trên các trường độ dài tại các vị trí được đoán).
Bất cứ khi nào vị trí dự kiến không chứa tiêu đề hợp lệ, quá trình quét sẽ
được khởi động lại.

Khi tiêu đề khớp, thiết bị sẽ gửi yêu cầu xác nhận
vào kernel, hỏi xem vị trí đoán có đúng không (nếu bản ghi TLS
thực sự bắt đầu từ đó) và số thứ tự bản ghi mà tiêu đề đã cho có.

Quá trình đồng bộ lại không đồng bộ được phối hợp ở phía kernel bằng cách sử dụng
struct tls_offload_resync_async, theo dõi và quản lý yêu cầu đồng bộ lại.

Các hàm trợ giúp để quản lý struct tls_offload_resync_async:

ZZ0000ZZ
Khởi tạo nỗ lực đồng bộ lại không đồng bộ bằng cách chỉ định phạm vi chuỗi thành
giám sát và đặt lại trạng thái bên trong trong cấu trúc.

ZZ0000ZZ
Giữ lại số thứ tự TCP được đoán của thiết bị để so sánh với hiện tại hoặc
những cái được ghi lại trong tương lai. Nó cũng xóa cờ RESYNC_REQ_ASYNC khỏi quá trình đồng bộ lại
yêu cầu, chỉ ra rằng thiết bị đã gửi số thứ tự dự đoán của nó.

ZZ0000ZZ
Hủy mọi nỗ lực đồng bộ hóa lại đang diễn ra, xóa trạng thái yêu cầu.

Khi kernel xử lý phân đoạn RX bắt đầu bản ghi TLS mới, nó
kiểm tra trạng thái hiện tại của yêu cầu đồng bộ lại không đồng bộ.

Nếu thiết bị vẫn đang chờ cung cấp số thứ tự TCP được đoán của nó
(trạng thái không đồng bộ), kernel ghi lại số thứ tự của phân đoạn này để
rằng sau này nó có thể được so sánh khi dự đoán của thiết bị có sẵn.

Nếu thiết bị đã gửi số thứ tự được đoán (không đồng bộ
trạng thái), hạt nhân bây giờ cố gắng khớp dự đoán đó với số thứ tự của
tất cả các tiêu đề bản ghi TLS đã được ghi lại kể từ yêu cầu đồng bộ lại
bắt đầu.

Hạt nhân xác nhận vị trí đoán là chính xác và thông báo cho thiết bị
số thứ tự bản ghi. Trong khi đó, thiết bị đã phân tích cú pháp
và đếm tất cả các bản ghi kể từ bản ghi vừa được xác nhận, nó sẽ cộng số
của các bản ghi nó đã thấy so với con số kỷ lục do kernel cung cấp.
Tại thời điểm này, thiết bị đã đồng bộ hóa và có thể tiếp tục giải mã ở lần tiếp theo.
ranh giới phân khúc.

Trong trường hợp bệnh lý, thiết bị có thể bám vào một chuỗi khớp
tiêu đề và không bao giờ nhận được phản hồi từ kernel (không có tiêu cực
xác nhận từ kernel). Việc thực hiện có thể chọn định kỳ
khởi động lại quá trình quét. Tuy nhiên, do luồng kết hợp sai khó có thể xảy ra,
khởi động lại định kỳ là không cần thiết.

Phải đặc biệt cẩn thận nếu yêu cầu xác nhận được thông qua
không đồng bộ với luồng gói và bản ghi có thể được xử lý
bởi kernel trước yêu cầu xác nhận.

Đồng bộ hóa lại theo hướng ngăn xếp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trình điều khiển cũng có thể yêu cầu ngăn xếp thực hiện đồng bộ lại
bất cứ khi nào nó thấy các bản ghi không còn được giải mã nữa.
Nếu kết nối được cấu hình ở chế độ này, ngăn xếp sẽ tự động
lên lịch đồng bộ lại sau khi nhận được hai mã hóa hoàn toàn
hồ sơ.

Ngăn xếp chờ ổ cắm thoát nước và thông báo cho thiết bị về
số bản ghi dự kiến tiếp theo và số thứ tự TCP của nó. Nếu
các bản ghi tiếp tục được nhận, ngăn xếp được mã hóa hoàn toàn, thử lại
đồng bộ hóa với mức lùi theo cấp số nhân (lần đầu tiên sau 2 lần mã hóa
bản ghi, rồi sau 4 bản ghi, sau 8 bản ghi, sau 16 bản ghi... cho đến mỗi bản ghi
128 hồ sơ).

Xử lý lỗi
==============

TX
--

Các gói có thể được chuyển hướng hoặc định tuyến lại bởi ngăn xếp tới một địa chỉ khác
thiết bị hơn thiết bị giảm tải TLS đã chọn. Ngăn xếp sẽ xử lý
điều kiện như vậy bằng cách sử dụng trình trợ giúp ZZ0000ZZ
(Mã giảm tải TLS cài đặt ZZ0001ZZ tại hook này).
Offload duy trì thông tin về tất cả các bản ghi cho đến khi dữ liệu được
được thừa nhận đầy đủ, vì vậy nếu skbs tiếp cận sai thiết bị, chúng có thể được xử lý
bằng dự phòng phần mềm.

Bất kỳ lỗi xử lý giảm tải TLS nào của thiết bị ở phía truyền đều phải xảy ra
trong gói tin bị loại bỏ. Ví dụ: nếu một gói bị lỗi
do lỗi trong ngăn xếp hoặc thiết bị, đã truy cập vào thiết bị và không thể
được mã hóa thì gói tin đó phải bị loại bỏ.

RX
--

Nếu thiết bị gặp bất kỳ sự cố nào với việc giảm tải TLS khi nhận
bên cạnh đó nó sẽ chuyển gói đến ngăn xếp mạng của máy chủ như trước đây
nhận được trên dây.

Ví dụ: lỗi xác thực đối với bất kỳ bản ghi nào trong phân đoạn sẽ
dẫn đến việc chuyển gói chưa sửa đổi sang dự phòng phần mềm. Điều này có nghĩa
các gói không nên được sửa đổi "tại chỗ". Tách các phân đoạn để xử lý một phần
giải mã không được khuyến khích. Nói cách khác hoặc tất cả các bản ghi trong gói
đã được xử lý thành công và được xác thực hoặc gói phải được chuyển
vào ngăn xếp của máy chủ như trên đường truyền (khôi phục gói gốc trong
trình điều khiển nếu thiết bị cung cấp lỗi chính xác là đủ).

Ngăn xếp mạng Linux không cung cấp cách báo cáo trên mỗi gói
lỗi giải mã và xác thực, các gói có lỗi đơn giản là không
có bộ nhãn hiệu ZZ0000ZZ.

Một gói cũng không được xử lý bởi bộ giảm tải TLS nếu nó chứa
tổng kiểm tra không chính xác.

Số liệu hiệu suất
===================

Giảm tải TLS có thể được đặc trưng bởi các số liệu cơ bản sau:

* số lượng kết nối tối đa
 * tỷ lệ cài đặt kết nối
 * độ trễ cài đặt kết nối
 * tổng hiệu suất mật mã

Lưu ý rằng mỗi kết nối TCP yêu cầu phiên TLS theo cả hai hướng,
hiệu suất có thể được báo cáo xử lý từng hướng riêng biệt.

Số lượng kết nối tối đa
-----------------------

Số lượng kết nối mà thiết bị có thể hỗ trợ có thể được hiển thị thông qua
ZZ0000ZZ API.

Tổng hiệu suất mật mã
-------------------------------

Hiệu suất giảm tải có thể phụ thuộc vào phân đoạn và kích thước bản ghi.

Hệ thống con mật mã của thiết bị không được bị quá tải
tác động hiệu suất đáng kể trên các luồng không giảm tải.

Thống kê
==========

Phải báo cáo bộ thống kê tối thiểu liên quan đến TLS sau đây
bởi người lái xe:

* ZZ0000ZZ - số gói RX được giải mã thành công
   là một phần của luồng TLS.
 * ZZ0001ZZ - số byte tải trọng TLS trong gói RX
   đã được giải mã thành công.
 * ZZ0002ZZ - số bối cảnh giảm tải TLS RX HW được thêm vào thiết bị cho
   giải mã.
 * ZZ0003ZZ - số bối cảnh giảm tải TLS RX HW đã bị xóa khỏi thiết bị
   (kết nối đã kết thúc).
 * ZZ0004ZZ - số lượng gói TLS đã nhận được đồng bộ lại
    yêu cầu.
 * ZZ0005ZZ - số lần yêu cầu đồng bộ lại không đồng bộ TLS
    đã được bắt đầu.
 * ZZ0006ZZ - số lần yêu cầu đồng bộ lại không đồng bộ TLS
    đã kết thúc đúng cách bằng việc cung cấp tcp-seq được theo dõi CTNH.
 * ZZ0007ZZ - số lần yêu cầu đồng bộ lại không đồng bộ TLS
    thủ tục đã được bắt đầu nhưng không kết thúc đúng cách.
 * ZZ0008ZZ - số lần cuộc gọi phản hồi đồng bộ lại TLS tới
    người lái xe đã được xử lý thành công.
 * ZZ0009ZZ - số lần cuộc gọi phản hồi đồng bộ lại TLS tới
    trình điều khiển đã bị chấm dứt không thành công.
 * ZZ0010ZZ - số gói RX là một phần của luồng TLS
   nhưng không được giải mã do lỗi không mong muốn trong máy trạng thái.
 * ZZ0011ZZ - số lượng gói TX được truyền tới thiết bị
   để mã hóa tải trọng TLS của họ.
 * ZZ0012ZZ - số byte tải trọng TLS trong gói TX
   được chuyển đến thiết bị để mã hóa.
 * ZZ0013ZZ - số bối cảnh giảm tải TLS TX HW được thêm vào thiết bị cho
   mã hóa.
 * ZZ0014ZZ - số lượng gói TX là một phần của luồng TLS
   nhưng đã không đến theo thứ tự dự kiến.
 * ZZ0015ZZ - số lượng gói TX là một phần của
   một luồng TLS và không theo thứ tự, nhưng đã bỏ qua quy trình giảm tải CTNH
   và đi đến luồng truyền thông thường vì chúng được truyền lại
   bắt tay kết nối.
 * ZZ0016ZZ - số lượng gói TX là một phần của
   luồng TLS bị rớt do chúng không theo thứ tự và được liên kết
   bản ghi không thể được tìm thấy.
 * ZZ0017ZZ - số gói TX là một phần của TLS
   luồng bị hủy vì chúng chứa cả dữ liệu đã được mã hóa bởi
   phần mềm và dữ liệu yêu cầu giảm tải mật mã phần cứng.

Các trường hợp góc đáng chú ý, các trường hợp ngoại lệ và yêu cầu bổ sung
=========================================================================

.. _5tuple_problems:

Giới hạn khớp 5 bộ
----------------------------

Thiết bị chỉ có thể nhận dạng các gói đã nhận dựa trên 5 bộ dữ liệu
của ổ cắm. Việc triển khai ZZ0000ZZ hiện tại sẽ không giảm tải ổ cắm
được định tuyến thông qua các giao diện phần mềm như giao diện được sử dụng cho đường hầm
hoặc mạng ảo. Tuy nhiên, nhiều chuyển đổi gói được thực hiện
bởi ngăn xếp mạng (đáng chú ý nhất là bất kỳ logic BPF nào) không yêu cầu
bất kỳ thiết bị phần mềm trung gian nào, do đó việc so khớp 5 bộ dữ liệu có thể
liên tục bỏ lỡ ở cấp độ thiết bị. Trong những trường hợp như vậy thiết bị
vẫn có thể thực hiện giảm tải TX (mã hóa) và nên
dự phòng hoàn toàn sang giải mã phần mềm (RX).

Không theo thứ tự
-----------------

Việc giới thiệu quá trình xử lý bổ sung trong NIC sẽ không khiến các gói bị
được truyền hoặc nhận không theo thứ tự, ví dụ như các gói ACK thuần túy
không nên được sắp xếp lại đối với các phân đoạn dữ liệu.

Sắp xếp lại lần nhập
--------------------

Một thiết bị được phép thực hiện sắp xếp lại gói liên tục
Các phân đoạn TCP (tức là đặt các gói theo đúng thứ tự) nhưng bất kỳ dạng nào
việc đệm bổ sung không được phép.

Cùng tồn tại với các tính năng giảm tải mạng tiêu chuẩn
-------------------------------------------------------

Ổ cắm ZZ0000ZZ được giảm tải sẽ hỗ trợ các tính năng ngăn xếp TCP tiêu chuẩn
một cách minh bạch. Việc kích hoạt giảm tải thiết bị TLS sẽ không gây ra bất kỳ sự khác biệt nào
trong các gói như được thấy trên dây.

Độ trong suốt của lớp vận chuyển
--------------------------------

Với mục đích đơn giản hóa việc giảm tải TLS, thiết bị không được sửa đổi bất kỳ
tiêu đề gói.

Thiết bị không nên phụ thuộc vào bất kỳ tiêu đề gói nào ngoài những gì được quy định nghiêm ngặt.
cần thiết cho việc giảm tải TLS.

Phân khúc giảm
--------------

Việc bỏ gói chỉ được chấp nhận trong trường hợp có thảm họa
lỗi hệ thống và không bao giờ được sử dụng làm cơ chế xử lý lỗi
trong các trường hợp phát sinh từ hoạt động bình thường. Nói cách khác, sự phụ thuộc
trên TCP, việc truyền lại để xử lý các trường hợp góc là không được chấp nhận.

Tính năng của thiết bị TLS
--------------------------

Trình điều khiển nên bỏ qua những thay đổi đối với cờ tính năng của thiết bị TLS.
Các cờ này sẽ được xử lý tương ứng bằng mã ZZ0000ZZ cốt lõi.
Cờ tính năng của thiết bị TLS chỉ kiểm soát việc thêm kết nối TLS mới
giảm tải, các kết nối cũ sẽ vẫn hoạt động sau khi cờ được xóa.

Không thể tải mã hóa TLS xuống các thiết bị mà không tính toán tổng kiểm tra
giảm tải. Do đó, cờ tính năng của thiết bị TLS TX yêu cầu thiết lập giảm tải csum TX.
Vô hiệu hóa cái sau có nghĩa là xóa cái trước. Vô hiệu hóa giảm tải tổng kiểm tra TX
không ảnh hưởng đến các kết nối cũ và trình điều khiển phải đảm bảo tổng kiểm tra
tính toán không phá vỡ đối với họ.
Tương tự, việc giải mã TLS được giảm tải cho thiết bị ngụ ý thực hiện RXCSUM. Nếu người dùng
không muốn bật tính năng giảm tải csum RX, tính năng thiết bị TLS RX bị tắt
cũng vậy.