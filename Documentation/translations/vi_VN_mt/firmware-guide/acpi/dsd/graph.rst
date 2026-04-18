.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/dsd/graph.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
Đồ thị
======

_DSD
====

_DSD (Dữ liệu cụ thể của thiết bị) [dsd-guide] là thiết bị ACPI được xác định trước
đối tượng cấu hình có thể được sử dụng để truyền tải thông tin về
các tính năng phần cứng không được ACPI đề cập cụ thể
đặc điểm kỹ thuật [acpi]. Có hai phần mở rộng _DSD có liên quan
dành cho biểu đồ: thuộc tính [dsd-guide] và phần mở rộng dữ liệu phân cấp. các
phần mở rộng thuộc tính cung cấp các cặp khóa-giá trị chung trong khi phần mở rộng thuộc tính
Phần mở rộng dữ liệu phân cấp hỗ trợ các nút có tham chiếu đến các nút khác
các nút, tạo thành một cây. Các nút trong cây có thể chứa các thuộc tính như
được xác định bởi phần mở rộng thuộc tính. Hai phần mở rộng cùng nhau cung cấp
cấu trúc dạng cây không có hoặc nhiều thuộc tính (cặp khóa-giá trị)
trong mỗi nút của cây.

Cấu trúc dữ liệu có thể được truy cập trong thời gian chạy bằng cách sử dụng device_*
và các hàm fwnode_* được xác định trong include/linux/fwnode.h .

Fwnode đại diện cho một đối tượng nút phần sụn chung. Nó độc lập trên
loại phần sụn. Trong ACPI, fwnode là dữ liệu phân cấp _DSD
các đối tượng mở rộng Đối tượng _DSD của thiết bị được biểu diễn bằng một
fwnode.

Cấu trúc dữ liệu có thể được tham chiếu đến nơi khác trong bảng ACPI
bằng cách sử dụng một tham chiếu cứng tới chính thiết bị đó và một chỉ mục tới
mảng mở rộng dữ liệu phân cấp theo từng độ sâu.


Cổng và điểm cuối
===================

Các khái niệm về cổng và điểm cuối rất giống với các khái niệm trong Devicetree
[devicetree, liên kết đồ thị]. Một cổng đại diện cho một giao diện trong một thiết bị và
một điểm cuối đại diện cho một kết nối đến giao diện đó. Đồng thời xem [data-node-ref]
để tham khảo nút dữ liệu chung.

Tất cả các nút cổng được đặt dưới nút "_DSD" của thiết bị trong hệ thống phân cấp
cây mở rộng dữ liệu Phần mở rộng dữ liệu liên quan đến mỗi nút cổng phải bắt đầu
bằng "port" và phải theo sau là ký tự "@" và số của
port làm khóa của nó. Đối tượng mục tiêu mà nó đề cập đến phải được gọi là "PRTX", trong đó
"X" là số cổng. Một ví dụ về gói như vậy sẽ là ::

Gói() { "port@4", "PRT4" }

Hơn nữa, các điểm cuối được đặt dưới các nút cổng. Hệ thống phân cấp
khóa mở rộng dữ liệu của các nút điểm cuối phải bắt đầu bằng
"điểm cuối" và phải theo sau là ký tự "@" và số của
điểm cuối. Đối tượng mà nó đề cập đến phải được gọi là "EPXY", trong đó "X" là
số cổng và "Y" là số điểm cuối. Một ví dụ như vậy
gói sẽ là::

Gói() { "endpoint@0", "EP40" }

Mỗi nút cổng chứa một khóa mở rộng thuộc tính "port", giá trị của nó là
số của cảng. Mỗi điểm cuối được đánh số tương tự với một thuộc tính
khóa mở rộng "reg", giá trị của nó là số điểm cuối. Cảng
các số phải là duy nhất trong một thiết bị và các số điểm cuối phải là duy nhất
trong một cảng. Nếu một đối tượng thiết bị chỉ có thể có một cổng duy nhất thì số
của cổng đó sẽ bằng không. Tương tự, nếu một cổng chỉ có thể có một
điểm cuối thì số điểm cuối đó sẽ bằng 0.

Tham chiếu điểm cuối sử dụng phần mở rộng thuộc tính với thuộc tính "điểm cuối từ xa"
tên theo sau là một tham chiếu chuỗi trong cùng một gói. [dữ liệu-nút-ref]::

"thiết bị.datanode"

Trong ví dụ trên, "X" là số cổng và "Y" là số cổng
điểm cuối.

Việc tham chiếu đến điểm cuối phải luôn được thực hiện theo cả hai cách, đối với
điểm cuối từ xa và quay lại từ nút điểm cuối từ xa được giới thiệu.

Một ví dụ đơn giản về điều này được hiển thị bên dưới::

Phạm vi (\_SB.PCI0.I2C2)
    {
	Thiết bị (CAM0)
	{
	    Tên (_DSD, Gói () {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "tương thích", Gói () { "nokia,smia" } },
		},
		ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		Gói () {
		    Gói () { "port@0", "PRT0" },
		}
	    })
	    Tên (PRT0, Gói() {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "reg", 0 },
		},
		ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		Gói () {
		    Gói () { "endpoint@0", "EP00" },
		}
	    })
	    Tên (EP00, Gói() {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "reg", 0 },
		    Gói () { "điểm cuối từ xa", "\\_SB.PCI0.ISP.EP40" },
		}
	    })
	}
    }

Phạm vi (\_SB.PCI0)
    {
	Thiết bị (ISP)
	{
	    Tên (_DSD, Gói () {
		ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		Gói () {
		    Gói () { "port@4", "PRT4" },
		}
	    })

Tên (PRT4, Gói() {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "reg", 4 }, /* Số cổng CSI-2 */
		},
		ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		Gói () {
		    Gói () { "endpoint@0", "EP40" },
		}
	    })

Tên (EP40, Gói() {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "reg", 0 },
		    Gói () { "điểm cuối từ xa", "\\_SB.PCI0.I2C2.CAM0.EP00" },
		}
	    })
	}
    }

Ở đây, cổng 0 của thiết bị "CAM0" được kết nối với cổng 4 của
thiết bị "ISP" và ngược lại.


Tài liệu tham khảo
==========

[acpi] Cấu hình nâng cao và đặc tả giao diện nguồn.
    ZZ0000ZZ được tham chiếu 2021-11-30.

[data-node-ref] Tài liệu/firmware-guide/acpi/dsd/data-node-references.rst

[cây thiết bị] Cây thiết bị. ZZ0000ZZ được tham chiếu 2016-10-03.

[dsd-guide] Hướng dẫn DSD.
    ZZ0000ZZ được tham chiếu
    2021-11-30.

[dsd-rules] Quy tắc sử dụng thuộc tính thiết bị _DSD.
    Tài liệu/firmware-guide/acpi/DSD-properties-rules.rst

[liên kết biểu đồ] Các liên kết chung cho biểu đồ thiết bị (Devicetree).
    ZZ0000ZZ
    tham chiếu 2021-11-30.