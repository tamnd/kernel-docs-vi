.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/botching-up-ioctls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
(Cách tránh) Làm hỏng ioctls
====================================

Từ: ZZ0000ZZ

Bởi: Daniel Vetter, Bản quyền © 2013 Tập đoàn Intel

Một cái nhìn sâu sắc rõ ràng mà các hacker đồ họa hạt nhân đã đạt được trong vài năm qua là
cố gắng đưa ra một giao diện thống nhất để quản lý các đơn vị thực thi và
bộ nhớ trên các GPU hoàn toàn khác nhau là một nỗ lực vô ích. Vì vậy ngày nay mọi
trình điều khiển có bộ ioctls riêng để phân bổ bộ nhớ và gửi công việc tới GPU.
Điều đó thật tuyệt, vì không còn sự điên rồ nào ở dạng chung chung giả nữa, nhưng
thực tế chỉ được sử dụng một lần giao diện. Nhưng nhược điểm rõ ràng là có rất nhiều
nhiều khả năng hơn để làm hỏng mọi thứ.

Để tránh lặp lại những sai lầm tương tự một lần nữa, tôi đã viết ra một số
bài học kinh nghiệm khi làm hỏng công việc của trình điều khiển drm/i915. Hầu hết trong số này
chỉ đề cập đến các vấn đề kỹ thuật chứ không phải các vấn đề toàn cảnh như lệnh
việc gửi ioctl chính xác sẽ trông như thế nào. Có lẽ học được những bài học này
điều mà mọi trình điều khiển GPU đều phải tự làm.


Điều kiện tiên quyết
--------------------

Đầu tiên là điều kiện tiên quyết. Không có những điều này bạn đã thất bại rồi, bởi vì bạn
sẽ cần thêm lớp tương thích 32 bit:

* Chỉ sử dụng số nguyên có kích thước cố định. Để tránh xung đột với typedefs trong không gian người dùng
   kernel có các loại đặc biệt như __u32, __s64. Sử dụng chúng.

* Căn chỉnh mọi thứ theo kích thước tự nhiên và sử dụng phần đệm rõ ràng. 32-bit
   nền tảng không nhất thiết phải căn chỉnh các giá trị 64-bit theo ranh giới 64-bit, nhưng
   Nền tảng 64-bit làm được. Vì vậy, chúng tôi luôn cần đệm theo kích thước tự nhiên để có được
   quyền này.

* Đệm toàn bộ cấu trúc thành bội số của 64 bit nếu cấu trúc chứa
   Loại 64 bit - kích thước cấu trúc sẽ khác nhau trên 32 bit so với
   64-bit. Có kích thước cấu trúc khác sẽ gây khó khăn khi truyền mảng
   cấu trúc cho hạt nhân, hoặc nếu hạt nhân kiểm tra kích thước cấu trúc,
   ví dụ: lõi drm thì có.

* Con trỏ là __u64, được truyền từ/đến uintptr_t ở phía không gian người dùng và
   từ/đến một khoảng trống __user * trong kernel. Hãy cố gắng hết sức để không trì hoãn việc này
   chuyển đổi hoặc tệ hơn, hãy sử dụng __u64 thô thông qua mã của bạn kể từ đó
   làm giảm bớt các công cụ kiểm tra như thưa thớt có thể cung cấp. vĩ mô
   u64_to_user_ptr có thể được sử dụng trong kernel để tránh cảnh báo về số nguyên
   và con trỏ có kích cỡ khác nhau.


Khái niệm cơ bản
----------------

Với niềm vui khi viết một lớp tương thích, chúng ta có thể xem xét cơ bản
dò dẫm. Bỏ qua những điều này sẽ làm cho khả năng tương thích ngược và xuôi trở nên thực sự
đau đớn. Và vì đảm bảo bạn sẽ mắc sai lầm trong lần thử đầu tiên
sẽ có lần lặp thứ hai hoặc ít nhất là phần mở rộng cho bất kỳ giao diện cụ thể nào.

* Có một cách rõ ràng để không gian người dùng xác định xem ioctl hay ioctl mới của bạn
   phần mở rộng được hỗ trợ trên một kernel nhất định. Nếu bạn không thể dựa vào hạt nhân cũ
   từ chối các cờ/chế độ hoặc ioctls mới (vì việc đó đã bị hỏng trong
   quá khứ) thì bạn cần có cờ tính năng trình điều khiển hoặc số sửa đổi ở đâu đó.

* Có kế hoạch mở rộng ioctls với cờ mới hoặc trường mới vào cuối
   cấu trúc. Lõi drm kiểm tra kích thước được truyền vào cho mỗi lệnh gọi ioctl
   và không mở rộng bất kỳ sự không phù hợp nào giữa kernel và không gian người dùng. Điều đó giúp ích,
   nhưng không phải là một giải pháp hoàn chỉnh vì không gian người dùng mới hơn trên các hạt nhân cũ hơn sẽ không
   lưu ý rằng các trường mới được thêm vào ở cuối sẽ bị bỏ qua. Vì thế điều này vẫn
   cần một cờ tính năng trình điều khiển mới.

* Kiểm tra tất cả các trường và cờ không sử dụng cũng như tất cả phần đệm xem nó có phải là 0 hay không
   và từ chối ioctl nếu không đúng như vậy. Nếu không thì kế hoạch tốt đẹp của bạn cho
   các tiện ích mở rộng trong tương lai sắp bị loại bỏ vì ai đó sẽ gửi
   một cấu trúc ioctl với rác ngăn xếp ngẫu nhiên ở những phần chưa được sử dụng. Cái nào
   sau đó đưa vào ABI rằng những trường đó không bao giờ có thể được sử dụng cho bất kỳ mục đích nào khác
   nhưng rác rưởi. Đây cũng là lý do tại sao bạn phải rõ ràng đệm tất cả
   cấu trúc, ngay cả khi bạn không bao giờ sử dụng chúng trong một mảng - phần đệm của trình biên dịch
   có thể chèn có thể chứa rác.

* Có các trường hợp thử nghiệm đơn giản cho tất cả những điều trên.


Thú vị với các đường dẫn lỗi
----------------------------

Ngày nay chúng ta không còn lý do nào để bào chữa cho trình điều khiển drm gọn gàng nữa
ít khai thác root. Điều này có nghĩa là cả hai chúng ta đều cần xác thực đầu vào đầy đủ và chắc chắn.
đường dẫn xử lý lỗi - GPU cuối cùng sẽ chết trong những trường hợp khó khăn nhất
dù sao đi nữa:

* Ioctl phải kiểm tra lỗi tràn mảng. Ngoài ra nó cần phải kiểm tra
   tràn/tràn và các vấn đề kẹp của giá trị số nguyên nói chung. Thông thường
   ví dụ là các giá trị định vị sprite được đưa trực tiếp vào phần cứng bằng
   phần cứng chỉ có 12 bit hoặc hơn. Hoạt động độc đáo cho đến khi có một số màn hình hiển thị kỳ lạ
   máy chủ không bận tâm đến việc tự kẹp và con trỏ quấn quanh
   màn hình.

* Có các trường hợp kiểm thử đơn giản cho mọi trường hợp lỗi xác thực đầu vào trong ioctl của bạn.
   Kiểm tra xem mã lỗi có khớp với mong đợi của bạn không. Và cuối cùng hãy chắc chắn
   rằng bạn chỉ kiểm tra một đường dẫn lỗi duy nhất trong mỗi bài kiểm tra phụ bằng cách gửi
   nếu không thì dữ liệu hoàn toàn hợp lệ. Nếu không có điều này, séc trước đó có thể bị từ chối
   ioctl đã có và theo dõi đường dẫn mã mà bạn thực sự muốn kiểm tra, ẩn
   lỗi và hồi quy.

* Làm cho tất cả ioctls của bạn có thể khởi động lại. X đầu tiên thực sự yêu thích tín hiệu và thứ hai
   điều này sẽ cho phép bạn kiểm tra 90% tất cả các đường dẫn xử lý lỗi chỉ bằng cách
   làm gián đoạn bộ thử nghiệm chính của bạn liên tục bằng tín hiệu. Cảm ơn X
   yêu thích tín hiệu, bạn sẽ nhận được mức độ bao phủ cơ bản tuyệt vời cho mọi lỗi của mình
   đường dẫn khá nhiều miễn phí cho trình điều khiển đồ họa. Ngoài ra, hãy nhất quán với
   cách bạn xử lý việc khởi động lại ioctl - ví dụ: drm có một trình trợ giúp drmIoctl nhỏ trong nó
   thư viện không gian người dùng. Trình điều khiển i915 đã khắc phục sự cố này bằng set_tiling ioctl,
   bây giờ chúng ta đang bị mắc kẹt mãi mãi với một số ngữ nghĩa phức tạp trong cả kernel và
   không gian người dùng.

* Nếu bạn không thể khởi động lại một đường dẫn mã nhất định thì ít nhất hãy thực hiện một tác vụ bị kẹt
   có thể giết được. GPU sẽ chết và người dùng của bạn sẽ không thích bạn nhiều hơn nếu bạn treo chúng
   toàn bộ hộp (bằng quy trình X không thể thực hiện được). Nếu việc khôi phục trạng thái là
   vẫn còn quá khó khăn, hãy có một mạng lưới an toàn hết thời gian chờ hoặc hangcheck như một giải pháp cuối cùng
   nỗ lực trong trường hợp phần cứng đã hỏng.

* Có các trường hợp thử nghiệm cho các trường hợp góc thực sự phức tạp trong mã khôi phục lỗi của bạn
   - rất dễ tạo ra sự bế tắc giữa mã hangcheck của bạn và
   bồi bàn.


Thời gian, chờ đợi và bỏ lỡ
----------------------------

GPU thực hiện hầu hết mọi thứ một cách không đồng bộ, vì vậy chúng ta cần có thời gian hoạt động và
chờ đợi những cái xuất sắc. Đây thực sự là một công việc khó khăn; tại thời điểm này không ai trong số
ioctls được drm/i915 hỗ trợ hoàn toàn đúng, nghĩa là có
vẫn còn rất nhiều bài học để học ở đây.

* Luôn sử dụng CLOCK_MONOTONIC làm thời gian tham khảo. Đó là những gì alsa, drm và
   ngày nay sử dụng v4l theo mặc định. Nhưng hãy cho không gian người dùng biết dấu thời gian nào
   bắt nguồn từ các miền đồng hồ khác nhau như đồng hồ hệ thống chính của bạn (được cung cấp
   bởi kernel) hoặc một số bộ đếm phần cứng độc lập ở một nơi khác. Đồng hồ
   sẽ không khớp nếu bạn nhìn đủ kỹ, nhưng nếu các công cụ đo hiệu suất
   có thông tin này ít nhất họ có thể bù đắp được. Nếu không gian người dùng của bạn có thể
   nhận được các giá trị thô của một số đồng hồ (ví dụ: thông qua luồng lệnh
   hướng dẫn lấy mẫu bộ đếm hiệu suất) cũng nên xem xét việc đưa ra những hướng dẫn đó.

* Sử dụng __s64 giây cộng với __u64 nano giây để chỉ định thời gian. Nó không phải là nhất
   đặc điểm kỹ thuật thời gian thuận tiện, nhưng nó chủ yếu là tiêu chuẩn.

* Kiểm tra xem các giá trị thời gian đầu vào đã được chuẩn hóa chưa và loại bỏ chúng nếu không. Lưu ý
   rằng cấu trúc gốc của kernel ktime có số nguyên có dấu cho cả hai giây
   và nano giây, vì vậy hãy cẩn thận ở đây.

* Đối với thời gian chờ, hãy sử dụng thời gian tuyệt đối. Nếu bạn là một người tốt và đã thành công
   Thời gian chờ tương đối có thể khởi động lại của ioctl có xu hướng quá thô và có thể
   kéo dài thời gian chờ đợi của bạn vô thời hạn do làm tròn số mỗi lần khởi động lại.
   Đặc biệt nếu đồng hồ tham chiếu của bạn chạy rất chậm như màn hình
   bộ đếm khung. Với chiếc mũ luật sư đặc biệt, đây không phải là lỗi vì thời gian chờ có thể
   luôn được mở rộng - nhưng người dùng chắc chắn sẽ ghét bạn nếu hình ảnh động gọn gàng của họ
   bắt đầu nói lắp vì điều này.

* Hãy cân nhắc việc loại bỏ mọi ioctls chờ đợi đồng bộ có thời gian chờ và chỉ phân phối
   một sự kiện không đồng bộ trên bộ mô tả tệp có thể thăm dò. Nó phù hợp hơn nhiều
   vào vòng lặp chính của các ứng dụng hướng sự kiện.

* Có các trường hợp thử nghiệm cho các trường hợp góc, đặc biệt là liệu các giá trị trả về cho
   các sự kiện đã hoàn thành, chờ đợi thành công và chờ đợi hết thời gian chờ đều bình thường
   và phù hợp với nhu cầu của bạn.


Rò rỉ tài nguyên, không phải
----------------------------

Trình điều khiển drm toàn diện về cơ bản triển khai một hệ điều hành nhỏ nhưng chuyên dụng cho
các nền tảng GPU nhất định. Điều này có nghĩa là người lái xe cần phải để lộ hàng tấn tay cầm
cho các đối tượng khác nhau và các tài nguyên khác vào không gian người dùng. Làm điều đó đúng
kéo theo những cạm bẫy nhỏ của riêng nó:

* Luôn gắn thời gian tồn tại của tài nguyên được tạo động của bạn với
   thời gian tồn tại của một bộ mô tả tập tin. Hãy cân nhắc sử dụng ánh xạ 1:1 nếu tài nguyên của bạn
   cần được chia sẻ giữa các quy trình - chuyển fd qua ổ cắm tên miền unix
   cũng đơn giản hóa việc quản lý trọn đời cho không gian người dùng.

* Luôn có hỗ trợ O_CLOEXEC.

* Đảm bảo rằng bạn có đủ cách nhiệt giữa các khách hàng khác nhau. Bởi
   mặc định chọn một không gian tên per-fd riêng tư để buộc thực hiện mọi chia sẻ
   một cách rõ ràng. Chỉ sử dụng không gian tên toàn cầu hơn cho mỗi thiết bị nếu các đối tượng
   thực sự là thiết bị độc đáo. Một ví dụ mẫu trong giao diện bộ chế độ drm là
   rằng các đối tượng chế độ trên mỗi thiết bị như trình kết nối chia sẻ một không gian tên với
   các đối tượng bộ đệm khung, hầu hết không được chia sẻ. riêng biệt
   không gian tên, riêng tư theo mặc định, đối với bộ đệm khung sẽ tốt hơn
   phù hợp.

* Hãy suy nghĩ về các yêu cầu về tính duy nhất đối với các thẻ điều khiển vùng người dùng. Ví dụ. cho hầu hết drm
   trình điều khiển, đó là lỗi không gian người dùng khi gửi cùng một đối tượng hai lần trong cùng một
   gửi lệnh ioctl. Nhưng sau đó nếu các đối tượng có nhu cầu về không gian người dùng có thể chia sẻ
   để biết liệu nó có nhìn thấy một đối tượng được nhập từ một quy trình khác hay không
   đã hay chưa. Tôi chưa thử cái này vì thiếu lớp mới
   của các đối tượng, nhưng hãy cân nhắc việc sử dụng số inode trên bộ mô tả tệp dùng chung của bạn
   dưới dạng số nhận dạng duy nhất - đó cũng là cách phân biệt các tệp thực.
   Thật không may, điều này đòi hỏi một hệ thống tập tin ảo toàn diện trong kernel.


Cuối cùng nhưng không kém phần quan trọng
-----------------------------------------

Không phải mọi vấn đề đều cần một ioctl mới:

* Hãy suy nghĩ kỹ xem bạn có thực sự muốn có giao diện riêng tư cho người lái xe hay không. Tất nhiên
   việc đẩy giao diện riêng tư của người lái xe sẽ nhanh hơn nhiều so với việc tham gia vào
   các cuộc thảo luận kéo dài để tìm ra giải pháp tổng quát hơn. Và thỉnh thoảng làm một
   giao diện riêng tư để dẫn đầu một khái niệm mới là điều cần thiết. Nhưng trong
   kết thúc, khi giao diện chung xuất hiện, bạn sẽ phải duy trì hai
   giao diện. Vô thời hạn.

* Xem xét các giao diện khác ngoài ioctls. Thuộc tính sysfs tốt hơn nhiều cho
   cài đặt trên mỗi thiết bị hoặc cho các đối tượng con có thời gian tồn tại khá tĩnh (như
   đầu nối đầu ra trong drm với tất cả các thuộc tính ghi đè phát hiện). Hoặc
   có lẽ chỉ bộ thử nghiệm của bạn mới cần giao diện này và sau đó gỡ lỗi với nó
   từ chối trách nhiệm về việc không có ABI ổn định sẽ tốt hơn.

Cuối cùng, tên của trò chơi là làm đúng ngay lần thử đầu tiên, vì nếu
trình điều khiển của bạn đã trở nên phổ biến và nền tảng phần cứng của bạn đã tồn tại lâu dài thì bạn sẽ
về cơ bản sẽ bị mắc kẹt với một ioctl nhất định mãi mãi. Bạn có thể thử phản đối
ioctls khủng khiếp trên các phiên bản phần cứng mới hơn của bạn, nhưng nhìn chung phải mất
năm để thực hiện điều này. Và sau đó nhiều năm nữa cho đến khi người dùng cuối cùng có thể
phàn nàn về sự hồi quy cũng biến mất.
