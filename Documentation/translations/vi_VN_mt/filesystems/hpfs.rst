.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/hpfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Đọc/Ghi HPFS 2.09
======================

1998-2004, Mikulas Patocka

:email: mikulas@artax.karlin.mff.cuni.cz
:trang chủ: ZZ0000ZZ

Tín dụng
=======
Chris Smith, 1993, HPFS chỉ đọc ban đầu, một số tệp cấu trúc mã và hpfs
	được lấy từ nó

Jacques Gelinas, MSDos mmap, Lấy cảm hứng từ fs/nfs/mmap.c (Jon Tombs ngày 15 tháng 8 năm 1993)

Werner Almesberger, 1992, 1993, trình phân tích cú pháp tùy chọn MSDos & chuyển đổi CR/LF

Tùy chọn gắn kết

uid=xxx,gid=xxx,umask=xxx (mặc định uid=gid=0 umask=default_system_umask)
	Đặt chủ sở hữu/nhóm/chế độ cho các tệp không được chỉ định trong phần mở rộng
	thuộc tính. Chế độ được đảo ngược umask - ví dụ umask 027 cung cấp cho chủ sở hữu
	tất cả các quyền, quyền đọc nhóm và bất kỳ ai khác không có quyền truy cập. Lưu ý
	chế độ tệp đối với chế độ tệp được ghi bằng 0666. Nếu bạn muốn tệp có 'x'
	quyền, bạn phải sử dụng các thuộc tính mở rộng.
case=low,asis (asis mặc định)
	Viết thường tên tệp trong readdir.
conv=binary,text,auto (nhị phân mặc định)
	CR/LF -> Chuyển đổi LF, nếu tự động, quyết định được đưa ra theo tiện ích mở rộng
	- có một danh sách các phần mở rộng văn bản (tôi nghĩ tốt hơn hết là không nên chuyển đổi
	tệp văn bản hơn là làm hỏng tệp nhị phân). Nếu bạn muốn thay đổi danh sách đó,
	thay đổi nó trong nguồn. Bản gốc HPFS chỉ đọc có chứa một số nội dung lạ
	thuật toán heuristic mà tôi đã loại bỏ. Tôi nghĩ thật nguy hiểm nếu để
	máy tính quyết định xem tập tin là văn bản hay nhị phân. Ví dụ: DJGPP
	các tệp nhị phân chứa tin nhắn văn bản nhỏ ở đầu và chúng có thể
	xác định sai và bị hư hỏng trong một số trường hợp.
check=none, normal, strict (mặc định là bình thường)
	Kiểm tra mức độ. Việc chọn không sẽ chỉ gây ra sự tăng tốc nhỏ và lớn
	nguy hiểm. Tôi đã cố gắng viết nó để nó không bị lỗi nếu bật check=normal
	hệ thống tập tin bị hỏng. check=strict có nghĩa là có nhiều kiểm tra không cần thiết -
	được sử dụng để gỡ lỗi (ví dụ: nó kiểm tra xem tệp có được phân bổ trong
	bitmap khi truy cập nó).
lỗi=tiếp tục,remount-ro,panic (remount-ro mặc định)
	Hành vi khi tìm thấy lỗi hệ thống tập tin.
chkdsk=no,errors,always (lỗi mặc định)
	Khi nào cần đánh dấu hệ thống tập tin là bẩn để OS/2 kiểm tra nó.
eas=no,ro,rw (rw mặc định)
	Phải làm gì với các thuộc tính mở rộng. 'không' - bỏ qua chúng và sử dụng luôn
	các giá trị được chỉ định trong tùy chọn uid/gid/mode. 'ro' - đọc mở rộng
	thuộc tính nhưng không tạo ra chúng. 'rw' - tạo thuộc tính mở rộng
	khi bạn sử dụng chmod/chown/chgrp/mknod/ln -s trên hệ thống tập tin.
timeshift=(-)nnn (mặc định 0)
	Thay đổi thời gian theo nnn giây. Ví dụ: nếu bạn thấy trong linux
	nhiều hơn một giờ so với dưới os/2, hãy sử dụng timeshift=-3600.


Tên tệp
==========

Giống như trong OS/2, tên tệp không phân biệt chữ hoa chữ thường. Tuy nhiên, Shell cho rằng những cái tên đó
phân biệt chữ hoa chữ thường, vì vậy, ví dụ: khi bạn tạo tệp FOO, bạn có thể sử dụng
'mèo FOO', 'mèo Foo', 'mèo foo' hoặc 'mèo FZZ0000ZZ'. Lưu ý rằng bạn
cũng sẽ không thể biên dịch kernel linux (và có thể cả những thứ khác) trên HPFS
bởi vì kernel tạo các tệp khác nhau có tên như bootect.S và
bootect.s. Khi tìm kiếm file có tên có ký tự >= 128, codepages
được sử dụng - xem bên dưới.
OS/2 bỏ qua các dấu chấm và dấu cách ở cuối tên tệp, do đó trình điều khiển này thực hiện như
tốt. Nếu bạn tạo 'a. ...', tập tin 'a' sẽ được tạo, nhưng bạn vẫn có thể
truy cập nó dưới tên 'a.', 'a..', 'a .  . . ' vân vân.


Thuộc tính mở rộng
===================

Trên các phân vùng HPFS, OS/2 có thể liên kết với mỗi tệp một thông tin đặc biệt gọi là
thuộc tính mở rộng. Thuộc tính mở rộng là các cặp (khóa, giá trị) trong đó khóa là
một chuỗi ascii xác định thuộc tính và giá trị đó là bất kỳ chuỗi byte nào của
chiều dài thay đổi. OS/2 lưu trữ vị trí cửa sổ, biểu tượng và loại tệp ở đó. Vì vậy
tại sao không sử dụng nó cho thông tin dành riêng cho unix như chủ sở hữu tệp hoặc quyền truy cập? Cái này
người lái xe có thể làm điều đó Nếu bạn chown/chgrp/chmod trên phân vùng hpfs, đã mở rộng
các thuộc tính có khóa "UID", "GID" hoặc "MODE" và các giá trị 2 byte được tạo. Chỉ
các thuộc tính mở rộng đó có giá trị khác với các giá trị mặc định được chỉ định trong mount
các tùy chọn được tạo ra. Sau khi được tạo, các thuộc tính mở rộng sẽ không bao giờ bị xóa,
họ vừa mới thay đổi. Điều đó có nghĩa là khi uid mặc định của bạn = 0 và bạn gõ
đại loại như 'tập tin chown luser; chown root file' tập tin sẽ chứa
thuộc tính mở rộng UID=0. Và khi bạn bỏ qua fs và gắn kết lại với
uid=luser_uid, tệp sẽ vẫn thuộc quyền sở hữu của root! Nếu bạn chmod file thành 444,
thuộc tính mở rộng "MODE" sẽ không được đặt, trường hợp đặc biệt này được thực hiện bằng cách đặt
cờ chỉ đọc. Khi bạn mknod một thiết bị khối hoặc ký tự, ngoài "MODE",
Thuộc tính mở rộng 4 byte đặc biệt "DEV" sẽ được tạo có chứa thiết bị
số. Hiện tại trình điều khiển này không thể thay đổi kích thước các thuộc tính mở rộng - điều đó có nghĩa là
rằng nếu ai đó (tôi không biết là ai?) đã đặt "UID", "GID", "MODE" hoặc "DEV"
các thuộc tính có kích thước khác nhau, chúng sẽ không được viết lại và thay đổi các thuộc tính này
các giá trị không hoạt động.


Liên kết tượng trưng
========

Bạn có thể thực hiện liên kết tượng trưng trên phân vùng HPFS, liên kết tượng trưng đạt được bằng cách cài đặt mở rộng
thuộc tính có tên "SYMLINK" với giá trị liên kết tượng trưng. Giống như trên ext2, bạn có thể chọn và
liên kết tượng trưng chgrp nhưng tôi không biết nó tốt cho việc gì. chmoding kết quả liên kết tượng trưng
trong tập tin chmoding nơi các điểm liên kết tượng trưng. Các liên kết tượng trưng này chỉ dành cho việc sử dụng Linux và
không tương thích với OS/2. Liên kết tượng trưng OS/2 PmShell không được hỗ trợ vì chúng
được lưu trữ một cách rất điên rồ. Họ đã cố gắng làm điều đó để liên kết thay đổi khi tập tin được
đã di chuyển ... đôi khi nó hoạt động. Nhưng liên kết được lưu trữ một phần trong thư mục
thuộc tính mở rộng và một phần trong OS2SYS.INI. Tôi không muốn (và không biết làm thế nào)
để phân tích hoặc thay đổi OS2SYS.INI.


Trang mã
=========

HPFS có thể chứa một số bảng viết hoa cho một số trang mã và mỗi bảng
tập tin có một con trỏ để mã hóa tên của nó. Tuy nhiên OS/2 đã được tạo ra trong
Nước Mỹ nơi mọi người không quan tâm nhiều đến các bảng mã và quá nhiều bảng mã
hỗ trợ là khá nhiều lỗi. Tôi có Czech OS/2 hoạt động ở codepage 852 trên đĩa của mình.
Khi tôi khởi động English OS/2 hoạt động trên cp 850 và tôi đã tạo một tệp trên 852 của mình
phân vùng. Nó đánh dấu tên tệp mã trang là 850 - tốt. Nhưng khi tôi khởi động lại
Czech OS/2, tệp hoàn toàn không thể truy cập được dưới bất kỳ tên nào. Có vẻ như vậy
OS/2 viết hoa mẫu tìm kiếm với trang mã hệ thống (852) và tệp
tên nó so sánh với trang mã của nó (850). Những điều này không bao giờ có thể phù hợp. Có phải không?
thực sự những gì các nhà phát triển IBM mong muốn? Nhưng vấn đề vẫn tiếp tục. Khi tôi tạo trong
Czech OS/2 một tệp khác trong thư mục đó, tệp đó cũng không thể truy cập được. Hệ điều hành/2
có thể sử dụng phương pháp viết hoa khác nhau khi tìm kiếm nơi đặt tệp
(lưu ý rằng các tập tin trong thư mục HPFS phải được sắp xếp) và khi tìm kiếm
một tập tin. Cuối cùng khi tôi mở thư mục này trong PmShell, PmShell bị lỗi (
Điều buồn cười là khi khởi động lại, PmShell đã cố gắng mở lại thư mục này
một lần nữa :-). chkdsk vui vẻ bỏ qua những lỗi này và chỉ đĩa cấp thấp
sửa đổi đã cứu tôi.  Không bao giờ trộn lẫn các phiên bản ngôn ngữ khác nhau của OS/2 trên một
hệ thống mặc dù HPFS được thiết kế để cho phép điều đó.
Được rồi, tôi có thể triển khai hỗ trợ bảng mã phức tạp cho trình điều khiển này nhưng tôi nghĩ vậy
sẽ gây ra nhiều vấn đề hơn là lợi ích khi triển khai lỗi như vậy trong OS/2.
Vì vậy, trình điều khiển này chỉ đơn giản sử dụng bảng mã đầu tiên nó tìm thấy để viết hoa và
viết thường bất kể chỉ mục mã trang tập tin là gì. Thông thường tất cả các tên tập tin đều ở dạng
bảng mã này - nếu bạn không cố gắng làm những gì tôi đã mô tả ở trên :-)


Lỗi đã biết
==========

HPFS386 trên máy chủ OS/2 không được hỗ trợ. HPFS386 được cài đặt trên máy khách OS/2 thông thường
nên làm việc. Nếu bạn có máy chủ OS/2, chỉ sử dụng chế độ chỉ đọc. Tôi không biết làm thế nào
để xử lý một số cấu trúc HPFS386 như danh sách kiểm soát truy cập hoặc perm mở rộng
list, tôi không biết làm thế nào để xóa chúng khi tập tin bị xóa và làm thế nào để không
ghi đè lên chúng bằng các thuộc tính mở rộng. Gửi cho tôi một số thông tin về các cấu trúc này
và tôi sẽ làm được. Tuy nhiên, trình điều khiển này sẽ phát hiện sự hiện diện của HPFS386
cấu trúc, chỉ đọc lại và không phá hủy chúng (tôi hy vọng).

Khi không còn đủ chỗ cho các thuộc tính mở rộng, chúng sẽ bị cắt bớt
và không có lỗi được trả lại.

OS/2 không thể truy cập tệp nếu đường dẫn dài hơn khoảng 256 ký tự nhưng điều này
trình điều khiển cho phép bạn làm điều đó. chkdsk bỏ qua những lỗi như vậy.

Đôi khi bạn sẽ không thể xóa một số tệp trên hệ thống tệp đầy đủ
(trả về lỗi ENOSPC). Đó là vì tệp ở nút không có lá trong cây thư mục
(một thư mục, nếu lớn, có thư mục trong cây trên HPFS) phải được thay thế
với một nút khác khi bị xóa. Và tập tin mới đó có thể có tên lớn hơn
tên cũ nên tên mới không vừa với nút thư mục (dnode). Và đó
sẽ dẫn đến việc chia cây thư mục, chiếm dung lượng ổ đĩa. Cách giải quyết là
để xóa các tập tin khác là lá (xác suất tập tin đó không phải là lá là
khoảng 1/50) hoặc cắt bớt tệp trước để tạo khoảng trống.
Bạn chỉ gặp phải vấn đề này nếu bạn có nhiều thư mục để
Dải thư mục được phân bổ trước đã đầy, tức là::

số_of_directories/size_of_filesystem_in_mb > 4.

Bạn không thể xóa các thư mục đang mở.

Bạn không thể đổi tên các thư mục (nó có ích gì?).

Đổi tên tập tin để chỉ thay đổi trường hợp không hoạt động. Trình điều khiển này hỗ trợ nó
nhưng vfs thì không. Nội dung như 'tệp mv FILE' sẽ không hoạt động.

Tất cả các thời điểm và thời gian thư mục không được cập nhật. Đó là do hiệu suất
lý do. Nếu bạn thực sự muốn cập nhật chúng, hãy cho tôi biết, tôi sẽ viết nó (nhưng
nó sẽ chậm).

Khi hệ thống hết bộ nhớ và trao đổi, hệ thống tập tin có thể bị hỏng nhẹ
(tập tin bị mất, thư mục không cân bằng). (Tôi đoán tất cả hệ thống tập tin đều có thể làm được điều đó).

Khi biên dịch, bạn nhận được cảnh báo: khai báo hàm không phải là nguyên mẫu. Có
có ai biết nó có nghĩa là gì không?


Thông báo "cây không cân bằng" có nghĩa là gì?
=========================================

Các phiên bản cũ của trình điều khiển này đôi khi tạo ra các cây dnode không cân bằng. Hệ điều hành/2
chkdsk không hét lên nếu cây mất cân bằng (và đôi khi tạo ra
cây không cân bằng nữa :-) nhưng cả HPFS và HPFS386 đều có lỗi mà hiếm khi xảy ra
bị gãy khi cây không cân bằng. Trình điều khiển này xử lý cây không cân bằng
chính xác và viết cảnh báo nếu tìm thấy chúng. Nếu bạn thấy thông báo này thì đây là
có lẽ là do các thư mục được tạo bằng phiên bản cũ của trình điều khiển này.
Cách giải quyết là di chuyển tất cả các tệp từ thư mục đó sang thư mục khác rồi quay lại
một lần nữa. Làm điều đó trong Linux, không phải OS/2! Nếu bạn thấy thông báo này trong thư mục đó là
toàn bộ được tạo bởi trình điều khiển này, đó là BUG - hãy cho tôi biết về nó.


Lỗi trong OS/2
============

Khi bạn có hai (hoặc nhiều) thư mục bị mất trỏ vào nhau, chkdsk
bị khóa khi sửa chữa hệ thống tập tin.

Đôi khi (tôi nghĩ là ngẫu nhiên) khi bạn tạo một tệp có tên một ký tự bên dưới
OS/2, OS/2 đánh dấu nó là 'dài'. chkdsk sau đó xóa cờ này với nội dung "Fs nhỏ
đã sửa lỗi".

Các tên tệp như "a .b" được OS/2 đánh dấu là 'dài' nhưng chkdsk "sửa" nó và
đánh dấu chúng là ngắn (và viết "đã sửa lỗi fs nhỏ"). Lỗi này không có trong
HPFS386.

Lỗi trang mã được mô tả ở trên
=============================

Nếu bạn không cài đặt các gói sửa lỗi, thì còn rất nhiều, rất nhiều gói khác...


Lịch sử
=======

====== ===============================================================================
0,90 Phát hành công khai lần đầu
0.91 Đã sửa lỗi khiến việc ghi vào bộ nhớ khi write_inode được gọi
       mở inode (hiếm khi xảy ra)
0.92 Đã sửa một chút rò rỉ bộ nhớ trong các nút thư mục giải phóng
0.93 Đã sửa lỗi khóa máy khi có quá nhiều tên tệp
       với 15 ký tự đầu tiên giống nhau
       Đã sửa lỗi write_file thành tệp 0 khi ghi vào cuối tệp
0.94 Đã khắc phục một chút rò rỉ bộ nhớ khi cố gắng xóa tệp hoặc thư mục bận
0,95 Đã sửa lỗi i_hpfs_parent_dir không được cập nhật khi di chuyển tệp
1.90 Phiên bản đầu tiên cho hạt nhân 2.1.1xx
1.91 Đã sửa lỗi chk_sector không thành công khi các cung ở cuối đĩa
       Đã sửa lỗi tình trạng dồn đuổi khi write_inode được gọi trong khi xóa tệp
       Đã sửa lỗi có thể xảy ra (với xác suất rất thấp) khi
       sử dụng 0xff trong tên tệp.

Khóa viết lại để tránh điều kiện chủng tộc

Tùy chọn gắn kết 'eas' hiện hoạt động

Fsync không còn trả về lỗi

Các tệp bắt đầu bằng '.' được đánh dấu ẩn

Đã thêm hỗ trợ kể lại

Alloc không quá chậm khi hệ thống tập tin đầy

Đôi khi không còn cập nhật nữa vì nó làm chậm hoạt động

Dọn dẹp mã (xóa tất cả các bản in gỡ lỗi nhận xét)
1.92 Đã sửa lỗi khi đồng bộ hóa được gọi ngay trước khi đóng tệp
1.93 Đã sửa đổi để hoạt động với kernel >= 2.1.131, không biết có ổn không
       hoạt động với các phiên bản trước

Đã khắc phục sự cố có thể xảy ra với các ổ đĩa > 64G (nhưng tôi không có ổ đĩa này nên tôi không thể
       kiểm tra nó)

Đã sửa lỗi tràn tệp ở 2G

Đã thêm tùy chọn mới 'timeshift'

Đã thay đổi hành vi trên HPFS386: Hiện tại có thể hoạt động trên HPFS386 trong
       chế độ chỉ đọc

Đã sửa lỗi làm chậm quá trình phân bổ và ngăn việc phân bổ 100% dung lượng
       (lỗi này không có tính phá hoại)
1.94 Đã thêm cách giải quyết cho một lỗi trong Linux

Đã sửa lỗi rò rỉ một bộ đệm

Đã sửa một số điểm không tương thích với các thuộc tính mở rộng lớn (nhưng vẫn
       không ổn 100%, tôi không có thông tin về nó và OS/2 không muốn tạo chúng)

Phân bổ viết lại

Đã sửa lỗi với i_blocks (du đôi khi không hiển thị giá trị chính xác)

Các thư mục không còn tập hợp thuộc tính lưu trữ (một số chương trình không thích
       nó)

Đã sửa lỗi khiến một cờ trong cây anode lớn bị lỗi (không phải vậy).
       phá hoại)
1.95 Đã sửa lỗi rò rỉ bộ đệm, điều đó có thể xảy ra trên hệ thống tệp bị hỏng

Đã sửa một lỗi trong phân bổ ở phiên bản 1.94
1.96 Đã thêm cách giải quyết cho một lỗi trong OS/2 (HPFS đã bị khóa, HPFS386 đã báo cáo
       đôi khi bị lỗi khi mở thư mục trong PMSHELL)

Đã sửa lỗi cuộc đua bitmap có thể xảy ra

Đã khắc phục sự cố có thể xảy ra trên các đĩa lớn

Bây giờ bạn có thể xóa các tập tin đang mở

Đã sửa lỗi cuộc đua không phá hủy khi đổi tên
1.97 Hỗ trợ HPFS v3 (trên các phân vùng lớn)

ZĐã sửa lỗi không cho phép tạo tệp > 128M
       (phải là 2G)
1.97.1 Đã thay đổi tên của các ký hiệu chung

Đã sửa lỗi khi chỉnh sửa hoặc chọn thư mục gốc
1.98 Đã sửa lỗi bế tắc khi sử dụng old_readdir
       Xử lý thư mục tốt hơn; giải pháp cho lỗi "cây không cân bằng" trong OS/2
1.99 Đã khắc phục sự cố có thể xảy ra khi không đủ dung lượng trong khi xóa
       tập tin

Bây giờ nó cố gắng cắt bớt tập tin nếu không có đủ dung lượng khi
       xóa

Đã loại bỏ rất nhiều mã dư thừa
2.00 Đã sửa lỗi đổi tên (nó đã có từ phiên bản 1.96)
       Chiến lược chống phân mảnh tốt hơn
2.01 Đã khắc phục sự cố với danh sách thư mục trên NFS

Thư mục lseek hiện kiểm tra các tham số thích hợp

Đã sửa lỗi tình trạng chủng tộc trong mã đệm - nó có trong tất cả các hệ thống tệp trong Linux;
       khi đọc thiết bị (cat /dev/hda) trong khi tạo tập tin trên đó, tập tin
       có thể bị hư hỏng
2.02 Giải pháp cho lỗi breada trong Linux. breada có thể gây ra sự truy cập vượt quá
       kết thúc phân vùng
2.03 Char, thiết bị khối và đường ống được tạo chính xác

Đã sửa lỗi cuộc đua không gặp sự cố khi hủy liên kết (Alexander Viro)

Bây giờ nó hoạt động với phiên bản OS/2 của Nhật Bản
2.04 Đã sửa lỗi khi sử dụng ftruncate để mở rộng tệp
2.05 Đã sửa lỗi sự cố khi có tham số gắn kết không có =

Đã khắc phục sự cố khi phân bổ cực dương không thành công do đĩa đầy

Đã khắc phục một số sự cố khi phân bổ khối io hoặc inode không thành công
2.06 Đã khắc phục một số sự cố trên cấu trúc đĩa bị hỏng

Chiến lược phân bổ tốt hơn

Đã thêm lịch lại các điểm để không bị khóa CPU trong thời gian dài

Nó sẽ hoạt động ở chế độ chỉ đọc trên Warp Server
2.07 Nhiều bản sửa lỗi hơn cho Warp Server. Bây giờ nó thực sự hoạt động
2.08 Tạo tệp mới không quá chậm trên đĩa lớn

Nỗ lực đồng bộ hóa tệp đã xóa không tạo ra lỗi hệ thống tệp
2.09 Đã sửa lỗi trên các tệp bị phân mảnh quá mức
====== ===============================================================================