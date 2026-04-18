.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/iomap/porting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _iomap_porting:

..
        Dumb style notes to maintain the author's sanity:
        Please try to start sentences on separate lines so that
        sentence changes don't bleed colors in diff.
        Heading decorations are documented in sphinx.rst.

===============================
Chuyển hệ thống tập tin của bạn
===============================

.. contents:: Table of Contents
   :local:

Tại sao chuyển đổi?
===================

Có một số lý do để chuyển đổi hệ thống tập tin sang iomap:

1. Đường dẫn I/O Linux cổ điển không hiệu quả lắm.
    Các hoạt động của Pagecache khóa một trang cơ sở tại một thời điểm và sau đó gọi
    vào hệ thống tập tin để trả về ánh xạ chỉ cho trang đó.
    Hoạt động I/O trực tiếp xây dựng I/O yêu cầu một khối tệp duy nhất tại một
    thời gian.
    Điều này hoạt động đủ tốt cho các hệ thống tập tin được ánh xạ trực tiếp/gián tiếp như
    như ext2, nhưng rất kém hiệu quả đối với các hệ thống tập tin dựa trên phạm vi như
    như XFS.

2. Các folio lớn chỉ được hỗ trợ qua iomap; không có kế hoạch để
    chuyển đổi đường dẫn buffer_head cũ để sử dụng chúng.

3. Chỉ có quyền truy cập trực tiếp vào bộ lưu trữ trên các thiết bị giống bộ nhớ (fsdax)
    được hỗ trợ thông qua iomap.

4. Giảm chi phí bảo trì cho người bảo trì hệ thống tập tin riêng lẻ.
    iomap tự xử lý các hoạt động phổ biến liên quan đến bộ đệm trang, chẳng hạn như
    phân bổ, khởi tạo, khóa và mở khóa các folios.
    Không ->write_begin(), ->write_end() hoặc direct_IO
    address_space_Operations được yêu cầu phải được thực hiện bởi
    hệ thống tập tin sử dụng iomap.

Làm cách nào để chuyển đổi hệ thống tập tin?
============================================

Đầu tiên, thêm ZZ0000ZZ từ mã nguồn của bạn và thêm
ZZ0001ZZ vào tùy chọn Kconfig của hệ thống tập tin của bạn.
Xây dựng kernel, chạy fstests với tùy chọn ZZ0002ZZ trên phạm vi rộng
nhiều cấu hình được hỗ trợ cho hệ thống tập tin của bạn để xây dựng một
cơ sở về bài kiểm tra nào đạt và bài kiểm tra nào thất bại.

Cách tiếp cận được đề xuất trước tiên là triển khai ZZ0000ZZ (và
ZZ0001ZZ nếu cần thiết) để cho phép iomap có được chế độ chỉ đọc
ánh xạ của một phạm vi tập tin.
Trong hầu hết các trường hợp, đây là một sự chuyển đổi tương đối tầm thường của
Chức năng ZZ0002ZZ cho ánh xạ chỉ đọc.
ZZ0003ZZ là mục tiêu đầu tiên tốt vì nó không quan trọng
triển khai hỗ trợ cho nó và sau đó xác định rằng bản đồ phạm vi
lặp lại là chính xác từ không gian người dùng.
Nếu FIEMAP trả về thông tin chính xác thì đó là một dấu hiệu tốt cho thấy
các hoạt động ánh xạ chỉ đọc khác sẽ thực hiện đúng.

Tiếp theo, sửa đổi ZZ0000ZZ của hệ thống tập tin
triển khai để sử dụng triển khai ZZ0001ZZ mới để ánh xạ
không gian tập tin cho các hoạt động đọc đã chọn.
Ẩn đằng sau nút gỡ lỗi khả năng bật ánh xạ iomap
chức năng cho các đường dẫn cuộc gọi đã chọn.
Cần phải viết một số mã để điền vào phần đệm dựa trên
ánh xạ thông tin từ cấu trúc ZZ0002ZZ, nhưng các chức năng mới
có thể được kiểm tra mà không cần triển khai bất kỳ API iomap nào.

Khi các chức năng chỉ đọc hoạt động như thế này, hãy chuyển đổi từng mức cao
thao tác tệp cấp độ từng cái một để sử dụng API gốc iomap thay vì
đi qua ZZ0000ZZ.
Thực hiện từng cái một, các hồi quy sẽ hiển nhiên.
ZZ0003ZZ của bạn có đường cơ sở kiểm tra hồi quy cho fstest, phải không?
Nên chuyển đổi kích hoạt tệp hoán đổi, ZZ0001ZZ và
ZZ0002ZZ trước khi giải quyết các đường dẫn I/O.
Sự phức tạp có thể xảy ra tại thời điểm này sẽ là chuyển đổi dữ liệu đọc vào bộ đệm
Đường dẫn I/O vì các đầu đệm.
Các đường dẫn I/O đọc vào bộ đệm chưa cần phải được chuyển đổi, mặc dù
đường dẫn đọc I/O trực tiếp sẽ được chuyển đổi trong giai đoạn này.

Tại thời điểm này, bạn nên xem qua chức năng ZZ0000ZZ của mình.
Nếu nó chuyển đổi giữa các khối mã lớn dựa trên việc gửi đi
Đối số ZZ0001ZZ, bạn nên cân nhắc việc chia nó thành
các hoạt động iomap cho mỗi hoạt động với các chức năng nhỏ hơn, gắn kết hơn.
XFS là một ví dụ điển hình về điều này.

Việc tiếp theo cần làm là triển khai ZZ0000ZZ
chức năng trong các phương pháp ZZ0001ZZ/ZZ0002ZZ.
Chúng tôi đặc biệt khuyến khích tạo các chức năng ánh xạ riêng biệt và
iomap hoạt động cho các hoạt động ghi.
Sau đó chuyển đổi đường dẫn ghi I/O trực tiếp sang iomap và bắt đầu chạy fsx
w/ DIO được kích hoạt nghiêm túc trên hệ thống tập tin.
Điều này sẽ loại bỏ rất nhiều lỗi trong trường hợp góc toàn vẹn dữ liệu mà phiên bản mới
viết bản đồ thực hiện giới thiệu.

Bây giờ, hãy chuyển đổi mọi thao tác tệp còn lại để gọi các hàm iomap.
Điều này sẽ có được toàn bộ hệ thống tập tin bằng cách sử dụng các chức năng ánh xạ mới và
phần lớn chúng sẽ được gỡ lỗi và hoạt động chính xác sau bước này.

Rất có thể tại thời điểm này, các đường dẫn đọc và ghi được đệm sẽ vẫn
cần phải được chuyển đổi.
Tất cả các chức năng ánh xạ đều phải hoạt động chính xác, vì vậy tất cả những gì cần phải được
xong là viết lại tất cả mã có giao diện với đầu đệm để
giao diện với iomap và folios.
Trước tiên, việc lấy I/O tệp thông thường sẽ dễ dàng hơn nhiều (không cần bất kỳ sự ưa thích nào).
các tính năng như fscrypt, fsverity, nén hoặc data=journaling)
chuyển đổi để sử dụng iomap.
Một số tính năng ưa thích đó (fscrypt và nén) không có
chưa được triển khai trong iomap.
Đối với các hệ thống tệp chưa được ghi nhật ký sử dụng bộ đệm trang cho các liên kết tượng trưng
và thư mục, bạn cũng có thể thử chuyển đổi cách xử lý chúng sang iomap.

Phần còn lại được để lại như một bài tập cho người đọc, vì nó sẽ khác
cho mọi hệ thống tập tin.
Nếu bạn gặp vấn đề, hãy gửi email cho mọi người và danh sách trong
ZZ0000ZZ để được trợ giúp.