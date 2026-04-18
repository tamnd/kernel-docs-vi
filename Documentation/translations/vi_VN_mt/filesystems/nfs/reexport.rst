.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/reexport.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Tái xuất hệ thống tập tin NFS
===========================

Tổng quan
--------

Có thể xuất lại hệ thống tệp NFS qua NFS.  Tuy nhiên, điều này
tính năng đi kèm với một số hạn chế.  Trước khi thử nó, chúng tôi
đề xuất một số nghiên cứu cẩn thận để xác định xem liệu nó có hiệu quả hay không
mục đích của bạn.

Sau đây là một cuộc thảo luận về những hạn chế đã biết hiện tại.

"fsid=" bắt buộc, chéo không bị hỏng
---------------------------------

Chúng tôi yêu cầu tùy chọn xuất "fsid=" trên bất kỳ lần tái xuất nào của NFS
hệ thống tập tin.  Bạn có thể sử dụng "uuidgen -r" để tạo một đối số duy nhất.

Việc xuất "crossmnt" không truyền "fsid=", vì vậy nó sẽ không cho phép
truy cập vào các hệ thống tập tin nfs tiếp theo; nếu bạn muốn xuất nfs
hệ thống tập tin được gắn trong hệ thống tập tin đã xuất, bạn sẽ cần xuất
chúng một cách rõ ràng, chỉ định mỗi tùy chọn "fsid= duy nhất của riêng nó.

Khởi động lại phục hồi
---------------

Cơ chế khôi phục khởi động lại thông thường của giao thức NFS không hoạt động đối với
trường hợp máy chủ tái xuất khởi động lại do máy chủ nguồn chưa
đã khởi động lại và do đó nó không còn hoạt động nữa.  Vì máy chủ nguồn không có trong
ân huệ, nó không thể đưa ra bất kỳ đảm bảo nào rằng tập tin sẽ không bị
đã thay đổi giữa các ổ khóa bị mất và bất kỳ nỗ lực nào để khôi phục chúng.
Điều tương tự cũng áp dụng cho các ủy quyền và bất kỳ khóa liên quan nào.  Khách hàng là
không được phép lấy khóa tập tin hoặc ủy quyền từ máy chủ tái xuất, bất kỳ
các lần thử sẽ thất bại do thao tác không được hỗ trợ.

Giới hạn xử lý tệp
-----------------

Nếu máy chủ ban đầu sử dụng tước hiệu tệp X byte cho một đối tượng nhất định, thì
Tên xử lý tệp của máy chủ tái xuất cho đối tượng được tái xuất sẽ là X+22
byte, làm tròn lên bội số gần nhất của bốn byte.

Kết quả phải phù hợp với giới hạn kích thước tay cầm tệp bắt buộc của RFC:

+-------+----------+
ZZ0000ZZ 32 byte |
+-------+----------+
ZZ0001ZZ 64 byte |
+-------+----------+
ZZ0002ZZ 128 byte |
+-------+----------+

Vì vậy, ví dụ: bạn sẽ chỉ có thể xuất lại hệ thống tệp qua
NFSv2 nếu máy chủ gốc cung cấp cho bạn các quyền xử lý tệp phù hợp với 10
byte - điều này khó xảy ra.

Nói chung không có cách nào để biết kích thước tước hiệu tệp tối đa được đưa ra
bởi máy chủ NFS mà không hỏi nhà cung cấp máy chủ.

Nhưng bảng sau đây đưa ra một vài ví dụ.  Cột đầu tiên là
độ dài điển hình của tước hiệu tệp từ máy chủ Linux xuất tệp đã cho
hệ thống tập tin, thứ hai là độ dài sau khi xuất nfs đó được xuất lại
bởi một máy chủ Linux khác:

+--------+-------------------+-------+
Chiều dài tay cầm tập tin ZZ0000ZZ ZZ0001ZZ
+=========+==============================================================================================================
ZZ0002ZZ 28 byte ZZ0003ZZ
+--------+-------------------+-------+
ZZ0004ZZ 32 byte ZZ0005ZZ
+--------+-------------------+-------+
ZZ0006ZZ 40 byte ZZ0007ZZ
+--------+-------------------+-------+

Do đó, tất cả sẽ vừa với tước hiệu tệp NFSv3 hoặc NFSv4 sau khi tái xuất,
nhưng không có cái nào có thể tái xuất khẩu qua NFSv2.

Tuy nhiên, các thẻ xử lý tệp máy chủ Linux phức tạp hơn thế này một chút;
Ví dụ:

- Tùy chọn xuất "kiểm tra cây con" (không mặc định) nói chung
          yêu cầu thêm 4 đến 8 byte trong tước hiệu tệp.
        - Nếu bạn xuất thư mục con của hệ thống tập tin (thay vì
          xuất gốc hệ thống tập tin), điều đó cũng thường thêm 4 đến 8
          byte.
        - Nếu bạn xuất qua NFSv2, knfsd thường sử dụng tên ngắn hơn
          mã định danh hệ thống tập tin giúp tiết kiệm 8 byte.
        - Thư mục gốc của bản xuất sử dụng tước hiệu tệp
          ngắn hơn.

Như bạn có thể thấy, tước hiệu tệp NFSv4 128 byte đủ lớn để
bạn sẽ không gặp khó khăn khi sử dụng NFSv4 để xuất lại bất kỳ hệ thống tệp nào
được xuất từ máy chủ Linux.  Nói chung, nếu máy chủ ban đầu là
thứ gì đó cũng hỗ trợ NFSv3, bạn ZZ0000ZZ OK.  Tái xuất
qua NFSv3 có thể khó khăn hơn và việc tái xuất qua NFSv2 có thể sẽ
không bao giờ làm việc.

Để biết thêm chi tiết về cấu trúc tước hiệu tệp Linux, tài liệu tham khảo tốt nhất là
mã nguồn và ý kiến; xem cụ thể:

- bao gồm/linux/exportfs.h:enum fid_type
        - bao gồm/uapi/linux/nfsd/nfsfh.h:struct nfs_fhbase_new
        - fs/nfsd/nfsfh.c:set_version_and_fsid_type
        - fs/nfs/export.c:nfs_encode_fh

Mở các bit DENY bị bỏ qua
----------------------

NFS vì NFSv4 hỗ trợ các bit ALLOW và DENY được lấy từ Windows,
ví dụ: cho phép bạn mở một tập tin ở chế độ cấm người khác
đọc mở ra hoặc viết mở ra. Máy khách Linux không sử dụng chúng và
sự hỗ trợ của máy chủ luôn không đầy đủ: chúng chỉ được thực thi
chống lại những người dùng NFS khác, không chống lại các quá trình truy cập vào dữ liệu đã xuất
hệ thống tập tin cục bộ. Máy chủ tái xuất cũng sẽ không chuyển chúng tới
máy chủ ban đầu, vì vậy chúng sẽ không được thực thi giữa các máy khách của
các máy chủ tái xuất khác nhau.
