.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/udf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Hệ thống tập tin UDF
===============

Nếu bạn gặp vấn đề khi đọc đĩa UDF bằng trình điều khiển này,
vui lòng báo cáo chúng theo tệp MAINTAINERS.

Hỗ trợ ghi yêu cầu trình điều khiển khối hỗ trợ ghi.  Hiện tại
dvd+rw drives and media support true random sector writes, and so a udf
hệ thống tập tin trên các thiết bị như vậy có thể được gắn trực tiếp vào việc đọc/ghi.  CD-RW
Tuy nhiên, phương tiện truyền thông không hỗ trợ điều này.  Thay vào đó, phương tiện có thể được định dạng
đối với chế độ gói bằng tiện ích cdrwtool thì trình điều khiển pktcdvd có thể
được liên kết với thiết bị cd bên dưới để cung cấp bộ đệm cần thiết
và các chu kỳ đọc-sửa-ghi để cho phép ghi khu vực ngẫu nhiên của hệ thống tập tin
trong khi cung cấp cho phần cứng chỉ ghi gói đầy đủ.  Trong khi không
cần thiết cho phương tiện dvd+rw, việc sử dụng trình điều khiển pktcdvd thường nâng cao
hiệu suất do hỗ trợ đọc-sửa-ghi được cung cấp nội bộ rất kém
bằng phần mềm ổ đĩa.

-------------------------------------------------------------------------------

Các tùy chọn gắn kết sau được hỗ trợ:

=====================================================
	gid= Đặt nhóm mặc định.
	umask=Đặt ô mặc định.
	mode= Đặt quyền truy cập tệp mặc định.
	dmode= Đặt quyền truy cập thư mục mặc định.
	uid= Đặt người dùng mặc định.
	bs= Đặt kích thước khối.
	bỏ ẩn Hiển thị các tập tin ẩn khác.
	phục hồi Hiển thị các tập tin đã xóa trong danh sách.
	adinicb Nhúng dữ liệu vào inode (mặc định)
	noadinicb Không nhúng dữ liệu vào inode
	shortad Sử dụng quảng cáo ngắn
	longad Sử dụng quảng cáo dài (mặc định)
	nostrict Bỏ đặt sự tuân thủ nghiêm ngặt
	iocharset= Đặt bộ ký tự NLS
	=====================================================

Các tùy chọn uid= và gid= cần được giải thích thêm một chút.  Họ sẽ chấp nhận một
giá trị số thập phân và tất cả các nút trên mount đó sẽ xuất hiện dưới dạng
thuộc về uid và gid đó.  Tùy chọn gắn kết cũng chấp nhận chuỗi "quên".
Tùy chọn quên khiến tất cả ID được ghi vào đĩa dưới dạng -1, đây là một cách
của tiêu chuẩn UDF để cho biết rằng ID không được hỗ trợ cho các tệp này.

Đối với việc sử dụng phương tiện di động thông thường trên máy tính để bàn, bạn nên đặt ID thành ID của
người dùng đã đăng nhập tương tác và cũng chỉ định tùy chọn quên.  Lối này
người dùng tương tác sẽ luôn xem các tập tin trên đĩa là của mình.

Phần còn lại dành cho việc gỡ lỗi và khắc phục sự cố:

===== ===================================
	novrs Bỏ qua nhận dạng chuỗi âm lượng
	===== ===================================

Những điều sau đây mong đợi một sự bù đắp từ 0.

================================================================
	session= Đặt phiên CDROM (mặc định= phiên cuối cùng)
	neo= Ghi đè vị trí neo tiêu chuẩn. (mặc định= 256)
	Lastblock= Đặt khối cuối cùng của hệ thống tập tin/
	================================================================

-------------------------------------------------------------------------------


Để biết phiên bản và bộ công cụ mới nhất, hãy xem:
	ZZ0000ZZ

Tài liệu về UDF và ECMA 167 có sẵn FREE từ:
	-ZZ0000ZZ
	-ZZ0001ZZ