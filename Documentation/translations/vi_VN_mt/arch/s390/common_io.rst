.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/s390/common_io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Lớp I/O chung S/390
======================

tham số dòng lệnh, mục Procfs và debugfs
===================================================

Tham số dòng lệnh
-----------------------

* ccw_timeout_log

Cho phép ghi nhật ký thông tin gỡ lỗi trong trường hợp hết thời gian chờ của thiết bị ccw.

* cio_ignore = thiết bị[,thiết bị[,..]]

thiết bị := {tất cả ZZ0000ZZ [!]condev ZZ0001ZZ [!]<devno>-<devno>}

Các thiết bị đã cho sẽ bị lớp I/O chung bỏ qua; không phát hiện
  và cảm biến thiết bị sẽ được thực hiện trên bất kỳ thiết bị nào trong số đó. Kênh con tới
  mà thiết bị được đề cập được gắn vào sẽ được coi như không có thiết bị nào được gắn vào
  đính kèm.

Một thiết bị bị bỏ qua có thể được bỏ qua sau này; xem phần "/procentry" để biết
  chi tiết.

Các thiết bị phải được cung cấp dưới dạng id bus (0.x.abcd) hoặc dưới dạng thập lục phân
  số thiết bị (0xabcd hoặc abcd, để tương thích ngược 2.4). Nếu bạn
  đưa ra số thiết bị 0xabcd, nó sẽ được hiểu là 0.0.abcd.

Bạn có thể sử dụng từ khóa 'all' để bỏ qua tất cả các thiết bị. 'ipldev' và 'condev'
  từ khóa có thể được sử dụng để chỉ thiết bị khởi động dựa trên CCW và bảng điều khiển CCW
  thiết bị tương ứng (những thứ này có thể chỉ hữu ích khi được kết hợp với '!'
  nhà điều hành). '!' toán tử sẽ khiến lớp I/O _không_ bỏ qua một thiết bị.
  Dòng lệnh
  được phân tích từ trái sang phải.

Ví dụ::

cio_ignore=0.0.0023-0.0.0042,0.0.4711

sẽ bỏ qua tất cả các thiết bị có phạm vi từ 0.0.0023 đến 0.0.0042 và thiết bị
  0.0.4711, nếu được phát hiện.

Một ví dụ khác::

cio_ignore=all,!0.0.4711,!0.0.fd00-0.0.fd02

sẽ bỏ qua tất cả các thiết bị ngoại trừ 0.0.4711, 0.0.fd00, 0.0.fd01, 0.0.fd02.

Theo mặc định, không có thiết bị nào bị bỏ qua.


/mục nhập thủ tục
-------------

* /proc/cio_ignore

Liệt kê các phạm vi thiết bị (theo id bus) bị I/O chung bỏ qua.

Bạn có thể bỏ qua một số hoặc tất cả các thiết bị bằng cách chuyển tới /proc/cio_ignore.
  "miễn phí tất cả" sẽ bỏ qua tất cả các thiết bị bị bỏ qua,
  "miễn phí <phạm vi thiết bị>, <phạm vi thiết bị>, ..." sẽ bỏ qua chỉ định
  thiết bị.

Ví dụ: nếu các thiết bị 0.0.0023 đến 0.0.0042 và 0.0.4711 bị bỏ qua,

- không có tiếng vang 0.0.0030-0.0.0032 > /proc/cio_ignore
    sẽ bỏ qua các thiết bị 0.0.0030 đến 0.0.0032 và sẽ rời khỏi các thiết bị 0.0.0023
    đến 0,0,002f, 0,0,0033 đến 0,0,0042 và 0,0,4711 bị bỏ qua;
  - echo free 0.0.0041 > /proc/cio_ignore sẽ bỏ qua thiết bị
    0,0,0041;
  - echo free all > /proc/cio_ignore sẽ bỏ qua tất cả những gì còn lại bị bỏ qua
    thiết bị.

Khi một thiết bị không bị bỏ qua, việc nhận dạng và cảm biến thiết bị sẽ được thực hiện và
  trình điều khiển thiết bị sẽ được thông báo nếu có thể, do đó thiết bị sẽ trở thành
  có sẵn cho hệ thống. Lưu ý rằng việc bỏ qua được thực hiện không đồng bộ.

Bạn cũng có thể thêm phạm vi thiết bị bị bỏ qua bằng cách chuyển tới
  /proc/cio_ignore; "thêm <phạm vi thiết bị>, <phạm vi thiết bị>, ..." sẽ bỏ qua
  các thiết bị được chỉ định.

Lưu ý: Mặc dù các thiết bị đã biết có thể được thêm vào danh sách các thiết bị sẽ được
	bỏ qua thì sẽ không có tác dụng gì nữa. Tuy nhiên, nếu một thiết bị như vậy
	biến mất rồi xuất hiện trở lại thì sẽ bị bỏ qua. để làm
	các thiết bị đã biết biến mất, bạn cần lệnh "thanh lọc" (xem bên dưới).

Ví dụ::

"echo thêm 0.0.a000-0.0.accc, 0.0.af00-0.0.afff > /proc/cio_ignore"

sẽ thêm 0.0.a000-0.0.accc và 0.0.af00-0.0.afff vào danh sách bị bỏ qua
  thiết bị.

Bạn có thể xóa các thiết bị đã biết nhưng hiện bị bỏ qua thông qua ::

"thanh lọc tiếng vang > /proc/cio_ignore"

Tất cả các thiết bị bị bỏ qua nhưng vẫn được đăng ký và không trực tuyến (= không được sử dụng)
  sẽ bị hủy đăng ký và do đó bị xóa khỏi hệ thống.

Các thiết bị có thể được chỉ định theo id bus (0.x.abcd) hoặc, đối với 2.4 lùi
  khả năng tương thích, theo số thiết bị ở dạng thập lục phân (0xabcd hoặc abcd). Thiết bị
  các số được cung cấp là 0xabcd sẽ được hiểu là 0,0.abcd.

* /proc/cio_settle

Yêu cầu ghi vào tệp này bị chặn cho đến khi tất cả các hành động cio được xếp hàng đợi được hoàn thành
  xử lý. Điều này sẽ cho phép không gian người dùng chờ đợi công việc đang chờ xử lý ảnh hưởng đến
  tính khả dụng của thiết bị sau khi thay đổi cio_ignore hoặc cấu hình phần cứng.

* Đối với một số thông tin có trong hệ thống tập tin /proc trong 2.4 (cụ thể là,
  /proc/subchannels và /proc/chpids), xem driver-model.txt.
  Thông tin trước đây có trong /proc/irq_count hiện có trong /proc/interrupts.


mục gỡ lỗi
---------------

* /sys/kernel/debug/s390dbf/cio_*/ (Tính năng gỡ lỗi S/390)

Một số chế độ xem do tính năng gỡ lỗi tạo ra để chứa nhiều kết quả gỡ lỗi khác nhau.

- /sys/kernel/debug/s390dbf/cio_crw/sprintf
    Thông báo từ quá trình xử lý các từ báo cáo kênh đang chờ xử lý (kiểm tra máy
    xử lý).

- /sys/kernel/debug/s390dbf/cio_msg/sprintf
    Các thông báo gỡ lỗi khác nhau từ lớp I/O chung.

- /sys/kernel/debug/s390dbf/cio_trace/hex_ascii
    Ghi lại việc gọi các chức năng trong lớp I/O chung và, nếu có,
    kênh con nào họ được yêu cầu, cũng như một số dữ liệu
    cấu trúc (như irb trong trường hợp lỗi).

Mức độ ghi nhật ký có thể được thay đổi để dài dòng hơn hoặc ít hơn bằng cách chuyển sang
  /sys/kernel/debug/s390dbf/cio_*/cấp một số từ 0 đến 6; xem
  tài liệu về tính năng gỡ lỗi S/390 (Documentation/arch/s390/s390dbf.rst)
  để biết chi tiết.
