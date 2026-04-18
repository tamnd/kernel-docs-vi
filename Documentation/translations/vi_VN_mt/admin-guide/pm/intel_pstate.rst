.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/intel_pstate.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

====================================================
Trình điều khiển mở rộng hiệu suất ZZ0000ZZ CPU
===============================================

:Bản quyền: ZZ0000ZZ 2017 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>


Thông tin chung
===================

ZZ0001ZZ là một phần của
ZZ0000ZZ trong nhân Linux
(ZZ0002ZZ).  Nó là trình điều khiển mở rộng quy mô cho Sandy Bridge và sau này
thế hệ bộ xử lý Intel.  Tuy nhiên, lưu ý rằng một số bộ xử lý đó
có thể không được hỗ trợ.  [Để hiểu ZZ0003ZZ cần phải biết
ZZ0004ZZ nói chung hoạt động như thế nào, vì vậy đây là lúc để đọc
Documentation/admin-guide/pm/cpufreq.rst nếu bạn chưa làm điều đó.]

Đối với các bộ xử lý được ZZ0000ZZ hỗ trợ, khái niệm trạng thái P rộng hơn
không chỉ là tần số hoạt động hoặc điểm hiệu suất hoạt động (xem phần
Bài thuyết trình LinuxCon Châu Âu 2015 của Kristen Accardi [1]_ để biết thêm
thông tin về điều đó).  Vì lý do này, việc biểu diễn các trạng thái P được sử dụng
bởi ZZ0001ZZ nội bộ tuân theo thông số kỹ thuật phần cứng (để biết chi tiết
tham khảo Hướng dẫn dành cho nhà phát triển phần mềm Intel [2]_).  Tuy nhiên, lõi ZZ0002ZZ
sử dụng tần số để xác định các điểm hiệu suất hoạt động của CPU và
tần số có liên quan đến giao diện không gian người dùng mà nó tiếp xúc, vì vậy
ZZ0003ZZ cũng ánh xạ biểu diễn bên trong của trạng thái P thành tần số
(may mắn thay, bản đồ đó không rõ ràng).  Đồng thời, sẽ không
thiết thực để ZZ0004ZZ cung cấp cho lõi ZZ0005ZZ một bảng
tần số có sẵn do kích thước có thể có của nó, vì vậy trình điều khiển không làm
đó.  Một số chức năng của lõi bị hạn chế bởi điều đó.

Do giao diện lựa chọn trạng thái P phần cứng được ZZ0000ZZ sử dụng là
có sẵn ở mức logic CPU, trình điều khiển luôn hoạt động với từng cá nhân
CPU.  Do đó, nếu ZZ0001ZZ được sử dụng, mọi chính sách ZZ0002ZZ
đối tượng tương ứng với một chính sách logic CPU và ZZ0003ZZ có hiệu quả
tương đương với CPU.  Đặc biệt, điều này có nghĩa là chúng trở nên "không hoạt động" mỗi
thời điểm CPU tương ứng được ngoại tuyến và cần được khởi tạo lại khi
nó quay trở lại trực tuyến.

ZZ0001ZZ không phải là mô-đun nên không thể dỡ xuống, điều đó có nghĩa là
cách duy nhất để truyền các tham số thời gian cấu hình sớm cho nó là thông qua kernel
dòng lệnh.  Tuy nhiên, cấu hình của nó có thể được điều chỉnh thông qua ZZ0002ZZ để
mức độ lớn.  Trong một số cấu hình thậm chí có thể hủy đăng ký thông qua
ZZ0003ZZ cho phép tải trình điều khiển chia tỷ lệ ZZ0004ZZ khác và
đã đăng ký (xem ZZ0000ZZ).

.. _operation_modes:

Chế độ hoạt động
===============

ZZ0000ZZ có thể hoạt động ở hai chế độ khác nhau, chủ động hoặc thụ động.  trong
chế độ hoạt động, nó sử dụng thuật toán điều chỉnh tỷ lệ hiệu suất nội bộ của chính nó hoặc
cho phép phần cứng tự thực hiện việc điều chỉnh hiệu suất, trong khi ở chế độ thụ động
chế độ nó đáp ứng các yêu cầu được thực hiện bởi bộ điều chỉnh ZZ0001ZZ chung đang thực hiện
một thuật toán mở rộng hiệu suất nhất định.  Cái nào trong số chúng sẽ có hiệu lực
phụ thuộc vào tùy chọn dòng lệnh kernel nào được sử dụng và vào khả năng của
bộ xử lý.

.. _active_mode:

Chế độ hoạt động
-----------

Đây là chế độ hoạt động mặc định của ZZ0000ZZ dành cho bộ xử lý có
Hỗ trợ trạng thái P được quản lý bằng phần cứng (HWP).  Nếu nó hoạt động ở chế độ này,
Thuộc tính chính sách ZZ0001ZZ trong ZZ0002ZZ cho tất cả các chính sách ZZ0003ZZ
chứa chuỗi "intel_pstate".

Ở chế độ này, trình điều khiển bỏ qua lớp điều chỉnh tỷ lệ của ZZ0000ZZ và
cung cấp các thuật toán chia tỷ lệ riêng để lựa chọn trạng thái P.  Những thuật toán đó
có thể được áp dụng cho các chính sách ZZ0001ZZ theo cách tương tự như chia tỷ lệ chung
các bộ điều chỉnh (nghĩa là thông qua thuộc tính chính sách ZZ0002ZZ trong
ZZ0003ZZ).  [Lưu ý rằng các thuật toán lựa chọn trạng thái P khác nhau có thể được chọn cho
các chính sách khác nhau, nhưng điều đó không được khuyến khích.]

Chúng không phải là các bộ điều chỉnh tỷ lệ chung chung, nhưng tên của chúng giống với
tên của một số thống đốc đó.  Hơn nữa, điều khá khó hiểu là họ thường
không hoạt động theo cách giống như các thống đốc chung mà họ cùng tên.
Ví dụ: thuật toán chọn trạng thái P ZZ0000ZZ được cung cấp bởi
ZZ0001ZZ không phải là bản sao của bộ điều tốc ZZ0002ZZ chung
(đại khái, nó tương ứng với các bộ điều chỉnh ZZ0003ZZ và ZZ0004ZZ).

Có hai thuật toán lựa chọn trạng thái P được cung cấp bởi ZZ0000ZZ trong
chế độ hoạt động: ZZ0001ZZ và ZZ0002ZZ.  Cách cả hai đều hoạt động
phụ thuộc vào việc tính năng trạng thái P được quản lý bằng phần cứng (HWP) có được
được kích hoạt trong bộ xử lý và có thể trên kiểu bộ xử lý.

Thuật toán lựa chọn trạng thái P nào được sử dụng theo mặc định phụ thuộc vào
Tùy chọn cấu hình hạt nhân ZZ0000ZZ.
Cụ thể, nếu tùy chọn đó được đặt, thuật toán ZZ0001ZZ sẽ được sử dụng bởi
mặc định và cái còn lại sẽ được sử dụng theo mặc định nếu nó không được đặt.

.. _active_mode_hwp:

Chế độ hoạt động với HWP
~~~~~~~~~~~~~~~~~~~~

Nếu bộ xử lý hỗ trợ tính năng HWP, nó sẽ được bật trong quá trình
khởi tạo bộ xử lý và không thể tắt sau đó.  Có thể
để tránh kích hoạt nó bằng cách chuyển đối số ZZ0000ZZ cho
hạt nhân trong dòng lệnh.

Nếu tính năng HWP đã được bật, ZZ0000ZZ sẽ dựa vào bộ xử lý để
tự mình chọn trạng thái P, nhưng nó vẫn có thể đưa ra gợi ý cho bộ xử lý
logic lựa chọn trạng thái P bên trong.  Những gợi ý đó là gì phụ thuộc vào trạng thái P nào
thuật toán lựa chọn đã được áp dụng cho chính sách nhất định (hoặc cho CPU nó
tương ứng với).

Mặc dù việc lựa chọn trạng thái P được bộ xử lý thực hiện tự động,
ZZ0000ZZ đăng ký lệnh gọi lại cập nhật sử dụng với bộ lập lịch CPU
ở chế độ này.  Tuy nhiên, chúng không được sử dụng để chạy lựa chọn trạng thái P
thuật toán, nhưng để cập nhật định kỳ thông tin tần số CPU hiện tại lên
được cung cấp từ thuộc tính chính sách ZZ0001ZZ trong ZZ0002ZZ.

HWP + ZZ0000ZZ
.....................

Trong cấu hình này ZZ0000ZZ sẽ ghi 0 vào bộ xử lý
Núm Tùy chọn Hiệu suất Năng lượng (EPP) (nếu được hỗ trợ) hoặc nút
Núm Xu hướng Hiệu suất Năng lượng (EPB) (nếu không), có nghĩa là bộ xử lý
logic lựa chọn trạng thái P nội bộ dự kiến sẽ tập trung hoàn toàn vào hiệu suất.

Điều này sẽ ghi đè cài đặt EPP/EPB đến từ giao diện ZZ0001ZZ
(xem ZZ0000ZZ bên dưới).  Hơn nữa, bất kỳ nỗ lực nào nhằm thay đổi
EPP/EPB thành giá trị khác 0 ("hiệu suất") thông qua ZZ0002ZZ trong trường hợp này
cấu hình sẽ bị từ chối.

Ngoài ra, trong cấu hình này, phạm vi trạng thái P có sẵn cho bộ xử lý
logic lựa chọn trạng thái P bên trong luôn bị giới hạn ở ranh giới trên
(tức là trạng thái P tối đa mà người lái xe được phép sử dụng).

HWP + ZZ0000ZZ
...................

Trong cấu hình này ZZ0000ZZ sẽ đặt bộ xử lý
Núm Tùy chọn Hiệu suất Năng lượng (EPP) (nếu được hỗ trợ) hoặc nút
Núm Xu hướng Hiệu suất Năng lượng (EPB) (nếu không) thành bất kỳ giá trị nào
trước đây được đặt thành thông qua ZZ0001ZZ (hoặc bất kỳ giá trị mặc định nào được đặt
được thiết lập bởi phần sụn nền tảng).  Điều này thường khiến bộ xử lý
logic lựa chọn trạng thái P bên trong để ít tập trung vào hiệu suất hơn.

Chế độ hoạt động không có HWP
~~~~~~~~~~~~~~~~~~~~~~~

Chế độ hoạt động này là tùy chọn cho các bộ xử lý không hỗ trợ HWP
tính năng hoặc khi đối số ZZ0000ZZ được chuyển tới kernel trong
dòng lệnh.  Chế độ hoạt động được sử dụng trong những trường hợp đó nếu
Đối số ZZ0001ZZ được truyền tới kernel trong dòng lệnh.
Ở chế độ này ZZ0002ZZ có thể từ chối hoạt động với các bộ xử lý không
được nó công nhận.  [Lưu ý rằng ZZ0003ZZ sẽ không bao giờ từ chối làm việc với
bất kỳ bộ xử lý nào có bật tính năng HWP.]

Ở chế độ này, ZZ0000ZZ đăng ký các lệnh gọi lại cập nhật mức sử dụng với
Bộ lập lịch CPU để chạy thuật toán chọn trạng thái P
ZZ0001ZZ hoặc ZZ0002ZZ, tùy thuộc vào chính sách ZZ0003ZZ
cài đặt trong ZZ0004ZZ.  Thông tin tần số CPU hiện tại sẽ được thực hiện
có sẵn từ thuộc tính chính sách ZZ0005ZZ trong ZZ0006ZZ là
cũng được cập nhật định kỳ bởi các lệnh gọi lại cập nhật mức sử dụng đó.

ZZ0000ZZ
...............

Không có HWP, thuật toán chọn trạng thái P này luôn giống nhau bất kể
mô hình bộ xử lý và cấu hình nền tảng.

Nó chọn trạng thái P tối đa được phép sử dụng, tuân theo các giới hạn được đặt qua
ZZ0000ZZ, mỗi khi cấu hình trình điều khiển cho CPU nhất định được cập nhật
(ví dụ: qua ZZ0001ZZ).

Đây là thuật toán lựa chọn trạng thái P mặc định nếu
Tùy chọn cấu hình hạt nhân ZZ0000ZZ
được thiết lập.

ZZ0000ZZ
.............

Không có HWP, thuật toán chọn trạng thái P này tương tự như thuật toán
được thực hiện bởi bộ điều chỉnh tỷ lệ ZZ0000ZZ chung ngoại trừ việc
số liệu sử dụng được nó sử dụng dựa trên các con số đến từ phản hồi
thanh ghi của CPU.  Nó thường chọn trạng thái P tỷ lệ thuận với
việc sử dụng CPU hiện tại.

Thuật toán này được điều hành bởi lệnh gọi lại cập nhật mức sử dụng của trình điều khiển cho
được cấp CPU khi nó được gọi bởi bộ lập lịch CPU, nhưng không thường xuyên hơn
cứ sau 10 mili giây.  Giống như trường hợp ZZ0000ZZ, cấu hình phần cứng
không được chạm tới nếu trạng thái P mới giống với trạng thái hiện tại
một.

Đây là thuật toán lựa chọn trạng thái P mặc định nếu
Tùy chọn cấu hình hạt nhân ZZ0000ZZ
không được thiết lập.

.. _passive_mode:

Chế độ thụ động
------------

Đây là chế độ hoạt động mặc định của ZZ0000ZZ dành cho bộ xử lý không có
Hỗ trợ trạng thái P được quản lý bằng phần cứng (HWP).  Nó luôn được sử dụng nếu
Đối số ZZ0001ZZ được truyền tới kernel trong dòng lệnh
bất kể bộ xử lý nhất định có hỗ trợ HWP hay không.  [Lưu ý rằng
Cài đặt ZZ0002ZZ khiến trình điều khiển khởi động ở chế độ thụ động
nếu nó không được kết hợp với ZZ0003ZZ.] Giống như ở chế độ hoạt động
không có hỗ trợ HWP, ở chế độ này ZZ0004ZZ có thể từ chối hoạt động với
bộ xử lý không được nó nhận dạng nếu HWP bị ngăn kích hoạt
thông qua dòng lệnh kernel.

Nếu trình điều khiển hoạt động ở chế độ này, thuộc tính chính sách ZZ0000ZZ trong
ZZ0001ZZ cho tất cả các chính sách ZZ0002ZZ đều chứa chuỗi "intel_cpufreq".
Sau đó, trình điều khiển hoạt động giống như trình điều khiển chia tỷ lệ ZZ0003ZZ thông thường.  Đó là,
nó được viện dẫn bởi các bộ điều chỉnh quy mô chung khi cần thiết để nói chuyện với
phần cứng để thay đổi trạng thái P của CPU (đặc biệt là
Bộ điều chỉnh ZZ0004ZZ có thể gọi nó trực tiếp từ ngữ cảnh của bộ lập lịch).

Khi ở chế độ này, ZZ0000ZZ có thể được sử dụng với tất cả (chung)
bộ điều chỉnh tỷ lệ được liệt kê bởi thuộc tính chính sách ZZ0001ZZ
trong ZZ0002ZZ (và các thuật toán lựa chọn trạng thái P được mô tả ở trên không
đã sử dụng).  Sau đó, nó chịu trách nhiệm cấu hình các đối tượng chính sách
tương ứng với CPU và cung cấp lõi ZZ0003ZZ (và khả năng chia tỷ lệ
thống đốc gắn liền với các đối tượng chính sách) với thông tin chính xác về
tần số hoạt động tối đa và tối thiểu được hỗ trợ bởi phần cứng (bao gồm cả
dải tần số được gọi là "turbo").  Nói cách khác, ở chế độ thụ động
toàn bộ phạm vi trạng thái P có sẵn được ZZ0004ZZ hiển thị cho
Lõi ZZ0005ZZ.  Tuy nhiên, ở chế độ này trình điều khiển không đăng ký
gọi lại cập nhật sử dụng với bộ lập lịch CPU và ZZ0006ZZ
thông tin đến từ lõi ZZ0007ZZ (và là tần số cuối cùng được chọn
bởi bộ điều chỉnh tỷ lệ hiện tại cho chính sách nhất định).


.. _turbo:

Hỗ trợ trạng thái Turbo P
======================

Trong phần lớn các trường hợp, toàn bộ phạm vi trạng thái P có sẵn để
ZZ0000ZZ có thể được chia thành hai phạm vi phụ tương ứng với
các loại hành vi xử lý khác nhau, trên và dưới một ranh giới
sẽ được gọi là "ngưỡng turbo" sau đây.

Trạng thái P trên ngưỡng turbo được gọi là "trạng thái P turbo" và
toàn bộ phạm vi phụ của trạng thái P mà chúng thuộc về được gọi là "turbo
phạm vi".  Những cái tên này có liên quan đến công nghệ Turbo Boost cho phép
bộ xử lý đa lõi để tăng cơ hội trạng thái P của một hoặc nhiều
lõi nếu có đủ sức mạnh để làm điều đó và nếu điều đó không gây ra
vượt quá đường bao nhiệt của gói bộ xử lý.

Cụ thể, nếu phần mềm đặt trạng thái P của lõi CPU trong phạm vi turbo
(nghĩa là trên ngưỡng turbo), bộ xử lý được phép tiếp quản
kiểm soát tỷ lệ hiệu suất cho lõi đó và đưa nó vào trạng thái P turbo của nó
sự lựa chọn sắp tới.  Tuy nhiên, sự cho phép đó được giải thích khác nhau bởi
thế hệ vi xử lý khác nhau.  Cụ thể là thế hệ Sandy Bridge của
bộ xử lý sẽ không bao giờ sử dụng bất kỳ trạng thái P nào cao hơn trạng thái cuối cùng do phần mềm thiết lập cho
lõi nhất định, ngay cả khi nó nằm trong phạm vi turbo, trong khi tất cả các lõi sau
các thế hệ bộ xử lý sẽ coi đó là giấy phép để sử dụng bất kỳ trạng thái P nào từ
phạm vi turbo, thậm chí cao hơn phạm vi được thiết lập bởi phần mềm.  Nói cách khác, trên những
bộ xử lý thiết lập bất kỳ trạng thái P nào từ phạm vi turbo sẽ cho phép bộ xử lý
để đưa lõi đã cho vào tất cả các trạng thái P turbo lên đến và bao gồm cả mức tối đa
được hỗ trợ một khi nó thấy phù hợp.

Một đặc tính quan trọng của trạng thái turbo P là chúng không bền vững.  Thêm
chính xác thì không có gì đảm bảo rằng mọi CPU sẽ có thể ở trong bất kỳ
những trạng thái đó vô thời hạn, bởi vì sự phân bổ điện năng trong bộ xử lý
gói hàng có thể thay đổi theo thời gian hoặc đường bao nhiệt được thiết kế để có thể
bị vượt quá nếu trạng thái turbo P được sử dụng quá lâu.

Đổi lại, trạng thái P dưới ngưỡng turbo nhìn chung là bền vững.  trong
Trên thực tế, nếu một trong số chúng được thiết lập bằng phần mềm thì bộ xử lý sẽ không thay đổi.
nó xuống mức thấp hơn trừ khi bị căng thẳng về nhiệt hoặc vi phạm giới hạn công suất
tình huống (trạng thái P cao hơn vẫn có thể được sử dụng nếu nó được đặt cho CPU khác trong
cùng một gói vào cùng một thời điểm chẳng hạn).

Một số bộ xử lý cho phép nhiều lõi ở trạng thái P-turbo cùng một lúc,
nhưng trạng thái P tối đa có thể được đặt cho chúng thường phụ thuộc vào số lượng
số lõi chạy đồng thời.  Trạng thái P turbo tối đa có thể được đặt trong 3
lõi cùng lúc thường thấp hơn trạng thái P tối đa tương tự đối với
2 lõi, do đó thường thấp hơn trạng thái P turbo tối đa có thể
được đặt cho 1 lõi.  Do đó, trạng thái P turbo tối đa một lõi là mức tối đa
được hỗ trợ một tổng thể.

Trạng thái P turbo được hỗ trợ tối đa, ngưỡng turbo (mức tăng áp được hỗ trợ tối đa
trạng thái P không tăng áp) và trạng thái P được hỗ trợ tối thiểu dành riêng cho
mô hình bộ xử lý và có thể được xác định bằng cách đọc mô hình cụ thể của bộ xử lý
các thanh ghi (MSR).  Hơn nữa, một số bộ xử lý hỗ trợ TDP có thể định cấu hình
(Công suất thiết kế nhiệt) và khi tính năng đó được bật, turbo
ngưỡng thực sự trở thành một giá trị có thể định cấu hình được thiết lập bởi
phần mềm nền tảng.

Không giống như các đối tượng ZZ0001ZZ trong các bảng ACPI, ZZ0002ZZ luôn hiển thị
toàn bộ phạm vi trạng thái P có sẵn, bao gồm toàn bộ phạm vi turbo, cho đến
Lõi ZZ0003ZZ và (ở chế độ thụ động) cho đến các bộ điều chỉnh tỷ lệ chung.  Cái này
thường khiến trạng thái turbo P được thiết lập thường xuyên hơn khi ZZ0004ZZ được
được sử dụng liên quan đến tỷ lệ hiệu suất CPU dựa trên ACPI (xem
ZZ0000ZZ để biết thêm thông tin).

Hơn nữa, vì ZZ0001ZZ luôn biết ngưỡng turbo thực sự là gì
(ngay cả khi tính năng TDP có thể định cấu hình được bật trong bộ xử lý), nó
Thuộc tính ZZ0002ZZ trong ZZ0003ZZ (được mô tả là ZZ0000ZZ) sẽ
hoạt động như mong đợi trong mọi trường hợp (nghĩa là, nếu được đặt thành tắt trạng thái turbo P, nó
luôn phải ngăn ZZ0004ZZ sử dụng chúng).


Hỗ trợ bộ xử lý
=================

Để xử lý một bộ xử lý nhất định ZZ0000ZZ yêu cầu một số khác nhau
mẩu thông tin về nó được biết đến, bao gồm:

* Trạng thái P được hỗ trợ tối thiểu.

* ZZ0000ZZ được hỗ trợ tối đa.

* Trạng thái P turbo có được hỗ trợ hay không.

* ZZ0000ZZ được hỗ trợ tối đa (nếu turbo
   Trạng thái P được hỗ trợ).

* Công thức chia tỷ lệ để dịch biểu diễn bên trong của trình điều khiển
   của trạng thái P thành tần số và ngược lại.

Nói chung, các cách để có được thông tin đó là dành riêng cho kiểu bộ xử lý
hoặc gia đình.  Mặc dù thường có thể lấy được tất cả thông tin đó từ bộ xử lý
chính nó (sử dụng các thanh ghi dành riêng cho từng model), có những trường hợp phần cứng
sách hướng dẫn cũng cần phải được tư vấn để có được nó.

Vì lý do này, có một danh sách các bộ xử lý được hỗ trợ trong ZZ0000ZZ và
quá trình khởi tạo trình điều khiển sẽ thất bại nếu bộ xử lý được phát hiện không nằm trong đó
danh sách, trừ khi nó hỗ trợ tính năng HWP.  [Giao diện để có được tất cả các
thông tin được liệt kê ở trên là giống nhau đối với tất cả các bộ xử lý hỗ trợ
Tính năng HWP, đó là lý do tại sao ZZ0001ZZ hoạt động với tất cả chúng.]


Hỗ trợ cho bộ xử lý lai
=============================

Một số bộ xử lý được ZZ0000ZZ hỗ trợ chứa hai hoặc nhiều loại CPU
các lõi khác nhau ở trạng thái P turbo tối đa, hiệu suất và đặc tính công suất,
kích thước bộ đệm và có thể các thuộc tính khác.  Họ thường được gọi là
bộ xử lý lai.  Để hỗ trợ chúng, ZZ0001ZZ yêu cầu kích hoạt HWP
và nó giả định các đơn vị hiệu năng HWP là giống nhau cho tất cả các CPU trong
hệ thống, do đó, mức hiệu suất HWP nhất định luôn đại diện cho khoảng
hiệu suất vật lý như nhau bất kể loại lõi (CPU).

Bộ xử lý lai với SMT
--------------------------

Trên các hệ thống có SMT (Đa luồng đồng thời), còn được gọi là
Siêu phân luồng (HT) trong bối cảnh bộ xử lý Intel, được bật trên ít nhất
một lõi, ZZ0000ZZ chỉ định mức độ ưu tiên dựa trên hiệu suất cho CPU.  Cụ thể là,
mức độ ưu tiên của CPU nhất định phản ánh mức hiệu suất HWP cao nhất của nó
khiến bộ lập lịch CPU thường thích CPU có hiệu năng cao hơn, do đó càng ít
CPU có hiệu suất cao được sử dụng khi các CPU khác được tải đầy đủ.  Tuy nhiên, SMT
anh chị em (nghĩa là các CPU logic chia sẻ một lõi vật lý) được xử lý theo cách
cách đặc biệt sao cho nếu một trong số chúng được sử dụng thì mức độ ưu tiên hiệu quả của
những cái khác được hạ xuống dưới mức độ ưu tiên của các CPU nằm ở vị trí khác
lõi vật lý.

Cách tiếp cận này tối đa hóa hiệu suất trong phần lớn các trường hợp, nhưng thật không may
nó cũng dẫn đến việc sử dụng năng lượng quá mức trong một số trường hợp quan trọng, như video
phát lại, điều này thường không được mong muốn.  Trong khi không có khả năng nào khác
lựa chọn với SMT được kích hoạt vì công suất và mức sử dụng hiệu quả của SMT
khó xác định anh chị em, bộ xử lý lai không có SMT có thể được xử lý trong
những cách tiết kiệm năng lượng hơn.

.. _CAS:

Hỗ trợ lập kế hoạch nhận biết năng lực
---------------------------------

Hỗ trợ lập lịch nhận biết năng lực (CAS) trong bộ lập lịch CPU được bật bởi
ZZ0000ZZ theo mặc định trên bộ xử lý lai không có SMT.  CAS nói chung
khiến bộ lập lịch đặt các tác vụ lên CPU miễn là có đủ
lượng công suất dự phòng của nó và nếu việc sử dụng một nhiệm vụ nhất định quá
cao cho nó, nhiệm vụ sẽ cần phải đi nơi khác.

Vì CAS tính đến dung lượng của CPU nên nó không yêu cầu CPU
ưu tiên và nó cho phép các nhiệm vụ được phân bổ đối xứng hơn giữa
CPU hiệu suất cao hơn và CPU kém hiệu suất hơn.  Sau khi được đặt trên CPU có đủ
khả năng đáp ứng nó, một tác vụ có thể tiếp tục chạy ở đó bất kể
liệu các CPU khác có được tải đầy đủ hay không, do đó, trung bình CAS sẽ giảm
việc sử dụng các CPU có hiệu suất cao hơn khiến việc sử dụng năng lượng nhiều hơn
cân bằng vì CPU có hiệu suất cao hơn thường ít tiết kiệm năng lượng hơn
hơn những người kém hiệu quả hơn.

Để sử dụng CAS, bộ lập lịch cần biết dung lượng của từng CPU trong
hệ thống và nó cần có khả năng tính toán việc sử dụng bất biến quy mô của
CPU, vì vậy ZZ0000ZZ cung cấp cho nó thông tin cần thiết.

Trước hết, dung lượng của mỗi CPU được biểu thị bằng tỷ lệ dung lượng cao nhất của nó
Mức hiệu suất HWP, nhân với 1024, đạt mức hiệu suất HWP cao nhất
trong số CPU có hiệu suất cao nhất trong hệ thống, hoạt động nhờ hiệu suất của HWP
các đơn vị đều giống nhau cho tất cả các CPU.  Thứ hai, tính toán bất biến tần số,
được thực hiện bởi bộ lập lịch để luôn thể hiện việc sử dụng CPU trong cùng một đơn vị
bất kể tần số hiện tại nó đang chạy, đều được điều chỉnh để lấy
Tính đến dung lượng CPU.  Tất cả điều này xảy ra khi ZZ0000ZZ có
đã tự đăng ký với lõi ZZ0001ZZ và nó đã phát hiện ra rằng đó là
chạy trên bộ xử lý lai không có SMT.

Hỗ trợ lập kế hoạch nhận biết năng lượng
-------------------------------

Nếu ZZ0002ZZ đã được đặt trong quá trình cấu hình kernel và
ZZ0003ZZ chạy trên bộ xử lý lai không có SMT, ngoài việc cho phép
ZZ0000ZZ nó đăng ký Mô hình năng lượng cho bộ xử lý.  Điều này cho phép
Hỗ trợ Lập kế hoạch nhận biết năng lượng (EAS) sẽ được bật trong bộ lập lịch CPU nếu
ZZ0004ZZ được sử dụng làm bộ điều chỉnh ZZ0005ZZ cần có ZZ0006ZZ
để hoạt động trong ZZ0001ZZ.

Mô hình năng lượng được ZZ0000ZZ đăng ký là nhân tạo (nghĩa là nó
dựa trên các giá trị chi phí trừu tượng và nó không bao gồm bất kỳ số lũy thừa thực nào)
và việc tránh những tính toán không cần thiết trong bộ lập lịch là tương đối đơn giản.
Có một miền hiệu suất cho mỗi CPU trong hệ thống và chi phí
các giá trị cho các miền hiệu suất này đã được chọn để chạy một tác vụ trên
một chiếc CPU hoạt động kém hơn (nhỏ) dường như luôn rẻ hơn so với việc chạy chiếc đó
nhiệm vụ trên CPU (lớn) hiệu suất cao hơn.  Tuy nhiên, đối với hai CPU cùng loại,
sự khác biệt về chi phí phụ thuộc vào mức sử dụng hiện tại của chúng và CPU có
mức sử dụng hiện tại cao hơn thường có vẻ đắt hơn
đích cho một nhiệm vụ nhất định.  Điều này giúp cân bằng tải giữa các CPU của
cùng loại.

Vì EAS hoạt động dựa trên CAS nên các tác vụ có mức sử dụng cao luôn được di chuyển sang
CPU có đủ dung lượng để chứa chúng, nhưng nhờ EAS, hiệu suất sử dụng thấp
các tác vụ có xu hướng được đặt trên các CPU trông ít tốn kém hơn đối với bộ lập lịch.
Thực tế, điều này khiến cho các CPU hoạt động kém hơn và tải ít hơn
được ưu tiên miễn là họ có đủ năng lực dự phòng để thực hiện nhiệm vụ được giao
thường dẫn đến giảm mức sử dụng năng lượng.

Có thể kiểm tra Mô hình Năng lượng do ZZ0000ZZ tạo bằng cách xem
thư mục ZZ0001ZZ trong ZZ0002ZZ (thường được gắn trên
ZZ0003ZZ).


Giao diện không gian người dùng trong ZZ0000ZZ
=================================

.. _global_attributes:

Thuộc tính chung
-----------------

ZZ0000ZZ hiển thị một số thuộc tính (tệp) toàn cầu trong ZZ0001ZZ cho
kiểm soát chức năng của nó ở cấp độ hệ thống.  Chúng nằm ở
Thư mục ZZ0002ZZ và ảnh hưởng đến tất cả các CPU.

Một số trong số chúng không có mặt nếu ZZ0000ZZ
đối số được truyền tới kernel trong dòng lệnh.

ZZ0001ZZ
	Trạng thái P tối đa mà trình điều khiển được phép đặt theo phần trăm của
	mức hiệu suất được hỗ trợ tối đa (ZZ0000ZZ được hỗ trợ cao nhất).

Thuộc tính này sẽ không được hiển thị nếu
	Đối số ZZ0000ZZ có trong kernel
	dòng lệnh.

ZZ0001ZZ
	Trạng thái P tối thiểu mà trình điều khiển được phép đặt theo phần trăm của
	mức hiệu suất được hỗ trợ tối đa (ZZ0000ZZ được hỗ trợ cao nhất).

Thuộc tính này sẽ không được hiển thị nếu
	Đối số ZZ0000ZZ có trong kernel
	dòng lệnh.

ZZ0001ZZ
	Số trạng thái P được bộ xử lý hỗ trợ (từ 0 đến 255
	bao gồm) bao gồm cả trạng thái P tăng áp và không tăng áp (xem
	ZZ0000ZZ).

Thuộc tính này chỉ xuất hiện nếu giá trị được hiển thị bởi nó giống nhau
	cho tất cả các CPU trong hệ thống.

Giá trị của thuộc tính này không bị ảnh hưởng bởi ZZ0001ZZ
	cài đặt được mô tả ZZ0000ZZ.

Thuộc tính này là chỉ đọc.

ZZ0001ZZ
	Tỷ lệ kích thước ZZ0000ZZ so với kích thước của toàn bộ
	phạm vi trạng thái P được hỗ trợ, tính bằng phần trăm.

Thuộc tính này chỉ xuất hiện nếu giá trị được hiển thị bởi nó giống nhau
	cho tất cả các CPU trong hệ thống.

Thuộc tính này là chỉ đọc.

.. _no_turbo_attr:

ZZ0001ZZ
	Nếu được đặt (bằng 1), người lái xe không được phép đặt bất kỳ trạng thái P turbo nào
	(xem ZZ0000ZZ).  Nếu không được đặt (bằng 0, là
	mặc định), trình điều khiển có thể cài đặt trạng thái P turbo.
	[Lưu ý rằng ZZ0002ZZ không hỗ trợ ZZ0003ZZ chung
	thuộc tính (được hỗ trợ bởi một số trình điều khiển chia tỷ lệ khác) được thay thế
	bằng cái này.]

Thuộc tính này không ảnh hưởng đến giá trị tần số được hỗ trợ tối đa
	được cung cấp cho lõi ZZ0001ZZ và được hiển thị thông qua giao diện chính sách,
	nhưng nó ảnh hưởng đến giá trị tối đa có thể có của giới hạn trạng thái P cho mỗi chính sách
	(xem ZZ0000ZZ bên dưới để biết chi tiết).

ZZ0001ZZ
	Thuộc tính này chỉ xuất hiện nếu ZZ0002ZZ hoạt động trong
	ZZ0000ZZ trong
	bộ xử lý.  Nếu được đặt (bằng 1), nó gây ra giới hạn trạng thái P tối thiểu
	được tăng động trong một thời gian ngắn bất cứ khi nào một nhiệm vụ trước đó
	chờ I/O được chọn để chạy trên CPU logic nhất định (mục đích
	của cơ chế này là để cải thiện hiệu suất).

	This setting has no effect on logical CPUs whose minimum P-state limit
	is directly set to the highest non-turbo P-state or above it.

.. _status_attr:

ZZ0000ZZ
	Chế độ hoạt động của trình điều khiển: "hoạt động", "thụ động" hoặc "tắt".

"hoạt động"
		Trình điều khiển có chức năng trong ZZ0000ZZ.

	"passive"
		The driver is functional and in the :ref:`passive mode
		<passive_mode>`.

	"off"
		The driver is not functional (it is not registered as a scaling
		driver with the ``CPUFreq`` core).

	This attribute can be written to in order to change the driver's
	operation mode or to unregister it.  The string written to it must be
	one of the possible values of it and, if successful, the write will
	cause the driver to switch over to the operation mode represented by
	that string - or to be unregistered in the "off" case.  [Actually,
	switching over from the active mode to the passive mode or the other
	way around causes the driver to be unregistered and registered again
	with a different set of callbacks, so all of its settings (the global
	as well as the per-policy ones) are then reset to their default
	values, possibly depending on the target operation mode.]

``energy_efficiency``
	This attribute is only present on platforms with CPUs matching the Kaby
	Lake or Coffee Lake desktop CPU model. By default, energy-efficiency
	optimizations are disabled on these CPU models if HWP is enabled.
	Enabling energy-efficiency optimizations may limit maximum operating
	frequency with or without the HWP feature.  With HWP enabled, the
	optimizations are done only in the turbo frequency range.  Without it,
	they are done in the entire available frequency range.  Setting this
	attribute to "1" enables the energy-efficiency optimizations and setting
	to "0" disables them.

.. _policy_attributes_interpretation:

Interpretation of Policy Attributes
-----------------------------------

The interpretation of some ``CPUFreq`` policy attributes described in
Documentation/admin-guide/pm/cpufreq.rst is special with ``intel_pstate``
as the current scaling driver and it generally depends on the driver's
:ref:`operation mode <operation_modes>`.

First of all, the values of the ``cpuinfo_max_freq``, ``cpuinfo_min_freq`` and
``scaling_cur_freq`` attributes are produced by applying a processor-specific
multiplier to the internal P-state representation used by ``intel_pstate``.
Also, the values of the ``scaling_max_freq`` and ``scaling_min_freq``
attributes are capped by the frequency corresponding to the maximum P-state that
the driver is allowed to set.

If the ``no_turbo`` :ref:`global attribute <no_turbo_attr>` is set, the driver
is not allowed to use turbo P-states, so the maximum value of
``scaling_max_freq`` and ``scaling_min_freq`` is limited to the maximum
non-turbo P-state frequency.
Accordingly, setting ``no_turbo`` causes ``scaling_max_freq`` and
``scaling_min_freq`` to go down to that value if they were above it before.
However, the old values of ``scaling_max_freq`` and ``scaling_min_freq`` will be
restored after unsetting ``no_turbo``, unless these attributes have been written
to after ``no_turbo`` was set.

If ``no_turbo`` is not set, the maximum possible value of ``scaling_max_freq``
and ``scaling_min_freq`` corresponds to the maximum supported turbo P-state,
which also is the value of ``cpuinfo_max_freq`` in either case.

Next, the following policy attributes have special meaning if
``intel_pstate`` works in the :ref:`active mode <active_mode>`:

``scaling_available_governors``
	List of P-state selection algorithms provided by ``intel_pstate``.

``scaling_governor``
	P-state selection algorithm provided by ``intel_pstate`` currently in
	use with the given policy.

``scaling_cur_freq``
	Frequency of the average P-state of the CPU represented by the given
	policy for the time interval between the last two invocations of the
	driver's utilization update callback by the CPU scheduler for that CPU.

One more policy attribute is present if the HWP feature is enabled in the
processor:

``base_frequency``
	Shows the base frequency of the CPU. Any frequency above this will be
	in the turbo frequency range.

The meaning of these attributes in the :ref:`passive mode <passive_mode>` is the
same as for other scaling drivers.

Additionally, the value of the ``scaling_driver`` attribute for ``intel_pstate``
depends on the operation mode of the driver.  Namely, it is either
"intel_pstate" (in the :ref:`active mode <active_mode>`) or "intel_cpufreq"
(in the :ref:`passive mode <passive_mode>`).

.. _pstate_limits_coordination:

Coordination of P-State Limits
------------------------------

``intel_pstate`` allows P-state limits to be set in two ways: with the help of
the ``max_perf_pct`` and ``min_perf_pct`` :ref:`global attributes
<global_attributes>` or via the ``scaling_max_freq`` and ``scaling_min_freq``
``CPUFreq`` policy attributes.  The coordination between those limits is based
on the following rules, regardless of the current operation mode of the driver:

 1. All CPUs are affected by the global limits (that is, none of them can be
    requested to run faster than the global maximum and none of them can be
    requested to run slower than the global minimum).

 2. Each individual CPU is affected by its own per-policy limits (that is, it
    cannot be requested to run faster than its own per-policy maximum and it
    cannot be requested to run slower than its own per-policy minimum). The
    effective performance depends on whether the platform supports per core
    P-states, hyper-threading is enabled and on current performance requests
    from other CPUs. When platform doesn't support per core P-states, the
    effective performance can be more than the policy limits set on a CPU, if
    other CPUs are requesting higher performance at that moment. Even with per
    core P-states support, when hyper-threading is enabled, if the sibling CPU
    is requesting higher performance, the other siblings will get higher
    performance than their policy limits.

 3. The global and per-policy limits can be set independently.

In the :ref:`active mode with the HWP feature enabled <active_mode_hwp>`, the
resulting effective values are written into hardware registers whenever the
limits change in order to request its internal P-state selection logic to always
set P-states within these limits.  Otherwise, the limits are taken into account
by scaling governors (in the :ref:`passive mode <passive_mode>`) and by the
driver every time before setting a new P-state for a CPU.

Additionally, if the ``intel_pstate=per_cpu_perf_limits`` command line argument
is passed to the kernel, ``max_perf_pct`` and ``min_perf_pct`` are not exposed
at all and the only way to set the limits is by using the policy attributes.

.. _energy_performance_hints:

Energy vs Performance Hints
---------------------------

If the hardware-managed P-states (HWP) is enabled in the processor, additional
attributes, intended to allow user space to help ``intel_pstate`` to adjust the
processor's internal P-state selection logic by focusing it on performance or on
energy-efficiency, or somewhere between the two extremes, are present in every
``CPUFreq`` policy directory in ``sysfs``.  They are :

``energy_performance_preference``
	Current value of the energy vs performance hint for the given policy
	(or the CPU represented by it).

	The hint can be changed by writing to this attribute.

``energy_performance_available_preferences``
	List of strings that can be written to the
	``energy_performance_preference`` attribute.

	They represent different energy vs performance hints and should be
	self-explanatory, except that ``default`` represents whatever hint
	value was set by the platform firmware.

Strings written to the ``energy_performance_preference`` attribute are
internally translated to integer values written to the processor's
Energy-Performance Preference (EPP) knob (if supported) or its
Energy-Performance Bias (EPB) knob. It is also possible to write a positive
integer value between 0 to 255, if the EPP feature is present. If the EPP
feature is not present, writing integer value to this attribute is not
supported. In this case, user can use the
"/sys/devices/system/cpu/cpu*/power/energy_perf_bias" interface.

[Note that tasks may by migrated from one CPU to another by the scheduler's
load-balancing algorithm and if different energy vs performance hints are
set for those CPUs, that may lead to undesirable outcomes.  To avoid such
issues it is better to set the same energy vs performance hint for all CPUs
or to pin every task potentially sensitive to them to a specific CPU.]

.. _acpi-cpufreq:

``intel_pstate`` vs ``acpi-cpufreq``
====================================

On the majority of systems supported by ``intel_pstate``, the ACPI tables
provided by the platform firmware contain ``_PSS`` objects returning information
that can be used for CPU performance scaling (refer to the ACPI specification
[3]_ for details on the ``_PSS`` objects and the format of the information
returned by them).

The information returned by the ACPI ``_PSS`` objects is used by the
``acpi-cpufreq`` scaling driver.  On systems supported by ``intel_pstate``
the ``acpi-cpufreq`` driver uses the same hardware CPU performance scaling
interface, but the set of P-states it can use is limited by the ``_PSS``
output.

On those systems each ``_PSS`` object returns a list of P-states supported by
the corresponding CPU which basically is a subset of the P-states range that can
be used by ``intel_pstate`` on the same system, with one exception: the whole
:ref:`turbo range <turbo>` is represented by one item in it (the topmost one).
By convention, the frequency returned by ``_PSS`` for that item is greater by
1 MHz than the frequency of the highest non-turbo P-state listed by it, but the
corresponding P-state representation (following the hardware specification)
returned for it matches the maximum supported turbo P-state (or is the
special value 255 meaning essentially "go as high as you can get").

The list of P-states returned by ``_PSS`` is reflected by the table of
available frequencies supplied by ``acpi-cpufreq`` to the ``CPUFreq`` core and
scaling governors and the minimum and maximum supported frequencies reported by
it come from that list as well.  In particular, given the special representation
of the turbo range described above, this means that the maximum supported
frequency reported by ``acpi-cpufreq`` is higher by 1 MHz than the frequency
of the highest supported non-turbo P-state listed by ``_PSS`` which, of course,
affects decisions made by the scaling governors, except for ``powersave`` and
``performance``.

For example, if a given governor attempts to select a frequency proportional to
estimated CPU load and maps the load of 100% to the maximum supported frequency
(possibly multiplied by a constant), then it will tend to choose P-states below
the turbo threshold if ``acpi-cpufreq`` is used as the scaling driver, because
in that case the turbo range corresponds to a small fraction of the frequency
band it can use (1 MHz vs 1 GHz or more).  In consequence, it will only go to
the turbo range for the highest loads and the other loads above 50% that might
benefit from running at turbo frequencies will be given non-turbo P-states
instead.

One more issue related to that may appear on systems supporting the
:ref:`Configurable TDP feature <turbo>` allowing the platform firmware to set
the turbo threshold.  Namely, if that is not coordinated with the lists of
P-states returned by ``_PSS`` properly, there may be more than one item
corresponding to a turbo P-state in those lists and there may be a problem with
avoiding the turbo range (if desirable or necessary).  Usually, to avoid using
turbo P-states overall, ``acpi-cpufreq`` simply avoids using the topmost state
listed by ``_PSS``, but that is not sufficient when there are other turbo
P-states in the list returned by it.

Apart from the above, ``acpi-cpufreq`` works like ``intel_pstate`` in the
:ref:`passive mode <passive_mode>`, except that the number of P-states it can
set is limited to the ones listed by the ACPI ``_PSS`` objects.


Kernel Command Line Options for ``intel_pstate``
================================================

Several kernel command line options can be used to pass early-configuration-time
parameters to ``intel_pstate`` in order to enforce specific behavior of it.  All
of them have to be prepended with the ``intel_pstate=`` prefix.

``disable``
	Do not register ``intel_pstate`` as the scaling driver even if the
	processor is supported by it.

``active``
	Register ``intel_pstate`` in the :ref:`active mode <active_mode>` to
        start with.

``passive``
	Register ``intel_pstate`` in the :ref:`passive mode <passive_mode>` to
	start with.

``force``
	Register ``intel_pstate`` as the scaling driver instead of
	``acpi-cpufreq`` even if the latter is preferred on the given system.

	This may prevent some platform features (such as thermal controls and
	power capping) that rely on the availability of ACPI P-states
	information from functioning as expected, so it should be used with
	caution.

	This option does not work with processors that are not supported by
	``intel_pstate`` and on platforms where the ``pcc-cpufreq`` scaling
	driver is used instead of ``acpi-cpufreq``.

``no_hwp``
	Do not enable the hardware-managed P-states (HWP) feature even if it is
	supported by the processor.

``hwp_only``
	Register ``intel_pstate`` as the scaling driver only if the
	hardware-managed P-states (HWP) feature is supported by the processor.

``support_acpi_ppc``
	Take ACPI ``_PPC`` performance limits into account.

	If the preferred power management profile in the FADT (Fixed ACPI
	Description Table) is set to "Enterprise Server" or "Performance
	Server", the ACPI ``_PPC`` limits are taken into account by default
	and this option has no effect.

``per_cpu_perf_limits``
	Use per-logical-CPU P-State limits (see
        :ref:`pstate_limits_coordination` for details).

``no_cas``
	Do not enable :ref:`capacity-aware scheduling <CAS>` which is enabled
        by default on hybrid systems without SMT.

Diagnostics and Tuning
======================

Trace Events
------------

There are two static trace events that can be used for ``intel_pstate``
diagnostics.  One of them is the ``cpu_frequency`` trace event generally used
by ``CPUFreq``, and the other one is the ``pstate_sample`` trace event specific
to ``intel_pstate``.  Both of them are triggered by ``intel_pstate`` only if
it works in the :ref:`active mode <active_mode>`.

The following sequence of shell commands can be used to enable them and see
their output (if the kernel is generally configured to support event tracing)::

 # cd /sys/kernel/tracing/
 # echo 1 > events/power/pstate_sample/enable
 # echo 1 > events/power/cpu_frequency/enable
 # cat trace
 gnome-terminal--4510  [001] ..s.  1177.680733: pstate_sample: core_busy=107 scaled=94 from=26 to=26 mperf=1143818 aperf=1230607 tsc=29838618 freq=2474476
 cat-5235  [002] ..s.  1177.681723: cpu_frequency: state=2900000 cpu_id=2

If ``intel_pstate`` works in the :ref:`passive mode <passive_mode>`, the
``cpu_frequency`` trace event will be triggered either by the ``schedutil``
scaling governor (for the policies it is attached to), or by the ``CPUFreq``
core (for the policies with other scaling governors).

``ftrace``
----------

The ``ftrace`` interface can be used for low-level diagnostics of
``intel_pstate``.  For example, to check how often the function to set a
P-state is called, the ``ftrace`` filter can be set to
:c:func:`intel_pstate_set_pstate`::

 # cd /sys/kernel/tracing/
 # cat available_filter_functions | grep -i pstate
 intel_pstate_set_pstate
 intel_pstate_cpu_init
 ...
 # echo intel_pstate_set_pstate > set_ftrace_filter
 # echo function > current_tracer
 # cat trace | head -15
 # tracer: function
 #
 # entries-in-buffer/entries-written: 80/80   #P:4
 #
 #                              _-----=> irqs-off
 #                             / _----=> need-resched
 #                            | / _---=> hardirq/softirq
 #                            || / _--=> preempt-depth
 #                            ||| /     delay
 #           TASK-PID   CPU#  ||||    TIMESTAMP  FUNCTION
 #              | |       |   ||||       |         |
             Xorg-3129  [000] ..s.  2537.644844: intel_pstate_set_pstate <-intel_pstate_timer_func
  gnome-terminal--4510  [002] ..s.  2537.649844: intel_pstate_set_pstate <-intel_pstate_timer_func
      gnome-shell-3409  [001] ..s.  2537.650850: intel_pstate_set_pstate <-intel_pstate_timer_func
           <idle>-0     [000] ..s.  2537.654843: intel_pstate_set_pstate <-intel_pstate_timer_func


References
==========

.. [1] Kristen Accardi, *Balancing Power and Performance in the Linux Kernel*,
       https://events.static.linuxfound.org/sites/events/files/slides/LinuxConEurope_2015.pdf

.. [2] *Intel® 64 and IA-32 Architectures Software Developer’s Manual Volume 3: System Programming Guide*,
       https://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-system-programming-manual-325384.html

.. [3] *Advanced Configuration and Power Interface Specification*,
       https://uefi.org/sites/default/files/resources/ACPI_6_3_final_Jan30.pdf