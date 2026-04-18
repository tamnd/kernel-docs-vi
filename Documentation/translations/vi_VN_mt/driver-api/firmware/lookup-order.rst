.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/lookup-order.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Thứ tự tra cứu firmware
=====================

Chức năng khác nhau có sẵn để cho phép tìm thấy phần sụn.
Dưới đây là thứ tự thời gian về cách tìm kiếm phần sụn một lần
trình điều khiển phát ra lệnh gọi firmware API.

* ''Phần sụn tích hợp'' được kiểm tra trước tiên, nếu có phần sụn, chúng tôi sẽ
  trả lại nó ngay lập tức
* Phần tiếp theo sẽ được xem xét ''Bộ đệm phần sụn''. Nếu phần sụn được tìm thấy, chúng tôi
  trả lại nó ngay lập tức
* Việc ''Tra cứu hệ thống tập tin trực tiếp'' được thực hiện tiếp theo, nếu tìm thấy chúng tôi
  trả lại nó ngay lập tức
* ''Dự phòng phần sụn nền tảng'' được thực hiện tiếp theo, nhưng chỉ khi
  firmware_request_platform() đã được sử dụng, nếu tìm thấy chúng tôi sẽ trả lại ngay lập tức
* Nếu không tìm thấy phần sụn nào và cơ chế dự phòng đã được bật
  giao diện sysfs được tạo. Sau đó, một sự kiện kobject
  được phát hành hoặc việc tải chương trình cơ sở tùy chỉnh được dựa vào cho chương trình cơ sở
  tải đến giá trị thời gian chờ.
