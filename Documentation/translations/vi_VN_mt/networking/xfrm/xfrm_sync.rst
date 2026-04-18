.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/xfrm/xfrm_sync.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Đồng bộ hóa XFRM
================

Hoạt động của các bản vá đồng bộ dựa trên các bản vá ban đầu từ
Krisztian <hidden@balabit.hu> và những người khác và các bản vá bổ sung
từ Jamal <hadi@cyberus.ca>.

Mục tiêu cuối cùng của việc đồng bộ hóa là có thể chèn thuộc tính + tạo
các sự kiện để SA có thể được di chuyển an toàn từ máy này sang máy khác
nhằm mục đích HA.
Ý tưởng là đồng bộ hóa SA để máy tiếp quản có thể thực hiện
việc xử lý SA chính xác nhất có thể nếu nó có quyền truy cập vào nó.

Chúng tôi đã có khả năng tạo các sự kiện thêm/xóa/cập nhật SA.
Các bản vá này bổ sung khả năng đồng bộ hóa và có byte trọn đời chính xác (để
đảm bảo phân rã SA thích hợp) và bộ đếm phát lại để tránh các cuộc tấn công phát lại
với tổn thất tối thiểu tại thời điểm chuyển đổi dự phòng.
Bằng cách này, bản sao lưu luôn được cập nhật chặt chẽ như một thành viên tích cực.

Bởi vì các mục trên thay đổi theo mỗi gói mà SA nhận được,
có thể có rất nhiều sự kiện được tạo ra.
Vì lý do này, chúng tôi cũng thêm một thuật toán giống nagle để hạn chế
các sự kiện. tức là chúng ta sẽ đặt ra các ngưỡng để nói "hãy để tôi
biết đã đạt đến ngưỡng trình tự phát lại hay đã trôi qua 10 giây"
Các ngưỡng này được đặt trên toàn hệ thống thông qua sysctls hoặc có thể được cập nhật
mỗi SA.

Các mục được xác định cần được đồng bộ là:
- bộ đếm byte trọn đời
lưu ý rằng: giới hạn thời gian trọn đời không quan trọng nếu bạn giả sử chuyển đổi dự phòng
máy được biết trước kể từ khi đếm ngược thời gian suy giảm
không bị điều khiển bởi sự đến của gói.
- trình tự phát lại cho cả trong và ngoài nước

1) Cấu trúc tin nhắn
--------------------

nlmsghdr:aevent_id:tùy chọn-TLV.

Các loại tin nhắn liên kết mạng là:

XFRM_MSG_NEWAE và XFRM_MSG_GETAE.

XFRM_MSG_GETAE không có TLV.

XFRM_MSG_NEWAE sẽ có ít nhất hai TLV (như
được thảo luận thêm dưới đây).

cấu trúc aevent_id trông giống như::

cấu trúc xfrm_aevent_id {
	     cấu trúc xfrm_usersa_id sa_id;
	     xfrm_address_t saddr;
	     __u32 cờ;
	     __u32 cần thiết;
   };

SA duy nhất được xác định bằng sự kết hợp của xfrm_usersa_id,
reqid và saddr.

cờ được sử dụng để chỉ ra những điều khác nhau. Điều có thể
cờ là::

XFRM_AE_RTHR=1, /* ngưỡng phát lại*/
	XFRM_AE_RVAL=2, /* giá trị phát lại */
	XFRM_AE_LVAL=4, /* giá trị trọn đời */
	XFRM_AE_ETHR=8, /* ngưỡng hẹn giờ hết hạn */
	XFRM_AE_CR=16, /* Nguyên nhân sự kiện là do phát lại cập nhật */
	XFRM_AE_CE=32, /* Nguyên nhân sự kiện là hết giờ */
	XFRM_AE_CU=64, /* Nguyên nhân sự kiện là do cập nhật chính sách */

Những lá cờ này được sử dụng như thế nào phụ thuộc vào hướng của
thông báo (kernel<->user) cũng như nguyên nhân (cấu hình, truy vấn hoặc sự kiện).
Điều này được mô tả dưới đây trong các tin nhắn khác nhau.

pid sẽ được đặt phù hợp trong netlink để nhận biết hướng
(0 cho kernel và pid =processid đã tạo ra sự kiện
khi đi từ kernel sang không gian người dùng)

Một chương trình cần đăng ký vào nhóm multicast XFRMNLGRP_AEVENTS
để nhận được thông báo về những sự kiện này.

2) TLVS phản ánh các thông số khác nhau
----------------------------------------

a) giá trị byte (XFRMA_LTIME_VAL)

TLV này mang bộ đếm đang chạy/hiện tại trong suốt thời gian tồn tại của byte kể từ
   sự kiện cuối cùng.

b) giá trị chơi lại (XFRMA_REPLAY_VAL)

TLV này mang bộ đếm đang chạy/dòng điện cho chuỗi phát lại kể từ
   sự kiện cuối cùng.

c) ngưỡng phát lại (XFRMA_REPLAY_THRESH)

TLV này mang ngưỡng đang được kernel sử dụng để kích hoạt các sự kiện
   khi trình tự phát lại bị vượt quá.

d) hẹn giờ hết hạn (XFRMA_ETIMER_THRESH)

Đây là giá trị bộ đếm thời gian tính bằng mili giây được sử dụng làm thông báo
   giá trị để đánh giá giới hạn các sự kiện.

3) Cấu hình mặc định cho các thông số
--------------------------------------------

Theo mặc định, những sự kiện này sẽ bị tắt trừ khi có
ít nhất một người nghe đã đăng ký để nghe multicast
nhóm XFRMNLGRP_AEVENTS.

Tuy nhiên, các chương trình cài đặt SA sẽ cần chỉ định hai ngưỡng
để không thay đổi các ứng dụng hiện có như racoon
chúng tôi cũng cung cấp các giá trị ngưỡng mặc định cho các thông số khác nhau này
trong trường hợp chúng không được chỉ định.

hai mục sysctls/proc là:

a)/proc/sys/net/core/sysctl_xfrm_aevent_etime

Được sử dụng để cung cấp các giá trị mặc định cho XFRMA_ETIMER_THRESH theo mức tăng dần
   đơn vị thời gian là 100ms. Mặc định là 10 (1 giây)

b) /proc/sys/net/core/sysctl_xfrm_aevent_rseqth

Được sử dụng để cung cấp các giá trị mặc định cho tham số XFRMA_REPLAY_THRESH
   trong số lượng gói tăng dần. Mặc định là hai gói.

4) Các loại tin nhắn
--------------------

a) XFRM_MSG_GETAE do người dùng cấp-->kernel.
   XFRM_MSG_GETAE không mang theo bất kỳ TLV nào.

Phản hồi là XFRM_MSG_NEWAE được định dạng dựa trên những gì
   XFRM_MSG_GETAE đã truy vấn.

Phản hồi sẽ luôn có TLV XFRMA_LTIME_VAL và XFRMA_REPLAY_VAL.

* nếu cờ XFRM_AE_RTHR được đặt thì XFRMA_REPLAY_THRESH cũng được truy xuất
     * nếu cờ XFRM_AE_ETHR được đặt thì XFRMA_ETIMER_THRESH cũng được truy xuất

b) XFRM_MSG_NEWAE được cấp bởi không gian người dùng để định cấu hình
   hoặc kernel để thông báo sự kiện hoặc phản hồi XFRM_MSG_GETAE.

i) người dùng --> kernel để cấu hình một SA cụ thể.

bất kỳ giá trị hoặc tham số ngưỡng nào cũng có thể được cập nhật bằng cách chuyển
      TLV thích hợp.

Phản hồi được gửi lại cho người gửi trong không gian người dùng để biểu thị thành công
      hoặc thất bại.

Trong trường hợp thành công, thêm một sự kiện với
      XFRM_MSG_NEWAE cũng được cấp cho bất kỳ người nghe nào như được mô tả trong iii).

ii) kernel->hướng người dùng như một phản hồi cho XFRM_MSG_GETAE

Phản hồi sẽ luôn có TLV XFRMA_LTIME_VAL và XFRMA_REPLAY_VAL.

Các TLV ngưỡng sẽ được bao gồm nếu được yêu cầu rõ ràng trong
       thông báo XFRM_MSG_GETAE.

iii) kernel->user sẽ báo cáo là sự kiện nếu ai đó đặt bất kỳ giá trị nào hoặc
        ngưỡng cho SA sử dụng XFRM_MSG_NEWAE (như được mô tả trong #i ở trên).
        Trong trường hợp này, cờ XFRM_AE_CU được đặt để thông báo cho người dùng rằng
        sự thay đổi xảy ra do một bản cập nhật.
        Tin nhắn sẽ luôn có TLV XFRMA_LTIME_VAL và XFRMA_REPLAY_VAL.

iv) kernel->user để báo cáo sự kiện khi ngưỡng phát lại hoặc hết thời gian chờ
       bị vượt quá.

Trong trường hợp như vậy, XFRM_AE_CR (vượt quá thời gian phát lại) hoặc XFRM_AE_CE (hết thời gian chờ
đã xảy ra) được thiết lập để thông báo cho người dùng những gì đã xảy ra.
Lưu ý hai cờ loại trừ lẫn nhau.
Tin nhắn sẽ luôn có TLV XFRMA_LTIME_VAL và XFRMA_REPLAY_VAL.

5) Ngoại lệ đối với cài đặt ngưỡng
-----------------------------------

Nếu bạn có một SA đang bị ảnh hưởng bởi lưu lượng truy cập theo từng đợt như vậy
có một khoảng thời gian mà ngưỡng hẹn giờ hết hạn mà không có gói nào
được nhìn thấy thì một hành vi kỳ lạ được nhìn thấy như sau:
Gói đầu tiên đến sau khi hết giờ sẽ kích hoạt thời gian chờ
sự kiện; tức là chúng tôi không đợi khoảng thời gian chờ hoặc ngưỡng gói
để đạt được. Điều này được thực hiện vì lý do đơn giản và hiệu quả.

-JHS