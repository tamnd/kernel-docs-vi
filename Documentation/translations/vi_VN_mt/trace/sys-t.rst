.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/sys-t.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
MIPI SyS-T trên STP
===================

Trình điều khiển giao thức MIPI SyS-T có thể được sử dụng với các thiết bị lớp STM để
tạo ra dòng dấu vết tiêu chuẩn hóa. Ngoài việc là một tiêu chuẩn, nó còn
cung cấp nhận dạng nguồn dấu vết tốt hơn và tương quan dấu thời gian.

Để sử dụng trình điều khiển giao thức MIPI SyS-T với thiết bị STM của bạn,
đầu tiên, bạn sẽ cần CONFIG_STM_PROTO_SYS_T.

Bây giờ, bạn có thể chọn trình điều khiển giao thức nào bạn muốn sử dụng khi tạo
chính sách cho thiết bị STM của bạn, bằng cách chỉ định chính sách đó trong tên chính sách:

# mkdir /config/stp-policy/dummy_stm.0:p_sys-t.my-policy/

Nói cách khác, định dạng tên chính sách được mở rộng như sau:

<device_name>:<protocol_name>.<policy_name>

Do đó, với Intel TH, nó có thể trông giống như "0-sth:p_sys-t.my-policy".

Nếu tên giao thức bị bỏ qua, lớp STM sẽ chọn bất kỳ tên nào
trình điều khiển giao thức đã được tải đầu tiên.

Bạn cũng có thể kiểm tra kỹ xem mọi thứ có hoạt động như mong đợi không bằng cách

# cat /config/stp-policy/dummy_stm.0:p_sys-t.my-policy/protocol
p_sys-t

Giờ đây, với trình điều khiển giao thức MIPI SyS-T, mỗi nút chính sách trong
configfs nhận được một vài thuộc tính bổ sung, xác định từng nguồn
các tham số cụ thể cho giao thức:

# mkdir /config/stp-policy/dummy_stm.0:p_sys-t.my-policy/default
# ls /config/stp-policy/dummy_stm.0:p_sys-t.my-policy/default
kênh
clocksync_interval
do_len
bậc thầy
ts_interval
uuid

Điều quan trọng nhất ở đây là "uuid", xác định UUID
sẽ được sử dụng để gắn thẻ tất cả dữ liệu đến từ nguồn này. Đó là
được tạo tự động khi một nút mới được tạo, nhưng có thể
rằng bạn muốn thay đổi nó.

do_len bật/tắt trường "độ dài tải trọng" bổ sung trong
Tiêu đề tin nhắn MIPI SyS-T. Mặc định nó tắt như STP rồi
đánh dấu ranh giới tin nhắn.

ts_interval và clocksync_interval xác định thời gian tính bằng mili giây
có thể vượt qua trước khi chúng tôi cần bao gồm một giao thức (không phải vận chuyển, hay còn gọi là STP)
dấu thời gian trong tiêu đề thư hoặc gửi gói CLOCKSYNC tương ứng.

Xem Tài liệu/ABI/testing/configfs-stp-policy-p_sys-t để biết thêm
chi tiết.

* [1] ZZ0000ZZ