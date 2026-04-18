.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/ti/icssg_prueth.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Trình điều khiển ethernet ICSSG PRUETH của Texas Instruments
==============================================

:Phiên bản: 1.0

Phần mềm ICSSG
==============

Mỗi lõi ICSSG có hai Đơn vị thời gian thực có thể lập trình (PRU), hai thiết bị phụ trợ
Đơn vị truyền thời gian thực (RTU) và hai Đơn vị truyền thời gian thực truyền
(TX_PRU). Mỗi cái này chạy phần sụn riêng. Các phần cứng được kết hợp là
được gọi là Phần mềm ICSSG.

Thống kê phần sụn
===================

Phần sụn ICSSG duy trì số liệu thống kê nhất định được trình điều khiển kết xuất
thông qua ZZ0000ZZ

Những thống kê này như sau,

- ZZ0000ZZ: Bộ đếm lỗi chẩn đoán tăng lên khi RTU đánh rơi gói được đưa vào cục bộ do cổng bị vô hiệu hóa hoặc vi phạm quy tắc.
 - ZZ0001ZZ: Bộ đếm tràn TX cho queue0
 - ZZ0002ZZ: Bộ đếm tràn TX cho queue1
 - ZZ0003ZZ: Bộ đếm tràn TX cho queue2
 - ZZ0004ZZ: Bộ đếm tràn TX cho queue3
 - ZZ0005ZZ: Bộ đếm tràn TX cho queue4
 - ZZ0006ZZ: Bộ đếm tràn TX cho queue5
 - ZZ0007ZZ: Bộ đếm tràn TX cho queue6
 - ZZ0008ZZ: Bộ đếm tràn TX cho queue7
 - ZZ0009ZZ: Bộ đếm này tăng lên khi một gói tin bị rớt tại PRU do vi phạm quy tắc.
 - ZZ0010ZZ: Tăng nếu có lỗi CRC hoặc lỗi khung Min/Max tại PRU
 - ZZ0011ZZ: Tăng lên khi RTU phát hiện trạng thái Data Status không hợp lệ
 - ZZ0012ZZ: Bộ đếm gói tin bị rớt qua cổng TX
 - ZZ0013ZZ: Bộ đếm các gói tin có cờ TS bị rớt qua cổng TX
 - ZZ0014ZZ: Tăng khi khung RX bị rớt do cổng bị vô hiệu hóa
 - ZZ0015ZZ: Tăng khi khung RX bị rớt do vi phạm Địa chỉ nguồn
 - ZZ0016ZZ: Tăng khi khung RX bị loại bỏ do Địa chỉ nguồn nằm trong danh sách từ chối
 - ZZ0017ZZ: Tăng khi khung RX bị rớt do cổng bị chặn và khung là khung đặc biệt
 - ZZ0018ZZ : Tăng lên khi khung RX bị hủy do được gắn thẻ
 - ZZ0019ZZ: Tăng khi khung RX bị loại bỏ để được gắn thẻ ưu tiên
 - ZZ0020ZZ: Tăng khi khung RX bị bỏ do không được gắn thẻ
 - ZZ0021ZZ: Tăng khi khung RX bị loại bỏ do cổng không phải là thành viên của VLAN
 - ZZ0022ZZ: Tăng lên nếu tác vụ End Of Frame (EOF) được lên lịch mà không thấy RX_B1
 - ZZ0023ZZ: Tăng khi khung hình bị rớt do EOF sớm
 - ZZ0024ZZ: Tăng khi cắt khung để ngăn kích thước gói > 2000 Byte
 - ZZ0025ZZ: Tăng lên khi nhận được khung tốc độ cao trong cùng hàng đợi với đoạn trước đó
 - ZZ0026ZZ: Bộ đếm tràn RX fifo
 - ZZ0027ZZ: Tăng dần khi gói được chuyển tiếp bằng phương pháp chuyển tiếp Cut-Through
 - ZZ0028ZZ: Số gói tin hợp lệ được Rx PRU gửi đến Host trên PSI
 - ZZ0029ZZ: Số lượng gói tin hợp lệ được RTU0 sao chép vào hàng đợi Tx
 - ZZ0030ZZ: Bộ đếm tràn máy chủ Q (có thể sử dụng trước)
 - ZZ0031ZZ: Bộ đếm tràn máy chủ Q (có thể sử dụng trước)