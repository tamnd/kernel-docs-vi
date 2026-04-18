.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mhi/mhi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
MHI (Giao diện máy chủ Modem)
==========================

Tài liệu này cung cấp thông tin về giao thức MHI.

Tổng quan
========

MHI là giao thức được phát triển bởi Qualcomm Innovation Center, Inc. Nó được sử dụng
bởi bộ xử lý máy chủ để điều khiển và liên lạc với các thiết bị modem trên mạng cao
tốc độ xe buýt ngoại vi hoặc bộ nhớ dùng chung. Mặc dù MHI có thể dễ dàng điều chỉnh
đối với bất kỳ bus ngoại vi nào, nó chủ yếu được sử dụng với các thiết bị dựa trên PCIe. MHI
cung cấp các kênh logic trên các bus vật lý và cho phép vận chuyển các
giao thức modem, chẳng hạn như gói dữ liệu IP, tin nhắn điều khiển modem và
chẩn đoán trên ít nhất một trong các kênh logic đó. Ngoài ra, MHI
giao thức cung cấp tính năng xác nhận dữ liệu và quản lý trạng thái nguồn của
modem thông qua một hoặc nhiều kênh logic.

Bộ phận bên trong MHI
=============

MMIO
----

MMIO (IO được ánh xạ bộ nhớ) bao gồm một tập hợp các thanh ghi trong phần cứng thiết bị,
được ánh xạ tới không gian bộ nhớ máy chủ bằng các bus ngoại vi như PCIe.
Sau đây là các thành phần chính của không gian thanh ghi MMIO:

Các thanh ghi điều khiển MHI: Truy cập vào các thanh ghi cấu hình MHI

Các thanh ghi MHI BHI: Các thanh ghi BHI (Giao diện máy chủ khởi động) được máy chủ sử dụng
để tải chương trình cơ sở xuống thiết bị trước khi khởi tạo MHI.

Mảng Chuông cửa kênh: Các thanh ghi Chuông cửa kênh (DB) được máy chủ sử dụng để
thông báo cho thiết bị khi có công việc mới cần làm.

Mảng Event Doorbell: Liên kết với mảng bối cảnh sự kiện, Event Doorbell
Các thanh ghi (DB) được máy chủ sử dụng để thông báo cho thiết bị khi có sự kiện mới.
có sẵn.

Thanh ghi gỡ lỗi: Một tập hợp các thanh ghi và bộ đếm được thiết bị sử dụng để hiển thị
gỡ lỗi thông tin như hiệu suất, chức năng và độ ổn định cho máy chủ.

Cấu trúc dữ liệu
---------------

Tất cả các cấu trúc dữ liệu được MHI sử dụng đều nằm trong bộ nhớ hệ thống máy chủ. Sử dụng
giao diện vật lý, thiết bị truy cập vào các cấu trúc dữ liệu đó. Dữ liệu MHI
cấu trúc và bộ đệm dữ liệu trong vùng bộ nhớ của hệ thống máy chủ được ánh xạ cho
thiết bị.

Mảng ngữ cảnh kênh: Tất cả các cấu hình kênh được sắp xếp theo kênh
mảng dữ liệu ngữ cảnh.

Vòng truyền: Được máy chủ sử dụng để lên lịch các mục công việc cho một kênh. các
các vòng truyền được tổ chức như một hàng đợi vòng tròn của Bộ mô tả truyền (TD).

Mảng ngữ cảnh sự kiện: Tất cả các cấu hình sự kiện được sắp xếp trong ngữ cảnh sự kiện
mảng dữ liệu.

Vòng sự kiện: Được thiết bị sử dụng để gửi thông báo hoàn thành và chuyển trạng thái
đến chủ nhà

Mảng ngữ cảnh lệnh: Tất cả các cấu hình lệnh được tổ chức trong lệnh
mảng dữ liệu ngữ cảnh.

Vòng lệnh: Được máy chủ sử dụng để gửi lệnh MHI tới thiết bị. Lệnh
các vòng được tổ chức dưới dạng hàng đợi vòng tròn của Bộ mô tả Lệnh (CD).

Kênh
--------

Các kênh MHI là các ống dữ liệu hợp lý, một chiều giữa máy chủ và thiết bị.
Khái niệm kênh trong MHI tương tự như điểm cuối trong USB. MHI hỗ trợ lên
tới 256 kênh. Tuy nhiên, việc triển khai thiết bị cụ thể có thể hỗ trợ ít hơn
số lượng kênh tối đa được phép.

Hai kênh đơn hướng với các vòng truyền liên kết của chúng tạo thành một
ống dữ liệu hai chiều, có thể được sử dụng bởi các giao thức lớp trên để
truyền tải các gói dữ liệu ứng dụng (như gói IP, tin nhắn điều khiển modem,
thông báo chẩn đoán, v.v.). Mỗi kênh được liên kết với một
vòng chuyển.

Vòng chuyển
--------------

Việc truyền giữa máy chủ và thiết bị được tổ chức theo kênh và được xác định bởi
Bộ mô tả chuyển giao (TD). TD được quản lý thông qua các vòng chuyển giao, được
được xác định cho từng kênh giữa thiết bị và máy chủ và nằm trong máy chủ
trí nhớ. TD bao gồm một hoặc nhiều phần tử vòng (hoặc khối chuyển)::

[Con trỏ đọc (RP)] ----------->[Phần tử vòng] } TD
        [Con trỏ ghi (WP)]- [Phần tử vòng]
                             - [Yếu tố Nhẫn]
                              ---------->[Phần tử chiếc nhẫn]
                                        [Yếu tố nhẫn]

Dưới đây là cách sử dụng cơ bản của vòng chuyển:

* Máy chủ phân bổ bộ nhớ cho vòng truyền.
* Máy chủ đặt con trỏ cơ sở, con trỏ đọc và con trỏ ghi tương ứng
  bối cảnh kênh.
* Vòng được coi là trống khi RP == WP.
* Vòng được coi là đầy khi WP + 1 == RP.
* RP cho biết phần tử tiếp theo sẽ được thiết bị phục vụ.
* Khi máy chủ có bộ đệm mới để gửi, nó sẽ cập nhật phần tử vòng bằng
  thông tin bộ đệm, tăng WP cho phần tử tiếp theo và đổ chuông
  kênh DB liên quan.

Nhẫn sự kiện
-----------

Các sự kiện từ thiết bị đến máy chủ được tổ chức theo vòng sự kiện và được xác định bởi Sự kiện
Bộ mô tả (ED). Vòng sự kiện được thiết bị sử dụng để báo cáo các sự kiện như
trạng thái hoàn thành truyền dữ liệu, trạng thái hoàn thành lệnh và thay đổi trạng thái
đến chủ nhà. Các vòng sự kiện là mảng ED nằm trong máy chủ
trí nhớ. ED bao gồm một hoặc nhiều phần tử vòng (hoặc khối chuyển)::

[Con trỏ đọc (RP)] ----------->[Phần tử vòng] } ED
        [Con trỏ ghi (WP)]- [Phần tử vòng]
                             - [Yếu tố Nhẫn]
                              ---------->[Phần tử chiếc nhẫn]
                                        [Yếu tố nhẫn]

Dưới đây là cách sử dụng cơ bản của vòng sự kiện:

* Máy chủ phân bổ bộ nhớ cho vòng sự kiện.
* Máy chủ đặt con trỏ cơ sở, con trỏ đọc và con trỏ ghi tương ứng
  bối cảnh kênh.
* Cả máy chủ và thiết bị đều có bản sao cục bộ của RP, WP.
* Ring được coi là trống (không có sự kiện nào để phục vụ) khi WP + 1 == RP.
* Vòng được coi là đầy sự kiện khi RP == WP.
* Khi có sự kiện mới thiết bị cần gửi, thiết bị sẽ cập nhật ED
  được trỏ bởi RP, tăng RP cho phần tử tiếp theo và kích hoạt
  ngắt lời.

Yếu tố chiếc nhẫn
------------

Phần tử vòng là cấu trúc dữ liệu được sử dụng để chuyển một khối
dữ liệu giữa máy chủ và thiết bị. Các loại phần tử vòng chuyển chứa một
con trỏ đệm đơn, kích thước của bộ đệm và điều khiển bổ sung
thông tin. Các loại phần tử vòng khác chỉ có thể chứa điều khiển và trạng thái
thông tin. Đối với các hoạt động đệm đơn, một bộ mô tả vòng bao gồm một
phần tử đơn. Đối với các hoạt động đa bộ đệm lớn (chẳng hạn như phân tán và thu thập),
các phần tử có thể được xâu chuỗi để tạo thành một bộ mô tả dài hơn.

Hoạt động của MHI
==============

Trạng thái MHI
----------

MHI_STATE_RESET
~~~~~~~~~~~~~~~
MHI ở trạng thái đặt lại sau khi bật nguồn hoặc đặt lại phần cứng. Máy chủ không được phép
để truy cập vào không gian đăng ký MMIO của thiết bị.

MHI_STATE_READY
~~~~~~~~~~~~~~~
MHI đã sẵn sàng để khởi tạo. Máy chủ có thể bắt đầu khởi tạo MHI bằng cách
lập trình thanh ghi MMIO.

MHI_STATE_M0
~~~~~~~~~~~~
MHI đang chạy và hoạt động trong thiết bị. Máy chủ có thể bắt đầu các kênh bằng cách
phát lệnh bắt đầu kênh.

MHI_STATE_M1
~~~~~~~~~~~~
Hoạt động của MHI bị thiết bị tạm dừng. Trạng thái này được đưa vào khi
thiết bị phát hiện không hoạt động ở giao diện vật lý trong thời gian định sẵn.

MHI_STATE_M2
~~~~~~~~~~~~
MHI đang ở trạng thái năng lượng thấp. Hoạt động của MHI bị tạm dừng và thiết bị có thể
vào chế độ năng lượng thấp hơn.

MHI_STATE_M3
~~~~~~~~~~~~
Hoạt động MHI bị máy chủ dừng lại. Trạng thái này được nhập khi máy chủ tạm dừng
Hoạt động MHI.

Khởi tạo MHI
------------------

Sau khi hệ thống khởi động, thiết bị được liệt kê trên giao diện vật lý.
Trong trường hợp PCIe, thiết bị được liệt kê và gán BAR-0 cho
không gian đăng ký MMIO của thiết bị. Để khởi tạo MHI trong thiết bị,
máy chủ thực hiện các hoạt động sau:

* Phân bổ bối cảnh MHI cho mảng sự kiện, kênh và lệnh.
* Khởi tạo mảng ngữ cảnh và chuẩn bị các ngắt.
* Chờ cho đến khi thiết bị vào trạng thái READY.
* Lập trình MHI MMIO đăng ký và đặt thiết bị vào trạng thái MHI_M0.
* Chờ thiết bị vào trạng thái M0.

Truyền dữ liệu MHI
-----------------

Truyền dữ liệu MHI được máy chủ khởi tạo để truyền dữ liệu đến thiết bị.
Sau đây là trình tự các hoạt động được thực hiện bởi máy chủ để truyền
dữ liệu vào thiết bị:

* Máy chủ chuẩn bị TD với thông tin bộ đệm.
* Máy chủ tăng WP của vòng chuyển kênh tương ứng.
* Máy chủ đổ chuông vào thanh ghi DB kênh.
* Thiết bị thức dậy để xử lý TD.
* Thiết bị tạo ra sự kiện hoàn thành cho TD đã xử lý bằng cách cập nhật ED.
* Thiết bị tăng RP của vòng sự kiện tương ứng.
* Thiết bị kích hoạt IRQ để đánh thức máy chủ.
* Chủ nhà thức dậy và kiểm tra vòng sự kiện xem sự kiện đã hoàn thành chưa.
* Máy chủ cập nhật WP của vòng sự kiện tương ứng để cho biết rằng
  truyền dữ liệu đã được hoàn thành thành công.
