.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/soundwire/bra.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Truy cập đăng ký hàng loạt (BRA)
================================

Công ước
-----------

Các từ viết hoa được sử dụng trong tài liệu này là có chủ ý và đề cập đến
các khái niệm về đặc tả SoundWire 1.x.

Giới thiệu
------------

Đặc tả SoundWire 1.x cung cấp cơ chế tăng tốc
truyền lệnh/điều khiển bằng cách lấy lại các phần của âm thanh
băng thông. Giao thức Truy cập Đăng ký Hàng loạt (BRA) là một tiêu chuẩn
giải pháp dựa trên định nghĩa Vận chuyển tải trọng số lượng lớn (BPT).

Kênh điều khiển thông thường sử dụng Cột 0 và chỉ có thể gửi/truy xuất
một byte trên mỗi khung với các lệnh ghi/đọc. Với tần số 48kHz điển hình
tốc độ khung hình, chỉ có thể truyền 48kB/s.

Khả năng Truy cập Đăng ký Hàng loạt tùy chọn có thể truyền tới 12
Mbits/s và giảm thời gian truyền đi vài bậc độ lớn, nhưng
có nhiều hạn chế về thiết kế:

(1) Mỗi khung chỉ có thể hỗ trợ truyền đọc hoặc ghi, với
      Chi phí 10 byte cho mỗi khung hình (phản hồi đầu trang và chân trang).

(2) Việc đọc/ghi SHALL là từ/đến các địa chỉ thanh ghi liền kề
      trong cùng một khung. Một không gian thanh ghi bị phân mảnh làm giảm
      hiệu quả của giao thức bằng cách yêu cầu chuyển BRA nhiều lần
      được sắp xếp ở các khung khác nhau.

(3) Thiết bị ngoại vi được nhắm mục tiêu SHALL hỗ trợ Dữ liệu tùy chọn
      Cổng 0 và tương tự như vậy, Trình quản lý SHALL hiển thị các Cổng giống như âm thanh
      để chèn các gói BRA vào tải trọng âm thanh bằng cách sử dụng các khái niệm về
      Khoảng thời gian mẫu, HSTART, HSTOP, v.v.

(4) Hiệu quả vận chuyển BRA phụ thuộc vào khả năng sẵn có
      băng thông. Nếu không có quá trình truyền âm thanh nào đang diễn ra, toàn bộ
      khung trừ Cột 0 có thể được lấy lại cho BRA. Hình dạng khung
      cũng ảnh hưởng đến hiệu quả: vì Cột0 không thể được sử dụng cho
      BTP/BRA, khung phải dựa vào số lượng lớn cột và
      giảm thiểu số lượng hàng. Đồng hồ xe buýt phải cao như
      có thể.

(5) Số bit được truyền trên mỗi khung SHALL là bội số của
      8 bit. Các bit đệm SHALL được chèn vào cuối nếu cần thiết
      của dữ liệu.

(6) Lệnh đọc/ghi thông thường có thể được thực hiện song song với
      Chuyển BRA. Điều này thuận tiện để ví dụ: xử lý các cảnh báo, jack
      phát hiện hoặc thay đổi âm lượng trong quá trình tải xuống chương trình cơ sở, nhưng
      truy cập vào cùng một địa chỉ với hai giao thức độc lập phải
      tránh để tránh hành vi không xác định.

(7) Một số triển khai có thể không có khả năng xử lý
      băng thông của giao thức BRA, ví dụ: trong trường hợp I2C chậm
      xe buýt phía sau IP SoundWire. Trong trường hợp này, việc chuyển tiền có thể
      cần phải được đặt cách nhau theo thời gian hoặc được kiểm soát dòng chảy.

(8) Mỗi gói BRA SHALL được đánh dấu là 'Hoạt động' khi dữ liệu hợp lệ được
      được truyền đi. Điều này cho phép phần mềm phân bổ BRA
      truyền phát nhưng không truyền/loại bỏ dữ liệu trong khi xử lý
      kết quả hoặc chuẩn bị lô dữ liệu tiếp theo hoặc cho phép
      thiết bị ngoại vi để xử lý việc chuyển giao trước đó. Ngoài ra BRA
      chuyển giao có thể được bắt đầu sớm mà không cần dữ liệu sẵn sàng.

(9) Có thể truyền tối đa 470 byte trên mỗi khung.

(10) Địa chỉ được biểu diễn bằng 32 bit và không dựa vào
       các thanh ghi phân trang được sử dụng cho lệnh/điều khiển thông thường
       giao thức ở Cột 0.


Kiểm tra lỗi
--------------

Tải xuống chương trình cơ sở là một trong những cách sử dụng chính của Quyền truy cập đăng ký hàng loạt
giao thức. Để đảm bảo tính toàn vẹn của dữ liệu nhị phân không bị xâm phạm bởi
lỗi truyền hoặc lập trình, mỗi gói BRA cung cấp:

(1) CRC trên tiêu đề 7 byte. CRC này giúp thiết bị ngoại vi
      kiểm tra xem nó có được đánh địa chỉ hay không và đặt địa chỉ bắt đầu và số lượng
      byte. Thiết bị ngoại vi cung cấp phản hồi ở Byte 7.

(2) CRC trên khối dữ liệu (không bao gồm tiêu đề). CRC này là
      được truyền dưới dạng byte cuối cùng trong gói, trước byte
      phản hồi chân trang.

Phản hồi tiêu đề có thể là một trong:
  (a) ACK
  (b) Nak
  (c) Chưa sẵn sàng

Phản hồi ở chân trang có thể là một trong:
  (1) ACK
  (2) Nak (lỗi CRC)
  (3) Tốt (hoàn thành thao tác)
  (4) Xấu (thao tác thất bại)

Khung mẫu
-------------

Ví dụ dưới đây không mở rộng quy mô và đưa ra các giả định đơn giản hóa
cho rõ ràng. Không cần phải có các đoạn khác nhau trong gói BRA
để bắt đầu trên Hàng SoundWire mới và quy mô dữ liệu có thể thay đổi.

      ::

+---+----------------------------------------------------------+
	+ ZZ0000ZZ
	+ ZZ0001ZZ
	+ ZZ0002ZZ
	+ +----------------------------------------------------------+
	+ C ZZ0003ZZ
	+ Ô +---------------------------------------------+
	+ M ZZ0004ZZ
	+ M +---------------------------------------------+
	+ ZZ0005ZZ
	+ N ZZ0006ZZ
	+ D ZZ0007ZZ
	+ ZZ0008ZZ
	+ ZZ0009ZZ
	+ ZZ0010ZZ
	+ +----------------------------------------------------------+
	+ ZZ0011ZZ
	+ +----------------------------------------------------------+
	+ ZZ0012ZZ
	+---+----------------------------------------------------------+


Giả sử khung sử dụng N cột, cấu hình hiển thị ở trên có thể
được lập trình bằng cách thiết lập các thanh ghi DP0 như:

- HSTART = 1
    - HSTOP = N - 1
    - Khoảng thời gian lấy mẫu = N
    - Độ dài từ = N - 1

Giải quyết các hạn chế
-----------------------

Số thiết bị được chỉ định trong Tiêu đề tuân theo SoundWire
cho phép các định nghĩa, địa chỉ quảng bá và địa chỉ nhóm. Hiện tại
việc triển khai Linux chỉ cho phép chuyển một BPT sang một
một thiết bị tại một thời điểm. Điều này có thể được xem xét lại sau này vì
tối ưu hóa để gửi cùng một chương trình cơ sở tới nhiều thiết bị, nhưng
điều này sẽ chỉ có lợi cho các giải pháp liên kết đơn.

Trong trường hợp có nhiều thiết bị ngoại vi được gắn vào các thiết bị khác nhau
Người quản lý, việc phát sóng và đánh địa chỉ nhóm không được hỗ trợ bởi
Thông số kỹ thuật SoundWire Mỗi thiết bị phải được xử lý bằng BRA riêng biệt
các luồng, có thể song song - các liên kết thực sự độc lập.

Các tính năng không được hỗ trợ
--------------------

Đặc tả Truy cập Đăng ký Hàng loạt cung cấp một số
các khả năng không được hỗ trợ trong các triển khai đã biết, chẳng hạn như:

(1) Quá trình truyền được thực hiện bởi Thiết bị ngoại vi. Bộ khởi tạo BRA là
      luôn là Thiết bị quản lý.

(2) Khả năng điều khiển luồng và truyền lại dựa trên
      Phản hồi tiêu đề 'Chưa sẵn sàng' yêu cầu thêm bộ đệm trong
      IP SoundWire và không được triển khai.

Xử lý hai chiều
-----------------------

Giao thức BRA có thể xử lý việc ghi cũng như đọc và trong mỗi
gói phản hồi đầu trang và chân trang được cung cấp bởi Thiết bị ngoại vi
Thiết bị mục tiêu. Trên thiết bị ngoại vi, giao thức BRA được xử lý
bởi một cổng dữ liệu DP0 duy nhất và ở mức độ thấp, quyền sở hữu xe buýt có thể
sẽ thay đổi đối với phản hồi đầu trang/chân trang cũng như dữ liệu được truyền
trong một lần đọc.

Về phía máy chủ, hầu hết các hoạt động triển khai đều dựa trên khái niệm giống Cổng,
với hai FIFO tiêu thụ/tạo ra truyền dữ liệu song song
(Máy chủ->Ngoại vi và Ngoại vi->Máy chủ). Lượng dữ liệu
do các FIFO này tiêu thụ/sản xuất không có tính đối xứng, do đó
phần cứng thường chèn các điểm đánh dấu để giúp phần mềm và phần cứng
diễn giải dữ liệu thô

Mỗi gói thường sẽ có:

(1) chỉ báo 'Bắt ​​đầu gói'.

(2) chỉ báo 'Kết thúc gói'.

(3) mã định danh gói để tương quan với dữ liệu được yêu cầu và
      được truyền đi và trạng thái lỗi của từng khung

Việc triển khai phần cứng có thể kiểm tra lỗi ở cấp khung và
thử lại việc chuyển tiền trong trường hợp có lỗi. Tuy nhiên, đối với việc điều khiển luồng
trường hợp này, điều này đòi hỏi phải có thêm bộ đệm và trí thông minh trong
phần cứng. Bộ phận hỗ trợ Linux giả định rằng toàn bộ quá trình chuyển giao được thực hiện
bị hủy nếu phát hiện một lỗi ở một trong các phản hồi.

Yêu cầu trừu tượng
~~~~~~~~~~~~~~~~~~~~

Không có đăng ký tiêu chuẩn hoặc thực hiện bắt buộc tại
Cấp người quản lý, do đó, chi tiết BPT/BRA cấp thấp phải được ẩn trong
Mã dành riêng cho người quản lý. Ví dụ: định dạng IP Cadence ở trên không
được các trình điều khiển codec biết đến.

Tương tự như vậy, trình điều khiển codec không cần phải biết kích thước khung hình. các
việc tính toán CRC và xử lý các phản hồi được xử lý trong các trình trợ giúp và
Mã dành riêng cho người quản lý.

Trình điều khiển BRA của máy chủ cũng có thể có những hạn chế đối với các trang được phân bổ cho
DMA hoặc các giao thức truyền thông Host-DSP khác. Trình điều khiển mã hóa
không nên biết về bất kỳ hạn chế nào trong số này, vì nó có thể
được sử dụng lại kết hợp với các triển khai khác nhau của IP Người quản lý.

Đồng thời giữa BRA và đọc/ghi thông thường
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

API 'nread/nwrite' hiện tại đã dựa trên khái niệm bắt đầu
địa chỉ và số byte, do đó có thể mở rộng địa chỉ này
API kèm theo 'gợi ý' yêu cầu sử dụng BPT/BRA.

Tuy nhiên, quá trình chuyển BRA có thể khá dài và việc sử dụng một lần
mutex để đọc/ghi thông thường và BRA là công cụ dừng hiển thị. Độc lập
hoạt động điều khiển/lệnh và chuyển BRA là cơ bản
yêu cầu, ví dụ: để thay đổi mức âm lượng với sơ đồ quy trình hiện có
giao diện trong khi tải firmware. Tuy nhiên, việc tích hợp phải
đảm bảo rằng không có quyền truy cập đồng thời vào cùng một địa chỉ với
giao thức lệnh/điều khiển và giao thức BRA.

Ngoài ra, mã cứng cấu trúc 'sdw_msg' hỗ trợ cho 16-bit
địa chỉ và thanh ghi phân trang không liên quan đến BPT/BRA
hỗ trợ dựa trên địa chỉ 32-bit gốc. Một API riêng biệt với
'sdw_bpt_msg' có ý nghĩa hơn.

Một chiến lược khả thi để tăng tốc tất cả các tác vụ khởi tạo là
bắt đầu chuyển BRA để tải xuống chương trình cơ sở, sau đó xử lý tất cả các vấn đề
đọc/ghi "thông thường" song song với kênh lệnh và cuối cùng
để chờ quá trình chuyển BRA hoàn tất. Điều này sẽ cho phép một
mức độ chồng chéo thay vì giải pháp tuần tự thuần túy. Như vậy,
BRA API phải hỗ trợ truyền không đồng bộ và có thời gian chờ riêng
chức năng.


Giao diện ngoại vi/bus
------------------------

Giao diện bus cho BPT/BRA được tạo thành từ hai chức năng:

- sdw_bpt_send_async(bpt_message)

Hàm này gửi dữ liệu bằng Trình quản lý
      các khả năng do triển khai xác định (thường là DMA hoặc IPC
      giao thức).

Xếp hàng hiện không được hỗ trợ, người gọi
      cần chờ hoàn thành việc chuyển giao được yêu cầu.

- sdw_bpt_wait()

Chức năng này chờ toàn bộ tin nhắn được cung cấp bởi
      trình điều khiển codec ở giai đoạn 'send_async'. Trạng thái trung gian cho
      các phần nhỏ hơn sẽ không được cung cấp lại cho trình điều khiển codec,
      chỉ có một mã trả lại sẽ được cung cấp.

Sử dụng bản đồ Regmap
~~~~~~~~~~

Trình điều khiển codec hiện tại dựa vào regmap để tải chương trình cơ sở về
Thiết bị ngoại vi. regmap hiển thị giao diện không đồng bộ tương tự như
gửi/chờ API được đề xuất ở trên, vì vậy ở mức độ cao có vẻ như
tự nhiên để kết hợp BRA và regmap. Lớp regmap có thể kiểm tra xem BRA có
có sẵn hay không và sử dụng kênh lệnh đọc-ghi thông thường trong
trường hợp sau.

Việc tích hợp regmap sẽ được xử lý ở bước thứ hai.

Mô hình luồng BRA
----------------

Để truyền âm thanh thông thường, trình điều khiển máy sẽ hiển thị dailink
kết nối CPU DAI(s) và Codec DAI(s).

Model này không cần hỗ trợ BRA:

(1) SoundWire DAI chủ yếu là các trình bao bọc cho Dữ liệu SoundWire
       Các cổng, có thể có một số chuyển đổi tương tự hoặc âm thanh
       các khả năng được chốt phía sau Cổng dữ liệu. Trong bối cảnh của
       BRA, DP0 là đích đến. Các thanh ghi DP0 là tiêu chuẩn và
       có thể được lập trình một cách mù quáng mà không biết Ngoại vi là gì
       được kết nối với mỗi liên kết. Ngoài ra, nếu có nhiều
       Các thiết bị ngoại vi trên một liên kết và một số trong số chúng không hỗ trợ DP0,
       ghi lệnh vào chương trình thanh ghi DP0 sẽ tạo ra vô hại
       Các phản hồi COMMAND_IGNORED sẽ được nối dây OR với
       phản hồi từ Thiết bị ngoại vi hỗ trợ DP0. Nói cách khác,
       việc lập trình DP0 có thể được thực hiện bằng các lệnh phát sóng và
       thông tin trên thiết bị Target chỉ có thể được thêm vào trong
       Tiêu đề BRA.

(2) Ở cấp độ CPU, khái niệm DAI không hữu ích cho BRA; cái
       Trình điều khiển máy sẽ không tạo dailink dựa trên DP0. các
       khái niệm duy nhất cần thiết là khái niệm về cổng.

(3) Khái niệm luồng dựa trên tập hợp master_rt và Slave_rt
       các khái niệm. Tất cả các thực thể này đại diện cho các cổng chứ không phải DAI.

(4) Với giả định rằng một luồng BRA duy nhất được sử dụng cho mỗi liên kết,
       luồng đó có thể kết nối các cổng chính cũng như tất cả các thiết bị ngoại vi
       Cổng DP0.

(5) Việc chuyển BRA chỉ có ý nghĩa trong bối cảnh một
       Trình quản lý/Liên kết, do đó việc xử lý luồng BRA không phụ thuộc vào
       khái niệm tổng hợp đa liên kết được cho phép bởi các liên kết DAI thông thường.

Hỗ trợ âm thanh DMA
-----------------

Một số DMA, chẳng hạn như HDaudio, yêu cầu phải có trường định dạng âm thanh.
thiết lập. Định dạng này lần lượt được sử dụng để xác định các cụm có thể chấp nhận được. BPT/BRA
hỗ trợ không hoàn toàn tương thích với các định nghĩa này ở chỗ
format and bandwidth may vary between read and write commands.

Ngoài ra, trên nền tảng Intel HDaudio Intel, DMA cần phải được
được lập trình với định dạng PCM phù hợp với băng thông của BPT/BRA
chuyển nhượng. Định dạng này dựa trên các mẫu 32-bit 192kHz và số lượng
của các kênh khác nhau để điều chỉnh băng thông. Khái niệm kênh là
hoàn toàn không có ý nghĩa vì dữ liệu không phải là âm thanh thông thường
PCM. Lập trình các kênh như vậy giúp dự trữ đủ băng thông và điều chỉnh
Kích thước FIFO để tránh xrun.

Yêu cầu liên kết hiện không được thực thi ở cấp độ cốt lõi
nhưng ở cấp độ nền tảng, ví dụ: đối với Intel, kích thước dữ liệu phải là
bằng hoặc lớn hơn 16 byte.
