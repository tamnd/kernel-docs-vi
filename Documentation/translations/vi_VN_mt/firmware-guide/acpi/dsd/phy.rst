.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/dsd/phy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Xe buýt MDIO và PHY trong ACPI
=========================

Các PHY trên bus MDIO [phy] được thăm dò và đăng ký bằng cách sử dụng
fwnode_mdiobus_register_phy().

Sau đó, để kết nối các PHY này với các MAC tương ứng, các PHY đã đăng ký
trên xe buýt MDIO phải được tham chiếu.

Tài liệu này giới thiệu hai thuộc tính _DSD sẽ được sử dụng
để kết nối PHY trên bus MDIO [dsd-properties-rules] với lớp MAC.

Các thuộc tính này được xác định theo "Thiết bị
Thuộc tính UUID Dành cho tài liệu _DSD" [dsd-guide] và
daffd814-6eba-4d8c-8a91-bc9bbf4aa301 UUID phải được sử dụng trong Thiết bị
Bộ mô tả dữ liệu có chứa chúng.

tay cầm phy
----------
Đối với mỗi nút MAC, thuộc tính thiết bị "phy-xử lý" được sử dụng để tham chiếu
PHY được đăng ký trên bus MDIO. Điều này là bắt buộc đối với
giao diện mạng có PHY được kết nối với MAC qua bus MDIO.

Trong quá trình khởi tạo trình điều khiển bus MDIO, PHY trên bus này được thăm dò
sử dụng đối tượng _ADR như hiển thị bên dưới và được đăng ký trên bus MDIO.

.. code-block:: none

      Scope(\_SB.MDI0)
      {
        Device(PHY1) {
          Name (_ADR, 0x1)
        } // end of PHY1

        Device(PHY2) {
          Name (_ADR, 0x2)
        } // end of PHY2
      }

Sau đó, trong quá trình khởi tạo trình điều khiển MAC, các thiết bị PHY đã đăng ký
phải được lấy từ bus MDIO. Để làm được điều này, trình điều khiển MAC cần
tài liệu tham khảo đến các PHY đã đăng ký trước đó được cung cấp
làm tham chiếu đối tượng thiết bị (ví dụ \_SB.MDI0.PHY1).

chế độ phy
--------
Thuộc tính _DSD "phy-mode" được sử dụng để mô tả kết nối tới
PHY. Các giá trị hợp lệ cho "phy-mode" được xác định trong [bộ điều khiển ethernet].

được quản lý
-------
Thuộc tính tùy chọn, chỉ định loại quản lý PHY.
Các giá trị hợp lệ cho "được quản lý" được xác định trong [bộ điều khiển ethernet].

liên kết cố định
----------
"Liên kết cố định" được mô tả bằng nút con chỉ có dữ liệu của
Cổng MAC, được liên kết trong gói _DSD thông qua
phần mở rộng dữ liệu phân cấp (UUID dbb8e3e6-5886-4ba6-8795-1319f52a966b
theo tài liệu [dsd-guide] "Hướng dẫn triển khai _DSD").
Nút con phải bao gồm thuộc tính bắt buộc ("tốc độ") và
có thể là những cái tùy chọn - danh sách đầy đủ các tham số và
giá trị của chúng được chỉ định trong [bộ điều khiển ethernet].

Ví dụ ASL sau đây minh họa cách sử dụng các thuộc tính này.

Mục nhập DSDT cho nút MDIO
------------------------

Bus MDIO có thành phần SoC (bộ điều khiển MDIO) và nền tảng
thành phần (PHY trên bus MDIO).

a) Thành phần silic
Nút này mô tả bộ điều khiển MDIO, MDI0
---------------------------------------------

.. code-block:: none

	Scope(_SB)
	{
	  Device(MDI0) {
	    Name(_HID, "NXP0006")
	    Name(_CCA, 1)
	    Name(_UID, 0)
	    Name(_CRS, ResourceTemplate() {
	      Memory32Fixed(ReadWrite, MDI0_BASE, MDI_LEN)
	      Interrupt(ResourceConsumer, Level, ActiveHigh, Shared)
	       {
		 MDI0_IT
	       }
	    }) // end of _CRS for MDI0
	  } // end of MDI0
	}

b) Thành phần nền tảng
Các nút PHY1 và PHY2 đại diện cho các PHY được kết nối với bus MDIO MDI0
---------------------------------------------------------------------

.. code-block:: none

	Scope(\_SB.MDI0)
	{
	  Device(PHY1) {
	    Name (_ADR, 0x1)
	  } // end of PHY1

	  Device(PHY2) {
	    Name (_ADR, 0x2)
	  } // end of PHY2
	}

Các mục DSDT đại diện cho các nút MAC
-----------------------------------

Dưới đây là các nút MAC trong đó các nút PHY được tham chiếu.
phy-mode và phy-handle được sử dụng như đã giải thích trước đó.
------------------------------------------------------

.. code-block:: none

	Scope(\_SB.MCE0.PR17)
	{
	  Name (_DSD, Package () {
	     ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		 Package () {
		     Package (2) {"phy-mode", "rgmii-id"},
		     Package (2) {"phy-handle", \_SB.MDI0.PHY1}
	      }
	   })
	}

	Scope(\_SB.MCE0.PR18)
	{
	  Name (_DSD, Package () {
	    ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Package () {
		    Package (2) {"phy-mode", "rgmii-id"},
		    Package (2) {"phy-handle", \_SB.MDI0.PHY2}}
	    }
	  })
	}

Ví dụ về nút MAC trong đó thuộc tính "được quản lý" được chỉ định.
-------------------------------------------------------

.. code-block:: none

	Scope(\_SB.PP21.ETH0)
	{
	  Name (_DSD, Package () {
	     ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		 Package () {
		     Package () {"phy-mode", "sgmii"},
		     Package () {"managed", "in-band-status"}
		 }
	   })
	}

Ví dụ về nút MAC với nút con "liên kết cố định".
---------------------------------------------

.. code-block:: none

	Scope(\_SB.PP21.ETH1)
	{
	  Name (_DSD, Package () {
	    ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		 Package () {
		     Package () {"phy-mode", "sgmii"},
		 },
	    ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		 Package () {
		     Package () {"fixed-link", "LNK0"}
		 }
	  })
	  Name (LNK0, Package(){ // Data-only subnode of port
	    ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		 Package () {
		     Package () {"speed", 1000},
		     Package () {"full-duplex", 1}
		 }
	  })
	}

Tài liệu tham khảo
==========

[phy] Tài liệu/mạng/phy.rst

[dsd-thuộc tính-quy tắc]
    Tài liệu/firmware-guide/acpi/DSD-properties-rules.rst

[bộ điều khiển ethernet]
    Tài liệu/devicetree/binds/net/ethernet-controller.yaml

[dsd-guide] Hướng dẫn DSD.
    ZZ0000ZZ được tham chiếu
    2021-11-30.