.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/nfsd-maintainer-entry-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hồ sơ đăng nhập của người bảo trì NFSD
=============================

Hồ sơ mục nhập của người bảo trì bổ sung cho quy trình cấp cao nhất
các tài liệu (có trong Tài liệu/quy trình/) với hải quan
cụ thể cho một hệ thống con và những người bảo trì nó. Người đóng góp có thể sử dụng
tài liệu này để đặt ra những kỳ vọng của họ và tránh những lỗi thường gặp.
Người bảo trì có thể sử dụng các hồ sơ này để xem xét các hệ thống con để tìm
cơ hội hội tụ những thực tiễn chung tốt nhất.

Tổng quan
--------
Hệ thống tệp mạng (NFS) là một họ mạng được tiêu chuẩn hóa
các giao thức cho phép truy cập vào các tập tin trên một tập hợp mạng-
các máy chủ ngang hàng được kết nối. Các ứng dụng trên máy khách NFS truy cập các tệp
cư trú trên các hệ thống tệp được chia sẻ bởi máy chủ NFS. Một đĩa đơn
mạng ngang hàng có thể hoạt động như cả máy khách NFS và máy chủ NFS.

NFSD đề cập đến việc triển khai máy chủ NFS có trong Linux
hạt nhân. Máy chủ NFS trong kernel có khả năng truy cập nhanh vào các tệp được lưu trữ
trong các hệ thống tập tin cục bộ trên máy chủ đó. NFSD có thể chia sẻ tập tin được lưu trữ
trên hầu hết các loại hệ thống tệp có nguồn gốc từ Linux, bao gồm xfs,
ext4, btrfs và tmpfs.

Danh sách gửi thư
------------
Danh sách gửi thư linux-nfs@vger.kernel.org là danh sách công khai. của nó
Mục đích là để cho phép sự hợp tác giữa các nhà phát triển làm việc trên
Ngăn xếp Linux NFS, cả máy khách và máy chủ. Nó không phải là nơi dành cho
các cuộc hội thoại không liên quan trực tiếp đến ngăn xếp Linux NFS.

Danh sách gửi thư linux-nfs được lưu trữ trên ZZ0000ZZ.

Cộng đồng Linux NFS không có phòng trò chuyện.

Báo cáo lỗi
--------------
Nếu bạn gặp lỗi liên quan đến NFSD trên phiên bản được xây dựng phân phối
kernel, vui lòng bắt đầu bằng cách làm việc với nhà phân phối Linux của bạn.

Các báo cáo lỗi đối với các cơ sở mã Linux ngược dòng được hoan nghênh trên
danh sách gửi thư linux-nfs@vger.kernel.org, trong đó một số phân loại đang hoạt động
có thể được thực hiện Lỗi NFSD cũng có thể được báo cáo trong nhân Linux
bugzilla của cộng đồng tại:

ZZ0000ZZ

Vui lòng gửi các lỗi liên quan đến NFSD trong "Filesystems/NFSD"
thành phần. Nói chung, bao gồm càng nhiều chi tiết càng tốt là một
khởi đầu tốt đẹp, bao gồm các thông báo nhật ký hệ thống thích hợp từ cả hai
máy khách và máy chủ.

Phần mềm không gian người dùng liên quan đến NFSD, chẳng hạn như mountd hoặc importfs
lệnh, được chứa trong gói nfs-utils. Báo cáo vấn đề
với các thành phần đó vào linux-nfs@vger.kernel.org. Bạn có thể là
được hướng dẫn để chuyển báo cáo tới một trình theo dõi lỗi cụ thể.

Hướng dẫn dành cho người đóng góp
-------------------

Tuân thủ tiêu chuẩn
~~~~~~~~~~~~~~~~~~~~
Ưu tiên là NFSD tương thích hoàn toàn với Linux NFS
khách hàng. Chúng tôi cũng thử nghiệm với các ứng dụng khách NFS phổ biến khác.
thường xuyên tại các sự kiện nướng bánh NFS (còn được gọi là plug-
lễ hội). Máy khách NFS không phải Linux không phải là một phần của NFSD CI/CD ngược dòng.

Cộng đồng NFSD cố gắng cung cấp triển khai máy chủ NFS
tương thích với tất cả máy khách NFS tuân thủ tiêu chuẩn
triển khai. Điều này được thực hiện bằng cách ở gần nhất có thể
các nhiệm vụ quy phạm trong NFS, RPC và GSS-API đã xuất bản của IETF
tiêu chuẩn.

Việc tham chiếu RFC và số phần trong mã luôn hữu ích
bình luận khi hành vi đi chệch khỏi tiêu chuẩn (và ngay cả khi
hành vi tuân thủ nhưng việc triển khai lại khó hiểu).

Trong trường hợp hiếm hoi khi có sự sai lệch so với yêu cầu tiêu chuẩn
hành vi là cần thiết, tài liệu ngắn gọn về trường hợp sử dụng hoặc
những thiếu sót trong tiêu chuẩn là một phần bắt buộc của mã
tài liệu.

Phải luôn cẩn thận để tránh rò rỉ mã lỗi cục bộ (ví dụ:
errnos) cho khách hàng của NFSD. Mã trạng thái NFS thích hợp luôn được
được yêu cầu trong các phản hồi giao thức NFS.

Giao diện quản trị NFSD
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Giao diện quản trị NFSD bao gồm:

- tham số mô-đun NFSD hoặc SUNRPC

- tùy chọn xuất trong /etc/exports

- các tập tin trong /proc/fs/nfsd/ hoặc /proc/sys/sunrpc/

- giao thức liên kết mạng NFSD

Thông thường, một yêu cầu được đưa ra để giới thiệu hoặc sửa đổi một trong các NFSD
giao diện quản trị truyền thống. Chắc chắn là về mặt kỹ thuật
dễ dàng để giới thiệu một thiết lập hành chính mới. Tuy nhiên, có
những lý do chính đáng tại sao những người bảo trì NFSD lại thích để nó ở cuối
khu nghỉ dưỡng:

- Như với bất kỳ API nào, rất khó có được giao diện quản trị
  đúng.

- Một khi chúng được ghi chép lại và có giá trị sử dụng lâu dài, các hoạt động quản trị
  giao diện trở nên khó sửa đổi hoặc loại bỏ.

- Mỗi cài đặt quản trị mới sẽ nhân ma trận kiểm tra NFSD.

- Chi phí của một giao diện quản trị tăng dần, nhưng chi phí
  bổ sung trên tất cả các giao diện hiện có.

Thông thường sẽ tốt hơn cho mọi người nếu nỗ lực thực hiện trước
hiểu được yêu cầu cơ bản của bối cảnh mới và
sau đó cố gắng làm cho nó tự điều chỉnh (hoặc trở thành khác
không cần thiết).

Nếu một cài đặt mới thực sự cần thiết, trước tiên hãy xem xét thêm nó vào
giao thức liên kết mạng NFSD. Hoặc nếu nó không cần phải đáng tin cậy
tính năng không gian người dùng lâu dài, nó có thể được thêm vào danh sách của NFSD
cài đặt thử nghiệm nằm trong /sys/kernel/debug/nfsd/ .

Khả năng quan sát hiện trường
~~~~~~~~~~~~~~~~~~~
NFSD sử dụng một số cơ chế khác nhau để quan sát hoạt động,
bao gồm bộ đếm, bản in, CẢNH BÁO và các điểm theo dõi tĩnh. Mỗi
có điểm mạnh và điểm yếu của họ. Những người đóng góp nên chọn
công cụ thích hợp nhất cho nhiệm vụ của họ.

- Phải tránh BUG nếu có thể, vì nó sẽ thường xuyên xảy ra
  dẫn đến sự cố toàn bộ hệ thống.

- WARN chỉ thích hợp khi dấu vết ngăn xếp đầy đủ hữu ích.

- printk có thể hiển thị thông tin chi tiết. Những thứ này không được sử dụng
  trong các đường dẫn mã nơi chúng có thể được kích hoạt nhiều lần bằng điều khiển từ xa
  người dùng.

- dprintk có thể hiển thị thông tin chi tiết, nhưng chỉ có thể được kích hoạt
  trong các nhóm được thiết lập trước. Chi phí phát ra đầu ra làm cho dprintk
  không phù hợp cho các hoạt động thường xuyên như I/O.

- Bộ đếm luôn bật nhưng cung cấp rất ít thông tin về
  các sự kiện riêng lẻ ngoài tần suất chúng xảy ra.

- điểm theo dõi tĩnh có thể được kích hoạt riêng lẻ hoặc theo nhóm
  (thông qua một quả cầu). Đây thường là chi phí thấp và do đó
  được ưa chuộng để sử dụng trong các đường dẫn nóng.

- truy tìm động, chẳng hạn như kprobes hoặc eBPF, khá linh hoạt nhưng
  không thể được sử dụng trong một số môi trường nhất định (ví dụ: khóa kernel đầy đủ-
  xuống).

Kiểm tra
~~~~~~~
dự án kdevops

ZZ0000ZZ

chứa một số quy trình công việc dành riêng cho NFS, cũng như cộng đồng
bộ fstests tiêu chuẩn. Những quy trình công việc này dựa trên nguồn mở
các công cụ kiểm tra như ltp và fio. Những người đóng góp được khuyến khích
sử dụng những công cụ này mà không cần kdevops hoặc những người đóng góp nên cài đặt và
sử dụng chính kdevops để xác minh các bản vá của họ trước khi gửi.

Phong cách mã hóa
~~~~~~~~~~~~
Thực hiện theo các tùy chọn kiểu mã hóa được mô tả trong

Tài liệu/quy trình/coding-style.rst

với các ngoại lệ sau:

- Thêm các biến cục bộ mới vào hàm trong cây Giáng sinh đảo ngược
  đặt hàng

- Sử dụng kiểu bình luận kdoc cho
  + hàm không tĩnh
  + hàm nội tuyến tĩnh
  + các hàm tĩnh là hàm gọi lại/hàm ảo

- Tất cả các tên chức năng mới đều bắt đầu bằng ZZ0000ZZ cho phiên bản không phải NFS-
  các chức năng cụ thể.

- Tên hàm mới dành riêng cho NFSv2 hoặc NFSv3 hoặc
  được sử dụng bởi tất cả các phiên bản nhỏ của NFSv4, hãy sử dụng ZZ0000ZZ trong đó N là
  phiên bản.

- Tên chức năng mới dành riêng cho phiên bản phụ NFSv4 có thể được
  được đặt tên bằng ZZ0000ZZ trong đó M là phiên bản phụ.

Chuẩn bị bản vá
~~~~~~~~~~~~~~~~~
Đọc và làm theo tất cả các hướng dẫn trong

Tài liệu/quy trình/gửi-patches.rst

Sử dụng gắn thẻ để xác định tất cả các tác giả bản vá. Tuy nhiên, người đánh giá và
người kiểm tra nên được thêm vào bằng cách trả lời việc gửi bản vá qua email.
Email được sử dụng rộng rãi để lưu trữ công khai đánh giá và
thử nghiệm các thuộc tính. Các thẻ này được tự động chèn vào
các bản vá của bạn khi chúng được áp dụng.

Mã trong phần khác biệt đã hiển thị /what/ đang được
đã thay đổi. Vì vậy không cần thiết phải lặp lại điều đó trong bản vá
mô tả. Thay vào đó, mô tả nên chứa một hoặc nhiều
của:

- Một tuyên bố vấn đề ngắn gọn ("bản vá này đang cố gắng khắc phục điều gì?")
  với việc phân tích nguyên nhân gốc rễ.

- Các triệu chứng hoặc mục có thể nhìn thấy của người dùng cuối mà kỹ sư hỗ trợ có thể
  sử dụng để tìm kiếm bản vá, như dấu vết ngăn xếp.

- Giải thích ngắn gọn lý do tại sao bản vá là cách tốt nhất để giải quyết
  vấn đề.

- Bất kỳ bối cảnh nào mà người đánh giá có thể cần để hiểu những thay đổi
  được thực hiện bởi bản vá.

- Mọi kết quả đo điểm chuẩn và/hoặc kết quả kiểm tra chức năng có liên quan.

Như chi tiết trong Tài liệu/quy trình/gửi-patches.rst,
xác định thời điểm trong lịch sử mà vấn đề đang được giải quyết là
được giới thiệu bằng cách sử dụng thẻ Fixes:.

Đề cập trong phần mô tả bản vá nếu điểm đó trong lịch sử không thể được
được xác định -- nghĩa là không có Bản sửa lỗi: thẻ nào có thể được cung cấp. Trong trường hợp này,
vui lòng nói rõ với người bảo trì xem cổng sau LTS có
cần thiết mặc dù không có thẻ Fixes:.

Những người bảo trì NFSD thích tự thêm tính năng gắn thẻ ổn định hơn sau
thảo luận công khai để đáp lại việc gửi bản vá. Người đóng góp
có thể đề xuất gắn thẻ ổn định, nhưng hãy lưu ý rằng nhiều phiên bản
các công cụ quản lý thêm Cc ổn định như vậy khi bạn đăng các bản vá của mình.
Đừng thêm "Cc: stable" trừ khi bạn hoàn toàn chắc chắn về bản vá
cần phải chuyển sang trạng thái ổn định trong quá trình gửi ban đầu.

Gửi bản vá
~~~~~~~~~~~~~~~~
Các bản vá cho NFSD được gửi qua đánh giá dựa trên email của kernel
quá trình phổ biến cho hầu hết các hệ thống con hạt nhân khác.

Ngay trước mỗi lần gửi, hãy rebase bản vá hoặc chuỗi của bạn trên
chi nhánh thử nghiệm nfsd tại

ZZ0000ZZ

Hệ thống con NFSD được duy trì tách biệt với nhân Linux
Khách hàng NFS. Những người bảo trì NFSD thường không nhận bài nộp
đối với các thay đổi của khách hàng, họ cũng không thể phản hồi chính thức đối với lỗi
báo cáo hoặc yêu cầu tính năng cho mã máy khách NFS.

Điều này có nghĩa là những người đóng góp có thể được yêu cầu gửi lại các bản vá nếu
họ đã được gửi email đến nhóm người bảo trì và người đánh giá không chính xác.
Đây không phải là từ chối mà chỉ đơn giản là sửa lại bài gửi
quá trình.

Khi nghi ngờ, hãy tham khảo mục NFSD trong tệp MAINTAINERS để
xem tập tin và thư mục nào nằm trong hệ thống con NFSD.

Bộ địa chỉ email thích hợp cho các bản vá NFSD là:

Tới: người bảo trì và đánh giá NFSD được liệt kê trong MAINTAINERS
Cc: linux-nfs@vger.kernel.org và tùy chọn linux-kernel@

Nếu có các hệ thống con khác liên quan đến các bản vá (ví dụ:
MM hoặc RDMA), địa chỉ danh sách gửi thư chính của họ có thể được đưa vào
trường Cc:. Những người đóng góp khác và các bên quan tâm có thể
cũng được bao gồm ở đó.

Nói chung, chúng tôi mong muốn những người đóng góp sử dụng các công cụ email vá lỗi phổ biến
chẳng hạn như "git send-email" hoặc "stg email format/send", có xu hướng
có được các chi tiết ngay mà không cần nhiều phiền phức.

Một loạt bao gồm một bản vá không bắt buộc phải có
thư xin việc. Tuy nhiên, có thể gửi kèm thư xin việc nếu có.
bối cảnh quan trọng không phù hợp để đưa vào
mô tả bản vá.

Xin lưu ý rằng, với quy trình gửi dựa trên e-mail, hàng loạt
thư xin việc không phải là một phần công việc được cam kết với
cơ sở mã nguồn kernel hoặc lịch sử cam kết của nó. Vì thế hãy luôn cố gắng
để giữ thông tin thích hợp trong mô tả bản vá.

Tài liệu thiết kế được hoan nghênh, nhưng thư xin việc thì không
được bảo tồn, có lẽ một lựa chọn tốt hơn là đưa vào một bản vá bổ sung
tài liệu đó trong Documentation/filesystems/nfs/.

Người đánh giá sẽ hỏi về phạm vi kiểm thử và trường hợp sử dụng nào
các bản vá dự kiến ​​sẽ giải quyết. Hãy chuẩn bị sẵn sàng để trả lời những điều này
câu hỏi.

Đánh giá nhận xét từ người bảo trì có thể được nêu một cách lịch sự, nhưng trong
nói chung, những vấn đề này không phải là tùy chọn để giải quyết khi chúng có thể thực hiện được.
Nếu cần thiết, người bảo trì có quyền không áp dụng các bản vá
khi những người đóng góp từ chối giải quyết các yêu cầu hợp lý.

Đăng các thay đổi đối với mã nguồn hạt nhân và mã nguồn không gian người dùng dưới dạng
loạt riêng biệt. Bạn có thể kết nối hai chuỗi với các bình luận trong
thư xin việc của bạn.

Nói chung, những người bảo trì NFSD yêu cầu đăng lại ngay cả đối với những nội dung đơn giản
sửa đổi để lưu trữ công khai yêu cầu và
kết quả là đăng lại trước khi nó được kéo vào cây NFSD. Cái này
cũng cho phép chúng tôi xây dựng lại một loạt bản vá một cách nhanh chóng mà không bỏ sót
những thay đổi có thể đã được thảo luận qua email.

Tránh thường xuyên đăng lại loạt bài lớn chỉ với những thay đổi nhỏ. Như
nguyên tắc chung là đăng những thay đổi đáng kể nhiều hơn một lần một tuần
sẽ dẫn đến tình trạng quá tải của người đánh giá.

Hãy nhớ rằng chỉ có một số ít người bảo trì hệ thống con và
người đánh giá, nhưng có thể có nhiều nguồn đóng góp. các
do đó, người bảo trì và người đánh giá luôn là những người ít có khả năng mở rộng hơn
tài nguyên. Hãy tử tế với người bảo trì khu phố thân thiện của bạn.

Chấp nhận bản vá
~~~~~~~~~~~~~~~~
Không có quy trình đánh giá chính thức cho NFSD, nhưng chúng tôi muốn thấy
ít nhất hai Người được đánh giá: thông báo về các bản vá nhiều hơn
dọn dẹp đơn giản. Việc đánh giá được thực hiện công khai trên
linux-nfs@vger.kernel.org và được lưu trữ trên lore.kernel.org.

Hiện tại hàng đợi bản vá NFSD được duy trì ở các chi nhánh tại đây:

ZZ0000ZZ

Những người bảo trì NFSD ban đầu áp dụng các bản vá cho thử nghiệm nfsd
chi nhánh, luôn mở cho các bài nộp mới. Các bản vá có thể được
được áp dụng trong khi việc xem xét đang diễn ra. nfsd-testing là một nhánh chủ đề,
vì vậy nó có thể thay đổi thường xuyên, nó sẽ được khởi động lại và bản vá của bạn
có thể bị loại bỏ nếu có vấn đề với nó.

Nói chung, email "cảm ơn" do tập lệnh tạo sẽ cho biết khi nào
bản vá của bạn đã được thêm vào nhánh thử nghiệm nfsd. Bạn có thể theo dõi
tiến trình của bản vá của bạn bằng cách sử dụng phiên bản bản vá lỗi linux-nfs:

ZZ0000ZZ

Trong khi bản vá của bạn đang trong giai đoạn thử nghiệm nfsd, nó sẽ tiếp xúc với nhiều loại
môi trường thử nghiệm, bao gồm các bot cộng đồng zero-day, môi trường tĩnh
công cụ phân tích và thử nghiệm tích hợp liên tục NFSD. Ngâm
thời gian là ba đến bốn tuần.

Mỗi bản vá tồn tại trong thử nghiệm nfsd trong thời gian ngâm mà không có
những thay đổi được chuyển đến nhánh nfsd-next.

Nhánh nfsd-next được tự động sáp nhập vào linux-next và
fs-next hàng đêm.

Các bản vá tồn tại trong nfsd-next sẽ được đưa vào NFSD tiếp theo
yêu cầu kéo cửa sổ hợp nhất. Các cửa sổ này thường xuất hiện một lần mỗi
63 ngày (chín tuần).

Khi cửa sổ hợp nhất ngược dòng đóng lại, nhánh nfsd-next là
được đổi tên thành nfsd-fixes và một nhánh nfsd-next mới được tạo, dựa trên
thẻ -rc1 ngược dòng.

Các bản sửa lỗi dành cho bản phát hành ngược dòng -rc cũng chạy
găng tay kiểm tra nfsd, nhưng sau đó được áp dụng cho các bản sửa lỗi nfsd
chi nhánh. Nhánh đó được tạo sẵn để Linus kéo sau một
thời gian ngắn. Để hạn chế rủi ro xảy ra hiện tượng hồi quy,
chúng tôi giới hạn các bản sửa lỗi như vậy cho các tình huống khẩn cấp hoặc các bản sửa lỗi cho sự cố
đã xảy ra trong quá trình hợp nhất ngược dòng gần đây nhất.

Vui lòng làm rõ khi gửi bản vá khẩn cấp rằng
hành động ngay lập tức (ứng dụng vào cổng sau -rc hoặc LTS) là
cần thiết.

Gửi bản vá nhạy cảm và báo cáo lỗi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
CVE được tạo bởi các thành viên cụ thể của cộng đồng nhân Linux
và một số thực thể bên ngoài. Cộng đồng Linux NFS không phát ra
hoặc chỉ định CVE. CVE được chỉ định sau một sự cố và cách khắc phục sự cố đó là
được biết đến.

Tuy nhiên, những người bảo trì NFSD đôi khi nhận được bảo mật nhạy cảm
báo cáo, và đôi khi những báo cáo này đủ quan trọng để cần phải được
bị cấm vận. Trong những trường hợp hiếm hoi như vậy, các bản sửa lỗi có thể được phát triển và xem xét
ra khỏi tầm mắt của công chúng.

Xin lưu ý rằng nhiều công cụ quản lý phiên bản có thêm tính năng ổn định
Cc khi bạn đăng các bản vá của mình. Điều này nói chung là một mối phiền toái, nhưng
nó có thể vô tình dẫn đến một vấn đề bảo mật bị cấm vận.
Đừng thêm "Cc: stable" trừ khi bạn hoàn toàn chắc chắn về bản vá
cần truy cập vào stable@ trong quá trình gửi ban đầu.

Các bản vá được hợp nhất mà không bao giờ xuất hiện trên bất kỳ danh sách nào và
mang thẻ Người báo cáo: hoặc Bản sửa lỗi: được phát hiện là đáng ngờ
bởi những người tập trung vào an ninh. Chúng tôi khuyến khích điều đó, sau bất kỳ sự riêng tư nào
xem xét lại, các bản vá nhạy cảm về bảo mật phải được đăng lên linux-nfs@
cho giai đoạn xem xét, lưu trữ và kiểm tra công khai thông thường.

Bài gửi do LLM tạo
~~~~~~~~~~~~~~~~~~~~~~~~~
Toàn bộ cộng đồng nhân Linux vẫn đang khám phá những tính năng mới
thế giới mã do LLM tạo ra. Những người bảo trì NFSD sẽ giải trí
gửi các bản vá được tạo ra một phần hoặc toàn bộ bởi
Các công cụ phát triển dựa trên LLM. Những đệ trình như vậy được giữ lại cho
các tiêu chuẩn tương tự như các bài nộp được tạo ra hoàn toàn bởi con người:

- Người đóng góp con người tự xác định mình thông qua Người đăng ký:
  thẻ. Thẻ này được tính là DoC.

- Người đóng góp hoàn toàn chịu trách nhiệm về nguồn gốc mã
  và bất kỳ sự lây nhiễm nào do mã vô tình được đưa vào với một
  giấy phép xung đột, như thường lệ.

- Người đóng góp phải có khả năng trả lời và giải quyết vấn đề đánh giá
  câu hỏi. Mô tả bản vá chẳng hạn như "Điều này đã khắc phục được sự cố của tôi
  nhưng tôi không biết tại sao" là không thể chấp nhận được.

- Phần đóng góp phải tuân theo chế độ kiểm tra giống như tất cả
  các bài nộp khác.

- Một dấu hiệu (thông qua thẻ Được tạo bởi: hoặc cách khác) rằng
  không cần đóng góp LLM do ZZ tạo ra.

Thật dễ dàng để giải quyết các nhận xét đánh giá và yêu cầu khắc phục trong LLM
mã được tạo ra. Trên thực tế, dễ dàng đến mức việc đăng lại trở nên hấp dẫn
mã được làm mới ngay lập tức. Hãy chống lại sự cám dỗ đó.

Như mọi khi, vui lòng tránh đăng lại các bản sửa đổi của bộ truyện nhiều lần
cứ sau 24 giờ.

Các bản vá dọn dẹp
~~~~~~~~~~~~~~~~
Những người bảo trì NFSD không khuyến khích các bản vá thực hiện việc dọn dẹp đơn giản.
up, không nằm trong bối cảnh của công việc khác. Ví dụ:

* Giải quyết các cảnh báo ZZ0001ZZ sau khi hợp nhất
* Giải quyết các vấn đề về ZZ0000ZZ
* Giải quyết thiệt hại về khoảng trắng lâu dài

Điều này là do người ta cảm thấy rằng sự hỗn loạn do những thay đổi đó tạo ra
có chi phí lớn hơn giá trị của việc dọn dẹp như vậy.

Ngược lại, việc sửa lỗi chính tả và ngữ pháp được khuyến khích.

Hỗ trợ ổn định và LTS
----------------------
Thử nghiệm tích hợp liên tục NFSD ngược dòng chạy trên cây LTS
bất cứ khi nào chúng được cập nhật.

Vui lòng cho biết khi nào cần xem xét bản vá có bản sửa lỗi
đối với hạt nhân LTS, thông qua thẻ Fixes: hoặc đề cập rõ ràng.

Yêu cầu tính năng
----------------
Không có cách nào để đưa ra yêu cầu tính năng chính thức, nhưng
cuộc thảo luận về yêu cầu cuối cùng sẽ đi đến
danh sách gửi thư linux-nfs@vger.kernel.org để công chúng xem xét bởi
cộng đồng.

Ranh giới hệ thống con
~~~~~~~~~~~~~~~~~~~~
Bản thân NFSD không hơn gì một công cụ giao thức. Điều này có nghĩa là nó
trách nhiệm chính là dịch giao thức NFS sang API
các cuộc gọi trong nhân Linux. Ví dụ: NFSD không chịu trách nhiệm về
biết chính xác cách quản lý byte hoặc thuộc tính tệp trên một khối
thiết bị. Nó dựa vào các hệ thống con kernel khác cho việc đó.

Nếu các hệ thống con mà NFSD dựa vào không triển khai một quy trình cụ thể
tính năng, ngay cả khi các giao thức NFS tiêu chuẩn hỗ trợ tính năng đó,
điều đó thường có nghĩa là NFSD không thể cung cấp tính năng đó nếu không có
công việc phát triển đáng kể trong các lĩnh vực khác của kernel.

Tính đặc hiệu
~~~~~~~~~~~
Yêu cầu tính năng có thể đến từ bất cứ đâu và do đó thường có thể được
mơ hồ. Người yêu cầu có thể không hiểu "trường hợp sử dụng" hoặc
"câu chuyện của người dùng" là. Những mô hình mô tả này thường được sử dụng bởi
các nhà phát triển và kiến trúc sư để hiểu những gì được yêu cầu của một
thiết kế, nhưng là những thuật ngữ nghệ thuật trong buôn bán phần mềm, không được sử dụng trong
thế giới hàng ngày.

Để ngăn chặn những người đóng góp và người bảo trì trở thành
choáng ngợp, chúng ta sẽ không ngại nói “không” một cách lịch sự với
các yêu cầu không được xác định rõ.

Vai trò của cộng đồng và quyền hạn của họ
-----------------------------------
Mục đích của cộng đồng hệ thống con Linux là cung cấp kiến thức chuyên môn
và quản lý tích cực một tập hợp hẹp các tệp nguồn trong Linux
hạt nhân. Điều này có thể bao gồm cả việc quản lý công cụ không gian người dùng.

Để bối cảnh hóa cấu trúc của cộng đồng Linux NFS
chịu trách nhiệm quản lý cơ sở mã máy chủ NFS, chúng tôi
xác định vai trò của cộng đồng ở đây.

- ZZ0000ZZ : Bất cứ ai gửi thay đổi mã, sửa lỗi,
  khuyến nghị, sửa chữa tài liệu, v.v. Một người đóng góp có thể
  nộp thường xuyên hoặc không thường xuyên.

- ZZ0000ZZ : Cộng tác viên không phải là diễn viên thường xuyên
  trong cộng đồng Linux NFS. Điều này có thể có nghĩa là ai đó đóng góp
  đến các phần khác của kernel hoặc ai đó vừa nhận thấy một
  sai chính tả trong một bình luận và gửi một bản vá.

- ZZ0000ZZ : Người có tên trong file MAINTAINERS là
  người đánh giá là một chuyên gia trong lĩnh vực có thể yêu cầu thay đổi các nội dung đã đóng góp
  mã và hy vọng rằng những người đóng góp sẽ giải quyết yêu cầu.

- ZZ0000ZZ : Người không có tên trong
  MAINTAINERS là người đánh giá nhưng lại là chuyên gia trong lĩnh vực này.
  Ví dụ bao gồm những người đóng góp nhân Linux với mạng,
  chuyên môn về bảo mật hoặc lưu trữ liên tục hoặc các nhà phát triển
  đóng góp chủ yếu cho việc triển khai NFS khác.

Một hoặc nhiều người sẽ đảm nhận các vai trò sau. Những người này
thường được gọi chung là "người bảo trì" và là
được xác định trong tệp MAINTAINERS bằng thẻ "M:" bên dưới NFSD
hệ thống con.

- ZZ0000ZZ : Vai trò này chịu trách nhiệm về
  quản lý các đóng góp cho một chi nhánh, xem xét kết quả kiểm tra và
  sau đó gửi yêu cầu kéo trong các cửa sổ hợp nhất. có một
  mối quan hệ tin cậy giữa người quản lý phát hành và Linus.

- ZZ0000ZZ : Người phản hồi đầu tiên đối với các báo cáo lỗi
  được gửi tới danh sách gửi thư linux-nfs hoặc trình theo dõi lỗi và giúp
  khắc phục sự cố và xác định các bước tiếp theo.

- ZZ0000ZZ : Trưởng nhóm bảo mật xử lý các liên hệ từ
  cộng đồng bảo mật để giải quyết các vấn đề trước mắt cũng như giải quyết
  với các vấn đề an ninh dài hạn như mối quan tâm về chuỗi cung ứng. cho
  ngược dòng, đó thường là liệu các đóng góp có vi phạm việc cấp phép hay không
  hoặc các thỏa thuận sở hữu trí tuệ khác.

- ZZ0000ZZ : Trưởng nhóm test xây dựng và chạy thử nghiệm
  cơ sở hạ tầng cho hệ thống con. Trưởng nhóm kiểm tra có thể yêu cầu
  các bản vá sẽ bị loại bỏ vì tỷ lệ lỗi cao đang diễn ra.

- ZZ0000ZZ : Người bảo trì LTS chịu trách nhiệm quản lý
  các bản sửa lỗi: và Cc: chú thích ổn định trên các bản vá và thấy rằng
  nhận các bản vá không thể tự động áp dụng cho hạt nhân LTS
  backport thủ công thích hợp khi cần thiết.

- ZZ0000ZZ : Vai trò trọng tài này có thể được yêu cầu gọi bóng
  và đình công trong các cuộc xung đột, nhưng cũng chịu trách nhiệm đảm bảo
  sức khỏe của các mối quan hệ trong cộng đồng và cho
  tạo điều kiện cho các cuộc thảo luận về các chủ đề dài hạn như cách quản lý
  nợ kỹ thuật ngày càng tăng.
