.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ecryptfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================================================
eCryptfs: Hệ thống tệp mật mã xếp chồng cho Linux
======================================================

eCryptfs là phần mềm miễn phí. Vui lòng xem tệp COPYING để biết chi tiết.
Để biết tài liệu, vui lòng xem các tập tin trong thư mục con doc/.  cho
hướng dẫn xây dựng và cài đặt vui lòng xem tệp INSTALL.

:Người bảo trì: Phillip Hellewell
:Nhà phát triển chính: Michael A. Halcrow <mhalcrow@us.ibm.com>
: Nhà phát triển: Michael C. Thompson
             Kent Yoder
:Trang web: ZZ0000ZZ

Phần mềm này hiện đang được phát triển. Đảm bảo
duy trì một bản sao lưu của bất kỳ dữ liệu nào bạn ghi vào eCryptfs.

eCryptfs yêu cầu các công cụ không gian người dùng có thể tải xuống từ
Trang web SourceForge:

ZZ0000ZZ

Yêu cầu về không gian người dùng bao gồm:

- Các tiêu đề và thư viện khóa không gian người dùng của David Howells (phiên bản
  1.0 trở lên), có thể lấy được từ
  ZZ0000ZZ
- Libgcrypt


.. note::

   In the beta/experimental releases of eCryptfs, when you upgrade
   eCryptfs, you should copy the files to an unencrypted location and
   then copy the files back into the new eCryptfs mount to migrate the
   files.


Cụm mật khẩu toàn núi
=====================

Tạo một thư mục mới để eCryptfs sẽ ghi mã hóa của nó vào đó
các tập tin (tức là /root/crypt).  Sau đó, tạo thư mục điểm gắn kết
(tức là /mnt/crypt).  Bây giờ là lúc gắn eCryptfs::

mount -t ecryptfs/root/crypt/mnt/crypt

Bạn sẽ được nhắc nhập cụm mật khẩu và muối (muối có thể
trống).

Hãy thử viết một tập tin mới::

echo "Xin chào thế giới" > /mnt/crypt/hello.txt

Hoạt động sẽ hoàn tất.  Chú ý rằng có một tập tin mới trong
/root/crypt có kích thước tối thiểu là 12288 byte (tùy thuộc vào
kích thước trang chủ).  Đây là tập tin cơ bản được mã hóa cho những gì bạn
vừa viết.  Để kiểm tra khả năng đọc, từ đầu đến cuối, bạn cần xóa
khóa phiên người dùng:

keyctl rõ ràng @u

Sau đó umount /mnt/crypt và gắn kết lại theo hướng dẫn đã cho
ở trên.

::

mèo /mnt/crypt/hello.txt


Ghi chú
=====

eCryptfs phiên bản 0.1 chỉ nên được gắn vào (1) thư mục trống
hoặc (2) thư mục chứa các tập tin chỉ được tạo bởi eCryptfs. Nếu bạn
gắn kết một thư mục có các tệp tồn tại từ trước không được tạo bởi eCryptfs,
thì hành vi không được xác định. Không chạy eCryptfs ở mức độ chi tiết cao hơn
cấp độ trừ khi bạn làm như vậy với mục đích duy nhất là gỡ lỗi hoặc
phát triển, vì các giá trị bí mật sẽ được ghi vào nhật ký hệ thống
trong trường hợp đó.


Mike Halcrow
mhalcrow@us.ibm.com