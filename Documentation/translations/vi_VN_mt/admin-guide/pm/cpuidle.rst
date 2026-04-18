.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/cpuidle.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

.. |struct cpuidle_state| replace:: :c:type:`struct cpuidle_state <cpuidle_state>`
.. |cpufreq| replace:: :doc:`CPU Performance Scaling <cpufreq>`

==============================
CPU Quản lý thời gian nhàn rỗi
==============================

:Bản quyền: ZZ0000ZZ 2018 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Khái niệm
=========

Các bộ xử lý hiện đại thường có thể chuyển sang các trạng thái trong đó việc thực thi
một chương trình bị đình chỉ và các hướng dẫn thuộc về chương trình đó không được lấy từ
bộ nhớ hoặc được thực thi.  Các trạng thái đó là trạng thái ZZ0000ZZ của bộ xử lý.

Vì một phần phần cứng của bộ xử lý không được sử dụng ở trạng thái không hoạt động nên việc nhập chúng
thường cho phép giảm năng lượng mà bộ xử lý tiêu thụ và do đó,
đó là cơ hội để tiết kiệm năng lượng.

Quản lý thời gian nhàn rỗi của CPU là một tính năng tiết kiệm năng lượng liên quan đến việc sử dụng
trạng thái nhàn rỗi của bộ xử lý cho mục đích này.

CPU logic
------------

Quản lý thời gian nhàn rỗi của CPU hoạt động trên CPU như ZZ0000ZZ đã thấy (đó
là một phần của hạt nhân chịu trách nhiệm phân phối các công cụ tính toán
làm việc trong hệ thống).  Theo quan điểm của nó, CPU là đơn vị ZZ0001ZZ.  Tức là họ cần
không phải là các thực thể vật lý riêng biệt và có thể chỉ là các giao diện xuất hiện để
phần mềm như các bộ xử lý lõi đơn riêng lẻ.  Nói cách khác, CPU là một
thực thể dường như đang tìm nạp các hướng dẫn thuộc về một chuỗi
(chương trình) từ bộ nhớ và thực thi chúng, nhưng nó không cần phải hoạt động theo cách này
về thể chất.  Nói chung, ba trường hợp khác nhau có thể được xem xét ở đây.

Đầu tiên, nếu toàn bộ bộ xử lý chỉ có thể tuân theo một chuỗi hướng dẫn (một
chương trình) tại một thời điểm, nó là CPU.  Trong trường hợp đó, nếu phần cứng được yêu cầu
nhập trạng thái không hoạt động, áp dụng cho toàn bộ bộ xử lý.

Thứ hai, nếu bộ xử lý có nhiều lõi thì mỗi lõi trong đó có thể tuân theo tốc độ
ít nhất một chương trình tại một thời điểm.  Các lõi không nhất thiết phải hoàn toàn độc lập với nhau
khác (ví dụ: họ có thể chia sẻ bộ nhớ đệm), nhưng hầu hết thời gian họ
hoạt động vật lý song song với nhau, vì vậy nếu mỗi cái chỉ thực thi
một chương trình, các chương trình đó hầu như chạy độc lập với nhau trong cùng một
thời gian.  Toàn bộ lõi là CPU trong trường hợp đó và nếu phần cứng được yêu cầu
chuyển sang trạng thái không hoạt động, áp dụng cho lõi được yêu cầu trong lần đầu tiên
địa điểm, nhưng nó cũng có thể áp dụng cho một đơn vị lớn hơn (chẳng hạn như "gói" hoặc "cụm")
mà lõi thuộc về (trên thực tế, nó có thể áp dụng cho toàn bộ hệ thống phân cấp lớn hơn
đơn vị chứa lõi).  Cụ thể là, nếu tất cả các lõi trong đơn vị lớn hơn
ngoại trừ một cái đã được đưa vào trạng thái không hoạt động ở "cấp lõi" và
lõi còn lại yêu cầu bộ xử lý chuyển sang trạng thái không hoạt động, điều này có thể kích hoạt nó
để đưa toàn bộ thiết bị lớn hơn vào trạng thái không hoạt động, điều này cũng sẽ ảnh hưởng đến
các lõi khác trong đơn vị đó.

Cuối cùng, mỗi lõi trong bộ xử lý đa lõi có thể theo dõi nhiều lõi
chương trình trong cùng một khung thời gian (nghĩa là mỗi lõi có thể tìm nạp
hướng dẫn từ nhiều vị trí trong bộ nhớ và thực hiện chúng trong cùng một thời điểm
khung, nhưng không nhất thiết phải hoàn toàn song song với nhau).  Trong trường hợp đó
các lõi tự thể hiện với phần mềm dưới dạng các "gói", mỗi lõi bao gồm
nhiều "bộ xử lý" lõi đơn riêng lẻ, được gọi là ZZ0000ZZ
(hoặc siêu luồng cụ thể trên phần cứng Intel), mỗi siêu luồng có thể theo một
trình tự hướng dẫn.  Sau đó, các luồng phần cứng là CPU từ CPU không hoạt động
phối cảnh quản lý thời gian và liệu bộ xử lý có được yêu cầu chuyển sang trạng thái không hoạt động hay không
bởi một trong số họ, luồng phần cứng (hoặc CPU) yêu cầu nó đã bị dừng, nhưng
không có gì xảy ra nữa, trừ khi tất cả các luồng phần cứng khác trong cùng một
core cũng đã yêu cầu bộ xử lý chuyển sang trạng thái không hoạt động.  Trong hoàn cảnh đó,
lõi có thể được đặt ở trạng thái không hoạt động riêng lẻ hoặc một đơn vị lớn hơn chứa
toàn bộ nó có thể được đặt ở trạng thái không hoạt động (nếu các lõi khác trong
đơn vị lớn hơn đang ở trạng thái không hoạt động).

CPU nhàn rỗi
------------

CPU logic, được gọi đơn giản là "CPU" sau đây, được coi là
ZZ0000ZZ bởi nhân Linux khi không có tác vụ nào để chạy trên chúng ngoại trừ
nhiệm vụ "nhàn rỗi" đặc biệt.

Nhiệm vụ là sự thể hiện công việc của bộ lập lịch CPU.  Mỗi nhiệm vụ bao gồm một
chuỗi các hướng dẫn để thực thi hoặc mã hóa dữ liệu được xử lý trong khi
chạy mã đó và một số thông tin ngữ cảnh cần được tải vào
bộ xử lý mỗi khi mã của tác vụ được chạy bởi CPU.  Bộ lập lịch CPU
phân phối công việc bằng cách phân công nhiệm vụ chạy cho các CPU có trong hệ thống.

Nhiệm vụ có thể ở nhiều trạng thái khác nhau.  Đặc biệt, chúng là ZZ0000ZZ nếu có
không có điều kiện cụ thể nào ngăn cản mã của họ được chạy bởi CPU miễn là
có sẵn CPU cho việc đó (ví dụ: họ không chờ đợi bất kỳ
sự kiện xảy ra hoặc tương tự).  Khi một tác vụ có thể chạy được, bộ lập lịch CPU
gán nó cho một trong các CPU có sẵn để chạy và nếu không còn CPU nào có thể chạy được nữa
nhiệm vụ được giao cho nó, CPU sẽ tải ngữ cảnh của nhiệm vụ đó và chạy nó
mã (từ lệnh theo sau lệnh cuối cùng được thực hiện cho đến nay, có thể bởi
một CPU khác).  [Nếu có nhiều tác vụ có thể chạy được được gán cho một CPU
đồng thời, chúng sẽ được ưu tiên và chia sẻ thời gian để
để cho phép họ đạt được một số tiến bộ theo thời gian.]

Tác vụ "nhàn rỗi" đặc biệt sẽ có thể chạy được nếu không có tác vụ nào khác có thể chạy được
được gán cho CPU đã cho và CPU sau đó được coi là không hoạt động.  Nói cách khác,
trong các CPU nhàn rỗi của Linux chạy mã của tác vụ "nhàn rỗi" có tên là ZZ0000ZZ.  Đó
mã có thể khiến bộ xử lý được đặt vào một trong các trạng thái không hoạt động của nó, nếu chúng
được hỗ trợ, để tiết kiệm năng lượng, nhưng nếu bộ xử lý không hỗ trợ bất kỳ
trạng thái nhàn rỗi hoặc không có đủ thời gian để ở trạng thái nhàn rỗi trước khi
sự kiện đánh thức tiếp theo hoặc có các hạn chế về độ trễ nghiêm ngặt ngăn cản bất kỳ
trạng thái nhàn rỗi có sẵn khi được sử dụng, CPU sẽ chỉ thực thi ít nhiều
những hướng dẫn vô ích trong một vòng lặp cho đến khi nó được giao một nhiệm vụ mới để chạy.


.. _idle-loop:

Vòng lặp nhàn rỗi
=================

Mã vòng lặp nhàn rỗi thực hiện hai bước chính trong mỗi lần lặp của nó.  Đầu tiên, nó
gọi vào một mô-đun mã được gọi là ZZ0002ZZ thuộc CPU
hệ thống con quản lý thời gian nhàn rỗi có tên ZZ0000ZZ để chọn trạng thái nhàn rỗi cho
CPU để yêu cầu phần cứng nhập.  Thứ hai, nó gọi một mô-đun mã khác
từ hệ thống con ZZ0001ZZ, được gọi là ZZ0003ZZ, để thực sự yêu cầu
phần cứng bộ xử lý để chuyển sang trạng thái không hoạt động do Thống đốc lựa chọn.

Vai trò của thống đốc là tìm ra trạng thái nhàn rỗi phù hợp nhất cho
điều kiện trong tầm tay.  Với mục đích này, nhàn rỗi nói rằng phần cứng có thể
được yêu cầu nhập bởi CPU logic được biểu diễn một cách trừu tượng độc lập với
nền tảng hoặc kiến trúc bộ xử lý và được tổ chức theo mô hình một chiều
mảng (tuyến tính).  Mảng đó phải được chuẩn bị và cung cấp bởi ZZ0000ZZ
trình điều khiển phù hợp với nền tảng mà kernel đang chạy khi khởi tạo
thời gian.  Điều này cho phép các bộ điều chỉnh ZZ0001ZZ độc lập với cơ sở
phần cứng và làm việc với mọi nền tảng mà nhân Linux có thể chạy trên đó.

Mỗi trạng thái nhàn rỗi có trong mảng đó được đặc trưng bởi hai tham số được
được thống đốc, ZZ0000ZZ và (trường hợp xấu nhất) tính đến
ZZ0001ZZ.  Nơi cư trú mục tiêu là thời gian tối thiểu mà phần cứng phải
tiêu ở trạng thái nhất định, bao gồm cả thời gian cần thiết để vào trạng thái đó (có thể
đáng kể), để tiết kiệm nhiều năng lượng hơn mức có thể tiết kiệm bằng cách nhập một trong các
thay vào đó là trạng thái nhàn rỗi nông hơn.  ["Độ sâu" của trạng thái nhàn rỗi khoảng
tương ứng với công suất mà bộ xử lý tiêu thụ ở trạng thái đó.] Lối ra
Ngược lại, độ trễ là thời gian tối đa mà CPU sẽ yêu cầu bộ xử lý
phần cứng chuyển sang trạng thái không hoạt động để bắt đầu thực hiện lệnh đầu tiên sau một
thức dậy từ trạng thái đó.  Lưu ý rằng nhìn chung độ trễ thoát cũng phải bao gồm
thời gian cần thiết để vào trạng thái nhất định trong trường hợp việc đánh thức xảy ra khi
phần cứng đang truy cập vào nó và nó phải được nhập hoàn toàn để thoát ra trong một
cách có trật tự.

Có hai loại thông tin có thể ảnh hưởng đến quyết định của thống đốc.
Trước hết, thống đốc biết thời gian cho đến sự kiện hẹn giờ gần nhất.  Đó
thời gian được biết chính xác, bởi vì các chương trình kernel tính giờ và nó biết chính xác
khi nào chúng sẽ kích hoạt và đó là thời gian tối đa mà phần cứng đã cho
CPU tùy thuộc vào khả năng chi tiêu ở trạng thái không hoạt động, bao gồm cả thời gian cần thiết để vào
và thoát khỏi nó.  Tuy nhiên, CPU có thể bị đánh thức bởi một sự kiện không hẹn giờ bất cứ lúc nào
(đặc biệt là trước khi bộ đếm thời gian kích hoạt gần nhất) và nó thường không được biết đến
khi điều đó có thể xảy ra.  Thống đốc chỉ có thể xem CPU thực sự có bao nhiêu thời gian
không hoạt động sau khi được đánh thức (thời gian đó sẽ được gọi là *nhàn rỗi
thời lượng* kể từ bây giờ) và nó có thể sử dụng thông tin đó bằng cách nào đó cùng với
thời gian cho đến bộ đếm thời gian gần nhất để ước tính thời gian nhàn rỗi trong tương lai.  Làm thế nào
Thống đốc sử dụng thông tin đó phụ thuộc vào thuật toán nào được thực hiện bởi nó
và đó là lý do chính cho việc có nhiều hơn một thống đốc trong
Hệ thống con ZZ0000ZZ.

Có sẵn bốn bộ điều tốc ZZ0004ZZ, ZZ0005ZZ, ZZ0010ZZ,
ZZ0006ZZ và ZZ0007ZZ.  Cái nào trong số chúng được sử dụng theo mặc định tùy thuộc vào
cấu hình của kernel và đặc biệt là về việc bộ lập lịch có
đánh dấu có thể là ZZ0011ZZ.  Có sẵn
bộ điều tốc có thể được đọc từ ZZ0000ZZ, và bộ điều tốc
có thể được thay đổi trong thời gian chạy.  Tên của thống đốc ZZ0008ZZ hiện tại
được sử dụng bởi kernel có thể được đọc từ ZZ0001ZZ hoặc
Tệp ZZ0002ZZ trong ZZ0003ZZ
trong ZZ0009ZZ.

Mặt khác, trình điều khiển ZZ0002ZZ nào được sử dụng thường phụ thuộc vào
nền tảng mà kernel đang chạy trên đó, nhưng có những nền tảng có nhiều hơn một
trình điều khiển phù hợp.  Ví dụ: có hai trình điều khiển có thể hoạt động với
phần lớn các nền tảng Intel, ZZ0003ZZ và ZZ0004ZZ, một nền tảng có
thông tin trạng thái nhàn rỗi được mã hóa cứng và thông tin khác có thể đọc thông tin đó
tương ứng từ các bảng ACPI của hệ thống.  Tuy nhiên, ngay cả trong những trường hợp đó,
Trình điều khiển được chọn tại thời điểm khởi tạo hệ thống không thể được thay thế sau đó, vì vậy
quyết định sử dụng cái nào trong số chúng phải được đưa ra sớm (trên nền tảng Intel
trình điều khiển ZZ0005ZZ sẽ được sử dụng nếu ZZ0006ZZ bị tắt đối với một số
lý do hoặc nếu nó không nhận ra bộ xử lý).  Tên của ZZ0007ZZ
trình điều khiển hiện đang được kernel sử dụng có thể được đọc từ ZZ0000ZZ
tệp dưới ZZ0001ZZ trong ZZ0008ZZ.


.. _idle-cpus-and-tick:

CPU nhàn rỗi và đánh dấu bộ lập lịch
====================================

Đánh dấu bộ lập lịch là bộ đếm thời gian được kích hoạt định kỳ để thực hiện
chiến lược chia sẻ thời gian của bộ lập lịch CPU.  Tất nhiên, nếu có
nhiều tác vụ có thể chạy được được giao cho một CPU cùng lúc, cách duy nhất để
cho phép họ đạt được tiến bộ hợp lý trong một khung thời gian nhất định là làm cho họ
chia sẻ thời gian CPU có sẵn.  Cụ thể, trong phép tính gần đúng, mỗi nhiệm vụ được
dành một phần thời gian cho CPU để chạy mã của nó, tùy thuộc vào lớp lập kế hoạch,
ưu tiên, v.v. và khi khoảng thời gian đó được sử dụng hết, CPU sẽ được
chuyển sang chạy (mã của) một nhiệm vụ khác.  Tác vụ hiện đang chạy
Tuy nhiên, có thể không muốn tự nguyện tặng CPU và đánh dấu vào lịch trình
có mặt ở đó để thực hiện việc chuyển đổi bất chấp điều đó.  Đó không phải là vai trò duy nhất của
đánh dấu, nhưng đó là lý do chính để sử dụng nó.

Đánh dấu bộ lập lịch có vấn đề từ góc độ quản lý thời gian nhàn rỗi của CPU,
bởi vì nó kích hoạt định kỳ và tương đối thường xuyên (tùy thuộc vào kernel
cấu hình, độ dài của khoảng thời gian đánh dấu là từ 1 ms đến 10 ms).
Vì vậy, nếu cho phép tích tắc kích hoạt trên các CPU nhàn rỗi sẽ không có ý nghĩa gì
để họ yêu cầu phần cứng chuyển sang trạng thái không hoạt động với các vị trí mục tiêu ở trên
độ dài thời gian đánh dấu.  Hơn nữa, trong trường hợp đó, thời gian nhàn rỗi của bất kỳ CPU nào
sẽ không bao giờ vượt quá độ dài thời gian đánh dấu và năng lượng được sử dụng để vào và
việc thoát khỏi trạng thái nhàn rỗi do đánh dấu đánh thức trên các CPU nhàn rỗi sẽ bị lãng phí.

May mắn thay, không thực sự cần thiết phải cho phép đánh dấu kích hoạt khi không hoạt động
CPU, bởi vì (theo định nghĩa) chúng không có nhiệm vụ nào để chạy ngoại trừ nhiệm vụ đặc biệt
một cái "nhàn rỗi".  Nói cách khác, từ góc độ bộ lập lịch CPU, người dùng duy nhất
thời gian của CPU trên chúng là vòng lặp nhàn rỗi.  Kể từ thời điểm CPU nhàn rỗi cần
không được chia sẻ giữa nhiều tác vụ có thể chạy được, lý do chính để sử dụng
đánh dấu sẽ biến mất nếu CPU đã cho không hoạt động.  Do đó, có thể dừng
về nguyên tắc, bộ lập lịch đánh dấu hoàn toàn vào các CPU nhàn rỗi, mặc dù điều đó có thể không
luôn xứng đáng với nỗ lực.

Việc dừng đánh dấu lịch trình trong vòng lặp nhàn rỗi có hợp lý hay không
phụ thuộc vào những gì được thống đốc mong đợi.  Đầu tiên, nếu có cái khác
(không đánh dấu) do kích hoạt trong phạm vi đánh dấu, dừng đánh dấu rõ ràng
sẽ lãng phí thời gian, mặc dù phần cứng hẹn giờ có thể không cần thiết.
được lập trình lại trong trường hợp đó.  Thứ hai, nếu thống đốc đang mong đợi một tín hiệu không hẹn giờ
thức dậy trong phạm vi đánh dấu, việc dừng đánh dấu là không cần thiết và thậm chí có thể
có hại.  Cụ thể, trong trường hợp đó bộ điều tốc sẽ chọn trạng thái rảnh với
nơi cư trú mục tiêu trong khoảng thời gian cho đến khi thức dậy dự kiến, vì vậy trạng thái đó là
sẽ tương đối nông.  Thống đốc thực sự không thể chọn một nhàn rỗi sâu
tuyên bố sau đó, vì điều đó sẽ mâu thuẫn với kỳ vọng của chính nó về sự thức tỉnh trong thời gian ngắn
đặt hàng.  Bây giờ, nếu việc đánh thức thực sự diễn ra trong thời gian ngắn, việc dừng đánh dấu sẽ là một
lãng phí thời gian và trong trường hợp này phần cứng hẹn giờ sẽ cần phải được lập trình lại,
cái đó đắt tiền  Mặt khác, nếu tiếng tích tắc dừng lại và sự thức dậy
không xảy ra sớm, phần cứng có thể mất một khoảng thời gian không xác định
ở trạng thái nhàn rỗi nông được thống đốc lựa chọn, điều này sẽ gây lãng phí
năng lượng.  Do đó, nếu thống đốc đang mong đợi một sự thức tỉnh dưới bất kỳ hình thức nào trong
phạm vi đánh dấu, tốt hơn là cho phép kích hoạt đánh dấu.  Tuy nhiên, nếu không thì
thống đốc sẽ chọn trạng thái không tải tương đối sâu, vì vậy nên dừng tích tắc
để nó không đánh thức CPU quá sớm.

Trong mọi trường hợp, thống đốc biết những gì họ mong đợi và quyết định liệu
hoặc không dừng đánh dấu lịch trình thuộc về nó.  Tuy nhiên, nếu đánh dấu đã được
đã dừng lại (ở một trong các lần lặp trước của vòng lặp), tốt hơn là
hãy để nguyên như vậy và thống đốc cần phải tính đến điều đó.

Hạt nhân có thể được cấu hình để vô hiệu hóa việc dừng đánh dấu lịch trình khi không hoạt động
vòng lặp hoàn toàn.  Điều đó có thể được thực hiện thông qua cấu hình thời gian xây dựng của nó
(bằng cách bỏ cài đặt tùy chọn cấu hình ZZ0000ZZ) hoặc bằng cách chuyển
ZZ0001ZZ vào nó trong dòng lệnh.  Trong cả hai trường hợp, khi dừng
đánh dấu lịch trình bị vô hiệu hóa, các quyết định của thống đốc liên quan đến nó chỉ đơn giản là
bị bỏ qua bởi mã vòng lặp nhàn rỗi và dấu tích không bao giờ dừng lại.

Các hệ thống chạy hạt nhân được cấu hình để cho phép đánh dấu bộ lập lịch
bị dừng trên các CPU nhàn rỗi được gọi là hệ thống ZZ0003ZZ và chúng
thường được coi là tiết kiệm năng lượng hơn so với các hệ thống chạy hạt nhân trong
mà tích tắc không thể dừng lại.  Nếu hệ thống nhất định không có tích tắc, nó sẽ sử dụng
bộ điều tốc ZZ0000ZZ theo mặc định và nếu nó không tích tắc thì mặc định
Thống đốc ZZ0001ZZ trên đó sẽ là ZZ0002ZZ.


.. _menu-gov:

Thống đốc ZZ0000ZZ
=====================

Bộ điều tốc ZZ0000ZZ là bộ điều tốc ZZ0001ZZ mặc định cho các hệ thống không tích tắc.
Nó khá phức tạp, nhưng nguyên tắc cơ bản trong thiết kế của nó rất đơn giản.
Cụ thể, khi được gọi để chọn trạng thái không hoạt động cho CPU (tức là trạng thái không hoạt động
CPU sẽ yêu cầu phần cứng bộ xử lý nhập vào), nó sẽ cố gắng dự đoán
thời gian nhàn rỗi và sử dụng giá trị dự đoán để lựa chọn trạng thái nhàn rỗi.

Đầu tiên nó sử dụng một thuật toán nhận dạng mẫu đơn giản để thu được kết quả sơ bộ.
dự đoán thời gian nhàn rỗi.  Cụ thể là nó lưu lại 8 thời gian nhàn rỗi được quan sát gần nhất
giá trị và khi dự đoán thời gian nhàn rỗi vào lần tiếp theo, nó sẽ tính giá trị trung bình
và phương sai của chúng.  Nếu phương sai nhỏ (nhỏ hơn 400 bình phương
mili giây) hoặc nó nhỏ so với mức trung bình (trung bình lớn hơn
gấp 6 lần độ lệch chuẩn), giá trị trung bình được coi là "giá trị điển hình
giá trị khoảng".  Mặt khác, dài nhất hoặc ngắn nhất (tùy thuộc vào
cái nào xa hơn mức trung bình) của thời gian nhàn rỗi được quan sát đã lưu
các giá trị bị loại bỏ và việc tính toán được lặp lại cho các giá trị còn lại.

Một lần nữa, nếu phương sai của chúng nhỏ (theo nghĩa trên), thì giá trị trung bình là
được lấy làm giá trị "khoảng điển hình", v.v., cho đến khi "khoảng điển hình"
interval" được xác định hoặc quá nhiều điểm dữ liệu bị bỏ qua.  Ở phần sau
trường hợp, nếu kích thước của tập hợp các điểm dữ liệu vẫn đang được xem xét là
đủ lớn, thời gian nhàn rỗi tiếp theo khó có thể vượt quá thời gian lớn nhất
giá trị thời lượng không hoạt động vẫn còn trong tập hợp đó, do đó giá trị đó được lấy làm giá trị dự đoán
thời gian nhàn rỗi tiếp theo.  Cuối cùng, nếu tập hợp các điểm dữ liệu vẫn nằm trong
sự xem xét quá nhỏ, không có dự đoán nào được đưa ra.

Nếu dự đoán sơ bộ về thời gian nhàn rỗi tiếp theo được tính theo cách này là
đủ lâu, thống đốc sẽ có được thời gian cho đến khi sự kiện tính giờ gần nhất xảy ra với
giả định rằng việc đánh dấu lịch trình sẽ bị dừng lại.  Lần đó, nhắc đến
như ZZ0000ZZ trong phần tiếp theo, là giới hạn trên vào thời điểm trước
lần thức dậy CPU tiếp theo.  Nó được sử dụng để xác định phạm vi độ dài giấc ngủ, từ đó
là cần thiết để có được hệ số điều chỉnh độ dài giấc ngủ.

Bộ điều tốc ZZ0000ZZ duy trì một mảng chứa một số hệ số hiệu chỉnh
các giá trị tương ứng với các khoảng thời gian ngủ khác nhau được sắp xếp sao cho mỗi giá trị
phạm vi được biểu thị trong mảng rộng hơn khoảng 10 lần so với trước đó
một.

Hệ số hiệu chỉnh cho khoảng thời gian ngủ nhất định (được xác định trước
việc chọn trạng thái không hoạt động cho CPU) được cập nhật sau khi CPU được đánh thức
lên và thời gian ngủ càng gần với thời gian nhàn rỗi được quan sát thì càng gần
đến 1 thì hệ số hiệu chỉnh sẽ trở thành (nó phải nằm trong khoảng từ 0 đến 1).
Độ dài giấc ngủ được nhân với hệ số hiệu chỉnh cho phạm vi mà nó
rơi vào để có được giá trị gần đúng về thời gian nhàn rỗi được dự đoán là
so với "khoảng thời gian điển hình" được xác định trước đó và mức tối thiểu của
cả hai được coi là dự đoán thời gian nhàn rỗi cuối cùng.

Nếu giá trị "khoảng điển hình" nhỏ, điều đó có nghĩa là CPU có khả năng
được thức dậy đủ sớm, việc tính toán độ dài giấc ngủ sẽ bị bỏ qua vì nó có thể
tốn kém và thời gian nhàn rỗi được dự đoán đơn giản là bằng "thời gian điển hình
giá trị khoảng".

Bây giờ, thống đốc đã sẵn sàng duyệt qua danh sách các trạng thái nhàn rỗi và chọn một trong các trạng thái đó.
họ.  Với mục đích này, nó so sánh nơi cư trú mục tiêu của mỗi tiểu bang với
thời lượng không hoạt động được dự đoán và độ trễ thoát của nó với độ trễ
giới hạn đến từ chất lượng dịch vụ quản lý năng lượng hoặc ZZ0000ZZ,
khuôn khổ.  Nó chọn tiểu bang có nơi cư trú mục tiêu gần nhất với dự đoán
thời gian nhàn rỗi nhưng vẫn ở dưới mức đó và độ trễ thoát không vượt quá
giới hạn.

Ở bước cuối cùng, thống đốc có thể vẫn cần tinh chỉnh việc lựa chọn trạng thái nhàn rỗi
nếu nó chưa quyết định ZZ0000ZZ.  Đó
xảy ra nếu thời gian nhàn rỗi được dự đoán bởi nó nhỏ hơn thời gian đánh dấu và
đánh dấu vẫn chưa bị dừng lại (trong lần lặp trước của chế độ chờ
vòng lặp).  Khi đó, độ dài giấc ngủ được sử dụng trong các tính toán trước đó có thể không phản ánh
thời gian thực cho đến sự kiện hẹn giờ gần nhất và nếu nó thực sự lớn hơn
lúc đó, thống đốc có thể cần chọn một bang nông hơn với cơ chế phù hợp
nơi cư trú mục tiêu.


.. _teo-gov:

Bộ đếm thời gian định hướng sự kiện (TEO)
=========================================

Bộ điều chỉnh định hướng sự kiện hẹn giờ (TEO) là bộ điều chỉnh ZZ0000ZZ thay thế
cho các hệ thống không tích tắc.  Nó tuân theo chiến lược cơ bản tương tự như ZZ0001ZZ ZZ0002ZZ: nó luôn cố gắng tìm trạng thái không hoạt động sâu nhất phù hợp với
điều kiện nhất định.  Tuy nhiên, nó áp dụng một cách tiếp cận khác cho vấn đề đó.

.. kernel-doc:: drivers/cpuidle/governors/teo.c
   :doc: teo-description

.. _idle-states-representation:

Đại diện của các quốc gia nhàn rỗi
==================================

Đối với mục đích quản lý thời gian nhàn rỗi của CPU, tất cả các trạng thái nhàn rỗi vật lý
được bộ xử lý hỗ trợ phải được biểu diễn dưới dạng mảng một chiều của
Mỗi đối tượng ZZ0001ZZ cho phép một CPU riêng lẻ (hợp lý) hỏi
phần cứng bộ xử lý để chuyển sang trạng thái không hoạt động của một số thuộc tính nhất định.  Nếu có
là một hệ thống phân cấp các đơn vị trong bộ xử lý, một đối tượng ZZ0002ZZ có thể
bao gồm sự kết hợp của các trạng thái nhàn rỗi được hỗ trợ bởi các đơn vị ở các mức độ khác nhau
hệ thống phân cấp.  Trong trường hợp đó, ZZ0000ZZ phải phản ánh các thuộc tính của trạng thái không hoạt động tại
mức sâu nhất (tức là trạng thái không hoạt động của thiết bị chứa tất cả các thiết bị khác
đơn vị).

Ví dụ: lấy bộ xử lý có hai lõi trong một đơn vị lớn hơn được gọi là
một "mô-đun" và giả sử rằng việc yêu cầu phần cứng chuyển sang trạng thái không hoạt động cụ thể
(nói "X") ở cấp độ "lõi" theo một lõi sẽ kích hoạt mô-đun cố gắng
nhập một trạng thái không hoạt động cụ thể của riêng nó (giả sử "MX") nếu lõi kia ở trạng thái không hoạt động
nói "X" rồi.  Nói cách khác, yêu cầu trạng thái rảnh "X" ở "lõi"
cấp độ này cấp cho phần cứng giấy phép để chuyển sang trạng thái không hoạt động "MX" tại
cấp độ "mô-đun", nhưng không có gì đảm bảo rằng điều này sẽ xảy ra (cốt lõi
thay vào đó, yêu cầu trạng thái không hoạt động "X" có thể tự kết thúc ở trạng thái đó).
Sau đó, nơi cư trú mục tiêu của đối tượng ZZ0000ZZ đại diện cho
trạng thái không hoạt động "X" phải phản ánh thời gian tối thiểu để sử dụng ở trạng thái không hoạt động "MX" của
mô-đun (bao gồm cả thời gian cần thiết để nhập nó), vì đó là thời gian tối thiểu
thời gian CPU cần ở chế độ rảnh để tiết kiệm năng lượng trong trường hợp phần cứng xâm nhập
trạng thái đó.  Tương tự, tham số độ trễ thoát của đối tượng đó phải bao gồm
thời gian thoát ở trạng thái không hoạt động "MX" của mô-đun (và thường là thời gian vào của mô-đun),
vì đó là độ trễ tối đa giữa tín hiệu đánh thức và thời điểm CPU
sẽ bắt đầu thực hiện lệnh mới đầu tiên (giả sử rằng cả hai lõi trong
mô-đun sẽ luôn sẵn sàng thực hiện các hướng dẫn ngay khi mô-đun
sẽ đi vào hoạt động tổng thể).

Có những bộ xử lý không có sự phối hợp trực tiếp giữa các cấp độ khác nhau của
Tuy nhiên, hệ thống phân cấp của các đơn vị bên trong chúng.  Trong những trường hợp yêu cầu nhàn rỗi
trạng thái ở cấp độ "lõi" không tự động ảnh hưởng đến cấp độ "mô-đun", vì
ví dụ, dưới bất kỳ hình thức nào và trình điều khiển ZZ0000ZZ chịu trách nhiệm về toàn bộ
xử lý hệ thống phân cấp.  Sau đó, định nghĩa của các đối tượng trạng thái nhàn rỗi là
hoàn toàn phụ thuộc vào người lái nhưng vẫn là các đặc tính vật lý của trạng thái không tải
mà phần cứng bộ xử lý cuối cùng đi vào phải luôn tuân theo các thông số
được sử dụng bởi bộ điều tốc để lựa chọn trạng thái nhàn rỗi (ví dụ: lối ra thực tế
độ trễ của trạng thái không hoạt động đó không được vượt quá tham số độ trễ thoát của
đối tượng trạng thái nhàn rỗi do thống đốc lựa chọn).

Ngoài các tham số trạng thái nhàn rỗi và độ trễ thoát mục tiêu
đã thảo luận ở trên, các đối tượng biểu diễn trạng thái nhàn rỗi đều chứa một vài đối tượng khác
các tham số mô tả trạng thái không hoạt động và một con trỏ tới hàm sẽ chạy trong đó
để yêu cầu phần cứng vào trạng thái đó.  Ngoài ra, đối với mỗi
Đối tượng ZZ0002ZZ, có một đối tượng tương ứng
ZZ0000ZZ một trong đó có cách sử dụng
thống kê của trạng thái nhàn rỗi nhất định.  Thông tin đó được phơi bày bởi kernel
thông qua ZZ0001ZZ.

Đối với mỗi CPU trong hệ thống, có một ZZ0000ZZ
thư mục trong ZZ0003ZZ, trong đó số ZZ0004ZZ được gán cho
CPU tại thời điểm khởi tạo.  Thư mục đó chứa một tập hợp các thư mục con
được gọi là ZZ0001ZZ, ZZ0002ZZ, v.v., tùy theo số trạng thái không hoạt động
các đối tượng được xác định cho CPU đã cho trừ đi một.  Mỗi thư mục này
tương ứng với một đối tượng trạng thái rảnh rỗi và số trong tên của nó càng lớn thì
sâu hơn trạng thái nhàn rỗi (hiệu quả) được đại diện bởi nó.  Mỗi người trong số họ chứa
một số tệp (thuộc tính) đại diện cho các thuộc tính của trạng thái không hoạt động
đối tượng tương ứng với nó như sau:

ZZ0000ZZ
	Tổng số lần trạng thái nhàn rỗi này đã được yêu cầu, nhưng
	thời gian nhàn rỗi được quan sát chắc chắn là quá ngắn để đạt được mục tiêu của nó
	cư trú.

ZZ0000ZZ
	Tổng số lần trạng thái nhàn rỗi này đã được yêu cầu, nhưng chắc chắn
	trạng thái nhàn rỗi sâu hơn sẽ phù hợp hơn với trạng thái nhàn rỗi được quan sát
	thời lượng.

ZZ0000ZZ
	Mô tả trạng thái nhàn rỗi.

ZZ0000ZZ
	Trạng thái nhàn rỗi này có bị tắt hay không.

ZZ0000ZZ
	Trạng thái mặc định của trạng thái này là "đã bật" hoặc "đã tắt".

ZZ0000ZZ
	Độ trễ thoát của trạng thái không hoạt động tính bằng micro giây.

ZZ0000ZZ
	Tên trạng thái nhàn rỗi.

ZZ0000ZZ
	Công suất được tiêu thụ bởi phần cứng ở trạng thái không tải này tính bằng miliwatt (nếu được chỉ định,
	0 nếu không).

ZZ0000ZZ
	Mục tiêu cư trú của trạng thái không hoạt động tính bằng micro giây.

ZZ0000ZZ
	Tổng thời gian ở trạng thái không hoạt động này của CPU đã cho (được đo bằng
	kernel) tính bằng micro giây.

ZZ0000ZZ
	Tổng số lần phần cứng đã được CPU đưa ra yêu cầu
	đi vào trạng thái nhàn rỗi này.

ZZ0000ZZ
	Tổng số lần yêu cầu chuyển sang trạng thái không hoạt động này trên thiết bị đã cho
	CPU đã bị từ chối.

Các tệp ZZ0000ZZ và ZZ0001ZZ đều chứa chuỗi.  Sự khác biệt
giữa chúng là cái tên được mong đợi sẽ ngắn gọn hơn, trong khi
mô tả có thể dài hơn và có thể chứa khoảng trắng hoặc ký tự đặc biệt.
Các tệp khác được liệt kê ở trên chứa số nguyên.

Thuộc tính ZZ0000ZZ là thuộc tính duy nhất có thể ghi được.  Nếu nó chứa 1 thì
trạng thái nhàn rỗi đã cho bị vô hiệu hóa đối với CPU cụ thể này, điều đó có nghĩa là
thống đốc sẽ không bao giờ chọn nó cho CPU và ZZ0001ZZ cụ thể này
Do đó, trình điều khiển sẽ không bao giờ yêu cầu phần cứng nhập nó cho CPU đó.
Tuy nhiên, việc vô hiệu hóa trạng thái không hoạt động của một chiếc CPU không ngăn được việc nó bị
được yêu cầu bởi các CPU khác, do đó nó phải bị vô hiệu hóa đối với tất cả chúng để
không bao giờ được yêu cầu bởi bất kỳ ai trong số họ.  [Lưu ý rằng, do cách ZZ0002ZZ
thống đốc được thực hiện, việc vô hiệu hóa trạng thái nhàn rỗi sẽ ngăn cản thống đốc đó
chọn bất kỳ trạng thái nhàn rỗi nào sâu hơn trạng thái bị vô hiệu hóa.]

Nếu thuộc tính ZZ0000ZZ chứa 0, trạng thái không hoạt động đã cho sẽ được bật cho
CPU cụ thể này, nhưng nó vẫn có thể bị vô hiệu hóa đối với một số hoặc tất cả các CPU khác
CPU trong hệ thống cùng một lúc.  Viết 1 vào nó sẽ khiến trạng thái không hoạt động
bị vô hiệu hóa đối với CPU cụ thể này và việc ghi 0 vào nó cho phép bộ điều tốc
hãy cân nhắc chiếc CPU đã cho và người lái xe để yêu cầu nó,
trừ khi trạng thái đó bị vô hiệu hóa toàn cầu trong trình điều khiển (trong trường hợp đó nó không thể
đều được sử dụng).

Thuộc tính ZZ0000ZZ không được xác định rõ ràng, đặc biệt đối với trạng thái không hoạt động
các đối tượng đại diện cho sự kết hợp của các trạng thái nhàn rỗi ở các cấp độ khác nhau của
phân cấp các đơn vị trong bộ xử lý và nói chung khó có được
số công suất trạng thái cho phần cứng phức tạp, vì vậy ZZ0001ZZ thường chứa 0 (không phải
có sẵn) và nếu nó chứa một số khác 0 thì số đó có thể không
chính xác và không nên dựa vào nó để làm bất cứ điều gì có ý nghĩa.

Con số trong tệp ZZ0000ZZ nhìn chung có thể lớn hơn tổng thời gian
thực sự được chi tiêu bởi CPU đã cho ở trạng thái không hoạt động nhất định, bởi vì nó được đo bằng
kernel và nó có thể không bao gồm các trường hợp phần cứng từ chối nhập
trạng thái nhàn rỗi này và thay vào đó chuyển sang trạng thái nông hơn (hoặc thậm chí nó không
nhập bất kỳ trạng thái nhàn rỗi nào).  Hạt nhân chỉ có thể đo khoảng thời gian giữa
yêu cầu phần cứng chuyển sang trạng thái không hoạt động và sau đó CPU được đánh thức
và nó không thể nói điều gì thực sự đã xảy ra trong thời gian đó ở cấp độ phần cứng.
Hơn nữa, nếu đối tượng trạng thái rảnh rỗi được đề cập đại diện cho sự kết hợp của trạng thái rảnh rỗi
trạng thái ở các cấp độ khác nhau của hệ thống phân cấp các đơn vị trong bộ xử lý,
hạt nhân không bao giờ có thể nói phần cứng đã đi sâu vào hệ thống phân cấp như thế nào trong bất kỳ
trường hợp cụ thể.  Vì những lý do này, cách đáng tin cậy duy nhất để tìm ra cách
phần cứng đã dành nhiều thời gian ở các trạng thái nhàn rỗi khác nhau được hỗ trợ bởi
đó là sử dụng bộ đếm trạng thái nhàn rỗi trong phần cứng, nếu có.

Nói chung, một ngắt nhận được khi cố gắng chuyển sang trạng thái không hoạt động sẽ gây ra
yêu cầu nhập trạng thái không hoạt động bị từ chối, trong trường hợp đó trình điều khiển ZZ0002ZZ
có thể trả về một mã lỗi để cho biết đây là trường hợp. ZZ0000ZZ
và các tệp ZZ0001ZZ báo cáo số lần trạng thái không hoạt động đã cho
đã được nhập thành công hoặc bị từ chối tương ứng.

.. _cpu-pm-qos:

Quản lý năng lượng Chất lượng dịch vụ cho CPU
=============================================

Khung chất lượng dịch vụ quản lý năng lượng (PM QoS) trong nhân Linux
cho phép mã hạt nhân và các tiến trình không gian người dùng thiết lập các ràng buộc trên nhiều
các tính năng tiết kiệm năng lượng của hạt nhân để ngăn chặn tình trạng giảm hiệu suất
dưới mức yêu cầu.

Việc quản lý thời gian nhàn rỗi của CPU có thể bị ảnh hưởng bởi PM QoS theo hai cách, thông qua
giới hạn độ trễ CPU toàn cầu và thông qua các hạn chế về độ trễ tiếp tục cho
các CPU riêng lẻ.  Mã hạt nhân (ví dụ: trình điều khiển thiết bị) có thể đặt cả hai bằng
sự trợ giúp của các giao diện nội bộ đặc biệt được cung cấp bởi khung PM QoS.  người dùng
không gian có thể sửa đổi cái trước bằng cách mở ZZ0000ZZ đặc biệt
tệp thiết bị theo ZZ0001ZZ và ghi giá trị nhị phân (được hiểu là
số nguyên 32 bit đã ký) cho nó.  Đổi lại, hạn chế độ trễ tiếp tục cho CPU
có thể được sửa đổi từ không gian người dùng bằng cách viết một chuỗi (biểu thị một chuỗi đã ký
số nguyên 32 bit) vào tệp ZZ0002ZZ bên dưới
ZZ0003ZZ trong ZZ0004ZZ, trong đó số CPU
ZZ0005ZZ được phân bổ tại thời điểm khởi tạo hệ thống.  Giá trị âm
sẽ bị từ chối trong cả hai trường hợp và cả trong cả hai trường hợp, số nguyên được viết
số sẽ được hiểu là ràng buộc PM QoS được yêu cầu tính bằng micro giây.

The requested value is not automatically applied as a new constraint, however,
as it may be less restrictive (greater in this particular case) than another
constraint previously requested by someone else.  For this reason, the PM QoS
framework maintains a list of requests that have been made so far for the
global CPU latency limit and for each individual CPU, aggregates them and
applies the effective (minimum in this particular case) value as the new
constraint.

In fact, opening the :file:`cpu_dma_latency` special device file causes a new
PM QoS request to be created and added to a global priority list of CPU latency
limit requests and the file descriptor coming from the "open" operation
represents that request.  If that file descriptor is then used for writing, the
number written to it will be associated with the PM QoS request represented by
it as a new requested limit value.  Next, the priority list mechanism will be
used to determine the new effective value of the entire list of requests and
that effective value will be set as a new CPU latency limit.  Thus requesting a
new limit value will only change the real limit if the effective "list" value is
affected by it, which is the case if it is the minimum of the requested values
in the list.

The process holding a file descriptor obtained by opening the
:file:`cpu_dma_latency` special device file controls the PM QoS request
associated with that file descriptor, but it controls this particular PM QoS
request only.

Closing the :file:`cpu_dma_latency` special device file or, more precisely, the
file descriptor obtained while opening it, causes the PM QoS request associated
with that file descriptor to be removed from the global priority list of CPU
latency limit requests and destroyed.  If that happens, the priority list
mechanism will be used again, to determine the new effective value for the whole
list and that value will become the new limit.

In turn, for each CPU there is one resume latency PM QoS request associated with
the :file:`power/pm_qos_resume_latency_us` file under
:file:`/sys/devices/system/cpu/cpu<N>/` in ``sysfs`` and writing to it causes
this single PM QoS request to be updated regardless of which user space
process does that.  In other words, this PM QoS request is shared by the entire
user space, so access to the file associated with it needs to be arbitrated
to avoid confusion.  [Arguably, the only legitimate use of this mechanism in
practice is to pin a process to the CPU in question and let it use the
``sysfs`` interface to control the resume latency constraint for it.]  It is
still only a request, however.  It is an entry in a priority list used to
determine the effective value to be set as the resume latency constraint for the
CPU in question every time the list of requests is updated this way or another
(there may be other requests coming from kernel code in that list).

CPU idle time governors are expected to regard the minimum of the global
(effective) CPU latency limit and the effective resume latency constraint for
the given CPU as the upper limit for the exit latency of the idle states that
they are allowed to select for that CPU.  They should never select any idle
states with exit latency beyond that limit.

While the above CPU QoS constraints apply to CPU idle time management, user
space may also request a CPU system wakeup latency QoS limit, via the
`cpu_wakeup_latency` file.  This QoS constraint is respected when selecting a
suitable idle state for the CPUs, while entering the system-wide suspend-to-idle
sleep state, but also to the regular CPU idle time management.

Note that, the management of the `cpu_wakeup_latency` file works according to
the 'cpu_dma_latency' file from user space point of view.  Moreover, the unit
is also microseconds.

Idle States Control Via Kernel Command Line
===========================================

In addition to the ``sysfs`` interface allowing individual idle states to be
`disabled for individual CPUs <idle-states-representation_>`_, there are kernel
command line parameters affecting CPU idle time management.

The ``cpuidle.off=1`` kernel command line option can be used to disable the
CPU idle time management entirely.  It does not prevent the idle loop from
running on idle CPUs, but it prevents the CPU idle time governors and drivers
from being invoked.  If it is added to the kernel command line, the idle loop
will ask the hardware to enter idle states on idle CPUs via the CPU architecture
support code that is expected to provide a default mechanism for this purpose.
That default mechanism usually is the least common denominator for all of the
processors implementing the architecture (i.e. CPU instruction set) in question,
however, so it is rather crude and not very energy-efficient.  For this reason,
it is not recommended for production use.

The ``cpuidle.governor=`` kernel command line switch allows the ``CPUIdle``
governor to use to be specified.  It has to be appended with a string matching
the name of an available governor (e.g. ``cpuidle.governor=menu``) and that
governor will be used instead of the default one.  It is possible to force
the ``menu`` governor to be used on the systems that use the ``ladder`` governor
by default this way, for example.

The other kernel command line parameters controlling CPU idle time management
described below are only relevant for the *x86* architecture and references
to ``intel_idle`` affect Intel processors only.

The *x86* architecture support code recognizes three kernel command line
options related to CPU idle time management: ``idle=poll``, ``idle=halt``,
and ``idle=nomwait``.  The first two of them disable the ``acpi_idle`` and
``intel_idle`` drivers altogether, which effectively causes the entire
``CPUIdle`` subsystem to be disabled and makes the idle loop invoke the
architecture support code to deal with idle CPUs.  How it does that depends on
which of the two parameters is added to the kernel command line.  In the
``idle=halt`` case, the architecture support code will use the ``HLT``
instruction of the CPUs (which, as a rule, suspends the execution of the program
and causes the hardware to attempt to enter the shallowest available idle state)
for this purpose, and if ``idle=poll`` is used, idle CPUs will execute a
more or less "lightweight" sequence of instructions in a tight loop.  [Note
that using ``idle=poll`` is somewhat drastic in many cases, as preventing idle
CPUs from saving almost any energy at all may not be the only effect of it.
For example, on Intel hardware it effectively prevents CPUs from using
P-states (see |cpufreq|) that require any number of CPUs in a package to be
idle, so it very well may hurt single-thread computations performance as well as
energy-efficiency.  Thus using it for performance reasons may not be a good idea
at all.]

The ``idle=nomwait`` option prevents the use of ``MWAIT`` instruction of
the CPU to enter idle states. When this option is used, the ``acpi_idle``
driver will use the ``HLT`` instruction instead of ``MWAIT``. On systems
running Intel processors, this option disables the ``intel_idle`` driver
and forces the use of the ``acpi_idle`` driver instead. Note that in either
case, ``acpi_idle`` driver will function only if all the information needed
by it is in the system's ACPI tables.

In addition to the architecture-level kernel command line options affecting CPU
idle time management, there are parameters affecting individual ``CPUIdle``
drivers that can be passed to them via the kernel command line.  Specifically,
the ``intel_idle.max_cstate=<n>`` and ``processor.max_cstate=<n>`` parameters,
where ``<n>`` is an idle state index also used in the name of the given
state's directory in ``sysfs`` (see
`Representation of Idle States <idle-states-representation_>`_), causes the
``intel_idle`` and ``acpi_idle`` drivers, respectively, to discard all of the
idle states deeper than idle state ``<n>``.  In that case, they will never ask
for any of those idle states or expose them to the governor.  [The behavior of
the two drivers is different for ``<n>`` equal to ``0``.  Adding
``intel_idle.max_cstate=0`` to the kernel command line disables the
``intel_idle`` driver and allows ``acpi_idle`` to be used, whereas
``processor.max_cstate=0`` is equivalent to ``processor.max_cstate=1``.
Also, the ``acpi_idle`` driver is part of the ``processor`` kernel module that
can be loaded separately and ``max_cstate=<n>`` can be passed to it as a module
parameter when it is loaded.]