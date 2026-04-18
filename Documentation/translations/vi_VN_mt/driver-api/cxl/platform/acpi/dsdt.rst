.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/platform/acpi/dsdt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
DSDT - Bảng mô tả hệ thống vi phân
==================================================

Bảng này mô tả những thiết bị ngoại vi mà máy có.

UID của bảng này dành cho các thiết bị CXL - cụ thể là các cầu nối máy chủ, phải là
phù hợp với nội dung của CEDT, nếu không trình điều khiển CXL sẽ
không thăm dò chính xác.

Ví dụ về tính toán cầu nối máy chủ liên kết nhanh ::

Phạm vi (_SB)
    {
        Thiết bị (S0D0)
        {
            Tên (_HID, "ACPI0016" /* Cầu nối máy chủ liên kết nhanh tính toán */) // _HID: ID phần cứng
            Tên (_CID, Gói (0x02) // _CID: ID tương thích
            {
                EisaId ("PNP0A08") /* Xe buýt tốc hành PCI */,
                EisaId ("PNP0A03") /* Xe buýt PCI */
            })
            ...
Tên (_UID, 0x05) // _UID: ID duy nhất
            ...
      }