.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/sisfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
sisfb - Trình điều khiển thiết bị bộ đệm khung SiS
==================================================

sisfb là trình điều khiển thiết bị bộ đệm khung cho SiS (Hệ thống tích hợp Silicon)
chip đồ họa. Được hỗ trợ là:

- Dòng SiS 300: SiS 300/305, 540, 630(S), 730(S)
- Dòng SiS 315: SiS 315/H/PRO, 55x, (M)65x, 740, (M)661(F/M)X, (M)741(GX)
- Dòng SiS 330: SiS 330 ("Xabre"), (M)760


Tại sao tôi cần trình điều khiển bộ đệm khung?
==============================================

sisfb là ví dụ. hữu ích nếu bạn muốn có bảng điều khiển văn bản có độ phân giải cao. Bên cạnh đó,
sisfb được yêu cầu để chạy DirectFB (đi kèm với một tiện ích bổ sung, chuyên dụng
trình điều khiển cho dòng 315).

Trên dòng 300, sisfb trên các nhân cũ hơn 2.6.3 còn đóng vai trò
vai trò quan trọng liên quan đến DRM/DRI: Sisfb quản lý vùng bộ nhớ
được DRM/DRI sử dụng cho kết cấu 3D và dữ liệu khác. Việc quản lý bộ nhớ này được
cần thiết để sử dụng DRI/DRM.

Hạt nhân >= khoảng 2.6.3 không cần sisfb nữa đối với bộ nhớ DRI/DRM
quản lý. Trình điều khiển SiS DRM đã được cập nhật và có tính năng quản lý bộ nhớ
của chính nó (sẽ được sử dụng nếu sisfb không được biên dịch). Vì vậy trừ khi bạn muốn
bảng điều khiển đồ họa, bạn không cần sisfb trên hạt nhân >=2.6.3.

Sidenote: Vì đây có vẻ là một lỗi thường mắc phải: sisfb và vesafb
không thể hoạt động cùng một lúc! Chỉ chọn một trong số chúng trong kernel của bạn
cấu hình.


Các tham số được truyền tới sisfb như thế nào?
==============================================

Vâng, điều đó còn tùy: Nếu được biên dịch tĩnh vào kernel, hãy sử dụng phần bổ sung của lilo
câu lệnh để thêm các tham số vào dòng lệnh kernel. Xin vui lòng xem lilo
(hoặc tài liệu của GRUB) để biết thêm thông tin. Nếu sisfb là mô-đun hạt nhân,
các tham số được đưa ra bằng lệnh modprobe (hoặc insmod).

Ví dụ về sisfb như một phần của kernel tĩnh: Thêm dòng sau vào
lilo.conf::

chắp thêm="video=sisfb:mode:1024x768x16,mem:12288,tỷ lệ:75"

Ví dụ về sisfb dưới dạng mô-đun: Bắt đầu sisfb bằng cách gõ::

chế độ modprobe sisfb=1024x768x16 rate=75 mem=12288

Một lỗi phổ biến là mọi người sử dụng định dạng tham số sai khi sử dụng
trình điều khiển được biên dịch vào kernel. Xin lưu ý: Nếu được biên dịch vào kernel,
định dạng tham số là video=sisfb:mode:none hoặc video=sisfb:mode:1024x768x16
(hoặc bất kỳ chế độ nào bạn muốn sử dụng, hoặc sử dụng bất kỳ định dạng nào khác
được mô tả ở trên hoặc từ khóa vesa thay vì mode). Nếu được biên dịch dưới dạng một mô-đun,
định dạng tham số đọc mode=none hoặc mode=1024x768x16 (hoặc bất kỳ chế độ nào bạn
muốn sử dụng). Sử dụng dấu "=" cho dấu ://" (và ngược lại) là một sự khác biệt rất lớn!
Ngoài ra: Nếu bạn đưa ra nhiều hơn một đối số cho sisfb trong kernel, thì
các đối số được phân tách bằng dấu ",". Ví dụ::

video=sisfb:chế độ:1024x768x16,tỷ lệ:75,mem:12288


Làm cách nào để sử dụng nó?
===========================

Lời nói đầu: Tập tin này chỉ bao gồm rất ít thông tin về trình điều khiển
khả năng và tính năng. Vui lòng tham khảo tài liệu của tác giả và người bảo trì
trang web tại ZZ0000ZZ để biết thêm
thông tin. Ngoài ra, "modinfo sisfb" cung cấp cái nhìn tổng quan về tất cả
các tùy chọn được hỗ trợ bao gồm một số giải thích.

Chế độ hiển thị mong muốn có thể được chỉ định bằng từ khóa "mode" với
một tham số ở một trong các định dạng sau:

- XxYxDepth hoặc
  - XxY-Độ sâu hoặc
  - XxY-Depth@Rate hoặc
  - XxY
  - hoặc đơn giản là sử dụng số chế độ VESA ở dạng thập lục phân hoặc thập phân.

Ví dụ: 1024x768x16, 1024x768-16@75, 1280x1024-16. Nếu không có độ sâu
được chỉ định, nó mặc định là 8. Nếu không đưa ra tốc độ nào, nó sẽ mặc định là 60Hz. Độ sâu 32
có nghĩa là độ sâu màu 24 bit (nhưng độ sâu bộ đệm khung 32 bit, không liên quan
tới người dùng).

Ngoài ra, sisfb hiểu từ khóa "vesa" theo sau là chế độ VESA
số ở dạng thập phân hoặc thập lục phân. Ví dụ: vesa=791 hoặc vesa=0x117. làm ơn
sử dụng "mode" hoặc "vesa" nhưng không sử dụng cả hai.

Chỉ dành cho Linux 2.4: Nếu không có chế độ nào được cung cấp, sisfb sẽ mặc định là "không có chế độ" (mode=none) nếu
được biên dịch dưới dạng mô-đun; nếu sisfb được biên dịch tĩnh vào kernel, nó
mặc định là 800x600x8 trừ khi loại CRT2 là LCD, trong trường hợp đó là kiểu gốc của LCD
độ phân giải được sử dụng. Nếu bạn muốn chuyển sang chế độ khác, hãy sử dụng fbset
lệnh vỏ.

Chỉ Linux 2.6: Nếu không có chế độ nào được cung cấp, sisfb mặc định là 800x600x8 trừ khi CRT2
loại là LCD, trong trường hợp đó nó mặc định có độ phân giải gốc của LCD. Nếu
bạn muốn chuyển sang chế độ khác thì dùng lệnh stty shell.

Bạn nên biên dịch trong cả vgacon (để khởi động nếu bạn tháo thẻ SiS khỏi
hệ thống của bạn) và sisfb (đối với chế độ đồ họa). Trong Linux 2.6, "Framebuffer
hỗ trợ bảng điều khiển" (fbcon) là cần thiết cho bảng điều khiển đồ họa.

Bạn nên biên dịch ZZ0000ZZ trong vesafb. Và vui lòng không sử dụng từ khóa "vga="
trong tập tin cấu hình của lilo hoặc grub; việc lựa chọn chế độ được thực hiện bằng cách sử dụng
Từ khóa "mode" hoặc "vesa" làm tham số. Xem trên và dưới.


X11
===

Nếu sử dụng XFree86 hoặc X.org, bạn không nên sử dụng "fbdev"
nhưng là trình điều khiển X "sis" chuyên dụng. Trình điều khiển "sis" X và sisfb là
được phát triển bởi cùng một người (Thomas Winischhofer) và hợp tác tốt với
lẫn nhau.


SVGALib
=======

SVGALib nếu truy cập trực tiếp vào phần cứng sẽ không bao giờ khôi phục được màn hình
chính xác, đặc biệt là trên máy tính xách tay hoặc nếu thiết bị đầu ra là LCD hoặc TV.
Do đó, hãy sử dụng chipset "FBDEV" trong cấu hình SVGALib. Điều này sẽ làm cho
SVGALib sử dụng thiết bị bộ đệm khung để chuyển đổi và khôi phục chế độ.


Cấu hình
=============

(Một số) tùy chọn được chấp nhận:

=================================================================================
tắt Tắt sisfb. Tùy chọn này chỉ được hiểu nếu sisfb là
	   trong kernel chứ không phải mô-đun.
mem:X kích thước bộ nhớ cho bảng điều khiển, phần còn lại sẽ được sử dụng cho DRI/DRM. X
	   tính bằng kilobyte. Trên dòng 300, mặc định là 4096, 8192 hoặc
	   16384 (mỗi kilobyte) tùy thuộc vào dung lượng ram video của thẻ
	   có. Trên dòng 315/330 mặc định là ram khả dụng tối đa
	   (vì DRI/DRM không được hỗ trợ cho các chipset này).
noaccel không sử dụng công cụ tăng tốc 2D. (Mặc định: sử dụng khả năng tăng tốc)
noypan vô hiệu hóa tính năng xoay y và cuộn bằng cách vẽ lại toàn bộ màn hình.
	   Điều này chậm hơn nhiều so với y-panning. (Mặc định: sử dụng y-panning)
vesa:X chọn chế độ video khởi động. X là số từ 0 đến 0x1FF và
	   đại diện cho số chế độ VESA (có thể được đưa ra ở dạng thập phân hoặc
	   dạng thập lục phân, dạng sau có tiền tố là "0x").
mode:X chọn chế độ video khởi động. Vui lòng xem ở trên để biết định dạng của
	   "X".
=================================================================================

Các tùy chọn Boolean như "noaccel" hoặc "noypan" sẽ được đưa ra mà không có
tham số nếu sisfb nằm trong kernel (ví dụ "video=sisfb:noypan). Nếu
sisfb là một mô-đun, các mô-đun này phải được đặt thành 1 (ví dụ: "modprobe sisfb
noypan=1").


Thomas Winischhofer <thomas@winischhofer.net>

Ngày 27 tháng 5 năm 2004
