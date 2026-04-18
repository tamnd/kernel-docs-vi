.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/persistent-data.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Dữ liệu liên tục
=================

Giới thiệu
============

Các mục tiêu ánh xạ thiết bị phức tạp hơn yêu cầu siêu dữ liệu phức tạp
được quản lý trong kernel.  Vào cuối năm 2010, chúng tôi đã thấy nhiều
các mục tiêu khác nhau đang triển khai cấu trúc dữ liệu của riêng họ, ví dụ:

- Triển khai multisnap của Mikulas Patocka
- Mục tiêu dự phòng mỏng của Heinz Mauelshagen
- Một mục tiêu bộ nhớ đệm dựa trên btree khác được đăng lên dm-devel
- Một mục tiêu chụp nhanh khác dựa trên thiết kế của Daniel Phillips

Việc duy trì các cấu trúc dữ liệu này tốn rất nhiều công sức, vì vậy nếu có thể
chúng tôi muốn giảm số lượng.

Thư viện dữ liệu liên tục là một nỗ lực nhằm cung cấp một cơ chế có thể sử dụng lại
framework dành cho những người muốn lưu trữ siêu dữ liệu trong trình ánh xạ thiết bị
mục tiêu.  Nó hiện đang được sử dụng bởi mục tiêu cung cấp mỏng và
mục tiêu lưu trữ phân cấp sắp tới.

Tổng quan
========

Tài liệu chính nằm trong các tệp tiêu đề, tất cả đều có thể được tìm thấy
trong trình điều khiển/md/dữ liệu liên tục.

Người quản lý khối
-----------------

dm-block-manager.[hc]

Điều này cung cấp quyền truy cập vào dữ liệu trên đĩa theo các khối có kích thước cố định.  Ở đó
là giao diện khóa đọc/ghi để ngăn chặn các truy cập đồng thời và
giữ dữ liệu đang được sử dụng trong bộ đệm.

Khách hàng của dữ liệu liên tục không thể sử dụng trực tiếp điều này.

Người quản lý giao dịch
-----------------------

dm-giao dịch-quản lý. [hc]

Điều này hạn chế quyền truy cập vào các khối và thực thi ngữ nghĩa sao chép khi ghi.
Cách duy nhất bạn có thể nắm giữ một khối có thể ghi thông qua
người quản lý giao dịch bằng cách theo dõi một khối hiện có (tức là thực hiện
copy-on-write) hoặc phân bổ một cái mới.  Bóng tối được che đậy bên trong
cùng một giao dịch nên hiệu suất là hợp lý.  Phương thức cam kết
đảm bảo rằng tất cả dữ liệu được xóa trước khi ghi siêu khối.
Khi mất điện, siêu dữ liệu của bạn sẽ vẫn như cũ khi được cam kết lần cuối.

Bản đồ không gian
--------------

dm-space-map.h
dm-space-map-siêu dữ liệu.[hc]
dm-space-map-disk.[hc]

Cấu trúc dữ liệu trên đĩa theo dõi số lượng tham chiếu của các khối.
Cũng đóng vai trò là người cấp phát các khối mới.  Hiện nay hai
triển khai: một cách đơn giản hơn để quản lý các khối trên một thiết bị khác
thiết bị (ví dụ: khối dữ liệu được cung cấp mỏng); và một để quản lý
không gian siêu dữ liệu.  Cái sau phức tạp bởi nhu cầu lưu trữ
dữ liệu riêng của nó trong không gian nó đang quản lý.

Các cấu trúc dữ liệu
-------------------

dm-btree.[hc]
dm-btree-remove.c
dm-btree-spine.c
dm-btree-internal.h

Hiện tại chỉ có một cấu trúc dữ liệu, btree phân cấp.
Có kế hoạch để bổ sung thêm.  Ví dụ, một cái gì đó có
giao diện giống như mảng sẽ được sử dụng rất nhiều.

Btree có tính 'phân cấp' ở chỗ bạn có thể định nghĩa nó được cấu thành
của các cây btree lồng nhau và lấy nhiều khóa.  Ví dụ,
mục tiêu cung cấp mỏng sử dụng btree với hai cấp độ lồng nhau.
Cái đầu tiên ánh xạ id thiết bị vào cây ánh xạ và từ đó ánh xạ một
khối ảo thành khối vật lý.

Các giá trị được lưu trữ trong btrees có thể có kích thước tùy ý.  Chìa khóa luôn luôn
64bit, mặc dù việc lồng nhau cho phép bạn sử dụng nhiều phím.
