.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/localio.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

============
NFS LOCALIO
===========

Tổng quan
========

Giao thức RPC phụ trợ LOCALIO cho phép máy khách Linux NFS và
máy chủ bắt tay một cách đáng tin cậy để xác định xem chúng có ở trên cùng một không
chủ nhà. Chọn "Hỗ trợ máy khách và máy chủ NFS cho phụ trợ LOCALIO
giao thức" trong menuconfig để kích hoạt CONFIG_NFS_LOCALIO trong kernel
config (cả CONFIG_NFS_FS và CONFIG_NFSD cũng phải được bật).

Sau khi bắt tay máy khách và máy chủ NFS là "cục bộ", máy khách sẽ
bỏ qua giao thức mạng RPC để thực hiện các hoạt động đọc, ghi và cam kết.
Do bỏ qua XDR và RPC này, các thao tác này sẽ hoạt động nhanh hơn.

Việc triển khai giao thức phụ trợ LOCALIO, sử dụng cùng một
kết nối dưới dạng lưu lượng NFS, tuân theo mẫu được thiết lập bởi NFS
Phần mở rộng giao thức ACL.

Cần có giao thức phụ trợ LOCALIO để cho phép khám phá mạnh mẽ các
khách hàng cục bộ đến máy chủ của họ. Trong một triển khai riêng tư
trước khi sử dụng giao thức LOCALIO này, một mạng sockaddr mỏng manh
Đã thử so khớp dựa trên địa chỉ với tất cả các giao diện mạng cục bộ.
Nhưng không giống như giao thức LOCALIO, việc so khớp dựa trên sockaddr không
xử lý việc sử dụng iptables hoặc container.

Sự bắt tay mạnh mẽ giữa máy khách và máy chủ cục bộ chỉ là
đầu, trường hợp sử dụng cuối cùng mà địa phương này có thể thực hiện được là
khách hàng có thể mở tệp và thực hiện đọc, ghi và cam kết
trực tiếp đến máy chủ mà không cần phải qua mạng. các
yêu cầu là thực hiện các hoạt động NFS loopback này một cách hiệu quả
càng tốt, điều này đặc biệt hữu ích cho các trường hợp sử dụng vùng chứa
(ví dụ: kubernetes), nơi có thể chạy công việc IO cục bộ trên
máy chủ.

Lợi thế về hiệu suất được nhận ra từ khả năng vượt qua của LOCALIO
việc sử dụng XDR và RPC để đọc, ghi và xác nhận có thể rất khó khăn, ví dụ:

fio trong 20 giây với directio, qd 8, 16 chủ đề libaio:
  - Với LOCALIO:
    Đọc 4K: IOPS=979k, BW=3825MiB/s (4011MB/s)(74,7GiB/20002msec)
    Ghi 4K: IOPS=165k, BW=646MiB/s (678MB/s)(12,6GiB/20002msec)
    Đọc 128K: IOPS=402k, BW=49,1GiB/s (52,7GB/s)(982GiB/20002msec)
    Ghi 128K: IOPS=11,5k, BW=1433MiB/s (1503MB/s)(28.0GiB/20004msec)

- Không có LOCALIO:
    Đọc 4K: IOPS=79,2k, BW=309MiB/s (324MB/s)(6188MiB/20003msec)
    Ghi 4K: IOPS=59,8k, BW=234MiB/s (245MB/s)(4671MiB/20002msec)
    Đọc 128K: IOPS=33,9k, BW=4234MiB/s (4440MB/s)(82,7GiB/20004msec)
    Ghi 128K: IOPS=11,5k, BW=1434MiB/s (1504MB/s)(28.0GiB/20011msec)

fio trong 20 giây với directio, qd là 8, 1 luồng libaio:
  - Với LOCALIO:
    Đọc 4K: IOPS=230k, BW=898MiB/s (941MB/s)(17,5GiB/20001msec)
    Ghi 4K: IOPS=22,6k, BW=88,3MiB/s (92,6MB/s)(1766MiB/20001msec)
    Đọc 128K: IOPS=38,8k, BW=4855MiB/s (5091MB/s)(94,8GiB/20001msec)
    Ghi 128K: IOPS=11,4k, BW=1428MiB/s (1497MB/s)(27,9GiB/20001msec)

- Không có LOCALIO:
    Đọc 4K: IOPS=77,1k, BW=301MiB/s (316MB/s)(6022MiB/20001msec)
    Ghi 4K: IOPS=32,8k, BW=128MiB/s (135MB/s)(2566MiB/20001msec)
    Đọc 128K: IOPS=24,4k, BW=3050MiB/s (3198MB/s)(59,6GiB/20001msec)
    Ghi 128K: IOPS=11,4k, BW=1430MiB/s (1500MB/s)(27,9GiB/20001msec)

FAQ
===

1. Các trường hợp sử dụng LOCALIO là gì?

Một. Khối lượng công việc trong đó máy khách và máy chủ NFS trên cùng một máy chủ
      nhận ra hiệu suất IO được cải thiện. Đặc biệt, thường xảy ra khi
      chạy khối lượng công việc được đóng gói để tìm việc làm
      chạy trên cùng một máy chủ với máy chủ knfsd đang được sử dụng cho
      lưu trữ.

2. Các yêu cầu đối với LOCALIO là gì?

Một. Bỏ qua việc sử dụng giao thức mạng RPC càng nhiều càng tốt. Cái này
      bao gồm bỏ qua XDR và RPC để mở, đọc, viết và cam kết
      hoạt động.
   b. Cho phép máy khách và máy chủ tự động phát hiện xem chúng có
      chạy cục bộ với nhau mà không đưa ra bất kỳ giả định nào về
      topo mạng cục bộ.
   c. Hỗ trợ việc sử dụng các thùng chứa bằng cách tương thích với các thiết bị liên quan
      không gian tên (ví dụ: mạng, người dùng, mount).
   d. Hỗ trợ tất cả các phiên bản của NFS. NFSv3 có tầm quan trọng đặc biệt
      bởi vì nó được sử dụng rộng rãi trong doanh nghiệp và các tệp linh hoạt pNFS được sử dụng
      của nó cho đường dẫn dữ liệu.

3. Tại sao LOCALIO không chỉ so sánh địa chỉ IP hoặc tên máy chủ khi
   quyết định xem máy khách và máy chủ NFS có được đặt cùng vị trí trên cùng một không
   chủ nhà?

Vì một trong những trường hợp sử dụng chính là khối lượng công việc được chứa trong bộ chứa nên chúng tôi không thể
   giả sử rằng địa chỉ IP sẽ được chia sẻ giữa máy khách và
   máy chủ. Điều này thiết lập một yêu cầu cho một giao thức bắt tay
   cần phải đi qua cùng một kết nối với lưu lượng NFS để
   xác định rằng máy khách và máy chủ thực sự đang chạy trên
   cùng một máy chủ. Cái bắt tay sử dụng một bí mật được gửi qua đường dây,
   và có thể được cả hai bên xác minh bằng cách so sánh với giá trị được lưu trữ
   trong bộ nhớ kernel dùng chung nếu chúng thực sự nằm cùng vị trí.

4. LOCALIO có cải thiện các tệp linh hoạt pNFS không?

Có, LOCALIO bổ sung cho các tệp linh hoạt pNFS bằng cách cho phép nó sử dụng
   lợi thế của máy khách và máy chủ NFS.  Chính sách khởi xướng
   client IO càng gần với máy chủ nơi dữ liệu được lưu trữ một cách tự nhiên
   lợi ích từ việc tối ưu hóa đường dẫn dữ liệu mà LOCALIO cung cấp.

5. Tại sao không phát triển bố cục pNFS mới để kích hoạt LOCALIO?

Một bố cục pNFS mới có thể được phát triển, nhưng làm như vậy sẽ đặt
   trách nhiệm trên máy chủ bằng cách nào đó phát hiện ra rằng máy khách được đặt cùng vị trí
   khi quyết định giao bố cục.
   Có giá trị theo cách tiếp cận đơn giản hơn (do LOCALIO cung cấp)
   cho phép khách hàng NFS đàm phán và tận dụng địa phương mà không cần
   đòi hỏi mô hình hóa phức tạp hơn và khám phá địa phương đó trong một
   cách tập trung hơn.

6. Tại sao yêu cầu máy khách thực hiện tệp phía máy chủ OPEN mà không có
   sử dụng RPC, có lợi không?  Lợi ích pNFS có cụ thể không?

Tránh sử dụng XDR và RPC để mở tệp sẽ có lợi cho
   hiệu suất bất kể pNFS có được sử dụng hay không. Đặc biệt là khi
   xử lý các tệp nhỏ tốt nhất là tránh đi quá giới hạn
   bất cứ khi nào có thể, nếu không nó có thể làm giảm hoặc thậm chí phủ nhận
   lợi ích của việc tránh dây để thực hiện I/O tệp nhỏ.
   Với các yêu cầu của LOCALIO, cách tiếp cận hiện tại là có
   khách hàng thực hiện mở tệp phía máy chủ mà không cần sử dụng RPC là lý tưởng.
   Nếu trong tương lai yêu cầu thay đổi thì chúng ta có thể điều chỉnh cho phù hợp.

7. Tại sao LOCALIO chỉ được hỗ trợ với Xác thực UNIX (AUTH_UNIX)?

Xác thực mạnh thường được gắn với chính kết nối đó. Nó
   hoạt động bằng cách thiết lập một bối cảnh được máy chủ lưu vào bộ nhớ đệm và
   đóng vai trò là chìa khóa để khám phá mã thông báo ủy quyền, mã thông báo này
   sau đó có thể được chuyển tới rpc.mountd để hoàn tất xác thực
   quá trình. Mặt khác, trong trường hợp AUTH_UNIX, thông tin xác thực
   được truyền qua dây sẽ được sử dụng trực tiếp làm chìa khóa trong
   gọi tới rpc.mountd. Điều này giúp đơn giản hóa quá trình xác thực và
   do đó giúp AUTH_UNIX dễ hỗ trợ hơn.

8. Các tùy chọn xuất dịch ID người dùng RPC hoạt động như thế nào cho LOCALIO
   hoạt động (ví dụ: root_squash, all_squash)?

Các tùy chọn xuất dịch ID người dùng được quản lý bởi nfsd_setuser()
   được gọi bởi nfsd_setuser_and_check_port() được gọi bởi
   __fh_verify().  Vì vậy, chúng được xử lý theo cách tương tự đối với LOCALIO
   như họ làm với không phải LOCALIO.

9. LOCALIO làm cách nào để đảm bảo rằng vòng đời của đối tượng được quản lý
   NFSD và NFS được cung cấp đúng cách có hoạt động trong các bối cảnh khác nhau không?

Xem phần "Khóa liên động máy khách và máy chủ NFS" chi tiết bên dưới.

RPC
===

Giao thức RPC phụ trợ LOCALIO bao gồm một "UUID_IS_LOCAL" duy nhất
Phương thức RPC cho phép máy khách Linux NFS xác minh Linux cục bộ
Máy chủ NFS có thể thấy nonce (UUID sử dụng một lần) mà máy khách đã tạo và
có sẵn trong nfs_common. Giao thức này không phải là một phần của IETF
tiêu chuẩn, cũng không cần phải coi đó là Linux-to-Linux
Giao thức RPC phụ trợ tương đương với chi tiết triển khai.

Phương thức UUID_IS_LOCAL mã hóa uuid_t do khách hàng tạo ra theo
UUID_SIZE cố định (16 byte). Mã hóa và giải mã mờ kích thước cố định
Các phương pháp XDR được sử dụng thay cho các phương pháp có kích thước thay đổi kém hiệu quả hơn
phương pháp.

Số chương trình RPC cho NFS_LOCALIO_PROGRAM là 400122 (như được chỉ định
bởi IANA, xem ZZ0000ZZ ):
Tổ chức hạt nhân Linux 400122 nfslocalio

Thông số giao thức LOCALIO trong cú pháp rpcgen là::

/* RFC thô 9562 UUID */
  #define UUID_SIZE 16
  typedef u8 uuid_t<UUID_SIZE>;

chương trình NFS_LOCALIO_PROGRAM {
      phiên bản LOCALIO_V1 {
          trống rỗng
              NULL(void) = 0;

trống rỗng
              UUID_IS_LOCAL(uuid_t) = 1;
      } = 1;
  } = 400122;

LOCALIO sử dụng kết nối truyền tải giống như lưu lượng NFS. Như vậy,
LOCALIO chưa được đăng ký với rpcbind.

NFS Bắt tay chung và Máy khách/Máy chủ
======================================

fs/nfs_common/nfslocalio.c cung cấp các giao diện cho phép máy khách NFS
để tạo ra một nonce (UUID sử dụng một lần) và liên quan đến thời gian tồn tại ngắn
nfs_uuid_t struct, hãy đăng ký nó với nfs_common để tra cứu tiếp theo và
xác minh bởi máy chủ NFS và nếu khớp thì máy chủ NFS sẽ xuất hiện
các thành viên trong cấu trúc nfs_uuid_t. Máy khách NFS sau đó sử dụng nfs_common để
chuyển nfs_uuid_t từ nfs_uuids của nó sang nn->nfsd_serv
client_list từ uuids_list của nfs_common.  Xem:
fs/nfs/localio.c:nfs_local_probe()

Danh sách nfs_uuids của nfs_common là cơ sở để kích hoạt LOCALIO, như vậy
nó có các thành viên trỏ đến bộ nhớ nfsd để khách hàng sử dụng trực tiếp
(ví dụ: 'net' là không gian tên mạng của máy chủ, thông qua nó, máy khách có thể
truy cập nn->nfsd_serv với quyền truy cập đọc rcu thích hợp). Đó là khách hàng này
và đồng bộ hóa máy chủ cho phép sử dụng nâng cao và kéo dài tuổi thọ của
các đối tượng trải dài từ nfsd của hạt nhân máy chủ đến knfsd trên mỗi vùng chứa
các phiên bản được kết nối với máy khách nfs đang chạy trên cùng một máy cục bộ
chủ nhà.

NFS Khóa liên động máy khách và máy chủ
===============================

LOCALIO cung cấp đối tượng nfs_uuid_t và các giao diện liên quan cho
cho phép không gian tên mạng thích hợp (net-ns) và tính toán lại đối tượng NFSD.

LOCALIO yêu cầu giới thiệu và sử dụng percpu nfsd_net_ref của NFSD
để khóa liên động nfsd_shutdown_net() và nfsd_open_local_fh(), để đảm bảo
mỗi net-ns không bị phá hủy khi được sử dụng bởi nfsd_open_local_fh() và
đảm bảo một lời giải thích chi tiết hơn:

nfsd_open_local_fh() sử dụng nfsd_net_try_get() trước khi mở nó
    nfsd_file xử lý và sau đó người gọi (máy khách NFS) phải hủy
    tham chiếu cho nfsd_file và các net-ns liên quan bằng cách sử dụng
    nfsd_file_put_local() sau khi hoàn thành IO.

Hoạt động khóa liên động này phụ thuộc rất nhiều vào việc nfsd_open_local_fh()
    có đủ khả năng để đối phó một cách an toàn với khả năng
    Net-ns của NFSD (và nfsd_net theo liên kết) có thể đã bị phá hủy
    bởi nfsd_destroy_serv() qua nfsd_shutdown_net().

Khóa liên động này của máy khách và máy chủ NFS đã được xác minh để khắc phục sự cố
dễ xảy ra sự cố nếu phiên bản NFSD chạy trong
container, có gắn máy khách LOCALIO, đang tắt. Khi khởi động lại
container và NFSD liên quan, khách hàng sẽ gặp sự cố do
tới việc vô hiệu hóa con trỏ NULL xảy ra do máy khách LOCALIO
cố gắng nfsd_open_local_fh() mà không có tài liệu tham khảo thích hợp về
Mạng của NFSD.

NFS Máy khách phát hành IO thay vì Máy chủ
======================================

Bởi vì LOCALIO tập trung vào việc bỏ qua giao thức để đạt được IO được cải thiện
hiệu suất, các lựa chọn thay thế cho giao thức dây NFS truyền thống (SUNRPC
với XDR) phải được cung cấp để truy cập hệ thống tệp sao lưu.

Xem fs/nfs/localio.c:nfs_local_open_fh() và
fs/nfsd/localio.c:nfsd_open_local_fh() cho giao diện tạo nên
tập trung sử dụng các đối tượng máy chủ nfs chọn lọc để cho phép máy khách cục bộ truy cập
máy chủ để mở con trỏ tập tin mà không cần phải truy cập mạng.

fs/nfs/localio.c:nfs_local_open_fh() của khách hàng sẽ gọi vào
fs/nfsd/localio.c:nfsd_open_local_fh() của máy chủ và truy cập cẩn thận
cả không gian tên mạng nfsd được liên kết và nn->nfsd_serv về mặt
RCU. Nếu nfsd_open_local_fh() thấy rằng máy khách không còn thấy hợp lệ
các đối tượng nfsd (có thể là struct net hoặc nn->nfsd_serv) nó trả về -ENXIO
tới nfs_local_open_fh() và máy khách sẽ cố gắng thiết lập lại
Cần có tài nguyên LOCALIO bằng cách gọi lại nfs_local_probe(). Cái này
cần khôi phục nếu/khi một phiên bản nfsd chạy trong vùng chứa bị
để khởi động lại trong khi máy khách LOCALIO được kết nối với nó.

Khi máy khách có một con trỏ nfsd_file mở, nó sẽ phát ra các lệnh đọc,
ghi và cam kết trực tiếp vào hệ thống tập tin cục bộ cơ bản (thông thường
được thực hiện bởi máy chủ nfs). Như vậy, đối với các hoạt động này, máy khách NFS
đang phát hành IO cho hệ thống tệp cục bộ cơ bản mà nó đang chia sẻ
máy chủ NFS. Xem: fs/nfs/localio.c:nfs_local_doio() và
fs/nfs/localio.c:nfs_local_commit().

Với NFS bình thường sử dụng RPC để cấp IO cho máy chủ, nếu có
ứng dụng sử dụng O_DIRECT, máy khách NFS sẽ bỏ qua bộ đệm trang nhưng
máy chủ NFS thì không. Việc sử dụng IO đệm của máy chủ NFS
các ứng dụng sẽ kém chính xác hơn với sự liên kết của chúng khi phát hành IO tới
máy khách NFS. Nhưng nếu tất cả các ứng dụng căn chỉnh IO của chúng một cách chính xác, LOCALIO
có thể được cấu hình để sử dụng ngữ nghĩa O_DIRECT từ đầu đến cuối từ NFS
client vào hệ thống tập tin cục bộ cơ bản mà nó đang chia sẻ với
máy chủ NFS, bằng cách thiết lập mô-đun nfs 'localio_O_DIRECT_semantics'
tham số cho Y, ví dụ:

echo Y > /sys/module/nfs/parameters/localio_O_DIRECT_semantics

Sau khi được bật, nó sẽ khiến LOCALIO sử dụng ngữ nghĩa O_DIRECT từ đầu đến cuối
(nhưng một lần nữa, điều này có thể khiến IO bị lỗi nếu ứng dụng không hoạt động đúng cách).
căn chỉnh IO của họ).

Bảo vệ
========

LOCALIO chỉ được hỗ trợ khi xác thực kiểu UNIX (AUTH_UNIX, hay còn gọi là
AUTH_SYS) được sử dụng.

Cần thận trọng để đảm bảo sử dụng các cơ chế bảo mật NFS tương tự
(xác thực, v.v.) bất kể LOCALIO hay NFS thông thường
quyền truy cập được sử dụng. auth_domain được thiết lập như một phần của truyền thống
Quyền truy cập của máy khách NFS vào máy chủ NFS cũng được sử dụng cho LOCALIO.

So với các container, LOCALIO cung cấp cho khách hàng quyền truy cập vào mạng
không gian tên mà máy chủ có. Điều này là cần thiết để cho phép khách hàng truy cập
cấu trúc nfsd_net trên mỗi không gian tên của máy chủ. Với NFS truyền thống,
khách hàng được cung cấp cùng mức truy cập này (mặc dù xét về NFS
giao thức thông qua SUNRPC). Không có không gian tên nào khác (người dùng, mount, v.v.) được
bị thay đổi hoặc cố ý mở rộng từ máy chủ đến máy khách.

Thông số mô-đun
=================

/sys/module/nfs/parameters/localio_enabled (bool)
kiểm soát nếu LOCALIO được bật, mặc định là Y. Nếu máy khách và máy chủ là
local nhưng 'localio_enabled' được đặt thành N thì LOCALIO sẽ không được sử dụng.

/sys/module/nfs/parameters/localio_O_DIRECT_semantics (bool)
kiểm soát nếu O_DIRECT mở rộng xuống hệ thống tệp cơ bản, mặc định
tới N. Ứng dụng IO phải được căn chỉnh theo kích thước khối hợp lý, nếu không
O_DIRECT sẽ thất bại.

/sys/module/nfsv3/parameters/nfs3_localio_probe_throttle (uint)
kiểm soát nếu các IO đọc và ghi NFSv3 sẽ kích hoạt (tái) kích hoạt
LOCALIO mỗi N (nfs3_localio_probe_throttle) IO, mặc định là 0
(bị vô hiệu hóa). Phải có sức mạnh 2, quản trị viên sẽ giữ tất cả các phần nếu chúng
cấu hình sai (giá trị quá thấp hoặc không có lũy thừa bằng 2).

Kiểm tra
=======

Giao thức phụ trợ LOCALIO và đọc, ghi NFS LOCALIO liên quan
và quyền truy cập cam kết đã được chứng minh là ổn định trước các tình huống thử nghiệm khác nhau:

- Máy khách và máy chủ đều trên cùng một máy chủ.

- Tất cả các hoán vị hỗ trợ client và server cho cả hai
  máy khách và máy chủ cục bộ và từ xa.

- Thử nghiệm với các sản phẩm lưu trữ NFS không hỗ trợ LOCALIO
  giao thức cũng đã được thực hiện.

- Máy khách trên máy chủ, máy chủ trong một container (cho cả v3 và v4.2).
  Việc thử nghiệm container dựa trên các container được quản lý bởi podman và
  bao gồm kịch bản dừng/khởi động lại container thành công.

- Chính thức hóa các kịch bản thử nghiệm này theo thử nghiệm hiện có
  cơ sở hạ tầng đang được tiến hành. Bảo hiểm thường xuyên ban đầu được cung cấp trong
  điều khoản của ktest chạy xfstests dựa trên vòng lặp NFS hỗ trợ LOCALIO
  cấu hình gắn kết và bao gồm vùng phủ sóng lockdep và KASAN, xem:
  ZZ0000ZZ
  ZZ0001ZZ

- Nhiều thử nghiệm kdevops khác nhau (theo thuật ngữ "Chuck's BuildBot") đã được thực hiện
  được thực hiện để thường xuyên xác minh các thay đổi của LOCALIO không gây ra bất kỳ
  hồi quy về các trường hợp sử dụng không phải LOCALIO NFS.

- Tất cả các bài kiểm tra độ tỉnh táo khác nhau của Hammerspace đều vượt qua khi bật LOCALIO
  (điều này bao gồm nhiều bài kiểm tra pNFS và flexfiles).
