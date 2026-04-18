.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/accel/introduction.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Giới thiệu
=============

Hệ thống con tăng tốc tính toán Linux được thiết kế để hiển thị các
các bộ tăng tốc theo cách chung cho không gian người dùng và cung cấp một tập hợp chung
chức năng.

Các thiết bị này có thể là ASIC độc lập hoặc khối IP bên trong SoC/GPU.
Mặc dù các thiết bị này thường được thiết kế để tăng tốc
Tính toán Machine-Learning (ML) và/hoặc Deep-Learning (DL), lớp tăng tốc
không bị giới hạn trong việc xử lý các loại máy gia tốc này.

Thông thường, máy tăng tốc tính toán sẽ thuộc một trong các loại sau
loại:

- Edge AI - thực hiện suy luận trên thiết bị biên. Nó có thể là ASIC/FPGA được nhúng,
  hoặc IP bên trong SoC (ví dụ: web camera trên máy tính xách tay). Những thiết bị này
  thường được cấu hình bằng các thanh ghi và có thể hoạt động có hoặc không có DMA.

- Trung tâm dữ liệu suy luận - thiết bị đơn/đa người dùng trong một máy chủ lớn. Cái này
  loại thiết bị có thể độc lập hoặc IP bên trong SoC hoặc GPU. Nó sẽ
  có DRAM trên bo mạch (để giữ cấu trúc liên kết DL), động cơ DMA và
  hàng đợi gửi lệnh (hàng đợi kernel hoặc không gian người dùng).
  Nó cũng có thể có MMU để quản lý nhiều người dùng và cũng có thể cho phép
  ảo hóa (SR-IOV) để hỗ trợ nhiều VM trên cùng một thiết bị. trong
  Ngoài ra, các thiết bị này thường sẽ có một số công cụ như profiler và
  trình gỡ lỗi.

- Trung tâm dữ liệu huấn luyện - Tương tự như thẻ trung tâm dữ liệu suy luận, nhưng thông thường
  có nhiều sức mạnh tính toán và bộ nhớ b/w hơn (ví dụ HBM) và có thể sẽ có
  một phương pháp mở rộng/thu nhỏ, tức là kết nối với các thẻ đào tạo khác bên trong
  máy chủ hoặc trong các máy chủ khác, tương ứng.

Tất cả các thiết bị này thường có ngăn xếp phần mềm không gian người dùng thời gian chạy khác nhau,
được thiết kế riêng cho h/w của họ. Ngoài ra, có lẽ họ cũng sẽ
bao gồm một trình biên dịch để tạo ra các chương trình tính toán tùy chỉnh
động cơ. Thông thường, lớp chung trong không gian người dùng sẽ là các khung DL,
chẳng hạn như PyTorch và TensorFlow.

Chia sẻ mã với DRM
=====================

Bởi vì loại thiết bị này có thể là IP bên trong GPU hoặc có các đặc tính tương tự
giống như các GPU, hệ thống con accel sẽ sử dụng
Mã và chức năng của hệ thống con DRM. tức là mã lõi accel sẽ
là một phần của hệ thống con DRM và thiết bị tăng tốc sẽ là một loại DRM mới
thiết bị.

Điều này sẽ cho phép chúng tôi tận dụng cơ sở mã DRM mở rộng và
cộng tác với các nhà phát triển DRM có kinh nghiệm với loại hình này
thiết bị. Ngoài ra, các tính năng mới sẽ được thêm vào cho máy gia tốc
trình điều khiển cũng có thể được sử dụng cho trình điều khiển GPU.

Sự khác biệt với GPU
=========================

Bởi vì chúng tôi muốn ngăn chặn việc sử dụng quá nhiều phần mềm đồ họa trong không gian người dùng
từ việc cố gắng sử dụng máy gia tốc làm GPU, máy gia tốc điện toán sẽ
khác biệt với GPU bằng cách sử dụng số chính mới và tệp char thiết bị mới.

Hơn nữa, các trình điều khiển sẽ được đặt ở một nơi riêng biệt trong kernel
cây - trình điều khiển/accel/.

Các thiết bị tăng tốc sẽ được tiếp xúc với không gian người dùng bằng giao diện chuyên dụng
261 số chính và sẽ có quy ước sau:

- tập tin char thiết bị - /dev/accel/accel\*
- sysfs - /sys/class/accel/accel\*/
- debugfs - /sys/kernel/debug/accel/\*/

Bắt đầu
===============

Trước tiên, hãy đọc tài liệu DRM tại Documentation/gpu/index.rst.
Nó không chỉ giải thích cách viết trình điều khiển DRM mới mà còn
chứa tất cả thông tin về cách đóng góp, Quy tắc ứng xử và
phong cách/tài liệu mã hóa là gì. Tất cả điều đó đều giống nhau đối với
hệ thống con tăng tốc.

Thứ hai, đảm bảo kernel được cấu hình bằng CONFIG_DRM_ACCEL.

Để hiển thị thiết bị của bạn dưới dạng máy gia tốc, cần có hai thay đổi để
được thực hiện trong trình điều khiển của bạn (trái ngược với trình điều khiển DRM tiêu chuẩn):

- Thêm cờ tính năng DRIVER_COMPUTE_ACCEL vào drm_driver's của bạn
  trường driver_features. Điều quan trọng cần lưu ý là tính năng trình điều khiển này
  loại trừ lẫn nhau với DRIVER_RENDER và DRIVER_MODESET. Các thiết bị muốn
  để hiển thị cả tệp char đồ họa và thiết bị máy tính phải được xử lý bởi
  hai trình điều khiển được kết nối bằng khung bus phụ.

- Thay đổi lệnh gọi lại mở trong cấu trúc fops trình điều khiển của bạn thành accel_open().
  Ngoài ra, trình điều khiển của bạn có thể sử dụng macro DEFINE_DRM_ACCEL_FOPS để dễ dàng
  thiết lập cấu trúc con trỏ hoạt động chức năng chính xác.

Tài liệu tham khảo bên ngoài
===================

chủ đề email
-------------

* ZZ0000ZZ - Oded Gabbay (2022)
* ZZ0001ZZ - Oded Gabbay (2022)

Hội nghị tọa đàm
----------------

* ZZ0000ZZ - Dave Airlie (2022)