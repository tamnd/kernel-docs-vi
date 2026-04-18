.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/sstfb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====
sstfb
=====

Giới thiệu
============

Đây là trình điều khiển thiết bị đệm khung cho Đồ họa Voodoo của 3dfx
(còn gọi là voodoo 1, còn gọi là sst1) và Voodoo² (còn gọi là Voodoo 2, còn gọi là CVG)
bảng video. Đây là mã mang tính thử nghiệm cao nhưng được đảm bảo hoạt động
trên máy tính của tôi, với bảng "Maxi Gamer 3D" và "Maxi Gamer 3d²",
và với tôi "giữa ghế và bàn phím". Một số người đã thử nghiệm khác
kết hợp và có vẻ như nó hoạt động.
Trang chính được đặt tại <ZZ0000ZZ và nếu
bạn muốn có phiên bản mới nhất, hãy xem CVS, vì trình điều khiển là một tác phẩm
trong quá trình thực hiện, tôi cảm thấy không thoải mái với việc phát hành tarball của thứ gì đó
không hoàn toàn hoạt động...Đừng lo lắng, nó vẫn còn nhiều hơn mức có thể sử dụng được
(Tôi ăn thức ăn cho chó của riêng tôi)

Vui lòng đọc phần Lỗi và báo cáo mọi thành công hay thất bại cho tôi
(Ghozlane Toumi <gtoumi@laposte.net>).
BTW, Nếu bạn chỉ có một màn hình và bạn không muốn chơi
với cáp vga passthrou, tôi chỉ có thể đề nghị mượn màn hình
ở đâu đó...


Cài đặt
============

Trình điều khiển này (phải) hoạt động trên ix86, với kernel 2.2.x "muộn" (đã được kiểm tra
với x = 19) và hạt nhân 2.4.x "gần đây", dưới dạng mô-đun hoặc được biên dịch vào.
Nó đã được đưa vào kernel chính thống kể từ phiên bản 2.4.10 khét tiếng.
Bạn có thể áp dụng các bản vá có trong ZZ0000ZZ,
và sao chép sstfb.c sang linux/drivers/video/ hoặc áp dụng một bản vá duy nhất,
ZZ0001ZZ vào cây nguồn linux của bạn.

Sau đó cấu hình kernel của bạn như bình thường: chọn "m" hoặc "y" để 3Dfx Voodoo
Đồ họa trong phần "console". Biên dịch, cài đặt, vui chơi... và vui lòng
gửi cho tôi một bản báo cáo :)


Cách sử dụng mô-đun
============

.. warning::

       #. You should read completely this section before issuing any command.

       #. If you have only one monitor to play with, once you insmod the
	  module, the 3dfx takes control of the output, so you'll have to
	  plug the monitor to the "normal" video board in order to issue
	  the commands, or you can blindly use sst_dbg_vgapass
	  in the tools directory (See Tools). The latest solution is pass the
	  parameter vgapass=1 when insmodding the driver. (See Kernel/Modules
	  Options)

Chèn mô-đun
----------------

#. insmod sstfb.o

bạn sẽ thấy một số kết quả lạ từ bảng:
	  một hình vuông lớn màu xanh lam, một hình vuông nhỏ màu xanh lá cây và màu đỏ và một hình vuông thẳng đứng
	  hình chữ nhật màu trắng. Tại sao? tên của hàm là tự giải thích:
	  "sstfb_test()"...
	  (nếu bạn không có màn hình thứ hai, bạn sẽ phải cắm màn hình của mình vào
	  trực tiếp đến videocard 2D để xem bạn đang gõ gì)

#. con2fb /dev/fbx /dev/ttyx

liên kết một tty với bộ đệm khung mới. nếu bạn đã có khung
	  trình điều khiển đệm, fb voodoo có thể sẽ là /dev/fb1. nếu không,
	  thiết bị sẽ là /dev/fb0. Bạn có thể kiểm tra điều này bằng cách thực hiện một
	  con mèo /proc/fb. Bạn có thể tìm thấy bản sao của con2fb trong thư mục tools/.
	  nếu bạn không có thiết bị fb khác thì bước này là không cần thiết,
	  vì hệ thống con bảng điều khiển tự động liên kết các tty với fb.
       #. chuyển sang bảng điều khiển ảo bạn vừa ánh xạ. "tadaaaa"...

Loại bỏ mô-đun
--------------

#. con2fb /dev/fbx /dev/ttyx

liên kết tty với bộ đệm khung cũ để có thể xóa mô-đun.
	  (nó hoạt động như thế nào với vgacon? câu trả lời ngắn gọn: nó không hoạt động)

#. rmmod sstfb


Tùy chọn hạt nhân/mô-đun
----------------------

Bạn có thể chuyển một số tùy chọn cho mô-đun sstfb và thông qua kernel
dòng lệnh khi trình điều khiển được biên dịch trong:
cho mô-đun: insmod sstfb.o option1=value1 option2=value2 ...
trong kernel: video=sstfb:option1,option2:value2,option3 ...

sstfb hỗ trợ các tùy chọn sau:

================ ===================================================================
Mô tả hạt nhân mô-đun
================ ===================================================================
vgapass=0 vganopass Bật hoặc tắt cáp truyền qua VGA.
vgapass=1 vgapass Khi được bật, màn hình sẽ nhận được tín hiệu
				từ bảng VGA chứ không phải từ tà thuật.

Mặc định: nopass

mem=x mem:x Buộc bộ nhớ đệm khung trong MiB
				giá trị được phép: 0, 1, 2, 4.

Mặc định: 0 (= tự động phát hiện)

inverse=1 inverse Được cho là để kích hoạt bảng điều khiển nghịch đảo.
				vẫn chưa hoạt động...

clipping=1 clipping Bật hoặc tắt tính năng cắt.
clipping=0 noclipping Khi bật tính năng cắt, tất cả đều ở ngoài màn hình
				đọc và viết bị loại bỏ.

Mặc định: bật cắt.

gfxclk=x gfxclk:x Tần số xung nhịp đồ họa bắt buộc (tính bằng MHz).
				Hãy cẩn thận với tùy chọn này, nó có thể
				DANGEROUS.

Mặc định: tự động

- 50 MHz cho Voodoo 1,
					- 75 MHz cho Voodoo 2.

Slowpci=1 fastpci Bật hoặc tắt tính năng đọc/ghi nhanh PCI.
Slowpci=1 Slowpci Mặc định: fastpci

dev=x dev:x Đính kèm driver vào số thiết bị x.
				0 là bo mạch tương thích đầu tiên (trong
				thứ tự lspci)
================ ===================================================================

Công cụ
=====

Những công cụ này chủ yếu nhằm mục đích gỡ lỗi, nhưng bạn có thể
tìm thấy một số trong những điều thú vị:

- ZZ0000ZZ, ánh xạ tty tới fbramebuffer::

con2fb /dev/fb1 /dev/tty5

- ZZ0000ZZ, chuyển đổi vga passthrou. Bạn phải biên dịch lại
  trình điều khiển có SST_DEBUG và SST_DEBUG_IOCTL được đặt thành 1::

sst_dbg_vgapass /dev/fb1 1 (bật cáp vga)
	sst_dbg_vgapass /dev/fb1 0 (tắt cáp vga)

- ZZ0000ZZ, đặt lại voodoo bằng cách lướt
  sử dụng cái này sau khi sửa đổi sstfb, nếu mô-đun từ chối
  lắp lại.

Lỗi
====

- NOT CÓ sử dụng tính năng lướt khi mô-đun sstfb đang hoạt động không, rất có thể bạn sẽ làm vậy
  treo máy tính của bạn.
- Nếu bạn thấy một số đồ tạo tác (pixel không được làm sạch và những thứ tương tự),
  hãy thử tắt tính năng cắt (cắt=0) và/hoặc sử dụng Slowpci
- trình điều khiển không phát hiện ra các lỗi của bộ đệm khung 4Mb, có vẻ như vậy
  2 Mbs cuối cùng quấn quanh. nhìn vào đó
- Driver chỉ 16 bpp, 24/32 không hoạt động.
- Trình điều khiển không an toàn cho đồ chơi yêu thích của bạn. điều này bao gồm SMP...

[Thực ra qua kiểm tra thì có vẻ an toàn - Alan]

- Khi sử dụng XFree86 FBdev (X over fbdev) bạn có thể thấy màu lạ
  các mẫu ở viền cửa sổ của bạn (các pixel mất mức thấp nhất
  byte -> về cơ bản là thành phần màu xanh lam và một số thành phần màu xanh lá cây). tôi không thể
  để tái tạo điều này bằng XFree86-3.3, nhưng một trong những người thử nghiệm có điều này
  vấn đề với XFree86-4. Rõ ràng Xfree86-4.x gần đây đã giải quyết được vấn đề này
  vấn đề.
- Tôi chưa thực sự thử nghiệm việc thay đổi bảng màu, nên bạn có thể thấy có gì đó kỳ lạ.
  mọi thứ khi chơi với điều đó.
- Đôi khi người lái xe sẽ không nhận ra DAC và
  khởi tạo sẽ thất bại. Điều này đặc biệt đúng đối với
  bảng voodoo 2, nhưng nó cần được giải quyết trong các phiên bản gần đây. làm ơn
  liên hệ với tôi.
- 24/32 khó có thể hoạt động sớm được vì biết rằng
  phần cứng làm ... những điều bất thường trong 24/32 bpp.

việc cần làm
====

- Bỏ đoạn trước đi.
- Mua thêm cà phê đi.
- kiểm tra/port sang vòm khác.
- cố gắng thêm tính năng xoay bằng cách sử dụng các chỉnh sửa với bộ đệm trước và sau.
- hãy thử triển khai accel trên voodoo2, bảng này thực sự có thể làm được
  rất nhiều ở dạng 2D ngay cả khi nó được bán dưới dạng bảng chỉ 3D ...

Ghozlane Toumi <gtoumi@laposte.net>


Ngày: 2002/05/09 20:11:45

ZZ0000ZZ
