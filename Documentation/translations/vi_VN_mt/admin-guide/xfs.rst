.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/xfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Hệ thống tập tin SGI XFS
======================

XFS là một hệ thống tệp nhật ký hiệu suất cao có nguồn gốc từ
trên nền tảng SGI IRIX.  Nó hoàn toàn đa luồng, có thể
hỗ trợ các tệp lớn và hệ thống tệp lớn, các thuộc tính mở rộng,
kích thước khối thay đổi, dựa trên phạm vi và sử dụng rộng rãi
Btrees (thư mục, phạm vi, không gian trống) để hỗ trợ cả hiệu suất
và khả năng mở rộng.

Tham khảo tài liệu tại ZZ0000ZZ
để biết thêm chi tiết.  Việc triển khai này tương thích trên đĩa
với phiên bản IRIX của XFS.


Tùy chọn gắn kết
=============

Khi gắn hệ thống tệp XFS, các tùy chọn sau được chấp nhận.

phân bổ=kích thước
	Đặt kích thước phân bổ trước phần cuối tệp I/O được đệm khi
	thực hiện ghi phân bổ bị trì hoãn (kích thước mặc định là 64KiB).
	Giá trị hợp lệ cho tùy chọn này là kích thước trang (thường là 4KiB)
	cho đến 1GiB, bao gồm, với mức tăng lũy thừa 2.

Hành vi mặc định dành cho phần cuối tập tin động
	kích thước phân bổ trước, sử dụng một tập hợp các phương pháp phỏng đoán để
	tối ưu hóa kích thước phân bổ trước dựa trên hiện tại
	các mẫu phân bổ trong tệp và các mẫu truy cập
	vào tập tin. Chỉ định giá trị ZZ0000ZZ cố định sẽ tắt
	hành vi năng động.

loại bỏ hoặc không loại bỏ (mặc định)
	Bật/tắt việc phát lệnh để chặn
	thiết bị lấy lại không gian được giải phóng bởi hệ thống tập tin.  Đây là
	hữu ích cho các thiết bị SSD, LUN được cung cấp mỏng và ảo
	hình ảnh máy, nhưng có thể có tác động đến hiệu suất.

Lưu ý: Hiện tại bạn nên sử dụng ZZ0000ZZ
	ứng dụng cho các khối không sử dụng ZZ0001ZZ thay vì ZZ0002ZZ
	tùy chọn gắn kết vì tác động hiệu suất của tùy chọn này
	là khá nghiêm trọng.

grpid/bsdgroups hoặc nogrpid/sysvgroups (mặc định)
	Các tùy chọn này xác định ID nhóm nào của tệp mới được tạo
	được.  Khi ZZ0000ZZ được đặt, nó sẽ lấy ID nhóm của
	thư mục nơi nó được tạo; nếu không thì phải mất
	ZZ0001ZZ của quy trình hiện tại, trừ khi thư mục có
	Tập bit ZZ0002ZZ, trong trường hợp đó nó lấy ZZ0003ZZ từ
	thư mục mẹ và cũng nhận được bit ZZ0004ZZ nếu có
	một thư mục chính nó.

dòng tập tin
	Làm cho bộ cấp phát dữ liệu sử dụng chế độ phân bổ dòng tệp
	trên toàn bộ hệ thống tập tin thay vì chỉ trên các thư mục
	cấu hình để sử dụng nó.

inode32 hoặc inode64 (mặc định)
	Khi ZZ0000ZZ được chỉ định, nó cho biết giới hạn của XFS
	tạo inode đến các vị trí sẽ không tạo ra inode
	số có ý nghĩa lớn hơn 32 bit.

Khi ZZ0000ZZ được chỉ định, nó cho biết XFS được phép
	để tạo các nút ở bất kỳ vị trí nào trong hệ thống tập tin,
	bao gồm cả những thứ sẽ dẫn đến việc chiếm số lượng inode
	hơn 32 bit có ý nghĩa.

ZZ0000ZZ được cung cấp để tương thích ngược với phiên bản cũ hơn
	hệ thống và ứng dụng, vì số inode 64 bit có thể
	gây ra sự cố cho một số ứng dụng không thể xử lý
	số inode lớn.  Nếu các ứng dụng đang được sử dụng
	không xử lý số inode lớn hơn 32 bit, ZZ0001ZZ
	tùy chọn nên được chỉ định.

bigio hoặc nolargeio (mặc định)
	Nếu ZZ0000ZZ được chỉ định, I/O tối ưu được báo cáo trong
	ZZ0001ZZ của ZZ0002ZZ sẽ nhỏ nhất có thể để cho phép
	ứng dụng của người dùng để tránh việc đọc/sửa đổi/ghi không hiệu quả
	Tôi/O.  Đây thường là kích thước trang của máy, vì
	đây là mức độ chi tiết của bộ đệm trang.

Nếu ZZ0000ZZ được chỉ định, hệ thống tệp được tạo bằng
	ZZ0001ZZ được chỉ định sẽ trả về giá trị ZZ0002ZZ (tính bằng byte)
	trong ZZ0003ZZ. Nếu hệ thống tập tin không có ZZ0004ZZ
	được chỉ định nhưng lại chỉ định ZZ0005ZZ rồi ZZ0006ZZ
	(tính bằng byte) sẽ được trả về thay thế. Nếu không thì hành vi
	giống như khi ZZ0007ZZ được chỉ định.

logbufs=giá trị
	Đặt số lượng bộ đệm nhật ký trong bộ nhớ.  Số hợp lệ
	bao gồm từ 2-8.

Giá trị mặc định là 8 bộ đệm.

Nếu chi phí bộ nhớ của 8 bộ đệm nhật ký quá cao trên thiết bị nhỏ
	hệ thống, sau đó nó có thể được giảm bớt với một số chi phí về hiệu suất
	về khối lượng công việc chuyên sâu về siêu dữ liệu. Tùy chọn ZZ0000ZZ bên dưới
	kiểm soát kích thước của mỗi bộ đệm và do đó cũng liên quan đến
	trường hợp này.

trọn đời (mặc định) hoặc không trọn đời
	Bật vị trí dữ liệu dựa trên gợi ý về thời gian ghi được cung cấp
	bởi người dùng. Điều này bật tính năng đồng phân bổ dữ liệu tương tự
	cuộc sống khi thống kê thuận lợi để giảm rác thải
	chi phí thu gom.

Các tùy chọn này chỉ khả dụng cho các hệ thống tệp rt được khoanh vùng.

logbsize=giá trị
	Đặt kích thước của từng bộ đệm nhật ký trong bộ nhớ.  Kích thước có thể là
	được chỉ định bằng byte hoặc tính bằng kilobyte với hậu tố "k".
	Kích thước hợp lệ cho nhật ký phiên bản 1 và phiên bản 2 là 16384 (16k)
	và 32768 (32k).  Kích thước hợp lệ cho nhật ký phiên bản 2 cũng
	bao gồm 65536 (64k), 131072 (128k) và 262144 (256k). các
	logbsize phải là bội số nguyên của nhật ký
	đơn vị sọc được định cấu hình tại thời điểm ZZ0000ZZ.

Giá trị mặc định cho nhật ký phiên bản 1 là 32768, trong khi
	giá trị mặc định cho nhật ký phiên bản 2 là MAX(32768, log_sunit).

logdev=thiết bị và rtdev=thiết bị
	Sử dụng nhật ký bên ngoài (nhật ký siêu dữ liệu) và/hoặc thiết bị thời gian thực.
	Hệ thống tệp XFS có tối đa ba phần: phần dữ liệu, phần nhật ký
	phần và một phần thời gian thực.  Phần thời gian thực là
	tùy chọn và phần nhật ký có thể tách biệt khỏi dữ liệu
	phần hoặc chứa trong đó.

max_atomic_write=giá trị
	Đặt kích thước tối đa của một lần ghi nguyên tử.  Kích thước có thể là
	được chỉ định bằng byte, tính bằng kilobyte với hậu tố "k", tính bằng megabyte
	có hậu tố "m" hoặc tính bằng gigabyte với hậu tố "g".  Kích thước
	không thể lớn hơn kích thước ghi tối đa, lớn hơn kích thước
	kích thước của bất kỳ nhóm phân bổ nào hoặc lớn hơn kích thước của một
	hoạt động ánh xạ lại mà nhật ký có thể hoàn thành một cách nguyên tử.

Giá trị mặc định là đặt kích thước hoàn thành I/O tối đa
	để cho phép mỗi CPU xử lý từng cái một.

max_open_zones=giá trị
	Chỉ định số vùng tối đa để tiếp tục mở để viết trên một
	thiết bị rt được khoanh vùng. Nhiều vùng mở hỗ trợ phân tách dữ liệu tệp
	nhưng có thể ảnh hưởng đến hiệu suất trên ổ cứng.

Nếu ZZ0000ZZ không được chỉ định, giá trị được xác định
	bởi khả năng và kích thước của thiết bị rt được khoanh vùng.

không căn chỉnh
	Phân bổ dữ liệu sẽ không được căn chỉnh theo đơn vị sọc
	ranh giới. Điều này chỉ liên quan đến các hệ thống tập tin được tạo
	với các tham số căn chỉnh dữ liệu khác 0 (ZZ0000ZZ, ZZ0001ZZ) bởi
	ZZ0002ZZ.

không hồi phục
	Hệ thống tập tin sẽ được gắn kết mà không cần chạy khôi phục nhật ký.
	Nếu hệ thống tập tin không được ngắt kết nối hoàn toàn, có thể nó sẽ
	không nhất quán khi được gắn ở chế độ ZZ0000ZZ.
	Một số tập tin hoặc thư mục có thể không truy cập được vì điều này.
	Hệ thống tập tin được gắn ZZ0001ZZ phải được gắn ở chế độ chỉ đọc hoặc
	việc gắn kết sẽ thất bại.

nouuid
	Đừng kiểm tra hệ thống tệp được gắn kép bằng tệp
	hệ thống ZZ0000ZZ.  Điều này rất hữu ích để gắn các khối ảnh chụp nhanh LVM,
	và thường được sử dụng kết hợp với ZZ0001ZZ để gắn
	ảnh chụp nhanh chỉ đọc.

không có hạn ngạch
	Buộc tắt tất cả tính toán và thực thi hạn ngạch
	trong hệ thống tập tin.

hạn ngạch/usrquota/uqnoenforce/hạn ngạch
	Đã bật tính toán hạn ngạch đĩa người dùng và giới hạn (tùy chọn)
	thi hành.  Tham khảo ZZ0000ZZ để biết thêm chi tiết.

gquota/grpquota/gqnoenforce
	Đã bật và giới hạn tính toán hạn ngạch đĩa nhóm (tùy chọn)
	thi hành.  Tham khảo ZZ0000ZZ để biết thêm chi tiết.

pquota/prjquota/pqnoenforce
	Đã bật và giới hạn tính toán hạn ngạch đĩa dự án (tùy chọn)
	thi hành.  Tham khảo ZZ0000ZZ để biết thêm chi tiết.

sunit=value và swidth=value
	Được sử dụng để chỉ định đơn vị sọc và chiều rộng cho thiết bị RAID
	hoặc một tập sọc.  "giá trị" phải được chỉ định bằng 512 byte
	các đơn vị khối. Các tùy chọn này chỉ liên quan đến hệ thống tập tin
	được tạo bằng các tham số căn chỉnh dữ liệu khác 0.

Các tham số ZZ0000ZZ và ZZ0001ZZ được chỉ định phải tương thích
	với các đặc điểm căn chỉnh hệ thống tập tin hiện có.  trong
	nói chung, điều đó có nghĩa là những thay đổi hợp lệ duy nhất đối với ZZ0002ZZ là
	tăng nó lên bội số của 2. Giá trị ZZ0003ZZ hợp lệ
	là bội số nguyên bất kỳ của giá trị ZZ0004ZZ hợp lệ.

Thông thường, lần duy nhất các tùy chọn gắn kết này là cần thiết nếu
	sau khi thiết bị RAID cơ bản đã có hình dạng của nó
	đã sửa đổi, chẳng hạn như thêm đĩa mới vào lun RAID5 và
	định hình lại nó.

chim nhạn
	Phân bổ dữ liệu sẽ được làm tròn đến ranh giới chiều rộng sọc
	khi phần cuối hiện tại của tệp đang được mở rộng và tệp
	kích thước lớn hơn kích thước chiều rộng sọc.

không đồng bộ
	Khi được chỉ định, tất cả các hoạt động không gian tên của hệ thống tập tin đều được
	được thực hiện đồng bộ. Điều này đảm bảo rằng khi không gian tên
	thao tác (tạo, hủy liên kết, v.v.) hoàn tất, thay đổi đối với
	không gian tên được lưu trữ ổn định. Điều này hữu ích trong việc thiết lập HA
	nơi chuyển đổi dự phòng không được dẫn đến việc khách hàng nhìn thấy
	cách trình bày không gian tên không nhất quán trong hoặc sau một
	sự kiện chuyển đổi dự phòng.

thẻ lỗi=tên thẻ
	Khi được chỉ định, hãy bật thẻ chèn lỗi có tên "tagname" với
	tần số mặc định.  Có thể được chỉ định nhiều lần để kích hoạt nhiều
	thẻ lỗi.  Việc chỉ định tùy chọn này khi gắn lại sẽ đặt lại thẻ lỗi
	về giá trị mặc định nếu nó được đặt thành bất kỳ giá trị nào khác trước đó.
	Tùy chọn này chỉ được hỗ trợ khi CONFIG_XFS_DEBUG được bật và
	sẽ không được phản ánh trong /proc/self/mounts.

Ngừng sử dụng định dạng V4
========================

Định dạng hệ thống tập tin V4 thiếu một số tính năng nhất định được hỗ trợ bởi
định dạng V5, chẳng hạn như kiểm tra tổng hợp siêu dữ liệu, siêu dữ liệu được tăng cường
xác minh và khả năng lưu trữ dấu thời gian trong năm 2038.
Vì điều này, định dạng V4 không được dùng nữa.  Tất cả người dùng nên nâng cấp
bằng cách sao lưu các tập tin của họ, định dạng lại và khôi phục từ bản sao lưu.

Quản trị viên và người dùng có thể phát hiện hệ thống tệp V4 bằng cách chạy xfs_info
dựa vào điểm gắn kết hệ thống tập tin và kiểm tra chuỗi chứa
"crc=".  Nếu không tìm thấy chuỗi như vậy, vui lòng nâng cấp xfsprogs lên
phiên bản mới nhất và thử lại.

Việc ngừng sử dụng sẽ diễn ra trong hai phần.  Hỗ trợ gắn V4
hệ thống tập tin bây giờ có thể bị vô hiệu hóa tại thời điểm xây dựng kernel thông qua tùy chọn Kconfig.
Các tùy chọn này đã được thay đổi thành mặc định thành không vào tháng 9 năm 2025. Trong
Kể từ tháng 9 năm 2030, hỗ trợ sẽ bị xóa hoàn toàn khỏi cơ sở mã.

Lưu ý: Nhà phân phối có thể chọn ngừng hỗ trợ định dạng V4 sớm hơn
những ngày được liệt kê ở trên.

Tùy chọn gắn kết không được dùng nữa
========================

================================================
  Lịch xóa tên
================================================
Gắn kết với hệ thống tập tin V4 Tháng 9 năm 2030
Gắn hệ thống tập tin ascii-ci tháng 9 năm 2030
================================================


Tùy chọn gắn kết đã xóa
=====================

=====================================
  Đã xóa tên
=====================================
  nhật ký trễ/nodelaylog v4.0
  ihashsize v4.0
  irixsgid v4.0
  osyncisdsync/osyncisosync v4.0
  rào cản v4.19
  không có rào cản v4.19
  ikeep/noikeep v6.18
  attr2/noattr2 v6.18
=====================================

hệ thống
=======

Các hệ thống sau có sẵn cho hệ thống tệp XFS:

fs.xfs.stats_clear (Tối thiểu: 0 Mặc định: 0 Tối đa: 1)
	Đặt giá trị này thành "1" sẽ xóa số liệu thống kê XFS tích lũy
	trong /proc/fs/xfs/stat.  Sau đó nó ngay lập tức đặt lại về "0".

fs.xfs.xfssyncd_centisecs (Tối thiểu: 100 Mặc định: 3000 Tối đa: 720000)
	Khoảng thời gian mà hệ thống tập tin xóa siêu dữ liệu
	ra đĩa và chạy các chương trình dọn dẹp bộ nhớ đệm nội bộ.

fs.xfs.filestream_centisecs (Tối thiểu: 1 Mặc định: 3000 Tối đa: 360000)
	Khoảng thời gian mà hệ thống tập tin lưu giữ bộ nhớ đệm của dòng tập tin
	tham chiếu và trả AG đã hết thời gian chờ trở lại luồng miễn phí
	bể bơi.

fs.xfs.speculative_prealloc_lifetime
	(Đơn vị: giây Tối thiểu: 1 Mặc định: 300 Tối đa: 86400)
	Khoảng thời gian quét nền cho các nút
	với các lần chạy phân bổ đầu cơ chưa được sử dụng. Quá trình quét
	loại bỏ việc phân bổ trước không được sử dụng khỏi các nút và bản phát hành sạch
	không gian chưa sử dụng trở lại hồ bơi miễn phí.

fs.xfs.error_level (Tối thiểu: 0 Mặc định: 3 Tối đa: 11)
	Núm âm lượng để báo lỗi khi xảy ra lỗi nội bộ.
	Điều này sẽ tạo ra các thông báo và dấu vết ngược chi tiết cho hệ thống tập tin
	tắt máy chẳng hạn.  Giá trị ngưỡng hiện tại là:

XFS_ERRLEVEL_OFF: 0
		XFS_ERRLEVEL_LOW: 1
		XFS_ERRLEVEL_HIGH: 5

fs.xfs.panic_mask (Tối thiểu: 0 Mặc định: 0 Tối đa: 511)
	Gây ra một số điều kiện lỗi nhất định để gọi BUG(). Giá trị là một mặt nạ bit;
	HOẶC các thẻ đại diện cho lỗi có thể gây hoảng loạn:

XFS_NO_PTAG 0
		XFS_PTAG_IFLUSH 0x00000001
		XFS_PTAG_LOGRES 0x00000002
		XFS_PTAG_AILDELETE 0x00000004
		XFS_PTAG_ERROR_REPORT 0x00000008
		XFS_PTAG_SHUTDOWN_CORRUPT 0x00000010
		XFS_PTAG_SHUTDOWN_IOERROR 0x00000020
		XFS_PTAG_SHUTDOWN_LOGERROR 0x00000040
		XFS_PTAG_FSBLOCK_ZERO 0x00000080
		XFS_PTAG_VERIFIER_ERROR 0x00000100

Tùy chọn này chỉ nhằm mục đích gỡ lỗi.

fs.xfs.inherit_sync (Tối thiểu: 0 Mặc định: 1 Tối đa: 1)
	Đặt giá trị này thành "1" sẽ khiến cờ "đồng bộ hóa" được đặt
	bằng lệnh chattr ZZ0000ZZ trên thư mục cần
	được kế thừa bởi các tập tin trong thư mục đó.

fs.xfs.inherit_nodump (Tối thiểu: 0 Mặc định: 1 Tối đa: 1)
	Đặt giá trị này thành "1" sẽ khiến cờ "nodump" được đặt
	bằng lệnh chattr ZZ0000ZZ trên thư mục cần
	được kế thừa bởi các tập tin trong thư mục đó.

fs.xfs.inherit_noatime (Tối thiểu: 0 Mặc định: 1 Tối đa: 1)
	Đặt giá trị này thành "1" sẽ khiến cờ "noatime" được đặt
	bằng lệnh chattr ZZ0000ZZ trên thư mục cần
	được kế thừa bởi các tập tin trong thư mục đó.

fs.xfs.inherit_nosymlinks (Tối thiểu: 0 Mặc định: 1 Tối đa: 1)
	Đặt giá trị này thành "1" sẽ khiến cờ "nosymlinks" được đặt
	bằng lệnh chattr ZZ0000ZZ trên thư mục cần
	được kế thừa bởi các tập tin trong thư mục đó.

fs.xfs.inherit_nodefrag (Tối thiểu: 0 Mặc định: 1 Tối đa: 1)
	Đặt giá trị này thành "1" sẽ khiến cờ "nodefrag" được đặt
	bằng lệnh chattr ZZ0000ZZ trên thư mục cần
	được kế thừa bởi các tập tin trong thư mục đó.

fs.xfs.rotorstep (Tối thiểu: 1 Mặc định: 1 Tối đa: 256)
	Trong chế độ phân bổ "inode32", tùy chọn này xác định có bao nhiêu
	tập tin mà người cấp phát cố gắng phân bổ trong cùng một lần phân bổ
	nhóm trước khi chuyển sang nhóm phân bổ tiếp theo.  Ý định
	là để kiểm soát tốc độ mà bộ cấp phát di chuyển giữa
	nhóm phân bổ khi phân bổ phạm vi cho các tệp mới.

Hệ thống không được dùng nữa
==================

Hiện tại không có.

Hệ thống đã xóa
===============

============================================= =======
  Đã xóa tên
============================================= =======
  fs.xfs.xfsbufd_centisec v4.0
  fs.xfs.age_buffer_centisecs v4.0
  fs.xfs.irix_symlink_mode v6.18
  fs.xfs.irix_sgid_inherit v6.18
  fs.xfs.speculative_cow_prealloc_lifetime v6.18
============================================= =======

Xử lý lỗi
==============

XFS có thể hoạt động khác nhau tùy theo loại lỗi được tìm thấy trong quá trình sử dụng.
hoạt động. Việc triển khai đưa ra các khái niệm sau về lỗi
xử lý:

-Tốc độ hư hỏng:
	Xác định tốc độ XFS sẽ truyền lỗi lên trên khi một lỗi cụ thể
	lỗi được tìm thấy trong quá trình hoạt động của hệ thống tập tin. Nó có thể truyền bá
	ngay lập tức, sau một số lần thử lại xác định, sau một khoảng thời gian đã định,
	hoặc đơn giản là thử lại mãi mãi.

-Các lớp lỗi:
	Chỉ định hệ thống con mà cấu hình lỗi sẽ áp dụng, chẳng hạn như
	siêu dữ liệu IO hoặc phân bổ bộ nhớ. Các hệ thống con khác nhau sẽ có
	các trình xử lý lỗi khác nhau mà hành vi có thể được cấu hình.

-trình xử lý lỗi:
	Xác định hành vi cho một lỗi cụ thể.

Hành vi của hệ thống tệp khi xảy ra lỗi có thể được đặt thông qua các tệp ZZ0000ZZ. Mỗi
trình xử lý lỗi hoạt động độc lập - điều kiện đầu tiên được trình xử lý lỗi đáp ứng
đối với một lớp cụ thể sẽ khiến lỗi được lan truyền thay vì đặt lại và
đã thử lại.

Hành động được hệ thống tập tin thực hiện khi lỗi lan truyền là ngữ cảnh
phụ thuộc - nó có thể gây tắt máy trong trường hợp xảy ra lỗi không thể khắc phục được,
nó có thể được báo cáo trở lại không gian người dùng hoặc thậm chí có thể bị bỏ qua vì
chúng tôi không thể báo cáo lỗi này hoặc bất cứ ai có thể hữu ích (ví dụ:
trong quá trình ngắt kết nối).

Các tập tin cấu hình được tổ chức thành hệ thống phân cấp sau đây cho mỗi
hệ thống tập tin được gắn kết:

/sys/fs/xfs/<dev>/error/<class>/<error>/

Ở đâu:
  <dev>
	Tên thiết bị ngắn của hệ thống tập tin được gắn kết. Đây là cùng một thiết bị
	tên hiển thị trong thông báo lỗi kernel XFS là "XFS(<dev>): ..."

<lớp>
	Hệ thống con mà cấu hình lỗi thuộc về. Kể từ 4.9, định nghĩa
	các lớp là:

- "siêu dữ liệu": áp dụng bộ đệm siêu dữ liệu ghi IO

<lỗi>
	Các cấu hình xử lý lỗi riêng lẻ.


Mỗi hệ thống tập tin có các tùy chọn cấu hình lỗi "toàn cầu" được xác định trong phần trên cùng của chúng.
thư mục cấp:

/sys/fs/xfs/<dev>/error/

failed_at_unmount (Tối thiểu: 0 Mặc định: 1 Tối đa: 1)
	Xác định hành vi lỗi hệ thống tập tin tại thời điểm ngắt kết nối.

Nếu được đặt thành giá trị 1, XFS sẽ ghi đè tất cả các cấu hình lỗi khác
	trong quá trình ngắt kết nối và thay thế chúng bằng đặc điểm "lỗi ngay lập tức".
	tức là không thử lại, không hết thời gian thử lại. Điều này sẽ luôn cho phép ngắt kết nối
	thành công khi có những lỗi dai dẳng hiện diện.

Nếu được đặt thành 0, hành vi thử lại đã định cấu hình sẽ tiếp tục cho đến khi tất cả
	số lần thử lại và/hoặc thời gian chờ đã hết. Điều này sẽ trì hoãn việc ngắt kết nối
	hoàn thành khi có lỗi dai dẳng và nó có thể ngăn cản việc
	hệ thống tập tin không bao giờ được ngắt kết nối hoàn toàn trong trường hợp "thử lại mãi mãi"
	các cấu hình xử lý.

Lưu ý: không có gì đảm bảo rằng failed_at_unmount có thể được đặt trong khi
	quá trình ngắt kết nối đang diễn ra. Có thể các mục ZZ0000ZZ là
	bị xóa bởi hệ thống tập tin đang ngắt kết nối trước khi xảy ra lỗi "thử lại mãi mãi"
	cấu hình trình xử lý khiến việc ngắt kết nối bị treo và do đó hệ thống tập tin
	phải được cấu hình phù hợp trước khi bắt đầu ngắt kết nối để ngăn chặn
	ngắt kết nối bị treo.

Mỗi hệ thống tập tin có các trình xử lý lớp lỗi cụ thể để xác định lỗi
hành vi lan truyền cho các lỗi cụ thể. Ngoài ra còn có lỗi "mặc định"
trình xử lý được xác định, xác định hành vi cho tất cả các lỗi không có
trình xử lý cụ thể được xác định. Trường hợp nhiều ràng buộc thử lại được định cấu hình cho
một lỗi duy nhất, cấu hình thử lại đầu tiên hết hạn sẽ gây ra lỗi
để được tuyên truyền. Các cấu hình xử lý được tìm thấy trong thư mục:

/sys/fs/xfs/<dev>/error/<class>/<error>/

max_retries (Tối thiểu: -1 Mặc định: Khác nhau Tối đa: INTMAX)
	Xác định số lần thử lại được phép của một lỗi cụ thể trước khi
	hệ thống tập tin sẽ truyền lỗi. Số lần thử lại cho một lần nhất định
	bối cảnh lỗi (ví dụ: bộ đệm siêu dữ liệu cụ thể) được đặt lại mỗi lần
	có một sự hoàn thành thành công của hoạt động.

Đặt giá trị thành "-1" sẽ khiến XFS thử lại mãi mãi cho việc này
	lỗi cụ thể.

Đặt giá trị thành "0" sẽ khiến XFS bị lỗi ngay lập tức khi
	lỗi cụ thể được báo cáo.

Đặt giá trị thành "N" (trong đó 0 < N < Max) sẽ khiến XFS thử lại
	thao tác "N" lần trước khi truyền lỗi.

retry_timeout_seconds (Tối thiểu: -1 Mặc định: Thay đổi tối đa: 1 ngày)
	Xác định lượng thời gian (tính bằng giây) mà hệ thống tập tin được
	được phép thử lại các hoạt động của nó khi có lỗi cụ thể
	được tìm thấy.

Đặt giá trị thành "-1" sẽ cho phép XFS thử lại mãi mãi cho việc này
	lỗi cụ thể.

Đặt giá trị thành "0" sẽ khiến XFS bị lỗi ngay lập tức khi
	lỗi cụ thể được báo cáo.

Đặt giá trị thành "N" (trong đó 0 < N < Max) sẽ cho phép XFS thử lại
	hoạt động trong tối đa "N" giây trước khi truyền lỗi.

ZZ0000ZZ Hành vi mặc định cho một trình xử lý lỗi cụ thể phụ thuộc vào cả hai
bối cảnh lớp và lỗi. Ví dụ: các giá trị mặc định cho
"siêu dữ liệu/ENODEV" là "0" thay vì "-1" để trình xử lý lỗi này mặc định
hành vi "thất bại ngay lập tức". Điều này được thực hiện vì ENODEV gây tử vong,
lỗi không thể phục hồi bất kể siêu dữ liệu IO được thử lại bao nhiêu lần.

Đồng thời hàng đợi công việc
=====================

XFS sử dụng hàng đợi công việc hạt nhân để song song hóa các quy trình cập nhật siêu dữ liệu.  Cái này
cho phép nó tận dụng phần cứng lưu trữ có thể phục vụ nhiều IO
hoạt động đồng thời.  Giao diện này hiển thị việc triển khai nội bộ
chi tiết về XFS và do đó rõ ràng không phải là một phần của bất kỳ không gian người dùng API/ABI nào
đảm bảo kernel có thể cung cấp không gian người dùng.  Đây là những đặc điểm không có giấy tờ của
việc triển khai hàng đợi công việc chung mà XFS sử dụng cho hoạt động đồng thời và chúng là
được cung cấp ở đây hoàn toàn cho mục đích chẩn đoán và điều chỉnh và có thể thay đổi bất kỳ lúc nào
thời gian trong tương lai.

Các nút điều khiển cho hàng đợi công việc của hệ thống tập tin được sắp xếp theo tác vụ hiện tại
và tên viết tắt của thiết bị dữ liệu.  Tất cả đều có thể được tìm thấy trong:

/sys/bus/workqueue/devices/${task}!${device}

================= ============
  Mô tả nhiệm vụ
================= ============
  xfs_iwalk-$pid Inode quét toàn bộ hệ thống tập tin. Hiện nay giới hạn ở
                  kiểm tra hạn ngạch thời gian gắn kết.
  xfs-gc Thu thập rác nền của không gian đĩa đã được
                  được phân bổ theo suy đoán ngoài EOF hoặc để sao chép theo giai đoạn trên
                  thao tác ghi.
================= ============

Ví dụ: các nút cho hàng công việc kiểm tra hạn ngạch cho /dev/nvme0n1 sẽ là
được tìm thấy trong /sys/bus/workqueue/devices/xfs_iwalk-1111!nvme0n1/.

Các nút bấm thú vị dành cho hàng công việc XFS như sau:

========================
  Mô tả núm
========================
  max_active Số lượng chủ đề nền tối đa có thể được bắt đầu
                 điều hành công việc.
  CPU cpumask mà các luồng được phép chạy trên đó.
  tốt Mức độ ưu tiên tương đối của việc lập kế hoạch cho các chủ đề.  Đây là những
                 các mức độ tốt đẹp tương tự có thể được áp dụng cho các quy trình không gian người dùng.
========================

Hệ thống tập tin được khoanh vùng
=================

Đối với các hệ thống tệp được khoanh vùng, các thuộc tính sau được hiển thị trong:

/sys/fs/xfs/<dev>/zoned/

max_open_zones (Tối thiểu: 1 Mặc định: Khác nhau Tối đa: UINTMAX)
	Thuộc tính chỉ đọc này hiển thị số lượng vùng mở tối đa
	có sẵn để sắp xếp dữ liệu. Giá trị được xác định tại thời điểm gắn kết và
	bị giới hạn bởi khả năng của thiết bị được khoanh vùng sao lưu, hệ thống tệp
	size và tùy chọn gắn kết max_open_zones.

nr_open_zones (Tối thiểu: 0 Mặc định: Khác nhau Tối đa: UINTMAX)
	Thuộc tính chỉ đọc này hiển thị số vùng mở hiện tại
	được sử dụng bởi hệ thống tập tin.

Zonegc_low_space (Tối thiểu: 0 Mặc định: 0 Tối đa: 100)
	Xác định tỷ lệ phần trăm cho lượng không gian chưa sử dụng mà GC nên giữ
	có sẵn để viết. Giá trị cao sẽ lấy lại nhiều không gian hơn
	bị chiếm giữ bởi các khối không sử dụng, tạo ra bộ đệm lớn hơn chống ghi
	bùng nổ với chi phí khuếch đại ghi tăng lên.  Bất kể
	Với giá trị này, việc thu gom rác sẽ luôn hướng tới việc giải phóng tối thiểu
	số lượng khối để giữ max_open_zones mở cho mục đích sắp xếp dữ liệu.