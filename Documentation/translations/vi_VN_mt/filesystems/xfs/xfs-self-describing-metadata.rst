.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/xfs/xfs-self-describing-metadata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _xfs_self_describing_metadata:

===============================
Siêu dữ liệu tự mô tả XFS
============================

Giới thiệu
============

Vấn đề về khả năng mở rộng lớn nhất mà XFS phải đối mặt không phải là vấn đề về thuật toán
khả năng mở rộng, nhưng xác minh cấu trúc hệ thống tập tin. Khả năng mở rộng của
cấu trúc và chỉ mục trên đĩa cũng như các thuật toán để lặp lại chúng
đủ để hỗ trợ các hệ thống tệp quy mô PB với hàng tỷ nút, tuy nhiên nó
chính khả năng mở rộng này có gây ra vấn đề xác minh hay không.

Hầu như tất cả siêu dữ liệu trên XFS đều được phân bổ động. Vị trí cố định duy nhất
siêu dữ liệu là các tiêu đề nhóm phân bổ (SB, AGF, AGFL và AGI), trong khi tất cả
các cấu trúc siêu dữ liệu khác cần được phát hiện bằng cách duyệt qua hệ thống tệp
cấu trúc theo những cách khác nhau. Mặc dù điều này đã được thực hiện bởi các công cụ không gian người dùng dành cho
xác nhận và sửa chữa cấu trúc, có những giới hạn đối với những gì họ có thể
xác minh và điều này đến lượt nó sẽ giới hạn kích thước có thể hỗ trợ của hệ thống tệp XFS.

Ví dụ: hoàn toàn có thể sử dụng xfs_db theo cách thủ công và một chút
tập lệnh để phân tích cấu trúc của hệ thống tệp 100TB khi cố gắng
xác định nguyên nhân gốc rễ của vấn đề tham nhũng, nhưng nó vẫn chủ yếu là
nhiệm vụ thủ công là xác minh những thứ như lỗi bit đơn hoặc ghi sai vị trí
không phải là nguyên nhân cuối cùng của một sự kiện tham nhũng. Có thể mất vài giờ để
vài ngày để thực hiện phân tích pháp lý như vậy, vì vậy ở quy mô này, nguyên nhân gốc rễ
việc phân tích là hoàn toàn có thể.

Tuy nhiên, nếu chúng tôi mở rộng hệ thống tệp lên tới 1PB, thì hiện tại chúng tôi có số lượng siêu dữ liệu gấp 10 lần
để phân tích và do đó việc phân tích sẽ diễn ra trong nhiều tuần/tháng của công việc điều tra.
Hầu hết công việc phân tích đều chậm chạp và tẻ nhạt, vì vậy khối lượng phân tích càng tăng lên.
lên thì càng có nhiều khả năng nguyên nhân sẽ bị mất trong tiếng ồn.  Do đó chính
Mối quan tâm về việc hỗ trợ các hệ thống tệp quy mô PB là giảm thiểu thời gian và công sức
cần thiết cho phân tích điều tra cơ bản về cấu trúc hệ thống tập tin.


Siêu dữ liệu tự mô tả
========================

Một trong những vấn đề với định dạng siêu dữ liệu hiện tại là ngoài
số ma thuật trong khối siêu dữ liệu, chúng tôi không có cách nào khác để xác định nó là gì
được cho là như vậy. Chúng tôi thậm chí không thể xác định được liệu đó có phải là nơi thích hợp hay không. Nói một cách đơn giản,
bạn không thể xem xét một khối siêu dữ liệu một cách riêng biệt và nói "vâng, đúng vậy
được cho là ở đó và nội dung hợp lệ".

Do đó, phần lớn thời gian dành cho việc phân tích pháp y được dành cho việc thực hiện các công việc cơ bản.
xác minh các giá trị siêu dữ liệu, tìm kiếm các giá trị nằm trong phạm vi (và do đó
không được phát hiện bởi quá trình kiểm tra xác minh tự động) nhưng không chính xác. Tìm và
hiểu cách những thứ như danh sách chặn được liên kết chéo (ví dụ: anh chị em
con trỏ trong btree kết thúc bằng các vòng lặp trong đó) là chìa khóa để hiểu những gì
đã sai, nhưng không thể biết các khối được liên kết theo thứ tự nào
nhau hoặc được ghi vào đĩa sau khi thực tế.

Do đó, chúng tôi cần ghi thêm thông tin vào siêu dữ liệu để cho phép chúng tôi
nhanh chóng xác định xem siêu dữ liệu có còn nguyên vẹn hay không và có thể bị bỏ qua vì mục đích này
của phân tích. Chúng tôi không thể bảo vệ khỏi mọi loại lỗi có thể xảy ra, nhưng chúng tôi có thể
đảm bảo rằng các loại lỗi phổ biến có thể dễ dàng được phát hiện.  Do đó khái niệm về
tự mô tả siêu dữ liệu.

Yêu cầu cơ bản đầu tiên của siêu dữ liệu tự mô tả là
đối tượng siêu dữ liệu chứa một số dạng định danh duy nhất trong một đối tượng nổi tiếng
vị trí. Điều này cho phép chúng tôi xác định nội dung mong đợi của khối và
do đó phân tích và xác minh đối tượng siêu dữ liệu. NẾU chúng ta không thể xác định một cách độc lập
loại siêu dữ liệu trong đối tượng thì siêu dữ liệu đó không mô tả chính nó
rất tốt cả!

May mắn thay, hầu hết tất cả siêu dữ liệu XFS đều đã được nhúng các số ma thuật - chỉ có
AGFL, các liên kết tượng trưng từ xa và các khối thuộc tính từ xa không chứa thông tin nhận dạng
những con số ma thuật. Do đó chúng ta có thể thay đổi định dạng trên đĩa của tất cả các đối tượng này thành
thêm nhiều thông tin nhận dạng hơn và phát hiện điều này chỉ bằng cách thay đổi phép thuật
số trong các đối tượng siêu dữ liệu. Nghĩa là, nếu nó có số ma thuật hiện tại,
siêu dữ liệu không tự nhận dạng. Nếu nó chứa một con số ma thuật mới, thì đó là
tự nhận dạng và chúng tôi có thể thực hiện xác minh tự động mở rộng hơn nhiều về
đối tượng siêu dữ liệu trong thời gian chạy, trong quá trình phân tích hoặc sửa chữa pháp lý.

Là mối quan tâm hàng đầu, siêu dữ liệu tự mô tả cần một số dạng tổng thể
kiểm tra tính toàn vẹn. Chúng tôi không thể tin cậy siêu dữ liệu nếu chúng tôi không thể xác minh rằng nó có
không bị thay đổi do tác động bên ngoài. Do đó chúng ta cần một số dạng
kiểm tra tính toàn vẹn và điều này được thực hiện bằng cách thêm xác thực CRC32c vào siêu dữ liệu
khối. Nếu chúng tôi có thể xác minh khối chứa siêu dữ liệu mà nó dự định
contain, a large amount of the manual verification work can be skipped.

CRC32c đã được chọn vì siêu dữ liệu không thể dài hơn 64k trong XFS và
do đó CRC 32 bit là quá đủ để phát hiện các lỗi nhiều bit trong
khối siêu dữ liệu. CRC32c hiện cũng được tăng tốc phần cứng trên các CPU thông thường nên nó được
nhanh chóng. Vì vậy, mặc dù CRC32c không phải là biện pháp kiểm tra tính toàn vẹn mạnh mẽ nhất có thể nhưng
có thể được sử dụng, nó là quá đủ cho nhu cầu của chúng tôi và có tương đối
ít chi phí. Thêm hỗ trợ cho các trường và/hoặc thuật toán toàn vẹn lớn hơn
thực sự cung cấp bất kỳ giá trị bổ sung nào so với CRC32c, nhưng nó bổ sung thêm rất nhiều
phức tạp và do đó không có điều khoản nào để thay đổi việc kiểm tra tính toàn vẹn
cơ chế.

Siêu dữ liệu tự mô tả cần chứa đủ thông tin để
khối siêu dữ liệu có thể được xác minh là ở đúng vị trí mà không cần phải
xem xét bất kỳ siêu dữ liệu nào khác. Điều này có nghĩa là nó cần chứa thông tin vị trí.
Chỉ thêm số khối vào siêu dữ liệu là không đủ để bảo vệ chống lại
ghi sai hướng - một lần viết có thể bị chuyển hướng sai tới LUN sai và do đó
được ghi vào "khối chính xác" của hệ thống tập tin sai. Do đó vị trí
thông tin phải chứa mã định danh hệ thống tập tin cũng như số khối.

Một điểm thông tin quan trọng khác trong phân tích điều tra là biết siêu dữ liệu của ai
khối thuộc về. Chúng tôi đã biết loại, vị trí và nó hợp lệ
và/hoặc bị hỏng và lần cuối nó được sửa đổi là bao lâu. Biết chủ nhân
của khối rất quan trọng vì nó cho phép chúng tôi tìm siêu dữ liệu liên quan khác để
xác định phạm vi tham nhũng. Ví dụ: nếu chúng ta có phạm vi btree
đối tượng, chúng tôi không biết nó thuộc về inode nào và do đó phải duyệt toàn bộ
hệ thống tập tin để tìm chủ sở hữu của khối. Tệ hơn nữa, tham nhũng có thể có nghĩa là
không thể tìm thấy chủ sở hữu (tức là khối mồ côi) và do đó không có trường chủ sở hữu
trong siêu dữ liệu, chúng tôi không biết phạm vi của tham nhũng. Nếu chúng ta có một
trường chủ sở hữu trong đối tượng siêu dữ liệu, chúng tôi có thể ngay lập tức thực hiện xác thực từ trên xuống để
xác định phạm vi của vấn đề.

Các loại siêu dữ liệu khác nhau có số nhận dạng chủ sở hữu khác nhau. Ví dụ,
Các khối cây thư mục, thuộc tính và phạm vi đều thuộc sở hữu của một inode, trong khi
Các khối btree freespace được sở hữu bởi một nhóm phân bổ. Do đó kích thước và
nội dung của trường chủ sở hữu được xác định bởi loại đối tượng siêu dữ liệu mà chúng tôi đang có
đang nhìn vào.  Thông tin chủ sở hữu cũng có thể xác định việc ghi sai vị trí (ví dụ:
khối btree freespace được ghi vào AG sai).

Siêu dữ liệu tự mô tả cũng cần chứa một số dấu hiệu về thời điểm nó được
được ghi vào hệ thống tập tin. Một trong những điểm thông tin quan trọng khi làm pháp y
phân tích là khối đã được sửa đổi gần đây như thế nào. Tương quan của tập hợp bị hỏng
khối siêu dữ liệu dựa trên thời gian sửa đổi là quan trọng vì nó có thể chỉ ra
liệu các vụ tham nhũng có liên quan hay không, liệu có nhiều vụ tham nhũng không
các sự kiện dẫn đến sự thất bại cuối cùng và thậm chí liệu có tham nhũng hay không
cho thấy việc xác minh thời gian chạy không được phát hiện.

Ví dụ: chúng ta có thể xác định xem một đối tượng siêu dữ liệu có được coi là miễn phí hay không
không gian hoặc vẫn được phân bổ nếu nó vẫn được chủ sở hữu của nó tham chiếu bằng cách xem xét
khi khối btree không gian trống chứa khối đó được ghi lần cuối
so với thời điểm đối tượng siêu dữ liệu được viết lần cuối.  Nếu không gian trống
khối gần đây hơn đối tượng và chủ sở hữu của đối tượng thì có một
rất có thể khối đó đã bị xóa khỏi chủ sở hữu.

Để cung cấp "dấu thời gian bằng văn bản" này, mỗi khối siêu dữ liệu sẽ có Chuỗi nhật ký
Số (LSN) của giao dịch gần đây nhất đã được sửa đổi khi ghi vào đó.
Con số này sẽ luôn tăng theo thời gian tồn tại của hệ thống tập tin và con số duy nhất
thứ đặt lại nó đang chạy xfs_repair trên hệ thống tập tin. Hơn nữa, bằng cách sử dụng
LSN chúng ta có thể biết liệu tất cả siêu dữ liệu bị hỏng có thuộc cùng một nhật ký hay không
điểm kiểm tra và do đó có một số ý tưởng về mức độ sửa đổi xảy ra giữa
trường hợp đầu tiên và cuối cùng của siêu dữ liệu bị hỏng trên đĩa và hơn nữa, bao nhiêu
sửa đổi xảy ra giữa lỗi được viết và khi nó được
được phát hiện.

Xác thực thời gian chạy
==================

Việc xác thực siêu dữ liệu tự mô tả diễn ra trong thời gian chạy ở hai nơi:

- ngay sau khi đọc thành công từ đĩa
	- ngay trước khi viết IO đệ trình

Việc xác minh hoàn toàn không có trạng thái - nó được thực hiện độc lập với
quá trình sửa đổi và chỉ tìm cách kiểm tra xem siêu dữ liệu có đúng như những gì nó nói không
đúng như vậy và các trường siêu dữ liệu nằm trong giới hạn và nhất quán nội bộ.
Như vậy, chúng ta không thể nắm bắt được tất cả các loại tham nhũng có thể xảy ra trong một khối
vì có thể có những hạn chế nhất định mà trạng thái vận hành áp đặt đối với
siêu dữ liệu hoặc có thể có sai sót trong các mối quan hệ liên khối (ví dụ: bị hỏng
danh sách con trỏ anh chị em). Do đó chúng ta vẫn cần kiểm tra trạng thái trong mã chính
nội dung, nhưng nói chung hầu hết việc xác thực theo từng trường được xử lý bởi
người xác minh.

Để xác minh đã đọc, người gọi cần chỉ định loại siêu dữ liệu dự kiến
mà nó sẽ thấy và quá trình hoàn thành IO xác minh rằng siêu dữ liệu
đối tượng phù hợp với những gì được mong đợi. Nếu quá trình xác minh thất bại thì nó
đánh dấu đối tượng đang được đọc là EFSCORRUPTED. Người gọi cần nắm bắt điều này
lỗi (tương tự như lỗi IO) và liệu nó có cần thực hiện hành động đặc biệt do lỗi không
lỗi xác minh, nó có thể làm như vậy bằng cách bắt giá trị lỗi EFSCORRUPTED. Nếu chúng ta
cần phân biệt nhiều hơn về loại lỗi ở cấp độ cao hơn, chúng ta có thể xác định mới
số lỗi cho các lỗi khác nhau khi cần thiết.

Bước đầu tiên trong việc xác minh việc đọc là kiểm tra số ma thuật và xác định
liệu việc xác thực CRC có cần thiết hay không. Nếu đúng như vậy, CRC32c sẽ được tính toán và
so sánh với giá trị được lưu trữ trong chính đối tượng đó. Một khi điều này được xác nhận,
kiểm tra thêm được thực hiện đối với thông tin vị trí, tiếp theo là mở rộng
xác thực siêu dữ liệu cụ thể của đối tượng. Nếu bất kỳ kiểm tra nào trong số này không thành công thì
bộ đệm được coi là bị hỏng và lỗi EFSCORRUPTED được đặt phù hợp.

Xác minh ghi ngược lại với xác minh đọc - đầu tiên là đối tượng
đã được xác minh rộng rãi và nếu ổn thì chúng tôi sẽ cập nhật LSN từ phiên bản trước
sửa đổi được thực hiện cho đối tượng, Sau đó, chúng tôi tính toán CRC và chèn nó
vào đối tượng. Sau khi hoàn thành việc ghi IO được phép tiếp tục. Nếu có
xảy ra lỗi trong quá trình này, bộ đệm lại được đánh dấu bằng EFSCORRUPTED
lỗi để các lớp cao hơn bắt.

Cấu trúc
==========

Cấu trúc trên đĩa điển hình cần chứa thông tin sau ::

cấu trúc xfs_ondisk_hdr {
	    __be32 phép thuật;		/*con số kỳ diệu*/
	    __be32 crc;		/* CRC, chưa được ghi lại */
	    uuid_t uuid;		/*định danh hệ thống tập tin */
	    __be64 chủ sở hữu;		/*đối tượng cha */
	    __be64 blkno;		/*vị trí trên đĩa*/
	    __be64 lsn;		/* sửa đổi lần cuối trong nhật ký, chưa được ghi */
    };

Tùy thuộc vào siêu dữ liệu, thông tin này có thể là một phần của cấu trúc tiêu đề
tách biệt với nội dung siêu dữ liệu hoặc có thể được phân phối thông qua một hệ thống hiện có
cấu trúc. Điều thứ hai xảy ra với siêu dữ liệu đã chứa một số thông tin này
thông tin, chẳng hạn như siêu khối và tiêu đề AG.

Siêu dữ liệu khác có thể có các định dạng khác nhau cho thông tin, nhưng giống nhau
mức độ thông tin nói chung được cung cấp. Ví dụ:

- khối btree ngắn có chủ sở hữu 32 bit (số ag) và khối 32 bit
	  số cho vị trí. Hai trong số này kết hợp cung cấp cùng một
	  thông tin như @owner và @blkno trong cấu trúc eh ở trên, nhưng sử dụng 8
	  ít byte hơn trên đĩa.

- các khối nút thư mục/thuộc tính có số ma thuật 16 bit và
	  tiêu đề chứa số ma thuật có thông tin khác trong đó như
	  tốt. do đó các tiêu đề siêu dữ liệu bổ sung thay đổi định dạng tổng thể
	  của siêu dữ liệu.

Trình xác minh đọc bộ đệm điển hình có cấu trúc như sau::

#define XFS_FOO_CRC_OFF offsetof(struct xfs_ondisk_hdr, crc)

khoảng trống tĩnh
    xfs_foo_read_verify(
	    cấu trúc xfs_buf *bp)
    {
	struct xfs_mount *mp = bp->b_mount;

if ((xfs_sb_version_hascrc(&mp->m_sb) &&
		!xfs_verify_cksum(bp->b_addr, BBTOB(bp->b_length),
					    XFS_FOO_CRC_OFF)) ||
		!xfs_foo_verify(bp)) {
		    XFS_CORRUPTION_ERROR(__func__, XFS_ERRLEVEL_LOW, mp, bp->b_addr);
		    xfs_buf_ioerror(bp, EFSCORRUPTED);
	    }
    }

Mã đảm bảo rằng CRC chỉ được kiểm tra nếu hệ thống tệp đã bật CRC
bằng cách kiểm tra siêu khối của bit tính năng và sau đó nếu CRC xác minh OK
(hoặc không cần thiết) nó xác minh nội dung thực tế của khối.

Chức năng xác minh sẽ có một vài dạng khác nhau, tùy thuộc vào
liệu số ma thuật có thể được sử dụng để xác định định dạng của khối hay không. trong
trong trường hợp không thể, mã có cấu trúc như sau ::

bool tĩnh
    xfs_foo_verify(
	    cấu trúc xfs_buf *bp)
    {
	    struct xfs_mount *mp = bp->b_mount;
	    struct xfs_ondisk_hdr *hdr = bp->b_addr;

if (hdr->magic != cpu_to_be32(XFS_FOO_MAGIC))
		    trả về sai;

if (!xfs_sb_version_hascrc(&mp->m_sb)) {
		    if (!uuid_equal(&hdr->uuid, &mp->m_sb.sb_uuid))
			    trả về sai;
		    if (bp->b_bn != be64_to_cpu(hdr->blkno))
			    trả về sai;
		    nếu (hdr-> chủ sở hữu == 0)
			    trả về sai;
	    }

/* Kiểm tra xác minh cụ thể đối tượng tại đây */

trả về đúng sự thật;
    }

Nếu có các số ma thuật khác nhau cho các định dạng khác nhau, trình xác minh
sẽ trông giống như::

bool tĩnh
    xfs_foo_verify(
	    cấu trúc xfs_buf *bp)
    {
	    struct xfs_mount *mp = bp->b_mount;
	    struct xfs_ondisk_hdr *hdr = bp->b_addr;

if (hdr->magic == cpu_to_be32(XFS_FOO_CRC_MAGIC)) {
		    if (!uuid_equal(&hdr->uuid, &mp->m_sb.sb_uuid))
			    trả về sai;
		    if (bp->b_bn != be64_to_cpu(hdr->blkno))
			    trả về sai;
		    nếu (hdr-> chủ sở hữu == 0)
			    trả về sai;
	    } khác nếu (hdr->magic != cpu_to_be32(XFS_FOO_MAGIC))
		    trả về sai;

/* Kiểm tra xác minh cụ thể đối tượng tại đây */

trả về đúng sự thật;
    }

Trình xác minh ghi rất giống với trình xác minh đọc, chúng chỉ thực hiện mọi việc theo
thứ tự ngược lại với trình xác minh đã đọc. Trình xác minh ghi điển hình::

khoảng trống tĩnh
    xfs_foo_write_verify(
	    cấu trúc xfs_buf *bp)
    {
	    struct xfs_mount *mp = bp->b_mount;
	    struct xfs_buf_log_item *bip = bp->b_fspriv;

if (!xfs_foo_verify(bp)) {
		    XFS_CORRUPTION_ERROR(__func__, XFS_ERRLEVEL_LOW, mp, bp->b_addr);
		    xfs_buf_ioerror(bp, EFSCORRUPTED);
		    trở lại;
	    }

if (!xfs_sb_version_hascrc(&mp->m_sb))
		    trở lại;


nếu (bip) {
		    struct xfs_ondisk_hdr *hdr = bp->b_addr;
		    hdr->lsn = cpu_to_be64(bip->bli_item.li_lsn);
	    }
	    xfs_update_cksum(bp->b_addr, BBTOB(bp->b_length), XFS_FOO_CRC_OFF);
    }

Điều này sẽ xác minh cấu trúc bên trong của siêu dữ liệu trước khi chúng tôi thực hiện bất kỳ thao tác nào.
hơn nữa, việc phát hiện các sai sót đã xảy ra khi siêu dữ liệu đã được
được sửa đổi trong bộ nhớ. Nếu siêu dữ liệu xác minh là OK và CRC được bật thì chúng tôi sẽ
cập nhật trường LSN (khi nó được sửa đổi lần cuối) và tính toán CRC trên
siêu dữ liệu. Khi việc này hoàn tất, chúng ta có thể phát hành IO.

Inodes và Dquots
=================

Inodes và dquots là những bông tuyết đặc biệt. Họ có mỗi đối tượng CRC và
tự nhận dạng, nhưng chúng được đóng gói sao cho có nhiều đối tượng trên mỗi
bộ đệm. Do đó, chúng tôi không sử dụng trình xác minh trên mỗi bộ đệm để thực hiện công việc của từng đối tượng
xác minh và tính toán CRC. Trình xác minh trên mỗi bộ đệm chỉ thực hiện cơ bản
nhận dạng bộ đệm - chúng chứa inode hoặc dquot, và rằng
có những con số kỳ diệu ở tất cả các vị trí mong đợi. Tất cả hơn nữa CRC và
Việc kiểm tra xác minh được thực hiện khi mỗi inode được đọc từ hoặc ghi lại vào
bộ đệm.

Cấu trúc của các trình xác minh và kiểm tra định danh rất giống với cấu trúc
mã đệm được mô tả ở trên. Sự khác biệt duy nhất là nơi họ được gọi. cho
ví dụ, việc xác minh đọc inode được thực hiện trong xfs_inode_from_disk() khi inode
lần đầu tiên được đọc ra khỏi bộ đệm và struct xfs_inode được khởi tạo. các
inode đã được xác minh rộng rãi trong quá trình ghi lại trong xfs_iflush_int, vì vậy
bổ sung duy nhất ở đây là thêm LSN và CRC vào inode khi nó được sao chép lại
vào bộ đệm.

XXX: sửa đổi danh sách hủy liên kết inode không tính toán lại inode CRC! Không ai trong số
việc sửa đổi danh sách không liên kết sẽ kiểm tra hoặc cập nhật CRC, không phải trong quá trình hủy liên kết cũng như
phục hồi nhật ký. Vì vậy, nó đã không được chú ý cho đến tận bây giờ. Điều này sẽ không thành vấn đề ngay lập tức -
việc sửa chữa có thể sẽ phàn nàn về điều đó - nhưng nó cần phải được sửa chữa.