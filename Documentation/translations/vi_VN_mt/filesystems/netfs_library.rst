.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/netfs_library.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================================
Thư viện dịch vụ hệ thống tập tin mạng
===================================

.. Contents:

 - Overview.
   - Requests and streams.
   - Subrequests.
   - Result collection and retry.
   - Local caching.
   - Content encryption (fscrypt).
 - Per-inode context.
   - Inode context helper functions.
   - Inode locking.
   - Inode writeback.
 - High-level VFS API.
   - Unlocked read/write iter.
   - Pre-locked read/write iter.
   - Monolithic files API.
   - Memory-mapped I/O API.
 - High-level VM API.
   - Deprecated PG_private2 API.
 - I/O request API.
   - Request structure.
   - Stream structure.
   - Subrequest structure.
   - Filesystem methods.
   - Terminating a subrequest.
   - Local cache API.
 - API function reference.


Tổng quan
========

Thư viện dịch vụ hệ thống tập tin mạng, netfslib, là một tập hợp các hàm
được thiết kế để hỗ trợ hệ thống tệp mạng trong việc triển khai các hoạt động VM/VFS API.  Nó
đảm nhận việc đọc, đọc trước, ghi và ghi lại trong bộ đệm thông thường và cả
xử lý I/O trực tiếp và không có bộ đệm.

Thư viện cung cấp hỗ trợ cho việc đàm phán (tái) kích thước I/O và thử lại
I/O không thành công cũng như bộ nhớ đệm cục bộ và trong tương lai sẽ cung cấp nội dung
mã hóa.

Nó cách ly hệ thống tập tin khỏi những thay đổi giao diện VM nhiều nhất có thể và
xử lý các tính năng của VM như các folio nhiều trang lớn.  Về cơ bản hệ thống tập tin
chỉ cần cung cấp một cách để thực hiện các cuộc gọi RPC đọc và ghi.

Cách tổ chức I/O bên trong netfslib bao gồm một số đối tượng:

* ZZ0000ZZ.  Một yêu cầu được sử dụng để theo dõi tiến trình chung của I/O và
   để giữ tài nguyên.  Việc thu thập kết quả được thực hiện theo yêu cầu
   cấp độ.  I/O trong một yêu cầu được chia thành nhiều cổng song song
   các luồng yêu cầu phụ.

* ZZ0000ZZ.  Một loạt các yêu cầu phụ không chồng chéo.  Các yêu cầu phụ
   trong một luồng không nhất thiết phải liền kề nhau.

* ZZ0000ZZ.  Đây là đơn vị cơ bản của I/O.  Nó đại diện cho một RPC duy nhất
   cuộc gọi hoặc một thao tác I/O bộ đệm duy nhất.  Thư viện chuyển chúng tới
   hệ thống tập tin và bộ đệm để thực hiện.

Yêu cầu và luồng
--------------------

Khi thực sự thực hiện I/O (trái ngược với việc chỉ sao chép vào bộ đệm trang),
netfslib sẽ tạo một hoặc nhiều yêu cầu để theo dõi tiến trình của I/O và
để nắm giữ tài nguyên.

Thao tác đọc sẽ có một luồng duy nhất và các yêu cầu phụ trong đó
luồng có thể có nguồn gốc hỗn hợp, ví dụ như trộn các yêu cầu phụ RPC và bộ đệm
yêu cầu phụ.

Mặt khác, một thao tác ghi có thể có nhiều luồng, trong đó mỗi luồng
luồng nhắm mục tiêu đến một đích khác.  Ví dụ: có thể có một luồng
ghi vào bộ đệm cục bộ và một vào máy chủ.  Hiện tại chỉ có hai luồng
được phép, nhưng điều này có thể tăng lên nếu ghi song song vào nhiều máy chủ
được mong muốn.

Các yêu cầu phụ trong luồng ghi không cần phải khớp với căn chỉnh hoặc kích thước
với các yêu cầu phụ trong luồng ghi khác và netfslib thực hiện việc sắp xếp
của các yêu cầu phụ trong mỗi luồng trên bộ đệm nguồn một cách độc lập.  Hơn nữa,
mỗi luồng có thể chứa các lỗ không tương ứng với các lỗ ở luồng kia
suối.

Ngoài ra, các yêu cầu phụ không cần phải tương ứng với ranh giới của
folios hoặc vectơ trong bộ đệm nguồn/đích.  Thư viện xử lý các
việc thu thập các kết quả và sự tranh cãi về các lá cờ và tài liệu tham khảo.

Yêu cầu phụ
-----------

Các yêu cầu phụ là trung tâm của sự tương tác giữa netfslib và
hệ thống tập tin sử dụng nó.  Mỗi yêu cầu phụ dự kiến sẽ tương ứng với một
đọc hoặc ghi RPC hoặc thao tác bộ đệm.  Thư viện sẽ ghép các
là kết quả của một tập hợp các yêu cầu phụ để cung cấp hoạt động ở cấp độ cao hơn.

Netfslib có hai tương tác với hệ thống tập tin hoặc bộ đệm khi thiết lập
một yêu cầu phụ.  Đầu tiên, có một bước chuẩn bị tùy chọn cho phép
hệ thống tập tin để thương lượng các giới hạn cho yêu cầu phụ, cả về mặt tối đa
số byte và số lượng vectơ tối đa (ví dụ: đối với RDMA).  Điều này có thể
liên quan đến việc đàm phán với máy chủ (ví dụ: cifs cần có được tín dụng).

Và thứ hai, có bước phát hành trong đó yêu cầu phụ được chuyển giao
vào hệ thống tập tin để thực hiện.

Lưu ý rằng hai bước này được thực hiện hơi khác nhau giữa đọc và ghi:

* Đối với số lần đọc, VM/VFS cho chúng tôi biết số lượng được yêu cầu trước, do đó
   thư viện có thể đặt trước các giá trị tối đa mà bộ đệm và sau đó hệ thống tệp có thể
   sau đó giảm đi.  Bộ đệm cũng được tư vấn trước tiên về việc nó có muốn thực hiện hay không
   đọc trước khi hệ thống tập tin được tư vấn.

* Đối với việc viết lại, không biết sẽ còn bao nhiêu để viết cho đến khi
   pagecache được di chuyển nên không có giới hạn nào được thư viện đặt ra.

Khi một yêu cầu phụ được hoàn thành, hệ thống tập tin hoặc bộ đệm sẽ thông báo cho thư viện về
việc hoàn thành và sau đó bộ sưu tập được gọi.  Tùy thuộc vào việc
yêu cầu đồng bộ hay không đồng bộ thì việc thu thập kết quả sẽ được thực hiện
trong luồng ứng dụng hoặc trong hàng đợi công việc.

Thu thập kết quả và thử lại
---------------------------

Khi các yêu cầu phụ hoàn tất, kết quả sẽ được thư viện thu thập và đối chiếu
và việc mở khóa folio được thực hiện dần dần (nếu thích hợp).  Một khi
yêu cầu hoàn tất, việc hoàn thành không đồng bộ sẽ được gọi (một lần nữa, nếu thích hợp).
Hệ thống tập tin có thể cung cấp các báo cáo tiến độ tạm thời cho
thư viện để việc mở khóa folio diễn ra sớm hơn nếu có thể.

Nếu bất kỳ yêu cầu phụ nào không thành công, netfslib có thể thử lại chúng.  Nó sẽ đợi cho đến khi tất cả
các yêu cầu phụ được hoàn thành, hãy cho hệ thống tập tin cơ hội để thử nghiệm
tài nguyên/trạng thái được yêu cầu nắm giữ và xem xét các yêu cầu phụ trước
chuẩn bị lại và ban hành lại các yêu cầu phụ.

Điều này cho phép xếp các nhóm yêu cầu phụ không thành công liền kề trong một luồng
được thay đổi, thêm nhiều yêu cầu phụ hoặc loại bỏ phần dư thừa nếu cần thiết (đối với
Ví dụ: nếu kích thước mạng thay đổi hoặc máy chủ quyết định muốn nhỏ hơn
khối).

Hơn nữa, nếu một hoặc nhiều yêu cầu phụ đọc bộ đệm liền kề không thành công, thư viện
thay vào đó sẽ chuyển chúng đến hệ thống tập tin để thực hiện, đàm phán lại và sắp xếp lại
chúng khi cần thiết để phù hợp với các tham số của hệ thống tập tin thay vì của
bộ đệm.

Bộ nhớ đệm cục bộ
-------------

Một trong những dịch vụ mà netfslib cung cấp, thông qua ZZ0000ZZ, là tùy chọn lưu vào bộ đệm
trên đĩa cục bộ một bản sao của dữ liệu thu được từ/được ghi vào hệ thống tệp mạng.
Thư viện sẽ quản lý việc lưu trữ, truy xuất và vô hiệu hóa một số dữ liệu
tự động thay mặt hệ thống tập tin nếu cookie được đính kèm vào
ZZ0001ZZ.

Lưu ý rằng bộ nhớ đệm cục bộ được sử dụng để sử dụng PG_private_2 (bí danh là PG_fscache) để
theo dõi một trang đã được ghi vào bộ nhớ đệm, nhưng bây giờ đây là
không được dùng nữa vì PG_private_2 sẽ bị xóa.

Thay vào đó, các folio được đọc từ máy chủ không có dữ liệu trong
bộ nhớ đệm sẽ bị đánh dấu là bẩn và sẽ có ZZ0000ZZ được đặt thành
giá trị đặc biệt (ZZ0001ZZ) và để lại để ghi lại.
Nếu folio được sửa đổi trước khi điều đó xảy ra, giá trị đặc biệt sẽ là
bị xóa và chữ viết sẽ trở nên bẩn bình thường.

Khi việc ghi lại xảy ra, các folio được đánh dấu như vậy sẽ chỉ được ghi vào
cache chứ không phải tới máy chủ.  Writeback xử lý việc ghi và chỉ lưu vào bộ đệm hỗn hợp
server-and-cache ghi bằng cách sử dụng hai luồng, gửi một luồng vào bộ đệm và một luồng
đến máy chủ.  Luồng máy chủ sẽ có những khoảng trống tương ứng với những khoảng trống đó
folio.

Mã hóa nội dung (fscrypt)
----------------------------

Mặc dù nó chưa làm được điều đó nhưng đến một lúc nào đó netfslib sẽ có được khả năng
để thực hiện mã hóa nội dung phía máy khách thay mặt cho hệ thống tệp mạng (Ceph,
chẳng hạn).  fscrypt có thể được sử dụng cho việc này nếu thích hợp (có thể không -
cif chẳng hạn).

Dữ liệu sẽ được lưu trữ được mã hóa trong bộ đệm cục bộ bằng cách sử dụng cùng một cách
mã hóa vì dữ liệu được ghi vào máy chủ và thư viện sẽ bị trả lại
đệm và chu trình RMW khi cần thiết.


Bối cảnh trên mỗi Inode
=================

Thư viện trợ giúp hệ thống tập tin mạng cần một nơi để lưu trữ một chút trạng thái cho
việc sử dụng nó trên mỗi inode netfs mà nó đang giúp quản lý.  Để đạt được mục đích này, một bối cảnh
cấu trúc được xác định::

cấu trúc netfs_inode {
		cấu trúc inode inode;
		const struct netfs_request_ops *ops;
		struct fscache_cookie * bộ đệm;
		loff_t remote_i_size;
		cờ dài không dấu;
		...
	};

Một hệ thống tập tin mạng muốn sử dụng netfslib phải đặt một trong những thứ này vào
cấu trúc trình bao bọc inode thay vì VFS ZZ0000ZZ.  Điều này có thể được thực hiện trong
một cách tương tự như sau ::

cấu trúc my_inode {
		cấu trúc netfs_inode netfs; /* Bối cảnh Netfslib và vfs inode */
		...
	};

Điều này cho phép netfslib tìm trạng thái của nó bằng cách sử dụng ZZ0000ZZ từ
con trỏ inode, do đó cho phép các hàm trợ giúp netfslib được trỏ tới
trực tiếp bằng bảng thao tác VFS/VM.

Cấu trúc chứa các trường sau mà người dùng quan tâm
hệ thống tập tin:

* ZZ0000ZZ

Cấu trúc nút VFS.

* ZZ0000ZZ

Tập hợp các hoạt động được hệ thống tệp mạng cung cấp cho netfslib.

* ZZ0000ZZ

Cookie bộ nhớ đệm cục bộ hoặc NULL nếu không bật bộ nhớ đệm.  Trường này không
   tồn tại nếu fscache bị vô hiệu hóa.

* ZZ0000ZZ

Kích thước của tập tin trên máy chủ.  Điều này khác với inode->i_size nếu
   sửa đổi cục bộ đã được thực hiện nhưng chưa được viết lại.

* ZZ0000ZZ

Một bộ cờ, một số trong đó hệ thống tập tin có thể quan tâm:

* ZZ0000ZZ

Đặt nếu netfslib sửa đổi mtime/ctime.  Hệ thống tập tin có thể được bỏ qua
     cái này hoặc xóa nó.

* ZZ0000ZZ

Thực hiện I/O không có bộ đệm trên tệp.  Giống như I/O trực tiếp nhưng không có
     hạn chế sắp xếp.  RMW sẽ được thực hiện nếu cần thiết.  Bộ đệm trang
     sẽ không được sử dụng trừ khi mmap() cũng được sử dụng.

* ZZ0000ZZ

Thực hiện ghi vào bộ nhớ đệm vào tập tin.  I/O sẽ được thiết lập và gửi đi
     khi ghi vào bộ đệm được thực hiện vào bộ đệm trang.  mmap() hoạt động bình thường
     điều viết lại.

* ZZ0000ZZ

Đặt xem tệp có nội dung nguyên khối phải được đọc hoàn toàn trong một
     thực hiện một lần và không được ghi lại vào máy chủ, mặc dù có thể
     được lưu vào bộ nhớ đệm (ví dụ: thư mục AFS).

Chức năng trợ giúp ngữ cảnh Inode
------------------------------

Để giúp xử lý bối cảnh trên mỗi inode, một số hàm trợ giúp được
được cung cấp.  Thứ nhất, một hàm để thực hiện khởi tạo cơ bản trên một ngữ cảnh và
đặt con trỏ bảng thao tác::

void netfs_inode_init(struct netfs_inode *ctx,
			      const struct netfs_request_ops *ops);

sau đó là một hàm để chuyển từ cấu trúc inode VFS sang ngữ cảnh netfs ::

cấu trúc netfs_inode *netfs_inode(struct inode *inode);

và cuối cùng là hàm lấy con trỏ cookie bộ đệm từ ngữ cảnh
được gắn vào một inode (hoặc NULL nếu fscache bị tắt)::

cấu trúc fscache_cookie *netfs_i_cookie(struct netfs_inode *ctx);

Khóa Inode
-------------

Một số chức năng được cung cấp để quản lý việc khóa i_rwsem cho I/O và
để mở rộng nó một cách hiệu quả nhằm cung cấp nhiều lớp loại trừ riêng biệt hơn::

int netfs_start_io_read(struct inode *inode);
	void netfs_end_io_read(struct inode *inode);
	int netfs_start_io_write(struct inode *inode);
	void netfs_end_io_write(struct inode *inode);
	int netfs_start_io_direct(struct inode *inode);
	void netfs_end_io_direct(struct inode *inode);

Việc loại trừ được chia thành bốn lớp riêng biệt:

1) Đọc và ghi vào bộ đệm.

Các lần đọc vào bộ đệm có thể chạy đồng thời với nhau và với việc ghi vào bộ đệm,
    nhưng việc ghi vào bộ đệm không thể chạy đồng thời với nhau.

2) Đọc và ghi trực tiếp.

Việc đọc và ghi trực tiếp (và không có bộ đệm) có thể chạy đồng thời vì chúng thực hiện
    không chia sẻ bộ đệm cục bộ (tức là pagecache) và trong mạng
    hệ thống tập tin, dự kiến sẽ có quản lý loại trừ trên máy chủ (mặc dù
    điều này có thể không đúng với Ceph).

3) Các hoạt động sửa đổi inode chính khác (ví dụ: cắt ngắn, sai số).

Chúng chỉ nên truy cập trực tiếp vào i_rwsem.

4) mmap().

quyền truy cập mmap'd có thể hoạt động đồng thời với bất kỳ lớp nào khác.
    Chúng có thể tạo thành bộ đệm cho việc đọc/ghi vòng lặp DIO trong nội bộ tệp.  Họ
    có thể được cho phép trên các tập tin không có bộ đệm.

Viết lại Inode
---------------

Netfslib sẽ ghim tài nguyên vào một nút để ghi lại trong tương lai (chẳng hạn như ghim
sử dụng cookie fscache) khi inode bị bẩn.  Tuy nhiên, việc ghim này
cần quản lý cẩn thận.  Để quản lý việc ghim, trình tự sau
xảy ra:

1) Cờ trạng thái inode ZZ0000ZZ được đặt bởi netfslib khi
    quá trình ghim bắt đầu (ví dụ: khi một folio bị bẩn) nếu bộ nhớ đệm bị
    hoạt động để ngăn chặn các cấu trúc bộ đệm bị loại bỏ và bộ đệm
    không gian khỏi bị loại bỏ.  Điều này cũng ngăn chặn việc lấy lại tài nguyên bộ đệm
    nếu cờ đã được đặt.

2) Cờ này sau đó sẽ bị xóa bên trong khóa inode trong quá trình ghi lại inode trong
    VM - và thực tế là nó đã được thiết lập sẽ được chuyển sang ZZ0000ZZ
    trong ZZ0001ZZ.

3) Nếu ZZ0000ZZ hiện được đặt, thủ tục write_inode bị bắt buộc.

4) Hàm ZZ0000ZZ của hệ thống tập tin được gọi để thực hiện việc dọn dẹp.

5) Hệ thống tập tin gọi netfs để dọn dẹp nó.

Để thực hiện việc dọn dẹp, netfslib cung cấp một chức năng để thực hiện việc bỏ ghim tài nguyên ::

int netfs_unpin_writeback(struct inode *inode, struct writeback_control *wbc);

Nếu hệ thống tập tin không cần làm gì khác, điều này có thể được đặt làm
Phương pháp ZZ0000ZZ.

Hơn nữa, nếu một inode bị xóa, phương thức write_inode của hệ thống tập tin có thể không
được gọi, vì vậy::

void netfs_clear_inode_writeback(struct inode *inode, const void *aux);

phải được gọi từ ZZ0000ZZ ZZ0002ZZ ZZ0001ZZ được gọi.


VFS API cấp cao
==================

Netfslib cung cấp một số bộ lệnh gọi API để hệ thống tệp ủy quyền
VFS hoạt động tới.  Ngược lại, Netfslib sẽ gọi hệ thống tập tin và
bộ đệm để đàm phán kích thước I/O, phát hành RPC và cung cấp địa điểm để nó can thiệp
vào những thời điểm khác nhau.

Đã mở khóa Đọc/Ghi Iter
------------------------

Bộ API đầu tiên dành cho việc ủy quyền hoạt động cho netfslib khi
hệ thống tập tin được gọi thông qua các phương thức đọc/ghi_iter VFS tiêu chuẩn ::

ssize_t netfs_file_read_iter(struct kiocb *iocb, struct iov_iter *iter);
	ssize_t netfs_file_write_iter(struct kiocb *iocb, struct iov_iter *from);
	ssize_t netfs_buffered_read_iter(struct kiocb *iocb, struct iov_iter *iter);
	ssize_t netfs_unbuffered_read_iter(struct kiocb *iocb, struct iov_iter *iter);
	ssize_t netfs_unbuffered_write_iter(struct kiocb *iocb, struct iov_iter *from);

Chúng có thể được gán trực tiếp cho ZZ0000ZZ và ZZ0001ZZ.  Họ
tự khóa inode và hai nút đầu tiên sẽ chuyển đổi giữa
I/O đệm và DIO nếu thích hợp.

Lặp lại đọc/ghi được khóa trước
--------------------------

Bộ API thứ hai dành cho việc ủy quyền hoạt động cho netfslib khi
hệ thống tập tin được gọi thông qua các phương thức VFS tiêu chuẩn, nhưng cần thực hiện một số
những thứ khác trước hoặc sau khi gọi netfslib trong khi vẫn ở trong phần bị khóa
(ví dụ: giới hạn đàm phán của Ceph).  Chức năng đọc không có bộ đệm là::

ssize_t netfs_unbuffered_read_iter_locked(struct kiocb *iocb, struct iov_iter *iter);

Điều này không được gán trực tiếp cho ZZ0000ZZ và hệ thống tập tin được
chịu trách nhiệm thực hiện khóa inode trước khi gọi nó.  Trong trường hợp của
đọc vào bộ đệm, hệ thống tập tin nên sử dụng ZZ0001ZZ.

Có ba chức năng để viết::

ssize_t netfs_buffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *from,
						 cấu trúc netfs_group *netfs_group);
	ssize_t netfs_perform_write(struct kiocb *iocb, struct iov_iter *iter,
				    cấu trúc netfs_group *netfs_group);
	ssize_t netfs_unbuffered_write_iter_locked(struct kiocb *iocb, struct iov_iter *iter,
						   cấu trúc netfs_group *netfs_group);

Chúng không được gán trực tiếp cho ZZ0000ZZ và hệ thống tập tin được
chịu trách nhiệm thực hiện khóa inode trước khi gọi chúng.

Hai chức năng đầu tiên dành cho việc ghi vào bộ đệm; đầu tiên chỉ thêm một số
kiểm tra ghi tiêu chuẩn và nhảy sang giây, nhưng nếu hệ thống tập tin muốn
tự mình kiểm tra, nó có thể sử dụng trực tiếp lần thứ hai.  Chức năng thứ ba là
để ghi không có bộ đệm hoặc DIO.

Trên cả ba hàm ghi đều có một con trỏ nhóm writeback (cần
là NULL nếu hệ thống tập tin không sử dụng cái này).  Nhóm Writeback được thiết lập trên
folios khi chúng được sửa đổi.  Nếu một folio cần sửa đổi đã được đánh dấu bằng
một nhóm khác, nó sẽ bị xóa trước.  Writeback API cho phép viết lại
của một nhóm cụ thể.

I/O được ánh xạ bộ nhớ API
---------------------

API để hỗ trợ I/O của mmap() được cung cấp ::

vm_fault_t netfs_page_mkwrite(struct vm_fault *vmf, struct netfs_group *netfs_group);

Điều này cho phép hệ thống tập tin ủy quyền ZZ0000ZZ cho netfslib.  các
hệ thống tập tin không nên khóa inode trước khi gọi nó, nhưng, cũng như với
các hàm ghi bị khóa ở trên, việc này cần có một con trỏ nhóm ghi lại.  Nếu
trang được đặt ở chế độ có thể ghi nằm trong một nhóm khác, nó sẽ bị xóa trước tiên.

Tập tin nguyên khối API
--------------------

Ngoài ra còn có một bộ API đặc biệt dành cho các tệp mà nội dung phải được đọc trong đó.
một RPC duy nhất (và không được viết lại) và được duy trì dưới dạng một khối nguyên khối
(ví dụ: thư mục AFS), mặc dù nó có thể được lưu trữ và cập nhật trong bộ đệm cục bộ ::

ssize_t netfs_read_single(struct inode *inode, struct file *file, struct iov_iter *iter);
	void netfs_single_mark_inode_dirty(struct inode *inode);
	int netfs_writeback_single(struct address_space *mapping,
				   cấu trúc writeback_control *wbc,
				   cấu trúc iov_iter *iter);

Hàm đầu tiên đọc từ một tập tin vào bộ đệm đã cho, đọc từ
ưu tiên bộ đệm nếu dữ liệu được lưu trong bộ nhớ đệm ở đó; chức năng thứ hai cho phép
inode bị đánh dấu bẩn, gây ra lỗi viết lại sau này; và chức năng thứ ba có thể
được gọi từ mã ghi lại để ghi dữ liệu vào bộ đệm, nếu có
một.

Inode phải được đánh dấu là ZZ0000ZZ nếu API này được sử dụng
đã sử dụng.  Chức năng ghi lại yêu cầu bộ đệm phải thuộc loại ITER_FOLIOQ.

VM cấp cao API
==================

Netfslib cũng cung cấp một số tập lệnh gọi API cho hệ thống tệp để
ủy quyền các hoạt động VM cho.  Một lần nữa, netfslib sẽ lần lượt gọi ra
hệ thống tập tin và bộ đệm để đàm phán kích thước I/O, phát hành RPC và cung cấp địa điểm
để nó can thiệp vào nhiều thời điểm khác nhau::

void netfs_readahead(struct readahead_control *);
	int netfs_read_folio(tệp cấu trúc ZZ0000ZZ);
	int netfs_writepages(struct address_space *mapping,
			     cấu trúc writeback_control *wbc);
	bool netfs_dirty_folio(struct address_space *mapping, struct folio *folio);
	void netfs_invalidate_folio(struct folio *folio, offset size_t, size_t length);
	bool netfs_release_folio(struct folio *folio, gfp_t gfp);

Đây là các phương pháp ZZ0000ZZ và có thể được đặt trực tiếp trong
bảng thao tác.

PG_private_2 API không được dùng nữa
---------------------------

Ngoài ra còn có một chức năng không được dùng nữa cho các hệ thống tập tin vẫn sử dụng
Phương pháp ZZ0000ZZ::

int netfs_write_begin(struct netfs_inode *inode, struct file *file,
			      struct address_space *ánh xạ, loff_t pos, unsigned int len,
			      cấu trúc folio **_folio, void **_fsdata);

Nó sử dụng cờ PG_private_2 không được dùng nữa và do đó không nên sử dụng.


Yêu cầu I/O API
===============

Yêu cầu I/O API bao gồm một số cấu trúc và một số chức năng
mà hệ thống tập tin có thể cần sử dụng.

Cấu trúc yêu cầu
-----------------

Cấu trúc yêu cầu quản lý toàn bộ yêu cầu, nắm giữ một số tài nguyên
và thay mặt hệ thống tập tin tuyên bố và theo dõi việc thu thập kết quả ::

cấu trúc netfs_io_request {
		nguồn gốc enum netfs_io_origin;
		cấu trúc inode * inode;
		struct address_space *ánh xạ;
		cấu trúc netfs_group *nhóm;
		cấu trúc netfs_io_stream io_streams[];
		void *netfs_priv;
		void *netfs_priv2;
		không dấu dài bắt đầu;
		len dài không dấu;
		i_size dài không dấu;
		unsigned int debug_id;
		cờ dài không dấu;
		...
	};

Nhiều trường được sử dụng nội bộ, nhưng các trường hiển thị ở đây là của
quan tâm đến hệ thống tập tin:

* ZZ0000ZZ

Nguồn gốc của yêu cầu (readahead, read_folio, DIO read, writeback, ...).

* ZZ0000ZZ
 * ZZ0001ZZ

Inode và không gian địa chỉ của tệp đang được đọc từ đó.  Bản đồ
   có thể trỏ tới inode->i_data hoặc không.

* ZZ0000ZZ

Nhóm phản hồi mà yêu cầu này đang xử lý hoặc NULL.  Điều này giữ một ref
   trên nhóm.

* ZZ0000ZZ

Các luồng yêu cầu phụ song song có sẵn cho yêu cầu.  Hiện nay hai
   có sẵn, nhưng điều này có thể được mở rộng trong tương lai.  ZZ0000ZZ
   cho biết kích thước của mảng.

* ZZ0000ZZ
 * ZZ0001ZZ

Dữ liệu riêng tư của hệ thống tập tin mạng.  Giá trị của điều này có thể được chuyển vào
   đến các chức năng trợ giúp hoặc được đặt trong khi yêu cầu.

* ZZ0000ZZ
 * ZZ0001ZZ

Vị trí tệp bắt đầu yêu cầu đọc và độ dài.  Những cái này
   có thể được thay đổi bởi ->expand_readahead() op.

* ZZ0000ZZ

Kích thước của tập tin khi bắt đầu yêu cầu.

* ZZ0000ZZ

Một số được phân bổ cho thao tác này có thể được hiển thị trong các dòng dấu vết
   để tham khảo.

* ZZ0000ZZ

Cờ để quản lý và kiểm soát hoạt động của yêu cầu.  Một số
   những điều này có thể được hệ thống tập tin quan tâm:

* ZZ0000ZZ

Netfslib đặt điều này khi tạo lần thử lại.

* ZZ0000ZZ

Hệ thống tập tin có thể đặt điều này để yêu cầu tạm dừng yêu cầu phụ của thư viện
     vòng lặp phát hành - nhưng cần phải cẩn thận vì netfslib cũng có thể thiết lập nó.

* ZZ0000ZZ
   * ZZ0001ZZ

Netfslib đặt tùy chọn đầu tiên để chỉ ra rằng chế độ không chặn đã được đặt bởi
     người gọi và hệ thống tập tin có thể đặt thứ hai để cho biết rằng nó sẽ
     đã phải chặn.

* ZZ0000ZZ

Hệ thống tập tin có thể thiết lập điều này nếu muốn sử dụng PG_private_2 để theo dõi
     liệu một folio có được ghi vào bộ đệm hay không.  Điều này không được dùng nữa vì
     PG_private_2 sắp biến mất.

Nếu hệ thống tập tin muốn có nhiều dữ liệu riêng tư hơn mức mà cấu trúc này cung cấp,
sau đó nó sẽ bọc nó và cung cấp bộ cấp phát riêng.

Cấu trúc luồng
----------------

Một yêu cầu bao gồm một hoặc nhiều luồng song song và mỗi luồng có thể
nhằm vào một mục tiêu khác.

Đối với các yêu cầu đọc, chỉ luồng 0 được sử dụng.  Chất này có thể chứa hỗn hợp
các yêu cầu phụ nhắm vào các nguồn khác nhau.  Đối với yêu cầu ghi, luồng 0 được sử dụng
cho máy chủ và luồng 1 được sử dụng cho bộ đệm.  Để ghi lại vào bộ đệm,
luồng 0 không được bật trừ khi gặp phải một folio bẩn thông thường, tại đó
point ->begin_writeback() sẽ được gọi và hệ thống tập tin có thể đánh dấu
luồng có sẵn.

Cấu trúc luồng trông giống như::

cấu trúc netfs_io_stream {
		ký tự không dấu dòng_nr;
		bool tận dụng;
		size_t sreq_max_len;
		sreq_max_segs int không dấu;
		unsigned int submit_extendable_to;
		...
	};

Một số thành viên có sẵn để hệ thống tập tin truy cập/sử dụng:

* ZZ0000ZZ

Số lượng luồng trong yêu cầu.

* ZZ0000ZZ

Đúng nếu luồng có sẵn để sử dụng.  Hệ thống tập tin nên đặt cái này trên
   luồng 0 nếu ở ->begin_writeback().

* ZZ0000ZZ
 * ZZ0001ZZ

Chúng được thiết lập bởi hệ thống tập tin hoặc bộ đệm trong ->prepare_read() hoặc
   ->prepare_write() cho mỗi yêu cầu phụ để cho biết số lượng tối đa
   byte và, tùy chọn, số lượng phân đoạn tối đa (nếu không phải 0) mà
   yêu cầu phụ có thể hỗ trợ.

* ZZ0000ZZ

Kích thước mà một yêu cầu phụ có thể được làm tròn lên vượt quá EOF, dựa trên
   bộ đệm có sẵn.  Điều này cho phép bộ đệm hoạt động nếu nó có thể đọc DIO
   hoặc viết nằm trên điểm đánh dấu EOF.

Cấu trúc yêu cầu phụ
--------------------

Các đơn vị I/O riêng lẻ được quản lý theo cấu trúc yêu cầu phụ.  Những cái này
đại diện cho các phần của yêu cầu tổng thể và chạy độc lập ::

cấu trúc netfs_io_subrequest {
		struct netfs_io_request *rreq;
		cấu trúc iov_iter io_iter;
		không dấu dài bắt đầu;
		size_t len;
		size_t đã chuyển;
		cờ dài không dấu;
		lỗi ngắn;
		debug_index ngắn không dấu;
		ký tự không dấu dòng_nr;
		...
	};

Mỗi yêu cầu phụ dự kiến sẽ truy cập vào một nguồn duy nhất, mặc dù thư viện sẽ
xử lý việc rơi trở lại từ loại nguồn này sang loại nguồn khác.  Các thành viên là:

* ZZ0000ZZ

Một con trỏ tới yêu cầu đọc.

* ZZ0000ZZ

Một trình vòng lặp I/O đại diện cho một phần của bộ đệm được đọc vào hoặc
   được viết từ.

* ZZ0000ZZ
 * ZZ0001ZZ

Vị trí tập tin bắt đầu phần này của yêu cầu đọc và
   chiều dài.

* ZZ0000ZZ

Lượng dữ liệu được truyền cho đến nay cho yêu cầu phụ này.  Điều này nên được
   được cộng thêm vào thời gian chuyển nhượng được thực hiện bởi đợt phát hành này
   yêu cầu phụ.  Nếu giá trị này nhỏ hơn ZZ0000ZZ thì yêu cầu phụ có thể là
   phát hành lại để tiếp tục.

* ZZ0000ZZ

Cờ để quản lý yêu cầu phụ.  Có một số mối quan tâm đối với
   hệ thống tập tin hoặc bộ đệm:

* ZZ0000ZZ

Được đặt bởi hệ thống tệp để cho biết rằng ít nhất một byte dữ liệu đã được đọc
     hoặc được viết.

* ZZ0000ZZ

Hệ thống tập tin sẽ thiết lập điều này nếu một lần đọc chạm vào EOF trên tập tin (trong đó
     trường hợp ZZ0000ZZ nên dừng ở EOF).  Netfslib có thể mở rộng
     yêu cầu phụ theo kích thước của folio chứa EOF ở bên ngoài
     có khả năng xảy ra thay đổi của bên thứ ba hoặc việc đọc DIO có thể đã được yêu cầu
     nhiều hơn những gì có sẵn.  Thư viện sẽ xóa mọi bộ đệm trang dư thừa.

* ZZ0000ZZ

Hệ thống tập tin có thể thiết lập điều này để chỉ ra rằng phần còn lại của lát cắt,
     từ chuyển sang len, cần được xóa.  Không đặt nếu HIT_EOF được đặt.

* ZZ0000ZZ

Hệ thống tập tin có thể thiết lập điều này để yêu cầu netfslib thử lại yêu cầu phụ.

* ZZ0000ZZ

Điều này có thể được hệ thống tập tin thiết lập trên một yêu cầu phụ để cho biết rằng nó kết thúc
     tại ranh giới với cấu trúc hệ thống tập tin (ví dụ: ở cuối Ceph
     đối tượng).  Nó yêu cầu netfslib không gửi lại các yêu cầu phụ trên đó.

* ZZ0000ZZ

Điều này là để hệ thống tập tin lưu trữ kết quả của yêu cầu phụ.  Nó nên như vậy
   được đặt thành 0 nếu thành công và mã lỗi âm nếu ngược lại.

* ZZ0000ZZ
 * ZZ0001ZZ

Một số được phân bổ cho lát cắt này có thể được hiển thị dưới dạng các dòng vết cho
   tham chiếu và số lượng luồng yêu cầu mà nó thuộc về.

Nếu cần, hệ thống tập tin có thể nhận và đặt thêm các tham chiếu cho yêu cầu phụ đó
đã cho::

void netfs_get_subrequest(struct netfs_io_subrequest *subreq,
				  enum netfs_sreq_ref_trace cái gì);
	void netfs_put_subrequest(struct netfs_io_subrequest *subreq,
				  enum netfs_sreq_ref_trace cái gì);

sử dụng mã theo dõi netfs để cho biết lý do.  Tuy nhiên cần phải cẩn thận,
vì khi quyền kiểm soát yêu cầu phụ được trả về netfslib, yêu cầu phụ tương tự
có thể được phát hành lại/thử lại.

Phương pháp hệ thống tập tin
------------------

Hệ thống tập tin thiết lập một bảng hoạt động trong ZZ0000ZZ cho netfslib để
sử dụng::

cấu trúc netfs_request_ops {
		mempool_t *request_pool;
		mempool_t *subrequest_pool;
		int (*init_request)(struct netfs_io_request *rreq, tệp cấu trúc *tệp);
		khoảng trống (*free_request)(struct netfs_io_request *rreq);
		khoảng trống (*free_subrequest)(struct netfs_io_subrequest *rreq);
		khoảng trống (*expand_readahead)(struct netfs_io_request *rreq);
		int (*prepare_read)(struct netfs_io_subrequest *subreq);
		khoảng trống (*issue_read)(struct netfs_io_subrequest *subreq);
		khoảng trống (*done)(struct netfs_io_request *rreq);
		khoảng trống (*update_i_size)(struct inode *inode, loff_t i_size);
		khoảng trống (*post_modify)(struct inode *inode);
		khoảng trống (*begin_writeback)(struct netfs_io_request *wreq);
		khoảng trống (*prepare_write)(struct netfs_io_subrequest *subreq);
		khoảng trống (*issue_write)(struct netfs_io_subrequest *subreq);
		khoảng trống (*retry_request)(struct netfs_io_request *wreq,
				      cấu trúc netfs_io_stream *stream);
		khoảng trống (*invalidate_cache)(struct netfs_io_request *wreq);
	};

Bảng bắt đầu bằng một cặp con trỏ tùy chọn tới vùng bộ nhớ mà từ đó
yêu cầu và yêu cầu phụ có thể được phân bổ.  Nếu những thứ này không được đưa ra, netfslib
có nhóm mặc định mà nó sẽ sử dụng thay thế.  Nếu hệ thống tập tin bao bọc netfs
structs trong các cấu trúc lớn hơn của chính nó, thì nó sẽ cần sử dụng các nhóm riêng của nó.
Netfslib sẽ phân bổ trực tiếp từ các nhóm.

Các phương thức được xác định trong bảng là:

* ZZ0000ZZ
 * ZZ0001ZZ
 * ZZ0002ZZ

[Tùy chọn] Hệ thống tập tin có thể triển khai những điều này để khởi tạo hoặc dọn sạch mọi
   tài nguyên mà nó đính kèm vào yêu cầu hoặc yêu cầu phụ.

* ZZ0000ZZ

[Tùy chọn] Điều này được gọi để cho phép hệ thống tập tin mở rộng kích thước của một
   yêu cầu đọc trước.  Hệ thống tập tin sẽ mở rộng yêu cầu trong cả hai
   hướng, mặc dù nó phải giữ lại vùng ban đầu vì nó có thể đại diện cho
   sự phân bổ đã được thực hiện.  Nếu bộ nhớ đệm cục bộ được bật, nó sẽ mở rộng
   yêu cầu đầu tiên.

Việc mở rộng được truyền đạt bằng cách thay đổi ->start và ->len trong yêu cầu
   cấu trúc.  Lưu ý rằng nếu có bất kỳ thay đổi nào được thực hiện, ->len phải được tăng lên ở mức
   ít nhất là ->bắt đầu giảm.

* ZZ0000ZZ

[Tùy chọn] Điều này được gọi để cho phép hệ thống tập tin giới hạn kích thước của một
   yêu cầu phụ.  Nó cũng có thể giới hạn số vùng riêng lẻ trong iterator,
   chẳng hạn như yêu cầu của RDMA.  Thông tin này phải được đặt trên luồng số 0 trong::

rreq->io_streams[0].sreq_max_len
	rreq->io_streams[0].sreq_max_segs

Ví dụ, hệ thống tập tin có thể sử dụng điều này để cắt nhỏ một yêu cầu phải
   được chia thành nhiều máy chủ hoặc để thực hiện nhiều lần đọc.

Số 0 sẽ được trả về nếu thành công và nếu không thì sẽ có mã lỗi.

* ZZ0000ZZ

[Bắt buộc] Netfslib gọi điều này để gửi yêu cầu phụ tới máy chủ cho
   đọc.  Trong yêu cầu phụ, ->start, ->len và ->transferred cho biết nội dung gì
   dữ liệu phải được đọc từ máy chủ và ->io_iter cho biết bộ đệm được
   đã sử dụng.

Không có giá trị trả về; chức năng ZZ0000ZZ
   nên được gọi để chỉ ra rằng yêu cầu phụ đã hoàn thành theo một trong hai cách.
   ->lỗi, ->đã chuyển và ->cờ phải được cập nhật trước khi hoàn tất.  các
   việc chấm dứt có thể được thực hiện không đồng bộ.

Lưu ý: hệ thống tập tin không được xử lý việc cài đặt cập nhật folios, mở khóa
   họ hoặc loại bỏ các giới thiệu của họ - thư viện giải quyết vấn đề này vì nó có thể phải làm như vậy
   ghép các kết quả của nhiều yêu cầu phụ chồng chéo lên nhau
   bộ folio.

* ZZ0000ZZ

[Tùy chọn] Lệnh này được gọi sau khi tất cả các folio trong yêu cầu đọc đã được
   đã được mở khóa (và được đánh dấu cập nhật nếu có).

* ZZ0000ZZ

[Tùy chọn] Điều này được netfslib gọi ở nhiều thời điểm khác nhau trong quá trình ghi
   đường dẫn để yêu cầu hệ thống tệp cập nhật ý tưởng về kích thước tệp.  Nếu không
   được cung cấp, netfslib sẽ đặt i_size và i_blocks và cập nhật bộ đệm cục bộ
   bánh quy.
   
* ZZ0000ZZ

[Tùy chọn] Điều này được gọi sau khi netfslib ghi vào bộ đệm trang hoặc khi nó
   cho phép một trang mmap'd được đánh dấu là có thể ghi.
   
* ZZ0000ZZ

[Tùy chọn] Netfslib gọi điều này khi xử lý yêu cầu viết lại nếu nó
   tìm thấy một trang bẩn không được đánh dấu đơn giản là NETFS_FOLIO_COPY_TO_CACHE,
   cho biết nó phải được ghi vào máy chủ.  Điều này cho phép hệ thống tập tin
   chỉ thiết lập tài nguyên ghi lại khi nó biết nó sẽ phải thực hiện
   một bài viết.
   
* ZZ0000ZZ

[Tùy chọn] Điều này được gọi để cho phép hệ thống tập tin giới hạn kích thước của một
   yêu cầu phụ.  Nó cũng có thể giới hạn số vùng riêng lẻ trong iterator,
   chẳng hạn như yêu cầu của RDMA.  Thông tin này phải được đặt trên luồng mà
   yêu cầu phụ thuộc về::

rreq->io_streams[subreq->stream_nr].sreq_max_len
	rreq->io_streams[subreq->stream_nr].sreq_max_segs

Ví dụ, hệ thống tập tin có thể sử dụng điều này để cắt nhỏ một yêu cầu phải
   được chia ra trên nhiều máy chủ hoặc để thực hiện nhiều thao tác ghi.

Điều này không được phép trả lại một lỗi.  Thay vào đó, trong trường hợp thất bại,
   ZZ0000ZZ phải được gọi.

* ZZ0000ZZ

[Bắt buộc] Điều này được sử dụng để gửi yêu cầu phụ đến máy chủ để viết.
   Trong yêu cầu phụ, ->start, ->len và ->transferred cho biết dữ liệu nào
   nên được ghi vào máy chủ và ->io_iter cho biết bộ đệm sẽ được
   đã sử dụng.

Không có giá trị trả về; chức năng ZZ0000ZZ
   nên được gọi để chỉ ra rằng yêu cầu phụ đã hoàn thành theo một trong hai cách.
   ->lỗi, ->đã chuyển và ->cờ phải được cập nhật trước khi hoàn tất.  các
   việc chấm dứt có thể được thực hiện không đồng bộ.

Lưu ý: hệ thống tập tin không được xử lý việc loại bỏ các phần bẩn hoặc ghi lại
   đánh dấu trên các tờ giấy có liên quan đến hoạt động và không được lấy điểm hoặc ghim
   trên chúng, nhưng nên để lại quyền lưu giữ cho netfslib.

* ZZ0000ZZ

[Tùy chọn] Netfslib gọi điều này khi bắt đầu chu kỳ thử lại.  Cái này
   cho phép hệ thống tập tin kiểm tra trạng thái của yêu cầu, các yêu cầu phụ
   trong luồng được chỉ định và dữ liệu của chính nó và thực hiện các điều chỉnh hoặc
   đàm phán lại các nguồn lực.
   
* ZZ0000ZZ

[Tùy chọn] Điều này được netfslib gọi để vô hiệu hóa dữ liệu được lưu trữ trong máy cục bộ
   bộ nhớ đệm trong trường hợp việc ghi vào bộ nhớ đệm cục bộ không thành công, việc cung cấp các bản cập nhật
   dữ liệu mạch lạc mà netfs không thể cung cấp.

Chấm dứt yêu cầu phụ
------------------------

Khi một yêu cầu phụ hoàn thành, có một số chức năng mà bộ đệm hoặc
yêu cầu phụ có thể gọi để thông báo cho netfslib về sự thay đổi trạng thái.  Một chức năng là
được cung cấp để chấm dứt yêu cầu viết ở giai đoạn chuẩn bị và hành động
đồng bộ:

* ZZ0000ZZ

Cho biết lệnh gọi ->prepare_write() không thành công.  Trường ZZ0000ZZ sẽ
   đã được cập nhật.

Lưu ý rằng ->prepare_read() có thể trả về lỗi vì quá trình đọc có thể bị hủy bỏ.
Xử lý lỗi viết lại phức tạp hơn.

Các chức năng khác được sử dụng cho các yêu cầu phụ đã được ban hành:

* ZZ0000ZZ

Báo cho netfslib biết rằng yêu cầu đọc phụ đã chấm dứt.  ZZ0000ZZ,
   Các trường ZZ0001ZZ và ZZ0002ZZ phải được cập nhật.

* ZZ0000ZZ

Báo cho netfslib biết rằng yêu cầu phụ ghi đã chấm dứt.  Hoặc số lượng
   dữ liệu đã được xử lý hoặc mã lỗi âm có thể được truyền vào. Đây là
   có thể được sử dụng như một chức năng hoàn thành kiocb.

* ZZ0000ZZ

Điều này được cung cấp để cập nhật tùy chọn netfslib theo tiến trình gia tăng
   của một lần đọc, cho phép một số folio được mở khóa sớm và không thực sự
   chấm dứt yêu cầu phụ.  Trường ZZ0000ZZ lẽ ra phải có
   được cập nhật.

Bộ đệm cục bộ API
---------------

Netfslib cung cấp một API riêng để triển khai bộ đệm cục bộ, mặc dù nó
cung cấp một số quy trình tương tự như yêu cầu hệ thống tập tin API.

Đầu tiên, đối tượng netfs_io_request chứa một nơi để bộ đệm treo
tiểu bang::

cấu trúc netfs_cache_resource {
		const struct netfs_cache_ops *ops;
		void *cache_priv;
		void *cache_priv2;
		unsigned int debug_id;
		int unsign inval_counter;
	};

Nó chứa một con trỏ bảng thao tác và hai con trỏ riêng cộng với
ID gỡ lỗi của cookie fscache cho mục đích theo dõi và bộ đếm vô hiệu
được điều chỉnh bằng các lệnh gọi đến ZZ0000ZZ cho phép yêu cầu bộ nhớ đệm phụ
sẽ bị vô hiệu sau khi hoàn thành.

Bảng thao tác bộ nhớ đệm trông như sau::

cấu trúc netfs_cache_ops {
		khoảng trống (*end_operation)(struct netfs_cache_resources *cres);
		khoảng trống (*expand_readahead)(struct netfs_cache_resources *cres,
					 loff_t *_start, size_t *_len, loff_t i_size);
		enum netfs_io_source (*prepare_read)(struct netfs_io_subrequest *subreq,
						     loff_t i_size);
		int (*read)(struct netfs_cache_resources *cres,
			    loff_t bắt đầu_pos,
			    cấu trúc iov_iter *iter,
			    bool seek_data,
			    netfs_io_terminated_t term_func,
			    void *term_func_priv);
		khoảng trống (*prepare_write_subreq)(struct netfs_io_subrequest *subreq);
		khoảng trống (*issue_write)(struct netfs_io_subrequest *subreq);
	};

Với con trỏ hàm xử lý chấm dứt::

khoảng trống typedef (*netfs_io_terminated_t)(void *priv,
					      ssize_t đã chuyển_or_error,
					      bool was_async);

Các phương thức được xác định trong bảng là:

* ZZ0000ZZ

[Bắt buộc] Được gọi để dọn sạch tài nguyên khi kết thúc yêu cầu đọc.

* ZZ0000ZZ

[Tùy chọn] Được gọi khi bắt đầu thao tác đọc trước để cho phép
   cache để mở rộng yêu cầu theo một trong hai hướng.  Điều này cho phép bộ nhớ đệm
   kích thước yêu cầu một cách thích hợp cho mức độ chi tiết của bộ đệm.

* ZZ0000ZZ

[Bắt buộc] Được gọi để định cấu hình phần tiếp theo của yêu cầu.  -> bắt đầu và
   ->len trong yêu cầu phụ cho biết vị trí và mức độ lớn của lát cắt tiếp theo;
   bộ đệm sẽ giảm độ dài để phù hợp với yêu cầu về độ chi tiết của nó.

Hàm được truyền con trỏ tới điểm bắt đầu và độ dài trong các tham số của nó,
   cộng với kích thước của tệp để tham khảo và điều chỉnh phần bắt đầu và độ dài
   một cách thích hợp.  Nó sẽ trả về một trong:

* ZZ0000ZZ
   * ZZ0001ZZ
   * ZZ0002ZZ
   * ZZ0003ZZ

để cho biết liệu lát cắt đó có nên được xóa hay không
   được tải xuống từ máy chủ hoặc đọc từ bộ đệm - hoặc cắt lát
   nên từ bỏ ở thời điểm hiện tại.

* ZZ0000ZZ

[Bắt buộc] Được gọi để đọc từ bộ đệm.  Phần bù tập tin bắt đầu được đưa ra
   cùng với một trình vòng lặp để đọc, nó cũng cung cấp độ dài.  Nó có thể
   đưa ra một gợi ý yêu cầu nó tiến về phía trước từ vị trí bắt đầu đó cho
   dữ liệu.

Cũng được cung cấp một con trỏ tới hàm xử lý chấm dứt và riêng tư
   dữ liệu cần truyền tới hàm đó.  Hàm kết thúc nên được gọi
   với số byte được truyền hoặc mã lỗi, cộng với cờ
   cho biết liệu việc chấm dứt có chắc chắn xảy ra trong người gọi hay không
   bối cảnh.

* ZZ0000ZZ

[Bắt buộc] Lệnh này được gọi để cho phép bộ đệm giới hạn kích thước của một
   yêu cầu phụ.  Nó cũng có thể giới hạn số vùng riêng lẻ trong iterator,
   chẳng hạn như yêu cầu của DIO/DMA.  Thông tin này phải được đặt trực tuyến để
   yêu cầu phụ thuộc về::

rreq->io_streams[subreq->stream_nr].sreq_max_len
	rreq->io_streams[subreq->stream_nr].sreq_max_segs

Ví dụ, hệ thống tập tin có thể sử dụng điều này để cắt nhỏ một yêu cầu phải
   được chia ra trên nhiều máy chủ hoặc để thực hiện nhiều thao tác ghi.

Điều này không được phép trả lại một lỗi.  Trong trường hợp thất bại,
   ZZ0000ZZ phải được gọi.

* ZZ0000ZZ

[Bắt buộc] Điều này được sử dụng để gửi yêu cầu phụ tới bộ đệm để ghi.
   Trong yêu cầu phụ, ->start, ->len và ->transferred cho biết dữ liệu nào
   nên được ghi vào bộ đệm và ->io_iter cho biết bộ đệm sẽ được
   đã sử dụng.

Không có giá trị trả về; chức năng ZZ0000ZZ
   nên được gọi để chỉ ra rằng yêu cầu phụ đã hoàn thành theo một trong hai cách.
   ->lỗi, ->đã chuyển và ->cờ phải được cập nhật trước khi hoàn tất.  các
   việc chấm dứt có thể được thực hiện không đồng bộ.


Tham khảo chức năng API
======================

.. kernel-doc:: include/linux/netfs.h
.. kernel-doc:: fs/netfs/buffered_read.c