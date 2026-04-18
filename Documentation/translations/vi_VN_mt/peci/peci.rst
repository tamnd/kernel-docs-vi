.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/peci/peci.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
Tổng quan
========

Giao diện điều khiển môi trường nền tảng (PECI) là một giao tiếp
giao diện giữa bộ xử lý Intel và bộ điều khiển quản lý
(ví dụ: Bộ điều khiển quản lý ván chân tường, BMC).
PECI cung cấp các dịch vụ cho phép bộ điều khiển quản lý
cấu hình, giám sát và gỡ lỗi nền tảng bằng cách truy cập vào các thanh ghi khác nhau.
Nó định nghĩa một giao thức lệnh chuyên dụng, trong đó việc quản lý
bộ điều khiển hoạt động như một bộ khởi tạo PECI và bộ xử lý - như
một bộ phản hồi PECI.
PECI có thể được sử dụng trong cả bộ xử lý đơn và bộ xử lý đa
hệ thống.

NOTE:
Thông số kỹ thuật Intel PECI không được phát hành dưới dạng tài liệu chuyên dụng,
thay vào đó nó là một phần của Đặc tả thiết kế bên ngoài (EDS) dành cho
Intel CPU. Thông số kỹ thuật thiết kế bên ngoài thường không được công khai
có sẵn.

Dây PECI
---------

Giao diện Wire PECI sử dụng một dây duy nhất để tự đồng hồ và truyền dữ liệu
chuyển nhượng. Nó không yêu cầu bất kỳ dòng điều khiển bổ sung nào -
lớp vật lý là tín hiệu bus một dây tự định thời gian bắt đầu mỗi
bit có cạnh nhô lên được điều khiển từ trạng thái không tải gần 0 vôn. các
khoảng thời gian của tín hiệu được điều khiển ở mức cao cho phép xác định xem bit có
giá trị là logic '0' hoặc logic '1'. Dây PECI cũng bao gồm dữ liệu biến đổi
tỷ lệ được thiết lập với mỗi tin nhắn.

Đối với Dây PECI, mỗi gói bộ xử lý sẽ sử dụng duy nhất, cố định
địa chỉ trong một phạm vi xác định và địa chỉ đó sẽ
có mối quan hệ cố định với ID ổ cắm bộ xử lý - nếu một trong
bộ xử lý bị loại bỏ, nó không ảnh hưởng đến địa chỉ còn lại
bộ xử lý.

Nội bộ hệ thống con PECI
------------------------

.. kernel-doc:: include/linux/peci.h
.. kernel-doc:: drivers/peci/internal.h
.. kernel-doc:: drivers/peci/core.c
.. kernel-doc:: drivers/peci/request.c

Trình điều khiển PECI CPU API
-------------------
.. kernel-doc:: drivers/peci/cpu.c