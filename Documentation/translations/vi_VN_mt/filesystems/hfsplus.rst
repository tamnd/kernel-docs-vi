.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/hfsplus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Hệ thống tập tin Macintosh HFSPlus cho Linux
============================================

HFSPlus là hệ thống tập tin được giới thiệu lần đầu tiên trong MacOS 8.1.
HFSPlus có một số phần mở rộng cho HFS, bao gồm phân bổ 32 bit
khối, tên tệp unicode gồm 255 ký tự và kích thước tệp là 2^63 byte.


Tùy chọn gắn kết
=============

Khi gắn hệ thống tệp HFSPlus, các tùy chọn sau được chấp nhận:

người sáng tạo=cccc, loại=cccc
	Chỉ định các giá trị người tạo/loại như được hiển thị bởi công cụ tìm MacOS
	được sử dụng để tạo tập tin mới.  Giá trị mặc định: '????'.

uid=n, gid=n
	Chỉ định người dùng/nhóm sở hữu tất cả các tệp trên hệ thống tệp
	có cấu trúc quyền chưa được khởi tạo.
	Mặc định: id người dùng/nhóm của quá trình gắn kết.

umask=n
	Chỉ định umask (theo số bát phân) được sử dụng cho các tệp và thư mục
	có cấu trúc quyền chưa được khởi tạo.
	Mặc định: umask của quá trình gắn kết.

phiên=n
	Chọn phiên CDROM để gắn kết dưới dạng hệ thống tệp HFSPlus.  Mặc định là
	để lại quyết định đó cho trình điều khiển CDROM.  Tùy chọn này sẽ thất bại
	với bất cứ thứ gì ngoại trừ CDROM làm thiết bị cơ bản.

phần=n
	Chọn số phân vùng n từ các thiết bị.  Tùy chọn này chỉ làm cho
	ý nghĩa đối với CDROM vì chúng không thể được phân vùng trong Linux.
	Đối với các thiết bị đĩa, mã phân tích phân vùng chung thực hiện điều này
	cho chúng tôi.  Mặc định không phân tích bảng phân vùng.

phân hủy
	Phân tách các ký tự tên tập tin.

nút soạn thảo
	Không phân tách các ký tự tên tập tin.

lực lượng
	Được sử dụng để buộc quyền truy cập ghi vào các tập được đánh dấu là đã ghi nhật ký
	hoặc bị khóa.  Sử dụng có nguy cơ của riêng bạn.

nls=cccc
	Mã hóa để sử dụng khi trình bày tên tập tin.


Tài liệu tham khảo
==========

nguồn hạt nhân: <file:fs/hfsplus>

Apple Technote 1150 ZZ0000ZZ