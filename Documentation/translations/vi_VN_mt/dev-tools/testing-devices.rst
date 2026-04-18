.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/testing-devices.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (c) 2024 Collabora Ltd

================================
Kiểm tra thiết bị với kselftest
=============================


Nói chung, có một số kselftests khác nhau dành cho các thiết bị thử nghiệm,
với một số chồng chéo trong phạm vi bảo hiểm và các yêu cầu khác nhau. Tài liệu này nhằm mục đích
đưa ra một cái nhìn tổng quan về mỗi người.

Lưu ý: Đường dẫn trong tài liệu này liên quan đến thư mục kselftest
(ZZ0000ZZ).

Kselftests định hướng thiết bị:

* Cây thiết bị (ZZ0000ZZ)

* ZZ0000ZZ: Trạng thái thăm dò cho các thiết bị được mô tả trong Devicetree
  * ZZ0001ZZ: Không có

* Nhật ký lỗi (ZZ0000ZZ)

* ZZ0000ZZ: Lỗi (hoặc nghiêm trọng hơn) hiện diện thông báo nhật ký đến từ bất kỳ
    thiết bị
  * ZZ0001ZZ: Không có

* Xe buýt có thể khám phá (ZZ0000ZZ)

* ZZ0001ZZ: Trạng thái hiện diện và thăm dò của các thiết bị USB hoặc PCI đã được
    described in the reference file
  * ZZ0002ZZ: Mô tả thủ công các thiết bị cần được kiểm tra theo cách
    Tệp tham chiếu YAML (xem ZZ0000ZZ để biết
    một ví dụ)

* Tồn tại (ZZ0000ZZ)

* ZZ0001ZZ: Sự hiện diện của tất cả các thiết bị
  * ZZ0002ZZ: Tạo tham chiếu (xem ZZ0000ZZ
    để biết chi tiết) trên một hạt nhân nổi tiếng

Do đó, đề xuất là kích hoạt tính năng kiểm tra nhật ký lỗi và cây thiết bị trên tất cả
(dựa trên DT) vì chúng không có bất kỳ yêu cầu nào. Sau đó rất nhiều
cải thiện phạm vi phủ sóng, tạo tham chiếu cho từng nền tảng và cho phép tồn tại
kiểm tra. Kiểm tra bus có thể phát hiện có thể được sử dụng để xác minh trạng thái đầu dò của
specific USB or PCI devices, but is probably not worth it for most cases.