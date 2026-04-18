.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/i2c/busses/i2c-via.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Trình điều khiển hạt nhân i2c-via
=================================

Bộ điều hợp được hỗ trợ:
  * Công nghệ VIA, Inc. VT82C586B
    Bảng dữ liệu: Có sẵn công khai tại trang web VIA

Tác giả: Kyösti Mälkki <kmalkki@cc.hut.fi>

Sự miêu tả
-----------

i2c-via là trình điều khiển bus i2c cho bo mạch chủ với chipset VIA.

Các chipset pci VIA sau được hỗ trợ:
 - MVP3, VP3, VP2/97, VPX/97
 - những người khác có cầu Nam VT82C586B

Danh sách ZZ0000ZZ của bạn phải hiển thị điều này ::

Cầu: VIA Technologies, Inc. VT82C586B ACPI (rev 10)

Vấn đề?
---------

Hỏi:
    Bạn có VT82C586B trên bo mạch chủ nhưng không có trong danh sách.

Đáp:
    Đi tới thiết lập BIOS của bạn, phần Thiết bị PCI hoặc tương tự.
    Bật hỗ trợ USB và thử lại.

Hỏi:
    Không có thông báo lỗi, nhưng i2c dường như không hoạt động.

Đáp:
    Điều này có thể xảy ra. Trình điều khiển này sử dụng các chân VIA khuyến nghị trong
    bảng dữ liệu, nhưng có một số cách mà nhà sản xuất bo mạch chủ
    thực sự có thể nối dây.
