.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/vfat.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====
VFAT
====

USING VFAT
==========

Để sử dụng hệ thống tệp vfat, hãy sử dụng loại hệ thống tệp 'vfat'.  tức là::

mount -t vfat /dev/fd0 /mnt


Không yêu cầu định dạng phân vùng đặc biệt,
'mkdosfs' sẽ hoạt động tốt nếu bạn muốn định dạng từ bên trong Linux.

VFAT MOUNT OPTIONS
==================

ZZ0000ZZ
	Đặt chủ sở hữu của tất cả các tệp trên hệ thống tệp này.
	Mặc định là uid của quá trình hiện tại.

ZZ0000ZZ
	Đặt nhóm tất cả các tệp trên hệ thống tệp này.
	Giá trị mặc định là gid của quy trình hiện tại.

ZZ0000ZZ
	Mặt nạ cấp phép (đối với các tệp và thư mục, xem ZZ0001ZZ).
	Mặc định là ô của quy trình hiện tại.

ZZ0000ZZ
	Mặt nạ cấp phép cho thư mục.
	Mặc định là ô của quy trình hiện tại.

ZZ0000ZZ
	Mặt nạ cấp phép cho các tập tin.
	Mặc định là ô của quy trình hiện tại.

ZZ0000ZZ
	Tùy chọn này kiểm soát việc kiểm tra quyền của mtime/atime.

ZZ0000ZZ: Nếu quy trình hiện tại nằm trong nhóm ID nhóm của tệp,
                bạn có thể thay đổi dấu thời gian.

ZZ0000ZZ: Người dùng khác có thể thay đổi dấu thời gian.

Mặc định được đặt từ tùy chọn dmask. Nếu thư mục là
	có thể ghi, utime(2) cũng được cho phép. tức là ~dmask & 022.

Thông thường utime(2) kiểm tra tiến trình hiện tại là chủ sở hữu của
	tệp hoặc nó có khả năng CAP_FOWNER. Nhưng FAT
	hệ thống tập tin không có uid/gid trên đĩa, nên bình thường
	kiểm tra quá thiếu linh hoạt. Với tùy chọn này bạn có thể
	thư giãn nó.

ZZ0000ZZ
	Đặt số trang mã để chuyển đổi thành tên viết tắt
	các ký tự trên hệ thống tập tin FAT.
	Theo mặc định, cài đặt FAT_DEFAULT_CODEPAGE được sử dụng.

ZZ0000ZZ
	Bộ ký tự được sử dụng để chuyển đổi giữa
	mã hóa được sử dụng cho tên tệp hiển thị của người dùng và 16 bit
	Ký tự Unicode. Tên tập tin dài được lưu trữ trên đĩa
	ở định dạng Unicode, nhưng phần lớn Unix thì không
	biết cách xử lý Unicode.
	Theo mặc định, cài đặt FAT_DEFAULT_IOCHARSET được sử dụng.

Ngoài ra còn có tùy chọn thực hiện bản dịch UTF-8
	với tùy chọn utf8.

.. note:: ``iocharset=utf8`` is not recommended. If unsure, you should consider
	  the utf8 option instead.

ZZ0000ZZ
	UTF-8 là phiên bản Unicode an toàn cho hệ thống tập tin
	được sử dụng bởi bàn điều khiển. Nó có thể được kích hoạt hoặc vô hiệu hóa
	cho hệ thống tập tin với tùy chọn này.
	Nếu 'uni_xlate' được đặt, UTF-8 sẽ bị tắt.
	Theo mặc định, cài đặt FAT_DEFAULT_UTF8 được sử dụng.

ZZ0000ZZ
	Dịch các ký tự Unicode chưa được xử lý thành ký tự đặc biệt
	trình tự thoát.  Điều này sẽ cho phép bạn sao lưu và
	khôi phục tên tệp được tạo bằng bất kỳ Unicode nào
	nhân vật.  Cho đến khi Linux thực sự hỗ trợ Unicode,
	điều này mang lại cho bạn một sự thay thế.  Nếu không có tùy chọn này,
	một '?' được sử dụng khi không thể dịch được.  các
	ký tự thoát là ':' vì nó khác
	bất hợp pháp trên hệ thống tập tin vfat.  Trình tự trốn thoát
	được sử dụng là ':' và bốn chữ số thập lục phân
	unicode.

ZZ0000ZZ
	Khi tạo bí danh 8.3, thông thường bí danh sẽ
	kết thúc bằng '~1' hoặc dấu ngã theo sau là một số.  Nếu điều này
	tùy chọn được đặt, thì nếu tên tệp là
	"longfilename.txt" và "longfile.txt" không
	hiện tồn tại trong thư mục, longfile.txt sẽ
	là bí danh ngắn thay vì longfi~1.txt.

ZZ0000ZZ
	Sử dụng giá trị "cụm miễn phí" được lưu trữ trên FSINFO. Nó sẽ
	được sử dụng để xác định số lượng cụm miễn phí mà không cần
	quét đĩa. Nhưng nó không được sử dụng theo mặc định, bởi vì
	Windows gần đây không cập nhật chính xác ở một số nơi
	trường hợp. Nếu bạn chắc chắn "cụm miễn phí" trên FSINFO là
	đúng, bằng tùy chọn này bạn có thể tránh được việc quét đĩa.

ZZ0000ZZ
	Dừng in các thông báo cảnh báo nhất định.

ZZ0000ZZ
	Cài đặt kiểm tra độ nhạy trường hợp.

ZZ0000ZZ: nghiêm ngặt, phân biệt chữ hoa chữ thường

ZZ0000ZZ: thoải mái, không phân biệt chữ hoa chữ thường

ZZ0000ZZ: bình thường, cài đặt mặc định, hiện không phân biệt chữ hoa chữ thường

ZZ0001ZZ
	Điều này không được dùng nữa đối với vfat. Thay vào đó hãy sử dụng ZZ0000ZZ.

ZZ0000ZZ
	Cài đặt hiển thị/tạo tên viết tắt.

ZZ0000ZZ: chuyển sang chữ thường để hiển thị,
	mô phỏng quy tắc Windows 95 để tạo.

ZZ0000ZZ: mô phỏng quy tắc Windows 95 để hiển thị/tạo.

ZZ0000ZZ: mô phỏng quy tắc Windows NT để hiển thị/tạo.

ZZ0000ZZ: mô phỏng quy tắc Windows NT để hiển thị,
	mô phỏng quy tắc Windows 95 để tạo.

Cài đặt mặc định là ZZ0000ZZ.

ZZ0000ZZ
	Giải thích dấu thời gian là UTC thay vì giờ địa phương.
	Tùy chọn này vô hiệu hóa việc chuyển đổi dấu thời gian
	giữa giờ địa phương (được Windows sử dụng trên FAT) và UTC
	(mà Linux sử dụng nội bộ).  Điều này đặc biệt
	hữu ích khi gắn thiết bị (như máy ảnh kỹ thuật số)
	được đặt thành UTC để tránh những cạm bẫy của
	giờ địa phương.

ZZ0001ZZ
	Đặt phần bù cho việc chuyển đổi dấu thời gian từ giờ địa phương
	được sử dụng bởi FAT đến UTC. tức là <phút> phút sẽ bị trừ
	từ mỗi dấu thời gian để chuyển đổi nó thành UTC được sử dụng nội bộ bởi
	Linux. Điều này hữu ích khi múi giờ được đặt trong ZZ0000ZZ
	không phải múi giờ được sử dụng bởi hệ thống tập tin. Lưu ý rằng điều này
	tùy chọn vẫn không cung cấp dấu thời gian chính xác trong tất cả
	các trường hợp có DST - dấu thời gian trong DST khác
	cài đặt sẽ tắt sau một giờ.

ZZ0000ZZ
	Nếu được đặt, các bit quyền thực thi của tệp sẽ là
	chỉ được phép nếu phần mở rộng của tên là .EXE,
	.COM hoặc .BAT. Không được đặt theo mặc định.

ZZ0000ZZ
	Có thể được đặt nhưng không được sử dụng trong quá trình triển khai hiện tại.

ZZ0000ZZ
	Nếu được đặt, thuộc tính ATTR_SYS trên FAT sẽ được xử lý như
	Cờ IMMUTABLE trên Linux. Không được đặt theo mặc định.

ZZ0000ZZ
	Nếu được đặt, hệ thống tập tin sẽ cố gắng xóa vào đĩa nhiều hơn
	sớm hơn bình thường. Không được đặt theo mặc định.

ZZ0000ZZ
	FAT có thuộc tính ATTR_RO (chỉ đọc). Trên Windows,
	ATTR_RO của thư mục sẽ bị bỏ qua,
	và chỉ được các ứng dụng sử dụng làm cờ (ví dụ: nó được đặt
	cho thư mục tùy chỉnh).

Nếu bạn muốn sử dụng ATTR_RO làm cờ chỉ đọc ngay cả đối với
	thư mục, hãy đặt tùy chọn này.

ZZ0000ZZ
	chỉ định hành vi FAT đối với các lỗi nghiêm trọng: hoảng sợ, tiếp tục
	mà không làm bất cứ điều gì hoặc kể lại phân vùng trong
	chế độ chỉ đọc (hành vi mặc định).

ZZ0000ZZ
	Nếu được đặt, sẽ phát lệnh loại bỏ/TRIM cho khối
	thiết bị khi các khối được giải phóng. Điều này hữu ích cho các thiết bị SSD
	và LUN được cung cấp thưa thớt/thiếu.

ZZ0000ZZ
	Chỉ kích hoạt tính năng này nếu bạn muốn xuất hệ thống tệp FAT
	trên NFS.

ZZ0000ZZ: Tùy chọn này duy trì chỉ mục (bộ đệm) của thư mục
		ZZ0001ZZ của ZZ0002ZZ được sử dụng bởi mã liên quan đến nfs để
		cải thiện việc tra cứu. Toàn bộ thao tác tập tin (đọc/ghi) trên NFS là
		được hỗ trợ nhưng với việc xóa bộ nhớ đệm ở máy chủ NFS, điều này có thể
		dẫn đến các vấn đề về ESTALE.

ZZ0000ZZ: Tùy chọn này dựa trên số ZZ0001ZZ và tước hiệu tệp
		trên vị trí trên đĩa của tệp trong mục nhập thư mục MS-DOS.
		Điều này đảm bảo rằng ESTALE sẽ không được trả về sau khi một tập tin được
		bị xóa khỏi bộ đệm inode. Tuy nhiên, điều đó có nghĩa là hoạt động
		chẳng hạn như đổi tên, tạo và hủy liên kết có thể khiến các tước hiệu tệp bị
		trước đó đã trỏ vào một tệp để trỏ vào một tệp khác,
		có khả năng gây ra hỏng dữ liệu. Vì lý do này, điều này
		tùy chọn cũng gắn kết hệ thống tập tin chỉ đọc.

Để duy trì khả năng tương thích ngược, ZZ0000ZZ cũng được chấp nhận,
	mặc định là "stale_rw".

ZZ0000ZZ
	Nếu được đặt, hãy sử dụng Khối tham số BIOS mặc định dự phòng
	cấu hình, được xác định bởi kích thước thiết bị hỗ trợ. Những tĩnh này
	các tham số khớp với các giá trị mặc định được giả định bởi DOS 1.x cho 160 kiB,
	Đĩa mềm và hình ảnh đĩa mềm 180 kiB, 320 kiB và 360 kiB.



LIMITATION
==========

Vùng bị phân bổ của tệp sẽ bị loại bỏ tại thời điểm umount/evict
khi sử dụng fallocate với FALLOC_FL_KEEP_SIZE.
Vì vậy, Người dùng nên cho rằng vùng bị sai có thể bị loại bỏ tại
lần đóng cuối cùng nếu có áp lực bộ nhớ dẫn đến việc trục xuất
inode từ bộ nhớ. Kết quả là, đối với bất kỳ sự phụ thuộc nào vào
vùng fallocated, người dùng phải đảm bảo kiểm tra lại fallocate
sau khi mở lại tập tin.

TODO
====
Cần phải loại bỏ những thứ quét thô.  Thay vào đó, hãy luôn sử dụng
một cách tiếp cận mục nhập thư mục tiếp theo.  Điều duy nhất còn lại là sử dụng
quét thô là mã đổi tên thư mục.


POSSIBLE PROBLEMS
=================

- vfat_valid_longname không kiểm tra đúng tên dành riêng.
- Khi tên ổ đĩa trùng với tên thư mục trong thư mục gốc
  thư mục của hệ thống tập tin, tên thư mục đôi khi hiển thị
  lên dưới dạng một tập tin trống.
- tùy chọn autoconv không hoạt động chính xác.


TEST SUITE
==========
Nếu bạn dự định thực hiện bất kỳ sửa đổi nào đối với hệ thống tập tin vfat, vui lòng
lấy bộ thử nghiệm đi kèm với bản phân phối vfat tại

ZZ0000ZZ

Điều này kiểm tra khá nhiều phần của hệ thống tập tin vfat và các phần bổ sung
các thử nghiệm về tính năng mới hoặc tính năng chưa được thử nghiệm sẽ được đánh giá cao.

NOTES TRÊN THE STRUCTURE CỦA THE VFAT FILESYSTEM
=============================================
Tài liệu này được cung cấp bởi Galen C. Hunt gchunt@cs.rochester.edu và
được chú thích nhẹ nhàng bởi Gordon Chaffee.

Tài liệu này trình bày một cái nhìn tổng quan rất thô sơ, mang tính kỹ thuật về
kiến thức về hệ thống tệp FAT mở rộng được sử dụng trong Windows NT 3.5 và
Windows 95. Tôi không đảm bảo rằng bất kỳ điều nào sau đây là đúng,
nhưng có vẻ như vậy.

Hệ thống tệp FAT mở rộng gần giống với FAT
hệ thống tệp được sử dụng trong các phiên bản DOS lên đến và bao gồm ZZ0000ZZ
:-).  Sự thay đổi đáng kể là việc bổ sung các tên tệp dài.
Những tên này hỗ trợ tối đa 255 ký tự bao gồm dấu cách và chữ thường
các ký tự viết hoa trái ngược với tên viết tắt 8.3 truyền thống.

Dưới đây là mô tả về mục FAT truyền thống trong hiện tại
Hệ thống tập tin Windows 95::

thư mục struct { // Tên ngắn 8.3
                tên char không dấu[8];          // tên tập tin
                ký tự không dấu ext[3];           // phần mở rộng tập tin
                attr char không dấu;             // byte thuộc tính
		trường hợp char không dấu;		// Trường hợp cho cơ sở và phần mở rộng
		char không dấu ctime_ms;		// Thời gian tạo, mili giây
		ctime char không dấu [2];		// Thời gian tạo
		cdate char không dấu [2];		// Ngày tạo
		adate char không dấu [2];		// Ngày truy cập lần cuối
		ký tự không dấu dành riêng [2];	// giá trị dành riêng (bỏ qua)
                thời gian char không dấu [2];          // dấu thời gian
                ngày char không dấu [2];          // dấu ngày tháng
                bắt đầu char không dấu [2];         // số cụm bắt đầu
                kích thước char không dấu [4];          // kích thước của tập tin
        };


Trường lcase chỉ định liệu cơ sở và/hoặc phần mở rộng của 8.3 có
tên nên viết hoa.  Trường này dường như không được sử dụng bởi
Windows 95 nhưng nó được sử dụng bởi Windows NT.  Trường hợp tên tập tin không
hoàn toàn tương thích từ Windows NT đến Windows 95. Nó không hoàn toàn
Tuy nhiên, tương thích theo hướng ngược lại.  Tên tập tin phù hợp
không gian tên 8.3 và được viết trên Windows NT ở dạng chữ thường sẽ
hiển thị dưới dạng chữ hoa trên Windows 95.

.. note:: Note that the ``start`` and ``size`` values are actually little
          endian integer values.  The descriptions of the fields in this
          structure are public knowledge and can be found elsewhere.

Với hệ thống FAT mở rộng, Microsoft đã bổ sung thêm
mục nhập thư mục cho bất kỳ tập tin nào có tên mở rộng.  (Bất kỳ tên nào
phù hợp về mặt pháp lý trong sơ đồ mã hóa 8.3 cũ không có thêm
các mục nhập.) Tôi gọi những vị trí mục nhập bổ sung này.  Về cơ bản, slot là một
mục nhập thư mục được định dạng đặc biệt chứa tối đa 13 ký tự
tên mở rộng của một tập tin.  Hãy coi các khe cắm như là nhãn bổ sung cho
mục nhập thư mục của tập tin mà chúng tương ứng.  Microsoft
thích coi mục 8.3 của một tập tin là bí danh của nó và
các mục thư mục khe cắm mở rộng làm tên tệp.

Cấu trúc C cho một mục nhập thư mục vị trí như sau::

struct slot { // Tối đa 13 ký tự cho một tên dài
                id char không dấu;               // số thứ tự cho vị trí
                tên char không dấu0_4[10];      // 5 ký tự đầu tiên trong tên
                attr char không dấu;             // byte thuộc tính
                char không dấu dành riêng;         // luôn luôn là 0
                char không dấu bí danh_checksum;   // tổng kiểm tra bí danh 8.3
                tên char không dấu5_10[12];     // 6 ký tự nữa trong tên
                bắt đầu char không dấu [2];         // số cụm bắt đầu
                tên char không dấu11_12[4];     // 2 ký tự cuối cùng trong tên
        };


Nếu bố cục của các khe trông hơi kỳ quặc thì đó chỉ là
vì những nỗ lực của Microsoft nhằm duy trì khả năng tương thích với phiên bản cũ
phần mềm.  Các khe cắm phải được ngụy trang để ngăn phần mềm cũ xâm nhập
hoảng loạn.  Để đạt được mục đích này, một số biện pháp được thực hiện:

1) Byte thuộc tính cho mục nhập thư mục vị trí luôn được đặt
           đến 0x0f.  Điều này tương ứng với một mục thư mục cũ với
           thuộc tính "ẩn", "hệ thống", "chỉ đọc" và "khối lượng
           nhãn".  Hầu hết các phần mềm cũ sẽ bỏ qua mọi thư mục
           các mục có tập bit "nhãn âm lượng".  Nhãn khối lượng thực
           các mục không có ba bit khác được đặt.

2) Cụm bắt đầu luôn được đặt thành 0, điều này không thể
           giá trị cho tệp DOS.

Bởi vì hệ thống FAT mở rộng có khả năng tương thích ngược nên
phần mềm cũ có thể sửa đổi các mục trong thư mục.  Các biện pháp phải
được thực hiện để đảm bảo tính hợp lệ của các slot.  Một hệ thống FAT mở rộng có thể
xác minh rằng một vị trí trên thực tế thuộc về mục nhập thư mục 8.3 bằng cách
sau đây:

1) Định vị.  Khe cắm cho một tập tin luôn tiến hành ngay lập tức
           mục nhập thư mục 8.3 tương ứng của họ.  Ngoài ra, mỗi
           slot có id đánh dấu thứ tự của nó trong tệp mở rộng
           tên.  Đây là một cái nhìn rất ngắn gọn về thư mục 8.3
           mục nhập và các khe tên dài tương ứng của nó cho tệp
           "My Big File.Extension dài"::

<đang xử lý các tập tin...>
                <khe #3, id = 0x43, ký tự = "h dài">
                <khe #2, id = 0x02, ký tự = "xtension whic">
                <khe #1, id = 0x01, ký tự = "Tệp lớn của tôi.E">
                <mục nhập thư mục, tên = "MYBIGFIL.EXT">


           .. note:: Note that the slots are stored from last to first.  Slots
được đánh số từ 1 đến N. Khe thứ N là ZZ0000ZZ với
		     0x40 để đánh dấu nó là cái cuối cùng.

2) Tổng kiểm tra.  Mỗi vị trí có một giá trị alias_checksum.  các
           tổng kiểm tra được tính từ tên 8.3 bằng cách sử dụng
           thuật toán sau::

vì (tổng = i = 0; i < 11; i++) {
                        tổng = (((sum&1)<<7)|((sum&0xfe)>>1)) + name[i]
                }


3) Nếu còn chỗ trống ở khe cuối cùng, Unicode ZZ0000ZZ
	   được lưu trữ sau ký tự cuối cùng.  Sau đó, tất cả đều không được sử dụng
	   các ký tự trong khe cuối cùng được đặt thành Unicode 0xFFFF.

Cuối cùng, lưu ý rằng tên mở rộng được lưu trữ bằng Unicode.  Mỗi Unicode
ký tự có hai hoặc bốn byte, được mã hóa UTF-16LE.
