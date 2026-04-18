.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/cdrom/cdrom-standard.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Tiêu chuẩn Linux CD-ROM
==========================

:Tác giả: David van Leeuwen <david@ElseWare.cistron.nl>
:Ngày: 12 tháng 3 năm 1999
:Cập nhật bởi: Erik Andersen (andersee@debian.org)
:Cập nhật bởi: Jens Axboe (axboe@image.dk)


Giới thiệu
============

Linux có lẽ là hệ điều hành giống Unix hỗ trợ
sự đa dạng nhất của các thiết bị phần cứng. Những lý do cho điều này là
có lẽ

- Danh sách lớn các thiết bị phần cứng có sẵn cho nhiều nền tảng
  mà Linux hiện hỗ trợ (ví dụ: i386-PC, Sparc Suns, v.v.)
- Thiết kế mở của hệ điều hành, sao cho bất kỳ ai cũng có thể viết một
  trình điều khiển cho Linux.
- Có rất nhiều mã nguồn làm ví dụ về cách viết trình điều khiển.

Tính mở của Linux và nhiều loại phần mềm có sẵn khác nhau
phần cứng đã cho phép Linux hỗ trợ nhiều thiết bị phần cứng khác nhau.
Thật không may, chính sự cởi mở đã cho phép Linux hỗ trợ
tất cả các thiết bị khác nhau này cũng đã cho phép hoạt động của từng thiết bị
trình điều khiển thiết bị khác nhau đáng kể giữa các thiết bị.
Sự khác biệt về hành vi này rất có ý nghĩa đối với CD-ROM
thiết bị; cách một ổ đĩa cụ thể phản ứng với ZZ0000ZZ ZZ0001ZZ
cuộc gọi khác nhau rất nhiều từ trình điều khiển thiết bị này sang trình điều khiển thiết bị khác. Để tránh làm
trình điều khiển của họ hoàn toàn không nhất quán, người viết Linux CD-ROM
trình điều khiển thường tạo trình điều khiển thiết bị mới bằng cách hiểu, sao chép,
và sau đó thay đổi một cái hiện có. Thật không may, cách làm này đã không
duy trì hành vi thống nhất trên tất cả các trình điều khiển Linux CD-ROM.

Tài liệu này mô tả nỗ lực nhằm thiết lập hành vi thống nhất trên toàn
tất cả các trình điều khiển thiết bị CD-ROM khác nhau dành cho Linux. Tài liệu này cũng
xác định các ZZ0000ZZ khác nhau và cách thiết bị CD-ROM cấp thấp
người lái xe nên thực hiện chúng. Hiện tại (kể từ Linux 2.1.\ ZZ0001ZZ
hạt nhân phát triển) một số trình điều khiển thiết bị CD-ROM cấp thấp, bao gồm
cả IDE/ATAPI và SCSI, hiện đều sử dụng giao diện Đồng nhất này.

Khi CD-ROM được phát triển, giao diện giữa ổ đĩa CD-ROM
và máy tính không được quy định trong tiêu chuẩn. Kết quả là, nhiều
các giao diện CD-ROM khác nhau đã được phát triển. Một số người trong số họ đã có
sở hữu thiết kế độc quyền (Sony, Mitsumi, Panasonic, Philips), khác
các nhà sản xuất đã áp dụng giao diện điện hiện có và thay đổi
chức năng (CreativeLabs/SoundBlaster, Teac, Funai) hoặc đơn giản là
điều chỉnh bộ truyền động của họ cho phù hợp với một hoặc nhiều hệ thống điện hiện có
giao diện (Aztech, Sanyo, Funai, Vertos, Longshine, Optics Storage và
hầu hết các nhà sản xuất ZZ0000ZZ). Trong trường hợp một ổ đĩa mới thực sự
mang giao diện riêng hoặc sử dụng bộ lệnh và điều khiển luồng riêng
sơ đồ, hoặc một trình điều khiển riêng phải được viết hoặc một trình điều khiển hiện có
trình điều khiển đã phải được tăng cường. Lịch sử đã cung cấp cho chúng tôi sự hỗ trợ CD-ROM cho
nhiều giao diện khác nhau. Ngày nay hầu như tất cả CD-ROM đều mới
các ổ đĩa là IDE/ATAPI hoặc SCSI và rất khó có khả năng
nhà sản xuất sẽ tạo ra một giao diện mới. Ngay cả việc tìm kiếm ổ đĩa cho
giao diện độc quyền cũ đang trở nên khó khăn.

Khi (ở phiên bản 1.3.70) tôi nhìn vào giao diện phần mềm hiện có,
được thể hiện thông qua ZZ0000ZZ, nó có vẻ khá hoang dã
tập lệnh và định dạng dữ liệu [#f1]_. Có vẻ như rất nhiều
các tính năng của giao diện phần mềm đã được thêm vào để phù hợp với
khả năng của một ổ đĩa cụ thể, theo cách ZZ0002ZZ. Thêm
quan trọng là có vẻ như hành vi của các lệnh ZZ0001ZZ
là khác nhau đối với hầu hết các trình điều khiển khác nhau: e. g., một số trình điều khiển
đóng khay nếu cuộc gọi ZZ0003ZZ xảy ra khi khay đang mở, trong khi
những người khác thì không. Một số tài xế khóa cửa khi mở thiết bị, để
ngăn chặn một hệ thống tệp không mạch lạc, nhưng những hệ thống khác thì không, để cho phép phần mềm
phóng ra. Không còn nghi ngờ gì nữa, khả năng của các ổ đĩa khác nhau là khác nhau,
nhưng ngay cả khi hai ổ đĩa có cùng khả năng thì trình điều khiển của chúng
hành vi thường khác nhau.

.. [#f1]
   I cannot recollect what kernel version I looked at, then,
   presumably 1.2.13 and 1.3.34 --- the latest kernel that I was
   indirectly involved in.

Tôi quyết định bắt đầu thảo luận về cách tạo tất cả đĩa CD-ROM cho Linux
người lái xe hành xử thống nhất hơn. Tôi bắt đầu bằng cách liên hệ với các nhà phát triển của
nhiều trình điều khiển CD-ROM được tìm thấy trong nhân Linux. Phản ứng của họ
đã khuyến khích tôi viết Trình điều khiển CD-ROM thống nhất mà tài liệu này là
nhằm mục đích mô tả. Việc triển khai Trình điều khiển CD-ROM thống nhất là
trong tệp ZZ0000ZZ. Trình điều khiển này được dự định là một phần mềm bổ sung
nằm trên trình điều khiển thiết bị cấp thấp cho mỗi ổ đĩa CD-ROM.
Bằng cách thêm lớp bổ sung này, có thể có tất cả các
Các thiết bị CD-ROM hoạt động giống như ZZ0001ZZ (trong trường hợp các thiết bị cơ bản
phần cứng sẽ cho phép).

Mục tiêu của Trình điều khiển CD-ROM thống nhất là ZZ0002ZZ để khiến các nhà phát triển trình điều khiển xa lánh
những người chưa thực hiện các bước để hỗ trợ nỗ lực này. Mục tiêu của Đồng phục CD-ROM
Driver đơn giản là để cung cấp cho người viết chương trình ứng dụng cho ổ CD-ROM
Giao diện ZZ0003ZZ Linux CD-ROM với hành vi nhất quán cho tất cả
Thiết bị CD-ROM. Ngoài ra, điều này còn cung cấp một giao diện nhất quán
giữa mã trình điều khiển thiết bị cấp thấp và nhân Linux. Chăm sóc
được coi là có khả năng tương thích 100% với cấu trúc dữ liệu và
giao diện lập trình viên được xác định trong ZZ0000ZZ. Hướng dẫn này được viết cho
giúp các nhà phát triển trình điều khiển CD-ROM điều chỉnh mã của họ để sử dụng Thống nhất CD-ROM
Mã trình điều khiển được xác định trong ZZ0001ZZ.

Cá nhân tôi nghĩ rằng giao diện phần cứng quan trọng nhất là
các ổ IDE/ATAPI và tất nhiên cả các ổ SCSI, nhưng về mặt giá cả
phần cứng giảm liên tục, cũng có khả năng là mọi người có thể gặp phải
nhiều hơn một ổ đĩa CD-ROM, có thể có nhiều loại khác nhau. Nó quan trọng
rằng những ổ đĩa này hoạt động theo cùng một cách. Vào tháng 12 năm 1994, một trong những
ổ đĩa CD-ROM rẻ nhất là cm206 của Philips, độc quyền tốc độ gấp đôi
lái xe. Trong những tháng tôi bận viết trình điều khiển Linux cho nó,
các ổ đĩa độc quyền đã trở nên lỗi thời và các ổ đĩa IDE/ATAPI đã trở thành
tiêu chuẩn. Tại thời điểm cập nhật tài liệu này lần cuối (tháng 11
1997), ngay cả ZZ0000ZZ cũng khó có thể đạt được bất cứ điều gì ít hơn một
Ổ đĩa CD-ROM 16 tốc độ và ổ đĩa 24 tốc độ là phổ biến.

.. _cdrom_api:

Tiêu chuẩn hóa thông qua cấp độ phần mềm khác
============================================

Vào thời điểm tài liệu này được hình thành, tất cả các trình điều khiển trực tiếp
đã triển khai các cuộc gọi CD-ROM ZZ0000ZZ thông qua các quy trình riêng của họ. Cái này
dẫn đến nguy cơ nhiều tài xế quên làm việc quan trọng
giống như kiểm tra xem người dùng có cung cấp cho trình điều khiển dữ liệu hợp lệ hay không. Thêm
quan trọng là điều này đã dẫn đến sự khác biệt trong hành vi, vốn đã
đã được thảo luận.

Vì lý do này, Trình điều khiển CD-ROM thống nhất đã được tạo để thực thi nhất quán
Hoạt động của ổ đĩa CD-ROM và để cung cấp một bộ dịch vụ chung cho nhiều loại ổ đĩa khác nhau.
trình điều khiển thiết bị CD-ROM cấp thấp. Trình điều khiển CD-ROM thống nhất hiện cung cấp một trình điều khiển khác
cấp độ phần mềm, phân biệt việc triển khai ZZ0001ZZ và ZZ0002ZZ
từ việc triển khai phần cứng thực tế. Lưu ý rằng nỗ lực này có
đã thực hiện một số thay đổi sẽ ảnh hưởng đến chương trình ứng dụng của người dùng. các
thay đổi lớn nhất liên quan đến việc di chuyển nội dung của các cấp độ thấp khác nhau
Các tệp tiêu đề của trình điều khiển CD-ROM vào thư mục cdrom của kernel. Đây là
được thực hiện để giúp đảm bảo rằng người dùng chỉ được cung cấp một cdrom
giao diện, giao diện được xác định trong ZZ0000ZZ.

Ổ đĩa CD-ROM đủ cụ thể (tức là khác với các ổ đĩa khác).
khối thiết bị như ổ đĩa mềm hoặc đĩa cứng), để xác định một bộ
của ZZ0000ZZ, ZZ0001ZZ thông thường.
Các thao tác này khác với tệp thiết bị khối cổ điển
hoạt động, ZZ0002ZZ.

Các quy trình dành cho cấp độ giao diện Trình điều khiển CD-ROM thống nhất được triển khai
trong tệp ZZ0000ZZ. Trong tệp này, các giao diện Trình điều khiển CD-ROM thống nhất
với kernel như một thiết bị khối bằng cách đăng ký chung sau
ZZ0001ZZ::

struct file_Operation cdrom_fops = {
		NULL, /* lseek */
		block _read , /* read--chung đọc block-dev */
		block _write, /* write--general block-dev write */
		NULL, /* readdir */
		NULL, /* chọn */
		cdrom_ioctl, /* ioctl */
		NULL, /* mmap */
		cdrom_open, /* mở */
		cdrom_release, /* phát hành */
		NULL, /* fsync */
		NULL, /* fasync */
		NULL /* xác nhận lại */
	};

Mọi thiết bị CD-ROM đang hoạt động đều chia sẻ ZZ0002ZZ này. Các thói quen
được khai báo ở trên đều được triển khai trong ZZ0000ZZ, vì tệp này là
nơi xác định hành vi của tất cả các thiết bị CD-ROM và
được tiêu chuẩn hóa. Giao diện thực tế của các loại CD-ROM khác nhau
phần cứng vẫn được thực hiện bởi nhiều thiết bị CD-ROM cấp thấp khác nhau
trình điều khiển. Những thói quen này chỉ đơn giản là thực hiện một số ZZ0001ZZ nhất định
chung cho tất cả CD-ROM (và thực sự, tất cả các phương tiện lưu trữ di động
thiết bị).

Việc đăng ký trình điều khiển thiết bị CD-ROM cấp thấp hiện được thực hiện thông qua
các quy trình chung trong ZZ0000ZZ, không thông qua Hệ thống tệp ảo
(VFS) nữa. Giao diện được triển khai trong ZZ0001ZZ được thực hiện
thông qua hai cấu trúc chung có chứa thông tin về
khả năng của trình điều khiển và các ổ đĩa cụ thể mà trên đó
người lái xe vận hành. Các cấu trúc là:

cdrom_device_ops
  Cấu trúc này chứa thông tin về trình điều khiển cấp thấp cho một
  Thiết bị CD-ROM. Cấu trúc này về mặt khái niệm được kết nối với phần chính
  số lượng thiết bị (mặc dù một số trình điều khiển có thể có
  số chính, như trường hợp của trình điều khiển IDE).

cdrom_device_info
  Cấu trúc này chứa thông tin về ổ đĩa CD-ROM cụ thể,
  chẳng hạn như tên thiết bị, tốc độ, v.v. Cấu trúc này về mặt khái niệm
  được kết nối với số nhỏ của thiết bị.

Đăng ký ổ đĩa CD-ROM cụ thể với Trình điều khiển CD-ROM thống nhất
được thực hiện bởi trình điều khiển thiết bị cấp thấp thông qua lệnh gọi tới ::

register_cdrom(struct cdrom_device_info * <device>_info)

Cấu trúc thông tin thiết bị, ZZ0000ZZ, chứa tất cả các
thông tin cần thiết để kernel giao tiếp với cấp độ thấp
Trình điều khiển thiết bị CD-ROM. Một trong những mục quan trọng nhất trong này
cấu trúc là một con trỏ tới cấu trúc ZZ0001ZZ của
trình điều khiển cấp thấp.

Cấu trúc hoạt động của thiết bị, ZZ0001ZZ, chứa một danh sách
của các con trỏ tới các chức năng được thực hiện ở cấp độ thấp
trình điều khiển thiết bị. Khi ZZ0000ZZ truy cập vào thiết bị CD-ROM, nó sẽ thực hiện điều đó
thông qua các chức năng trong cấu trúc này. Không thể biết hết được
khả năng của các ổ đĩa CD-ROM trong tương lai, vì vậy người ta mong đợi rằng điều này
danh sách có thể cần được mở rộng theo thời gian vì các công nghệ mới đang
được phát triển. Ví dụ, các ổ đĩa CD-R và CD-R/W đang bắt đầu trở nên phổ biến.
phổ biến và sẽ sớm cần thêm hỗ trợ cho chúng. Hiện tại,
ZZ0002ZZ hiện tại là::

cấu trúc cdrom_device_ops {
		int (ZZ0000ZZ, int)
		khoảng trống (ZZ0001ZZ);
		int (ZZ0002ZZ, int);
		int không dấu (ZZ0003ZZ,
					     int không dấu, int);
		int (ZZ0004ZZ, int);
		int (ZZ0005ZZ, int);
		int (ZZ0006ZZ, int);
		int (ZZ0007ZZ, dài không dấu);
		int (ZZ0008ZZ,
					 struct cdrom_multisession *);
		int (ZZ0009ZZ, struct cdrom_mcn *);
		int (ZZ0010ZZ);
		int (ZZ0011ZZ,
				   int không dấu, void *);
		khả năng const int;		/* cờ khả năng */
		int (ZZ0012ZZ,
				      cấu trúc packet_command *);
	};

Khi trình điều khiển thiết bị cấp thấp triển khai một trong các khả năng này,
cần thêm một con trỏ hàm vào ZZ0000ZZ này. Khi một điều cụ thể
tuy nhiên, chức năng này không được triển khai, ZZ0001ZZ này phải chứa một
Thay vào đó là NULL. Cờ ZZ0002ZZ chỉ định khả năng của
Phần cứng CD-ROM và/hoặc trình điều khiển CD-ROM cấp thấp khi ổ đĩa CD-ROM
được đăng ký với Trình điều khiển thống nhất CD-ROM.

Lưu ý rằng hầu hết các hàm đều có ít tham số hơn
đối tác ZZ0000ZZ. Điều này là do rất ít trong số
thông tin trong các cấu trúc ZZ0001ZZ và ZZ0002ZZ được sử dụng. Đối với hầu hết
trình điều khiển, tham số chính là ZZ0003ZZ ZZ0004ZZ, từ
mà số chính và số phụ có thể được trích xuất. (Mức độ thấp nhất
Tuy nhiên, trình điều khiển CD-ROM thậm chí không nhìn vào số chính và số phụ,
vì nhiều trong số chúng chỉ hỗ trợ một thiết bị.) Tính năng này sẽ có sẵn
thông qua ZZ0005ZZ trong ZZ0006ZZ được mô tả bên dưới.

Thông tin nhỏ, dành riêng cho ổ đĩa được đăng ký với
ZZ0000ZZ, hiện chứa các trường sau::

cấu trúc cdrom_device_info {
	const struct cdrom_device_ops * ops;	/* hoạt động của thiết bị cho chuyên ngành này */
	danh sách struct list_head;			/* danh sách liên kết của tất cả thông tin thiết bị */
	struct gendisk * đĩa;			/* đĩa lớp khối phù hợp */
	void * xử lý;				/*dữ liệu phụ thuộc vào trình điều khiển */

mặt nạ int;				/* mặt nạ khả năng: vô hiệu hóa chúng */
	tốc độ int;				/*tốc độ đọc dữ liệu tối đa */
	công suất int;				/* số lượng đĩa trong máy hát tự động */

tùy chọn int không dấu: 30;		/* cờ tùy chọn */
	mc_flags không dấu:2;			/* cờ đệm thay đổi phương tiện */
	unsign int vfs_events;		/* sự kiện được lưu trong bộ nhớ đệm cho đường dẫn vfs */
	unsigned int ioctl_events;		/* sự kiện được lưu trong bộ nhớ đệm cho đường dẫn ioctl */
	int use_count;				/*số lần mở thiết bị */
	tên char[20];				/*tên loại thiết bị */

__u8 sanyo_slot : 2;			/* Hỗ trợ bộ đổi 3-CD Sanyo */
	__u8 bị khóa : 1;			/* Trạng thái CDROM_LOCKDOOR */
	__u8 dành riêng: 5;			/*chưa được sử dụng */
	int cdda_method;			/* xem cờ CDDA_* */
	__u8 cuối_sense;			/* lưu lại khóa giác quan cuối cùng */
	__u8 media_writing;			/* cờ bẩn, sổ sách kế toán DVD+RW */
	mmc3_profile ngắn không dấu;		/* hồ sơ MMC3 hiện tại */
	int for_data;				/* không xác định:TBD */
	int mrw_mode_page;			/* trang chế độ MRW nào đang được sử dụng */
  };

Sử dụng ZZ0000ZZ này, danh sách liên kết của các thiết bị nhỏ đã đăng ký sẽ được cung cấp
được xây dựng bằng cách sử dụng trường ZZ0001ZZ. Số thiết bị, hoạt động của thiết bị
Cấu trúc và thông số kỹ thuật của các thuộc tính của ổ đĩa được lưu trữ trong này
cấu trúc.

Cờ ZZ0000ZZ có thể được sử dụng để che giấu một số khả năng được liệt kê
trong ZZ0001ZZ, nếu một ổ đĩa cụ thể không hỗ trợ tính năng
của người lái xe. Giá trị ZZ0002ZZ chỉ định tốc độ đầu tối đa của
ổ đĩa, được đo bằng đơn vị tốc độ âm thanh bình thường (dữ liệu thô 176kB/giây hoặc
dữ liệu hệ thống tệp 150kB/giây). Các thông số được khai báo ZZ0003ZZ
bởi vì chúng mô tả các đặc tính của ổ đĩa, những đặc tính này không thay đổi sau
đăng ký.

Một số thanh ghi chứa các biến cục bộ của ổ CD-ROM. các
cờ ZZ0002ZZ được sử dụng để chỉ định cách hoạt động chung của CD-ROM
nên cư xử. Những thanh ghi cờ khác nhau này sẽ cung cấp đủ
linh hoạt để thích ứng với mong muốn của người dùng khác nhau (và ZZ0001ZZ
ZZ0000ZZ mong muốn của tác giả trình điều khiển thiết bị cấp thấp, cũng như
trường hợp trong sơ đồ cũ). Thanh ghi ZZ0003ZZ được sử dụng để đệm
thông tin từ ZZ0004ZZ đến hai hàng đợi riêng biệt. Khác
dữ liệu dành riêng cho một ổ đĩa nhỏ, có thể được truy cập thông qua ZZ0005ZZ,
có thể trỏ đến cấu trúc dữ liệu dành riêng cho trình điều khiển cấp thấp.
Các trường ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ và ZZ0009ZZ không cần thiết
được khởi tạo.

Lớp phần mềm trung gian mà ZZ0000ZZ hình thành sẽ thực hiện một số
kế toán bổ sung. Số lần sử dụng của thiết bị (số lượng
các tiến trình đã mở thiết bị) được đăng ký trong ZZ0002ZZ. các
chức năng ZZ0003ZZ sẽ xác minh vùng bộ nhớ người dùng phù hợp
để đọc và ghi, và trong trường hợp một vị trí trên đĩa CD được truyền đi,
nó sẽ định dạng ZZ0001ZZ bằng cách gửi yêu cầu tới cấp thấp
trình điều khiển ở định dạng chuẩn và dịch tất cả các định dạng giữa
phần mềm người dùng và trình điều khiển cấp thấp. Điều này làm giảm bớt phần lớn sự mệt mỏi của người lái xe
kiểm tra bộ nhớ, kiểm tra định dạng và dịch thuật. Ngoài ra, điều cần thiết
cấu trúc sẽ được khai báo trên ngăn xếp chương trình.

Việc thực hiện các chức năng phải được xác định trong
các phần sau. Hai chức năng ZZ0000ZZ được triển khai, đó là
ZZ0001ZZ và ZZ0002ZZ. Các chức năng khác có thể được bỏ qua,
cờ khả năng tương ứng sẽ bị xóa khi đăng ký.
Nói chung, một hàm trả về 0 nếu thành công và âm nếu có lỗi. A
lệnh gọi hàm chỉ được trả về sau khi lệnh đã hoàn thành, nhưng
Tất nhiên việc chờ đợi thiết bị không nên sử dụng thời gian xử lý.

::

int open(struct cdrom_device_info *cdi, mục đích int)

ZZ0000ZZ nên thử mở thiết bị để tìm ZZ0001ZZ cụ thể,
có thể là:

- Mở để đọc dữ liệu, như được thực hiện bởi ZZ0000ZZ (2), hoặc
  lệnh người dùng ZZ0001ZZ hoặc ZZ0002ZZ.
- Mở các lệnh ZZ0003ZZ, như được thực hiện bởi các chương trình phát âm thanh-CD.

Lưu ý rằng bất kỳ mã chiến lược nào (đóng khay trên ZZ0001ZZ, v.v.) đều là
được thực hiện bằng thủ tục gọi trong ZZ0000ZZ, vì vậy thủ tục cấp thấp
chỉ nên quan tâm đến việc khởi tạo thích hợp, chẳng hạn như quay
lên đĩa, v.v.

::

phát hành vô hiệu (struct cdrom_device_info *cdi)

Nên thực hiện các hành động dành riêng cho thiết bị, chẳng hạn như tắt thiết bị.
Tuy nhiên, các hành động chiến lược như đẩy khay ra hoặc mở khóa
cửa, nên để lại quy trình chung ZZ0000ZZ.
Đây là hàm duy nhất trả về kiểu ZZ0001ZZ.

.. _cdrom_drive_status:

::

int drive_status(struct cdrom_device_info *cdi, int slot_nr)

Hàm ZZ0001ZZ, nếu được triển khai, sẽ cung cấp
thông tin về trạng thái của ổ đĩa (không phải trạng thái của đĩa,
có thể có hoặc không có trong ổ đĩa). Nếu ổ đĩa không phải là bộ chuyển đổi,
ZZ0002ZZ nên được bỏ qua. Trong ZZ0000ZZ, các khả năng được liệt kê::


CDS_NO_INFO /* không có thông tin */
	CDS_NO_DISC /* không đưa đĩa vào, khay bị đóng */
	CDS_TRAY_OPEN /* khay được mở */
	CDS_DRIVE_NOT_READY /* có vấn đề gì đó, khay đang di chuyển? */
	CDS_DISC_OK /* một đĩa đã được tải và mọi thứ đều ổn */

::

int khay_move(struct cdrom_device_info *cdi, vị trí int)

Chức năng này, nếu được triển khai, sẽ kiểm soát chuyển động của khay. (Không
chức năng khác sẽ kiểm soát điều này.) Tham số ZZ0000ZZ điều khiển
hướng chuyển động mong muốn:

- 0 Đóng khay
- 1 khay mở

Hàm này trả về 0 khi thành công và trả về giá trị khác 0 khi
lỗi. Lưu ý rằng nếu khay đã ở vị trí mong muốn thì không
cần thực hiện hành động và giá trị trả về phải là 0.

::

int lock_door(struct cdrom_device_info *cdi, int lock)

Chức năng này (và không có mã nào khác) điều khiển việc khóa cửa, nếu
ổ đĩa cho phép điều này. Giá trị của ZZ0000ZZ kiểm soát khóa mong muốn
tiểu bang:

- 0 Mở khóa cửa, cho phép mở bằng tay
- 1 Khóa cửa, khay không thể đẩy ra bằng tay

Hàm này trả về 0 khi thành công và trả về giá trị khác 0 khi
lỗi. Lưu ý rằng nếu cửa đã ở trạng thái được yêu cầu thì không
cần thực hiện hành động và giá trị trả về phải là 0.

::

int select_speed(struct cdrom_device_info *cdi, tốc độ dài không dấu)

Một số ổ đĩa CD-ROM có khả năng thay đổi tốc độ đầu của chúng. Ở đó
là một số lý do làm thay đổi tốc độ của ổ CD-ROM. Tệ
CD-ROM được nhấn có thể được hưởng lợi từ tốc độ đầu thấp hơn mức tối đa. hiện đại
Ổ đĩa CD-ROM có thể đạt tốc độ đầu rất cao (lên đến ZZ0000ZZ là
chung). Đã có thông báo rằng những ổ đĩa này có thể giúp việc đọc
xảy ra lỗi ở tốc độ cao này, việc giảm tốc độ có thể ngăn ngừa mất dữ liệu
trong những hoàn cảnh này. Cuối cùng, một số ổ đĩa này có thể
tạo ra tiếng ồn lớn khó chịu, tốc độ thấp hơn có thể giảm bớt.

Chức năng này chỉ định tốc độ đọc dữ liệu hoặc âm thanh được
phát lại. Giá trị của ZZ0003ZZ chỉ định tốc độ đầu của
ổ đĩa, được đo bằng đơn vị tốc độ cdrom tiêu chuẩn (dữ liệu thô 176kB/giây
hoặc dữ liệu hệ thống tệp 150kB/giây). Vì vậy để yêu cầu một ổ đĩa CD-ROM
hoạt động ở tốc độ 300kB/giây, bạn sẽ gọi CDROM_SELECT_SPEED ZZ0004ZZ
với ZZ0005ZZ. Giá trị đặc biệt ZZ0000ZZ có nghĩa là ZZ0001ZZ, i. e.,
tốc độ dữ liệu tối đa hoặc tốc độ âm thanh thời gian thực. Nếu ổ đĩa không có
khả năng ZZ0002ZZ này, quyết định sẽ được đưa ra dựa trên
đĩa hiện tại được tải và giá trị trả về phải dương. Một tiêu cực
giá trị trả về cho biết có lỗi.

::

int get_last_session(struct cdrom_device_info *cdi,
			     cấu trúc cdrom_multisession *ms_info)

Chức năng này sẽ triển khai ZZ0003ZZ tương ứng cũ. cho
thiết bị ZZ0004ZZ, bắt đầu phiên cuối cùng của đĩa hiện tại
phải được trả về trong đối số con trỏ ZZ0005ZZ. Lưu ý rằng
các quy trình trong ZZ0000ZZ đã làm rõ đối số này: nó được yêu cầu
định dạng ZZ0002ZZ sẽ thuộc loại ZZ0006ZZ (khối tuyến tính
chế độ địa chỉ), bất kể phần mềm gọi điện yêu cầu. Nhưng
vệ sinh thậm chí còn đi xa hơn: việc thực hiện ở mức độ thấp có thể
trả lại thông tin được yêu cầu ở định dạng ZZ0007ZZ nếu muốn
(thiết lập trường ZZ0008ZZ một cách thích hợp, của
khóa học) và các quy trình trong ZZ0001ZZ sẽ thực hiện chuyển đổi nếu
cần thiết. Giá trị trả về là 0 khi thành công.

::

int get_mcn(struct cdrom_device_info *cdi,
		    cấu trúc cdrom_mcn *mcn)

Một số đĩa có ZZ0000ZZ (MCN), còn được gọi là
ZZ0001ZZ (UPC). Con số này phải phản ánh số
thường được tìm thấy trong mã vạch trên sản phẩm. Thật không may,
một số ít đĩa mang số như vậy trên đĩa thậm chí không sử dụng
cùng một định dạng. Đối số trả về của hàm này là một con trỏ tới một
vùng bộ nhớ được khai báo trước thuộc loại ZZ0002ZZ. MCN là
dự kiến là một chuỗi 13 ký tự, được kết thúc bằng ký tự null.

::

thiết lập lại int(struct cdrom_device_info *cdi)

Lệnh gọi này sẽ thực hiện việc thiết lập lại cứng trên ổ đĩa (mặc dù trong
Trong trường hợp cần thiết lập lại cứng, ổ đĩa rất có thể không
nghe lệnh nữa). Tốt nhất là quyền kiểm soát được trả lại cho
chỉ người gọi sau khi ổ đĩa đã thiết lập lại xong. Nếu ổ đĩa không
nghe lâu hơn, có thể là khôn ngoan đối với cdrom cấp thấp cơ bản
tài xế hết giờ.

::

int audio_ioctl(struct cdrom_device_info *cdi,
			int cmd không dấu, void *arg)

Một số CD-ROM-\ ZZ0002ZZ\ được xác định trong ZZ0000ZZ có thể
được thực hiện bởi các thủ tục được mô tả ở trên, và do đó chức năng
ZZ0003ZZ sẽ sử dụng chúng. Tuy nhiên, hầu hết các giao dịch của ZZ0004ZZ đều có
điều khiển âm thanh. Chúng tôi đã quyết định để những thứ này được truy cập thông qua một
hàm đơn, lặp lại các đối số ZZ0005ZZ và ZZ0006ZZ. Lưu ý rằng
cái sau thuộc loại ZZ0007ZZ, thay vì ZZ0008ZZ.
Quy trình ZZ0009ZZ thực hiện một số điều hữu ích,
mặc dù. Nó vệ sinh loại định dạng địa chỉ thành ZZ0010ZZ (Phút,
Giây, Khung) cho tất cả cuộc gọi âm thanh. Nó cũng xác minh bộ nhớ
vị trí của ZZ0011ZZ và dự trữ bộ nhớ ngăn xếp cho đối số. Cái này
làm cho việc triển khai ZZ0012ZZ đơn giản hơn nhiều so với trong
sơ đồ điều khiển cũ. Ví dụ, bạn có thể tra cứu hàm
ZZ0013ZZ ZZ0001ZZ cần được cập nhật
tài liệu này.

Một ioctl chưa được triển khai sẽ trả về ZZ0000ZZ, nhưng một yêu cầu vô hại
(ví dụ: ZZ0001ZZ) có thể bị bỏ qua bằng cách trả về 0 (thành công). Khác
lỗi phải theo tiêu chuẩn, bất kể chúng là gì. Khi nào
lỗi được trả về bởi trình điều khiển cấp thấp, Trình điều khiển CD-ROM thống nhất
cố gắng bất cứ khi nào có thể để trả lại mã lỗi cho chương trình gọi.
(Tuy nhiên, chúng tôi có thể quyết định loại bỏ giá trị trả về trong ZZ0002ZZ, trong
để đảm bảo giao diện thống nhất cho phần mềm trình phát âm thanh.)

::

int dev_ioctl(struct cdrom_device_info *cdi,
		      int cmd không dấu, arg dài không dấu)

Một số ZZ0001ZZ dường như dành riêng cho một số ổ đĩa CD-ROM nhất định. Đó là,
chúng được giới thiệu để phục vụ một số khả năng của một số ổ đĩa nhất định. trong
thực tế, có 6 ZZ0002ZZ khác nhau để đọc dữ liệu, trong một số
loại định dạng cụ thể hoặc dữ liệu âm thanh. Không có nhiều ổ đĩa hỗ trợ
đọc các đoạn âm thanh dưới dạng dữ liệu, tôi tin rằng điều này là do sự bảo vệ
về bản quyền của các nghệ sĩ. Hơn nữa, tôi nghĩ rằng nếu các bản âm thanh được
được hỗ trợ, việc này phải được thực hiện thông qua VFS chứ không phải qua ZZ0003ZZ. A
vấn đề ở đây có thể là khung âm thanh dài 2352 byte,
vì vậy hệ thống tệp âm thanh sẽ yêu cầu 75264 byte cùng một lúc
(bội số chung nhỏ nhất của 512 và 2352), hoặc trình điều khiển nên
họ quay lưng lại để đối phó với sự không mạch lạc này (mà tôi sẽ làm
phản đối). Hơn nữa, phần cứng rất khó tìm thấy
ranh giới khung chính xác vì không có tiêu đề đồng bộ hóa
trong khung âm thanh. Khi những vấn đề này được giải quyết, mã này sẽ được
được tiêu chuẩn hóa trong ZZ0000ZZ.

Bởi vì có rất nhiều ZZ0002ZZ dường như được giới thiệu
đáp ứng các trình điều khiển nhất định [#f2]_, mọi ZZ0003ZZ\ s không chuẩn
được định tuyến thông qua cuộc gọi ZZ0004ZZ. Về nguyên tắc, ZZ0000ZZ
ZZ0005ZZ\ 's phải được đánh số sau số chính của thiết bị chứ không phải
số CD-ROM ZZ0006ZZ chung, ZZ0001ZZ. Hiện nay
ZZ0007ZZ không được hỗ trợ là:

CDROMREADMODE1, CDROMREADMODE2, CDROMREADAUDIO, CDROMREADRAW,
	CDROMREADCOOKED, CDROMSEEK, CDROMPLAY-BLK và CDROM-READALL

.. [#f2]

   Is there software around that actually uses these? I'd be interested!

.. _cdrom_capabilities:

Khả năng của CD-ROM
-------------------

Thay vì chỉ thực hiện một số lệnh gọi ZZ0003ZZ, giao diện trong
ZZ0000ZZ cung cấp khả năng chỉ ra ZZ0002ZZ
của ổ đĩa CD-ROM. Điều này có thể được thực hiện bằng cách ORing bất kỳ số lượng
hằng số khả năng được xác định trong ZZ0001ZZ khi đăng ký
giai đoạn. Hiện tại, các khả năng là::

CDC_CLOSE_TRAY /* có thể đóng khay bằng điều khiển phần mềm */
	CDC_OPEN_TRAY /* có thể mở khay */
	CDC_LOCK /* có thể khóa và mở khóa cửa */
	CDC_SELECT_SPEED /* có thể chọn tốc độ, theo đơn vị * sim*150 ,kB/s */
	CDC_SELECT_DISC /* ổ đĩa là máy hát tự động */
	CDC_MULTI_SESSION /* có thể đọc phiên ZZ0001ZZ */
	CDC_MCN /* có thể đọc Số danh mục phương tiện */
	CDC_MEDIA_CHANGED /* có thể báo cáo nếu đĩa đã thay đổi */
	CDC_PLAY_AUDIO /* có thể thực hiện các chức năng âm thanh (phát, tạm dừng, v.v.) */
	CDC_RESET /* thiết bị reset cứng */
	Trình điều khiển CDC_IOCTLS /* có ioctls không chuẩn */
	CDC_DRIVE_STATUS /* trình điều khiển thực hiện trạng thái ổ đĩa */

Cờ khả năng được khai báo là ZZ0001ZZ, để ngăn trình điều khiển
vô tình làm xáo trộn nội dung. Các lá cờ khả năng thực sự
thông báo cho ZZ0000ZZ về những gì người lái xe có thể làm. Nếu ổ đĩa được tìm thấy
bởi người lái xe không có khả năng, có thể bị che giấu bởi
biến ZZ0002ZZ ZZ0003ZZ. Ví dụ: SCSI CD-ROM
trình điều khiển đã triển khai mã để tải và đẩy đĩa CD-ROM, và
do đó các cờ tương ứng của nó trong ZZ0004ZZ sẽ được đặt. Nhưng một chiếc SCSI
Ổ đĩa CD-ROM có thể là một hệ thống caddy, không thể nạp khay và
do đó đối với ổ đĩa này, cấu trúc ZZ0005ZZ sẽ được thiết lập
bit ZZ0006ZZ trong ZZ0007ZZ.

Trong tệp ZZ0000ZZ bạn sẽ gặp nhiều cấu trúc kiểu::

if (cdo->capability & ~cdi->mask & CDC _<capability>) ...

Không có ZZ0002ZZ để đắp mặt nạ... Lý do là vậy
Tôi nghĩ tốt hơn là nên điều khiển ZZ0000ZZ hơn là
ZZ0001ZZ.

Tùy chọn
-------

Thanh ghi cờ cuối cùng điều khiển ZZ0000ZZ của CD-ROM
ổ đĩa, để đáp ứng mong muốn của người dùng khác nhau, hy vọng
độc lập với ý tưởng của tác giả tương ứng, người đã tình cờ
đã cung cấp hỗ trợ ổ đĩa cho cộng đồng Linux. các
các tùy chọn hành vi hiện tại là::

CDO_AUTO_CLOSE /* cố gắng đóng khay khi thiết bị mở() */
	CDO_AUTO_EJECT /* thử mở khay trên thiết bị cuối cùng đóng() */
	CDO_USE_FFLAGS /* sử dụng file_pointer->f_flags để biểu thị mục đích của open() */
	CDO_LOCK /* thử khóa cửa nếu thiết bị được mở */
	CDO_CHECK_TYPE /* đảm bảo loại đĩa là dữ liệu nếu được mở để lấy dữ liệu */

Giá trị ban đầu của thanh ghi này là
ZZ0000ZZ, phản ánh quan điểm của tôi về người dùng
các tiêu chuẩn về giao diện và phần mềm. Trước khi bạn phản đối, có hai
ZZ0002ZZ mới được triển khai trong ZZ0001ZZ, cho phép bạn kiểm soát
hành vi bằng phần mềm. Đó là::

CDROM_SET_OPTIONS /* đặt các tùy chọn được chỉ định trong (int)arg */
	CDROM_CLEAR_OPTIONS /* xóa các tùy chọn được chỉ định trong (int)arg */

Một tùy chọn cần giải thích thêm: ZZ0000ZZ. Trong phần tiếp theo
phần mới, chúng tôi giải thích sự cần thiết của tùy chọn này.

Gói phần mềm ZZ0000ZZ, có sẵn từ bản phân phối Debian
và ZZ0001ZZ, cho phép người dùng kiểm soát các cờ này.


Cần biết mục đích mở thiết bị CD-ROM
=========================================================

Theo truyền thống, các thiết bị Unix có thể được sử dụng trong hai ZZ0000ZZ khác nhau,
bằng cách đọc/ghi vào tập tin thiết bị hoặc bằng cách phát hành
điều khiển các lệnh đến thiết bị, bằng ZZ0003ZZ của thiết bị
gọi. Vấn đề với ổ đĩa CD-ROM là chúng có thể được sử dụng cho
hai mục đích hoàn toàn khác nhau. Một là gắn có thể tháo rời
hệ thống tập tin, CD-ROM, cái còn lại là phát đĩa CD âm thanh. Lệnh âm thanh
được triển khai hoàn toàn thông qua ZZ0004ZZ, có lẽ là do
lần triển khai đầu tiên (SUN?) là như vậy. Về nguyên tắc có
điều này không có gì sai, nhưng việc kiểm soát tốt nhu cầu của ZZ0001ZZ
rằng thiết bị có thể mở ZZ0002ZZ để cung cấp
Các lệnh ZZ0005ZZ, bất kể trạng thái của ổ đĩa.

Mặt khác, khi được sử dụng làm ổ đĩa phương tiện di động (điều gì
mục đích ban đầu của CD-ROM là) chúng tôi muốn đảm bảo rằng
ổ đĩa sẵn sàng hoạt động khi mở thiết bị. Trong cái cũ
sơ đồ, một số trình điều khiển CD-ROM không thực hiện bất kỳ kiểm tra tính toàn vẹn nào, dẫn đến
trong một số lỗi I/O được VFS báo cáo cho kernel khi một
xảy ra nỗ lực gắn CD-ROM vào một ổ đĩa trống. Đây không phải là một
cách đặc biệt tao nhã để phát hiện ra rằng không có CD-ROM được lắp vào;
nó ít nhiều trông giống như IBM-PC cũ đang cố đọc một đĩa mềm trống
lái xe trong vài giây, sau đó hệ thống sẽ phàn nàn về điều đó
không thể đọc từ nó. Ngày nay chúng ta có thể ZZ0000ZZ sự tồn tại của một
phương tiện di động trong ổ đĩa và chúng tôi tin rằng chúng tôi nên khai thác điều đó
thực tế. Kiểm tra tính toàn vẹn khi mở thiết bị để xác minh
tính khả dụng của CD-ROM và loại (dữ liệu) chính xác của nó sẽ là
mong muốn.

Hai cách sử dụng ổ đĩa CD-ROM này, chủ yếu cho dữ liệu và
thứ hai là để phát đĩa âm thanh, có những nhu cầu khác nhau về
hành vi của cuộc gọi ZZ0001ZZ. Sử dụng âm thanh chỉ đơn giản là muốn mở
thiết bị để có được một tập tin xử lý cần thiết cho việc phát hành
Các lệnh ZZ0002ZZ, trong khi dữ liệu sử dụng muốn mở chính xác và
truyền dữ liệu đáng tin cậy. Cách duy nhất mà chương trình người dùng có thể chỉ ra những gì
ZZ0003ZZ của họ để mở thiết bị là thông qua ZZ0004ZZ
tham số (xem ZZ0000ZZ). Đối với các thiết bị CD-ROM, những cờ này không
được triển khai (một số trình điều khiển triển khai việc kiểm tra các cờ liên quan đến ghi,
nhưng điều này không thực sự cần thiết nếu tệp thiết bị có chính xác
cờ cho phép). Hầu hết các cờ tùy chọn đơn giản là không có ý nghĩa đối với
Thiết bị CD-ROM: ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ, ZZ0008ZZ và
ZZ0009ZZ không có ý nghĩa gì đối với CD-ROM.

Do đó chúng tôi đề xuất sử dụng cờ ZZ0000ZZ để biểu thị
thiết bị được mở chỉ để phát hành ZZ0001ZZ
lệnh. Đúng ra, ý nghĩa của ZZ0002ZZ là việc mở và
các cuộc gọi tiếp theo tới thiết bị không khiến quá trình gọi bị dừng
chờ đã. Chúng ta có thể giải thích điều này là đừng đợi cho đến khi ai đó có
đã chèn một số dữ liệu hợp lệ-CD-ROM. Vì vậy, đề xuất của chúng tôi về
việc triển khai lệnh gọi ZZ0003ZZ cho CD-ROM s là:

- Nếu không có cờ nào khác được đặt ngoài ZZ0000ZZ, thiết bị sẽ được mở
  để truyền dữ liệu và giá trị trả về sẽ chỉ là 0 khi thành công
  khởi tạo quá trình chuyển giao. Cuộc gọi thậm chí có thể gây ra một số hành động
  trên CD-ROM, chẳng hạn như đóng khay lại.
- Nếu cờ tùy chọn ZZ0001ZZ được đặt, việc mở sẽ luôn là
  thành công, trừ khi toàn bộ thiết bị không tồn tại. Ổ đĩa sẽ mất
  không có bất kỳ hành động nào.

Và tiêu chuẩn thì sao?
-------------------------

Bạn có thể ngần ngại chấp nhận đề xuất này vì nó xuất phát từ
Cộng đồng Linux chứ không phải từ một viện tiêu chuẩn hóa nào đó. cái gì
về SUN, SGI, HP và tất cả các nhà cung cấp phần cứng và Unix khác?
Vâng, những công ty này đang ở vị trí may mắn mà họ thường
kiểm soát cả phần cứng và phần mềm của các sản phẩm được hỗ trợ của họ,
và đủ lớn để thiết lập tiêu chuẩn riêng của họ. Họ không cần phải
xử lý hàng tá phần cứng cạnh tranh khác nhau trở lên
cấu hình\ [#f3]_.

.. [#f3]

   Incidentally, I think that SUN's approach to mounting CD-ROM s is very
   good in origin: under Solaris a volume-daemon automatically mounts a
   newly inserted CD-ROM under `/cdrom/*<volume-name>*`.

   In my opinion they should have pushed this
   further and have **every** CD-ROM on the local area network be
   mounted at the similar location, i. e., no matter in which particular
   machine you insert a CD-ROM, it will always appear at the same
   position in the directory tree, on every system. When I wanted to
   implement such a user-program for Linux, I came across the
   differences in behavior of the various drivers, and the need for an
   *ioctl* informing about media changes.

Chúng tôi tin rằng việc sử dụng ZZ0000ZZ để cho biết rằng một thiết bị đang được mở
chỉ có thể dễ dàng giới thiệu các lệnh ZZ0001ZZ trong Linux
cộng đồng. Tất cả các tác giả của đầu đĩa CD sẽ phải được thông báo, chúng tôi có thể
thậm chí còn gửi các bản vá lỗi của chúng tôi tới các chương trình. Việc sử dụng ZZ0002ZZ
hầu như không có ảnh hưởng gì đến hoạt động của đầu đĩa CD trên
hệ điều hành khác ngoài Linux. Cuối cùng, người dùng luôn có thể hoàn nguyên
hành vi cũ bằng cách gọi tới
ZZ0003ZZ.

Chiến lược ưa thích của ZZ0000ZZ
----------------------------------

Các thủ tục trong ZZ0000ZZ được thiết kế sao cho thời gian chạy
cấu hình hoạt động của thiết bị CD-ROM (thuộc loại ZZ0001ZZ)
có thể được thực hiện bởi ZZ0002ZZ ZZ0003ZZ. Như vậy, đa dạng
chế độ hoạt động có thể được thiết lập:

ZZ0000ZZ
   Đây là cài đặt mặc định. (Với ZZ0002ZZ thì sẽ tốt hơn, trong
   tương lai.) Nếu thiết bị chưa được mở bằng bất kỳ quy trình nào khác và nếu
   thiết bị đang được mở để lấy dữ liệu (ZZ0003ZZ chưa được đặt) và
   khay được phát hiện đang mở, cố gắng đóng khay được thực hiện. Sau đó,
   nó được xác minh rằng có một đĩa trong ổ đĩa và nếu ZZ0004ZZ là
   được đặt, nó chứa các bản nhạc thuộc loại ZZ0001ZZ. Chỉ khi tất cả các bài kiểm tra
   được thông qua là giá trị trả về bằng 0. Cửa bị khóa để ngăn chặn tập tin
   tham nhũng hệ thống. Nếu ổ đĩa được mở để phát âm thanh (ZZ0005ZZ là
   được đặt), không có hành động nào được thực hiện và giá trị 0 sẽ được trả về.

ZZ0000ZZ
   Điều này bắt chước hành vi của trình điều khiển sbpcd hiện tại. Các cờ tùy chọn là
   bị bỏ qua, khay sẽ được đóng vào lần mở đầu tiên, nếu cần. Tương tự,
   khay được mở ở lần phát hành cuối cùng, i. e., nếu CD-ROM chưa được gắn kết,
   nó sẽ tự động được đẩy ra để người dùng có thể thay thế nó.

Chúng tôi hy vọng rằng lựa chọn này có thể thuyết phục được mọi người (cả tài xế và
người bảo trì và nhà phát triển chương trình người dùng) áp dụng CD-ROM mới
sơ đồ trình điều khiển và giải thích cờ tùy chọn.

Mô tả các thủ tục trong ZZ0000ZZ
====================================

Chỉ một số quy trình trong ZZ0000ZZ được xuất sang trình điều khiển. Trong này
Phần mới chúng ta sẽ thảo luận về những điều này, cũng như các chức năng mà ZZ0001ZZ giao tiếp với kernel của CD-ROM. Tệp tiêu đề thuộc về
đến ZZ0002ZZ được gọi là ZZ0003ZZ. Trước đây, một số nội dung của tài liệu này
đã được đặt trong tệp ZZ0004ZZ, nhưng tệp này hiện đã bị
được sáp nhập lại vào ZZ0005ZZ.

::

cấu trúc file_Operation cdrom_fops

Nội dung của cấu trúc này được mô tả trong cdrom_api_.
Một con trỏ tới cấu trúc này được gán cho trường ZZ0000ZZ
của ZZ0001ZZ.

::

int register_cdrom(struct cdrom_device_info *cdi)

Chức năng này được sử dụng giống như cách người ta đăng ký ZZ0000ZZ
với nhân, hoạt động của thiết bị và cấu trúc thông tin,
như được mô tả trong cdrom_api_, phải được đăng ký với
Trình điều khiển CD-ROM thống nhất::

register_cdrom(&<device>_info);


Hàm này trả về 0 khi thành công và khác 0 khi
thất bại. Cấu trúc ZZ0000ZZ phải có một con trỏ tới
ZZ0001ZZ của trình điều khiển, như trong::

struct cdrom_device_info <device>_info = {
		<thiết bị>_dops;
		...
	}

Lưu ý rằng trình điều khiển phải có một cấu trúc tĩnh, ZZ0000ZZ, trong khi
nó có thể có nhiều cấu trúc ZZ0001ZZ cũng như có nhiều thiết bị nhỏ
hoạt động. ZZ0002ZZ xây dựng danh sách liên kết từ những danh sách này.


::

void unregister_cdrom(struct cdrom_device_info *cdi)

Xóa thiết bị hủy đăng ký ZZ0000ZZ với số phụ ZZ0001ZZ
thiết bị phụ trong danh sách. Nếu đó là trẻ vị thành niên được đăng ký cuối cùng cho
trình điều khiển cấp thấp, điều này sẽ ngắt kết nối hoạt động của thiết bị đã đăng ký
các hoạt động thường ngày từ giao diện CD-ROM. Hàm này trả về 0 khi
thành công và khác 0 khi thất bại.

::

int cdrom_open(struct inode * ip, file struct * fp)

Chức năng này không được gọi trực tiếp bởi trình điều khiển cấp thấp, nó được
được liệt kê trong ZZ0000ZZ tiêu chuẩn. Nếu VFS mở một tập tin, điều này
chức năng trở nên hoạt động. Một chiến lược được thực hiện trong thói quen này,
chăm sóc tất cả các khả năng và tùy chọn được đặt trong
ZZ0001ZZ được kết nối với thiết bị. Sau đó, luồng chương trình là
được chuyển sang cuộc gọi ZZ0002ZZ phụ thuộc vào thiết bị.

::

void cdrom_release(struct inode *ip, struct file *fp)

Hàm này thực hiện logic đảo ngược của ZZ0000ZZ, sau đó
gọi thủ tục ZZ0001ZZ phụ thuộc vào thiết bị. Khi số lượng sử dụng có
đạt đến 0, bộ đệm được phân bổ sẽ bị xóa bởi các lệnh gọi tới ZZ0002ZZ
và ZZ0003ZZ.


.. _cdrom_ioctl:

::

int cdrom_ioctl(struct inode *ip, struct file *fp,
			int cmd không dấu, arg dài không dấu)

Chức năng này xử lý tất cả các yêu cầu ZZ0000ZZ tiêu chuẩn cho CD-ROM
thiết bị một cách thống nhất. Các cuộc gọi khác nhau rơi vào ba
danh mục: ZZ0001ZZ có thể được triển khai trực tiếp bằng thiết bị
các hoạt động được định tuyến thông qua cuộc gọi ZZ0002ZZ và
những cái còn lại, có thể phụ thuộc vào thiết bị. Nói chung, một
giá trị trả về âm cho biết có lỗi.

Trực tiếp thực hiện ZZ0000ZZ
--------------------------------

ZZ0000ZZ CD-ROM ZZ0001ZZ\ sau đây được triển khai trực tiếp
gọi hoạt động thiết bị trong ZZ0002ZZ, nếu được triển khai và
không bịt mặt:

ZZ0000ZZ
	Yêu cầu phiên cuối cùng trên CD-ROM.
ZZ0001ZZ
	Mở khay.
ZZ0002ZZ
	Đóng khay.
ZZ0003ZZ
	Nếu ZZ0005ZZ, hãy đặt hành vi thành tự động đóng (đóng
	khay ở lần mở đầu tiên) và tự động đẩy ra (đẩy ra ở lần phát hành cuối cùng), nếu không
	đặt hành vi thành không di chuyển trong các cuộc gọi ZZ0006ZZ và ZZ0007ZZ.
ZZ0004ZZ
	Lấy số danh mục phương tiện từ đĩa CD.

*Ioctl* được định tuyến qua ZZ0001ZZ
---------------------------------------

Bộ ZZ0000ZZ sau đây đều được triển khai thông qua lệnh gọi tới
chức năng ZZ0001ZZ ZZ0002ZZ. Kiểm tra bộ nhớ và
việc phân bổ được thực hiện trong ZZ0003ZZ, đồng thời vệ sinh
định dạng địa chỉ (ZZ0004ZZ/ZZ0005ZZ) đã hoàn tất.

ZZ0000ZZ
	Nhận dữ liệu kênh phụ trong đối số ZZ0018ZZ thuộc loại
	ZZ0001ZZ.
ZZ0002ZZ
	Đọc tiêu đề Mục lục, thuộc loại ZZ0019ZZ
	ZZ0003ZZ.
ZZ0004ZZ
	Đọc mục nhập Mục lục trong ZZ0020ZZ và được chỉ định bởi ZZ0021ZZ
	thuộc loại ZZ0005ZZ.
ZZ0006ZZ
	Phát đoạn âm thanh được chỉ định ở định dạng Phút, Giây, Khung,
	được phân cách bởi ZZ0022ZZ thuộc loại ZZ0007ZZ.
ZZ0008ZZ
	Phát đoạn âm thanh ở định dạng chỉ mục theo dõi được phân cách bằng ZZ0023ZZ
	thuộc loại ZZ0009ZZ.
ZZ0010ZZ
	Đặt âm lượng được chỉ định bởi ZZ0024ZZ thuộc loại ZZ0011ZZ.
ZZ0012ZZ
	Đọc âm lượng vào ZZ0025ZZ thuộc loại ZZ0013ZZ.
ZZ0014ZZ
	Quay đĩa.
ZZ0015ZZ
	Dừng phát lại đoạn âm thanh.
ZZ0016ZZ
	Tạm dừng phát lại đoạn âm thanh.
ZZ0017ZZ
	Tiếp tục chơi.

ZZ0001ZZ mới trong ZZ0000ZZ
----------------------------

ZZ0000ZZ sau đây đã được giới thiệu để cho phép các chương trình người dùng
kiểm soát hoạt động của từng thiết bị CD-ROM riêng lẻ. ZZ0001ZZ mới
các lệnh có thể được xác định bằng dấu gạch dưới trong tên của chúng.

ZZ0000ZZ
	Đặt các tùy chọn được chỉ định bởi ZZ0005ZZ. Trả về thanh ghi cờ tùy chọn
	sau khi sửa đổi. Sử dụng ZZ0006ZZ để đọc các cờ hiện tại.
ZZ0001ZZ
	Xóa các tùy chọn được chỉ định bởi ZZ0007ZZ. Trả về thanh ghi cờ tùy chọn
	sau khi sửa đổi.
ZZ0002ZZ
	Chọn tốc độ đầu của đĩa được chỉ định bởi ZZ0008ZZ theo đơn vị
	tốc độ cdrom tiêu chuẩn (dữ liệu thô 176\,kB/giây hoặc
	dữ liệu hệ thống tệp 150kB/giây). Giá trị 0 có nghĩa là ZZ0003ZZ,
	tôi. e., phát đĩa âm thanh ở thời gian thực và đĩa dữ liệu ở tốc độ tối đa.
	Giá trị ZZ0009ZZ được kiểm tra theo tốc độ đầu tối đa của
	ổ đĩa được tìm thấy trong ZZ0010ZZ.
ZZ0004ZZ
	Chọn đĩa được đánh số ZZ0011ZZ từ máy hát tự động.

Đĩa đầu tiên được đánh số 0. Số ZZ0002ZZ được kiểm tra dựa trên
	số lượng đĩa tối đa trong máy hát tự động được tìm thấy trong ZZ0003ZZ.
ZZ0000ZZ
	Trả về 1 nếu đĩa đã được thay đổi kể từ lần gọi cuối cùng.
	Đối với máy hát tự động, một đối số bổ sung ZZ0004ZZ
	chỉ định vị trí mà thông tin được cung cấp. Điều đặc biệt
	giá trị ZZ0005ZZ yêu cầu thông tin về hiện tại
	vị trí đã chọn sẽ được trả lại.
ZZ0001ZZ
	Kiểm tra xem đĩa có bị thay đổi kể từ thời điểm người dùng cung cấp hay không
	và trả về thời điểm thay đổi đĩa cuối cùng.

ZZ0002ZZ là một con trỏ tới cấu trúc ZZ0003ZZ.
	ZZ0004ZZ có thể được đặt bằng cách gọi mã để báo hiệu
	dấu thời gian của lần thay đổi phương tiện đã biết gần đây nhất (bởi người gọi).
	Sau khi quay lại thành công, lệnh gọi ioctl này sẽ được đặt
	ZZ0005ZZ sang dấu thời gian thay đổi phương tiện mới nhất (tính bằng mili giây)
	được hạt nhân/trình điều khiển biết đến và đặt ZZ0006ZZ thành 1 nếu
	dấu thời gian đó gần đây hơn dấu thời gian do người gọi đặt.
ZZ0000ZZ
	Trả về trạng thái của ổ đĩa bằng lệnh gọi tới
	ZZ0007ZZ. Giá trị trả về được xác định trong cdrom_drive_status_.
	Lưu ý rằng lệnh gọi này không trả về thông tin trên
	hoạt động chơi hiện tại của ổ đĩa; điều này có thể được thăm dò thông qua
	một cuộc gọi ZZ0008ZZ tới ZZ0009ZZ. Đối với máy hát tự động, một đối số bổ sung
	ZZ0010ZZ chỉ định vị trí chứa thông tin (có thể bị giới hạn)
	đã cho. Giá trị đặc biệt ZZ0011ZZ yêu cầu thông tin đó
	về vị trí hiện được chọn sẽ được trả về.
ZZ0001ZZ
	Trả về loại đĩa hiện có trong ổ đĩa.
	Nó nên được xem như một phần bổ sung cho ZZ0012ZZ.
	ZZ0013ZZ này có thể cung cấp thông tin ZZ0014ZZ về hiện tại
	đĩa được đưa vào ổ đĩa. Chức năng này trước đây
	được thực hiện trong các trình điều khiển cấp thấp, nhưng bây giờ được thực hiện
	hoàn toàn trong Trình điều khiển CD-ROM thống nhất.

Lịch sử phát triển của việc sử dụng đĩa CD làm phương tiện truyền tải cho
	thông tin kỹ thuật số khác nhau đã dẫn đến nhiều loại đĩa khác nhau.
	ZZ0000ZZ này chỉ hữu ích trong trường hợp đĩa CD có \emph {chỉ
	one} loại dữ liệu trên chúng. Mặc dù điều này thường xảy ra nhưng nó
	cũng rất phổ biến khi đĩa CD có một số bản nhạc chứa dữ liệu và một số
	bài hát có âm thanh. Bởi vì đây là một giao diện hiện có, đúng hơn
	hơn là sửa giao diện này bằng cách thay đổi các giả định đã được thực hiện
	bên dưới, do đó phá vỡ tất cả các ứng dụng người dùng sử dụng điều này
	chức năng, Trình điều khiển CD-ROM thống nhất triển khai ZZ0001ZZ này như
	sau: Nếu đĩa CD được đề cập có các rãnh âm thanh trên đó và nó có
	hoàn toàn không có CD-I, XA hay dấu vết dữ liệu nào trên đó, nó sẽ bị báo cáo
	như ZZ0002ZZ. Nếu nó có cả rãnh âm thanh và dữ liệu, nó sẽ
	trả lại ZZ0003ZZ. Nếu không có rãnh âm thanh trên đĩa và
	nếu đĩa CD được đề cập có bất kỳ rãnh đĩa CD-I nào trên đó thì nó sẽ là
	được báo cáo là ZZ0004ZZ. Nếu không, nếu đĩa CD được đề cập
	có bất kỳ bản nhạc XA nào trên đó thì nó sẽ được báo cáo là ZZ0005ZZ.
	Cuối cùng, nếu đĩa CD được đề cập có bất kỳ rãnh dữ liệu nào trên đó,
	nó sẽ được báo cáo dưới dạng CD dữ liệu (ZZ0006ZZ).

ZZ0000ZZ này có thể trả về::

CDS_NO_INFO /* không có thông tin */
		CDS_NO_DISC /* không đưa đĩa vào hoặc mở khay */
		CDS_AUDIO /* Đĩa âm thanh (2352 byte âm thanh/khung) */
		CDS_DATA_1 /* đĩa dữ liệu, chế độ 1 (2048 byte/khung người dùng) */
		CDS_XA_2_1 /* dữ liệu hỗn hợp (XA), chế độ 2, dạng 1 (2048 byte người dùng) */
		CDS_XA_2_2 /* dữ liệu hỗn hợp (XA), chế độ 2, dạng 1 (2324 byte người dùng) */
		CDS_MIXED /* đĩa âm thanh/dữ liệu hỗn hợp */

Để biết một số thông tin liên quan đến bố cục khung của các đĩa khác nhau
	các loại, hãy xem phiên bản gần đây của ZZ0000ZZ.

ZZ0000ZZ
	Trả về số lượng vị trí trong máy hát tự động.
ZZ0001ZZ
	Đặt lại ổ đĩa.
ZZ0002ZZ
	Trả về cờ ZZ0006ZZ cho ổ đĩa. Tham khảo phần
	cdrom_capabilities_ để biết thêm thông tin về các cờ này.
ZZ0003ZZ
	 Khóa cửa ổ đĩa. ZZ0004ZZ mở khóa cửa,
	 bất kỳ giá trị nào khác sẽ khóa nó.
ZZ0005ZZ
	 Bật thông tin gỡ lỗi. Chỉ có root mới được phép làm điều này.
	 Ngữ nghĩa tương tự như CDROM_LOCKDOOR.


Phụ thuộc thiết bị ZZ0000ZZ
----------------------------

Cuối cùng, tất cả ZZ0000ZZ khác được chuyển đến hàm ZZ0001ZZ,
nếu được thực hiện. Không có việc phân bổ hoặc xác minh bộ nhớ nào được thực hiện.

Cách cập nhật trình điều khiển của bạn
=========================

- Tạo một bản sao lưu của trình điều khiển hiện tại của bạn.
- Giữ các tập tin ZZ0000ZZ và ZZ0001ZZ, chúng phải ở trong
  cây thư mục đi kèm với tài liệu này.
- Đảm bảo bạn bao gồm ZZ0002ZZ.
- Thay đổi đối số thứ 3 của ZZ0005ZZ từ ZZ0003ZZ
  tới ZZ0004ZZ.
- Ngay sau dòng đó thêm dòng sau để đăng ký với Đồng Phục
  Trình điều khiển CD-ROM::

register_cdrom(&<your-drive>_info);*

Tương tự, thêm cuộc gọi đến ZZ0004ZZ ở vị trí thích hợp.
- Sao chép một ví dụ về hoạt động của thiết bị ZZ0005ZZ vào
  nguồn, đ. g., từ ZZ0000ZZ ZZ0006ZZ, và thay đổi tất cả
  các mục nhập tên tương ứng với trình điều khiển của bạn hoặc tên bạn vừa
  ngẫu nhiên thích. Nếu trình điều khiển của bạn không hỗ trợ một chức năng nhất định,
  thực hiện mục ZZ0007ZZ. Tại mục ZZ0008ZZ bạn nên liệt kê tất cả
  khả năng mà trình điều khiển của bạn hiện đang hỗ trợ. Nếu tài xế của bạn
  có khả năng không được liệt kê, vui lòng gửi tin nhắn cho tôi.
- Sao chép khai báo ZZ0009ZZ từ ví dụ tương tự
  driver, và sửa đổi các mục theo nhu cầu của bạn. Nếu bạn
  trình điều khiển tự động xác định khả năng của phần cứng, điều này
  cấu trúc cũng nên được khai báo động.
- Thực hiện tất cả các chức năng trong cấu trúc ZZ0001ZZ của bạn,
  theo các nguyên mẫu được liệt kê trong ZZ0002ZZ và các thông số kỹ thuật được cung cấp
  trong cdrom_api_. Rất có thể bạn đã thực hiện
  phần lớn mã và bạn gần như chắc chắn sẽ cần phải điều chỉnh
  nguyên mẫu và giá trị trả về.
- Đổi tên chức năng ZZ0003ZZ của bạn thành ZZ0010ZZ và
  thay đổi nguyên mẫu một chút. Xóa các mục được liệt kê trong đầu tiên
  một phần trong cdrom_ioctl_, nếu mã của bạn ổn thì đây là
  chỉ cần gọi đến các thói quen bạn đã điều chỉnh ở bước trước.
- Bạn có thể xóa toàn bộ mã kiểm tra bộ nhớ còn lại trong
  Chức năng ZZ0011ZZ xử lý các lệnh âm thanh (đây là
  được liệt kê trong phần thứ hai của cdrom_ioctl_. không có
  cũng cần phân bổ bộ nhớ, vì vậy hầu hết các *case* trong ZZ0013ZZ
  tuyên bố trông giống như ::

vỏ CDROMREADTOCENTRY:
		get_toc_entry\bigl((struct cdrom_tocentry *) arg);

- Tất cả các vỏ ZZ0001ZZ còn lại phải được chuyển sang một ngăn riêng
  chức năng, ZZ0002ZZ, ZZ0003ZZ phụ thuộc vào thiết bị. Lưu ý rằng
  Việc kiểm tra và phân bổ bộ nhớ phải được lưu giữ trong mã này!
- Thay đổi nguyên mẫu của ZZ0004ZZ và
  ZZ0005ZZ và xóa mọi mã chiến lược (ví dụ: khay
  chuyển động, khóa cửa, v.v.).
- Cố gắng biên dịch lại các trình điều khiển. Chúng tôi khuyên bạn nên sử dụng cả hai mô-đun
  đối với ZZ0000ZZ và trình điều khiển của bạn, vì việc gỡ lỗi này dễ dàng hơn nhiều
  cách.

Cảm ơn
======

Cảm ơn tất cả những người liên quan. Đầu tiên, Erik Andersen, người đã
đã dẫn đầu trong việc duy trì ZZ0000ZZ và tích hợp nhiều
Mã liên quan đến CD-ROM trong hạt nhân 2.1. Cảm ơn Scott Snyder và
Gerd Knorr, người đầu tiên triển khai giao diện này cho SCSI
và trình điều khiển IDE-CD và thêm nhiều ý tưởng để mở rộng dữ liệu
cấu trúc liên quan đến kernel~2.0. Xin cảm ơn Heiko Eißfeldt,
Thomas Quinot, Jon Tombs, Ken Pizzini, Eberhard Mönkeberg và Andrew Kroll,
các nhà phát triển trình điều khiển thiết bị Linux CD-ROM rất tốt bụng
đủ để đưa ra những gợi ý và phê bình trong quá trình viết. Cuối cùng
tất nhiên, tôi muốn cảm ơn Linus Torvalds vì đã biến điều này thành hiện thực trong
nơi đầu tiên
