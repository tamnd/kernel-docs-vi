.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/rkisp1.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển bộ xử lý tín hiệu hình ảnh Rockchip (rkisp1)
===================================================

Các phiên bản và sự khác biệt của chúng
------------------------------

Khối rkisp1 đã trải qua một số thay đổi giữa các lần triển khai SoC.
Nhà cung cấp chỉ định chúng là:

- V10: được sử dụng ít nhất trong rk3288 và rk3399
- V11: khai báo theo mã nhà cung cấp ban đầu nhưng chưa được sử dụng
- V12: được sử dụng ít nhất trong rk3326 và px30
- V13: được sử dụng ít nhất trong rk1808
- V20: được sử dụng trong rk3568 trở lên

Hiện tại kernel hỗ trợ triển khai rkisp1 dựa trên
trên các biến thể V10 và V12. V11 dường như không thực sự được sử dụng
và V13 sẽ cần thêm một số bổ sung nhưng chưa được nghiên cứu,
đặc biệt là vì nó dường như bị giới hạn ở rk1808 chưa có
đạt được nhiều thị trường phổ biến.

Mặt khác, V20 có thể sẽ được sử dụng trong các SoC và
đã thấy những thay đổi thực sự lớn trong nhân của nhà cung cấp, vì vậy sẽ cần
khá nhiều nghiên cứu.

Thay đổi từ V10 thành V12
-----------------------

- V12 hỗ trợ triển khai máy chủ CSI mới nhưng vẫn có thể
  cũng sử dụng cách triển khai tương tự từ V10
- Mô-đun điều chỉnh độ bóng của ống kính đã được thay đổi
  chiều rộng từ 12bit đến 13bit
- Các mô-đun AWB và AEC đã được thay thế để hỗ trợ tốt hơn
  thu thập dữ liệu chi tiết

Thay đổi từ V12 thành V13
-----------------------

Danh sách V13 chưa đầy đủ và cần điều tra thêm.

- V13 không hỗ trợ triển khai CSI-host cũ nữa