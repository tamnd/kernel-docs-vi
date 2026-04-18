.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/can_ucan_protocol.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Giao thức UCAN
===================

UCAN là giao thức được sử dụng bởi USB-CAN dựa trên vi điều khiển
bộ chuyển đổi được tích hợp trên System-on-Modules từ Hệ thống Theobroma
và nó cũng có sẵn dưới dạng thanh USB độc lập.

Giao thức UCAN được thiết kế độc lập với phần cứng.
Nó được mô phỏng chặt chẽ theo cách Linux đại diện cho các thiết bị CAN
nội bộ. Tất cả các số nguyên nhiều byte được mã hóa dưới dạng Little Endian.

Tất cả các cấu trúc được đề cập trong tài liệu này được định nghĩa trong
ZZ0000ZZ.

Điểm cuối USB
=============

Các thiết bị UCAN sử dụng ba điểm cuối USB:

Điểm cuối CONTROL
  Trình điều khiển gửi lệnh quản lý thiết bị trên điểm cuối này

TRONG điểm cuối
  Thiết bị gửi khung dữ liệu CAN và khung lỗi CAN

Điểm cuối OUT
  Trình điều khiển gửi khung dữ liệu CAN ở điểm cuối bên ngoài


Tin nhắn CONTROL
================

Các thiết bị UCAN được cấu hình bằng cách sử dụng các yêu cầu của nhà cung cấp trên đường ống điều khiển.

Để hỗ trợ nhiều giao diện CAN trong một thiết bị USB duy nhất
các lệnh cấu hình nhắm vào giao diện tương ứng trong USB
mô tả.

Trình điều khiển sử dụng ZZ0000ZZ và
ZZ0001ZZ để gửi lệnh đến thiết bị.

Gói cài đặt
------------

============================================================================
ZZ0000ZZ Hướng ZZ0005ZZ (Giao diện hoặc Thiết bị)
Số lệnh ZZ0001ZZ
Số lệnh phụ ZZ0002ZZ (16 Bit) hoặc 0 nếu không được sử dụng
ZZ0003ZZ USB Chỉ mục giao diện (0 cho lệnh thiết bị)
ZZ0004ZZ * Máy chủ tới thiết bị - Số byte cần truyền
                   * Thiết bị lưu trữ - Số byte tối đa để lưu trữ
                     nhận. Nếu thiết bị gửi ít hơn. ZLP chung
                     ngữ nghĩa được sử dụng.
============================================================================

Xử lý lỗi
--------------

Thiết bị cho biết các lệnh điều khiển không thành công bằng cách dừng hoạt động
ống.

Lệnh thiết bị
---------------

UCAN_DEVICE_GET_FW_STRING
~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ

Yêu cầu chuỗi chương trình cơ sở của thiết bị.


Lệnh giao diện
------------------

UCAN_COMMAND_START
~~~~~~~~~~~~~~~~~~

ZZ0000ZZ

Đưa giao diện CAN lên.

Định dạng tải trọng
  ZZ0000ZZ

==== ===============================
chế độ hoặc mặt nạ của ZZ0000ZZ
==== ===============================

UCAN_COMMAND_STOP
~~~~~~~~~~~~~~~~~~

ZZ0000ZZ

Dừng giao diện CAN

Định dạng tải trọng
  ZZ0000ZZ

UCAN_COMMAND_RESET
~~~~~~~~~~~~~~~~~~

ZZ0000ZZ

Đặt lại bộ điều khiển CAN (bao gồm bộ đếm lỗi)

Định dạng tải trọng
  ZZ0000ZZ

UCAN_COMMAND_GET
~~~~~~~~~~~~~~~~

ZZ0000ZZ

Nhận thông tin từ thiết bị

Lệnh phụ
^^^^^^^^^^^

UCAN_COMMAND_GET_INFO
  Yêu cầu cấu trúc thông tin thiết bị ZZ0000ZZ.

Xem trường ZZ0000ZZ để biết chi tiết và
  ZZ0001ZZ để được giải thích về
  ZZ0002ZZ.

Định dạng tải trọng
    ZZ0000ZZ

UCAN_COMMAND_GET_PROTOCOL_VERSION

Yêu cầu phiên bản giao thức thiết bị
  ZZ0000ZZ. Phiên bản giao thức hiện tại là 3.

Định dạng tải trọng
    ZZ0000ZZ

.. note:: Devices that do not implement this command use the old
          protocol version 1

UCAN_COMMAND_SET_BITTIMING
~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ

Thiết lập bittiming bằng cách gửi cấu trúc
ZZ0000ZZ (xem ZZ0001ZZ để biết
chi tiết)

Định dạng tải trọng
  ZZ0000ZZ.

UCAN_SLEEP/WAKE
~~~~~~~~~~~~~~~

ZZ0000ZZ

Cấu hình chế độ ngủ và thức. Chưa được hỗ trợ bởi trình điều khiển.

UCAN_FILTER
~~~~~~~~~~~

ZZ0000ZZ

Thiết lập bộ lọc CAN phần cứng. Chưa được hỗ trợ bởi trình điều khiển.

Các lệnh giao diện được phép
----------------------------

============================================================
Trạng thái thiết bị hợp pháp Lệnh Trạng thái thiết bị mới
============================================================
đã dừng SET_BITTIMING đã dừng
đã dừng START đã bắt đầu
đã bắt đầu STOP hoặc RESET đã dừng
đã dừng STOP hoặc RESET đã dừng
bắt đầu RESTART bắt đầu
bất kỳ GET ZZ0000ZZ nào
============================================================

IN Định dạng tin nhắn
=====================

Gói dữ liệu trên điểm cuối USB IN chứa một hoặc nhiều
Giá trị ZZ0000ZZ. Nếu nhiều tin nhắn được nhóm trong USB
gói dữ liệu, trường ZZ0001ZZ có thể được sử dụng để chuyển sang gói tiếp theo
Giá trị ZZ0002ZZ (chú ý kiểm tra giá trị ZZ0003ZZ
so với kích thước dữ liệu thực tế).

.. _can_ucan_in_message_len:

Trường ZZ0000ZZ
---------------

Mỗi ZZ0000ZZ phải được căn chỉnh theo ranh giới 4 byte (tương đối
đến điểm bắt đầu của bộ đệm dữ liệu). Điều đó có nghĩa là có
có thể đệm các byte giữa nhiều giá trị ZZ0001ZZ:

.. code::

    +----------------------------+ < 0
    |                            |
    |   struct ucan_message_in   |
    |                            |
    +----------------------------+ < len
              [padding]
    +----------------------------+ < round_up(len, 4)
    |                            |
    |   struct ucan_message_in   |
    |                            |
    +----------------------------+
                [...]

Trường ZZ0000ZZ
---------------

Trường ZZ0000ZZ chỉ định loại tin nhắn.

UCAN_IN_RX
~~~~~~~~~~

ZZ0000ZZ
  không

Dữ liệu nhận được từ bus CAN (ID + tải trọng).

UCAN_IN_TX_COMPLETE
~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ
  không

Thiết bị CAN đã gửi tin nhắn đến bus CAN. Nó trả lời bằng một
danh sách các bộ dữ liệu <echo-ids, flags>.

Echo-id xác định khung từ (tiếng vang id từ khung trước đó
tin nhắn UCAN_OUT_TX). Cờ cho biết kết quả của
truyền tải. Trong khi đó Bit 0 được đặt cho biết thành công. Tất cả các bit khác
được bảo lưu và đặt thành 0.

Kiểm soát dòng chảy
-------------------

Khi nhận tin nhắn CAN, không có điều khiển luồng trên USB
bộ đệm. Người lái xe phải xử lý tin nhắn gửi đến đủ nhanh để
tránh giọt. Tôi trường hợp tràn bộ đệm thiết bị, điều kiện là
được báo cáo bằng cách gửi các khung lỗi tương ứng (xem
ZZ0000ZZ)


Định dạng tin nhắn OUT
======================

Gói dữ liệu trên điểm cuối USB OUT chứa một hoặc nhiều giá trị ZZ0001ZZ. Nếu nhiều tin nhắn được gộp thành một
gói dữ liệu, thiết bị sử dụng trường ZZ0002ZZ để chuyển sang gói tiếp theo
giá trị ucan_message_out. Mỗi ucan_message_out phải được căn chỉnh thành 4
byte (so với điểm bắt đầu của bộ đệm dữ liệu). Cơ chế là
giống như được mô tả trong ZZ0000ZZ.

.. code::

    +----------------------------+ < 0
    |                            |
    |   struct ucan_message_out  |
    |                            |
    +----------------------------+ < len
              [padding]
    +----------------------------+ < round_up(len, 4)
    |                            |
    |   struct ucan_message_out  |
    |                            |
    +----------------------------+
                [...]

Trường ZZ0000ZZ
---------------

Trong giao thức phiên bản 3 chỉ xác định ZZ0000ZZ, các giao thức khác được sử dụng
chỉ bởi các thiết bị cũ (phiên bản giao thức 1).

UCAN_OUT_TX
~~~~~~~~~~~
ZZ0000ZZ
  echo id sẽ được trả lời trong tin nhắn CAN_IN_TX_COMPLETE

Truyền khung CAN. (thông số: ZZ0000ZZ, ZZ0001ZZ)

Kiểm soát dòng chảy
-------------------

Khi bộ đệm gửi đi của thiết bị đầy, nó sẽ bắt đầu gửi ZZ0000ZZ
ống ZZ0001ZZ cho đến khi có thêm bộ đệm. Người lái xe dừng xe
xếp hàng khi một ngưỡng nhất định của các gói tin không đầy đủ.

.. _can_ucan_error_handling:

Xử lý lỗi CAN
==================

Nếu bật báo cáo lỗi, thiết bị sẽ mã hóa lỗi thành CAN
khung lỗi (xem ZZ0000ZZ) và gửi nó bằng cách sử dụng
TRONG điểm cuối. Trình điều khiển cập nhật số liệu thống kê lỗi của nó và chuyển tiếp
nó.

Mặc dù các thiết bị UCAN có thể ngăn chặn hoàn toàn các khung lỗi nhưng trong Linux
người lái xe luôn quan tâm. Do đó, thiết bị luôn được khởi động bằng
bộ ZZ0000ZZ. Lọc những tin nhắn đó cho
không gian người dùng được thực hiện bởi trình điều khiển.

Xe buýt OFF
-----------

- Thiết bị không tự động khôi phục từ bus.
- Bus OFF được biểu thị bằng khung lỗi (xem ZZ0000ZZ)
- Quá trình khôi phục Bus OFF được khởi động bởi ZZ0001ZZ
- Sau khi khôi phục Bus OFF hoàn tất, thiết bị sẽ gửi khung lỗi
  chỉ ra rằng nó ở trạng thái ERROR-ACTIVE.
- Trong Bus OFF không có khung nào được thiết bị gửi.
- Trong khi yêu cầu truyền Bus OFF từ máy chủ được hoàn thành
  ngay lập tức với bit thành công không được đặt.

Cuộc trò chuyện mẫu
====================

#) Thiết bị được kết nối với USB
#) Host gửi lệnh ZZ0000ZZ, subcmd 0
#) Host gửi lệnh ZZ0001ZZ, subcmd ZZ0002ZZ
#) Thiết bị gửi ZZ0003ZZ
#) Máy chủ gửi lệnh ZZ0004ZZ
#) Host gửi lệnh ZZ0005ZZ, subcmd 0, chế độ ZZ0006ZZ
