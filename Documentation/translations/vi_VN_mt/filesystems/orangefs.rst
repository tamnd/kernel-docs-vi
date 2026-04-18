.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/orangefs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========
ORANGEFS
========

OrangeFS là hệ thống lưu trữ song song mở rộng không gian người dùng LGPL. Thật là lý tưởng
cho các vấn đề lưu trữ lớn mà HPC, BigData, Streaming Video,
Genomics, Tin sinh học.

Orangefs, ban đầu được gọi là PVFS, được phát triển lần đầu tiên vào năm 1993 bởi
Walt Ligon và Eric Blumer là hệ thống tệp song song cho Parallel
Máy ảo (PVM) như một phần của khoản tài trợ NASA để nghiên cứu các mẫu I/O
của các chương trình song song.

Các tính năng của Orangefs bao gồm:

* Phân phối dữ liệu tệp giữa nhiều máy chủ tệp
  * Hỗ trợ truy cập đồng thời bởi nhiều khách hàng
  * Lưu trữ dữ liệu tệp và siêu dữ liệu trên máy chủ bằng hệ thống tệp cục bộ
    và phương pháp truy cập
  * Triển khai không gian người dùng dễ cài đặt và bảo trì
  * Hỗ trợ trực tiếp MPI
  * Không quốc tịch


Lưu trữ danh sách gửi thư
=========================

ZZ0000ZZ


Gửi danh sách gửi thư
========================

devel@lists.orangefs.org


Tài liệu
=============

ZZ0000ZZ

Chạy ORANGEFS trên một máy chủ
===================================

OrangeFS thường được chạy trong các cài đặt lớn với nhiều máy chủ và
khách hàng, nhưng một hệ thống tập tin hoàn chỉnh có thể chạy trên một máy duy nhất
phát triển và thử nghiệm.

Trên Fedora, cài đặt orangefs và orangefs-server::

dnf -y cài đặt camfs camfs-server

Có một tệp cấu hình máy chủ ví dụ trong
/etc/orangefs/orangefs.conf.  Thay đổi localhost thành tên máy chủ của bạn nếu
cần thiết.

Để tạo hệ thống tệp để chạy xfstests, hãy xem bên dưới.

Có một tệp cấu hình máy khách mẫu trong /etc/pvfs2tab.  Đó là một
dòng đơn.  Bỏ ghi chú và thay đổi tên máy chủ nếu cần thiết.  Cái này
kiểm soát các máy khách sử dụng libpvfs2.  Điều này không kiểm soát
pvfs2-client-core.

Tạo hệ thống tập tin::

pvfs2-server -f /etc/orangefs/orangefs.conf

Khởi động máy chủ::

systemctl khởi động máy chủ camfs

Kiểm tra máy chủ::

pvfs2-ping -m /pvfsmnt

Khởi động máy khách.  Mô-đun phải được biên dịch hoặc tải trước đó
điểm::

systemctl bắt đầu orangefs-client

Gắn kết hệ thống tập tin::

mount -t pvfs2 tcp://localhost:3334/orangefs /pvfsmnt

Nguồn hệ thống tập tin không gian người dùng
============================================

ZZ0000ZZ

Các phiên bản Orangefs trước 2.9.3 sẽ không tương thích với
phiên bản ngược dòng của máy khách kernel.


Xây dựng ORANGEFS trên một máy chủ
====================================

Trường hợp OrangeFS không thể được cài đặt từ các gói phân phối, có thể
được xây dựng từ nguồn.

Bạn có thể bỏ qua --prefix nếu bạn không quan tâm đến việc mọi thứ được rải rác xung quanh
trong /usr/local.  Kể từ phiên bản 2.9.6, OrangeFS sử dụng Berkeley DB bằng
mặc định, có thể chúng tôi sẽ sớm thay đổi mặc định thành LMDB.

::

./configure --prefix=/opt/ofs --with-db-backend=lmdb --disable-usrint

làm

thực hiện cài đặt

Tạo tệp cấu hình orangefs bằng cách chạy pvfs2-genconfig và
chỉ định một tập tin cấu hình mục tiêu. Pvfs2-genconfig sẽ nhắc bạn
thông qua. Nói chung, lấy giá trị mặc định là ổn, nhưng bạn
nên sử dụng tên máy chủ của máy chủ thay vì "localhost" khi
nó liên quan đến câu hỏi đó::

/opt/ofs/bin/pvfs2-genconfig /etc/pvfs2.conf

Tạo tệp /etc/pvfs2tab (localhost vẫn ổn)::

echo tcp://localhost:3334/orangefs /pvfsmnt pvfs2 mặc định,noauto 0 0 > \
	/etc/pvfs2tab

Tạo điểm gắn kết mà bạn đã chỉ định trong tệp tab nếu cần::

mkdir /pvfsmnt

Khởi động lại máy chủ::

/opt/ofs/sbin/pvfs2-server -f /etc/pvfs2.conf

Khởi động máy chủ::

/opt/ofs/sbin/pvfs2-server /etc/pvfs2.conf

Bây giờ máy chủ sẽ chạy. Pvfs2-ls rất đơn giản
kiểm tra để xác minh rằng máy chủ đang chạy::

/opt/ofs/bin/pvfs2-ls /pvfsmnt

Nếu mọi thứ có vẻ đang hoạt động, hãy tải mô-đun hạt nhân và
bật lõi máy khách::

/opt/ofs/sbin/pvfs2-client -p /opt/ofs/sbin/pvfs2-client-core

Gắn kết hệ thống tập tin của bạn::

mount -t pvfs2 tcp://ZZ0000ZZ:3334/orangefs /pvfsmnt


Chạy xfstests
================

Sẽ rất hữu ích khi sử dụng hệ thống tập tin đầu với xfstests.  Đây có thể là
được thực hiện chỉ với một máy chủ.

Tạo bản sao thứ hai của phần FileSystem trong cấu hình máy chủ
tệp, đó là /etc/orangefs/orangefs.conf.  Đổi tên thành cào.
Thay đổi ID thành ID khác với ID của Hệ thống tệp đầu tiên
phần (2 thường là một lựa chọn tốt).

Sau đó có hai phần FileSystem: orangefs và Scratch.

Thay đổi này phải được thực hiện trước khi tạo hệ thống tập tin.

::

pvfs2-server -f /etc/orangefs/orangefs.conf

Để chạy xfstests, hãy tạo /etc/xfsqa.config::

TEST_DIR=/orangefs
    TEST_DEV=tcp://localhost:3334/orangefs
    SCRATCH_MNT=/cào
    SCRATCH_DEV=tcp://localhost:3334/scratch

Sau đó xfstests có thể được chạy ::

./kiểm tra -pvfs2


Tùy chọn
========

Các tùy chọn gắn kết sau đây được chấp nhận:

acl
    Cho phép sử dụng Danh sách kiểm soát truy cập trên các tập tin và thư mục.

nội tâm
    Một số thao tác giữa máy khách kernel và không gian người dùng
    hệ thống tập tin có thể bị gián đoạn, chẳng hạn như những thay đổi về mức độ gỡ lỗi
    và thiết lập các tham số có thể điều chỉnh.

local_lock
    Kích hoạt khóa posix từ góc độ của kernel "này". các
    Hành động khóa file_Operation mặc định là trả về ENOSYS. Posix
    khóa sẽ hoạt động nếu hệ thống tập tin được gắn với -o local_lock.
    Khóa phân phối đang được thực hiện cho tương lai.


Gỡ lỗi
=========

Nếu bạn muốn các câu lệnh gỡ lỗi (GOSSIP) theo một cách cụ thể
tập tin nguồn (ví dụ inode.c) đi tới syslog::

echo inode > /sys/kernel/debug/orangefs/kernel-debug

Không gỡ lỗi (mặc định)::

echo none > /sys/kernel/debug/orangefs/kernel-debug

Gỡ lỗi từ một số tệp nguồn::

echo inode,dir > /sys/kernel/debug/orangefs/kernel-debug

Tất cả các gỡ lỗi::

echo all > /sys/kernel/debug/orangefs/kernel-debug

Nhận danh sách tất cả các từ khóa gỡ lỗi::

cat /sys/kernel/debug/orangefs/debug-help


Giao thức giữa Mô-đun hạt nhân và không gian người dùng
=======================================================

Orangefs là một hệ thống tập tin không gian người dùng và một mô-đun hạt nhân liên quan.
Chúng ta sẽ chỉ gọi phần không gian người dùng của Orangefs là "không gian người dùng"
từ đây trở đi. Orangefs xuất phát từ PVFS và mã không gian người dùng
vẫn sử dụng PVFS cho tên hàm và tên biến. typedef không gian người dùng
nhiều công trình quan trọng. Tên hàm và biến trong
mô-đun hạt nhân đã được chuyển sang "orangefs" và Linux
Kiểu mã hóa tránh được typedefs, do đó cấu trúc mô-đun hạt nhân
tương ứng với cấu trúc không gian người dùng không được đánh máy.

Mô-đun hạt nhân triển khai một thiết bị giả mà không gian người dùng
có thể đọc và ghi vào. Không gian người dùng cũng có thể thao tác
mô-đun hạt nhân thông qua thiết bị giả với ioctl.

Bản đồ Bufmap
-------------

Khi khởi động, không gian người dùng phân bổ hai kích thước trang được căn chỉnh (posix_memalign)
bộ nhớ đệm bị khóa, một bộ dùng cho IO và một bộ dùng cho readdir
hoạt động. Bộ đệm IO là 41943040 byte và bộ đệm readdir là
4194304 byte. Mỗi bộ đệm chứa các khối logic hoặc các phân vùng và
một con trỏ tới mỗi bộ đệm được thêm vào cấu trúc PVFS_dev_map_desc của chính nó
cũng mô tả kích thước tổng thể của nó, cũng như kích thước và số lượng
các phân vùng.

Một con trỏ tới cấu trúc PVFS_dev_map_desc của bộ đệm IO được gửi tới
quy trình ánh xạ trong mô-đun hạt nhân bằng ioctl. Cấu trúc là
được sao chép từ không gian người dùng sang không gian kernel bằng copy_from_user và được sử dụng
để khởi tạo "bufmap" của mô-đun hạt nhân (struct orangefs_bufmap), mà
sau đó chứa:

* phản ánh
    - bộ đếm tham chiếu
  * desc_size - PVFS2_BUFMAP_DEFAULT_DESC_SIZE (4194304) - bộ đệm IO
    kích thước phân vùng, đại diện cho kích thước khối của hệ thống tập tin và
    được sử dụng cho s_blocksize trong siêu khối.
  * desc_count - PVFS2_BUFMAP_DEFAULT_DESC_COUNT (10) - số lượng
    phân vùng trong bộ đệm IO.
  * desc_shift - log2(desc_size), được sử dụng cho s_blocksize_bit trong siêu khối.
  * Total_size - tổng kích thước của bộ đệm IO.
  * page_count - số lượng trang 4096 byte trong bộ đệm IO.
  * page_array - một con trỏ tới byte ZZ0000ZZ
    của bộ nhớ kcalloced. Bộ nhớ này được sử dụng như một mảng con trỏ
    tới từng trang trong bộ đệm IO thông qua lệnh gọi tới get_user_pages.
  * desc_array - con trỏ tới ZZ0001ZZ
    byte bộ nhớ kcalloced. Bộ nhớ này được khởi tạo thêm:

user_desc là bản sao của hạt nhân ORANGEFS_dev_map_desc của bộ đệm IO
      cấu trúc. user_desc->ptr trỏ đến bộ đệm IO.

      ::

pages_per_desc = bufmap->desc_size / PAGE_SIZE
	bù đắp = 0

bufmap->desc_array[0].page_array = &bufmap->page_array[offset]
        bufmap->desc_array[0].array_count = pages_per_desc = 1024
        bufmap->desc_array[0].uaddr = (user_desc->ptr) + (0 * 1024 * 4096)
        bù đắp += 1024
                           .
                           .
                           .
        bufmap->desc_array[9].page_array = &bufmap->page_array[offset]
        bufmap->desc_array[9].array_count = pages_per_desc = 1024
        bufmap->desc_array[9].uaddr = (user_desc->ptr) +
                                               (9*1024*4096)
        bù đắp += 1024

* buffer_index_array - một mảng int có kích thước desc_count, được sử dụng để
    cho biết phân vùng nào của bộ đệm IO có sẵn để sử dụng.
  * buffer_index_lock - một spinlock để bảo vệ buffer_index_array trong quá trình cập nhật.
  * readdir_index_array - phần tử năm (ORANGEFS_READDIR_DEFAULT_DESC_COUNT)
    mảng int được sử dụng để chỉ ra phân vùng nào của bộ đệm readdir
    có sẵn để sử dụng.
  * readdir_index_lock - một spinlock để bảo vệ readdir_index_array trong quá trình
    cập nhật.

Hoạt động
----------

Mô-đun hạt nhân xây dựng một "op" (struct orangefs_kernel_op_s) khi nó
cần giao tiếp với không gian người dùng. Một phần của op chứa "upcall"
thể hiện yêu cầu đối với không gian người dùng. Một phần của hoạt động cuối cùng
chứa "downcall" thể hiện kết quả của yêu cầu.

Bộ cấp phát bản sàn được sử dụng để giữ bộ nhớ đệm của các cấu trúc hoạt động tiện dụng.

Tại thời điểm bắt đầu, mô-đun hạt nhân xác định và khởi tạo danh sách yêu cầu
và bảng băm in_progress để theo dõi tất cả các hoạt động đang diễn ra
trong chuyến bay vào bất kỳ thời điểm nào.

Ops có trạng thái:

* không rõ
	    - op vừa được khởi tạo
 * chờ đợi
	    - op nằm trên request_list (giới hạn hướng lên)
 * tiến trình
	    - op đang được tiến hành (đang chờ downcall)
 * phục vụ
	    - op có lệnh gọi xuống phù hợp; được
 * thanh lọc
	    - op phải bắt đầu hẹn giờ kể từ client-core
              đã thoát ra không sạch sẽ trước khi bảo trì op
 * từ bỏ
	    - người gửi đã từ bỏ việc chờ đợi nó

Khi một số chương trình không gian người dùng tùy ý cần thực hiện một
hoạt động hệ thống tập tin trên Orangefs (readdir, I/O, tạo, bất cứ thứ gì)
một cấu trúc op được khởi tạo và gắn thẻ ID phân biệt
số. Phần upcall của op đã được điền và op là
được chuyển đến hàm "service_Operation".

Service_Operation thay đổi trạng thái của op thành "đang chờ", đặt
nó trong danh sách yêu cầu và báo hiệu cho Orangefs file_Operations.poll
hoạt động thông qua hàng đợi. Không gian người dùng đang thăm dò thiết bị giả
và do đó nhận thức được yêu cầu upcall cần được đọc.

Khi chức năng Orangefs file_Operations.read được kích hoạt,
danh sách yêu cầu được tìm kiếm một op có vẻ đã sẵn sàng để xử lý.
Op được xóa khỏi danh sách yêu cầu. Thẻ từ op và
cấu trúc cuộc gọi nâng cấp đã điền sẽ được sao chép_to_user trở lại không gian người dùng.

Nếu bất kỳ điều nào trong số này (và một số giao thức bổ sung) copy_to_users không thành công,
trạng thái của op được đặt thành "chờ" và op được thêm lại vào
danh sách yêu cầu. Nếu không, trạng thái của op sẽ được thay đổi thành "đang tiến hành",
và op được băm vào thẻ của nó và đặt vào cuối danh sách trong
bảng băm in_progress tại chỉ mục mà thẻ được băm vào.

Khi không gian người dùng đã tập hợp phản hồi cho cuộc gọi nâng cấp, nó
viết phản hồi, bao gồm thẻ phân biệt, trở lại
thiết bị giả trong chuỗi io_vecs. Điều này kích hoạt Orangefs
hàm file_Operations.write_iter để tìm op có liên quan
gắn thẻ và xóa nó khỏi bảng băm in_progress. Miễn là op
trạng thái không bị "hủy" hoặc "từ bỏ", trạng thái của nó được đặt thành "được phục vụ".
Hàm file_Operations.write_iter trả về vfs đang chờ,
và quay lại service_Operation thông qua Wait_for_matching_downcall.

Hoạt động dịch vụ trả về người gọi nó với lệnh gọi xuống của op
phần (phản hồi cho lệnh gọi lên) đã được điền.

"Lõi máy khách" là cầu nối giữa mô-đun hạt nhân và
không gian người dùng. Lõi máy khách là một daemon. Lõi máy khách có một
daemon giám sát liên quan. Nếu lõi máy khách được báo hiệu
chết, daemon giám sát sẽ khởi động lại lõi máy khách. Mặc dù
lõi máy khách được khởi động lại "ngay lập tức", có một khoảng thời gian
thời gian trong một sự kiện như vậy mà lõi máy khách đã chết. Lõi khách hàng đã chết
không thể được kích hoạt bởi hàm Orangefs file_Operations.poll.
Các hoạt động đi qua service_Operation trong thời gian "chết" có thể hết thời gian chờ
trên hàng chờ và một nỗ lực được thực hiện để tái chế chúng. Rõ ràng,
nếu lõi máy khách không hoạt động quá lâu, không gian người dùng tùy ý sẽ xử lý
cố gắng sử dụng Orangefs sẽ bị ảnh hưởng tiêu cực. Đang chờ hoạt động
không thể phục vụ được sẽ bị xóa khỏi danh sách yêu cầu và
trạng thái của họ được đặt thành "bỏ cuộc". Các hoạt động đang được tiến hành nhưng không thể
được phục vụ sẽ bị xóa khỏi bảng băm in_progress và
trạng thái của họ được đặt thành "bỏ cuộc".

Các hoạt động Readdir và I/O không điển hình về tải trọng của chúng.

- các hoạt động readdir sử dụng phần nhỏ hơn của hai phần được phân bổ trước được phân bổ trước
    bộ nhớ đệm. Bộ đệm readdir chỉ khả dụng cho không gian người dùng.
    Mô-đun hạt nhân lấy chỉ mục cho phân vùng trống trước khi khởi chạy
    một thư mục đọc. Không gian người dùng gửi kết quả vào phân vùng được lập chỉ mục
    và sau đó ghi chúng trở lại thiết bị pvfs.

- Hoạt động io (đọc và ghi) sử dụng phần lớn hơn trong hai phần được phân bổ trước
    bộ nhớ đệm được phân vùng trước. Bộ đệm IO có thể truy cập được từ
    cả không gian người dùng và mô-đun hạt nhân. Mô-đun hạt nhân nhận được một
    lập chỉ mục cho một phân vùng trống trước khi khởi chạy io op. Mô-đun hạt nhân
    tiền gửi ghi dữ liệu vào phân vùng được lập chỉ mục, sẽ được sử dụng
    trực tiếp bởi không gian người dùng. Không gian người dùng gửi kết quả đọc
    yêu cầu vào phân vùng được lập chỉ mục, được sử dụng trực tiếp
    bởi mô-đun hạt nhân.

Tất cả các phản hồi cho yêu cầu kernel đều được đóng gói trong pvfs2_downcall_t
cấu trúc. Ngoài một số thành viên khác, pvfs2_downcall_t còn chứa một
sự kết hợp của các cấu trúc, mỗi cấu trúc được liên kết với một cấu trúc cụ thể
kiểu phản hồi.

Một số thành viên bên ngoài công đoàn là:

ZZ0000ZZ
    - loại hoạt động.
 ZZ0001ZZ
    - trả lại mã cho hoạt động.
 ZZ0002ZZ
    - 0 trừ khi hoạt động readdir.
 ZZ0003ZZ
    - được khởi tạo thành NULL, được sử dụng trong các hoạt động readdir.

Thành viên thích hợp trong công đoàn được điền vào bất kỳ
phản ứng cụ thể.

PVFS2_VFS_OP_FILE_IO
    điền vào pvfs2_io_response_t

PVFS2_VFS_OP_LOOKUP
    điền vào PVFS_object_kref

PVFS2_VFS_OP_CREATE
    điền vào PVFS_object_kref

PVFS2_VFS_OP_SYMLINK
    điền vào PVFS_object_kref

PVFS2_VFS_OP_GETATTR
    điền vào PVFS_sys_attr_s (rất nhiều thứ mà kernel không cần)
    điền vào một chuỗi với mục tiêu liên kết khi đối tượng là một liên kết tượng trưng.

PVFS2_VFS_OP_MKDIR
    điền vào PVFS_object_kref

PVFS2_VFS_OP_STATFS
    điền vào pvfs2_statfs_response_t những thông tin vô ích <g>. Thật khó cho
    chúng tôi biết, một cách kịp thời, những số liệu thống kê này về chúng tôi
    hệ thống tập tin mạng phân tán.

PVFS2_VFS_OP_FS_MOUNT
    điền vào pvfs2_fs_mount_response_t giống như PVFS_object_kref
    ngoại trừ các thành viên của nó có thứ tự khác và "__pad1" được thay thế
    với "id".

PVFS2_VFS_OP_GETXATTR
    điền vào pvfs2_getxattr_response_t

PVFS2_VFS_OP_LISTXATTR
    điền vào pvfs2_listxattr_response_t

PVFS2_VFS_OP_PARAM
    điền vào pvfs2_param_response_t

PVFS2_VFS_OP_PERF_COUNT
    điền vào pvfs2_perf_count_response_t

PVFS2_VFS_OP_FSKEY
    gửi pvfs2_fs_key_response_t

PVFS2_VFS_OP_READDIR
    gộp mọi thứ cần thiết để thể hiện pvfs2_readdir_response_t vào
    bộ mô tả bộ đệm readdir được chỉ định trong lệnh gọi lên.

Không gian người dùng sử dụng writev() trên /dev/pvfs2-req để chuyển phản hồi cho các yêu cầu
được thực hiện bởi phía kernel.

Một buffer_list chứa:

- một con trỏ tới phản hồi đã chuẩn bị sẵn cho yêu cầu từ
    hạt nhân (struct pvfs2_downcall_t).
  - và ngoài ra, trong trường hợp yêu cầu readdir, một con trỏ tới một
    bộ đệm chứa các bộ mô tả cho các đối tượng trong mục tiêu
    thư mục.

... is sent to the function (PINT_dev_write_list) which performs
viết v.

PINT_dev_write_list có một mảng iovec cục bộ: struct iovec io_array[10];

Bốn phần tử đầu tiên của io_array được khởi tạo như thế này cho tất cả
phản hồi::

io_array[0].iov_base = địa chỉ của biến cục bộ "proto_ver" (int32_t)
  io_array[0].iov_len = sizeof(int32_t)

io_array[1].iov_base = địa chỉ của biến toàn cục "pdev_magic" (int32_t)
  io_array[1].iov_len = sizeof(int32_t)

io_array[2].iov_base = địa chỉ của tham số "tag" (PVFS_id_gen_t)
  io_array[2].iov_len = sizeof(int64_t)

io_array[3].iov_base = địa chỉ của thành viên out_downcall (pvfs2_downcall_t)
                         của biến toàn cục vfs_request (vfs_request_t)
  io_array[3].iov_len = sizeof(pvfs2_downcall_t)

Phản hồi Readdir khởi tạo phần tử thứ năm io_array như thế này ::

io_array[4].iov_base = nội dung của thành viên trailer_buf (char *)
                         từ thành viên out_downcall của biến toàn cục
                         vfs_request
  io_array[4].iov_len = nội dung trailer_size của thành viên (PVFS_size)
                        từ thành viên out_downcall của biến toàn cục
                        vfs_request

Orangefs khai thác dcache để tránh gửi dữ liệu dư thừa
yêu cầu tới không gian người dùng. Chúng tôi luôn cập nhật các thuộc tính inode của đối tượng với
camfs_inode_getattr. Orangefs_inode_getattr sử dụng hai đối số để
giúp nó quyết định có cập nhật một nút hay không: "mới" và "bỏ qua".
Orangefs giữ dữ liệu riêng tư trong inode của đối tượng bao gồm một đoạn mã ngắn
giá trị thời gian chờ, getattr_time, cho phép bất kỳ lần lặp nào của
orangefs_inode_getattr để biết inode đã tồn tại được bao lâu
được cập nhật. Khi đối tượng không mới (mới == 0) và cờ bỏ qua không
set (bypass == 0) orangefs_inode_getattr trả về mà không cập nhật inode
nếu getattr_time chưa hết thời gian chờ. Getattr_time được cập nhật mỗi lần
inode được cập nhật.

Việc tạo một đối tượng mới (file, dir, sym-link) bao gồm việc đánh giá
tên đường dẫn của nó, dẫn đến một mục nhập thư mục phủ định cho đối tượng.
Một inode mới được phân bổ và liên kết với nha khoa, chuyển nó từ
một mục tiêu tiêu cực trở thành một "thành viên đầy đủ năng suất của xã hội". camfs
lấy inode mới từ Linux bằng new_inode() và các cộng sự
inode với nha khoa bằng cách gửi cặp trở lại Linux với
d_instantiate().

Việc đánh giá tên đường dẫn cho một đối tượng sẽ giải quyết tương ứng của nó
nha khoa. Nếu không có nha khoa tương ứng, một nha khoa sẽ được tạo cho nó trong
cái dcache. Bất cứ khi nào một răng giả được sửa đổi hoặc xác minh, Orangefs sẽ lưu trữ một
giá trị thời gian chờ ngắn trong d_time của nha khoa và nha khoa sẽ được tin cậy
trong khoảng thời gian đó. Orangefs là một hệ thống tập tin mạng và các đối tượng
có khả năng thay đổi ngoài băng tần với bất kỳ mô-đun hạt nhân Orangefs cụ thể nào
Ví dụ, tin tưởng vào một nha khoa là rất rủi ro. Sự thay thế cho sự tin tưởng
dentries là luôn lấy được thông tin cần thiết từ không gian người dùng - tại
ít nhất là một chuyến đi đến lõi máy khách, có thể đến máy chủ. Lấy thông tin
từ nha sĩ thì rẻ, lấy nó từ không gian người dùng thì tương đối đắt,
từ đó có động lực sử dụng răng giả khi có thể.

Các giá trị thời gian chờ d_time và getattr_time được dựa trên thời gian ngắn và
mã được thiết kế để tránh sự cố quấn nhanh::

"Nói chung, nếu đồng hồ có thể quay nhiều vòng thì có
    không cách nào biết được thời gian đã trôi qua bao lâu. Tuy nhiên, nếu thời gian t1
    và t2 được biết là khá gần nhau, chúng ta có thể tính toán một cách đáng tin cậy
    sự khác biệt theo cách có tính đến khả năng
    đồng hồ có thể đã bị cuốn giữa các thời điểm."

từ ghi chú khóa học của người hướng dẫn Andy Wang
