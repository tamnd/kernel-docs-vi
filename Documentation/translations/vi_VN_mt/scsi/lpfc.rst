.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/lpfc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================
Ghi chú phát hành trình điều khiển LPFC
=======================================


.. important::

  Starting in the 8.0.17 release, the driver began to be targeted strictly
  toward the upstream kernel. As such, we removed #ifdefs for older kernels
  (pre 2.6.10). The 8.0.16 release should be used if the driver is to be
  run on one of the older kernels.

  The proposed modifications to the transport layer for FC remote ports
  and extended attribute support is now part of the upstream kernel
  as of 2.6.12. We no longer need to provide patches for this support,
  nor a *full* version which has old an new kernel support.
  
  The driver now requires a 2.6.12 (if pre-release, 2.6.12-rc1) or later
  kernel.
  
  Please heed these dependencies....


Thông tin sau đây được cung cấp để cung cấp thêm thông tin cơ bản về
lịch sử của trình điều khiển khi chúng tôi thúc đẩy sự chấp nhận ngược dòng.

Kéo cáp và thiết bị tạm thời Mất mát:

Trong các phiên bản cũ hơn của trình điều khiển lpfc, trình điều khiển đã xếp hàng đợi nội bộ i/o 
  nhận được từ lớp giữa. Trong trường hợp cáp bị kéo, liên kết
  giật hoặc thiết bị tạm thời mất kết nối (do cáp của nó
  bị xóa, khởi động lại switch hoặc khởi động lại thiết bị), trình điều khiển có thể
  ẩn sự biến mất của thiết bị khỏi lớp giữa. I/O được cấp cho
  LLDD sẽ chỉ được xếp hàng đợi trong một khoảng thời gian ngắn, cho phép thiết bị
  xuất hiện trở lại hoặc liên kết trở lại sống động mà không có tác dụng phụ ngoài ý muốn
  vào hệ thống. Nếu trình điều khiển không ẩn các điều kiện này, i/o sẽ là
  do trình điều khiển gây ra, lớp giữa sẽ hết số lần thử lại và
  thiết bị sẽ được đưa ngoại tuyến. Cần phải có sự can thiệp thủ công để
  kích hoạt lại thiết bị.

Cộng đồng hỗ trợ kernel.org đã nỗ lực loại bỏ
  xếp hàng nội bộ từ tất cả các LLDD. Triết lý là nội tại
  xếp hàng là không cần thiết vì lớp khối đã thực hiện 
  xếp hàng. Việc xóa hàng đợi khỏi LLDD giúp dễ dự đoán hơn
  và LLDD đơn giản hơn.

Là một bổ sung mới tiềm năng cho kernel.org, trình điều khiển 8.x được yêu cầu
  đã loại bỏ tất cả hàng đợi nội bộ. Emulex đã đáp ứng yêu cầu này.
  Để giải thích tác động của sự thay đổi này, Emulex đã làm việc với
  cộng đồng trong việc sửa đổi hành vi của lớp giữa SCSI để SCSI
  thiết bị có thể bị tạm dừng trong khi các sự kiện vận chuyển (chẳng hạn như
  những điều được mô tả) có thể xảy ra.

Bản vá được đề xuất đã được đăng lên danh sách gửi thư linux-scsi. Bản vá
  được chứa trong bộ vá 2.6.10-rc2 (và phiên bản mới hơn). Như vậy, điều này
  bản vá là một phần của kernel 2.6.10 tiêu chuẩn.

Theo mặc định, trình điều khiển mong đợi các bản vá cho giao diện chặn/bỏ chặn
  có mặt trong kernel. Không cần thiết lập #define để kích hoạt hỗ trợ.


Hỗ trợ hạt nhân
===============

Gói nguồn này chỉ dành cho kernel ngược dòng. (Xem ghi chú
  ở đầu tập tin này). Nó dựa vào các giao diện đang chậm lại
  di chuyển vào kernel kernel.org.

Tại thời điểm này, trình điều khiển yêu cầu 2.6.12 (nếu phát hành trước, 2.6.12-rc1)
  hạt nhân.

Nếu cần trình điều khiển cho các hạt nhân cũ hơn, vui lòng sử dụng phiên bản 8.0.16
  nguồn điều khiển.


Bản vá lỗi
==========

Rất may, tại thời điểm này, các bản vá không cần thiết.