.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/i2c/slave-interface.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================
Mô tả giao diện nô lệ Linux I2C
=====================================

bởi Wolfram Sang <wsa@sang-engineering.com> vào năm 2014-15

Linux cũng có thể là nô lệ I2C nếu bộ điều khiển I2C đang sử dụng có nô lệ
chức năng. Để làm việc đó, người ta cần có sự hỗ trợ nô lệ trong trình điều khiển xe buýt cộng thêm
một phần mềm phụ trợ độc lập với phần cứng cung cấp chức năng thực tế. Một
ví dụ cho cái sau là trình điều khiển nô lệ-eeprom, hoạt động như một bộ nhớ kép
người lái xe. Trong khi một chủ I2C khác trên xe buýt có thể truy cập nó như thông thường
EEPROM, nô lệ I2C của Linux có thể truy cập nội dung thông qua sysfs và xử lý dữ liệu dưới dạng
cần thiết. Trình điều khiển phụ trợ và trình điều khiển xe buýt I2C giao tiếp thông qua các sự kiện. đây
là một biểu đồ nhỏ trực quan hóa luồng dữ liệu và phương tiện dữ liệu được
được vận chuyển. Đường chấm chấm chỉ đánh dấu một ví dụ. Phần phụ trợ cũng có thể
sử dụng một thiết bị ký tự, chỉ ở trong kernel hoặc một cái gì đó hoàn toàn khác ::


ví dụ. sysfs Sự kiện phụ I2C Thanh ghi I/O
  +----------+ v +----------+ v +--------+ v +-------------+
  ZZ0000ZZ
  +----------+ +----------+ +--------+ +-------------+
                                                                ZZ0001ZZ
  --------------------------------------------------+-- I2C
  --------------------------------------------------------------+---- Xe buýt

Lưu ý: Về mặt kỹ thuật, còn có lõi I2C nằm giữa phần phụ trợ và phần
người lái xe. Tuy nhiên, tại thời điểm viết bài này, lớp này trong suốt.


Hướng dẫn sử dụng
===========

Các chương trình phụ trợ nô lệ của I2C hoạt động giống như các máy khách I2C tiêu chuẩn. Vì vậy, bạn có thể khởi tạo
chúng như được mô tả trong tài liệu instantiate-devices.rst. duy nhất
sự khác biệt là phần phụ trợ nô lệ i2c có không gian địa chỉ riêng. Vì vậy, bạn
phải thêm 0x1000 vào địa chỉ bạn yêu cầu ban đầu. Một ví dụ cho
khởi tạo trình điều khiển nô lệ-eeprom từ không gian người dùng ở địa chỉ 7 bit 0x64
trên xe buýt 1::

# echo nô lệ-24c02 0x1064 > /sys/bus/i2c/devices/i2c-1/new_device

Mỗi phần phụ trợ phải đi kèm với tài liệu riêng để mô tả cụ thể của nó
hành vi và thiết lập.


Hướng dẫn dành cho nhà phát triển
================

Đầu tiên, các sự kiện được tài xế xe buýt và phần phụ trợ sử dụng sẽ được
được mô tả chi tiết. Sau đó, một số gợi ý triển khai để mở rộng bus
trình điều khiển và phần phụ trợ viết sẽ được cung cấp.


Sự kiện nô lệ I2C
----------------

Trình điều khiển xe buýt gửi một sự kiện đến chương trình phụ trợ bằng chức năng sau ::

ret = i2c_slave_event(client, sự kiện, &val)

'khách hàng' mô tả thiết bị phụ I2C. 'sự kiện' là một trong những sự kiện đặc biệt
các loại được mô tả sau đây. 'val' giữ giá trị u8 cho byte dữ liệu
đọc/ghi và do đó là hai chiều. Con trỏ tới val phải luôn là
được cung cấp ngay cả khi val không được sử dụng cho một sự kiện, tức là không sử dụng NULL tại đây. 'ret'
là giá trị trả về từ chương trình phụ trợ. Các sự kiện bắt buộc phải được cung cấp bởi
trình điều khiển xe buýt và phải được kiểm tra bởi trình điều khiển phụ trợ.

Các loại sự kiện:

* I2C_SLAVE_WRITE_REQUESTED (bắt buộc)

'val': không sử dụng

'ret': 0 nếu phần phụ trợ đã sẵn sàng, nếu không thì không có lỗi

Một chủ I2C khác muốn ghi dữ liệu cho chúng tôi. Sự kiện này phải được gửi một lần
địa chỉ của chúng tôi và bit ghi đã được phát hiện. Dữ liệu vẫn chưa đến, vì vậy
không có gì để xử lý hoặc trả lại. Sau khi quay về, tài xế xe buýt phải
luôn luôn xác nhận giai đoạn địa chỉ. Nếu 'ret' bằng 0, khởi tạo phụ trợ hoặc
quá trình đánh thức đã hoàn tất và dữ liệu tiếp theo có thể được nhận. Nếu 'ret' là một lỗi sai thì xe buýt
trình điều khiển nên xử lý tất cả các byte đến cho đến khi điều kiện dừng tiếp theo để thực thi
việc thử lại đường truyền.

* I2C_SLAVE_READ_REQUESTED (bắt buộc)

'val': phần phụ trợ trả về byte đầu tiên được gửi

'ret': luôn là 0

Một chủ I2C khác muốn đọc dữ liệu từ chúng tôi. Sự kiện này phải được gửi một lần
địa chỉ của chúng tôi và bit đọc đã được phát hiện. Sau khi trở về, tài xế xe buýt
nên truyền byte đầu tiên.

* I2C_SLAVE_WRITE_RECEIVED (bắt buộc)

'val': trình điều khiển xe buýt gửi byte đã nhận

'ret': 0 nếu byte cần được xác nhận, một số lỗi sẽ xảy ra nếu byte cần được xác nhận

Một chủ I2C khác đã gửi một byte cho chúng tôi cần được đặt trong 'val'. Nếu 'ret'
bằng 0, trình điều khiển xe buýt sẽ xác nhận byte này. Nếu 'ret' là một lỗi thì byte
nên được khắc phục.

* I2C_SLAVE_READ_PROCESSED (bắt buộc)

'val': phần phụ trợ trả về byte tiếp theo sẽ được gửi

'ret': luôn là 0

Trình điều khiển xe buýt yêu cầu byte tiếp theo được gửi đến một máy chủ I2C khác trong
'val'. Quan trọng: Điều này không có nghĩa là byte trước đó đã được xác nhận, nó
chỉ có nghĩa là byte trước đó được chuyển ra bus! Để đảm bảo liền mạch
truyền, hầu hết phần cứng đều yêu cầu byte tiếp theo khi byte trước đó được
vẫn dịch chuyển ra ngoài. Nếu chủ gửi NACK và dừng đọc sau byte
hiện đã được chuyển ra ngoài, byte được yêu cầu ở đây không bao giờ được sử dụng. Rất có thể
cần được gửi lại trên I2C_SLAVE_READ_REQUEST tiếp theo, tùy thuộc một chút vào
Tuy nhiên, phần phụ trợ của bạn.

* I2C_SLAVE_STOP (bắt buộc)

'val': không sử dụng

'ret': luôn là 0

Một điều kiện dừng đã được nhận. Điều này có thể xảy ra bất cứ lúc nào và phần phụ trợ sẽ
đặt lại máy trạng thái của nó để chuyển I2C để có thể nhận các yêu cầu mới.


Phần mềm phụ trợ
-----------------

Nếu bạn muốn viết phần mềm phụ trợ:

* sử dụng i2c_driver tiêu chuẩn và các cơ chế phù hợp của nó
* viết Slav_callback để xử lý các sự kiện nô lệ ở trên
  (tốt nhất là sử dụng máy trạng thái)
* đăng ký cuộc gọi lại này qua i2c_slave_register()

Kiểm tra trình điều khiển i2c-slave-eeprom làm ví dụ.


Hỗ trợ tài xế xe buýt
------------------

Nếu bạn muốn thêm hỗ trợ nô lệ cho trình điều khiển xe buýt:

* thực hiện các lệnh gọi để đăng ký/hủy đăng ký nô lệ và thêm chúng vào
  cấu trúc i2c_algorithm. Khi đăng ký chắc chắn bạn sẽ cần đặt I2C
  địa chỉ nô lệ và cho phép các ngắt cụ thể của nô lệ. Nếu bạn sử dụng thời gian chạy chiều, bạn
  nên sử dụng pm_runtime_get_sync() vì thiết bị của bạn thường cần
  luôn bật nguồn để có thể phát hiện địa chỉ nô lệ của nó. Khi hủy đăng ký,
  làm ngược lại điều trên.

* Bắt các ngắt nô lệ và gửi i2c_slave_event thích hợp đến phần phụ trợ.

Lưu ý rằng hầu hết phần cứng đều hỗ trợ làm master _and_ Slave trên cùng một bus. Vì vậy,
nếu bạn mở rộng trình điều khiển xe buýt, vui lòng đảm bảo rằng trình điều khiển đó hỗ trợ điều đó
tốt. Trong hầu hết các trường hợp, hỗ trợ nô lệ không cần phải tắt chế độ chính
chức năng.

Kiểm tra trình điều khiển i2c-rcar làm ví dụ.


Giới thiệu về ACK/NACK
--------------

Việc luôn luôn sử dụng pha địa chỉ ACK là một hành vi tốt, để chủ nhân biết liệu một
về cơ bản thiết bị vẫn tồn tại hoặc nếu nó biến mất một cách bí ẩn. Sử dụng NACK để
trạng thái bận rộn là rắc rối. SMBus yêu cầu luôn có ACK giai đoạn địa chỉ,
trong khi thông số kỹ thuật của I2C lại lỏng lẻo hơn về điều đó. Hầu hết các bộ điều khiển I2C cũng
tự động ACK khi phát hiện địa chỉ nô lệ của họ, vì vậy không có tùy chọn
tới NACK chúng. Vì những lý do đó, API này không hỗ trợ NACK trong địa chỉ
giai đoạn.

Hiện tại, không có sự kiện phụ nào để báo cáo nếu chủ đã thực hiện ACK hoặc NACK a
byte khi nó đọc từ chúng tôi. Chúng tôi có thể biến sự kiện này thành một sự kiện tùy chọn nếu cần
phát sinh. Tuy nhiên, các trường hợp này cực kỳ hiếm vì chủ nhân được mong đợi
gửi STOP sau đó và chúng tôi có một sự kiện cho việc đó. Ngoài ra, hãy nhớ rằng không
tất cả bộ điều khiển I2C đều có khả năng báo cáo sự kiện đó.


Giới thiệu về bộ đệm
-------------

Trong quá trình phát triển API này, câu hỏi về việc sử dụng bộ đệm thay vì chỉ
byte xuất hiện. Việc mở rộng như vậy có thể thực hiện được, nhưng tính hữu dụng vẫn chưa rõ ràng
lần viết bài này. Một số điểm cần lưu ý khi sử dụng bộ đệm:

* Bộ đệm phải được chọn tham gia và trình điều khiển phụ trợ sẽ luôn phải hỗ trợ
  dù sao đi nữa, các giao dịch dựa trên byte là phương án dự phòng cuối cùng vì đây là cách
  phần lớn các công việc HW.

* Đối với phần phụ trợ mô phỏng các thanh ghi phần cứng, bộ đệm phần lớn không hữu ích
  bởi vì sau mỗi byte được ghi, một hành động sẽ được kích hoạt ngay lập tức.
  Đối với các lần đọc, dữ liệu được lưu trong bộ đệm có thể bị cũ nếu phần phụ trợ chỉ
  đã cập nhật một sổ đăng ký vì xử lý nội bộ.

* Người chủ có thể gửi STOP bất cứ lúc nào. Đối với bộ đệm được chuyển một phần, điều này
  có nghĩa là mã bổ sung để xử lý ngoại lệ này. Mã như vậy có xu hướng
  dễ bị lỗi.
