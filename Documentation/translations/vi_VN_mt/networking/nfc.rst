.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/nfc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Hệ thống con Linux NFC
======================

Cần có hệ thống con Giao tiếp trường gần (NFC) để chuẩn hóa
NFC phát triển trình điều khiển thiết bị và tạo giao diện không gian người dùng thống nhất.

Tài liệu này trình bày tổng quan về kiến trúc, giao diện trình điều khiển thiết bị
mô tả và mô tả giao diện không gian người dùng.

Tổng quan về kiến ​​trúc
========================

Hệ thống con NFC chịu trách nhiệm:
      - Quản lý bộ điều hợp NFC;
      - Bỏ phiếu cho các mục tiêu;
      - Trao đổi dữ liệu cấp thấp;

Hệ thống con được chia thành một số phần. “Cốt lõi” chịu trách nhiệm về
cung cấp giao diện trình điều khiển thiết bị. Mặt khác, nó cũng
chịu trách nhiệm cung cấp một giao diện để kiểm soát các hoạt động và các hoạt động cấp thấp
trao đổi dữ liệu.

Các hoạt động điều khiển có sẵn cho không gian người dùng thông qua liên kết mạng chung.

Giao diện trao đổi dữ liệu cấp thấp được cung cấp bởi họ socket mới
PF_NFC. NFC_SOCKPROTO_RAW thực hiện giao tiếp thô với các mục tiêu NFC.

.. code-block:: none

        +--------------------------------------+
        |              USER SPACE              |
        +--------------------------------------+
            ^                       ^
            | low-level             | control
            | data exchange         | operations
            |                       |
            |                       v
            |                  +-----------+
            | AF_NFC           |  netlink  |
            | socket           +-----------+
            | raw                   ^
            |                       |
            v                       v
        +---------+            +-----------+
        | rawsock | <--------> |   core    |
        +---------+            +-----------+
                                    ^
                                    |
                                    v
                               +-----------+
                               |  driver   |
                               +-----------+

Giao diện trình điều khiển thiết bị
===================================

Khi đăng ký trên hệ thống con NFC, trình điều khiển thiết bị phải thông báo cho lõi
của bộ giao thức NFC được hỗ trợ và bộ lệnh gọi lại hoạt động. hoạt động
các cuộc gọi lại phải được thực hiện như sau:

* start_poll - thiết lập thiết bị để thăm dò mục tiêu
* stop_poll - dừng hoạt động bỏ phiếu tiến trình
* activate_target - chọn và khởi tạo một trong các mục tiêu được tìm thấy
* hủy kích hoạt_target - bỏ chọn và khởi tạo lại mục tiêu đã chọn
* data_exchange - gửi dữ liệu và nhận phản hồi (hoạt động thu phát)

Giao diện không gian người dùng
===============================

Giao diện không gian người dùng được chia thành các hoạt động điều khiển và dữ liệu cấp thấp
hoạt động trao đổi.

Hoạt động điều khiển
--------------------

Liên kết mạng chung được sử dụng để triển khai giao diện cho các hoạt động điều khiển.
Các hoạt động được tạo bởi các lệnh và sự kiện, tất cả được liệt kê dưới đây:

* NFC_CMD_GET_DEVICE - lấy thông tin thiết bị cụ thể hoặc kết xuất danh sách thiết bị
* NFC_CMD_START_POLL - thiết lập một thiết bị cụ thể để thăm dò mục tiêu
* NFC_CMD_STOP_POLL - dừng hoạt động bỏ phiếu trong một thiết bị cụ thể
* NFC_CMD_GET_TARGET - kết xuất danh sách các mục tiêu được tìm thấy bởi một thiết bị cụ thể

* NFC_EVENT_DEVICE_ADDED - báo cáo bổ sung thiết bị NFC
* NFC_EVENT_DEVICE_REMOVED - báo cáo việc loại bỏ thiết bị NFC
* NFC_EVENT_TARGETS_FOUND - báo cáo kết quả START_POLL khi có 1 hoặc nhiều mục tiêu
  được tìm thấy

Người dùng phải gọi START_POLL để thăm dò các mục tiêu NFC, chuyển NFC mong muốn
giao thức thông qua thuộc tính NFC_ATTR_PROTOCOLS. Thiết bị vẫn đang trong chế độ bỏ phiếu
trạng thái cho đến khi nó tìm thấy bất kỳ mục tiêu nào. Tuy nhiên, người dùng có thể dừng bỏ phiếu
hoạt động bằng cách gọi lệnh STOP_POLL. Trong trường hợp này, nó sẽ được kiểm tra xem
người yêu cầu STOP_POLL cũng giống như START_POLL.

Nếu hoạt động thăm dò tìm thấy một hoặc nhiều mục tiêu, sự kiện TARGETS_FOUND sẽ được
đã gửi (bao gồm cả id thiết bị). Người dùng phải gọi GET_TARGET để nhận danh sách
tất cả các mục tiêu được tìm thấy bởi thiết bị đó. Mỗi tin nhắn trả lời có thuộc tính đích với
thông tin liên quan như các giao thức NFC được hỗ trợ.

Tất cả các hoạt động thăm dò được yêu cầu thông qua một ổ cắm netlink đều bị dừng khi
nó đã đóng cửa.

Trao đổi dữ liệu cấp thấp
-------------------------

Không gian người dùng phải sử dụng ổ cắm PF_NFC để thực hiện bất kỳ giao tiếp dữ liệu nào với
mục tiêu. Tất cả các ổ cắm NFC đều sử dụng AF_NFC::

cấu trúc sockaddr_nfc {
               sa_family_t sa_family;
               __u32 dev_idx;
               __u32 target_idx;
               __u32 nfc_protocol;
        };

Để thiết lập kết nối với một mục tiêu, người dùng phải tạo một
Ổ cắm NFC_SOCKPROTO_RAW và gọi tòa nhà 'kết nối' với sockaddr_nfc
struct được điền chính xác. Mọi thông tin đều đến từ NFC_EVENT_TARGETS_FOUND
sự kiện liên kết mạng. Vì mục tiêu có thể hỗ trợ nhiều giao thức NFC, người dùng
phải thông báo giao thức nào nó muốn sử dụng.

Trong nội bộ, 'kết nối' sẽ dẫn đến lệnh gọi activate_target tới trình điều khiển.
Khi ổ cắm được đóng lại, mục tiêu sẽ bị vô hiệu hóa.

Định dạng dữ liệu được trao đổi qua ổ cắm phụ thuộc vào giao thức NFC. cho
Ví dụ: khi giao tiếp với thẻ MIFARE, dữ liệu được trao đổi là MIFARE
lệnh và phản hồi của chúng.

Gói nhận được đầu tiên là phản hồi cho gói được gửi đầu tiên và do đó
trên. Để cho phép phản hồi "trống" hợp lệ, mọi dữ liệu nhận được đều có NULL
tiêu đề 1 byte.
