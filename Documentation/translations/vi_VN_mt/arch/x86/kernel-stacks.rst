.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/kernel-stacks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
ngăn xếp hạt nhân
=================

Ngăn xếp hạt nhân trên x86-64 bit
===========================

Phần lớn văn bản của Keith Owens, bị AK hack

kích thước trang x86_64 (PAGE_SIZE) là 4K.

Giống như tất cả các kiến trúc khác, x86_64 có một ngăn xếp hạt nhân cho mọi
chủ đề hoạt động.  Các ngăn xếp luồng này có kích thước lớn THREAD_SIZE (4*PAGE_SIZE).
Các ngăn xếp này chứa dữ liệu hữu ích miễn là một luồng còn hoạt động hoặc một
xác sống. Trong khi luồng ở trong không gian người dùng thì ngăn xếp kernel trống
ngoại trừ cấu trúc thread_info ở phía dưới.

Ngoài các ngăn xếp trên mỗi luồng, còn có các ngăn xếp chuyên dụng
được liên kết với mỗi CPU.  Những ngăn xếp này chỉ được sử dụng trong khi kernel
đang kiểm soát CPU đó; khi CPU quay trở lại không gian người dùng
ngăn xếp chuyên dụng không chứa dữ liệu hữu ích.  Các ngăn xếp CPU chính là:

* Ngăn xếp ngắt.  IRQ_STACK_SIZE

Được sử dụng cho các ngắt phần cứng bên ngoài.  Nếu đây là bên ngoài đầu tiên
  ngắt phần cứng (tức là không phải là ngắt phần cứng lồng nhau) thì
  kernel chuyển từ tác vụ hiện tại sang ngăn xếp ngắt.  thích
  ngăn xếp luồng và ngắt trên i386, điều này mang lại nhiều không gian hơn
  để xử lý ngắt kernel mà không cần phải tăng kích thước
  của mỗi ngăn xếp trên mỗi luồng.

Ngăn xếp ngắt cũng được sử dụng khi xử lý một phần mềm.

Việc chuyển sang ngăn xếp ngắt kernel được thực hiện bằng phần mềm dựa trên
trên mỗi bộ đếm tổ ngắt CPU. Điều này là cần thiết vì x86-64 "IST"
ngăn xếp phần cứng không thể lồng nhau nếu không có chủng tộc.

x86_64 cũng có một tính năng không có trên i386, đó là khả năng
để tự động chuyển sang ngăn xếp mới cho các sự kiện được chỉ định như
lỗi kép hoặc NMI, giúp xử lý những lỗi bất thường này dễ dàng hơn
sự kiện trên x86_64.  Tính năng này được gọi là Bảng ngăn xếp ngắt
(IST).  Có thể có tối đa 7 mục IST cho mỗi CPU. Mã IST là một
lập chỉ mục vào Phân đoạn trạng thái nhiệm vụ (TSS). Các mục IST trong TSS
trỏ đến ngăn xếp chuyên dụng; mỗi ngăn xếp có thể có kích thước khác nhau.

IST được chọn bởi giá trị khác 0 trong trường IST của một
mô tả cổng ngắt.  Khi một sự gián đoạn xảy ra và phần cứng
tải một bộ mô tả như vậy, phần cứng sẽ tự động thiết lập ngăn xếp mới
con trỏ dựa trên giá trị IST, sau đó gọi trình xử lý ngắt.  Nếu
ngắt đến từ chế độ người dùng, sau đó là phần mở đầu của trình xử lý ngắt
sẽ chuyển trở lại ngăn xếp trên mỗi luồng.  Nếu phần mềm muốn cho phép
các ngắt IST lồng nhau thì trình xử lý phải điều chỉnh các giá trị IST trên
vào và thoát khỏi trình xử lý ngắt.  (Việc này thỉnh thoảng
xong, ví dụ: để biết các ngoại lệ gỡ lỗi.)

Các sự kiện có mã IST khác nhau (tức là có các ngăn xếp khác nhau) có thể
lồng nhau.  Ví dụ: một ngắt gỡ lỗi có thể bị gián đoạn một cách an toàn bởi một
NMI.  Arch/x86_64/kernel/entry.S::paranoidentry điều chỉnh ngăn xếp
con trỏ vào và thoát khỏi tất cả các sự kiện IST, về mặt lý thuyết cho phép
Các sự kiện IST có cùng mã sẽ được lồng vào nhau.  Tuy nhiên trong hầu hết các trường hợp,
kích thước ngăn xếp được phân bổ cho IST giả định không có lồng nhau cho cùng một mã.
Nếu giả định đó bị phá vỡ thì ngăn xếp sẽ bị hỏng.

Các ngăn xếp IST hiện được chỉ định là:

*ESTACK_DF.  EXCEPTION_STKSZ (PAGE_SIZE).

Được sử dụng cho ngắt 8 - Ngoại lệ lỗi kép (#DF).

Được gọi khi xử lý một ngoại lệ gây ra một ngoại lệ khác. xảy ra
  khi kernel rất bối rối (ví dụ: con trỏ ngăn xếp kernel bị hỏng).
  Sử dụng một ngăn xếp riêng biệt cho phép kernel phục hồi đủ tốt
  trong nhiều trường hợp vẫn đưa ra lỗi rất tiếc.

*ESTACK_NMI.  EXCEPTION_STKSZ (PAGE_SIZE).

Được sử dụng cho các ngắt không thể che được (NMI).

NMI có thể được phân phối bất cứ lúc nào, kể cả khi kernel ở trong
  giữa các ngăn xếp chuyển đổi.  Sử dụng IST cho các sự kiện NMI sẽ tránh được việc thực hiện
  giả định về trạng thái trước đó của ngăn xếp hạt nhân.

*ESTACK_DB.  EXCEPTION_STKSZ (PAGE_SIZE).

Được sử dụng cho các ngắt gỡ lỗi phần cứng (ngắt 1) và cho phần mềm
  ngắt gỡ lỗi (INT3).

Khi gỡ lỗi kernel, việc gỡ lỗi sẽ bị gián đoạn (cả phần cứng và
  phần mềm) có thể xảy ra bất cứ lúc nào.  Sử dụng IST cho các ngắt này
  tránh đưa ra các giả định về trạng thái trước đó của kernel
  ngăn xếp.

Để xử lý chính xác #DB lồng nhau, tồn tại hai phiên bản ngăn xếp DB. Bật
  Mục nhập #DB, con trỏ xếp chồng IST cho #DB được chuyển sang phiên bản thứ hai
  vì vậy #DB lồng nhau bắt đầu từ một ngăn xếp sạch. Các công tắc #DB lồng nhau
  con trỏ ngăn xếp IST tới lỗ bảo vệ để bắt ba lần lồng nhau.

*ESTACK_MCE.  EXCEPTION_STKSZ (PAGE_SIZE).

Được sử dụng cho ngắt 18 - Ngoại lệ kiểm tra máy (#MC).

MCE có thể được phân phối bất cứ lúc nào, kể cả khi kernel ở trong
  giữa các ngăn xếp chuyển đổi.  Sử dụng IST cho các sự kiện MCE sẽ tránh được việc thực hiện
  giả định về trạng thái trước đó của ngăn xếp hạt nhân.

Để biết thêm chi tiết, hãy xem hướng dẫn sử dụng kiến ​​trúc Intel IA32 hoặc AMD AMD64.


In dấu vết trên x86
==========================

Câu hỏi về '?' tên hàm trước trong stacktrace x86
tiếp tục xuất hiện, đây là một lời giải thích sâu sắc. Sẽ có ích nếu người đọc
nhìn chằm chằm vào print_context_stack() và toàn bộ máy móc trong và xung quanh
Arch/x86/kernel/dumpstack.c.

Chuyển thể từ thư của Ingo, Message-ID: <20150521101614.GA10889@gmail.com>:

Chúng tôi luôn quét toàn bộ ngăn xếp hạt nhân để tìm địa chỉ trả về được lưu trữ trên
(các) ngăn xếp hạt nhân [1]_, từ đỉnh ngăn xếp đến đáy ngăn xếp và in ra
bất cứ thứ gì 'trông giống' là địa chỉ văn bản hạt nhân.

Nếu nó vừa với chuỗi con trỏ khung, chúng tôi sẽ in nó mà không cần hỏi
đánh dấu, biết rằng đó là một phần của vết lùi thực sự.

Nếu địa chỉ không khớp với chuỗi con trỏ khung mong đợi của chúng ta, chúng ta
vẫn in nó, nhưng chúng tôi in một '?'. Nó có thể có nghĩa là hai điều:

- địa chỉ đó không phải là một phần của chuỗi cuộc gọi: địa chỉ đó đã cũ
   các giá trị trên ngăn xếp kernel, từ các lệnh gọi hàm trước đó. Đây là
   trường hợp chung.

- hoặc nó là một phần của chuỗi cuộc gọi, nhưng con trỏ khung chưa được đặt
   lên đúng trong hàm nên chúng ta không nhận ra nó.

Bằng cách này, chúng ta sẽ luôn in ra chuỗi cuộc gọi thực (cộng thêm một vài
mục), bất kể con trỏ khung có được thiết lập chính xác hay không
hoặc không - nhưng trong hầu hết các trường hợp, chúng tôi cũng sẽ thực hiện đúng chuỗi cuộc gọi. các
các mục được in hoàn toàn theo thứ tự xếp chồng, vì vậy bạn có thể suy ra nhiều hơn
thông tin cũng từ đó.

Thuộc tính quan trọng nhất của phương pháp này là chúng ta _không bao giờ_ mất
thông tin: chúng tôi luôn cố gắng in _all_ địa chỉ trên (các) ngăn xếp
trông giống như địa chỉ văn bản kernel, vì vậy nếu thông tin gỡ lỗi sai,
chúng tôi vẫn in ra chuỗi cuộc gọi thực - chỉ với nhiều câu hỏi hơn
điểm hơn lý tưởng.

.. [1] For things like IRQ and IST stacks, we also scan those stacks, in
       the right order, and try to cross from one stack into another
       reconstructing the call chain. This works most of the time.