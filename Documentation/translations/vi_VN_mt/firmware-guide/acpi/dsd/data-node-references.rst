.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/dsd/data-node-references.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

======================================
Tham chiếu các nút dữ liệu phân cấp
======================================

:Bản quyền: ZZ0000ZZ 2018, 2021 Tập đoàn Intel
:Tác giả: Sakari Ailus <sakari.ailus@linux.intel.com>

ACPI nói chung chỉ cho phép tham chiếu tới các đối tượng thiết bị trong cây.
Các nút mở rộng dữ liệu phân cấp có thể không được tham chiếu trực tiếp, do đó điều này
tài liệu xác định một sơ đồ để thực hiện các tham chiếu đó.

Một tham chiếu đến nút dữ liệu phân cấp _DSD là một chuỗi bao gồm một
tham chiếu đối tượng thiết bị theo sau là dấu chấm (".") và đường dẫn tương đối tới dữ liệu
đối tượng nút. Không sử dụng các tham chiếu không phải chuỗi vì điều này sẽ tạo ra một bản sao của
nút dữ liệu phân cấp, không phải là một tham chiếu!

Nút mở rộng dữ liệu phân cấp được đề cập đến sẽ được đặt ở vị trí
ngay dưới đối tượng cha của nó, tức là đối tượng thiết bị hoặc đối tượng khác
nút mở rộng dữ liệu phân cấp [dsd-guide].

Các khóa trong các nút dữ liệu phân cấp sẽ bao gồm tên của nút,
Ký tự "@" và số nút theo ký hiệu thập lục phân (không có tiền
hoặc hậu tố). Đối tượng ACPI tương tự sẽ bao gồm phần mở rộng thuộc tính _DSD
với thuộc tính "reg" sẽ có cùng giá trị bằng số với số lượng
nút.

Trong trường hợp nút mở rộng dữ liệu phân cấp không có giá trị số thì
Thuộc tính "reg" sẽ bị bỏ qua khỏi thuộc tính _DSD của đối tượng ACPI và thuộc tính
Ký tự "@" và số sẽ bị loại bỏ khỏi dữ liệu phân cấp
phím mở rộng.


Ví dụ
=======

Trong đoạn mã ASL bên dưới, thuộc tính _DSD "tham chiếu" chứa một chuỗi
tham chiếu đến nút mở rộng dữ liệu phân cấp ANOD trong DEV0 dưới nút gốc
của DEV1. ANOD cũng là nút mục tiêu cuối cùng của tham chiếu.
::

Thiết bị (DEV0)
	{
	    Tên (_DSD, Gói () {
		ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		Gói () {
		    Gói () { "node@0", "NOD0" },
		    Gói () { "node@1", "NOD1" },
		}
	    })
	    Tên (NOD0, Gói() {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "reg", 0 },
		    Gói () { "thuộc tính ngẫu nhiên", 3 },
		}
	    })
	    Tên (NOD1, Gói() {
		ToUUID("dbb8e3e6-5886-4ba6-8795-1319f52a966b"),
		Gói () {
		    Gói () { "reg", 1 },
		    Gói () { "anothernode", "ANOD" },
		}
	    })
	    Tên (ANOD, Gói() {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "thuộc tính ngẫu nhiên", 0 },
		}
	    })
	}

Thiết bị (DEV1)
	{
	    Tên (_DSD, Gói () {
		ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
		Gói () {
		    Gói () { "tham khảo", "^DEV0.ANOD" }
		    },
		}
	    })
	}

Vui lòng xem thêm một ví dụ về biểu đồ trong
Tài liệu/firmware-guide/acpi/dsd/graph.rst.

Tài liệu tham khảo
==========

[dsd-guide] Hướng dẫn DSD.
    ZZ0000ZZ được tham chiếu
    2021-11-30.