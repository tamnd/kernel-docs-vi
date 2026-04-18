.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi/hmat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
HMAT - Bảng thuộc tính bộ nhớ không đồng nhất
===============================================

Bảng thuộc tính bộ nhớ không đồng nhất chứa thông tin như bộ đệm
thuộc tính, chi tiết về băng thông và độ trễ cho các miền lân cận bộ nhớ.
Với mục đích của tài liệu này, chúng tôi sẽ chỉ thảo luận về mục SSLIB.

SLLBI
=====
Thông tin về độ trễ và băng thông cục bộ của hệ thống ghi lại độ trễ và
thông tin băng thông cho các miền lân cận.

Bảng này được Linux sử dụng để định cấu hình các trọng số xen kẽ và các tầng bộ nhớ.

Ví dụ (Cắt ngắn nhiều cho ngắn gọn) ::

Loại cấu trúc: 0001 [SLLBI]
                    Kiểu dữ liệu: 00 <- Độ trễ
 Danh sách miền lân cận mục tiêu: 00000000
 Danh sách miền lân cận mục tiêu: 00000001
                        Đầu vào : 0080 <- DRAM LTC
                        Đầu vào : 0100 <- CXL LTC

Loại cấu trúc: 0001 [SLLBI]
                    Kiểu dữ liệu: 03 <- Băng thông
 Danh sách miền lân cận mục tiêu: 00000000
 Danh sách miền lân cận mục tiêu: 00000001
                        Đầu vào : 1200 <- DRAM BW
                        Đầu vào : 0200 <- CXL BW