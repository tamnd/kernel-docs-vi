.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/zorro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Viết trình điều khiển thiết bị cho thiết bị Zorro
=================================================

:Tác giả: Viết bởi Geert Uytterhoeven <geert@linux-m68k.org>
:Sửa đổi lần cuối: Ngày 5 tháng 9 năm 2003


Giới thiệu
------------

Xe buýt Zorro là xe buýt được sử dụng trong dòng máy tính Amiga. Nhờ có
AutoConfig(tm), đó là 100% Plug-and-Play.

Có hai loại xe buýt Zorro, Zorro II và Zorro III:

- Không gian địa chỉ Zorro II là 24-bit và nằm trong 16 MB đầu tiên của
    Bản đồ địa chỉ của Amiga.

- Zorro III là phần mở rộng 32-bit của Zorro II, tương thích ngược
    với Zorro II. Không gian địa chỉ Zorro III nằm ngoài 16 MB đầu tiên.


Thăm dò thiết bị Zorro
-------------------------

Thiết bị Zorro được tìm thấy bằng cách gọi ZZ0000ZZ, trả về một
con trỏ tới thiết bị ZZ0001ZZ Zorro với ID Zorro được chỉ định. Vòng thăm dò
đối với bảng có Zorro ID ZZ0002ZZ trông giống như::

struct zorro_dev *z = NULL;

trong khi ((z = zorro_find_device(ZORRO_PROD_xxx, z))) {
	if (!zorro_request_zone(z->resource.start+MY_START, MY_SIZE,
				  "Lời giải thích của tôi"))
	...
    }

ZZ0000ZZ hoạt động như một ký tự đại diện và tìm thấy bất kỳ thiết bị Zorro nào. Nếu tài xế của bạn
hỗ trợ các loại bảng khác nhau, bạn có thể sử dụng cấu trúc như ::

struct zorro_dev *z = NULL;

trong khi ((z = zorro_find_device(ZORRO_WILDCARD, z))) {
	if (z->id != ZORRO_PROD_xxx1 && z->id != ZORRO_PROD_xxx2 && ...)
	    tiếp tục;
	if (!zorro_request_zone(z->resource.start+MY_START, MY_SIZE,
				  "Lời giải thích của tôi"))
	...
    }


Tài nguyên Zorro
---------------

Trước khi bạn có thể truy cập vào sổ đăng ký của thiết bị Zorro, bạn phải đảm bảo rằng nó
chưa được sử dụng. Việc này được thực hiện bằng cách sử dụng tính năng quản lý tài nguyên không gian bộ nhớ I/O
chức năng::

request_mem_khu vực()
    phát hành_mem_khu vực()

Các phím tắt để xác nhận toàn bộ không gian địa chỉ của thiết bị cũng được cung cấp ::

zorro_request_device
    zorro_release_device


Truy cập không gian địa chỉ Zorro
---------------------------------

Các vùng địa chỉ trong tài nguyên thiết bị Zorro là địa chỉ xe buýt Zorro
các vùng. Do ánh xạ địa chỉ vật lý-bus nhận dạng trên xe buýt Zorro,
chúng cũng là địa chỉ vật lý CPU.

Việc xử lý các vùng này phụ thuộc vào loại không gian Zorro:

- Không gian địa chỉ Zorro II luôn được ánh xạ và không cần phải ánh xạ
    rõ ràng bằng cách sử dụng z_ioremap().
    
Chuyển đổi từ địa chỉ bus/địa chỉ Zorro II vật lý sang địa chỉ ảo kernel
    và ngược lại được thực hiện bằng cách sử dụng::

virt_addr = ZTWO_VADDR(bus_addr);
	bus_addr = ZTWO_PADDR(virt_addr);

- Không gian địa chỉ Zorro III trước tiên phải được ánh xạ rõ ràng bằng cách sử dụng z_ioremap()
    trước khi nó có thể được truy cập::
 
virt_addr = z_ioremap(bus_addr, kích thước);
	...
z_iounmap(virt_addr);


Tài liệu tham khảo
----------

#. linux/include/linux/zorro.h
#. linux/include/uapi/linux/zorro.h
#. linux/include/uapi/linux/zorro_ids.h
#. linux/arch/m68k/include/asm/zorro.h
#. linux/trình điều khiển/zorro
#. /proc/bus/zorro

