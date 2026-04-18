.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/efifb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================
efifb - Trình điều khiển nền tảng EFI chung
===========================================

Đây là trình điều khiển nền tảng EFI chung dành cho các hệ thống có chương trình cơ sở UEFI. các
hệ thống phải được khởi động thông qua sơ khai EFI để có thể sử dụng được. hỗ trợ efifb
cả chương trình cơ sở có màn hình Giao thức đầu ra đồ họa (GOP) cũng như phiên bản cũ hơn
các hệ thống chỉ có màn hình Bộ điều hợp đồ họa phổ dụng (UGA).

Phần cứng được hỗ trợ
=====================

-iMac 17"/20"
-Macbook
-MacBookPro 15"/17"
- MacMini
- Hệ thống ARM/ARM64/X86 với phần mềm UEFI

Làm thế nào để sử dụng nó?
==========================

Đối với màn hình UGA, efifb không có bất kỳ loại tự động phát hiện nào của bạn
máy.

Bạn phải thêm các tham số kernel sau vào elilo.conf::

Macbook :
		video=efifb:macbook
	MacMini :
		video=efifb:mini
	MacbookPro 15", iMac 17":
		video=efifb:i17
	MacbookPro 17", iMac 20":
		video=efifb:i20

Đối với màn hình GOP, efifb có thể tự động phát hiện độ phân giải và bộ đệm khung của màn hình
địa chỉ, vì vậy những địa chỉ này sẽ hoạt động tốt mà không cần bất kỳ thông số đặc biệt nào.

Tùy chọn được chấp nhận:

======= ================================================================
nowc Đừng ánh xạ ghi bộ đệm khung kết hợp. Điều này có thể được sử dụng
	để khắc phục các tác dụng phụ và tình trạng chậm lại trên các lõi CPU khác
	khi một lượng lớn dữ liệu bảng điều khiển được ghi.
======= ================================================================

Tùy chọn cho màn hình GOP:

chế độ=n
        Sơ khai EFI sẽ đặt chế độ hiển thị thành chế độ số n nếu
        có thể.

<xres>x<yres>[-(rgb|bgr|<bpp>)]
        Sơ khai EFI sẽ tìm kiếm chế độ hiển thị phù hợp với chế độ được chỉ định
        độ phân giải ngang và dọc, độ sâu bit tùy chọn và đặt
        chế độ hiển thị cho nó nếu tìm thấy. Độ sâu bit có thể
        "rgb" hoặc "bgr" để khớp cụ thể với các định dạng pixel đó hoặc một số
        đối với chế độ có số bit phù hợp trên mỗi pixel.

tự động
        Sơ khai EFI sẽ chọn chế độ có độ phân giải cao nhất (sản phẩm
        độ phân giải ngang và dọc). Nếu có nhiều chế độ
        có độ phân giải cao nhất thì nó sẽ chọn cái có màu sắc cao nhất
        chiều sâu.

danh sách
        Sơ khai EFI sẽ liệt kê tất cả các chế độ hiển thị có sẵn. A
        chế độ cụ thể sau đó có thể được chọn bằng cách sử dụng một trong các tùy chọn trên cho
        lần khởi động tiếp theo.

Edgar Hucek <gimli@dark-green.com>
