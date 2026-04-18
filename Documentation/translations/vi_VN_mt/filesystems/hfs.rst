.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/hfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Hệ thống tập tin Macintosh HFS cho Linux
==================================


.. Note:: This filesystem doesn't have a maintainer.


HFS là viết tắt của ZZ0000ZZ và là hệ thống tập tin được sử dụng
bởi Mac Plus và tất cả các mẫu Macintosh sau này.  Macintosh trước đó
các mẫu đã sử dụng MFS (ZZ0001ZZ), không được hỗ trợ,
MacOS 8.1 trở lên hỗ trợ hệ thống tệp có tên HFS+ tương tự như
HFS nhưng được mở rộng ở nhiều lĩnh vực khác nhau.  Sử dụng trình điều khiển hệ thống tập tin hfsplus
để truy cập các hệ thống tập tin như vậy từ Linux.


Tùy chọn gắn kết
=============

Khi gắn hệ thống tệp HFS, các tùy chọn sau được chấp nhận:

người sáng tạo=cccc, loại=cccc
	Chỉ định các giá trị người tạo/loại như được hiển thị bởi công cụ tìm MacOS
	được sử dụng để tạo tập tin mới.  Giá trị mặc định: '????'.

uid=n, gid=n
  	Chỉ định người dùng/nhóm sở hữu tất cả các tệp trên hệ thống tệp.
	Mặc định: id người dùng/nhóm của quá trình gắn kết.

dir_umask=n, file_umask=n, umask=n
	Chỉ định umask được sử dụng cho tất cả các tập tin, tất cả các thư mục hoặc tất cả
	tập tin và thư mục.  Mặc định là umask của quá trình gắn kết.

phiên=n
  	Chọn phiên CDROM để gắn kết dưới dạng hệ thống tệp HFS.  Mặc định là
	để lại quyết định đó cho trình điều khiển CDROM.  Tùy chọn này sẽ thất bại
	với bất cứ thứ gì ngoại trừ CDROM làm thiết bị cơ bản.

phần=n
  	Chọn số phân vùng n từ các thiết bị.  Chỉ làm cho
	có ý nghĩa đối với CDROMS vì chúng không thể được phân vùng trong Linux.
	Đối với các thiết bị đĩa, mã phân tích phân vùng chung thực hiện điều này
	cho chúng tôi.  Mặc định không phân tích bảng phân vùng.

yên tĩnh
  	Bỏ qua các tùy chọn gắn kết không hợp lệ thay vì phàn nàn.


Ghi vào hệ thống tập tin HFS
==========================

HFS không phải là hệ thống tập tin UNIX, do đó nó không có các tính năng thông thường mà bạn có
mong đợi:

* Bạn không thể sửa đổi các bit set-uid, set-gid, cố định hoặc thực thi hoặc uid
   và gid của tập tin.
 * Bạn không thể tạo liên kết cứng hoặc liên kết tượng trưng, ​​tệp thiết bị, ổ cắm hoặc FIFO.

Mặt khác, HFS có khái niệm về nhiều nhánh cho mỗi tệp.  Những cái này
các nhánh không chuẩn được biểu diễn dưới dạng các tệp bổ sung ẩn trong tệp thông thường
không gian tên hệ thống tập tin là một loại cludge và tạo ra ngữ nghĩa cho
hơi lạ một chút:

* Bạn không thể tạo, xóa hoặc đổi tên các nhánh tài nguyên của tệp hoặc
   Siêu dữ liệu của Finder.
 * Tuy nhiên, chúng được tạo (với giá trị mặc định), bị xóa và đổi tên
   cùng với nhánh dữ liệu hoặc thư mục tương ứng.
 * Sao chép tệp sang hệ thống tệp khác sẽ làm mất các thuộc tính đó
   những thứ cần thiết để MacOS hoạt động.


Tạo hệ thống tập tin HFS
========================

Gói hfsutils của Robert Leslie chứa một chương trình có tên
hformat có thể được sử dụng để tạo hệ thống tập tin HFS. Xem
<ZZ0000ZZ để biết chi tiết.


Tín dụng
=======

Trình điều khiển HFS được viết bởi Paul H. Hargrovea (hargrove@sccm.Stanford.EDU).
Roman Zippel (roman@ardistech.com) đã viết lại phần lớn mã và đưa
trong các quy trình btree bắt nguồn từ trình điều khiển hfsplus của Brad Boyer.