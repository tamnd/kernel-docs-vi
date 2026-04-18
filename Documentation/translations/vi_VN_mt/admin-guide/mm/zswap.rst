.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mm/zswap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
trao đổi zswap
=====

Tổng quan
========

Zswap là bộ đệm nén nhẹ dành cho các trang trao đổi. Phải mất các trang
trong quá trình hoán đổi và cố gắng nén chúng thành một
Nhóm bộ nhớ dựa trên RAM được phân bổ động.  zswap về cơ bản giao dịch theo chu kỳ CPU
để giảm I/O trao đổi có khả năng.  Sự đánh đổi này cũng có thể dẫn đến
cải thiện hiệu suất đáng kể nếu đọc từ bộ nhớ đệm nén
nhanh hơn đọc từ một thiết bị trao đổi.

Một số lợi ích tiềm năng:

* Người dùng máy tính để bàn/máy tính xách tay có dung lượng RAM hạn chế có thể giảm thiểu
  tác động hiệu suất của việc hoán đổi.
* Các khách được cam kết quá mức có thể chia sẻ tài nguyên I/O chung
  giảm đáng kể áp lực I/O hoán đổi của họ, tránh I/O nặng tay
  điều tiết bởi hypervisor. Điều này cho phép hoàn thành nhiều công việc hơn với ít công sức hơn
  tác động đến khối lượng công việc của khách và khách chia sẻ hệ thống con I/O
* Người dùng sử dụng ổ SSD làm thiết bị trao đổi có thể kéo dài tuổi thọ của thiết bị bằng cách
  giảm đáng kể việc viết rút ngắn tuổi thọ.

Zswap chuyển các trang khỏi bộ đệm nén trên cơ sở LRU sang hoán đổi sao lưu
thiết bị khi nhóm nén đạt đến giới hạn kích thước của nó.  Yêu cầu này đã có
đã được xác định trong các cuộc thảo luận cộng đồng trước đây.

Zswap có được bật vào lúc khởi động hay không tùy thuộc vào việc
tùy chọn ZZ0000ZZ Kconfig có được bật hay không.
Cài đặt này sau đó có thể được ghi đè bằng cách cung cấp dòng lệnh kernel
Tùy chọn ZZ0001ZZ, ví dụ ZZ0002ZZ.
Zswap cũng có thể được bật và tắt trong thời gian chạy bằng giao diện sysfs.
Một lệnh ví dụ để kích hoạt zswap khi chạy, giả sử sysfs được gắn kết
tại ZZ0003ZZ, là::

echo 1 > /sys/module/zswap/parameters/enabled

Khi zswap bị tắt trong thời gian chạy, nó sẽ ngừng lưu trữ các trang
đang bị hoán đổi.  Tuy nhiên, nó sẽ _không_ báo lỗi ngay lập tức
trở lại bộ nhớ tất cả các trang được lưu trữ trong vùng nén.  các
các trang được lưu trữ trong zswap sẽ vẫn ở trong nhóm nén cho đến khi chúng được
hoặc bị vô hiệu hoặc bị lỗi quay trở lại bộ nhớ.  Để buộc tất cả
các trang ra khỏi vùng nén, việc hoán đổi trên (các) thiết bị trao đổi sẽ
lỗi quay trở lại bộ nhớ tất cả các trang bị tráo đổi, kể cả những trang trong
bể nén.

Thiết kế
======

Zswap nhận các trang để nén từ hệ thống con trao đổi và có thể
loại bỏ các trang khỏi vùng nén của chính nó trên cơ sở LRU và ghi chúng lại vào
thiết bị trao đổi dự phòng trong trường hợp nhóm nén đã đầy.

Zswap sử dụng zsmalloc để quản lý nhóm bộ nhớ nén.  Mỗi
phân bổ trong zsmalloc không thể truy cập trực tiếp theo địa chỉ.  Đúng hơn là một tay cầm
được trả về bởi thủ tục phân bổ và phần xử lý đó phải được ánh xạ trước khi được
đã truy cập.  Nhóm bộ nhớ nén tăng lên theo yêu cầu và co lại khi bị nén
các trang được giải phóng.  Nhóm không được phân bổ trước.

Khi một trang trao đổi được chuyển từ trao đổi sang zswap, zswap duy trì ánh xạ
mục nhập hoán đổi, sự kết hợp giữa loại hoán đổi và phần bù hoán đổi, cho zsmalloc
xử lý các tham chiếu đó đã nén trang hoán đổi.  Việc lập bản đồ này đạt được
với một xarray cho mỗi loại trao đổi.  Phần bù hoán đổi là khóa tìm kiếm cho xarray
nút.

Khi xảy ra lỗi trang trên PTE là mục trao đổi, mã hoán đổi sẽ gọi
chức năng tải zswap để giải nén trang vào trang được phân bổ bởi trang
người xử lý lỗi.

Khi không có PTE nào tham chiếu đến trang hoán đổi được lưu trữ trong zswap (tức là số lượng
trong swap_map chuyển sang 0) mã hoán đổi gọi hàm vô hiệu zswap
để giải phóng mục bị nén.

Zswap tìm cách đơn giản hóa các chính sách của mình.  Thuộc tính Sysfs cho phép một người dùng
Chính sách kiểm soát:

* max_pool_percent - Phần trăm bộ nhớ tối đa được nén
  hồ bơi có thể chiếm.

Máy nén mặc định được chọn trong ZZ0000ZZ
Kconfig, nhưng nó có thể bị ghi đè khi khởi động bằng cách đặt
Thuộc tính ZZ0001ZZ, ví dụ: ZZ0002ZZ.
Nó cũng có thể được thay đổi trong thời gian chạy bằng cách sử dụng "máy nén" sysfs
thuộc tính, ví dụ::

echo lzo > /sys/module/zswap/parameters/compressor

Khi tham số máy nén được thay đổi trong thời gian chạy, mọi dữ liệu nén hiện có
các trang không được sửa đổi; họ bị bỏ lại trong hồ bơi riêng của họ.  Khi một yêu cầu được
được tạo cho một trang trong nhóm cũ, nó không bị nén bằng cách sử dụng trang gốc
máy nén.  Sau khi tất cả các trang được xóa khỏi nhóm cũ, nhóm đó và
máy nén được giải phóng.

Một số trang trong zswap là các trang có cùng giá trị (tức là nội dung của
trang có cùng giá trị hoặc mẫu lặp lại). Những trang này bao gồm không điền
các trang và chúng được xử lý khác nhau. Trong quá trình vận hành cửa hàng, một trang được
đã kiểm tra xem đó có phải là trang có cùng giá trị hay không trước khi nén nó. Nếu đúng thì
độ dài nén của trang được đặt thành 0 và mẫu hoặc điền giống nhau
giá trị được lưu trữ.

Để ngăn zswap thu hẹp nhóm khi zswap đầy và có mức cao
áp lực trao đổi (điều này sẽ dẫn đến việc lật các trang vào và ra nhóm zswap
không có bất kỳ lợi ích thực sự nào nhưng lại làm giảm hiệu suất của hệ thống),
tham số đặc biệt đã được giới thiệu để thực hiện một loại độ trễ để
từ chối đưa các trang vào nhóm zswap cho đến khi có đủ dung lượng nếu giới hạn
đã bị đánh. Để đặt ngưỡng mà zswap sẽ bắt đầu chấp nhận các trang
một lần nữa sau khi nó đầy, hãy sử dụng sysfs ZZ0000ZZ
thuộc tính, e. g.::

echo 80 > /sys/module/zswap/parameters/accept_threshold_percent

Đặt tham số này thành 100 sẽ vô hiệu hóa độ trễ.

Một số người dùng không thể chịu đựng được việc hoán đổi do lỗi cửa hàng zswap
và viết lại zswap. Việc hoán đổi có thể bị vô hiệu hóa hoàn toàn (không cần vô hiệu hóa
zswap chính nó) trên cơ sở cgroup như sau ::

echo 0 > /sys/fs/cgroup/<cgroup-name>/memory.zswap.writeback

Lưu ý rằng nếu lỗi cửa hàng tái diễn (ví dụ: nếu các trang
không thể nén được), người dùng có thể quan sát thấy việc lấy lại không hiệu quả sau khi vô hiệu hóa
viết lại (vì các trang giống nhau có thể bị từ chối nhiều lần).

Khi có một lượng lớn bộ nhớ lạnh nằm trong nhóm zswap, nó
có thể thuận lợi khi chủ động viết những trang lạnh này để trao đổi và lấy lại
bộ nhớ cho các trường hợp sử dụng khác. Theo mặc định, trình thu gọn zswap bị tắt.
Người dùng có thể kích hoạt nó như sau::

echo Y > /sys/module/zswap/parameters/shrinker_enabled

Điều này có thể được kích hoạt vào lúc khởi động nếu ZZ0000ZZ được
đã chọn.

Giao diện debugfs được cung cấp cho nhiều thống kê khác nhau về kích thước nhóm, số lượng
số trang được lưu trữ, các trang có cùng giá trị và các bộ đếm khác nhau vì các lý do
các trang bị từ chối.
