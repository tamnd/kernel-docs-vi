.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/nilfs2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======
NILFS2
======

NILFS2 là một hệ thống tệp có cấu trúc nhật ký (LFS) hỗ trợ liên tục
chụp ảnh nhanh.  Ngoài khả năng phiên bản của toàn bộ tập tin
hệ thống, người dùng thậm chí có thể khôi phục các tập tin bị ghi đè nhầm hoặc
bị phá hủy chỉ vài giây trước.  Vì NILFS2 có thể giữ được tính nhất quán
giống như LFS thông thường, nó đạt được khả năng phục hồi nhanh chóng sau hệ thống
gặp sự cố.

NILFS2 tạo ra một số điểm kiểm tra cứ sau vài giây hoặc mỗi lần
cơ sở ghi đồng bộ (trừ khi không có thay đổi).  Người dùng có thể chọn
các phiên bản quan trọng giữa các điểm kiểm tra được tạo liên tục và có thể
thay đổi chúng thành ảnh chụp nhanh sẽ được giữ nguyên cho đến khi chúng
đổi lại thành điểm kiểm tra.

Không có giới hạn về số lượng ảnh chụp nhanh cho đến khi âm lượng đạt được
đầy đủ.  Mỗi ảnh chụp nhanh có thể được gắn kết dưới dạng hệ thống tệp chỉ đọc
đồng thời với giá đỡ có thể ghi của nó và tính năng này rất thuận tiện
để sao lưu trực tuyến.

Các công cụ vùng người dùng được bao gồm trong gói nilfs-utils,
có sẵn từ trang tải xuống sau đây.  Ít nhất là "mkfs.nilfs2",
"mount.nilfs2", "umount.nilfs2" và "nilfs_cleanerd" (còn gọi là
người dọn dẹp hoặc người thu gom rác) là bắt buộc.  Thông tin chi tiết về các công cụ được
được mô tả trong các trang man có trong gói.

:Trang web dự án: ZZ0000ZZ
:Trang tải xuống: ZZ0001ZZ
:Thông tin danh sách: ZZ0002ZZ

Hãy cẩn thận
=======

Các tính năng mà NILFS2 chưa hỗ trợ:

- một lúc
	- thuộc tính mở rộng
	- ACL POSIX
	- hạn ngạch
	- fsck
	- chống phân mảnh

Tùy chọn gắn kết
=============

NILFS2 hỗ trợ các tùy chọn gắn kết sau:
(*) == mặc định

====================================================================================
rào cản(*) Điều này cho phép/vô hiệu hóa việc sử dụng các rào cản ghi.  Cái này
nobarrier yêu cầu ngăn xếp IO có thể hỗ trợ các rào cản và
			nếu nilfs gặp lỗi khi viết rào cản, nó sẽ
			vô hiệu hóa một lần nữa với một cảnh báo.
error=continue Tiếp tục xảy ra lỗi hệ thống tập tin.
error=remount-ro(*) Gắn lại hệ thống tập tin chỉ đọc khi có lỗi.
error=panic Hoảng loạn và dừng máy nếu xảy ra lỗi.
cp=n Chỉ định số điểm kiểm tra của ảnh chụp nhanh
			gắn kết.  Điểm kiểm tra và ảnh chụp nhanh được liệt kê bởi lscp
			lệnh của người dùng.  Chỉ các điểm kiểm tra được đánh dấu là ảnh chụp nhanh
			có thể gắn kết với tùy chọn này.  Ảnh chụp nhanh ở chế độ chỉ đọc,
			vì vậy tùy chọn gắn kết chỉ đọc phải được chỉ định cùng nhau.
order=relaxed(*) Áp dụng ngữ nghĩa thứ tự thoải mái cho phép sửa đổi dữ liệu
			các khối được ghi vào đĩa mà không cần tạo một
			điểm kiểm tra nếu không có cập nhật siêu dữ liệu.  Chế độ này
			tương đương với chế độ dữ liệu có thứ tự của ext3
			hệ thống tập tin ngoại trừ các bản cập nhật trên khối dữ liệu vẫn
			bảo toàn tính nguyên tử.  Điều này sẽ cải thiện tính đồng bộ
			ghi hiệu suất để ghi đè.
order=strict Áp dụng ngữ nghĩa theo thứ tự nghiêm ngặt để duy trì trình tự
			của tất cả các hoạt động tập tin bao gồm ghi đè dữ liệu
			khối.  Điều đó có nghĩa là đảm bảo rằng không
			vượt qua các sự kiện xảy ra trong tập tin được khôi phục
			hệ thống sau sự cố.
norecovery Vô hiệu hóa việc khôi phục hệ thống tập tin khi gắn kết.
			Điều này vô hiệu hóa mọi quyền truy cập ghi trên thiết bị cho
			gắn kết hoặc ảnh chụp nhanh chỉ đọc.  Tùy chọn này sẽ thất bại
			để gắn kết r/w trên một ổ đĩa không sạch.
loại bỏ Điều này cho phép/vô hiệu hóa việc sử dụng các lệnh loại bỏ/TRIM.
nodiscard(*) Các lệnh loại bỏ/TRIM được gửi đến cơ sở
			chặn thiết bị khi các khối được giải phóng.  Điều này rất hữu ích
			dành cho các thiết bị SSD và LUN được cung cấp thưa thớt/cung cấp mỏng.
====================================================================================

Ioctl
======

Có một số chức năng cụ thể của NILFS2 mà các ứng dụng có thể truy cập
thông qua các giao diện cuộc gọi hệ thống. Danh sách tất cả các ioctls cụ thể của NILFS2 là
thể hiện trong bảng dưới đây.

Bảng ioctls cụ thể của NILFS2:

===================================================================================
 Mô tả Ioctl
 ===================================================================================
 NILFS_IOCTL_CHANGE_CPMODE Thay đổi chế độ của điểm kiểm tra đã cho giữa
			        trạng thái điểm kiểm tra và ảnh chụp nhanh. Ioctl này là
			        được sử dụng trong các tiện ích chcp và mkcp.

NILFS_IOCTL_DELETE_CHECKPOINT Xóa điểm kiểm tra khỏi hệ thống tệp NILFS2.
			        Ioctl này được sử dụng trong tiện ích rmcp.

NILFS_IOCTL_GET_CPINFO Trả về thông tin về các điểm kiểm tra được yêu cầu. Cái này
			        ioctl được sử dụng trong tiện ích lscp và bởi
			        daemon nilfs_cleanerd.

NILFS_IOCTL_GET_CPSTAT Trả về số liệu thống kê điểm kiểm tra. Ioctl này là
			        được sử dụng bởi các tiện ích lscp, rmcp và bởi
			        daemon nilfs_cleanerd.

NILFS_IOCTL_GET_SUINFO Trả về thông tin sử dụng phân đoạn về yêu cầu
			        phân đoạn. Ioctl này được sử dụng trong lssu,
			        tiện ích nilfs_resize và bởi nilfs_cleanerd
			        daemon.

NILFS_IOCTL_SET_SUINFO Sửa đổi thông tin sử dụng phân đoạn được yêu cầu
				phân đoạn. Ioctl này được sử dụng bởi
				daemon nilfs_cleanerd để bỏ qua không cần thiết
				hoạt động làm sạch các phân đoạn và giảm
				phạt hiệu suất hoặc hao mòn thiết bị flash
				do sự di chuyển dư thừa của các khối đang sử dụng.

NILFS_IOCTL_GET_SUSTAT Trả về số liệu thống kê sử dụng phân đoạn. ioctl này
			        được sử dụng trong các tiện ích lssu, nilfs_resize và
			        bởi daemon nilfs_cleanerd.

NILFS_IOCTL_GET_VINFO Trả về thông tin về địa chỉ khối ảo.
			        Ioctl này được sử dụng bởi daemon nilfs_cleanerd.

NILFS_IOCTL_GET_BDESCS Trả về thông tin về bộ mô tả đĩa
			        khối số. Ioctl này được sử dụng bởi
			        daemon nilfs_cleanerd.

NILFS_IOCTL_CLEAN_SEGMENTS Thực hiện hoạt động thu gom rác trong
			        môi trường của các tham số được yêu cầu từ
			        không gian người dùng. Ioctl này được sử dụng bởi
			        daemon nilfs_cleanerd.

NILFS_IOCTL_SYNC Tạo điểm kiểm tra. ioctl này được sử dụng trong
			        tiện ích mkcp.

NILFS_IOCTL_RESIZE Thay đổi kích thước âm lượng NILFS2. ioctl này được sử dụng
			        bởi tiện ích nilfs_resize.

NILFS_IOCTL_SET_ALLOC_RANGE Xác định giới hạn dưới của các phân đoạn theo byte và
			        giới hạn trên của các phân đoạn tính bằng byte. ioctl này
			        được sử dụng bởi tiện ích nilfs_resize.
 ===================================================================================

Cách sử dụng NILFS2
============

Để sử dụng nilfs2 làm hệ thống tệp cục bộ, chỉ cần ::

# mkfs -t nilfs2/dev/block_device
 # mount -t nilfs2/dev/block_device/dir

Điều này cũng sẽ gọi trình dọn dẹp thông qua chương trình trợ giúp gắn kết
(mount.nilfs2).

Điểm kiểm tra và ảnh chụp nhanh được quản lý bằng các lệnh sau.
Các trang của họ được bao gồm trong gói nilfs-utils ở trên.

==== =================================================================
  lscp liệt kê các điểm kiểm tra hoặc ảnh chụp nhanh.
  mkcp tạo điểm kiểm tra hoặc ảnh chụp nhanh.
  chcp thay đổi điểm kiểm tra hiện có thành ảnh chụp nhanh hoặc ngược lại.
  rmcp vô hiệu hóa (các) điểm kiểm tra được chỉ định.
  ==== =================================================================

Để gắn ảnh chụp nhanh::

# mount -t nilfs2 -r -o cp=<cno> /dev/block_device /snap_dir

trong đó <cno> là số điểm kiểm tra của ảnh chụp nhanh.

Để ngắt kết nối điểm gắn kết hoặc ảnh chụp nhanh NILFS2, chỉ cần::

# umount / thư mục

Sau đó, trình nền sạch sẽ tự động bị tắt bởi umount
chương trình trợ giúp (umount.nilfs2).

Định dạng đĩa
===========

Một tập nilfs2 được chia đều thành một số phân đoạn ngoại trừ
cho siêu khối (SB) và phân đoạn #0.  Một đoạn là vùng chứa
của nhật ký.  Mỗi nhật ký bao gồm các khối thông tin tóm tắt, tải trọng
khối và một khối siêu gốc tùy chọn (SR)::

______________________________________________________
  Phân đoạn ZZ0000ZZSBZZ0001ZZ Phân đoạn ZZ0002ZZ Phân đoạn ZZ0003ZZ Phân đoạn ZZ0004ZZ
  ZZ0005ZZ__ZZ0006ZZ____0____ZZ0007ZZ____2____ZZ0008ZZ____N____ZZ0009ZZ
  0 +1K +4K +8M +16M +24M +(8MB x N)
       .             .            (Độ lệch điển hình cho khối 4KB)
    .                  .
  .______________________.
  Nhật ký ZZ0010ZZ Nhật ký ZZ0011ZZ |
  |__1__|__2__|____|__m__|
        .       .
      .               .
    .                       .
  .______________________________.
  Khối tải trọng ZZ0014ZZ ZZ0015ZZ
  ZZ0016ZZ_________________ZZ0017ZZ

Các khối tải trọng được tổ chức trên mỗi tệp và mỗi tệp bao gồm
khối dữ liệu và khối nút cây B::

ZZ0000ZZ<--- Tệp-B --->|
   _______________________________________________________________
    Khối cây B ZZ0001ZZ Khối cây B ZZ0002ZZ | ...
   _ZZ0003ZZ_______________ZZ0004ZZ_______________|_


Vì chỉ những khối đã sửa đổi mới được ghi vào nhật ký nên nó có thể có
các tệp không có khối dữ liệu hoặc khối nút cây B.

Việc tổ chức các khối được ghi lại trong thông tin tóm tắt
các khối chứa cấu trúc tiêu đề (nilfs_segment_summary), mỗi
cấu trúc tệp (nilfs_finfo) và cấu trúc trên mỗi khối (nilfs_binfo)::

_________________________________________________________________________
 ZZ0000ZZ thông tin ZZ0001ZZ ... ZZ0002ZZ thông tin ZZ0003ZZ ... ZZ0004ZZ...
 ZZ0005ZZ___A___ZZ0006ZZ_____ZZ0007ZZ___B___ZZ0008ZZ_____ZZ0009ZZ___


Nhật ký bao gồm các tệp thông thường, tệp thư mục, tệp liên kết tượng trưng
và một số tệp dữ liệu meta.  Các tệp dữ liệu meta là các tệp được sử dụng
để duy trì dữ liệu meta hệ thống tập tin.  Phiên bản hiện tại của NILFS2 sử dụng
các tệp dữ liệu meta sau::

1) Tệp inode (ifile) - Lưu trữ các nút trên đĩa
 2) Tệp điểm kiểm tra (cpfile) - Lưu trữ điểm kiểm tra
 3) Tệp sử dụng phân đoạn (sufile) - Lưu trữ trạng thái phân bổ của phân đoạn
 4) Tệp dịch địa chỉ dữ liệu - Ánh xạ số khối ảo thành thông thường
    (DAT) số khối.  Tập tin này phục vụ cho
                                      làm cho các khối trên đĩa có thể định vị lại được.

Hình dưới đây cho thấy cách tổ chức nhật ký điển hình::

_________________________________________________________________________
 ZZ0000ZZ tệp thông thường ZZ0001ZZ ... ZZ0002ZZ cpfile ZZ0003ZZ DAT ZZ0004ZZ
 |_blocks__|_or_directory_|_______|_____|_______|________|________|_____|__|


Để vượt qua ranh giới phân đoạn, chuỗi tệp này có thể được chia nhỏ
thành nhiều nhật ký.  Trình tự các nhật ký cần được xử lý như
một cách logic một nhật ký, được phân cách bằng các cờ được đánh dấu trong phân đoạn
tóm tắt.  Mã khôi phục của nilfs2 xem thông tin ranh giới này
để đảm bảo tính nguyên tử của các bản cập nhật.

Khối siêu gốc được chèn vào cho mọi điểm kiểm tra.  Nó bao gồm
ba nút đặc biệt, các nút dành cho DAT, cpfile và sufile.  Inode
của các tập tin thông thường, thư mục, liên kết tượng trưng và các tập tin đặc biệt khác, được
được bao gồm trong iffile.  Bản thân inode của iffile được bao gồm trong
mục nhập điểm kiểm tra tương ứng trong cpfile.  Như vậy, hệ thống phân cấp
trong số các tệp NILFS2 có thể được mô tả như sau::

Siêu khối (SB)
       |
       v
  Khối siêu gốc (cno=xx mới nhất)
       |-- DAT
       |-- sufile
       ZZ0000ZZ-- iffile (cno=xx) |-- tập tin (ino=i3)
                                  : :
                                  `-- tập tin (ino=yy)
                                    (tệp thông thường, thư mục hoặc liên kết tượng trưng)

Để biết chi tiết về định dạng của từng tệp, vui lòng xem nilfs2_ondisk.h
nằm ở thư mục include/uapi/linux.

Không có bằng sáng chế hoặc tài sản trí tuệ nào khác mà chúng tôi bảo vệ
liên quan đến thiết kế của NILFS2.  Nó được phép sao chép
thiết kế với hy vọng rằng các hệ điều hành khác có thể chia sẻ (mount, đọc,
ghi, v.v.) dữ liệu được lưu trữ ở định dạng này.