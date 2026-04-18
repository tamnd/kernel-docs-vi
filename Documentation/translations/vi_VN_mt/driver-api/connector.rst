.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/connector.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Đầu nối hạt nhân
==================

Trình kết nối hạt nhân - không gian người dùng dựa trên liên kết mạng mới <-> không gian hạt nhân dễ dàng
để sử dụng mô-đun truyền thông.

Trình điều khiển Connector giúp dễ dàng kết nối các tác nhân khác nhau bằng cách sử dụng một
mạng dựa trên netlink.  Người ta phải đăng ký một cuộc gọi lại và một mã định danh.
Khi trình điều khiển nhận được một thông báo liên kết mạng đặc biệt với địa chỉ thích hợp
định danh, cuộc gọi lại thích hợp sẽ được gọi.

Từ quan điểm không gian người dùng, nó khá đơn giản:

- ổ cắm();
	- ràng buộc();
	- gửi();
	- recv();

Nhưng nếu không gian hạt nhân muốn sử dụng toàn bộ sức mạnh của các kết nối như vậy thì
Người viết driver phải tạo socket đặc biệt, phải biết về struct sk_buff
xử lý, v.v... Trình điều khiển Connector cho phép bất kỳ tác nhân kernelspace nào sử dụng
mạng dựa trên netlink để liên lạc giữa các quá trình một cách đáng kể
cách dễ dàng hơn::

int cn_add_callback(const struct cb_id *id, char *name, void (ZZ0001ZZ, struct netlink_skb_parms *));
  void cn_netlink_send_mult(struct cn_msg *msg, u16 len, u32 portid, u32 __group, int gfp_mask);
  void cn_netlink_send(struct cn_msg *msg, u32 portid, u32 __group, int gfp_mask);

cấu trúc cb_id
  {
	__u32 idx;
	__u32 giá trị;
  };

idx và val là các mã định danh duy nhất phải được đăng ký trong
tiêu đề Connector.h để sử dụng trong kernel.  ZZ0000ZZ là một
hàm gọi lại sẽ được gọi khi có tin nhắn có idx.val ở trên
được nhận bởi lõi kết nối.  Đối số cho hàm đó phải
được hủy đăng ký thành ZZ0001ZZ::

cấu trúc cn_msg
  {
	cấu trúc cb_id id;

__u32 seq;
	__u32 ACK;

__u16 len;	/* Độ dài của dữ liệu sau */
	__u16 lá cờ;
	__u8 dữ liệu[0];
  };

Giao diện kết nối
====================

 .. kernel-doc:: include/linux/connector.h

Lưu ý:
   Khi đăng ký người dùng gọi lại mới, lõi trình kết nối sẽ gán
   nhóm netlink cho người dùng bằng id.idx của nó.

Mô tả giao thức
====================

Khung hiện tại cung cấp một lớp vận chuyển với các tiêu đề cố định.  các
giao thức được đề xuất sử dụng tiêu đề như sau:

msg->seq và msg->ack được sử dụng để xác định phả hệ của thông báo.  Khi nào
ai đó gửi tin nhắn, họ sử dụng một chuỗi duy nhất cục bộ và ngẫu nhiên
xác nhận số  Số thứ tự có thể được sao chép vào
nlmsghdr->nlmsg_seq nữa.

Số thứ tự được tăng lên sau mỗi tin nhắn được gửi.

Nếu bạn mong đợi một phản hồi cho tin nhắn thì số thứ tự trong
tin nhắn MUST đã nhận giống như tin nhắn gốc và
xác nhận số MUST giống nhau + 1.

Nếu chúng tôi nhận được một tin nhắn và số thứ tự của nó không bằng số thứ tự thì chúng tôi
đang mong đợi thì đó là một tin nhắn mới.  Nếu chúng tôi nhận được một tin nhắn và
số thứ tự của nó giống với số chúng ta mong đợi, nhưng nó
xác nhận không bằng số thứ tự trong bản gốc
tin nhắn + 1 thì đó là tin nhắn mới.

Rõ ràng, tiêu đề giao thức chứa id ở trên.

Trình kết nối cho phép thông báo sự kiện theo dạng sau: kernel
trình điều khiển hoặc không gian người dùng có thể yêu cầu trình kết nối thông báo cho nó khi
id đã chọn sẽ được bật hoặc tắt (đã đăng ký hoặc chưa đăng ký
gọi lại).  Nó được thực hiện bằng cách gửi một lệnh đặc biệt tới trình kết nối
trình điều khiển (nó cũng tự đăng ký với id={-1, -1}).

Ví dụ về cách sử dụng này có thể được tìm thấy trong mô-đun cn_test.c
sử dụng trình kết nối để yêu cầu thông báo và gửi tin nhắn.

Độ tin cậy
===========

Bản thân Netlink không phải là một giao thức đáng tin cậy.  Điều đó có nghĩa là tin nhắn có thể
bị mất do áp lực bộ nhớ hoặc hàng đợi nhận của tiến trình bị tràn,
vì vậy người gọi được cảnh báo rằng nó phải được chuẩn bị.  Chính vì vậy cấu trúc
cn_msg [tiêu đề tin nhắn của trình kết nối chính] chứa u32 seq và u32 ack
lĩnh vực.

Sử dụng không gian người dùng
===============

2.6.14 có triển khai ổ cắm liên kết mạng mới, theo mặc định thì không
cho phép mọi người gửi dữ liệu đến các nhóm liên kết mạng khác 1.
Vì vậy, nếu bạn muốn sử dụng ổ cắm netlink (ví dụ: sử dụng trình kết nối)
với số nhóm khác, ứng dụng không gian người dùng phải đăng ký
nhóm đó trước tiên.  Nó có thể đạt được bằng mã giả sau::

s = ổ cắm (PF_NETLINK, SOCK_DGRAM, NETLINK_CONNECTOR);

l_local.nl_family = AF_NETLINK;
  l_local.nl_groups = 12345;
  l_local.nl_pid = 0;

if (bind(s, (struct sockaddr *)&l_local, sizeof(struct sockaddr_nl)) == -1) {
	perror("liên kết");
	đóng (các);
	trả về -1;
  }

{
	int on = l_local.nl_groups;
	setsockopt(s, 270, 1, &on, sizeof(on));
  }

Trong đó 270 ở trên là SOL_NETLINK và 1 là ổ cắm NETLINK_ADD_MEMBERSHIP
tùy chọn.  Để hủy đăng ký phát đa hướng, người ta nên gọi ổ cắm ở trên
tùy chọn với tham số NETLINK_DROP_MEMBERSHIP được xác định là 0.

2.6.14 mã netlink chỉ cho phép chọn nhóm nhỏ hơn hoặc bằng
số nhóm tối đa, được sử dụng tại thời điểm netlink_kernel_create().
Trong trường hợp đầu nối thì nó là CN_NETLINK_USERS + 0xf, vì vậy nếu bạn muốn sử dụng
số nhóm 12345, bạn phải tăng CN_NETLINK_USERS lên số đó.
Các số 0xf bổ sung được phân bổ để người dùng không có trong kernel sử dụng.

Do hạn chế này, nhóm 0xffffffff hiện không hoạt động, vì vậy người ta có thể
không sử dụng thông báo nhóm của trình kết nối thêm/xóa, nhưng theo như tôi biết,
chỉ có mô-đun thử nghiệm cn_test.c mới sử dụng nó.

Một số công việc trong lĩnh vực liên kết mạng vẫn đang được thực hiện nên mọi thứ có thể được thay đổi trong
2.6.15 khung thời gian, nếu điều đó xảy ra, tài liệu sẽ được cập nhật về điều đó
hạt nhân.

Mẫu mã
============

Có thể tìm thấy mã mẫu cho mô-đun thử nghiệm đầu nối và không gian người dùng
trong mẫu/đầu nối/. Để tạo mã này, hãy bật CONFIG_CONNECTOR
và CONFIG_SAMPLES.