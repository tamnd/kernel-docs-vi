.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/generated-content.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Nguyên tắc hạt nhân cho nội dung do công cụ tạo
================================================

Mục đích
========

Những người đóng góp hạt nhân đã và đang sử dụng công cụ để tạo ra các đóng góp
trong một thời gian dài. Những công cụ này có thể tăng khối lượng đóng góp.
Đồng thời, băng thông của người đánh giá và người bảo trì rất khan hiếm.
tài nguyên. Hiểu được phần đóng góp nào đến từ
con người so với các công cụ rất hữu ích để duy trì những tài nguyên đó và giữ
hạt nhân phát triển lành mạnh.

Mục tiêu ở đây là làm rõ những kỳ vọng của cộng đồng xung quanh các công cụ. Cái này
cho phép mọi người làm việc hiệu quả hơn đồng thời duy trì mức năng suất cao
mức độ tin cậy giữa người gửi và người đánh giá.

Ngoài phạm vi
=============

Những nguyên tắc này không áp dụng cho các công cụ thực hiện những chỉnh sửa nhỏ đối với
nội dung có sẵn. Chúng cũng không liên quan đến công cụ hỗ trợ
những công việc tầm thường. Một số ví dụ:

- Sửa lỗi chính tả và ngữ pháp, chẳng hạn như diễn đạt lại giọng mệnh lệnh
 - Hỗ trợ đánh máy như hoàn thành mã định danh, bản soạn sẵn thông thường hoặc
   hoàn thành mẫu tầm thường
 - Các phép biến đổi thuần túy cơ học như đổi tên biến
 - Định dạng lại, như chạy Lindent, ZZ0000ZZ hoặc
   ZZ0001ZZ

Ngay cả khi việc sử dụng công cụ của bạn nằm ngoài phạm vi cho phép, bạn vẫn nên luôn luôn
hãy cân nhắc xem điều đó có giúp ích cho việc đánh giá đóng góp của bạn hay không nếu người đánh giá
biết về công cụ bạn đã sử dụng.

Trong phạm vi
=============

Những nguyên tắc này áp dụng khi một lượng nội dung có ý nghĩa trong kernel
đóng góp không được viết bởi một người trong chuỗi Đã ký,
nhưng thay vào đó lại được tạo ra bởi một công cụ.

Việc phát hiện một vấn đề và thử nghiệm cách khắc phục nó cũng là một phần của
quá trình phát triển; nếu một công cụ được sử dụng để tìm ra vấn đề được giải quyết bởi
một thay đổi cần được ghi chú trong nhật ký thay đổi. Điều này không chỉ mang lại
tín dụng khi đến hạn, nó cũng giúp các nhà phát triển đồng nghiệp tìm hiểu về
những công cụ này.

Một số ví dụ:
 - Mọi bản sửa lỗi do công cụ đề xuất như ZZ0000ZZ
 - Tập lệnh Coccinelle
 - Một chatbot đã tạo một chức năng mới trong bản vá của bạn để sắp xếp các mục trong danh sách.
 - Tệp .c trong bản vá ban đầu được tạo bằng mã hóa
   trợ lý nhưng được dọn dẹp bằng tay.
 - Nhật ký thay đổi được tạo bằng cách chuyển bản vá cho AI tổng hợp
   tool và yêu cầu nó viết nhật ký thay đổi.
 - Nhật ký thay đổi đã được dịch từ ngôn ngữ khác.

Nếu nghi ngờ, hãy chọn tính minh bạch và cho rằng những nguyên tắc này áp dụng cho
đóng góp của bạn.

Hướng dẫn
==========

Đầu tiên, hãy đọc Giấy chứng nhận xuất xứ của nhà phát triển:
Tài liệu/quy trình/gửi-patches.rst. Quy tắc của nó rất đơn giản
và đã tồn tại từ lâu. Họ đã bao gồm nhiều
đóng góp do công cụ tạo ra. Đảm bảo rằng bạn hiểu toàn bộ
trình và sẵn sàng trả lời các ý kiến đánh giá.

Thứ hai, khi đóng góp, phải minh bạch về nguồn gốc của
nội dung trong thư xin việc và nhật ký thay đổi. Bạn có thể minh bạch hơn
bằng cách thêm thông tin như thế này:

- Những công cụ nào đã được sử dụng?
 - Đầu vào của các công cụ bạn đã sử dụng, như tập lệnh nguồn Coccinelle.
 - Nếu mã phần lớn được tạo ra từ một tập hợp đơn lẻ hoặc ngắn
   lời nhắc, hãy bao gồm những lời nhắc đó. Đối với các phiên dài hơn, hãy bao gồm một
   tóm tắt các lời nhắc và bản chất của sự hỗ trợ mang lại.
 - Phần nội dung nào bị ảnh hưởng bởi công cụ đó?
 - Bài nộp được kiểm tra như thế nào và những công cụ nào được sử dụng để kiểm tra bài nộp
   sửa chữa?

Giống như tất cả các khoản đóng góp, cá nhân người bảo trì có toàn quyền quyết định
chọn cách họ xử lý sự đóng góp. Ví dụ: họ có thể:

- Hãy đối xử với nó giống như bất kỳ đóng góp nào khác.
 - Từ chối thẳng thừng.
 - Đối xử đặc biệt với khoản đóng góp, ví dụ như yêu cầu thêm
   kiểm tra, xem xét kỹ lưỡng hơn hoặc đánh giá ở mức độ thấp hơn
   ưu tiên hơn nội dung do con người tạo ra.
 - Yêu cầu một số bước đặc biệt khác, như yêu cầu người đóng góp
   giải thích chi tiết về cách công cụ hoặc mô hình được đào tạo.
 - Yêu cầu người nộp giải thích chi tiết hơn về nội dung đóng góp
   để người bảo trì có thể yên tâm rằng người gửi hoàn toàn
   hiểu cách mã hoạt động.
 - Đề xuất lời nhắc tốt hơn thay vì đề xuất thay đổi mã cụ thể.

Nếu các công cụ cho phép bạn tạo ra sự đóng góp một cách tự động, hãy mong đợi
sự giám sát bổ sung tương ứng với số lượng nó được tạo ra.

Giống như đầu ra của bất kỳ dụng cụ nào, kết quả có thể không chính xác hoặc
không phù hợp. Bạn được yêu cầu phải hiểu và có thể bảo vệ
mọi thứ bạn gửi. Nếu không làm được thì đừng nộp
những thay đổi kết quả.

Nếu bạn vẫn làm như vậy, người bảo trì có quyền từ chối loạt phim của bạn
không có sự xem xét chi tiết.
