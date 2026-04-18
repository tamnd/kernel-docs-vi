.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/setup.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================================
Thông số khởi tạo kernel trên ARM Linux
=================================================

Tài liệu sau đây mô tả tham số khởi tạo kernel
cấu trúc, còn được gọi là 'struct param_struct' được sử dụng
cho hầu hết các kiến trúc ARM Linux.

Cấu trúc này được sử dụng để truyền các tham số khởi tạo từ
trình tải hạt nhân vào nhân Linux phù hợp và có thể tồn tại trong thời gian ngắn
thông qua quá trình khởi tạo kernel.  Theo nguyên tắc chung, nó
không nên được tham chiếu bên ngoài Arch/arm/kernel/setup.c:setup_arch().

Có rất nhiều tham số được liệt kê trong đó và chúng được mô tả
dưới đây:

kích thước trang
   Tham số này phải được đặt theo kích thước trang của máy và
   sẽ được kiểm tra bởi kernel.

nr_pages
   Đây là tổng số trang bộ nhớ trong hệ thống.  Nếu
   bộ nhớ được lưu trữ, thì cái này sẽ chứa tổng số
   của các trang trong hệ thống.

Nếu hệ thống chứa VRAM riêng biệt, giá trị này sẽ không
   bao gồm thông tin này.

kích thước đĩa ram
   Điều này bây giờ đã lỗi thời và không nên được sử dụng.

cờ
   Các cờ kernel khác nhau, bao gồm:

===== ==========================
    bit 0 1 = mount root chỉ đọc
    bit 1 chưa sử dụng
    bit 2 0 = tải ramdisk
    bit 3 0 = nhắc về đĩa RAM
    ===== ==========================

rootdev
   cặp số chính/phụ của thiết bị để gắn kết làm hệ thống tập tin gốc.

video_num_cols / video_num_rows
   Cả hai cùng mô tả kích thước ký tự của bảng điều khiển giả,
   hoặc kích thước ký tự bảng điều khiển VGA.  Chúng không nên được sử dụng cho bất kỳ mục đích nào khác
   mục đích.

Nói chung, nên đặt những thứ này thành VGA tiêu chuẩn hoặc
   kích thước ký tự tương đương của màn hình fbcon của bạn.  Điều này sau đó cho phép
   tất cả các thông báo khởi động sẽ được hiển thị chính xác.

video_x / video_y
   Điều này mô tả vị trí ký tự của con trỏ trên bảng điều khiển VGA và
   mặt khác không được sử dụng. (không nên được sử dụng cho các loại bảng điều khiển khác và
   không được sử dụng cho mục đích khác).

memc_control_reg
   Đăng ký điều khiển chip MEMC cho Acorn Archimedes và Acorn A5000
   máy dựa trên.  Có thể được sử dụng khác nhau bởi các kiến ​​trúc khác nhau.

âm thanh mặc định
   Cài đặt âm thanh mặc định trên máy Acorn.  Có thể được sử dụng khác nhau bởi
   kiến trúc khác nhau.

ổ đĩa adfs
   Số lượng đĩa ADFS/MFM.  Có thể được sử dụng khác nhau bởi những người khác nhau
   kiến trúc.

byte_per_char_h / byte_per_char_v
   Những thứ này hiện đã lỗi thời và không nên sử dụng.

trang_in_bank[4]
   Số lượng trang trong mỗi dãy bộ nhớ hệ thống (được sử dụng cho RiscPC).
   Điều này được thiết kế để sử dụng trên các hệ thống có bộ nhớ vật lý
   là không liền kề theo quan điểm của bộ xử lý.

trang_in_vram
   Số trang trong VRAM (được sử dụng trên Acorn RiscPC).  Giá trị này cũng có thể
   được sử dụng bởi trình tải nếu không thể lấy được kích thước của video RAM
   từ phần cứng.

initrd_start / initrd_size
   Điều này mô tả địa chỉ bắt đầu ảo kernel và kích thước của
   đĩa ram ban đầu.

thứ_bắt đầu
   Địa chỉ bắt đầu trong các khu vực của hình ảnh đĩa RAM trên đĩa mềm.

hệ thống_rev
   số sửa đổi hệ thống.

system_serial_low / system_serial_high
   số sê-ri 64-bit của hệ thống

mem_fclk_21285
   Tốc độ của bộ dao động ngoài tới 21285 (footbridge),
   điều khiển tốc độ của bus bộ nhớ, bộ đếm thời gian và cổng nối tiếp.
   Tùy thuộc vào tốc độ của CPU, giá trị của nó có thể nằm trong khoảng
   0-66 MHz. Nếu không có tham số nào được truyền hoặc giá trị bằng 0 được truyền,
   thì giá trị 50 Mhz là mặc định trên kiến trúc 21285.

đường dẫn[8][128]
   Những thứ này hiện đã lỗi thời và không nên sử dụng.

dòng lệnh
   Tham số dòng lệnh hạt nhân.  Thông tin chi tiết có thể được tìm thấy ở nơi khác.
