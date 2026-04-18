.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/maintainer-tip.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Sổ tay cây tip
=====================

Cây tip là gì?
---------------------

Cây mẹo là một tập hợp của một số hệ thống con và các lĩnh vực của
sự phát triển. Cây mẹo vừa là cây phát triển trực tiếp vừa là cây
cây tổng hợp cho một số cây bảo trì phụ. Cây mẹo gitweb URL
là: ZZ0000ZZ

Cây mẹo chứa các hệ thống con sau:

-ZZ0000ZZ

Sự phát triển kiến trúc x86 diễn ra trong cây mẹo ngoại trừ
     đối với các bộ phận cụ thể x86 KVM và XEN được duy trì trong
     các hệ thống con tương ứng và được định tuyến trực tiếp đến tuyến chính từ
     ở đó. Đó vẫn là một cách tốt để Cc những người bảo trì x86 trên
     Các bản vá KVM và XEN dành riêng cho x86.

Một số hệ thống con x86 có bộ bảo trì riêng ngoài
     người duy trì x86 tổng thể.  Vui lòng Cc những người duy trì x86 tổng thể trên
     vá lỗi chạm vào các tệp trong Arch/x86 ngay cả khi chúng không được gọi ra
     bằng tệp MAINTAINER.

Lưu ý rằng ZZ0000ZZ không phải là danh sách gửi thư. Nó chỉ đơn thuần là một
     bí danh thư phân phối thư đến nhà bảo trì cấp cao nhất x86
     đội. Vui lòng luôn Cc danh sách gửi thư của Hạt nhân Linux (LKML)
     ZZ0001ZZ, nếu không thư của bạn sẽ chỉ kết thúc ở
     hộp thư đến riêng của người bảo trì.

-ZZ0000ZZ

Việc phát triển bộ lập lịch diễn ra trong cây -tip, trong
     nhánh lập kế hoạch/cốt lõi - với các cây chủ đề phụ không thường xuyên cho
     các bộ bản vá đang được thực hiện.

-ZZ0000ZZ

Khóa phát triển (bao gồm cả nguyên tử và đồng bộ hóa khác
     nguyên thủy được kết nối với khóa) diễn ra trong -tip
     cây, trong nhánh khóa/lõi - thỉnh thoảng có cây chủ đề phụ
     dành cho các bộ bản vá đang trong quá trình thực hiện.

-ZZ0000ZZ:

- sự phát triển cốt lõi bị gián đoạn xảy ra trong nhánh irq/core

- việc phát triển trình điều khiển chip bị gián đoạn cũng xảy ra trong irq/core
       nhánh, nhưng các bản vá thường được áp dụng trong một trình duy trì riêng biệt
       cây và sau đó tổng hợp thành irq/core

-ZZ0000ZZ:

- phát triển máy chấm công, lõi nguồn xung nhịp, NTP và phát triển bộ đếm thời gian báo thức
       xảy ra trong nhánh bộ định thời/lõi, nhưng các bản vá thường được áp dụng trong
       một cây duy trì riêng biệt và sau đó được tổng hợp thành bộ định thời/lõi

- phát triển trình điều khiển sự kiện/nguồn xung nhịp xảy ra trong bộ tính giờ/lõi
       nhánh, nhưng các bản vá hầu hết được áp dụng trong một cây bảo trì riêng biệt
       và sau đó được tổng hợp thành bộ tính giờ/lõi

-ZZ0000ZZ:

- Sự phát triển hỗ trợ kiến trúc và cốt lõi hoàn hảo diễn ra trong
       nhánh hoàn hảo/cốt lõi

- quá trình phát triển công cụ hoàn hảo diễn ra trong trình bảo trì công cụ hoàn hảo
       cây và được tổng hợp thành cây ngọn.

-ZZ0000ZZ

-ZZ0000ZZ

Hầu hết các bản vá RAS dành riêng cho x86 được thu thập trong tip ras/core
     chi nhánh.

-ZZ0000ZZ

Phát triển EFI trong cây git efi. Các bản vá được thu thập là
     được tổng hợp trong nhánh tip efi/core.

-ZZ0000ZZ

Quá trình phát triển RCU diễn ra trong cây linux-rcu. Kết quả thay đổi
     được tổng hợp vào nhánh tip core/rcu.

-ZZ0000ZZ:

- gỡ lỗi đối tượng

- công cụ đối tượng

- bit và mảnh ngẫu nhiên


Ghi chú gửi bản vá
----------------------

Chọn cây/cành
^^^^^^^^^^^^^^^^^^^^^^^^^

Nhìn chung, sự phát triển so với phần đầu của nhánh chính của cây ngọn là
tốt thôi, nhưng đối với các hệ thống con được duy trì riêng biệt, có
cây git của riêng mình và chỉ được tổng hợp vào cây mẹo, quá trình phát triển sẽ
diễn ra đối với cây hoặc nhánh hệ thống con có liên quan.

Sửa lỗi mà dòng chính mục tiêu phải luôn được áp dụng đối với
cây hạt nhân chính. Những xung đột tiềm ẩn chống lại những thay đổi đã được thực hiện
xếp hàng đợi trong cây mẹo được xử lý bởi người bảo trì.

Chủ đề vá lỗi
^^^^^^^^^^^^^

Định dạng ưa thích của cây mẹo cho tiền tố chủ đề bản vá là
'hệ thống con/thành phần:', ví dụ: 'x86/apic:', 'x86/mm/fault:', 'lên lịch/công bằng:',
'genirq/lõi:'. Vui lòng không sử dụng tên tệp hoặc đường dẫn tệp đầy đủ vì
tiền tố. 'git log path/to/file' sẽ cung cấp cho bạn gợi ý hợp lý trong hầu hết các trường hợp
trường hợp.

Mô tả bản vá cô đọng trong dòng chủ đề phải bắt đầu bằng một
chữ in hoa và phải được viết bằng giọng điệu mệnh lệnh.


Nhật ký thay đổi
^^^^^^^^^^^^^^^^

Áp dụng các quy tắc chung về nhật ký thay đổi trong ZZ0000ZZ.

Những người duy trì cây mẹo đặt giá trị vào việc tuân theo các quy tắc này, đặc biệt là trên
yêu cầu viết nhật ký thay đổi trong tâm trạng bắt buộc và không mạo danh
mã hoặc việc thực thi nó. Đây không chỉ là ý thích của
người bảo trì. Nhật ký thay đổi được viết bằng từ trừu tượng sẽ chính xác hơn và
có xu hướng ít gây nhầm lẫn hơn so với những tác phẩm được viết dưới dạng tiểu thuyết.

Việc cấu trúc nhật ký thay đổi thành nhiều đoạn cũng rất hữu ích và không
gộp mọi thứ lại thành một. Một cấu trúc tốt là để giải thích
bối cảnh, vấn đề và giải pháp trong các đoạn văn riêng biệt và điều này
đặt hàng.

Ví dụ minh họa:

Ví dụ 1::

x86/intel_rdt/mbm: Khắc phục trình xử lý tràn MBM khi CPU nóng

Khi CPU sắp chết, chúng tôi hủy nhân viên đó và lên lịch cho nhân viên mới theo lịch trình
    CPU khác nhau trên cùng một tên miền. Nhưng nếu đồng hồ hẹn giờ đã sắp hết
    hết hạn (giả sử là 0,99 giây) thì về cơ bản chúng tôi sẽ nhân đôi khoảng thời gian.

Chúng tôi sửa đổi cách xử lý CPU nóng để hủy bỏ công việc bị trì hoãn khi sắp chết
    cpu và chạy nhân viên ngay lập tức trên một cpu khác trong cùng một miền. Chúng tôi
    không xóa nhân viên vì nhân viên tràn MBM lên lịch lại
    worker trên cùng một CPU và quét miền->cpu_mask để lấy miền
    con trỏ.

Phiên bản cải tiến::

x86/intel_rdt/mbm: Khắc phục trình xử lý tràn MBM trong quá trình cắm nóng CPU

Khi CPU sắp chết, nhân viên tràn sẽ bị hủy và lên lịch lại trên một
    CPU khác nhau trong cùng một miền. Nhưng nếu đồng hồ hẹn giờ đã sắp hết
    hết hạn, điều này về cơ bản sẽ tăng gấp đôi khoảng thời gian có thể dẫn đến kết quả không
    phát hiện tràn.

Hủy nhân viên tràn và lên lịch lại ngay lập tức trên một CPU khác
    trong cùng một miền. Công việc cũng có thể bị xóa bỏ, nhưng điều đó sẽ
    sắp xếp lại nó trên cùng một CPU.

Ví dụ 2::

thời gian: POSIX Bộ định thời CPU: Đảm bảo biến đó được khởi tạo

Nếu cpu_timer_sample_group trả về -EINVAL, nó sẽ không được ghi vào
    *mẫu. Việc kiểm tra giá trị trả về của cpu_timer_sample_group sẽ loại trừ
    khả năng sử dụng giá trị chưa được khởi tạo của bây giờ trong khối sau.
    Với clock_idx không hợp lệ, mã trước đó có thể ghi đè lên
    *oldval theo cách không xác định. Điều này hiện đã được ngăn chặn. Chúng tôi cũng khai thác
    đoản mạch && để lấy mẫu bộ đếm thời gian chỉ khi kết quả đạt được
    thực sự được sử dụng để cập nhật *oldval.

Phiên bản cải tiến::

posix-cpu-timers: Làm cho set_process_cpu_timer() mạnh mẽ hơn

Bởi vì giá trị trả về của cpu_timer_sample_group() không được chọn,
    trình biên dịch và trình kiểm tra tĩnh có thể cảnh báo một cách hợp pháp về khả năng sử dụng
    của biến chưa được khởi tạo 'bây giờ'. Đây không phải là vấn đề về thời gian chạy vì tất cả
    gọi các trang web cung cấp id đồng hồ hợp lệ.

Ngoài ra cpu_timer_sample_group() được gọi vô điều kiện ngay cả khi
    kết quả không được sử dụng vì *oldval là NULL.

Thực hiện lệnh gọi có điều kiện và kiểm tra giá trị trả về.

Ví dụ 3::

Thực thể này cũng có thể được sử dụng cho các mục đích khác.

Hãy đổi tên nó thành chung chung hơn.

Phiên bản cải tiến::

Thực thể này cũng có thể được sử dụng cho các mục đích khác.

Đổi tên nó thành chung chung hơn.


Đối với các kịch bản phức tạp, đặc biệt là điều kiện cuộc đua và thứ tự bộ nhớ
vấn đề, sẽ rất có giá trị khi mô tả tình huống bằng một bảng cho thấy
sự song song và trật tự thời gian của các sự kiện. Đây là một ví dụ::

CPU0 CPU1
    free_irq(X) ngắt X
                                    spin_lock(desc->lock)
                                    đánh thức chủ đề irq()
                                    spin_unlock(desc->lock)
    spin_lock(desc->lock)
    xóa hành động()
    tắt máy_irq()
    phát hành_resource() thread_handler()
    spin_unlock(desc->lock) truy cập các tài nguyên đã phát hành.
                                      ^^ ^^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^ ^^
    đồng bộ hóa_irq()

Lockdep cung cấp đầu ra hữu ích tương tự để mô tả sự bế tắc có thể xảy ra
kịch bản::

CPU0 CPU1
    rtmutex_lock(&rcu->rt_mutex)
      spin_lock(&rcu->rt_mutex.wait_lock)
                                            local_irq_disable()
                                            spin_lock(&timer->it_lock)
                                            spin_lock(&rcu->mutex.wait_lock)
    --> Ngắt
        spin_lock(&timer->it_lock)


Tham chiếu chức năng trong nhật ký thay đổi
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khi một chức năng được đề cập trong nhật ký thay đổi, nội dung văn bản hoặc
dòng chủ đề, vui lòng sử dụng định dạng 'function_name()'. Bỏ qua
dấu ngoặc sau tên hàm có thể không rõ ràng::

Chủ đề: hệ thống con/thành phần: Đặt booking_count tĩnh

booking_count chỉ được sử dụng trong booking_stats. Làm cho nó tĩnh.

Biến thể có dấu ngoặc chính xác hơn::

Chủ đề: hệ thống con/thành phần: Đặt Đặt chỗ_count() tĩnh

booking_count() chỉ được gọi từ booking_stats(). làm cho nó
  tĩnh.


Dấu vết quay lại trong nhật ký thay đổi
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Xem ZZ0000ZZ.

Thứ tự các thẻ cam kết
^^^^^^^^^^^^^^^^^^^^^^^

Để có cái nhìn thống nhất về các thẻ cam kết, người duy trì mẹo sử dụng
sơ đồ đặt hàng thẻ sau:

- Sửa lỗi: 12+char-SHA1 ("phụ/sys: Dòng chủ đề gốc")

Nên thêm thẻ Sửa lỗi ngay cả đối với những thay đổi không cần thiết
   được chuyển ngược sang các hạt nhân ổn định, tức là khi giải quyết một vấn đề được giới thiệu gần đây
   vấn đề chỉ ảnh hưởng đến tiền boa hoặc người đứng đầu hiện tại của tuyến chính. Những thẻ này
   rất hữu ích để xác định cam kết ban đầu và có giá trị hơn nhiều
   hơn là đề cập một cách nổi bật đến cam kết đã gây ra vấn đề trong
   nội dung của nhật ký thay đổi vì chúng có thể được tự động
   được chiết xuất.

Ví dụ sau minh họa sự khác biệt::

Làm

abcdef012345678 ("x86/xxx: Thay thế foo bằng bar")

để lại một phiên bản không sử dụng của biến foo xung quanh. Loại bỏ nó.

Người đăng ký: J.Dev <j.dev@mail>

Thay vào đó hãy nói::

Việc thay thế foo bằng bar gần đây đã để lại một phiên bản không được sử dụng của
     biến foo xung quanh. Loại bỏ nó.

Sửa lỗi: abcdef012345678 ("x86/xxx: Thay thế foo bằng bar")
     Người đăng ký: J.Dev <j.dev@mail>

Cái sau đưa thông tin về bản vá vào tiêu điểm và
   sửa đổi nó bằng cách tham chiếu đến cam kết đã đưa ra vấn đề
   thay vì đặt trọng tâm vào cam kết ban đầu ngay từ đầu.

- Người báo cáo: ZZ0000ZZ

- Đóng cửa: ZZ0000ZZ

- Nguyên tác bởi: ZZ0000ZZ

- Người đề xuất: ZZ0000ZZ

- Đồng phát triển bởi: ZZ0000ZZ

Người đăng ký: ZZ0000ZZ

Lưu ý rằng Đồng tác giả và Ký xác nhận của (các) đồng tác giả phải
   đi theo cặp.

- Người đăng ký: ZZ0000ZZ

Người đăng ký đầu tiên (SOB) sau cặp Người đồng phát triển/SOB cuối cùng là
   tác giả SOB, tức là người được git gắn cờ là tác giả.

- Người đăng ký: ZZ0000ZZ

Các SOB sau tác giả SOB là của người xử lý, vận chuyển
   bản vá, nhưng không tham gia vào quá trình phát triển. Chuỗi SOB nên
   phản ánh lộ trình ZZ0000ZZ mà bản vá đã thực hiện khi nó được phổ biến cho chúng tôi,
   với mục nhập SOB đầu tiên báo hiệu quyền tác giả chính của một bài viết
   tác giả. Xác nhận phải được đưa ra dưới dạng dòng Xác nhận và phê duyệt xem xét
   như được đánh giá theo dòng.

Nếu trình xử lý thực hiện sửa đổi đối với bản vá hoặc nhật ký thay đổi thì
   điều này nên được đề cập đến ZZ0000ZZ văn bản nhật ký thay đổi và ZZ0001ZZ
   tất cả các thẻ cam kết ở định dạng sau ::

     ... changelog text ends.

[ trình xử lý: Đã thay thế foo bằng thanh và nhật ký thay đổi được cập nhật ]

Thẻ đầu tiên:.....

Lưu ý hai dòng mới trống ngăn cách văn bản nhật ký thay đổi và
   cam kết thẻ từ thông báo đó.

Nếu một bản vá được người xử lý gửi đến danh sách gửi thư thì tác giả có
   được ghi chú trong dòng đầu tiên của nhật ký thay đổi với::

Từ: Tác giả <author@mail>

Văn bản nhật ký thay đổi bắt đầu từ đây....

vì vậy quyền tác giả được bảo tồn. Phải theo dòng 'Từ:'
   bởi một dòng mới trống. Nếu dòng 'Từ:' đó bị thiếu thì bản vá
   sẽ được quy cho người gửi (vận chuyển, xử lý) nó.
   Dòng 'Từ:' sẽ tự động bị xóa khi áp dụng bản vá
   và không hiển thị trong nhật ký thay đổi git cuối cùng. Nó chỉ ảnh hưởng
   thông tin về quyền tác giả của cam kết Git kết quả.

- Đã được thử nghiệm bởi: ZZ0000ZZ

- Người đánh giá: ZZ0000ZZ

- Được xác nhận bởi: ZZ0000ZZ

- Cc: ZZ0000ZZ

Nếu bản vá phải được chuyển về trạng thái ổn định thì vui lòng thêm thẻ 'ZZ0000ZZ' nhưng không Cc ổn định khi gửi
   thư.

-Link: ZZ0000ZZ

Để tham khảo một email được đăng lên danh sách gửi thư kernel, vui lòng
   sử dụng bộ chuyển hướng lore.kernel.org URL::

Liên kết: ZZ0000ZZ

Nên sử dụng URL này khi tham khảo danh sách gửi thư có liên quan
   chủ đề, bộ bản vá liên quan hoặc các chủ đề thảo luận đáng chú ý khác.
   Một cách thuận tiện để liên kết các đoạn giới thiệu ZZ0000ZZ với cam kết
   thông báo là sử dụng ký hiệu trong ngoặc giống như đánh dấu, ví dụ::

Một cách tiếp cận tương tự đã được thử trước đây như một phần của một giải pháp khác
     nỗ lực [1], nhưng việc triển khai ban đầu gây ra quá nhiều
     hồi quy [2] nên nó đã được sao lưu và triển khai lại.

Liên kết: ZZ0000ZZ # [1]
     Liên kết: ZZ0001ZZ # [2]

Bạn cũng có thể sử dụng đoạn giới thiệu ZZ0000ZZ để chỉ ra nguồn gốc của
   patch khi áp dụng nó vào cây git của bạn. Trong trường hợp đó, hãy sử dụng
   miền ZZ0001ZZ chuyên dụng thay vì ZZ0002ZZ.
   Cách thực hành này giúp cho công cụ tự động có thể xác định được
   sử dụng liên kết nào để truy xuất bản vá ban đầu. Ví dụ::

Liên kết: ZZ0000ZZ

Vui lòng không sử dụng các thẻ kết hợp, ví dụ: ZZ0000ZZ, như
chúng chỉ làm phức tạp thêm việc trích xuất thẻ tự động.


Liên kết đến tài liệu
^^^^^^^^^^^^^^^^^^^^^^

Cung cấp liên kết đến tài liệu trong nhật ký thay đổi là một trợ giúp tuyệt vời cho sau này
gỡ lỗi và phân tích.  Thật không may, URL thường bị hỏng rất nhanh
bởi vì các công ty thường xuyên tái cấu trúc trang web của họ.  Không 'dễ bay hơi'
các trường hợp ngoại lệ bao gồm Intel SDM và AMD APM.

Do đó, đối với các tài liệu “dễ bay hơi”, hãy tạo một mục trong kernel
bugzilla ZZ0000ZZ và đính kèm bản sao của các tài liệu này
đến mục bugzilla. Cuối cùng, cung cấp URL của mục bugzilla trong
nhật ký thay đổi.

Gửi lại bản vá hoặc lời nhắc
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Xem ZZ0000ZZ.

Hợp nhất cửa sổ
^^^^^^^^^^^^^^^

Xin đừng mong đợi các bản vá sẽ được xem xét hoặc hợp nhất theo mẹo
người bảo trì xung quanh hoặc trong cửa sổ hợp nhất.  Cây cối đã đóng cửa
cho tất cả trừ các bản sửa lỗi khẩn cấp trong thời gian này.  Họ mở lại sau khi hợp nhất
cửa sổ đóng lại và hạt nhân -rc1 mới đã được phát hành.

Chuỗi lớn phải được gửi ở trạng thái có thể hợp nhất ZZ0000ZZ ZZ0001ZZ một tuần
trước khi cửa sổ hợp nhất mở ra.  Các ngoại lệ được thực hiện để sửa lỗi và
ZZ0002ZZ dành cho trình điều khiển độc lập nhỏ dành cho phần cứng mới hoặc tối thiểu
các bản vá xâm lấn để hỗ trợ phần cứng.

Trong cửa sổ hợp nhất, thay vào đó, những người bảo trì tập trung vào việc tuân theo
các thay đổi ngược dòng, sửa lỗi cửa sổ hợp nhất, thu thập các bản sửa lỗi và
cho phép mình thở một hơi. Hãy tôn trọng điều đó.

Vì vậy, các nhánh được gọi là _ Emergency_ sẽ được sáp nhập vào dòng chính trong thời gian diễn ra
giai đoạn ổn định của mỗi phiên bản.


Git
^^^

Những người bảo trì tiền boa chấp nhận yêu cầu kéo git từ những người bảo trì cung cấp
thay đổi hệ thống con để tổng hợp trong cây mẹo.

Yêu cầu kéo để gửi bản vá mới thường không được chấp nhận và không
thay thế việc gửi bản vá thích hợp vào danh sách gửi thư. Lý do chính cho
đây là quy trình đánh giá dựa trên email.

Nếu bạn gửi một loạt bản vá lớn hơn thì việc cung cấp một nhánh git sẽ rất hữu ích
trong một kho lưu trữ riêng tư cho phép những người quan tâm dễ dàng lấy
loạt để thử nghiệm. Cách thông thường để cung cấp điều này là một git URL trên trang bìa
thư của loạt bản vá.

Kiểm tra
^^^^^^^^

Mã phải được kiểm tra trước khi gửi cho người bảo trì tiền boa.  Bất cứ điều gì
ngoài những thay đổi nhỏ nên được xây dựng, khởi động và thử nghiệm với
đã bật các tùy chọn gỡ lỗi kernel toàn diện (và nặng).

Các tùy chọn gỡ lỗi này có thể được tìm thấy trong kernel/configs/x86_debug.config
và có thể được thêm vào cấu hình kernel hiện có bằng cách chạy:

tạo x86_debug.config

Một số tùy chọn này dành riêng cho x86 và có thể bị bỏ qua khi thử nghiệm
trên các kiến trúc khác.

.. _maintainer-tip-coding-style:

Ghi chú kiểu mã hóa
-------------------

Phong cách bình luận
^^^^^^^^^^^^^^^^^^^^

Các câu trong nhận xét bắt đầu bằng chữ in hoa.

Nhận xét một dòng::

/* Đây là chú thích một dòng */

Nhận xét nhiều dòng::

/*
	 * Đây là một định dạng đúng
	 * bình luận nhiều dòng.
	 *
	 * Những bình luận nhiều dòng lớn hơn nên được chia thành các đoạn văn.
	 */

Không có bình luận đuôi (xem bên dưới):

Vui lòng không sử dụng bình luận đuôi. Bình luận đuôi làm phiền
  luồng đọc trong hầu hết các ngữ cảnh, nhưng đặc biệt là trong mã::

if (somecondition_is_true) /* Đừng bình luận ở đây */
		dostuff(); /* Ở đây cũng không có */

hạt giống = MAGIC_CONSTANT; /* Cũng không phải ở đây */

Thay vào đó, hãy sử dụng nhận xét độc lập::

/* Điều kiện này không rõ ràng nếu không có chú thích */
	nếu (somecondition_is_true) {
		/* Điều này thực sự cần phải được ghi lại */
		dostuff();
	}

/* Việc khởi tạo phép thuật này cần được bình luận. Có lẽ không? */
	hạt giống = MAGIC_CONSTANT;

Sử dụng kiểu C++, gắn đuôi chú thích khi ghi lại cấu trúc trong tiêu đề thành
  đạt được bố cục nhỏ gọn hơn và dễ đọc hơn::

// eax
        u32 x2apic_shift : 5, // Số bit để dịch ID APIC sang phải
                                      // cho ID cấu trúc liên kết ở cấp độ tiếp theo
                                : 27; // Dành riêng
        // ebx
        u32 num_processors : 16, // Số lượng bộ xử lý ở cấp độ hiện tại
                                : 16; // Kín đáo

so với::

/* ea */
	        /*
	         * Số bit để dịch chuyển ID APIC sang phải cho ID cấu trúc liên kết
	         * ở cấp độ tiếp theo
	         */
         u32 x2apic_shift : 5,
		 /* Đã đặt trước */
				 : 27;

/* ebx */
		/* Số lượng bộ xử lý ở mức hiện tại */
	u32 num_processors: 16,
		/* Đã đặt trước */
				: 16;

Bình luận những điều quan trọng:

Cần thêm bình luận khi thao tác không rõ ràng. Tài liệu
  điều hiển nhiên chỉ là sự xao lãng::

/* Giảm số lần đếm lại và kiểm tra số 0 */
	if (refcount_dec_and_test(&p->refcnt)) {
		làm ;
		rất nhiều;
		của;
		ảo thuật;
		đồ đạc;
	}

Thay vào đó, các nhận xét nên giải thích những chi tiết và tài liệu không rõ ràng.
  hạn chế::

if (refcount_dec_and_test(&p->refcnt)) {
		/*
		 * Lời giải thích thực sự hay tại sao lại có những điều kỳ diệu dưới đây
		 * cần phải được thực hiện, sắp xếp thứ tự và khóa các ràng buộc,
		 * v.v..
		 */
		làm ;
		rất nhiều;
		của;
		ảo thuật;
		/* Cần phải là thao tác cuối cùng vì ... */
		sự vật;
	}

Nhận xét tài liệu chức năng:

Để ghi lại các hàm và đối số của chúng, vui lòng sử dụng định dạng kernel-doc
  và không phải là nhận xét dạng tự do::

/**
	 * magic_function - Làm nhiều thứ ma thuật
	 * @magic: Con trỏ tới dữ liệu ma thuật để thao tác
	 * @offset: Offset trong mảng dữ liệu của @magic
	 *
	 * Giải thích sâu sắc về những điều bí ẩn được thực hiện với @magic
         * với tài liệu về các giá trị trả về.
	 *
	 * Lưu ý rằng các mô tả đối số ở trên được sắp xếp
	 * theo kiểu bảng biểu.
	 */

Điều này đặc biệt áp dụng cho các hàm hiển thị toàn cầu và các hàm nội tuyến
  chức năng trong các tập tin tiêu đề công cộng. Có thể là quá mức cần thiết khi sử dụng kernel-doc
  format cho mọi hàm (tĩnh) cần một lời giải thích nhỏ. các
  việc sử dụng tên hàm mô tả thường thay thế những nhận xét nhỏ này.
  Áp dụng lẽ thường như mọi khi.


Yêu cầu khóa tài liệu
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Ghi lại các yêu cầu khóa là một điều tốt, nhưng các bình luận thì không
  nhất thiết phải là sự lựa chọn tốt nhất. Thay vì viết::

/* Người gọi phải giữ foo->lock */
	void func(struct foo *foo)
	{
		...
	}

Vui lòng sử dụng::

void func(struct foo *foo)
	{
		lockdep_assert_held(&foo->lock);
		...
	}

Trong hạt nhân PROVE_LOCKING, lockdep_assert_held() phát ra cảnh báo
  nếu người gọi không giữ khóa.  Bình luận không thể làm điều đó.

Quy tắc khung
^^^^^^^^^^^^^

Chỉ nên bỏ dấu ngoặc nếu câu lệnh theo sau 'if', 'for',
'while', v.v. thực sự là một dòng duy nhất ::

nếu (foo)
		do_something();

Sau đây không được coi là một tuyên bố dòng đơn ngay cả
mặc dù C không yêu cầu dấu ngoặc::

cho (i = 0; i < kết thúc; i++)
		nếu (foo[i])
			do_something(foo[i]);

Việc thêm dấu ngoặc quanh vòng lặp bên ngoài sẽ nâng cao luồng đọc::

cho (i = 0; i < kết thúc; i++) {
		nếu (foo[i])
			do_something(foo[i]);
	}


Khai báo biến
^^^^^^^^^^^^^^^^^^^^^

Thứ tự ưu tiên của các khai báo biến ở đầu một
chức năng đảo ngược thứ tự cây linh sam::

struct long_struct_name *descriptive_name;
	foo, thanh dài không dấu;
	int không dấu tmp;
	int ret;

Ở trên phân tích cú pháp nhanh hơn so với thứ tự ngược lại ::

int ret;
	int không dấu tmp;
	foo, thanh dài không dấu;
	struct long_struct_name *descriptive_name;

Và thậm chí còn hơn thế nữa so với việc đặt hàng ngẫu nhiên::

foo, thanh dài không dấu;
	int ret;
	struct long_struct_name *descriptive_name;
	int không dấu tmp;

Ngoài ra, vui lòng thử tổng hợp các biến cùng loại thành một
dòng. Không có ích gì khi lãng phí không gian màn hình::

không dấu dài a;
	dài không dấu b;
	không dấu dài c;
	không dấu dài d;

Nó thực sự đủ để làm::

không dấu dài a, b, c, d;

Ngoài ra, vui lòng không giới thiệu việc phân tách dòng trong khai báo biến ::

struct long_struct_name *descriptive_name = container_of(bar,
						      cấu trúc long_struct_name,
	                                              thành viên);
	struct foobar foo;

Cách tốt hơn là chuyển phần khởi tạo sang một dòng riêng sau dòng
khai báo::

struct long_struct_name *descriptive_name;
	struct foobar foo;

mô tả_name = container_of(bar, struct long_struct_name, member);


Các loại biến
^^^^^^^^^^^^^^

Vui lòng sử dụng các loại u8, u16, u32, u64 thích hợp cho các biến có ý nghĩa
để mô tả phần cứng hoặc được sử dụng làm đối số cho các hàm truy cập
phần cứng. Những loại này được xác định rõ ràng về độ rộng bit và tránh
cắt ngắn, mở rộng và nhầm lẫn 32/64-bit.

u64 cũng được khuyến nghị trong mã sẽ trở nên mơ hồ đối với 32-bit
thay vào đó, các hạt nhân khi 'unsigned long' sẽ được sử dụng. Trong khi ở trong tình trạng như vậy
tình huống 'dài không dấu' cũng có thể được sử dụng, u64 ngắn hơn
và cũng cho thấy rõ rằng thao tác được yêu cầu phải rộng 64 bit
độc lập với CPU mục tiêu.

Vui lòng sử dụng 'unsign int' thay vì 'unsigned'.


Hằng số
^^^^^^^^^

Vui lòng không sử dụng số thập phân bằng chữ (hexa) trong mã hoặc bộ khởi tạo.
Sử dụng các định nghĩa thích hợp có tên mô tả hoặc cân nhắc sử dụng
một enum.


Khai báo cấu trúc và khởi tạo
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khai báo cấu trúc phải căn chỉnh tên thành viên cấu trúc trong bảng
thời trang::

cấu trúc bar_order {
		unsign int guest_id;
		int order_item;
		menu cấu trúc *menu;
	};

Vui lòng tránh ghi lại các thành viên cấu trúc trong phần khai báo, bởi vì
điều này thường dẫn đến những nhận xét có định dạng lạ và các thành viên cấu trúc
trở nên bối rối::

cấu trúc bar_order {
		unsign int guest_id; /* ID khách duy nhất */
		int order_item;
		/* Con trỏ tới một thực thể menu chứa tất cả đồ uống */
		menu cấu trúc *menu;
	};

Thay vào đó, vui lòng cân nhắc sử dụng định dạng kernel-doc trong nhận xét trước
khai báo cấu trúc, dễ đọc hơn và có thêm lợi thế
bao gồm thông tin trong tài liệu hạt nhân, ví dụ như
sau::


/**
	 * struct bar_order - Mô tả thứ tự thanh
	 * @guest_id: Id khách duy nhất
	 * @ordered_item: Mã số món trong menu
	 * @menu: Con trỏ tới menu chứa mục đó
	 * đã được đặt hàng
	 *
	 * Thông tin bổ sung cho việc sử dụng cấu trúc.
	 *
	 * Lưu ý rằng các mô tả thành phần cấu trúc ở trên được sắp xếp
	 * theo kiểu bảng biểu.
	 */
	cấu trúc bar_order {
		unsign int guest_id;
		int order_item;
		menu cấu trúc *menu;
	};

Bộ khởi tạo cấu trúc tĩnh phải sử dụng bộ khởi tạo C99 và cũng phải
căn chỉnh theo kiểu bảng::

cấu trúc tĩnh foo statfoo = {
		.a = 0,
		.plain_integer = CONSTANT_DEFINE_OR_ENUM,
		.bar = &statbar,
	};

Lưu ý rằng mặc dù cú pháp C99 cho phép bỏ qua dấu phẩy cuối cùng,
chúng tôi khuyên bạn nên sử dụng dấu phẩy ở dòng cuối cùng vì nó làm cho
sắp xếp lại và bổ sung các dòng mới dễ dàng hơn và làm cho tương lai như vậy
các bản vá cũng dễ đọc hơn một chút.

Ngắt dòng
^^^^^^^^^^^

Việc giới hạn độ dài dòng ở mức 80 ký tự khiến mã thụt lề sâu khó có thể thực hiện được
đọc.  Hãy cân nhắc việc chia mã thành các hàm trợ giúp để tránh việc sử dụng quá nhiều
ngắt dòng.

Quy tắc 80 ký tự không phải là quy tắc nghiêm ngặt, vì vậy vui lòng sử dụng ý thức chung khi
ngắt dòng. Đặc biệt là các chuỗi định dạng không bao giờ được chia nhỏ.

Khi tách khai báo hàm hoặc gọi hàm thì hãy căn chỉnh
đối số đầu tiên ở dòng thứ hai với đối số đầu tiên ở dòng đầu tiên
dòng::

int tĩnh long_function_name(struct foobar *barfoo, unsigned int id,
				phần bù int không dấu)
  {

nếu (!id) {
		ret = long_function_name(barfoo, DEFAULT_BARFOO_ID,
					   bù đắp);
	...

Không gian tên
^^^^^^^^^^^^^^

Không gian tên hàm/biến cải thiện khả năng đọc và cho phép dễ dàng
gắp. Các không gian tên này là tiền tố chuỗi để hiển thị trên toàn cầu
tên hàm và biến, bao gồm cả nội tuyến. Những tiền tố này nên
kết hợp hệ thống con và tên thành phần, chẳng hạn như 'x86_comp\_',
'lịch\_', 'irq\_' và 'mutex\_'.

Điều này cũng bao gồm các hàm phạm vi tệp tĩnh được đặt ngay lập tức
vào các mẫu trình điều khiển hiển thị trên toàn cầu - nó hữu ích cho các ký hiệu đó
cũng phải mang một tiền tố tốt để có thể đọc được dấu vết ngược.

Tiền tố không gian tên có thể được bỏ qua đối với các hàm tĩnh cục bộ và
các biến. Các hàm cục bộ thực sự, chỉ được gọi bởi các hàm cục bộ khác,
có thể có tên mô tả ngắn hơn - mối quan tâm chính của chúng tôi là khả năng phân loại
và khả năng đọc ngược.

Xin lưu ý rằng tiền tố 'xxx_vendor\_' và 'vendor_xxx_` không
hữu ích cho các hàm tĩnh trong các tệp dành riêng cho nhà cung cấp. Rốt cuộc thì nó
đã rõ ràng rằng mã này dành riêng cho nhà cung cấp. Ngoài ra, nhà cung cấp
tên chỉ nên dành cho chức năng thực sự dành riêng cho nhà cung cấp.

Như luôn áp dụng ý thức chung và hướng tới sự nhất quán và dễ đọc.


Thông báo cam kết
--------------------

Cây mẹo được bot giám sát để xác nhận các lần xác nhận mới. Bot gửi email
cho mỗi cam kết mới đối với một danh sách gửi thư chuyên dụng
(ZZ0000ZZ) và tất cả những người của Cc
được đề cập trong một trong các thẻ cam kết. Nó sử dụng ID tin nhắn email từ
Thẻ liên kết ở cuối danh sách thẻ để đặt tiêu đề email Trả lời để
tin nhắn được xâu chuỗi đúng cách với email gửi bản vá.

Người duy trì tiền boa và người duy trì phụ cố gắng trả lời người gửi
khi ghép một bản vá nhưng đôi khi họ quên hoặc nó không vừa với bản vá
quy trình làm việc của thời điểm hiện tại. Mặc dù tin nhắn của bot hoàn toàn mang tính cơ học nhưng nó
cũng ngụ ý 'Cảm ơn bạn! Đã áp dụng.'.