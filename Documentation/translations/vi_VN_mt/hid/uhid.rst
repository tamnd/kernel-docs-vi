.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/uhid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================================================
UHID - Hỗ trợ trình điều khiển I/O không gian người dùng cho hệ thống con HID
======================================================

UHID cho phép không gian người dùng triển khai trình điều khiển vận chuyển HID. Xin vui lòng xem
hid-transport.rst để giới thiệu về trình điều khiển vận chuyển HID. Tài liệu này
phụ thuộc rất nhiều vào các định nghĩa được khai báo ở đó.

Với UHID, trình điều khiển vận chuyển không gian người dùng có thể tạo các thiết bị ẩn kernel cho mỗi
thiết bị được kết nối với bus được điều khiển bởi không gian người dùng. UHID API xác định I/O
các sự kiện được cung cấp từ kernel đến không gian người dùng và ngược lại.

Có một ứng dụng không gian người dùng mẫu trong ./samples/uhid/uhid-example.c

UHID API
------------

UHID được truy cập thông qua một thiết bị ký tự linh tinh. Số thứ yếu được phân bổ
động nên bạn cần dựa vào udev (hoặc tương tự) để tạo nút thiết bị.
Đây là /dev/uhid theo mặc định.

Nếu Trình điều khiển I/O HID của bạn phát hiện một thiết bị mới và bạn muốn đăng ký thiết bị này
thiết bị có hệ thống con HID, thì bạn cần mở /dev/uhid một lần cho mỗi thiết bị
thiết bị bạn muốn đăng ký. Tất cả các giao tiếp tiếp theo được thực hiện bằng cách read()'ing hoặc
write()'ing các đối tượng "struct uhid_event". Hoạt động không chặn được hỗ trợ
bằng cách cài đặt O_NONBLOCK::

cấu trúc uhid_event {
        __u32 loại;
        công đoàn {
                cấu trúc uhid_create2_req create2;
                cấu trúc đầu ra uhid_output_req;
                cấu trúc uhid_input2_req input2;
                ...
} bạn;
  };

Trường "loại" chứa ID của sự kiện. Tùy theo ID khác nhau
tải trọng được gửi đi. Bạn không được chia một sự kiện thành nhiều lần đọc() hoặc
nhiều lần ghi(). Một sự kiện duy nhất phải luôn được gửi toàn bộ. Hơn nữa,
chỉ một sự kiện duy nhất có thể được gửi cho mỗi lần đọc() hoặc ghi(). Dữ liệu đang chờ xử lý bị bỏ qua.
Nếu bạn muốn xử lý nhiều sự kiện trong một tòa nhà chung cư, hãy sử dụng vectơ
I/O với readv()/writev().
Trường "loại" xác định tải trọng. Đối với mỗi loại có một
cấu trúc tải trọng có sẵn trong liên kết "u" (ngoại trừ tải trọng trống). Cái này
tải trọng chứa dữ liệu quản lý và/hoặc thiết bị.

Điều đầu tiên bạn nên làm là gửi sự kiện UHID_CREATE2. Điều này sẽ
đăng ký thiết bị. UHID sẽ phản hồi bằng sự kiện UHID_START. Bây giờ bạn có thể
bắt đầu gửi dữ liệu đến và đọc dữ liệu từ UHID. Tuy nhiên, trừ khi UHID gửi
Sự kiện UHID_OPEN, Trình điều khiển thiết bị HID được đính kèm bên trong không có người dùng nào được đính kèm.
Nghĩa là, bạn có thể đặt thiết bị của mình ở chế độ ngủ trừ khi bạn nhận được UHID_OPEN
sự kiện. Nếu bạn nhận được sự kiện UHID_OPEN, bạn nên bắt đầu I/O. Nếu cuối cùng
người dùng đóng thiết bị HID, bạn sẽ nhận được sự kiện UHID_CLOSE. Đây có thể là
tiếp theo là sự kiện UHID_OPEN một lần nữa, v.v. Không cần thiết phải thực hiện
đếm tham chiếu trong không gian người dùng. Tức là bạn sẽ không bao giờ nhận được nhiều
Sự kiện UHID_OPEN không có sự kiện UHID_CLOSE. Hệ thống con HID thực hiện
đếm lại cho bạn.
Tuy nhiên, bạn có thể quyết định bỏ qua UHID_OPEN/UHID_CLOSE. I/O được cho phép ngay cả
mặc dù thiết bị có thể không có người dùng.

Nếu bạn muốn gửi dữ liệu trên kênh ngắt tới hệ thống con HID, bạn gửi
sự kiện HID_INPUT2 với tải trọng dữ liệu thô của bạn. Nếu kernel muốn gửi dữ liệu
trên kênh ngắt tới thiết bị, bạn sẽ đọc sự kiện UHID_OUTPUT.
Yêu cầu dữ liệu trên kênh điều khiển hiện bị giới hạn ở GET_REPORT và
SET_REPORT (cho đến nay không có báo cáo dữ liệu nào khác trên kênh điều khiển được xác định).
Những yêu cầu đó luôn đồng bộ. Điều đó có nghĩa là kernel sẽ gửi
Các sự kiện UHID_GET_REPORT và UHID_SET_REPORT và yêu cầu bạn chuyển tiếp chúng tới
thiết bị trên kênh điều khiển. Sau khi thiết bị phản hồi, bạn phải chuyển tiếp
phản hồi thông qua UHID_GET_REPORT_REPLY và UHID_SET_REPORT_REPLY tới kernel.
Hạt nhân chặn việc thực thi trình điều khiển nội bộ trong các chuyến đi khứ hồi như vậy (hết thời gian
sau một khoảng thời gian được mã hóa cứng).

Nếu thiết bị của bạn ngắt kết nối, bạn nên gửi sự kiện UHID_DESTROY. Điều này sẽ
hủy đăng ký thiết bị. Bây giờ bạn có thể gửi lại UHID_CREATE2 để đăng ký tài khoản mới
thiết bị.
Nếu bạn close() fd, thiết bị sẽ tự động bị hủy đăng ký và bị hủy
nội bộ.

viết()
-------
write() cho phép bạn sửa đổi trạng thái của thiết bị và đưa dữ liệu đầu vào vào
hạt nhân. Hạt nhân sẽ phân tích sự kiện ngay lập tức và nếu ID sự kiện là
không được hỗ trợ, nó sẽ trả về -EOPNOTSUPP. Nếu tải trọng không hợp lệ thì
-EINVAL được trả về, nếu không, lượng dữ liệu đã đọc sẽ được trả về và
yêu cầu đã được xử lý thành công. O_NONBLOCK không ảnh hưởng đến write() vì
việc ghi luôn được xử lý ngay lập tức theo kiểu không bị chặn. Yêu cầu trong tương lai
Tuy nhiên, có thể sử dụng O_NONBLOCK.

UHID_CREATE2:
  Điều này tạo ra thiết bị HID bên trong. Không thể thực hiện I/O cho đến khi bạn gửi cái này
  sự kiện vào kernel. Tải trọng có kiểu struct uhid_create2_req và
  chứa thông tin về thiết bị của bạn. Bạn có thể bắt đầu I/O ngay bây giờ.

UHID_DESTROY:
  Điều này sẽ phá hủy thiết bị HID bên trong. I/O tiếp theo sẽ không được chấp nhận. Ở đó
  có thể vẫn đang chờ các tin nhắn mà bạn có thể nhận được bằng read() nhưng không còn nữa
  Các sự kiện UHID_INPUT có thể được gửi tới kernel.
  Bạn có thể tạo một thiết bị mới bằng cách gửi lại UHID_CREATE2. Không cần thiết phải
  mở lại thiết bị ký tự.

UHID_INPUT2:
  Bạn phải gửi UHID_CREATE2 trước khi gửi đầu vào vào kernel! Sự kiện này
  chứa một tải trọng dữ liệu. Đây là dữ liệu thô mà bạn đọc từ thiết bị của mình
  trên kênh ngắt. Hạt nhân sẽ phân tích các báo cáo HID.

UHID_GET_REPORT_REPLY:
  Nếu bạn nhận được yêu cầu UHID_GET_REPORT, bạn phải trả lời yêu cầu này.
  Bạn phải sao chép trường "id" từ yêu cầu vào câu trả lời. Đặt "lỗi"
  trường thành 0 nếu không xảy ra lỗi hoặc tới EIO nếu xảy ra lỗi I/O.
  Nếu "err" bằng 0 thì bạn nên điền kết quả vào bộ đệm của câu trả lời
  của yêu cầu GET_REPORT và đặt "kích thước" tương ứng.

UHID_SET_REPORT_REPLY:
  Đây là SET_REPORT tương đương với UHID_GET_REPORT_REPLY. Không giống như GET_REPORT,
  SET_REPORT không bao giờ trả về bộ đệm dữ liệu, do đó, chỉ cần đặt
  trường "id" và "err" một cách chính xác.

đọc()
------
read() sẽ trả về một báo cáo đầu ra được xếp hàng đợi. Không cần phản ứng với bất kỳ
chúng nhưng bạn nên xử lý chúng theo nhu cầu của bạn.

UHID_START:
  Điều này được gửi khi thiết bị HID được khởi động. Hãy coi đây là câu trả lời cho
  UHID_CREATE2. Đây luôn là sự kiện đầu tiên được gửi đi. Lưu ý rằng điều này
  sự kiện có thể không khả dụng ngay sau khi write(UHID_CREATE2) trả về.
  Trình điều khiển thiết bị có thể yêu cầu thiết lập bị trì hoãn.
  Sự kiện này chứa tải trọng thuộc loại uhid_start_req. Trường "dev_flags"
  mô tả các hành vi đặc biệt của một thiết bị. Các cờ sau được xác định:

-UHID_DEV_NUMBERED_FEATURE_REPORTS
      -UHID_DEV_NUMBERED_OUTPUT_REPORTS
      -UHID_DEV_NUMBERED_INPUT_REPORTS

Mỗi cờ này xác định liệu một loại báo cáo nhất định có sử dụng số
          báo cáo. Nếu sử dụng các báo cáo được đánh số cho một loại thì tất cả các tin nhắn từ
          hạt nhân đã có số báo cáo làm tiền tố. Nếu không thì không
          tiền tố được thêm vào bởi kernel.
          Đối với các tin nhắn được gửi bởi không gian người dùng tới kernel, bạn phải điều chỉnh
          tiền tố theo các cờ này.

UHID_STOP:
  Điều này được gửi khi thiết bị HID bị dừng. Hãy coi đây là câu trả lời cho
  UHID_DESTROY.

Nếu bạn không phá hủy thiết bị của mình thông qua UHID_DESTROY, nhưng kernel sẽ gửi một
  Sự kiện UHID_STOP, điều này thường bị bỏ qua. Nó có nghĩa là hạt nhân
  đã tải lại/thay đổi trình điều khiển thiết bị được tải trên thiết bị HID của bạn (hoặc một số thiết bị khác
  hành động bảo trì đã xảy ra).

Bạn thường có thể bỏ qua mọi sự kiện UHID_STOP một cách an toàn.

UHID_OPEN:
  Điều này được gửi khi thiết bị HID được mở. Tức là dữ liệu mà HID
  thiết bị cung cấp được đọc bởi một số quá trình khác. Bạn có thể bỏ qua sự kiện này nhưng
  nó rất hữu ích cho việc quản lý năng lượng. Miễn là bạn chưa nhận được sự kiện này
  thực tế không có quy trình nào khác đọc dữ liệu của bạn nên không cần thiết
  gửi các sự kiện UHID_INPUT2 tới kernel.

UHID_CLOSE:
  Điều này được gửi khi không còn quá trình nào đọc dữ liệu HID nữa. Đó là
  bản sao của UHID_OPEN và bạn cũng có thể bỏ qua sự kiện này.

UHID_OUTPUT:
  Điều này được gửi nếu trình điều khiển thiết bị HID muốn gửi dữ liệu thô tới I/O
  thiết bị trên kênh ngắt. Bạn nên đọc tải trọng và chuyển tiếp nó tới
  thiết bị. Tải trọng thuộc loại "struct uhid_output_req".
  Điều này có thể được nhận ngay cả khi bạn chưa nhận được UHID_OPEN.

UHID_GET_REPORT:
  Sự kiện này được gửi nếu trình điều khiển kernel muốn thực hiện yêu cầu GET_REPORT
  trên kênh điều khiển như được mô tả trong thông số kỹ thuật HID. Loại báo cáo và
  số báo cáo có sẵn trong tải trọng.
  Kernel tuần tự hóa các yêu cầu GET_REPORT nên sẽ không bao giờ có hai yêu cầu trong
  song song. Tuy nhiên, nếu bạn không phản hồi bằng UHID_GET_REPORT_REPLY,
  yêu cầu có thể âm thầm hết thời gian chờ.
  Sau khi đọc yêu cầu GET_REPORT, bạn sẽ chuyển tiếp yêu cầu đó đến thiết bị HID và
  hãy nhớ trường "id" trong tải trọng. Sau khi thiết bị HID của bạn phản hồi với
  GET_REPORT (hoặc nếu thất bại), bạn phải gửi UHID_GET_REPORT_REPLY tới
  kernel có cùng "id" như trong yêu cầu. Nếu yêu cầu đã có
  hết thời gian, kernel sẽ âm thầm bỏ qua phản hồi. Trường "id" là
  không bao giờ được sử dụng lại nên xung đột không thể xảy ra.

UHID_SET_REPORT:
  Đây là SET_REPORT tương đương với UHID_GET_REPORT. Khi nhận được, bạn sẽ
  gửi yêu cầu SET_REPORT tới thiết bị HID của bạn. Sau khi nó trả lời, bạn phải nói
  kernel về nó thông qua UHID_SET_REPORT_REPLY.
  Áp dụng các hạn chế tương tự như đối với UHID_GET_REPORT.

---------------------------------------------------

Viết năm 2012, David Herrmann <dh.herrmann@gmail.com>
