.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mtd/spi-intel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Nâng cấp BIOS bằng spi-intel
=================================

Nhiều CPU Intel như Baytrail và Braswell bao gồm máy chủ flash nối tiếp SPI
bộ điều khiển được sử dụng để chứa BIOS và dữ liệu cụ thể của nền tảng khác.
Vì nội dung của đèn flash nối tiếp SPI rất quan trọng để máy hoạt động,
nó thường được bảo vệ bởi các cơ chế bảo vệ phần cứng khác nhau để
tránh vô tình (hoặc cố ý) ghi đè lên nội dung.

Không phải tất cả các nhà sản xuất đều bảo vệ đèn flash nối tiếp SPI, chủ yếu là vì nó
cho phép nâng cấp hình ảnh BIOS trực tiếp từ hệ điều hành.

Trình điều khiển spi-intel giúp đọc và ghi sê-ri SPI
flash, nếu một số bit bảo vệ nhất định không được thiết lập và khóa. Nếu nó tìm thấy
bất kỳ cài đặt nào trong số đó được thiết lập, toàn bộ thiết bị MTD được đặt ở chế độ chỉ đọc để ngăn chặn
ghi đè một phần. Theo mặc định, trình điều khiển hiển thị đèn flash nối tiếp SPI
nội dung ở dạng chỉ đọc nhưng có thể thay đổi từ dòng lệnh kernel,
chuyển "spi_intel.writeable=1".

Xin lưu ý rằng việc ghi đè hình ảnh BIOS trên đèn flash nối tiếp SPI
có thể khiến máy không thể khởi động được và cần có thiết bị đặc biệt như
Dediprog để hồi sinh. Bạn đã được cảnh báo!

Dưới đây là các bước để nâng cấp MinnowBoard MAX BIOS trực tiếp từ
Linux.

1) Tải xuống và giải nén hình ảnh Minnowboard MAX BIOS SPI mới nhất
    [1]. Tại thời điểm viết bài này, hình ảnh mới nhất là v92.

2) Cài đặt gói mtd-utils [2]. Chúng tôi cần điều này để xóa SPI
    đèn flash nối tiếp. Các bản phân phối như Debian và Fedora có gói sẵn này với
    tên "mtd-utils".

3) Thêm "spi_intel.writeable=1" vào dòng lệnh kernel và khởi động lại
    bảng (bạn cũng có thể tải lại trình điều khiển chuyển "writeable=1" dưới dạng
    tham số mô-đun cho modprobe).

4) Sau khi bo mạch hoạt động trở lại, hãy tìm phân vùng MTD phù hợp
    (nó được đặt tên là "BIOS")::

# cat /proc/mtd
	dev: kích thước xóa tên
	mtd0: 00800000 00001000 "BIOS"

Vì vậy, ở đây nó sẽ là /dev/mtd0 nhưng nó có thể thay đổi.

5) Trước tiên hãy sao lưu hình ảnh hiện có::

# dd if=/dev/mtd0ro of=bios.bak
	16384+0 bản ghi trong
	16384+0 ghi lại
	Đã sao chép 8388608 byte (8,4 MB), 10,0269 giây, 837 kB/s

6) Xác minh bản sao lưu::

# sha1sum /dev/mtd0ro bios.bak
	fdbb011920572ca6c991377c4b418a0502668b73/dev/mtd0ro
	fdbb011920572ca6c991377c4b418a0502668b73 bios.bak

Tổng SHA1 phải khớp. Còn không thì đừng tiếp tục nữa!

7) Xóa đèn flash nối tiếp SPI. Sau bước này, không khởi động lại máy
    bảng! Nếu không nó sẽ không bắt đầu nữa::

# flash_erase /dev/mtd0 0 0
	Xóa 4 Kibyte @ 7ff000 - hoàn thành 100%

8) Sau khi hoàn thành mà không có lỗi, bạn có thể viết hình ảnh BIOS mới::

# dd if=MNW2MAX1.X64.0092.R01.1605221712.bin của=/dev/mtd0

9) Xác minh rằng nội dung mới của đèn flash nối tiếp SPI khớp với nội dung mới
    Hình ảnh BIOS::

# sha1sum /dev/mtd0ro MNW2MAX1.X64.0092.R01.1605221712.bin
	9b4df9e4be2057fceec3a5529ec3d950836c87a2 /dev/mtd0ro
	9b4df9e4be2057fceec3a5529ec3d950836c87a2 MNW2MAX1.X64.0092.R01.1605221712.bin

Tổng SHA1 phải khớp.

10) Bây giờ bạn có thể khởi động lại bo mạch của mình và quan sát BIOS mới khởi động
     đúng cách.

Tài liệu tham khảo
----------

[1] ZZ0000ZZ

[2] ZZ0000ZZ
