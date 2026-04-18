.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/i2c-muxes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Mux ACPI I2C
==============

Mô tả hệ thống phân cấp thiết bị I2C bao gồm các mux I2C yêu cầu ACPI
Phạm vi thiết bị () trên mỗi kênh mux.

Hãy xem xét cấu trúc liên kết này::

+------+ +------+
    ZZ0000ZZ->ZZ0001ZZ--CH00->i2c khách hàng A (0x50)
    ZZ0002ZZ ZZ0003ZZ--CH01->i2c khách hàng B (0x50)
    +------+ +------+

tương ứng với ASL sau (trong phạm vi \_SB)::

Thiết bị (SMB1)
    {
        Tên (_HID, ...)
        Thiết bị (MUX0)
        {
            Tên (_HID, ...)
            Tên (_CRS, ResourceTemplate () {
                I2cSerialBus (0x70, Bộ điều khiển được khởi tạo, I2C_SPEED,
                            Địa chỉMode7Bit, "\\_SB.SMB1", 0x00,
                            Người tiêu dùng tài nguyên,,)
            }

Thiết bị (CH00)
            {
                Tên (_ADR, 0)

Thiết bị (CLIA)
                {
                    Tên (_HID, ...)
                    Tên (_CRS, ResourceTemplate () {
                        I2cSerialBus (0x50, Bộ điều khiển được khởi tạo, I2C_SPEED,
                                    Địa chỉMode7Bit, "\\_SB.SMB1.MUX0.CH00",
                                    0x00, Người tiêu dùng tài nguyên,,)
                    }
                }
            }

Thiết bị (CH01)
            {
                Tên (_ADR, 1)

Thiết bị (CLIB)
                {
                    Tên (_HID, ...)
                    Tên (_CRS, ResourceTemplate () {
                        I2cSerialBus (0x50, Bộ điều khiển được khởi tạo, I2C_SPEED,
                                    Địa chỉMode7Bit, "\\_SB.SMB1.MUX0.CH01",
                                    0x00, Người tiêu dùng tài nguyên,,)
                    }
                }
            }
        }
    }