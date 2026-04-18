.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/timers/highres.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Bộ hẹn giờ có độ phân giải cao và ghi chú thiết kế đánh dấu động
================================================================

Thông tin thêm có thể được tìm thấy trong bài nói chuyện OLS 2006 "hrtimers
và hơn thế nữa". Bài viết này là một phần của Kỷ yếu OLS 2006 Tập 1, có thể
được tìm thấy trên trang web OLS:
ZZ0000ZZ

Các slide của bài nói chuyện này có sẵn từ:
ZZ0000ZZ

Các slide có năm hình (trang 2, 15, 18, 20, 22), minh họa
những thay đổi trong các hệ thống con Linux liên quan đến thời gian. Hình #1 (tr. 2) hiển thị
thiết kế hệ thống thời gian (r) Linux trước giờ làm việc và các khối xây dựng khác
đã sáp nhập vào dòng chính.

Lưu ý: bài báo và các slide đang nói về "nguồn sự kiện đồng hồ", trong khi chúng ta
trong khi đó đã chuyển sang tên "thiết bị sự kiện đồng hồ".

Thiết kế bao gồm các khối xây dựng cơ bản sau:

- cơ sở hạ tầng cơ sở hrtimer
- quản lý nguồn thời gian trong ngày và đồng hồ
- quản lý sự kiện đồng hồ
- chức năng hẹn giờ độ phân giải cao
- tích tắc năng động


cơ sở hạ tầng cơ sở hrtimer
---------------------------

Cơ sở hạ tầng cơ sở hrtimer đã được hợp nhất vào kernel 2.6.16. Chi tiết về
việc triển khai cơ sở được đề cập trong Documentation/timers/hrtimers.rst. Xem
cũng hình #2 (OLS slide trang 15)

Sự khác biệt chính đối với bánh xe hẹn giờ, loại chứa loại time_list được trang bị vũ khí
đồng hồ tính giờ là:

- thời gian ra lệnh xếp hàng vào cây rb
       - độc lập với tích tắc (quá trình xử lý dựa trên nano giây)


quản lý nguồn thời gian trong ngày và đồng hồ
-------------------------------------

Khung thời gian chung trong ngày (GTOD) của John Stultz di chuyển phần lớn
mã hóa từ các khu vực kiến trúc cụ thể thành một khu vực quản lý chung
framework, như được minh họa trong hình #3 (OLS slide trang 18). Kiến trúc
phần cụ thể được giảm xuống các chi tiết phần cứng cấp thấp của đồng hồ
các nguồn được đăng ký trong khuôn khổ và được lựa chọn dựa trên chất lượng
quyết định. Mã cấp thấp cung cấp các quy trình đọc và thiết lập phần cứng cũng như
khởi tạo cấu trúc dữ liệu, được sử dụng bởi mã lưu giữ thời gian chung để
chuyển đổi tích tắc đồng hồ thành giá trị thời gian dựa trên nano giây. Tất cả việc giữ thời gian khác
chức năng liên quan được chuyển vào mã chung. Bản vá cơ sở GTOD đã có
được sáp nhập vào kernel 2.6.18.

Thông tin thêm về khung Thời gian chung trong ngày có sẵn trong
Kỷ yếu OLS 2005 Tập 1:

ZZ0000ZZ

Bài viết "Chúng ta không còn trẻ nữa: Một cách tiếp cận mới về thời gian và
Bộ hẹn giờ" được viết bởi J. Stultz, D.V. Hart, & N. Aravamudan.

Hình #3 (OLS slide trang 18) minh họa sự chuyển đổi.


quản lý sự kiện đồng hồ
----------------------

Trong khi các nguồn đồng hồ cung cấp quyền truy cập đọc vào thời gian tăng dần một cách đơn điệu
giá trị, các thiết bị sự kiện đồng hồ được sử dụng để lên lịch cho sự kiện tiếp theo
(các) ngắt. Sự kiện tiếp theo hiện được xác định là định kỳ, với
khoảng thời gian được xác định tại thời điểm biên dịch. Thiết lập và lựa chọn thiết bị sự kiện
cho các chức năng điều khiển sự kiện khác nhau được cài đặt sẵn vào kiến trúc
mã phụ thuộc Điều này dẫn đến mã trùng lặp trên tất cả các kiến trúc và
khiến việc thay đổi cấu hình của hệ thống để sử dụng trở nên vô cùng khó khăn
các thiết bị ngắt sự kiện khác với những thiết bị đã được tích hợp sẵn trong
kiến trúc. Một ý nghĩa khác của thiết kế hiện tại là nó cần thiết
chạm vào tất cả các triển khai kiến trúc cụ thể để cung cấp các tính năng mới
chức năng như bộ hẹn giờ có độ phân giải cao hoặc dấu tích động.

Hệ thống con sự kiện đồng hồ cố gắng giải quyết vấn đề này bằng cách cung cấp một
giải pháp quản lý các thiết bị sự kiện đồng hồ và cách sử dụng chúng cho các loại đồng hồ khác nhau
các chức năng hạt nhân hướng sự kiện. Mục tiêu của hệ thống con sự kiện đồng hồ là
để giảm thiểu mã phụ thuộc kiến trúc liên quan đến sự kiện đồng hồ về mức thuần túy
xử lý liên quan đến phần cứng và cho phép dễ dàng bổ sung và sử dụng các phần mềm mới
thiết bị sự kiện đồng hồ. Nó cũng giảm thiểu mã trùng lặp trên toàn bộ
kiến trúc vì nó cung cấp chức năng chung cho tới ngắt
trình xử lý dịch vụ, vốn gần như phụ thuộc vào phần cứng.

Các thiết bị sự kiện đồng hồ được đăng ký bằng cách khởi động phụ thuộc vào kiến trúc
mã hoặc tại thời điểm chèn mô-đun. Mỗi thiết bị sự kiện đồng hồ sẽ điền vào một dữ liệu
cấu trúc với các tham số thuộc tính đồng hồ cụ thể và các chức năng gọi lại. các
quản lý sự kiện đồng hồ quyết định, bằng cách sử dụng các tham số thuộc tính được chỉ định,
tập hợp các chức năng hệ thống mà thiết bị sự kiện đồng hồ sẽ được sử dụng để hỗ trợ. Cái này
bao gồm sự khác biệt giữa các thiết bị sự kiện toàn cầu trên mỗi CPU và trên mỗi hệ thống.

Các thiết bị sự kiện toàn cầu cấp hệ thống được sử dụng để đánh dấu định kỳ Linux. Mỗi CPU
các thiết bị sự kiện được sử dụng để cung cấp chức năng CPU cục bộ như xử lý
kế toán, lập hồ sơ và bộ đếm thời gian có độ phân giải cao.

Lớp quản lý gán một hoặc nhiều chức năng sau cho đồng hồ
thiết bị sự kiện:

- hệ thống đánh dấu định kỳ toàn cầu (cập nhật jiffies)
      - cập nhật cục bộ cpu_process_times
      - hồ sơ địa phương cpu
      - ngắt sự kiện tiếp theo cục bộ của CPU (chế độ không định kỳ)

Thiết bị sự kiện đồng hồ ủy quyền lựa chọn các ngắt hẹn giờ liên quan đến
hoạt động hoàn toàn đối với lớp quản lý. Lớp quản lý đồng hồ lưu trữ
một con trỏ hàm trong cấu trúc mô tả thiết bị, được gọi là
từ trình xử lý cấp phần cứng. Điều này loại bỏ rất nhiều mã trùng lặp khỏi
trình xử lý ngắt bộ định thời cụ thể theo kiến trúc và trao quyền điều khiển cho
thiết bị sự kiện đồng hồ và phân công chức năng liên quan đến ngắt hẹn giờ
vào mã lõi.

Lớp sự kiện đồng hồ API khá nhỏ. Ngoài thiết bị sự kiện đồng hồ
giao diện đăng ký nó cung cấp các chức năng để lên lịch cho sự kiện tiếp theo
gián đoạn, dịch vụ thông báo thiết bị sự kiện đồng hồ và hỗ trợ tạm dừng và
tiếp tục.

Khung này bổ sung thêm khoảng 700 dòng mã, giúp tăng 2KB dung lượng.
kích thước nhị phân của hạt nhân. Việc chuyển đổi i386 sẽ loại bỏ khoảng 100 dòng
mã. Việc giảm kích thước nhị phân nằm trong phạm vi 400 byte. Chúng tôi tin rằng
tăng tính linh hoạt và tránh mã trùng lặp trên
kiến trúc biện minh cho việc tăng nhẹ kích thước nhị phân.

Việc chuyển đổi một kiến trúc không có tác động về mặt chức năng nhưng cho phép
sử dụng độ phân giải cao và chức năng đánh dấu động mà không có bất kỳ thay đổi nào
đến thiết bị sự kiện đồng hồ và mã ngắt hẹn giờ. Sau khi chuyển đổi
việc bật tính năng hẹn giờ có độ phân giải cao và đánh dấu động được cung cấp đơn giản bởi
thêm tệp kernel/time/Kconfig vào kiến trúc Kconfig cụ thể và
thêm các lệnh gọi cụ thể đánh dấu động vào quy trình nhàn rỗi (tổng cộng 3 dòng
được thêm vào chức năng nhàn rỗi và tệp Kconfig)

Hình #4 (OLS slide p.20) minh họa sự chuyển đổi.


chức năng hẹn giờ độ phân giải cao
-----------------------------------

Trong quá trình khởi động hệ thống, không thể sử dụng bộ hẹn giờ có độ phân giải cao
chức năng, trong khi việc thực hiện nó sẽ khó khăn và sẽ không phục vụ
chức năng hữu ích. Việc khởi tạo khung thiết bị sự kiện đồng hồ,
khung nguồn đồng hồ (GTOD) và bản thân bộ đếm thời gian phải được thực hiện và
nguồn đồng hồ thích hợp và thiết bị sự kiện đồng hồ phải được đăng ký trước
chức năng độ phân giải cao có thể hoạt động. Cho đến thời điểm mà người ta tính giờ
được khởi tạo, hệ thống hoạt động ở chế độ định kỳ có độ phân giải thấp thông thường. các
nguồn đồng hồ và các lớp thiết bị sự kiện đồng hồ cung cấp chức năng thông báo
thông báo cho người tính giờ về sự sẵn có của phần cứng mới. giờ xác nhận
khả năng sử dụng của các nguồn đồng hồ đã đăng ký và các thiết bị sự kiện đồng hồ trước đây
chuyển sang chế độ độ phân giải cao. Điều này cũng đảm bảo rằng một hạt nhân được
được cấu hình cho bộ hẹn giờ có độ phân giải cao có thể chạy trên hệ thống thiếu
hỗ trợ phần cứng cần thiết.

Mã hẹn giờ có độ phân giải cao không hỗ trợ các máy SMP chỉ có
thiết bị sự kiện đồng hồ toàn cầu. Sự hỗ trợ của phần cứng như vậy sẽ liên quan đến IPI
gọi khi có ngắt xảy ra. Chi phí chung sẽ lớn hơn nhiều so với
lợi ích. Đây là lý do tại sao hiện tại chúng tôi vô hiệu hóa độ phân giải cao và
tích tắc động trên các hệ thống i386 SMP làm dừng APIC cục bộ trong nguồn C3
trạng thái. Một cách giải quyết có sẵn dưới dạng ý tưởng, nhưng vấn đề vẫn chưa được giải quyết
đã giải quyết được chưa.

Việc chèn bộ hẹn giờ theo thứ tự thời gian cung cấp tất cả cơ sở hạ tầng để quyết định
liệu thiết bị sự kiện có phải được lập trình lại khi thêm bộ hẹn giờ hay không. các
quyết định được thực hiện trên mỗi cơ sở hẹn giờ và được đồng bộ hóa trên các cơ sở hẹn giờ trên mỗi CPU trong
một chức năng hỗ trợ. Thiết kế cho phép hệ thống sử dụng từng CPU riêng biệt
thiết bị sự kiện đồng hồ cho các cơ sở hẹn giờ trên mỗi CPU, nhưng hiện tại chỉ có một
thiết bị sự kiện đồng hồ có thể lập trình lại trên mỗi CPU được sử dụng.

Khi ngắt hẹn giờ xảy ra, trình xử lý ngắt sự kiện tiếp theo sẽ được gọi
từ mã phân phối sự kiện đồng hồ và di chuyển bộ hẹn giờ đã hết hạn từ
cây đỏ-đen vào một danh sách liên kết đôi riêng biệt và gọi softirq
người xử lý. Trường chế độ bổ sung trong cấu trúc giờ cho phép hệ thống
thực hiện các chức năng gọi lại trực tiếp từ trình xử lý ngắt sự kiện tiếp theo. Cái này
được giới hạn ở mã có thể được thực thi một cách an toàn trong ngắt cứng
bối cảnh. Ví dụ, điều này áp dụng cho trường hợp phổ biến của hàm đánh thức như
được sử dụng bởi nanosleep. Ưu điểm của việc thực thi trình xử lý trong ngắt
bối cảnh là tránh tối đa hai chuyển đổi bối cảnh - từ bị gián đoạn
bối cảnh cho softirq và tác vụ được đánh thức khi hết hạn
hẹn giờ.

Khi hệ thống đã chuyển sang chế độ phân giải cao, dấu tích định kỳ là
đã tắt. Điều này vô hiệu hóa thiết bị sự kiện đồng hồ định kỳ toàn cầu trên mỗi hệ thống -
ví dụ: PIT trên hệ thống i386 SMP.

Chức năng đánh dấu định kỳ được cung cấp bởi bộ đếm thời gian trên mỗi CPU. Cuộc gọi lại
hàm được thực thi trong bối cảnh ngắt sự kiện tiếp theo và cập nhật nhanh chóng
và gọi update_process_times và lược tả. Việc thực hiện đồng hồ giờ
đánh dấu định kỳ dựa trên được thiết kế để mở rộng với chức năng đánh dấu động.
Điều này cho phép sử dụng một thiết bị sự kiện đồng hồ duy nhất để lên lịch độ phân giải cao
hẹn giờ và các sự kiện định kỳ (tích tắc nhanh, lập hồ sơ, tính toán quy trình) trên UP
hệ thống. Điều này đã được chứng minh là có hiệu quả với PIT trên i386 và Bộ tăng tốc
trên PPC.

Softirq để chạy hàng đợi giờ và thực hiện các cuộc gọi lại đã được
tách biệt khỏi phần mềm hẹn giờ giới hạn đánh dấu để cho phép phân phối chính xác mức cao
tín hiệu hẹn giờ có độ phân giải được sử dụng bởi bộ đếm thời gian và khoảng thời gian POSIX
đồng hồ bấm giờ. Việc thực thi softirq này vẫn có thể bị trì hoãn bởi các softirq khác,
nhưng độ trễ tổng thể đã được cải thiện đáng kể nhờ sự tách biệt này.

Hình #5 (OLS slide p.22) minh họa sự chuyển đổi.


tích tắc năng động
-------------

Đánh dấu động là kết quả hợp lý của đánh dấu định kỳ dựa trên giờ
thay thế (lịch_tick). Chức năng của sched_tick hrtimer là
mở rộng bởi ba chức năng:

- hrtimer_stop_sched_tick
- giờ_restart_sched_tick
- hrtimer_update_jiffies

hrtimer_stop_sched_tick() được gọi khi CPU chuyển sang trạng thái không hoạt động. Mã
đánh giá sự kiện hẹn giờ được lên lịch tiếp theo (từ cả đồng hồ tính giờ và đồng hồ hẹn giờ
bánh xe) và trong trường hợp sự kiện tiếp theo ở xa hơn sự kiện tiếp theo, hãy đánh dấu vào đó
lập trình lại sched_tick cho sự kiện trong tương lai này để cho phép thời gian ngủ không hoạt động lâu hơn
không bị gián đoạn vô ích bởi tiếng tích tắc định kỳ. Chức năng này cũng
được gọi khi một ngắt xảy ra trong thời gian nhàn rỗi, điều này không gây ra
lên lịch lại. Cuộc gọi là cần thiết vì trình xử lý ngắt có thể đã trang bị một
bộ đếm thời gian mới có thời gian hết hạn trước thời điểm được xác định là
sự kiện gần nhất trong lệnh gọi trước tới hrtimer_stop_sched_tick.

hrtimer_restart_sched_tick() được gọi khi CPU rời khỏi trạng thái không hoạt động trước đó
nó gọi lịch trình(). hrtimer_restart_sched_tick() tiếp tục đánh dấu định kỳ,
được duy trì hoạt động cho đến cuộc gọi tiếp theo tới hrtimer_stop_sched_tick().

hrtimer_update_jiffies() được gọi từ irq_enter() khi xảy ra gián đoạn
trong thời gian nhàn rỗi để đảm bảo rằng các jiffies được cập nhật và sự gián đoạn
trình xử lý không phải xử lý một giá trị nhanh chóng cũ kỹ.

Tính năng đánh dấu động cung cấp các giá trị thống kê được xuất sang
không gian người dùng thông qua /proc/stat và có thể được cung cấp để tăng cường sức mạnh
kiểm soát quản lý.

Việc triển khai còn chỗ cho sự phát triển hơn nữa như hoàn toàn tích tắc
các hệ thống, trong đó lát thời gian được điều khiển bởi bộ lập lịch, biến
lập hồ sơ tần số và loại bỏ hoàn toàn tình trạng giật hình trong tương lai.


Ngoài việc gửi hỗ trợ i386 ban đầu hiện tại, bản vá đã được
đã mở rộng lên x86_64 và ARM rồi. Hỗ trợ ban đầu (đang tiến hành) cũng là
có sẵn cho MIPS và PowerPC.

Thomas, Ingo
