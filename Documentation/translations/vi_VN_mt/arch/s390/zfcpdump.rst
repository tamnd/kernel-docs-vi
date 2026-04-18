.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/zfcpdump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Công cụ kết xuất s390 SCSI (zfcpdump)
=====================================

Máy System z (z900 trở lên) cung cấp hỗ trợ phần cứng để tạo hệ thống
đổ vào đĩa SCSI. Quá trình kết xuất được bắt đầu bằng cách khởi động một công cụ kết xuất, công cụ này
phải tạo một kết xuất hình ảnh Linux hiện tại (có thể bị hỏng). để
không ghi đè lên bộ nhớ của Linux bị lỗi bằng dữ liệu của công cụ kết xuất,
phần cứng tiết kiệm một số bộ nhớ cộng với các bộ thanh ghi của boot CPU trước khi
công cụ kết xuất đã được tải. Tồn tại một giao diện phần cứng SCLP để lấy dữ liệu đã lưu
trí nhớ sau đó. Hiện tại 32 MB được lưu.

Việc triển khai zfcpdump này bao gồm một kernel kết xuất Linux cùng với
một công cụ kết xuất không gian người dùng, được tải cùng nhau vào vùng bộ nhớ đã lưu
dưới 32 MB. zfcpdump được cài đặt trên đĩa SCSI bằng zipl (như có trong
gói s390-tools) để làm cho thiết bị có khả năng khởi động. Người vận hành Linux
sau đó hệ thống có thể kích hoạt kết xuất SCSI bằng cách khởi động đĩa SCSI, trong đó zfcpdump
cư trú trên.

Công cụ kết xuất không gian người dùng truy cập vào bộ nhớ của hệ thống bị lỗi bằng cách
của giao diện /proc/vmcore. Giao diện này xuất hệ thống bị lỗi
bộ nhớ và các thanh ghi ở định dạng kết xuất lõi ELF. Để truy cập vào bộ nhớ có
được lưu bởi phần cứng SCLP, các yêu cầu sẽ được tạo tại thời điểm dữ liệu
là cần thiết bởi /proc/vmcore. Phần đuôi của bộ nhớ hệ thống bị lỗi
chưa được phần cứng lưu trữ có thể được sao chép từ bộ nhớ thực.

Để xây dựng kernel được kích hoạt kết xuất, tùy chọn cấu hình kernel CONFIG_CRASH_DUMP
phải được thiết lập.

Để có cấu hình kernel zfcpdump hợp lệ, hãy sử dụng "make zfcpdump_defconfig".

Công cụ zipl s390 tìm kiếm kernel zfcpdump và initrd/initramfs tùy chọn
dưới các vị trí sau:

* hạt nhân: <thư mục zfcpdump>/zfcpdump.image
* đĩa RAM: <thư mục zfcpdump>/zfcpdump.rd

Thư mục zfcpdump được xác định trong gói s390-tools.

Ứng dụng không gian người dùng của zfcpdump có thể nằm trong intitramfs hoặc
initrd. Nó cũng có thể được bao gồm trong initramfs kernel tích hợp. ứng dụng
đọc từ /proc/vmcore hoặc zcore/mem và ghi kết xuất hệ thống vào đĩa SCSI.

Gói công cụ s390 phiên bản 1.24.0 trở lên xây dựng zfcpdump bên ngoài
initramfs với một ứng dụng không gian người dùng ghi kết xuất vào SCSI
phân vùng.

Để biết thêm thông tin về cách sử dụng zfcpdump, hãy tham khảo s390 'Sử dụng kết xuất
Sách về công cụ có sẵn tại Trung tâm Kiến thức IBM:
ZZ0000ZZ
