.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/w1/w1-netlink.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Giao thức truyền thông không gian người dùng qua trình kết nối
===============================================

Các loại tin nhắn
=============

Có ba loại tin nhắn giữa lõi w1 và không gian người dùng:

1. Sự kiện. Chúng được tạo ra mỗi khi có thiết bị chính hoặc thiết bị phụ mới
   được tìm thấy do tìm kiếm tự động hoặc được yêu cầu.
2. Lệnh không gian người dùng.
3. Trả lời các lệnh của người dùng.


Giao thức
========

::

[struct cn_msg] - tiêu đề trình kết nối.
	Trường độ dài của nó bằng kích thước của dữ liệu đính kèm
  [struct w1_netlink_msg] - tiêu đề liên kết mạng w1.
	__u8 loại - loại tin nhắn.
			W1_LIST_MASTERS
				liệt kê các bậc thầy xe buýt hiện tại
			W1_SLAVE_ADD/W1_SLAVE_REMOVE
				sự kiện thêm/xóa nô lệ
			W1_MASTER_ADD/W1_MASTER_REMOVE
				sự kiện thêm/xóa chính
			W1_MASTER_CMD
				lệnh không gian người dùng cho bus master
				thiết bị (tìm kiếm/tìm kiếm báo động)
			W1_SLAVE_CMD
				lệnh không gian người dùng cho thiết bị nô lệ
				(đọc/ghi/chạm)
	Trạng thái __u8 - chỉ báo lỗi từ kernel
	__u16 len - kích thước của dữ liệu được đính kèm với dữ liệu tiêu đề này
	công đoàn {
		__u8 id[8];			 - id thiết bị duy nhất nô lệ
		cấu trúc w1_mst {
			__u32 id;	 - id của chủ nhân
			__u32 độ phân giải;	 - dành riêng
		} mst;
	} nhận dạng;

[struct w1_netlink_cmd] - lệnh cho thiết bị chính hoặc phụ đã cho.
	__u8 cmd - lệnh opcode.
			W1_CMD_READ - lệnh đọc
			W1_CMD_WRITE - ghi lệnh
			W1_CMD_SEARCH - lệnh tìm kiếm
			W1_CMD_ALARM_SEARCH - lệnh tìm kiếm cảnh báo
			W1_CMD_TOUCH - lệnh chạm
				(ghi và lấy mẫu dữ liệu trở lại không gian người dùng)
			W1_CMD_RESET - gửi thiết lập lại bus
			W1_CMD_SLAVE_ADD - thêm nô lệ vào danh sách kernel
			W1_CMD_SLAVE_REMOVE - xóa nô lệ khỏi danh sách kernel
			W1_CMD_LIST_SLAVES - lấy danh sách nô lệ từ kernel
	__u8 res - dành riêng
	__u16 len - độ dài dữ liệu cho lệnh này
		Đối với lệnh đọc, dữ liệu phải được phân bổ giống như lệnh ghi
	__u8 data[0] - dữ liệu cho lệnh này


Mỗi thông báo trình kết nối có thể bao gồm một hoặc nhiều w1_netlink_msg với
không có hoặc nhiều tin nhắn w1_netlink_cmd được đính kèm.

Đối với thông báo sự kiện, không có cấu trúc nhúng w1_netlink_cmd,
chỉ tiêu đề trình kết nối và cấu trúc w1_netlink_msg với trường "len"
bằng 0 và loại được điền (một trong các loại sự kiện) và id:
8 byte id duy nhất nô lệ theo thứ tự máy chủ,
hoặc id chủ, được gán cho thiết bị chính bus
khi nó được thêm vào lõi w1.

Hiện tại các câu trả lời cho lệnh vùng người dùng chỉ được tạo để đọc
yêu cầu lệnh. Một câu trả lời được tạo chính xác cho một w1_netlink_cmd
đọc yêu cầu. Các câu trả lời không được kết hợp khi gửi - tức là trả lời thông thường
tin nhắn trông giống như sau::

[cn_msg][w1_netlink_msg][w1_netlink_cmd]
  cn_msg.len = sizeof(struct w1_netlink_msg) +
	     sizeof(struct w1_netlink_cmd) +
	     cmd->len;
  w1_netlink_msg.len = sizeof(struct w1_netlink_cmd) + cmd->len;
  w1_netlink_cmd.len = cmd->len;

Trả lời W1_LIST_MASTERS sẽ gửi tin nhắn trở lại không gian người dùng
sẽ chứa danh sách tất cả các id chính đã đăng ký sau đây
định dạng::

cn_msg (CN_W1_IDX.CN_W1_VAL là id, len bằng sizeof(struct
	w1_netlink_msg) cộng với số master nhân với 4)
	w1_netlink_msg (loại: W1_LIST_MASTERS, len bằng
		số master nhân với 4 (cỡ u32))
	id0 ... idN

Mỗi tin nhắn có kích thước tối đa là 4k, vì vậy nếu số lượng thiết bị chính
vượt quá mức này, nó sẽ được chia thành nhiều tin nhắn.

Lệnh tìm kiếm và cảnh báo W1.

lời yêu cầu::

[cn_msg]
    [loại w1_netlink_msg = W1_MASTER_CMD
	id bằng id chính của bus để sử dụng cho việc tìm kiếm]
    [w1_netlink_cmd cmd = W1_CMD_SEARCH hoặc W1_CMD_ALARM_SEARCH]

hồi đáp::

[cn_msg, ack = 1 và tăng dần, 0 nghĩa là tin nhắn cuối cùng,
	seq bằng với yêu cầu seq]
  [loại w1_netlink_msg = W1_MASTER_CMD]
  [w1_netlink_cmd cmd = W1_CMD_SEARCH hoặc W1_CMD_ALARM_SEARCH
	len bằng số ID nhân với 8]
  [64bit-id0 ... 64bit-idN]

Độ dài trong mỗi tiêu đề tương ứng với kích thước của dữ liệu đằng sau nó, vì vậy
w1_netlink_cmd->len = N * 8; trong đó N là số ID trong tin nhắn này.
Có thể bằng không.

::

w1_netlink_msg->len = sizeof(struct w1_netlink_cmd) + N * 8;
  cn_msg->len = sizeof(struct w1_netlink_msg) +
	      sizeof(struct w1_netlink_cmd) +
	      N*8;

Lệnh đặt lại W1::

[cn_msg]
    [loại w1_netlink_msg = W1_MASTER_CMD
	id bằng id chính của bus để sử dụng cho việc tìm kiếm]
    [w1_netlink_cmd cmd = W1_CMD_RESET]


Trả lời trạng thái lệnh
======================

Mỗi lệnh (root, master hoặc Slave có hoặc không có w1_netlink_cmd
Structure) sẽ bị lõi w1 'ack'. Định dạng của câu trả lời giống nhau
dưới dạng thông báo yêu cầu ngoại trừ các tham số độ dài không tính đến dữ liệu
do người dùng yêu cầu, tức là các yêu cầu đọc/ghi/chạm IO sẽ không chứa
dữ liệu, vì vậy w1_netlink_cmd.len sẽ là 0, w1_netlink_msg.len sẽ có kích thước
của cấu trúc w1_netlink_cmd và cn_msg.len sẽ bằng tổng
của sizeof(struct w1_netlink_msg) và sizeof(struct w1_netlink_cmd).
Nếu trả lời được tạo ra cho lệnh chính hoặc lệnh gốc (không có
w1_netlink_cmd được đính kèm), thư trả lời sẽ chỉ chứa cn_msg và w1_netlink_msg
các cấu trúc.

Trường w1_netlink_msg.status sẽ mang giá trị lỗi dương
(ví dụ EINVAL) hoặc 0 trong trường hợp thành công.

Tất cả các trường khác trong mọi cấu trúc sẽ phản ánh các tham số tương tự trong
tin nhắn yêu cầu (ngoại trừ độ dài như mô tả ở trên).

Trả lời trạng thái được tạo cho mọi w1_netlink_cmd được nhúng trong
w1_netlink_msg, nếu không có cấu trúc w1_netlink_cmd,
câu trả lời sẽ được tạo cho w1_netlink_msg.

Tất cả các cấu trúc lệnh w1_netlink_cmd được xử lý trong mọi w1_netlink_msg,
ngay cả khi có lỗi, chỉ có độ dài không khớp sẽ làm gián đoạn quá trình xử lý tin nhắn.


Các bước thao tác trong lõi w1 khi nhận được lệnh mới
=======================================================

Khi nhận được tin nhắn mới (w1_netlink_msg), lõi w1 sẽ phát hiện xem nó có đúng không
yêu cầu chính hoặc phụ, theo trường w1_netlink_msg.type.
Sau đó, thiết bị chính hoặc thiết bị phụ sẽ được tìm kiếm.
Khi tìm thấy, thiết bị chính (được yêu cầu hoặc thiết bị trên thiết bị phụ)
được tìm thấy) đã bị khóa. Nếu lệnh nô lệ được yêu cầu, hãy đặt lại/chọn
thủ tục được bắt đầu để chọn thiết bị nhất định.

Sau đó, tất cả các yêu cầu trong hoạt động w1_netlink_msg sẽ được thực hiện lần lượt.
Nếu lệnh yêu cầu trả lời (như lệnh đọc), nó sẽ được gửi khi hoàn thành lệnh.

Khi tất cả các lệnh (w1_netlink_cmd) được xử lý, thiết bị chính sẽ được mở khóa
và quá trình xử lý tiêu đề w1_netlink_msg tiếp theo bắt đầu.


Connector [1] tài liệu cụ thể
====================================

Mỗi thông báo trình kết nối bao gồm hai trường u32 làm "địa chỉ".
w1 sử dụng CN_W1_IDX và CN_W1_VAL được xác định trong tiêu đề include/linux/connector.h.
Mỗi tin nhắn cũng bao gồm số thứ tự và số xác nhận.
Số thứ tự cho các thông báo sự kiện là số thứ tự chính của bus thích hợp
tăng lên theo mỗi thông báo sự kiện được gửi "thông qua" chủ này.
Số thứ tự cho các yêu cầu vùng người dùng được thiết lập bởi ứng dụng vùng người dùng.
Số thứ tự để trả lời giống như trong yêu cầu và
số xác nhận được đặt thành seq+1.


Tài liệu bổ sung, ví dụ mã nguồn
==============================================

1. Tài liệu/driver-api/connector.rst
2. ZZ0000ZZ

Kho lưu trữ này bao gồm ứng dụng không gian người dùng w1d.c sử dụng
   lệnh đọc/ghi/tìm kiếm cho tất cả các thiết bị chính/phụ được tìm thấy trên bus.
