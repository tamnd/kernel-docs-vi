.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/testing-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Hướng dẫn kiểm tra hạt nhân
====================


Có một số công cụ khác nhau để kiểm tra nhân Linux, vì vậy việc biết
khi nào sử dụng từng cái có thể là một thách thức. Tài liệu này cung cấp một cái nhìn sơ bộ
tổng quan về sự khác biệt của chúng và cách chúng phù hợp với nhau.


Viết và chạy thử nghiệm
=========================

Phần lớn các bài kiểm tra kernel được viết bằng kselftest hoặc KUnit
khuôn khổ. Cả hai đều cung cấp cơ sở hạ tầng để giúp thực hiện các thử nghiệm đang chạy và
các nhóm bài kiểm tra dễ dàng hơn cũng như cung cấp những trợ giúp để hỗ trợ việc viết bài mới
các bài kiểm tra.

Nếu bạn đang tìm cách xác minh hoạt động của Kernel — đặc biệt cụ thể
các phần của kernel — khi đó bạn sẽ muốn sử dụng KUnit hoặc kselftest.


Sự khác biệt giữa KUnit và kselftest
------------------------------------------

KUnit (Documentation/dev-tools/kunit/index.rst) là một hệ thống hoàn toàn trong kernel
đối với kiểm thử "hộp trắng": vì mã kiểm tra là một phần của kernel nên nó có thể truy cập
các cấu trúc và chức năng bên trong không được tiếp xúc với không gian người dùng.

Do đó, các bài kiểm tra KUnit được viết tốt nhất trên các phần nhỏ, khép kín
của hạt nhân, có thể được kiểm tra một cách độc lập. Điều này phù hợp tốt với
khái niệm về thử nghiệm 'đơn vị'.

Ví dụ: kiểm tra KUnit có thể kiểm tra một chức năng hạt nhân riêng lẻ (hoặc thậm chí một
đường dẫn mã đơn thông qua một hàm, chẳng hạn như trường hợp xử lý lỗi), thay vì
hơn là một tính năng nói chung.

Điều này cũng làm cho các bài kiểm tra KUnit được xây dựng và chạy rất nhanh, cho phép chúng được
chạy thường xuyên như một phần của quá trình phát triển.

There is a KUnit test style guide which may give further pointers in
Tài liệu/dev-tools/kunit/style.rst


Mặt khác, kselftest (Documentation/dev-tools/kselftest.rst) là
phần lớn được triển khai trong không gian người dùng và các thử nghiệm là các tập lệnh không gian người dùng thông thường hoặc
các chương trình.

Điều này làm cho việc viết các bài kiểm tra phức tạp hơn hoặc các bài kiểm tra cần
thao túng trạng thái tổng thể của hệ thống nhiều hơn (ví dụ: quá trình sinh sản, v.v.).
Tuy nhiên, không thể gọi trực tiếp các hàm kernel từ kselftest.
Điều này có nghĩa là chỉ có chức năng kernel được tiếp xúc với không gian người dùng bằng cách nào đó
(ví dụ: bằng syscall, thiết bị, hệ thống tập tin, v.v.) có thể được kiểm tra bằng kselftest.  Đến
giải quyết vấn đề này, một số thử nghiệm bao gồm mô-đun hạt nhân đồng hành cho thấy
thêm thông tin hoặc chức năng. Nếu thử nghiệm diễn ra chủ yếu hoặc hoàn toàn trong
kernel, tuy nhiên, KUnit có thể là công cụ thích hợp hơn.

do đó, kselftest rất phù hợp để kiểm tra toàn bộ tính năng, vì chúng sẽ
hiển thị giao diện cho không gian người dùng, giao diện này có thể được kiểm tra nhưng không thể triển khai
chi tiết. Điều này phù hợp tốt với thử nghiệm 'hệ thống' hoặc 'từ đầu đến cuối'.

Ví dụ: tất cả các lệnh gọi hệ thống mới phải đi kèm với các bài kiểm tra kselftest.

Công cụ bảo hiểm mã
===================

Nhân Linux hỗ trợ hai công cụ đo mức độ bao phủ mã khác nhau. Những cái này
có thể được sử dụng để xác minh rằng thử nghiệm đang thực hiện các chức năng hoặc dòng cụ thể
của mã. Điều này rất hữu ích để xác định số lượng hạt nhân đang được thử nghiệm,
và để tìm các trường hợp góc không được kiểm tra thích hợp.

Documentation/dev-tools/gcov.rst là công cụ kiểm tra mức độ phù hợp của GCC, có thể
được sử dụng với kernel để có được phạm vi phủ sóng toàn cầu hoặc từng mô-đun. Không giống như KCOV, nó
không ghi lại mức độ bao phủ của mỗi nhiệm vụ. Dữ liệu bảo hiểm có thể được đọc từ debugfs,
và diễn giải bằng cách sử dụng công cụ gcov thông thường.

Documentation/dev-tools/kcov.rst là một tính năng có thể được tích hợp trong
kernel để cho phép nắm bắt mức độ phù hợp ở cấp độ mỗi tác vụ. Vì vậy nó rất hữu ích
để làm mờ và các tình huống khác trong đó thông tin về mã được thực thi trong,
ví dụ, một cuộc gọi chung là hữu ích.


Công cụ phân tích động
======================

Hạt nhân cũng hỗ trợ một số công cụ phân tích động nhằm cố gắng
phát hiện các loại sự cố khi chúng xảy ra trong kernel đang chạy. Những điều này thường
mỗi loại tìm kiếm một loại lỗi khác nhau, chẳng hạn như truy cập bộ nhớ không hợp lệ,
các vấn đề tương tranh như chạy đua dữ liệu hoặc hành vi không xác định khác như
tràn số nguyên.

Một số công cụ này được liệt kê dưới đây:

* kmemleak phát hiện rò rỉ bộ nhớ có thể xảy ra. Xem
  Tài liệu/dev-tools/kmemleak.rst
* KASAN phát hiện các truy cập bộ nhớ không hợp lệ như truy cập ngoài giới hạn và
  lỗi sử dụng sau miễn phí. Xem Tài liệu/dev-tools/kasan.rst
* UBSAN phát hiện hành vi không được xác định theo tiêu chuẩn C, như số nguyên
  tràn. Xem Tài liệu/dev-tools/ubsan.rst
* KCSAN phát hiện các cuộc đua dữ liệu. Xem Tài liệu/dev-tools/kcsan.rst
* KFENCE là công cụ phát hiện các vấn đề về bộ nhớ với chi phí thấp, nhanh hơn nhiều so với
  KASAN và có thể được sử dụng trong sản xuất. Xem Tài liệu/dev-tools/kfence.rst
* lockdep là trình xác nhận tính chính xác của khóa. Xem
  Tài liệu/khóa/lockdep-design.rst
* Xác minh thời gian chạy (RV) hỗ trợ kiểm tra các hành vi cụ thể cho một
  hệ thống con. Xem Tài liệu/trace/rv/runtime-verification.rst
* Có một số phần của công cụ gỡ lỗi khác trong kernel, nhiều phần
  trong số đó có thể được tìm thấy trong lib/Kconfig.debug

Những công cụ này có xu hướng kiểm tra toàn bộ kernel và không "vượt qua" như
kiểm tra kselftest hoặc KUnit. Chúng có thể được kết hợp với KUnit hoặc kselftest bằng cách
chạy thử nghiệm trên kernel với các công cụ này được kích hoạt: khi đó bạn có thể chắc chắn
rằng không có lỗi nào trong số này xảy ra trong quá trình thử nghiệm.

Một số công cụ này tích hợp với KUnit hoặc kselftest và sẽ
tự động thất bại trong các bài kiểm tra nếu phát hiện thấy sự cố.

Công cụ phân tích tĩnh
=====================

Ngoài việc kiểm tra kernel đang chạy, người ta còn có thể phân tích mã nguồn kernel
trực tiếp (ZZ0000ZZ) bằng công cụ ZZ0001ZZ. Các công cụ
thường được sử dụng trong kernel cho phép người ta kiểm tra toàn bộ cây nguồn hoặc chỉ
tập tin cụ thể bên trong nó. Chúng giúp việc phát hiện và khắc phục sự cố dễ dàng hơn trong quá trình
quá trình phát triển.

Sparse có thể giúp kiểm tra kernel bằng cách thực hiện kiểm tra kiểu, kiểm tra khóa,
kiểm tra phạm vi giá trị, ngoài việc báo cáo các lỗi và cảnh báo khác nhau trong khi
kiểm tra mã. Xem tài liệu Documentation/dev-tools/sparse.rst
trang để biết chi tiết về cách sử dụng nó.

Smatch mở rộng Sparse và cung cấp các kiểm tra bổ sung cho logic lập trình
những lỗi như thiếu dấu ngắt trong câu lệnh switch, giá trị trả về không được sử dụng trên
kiểm tra lỗi, quên đặt mã lỗi khi trả về đường dẫn lỗi,
v.v. Smatch cũng có các bài kiểm tra đối với các vấn đề nghiêm trọng hơn như số nguyên
tràn, hủy tham chiếu con trỏ null và rò rỉ bộ nhớ. Xem trang dự án tại
ZZ0000ZZ

Coccinelle là một máy phân tích tĩnh khác mà chúng tôi sử dụng. Coccinelle thường được sử dụng
để hỗ trợ tái cấu trúc và phát triển tài sản thế chấp của mã nguồn, nhưng nó cũng có thể giúp
để tránh một số lỗi nhất định xảy ra trong các mẫu mã phổ biến. Các loại bài kiểm tra
có sẵn bao gồm các bài kiểm tra API, các bài kiểm tra cách sử dụng đúng các trình vòng lặp kernel, kiểm tra
về tính hợp lý của các hoạt động tự do, phân tích hành vi khóa và hơn thế nữa
các bài kiểm tra được biết là giúp duy trì việc sử dụng kernel nhất quán. Xem
Trang tài liệu Documentation/dev-tools/coccinelle.rst để biết chi tiết.

Tuy nhiên, hãy cẩn thận rằng các công cụ phân tích tĩnh bị ảnh hưởng bởi ZZ0000ZZ.
Các lỗi và cảnh báo cần được đánh giá cẩn thận trước khi cố gắng khắc phục chúng.

Khi nào nên sử dụng Sparse và Smatch
-----------------------------

Kiểm tra kiểu thưa thớt, chẳng hạn như xác minh rằng các biến chú thích không
gây ra lỗi endianness, phát hiện những nơi sử dụng con trỏ ZZ0000ZZ không đúng cách,
và phân tích tính tương thích của các bộ khởi tạo ký hiệu.

Smatch thực hiện phân tích luồng và nếu được phép xây dựng cơ sở dữ liệu chức năng, nó sẽ
cũng thực hiện phân tích chức năng chéo. Smatch cố gắng trả lời các câu hỏi như ở đâu
bộ đệm này có được phân bổ không? Nó lớn đến mức nào? Liệu chỉ số này có thể được kiểm soát bởi
người dùng? Biến này có lớn hơn biến kia không?

Nói chung, việc viết séc trong Smatch dễ dàng hơn so với việc viết séc trong
Thưa thớt. Tuy nhiên, có một số điểm trùng lặp giữa kiểm tra Sparse và Smatch.

Điểm mạnh của Smatch và Coccinelle
--------------------------------------

Coccinelle có lẽ là cách viết séc dễ dàng nhất. Nó hoạt động trước
bộ tiền xử lý để việc kiểm tra lỗi trong macro bằng Coccinelle dễ dàng hơn.
Coccinelle cũng tạo các bản vá cho bạn, điều mà không công cụ nào khác làm được.

Ví dụ: với Coccinelle bạn có thể thực hiện chuyển đổi hàng loạt từ
ZZ0000ZZ đến ZZ0001ZZ và
that's really useful. Nếu bạn vừa tạo cảnh báo Smatch và cố gắng đẩy
công việc chuyển đổi sang những người bảo trì họ sẽ khó chịu. Bạn sẽ phải
tranh luận về từng cảnh báo nếu thực sự có thể tràn hay không.

Coccinelle không phân tích các giá trị thay đổi, đây là điểm mạnh của
Trận đấu. Mặt khác, Coccinelle cho phép bạn thực hiện những việc đơn giản một cách đơn giản
cách.