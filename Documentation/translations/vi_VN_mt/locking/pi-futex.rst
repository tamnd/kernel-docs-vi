.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/pi-futex.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
PI-futex nhẹ
======================

Chúng tôi gọi chúng là nhẹ vì 3 lý do:

- trong đường dẫn nhanh của không gian người dùng, futex hỗ trợ PI không liên quan đến hoạt động của kernel
   (hoặc bất kỳ sự phức tạp PI nào khác). Không cần đăng ký, không cần thêm kernel
   cuộc gọi - chỉ là các hoạt động nguyên tử nhanh thuần túy trong không gian người dùng.

- ngay cả trong đường dẫn chậm, mẫu lệnh gọi và lập lịch hệ thống rất
   tương tự như futexes bình thường.

- việc triển khai PI trong nhân được sắp xếp hợp lý xung quanh mutex
   trừu tượng, với các quy tắc nghiêm ngặt để duy trì việc thực hiện
   tương đối đơn giản: chỉ một chủ sở hữu duy nhất có thể sở hữu một ổ khóa (tức là không
   hỗ trợ khóa đọc-ghi), chỉ chủ sở hữu mới có thể mở khóa, không
   khóa đệ quy, v.v.

Kế thừa ưu tiên - tại sao?
---------------------------

Câu trả lời ngắn gọn: PI không gian người dùng giúp đạt được/cải thiện tính quyết định cho
các ứng dụng không gian người dùng. Trong trường hợp tốt nhất, nó có thể giúp đạt được
tính quyết định và độ trễ ràng buộc tốt. Ngay cả trong trường hợp xấu nhất, PI sẽ
cải thiện phân phối thống kê của ứng dụng liên quan đến khóa
sự chậm trễ.

Câu trả lời dài hơn
----------------

Thứ nhất, chia sẻ khóa giữa nhiều tác vụ là một chương trình phổ biến
kỹ thuật thường không thể thay thế được bằng các thuật toán không khóa. Như chúng tôi
có thể thấy nó trong kernel [bản thân nó là một chương trình khá phức tạp],
cấu trúc không khóa là ngoại lệ hơn là chuẩn mực - hiện tại
tỷ lệ giữa mã không khóa và mã khóa cho cấu trúc dữ liệu dùng chung ở đâu đó
trong khoảng từ 1:10 đến 1:100. Lockless rất khó và sự phức tạp của lockless
các thuật toán thường gây nguy hiểm cho khả năng thực hiện các đánh giá mạnh mẽ về mã nói trên.
tức là các ứng dụng RT quan trọng thường chọn cấu trúc khóa để bảo vệ các ứng dụng quan trọng
cấu trúc dữ liệu, thay vì các thuật toán không khóa. Hơn nữa, có
các trường hợp (như phần cứng dùng chung hoặc các giới hạn tài nguyên khác) trong đó không khóa
truy cập là không thể về mặt toán học.

Trình phát đa phương tiện (chẳng hạn như Jack) là một ví dụ về ứng dụng hợp lý
thiết kế với nhiều nhiệm vụ (với nhiều mức độ ưu tiên) chia sẻ
khóa được giữ ngắn: ví dụ: luồng phát lại âm thanh highprio là
được kết hợp với các luồng dữ liệu âm thanh có cấu trúc trung bình và các luồng có mức ưu tiên thấp
chủ đề hiển thị màu sắc. Thêm video và giải mã vào hỗn hợp và
chúng tôi thậm chí còn có nhiều mức độ ưu tiên hơn.

Vì vậy, một khi chúng ta chấp nhận rằng các đối tượng đồng bộ hóa (khóa) là một
thực tế không thể tránh khỏi của cuộc sống và một khi chúng ta chấp nhận không gian người dùng đa tác vụ đó
các ứng dụng có kỳ vọng rất cao về khả năng sử dụng khóa, chúng tôi đã có
suy nghĩ về cách cung cấp tùy chọn khóa xác định
triển khai vào không gian người dùng.

Hầu hết các lập luận phản bác về mặt kỹ thuật chống lại việc thực hiện ưu tiên
kế thừa chỉ áp dụng cho khóa không gian kernel. Nhưng khóa không gian người dùng là
khác, ở đó chúng ta không thể vô hiệu hóa các ngắt hoặc thực hiện tác vụ
không thể được ưu tiên trong phần quan trọng, vì vậy đối số 'sử dụng khóa xoay'
không áp dụng (các spinlock trong không gian người dùng có cùng mức độ ưu tiên đảo ngược
vấn đề như các cấu trúc khóa không gian người dùng khác). Thực tế là, khá nhiều
kỹ thuật duy nhất hiện nay cho phép xác định tốt cho không gian người dùng
khóa (chẳng hạn như các mutex pthread dựa trên futex) là sự kế thừa ưu tiên:

Hiện tại (không có PI), nếu một tác vụ có mức ưu tiên cao và một nhiệm vụ có mức ưu tiên thấp chia sẻ một khóa
[đây là tình huống khá phổ biến đối với hầu hết các ứng dụng RT không tầm thường],
ngay cả khi tất cả các phần quan trọng được mã hóa cẩn thận để mang tính xác định
(tức là tất cả các phần quan trọng đều có thời lượng ngắn và chỉ thực hiện một
số lượng lệnh có hạn), kernel không thể đảm bảo bất kỳ
thực hiện xác định nhiệm vụ ưu tiên cao: bất kỳ nhiệm vụ ưu tiên trung bình nào
có thể ưu tiên thực hiện nhiệm vụ ưu tiên thấp trong khi nó giữ khóa chia sẻ và
thực thi phần quan trọng và có thể trì hoãn nó vô thời hạn.

Thực hiện
--------------

Như đã đề cập trước đó, đường dẫn nhanh vùng người dùng của pthread hỗ trợ PI
mutexes không liên quan đến hoạt động của kernel - chúng hoạt động khá giống với
khóa dựa trên futex thông thường: giá trị 0 có nghĩa là đã mở khóa và giá trị==TID
có nghĩa là bị khóa. (Đây là phương pháp tương tự được sử dụng bởi các công cụ mạnh mẽ dựa trên danh sách.
futexes.) Không gian người dùng sử dụng các thao tác nguyên tử để khóa/mở khóa các mutex này mà không cần
đi vào hạt nhân.

Để xử lý đường dẫn chậm, chúng tôi đã thêm hai hoạt động futex mới:

-FUTEX_LOCK_PI
  -FUTEX_UNLOCK_PI

Nếu đường dẫn nhanh thu được khóa không thành công, [tức là. sự chuyển đổi nguyên tử từ 0 sang
TID không thành công], sau đó FUTEX_LOCK_PI được gọi. Hạt nhân thực hiện tất cả
công việc còn lại: nếu không có hàng đợi futex được đính kèm với địa chỉ futex
tuy nhiên sau đó đoạn mã sẽ tra cứu tác vụ sở hữu futex [nó đã đặt nó
sở hữu TID vào giá trị futex] và gắn cấu trúc 'trạng thái PI' vào
hàng đợi futex. pi_state bao gồm rt-mutex, nhận biết PI,
đối tượng đồng bộ hóa dựa trên kernel. Nhiệm vụ 'khác' được đặt làm chủ sở hữu
của rt-mutex và bit FUTEX_WAITERS được đặt nguyên tử trong
giá trị futex. Sau đó, tác vụ này sẽ cố gắng khóa rt-mutex, trên đó nó
khối. Khi nó quay trở lại, nó có được mutex và thiết lập
giá trị futex thành TID của chính nó và trả về. Không gian người dùng không có công việc nào khác để
thực hiện - hiện tại nó sở hữu khóa và giá trị futex chứa
FUTEX_WAITERS|TID.

Nếu đường dẫn nhanh bên mở khóa thành công, [tức là. không gian người dùng quản lý để thực hiện một
TID -> 0 chuyển đổi nguyên tử của giá trị futex], thì không có kernel nào hoạt động được
được kích hoạt.

Nếu đường dẫn mở khóa nhanh không thành công (vì bit FUTEX_WAITERS được đặt),
sau đó FUTEX_UNLOCK_PI được gọi và kernel sẽ mở khóa futex trên
thay mặt cho không gian người dùng - và nó cũng mở khóa tệp đính kèm
pi_state->rt_mutex và do đó đánh thức bất kỳ người phục vụ tiềm năng nào.

Lưu ý rằng theo cách tiếp cận này, trái ngược với các cách tiếp cận PI-futex trước đây,
không có 'đăng ký' trước PI-futex. [điều này không hoàn toàn
dù sao cũng có thể, do các thuộc tính ABI hiện có của các mutex pthread.]

Ngoài ra, theo sơ đồ này, 'độ bền' và 'PI' là hai trực giao
thuộc tính của futexes và tất cả bốn kết hợp đều có thể: futex,
mạnh mẽ-futex, PI-futex, mạnh mẽ+PI-futex.

Thông tin chi tiết về kế thừa ưu tiên có thể được tìm thấy trong
Tài liệu/khóa/rt-mutex.rst.
