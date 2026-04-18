.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ntfs3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
NTFS3
=====

Tóm tắt và tính năng
====================

NTFS3 là trình điều khiển Đọc-Ghi NTFS đầy đủ chức năng. Trình điều khiển hoạt động với NTFS
phiên bản lên tới 3.1. Loại hệ thống tệp để sử dụng khi gắn kết là ZZ0000ZZ.

- Trình điều khiển này triển khai hỗ trợ đọc/ghi NTFS cho dữ liệu bình thường, thưa thớt và
  tập tin nén.
- Hỗ trợ phát lại tạp chí gốc.
- Hỗ trợ xuất NFS của khối NTFS được gắn.
- Hỗ trợ các thuộc tính mở rộng. Thuộc tính mở rộng được xác định trước:

- ZZ0000ZZ được/thiết lập bảo mật

Mô tả: SECURITY_DESCRIPTOR_RELATIVE

- ZZ0000ZZ nhận/đặt thuộc tính tệp/thư mục ntfs.

Lưu ý: Áp dụng cho các tập tin trống, điều này cho phép chuyển đổi loại giữa
	  thưa thớt (0x200), nén (0x800) và bình thường.

- ZZ0000ZZ nhận/đặt thuộc tính tệp/thư mục ntfs.

Cùng giá trị với system.ntfs_attrib nhưng luôn biểu thị dưới dạng big-endian
	  (độ bền của system.ntfs_attrib giống với CPU).

Tùy chọn gắn kết
=============

Danh sách bên dưới mô tả các tùy chọn gắn kết được hỗ trợ bởi trình điều khiển NTFS3 ngoài
những cái chung chung. Bạn có thể sử dụng mọi tùy chọn gắn kết với tùy chọn ZZ0000ZZ. Nếu nó ở trong
bảng này được đánh dấu bằng không, điều đó có nghĩa là mặc định không có ZZ0001ZZ.

.. flat-table::
   :widths: 1 5
   :fill-cells:

   * - iocharset=name
     - This option informs the driver how to interpret path strings and
       translate them to Unicode and back. If this option is not set, the
       default codepage will be used (CONFIG_NLS_DEFAULT).

       Example: iocharset=utf8

   * - uid=
     - :rspan:`1`
   * - gid=

   * - umask=
     - Controls the default permissions for files/directories created after
       the NTFS volume is mounted.

   * - dmask=
     - :rspan:`1` Instead of specifying umask which applies both to files and
       directories, fmask applies only to files and dmask only to directories.
   * - fmask=

   * - nohidden
     - Files with the Windows-specific HIDDEN (FILE_ATTRIBUTE_HIDDEN) attribute
       will not be shown under Linux.

   * - sys_immutable
     - Files with the Windows-specific SYSTEM (FILE_ATTRIBUTE_SYSTEM) attribute
       will be marked as system immutable files.

   * - hide_dot_files
     - Updates the Windows-specific HIDDEN (FILE_ATTRIBUTE_HIDDEN) attribute
       when creating and moving or renaming files. Files whose names start
       with a dot will have the HIDDEN attribute set and files whose names
       do not start with a dot will have it unset.

   * - windows_names
     - Prevents the creation of files and directories with a name not allowed
       by Windows, either because it contains some not allowed character (which
       are the characters " * / : < > ? \\ | and those whose code is less than
       0x20), because the name (with or without extension) is a reserved file
       name (CON, AUX, NUL, PRN, LPT1-9, COM1-9) or because the last character
       is a space or a dot. Existing such files can still be read and renamed.

   * - discard
     - Enable support of the TRIM command for improved performance on delete
       operations, which is recommended for use with the solid-state drives
       (SSD).

   * - force
     - Forces the driver to mount partitions even if volume is marked dirty.
       Not recommended for use.

   * - sparse
     - Create new files as sparse.

   * - showmeta
     - Use this parameter to show all meta-files (System Files) on a mounted
       NTFS partition. By default, all meta-files are hidden.

   * - prealloc
     - Preallocate space for files excessively when file size is increasing on
       writes. Decreases fragmentation in case of parallel write operations to
       different files.

   * - acl
     - Support POSIX ACLs (Access Control Lists). Effective if supported by
       Kernel. Not to be confused with NTFS ACLs. The option specified as acl
       enables support for POSIX ACLs.

danh sách việc cần làm
=========
- Hỗ trợ ghi nhật ký đầy đủ trên JBD. Hiện tại việc phát lại tạp chí được hỗ trợ
  điều này không nhất thiết phải hiệu quả như JBD.

Tài liệu tham khảo
==========
- Phiên bản thương mại của trình điều khiển NTFS dành cho Linux.
	ZZ0000ZZ

- Địa chỉ email trực tiếp để nhận phản hồi và yêu cầu về việc triển khai NTFS3.
	almaz.alexandrovich@paragon-software.com