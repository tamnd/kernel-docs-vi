.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/inotify.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================================================
Inotify - Hệ thống thông báo thay đổi tệp mạnh mẽ nhưng đơn giản
===============================================================



Tài liệu bắt đầu vào ngày 15 tháng 3 năm 2005 bởi Robert Love <rml@novell.com>

Tài liệu được cập nhật ngày 4 tháng 1 năm 2015 bởi Zhang Zhen <zhenzhang.zhang@huawei.com>

- Đã xóa giao diện lỗi thời, chỉ tham khảo các trang hướng dẫn về giao diện người dùng.

(i) Cơ sở lý luận

Hỏi:
   Quyết định thiết kế đằng sau việc không buộc đồng hồ vào fd mở của là gì?
   đối tượng được quan sát?

Đáp:
   Đồng hồ được liên kết với một thiết bị inotify đang mở chứ không phải một tệp đang mở.
   Điều này giải quyết vấn đề chính với dnotify: giữ cho các ghim của tệp luôn mở
   tập tin và do đó, tệ hơn, ghim mount.  Do đó, Dnotify là không khả thi
   để sử dụng trên hệ thống máy tính để bàn có phương tiện di động vì phương tiện không thể
   chưa được gắn kết.  Việc xem một tập tin không yêu cầu nó phải được mở.

Hỏi:
   Quyết định thiết kế đằng sau việc sử dụng an-fd-per-instance thay vì
   một fd-mỗi-đồng hồ?

Đáp:
   Một fd-per-watch nhanh chóng sử dụng nhiều bộ mô tả tệp hơn mức cho phép,
   nhiều fd hơn mức khả thi để quản lý và nhiều fd hơn mức tối ưu
   chọn()-có thể.  Có, root có thể vượt quá giới hạn fd trên mỗi quy trình và vâng, người dùng
   có thể sử dụng epoll, nhưng yêu cầu cả hai là một yêu cầu ngớ ngẩn và không liên quan.
   Đồng hồ tiêu thụ ít bộ nhớ hơn tệp đang mở, tách số
   do đó không gian là hợp lý.  Thiết kế hiện tại là những gì các nhà phát triển không gian người dùng
   muốn: Người dùng khởi tạo inotify một lần và thêm n đồng hồ, yêu cầu chỉ một
   fd và không có sự thay đổi nào với giới hạn fd.  Đang khởi tạo một phiên bản inotify hai
   ngàn lần là ngớ ngẩn.  Nếu chúng tôi có thể triển khai các tùy chọn của không gian người dùng
   một cách rõ ràng--và chúng ta có thể, lớp idr tạo ra những thứ tầm thường như thế này--sau đó chúng ta
   nên.

Có những lập luận tốt khác.  Với một fd duy nhất, có một
   mục cần chặn, được ánh xạ tới một hàng sự kiện.  Đĩa đơn
   fd trả về tất cả các sự kiện theo dõi cũng như mọi dữ liệu ngoài băng tần tiềm năng.  Nếu
   mỗi fd là một chiếc đồng hồ riêng biệt,

- Sẽ không có cách nào để có được sự kiện đặt hàng.  Sự kiện trên tập tin foo và
     thanh tệp sẽ bật poll() trên cả hai fd, nhưng sẽ không có cách nào để biết
     điều đó đã xảy ra đầu tiên  Một hàng đợi đơn giản sẽ cung cấp cho bạn đơn đặt hàng.  Như vậy
     việc đặt hàng là rất quan trọng đối với các ứng dụng hiện có như Beagle.  Hãy tưởng tượng
     Các sự kiện "mv a b ; mv b a" không có thứ tự.

- Chúng ta sẽ phải duy trì n fd's và n hàng đợi nội bộ với trạng thái,
     so với chỉ một.  Nó lộn xộn hơn rất nhiều trong kernel.  Một, tuyến tính
     hàng đợi là cấu trúc dữ liệu có ý nghĩa.

- Các nhà phát triển không gian người dùng thích API hiện tại hơn.  Những anh chàng Beagle, vì
     ví dụ, yêu nó.  Hãy tin tôi, tôi hỏi.  Không có gì đáng ngạc nhiên: Ai muốn
     để quản lý và chặn trên 1000 fd thông qua lựa chọn?

- Không có cách nào để thoát khỏi dữ liệu băng tần.

- 1024 vẫn còn quá thấp.  ;-)

Khi bạn nói về việc thiết kế một hệ thống thông báo thay đổi tập tin
   mở rộng tới 1000 thư mục, việc tung hứng 1000 thư mục dường như không thành công
   giao diện phù hợp.  Nó quá nặng.

Ngoài ra, _is_ có thể có nhiều hơn một phiên bản và
   sắp xếp nhiều hơn một hàng đợi và do đó có nhiều hơn một fd liên quan.  Ở đó
   không cần phải là ánh xạ một fd cho mỗi quy trình; nó là một fd-mỗi-hàng đợi và một
   quá trình có thể dễ dàng muốn có nhiều hơn một hàng đợi.

Hỏi:
   Tại sao lại áp dụng phương pháp gọi hệ thống?

Đáp:
   Giao diện không gian người dùng kém là vấn đề lớn thứ hai với dnotify.
   Tín hiệu là một giao diện tồi tệ, khủng khiếp để thông báo tập tin.  Hoặc cho
   bất cứ điều gì, cho vấn đề đó.  Giải pháp lý tưởng, xét từ mọi khía cạnh, là một
   dựa trên bộ mô tả tệp cho phép I/O tệp cơ bản và thăm dò/chọn.
   Việc lấy fd và quản lý đồng hồ có thể được thực hiện thông qua
   tập tin thiết bị hoặc một nhóm các cuộc gọi hệ thống mới.  Chúng tôi quyết định thực hiện một
   nhóm lệnh gọi hệ thống vì đó là cách tiếp cận ưa thích cho kernel mới
   giao diện.  Sự khác biệt thực sự duy nhất là liệu chúng tôi có muốn sử dụng open(2) hay không
   và ioctl(2) hoặc một vài lệnh gọi hệ thống mới.  Cuộc gọi hệ thống đánh bại ioctls.
