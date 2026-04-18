.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/seq_file.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Giao diện seq_file
======================

Bản quyền 2003 Jonathan Corbet <corbet@lwn.net>

Tệp này có nguồn gốc từ loạt LWN.net Driver Porting tại
	ZZ0000ZZ


Có rất nhiều cách để trình điều khiển thiết bị (hoặc thành phần hạt nhân khác)
cung cấp thông tin cho người dùng hoặc người quản trị hệ thống.  Một hữu ích
kỹ thuật là tạo các tệp ảo, trong debugfs, /proc hoặc ở nơi khác.
Các tệp ảo có thể cung cấp đầu ra mà con người có thể đọc được và dễ dàng lấy được
không có bất kỳ chương trình tiện ích đặc biệt nào; họ cũng có thể làm cho cuộc sống dễ dàng hơn cho
người viết kịch bản. Không có gì ngạc nhiên khi việc sử dụng file ảo có
trưởng thành qua các năm.

Việc tạo các tệp đó một cách chính xác luôn là một thách thức,
tuy nhiên. Không khó để tạo một tệp ảo trả về một
chuỗi. Nhưng cuộc sống sẽ trở nên phức tạp hơn nếu đầu ra dài - bất cứ điều gì lớn hơn
hơn khả năng ứng dụng có thể đọc trong một thao tác.  Xử lý
nhiều lần đọc (và tìm kiếm) đòi hỏi sự chú ý cẩn thận đến ý kiến của người đọc
vị trí trong tệp ảo - vị trí đó, có thể là không, trong
giữa một dòng đầu ra. Hạt nhân theo truyền thống có một số
việc triển khai đã xảy ra lỗi này.

Hạt nhân bây giờ chứa một tập hợp các hàm (được triển khai bởi Alexander Viro)
được thiết kế để giúp người tạo tệp ảo dễ dàng lấy được nó
đúng.

Giao diện seq_file có sẵn qua <linux/seq_file.h>. có
ba khía cạnh của seq_file:

* Giao diện lặp cho phép triển khai tệp ảo
       bước qua các đối tượng mà nó đang trình bày.

* Một số hàm tiện ích để định dạng đối tượng cho đầu ra mà không cần
       cần phải lo lắng về những thứ như bộ đệm đầu ra.

* Một tập hợp các thao tác file đóng hộp thực hiện hầu hết các thao tác trên
       tập tin ảo.

Chúng ta sẽ xem xét giao diện seq_file qua một ví dụ cực kỳ đơn giản: a
mô-đun có thể tải để tạo một tệp có tên /proc/sequence. Tập tin khi
đọc, chỉ đơn giản tạo ra một tập hợp các giá trị số nguyên tăng dần, mỗi giá trị trên một dòng. các
trình tự sẽ tiếp tục cho đến khi người dùng mất kiên nhẫn và tìm thấy thứ gì đó
tốt hơn để làm. Tệp có thể tìm kiếm được, trong đó người ta có thể làm điều gì đó như
sau đây::

dd if=/proc/chuỗi of=out1 count=1
    dd if=/proc/sequence Skip=1 of=out2 count=1

Sau đó nối các tệp đầu ra out1 và out2 và lấy đúng
kết quả. Đúng, nó là một mô-đun hoàn toàn vô dụng, nhưng mục đích là để hiển thị
cách thức hoạt động của cơ chế mà không bị lạc vào các chi tiết khác.  (Những cái đó
muốn xem nguồn đầy đủ cho mô-đun này có thể tìm thấy nó tại
ZZ0000ZZ

create_proc_entry không được dùng nữa
============================

Lưu ý rằng bài viết trên sử dụng create_proc_entry đã bị xóa trong
hạt nhân 3.10. Các phiên bản hiện tại yêu cầu cập nhật sau::

- entry = create_proc_entry("chuỗi", 0, NULL);
    - nếu (mục nhập)
    - entry->proc_fops = &ct_file_ops;
    + entry = proc_create("chuỗi", 0, NULL, &ct_file_ops);

Giao diện lặp
======================

Các mô-đun triển khai tệp ảo với seq_file phải triển khai một
đối tượng iterator cho phép duyệt qua dữ liệu quan tâm
trong một "phiên" (khoảng một lệnh gọi hệ thống read()).  Nếu trình vòng lặp
có thể di chuyển đến một vị trí cụ thể - như tệp họ triển khai,
mặc dù có quyền tự do ánh xạ số vị trí tới vị trí thứ tự
theo bất kỳ cách nào thuận tiện - trình vòng lặp chỉ cần tồn tại
tạm thời trong một phiên.  Nếu trình vòng lặp không thể dễ dàng tìm thấy một
vị trí số nhưng hoạt động tốt với giao diện đầu tiên/tiếp theo,
iterator có thể được lưu trữ trong vùng dữ liệu riêng tư và tiếp tục từ một vùng
phiên tiếp theo.

Việc triển khai seq_file đang định dạng các quy tắc tường lửa từ một
bảng, chẳng hạn, có thể cung cấp một trình vòng lặp đơn giản để diễn giải
vị trí N là quy tắc thứ N trong chuỗi.  Triển khai seq_file
trình bày nội dung của một danh sách liên kết có khả năng thay đổi
có thể ghi một con trỏ vào danh sách đó, miễn là có thể thực hiện được
mà không có nguy cơ vị trí hiện tại bị xóa.

Do đó, việc định vị có thể được thực hiện theo bất kỳ cách nào có ý nghĩa nhất đối với
người tạo ra dữ liệu, không cần phải biết vị trí
chuyển thành phần bù trong tệp ảo. Một ngoại lệ rõ ràng
đó là vị trí số 0 sẽ biểu thị phần đầu của tệp.

Trình lặp /proc/sequence chỉ sử dụng số đếm tiếp theo của nó
sẽ xuất ra như vị trí của nó.

Bốn chức năng phải được triển khai để làm cho trình vòng lặp hoạt động. các
đầu tiên, được gọi là start(), bắt đầu một phiên làm việc và nhận một vị trí làm
đối số, trả về một trình vòng lặp sẽ bắt đầu đọc tại đó
vị trí.  Vị trí được chuyển đến start() sẽ luôn bằng 0 hoặc
tư thế gần đây nhất được sử dụng trong phiên trước.

Đối với ví dụ trình tự đơn giản của chúng tôi,
hàm start() trông giống như::

khoảng trống tĩnh *ct_seq_start(struct seq_file *s, loff_t *pos)
	{
	        loff_t *spos = kmalloc(sizeof(loff_t), GFP_KERNEL);
	        nếu (! spos)
	                trả lại NULL;
	        *spos = *pos;
	        trả lại sp;
	}

Toàn bộ cấu trúc dữ liệu cho trình vòng lặp này là một giá trị loff_t duy nhất
giữ chức vụ hiện tại. Không có giới hạn trên cho chuỗi
iterator, nhưng điều đó sẽ không xảy ra với hầu hết các seq_file khác
triển khai; trong hầu hết các trường hợp, hàm start() sẽ kiểm tra
điều kiện "kết thúc tập tin trước đây" và trả về NULL nếu cần.

Đối với các ứng dụng phức tạp hơn, trường riêng tư của seq_file
cấu trúc có thể được sử dụng để giữ trạng thái từ phiên này sang phiên khác.  có
cũng là một giá trị đặc biệt có thể được trả về bởi hàm start()
được gọi là SEQ_START_TOKEN; nó có thể được sử dụng nếu bạn muốn hướng dẫn
show() (được mô tả bên dưới) để in tiêu đề ở đầu
đầu ra. SEQ_START_TOKEN chỉ nên được sử dụng nếu độ lệch bằng 0,
tuy nhiên.  SEQ_START_TOKEN không có ý nghĩa đặc biệt đối với seq_file lõi
mã.  Nó được cung cấp để thuận tiện cho hàm start()
giao tiếp với các hàm next() và show().

Thật ngạc nhiên, hàm tiếp theo cần triển khai được gọi là next(); công việc của nó là
di chuyển vòng lặp về phía trước đến vị trí tiếp theo trong chuỗi.  các
mô-đun ví dụ có thể chỉ cần tăng vị trí lên một; hữu ích hơn
các mô-đun sẽ thực hiện những gì cần thiết để duyệt qua một số cấu trúc dữ liệu. các
Hàm next() trả về một trình vòng lặp mới hoặc NULL nếu chuỗi đó là
hoàn thành. Đây là phiên bản ví dụ::

khoảng trống tĩnh *ct_seq_next(struct seq_file *s, khoảng trống *v, loff_t *pos)
	{
	        loff_t *spos = v;
	        *pos = ++*spos;
	        trả lại sp;
	}

Hàm next() sẽ đặt ZZ0000ZZ thành giá trị mà start() có thể sử dụng
để tìm vị trí mới trong chuỗi.  Khi vòng lặp đang được
được lưu trữ trong vùng dữ liệu riêng tư, thay vì được khởi tạo lại trên mỗi
start(), có vẻ như chỉ cần đặt ZZ0001ZZ thành bất kỳ giá trị nào khác 0 là đủ
giá trị (số 0 luôn báo cho start() khởi động lại chuỗi).  Đây không phải là
đủ do các vấn đề lịch sử.

Trong lịch sử, nhiều hàm next() có ZZ0003ZZ được cập nhật ZZ0000ZZ tại
cuối tập tin.  Nếu giá trị đó được sử dụng bởi start() để khởi tạo
iterator, điều này có thể dẫn đến các trường hợp góc trong đó mục cuối cùng trong
trình tự được báo cáo hai lần trong tập tin.  Để ngăn chặn lỗi này
sau khi được phục hồi, mã seq_file lõi hiện tạo ra cảnh báo nếu
hàm next() không thay đổi giá trị của ZZ0001ZZ.  Do đó một
Hàm next() ZZ0004ZZ thay đổi giá trị của ZZ0002ZZ, và tất nhiên là phải
đặt nó thành một giá trị khác không.

Hàm stop() đóng một phiên; Công việc của nó tất nhiên là dọn dẹp
lên. Nếu bộ nhớ động được phân bổ cho iterator, thì stop() là
nơi để giải phóng nó; nếu khóa được thực hiện bởi start(), stop() phải giải phóng
ổ khóa đó.  Giá trị mà ZZ0000ZZ được đặt thành bởi lệnh gọi next() cuối cùng
trước khi stop() được ghi nhớ và được sử dụng cho lệnh gọi start() đầu tiên của
phiên tiếp theo trừ khi lseek() được gọi trong tệp; trong đó
trường hợp start() tiếp theo sẽ được yêu cầu bắt đầu ở vị trí 0::

khoảng trống tĩnh ct_seq_stop(struct seq_file *s, void *v)
	{
	        kfree(v);
	}

Cuối cùng, hàm show() sẽ định dạng đối tượng hiện được trỏ tới
bởi iterator cho đầu ra.  Hàm show() của mô-đun ví dụ là::

int tĩnh ct_seq_show(struct seq_file *s, void *v)
	{
	        loff_t *spos = v;
	        seq_printf(s, "%lld\n", (dài dài)*spos);
	        trả về 0;
	}

Nếu tất cả đều ổn, hàm show() sẽ trả về 0.  Lỗi tiêu cực
mã theo cách thông thường chỉ ra rằng đã xảy ra lỗi; nó sẽ như vậy
được chuyển trở lại không gian người dùng.  Hàm này cũng có thể trả về SEQ_SKIP,
làm cho mục hiện tại bị bỏ qua; nếu hàm show() đã có
đầu ra được tạo trước khi trả về SEQ_SKIP, đầu ra đó sẽ bị loại bỏ.

Chúng ta sẽ xem xét seq_printf() sau. Nhưng trước hết, định nghĩa của
Trình vòng lặp seq_file được hoàn thành bằng cách tạo cấu trúc seq_Operations với
bốn hàm chúng ta vừa xác định::

const tĩnh struct seq_Operation ct_seq_ops = {
	        .start = ct_seq_start,
	        .next = ct_seq_next,
	        .stop = ct_seq_stop,
	        .show = ct_seq_show
	};

Cấu trúc này sẽ cần thiết để liên kết trình vòng lặp của chúng ta với tệp /proc trong
một chút.

Điều đáng chú ý là giá trị iterator được trả về bởi start() và
thao tác bởi các chức năng khác được coi là hoàn toàn mờ đục bởi
mã seq_file. Do đó, nó có thể là bất cứ thứ gì hữu ích trong việc đẩy mạnh
thông qua dữ liệu được xuất ra. Bộ đếm có thể hữu ích, nhưng nó cũng có thể
con trỏ trực tiếp vào một mảng hoặc danh sách liên kết. Làm gì cũng được, miễn là
lập trình viên biết rằng mọi thứ có thể xảy ra giữa các cuộc gọi đến
hàm lặp. Tuy nhiên, mã seq_file (theo thiết kế) sẽ không ngủ
giữa các lệnh gọi start() và stop(), do đó, hãy giữ khóa trong thời gian đó
là điều hợp lý nên làm. Mã seq_file cũng sẽ tránh lấy bất kỳ
các khóa khác trong khi trình lặp đang hoạt động.

Giá trị lặp được trả về bởi start() hoặc next() được đảm bảo là
được chuyển sang lệnh gọi next() hoặc stop() tiếp theo.  Điều này cho phép tài nguyên
chẳng hạn như những ổ khóa đã được mở ra một cách đáng tin cậy.  Có ZZ0000ZZ
đảm bảo rằng trình vòng lặp sẽ được chuyển tới show(), mặc dù trong thực tế
nó thường sẽ như vậy.


Đầu ra được định dạng
================

Mã seq_file quản lý việc định vị trong đầu ra được tạo bởi
iterator và đưa nó vào bộ đệm của người dùng. Nhưng để điều đó có hiệu quả thì
đầu ra phải được chuyển tới mã seq_file. Một số chức năng tiện ích có
đã được xác định để làm cho nhiệm vụ này trở nên dễ dàng.

Hầu hết mã sẽ chỉ sử dụng seq_printf(), hoạt động khá giống
printk(), nhưng yêu cầu con trỏ seq_file làm đối số.

Đối với đầu ra ký tự thẳng, có thể sử dụng các chức năng sau::

seq_putc(struct seq_file *m, char c);
	seq_puts(struct seq_file *m, const char *s);
	seq_escape(struct seq_file *m, const char *s, const char *esc);

Hai cái đầu tiên xuất ra một ký tự đơn và một chuỗi, giống như một cái
mong đợi. seq_escape() giống như seq_puts(), ngoại trừ bất kỳ ký tự nào trong s
trong chuỗi esc sẽ được biểu diễn dưới dạng bát phân ở đầu ra.

Ngoài ra còn có một cặp chức năng in tên tệp::

int seq_path(struct seq_file *m, const struct path *path,
		     const char *esc);
	int seq_path_root(struct seq_file *m, const struct path *path,
			  đường dẫn cấu trúc const *root, const char *esc)

Ở đây, đường dẫn chỉ ra file quan tâm và esc là tập hợp các ký tự
cần được thoát trong đầu ra.  Một lệnh gọi tới seq_path() sẽ xuất ra
đường dẫn liên quan đến gốc hệ thống tập tin của quy trình hiện tại.  Nếu khác
muốn root thì có thể sử dụng nó với seq_path_root().  Nếu hóa ra thế
không thể truy cập đường dẫn từ root, seq_path_root() trả về SEQ_SKIP.

Một hàm tạo đầu ra phức tạp có thể muốn kiểm tra::

bool seq_has_overflowed(struct seq_file *m);

và tránh các lệnh gọi seq_<output> tiếp theo nếu trả về true.

Trả về thực sự từ seq_has_overflowed có nghĩa là bộ đệm seq_file sẽ
bị loại bỏ và hàm seq_show sẽ cố gắng phân bổ một phần lớn hơn
đệm và thử in lại.


Làm cho tất cả hoạt động
==================

Cho đến nay, chúng ta đã có một tập hợp các hàm hữu ích có thể tạo ra đầu ra trong phạm vi
seq_file, nhưng chúng tôi vẫn chưa biến chúng thành một tệp mà người dùng
có thể nhìn thấy. Tất nhiên, việc tạo một tập tin trong kernel đòi hỏi phải có
tạo một tập hợp các file_operating để thực hiện các thao tác trên đó
tập tin. Giao diện seq_file cung cấp một tập hợp các thao tác soạn sẵn để thực hiện
hầu hết công việc. Tác giả tệp ảo vẫn phải triển khai open()
Tuy nhiên, phương pháp để kết nối mọi thứ. Hàm mở thường là một hàm duy nhất
dòng, như trong mô-đun ví dụ::

int tĩnh ct_open(tệp struct inode *inode, struct file *)
	{
		trả về seq_open(file, &ct_seq_ops);
	}

Ở đây, lệnh gọi seq_open() lấy cấu trúc seq_Operations mà chúng tôi đã tạo
trước đó và được thiết lập để lặp qua tệp ảo.

Khi mở thành công, seq_open() lưu trữ con trỏ struct seq_file trong
tệp->private_data. Nếu bạn có một ứng dụng mà cùng một trình vòng lặp có thể
được sử dụng cho nhiều tập tin, bạn có thể lưu trữ một con trỏ tùy ý trong
trường riêng của cấu trúc seq_file; giá trị đó sau đó có thể được lấy ra
bởi các hàm lặp.

Ngoài ra còn có một hàm bao bọc cho seq_open() được gọi là seq_open_private(). Nó
kmallocs một khối bộ nhớ được lấp đầy bằng 0 và lưu trữ một con trỏ tới nó trong
trường riêng của cấu trúc seq_file, trả về 0 nếu thành công. các
kích thước khối được chỉ định trong tham số thứ ba cho hàm, ví dụ:::

int tĩnh ct_open(tệp struct inode *inode, struct file *)
	{
		trả về seq_open_private(file, &ct_seq_ops,
					sizeof(struct mystruct));
	}

Ngoài ra còn có một hàm biến thể, __seq_open_private(), có chức năng
giống nhau ngoại trừ việc, nếu thành công, nó sẽ trả về con trỏ tới vị trí được phân bổ
khối bộ nhớ, cho phép khởi tạo thêm, ví dụ::

int tĩnh ct_open(tệp struct inode *inode, struct file *)
	{
		struct mystruct *p =
			__seq_open_private(file, &ct_seq_ops, sizeof(*p));

nếu (!p)
			trả về -ENOMEM;

p->foo = thanh; /* khởi tạo nội dung của tôi */
			...
p->baz = đúng;

trả về 0;
	}

Một hàm đóng tương ứng, seq_release_private() có sẵn
giải phóng bộ nhớ được phân bổ trong lần mở tương ứng.

Các hoạt động quan tâm khác - read(), llseek() và phát hành() - là
tất cả đều được thực hiện bởi chính mã seq_file. Vì vậy, một tập tin ảo
Cấu trúc file_Operations sẽ trông giống như::

const tĩnh struct file_Operations ct_file_ops = {
	        .chủ sở hữu = THIS_MODULE,
	        .open = ct_open,
	        .read = seq_read,
	        .llseek = seq_lseek,
	        .release = seq_release
	};

Ngoài ra còn có một seq_release_private() chuyển nội dung của
trường riêng seq_file thành kfree() trước khi giải phóng cấu trúc.

Bước cuối cùng là tạo tập tin /proc. Trong ví dụ
mã, việc đó được thực hiện trong mã khởi tạo theo cách thông thường::

int tĩnh ct_init(void)
	{
	        struct proc_dir_entry *entry;

proc_create("chuỗi", 0, NULL, &ct_file_ops);
	        trả về 0;
	}

module_init(ct_init);

Và đó là khá nhiều nó.


danh sách seq_list
========

Nếu tệp của bạn sẽ lặp qua danh sách liên kết, bạn có thể tìm thấy những
thói quen hữu ích::

danh sách cấu trúc_head *seq_list_start(struct list_head *head,
	       		 		 tư thế loff_t);
	danh sách cấu trúc_head *seq_list_start_head(struct list_head *head,
			 		      tư thế loff_t);
	cấu trúc list_head *seq_list_next(void *v, cấu trúc list_head *head,
					loff_t *ppos);

Những người trợ giúp này sẽ diễn giải pos như một vị trí trong danh sách và lặp lại
tương ứng.  Các hàm start() và next() của bạn chỉ cần gọi
Người trợ giúp ZZ0000ZZ có con trỏ tới cấu trúc list_head thích hợp.


Phiên bản cực kỳ đơn giản
========================

Đối với các tệp ảo cực kỳ đơn giản, thậm chí còn có giao diện dễ dàng hơn.  A
mô-đun chỉ có thể định nghĩa hàm show(), hàm này sẽ tạo ra tất cả
đầu ra mà tệp ảo sẽ chứa. Sau đó, phương thức open() của tệp
cuộc gọi::

int single_open(tệp cấu trúc *tệp,
	                int (*show)(struct seq_file *m, void *p),
	                void *dữ liệu);

Khi đến thời điểm xuất ra, hàm show() sẽ được gọi một lần. Dữ liệu
giá trị được cấp cho single_open() có thể được tìm thấy trong trường riêng tư của
cấu trúc seq_file. Khi sử dụng single_open(), lập trình viên nên sử dụng
single_release() thay vì seq_release() trong cấu trúc file_Operations
để tránh rò rỉ bộ nhớ.