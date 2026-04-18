.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/lsm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================================
Mô-đun bảo mật Linux: Móc bảo mật chung cho Linux
========================================================

:Tác giả: Stephen Smalley
:Tác giả: Timothy Fraser
:Tác giả: Chris Vance

.. note::

   The APIs described in this book are outdated.

Giới thiệu
============

Vào tháng 3 năm 2001, Cơ quan An ninh Quốc gia (NSA) đã trình bày
về Linux được tăng cường bảo mật (SELinux) tại Hội nghị thượng đỉnh hạt nhân Linux 2.5.
SELinux là một triển khai linh hoạt và chi tiết
kiểm soát truy cập không tùy ý trong nhân Linux, ban đầu
được triển khai như bản vá kernel cụ thể của riêng nó. Một số bảo mật khác
các dự án (ví dụ RSBAC, Medusa) cũng đã phát triển quyền truy cập linh hoạt
kiến trúc điều khiển cho nhân Linux và nhiều dự án khác nhau đã
đã phát triển các mô hình kiểm soát truy cập cụ thể cho Linux (ví dụ LIDS, DTE,
Tên miền phụ). Mỗi dự án đã phát triển và duy trì kernel riêng
vá để hỗ trợ nhu cầu bảo mật của nó.

Để đáp lại bài thuyết trình NSA, Linus Torvalds đã thực hiện một bộ
nhận xét mô tả một khuôn khổ bảo mật mà anh ấy sẵn sàng thực hiện
xem xét đưa vào nhân Linux chính thống. Ông đã mô tả một
khuôn khổ chung sẽ cung cấp một tập hợp các móc bảo mật để kiểm soát
hoạt động trên các đối tượng hạt nhân và một tập hợp các trường bảo mật không rõ ràng trong
cấu trúc dữ liệu hạt nhân để duy trì các thuộc tính bảo mật. Cái này
framework sau đó có thể được sử dụng bởi các mô-đun hạt nhân có thể tải được để triển khai bất kỳ
mô hình bảo mật mong muốn. Linus cũng đề xuất khả năng
di chuyển mã khả năng của Linux vào một mô-đun như vậy.

Dự án Mô-đun bảo mật Linux (LSM) được WireX khởi động để phát triển
một khuôn khổ như vậy. LSM là nỗ lực phát triển chung của một số cơ quan bảo mật
các dự án, bao gồm Immunix, SELinux, SGI và Janus, cùng một số dự án khác
cá nhân, bao gồm Greg Kroah-Hartman và James Morris, để phát triển một
Bản vá nhân Linux triển khai khung này. Công việc đã
được đưa vào dòng chính vào tháng 12 năm 2003. Kỹ thuật này
báo cáo cung cấp một cái nhìn tổng quan về khuôn khổ và khả năng
mô-đun bảo mật.

Khung LSM
=============

Khung LSM cung cấp khung kernel chung để hỗ trợ
mô-đun bảo mật. Đặc biệt, khung LSM chủ yếu tập trung vào
về việc hỗ trợ các mô-đun kiểm soát truy cập, mặc dù sự phát triển trong tương lai là
có khả năng giải quyết các nhu cầu bảo mật khác như hộp cát. Bản thân nó,
framework không cung cấp bất kỳ bảo mật bổ sung nào; nó chỉ đơn thuần cung cấp
cơ sở hạ tầng để hỗ trợ các mô-đun bảo mật. Khung LSM là
tùy chọn, yêu cầu bật ZZ0001ZZ. Các khả năng
logic được triển khai như một mô-đun bảo mật.
Mô-đun khả năng này sẽ được thảo luận thêm trong
ZZ0000ZZ.

Khung LSM bao gồm các trường bảo mật trong cấu trúc dữ liệu hạt nhân và
gọi các hàm hook tại các điểm quan trọng trong mã kernel tới
quản lý các trường bảo mật và thực hiện kiểm soát truy cập.
Nó cũng bổ sung thêm chức năng đăng ký các mô-đun bảo mật.
Giao diện ZZ0000ZZ báo cáo danh sách được phân tách bằng dấu phẩy
của các mô-đun bảo mật đang hoạt động trên hệ thống.

Các trường bảo mật LSM chỉ đơn giản là các con trỏ ZZ0008ZZ.
Dữ liệu được gọi là blob, có thể được quản lý bởi
khung hoặc bởi các mô-đun bảo mật riêng lẻ sử dụng nó.
Các đốm màu bảo mật được sử dụng bởi nhiều mô-đun bảo mật
thường được quản lý bởi framework.
Đối với quá trình và
thông tin bảo mật thực thi chương trình, các trường bảo mật được bao gồm trong
ZZ0000ZZ và
ZZ0001ZZ.
Đối với hệ thống tập tin
thông tin bảo mật, trường bảo mật được bao gồm trong ZZ0002ZZ. Để bảo mật đường ống, tập tin và ổ cắm
thông tin, trường bảo mật được bao gồm trong ZZ0003ZZ và ZZ0004ZZ.
Để biết thông tin bảo mật của System V IPC,
các trường bảo mật đã được thêm vào ZZ0005ZZ và ZZ0006ZZ; Ngoài ra, các định nghĩa cho ZZ0007ZZ, struct msg_queue và struct shmid_kernel
đã được chuyển đến các tệp tiêu đề (ZZ0009ZZ và
ZZ0010ZZ nếu thích hợp) để cho phép các mô-đun bảo mật
sử dụng các định nghĩa này.

Đối với gói và
thông tin bảo mật thiết bị mạng, các trường bảo mật đã được thêm vào
ZZ0000ZZ và
ZZ0001ZZ.
Không giống như dữ liệu mô-đun bảo mật khác, dữ liệu được sử dụng ở đây là
số nguyên 32 bit. Các mô-đun bảo mật được yêu cầu phải ánh xạ hoặc nói cách khác
liên kết các giá trị này với các thuộc tính bảo mật thực sự.

Móc LSM được duy trì trong danh sách. Một danh sách được duy trì cho mỗi
hook và các hook được gọi theo thứ tự do CONFIG_LSM chỉ định.
Tài liệu chi tiết cho từng móc là
được bao gồm trong tệp nguồn ZZ0000ZZ.

Khung LSM cung cấp một xấp xỉ gần đúng về
xếp chồng mô-đun bảo mật chung. Nó định nghĩa
security_add_hooks() mà mỗi mô-đun bảo mật chuyển một
ZZ0000ZZ,
được thêm vào danh sách.
Khung LSM không cung cấp cơ chế loại bỏ các móc
đã được đăng ký. Mô-đun bảo mật SELinux đã triển khai
một cách để loại bỏ chính nó, tuy nhiên tính năng này không được dùng nữa.

Các móc có thể được xem như rơi vào hai chính
danh mục: hook được sử dụng để quản lý các trường bảo mật và hook
được sử dụng để thực hiện kiểm soát truy cập. Ví dụ về loại đầu tiên
của các hook bao gồm security_inode_alloc() và security_inode_free()
Những hook này được sử dụng để phân bổ
và các cấu trúc bảo mật miễn phí cho các đối tượng inode.
Một ví dụ về loại móc thứ hai
là hook security_inode_permission().
Móc này kiểm tra quyền khi truy cập vào một nút.

Mô-đun khả năng LSM
=======================

Logic khả năng của POSIX.1e được duy trì dưới dạng mô-đun bảo mật
được lưu trữ trong tệp ZZ0001ZZ. Các khả năng
mô-đun sử dụng trường đơn hàng của mô tả ZZ0000ZZ
để xác định nó là mô-đun bảo mật đầu tiên được đăng ký.
Mô-đun bảo mật khả năng không sử dụng bảo mật chung
các đốm màu, không giống như các mô-đun khác. Nguyên nhân mang tính lịch sử và
dựa trên các mối quan tâm về chi phí, độ phức tạp và hiệu suất.
