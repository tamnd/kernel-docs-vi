.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/concepts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Tổng quan về khái niệm
======================

Việc quản lý bộ nhớ trong Linux là một hệ thống phức tạp được phát triển qua
năm và bao gồm ngày càng nhiều chức năng để hỗ trợ nhiều loại
hệ thống từ bộ vi điều khiển không có MMU đến siêu máy tính. Bộ nhớ
quản lý các hệ thống không có MMU được gọi là ZZ0000ZZ và nó
chắc chắn xứng đáng có một tài liệu chuyên dụng, hy vọng sẽ có
cuối cùng được viết. Tuy nhiên, mặc dù một số khái niệm giống nhau,
ở đây chúng tôi giả định rằng MMU có sẵn và CPU có thể dịch một ngôn ngữ ảo
địa chỉ đến một địa chỉ vật lý.

.. contents:: :local:

Bộ nhớ ảo Primer
=====================

Bộ nhớ vật lý trong hệ thống máy tính là một nguồn tài nguyên có hạn và
ngay cả đối với các hệ thống hỗ trợ cắm nóng bộ nhớ cũng có giới hạn cứng về
dung lượng bộ nhớ có thể được cài đặt. Bộ nhớ vật lý không
nhất thiết phải tiếp giáp nhau; nó có thể được truy cập dưới dạng một tập hợp riêng biệt
các dãy địa chỉ. Ngoài ra, các kiến trúc CPU khác nhau và thậm chí
các triển khai khác nhau của cùng một kiến trúc có các quan điểm khác nhau
về cách xác định các phạm vi địa chỉ này.

Tất cả điều này làm cho việc xử lý trực tiếp bộ nhớ vật lý trở nên khá phức tạp và
Để tránh sự phức tạp này, một khái niệm về bộ nhớ ảo đã được phát triển.

Bộ nhớ ảo trừu tượng hóa các chi tiết của bộ nhớ vật lý từ
phần mềm ứng dụng, cho phép chỉ giữ những thông tin cần thiết trong
bộ nhớ vật lý (phân trang theo yêu cầu) và cung cấp một cơ chế cho
bảo vệ và kiểm soát việc chia sẻ dữ liệu giữa các tiến trình.

Với bộ nhớ ảo, mỗi và mọi truy cập bộ nhớ đều sử dụng một
địa chỉ. Khi CPU giải mã một lệnh đọc (hoặc
ghi) từ (hoặc tới) bộ nhớ hệ thống, nó sẽ dịch ZZ0000ZZ
địa chỉ được mã hóa trong lệnh đó thành địa chỉ ZZ0001ZZ mà
bộ điều khiển bộ nhớ có thể hiểu được.

Bộ nhớ hệ thống vật lý được chia thành các khung trang hoặc các trang. các
kích thước của mỗi trang là kiến trúc cụ thể. Một số kiến trúc cho phép
lựa chọn kích thước trang từ một số giá trị được hỗ trợ; cái này
việc lựa chọn được thực hiện tại thời điểm xây dựng kernel bằng cách thiết lập một
tùy chọn cấu hình kernel thích hợp.

Mỗi trang bộ nhớ vật lý có thể được ánh xạ dưới dạng một hoặc nhiều trang ảo
trang. Những ánh xạ này được mô tả bởi các bảng trang cho phép
dịch từ địa chỉ ảo được chương trình sử dụng sang địa chỉ vật lý
địa chỉ bộ nhớ. Các bảng trang được tổ chức theo thứ bậc.

Các bảng ở mức thấp nhất của hệ thống phân cấp chứa các dữ liệu vật lý
địa chỉ của các trang thực tế được phần mềm sử dụng. Các bảng ở cao hơn
các cấp độ chứa địa chỉ vật lý của các trang thuộc cấp độ thấp hơn
cấp độ. Con trỏ tới bảng trang cấp cao nhất nằm trong một
đăng ký. Khi CPU thực hiện dịch địa chỉ, nó sử dụng
đăng ký để truy cập bảng trang cấp cao nhất. Các bit cao của
địa chỉ ảo được sử dụng để lập chỉ mục một mục trong trang cấp cao nhất
cái bàn. Mục nhập đó sau đó được sử dụng để truy cập cấp độ tiếp theo trong
phân cấp với các bit tiếp theo của địa chỉ ảo làm chỉ mục cho
bảng trang cấp độ đó. Các bit thấp nhất trong địa chỉ ảo xác định
phần bù bên trong trang thực tế.

Trang lớn
==========

Việc dịch địa chỉ yêu cầu một số quyền truy cập bộ nhớ và bộ nhớ
truy cập chậm tương đối với tốc độ CPU. Để tránh chi tiêu quý giá
bộ xử lý thực hiện chu kỳ dịch địa chỉ, CPU duy trì bộ nhớ đệm
những bản dịch như vậy được gọi là Bộ đệm tra cứu dịch thuật (hoặc
TLB). Thông thường TLB là nguồn tài nguyên và ứng dụng khá khan hiếm với
bộ làm việc có bộ nhớ lớn sẽ bị ảnh hưởng về hiệu suất do
TLB trượt.

Nhiều kiến trúc CPU hiện đại cho phép ánh xạ các trang bộ nhớ
trực tiếp bởi các cấp độ cao hơn trong bảng trang. Ví dụ: trên x86,
có thể ánh xạ các trang 2M và thậm chí 1G bằng cách sử dụng các mục trong phần thứ hai
và các bảng trang cấp ba. Trong Linux những trang như vậy được gọi là
ZZ0000ZZ. Việc sử dụng các trang lớn giúp giảm đáng kể áp lực lên TLB,
cải thiện tỷ lệ trúng TLB và do đó cải thiện hiệu suất hệ thống tổng thể.

Có hai cơ chế trong Linux cho phép ánh xạ vùng vật lý
bộ nhớ với các trang lớn. Cái đầu tiên là ZZ0000ZZ, hoặc
Hugetlbfs. Nó là một hệ thống tập tin giả sử dụng RAM làm nền tảng
cửa hàng. Đối với các tệp được tạo trong hệ thống tệp này, dữ liệu nằm trong
bộ nhớ và ánh xạ bằng cách sử dụng các trang lớn. Hugetlbfs được mô tả tại
Tài liệu/admin-guide/mm/hugetlbpage.rst.

Một cơ chế khác gần đây hơn cho phép sử dụng các trang lớn là
được gọi là ZZ0000ZZ, hoặc THP. Không giống như Hugetlbfs đó
yêu cầu người dùng và/hoặc quản trị viên hệ thống định cấu hình những phần nào của
bộ nhớ hệ thống nên và có thể được ánh xạ bởi các trang lớn, THP
quản lý các ánh xạ đó một cách minh bạch cho người dùng và do đó
tên. Xem Tài liệu/admin-guide/mm/transhuge.rst để biết thêm chi tiết
về THP.

Khu vực
=====

Thông thường phần cứng đặt ra những hạn chế về cách bộ nhớ vật lý khác nhau
phạm vi có thể được truy cập. Trong một số trường hợp, thiết bị không thể thực hiện DMA để
tất cả bộ nhớ có thể định địa chỉ. Trong các trường hợp khác, kích thước của vật lý
bộ nhớ vượt quá kích thước địa chỉ tối đa của bộ nhớ ảo và
cần có các hành động đặc biệt để truy cập các phần của bộ nhớ. Linux
nhóm các trang bộ nhớ vào ZZ0000ZZ theo khả năng có thể của chúng.
cách sử dụng. Ví dụ: ZONE_DMA sẽ chứa bộ nhớ có thể được sử dụng bởi
các thiết bị dành cho DMA, ZONE_HIGHMEM sẽ chứa bộ nhớ không
được ánh xạ vĩnh viễn vào không gian địa chỉ của kernel và ZONE_NORMAL sẽ
chứa các trang có địa chỉ thông thường.

Bố cục thực tế của các vùng bộ nhớ phụ thuộc vào phần cứng vì không phải tất cả
kiến trúc xác định tất cả các vùng và yêu cầu đối với DMA là khác nhau
cho các nền tảng khác nhau.

Nút
=====

Nhiều máy đa bộ xử lý là NUMA - Truy cập bộ nhớ không đồng nhất -
hệ thống. Trong các hệ thống như vậy, bộ nhớ được sắp xếp thành các ngân hàng có
độ trễ truy cập khác nhau tùy thuộc vào "khoảng cách" từ
bộ xử lý. Mỗi ngân hàng được gọi là ZZ0000ZZ và đối với mỗi nút Linux
xây dựng một hệ thống con quản lý bộ nhớ độc lập. Một nút có
tập hợp các vùng riêng, danh sách các trang miễn phí và được sử dụng cùng các số liệu thống kê khác nhau
quầy. Bạn có thể tìm thêm thông tin chi tiết về NUMA trong
Tài liệu/mm/numa.rst` và trong
Tài liệu/admin-guide/mm/numa_memory_policy.rst.

Bộ đệm trang
==========

Bộ nhớ vật lý dễ thay đổi và trường hợp phổ biến để lấy dữ liệu
vào bộ nhớ là đọc nó từ các tập tin. Bất cứ khi nào một tập tin được đọc,
dữ liệu được đưa vào ZZ0000ZZ để tránh truy cập đĩa đắt tiền trên
những lần đọc tiếp theo. Tương tự, khi người ta ghi vào một tập tin, dữ liệu
được đặt trong bộ nhớ đệm của trang và cuối cùng được đưa vào phần sao lưu
thiết bị lưu trữ. Các trang viết được đánh dấu là ZZ0001ZZ và khi Linux
quyết định sử dụng lại chúng cho các mục đích khác, nó đảm bảo đồng bộ hóa
nội dung tập tin trên thiết bị với dữ liệu được cập nhật.

Ký ức ẩn danh
================

ZZ0000ZZ hoặc ZZ0001ZZ đại diện cho bộ nhớ
không được hỗ trợ bởi hệ thống tập tin. Những ánh xạ như vậy được ngầm tạo ra
cho ngăn xếp và vùng nhớ của chương trình hoặc bằng các lệnh gọi rõ ràng tới hệ thống mmap(2)
gọi. Thông thường, ánh xạ ẩn danh chỉ xác định vùng bộ nhớ ảo
mà chương trình được phép truy cập. Việc truy cập đọc sẽ dẫn đến
trong việc tạo ra một mục bảng trang tham chiếu đến một vật lý đặc biệt
trang chứa đầy số không. Khi chương trình thực hiện việc ghi, một thông thường
trang vật lý sẽ được phân bổ để chứa dữ liệu bằng văn bản. trang
sẽ bị đánh dấu là bẩn và nếu hạt nhân quyết định sử dụng lại nó,
trang bẩn sẽ được hoán đổi.

Đòi lại
=======

Trong suốt vòng đời của hệ thống, một trang vật lý có thể được sử dụng để lưu trữ
các loại dữ liệu khác nhau. Nó có thể là cấu trúc dữ liệu bên trong kernel,
Bộ đệm DMA có thể sử dụng cho trình điều khiển thiết bị, đọc dữ liệu từ hệ thống tệp,
bộ nhớ được phân bổ bởi các tiến trình không gian của người dùng, v.v.

Tùy thuộc vào cách sử dụng trang, Linux sẽ xử lý khác nhau
quản lý bộ nhớ. Các trang có thể được giải phóng bất cứ lúc nào
bởi vì họ lưu trữ dữ liệu có sẵn ở nơi khác, chẳng hạn như trên một
đĩa cứng, hoặc vì chúng có thể được hoán đổi một lần nữa sang ổ cứng
đĩa, được gọi là ZZ0000ZZ. Các hạng mục đáng chú ý nhất của
các trang có thể lấy lại được là bộ đệm trang và bộ nhớ ẩn danh.

Trong hầu hết các trường hợp, các trang chứa dữ liệu kernel nội bộ và được sử dụng làm DMA
bộ đệm không thể được thay đổi mục đích và chúng vẫn được ghim cho đến khi được giải phóng bởi
người dùng của họ. Những trang như vậy được gọi là ZZ0000ZZ. Tuy nhiên, trong một số trường hợp nhất định
trong các trường hợp, thậm chí các trang chứa cấu trúc dữ liệu hạt nhân cũng có thể bị
được thu hồi. Ví dụ: bộ đệm trong bộ nhớ của siêu dữ liệu hệ thống tệp có thể
được đọc lại từ thiết bị lưu trữ và do đó có thể
loại bỏ chúng khỏi bộ nhớ chính khi hệ thống còn trong bộ nhớ
áp lực.

Quá trình giải phóng các trang bộ nhớ vật lý có thể lấy lại được và
tái sử dụng chúng được gọi là (ngạc nhiên chưa!) ZZ0001ZZ. Linux có thể lấy lại
các trang không đồng bộ hoặc đồng bộ, tùy thuộc vào trạng thái
của hệ thống. Khi hệ thống không được tải, phần lớn bộ nhớ sẽ trống
và các yêu cầu phân bổ sẽ được đáp ứng ngay lập tức từ
trang cung cấp. Khi tải tăng lên, số lượng trang miễn phí sẽ tăng lên
xuống và khi đạt đến một ngưỡng nhất định (hình mờ thấp),
yêu cầu phân bổ sẽ đánh thức daemon ZZ0000ZZ. Nó sẽ
quét không đồng bộ các trang bộ nhớ và chỉ giải phóng chúng nếu dữ liệu
chúng chứa có sẵn ở nơi khác hoặc bị trục xuất vào bộ lưu trữ dự phòng
thiết bị (bạn có nhớ những trang bẩn đó không?). Khi mức sử dụng bộ nhớ tăng lên thậm chí
nhiều hơn và đạt đến ngưỡng khác - hình mờ tối thiểu - phân bổ
sẽ kích hoạt ZZ0002ZZ. Trong trường hợp này việc phân bổ bị đình trệ
cho đến khi đủ số trang bộ nhớ được thu hồi để đáp ứng yêu cầu.

nén chặt
==========

Khi hệ thống chạy, các tác vụ sẽ phân bổ và giải phóng bộ nhớ và nó sẽ trở thành
bị phân mảnh. Mặc dù với bộ nhớ ảo có thể trình bày
các trang vật lý nằm rải rác như những phạm vi gần như liền kề nhau, đôi khi nó
cần thiết để phân bổ các vùng bộ nhớ liền kề về mặt vật lý lớn. Như vậy
nhu cầu có thể phát sinh, ví dụ, khi trình điều khiển thiết bị yêu cầu một lượng lớn
bộ đệm cho DMA hoặc khi THP phân bổ một trang lớn. Bộ nhớ ZZ0000ZZ
giải quyết vấn đề phân mảnh. Cơ chế này di chuyển các trang bị chiếm dụng
từ phần dưới của vùng nhớ đến các trang trống ở phần trên
của khu vực. Khi quá trình quét nén hoàn tất, các trang trống sẽ được nhóm lại
cùng nhau ở đầu khu vực và phân bổ số lượng lớn
các khu vực tiếp giáp về mặt vật lý trở nên khả thi.

Giống như việc thu hồi, quá trình nén có thể diễn ra không đồng bộ trong ZZ0000ZZ
daemon hoặc đồng bộ do yêu cầu cấp phát bộ nhớ.

Sát thủ OOM
==========

Có thể bộ nhớ của máy được tải sẽ cạn kiệt và
kernel sẽ không thể lấy lại đủ bộ nhớ để tiếp tục hoạt động. trong
để lưu phần còn lại của hệ thống, nó gọi ZZ0000ZZ.

ZZ0000ZZ chọn một nhiệm vụ để hy sinh vì lợi ích chung
sức khỏe hệ thống. Nhiệm vụ đã chọn sẽ bị hủy với hy vọng rằng sau khi nó thoát
đủ bộ nhớ sẽ được giải phóng để tiếp tục hoạt động bình thường.
