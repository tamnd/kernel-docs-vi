.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-zoned.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========
khoanh vùng dm
========

Mục tiêu ánh xạ thiết bị được khoanh vùng dm hiển thị một thiết bị khối được khoanh vùng (ZBC và
thiết bị tương thích ZAC) như một thiết bị khối thông thường mà không cần ghi
những hạn chế về mẫu mã. Trong thực tế, nó thực hiện một cơ chế phân vùng được quản lý bằng ổ đĩa
chặn thiết bị ẩn khỏi người dùng (hệ thống tệp hoặc ứng dụng
thực hiện truy cập thiết bị khối thô) các ràng buộc ghi tuần tự của
thiết bị khối được khoanh vùng do máy chủ quản lý và có thể giảm thiểu khả năng
suy giảm hiệu suất phía thiết bị do ghi ngẫu nhiên quá mức
thiết bị khối được khoanh vùng nhận biết máy chủ.

Để có mô tả chi tiết hơn về các mẫu thiết bị khối được khoanh vùng và
xem các ràng buộc của họ (đối với các thiết bị SCSI):

ZZ0000ZZ

và (đối với thiết bị ATA):

ZZ0000ZZ

Việc triển khai dm-zoned rất đơn giản và giảm thiểu chi phí hệ thống (CPU
và sử dụng bộ nhớ cũng như mất dung lượng lưu trữ). Đối với 10TB
đĩa do máy chủ quản lý với các vùng 256 MB, mức sử dụng bộ nhớ được phân vùng dm trên mỗi đĩa
phiên bản có dung lượng tối đa là 4,5 MB và chỉ sử dụng tối đa 5 vùng
nội bộ để lưu trữ siêu dữ liệu và thực hiện các hoạt động lấy lại.

các thiết bị mục tiêu được khoanh vùng dm được định dạng và kiểm tra bằng dmzadm
Tiện ích có sẵn tại:

ZZ0000ZZ

Thuật toán
=========

dm-zoned triển khai sơ đồ đệm trên đĩa để xử lý các dữ liệu không tuần tự
quyền ghi vào các vùng tuần tự của thiết bị khối được khoanh vùng.
Các vùng thông thường được sử dụng để lưu vào bộ nhớ đệm cũng như lưu trữ nội bộ
siêu dữ liệu. Nó cũng có thể sử dụng một thiết bị khối thông thường cùng với thiết bị được khoanh vùng
chặn thiết bị; trong trường hợp đó thiết bị khối thông thường sẽ được phân chia một cách hợp lý
trong các vùng có cùng kích thước với thiết bị khối được khoanh vùng. Các khu vực này sẽ được
được đặt trước các vùng từ thiết bị khối được khoanh vùng và sẽ được xử lý
giống như các khu vực thông thường.

Các vùng của (các) thiết bị được chia thành 2 loại:

1) Vùng siêu dữ liệu: đây là các vùng thông thường được sử dụng để lưu trữ siêu dữ liệu.
Vùng siêu dữ liệu không được báo cáo là dung lượng có thể sử dụng cho người dùng.

2) Vùng dữ liệu: tất cả các vùng còn lại, phần lớn trong số đó sẽ được
các vùng tuần tự được sử dụng riêng để lưu trữ dữ liệu người dùng. thông thường
các vùng của thiết bị cũng có thể được sử dụng để đệm ghi ngẫu nhiên của người dùng.
Dữ liệu trong các vùng này có thể được ánh xạ trực tiếp tới vùng thông thường, nhưng
sau đó được chuyển sang vùng tuần tự để vùng thông thường có thể được
được sử dụng lại để đệm các lần ghi ngẫu nhiên đến.

dm-zoned hiển thị một thiết bị logic có kích thước cung là 4096 byte,
bất kể kích thước khu vực vật lý của khối được khoanh vùng phụ trợ
thiết bị đang được sử dụng. Điều này cho phép giảm số lượng siêu dữ liệu cần thiết để
quản lý các khối hợp lệ (khối được viết).

Định dạng siêu dữ liệu trên đĩa như sau:

1) Khối đầu tiên của vùng quy ước đầu tiên được tìm thấy chứa
siêu khối mô tả số lượng trên đĩa và vị trí của siêu dữ liệu
khối.

2) Sau siêu khối, một tập hợp các khối được sử dụng để mô tả
ánh xạ các khối thiết bị logic. Việc ánh xạ được thực hiện trên mỗi đoạn của
các khối, với kích thước chunk bằng kích thước thiết bị khối được khoanh vùng. các
bảng ánh xạ được lập chỉ mục theo số đoạn và mỗi mục ánh xạ
cho biết số vùng của thiết bị lưu trữ đoạn dữ liệu. Mỗi
mục ánh xạ cũng có thể cho biết liệu số vùng của một thông thường
vùng được sử dụng để đệm sửa đổi ngẫu nhiên cho vùng dữ liệu.

3) Một tập hợp các khối được sử dụng để lưu trữ ảnh bitmap cho biết tính hợp lệ của
các khối trong vùng dữ liệu tuân theo bảng ánh xạ. Một khối hợp lệ là
được định nghĩa là một khối được viết và không bị loại bỏ. Để được đệm
đoạn dữ liệu, một khối luôn chỉ hợp lệ trong vùng dữ liệu ánh xạ
chunk hoặc trong vùng đệm của chunk.

Đối với một đoạn logic được ánh xạ tới một vùng thông thường, tất cả các thao tác ghi
được xử lý bằng cách ghi trực tiếp vào vùng. Nếu vùng ánh xạ là một
vùng tuần tự, thao tác ghi chỉ được xử lý trực tiếp nếu
phần bù ghi trong đoạn logic bằng với con trỏ ghi
offset trong vùng dữ liệu tuần tự (tức là thao tác ghi được thực hiện
căn chỉnh trên con trỏ ghi vùng). Mặt khác, các thao tác ghi là
được xử lý gián tiếp bằng cách sử dụng vùng đệm. Trong trường hợp đó, một tài khoản chưa được sử dụng
vùng thông thường được phân bổ và gán cho đoạn đang được
đã truy cập. Việc ghi một khối vào vùng đệm của một đoạn sẽ
tự động vô hiệu hóa cùng một khối trong ánh xạ vùng tuần tự
khúc đó. Nếu tất cả các khối của vùng tuần tự trở nên không hợp lệ thì vùng đó
được giải phóng và vùng đệm chunk trở thành vùng chính ánh xạ
chunk, dẫn đến hiệu suất ghi ngẫu nhiên tự nhiên tương tự như thông thường
chặn thiết bị.

Hoạt động đọc được xử lý theo tính hợp lệ của khối
thông tin được cung cấp bởi bitmap. Các khối hợp lệ được đọc từ
vùng tuần tự ánh xạ một đoạn hoặc nếu đoạn đó được lưu vào bộ đệm, từ
vùng đệm được chỉ định. Nếu đoạn được truy cập không có ánh xạ, hoặc
các khối được truy cập không hợp lệ, bộ đệm đọc bằng 0 và giá trị đọc
hoạt động chấm dứt.

Sau một thời gian, số lượng khu vực thông thường có sẵn có hạn có thể
đã cạn kiệt (tất cả được sử dụng để ánh xạ các khối hoặc vùng đệm tuần tự) và
việc ghi không được căn chỉnh vào các đoạn không có bộ đệm trở thành không thể. Để tránh điều này
tình huống, quy trình thu hồi thường xuyên quét các vùng thông thường đã sử dụng và
cố gắng lấy lại các vùng ít được sử dụng gần đây nhất bằng cách sao chép vùng hợp lệ
các khối của vùng đệm thành vùng tuần tự tự do. Một khi sao chép
hoàn tất, ánh xạ chunk được cập nhật để trỏ tới vùng tuần tự
và vùng đệm được giải phóng để tái sử dụng.

Bảo vệ siêu dữ liệu
===================

Để bảo vệ siêu dữ liệu khỏi bị hỏng trong trường hợp mất điện đột ngột hoặc
sự cố hệ thống, 2 bộ vùng siêu dữ liệu được sử dụng. Một bộ, chính
bộ, được sử dụng làm vùng siêu dữ liệu chính, trong khi bộ thứ cấp được sử dụng làm
được sử dụng làm khu vực tổ chức. Siêu dữ liệu đã sửa đổi lần đầu tiên được ghi vào
tập thứ cấp và được xác thực bằng cách cập nhật siêu khối trong tập thứ cấp
bộ, bộ đếm thế hệ được sử dụng để chỉ ra rằng bộ này chứa
siêu dữ liệu mới nhất. Khi thao tác này hoàn tất, thay cho siêu dữ liệu
cập nhật khối có thể được thực hiện trong bộ siêu dữ liệu chính. Điều này đảm bảo rằng
một trong các bộ luôn nhất quán (tất cả các sửa đổi được cam kết hoặc không có sửa đổi nào
không hề). Hoạt động tuôn ra được sử dụng như một điểm cam kết. Khi tiếp nhận
yêu cầu xóa, hoạt động sửa đổi siêu dữ liệu tạm thời bị chặn
(đối với cả quá trình xử lý và thu hồi BIO sắp đến) và tất cả các lỗi bẩn
các khối siêu dữ liệu được sắp xếp và cập nhật. Khi đó hoạt động bình thường
được tiếp tục. Do đó, việc xóa siêu dữ liệu chỉ tạm thời làm trì hoãn việc ghi và
loại bỏ các yêu cầu. Yêu cầu đọc có thể được xử lý đồng thời trong khi
việc xóa siêu dữ liệu đang được thực thi.

Nếu một thiết bị thông thường được sử dụng cùng với thiết bị khối được khoanh vùng,
bộ siêu dữ liệu thứ ba (không có bitmap vùng) được ghi vào
bắt đầu của thiết bị khối được khoanh vùng. Siêu dữ liệu này có bộ đếm thế hệ
'0' và sẽ không bao giờ được cập nhật trong quá trình hoạt động bình thường; nó chỉ phục vụ cho
mục đích nhận dạng. Bản sao thứ nhất và thứ hai của siêu dữ liệu
được đặt ở đầu thiết bị khối thông thường.

Cách sử dụng
=====

Thiết bị khối được khoanh vùng trước tiên phải được định dạng bằng công cụ dmzadm. Cái này
sẽ phân tích cấu hình vùng thiết bị, xác định vị trí đặt
bộ siêu dữ liệu trên thiết bị và khởi tạo bộ siêu dữ liệu.

Bán tại::

dmzadm --format /dev/sdxx


Nếu sử dụng hai ổ đĩa, cả hai thiết bị phải được chỉ định, với
thiết bị khối thông thường làm thiết bị đầu tiên.

Bán tại::

dmzadm --format /dev/sdxx /dev/sdyy


(Các) thiết bị được định dạng cũng có thể được khởi động bằng tiện ích dmzadm.:

Bán tại::

dmzadm --start /dev/sdxx /dev/sdyy


Thông tin về cách bố trí bên trong và cách sử dụng hiện tại của các vùng có thể
có được bằng lệnh gọi lại 'trạng thái' từ dmsetup:

Bán tại::

trạng thái dmsetup/dev/dm-X

sẽ trả lại một dòng

0 <size> được khoanh vùng <nr_zones> vùng <nr_unmap_rnd>/<nr_rnd> ngẫu nhiên <nr_unmap_seq>/<nr_seq> tuần tự

trong đó <nr_zones> là tổng số vùng, <nr_unmap_rnd> là số
của các vùng ngẫu nhiên chưa được ánh xạ (tức là miễn phí), <nr_rnd> tổng số vùng,
<nr_unmap_seq> số vùng tuần tự chưa được ánh xạ và <nr_seq>
tổng số vùng liên tiếp.

Thông thường quá trình lấy lại sẽ được bắt đầu khi có ít hơn 50
phần trăm vùng ngẫu nhiên miễn phí. Để bắt đầu quá trình lấy lại bằng tay
ngay cả trước khi đạt đến ngưỡng này, chức năng 'thông báo dmsetup' có thể
đã sử dụng:

Bán tại::

tin nhắn dmsetup/dev/dm-X 0 lấy lại

sẽ bắt đầu quá trình lấy lại và các vùng ngẫu nhiên sẽ được chuyển sang tuần tự
khu.
