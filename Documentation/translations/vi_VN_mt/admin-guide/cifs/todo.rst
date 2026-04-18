.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cifs/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====
TODO
====

Kể từ hạt nhân 6.7. Xem ZZ0000ZZ
để biết danh sách các tính năng được thêm vào theo bản phát hành

Danh sách một phần các tính năng bị thiếu
=========================================

Đóng góp được chào đón.  Có rất nhiều cơ hội
cho những đóng góp quan trọng, rõ ràng cho mô-đun này.  đây
là danh sách một phần các vấn đề đã biết và các tính năng còn thiếu:

a) SMB3 (và SMB3.1.1) thiếu các tính năng tùy chọn:
   tối ưu hóa hiệu suất đa kênh, lựa chọn kênh thuật toán,
   tối ưu hóa cho thuê thư mục,
   hỗ trợ ký gói nhanh hơn (GMAC),
   hỗ trợ nén qua mạng,
   Giảm tải bản sao T10 tức là "ODX" (đoạn sao chép và "Mức độ trùng lặp" ioctl
   hiện là hai cơ chế sao chép phía máy chủ duy nhất được hỗ trợ)

b) Việc kết hợp và xử lý lỗi được tối ưu hóa tốt hơn để hỗ trợ tệp thưa thớt,
   có lẽ việc bổ sung các fsctls SMB3.1.1 tùy chọn mới để tạo phạm vi thu gọn
   và chèn phạm vi nguyên tử hơn

c) Hỗ trợ SMB3.1.1 qua QUIC (và có lẽ các giao thức dựa trên ổ cắm khác
   như SCTP)

d) hỗ trợ hạn ngạch (cần thay đổi nhỏ về kernel vì nếu không thì sẽ gọi hạn ngạch
   sẽ không lọt vào hệ thống tệp mạng hoặc hệ thống tệp không có thiết bị).

e) Các trường hợp sử dụng bổ sung có thể được tối ưu hóa để sử dụng "kết hợp" (ví dụ:
   open/query/close và open/setinfo/close) để giảm số lượng
   các chuyến khứ hồi đến máy chủ và cải thiện hiệu suất. trường hợp khác nhau
   (stat, statfs, create, unlink, mkdir, xattrs) đã được cải thiện bởi
   sử dụng lãi kép nhưng có thể làm được nhiều hơn thế. Ngoài ra chúng tôi có thể
   giảm đáng kể số lần mở dư thừa bằng cách sử dụng chế độ đóng chậm (với
   xử lý việc cho thuê bộ đệm) và tốt hơn bằng cách sử dụng bộ đếm tham chiếu trên tệp
   tay cầm.

f) Hoàn tất hỗ trợ inotify để cửa sổ danh sách tệp kde và gnome
   sẽ tự động làm mới (hoàn thành một phần bởi Asser). Cần hạt nhân nhỏ
   vfs thay đổi để hỗ trợ xóa D_NOTIFY trên một tệp.

g) Thêm công cụ GUI để định cấu hình cài đặt /proc/fs/cifs và để hiển thị
   số liệu thống kê CIFS (đã bắt đầu)

h) triển khai hỗ trợ về bảo mật và các danh mục xattr đáng tin cậy
   (yêu cầu mở rộng giao thức nhỏ) để hỗ trợ tốt hơn cho SELINUX

i) Thêm hỗ trợ cho bối cảnh kết nối cây (xem MS-SMB2) giao thức SMB3.1.1 mới
   tính năng (có thể đặc biệt hữu ích cho việc ảo hóa).

j) Tạo cơ sở ánh xạ UID để UID máy chủ có thể được ánh xạ trên mỗi
   gắn kết hoặc cơ sở mỗi máy chủ với UID máy khách hoặc không ai nếu không có ánh xạ
   tồn tại. Tích hợp tốt hơn với winbind để giải quyết chủ sở hữu SID

k) Thêm công cụ để tận dụng nhiều tính năng và ioctls cụ thể hơn của smb3
   (passthrough ioctl/fsctl hiện được triển khai trong cifs.ko để cho phép
   gửi nhiều fsctls SMB3 khác nhau và thông tin truy vấn cũng như đặt cuộc gọi thông tin
   trực tiếp từ không gian người dùng) Thêm công cụ để thực hiện cài đặt khác nhau không phải POSIX
   thuộc tính siêu dữ liệu dễ dàng hơn từ các công cụ (ví dụ: mở rộng những gì đã được thực hiện
   trong công cụ thông tin smb).

l) hỗ trợ tệp được mã hóa (hiện tại thuộc tính hiển thị tệp là
   mã hóa trên máy chủ được báo cáo, nhưng việc thay đổi thuộc tính thì không.
   được hỗ trợ).

m) các công cụ thu thập số liệu thống kê được cải tiến (có thể tích hợp với nfsometer?)
   để mở rộng và làm cho việc sử dụng những gì hiện có trong /proc/fs/cifs/Stats trở nên dễ dàng hơn

n) Thêm hỗ trợ cho ACL dựa trên khiếu nại ("DAC")

o) trình trợ giúp gắn kết GUI (để đơn giản hóa các tùy chọn cấu hình khác nhau khi gắn kết)

p) Mở rộng hỗ trợ cho giao thức nhân chứng để cho phép thông báo chia sẻ
   di chuyển và thay đổi bộ điều hợp mạng máy chủ. Hiện tại chỉ có thông báo bởi
   giao thức nhân chứng để di chuyển máy chủ được máy khách Linux hỗ trợ.

q) Cho phép mount.cifs chi tiết hơn trong việc báo cáo lỗi bằng phương ngữ
   hoặc lỗi tính năng không được hỗ trợ. Việc này bây giờ sẽ dễ dàng hơn nhờ
   triển khai ngàm API mới.

r) cập nhật tài liệu cifs và hướng dẫn sử dụng.

s) Giải quyết các lỗi được tìm thấy bằng cách chạy một bộ xfstests rộng hơn trong tiêu chuẩn
   bộ hệ thống tập tin xfstest.

t) chia hỗ trợ cifs và smb3 thành các mô-đun riêng biệt để kế thừa (và ít hơn
   an toàn) Phương ngữ CIFS có thể bị tắt trong các môi trường không cần đến nó
   và đơn giản hóa mã.

v) Thử nghiệm bổ sung Tiện ích mở rộng POSIX cho SMB3.1.1

w) Hỗ trợ các tiện ích mở rộng Mac SMB3.1.1 để cải thiện khả năng tương tác với máy chủ Apple

x) Hỗ trợ các tùy chọn xác thực bổ sung (ví dụ: IAKERB, ngang hàng
   Kerberos, SCRAM và các loại khác được hỗ trợ bởi các máy chủ hiện có)

y) Truy tìm được cải thiện, nhiều điểm theo dõi eBPF hơn, tập lệnh tốt hơn để thực hiện
   phân tích

Lỗi đã biết
===========

Xem ZZ0000ZZ - tìm kiếm trên sản phẩm "CifsVFS" để biết
danh sách lỗi hiện tại.  Also check ZZ0001ZZ (Product = File System, Component = CIFS)
và kết quả xfstest, vd ZZ0002ZZ

Kiểm tra linh tinh để làm
=========================
1) kiểm tra tên đường dẫn tối đa và các thành phần tên đường dẫn tối đa đối với các máy chủ khác nhau
   các loại. Hãy thử các liên kết tượng trưng lồng nhau (sâu 8). Trả về tên đường dẫn tối đa trong thông tin stat -f

2) Cải thiện khả năng hỗ trợ cifs/smb3 của xfstest và điều chỉnh xfstests khi cần kiểm tra
   cifs/smb3 tốt hơn

3) Kiểm tra và tối ưu hóa hiệu suất bổ sung bằng cách sử dụng iozone và tương tự -
   có một số thay đổi dễ dàng có thể được thực hiện để song song hóa việc ghi tuần tự,
   và khi chức năng ký bị vô hiệu hóa để yêu cầu kích thước đọc lớn hơn (lớn hơn
   kích thước đã thương lượng) và gửi kích thước ghi lớn hơn đến các máy chủ hiện đại.

4) Kiểm tra kỹ lưỡng hơn đối với các máy chủ ít phổ biến hơn

5) Tiếp tục mở rộng "buildbot" smb3 để thực hiện xfstesting tự động
   hiện tại chống lại Windows, Samba và Azure - để thêm các thử nghiệm bổ sung và
   để cho phép buildbot thực hiện các bài kiểm tra nhanh hơn. URL dành cho
   buildbot là: ZZ0000ZZ

6) Giải quyết các cảnh báo về phạm vi bảo hiểm khác nhau (hầu hết không phải là lỗi, nhưng
   càng có nhiều cảnh báo được giải quyết thì càng dễ dàng phát hiện ra thực tế
   vấn đề mà máy phân tích tĩnh sẽ chỉ ra trong tương lai).
