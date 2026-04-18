.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/strparser.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình phân tích cú pháp luồng (strparser)
=========================

Giới thiệu
============

Trình phân tích cú pháp luồng (strparser) là một tiện ích phân tích các thông điệp của một
Giao thức lớp ứng dụng chạy trên luồng dữ liệu. Dòng chảy
bộ phân tích cú pháp hoạt động cùng với lớp trên trong kernel để cung cấp
hỗ trợ kernel cho các thông báo lớp ứng dụng. Ví dụ, hạt nhân
Bộ ghép kênh kết nối (KCM) sử dụng Trình phân tích cú pháp luồng để phân tích thông báo
bằng chương trình BPF.

Trình phân tích cú pháp hoạt động ở một trong hai chế độ: nhận cuộc gọi lại hoặc chung
chế độ.

Trong chế độ nhận cuộc gọi lại, strparser được gọi từ data_ready
gọi lại ổ cắm TCP. Tin nhắn được phân tích cú pháp và gửi như cũ
nhận được trên ổ cắm.

Ở chế độ chung, một chuỗi skbs được đưa tới strparser từ một
nguồn bên ngoài. Tin nhắn được phân tích cú pháp và gửi theo trình tự
đã xử lý. Chế độ này cho phép strparser được áp dụng tùy ý
các luồng dữ liệu.

Giao diện
=========

API bao gồm cấu trúc ngữ cảnh, tập hợp các lệnh gọi lại, tiện ích
và hàm data_ready để nhận chế độ gọi lại. các
các cuộc gọi lại bao gồm hàm pars_msg được gọi để thực hiện
phân tích cú pháp (ví dụ: phân tích cú pháp BPF trong trường hợp KCM) và hàm rcv_msg
được gọi khi một tin nhắn đầy đủ đã được hoàn thành.

Chức năng
=========

     ::

strp_init(struct strparser *strp, struct sock *sk,
		const struct strp_callbacks *cb)

Được gọi để khởi tạo trình phân tích cú pháp luồng. strp là một cấu trúc kiểu
     strparser được phân bổ bởi lớp trên. sk là TCP
     ổ cắm được liên kết với trình phân tích cú pháp luồng để sử dụng với nhận
     chế độ gọi lại; ở chế độ chung, giá trị này được đặt thành NULL. Cuộc gọi lại
     được gọi bởi trình phân tích cú pháp luồng (các lệnh gọi lại được liệt kê bên dưới).

     ::

void strp_pause(struct strparser *strp)

Tạm dừng trình phân tích cú pháp luồng. Phân tích tin nhắn bị đình chỉ
     và không có tin nhắn mới nào được gửi đến lớp trên.

     ::

void strp_unpause(struct strparser *strp)

Bỏ tạm dừng trình phân tích cú pháp luồng bị tạm dừng.

     ::

void strp_stop(struct strparser *strp);

strp_stop được gọi để dừng hoàn toàn các hoạt động của trình phân tích cú pháp luồng.
     Điều này được gọi nội bộ khi trình phân tích luồng gặp phải một
     lỗi và nó được gọi từ lớp trên để dừng phân tích cú pháp
     hoạt động.

     ::

void strp_done(struct strparser *strp);

strp_done được gọi để giải phóng mọi tài nguyên do luồng nắm giữ
     phiên bản trình phân tích cú pháp. Điều này phải được gọi sau bộ xử lý luồng
     đã bị dừng lại.

     ::

int strp_process(struct strparser *strp, struct sk_buff *orig_skb,
			 unsigned int orig_offset, size_t orig_len,
			 size_t max_msg_size, lâu rồi)

strp_process được gọi ở chế độ chung để trình phân tích cú pháp luồng
    phân tích một sk_buff. Số byte được xử lý hoặc số âm
    số lỗi được trả về. Lưu ý rằng strp_process không
    tiêu thụ sk_buff. max_msg_size là kích thước tối đa của luồng
    trình phân tích cú pháp sẽ phân tích cú pháp. timeo là thời gian chờ để hoàn thành tin nhắn.

    ::

void strp_data_ready(struct strparser *strp);

Lớp trên gọi strp_tcp_data_ready khi dữ liệu đã sẵn sàng
    ổ cắm phía dưới để strparser xử lý. Điều này nên được gọi
    từ lệnh gọi lại data_ready được đặt trên ổ cắm. Lưu ý rằng
    kích thước tin nhắn tối đa là giới hạn của ổ cắm nhận
    thời gian chờ của bộ đệm và tin nhắn là thời gian chờ nhận của ổ cắm.

    ::

void strp_check_rcv(struct strparser *strp);

strp_check_rcv được gọi để kiểm tra tin nhắn mới trên ổ cắm.
    Điều này thường được gọi khi khởi tạo trình phân tích cú pháp luồng
    dụ hoặc sau strp_unpause.

Cuộc gọi lại
=========

Có bảy cuộc gọi lại:

    ::

int (*parse_msg)(struct strparser *strp, struct sk_buff *skb);

Parse_msg được gọi để xác định độ dài của tin nhắn tiếp theo
    trong luồng. Lớp trên phải thực hiện chức năng này. Nó
    nên phân tích cú pháp sk_buff có chứa các tiêu đề cho
    thông báo lớp ứng dụng tiếp theo trong luồng.

Skb->cb trong skb đầu vào là một strp_msg cấu trúc. Chỉ
    trường offset có liên quan trong Parse_msg và đưa ra giá trị offset
    nơi tin nhắn bắt đầu trong skb.

Các giá trị trả về của hàm này là:

==========================================================================
    >0 cho biết độ dài của tin nhắn được phân tích cú pháp thành công
    0 cho biết phải nhận nhiều dữ liệu hơn để phân tích tin nhắn
    -ESTRPIPE tin nhắn hiện tại không được xử lý bởi
		 kernel, trả lại quyền kiểm soát socket cho không gian người dùng
		 có thể tiếp tục đọc tin nhắn
    other < 0 Lỗi phân tích cú pháp, trả lại quyền kiểm soát cho không gian người dùng
		 giả sử rằng đồng bộ hóa bị mất và luồng
		 không thể phục hồi được (ứng dụng dự kiến ​​sẽ đóng ổ cắm TCP)
    ==========================================================================

Trong trường hợp trả về lỗi (giá trị trả về nhỏ hơn
    zero) và trình phân tích cú pháp đang ở chế độ nhận gọi lại, sau đó nó sẽ đặt
    lỗi trên ổ cắm TCP và đánh thức nó. Nếu phân tích cú pháp_msg trả về
    -ESTRPIPE và trình phân tích cú pháp luồng trước đó đã đọc một số byte cho
    thông báo hiện tại thì lỗi được đặt trên ổ cắm kèm theo là
    ENODATA vì luồng không thể phục hồi được trong trường hợp đó.

    ::

khoảng trống (*lock)(struct strparser *strp)

Lệnh gọi lại khóa được gọi để khóa cấu trúc strp khi
    strparser đang thực hiện một thao tác không đồng bộ (chẳng hạn như
    xử lý thời gian chờ). Ở chế độ nhận cuộc gọi lại, mặc định
    chức năng là lock_sock cho ổ cắm liên quan. Nói chung
    chế độ gọi lại phải được đặt phù hợp.

    ::

khoảng trống (*unlock)(struct strparser *strp)

Cuộc gọi lại mở khóa được gọi để giải phóng khóa thu được
    bằng cách gọi lại khóa. Ở chế độ nhận cuộc gọi lại, mặc định
    chức năng là Release_sock cho ổ cắm liên quan. Nói chung
    chế độ gọi lại phải được đặt phù hợp.

    ::

khoảng trống (*rcv_msg)(struct strparser *strp, struct sk_buff *skb);

rcv_msg được gọi khi nhận được tin nhắn đầy đủ và
    đang được xếp hàng. Callee phải tiêu thụ sk_buff; nó có thể
    gọi strp_pause để ngăn chặn bất kỳ tin nhắn nào tiếp theo
    nhận được trong rcv_msg (xem strp_pause ở trên). Cuộc gọi lại này
    phải được thiết lập.

Skb->cb trong skb đầu vào là một strp_msg cấu trúc. Cái này
    struct chứa hai trường: offset và full_len. Bù đắp là
    nơi thông báo bắt đầu trong skb và full_len là
    độ dài của tin nhắn. skb->len - offset có thể lớn hơn
    hơn full_len vì strparser không cắt bớt skb.

    ::

int (*read_sock)(struct strparser *strp, read_descriptor_t *desc,
                     sk_read_actor_t recv_actor);

Lệnh gọi lại read_sock được sử dụng bởi strparser thay vì
    sock->ops->read_sock, nếu được cung cấp.
    ::

int (*read_sock_done)(struct strparser *strp, int err);

read_sock_done được gọi khi trình phân tích cú pháp luồng đọc xong
     ổ cắm TCP ở chế độ nhận cuộc gọi lại. Trình phân tích cú pháp luồng có thể
     đọc nhiều tin nhắn trong một vòng lặp và chức năng này cho phép dọn dẹp
     xảy ra khi thoát khỏi vòng lặp. Nếu cuộc gọi lại không được đặt (NULL
     trong strp_init) một hàm mặc định được sử dụng.

     ::

khoảng trống (*abort_parser)(struct strparser *strp, int err);

Hàm này được gọi khi trình phân tích luồng gặp lỗi
     trong việc phân tích cú pháp. Hàm mặc định dừng trình phân tích cú pháp luồng và
     đặt lỗi trong ổ cắm nếu trình phân tích cú pháp đang nhận cuộc gọi lại
     chế độ. Chức năng mặc định có thể được thay đổi bằng cách đặt lệnh gọi lại
     đến không phải NULL trong strp_init.

Thống kê
==========

Các bộ đếm khác nhau được lưu giữ cho mỗi phiên bản trình phân tích cú pháp luồng. Đây là trong
cấu trúc strp_stats. strp_aggr_stats là một cấu trúc tiện lợi cho
tích lũy số liệu thống kê cho nhiều phiên bản phân tích cú pháp luồng.
save_strp_stats và tổng hợp_strp_stats là các hàm trợ giúp để lưu
và thống kê tổng hợp.

Giới hạn tập hợp tin nhắn
=======================

Trình phân tích cú pháp luồng cung cấp các cơ chế để hạn chế tài nguyên được tiêu thụ bởi
tập hợp tin nhắn.

Bộ hẹn giờ được đặt khi quá trình lắp ráp bắt đầu cho một tin nhắn mới. Trong nhận
chế độ gọi lại, thời gian chờ của tin nhắn được lấy từ rcvtime cho
ổ cắm TCP liên quan. Ở chế độ chung, thời gian chờ được chuyển thành
đối số trong strp_process. Nếu bộ hẹn giờ kích hoạt trước khi quá trình lắp ráp hoàn tất
trình phân tích cú pháp luồng bị hủy bỏ và lỗi ETIMEDOUT được đặt trên TCP
socket nếu ở chế độ nhận cuộc gọi lại.

Trong chế độ nhận cuộc gọi lại, độ dài tin nhắn được giới hạn ở thời điểm nhận
kích thước bộ đệm của ổ cắm TCP được liên kết. Nếu độ dài được trả về bởi
Parse_msg lớn hơn kích thước bộ đệm ổ cắm thì trình phân tích cú pháp luồng
bị hủy bỏ do lỗi EMSGSIZE được đặt trên ổ cắm TCP. Lưu ý rằng điều này
tạo kích thước tối đa của skbuff nhận cho ổ cắm có luồng
trình phân tích cú pháp thành 2*sk_rcvbuf của ổ cắm TCP.

Ở chế độ chung, giới hạn độ dài tin nhắn được chuyển vào dưới dạng đối số
tới strp_process.

Tác giả
======

Tom Herbert (tom@quantonium.net)