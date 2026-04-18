.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/feature-and-driver-maintainers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================
Người bảo trì tính năng và trình điều khiển
===========================================

Thuật ngữ "người duy trì" bao gồm rất nhiều cấp độ tham gia
từ những người xử lý các bản vá và yêu cầu kéo gần như là một công việc toàn thời gian
cho những người chịu trách nhiệm về một tính năng nhỏ hoặc một trình điều khiển.

Không giống như hầu hết các chương, phần này dành cho phần sau (xem thêm
nhóm đông dân). Nó cung cấp các lời khuyên và mô tả những kỳ vọng và
trách nhiệm của người duy trì một phần nhỏ (ish) của mã.

Các tài xế thường không có danh sách gửi thư riêng và
cây git mà thay vào đó gửi và xem xét các bản vá trên danh sách lớn hơn
hệ thống con.

Trách nhiệm
================

Khối lượng công việc bảo trì thường tỷ lệ thuận với quy mô
và mức độ phổ biến của cơ sở mã. Các tính năng và trình điều khiển nhỏ nên
đòi hỏi lượng chăm sóc và cho ăn tương đối nhỏ. Tuy nhiên
khi tác phẩm đến tay (dưới dạng các bản vá cần xem xét,
báo cáo lỗi của người dùng, v.v.) nó phải được xử lý kịp thời.
Ngay cả khi một trình điều khiển cụ thể chỉ nhìn thấy một bản vá mỗi tháng hoặc một phần tư,
một hệ thống con cũng có thể có hàng trăm trình điều khiển như vậy. Hệ thống con
người bảo trì không thể chờ đợi lâu để nhận được phản hồi từ người đánh giá.

Kỳ vọng chính xác về thời gian phản hồi sẽ khác nhau tùy theo hệ thống con.
Bản đánh giá bản vá SLA mà hệ thống con đã tự thiết lập đôi khi có thể
được tìm thấy trong tài liệu hệ thống con. Thất bại như một quy tắc chung
người đánh giá nên cố gắng phản hồi nhanh hơn bản vá thông thường
sự chậm trễ trong việc xem xét của người bảo trì hệ thống con. Kết quả kỳ vọng
có thể kéo dài từ hai ngày làm việc đối với các hệ thống con có tốc độ nhanh (ví dụ: kết nối mạng)
đến vài tuần ở những phần chuyển động chậm hơn của hạt nhân.

Tham gia danh sách gửi thư
--------------------------

Nhân Linux sử dụng danh sách gửi thư làm hình thức liên lạc chính.
Người bảo trì phải được đăng ký và tuân theo quy trình thích hợp trên toàn hệ thống con
danh sách gửi thư. Hoặc bằng cách đăng ký toàn bộ danh sách hoặc sử dụng nhiều hơn
thiết lập hiện đại, có chọn lọc như
ZZ0000ZZ.

Người bảo trì phải biết cách giao tiếp trên danh sách (văn bản thuần túy, không xâm lấn
chân trang hợp pháp, không có bài đăng hàng đầu, v.v.)

Đánh giá
-------

Người bảo trì phải xem xét các bản vá ZZ0000ZZ dành riêng cho trình điều khiển của họ,
dù tầm thường đến đâu. Nếu bản vá là một cây thay đổi và sửa đổi
nhiều trình điều khiển - việc có cung cấp đánh giá hay không là tùy thuộc vào người bảo trì.

Khi có nhiều người bảo trì cho một đoạn mã, ZZ0000ZZ
hoặc thẻ ZZ0001ZZ (hoặc xem lại nhận xét) từ một nhà bảo trì duy nhất là
đủ để đáp ứng yêu cầu này.

Nếu quá trình xem xét hoặc xác nhận một thay đổi cụ thể sẽ mất nhiều thời gian hơn
hơn thời gian xem xét dự kiến cho hệ thống con, người bảo trì nên
trả lời bài nộp cho biết rằng công việc đang được thực hiện và khi nào
để mong đợi kết quả đầy đủ.

Tái cấu trúc và thay đổi cốt lõi
----------------------------

Đôi khi mã lõi cần được thay đổi để cải thiện khả năng bảo trì
của hạt nhân nói chung. Những người bảo trì dự kiến sẽ có mặt và
giúp hướng dẫn và kiểm tra các thay đổi đối với mã của họ để phù hợp với cơ sở hạ tầng mới.

Báo cáo lỗi
-----------

Người bảo trì phải đảm bảo các vấn đề nghiêm trọng trong mã của họ được báo cáo cho họ
được giải quyết kịp thời: hồi quy, sự cố kernel, cảnh báo kernel,
lỗi biên dịch, khóa, mất dữ liệu và các lỗi khác có phạm vi tương tự.

Ngoài ra, người bảo trì nên phản hồi các báo cáo về các loại lỗi khác
cũng có lỗi nếu báo cáo có chất lượng hợp lý hoặc chỉ ra một lỗi
vấn đề có thể nghiêm trọng -- đặc biệt nếu họ có ZZ0000ZZ
trạng thái của cơ sở mã trong tệp MAINTAINERS.

Phát triển mở
----------------

Thảo luận về các vấn đề được người dùng báo cáo và phát triển mã mới
nên được tiến hành theo cách điển hình cho hệ thống con lớn hơn.
Việc phát triển trong một công ty thường được tiến hành
đằng sau những cánh cửa đóng kín. Tuy nhiên, sự phát triển và thảo luận đã bắt đầu
của các thành viên cộng đồng không được chuyển hướng từ diễn đàn công khai sang diễn đàn đóng
hoặc đến các cuộc trò chuyện email riêng tư. Các trường hợp ngoại lệ hợp lý đối với hướng dẫn này
bao gồm các cuộc thảo luận về các vấn đề liên quan đến bảo mật.

Lựa chọn người bảo trì
========================

Phần trước mô tả những kỳ vọng của người bảo trì,
phần này cung cấp hướng dẫn về cách chọn một và mô tả các điểm chung
những quan niệm sai lầm.

tác giả
----------

Sự lựa chọn tự nhiên và phổ biến nhất của người bảo trì là tác giả của mã.
Tác giả rành về code nên là người giỏi nhất
để chăm sóc nó một cách liên tục.

Điều đó nói lên rằng, trở thành người bảo trì là một vai trò tích cực. Tệp MAINTAINERS
không phải là danh sách các khoản tín dụng (trên thực tế tồn tại một tệp CREDITS riêng biệt),
đó là danh sách những người sẽ tích cực trợ giúp về mã.
Nếu tác giả không có thời gian, hứng thú hoặc khả năng duy trì
mã, một người bảo trì khác phải được chọn.

Nhiều người bảo trì
--------------------

Các phương pháp thực hành tốt nhất hiện đại quy định rằng phải có ít nhất hai người bảo trì
cho bất kỳ đoạn mã nào, cho dù tầm thường đến đâu. Nó chia sẻ gánh nặng, giúp
mọi người đi nghỉ và tránh tình trạng kiệt sức, đào tạo thành viên mới của
cộng đồng, v.v.. Ngay cả khi rõ ràng có một ứng cử viên hoàn hảo,
một người bảo trì khác nên được tìm thấy.

Người bảo trì phải là con người, do đó, việc thêm địa chỉ gửi thư là không thể chấp nhận được.
danh sách hoặc email nhóm với tư cách là người duy trì. Sự tin tưởng và hiểu biết là
nền tảng của việc bảo trì kernel và người ta không thể xây dựng niềm tin bằng việc gửi thư
danh sách. Có một danh sách gửi thư ZZ0000ZZ cho con người là hoàn toàn ổn.

Cơ cấu doanh nghiệp
--------------------

Đối với người ngoài, nhân Linux có thể giống một tổ chức có thứ bậc
với Linus là CEO. Trong khi mã chạy theo kiểu phân cấp,
mẫu công ty không áp dụng ở đây. Linux là một tình trạng hỗn loạn được tổ chức
với nhau bằng (hiếm khi được thể hiện) sự tôn trọng, tin tưởng và thuận tiện lẫn nhau.

Tất cả những điều đó nhằm nói lên rằng các nhà quản lý hầu như không bao giờ trở thành những người bảo trì giỏi.
Vị trí của người bảo trì phù hợp hơn với vòng quay theo yêu cầu
hơn là một vị trí quyền lực.

Các đặc điểm sau đây của người được chọn làm người bảo trì
là những lá cờ đỏ rõ ràng:

- cộng đồng chưa biết, chưa bao giờ gửi email đến danh sách trước đó
 - không phải là tác giả của bất kỳ mã nào
 - (khi ký hợp đồng phát triển) làm việc cho một công ty được trả lương
   cho sự phát triển chứ không phải là công ty đã thực hiện công việc đó

Không tuân thủ
==============

Người bảo trì hệ thống con có thể xóa người bảo trì không hoạt động khỏi MAINTAINERS
tập tin. Nếu người bảo trì là một tác giả quan trọng hoặc đóng một vai trò quan trọng
vai trò trong việc phát triển mã, chúng nên được chuyển sang tệp CREDITS.

Việc loại bỏ một trình bảo trì không hoạt động không nên được coi là một hành động trừng phạt.
Việc có một người bảo trì không hoạt động sẽ gây ra một chi phí thực sự vì tất cả các nhà phát triển đều phải trả
phải nhớ đưa những người bảo trì vào các cuộc thảo luận và hệ thống con
những người bảo trì dành năng lực trí óc để tìm ra cách thu hút phản hồi.

Người bảo trì hệ thống con có thể xóa mã do thiếu bảo trì.

Người bảo trì hệ thống con có thể từ chối chấp nhận mã từ các công ty
đã nhiều lần bỏ bê nhiệm vụ bảo trì của mình.