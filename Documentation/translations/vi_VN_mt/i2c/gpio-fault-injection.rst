.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/gpio-fault-injection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Lỗi tiêm Linux I2C
===========================

Trình điều khiển chính bus I2C dựa trên GPIO có thể được cấu hình để cung cấp lỗi
khả năng tiêm. Sau đó nó được kết nối với một bus I2C khác
được điều khiển bởi trình điều khiển chính xe buýt I2C đang được thử nghiệm. Lỗi GPIO
trình điều khiển tiêm có thể tạo các trạng thái đặc biệt trên xe buýt mà xe buýt I2C khác
tài xế chính nên xử lý một cách duyên dáng.

Khi tùy chọn Kconfig I2C_GPIO_FAULT_INJECTOR được bật, sẽ có một
Thư mục con 'i2c-fault-injector' trong hệ thống tập tin Kernel debugfs, thường là
được gắn tại /sys/kernel/debug. Sẽ có một thư mục con riêng cho mỗi GPIO
điều khiển xe buýt I2C. Mỗi thư mục con sẽ chứa các file gây ra lỗi
tiêm. Bây giờ chúng sẽ được mô tả cùng với các trường hợp sử dụng dự định của chúng.

Trạng thái dây
===========

"scl"
-----

Bằng cách đọc tệp này, bạn sẽ có được trạng thái hiện tại của SCL. Bằng cách viết, bạn có thể
thay đổi trạng thái của nó để buộc nó ở mức thấp hoặc thả nó ra lần nữa. Vì vậy, bằng cách sử dụng
"echo 0 > scl" bạn đặt SCL ở mức thấp và do đó, sẽ không thể liên lạc được
bởi vì chủ xe buýt đang được thử nghiệm sẽ không thể bấm giờ. Nó sẽ phát hiện
tình trạng SCL không phản hồi và báo lỗi cho cấp trên
các lớp.

"sda"
-----

Bằng cách đọc tệp này, bạn sẽ có được trạng thái hiện tại của SDA. Bằng cách viết, bạn có thể
thay đổi trạng thái của nó để buộc nó ở mức thấp hoặc thả nó ra lần nữa. Vì vậy, bằng cách sử dụng
"echo 0 > sda" bạn đặt SDA ở mức thấp và do đó, dữ liệu không thể truyền được. xe buýt
Master đang được kiểm tra sẽ phát hiện tình trạng này và kích hoạt khôi phục bus (xem
Thông số kỹ thuật I2C phiên bản 4, phần 3.1.16) sử dụng trình trợ giúp của Linux I2C
lõi (xem 'struct bus_recovery_info'). Tuy nhiên, việc phục hồi xe buýt sẽ không
thành công vì SDA vẫn được ghim ở mức thấp cho đến khi bạn giải phóng lại theo cách thủ công
với "tiếng vang 1> sda". Việc kiểm tra với chế độ phát hành tự động có thể được thực hiện bằng
lớp "chuyển giao không đầy đủ" của kim phun lỗi.

Chuyển khoản chưa hoàn tất
====================

Các kim phun lỗi sau đây tạo ra các tình huống trong đó SDA sẽ bị giữ ở mức thấp
thiết bị. Phục hồi xe buýt sẽ có thể khắc phục những tình huống này. Nhưng xin lưu ý:
có các thiết bị khách I2C phát hiện SDA bị kẹt ở bên cạnh và giải phóng
nó sẽ tự động hoạt động sau vài mili giây. Ngoài ra, có thể có một tác nhân bên ngoài
thiết bị ngừng hoạt động và giám sát bus I2C. Nó cũng có thể phát hiện SDA bị kẹt
và sẽ tự khởi động quá trình khôi phục xe buýt. Nếu bạn muốn thực hiện khôi phục xe buýt
trong trình điều khiển chính của xe buýt, hãy đảm bảo bạn đã kiểm tra thiết lập phần cứng của mình để biết những điều đó
các thiết bị trước đó. Và luôn xác minh bằng máy phân tích phạm vi hoặc logic!

"không đầy đủ_địa chỉ_phase"
--------------------------

Tệp này chỉ được ghi và bạn cần ghi địa chỉ của I2C hiện có
thiết bị khách hàng với nó. Sau đó, quá trình truyền đọc tới thiết bị này sẽ được bắt đầu, nhưng
nó sẽ dừng ở giai đoạn ACK sau khi địa chỉ của máy khách đã được
được truyền đi. Bởi vì thiết bị sẽ có ACK sự hiện diện của nó, điều này dẫn đến SDA
bị thiết bị kéo xuống thấp trong khi SCL ở mức cao. Vì vậy, tương tự như tệp "sda"
ở trên, chủ xe buýt đang được kiểm tra sẽ phát hiện tình trạng này và thử một xe buýt
phục hồi. Tuy nhiên, lần này sẽ thành công và thiết bị sẽ giải phóng
SDA sau khi chuyển đổi SCL.

"không đầy đủ_write_byte"
-----------------------

Tương tự như trên, file này chỉ được ghi và bạn cần ghi địa chỉ của
một thiết bị khách I2C hiện có vào nó.

Kim phun sẽ lại dừng ở một pha ACK, do đó thiết bị sẽ giữ SDA ở mức thấp
bởi vì nó thừa nhận dữ liệu. Tuy nhiên, có hai điểm khác biệt so với
'không đầy đủ_address_phase':

a) tin nhắn được gửi đi sẽ là tin nhắn viết
b) sau byte địa chỉ, byte 0x00 sẽ được chuyển. Sau đó, dừng lại ở ACK.

Đây là trạng thái rất nhạy cảm, thiết bị được thiết lập để ghi bất kỳ dữ liệu nào vào
đăng ký 0x00 (nếu nó có các thanh ghi) khi các xung đồng hồ tiếp theo xảy ra trên SCL.
Đây là lý do tại sao việc khôi phục bus (tối đa 9 xung đồng hồ) phải kiểm tra SDA hoặc gửi
điều kiện STOP bổ sung để đảm bảo xe buýt đã được giải phóng. Nếu không
dữ liệu ngẫu nhiên sẽ được ghi vào thiết bị!

Trọng tài thua
================

Ở đây, chúng tôi muốn mô phỏng điều kiện trong đó bản gốc được thử nghiệm mất
trọng tài bus đối với một máy chủ khác trong thiết lập nhiều máy chủ.

"thua_trọng tài"
------------------

Tệp này chỉ được ghi và bạn cần ghi thời gian phân xử
nhiễu (tính bằng µs, tối đa là 100ms). Quá trình gọi sau đó sẽ ngủ
và đợi đồng hồ xe buýt tiếp theo. Tuy nhiên, quá trình này có thể bị gián đoạn.

Việc thua trọng tài đạt được bằng cách đợi SCL bị chủ nhân hạ xuống
kiểm tra và sau đó kéo SDA xuống thấp trong một thời gian. Vì vậy, địa chỉ I2C đã được gửi đi
nên bị hỏng và cần được phát hiện đúng cách. Điều đó có nghĩa là
địa chỉ được gửi đi phải có nhiều bit '1' để có thể phát hiện tham nhũng.
Không cần thiết phải có thiết bị ở địa chỉ này vì trọng tài bị mất
nên được phát hiện trước. Cũng lưu ý rằng việc SCL ngừng hoạt động sẽ được theo dõi
sử dụng các ngắt, do đó độ trễ ngắt có thể khiến các bit đầu tiên không được
bị hỏng. Một điểm khởi đầu tốt để sử dụng bộ phun lỗi này trên một thiết bị khác
xe buýt nhàn rỗi là::

# echo 200 > thua_trọng tài &
  # i2cget -y <bus_to_test> 0x3f

Hoảng loạn khi chuyển giao
=====================

Trình tạo lỗi này sẽ tạo ra một hạt nhân hoảng loạn khi bản gốc được kiểm tra
bắt đầu chuyển giao. Điều này thường có nghĩa là máy trạng thái của bus master
người lái xe sẽ bị gián đoạn một cách vô duyên và xe buýt có thể rơi vào tình trạng bất thường
trạng thái. Sử dụng cái này để kiểm tra xem mã tắt máy/khởi động lại/khởi động của bạn có thể xử lý việc này không
kịch bản.

"tiêm_hoảng loạn"
--------------

Tệp này chỉ được ghi và bạn cần ghi độ trễ giữa thời điểm được phát hiện
bắt đầu truyền và gây ra hoảng loạn hạt nhân (tính bằng µs, tối đa là 100ms).
Quá trình gọi sau đó sẽ ngủ và chờ đồng hồ xe buýt tiếp theo. các
Tuy nhiên, quá trình này có thể bị gián đoạn.

Việc bắt đầu truyền được phát hiện bằng cách chờ SCL được chủ thực hiện xuống
đang được thử nghiệm.  Điểm khởi đầu tốt để sử dụng bộ phun lỗi này là::

# echo 0 > tiêm_panic &
  # i2cget -y <bus_to_test> <some_address>

Lưu ý rằng không cần thiết phải có thiết bị nghe địa chỉ bạn đang ở
sử dụng. Tuy nhiên, kết quả có thể khác nhau tùy thuộc vào điều đó.
