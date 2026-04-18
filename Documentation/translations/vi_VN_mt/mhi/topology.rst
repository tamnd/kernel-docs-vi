.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mhi/topology.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Cấu trúc liên kết MHI
=====================

Tài liệu này cung cấp thông tin về mô hình cấu trúc liên kết MHI và
biểu diễn trong kernel.

Bộ điều khiển MHI
--------------

Trình điều khiển bộ điều khiển MHI quản lý sự tương tác với các thiết bị khách MHI
chẳng hạn như modem ngoài và chipset WiFi. Nó cũng là chủ xe buýt MHI
chịu trách nhiệm quản lý liên kết vật lý giữa máy chủ và thiết bị.
Tuy nhiên, nó không liên quan đến việc truyền dữ liệu thực tế vì việc truyền dữ liệu
được chăm sóc bởi bus vật lý như PCIe. Mỗi trình điều khiển bộ điều khiển hiển thị
các kênh và sự kiện dựa trên loại thiết bị khách hàng.

Dưới đây là vai trò của trình điều khiển bộ điều khiển MHI:

* Bật bus vật lý và thiết lập liên kết đến thiết bị
* Định cấu hình IRQ, IOMMU và IOMEM
* Phân bổ struct mhi_controller và đăng ký với khung bus MHI
  với cấu hình kênh và sự kiện bằng mhi_register_controller.
* Bắt đầu trình tự bật và tắt nguồn
* Bắt đầu tạm dừng và tiếp tục hoạt động quản lý nguồn điện của thiết bị.

Thiết bị MHI
----------

Thiết bị MHI là thiết bị logic liên kết với tối đa hai kênh MHI
cho giao tiếp hai chiều. Khi MHI ở trạng thái bật nguồn, MHI
core sẽ tạo các thiết bị MHI dựa trên cấu hình kênh được hiển thị
bởi bộ điều khiển. Có thể có một thiết bị MHI duy nhất cho mỗi kênh hoặc cho một
vài kênh.

Mỗi thiết bị được hỗ trợ được liệt kê trong::

/sys/bus/mhi/thiết bị/

Trình điều khiển MHI
----------

Trình điều khiển MHI là trình điều khiển máy khách liên kết với một hoặc nhiều thiết bị MHI. MHI
trình điều khiển gửi và nhận các gói giao thức lớp trên như gói IP,
thông báo điều khiển modem và thông báo chẩn đoán trên MHI. Lõi MHI sẽ
liên kết các thiết bị MHI với trình điều khiển MHI.

Mỗi trình điều khiển được hỗ trợ được liệt kê trong::

/sys/bus/mhi/trình điều khiển/

Dưới đây là vai trò của trình điều khiển MHI:

* Đăng ký trình điều khiển với khung bus MHI bằng mhi_driver_register.
* Chuẩn bị thiết bị để chuyển bằng cách gọi mhi_prepare_for_transfer.
* Bắt đầu truyền dữ liệu bằng cách gọi mhi_queue_transfer.
* Sau khi quá trình truyền dữ liệu kết thúc, hãy gọi mhi_unprepare_from_transfer tới
  kết thúc việc truyền dữ liệu.