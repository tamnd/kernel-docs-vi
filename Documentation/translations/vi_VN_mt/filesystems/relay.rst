.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/relay.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
giao diện chuyển tiếp (trước đây là rơlefs)
==================================

Giao diện chuyển tiếp cung cấp phương tiện cho các ứng dụng hạt nhân
ghi nhật ký và truyền tải lượng lớn dữ liệu từ kernel một cách hiệu quả
tới không gian người dùng thông qua 'kênh chuyển tiếp' do người dùng xác định.

'Kênh chuyển tiếp' là cơ chế chuyển tiếp dữ liệu kernel->user được triển khai
dưới dạng một tập hợp các bộ đệm nhân trên mỗi CPU ('bộ đệm kênh'), mỗi bộ đệm
được biểu diễn dưới dạng tệp thông thường ('tệp chuyển tiếp') trong không gian người dùng.  hạt nhân
khách hàng ghi vào bộ đệm kênh bằng cách sử dụng tính năng ghi hiệu quả
chức năng; chúng tự động đăng nhập vào kênh của cpu hiện tại
bộ đệm.  Ứng dụng không gian người dùng mmap() hoặc read() từ các tệp chuyển tiếp
và truy xuất dữ liệu khi nó có sẵn.  Các tập tin chuyển tiếp
bản thân chúng là các tệp được tạo trong hệ thống tệp máy chủ, ví dụ: gỡ lỗi và
được liên kết với bộ đệm kênh bằng API được mô tả bên dưới.

Định dạng của dữ liệu được ghi vào bộ đệm kênh hoàn toàn
lên đến máy khách kernel; Tuy nhiên, giao diện chuyển tiếp cung cấp
các hook cho phép các máy khách kernel áp đặt một số cấu trúc lên
dữ liệu đệm.  Giao diện chuyển tiếp không triển khai bất kỳ dạng dữ liệu nào
lọc - việc này cũng được giao cho máy khách kernel.  Mục đích là để
giữ mọi thứ đơn giản nhất có thể.

Tài liệu này cung cấp cái nhìn tổng quan về giao diện rơle API.  các
chi tiết về các tham số chức năng được ghi lại cùng với
các chức năng trong mã giao diện chuyển tiếp - vui lòng xem để biết chi tiết.

Ngữ nghĩa
=========

Mỗi kênh chuyển tiếp có một bộ đệm cho mỗi CPU; mỗi bộ đệm có một hoặc nhiều
bộ đệm phụ.  Tin nhắn được ghi vào bộ đệm phụ đầu tiên cho đến khi nó được
quá đầy để chứa một tin nhắn mới, trong trường hợp đó nó được ghi vào
tiếp theo (nếu có).  Tin nhắn không bao giờ được chia thành các bộ đệm phụ.
Tại thời điểm này, không gian người dùng có thể được thông báo để nó trống không gian đầu tiên
bộ đệm phụ, trong khi kernel tiếp tục ghi vào bộ đệm tiếp theo.

Khi được thông báo rằng bộ đệm phụ đã đầy, kernel sẽ biết có bao nhiêu
byte của nó là phần đệm, tức là không gian chưa được sử dụng xảy ra do đã hoàn thành
tin nhắn không thể vừa với bộ đệm phụ.  Không gian người dùng có thể sử dụng cái này
kiến thức để chỉ sao chép dữ liệu hợp lệ.

Sau khi sao chép nó, không gian người dùng có thể thông báo cho kernel rằng bộ đệm phụ
đã được tiêu thụ.

Một kênh chuyển tiếp có thể hoạt động ở chế độ mà nó sẽ ghi đè lên dữ liệu mà không
chưa được không gian người dùng thu thập và không chờ nó được sử dụng.

Bản thân kênh chuyển tiếp không cung cấp khả năng liên lạc như vậy
dữ liệu giữa không gian người dùng và kernel, cho phép phía kernel vẫn còn
đơn giản và không áp đặt một giao diện duy nhất trên không gian người dùng.  Nó có
tuy nhiên, hãy cung cấp một tập hợp các ví dụ và một trình trợ giúp riêng biệt, được mô tả
bên dưới.

Giao diện read() vừa loại bỏ phần đệm vừa tiêu thụ nội bộ
đọc bộ đệm phụ; do đó trong trường hợp read(2) đang được sử dụng để thoát
bộ đệm kênh, giao tiếp có mục đích đặc biệt giữa kernel và
người dùng không cần thiết cho hoạt động cơ bản.

Một trong những mục tiêu chính của giao diện chuyển tiếp là cung cấp mức điện áp thấp
cơ chế chi phí để truyền dữ liệu hạt nhân đến không gian người dùng.  Trong khi
Giao diện read() rất dễ sử dụng, nó không hiệu quả bằng mmap()
cách tiếp cận; mã ví dụ cố gắng thực hiện sự cân bằng giữa
hai cách tiếp cận càng nhỏ càng tốt.

mã ví dụ về klog và ứng dụng chuyển tiếp
================================

Bản thân giao diện chuyển tiếp đã sẵn sàng để sử dụng, nhưng để làm mọi việc dễ dàng hơn,
một vài hàm tiện ích đơn giản và một tập hợp các ví dụ được cung cấp.

Ví dụ về tarball của ứng dụng chuyển tiếp, có sẵn trên sourceforge chuyển tiếp
trang web, chứa một tập hợp các ví dụ độc lập, mỗi ví dụ bao gồm một
cặp tệp .c chứa mã soạn sẵn cho mỗi người dùng và
các mặt hạt nhân của một ứng dụng chuyển tiếp.  Khi kết hợp hai bộ này
mã soạn sẵn cung cấp keo để dễ dàng truyền dữ liệu vào đĩa mà không cần
phải bận tâm với công việc dọn phòng nhàm chán.

Bản vá 'chức năng gỡ lỗi klog' (klog.patch trong ứng dụng chuyển tiếp
tarball) cung cấp một vài chức năng ghi nhật ký cấp cao cho
kernel cho phép ghi văn bản được định dạng hoặc dữ liệu thô vào một kênh,
bất kể kênh để ghi vào có tồn tại hay không, hoặc thậm chí
giao diện chuyển tiếp có được biên dịch vào kernel hay không.  Những cái này
các hàm cho phép bạn đặt các câu lệnh 'theo dõi' vô điều kiện ở bất cứ đâu
trong hạt nhân hoặc mô-đun hạt nhân; chỉ khi có 'trình xử lý klog'
dữ liệu đã đăng ký có thực sự được ghi lại không (xem klog và kleak
ví dụ để biết chi tiết).

Tất nhiên là có thể sử dụng giao diện chuyển tiếp từ đầu,
tức là không sử dụng bất kỳ mã ví dụ hoặc klog nào của ứng dụng chuyển tiếp, nhưng
bạn sẽ phải triển khai giao tiếp giữa không gian người dùng và kernel,
cho phép cả hai truyền tải trạng thái của bộ đệm (đầy, trống, số lượng
đệm).  Giao diện read() vừa loại bỏ phần đệm vừa loại bỏ nội bộ
tiêu thụ bộ đệm phụ đọc; do đó trong trường hợp read(2) đang được
được sử dụng để làm cạn kiệt bộ đệm kênh, giao tiếp có mục đích đặc biệt
giữa kernel và người dùng không cần thiết cho hoạt động cơ bản.  thứ
chẳng hạn như điều kiện đầy bộ đệm vẫn cần được truyền đạt qua
một số kênh mặc dù.

klog và các ví dụ về ứng dụng chuyển tiếp có thể được tìm thấy trong ứng dụng chuyển tiếp
tarball trên ZZ0000ZZ

Không gian người dùng giao diện chuyển tiếp API
==================================

Giao diện chuyển tiếp thực hiện các thao tác tệp cơ bản cho không gian người dùng
truy cập vào dữ liệu bộ đệm kênh chuyển tiếp.  Dưới đây là các thao tác tập tin
có sẵn và một số nhận xét liên quan đến hành vi của họ:

=========== ==================================================================
open() cho phép người dùng mở bộ đệm kênh _being_.

mmap() dẫn đến bộ đệm kênh được ánh xạ vào bộ đệm của người gọi
	    không gian bộ nhớ. Lưu ý rằng bạn không thể thực hiện một phần mmap - bạn
	    phải ánh xạ toàn bộ tệp, đó là NRBUF * SUBBUFSIZE.

read() đọc nội dung của bộ đệm kênh.  Các byte được đọc là
	    'được người đọc sử dụng', tức là chúng sẽ không có sẵn
	    một lần nữa cho lần đọc tiếp theo.  Nếu kênh đang được sử dụng
	    ở chế độ không ghi đè (mặc định), nó có thể được đọc bất cứ lúc nào
	    ngay cả khi có một trình ghi kernel đang hoạt động.  Nếu
	    kênh đang được sử dụng ở chế độ ghi đè và có
	    người viết kênh đang hoạt động, kết quả có thể không thể đoán trước -
	    người dùng nên đảm bảo rằng tất cả việc đăng nhập vào kênh đều có
	    đã kết thúc trước khi sử dụng read() với chế độ ghi đè.  Bộ đệm phụ
	    phần đệm sẽ tự động bị xóa và sẽ không được nhìn thấy bởi
	    người đọc.

sendfile() truyền dữ liệu từ bộ đệm kênh sang tệp đầu ra
	    mô tả. Phần đệm của bộ đệm phụ sẽ tự động bị xóa
	    và sẽ không được người đọc nhìn thấy.

thăm dò ý kiến() POLLIN/POLLRDNORM/POLLERR được hỗ trợ.  Các ứng dụng của người dùng được
	    được thông báo khi ranh giới vùng đệm phụ bị vượt qua.

close() giảm số lần đếm của bộ đệm kênh.  Khi hoàn tiền
	    đạt tới 0, tức là khi không có tiến trình hoặc máy khách kernel nào có
	    bộ đệm mở, bộ đệm kênh được giải phóng.
=========== ==================================================================

Để ứng dụng người dùng sử dụng các tập tin chuyển tiếp,
hệ thống tập tin máy chủ phải được gắn kết.  Ví dụ::

mount -t debugfs debugfs/sys/kernel/debug

.. Note::

	The host filesystem doesn't need to be mounted for kernel
	clients to create or use channels - it only needs to be
	mounted when user space applications need access to the buffer
	data.


Hạt nhân giao diện chuyển tiếp API
==============================

Dưới đây là bản tóm tắt về API mà giao diện chuyển tiếp cung cấp cho các máy khách trong kernel:

TBD(dòng hiện tại MT:/API/)
  Chức năng quản lý kênh::

Relay_open(base_filename, parent, subbuf_size, n_subbufs,
               cuộc gọi lại, Private_data)
    tiếp sức_close(chan)
    tiếp sức_flush(chan)
    tiếp sức_reset(chan)

quản lý kênh thường kêu gọi xúi giục không gian người dùng::

tiếp sức_subbufs_consumed(chan, cpu, subbufs_consumed)

viết hàm::

rơle_write(chan, dữ liệu, độ dài)
    __relay_write(chan, dữ liệu, độ dài)
    tiếp sức_reserve(chan, chiều dài)

cuộc gọi lại::

subbuf_start(buf, subbuf, prev_subbuf, prev_padding)
    buf_mapped(buf, filp)
    buf_unmapped(buf, filp)
    create_buf_file(tên tệp, cha, chế độ, buf, is_global)
    Remove_buf_file(nha khoa)

chức năng trợ giúp::

tiếp sức_buf_full(buf)
    subbuf_start_reserve(buf, chiều dài)


Tạo kênh
------------------

Relay_open() được sử dụng để tạo kênh, cùng với mỗi CPU của nó
bộ đệm kênh.  Mỗi bộ đệm kênh sẽ có một tệp liên quan
được tạo cho nó trong hệ thống tập tin máy chủ, có thể được mmapped hoặc
đọc từ trong không gian người dùng.  Các tập tin được đặt tên basename0...basenameN-1
trong đó N là số lượng cpu trực tuyến và theo mặc định sẽ được tạo
trong thư mục gốc của hệ thống tập tin (nếu thông số gốc là NULL).  Nếu bạn
muốn có cấu trúc thư mục chứa các tập tin chuyển tiếp của bạn, bạn nên
tạo nó bằng chức năng tạo thư mục của hệ thống tập tin máy chủ,
ví dụ: debugfs_create_dir() và chuyển thư mục mẹ tới
tiếp sức_open().  Người dùng có trách nhiệm dọn dẹp mọi thư mục
cấu trúc mà chúng tạo ra, khi kênh bị đóng - lại là máy chủ
chức năng loại bỏ thư mục của hệ thống tập tin nên được sử dụng cho việc đó,
ví dụ: debugfs_remove().

Để tạo một kênh và các tập tin của hệ thống tập tin máy chủ
được liên kết với bộ đệm kênh của nó, người dùng phải cung cấp định nghĩa
đối với hai hàm gọi lại, create_buf_file() và Remove_buf_file().
create_buf_file() được gọi một lần cho mỗi bộ đệm trên mỗi CPU từ
Relay_open() và cho phép người dùng tạo tệp sẽ được sử dụng
để đại diện cho bộ đệm kênh tương ứng.  Cuộc gọi lại nên
trả về mục nhập của tệp được tạo để thể hiện bộ đệm kênh.
Remove_buf_file() cũng phải được xác định; nó có trách nhiệm xóa
(các) tệp được tạo trong create_buf_file() và được gọi trong
rơle_close().

Dưới đây là một số định nghĩa điển hình cho các lệnh gọi lại này, trong trường hợp này
sử dụng debugfs::

/*
    * gọi lại create_buf_file().  Tạo tập tin chuyển tiếp trong debugfs.
    */
    cấu trúc nha khoa tĩnh *create_buf_file_handler(const char *filename,
						cấu trúc nha khoa *cha mẹ,
						chế độ umode_t,
						cấu trúc rchan_buf *buf,
						int *is_global)
    {
	    trả về debugfs_create_file(tên tệp, chế độ, cha mẹ, buf,
				    &relay_file_Operations);
    }

/*
    * gọi lại Remove_buf_file().  Xóa tệp chuyển tiếp khỏi debugfs.
    */
    int tĩnh Remove_buf_file_handler(cấu trúc nha khoa *dentry)
    {
	    debugfs_remove(nha khoa);

trả về 0;
    }

/*
    * gọi lại giao diện chuyển tiếp
    */
    cấu trúc tĩnh rchan_callbacks tiếp sức_callbacks =
    {
	    .create_buf_file = create_buf_file_handler,
	    .remove_buf_file=remove_buf_file_handler,
    };

Và một ví dụ về lệnh gọi Relay_open() sử dụng chúng ::

chan = Relay_open("cpu", NULL, SUBBUF_SIZE, N_SUBBUFS, &relay_callbacks, NULL);

Nếu lệnh gọi lại create_buf_file() không thành công hoặc không được xác định, kênh
việc tạo và do đó Relay_open() sẽ thất bại.

Tổng kích thước của mỗi bộ đệm trên mỗi CPU được tính bằng cách nhân
số lượng bộ đệm phụ theo kích thước bộ đệm phụ được chuyển vào Relay_open().
Ý tưởng đằng sau các bộ đệm phụ là về cơ bản chúng là một phần mở rộng của
đệm đôi vào N bộ đệm và chúng cũng cho phép các ứng dụng
dễ dàng thực hiện các sơ đồ ranh giới truy cập ngẫu nhiên trên bộ đệm, có thể
quan trọng đối với một số ứng dụng có khối lượng lớn.  Số lượng và kích thước
của bộ đệm phụ hoàn toàn phụ thuộc vào ứng dụng và thậm chí đối với
cùng một ứng dụng, các điều kiện khác nhau sẽ đảm bảo khác nhau
giá trị của các thông số này tại các thời điểm khác nhau.  Thông thường, bên phải
các giá trị sử dụng được quyết định tốt nhất sau một số thử nghiệm; nói chung,
tuy nhiên, có thể an toàn khi cho rằng chỉ có 1 bộ đệm phụ là không tốt
ý tưởng - bạn được đảm bảo ghi đè lên dữ liệu hoặc mất sự kiện
tùy thuộc vào chế độ kênh đang được sử dụng.

Việc triển khai create_buf_file() cũng có thể được định nghĩa theo cách như vậy
để cho phép tạo một bộ đệm 'toàn cầu' duy nhất thay vì
bộ mỗi CPU mặc định.  Điều này có thể hữu ích cho các ứng dụng quan tâm
chủ yếu là nhìn thấy thứ tự tương đối của các sự kiện trên toàn hệ thống mà không cần
sự cần thiết phải bận tâm đến việc lưu dấu thời gian rõ ràng cho mục đích
hợp nhất/sắp xếp các tệp trên mỗi CPU trong bước xử lý hậu kỳ.

Để Relay_open() tạo bộ đệm chung, create_buf_file()
việc triển khai nên đặt giá trị của outparam is_global thành a
giá trị khác 0 ngoài việc tạo tệp sẽ được sử dụng để
đại diện cho bộ đệm đơn.  Trong trường hợp bộ đệm toàn cục,
create_buf_file() và Remove_buf_file() sẽ chỉ được gọi một lần.  các
chức năng ghi kênh thông thường, ví dụ: Relay_write(), vẫn có thể
đã sử dụng - việc ghi từ bất kỳ CPU nào sẽ kết thúc một cách minh bạch trên toàn cầu
bộ đệm - nhưng vì đây là bộ đệm chung nên người gọi phải đảm bảo
họ sử dụng khóa thích hợp cho bộ đệm như vậy bằng cách gói
ghi vào spinlock hoặc bằng cách sao chép chức năng ghi từ rơle.h và
tạo một phiên bản cục bộ thực hiện khóa thích hợp trong nội bộ.

Private_data được truyền vào Relay_open() cho phép khách hàng liên kết
dữ liệu do người dùng xác định với một kênh và có sẵn ngay lập tức
(bao gồm trong create_buf_file()) qua chan->private_data hoặc
buf->chan->private_data.

'Chế độ' kênh
---------------

các kênh chuyển tiếp có thể được sử dụng ở một trong hai chế độ - 'ghi đè' hoặc
'không ghi đè'.  Chế độ hoàn toàn được xác định bởi việc thực hiện
của lệnh gọi lại subbuf_start(), như được mô tả bên dưới.  Mặc định nếu không
Cuộc gọi lại subbuf_start() được xác định là chế độ 'không ghi đè'.  Nếu
chế độ mặc định phù hợp với nhu cầu của bạn và bạn dự định sử dụng read()
giao diện lấy dữ liệu kênh, bạn có thể bỏ qua chi tiết này
phần này, vì nó chủ yếu liên quan đến việc triển khai mmap().

Ở chế độ 'ghi đè', còn được gọi là chế độ 'ghi chuyến bay', ghi
quay vòng liên tục quanh bộ đệm và sẽ không bao giờ bị lỗi, nhưng sẽ
ghi đè vô điều kiện dữ liệu cũ bất kể nó có thực sự
đã được tiêu thụ.  Ở chế độ không ghi đè, việc ghi sẽ không thành công, tức là dữ liệu sẽ
bị mất nếu số lượng bộ đệm phụ chưa được sử dụng bằng tổng số
số lượng bộ đệm phụ trong kênh.  Cần phải rõ ràng rằng nếu
không có người tiêu dùng hoặc nếu người tiêu dùng không thể sử dụng bộ đệm phụ nhanh chóng
đủ, dữ liệu sẽ bị mất trong cả hai trường hợp; sự khác biệt duy nhất là
dữ liệu bị mất từ đầu hay cuối bộ đệm.

Như đã giải thích ở trên, một kênh chuyển tiếp được tạo thành từ một hoặc nhiều
bộ đệm kênh trên mỗi CPU, mỗi bộ đệm được triển khai dưới dạng bộ đệm tròn
được chia thành một hoặc nhiều bộ đệm con.  Tin nhắn được viết vào
bộ đệm phụ hiện tại của bộ đệm trên mỗi CPU hiện tại của kênh thông qua
viết các chức năng được mô tả dưới đây.  Bất cứ khi nào một tin nhắn không thể phù hợp
bộ đệm phụ hiện tại, vì không còn chỗ cho nó, nên
khách hàng được thông báo qua lệnh gọi lại subbuf_start() rằng việc chuyển sang
bộ đệm phụ mới sắp xảy ra.  Khách hàng sử dụng cuộc gọi lại này tới 1)
khởi tạo bộ đệm phụ tiếp theo nếu thích hợp 2) hoàn thiện bộ đệm trước đó
bộ đệm phụ nếu thích hợp và 3) trả về giá trị boolean cho biết
có thực sự chuyển sang bộ đệm phụ tiếp theo hay không.

Để triển khai chế độ 'không ghi đè', ứng dụng khách vùng người dùng cung cấp
việc triển khai lệnh gọi lại subbuf_start() giống như
sau đây::

int tĩnh subbuf_start(struct rchan_buf *buf,
			    vô hiệu *subbuf,
			    vô hiệu *prev_subbuf,
			    unsigned int prev_padding)
    {
	    nếu (prev_subbuf)
		    ZZ0000ZZ)prev_subbuf) = prev_padding;

nếu (relay_buf_full(buf))
		    trả về 0;

subbuf_start_reserve(buf, sizeof(unsigned int));

trả về 1;
    }

Nếu bộ đệm hiện tại đã đầy, tức là tất cả các bộ đệm phụ vẫn chưa được sử dụng,
cuộc gọi lại trả về 0 để chỉ ra rằng công tắc bộ đệm không nên
chưa xảy ra, tức là cho đến khi người tiêu dùng có cơ hội đọc
tập hợp các bộ đệm phụ sẵn sàng hiện tại.  Đối với hàm Relay_buf_full()
để có ý nghĩa, người tiêu dùng có trách nhiệm thông báo cho người chuyển tiếp
giao diện khi bộ đệm phụ đã được sử dụng thông qua
tiếp sức_subbufs_consumed().  Bất kỳ nỗ lực tiếp theo nào để ghi vào
bộ đệm sẽ lại gọi lệnh gọi lại subbuf_start() với cùng một lệnh
thông số; chỉ khi người tiêu dùng đã tiêu thụ một hoặc nhiều sản phẩm
bộ đệm phụ sẵn sàng sẽ tiếp sức_buf_full() trả về 0, trong trường hợp đó
chuyển đổi đệm có thể tiếp tục.

Việc triển khai lệnh gọi lại subbuf_start() cho chế độ 'ghi đè'
sẽ rất giống nhau::

int tĩnh subbuf_start(struct rchan_buf *buf,
			    vô hiệu *subbuf,
			    vô hiệu *prev_subbuf,
			    size_t prev_padding)
    {
	    nếu (prev_subbuf)
		    ZZ0000ZZ)prev_subbuf) = prev_padding;

subbuf_start_reserve(buf, sizeof(unsigned int));

trả về 1;
    }

Trong trường hợp này, việc kiểm tra Relay_buf_full() là vô nghĩa và
gọi lại luôn trả về 1, khiến việc chuyển đổi bộ đệm xảy ra
vô điều kiện.  Việc khách hàng sử dụng
hàm Relay_subbufs_consumed() ở chế độ này, vì nó không bao giờ
đã được tư vấn.

Việc triển khai subbuf_start() mặc định, được sử dụng nếu máy khách không
xác định bất kỳ lệnh gọi lại nào hoặc không xác định lệnh gọi lại subbuf_start(),
thực hiện chế độ 'không ghi đè' đơn giản nhất có thể, tức là nó thực hiện
không có gì ngoài việc trả về 0.

Thông tin tiêu đề có thể được đặt trước ở đầu mỗi bộ đệm phụ
bằng cách gọi hàm trợ giúp subbuf_start_reserve() từ bên trong
gọi lại subbuf_start().  Khu vực dành riêng này có thể được sử dụng để lưu trữ
bất cứ thông tin nào khách hàng muốn.  Trong ví dụ trên, phòng là
dành riêng trong mỗi bộ đệm phụ để lưu trữ số lượng phần đệm cho điều đó
bộ đệm phụ.  Điều này được điền vào cho bộ đệm phụ trước đó trong
triển khai subbuf_start(); giá trị đệm cho trước đó
bộ đệm phụ được chuyển vào lệnh gọi lại subbuf_start() cùng với
con trỏ tới bộ đệm phụ trước đó, vì giá trị phần đệm không
được biết cho đến khi bộ đệm phụ được lấp đầy.  Cuộc gọi lại subbuf_start() là
cũng được gọi cho bộ đệm phụ đầu tiên khi kênh được mở, để
cho khách hàng một cơ hội để dành chỗ trong đó.  Trong trường hợp này
con trỏ bộ đệm phụ trước đó được chuyển vào lệnh gọi lại sẽ là NULL, vì vậy
khách hàng nên kiểm tra giá trị của con trỏ prev_subbuf trước
ghi vào bộ đệm phụ trước đó.

Viết cho một kênh
--------------------

Máy khách hạt nhân ghi dữ liệu vào bộ đệm kênh của CPU hiện tại bằng cách sử dụng
tiếp sức_write() hoặc __relay_write().  Relay_write() là ghi nhật ký chính
chức năng - nó sử dụng local_irqsave() để bảo vệ bộ đệm và phải
được sử dụng nếu bạn có thể đang đăng nhập từ ngữ cảnh bị gián đoạn.  Nếu bạn biết
bạn sẽ không bao giờ đăng nhập từ bối cảnh bị gián đoạn, bạn có thể sử dụng
__relay_write(), chỉ vô hiệu hóa quyền ưu tiên.  Những chức năng này
không trả về một giá trị, vì vậy bạn không thể xác định liệu chúng có
không thành công - giả định là bạn sẽ không muốn kiểm tra hàng trả lại
dù sao cũng có giá trị trong đường dẫn ghi nhật ký nhanh và họ sẽ luôn thành công
trừ khi bộ đệm đầy và chế độ không ghi đè đang được sử dụng, trong
trường hợp nào bạn có thể phát hiện lỗi ghi trong subbuf_start()
gọi lại bằng cách gọi hàm trợ giúp Relay_buf_full().

Relay_reserve() được sử dụng để dành một vị trí trong bộ đệm kênh
có thể được viết để sau này.  Điều này thường được sử dụng trong các ứng dụng
cần ghi trực tiếp vào bộ đệm kênh mà không cần phải
dữ liệu giai đoạn trong một bộ đệm tạm thời trước đó.  Bởi vì viết thực tế
có thể không xảy ra ngay sau khi chỗ trống được đặt trước, các ứng dụng
sử dụng Relay_reserve() thực sự có thể đếm số byte
được viết, trong không gian dành riêng trong các bộ đệm phụ hoặc dưới dạng
một mảng riêng biệt.  Xem ví dụ 'dự trữ' trong tarball ứng dụng chuyển tiếp
tại ZZ0000ZZ để biết ví dụ về cách thực hiện điều này
xong.  Bởi vì việc viết nằm dưới sự kiểm soát của khách hàng và
tách khỏi khu dự trữ, Relay_reserve() không bảo vệ bộ đệm
hoàn toàn - việc cung cấp thông tin thích hợp là tùy thuộc vào khách hàng
đồng bộ hóa khi sử dụng Relay_reserve().

Đóng một kênh
-----------------

Máy khách gọi Relay_close() khi sử dụng xong kênh.
Kênh và bộ đệm liên quan của nó sẽ bị hủy khi không có
còn bất kỳ tham chiếu nào đến bất kỳ bộ đệm kênh nào.  rơle_flush()
buộc chuyển đổi bộ đệm phụ trên tất cả các bộ đệm kênh và có thể được sử dụng
để hoàn thiện và xử lý các bộ đệm phụ cuối cùng trước khi kênh được
đóng cửa.

linh tinh
----

Một số ứng dụng có thể muốn giữ lại một kênh và sử dụng lại nó
thay vì mở và đóng một kênh mới cho mỗi lần sử dụng.  rơle_reset()
có thể được sử dụng cho mục đích này - nó đặt lại kênh về trạng thái ban đầu
trạng thái mà không cần phân bổ lại bộ nhớ đệm kênh hoặc hủy bỏ
các bản đồ hiện có.  Tuy nhiên, nó chỉ nên được gọi khi thấy an toàn
làm như vậy, tức là khi kênh hiện không được ghi vào.

Cuối cùng, có một số lệnh gọi lại tiện ích có thể được sử dụng cho
mục đích khác nhau.  buf_mapped() được gọi bất cứ khi nào bộ đệm kênh
được mmapped từ không gian người dùng và buf_unmapped() được gọi khi nó
chưa được lập bản đồ.  Khách hàng có thể sử dụng thông báo này để kích hoạt hành động
trong ứng dụng kernel, chẳng hạn như bật/tắt đăng nhập vào
kênh này.


Tài nguyên
=========

Để biết tin tức, mã ví dụ, danh sách gửi thư, v.v. hãy xem trang chủ giao diện chuyển tiếp:

ZZ0000ZZ


Tín dụng
=======

Ý tưởng và thông số kỹ thuật cho giao diện chuyển tiếp xuất hiện do
thảo luận về truy tìm liên quan đến những điều sau đây:

Michel Dagenais <michel.dagenais@polymtl.ca>
Richard Moore <richardj_moore@uk.ibm.com>
Bob Wisniewski <bob@watson.ibm.com>
Karim Yaghmour <karim@opersys.com>
Tom Zanussi <zanussi@us.ibm.com>

Cũng xin cảm ơn Hubertus Franke vì rất nhiều gợi ý và lỗi hữu ích
báo cáo.