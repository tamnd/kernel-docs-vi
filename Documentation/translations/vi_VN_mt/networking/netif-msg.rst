.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/netif-msg.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Mức tin nhắn NETIF
===============

Thiết kế cài đặt mức thông báo giao diện mạng.

Lịch sử
-------

Việc thiết kế giao diện thông báo gỡ lỗi đã được hướng dẫn và
 bị hạn chế bởi khả năng tương thích ngược thực tế trước đó.  Nó rất hữu ích
 để hiểu lịch sử và sự phát triển để hiểu hiện tại
 thực hành và liên hệ nó với mã nguồn trình điều khiển cũ hơn.

Ngay từ đầu Linux, mỗi trình điều khiển thiết bị mạng đã có một trình điều khiển cục bộ
 biến số nguyên kiểm soát mức độ thông báo gỡ lỗi.  Tin nhắn
 mức độ dao động từ 0 đến 7 và tăng độ dài một cách đơn điệu.

Cấp độ thông báo không được xác định chính xác ở cấp độ 3, nhưng đã
 luôn được thực hiện trong khoảng +-1 của mức được chỉ định.  Trình điều khiển có xu hướng
 để loại bỏ các thông điệp ở mức độ chi tiết hơn khi chúng trưởng thành.

- 0 tin nhắn tối thiểu, chỉ có thông tin cần thiết về các lỗi nghiêm trọng.
   - 1 tin nhắn chuẩn, trạng thái khởi tạo.  Không có tin nhắn trong thời gian chạy
   - 2 tin nhắn lựa chọn phương tiện đặc biệt, thường là trình điều khiển hẹn giờ.
   - 3 Giao diện khởi động và dừng, bao gồm các thông báo trạng thái bình thường
   - 4 thông báo lỗi khung Tx và Rx, driver hoạt động bất thường
   - Thông tin hàng đợi gói 5 Tx, sự kiện ngắt.
   - 6 Trạng thái trên mỗi gói Tx đã hoàn thành và các gói Rx đã nhận
   - 7 Nội dung ban đầu của gói Tx và Rx

Ban đầu biến mức thông báo này được đặt tên duy nhất trong mỗi trình điều khiển
 ví dụ: "lance_debug", để trình gỡ lỗi biểu tượng kernel có thể định vị và
 sửa đổi cài đặt.  Khi các mô-đun hạt nhân trở nên phổ biến, các biến
 liên tục được đổi tên thành "gỡ lỗi" và được phép đặt làm mô-đun
 tham số.

Cách tiếp cận này hoạt động tốt.  Tuy nhiên luôn có nhu cầu về
 các tính năng bổ sung.  Qua nhiều năm, những điều sau đây nổi lên như
 cải tiến hợp lý và dễ dàng thực hiện

- Sử dụng lệnh gọi ioctl() để sửa đổi cấp độ.
   - Cài đặt cấp độ thông báo trên mỗi giao diện chứ không phải trên mỗi trình điều khiển.
   - Kiểm soát có chọn lọc hơn đối với loại tin nhắn được phát ra.

Đề xuất netif_msg chỉ bổ sung thêm các tính năng này với một số tính năng nhỏ
 độ phức tạp và kích thước mã tăng lên.

Khuyến nghị là những điểm sau

- Giữ lại biến số nguyên "gỡ lỗi" cho mỗi trình điều khiển dưới dạng mô-đun
    tham số có mức mặc định là '1'.

- Thêm biến riêng tư trên mỗi giao diện có tên là "msg_enable".  các
    biến là một bản đồ bit chứ không phải là một cấp độ và được khởi tạo là ::

1 << gỡ lỗi

Hay chính xác hơn::

gỡ lỗi <0? 0 : 1 << phút(sizeof(int)-1, gỡ lỗi)

Tin nhắn sẽ thay đổi từ::

nếu (gỡ lỗi > 1)
	   printk(MSG_DEBUG "%s: ...

ĐẾN::

nếu (np->msg_enable & NETIF_MSG_LINK)
	   printk(MSG_DEBUG "%s: ...


Tập hợp các cấp độ tin nhắn được đặt tên


===========================================
  Cấp độ cũ Tên Vị trí bit
  ===========================================
    0 NETIF_MSG_DRV 0x0001
    1 NETIF_MSG_PROBE 0x0002
    2 NETIF_MSG_LINK 0x0004
    2 NETIF_MSG_TIMER 0x0004
    3 NETIF_MSG_IFDOWN 0x0008
    3 NETIF_MSG_IFUP 0x0008
    4 NETIF_MSG_RX_ERR 0x0010
    4 NETIF_MSG_TX_ERR 0x0010
    5 NETIF_MSG_TX_QUEUED 0x0020
    5 NETIF_MSG_INTR 0x0020
    6 NETIF_MSG_TX_DONE 0x0040
    6 NETIF_MSG_RX_STATUS 0x0040
    7 NETIF_MSG_PKTDATA 0x0080
  ===========================================