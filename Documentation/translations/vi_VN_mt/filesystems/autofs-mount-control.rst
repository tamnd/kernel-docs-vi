.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/autofs-mount-control.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================================
Các hoạt động điều khiển thiết bị khác cho mô-đun hạt nhân autofs
==========================================================================

vấn đề
===========

Đã xảy ra sự cố với hoạt động khởi động lại trong autofs (nghĩa là
khởi động lại autofs khi có quá trình gắn kết bận).

Trong quá trình hoạt động bình thường, autofs sử dụng bộ mô tả tệp được mở trên
thư mục đang được quản lý để có thể phát hành quyền kiểm soát
hoạt động. Việc sử dụng bộ mô tả tệp sẽ cho phép các hoạt động ioctl truy cập vào
autofs thông tin cụ thể được lưu trữ trong siêu khối. Các hoạt động
là những việc như cài đặt catatonic gắn kết autofs, cài đặt
hết thời gian chờ và yêu cầu kiểm tra hết hạn. Như được giải thích dưới đây,
một số loại gắn kết được kích hoạt tự động nhất định có thể sẽ bao phủ một tự động
mount chính nó, điều này ngăn cản chúng tôi có thể sử dụng open(2) để có được
bộ mô tả tệp cho các thao tác này nếu chúng tôi chưa mở.

Hiện tại autofs sử dụng "umount -l" (umount lười biếng) để xóa các mount đang hoạt động
lúc khởi động lại. Mặc dù việc sử dụng lười biếng umount có tác dụng với hầu hết các trường hợp, nhưng bất cứ điều gì
cần phải đi ngược lên cây gắn kết để xây dựng một con đường, chẳng hạn như
getcwd(2) và hệ thống tệp Proc/proc/<pid>/cwd, không còn hoạt động
bởi vì điểm mà đường dẫn được xây dựng đã bị tách ra
từ cây gắn kết.

Vấn đề thực sự với autofs là nó không thể kết nối lại với các thiết bị hiện có.
gắn kết. Ngay lập tức người ta nghĩ đến việc chỉ cần thêm khả năng kể lại
hệ thống tập tin autofs sẽ giải quyết được nó, nhưng than ôi, nó không thể hoạt động được. Đây là
bởi vì việc gắn kết trực tiếp của autofs và việc triển khai "gắn kết theo yêu cầu"
và hết hạn" của các cây gắn kết lồng nhau có hệ thống tệp được gắn trực tiếp
ở trên cùng của thư mục kích hoạt gắn kết.

Ví dụ: có hai loại bản đồ tự động đếm, trực tiếp (trong kernel
nguồn mô-đun, bạn sẽ thấy loại thứ ba được gọi là offset, đây chỉ là
thú cưỡi trực tiếp được ngụy trang) và gián tiếp.

Đây là bản đồ chính với các mục bản đồ trực tiếp và gián tiếp ::

/- /etc/auto.direct
    /test /etc/auto.indirect

và các tệp bản đồ tương ứng::

/etc/auto.direct:

/automount/dparse/g6 budgie:/autofs/export1
    /automount/dparse/g1 shark:/autofs/export1
    và vân vân.

/etc/auto.indirect::

cá mập g1:/autofs/export1
    g6 búp bê:/autofs/export1
    và vân vân.

Đối với bản đồ gián tiếp ở trên, hệ thống tệp autofs được gắn vào /test và
việc gắn kết được kích hoạt cho mỗi khóa thư mục con bằng cách tra cứu inode
hoạt động. Vì vậy, chúng ta thấy một con cá mập:/autofs/export1 trên /test/g1, cho
ví dụ.

Cách xử lý việc gắn kết trực tiếp là thực hiện việc gắn kết tự động trên
mỗi đường dẫn đầy đủ, chẳng hạn như /automount/dparse/g1 và sử dụng nó làm mount
kích hoạt. Vì vậy, khi chúng ta đi trên con đường, chúng ta sẽ gắn shark:/autofs/export1 "trên
đỉnh của điểm gắn kết này". Vì đây luôn là những thư mục nên chúng ta có thể
sử dụng thao tác inode follow_link để kích hoạt quá trình gắn kết.

Tuy nhiên, mỗi mục trong bản đồ trực tiếp và gián tiếp có thể có phần bù (làm cho
chúng có nhiều mục bản đồ gắn kết).

Ví dụ: mục nhập bản đồ gắn kết gián tiếp cũng có thể là::

g1 \
    / shark:/autofs/export5/testing/test \
    /s1 shark:/autofs/export/testing/test/s1 \
    /s2 shark:/autofs/export5/testing/test/s2 \
    /s1/ss1 shark:/autofs/export1 \
    /s2/ss2 cá mập:/autofs/export2

và một mục nhập bản đồ gắn kết trực tiếp tương tự cũng có thể là ::

/automount/dparse/g1 \
	/ shark:/autofs/export5/testing/test \
	/s1 shark:/autofs/export/testing/test/s1 \
	/s2 shark:/autofs/export5/testing/test/s2 \
	/s1/ss1 shark:/autofs/export2 \
	/s2/ss2 cá mập:/autofs/export2

Một trong những vấn đề với phiên bản 4 của autofs là khi gắn một
mục nhập có số lượng chênh lệch lớn, có thể có lồng nhau, chúng tôi cần
để gắn kết và bỏ qua tất cả các phần bù dưới dạng một đơn vị. Không thực sự là một
vấn đề, ngoại trừ những người có số lượng chênh lệch lớn trong các mục trên bản đồ.
Cơ chế này được sử dụng cho bản đồ "máy chủ" nổi tiếng và chúng tôi đã thấy
các trường hợp (trong 2.4) khi số lượng giá treo sẵn có đã hết hoặc
nơi mà số lượng cổng đặc quyền có sẵn đã cạn kiệt.

Trong phiên bản 5, chúng tôi chỉ gắn kết khi đi xuống cây bù trừ và
tương tự để hết hạn chúng để giải quyết vấn đề trên. có
chi tiết hơn một chút về việc triển khai nhưng nó không cần thiết cho
vì việc giải thích vấn đề. Một chi tiết quan trọng là những
việc bù đắp được thực hiện bằng cách sử dụng cơ chế tương tự như gắn kết trực tiếp
ở trên và do đó các điểm lắp có thể được bao phủ bởi một giá treo.

Việc triển khai autofs hiện tại sử dụng bộ mô tả tệp ioctl đã mở
trên điểm gắn kết cho các hoạt động điều khiển. Các tài liệu tham khảo được nắm giữ bởi
bộ mô tả được tính đến trong các lần kiểm tra được thực hiện để xác định xem giá treo có
đang được sử dụng và cũng được sử dụng để truy cập thông tin hệ thống tệp autofs được lưu giữ
trong siêu khối gắn kết. Vì vậy việc sử dụng một trình xử lý tập tin cần phải được
được giữ lại.


Giải pháp
============

Để có thể khởi động lại các autofs rời khỏi trực tiếp, gián tiếp và
các giá trị gắn kết bù đắp được đặt đúng chỗ, chúng ta cần có khả năng xử lý tệp
đối với những điểm gắn kết autofs có khả năng được bảo hiểm này. Thay vì chỉ
thực hiện một hoạt động biệt lập, nó đã được quyết định thực hiện lại
giao diện ioctl hiện có và thêm các hoạt động mới để cung cấp giao diện này
chức năng.

Ngoài ra, để có thể xây dựng lại cây gắn kết có các gắn kết bận rộn,
uid và gid của người dùng cuối cùng đã kích hoạt quá trình gắn kết cần phải là
có sẵn vì chúng có thể được sử dụng làm biến thay thế vĩ mô trong
bản đồ autofs. Chúng được ghi lại vào thời điểm yêu cầu gắn kết và một thao tác
đã được thêm vào để lấy chúng.

Vì chúng tôi đang triển khai lại giao diện điều khiển nên một số giao diện khác
các vấn đề với giao diện hiện tại đã được giải quyết. Đầu tiên, khi
thao tác gắn kết hoặc hết hạn hoàn tất, trạng thái được trả về
kernel bằng thao tác "sẵn sàng gửi" hoặc "gửi không thành công". các
Hoạt động "gửi lỗi" của giao diện ioctl chỉ có thể gửi
ENOENT nên việc triển khai lại cho phép người dùng có không gian gửi dữ liệu thực tế
trạng thái. Một hoạt động tốn kém khác trong không gian người dùng, dành cho những người sử dụng
bản đồ rất lớn, đang khám phá xem có thú cưỡi hay không. Thông thường điều này
liên quan đến việc quét /proc/mounts và vì nó cần phải được thực hiện khá nhiều
thường thì nó có thể gây ra chi phí đáng kể khi có nhiều mục
trong bảng gắn kết. Thao tác tra cứu trạng thái mount của mount
điểm nha khoa (được che phủ hoặc không) cũng đã được thêm vào.

Chính sách phát triển hạt nhân hiện tại khuyến nghị tránh sử dụng
cơ chế ioctl có lợi cho các hệ thống như Netlink. Một triển khai
việc sử dụng hệ thống này đã được cố gắng đánh giá sự phù hợp của nó và nó đã được
trong trường hợp này được cho là không đủ. Hệ thống Netlink chung là
được sử dụng cho mục đích này dưới dạng Netlink thô sẽ dẫn đến sự gia tăng đáng kể về
sự phức tạp. Không còn nghi ngờ gì nữa rằng hệ thống Netlink chung là một
giải pháp tao nhã cho các hàm ioctl trong trường hợp thông thường nhưng nó chưa hoàn chỉnh
sự thay thế có lẽ vì mục đích chính của nó trong cuộc sống là trở thành một
triển khai bus thông báo thay vì thay thế ioctl cụ thể.
Mặc dù có thể giải quyết vấn đề này nhưng có một mối lo ngại
dẫn đến quyết định không sử dụng nó. Đây là autofs
hết hạn trong daemon đã trở nên phức tạp vì umount
các ứng cử viên được liệt kê, hầu như không có lý do nào khác ngoài việc "đếm"
số lần gọi hết hạn ioctl. Điều này bao gồm việc quét
bàn gắn đã được chứng minh là một chi phí lớn đối với người dùng có
những bản đồ lớn. Cách tốt nhất để cải thiện điều này là thử quay lại
cách hết hạn đã được thực hiện từ lâu. Nghĩa là, khi một yêu cầu hết hạn được
được cấp cho một mount (xử lý tập tin), chúng ta nên liên tục gọi lại
daemon cho đến khi chúng ta không thể đếm được thêm thú cưỡi nào nữa, sau đó trả lại
trạng thái thích hợp cho daemon. Hiện tại chúng tôi vừa hết hạn một
gắn kết tại một thời điểm. Việc triển khai Netlink chung sẽ loại trừ điều này
khả năng phát triển trong tương lai do yêu cầu của
kiến trúc bus tin nhắn


autofs Linh tinh Giao diện điều khiển gắn thiết bị
====================================================

Giao diện điều khiển đang mở một nút thiết bị, thường là /dev/autofs.

Tất cả các ioctls đều sử dụng một cấu trúc chung để truyền tham số cần thiết
thông tin và trả về kết quả hoạt động::

cấu trúc autofs_dev_ioctl {
	    __u32 ver_major;
	    __u32 ver_minor;
	    __u32 kích thước;             /* tổng kích thước dữ liệu được truyền vào
				    * bao gồm cả cấu trúc này */
	    __s32 ioctlfd;          /* lệnh tự động đếm fd */

/* Tham số lệnh */
	    công đoàn {
		    struct args_protover protover;
		    struct args_protosubver protosubver;
		    struct args_openmount openmount;
		    struct args_ready đã sẵn sàng;
		    cấu trúc args_fail thất bại;
		    struct args_setpipefd setpipefd;
		    struct args_timeout hết thời gian chờ;
		    người yêu cầu struct args_requester;
		    struct args_expire hết hạn;
		    struct args_askumount yêu cầu;
		    struct args_ismountpoint ismountpoint;
	    };

đường dẫn char[];
    };

Trường ioctlfd là bộ mô tả tệp điểm gắn kết của mount autofs
điểm. Nó được trả về bởi cuộc gọi open và được sử dụng bởi tất cả các cuộc gọi ngoại trừ
kiểm tra xem một đường dẫn đã cho có phải là điểm gắn kết hay không, nơi nó có thể
tùy chọn được sử dụng để kiểm tra một giá treo cụ thể tương ứng với một giá trị nhất định
bộ mô tả tập tin điểm gắn kết và khi yêu cầu uid và gid của
lần gắn kết thành công cuối cùng vào một thư mục trong hệ thống tệp autofs.

Công đoàn được sử dụng để truyền đạt các thông số và kết quả của các cuộc gọi được thực hiện
như được mô tả dưới đây.

Trường đường dẫn được sử dụng để chuyển một đường dẫn cần thiết và trường kích thước
được sử dụng để tăng chiều dài cấu trúc khi dịch
cấu trúc được gửi từ không gian người dùng.

Cấu trúc này có thể được khởi tạo trước khi thiết lập các trường cụ thể bằng cách sử dụng
lệnh gọi hàm void init_autofs_dev_ioctl(ZZ0000ZZ).

Tất cả các ioctls thực hiện sao chép cấu trúc này từ không gian người dùng sang
không gian kernel và trả về -EINVAL nếu tham số kích thước nhỏ hơn
kích thước cấu trúc của chính nó, -ENOMEM nếu việc cấp phát bộ nhớ kernel không thành công
hoặc -EFAULT nếu bản sao chép bị lỗi. Các kiểm tra khác bao gồm kiểm tra phiên bản
của phiên bản không gian người dùng được biên dịch so với phiên bản mô-đun và
kết quả không khớp sẽ trả về -EINVAL. Nếu trường kích thước lớn hơn
kích thước cấu trúc thì một đường dẫn được coi là có mặt và được kiểm tra để
đảm bảo nó bắt đầu bằng "/" và NULL bị chấm dứt, nếu không thì -EINVAL là
đã quay trở lại. Thực hiện theo các bước kiểm tra này, đối với tất cả các lệnh ioctl ngoại trừ
AUTOFS_DEV_IOCTL_VERSION_CMD, AUTOFS_DEV_IOCTL_OPENMOUNT_CMD và
AUTOFS_DEV_IOCTL_CLOSEMOUNT_CMD thì ioctlfd đã được xác thực và nếu đúng như vậy
không phải là bộ mô tả hợp lệ hoặc không tương ứng với điểm gắn kết autofs
lỗi -EBADF, -ENOTTY hoặc -EINVAL (không phải là bộ mô tả autofs) là
đã quay trở lại.


các ioctls
==========

Có thể xem ví dụ về cách triển khai sử dụng giao diện này
trong autofs phiên bản 5.0.4 trở lên trong tệp lib/dev-ioctl-lib.c của
tar phân phối có sẵn để tải xuống từ kernel.org trong thư mục
/pub/linux/daemons/autofs/v5.

Các hoạt động ioctl của nút thiết bị được thực hiện bởi giao diện này là:


AUTOFS_DEV_IOCTL_VERSION
------------------------

Tải phiên bản chính và phụ của mô-đun hạt nhân ioctl của thiết bị autofs
thực hiện. Nó yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo như một
tham số đầu vào và đặt thông tin phiên bản trong cấu trúc được truyền vào.
Nó trả về 0 nếu thành công hoặc lỗi -EINVAL nếu phiên bản không khớp
được phát hiện.


AUTOFS_DEV_IOCTL_PROTOVER_CMD và AUTOFS_DEV_IOCTL_PROTOSUBVER_CMD
------------------------------------------------------------------

Hiểu phiên bản chính và phụ của phiên bản giao thức autofs
bởi mô-đun được tải. Cuộc gọi này yêu cầu cấu trúc khởi tạo autofs_dev_ioctl
với trường ioctlfd được đặt thành bộ mô tả điểm gắn kết autofs hợp lệ
và đặt số phiên bản được yêu cầu trong trường phiên bản của struct args_protover
hoặc trường sub_version của struct args_protosubver. Các lệnh này trả về
0 nếu thành công hoặc một trong các mã lỗi âm nếu xác thực không thành công.


AUTOFS_DEV_IOCTL_OPENMOUNT và AUTOFS_DEV_IOCTL_CLOSEMOUNT
----------------------------------------------------------

Lấy và phát hành bộ mô tả tệp cho điểm gắn kết được quản lý tự động
con đường. Cuộc gọi mở yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo với
trường đường dẫn được thiết lập và trường kích thước cũng được điều chỉnh phù hợp
là trường phân chia của struct args_openmount được đặt thành số thiết bị của
gắn kết autofs. Số thiết bị có thể được lấy từ các tùy chọn gắn kết
được hiển thị trong /proc/mounts. Cuộc gọi đóng yêu cầu cấu trúc khởi tạo
autofs_dev_ioct với trường ioctlfd được đặt thành bộ mô tả thu được
từ cuộc gọi mở. Việc phát hành bộ mô tả tập tin cũng có thể được thực hiện
bằng close(2) để mọi bộ mô tả mở cũng sẽ bị đóng khi thoát quá trình.
Cuộc gọi kết thúc được bao gồm trong các hoạt động được triển khai phần lớn dành cho
đầy đủ và cung cấp việc triển khai không gian người dùng nhất quán.


AUTOFS_DEV_IOCTL_READY_CMD và AUTOFS_DEV_IOCTL_FAIL_CMD
--------------------------------------------------------

Trả lại trạng thái kết quả gắn kết và hết hạn từ không gian người dùng đến kernel.
Cả hai lệnh gọi này đều yêu cầu khởi tạo struct autofs_dev_ioctl
với trường ioctlfd được đặt thành bộ mô tả thu được từ phần mở
gọi và trường mã thông báo của struct args_ready hoặc struct args_fail set
tới số mã thông báo hàng đợi chờ, được nhận bởi không gian người dùng ở trên
yêu cầu gắn kết hoặc hết hạn. Trường trạng thái của struct args_fail được đặt thành
lỗi của hoạt động. Nó được đặt thành 0 nếu thành công.


AUTOFS_DEV_IOCTL_SETPIPEFD_CMD
------------------------------

Đặt bộ mô tả tệp ống được sử dụng để liên lạc kernel với daemon.
Thông thường, điều này được đặt tại thời điểm gắn kết bằng một tùy chọn nhưng khi kết nối lại
đối với một mount hiện có, chúng ta cần sử dụng điều này để thông báo cho mount autofs về
bộ mô tả ống kernel mới. Để bảo vệ thú cưỡi khỏi
cài đặt không chính xác bộ mô tả đường ống, chúng tôi cũng yêu cầu các autofs
gắn kết được catatonic (xem cuộc gọi tiếp theo).

Cuộc gọi yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo với
trường ioctlfd được đặt thành bộ mô tả thu được từ lệnh gọi mở và
trường pipefd của struct args_setpipefd được đặt thành bộ mô tả của đường ống.
Khi thành công, cuộc gọi cũng đặt id nhóm quy trình được sử dụng để xác định
quy trình kiểm soát (ví dụ: daemon sở hữu automount(8)) cho quy trình
nhóm người gọi.


AUTOFS_DEV_IOCTL_CATATONIC_CMD
------------------------------

Làm cho điểm gắn kết của autofs trở nên catatonic. Việc gắn kết autofs sẽ không còn
đưa ra các yêu cầu gắn kết, bộ mô tả đường ống giao tiếp kernel được giải phóng
và bất kỳ sự chờ đợi nào còn lại trong hàng đợi được giải phóng.

Cuộc gọi yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo với
trường ioctlfd được đặt thành bộ mô tả thu được từ lệnh gọi mở.


AUTOFS_DEV_IOCTL_TIMEOUT_CMD
----------------------------

Đặt thời gian chờ hết hạn cho các lần gắn kết trong điểm gắn kết tự động.

Cuộc gọi yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo với
trường ioctlfd được đặt thành bộ mô tả thu được từ lệnh gọi mở.


AUTOFS_DEV_IOCTL_REQUESTER_CMD
------------------------------

Trả về uid và gid của quy trình cuối cùng để kích hoạt thành công
gắn kết vào đường dẫn nha khoa nhất định.

Cuộc gọi yêu cầu khởi tạo struct autofs_dev_ioctl với đường dẫn
trường được đặt thành điểm gắn kết được đề cập và trường kích thước được điều chỉnh
một cách thích hợp. Khi trả về trường uid của struct args_requester chứa
trường uid và gid gid.

Khi xây dựng lại cây gắn kết autofs với các giá trị gắn kết đang hoạt động, chúng ta cần phải
kết nối lại với các mount có thể đã sử dụng uid quy trình ban đầu và
gid (hoặc các biến thể chuỗi của chúng) để tra cứu gắn kết trong mục bản đồ.
Cuộc gọi này cung cấp khả năng lấy uid và gid này để chúng có thể
được sử dụng bởi không gian người dùng để tra cứu bản đồ gắn kết.


AUTOFS_DEV_IOCTL_EXPIRE_CMD
---------------------------

Đưa ra yêu cầu hết hạn tới kernel để gắn kết autofs. Thông thường
ioctl này được gọi cho đến khi không tìm thấy ứng viên nào hết hạn nữa.

Cuộc gọi yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo với
trường ioctlfd được đặt thành bộ mô tả thu được từ lệnh gọi mở. trong
ngoài ra, hết hạn ngay lập tức không phụ thuộc vào thời gian chờ gắn kết,
và buộc phải hết hạn, không phụ thuộc vào việc thú cưỡi có bận hay không,
có thể được yêu cầu bằng cách đặt trường cách thức của struct args_expire thành
AUTOFS_EXP_IMMEDIATE hoặc AUTOFS_EXP_FORCED tương ứng . Nếu không
có thể tìm thấy các ứng cử viên hết hạn, ioctl trả về -1 với errno được đặt thành
EAGAIN.

Cuộc gọi này khiến mô-đun hạt nhân kiểm tra mount tương ứng
tới ioctlfd đã cho đối với các mount có thể đã hết hạn, sẽ đưa ra thông báo hết hạn
yêu cầu quay lại daemon và chờ hoàn thành.

AUTOFS_DEV_IOCTL_ASKUMOUNT_CMD
------------------------------

Kiểm tra xem điểm gắn kết autofs có đang được sử dụng hay không.

Cuộc gọi yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo với
trường ioctlfd được đặt thành bộ mô tả thu được từ lệnh gọi mở và
nó trả về kết quả trong trường may_umount của struct args_askumount,
1 cho bận và 0 nếu không.


AUTOFS_DEV_IOCTL_ISMOUNTPOINT_CMD
---------------------------------

Kiểm tra xem đường dẫn đã cho có phải là điểm gắn kết hay không.

Cuộc gọi yêu cầu cấu trúc autofs_dev_ioctl được khởi tạo. Có hai
những biến thể có thể có. Cả hai đều sử dụng trường đường dẫn được đặt thành đường dẫn của mount
điểm để kiểm tra và điều chỉnh trường kích thước phù hợp. Một người sử dụng
trường ioctlfd để xác định một điểm gắn kết cụ thể để kiểm tra trong khi điểm gắn kết kia
biến thể sử dụng đường dẫn và trường in.type tùy chọn của struct args_ismountpoint
được đặt thành loại gắn kết autofs. Cuộc gọi trả về 1 nếu đây là điểm gắn kết
và đặt trường out.devid cho số thiết bị của mount và out.magic
trường vào số ma thuật siêu khối có liên quan (được mô tả bên dưới) hoặc 0 nếu
nó không phải là một điểm gắn kết. Trong cả hai trường hợp, số thiết bị (được trả về
bởi new_encode_dev()) được trả về trong trường out.devid.

Nếu được cung cấp bộ mô tả tệp, chúng tôi đang tìm kiếm một giá treo cụ thể,
không nhất thiết phải ở trên cùng của ngăn xếp được gắn. Trong trường hợp này đường dẫn
bộ mô tả tương ứng được coi là điểm gắn kết nếu nó là chính nó
một điểm gắn kết hoặc chứa một điểm gắn kết, chẳng hạn như một điểm gắn kết không có gốc
gắn kết. Trong trường hợp này, chúng tôi trả về 1 nếu bộ mô tả tương ứng với một giá trị gắn kết
điểm và cũng trả lại siêu ma thuật của thú cưỡi che phủ nếu có
là một hoặc 0 nếu nó không phải là điểm gắn kết.

Nếu một đường dẫn được cung cấp (và trường ioctlfd được đặt thành -1) thì đường dẫn đó
được tra cứu và kiểm tra xem nó có phải là gốc của mount hay không. Nếu một
loại cũng được cung cấp, chúng tôi đang tìm kiếm một mount autofs cụ thể và nếu
một trận đấu không được tìm thấy một thất bại được trả về. Nếu đường dẫn được định vị là
gốc của thú cưỡi 1 được trả về cùng với siêu năng lực của thú cưỡi
hoặc 0 nếu không.