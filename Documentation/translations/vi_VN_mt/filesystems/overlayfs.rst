.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/overlayfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Được viết bởi: Neil Brown
Vui lòng xem tệp MAINTAINERS để biết nơi gửi câu hỏi.

Hệ thống tập tin lớp phủ
========================

Tài liệu này mô tả một nguyên mẫu cho một cách tiếp cận mới để cung cấp
chức năng hệ thống tập tin lớp phủ trong Linux (đôi khi được gọi là
hệ thống tập tin liên minh).  Một hệ thống tập tin lớp phủ cố gắng trình bày một
hệ thống tập tin là kết quả của việc phủ một hệ thống tập tin lên trên
của người khác.


Lớp phủ đối tượng
-----------------

Cách tiếp cận hệ thống tập tin lớp phủ là 'hỗn hợp', bởi vì các đối tượng
xuất hiện trong hệ thống tập tin không phải lúc nào cũng có vẻ thuộc về hệ thống tập tin đó.
Trong nhiều trường hợp, một đối tượng được truy cập trong liên minh sẽ không thể phân biệt được
truy cập vào đối tượng tương ứng từ hệ thống tập tin gốc.
Điều này rõ ràng nhất từ ​​trường 'st_dev' được trả về bởi stat(2).

Mặc dù các thư mục sẽ báo cáo st_dev từ hệ thống tệp lớp phủ,
các đối tượng không phải thư mục có thể báo cáo st_dev từ hệ thống tệp thấp hơn hoặc
hệ thống tập tin phía trên đang cung cấp đối tượng.  Tương tự st_ino sẽ
chỉ duy nhất khi kết hợp với st_dev và cả hai đều có thể thay đổi
trong suốt vòng đời của một đối tượng không có thư mục.  Nhiều ứng dụng và
công cụ bỏ qua các giá trị này và sẽ không bị ảnh hưởng.

Trong trường hợp đặc biệt của tất cả các lớp phủ trên cùng một lớp bên dưới
hệ thống tập tin, tất cả các đối tượng sẽ báo cáo st_dev từ lớp phủ
hệ thống tập tin và st_ino từ hệ thống tập tin cơ bản.  Điều này sẽ
làm cho lớp phủ gắn kết phù hợp hơn với các trình quét hệ thống tập tin và
các đối tượng lớp phủ sẽ được phân biệt với các đối tượng tương ứng
các đối tượng trong hệ thống tập tin gốc.

Trên hệ thống 64bit, ngay cả khi tất cả các lớp phủ không giống nhau
hệ thống tập tin cơ bản, hành vi tuân thủ tương tự có thể đạt được
với tính năng "xino".  Tính năng "xino" tạo ra một đối tượng duy nhất
mã định danh từ đối tượng thực st_ino và số fsid cơ bản.
Tính năng "xino" sử dụng các bit có số inode cao cho fsid, bởi vì
hệ thống tập tin cơ bản hiếm khi sử dụng các bit số inode cao.  Trong trường hợp
số inode cơ bản tràn vào các bit xino cao, lớp phủ
hệ thống tập tin sẽ quay trở lại trạng thái non xino đối với inode đó.

Tính năng "xino" có thể được bật bằng tùy chọn gắn lớp phủ "-o xino=on".
Nếu tất cả các hệ thống tệp cơ bản đều hỗ trợ xử lý tệp NFS, giá trị của st_ino
đối với các đối tượng hệ thống tập tin lớp phủ không chỉ là duy nhất mà còn liên tục
thời gian tồn tại của hệ thống tập tin.  Tùy chọn gắn lớp phủ "-o xino=auto"
chỉ bật tính năng "xino" nếu đáp ứng được yêu cầu liên tục về st_ino.

Bảng sau đây tóm tắt những gì có thể mong đợi ở các lớp phủ khác nhau
cấu hình.

Thuộc tính nút
````````````````

+--------------+-------------+-------------+-------------------+-------+
ZZ0000ZZ Liên tục ZZ0001ZZ st_ino == d_ino ZZ0002ZZ
ZZ0003ZZ st_ino ZZ0004ZZ ZZ0005ZZ
+===============+======+=======+=====+====================================================+
ZZ0006ZZ địa chỉ ZZ0007ZZ địa chỉ ZZ0008ZZ địa chỉ ZZ0009ZZ địa chỉ ZZ0010ZZ
+--------------+------+------+------+------+--------+--------+--------+-------+
ZZ0011ZZ Y ZZ0012ZZ Y ZZ0013ZZ Y ZZ0014ZZ Y ZZ0015ZZ
ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ
+--------------+------+------+------+------+--------+--------+--------+-------+
ZZ0021ZZ N ZZ0022ZZ Y ZZ0023ZZ N ZZ0024ZZ N ZZ0025ZZ
ZZ0026ZZ ZZ0027ZZ ZZ0028ZZ ZZ0029ZZ ZZ0030ZZ
ZZ0031ZZ ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ ZZ0035ZZ
+--------------+------+------+------+------+--------+--------+--------+-------+
ZZ0036ZZ Y ZZ0037ZZ Y ZZ0038ZZ Y ZZ0039ZZ Y ZZ0040ZZ
+--------------+------+------+------+------+--------+--------+--------+-------+
ZZ0041ZZ N ZZ0042ZZ Y ZZ0043ZZ N ZZ0044ZZ N ZZ0045ZZ
ZZ0046ZZ ZZ0047ZZ ZZ0048ZZ ZZ0049ZZ ZZ0050ZZ
+--------------+------+------+------+------+--------+--------+--------+-------+

[*] nfsd v3 readdirplus xác minh d_ino == i_ino. i_ino được tiếp xúc thông qua một số
/proc các tệp, chẳng hạn như /proc/locks và /proc/self/fdinfo/<fd> của inotify
bộ mô tả tập tin.

Thượng và Hạ
---------------

Hệ thống tệp lớp phủ kết hợp hai hệ thống tệp - hệ thống tệp 'trên'
và một hệ thống tập tin 'thấp hơn'.  Khi một tên tồn tại trong cả hai hệ thống tập tin,
đối tượng trong hệ thống tập tin 'trên' được hiển thị trong khi đối tượng trong
hệ thống tập tin 'thấp hơn' bị ẩn hoặc, trong trường hợp thư mục,
được hợp nhất với đối tượng 'trên'.

Sẽ đúng hơn nếu đề cập đến thư mục trên và dưới
cây' thay vì 'hệ thống tập tin' vì cả hai đều có thể
cây thư mục nằm trong cùng một hệ thống tập tin và không có
yêu cầu gốc của hệ thống tập tin phải được cấp cho chữ hoa hoặc chữ hoa
thấp hơn.

Một loạt các hệ thống tập tin được Linux hỗ trợ có thể là hệ thống tập tin cấp thấp hơn,
nhưng không phải tất cả các hệ thống tập tin mà Linux có thể gắn kết đều có các tính năng
cần thiết để OverlayFS hoạt động.  Hệ thống tập tin thấp hơn không cần phải có
có thể ghi được.  Hệ thống tập tin thấp hơn thậm chí có thể là một lớp phủ khác.  Phần trên
hệ thống tập tin thường có thể ghi được và nếu có thì nó phải hỗ trợ
tạo các thuộc tính mở rộng đáng tin cậy.* và/hoặc user.* và phải cung cấp
d_type hợp lệ trong phản hồi readdir, vì vậy NFS không phù hợp.

Lớp phủ chỉ đọc của hai hệ thống tệp chỉ đọc có thể sử dụng bất kỳ
loại hệ thống tập tin.

Thư mục
-----------

Lớp phủ chủ yếu liên quan đến các thư mục.  Nếu một tên cụ thể xuất hiện trong cả hai
hệ thống tập tin trên và dưới và đề cập đến một thư mục không phải trong một trong hai,
sau đó đối tượng phía dưới bị ẩn - tên chỉ đề cập đến đối tượng phía trên
đối tượng.

Trong đó cả đối tượng trên và đối tượng dưới đều là thư mục, một thư mục được hợp nhất
được hình thành.

Tại thời điểm gắn kết, hai thư mục được cung cấp dưới dạng tùy chọn gắn kết "lowdir" và
"upperdir" được kết hợp thành một thư mục được hợp nhất ::

mount -t lớp phủ lớp phủ -owerdir=/lower,upperdir=/upper,\
  workdir=/work/đã sáp nhập

"Workdir" cần phải là một thư mục trống trên cùng một hệ thống tập tin
như thư mục trên.

Sau đó, bất cứ khi nào việc tra cứu được yêu cầu trong một thư mục được hợp nhất như vậy,
việc tra cứu được thực hiện trong từng thư mục thực tế và kết quả tổng hợp
được lưu trữ trong nha khoa thuộc hệ thống tập tin lớp phủ.  Nếu cả hai
tra cứu thực tế tìm thấy các thư mục, cả hai đều được lưu trữ và hợp nhất
thư mục được tạo, nếu không thì chỉ có một thư mục được lưu trữ: phần trên nếu nó
tồn tại, nếu không thì thấp hơn.

Chỉ danh sách tên từ các thư mục mới được hợp nhất.  Nội dung khác
chẳng hạn như siêu dữ liệu và thuộc tính mở rộng được báo cáo cho cấp trên
chỉ thư mục.  Các thuộc tính của thư mục phía dưới bị ẩn.

thư mục trắng và mờ đục
--------------------------------

Để hỗ trợ rm và rmdir mà không thay đổi phần dưới
hệ thống tập tin, một hệ thống tập tin lớp phủ cần ghi vào hệ thống tập tin phía trên
các tập tin đó đã bị xóa.  Điều này được thực hiện bằng cách sử dụng khoảng trắng và mờ
thư mục (không phải thư mục luôn mờ đục).

Khoảng trắng được tạo dưới dạng thiết bị ký tự có số thiết bị 0/0 hoặc
dưới dạng tệp thông thường có kích thước bằng 0 với xattr "trusted.overlay.whiteout".

Khi tìm thấy khoảng trắng ở cấp trên của thư mục đã hợp nhất, bất kỳ
tên phù hợp ở cấp độ thấp hơn bị bỏ qua và bản thân việc xóa trắng
cũng bị ẩn đi.

Một thư mục được làm mờ bằng cách đặt xattr "trusted.overlay.opaque"
đến "y".  Trong đó hệ thống tập tin phía trên chứa một thư mục không rõ ràng, bất kỳ
thư mục trong hệ thống tập tin thấp hơn có cùng tên sẽ bị bỏ qua.

Một thư mục không rõ ràng không được chứa bất kỳ phần trắng nào vì chúng không
phục vụ bất kỳ mục đích nào.  Một thư mục hợp nhất chứa các tệp thông thường với xattr
"trusted.overlay.whiteout", phải được đánh dấu bổ sung bằng cách đặt xattr
"trusted.overlay.opaque" thành "x" trên chính thư mục hợp nhất.
Điều này là cần thiết để tránh việc kiểm tra "trusted.overlay.whiteout"
trên tất cả các mục trong readdir trong trường hợp phổ biến.

thư mục đọc
-----------

Khi yêu cầu 'readdir' được thực hiện trên một thư mục đã hợp nhất, phần trên và
mỗi thư mục thấp hơn sẽ được đọc và danh sách tên được hợp nhất trong
cách rõ ràng (phần trên được đọc trước, sau đó được đọc dưới - các mục đã có
tồn tại không được thêm lại).  Danh sách tên đã hợp nhất này được lưu trữ trong
'tệp cấu trúc' và do đó vẫn tồn tại miễn là tệp được giữ mở.  Nếu
thư mục được mở và đọc bởi hai tiến trình cùng một lúc, chúng
mỗi cái sẽ có bộ đệm riêng.  Một seekdir để bắt đầu
thư mục (offset 0) theo sau là readdir sẽ khiến bộ đệm bị lỗi
bỏ đi và xây dựng lại.

Điều này có nghĩa là những thay đổi đối với thư mục đã hợp nhất sẽ không xuất hiện trong khi
thư mục đang được đọc.  Điều này có lẽ sẽ không được nhiều người chú ý
các chương trình.

tìm kiếm offset được chỉ định tuần tự khi các thư mục được đọc.
Như vậy nếu:

- đọc một phần của thư mục
 - nhớ một phần bù và đóng thư mục
 - một thời gian sau mở lại thư mục
 - tìm kiếm phần bù được ghi nhớ

có thể có rất ít mối tương quan giữa vị trí cũ và vị trí mới trong
danh sách tên tập tin, đặc biệt nếu có bất cứ điều gì thay đổi trong
thư mục.

Readdir trên các thư mục chưa được hợp nhất sẽ được xử lý đơn giản bởi
thư mục cơ bản (trên hoặc dưới).

đổi tên thư mục
--------------------

Khi đổi tên một thư mục ở lớp dưới hoặc được hợp nhất (tức là thư mục
thư mục không được tạo ở lớp trên để bắt đầu) lớp phủ có thể
xử lý nó theo hai cách khác nhau:

1. trả về lỗi EXDEV: lỗi này được trả về bằng cách đổi tên(2) khi cố gắng
   di chuyển một tập tin hoặc thư mục qua ranh giới hệ thống tập tin.  Do đó
   các ứng dụng thường được chuẩn bị để xử lý lỗi này (ví dụ mv(1)
   sao chép đệ quy cây thư mục).  Đây là hành vi mặc định.

2. Nếu tính năng "redirect_dir" được bật thì thư mục sẽ được
   sao chép lên (nhưng không phải nội dung).  Sau đó là "trust.overlay.redirect"
   thuộc tính mở rộng được đặt thành đường dẫn của vị trí ban đầu từ
   gốc của lớp phủ.  Cuối cùng thư mục được chuyển sang mới
   vị trí.

Có một số cách để điều chỉnh tính năng "redirect_dir".

Tùy chọn cấu hình hạt nhân:

-OVERLAY_FS_REDIRECT_DIR:
    Nếu tính năng này được bật thì redirect_dir được bật theo mặc định.
-OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW:
    Nếu tính năng này được bật thì các chuyển hướng luôn được tuân theo theo mặc định. Kích hoạt
    điều này dẫn đến một cấu hình kém an toàn hơn.  Chỉ bật tùy chọn này khi
    lo lắng về khả năng tương thích ngược với các hạt nhân có redirect_dir
    tính năng và theo dõi các chuyển hướng ngay cả khi bị tắt.

Tùy chọn mô-đun (cũng có thể được thay đổi thông qua /sys/module/overlay/parameters/):

- "redirect_dir=BOOL":
    Xem tùy chọn cấu hình kernel OVERLAY_FS_REDIRECT_DIR ở trên.
- "redirect_always_follow=BOOL":
    Xem tùy chọn cấu hình kernel OVERLAY_FS_REDIRECT_ALWAYS_FOLLOW ở trên.
- "redirect_max=NUM":
    Số byte tối đa trong một chuyển hướng tuyệt đối (mặc định là 256).

Tùy chọn gắn kết:

- "redirect_dir=bật":
    Chuyển hướng được kích hoạt.
- "redirect_dir=follow":
    Chuyển hướng không được tạo ra, nhưng theo sau.
- "redirect_dir=nofollow":
    Chuyển hướng không được tạo và không được theo dõi.
- "redirect_dir=tắt":
    Nếu "redirect_always_follow" được bật trong cấu hình kernel/module,
    "Tắt" này có nghĩa là "theo dõi", nếu không nó sẽ có nghĩa là "nofollow".

Khi tính năng xuất NFS được bật, mọi thư mục được sao chép sẽ được
được lập chỉ mục bởi phần xử lý tệp của nút dưới và phần xử lý tệp của
thư mục phía trên được lưu trữ trong thuộc tính mở rộng "trusted.overlay.upper"
trên mục nhập chỉ mục.  Khi tra cứu một thư mục đã hợp nhất, nếu phần trên
thư mục không khớp với phần lưu trữ xử lý tệp trong chỉ mục, đó là một
dấu hiệu cho thấy nhiều thư mục phía trên có thể được chuyển hướng đến cùng một
thư mục thấp hơn.  Trong trường hợp đó, việc tra cứu sẽ trả về lỗi và cảnh báo về
một sự không nhất quán có thể xảy ra.

Bởi vì các chuyển hướng lớp thấp hơn không thể được xác minh bằng chỉ mục, cho phép
Hỗ trợ xuất NFS trên hệ thống tệp lớp phủ không yêu cầu lớp trên
tắt tính năng theo dõi chuyển hướng (ví dụ: "redirect_dir=nofollow").


Không có thư mục
----------------

Các đối tượng không phải là thư mục (tệp, liên kết tượng trưng, ​​thiết bị đặc biệt)
các tập tin, v.v.) được trình bày từ hệ thống tập tin trên hoặc dưới dưới dạng
thích hợp.  Khi một tập tin trong hệ thống tập tin thấp hơn được truy cập theo cách
yêu cầu quyền truy cập ghi, chẳng hạn như mở để truy cập ghi, thay đổi
một số siêu dữ liệu, v.v., tệp được sao chép lần đầu tiên từ hệ thống tệp thấp hơn
đến hệ thống tập tin phía trên (copy_up).  Lưu ý rằng việc tạo liên kết cứng
cũng yêu cầu copy_up, mặc dù tất nhiên việc tạo một liên kết tượng trưng cũng cần
không.

copy_up có thể trở nên không cần thiết, ví dụ như nếu tập tin
được mở để đọc-ghi nhưng dữ liệu không được sửa đổi.

Quá trình copy_up trước tiên đảm bảo rằng thư mục chứa
tồn tại trong hệ thống tập tin phía trên - việc tạo nó và bất kỳ tập tin gốc nào cũng như
cần thiết.  Sau đó, nó tạo đối tượng có cùng siêu dữ liệu (chủ sở hữu,
mode, mtime, symlink-target, v.v.) và sau đó nếu đối tượng là một tệp, thì
dữ liệu được sao chép từ hệ thống tập tin dưới lên trên.  Cuối cùng bất kỳ
thuộc tính mở rộng được sao chép lên.

Sau khi copy_up hoàn tất, hệ thống tập tin lớp phủ chỉ cần
cung cấp quyền truy cập trực tiếp vào tệp mới được tạo ở phía trên
hệ thống tập tin - các hoạt động trong tương lai trên tập tin hầu như không được chú ý bởi
hệ thống tập tin lớp phủ (mặc dù một thao tác trên tên của tập tin chẳng hạn như
đổi tên hoặc hủy liên kết tất nhiên sẽ được chú ý và xử lý).


Mô hình quyền
----------------

Hệ thống tập tin lớp phủ lưu trữ thông tin xác thực sẽ được sử dụng khi
truy cập các hệ thống tập tin thấp hơn hoặc cao hơn.

Trong api gắn kết cũ, thông tin xác thực của nhiệm vụ gọi mount(2) là
được cất giấu. Trong api gắn kết mới, thông tin xác thực của tác vụ tạo
siêu khối thông qua lệnh FSCONFIG_CMD_CREATE của fsconfig(2) là
được cất giấu.

Bắt đầu với kernel v6.15, có thể sử dụng "override_creds"
tùy chọn gắn kết sẽ khiến thông tin xác thực của tác vụ gọi điện bị
được ghi lại. Lưu ý rằng "override_creds" chỉ có ý nghĩa khi được sử dụng với
api gắn kết mới vì api gắn kết cũ kết hợp các tùy chọn cài đặt và
tạo siêu khối trong một tòa nhà cao tầng mount(2).

Việc kiểm tra quyền trong hệ thống tệp lớp phủ tuân theo các nguyên tắc sau:

1) kiểm tra quyền SHOULD trả về kết quả tương tự trước và sau khi sao chép

2) tác vụ tạo lớp phủ gắn MUST NOT có được các đặc quyền bổ sung

3) nhiệm vụ[*] MAY nhận được các đặc quyền bổ sung thông qua lớp phủ,
    so với truy cập trực tiếp trên các hệ thống tập tin cấp dưới hoặc cấp trên

Điều này đạt được bằng cách thực hiện hai lần kiểm tra quyền trên mỗi lần truy cập:

a) kiểm tra xem tác vụ hiện tại có được phép truy cập hay không dựa trên DAC cục bộ (chủ sở hữu,
    nhóm, chế độ và posix acl), cũng như kiểm tra MAC

b) kiểm tra xem thông tin xác thực được lưu trữ có được phép hoạt động thực sự ở mức thấp hơn hay không
    lớp trên dựa trên các quyền của hệ thống tập tin cơ bản, một lần nữa bao gồm
    Kiểm tra MAC

Kiểm tra (a) đảm bảo tính nhất quán (1) vì chủ sở hữu, nhóm, chế độ và acl posix
được sao chép lên.  Mặt khác, nó có thể dẫn đến việc máy chủ bị ép buộc
các quyền (ví dụ được sử dụng bởi NFS) bị bỏ qua (3).

Kiểm tra (b) đảm bảo rằng không có tác vụ nào giành được quyền đối với các lớp bên dưới
thông tin đăng nhập được lưu trữ không có (2).  Điều này cũng có nghĩa là có thể
để tạo các thiết lập trong đó quy tắc nhất quán (1) không giữ được; bình thường,
tuy nhiên, thông tin xác thực được lưu trữ sẽ có đủ đặc quyền để
thực hiện mọi thao tác.

Một cách khác để chứng minh mô hình này là vẽ sự tương đồng giữa::

mount -t lớp phủ lớp phủ -owerdir=/low,upperdir=/upper,... /merged

Và::

cp -a/dưới/trên
  mount --bind /upper /merged

Các quyền truy cập kết quả phải giống nhau.  Sự khác biệt là ở
thời điểm sao chép (theo yêu cầu so với trả trước).


Nhiều lớp thấp hơn
---------------------

Hiện tại, nhiều lớp thấp hơn có thể được cung cấp bằng cách sử dụng dấu hai chấm (: //) làm
ký tự phân cách giữa các tên thư mục.  Ví dụ::

mount -t lớp phủ lớp phủ -owerdir=/low1:/low2:/low3 /merged

Như ví dụ cho thấy, "upperdir=" và "workdir=" có thể bị bỏ qua.  trong
trường hợp đó lớp phủ sẽ ở chế độ chỉ đọc.

Các thư mục thấp hơn được chỉ định sẽ được xếp chồng lên nhau bắt đầu từ
ngoài cùng bên phải và đi sang trái.  Trong ví dụ trên, low1 sẽ là
trên cùng, Lower2 ở giữa và Lower3 ở lớp dưới cùng.

Lưu ý: tên thư mục chứa dấu hai chấm có thể được cung cấp ở lớp thấp hơn bằng cách
thoát khỏi dấu hai chấm bằng một dấu gạch chéo ngược.  Ví dụ::

mount -t lớp phủ lớp phủ -owerdir=/a\:low\:\:dir /merged

Kể từ phiên bản kernel v6.8, tên thư mục chứa dấu hai chấm cũng có thể
được cấu hình ở lớp thấp hơn bằng cách sử dụng các tùy chọn gắn kết "lowdir+" và
fsconfig syscall từ api gắn kết mới.  Ví dụ::

fsconfig(fs_fd, FSCONFIG_SET_STRING, "lowdir+", "/a:low::dir", 0);

Trong trường hợp sau, dấu hai chấm trong tên thư mục lớp thấp hơn sẽ bị thoát
dưới dạng ký tự bát phân (\072) khi được hiển thị trong /proc/self/mountinfo.

Siêu dữ liệu chỉ sao chép lên
-----------------------------

Khi tính năng "siêu sao chép" được bật, lớp phủ sẽ chỉ sao chép
lên siêu dữ liệu (ngược lại với toàn bộ tệp), khi một thao tác cụ thể về siêu dữ liệu
như chown/chmod được thực hiện. Một tập tin phía trên ở trạng thái này được đánh dấu bằng
"trusted.overlayfs.metacopy" xattr cho biết rằng tệp phía trên
không chứa dữ liệu.  Dữ liệu sẽ được sao chép sau khi tập tin được mở
Hoạt động WRITE.  Sau khi dữ liệu của tập tin thấp hơn được sao chép lên,
xattr "trusted.overlayfs.metacopy" bị xóa khỏi tệp phía trên.

Nói cách khác, đây là thao tác sao chép dữ liệu bị trì hoãn và dữ liệu được sao chép
lên khi có nhu cầu thực sự sửa đổi dữ liệu.

Có nhiều cách để bật/tắt tính năng này. Một tùy chọn cấu hình
CONFIG_OVERLAY_FS_METACOPY có thể được đặt/bỏ đặt để bật/tắt tính năng này
theo mặc định. Hoặc người ta có thể bật/tắt nó khi tải mô-đun bằng module
tham số metacopy=bật/tắt. Cuối cùng, cũng có tùy chọn cho mỗi lần gắn kết
metacopy=on/off để bật/tắt tính năng này cho mỗi lần gắn kết.

Không sử dụng metacopy=on với các thư mục trên/dưới không đáng tin cậy. Nếu không
có thể kẻ tấn công có thể tạo một tệp thủ công với
các xattr REDIRECT và METACOPY thích hợp và có quyền truy cập vào tệp ở mức thấp hơn
được chỉ bởi REDIRECT. Điều này không thể thực hiện được trên hệ thống cục bộ vì cài đặt
"đáng tin cậy." xattrs sẽ yêu cầu CAP_SYS_ADMIN. Nhưng nó phải có thể
đối với các lớp không đáng tin cậy như từ ổ đĩa bút.

Lưu ý: redirect_dir={off|nofollow|follow[*]} và nfs_export=on tùy chọn gắn kết
xung đột với metacopy=on và sẽ dẫn đến lỗi.

[*] redirect_dir=follow chỉ xung đột với metacopy=on nếu Upperdir=... là
đã cho.


Các lớp thấp hơn chỉ có dữ liệu
-------------------------------

Khi tính năng "siêu sao chép" được bật, tệp thông thường của lớp phủ có thể là một thành phần
thông tin từ tối đa ba lớp khác nhau:

1) siêu dữ liệu từ một tệp ở lớp trên

2) định danh đối tượng st_ino và st_dev từ một tệp ở lớp thấp hơn

3) dữ liệu từ một tệp ở lớp thấp hơn khác (bên dưới)

Tệp "dữ liệu thấp hơn" có thể ở bất kỳ lớp nào bên dưới, ngoại trừ ở lớp trên cùng.
lớp dưới.

Bên dưới lớp trên cùng thấp hơn, có thể xác định số lượng lớp dưới cùng bất kỳ
làm lớp thấp hơn "chỉ dữ liệu", sử dụng dấu phân cách hai dấu hai chấm ("::").
Lớp thấp hơn bình thường không được phép ở dưới lớp chỉ có dữ liệu, vì vậy một lớp
dấu phân cách dấu hai chấm không được phép ở bên phải dấu phân cách hai dấu hai chấm ("::").


Ví dụ::

mount -t lớp phủ lớp phủ -owerdir=/l1:/l2:/l3::/do1::/do2 /merged

Đường dẫn của các tệp trong các lớp thấp hơn "chỉ dữ liệu" không hiển thị trong
các thư mục lớp phủ đã hợp nhất và siêu dữ liệu cũng như st_ino/st_dev của các tệp
trong các lớp thấp hơn "chỉ dữ liệu" không hiển thị trong các nút lớp phủ.

Chỉ có thể hiển thị dữ liệu của các tệp ở các lớp thấp hơn "chỉ dữ liệu"
khi một tệp "siêu sao chép" ở một trong các lớp thấp hơn phía trên nó có "chuyển hướng"
đến đường dẫn tuyệt đối của tệp "dữ liệu thấp hơn" ở lớp bên dưới "chỉ dữ liệu".

Thay vì bật "metacopy=on" một cách rõ ràng, chỉ cần chỉ định tại
ít nhất một lớp chỉ có dữ liệu để cho phép chuyển hướng dữ liệu sang lớp chỉ có dữ liệu.
Trong trường hợp này, các hình thức siêu sao khác đều bị từ chối.  Lưu ý: theo cách này, chỉ có dữ liệu
các lớp có thể được sử dụng cùng với "userxattr", trong trường hợp đó hãy chú ý cẩn thận
phải được cấp các đặc quyền cần thiết để thay đổi xattr "user.overlay.redirect"
để ngăn chặn việc sử dụng sai mục đích.

Kể từ phiên bản kernel v6.8, các lớp thấp hơn "chỉ dữ liệu" cũng có thể được thêm bằng cách sử dụng
các tùy chọn gắn kết "datadir+" và tòa nhà fsconfig từ api gắn kết mới.
Ví dụ::

fsconfig(fs_fd, FSCONFIG_SET_STRING, "lowdir+", "/l1", 0);
  fsconfig(fs_fd, FSCONFIG_SET_STRING, "lowdir+", "/l2", 0);
  fsconfig(fs_fd, FSCONFIG_SET_STRING, "lowdir+", "/l3", 0);
  fsconfig(fs_fd, FSCONFIG_SET_STRING, "datadir+", "/do1", 0);
  fsconfig(fs_fd, FSCONFIG_SET_STRING, "datadir+", "/do2", 0);


Chỉ định các lớp thông qua bộ mô tả tệp
---------------------------------------

Kể từ kernel v6.13, lớp phủ hỗ trợ chỉ định các lớp thông qua bộ mô tả tệp trong
ngoài việc chỉ định chúng là đường dẫn. Tính năng này có sẵn cho
Các tùy chọn gắn kết "datadir+", "lowdir+", "upperdir" và "workdir+" với
fsconfig syscall từ api gắn kết mới ::

fsconfig(fs_fd, FSCONFIG_SET_FD, "lowdir+", NULL, fd_low1);
  fsconfig(fs_fd, FSCONFIG_SET_FD, "lowdir+", NULL, fd_low2);
  fsconfig(fs_fd, FSCONFIG_SET_FD, "lowdir+", NULL, fd_low3);
  fsconfig(fs_fd, FSCONFIG_SET_FD, "datadir+", NULL, fd_data1);
  fsconfig(fs_fd, FSCONFIG_SET_FD, "datadir+", NULL, fd_data2);
  fsconfig(fs_fd, FSCONFIG_SET_FD, "workdir", NULL, fd_work);
  fsconfig(fs_fd, FSCONFIG_SET_FD, "upperdir", NULL, fd_upper);


hỗ trợ fs-verity
-----------------

Trong quá trình sao chép siêu dữ liệu của tệp thấp hơn, nếu tệp nguồn có
đã bật fs-verity và hỗ trợ xác thực lớp phủ được bật, thì
thông báo của tệp bên dưới được thêm vào "trust.overlay.metacopy"
xattr. Điều này sau đó được sử dụng để xác minh nội dung của tệp thấp hơn
mỗi lần tệp metacopy được mở.

Khi một lớp chứa xác thực xattrs được sử dụng, điều đó có nghĩa là bất kỳ lớp nào như vậy
tệp metacopy ở lớp trên được đảm bảo khớp với nội dung
đó là mức thấp hơn tại thời điểm sao chép. Nếu bất cứ lúc nào
(trong quá trình gắn kết, sau khi kết nối lại, v.v.) một tệp như vậy ở phía dưới là
được thay thế hoặc sửa đổi theo bất kỳ cách nào, truy cập vào tệp tương ứng trong
lớp phủ sẽ dẫn đến lỗi EIO (khi mở, do lớp phủ
kiểm tra tóm tắt hoặc từ lần đọc sau do fs-verity) và chi tiết
lỗi được in vào nhật ký kernel. Để biết thêm chi tiết về cách fs-verity
truy cập tệp hoạt động, xem ZZ0000ZZ.

Tính xác thực có thể được sử dụng như một biện pháp kiểm tra độ tin cậy chung để phát hiện các sự cố ngẫu nhiên
những thay đổi trong thư mục lớp phủ đang sử dụng. Tuy nhiên, với sự cẩn thận bổ sung
nó cũng có thể đưa ra những đảm bảo mạnh mẽ hơn. Ví dụ, nếu phần trên
lớp được tin cậy hoàn toàn (bằng cách sử dụng dm-verity hoặc thứ gì đó tương tự), sau đó
lớp dưới không đáng tin cậy có thể được sử dụng để cung cấp nội dung tệp được xác thực
cho tất cả các tập tin metacopy.  Nếu thêm vào đó, mức thấp hơn không đáng tin cậy
các thư mục được chỉ định là "Chỉ dữ liệu", thì chúng chỉ có thể cung cấp
nội dung tệp như vậy và toàn bộ giá trị gắn kết có thể được tin cậy để khớp với
lớp trên.

Tính năng này được điều khiển bởi tùy chọn gắn kết "verity", tùy chọn này
hỗ trợ các giá trị này:

- “tắt”:
    Thông báo metacopy không bao giờ được tạo hoặc sử dụng. Đây là
    mặc định nếu tùy chọn xác thực không được chỉ định.
- "bật":
    Bất cứ khi nào một tệp siêu sao chỉ định một bản tóm tắt dự kiến,
    tệp dữ liệu tương ứng phải khớp với thông báo đã chỉ định. Khi nào
    tạo một tệp metacopy, bản tóm tắt xác thực sẽ được đặt trong đó
    dựa trên tệp nguồn (nếu có).
- “yêu cầu”:
    Tương tự như "bật", nhưng ngoài ra tất cả các tệp metacopy phải chỉ định một
    thông báo (hoặc EIO được trả về khi mở). Điều này có nghĩa là sao chép siêu dữ liệu
    sẽ chỉ được sử dụng nếu tệp dữ liệu đã bật fs-verity,
    nếu không thì bản sao đầy đủ sẽ được sử dụng.

Chia sẻ và sao chép các lớp
---------------------------

Các lớp thấp hơn có thể được chia sẻ giữa một số lớp phủ và điều đó thực sự là
một thực tế rất phổ biến.  Một lớp phủ gắn kết có thể sử dụng cùng một lớp thấp hơn
đường dẫn như một lớp phủ khác và nó có thể sử dụng đường dẫn lớp thấp hơn
bên dưới hoặc phía trên đường dẫn của một đường dẫn lớp thấp hơn khác.

Sử dụng đường dẫn lớp trên và/hoặc đường dẫn công việc đã được sử dụng bởi
một lớp phủ khác không được phép và có thể bị lỗi với EBUSY.  sử dụng
các đường dẫn chồng chéo một phần không được phép và có thể bị lỗi với EBUSY.
Nếu các tập tin được truy cập từ hai lớp phủ gắn kết chia sẻ hoặc chồng lên nhau
lớp trên và/hoặc đường dẫn công việc, hoạt động của lớp phủ không được xác định,
mặc dù nó sẽ không dẫn đến sự cố hoặc bế tắc.

Gắn lớp phủ bằng đường dẫn lớp trên, trong đó đường dẫn lớp trên
trước đây đã được sử dụng bởi một lớp phủ được gắn kết khác kết hợp với
được phép có đường dẫn lớp thấp hơn khác, trừ khi "chỉ mục" hoặc "siêu sao"
các tính năng được kích hoạt.

Với tính năng "chỉ mục", trong lần gắn kết đầu tiên, tệp NFS
xử lý thư mục gốc của lớp dưới, cùng với UUID của lớp dưới
hệ thống tập tin, được mã hóa và lưu trữ trong phần mở rộng "trust.overlay.origin"
thuộc tính trên thư mục gốc lớp trên.  Trong những lần thử gắn kết tiếp theo,
phần xử lý tệp thư mục gốc thấp hơn và hệ thống tệp thấp hơn UUID được so sánh
đến nguồn gốc được lưu trữ trong thư mục gốc phía trên.  Về việc không xác minh được
nguồn gốc gốc thấp hơn, việc gắn kết sẽ thất bại với ESTALE.  Một lớp phủ gắn kết với
"Chỉ mục" được bật sẽ không thành công với EOPNOTSUPP nếu hệ thống tệp thấp hơn
không hỗ trợ xuất NFS, hệ thống tệp thấp hơn không có UUID hợp lệ hoặc
nếu hệ thống tập tin phía trên không hỗ trợ các thuộc tính mở rộng.

Đối với tính năng "metacopy", không có cơ chế xác minh tại
thời gian gắn kết. Vì vậy, nếu cùng một phần trên được gắn với bộ phần dưới khác nhau, hãy gắn
có lẽ sẽ thành công nhưng mong đợi điều bất ngờ sau này. Vì vậy, đừng làm điều đó.

Thực tế khá phổ biến là sao chép các lớp phủ sang một lớp khác
cây thư mục trên cùng một hệ thống tập tin cơ bản hoặc khác nhau và thậm chí
sang máy khác.  Với tính năng "chỉ mục", cố gắng gắn kết
các lớp được sao chép sẽ không thể xác minh được phần xử lý tệp gốc thấp hơn.

Gắn kết lớp phủ lồng nhau
-------------------------

Có thể sử dụng thư mục thấp hơn được lưu trữ trên lớp phủ
gắn kết. Đối với các tập tin thông thường, điều này không cần bất kỳ sự chăm sóc đặc biệt nào. Tuy nhiên, các tập tin
có các thuộc tính lớp phủ, chẳng hạn như khoảng trắng hoặc "overlay.*" xattr, sẽ
được diễn giải bằng cách gắn kết lớp phủ bên dưới và loại bỏ. để
cho phép mount lớp phủ thứ hai xem các thuộc tính mà chúng phải được thoát.

Các xattr cụ thể của lớp phủ được thoát bằng cách sử dụng tiền tố đặc biệt của
"lớp phủ.lớp phủ.". Vì vậy, một tệp có xattr "trusted.overlay.overlay.metacopy"
trong thư mục phía dưới sẽ được hiển thị dưới dạng một tệp thông thường có phần mở rộng
"trusted.overlay.metacopy" xattr trong mount Overlayfs. Điều này có thể được lồng bởi
lặp lại tiền tố nhiều lần, vì mỗi trường hợp chỉ xóa một tiền tố.

Một thư mục thấp hơn bị mất trắng thường xuyên sẽ luôn được xử lý bởi các lớp phủ
mount, do đó, để hỗ trợ việc lưu trữ tệp trắng hiệu quả trong lớp phủ, hãy gắn một
hình thức trắng thay thế được hỗ trợ. Biểu mẫu này là biểu mẫu thông thường, có kích thước bằng 0
tệp có bộ xattr "overlay.whiteout", bên trong một thư mục có
"overlay.opaque" xattr được đặt thành "x" (xem ZZ0000ZZ).
Những khoảng trắng thay thế này không bao giờ được tạo bởi các lớp phủ, nhưng có thể được sử dụng bởi
công cụ không gian người dùng (như vùng chứa) tạo ra các lớp thấp hơn.
Những khoảng trắng thay thế này có thể được thoát bằng cách sử dụng lối thoát xattr tiêu chuẩn
cơ chế để lồng đúng vào bất kỳ độ sâu nào.

Hành vi không chuẩn
---------------------

Phiên bản hiện tại của lớp phủ có thể hoạt động như một phiên bản tuân thủ POSIX
hệ thống tập tin.

Đây là danh sách các trường hợp mà lớp phủ hiện không xử lý:

a) POSIX bắt buộc cập nhật st_atime cho các lần đọc.  Điều này hiện tại không
    được thực hiện trong trường hợp tệp nằm ở lớp thấp hơn.

b) Nếu một tập tin nằm ở lớp thấp hơn được mở ở chế độ chỉ đọc và sau đó
    bộ nhớ được ánh xạ với MAP_SHARED, thì những thay đổi tiếp theo đối với tệp sẽ không được thực hiện
    được phản ánh trong ánh xạ bộ nhớ.

c) Nếu một tệp nằm ở lớp thấp hơn đang được thực thi thì hãy mở tệp đó
    tệp để ghi hoặc cắt bớt tệp sẽ không bị từ chối với ETXTBSY.

Các tùy chọn sau đây cho phép lớp phủ hoạt động giống tiêu chuẩn hơn
hệ thống tập tin tuân thủ:

redirect_dir
````````````

Được bật với tùy chọn gắn kết hoặc tùy chọn mô-đun: "redirect_dir=on" hoặc với
tùy chọn cấu hình kernel CONFIG_OVERLAY_FS_REDIRECT_DIR=y.

Nếu tính năng này bị tắt, thì đổi tên (2) trên thư mục thấp hơn hoặc được hợp nhất
sẽ thất bại với EXDEV ("Liên kết thiết bị chéo không hợp lệ").

chỉ mục
```````

Được bật với tùy chọn gắn kết hoặc tùy chọn mô-đun "index=on" hoặc với
tùy chọn cấu hình kernel CONFIG_OVERLAY_FS_INDEX=y.

Nếu tính năng này bị tắt và một tệp có nhiều liên kết cứng được sao chép
lên thì điều này sẽ "phá vỡ" liên kết.  Những thay đổi sẽ không được truyền tới
các tên khác đề cập đến cùng một nút.

xino
````

Được bật với tùy chọn gắn kết "xino=auto" hoặc "xino=on", với mô-đun
tùy chọn "xino_auto=on" hoặc với tùy chọn cấu hình kernel
CONFIG_OVERLAY_FS_XINO_AUTO=y.  Cũng được kích hoạt ngầm bằng cách sử dụng tương tự
hệ thống tập tin cơ bản cho tất cả các lớp tạo nên lớp phủ.

Nếu tính năng này bị tắt hoặc hệ thống tập tin cơ bản không có
đủ số bit trống trong số inode thì các lớp phủ sẽ không thể
đảm bảo rằng các giá trị của st_ino và st_dev được trả về bởi stat(2) và
giá trị của d_ino được readdir(3) trả về sẽ hoạt động giống như trên hệ thống tệp thông thường.
Ví dụ. giá trị của st_dev có thể khác nhau đối với hai đối tượng trong cùng một
hệ thống tập tin lớp phủ và giá trị của st_ino cho các đối tượng hệ thống tập tin có thể không
liên tục và có thể thay đổi ngay cả khi hệ thống tập tin lớp phủ được gắn kết, như
được tóm tắt trong bảng ZZ0000ZZ ở trên.


Thay đổi hệ thống tập tin cơ bản
---------------------------------

Thay đổi hệ thống tệp cơ bản trong khi là một phần của lớp phủ được gắn
hệ thống tập tin không được phép.  Nếu hệ thống tập tin cơ bản bị thay đổi,
hành vi của lớp phủ không được xác định, mặc dù nó sẽ không dẫn đến
sự cố hoặc bế tắc.

Các thay đổi ngoại tuyến, khi lớp phủ không được gắn kết, được phép thực hiện
cây phía trên.  Những thay đổi ngoại tuyến đối với cây thấp hơn chỉ được phép nếu
Các tính năng "metacopy", "index", "xino" và "redirect_dir"
chưa được sử dụng.  Nếu cây phía dưới bị sửa đổi và bất kỳ cây nào trong số này
các tính năng đã được sử dụng, hoạt động của lớp phủ không được xác định,
mặc dù nó sẽ không dẫn đến sự cố hoặc bế tắc.

Khi tính năng xuất lớp phủ NFS được bật, hệ thống tệp lớp phủ
hành vi đối với các thay đổi ngoại tuyến của lớp bên dưới là khác nhau
hơn hành vi khi xuất NFS bị vô hiệu hóa.

Trên mỗi copy_up, một tập tin NFS xử lý inode thấp hơn, cùng với
UUID của hệ thống tệp thấp hơn, được mã hóa và lưu trữ ở dạng mở rộng
thuộc tính "trusted.overlay.origin" ở nút trên.

Khi tính năng xuất NFS được bật, việc tra cứu thư mục đã hợp nhất,
đã tìm thấy thư mục thấp hơn tại đường dẫn tra cứu hoặc tại đường dẫn được trỏ
tới thuộc tính mở rộng "trusted.overlay.redirect", sẽ xác minh
rằng tệp thư mục thấp hơn được tìm thấy xử lý và hệ thống tệp thấp hơn UUID
khớp với phần xử lý tệp gốc được lưu trữ tại thời điểm copy_up.  Nếu một
tìm thấy thư mục thấp hơn không khớp với nguồn gốc được lưu trữ, thư mục đó
sẽ không được hợp nhất với thư mục trên.



Xuất khẩu NFS
-------------

Khi hệ thống tệp cơ bản hỗ trợ xuất NFS và "nfs_export"
tính năng này được bật, hệ thống tệp lớp phủ có thể được xuất sang NFS.

Với tính năng "nfs_export", trên copy_up của bất kỳ đối tượng thấp hơn nào, một chỉ mục
mục được tạo trong thư mục chỉ mục.  Tên mục nhập chỉ mục là
biểu diễn thập lục phân của phần xử lý tệp gốc sao chép lên.  Đối với một
đối tượng không phải là thư mục, mục nhập chỉ mục là một liên kết cứng tới nút trên.
Đối với một đối tượng thư mục, mục nhập chỉ mục có thuộc tính mở rộng
"trusted.overlay.upper" với phần xử lý tệp được mã hóa ở phía trên
thư mục inode.

Khi mã hóa một tập tin xử lý từ một đối tượng hệ thống tập tin lớp phủ,
áp dụng các quy tắc sau:

1. Đối với đối tượng không phải ở trên, hãy mã hóa phần xử lý tệp thấp hơn từ nút dưới
 2. Đối với một đối tượng được lập chỉ mục, hãy mã hóa phần xử lý tệp thấp hơn từ nguồn gốc copy_up
 3. Đối với một đối tượng thuần túy phía trên và đối với một đối tượng phía trên không được lập chỉ mục hiện có,
    mã hóa một tập tin xử lý phía trên từ inode phía trên

Việc xử lý tệp lớp phủ được mã hóa bao gồm:

- Tiêu đề bao gồm thông tin loại đường dẫn (ví dụ: dưới/trên)
 - UUID của hệ thống tập tin cơ bản
 - Mã hóa hệ thống tập tin cơ bản của inode cơ bản

Định dạng mã hóa này giống hệt với tệp định dạng mã hóa xử lý
được lưu trữ trong thuộc tính mở rộng "trusted.overlay.origin".

Khi giải mã một tập tin xử lý lớp phủ, các bước sau đây được thực hiện:

1. Tìm lớp bên dưới bằng UUID và thông tin loại đường dẫn.
 2. Giải mã phần xử lý tệp hệ thống tập tin cơ bản thành hàm nha khoa cơ bản.
 3. Đối với phần xử lý tệp thấp hơn, hãy tra cứu phần xử lý trong thư mục chỉ mục theo tên.
 4. Nếu tìm thấy khoảng trống trong chỉ mục, hãy trả về ESTALE. Điều này thể hiện một
    đối tượng lớp phủ đã bị xóa sau khi xử lý tệp của nó được mã hóa.
 5. Đối với một không có thư mục, hãy khởi tạo một nha khoa lớp phủ bị ngắt kết nối từ
    đã giải mã nha khoa cơ bản, loại đường dẫn và nút chỉ mục, nếu tìm thấy.
 6. Đối với một thư mục, hãy sử dụng nha khoa được giải mã cơ bản được kết nối, loại đường dẫn
    và lập chỉ mục, để tra cứu một lớp phủ nha khoa được kết nối.

Giải mã một tập tin xử lý không phải thư mục có thể trả về một nha khoa bị ngắt kết nối.
copy_up của nha khoa bị ngắt kết nối đó sẽ tạo một mục nhập chỉ mục trên với
không có bí danh trên.

Khi hệ thống tập tin lớp phủ có nhiều lớp thấp hơn, lớp giữa
thư mục có thể có "chuyển hướng" đến thư mục thấp hơn.  Vì lớp giữa
"chuyển hướng" không được lập chỉ mục, phần xử lý tệp thấp hơn được mã hóa từ
thư mục gốc "chuyển hướng", không thể được sử dụng để tìm phần giữa hoặc phần trên
thư mục lớp.  Tương tự, phần xử lý tệp thấp hơn được mã hóa từ một
hậu duệ của thư mục gốc "chuyển hướng", không thể được sử dụng để
xây dựng lại đường dẫn lớp phủ được kết nối.  Để giảm thiểu các trường hợp
các thư mục không thể giải mã được từ phần xử lý tệp thấp hơn, những thư mục này
các thư mục được sao chép trên mã hóa và được mã hóa dưới dạng phần xử lý tệp phía trên.
Trên hệ thống tệp lớp phủ không có lớp trên, việc giảm nhẹ này không thể thực hiện được
xuất NFS đã sử dụng trong thiết lập này yêu cầu tắt tính năng theo dõi chuyển hướng (ví dụ:
"redirect_dir=nofollow").

Hệ thống tệp lớp phủ không hỗ trợ tệp có thể kết nối không có thư mục
xử lý, do đó việc xuất bằng cấu hình importfs 'subtree_check' sẽ
gây ra lỗi tra cứu tệp trên NFS.

Khi tính năng xuất NFS được bật, tất cả các mục chỉ mục thư mục sẽ được
được xác minh vào thời điểm gắn kết để kiểm tra xem các thẻ xử lý tệp phía trên có bị cũ không.
Việc xác minh này có thể gây ra chi phí đáng kể trong một số trường hợp.

Lưu ý: các tùy chọn gắn kết index=off,nfs_export=on đang xung đột đối với
mount đọc-ghi và sẽ dẫn đến lỗi.

Lưu ý: tùy chọn gắn kết uuid=off có thể được sử dụng để thay thế UUID của lớp bên dưới
hệ thống tập tin trong tập tin xử lý bằng null, để giảm bớt việc kiểm tra UUID. Cái này
có thể hữu ích trong trường hợp đĩa cơ bản được sao chép và UUID của bản sao này
được thay đổi. Điều này chỉ áp dụng được nếu tất cả các thư mục thấp hơn đều được bật
cùng một hệ thống tập tin, nếu không nó sẽ chuyển sang hoạt động bình thường.


UUID và fsid
-------------

UUID của chính phiên bản lớp phủ và fsid được báo cáo bởi statfs(2) là
được điều khiển bởi tùy chọn gắn kết "uuid", hỗ trợ các giá trị sau:

- "không":
    UUID của lớp phủ là rỗng. fsid được lấy từ hầu hết hệ thống tập tin phía trên.
- “tắt”:
    UUID của lớp phủ là rỗng. fsid được lấy từ hầu hết hệ thống tập tin phía trên.
    UUID của các lớp bên dưới bị bỏ qua và thay vào đó được sử dụng null.
- "bật":
    UUID của lớp phủ được tạo và sử dụng để báo cáo một fsid duy nhất.
    UUID được lưu trữ trong xattr "trusted.overlay.uuid", tạo lớp phủ fsid
    duy nhất và bền bỉ.  Tùy chọn này yêu cầu lớp phủ có phần trên
    hệ thống tập tin hỗ trợ xattrs.
- "tự động": (mặc định)
    UUID được lấy từ xattr "trusted.overlay.uuid" nếu nó tồn tại.
    Nâng cấp lên "uuid=on" trong lần cài đặt đầu tiên của hệ thống tập tin lớp phủ mới
    đáp ứng các điều kiện tiên quyết.
    Hạ cấp xuống "uuid=null" đối với các hệ thống tệp lớp phủ hiện có chưa từng được
    được gắn với "uuid=on".


Độ bền và sao chép
----------------------

Lệnh gọi hệ thống fsync(2) đảm bảo rằng dữ liệu và siêu dữ liệu của tệp
được ghi an toàn vào bộ nhớ đệm dự kiến sẽ
đảm bảo sự tồn tại của sự cố hệ thống thông tin bài viết.

Nếu không có lệnh gọi fsync(2), không có gì đảm bảo rằng dữ liệu được quan sát
dữ liệu sau khi hệ thống gặp sự cố sẽ là dữ liệu cũ hoặc mới, nhưng
trong thực tế, dữ liệu quan sát được sau sự cố thường là dữ liệu cũ hoặc mới
hoặc kết hợp cả hai.

Khi tệp lớp phủ được sửa đổi lần đầu tiên, việc sao chép sẽ
tạo một bản sao của tập tin phía dưới và các thư mục mẹ của nó ở phía trên
lớp.  Vì hệ thống tập tin Linux API không thực thi bất kỳ
ra lệnh lưu trữ các thay đổi mà không cần gọi fsync(2) rõ ràng, trong trường hợp
do hệ thống gặp sự cố, tệp phía trên có thể không có dữ liệu nào cả
(tức là số không), đó sẽ là một kết quả bất thường.  Để tránh điều này
trải nghiệm, lớp phủ gọi fsync(2) ở tệp trên trước khi hoàn thành
sao chép dữ liệu bằng đổi tên (2) hoặc liên kết (2) để tạo bản sao thành "nguyên tử".

Theo mặc định, lớp phủ không gọi fsync(2) một cách rõ ràng khi sao chép lên
thư mục hoặc chỉ sao chép siêu dữ liệu, do đó nó không đảm bảo
duy trì sửa đổi của người dùng trừ khi người dùng gọi fsync(2).
Fsync trong quá trình sao chép chỉ đảm bảo rằng nếu quan sát thấy việc sao chép
sau một sự cố, dữ liệu được quan sát không phải là số 0 hoặc giá trị trung gian
từ khu vực sao chép lên dàn dựng.

Trên các hệ thống tệp cục bộ truyền thống có một nhật ký duy nhất (ví dụ: ext4, xfs),
fsync trên một tệp cũng duy trì các thay đổi của thư mục mẹ, bởi vì chúng
thường được sửa đổi trong cùng một giao dịch, do đó độ bền của siêu dữ liệu trong quá trình
sao chép dữ liệu một cách hiệu quả được cung cấp miễn phí.  Lớp phủ hạn chế hơn nữa rủi ro bằng cách
không cho phép hệ thống tập tin mạng làm lớp trên.

Lớp phủ có thể được điều chỉnh để cải thiện hiệu suất hoặc độ bền khi lưu trữ
tới lớp bên dưới phía trên.  Điều này được điều khiển bởi mount "fsync"
tùy chọn hỗ trợ các giá trị sau:

- "tự động": (mặc định)
    Gọi fsync(2) ở tệp trên trước khi hoàn tất sao chép dữ liệu.
    Không có fsync(2) rõ ràng trên thư mục hoặc chỉ sao chép siêu dữ liệu.
- “nghiêm khắc”:
    Gọi fsync(2) trên tệp và thư mục phía trên trước khi hoàn thành bất kỳ thao tác nào
    sao chép lên.
- "không ổn định": [*]
    Thích hiệu suất hơn độ bền (xem ZZ0000ZZ)

[*] Tùy chọn gắn kết "dễ bay hơi" là bí danh của "fsync=volatile".


Gắn kết dễ bay hơi
------------------

Điều này được kích hoạt với tùy chọn gắn kết "dễ bay hơi".  Gắn kết dễ bay hơi không
đảm bảo sống sót sau một vụ tai nạn.  Khuyến nghị mạnh mẽ rằng không ổn định
gắn kết chỉ được sử dụng nếu dữ liệu được ghi vào lớp phủ có thể được tạo lại
mà không cần nỗ lực đáng kể.

Ưu điểm của việc gắn với tùy chọn "dễ bay hơi" là tất cả các dạng
các cuộc gọi đồng bộ hóa tới hệ thống tập tin phía trên bị bỏ qua.

Để tránh mang lại cảm giác an toàn sai lầm, syncfs (và fsync)
ngữ nghĩa của các giá trị gắn kết dễ bay hơi hơi khác so với phần còn lại của
VFS.  Nếu bất kỳ lỗi ghi lại nào xảy ra trên hệ thống tập tin của thư mục trên sau một
quá trình gắn kết dễ bay hơi diễn ra, tất cả các chức năng đồng bộ hóa sẽ trả về lỗi.  Một lần này
đạt đến điều kiện, hệ thống tập tin sẽ không phục hồi và mỗi lần đồng bộ hóa tiếp theo
cuộc gọi sẽ trả về lỗi, ngay cả khi Upperdir chưa gặp lỗi mới
kể từ cuộc gọi đồng bộ hóa cuối cùng.

Khi lớp phủ được gắn với tùy chọn "dễ bay hơi", thư mục
"$workdir/work/incompat/volatile" được tạo.  Trong lần gắn kết tiếp theo, lớp phủ
kiểm tra thư mục này và từ chối gắn kết nếu có. Đây là một điểm mạnh
chỉ báo rằng người dùng nên loại bỏ các thư mục trên và thư mục công việc và tạo
những cái tươi. Trong những trường hợp rất hạn chế khi người dùng biết rằng hệ thống có
không bị lỗi và nội dung của Upperdir vẫn nguyên vẹn, thư mục "dễ bay hơi"
có thể được gỡ bỏ.


Người dùng xattr
----------------

Tùy chọn gắn kết "-o userxattr" buộc các lớp phủ sử dụng
"người dùng.lớp phủ." không gian tên xattr thay vì "trusted.overlay.".  Đây là
hữu ích cho việc gắn các lớp phủ không có đặc quyền.


Bộ thử nghiệm
-------------

Có một bộ thử nghiệm ban đầu được phát triển bởi David Howells và hiện tại
được duy trì bởi Amir Goldstein tại:

ZZ0000ZZ

Chạy bằng root::

Bộ thử nghiệm liên kết # cd
  # ./run --ov --verify