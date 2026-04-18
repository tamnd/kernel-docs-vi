.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/dnotify.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================
Thông báo thư mục Linux
============================

Stephen Rothwell <sfr@canb.auug.org.au>

Mục đích của thông báo thư mục là cho phép các ứng dụng của người dùng
được thông báo khi một thư mục hoặc bất kỳ tập tin nào trong đó bị thay đổi.
Cơ chế cơ bản liên quan đến việc ứng dụng đăng ký thông báo
trên một thư mục sử dụng lệnh gọi fcntl(2) và chính các thông báo
được phân phối bằng cách sử dụng tín hiệu.

Ứng dụng quyết định "sự kiện" nào nó muốn được thông báo.
Các sự kiện hiện được xác định là:

====================================================================
	DN_ACCESS Một tập tin trong thư mục đã được truy cập (đọc)
	DN_MODIFY Một tập tin trong thư mục đã được sửa đổi (ghi, cắt bớt)
	DN_CREATE Một tập tin đã được tạo trong thư mục
	DN_DELETE Một tập tin đã được hủy liên kết khỏi thư mục
	DN_RENAME Một tập tin trong thư mục đã được đổi tên
	DN_ATTRIB Một tệp trong thư mục có thuộc tính của nó
			đã thay đổi (chmod,chown)
	====================================================================

Thông thường, ứng dụng phải đăng ký lại sau mỗi thông báo, nhưng
nếu DN_MULTISHOT được gắn mặt nạ sự kiện thì việc đăng ký sẽ
duy trì cho đến khi bị xóa rõ ràng (bằng cách đăng ký không có sự kiện nào).

Theo mặc định, SIGIO sẽ được gửi đến quy trình và không có thông tin hữu ích nào khác
thông tin.  Tuy nhiên, nếu lệnh gọi F_SETSIG fcntl(2) được sử dụng để cho phép
kernel biết tín hiệu nào cần phân phối, cấu trúc siginfo sẽ được chuyển tới
bộ xử lý tín hiệu và thành viên si_fd của cấu trúc đó sẽ chứa
bộ mô tả tệp được liên kết với thư mục xảy ra sự kiện.

Tốt nhất là ứng dụng sẽ chọn một trong các tín hiệu thời gian thực
(SIGRTMIN + <n>) để các thông báo có thể được xếp hàng đợi.  Đây là
đặc biệt quan trọng nếu DN_MULTISHOT được chỉ định.  Lưu ý rằng SIGRTMIN
thường bị chặn nên tốt hơn nên sử dụng (ít nhất) SIGRTMIN + 1.

Kỳ vọng triển khai (tính năng và lỗi :-))
---------------------------------------------------

Thông báo sẽ hoạt động đối với mọi quyền truy cập cục bộ vào tệp ngay cả khi
hệ thống tập tin thực tế là trên một máy chủ từ xa.  Điều này ngụ ý rằng từ xa
quyền truy cập vào các tệp được cung cấp bởi máy chủ chế độ người dùng cục bộ sẽ được thông báo.
Ngoài ra, quyền truy cập từ xa vào các tệp được cung cấp bởi máy chủ NFS hạt nhân cục bộ sẽ
được thông báo.

Để làm cho tác động lên mã hệ thống tập tin càng nhỏ càng tốt,
vấn đề liên kết cứng tới tập tin đã bị bỏ qua.  Vì vậy, nếu một tập tin (x)
tồn tại trong hai thư mục (a và b) sau đó thay đổi tệp bằng cách sử dụng
tên "a/x" sẽ được thông báo cho chương trình đang chờ thông báo trên
thư mục "a", nhưng sẽ không được thông báo cho người mong đợi thông báo trên
thư mục "b".

Ngoài ra, các tệp đã được hủy liên kết vẫn sẽ gây ra thông báo trong
thư mục cuối cùng mà chúng được liên kết tới.

Cấu hình
-------------

Dnotify được điều khiển thông qua tùy chọn cấu hình CONFIG_DNOTIFY.  Khi nào
bị vô hiệu hóa, fcntl(fd, F_NOTIFY, ...) sẽ trả về -EINVAL.

Ví dụ
-------
Xem tools/testing/selftests/filesystems/dnotify_test.c để biết ví dụ.

NOTE
----
Bắt đầu với Linux 2.6.13, dnotify đã được thay thế bằng inotify.
Xem Documentation/filesystems/inotify.rst để biết thêm thông tin về nó.