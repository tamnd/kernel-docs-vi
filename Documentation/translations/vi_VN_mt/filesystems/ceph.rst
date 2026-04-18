.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ceph.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Hệ thống tệp phân tán Ceph
===============================

Ceph là một hệ thống tập tin mạng phân tán được thiết kế để cung cấp khả năng
hiệu suất, độ tin cậy và khả năng mở rộng.

Các tính năng cơ bản bao gồm:

* Ngữ nghĩa POSIX
 * Chia tỷ lệ liền mạch từ 1 đến hàng nghìn nút
 * Tính sẵn sàng và độ tin cậy cao.  Không có điểm thất bại duy nhất.
 * Sao chép dữ liệu N-way trên các nút lưu trữ
 * Phục hồi nhanh sau lỗi nút
 * Tự động cân bằng lại dữ liệu khi thêm/xóa nút
 * Triển khai dễ dàng: hầu hết các thành phần FS đều là daemon không gian người dùng

Cũng,

* Ảnh chụp nhanh linh hoạt (trên bất kỳ thư mục nào)
 * Kế toán đệ quy (tệp, thư mục, byte lồng nhau)

Ngược lại với các hệ thống tập tin cụm như GFS, OCFS2 và GPFS dựa vào
về quyền truy cập đối xứng của tất cả khách hàng vào các thiết bị khối dùng chung, Ceph
tách quản lý dữ liệu và siêu dữ liệu thành máy chủ độc lập
cụm, tương tự như Lustre.  Tuy nhiên, không giống như Lustre, siêu dữ liệu và
các nút lưu trữ chạy hoàn toàn dưới dạng daemon không gian người dùng.  Dữ liệu tập tin bị sọc
trên các nút lưu trữ theo khối lớn để phân phối khối lượng công việc và
tạo điều kiện cho thông lượng cao.  Khi các nút lưu trữ bị lỗi, dữ liệu sẽ bị
được sao chép lại theo kiểu phân tán bởi chính các nút lưu trữ
(với sự phối hợp tối thiểu từ màn hình cụm), làm cho
hệ thống cực kỳ hiệu quả và có thể mở rộng.

Các máy chủ siêu dữ liệu hình thành một cách hiệu quả một hệ thống lớn, nhất quán, được phân phối
bộ đệm trong bộ nhớ phía trên không gian tên tệp có khả năng mở rộng cực kỳ cao,
phân phối lại siêu dữ liệu một cách linh hoạt để đáp ứng với những thay đổi về khối lượng công việc,
và có thể chịu đựng được các lỗi nút tùy ý (tốt, không phải Byzantine).  các
máy chủ siêu dữ liệu có cách tiếp cận hơi khác thường đối với siêu dữ liệu
lưu trữ để cải thiện đáng kể hiệu suất cho khối lượng công việc thông thường.  trong
cụ thể, các nút chỉ có một liên kết duy nhất được nhúng vào
thư mục, cho phép toàn bộ thư mục của răng và inodes được
được tải vào bộ đệm của nó chỉ bằng một thao tác I/O.  Nội dung của
các thư mục cực lớn có thể được phân mảnh và quản lý bởi
máy chủ siêu dữ liệu độc lập, cho phép truy cập đồng thời có thể mở rộng.

Hệ thống cung cấp tính năng tái cân bằng/di chuyển dữ liệu tự động khi mở rộng quy mô
từ một cụm nhỏ chỉ có vài nút đến hàng trăm nút mà không có
yêu cầu quản trị viên khắc tập dữ liệu vào các khối tĩnh hoặc
trải qua quá trình di chuyển dữ liệu tẻ nhạt giữa các máy chủ.
Khi hệ thống tập tin gần đầy, các nút mới có thể dễ dàng được thêm vào
và mọi thứ sẽ "hoạt động bình thường."

Ceph bao gồm cơ chế chụp nhanh linh hoạt cho phép người dùng tạo
ảnh chụp nhanh về bất kỳ thư mục con nào (và nội dung lồng nhau của nó) trong
hệ thống.  Tạo và xóa ảnh chụp nhanh đơn giản như 'mkdir
.snap/foo' và 'rmdir .snap/foo'.

Tên ảnh chụp nhanh có hai hạn chế:

* Chúng không thể bắt đầu bằng dấu gạch dưới ('_'), vì những tên này được bảo lưu
  để MDS sử dụng nội bộ.
* Kích thước của chúng không được vượt quá 240 ký tự.  Điều này là do MDS tạo ra
  sử dụng tên ảnh chụp nhanh dài trong nội bộ, theo định dạng:
  ZZ0000ZZ.  Vì tên tập tin nói chung không thể có
  hơn 255 ký tự và ZZ0001ZZ có 13 ký tự, chiều dài
  tên ảnh chụp nhanh có thể lên tới 255 - 1 - 1 - 13 = 240.

Ceph cũng cung cấp một số tính toán đệ quy trên các thư mục cho các tệp lồng nhau
và byte.  Bạn có thể chạy các lệnh ::

getfattr -n ceph.dir.rfiles /some/dir
 getfattr -n ceph.dir.rbytes /some/dir

để có được tổng số tệp lồng nhau và kích thước kết hợp của chúng tương ứng.
Điều này làm cho việc xác định người tiêu dùng dung lượng ổ đĩa lớn tương đối nhanh chóng,
vì không cần 'du' hoặc quét đệ quy tương tự hệ thống tệp.

Cuối cùng, Ceph cũng cho phép đặt hạn ngạch trên bất kỳ thư mục nào trong hệ thống.
Hạn ngạch có thể hạn chế số byte hoặc số lượng tệp được lưu trữ
bên dưới điểm đó trong hệ thống phân cấp thư mục.  Hạn ngạch có thể được thiết lập bằng cách sử dụng
thuộc tính mở rộng 'ceph.quota.max_files' và 'ceph.quota.max_bytes', ví dụ::

setfattr -n ceph.quota.max_bytes -v 100000000 /some/dir
 getfattr -n ceph.quota.max_bytes /some/dir

Hạn chế của việc thực hiện hạn ngạch hiện nay là nó phụ thuộc vào
sự hợp tác của khách hàng gắn hệ thống tập tin để dừng người ghi khi
đã đạt đến giới hạn.  Không thể ngăn chặn một máy khách bị sửa đổi hoặc đối nghịch
từ việc ghi nhiều dữ liệu như nó cần.

Cú pháp gắn kết
============

Cú pháp gắn kết cơ bản là::

# mount -t ceph user@fsid.fs_name=/[subdir] mnt -o mon_addr=monip1[:port][/monip2[:port]]

Bạn chỉ cần chỉ định một màn hình duy nhất vì khách hàng sẽ nhận được
danh sách đầy đủ khi nó kết nối.  (Tuy nhiên, nếu màn hình bạn chỉ định
tình cờ bị hỏng, quá trình gắn kết sẽ không thành công.) Cổng có thể bị bỏ lại
tắt nếu màn hình đang sử dụng chế độ mặc định.  Vì vậy nếu màn hình ở
1.2.3.4::

# mount -t ceph cephuser@07fe3187-00d9-42a3-814b-72a4d5e7d5be.cephfs=/ /mnt/ceph -o mon_addr=1.2.3.4

là đủ.  Nếu /sbin/mount.ceph được cài đặt, tên máy chủ có thể là
được sử dụng thay cho địa chỉ IP và cụm FSID có thể bị bỏ qua
(vì trình trợ giúp gắn kết sẽ điền nó bằng cách đọc cấu hình ceph
tập tin)::

# mount -t ceph cephuser@cephfs=/ /mnt/ceph -o mon_addr=mon-addr

Có thể chuyển nhiều địa chỉ màn hình bằng cách phân tách từng địa chỉ bằng dấu gạch chéo (ZZ0000ZZ)::

# mount -t ceph cephuser@cephfs=/ /mnt/ceph -o mon_addr=192.168.1.100/192.168.1.101

Khi sử dụng trình trợ giúp gắn kết, địa chỉ màn hình có thể được đọc từ ceph
tập tin cấu hình nếu có. Lưu ý rằng, cụm FSID (được chuyển thành một phần
của chuỗi thiết bị) được xác thực bằng cách kiểm tra nó với FSID được báo cáo bởi
màn hình.

Tùy chọn gắn kết
=============

mon_addr=ip_address[:port][/ip_address[:port]]
	Giám sát địa chỉ đến cụm. Điều này được sử dụng để khởi động
        kết nối vào cụm. Sau khi kết nối được thiết lập,
        địa chỉ màn hình trong bản đồ màn hình được theo sau.

fsid=id cụm
	FSID của cụm (từ lệnh ZZ0000ZZ).

ip=A.B.C.D[:N]
	Chỉ định IP và/hoặc cổng mà máy khách sẽ liên kết cục bộ.
	Thông thường không có nhiều lý do để làm điều này.  Nếu IP không
	được chỉ định, địa chỉ IP của khách hàng được xác định bằng cách xem xét
	địa chỉ kết nối của nó với màn hình bắt nguồn từ đâu.

wsize=X
	Chỉ định kích thước ghi tối đa theo byte.  Mặc định: 64 MB.

rsize=X
	Chỉ định kích thước đọc tối đa tính bằng byte.  Mặc định: 64 MB.

rasize=X
	Chỉ định kích thước đọc trước tối đa tính bằng byte.  Mặc định: 8 MB.

mount_timeout=X
	Chỉ định giá trị thời gian chờ cho mount (tính bằng giây), trong trường hợp
	của hệ thống tệp Ceph không phản hồi.  Mặc định là 60
	giây.

mũ_max=X
	Chỉ định số lượng mũ tối đa để giữ. Mũ không sử dụng được phát hành
	khi số lượng giới hạn vượt quá giới hạn. Mặc định là 0 (không giới hạn)

rbyte
	Khi stat() được gọi trên một thư mục, hãy đặt st_size thành 'rbytes',
	tổng kích thước tệp trên tất cả các tệp được lồng bên dưới đó
	thư mục.  Đây là mặc định.

norbyte
	Khi stat() được gọi trên một thư mục, hãy đặt st_size thành
	số mục trong thư mục đó.

đêm khuya
	Tắt tính toán CRC32C để ghi dữ liệu.  Nếu được đặt, nút lưu trữ
	phải dựa vào tính năng sửa lỗi của TCP để phát hiện hỏng dữ liệu
	trong tải trọng dữ liệu.

dache
        Sử dụng nội dung dcache để thực hiện tra cứu phủ định và
        readdir khi máy khách có toàn bộ nội dung thư mục trong
        bộ đệm của nó.  (Điều này không thay đổi tính chính xác; khách hàng sử dụng
        siêu dữ liệu được lưu vào bộ nhớ đệm chỉ khi hợp đồng thuê hoặc khả năng đảm bảo nó được lưu trữ
        hợp lệ.)

gật đầu
        Không sử dụng dcache như trên.  Điều này tránh được một lượng đáng kể
        mã phức tạp, hy sinh hiệu suất mà không ảnh hưởng đến tính chính xác,
        và rất hữu ích cho việc theo dõi lỗi.

noasyncreaddir
	Không sử dụng dcache như trên cho readdir.

noquotadf
        Báo cáo mức sử dụng hệ thống tệp tổng thể trong statfs thay vì sử dụng root
        hạn ngạch thư mục.

nocopyfrom
        Không sử dụng thao tác 'sao chép từ' RADOS để thực hiện đối tượng từ xa
        bản sao.  Hiện tại, nó chỉ được sử dụng trong copy_file_range, nó sẽ hoàn nguyên
        về cài đặt VFS mặc định nếu tùy chọn này được sử dụng.

recovery_session=<no|sạch>
	Đặt chế độ tự động kết nối lại trong trường hợp máy khách bị đưa vào danh sách chặn. các
	các chế độ khả dụng là "không" và "sạch". Mặc định là "không".

* không: không bao giờ thử kết nối lại khi máy khách phát hiện ra rằng nó đã bị
	  bị liệt vào danh sách chặn. Các hoạt động nói chung sẽ thất bại sau khi bị đưa vào danh sách chặn.

* sạch: máy khách tự động kết nối lại với cụm ceph khi nó
	  phát hiện rằng nó đã bị đưa vào danh sách chặn. Trong khi kết nối lại, máy khách bị rớt
	  dữ liệu/siêu dữ liệu bẩn, làm mất hiệu lực bộ đệm trang và xử lý tệp có thể ghi.
	  Sau khi kết nối lại, khóa tệp trở nên cũ vì MDS mất dấu vết
	  của họ. Nếu một inode chứa bất kỳ khóa tập tin cũ nào, hãy đọc/ghi trên
	  inode không được phép cho đến khi ứng dụng giải phóng tất cả các khóa tệp cũ.

Thêm thông tin
================

Để biết thêm thông tin về Ceph, xem trang chủ tại
	ZZ0000ZZ

Cây nguồn máy khách nhân Linux có sẵn tại
	-ZZ0000ZZ

và nguồn cho toàn bộ hệ thống là tại
	ZZ0000ZZ