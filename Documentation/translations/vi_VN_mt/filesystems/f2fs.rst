.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/f2fs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Hệ thống tệp thân thiện với Flash (F2FS)
=================================

Tổng quan
========

Các thiết bị lưu trữ dựa trên bộ nhớ flash NAND, chẳng hạn như SSD, eMMC và thẻ SD, có
được trang bị trên nhiều hệ thống khác nhau, từ hệ thống di động đến hệ thống máy chủ. Kể từ khi
chúng được biết là có những đặc điểm khác với chuyển động quay thông thường
đĩa, hệ thống tập tin, lớp trên của thiết bị lưu trữ, phải thích ứng với
thay đổi so với bản phác thảo ở cấp độ thiết kế.

F2FS là một hệ thống tệp khai thác các thiết bị lưu trữ dựa trên bộ nhớ flash NAND,
dựa trên Hệ thống tệp có cấu trúc nhật ký (LFS). Thiết kế đã được tập trung vào
giải quyết các vấn đề cơ bản trong LFS, đó là hiệu ứng quả cầu tuyết khi đi lang thang
cây và chi phí làm sạch cao.

Do thiết bị lưu trữ dựa trên bộ nhớ flash NAND hiển thị các đặc tính khác nhau
theo sơ đồ quản lý bộ nhớ flash hoặc hình học bên trong của nó, cụ thể là FTL,
F2FS và các công cụ của nó hỗ trợ nhiều tham số khác nhau không chỉ để định cấu hình trên đĩa
bố cục mà còn để lựa chọn các thuật toán phân bổ và làm sạch.

Cây git sau đây cung cấp công cụ định dạng hệ thống tệp (mkfs.f2fs),
công cụ kiểm tra tính nhất quán (fsck.f2fs) và công cụ gỡ lỗi (dump.f2fs).

- git://git.kernel.org/pub/scm/linux/kernel/git/jaegeuk/f2fs-tools.git

Để gửi bản vá, vui lòng sử dụng danh sách gửi thư sau:

- linux-f2fs-devel@lists.sourceforge.net

Để báo cáo lỗi, vui lòng sử dụng liên kết theo dõi lỗi f2fs sau:

-ZZ0000ZZ

Các vấn đề về bối cảnh và thiết kế
============================

Hệ thống tệp có cấu trúc nhật ký (LFS)
--------------------------------
"Một hệ thống tập tin có cấu trúc nhật ký ghi tất cả các sửa đổi vào đĩa một cách tuần tự theo
một cấu trúc giống như nhật ký, do đó tăng tốc cả việc ghi tệp và khôi phục sự cố.
Nhật ký là cấu trúc duy nhất trên đĩa; nó chứa thông tin lập chỉ mục để
các tập tin có thể được đọc lại từ nhật ký một cách hiệu quả. Để duy trì lượng lớn miễn phí
vùng trên đĩa để ghi nhanh, chúng tôi chia nhật ký thành các đoạn và sử dụng
trình dọn dẹp phân đoạn để nén thông tin trực tiếp từ các phần bị phân mảnh nhiều
phân đoạn." từ Rosenblum, M. và Ousterhout, J. K., 1992, "Việc thiết kế và
triển khai hệ thống tệp có cấu trúc nhật ký", ACM Trans. Hệ thống máy tính
10, 1, 26–52.

Vấn đề cây lang thang
----------------------
Trong LFS, khi dữ liệu tệp được cập nhật và ghi vào cuối nhật ký, nó sẽ trực tiếp
khối con trỏ được cập nhật do vị trí đã thay đổi. Khi đó con trỏ gián tiếp
khối cũng được cập nhật do cập nhật khối con trỏ trực tiếp. Bằng cách này,
Các cấu trúc chỉ mục trên như inode, bản đồ inode và khối điểm kiểm tra là
cũng được cập nhật đệ quy. Bài toán này được gọi là bài toán cây lang thang [1],
và để nâng cao hiệu suất, cần loại bỏ hoặc nới lỏng việc cập nhật
tuyên truyền càng nhiều càng tốt.

[1] Bitutskiy, A. 2005. Các vấn đề về thiết kế của JFFS3. ZZ0000ZZ

Dọn dẹp trên cao
-----------------
Vì LFS dựa trên việc ghi sai vị trí nên nó tạo ra rất nhiều khối lỗi thời
nằm rải rác trên toàn bộ kho lưu trữ. Để phục vụ không gian nhật ký trống mới, nó
cần lấy lại các khối lỗi thời này một cách liền mạch cho người dùng. Công việc này được gọi là
như một quá trình làm sạch.

Quá trình này bao gồm ba hoạt động như sau.

1. Phân đoạn nạn nhân được chọn thông qua bảng sử dụng phân đoạn tham chiếu.
2. Nó tải cấu trúc chỉ mục gốc của tất cả dữ liệu trong nạn nhân được xác định bởi
   khối tóm tắt phân đoạn.
3. Nó kiểm tra tham chiếu chéo giữa dữ liệu và cấu trúc chỉ mục gốc của nó.
4. Nó di chuyển dữ liệu hợp lệ một cách có chọn lọc.

Công việc dọn dẹp này có thể gây ra sự chậm trễ kéo dài ngoài dự kiến, vì vậy mục tiêu quan trọng nhất
là để ẩn độ trễ cho người dùng. Và cũng chắc chắn, nó sẽ làm giảm
lượng dữ liệu hợp lệ cần được di chuyển và di chuyển chúng một cách nhanh chóng.

Các tính năng chính
============

Nhận thức chớp nhoáng
---------------
- Mở rộng vùng ghi ngẫu nhiên để có hiệu suất tốt hơn nhưng vẫn mang lại hiệu suất cao
  địa phương không gian
- Căn chỉnh cấu trúc dữ liệu FS cho các đơn vị vận hành trong FTL bằng nỗ lực tốt nhất

Vấn đề cây lang thang
----------------------
- Sử dụng thuật ngữ “nút”, biểu thị các nút cũng như các khối con trỏ khác nhau
- Giới thiệu Bảng địa chỉ nút (NAT) chứa vị trí của tất cả các “nút”
  khối; điều này sẽ cắt đứt sự lan truyền cập nhật.

Dọn dẹp trên cao
-----------------
- Hỗ trợ quá trình làm sạch nền
- Hỗ trợ các thuật toán tham lam và lợi ích chi phí cho các chính sách lựa chọn nạn nhân
- Hỗ trợ nhật ký nhiều đầu để phân tách dữ liệu nóng và lạnh tĩnh/động
- Giới thiệu tính năng ghi nhật ký thích ứng để phân bổ khối hiệu quả

Tùy chọn gắn kết
=============


===========================================================================================
Background_gc=%s Bật/tắt các thao tác dọn dẹp, cụ thể là rác
			 bộ sưu tập, được kích hoạt ở chế độ nền khi hệ thống con I/O được
			 nhàn rỗi. Nếu Background_gc=on thì nó sẽ bật rác
			 bộ sưu tập và nếu nền_gc=off, bộ sưu tập rác
			 sẽ bị tắt. Nếu nền_gc=sync, nó sẽ chuyển sang
			 về bộ sưu tập rác đồng bộ đang chạy ở chế độ nền.
			 Giá trị mặc định cho tùy chọn này là bật. rác quá
			 bộ sưu tập được bật theo mặc định.
gc_merge Khi nền_gc được bật, tùy chọn này có thể được bật để
			 để luồng GC nền xử lý các yêu cầu GC nền trước,
			 nó có thể loại bỏ vấn đề chậm chạp do tiền cảnh chậm
			 Hoạt động GC khi GC được kích hoạt từ một quá trình có giới hạn
			 Tài nguyên I/O và CPU.
nogc_merge Tắt tính năng hợp nhất GC.
vô hiệu hóa_roll_forward Vô hiệu hóa thói quen khôi phục cuộn về phía trước
norecovery Vô hiệu hóa quy trình khôi phục cuộn tiến, được gắn đọc-
			 chỉ (tức là -o ro,disable_roll_forward)
loại bỏ/nodiscard Kích hoạt/vô hiệu hóa loại bỏ thời gian thực trong f2fs, nếu loại bỏ là
			 được bật, f2fs sẽ đưa ra lệnh loại bỏ/TRIM khi
			 đoạn được làm sạch.
heap/no_heap Không được dùng nữa.
nouser_xattr Tắt thuộc tính người dùng mở rộng. Lưu ý: xattr đã được bật
			 theo mặc định nếu CONFIG_F2FS_FS_XATTR được chọn.
noacl Tắt danh sách kiểm soát truy cập POSIX. Lưu ý: acl đã được bật
			 theo mặc định nếu CONFIG_F2FS_FS_POSIX_ACL được chọn.
active_logs=%u Hỗ trợ cấu hình số lượng nhật ký hoạt động. trong
			 thiết kế hiện tại, f2fs chỉ hỗ trợ 2, 4 và 6 nhật ký.
			 Số mặc định là 6.
vô hiệu hóa_ext_identify Vô hiệu hóa danh sách tiện ích mở rộng được định cấu hình bởi mkfs, vì vậy f2fs
			 không nhận thức được các tập tin lạnh như tập tin media.
inline_xattr Kích hoạt tính năng xattrs nội tuyến.
noinline_xattr Tắt tính năng xattrs nội tuyến.
inline_xattr_size=%u Hỗ trợ định cấu hình kích thước xattr nội tuyến, tùy thuộc vào
			 tính năng xattr nội tuyến linh hoạt.
inline_data Kích hoạt tính năng dữ liệu nội tuyến: Nhỏ mới được tạo (<~3,4k)
			 tập tin có thể được ghi vào khối inode.
inline_dentry Kích hoạt tính năng thư mục nội tuyến: dữ liệu mới được tạo
			 các mục thư mục có thể được ghi vào khối inode. các
			 không gian của khối inode được sử dụng để lưu trữ nội tuyến
			 nha khoa được giới hạn ở mức ~ 3,4k.
noinline_dentry Tắt tính năng nha khoa nội tuyến.
Flush_merge Hợp nhất các lệnh cache_flush đồng thời càng nhiều càng tốt
			 để loại bỏ các vấn đề lệnh dư thừa. Nếu cơ sở
			 thiết bị xử lý lệnh cache_flush tương đối chậm,
			 khuyên bạn nên kích hoạt tùy chọn này.
nobarrier Tùy chọn này có thể được sử dụng nếu bộ nhớ cơ bản đảm bảo
			 dữ liệu được lưu trong bộ nhớ cache của nó phải được ghi vào vùng mới.
			 Nếu tùy chọn này được đặt, sẽ không có lệnh cache_flush nào được đưa ra
			 nhưng f2fs vẫn đảm bảo thứ tự ghi của tất cả
			 dữ liệu ghi.
rào cản Nếu tùy chọn này được đặt, các lệnh cache_flush được phép
			 ban hành.
fastboot Tùy chọn này được sử dụng khi hệ thống muốn giảm mount
			 thời gian nhiều nhất có thể, mặc dù hiệu suất bình thường
			 có thể hy sinh.
mở rộng_cache Kích hoạt bộ đệm phạm vi dựa trên cây rb, nó có thể lưu vào bộ đệm
			 càng nhiều mức độ ánh xạ giữa logic liền kề
			 địa chỉ và địa chỉ vật lý trên mỗi inode, dẫn đến
			 tăng tỷ lệ nhấn bộ đệm. Đặt theo mặc định.
noextent_cache Tắt bộ nhớ đệm phạm vi dựa trên cây rb một cách rõ ràng, xem
			 tùy chọn gắn kết range_cache ở trên.
noinline_data Tắt tính năng dữ liệu nội tuyến, tính năng dữ liệu nội tuyến là
			 được bật theo mặc định.
data_flush Cho phép xóa dữ liệu trước điểm kiểm tra để
			 duy trì dữ liệu của liên kết thường xuyên và tượng trưng.
Reserve_root=%d Hỗ trợ định cấu hình không gian dành riêng được sử dụng cho
			 phân bổ từ người dùng đặc quyền với uid được chỉ định hoặc
			 gid, đơn vị: 4KB, giới hạn mặc định là 12,5% khối người dùng.
Reserve_node=%d Hỗ trợ định cấu hình các nút dành riêng được sử dụng cho
			 phân bổ từ người dùng đặc quyền với uid được chỉ định hoặc
			 gid, giới hạn mặc định là 12,5% của tất cả các nút.
resuid=%d ID người dùng có thể sử dụng các khối và nút dành riêng.
resgid=%d ID nhóm có thể sử dụng các khối và nút dành riêng.
error_injection=%d Kích hoạt tính năng đưa lỗi vào tất cả các loại được hỗ trợ với
			 tốc độ phun quy định.
error_type=%d Hỗ trợ định cấu hình kiểu tiêm lỗi, nên có
			 được bật với tùy chọn error_injection, giá trị loại lỗi
			 được hiển thị bên dưới, nó hỗ trợ loại đơn hoặc kết hợp.

			 .. code-block:: none

			     ===========================      ==========
			     Type_Name                        Type_Value
			     ===========================      ==========
			     FAULT_KMALLOC                    0x00000001
			     FAULT_KVMALLOC                   0x00000002
			     FAULT_PAGE_ALLOC                 0x00000004
			     FAULT_PAGE_GET                   0x00000008
			     FAULT_ALLOC_BIO                  0x00000010 (obsolete)
			     FAULT_ALLOC_NID                  0x00000020
			     FAULT_ORPHAN                     0x00000040
			     FAULT_BLOCK                      0x00000080
			     FAULT_DIR_DEPTH                  0x00000100
			     FAULT_EVICT_INODE                0x00000200
			     FAULT_TRUNCATE                   0x00000400
			     FAULT_READ_IO                    0x00000800
			     FAULT_CHECKPOINT                 0x00001000
			     FAULT_DISCARD                    0x00002000 (obsolete)
			     FAULT_WRITE_IO                   0x00004000
			     FAULT_SLAB_ALLOC                 0x00008000
			     FAULT_DQUOT_INIT                 0x00010000
			     FAULT_LOCK_OP                    0x00020000
			     FAULT_BLKADDR_VALIDITY           0x00040000
			     FAULT_BLKADDR_CONSISTENCE        0x00080000
			     FAULT_NO_SEGMENT                 0x00100000
			     FAULT_INCONSISTENT_FOOTER        0x00200000
			     FAULT_ATOMIC_TIMEOUT             0x00400000 (1000ms)
			     FAULT_VMALLOC                    0x00800000
			     FAULT_LOCK_TIMEOUT               0x01000000 (1000ms)
			     FAULT_SKIP_WRITE                 0x02000000
			     ===========================      ==========
mode=%s Chế độ phân bổ khối điều khiển hỗ trợ "thích ứng"
			 và "lfs". Trong chế độ "lfs", không được có ngẫu nhiên
			 viết về phía khu vực chính.
			 "đoạn:đoạn" và "đoạn:khối" mới được thêm vào đây.
			 Đây là các tùy chọn dành cho nhà phát triển cho các thử nghiệm mô phỏng hệ thống tệp
			 chính tình huống phân mảnh/sau GC. Các nhà phát triển sử dụng chúng
			 các chế độ để hiểu rõ tình trạng phân mảnh/sau GC của hệ thống tập tin,
			 và cuối cùng có được một số hiểu biết sâu sắc để xử lý chúng tốt hơn.
			 Trong "đoạn: đoạn", f2fs phân bổ một đoạn mới một cách ngẫu nhiên
			 vị trí. Với điều này, chúng ta có thể mô phỏng điều kiện sau GC.
			 Trong "đoạn:khối", chúng ta có thể phân tán việc phân bổ khối bằng
			 Các nút sysfs "max_fragment_chunk" và "max_fragment_hole".
			 Chúng tôi đã thêm một số tính năng ngẫu nhiên vào cả kích thước khối và lỗ để tạo ra
			 nó gần với mẫu IO thực tế. Vì vậy, ở chế độ này, f2fs sẽ phân bổ
			 1..<max_fragment_chunk> chặn thành một đoạn và tạo một lỗ trên
			 chiều dài 1..<max_fragment_hole> lần lượt. Với điều này, mới
			 các khối được phân bổ sẽ nằm rải rác trong toàn bộ phân vùng.
			 Lưu ý rằng "đoạn: khối" ngầm cho phép "đoạn: đoạn"
			 tùy chọn cho sự ngẫu nhiên hơn.
			 Vui lòng sử dụng các tùy chọn này cho thử nghiệm của bạn và chúng tôi thực sự
			 khuyên bạn nên định dạng lại hệ thống tập tin sau khi sử dụng các tùy chọn này.
usrquota Cho phép tính toán hạn ngạch đĩa của người dùng đơn giản.
grpquota Kích hoạt tính toán hạn ngạch đĩa nhóm đơn giản.
pjquota Cho phép tính toán hạn ngạch dự án đơn giản.
usrjquota=<file> Chỉ định tệp và loại được chỉ định trong quá trình gắn kết, sao cho hạn ngạch đó
thông tin grpjquota=<file> có thể được cập nhật chính xác trong quá trình khôi phục,
prjjquota=<file> <quota file>: phải ở thư mục gốc;
jqfmt=<loại hạn ngạch> <loại hạn ngạch>: [vfsold,vfsv0,vfsv1].
usrjquota= Tắt hạn ngạch ghi nhật ký của người dùng.
grpjquota=Tắt hạn ngạch ghi nhật ký của nhóm.
prjjquota= Tắt hạn ngạch ghi nhật ký của dự án.
hạn ngạch Cho phép tính toán hạn ngạch đĩa của người dùng đơn giản.
noquota Tắt tất cả tùy chọn hạn ngạch đĩa đơn giản.
alloc_mode=%s Điều chỉnh chính sách phân bổ khối, hỗ trợ "tái sử dụng"
			 và "mặc định".
fsync_mode=%s Kiểm soát chính sách của fsync. Hiện hỗ trợ "posix",
			 “nghiêm ngặt” và “không rào cản”. Ở chế độ "posix", đó là
			 mặc định, fsync sẽ tuân theo ngữ nghĩa POSIX và thực hiện
			 hoạt động nhẹ nhàng để cải thiện hiệu suất hệ thống tập tin.
			 Ở chế độ "nghiêm ngặt", fsync sẽ nặng và hoạt động theo đường thẳng
			 với xfs, ext4 và btrfs, trong đó xfstest generic/342 sẽ
			 vượt qua, nhưng hiệu suất sẽ thụt lùi. "không rào cản" là
			 dựa trên "posix", nhưng không đưa ra lệnh tuôn ra cho
			 các tệp không phải nguyên tử cũng có tùy chọn gắn kết "nobarrier".
test_dummy_encryption
test_dummy_encryption=%s
			 Kích hoạt mã hóa giả, cung cấp fscrypt giả
			 bối cảnh. Bối cảnh fscrypt giả được sử dụng bởi xfstests.
			 Đối số có thể là "v1" hoặc "v2", để
			 chọn phiên bản chính sách fscrypt tương ứng.
checkpoint=%s[:%u[%]] Đặt thành "tắt" để tắt tính năng kiểm tra. Đặt thành "bật"
			 để kích hoạt lại điểm kiểm tra. Được bật theo mặc định. Trong khi
			 bị vô hiệu hóa, mọi thao tác ngắt kết nối hoặc tắt máy đột ngột sẽ gây ra
			 nội dung hệ thống tập tin sẽ xuất hiện như khi
			 hệ thống tập tin đã được gắn kết với tùy chọn đó.
			 Trong khi gắn với điểm kiểm tra=vô hiệu hóa, hệ thống tập tin phải
			 chạy bộ sưu tập rác để đảm bảo rằng tất cả không gian có sẵn có thể
			 được sử dụng. Nếu việc này mất quá nhiều thời gian, thú cưỡi có thể quay trở lại
			 EAGAIN. Bạn có thể tùy ý thêm một giá trị để cho biết số tiền
			 của đĩa mà bạn sẵn sàng tạm thời từ bỏ
			 tránh thu gom rác bổ sung. Điều này có thể được đưa ra như một
			 số khối hoặc theo phần trăm. Ví dụ, gắn
			 với checkpoint=disable:100% sẽ luôn thành công, nhưng có thể
			 ẩn lên tất cả không gian trống còn lại. Không gian thực tế đó
			 sẽ không sử dụng được có thể được xem tại /sys/fs/f2fs/<disk>/unusable
			 Không gian này được lấy lại sau khi checkpoint=enable.
checkpoint_merge Khi điểm kiểm tra được bật, điểm này có thể được sử dụng để tạo kernel
			 daemon và làm cho nó hợp nhất các yêu cầu điểm kiểm tra đồng thời dưới dạng
			 càng nhiều càng tốt để loại bỏ các vấn đề điểm kiểm tra dư thừa. Ngoài ra,
			 chúng ta có thể loại bỏ vấn đề chậm chạp do điểm kiểm tra chậm gây ra
			 hoạt động khi điểm kiểm tra được thực hiện trong bối cảnh quy trình trong
			 một nhóm có ngân sách i/o và chia sẻ cpu thấp. Để làm điều này
			 làm tốt hơn, chúng tôi đặt mức độ ưu tiên I/O mặc định của trình nền kernel
			 thành "3", để ưu tiên một luồng cao hơn các luồng nhân khác.
			 Đây là cách tương tự để ưu tiên I/O cho jbd2
			 chủ đề ghi nhật ký của hệ thống tập tin ext4.
nocheckpoint_merge Tắt tính năng hợp nhất điểm kiểm tra.
Compress_algorithm=%s Thuật toán nén điều khiển, hiện tại f2fs hỗ trợ "lzo",
			 Thuật toán "lz4", "zstd" và "lzo-rle".
Compress_algorithm=%s:%d Bây giờ, chỉ kiểm soát thuật toán nén và mức độ nén của nó
			 "lz4" và "zstd" hỗ trợ cấu hình mức nén::

=====================
				 phạm vi cấp độ thuật toán
				 =====================
				 lz4 3 - 16
				 zstd 1 - 22
				 =====================

Compressor_log_size=%u Hỗ trợ định cấu hình kích thước cụm nén. Kích thước sẽ
			 là 4KB * (1 << %u). Kích thước mặc định và tối thiểu là 16KB.
nén_extension=%s Hỗ trợ thêm tiện ích mở rộng được chỉ định để f2fs có thể kích hoạt
			 nén trên các tệp tương ứng đó, ví dụ: nếu tất cả các tập tin
			 với '.ext' có tốc độ nén cao, chúng ta có thể đặt '.ext'
			 trên danh sách tiện ích mở rộng nén và bật tính năng nén
			 các tệp này theo mặc định thay vì kích hoạt nó qua ioctl.
			 Đối với các tệp khác, chúng tôi vẫn có thể kích hoạt tính năng nén qua ioctl.
			 Lưu ý rằng có một tiện ích mở rộng đặc biệt dành riêng '*', nó
			 có thể được đặt để bật tính năng nén cho tất cả các tệp.
nocompress_extension=%s Hỗ trợ thêm tiện ích mở rộng được chỉ định để f2fs có thể tắt
			 nén trên các tệp tương ứng đó, trái ngược với phần mở rộng nén.
			 Nếu bạn biết chính xác tập tin nào không thể nén được, bạn có thể sử dụng tập tin này.
			 Tên tiện ích mở rộng giống nhau không thể xuất hiện trong cả nén và nocompress
			 gia hạn cùng một lúc.
			 Nếu phần mở rộng nén chỉ định tất cả các tệp, thì các loại được chỉ định bởi
			 tiện ích mở rộng nocompress sẽ được coi là trường hợp đặc biệt và sẽ không bị nén.
			 Không cho phép sử dụng '*' để chỉ định tất cả tệp trong tiện ích mở rộng không nén.
			 Sau khi thêm nocompress_extension, mức độ ưu tiên sẽ là:
			 dir_flag < comp_extention,nocompress_extension < comp_file_flag,no_comp_file_flag.
			 Xem thêm ở phần nén.

nén_chksum Hỗ trợ xác minh chksum dữ liệu thô trong cụm nén.
Compress_mode=%s Kiểm soát chế độ nén tập tin. Điều này hỗ trợ "fs" và "người dùng"
			 chế độ. Ở chế độ "fs" (mặc định), f2fs thực hiện nén tự động
			 trên các tập tin cho phép nén. Trong chế độ "người dùng", f2fs tắt
			 nén tự động và cho phép người dùng tùy ý
			 chọn tệp mục tiêu và thời gian. Người dùng có thể làm thủ công
			 nén/giải nén trên các tệp hỗ trợ nén bằng cách sử dụng
			 ioctls.
nén_cache Hỗ trợ sử dụng không gian địa chỉ của nút hệ thống tệp được quản lý để
			 khối nén bộ đệm, để cải thiện tỷ lệ nhấn bộ đệm của
			 đọc ngẫu nhiên.
inlinecrypt Khi có thể, hãy mã hóa/giải mã nội dung của mã hóa
			 các tệp bằng cách sử dụng khung blk-crypto thay vì
			 mã hóa lớp hệ thống tập tin. Điều này cho phép sử dụng
			 phần cứng mã hóa nội tuyến. Định dạng trên đĩa là
			 không bị ảnh hưởng. Để biết thêm chi tiết, xem
			 Tài liệu/khối/inline-encryption.rst.
atgc Cho phép thu thập rác theo ngưỡng tuổi, nó cung cấp hiệu suất cao
			 hiệu lực và hiệu quả trên GC nền.
discard_unit=%s Kiểm soát đơn vị loại bỏ, đối số có thể là "block", "segment"
			 và "phần", độ lệch/kích thước của lệnh loại bỏ đã ban hành sẽ là
			 căn chỉnh theo đơn vị, theo mặc định, "discard_unit=block" được đặt,
			 để chức năng loại bỏ nhỏ được kích hoạt.
			 Đối với thiết bị được khoanh vùng, "discard_unit=section" sẽ được đặt bởi
			 mặc định, nó rất hữu ích cho các thiết bị SMR hoặc ZNS có kích thước lớn
			 giảm chi phí bộ nhớ bằng cách loại bỏ hỗ trợ siêu dữ liệu fs nhỏ
			 vứt bỏ.
Memory=%s Kiểm soát chế độ bộ nhớ. Điều này hỗ trợ chế độ "bình thường" và "thấp".
			 chế độ "thấp" được giới thiệu để hỗ trợ các thiết bị có bộ nhớ thấp.
			 Do tính chất của thiết bị có bộ nhớ thấp nên ở chế độ này, f2fs
			 đôi khi sẽ cố gắng tiết kiệm bộ nhớ bằng cách hy sinh hiệu suất.
			 Chế độ "bình thường" là chế độ mặc định và giống như trước đây.
age_extent_cache Bật bộ nhớ đệm về độ tuổi dựa trên cây rb. Nó ghi lại
			 tần số cập nhật khối dữ liệu của phạm vi trên mỗi inode, trong
			 để cung cấp gợi ý nhiệt độ tốt hơn cho khối dữ liệu
			 phân bổ.
error=%s Chỉ định hành vi f2fs đối với các lỗi nghiêm trọng. Điều này hỗ trợ các chế độ:
			 lần lượt là "hoảng loạn", "tiếp tục" và "remount-ro"
			 hoảng sợ ngay lập tức, tiếp tục mà không làm gì cả và kể lại
			 phân vùng ở chế độ chỉ đọc. Theo mặc định, nó sử dụng "tiếp tục"
			 chế độ.

			 .. code-block:: none

			     ====================== =============== =============== ========
			     mode                   continue        remount-ro      panic
			     ====================== =============== =============== ========
			     access ops             normal          normal          N/A
			     syscall errors         -EIO            -EROFS          N/A
			     mount option           rw              ro              N/A
			     pending dir write      keep            keep            N/A
			     pending non-dir write  drop            keep            N/A
			     pending node write     drop            keep            N/A
			     pending meta write     keep            keep            N/A
			     ====================== =============== =============== ========
nat_bits Kích hoạt tính năng nat_bits để tăng cường khả năng truy cập khối nat đầy đủ/trống,
			 theo mặc định nó bị vô hiệu hóa.
lookup_mode=%s Kiểm soát hành vi tra cứu thư mục cho casefolded
			 thư mục. Tùy chọn này không có tác dụng với thư mục
			 chưa bật tính năng casefold.

			 .. code-block:: none

			     ================== ========================================
			     Value              Description
			     ================== ========================================
			     perf               (Default) Enforces a hash-only lookup.
					        The linear search fallback is always
					        disabled, ignoring the on-disk flag.
			     compat             Enables the linear search fallback for
					        compatibility with directory entries
					        created by older kernel that used a
					        different case-folding algorithm.
					        This mode ignores the on-disk flag.
			     auto               F2FS determines the mode based on the
					        on-disk `SB_ENC_NO_COMPAT_FALLBACK_FL`
					        flag.
			     ================== ========================================
===========================================================================================

Mục gỡ lỗi
===============

/sys/kernel/debug/f2fs/ chứa thông tin về tất cả các phân vùng được gắn dưới dạng
f2fs. Mỗi tệp hiển thị toàn bộ thông tin f2fs.

/sys/kernel/debug/f2fs/status bao gồm:

- thông tin hệ thống tệp chính được quản lý bởi f2fs hiện tại
 - thông tin SIT trung bình về toàn bộ phân khúc
 - dung lượng bộ nhớ hiện tại được sử dụng bởi f2fs.

Mục nhập hệ thống
=============

Thông tin về hệ thống tập tin f2fs được gắn có thể được tìm thấy trong
/sys/fs/f2fs.  Mỗi hệ thống tập tin được gắn sẽ có một thư mục trong
/sys/fs/f2fs dựa trên tên thiết bị của nó (tức là /sys/fs/f2fs/sda).
Các tệp trong mỗi thư mục trên mỗi thiết bị được hiển thị trong bảng bên dưới.

Các tệp trong /sys/fs/f2fs/<devname>
(xem thêm Tài liệu/ABI/testing/sysfs-fs-f2fs)

Cách sử dụng
=====

1. Tải xuống các công cụ dành cho người dùng và biên dịch chúng.

2. Bỏ qua, nếu f2fs được biên dịch tĩnh bên trong kernel.
   Nếu không, hãy chèn mô-đun f2fs.ko::

# insmod f2fs.ko

3. Tạo thư mục để sử dụng khi mount::

# mkdir /mnt/f2fs

4. Định dạng thiết bị khối, sau đó gắn kết dưới dạng f2fs::

# mkfs.f2fs -l nhãn /dev/block_device
	# mount -t f2fs/dev/block_device/mnt/f2fs

mkfs.f2fs
---------
mkfs.f2fs dùng để định dạng phân vùng dưới dạng hệ thống tệp f2fs,
xây dựng bố cục cơ bản trên đĩa.

Các tùy chọn nhanh bao gồm:

================================================================================
ZZ0000ZZ Cung cấp nhãn ổ đĩa, tối đa 512 tên unicode.
ZZ0001ZZ Chia vị trí bắt đầu của từng khu vực để phân bổ dựa trên vùng nhớ heap.

1 được đặt theo mặc định để thực hiện việc này.
ZZ0000ZZ Đặt tỷ lệ cung cấp vượt mức theo phần trăm trên kích thước ổ đĩa.

5 được đặt theo mặc định.
ZZ0000ZZ Đặt số lượng phân đoạn trên mỗi phần.

1 được đặt theo mặc định.
ZZ0000ZZ Đặt số phần cho mỗi vùng.

1 được đặt theo mặc định.
ZZ0000ZZ Đặt danh sách tiện ích mở rộng cơ bản. ví dụ. "mp3, gif, di chuyển"
ZZ0001ZZ Tắt lệnh loại bỏ hay không.

1 được đặt theo mặc định, tiến hành loại bỏ.
================================================================================

Lưu ý: vui lòng tham khảo trang chủ của mkfs.f2fs(8) để có danh sách tùy chọn đầy đủ.

fsck.f2fs
---------
Fsck.f2fs là một công cụ để kiểm tra tính nhất quán của định dạng f2fs
phân vùng, kiểm tra xem siêu dữ liệu hệ thống tập tin và dữ liệu do người dùng tạo có
có được tham chiếu chéo chính xác hay không.
Lưu ý rằng phiên bản ban đầu của công cụ không khắc phục bất kỳ sự không nhất quán nào.

Các tùy chọn nhanh bao gồm::

-d mức gỡ lỗi [mặc định: 0]

Lưu ý: vui lòng tham khảo trang chủ của fsck.f2fs(8) để có danh sách tùy chọn đầy đủ.

bãi chứa.f2fs
---------
dump.f2fs hiển thị thông tin của inode cụ thể và chuyển SSA và SIT sang
tập tin. Mỗi tệp là dump_ssa và dump_sit.

dump.f2fs được sử dụng để gỡ lỗi cấu trúc dữ liệu trên đĩa của hệ thống tệp f2fs.
Nó hiển thị thông tin inode trên đĩa được nhận dạng bởi một số inode nhất định và được
có thể kết xuất tất cả các mục SSA và SIT vào các tệp được xác định trước, ./dump_ssa và
./dump_sit tương ứng.

Các tùy chọn bao gồm::

-d mức gỡ lỗi [mặc định: 0]
  -i inode số (hex)
  -s [SIT kết xuất segno từ #1~#2 (thập phân), với tất cả 0~-1]
  -a [SSA kết xuất segno từ #1~#2 (thập phân), với tất cả 0~-1]

Ví dụ::

# dump.f2fs -i [ino] /dev/sdx
    # dump.f2fs -s 0~-1 /dev/sdx (kết xuất SIT)
    # dump.f2fs -a 0~-1 /dev/sdx (kết xuất SSA)

Lưu ý: vui lòng tham khảo trang chủ của dump.f2fs(8) để có danh sách tùy chọn đầy đủ.

sload.f2fs
----------
sload.f2fs cung cấp cách chèn tệp và thư mục vào đĩa hiện có
hình ảnh. Công cụ này hữu ích khi xây dựng hình ảnh f2fs cho các tệp đã biên dịch.

Lưu ý: vui lòng tham khảo trang chủ của sload.f2fs(8) để có danh sách tùy chọn đầy đủ.

thay đổi kích thước.f2fs
-----------
Thay đổi kích thước.f2fs cho phép người dùng thay đổi kích thước hình ảnh đĩa có định dạng f2fs, trong khi vẫn giữ nguyên
tất cả các tập tin và thư mục được lưu trữ trong hình ảnh.

Lưu ý: vui lòng tham khảo trang chủ của size.f2fs(8) để có danh sách tùy chọn đầy đủ.

chống phân mảnh.f2fs
-----------
Defrag.f2fs có thể được sử dụng để chống phân mảnh dữ liệu văn bản rải rác cũng như
siêu dữ liệu hệ thống tập tin trên đĩa. Điều này có thể cải thiện tốc độ ghi bằng cách cho
nhiều không gian trống liên tiếp hơn.

Lưu ý: vui lòng tham khảo trang chủ của defrag.f2fs(8) để có danh sách tùy chọn đầy đủ.

f2fs_io
-------
F2fs_io là một công cụ đơn giản để phát hành các API hệ thống tệp khác nhau cũng như
những cái dành riêng cho f2fs, rất hữu ích cho các bài kiểm tra QA.

Lưu ý: vui lòng tham khảo trang chủ của f2fs_io(8) để có danh sách tùy chọn đầy đủ.

Thiết kế
======

Bố cục trên đĩa
--------------

F2FS chia toàn bộ tập đĩa thành nhiều đoạn, mỗi đoạn cố định
đến kích thước 2 MB. Một phần bao gồm các phân đoạn liên tiếp và một vùng
bao gồm một tập hợp các phần. Theo mặc định, kích thước phần và vùng được đặt thành một
kích thước phân đoạn giống hệt nhau, nhưng người dùng có thể dễ dàng sửa đổi kích thước bằng mkfs.

F2FS chia toàn bộ khối thành sáu khu vực và tất cả các khu vực ngoại trừ siêu khối
bao gồm nhiều phân đoạn như được mô tả dưới đây::

căn chỉnh với kích thước vùng <-|
                 |-> căn chỉnh với kích thước phân khúc
     _________________________________________________________________________
    ZZ0000ZZ ZZ0001ZZ Nút ZZ0002ZZ |
    Điểm kiểm tra ZZ0003ZZ ZZ0004ZZ Địa chỉ ZZ0005ZZ Chính |
    ZZ0006ZZ (CP) Bảng ZZ0007ZZ (NAT) ZZ0008ZZ |
    ZZ0009ZZ_____2______ZZ0010ZZ______N______ZZ0011ZZ__N___|
                                                                       .      .
                                                             .                .
                                                 .                            .
                                    ._________________________________________.
                                    ZZ0012ZZ_..._ZZ0013ZZ_..._ZZ0014ZZ
                                    .           .
                                    ._________._________
                                    ZZ0015ZZ__...__|_
                                    .            .
		                    .________.
	                            ZZ0016ZZ

- Siêu khối (SB)
   Nó nằm ở đầu phân vùng và tồn tại hai bản sao
   để tránh sự cố hệ thống tập tin. Nó chứa thông tin phân vùng cơ bản và một số
   thông số mặc định của f2fs.

- Điểm kiểm tra (CP)
   Nó chứa thông tin hệ thống tệp, bitmap cho các bộ NAT/SIT hợp lệ, mồ côi
   danh sách inode và các mục tóm tắt của các phân đoạn hoạt động hiện tại.

- Bảng thông tin phân khúc (SIT)
   Nó chứa thông tin phân đoạn như số khối hợp lệ và bitmap cho
   hợp lệ của tất cả các khối.

- Bảng địa chỉ nút (NAT)
   Nó bao gồm một bảng địa chỉ khối cho tất cả các khối nút được lưu trữ trong
   Khu vực chính.

- Khu vực tóm tắt phân khúc (SSA)
   Nó chứa các mục tóm tắt chứa thông tin chủ sở hữu của tất cả các
   khối dữ liệu và nút được lưu trữ trong Khu vực chính.

- Khu vực chính
   Nó chứa dữ liệu tập tin và thư mục bao gồm cả các chỉ mục của chúng.

Để tránh sai lệch giữa hệ thống tệp và bộ lưu trữ dựa trên flash, F2FS
căn chỉnh địa chỉ khối bắt đầu của CP với kích thước phân đoạn. Ngoài ra, nó sắp xếp các
địa chỉ khối bắt đầu của Khu vực chính với kích thước vùng bằng cách đặt trước một số phân đoạn
trong khu vực SSA.

Tham khảo khảo sát sau đây để biết thêm chi tiết kỹ thuật.
ZZ0000ZZ

Cấu trúc siêu dữ liệu hệ thống tệp
------------------------------

F2FS áp dụng sơ đồ điểm kiểm tra để duy trì tính nhất quán của hệ thống tệp. Tại
thời gian gắn kết, trước tiên F2FS cố gắng tìm dữ liệu điểm kiểm tra hợp lệ cuối cùng bằng cách quét
khu vực CP. Để giảm thời gian quét, F2FS chỉ sử dụng hai bản sao CP.
Một trong số chúng luôn chỉ ra dữ liệu hợp lệ cuối cùng, được gọi là bản sao bóng
cơ chế. Ngoài CP, NAT và SIT cũng áp dụng cơ chế sao chép bóng.

Để đảm bảo tính nhất quán của hệ thống tệp, mỗi CP trỏ tới các bản sao NAT và SIT.
hợp lệ, như được hiển thị như dưới đây::

+--------+----------+----------+
  ZZ0000ZZ SIT ZZ0001ZZ
  +--------+----------+----------+
  .         .          .          .
  .            .              .              .
  .               .                 .                 .
  +-------+-------+--------+--------+--------+--------+
  ZZ0002ZZ CP #1 ZZ0003ZZ SIT #1 ZZ0004ZZ NAT #1 |
  +-------+-------+--------+--------+--------+--------+
     |             ^ ^
     ZZ0005ZZ |
     `---------------------------------------'

Cấu trúc chỉ mục
---------------

Cấu trúc dữ liệu chính để quản lý các vị trí dữ liệu là một "nút". Tương tự như
cấu trúc tệp truyền thống, F2FS có ba loại nút: inode, nút trực tiếp,
nút gián tiếp. F2FS gán 4KB cho khối inode chứa khối dữ liệu 923
chỉ mục, hai con trỏ nút trực tiếp, hai con trỏ nút gián tiếp và một con trỏ nút kép
con trỏ nút gián tiếp như được mô tả dưới đây. Một khối nút trực tiếp chứa 1018
khối dữ liệu và một khối nút gián tiếp cũng chứa 1018 khối nút. Như vậy,
một khối inode (tức là một tệp) bao gồm::

4KB * (923 + 2 * 1018 + 2 * 1018 * 1018 + 1018 * 1018 * 1018) := 3,94TB.

Khối inode (4KB)
     |- dữ liệu (923)
     |- nút trực tiếp (2)
     |          ZZ0000ZZ- nút trực tiếp (1018)
     |                       ZZ0001ZZ- nút gián tiếp kép (1)
                         ZZ0002ZZ- nút trực tiếp (1018)
	                                         `- dữ liệu (1018)

Lưu ý rằng tất cả các khối nút được ánh xạ bởi NAT, nghĩa là vị trí của
mỗi nút được dịch bởi bảng NAT. Khi xem xét sự lang thang
vấn đề về cây, F2FS có thể cắt đứt quá trình truyền bá các bản cập nhật nút do
dữ liệu lá ghi.

Cấu trúc thư mục
-------------------

Một mục nhập thư mục chiếm 11 byte, bao gồm các thuộc tính sau.

- giá trị băm băm của tên tệp
- số ino inode
- len độ dài của tên tập tin
- gõ loại tập tin như thư mục, liên kết tượng trưng, ​​v.v.

Một khối nha khoa bao gồm 214 khe nha khoa và tên tệp. Trong đó một bitmap là
được sử dụng để thể hiện xem mỗi răng giả có hợp lệ hay không. Một khối nha khoa chiếm
4KB với thành phần sau.

::

Khối Dentry(4 K) = bitmap (27 byte) + dành riêng (3 byte) +
	              nha khoa (11 * 214 byte) + tên tệp (8 * 214 byte)

[Xô]
             +--------------------------------+
             Khối nha khoa ZZ0000ZZ 2 |
             +--------------------------------+
             .               .
       .                             .
  .       [Cấu trúc khối nha khoa: 4KB] .
  +--------+----------+----------+-------------+
  ZZ0001ZZ tên tệp ZZ0002ZZ dành riêng |
  +--------+----------+----------+-------------+
  [Khối nha khoa: 4KB] .   .
		 .               .
            .                          .
            +------+------+------+------+
            ZZ0003ZZ trong loại ZZ0004ZZ |
            +------+------+------+------+
            [Cấu trúc nha khoa: 11 byte]

F2FS triển khai bảng băm đa cấp cho cấu trúc thư mục. Mỗi cấp độ có
một bảng băm với số lượng nhóm băm chuyên dụng như hiển thị bên dưới. Lưu ý rằng
"A(2B)" có nghĩa là một nhóm bao gồm 2 khối dữ liệu.

::

----------------------
    A: xô
    B: khối
    N : MAX_DIR_HASH_DEPTH
    ----------------------

cấp độ #0 | A(2B)
	    |
    cấp độ #1 | A(2B) - A(2B)
	    |
    cấp độ #2 | A(2B) - A(2B) - A(2B) - A(2B)
	.     |   .       .       .       .
    cấp độ #N/2 | A(2B) - A(2B) - A(2B) - A(2B) - A(2B) - ... - A(2B)
	.     |   .       .       .       .
    cấp độ #N | A(4B) - A(4B) - A(4B) - A(4B) - A(4B) - ... - A(4B)

Số lượng khối và thùng được xác định bởi::

,- 2, nếu n < MAX_DIR_HASH_DEPTH / 2,
  Khối # of ở cấp độ #n = |
                            `- 4, Ngược lại

,- 2^(n + dir_level),
			     |        nếu n + dir_level < MAX_DIR_HASH_DEPTH/2,
  Xô # of ở cấp độ #n = |
                             `- 2^((MAX_DIR_HASH_DEPTH / 2) - 1),
			              Nếu không

Khi F2FS tìm thấy tên tệp trong một thư mục, lúc đầu giá trị băm của tệp
tên được tính toán. Sau đó, F2FS quét bảng băm ở cấp #0 để tìm
nha khoa bao gồm tên tập tin và số inode của nó. Nếu không tìm thấy, F2FS
quét bảng băm tiếp theo ở cấp độ #1. Bằng cách này, F2FS quét các bảng băm trong
mỗi cấp độ tăng dần từ 1 đến N. Ở mỗi cấp độ F2FS chỉ cần quét
một nhóm được xác định theo phương trình sau, hiển thị O(log(# of files))
độ phức tạp::

số nhóm cần quét ở cấp #n = (giá trị băm) % (các nhóm # of ở cấp #n)

Trong trường hợp tạo tập tin, F2FS tìm thấy các khe trống liên tiếp bao phủ
tên tập tin. F2FS tìm kiếm các vị trí trống trong bảng băm của toàn bộ các cấp từ
1 đến N tương tự như thao tác tra cứu.

Hình dưới đây minh họa ví dụ về hai trường hợp bế trẻ em::

--------------> Giám đốc <--------------
       ZZ0000ZZ
    đứa trẻ

con - con [lỗ] - con

con - con - con [lỗ] - [lỗ] - con

Trường hợp 1: Trường hợp 2:
   Số con = 6, Số con = 3,
   Kích thước tệp = 7 Kích thước tệp = 7

Phân bổ khối mặc định
------------------------

Trong thời gian chạy, F2FS quản lý sáu nhật ký hoạt động bên trong khu vực "Chính": Nút Nóng/Ấm/Lạnh
và dữ liệu Nóng/Ấm/Lạnh.

- Nút nóng chứa các khối nút trực tiếp của thư mục.
- Nút ấm chứa các khối nút trực tiếp ngoại trừ khối nút nóng.
- Nút lạnh chứa các khối nút gián tiếp
- Dữ liệu nóng chứa các khối nha khoa
- Dữ liệu ấm chứa các khối dữ liệu ngoại trừ khối dữ liệu nóng và lạnh
- Dữ liệu lạnh chứa dữ liệu đa phương tiện hoặc khối dữ liệu được di chuyển

LFS có hai sơ đồ quản lý không gian trống: nhật ký theo luồng và sao chép và compac-
chuyện. Sơ đồ sao chép và nén được gọi là làm sạch, rất phù hợp
dành cho các thiết bị có hiệu suất ghi tuần tự rất tốt, vì các phân đoạn trống
luôn được phục vụ để ghi dữ liệu mới. Tuy nhiên, nó gặp khó khăn trong việc làm sạch
chi phí chung với mức sử dụng cao. Ngược lại, sơ đồ nhật ký theo luồng bị ảnh hưởng
từ việc ghi ngẫu nhiên, nhưng không cần quá trình làm sạch. F2FS sử dụng hybrid
lược đồ trong đó lược đồ sao chép và nén được áp dụng theo mặc định, nhưng
chính sách được thay đổi linh hoạt thành sơ đồ nhật ký theo luồng theo tệp
trạng thái hệ thống.

Để căn chỉnh F2FS với bộ lưu trữ dựa trên flash cơ bản, F2FS phân bổ một
đoạn trong một đơn vị của phần. F2FS hy vọng rằng kích thước phần sẽ là
giống như kích thước đơn vị thu gom rác trong FTL. Hơn nữa, với sự tôn trọng
đến mức độ chi tiết của ánh xạ trong FTL, F2FS phân bổ từng phần của hoạt động
ghi nhật ký từ các vùng khác nhau càng nhiều càng tốt, vì FTL có thể ghi dữ liệu vào
nhật ký hoạt động vào một đơn vị phân bổ theo mức độ chi tiết ánh xạ của nó.

Quá trình làm sạch
----------------

F2FS thực hiện dọn dẹp theo yêu cầu và ở chế độ nền. Làm sạch theo yêu cầu là
được kích hoạt khi không có đủ phân đoạn trống để phục vụ cuộc gọi VFS. Nền
trình dọn dẹp được vận hành bởi một luồng nhân và kích hoạt công việc dọn dẹp khi
hệ thống không hoạt động.

F2FS hỗ trợ hai chính sách lựa chọn nạn nhân: thuật toán tham lam và lợi ích chi phí.
Trong thuật toán tham lam, F2FS chọn phân khúc nạn nhân có số lượng nhỏ nhất
của các khối hợp lệ. Trong thuật toán chi phí-lợi ích, F2FS chọn phân khúc nạn nhân
theo tuổi phân đoạn và số lượng khối hợp lệ để giải quyết
vấn đề đập khối log trong thuật toán tham lam. F2FS chấp nhận sự tham lam
thuật toán dọn dẹp theo yêu cầu, trong khi trình dọn dẹp nền áp dụng lợi ích chi phí
thuật toán.

Để xác định xem dữ liệu trong phân đoạn nạn nhân có hợp lệ hay không,
F2FS quản lý bitmap. Mỗi bit đại diện cho tính hợp lệ của một khối và
bitmap bao gồm một luồng bit bao phủ toàn bộ các khối trong khu vực chính.

Chính sách gợi ý viết
-----------------

F2FS luôn đặt ra lời kêu gọi với chính sách bên dưới.

============================================== ======================
Khối F2FS của người dùng
============================================== ======================
Không có META WRITE_LIFE_NONE|REQ_META
Không có HOT_NODE WRITE_LIFE_NONE
Không có WARM_NODE WRITE_LIFE_MEDIUM
Không có COLD_NODE WRITE_LIFE_LONG
ioctl(COLD) COLD_DATA WRITE_LIFE_EXTREME
danh sách tiện ích mở rộng " "

-- io được lưu vào bộ đệm
------------------------------------------------------------------
Không có COLD_DATA WRITE_LIFE_EXTREME
Không có HOT_DATA WRITE_LIFE_SHORT
Không có WARM_DATA WRITE_LIFE_NOT_SET

-- trực tiếp io
------------------------------------------------------------------
WRITE_LIFE_EXTREME COLD_DATA WRITE_LIFE_EXTREME
WRITE_LIFE_SHORT HOT_DATA WRITE_LIFE_SHORT
WRITE_LIFE_NOT_SET WARM_DATA WRITE_LIFE_NOT_SET
WRITE_LIFE_NONE" WRITE_LIFE_NONE
WRITE_LIFE_MEDIUM" WRITE_LIFE_MEDIUM
WRITE_LIFE_LONG" WRITE_LIFE_LONG
============================================== ======================

Chính sách Fallocate(2)
-------------------

Chính sách mặc định tuân theo quy tắc POSIX bên dưới.

Phân bổ không gian đĩa
    Hoạt động mặc định (tức là chế độ bằng 0) của fallocate() phân bổ
    dung lượng ổ đĩa trong phạm vi được chỉ định bởi offset và len.  các
    kích thước tệp (như được báo cáo bởi stat(2)) sẽ được thay đổi nếu offset+len được
    lớn hơn kích thước tập tin.  Bất kỳ tiểu vùng nào trong phạm vi được chỉ định
    bằng offset và len không chứa dữ liệu trước cuộc gọi sẽ
    được khởi tạo về 0.  Hành vi mặc định này gần giống với
    hành vi của hàm thư viện posix_fallocate(3) và được dự định
    như một phương pháp thực hiện tối ưu chức năng đó.

Tuy nhiên, khi F2FS nhận được ioctl(fd, F2FS_IOC_SET_PIN_FILE) trước
fallocate(fd, DEFAULT_MODE), nó phân bổ các địa chỉ khối trên đĩa có
dữ liệu bằng 0 hoặc ngẫu nhiên, rất hữu ích cho trường hợp dưới đây:

1. tạo (fd)
 2. ioctl(fd, F2FS_IOC_SET_PIN_FILE)
 3. sai(fd, 0, 0, kích thước)
 4. địa chỉ = fibmap(fd, offset)
 5. mở (blkdev)
 6. viết(blkdev, địa chỉ)

Thực hiện nén
--------------------------

- Thuật ngữ mới có tên cluster được định nghĩa là đơn vị nén cơ bản, file có thể
  được chia thành nhiều cụm một cách logic. Một cụm bao gồm 4 << n
  (n >= 0) trang logic, kích thước nén cũng là kích thước cụm, mỗi trang
  cụm có thể được nén hoặc không.

- Trong bố cục siêu dữ liệu cụm, một địa chỉ khối đặc biệt được sử dụng để biểu thị
  một cụm là một cụm được nén hoặc một cụm bình thường; đối với cụm nén, sau
  siêu dữ liệu ánh xạ cụm tới các khối vật lý [1, 4 << n - 1], trong đó f2fs
  lưu trữ dữ liệu bao gồm tiêu đề nén và dữ liệu nén.

- Để loại bỏ khuếch đại ghi trong quá trình ghi đè, chỉ F2FS
  hỗ trợ nén trên tệp ghi một lần, dữ liệu chỉ có thể được nén khi
  tất cả các khối logic trong cụm đều chứa dữ liệu hợp lệ và tỷ lệ nén của
  dữ liệu cụm thấp hơn ngưỡng được chỉ định.

- Để kích hoạt tính năng nén trên inode thông thường, có 4 cách:

* tập tin chattr +c
  * chattr +c thư mục; chạm vào thư mục/tập tin
  * gắn kết với -o nén_extension=ext; chạm vào tập tin.ext
  * gắn kết với -o nén_extension=*; chạm vào tập tin bất kỳ

- Để tắt tính năng nén trên inode thông thường, có 2 cách:

* tập tin chattr -c
  * gắn kết với -o nocompress_extension=ext; chạm vào tập tin.ext

- Ưu tiên giữa FS_COMPR_FL, FS_NOCOMP_FS, tiện ích mở rộng:

* nén_extension=so; nocompress_extension=zip; chattr +c dir; chạm vào
    dir/foo.so; chạm vào dir/bar.zip; chạm vào dir/baz.txt; sau đó là foo.so và baz.txt
    nên nén, bar.zip không nén. chattr +c dir/bar.zip
    có thể kích hoạt tính năng nén trên bar.zip.
  * nén_extension=so; nocompress_extension=zip; chattr -c thư mục; chạm vào
    dir/foo.so; chạm vào dir/bar.zip; chạm vào dir/baz.txt; thì foo.so nên như vậy
    nén, bar.zip và baz.txt không được nén.
    chattr+c dir/bar.zip; chattr+c dir/baz.txt; có thể kích hoạt tính năng nén trên bar.zip
    và baz.txt.

- Tại thời điểm này, tính năng nén không hiển thị không gian nén cho người dùng
  trực tiếp để đảm bảo cập nhật dữ liệu tiềm năng sau này vào không gian.
  Thay vào đó, mục tiêu chính là giảm việc ghi dữ liệu vào đĩa flash càng nhiều càng tốt.
  có thể, dẫn đến việc kéo dài thời gian sử dụng đĩa cũng như thư giãn IO
  ùn tắc. Ngoài ra, chúng tôi đã thêm ioctl(F2FS_IOC_RELEASE_COMPRESS_BLOCKS)
  giao diện để lấy lại không gian nén và hiển thị nó cho người dùng sau khi thiết lập
  cờ đặc biệt cho inode. Khi không gian nén được giải phóng, cờ
  sẽ chặn việc ghi dữ liệu vào tệp cho đến khi hết dung lượng nén
  được bảo lưu qua ioctl(F2FS_IOC_RESERVE_COMPRESS_BLOCKS) hoặc kích thước tệp là
  cắt ngắn về không.

Nén bố cục siêu dữ liệu::

[Cấu trúc Dnode]
		+-----------------------------------------------+
		ZZ0000ZZ cụm 2 ZZ0001ZZ cụm N |
		+-----------------------------------------------+
		.           .                       .           .
	  .                      .                .                      .
    .         Cụm nén .        .        Cụm bình thường.
    +----------+----------+----------+--------------+ +----------+--------------+----------+----------+
    Khối ZZ0002ZZ 1 Khối ZZ0003ZZ 3 Khối ZZ0004ZZ 1 Khối ZZ0005ZZ 3 ZZ0006ZZ
    +----------+----------+----------+--------------+ +----------+--------------+----------+----------+
	       .                             .
	    .                                           .
	.                                                           .
	+-------------+-------------+----------+--------------------------+
	Dữ liệu nén ZZ0007ZZ chksum Dữ liệu nén ZZ0008ZZ |
	+-------------+-------------+----------+--------------------------+

Chế độ nén
--------------------------

f2fs hỗ trợ chế độ nén "fs" và "user" với tùy chọn gắn kết "compression_mode".
Với tùy chọn này, f2fs cung cấp một lựa chọn để chọn cách nén tập tin
các tập tin hỗ trợ nén (tham khảo phần "Triển khai nén" để biết cách
cho phép nén trên một nút thông thường).

1) nén_mode=fs

Đây là tùy chọn mặc định. f2fs thực hiện nén tự động trong quá trình ghi lại của
   tập tin hỗ trợ nén.

2) nén_mode=người dùng

Điều này vô hiệu hóa tính năng nén tự động và cho phép người dùng tùy ý lựa chọn
   tập tin mục tiêu và thời gian. Người dùng có thể thực hiện nén/giải nén thủ công trên
   các tệp được kích hoạt nén bằng F2FS_IOC_DECOMPRESS_FILE và F2FS_IOC_COMPRESS_FILE
   ioctls như bên dưới.

Để giải nén một tập tin::

fd = open(tên tệp, O_WRONLY, 0);
  ret = ioctl(fd, F2FS_IOC_DECOMPRESS_FILE);

Để nén một tập tin::

fd = open(tên tệp, O_WRONLY, 0);
  ret = ioctl(fd, F2FS_IOC_COMPRESS_FILE);

Thiết bị không gian tên được khoanh vùng NVMe
----------------------------

- ZNS xác định công suất trên mỗi vùng có thể bằng hoặc nhỏ hơn công suất
  kích thước vùng. Dung lượng vùng là số khối có thể sử dụng được trong vùng.
  F2FS kiểm tra xem dung lượng vùng có nhỏ hơn kích thước vùng hay không, nếu có thì bất kỳ
  phân đoạn bắt đầu sau khi dung lượng vùng được đánh dấu là không trống trong
  bitmap phân đoạn miễn phí tại thời điểm gắn kết ban đầu. Các phân đoạn này được đánh dấu
  được sử dụng vĩnh viễn nên chúng không được phân bổ để ghi và
  do đó không cần thiết phải thu gom rác. Trong trường hợp
  dung lượng vùng không được căn chỉnh theo kích thước phân đoạn mặc định (2MB), thì phân đoạn
  có thể bắt đầu trước công suất vùng và trải dài trên ranh giới công suất vùng.
  Các đoạn mở rộng như vậy cũng được coi là các đoạn có thể sử dụng được. Tất cả các khối
  vượt quá dung lượng vùng được coi là không thể sử dụng được trong các phân đoạn này.

Tính năng đặt bí danh thiết bị
-----------------------

f2fs có thể sử dụng một tệp đặc biệt gọi là "tệp bí danh thiết bị". Tập tin này cho phép
toàn bộ thiết bị lưu trữ được ánh xạ với một mức độ lớn, duy nhất, không sử dụng
cấu trúc nút f2fs thông thường. Khu vực được lập bản đồ này được ghim và chủ yếu nhằm mục đích
để giữ không gian.

Về cơ bản, cơ chế này cho phép tạm thời một phần diện tích f2fs được
được dành riêng và sử dụng bởi hệ thống tập tin khác hoặc cho các mục đích khác. Một lần đó
việc sử dụng bên ngoài đã hoàn tất, tệp bí danh của thiết bị có thể bị xóa, giải phóng
không gian dành riêng trở lại F2FS để sử dụng riêng.

.. code-block::

   # ls /dev/vd*
   /dev/vdb (32GB) /dev/vdc (32GB)
   # mkfs.ext4 /dev/vdc
   # mkfs.f2fs -c /dev/vdc@vdc.file /dev/vdb
   # mount /dev/vdb /mnt/f2fs
   # ls -l /mnt/f2fs
   vdc.file
   # df -h
   /dev/vdb                            64G   33G   32G  52% /mnt/f2fs

   # mount -o loop /dev/vdc /mnt/ext4
   # df -h
   /dev/vdb                            64G   33G   32G  52% /mnt/f2fs
   /dev/loop7                          32G   24K   30G   1% /mnt/ext4
   # umount /mnt/ext4

   # f2fs_io getflags /mnt/f2fs/vdc.file
   get a flag on /mnt/f2fs/vdc.file ret=0, flags=nocow(pinned),immutable
   # f2fs_io setflags noimmutable /mnt/f2fs/vdc.file
   get a flag on noimmutable ret=0, flags=800010
   set a flag on /mnt/f2fs/vdc.file ret=0, flags=noimmutable
   # rm /mnt/f2fs/vdc.file
   # df -h
   /dev/vdb                            64G  753M   64G   2% /mnt/f2fs

Vì vậy, ý tưởng chính là, người dùng có thể thực hiện bất kỳ thao tác tệp nào trên/dev/vdc và
lấy lại dung lượng sau khi sử dụng, trong khi dung lượng được tính là /data.
Điều đó không yêu cầu sửa đổi kích thước phân vùng và định dạng hệ thống tập tin.

Hỗ trợ Folio lớn chỉ đọc cho mỗi tệp
--------------------------------------

F2FS triển khai hỗ trợ folio lớn trên đường dẫn đọc để tận dụng hiệu suất cao
phân bổ trang để đạt được hiệu suất đáng kể. Để giảm thiểu độ phức tạp của mã,
hỗ trợ này hiện bị loại trừ khỏi đường dẫn ghi, yêu cầu xử lý
tối ưu hóa phức tạp như chế độ nén và phân bổ khối.

Tính năng tùy chọn này chỉ được kích hoạt khi bit bất biến của tệp được đặt.
Do đó, F2FS sẽ trả về EOPNOTSUPP nếu người dùng cố mở bộ nhớ đệm
tập tin có quyền ghi, thậm chí ngay sau khi xóa bit. Viết
quyền truy cập chỉ được khôi phục sau khi nút lưu trong bộ nhớ đệm bị loại bỏ. Luồng sử dụng là
chứng minh dưới đây:

.. code-block::

   # f2fs_io setflags immutable /data/testfile_read_seq

   /* flush and reload the inode to enable the large folio */
   # sync && echo 3 > /proc/sys/vm/drop_caches

   /* mmap(MAP_POPULATE) + mlock() */
   # f2fs_io read 128 0 1024 mmap 1 0 /data/testfile_read_seq

   /* mmap() + fadvise(POSIX_FADV_WILLNEED) + mlock() */
   # f2fs_io read 128 0 1024 fadvise 1 0 /data/testfile_read_seq

   /* mmap() + mlock2(MLOCK_ONFAULT) + madvise(MADV_POPULATE_READ) */
   # f2fs_io read 128 0 1024 madvise 1 0 /data/testfile_read_seq

   # f2fs_io clearflags immutable /data/testfile_read_seq

   # f2fs_io write 1 0 1 zero buffered /data/testfile_read_seq
   Failed to open /mnt/test/test: Operation not supported

   /* flush and reload the inode to disable the large folio */
   # sync && echo 3 > /proc/sys/vm/drop_caches

   # f2fs_io write 1 0 1 zero buffered /data/testfile_read_seq
   Written 4096 bytes with pattern = zero, total_time = 29 us, max_latency = 28 us

   # rm /data/testfile_read_seq