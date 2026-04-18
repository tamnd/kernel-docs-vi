.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/callbacks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
(Un) vá các cuộc gọi lại
========================

Livepatch (un)patch-callbacks cung cấp cơ chế cho các mô-đun livepatch
để thực thi các chức năng gọi lại khi một đối tượng kernel được vá (chưa).  Họ
có thể coi là ZZ0000ZZ mà ZZ0001ZZ
bao gồm:

- Cập nhật an toàn dữ liệu toàn cầu

- "Bản vá" cho các chức năng khởi tạo và thăm dò

- Vá các mã không thể vá được (tức là lắp ráp)

Trong hầu hết các trường hợp, các lệnh gọi lại bản vá (un) sẽ cần được sử dụng kết hợp
với các rào cản bộ nhớ và các nguyên tắc đồng bộ hóa hạt nhân, như
mutexes/spinlocks hoặc thậm chí stop_machine() để tránh các vấn đề tương tranh.

1. Động lực
=============

Cuộc gọi lại khác với các cơ sở hạt nhân hiện có:

- Mã khởi tạo/thoát mô-đun không chạy khi tắt và bật lại mô-đun
    vá.

- Trình thông báo mô-đun không thể ngăn mô-đun được vá tải.

Lệnh gọi lại là một phần của cấu trúc klp_object và cách triển khai chúng
dành riêng cho klp_object đó.  Các đối tượng livepatch khác có thể có hoặc không
được vá, bất kể trạng thái hiện tại của klp_object mục tiêu.

2. Các kiểu gọi lại
===================

Cuộc gọi lại có thể được đăng ký cho các hành động livepatch sau:

* Bản vá trước
                 - trước khi klp_object được vá

* Sau bản vá
                 - sau khi klp_object đã được vá và hoạt động
                   trên tất cả các nhiệm vụ

* Trước khi gỡ lỗi
                 - trước khi klp_object chưa được vá (tức là mã được vá là
                   đang hoạt động), được sử dụng để dọn dẹp cuộc gọi lại sau bản vá
                   tài nguyên

* Sau khi gỡ lỗi
                 - sau khi klp_object được vá, tất cả mã đều có
                   đã được khôi phục và không có tác vụ nào đang chạy mã đã vá,
                   được sử dụng để dọn sạch tài nguyên gọi lại bản vá trước

3. Cách thức hoạt động
======================

Mỗi cuộc gọi lại là tùy chọn, việc bỏ qua một cuộc gọi lại không loại trừ việc chỉ định bất kỳ cuộc gọi lại nào
khác.  Tuy nhiên, lõi livepatching thực thi các trình xử lý trong
tính đối xứng: các lệnh gọi lại trước bản vá có một bản sao sau bản vá và
các lệnh gọi lại sau bản vá có một bản sao trước khi chưa vá.  Một bản gỡ lỗi
cuộc gọi lại sẽ chỉ được thực hiện nếu cuộc gọi lại bản vá tương ứng của nó được thực hiện
bị xử tử.  Các trường hợp sử dụng điển hình kết hợp một trình xử lý bản vá để thu thập và
định cấu hình tài nguyên bằng trình xử lý chưa vá lỗi và giải phóng
những tài nguyên tương tự.

Lệnh gọi lại chỉ được thực thi nếu máy chủ klp_object của nó được tải.  cho
các mục tiêu vmlinux trong kernel, điều này có nghĩa là các cuộc gọi lại sẽ luôn thực thi
khi bản vá trực tiếp được bật/tắt.  Đối với các mô-đun hạt nhân mục tiêu vá lỗi,
cuộc gọi lại sẽ chỉ thực thi nếu mô-đun đích được tải.  Khi một
mục tiêu mô-đun được (không) được tải, các lệnh gọi lại của nó sẽ chỉ thực thi nếu
mô-đun livepatch được kích hoạt.

Lệnh gọi lại bản vá trước, nếu được chỉ định, dự kiến sẽ trả về trạng thái
mã (0 là thành công, -ERRNO có lỗi).  Mã trạng thái lỗi cho biết
đối với lõi bản vá trực tiếp thì việc vá klp_object hiện tại không được
an toàn và dừng yêu cầu vá lỗi hiện tại.  (Khi không có bản vá trước
cuộc gọi lại được cung cấp, quá trình chuyển đổi được coi là an toàn.) Nếu một
lệnh gọi lại bản vá trước trả về lỗi, trình tải mô-đun của hạt nhân sẽ:

- Từ chối tải bản livepatch nếu bản livepatch được tải sau
    mã mục tiêu.

hoặc:

- Từ chối tải mô-đun nếu bản vá trực tiếp đã thành công
    đã tải.

Sẽ không có lệnh gọi lại sau bản vá, trước khi gỡ bản vá hoặc sau khi hủy bản vá nào được thực thi
đối với một klp_object nhất định nếu đối tượng không thể vá được, do lỗi
gọi lại pre_patch hoặc vì bất kỳ lý do nào khác.

Nếu quá trình chuyển đổi bản vá bị đảo ngược, sẽ không có trình xử lý trước khi hủy bản vá nào được chạy
(điều này tuân theo tính đối xứng đã đề cập trước đó -- lệnh gọi lại trước khi hủy bản vá
sẽ chỉ xảy ra nếu cuộc gọi lại sau bản vá tương ứng của họ được thực hiện).

Nếu đối tượng đã vá thành công nhưng quá trình chuyển đổi bản vá không bao giờ
bắt đầu vì lý do nào đó (ví dụ: nếu một đối tượng khác không vá được),
chỉ cuộc gọi lại sau khi hủy bản vá sẽ được gọi.

4. Các trường hợp sử dụng
=========================

Bạn có thể tìm thấy các mô-đun bản vá trực tiếp mẫu thể hiện lệnh gọi lại API trong
thư mục mẫu/livepatch/.  Những mẫu này đã được sửa đổi để sử dụng trong
kselftests và có thể được tìm thấy trong thư mục lib/livepatch.

Cập nhật dữ liệu toàn cầu
-------------------------

Lệnh gọi lại trước bản vá có thể hữu ích để cập nhật biến toàn cục.  cho
ví dụ: cam kết 75ff39ccc1bd ("tcp: làm cho các thách thức trở nên khó dự đoán hơn")
thay đổi sysctl toàn cầu, cũng như vá lỗi tcp_send_challenge_ack()
chức năng.

Trong trường hợp này, nếu chúng ta quá hoang tưởng, có lẽ sẽ hợp lý hơn nếu chúng ta
vá dữ liệu Bản vá ZZ0000ZZ hoàn tất với lệnh gọi lại sau bản vá,
để tcp_send_challenge_ack() trước tiên có thể được thay đổi thành đọc
sysctl_tcp_challenge_ack_limit với READ_ONCE.

Hỗ trợ các bản vá chức năng __init và thăm dò
---------------------------------------------

Mặc dù các hàm __init và thăm dò không thể phát trực tiếp được, nhưng nó
có thể thực hiện các cập nhật tương tự thông qua bản vá trước/sau
cuộc gọi lại.

Cam kết 48900cb6af42 ("virtio-net: drop NETIF_F_FRAGLIST") thay đổi cách
virtnet_probe() đã khởi tạo các tính năng net_device của trình điều khiển.  A
lệnh gọi lại trước/sau bản vá có thể lặp lại trên tất cả các thiết bị như vậy, tạo ra một
thay đổi tương tự với giá trị hw_features của chúng.  (Chức năng khách hàng của
giá trị có thể cần phải được cập nhật tương ứng.)
