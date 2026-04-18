.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/fbcon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Bảng điều khiển bộ đệm khung
=======================

Bảng điều khiển bộ đệm khung (fbcon), như tên gọi của nó, là một văn bản
bảng điều khiển chạy trên thiết bị bộ đệm khung. Nó có chức năng của
bất kỳ trình điều khiển bảng điều khiển văn bản tiêu chuẩn nào, chẳng hạn như bảng điều khiển VGA, có bổ sung
các tính năng có thể được quy cho tính chất đồ họa của bộ đệm khung.

Trong kiến trúc x86, bảng điều khiển bộ đệm khung là tùy chọn và
một số thậm chí còn coi nó như một món đồ chơi. Đối với các kiến trúc khác, nó là kiến trúc duy nhất có sẵn
thiết bị hiển thị, văn bản hoặc đồ họa.

Các tính năng của fbcon là gì?  Bảng điều khiển bộ đệm khung hỗ trợ
độ phân giải cao, các loại phông chữ khác nhau, xoay màn hình, nhiều đầu nguyên thủy,
v.v. Về mặt lý thuyết, phông chữ nhiều màu, trộn, đặt răng cưa và bất kỳ tính năng nào
cũng có thể được cung cấp bởi card đồ họa cơ bản.

A. Cấu hình
================

Bảng điều khiển bộ đệm khung có thể được kích hoạt bằng cách sử dụng kernel yêu thích của bạn
công cụ cấu hình.  Nó nằm trong Trình điều khiển thiết bị->Hỗ trợ đồ họa->
Hỗ trợ trình điều khiển hiển thị bảng điều khiển->Hỗ trợ bảng điều khiển Framebuffer.
Chọn 'y' để biên dịch hỗ trợ tĩnh hoặc 'm' để hỗ trợ mô-đun.  các
mô-đun sẽ là fbcon.

Để fbcon kích hoạt, cần có ít nhất một trình điều khiển bộ đệm khung
được yêu cầu, vì vậy hãy chọn từ bất kỳ trình điều khiển nào trong số rất nhiều trình điều khiển có sẵn. Dành cho x86
hệ thống, hầu như chúng đều có thẻ VGA, vì vậy vga16fb và vesafb sẽ
luôn có sẵn. Tuy nhiên, việc sử dụng trình điều khiển dành riêng cho chipset sẽ cung cấp cho bạn
nhiều tốc độ và tính năng hơn, chẳng hạn như khả năng thay đổi chế độ video
một cách năng động.

Để hiển thị logo chim cánh cụt chọn logo bất kỳ có sẵn trong Graphics
hỗ trợ->Biểu tượng khởi động.

Ngoài ra, bạn sẽ cần phải chọn ít nhất một phông chữ được biên dịch sẵn, nhưng nếu
bạn không làm gì cả, công cụ cấu hình kernel sẽ chọn một cái cho bạn,
thường là phông chữ 8x16.

.. admonition:: GOTCHA

   A common bug report is enabling the framebuffer without enabling the
   framebuffer console.  Depending on the driver, you may get a blanked or
   garbled display, but the system still boots to completion.  If you are
   fortunate to have a driver that does not alter the graphics chip, then you
   will still get a VGA console.

B. Đang tải
==========

Các tình huống có thể xảy ra:

1. Driver và fbcon được biên dịch tĩnh

Thông thường, fbcon sẽ tự động chiếm quyền điều khiển bảng điều khiển của bạn. Điều đáng chú ý
	 ngoại lệ là vesafb.  Nó cần được kích hoạt rõ ràng bằng
	 vga= tham số tùy chọn khởi động.

2. Driver được biên dịch tĩnh, fbcon được biên dịch dưới dạng mô-đun

Tùy thuộc vào trình điều khiển, bạn có thể nhận được bảng điều khiển tiêu chuẩn hoặc
	 hiển thị bị cắt xén, như đã đề cập ở trên.  Để có được bảng điều khiển bộ đệm khung,
	 thực hiện 'modprobe fbcon'.

3. Driver được biên dịch dưới dạng module, fbcon được biên dịch tĩnh

Bạn nhận được bảng điều khiển tiêu chuẩn của bạn.  Khi trình điều khiển được tải với
	 'modprobe xxxfb', fbcon tự động chiếm quyền điều khiển bảng điều khiển với
	 ngoại lệ có thể xảy ra khi sử dụng tùy chọn fbcon=map:n. Xem bên dưới.

4. Driver và fbcon được biên dịch dưới dạng mô-đun.

Bạn có thể tải chúng theo thứ tự bất kỳ. Sau khi cả hai được tải, fbcon sẽ thực hiện
	 trên bảng điều khiển.

C. Tùy chọn khởi động
===============

Bảng điều khiển bộ đệm khung có một số tùy chọn khởi động mà phần lớn chưa được biết đến
	 có thể thay đổi hành vi của nó.

1. fbcon=font:<name>

Chọn phông chữ ban đầu để sử dụng. Giá trị 'tên' có thể là bất kỳ
	phông chữ được biên dịch sẵn: 10x18, 6x10, 6x8, 7x14, Acorn8x8, MINI4x6,
	PEARL8x8, ProFont6x11, SUN12x22, SUN8x16, TER16x32, VGA8x16, VGA8x8.

Lưu ý, không phải driver nào cũng xử lý được phông chữ có chiều rộng không chia hết cho 8,
	chẳng hạn như vga16fb.


2. fbcon=map:<0123>

Đây là một lựa chọn thú vị. Nó cho biết trình điều khiển nào được ánh xạ tới
	bảng điều khiển nào. Giá trị '0123' là một chuỗi được lặp lại cho đến khi
	tổng chiều dài là 64 là số lượng bảng điều khiển có sẵn. trong
	ví dụ trên, nó được mở rộng thành 012301230123... và ánh xạ
	sẽ là::

tty | 1 2 3 4 5 6 7 8 9 ...
		fb | 0 1 2 3 0 1 2 3 0 ...

('cat /proc/fb' sẽ cho bạn biết số fb là gì)

Một tác dụng phụ có thể hữu ích là sử dụng giá trị bản đồ vượt quá
	số lượng trình điều khiển fb được tải. Ví dụ: nếu chỉ có một trình điều khiển
	có sẵn, fb0, việc thêm fbcon=map:1 sẽ yêu cầu fbcon không tiếp quản
	bảng điều khiển.

Sau này, khi bạn muốn ánh xạ bảng điều khiển tới bộ đệm khung
	thiết bị, bạn có thể sử dụng tiện ích con2fbmap.

3. fbcon=vc:<n1>-<n2>

Tùy chọn này yêu cầu fbcon chỉ tiếp quản một loạt bảng điều khiển như
	được chỉ định bởi các giá trị 'n1' và 'n2'. Phần còn lại của bảng điều khiển
	ngoài phạm vi nhất định vẫn sẽ được kiểm soát bởi tiêu chuẩn
	trình điều khiển bảng điều khiển.

	.. note::
	   For x86 machines, the standard console is the VGA console which
	   is typically located on the same video card.  Thus, the consoles that
	   are controlled by the VGA console will be garbled.

4. fbcon=xoay:<n>

Tùy chọn này thay đổi góc định hướng của màn hình bảng điều khiển. các
	giá trị 'n' chấp nhận như sau:

- 0 - hướng bình thường (0 độ)
	    - 1 - hướng theo chiều kim đồng hồ (90 độ)
	    - 2 - hướng lộn ngược (180 độ)
	    - 3 - hướng ngược chiều kim đồng hồ (270 độ)

Góc có thể được thay đổi bất cứ lúc nào sau đó bằng cách 'tiếng vang' tương tự
	số cho bất kỳ một trong 2 thuộc tính được tìm thấy trong
	/sys/class/graphics/fbcon:

- xoay - xoay màn hình của bảng điều khiển đang hoạt động
		- xoay_all - xoay màn hình của tất cả các bảng điều khiển

Xoay bảng điều khiển sẽ chỉ khả dụng nếu Bảng điều khiển Framebuffer
	Hỗ trợ xoay được biên dịch trong kernel của bạn.

	.. note::
	   This is purely console rotation.  Any other applications that
	   use the framebuffer will remain at their 'normal' orientation.
	   Actually, the underlying fb driver is totally ignorant of console
	   rotation.

5. fbcon=lề:<color>

Tùy chọn này chỉ định màu của lề. Biên độ là
	khu vực còn sót lại ở bên phải và phía dưới màn hình không
	được sử dụng bởi văn bản. Theo mặc định, khu vực này sẽ có màu đen. Giá trị 'màu'
	là một số nguyên phụ thuộc vào trình điều khiển bộ đệm khung đang được sử dụng.

6. fbcon=nodefer

Nếu hạt nhân được biên dịch với sự hỗ trợ tiếp quản fbcon bị trì hoãn, thông thường
	nội dung của bộ đệm khung, được giữ lại bởi phần sụn/bộ nạp khởi động, sẽ
	được giữ nguyên cho đến khi thực sự có một số văn bản được xuất ra bảng điều khiển.
	Tùy chọn này khiến fbcon liên kết ngay lập tức với thiết bị fbdev.

7. fbcon=logo-pos:<location>

'Vị trí' duy nhất có thể là 'trung tâm' (không có dấu ngoặc kép) và khi
	nhất định, logo khởi động được di chuyển từ góc trên bên trái mặc định
	vị trí ở giữa bộ đệm khung. Nếu có nhiều hơn một logo
	được hiển thị do có nhiều CPU, dòng logo được thu thập sẽ bị di chuyển
	như một tổng thể.

8. fbcon=logo-count:<n>

Giá trị 'n' ghi đè số lượng logo khởi động. 0 vô hiệu hóa
	logo và -1 đưa ra giá trị mặc định là số lượng CPU trực tuyến.

D. Gắn, tháo và dỡ
=====================================

Trước khi tiếp tục cách gắn, tháo và dỡ bảng điều khiển bộ đệm khung, một
minh họa về sự phụ thuộc có thể giúp ích.

Lớp bảng điều khiển, giống như hầu hết các hệ thống con, cần một trình điều khiển có giao diện với
phần cứng. Do đó, trong bảng điều khiển VGA::

bảng điều khiển ---> Trình điều khiển VGA ---> phần cứng.

Giả sử trình điều khiển VGA có thể được tải xuống, trước tiên người ta phải hủy liên kết trình điều khiển VGA
từ lớp bảng điều khiển trước khi dỡ bỏ trình điều khiển.  Trình điều khiển VGA không thể được
được dỡ bỏ nếu nó vẫn bị ràng buộc với lớp giao diện điều khiển. (Xem
Documentation/driver-api/console.rst để biết thêm thông tin).

Điều này phức tạp hơn trong trường hợp bảng điều khiển bộ đệm khung (fbcon),
vì fbcon là lớp trung gian giữa bảng điều khiển và trình điều khiển ::

bảng điều khiển ---> fbcon ---> trình điều khiển fbdev ---> phần cứng

Trình điều khiển fbdev không thể được tải nếu bị ràng buộc với fbcon và fbcon không thể
sẽ được dỡ bỏ nếu nó bị ràng buộc với lớp bảng điều khiển.

Vì vậy, để dỡ bỏ trình điều khiển fbdev, trước tiên người ta phải hủy liên kết fbcon khỏi bảng điều khiển,
sau đó hủy liên kết trình điều khiển fbdev khỏi fbcon.  May mắn thay, việc hủy liên kết fbcon khỏi
lớp bảng điều khiển sẽ tự động hủy liên kết trình điều khiển bộ đệm khung khỏi
fbcon. Vì vậy, không cần phải hủy liên kết rõ ràng trình điều khiển fbdev khỏi
fbcon.

Vậy làm cách nào để hủy liên kết fbcon khỏi bảng điều khiển? Một phần câu trả lời nằm ở
Tài liệu/driver-api/console.rst. Để tóm tắt:

Báo lại một giá trị cho tệp liên kết đại diện cho bảng điều khiển bộ đệm khung
người lái xe. Vì vậy, giả sử vtcon1 đại diện cho fbcon, thì::

echo 1 > /sys/class/vtconsole/vtcon1/bind - đính kèm bảng điều khiển bộ đệm khung vào
					     lớp điều khiển
  echo 0 > /sys/class/vtconsole/vtcon1/bind - tách bảng điều khiển bộ đệm khung khỏi
					     lớp điều khiển

Nếu fbcon được tách khỏi lớp bảng điều khiển, trình điều khiển bảng điều khiển khởi động của bạn (là
thường là chế độ văn bản VGA) sẽ tiếp quản.  Một số trình điều khiển (rivafb và i810fb) sẽ
khôi phục chế độ văn bản VGA cho bạn.  Với phần còn lại, trước khi tách fbcon, bạn
phải thực hiện thêm một số bước để đảm bảo rằng chế độ văn bản VGA của bạn được
được khôi phục đúng cách. Sau đây là một trong nhiều phương pháp mà bạn có thể thực hiện:

1. Tải xuống hoặc cài đặt vbetool.  Tiện ích này được bao gồm trong hầu hết
   phân phối hiện nay và thường là một phần của công cụ tạm dừng/tiếp tục.

2. Trong cấu hình kernel của bạn, đảm bảo rằng CONFIG_FRAMEBUFFER_CONSOLE được đặt
   thành 'y' hoặc 'm'. Kích hoạt một hoặc nhiều trình điều khiển bộ đệm khung yêu thích của bạn.

3. Khởi động vào chế độ văn bản và chạy root::

vbetool vbestate lưu > <tập tin trạng thái vga>

Lệnh trên lưu nội dung đăng ký của đồ họa của bạn
   phần cứng vào <tập tin trạng thái vga>.  Bạn chỉ cần thực hiện bước này một lần vì
   tập tin trạng thái có thể được sử dụng lại.

4. Nếu fbcon được biên dịch dưới dạng mô-đun, hãy tải fbcon bằng cách thực hiện ::

modprobe fbcon

5. Bây giờ tách fbcon::

khôi phục vbetool vbestate < <tệp trạng thái vga> && \
       echo 0 > /sys/class/vtconsole/vtcon1/bind

6. Thế là xong, bạn quay lại chế độ VGA. Và nếu bạn đã biên dịch fbcon dưới dạng một mô-đun,
   bạn có thể dỡ nó bằng 'rmmod fbcon'.

7. Để gắn lại fbcon::

echo 1 > /sys/class/vtconsole/vtcon1/bind

8. Sau khi fbcon được giải phóng, tất cả các trình điều khiển đã đăng ký vào hệ thống cũng sẽ
   trở nên không bị ràng buộc.  Điều này có nghĩa là fbcon và trình điều khiển bộ đệm khung riêng lẻ
   có thể được dỡ hoặc tải lại theo ý muốn. Tải lại trình điều khiển hoặc fbcon sẽ
   tự động liên kết bảng điều khiển, fbcon và trình điều khiển với nhau. Đang dỡ hàng
   tất cả các driver mà không dỡ bỏ fbcon sẽ khiến cho việc
   console để liên kết fbcon.

Lưu ý dành cho người dùng vesafb:
=======================

Thật không may, nếu dòng khởi động của bạn bao gồm tham số vga=xxx đặt
phần cứng ở chế độ đồ họa chẳng hạn như khi tải vesafb thì vgacon sẽ không tải.
Thay vào đó, vgacon sẽ thay thế bảng điều khiển khởi động mặc định bằng dummycon, và bạn
sẽ không nhận được bất kỳ màn hình nào sau khi tách fbcon. Máy của bạn vẫn còn sống, vậy
bạn có thể gắn lại vesafb. Tuy nhiên, để gắn lại vesafb, bạn cần thực hiện một trong
sau đây:

Biến thể 1:

Một. Trước khi tách fbcon, hãy làm::

vbetool vbemode save > <tệp trạng thái vesa> # do một lần cho mỗi chế độ vesafb,
						 Tệp # the có thể được sử dụng lại

b. Tách fbcon như bước 5.

c. Đính kèm fbcon::

khôi phục vbetool vbestate < <tệp trạng thái vesa> && \
	echo 1 > /sys/class/vtconsole/vtcon1/bind

Biến thể 2:

Một. Trước khi tách fbcon, hãy làm::

echo <ID> > /sys/class/tty/console/bind

vbetool vbemode lấy

b. Lưu ý số chế độ

b. Tách fbcon như bước 5.

c. Đính kèm fbcon::

vbetool vbemode đặt <số chế độ> && \
	echo 1 > /sys/class/vtconsole/vtcon1/bind

Mẫu:
========

Dưới đây là 2 tập lệnh bash mẫu mà bạn có thể sử dụng để liên kết hoặc hủy liên kết
trình điều khiển bảng điều khiển bộ đệm khung nếu bạn đang sử dụng hộp X86::

#!/bin/bash
  fbcon # Unbind

# Change này tới nơi chứa tệp vgastate thực tế của bạn
  # Or Sử dụng VGASTATE=$1 để biểu thị tệp trạng thái khi chạy
  VGASTATE=/tmp/vgastate

# path sang vbetool
  VBETOOL=/usr/local/bin


cho (( i = 0; i < 16; i++))
  làm
    if test -x /sys/class/vtconsole/vtcon$i; sau đó
	nếu [ ZZ0000ZZ \
	     = 1]; sau đó
	    nếu kiểm tra -x $VBETOOL/vbetool; sau đó
	       echo Hủy liên kết vtcon$i
	       Khôi phục vbestate $VBETOOL/vbetool < $VGASTATE
	       echo 0 > /sys/class/vtconsole/vtcon$i/bind
	    fi
	fi
    fi
  xong

--------------------------------------------------------------------------

::

#!/bin/bash
  fbcon # Bind

cho (( i = 0; i < 16; i++))
  làm
    if test -x /sys/class/vtconsole/vtcon$i; sau đó
	nếu [ ZZ0000ZZ \
	     = 1]; sau đó
	  echo Hủy liên kết vtcon$i
	  echo 1 > /sys/class/vtconsole/vtcon$i/bind
	fi
    fi
  xong

Antonino Daplas <adaplas@pol.net>
