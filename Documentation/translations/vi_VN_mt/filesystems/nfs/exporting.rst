.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/exporting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

:mồ côi:

Làm cho hệ thống tập tin có thể xuất được
=========================================

Tổng quan
---------

Tất cả các hoạt động của hệ thống tập tin đều yêu cầu một (hoặc hai) dấu răng để bắt đầu
điểm.  Các ứng dụng cục bộ có thời gian lưu giữ được tính tham chiếu phù hợp
nha khoa thông qua bộ mô tả tệp đang mở hoặc cwd/root.  Tuy nhiên xa xôi
các ứng dụng truy cập hệ thống tập tin thông qua giao thức hệ thống tập tin từ xa
chẳng hạn như NFS có thể không có khả năng chứa tham chiếu như vậy và do đó cần có
cách khác nhau để chỉ một nha khoa cụ thể.  Là sự thay thế
hình thức tham chiếu cần phải ổn định khi đổi tên, cắt bớt và
khởi động lại máy chủ (trong số những thứ khác, mặc dù những thứ này có xu hướng phổ biến nhất
có vấn đề), không có câu trả lời đơn giản như 'tên tệp'.

Cơ chế được thảo luận ở đây cho phép mỗi triển khai hệ thống tập tin
chỉ định cách tạo byte mờ (bên ngoài hệ thống tệp)
dây cho bất kỳ loại răng nào và làm thế nào để tìm được một loại răng thích hợp cho bất kỳ loại răng nào
cho chuỗi byte mờ.
Chuỗi byte này sẽ được gọi là "đoạn xử lý tệp" vì nó
tương ứng với một phần của tước hiệu tệp NFS.

Một hệ thống tập tin hỗ trợ ánh xạ giữa các đoạn tước hiệu tập tin
và răng giả sẽ được gọi là "có thể xuất khẩu".



Sự cố Dcache
-------------

Dcache thường chứa tiền tố thích hợp của bất kỳ hệ thống tập tin cụ thể nào
cây.  Điều này có nghĩa là nếu bất kỳ đối tượng hệ thống tập tin nào nằm trong dcache thì
tất cả tổ tiên của đối tượng hệ thống tập tin đó cũng nằm trong dcache.
Vì quyền truy cập thông thường là theo tên tệp, tiền tố này được tạo một cách tự nhiên và
được duy trì dễ dàng (bởi mỗi đối tượng duy trì số lượng tham chiếu trên
cha mẹ của nó).

Tuy nhiên, khi các đối tượng được đưa vào dcache bằng cách diễn giải một
đoạn filehandle, không có việc tự động tạo tiền tố đường dẫn
cho đối tượng.  Điều này dẫn đến hai đặc điểm có liên quan nhưng khác biệt của
dcache không cần thiết để truy cập hệ thống tập tin thông thường.

1. Dcache đôi khi phải chứa các đối tượng không phải là một phần của
   tiền tố thích hợp. tức là không được kết nối với thư mục gốc.
2. Dcache phải được chuẩn bị cho thư mục mới được tìm thấy (thông qua ->tra cứu)
   đã có một răng giả (không được kết nối) và phải có khả năng di chuyển
   răng đó vào đúng vị trí (dựa trên cha mẹ và tên trong
   -> tra cứu).   Điều này đặc biệt cần thiết cho các thư mục vì
   đó là một bất biến dcache mà các thư mục chỉ có một răng.

Để triển khai các tính năng này, dcache có:

Một. Cờ nha khoa DCACHE_DISCONNECTED được bật
   bất kỳ nha khoa nào có thể không phải là một phần của tiền tố thích hợp.
   Điều này được đặt khi các mục nhập ẩn danh được tạo và bị xóa khi
   nha khoa được nhận thấy là con của một nha khoa nằm trong vị trí thích hợp
   tiền tố.  Nếu việc hoàn tiền cho một nha khoa có cờ này được đặt
   trở thành số 0, hàm răng sẽ bị loại bỏ ngay lập tức thay vì bị
   được giữ trong dcache.  Nếu một nha khoa chưa có trong dcache
   được truy cập nhiều lần bằng tước hiệu tệp (như NFSD có thể làm), một nha khoa mới
   sẽ được phân bổ cho mỗi lần truy cập và bị loại bỏ khi kết thúc
   quyền truy cập.

Lưu ý rằng một nha khoa như vậy có thể có được con cái, tên, tổ tiên, v.v.
   mà không làm mất DCACHE_DISCONNECTED - cờ đó chỉ bị xóa khi
   cây con được kết nối lại thành công với root.  Cho đến lúc đó răng giả
   trong cây con đó chỉ được giữ lại khi có tham chiếu;
   số lần đếm lại đạt đến 0 có nghĩa là bị trục xuất ngay lập tức, giống như đối với trường hợp chưa được băm
   răng giả.  Điều đó đảm bảo rằng chúng ta sẽ không cần phải săn lùng chúng
   umount.

b. Nguyên thủy để tạo các gốc phụ - d_obtain_root(inode).
   Những cái đó _không_ mang DCACHE_DISCONNECTED.  Chúng được đặt trên
   danh sách mỗi siêu khối (->s_roots), vì vậy chúng có thể được đặt tại umount
   thời gian cho mục đích trục xuất.

c. Trình trợ giúp phân bổ các mục nhập ẩn danh và giúp đính kèm
   thư mục lỏng lẻo vào thời điểm tra cứu. Họ là:

d_obtain_alias(inode) sẽ trả về một dấu răng cho inode đã cho.
      Nếu inode đã có một răng, một trong số đó sẽ được trả về.

Nếu không, một ẩn danh mới (IS_ROOT và
      DCACHE_DISCONNECTED) nha khoa được phân bổ và gắn vào.

Trong trường hợp có thư mục, cần lưu ý rằng chỉ có một răng duy nhất
      bao giờ có thể được gắn kết.

d_splice_alias(inode, dentry) sẽ đưa một hàm mới vào trong cây;
      nha khoa được truyền vào hoặc bí danh có sẵn cho nút đã cho
      (chẳng hạn như một ẩn danh được tạo bởi d_obtain_alias), nếu thích hợp.
      Nó trả về NULL khi nha khoa được truyền vào được sử dụng, sau lệnh gọi
      quy ước -> tra cứu.

Sự cố về hệ thống tập tin
-------------------------

Để một hệ thống tập tin có thể xuất được, nó phải:

1. cung cấp các thủ tục phân đoạn filehandle được mô tả dưới đây.
   2. đảm bảo rằng d_splice_alias được sử dụng thay vì d_add
      khi ->tra cứu tìm thấy một nút cho tên và cha mẹ nhất định.

Nếu inode là NULL thì d_splice_alias(inode, dentry) tương đương với::

d_add(dentry, inode), NULL

Tương tự, d_splice_alias(ERR_PTR(err), nha khoa) = ERR_PTR(err)

Thông thường, quy trình ->tra cứu sẽ kết thúc bằng ::

trả về d_splice_alias(inode, nha khoa);
	}



Việc triển khai hệ thống tệp khai báo rằng các phiên bản của hệ thống tệp
có thể xuất được bằng cách đặt trường s_export_op trong cấu trúc
super_block.  Trường này phải trỏ đến cấu trúc xuất_hoạt động
trong đó có các thành viên sau:

.. kernel-doc:: include/linux/exportfs.h
   :identifiers: struct export_operations

Một đoạn tước hiệu tệp bao gồm một mảng gồm 1 hoặc nhiều từ 4byte,
cùng với một "loại" một byte.
Quy trình giải mã_fh không nên phụ thuộc vào kích thước đã nêu
được truyền cho nó.  Kích thước này có thể lớn hơn tước hiệu tệp gốc
được tạo bởi Encode_fh, trong trường hợp đó nó sẽ được đệm bằng
không.  Đúng hơn, quy trình Encode_fh nên chọn một "loại"
cho biết bộ giải mã_fh có bao nhiêu phần tước hiệu tệp hợp lệ và cách
nó nên được giải thích.

Cờ hoạt động xuất khẩu
-----------------------
Ngoài các con trỏ vectơ thao tác, struct import_Operations còn có
chứa trường "cờ" cho phép hệ thống tệp giao tiếp với nfsd
rằng nó có thể muốn làm những điều khác biệt khi giải quyết nó. các
các cờ sau được xác định:

EXPORT_OP_NOWCC - tắt các thuộc tính NFSv3 WCC trên hệ thống tệp này
    RFC 1813 khuyến nghị các máy chủ luôn gửi tính nhất quán của bộ nhớ đệm yếu
    (WCC) cho máy khách sau mỗi thao tác. Máy chủ nên
    thu thập một cách nguyên tử các thuộc tính về inode, thực hiện thao tác trên nó,
    và sau đó thu thập các thuộc tính sau đó. Điều này cho phép khách hàng
    bỏ qua việc phát hành GETATTR trong một số trường hợp nhưng có nghĩa là máy chủ
    đang gọi vfs_getattr cho hầu hết tất cả RPC. Trên một số hệ thống tập tin
    (đặc biệt là những thứ được phân cụm hoặc nối mạng) cái này đắt
    và tính nguyên tử rất khó đảm bảo. Cờ này biểu thị cho nfsd
    rằng nó nên bỏ qua việc cung cấp các thuộc tính WCC cho máy khách trong NFSv3
    trả lời khi thực hiện các thao tác trên hệ thống tập tin này. Xem xét việc kích hoạt
    điều này trên các hệ thống tập tin có thao tác inode ->getattr đắt tiền,
    hoặc khi tính nguyên tử giữa tập hợp thuộc tính trước và sau hoạt động
    không thể đảm bảo được.

EXPORT_OP_NOSUBTREECHK - không cho phép kiểm tra cây con trên fs này
    Nhiều hoạt động NFS xử lý các xử lý tệp mà sau đó máy chủ phải
    bác sĩ thú y để đảm bảo rằng chúng sống bên trong cây xuất khẩu. Khi
    xuất bao gồm toàn bộ hệ thống tập tin, điều này không quan trọng. nfsd chỉ có thể
    đảm bảo rằng tước hiệu tệp tồn tại trên hệ thống tệp. Khi chỉ là một phần của
    Tuy nhiên, hệ thống tập tin được xuất khẩu thì nfsd phải đi theo tổ tiên của
    inode để đảm bảo rằng nó nằm trong cây con được xuất. Đây là một
    hoạt động tốn kém và không phải tất cả các hệ thống tập tin đều có thể hỗ trợ nó đúng cách.
    Cờ này miễn cho hệ thống tập tin khỏi việc kiểm tra cây con và gây ra
    importfs để khắc phục lỗi nếu nó cố kích hoạt kiểm tra cây con
    trên đó.

EXPORT_OP_CLOSE_BEFORE_UNLINK - luôn đóng các tệp được lưu trong bộ nhớ đệm trước khi hủy liên kết
    Trên một số hệ thống tệp có thể xuất (chẳng hạn như NFS), việc hủy liên kết một tệp
    vẫn còn mở có thể gây ra một chút công việc làm thêm. Ví dụ,
    máy khách NFS sẽ thực hiện "đổi tên ngớ ngẩn" để đảm bảo rằng tệp
    dính xung quanh trong khi nó vẫn mở. Khi tái xuất thì mở ra
    tập tin được giữ bởi nfsd nên chúng tôi thường thực hiện một cái tên ngớ ngẩn, và
    sau đó xóa ngay tập tin đã được đổi tên ngớ ngẩn ngay sau đó khi
    số lượng liên kết thực sự bằng không. Đôi khi việc xóa này có thể chạy đua
    với các hoạt động khác (ví dụ: rmdir của thư mục mẹ).
    Cờ này khiến nfsd đóng mọi tệp đang mở cho nút này _trước_
    gọi vào vfs để thực hiện hủy liên kết hoặc đổi tên sẽ thay thế
    một tập tin hiện có.

EXPORT_OP_REMOTE_FS - Bộ nhớ sao lưu cho hệ thống tệp này ở xa
    PF_LOCAL_THROTTLE tồn tại cho loopback NFSD, trong đó một luồng cần
    ghi vào một bdi (bdi cuối cùng) để giải phóng việc ghi hàng đợi
    tới một bdi khác (bdi khách). Các chủ đề như vậy có được số dư riêng tư
    của các trang bẩn để các trang bẩn cho bdi khách hàng không bị ảnh hưởng
    daemon ghi vào bdi cuối cùng. Đối với các hệ thống tập tin có độ bền cao
    bộ nhớ không cục bộ (chẳng hạn như hệ thống tệp NFS đã xuất), điều này
    hạn chế có những hậu quả tiêu cực. EXPORT_OP_REMOTE_FS kích hoạt
    xuất để vô hiệu hóa điều chỉnh ghi lại.

EXPORT_OP_NOATOMIC_ATTR - Hệ thống tập tin không cập nhật các thuộc tính nguyên tử
    EXPORT_OP_NOATOMIC_ATTR chỉ ra rằng hệ thống tập tin đã xuất
    không thể cung cấp ngữ nghĩa theo yêu cầu của boolean "nguyên tử" trong
    Change_info4 của NFSv4. Boolean này cho khách hàng biết liệu
    được trả về trước và sau khi các thuộc tính thay đổi được lấy một cách nguyên tử
    liên quan đến hoạt động siêu dữ liệu được yêu cầu (UNLINK,
    OPEN/CREATE, MKDIR, v.v.).

EXPORT_OP_FLUSH_ON_CLOSE - Hệ thống tập tin xóa dữ liệu tập tin khi đóng(2)
    Trên hầu hết các hệ thống tập tin, các nút có thể vẫn ở trạng thái ghi lại sau khi
    tập tin đã bị đóng. NFSD dựa vào hoạt động của khách hàng hoặc trình xóa cục bộ
    chủ đề để xử lý viết lại. Một số hệ thống tập tin nhất định, chẳng hạn như NFS, tuôn ra
    tất cả dữ liệu bẩn của inode ở lần đóng cuối cùng. Xuất khẩu thực hiện điều này
    cách nên đặt EXPORT_OP_FLUSH_ON_CLOSE để NFSD biết bỏ qua
    chờ ghi lại khi đóng các tập tin đó.
