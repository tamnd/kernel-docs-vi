.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/md/raid5-cache.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Bộ đệm RAID 4/5/6
================

Raid 4/5/6 có thể bao gồm một đĩa bổ sung để lưu trữ dữ liệu bên cạnh RAID thông thường
đĩa. Vai trò của đĩa RAID không thay đổi với đĩa đệm. Đĩa đệm
lưu trữ dữ liệu vào đĩa RAID. Bộ đệm có thể ở chế độ ghi (được hỗ trợ
kể từ 4.4) hoặc chế độ ghi lại (được hỗ trợ kể từ 4.10). mdadm (được hỗ trợ kể từ
3.4) có tùy chọn mới '--write-journal' để tạo mảng có bộ đệm. làm ơn
tham khảo hướng dẫn sử dụng mdadm để biết chi tiết. Theo mặc định (mảng RAID bắt đầu), bộ nhớ đệm được
ở chế độ ghi qua. Người dùng có thể chuyển nó sang chế độ ghi lại bằng cách::

echo "ghi lại" > /sys/block/md0/md/journal_mode

Và chuyển nó trở lại chế độ ghi bằng cách ::

echo "ghi qua" > /sys/block/md0/md/journal_mode

Trong cả hai chế độ, tất cả việc ghi vào mảng sẽ vào đĩa đệm trước. Điều này có nghĩa
đĩa đệm phải nhanh và bền vững.

chế độ ghi qua
==================

Chế độ này chủ yếu khắc phục vấn đề 'lỗ ghi'. Đối với mảng RAID 4/5/6, không sạch
việc tắt máy có thể khiến dữ liệu ở một số sọc không ở trạng thái nhất quán, ví dụ: dữ liệu
và tính chẵn lẻ không khớp. Lý do là việc viết sọc liên quan đến nhiều RAID
đĩa và có thể việc ghi chưa chạm tới tất cả các đĩa RAID trước khi
tắt máy không sạch sẽ. Chúng tôi gọi một mảng bị xuống cấp nếu nó có dữ liệu không nhất quán. MD
cố gắng đồng bộ lại mảng để đưa nó trở lại trạng thái bình thường. Nhưng trước
quá trình đồng bộ lại hoàn tất, bất kỳ sự cố hệ thống nào cũng có thể làm lộ ra dữ liệu thực
tham nhũng trong mảng RAID. Vấn đề này được gọi là 'lỗ ghi'.

Bộ nhớ đệm ghi qua sẽ lưu vào bộ nhớ đệm tất cả dữ liệu trên đĩa đệm trước tiên. Sau khi dữ liệu
an toàn trên đĩa đệm, dữ liệu sẽ được xóa vào đĩa RAID. các
ghi hai bước sẽ đảm bảo MD có thể khôi phục dữ liệu chính xác sau khi không sạch
tắt máy ngay cả khi mảng bị xuống cấp. Do đó bộ đệm có thể đóng 'lỗ ghi'.

Trong chế độ ghi, MD báo cáo việc hoàn thành IO lên lớp trên (thường là
hệ thống tập tin) sau khi dữ liệu an toàn trên đĩa RAID, do đó lỗi đĩa đệm
không gây mất dữ liệu. Tất nhiên lỗi đĩa đệm có nghĩa là mảng đó bị hỏng
lại gặp phải 'lỗ viết'.

Ở chế độ ghi, đĩa đệm không cần phải lớn. Một số
hàng trăm megabyte là đủ.

chế độ ghi lại
===============

chế độ ghi lại cũng khắc phục được vấn đề 'lỗ ghi' vì tất cả dữ liệu ghi đều được
được lưu trữ trên đĩa đệm. Nhưng mục tiêu chính của bộ nhớ đệm 'ghi lại' là tăng tốc
viết. Nếu một thao tác ghi vượt qua tất cả các đĩa RAID của một sọc, chúng tôi gọi đó là sọc đầy đủ
viết. Đối với ghi không đầy đủ sọc, MD phải đọc dữ liệu cũ trước tính chẵn lẻ mới
có thể được tính toán. Những lần đọc đồng bộ này làm ảnh hưởng đến thông lượng ghi. Một số viết
được gửi tuần tự nhưng không được gửi cùng lúc sẽ gặp phải vấn đề này
trên cao quá. Bộ đệm ghi lại sẽ tổng hợp dữ liệu và chuyển dữ liệu sang
Đĩa RAID chỉ được ghi sau khi dữ liệu được ghi đầy đủ. Điều này sẽ
hoàn toàn tránh được chi phí chung, vì vậy nó rất hữu ích cho một số khối lượng công việc. A
khối lượng công việc điển hình thực hiện ghi tuần tự theo sau là fsync là một ví dụ.

Trong chế độ ghi lại, MD báo cáo việc hoàn thành IO lên lớp trên (thường là
filesystems) ngay sau khi dữ liệu chạm vào đĩa đệm. Dữ liệu được xóa để đột kích
đĩa sau khi các điều kiện cụ thể được đáp ứng. Vì vậy lỗi đĩa đệm sẽ gây ra
mất dữ liệu.

Ở chế độ ghi lại, MD cũng lưu trữ dữ liệu vào bộ nhớ. Bộ nhớ đệm bao gồm
cùng một dữ liệu được lưu trữ trên đĩa đệm, do đó việc mất điện không gây mất dữ liệu.
Kích thước bộ đệm bộ nhớ có tác động đến hiệu suất của mảng. Nó được khuyến khích
kích thước là lớn. Người dùng có thể định cấu hình kích thước bằng cách::

echo "2048" > /sys/block/md0/md/stripe_cache_size

Đĩa đệm quá nhỏ sẽ làm cho việc tổng hợp ghi kém hiệu quả hơn trong trường hợp này
chế độ tùy thuộc vào khối lượng công việc. Bạn nên sử dụng đĩa đệm có tại
kích thước tối thiểu vài gigabyte ở chế độ ghi lại.

Việc thực hiện
==================

Bộ nhớ đệm ghi qua và ghi lại sử dụng cùng một định dạng đĩa. Đĩa đệm
được tổ chức dưới dạng nhật ký ghi đơn giản. Nhật ký bao gồm 'siêu dữ liệu' và 'dữ liệu'
cặp. Dữ liệu meta mô tả dữ liệu. Nó cũng bao gồm tổng kiểm tra và trình tự
ID để nhận dạng phục hồi. Dữ liệu có thể là dữ liệu IO và dữ liệu chẵn lẻ. Dữ liệu là
cũng đã được kiểm tra. Tổng kiểm tra được lưu trữ trong siêu dữ liệu trước dữ liệu. các
tổng kiểm tra là một sự tối ưu hóa vì MD có thể ghi meta và dữ liệu một cách tự do mà không cần
lo lắng về thứ tự. Siêu khối MD có một trường được trỏ đến dữ liệu meta hợp lệ
của đầu gỗ.

Việc thực hiện nhật ký khá đơn giản. Phần khó khăn là
thứ tự MD ghi dữ liệu vào đĩa đệm và đĩa RAID. Cụ thể, ở
chế độ ghi qua, MD tính toán tính chẵn lẻ cho dữ liệu IO, ghi cả dữ liệu IO và
chẵn lẻ vào nhật ký, ghi dữ liệu và tính chẵn lẻ vào đĩa RAID sau dữ liệu và
tính chẵn lẻ được giải quyết trong nhật ký và cuối cùng IO kết thúc. Đọc chỉ đọc
từ đĩa đột kích như bình thường.

Ở chế độ ghi lại, MD ghi dữ liệu IO vào nhật ký và báo cáo việc hoàn thành IO. các
dữ liệu cũng được lưu trữ đầy đủ trong bộ nhớ tại thời điểm đó, điều đó có nghĩa là việc đọc phải truy vấn
bộ nhớ đệm. Nếu một số điều kiện được đáp ứng, MD sẽ chuyển dữ liệu sang đĩa RAID.
MD sẽ tính toán tính chẵn lẻ cho dữ liệu và ghi tính chẵn lẻ vào nhật ký. Sau này
hoàn tất, MD sẽ ghi cả dữ liệu và tính chẵn lẻ vào các đĩa RAID, sau đó MD có thể
giải phóng bộ nhớ đệm. Các điều kiện tuôn ra có thể là sọc trở thành đầy đủ
ghi sọc, dung lượng đĩa đệm còn trống sắp hết hoặc dung lượng bộ nhớ đệm trong bộ nhớ trong kernel còn trống
thấp.

Sau khi tắt máy không sạch sẽ, MD sẽ phục hồi. MD đọc tất cả dữ liệu meta và dữ liệu
từ nhật ký. ID chuỗi và tổng kiểm tra sẽ giúp chúng tôi phát hiện meta bị hỏng
dữ liệu và dữ liệu. Nếu MD tìm thấy một sọc có dữ liệu và các số chẵn lẻ hợp lệ (1 số chẵn lẻ cho
raid4/5 và 2 cho raid6), MD sẽ ghi dữ liệu và số chẵn lẻ vào đĩa RAID. Nếu
số chẵn lẻ không đầy đủ, chúng bị loại bỏ. Nếu một phần dữ liệu bị hỏng,
chúng cũng bị loại bỏ. MD sau đó tải dữ liệu hợp lệ và ghi chúng vào đĩa RAID
theo cách thông thường.
