.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/igbvf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================================
Trình điều khiển chức năng ảo cơ sở Linux cho Intel(R) 1G Ethernet
==================================================================

Trình điều khiển Linux chức năng ảo Intel Gigabit.
Bản quyền(c) 1999-2018 Tập đoàn Intel.

Nội dung
========
- Xác định bộ chuyển đổi của bạn
- Cấu hình bổ sung
- Hỗ trợ

Trình điều khiển này hỗ trợ chức năng ảo dựa trên thiết bị ảo dựa trên Intel 82576
các thiết bị chức năng chỉ có thể được kích hoạt trên các hạt nhân hỗ trợ SR-IOV.

SR-IOV yêu cầu nền tảng và hệ điều hành hỗ trợ chính xác.

Hệ điều hành khách tải trình điều khiển này phải hỗ trợ các ngắt MSI-X.

Đối với các câu hỏi liên quan đến yêu cầu phần cứng, hãy tham khảo tài liệu
được cung cấp cùng với bộ điều hợp Intel của bạn. Tất cả các yêu cầu phần cứng được liệt kê đều áp dụng để sử dụng
với Linux.

Thông tin trình điều khiển có thể được lấy bằng ethtool, lspci và ifconfig.
Hướng dẫn cập nhật ethtool có thể được tìm thấy trong phần Bổ sung
Cấu hình sau trong tài liệu này.

NOTE: Có giới hạn tổng cộng 32 Vlan được chia sẻ cho 1 hoặc nhiều VF.


Xác định bộ điều hợp của bạn
============================
Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ


Các tính năng và cấu hình bổ sung
======================================

công cụ đạo đức
---------------
Trình điều khiển sử dụng giao diện ethtool để cấu hình trình điều khiển và
chẩn đoán cũng như hiển thị thông tin thống kê. Công cụ đạo đức mới nhất
Phiên bản này là cần thiết cho chức năng này. Tải xuống tại:

ZZ0000ZZ


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.