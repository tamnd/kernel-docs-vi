.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/sparc/oradax/oracle-dax.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Trình tăng tốc phân tích dữ liệu Oracle (DAX)
=============================================

DAX là bộ đồng xử lý nằm trên SPARC M7 (DAX1) và M8
(DAX2) chip xử lý và có quyền truy cập trực tiếp vào bộ đệm L3 của CPU
cũng như bộ nhớ vật lý. Nó có thể thực hiện một số thao tác trên dữ liệu
luồng với các định dạng đầu vào và đầu ra khác nhau.  Một người lái xe cung cấp một
cơ chế vận chuyển và có kiến thức hạn chế về các opcode khác nhau
và các định dạng dữ liệu. Thư viện không gian người dùng cung cấp các dịch vụ cấp cao
và dịch chúng thành các lệnh cấp thấp, sau đó được chuyển
vào trình điều khiển và sau đó là Hypervisor và bộ đồng xử lý.
Thư viện là cách được khuyến nghị cho các ứng dụng sử dụng
bộ đồng xử lý và giao diện trình điều khiển không dành cho mục đích sử dụng chung.
Tài liệu này mô tả luồng chung của trình điều khiển,
cấu trúc và giao diện lập trình của nó. Nó cũng cung cấp ví dụ
mã đủ để viết ứng dụng người dùng hoặc kernel sử dụng DAX
chức năng.

Thư viện người dùng là nguồn mở và có sẵn tại:

ZZ0000ZZ

Giao diện Hypervisor với bộ đồng xử lý được mô tả chi tiết trong
tài liệu đi kèm, dax-hv-api.txt, là văn bản thuần túy
đoạn trích của (Nội bộ Oracle) "Máy ảo UltraSPARC
Thông số kỹ thuật" phiên bản 3.0.20+15, ngày 25-09-2017.


Tổng quan cấp cao
===================

Yêu cầu bộ đồng xử lý được mô tả bởi Khối điều khiển lệnh
(CCB). CCB chứa opcode và các thông số khác nhau. mã hoạt động
chỉ định thao tác nào sẽ được thực hiện và các tham số chỉ định
tùy chọn, cờ, kích thước và địa chỉ.  CCB (hoặc một mảng CCB)
được chuyển đến Hypervisor, xử lý việc xếp hàng và lập lịch trình
yêu cầu tới các đơn vị thực thi bộ đồng xử lý có sẵn. Mã trạng thái
trả về cho biết yêu cầu đã được gửi thành công hay chưa
đã có một lỗi.  Một trong những địa chỉ được cung cấp trong mỗi CCB là một
con trỏ tới "vùng hoàn thành", là khối bộ nhớ 128 byte
được bộ đồng xử lý viết để cung cấp trạng thái thực thi. Không
ngắt được tạo ra sau khi hoàn thành; khu vực hoàn thành phải là
được thăm dò bằng phần mềm để biết khi nào giao dịch kết thúc, nhưng
bộ xử lý M7 trở lên cung cấp cơ chế tạm dừng ảo
bộ xử lý cho đến khi trạng thái hoàn thành được cập nhật bởi bộ xử lý
bộ đồng xử lý. Việc này được thực hiện bằng cách sử dụng tải được theo dõi và mwait
hướng dẫn, được mô tả chi tiết hơn sau.  DAX
bộ đồng xử lý được thiết kế sao cho sau khi một yêu cầu được gửi đi,
kernel không còn tham gia vào quá trình xử lý nó nữa.  Việc bỏ phiếu là
được thực hiện ở cấp độ người dùng, điều này dẫn đến độ trễ gần như bằng 0 giữa
hoàn thành yêu cầu và tiếp tục thực hiện yêu cầu
chủ đề.


Địa chỉ bộ nhớ
=================

Kernel không có quyền truy cập vào bộ nhớ vật lý trong Sun4v
kiến trúc, vì có thêm mức độ ảo hóa bộ nhớ
hiện tại. Mức độ trung gian này được gọi là bộ nhớ "thực" và
kernel xử lý điều này như thể nó là vật lý.  Hypervisor xử lý
chuyển đổi giữa bộ nhớ thực và bộ nhớ vật lý sao cho mỗi logic
miền (LDOM) có thể có một phân vùng bộ nhớ vật lý được cách ly
từ các LDOM khác.  Khi kernel thiết lập ánh xạ ảo,
nó chỉ định một địa chỉ ảo và địa chỉ thực mà nó cần tới
được lập bản đồ.

Bộ đồng xử lý DAX chỉ có thể hoạt động trên bộ nhớ vật lý, vì vậy trước khi
yêu cầu có thể được đưa đến bộ đồng xử lý, tất cả các địa chỉ trong CCB phải
được chuyển đổi thành địa chỉ vật lý. Hạt nhân không thể làm điều này vì
nó không có khả năng hiển thị các địa chỉ vật lý. Vì vậy CCB có thể chứa
địa chỉ ảo hoặc thực của bộ đệm hoặc kết hợp
của họ. Trường "loại địa chỉ" có sẵn cho mỗi địa chỉ
có thể được đưa ra trong CCB. Trong mọi trường hợp, Hypervisor sẽ dịch
tất cả các địa chỉ vật lý trước khi gửi đến phần cứng. Địa chỉ
các bản dịch được thực hiện bằng cách sử dụng bối cảnh của quá trình bắt đầu
yêu cầu.


Trình điều khiển API
====================

Một ứng dụng đưa ra yêu cầu tới trình điều khiển thông qua hệ thống write()
gọi và nhận kết quả (nếu có) thông qua read(). Các khu vực hoàn thiện là
có thể truy cập được thông qua mmap() và ở chế độ chỉ đọc cho ứng dụng.

Yêu cầu có thể là một lệnh tức thời hoặc một mảng CCB để
được gửi tới phần cứng.

Mỗi phiên bản mở của thiết bị là độc quyền cho luồng
đã mở nó và phải được luồng đó sử dụng cho tất cả các lần tiếp theo
hoạt động. Chức năng mở trình điều khiển tạo ra một bối cảnh mới cho
thread và khởi tạo nó để sử dụng.  Ngữ cảnh này chứa các con trỏ và
các giá trị được trình điều khiển sử dụng nội bộ để theo dõi các dữ liệu đã gửi
yêu cầu. Vùng đệm hoàn thành cũng được phân bổ và đây là
đủ lớn để chứa các khu vực hoàn thành cho nhiều hoạt động đồng thời
yêu cầu.  Khi đóng thiết bị, mọi giao dịch còn tồn đọng sẽ được
đỏ bừng và bối cảnh được làm sạch.

Trên hệ thống DAX1 (M7), thiết bị sẽ được gọi là "oradax1", trong khi trên hệ thống
Hệ thống DAX2 (M8) sẽ là "oradax2". Nếu một ứng dụng yêu cầu một
hoặc cách khác, nó chỉ cần cố gắng mở thích hợp
thiết bị. Chỉ một trong các thiết bị sẽ tồn tại trên bất kỳ hệ thống nào, do đó
tên có thể được sử dụng để xác định những gì nền tảng hỗ trợ.

Các lệnh ngay lập tức là CCB_DEQUEUE, CCB_KILL và CCB_INFO. cho
tất cả những điều này, thành công được biểu thị bằng giá trị trả về từ write()
bằng số byte được đưa ra trong cuộc gọi. Ngược lại -1 là
được trả về và lỗi được thiết lập.

CCB_DEQUEUE
-----------

Yêu cầu người lái xe dọn sạch các tài nguyên liên quan đến quá khứ
yêu cầu. Vì không có ngắt nào được tạo ra sau khi hoàn thành một
yêu cầu, trình điều khiển phải được thông báo khi nào nó có thể lấy lại tài nguyên.  Không
thông tin trạng thái tiếp theo được trả về, vì vậy người dùng không nên
sau đó gọi read().

CCB_KILL
--------

Giết CCB trong khi thực hiện. CCB được đảm bảo không tiếp tục
thực hiện khi cuộc gọi này trở lại thành công. Khi thành công, read() phải
được gọi để lấy kết quả của hành động.

CCB_INFO
--------

Truy xuất thông tin về CCB hiện đang thực thi. Lưu ý rằng một số
Trình giám sát ảo có thể trả về trạng thái 'không tìm thấy' khi CCB đang ở trạng thái 'đang xử lý'
trạng thái. Để đảm bảo CCB ở trạng thái 'không tìm thấy' sẽ không bao giờ được thực thi,
CCB_KILL phải được gọi trên CCB đó. Khi thành công, read() phải là
được gọi để lấy các chi tiết của hành động.

Đệ trình một loạt CCB để thực hiện
---------------------------------------------

Một write() có độ dài là bội số của kích thước CCB được coi là một
nộp hoạt động. Phần bù tập tin được coi là chỉ mục của
khu vực hoàn thành để sử dụng và có thể được đặt thông qua lseek() hoặc sử dụng
lệnh gọi hệ thống pwrite(). Nếu -1 được trả về thì errno được đặt để chỉ ra
lỗi. Ngược lại, giá trị trả về là độ dài của mảng
thực sự đã được bộ đồng xử lý chấp nhận. Nếu độ dài được chấp nhận là
bằng với độ dài được yêu cầu thì bài nộp đã hoàn tất
thành công và không cần thêm trạng thái nào nữa; do đó, người dùng
sau đó không nên gọi read(). Chấp nhận một phần CCB
mảng được biểu thị bằng giá trị trả về nhỏ hơn độ dài được yêu cầu,
và read() phải được gọi để lấy thêm thông tin trạng thái.  các
trạng thái sẽ phản ánh lỗi do CCB đầu tiên không có
được chấp nhận và status_data sẽ cung cấp dữ liệu bổ sung trong một số trường hợp.

MMAP
----

Hàm mmap() cung cấp quyền truy cập vào khu vực hoàn thành được phân bổ
trong người lái xe.  Lưu ý rằng vùng hoàn thành không thể ghi được bởi
quy trình người dùng và lệnh gọi mmap không được chỉ định PROT_WRITE.


Hoàn thành một yêu cầu
=======================

Byte đầu tiên trong mỗi vùng hoàn thành là trạng thái lệnh được
được cập nhật bởi phần cứng bộ đồng xử lý. Phần mềm có thể lợi dụng
khả năng xử lý M7/M8 mới để thăm dò byte trạng thái này một cách hiệu quả.
Đầu tiên, "tải được giám sát" đạt được thông qua Tải từ không gian thay thế
(ldxa, lduba, v.v.) với ASI 0x84 (ASI_MONITOR_PRIMARY).  Thứ hai, một
"chờ được giám sát" đạt được thông qua lệnh mwait (ghi vào
%asr28). Lệnh này giống như tạm dừng ở chỗ nó tạm dừng việc thực thi
của bộ xử lý ảo trong số nano giây nhất định, nhưng trong
phép cộng sẽ chấm dứt sớm khi một trong nhiều sự kiện xảy ra. Nếu
khối dữ liệu chứa vị trí được giám sát bị sửa đổi, thì
chờ đợi chấm dứt. Điều này khiến phần mềm tiếp tục thực thi ngay lập tức
(không có chuyển đổi ngữ cảnh hoặc kernel sang chuyển đổi người dùng) sau một
giao dịch hoàn tất. Do đó độ trễ giữa việc hoàn thành giao dịch
và việc tiếp tục thực thi có thể chỉ mất vài nano giây.


Vòng đời ứng dụng của một bài gửi DAX
==========================================

- mở thiết bị dax
 - gọi mmap() để lấy địa chỉ khu vực hoàn thành
 - phân bổ CCB và điền opcode, cờ, tham số, địa chỉ, v.v.
 - gửi CCB qua write() hoặc pwrite()
 - đi vào một vòng lặp thực hiện tải được giám sát + chờ được giám sát và
   chấm dứt khi trạng thái lệnh cho biết yêu cầu đã hoàn tất
   (CCB_KILL hoặc CCB_INFO có thể được sử dụng bất cứ lúc nào nếu cần thiết)
 - thực hiện CCB_DEQUEUE
 - gọi munmap() để biết khu vực hoàn thành
 - đóng thiết bị dax


Hạn chế về bộ nhớ
==================

Phần cứng DAX chỉ hoạt động trên các địa chỉ vật lý. Vì vậy, nó là
không nhận thức được ánh xạ bộ nhớ ảo và sự không liên tục có thể
tồn tại trong bộ nhớ vật lý mà bộ đệm ảo ánh xạ tới. có
không có I/O TLB hoặc bất kỳ cơ chế phân tán/thu thập nào. Tất cả các bộ đệm, cho dù đầu vào
hoặc đầu ra, phải nằm trong một vùng bộ nhớ liền kề về mặt vật lý.

Hypervisor dịch tất cả các địa chỉ trong CCB sang địa chỉ vật lý
trước khi giao CCB cho DAX. Hypervisor xác định
kích thước trang ảo cho mỗi địa chỉ ảo được cung cấp và sử dụng kích thước này để
lập trình giới hạn kích thước cho mỗi địa chỉ. Điều này ngăn cản bộ đồng xử lý
từ việc đọc hoặc viết vượt quá giới hạn của trang ảo, thậm chí
mặc dù nó đang truy cập trực tiếp vào bộ nhớ vật lý. Một cách đơn giản hơn
nói điều này là thao tác DAX sẽ không bao giờ "vượt qua" một trang ảo
ranh giới. Nếu sử dụng trang ảo 8k thì dữ liệu sẽ được đảm bảo nghiêm ngặt
giới hạn ở 8k. Nếu bộ đệm của người dùng lớn hơn 8k thì bộ đệm lớn hơn
kích thước trang phải được sử dụng, nếu không kích thước giao dịch sẽ bị cắt bớt thành
8k.

Các trang lớn. Người dùng có thể phân bổ các trang lớn bằng giao diện tiêu chuẩn.
Bộ nhớ đệm nằm trên các trang lớn có thể được sử dụng để đạt được nhiều
quy mô giao dịch DAX lớn hơn, nhưng vẫn phải tuân theo các quy tắc,
và không có giao dịch nào vượt qua ranh giới trang, thậm chí là một trang lớn.  A
cảnh báo chính là Linux trên Sparc thể hiện 8Mb là một trong những dung lượng lớn
kích thước trang. Sparc không thực sự cung cấp kích thước trang phần cứng 8Mb,
và kích thước này được tổng hợp bằng cách dán hai trang 4Mb lại với nhau. các
lý do cho điều này là lịch sử và nó tạo ra một vấn đề bởi vì chỉ
một nửa trang 8Mb này thực sự có thể được sử dụng cho bất kỳ bộ đệm nào trong một
Yêu cầu DAX và phải là nửa đầu hoặc nửa sau;
nó không thể là đoạn 4Mb ở giữa vì nó vượt qua một
ranh giới trang (phần cứng). Lưu ý rằng toàn bộ vấn đề này có thể bị ẩn bởi
thư viện cấp cao hơn.


Cấu trúc CCB
-------------
CCB là một mảng gồm 8 từ 64 bit. Một số từ này cung cấp
mã lệnh, tham số, cờ, v.v. và phần còn lại là địa chỉ
cho vùng hoàn thành, vùng đệm đầu ra và các đầu vào khác nhau::

cấu trúc ccb {
       điều khiển u64;
       hoàn thành u64;
       u64 đầu vào0;
       truy cập u64;
       đầu vào u641;
       u64 op_data;
       đầu ra u64;
       bảng u64;
   };

Xem libdax/common/sys/dax1/dax1_ccb.h để biết mô tả chi tiết về
từng trường này và xem dax-hv-api.txt để biết mô tả đầy đủ
của Hypervisor API có sẵn cho hệ điều hành khách (tức là nhân Linux).

Từ đầu tiên (điều khiển) được người lái xe kiểm tra những điều sau:
 - Phiên bản CCB phải phù hợp với phiên bản phần cứng
 - Opcode, phải là một trong những lệnh được cho phép được ghi lại
 - Loại địa chỉ, phải được đặt thành "ảo" cho tất cả các địa chỉ
   do người dùng đưa ra, qua đó đảm bảo rằng ứng dụng có thể
   chỉ truy cập bộ nhớ mà nó sở hữu


Mã ví dụ
============

DAX có thể truy cập được đối với cả mã người dùng và mã hạt nhân.  Mã hạt nhân
có thể thực hiện siêu lệnh trực tiếp trong khi mã người dùng phải sử dụng trình bao bọc
do tài xế cung cấp. Cách thiết lập của CCB gần như giống hệt nhau đối với
cả hai; sự khác biệt duy nhất là việc chuẩn bị khu vực hoàn thiện. Một
ví dụ về mã người dùng được đưa ra ngay bây giờ, với mã hạt nhân sau đó.

Để lập trình bằng trình điều khiển API, tệp
Arch/sparc/include/uapi/asm/oradax.h phải được bao gồm.

Đầu tiên, thiết bị thích hợp phải được mở. Đối với M7 thì sẽ như vậy
/dev/oradax1 và đối với M8 nó sẽ là /dev/oradax2. Đơn giản nhất
thủ tục là cố gắng mở cả hai, vì chỉ một người sẽ thành công ::

fd = open("/dev/oradax1", O_RDWR);
	nếu (fd < 0)
		fd = open("/dev/oradax2", O_RDWR);
	nếu (fd < 0)
	       /* Không tìm thấy DAX */

Tiếp theo, khu vực hoàn thành phải được ánh xạ::

hoàn thành_area = mmap(NULL, DAX_MMAP_LEN, PROT_READ, MAP_SHARED, fd, 0);

Tất cả các bộ đệm đầu vào và đầu ra phải được chứa đầy đủ trong một phần cứng
trang, vì như đã giải thích ở trên, DAX bị hạn chế nghiêm ngặt bởi
ranh giới trang ảo.  Ngoài ra, bộ đệm đầu ra phải được
Căn chỉnh 64 byte và kích thước của nó phải là bội số của 64 byte vì
bộ đồng xử lý ghi theo đơn vị dòng bộ đệm.

Ví dụ này minh họa lệnh Quét DAX, lấy đầu vào là một
vectơ và giá trị khớp và tạo ra bitmap làm đầu ra. cho
mỗi phần tử đầu vào khớp với giá trị, bit tương ứng là
đặt ở đầu ra.

Trong ví dụ này, vectơ đầu vào bao gồm một chuỗi các bit đơn,
và giá trị khớp là 0. Vì vậy, mỗi bit 0 trong đầu vào sẽ tạo ra 1
ở đầu ra và ngược lại, tạo ra bitmap đầu ra
là bitmap đầu vào bị đảo ngược.

Để biết chi tiết về tất cả các tham số và bit được sử dụng trong CCB này, vui lòng
tham khảo phần 36.2.1.3 của tài liệu DAX Hypervisor API, trong đó
mô tả chi tiết lệnh Quét::

ccb->control = /* Bảng 36.1, Định dạng tiêu đề CCB */
		  (2L << 48) /* lệnh = Giá trị quét */
		| (3L << 40) /* loại địa chỉ đầu ra = ảo chính */
		| (3L << 34) /* loại địa chỉ đầu vào chính = ảo chính */
		             /* Mục 36.2.1, Định dạng lệnh truy vấn CCB */
		| (1 << 28) /* 36.2.1.1.1 định dạng đầu vào chính = đóng gói bit có chiều rộng cố định */
		| (0 << 23) /* 36.2.1.1.2 kích thước phần tử đầu vào chính = 0 (1 bit) */
		| (8 << 10) /* Định dạng đầu ra 36.2.1.1.6 = vectơ bit */
		| (0 << 5) /* 36.2.1.3 Kích thước tiêu chí quét đầu tiên = 0 (1 byte) */
		| (31 << 0);	/* 36.2.1.3 Tắt tiêu chí quét thứ hai */

ccb->hoàn thành = 0;    /* Địa chỉ khu vực hoàn thành, do tài xế điền */

ccb->input0 = đầu vào (dài không dấu); /*địa chỉ đầu vào chính */

ccb->access = /* Mục 36.2.1.2, Kiểm soát truy cập dữ liệu */
		  (2 << 24) /* Định dạng độ dài đầu vào chính = bit */
		| (nbits - 1); /* số bit trong luồng đầu vào chính, trừ 1 */

ccb->input1 = 0;       /*địa chỉ đầu vào phụ, không được sử dụng */

ccb->op_data = 0;      /* tiêu chí quét (giá trị cần khớp) */

ccb->output = đầu ra (dài không dấu);	/*địa chỉ đầu ra */

ccb->bảng = 0;	       /*địa chỉ bảng, không được sử dụng */

Việc gửi CCB là một lệnh gọi hệ thống write() hoặc pwrite() tới
người lái xe. Nếu cuộc gọi thất bại thì hàm read() phải được sử dụng để truy xuất
trạng thái::

if (pwrite(fd, ccb, 64, 0) != 64) {
		trạng thái cấu trúc ccb_exec_result;
		read(fd, &status, sizeof(status));
		/*giải cứu*/
	}

Sau khi gửi thành công CCB, khu vực hoàn thành có thể được
được thăm dò để xác định khi nào DAX kết thúc. Thông tin chi tiết về
nội dung của khu vực hoàn thành có thể được tìm thấy trong phần 36.2.2 của
tài liệu DAX HV API::

trong khi (1) {
		/* Tải được giám sát */
		__asm__ __dễ bay hơi__("lduba [%1] 0x84, %0\n"
				     : "=r" (trạng thái)
				     : "r" (completion_area));

if (trạng thái) /* 0 biểu thị lệnh đang được xử lý */
			phá vỡ;

/* MWAIT */
		__asm__ __volatile__("wr %%g0, 1000, %%asr28\n" ::);    /* 1000 ns */
	}

Trạng thái khu vực hoàn thành là 1 cho biết việc hoàn thành thành công
CCB và tính hợp lệ của bitmap đầu ra, có thể được sử dụng ngay lập tức.
Tất cả các giá trị khác 0 khác biểu thị các điều kiện lỗi
được mô tả trong phần 36.2.2::

if (completion_area[0] != 1) { /* phần 36.2.2, 1 = lệnh đã chạy và thành công */
		/*complete_area[0] chứa trạng thái hoàn thành */
		/* Complete_area[1] chứa mã lỗi, xem 36.2.2 */
	}

Sau khi xử lý xong khu vực hoàn thiện, người lái xe phải
được thông báo rằng nó có thể giải phóng bất kỳ tài nguyên nào liên quan đến
yêu cầu. Điều này được thực hiện thông qua hoạt động dequeue::

struct dax_command cmd;
	cmd.command = CCB_DEQUEUE;
	if (write(fd, &cmd, sizeof(cmd)) != sizeof(cmd)) {
		/*giải cứu*/
	}

Cuối cùng, việc dọn dẹp chương trình thông thường phải được thực hiện, tức là hủy ánh xạ
khu vực hoàn thành, đóng thiết bị dax, giải phóng bộ nhớ, v.v.

Ví dụ về hạt nhân
-----------------

Sự khác biệt duy nhất khi sử dụng DAX trong mã kernel là cách xử lý
của khu vực hoàn thiện. Không giống như các ứng dụng người dùng mmap
vùng hoàn thành do trình điều khiển phân bổ, mã hạt nhân phải phân bổ
bộ nhớ riêng để sử dụng cho vùng hoàn thành, địa chỉ này và địa chỉ của nó
loại phải được đưa ra trong CCB::

ccb->control |= /* Bảng 36.1, Định dạng tiêu đề CCB */
	        (3L << 32);     /* loại địa chỉ vùng hoàn thành = ảo chính */

ccb->completion = (dài không dấu) hoàn thành_area;   /*Địa chỉ khu vực hoàn thiện */

Siêu cuộc gọi gửi dax được thực hiện trực tiếp. Các lá cờ được sử dụng trong
Cuộc gọi ccb_submit được ghi lại trong DAX HV API trong phần 36.3.1/

::

#include <asm/hypervisor.h>

hv_rv = sun4v_ccb_submit((dài chưa dấu)ccb, 64,
				 HV_CCB_QUERY_CMD |
				 HV_CCB_ARG0_PRIVILEGED ZZ0000ZZ
				 HV_CCB_VA_PRIVILEGED,
				 0, &byte_accepted, &status_data);

nếu (hv_rv != HV_EOK) {
		/* hv_rv là mã lỗi, status_data chứa */
		/* trạng thái bổ sung tiềm năng, xem 36.3.1.1 */
	}

Sau khi gửi, mã bỏ phiếu khu vực hoàn thành giống hệt với
trong vùng đất của người dùng::

trong khi (1) {
		/* Tải được giám sát */
		__asm__ __dễ bay hơi__("lduba [%1] 0x84, %0\n"
				     : "=r" (trạng thái)
				     : "r" (completion_area));

if (trạng thái) /* 0 biểu thị lệnh đang được xử lý */
			phá vỡ;

/* MWAIT */
		__asm__ __volatile__("wr %%g0, 1000, %%asr28\n" ::);    /* 1000 ns */
	}

if (completion_area[0] != 1) { /* phần 36.2.2, 1 = lệnh đã chạy và thành công */
		/*complete_area[0] chứa trạng thái hoàn thành */
		/* Complete_area[1] chứa mã lỗi, xem 36.2.2 */
	}

Bitmap đầu ra đã sẵn sàng để sử dụng ngay sau khi
trạng thái hoàn thành cho biết thành công.

Excer[t từ Thông số kỹ thuật máy ảo UltraSPARC
=====================================================

 .. include:: dax-hv-api.txt
    :literal:
