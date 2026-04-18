.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/timers/timekeeping.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Nguồn đồng hồ, Sự kiện đồng hồ, sched_clock() và bộ hẹn giờ trễ
================================================================

Tài liệu này cố gắng giải thích ngắn gọn một số cách chấm công kernel cơ bản
trừu tượng. Nó một phần liên quan đến các trình điều khiển thường được tìm thấy trong
trình điều khiển/nguồn xung nhịp trong cây nhân, nhưng mã có thể bị dàn trải
xuyên suốt hạt nhân.

Nếu bạn grep thông qua nguồn kernel, bạn sẽ tìm thấy một số kiến trúc-
triển khai cụ thể của nguồn đồng hồ, sự kiện đồng hồ và một số tương tự
ghi đè theo kiến trúc cụ thể của hàm sched_clock() và một số
bộ định thời trễ.

Để cung cấp tính năng chấm công cho nền tảng của bạn, nguồn đồng hồ cung cấp
dòng thời gian cơ bản, trong khi các sự kiện đồng hồ sẽ bị gián đoạn ở một số điểm nhất định
trên dòng thời gian này, cung cấp các tiện ích như bộ hẹn giờ có độ phân giải cao.
sched_clock() được sử dụng để lập lịch, đánh dấu thời gian và hẹn giờ trễ
cung cấp nguồn trễ chính xác bằng cách sử dụng bộ đếm phần cứng.


Nguồn đồng hồ
-------------

Mục đích của nguồn đồng hồ là cung cấp dòng thời gian cho hệ thống
cho bạn biết bạn đang ở đâu trong thời gian. Ví dụ: ban hành lệnh 'ngày' vào
một hệ thống Linux cuối cùng sẽ đọc nguồn đồng hồ để xác định chính xác
bây giờ là mấy giờ rồi

Thông thường, nguồn đồng hồ là một bộ đếm nguyên tử đơn điệu sẽ cung cấp
n bit đếm từ 0 đến (2^n)-1 rồi quấn quanh thành 0 và bắt đầu lại.
Lý tưởng nhất là NEVER sẽ ngừng tích tắc miễn là hệ thống đang chạy. Nó
có thể dừng trong khi hệ thống tạm dừng.

Nguồn đồng hồ phải có độ phân giải cao nhất có thể và tần số
phải ổn định và chính xác nhất có thể so với bức tường trong thế giới thực
đồng hồ. Nó không được di chuyển qua lại theo thời gian một cách khó lường hoặc bỏ lỡ một vài
chu kỳ ở đây và ở đó.

Nó phải miễn nhiễm với các loại hiệu ứng xảy ra trong phần cứng, ví dụ:
thanh ghi bộ đếm được đọc theo hai giai đoạn trên bus thấp nhất 16 bit trước
và 16 bit cao hơn trong chu kỳ bus thứ hai với các bit bộ đếm
có khả năng được cập nhật ở giữa dẫn đến nguy cơ rất lạ
các giá trị từ bộ đếm.

Khi độ chính xác của đồng hồ treo tường của nguồn đồng hồ không đạt yêu cầu, có
có nhiều điểm kỳ quặc và lớp khác nhau trong mã chấm công, ví dụ: đồng bộ hóa
thời gian mà người dùng hiển thị theo đồng hồ RTC trong hệ thống hoặc theo thời gian được nối mạng
máy chủ sử dụng NTP, nhưng về cơ bản tất cả những gì chúng làm là cập nhật phần bù đắp cho
nguồn đồng hồ, cung cấp dòng thời gian cơ bản cho hệ thống.
Các biện pháp này không ảnh hưởng đến nguồn đồng hồ, chúng chỉ điều chỉnh
hệ thống về những nhược điểm của nó.

Cấu trúc nguồn đồng hồ sẽ cung cấp phương tiện để dịch bộ đếm được cung cấp
thành giá trị nano giây dưới dạng số dài không dấu (64 bit không dấu).
Vì thao tác này có thể được gọi rất thường xuyên nên việc thực hiện việc này một cách nghiêm ngặt
ý nghĩa toán học là không mong muốn: thay vào đó, con số được lấy gần bằng
có thể đạt tới giá trị nano giây chỉ bằng các phép toán số học
nhân và dịch chuyển, vì vậy trong clocksource_cyc2ns() bạn tìm thấy:

ns ~= (clocksource * mult) >> shift

Bạn sẽ tìm thấy một số chức năng trợ giúp trong mã nguồn đồng hồ dự định
để hỗ trợ việc cung cấp các giá trị đa và dịch chuyển này, chẳng hạn như
clocksource_khz2mult(), clocksource_hz2mult() giúp xác định
nhiều hệ số từ một ca cố định và clocksource_register_hz() và
clocksource_register_khz() sẽ giúp chỉ định cả ca và mult
các yếu tố sử dụng tần số của nguồn đồng hồ làm đầu vào duy nhất.

Đối với các nguồn xung nhịp thực sự đơn giản được truy cập từ một vị trí bộ nhớ I/O duy nhất
ngày nay thậm chí còn có clocksource_mmio_init() sẽ chiếm bộ nhớ
vị trí, độ rộng bit, một tham số cho biết bộ đếm trong
đăng ký đếm lên hoặc xuống, và tốc độ đồng hồ hẹn giờ, sau đó gợi lên tất cả
các thông số cần thiết.

Vì bộ đếm 32 bit ở tần số 100 MHz sẽ về 0 sau khoảng 43
giây, mã xử lý nguồn đồng hồ sẽ phải bù đắp cho điều này.
Đó là lý do tại sao cấu trúc nguồn đồng hồ cũng chứa 'mặt nạ'
thành viên cho biết có bao nhiêu bit của nguồn hợp lệ. Bằng cách này, việc chấm công
mã biết khi nào bộ đếm sẽ bao quanh và có thể chèn thông tin cần thiết
mã bồi thường ở cả hai bên của điểm gói để dòng thời gian của hệ thống
vẫn đơn điệu.


Sự kiện đồng hồ
------------

Các sự kiện đồng hồ là sự đảo ngược về mặt khái niệm của các nguồn đồng hồ: chúng lấy một
giá trị đặc tả thời gian mong muốn và tính toán các giá trị để chọc vào
các thanh ghi hẹn giờ phần cứng.

Các sự kiện đồng hồ trực giao với nguồn đồng hồ. Phần cứng giống nhau
và phạm vi đăng ký có thể được sử dụng cho sự kiện đồng hồ, nhưng về cơ bản nó là
một điều khác. Các sự kiện đồng hồ điều khiển phần cứng phải có khả năng
ngắt lửa, để kích hoạt các sự kiện trên dòng thời gian của hệ thống. Trên SMP
hệ thống, lý tưởng nhất (và theo thông lệ) là có một bộ đếm thời gian điều khiển sự kiện như vậy cho mỗi
Lõi CPU, để mỗi lõi có thể kích hoạt các sự kiện độc lập với bất kỳ lõi nào khác
cốt lõi.

Bạn sẽ nhận thấy rằng mã thiết bị sự kiện đồng hồ dựa trên cùng một cơ sở
ý tưởng về việc dịch bộ đếm sang nano giây bằng cách sử dụng mult và shift
số học và bạn lại tìm thấy cùng một họ các hàm trợ giúp cho
gán các giá trị này. Trình điều khiển sự kiện đồng hồ không cần 'mặt nạ'
tuy nhiên thuộc tính: hệ thống sẽ không cố gắng lên kế hoạch cho các sự kiện vượt quá thời gian
chân trời của sự kiện đồng hồ.


lịch_clock()
-------------

Ngoài các nguồn đồng hồ và các sự kiện đồng hồ còn có một điểm yếu đặc biệt
hàm trong kernel có tên là sched_clock(). Hàm này sẽ trả về
nano giây kể từ khi hệ thống được khởi động. Một kiến trúc có thể hoặc
có thể không tự cung cấp việc triển khai sched_clock(). Nếu là người địa phương
việc triển khai không được cung cấp, bộ đếm nhanh của hệ thống sẽ được sử dụng làm
lịch_clock().

Đúng như tên gọi, sched_clock() được sử dụng để lập lịch cho hệ thống,
xác định khoảng thời gian tuyệt đối cho một quy trình nhất định trong bộ lập lịch CFS
chẳng hạn. Nó cũng được sử dụng để in dấu thời gian khi bạn đã chọn
bao gồm thông tin thời gian trong printk cho những thứ như biểu đồ khởi động.

So với các nguồn đồng hồ, sched_clock() phải rất nhanh: nó được gọi là
thường xuyên hơn nhiều, đặc biệt là bởi người lập lịch trình. Nếu bạn phải đánh đổi
giữa độ chính xác so với nguồn đồng hồ, bạn có thể hy sinh độ chính xác
để biết tốc độ trong sched_clock(). Tuy nhiên nó đòi hỏi một số điều cơ bản tương tự
đặc điểm như nguồn đồng hồ, tức là nó phải đơn điệu.

Hàm sched_clock() chỉ có thể bao bọc trên các ranh giới dài không dấu,
tức là sau 64 bit. Vì đây là giá trị nano giây nên điều này có nghĩa là nó bao bọc
sau khoảng 585 năm. (Đối với hầu hết các hệ thống thực tế, điều này có nghĩa là "không bao giờ".)

Nếu một kiến trúc không cung cấp cách triển khai riêng của nó cho chức năng này,
nó sẽ quay trở lại sử dụng jiffies, làm cho độ phân giải tối đa của nó là 1/HZ của
tần số nhanh cho kiến trúc. Điều này sẽ ảnh hưởng đến độ chính xác của việc lập kế hoạch
và có thể sẽ hiển thị trong điểm chuẩn của hệ thống.

Đồng hồ điều khiển sched_clock() có thể dừng hoặc đặt lại về 0 trong hệ thống
đình chỉ/ngủ. Điều này không quan trọng đối với chức năng lập kế hoạch mà nó phục vụ
sự kiện trên hệ thống. Tuy nhiên nó có thể dẫn đến dấu thời gian thú vị trong
printk().

Hàm sched_clock() có thể gọi được trong mọi ngữ cảnh, IRQ- và
NMI-safe và trả về giá trị lành mạnh trong mọi ngữ cảnh.

Một số kiến trúc có thể có một tập hợp nguồn thời gian hạn chế và thiếu một
bộ đếm để lấy giá trị nano giây 64 bit, ví dụ như trên ARM
kiến trúc, các chức năng trợ giúp đặc biệt đã được tạo ra để cung cấp một
sched_clock() cơ sở nano giây từ bộ đếm 16 hoặc 32 bit. Đôi khi
cùng một bộ đếm cũng được sử dụng làm nguồn đồng hồ được sử dụng cho mục đích này.

Trên các hệ thống SMP, điều quan trọng đối với hiệu suất là sched_clock() có thể được gọi
độc lập trên mỗi CPU mà không có bất kỳ lần truy cập hiệu suất đồng bộ hóa nào.
Một số phần cứng (chẳng hạn như x86 TSC) sẽ khiến hàm sched_clock() hoạt động
trôi dạt giữa các CPU trên hệ thống. Hạt nhân có thể giải quyết vấn đề này bằng cách
bật tùy chọn CONFIG_HAVE_UNSTABLE_SCHED_CLOCK. Đây là một khía cạnh khác
điều đó làm cho sched_clock() khác với nguồn đồng hồ thông thường.


Bộ định thời gian trễ (chỉ một số kiến ​​trúc)
--------------------------------------

Trên các hệ thống có tần số CPU thay đổi, các hàm delay() khác nhau của kernel
đôi khi sẽ cư xử kỳ lạ. Về cơ bản những độ trễ này thường sử dụng phần cứng
vòng lặp để trì hoãn một số phân số nhanh nhất định bằng cách sử dụng "lpj" (vòng lặp trên mỗi
Jiffy), được hiệu chỉnh khi khởi động.

Hãy hy vọng rằng hệ thống của bạn đang chạy ở tần số tối đa khi giá trị này
được hiệu chỉnh: như một hiệu ứng khi tần số được giảm xuống một nửa
tần số đầy đủ, mọi độ trễ() sẽ dài gấp đôi. Thông thường điều này không
thật khó chịu, vì bạn thường yêu cầu khoảng thời gian trễ đó ZZ0000ZZ. Nhưng
về cơ bản, ngữ nghĩa khá khó đoán trên các hệ thống như vậy.

Nhập độ trễ dựa trên bộ đếm thời gian. Bằng cách sử dụng những thứ này, có thể sử dụng bộ đếm thời gian đọc thay vì
một vòng lặp được mã hóa cứng để cung cấp độ trễ mong muốn.

Điều này được thực hiện bằng cách khai báo struct delay_timer và gán giá trị thích hợp
con trỏ chức năng và cài đặt tốc độ cho bộ đếm thời gian trễ này.

Tính năng này có sẵn trên một số kiến ​​trúc như OpenRISC hoặc ARM.
