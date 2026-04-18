.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/surface_aggregator/clients/san.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. |san_client_link| replace:: :c:func:`san_client_link`
.. |san_dgpu_notifier_register| replace:: :c:func:`san_dgpu_notifier_register`
.. |san_dgpu_notifier_unregister| replace:: :c:func:`san_dgpu_notifier_unregister`

=====================
Bề mặt ACPI Thông báo
=====================

Thiết bị Surface ACPI Notify (SAN) cung cấp cầu nối giữa ACPI và
Bộ điều khiển SAM. Cụ thể, mã ACPI có thể thực hiện các yêu cầu và xử lý
các sự kiện về pin và nhiệt thông qua giao diện này. Ngoài ra, các sự kiện
liên quan đến GPU (dGPU) rời rạc của Surface Book 2 có thể được gửi từ
Mã ACPI (lưu ý: Surface Book 3 sử dụng phương pháp khác cho việc này). các
sự kiện duy nhất hiện được biết được gửi qua giao diện này là sự kiện bật nguồn dGPU
thông báo. Trong khi trình điều khiển này xử lý phần trước trong nội bộ, nó chỉ
chuyển tiếp các sự kiện dGPU tới bất kỳ trình điều khiển nào khác quan tâm thông qua API công khai của nó và
không xử lý chúng.

Giao diện chung của trình điều khiển này được chia thành hai phần: Máy khách
đăng ký và đăng ký khối thông báo.

Một máy khách với giao diện SAN có thể được liên kết với tư cách là người tiêu dùng với thiết bị SAN
thông qua ZZ0000ZZ. Điều này có thể được sử dụng để đảm bảo rằng khách hàng
nhận sự kiện dGPU không bỏ lỡ bất kỳ sự kiện nào do giao diện SAN không
được thiết lập vì điều này buộc trình điều khiển máy khách phải hủy liên kết sau khi trình điều khiển SAN
không bị ràng buộc.

Khối thông báo có thể được đăng ký bởi bất kỳ thiết bị nào miễn là mô-đun được
được tải, bất kể có được liên kết với tư cách khách hàng hay không. Đăng ký xong
với ZZ0000ZZ. Nếu trình thông báo không còn cần thiết nữa thì nó
nên hủy đăng ký thông qua ZZ0001ZZ.

Tham khảo tài liệu API bên dưới để biết thêm chi tiết.


Tài liệu API
=================

.. kernel-doc:: include/linux/surface_acpi_notify.h

.. kernel-doc:: drivers/platform/surface/surface_acpi_notify.c
    :export: