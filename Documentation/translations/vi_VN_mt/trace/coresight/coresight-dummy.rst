.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-dummy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Mô-đun theo dõi giả Coresight
=============================

:Tác giả: Hao Zhang <quic_hazha@quicinc.com>
    :Ngày: Tháng 6 năm 2023

Giới thiệu
------------

Mô-đun theo dõi giả Coresight dành cho các thiết bị cụ thể mà kernel không có
có quyền truy cập hoặc định cấu hình, ví dụ: TPDM CoreSight trên Qualcomm
nền tảng. Đối với các thiết bị này, cần có trình điều khiển giả để đăng ký chúng dưới dạng
Thiết bị Coresight Mô-đun này cũng có thể được sử dụng để xác định các thành phần có thể
không có bất kỳ giao diện lập trình nào nên có thể tạo đường dẫn trong trình điều khiển.
Nó cung cấp Coresight API để vận hành trên các thiết bị giả, chẳng hạn như kích hoạt và
vô hiệu hóa chúng. Nó cũng cung cấp các đường dẫn nguồn/sink giả Coresight cho
gỡ lỗi.

Chi tiết cấu hình
--------------

Có hai loại nút, nguồn giả và nguồn giả. Các nút này
có sẵn tại ZZ0000ZZ.

Đầu ra ví dụ::

$ ls -l /sys/bus/coresight/devices | grep giả
    dummy_sink0 -> ../../../devices/platform/soc@0/soc@0:sink/dummy_sink0
    dummy_source0 -> ../../../devices/platform/soc@0/soc@0:source/dummy_source0