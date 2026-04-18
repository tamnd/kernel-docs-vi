.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/vesafb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================
vesafb - Trình điều khiển bộ đệm khung đồ họa chung
===================================================

Đây là trình điều khiển chung cho bộ đệm khung đồ họa trên hộp intel.

Ý tưởng rất đơn giản: Bật chế độ đồ họa khi khởi động với sự trợ giúp
của BIOS và sử dụng thiết bị này làm thiết bị bộ đệm khung/dev/fb0, như m68k
(và các cổng khác) làm được.

Điều này có nghĩa là chúng tôi quyết định vào lúc khởi động bất cứ khi nào chúng tôi muốn chạy trong văn bản hoặc
chế độ đồ họa.  Việc chuyển đổi chế độ sau này (ở chế độ được bảo vệ) là
không thể được; Cuộc gọi BIOS chỉ hoạt động ở chế độ thực.  Phần mở rộng VESA BIOS
Cần có phiên bản 2.0 vì chúng tôi cần bộ đệm khung tuyến tính.

Thuận lợi:

* Nó cung cấp một bảng điều khiển lớn đẹp mắt (128 cols + 48 dòng với 1024x768)
   không sử dụng các phông chữ nhỏ, không thể đọc được.
 * Bạn có thể chạy XF68_FBDev trên /dev/fb0 (=> X11 không tăng tốc
   hỗ trợ cho mọi bo mạch đồ họa tương thích VBE 2.0).
 * Quan trọng nhất: logo khởi động :-)

Nhược điểm:

* chế độ đồ họa chậm hơn chế độ văn bản...


Làm thế nào để sử dụng nó?
==============

Việc chuyển đổi chế độ được thực hiện bằng tham số khởi động vga=....  Đọc
Tài liệu/admin-guide/svga.rst để biết chi tiết.

Bạn nên biên dịch ở cả vgacon (cho chế độ văn bản) và vesafb (cho
chế độ đồ họa). Ai trong số họ tiếp quản bảng điều khiển phụ thuộc vào
bất cứ khi nào chế độ được chỉ định là văn bản hoặc đồ họa.

Các chế độ đồ họa là NOT trong danh sách bạn nhận được nếu khởi động bằng
vga=ask và nhấn return. Chế độ bạn muốn sử dụng có nguồn gốc từ
Số chế độ VESA. Dưới đây là các số chế độ VESA:

==================== ======== ==========
màu sắc 640x480 800x600 1024x768 1280x1024
==================== ======== ==========
256 0x101 0x103 0x105 0x107
32k 0x110 0x113 0x116 0x119
64k 0x111 0x114 0x117 0x11A
16M 0x112 0x115 0x118 0x11B
==================== ======== ==========


Số chế độ video của nhân Linux là số chế độ VESA cộng thêm
0x200:

Linux_kernel_mode_number = VESA_mode_number + 0x200

Vì vậy, bảng cho các số chế độ hạt nhân là:

==================== ======== ==========
màu sắc 640x480 800x600 1024x768 1280x1024
==================== ======== ==========
256 0x301 0x303 0x305 0x307
32k 0x310 0x313 0x316 0x319
64k 0x311 0x314 0x317 0x31A
16M 0x312 0x315 0x318 0x31B
==================== ======== ==========

Để bật một trong những chế độ đó, bạn phải chỉ định "vga=ask" trong
lilo.conf và chạy lại LILO. Sau đó, bạn có thể gõ vào mong muốn
chế độ tại dấu nhắc "vga=ask". Ví dụ nếu bạn thích sử dụng
Màu 1024x768x256 bạn phải nói "305" tại dấu nhắc này.

Nếu cách này không hiệu quả, điều này có thể là do BIOS của bạn không hỗ trợ
bộ đệm khung tuyến tính hoặc vì nó hoàn toàn không hỗ trợ chế độ này.
Ngay cả khi bo mạch của bạn có, nó có thể là BIOS không có.  VESA BIOS
Cần có phần mở rộng v2.0, 1.2 là NOT là đủ.  Bạn sẽ nhận được một
thông báo "số chế độ xấu" nếu có sự cố.

1. Lưu ý: LILO không thể xử lý hex, để khởi động trực tiếp bằng
   "vga=mode-number" bạn phải chuyển đổi số thành số thập phân.
2. Lưu ý: Một số phiên bản mới hơn của LILO dường như hoạt động với các giá trị hex đó,
   nếu bạn đặt 0x ở phía trước các con số.

X11
===

XF68_FBDev sẽ hoạt động tốt nhưng không được tăng tốc.  Đang chạy
một X-Server khác (được tăng tốc) như XF86_SVGA có thể hoạt động hoặc không.
Nó phụ thuộc vào X-Server và bo mạch đồ họa.

Máy chủ X phải khôi phục chế độ video một cách chính xác, nếu không bạn sẽ kết thúc
với bảng điều khiển bị hỏng (và vesafb không thể làm gì về việc này).


Tốc độ làm mới
=============

Không có cách nào để thay đổi chế độ video vesafb và/hoặc thời gian sau
khởi động linux.  Nếu bạn không hài lòng với tốc độ làm mới 60 Hz, bạn
có các tùy chọn sau:

* cấu hình và tải DOS-Tools cho bo mạch đồ họa (nếu
   có sẵn) và khởi động Linux bằng Loadlin.
 * thay vào đó hãy sử dụng trình điều khiển gốc (matroxfb/atyfb) nếu vesafb.  Nếu không có
   có sẵn, viết một cái mới!
 * VBE 3.0 cũng có thể hoạt động.  Tôi không có bảng gfx với VBE 3.0
   hỗ trợ cũng như thông số kỹ thuật, vì vậy tôi chưa kiểm tra điều này.


Cấu hình
=============

VESA BIOS cung cấp giao diện chế độ được bảo vệ để thay đổi
một số thông số.  vesafb có thể sử dụng nó để thay đổi bảng màu và
để xoay màn hình.  Nó bị tắt theo mặc định vì nó
dường như không hoạt động với một số phiên bản BIOS, nhưng có các tùy chọn
để bật nó lên.

Bạn có thể chuyển tùy chọn tới vesafb bằng cách sử dụng "video=vesafb:option" trên
dòng lệnh hạt nhân.  Nhiều lựa chọn nên được tách ra
bằng dấu phẩy, như thế này: "video=vesafb:ypan,inverse"

Tùy chọn được chấp nhận:

sử dụng nghịch đảo bản đồ màu nghịch đảo

=====================================================================================
ypan cho phép xoay màn hình bằng chế độ được bảo vệ VESA
          giao diện.  Màn hình hiển thị chỉ là một cửa sổ của
          bộ nhớ video, việc cuộn bảng điều khiển được thực hiện bằng cách thay đổi
          bắt đầu của cửa sổ.

chuyên nghiệp:

* cuộn (toàn màn hình) rất nhanh, vì có
		  không cần phải sao chép xung quanh dữ liệu.

hỏi:

* chỉ cuộn các phần của màn hình gây ra một số
		  hiệu ứng nhấp nháy xấu xí (logo khởi động nhấp nháy cho
		  ví dụ).

ywrap Tương tự như ypan, nhưng giả sử bảng gfx của bạn có thể bao bọc xung quanh
          bộ nhớ video (tức là bắt đầu đọc từ trên xuống nếu nó
          đạt đến cuối bộ nhớ video).  Nhanh hơn ypan.

vẽ lại Cuộn bằng cách vẽ lại phần bị ảnh hưởng của màn hình, điều này
          là mặc định an toàn (và chậm).


vgapal Sử dụng thanh ghi vga tiêu chuẩn để thay đổi bảng màu.
          Đây là mặc định.
pmipal Sử dụng giao diện chế độ được bảo vệ để thay đổi bảng màu.

mtrr:n Thiết lập các thanh ghi phạm vi loại bộ nhớ cho bộ đệm khung vesafb
          ở đâu n:

- 0 - bị vô hiệu hóa (tương đương với nomtrr) (mặc định)
              - 1 - không thể lưu được
              - 2 - viết lại
              - 3 - viết-kết hợp
              - 4 - viết qua

Nếu bạn thấy thông tin sau trong dmesg, hãy chọn loại phù hợp với
          cái cũ. Trong ví dụ này, hãy sử dụng "mtrr:2".
...
mtrr: gõ không khớp cho e0000000,8000000 cũ: viết lại mới:
	  kết hợp viết
...

nomtrr vô hiệu hóa mtrr

vremap:n
          Ánh xạ lại 'n' MiB của video RAM. Nếu 0 hoặc không được chỉ định, hãy ánh xạ lại bộ nhớ
          theo chế độ video. (Bản vá/ý tưởng 2.5.66 của Antonino Daplas
          đảo ngược để cung cấp khả năng ghi đè (cấp phát thêm bộ nhớ fb
          hơn kernel) lên 2,4 bởi tmb@iki.fi)

vtotal:n Nếu video BIOS của thẻ xác định sai tổng
          lượng video RAM, hãy sử dụng tùy chọn này để ghi đè BIOS (trong MiB).
=====================================================================================

Chúc vui vẻ!

Gerd Knorr <kraxel@goldbach.in-berlin.de>

Những thay đổi nhỏ (chủ yếu là lỗi đánh máy)
bởi Nico Schmoigl <schmoigl@rumms.uni-mannheim.de>
