.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/multigrain-ts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Dấu thời gian nhiều hạt
=====================

Giới thiệu
============
Trong lịch sử, kernel luôn sử dụng các giá trị thời gian thô để đóng dấu các nút.
Giá trị này được cập nhật nhanh chóng, do đó, bất kỳ thay đổi nào xảy ra trong thời gian ngắn đó
sẽ kết thúc với cùng một dấu thời gian.

Khi hạt nhân đóng dấu một nút (do đọc hoặc ghi), trước tiên nó sẽ nhận được
thời gian hiện tại rồi so sánh với (các) dấu thời gian hiện có để xem
liệu có điều gì sẽ thay đổi không. Nếu không có gì thay đổi thì có thể tránh cập nhật
siêu dữ liệu của inode.

Do đó, dấu thời gian thô sẽ tốt nếu xét trên quan điểm hiệu suất, vì chúng
giảm nhu cầu cập nhật siêu dữ liệu, nhưng lại tệ từ quan điểm
xác định xem có điều gì đã thay đổi hay không, vì rất nhiều điều có thể xảy ra trong một
trong nháy mắt.

Chúng đặc biệt rắc rối với NFSv3, nơi dấu thời gian không thay đổi có thể
gây khó khăn cho việc biết có nên vô hiệu hóa bộ đệm hay không. NFSv4 cung cấp một
thuộc tính thay đổi chuyên dụng phải luôn hiển thị thay đổi rõ ràng, nhưng không
tất cả các hệ thống tập tin đều thực hiện điều này đúng cách, khiến máy chủ NFS thay thế
ctime trong nhiều trường hợp.

Dấu thời gian đa hạt nhằm mục đích khắc phục điều này bằng cách sử dụng có chọn lọc các dấu thời gian hạt mịn
dấu thời gian khi một tệp có dấu thời gian được truy vấn gần đây và dấu thời gian hiện tại
thời gian chi tiết thô không gây ra sự thay đổi.

Dấu thời gian Inode
================
Hiện tại có 3 dấu thời gian trong inode được cập nhật theo giá trị hiện tại
đồng hồ treo tường thời gian trên hoạt động khác nhau:

thời gian:
  Thời gian thay đổi inode. Điều này được đóng dấu với thời gian hiện tại bất cứ khi nào
  siêu dữ liệu của inode bị thay đổi. Lưu ý rằng giá trị này không thể thiết lập được
  từ vùng người dùng.

giờ:
  Thời gian sửa đổi inode. Điều này được đóng dấu với thời gian hiện tại
  bất cứ khi nào nội dung của tập tin thay đổi.

một lúc:
  Thời gian truy cập inode. Điều này được đóng dấu bất cứ khi nào nội dung của inode được
  đọc. Được coi là một sai lầm khủng khiếp. Thường tránh với
  các tùy chọn như noatime hoặc relatime.

Cập nhật mtime luôn ngụ ý thay đổi ctime, nhưng việc cập nhật
atime do một yêu cầu đọc không.

Dấu thời gian nhiều lớp chỉ được theo dõi cho ctime và mtime. đôi khi là
không bị ảnh hưởng và luôn sử dụng giá trị thô (tùy theo mức sàn).

Thứ tự dấu thời gian Inode
========================

Ngoài việc chỉ cung cấp thông tin về những thay đổi đối với từng tệp, tệp
dấu thời gian cũng phục vụ một mục đích quan trọng trong các ứng dụng như "thực hiện". Những cái này
chương trình đo dấu thời gian để xác định xem các tập tin nguồn có thể bị
mới hơn các đối tượng được lưu trong bộ nhớ đệm.

Các ứng dụng của người dùng như make chỉ có thể xác định thứ tự dựa trên
ranh giới hoạt động. Đối với một cuộc gọi chung, đó là lối vào và lối ra của cuộc gọi chung
điểm. Đối với các hoạt động io_uring hoặc nfsd, đó là việc gửi yêu cầu và
phản hồi. Trong trường hợp hoạt động đồng thời, vùng người dùng không thể thực hiện
quyết định về thứ tự các sự việc sẽ xảy ra.

Ví dụ: nếu một luồng đơn sửa đổi một tệp và sau đó một tệp khác trong
trình tự, tệp thứ hai phải hiển thị thời gian bằng hoặc muộn hơn tệp đầu tiên. các
điều tương tự cũng đúng nếu hai luồng thực hiện các hoạt động tương tự không trùng nhau
đúng lúc.

Tuy nhiên, nếu hai luồng có các tòa nhà chồng chéo về thời gian thì sẽ có
không có sự đảm bảo nào như vậy và tệp thứ hai có thể đã được sửa đổi
trước, sau hay cùng thời điểm với lần đầu, bất kể là cái nào
nộp đầu tiên.

Lưu ý rằng điều trên giả định rằng hệ thống không gặp phải hiện tượng nhảy lùi
của đồng hồ thời gian thực. Nếu điều đó xảy ra vào thời điểm không thích hợp thì dấu thời gian
có thể bị lạc hậu, ngay cả trên một hệ thống hoạt động bình thường.

Triển khai dấu thời gian đa hạt
===================================
Dấu thời gian nhiều lớp nhằm mục đích đảm bảo rằng các thay đổi đối với một tệp duy nhất được
luôn có thể nhận biết được mà không vi phạm các đảm bảo đặt hàng khi nhiều
các tập tin khác nhau được sửa đổi. Điều này ảnh hưởng đến mtime và ctime, nhưng
atime sẽ luôn sử dụng dấu thời gian chi tiết.

Nó sử dụng một bit không được sử dụng trong trường i_ctime_nsec để cho biết liệu mtime
hoặc ctime đã được truy vấn. Nếu một trong hai hoặc cả hai đều có thì kernel sẽ lấy
đặc biệt cẩn thận để đảm bảo bản cập nhật dấu thời gian tiếp theo sẽ hiển thị thay đổi rõ ràng.
Điều này đảm bảo tính liên kết chặt chẽ của bộ đệm cho các trường hợp sử dụng như NFS mà không phải hy sinh
lợi ích của việc giảm cập nhật siêu dữ liệu khi không xem tệp.

Giá trị sàn Ctime
=====================
Sẽ không đủ nếu chỉ sử dụng dấu thời gian chi tiết hoặc chi tiết dựa trên
liệu mtime hay ctime đã được truy vấn hay chưa. Một tập tin có thể có được một chi tiết tốt
dấu thời gian và sau đó tệp thứ hai được sửa đổi sau đó có thể có được tệp thô
xuất hiện sớm hơn lần đầu tiên, điều này sẽ phá vỡ dấu thời gian của kernel
đảm bảo đặt hàng.

Để giảm thiểu vấn đề này, hãy duy trì giá trị sàn toàn cầu để đảm bảo rằng
điều này không thể xảy ra. Hai tập tin trong ví dụ trên có thể đã được
được sửa đổi cùng lúc trong trường hợp như vậy, nhưng chúng sẽ không bao giờ hiển thị ngược lại
đặt hàng. Để tránh các vấn đề về nhảy đồng hồ theo thời gian thực, sàn được quản lý như một
ktime_t đơn điệu và các giá trị được chuyển đổi thành giá trị đồng hồ thời gian thực dưới dạng
cần thiết.

Ghi chú thực hiện
====================
Dấu thời gian nhiều lớp được thiết kế để sử dụng bởi các hệ thống tệp cục bộ có
giá trị ctime từ đồng hồ địa phương. Điều này trái ngược với các hệ thống tập tin mạng
và những thứ tương tự chỉ phản ánh các giá trị dấu thời gian từ máy chủ.

Đối với hầu hết các hệ thống tập tin, chỉ cần đặt cờ FS_MGTIME trong
fstype->fs_flags để chọn tham gia, miễn là ctime chỉ được đặt qua
inode_set_ctime_current(). Nếu hệ thống tập tin có thói quen ->getattr
không gọi generic_fillattr thì nó sẽ gọi fill_mg_cmtime() tới
điền vào các giá trị đó. Đối với setattr, nó nên sử dụng setattr_copy() để cập nhật
dấu thời gian hoặc bắt chước hành vi của nó.