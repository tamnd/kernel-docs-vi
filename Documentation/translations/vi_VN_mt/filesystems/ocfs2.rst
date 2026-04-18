.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ocfs2.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Hệ thống tập tin OCFS2
======================

OCFS2 là tệp cụm đĩa chia sẻ dựa trên phạm vi mục đích chung
hệ thống có nhiều điểm tương đồng với ext3. Nó hỗ trợ inode 64 bit
số và đã tự động mở rộng các nhóm siêu dữ liệu có thể
cũng làm cho nó hấp dẫn cho việc sử dụng không phân cụm.

Bạn sẽ muốn cài đặt gói ocfs2-tools để ít nhất
nhận "mount.ocfs2" và "ocfs2_hb_ctl".

Trang web dự án: ZZ0000ZZ
Cây git công cụ: ZZ0001ZZ
Danh sách gửi thư OCFS2: ZZ0002ZZ

Tất cả các mã bản quyền 2005 Oracle trừ khi có ghi chú khác.

Tín dụng
=======

Rất nhiều mã được lấy từ ext3 và các dự án khác.

Các tác giả theo thứ tự bảng chữ cái:

- Joel Becker <joel.becker@oracle.com>
- Zach Brown <zach. brown@oracle.com>
- Mark Fasheh <mfasheh@suse.com>
- Kurt Hackel <kurt.hackel@oracle.com>
- Tao Ma <tao.ma@oracle.com>
- Sunil Mushran <sunil.mushran@oracle.com>
- Manish Singh <manish.singh@oracle.com>
- Hổ Dương <tiger.yang@oracle.com>

Hãy cẩn thận
=======
Các tính năng mà OCFS2 chưa hỗ trợ:

- Thông báo thay đổi thư mục (F_NOTIFY)
	- Bộ nhớ đệm phân tán (F_SETLEASE/F_GETLEASE/break_lease)

Tùy chọn gắn kết
=============

OCFS2 hỗ trợ các tùy chọn gắn kết sau:

(*) == mặc định

=====================================================================================
Barrier=1 Điều này cho phép/vô hiệu hóa các rào cản. rào cản = 0 vô hiệu hóa nó,
			Barrier=1 kích hoạt nó.
error=remount-ro(*) Gắn lại hệ thống tập tin chỉ đọc khi có lỗi.
error=panic Hoảng loạn và dừng máy nếu xảy ra lỗi.
intr (*) Cho phép tín hiệu làm gián đoạn hoạt động của cụm.
nointr Không cho phép tín hiệu làm gián đoạn cụm
			hoạt động.
noatime Không cập nhật thời gian truy cập.
relatime(*) Cập nhật atime nếu atime trước đó cũ hơn
			mtime hoặc ctime
thời gian nghiêm ngặt Luôn cập nhật vào một thời điểm, nhưng khoảng thời gian cập nhật tối thiểu
			được chỉ định bởi atime_quantum.
atime_quantum=60(*) OCFS2 sẽ không cập nhật tại thời điểm trừ khi có con số này
			giây đã trôi qua kể từ lần cập nhật cuối cùng.
			Đặt về 0 để luôn cập nhật theo thời gian. Tùy chọn này cần
			làm việc với thời gian nghiêm ngặt.
data=ordered (*) Tất cả dữ liệu được buộc trực tiếp vào tệp chính
			hệ thống trước khi siêu dữ liệu của nó được cam kết với
			tạp chí.
data=writeback Thứ tự dữ liệu không được giữ nguyên, dữ liệu có thể được ghi
			vào hệ thống tập tin chính sau khi siêu dữ liệu của nó đã được
			cam kết với tạp chí.
ưa thích_slot=0(*) Trong quá trình gắn kết, trước tiên hãy thử sử dụng khe hệ thống tệp này. Nếu
			nó đang được sử dụng bởi một nút khác, nút trống đầu tiên được tìm thấy
			sẽ được chọn. Các giá trị không hợp lệ sẽ bị bỏ qua.
commit=nrsec (*) Ocfs2 có thể được yêu cầu đồng bộ hóa tất cả dữ liệu và siêu dữ liệu của nó
			mỗi giây 'nrsec'. Giá trị mặc định là 5 giây.
			Điều này có nghĩa là nếu bạn mất quyền lực, bạn sẽ mất
			tối đa 5 giây làm việc gần nhất (của bạn
			Tuy nhiên, hệ thống tập tin sẽ không bị hỏng nhờ vào
			viết nhật ký).  Giá trị mặc định này (hoặc bất kỳ giá trị thấp nào)
			sẽ ảnh hưởng đến hiệu suất nhưng lại tốt cho sự an toàn dữ liệu.
			Đặt nó thành 0 sẽ có tác dụng tương tự như việc rời khỏi
			nó ở mặc định (5 giây).
			Đặt nó thành giá trị rất lớn sẽ cải thiện
			hiệu suất.
localalloc=8(*) Cho phép kích thước localalloc tùy chỉnh tính bằng MB. Nếu giá trị quá
			lớn, fs sẽ âm thầm hoàn nguyên nó về mặc định.
localflocks Điều này vô hiệu hóa đàn nhận biết cụm.
inode64 Cho biết rằng Ocfs2 được phép tạo các nút tại
			bất kỳ vị trí nào trong hệ thống tập tin, bao gồm cả những vị trí
			sẽ dẫn đến số inode chiếm hơn 32
			chút ý nghĩa.
user_xattr (*) Kích hoạt thuộc tính người dùng mở rộng.
nouser_xattr Vô hiệu hóa các thuộc tính người dùng mở rộng.
acl Bật hỗ trợ Danh sách điều khiển truy cập POSIX.
noacl (*) Tắt hỗ trợ Danh sách điều khiển truy cập POSIX.
resv_level=2 (*) Đặt mức độ đặt trước phân bổ linh hoạt.
			Các giá trị hợp lệ nằm trong khoảng từ 0 (tắt đặt trước) đến 8
			(không gian tối đa để đặt chỗ).
dir_resv_level= (*) Theo mặc định, việc đặt trước thư mục sẽ chia tỷ lệ theo tệp
			đặt chỗ - người dùng hiếm khi cần thay đổi điều này
			giá trị. Nếu việc đặt trước phân bổ bị tắt, điều này
			tùy chọn sẽ không có hiệu lực.
coherency=full (*) Không cho phép ghi O_DIRECT đồng thời, inode cụm
			khóa sẽ được thực hiện để buộc các nút khác bỏ bộ đệm,
			do đó tính nhất quán của cụm đầy đủ được đảm bảo ngay cả
			cho O_DIRECT viết.
coherency=buffered Cho phép ghi O_DIRECT đồng thời mà không cần khóa EX giữa
			các nút đạt được hiệu suất cao nhưng có nguy cơ bị
			dữ liệu cũ trên các nút khác.
Journal_async_commit Khối cam kết có thể được ghi vào đĩa mà không cần chờ đợi
			cho các khối mô tả. Nếu được kích hoạt, các hạt nhân cũ hơn không thể
			gắn thiết bị. Điều này sẽ kích hoạt 'journal_checksum'
			nội bộ.
=====================================================================================