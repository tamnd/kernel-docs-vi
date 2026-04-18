.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/clients/cdev.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |ssam_cdev_request| replace:: :c:type:`struct ssam_cdev_request <ssam_cdev_request>`
.. |ssam_cdev_request_flags| replace:: :c:type:`enum ssam_cdev_request_flags <ssam_cdev_request_flags>`
.. |ssam_cdev_event| replace:: :c:type:`struct ssam_cdev_event <ssam_cdev_event>`

=========================================
Giao diện EC không gian người dùng (cdev)
=========================================

Mô-đun ZZ0000ZZ cung cấp một thiết bị linh tinh cho SSAM
bộ điều khiển để cho phép kết nối trực tiếp (ít nhiều) từ không gian người dùng tới
SAM EC. Nó được thiết kế để sử dụng cho việc phát triển và gỡ lỗi, và
do đó không nên được sử dụng hoặc dựa vào bất kỳ cách nào khác. Lưu ý rằng điều này
mô-đun không được tải tự động mà thay vào đó phải được tải theo cách thủ công.

Giao diện được cung cấp có thể truy cập được thông qua ZZ0000ZZ
tập tin thiết bị. Tất cả chức năng của giao diện này được cung cấp thông qua IOCTL.
Các IOCTL này và các cấu trúc tham số đầu vào/đầu ra tương ứng của chúng được xác định trong
ZZ0001ZZ.

Có thể tìm thấy một thư viện python nhỏ và các tập lệnh để truy cập giao diện này
tại ZZ0000ZZ

.. contents::


Nhận sự kiện
================

Sự kiện có thể được nhận bằng cách đọc từ tệp thiết bị. Được đại diện bởi
kiểu dữ liệu ZZ0000ZZ.

Tuy nhiên, trước khi có thể đọc các sự kiện, các trình thông báo mong muốn phải được
được đăng ký qua ZZ0000ZZ IOCTL. Trình thông báo là, trong
bản chất, lệnh gọi lại, được gọi khi EC gửi một sự kiện. Họ ở trong này
giao diện, được liên kết với một danh mục mục tiêu cụ thể và phiên bản tệp thiết bị.
Chúng chuyển tiếp bất kỳ sự kiện nào thuộc loại này tới bộ đệm của sự kiện tương ứng.
dụ, từ đó nó có thể được đọc.

Bản thân trình thông báo không kích hoạt các sự kiện trên EC. Vì vậy, nó có thể bổ sung
cần thiết để kích hoạt các sự kiện thông qua ZZ0000ZZ IOCTL. Trong khi
trình thông báo hoạt động trên mỗi khách hàng (tức là trên mỗi phiên bản tệp thiết bị), các sự kiện được bật
trên toàn cầu, đối với EC và tất cả các khách hàng của nó (bất kể không gian người dùng hay
không phải không gian người dùng). ZZ0001ZZ và ZZ0002ZZ
IOCTL đảm nhiệm việc tham chiếu đếm các sự kiện, sao cho một sự kiện được
được kích hoạt miễn là có khách hàng yêu cầu nó.

Lưu ý rằng các sự kiện đã bật sẽ không tự động bị tắt khi máy khách
dụ đã bị đóng. Do đó, bất kỳ quy trình khách hàng nào (hoặc nhóm quy trình) đều phải
cân bằng các cuộc gọi kích hoạt sự kiện của họ với các cuộc gọi vô hiệu hóa sự kiện tương ứng. Nó
tuy nhiên, hoàn toàn hợp lệ để bật và tắt các sự kiện trên máy khách khác nhau
trường hợp. Ví dụ: việc thiết lập trình thông báo và đọc các sự kiện trên
phiên bản máy khách ZZ0000ZZ, hãy kích hoạt các sự kiện đó trên phiên bản ZZ0001ZZ (lưu ý rằng những sự kiện này
A cũng sẽ được nhận vì các sự kiện được bật/tắt trên toàn cầu) và
sau khi không muốn thêm sự kiện nào nữa, hãy tắt các sự kiện đã bật trước đó thông qua
ví dụ ZZ0002ZZ.


IOCTL bộ điều khiển
===================

Các IOCTL sau đây được cung cấp:

.. flat-table:: Controller IOCTLs
   :widths: 1 1 1 1 4
   :header-rows: 1

   * - Type
     - Number
     - Direction
     - Name
     - Description

   * - ``0xA5``
     - ``1``
     - ``WR``
     - ``REQUEST``
     - Perform synchronous SAM request.

   * - ``0xA5``
     - ``2``
     - ``W``
     - ``NOTIF_REGISTER``
     - Register event notifier.

   * - ``0xA5``
     - ``3``
     - ``W``
     - ``NOTIF_UNREGISTER``
     - Unregister event notifier.

   * - ``0xA5``
     - ``4``
     - ``W``
     - ``EVENT_ENABLE``
     - Enable event source.

   * - ``0xA5``
     - ``5``
     - ``W``
     - ``EVENT_DISABLE``
     - Disable event source.


ZZ0000ZZ
---------------------

Được xác định là ZZ0000ZZ.

Thực hiện yêu cầu SAM đồng bộ. Đặc tả yêu cầu được chuyển vào
làm đối số của loại ZZ0000ZZ, sau đó được ghi vào/sửa đổi
bởi IOCTL để trả về trạng thái và kết quả của yêu cầu.

Dữ liệu tải trọng yêu cầu phải được phân bổ riêng và được chuyển qua
Các thành viên ZZ0000ZZ và ZZ0001ZZ. Nếu cần có một phản hồi,
bộ đệm phản hồi phải được cấp phát bởi người gọi và chuyển vào thông qua
Thành viên ZZ0002ZZ. Thành viên ZZ0003ZZ phải được đặt thành
dung lượng của bộ đệm này hoặc nếu không cần phản hồi thì bằng 0. Khi
hoàn thành yêu cầu, cuộc gọi sẽ viết phản hồi cho phản hồi
bộ đệm (nếu dung lượng của nó cho phép) và ghi đè trường độ dài bằng
kích thước thực tế của phản hồi, tính bằng byte.

Ngoài ra, nếu yêu cầu có phản hồi, điều này phải được chỉ định thông qua
cờ yêu cầu, như được thực hiện với các yêu cầu trong kernel. Cờ yêu cầu có thể được đặt
thông qua thành viên ZZ0000ZZ và các giá trị tương ứng với các giá trị được tìm thấy trong
ZZ0001ZZ.

Cuối cùng, trạng thái của yêu cầu được trả về trong ZZ0000ZZ
thành viên (giá trị lỗi âm cho biết lỗi). Lưu ý rằng sự thất bại
dấu hiệu của IOCTL được tách biệt khỏi dấu hiệu lỗi của yêu cầu:
IOCTL trả về mã trạng thái âm nếu có lỗi xảy ra trong quá trình thiết lập
yêu cầu (ZZ0001ZZ) hoặc nếu đối số được cung cấp hoặc bất kỳ trường nào của nó
không hợp lệ (ZZ0002ZZ). Trong trường hợp này, giá trị trạng thái của yêu cầu
đối số có thể được đặt, cung cấp thêm chi tiết về những gì đã xảy ra (ví dụ:
ZZ0003ZZ hết bộ nhớ), nhưng giá trị này cũng có thể bằng 0. IOCTL
sẽ trả về với mã trạng thái bằng 0 trong trường hợp yêu cầu đã được thiết lập,
đã gửi và hoàn thành (tức là được trả lại cho không gian người dùng) thành công từ
bên trong IOCTL, nhưng thành viên ZZ0004ZZ yêu cầu vẫn có thể âm trong
trường hợp việc thực hiện yêu cầu thực tế không thành công sau khi nó được gửi.

Một định nghĩa đầy đủ về cấu trúc đối số được cung cấp dưới đây.

ZZ0000ZZ
----------------------------

Được xác định là ZZ0000ZZ.

Đăng ký trình thông báo cho danh mục mục tiêu sự kiện được chỉ định trong
mô tả trình thông báo với mức độ ưu tiên được chỉ định. Đăng ký thông báo là
cần thiết để nhận các sự kiện, nhưng bản thân chúng không kích hoạt các sự kiện. Sau một
thông báo cho một danh mục mục tiêu cụ thể đã được đăng ký, tất cả các sự kiện đó
danh mục sẽ được chuyển tiếp đến ứng dụng khách không gian người dùng và sau đó có thể được đọc từ
phiên bản tập tin thiết bị. Lưu ý rằng các sự kiện có thể phải được bật, ví dụ: thông qua
ZZ0000ZZ IOCTL, trước khi EC gửi chúng.

Chỉ có thể đăng ký một trình thông báo cho mỗi danh mục mục tiêu và phiên bản máy khách. Nếu
một trình thông báo đã được đăng ký, IOCTL này sẽ không thành công với ZZ0000ZZ.

Trình thông báo sẽ tự động bị xóa khi phiên bản tệp thiết bị được
đóng cửa.

ZZ0000ZZ
------------------------------

Được xác định là ZZ0000ZZ.

Hủy đăng ký trình thông báo được liên kết với danh mục mục tiêu đã chỉ định. các
trường ưu tiên sẽ bị IOCTL này bỏ qua. Nếu không có người thông báo nào
đã đăng ký cho phiên bản máy khách này và danh mục nhất định, IOCTL này sẽ
thất bại với ZZ0000ZZ.

ZZ0000ZZ
--------------------------

Được xác định là ZZ0000ZZ.

Kích hoạt sự kiện được liên kết với bộ mô tả sự kiện đã cho.

Lưu ý rằng cuộc gọi này sẽ không tự đăng ký trình thông báo, nó sẽ chỉ kích hoạt
sự kiện trên bộ điều khiển. Nếu bạn muốn nhận sự kiện bằng cách đọc từ
tập tin thiết bị, bạn sẽ cần phải đăng ký (các) trình thông báo tương ứng trên đó
ví dụ.

Các sự kiện không tự động bị tắt khi đóng tệp thiết bị. Điều này phải
được thực hiện thủ công, thông qua cuộc gọi đến ZZ0000ZZ IOCTL.

ZZ0000ZZ
---------------------------

Được xác định là ZZ0000ZZ.

Tắt sự kiện được liên kết với bộ mô tả sự kiện đã cho.

Lưu ý rằng thao tác này sẽ không hủy đăng ký bất kỳ trình thông báo nào. Sự kiện vẫn có thể được nhận
và được chuyển tiếp đến không gian người dùng sau cuộc gọi này. Cách dừng an toàn duy nhất
các sự kiện được nhận sẽ hủy đăng ký tất cả các sự kiện đã đăng ký trước đó
người thông báo.


Cấu trúc và Enum
====================

.. kernel-doc:: include/uapi/linux/surface_aggregator/cdev.h