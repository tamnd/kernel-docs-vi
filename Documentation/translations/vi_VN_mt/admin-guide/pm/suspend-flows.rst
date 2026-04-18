.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/pm/suspend-flows.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===========================
Hệ thống tạm dừng dòng mã
===========================

:Bản quyền: ZZ0000ZZ 2020 Tập đoàn Intel

:Tác giả: Rafael J. Wysocki <rafael.j.wysocki@intel.com>

Ít nhất một quá trình chuyển đổi toàn hệ thống toàn cầu cần được thực hiện cho
hệ thống để chuyển từ trạng thái làm việc sang một trong những hệ thống được hỗ trợ
ZZ0000ZZ.  Ngủ đông đòi hỏi nhiều hơn một
quá trình chuyển đổi xảy ra vì mục đích này, nhưng các trạng thái ngủ khác, thường
được gọi là trạng thái ZZ0001ZZ (hoặc đơn giản là ZZ0002ZZ), cần
chỉ có một.

Đối với những trạng thái ngủ đó, việc chuyển từ trạng thái làm việc của hệ thống sang
trạng thái ngủ mục tiêu cũng được gọi là ZZ0000ZZ (trong phần lớn
trong các trường hợp, cho dù điều này có nghĩa là trạng thái chuyển tiếp hay trạng thái ngủ của hệ thống sẽ
rõ ràng trong bối cảnh) và sự chuyển đổi trở lại từ trạng thái ngủ sang trạng thái
trạng thái làm việc được gọi là ZZ0001ZZ.

Các luồng mã hạt nhân liên quan đến quá trình chuyển đổi tạm dừng và tiếp tục cho
các trạng thái ngủ khác nhau của hệ thống khá giống nhau, nhưng có một số
sự khác biệt đáng kể giữa các luồng mã ZZ0000ZZ
và các luồng mã liên quan đến ZZ0001ZZ và
Trạng thái ngủ của ZZ0002ZZ.

Trạng thái ngủ của ZZ0000ZZ và ZZ0001ZZ
không thể triển khai nếu không có sự hỗ trợ của nền tảng và sự khác biệt giữa chúng
tập trung vào các hành động dành riêng cho nền tảng được thực hiện bởi việc đình chỉ và
tiếp tục các móc cần được trình điều khiển nền tảng cung cấp để tạo chúng
có sẵn.  Ngoài ra, các luồng mã tạm dừng và tiếp tục cho các chế độ ngủ này
các trạng thái hầu hết giống hệt nhau, vì vậy cả hai cùng nhau sẽ được gọi là
ZZ0002ZZ nêu rõ nội dung sau.


.. _s2idle_suspend:

Luồng mã tạm dừng chuyển sang không hoạt động
=================================

Các bước sau đây được thực hiện để chuyển hệ thống từ chế độ làm việc
chuyển sang trạng thái ngủ ZZ0000ZZ:

1. Gọi trình thông báo tạm dừng trên toàn hệ thống.

Các hệ thống con hạt nhân có thể đăng ký các cuộc gọi lại để được gọi khi tạm dừng
    quá trình chuyển đổi sắp xảy ra và khi quá trình chuyển đổi tiếp tục kết thúc.

Điều đó cho phép họ chuẩn bị cho sự thay đổi trạng thái hệ thống và làm sạch
    lên sau khi trở lại trạng thái làm việc.

2. Nhiệm vụ đóng băng.

Các tác vụ được đóng băng chủ yếu để tránh truy cập phần cứng không được kiểm tra
    từ không gian người dùng thông qua các vùng MMIO hoặc các thanh ghi I/O được hiển thị trực tiếp tới
    nó và để ngăn không gian người dùng vào kernel trong khi bước tiếp theo
    quá trình chuyển đổi đang diễn ra (điều này có thể gây khó khăn cho
    nhiều lý do khác nhau).

Tất cả các tác vụ trong không gian của người dùng đều bị chặn như thể chúng được gửi tín hiệu và
    đưa vào giấc ngủ liên tục cho đến khi kết thúc hệ thống tiếp theo
    chuyển tiếp.

Các luồng nhân chọn bị đóng băng trong quá trình tạm dừng hệ thống trong
    Những lý do cụ thể sau đó sẽ bị đóng băng, nhưng chúng không bị chặn.
    Thay vào đó, họ phải định kỳ kiểm tra xem họ có cần
    nếu vậy sẽ bị đóng băng và đưa mình vào giấc ngủ không ngừng nghỉ.  [Lưu ý,
    tuy nhiên, các luồng nhân đó có thể sử dụng khóa và các điều khiển tương tranh khác
    có sẵn trong không gian kernel để tự đồng bộ hóa với hệ thống tạm dừng và
    tiếp tục, có thể chính xác hơn nhiều so với việc đóng băng, vì vậy cái sau là
    không phải là một tùy chọn được đề xuất cho các luồng nhân.]

3. Tạm dừng thiết bị và cấu hình lại IRQ.

Các thiết bị bị treo theo bốn giai đoạn gọi là ZZ0001ZZ, ZZ0002ZZ,
    ZZ0003ZZ và ZZ0004ZZ (xem ZZ0000ZZ để biết thêm
    thông tin về những gì chính xác xảy ra trong từng giai đoạn).

Mọi thiết bị đều được truy cập trong từng giai đoạn, nhưng thông thường nó không được truy cập về mặt vật lý
    được truy cập ở nhiều hơn hai trong số đó.

Thời gian chạy PM API bị tắt đối với mọi thiết bị trong thời gian tạm dừng ZZ0000ZZ
    các trình xử lý ngắt pha và cấp cao ("hành động") bị ngăn chặn
    được gọi trước giai đoạn tạm dừng ZZ0001ZZ.

Các ngắt vẫn được xử lý sau đó, nhưng chúng chỉ được xác nhận bởi
    bộ điều khiển ngắt mà không thực hiện bất kỳ hành động cụ thể nào của thiết bị
    sẽ được kích hoạt trong trạng thái làm việc của hệ thống (những hành động đó được
    hoãn lại cho đến khi hệ thống tiếp theo tiếp tục quá trình chuyển đổi như mô tả
    ZZ0000ZZ).

IRQ liên quan đến thiết bị đánh thức hệ thống được "trang bị" để tiếp tục
    quá trình chuyển đổi của hệ thống được bắt đầu khi một trong số chúng báo hiệu một sự kiện.

4. Đóng băng lịch đánh dấu và tạm dừng chấm công.

Khi tất cả các thiết bị đã bị treo, CPU sẽ vào vòng lặp nhàn rỗi và được đặt
    vào trạng thái nhàn rỗi sâu nhất hiện có.  Trong khi làm việc đó, mỗi người trong số họ
    "đóng băng" đánh dấu lịch trình của chính nó để các sự kiện hẹn giờ liên quan đến
    tiếng tích tắc không xảy ra cho đến khi CPU được đánh thức bởi một nguồn ngắt khác.

CPU cuối cùng chuyển sang trạng thái không hoạt động cũng dừng việc chấm công, điều này
    (trong số những thứ khác) ngăn không cho bộ hẹn giờ có độ phân giải cao kích hoạt
    chuyển tiếp cho đến khi CPU đầu tiên được đánh thức sẽ khởi động lại giờ hiện hành.
    Điều đó cho phép CPU duy trì ở trạng thái không hoạt động tương đối lâu trong một
    đi.

Từ thời điểm này trở đi, CPU chỉ có thể được đánh thức bằng phần cứng không hẹn giờ
    ngắt quãng.  Nếu điều đó xảy ra, chúng sẽ quay trở lại trạng thái không hoạt động trừ khi
    sự gián đoạn đánh thức một trong số họ đến từ một chiếc IRQ đã được trang bị cho
    đánh thức hệ thống, trong trường hợp đó quá trình chuyển đổi tiếp tục hệ thống được bắt đầu.


.. _s2idle_resume:

Luồng mã tiếp tục tạm dừng để không hoạt động
================================

Các bước sau đây được thực hiện để chuyển đổi hệ thống từ
ZZ0000ZZ trạng thái ngủ sang trạng thái làm việc:

1. Tiếp tục chấm công và giải phóng dấu tích của bộ lập lịch.

Khi một trong các CPU được đánh thức (do ngắt phần cứng không hẹn giờ), nó
    rời khỏi trạng thái không hoạt động đã nhập ở bước cuối cùng của lần tạm dừng trước đó
    chuyển đổi, khởi động lại giờ hiện hành (trừ khi nó đã được khởi động lại rồi
    bởi một CPU khác đã thức dậy sớm hơn) và bộ lập lịch đánh dấu vào CPU đó là
    rã đông.

Nếu ngắt đã đánh thức thì CPU được trang bị để đánh thức hệ thống,
    quá trình chuyển đổi tiếp tục của hệ thống bắt đầu.

2. Khôi phục thiết bị và khôi phục cấu hình trạng thái làm việc của IRQ.

Các thiết bị được nối lại theo bốn giai đoạn gọi là ZZ0001ZZ, ZZ0002ZZ,
    ZZ0003ZZ và ZZ0004ZZ (xem ZZ0000ZZ để biết thêm
    thông tin về những gì chính xác xảy ra trong từng giai đoạn).

Mọi thiết bị đều được truy cập trong từng giai đoạn, nhưng thông thường nó không được truy cập về mặt vật lý
    được truy cập ở nhiều hơn hai trong số đó.

Cấu hình trạng thái làm việc của IRQ được khôi phục sau khi tiếp tục ZZ0000ZZ
    pha và thời gian chạy PM API được kích hoạt lại cho mọi thiết bị có trình điều khiển
    hỗ trợ nó trong giai đoạn tiếp tục ZZ0001ZZ.

3. Nhiệm vụ rã đông.

Nhiệm vụ bị cố định ở bước 2 của ZZ0000ZZ trước đó
    quá trình chuyển đổi được "tan băng", có nghĩa là chúng được đánh thức từ
    giấc ngủ liên tục mà họ đã trải qua vào thời điểm đó và các nhiệm vụ trong không gian người dùng
    được phép thoát khỏi kernel.

4. Gọi trình thông báo sơ yếu lý lịch trên toàn hệ thống.

Điều này tương tự với bước 1 của quá trình chuyển đổi ZZ0000ZZ
    và cùng một tập hợp lệnh gọi lại được gọi vào thời điểm này, nhưng một tập hợp khác
    Giá trị tham số "loại thông báo" được chuyển cho họ.


Luồng mã tạm dừng phụ thuộc vào nền tảng
====================================

Các bước sau đây được thực hiện để chuyển hệ thống từ chế độ làm việc
chuyển sang trạng thái tạm dừng phụ thuộc vào nền tảng:

1. Gọi trình thông báo tạm dừng trên toàn hệ thống.

Bước này giống như bước 1 của quá trình chuyển đổi tạm dừng sang không hoạt động
    được mô tả ZZ0000ZZ.

2. Nhiệm vụ đóng băng.

Bước này giống như bước 2 của quá trình chuyển đổi tạm dừng sang không hoạt động
    được mô tả ZZ0000ZZ.

3. Tạm dừng thiết bị và cấu hình lại IRQ.

Bước này tương tự như bước 3 của quá trình chuyển đổi tạm dừng sang không hoạt động
    đã mô tả ZZ0000ZZ, nhưng việc trang bị IRQ cho hệ thống
    Wakeup thường không có bất kỳ ảnh hưởng nào đến nền tảng.

Có những nền tảng có thể chuyển sang trạng thái năng lượng thấp rất sâu trong nội bộ
    khi tất cả CPU trong chúng ở trạng thái nhàn rỗi đủ sâu và tất cả I/O
    các thiết bị đã được đưa vào trạng thái năng lượng thấp.  Trên các nền tảng đó,
    tạm dừng để không hoạt động có thể làm giảm sức mạnh hệ thống rất hiệu quả.

Tuy nhiên, trên các nền tảng khác, các thành phần cấp thấp (như ngắt
    bộ điều khiển) cần phải được tắt theo cách dành riêng cho nền tảng (được triển khai
    trong các móc do bộ điều khiển khung nâng cung cấp) để đạt được công suất tương đương
    giảm bớt.

Điều đó thường ngăn chặn các gián đoạn phần cứng trong băng tần đánh thức hệ thống,
    việc này phải được thực hiện theo cách phụ thuộc vào nền tảng đặc biệt.  Sau đó,
    cấu hình của các nguồn đánh thức hệ thống thường bắt đầu khi hệ thống đánh thức
    các thiết bị bị treo và được hoàn thiện bởi các móc treo của nền tảng sau đó
    trên.

4. Vô hiệu hóa CPU không khởi động được.

Trên một số nền tảng, móc treo được đề cập ở trên phải chạy trong một CPU
    cấu hình của hệ thống (đặc biệt là không thể truy cập phần cứng
    bởi bất kỳ mã nào chạy song song với các móc treo nền tảng có thể,
    và thường làm như vậy, truy cập vào phần sụn của nền tảng để hoàn thiện
    tạm dừng chuyển đổi).

Vì lý do này, khung CPU ngoại tuyến/trực tuyến (CPU hotplug) được sử dụng
    để lấy tất cả các CPU trong hệ thống, ngoại trừ một CPU (CPU khởi động),
    ngoại tuyến (thông thường, các CPU đã được ngoại tuyến sẽ chuyển sang trạng thái không hoạt động
    tiểu bang).

Điều này có nghĩa là tất cả các tác vụ sẽ được di chuyển khỏi các CPU đó và tất cả các IRQ đều được
    định tuyến lại đến CPU duy nhất vẫn trực tuyến.

5. Đình chỉ các thành phần hệ thống cốt lõi.

Điều này chuẩn bị cho các thành phần hệ thống cốt lõi (có thể) bị mất điện
    chuyển tiếp và tạm dừng việc chấm công.

6. Loại bỏ nguồn điện dành riêng cho nền tảng.

Điều này dự kiến sẽ loại bỏ nguồn điện khỏi tất cả các thành phần hệ thống ngoại trừ
    cho bộ điều khiển bộ nhớ và RAM (để bảo toàn nội dung của
    sau) và một số thiết bị được chỉ định để đánh thức hệ thống.

Trong nhiều trường hợp, quyền điều khiển được chuyển tới phần sụn nền tảng được mong đợi
    để hoàn tất quá trình chuyển đổi tạm dừng khi cần thiết.


Luồng mã tiếp tục phụ thuộc vào nền tảng
===================================

Các bước sau đây được thực hiện để chuyển đổi hệ thống từ
trạng thái tạm dừng phụ thuộc vào nền tảng sang trạng thái làm việc:

1. Đánh thức hệ thống dành riêng cho nền tảng.

Nền tảng được đánh thức bởi tín hiệu từ một trong các hệ thống được chỉ định
    thiết bị đánh thức (không cần phải ngắt phần cứng trong băng tần) và
    điều khiển được chuyển trở lại kernel (cấu hình hoạt động của
    nền tảng có thể cần được khôi phục bằng chương trình cơ sở của nền tảng trước khi
    kernel được kiểm soát lại).

2. Tiếp tục các thành phần hệ thống cốt lõi.

Cấu hình thời gian tạm dừng của các thành phần hệ thống cốt lõi được khôi phục và
    việc chấm công được tiếp tục.

3. Kích hoạt lại CPU không khởi động được.

Các CPU bị vô hiệu hóa ở bước 4 của quá trình chuyển đổi tạm dừng trước đó sẽ được thực hiện
    trở lại trực tuyến và cấu hình thời gian tạm dừng của họ được khôi phục.

4. Khôi phục thiết bị và khôi phục cấu hình trạng thái làm việc của IRQ.

Bước này giống như bước 2 của quá trình chuyển đổi tạm dừng sang không hoạt động
    được mô tả ZZ0000ZZ.

5. Nhiệm vụ rã đông.

Bước này giống như bước 3 của quá trình chuyển đổi tạm dừng sang không hoạt động
    được mô tả ZZ0000ZZ.

6. Gọi trình thông báo sơ yếu lý lịch trên toàn hệ thống.

Bước này giống như bước 4 của quá trình chuyển đổi tạm dừng sang không hoạt động
    được mô tả ZZ0000ZZ.