.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/fb/uvesafb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================================
uvesafb - Trình điều khiển chung cho card màn hình tương thích VBE2+
==========================================================

1. Yêu cầu
---------------

uvesafb sẽ hoạt động với bất kỳ card màn hình nào tương thích Video BIOS
với tiêu chuẩn VBE 2.0.

Không giống như các trình điều khiển khác, uvesafb sử dụng một trình trợ giúp không gian người dùng được gọi là
v86d.  v86d được sử dụng để chạy mã x86 Video BIOS ở dạng mô phỏng và
môi trường được kiểm soát.  Điều này cho phép uvesafb hoạt động trên các vòm khác
hơn x86.  Kiểm tra tài liệu v86d để biết danh sách hiện được hỗ trợ
vòm.

Mã nguồn v86d có thể được tải xuống từ trang web sau:

ZZ0000ZZ

Vui lòng tham khảo tài liệu v86d để biết cấu hình chi tiết và
hướng dẫn cài đặt.

Lưu ý rằng trình trợ giúp không gian người dùng v86d phải luôn sẵn sàng trong
để uvesafb hoạt động bình thường.  Nếu bạn muốn sử dụng uvesafb trong thời gian
khởi động sớm, bạn sẽ phải đưa v86d vào hình ảnh initramfs và
hoặc biên dịch nó vào kernel hoặc sử dụng nó làm initrd.

2. Những lưu ý và hạn chế
--------------------------

uvesafb là trình điều khiển _generic_ hỗ trợ nhiều loại video
nhưng cuối cùng bị hạn chế bởi giao diện Video BIOS.
Những hạn chế quan trọng nhất là:

- Thiếu bất kỳ loại tăng tốc nào.
- Một tập hợp các chế độ video được hỗ trợ nghiêm ngặt và hạn chế.  Thường người bản xứ
  hoặc độ phân giải/tốc độ làm mới tối ưu nhất cho thiết lập của bạn sẽ không hoạt động
  với uvesafb, đơn giản vì Video BIOS không hỗ trợ
  chế độ video bạn muốn sử dụng.  Điều này có thể đặc biệt đau đớn với
  bảng màn hình rộng, trong đó chế độ video gốc không có tỷ lệ khung hình 4:3
  tỷ lệ, đây là tỷ lệ mà hầu hết BIOS-es bị giới hạn.
- Chỉ có thể điều chỉnh tốc độ làm mới với VBE 3.0 tương thích
  Video BIOS.  Lưu ý rằng nhiều nVidia Video BIOS-es tự nhận là VBE 3.0
  tuân thủ, trong khi họ chỉ đơn giản bỏ qua mọi cài đặt tốc độ làm mới.

3. Cấu hình
----------------

uvesafb có thể được biên dịch dưới dạng mô-đun hoặc trực tiếp vào kernel.
Trong cả hai trường hợp, nó đều hỗ trợ cùng một bộ tùy chọn cấu hình,
được đưa ra trên dòng lệnh kernel hoặc dưới dạng tham số mô-đun, ví dụ::

video=uvesafb:1024x768-32,mtrr:3,ywrap (được biên dịch vào kernel)

# modprobe uvesafb mode_option=1024x768-32 mtrr=3 cuộn=ywrap (mô-đun)

Tùy chọn được chấp nhận:

======= ===============================================================
ypan Kích hoạt tính năng xoay màn hình bằng chế độ được bảo vệ VESA
	giao diện.  Màn hình hiển thị chỉ là một cửa sổ của
	bộ nhớ video, việc cuộn bảng điều khiển được thực hiện bằng cách thay đổi
	bắt đầu của cửa sổ.  Tùy chọn này có sẵn trên x86
	duy nhất và là tùy chọn mặc định trên kiến trúc đó.

ywrap Tương tự như ypan, nhưng giả sử bảng gfx của bạn có thể bao bọc xung quanh
	bộ nhớ video (tức là bắt đầu đọc từ trên xuống nếu nó
	đạt đến cuối bộ nhớ video).  Nhanh hơn ypan.
	Chỉ có trên x86.

vẽ lại Cuộn bằng cách vẽ lại phần bị ảnh hưởng của màn hình, điều này
	là mặc định trên không phải x86.
======= ===============================================================

(Nếu bạn đang sử dụng uvesafb làm mô-đun, ba tùy chọn trên là
đã sử dụng một tham số của tùy chọn cuộn, ví dụ: cuộn=ypan.)

============ ==========================================================================
vgapal Sử dụng thanh ghi VGA tiêu chuẩn để thay đổi bảng màu.

pmipal Sử dụng giao diện chế độ được bảo vệ để thay đổi bảng màu.
            Đây là mặc định nếu giao diện chế độ được bảo vệ
            có sẵn.  Chỉ có trên x86.

mtrr:n Thiết lập các thanh ghi phạm vi loại bộ nhớ cho bộ đệm khung
            ở đâu n:

- 0 - bị vô hiệu hóa (tương đương với nomtrr)
                - 3 - kết hợp ghi (mặc định)

Các giá trị khác 0 và 3 sẽ dẫn đến cảnh báo và sẽ bị
            xử lý như 3.

nomtrr Không sử dụng các thanh ghi phạm vi loại bộ nhớ.

vremap:n
            Ánh xạ lại 'n' MiB của video RAM.  Nếu 0 hoặc không được chỉ định, hãy ánh xạ lại bộ nhớ
            theo chế độ video.

vtotal:n Nếu video BIOS của thẻ xác định sai tổng
            lượng video RAM, hãy sử dụng tùy chọn này để ghi đè BIOS (trong MiB).

<mode> Chế độ bạn muốn đặt, ở định dạng moddb tiêu chuẩn.  tham khảo
            moddb.txt để biết mô tả chi tiết.  Khi uvesafb được biên dịch thành
            một mô-đun, chuỗi chế độ phải được cung cấp dưới dạng giá trị của
            Tùy chọn 'mode_option'.

vbemode:x Buộc sử dụng chế độ VBE x.  Chế độ này sẽ chỉ được thiết lập nếu
            được tìm thấy trong danh sách các chế độ được hỗ trợ do VBE cung cấp.
            NOTE: Số chế độ 'x' phải được chỉ định trong số chế độ VESA
            ký hiệu, không phải nhân Linux (ví dụ: 257 thay vì 769).
            HINT: Nếu bạn sử dụng tùy chọn này vì thông số <mode> bình thường không
            không phù hợp với bạn và bạn sử dụng máy chủ X, có thể bạn sẽ muốn
            đặt tùy chọn 'nocrtc' để đảm bảo chế độ video phù hợp
            được khôi phục sau khi chuyển đổi bảng điều khiển <-> X.

nocrtc Không sử dụng bộ định giờ CRTC trong khi cài đặt chế độ video.  Tùy chọn này
            chỉ có hiệu lực nếu Video BIOS tương thích với VBE 3.0.  Sử dụng nó
            nếu bạn gặp vấn đề với các chế độ, hãy đặt theo cách tiêu chuẩn.  Lưu ý rằng
            sử dụng tùy chọn này ngụ ý rằng mọi điều chỉnh tốc độ làm mới sẽ
            bị bỏ qua và tốc độ làm mới sẽ ở mức mặc định BIOS của bạn
            (60Hz).

noedid Đừng cố tìm nạp và sử dụng các chế độ do EDID cung cấp.

noblank Tắt tính năng xóa phần cứng.

v86d:path Đặt đường dẫn tới tệp thực thi v86d. Tùy chọn này chỉ có sẵn dưới dạng
            một tham số mô-đun chứ không phải là một phần của chuỗi video=.  Nếu bạn
            cần sử dụng nó và có uvesafb được tích hợp trong kernel, hãy sử dụng
            uvesafb.v86d="đường dẫn".
============ ==========================================================================

Ngoài ra, các tham số sau có thể được cung cấp.  Tất cả đều ghi đè lên
Các giá trị do EDID cung cấp và các giá trị mặc định của BIOS.  Hãy tham khảo thông số kỹ thuật của màn hình để biết
các giá trị chính xác cho maxhf, maxvf và maxclk cho phần cứng của bạn.

=====================================================
maxhf:n Tần số ngang tối đa (tính bằng kHz).
maxvf:n Tần số dọc tối đa (tính bằng Hz).
maxclk:n Đồng hồ pixel tối đa (tính bằng MHz).
=====================================================

4. Giao diện sysfs
----------------------

uvesafb cung cấp một số nút sysfs cho các tham số có thể định cấu hình và
thông tin bổ sung.

Thuộc tính trình điều khiển:

/sys/bus/nền tảng/trình điều khiển/uvesafb
  v86d
    (mặc định: /sbin/v86d)

Đường dẫn đến tệp thực thi v86d. v86d được bắt đầu bởi uvesafb
    nếu một phiên bản của daemon chưa chạy.

Thuộc tính thiết bị:

/sys/bus/platform/drivers/uvesafb/uvesafb.0
  ban đêm
    Sử dụng tốc độ làm mới mặc định (60 Hz) nếu được đặt thành 1.

oem_product_name, oem_product_rev, oem_string, oem_vendor
    Thông tin về thẻ và nhà sản xuất thẻ.

vbe_modes
    Danh sách các chế độ video được Video BIOS hỗ trợ cùng với các chế độ đó
    Số chế độ VBE ở dạng hex.

vbe_version
    Giá trị BCD biểu thị tiêu chuẩn VBE đã triển khai.

5. Linh tinh
----------------

Uvesafb sẽ đặt chế độ video với tốc độ làm mới và thời gian làm mới mặc định
từ Video BIOS nếu bạn đặt pixclock thành 0 trong fb_var_screeninfo.



Michal Januszewski <spock@gentoo.org>

Cập nhật lần cuối: 2017-10-10

Tài liệu về các tùy chọn uvesafb dựa trên vesafb.txt một cách lỏng lẻo.
