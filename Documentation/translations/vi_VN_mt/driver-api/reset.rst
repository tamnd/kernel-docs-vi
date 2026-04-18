.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/reset.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Đặt lại bộ điều khiển API
====================

Giới thiệu
============

Bộ điều khiển đặt lại là bộ phận trung tâm điều khiển tín hiệu đặt lại thành nhiều
thiết bị ngoại vi.
Bộ điều khiển đặt lại API được chia thành hai phần:
ZZ0000ZZ (ZZ0001ZZ), cho phép trình điều khiển ngoại vi yêu cầu điều khiển
qua các tín hiệu đầu vào đặt lại của chúng và ZZ0002ZZ (ZZ0003ZZ), được trình điều khiển sử dụng để đặt lại
thiết bị điều khiển đăng ký các điều khiển đặt lại của chúng để cung cấp chúng cho
người tiêu dùng.

Trong khi một số đơn vị phần cứng của bộ điều khiển đặt lại cũng thực hiện khởi động lại hệ thống
chức năng, trình xử lý khởi động lại nằm ngoài phạm vi của bộ điều khiển đặt lại API.

Thuật ngữ
--------

Bộ điều khiển đặt lại API sử dụng các thuật ngữ này với ý nghĩa cụ thể:

Đặt lại dòng

Đường đặt lại vật lý mang tín hiệu đặt lại từ bộ điều khiển đặt lại
    đơn vị phần cứng đến một mô-đun ngoại vi.

Đặt lại quyền kiểm soát

Phương pháp điều khiển xác định trạng thái của một hoặc nhiều dòng đặt lại.
    Thông thường nhất đây là một bit trong không gian thanh ghi bộ điều khiển thiết lập lại
    hoặc cho phép kiểm soát trực tiếp trạng thái vật lý của dòng đặt lại hoặc
    tự xóa và có thể được sử dụng để kích hoạt xung được xác định trước trên
    dòng thiết lập lại.
    Trong các điều khiển đặt lại phức tạp hơn, một hành động kích hoạt có thể khởi chạy một
    chuỗi xung được tính thời gian cẩn thận trên nhiều đường đặt lại.

Đặt lại bộ điều khiển

Một mô-đun phần cứng cung cấp một số điều khiển thiết lập lại để điều khiển một
    số dòng thiết lập lại.

Đặt lại người tiêu dùng

Mô-đun ngoại vi hoặc IC bên ngoài được đặt lại bằng tín hiệu trên
    dòng thiết lập lại.

Giao diện trình điều khiển tiêu dùng
=========================

Giao diện này cung cấp API tương tự như khung đồng hồ kernel.
Trình điều khiển tiêu dùng sử dụng các thao tác nhận và đặt để lấy và phát hành thiết lập lại
điều khiển.
Các chức năng được cung cấp để xác nhận và xác nhận lại các dòng thiết lập lại được kiểm soát,
kích hoạt các xung đặt lại hoặc để truy vấn trạng thái dòng đặt lại.

Khi yêu cầu đặt lại các điều khiển, người tiêu dùng có thể sử dụng tên tượng trưng cho
đầu vào đặt lại, được ánh xạ tới điều khiển đặt lại thực tế trên thiết lập lại hiện có
thiết bị điều khiển bằng lõi.

Phiên bản sơ khai của API này được cung cấp khi khung bộ điều khiển thiết lập lại được
không được sử dụng để giảm thiểu nhu cầu sử dụng ifdefs.

Đặt lại được chia sẻ và độc quyền
---------------------------

Bộ điều khiển đặt lại API cung cấp tính năng hủy xác nhận tham chiếu và
khẳng định hoặc kiểm soát trực tiếp, độc quyền.
Sự khác biệt giữa các điều khiển đặt lại được chia sẻ và độc quyền được thực hiện tại thời điểm
điều khiển đặt lại được yêu cầu, thông qua devm_reset_control_get_shared() hoặc
thông qua devm_reset_control_get_exclusive().
Lựa chọn này xác định hành vi của các cuộc gọi API được thực hiện bằng thiết lập lại
kiểm soát.

Việc đặt lại được chia sẻ hoạt động tương tự như đồng hồ trong khung đồng hồ hạt nhân.
Họ cung cấp việc xác nhận lại được tính tham chiếu, trong đó chỉ có xác nhận lại đầu tiên,
làm tăng số tham chiếu xác nhận lại lên một và xác nhận cuối cùng
làm giảm số tham chiếu xác nhận lại về 0, có một vật lý
tác dụng lên dòng reset.

Mặt khác, việc đặt lại độc quyền đảm bảo khả năng kiểm soát trực tiếp.
Nghĩa là, một xác nhận làm cho dòng đặt lại được xác nhận ngay lập tức và một
xác nhận lại khiến dòng đặt lại được xác nhận lại ngay lập tức.

Xác nhận và xác nhận lại
-------------------------

Trình điều khiển tiêu dùng sử dụng reset_control_assert() và reset_control_deassert()
chức năng xác nhận và xác nhận lại các dòng thiết lập lại.
Đối với các điều khiển đặt lại được chia sẻ, lệnh gọi đến hai chức năng phải được cân bằng.

Lưu ý rằng vì nhiều người tiêu dùng có thể đang sử dụng điều khiển đặt lại được chia sẻ nên có
không đảm bảo rằng việc gọi reset_control_assert() trên điều khiển đặt lại được chia sẻ
thực sự sẽ khiến dòng đặt lại được xác nhận.
Trình điều khiển của người tiêu dùng sử dụng các điều khiển đặt lại được chia sẻ sẽ cho rằng dòng đặt lại
có thể được giữ lại xác nhận mọi lúc.
API chỉ đảm bảo rằng dòng đặt lại không thể được xác nhận miễn là có bất kỳ
người tiêu dùng đã yêu cầu nó được xác nhận lại.

Kích hoạt
----------

Trình điều khiển của người tiêu dùng sử dụng reset_control_reset() để kích hoạt xung đặt lại trên
điều khiển thiết lập lại tự xác nhận.
Nói chung, những thiết lập lại này không thể được chia sẻ giữa nhiều người tiêu dùng, vì
yêu cầu xung từ bất kỳ trình điều khiển tiêu dùng nào sẽ thiết lập lại tất cả các kết nối
thiết bị ngoại vi.

Bộ điều khiển đặt lại API cho phép yêu cầu các điều khiển đặt lại tự xác nhận như
được chia sẻ, nhưng đối với những yêu cầu đó chỉ yêu cầu kích hoạt đầu tiên mới tạo ra xung thực tế
được phát hành trên dòng thiết lập lại.
Tất cả các lệnh gọi tiếp theo đến chức năng này sẽ không có hiệu lực cho đến khi tất cả người tiêu dùng có
được gọi là reset_control_rearm().
Đối với các điều khiển đặt lại được chia sẻ, lệnh gọi đến hai chức năng phải được cân bằng.
Điều này cho phép các thiết bị chỉ yêu cầu thiết lập lại lần đầu tại bất kỳ thời điểm nào trước khi
trình điều khiển được thăm dò hoặc tiếp tục để chia sẻ dòng thiết lập lại xung.

Truy vấn
--------

Chỉ một số bộ điều khiển đặt lại hỗ trợ truy vấn trạng thái hiện tại của việc đặt lại
dòng, thông qua reset_control_status().
Nếu được hỗ trợ, hàm này sẽ trả về giá trị dương khác 0 nếu giá trị đã cho
dòng thiết lập lại được xác nhận.
Hàm reset_control_status() không chấp nhận
ZZ0000ZZ xử lý làm tham số đầu vào của nó.

Đặt lại tùy chọn
---------------

Thông thường các thiết bị ngoại vi yêu cầu đường đặt lại trên một số nền tảng nhưng không yêu cầu trên các nền tảng khác.
Đối với điều này, các điều khiển đặt lại có thể được yêu cầu dưới dạng tùy chọn bằng cách sử dụng
devm_reset_control_get_Optional_exclusive() hoặc
devm_reset_control_get_Optional_shared().
Các hàm này trả về một con trỏ NULL thay vì lỗi khi được yêu cầu
điều khiển đặt lại không được chỉ định trong cây thiết bị.
Việc truyền con trỏ NULL tới các hàm reset_control sẽ khiến chúng trả về
lặng lẽ không có lỗi.

Đặt lại mảng điều khiển
--------------------

Một số trình điều khiển cần xác nhận một loạt dòng đặt lại không theo thứ tự cụ thể.
devm_reset_control_array_get() trả về một điều khiển điều khiển đặt lại mờ đục có thể
được sử dụng để xác nhận, xác nhận lại hoặc kích hoạt tất cả các điều khiển đặt lại được chỉ định cùng một lúc.
Điều khiển đặt lại API không đảm bảo thứ tự mà cá nhân
các điều khiển trong đó được xử lý.

Đặt lại giao diện trình điều khiển bộ điều khiển
=================================

Trình điều khiển cho các mô-đun bộ điều khiển thiết lập lại cung cấp chức năng cần thiết để
xác nhận hoặc xác nhận lại các tín hiệu đặt lại, để kích hoạt xung đặt lại trên đường đặt lại hoặc
để truy vấn trạng thái hiện tại của nó.
Tất cả các chức năng là tùy chọn.

Khởi tạo
--------------

Trình điều khiển điền vào cấu trúc ZZ0000ZZ và đăng ký nó với
reset_controller_register() trong chức năng thăm dò của họ.
Chức năng thực tế được triển khai trong các hàm gọi lại thông qua cấu trúc
ZZ0001ZZ.

Tham khảo API
=============

Bộ điều khiển đặt lại API được ghi lại ở đây thành hai phần:
ZZ0000ZZ và ZZ0001ZZ.

Đặt lại API tiêu dùng
------------------

Người tiêu dùng đặt lại có thể điều khiển dòng đặt lại bằng cách sử dụng tay cầm điều khiển đặt lại mờ đục,
có thể lấy được từ devm_reset_control_get_exclusive() hoặc
devm_reset_control_get_shared().
Với điều khiển đặt lại, người tiêu dùng có thể gọi reset_control_assert() và
reset_control_deassert(), kích hoạt xung đặt lại bằng cách sử dụng reset_control_reset() hoặc
truy vấn trạng thái dòng đặt lại bằng cách sử dụng reset_control_status().

.. kernel-doc:: include/linux/reset.h
   :internal:

.. kernel-doc:: drivers/reset/core.c
   :functions: reset_control_reset
               reset_control_assert
               reset_control_deassert
               reset_control_status
               reset_control_acquire
               reset_control_release
               reset_control_rearm
               reset_control_put
               of_reset_control_get_count
               devm_reset_control_array_get
               reset_control_get_count

Đặt lại trình điều khiển bộ điều khiển API
---------------------------

Trình điều khiển bộ điều khiển đặt lại có nhiệm vụ thực hiện các chức năng cần thiết trong
một cấu trúc hằng số tĩnh ZZ0000ZZ, phân bổ và điền vào
một cấu trúc ZZ0001ZZ và đăng ký nó bằng cách sử dụng
devm_reset_controller_register().

.. kernel-doc:: include/linux/reset-controller.h
   :internal:

.. kernel-doc:: drivers/reset/core.c
   :functions: of_reset_simple_xlate
               reset_controller_register
               reset_controller_unregister
               devm_reset_controller_register