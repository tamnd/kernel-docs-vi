.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/slimbus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Hỗ trợ SLIMbus nhân Linux
============================

Tổng quan
========

SLIMbus là gì?
----------------
SLIMbus (Bus đa phương tiện liên chip công suất thấp nối tiếp) là một thông số kỹ thuật được phát triển bởi
Liên minh MIPI (Giao diện bộ xử lý công nghiệp di động). Bus sử dụng master/slave
cấu hình và là triển khai nhiều lần thả 2 dây (đồng hồ và dữ liệu).

Hiện tại, SLIMbus được sử dụng để giao tiếp giữa các bộ xử lý ứng dụng của SoC
(System-on-Chip) và các thành phần ngoại vi (thường là codec). SLIMbus sử dụng
Ghép kênh phân chia theo thời gian để chứa nhiều kênh dữ liệu và
một kênh điều khiển.

Kênh điều khiển được sử dụng cho nhiều chức năng điều khiển khác nhau như bus
quản lý, cấu hình và cập nhật trạng thái. Những tin nhắn này có thể là unicast (ví dụ:
giá trị cụ thể của thiết bị đọc/ghi) hoặc multicast (ví dụ: kênh dữ liệu
trình tự cấu hình lại là một tin nhắn quảng bá được thông báo tới tất cả các thiết bị)

Kênh dữ liệu được sử dụng để truyền dữ liệu giữa 2 thiết bị SLIMbus. dữ liệu
kênh sử dụng cổng chuyên dụng trên thiết bị.

Mô tả phần cứng:
---------------------
Đặc tả SLIMbus có các loại phân loại thiết bị khác nhau dựa trên
khả năng của họ.
Một thiết bị quản lý chịu trách nhiệm liệt kê, cấu hình và động
phân bổ kênh. Mỗi xe buýt có 1 người quản lý đang hoạt động.

Thiết bị chung là thiết bị cung cấp chức năng ứng dụng (ví dụ: codec).

Thiết bị Framer chịu trách nhiệm bấm giờ cho xe buýt và truyền đồng bộ khung
và đóng khung thông tin trên xe buýt.

Mỗi thành phần SLIMbus có một thiết bị giao diện để giám sát lớp vật lý.

Thông thường, mỗi SoC chứa thành phần SLIMbus có 1 trình quản lý, 1 thiết bị đóng khung,
1 thiết bị chung (để hỗ trợ kênh dữ liệu) và 1 thiết bị giao diện.
Thành phần SLIMbus ngoại vi bên ngoài thường có 1 thiết bị chung (đối với
hỗ trợ chức năng/kênh dữ liệu) và thiết bị giao diện liên quan.
Các thanh ghi của thiết bị chung được ánh xạ dưới dạng 'các phần tử giá trị' để chúng có thể
được ghi/đọc bằng cách sử dụng kênh điều khiển SLIMbus trao đổi loại điều khiển/trạng thái của
thông tin.
Trong trường hợp có nhiều thiết bị đóng khung trên cùng một bus, thiết bị quản lý sẽ
chịu trách nhiệm chọn khung hoạt động để tính giờ cho xe buýt.

Theo thông số kỹ thuật, SLIMbus sử dụng "bánh răng đồng hồ" để quản lý năng lượng dựa trên
yêu cầu về tần số và băng thông hiện tại. Có 10 bánh răng đồng hồ và mỗi bánh răng
bánh răng thay đổi tần số SLIMbus gấp đôi bánh răng trước đó của nó.

Mỗi thiết bị có một địa chỉ liệt kê 6 byte và người quản lý chỉ định mỗi
thiết bị có địa chỉ logic 1 byte sau khi thiết bị báo cáo sự hiện diện trên
xe buýt.

Mô tả phần mềm:
---------------------
Có 2 loại trình điều khiển SLIMbus:

slim_controller đại diện cho 'bộ điều khiển' cho SLIMbus. Người lái xe này nên
thực hiện các nhiệm vụ cần thiết của SoC (thiết bị quản lý, liên quan
thiết bị giao diện để giám sát các lớp và báo cáo lỗi, mặc định
thiết bị đóng khung).

slim_device đại diện cho 'thiết bị/thành phần chung' cho SLIMbus và
slim_driver nên triển khai trình điều khiển cho slim_device đó.

Thông báo thiết bị cho người lái xe:
-----------------------------------
Vì các thiết bị SLIMbus có cơ chế báo cáo sự hiện diện của chúng nên
framework cho phép trình điều khiển liên kết khi các thiết bị tương ứng báo cáo
sự hiện diện trên xe buýt.
Tuy nhiên, có thể cần phải thăm dò tài xế
trước tiên để nó có thể kích hoạt thiết bị SLIMbus tương ứng (ví dụ: bật nguồn và/hoặc
gỡ nó ra khỏi thiết lập lại). Để hỗ trợ hành vi đó, khung cho phép trình điều khiển
để thăm dò trước (ví dụ: sử dụng trường tương thích DeviceTree tiêu chuẩn).
Điều này tạo ra sự cần thiết cho người lái xe biết khi nào thiết bị hoạt động
(tức là báo cáo hiện tại). Lệnh gọi lại device_up được sử dụng vì lý do đó khi
báo cáo thiết bị hiện diện và được bộ điều khiển gán một địa chỉ logic.

Tương tự, các thiết bị SLIMbus 'báo cáo vắng mặt' khi chúng gặp sự cố. Một 'thiết bị_down'
gọi lại thông báo cho trình điều khiển khi thiết bị báo vắng mặt và tính logic của nó
việc gán địa chỉ bị vô hiệu bởi bộ điều khiển.

Một thông báo khác "boot_device" được sử dụng để thông báo cho slim_driver khi
bộ điều khiển khởi động lại bus. Thông báo này cho phép người lái xe thực hiện những việc cần thiết
các bước để khởi động thiết bị để thiết bị hoạt động sau khi bus được đặt lại.

API trình điều khiển và bộ điều khiển:
---------------------------
.. kernel-doc:: include/linux/slimbus.h
   :internal:

.. kernel-doc:: drivers/slimbus/slimbus.h
   :internal:

.. kernel-doc:: drivers/slimbus/core.c
   :export:

Đồng hồ tạm dừng:
------------
SLIMbus bắt buộc phải thực hiện trình tự cấu hình lại (được gọi là tạm dừng đồng hồ).
phát sóng tới tất cả các thiết bị đang hoạt động trên xe buýt trước khi xe buýt có thể chuyển sang chế độ năng lượng thấp
chế độ. Bộ điều khiển sử dụng trình tự này khi nó quyết định chuyển sang chế độ năng lượng thấp để
đồng hồ và/hoặc đường ray điện tương ứng có thể được tắt để tiết kiệm điện.
Việc tạm dừng đồng hồ được thoát bằng cách đánh thức thiết bị đóng khung (nếu trình điều khiển bộ điều khiển khởi động
thoát khỏi chế độ năng lượng thấp) hoặc bằng cách chuyển đổi đường dữ liệu (nếu thiết bị phụ muốn
để bắt đầu nó).

API tạm dừng đồng hồ:
~~~~~~~~~~~~~~~~~
.. kernel-doc:: drivers/slimbus/sched.c
   :export:

Nhắn tin:
----------
Khung hỗ trợ regmap và api đọc/ghi để trao đổi thông tin kiểm soát
với thiết bị SLIMbus. API có thể đồng bộ hoặc không đồng bộ.
Tệp tiêu đề <linux/slimbus.h> có thêm tài liệu về API nhắn tin.

API nhắn tin:
~~~~~~~~~~~~~~~
.. kernel-doc:: drivers/slimbus/messaging.c
   :export:

API truyền phát:
~~~~~~~~~~~~~~~
.. kernel-doc:: drivers/slimbus/stream.c
   :export:
