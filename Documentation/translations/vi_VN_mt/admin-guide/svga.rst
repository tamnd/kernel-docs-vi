.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/svga.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

====================================
Hỗ trợ lựa chọn chế độ video 2.13
=================================

:Bản quyền: ZZ0000ZZ 1995--1999 Martin Mares, <mj@ucw.cz>

giới thiệu
~~~~~

Tài liệu nhỏ này mô tả tính năng "Lựa chọn chế độ video"
cho phép sử dụng nhiều chế độ video đặc biệt được hỗ trợ bởi video BIOS. Đến hạn
đối với việc sử dụng BIOS, việc lựa chọn bị giới hạn ở thời gian khởi động (trước khi
quá trình giải nén kernel bắt đầu) và chỉ hoạt động trên các máy 80X86
được khởi động thông qua phần sụn BIOS (trái ngược với UEFI, kexec, v.v.).

.. note::

   Short intro for the impatient: Just use vga=ask for the first time,
   enter ``scan`` on the video mode prompt, pick the mode you want to use,
   remember its mode ID (the four-digit hexadecimal number) and then
   set the vga parameter to this number (converted to decimal first).

Chế độ video sẽ được sử dụng được chọn bởi tham số kernel có thể
được chỉ định trong kernel Makefile (dòng SVGA_MODE=...) hoặc bằng "vga=..."
tùy chọn của LILO (hoặc một số bộ tải khởi động khác mà bạn sử dụng) hoặc bằng tiện ích "xrandr"
(có trong các gói tiện ích Linux tiêu chuẩn). Bạn có thể sử dụng các giá trị sau
của tham số này::

NORMAL_VGA - Chế độ 80x25 tiêu chuẩn có sẵn trên tất cả các bộ điều hợp màn hình.

EXTENDED_VGA - Chế độ phông chữ 8 pixel tiêu chuẩn: 80x43 trên EGA, 80x50 trên VGA.

ASK_VGA - Hiển thị menu chế độ video khi khởi động (xem bên dưới).

0..35 - Số mục menu (khi bạn đã sử dụng menu để xem danh sách
      các chế độ có sẵn trên bộ điều hợp của bạn, bạn có thể chỉ định mục menu bạn muốn
      để sử dụng). 0..9 tương ứng với "0".."9", 10..35 đến "a"."z". Cảnh báo:
      danh sách chế độ được hiển thị có thể thay đổi khi phiên bản kernel thay đổi, vì
      các chế độ được liệt kê theo cách "được phát hiện lần đầu - hiển thị lần đầu". Đó là
      thay vào đó tốt hơn nên sử dụng số chế độ tuyệt đối.

0x.... - ID chế độ video thập lục phân (cũng được hiển thị trên menu, xem bên dưới
      để biết ý nghĩa chính xác của ID). Cảnh báo: LILO không hỗ trợ
      số thập lục phân - bạn phải chuyển đổi nó thành số thập phân theo cách thủ công.

Thực đơn
~~~~

Chế độ ASK_VGA khiến kernel cung cấp menu chế độ video khi
khởi động. Nó hiển thị "Nhấn <RETURN> để xem các chế độ video khả dụng, <SPACE>
để tiếp tục hoặc đợi 30 giây". Nếu bạn nhấn <RETURN>, bạn nhập
menu, nếu bạn nhấn <SPACE> hoặc đợi 30 giây, kernel sẽ khởi động trong
chế độ 80x25 tiêu chuẩn.

Thực đơn trông giống như::

Bộ điều hợp video: <tên của bộ điều hợp video được phát hiện>
	Chế độ: COLSxROWS:
	0 0F00 80x25
	1 0F01 80x50
	2 0F02 80x43
	3 0F03 80x26
	....
Nhập số chế độ hoặc ZZ0000ZZ: <flashing-cursor-here>

<name-of- detect-video-adapter> cho biết Linux đã phát hiện ra bộ điều hợp video nào
-- đó là tên bộ chuyển đổi chung (MDA, CGA, HGC, EGA, VGA, VESA VGA [a VGA
với BIOS tương thích với VESA]) hoặc tên chipset (ví dụ: Trident). Phát hiện trực tiếp
của chipset bị tắt theo mặc định vì nó vốn không đáng tin cậy do
thiết kế PC hoàn toàn điên rồ.

"0 0F00 80x25" có nghĩa là mục menu đầu tiên (các mục menu được đánh số
từ "0" đến "9" và từ "a" đến "z") là chế độ 80x25 với ID=0x0f00 (xem phần
phần tiếp theo để biết mô tả về ID chế độ).

<flash-cursor-here> khuyến khích bạn nhập số mục hoặc ID chế độ
bạn muốn cài đặt và nhấn <RETURN>. Nếu máy tính phàn nàn điều gì đó về
"ID chế độ không xác định", nó đang cố nói với bạn rằng không thể đặt như vậy
một chế độ. Cũng có thể chỉ nhấn <RETURN> để thoát khỏi chế độ hiện tại.

Danh sách chế độ thường chứa một số chế độ cơ bản và một số chế độ VESA.  trong
trường hợp chipset của bạn đã được phát hiện, một số chế độ dành riêng cho chipset sẽ được hiển thị dưới dạng
à (một số trong số này có thể bị thiếu hoặc không sử dụng được trên máy của bạn vì lý do khác
BIOS thường được cung cấp cùng một thẻ và số chế độ hoàn toàn phụ thuộc vào
trên VGA BIOS).

Các chế độ hiển thị trên menu được sắp xếp một phần: Danh sách bắt đầu bằng
các chế độ tiêu chuẩn (80x25 và 80x50) theo sau là các chế độ "đặc biệt" (80x28 và
80x43), chế độ cục bộ (nếu tính năng chế độ cục bộ được bật), chế độ VESA và
cuối cùng là chế độ SVGA cho bộ điều hợp được phát hiện tự động.

Nếu bạn không hài lòng với danh sách chế độ được cung cấp (ví dụ: nếu bạn cho rằng thẻ của mình
có thể làm được nhiều hơn), bạn có thể nhập "quét" thay vì số mục/ID chế độ.  các
chương trình sẽ cố gắng hỏi BIOS về tất cả các số chế độ video có thể có và kiểm tra
điều gì sẽ xảy ra sau đó Màn hình có thể sẽ nhấp nháy dữ dội trong một thời gian và
những tiếng động lạ sẽ được nghe thấy từ bên trong màn hình, v.v., thực sự
tất cả các chế độ video nhất quán được BIOS hỗ trợ sẽ xuất hiện (cộng với một số chế độ có thể
ZZ0000ZZ). Nếu bạn sợ điều này có thể làm hỏng màn hình của bạn, đừng sử dụng
chức năng này.

Sau khi quét, thứ tự chế độ hơi khác một chút: SVGA được tự động phát hiện
các chế độ hoàn toàn không được liệt kê và các chế độ được ZZ0000ZZ tiết lộ được hiển thị trước đó
tất cả các chế độ VESA.

ID chế độ
~~~~~~~~

Do sự phức tạp của tất cả nội dung video nên ID chế độ video
được sử dụng ở đây cũng hơi phức tạp. ID chế độ video thường là số 16 bit
được biểu thị bằng ký hiệu thập lục phân (bắt đầu bằng "0x"). Bạn có thể đặt chế độ
bằng cách nhập trực tiếp chế độ của nó nếu bạn biết nó ngay cả khi nó không được hiển thị trên menu.

Số ID có thể được chia thành các vùng đó::

0x0000 đến 0x00ff - tham chiếu mục menu. 0x0000 là mục đầu tiên. không sử dụng
	bên ngoài menu vì điều này có thể thay đổi từ lần khởi động này sang lần khởi động khác (đặc biệt nếu bạn
	đã sử dụng tính năng ZZ0000ZZ).

0x0100 đến 0x017f - chế độ BIOS tiêu chuẩn. ID là số chế độ video BIOS
	(như được trình bày cho INT 10, chức năng 00) tăng thêm 0x0100.

0x0200 đến 0x08ff - Chế độ VESA BIOS. ID là ID chế độ VESA tăng thêm
	0x0100. Tất cả các chế độ VESA phải được tự động phát hiện và hiển thị trên menu.

0x0900 đến 0x09ff - Chế độ đặc biệt của Video7. Đặt bằng cách gọi INT 0x10, AX=0x6f05.
	(Thường là 940=80x43, 941=132x25, 942=132x44, 943=80x60, 944=100x60,
	945=132x28 cho Video7 BIOS tiêu chuẩn)

0x0f00 đến 0x0fff - các chế độ đặc biệt (chúng được đặt bằng nhiều thủ thuật khác nhau -- thường là
	bằng cách sửa đổi một trong các chế độ tiêu chuẩn). Hiện có sẵn:
	0x0f00 tiêu chuẩn 80x25, không đặt lại chế độ nếu đã đặt (=FFFF)
	Tiêu chuẩn 0x0f01 với phông chữ 8 điểm: 80x43 trên EGA, 80x50 trên VGA
	0x0f02 VGA 80x43 (VGA chuyển sang 350 dòng quét với phông chữ 8 điểm)
	0x0f03 VGA 80x28 (quét VGA tiêu chuẩn, nhưng phông chữ 14 điểm)
	0x0f04 rời khỏi chế độ video hiện tại
	0x0f05 VGA 80x30 (480 lần quét, phông chữ 16 điểm)
	0x0f06 VGA 80x34 (480 lần quét, phông chữ 14 điểm)
	0x0f07 VGA 80x60 (480 lần quét, phông chữ 8 điểm)
	0x0f08 Hack đồ họa (xem đoạn VIDEO_GFX_HACK bên dưới)

0x1000 đến 0x7fff - các chế độ được chỉ định bởi độ phân giải. Mã có "0xRRCC"
	dạng trong đó RR là một số hàng và CC là một số cột.
	Ví dụ: 0x1950 tương ứng với chế độ 80x25, 0x2b84 đến 132x43, v.v.
	Đây là cách hoàn toàn di động duy nhất để đề cập đến chế độ không chuẩn,
	nhưng nó phụ thuộc vào chế độ được tìm thấy và hiển thị trên menu
	(hãy nhớ rằng chế độ quét không được thực hiện tự động).

0xff00 đến 0xffff - bí danh cho khả năng tương thích ngược:
	0xffff tương đương với 0x0f00 (tiêu chuẩn 80x25)
	0xfffe tương đương với 0x0f01 (EGA 80x43 hoặc VGA 80x50)

Nếu bạn thêm 0x8000 vào ID chế độ, chương trình sẽ cố gắng tính toán lại
thời gian hiển thị dọc theo các thông số chế độ, có thể được sử dụng để
loại bỏ một số lỗi khó chịu của một số BIOS VGA nhất định (thường là những lỗi được sử dụng cho
thẻ có chipset S3 và BIOS Cirrus Logic cũ) -- chủ yếu là các dòng bổ sung ở
cuối màn hình.

Tùy chọn
~~~~~~~

Các tùy chọn xây dựng cho Arch/x86/boot/* được chọn bởi kernel kconfig
tiện ích và tệp .config kernel.

VIDEO_GFX_HACK - bao gồm hack đặc biệt để cài đặt chế độ đồ họa
để sau này được sử dụng bởi những người lái xe đặc biệt.
Cho phép đặt chế độ _any_ BIOS bao gồm cả chế độ đồ họa và buộc cụ thể
độ phân giải màn hình văn bản thay vì xem qua các biến BIOS. không sử dụng
trừ khi bạn nghĩ bạn biết mình đang làm gì. Để kích hoạt thiết lập này, hãy sử dụng
số chế độ 0x0f08 (xem phần ID chế độ ở trên).

Vẫn không hoạt động?
~~~~~~~~~~~~~~~~~~~

Khi tính năng phát hiện chế độ không hoạt động (ví dụ: danh sách chế độ không chính xác hoặc
máy bị treo thay vì hiển thị menu), hãy thử tắt một số
các tùy chọn cấu hình được liệt kê trong "Tùy chọn". Nếu thất bại, bạn vẫn có thể sử dụng
kernel của bạn với chế độ video được đặt trực tiếp thông qua tham số kernel.

Trong cả hai trường hợp, vui lòng gửi cho tôi báo cáo lỗi có nội dung _chính xác_
xảy ra và việc chuyển đổi cấu hình ảnh hưởng như thế nào đến hoạt động của lỗi.

Nếu bạn khởi động Linux từ M$-DOS, bạn cũng có thể sử dụng một số công cụ DOS để
cài đặt chế độ video. Trong trường hợp này, bạn phải chỉ định chế độ 0x0f04 ("để
cài đặt hiện tại") sang Linux, vì nếu bạn không làm như vậy và bạn sử dụng bất kỳ thông tin không chuẩn nào
chế độ này, Linux sẽ tự động chuyển sang 80x25.

Nếu bạn đặt một số chế độ mở rộng và có một hoặc nhiều dòng bổ sung trên
phía dưới màn hình chứa văn bản đã được cuộn ra, VGA BIOS của bạn
chứa lỗi BIOS video phổ biến nhất được gọi là "hiển thị dọc không chính xác
kết thúc cài đặt". Việc thêm 0x8000 vào ID chế độ có thể khắc phục được sự cố. Thật không may,
việc này phải được thực hiện thủ công -- không có cơ chế tự động phát hiện nào.

Lịch sử
~~~~~~~

======================================================================================
1.0 (??-Nov-95) Phiên bản đầu tiên hỗ trợ tất cả các bộ điều hợp được hỗ trợ bởi phiên bản cũ
		thiết lập.S + Cirrus Logic 54XX. Có mặt trong một số phiên bản 1.3.4? hạt nhân
		và sau đó bị loại bỏ do mất ổn định trên một số máy.
2.0 (28-01-96) Viết lại từ đầu. Gần như đã thêm hỗ trợ Cirrus Logic 64XX
		mọi thứ đều có thể cấu hình được, sự hỗ trợ của VESA sẽ còn nhiều hơn thế
		ổn định, cho phép đánh số chế độ rõ ràng, thực hiện "quét", v.v.
2.1 (30 tháng 1 năm 96) Chế độ VESA được chuyển sang 0x200-0x3ff. Lựa chọn chế độ theo độ phân giải
		được hỗ trợ. Đã sửa một số lỗi. Các chế độ VESA được liệt kê trước
		các chế độ được cung cấp bởi tính năng tự động phát hiện SVGA vì chúng đáng tin cậy hơn.
		CLGD tự động phát hiện hoạt động tốt hơn. Không phụ thuộc vào 80x25
		hoạt động khi bắt đầu. Đã sửa lỗi quét. Đã thêm 80x43 (bất kỳ VGA nào).
		Mã đã được dọn sạch.
2.2 (01-02-96) Đã sửa lỗi EGA 80x43. VESA được mở rộng thành 0x200-0x4ff (không chuẩn 02XX
		Chế độ VESA hiện hoạt động). Hiển thị cách giải quyết lỗi cuối được hỗ trợ.
		Các chế độ đặc biệt được đánh số lại để cho phép thêm tính năng "tính toán lại"
		cờ, 0xffff và 0xfffe trở thành bí danh thay vì ID thực.
		Nội dung màn hình được giữ lại trong quá trình thay đổi chế độ.
2.3 (15-03-96) Đã thay đổi để hoạt động với kernel 1.3.74.
2.4 (18-03-96) Đã thêm các bản vá của Hans Lermen khắc phục sự cố ghi đè bộ nhớ
		với một số bộ tải khởi động. Quản lý bộ nhớ được viết lại để phản ánh
		những thay đổi này. Thật không may, nội dung màn hình giữ lại hoạt động
		bây giờ chỉ với một số bộ tải.
		Đã thêm chế độ Tseng 132x60.
2.5 (19-03-96) Đã sửa lỗi quét chế độ VESA được giới thiệu trong 2.4.
2.6 (25-03-96) Một số lỗi VESA BIOS không được báo cáo -- nó sửa các báo cáo lỗi trên
		một số thẻ có mã VESA bị hỏng (ví dụ: ATI VGA).
2.7 (09-04-96) - Chấp nhận tất cả các chế độ VESA trong phạm vi 0x100 đến 0x7ff, vì một số
		  thẻ sử dụng số chế độ rất lạ.
		- Đã thêm chế độ Realtek VGA (nhờ Gonzalo Tornaria).
		- Thứ tự kiểm tra phần cứng có thay đổi một chút, kiểm tra dựa trên ROM
		  nội dung thực hiện như lần đầu.
		- Đã thêm hỗ trợ cho các chức năng chuyển đổi chế độ Video7 đặc biệt
		  (cảm ơn Tom Vander Aa).
		- Đã thêm chế độ quét 480 (đặc biệt hữu ích cho máy tính xách tay,
		  phiên bản gốc được viết bởi hhanemaa@cs.ruu.nl, được vá bởi
		  Jeff Chua, do tôi viết lại).
		- Đã sửa lỗi lưu trữ/khôi phục màn hình.
2.8 (14-04-96) - Bản phát hành trước không thể biên dịch được nếu không có CONFIG_VIDEO_SVGA.
		- Nhận dạng tốt hơn các chế độ văn bản trong quá trình quét chế độ.
2.9 (12-05-96) - Bỏ qua các chế độ VESA 0x80 - 0xff (thêm lỗi VESA BIOS!)
2.10(11-Nov-96) - Toàn bộ điều này được thực hiện tùy chọn.
		- Đã thêm công tắc CONFIG_VIDEO_400_HACK.
		- Đã thêm công tắc CONFIG_VIDEO_GFX_HACK.
		- Dọn dẹp mã.
2.11(03-May-97) - Một lần dọn dẹp khác, hiện bao gồm cả tài liệu.
		- Kiểm tra trực tiếp các bộ điều hợp SVGA bị tắt theo mặc định, ZZ0000ZZ
		  được cung cấp rõ ràng trên dòng nhắc.
		- Đã xóa phần tài liệu mô tả việc thêm thăm dò mới
		  hoạt động khi tôi cố gắng loại bỏ việc thăm dò phần cứng _all_ ở đây.
2.12(25-05-98) Đã thêm hỗ trợ cho đồ họa đệm khung VESA.
2.13(14-May-99) Sửa lỗi tài liệu nhỏ.
======================================================================================
