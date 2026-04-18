.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/vdo-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Thiết kế của dm-vdo
===================

Mục tiêu dm-vdo (trình tối ưu hóa dữ liệu ảo) cung cấp tính năng chống trùng lặp nội tuyến,
nén, loại bỏ khối không và cung cấp mỏng. Mục tiêu dm-vdo
có thể được hỗ trợ bởi dung lượng lưu trữ lên tới 256TB và có thể hiển thị kích thước logic của
lên đến 4PB. Mục tiêu này ban đầu được phát triển tại Permabit Technology
Corp. bắt đầu từ năm 2009. Nó được phát hành lần đầu tiên vào năm 2013 và đã được sử dụng trong
môi trường sản xuất kể từ đó. Nó được tạo thành nguồn mở vào năm 2017 sau
Permabit đã được Red Hat mua lại. Tài liệu này mô tả thiết kế của
dm-vdo. Để biết cách sử dụng, hãy xem vdo.rst trong cùng thư mục với tệp này.

Bởi vì tỷ lệ loại bỏ trùng lặp giảm đáng kể khi kích thước khối tăng lên, nên
Mục tiêu vdo có kích thước khối tối đa là 4K. Tuy nhiên nó có thể đạt được
tỷ lệ chống trùng lặp là 254:1, tức là có thể lên tới 254 bản sao của một khối 4K nhất định
tham chiếu một bộ nhớ thực tế 4K. Nó có thể đạt được tốc độ nén
là 14:1. Tất cả các khối bằng 0 đều không tiêu tốn dung lượng lưu trữ nào cả.

Lý thuyết hoạt động
===================

Thiết kế của dm-vdo dựa trên ý tưởng rằng việc chống trùng lặp là một quá trình gồm hai phần.
vấn đề. Đầu tiên là nhận biết dữ liệu trùng lặp. Thứ hai là tránh
lưu trữ nhiều bản sao của những bản sao đó. Do đó, dm-vdo có hai chính
các bộ phận: chỉ mục chống trùng lặp (được gọi là UDS) được sử dụng để khám phá
dữ liệu trùng lặp và kho lưu trữ dữ liệu có bản đồ khối được tính tham chiếu
ánh xạ từ các địa chỉ khối logic tới vị trí lưu trữ thực tế của
dữ liệu.

Vùng và luồng
-------------------

Do sự phức tạp của việc tối ưu hóa dữ liệu, số lượng siêu dữ liệu
các cấu trúc liên quan đến một thao tác ghi vào mục tiêu vdo lớn hơn
hơn hầu hết các mục tiêu khác. Hơn nữa, vì vdo phải hoạt động ở quy mô nhỏ
kích thước khối để đạt được tỷ lệ trùng lặp tốt, chấp nhận được
hiệu suất chỉ có thể đạt được thông qua sự song song. Vì vậy, vdo
thiết kế cố gắng không bị khóa.

Hầu hết cấu trúc dữ liệu chính của vdo được thiết kế để có thể dễ dàng chia thành
"vùng" sao cho bất kỳ sinh học cụ thể nào cũng chỉ được truy cập vào một vùng duy nhất của bất kỳ vùng nào được phân vùng
cấu trúc. Đạt được sự an toàn với khả năng khóa tối thiểu bằng cách đảm bảo rằng trong quá trình
hoạt động bình thường, mỗi vùng được gán cho một luồng cụ thể và chỉ vùng đó
thread sẽ truy cập vào phần cấu trúc dữ liệu trong vùng đó.
Liên kết với mỗi luồng là một hàng đợi công việc. Mỗi sinh vật được liên kết với một
đối tượng yêu cầu ("data_vio") sẽ được thêm vào hàng đợi công việc khi
giai đoạn hoạt động tiếp theo của nó yêu cầu quyền truy cập vào các cấu trúc trong
vùng liên kết với hàng đợi đó.

Một cách nghĩ khác về sự sắp xếp này là hàng đợi công việc cho
mỗi vùng có một khóa ngầm trên các cấu trúc mà nó quản lý cho tất cả các vùng của nó.
hoạt động, vì vdo đảm bảo rằng không có luồng nào khác sẽ thay đổi các hoạt động đó
các cấu trúc.

Mặc dù mỗi cấu trúc được chia thành các khu vực nhưng sự phân chia này không
được phản ánh trong sự biểu diễn trên đĩa của mỗi cấu trúc dữ liệu. Vì vậy,
số lượng vùng cho mỗi cấu trúc và do đó số lượng luồng,
có thể được cấu hình lại mỗi khi mục tiêu vdo được bắt đầu.

Chỉ số chống trùng lặp
-----------------------

Để xác định dữ liệu trùng lặp một cách hiệu quả, vdo được thiết kế để
tận dụng một số đặc điểm chung của dữ liệu trùng lặp. Từ thực nghiệm
quan sát, chúng tôi đã thu thập được hai hiểu biết quan trọng. Đầu tiên là trong hầu hết dữ liệu
các tập hợp có số lượng dữ liệu trùng lặp đáng kể, các bản sao có xu hướng
có địa phương theo thời gian. Khi một bản sao xuất hiện, nhiều khả năng là
các bản sao khác sẽ được phát hiện và những bản sao đó sẽ được
được viết vào khoảng thời gian đó. Đây là lý do tại sao chỉ mục này lưu giữ các bản ghi trong
trật tự thời gian. Cái nhìn sâu sắc thứ hai là dữ liệu mới có nhiều khả năng
sao chép dữ liệu gần đây hơn là sao chép dữ liệu cũ hơn và nói chung,
có lợi nhuận giảm dần khi nhìn xa hơn về quá khứ. Vì vậy,
khi chỉ mục đầy, nó sẽ loại bỏ các bản ghi cũ nhất để nhường chỗ cho
những cái mới. Một ý tưởng quan trọng khác đằng sau việc thiết kế chỉ số là
Mục tiêu cuối cùng của việc chống trùng lặp là giảm chi phí lưu trữ. Vì có một
sự cân bằng giữa dung lượng lưu trữ được tiết kiệm và nguồn lực sử dụng để đạt được
những khoản tiết kiệm đó, vdo không cố gắng tìm mọi khối trùng lặp cuối cùng. Nó
là đủ để tìm và loại bỏ phần lớn sự dư thừa.

Mỗi khối dữ liệu được băm để tạo ra tên khối 16 byte. Một chỉ mục
bản ghi bao gồm tên khối này được ghép nối với vị trí giả định của
dữ liệu đó trên bộ lưu trữ cơ bản. Tuy nhiên, không thể
đảm bảo rằng chỉ số là chính xác. Trong trường hợp phổ biến nhất, điều này xảy ra
bởi vì việc cập nhật chỉ mục khi một khối bị ghi đè là quá tốn kém
hoặc bị loại bỏ. Làm như vậy sẽ yêu cầu lưu trữ tên khối cùng với
với các khối, điều này khó thực hiện hiệu quả trong mô hình dựa trên khối
lưu trữ hoặc đọc và thử lại từng khối trước khi ghi đè lên nó.
Sự không chính xác cũng có thể xảy ra do xung đột hàm băm trong đó hai khối khác nhau
có cùng tên. Trong thực tế, điều này cực kỳ khó xảy ra, nhưng vì
vdo không sử dụng hàm băm mật mã, khối lượng công việc độc hại có thể
được xây dựng. Vì những điểm không chính xác này nên vdo xử lý các vị trí trong
lập chỉ mục dưới dạng gợi ý và đọc từng khối được chỉ định để xác minh rằng nó thực sự là
một bản sao trước khi chia sẻ khối hiện có với khối mới.

Hồ sơ được tập hợp thành các nhóm gọi là chương. Các bản ghi mới được thêm vào
chương mới nhất, gọi là chương mở. Chương này được lưu trữ trong một
định dạng được tối ưu hóa cho việc thêm và sửa đổi các bản ghi cũng như nội dung của
chương mở chưa được hoàn thiện cho đến khi hết chỗ cho các bản ghi mới.
Khi chương mở đầy, nó sẽ đóng lại và một chương mở mới sẽ được
được tạo ra để thu thập các bản ghi mới.

Đóng một chương sẽ chuyển đổi nó sang một định dạng khác được tối ưu hóa cho
đọc. Các bản ghi được ghi vào một loạt các trang bản ghi dựa trên
thứ tự mà chúng được nhận. Điều này có nghĩa là các bản ghi có thời gian
địa phương nên có trên một số lượng trang nhỏ, giảm lượng I/O cần thiết để
lấy chúng. Chương này cũng biên soạn một chỉ mục cho biết
trang bản ghi có chứa bất kỳ tên cụ thể nào. Chỉ số này có nghĩa là một yêu cầu cho một
tên có thể xác định chính xác trang bản ghi nào có thể chứa bản ghi đó,
mà không cần phải tải toàn bộ chương từ bộ lưu trữ. Chỉ số này sử dụng
chỉ một tập hợp con của tên khối làm khóa của nó, vì vậy nó không thể đảm bảo rằng
mục nhập chỉ mục đề cập đến tên khối mong muốn. Nó chỉ có thể đảm bảo rằng nếu
có một bản ghi cho tên này, nó sẽ ở trên trang được chỉ định. Đã đóng
các chương là cấu trúc chỉ đọc và nội dung của chúng không bao giờ bị thay đổi trong
bất kỳ cách nào.

Khi đã ghi đủ số bản ghi để điền vào tất cả các chỉ mục có sẵn
khoảng trống, chương cũ nhất sẽ được lược bỏ để nhường chỗ cho các chương mới. bất kỳ
thời điểm yêu cầu tìm thấy bản ghi phù hợp trong chỉ mục, bản ghi đó sẽ được sao chép
vào chương mở. Điều này đảm bảo rằng các tên khối hữu ích vẫn có sẵn
trong chỉ mục, trong khi các tên khối không được tham chiếu sẽ bị lãng quên theo thời gian.

Để tìm các bản ghi trong các chương cũ hơn, chỉ mục cũng duy trì một
cấu trúc cấp cao hơn được gọi là chỉ số khối lượng, chứa các mục
ánh xạ từng tên khối vào chương chứa bản ghi mới nhất của nó. Cái này
ánh xạ được cập nhật khi các bản ghi cho tên khối được sao chép hoặc cập nhật,
đảm bảo rằng chỉ có thể tìm thấy bản ghi mới nhất cho một tên khối nhất định.
Bản ghi cũ hơn cho tên khối sẽ không còn được tìm thấy ngay cả khi nó có
chưa bị xóa khỏi chương của nó. Giống như mục lục chương, mục lục tập
chỉ sử dụng một tập hợp con của tên khối làm khóa và không thể xác định rõ ràng
nói rằng một bản ghi tồn tại cho một cái tên. Nó chỉ có thể nói chương nào sẽ
chứa bản ghi nếu bản ghi tồn tại. Chỉ số âm lượng được lưu trữ hoàn toàn
trong bộ nhớ và chỉ được lưu vào bộ lưu trữ khi mục tiêu vdo bị tắt.

Từ quan điểm của một yêu cầu về một tên khối cụ thể, trước tiên nó sẽ
tra cứu tên trong chỉ số âm lượng. Tìm kiếm này sẽ chỉ ra rằng
tên mới hoặc chương nào cần tìm. Nếu nó trả về một chương,
yêu cầu tra cứu tên của nó trong chỉ mục chương. Điều này sẽ chỉ ra
tên đó là mới hoặc trang bản ghi nào cần tìm kiếm. Cuối cùng, nếu không
mới, yêu cầu sẽ tìm tên của nó trong trang bản ghi được chỉ định.
Quá trình này có thể yêu cầu tối đa hai lần đọc trang cho mỗi yêu cầu (một cho
trang chỉ mục chương và một trang cho trang yêu cầu). Tuy nhiên, gần đây
các trang đã truy cập được lưu vào bộ nhớ đệm để những lần đọc trang này có thể được phân bổ theo
nhiều yêu cầu tên khối.

Chỉ mục tập và chỉ mục chương được thực hiện bằng cách sử dụng
cấu trúc hiệu quả về bộ nhớ được gọi là chỉ mục delta. Thay vì lưu trữ các
toàn bộ tên khối (khóa) cho mỗi mục, các mục được sắp xếp theo tên
và chỉ sự khác biệt giữa các khóa liền kề (delta) được lưu trữ.
Bởi vì chúng tôi kỳ vọng các giá trị băm sẽ được phân phối ngẫu nhiên nên kích thước của
vùng đồng bằng tuân theo sự phân bố theo cấp số nhân. Nhờ sự phân bố này,
vùng delta được thể hiện bằng mã Huffman để chiếm ít không gian hơn.
Toàn bộ danh sách các khóa được sắp xếp được gọi là danh sách delta. Cấu trúc này
cho phép chỉ mục sử dụng ít byte hơn cho mỗi mục nhập so với hàm băm truyền thống
bảng, nhưng việc tra cứu các mục sẽ tốn kém hơn một chút, bởi vì
yêu cầu phải đọc mọi mục trong danh sách delta để cộng các delta theo thứ tự
để tìm bản ghi nó cần. Chỉ số delta giảm chi phí tra cứu này bằng cách
chia không gian khóa của nó thành nhiều danh sách con, mỗi danh sách bắt đầu từ một khóa cố định
giá trị, sao cho mỗi danh sách riêng lẻ đều ngắn.

Kích thước chỉ mục mặc định có thể chứa 64 triệu bản ghi, tương ứng với khoảng
256GB dữ liệu. Điều này có nghĩa là chỉ mục có thể xác định dữ liệu trùng lặp nếu
dữ liệu gốc được ghi trong vòng 256GB lần ghi cuối cùng. Phạm vi này là
được gọi là cửa sổ chống trùng lặp. Nếu mới ghi dữ liệu trùng lặp cũ hơn
hơn thế, chỉ mục sẽ không thể tìm thấy nó vì các bản ghi của
dữ liệu cũ hơn đã bị xóa. Điều này có nghĩa là nếu một ứng dụng viết một
Tệp 200 GB vào mục tiêu vdo và sau đó ghi lại ngay lập tức, cả hai
bản sao sẽ được sao chép một cách hoàn hảo. Làm tương tự với tệp 500 GB sẽ
dẫn đến không bị trùng lặp vì phần đầu của tập tin sẽ không có
còn ở trong chỉ mục vào thời điểm lần ghi thứ hai bắt đầu (giả sử có
không có sự trùng lặp trong chính tệp đó).

Nếu một ứng dụng dự đoán khối lượng công việc dữ liệu sẽ hữu ích
chống trùng lặp vượt quá ngưỡng 256GB, vdo có thể được cấu hình để sử dụng
chỉ mục lớn hơn với cửa sổ chống trùng lặp lớn hơn tương ứng. (Cái này
cấu hình chỉ có thể được đặt khi mục tiêu được tạo, không thể thay đổi
sau này. Điều quan trọng là phải xem xét khối lượng công việc dự kiến cho mục tiêu vdo
trước khi định cấu hình nó.) Có hai cách để thực hiện việc này.

Một cách là tăng kích thước bộ nhớ của chỉ mục, điều này cũng làm tăng
lượng lưu trữ sao lưu cần thiết. Việc tăng gấp đôi kích thước của chỉ mục sẽ
nhân đôi chiều dài của cửa sổ loại bỏ trùng lặp với chi phí tăng gấp đôi
kích thước lưu trữ và yêu cầu bộ nhớ.

Tùy chọn khác là kích hoạt lập chỉ mục thưa thớt. Lập chỉ mục thưa thớt tăng
cửa sổ chống trùng lặp theo hệ số 10, với chi phí cũng
tăng kích thước lưu trữ lên gấp 10. Tuy nhiên với mật độ lưu trữ thưa thớt
lập chỉ mục, yêu cầu bộ nhớ không tăng. Sự đánh đổi là
tính toán nhiều hơn một chút cho mỗi yêu cầu và giảm nhẹ số lượng
của sự trùng lặp được phát hiện. Đối với hầu hết các khối lượng công việc có số lượng đáng kể
dữ liệu trùng lặp, lập chỉ mục thưa thớt sẽ phát hiện 97-99% trùng lặp
mà một chỉ mục tiêu chuẩn sẽ phát hiện.

Cấu trúc vio và data_vio
-------------------------------

Vio (viết tắt của Vdo I/O) về mặt khái niệm tương tự như tiểu sử, có thêm
các trường và dữ liệu để theo dõi thông tin cụ thể về vdo. Một struct vio duy trì một
con trỏ tới tiểu sử mà còn theo dõi các trường khác cụ thể cho hoạt động của
vdo. Vio được tách biệt khỏi tiểu sử liên quan của nó vì có nhiều
trường hợp vdo hoàn thành tiểu sử nhưng phải tiếp tục làm việc
liên quan đến chống trùng lặp hoặc nén.

Đọc và ghi siêu dữ liệu cũng như các thao tác ghi khác bắt nguồn từ vdo, hãy sử dụng
một cấu trúc vio trực tiếp. Ứng dụng đọc và ghi sử dụng cấu trúc lớn hơn
được gọi là data_vio để theo dõi thông tin về tiến trình của họ. Một cấu trúc
data_vio chứa cấu trúc vio và cũng bao gồm một số trường khác
liên quan đến chống trùng lặp và các tính năng vdo khác. data_vio là
đơn vị ứng dụng chính hoạt động trong vdo. Mỗi data_vio tiến hành thông qua một
tập hợp các bước để xử lý dữ liệu ứng dụng, sau đó nó được đặt lại và
được trả về nhóm data_vios để sử dụng lại.

Có một nhóm cố định gồm 2048 data_vios. Con số này đã được chọn để ràng buộc
lượng công việc cần thiết để phục hồi sau sự cố. Ngoài ra,
điểm chuẩn đã chỉ ra rằng việc tăng quy mô của nhóm không
cải thiện đáng kể hiệu suất.

Kho dữ liệu
--------------

Kho dữ liệu được triển khai bởi ba cấu trúc dữ liệu chính, tất cả đều
phối hợp làm việc để giảm bớt hoặc khấu hao các cập nhật siêu dữ liệu trên nhiều dữ liệu
viết càng tốt.

ZZ0000ZZ

Phần lớn khối lượng vdo thuộc về kho phiến. Kho chứa một
bộ sưu tập các tấm. Các phiến có thể lên tới 32GB và được chia thành
ba phần. Hầu hết một bản sàn bao gồm một chuỗi tuyến tính gồm các khối 4K.
Các khối này được sử dụng để lưu trữ dữ liệu hoặc để giữ các phần của
bản đồ khối (xem bên dưới). Ngoài các khối dữ liệu, mỗi tấm còn có một bộ
bộ đếm tham chiếu, sử dụng 1 byte cho mỗi khối dữ liệu. Cuối cùng mỗi tấm
có một cuốn nhật ký.

Các cập nhật tham khảo được ghi vào nhật ký phiến. Khối tạp chí phiến là
được viết ra khi chúng đã đầy hoặc khi nhật ký khôi phục
yêu cầu họ làm như vậy để cho phép nhật ký khôi phục chính (xem bên dưới)
để giải phóng không gian. Nhật ký phiến được sử dụng cả để đảm bảo rằng
nhật ký phục hồi có thể thường xuyên giải phóng dung lượng và cũng để khấu hao chi phí
cập nhật các khối tham chiếu riêng lẻ. Các bộ đếm tham chiếu được lưu giữ trong
bộ nhớ và được ghi ra, mỗi khối một lần theo thứ tự cũ nhất, chỉ
khi có nhu cầu lấy lại không gian nhật ký bản sàn. Các thao tác ghi
được thực hiện ở chế độ nền khi cần thiết để chúng không gây thêm độ trễ cho
các hoạt động I/O cụ thể.

Mỗi tấm là độc lập với nhau. Họ được giao nhiệm vụ "vật lý
khu vực" theo kiểu vòng tròn. Nếu có vùng vật lý P thì tấm n
được gán cho vùng n mod P.

Kho phiến duy trì một cấu trúc dữ liệu nhỏ bổ sung, "slab
tóm tắt", được sử dụng để giảm lượng công việc cần thiết để quay lại
trực tuyến sau một sự cố. Bản tóm tắt bản duy trì một mục nhập cho mỗi bản
cho biết tấm sàn đã từng được sử dụng hay chưa, liệu tất cả các vật dụng của nó có
các bản cập nhật số lượng tham chiếu đã được lưu vào bộ nhớ và khoảng
nó đầy đến mức nào. Trong quá trình khôi phục, mỗi vùng vật lý sẽ cố gắng khôi phục
ít nhất một phiến, dừng lại bất cứ khi nào nó thu hồi được một phiến có một số
khối miễn phí. Khi mỗi khu vực có một số không gian hoặc đã xác định rằng không có không gian nào
sẵn có, mục tiêu có thể tiếp tục hoạt động bình thường ở chế độ xuống cấp. Đọc
và yêu cầu viết có thể được phục vụ, có thể với hiệu suất bị suy giảm,
trong khi phần còn lại của tấm bẩn được thu hồi.

ZZ0000ZZ

Bản đồ khối chứa ánh xạ logic đến vật lý. Có thể nghĩ
dưới dạng một mảng với một mục nhập cho mỗi địa chỉ logic. Mỗi mục là 5 byte,
36 bit trong đó chứa số khối vật lý chứa dữ liệu cho
địa chỉ logic đã cho. 4 bit còn lại được sử dụng để chỉ bản chất
của việc lập bản đồ. Trong số 16 trạng thái có thể có, một trạng thái đại diện cho địa chỉ logic
chưa được lập bản đồ (tức là nó chưa bao giờ được viết hoặc đã bị loại bỏ),
một trạng thái đại diện cho một khối không nén và 14 trạng thái còn lại được sử dụng để
chỉ ra rằng dữ liệu được ánh xạ đã được nén và dữ liệu nén nào
các khe trong khối nén chứa dữ liệu cho địa chỉ logic này.

Trong thực tế, mảng các mục ánh xạ được chia thành "khối bản đồ
trang", mỗi trang phù hợp với một khối 4K duy nhất. Mỗi trang bản đồ khối
bao gồm một tiêu đề và 812 mục ánh xạ. Mỗi trang bản đồ thực sự là
một lá của cây cơ số bao gồm các trang bản đồ khối ở mỗi cấp độ.
Có 60 cây cơ số được gán cho các vùng logic trong vòng
thời trang robin. (Nếu có L vùng logic thì cây n sẽ thuộc vùng n
mod L.) Ở mỗi cấp độ, các cây được xen kẽ, do đó địa chỉ logic
0-811 thuộc về cây 0, địa chỉ logic 812-1623 thuộc về cây 1, v.v.
trên. Việc xen kẽ được duy trì cho đến tận 60 nút gốc.
Chọn 60 cây sẽ có số cây phân bố đều trên mỗi vùng
cho một số lượng lớn số lượng vùng logic có thể. Kho lưu trữ 60
rễ cây được phân bổ tại thời điểm định dạng. Tất cả các trang bản đồ khối khác đều
được phân bổ ra khỏi tấm khi cần thiết. Sự phân bổ linh hoạt này tránh được
cần phân bổ trước không gian cho toàn bộ tập hợp ánh xạ logic và cả
làm cho việc tăng kích thước logic của vdo tương đối dễ dàng.

Khi hoạt động, bản đồ khối duy trì hai bộ đệm. Cấm giữ
toàn bộ cấp độ lá của cây trong bộ nhớ, do đó mỗi vùng logic
duy trì bộ đệm riêng của các trang lá. Kích thước của bộ đệm này là
có thể cấu hình tại thời điểm bắt đầu mục tiêu. Bộ đệm thứ hai được phân bổ khi bắt đầu
thời gian và đủ lớn để chứa tất cả các trang không có trang của toàn bộ
bản đồ khối. Bộ đệm này được điền khi cần các trang.

ZZ0000ZZ

Nhật ký khôi phục được sử dụng để khấu hao các bản cập nhật trên bản đồ khối và
kho phiến đá. Mỗi yêu cầu viết sẽ tạo ra một mục được thực hiện trong nhật ký.
Các mục nhập là "ánh xạ lại dữ liệu" hoặc "ánh xạ lại bản đồ khối". Đối với một dữ liệu
ánh xạ lại, nhật ký ghi lại địa chỉ logic bị ảnh hưởng và địa chỉ cũ và
ánh xạ vật lý mới. Để ánh xạ lại bản đồ khối, tạp chí ghi lại
số trang bản đồ khối và khối vật lý được phân bổ cho nó. Chặn bản đồ
các trang không bao giờ được thu hồi hoặc sử dụng lại, vì vậy ánh xạ cũ luôn bằng 0.

Mỗi mục nhật ký là một bản ghi ý định tóm tắt các cập nhật siêu dữ liệu
được yêu cầu cho data_vio. Nhật ký khôi phục phát hành một thông báo lỗi
trước khi ghi mỗi khối nhật ký để đảm bảo rằng dữ liệu vật lý cho
ánh xạ khối mới trong khối đó ổn định trên bộ lưu trữ và khối nhật ký
tất cả các lần ghi đều được cấp với bộ bit FUA để đảm bảo nhật ký khôi phục
bản thân các mục đã ổn định. Mục nhật ký và dữ liệu ghi nó
đại diện phải ổn định trên đĩa trước khi các cấu trúc siêu dữ liệu khác có thể
được cập nhật để phản ánh hoạt động. Những mục này cho phép thiết bị vdo
xây dựng lại ánh xạ logic sang vật lý sau một sự cố bất ngờ
gián đoạn như mất điện.

ZZ0000ZZ

Tất cả ghi I/O vào vdo đều không đồng bộ. Mỗi tiểu sử sẽ được thừa nhận ngay
vì vdo đã thực hiện đủ công việc để đảm bảo rằng nó có thể hoàn thành việc ghi
cuối cùng. Nói chung, dữ liệu cho I/O ghi được xác nhận nhưng không được xóa
có thể được xử lý như thể nó được lưu trữ trong bộ nhớ. Nếu một ứng dụng
yêu cầu dữ liệu phải ổn định khi lưu trữ, nó phải đưa ra lệnh xóa hoặc ghi
dữ liệu với bit FUA được đặt giống như bất kỳ I/O không đồng bộ nào khác. Tắt máy
mục tiêu vdo cũng sẽ xóa mọi I/O còn lại.

Ứng dụng viết bios hãy làm theo các bước được nêu dưới đây.

1. Data_vio được lấy từ nhóm data_vio và được liên kết với
    sinh học ứng dụng. Nếu không có sẵn data_vios, tiểu sử đến
    sẽ chặn cho đến khi có data_vio. Điều này tạo ra áp lực ngược
    vào ứng dụng. Nhóm data_vio được bảo vệ bằng khóa xoay.

Data_vio mới thu được được đặt lại và dữ liệu của tiểu sử được sao chép vào
    data_vio nếu đó là ghi và dữ liệu không phải là số 0. Dữ liệu
    phải được sao chép vì tiểu sử ứng dụng có thể được xác nhận trước
    quá trình xử lý data_vio hoàn tất, nghĩa là các bước xử lý sau
    sẽ không còn quyền truy cập vào tiểu sử ứng dụng. Sinh học ứng dụng
    cũng có thể nhỏ hơn 4K, trong trường hợp đó data_vio sẽ có
    đã đọc khối cơ bản và thay vào đó dữ liệu được sao chép qua
    phần có liên quan của khối lớn hơn.

2. data_vio đặt yêu cầu ("khóa logic") trên địa chỉ logic
    của sinh học. Điều quan trọng là phải ngăn chặn việc sửa đổi đồng thời các
    cùng một địa chỉ logic, vì việc loại bỏ trùng lặp liên quan đến các khối chia sẻ.
    Khiếu nại này được triển khai dưới dạng một mục trong bảng băm trong đó khóa được
    địa chỉ logic và giá trị là một con trỏ tới data_vio
    hiện đang xử lý địa chỉ đó.

Nếu một data_vio nhìn vào bảng băm và thấy rằng một data_vio khác đang
    đã hoạt động trên địa chỉ logic đó, nó sẽ đợi cho đến địa chỉ logic trước đó
    hoạt động kết thúc. Nó cũng gửi một tin nhắn để thông báo hiện tại
    người giữ khóa mà nó đang chờ đợi. Đáng chú ý nhất là một data_vio mới đang chờ
    đối với khóa logic sẽ đẩy bộ giữ khóa trước đó ra khỏi
    trình đóng gói nén (bước 8d) thay vì cho phép nó tiếp tục
    đang chờ được đóng gói.

Giai đoạn này yêu cầu data_vio có được khóa ngầm trên
    vùng logic thích hợp để ngăn chặn những sửa đổi đồng thời của
    có thể băm. Việc khóa ngầm này được xử lý bởi các bộ phận vùng
    được mô tả ở trên.

3. data_vio đi qua cây bản đồ khối để đảm bảo rằng tất cả
    các nút cây nội bộ cần thiết đã được phân bổ, bằng cách cố gắng tìm
    trang lá cho địa chỉ logic của nó. Nếu có bất kỳ trang cây bên trong nào
    bị thiếu, tại thời điểm này nó được cấp phát từ cùng một bộ nhớ vật lý
    pool được sử dụng để lưu trữ dữ liệu ứng dụng.

Một. Nếu bất kỳ nút trang nào trong cây chưa được phân bổ thì nó phải được
       được phân bổ trước khi việc ghi có thể tiếp tục. Bước này yêu cầu các
       data_vio để khóa nút trang cần được phân bổ. Cái này
       lock, giống như khóa khối logic ở bước 2, là một mục có thể băm
       khiến data_vios khác phải chờ quá trình phân bổ
       hoàn thành.

Khóa vùng logic tiềm ẩn được giải phóng trong khi việc phân bổ được thực hiện
       xảy ra, để cho phép các hoạt động khác theo cùng một logic
       vùng để tiếp tục. Chi tiết phân bổ giống như trong
       bước 4. Khi một nút mới được phân bổ, nút đó sẽ được thêm vào
       cây sử dụng quy trình tương tự để thêm ánh xạ khối dữ liệu mới.
       data_vio ghi lại ý định thêm nút mới vào khối
       cây bản đồ (bước 10), cập nhật số tham chiếu của khối mới
       (bước 11) và yêu cầu khóa vùng logic tiềm ẩn để thêm
       ánh xạ mới tới nút cây cha (bước 12). Một khi cây đã
       được cập nhật, data_vio sẽ tiếp tục đi xuống cây. Bất kỳ dữ liệu nào khác_vios
       chờ đợi sự phân bổ này cũng tiến hành.

b. Trong trường hợp trạng thái ổn định, các nút cây bản đồ khối sẽ
       được phân bổ, do đó data_vio chỉ duyệt cây cho đến khi tìm thấy
       nút lá cần thiết. Vị trí của bản đồ ("bản đồ khối
       slot") được ghi vào data_vio nên các bước sau không cần
       đi ngang qua cây lần nữa. Sau đó data_vio giải phóng ẩn ý
       khóa vùng logic.

4. Nếu khối là khối 0, chuyển sang bước 9. Nếu không, một lần thử sẽ được thực hiện
    được thực hiện để phân bổ một khối dữ liệu miễn phí. Sự phân bổ này đảm bảo rằng
    data_vio có thể ghi dữ liệu của nó ở đâu đó ngay cả khi chống trùng lặp và
    không thể nén được. Giai đoạn này có một khóa ngầm trên một
    vùng vật lý để tìm kiếm không gian trống trong vùng đó.

data_vio sẽ tìm kiếm từng phiến trong một vùng cho đến khi tìm thấy một bản trống
    chặn hoặc quyết định không có. Nếu vùng đầu tiên không còn chỗ trống,
    nó sẽ tiến hành tìm kiếm vùng vật lý tiếp theo bằng cách lấy ẩn
    khóa vùng đó và thả vùng trước đó cho đến khi tìm thấy
    chặn miễn phí hoặc hết vùng để tìm kiếm. data_vio sẽ có được một
    struct pbn_lock ("khóa khối vật lý") trên khối miễn phí. các
    struct pbn_lock cũng có một số trường để ghi lại các loại
    tuyên bố rằng data_vios có thể có trên các khối vật lý. pbn_lock là
    được thêm vào bảng băm giống như khóa khối logic ở bước 2. Điều này
    hashtable cũng được bao phủ bởi khóa vùng vật lý ngầm. các
    số tham chiếu của khối trống được cập nhật để ngăn chặn bất kỳ sự cố nào khác
    data_vio vì coi nó là miễn phí. Bộ đếm tham chiếu là một
    thành phần phụ của tấm và do đó cũng được bao phủ bởi ẩn
    khóa vùng vật lý.

5. Nếu nhận được sự phân bổ, data_vio có tất cả các tài nguyên mà nó
    cần hoàn thành bài viết. Tiểu sử ứng dụng có thể được bảo mật một cách an toàn
    thừa nhận vào thời điểm này. Việc xác nhận xảy ra một cách riêng biệt
    luồng để ngăn cuộc gọi lại ứng dụng chặn data_vio khác
    hoạt động.

Nếu không thể phân bổ được, data_vio sẽ tiếp tục
    cố gắng loại bỏ trùng lặp hoặc nén dữ liệu, nhưng tiểu sử thì không
    được xác nhận vì thiết bị vdo có thể đã hết dung lượng.

6. Lúc này vdo phải xác định nơi lưu trữ dữ liệu ứng dụng.
    Dữ liệu của data_vio được băm và hàm băm ("tên bản ghi") là
    được ghi lại trong data_vio.

7. data_vio dự trữ hoặc tham gia struct hash_lock, quản lý tất cả
    data_vios hiện đang ghi cùng một dữ liệu. Khóa băm hoạt động là
    được theo dõi trong bảng băm tương tự như cách khóa khối logic
    được theo dõi ở bước 2. Bảng băm này được bao phủ bởi khóa ngầm trên
    vùng băm.

Nếu không có khóa băm hiện có cho record_name của data_vio này, thì
    data_vio lấy khóa băm từ nhóm, thêm nó vào bảng băm,
    và tự đặt mình làm "tác nhân" của khóa băm mới. Nhóm hash_lock là
    cũng được bao phủ bởi khóa vùng băm ngầm. Tác nhân khóa băm sẽ
    thực hiện tất cả công việc để quyết định dữ liệu ứng dụng sẽ ở đâu
    được viết. Nếu khóa băm cho record_name của data_vio đã tồn tại,
    và dữ liệu của data_vio giống với dữ liệu của tác nhân, cái mới
    data_vio sẽ đợi tác nhân hoàn thành công việc rồi chia sẻ
    kết quả của nó.

Trong trường hợp hiếm hoi tồn tại khóa băm cho hàm băm của data_vio nhưng
    dữ liệu không khớp với tác nhân của khóa băm, data_vio chuyển sang
    bước 8h và cố gắng ghi dữ liệu trực tiếp. Điều này có thể xảy ra nếu hai
    ví dụ: các khối dữ liệu khác nhau tạo ra cùng một hàm băm.

8. Tác nhân khóa băm cố gắng loại bỏ trùng lặp hoặc nén dữ liệu của nó bằng
    các bước sau.

Một. Tác nhân khởi tạo và gửi yêu cầu chống trùng lặp được nhúng của nó
       (struct uds_request) vào chỉ mục chống trùng lặp. Điều này không
       yêu cầu data_vio nhận bất kỳ khóa nào vì các thành phần chỉ mục
       quản lý khóa riêng của họ. data_vio đợi cho đến khi nó nhận được
       phản hồi từ chỉ mục hoặc hết thời gian.

b. Nếu chỉ mục chống trùng lặp trả về lời khuyên, data_vio sẽ cố gắng
       có được khóa khối vật lý trên địa chỉ vật lý được chỉ định, trong
       để đọc dữ liệu và xác minh rằng nó giống với
       dữ liệu của data_vio và nó có thể chấp nhận nhiều tài liệu tham khảo hơn. Nếu
       địa chỉ vật lý đã bị khóa bởi data_vio khác, dữ liệu tại
       địa chỉ đó có thể sớm bị ghi đè nên không an toàn khi sử dụng
       địa chỉ để chống trùng lặp.

c. Nếu dữ liệu khớp và khối vật lý có thể thêm tham chiếu, thì
       tác nhân và bất kỳ data_vios nào khác đang chờ trên đó sẽ ghi lại điều này
       khối vật lý làm địa chỉ vật lý mới của họ và chuyển sang bước 9
       để ghi lại bản đồ mới của họ. Nếu có nhiều data_vios hơn trong hàm băm
       lock hơn là có sẵn tài liệu tham khảo, một trong những tài liệu còn lại
       data_vios trở thành đại lý mới và tiếp tục bước 8d như thể không
       lời khuyên hợp lệ đã được trả lại.

d. Nếu không tìm thấy khối trùng lặp có thể sử dụng được, trước tiên tác nhân sẽ kiểm tra xem
       nó có một khối vật lý được phân bổ (từ bước 3) mà nó có thể ghi
       đến. Nếu đại lý không có sự phân bổ, một số data_vio khác trong
       khóa băm có sự phân bổ sẽ đảm nhiệm vai trò là tác nhân. Nếu
       không có data_vios nào có khối vật lý được phân bổ, những lần ghi này
       đã hết dung lượng nên họ chuyển sang bước 13 để dọn dẹp.

đ. Tác nhân cố gắng nén dữ liệu của nó. Nếu dữ liệu không
       nén thì data_vio sẽ tiếp tục đến bước 8h để ghi dữ liệu của nó
       trực tiếp.

Nếu kích thước nén đủ nhỏ, tác nhân sẽ giải phóng
       khóa vùng băm ngầm và đi đến trình đóng gói (struct packer) nơi
       nó sẽ được đặt trong một thùng (struct packer_bin) cùng với các thùng khác
       data_vios. Tất cả các hoạt động nén đều yêu cầu khóa ngầm
       khu vực đóng gói.

Trình đóng gói có thể kết hợp tối đa 14 khối nén trong một 4k
       khối dữ liệu. Việc nén chỉ hữu ích nếu vdo có thể đóng gói ít nhất 2
       data_vios thành một khối dữ liệu duy nhất. Điều này có nghĩa là data_vio có thể
       chờ trong packer một thời gian dài tùy ý cho data_vios khác
       để điền vào khối nén. Có cơ chế để vdo làm
       đuổi data_vios đang chờ khi việc tiếp tục chờ sẽ gây ra
       vấn đề. Các trường hợp gây ra việc trục xuất bao gồm đơn đăng ký
       xả, tắt thiết bị hoặc data_vio tiếp theo đang cố ghi đè
       cùng một địa chỉ khối logic. Một data_vio cũng có thể bị đuổi khỏi
       trình đóng gói nếu nó không thể được ghép nối với bất kỳ khối nén nào khác
       trước khi các khối nén hơn cần sử dụng thùng của nó. Bị đuổi khỏi nhà
       data_vio sẽ chuyển sang bước 8h để ghi trực tiếp dữ liệu của nó.

f. Nếu đại lý lấp đầy thùng đóng gói, vì tất cả 14 vị trí của nó
       được sử dụng hoặc vì không còn chỗ trống nên nó được viết ra
       sử dụng khối vật lý được phân bổ từ một trong các data_vios của nó. Bước
       8d đã đảm bảo rằng có sẵn sự phân bổ.

g. Mỗi data_vio đặt khối nén làm địa chỉ vật lý mới.
       data_vio có được một khóa ngầm trên vùng vật lý và
       lấy được cấu trúc pbn_lock cho khối nén, đó là
       được sửa đổi thành khóa chung. Sau đó nó giải phóng vật lý tiềm ẩn
       khóa vùng và chuyển sang bước 8i.

h. Bất kỳ data_vio nào bị loại bỏ khỏi trình đóng gói sẽ có sự phân bổ từ
       bước 3. Nó sẽ ghi dữ liệu của mình vào khối vật lý được phân bổ đó.

Tôi. Sau khi dữ liệu được ghi, nếu data_vio là tác nhân của hàm băm
       khóa, nó sẽ lấy lại khóa vùng băm ngầm và chia sẻ nó
       địa chỉ vật lý với nhiều data_vios khác trong khóa băm càng tốt
       có thể. Sau đó, mỗi data_vio sẽ tiến tới bước 9 để ghi lại
       bản đồ mới.

j. Nếu tác nhân thực sự đã ghi dữ liệu mới (dù được nén hay không),
       chỉ số chống trùng lặp được cập nhật để phản ánh vị trí của
       dữ liệu mới. Sau đó, tác nhân sẽ giải phóng khóa vùng băm ngầm.

9. data_vio xác định ánh xạ trước đó của địa chỉ logic.
    Có một bộ đệm cho các trang lá bản đồ khối ("bộ đệm bản đồ khối"),
    bởi vì thường có quá nhiều nút lá bản đồ khối để lưu trữ
    hoàn toàn trong bộ nhớ. Nếu trang lá mong muốn không có trong bộ đệm,
    data_vio sẽ dành một chỗ trong bộ đệm và tải trang mong muốn
    vào đó, có thể sẽ xóa một trang cũ hơn được lưu trong bộ nhớ đệm. Data_vio thì
    tìm địa chỉ vật lý hiện tại cho địa chỉ logic này ("địa chỉ cũ
    ánh xạ vật lý"), nếu có và ghi lại nó. Bước này yêu cầu khóa
    trên các cấu trúc bộ đệm bản đồ khối, được bao phủ bởi vùng logic ngầm
    khóa.

10. data_vio tạo một mục trong nhật ký khôi phục có chứa
    địa chỉ khối logic, ánh xạ vật lý cũ và địa chỉ vật lý mới
    lập bản đồ. Việc thực hiện mục nhật ký này đòi hỏi phải nắm giữ những ý nghĩa tiềm ẩn
    khóa nhật ký phục hồi. data_vio sẽ đợi trong nhật ký cho đến khi tất cả
    các khối khôi phục cho đến khối chứa mục nhập của nó đã được ghi
    và được xóa để đảm bảo giao dịch ổn định khi lưu trữ.

11. Sau khi mục nhập nhật ký khôi phục ổn định, data_vio sẽ tạo hai bản
    các mục nhật ký: một mục tăng dần cho ánh xạ mới và một
    mục giảm dần cho ánh xạ cũ. Hai thao tác này đều yêu cầu
    giữ một chiếc khóa trên tấm vật lý bị ảnh hưởng, được bao phủ bởi sự ẩn giấu của nó
    khóa vùng vật lý. Để đảm bảo tính chính xác trong quá trình phục hồi, nhật ký bản sàn
    các mục trong bất kỳ nhật ký bản cụ thể nào cũng phải theo cùng thứ tự với
    các mục nhật ký phục hồi tương ứng. Vì vậy, nếu hai mục
    ở các khu vực khác nhau, chúng được thực hiện đồng thời và nếu chúng ở
    cùng một vùng, việc tăng luôn được thực hiện trước khi giảm trong
    để tránh tình trạng chảy tràn. Sau khi mỗi mục nhật ký bản được thực hiện trong
    bộ nhớ, số tham chiếu liên quan cũng được cập nhật trong bộ nhớ.

12. Sau khi hoàn tất cả hai lần cập nhật số tham chiếu, data_vio
    có được khóa vùng logic ngầm định và cập nhật
    ánh xạ logic-vật lý trong bản đồ khối để trỏ đến cái mới
    khối vật lý. Lúc này thao tác ghi đã hoàn tất.

13. Nếu data_vio có khóa băm, nó sẽ có được vùng băm ngầm
    lock và giải phóng khóa băm của nó vào nhóm.

Sau đó, data_vio có được khóa và giải phóng vùng vật lý tiềm ẩn
    cấu trúc pbn_lock mà nó giữ cho khối được phân bổ của nó. Nếu nó có một
    phân bổ mà nó không sử dụng, nó cũng đặt số lượng tham chiếu cho
    khối đó trở về 0 để giải phóng nó cho data_vios tiếp theo sử dụng.

Sau đó, data_vio có được khóa và giải phóng vùng logic ngầm định
    khóa khối logic có được ở bước 2.

Sau đó, tiểu sử ứng dụng sẽ được xác nhận nếu trước đó nó chưa được xác nhận
    được xác nhận và data_vio được trả về nhóm.

ZZ0000ZZ

Một ứng dụng đọc tiểu sử tuân theo một loạt các bước đơn giản hơn nhiều. Nó thực hiện các bước
1 và 2 trong đường dẫn ghi để lấy data_vio và khóa logic của nó
địa chỉ. Nếu đã có quá trình ghi data_vio cho logic đó
địa chỉ được đảm bảo hoàn thành, data_vio đã đọc sẽ sao chép
dữ liệu từ ghi data_vio và trả lại. Ngược lại nó sẽ tra cứu
ánh xạ logic-vật lý bằng cách duyệt qua cây bản đồ khối như ở bước 3,
sau đó đọc và có thể giải nén dữ liệu được chỉ định ở vị trí được chỉ định
địa chỉ khối vật lý Dữ liệu đã đọc_vio sẽ không phân bổ cây bản đồ khối
các nút nếu chúng bị thiếu. Nếu các nút bản đồ khối bên trong không tồn tại
Tuy nhiên, địa chỉ bản đồ khối logic vẫn phải chưa được ánh xạ và địa chỉ đọc
data_vio sẽ trả về tất cả các số 0. Dữ liệu đọc_vio xử lý việc dọn dẹp và
xác nhận như ở bước 13, mặc dù nó chỉ cần giải phóng logic
khóa và tự quay trở lại hồ bơi.

ZZ0000ZZ

Tất cả bộ nhớ trong vdo được quản lý dưới dạng khối 4KB, nhưng nó có thể chấp nhận ghi
nhỏ tới 512 byte. Yêu cầu xử lý ghi nhỏ hơn 4K
thao tác đọc-sửa-ghi đọc khối 4K có liên quan, sao chép
dữ liệu mới trên các lĩnh vực thích hợp của khối, sau đó khởi chạy một
thao tác ghi cho khối dữ liệu đã sửa đổi. Các giai đoạn đọc và ghi của
thao tác này gần giống với thao tác đọc và ghi thông thường
hoạt động và một data_vio duy nhất được sử dụng trong suốt hoạt động này.

ZZ0000ZZ

Khi một vdo được khởi động lại sau một sự cố, nó sẽ cố gắng khôi phục từ
tạp chí phục hồi. Trong giai đoạn chuẩn bị tiếp tục của lần khởi động tiếp theo,
nhật ký phục hồi được đọc. Phần tăng dần của các mục nhập hợp lệ được phát
vào bản đồ khối. Tiếp theo, các mục hợp lệ sẽ được phát theo thứ tự được yêu cầu,
vào các tạp chí phiến. Cuối cùng, mỗi vùng vật lý cố gắng phát lại ở
ít nhất một nhật ký bản sàn để xây dựng lại số lượng tham chiếu của một bản sàn.
Khi mỗi vùng có một số không gian trống (hoặc đã xác định rằng nó không có không gian trống),
vdo trở lại trực tuyến, trong khi phần còn lại của nhật ký phiến được
được sử dụng để xây dựng lại phần còn lại của số tham chiếu trong nền.

ZZ0000ZZ

Nếu vdo gặp lỗi không thể khôi phục, nó sẽ chuyển sang chế độ chỉ đọc.
Chế độ này chỉ ra rằng một số dữ liệu được xác nhận trước đó có thể đã bị
bị mất. Vdo có thể được hướng dẫn xây dựng lại tốt nhất có thể để
trở về trạng thái có thể ghi được. Tuy nhiên, việc này không bao giờ được thực hiện tự động do
đến khả năng dữ liệu đã bị mất. Trong quá trình xây dựng lại chỉ đọc,
bản đồ khối được khôi phục từ nhật ký khôi phục như trước. Tuy nhiên,
số lượng tài liệu tham khảo không được xây dựng lại từ các tạp chí bản sàn. Thay vào đó,
số lượng tham chiếu bằng 0, toàn bộ bản đồ khối được duyệt qua và
số lượng tham chiếu được cập nhật từ ánh xạ khối. Trong khi điều này có thể mất
một số dữ liệu, nó đảm bảo rằng bản đồ khối và số lượng tham chiếu được
nhất quán với nhau. Điều này cho phép vdo tiếp tục hoạt động bình thường và
chấp nhận viết thêm.