.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/multigen_lru.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
LRU đa thế hệ
==============
LRU đa thế hệ là một triển khai LRU thay thế giúp tối ưu hóa
lấy lại trang và cải thiện hiệu suất dưới áp lực bộ nhớ. Trang
lấy lại quyết định chính sách bộ nhớ đệm của kernel và khả năng vượt mức
trí nhớ. Nó ảnh hưởng trực tiếp đến việc sử dụng kswapd CPU và hiệu quả của RAM.

Tổng quan về thiết kế
===============
Mục tiêu
----------
Mục tiêu thiết kế là:

* Đại diện tốt về lượt truy cập gần đây
* Cố gắng kiếm lợi từ địa phương không gian
* Đường dẫn nhanh để đưa ra lựa chọn rõ ràng
* Phương pháp chẩn đoán tự sửa lỗi đơn giản

Việc thể hiện lần truy cập gần đây là cốt lõi của tất cả LRU
triển khai. Trong LRU đa thế hệ, mỗi thế hệ đại diện cho một
nhóm các trang có lần truy cập gần đây tương tự. Các thế hệ thiết lập một
(dựa trên thời gian) khung tham chiếu chung và do đó giúp cải thiện
các lựa chọn, ví dụ: giữa các memcgs khác nhau trên máy tính hoặc các
máy tính trong trung tâm dữ liệu (để lập kế hoạch công việc).

Khai thác không gian địa phương nâng cao hiệu quả khi thu thập
bit truy cập. Bước đi rmap nhắm mục tiêu vào một trang duy nhất và không cố gắng
kiếm lợi nhuận từ việc khám phá một chiếc PTE trẻ. Một trang bàn bước đi có thể quét sạch tất cả
các PTE non trẻ trong một không gian địa chỉ, nhưng không gian địa chỉ có thể quá
thưa thớt để kiếm lợi nhuận. Điều quan trọng là tối ưu hóa cả hai phương pháp và sử dụng
chúng kết hợp với nhau.

Đường dẫn nhanh làm giảm độ phức tạp của mã và chi phí thời gian chạy. Các trang chưa được ánh xạ
không yêu cầu xả TLB; các trang sạch không yêu cầu viết lại.
Những thông tin này chỉ hữu ích khi các điều kiện khác, ví dụ: khả năng tiếp cận
gần đây, tương tự nhau. Với các thế hệ là một hệ quy chiếu chung,
các yếu tố bổ sung nổi bật. Nhưng những lựa chọn rõ ràng có thể không tốt
sự lựa chọn; do đó việc tự điều chỉnh là cần thiết.

Lợi ích của phương pháp phỏng đoán tự sửa lỗi đơn giản là hiển nhiên.
Một lần nữa, với các thế hệ là một hệ quy chiếu chung, điều này trở thành
có thể đạt được. Cụ thể, các trang trong cùng một thế hệ có thể được
được phân loại dựa trên các yếu tố bổ sung và vòng phản hồi có thể
so sánh thống kê tỷ lệ phần trăm lỗi giữa các danh mục đó
và suy ra lựa chọn nào trong số đó là lựa chọn tốt hơn.

Giả định
-----------
Việc bảo vệ trang nóng và lựa chọn trang lạnh dựa trên
trên các kênh và mẫu truy cập trang. Có hai kênh truy cập:

* Truy cập thông qua bảng trang
* Truy cập thông qua mô tả tập tin

Việc bảo vệ kênh cũ được thiết kế mạnh mẽ hơn vì:

1. Sự không chắc chắn trong việc xác định các mô hình truy cập trước đây
   kênh cao hơn do tính gần đúng của bit được truy cập.
2. Chi phí loại bỏ kênh cũ cao hơn do TLB
   cần xả nước và khả năng gặp phải bit bẩn.
3. Hình phạt của việc bảo vệ kém kênh cũ sẽ cao hơn vì
   các ứng dụng thường không tự chuẩn bị cho trang chính
   những lỗi giống như lỗi xảy ra với I/O bị chặn. Ví dụ: ứng dụng GUI
   thường sử dụng các luồng I/O chuyên dụng để tránh chặn hiển thị
   chủ đề.

Ngoài ra còn có hai mẫu truy cập:

* Truy cập thể hiện địa phương thời gian
* Truy cập không hiển thị địa phương tạm thời

Vì những lý do được liệt kê ở trên, kênh cũ được coi là đi theo
mẫu trước trừ khi ZZ0000ZZ hoặc ZZ0001ZZ là
hiện tại và kênh sau được giả định nối tiếp kênh sau
mẫu trừ khi các lỗi bên ngoài đã được quan sát thấy.

Tổng quan về quy trình làm việc
=================
Các trang có thể bị loại bỏ được chia thành nhiều thế hệ cho mỗi thế hệ
ZZ0000ZZ. Số thế hệ trẻ nhất được lưu trữ trong
ZZ0001ZZ cho cả loại anon và loại tệp khi chúng cũ hơn
một nền tảng bình đẳng. Số thế hệ cũ nhất được lưu trữ trong
ZZ0002ZZ riêng biệt cho các loại tệp anon và tệp dưới dạng tệp sạch
các trang có thể bị loại bỏ bất kể ràng buộc trao đổi. Ba người này
các biến số đang tăng lên một cách đơn điệu.

Số thế hệ được cắt ngắn thành ZZ0000ZZ
bit để vừa với bộ đếm gen trong ZZ0001ZZ. Mỗi
số thế hệ bị cắt ngắn là chỉ số cho ZZ0002ZZ. các
kỹ thuật cửa sổ trượt được sử dụng để theo dõi ít nhất ZZ0003ZZ và
nhiều nhất là thế hệ ZZ0004ZZ. Bộ đếm gen lưu trữ một giá trị
trong ZZ0005ZZ khi một trang nằm trên một trong
ZZ0006ZZ; nếu không nó sẽ lưu trữ số không.

Mỗi thế hệ được chia thành nhiều tầng. Một trang được truy cập ZZ0000ZZ
lần thông qua bộ mô tả tệp nằm ở cấp ZZ0001ZZ. Không giống
thế hệ, tầng không có ZZ0002ZZ chuyên dụng. trong
trái ngược với việc di chuyển qua các thế hệ đòi hỏi phải có khóa LRU,
di chuyển qua các tầng chỉ liên quan đến các hoạt động nguyên tử trên
ZZ0003ZZ và do đó có chi phí không đáng kể. Một vòng phản hồi
được mô phỏng theo bộ điều khiển PID giám sát các lỗi trên tất cả các tầng
từ các loại anon và tệp và quyết định cấp độ nào từ loại nào sẽ
đuổi hoặc bảo vệ. Hiệu quả mong muốn là cân bằng tỷ lệ phần trăm lỗi
giữa các loại anon và tệp tỷ lệ thuận với mức độ hoán đổi.

Có hai quy trình độc lập về mặt khái niệm: lão hóa và
trục xuất. Chúng tạo thành một hệ thống khép kín, tức là lấy lại trang.

Lão hóa
-----
Sự lão hóa tạo ra thế hệ trẻ. Với một chiếc ZZ0000ZZ, nó
tăng ZZ0001ZZ khi ZZ0002ZZ đến gần
ZZ0003ZZ. Lão hóa đẩy trang nóng tới giới trẻ
tạo khi nó tìm thấy chúng được truy cập thông qua các bảng trang; cái
do đó việc hạ cấp các trang lạnh xảy ra khi nó tăng lên
ZZ0004ZZ. Quá trình lão hóa sử dụng các bước đi trong bảng trang và các bước đi rmap để tìm
PTE trẻ. Đối với cái trước, nó lặp lại ZZ0005ZZ
và gọi ZZ0006ZZ với mỗi ZZ0007ZZ trong danh sách này
để quét PTE và sau mỗi lần lặp, nó sẽ tăng ZZ0008ZZ. cho
phần sau, khi người bị trục xuất đi trên rmap và tìm thấy một PTE trẻ tuổi,
quá trình lão hóa sẽ quét các PTE lân cận. Đối với cả hai, việc tìm kiếm một chiếc PTE còn trẻ,
quá trình lão hóa sẽ xóa bit được truy cập và cập nhật bộ đếm gen của
trang được ánh xạ bởi PTE này tới ZZ0009ZZ.

Trục xuất
--------
Việc trục xuất tiêu tốn các thế hệ cũ. Cho một ZZ0000ZZ, nó
tăng ZZ0001ZZ khi ZZ0002ZZ được lập chỉ mục bởi
ZZ0003ZZ trở nên trống rỗng. Để chọn một loại và một bậc để
đuổi khỏi, đầu tiên nó sẽ so sánh ZZ0004ZZ để chọn loại cũ hơn.
Nếu cả hai loại đều cũ như nhau, nó sẽ chọn loại có cấp đầu tiên có
tỷ lệ lỗi thấp hơn. Tầng đầu tiên chứa loại sử dụng một lần
các trang sạch chưa được ánh xạ, đó là lựa chọn tốt nhất. Việc trục xuất sắp xếp một
trang theo bộ đếm gen của nó nếu quá trình lão hóa đã tìm thấy trang này
được truy cập thông qua các bảng trang và cập nhật bộ đếm gen của nó. Nó cũng
chuyển một trang sang thế hệ tiếp theo, tức là ZZ0005ZZ, nếu trang này
được truy cập nhiều lần thông qua bộ mô tả tập tin và phản hồi
vòng lặp đã phát hiện các lỗi ngoại vi từ cấp độ của trang này. Để
Cuối cùng, vòng phản hồi sử dụng tầng đầu tiên làm đường cơ sở, vì
lý do đã nêu trước đó.

Bảo vệ bộ làm việc
----------------------
Mỗi thế hệ được đánh dấu thời gian khi sinh. Nếu ZZ0000ZZ là
được thiết lập, ZZ0001ZZ được bảo vệ khỏi bị trục xuất khi nó cũ nhất
thế hệ được sinh ra trong vòng một phần nghìn giây của ZZ0002ZZ. Ở nơi khác
từ, nó ngăn cản tập hợp hoạt động của ZZ0003ZZ mili giây
khỏi việc bị đuổi ra khỏi nhà. Trình diệt OOM được kích hoạt nếu bộ làm việc này
không thể lưu giữ trong trí nhớ.

Cách tiếp cận dựa trên thời gian này có những ưu điểm sau:

1. Dễ dàng cấu hình hơn vì nó không phụ thuộc vào ứng dụng
   và kích thước bộ nhớ.
2. Nó đáng tin cậy hơn vì nó được nối trực tiếp với sát thủ OOM.

Danh sách ZZ0000ZZ
------------------
Danh sách ZZ0000ZZ được duy trì cho mỗi memcg và
ZZ0001ZZ tuân theo nhiệm vụ của chủ sở hữu nó tới memcg mới khi nhiệm vụ này
được di cư.

Một bộ khung trang lặp lại ZZ0000ZZ và gọi
ZZ0001ZZ với mỗi ZZ0002ZZ trong danh sách này để quét
PTE. Khi có nhiều trình duyệt bảng trang lặp lại cùng một danh sách, mỗi trình
họ có một chiếc ZZ0003ZZ độc nhất và do đó họ có thể chạy trong
song song.

Trình duyệt bảng trang bỏ qua bất kỳ trang nào bị đặt sai vị trí, ví dụ: nếu một
ZZ0000ZZ đã được di chuyển, các trang còn lại trong memcg trước đó sẽ được
bị bỏ qua khi memcg hiện tại đang được lấy lại. Tương tự, bảng trang
người đi bộ sẽ bỏ qua các trang từ các nút khác với nút được xác nhận lại.

Cơ sở hạ tầng này cũng theo dõi việc sử dụng ZZ0000ZZ giữa
chuyển ngữ cảnh để người đi trong bảng trang có thể bỏ qua các tiến trình
đã ngủ kể từ lần lặp cuối cùng.

Phản hồi đi bộ Rmap/PT
---------------------
Tìm kiếm rmap để ánh xạ PTE mỗi trang trên danh sách LRU (để kiểm tra
và xóa bit được truy cập) có thể tốn kém vì các trang từ
các VMA (không gian PA) khác nhau không thân thiện với bộ nhớ đệm đối với rmap (VA
không gian). Đối với khối lượng công việc chủ yếu sử dụng các trang được ánh xạ, việc tìm kiếm rmap
có thể phải chịu chi phí CPU cao nhất trong quá trình lấy lại.

ZZ0000ZZ khai thác vị trí không gian để giảm
chuyến đi vào rmap. Nó quét các PTE liền kề của PTE trẻ và
quảng cáo các trang nóng. Nếu quá trình quét được thực hiện bằng cacheline một cách hiệu quả, nó sẽ
thêm mục PMD trỏ đến bảng PTE vào bộ lọc Bloom. Cái này
tạo thành một vòng phản hồi giữa việc trục xuất và sự lão hóa.

Bộ lọc hoa
-------------
Bộ lọc Bloom là cấu trúc dữ liệu hiệu quả về không gian và bộ nhớ cho tập hợp
kiểm tra tư cách thành viên, tức là kiểm tra xem một phần tử có nằm trong tập hợp hay không hoặc có thể
trong bộ này.

Trong đường dẫn trục xuất, cụ thể là trong ZZ0000ZZ, nếu một
PMD có đủ số lượng trang nóng, địa chỉ của nó được đặt trong
bộ lọc. Trong lộ trình lão hóa, đặt tư cách thành viên có nghĩa là phạm vi PTE
sẽ được quét để tìm các trang trẻ.

Lưu ý rằng bộ lọc Bloom có ​​tính xác suất đối với tư cách thành viên đã đặt. Nếu một bài kiểm tra
là dương tính giả, chi phí là một lần quét bổ sung một loạt PTE,
dù sao cũng có thể mang lại những trang nóng. Các thông số của bộ lọc có thể
kiểm soát tỷ lệ dương tính giả trong giới hạn.

Bộ điều khiển PID
--------------
Một vòng phản hồi được mô hình hóa theo Tỷ lệ-Tích phân-Đạo hàm
Bộ điều khiển (PID) giám sát các lỗi trên các loại tệp và anon và
quyết định loại nào sẽ bị trục xuất khi cả hai loại đều có sẵn từ
cùng một thế hệ.

Bộ điều khiển PID sử dụng nhiều thế hệ thay vì đồng hồ treo tường làm
miền thời gian vì CPU có thể quét các trang ở các tốc độ khác nhau trong
áp lực bộ nhớ khác nhau. Nó tính toán mức trung bình động cho mỗi
thế hệ để tránh bị khóa vĩnh viễn ở trạng thái dưới mức tối ưu.

Memcg LRU
---------
Memcg LRU là LRU trên mỗi nút của memcgs. Nó cũng là LRU của LRU,
vì mỗi tổ hợp nút và memcg có LRU gồm các folio (xem
ZZ0000ZZ). Mục tiêu của nó là cải thiện khả năng mở rộng của
thu hồi toàn cục, điều này rất quan trọng đối với việc vượt quá mức bộ nhớ trên toàn hệ thống trong
trung tâm dữ liệu. Lưu ý rằng memcg LRU chỉ áp dụng cho việc thu hồi toàn cầu.

Cấu trúc cơ bản của một memcg LRU có thể được hiểu tương tự như
LRU hoạt động/không hoạt động (của folios):

1. Nó có người trẻ và người già (thế hệ), tức là những người tương ứng
   đến cái hoạt động và cái không hoạt động;
2. Việc tăng ZZ0000ZZ sẽ kích hoạt khuyến mãi, tức là
   đối tác kích hoạt;
3. Các sự kiện khác kích hoạt các hoạt động tương tự, ví dụ: ngoại tuyến một memcg
   kích hoạt việc giáng chức, tức là tương ứng với việc hủy kích hoạt.

Về mặt thu hồi toàn cầu, nó có hai đặc điểm riêng biệt:

1. Sharding, cho phép mỗi luồng bắt đầu ở một memcg ngẫu nhiên (trong
   thế hệ cũ) và cải thiện tính song song;
2. Sự công bằng cuối cùng, cho phép đòi lại trực tiếp hoặc giải cứu theo ý muốn
   và giảm độ trễ mà không ảnh hưởng đến sự công bằng theo thời gian.

Về mặt duyệt qua memcgs trong quá trình thu hồi toàn cầu, nó cải thiện
độ phức tạp trong trường hợp tốt nhất từ O(n) đến O(1) và không ảnh hưởng đến
độ phức tạp trong trường hợp xấu nhất O(n). Do đó, trung bình, nó có một tuyến tính phụ
sự phức tạp.

Bản tóm tắt
-------
LRU đa thế hệ (của folios) có thể được tháo rời thành các phần sau
bộ phận:

* Thế hệ
* Rmap đi bộ
* Bảng trang đi qua danh sách ZZ0000ZZ
* Bộ lọc Bloom cho phản hồi đi bộ rmap/PT
* Bộ điều khiển PID cho phản hồi mặc định

Sự lão hóa và sự trục xuất hình thành một mô hình nhà sản xuất-người tiêu dùng;
cụ thể là cái sau đẩy cái trước bằng cửa sổ trượt qua
nhiều thế hệ. Trong quá trình lão hóa, rmap bước đi lái xe bảng trang bước đi
chèn các bảng trang có mật độ dân số cao vào bộ lọc Bloom.
Trong quá trình trục xuất, bộ điều khiển PID sử dụng các giá trị lỗi làm phản hồi
để chọn loại cần loại bỏ và cấp độ cần bảo vệ.