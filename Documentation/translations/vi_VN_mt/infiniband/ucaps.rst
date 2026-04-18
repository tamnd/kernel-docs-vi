.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/infiniband/ucaps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Khả năng không gian người dùng Infiniband
=========================================

Khả năng của người dùng (UCAP) cung cấp khả năng kiểm soát chi tiết đối với các
   các tính năng phần sụn trong thiết bị Infiniband (IB). Cách tiếp cận này cung cấp
   các khả năng chi tiết hơn các khả năng hiện có của Linux,
   có thể quá chung chung đối với một số tính năng FW nhất định.

Mỗi khả năng của người dùng được biểu diễn dưới dạng một thiết bị ký tự có quyền root
   truy cập đọc-ghi. Quá trình root có thể cấp cho người dùng những đặc quyền đặc biệt
   bằng cách cho phép truy cập vào các thiết bị ký tự này (ví dụ: sử dụng chown).

Cách sử dụng
=====

UCAP cho phép kiểm soát các tính năng cụ thể của thiết bị IB bằng tệp
   mô tả của thiết bị ký tự UCAP. Đây là cách người dùng kích hoạt
   các tính năng cụ thể của thiết bị IB:

* Quá trình root cấp cho người dùng quyền truy cập vào các tệp UCAP
        đại diện cho các khả năng (ví dụ: sử dụng chown).
      * Người dùng mở tệp UCAP, lấy phần mô tả tệp.
      * Khi mở thiết bị IB, hãy bao gồm một mảng tệp UCAP
        mô tả như một thuộc tính.
      * Trình điều khiển ib_uverbs nhận dạng bộ mô tả tệp UCAP và cho phép
        các khả năng tương ứng cho thiết bị IB.

Tạo UCAP
==============

Để tạo UCAP mới, trước tiên trình điều khiển phải xác định loại trong
   rdma_user_cap enum trong rdma/ib_ucaps.h. Tên nhân vật UCAP
   thiết bị nên được thêm vào mảng ucap_names trong
   trình điều khiển/infiniband/core/ucaps.c. Sau đó, trình điều khiển có thể tạo UCAP
   thiết bị ký tự bằng cách gọi ib_create_ucap API bằng UCAP
   loại.

Số lượng tham chiếu được lưu trữ cho mỗi UCAP để theo dõi các sáng tạo và
   loại bỏ thiết bị UCAP. Nếu nhiều cuộc gọi tạo được thực hiện với
   cùng loại (ví dụ: đối với hai thiết bị IB), thiết bị ký tự UCAP
   được tạo trong cuộc gọi đầu tiên và các cuộc gọi tiếp theo sẽ tăng số lượng
   số lượng tham khảo

Thiết bị ký tự UCAP được tạo trong /dev/infiniband và
   quyền được đặt để chỉ cho phép quyền truy cập đọc và ghi gốc.

Loại bỏ UCAP
==============

Mỗi lần xóa sẽ làm giảm số lượng tham chiếu của UCAP. UCAP
   thiết bị ký tự chỉ bị xóa khỏi hệ thống tập tin khi
   số lượng tham chiếu giảm xuống 0.

các tập tin /dev và /sys/class
=========================

Lớp học::

/sys/class/infiniband_ucaps

được tạo khi thiết bị ký tự UCAP đầu tiên được tạo.

Thiết bị ký tự UCAP được tạo trong /dev/infiniband.

Ví dụ: nếu mlx5_ib thêm rdma_user_cap
   RDMA_UCAP_MLX5_CTRL_LOCAL có tên "mlx5_perm_ctrl_local", điều này sẽ
   tạo nút thiết bị::

/dev/infiniband/mlx5_perm_ctrl_local

