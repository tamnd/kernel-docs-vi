.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/process/debugging/driver_development_debugging_guide.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Lời khuyên gỡ lỗi để phát triển trình điều khiển
================================================

Tài liệu này đóng vai trò là điểm khởi đầu chung và tra cứu để gỡ lỗi
trình điều khiển thiết bị.
Mặc dù hướng dẫn này tập trung vào việc gỡ lỗi đòi hỏi phải biên dịch lại
mô-đun/hạt nhân, ZZ0000ZZ sẽ hướng dẫn
bạn thông qua các công cụ như gỡ lỗi động, ftrace và các công cụ khác hữu ích cho
gỡ lỗi các vấn đề và hành vi.
Để biết lời khuyên gỡ lỗi chung, hãy xem ZZ0001ZZ.

.. contents::
    :depth: 3

Các phần sau đây cho bạn thấy các công cụ có sẵn.

printk() và những người bạn
---------------------------

Đây là các dẫn xuất của printf() với các đích đến và hỗ trợ khác nhau cho
được bật hoặc tắt động hoặc thiếu tính năng này.

Bản in đơn giản()
~~~~~~~~~~~~~~~~~

Cổ điển, có thể được sử dụng để đạt hiệu quả cao cho sự phát triển nhanh chóng và bẩn thỉu
mô-đun mới hoặc trích xuất dữ liệu cần thiết tùy ý để khắc phục sự cố.

Điều kiện tiên quyết: ZZ0000ZZ (thường được bật theo mặc định)

ZZ0000ZZ:

- Không cần học gì cả, sử dụng đơn giản
- Dễ dàng sửa đổi chính xác theo nhu cầu (định dạng dữ liệu (Xem:
  ZZ0000ZZ), khả năng hiển thị trong nhật ký)
- Có thể gây ra sự chậm trễ trong việc thực thi mã (có lợi để xác nhận xem
  thời gian là một yếu tố)

ZZ0000ZZ:

- Yêu cầu xây dựng lại kernel/module
- Có thể gây ra sự chậm trễ trong việc thực thi mã (có thể gây ra sự cố
  không thể tái tạo)

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

Dấu vết_printk
~~~~~~~~~~~~~~

Điều kiện tiên quyết: ZZ0000ZZ & ZZ0001ZZ

Việc sử dụng nó kém thoải mái hơn một chút so với printk(), bởi vì bạn sẽ có
để đọc tin nhắn từ tệp theo dõi (Xem: ZZ0000ZZ
thay vì từ nhật ký kernel, nhưng rất hữu ích khi printk() thêm các phần không mong muốn
làm chậm quá trình thực thi mã, khiến các vấn đề không ổn định hoặc bị ẩn.)

Nếu quá trình xử lý này vẫn gây ra vấn đề về thời gian thì bạn có thể thử
trace_puts().

Để biết Tài liệu đầy đủ, hãy xem trace_printk()

dev_dbg
~~~~~~~

Tuyên bố in, có thể được nhắm mục tiêu bởi
ZZ0000ZZ có chứa
thông tin bổ sung về thiết bị được sử dụng trong ngữ cảnh.

ZZ0000ZZ

Các câu lệnh gỡ lỗi vĩnh viễn phải hữu ích để nhà phát triển khắc phục sự cố
hành vi sai trái của tài xế. Đánh giá rằng đó là một nghệ thuật hơn là khoa học, nhưng
một số hướng dẫn có trong ZZ0000ZZ. Trong hầu hết các trường hợp
các câu lệnh gỡ lỗi không nên được cập nhật ngược dòng, vì một trình điều khiển đang hoạt động được cho là
im lặng.

Bản in tùy chỉnh
~~~~~~~~~~~~~~~~

Ví dụ::

#define core_dbg(fmt, arg...) do { \
	  nếu (core_debug) \
		  printk(KERN_DEBUG pr_fmt("core: " fmt), ## arg); \
	  } trong khi (0)

ZZ0000ZZ

Tốt hơn là chỉ sử dụng pr_debug(), sau này có thể bật/tắt bằng
gỡ lỗi động. Ngoài ra, rất nhiều trình điều khiển kích hoạt các bản in này thông qua một
biến như ZZ0000ZZ được đặt bởi tham số mô-đun. Tuy nhiên, Mô-đun
thông số ZZ0001ZZ.

Ftrace
------

Tạo điểm theo dõi Ftrace tùy chỉnh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Điểm theo dõi thêm một hook vào mã của bạn, mã này sẽ được gọi và ghi lại khi
dấu vết được kích hoạt. Điều này có thể được sử dụng, ví dụ, để theo dõi việc đánh một
nhánh có điều kiện hoặc để kết xuất trạng thái nội bộ tại các điểm cụ thể của mã
luồng trong phiên gỡ lỗi.

Đây là mô tả cơ bản về ZZ0000ZZ.

Để có tài liệu theo dõi sự kiện đầy đủ, hãy xem ZZ0000ZZ

Để có tài liệu Ftrace đầy đủ, hãy xem ZZ0000ZZ

Gỡ lỗiFS
--------

Điều kiện tiên quyết: `ZZ0000ZZ & ZZ0001ZZ`

DebugFS khác với các phương pháp gỡ lỗi khác vì nó không ghi
thông báo vào nhật ký kernel cũng như không thêm dấu vết vào mã. Thay vào đó nó cho phép
nhà phát triển để xử lý một tập hợp các tập tin.
Với những tập tin này bạn có thể lưu trữ giá trị của các biến hoặc tạo
đăng ký/kết xuất bộ nhớ hoặc bạn có thể làm cho các tệp này có thể ghi và sửa đổi
giá trị/cài đặt trong trình điều khiển.

Các trường hợp sử dụng có thể có trong số những trường hợp khác:

- Lưu trữ giá trị đăng ký
- Theo dõi các biến
- Lỗi lưu trữ
- Cài đặt cửa hàng
- Chuyển đổi cài đặt như bật/tắt gỡ lỗi
- Lỗi tiêm

Điều này đặc biệt hữu ích khi kích thước của kết xuất dữ liệu khó tiêu hóa
như một phần của nhật ký kernel chung (ví dụ: khi kết xuất dữ liệu dòng bit thô)
hoặc khi bạn không phải lúc nào cũng quan tâm đến tất cả các giá trị, nhưng với
khả năng kiểm tra chúng.

Ý tưởng chung là:

- Tạo thư mục trong quá trình thăm dò (ZZ0000ZZ)
- Tạo một tập tin (ZZ0001ZZ)

- Trong ví dụ này tập tin được tìm thấy ở
    ZZ0000ZZ (có quyền đọc cho
    người dùng/nhóm/tất cả)
  - mọi thao tác đọc tệp sẽ trả về nội dung hiện tại của biến
    ZZ0001ZZ

- Dọn dẹp thư mục khi tháo máy
  (ZZ0000ZZ)

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ.

KASAN, UBSAN, lockdep và các trình kiểm tra lỗi khác
----------------------------------------------------

KASAN (Bộ khử trùng địa chỉ hạt nhân)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Điều kiện tiên quyết: ZZ0000ZZ

KASAN là một công cụ phát hiện lỗi bộ nhớ động giúp tìm kiếm những lần sử dụng không cần thiết và
lỗi ngoài giới hạn. Nó sử dụng thiết bị đo thời gian biên dịch để kiểm tra mọi bộ nhớ
truy cập.

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ.

UBSAN (Chất khử trùng hành vi không xác định)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Điều kiện tiên quyết: ZZ0000ZZ

UBSAN dựa vào công cụ biên dịch và kiểm tra thời gian chạy để phát hiện các phần không xác định
hành vi. Nó được thiết kế để tìm ra nhiều vấn đề khác nhau, bao gồm cả số nguyên có dấu
tràn, chỉ số mảng vượt quá giới hạn, v.v.

Để có tài liệu đầy đủ, hãy xem ZZ0000ZZ

lockdep (Trình xác thực phụ thuộc khóa)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Điều kiện tiên quyết: ZZ0000ZZ

lockdep là trình xác thực phụ thuộc khóa thời gian chạy để phát hiện các bế tắc tiềm ẩn
và các vấn đề liên quan đến khóa khác trong kernel.
Nó theo dõi việc mua lại và phát hành khóa, xây dựng một biểu đồ phụ thuộc
được phân tích về những bế tắc tiềm ẩn.
lockdep đặc biệt hữu ích cho việc xác nhận tính đúng đắn của thứ tự khóa trong
hạt nhân.

PSI (Theo dõi thông tin về gian áp suất)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Điều kiện tiên quyết: ZZ0000ZZ

PSI là một công cụ đo lường để xác định các cam kết quá mức trên phần cứng
tài nguyên, có thể gây gián đoạn hiệu suất hoặc thậm chí giết chết OOM.

lõi của thiết bị
----------------

Điều kiện tiên quyết: ZZ0000ZZ & ZZ0001ZZ

Cung cấp cơ sở hạ tầng để trình điều khiển cung cấp dữ liệu tùy ý cho vùng người dùng.
Nó thường được sử dụng cùng với udev hoặc ứng dụng vùng người dùng tương tự
để lắng nghe các sự kiện kernel, cho biết kết xuất đã sẵn sàng. Udev có
quy tắc sao chép tệp đó vào nơi nào đó để lưu trữ và phân tích lâu dài, chẳng hạn như
mặc định, dữ liệu cho kết xuất sẽ tự động được dọn sạch sau một lần mặc định
5 phút. Dữ liệu đó được phân tích bằng các công cụ dành riêng cho trình điều khiển hoặc GDB.

Một coredump của thiết bị có thể được tạo bằng vùng vmalloc, với quyền đọc/miễn phí
phương pháp hoặc dưới dạng danh sách phân tán/thu thập.

Bạn có thể tìm thấy một ví dụ triển khai tại:
ZZ0000ZZ,
trong lớp Bluetooth HCI, trong một số trình điều khiển không dây và trong một số
Trình điều khiển DRM.

giao diện devcoredump
~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/linux/devcoredump.h

.. kernel-doc:: drivers/base/devcoredump.c

ZZ0000ZZ ©2024 : Cộng tác