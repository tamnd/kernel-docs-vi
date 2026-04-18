.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/cpufreq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. |intel_pstate| replace:: :doc:`intel_pstate <intel_pstate>`

==========================
Mở rộng hiệu suất CPU
=======================

:Bản quyền: ZZ0000ZZ 2017 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Khái niệm về mở rộng hiệu suất CPU
======================================

Phần lớn các bộ xử lý hiện đại có khả năng hoạt động ở một số
các cấu hình điện áp và tần số đồng hồ khác nhau, thường được gọi là
Điểm hiệu suất vận hành hoặc trạng thái P (theo thuật ngữ ACPI).  Như một quy luật,
tần số đồng hồ càng cao và điện áp càng cao thì càng có nhiều hướng dẫn
CPU có thể ngừng hoạt động trong một đơn vị thời gian, nhưng đồng hồ càng cao
tần số và điện áp càng cao thì năng lượng tiêu thụ càng nhiều trên một đơn vị
thời gian (hoặc lượng điện năng được tiêu thụ nhiều hơn) bởi CPU ở trạng thái P nhất định.  Vì thế
có sự cân bằng tự nhiên giữa dung lượng CPU (số lượng lệnh
có thể được thực thi trong một đơn vị thời gian) và công suất do CPU tiêu thụ.

Trong một số trường hợp, việc chạy chương trình càng nhanh càng tốt hoặc thậm chí cần thiết.
nhất có thể và khi đó không có lý do gì để sử dụng bất kỳ trạng thái P nào khác với trạng thái
mức cao nhất (tức là cấu hình tần số/điện áp hiệu suất cao nhất
có sẵn).  Tuy nhiên, trong một số trường hợp khác, có thể không cần thiết phải thực thi
hướng dẫn nhanh chóng và duy trì dung lượng CPU cao nhất hiện có cho
thời gian tương đối dài mà không sử dụng hết có thể bị coi là lãng phí.
Về mặt vật lý, cũng có thể không thể duy trì dung lượng CPU tối đa
dài vì lý do nhiệt hoặc khả năng cung cấp điện hoặc tương tự.  Để che đậy những điều đó
trường hợp, có các giao diện phần cứng cho phép CPU chuyển đổi giữa
cấu hình tần số/điện áp khác nhau hoặc (theo thuật ngữ ACPI)
đưa vào các trạng thái P khác nhau.

Thông thường, chúng được sử dụng cùng với các thuật toán để ước tính CPU cần thiết
dung lượng, để quyết định trạng thái P nào sẽ đặt CPU vào.  Tất nhiên, kể từ khi
việc sử dụng hệ thống thường thay đổi theo thời gian, điều đó phải được thực hiện
lặp đi lặp lại một cách thường xuyên.  Hoạt động mà điều này xảy ra được đề cập
thành chia tỷ lệ hiệu suất CPU hoặc chia tỷ lệ tần số CPU (vì nó liên quan đến
điều chỉnh tần số xung nhịp CPU).


Mở rộng hiệu suất CPU trong Linux
================================

Nhân Linux hỗ trợ mở rộng hiệu suất CPU bằng ZZ0000ZZ
Hệ thống con (CPU Tần số chia tỷ lệ) bao gồm ba lớp mã: lớp
cốt lõi, bộ điều chỉnh tỷ lệ và trình điều khiển tỷ lệ.

Lõi ZZ0000ZZ cung cấp cơ sở hạ tầng mã chung và không gian người dùng
giao diện cho tất cả các nền tảng hỗ trợ mở rộng hiệu suất CPU.  Nó định nghĩa
khuôn khổ cơ bản trong đó các thành phần khác hoạt động.

Bộ điều chỉnh tỷ lệ thực hiện các thuật toán để ước tính dung lượng CPU cần thiết.
Theo quy định, mỗi bộ điều chỉnh thực hiện một quy mô, có thể được tham số hóa,
thuật toán.

Trình điều khiển mở rộng nói chuyện với phần cứng.  Họ cung cấp cho người điều khiển quy mô
thông tin về trạng thái P sẵn có (hoặc phạm vi trạng thái P trong một số trường hợp) và
truy cập các giao diện phần cứng dành riêng cho nền tảng để thay đổi trạng thái P của CPU theo yêu cầu
bằng cách mở rộng quy mô thống đốc.

Về nguyên tắc, tất cả các bộ điều chỉnh tỷ lệ có sẵn đều có thể được sử dụng với mọi tỷ lệ.
người lái xe.  Thiết kế đó dựa trên sự quan sát rằng thông tin được sử dụng bởi
Các thuật toán mở rộng hiệu suất cho lựa chọn trạng thái P có thể được biểu diễn dưới dạng
hình thức độc lập với nền tảng trong phần lớn các trường hợp, vì vậy có thể thực hiện được
để sử dụng cùng một thuật toán chia tỷ lệ hiệu suất được triển khai theo cùng một cách chính xác
bất kể trình điều khiển chia tỷ lệ nào được sử dụng.  Do đó, cùng một bộ
bộ điều chỉnh tỷ lệ phải phù hợp với mọi nền tảng được hỗ trợ.

Tuy nhiên, quan sát đó có thể không đúng đối với các thuật toán mở rộng hiệu suất
dựa trên thông tin do chính phần cứng cung cấp, ví dụ như thông qua
các thanh ghi phản hồi, vì thông tin đó thường dành riêng cho phần cứng
giao diện mà nó xuất phát và có thể không dễ dàng được trình bày dưới dạng trừu tượng,
cách độc lập với nền tảng.  Vì lý do này, ZZ0000ZZ cho phép trình điều khiển mở rộng quy mô
để bỏ qua lớp thống đốc và thực hiện việc mở rộng hiệu suất của riêng mình
thuật toán.  Điều đó được thực hiện bởi trình điều khiển chia tỷ lệ ZZ0001ZZ.


Đối tượng chính sách ZZ0000ZZ
==========================

Trong một số trường hợp, giao diện phần cứng để điều khiển trạng thái P được chia sẻ bởi nhiều
CPU.  Ví dụ, cùng một thanh ghi (hoặc tập hợp các thanh ghi) được sử dụng để
kiểm soát trạng thái P của nhiều CPU cùng lúc và việc ghi vào nó ảnh hưởng đến
tất cả các CPU đó cùng một lúc.

Các bộ CPU chia sẻ giao diện điều khiển trạng thái P phần cứng được biểu diễn bằng
ZZ0000ZZ là đối tượng struct cpufreq_policy.  Để nhất quán,
struct cpufreq_policy cũng được sử dụng khi chỉ có một CPU trong
thiết lập.

Lõi ZZ0000ZZ duy trì một con trỏ tới đối tượng struct cpufreq_policy cho
mọi CPU trong hệ thống, bao gồm cả CPU hiện đang ngoại tuyến.  Nếu nhiều
CPU chia sẻ cùng một giao diện điều khiển trạng thái P phần cứng, tất cả các con trỏ
tương ứng với chúng trỏ đến cùng một đối tượng struct cpufreq_policy.

ZZ0000ZZ sử dụng struct cpufreq_policy làm kiểu dữ liệu cơ bản và thiết kế
giao diện không gian người dùng của nó dựa trên khái niệm chính sách.


Khởi tạo CPU
==================

Trước hết, trình điều khiển chia tỷ lệ phải được đăng ký để ZZ0000ZZ hoạt động.
Mỗi lần chỉ có thể đăng ký một trình điều khiển chia tỷ lệ, do đó việc chia tỷ lệ
trình điều khiển dự kiến ​​sẽ có thể xử lý tất cả các CPU trong hệ thống.

Trình điều khiển chia tỷ lệ có thể được đăng ký trước hoặc sau khi đăng ký CPU.  Nếu
CPU được đăng ký trước đó, lõi trình điều khiển sẽ gọi lõi ZZ0000ZZ để
ghi lại tất cả các CPU đã được đăng ký trong quá trình đăng ký
trình điều khiển mở rộng quy mô.  Ngược lại, nếu bất kỳ CPU nào được đăng ký sau khi đăng ký
trình điều khiển chia tỷ lệ, lõi ZZ0001ZZ sẽ được gọi để ghi chú về chúng
tại thời điểm đăng ký của họ.

Trong mọi trường hợp, lõi ZZ0000ZZ được gọi để ghi chú bất kỳ CPU logic nào mà nó
cho đến nay vẫn chưa thấy nó sẵn sàng xử lý CPU đó.  [Lưu ý rằng
logic CPU có thể là bộ xử lý lõi đơn vật lý hoặc lõi đơn trong
bộ xử lý đa lõi hoặc luồng phần cứng trong bộ xử lý hoặc bộ xử lý vật lý
cốt lõi.  Trong phần tiếp theo "CPU" luôn có nghĩa là "CPU logic" trừ khi được nêu rõ ràng
mặt khác và từ "bộ xử lý" được dùng để chỉ phần vật lý
có thể bao gồm nhiều CPU logic.]

Sau khi được gọi, lõi ZZ0000ZZ sẽ kiểm tra xem con trỏ chính sách đã được đặt chưa
đối với CPU đã cho và nếu vậy, nó sẽ bỏ qua việc tạo đối tượng chính sách.  Nếu không,
một đối tượng chính sách mới được tạo và khởi tạo, bao gồm việc tạo ra
một thư mục chính sách mới trong ZZ0001ZZ và con trỏ chính sách tương ứng với
CPU đã cho được đặt thành địa chỉ của đối tượng chính sách mới trong bộ nhớ.

Tiếp theo, lệnh gọi lại ZZ0000ZZ của trình điều khiển mở rộng được gọi cùng với chính sách
con trỏ của CPU mới được truyền cho nó làm đối số.  Cuộc gọi lại đó được mong đợi
để khởi tạo giao diện phần cứng mở rộng hiệu suất cho CPU đã cho (hoặc,
chính xác hơn, đối với bộ CPU chia sẻ giao diện phần cứng thì nó thuộc về
tới, được biểu thị bằng đối tượng chính sách của nó) và, nếu đối tượng chính sách thì nó đã được
được yêu cầu là mới, để đặt các tham số của chính sách, như mức tối thiểu và tối đa
tần số được phần cứng hỗ trợ, bảng tần số khả dụng (nếu
tập hợp các trạng thái P được hỗ trợ không phải là một phạm vi liên tục) và mặt nạ của CPU
thuộc cùng một chính sách (bao gồm cả CPU trực tuyến và ngoại tuyến).  Đó
mặt nạ sau đó được lõi sử dụng để điền các con trỏ chính sách cho tất cả
CPU trong đó.

Bước khởi tạo chính tiếp theo cho một đối tượng chính sách mới là đính kèm một
bộ điều chỉnh tỷ lệ theo nó (bắt đầu, đó là bộ điều chỉnh tỷ lệ mặc định
được xác định bởi dòng lệnh hoặc cấu hình kernel, nhưng nó có thể bị thay đổi
sau qua ZZ0000ZZ).  Đầu tiên, một con trỏ tới đối tượng chính sách mới được chuyển tới
lệnh gọi lại ZZ0001ZZ của thống đốc dự kiến sẽ khởi tạo tất cả
cấu trúc dữ liệu cần thiết để xử lý chính sách đã cho và có thể thêm
một giao diện thống đốc ZZ0002ZZ với nó.  Tiếp theo, thống đốc được bắt đầu bởi
gọi lệnh gọi lại ZZ0003ZZ của nó.

Lệnh gọi lại đó dự kiến sẽ đăng ký các lệnh gọi lại cập nhật mức sử dụng trên mỗi CPU cho
tất cả các CPU trực tuyến thuộc chính sách nhất định với bộ lập lịch CPU.
Lệnh gọi lại cập nhật mức sử dụng sẽ được bộ lập lịch CPU gọi trên
các sự kiện quan trọng, như nhiệm vụ enqueue và dequeue, trên mỗi lần lặp của
đánh dấu vào lịch trình hoặc nói chung bất cứ khi nào việc sử dụng CPU có thể thay đổi (từ
quan điểm của người lập kế hoạch).  Họ dự kiến sẽ thực hiện các tính toán cần thiết
để xác định trạng thái P sẽ sử dụng cho chính sách đã cho trong tương lai và để
gọi trình điều khiển chia tỷ lệ để thực hiện các thay đổi đối với phần cứng theo
lựa chọn trạng thái P.  Trình điều khiển mở rộng có thể được gọi trực tiếp từ
ngữ cảnh của bộ lập lịch hoặc không đồng bộ, thông qua luồng nhân hoặc hàng đợi công việc, tùy thuộc vào
về cấu hình và khả năng của trình điều khiển tỷ lệ và bộ điều tốc.

Các bước tương tự được thực hiện đối với các đối tượng chính sách không phải là mới nhưng đã "không hoạt động"
trước đây, có nghĩa là tất cả các CPU thuộc về chúng đều ngoại tuyến.  các
sự khác biệt thực tế duy nhất trong trường hợp đó là lõi ZZ0000ZZ sẽ cố gắng
để sử dụng bộ điều chỉnh tỷ lệ được sử dụng trước đây với chính sách đã trở thành
"không hoạt động" (và hiện được khởi tạo lại) thay vì bộ điều chỉnh mặc định.

Đổi lại, nếu CPU ngoại tuyến trước đó được đưa trở lại trực tuyến, nhưng một số
các CPU khác chia sẻ đối tượng chính sách với nó đã trực tuyến rồi, không có
cần phải khởi tạo lại đối tượng chính sách.  Trong trường hợp đó, nó chỉ là
cần thiết phải khởi động lại bộ điều chỉnh tỷ lệ để có thể sử dụng CPU trực tuyến mới
tính đến.  Điều đó đạt được bằng cách gọi ZZ0000ZZ của thống đốc và
Lệnh gọi lại ZZ0001ZZ, theo thứ tự này, cho toàn bộ chính sách.

Như đã đề cập trước đó, trình điều khiển chia tỷ lệ ZZ0002ZZ bỏ qua việc chia tỷ lệ
lớp thống đốc của ZZ0000ZZ và cung cấp thuật toán lựa chọn trạng thái P của riêng nó.
Do đó, nếu sử dụng ZZ0003ZZ, bộ điều chỉnh tỷ lệ sẽ không được gắn vào
đối tượng chính sách mới  Thay vào đó, lệnh gọi lại ZZ0001ZZ của trình điều khiển được gọi
để đăng ký lệnh gọi lại cập nhật mức sử dụng trên mỗi CPU cho từng chính sách.  Những cái này
các cuộc gọi lại được gọi bởi bộ lập lịch CPU theo cách tương tự như để chia tỷ lệ
các bộ điều chỉnh, nhưng trong trường hợp ZZ0004ZZ, cả hai đều xác định trạng thái P để
sử dụng và thay đổi cấu hình phần cứng phù hợp chỉ trong một lần từ bộ lập lịch
bối cảnh.

Các đối tượng chính sách được tạo trong quá trình khởi tạo CPU và các cấu trúc dữ liệu khác
liên kết với chúng sẽ bị phá bỏ khi trình điều khiển chia tỷ lệ chưa được đăng ký
(ví dụ: điều này xảy ra khi mô-đun hạt nhân chứa nó không được tải) hoặc
khi CPU cuối cùng thuộc chính sách đã cho chưa được đăng ký.


Giao diện chính sách trong ZZ0000ZZ
=============================

Trong quá trình khởi tạo kernel, lõi ZZ0001ZZ tạo ra một
Thư mục ZZ0002ZZ (kobject) được gọi là ZZ0003ZZ trong
ZZ0000ZZ.

Thư mục đó chứa thư mục con ZZ0002ZZ (trong đó ZZ0003ZZ đại diện cho một
số nguyên) cho mọi đối tượng chính sách được duy trì bởi lõi ZZ0004ZZ.
Mỗi thư mục ZZ0005ZZ được trỏ tới bởi các liên kết tượng trưng ZZ0006ZZ
dưới ZZ0000ZZ (trong đó ZZ0007ZZ đại diện cho một số nguyên
có thể khác với cái được đại diện bởi ZZ0008ZZ) cho tất cả các CPU
liên quan đến (hoặc thuộc về) chính sách nhất định.  Các thư mục ZZ0009ZZ
trong ZZ0001ZZ, mỗi cái đều chứa chính sách cụ thể
thuộc tính (tệp) để kiểm soát hành vi ZZ0010ZZ cho chính sách tương ứng
các đối tượng (nghĩa là đối với tất cả các CPU được liên kết với chúng).

Một số thuộc tính đó là chung chung.  Chúng được tạo bởi lõi ZZ0000ZZ
và hành vi của chúng thường không phụ thuộc vào trình điều khiển mở rộng nào đang được sử dụng
và điều chỉnh tỷ lệ nào được gắn liền với chính sách nhất định.  Một số trình điều khiển mở rộng quy mô
đồng thời thêm các thuộc tính dành riêng cho trình điều khiển vào các thư mục chính sách trong ZZ0001ZZ để
kiểm soát các khía cạnh chính sách cụ thể của hành vi lái xe.

Các thuộc tính chung trong ZZ0000ZZ
như sau:

ZZ0000ZZ
	Danh sách các CPU trực tuyến thuộc chính sách này (tức là chia sẻ phần cứng
	giao diện mở rộng hiệu suất được biểu thị bằng chính sách ZZ0001ZZ
	đối tượng).

ZZ0000ZZ
	Nếu chương trình cơ sở nền tảng (BIOS) yêu cầu HĐH áp dụng giới hạn trên cho
	Tần số CPU, giới hạn đó sẽ được báo cáo thông qua thuộc tính này (nếu
	hiện tại).

Sự tồn tại của giới hạn có thể là kết quả của một số (thường là vô ý)
	Cài đặt BIOS, các hạn chế đến từ bộ xử lý dịch vụ hoặc thiết bị khác
	Cơ chế dựa trên BIOS/HW.

Điều này không bao gồm các hạn chế về nhiệt của ACPI có thể được phát hiện
	thông qua một trình điều khiển nhiệt chung.

Thuộc tính này không xuất hiện nếu trình điều khiển chia tỷ lệ đang sử dụng không
	ủng hộ nó.

ZZ0000ZZ
	Tần số hiện tại của các CPU thuộc chính sách này được lấy từ
	phần cứng (tính bằng KHz).

Đây dự kiến ​​sẽ là tần số mà phần cứng thực sự chạy.
	Nếu tần số đó không thể xác định được thì thuộc tính này sẽ không được
	có mặt.

ZZ0000ZZ
        Tần số trung bình (tính bằng KHz) của tất cả các CPU thuộc một chính sách nhất định,
        bắt nguồn từ phản hồi được cung cấp bởi phần cứng và được báo cáo theo khung thời gian
        kéo dài tối đa vài mili giây.

Điều này dự kiến ​​sẽ dựa trên tần suất phần cứng thực sự chạy
        tại và, do đó, có thể yêu cầu hỗ trợ phần cứng chuyên dụng (chẳng hạn như AMU
        tiện ích mở rộng trên ARM). Nếu không thể xác định được thì thuộc tính này sẽ
        không có mặt.

Lưu ý rằng nỗ lực truy xuất tần số hiện tại cho một khoảng thời gian nhất định không thành công.
        (Các) CPU sẽ dẫn đến một lỗi thích hợp, ví dụ: EAGAIN cho CPU
        vẫn không hoạt động (được nâng lên trên ARM).

ZZ0000ZZ
	Tần số hoạt động tối đa có thể có của các CPU thuộc chính sách này
	có thể chạy ở (tính bằng kHz).

ZZ0000ZZ
	Tần số hoạt động tối thiểu có thể có của các CPU thuộc chính sách này
	có thể chạy ở (tính bằng kHz).

ZZ0000ZZ
	Thời gian cần thiết để chuyển đổi các CPU thuộc chính sách này từ một
	Trạng thái P sang trạng thái khác, tính bằng nano giây.

ZZ0000ZZ
	Danh sách tất cả các CPU (trực tuyến và ngoại tuyến) thuộc chính sách này.

ZZ0000ZZ
	Danh sách tần số khả dụng của CPU thuộc chính sách này
	(tính bằng kHz).

ZZ0000ZZ
	Danh sách các bộ điều chỉnh tỷ lệ ZZ0001ZZ có trong kernel có thể
	được đính kèm với chính sách này hoặc (nếu trình điều khiển chia tỷ lệ ZZ0002ZZ được
	đang sử dụng) danh sách các thuật toán chia tỷ lệ do trình điều khiển cung cấp có thể được
	áp dụng cho chính sách này.

[Lưu ý rằng một số bộ điều tốc có dạng mô-đun và có thể cần phải tải một
	mô-đun hạt nhân dành cho bộ điều chỉnh do nó nắm giữ có sẵn và được sử dụng
	được liệt kê theo thuộc tính này.]

ZZ0000ZZ
	Tần số hiện tại của tất cả các CPU thuộc chính sách này (tính bằng kHz).

Trong phần lớn các trường hợp, đây là tần số của trạng thái P cuối cùng.
	được yêu cầu bởi trình điều khiển chia tỷ lệ từ phần cứng bằng cách sử dụng tính năng chia tỷ lệ
	giao diện do nó cung cấp, có thể hoặc không thể phản ánh tần số
	CPU thực sự đang chạy ở tốc độ (do thiết kế phần cứng và các yếu tố khác
	hạn chế).

Một số kiến trúc (ví dụ ZZ0000ZZ) có thể cố gắng cung cấp thông tin
	phản ánh chính xác hơn tần số CPU hiện tại thông qua điều này
	thuộc tính, nhưng đó vẫn có thể không phải là tần số CPU hiện tại chính xác như
	được nhìn thấy bởi phần cứng vào lúc này. Tuy nhiên, hành vi này chỉ
	có sẵn thông qua tùy chọn c:macro:ZZ0001ZZ.

ZZ0000ZZ
	Trình điều khiển chia tỷ lệ hiện đang được sử dụng.

ZZ0000ZZ
	Bộ điều chỉnh tỷ lệ hiện được đính kèm với chính sách này hoặc (nếu
	Trình điều khiển chia tỷ lệ ZZ0001ZZ đang được sử dụng) thuật toán chia tỷ lệ
	được cung cấp bởi trình điều khiển hiện được áp dụng cho chính sách này.

Thuộc tính này là đọc-ghi và việc ghi vào nó sẽ tạo ra một tỷ lệ mới
	thống đốc được gắn liền với chính sách này hoặc một thuật toán mở rộng quy mô mới
	được cung cấp bởi trình điều khiển chia tỷ lệ để áp dụng cho nó (trong
	trường hợp ZZ0001ZZ), như được biểu thị bằng chuỗi được ghi vào đây
	thuộc tính (phải là một trong những tên được liệt kê bởi
	Thuộc tính ZZ0000ZZ được mô tả ở trên).

ZZ0000ZZ
	Tần số tối đa mà các CPU thuộc chính sách này được phép
	chạy ở (tính bằng kHz).

Thuộc tính này là đọc-ghi và viết một chuỗi đại diện cho một
	số nguyên cho nó sẽ khiến một giới hạn mới được đặt ra (nó không được thấp hơn
	hơn giá trị của thuộc tính ZZ0000ZZ).

ZZ0000ZZ
	Tần số tối thiểu mà các CPU thuộc chính sách này được phép
	chạy ở (tính bằng kHz).

Thuộc tính này là đọc-ghi và viết một chuỗi đại diện cho một
	số nguyên không âm đối với nó sẽ khiến một giới hạn mới được đặt ra (không được phép
	cao hơn giá trị của thuộc tính ZZ0000ZZ).

ZZ0000ZZ
	Thuộc tính này chỉ hoạt động nếu bộ điều chỉnh tỷ lệ ZZ0001ZZ
	được đính kèm với chính sách nhất định.

Nó trả về tần số cuối cùng được yêu cầu bởi bộ điều chỉnh (tính bằng kHz) hoặc có thể
	được ghi vào để đặt tần suất mới cho chính sách.


Bộ điều chỉnh tỷ lệ chung
=========================

ZZ0000ZZ cung cấp bộ điều chỉnh tỷ lệ chung có thể được sử dụng với tất cả
trình điều khiển mở rộng quy mô.  Như đã nêu trước đây, mỗi người trong số họ thực hiện một, có thể
thuật toán chia tỷ lệ hiệu suất, tham số hóa.

Bộ điều chỉnh tỷ lệ được gắn vào các đối tượng chính sách và các đối tượng chính sách khác nhau
có thể được xử lý bởi các bộ điều chỉnh tỷ lệ khác nhau cùng một lúc (mặc dù điều đó
có thể dẫn đến kết quả dưới mức tối ưu trong một số trường hợp).

Bộ điều chỉnh tỷ lệ cho một đối tượng chính sách nhất định có thể được thay đổi bất kỳ lúc nào bằng
sự trợ giúp của thuộc tính chính sách ZZ0000ZZ trong ZZ0001ZZ.

Một số bộ điều chỉnh hiển thị các thuộc tính ZZ0001ZZ để kiểm soát hoặc tinh chỉnh tỷ lệ
các thuật toán do họ thực hiện.  Những thuộc tính đó, được gọi là thống đốc
có thể điều chỉnh được, có thể là toàn cầu (toàn hệ thống) hoặc theo từng chính sách, tùy thuộc vào
trình điều khiển mở rộng quy mô đang được sử dụng.  Nếu người lái xe yêu cầu điều chỉnh bộ điều tốc
per-policy, chúng nằm trong thư mục con của mỗi thư mục chính sách.
Nếu không, chúng nằm trong thư mục con bên dưới
ZZ0000ZZ.  Trong cả hai trường hợp, tên của
thư mục con chứa các điều chỉnh của thống đốc là tên của thống đốc
cung cấp cho họ.

ZZ0000ZZ
---------------

Khi được gắn vào một đối tượng chính sách, bộ điều chỉnh này gây ra tần suất cao nhất,
trong giới hạn chính sách ZZ0000ZZ, được yêu cầu cho chính sách đó.

Yêu cầu được thực hiện một lần vào thời điểm đó, thống đốc về chính sách được đặt thành
ZZ0000ZZ và bất cứ khi nào ZZ0001ZZ hoặc ZZ0002ZZ
giới hạn chính sách thay đổi sau đó.

ZZ0000ZZ
-------------

Khi được gắn vào một đối tượng chính sách, bộ điều chỉnh này gây ra tần số thấp nhất,
trong giới hạn chính sách ZZ0000ZZ, được yêu cầu cho chính sách đó.

Yêu cầu được thực hiện một lần vào thời điểm đó, thống đốc về chính sách được đặt thành
ZZ0000ZZ và bất cứ khi nào ZZ0001ZZ hoặc ZZ0002ZZ
giới hạn chính sách thay đổi sau đó.

ZZ0000ZZ
-------------

Thống đốc này không tự mình làm bất cứ điều gì.  Thay vào đó, nó cho phép không gian người dùng
để đặt tần số CPU cho chính sách mà nó được đính kèm bằng cách ghi vào
Thuộc tính ZZ0000ZZ của chính sách đó. Mặc dù mục đích có thể là
đặt tần suất chính xác cho chính sách, tần suất thực tế có thể thay đổi tùy theo
về sự phối hợp phần cứng, giới hạn nhiệt và năng lượng cũng như các yếu tố khác.

ZZ0000ZZ
-------------

Bộ điều chỉnh này sử dụng dữ liệu sử dụng CPU có sẵn từ bộ lập lịch CPU.  Nó
thường được coi là một phần của bộ lập lịch CPU, vì vậy nó có thể truy cập
trực tiếp cấu trúc dữ liệu nội bộ của bộ lập lịch.

Nó chạy hoàn toàn trong ngữ cảnh của bộ lập lịch, mặc dù trong một số trường hợp nó có thể cần phải
gọi trình điều khiển chia tỷ lệ một cách không đồng bộ khi nó quyết định rằng tần số CPU
nên được thay đổi đối với một chính sách nhất định (điều đó phụ thuộc vào việc trình điều khiển có
có khả năng thay đổi tần số CPU từ ngữ cảnh của bộ lập lịch).

Hành động của bộ điều chỉnh này đối với một CPU cụ thể phụ thuộc vào lớp lập kế hoạch
gọi lại lệnh gọi lại cập nhật mức sử dụng cho CPU đó.  Nếu nó được gọi bởi
RT hoặc các lớp lập kế hoạch thời hạn, thống đốc sẽ tăng tần suất lên
mức tối đa được phép (nghĩa là giới hạn chính sách ZZ0000ZZ).  Lần lượt,
nếu nó được gọi bởi lớp lập kế hoạch CFS, bộ điều tốc sẽ sử dụng
Số liệu Theo dõi tải trên mỗi thực thể (PELT) cho nhóm kiểm soát gốc của
lấy CPU làm ước tính sử dụng CPU (xem ZZ0001ZZ
Bài viết LWN.net [1]_ để biết mô tả về cơ chế PELT).  Sau đó, cái mới
Tần số CPU áp dụng được tính theo công thức

f = 1,25 * ZZ0000ZZ * ZZ0001ZZ / ZZ0002ZZ

trong đó ZZ0000ZZ là số PELT, ZZ0001ZZ là số tối đa theo lý thuyết của
ZZ0002ZZ và ZZ0003ZZ là tần số CPU tối đa có thể cho tần số đã cho
chính sách (nếu số PELT không đổi tần số) hoặc tần số CPU hiện tại
(nếu không).

Bộ điều chỉnh này cũng sử dụng một cơ chế cho phép nó tạm thời tăng tốc
Tần số CPU cho các tác vụ đang chờ trên I/O gần đây nhất, được gọi là
"IO-tăng cường chờ đợi".  Điều đó xảy ra khi cờ ZZ0000ZZ
được bộ lập lịch chuyển đến bộ điều chỉnh gọi lại gây ra tần số
tăng lên mức tối đa cho phép ngay lập tức và sau đó rút về giá trị
được trả về bởi công thức trên theo thời gian.

Thống đốc này chỉ hiển thị một điều chỉnh:

ZZ0000ZZ
	Thời gian tối thiểu (tính bằng micro giây) phải trôi qua giữa hai lần liên tiếp
	chạy các tính toán của bộ điều tốc (mặc định: 1,5 lần so với trình điều khiển tỷ lệ
	độ trễ chuyển tiếp hoặc 1ms nếu trình điều khiển không cung cấp giá trị độ trễ).

Mục đích của việc điều chỉnh này là để giảm chi phí ngữ cảnh của bộ lập lịch
	của thống đốc có thể là quá mức nếu không có nó.

Bộ điều tốc này thường được coi là sự thay thế cho ZZ0000ZZ cũ hơn
và Bộ điều tốc ZZ0001ZZ (được mô tả bên dưới), vì nó đơn giản hơn và hơn thế nữa
được tích hợp chặt chẽ với bộ lập lịch CPU, chi phí hoạt động của nó trong bối cảnh CPU
các công tắc và tương tự ít quan trọng hơn và nó sử dụng CPU của chính bộ lập lịch
số liệu sử dụng, do đó về nguyên tắc các quyết định của nó không được mâu thuẫn với
các quyết định được thực hiện bởi các phần khác của bộ lập lịch.

ZZ0000ZZ
------------

Bộ điều tốc này sử dụng tải CPU làm thước đo lựa chọn tần số CPU.

Để ước tính tải CPU hiện tại, nó đo thời gian trôi qua giữa
các lệnh gọi liên tiếp của thủ tục công nhân của nó và tính toán tỷ lệ đó
thời gian mà CPU đã cho không ở trạng thái rảnh.  Tỷ lệ không nhàn rỗi (hoạt động)
thời gian đến tổng thời gian CPU được lấy làm ước tính cho tải.

Nếu bộ điều chỉnh này được gắn vào một chính sách được chia sẻ bởi nhiều CPU thì tải sẽ là
được ước tính cho tất cả chúng và kết quả lớn nhất được lấy làm ước tính tải
cho toàn bộ chính sách.

Thủ tục công nhân của thống đốc này phải chạy trong bối cảnh quy trình, vì vậy nó
được gọi không đồng bộ (thông qua hàng đợi công việc) và trạng thái P của CPU được cập nhật từ
ở đó nếu cần thiết.  Kết quả là, chi phí ngữ cảnh của bộ lập lịch từ đây
thống đốc là tối thiểu, nhưng nó khiến các chuyển đổi ngữ cảnh CPU bổ sung xảy ra
tương đối thường xuyên và các bản cập nhật trạng thái P của CPU được kích hoạt bởi nó có thể tương đối
không đều.  Ngoài ra, nó còn ảnh hưởng đến số liệu tải CPU của chính nó bằng cách chạy mã
giảm thời gian nhàn rỗi của CPU (mặc dù thời gian nhàn rỗi của CPU chỉ giảm rất nhiều
hơi bằng nó).

Nó thường chọn tần số CPU tỷ lệ thuận với tải ước tính, do đó
giá trị của thuộc tính chính sách ZZ0000ZZ tương ứng với tải của
1 (hoặc 100%) và giá trị của thuộc tính chính sách ZZ0001ZZ
tương ứng với tải bằng 0, trừ khi tải vượt quá a (có thể định cấu hình)
ngưỡng tăng tốc, trong trường hợp đó nó sẽ đi thẳng tới tần số cao nhất
nó được phép sử dụng (giới hạn chính sách ZZ0002ZZ).

Thống đốc này đưa ra các điều chỉnh sau:

ZZ0000ZZ
	Đây là tần suất hoạt động thường lệ của công việc của thống đốc, trong
	micro giây.

Thông thường, nó được đặt thành các giá trị ở mức 2000 (2 ms).  của nó
	giá trị mặc định là thêm 50% phòng thở
	tới ZZ0000ZZ theo từng chính sách mà thống đốc này thực hiện
	gắn liền với. Mức tối thiểu thường là độ dài của hai bộ lập lịch
	bọ ve.

Nếu điều chỉnh này là theo chính sách, lệnh shell sau sẽ đặt thời gian
	được biểu thị bằng nó cao gấp 1,5 lần độ trễ chuyển đổi
	(mặc định)::

# echo ZZ0000ZZ > theo yêu cầu/tốc độ lấy mẫu

ZZ0000ZZ
	Nếu tải CPU ước tính cao hơn giá trị này (tính bằng phần trăm), bộ điều tốc
	sẽ đặt tần số thành giá trị tối đa được phép cho chính sách.
	Ngược lại, tần số được chọn sẽ tỷ lệ thuận với tần số ước tính
	Tải CPU.

ZZ0000ZZ
	Nếu được đặt thành 1 (mặc định là 0), nó sẽ khiến mã ước tính tải CPU
	xử lý thời gian CPU dành cho việc thực hiện các tác vụ ở mức "đẹp" hơn
	hơn 0 là thời gian rảnh của CPU.

Điều này có thể hữu ích nếu có những nhiệm vụ trong hệ thống không nên thực hiện.
	được tính đến khi quyết định tần số để chạy CPU.
	Sau đó, để thực hiện được điều đó chỉ cần tăng mức độ “đẹp” là đủ
	của những nhiệm vụ trên 0 và đặt thuộc tính này thành 1.

ZZ0000ZZ
	Hệ số nhân tạm thời, bao gồm từ 1 (mặc định) đến 100, để áp dụng cho
	giá trị ZZ0001ZZ nếu tải CPU vượt quá ZZ0002ZZ.

Điều này gây ra việc thực hiện tiếp theo của quy trình công nhân của thống đốc (sau
	đặt tần số ở mức tối đa cho phép) bị trễ, do đó
	tần số duy trì ở mức tối đa trong một thời gian dài hơn.

Có thể tránh được dao động tần số trong một số khối lượng công việc bùng nổ theo cách này
	với chi phí năng lượng bổ sung dành cho việc duy trì CPU tối đa
	năng lực.

ZZ0001ZZ
	Hệ số giảm áp dụng cho mục tiêu tần số ban đầu của
	bộ điều tốc (bao gồm giá trị lớn nhất được sử dụng khi ZZ0002ZZ
	vượt quá giá trị tải CPU ước tính) hoặc ngưỡng độ nhạy
	dành cho trình điều khiển thiên vị tiết kiệm năng lượng theo độ nhạy tần số AMD
	(ZZ0000ZZ), từ 0 đến 1000
	bao gồm.

Nếu trình điều khiển thiên vị tiết kiệm năng lượng có độ nhạy tần số AMD không được tải,
	tần suất hiệu quả để áp dụng được đưa ra bởi

f * (1 - ZZ0000ZZ / 1000)

trong đó f là mục tiêu tần số ban đầu của bộ điều tốc.  Giá trị mặc định
	của thuộc tính này là 0 trong trường hợp đó.

Nếu trình điều khiển thiên vị tiết kiệm năng lượng có độ nhạy tần số AMD được tải, thì
	Giá trị của thuộc tính này theo mặc định là 400 và nó được sử dụng theo cách khác
	cách.

Trên bộ xử lý AMD Family 16h (và mới hơn) có một cơ chế để có được
	đo độ nhạy khối lượng công việc, bao gồm từ 0 đến 100%, từ
	phần cứng.  Giá trị đó có thể được sử dụng để ước tính hiệu suất của
	khối lượng công việc chạy trên CPU sẽ thay đổi theo sự thay đổi tần số.

Hiệu suất của khối lượng công việc có độ nhạy bằng 0 (bị ràng buộc bởi bộ nhớ hoặc
	IO-bound) dự kiến sẽ không tăng chút nào do tăng
	tần số CPU, trong khi khối lượng công việc có độ nhạy 100%
	(CPU-bound) dự kiến sẽ hoạt động tốt hơn nhiều nếu tần số CPU là
	tăng lên.

Nếu độ nhạy của khối lượng công việc nhỏ hơn ngưỡng được biểu thị bằng
	giá trị ZZ0000ZZ, trình điều khiển thiên vị tiết kiệm năng lượng cho độ nhạy
	sẽ khiến bộ điều tốc chọn tần số thấp hơn tần số ban đầu của nó
	mục tiêu, để tránh cung cấp quá mức khối lượng công việc sẽ không mang lại lợi ích
	chạy ở tần số CPU cao hơn.

ZZ0000ZZ
----------------

Bộ điều tốc này sử dụng tải CPU làm thước đo lựa chọn tần số CPU.

Nó ước tính tải CPU theo cách tương tự như bộ điều chỉnh ZZ0000ZZ được mô tả
ở trên, nhưng thuật toán chọn tần số CPU do nó triển khai thì khác.

Cụ thể là nó tránh thay đổi tần số đáng kể trong khoảng thời gian ngắn
có thể không phù hợp với các hệ thống có khả năng cung cấp điện hạn chế (ví dụ:
chạy bằng pin).  Để đạt được điều đó, nó thay đổi tần số tương đối
bước nhỏ, từng bước một, lên hay xuống - tùy thuộc vào việc
(có thể định cấu hình) đã bị vượt quá ngưỡng CPU ước tính.

Thống đốc này đưa ra các điều chỉnh sau:

ZZ0000ZZ
	Bước tần số tính bằng phần trăm của tần số tối đa mà bộ điều tốc là
	được phép đặt (giới hạn chính sách ZZ0001ZZ), trong khoảng từ 0 đến
	100 (5 theo mặc định).

Đây là tần số được phép thay đổi trong một lần.  Cài đặt
	nó về 0 sẽ khiến bước tần số mặc định (5 phần trăm) được sử dụng
	và việc đặt nó thành 100 sẽ khiến cho bộ điều chỉnh định kỳ
	chuyển đổi tần số giữa ZZ0000ZZ và
	Giới hạn chính sách của ZZ0001ZZ.

ZZ0000ZZ
	Giá trị ngưỡng (theo phần trăm, theo mặc định là 20) được sử dụng để xác định
	hướng thay đổi tần số.

Nếu tải CPU ước tính lớn hơn giá trị này, tần số sẽ
	đi lên (bởi ZZ0000ZZ).  Nếu tải nhỏ hơn giá trị này (và
	Cơ chế ZZ0001ZZ không có hiệu lực), tần số sẽ
	đi xuống.  Nếu không, tần số sẽ không thay đổi.

ZZ0000ZZ
	Hệ số trì hoãn giảm tần suất, từ 1 (mặc định) đến 10
	bao gồm.

Nó có tác dụng làm giảm tần số ZZ0000ZZ
	chậm hơn nhiều lần so với khi tăng tốc.


Hỗ trợ tăng tần số
=======================

Background
----------

Một số bộ xử lý hỗ trợ cơ chế tăng tần số hoạt động của một số bộ xử lý
lõi trong gói đa lõi tạm thời (và trên tần số bền vững
ngưỡng cho toàn bộ gói) trong những điều kiện nhất định, ví dụ: nếu
toàn bộ chip không được sử dụng hết và dưới mức nhiệt hoặc năng lượng dự kiến.

Different names are used by different vendors to refer to this functionality.
For Intel processors it is referred to as "Turbo Boost", AMD calls it
"Turbo-Core" or (in technical documentation) "Core Performance Boost" and so on.
As a rule, it also is implemented differently by different vendors.  The simple
term "frequency boost" is used here for brevity to refer to all of those
implementations.

The frequency boost mechanism may be either hardware-based or software-based.
If it is hardware-based (e.g. on x86), the decision to trigger the boosting is
made by the hardware (although in general it requires the hardware to be put
into a special state in which it can control the CPU frequency within certain
limits).  If it is software-based (e.g. on ARM), the scaling driver decides
whether or not to trigger boosting and when to do that.

The ``boost`` File in ``sysfs``
-------------------------------

This file is located under :file:`/sys/devices/system/cpu/cpufreq/` and controls
the "boost" setting for the whole system.  It is not present if the underlying
scaling driver does not support the frequency boost mechanism (or supports it,
but provides a driver-specific interface for controlling it, like
|intel_pstate|).

If the value in this file is 1, the frequency boost mechanism is enabled.  This
means that either the hardware can be put into states in which it is able to
trigger boosting (in the hardware-based case), or the software is allowed to
trigger boosting (in the software-based case).  It does not mean that boosting
is actually in use at the moment on any CPUs in the system.  It only means a
permission to use the frequency boost mechanism (which still may never be used
for other reasons).

If the value in this file is 0, the frequency boost mechanism is disabled and
cannot be used at all.

The only values that can be written to this file are 0 and 1.

Rationale for Boost Control Knob
--------------------------------

The frequency boost mechanism is generally intended to help to achieve optimum
CPU performance on time scales below software resolution (e.g. below the
scheduler tick interval) and it is demonstrably suitable for many workloads, but
it may lead to problems in certain situations.

For this reason, many systems make it possible to disable the frequency boost
mechanism in the platform firmware (BIOS) setup, but that requires the system to
be restarted for the setting to be adjusted as desired, which may not be
practical at least in some cases.  For example:

  1. Boosting means overclocking the processor, although under controlled
     conditions.  Generally, the processor's energy consumption increases
     as a result of increasing its frequency and voltage, even temporarily.
     That may not be desirable on systems that switch to power sources of
     limited capacity, such as batteries, so the ability to disable the boost
     mechanism while the system is running may help there (but that depends on
     the workload too).

  2. In some situations deterministic behavior is more important than
     performance or energy consumption (or both) and the ability to disable
     boosting while the system is running may be useful then.

  3. To examine the impact of the frequency boost mechanism itself, it is useful
     to be able to run tests with and without boosting, preferably without
     restarting the system in the meantime.

  4. Reproducible results are important when running benchmarks.  Since
     the boosting functionality depends on the load of the whole package,
     single-thread performance may vary because of it which may lead to
     unreproducible results sometimes.  That can be avoided by disabling the
     frequency boost mechanism before running benchmarks sensitive to that
     issue.

Legacy AMD ``cpb`` Knob
-----------------------

The AMD powernow-k8 scaling driver supports a ``sysfs`` knob very similar to
the global ``boost`` one.  It is used for disabling/enabling the "Core
Performance Boost" feature of some AMD processors.

If present, that knob is located in every ``CPUFreq`` policy directory in
``sysfs`` (:file:`/sys/devices/system/cpu/cpufreq/policyX/`) and is called
``cpb``, which indicates a more fine grained control interface.  The actual
implementation, however, works on the system-wide basis and setting that knob
for one policy causes the same value of it to be set for all of the other
policies at the same time.

That knob is still supported on AMD processors that support its underlying
hardware feature, but it may be configured out of the kernel (via the
:c:macro:`CONFIG_X86_ACPI_CPUFREQ_CPB` configuration option) and the global
``boost`` knob is present regardless.  Thus it is always possible use the
``boost`` knob instead of the ``cpb`` one which is highly recommended, as that
is more consistent with what all of the other systems do (and the ``cpb`` knob
may not be supported any more in the future).

The ``cpb`` knob is never present for any processors without the underlying
hardware feature (e.g. all Intel ones), even if the
:c:macro:`CONFIG_X86_ACPI_CPUFREQ_CPB` configuration option is set.


References
==========

.. [1] Jonathan Corbet, *Per-entity load tracking*,
       https://lwn.net/Articles/531853/