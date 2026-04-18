.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/w1/masters/omap-hdq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Trình điều khiển hạt nhân cho mô-đun omap HDQ/1 dây
========================================

Chip được hỗ trợ:
================
Bộ điều khiển HDQ/1 dây trên nền tảng TI OMAP 2430/3430.

Một liên kết hữu ích về những điều cơ bản về HDQ:
===============================
ZZ0000ZZ

Sự miêu tả:
============
Mô-đun HDQ/1-Wire của nền tảng TI OMAP2430/3430 triển khai phần cứng
giao thức của các chức năng chính của Benchmark HDQ và Dallas
Giao thức 1-Dây bán dẫn. Các giao thức này sử dụng một dây duy nhất cho
giao tiếp giữa chủ (HDQ/bộ điều khiển 1-Wire) và nô lệ
(Thiết bị tương thích bên ngoài HDQ/1-Wire).

Một ứng dụng điển hình của mô-đun HDQ/1-Wire là giao tiếp với pin
mạch tích hợp giám sát (đồng hồ đo khí).

Bộ điều khiển hỗ trợ hoạt động ở cả chế độ HDQ và 1 dây. Điều thiết yếu
sự khác biệt giữa chế độ HDQ và chế độ 1 dây là cách thiết bị phụ phản hồi với
xung khởi tạo. Ở chế độ HDQ, phần sụn không yêu cầu máy chủ phải
tạo xung khởi tạo cho nô lệ. Tuy nhiên, nô lệ có thể được thiết lập lại bằng cách
sử dụng xung khởi tạo (còn được gọi là xung ngắt). xung phụ
không phản hồi với xung hiện diện như trong giao thức 1-Dây.

Nhận xét:
========
Trình điều khiển (drivers/w1/masters/omap_hdq.c) hỗ trợ chế độ HDQ của
bộ điều khiển. Ở chế độ này, vì chúng tôi không thể đọc ID tuân theo W1
spec(family:id:crc), một tham số mô-đun có thể được chuyển tới trình điều khiển sẽ
được sử dụng để tính toán CRC và gửi lại ID nô lệ thích hợp cho W1
cốt lõi.

Theo mặc định, trình điều khiển chính và i/f phụ thuộc BQ
driver(drivers/w1/slaves/w1_bq27000.c) đặt ID thành 1.
Vui lòng lưu ý tải cả hai mô-đun bằng ID khác nếu được yêu cầu, nhưng lưu ý
rằng ID được sử dụng phải giống nhau khi tải cả trình điều khiển chính và phụ.

ví dụ::

insmod omap_hdq.ko W1_ID=2
  insmod w1_bq27000.ko F_ID=2

Trình điều khiển cũng hỗ trợ chế độ 1 dây. Ở chế độ này, không cần
chuyển ID nô lệ làm tham số. Trình điều khiển sẽ tự động phát hiện các nô lệ được kết nối
tới xe buýt bằng thủ tục SEARCH_ROM. Chế độ 1 dây có thể được chọn bằng cách
đặt thuộc tính "ti,mode" thành "1w" trong DT (xem
Documentation/devicetree/binds/w1/omap-hdq.txt để biết thêm chi tiết).
Theo mặc định, trình điều khiển ở chế độ HDQ.
