.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/timers/hrtimers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
hrtimers - hệ thống con dành cho bộ định thời kernel có độ phân giải cao
========================================================================

Bản vá này giới thiệu một hệ thống con mới dành cho bộ đếm thời gian kernel có độ phân giải cao.

Người ta có thể đặt câu hỏi: chúng ta đã có một hệ thống con hẹn giờ
(kernel/timers.c), tại sao chúng ta cần hai hệ thống con hẹn giờ? Sau rất nhiều
qua lại cố gắng tích hợp độ phân giải cao và độ chính xác cao
tính năng vào khung hẹn giờ hiện có và sau khi thử nghiệm nhiều
triển khai bộ đếm thời gian có độ phân giải cao như vậy trong thực tế, chúng tôi đã đi đến
kết luận rằng mã bánh xe hẹn giờ về cơ bản là không phù hợp với
một cách tiếp cận như vậy. Ban đầu chúng tôi không tin vào điều này ('phải có cách nào đó
để giải quyết vấn đề này'), và dành một nỗ lực đáng kể để cố gắng tích hợp
mọi thứ vào bánh xe hẹn giờ, nhưng chúng tôi đã thất bại. Nhìn lại, có
một số lý do tại sao việc tích hợp như vậy là khó/không thể:

- việc xử lý bắt buộc các bộ định thời có độ phân giải thấp và độ phân giải cao trong
  cách tương tự dẫn đến nhiều thỏa hiệp, ma thuật vĩ mô và #ifdef
  lộn xộn. Mã của bộ hẹn giờ.c được "mã hóa chặt chẽ" xung quanh các khoảnh khắc và
  Các giả định về 32 bit và đã được mài giũa và tối ưu hóa vi mô cho
  trường hợp sử dụng tương đối hẹp (nhanh chóng trong phạm vi HZ tương đối hẹp)
  trong nhiều năm - và do đó, ngay cả những phần mở rộng nhỏ của nó cũng dễ dàng bị hỏng
  khái niệm bánh xe, dẫn đến những thỏa hiệp thậm chí còn tồi tệ hơn. Bánh xe hẹn giờ
  mã là mã rất tốt và chặt chẽ, không có vấn đề gì với nó
  cách sử dụng hiện tại - nhưng đơn giản là nó không phù hợp để mở rộng cho
  bộ hẹn giờ có độ phân giải cao.

- chi phí phân tầng [O(N)] không thể đoán trước dẫn đến sự chậm trễ
  đòi hỏi phải xử lý phức tạp hơn các bộ định thời có độ phân giải cao,
  lần lượt làm giảm độ bền. Thiết kế như vậy vẫn dẫn đến khá lớn
  sự thiếu chính xác về thời gian. Xếp tầng là một thuộc tính cơ bản của bộ đếm thời gian
  khái niệm bánh xe, nó không thể được 'thiết kế ra' nếu không chắc chắn
  làm suy giảm các phần khác của mãtimes.c theo cách không thể chấp nhận được.

- việc triển khai hệ thống con bộ đếm thời gian posix hiện tại trên
  bánh xe hẹn giờ đã giới thiệu một cách xử lý khá phức tạp
  yêu cầu điều chỉnh lại bộ hẹn giờ CLOCK_REALTIME tuyệt đối tại
  thời gian settimeofday hoặc NTP - làm cơ sở thêm cho trải nghiệm của chúng tôi bằng cách
  ví dụ: cấu trúc dữ liệu bánh xe hẹn giờ quá cứng đối với độ phân giải cao
  đồng hồ bấm giờ.

- mã bánh xe hẹn giờ là tối ưu nhất cho các trường hợp sử dụng có thể
  được xác định là "thời gian chờ". Thời gian chờ như vậy thường được thiết lập để bù đắp
  điều kiện lỗi trong các đường dẫn I/O khác nhau, chẳng hạn như kết nối mạng và chặn
  Tôi/O. Phần lớn những bộ tính giờ đó không bao giờ hết hạn và hiếm khi
  được xếp lại vì sự kiện đúng dự kiến đến kịp thời nên họ
  có thể được gỡ bỏ khỏi bánh xe hẹn giờ trước khi xử lý thêm
  chúng trở nên cần thiết. Do đó, người sử dụng thời gian chờ này có thể chấp nhận
  sự cân bằng chi tiết và độ chính xác của bánh xe hẹn giờ và
  phần lớn mong đợi hệ thống con hẹn giờ có chi phí gần như bằng không.
  Đối với họ, việc xác định thời điểm chính xác không phải là mục đích cốt lõi - trên thực tế, hầu hết
  giá trị thời gian chờ được sử dụng là đặc biệt. Đối với họ điều đó nhiều nhất là cần thiết
  ác để đảm bảo việc xử lý hoàn thành thời gian chờ thực tế
  (vì hầu hết thời gian chờ sẽ bị xóa trước khi hoàn thành), điều này
  do đó nên rẻ và ít xâm phạm nhất có thể.

Người dùng chính của bộ đếm thời gian chính xác là các ứng dụng trong không gian người dùng
sử dụng các giao diện nanosleep, posix-timers và itimer. Ngoài ra, trong kernel
người dùng thích trình điều khiển và hệ thống con yêu cầu các sự kiện được tính thời gian chính xác
(ví dụ: đa phương tiện) có thể được hưởng lợi từ sự sẵn có của một
hệ thống con hẹn giờ có độ phân giải cao là tốt.

Mặc dù hệ thống con này không cung cấp nguồn đồng hồ có độ phân giải cao mà chỉ
Tuy nhiên, hệ thống con giờ giờ có thể được mở rộng dễ dàng với độ phân giải cao
khả năng đồng hồ và các bản vá cho điều đó tồn tại và đang hoàn thiện nhanh chóng.
Nhu cầu ngày càng tăng về các ứng dụng đa phương tiện và thời gian thực cùng với
với những người dùng tiềm năng khác để có bộ tính giờ chính xác đưa ra một lý do khác để
tách biệt các hệ thống con "thời gian chờ" và "bộ đếm thời gian chính xác".

Một lợi ích tiềm năng khác là sự tách biệt như vậy thậm chí còn cho phép nhiều
tối ưu hóa mục đích đặc biệt của bánh xe hẹn giờ hiện có ở mức thấp
độ phân giải và các trường hợp sử dụng có độ chính xác thấp - một khi độ chính xác nhạy cảm
Các API được tách khỏi bánh xe hẹn giờ và được di chuyển sang
giờ làm việc. Ví dụ. chúng ta có thể giảm tần suất của hệ thống con hết thời gian chờ
từ 250 Hz đến 100 HZ (hoặc thậm chí nhỏ hơn).

chi tiết triển khai hệ thống con hrtimer
----------------------------------------

những cân nhắc thiết kế cơ bản là:

- sự đơn giản

- cấu trúc dữ liệu không bị ràng buộc ở mức độ nhanh chóng hoặc bất kỳ mức độ chi tiết nào khác. Tất cả
  logic hạt nhân hoạt động ở độ phân giải nano giây 64 bit - không ảnh hưởng.

- đơn giản hóa mã hạt nhân hiện có, liên quan đến thời gian

một yêu cầu cơ bản khác là việc xếp hàng và sắp xếp ngay lập tức các
bộ đếm thời gian tại thời điểm kích hoạt. Sau khi xem xét một số giải pháp khả thi
chẳng hạn như cây cơ số và hàm băm, chúng tôi chọn cây đỏ đen làm cơ bản
cấu trúc dữ liệu. Rbtrees có sẵn dưới dạng thư viện trong kernel và được
được sử dụng trong các lĩnh vực quan trọng về hiệu suất khác nhau, ví dụ: quản lý bộ nhớ và
hệ thống tập tin. Rbtree chỉ được sử dụng để sắp xếp thứ tự theo thời gian, trong khi
một danh sách riêng biệt được sử dụng để giúp mã hết hạn truy cập nhanh vào
bộ tính giờ được xếp hàng đợi mà không cần phải đi qua rbtree.

(Danh sách riêng này cũng hữu ích sau này khi chúng tôi giới thiệu
đồng hồ có độ phân giải cao, nơi chúng tôi cần tách riêng các đồng hồ đang chờ xử lý và đã hết hạn
hàng đợi trong khi vẫn giữ nguyên trật tự thời gian.)

Việc xếp hàng theo thứ tự thời gian không chỉ nhằm mục đích
đồng hồ có độ phân giải cao, nó cũng đơn giản hóa việc xử lý
bộ hẹn giờ tuyệt đối dựa trên CLOCK_REALTIME có độ phân giải thấp. Hiện có
thực hiện cần thiết để giữ một danh sách bổ sung của tất cả các lực lượng vũ trang tuyệt đối
Bộ hẹn giờ CLOCK_REALTIME cùng với khóa phức tạp. Trong trường hợp
settimeofday và NTP, tất cả các bộ tính giờ (!) phải được xếp hàng đợi,
mã thay đổi thời gian phải sửa từng cái một và tất cả chúng đều phải sửa
lại được xếp hàng nữa. Việc xếp hàng theo thứ tự thời gian và lưu trữ các
thời gian hết hạn tính theo đơn vị thời gian tuyệt đối sẽ loại bỏ tất cả những điều phức tạp và kém hiệu quả này
mã chia tỷ lệ từ việc triển khai bộ đếm thời gian posix - đồng hồ có thể đơn giản
được thiết lập mà không cần phải chạm vào rbtree. Điều này cũng làm cho việc xử lý
của posix-timer nói chung đơn giản hơn.

Hoạt động khóa và theo CPU của bộ tính giờ chủ yếu được lấy từ
mã bánh xe hẹn giờ hiện có, vì nó đã trưởng thành và rất phù hợp. Mã chia sẻ
không thực sự là một chiến thắng do cấu trúc dữ liệu khác nhau. Ngoài ra,
Các hàm hrtimer giờ đây có hành vi rõ ràng hơn và tên rõ ràng hơn - chẳng hạn như
hrtimer_try_to_cancel() và hrtimer_cancel() [đại khái là
tương đương vớitimer_delete() vàtimer_delete_sync()] - vì vậy không có trực tiếp
Ánh xạ 1:1 giữa chúng ở cấp độ thuật toán và do đó không có
tiềm năng chia sẻ mã.

Các kiểu dữ liệu cơ bản: mọi giá trị thời gian, tuyệt đối hoặc tương đối, nằm trong một
Loại 64bit có độ phân giải nano giây đặc biệt: ktime_t.
(Ban đầu, biểu diễn bên trong kernel của các giá trị ktime_t và
các hoạt động được thực hiện thông qua các macro và các hàm nội tuyến và có thể
chuyển đổi giữa loại "kết hợp lai" và loại 64bit "vô hướng" đơn giản
biểu diễn nano giây (tại thời điểm biên dịch). Điều này đã bị bỏ rơi trong
bối cảnh của công việc Y2038.)

giờ - làm tròn các giá trị bộ đếm thời gian
-----------------------------------

mã giờ sẽ làm tròn các sự kiện hẹn giờ thành đồng hồ có độ phân giải thấp hơn
bởi vì nó phải như vậy. Nếu không nó sẽ không làm tròn nhân tạo chút nào.

một câu hỏi là, giá trị độ phân giải nào sẽ được trả về cho người dùng bằng
giao diện clock_getres(). Điều này sẽ trả về bất kỳ độ phân giải thực nào
một đồng hồ nhất định có - có thể là độ phân giải thấp, độ phân giải cao hoặc độ phân giải thấp giả tạo.

giờ làm việc - kiểm tra và xác minh
-----------------------------------

Chúng tôi đã sử dụng hệ thống con đồng hồ có độ phân giải cao bên trên đồng hồ tính giờ để xác minh
chi tiết triển khai hrtimer trong praxis và chúng tôi cũng đã chạy posix
kiểm tra bộ đếm thời gian để đảm bảo tuân thủ đặc điểm kỹ thuật. Chúng tôi cũng chạy
thử nghiệm trên đồng hồ có độ phân giải thấp.

Bản vá hrtimer chuyển đổi chức năng kernel sau để sử dụng
giờ làm việc:

- nano ngủ
 - bộ đếm thời gian
 - bộ đếm thời gian posix

Việc chuyển đổi nanosleep và posix-timer đã cho phép thống nhất
nanosleep và clock_nanosleep.

Mã đã được biên dịch thành công cho các nền tảng sau:

i386, x86_64, ARM, PPC, PPC64, IA64

Mã đã được chạy thử nghiệm trên các nền tảng sau:

i386(LÊN/SMP), x86_64(LÊN/SMP), ARM, PPC

giờ cũng được tích hợp vào cây -rt, cùng với
triển khai đồng hồ có độ phân giải cao dựa trên giờ, vì vậy giờ
mã đã được thử nghiệm và sử dụng rất nhiều trong thực tế.

Thomas Gleixner, Ingo Molnar
