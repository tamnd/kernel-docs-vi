.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/isofs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================
Hệ thống tập tin ISO9660
==================

Các tùy chọn gắn kết tương tự như đối với phân vùng msdos và vfat.

=======================================================================
  gid=nnn Tất cả các tập tin trong phân vùng sẽ nằm trong nhóm nnn.
  uid=nnn Tất cả các tệp trong phân vùng sẽ thuộc sở hữu của id người dùng nnn.
  umask=nnn Mặt nạ cấp phép (xem umask(1)) cho phân vùng.
  =======================================================================

Các tùy chọn gắn kết giống như phân vùng vfat. Những điều này chỉ hữu ích
khi sử dụng đĩa được mã hóa bằng tiện ích mở rộng Joliet của Microsoft.

==================================================================================
 iocharset=name Bộ ký tự được sử dụng để chuyển đổi từ Unicode sang
		ASCII.  Tên tập tin Joliet được lưu trữ ở định dạng Unicode, nhưng
		Phần lớn Unix không biết cách xử lý Unicode.
		Ngoài ra còn có tùy chọn thực hiện các bản dịch UTF-8 với
		tùy chọn utf8.
  utf8 Mã hóa tên Unicode ở định dạng UTF-8. Mặc định là không.
 ==================================================================================

Tùy chọn gắn kết duy nhất cho hệ thống tập tin isofs.

===================================================================================
  block=512 Đặt kích thước khối cho đĩa thành 512 byte
  block=1024 Đặt kích thước khối cho đĩa thành 1024 byte
  block=2048 Đặt kích thước khối cho đĩa thành 2048 byte
  check=relaxed Khớp tên tệp với các kiểu chữ khác nhau
  check=strict Chỉ khớp các tên tệp có cùng kiểu chữ
  cruft Cố gắng xử lý các đĩa CD bị định dạng sai.
  map=off Không ánh xạ tên tệp không phải của Rock Ridge thành chữ thường
  map=normal Ánh xạ tên tệp không phải của Rock Ridge thành chữ thường
  map=acorn Như map=normal nhưng cũng áp dụng các tiện ích mở rộng Acorn nếu có
  mode=xxx Đặt quyền trên tệp thành xxx trừ khi Rock Ridge
		   tiện ích mở rộng đặt quyền theo cách khác
  dmode=xxx Đặt quyền trên thư mục thành xxx trừ khi Rock Ridge
		   tiện ích mở rộng đặt quyền theo cách khác
  ghi đèrockperm Đặt quyền trên các tập tin và thư mục theo
		   'mode' và 'dmode' mặc dù các phần mở rộng của Rock Ridge là
		   hiện tại.
  nojoliet Bỏ qua phần mở rộng Joliet nếu chúng có mặt.
  norock Bỏ qua các phần mở rộng của Rock Ridge nếu chúng có mặt.
  ẩn Loại bỏ hoàn toàn các tập tin ẩn khỏi hệ thống tập tin.
  showassoc Hiển thị các tập tin được đánh dấu bằng bit 'liên kết'
  bỏ ẩn Không dùng nữa; hiển thị các tập tin ẩn bây giờ là mặc định;
		   Nếu được, nó là từ đồng nghĩa với 'showassoc' sẽ
		   tạo lại hành vi bỏ ẩn trước đó
  session=x Chọn số phiên trên CD nhiều phiên
  sbsector=xxx Phiên bắt đầu từ khu vực xxx
 ===================================================================================

Các tài liệu gợi ý về tiêu chuẩn ISO 9660 có tại:

-ZZ0000ZZ
- ftp://ftp.ecma.ch/ecma-st/Ecma-119.pdf

Trích dẫn từ PDF "Phiên bản thứ 2 của ECMA-119 tiêu chuẩn này về mặt kỹ thuật
giống hệt với ISO 9660.", vì vậy nó là sự thay thế hợp lệ và miễn phí cho
thông số kỹ thuật ISO chính thức.