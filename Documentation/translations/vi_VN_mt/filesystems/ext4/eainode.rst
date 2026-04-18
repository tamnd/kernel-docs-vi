.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/eainode.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Giá trị thuộc tính mở rộng lớn
-------------------------------

Để cho phép ext4 lưu trữ các giá trị thuộc tính mở rộng không phù hợp với
inode hoặc trong khối thuộc tính mở rộng duy nhất được gắn vào một inode,
tính năng EA_INODE cho phép chúng ta lưu trữ giá trị trong các khối dữ liệu của
một nút tập tin thông thường. “Inode EA” này chỉ được liên kết từ phần mở rộng
chỉ mục tên thuộc tính và không được xuất hiện trong mục nhập thư mục. các
trường i_atime của inode được sử dụng để lưu trữ tổng kiểm tra giá trị xattr;
và i_ctime/i_version lưu trữ số tham chiếu 64 bit, cho phép
chia sẻ các giá trị xattr lớn giữa nhiều nút sở hữu. cho
khả năng tương thích ngược với các phiên bản cũ hơn của tính năng này,
i_mtime/i_Generation ZZ0001ZZ lưu trữ tham chiếu ngược tới số inode
và i_thế hệ của inode sở hữu ZZ0000ZZ (trong trường hợp EA
inode không được tham chiếu bởi nhiều nút) để xác minh rằng nút EA
là cái chính xác đang được truy cập.