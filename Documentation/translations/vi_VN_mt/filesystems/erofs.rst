.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/erofs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=========================================
EROFS - Hệ thống tệp chỉ đọc nâng cao
======================================

Tổng quan
========

Hệ thống tệp EROFS là viết tắt của Hệ thống tệp chỉ đọc nâng cao.  Nó nhằm mục đích hình thành một
thay vào đó, giải pháp hệ thống tệp chỉ đọc chung cho các trường hợp sử dụng chỉ đọc khác nhau
chỉ tập trung vào việc tiết kiệm không gian lưu trữ mà không xem xét bất kỳ tác dụng phụ nào
về hiệu suất thời gian chạy.

Nó được thiết kế để đáp ứng nhu cầu về tính linh hoạt, khả năng mở rộng tính năng và người dùng
thân thiện với tải trọng, v.v. Ngoài những thứ đó, nó vẫn được giữ đơn giản
hệ thống tập tin hiệu suất cao thân thiện với truy cập ngẫu nhiên để loại bỏ I/O không cần thiết
khuếch đại và chi phí lưu trú trong bộ nhớ so với các phương pháp tương tự.

Nó được triển khai để trở thành lựa chọn tốt hơn cho các tình huống sau:

- phương tiện lưu trữ chỉ đọc hoặc

- một phần của giải pháp chỉ đọc hoàn toàn đáng tin cậy, có nghĩa là nó cần phải được
   bất biến và giống hệt từng bit với hình ảnh vàng chính thức cho
   việc phát hành của họ do lý do bảo mật hoặc các cân nhắc khác và

- hy vọng giảm thiểu không gian lưu trữ bổ sung với hiệu suất được đảm bảo từ đầu đến cuối
   bằng cách sử dụng bố cục nhỏ gọn, nén tệp trong suốt và truy cập trực tiếp,
   đặc biệt đối với những thiết bị nhúng có bộ nhớ hạn chế và mật độ cao
   máy chủ có nhiều container.

Dưới đây là các tính năng chính của EROFS:

- Thiết kế trên đĩa Little endian;

- Phân phối dựa trên khối và phân phối dựa trên tệp trên fscache là
   được hỗ trợ;

- Hỗ trợ nhiều thiết bị tham khảo các đốm màu bên ngoài, có thể sử dụng được
   cho hình ảnh vùng chứa;

- Địa chỉ khối 32-bit cho mỗi thiết bị, do đó không gian địa chỉ 16TiB tại
   hiện tại hầu hết có kích thước khối 4KiB;

- Hai bố trí inode cho các yêu cầu khác nhau:

============================================================================
                          nhỏ gọn (v1) mở rộng (v2)
   ============================================================================
   Kích thước siêu dữ liệu Inode 32 byte 64 byte
   Kích thước tệp tối đa 4 GiB 16 EiB (cũng bị giới hạn bởi kích thước âm lượng tối đa)
   Uid/gids tối đa 65536 4294967296
   Dấu thời gian trên mỗi inode không có (dấu thời gian 64 + 32 bit)
   Liên kết cứng tối đa 65536 4294967296
   Siêu dữ liệu dành riêng 8 byte 18 byte
   ============================================================================

- Hỗ trợ các thuộc tính mở rộng dưới dạng tùy chọn;

- Hỗ trợ bộ lọc nở hoa giúp tăng tốc độ tra cứu thuộc tính mở rộng tiêu cực;

- Hỗ trợ ACL POSIX.1e bằng cách sử dụng các thuộc tính mở rộng;

- Hỗ trợ nén dữ liệu trong suốt dưới dạng tùy chọn:
   Các thuật toán LZ4, MicroLZMA, DEFLATE và Zstandard có thể được sử dụng trên mỗi tệp
   cơ sở; Ngoài ra tính năng giải nén tại chỗ cũng được hỗ trợ tránh hiện tượng nảy
   bộ đệm bị nén và việc đập bộ đệm trang không cần thiết.

- Hỗ trợ sao chép dữ liệu dựa trên chunk và dữ liệu nén băm
   chống trùng lặp;

- Hỗ trợ đóng gói nội tuyến so với siêu dữ liệu không được căn chỉnh theo địa chỉ byte
   hoặc các lựa chọn thay thế kích thước khối nhỏ hơn;

- Hỗ trợ hợp nhất dữ liệu tail-end thành một inode đặc biệt dưới dạng các đoạn.

- Hỗ trợ các folio lớn để sử dụng THP (Trang lớn trong suốt);

- Hỗ trợ I/O trực tiếp trên các tệp không nén để tránh lặp lại bộ nhớ đệm kép
   thiết bị;

- Hỗ trợ FSDAX trên hình ảnh không nén cho các thùng chứa và đĩa ram an toàn trong
   để loại bỏ bộ đệm trang không cần thiết.

- Hỗ trợ tải theo yêu cầu dựa trên tệp với cơ sở hạ tầng Fscache.

Cây git sau đây cung cấp các công cụ không gian người dùng hệ thống tệp trong
phát triển, chẳng hạn như công cụ định dạng (mkfs.erofs), tính nhất quán trên đĩa &
công cụ kiểm tra tính tương thích (fsck.erofs) và công cụ gỡ lỗi (dump.erofs):

- git://git.kernel.org/pub/scm/linux/kernel/git/xiang/erofs-utils.git

Để biết thêm thông tin, vui lòng tham khảo trang web tài liệu:

-ZZ0000ZZ

Các lỗi và bản vá đều được chào đón, vui lòng giúp đỡ chúng tôi và gửi tới địa chỉ sau
danh sách gửi thư linux-erofs:

- danh sách gửi thư linux-erofs <linux-erofs@lists.ozlabs.org>

Tùy chọn gắn kết
=============

==================================================================================
(no)user_xattr Thiết lập thuộc tính người dùng mở rộng. Lưu ý: xattr đã được bật
                       theo mặc định nếu CONFIG_EROFS_FS_XATTR được chọn.
(no)acl Thiết lập Danh sách kiểm soát truy cập POSIX. Lưu ý: acl đã được bật
                       theo mặc định nếu CONFIG_EROFS_FS_POSIX_ACL được chọn.
cache_strategy=%s Chọn chiến lược giải nén bộ nhớ đệm kể từ bây giờ:

============================================================
                         chỉ tắt tính năng giải nén I/O tại chỗ;
                        đọc trước Cache bản nén vật lý chưa hoàn chỉnh cuối cùng
                                   cụm để đọc thêm. Nó vẫn vậy
                                   giải nén I/O tại chỗ cho phần còn lại
                                   các cụm vật lý nén;
                       đọc xung quanh Bộ đệm cả hai đầu được nén không đầy đủ
                                   cụm vật lý để đọc thêm.
                                   Nó vẫn thực hiện giải nén I/O tại chỗ
                                   cho các cụm vật lý nén còn lại.
		       ============================================================
dax={always,never} Sử dụng quyền truy cập trực tiếp (không có bộ đệm trang).  Xem
                       Tài liệu/hệ thống tập tin/dax.rst.
dax Một tùy chọn cũ là bí danh của ZZ0000ZZ.
device=%s Chỉ định đường dẫn đến một thiết bị bổ sung sẽ được sử dụng cùng nhau.
directio (Đối với các mount được hỗ trợ bằng tệp) Sử dụng I/O trực tiếp để truy cập vào phần hỗ trợ
                       các tệp và I/O không đồng bộ sẽ được bật nếu được hỗ trợ.
fsid=%s Chỉ định ID hình ảnh hệ thống tập tin cho back-end Fscache.
domain_id=%s Chỉ định ID miền đáng tin cậy cho chế độ fscache để
                       các hình ảnh khác nhau có cùng các đốm màu, được xác định bằng ID blob,
                       có thể chia sẻ bộ nhớ trong cùng một miền đáng tin cậy.
                       Cũng được sử dụng cho các hệ thống tập tin khác nhau với tính năng chia sẻ trang inode
                       được phép chia sẻ bộ đệm trang trong miền đáng tin cậy.
fsoffset=%llu Chỉ định độ lệch hệ thống tệp được căn chỉnh theo khối cho thiết bị chính.
inode_share Bật chia sẻ trang inode cho hệ thống tập tin này.  Inode với
                       nội dung giống hệt nhau trong cùng một ID miền có thể chia sẻ
                       bộ đệm trang.
==================================================================================

Mục nhập hệ thống
=============

Thông tin về hệ thống tệp erofs được gắn có thể được tìm thấy trong /sys/fs/erofs.
Mỗi hệ thống tập tin được gắn sẽ có một thư mục trong /sys/fs/erofs dựa trên
tên thiết bị (tức là /sys/fs/erofs/sda).
(xem thêm Tài liệu/ABI/testing/sysfs-fs-erofs)

Chi tiết trên đĩa
===============

Bản tóm tắt
-------
Khác với các hệ thống tệp chỉ đọc khác, ổ EROFS được thiết kế
đơn giản nhất có thể::

|-> căn chỉnh theo kích thước khối
   ____________________________________________________________
  ZZ0000ZZSBZZ0001ZZ ... ZZ0002ZZ ... Siêu dữ liệu ZZ0003ZZ Dữ liệu ZZ0004ZZ |
  ZZ0005ZZ__ZZ0006ZZ_____ZZ0007ZZ_____ZZ0008ZZ__________ZZ0009ZZ______|
  0 +1K

Tất cả các vùng dữ liệu phải được căn chỉnh theo kích thước khối, nhưng các vùng siêu dữ liệu
có thể không. Hiện tại, tất cả siêu dữ liệu có thể được quan sát ở hai không gian (chế độ xem) khác nhau:

1. Không gian siêu dữ liệu Inode

Mỗi inode hợp lệ phải được căn chỉnh với một khe inode cố định
    giá trị (32 byte) và được thiết kế để phù hợp với kích thước inode nhỏ gọn.

Mỗi inode có thể được tìm thấy trực tiếp bằng công thức sau:
         inode offset = meta_blkaddr * block_size + 32 * nid

    ::

|-> căn chỉnh với 8B
                                            |-> theo sát
     + khối meta_blkaddr |-> vị trí khác
       _____________________________________________________________________
     ZZ0000ZZ inode ZZ0001ZZ mở rộng ZZ0002ZZ ... | nút ...
     ZZ0003ZZ_______ZZ0004ZZ (tùy chọn)ZZ0005ZZ_____|__________
              |-> căn chỉnh theo kích thước khe inode
                   .                   .
                 .                         .
               .                              .
             .                                    .
           .                                         .
         .                                              .
       .____________________________________________________|-> căn chỉnh với 4B
       ZZ0006ZZ chia sẻ xattrs ZZ0007ZZ
       ZZ0008ZZ_______________ZZ0009ZZ
       ZZ0010ZZ->x * 4 byte<-|               .
                           .                .                 .
                     .                      .                   .
                .                           .                     .
            ._______________________________.______________________.
            ZZ0011ZZ id ZZ0012ZZ id ZZ0013ZZ id ZZ0014ZZ ... ZZ0015ZZ ... |
            ZZ0016ZZ____ZZ0017ZZ____ZZ0018ZZ____ZZ0019ZZ_____ZZ0020ZZ_____|
                                            |-> căn chỉnh với 4B
                                                        |-> căn chỉnh với 4B

Inode có thể là 32 hoặc 64 byte, có thể phân biệt được với một byte thông thường
    trường mà tất cả các phiên bản inode đều có -- i_format::

__________________ __________________
       ZZ0000ZZ ZZ0001ZZ
       ZZ0002ZZ ZZ0003ZZ
       ZZ0004ZZ ZZ0005ZZ
       ZZ0006ZZ ZZ0007ZZ
       ZZ0008ZZ 32 byte ZZ0009ZZ
                                        ZZ0010ZZ
                                        ZZ0011ZZ 64 byte

Xattrs, phạm vi, dữ liệu nội tuyến được đặt sau nút tương ứng với
    căn chỉnh phù hợp và chúng có thể là tùy chọn cho các ánh xạ dữ liệu khác nhau.
    _hiện tại_ tổng cộng 5 bố cục dữ liệu được hỗ trợ:

== ==========================================================================
     0 dữ liệu tệp phẳng không có dữ liệu nội tuyến (không có phạm vi);
     1 nén dữ liệu đầu ra có kích thước cố định (với các chỉ mục không được nén);
     2 dữ liệu tệp phẳng với dữ liệu đóng gói đuôi nội tuyến (không có phạm vi);
     3 nén dữ liệu đầu ra có kích thước cố định (với các chỉ mục được nén, v5.3+);
     Tệp dựa trên 4 đoạn (v5.15+).
    == ==========================================================================

Kích thước của xattr tùy chọn được biểu thị bằng i_xattr_count trong inode
    tiêu đề. Các xattr hoặc xattr lớn được chia sẻ bởi nhiều tệp khác nhau có thể được
    được lưu trữ trong siêu dữ liệu xattrs được chia sẻ thay vì được nội tuyến ngay sau inode.

2. Không gian siêu dữ liệu xattrs được chia sẻ

Không gian xattrs được chia sẻ tương tự như không gian inode ở trên, bắt đầu bằng
    một khối cụ thể được chỉ định bởi xattr_blkaddr, được sắp xếp từng khối một với
    căn chỉnh thích hợp.

Mỗi chia sẻ xattr cũng có thể được tìm thấy trực tiếp theo công thức sau:
         xattr offset = xattr_blkaddr * block_size + 4 * xattr_id

::

|-> căn chỉnh theo 4 byte
    + khối xattr_blkaddr |-> căn chỉnh theo 4 byte
     _________________________________________________________________________
    ZZ0000ZZ xattr_entry ZZ0001ZZ ... Dữ liệu ZZ0002ZZ xattr ...
    ZZ0003ZZ_____________ZZ0004ZZ_____ZZ0005ZZ_______________

Thư mục
-----------
Tất cả các thư mục hiện được sắp xếp theo định dạng nhỏ gọn trên đĩa. Lưu ý rằng
mỗi khối thư mục được chia thành các vùng chỉ mục và tên để hỗ trợ
tra cứu tập tin ngẫu nhiên, và tất cả các mục nhập thư mục được _nghiêm ngặt_ ghi lại trong
thứ tự bảng chữ cái để hỗ trợ tìm kiếm nhị phân tiền tố được cải thiện
thuật toán (có thể tham khảo mã nguồn liên quan).

::

___________________________
                 / |
                / ______________|________________
               // Tên tắt ZZ0000ZZN-1
  ____________.______________._______________v________________v__________
 ZZ0001ZZ trực tiếp ZZ0002ZZ trực tiếp ZZ0003ZZ tên tệp ZZ0004ZZ |
 ZZ0005ZZ____1___ZZ0006ZZ___N-1__|____0_____|____1_____|_____|___N-1_____|
      \ ^
       \ |                           * có thể có
        \ |                             theo sau '\0'
         \________________________| tên tắt0
                             Khối thư mục

Lưu ý rằng ngoài phần bù của tên tệp đầu tiên, nameoff0 còn cho biết
tổng số mục thư mục trong khối này vì không cần thiết
giới thiệu một trường khác trên đĩa.

Các tập tin dựa trên chunk
-----------------
Để hỗ trợ sao chép dữ liệu dựa trên chunk, bố cục dữ liệu inode mới có
được hỗ trợ kể từ Linux v5.15: Các tệp được chia thành các khối dữ liệu có kích thước bằng nhau
với vùng ZZ0000ZZ của siêu dữ liệu inode cho biết cách lấy đoạn
dữ liệu: chúng có thể đơn giản là mảng địa chỉ khối 4 byte hoặc ở dạng 8 byte
dạng chỉ mục chunk (xem struct erofs_inode_chunk_index trong erofs_fs.h để biết thêm
chi tiết.)

Nhân tiện, hiện tại tất cả các tệp dựa trên chunk đều chưa được nén.

Tiền tố tên thuộc tính mở rộng dài
-------------------------------------
Có những trường hợp sử dụng trong đó các thuộc tính mở rộng với các giá trị khác nhau có thể có
chỉ một vài tiền tố phổ biến (chẳng hạn như lớp phủ xattrs).  Tiền tố được xác định trước
hoạt động không hiệu quả cả về kích thước hình ảnh và hiệu suất thời gian chạy trong những trường hợp như vậy.

Tính năng tiền tố tên xattr dài được giới thiệu để giải quyết vấn đề này.  các
Ý tưởng tổng thể là, ngoài các tiền tố được xác định trước hiện có, xattr
mục nhập cũng có thể đề cập đến tiền tố tên xattr dài do người dùng chỉ định, ví dụ:
"đáng tin cậy.overlay.".

Khi đề cập đến tiền tố tên xattr dài, bit cao nhất (bit 7) của
erofs_xattr_entry.e_name_index được đặt, trong khi toàn bộ các bit thấp hơn (bit 0-6)
đại diện cho chỉ mục của tiền tố tên dài được giới thiệu trong số tất cả các tên dài
tiền tố.  Vì vậy, chỉ có phần cuối của tên ngoài phần dài
Tiền tố tên xattr được lưu trữ trong erofs_xattr_entry.e_name, có thể trống nếu
tên xattr đầy đủ khớp chính xác với tiền tố tên xattr dài của nó.

Tất cả các tiền tố xattr dài được lưu trữ từng cái một trong inode đóng gói miễn là
nút đóng gói là hợp lệ hoặc trong nút meta nếu không.  các
xattr_prefix_count (của siêu khối trên đĩa) cho biết tổng số
tiền tố tên xattr dài, trong khi (xattr_prefix_start * 4) biểu thị sự bắt đầu
phần bù của các tiền tố tên dài trong inode đóng gói/meta.  Lưu ý rằng, kéo dài lâu
tiền tố tên thuộc tính bị vô hiệu hóa nếu xattr_prefix_count bằng 0.

Mỗi tiền tố tên dài được lưu trữ ở định dạng: ALIGN({__le16 len, data}, 4),
trong đó len đại diện cho tổng kích thước của phần dữ liệu.  Phần dữ liệu thực chất là
được biểu thị bằng 'struct erofs_xattr_long_prefix', trong đó base_index đại diện cho
chỉ mục của tiền tố tên xattr được xác định trước, ví dụ: EROFS_XATTR_INDEX_TRUSTED cho
"đáng tin cậy.overlay." tiền tố tên dài, trong khi chuỗi trung tố giữ nguyên chuỗi
sau khi loại bỏ tiền tố ngắn, ví dụ: "lớp phủ." cho ví dụ trên.

nén dữ liệu
----------------
EROFS thực hiện nén đầu ra có kích thước cố định để tạo ra các kích thước cố định
khối dữ liệu nén từ đầu vào có kích thước thay đổi trái ngược với các khối dữ liệu hiện có khác
giải pháp đầu vào có kích thước cố định. Tỷ lệ nén tương đối cao hơn có thể đạt được
bằng cách sử dụng nén đầu ra có kích thước cố định vì nén dữ liệu phổ biến hiện nay
các thuật toán chủ yếu dựa trên LZ77 và cách tiếp cận đầu ra có kích thước cố định như vậy có thể
được hưởng lợi từ từ điển lịch sử (hay còn gọi là cửa sổ trượt).

Cụ thể, dữ liệu gốc (không nén) được chuyển thành nhiều dữ liệu có kích thước thay đổi
phạm vi và trong khi đó, được nén thành các cụm vật lý (pclusters).
Để ghi lại từng phạm vi có kích thước thay đổi, các cụm logic (các cụm) được
được giới thiệu như đơn vị cơ bản của chỉ số nén để cho biết liệu một chỉ số nén mới
phạm vi được tạo ra trong phạm vi (HEAD) hay không (NONHEAD). Lclusters bây giờ là
cố định ở kích thước khối, như minh họa bên dưới::

ZZ0000ZZ<- VLE ->|
        cụm của cụm của cụm của
          ZZ0001ZZ |
 _________v__________________________________v______________________v________
 ... |    .         |              |        .     |              |  .   ...
____ZZ0000ZZ______________ZZ0001ZZ______________|__.________
     ZZ0002ZZ-> cụm <-ZZ0003ZZ-> cụm <-|
          (HEAD) (NONHEAD) (HEAD) (NONHEAD) .
           .             CBLKCNT.                    .
            .                               .                  .
             .                              .                .
       _______._____________________________.______________._________________
          ... |              |              |              | ...
_______ZZ0000ZZ______________ZZ0001ZZ_________________
              ZZ0002ZZ-> cụm máy tính <-|

Một cụm vật lý có thể được coi là nơi chứa các khối nén vật lý
chứa dữ liệu nén. Trước đây, chỉ các cụm có kích thước lcluster (4KB)
đã được hỗ trợ. Sau khi tính năng big pccluster được giới thiệu (có sẵn kể từ
Linux v5.13), pccluster có thể là bội số của kích thước lcluster.

Đối với mỗi cụm HEAD, các cụm được ghi lại để chỉ ra nơi có phạm vi mới
bắt đầu và blkaddr được sử dụng để tìm kiếm dữ liệu nén. Đối với mỗi NONHEAD
lcluster, delta0 và delta1 có sẵn thay vì blkaddr để biểu thị
khoảng cách đến cụm HEAD của nó và cụm HEAD tiếp theo. Một cụm PLAIN là
cũng là một cụm HEAD ngoại trừ dữ liệu của nó không bị nén. Xem các bình luận
xung quanh "struct z_erofs_vle_decompression_index" trong erofs_fs.h để biết thêm chi tiết.

Nếu bật cụm máy tính lớn, kích thước cụm máy tính trong các cụm cần phải được ghi lại là
tốt. Để delta0 của cụm NONHEAD đầu tiên lưu trữ khối nén
được tính bằng một lá cờ đặc biệt dưới dạng lcluster mới có tên CBLKCNT NONHEAD. thật dễ dàng
để hiểu delta0 của nó luôn bằng 1, như minh họa bên dưới ::

__________________________________________________________
  ZZ0000ZZ NONHEAD ZZ0001ZZ ... ZZ0002ZZ HEAD ZZ0003ZZ
  ZZ0004ZZ_(CBLKCNT)_ZZ0005ZZ_____ZZ0006ZZ__:___ZZ0007ZZ
     ZZ0008ZZ<-- -->|
           một cụm máy tính có kích thước lcluster (không có CBLKCNT) ^

Nếu một HEAD khác theo sau một cụm HEAD thì sẽ không còn chỗ để ghi CBLKCNT,
nhưng thật dễ dàng để biết kích thước của pcluster như vậy cũng là 1 lcluster.

Kể từ Linux v6.1, mỗi pccluster có thể được sử dụng cho nhiều phạm vi có kích thước thay đổi,
do đó nó có thể được sử dụng để chống trùng lặp dữ liệu nén.