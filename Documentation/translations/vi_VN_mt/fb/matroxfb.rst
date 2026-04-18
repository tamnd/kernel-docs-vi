.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/matroxfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
matroxfb - Trình điều khiển bộ đệm khung cho các thiết bị Matrox
================================================================

Đây là trình điều khiển cho bộ đệm khung đồ họa cho các thiết bị Matrox trên
Hộp Alpha, Intel và PPC.

Thuận lợi:

* Nó cung cấp một bảng điều khiển lớn đẹp mắt (128 cols + 48 dòng với 1024x768)
   không sử dụng các phông chữ nhỏ, không thể đọc được.
 * Bạn có thể chạy trình điều khiển fbdev XF{68,86__FBDev hoặc XFree86 trên /dev/fb0
 * Quan trọng nhất: logo khởi động :-)

Nhược điểm:

* Chế độ đồ họa chậm hơn chế độ văn bản...nhưng bạn không nên để ý
   nếu bạn sử dụng độ phân giải giống như bạn đã sử dụng trong chế độ văn bản.


Làm thế nào để sử dụng nó?
==============

Việc chuyển đổi chế độ được thực hiện bằng cách sử dụng tham số khởi động video=matroxfb:vesa:...
hoặc sử dụng chương trình ZZ0000ZZ.

Ví dụ: nếu bạn muốn bật độ phân giải 1280x1024x24bpp, bạn nên
chuyển tới kernel dòng lệnh này: "video=matroxfb:vesa:0x1BB".

Bạn nên biên dịch trong cả vgacon (để khởi động nếu bạn gỡ bỏ Matrox khỏi
box) và matroxfb (đối với chế độ đồ họa). Bạn không nên biên dịch vesafb
trừ khi bạn có màn hình chính trên thiết bị VBE2.0 không phải Matrox (xem
Tài liệu/fb/vesafb.rst để biết chi tiết).

Các chế độ video hiện được hỗ trợ là (thông qua giao diện vesa:..., PowerMac
có mã tương thích [dưới dạng addon]):


Chế độ đồ họa
-------------

=== ======= ======= ======= ======= =======
bpp 640x400 640x480 768x576 800x600 960x720
=== ======= ======= ======= ======= =======
  4 0x12 0x102
  8 0x100 0x101 0x180 0x103 0x188
 15 0x110 0x181 0x113 0x189
 16 0x111 0x182 0x114 0x18A
 24 0x1B2 0x184 0x1B5 0x18C
 32 0x112 0x183 0x115 0x18B
=== ======= ======= ======= ======= =======


Chế độ đồ họa (tiếp theo)
-------------------------

=== ======== =========================== ==========
bpp 1024x768 1152x864 1280x1024 1408x1056 1600x1200
=== ======== =========================== ==========
  4 0x104 0x106
  8 0x105 0x190 0x107 0x198 0x11C
 15 0x116 0x191 0x119 0x199 0x11D
 16 0x117 0x192 0x11A 0x19A 0x11E
 24 0x1B8 0x194 0x1BB 0x19C 0x1BF
 32 0x118 0x193 0x11B 0x19B
=== ======== =========================== ==========


Chế độ văn bản
----------

==== ======= =============== ======== =========
văn bản 640x400 640x480 1056x344 1056x400 1056x480
==== ======= =============== ======== =========
 8x8 0x1C0 0x108 0x10A 0x10B 0x10C
8x16 2, 3, 7 0x109
==== ======= =============== ======== =========

Bạn có thể nhập các số này theo hệ thập lục phân (ZZ0000ZZ đứng đầu) hoặc thập phân
(0x100 = 256). Bạn cũng có thể sử dụng giá trị + 512 để đạt được khả năng tương thích
với số cũ của bạn được chuyển đến vesafb.

Số không được liệt kê có thể đạt được bằng dòng lệnh phức tạp hơn, ví dụ:
ví dụ 1600x1200x32bpp có thể được chỉ định bởi ZZ0000ZZ.


X11
===

XF{68,86__FBDev sẽ hoạt động tốt nhưng không được tăng tốc. Trên không phải intel
kiến trúc có một số trục trặc đối với chế độ video 24bpp. 8, 16 và 32bpp
hoạt động tốt

Chạy một X-Server khác (được tăng tốc) như XF86_SVGA cũng hoạt động. Nhưng (ít nhất)
Máy chủ XFree gặp rắc rối lớn trong cấu hình nhiều đầu (ngay cả trong lần đầu tiên
đầu, thậm chí không nói về thứ hai). Chạy XFree86 4.x tăng tốc mga
có thể sử dụng trình điều khiển, nhưng bạn không được bật DRI - nếu có, độ phân giải và
độ sâu màu của máy tính để bàn X của bạn phải phù hợp với độ phân giải và độ sâu màu của màn hình của bạn.
bảng điều khiển ảo, nếu không X sẽ làm hỏng cài đặt bộ tăng tốc.


SVGALib
=======

Trình điều khiển chứa mã tương thích SVGALib. Nó được bật bằng cách chọn văn bản
chế độ cho bảng điều khiển. Bạn có thể làm điều đó khi khởi động bằng cách sử dụng videomode
2,3,7,0x108-0x10C hoặc 0x1C0. Khi chạy, ZZ0000ZZ thực hiện công việc này.
Thật không may, sau khi thoát ứng dụng SVGALib, nội dung màn hình bị hỏng.
Chuyển sang bảng điều khiển khác và quay lại sửa nó. Tôi hy vọng đó là của SVGALib
vấn đề và không phải của tôi, nhưng tôi không chắc chắn.


Cấu hình
=============

Bạn có thể chuyển các tùy chọn dòng lệnh kernel cho matroxfb bằng
ZZ0000ZZ (nên có nhiều tùy chọn
được phân tách bằng dấu phẩy, các giá trị được phân tách khỏi các tùy chọn bằng ZZ0001ZZ).
Tùy chọn được chấp nhận:

============= =========================================================================
mem: Kích thước X của bộ nhớ (X có thể tính bằng megabyte, kilobyte hoặc byte)
	     Bạn chỉ có thể giảm giá trị do trình điều khiển xác định vì
	     nó luôn thăm dò trí nhớ. Mặc định là sử dụng toàn bộ được phát hiện
	     bộ nhớ có thể sử dụng để hiển thị trên màn hình (tức là tối đa 8 MB).
bị vô hiệu hóa không tải trình điều khiển; bạn cũng có thể sử dụng ZZ0000ZZ, nhưng ZZ0001ZZ
	     cũng ở đây.
đã bật trình điều khiển tải, nếu bạn có ZZ0002ZZ trong LILO
	     cấu hình, bạn có thể ghi đè nó bằng cách này (bạn không thể ghi đè
	     ZZ0003ZZ). Đó là mặc định.
noaccel không sử dụng động cơ tăng tốc. Nó không hoạt động trên Alphas.
tăng tốc sử dụng động cơ tăng tốc. Đó là mặc định.
nopan tạo bảng điều khiển ban đầu với vyres = yres, do đó vô hiệu hóa ảo
	     cuộn.
pan tạo bảng điều khiển ban đầu càng cao càng tốt (vyres = bộ nhớ/vxres).
	     Đó là mặc định.
nopciretry vô hiệu hóa PCI thử lại. Nó cần thiết cho một số chipset bị hỏng,
	     nó được tự động phát hiện cho 82437 của intel. Trong trường hợp này, thiết bị sẽ
	     không tuân thủ các thông số kỹ thuật của PCI 2.1 (nó sẽ không đảm bảo rằng mọi
	     giao dịch chấm dứt thành công hoặc thử lại sau 32 PCLK).
pciretry cho phép thử lại PCI. Đó là mặc định, ngoại trừ 82437 của intel.
novga vô hiệu hóa các cổng I/O VGA. Nó là mặc định nếu BIOS không kích hoạt
	     thiết bị. Bạn không nên sử dụng tùy chọn này, một số bảng thì không
	     khởi động lại mà không tắt nguồn.
vga duy trì trạng thái của các cổng I/O VGA. Đó là mặc định. Người lái xe không
	     bật I/O VGA nếu BIOS chưa bật (không an toàn khi bật nó trong
	     hầu hết các trường hợp).
nobios vô hiệu hóa BIOS ROM. Đó là mặc định nếu BIOS không kích hoạt BIOS
	     chính nó. Bạn không nên sử dụng tùy chọn này, một số bảng thì không
	     khởi động lại mà không tắt nguồn.
trạng thái bảo tồn bios của BIOS ROM. Đó là mặc định. Trình điều khiển không kích hoạt
	     BIOS nếu BIOS chưa được kích hoạt trước đó.
noinit thông báo cho trình điều khiển rằng thiết bị đã được khởi tạo. Bạn nên sử dụng
	     nếu bạn có G100 và/hoặc nếu trình điều khiển không thể phát hiện bộ nhớ, bạn sẽ thấy
	     mô hình lạ trên màn hình và vân vân. Các thiết bị không được kích hoạt bởi BIOS
	     vẫn được khởi tạo. Đó là mặc định.
Trình điều khiển init khởi tạo mọi thiết bị mà nó biết.
memtype chỉ định loại bộ nhớ, ngụ ý 'init'. Điều này chỉ hợp lệ cho G200
	     và G400 và có ý nghĩa như sau:

G200:
		 - 0 -> 2x128Kx32 chip, 2MB onboard, có thể là sgram
		 - 1 -> 2x128Kx32 chip, 4MB onboard, có thể là sgram
		 - 2 -> 2x256Kx32 chip, 4MB onboard, có thể là sgram
		 - 3 -> 2x256Kx32 chip, 8 MB trên bo mạch, có thể là sgram
		 - 4 -> 2x512Kx16 chip, 8/16MB tích hợp, có thể chỉ sdram
		 - 5 -> tương tự như trên
		 - 6 -> 4x128Kx32 chip, 4MB onboard, có thể là sgram
		 - 7 -> 4x128Kx32 chip, 8 MB trên bo mạch, có thể là sgram
	       G400:
		 - 0 -> 2x512Kx16 SDRAM, 16/32MB
		 - 2x512Kx32 SGRAM, 16/32MB
		 - 1 -> 2x256Kx32 SGRAM, 8/16MB
		 - 2 -> 4x128Kx32 SGRAM, 8/16MB
		 - 3 -> 4x512Kx32 SDRAM, 32MB
		 - 4 -> 4x256Kx32 SGRAM, 16/32MB
		 - 5 -> 2x1Mx32 SDRAM, 32MB
		 - 6 -> dành riêng
		 - 7 -> dành riêng

Bạn nên sử dụng tham số sdram hoặc sgram ngoài memtype
	     tham số.
nomtrr vô hiệu hóa việc kết hợp ghi trên bộ đệm khung. Điều này làm chậm trình điều khiển
	     nhưng có báo cáo về sự không tương thích nhỏ giữa GUS DMA và
	     XFree dưới mức tải cao nếu tính năng kết hợp ghi được bật (âm thanh
	     bỏ học).
mtrr cho phép kết hợp ghi trên bộ đệm khung. Nó tăng tốc độ video
	     truy cập nhiều. Đó là mặc định. Bạn phải bật hỗ trợ MTRR
	     trong kernel và CPU của bạn phải có MTRR (fe Pentium II có chúng).
sgram nói với trình điều khiển rằng bạn có Gxx0 với bộ nhớ SGRAM. Nó không có
	     hiệu ứng không có ZZ0000ZZ.
sdram nói với trình điều khiển rằng bạn có Gxx0 với bộ nhớ SDRAM.
	     Đó là một mặc định.
inv24 thay đổi thông số thời gian cho chế độ 24bpp trên Millennium và
	     Thiên niên kỷ II. Chỉ định điều này nếu bạn thấy bóng màu lạ
	     xung quanh các nhân vật.
noinv24 sử dụng thời gian tiêu chuẩn. Đó là mặc định.
đảo ngược màu sắc trên màn hình (đối với màn hình LCD)
noinverse hiển thị màu sắc trung thực trên màn hình. Đó là mặc định.
dev:X liên kết trình điều khiển với thiết bị X. Số trình điều khiển thiết bị từ 0 đến N,
	     trong đó thiết bị 0 là thiết bị ZZ0001ZZ đầu tiên được tìm thấy, 1 giây, v.v.
	     lspci liệt kê các thiết bị theo thứ tự này.
	     Mặc định là thiết bị đã biết ZZ0002ZZ.
nohwcursor vô hiệu hóa con trỏ phần cứng (thay vào đó hãy sử dụng con trỏ phần mềm).
hwcursor kích hoạt con trỏ phần cứng. Đó là mặc định. Nếu bạn đang sử dụng
	     chế độ không tăng tốc (ZZ0003ZZ hoặc ZZ0004ZZ), phần mềm
	     con trỏ được sử dụng (ngoại trừ chế độ văn bản).
noblink vô hiệu hóa nhấp nháy con trỏ. Con trỏ ở chế độ văn bản luôn nhấp nháy (hw
	     hạn chế).
nhấp nháy cho phép con trỏ nhấp nháy. Đó là mặc định.
nofastfont vô hiệu hóa tính năng fastfont. Đó là mặc định.
fastfont:X kích hoạt tính năng fastfont. X chỉ định kích thước bộ nhớ dành riêng cho
	     dữ liệu phông chữ, nó phải là >= (fontwidth*fontheight*chars_in_font)/8.
	     Nó nhanh hơn trên dòng Gx00 nhưng chậm hơn trên các thẻ cũ.
thang độ xám cho phép tính tổng thang độ xám. Nó hoạt động ở chế độ PSEUDOCOLOR (văn bản,
	     4bpp, 8bpp). Trong chế độ DIRECTCOLOR, nó bị giới hạn ở các ký tự
	     được hiển thị thông qua putc/putcs. Truy cập trực tiếp vào bộ đệm khung
	     có thể vẽ màu.
nograyscale vô hiệu hóa tổng hợp thang độ xám. Đó là mặc định.
cross4MB cho phép dòng pixel đó có thể vượt qua ranh giới 4MB. Nó được mặc định cho
	     phi thiên niên kỷ.
Dòng pixel nocross4MB không được vượt quá ranh giới 4MB. Nó được mặc định cho
	     Thiên niên kỷ I hoặc II, vì những thiết bị này có phần cứng
	     những hạn chế không cho phép điều này. Nhưng lựa chọn này là
	     không tương thích với một số phiên bản (nếu chưa phải tất cả đã được phát hành) của
	     XF86_FBDev.
dfp cho phép giao diện màn hình phẳng kỹ thuật số. Tùy chọn này không tương thích
	     với đầu ra thứ cấp (TV) - nếu DFP đang hoạt động, đầu ra TV phải ở mức
	     không hoạt động và ngược lại. DFP luôn sử dụng thời gian giống như chính
	     (giám sát) đầu ra.
dfp:X sử dụng cài đặt X cho giao diện màn hình phẳng kỹ thuật số. X là số từ
	     0 đến 0xFF và ý nghĩa của từng bit riêng lẻ được mô tả trong
	     Hướng dẫn sử dụng G400, trong phần mô tả thanh ghi DAC 0x1F. Đối với bình thường
	     hoạt động bạn nên đặt tất cả các bit về 0, ngoại trừ bit thấp nhất. Cái này
	     bit thấp nhất chọn ai là nguồn của đồng hồ hiển thị, cho dù G400,
	     hoặc bảng điều khiển. Giá trị mặc định bây giờ được đọc lại từ phần cứng - vì vậy bạn
	     chỉ nên chỉ định giá trị này nếu bạn cũng đang sử dụng ZZ0005ZZ
	     tham số.
đầu ra:XYZ đặt ánh xạ giữa CRTC và đầu ra. Mỗi chữ cái có thể có giá trị
	     trong số 0 (không có CRTC), 1 (CRTC1) hoặc 2 (CRTC2) và chữ cái đầu tiên
	     tương ứng với đầu ra analog chính, chữ cái thứ hai của
	     đầu ra analog thứ cấp và chữ cái thứ ba cho đầu ra DVI.
	     Cài đặt mặc định là 100 cho các thẻ dưới G400 hoặc G400 không có DFP,
	     101 cho G400 với DFP và 111 cho G450 và G550. Bạn có thể thiết lập
	     chỉ ánh xạ trên thẻ đầu tiên, sử dụng matroxset để thiết lập thẻ khác
	     thiết bị.
vesa:X chọn chế độ video khởi động. X là số từ 0 đến 0x1FF, xem bảng
	     ở trên để được giải thích chi tiết. Mặc định là 640x480x8bpp nếu có driver
	     có hỗ trợ 8bpp. Nếu không thì lần đầu tiên có sẵn 640x350x4bpp,
	     Văn bản 640x480x15bpp, 640x480x24bpp, 640x480x32bpp hoặc 80x25
	     (văn bản 80x25 luôn có sẵn).
============= =========================================================================

Nếu bạn không hài lòng với chế độ video được chọn bởi tùy chọn ZZ0000ZZ, bạn
có thể sửa đổi nó bằng các tùy chọn sau:

============= =========================================================================
xres:X độ phân giải ngang, tính bằng pixel. Mặc định có nguồn gốc từ ZZ0000ZZ
	     tùy chọn.
yres:X độ phân giải dọc, tính bằng dòng pixel. Mặc định có nguồn gốc từ ZZ0001ZZ
	     tùy chọn.
ranh giới trên: X trên cùng: các đường giữa điểm cuối của xung VSYNC và điểm bắt đầu của xung đầu tiên
	     dòng pixel của hình ảnh. Mặc định bắt nguồn từ tùy chọn ZZ0002ZZ.
dưới:X ranh giới dưới cùng: các đường giữa phần cuối của hình ảnh và phần đầu của VSYNC
	     nhịp đập. Mặc định bắt nguồn từ tùy chọn ZZ0003ZZ.
vslen:X độ dài của xung VSYNC, tính theo dòng. Mặc định có nguồn gốc từ ZZ0004ZZ
	     tùy chọn.
trái:X ranh giới bên trái: các pixel giữa đầu xung HSYNC và pixel đầu tiên.
	     Mặc định bắt nguồn từ tùy chọn ZZ0005ZZ.
phải:X ranh giới bên phải: pixel giữa phần cuối của hình ảnh và phần đầu của HSYNC
	     nhịp đập. Mặc định bắt nguồn từ tùy chọn ZZ0006ZZ.
hslen:X độ dài của xung HSYNC, tính bằng pixel. Mặc định có nguồn gốc từ ZZ0007ZZ
	     tùy chọn.
pixclock:X dotclock, tính bằng ps (pico giây). Mặc định có nguồn gốc từ ZZ0008ZZ
	     tùy chọn và từ các tùy chọn ZZ0009ZZ và ZZ0010ZZ.
đồng bộ hóa: Đồng bộ hóa X. xung - bit 0 đảo ngược cực HSYNC, bit 1 VSYNC phân cực.
	     Nếu bit 3 (giá trị 0x08) được đặt, đồng bộ hóa tổng hợp thay vì HSYNC sẽ được thực hiện
	     được tạo ra. Nếu bit 5 (giá trị 0x20) được đặt, đồng bộ hóa sẽ chuyển sang màu xanh lục
	     trên. Đừng quên rằng nếu bạn muốn đồng bộ hóa với màu xanh lục, bạn cũng có thể
	     muốn đồng bộ hóa tổng hợp.
	     Mặc định phụ thuộc vào ZZ0011ZZ.
độ sâu:X Bit trên mỗi pixel: 0=văn bản, 4,8,15,16,24 hoặc 32. Mặc định tùy thuộc vào
	     ZZ0012ZZ.
============= =========================================================================

Nếu bạn biết khả năng của màn hình, bạn có thể chỉ định một số (hoặc tất cả)
ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ. Trong trường hợp này, ZZ0003ZZ được tính sao cho
pixclock <= maxclk, real_fh <= fh và real_fv <= fv.

============= ========================================================================
maxclk:X dotclock tối đa. X có thể được chỉ định bằng MHz, kHz hoặc Hz. Mặc định là
	     `don`t care`.
fh:X         maximum horizontal synchronization frequency. X can be specified
	     in kHz or Hz. Default is `không quan tâm`.
fv:X         maximum vertical frequency. X must be specified in Hz. Default is
	     70 for modes derived from `vesa` với yres <= 400, 60Hz cho
	     năm > 400.
============= ========================================================================


Hạn chế
===========

Có những lỗi, tính năng và tính năng sai đã biết và chưa biết.
Hiện tại có các lỗi đã biết sau:

- SVGALib không khôi phục màn hình khi thoát
 - quy trình fbcon-cfbX chung không hoạt động trên Alpha. Vì điều này,
   Trình điều khiển ZZ0000ZZ (và cfb4 accel) không hoạt động trên Alpha. Vì vậy mọi người
   với quyền truy cập vào ZZ0001ZZ trên Alpha có thể treo máy (bạn nên hạn chế
   truy cập vào ZZ0002ZZ - mọi người có quyền truy cập vào thiết bị này đều có thể phá hủy
   màn hình của bạn, tin tôi đi...).
 - 24bpp không hỗ trợ chính xác XF-FBDev trên kiến ​​trúc big-endian.
 - chế độ văn bản xen kẽ không được hỗ trợ; có vẻ như giới hạn phần cứng,
   nhưng tôi không chắc chắn.
 - Gxx0 SGRAM/SDRAM không được tự động phát hiện.
 - có thể hơn nữa...

Và những lỗi sai sau:

- SVGALib không khôi phục màn hình khi thoát.
 - pixclock cho chế độ văn bản bị giới hạn bởi phần cứng

- 83 MHz trên G200
    - 66 MHz trên Thiên niên kỷ I
    - 60 MHz trên Thiên niên kỷ II

Vì tôi không thể truy cập vào các thiết bị khác nên tôi không biết cụ thể
   tần số cho chúng. Vì vậy, trình điều khiển không kiểm tra điều này và cho phép bạn
   đặt tần số cao hơn mức này. Nó gây ra tia lửa, lỗ đen và các hiện tượng khác
   hiệu ứng đẹp mắt trên màn hình. Thiết bị không bị phá hủy trong quá trình thử nghiệm. :-)
 - bộ tạo dao động Millennium G200 của tôi có dải tần từ 35 MHz đến 380 MHz
   (và nó hoạt động với 8bpp trên các xung nhịp khoảng 320 MHz (và đã thay đổi mclk)).
   Nhưng Matrox nói trên tờ sản phẩm rằng giới hạn VCO là 50-250 MHz, vì vậy tôi tin
   chúng (có thể con chip đó quá nóng, nhưng nó có bộ làm mát rất lớn (G100 có
   không có), vì vậy nó sẽ hoạt động).
 - các chế độ video đồ họa/video hỗn hợp đặc biệt của Mystique và Gx00 - 2G8V16 và
   G16V16 không được hỗ trợ
 - phím màu không được hỗ trợ
 - tính năng kết nối của Mystique và Gx00 được đặt ở chế độ VGA (nó bị tắt
   bởi BIOS)
 - DDC (phát hiện màn hình) được hỗ trợ thông qua trình điều khiển hai đầu
 - một số kiểm tra đối với các giá trị đầu vào không quá nghiêm ngặt như thế nào (bạn có thể
   chỉ định vslen=4000, v.v.).
 - có thể hơn nữa...

Và các tính năng sau:

- 4bpp chỉ có ở Thiên niên kỷ I và Thiên niên kỷ II. Nó là phần cứng
   hạn chế.
 - việc lựa chọn giữa chế độ video 1:5:5:5 và 5:6:5 16bpp được thực hiện bởi -rgba
   tùy chọn của fbset: "fbset -deep 16 -rgba 5,5,5" chọn 1:5:5:5, bất cứ thứ gì
   nếu không thì chọn chế độ 5:6:5.
 - chế độ văn bản sử dụng bảng màu VGA 6 bit thay vì 8 bit (một trong 262144 màu
   thay vì một trong 16 triệu màu). Đó là do hạn chế về phần cứng của
   Khả năng tương thích của Millennium I/II và SVGALib.


Điểm chuẩn
==========
Đã đến lúc vẽ lại toàn bộ màn hình 1000 lần ở 1024x768, 60Hz. Đó là
thời gian để vẽ 6144000 ký tự trên màn hình thông qua/dev/vcsa
(đối với 32bpp thì khoảng 3GB dữ liệu (chính xác là 3000 MB); đối với phông chữ 8x16 ở
16 giây, tức là 187 MBps).
Thời gian được lấy từ một phiên bản trình điều khiển cũ hơn, hiện tại là khoảng 3%
nhanh hơn, đó là thời gian chỉ dành cho không gian hạt nhân trên P-II/350 MHz, Thiên niên kỷ I ở 33 MHz
Khe PCI, G200 trong khe AGP 2x. Tôi chưa kiểm tra vgacon ::

NOACCEL
	8x16 12x22
	Thiên niên kỷ I G200 Thiên niên kỷ I G200
  8bpp 16,42 9,54 12,33 9,13
  16 điểm 21,00 15,70 19,11 15,02
  24bpp 36,66 36,66 35,00 35,00
  32bpp 35,00 30,00 33,85 28,66

ACCEL, nofastfont
	8x16 12x22 6x11
	Thiên niên kỷ I G200 Thiên niên kỷ I G200 Thiên niên kỷ I G200
  8bpp 7,79 7,24 13,55 7,78 30,00 21,01
  16bpp 9,13 7,78 16,16 7,78 30,00 21,01
  24bpp 14,17 10,72 18,69 10,24 34,99 21,01
  32bpp 16,15 16,16 18,73 13,09 34,99 21,01

ACCEL, phông chữ nhanh
	8x16 12x22 6x11
	Thiên niên kỷ I G200 Thiên niên kỷ I G200 Thiên niên kỷ I G200
  8bpp 8,41 6,01 6,54 4,37 16,00 10,51
  16 điểm 9,54 9,12 8,76 6,17 17,52 14,01
  24bpp 15,00 12,36 11,67 10,00 22,01 18,32
  32bpp 16,18 18,29* 12,71 12,74 24,44 21,00

TEXT
	8x16
	Thiên niên kỷ I G200
  TEXT 3.29 1.50

* Đúng, nó chậm hơn Thiên niên kỷ I.


Đầu kép G400
=============
Trình điều khiển hỗ trợ G400 đầu kép với một số hạn chế:
 + đầu phụ chia sẻ bộ nhớ video với đầu chính. Nó không phải là vấn đề
   nếu bạn có 32 MB videoram, nhưng nếu bạn chỉ có 16 MB, bạn có thể có
   suy nghĩ kỹ trước khi chọn chế độ video (ví dụ: hai lần 1880x1440x32bpp
   là không thể).
 + do hạn chế về phần cứng nên đầu thứ cấp chỉ dùng được 16 và 32bpp
   videomodes.
 + đầu thứ cấp không tăng tốc. Có vấn đề tồi tệ với việc tăng tốc
   XFree khi đầu thứ cấp sử dụng để tăng tốc.
 + đầu phụ luôn cấp nguồn ở chế độ video 640x480@60-32. Bạn phải sử dụng
   fbset để thay đổi chế độ này.
 + đầu phụ luôn cấp nguồn ở chế độ màn hình. Bạn phải sử dụng fbmatroxset
   để thay đổi nó sang chế độ TV. Ngoài ra, bạn phải chọn ít nhất 525 dòng cho
   Đầu ra NTSC và 625 dòng cho đầu ra PAL.
 + kernel chưa sẵn sàng hoàn toàn với nhiều đầu. Vì thế có một số việc không thể thực hiện được.
 + nếu biên dịch thành module thì phải chèn i2c-matroxfb, matroxfb_maven
   và matroxfb_crtc2 vào kernel.


Đầu kép G450
=============
Trình điều khiển hỗ trợ G450 đầu kép với một số hạn chế:
 + đầu phụ chia sẻ bộ nhớ video với đầu chính. Nó không phải là vấn đề
   nếu bạn có 32 MB videoram, nhưng nếu bạn chỉ có 16 MB, bạn có thể có
   hãy suy nghĩ kỹ trước khi chọn chế độ video.
 + do hạn chế về phần cứng nên đầu thứ cấp chỉ dùng được 16 và 32bpp
   videomodes.
 + đầu thứ cấp không tăng tốc.
 + đầu phụ luôn cấp nguồn ở chế độ video 640x480@60-32. Bạn phải sử dụng
   fbset để thay đổi chế độ này.
 + Đầu ra TV không được hỗ trợ
 + kernel chưa hoàn toàn sẵn sàng cho nhiều đầu nên không thể thực hiện được một số việc.
 + nếu biên dịch thành module thì phải chèn matroxfb_g450 và matroxfb_crtc2
   vào hạt nhân.

Petr Vandrovec <vandrove@vc.cvut.cz>
