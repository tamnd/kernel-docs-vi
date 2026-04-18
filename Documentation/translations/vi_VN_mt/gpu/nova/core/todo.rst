.. SPDX-License-Identifier: (GPL-2.0+ OR MIT)

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/nova/core/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========
Danh sách nhiệm vụ
=========

Nhiệm vụ có thể có các trường sau:

- ZZ0000ZZ: Mô tả mức độ làm quen cần thiết với Rust và/hoặc
  API hạt nhân hoặc hệ thống con tương ứng. Có bốn sự phức tạp khác nhau,
  ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ và ZZ0004ZZ.
- ZZ0005ZZ: Tham khảo các công việc khác.
- ZZ0006ZZ: Liên kết tới các nguồn bên ngoài.
- ZZ0007ZZ: Người có thể liên hệ để biết thêm thông tin về
  nhiệm vụ.

Một tác vụ có thể có mã ZZ0000ZZ sau tên của nó. Mã này có thể được sử dụng để grep
vào mã cho các mục ZZ0001ZZ liên quan đến nó.

Kích hoạt (Rỉ sét)
=================

Các nhiệm vụ không liên quan trực tiếp đến nova-core nhưng là điều kiện tiên quyết về mặt
của các API cần thiết.

TừAPI nguyên thủy [FPRI]
------------------------

Đôi khi nảy sinh nhu cầu chuyển đổi một số thành giá trị của một enum hoặc một
cấu trúc.

Một ví dụ điển hình từ nova-core là loại enum ZZ0000ZZ, định nghĩa
giá trị ZZ0001ZZ. Khi thăm dò GPU, giá trị ZZ0002ZZ có thể được đọc từ một
chỉ báo đăng ký nhất định của chipset AD102. Do đó, giá trị enum ZZ0003ZZ
phải được bắt nguồn từ số ZZ0004ZZ. Hiện tại, nova-core sử dụng một tùy chỉnh
triển khai (ZZ0005ZZ cho việc này.

Thay vào đó, bạn nên có một cái gì đó giống như ZZ0000ZZ
đặc điểm [1] từ thùng số.

Việc khái quát hóa này cũng giúp triển khai một macro chung
tự động tạo ánh xạ tương ứng giữa một giá trị và một số.

Hỗ trợ FromPrimitive đã được thực hiện trước đây nhưng chưa được thực hiện
kể từ đó [1].

Cũng đã có những cân nhắc về ToPrimitive [2].

| Độ phức tạp: Sơ cấp
| Liên kết: ZZ0000ZZ
| Liên kết: ZZ0001ZZ [1]
| Liên kết: ZZ0002ZZ [2]

Các phép toán số [NUMM]
---------------------------

Nova sử dụng các phép toán số nguyên không phải là một phần của thư viện chuẩn (hoặc không
được triển khai theo cách tối ưu hóa cho kernel). Chúng bao gồm:

- Chức năng "Find Last Set Bit" (chức năng ZZ0000ZZ của phần C của kernel)
  hoạt động.

Mô-đun hạt nhân lõi ZZ0000ZZ đang được thiết kế để cung cấp các hoạt động này.

| Độ phức tạp: Trung cấp
| Liên hệ: Alexandre Courbot

Trừu tượng hóa trang cho các trang nước ngoài
----------------------------------

Sự trừu tượng hóa Rust cho các trang không được tạo bởi sự trừu tượng hóa trang Rust mà không có
sở hữu trực tiếp.

Có công việc đang diễn ra tích cực từ Abdiel Janulgue [1] và Lina [2].

| Độ phức tạp: Nâng cao
| Liên kết: ZZ0000ZZ [1]
| Liên kết: ZZ0001ZZ [2]

API PCI MISC
-------------

Mở rộng bản tóm tắt trình điều khiển / thiết bị PCI hiện có bằng SR-IOV, khả năng, MSI
Tóm tắt API.

SR-IOV [1] đang được hoàn thiện.

| Độ phức tạp: Sơ cấp
| Liên kết: ZZ0000ZZ [1]

GPU (chung)
=============

Hỗ trợ Devinit ban đầu
-----------------------

Triển khai Khởi tạo thiết bị BIOS, tức là định cỡ bộ nhớ, chờ đợi, PLL
cấu hình.

| Liên hệ: Dave Airlie
| Độ phức tạp: Sơ cấp

Quản lý MMU / PT
-------------------

Xây dựng kiến ​​trúc để quản lý bảng MMU/trang.

Chúng ta cần cân nhắc rằng nova-drm sẽ cần khả năng kiểm soát khá chi tiết,
đặc biệt là về mặt khóa, để có thể triển khai không đồng bộ
Hàng đợi Vulkan.

Mặc dù việc chia sẻ mã tương ứng nói chung là điều mong muốn nhưng nó cần phải được
đã đánh giá cách thức (và nếu có) việc chia sẻ mã tương ứng là phù hợp.

| Độ phức tạp: Chuyên gia

Bộ cấp phát bộ nhớ VRAM
---------------------

Điều tra các tùy chọn cho bộ cấp phát bộ nhớ VRAM.

Một số tùy chọn có thể:
  - Trừu tượng rỉ sét cho
    - Cây RB (cây khoảng)/drm_mm
    - cây phong
  - bộ sưu tập Rust bản địa

Đang tiến hành sử dụng drm_buddy [1].

| Độ phức tạp: Nâng cao
| Liên kết: ZZ0000ZZ [1]

Bộ nhớ phiên bản
---------------

Triển khai hỗ trợ cho instmem (bar2) dùng để lưu trữ bảng trang.

| Độ phức tạp: Trung cấp
| Liên hệ: Dave Airlie

Bộ xử lý hệ thống GPU (GSP)
==========================

Xuất bộ đệm nhật ký GSP
----------------------

Các bản vá gần đây từ Timur Tabi [1] đã thêm hỗ trợ để hiển thị bộ đệm nhật ký GSP-RM
(ngay cả sau khi không thăm dò được trình điều khiển) thông qua debugfs.

Đây cũng là một tính năng thú vị dành cho nova-core, đặc biệt là trong những ngày đầu.

| Liên kết: ZZ0000ZZ [1]
| Tham khảo: Tóm tắt Debugfs
| Độ phức tạp: Trung cấp

Tóm tắt phần mềm GSP
------------------------

Phần sụn GSP-RM API không ổn định và có thể thay đổi không tương thích giữa các phiên bản
phiên bản, về mặt cấu trúc dữ liệu và ngữ nghĩa.

Vấn đề này là một trong những động lực lớn để sử dụng Rust cho nova-core, vì
hóa ra tính năng macro thủ tục của Rust cung cấp một cách khá tao nhã
để giải quyết vấn đề này:

1. tạo cấu trúc Rust từ tiêu đề C trong một không gian tên riêng cho mỗi phiên bản
2. xây dựng các cấu trúc trừu tượng (trong một không gian tên chung) để triển khai
   giao diện phần sụn; chú thích sự khác biệt trong việc triển khai với phiên bản
   số nhận dạng
3. sử dụng macro thủ tục để tạo ra triển khai thực tế cho mỗi phiên bản
   sự trừu tượng này
4. khởi tạo đúng loại phiên bản một trong thời gian chạy (có thể chắc chắn rằng tất cả
   có cùng giao diện vì nó được xác định bởi một đặc điểm chung)

Có một triển khai PoC của mẫu này, trong bối cảnh lõi nova
Trình điều khiển PoC.

Nhiệm vụ này nhằm mục đích tinh chỉnh tính năng và khái quát hóa nó một cách lý tưởng để có thể sử dụng được.
bởi các trình điều khiển khác là tốt.

| Độ phức tạp: Chuyên gia

Hàng đợi tin nhắn GSP
-----------------

Triển khai hàng đợi tin nhắn GSP cấp thấp (lệnh, trạng thái) để liên lạc
giữa trình điều khiển kernel và GSP.

| Độ phức tạp: Nâng cao
| Liên hệ: Dave Airlie

Khởi động GSP
-------------

Gọi phần sụn khởi động để khởi động bộ xử lý GSP; thực hiện kiểm soát ban đầu
tin nhắn.

| Độ phức tạp: Trung cấp
| Liên hệ: Dave Airlie

API máy khách/thiết bị
--------------------

Triển khai giao diện thông báo GSP để phân bổ máy khách/thiết bị và
API phân bổ thiết bị và ứng dụng khách tương ứng.

| Độ phức tạp: Trung cấp
| Liên hệ: Dave Airlie

Thanh xử lý PDE
----------------

Đồng bộ hóa việc xử lý bảng trang cho BAR giữa trình điều khiển kernel và GSP.

| Độ phức tạp: Sơ cấp
| Liên hệ: Dave Airlie

Động cơ FIFO
-----------

Triển khai hỗ trợ cho công cụ FIFO, tức là thông báo GSP tương ứng
giao diện và cung cấp API để phân bổ con và xử lý kênh.

| Độ phức tạp: Nâng cao
| Liên hệ: Dave Airlie

động cơ GR
---------

Triển khai hỗ trợ cho công cụ đồ họa, tức là thông báo GSP tương ứng
giao diện và cung cấp API để tạo và quảng bá bối cảnh (vàng).

| Độ phức tạp: Nâng cao
| Liên hệ: Dave Airlie

Động cơ CE
---------

Triển khai hỗ trợ cho công cụ sao chép, tức là thông báo GSP tương ứng
giao diện.

| Độ phức tạp: Trung cấp
| Liên hệ: Dave Airlie

Bộ điều khiển VFN IRQ
------------------

Hỗ trợ bộ điều khiển ngắt VFN.

| Độ phức tạp: Trung cấp
| Liên hệ: Dave Airlie

API bên ngoài
=============

cơ sở lõi nova API
------------------

Tìm ra các phần chung của API để kết nối trình điều khiển cấp 2, tức là vGPU
quản lý và nova-drm.

| Độ phức tạp: Nâng cao

Trình quản lý vGPU API
----------------

Tìm ra các phần API theo yêu cầu của người quản lý vGPU, những phần không được đề cập trong
cơ sở API.

| Độ phức tạp: Nâng cao

lõi nova C API
---------------

Triển khai trình bao bọc C cho các API mà trình điều khiển trình quản lý vGPU yêu cầu.

| Độ phức tạp: Trung cấp

Kiểm tra
=======

đường ống CI
-----------

Tùy chọn điều tra để thử nghiệm tích hợp liên tục.

Điều này có thể đi từ đơn giản như chạy thử nghiệm KUnit qua chạy (đồ họa) CTS đến
khởi động (nhiều) máy ảo khách để kiểm tra các trường hợp sử dụng VFIO.

Cũng có thể đáng để xem xét trực tiếp việc giới thiệu một bộ thử nghiệm mới
quản lý uAPI để kiểm tra và gỡ lỗi có mục tiêu hơn. Có thể có
các tùy chọn cộng tác/chia sẻ mã với dự án Mesa.

| Độ phức tạp: Nâng cao