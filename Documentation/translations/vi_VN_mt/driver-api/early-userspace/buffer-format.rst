.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/early-userspace/buffer-format.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
định dạng bộ đệm initramfs
==========================

Al Viro, H. Peter Anvin

Với kernel 2.5.x, giao thức "ramdisk ban đầu" cũ đã được bổ sung
với giao thức "ramfs ban đầu".  Nội dung initramfs được thông qua
sử dụng cùng một giao thức bộ nhớ đệm được sử dụng bởi initrd, nhưng nội dung
là khác nhau.  Bộ đệm initramfs chứa một kho lưu trữ
mở rộng thành hệ thống tập tin ramfs; tài liệu này trình bày chi tiết về initramfs
định dạng bộ đệm.

Định dạng bộ đệm initramfs dựa trên "newc" hoặc "crc" CPIO
và có thể được tạo bằng tiện ích cpio(1).  CPIO
kho lưu trữ có thể được nén bằng gzip(1) hoặc bất kỳ thuật toán nào khác được cung cấp
thông qua CONFIG_DECOMPRESS_*.  Một phiên bản hợp lệ của bộ đệm initramfs là
do đó chỉ có một tệp .cpio.gz.

Định dạng đầy đủ của bộ đệm initramfs được xác định như sau
ngữ pháp, trong đó::

* được sử dụng để biểu thị "0 hoặc nhiều lần xuất hiện của"
	(|) chỉ ra các lựa chọn thay thế
	+ biểu thị sự nối
	GZIP() biểu thị nén gzip của toán hạng
	BZIP2() biểu thị nén bzip2 của toán hạng
	LZMA() biểu thị nén lzma của toán hạng
	XX() biểu thị nén xz của toán hạng
	LZO() biểu thị nén lzo của toán hạng
	LZ4() biểu thị nén lz4 của toán hạng
	ZSTD() biểu thị nén zstd của toán hạng
	ALGN(n) có nghĩa là đệm các byte rỗng vào ranh giới n-byte

initramfs := ("\0" ZZ0000ZZ cpio_compression_archive)*

cpio_compression_archive := (GZIP(cpio_archive) | BZIP2(cpio_archive)
		ZZ0000ZZ Xperia(cpio_archive) | LZO(cpio_archive)
		ZZ0001ZZ ZSTD(cpio_archive))

cpio_archive := cpio_file* + (<không có gì> | cpio_trailer)

cpio_file := ALGN(4) + cpio_header + tên tệp + "\0" + ALGN(4) + dữ liệu

cpio_trailer := ALGN(4) + cpio_header + "TRAILER!!!\0" + ALGN(4)


Theo thuật ngữ của con người, bộ đệm initramfs chứa một tập hợp các
kho lưu trữ cpio được nén và/hoặc không nén (trong "newc" hoặc "crc"
định dạng); số lượng tùy ý bằng 0 byte (để đệm) có thể được thêm vào
giữa các thành viên.

CPio "TRAILER!!!" mục (cpio cuối kho lưu trữ) là tùy chọn, nhưng là
không bị bỏ qua; xem phần "xử lý các liên kết cứng" bên dưới.

Cấu trúc của cpio_header như sau (tất cả các trường đều chứa
các số ASCII thập lục phân được đệm đầy đủ bằng '0' ở bên trái đến
toàn bộ chiều rộng của trường, ví dụ: số nguyên 4780 được biểu thị
bởi chuỗi ASCII "000012ac"):

============== =====================================================================
Tên trường Kích thước trường Ý nghĩa
============== =====================================================================
c_magic 6 byte Chuỗi "070701" hoặc "070702"
c_ino 8 byte Số inode của tệp
c_mode 8 byte Chế độ và quyền của tệp
c_uid 8 byte Tệp uid
c_gid 8 byte Tệp gid
c_nlink 8 byte Số lượng liên kết
c_mtime 8 byte Thời gian sửa đổi
c_filesize 8 byte Kích thước của trường dữ liệu
c_maj 8 byte Phần chính của số thiết bị tệp
c_min 8 byte Phần nhỏ của số thiết bị tệp
c_rmaj 8 byte Phần chính của tham chiếu nút thiết bị
c_rmin 8 byte Phần nhỏ của tham chiếu nút thiết bị
c_namesize 8 byte Độ dài của tên tệp, bao gồm cả \0 cuối cùng
c_chksum 8 byte Tổng kiểm tra trường dữ liệu nếu c_magic là 070702;
				 nếu không thì bằng không
============== =====================================================================

Trường c_mode khớp với nội dung của st_mode được trả về bởi stat(2)
trên Linux và mã hóa loại tệp cũng như quyền truy cập tệp.

c_mtime bị bỏ qua trừ khi CONFIG_INITRAMFS_PRESERVE_MTIME=y được đặt.

c_filesize phải bằng 0 đối với bất kỳ tệp nào không phải là tệp thông thường
hoặc liên kết tượng trưng.

c_namesize có thể chiếm nhiều hơn một dấu '\0', miễn là
giá trị không vượt quá PATH_MAX.  Điều này có thể hữu ích để đảm bảo rằng một
đoạn dữ liệu tệp tiếp theo được căn chỉnh, ví dụ: đến một khối hệ thống tập tin
ranh giới.

Trường c_chksum chứa tổng không dấu 32 bit đơn giản của tất cả
byte trong trường dữ liệu.  cpio(1) gọi đây là "crc", nghĩa là
rõ ràng là không chính xác (kiểm tra dự phòng theo chu kỳ là một cách khác và
kiểm tra tính toàn vẹn mạnh mẽ hơn đáng kể), tuy nhiên, đây là
thuật toán được sử dụng.

Nếu tên tệp là "TRAILER!!!" đây thực sự là một bản lưu trữ cuối cùng
điểm đánh dấu; c_filesize cho điểm đánh dấu cuối kho lưu trữ phải bằng 0.


Xử lý liên kết cứng
======================

Khi nhìn thấy một thư mục không có c_nlink > 1, (c_maj,c_min,c_ino)
tuple được tra cứu trong bộ đệm tuple.  Nếu không tìm thấy thì nhập vào
bộ đệm tuple và mục nhập được tạo như bình thường; nếu tìm thấy, một khó khăn
liên kết chứ không phải là bản sao thứ hai của tệp được tạo.  Nó không phải
cần thiết (nhưng được phép) bao gồm bản sao thứ hai của tệp
nội dung; nếu nội dung tệp không được bao gồm, trường c_filesize
nên được đặt thành 0 để cho biết không có phần dữ liệu nào theo sau.  Nếu dữ liệu là
hiện tại, phiên bản trước của tệp bị ghi đè; điều này cho phép
phiên bản mang dữ liệu của tệp xuất hiện ở bất kỳ đâu trong chuỗi
(GNU cpio được báo cáo là đính kèm dữ liệu vào phiên bản cuối cùng của
chỉ tập tin.)

c_filesize không được bằng 0 đối với liên kết tượng trưng.

Khi có thông báo "TRAILER!!!" điểm đánh dấu cuối kho lưu trữ được nhìn thấy, bộ đệm tuple được
đặt lại.  Điều này cho phép các tài liệu lưu trữ được tạo ra một cách độc lập được
nối.

Để kết hợp dữ liệu tệp từ các nguồn khác nhau (mà không cần phải
tạo lại các trường (c_maj,c_min,c_ino)), do đó, một trong hai
có thể sử dụng các kỹ thuật sau:

a) Phân tách các nguồn dữ liệu tệp khác nhau bằng "TRAILER!!!"
   điểm đánh dấu cuối kho lưu trữ, hoặc

b) Đảm bảo c_nlink == 1 cho tất cả các mục không thuộc thư mục.
