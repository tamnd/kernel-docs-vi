.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/video.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Sự cố video với sơ yếu lý lịch S3
=================================

2003-2006, Pavel Machek

Trong quá trình tiếp tục S3, phần cứng cần được khởi tạo lại. Đối với hầu hết
thiết bị, việc này thật dễ dàng và trình điều khiển hạt nhân biết cách thực hiện
nó. Thật không may có một ngoại lệ: card màn hình. Đó thường là những
được khởi tạo bởi BIOS và kernel không có đủ thông tin để
khởi động card màn hình. (Kernel thường thậm chí không chứa card màn hình
driver -- vesafb và vgacon được sử dụng rộng rãi).

Đây không phải là vấn đề đối với swsusp, vì trong quá trình tiếp tục swsusp, BIOS là
chạy bình thường nên card màn hình được khởi tạo bình thường. Nó không nên như vậy
vấn đề đối với chế độ chờ S1, vì phần cứng sẽ giữ nguyên trạng thái của nó trong
đó.

Chúng tôi phải chạy video BIOS trong thời gian tiếp tục sớm hoặc giải thích nó
sử dụng vbetool sau hoặc có thể không cần thiết gì đặc biệt
hệ thống vì trạng thái video được giữ nguyên. Thật không may là khác nhau
các phương pháp hoạt động trên các hệ thống khác nhau và không có phương pháp nào phù hợp với tất cả
họ.

Ứng dụng Userland có tên s2ram đã được phát triển; nó chứa dài
danh sách trắng của hệ thống và tự động chọn phương pháp làm việc cho
hệ thống đã cho. Nó có thể được tải xuống từ CVS tại
www.sf.net/projects/suspend. Nếu bạn nhận được một hệ thống không có trong
danh sách trắng, vui lòng thử tìm giải pháp hiệu quả và gửi danh sách trắng
nhập để công việc không cần phải lặp lại.

Hiện tại, phương pháp VBE_SAVE (6 bên dưới) hoạt động trên hầu hết
hệ thống. Thật không may, vbetool chỉ chạy sau khi vùng người dùng được nối lại,
vì vậy nó giúp khắc phục các vấn đề về sơ yếu lý lịch sớm
khó/không thể. Ưu tiên sử dụng các phương pháp không phụ thuộc vào vùng người dùng.

Chi tiết
~~~~~~~~

Có một số loại hệ thống nơi video hoạt động sau khi S3 tiếp tục:

(1) các hệ thống trong đó trạng thái video được bảo toàn trên S3.

(2) các hệ thống có thể gọi video BIOS trong S3
    tiếp tục. Rất tiếc là gọi video BIOS tại
    điểm đó, nhưng nó lại hoạt động trên một số máy. sử dụng
    acpi_sleep=s3_bios.

(3) hệ thống khởi tạo card màn hình sang chế độ văn bản vga và ở đâu
    BIOS hoạt động đủ tốt để có thể đặt chế độ video. sử dụng
    acpi_sleep=s3_mode trên những thứ này.

(4) trên một số hệ thống, s3_bios chuyển video sang chế độ văn bản và
    cần có acpi_sleep=s3_bios,s3_mode.

(5) hệ thống radeon, trong đó X có thể khởi động mềm card màn hình của bạn. Bạn sẽ cần
    một chữ X đủ mới và một bảng điều khiển văn bản thuần túy (không có vesafb hoặc radeonfb). Xem
    ZZ0000ZZ để biết thêm thông tin.
    Ngoài ra, bạn nên sử dụng vbetool (6) thay thế.

(6) các hệ thống radeon khác, trong đó vbetool đủ để đưa hệ thống trở lại
    đến cuộc sống. Nó cần bảng điều khiển văn bản để hoạt động. Làm vbetool vbestate
    lưu > /tmp/delme; echo 3 > /proc/acpi/sleep; bài vbetool; vbetool
    khôi phục vbestate </tmp/delme; setfont <bất cứ điều gì> và video của bạn
    nên làm việc.

(7) trên một số hệ thống, có thể khởi động hầu hết kernel và sau đó
    Đăng bios hoạt động. Ole Rohne có bản vá để làm việc đó tại
    ZZ0000ZZ

(8) trên một số hệ thống, bạn có thể sử dụng tiện ích video_post và hoặc
    làm echo 3 > /sys/power/state && /usr/sbin/video_post - điều này sẽ
    khởi tạo màn hình ở chế độ bảng điều khiển. Nếu bạn ở X, bạn có thể chuyển đổi
    đến một thiết bị đầu cuối ảo và quay lại X bằng cách sử dụng CTRL+ALT+F1 - CTRL+ALT+F7 để nhận
    màn hình lại hoạt động ở chế độ đồ họa.

Bây giờ, nếu bạn chuyển acpi_sleep=something và nó không hoạt động với
bios, bạn sẽ gặp sự cố nghiêm trọng trong quá trình tiếp tục. Hãy cẩn thận. Ngoài ra nó là
an toàn nhất để thực hiện các thử nghiệm của bạn với bảng điều khiển VGA cũ. vesafb
và trình điều khiển radeonfb (vv) có xu hướng làm hỏng máy trong quá trình
tiếp tục.

Bạn có thể có một hệ thống mà không có hệ thống nào ở trên hoạt động được. Vào thời điểm đó bạn
hoặc phát minh ra một cách hack xấu xí khác có thể hoạt động hoặc viết trình điều khiển thích hợp cho
card video của bạn (chúc may mắn nhận được tài liệu :-(). Có thể tạm dừng từ X
(đúng X, biết phần cứng của bạn, không phải XF68_FBcon) có thể tốt hơn
cơ hội làm việc.

Bảng sổ ghi chép làm việc đã biết:


====================================================================================
Hack mô hình (hoặc "cách thực hiện")
====================================================================================
Acer Aspire 1406LC ole init BIOS muộn (7), tắt DRI
Acer TM 230 s3_bios (2)
Acer TM 242FX vbetool (6)
Acer TM C110 video_post (8)
Acer TM C300 vga=bình thường (chỉ tạm dừng trên bảng điều khiển, không phải trong X),
				vbetool (6) hoặc video_post (8)
Acer TM 4052LCi s3_bios (2)
Acer TM 636Lci s3_bios,s3_mode (4)
Acer TM 650 (Radeon M7) vga=normal plus boot-radeon (5) nhận được văn bản
				giao diện điều khiển trở lại
Acer TM 660??? [#f1]_
Acer TM 800 vga=bình thường, bản vá X, xem trang web (5)
				hoặc vbetool (6)
Acer TM 803 vga=bình thường, bản vá X, xem trang web (5)
				hoặc vbetool (6)
Acer TM 803LCi vga=bình thường, vbetool (6)
Cần vbetool Arima W730a (6)
Asus L2400D s3_mode (3) [#f2]_ (S1 cũng hoạt động tốt)
Asus L3350M (SiS 740) (6)
Asus L3800C (Radeon M7) s3_bios (2) (S1 cũng hoạt động tốt)
Asus M6887Ne vga=bình thường, s3_bios (2), sử dụng driver radeon
				thay vì fglrx trong x.org
Nguyên mẫu máy tính để bàn Athlon64 s3_bios (2)
Compal CL-50 ??? [#f1]_
Compaq Armada E500 - P3-700 không có (1) (S1 cũng hoạt động tốt)
Compaq Evo N620c vga=bình thường, s3_bios (2)
Dell 600m, ATI R250 Lf không có (1), nhưng cần xorg-x11-6.8.1.902-1
Dell D600, ATI RV250 vga=bình thường và X, hoặc thử vbestate (6)
Dell D610 vga=normal và X (có thể cả vbestate (6),
				nhưng chưa được kiểm tra)
Dell Inspiron 4000??? [#f1]_
Dell Inspiron 500m ??? [#f1]_
Dell Inspiron 510m???
Cần vbetool Dell Inspiron 5150 (6)
Dell Inspiron 600m??? [#f1]_
Dell Inspiron 8200 ??? [#f1]_
Dell Inspiron 8500??? [#f1]_
Dell Inspiron 8600??? [#f1]_
Cần có máy eMachines athlon64 vbetool (6) (ai lấy giúp nhé
				tôi mẫu #s)
HP NC6000 s3_bios, không được sử dụng radeonfb (2);
				hoặc vbetool (6)
HP NX7000 ??? [#f1]_
Cần bài vbetool HP Pavilion ZD7000, cần nv mã nguồn mở
				tài xế cho X
HP Omnibook XE3 phiên bản athlon không có (1)
HP Omnibook XE3GC không có (1), video là S3 Savage/IX-MV
HP Omnibook XE3L-GF vbetool (6)
HP Omnibook 5150 không có (1), (S1 cũng hoạt động tốt)
IBM TP T20, model 2647-44G không có (1), video là S3 Inc. 86C270-294
				Savage/IX-MV, vesafb trở nên "thú vị"
				nhưng X hoạt động.
IBM TP A31 / Loại 2652-M5G s3_mode (3) [hoạt động ổn với
				BIOS 1.04 2002-08-23, nhưng hoàn toàn không có
				BIOS 1.11 2004-11-05 :-(]
IBM TP R32 / Loại 2658-MMG không có (1)
IBM TP R40 2722B3G ??? [#f1]_
IBM TP R50p / Loại 1832-22U s3_bios (2)
IBM TP R51 không có (1)
IBM TP T30 236681A ??? [#f1]_
IBM TP T40 / Loại 2373-MU4 không có (1)
IBM TP T40p không có (1)
IBM TP R40p s3_bios (2)
IBM TP T41p s3_bios (2), chuyển sang X sau khi tiếp tục
IBM TP T42 s3_bios (2)
IBM ThinkPad T42p (2373-GTG) s3_bios (2)
IBM TP X20 ??? [#f1]_
IBM TP X30 s3_bios, s3_mode (4)
IBM TP X31 / Loại 2672-XXH không có (1), sử dụng radeontool
				(ZZ0000ZZ đến
				tắt đèn nền.
IBM TP X32 không có (1), nhưng đèn nền bật và video đang bật
				bị vứt vào thùng rác sau một thời gian dài đình chỉ. s3_bios,
				s3_mode (4) cũng hoạt động. Có lẽ điều đó được
				kết quả tốt hơn?
IBM Thinkpad X40 Loại 2371-7JG s3_bios,s3_mode (4)
IBM TP 600e không có(1), nhưng chuyển sang bảng điều khiển và
				cần quay lại X
Medion MD4220 ??? [#f1]_
Cần vbetool Samsung P35 (6)
Sharp PC-AR10 (ATI cuồng nộ) không có (1), đèn nền không tắt
Sony Vaio PCG-C1VRX/K s3_bios (2)
Sony Vaio PCG-F403 ??? [#f1]_
Sony Vaio PCG-GRT995MP không có (1), hoạt động với trình điều khiển 'nv' X
Sony Vaio PCG-GR7/K không có (1), nhưng cần radeonfb, hãy sử dụng
				radeontool (ZZ0001ZZ
				để tắt đèn nền.
Sony Vaio PCG-N505SN ??? [#f1]_
Sony Vaio vgn-s260 X hoặc boot-radeon đều có thể khởi tạo được (5)
Sony Vaio vgn-S580BH vga=bình thường, nhưng tạm dừng từ X. Console sẽ
				để trống trừ khi bạn quay lại X.
Sony Vaio vgn-FS115B s3_bios (2),s3_mode (4)
Toshiba Libretto L5 không có (1)
Toshiba Libretto 100CT/110CT vbetool (6)
Toshiba Portege 3020CT s3_mode (3)
Toshiba Satellite 4030CDT s3_mode (3) (S1 cũng hoạt động tốt)
Toshiba Satellite 4080XCDT s3_mode (3) (S1 cũng hoạt động tốt)
Vệ tinh Toshiba 4090XCDT ??? [#f1]_
Toshiba Satellite P10-554 s3_bios,s3_mode (4) [#f3]_
Toshiba M30 (2) xor X với trình điều khiển nvidia sử dụng AGP bên trong
Uniwill 244IIO ??? [#f1]_
====================================================================================

Các hệ thống máy tính để bàn đang hoạt động đã biết
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

==============================================================================
Hack card đồ họa Mainboard (hoặc "cách thực hiện")
==============================================================================
Asus A7V8X nVidia RIVA TNT2 model 64 s3_bios,s3_mode (4)
==============================================================================


.. [#f1] from https://wiki.ubuntu.com/HoaryPMResults, not sure
         which options to use. If you know, please tell me.

.. [#f2] To be tested with a newer kernel.

.. [#f3] Not with SMP kernel, UP only.
