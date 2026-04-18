.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/dsd/leds.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

============================================
Mô tả và tham khảo đèn LED trong ACPI
========================================

Các đèn LED riêng lẻ được mô tả bằng các nút mở rộng dữ liệu phân cấp [5] trong phần
nút thiết bị, chip điều khiển LED. Thuộc tính "reg" trong các nút cụ thể LED
cho biết ID số của từng đầu ra LED riêng lẻ mà đèn LED hướng tới
được kết nối. [leds] Các nút dữ liệu phân cấp được đặt tên là "led@X", trong đó X là
số đầu ra LED.

Việc đề cập đến đèn LED trong cây Thiết bị được ghi lại trong [giao diện video], trong
Tài liệu thuộc tính "flash-led". Nói tóm lại, đèn LED được gọi trực tiếp bởi
sử dụng phandle.

ACPI cho phép (cũng như DT) sử dụng các đối số nguyên sau tham chiếu. A
sự kết hợp giữa tham chiếu thiết bị trình điều khiển LED và đối số số nguyên,
đề cập đến thuộc tính "reg" của LED có liên quan, được sử dụng để xác định
đèn LED riêng lẻ. Giá trị của tài sản “reg” là một hợp đồng giữa
chương trình cơ sở và phần mềm, nó xác định duy nhất các đầu ra trình điều khiển LED.

Trong thiết bị trình điều khiển LED, Danh sách gói mở rộng dữ liệu phân cấp đầu tiên
mục nhập sẽ chứa chuỗi "led@" theo sau là số LED,
theo sau là tên đối tượng được giới thiệu. Đối tượng đó sẽ được đặt tên là "LED" theo sau
theo số LED.

Ví dụ
=======

Một ví dụ ASL về thiết bị cảm biến camera và thiết bị điều khiển LED cho hai đèn LED là
hiển thị bên dưới. Các đối tượng không liên quan đến đèn LED hoặc các tài liệu tham khảo về chúng đã được
bỏ qua. ::

Thiết bị (LED)
	{
		Tên (_DSD, Gói () {
			ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
			Gói () {
				Gói () { "led@0", LED0 },
				Gói () { "led@1", LED1 },
			}
		})
		Tên (LED0, Gói () {
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói () {
				Gói () { "reg", 0 },
				Gói () { "flash-max-microamp", 1000000 },
				Gói () { "flash-timeout-us", 200000 },
				Gói () { "led-max-microamp", 100000 },
				Gói () { "nhãn", "trắng:flash" },
			}
		})
		Tên (LED1, Gói () {
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói () {
				Gói () { "reg", 1 },
				Gói () { "led-max-microamp", 10000 },
				Gói () { "nhãn", "đỏ:chỉ báo" },
			}
		})
	}

Thiết bị (SEN)
	{
		Tên (_DSD, Gói () {
			ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
			Gói () {
				Gói () {
					"đèn flash led",
					Gói () { "^LED.LED0", "^LED.LED1" },
				}
			}
		})
	}

Ở đâu
::

Thiết bị điều khiển LED LED
	LED0 LED đầu tiên
	LED1 LED thứ hai
	SEN Thiết bị cảm biến camera (hoặc thiết bị khác có liên quan đến LED)

Tài liệu tham khảo
==========

[acpi] Cấu hình nâng cao và đặc tả giao diện nguồn.
    ZZ0000ZZ được tham chiếu 2021-11-30.

[data-node-ref] Tài liệu/firmware-guide/acpi/dsd/data-node-references.rst

[cây thiết bị] Cây thiết bị. ZZ0000ZZ được tham chiếu 21-02-2019.

[dsd-guide] Hướng dẫn DSD.
    ZZ0000ZZ được tham chiếu
    2021-11-30.

[leds] Tài liệu/devicetree/binds/leds/common.yaml

[giao diện video] Tài liệu/devicetree/binds/media/video-interfaces.yaml