.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/bulk-streams.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Luồng số lượng lớn USB
~~~~~~~~~~~~~~~~

Lý lịch
==========

Các luồng điểm cuối hàng loạt đã được thêm vào đặc tả USB 3.0.  Các luồng cho phép một
trình điều khiển thiết bị làm quá tải một điểm cuối số lượng lớn để có thể thực hiện nhiều lần truyền
xếp hàng cùng một lúc.

Các luồng được xác định trong phần 4.4.6.4 và 8.12.1.4 của Universal Serial Bus
Thông số kỹ thuật 3.0 tại ZZ0000ZZ USB được đính kèm SCSI
Giao thức sử dụng các luồng để xếp hàng nhiều lệnh SCSI có thể được tìm thấy trên
trang web T10 (ZZ0001ZZ


Ý nghĩa phía thiết bị
========================

Khi bộ đệm đã được xếp vào hàng đợi vào vòng truyền phát, thiết bị sẽ được thông báo (thông qua
cơ chế ngoài băng tần trên một điểm cuối khác) dữ liệu đó đã sẵn sàng cho luồng đó
ID.  Sau đó, thiết bị sẽ thông báo cho máy chủ biết "luồng" nào nó muốn bắt đầu.  chủ nhà
cũng có thể bắt đầu truyền trên luồng mà không cần thiết bị yêu cầu, nhưng
thiết bị có thể từ chối việc chuyển giao đó.  Thiết bị có thể chuyển đổi giữa các luồng bất cứ lúc nào
thời gian.


Ý nghĩa của trình điều khiển
===================

::

int usb_alloc_streams(struct usb_interface *giao diện,
		struct usb_host_endpoint **eps, unsigned int num_eps,
		unsigned int num_streams, gfp_t mem_flags);

Trình điều khiển thiết bị sẽ gọi API này để yêu cầu trình điều khiển bộ điều khiển máy chủ
phân bổ bộ nhớ để trình điều khiển có thể sử dụng tối đa num_stream ID luồng.  Họ phải
chuyển một mảng usb_host_endpoint cần được thiết lập với luồng tương tự
ID.  Điều này nhằm đảm bảo rằng trình điều khiển UASP sẽ có thể sử dụng cùng một luồng
ID cho các điểm cuối IN và OUT số lượng lớn được sử dụng trong chuỗi lệnh hai chiều.

Giá trị trả về là tình trạng lỗi (nếu một trong các điểm cuối không hỗ trợ
luồng hoặc trình điều khiển xHCI hết bộ nhớ) hoặc số lượng luồng
bộ điều khiển máy chủ được phân bổ cho điểm cuối này.  Phần cứng bộ điều khiển máy chủ xHCI
khai báo số lượng ID luồng mà nó có thể hỗ trợ và mỗi điểm cuối hàng loạt trên một
Thiết bị SuperSpeed sẽ cho biết nó có thể xử lý bao nhiêu ID luồng.  Vì vậy,
trình điều khiển sẽ có thể giải quyết việc được phân bổ ít ID luồng hơn chúng
được yêu cầu.

NOT có gọi hàm này không nếu bạn có URB được xếp hàng đợi cho bất kỳ điểm cuối nào
được chuyển vào dưới dạng đối số.  Không gọi hàm này để yêu cầu ít hơn hai
suối.

Trình điều khiển sẽ chỉ được phép gọi API này một lần cho cùng một điểm cuối
mà không cần gọi usb_free_streams().  Đây là sự đơn giản hóa cho máy chủ xHCI
trình điều khiển bộ điều khiển và có thể thay đổi trong tương lai.


Chọn ID luồng mới để sử dụng
=============================

Luồng ID 0 được bảo lưu và không được sử dụng để liên lạc với các thiết bị.  Nếu
usb_alloc_streams() trả về giá trị N, bạn có thể sử dụng luồng 1 mặc dù N.
Để xếp hàng URB cho một luồng cụ thể, hãy đặt giá trị urb->stream_id.  Nếu
điểm cuối không hỗ trợ luồng, lỗi sẽ được trả về.

Lưu ý rằng API mới để chọn ID luồng tiếp theo sẽ phải được thêm nếu xHCI
trình điều khiển hỗ trợ ID luồng thứ cấp.


Dọn dẹp
========

Nếu trình điều khiển muốn ngừng sử dụng luồng để liên lạc với thiết bị, nó sẽ
nên gọi::

void usb_free_streams(struct usb_interface *giao diện,
		struct usb_host_endpoint **eps, unsigned int num_eps,
		gfp_t mem_flags);

Tất cả ID luồng sẽ bị hủy phân bổ khi trình điều khiển giải phóng giao diện, để
đảm bảo rằng các trình điều khiển không hỗ trợ luồng sẽ có thể sử dụng điểm cuối.
