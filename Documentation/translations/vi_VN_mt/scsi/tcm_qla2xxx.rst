.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/tcm_qla2xxx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================
Ghi chú về Trình điều khiển tcm_qla2xxx
=======================================

Thuộc tính tcm_qla2xxx jam_host
-------------------------------
Hiện tại có thuộc tính điểm cuối mô-đun mới được gọi là jam_host
thuộc tính::

jam_host: boolean=0/1

Thuộc tính này và mã đi kèm chỉ được đưa vào nếu
Tham số Kconfig TCM_QLA2XXX_DEBUG được đặt thành Y

Theo mặc định, chức năng và mã gây nhiễu này bị tắt

Sử dụng thuộc tính này để kiểm soát việc loại bỏ các lệnh SCSI thành một
máy chủ đã chọn.

Điều này có thể hữu ích cho việc kiểm tra việc xử lý lỗi và mô phỏng việc thoát nước chậm
và các vấn đề về vải khác.

Đặt giá trị boolean bằng 1 cho thuộc tính jam_host cho một máy chủ cụ thể
sẽ loại bỏ các lệnh cho máy chủ đó.

Đặt lại về 0 để ngừng gây nhiễu.

Cho phép máy chủ 4 bị kẹt::

echo 1 > /sys/kernel/config/target/qla2xxx/21:00:00:24:ff:27:8f:ae/tpgt_1/attrib/jam_host

Tắt gây nhiễu trên máy chủ 4::

echo 0 > /sys/kernel/config/target/qla2xxx/21:00:00:24:ff:27:8f:ae/tpgt_1/attrib/jam_host