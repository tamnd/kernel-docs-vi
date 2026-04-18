.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ocfs2-online-filecheck.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Hệ thống tệp OCFS2 - kiểm tra tệp trực tuyến
============================================

Tài liệu này sẽ mô tả tính năng kiểm tra tệp trực tuyến của OCFS2.

Giới thiệu
============
OCFS2 thường được sử dụng trong các hệ thống có tính sẵn sàng cao. Tuy nhiên, OCFS2 thường
chuyển đổi hệ thống tập tin thành chỉ đọc khi gặp lỗi. Điều này có thể không
cần thiết, vì việc chuyển hệ thống tập tin sang chế độ chỉ đọc sẽ ảnh hưởng đến các hoạt động khác
quá trình cũng vậy, làm giảm tính sẵn sàng.
Sau đó, một tùy chọn gắn kết (lỗi=tiếp tục) được đưa ra, sẽ trả về
-EIO gặp lỗi trong quá trình gọi và chấm dứt quá trình xử lý tiếp theo để
hệ thống tập tin không bị hỏng thêm. Hệ thống tập tin không được chuyển đổi thành
chỉ đọc và số inode của tệp có vấn đề được báo cáo trong kernel
nhật ký. Người dùng có thể thử kiểm tra/sửa tệp này thông qua tính năng kiểm tra tệp trực tuyến.

Phạm vi
=======
Nỗ lực này nhằm kiểm tra/khắc phục các vấn đề nhỏ có thể cản trở hoạt động hàng ngày
của một hệ thống tập tin cụm bằng cách chuyển hệ thống tập tin sang chế độ chỉ đọc. Phạm vi của
việc kiểm tra/sửa lỗi ở cấp độ tệp, ban đầu là đối với các tệp thông thường và cuối cùng là
tới tất cả các tệp (bao gồm cả tệp hệ thống) của hệ thống tệp.

Trong trường hợp liên kết thư mục đến tập tin không chính xác, inode thư mục là
được báo cáo là sai.

Tính năng này không phù hợp với những kiểm tra phức tạp liên quan đến sự phụ thuộc của
các thành phần khác của hệ thống tập tin, chẳng hạn như nhưng không giới hạn ở việc kiểm tra xem
bit cho khối tệp trong phân bổ đã được đặt. Trong trường hợp có lỗi như vậy,
fsck ngoại tuyến nên/sẽ được đề xuất.

Cuối cùng, một hoạt động/tính năng như vậy không nên được tự động hóa vì sợ hệ thống tập tin
có thể bị hư hại nhiều hơn trước khi cố gắng sửa chữa. Vì vậy, điều này phải
được thực hiện bằng cách sử dụng sự tương tác và sự đồng ý của người dùng.

Giao diện người dùng
====================
Khi có lỗi trong hệ thống tập tin OCFS2, chúng thường đi kèm
bởi số inode gây ra lỗi. Số inode này sẽ là
input để kiểm tra/sửa tập tin.

Có một thư mục sysfs để gắn mỗi hệ thống tệp OCFS2 ::

/sys/fs/ocfs2/<devname>/filecheck

Ở đây, <devname> cho biết tên của thiết bị âm lượng OCFS2 đã được
gắn kết. Tệp ở trên sẽ chấp nhận số inode. Điều này có thể được sử dụng để
giao tiếp với không gian kernel, cho biết tệp nào (số inode) sẽ được kiểm tra hoặc
đã sửa. Hiện tại, ba thao tác được hỗ trợ, bao gồm kiểm tra
inode, sửa lỗi inode và thiết lập kích thước của lịch sử bản ghi kết quả.

1. Nếu bạn muốn biết chính xác lỗi nào đã xảy ra với <inode> trước khi sửa, hãy làm::

# echo "<inode>" > /sys/fs/ocfs2/<devname>/filecheck/check
    # cat /sys/fs/ocfs2/<devname>/filecheck/check

Đầu ra là như thế này::

INO DONE ERROR
    39502 1 GENERATION

<INO> liệt kê các số inode.
   <DONE> cho biết thao tác đã kết thúc hay chưa.
   <ERROR> cho biết loại lỗi nào đã được tìm thấy. Để biết số lỗi chi tiết,
   vui lòng tham khảo tệp linux/fs/ocfs2/filecheck.h.

2. Nếu bạn xác định sửa inode này, hãy làm::

# echo "<inode>" > /sys/fs/ocfs2/<devname>/filecheck/fix
    # cat /sys/fs/ocfs2/<devname>/filecheck/fix

Đầu ra là như thế này::

INO DONE ERROR
    39502 1 SUCCESS

Lần này, cột <ERROR> cho biết việc sửa lỗi này có thành công hay không.

3. Bộ đệm ghi được sử dụng để lưu trữ lịch sử kết quả kiểm tra/sửa lỗi. Đó là
   kích thước mặc định là 10 và có thể điều chỉnh trong phạm vi từ 10 ~ 100. Bạn có thể
   điều chỉnh kích thước như thế này::

# echo "<size>" > /sys/fs/ocfs2/<devname>/filecheck/set

Sửa chữa đồ đạc
===============
Khi nhận được inode, hệ thống tập tin sẽ đọc inode và
siêu dữ liệu tập tin. Trong trường hợp có lỗi, hệ thống tập tin sẽ sửa lỗi
và báo cáo các vấn đề nó đã khắc phục trong nhật ký kernel. Là một biện pháp phòng ngừa,
inode trước tiên phải được kiểm tra lỗi trước khi thực hiện sửa lỗi cuối cùng.

Inode và lịch sử kết quả sẽ được duy trì tạm thời trong một
bộ đệm danh sách liên kết nhỏ sẽ chứa các nút (N) cuối cùng
đã sửa/kiểm tra, các lỗi chi tiết đã được sửa/kiểm tra sẽ được in trong
nhật ký hạt nhân.