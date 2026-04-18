.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/livepatch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
Livepatch
=========

Tài liệu này phác thảo thông tin cơ bản về livepatching kernel.

.. Table of Contents:

.. contents:: :local:


1. Động lực
=============

Có nhiều tình huống mà người dùng không muốn khởi động lại hệ thống. Nó có thể
là do hệ thống của họ đang thực hiện các tính toán khoa học phức tạp hoặc đang
tải nặng trong thời gian sử dụng cao điểm. Ngoài việc duy trì hoạt động của hệ thống,
người dùng cũng muốn có một hệ thống ổn định và an toàn. Livepatching mang đến cho người dùng
cả hai bằng cách cho phép chuyển hướng các lệnh gọi hàm; do đó, sửa chữa quan trọng
hoạt động mà không cần khởi động lại hệ thống.


2. Kprobes, Ftrace, Livepatching
================================

Có nhiều cơ chế trong nhân Linux có liên quan trực tiếp
để chuyển hướng thực thi mã; cụ thể là: thăm dò hạt nhân, theo dõi hàm,
và bản vá trực tiếp:

- Các thăm dò hạt nhân là chung nhất. Mã có thể được chuyển hướng bởi
    đặt một hướng dẫn điểm dừng thay vì bất kỳ hướng dẫn nào.

- Trình theo dõi hàm gọi mã từ một vị trí được xác định trước
    gần điểm vào chức năng. Vị trí này được tạo ra bởi
    trình biên dịch bằng cách sử dụng tùy chọn gcc '-pg'.

- Livepatching thường cần chuyển hướng mã ngay từ đầu
    của mục nhập hàm trước các tham số hàm hoặc ngăn xếp
    đang được sửa đổi theo bất kỳ cách nào.

Cả ba cách tiếp cận đều cần sửa đổi mã hiện có khi chạy. Vì thế
họ cần phải nhận thức được nhau và không dẫm chân lên nhau.
Hầu hết các vấn đề này được giải quyết bằng cách sử dụng khung công tác ftrace động như
một cơ sở. Kprobe được đăng ký làm trình xử lý ftrace khi mục nhập hàm
được thăm dò, xem CONFIG_KPROBES_ON_FTRACE. Cũng là một chức năng thay thế từ
một bản vá trực tiếp được gọi với sự trợ giúp của trình xử lý ftrace tùy chỉnh. Nhưng có
một số hạn chế, xem bên dưới.


3. Mô hình nhất quán
====================

Chức năng tồn tại là có lý do. Họ lấy một số tham số đầu vào, thu thập hoặc
giải phóng các khóa, đọc, xử lý và thậm chí ghi một số dữ liệu theo cách xác định,
có giá trị trả về. Nói cách khác, mỗi hàm có một ngữ nghĩa xác định.

Nhiều bản sửa lỗi không thay đổi ngữ nghĩa của các hàm đã sửa đổi. cho
ví dụ: họ thêm con trỏ NULL hoặc kiểm tra ranh giới, khắc phục cuộc đua bằng cách thêm
thiếu rào cản bộ nhớ hoặc thêm một số khóa xung quanh phần quan trọng.
Hầu hết những thay đổi này đều khép kín và chức năng tự thể hiện
theo cách tương tự với phần còn lại của hệ thống. Trong trường hợp này, các chức năng có thể
được cập nhật độc lập từng cái một.

Nhưng có nhiều cách sửa chữa phức tạp hơn. Ví dụ: một bản vá có thể thay đổi
thứ tự khóa nhiều chức năng cùng một lúc. Hoặc một bản vá
có thể trao đổi ý nghĩa của một số cấu trúc tạm thời và cập nhật
tất cả các chức năng liên quan. Trong trường hợp này, đơn vị bị ảnh hưởng
(luồng, toàn bộ kernel) cần bắt đầu sử dụng tất cả các phiên bản mới của
các chức năng cùng một lúc. Ngoài ra việc chuyển đổi chỉ phải xảy ra
khi thấy an toàn để làm như vậy, ví dụ: khi các ổ khóa bị ảnh hưởng được giải phóng
hoặc hiện tại không có dữ liệu nào được lưu trữ trong cấu trúc đã sửa đổi.

Lý thuyết về cách áp dụng các chức năng một cách an toàn khá phức tạp.
Mục đích là để xác định cái gọi là mô hình nhất quán. Nó cố gắng xác định
điều kiện khi triển khai mới có thể được sử dụng để hệ thống
vẫn nhất quán.

Livepatch có một mô hình nhất quán là sự kết hợp giữa kGraft và
kpatch: nó sử dụng rào cản tòa nhà và tính nhất quán theo từng nhiệm vụ của kGraft
chuyển đổi kết hợp với chuyển đổi theo dõi ngăn xếp của kpatch.  Ngoài ra còn có
một số tùy chọn dự phòng làm cho nó khá linh hoạt.

Các bản vá được áp dụng trên cơ sở từng nhiệm vụ khi nhiệm vụ đó được coi là an toàn đối với
chuyển qua.  Khi một bản vá được bật, livepatch sẽ chuyển sang
trạng thái chuyển tiếp trong đó các tác vụ đang hội tụ sang trạng thái được vá.
Thông thường trạng thái chuyển tiếp này có thể hoàn thành sau vài giây.  giống nhau
trình tự xảy ra khi một bản vá bị vô hiệu hóa, ngoại trừ các tác vụ hội tụ từ
trạng thái được vá sang trạng thái chưa được vá.

Trình xử lý ngắt kế thừa trạng thái đã được vá của tác vụ mà nó
ngắt quãng.  Điều này cũng đúng đối với các nhiệm vụ được phân nhánh: đứa trẻ kế thừa
trạng thái vá của cha mẹ.

Livepatch sử dụng một số phương pháp bổ sung để xác định khi nào nó
an toàn để vá các tác vụ:

1. Cách tiếp cận đầu tiên và hiệu quả nhất là kiểm tra ngăn ngủ
   nhiệm vụ.  Nếu không có chức năng nào bị ảnh hưởng trong ngăn xếp của một tác vụ nhất định,
   nhiệm vụ đã được vá.  Trong hầu hết các trường hợp, điều này sẽ vá hầu hết hoặc tất cả
   các nhiệm vụ trong lần thử đầu tiên.  Nếu không nó sẽ tiếp tục cố gắng
   định kỳ.  Tùy chọn này chỉ khả dụng nếu kiến trúc có
   ngăn xếp đáng tin cậy (HAVE_RELIABLE_STACKTRACE).

2. Cách tiếp cận thứ hai, nếu cần, là chuyển đổi thoát kernel.  A
   tác vụ được chuyển khi nó quay trở lại không gian người dùng sau một cuộc gọi hệ thống, một
   không gian người dùng IRQ hoặc tín hiệu.  Nó hữu ích trong các trường hợp sau:

a) Vá các tác vụ của người dùng liên quan đến I/O đang ngủ trên một thiết bị bị ảnh hưởng
      chức năng.  Trong trường hợp này, bạn phải gửi SIGSTOP và SIGCONT tới
      buộc nó thoát khỏi kernel và được vá.
   b) Vá các tác vụ của người dùng gắn liền với CPU.  Nếu tác vụ có giới hạn CPU cao
      sau đó nó sẽ được vá vào lần tiếp theo bị gián đoạn bởi một
      IRQ.

3. Đối với các tác vụ "hoán đổi" nhàn rỗi, vì chúng không bao giờ thoát khỏi kernel nên chúng
   thay vào đó hãy thực hiện lệnh gọi klp_update_patch_state() trong vòng lặp nhàn rỗi
   cho phép chúng được vá trước khi CPU chuyển sang trạng thái không hoạt động.

(Lưu ý rằng chưa có cách tiếp cận như vậy đối với kthreads.)

Các kiến trúc không có HAVE_RELIABLE_STACKTRACE chỉ dựa vào
cách tiếp cận thứ hai. Rất có thể một số nhiệm vụ vẫn có thể được thực hiện
chạy với phiên bản cũ của hàm, cho đến khi hàm đó
trở lại. Trong trường hợp này bạn sẽ phải báo hiệu nhiệm vụ. Cái này
đặc biệt áp dụng cho kthreads. Họ có thể không được đánh thức và sẽ cần
bị ép buộc. Xem bên dưới để biết thêm thông tin.

Trừ khi chúng ta có thể nghĩ ra cách khác để vá kthreads, kiến trúc
không có HAVE_RELIABLE_STACKTRACE không được coi là được hỗ trợ đầy đủ bởi
bản vá trực tiếp kernel.

Tệp /sys/kernel/livepatch/<patch>/transition cho biết liệu một bản vá có
đang trong quá trình chuyển đổi.  Chỉ một bản vá duy nhất có thể được chuyển đổi tại một thời điểm nhất định
thời gian.  Một bản vá có thể vẫn ở trạng thái chuyển tiếp vô thời hạn, nếu bất kỳ tác vụ nào
đang bị mắc kẹt trong trạng thái vá ban đầu.

Một quá trình chuyển đổi có thể được đảo ngược và hủy bỏ một cách hiệu quả bằng cách viết
giá trị ngược lại với tệp /sys/kernel/livepatch/<patch>/enabled trong khi
quá trình chuyển đổi đang được tiến hành.  Sau đó tất cả các nhiệm vụ sẽ cố gắng
hội tụ trở lại trạng thái vá ban đầu.

Ngoài ra còn có tệp /proc/<pid>/patch_state có thể được sử dụng để
xác định tác vụ nào đang cản trở việc hoàn thành thao tác vá lỗi.
Nếu một bản vá đang trong quá trình chuyển đổi, tệp này hiển thị 0 để cho biết tác vụ đang được thực hiện
chưa được vá và 1 để cho biết nó đã được vá.  Mặt khác, nếu không có bản vá nào
chuyển tiếp, nó hiển thị -1.  Bất kỳ tác vụ nào đang chặn quá trình chuyển đổi
có thể được báo hiệu bằng SIGSTOP và SIGCONT để buộc chúng thay đổi
trạng thái được vá. Tuy nhiên, điều này có thể gây hại cho hệ thống. Gửi tín hiệu giả
đối với tất cả các tác vụ chặn còn lại là giải pháp thay thế tốt hơn. Không có tín hiệu thích hợp
thực sự được phân phối (không có dữ liệu trong cấu trúc tín hiệu đang chờ xử lý). Nhiệm vụ là
bị gián đoạn hoặc thức dậy và buộc phải thay đổi trạng thái được vá. Đồ giả
tín hiệu được tự động gửi đi sau mỗi 15 giây.

Quản trị viên cũng có thể ảnh hưởng đến quá trình chuyển đổi thông qua
Thuộc tính /sys/kernel/livepatch/<patch>/force. Viết 1 ở đó xóa
Cờ TIF_PATCH_PENDING của tất cả các tác vụ và do đó buộc các tác vụ phải được vá
trạng thái. Lưu ý quan trọng! Thuộc tính lực được dành cho các trường hợp khi
quá trình chuyển đổi bị kẹt trong một thời gian dài do tác vụ chặn. Quản trị viên
dự kiến ​​sẽ thu thập tất cả dữ liệu cần thiết (cụ thể là dấu vết ngăn xếp của việc chặn đó
nhiệm vụ) và yêu cầu sự cho phép từ nhà phân phối bản vá để buộc chuyển đổi.
Việc sử dụng trái phép có thể gây hại cho hệ thống. Nó phụ thuộc vào bản chất của
bản vá, chức năng nào được (chưa) vá và chức năng nào chặn nhiệm vụ
đang ngủ (/proc/<pid>/stack có thể hữu ích ở đây). Loại bỏ (rmmod) bản vá
các mô-đun bị vô hiệu hóa vĩnh viễn khi tính năng bắt buộc được sử dụng. Nó không thể được
đảm bảo không có tác vụ nào đang ngủ trong mô-đun đó. Nó ngụ ý không giới hạn
số tham chiếu nếu mô-đun bản vá bị tắt và được bật trong một vòng lặp.

Hơn nữa, việc sử dụng vũ lực cũng có thể ảnh hưởng đến các ứng dụng trực tiếp trong tương lai.
vá lỗi và thậm chí còn gây hại nhiều hơn cho hệ thống. Quản trị viên trước tiên nên
hãy cân nhắc việc hủy bỏ quá trình chuyển đổi (xem ở trên). Nếu dùng vũ lực, hãy khởi động lại
nên được lên kế hoạch và không áp dụng thêm các bản vá trực tiếp.

3.1 Thêm hỗ trợ mô hình nhất quán cho các kiến ​​trúc mới
---------------------------------------------------------

Để bổ sung hỗ trợ mô hình nhất quán cho các kiến trúc mới, có một
vài lựa chọn:

1) Thêm CONFIG_HAVE_RELIABLE_STACKTRACE.  Điều này có nghĩa là chuyển objtool và
   đối với các trình tháo gỡ không phải DWARF, đồng thời đảm bảo có cách cho ngăn xếp
   mã truy tìm để phát hiện các ngắt trên ngăn xếp.

2) Ngoài ra, hãy đảm bảo rằng mọi kthread đều có lệnh gọi tới
   klp_update_patch_state() ở vị trí an toàn.  Kthreads thường
   trong một vòng lặp vô hạn thực hiện một số hành động lặp đi lặp lại.  cái an toàn
   vị trí để chuyển trạng thái bản vá của kthread sẽ ở một địa điểm được chỉ định
   điểm trong vòng lặp nơi không có khóa nào được thực hiện và tất cả dữ liệu
   các cấu trúc ở trạng thái được xác định rõ ràng.

Vị trí rõ ràng khi sử dụng hàng đợi công việc hoặc nhân viên kthread
   API.  Các kthread này xử lý các hành động độc lập trong một vòng lặp chung.

Nó phức tạp hơn nhiều với kthreads có vòng lặp tùy chỉnh.
   Ở đó, vị trí an toàn phải được lựa chọn cẩn thận trong từng trường hợp cụ thể
   cơ sở.

Trong trường hợp đó, vòm không có HAVE_RELIABLE_STACKTRACE vẫn sẽ được
   có thể sử dụng các phần không kiểm tra ngăn xếp của mô hình nhất quán:

a) vá các tác vụ của người dùng khi chúng vượt qua không gian kernel/người dùng
      ranh giới; Và

b) vá các luồng kthread và các tác vụ nhàn rỗi tại các điểm vá được chỉ định của chúng.

Tùy chọn này không tốt bằng tùy chọn 1 vì nó yêu cầu tín hiệu
   nhiệm vụ của người dùng và đánh thức kthread để vá chúng.  Nhưng nó vẫn có thể
   một tùy chọn sao lưu tốt cho những kiến trúc không có
   dấu vết ngăn xếp đáng tin cậy nào.


4. Mô-đun Livepatch
===================

Livepatches được phân phối bằng mô-đun hạt nhân, xem
mẫu/livepatch/livepatch-sample.c.

Mô-đun này bao gồm việc triển khai mới các chức năng mà chúng tôi muốn
để thay thế. Ngoài ra, nó còn định nghĩa một số cấu trúc mô tả
mối quan hệ giữa việc thực hiện ban đầu và việc thực hiện mới. Sau đó ở đó
là mã làm cho kernel bắt đầu sử dụng mã mới khi livepatch
mô-đun được tải. Ngoài ra còn có mã dọn dẹp trước
mô-đun livepatch bị xóa. Tất cả điều này được giải thích chi tiết hơn trong
các phần tiếp theo.


4.1. Chức năng mới
------------------

Phiên bản mới của chức năng thường chỉ được sao chép từ bản gốc
nguồn. Một cách thực hành tốt là thêm tiền tố vào tên để chúng
có thể được phân biệt với những cái ban đầu, ví dụ: trong một dấu vết ngược lại. Ngoài ra
chúng có thể được khai báo là tĩnh vì chúng không được gọi trực tiếp
và không cần tầm nhìn toàn cầu.

Bản vá chỉ chứa các chức năng được sửa đổi thực sự. Nhưng họ
có thể muốn truy cập các chức năng hoặc dữ liệu từ tệp nguồn gốc
chỉ có thể truy cập được cục bộ. Điều này có thể được giải quyết bằng một giải pháp đặc biệt
phần di dời trong mô-đun livepatch được tạo, xem
Tài liệu/livepatch/module-elf-format.rst để biết thêm chi tiết.


4.2. Siêu dữ liệu
-------------

Bản vá được mô tả bằng một số cấu trúc phân chia thông tin
thành ba cấp độ:

- struct klp_func được xác định cho từng hàm được vá. Nó mô tả
    mối quan hệ giữa việc triển khai ban đầu và việc triển khai mới của một
    chức năng cụ thể.

Cấu trúc bao gồm tên, dưới dạng một chuỗi, của hàm ban đầu.
    Địa chỉ hàm được tìm thấy thông qua kallsyms khi chạy.

Sau đó, nó bao gồm địa chỉ của hàm mới. Nó được định nghĩa
    trực tiếp bằng cách gán con trỏ hàm. Lưu ý rằng cái mới
    hàm thường được xác định trong cùng một tệp nguồn.

Là một tham số tùy chọn, vị trí ký hiệu trong cơ sở dữ liệu kallsyms có thể
    được sử dụng để phân biệt các chức năng có cùng tên. Đây không phải là
    vị trí tuyệt đối trong cơ sở dữ liệu mà đúng hơn là thứ tự được tìm thấy
    chỉ dành cho một đối tượng cụ thể (vmlinux hoặc mô-đun hạt nhân). Lưu ý rằng
    kallsyms cho phép tìm kiếm các ký hiệu theo tên đối tượng.

- struct klp_object định nghĩa một mảng các hàm được vá (struct
    klp_func) trong cùng một đối tượng. Trường hợp đối tượng là vmlinux
    (NULL) hoặc tên mô-đun.

Cấu trúc giúp nhóm và xử lý các chức năng cho từng đối tượng
    cùng nhau. Lưu ý rằng các mô-đun đã vá có thể được tải muộn hơn
    bản vá và các chức năng liên quan có thể được vá
    chỉ khi chúng có sẵn.


- struct klp_patch định nghĩa một mảng các đối tượng được vá (struct
    klp_object).

Cấu trúc này xử lý tất cả các chức năng được vá một cách nhất quán và cuối cùng,
    một cách đồng bộ. Toàn bộ bản vá chỉ được áp dụng khi tất cả được vá
    các biểu tượng được tìm thấy. Ngoại lệ duy nhất là các ký hiệu từ đồ vật
    (mô-đun hạt nhân) chưa được tải.

Để biết thêm chi tiết về cách áp dụng bản vá cho từng tác vụ,
    xem phần "Mô hình nhất quán".


5. Vòng đời của Livepatch
=======================

Livepatching có thể được mô tả bằng năm thao tác cơ bản:
tải, kích hoạt, thay thế, vô hiệu hóa, loại bỏ.

Trường hợp các hoạt động thay thế và vô hiệu hóa được thực hiện cùng nhau
độc quyền. Họ có kết quả tương tự cho bản vá nhất định nhưng
không dành cho hệ thống.


5.1. Đang tải
------------

Cách hợp lý duy nhất là kích hoạt bản vá khi kernel livepatch
mô-đun đang được tải. Để làm điều này, klp_enable_patch() phải được gọi
trong lệnh gọi lại module_init(). Có hai lý do chính:

Đầu tiên, chỉ có mô-đun mới có quyền truy cập dễ dàng vào cấu trúc klp_patch liên quan.

Thứ hai, mã lỗi có thể được sử dụng để từ chối tải mô-đun khi
bản vá không thể được kích hoạt.


5.2. Kích hoạt
-------------

Livepatch được kích hoạt bằng cách gọi klp_enable_patch() từ
cuộc gọi lại module_init(). Hệ thống sẽ bắt đầu sử dụng giao diện mới
thực hiện các chức năng được vá ở giai đoạn này.

Đầu tiên, địa chỉ của các chức năng được vá được tìm thấy theo
những cái tên. Các di dời đặc biệt, được đề cập trong phần "Chức năng mới",
được áp dụng. Các mục có liên quan được tạo ra dưới
/sys/kernel/livepatch/<name>. Bản vá bị từ chối khi có bất kỳ điều nào ở trên
hoạt động thất bại.

Thứ hai, livepatch chuyển sang trạng thái chuyển tiếp trong đó các nhiệm vụ đang hội tụ
sang trạng thái được vá. Nếu một chức năng ban đầu được vá lần đầu tiên
theo thời gian, một cấu trúc klp_ops cụ thể của hàm được tạo và một cấu trúc chung
trình xử lý ftrace đã được đăng ký\ [#]_. Giai đoạn này được biểu thị bằng giá trị '1'
trong /sys/kernel/livepatch/<name>/transition. Để biết thêm thông tin về
quá trình này, hãy xem phần "Mô hình nhất quán".

Cuối cùng, khi tất cả các tác vụ đã được vá, giá trị 'chuyển tiếp' sẽ thay đổi
đến '0'.

.. [#]

    Note that functions might be patched multiple times. The ftrace handler
    is registered only once for a given function. Further patches just add
    an entry to the list (see field `func_stack`) of the struct klp_ops.
    The right implementation is selected by the ftrace handler, see
    the "Consistency model" section.

    That said, it is highly recommended to use cumulative livepatches
    because they help keeping the consistency of all changes. In this case,
    functions might be patched two times only during the transition period.


5.3. Thay thế
--------------

Tất cả các bản vá đã kích hoạt có thể được thay thế bằng một bản vá tích lũy
đã đặt cờ .replace.

Sau khi bản vá mới được bật và quá trình 'chuyển đổi' kết thúc
tất cả các hàm (struct klp_func) được liên kết với hàm được thay thế
các bản vá được xóa khỏi cấu trúc klp_ops tương ứng. Ngoài ra
trình xử lý ftrace chưa được đăng ký và struct klp_ops là
được giải phóng khi chức năng liên quan không được sửa đổi bởi bản vá mới
và danh sách func_stack trở nên trống rỗng.

Xem Tài liệu/livepatch/cumulative-patches.rst để biết thêm chi tiết.


5.4. Vô hiệu hóa
--------------

Các bản vá đã bật có thể bị vô hiệu hóa bằng cách ghi '0' vào
/sys/kernel/livepatch/<name>/enabled.

Đầu tiên, livepatch chuyển sang trạng thái chuyển tiếp trong đó các nhiệm vụ đang hội tụ
sang trạng thái chưa được vá. Hệ thống bắt đầu sử dụng mã từ
bản vá đã được kích hoạt trước đó hoặc thậm chí là bản gốc. Giai đoạn này là
được biểu thị bằng giá trị '1' trong /sys/kernel/livepatch/<name>/transition.
Để biết thêm thông tin về quy trình này, hãy xem "Mô hình nhất quán"
phần.

Thứ hai, khi tất cả các tác vụ chưa được vá, giá trị 'chuyển tiếp' sẽ thay đổi
đến '0'. Tất cả các chức năng (struct klp_func) được liên kết với chức năng bị vô hiệu hóa
bản vá được xóa khỏi cấu trúc klp_ops tương ứng. Trình xử lý ftrace
chưa được đăng ký và struct klp_ops được giải phóng khi danh sách func_stack
trở nên trống rỗng.

Thứ ba, giao diện sysfs bị phá hủy.


5.5. Đang xóa
-------------

Việc gỡ bỏ mô-đun chỉ an toàn khi không có người sử dụng các chức năng được cung cấp
bởi mô-đun. Đây chính là lý do vì sao tính năng lực vĩnh viễn
vô hiệu hóa việc loại bỏ. Chỉ khi hệ thống được chuyển đổi thành công
sang trạng thái bản vá mới (đã vá/chưa vá) mà không bị ép buộc
đảm bảo rằng không có tác vụ nào ngủ hoặc chạy trong mã cũ.


6. Hệ thống
========

Thông tin về các bản vá đã đăng ký có thể được tìm thấy dưới
/sys/kernel/livepatch. Các bản vá có thể được kích hoạt và vô hiệu hóa
bằng cách viết ở đó.

Các thuộc tính /sys/kernel/livepatch/<patch>/force cho phép quản trị viên tác động đến một
hoạt động vá lỗi.

Xem Tài liệu/ABI/testing/sysfs-kernel-livepatch để biết thêm chi tiết.


7. Hạn chế
==============

Việc triển khai Livepatch hiện tại có một số hạn chế:

- Chỉ những chức năng có thể theo dõi mới có thể được vá.

Livepatch dựa trên ftrace động. Đặc biệt, chức năng
    không thể triển khai ftrace hoặc trình xử lý ftrace livepatch
    đã vá. Nếu không, mã sẽ rơi vào một vòng lặp vô hạn. A
    Lỗi tiềm ẩn được ngăn chặn bằng cách đánh dấu các chức năng có vấn đề
    bởi "notrace".



- Livepatch chỉ hoạt động đáng tin cậy khi ftrace động được đặt tại
    sự khởi đầu của chức năng.

Hàm cần được chuyển hướng trước ngăn xếp hoặc hàm
    các thông số được sửa đổi theo bất kỳ cách nào. Ví dụ: livepatch yêu cầu
    sử dụng tùy chọn trình biên dịch -fentry gcc trên x86_64.

Một ngoại lệ là cổng PPC. Nó sử dụng địa chỉ tương đối và TOC.
    Mỗi chức năng phải xử lý TOC và lưu LR trước khi có thể gọi
    trình xử lý ftrace. Hoạt động này phải được hoàn nguyên khi quay trở lại.
    May mắn thay, mã ftrace chung có cùng một vấn đề và tất cả
    việc này được xử lý ở cấp độ ftrace.


- Kretprobes sử dụng khung ftrace xung đột với bản vá
    chức năng.

Cả kretprobes và livepatches đều sử dụng trình xử lý ftrace để sửa đổi
    địa chỉ trả lại. Người dùng đầu tiên sẽ thắng. Đầu dò hoặc miếng vá
    bị từ chối khi trình xử lý khác đã được sử dụng.


- Kprobe trong hàm ban đầu bị bỏ qua khi mã được
    được chuyển hướng đến việc triển khai mới.

Đang tiến hành thêm các cảnh báo về tình trạng này.
