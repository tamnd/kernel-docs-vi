.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/blockdev/nbd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Thiết bị chặn mạng (phiên bản TCP)
=====================================

1) Tổng quan
-----------

Nó là gì: Với cái này được biên dịch trong kernel (hoặc dưới dạng một mô-đun), Linux
có thể sử dụng máy chủ từ xa làm một trong các thiết bị khối của nó. Vì thế mỗi lần
máy khách muốn đọc, ví dụ: /dev/nb0, nó sẽ gửi một
yêu cầu qua TCP tới máy chủ, máy chủ sẽ trả lời bằng dữ liệu đã đọc.
Điều này có thể được sử dụng cho các trạm có dung lượng ổ đĩa thấp (hoặc thậm chí không có ổ đĩa)
để mượn dung lượng đĩa từ một máy tính khác.
Không giống như NFS, có thể đặt bất kỳ hệ thống tập tin nào trên đó, v.v.

Để biết thêm thông tin hoặc tải xuống nbd-client và nbd-server
công cụ, hãy truy cập ZZ0000ZZ

Mô-đun hạt nhân nbd chỉ cần được cài đặt trên máy khách
hệ thống, vì máy chủ nbd hoàn toàn nằm trong không gian người dùng. Trên thực tế,
máy chủ nbd đã được chuyển thành công sang hệ điều hành khác
hệ thống, bao gồm cả Windows.

A) Thông số NBD
-----------------

phần tối đa
	Số lượng phân vùng trên mỗi thiết bị (mặc định: 0).

nbds_max
	Số lượng thiết bị khối cần được khởi tạo (mặc định: 16).
