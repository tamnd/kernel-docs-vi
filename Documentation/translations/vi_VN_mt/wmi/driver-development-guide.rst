.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/wmi/driver-development-guide.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Hướng dẫn phát triển trình điều khiển WMI
============================

Hệ thống con WMI cung cấp trình điều khiển phong phú API để triển khai trình điều khiển WMI,
được ghi lại tại Documentation/driver-api/wmi.rst. Tài liệu này sẽ phục vụ
làm hướng dẫn giới thiệu cho người viết trình điều khiển WMI sử dụng API này. Nó được cho là
là người kế thừa bài viết LWN ban đầu [1]_ đề cập đến trình điều khiển WMI
sử dụng giao diện WMI dựa trên GUID không được dùng nữa.

Lấy thông tin thiết bị WMI
--------------------------------

Trước khi phát triển trình điều khiển WMI, thông tin về thiết bị WMI được đề cập
phải có được. Tiện ích ZZ0000ZZ có thể
được sử dụng để trích xuất thông tin chi tiết về thiết bị WMI bằng lệnh sau:

::

lswmi -V

Kết quả đầu ra sẽ chứa thông tin về tất cả các thiết bị WMI có sẵn trên
một máy nhất định, cùng với một số thông tin bổ sung.

Để tìm hiểu thêm về giao diện được sử dụng để giao tiếp với thiết bị WMI,
các tiện ích ZZ0001ZZ có thể được sử dụng để giải mã
thông tin MOF nhị phân (Định dạng đối tượng được quản lý) được sử dụng để mô tả các thiết bị WMI.
Trình điều khiển ZZ0000ZZ hiển thị thông tin này cho không gian người dùng, xem
Tài liệu/wmi/devices/wmi-bmof.rst.

Để truy xuất thông tin MOF nhị phân đã giải mã, hãy sử dụng lệnh sau (yêu cầu root):

::

./bmf2mof /sys/bus/wmi/devices/05901221-D566-11D1-B2F0-00A0C9062910[-X]/bmof

Đôi khi nhìn vào các bảng ACPI đã được tháo rời dùng để mô tả thiết bị WMI
giúp hiểu cách thức hoạt động của thiết bị WMI. Đường đi của ACPI
phương thức được liên kết với một thiết bị WMI nhất định có thể được truy xuất bằng tiện ích ZZ0000ZZ
như đã đề cập ở trên.

Nếu bạn đang cố chuyển một trình điều khiển sang Linux và đang làm việc trên Windows
hệ thống, ZZ0000ZZ có thể hữu ích
để kiểm tra các phương thức WMI có sẵn và gọi chúng trực tiếp.

Cấu trúc trình điều khiển WMI cơ bản
--------------------------

Trình điều khiển WMI cơ bản được xây dựng xung quanh cấu trúc wmi_driver, sau đó được ràng buộc
để khớp các thiết bị WMI bằng bảng struct wmi_device_id:

::

cấu trúc const tĩnh wmi_device_id foo_id_table[] = {
         /* Chỉ sử dụng chữ in hoa! */
         { "936DA01F-9ABD-4D9D-80C7-02AF85C822A8", NULL },
         { }
  };
  MODULE_DEVICE_TABLE(wmi, foo_id_table);

cấu trúc tĩnh wmi_driver foo_driver = {
        .driver = {
                .name = "foo",
                .probe_type = PROBE_PREFER_ASYNCHRONOUS, /* được đề xuất */
                .pm = pm_sleep_ptr(&foo_dev_pm_ops), /* tùy chọn */
        },
        .id_table = foo_id_table,
        .probe = foo_probe,
        .remove = foo_remove, /* tùy chọn, ưu tiên devres */
        .shutdown = foo_shutdown, /* tùy chọn, được gọi khi tắt máy */
        .notify_new = foo_notify, /* tùy chọn, để xử lý sự kiện */
        .no_notify_data = true, /* tùy chọn, bật các sự kiện không chứa dữ liệu bổ sung */
        .no_singleton = true, /* bắt buộc đối với trình điều khiển WMI mới */
  };
  module_wmi_driver(foo_driver);

Cuộc gọi lại thăm dò() được gọi khi trình điều khiển WMI được liên kết với thiết bị WMI phù hợp. Phân bổ
Cấu trúc dữ liệu dành riêng cho trình điều khiển và giao diện khởi tạo cho các hệ thống con kernel khác sẽ
thường được thực hiện trong chức năng này.

Lệnh gọi lại Remove() sau đó được gọi khi trình điều khiển WMI được hủy liên kết khỏi thiết bị WMI. theo thứ tự
để hủy đăng ký giao diện với các hệ thống con kernel khác và giải phóng tài nguyên, nên sử dụng devres.
Điều này giúp đơn giản hóa việc xử lý lỗi trong quá trình thăm dò và thường cho phép bỏ qua hoàn toàn lệnh gọi lại này, xem
Documentation/driver-api/driver-model/devres.rst để biết chi tiết.

Lệnh gọi lại tắt máy () được gọi trong khi tắt máy, khởi động lại hoặc kexec. Mục đích duy nhất của nó là vô hiệu hóa
thiết bị WMI và đặt nó ở trạng thái nổi tiếng để trình điều khiển WMI nhận sau khi khởi động lại
hoặc kexec. Hầu hết các trình điều khiển WMI không cần xử lý tắt máy đặc biệt và do đó có thể bỏ qua lệnh gọi lại này.

Xin lưu ý rằng cần có trình điều khiển WMI mới để có thể khởi tạo nhiều lần,
và bị cấm sử dụng bất kỳ chức năng WMI dựa trên GUID hoặc ACPI không được dùng nữa. Điều này có nghĩa
trình điều khiển WMI phải được chuẩn bị cho trường hợp có nhiều thiết bị WMI phù hợp
hiện diện trên một máy nhất định.

Vì điều này, trình điều khiển WMI nên sử dụng mẫu thiết kế vùng chứa trạng thái như được mô tả trong
Tài liệu/driver-api/driver-model/design-patterns.rst.

.. warning:: Using both GUID-based and non-GUID-based functions for querying WMI data blocks and
             handling WMI events simultaneously on the same device is guaranteed to corrupt the
             WMI device state and might lead to erratic behaviour.

Trình điều khiển phương pháp WMI
------------------

Trình điều khiển WMI có thể gọi các phương thức thiết bị WMI bằng cách sử dụng wmidev_invoke_method(). Đối với mỗi phương pháp WMI
gọi trình điều khiển WMI cần cung cấp số phiên bản và ID phương thức, cũng như
một bộ đệm với các đối số của phương thức và tùy chọn một bộ đệm cho kết quả.

Bố cục của bộ đệm nói trên dành riêng cho thiết bị và được mô tả bằng dữ liệu MOF nhị phân được liên kết
với một thiết bị WMI nhất định. Dữ liệu MOF nhị phân đã nói cũng mô tả ID phương thức của một phương thức WMI nhất định
với vòng loại ZZ0000ZZ. Các thiết bị WMI hiển thị các phương thức WMI thường chỉ hiển thị một
instance (phiên bản số 0), nhưng trên lý thuyết cũng có thể phơi bày nhiều phiên bản. Trong trường hợp như vậy
số lượng phiên bản có thể được truy xuất bằng cách sử dụng wmidev_instance_count().

Hãy xem driver/platform/x86/intel/wmi/thunderbolt.c để biết trình điều khiển phương thức WMI mẫu.

Trình điều khiển khối dữ liệu WMI
----------------------

Trình điều khiển WMI có thể truy vấn các khối dữ liệu WMI bằng cách sử dụng wmidev_query_block(), bố cục của dữ liệu được trả về
bộ đệm lại dành riêng cho thiết bị và được mô tả bằng dữ liệu MOF nhị phân. Một số khối dữ liệu WMI
cũng có thể ghi và có thể được đặt bằng wmidev_set_block(). Số lượng phiên bản khối dữ liệu có thể
lại được truy xuất bằng cách sử dụng wmidev_instance_count().

Hãy xem driver/platform/x86/intel/wmi/sbl-fw-update.c để biết ví dụ về trình điều khiển khối dữ liệu WMI.

Trình điều khiển sự kiện WMI
-----------------

Trình điều khiển WMI có thể nhận các sự kiện WMI thông qua hàm gọi lại notification_new() bên trong struct wmi_driver.
Hệ thống con WMI sau đó sẽ đảm nhiệm việc thiết lập sự kiện WMI tương ứng. Xin lưu ý rằng
bố cục của bộ đệm được truyền cho lệnh gọi lại này dành riêng cho thiết bị và việc giải phóng bộ đệm
được thực hiện bởi chính hệ thống con WMI chứ không phải trình điều khiển.

Lõi trình điều khiển WMI sẽ đảm bảo rằng cuộc gọi lại thông báo_new() sẽ chỉ được gọi sau
lệnh gọi lại thăm dò() đã được gọi và trình điều khiển không nhận được sự kiện nào
ngay trước và sau khi gọi lại lệnh gọi lại Remove() hoặc Shutter().

Tuy nhiên, các nhà phát triển trình điều khiển WMI nên lưu ý rằng có thể nhận được nhiều sự kiện WMI đồng thời,
vì vậy mọi khóa (nếu cần) cần phải được cung cấp bởi chính trình điều khiển WMI.

Để có thể nhận các sự kiện WMI không chứa dữ liệu sự kiện bổ sung,
cờ ZZ0000ZZ bên trong struct wmi_driver phải được đặt thành ZZ0001ZZ.

Hãy xem driver/platform/x86/xiaomi-wmi.c để biết trình điều khiển sự kiện WMI mẫu.

Trao đổi dữ liệu với lõi trình điều khiển WMI
----------------------------------------

Trình điều khiển WMI có thể trao đổi dữ liệu với lõi trình điều khiển WMI bằng struct wmi_buffer. nội bộ
Cấu trúc của các bộ đệm đó dành riêng cho thiết bị và chỉ được trình điều khiển WMI biết. Vì điều này
Bản thân trình điều khiển WMI chịu trách nhiệm phân tích cú pháp và xác thực dữ liệu nhận được từ nó.
Thiết bị WMI.

Cấu trúc của bộ đệm nói trên được mô tả bằng dữ liệu MOF được liên kết với thiết bị WMI trong
câu hỏi. Khi một bộ đệm như vậy chứa nhiều mục dữ liệu, việc định nghĩa một
Cấu trúc C và sử dụng nó trong quá trình phân tích cú pháp. Vì lõi trình điều khiển WMI đảm bảo rằng tất cả các bộ đệm
nhận được từ thiết bị WMI được căn chỉnh trên ranh giới 8 byte, trình điều khiển WMI có thể thực hiện một cách đơn giản
một sự chuyển đổi giữa dữ liệu bộ đệm WMI và cấu trúc C này.

Tuy nhiên, điều này chỉ nên được thực hiện sau khi kích thước của bộ đệm được xác minh là đủ lớn.
để giữ toàn bộ cấu trúc C. Trình điều khiển WMI nên từ chối bộ đệm có kích thước nhỏ hơn như thường lệ
được gửi bởi thiết bị WMI để báo hiệu lỗi bên trong. Tuy nhiên, bộ đệm quá khổ nên được chấp nhận
để mô phỏng hành vi triển khai Windows WMI.

Khi xác định cấu trúc C để phân tích bộ đệm WMI, việc căn chỉnh các mục dữ liệu phải là
được tôn trọng. Điều này đặc biệt quan trọng đối với số nguyên 64 bit vì chúng có cách sắp xếp khác nhau
trên kiến trúc 64-bit (căn chỉnh 8 byte) và 32-bit (căn chỉnh 4 byte). Vì thế đó là một ý tưởng tốt
để chỉ định thủ công việc căn chỉnh các mục dữ liệu đó hoặc đánh dấu toàn bộ cấu trúc là được đóng gói khi
thích hợp. Các mục dữ liệu số nguyên nói chung là các số nguyên endian nhỏ và phải được đánh dấu là
như vậy bằng cách sử dụng ZZ0000ZZ và bạn bè. Khi phân tích các mục dữ liệu chuỗi WMI, cấu trúc wmi_string sẽ
được sử dụng làm chuỗi WMI có bố cục khác với chuỗi C.

Xem Documentation/wmi/acpi-interface.rst để biết thêm thông tin về định dạng nhị phân
của các mục dữ liệu WMI.

Xử lý nhiều thiết bị WMI cùng một lúc
-------------------------------------

Có nhiều trường hợp nhà cung cấp firmware sử dụng nhiều thiết bị WMI để kiểm soát các khía cạnh khác nhau
của một thiết bị vật lý duy nhất. Điều này có thể làm cho việc phát triển trình điều khiển WMI trở nên phức tạp vì những trình điều khiển đó
có thể cần liên lạc với nhau để trình bày một giao diện thống nhất cho không gian người dùng.

Trong trường hợp như vậy liên quan đến thiết bị sự kiện WMI cần giao tiếp với thiết bị khối dữ liệu WMI hoặc WMI
thiết bị phương thức khi nhận được sự kiện WMI. Trong trường hợp như vậy, nên phát triển hai trình điều khiển WMI,
một cho thiết bị sự kiện WMI và một cho thiết bị WMI khác.

Trình điều khiển thiết bị sự kiện WMI chỉ có một mục đích: nhận các sự kiện WMI, xác thực mọi sự kiện bổ sung
dữ liệu sự kiện và gọi chuỗi thông báo. Trình điều khiển WMI khác tự thêm vào chuỗi thông báo này
trong quá trình thăm dò và do đó được thông báo mỗi khi nhận được sự kiện WMI. Trình điều khiển WMI này có thể
sau đó xử lý thêm sự kiện chẳng hạn bằng cách sử dụng thiết bị đầu vào.

Đối với các nhóm thiết bị WMI khác, có thể sử dụng các cơ chế tương tự.

Những điều cần tránh
---------------

Khi phát triển trình điều khiển WMI, có một số điều cần tránh:

- sử dụng giao diện WMI dựa trên GUID không dùng nữa, sử dụng GUID thay vì cấu trúc thiết bị WMI
- sử dụng giao diện WMI dựa trên ACPI không dùng nữa, sử dụng các đối tượng ACPI thay vì bộ đệm đơn giản
- bỏ qua hệ thống con WMI khi nói chuyện với các thiết bị WMI
- Trình điều khiển WMI không thể khởi tạo nhiều lần.

Nhiều trình điều khiển WMI cũ hơn vi phạm một hoặc nhiều điểm trong danh sách này. Lý do cho
đây là hệ thống con WMI đã phát triển đáng kể trong hai thập kỷ qua,
vì vậy có rất nhiều hành trình kế thừa bên trong trình điều khiển WMI cũ hơn.

Trình điều khiển WMI mới cũng được yêu cầu phải phù hợp với kiểu mã hóa hạt nhân linux như được chỉ định trong
Tài liệu/quy trình/coding-style.rst. Tiện ích checkpatch có thể bắt được nhiều kiểu mã hóa phổ biến
vi phạm, bạn có thể gọi nó bằng lệnh sau:

::

./scripts/checkpatch.pl --strict <đường dẫn đến tệp trình điều khiển>

Tài liệu tham khảo
==========

.. [1] https://lwn.net/Articles/391230/