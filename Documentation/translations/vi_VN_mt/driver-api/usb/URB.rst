.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/URB.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _usb-urb:

Khối yêu cầu USB (URB)
~~~~~~~~~~~~~~~~~~~~~~~

:Sửa đổi: 2000-Dec-05
:Lại: 06-07-2002
:Lại: 2005-Tháng 9-19
:Một lần nữa: 29-03-2017


.. note::

    The USB subsystem now has a substantial section at :ref:`usb-hostside-api`
    section, generated from the current source code.
    This particular documentation file isn't complete and may not be
    updated to the last version; don't rely on it except for a quick
    overview.

Khái niệm cơ bản hoặc 'URB là gì?'
==================================

Ý tưởng cơ bản của trình điều khiển mới là truyền thông điệp, bản thân thông điệp
được gọi là Khối yêu cầu USB, hay viết tắt là URB.

- URB bao gồm tất cả thông tin liên quan để thực hiện bất kỳ giao dịch USB nào
  và cung cấp lại dữ liệu cũng như trạng thái.

- Việc thực thi URB vốn là một hoạt động không đồng bộ, tức là
  Cuộc gọi ZZ0000ZZ trả về ngay sau khi thành công
  xếp hàng đợi hành động được yêu cầu.

- Chuyển khoản cho một URB có thể bị hủy bằng ZZ0000ZZ
  bất cứ lúc nào.

- Mỗi URB có một trình xử lý hoàn thành, được gọi sau hành động
  đã được hoàn thành thành công hoặc bị hủy bỏ. URB cũng chứa một
  con trỏ ngữ cảnh để truyền thông tin đến trình xử lý hoàn thành.

- Mỗi điểm cuối cho một thiết bị hỗ trợ một cách hợp lý một hàng yêu cầu.
  Bạn có thể lấp đầy hàng đợi đó để phần cứng USB vẫn có thể truyền được
  dữ liệu đến điểm cuối trong khi trình điều khiển của bạn xử lý việc hoàn thành một điểm cuối khác.
  Điều này tối đa hóa việc sử dụng băng thông USB và hỗ trợ truyền phát liền mạch
  dữ liệu đến (hoặc từ) thiết bị khi sử dụng chế độ truyền định kỳ.


Cấu trúc URB
=================

Một số trường trong struct urb là::

cấu trúc đô thị
  {
  // (IN) thiết bị và đường ống chỉ định hàng đợi điểm cuối
	cấu trúc usb_device *dev;         // con trỏ tới thiết bị USB được liên kết
	ống int không dấu;              // thông tin điểm cuối

unsigned int transfer_flags;    // URB_ISO_ASAP, URB_SHORT_NOT_OK, v.v.

// (IN) tất cả các đô thị cần có quy trình hoàn thiện
	void *bối cảnh;                  // bối cảnh cho thủ tục hoàn thành
	usb_complete_t hoàn thành;        // con trỏ tới thủ tục hoàn thành

// Trạng thái (OUT) sau mỗi lần hoàn thành
	trạng thái int;                     // trạng thái trả về

// Bộ đệm (IN) dùng để truyền dữ liệu
	void *transfer_buffer;          // vùng đệm dữ liệu liên quan
	u32 transfer_buffer_length;     // chiều dài vùng đệm dữ liệu
	int number_of_packets;          // kích thước của iso_frame_desc

// (OUT) đôi khi chỉ một phần của CTRL/BULK/INTR transfer_buffer được sử dụng
	u32 thực tế_length;              // độ dài bộ đệm dữ liệu thực tế

// (IN) giai đoạn thiết lập cho CTRL (chuyển struct usb_ctrlrequest)
	ký tự không dấu *setup_packet;    // gói thiết lập (chỉ điều khiển)

// Chỉ dành cho chuyển khoản PERIODIC (ISO, INTERRUPT)
    // (IN/OUT) start_frame được đặt trừ khi URB_ISO_ASAP không được đặt
	int start_frame;                // khung bắt đầu
	khoảng int;                   // khoảng thời gian bỏ phiếu

// Chỉ ISO: các gói chỉ là "nỗ lực tốt nhất"; mỗi cái đều có thể có lỗi
	int error_count;                // số lỗi
	cấu trúc usb_iso_packet_descriptor iso_frame_desc[0];
  };

Trình điều khiển của bạn phải tạo giá trị "ống" bằng cách sử dụng các giá trị từ
bộ mô tả điểm cuối trong giao diện mà nó được yêu cầu.


Làm thế nào để có được URB?
==================

URB được phân bổ bằng cách gọi ZZ0000ZZ::

struct urb *usb_alloc_urb(int isoframe, int mem_flags)

Giá trị trả về là một con trỏ tới URB được phân bổ, 0 nếu phân bổ không thành công.
Tham số isoframe chỉ định số lượng khung truyền đẳng thời
bạn muốn đặt lịch. Đối với CTRL/BULK/INT, sử dụng 0. Tham số mem_flags
giữ các cờ phân bổ bộ nhớ tiêu chuẩn, cho phép bạn kiểm soát (trong số các cờ khác
thứ) liệu mã cơ bản có thể chặn hay không.

Để giải phóng URB, hãy sử dụng ZZ0000ZZ::

void usb_free_urb(struct urb *urb)

Bạn có thể giải phóng một đô thị mà bạn đã gửi nhưng chưa được
trả lại cho bạn trong một cuộc gọi lại hoàn thành.  Nó sẽ tự động được
được giải phóng khi không còn sử dụng nữa.


Phải điền những gì?
=========================

Tùy thuộc vào loại giao dịch, có một số chức năng nội tuyến
được xác định trong ZZ0003ZZ để đơn giản hóa việc khởi tạo, chẳng hạn như
ZZ0000ZZ, ZZ0001ZZ và
ZZ0002ZZ.  Nói chung, họ cần con trỏ thiết bị usb,
đường ống (định dạng thông thường từ usb.h), bộ đệm truyền, truyền mong muốn
length, trình xử lý hoàn thành và ngữ cảnh của nó. Hãy nhìn vào một số
trình điều khiển hiện có để xem chúng được sử dụng như thế nào.

Cờ:

- Đối với ISO có hai hành vi khởi động: Speced start_frame hoặc ASAP.
- Đối với ASAP, đặt ZZ0000ZZ trong transfer_flags.

Nếu các gói ngắn có thể chấp nhận được NOT, hãy đặt ZZ0000ZZ ở
transfer_flags.


Làm cách nào để gửi URB?
=====================

Chỉ cần gọi ZZ0000ZZ::

int usb_submit_urb(struct urb *urb, int mem_flags)

Tham số ZZ0000ZZ, chẳng hạn như ZZ0001ZZ, điều khiển bộ nhớ
phân bổ, chẳng hạn như liệu các mức thấp hơn có thể chặn khi bộ nhớ chật hẹp hay không.

Nó ngay lập tức trả về với trạng thái 0 (yêu cầu được xếp hàng đợi) hoặc một số
mã lỗi, thường do nguyên nhân sau:

- Hết bộ nhớ (ZZ0000ZZ)
- Thiết bị đã rút phích cắm (ZZ0001ZZ)
- Điểm cuối bị đình trệ (ZZ0002ZZ)
- Quá nhiều lần chuyển ISO được xếp hàng đợi (ZZ0003ZZ)
- Quá nhiều khung ISO được yêu cầu (ZZ0004ZZ)
- Khoảng INT không hợp lệ (ZZ0005ZZ)
- Nhiều hơn một gói cho INT (ZZ0006ZZ)

Sau khi gửi, ZZ0000ZZ là ZZ0001ZZ; tuy nhiên, bạn nên
không bao giờ nhìn vào giá trị đó ngoại trừ cuộc gọi lại hoàn thành của bạn.

Đối với các điểm cuối đẳng thời gian, trình xử lý hoàn thành của bạn phải (gửi lại)
URB đến cùng điểm cuối với cờ ZZ0000ZZ, sử dụng
đa bộ đệm, để truyền phát ISO liền mạch.


Làm cách nào để hủy URB đang chạy?
=====================================

Có hai cách để hủy URB bạn đã gửi nhưng chưa có
đã được trả lại cho tài xế của bạn chưa.  Để hủy không đồng bộ, hãy gọi
ZZ0000ZZ::

int usb_unlink_urb(struct urb *urb)

Nó loại bỏ urb khỏi danh sách nội bộ và giải phóng tất cả các
Bộ mô tả CTNH. Trạng thái được thay đổi để phản ánh việc hủy liên kết.  Lưu ý
rằng URB thường sẽ không hoàn thành khi ZZ0000ZZ
trả lại; bạn vẫn phải đợi trình xử lý hoàn thành được gọi.

Để hủy đồng bộ URB, hãy gọi ZZ0000ZZ::

void usb_kill_urb(struct urb *urb)

Nó thực hiện mọi thứ mà ZZ0000ZZ làm và ngoài ra nó còn chờ
cho đến sau khi URB được trả về và trình xử lý hoàn thành
đã kết thúc.  Nó cũng đánh dấu URB là tạm thời không sử dụng được, vì vậy
rằng nếu trình xử lý hoàn thành hoặc bất kỳ ai khác cố gắng gửi lại nó
họ sẽ gặp lỗi ZZ0002ZZ.  Vì vậy bạn có thể chắc chắn rằng khi
ZZ0001ZZ quay trở lại, URB hoàn toàn không hoạt động.

Có một vấn đề suốt đời cần xem xét.  URB có thể hoàn thành bất cứ lúc nào
thời gian và trình xử lý hoàn thành có thể giải phóng URB.  Nếu điều này xảy ra
trong khi ZZ0000ZZ hoặc ZZ0001ZZ đang chạy, nó sẽ
gây ra vi phạm truy cập bộ nhớ.  Người lái xe có trách nhiệm tránh việc này,
điều này thường có nghĩa là sẽ cần một số loại khóa để ngăn URB
khỏi bị giải phóng trong khi nó vẫn đang được sử dụng.

Mặt khác, vì usb_unlink_urb cuối cùng có thể gọi
trình xử lý hoàn thành, trình xử lý không được lấy bất kỳ khóa nào được giữ
khi usb_unlink_urb được gọi.  Giải pháp chung cho vấn đề này
là tăng số lượng tham chiếu của URB trong khi giữ khóa, sau đó
bỏ khóa và gọi usb_unlink_urb hoặc usb_kill_urb, sau đó
giảm số lượng tham chiếu của URB.  Bạn tăng tham chiếu
đếm bằng cách gọi :c:func`usb_get_urb`::

cấu trúc urb *usb_get_urb(struct urb *urb)

(bỏ qua giá trị trả về; nó giống với đối số) và
giảm số lượng tham chiếu bằng cách gọi ZZ0000ZZ.  Tất nhiên,
điều này không cần thiết nếu không có nguy cơ URB được giải phóng
bởi trình xử lý hoàn thành.


Còn trình xử lý hoàn thành thì sao?
==================================

Trình xử lý có loại sau::

khoảng trống typedef (ZZ0000ZZ)

Tức là, nó nhận được URB đã gây ra lệnh gọi hoàn thành. Trong quá trình hoàn thiện
xử lý, bạn nên xem ZZ0000ZZ để phát hiện bất kỳ lỗi USB nào.
Vì tham số ngữ cảnh được bao gồm trong URB, bạn có thể chuyển
thông tin cho người xử lý hoàn thành.

Lưu ý rằng ngay cả khi có báo cáo lỗi (hoặc hủy liên kết), dữ liệu có thể đã bị
được chuyển giao.  Đó là vì quá trình truyền USB được đóng gói; nó có thể mất
mười sáu gói để chuyển bộ đệm 1KByte của bạn và mười gói trong số đó có thể
đã chuyển thành công trước khi hoàn thành được gọi.


.. warning::

   NEVER SLEEP IN A COMPLETION HANDLER.

   These are often called in atomic context.

Trong kernel hiện tại, trình xử lý hoàn thành chạy với các ngắt cục bộ
bị vô hiệu hóa, nhưng trong tương lai điều này sẽ được thay đổi, vì vậy đừng cho rằng
IRQ cục bộ luôn bị tắt bên trong trình xử lý hoàn thành.

Làm cách nào để thực hiện chuyển khoản đẳng thời (ISO)?
======================================

Ngoài các trường có trong chuyển khoản số lượng lớn, đối với ISO, bạn cũng
phải đặt ZZ0001ZZ để cho biết tần suất thực hiện chuyển khoản; đó là
thường là một khung hình cho mỗi khung hình (mỗi khung hình nhỏ dành cho các thiết bị tốc độ cao).
Khoảng thực tế được sử dụng sẽ là lũy thừa của hai và không lớn hơn khoảng
bạn chỉ định. Bạn có thể sử dụng macro ZZ0000ZZ để điền
hầu hết các trường chuyển ISO.

Đối với chuyển khoản ISO, bạn cũng phải điền vào ZZ0000ZZ
cấu trúc, được phân bổ ở cuối URB bởi ZZ0001ZZ, cho
mỗi gói bạn muốn lên lịch.

Lệnh gọi ZZ0000ZZ sửa đổi ZZ0001ZZ thành ZZ0001ZZ đã triển khai
giá trị khoảng nhỏ hơn hoặc bằng giá trị khoảng được yêu cầu.  Nếu
Lập lịch ZZ0002ZZ được sử dụng, ZZ0003ZZ cũng được cập nhật.

Đối với mỗi mục, bạn phải chỉ định độ lệch dữ liệu cho khung này (cơ sở là
transfer_buffer) và độ dài bạn muốn viết/mong đọc.
Sau khi hoàn thành, Fact_length chứa độ dài thực tế được truyền và
trạng thái chứa trạng thái kết quả cho việc truyền ISO cho khung này.
Nó được phép chỉ định độ dài khác nhau từ khung này sang khung khác (ví dụ: đối với
đồng bộ hóa âm thanh/tốc độ truyền thích ứng). Bạn cũng có thể sử dụng chiều dài
0 để bỏ qua một hoặc nhiều khung hình (sọc).

Để lập lịch, bạn có thể chọn khung bắt đầu của riêng mình hoặc ZZ0000ZZ. Như
đã giải thích trước đó, nếu bạn luôn giữ ít nhất một URB ở hàng đợi và
quá trình hoàn tất tiếp tục gửi (lại) URB sau này, bạn sẽ nhận được phát trực tuyến ISO mượt mà
(nếu việc sử dụng băng thông usb cho phép).

Nếu bạn chỉ định khung bắt đầu của riêng mình, hãy đảm bảo rằng đó là một vài khung trước
của khung hiện tại.  Bạn có thể muốn mẫu này nếu bạn đang đồng bộ hóa
Dữ liệu ISO với một số luồng sự kiện khác.


Làm cách nào để bắt đầu chuyển khoản gián đoạn (INT)?
=======================================

Truyền gián đoạn, như truyền đẳng thời, là định kỳ và xảy ra
trong các khoảng là lũy thừa của hai đơn vị (1, 2, 4, v.v.).  Đơn vị là khung
dành cho thiết bị tốc độ đầy đủ và tốc độ thấp cũng như microframe dành cho thiết bị tốc độ cao.
Bạn có thể sử dụng macro ZZ0000ZZ để điền vào các trường chuyển INT.

Lệnh gọi ZZ0000ZZ sửa đổi ZZ0001ZZ thành ZZ0001ZZ đã triển khai
giá trị khoảng nhỏ hơn hoặc bằng giá trị khoảng được yêu cầu.

Trong Linux 2.6, không giống như các phiên bản trước, URB ngắt không tự động
khởi động lại khi chúng hoàn thành.  Chúng kết thúc khi trình xử lý hoàn thành được
được gọi, giống như các URB khác.  Nếu bạn muốn khởi động lại URB ngắt,
trình xử lý hoàn thành của bạn phải gửi lại nó.
S
