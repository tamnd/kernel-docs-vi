.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/usbmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
usbmon
======

Giới thiệu
============

Tên "usbmon" bằng chữ thường đề cập đến một tiện ích trong kernel được
được sử dụng để thu thập dấu vết I/O trên bus USB. Chức năng này tương tự
tới ổ cắm gói được sử dụng bởi các công cụ giám sát mạng như tcpdump(1)
hoặc thanh tao. Tương tự, người ta hy vọng rằng một công cụ như usbdump hoặc
USBMon (có chữ in hoa) được sử dụng để kiểm tra các dấu vết thô được tạo ra
bởi usbmon.

USBmon báo cáo các yêu cầu được thực hiện bởi trình điều khiển dành riêng cho thiết bị ngoại vi tới Máy chủ
Trình điều khiển bộ điều khiển (HCD). Vì vậy, nếu HCD có lỗi, dấu vết được báo cáo bởi
usbmon có thể không tương ứng chính xác với các giao dịch trên xe buýt. Đây là điều tương tự
tình huống như với tcpdump.

Hai API hiện đang được triển khai: "văn bản" và "nhị phân". API nhị phân
có sẵn thông qua một thiết bị ký tự trong không gian tên /dev và là ABI.
Văn bản API không còn được dùng kể từ phiên bản 2.6.35 nhưng vẫn có sẵn để thuận tiện.

Cách sử dụng usbmon để thu thập dấu vết văn bản thô
===================================================

Không giống như ổ cắm gói, usbmon có giao diện cung cấp dấu vết
ở dạng văn bản. Điều này được sử dụng cho hai mục đích. Đầu tiên, nó phục vụ như một
định dạng trao đổi dấu vết phổ biến cho các công cụ trong khi các định dạng phức tạp hơn
được hoàn thiện. Thứ hai, con người có thể đọc nó trong trường hợp không có công cụ.

Để thu thập dấu vết văn bản thô, hãy thực hiện các bước sau.

1. Chuẩn bị
-----------

Gắn debugfs (nó phải được kích hoạt trong cấu hình kernel của bạn) và
tải mô-đun usbmon (nếu được xây dựng dưới dạng mô-đun). Bước thứ hai được bỏ qua
nếu usbmon được tích hợp vào kernel ::

# mount -t debugfs none_debugs/sys/kernel/debug
	USBmon # modprobe
	#

Xác minh rằng có ổ cắm xe buýt::

# ls/sys/kernel/gỡ lỗi/usb/usbmon
	0s 0u 1s 1t 1u 2s 2t 2u 3s 3t 3u 4s 4t 4u
	#

Bây giờ bạn có thể chọn sử dụng socket '0u' (để chụp các gói trên tất cả
xe buýt) và chuyển sang bước #3 hoặc tìm xe buýt được thiết bị của bạn sử dụng bằng bước #2.
Điều này cho phép lọc đi các thiết bị gây phiền nhiễu nói chuyện liên tục.

2. Tìm bus nào kết nối với thiết bị mong muốn
------------------------------------------------

Chạy "cat /sys/kernel/debug/usb/devices" và tìm dòng chữ T tương ứng
tới thiết bị. Thông thường bạn làm điều đó bằng cách tìm kiếm chuỗi nhà cung cấp. Nếu bạn có
nhiều thiết bị tương tự nhau, hãy rút phích cắm của một thiết bị và so sánh hai thiết bị
/sys/kernel/debug/usb/thiết bị đầu ra. Tuyến T sẽ có số xe buýt.

Ví dụ::

T: Bus=03 Lev=01 Prnt=01 Cổng=00 Cnt=01 Dev#= 2 Spd=12 MxCh= 0
  D: Ver= 1.10 Cls=00(>ifc ) Sub=00 Prot=00 MxPS= 8 #Cfgs= 1
  P: Nhà cung cấp=0557 ProdID=2004 Rev= 1,00
  S: Nhà sản xuất=ATEN
  S: Sản phẩm=UC100KM V2.00

"Bus=03" có nghĩa là bus 3. Ngoài ra, bạn có thể xem kết quả từ
"lsusb" và lấy số xe buýt từ dòng thích hợp. Ví dụ:

Bus 003 Thiết bị 002: ID 0557:2004 ATEN UC100KM V2.00

3. Bắt đầu từ 'con mèo'
-----------------------

::

# cat /sys/kernel/debug/usb/usbmon/3u > /tmp/1.mon.out

để nghe trên một xe buýt, nếu không, để nghe trên tất cả các xe buýt, hãy nhập::

# cat /sys/kernel/debug/usb/usbmon/0u > /tmp/1.mon.out

Quá trình này sẽ đọc cho đến khi nó bị giết. Đương nhiên, đầu ra có thể là
được chuyển hướng đến một vị trí mong muốn. Điều này được ưa thích hơn vì nó sẽ
sẽ khá dài.

4. Thực hiện thao tác mong muốn trên bus USB
-----------------------------------------------

Đây là nơi bạn làm điều gì đó để tạo ra lưu lượng truy cập: cắm phím flash,
sao chép tập tin, điều khiển webcam, v.v.

5. Giết mèo
-----------

Thông thường, việc này được thực hiện bằng cách ngắt bàn phím (Control-C).

Tại thời điểm này, tệp đầu ra (/tmp/1.mon.out trong ví dụ này) có thể được lưu,
được gửi qua e-mail hoặc được kiểm tra bằng trình soạn thảo văn bản. Trong trường hợp cuối cùng, hãy đảm bảo
rằng kích thước tệp không quá lớn đối với trình chỉnh sửa yêu thích của bạn.

Định dạng dữ liệu văn bản thô
=============================

Hiện tại có hai định dạng được hỗ trợ: định dạng gốc hoặc định dạng '1t' và
định dạng '1u'. Định dạng '1t' không được dùng nữa trong kernel 2.6.21. '1u'
định dạng thêm một số trường, chẳng hạn như bộ mô tả khung ISO, khoảng thời gian, v.v.
Nó tạo ra những dòng dài hơn một chút, nhưng mặt khác lại là một superset hoàn hảo
định dạng '1t'.

Nếu muốn nhận ra cái này với cái kia trong một chương trình, hãy nhìn vào
Từ "địa chỉ" (xem bên dưới), trong đó định dạng '1u' thêm số xe buýt. Nếu 2 dấu hai chấm
có mặt, đó là định dạng '1t', nếu không thì là '1u'.

Mọi dữ liệu định dạng văn bản đều bao gồm một luồng sự kiện, chẳng hạn như gửi URB,
Gọi lại URB, lỗi gửi. Mỗi sự kiện là một dòng văn bản, bao gồm
các từ được phân tách bằng khoảng trắng. Số lượng hoặc vị trí của từ có thể phụ thuộc
về loại sự kiện, nhưng có một tập hợp các từ chung cho tất cả các loại.

Đây là danh sách các từ, từ trái sang phải:

- Thẻ URB. Địa chỉ này được sử dụng để xác định URB và thường là địa chỉ trong kernel
  của cấu trúc URB ở dạng thập lục phân, nhưng có thể là số thứ tự hoặc bất kỳ
  chuỗi duy nhất khác, trong phạm vi lý do.

- Dấu thời gian tính bằng micro giây, số thập phân. Độ phân giải của dấu thời gian
  phụ thuộc vào đồng hồ có sẵn và do đó nó có thể tệ hơn nhiều so với một phần triệu giây
  (ví dụ: nếu việc triển khai sử dụng jiffies).

- Loại sự kiện. Loại này đề cập đến định dạng của sự kiện, không phải loại URB.
  Các loại có sẵn là: S - gửi, C - gọi lại, E - lỗi gửi.

- Từ "Địa chỉ" (trước đây là "ống"). Nó bao gồm bốn trường, cách nhau bởi
  dấu hai chấm: loại và hướng URB, Số xe buýt, Địa chỉ thiết bị, Số điểm cuối.
  Loại và hướng được mã hóa bằng hai byte theo cách sau:

== == =================================
    Ci Co Kiểm soát đầu vào và đầu ra
    Zi Zo Đầu vào và đầu ra đẳng thời
    Ii Io Ngắt đầu vào và đầu ra
    Bi Bo Đầu vào và đầu ra số lượng lớn
    == == =================================

Số xe buýt, Địa chỉ thiết bị và Điểm cuối là số thập phân, nhưng chúng có thể
  có số 0 đứng đầu, vì lợi ích của độc giả con người.

- URB Từ trạng thái. Đây có thể là một chữ cái hoặc một vài số được phân tách
  theo dấu hai chấm: trạng thái URB, khoảng thời gian, khung bắt đầu và số lỗi. Không giống như
  từ "địa chỉ", tất cả các trường lưu trạng thái đều là tùy chọn. Khoảng thời gian được in
  chỉ dành cho URB ngắt và URB đẳng thời. Khung bắt đầu chỉ được in cho
  URB đẳng thời. Số lỗi chỉ được in cho cuộc gọi lại đẳng thời
  sự kiện.

Trường trạng thái là một số thập phân, đôi khi âm, đại diện cho
  trường "trạng thái" của URB. Trường này không có ý nghĩa đối với việc gửi bài, nhưng
  Dù sao cũng có mặt để giúp các tập lệnh phân tích cú pháp. Khi xảy ra lỗi,
  trường chứa mã lỗi.

Trong trường hợp gửi gói Kiểm soát, trường này chứa Thẻ thiết lập
  thay vì một nhóm số. Thật dễ dàng để biết liệu Thẻ thiết lập có
  hiện tại vì nó không bao giờ là một con số. Vì vậy, nếu tập lệnh tìm thấy một bộ số
  trong từ này, chúng tiến hành đọc Độ dài dữ liệu (ngoại trừ các URB đẳng thời).
  Nếu họ tìm thấy thứ gì khác, chẳng hạn như một lá thư, họ sẽ đọc gói thiết lập trước đó.
  đọc Độ dài dữ liệu hoặc mô tả đẳng thời.

- Gói thiết lập, nếu có, gồm 5 từ: mỗi từ dành cho bmRequestType,
  bRequest, wValue, wIndex, wLength, như được chỉ định bởi Đặc tả USB 2.0.
  Những từ này có thể giải mã an toàn nếu Thẻ thiết lập là 's'. Ngược lại, việc thiết lập
  gói đã có nhưng không được bắt và các trường chứa phụ.

- Số lượng bộ mô tả khung đẳng thời và bản thân bộ mô tả.
  Nếu một sự kiện chuyển giao đẳng thời có một bộ mô tả, tổng số
  trong số chúng trong URB được in trước, sau đó là một từ trên mỗi bộ mô tả, tối đa một
  tổng cộng là 5. Từ này bao gồm 3 số thập phân được phân cách bằng dấu hai chấm để biểu thị
  trạng thái, độ lệch và độ dài tương ứng. Đối với bài nộp, độ dài ban đầu
  được báo cáo. Đối với các lệnh gọi lại, độ dài thực tế sẽ được báo cáo.

- Độ dài dữ liệu Đối với bài nộp, đây là độ dài được yêu cầu. Đối với các cuộc gọi lại,
  đây là chiều dài thực tế

- Thẻ dữ liệu. USBmon không phải lúc nào cũng có thể thu thập dữ liệu, ngay cả khi độ dài khác 0.
  Các từ dữ liệu chỉ xuất hiện nếu thẻ này là '='.

- Các từ dữ liệu theo sau, ở định dạng thập lục phân cuối lớn. Chú ý rằng chúng
  không phải các từ máy, mà thực sự chỉ là một luồng byte được chia thành các từ để tạo
  nó dễ đọc hơn. Vì vậy, từ cuối cùng có thể chứa từ một đến bốn byte.
  Độ dài của dữ liệu được thu thập bị giới hạn và có thể nhỏ hơn độ dài dữ liệu
  được báo cáo trong từ Độ dài dữ liệu. Trong trường hợp đầu vào đẳng thời (Zi)
  hoàn thành khi dữ liệu nhận được thưa thớt trong bộ đệm, độ dài của
  dữ liệu được thu thập có thể lớn hơn giá trị Độ dài dữ liệu (vì Dữ liệu
  Độ dài chỉ tính số byte đã nhận được trong khi các từ Dữ liệu
  chứa toàn bộ bộ đệm truyền).

Ví dụ:

Chuyển điều khiển đầu vào để nhận trạng thái cổng ::

d5ea89a0 3575914555 S Ci:1:001:0 s a3 00 0000 0003 0004 4 <
  d5ea89a0 3575914560 C Ci:1:001:0 0 4 = 01050000

Chuyển số lượng lớn đầu ra để gửi lệnh SCSI 0x28 (READ_10) trong 31 byte
Trình bao bọc hàng loạt cho thiết bị lưu trữ tại địa chỉ 5::

dd65f0e8 4128379752 S Bo:1:005:2 -115 31 = 55534243 ad000000 00800000 80010a28 20000000 20000040 00000000 000000
  dd65f0e8 4128379808 C Bo:1:005:2 0 31 >

Định dạng nhị phân thô và API
=============================

Kiến trúc tổng thể của API gần giống như kiến trúc ở trên,
chỉ các sự kiện được phân phối ở định dạng nhị phân. Mỗi sự kiện được gửi vào
Cấu trúc như sau (tên nó được tạo nên để chúng ta tham khảo)::

cấu trúc usbmon_packet {
	id u64;			/* 0: ID URB - từ gửi đến gọi lại */
	loại char không dấu;	/* 8: Tương tự như văn bản; có thể mở rộng. */
	char xfer_type không dấu; /* ISO (0), Intr, Control, Bulk (3) */
	ký tự không dấu epnum;	/* Số điểm cuối và hướng truyền */
	devnum ký tự không dấu;	/*Địa chỉ thiết bị */
	u16 busnum;		/* 12: Số xe buýt */
	char flag_setup;	/* 14: Giống như văn bản */
	char flag_data;		/* 15: Giống như văn bản; Số 0 nhị phân là được. */
	s64 ts_sec;		/* 16: gettimeofday */
	s32 ts_usec;		/* 24: gettimeofday */
	trạng thái int;		/* 28: */
	chiều dài int không dấu;	/* 32: Độ dài dữ liệu (đã gửi hoặc thực tế) */
	unsigned int len_cap;	/* 36: Chiều dài đã gửi */
	công đoàn { /* 40: */
		thiết lập char không dấu [SETUP_LEN];	/* Chỉ dành cho loại điều khiển S */
		struct iso_rec { /* Chỉ dành cho ISO */
			int error_count;
			int numdesc;
		} iso;
	} s;
	khoảng int;		/* 48: Chỉ dành cho Ngắt và ISO */
	int start_frame;	/* 52: Dành cho ISO */
	int xfer_flags không dấu; /* 56: bản sao transfer_flags của URB */
	int unsigned ndesc;	/* 60: Số lượng bộ mô tả ISO thực tế */
  };				/* Tổng chiều dài 64 */

Những sự kiện này có thể được nhận từ thiết bị ký tự bằng cách đọc với read(2),
bằng ioctl(2) hoặc bằng cách truy cập bộ đệm bằng mmap. Tuy nhiên, đọc (2)
chỉ trả về 48 byte đầu tiên vì lý do tương thích.

Thiết bị ký tự thường được gọi là /dev/usbmonN, trong đó N là bus USB
số. Số 0 (/dev/usbmon0) là số đặc biệt và có nghĩa là "tất cả các xe buýt".
Lưu ý rằng chính sách đặt tên cụ thể do bản phân phối Linux của bạn đặt ra.

Nếu bạn tạo /dev/usbmon0 bằng tay, hãy đảm bảo rằng nó thuộc quyền sở hữu của root
và có chế độ 0600. Nếu không, người dùng không có đặc quyền sẽ có thể rình mò
lưu lượng truy cập bàn phím.

Các lệnh gọi ioctl sau đây khả dụng với MON_IOC_MAGIC 0x92:

MON_IOCQ_URB_LEN, được định nghĩa là _IO(MON_IOC_MAGIC, 1)

Cuộc gọi này trả về độ dài của dữ liệu trong sự kiện tiếp theo. Lưu ý rằng phần lớn
các sự kiện không chứa dữ liệu, vì vậy nếu lệnh gọi này trả về 0, điều đó không có nghĩa là
không có sự kiện nào có sẵn

MON_IOCG_STATS, được định nghĩa là _IOR(MON_IOC_MAGIC, 3, struct mon_bin_stats)

Đối số là một con trỏ tới cấu trúc sau::

cấu trúc mon_bin_stats {
	u32 xếp hàng;
	u32 rớt hạng;
  };

Thành viên "xếp hàng" đề cập đến số lượng sự kiện hiện đang được xếp hàng trong
bộ đệm (chứ không phải số lượng sự kiện được xử lý kể từ lần đặt lại cuối cùng).

Thành viên “rớt” là số sự kiện bị mất kể từ lần gọi cuối cùng
tới MON_IOCG_STATS.

MON_IOCT_RING_SIZE, được định nghĩa là _IO(MON_IOC_MAGIC, 4)

Cuộc gọi này đặt kích thước bộ đệm. Đối số là kích thước tính bằng byte.
Kích thước có thể được làm tròn xuống đoạn (hoặc trang) tiếp theo. Nếu được yêu cầu
kích thước vượt quá giới hạn [không xác định] cho hạt nhân này, cuộc gọi không thành công với
-EINVAL.

MON_IOCQ_RING_SIZE, được định nghĩa là _IO(MON_IOC_MAGIC, 5)

Cuộc gọi này trả về kích thước hiện tại của bộ đệm tính bằng byte.

MON_IOCX_GET, được định nghĩa là _IOW(MON_IOC_MAGIC, 6, struct mon_get_arg)
 MON_IOCX_GETX, được định nghĩa là _IOW(MON_IOC_MAGIC, 10, struct mon_get_arg)

Các cuộc gọi này chờ các sự kiện đến nếu không có sự kiện nào trong bộ đệm kernel,
sau đó trả lại sự kiện đầu tiên. Đối số là một con trỏ tới sau
cấu trúc::

cấu trúc mon_get_arg {
	cấu trúc usbmon_packet *hdr;
	void *dữ liệu;
	size_t phân bổ;		/* Độ dài dữ liệu (có thể bằng 0) */
  };

Trước cuộc gọi, phải điền hdr, dữ liệu và phân bổ. Khi trở về, khu vực
được trỏ bởi hdr chứa cấu trúc sự kiện tiếp theo và bộ đệm dữ liệu chứa
dữ liệu nếu có. Sự kiện này bị xóa khỏi bộ đệm kernel.

MON_IOCX_GET sao chép 48 byte vào vùng hdr, MON_IOCX_GETX sao chép 64 byte.

MON_IOCX_MFETCH, được định nghĩa là _IOWR(MON_IOC_MAGIC, 7, struct mon_mfetch_arg)

Ioctl này chủ yếu được sử dụng khi ứng dụng truy cập vào bộ đệm
với mmap(2). Đối số của nó là một con trỏ tới cấu trúc sau::

cấu trúc mon_mfetch_arg {
	uint32_t ZZ0000ZZ Vector sự kiện được tìm nạp */
	uint32_t nfetch;	/* Số sự kiện cần tìm nạp (out: đã tìm nạp) */
	uint32_t nflush;	/*Số sự kiện cần xóa */
  };

Ioctl hoạt động theo 3 giai đoạn.

Đầu tiên, nó loại bỏ và loại bỏ tối đa các sự kiện nflush khỏi bộ đệm kernel.
Số lượng sự kiện thực tế bị loại bỏ sẽ được trả về trong nflush.

Thứ hai, nó đợi một sự kiện xuất hiện trong bộ đệm, trừ khi giả
thiết bị đang mở với O_NONBLOCK.

Thứ ba, nó trích xuất tối đa nfetch offset vào bộ đệm mmap và lưu trữ
chúng vào offvec. Số lượng bù đắp sự kiện thực tế được lưu trữ vào
tìm nạp.

MON_IOCH_MFLUSH, được định nghĩa là _IO(MON_IOC_MAGIC, 8)

Cuộc gọi này loại bỏ một số sự kiện khỏi bộ đệm kernel. Lập luận của nó
là số lượng sự kiện cần loại bỏ. Nếu bộ đệm chứa ít sự kiện hơn
hơn yêu cầu, tất cả các sự kiện hiện tại sẽ bị xóa và không có lỗi nào được báo cáo.
Điều này hoạt động khi không có sự kiện nào có sẵn.

FIONBIO

ioctl FIONBIO có thể được triển khai trong tương lai nếu có nhu cầu.

Ngoài ioctl(2) và read(2), tệp đặc biệt của nhị phân API có thể
được thăm dò ý kiến ​​với select(2) và poll(2). Nhưng lseek(2) không hoạt động.

* Quyền truy cập được ánh xạ bộ nhớ của bộ đệm kernel cho API nhị phân

Ý tưởng cơ bản rất đơn giản:

Để chuẩn bị, hãy ánh xạ bộ đệm bằng cách lấy kích thước hiện tại, sau đó sử dụng mmap(2).
Sau đó, thực hiện một vòng lặp tương tự như vòng lặp được viết bằng mã giả bên dưới::

struct mon_mfetch_arg tìm nạp;
   cấu trúc usbmon_packet *hdr;
   int nflush = 0;
   cho (;;) {
      lấy.offvec = vec; // Có N từ 32-bit
      tìm nạp.nfetch = N;   // Hoặc nhỏ hơn N
      lấy.nflush = nflush;
      ioctl(fd, MON_IOCX_MFETCH, &tìm nạp);   // Lỗi xử lý nữa
      nflush = tìm nạp.nfetch;       // Nhiều gói này sẽ được xóa khi hoàn tất
      cho (i = 0; i < nflush; i++) {
         hdr = (struct ubsmon_packet *) &mmap_area[vec[i]];
         if (hdr->type == '@') // Gói phụ
            tiếp tục;
         dữ liệu caddr_t = &mmap_area[vec[i]] + 64;
         process_packet(hdr, dữ liệu);
      }
   }

Vì vậy, ý tưởng chính là chỉ thực hiện một ioctl cho mỗi N sự kiện.

Mặc dù bộ đệm có dạng tròn nhưng các tiêu đề và dữ liệu được trả về không giao nhau
phần cuối của bộ đệm, do đó mã giả ở trên không cần bất kỳ sự thu thập nào.
