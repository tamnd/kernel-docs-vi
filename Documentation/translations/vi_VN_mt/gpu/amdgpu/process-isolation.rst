.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/process-isolation.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
 Cách ly quy trình AMDGPU
===========================

Trình điều khiển AMDGPU bao gồm một tính năng cho phép cách ly quy trình tự động trên công cụ đồ họa. Tính năng này tuần tự hóa quyền truy cập vào công cụ đồ họa và thêm trình đổ bóng rõ ràng hơn để xóa Kho dữ liệu cục bộ (LDS) và Thanh ghi mục đích chung (GPR) giữa các công việc. Tất cả các quy trình sử dụng GPU, bao gồm cả khối lượng công việc đồ họa và điện toán, đều được tuần tự hóa khi tính năng này được bật. Trên các GPU hỗ trợ công cụ đồ họa có thể phân vùng, tính năng này có thể được bật trên cơ sở từng phân vùng.

Ngoài ra, còn có giao diện để chạy thủ công trình đổ bóng sạch hơn khi quá trình sử dụng GPU hoàn tất. Điều này có thể thích hợp hơn trong một số trường hợp sử dụng, chẳng hạn như hệ thống một người dùng trong đó trình quản lý đăng nhập sẽ kích hoạt trình đổ bóng sạch hơn khi người dùng đăng xuất.

Cách ly quy trình
=================

Giao diện sysfs ZZ0000ZZ và ZZ0001ZZ cho phép người dùng thực thi thủ công trình đổ bóng sạch hơn và kiểm soát tính năng cách ly quy trình tương ứng.

Xử lý phân vùng
------------------

Tệp ZZ0000ZZ trong sysfs có thể được sử dụng để cho phép cách ly quy trình và dọn dẹp trình đổ bóng tự động giữa các quy trình. Trên các GPU hỗ trợ phân vùng công cụ đồ họa, tính năng này có thể được bật cho mỗi phân vùng. Phân vùng và cài đặt hiện tại của nó (0 bị tắt, 1 được bật) có thể được đọc từ sysfs. Trên các GPU không hỗ trợ phân vùng công cụ đồ họa, sẽ chỉ có một phân vùng duy nhất. Ghi 1 vào vị trí phân vùng cho phép thực thi cách ly, ghi 0 sẽ vô hiệu hóa nó.

Ví dụ về việc kích hoạt cách ly thực thi trên GPU có nhiều phân vùng:

.. code-block:: console

    $ echo 1 0 1 0 > /sys/class/drm/card0/device/enforce_isolation
    $ cat /sys/class/drm/card0/device/enforce_isolation
    1 0 1 0

Đầu ra chỉ ra rằng cách ly thực thi được bật trên phân vùng thứ 0 và thứ hai và bị tắt trên phân vùng thứ nhất và thứ ba.

Đối với các thiết bị có một phân vùng duy nhất hoặc những thiết bị không hỗ trợ phân vùng sẽ chỉ có một thành phần:

.. code-block:: console

    $ echo 1 > /sys/class/drm/card0/device/enforce_isolation
    $ cat /sys/class/drm/card0/device/enforce_isolation
    1

Thực thi Shader sạch hơn
========================

Trình điều khiển có thể kích hoạt trình đổ bóng sạch hơn để dọn sạch trạng thái LDS và GPR trên công cụ đồ họa. Khi cách ly quy trình được bật, điều này sẽ tự động xảy ra giữa các quy trình. Ngoài ra, còn có tệp sysfs để kích hoạt thực thi trình đổ bóng sạch hơn theo cách thủ công.

Để kích hoạt thủ công việc thực thi trình đổ bóng sạch hơn, hãy ghi ZZ0000ZZ vào tệp sysfs ZZ0001ZZ:

.. code-block:: console

    $ echo 0 > /sys/class/drm/card0/device/run_cleaner_shader

Đối với các thiết bị có nhiều phân vùng, bạn có thể chỉ định chỉ mục phân vùng khi kích hoạt trình đổ bóng sạch hơn:

.. code-block:: console

    $ echo 0 > /sys/class/drm/card0/device/run_cleaner_shader # For partition 0
    $ echo 1 > /sys/class/drm/card0/device/run_cleaner_shader # For partition 1
    $ echo 2 > /sys/class/drm/card0/device/run_cleaner_shader # For partition 2
    # ... and so on for each partition

Lệnh này khởi tạo trình đổ bóng sạch hơn, trình đổ bóng này sẽ chạy và hoàn thành trước khi bất kỳ tác vụ mới nào được lên lịch trên GPU.