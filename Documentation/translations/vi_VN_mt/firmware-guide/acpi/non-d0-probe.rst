.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/non-d0-probe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============================================
Thiết bị thăm dò ở trạng thái D khác ngoài 0
========================================

Giới thiệu
============

Trong một số trường hợp, có thể nên tắt nguồn một số thiết bị nhất định để
toàn bộ quá trình khởi động hệ thống nếu bật nguồn các thiết bị này có tác dụng phụ bất lợi,
ngoài việc chỉ bật nguồn cho thiết bị nói trên.

Nó hoạt động như thế nào
============

Đối tượng _DSC (Trạng thái thiết bị cho cấu hình) đánh giá thành một số nguyên
có thể được sử dụng để báo cho Linux biết trạng thái D cao nhất được phép đối với một thiết bị trong
thăm dò. Sự hỗ trợ cho _DSC yêu cầu hỗ trợ từ loại bus hạt nhân nếu
Trình điều khiển xe buýt thường đặt thiết bị ở trạng thái D0 để thăm dò.

The downside of using _DSC is that as the device is not powered on, even if
there's a problem with the device, the driver likely probes just fine but the
first user will find out the device doesn't work, instead of a failure at probe
thời gian. Do đó, tính năng này nên được sử dụng một cách tiết kiệm.

I2C
---

Nếu trình điều khiển I2C cho biết sự hỗ trợ của nó cho việc này bằng cách đặt
Cờ I2C_DRV_ACPI_WAIVE_D0_PROBE trong trường struct i2c_driver.flags và
Đối tượng _DSC đánh giá số nguyên cao hơn trạng thái D của thiết bị,
thiết bị sẽ không được bật nguồn (đặt ở trạng thái D0) cho đầu dò.

trạng thái D
--------

Các trạng thái D và do đó cũng là các giá trị được phép cho _DSC được liệt kê bên dưới. tham khảo
tới [1] để biết thêm thông tin về trạng thái nguồn của thiết bị.

.. code-block:: text

	Number	State	Description
	0	D0	Device fully powered on
	1	D1
	2	D2
	3	D3hot
	4	D3cold	Off

Tài liệu tham khảo
==========

[1] ZZ0000ZZ

Ví dụ
=======

Một ví dụ ASL mô tả thiết bị ACPI sử dụng đối tượng _DSC để thông báo cho Hệ điều hành
Hệ thống, thiết bị sẽ vẫn tắt nguồn trong khi thăm dò trông như thế này. Một số
các đối tượng không liên quan từ quan điểm ví dụ đã bị bỏ qua.

.. code-block:: text

	Device (CAM0)
	{
		Name (_HID, "SONY319A")
		Name (_UID, Zero)
		Name (_CRS, ResourceTemplate ()
		{
			I2cSerialBus(0x0020, ControllerInitiated, 0x00061A80,
				     AddressingMode7Bit, "\\_SB.PCI0.I2C0",
				     0x00, ResourceConsumer)
		})
		Method (_DSC, 0, NotSerialized)
		{
			Return (0x4)
		}
	}