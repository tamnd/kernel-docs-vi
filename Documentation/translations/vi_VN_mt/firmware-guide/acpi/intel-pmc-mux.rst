.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/intel-pmc-mux.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Đại lý Intel North Mux
=====================

Giới thiệu
============

North Mux-Agent là một chức năng của phần sụn Intel PMC được hỗ trợ trên
hầu hết các nền tảng dựa trên Intel có bộ vi điều khiển PMC. Nó được sử dụng cho
định cấu hình Bộ ghép kênh/Bộ ghép kênh USB khác nhau trên hệ thống. các
các nền tảng cho phép cấu hình mux-agent từ hệ điều hành
có một đối tượng thiết bị ACPI (nút) với HID "INTC105C" đại diện cho nó.

Trình điều khiển North Mux-Agent (còn gọi là Intel PMC Mux Control hoặc chỉ mux-agent)
giao tiếp với bộ vi điều khiển PMC bằng cách sử dụng phương pháp PMC IPC
(trình điều khiển/nền tảng/x86/intel_scu_ipc.c). Trình điều khiển đăng ký với USB Type-C
Mux Class cho phép trình điều khiển Giao diện và Bộ điều khiển USB Type-C
định cấu hình hướng và chế độ cắm cáp (với Chế độ thay thế). Người lái xe
cũng đăng ký với Lớp vai trò USB để hỗ trợ cả Máy chủ USB và
Các chế độ thiết bị. Trình điều khiển được đặt ở đây: driver/usb/typec/mux/intel_pmc_mux.c.

Nút cổng
==========

Tổng quan
-------

Đối với mỗi đầu nối USB Type-C dưới sự kiểm soát tác nhân mux trên hệ thống, sẽ có
là một nút con riêng biệt trong nút thiết bị tác nhân mux PMC. Những nút đó không
đại diện cho các trình kết nối thực tế, mà thay vào đó là các "kênh" trong tác nhân mux
được liên kết với các đầu nối::

Phạm vi (_SB.PCI0.PMC.MUX)
	{
	    Thiết bị (CH0)
	    {
		Tên (_ADR, 0)
	    }

Thiết bị (CH1)
	    {
		Tên (_ADR, 1)
	    }
	}

_PLD (Vị trí vật lý của thiết bị)
----------------------------------

Đối tượng _PLD tùy chọn có thể được sử dụng với các nút cổng (kênh). Nếu _PLD
được cung cấp, nó phải khớp với nút kết nối _PLD::

Phạm vi (_SB.PCI0.PMC.MUX)
	{
	    Thiết bị (CH0)
	    {
		Tên (_ADR, 0)
	        Phương thức (_PLD, 0, Không được tuần tự hóa)
                {
		    /* Hãy coi đây là mã giả. */
		    Trả về (\_SB.USBC.CON0._PLD())
		}
	    }
	}

Thuộc tính thiết bị _DSD cụ thể của tác nhân Mux
-----------------------------------------

Số cổng
~~~~~~~~~~~~

Để định cấu hình các mux đằng sau đầu nối USB Type-C, chương trình cơ sở PMC
cần biết cổng USB2 và cổng USB3 được liên kết với
đầu nối. Trình điều khiển trích xuất số cổng chính xác bằng cách đọc _DSD cụ thể
thuộc tính thiết bị có tên là "số cổng usb2" và "số cổng usb3". Những cái này
các thuộc tính có giá trị nguyên có nghĩa là chỉ mục cổng. Số chỉ mục cổng
dựa trên 1 và giá trị 0 là bất hợp pháp. Người lái xe sử dụng những con số được trích xuất từ
các thuộc tính thiết bị này nguyên trạng khi gửi tin nhắn cụ thể của tác nhân mux tới
PMC::

Tên (_DSD, Gói () {
	    ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
	    Gói() {
	        Gói () {"usb2-port-number", 6},
	        Gói () {"usb3-port-number", 3},
	    },
	})

Định hướng
~~~~~~~~~~~

Tùy thuộc vào nền tảng, dữ liệu và dòng SBU đến từ đầu nối có thể
được "cố định" theo quan điểm của tác nhân mux, có nghĩa là trình điều khiển tác nhân mux
không nên cấu hình chúng theo hướng cắm cáp. Điều này có thể
ví dụ như xảy ra nếu bộ đếm thời gian trên nền tảng xử lý phích cắm cáp
định hướng. Trình điều khiển sử dụng một thuộc tính thiết bị cụ thể "định hướng sbu"
(SBU) và "hsl-orientation" (dữ liệu) để biết liệu các dòng đó có "cố định" hay không và để biết
định hướng nào. Giá trị mà các thuộc tính này có là giá trị chuỗi và
nó có thể là một cái được xác định cho hướng đầu nối USB Type-C: "bình thường"
hoặc "đảo ngược"::

Tên (_DSD, Gói () {
	    ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
	    Gói() {
	        Gói () {"sbu-orientation", "bình thường"},
	        Gói () {"hsl-orientation", "bình thường"},
	    },
	})

Ví dụ ASL
===========

ASL sau đây là một ví dụ hiển thị nút tác nhân mux và hai
kết nối dưới sự kiểm soát của nó::

Phạm vi (_SB.PCI0.PMC)
	{
	    Thiết bị (MUX)
	    {
	        Tên (_HID, "INTC105C")

Thiết bị (CH0)
	        {
	            Tên (_ADR, 0)

Tên (_DSD, Gói () {
	                ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
	                Gói() {
	                    Gói () {"usb2-port-number", 6},
	                    Gói () {"usb3-port-number", 3},
	                    Gói () {"sbu-orientation", "bình thường"},
	                    Gói () {"hsl-orientation", "bình thường"},
	                },
	            })
	        }

Thiết bị (CH1)
	        {
	            Tên (_ADR, 1)

Tên (_DSD, Gói () {
	                ToUUID("daffd814-6eba-4d8c-8a91-bc9bbf4aa301"),
	                Gói() {
	                    Gói () {"usb2-port-number", 5},
	                    Gói () {"usb3-port-number", 2},
	                    Gói () {"sbu-orientation", "bình thường"},
	                    Gói () {"hsl-orientation", "bình thường"},
	                },
	            })
	        }
	    }
	}