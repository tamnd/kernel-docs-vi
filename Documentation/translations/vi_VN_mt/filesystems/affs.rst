.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/affs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Tổng quan về hệ thống tập tin Amiga
===================================

Không phải tất cả các loại hệ thống tập tin Amiga đều được hỗ trợ để đọc và
viết. Amiga hiện biết sáu hệ thống tập tin khác nhau:

===================================================================================
DOS\0 Hệ thống tập tin cũ hoặc gốc, không thực sự phù hợp với
		đĩa cứng và thường không được sử dụng trên chúng.
		Hỗ trợ đọc/ghi.

DOS\1 Hệ thống tệp nhanh ban đầu. Hỗ trợ đọc/ghi.

DOS\2 Hệ thống tập tin "quốc tế" cũ. Quốc tế có nghĩa là
		một lỗi đã được sửa để các chữ cái có dấu ("quốc tế")
		trong tên tệp không phân biệt chữ hoa chữ thường.
		Hỗ trợ đọc/ghi.

DOS\3 Hệ thống tệp nhanh "quốc tế".  Hỗ trợ đọc/ghi.

DOS\4 Hệ thống tập tin gốc có bộ đệm thư mục. Thư mục
		bộ đệm tăng tốc đáng kể việc truy cập thư mục trên đĩa mềm,
		nhưng làm chậm quá trình tạo/xóa tập tin. Không kiếm được nhiều
		ý nghĩa trên đĩa cứng. Hỗ trợ chỉ đọc.

DOS\5 Hệ thống tệp nhanh với bộ đệm thư mục. Hỗ trợ chỉ đọc.
===================================================================================

Tất cả các hệ thống tệp trên cho phép kích thước khối từ 512 đến 32K byte.
Kích thước khối được hỗ trợ là: 512, 1024, 2048 và 4096 byte. Khối lớn hơn
tăng tốc hầu hết mọi thứ nhưng lại gây lãng phí dung lượng ổ đĩa. tốc độ
đạt được trên 4K dường như không thực sự đáng giá, vì vậy bạn cũng không bị mất
ở đây cũng có nhiều.

Tương đương muFS (Hệ thống tệp đa người dùng) của các hệ thống tệp trên
cũng được hỗ trợ.

Tùy chọn gắn kết cho AFFS
==========================

bảo vệ
		Nếu tùy chọn này được đặt, các bit bảo vệ không thể thay đổi được.

setuid[=uid]
		Điều này đặt chủ sở hữu của tất cả các tệp và thư mục trong tệp
		system thành uid hoặc uid của người dùng hiện tại tương ứng.

setgid[=gid]
		Tương tự như trên, nhưng đối với gi.

chế độ=chế độ
		Đặt cờ chế độ thành giá trị (bát phân) đã cho, bất kể
		của các quyền ban đầu. Thư mục sẽ nhận được một x
		quyền nếu bit r tương ứng được đặt.
		Điều này rất hữu ích vì hầu hết các tệp AmigaOS đơn giản đều
		sẽ ánh xạ tới 600.

nofilenamecắt ngắn
		Hệ thống tập tin sẽ trả về lỗi khi tên tập tin vượt quá
		độ dài tên tệp tối đa tiêu chuẩn (30 ký tự).

dành riêng=num
		Đặt số khối dành riêng khi bắt đầu
		phân vùng thành num. Bạn không bao giờ cần đến tùy chọn này.
		Mặc định là 2.

gốc=khối
		Đặt số khối của khối gốc. Điều này không bao giờ nên
		cần thiết.

bs=blksize
		Đặt kích thước khối thành blksize. Kích thước khối hợp lệ là 512,
		1024, 2048 và 4096. Giống như tùy chọn gốc, tùy chọn này sẽ
		không bao giờ cần thiết, vì aff có thể tự tìm ra.

yên tĩnh
		Hệ thống tập tin sẽ không trả về lỗi không được phép
		thay đổi chế độ.

dài dòng
		Tên ổ đĩa, loại hệ thống tệp và kích thước khối sẽ
		được ghi vào nhật ký hệ thống khi hệ thống tập tin được gắn kết.

khăn che mặt
		Hệ thống tập tin thực sự là một muFS, nhưng nó không
		tự nhận mình là một. Tùy chọn này là cần thiết nếu
		hệ thống tập tin không được định dạng là muFS, nhưng được sử dụng
		như một.

tiền tố=đường dẫn
		Đường dẫn sẽ được đặt trước mỗi tên đường dẫn tuyệt đối của
		liên kết tượng trưng trên phân vùng AFFS. Mặc định = "/".
		(Xem bên dưới.)

âm lượng=tên
		Khi liên kết tượng trưng với đường dẫn tuyệt đối được tạo
		trên phân vùng AFFS, tên sẽ được thêm vào trước
		tên tập. Mặc định = "" (chuỗi trống).
		(Xem bên dưới.)

Xử lý Người dùng/Nhóm và cờ bảo vệ
=================================================

Amiga -> Linux:

Cờ bảo vệ Amiga RWEDRWEDHSPARWED được xử lý như sau:

- R ánh xạ tới r cho người dùng, nhóm và những người khác. Trên các thư mục, R ngụ ý x.

- W ánh xạ tới w.

- E ánh xạ tới x.

- D bị bỏ qua.

- H, S và P luôn được giữ lại và bỏ qua trong Linux.

- A bị xóa khi một tập tin được ghi vào.

Id người dùng và id nhóm sẽ được sử dụng trừ khi set[gu]id được cung cấp dưới dạng mount
tùy chọn. Vì hầu hết các hệ thống tệp Amiga là hệ thống người dùng đơn lẻ
chúng sẽ được sở hữu bởi root. Thư mục gốc (điểm gắn kết) của
Hệ thống tập tin Amiga sẽ được sở hữu bởi người dùng thực sự gắn kết
hệ thống tập tin (thư mục gốc không có trường uid/gid).

Linux -> Amiga:

Chế độ tệp rwxrwxrwx của Linux được xử lý như sau:

- Quyền r sẽ cho phép R cho người dùng, nhóm và những người khác.

- quyền w sẽ cho phép W đối với người dùng, nhóm và những người khác.

- Quyền x của người dùng sẽ cho phép E đối với các tệp đơn giản.

- D sẽ được phép cho người dùng, nhóm và những người khác.

- Tất cả các cờ khác (suid, sgid, ...) đều bị bỏ qua và sẽ
    không được giữ lại.

Các tệp và thư mục mới được tạo sẽ nhận được ID người dùng và nhóm
của người dùng hiện tại và một chế độ theo ô.

Liên kết tượng trưng
==============

Mặc dù hệ thống tập tin Amiga và Linux giống nhau nhưng vẫn có
có một số khác biệt, không phải lúc nào cũng tinh tế. Một trong số chúng trở nên rõ ràng
với các liên kết tượng trưng. Trong khi Linux có một hệ thống tập tin với chính xác một
thư mục gốc, Amiga có một thư mục gốc riêng cho mỗi
hệ thống tập tin (ví dụ: phân vùng, đĩa mềm,...). Với Amiga,
những thực thể này được gọi là "khối lượng". Chúng có những cái tên tượng trưng
có thể được sử dụng để truy cập chúng. Vì vậy, các liên kết tượng trưng có thể trỏ tới một
khối lượng khác nhau. AFFS biến tên ổ đĩa thành tên thư mục
và thêm đường dẫn tiền tố (xem tùy chọn tiền tố) vào nó.

Ví dụ:
Bạn gắn tất cả các phân vùng Amiga của mình vào /amiga/<volume> (trong đó
<volume> là tên của ổ đĩa) và bạn đưa ra tùy chọn
"prefix=/amiga/" khi gắn tất cả các phân vùng AFFS của bạn. (Họ
có thể là "Người dùng", "WB" và "Đồ họa", điểm gắn kết/amiga/Người dùng,
/amiga/WB và /amiga/Graphics). Một liên kết tượng trưng đề cập đến
"User:sc/include/dos/dos.h" sẽ được theo dõi tới
"/amiga/User/sc/include/dos/dos.h".

Ví dụ
========

Dòng lệnh::

mount Archive/Amiga/Workbench3.1.adf /mnt -t affs -o loop,verbose
    mount /dev/sda3 /Amiga -t affs

/etc/fstab mục::

/dev/sdb5 /amiga/Workbench affs noauto,user,exec,verbose 0 0

IMPORTANT NOTE
==============

Nếu bạn khởi động Windows 95 (không biết về 3.x, 98 và NT) trong khi bạn
có một ổ cứng Amiga được kết nối với PC của bạn, nó sẽ ghi đè lên
các byte 0x00dc..0x00df của khối 0 có rác, do đó làm mất hiệu lực
Khối đĩa cứng. May mắn thay, đây là một thứ chưa được sử dụng
diện tích của RDB, do đó chỉ có tổng kiểm tra không khớp nữa.
Linux sẽ bỏ qua rác này và nhận ra RDB, nhưng
trước khi kết nối lại ổ đĩa đó với Amiga, bạn phải
khôi phục hoặc sửa chữa RDB của bạn. Vì vậy vui lòng tạo một bản sao lưu của nó
trước khi khởi động Windows!

Nếu hư hỏng đã xảy ra, cách sau sẽ khắc phục RDB
(trong đó <disk> là tên thiết bị).

LÀM TẠI YOUR OWN RISK::

dd if=/dev/<disk> of=rdb.tmp count=1
  cp rdb.tmp rdb.fixed
  dd if=/dev/zero of=rdb.fixed bs=1 seek=220 count=4
  dd if=rdb.fixed of=/dev/<disk>

Lỗi, Hạn chế, Hãy cẩn thận
===========================

Khá nhiều thứ có thể không hoạt động như quảng cáo. Không phải mọi thứ đều như vậy
đã được thử nghiệm, mặc dù hàng trăm MB đã được đọc và ghi bằng cách sử dụng
fs này. Để có danh sách lỗi cập nhật nhất, vui lòng tham khảo
fs/affs/Thay đổi.

Theo mặc định, tên tệp bị cắt ngắn còn 30 ký tự mà không có cảnh báo.
Tùy chọn gắn kết 'nofilenametruncate' có thể thay đổi hành vi đó.

Trường hợp này bị bỏ qua bởi các aff trong việc khớp tên tệp, nhưng hệ vỏ Linux
quan tâm đến vụ việc. Ví dụ (với /wb là một fs được gắn aff)::

rm /wb/WRONGCASE

sẽ xóa/mnt/chữ hoa sai, nhưng::

rm /wb/WR*

sẽ không vì tên được khớp với Shell.

Việc phân bổ khối được thiết kế cho các phân vùng đĩa cứng. Nếu nhiều hơn
hơn 1 tiến trình ghi vào đĩa (nhỏ), các khối được phân bổ
theo một cách xấu xí (nhưng AFFS thật cũng không làm tốt hơn là bao). Cái này
cũng đúng khi không gian trở nên chật hẹp.

Bạn không thể thực thi các chương trình trên OFS (Hệ thống tệp cũ), vì
các tệp chương trình không thể được ánh xạ bộ nhớ do các khối 488 byte.
Vì lý do tương tự, bạn không thể gắn hình ảnh vào hệ thống tập tin như vậy
thông qua thiết bị loopback.

Cờ hợp lệ bitmap trong khối gốc có thể không chính xác khi
hệ thống gặp sự cố trong khi phân vùng affs được gắn kết. Hiện tại có
không có cách nào để sửa hệ thống tập tin bị cắt xén nếu không có Amiga (trình xác thực đĩa)
hoặc thủ công (ai sẽ làm việc này?). Có lẽ sau này.

Nếu bạn gắn kết các phân vùng affs khi khởi động hệ thống, bạn có thể muốn thông báo
fsck rằng không nên kiểm tra fs (đặt '0' vào trường thứ sáu
của /etc/fstab).

Không thể đọc đĩa mềm bằng PC hoặc máy trạm thông thường
do không tương thích với bộ điều khiển đĩa mềm Amiga.

Nếu bạn quan tâm đến Trình giả lập Amiga cho Linux, hãy xem

ZZ0000ZZ