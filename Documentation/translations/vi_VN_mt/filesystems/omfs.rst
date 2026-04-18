.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/omfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Hệ thống tập tin MPEG được tối ưu hóa (OMFS)
============================================

Tổng quan
=========

OMFS là hệ thống tệp được SonicBlue tạo để sử dụng trong ReplayTV DVR
và máy nghe nhạc Rio Karma MP3.  Hệ thống tập tin dựa trên phạm vi, sử dụng
kích thước khối từ 2k đến 8k, với các thư mục dựa trên hàm băm.  Cái này
trình điều khiển hệ thống tập tin có thể được sử dụng để đọc và ghi đĩa từ những
thiết bị.

Lưu ý, không nên sử dụng FS này thay cho tài liệu chung
hệ thống tập tin cho thiết bị truyền thông trực tuyến của riêng bạn.  Hệ thống tập tin Linux gốc
có thể sẽ hoạt động tốt hơn.

Thêm thông tin có sẵn tại:

ZZ0000ZZ

Nhiều tiện ích khác nhau, bao gồm mkomfs và omfsck, được bao gồm trong
omfsprogs, có sẵn tại:

ZZ0000ZZ

Hướng dẫn được bao gồm trong README của nó.

Tùy chọn
========

OMFS hỗ trợ các tùy chọn thời gian gắn kết sau:

========================================================
    uid=n tạo tất cả các tệp thuộc sở hữu của người dùng được chỉ định
    gid=n tạo tất cả các tệp thuộc sở hữu của nhóm được chỉ định
    umask=xxx đặt quyền umask thành xxx
    fmask=xxx đặt umask thành xxx cho các tập tin
    dmask=xxx đặt umask thành xxx cho các thư mục
    ========================================================

Định dạng đĩa
=============

OMFS phân biệt giữa "khối hệ thống" và khối dữ liệu thông thường.  Khối hệ thống
nhóm bao gồm thông tin siêu khối, siêu dữ liệu tệp, cấu trúc thư mục,
và phạm vi.  Mỗi sysblock có một tiêu đề chứa CRC của toàn bộ
sysblock và có thể được nhân đôi thành các khối liên tiếp trên đĩa.  Một khối hệ thống có thể
có kích thước nhỏ hơn khối dữ liệu, nhưng vì cả hai đều được xử lý bởi
cùng số khối 64 bit, mọi khoảng trống còn lại trong khối hệ thống nhỏ hơn sẽ được
chưa sử dụng.

Thông tin tiêu đề Sysblock::

cấu trúc omfs_header {
	    __be64 h_self;                  /* Khối FS nơi đặt khối này */
	    __be32 h_body_size;             /* kích thước dữ liệu hữu ích sau tiêu đề */
	    __be16 h_crc;                   /* crc-ccitt của byte body_size */
	    char h_fill1[2];
	    u8 h_version;                   /* phiên bản, luôn là 1 */
	    char h_type;                    /* OMFS_INODE_X */
	    u8 h_magic;                     /* OMFS_IMAGIC */
	    u8 h_check_xor;                 /* XOR của các byte tiêu đề trước đó */
	    __be32 h_fill2;
    };

Các tập tin và thư mục đều được đại diện bởi omfs_inode::

cấu trúc omfs_inode {
	    cấu trúc omfs_header i_head;      /* tiêu đề */
	    __be64 i_parent;                /* cha chứa inode này */
	    __be64 i_anh chị em;               /* inode tiếp theo trong nhóm băm */
	    __be64 i_ctime;                 /* ctime, tính bằng mili giây */
	    char i_fill1[35];
	    char i_type;                    /* OMFS_[DIR,FILE] */
	    __be32 i_fill2;
	    char i_fill3[64];
	    char i_name[OMFS_NAMELEN];      /*tên tập tin */
	    __be64 i_size;                  /* kích thước file, tính bằng byte */
    };

Các thư mục trong OMFS được triển khai dưới dạng bảng băm lớn.  Tên tập tin là
được băm sau đó thêm vào danh sách nhóm bắt đầu từ OMFS_DIR_START.
Việc tra cứu yêu cầu băm tên tệp, sau đó tìm kiếm qua các con trỏ i_sibling
cho đến khi tìm thấy kết quả phù hợp trên i_name.  Các thùng trống được biểu thị bằng khối
con trỏ có tất cả số 1 (~0).

Một tập tin là một cấu trúc omfs_inode theo sau là một bảng phạm vi bắt đầu tại
OMFS_EXTENT_START::

cấu trúc omfs_extent_entry {
	    __be64 e_cluster;               /*vị trí bắt đầu của tập hợp các khối */
	    __be64 e_blocks;                /* số khối sau e_cluster */
    };

cấu trúc omfs_extent {
	    __be64 e_next;                  /* vị trí bảng phạm vi tiếp theo */
	    __be32 e_extent_count;          /* tổng số # extents trong bảng này */
	    __be32 e_fill;
	    cấu trúc omfs_extent_entry e_entry;       /* bắt đầu các mục phạm vi */
    };

Mỗi phạm vi chứa phần bù khối theo sau là số khối được phân bổ cho
mức độ.  Phạm vi cuối cùng trong mỗi bảng là một dấu kết thúc với e_cluster
là ~0 và e_blocks là phần bù của tổng số khối
trong bảng.

Nếu bảng này bị tràn, một nút tiếp tục được ghi và trỏ tới bởi
e_next.  Chúng có tiêu đề nhưng thiếu phần còn lại của cấu trúc inode.
