.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/rust/general-information.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thông tin chung
===================

Tài liệu này chứa thông tin hữu ích cần biết khi làm việc với
hỗ trợ Rust trong kernel.


ZZ0000ZZ
----------

Hỗ trợ Rust trong kernel chỉ có thể liên kết ZZ0001ZZ,
nhưng không phải ZZ0002ZZ. Thùng để sử dụng trong
kernel phải chọn tham gia hành vi này bằng thuộc tính ZZ0000ZZ.


.. _rust_code_documentation:

Tài liệu mã
------------------

Mã hạt nhân Rust được ghi lại bằng ZZ0000ZZ, tài liệu tích hợp của nó
máy phát điện.

Các tài liệu HTML được tạo bao gồm tìm kiếm tích hợp, các mục được liên kết (ví dụ: loại,
hàm, hằng số), mã nguồn, v.v. Bạn có thể đọc chúng tại:

ZZ0000ZZ

Đối với linux-next, vui lòng xem:

ZZ0000ZZ

Ngoài ra còn có các thẻ cho mỗi bản phát hành chính, ví dụ:

ZZ0000ZZ

Các tài liệu cũng có thể dễ dàng được tạo và đọc cục bộ. Điều này khá nhanh
(cùng thứ tự với việc biên dịch mã) và không có công cụ hoặc môi trường đặc biệt
là cần thiết. Điều này có thêm lợi thế là chúng sẽ được điều chỉnh cho phù hợp
cấu hình kernel cụ thể được sử dụng. Để tạo chúng, hãy sử dụng ZZ0000ZZ
target có cùng lời gọi được sử dụng để biên dịch, ví dụ:::

tạo LLVM=1 Rustdoc

Để đọc tài liệu cục bộ trong trình duyệt web của bạn, hãy chạy ví dụ:::

xdg-open Tài liệu/đầu ra/rust/rustdoc/kernel/index.html

Để tìm hiểu về cách viết tài liệu, vui lòng xemcoding-guidelines.rst.


thêm xơ vải
-----------

Mặc dù ZZ0000ZZ là một trình biên dịch rất hữu ích nhưng một số gợi ý và phân tích bổ sung lại được cung cấp.
có sẵn thông qua ZZ0001ZZ, một kẻ nói dối Rust. Để kích hoạt nó, hãy chuyển ZZ0002ZZ tới
lời gọi tương tự được sử dụng để biên dịch, ví dụ:::

tạo LLVM=1 CLIPPY=1

Xin lưu ý rằng Clippy có thể thay đổi việc tạo mã, do đó không nên
được kích hoạt trong khi xây dựng hạt nhân sản xuất.


Trừu tượng và ràng buộc
-------------------------

Tóm tắt là mã Rust bao bọc chức năng kernel từ phía C.

Để sử dụng các hàm và kiểu từ phía C, các liên kết sẽ được tạo.
Các ràng buộc là các khai báo cho Rust về các hàm và kiểu đó từ
phía C.

Chẳng hạn, người ta có thể viết một bản tóm tắt ZZ0000ZZ trong Rust bao bọc
ZZ0001ZZ từ phía C và gọi các chức năng của nó thông qua các liên kết.

Tính trừu tượng không có sẵn cho tất cả các khái niệm và API nội bộ của kernel,
nhưng dự kiến phạm vi phủ sóng sẽ được mở rộng theo thời gian. Mô-đun "Lá"
(ví dụ: trình điều khiển) không nên sử dụng trực tiếp các ràng buộc C. Thay vào đó, các hệ thống con
nên cung cấp sự trừu tượng hóa an toàn nhất có thể khi cần thiết.

.. code-block::

	                                                rust/bindings/
	                                               (rust/helpers/)

	                                                   include/ -----+ <-+
	                                                                 |   |
	  drivers/              rust/kernel/              +----------+ <-+   |
	    fs/                                           | bindgen  |       |
	   .../            +-------------------+          +----------+ --+   |
	                   |    Abstractions   |                         |   |
	+---------+        | +------+ +------+ |          +----------+   |   |
	| my_foo  | -----> | | foo  | | bar  | | -------> | Bindings | <-+   |
	| driver  |  Safe  | | sub- | | sub- | |  Unsafe  |          |       |
	+---------+        | |system| |system| |          | bindings | <-----+
	     |             | +------+ +------+ |          |  crate   |       |
	     |             |   kernel crate    |          +----------+       |
	     |             +-------------------+                             |
	     |                                                               |
	     +------------------# FORBIDDEN #--------------------------------+

Ý tưởng chính là gói gọn tất cả tương tác trực tiếp với API C của kernel
vào các phần tóm tắt được xem xét cẩn thận và ghi lại. Sau đó, những người sử dụng những thứ này
sự trừu tượng hóa không thể đưa ra hành vi không xác định (UB) miễn là:

#. Sự trừu tượng hóa là chính xác ("âm thanh").
#. Bất kỳ khối ZZ0000ZZ nào đều tôn trọng hợp đồng an toàn cần thiết để gọi
   hoạt động bên trong khối. Tương tự, mọi ZZ0001ZZ đều tôn trọng
   hợp đồng an toàn cần thiết để thực hiện đặc điểm.

Ràng buộc
~~~~~~~~~

Bằng cách đưa tiêu đề C từ ZZ0000ZZ vào
ZZ0001ZZ, công cụ ZZ0002ZZ sẽ tự động tạo
các ràng buộc cho hệ thống con đi kèm. Sau khi xây dựng, hãy xem ZZ0003ZZ
tập tin đầu ra trong thư mục ZZ0004ZZ.

Đối với các phần của tiêu đề C mà ZZ0000ZZ không tự động tạo, ví dụ: C
Các chức năng ZZ0001ZZ hoặc các macro không tầm thường, có thể thêm một số nhỏ
chức năng bao bọc cho ZZ0002ZZ để cung cấp nó cho phía Rust dưới dạng
tốt.

Trừu tượng
~~~~~~~~~~~~

Trừu tượng là lớp giữa các liên kết và người dùng trong kernel. Họ
được đặt trong ZZ0000ZZ và vai trò của chúng là đóng gói các thông tin không an toàn
truy cập vào các ràng buộc vào API an toàn nhất có thể mà họ tiếp xúc với
người dùng. Người dùng trừu tượng bao gồm những thứ như trình điều khiển hoặc hệ thống tệp
được viết bằng Rust.

Bên cạnh khía cạnh an toàn, sự trừu tượng được cho là "công thái học", trong
có nghĩa là họ biến giao diện C thành mã Rust "thành ngữ". Cơ bản
ví dụ là biến việc mua lại và phát hành tài nguyên C thành Rust
hàm tạo và hàm hủy hoặc mã lỗi số nguyên C vào ZZ0000ZZ\ s của Rust.


Biên dịch có điều kiện
-----------------------

Mã Rust có quyền truy cập vào trình biên dịch có điều kiện dựa trên kernel
cấu hình:

.. code-block:: rust

	#[cfg(CONFIG_X)]       // Enabled               (`y` or `m`)
	#[cfg(CONFIG_X="y")]   // Enabled as a built-in (`y`)
	#[cfg(CONFIG_X="m")]   // Enabled as a module   (`m`)
	#[cfg(not(CONFIG_X))]  // Disabled

Đối với các vị từ khác mà ZZ0000ZZ của Rust không hỗ trợ, ví dụ: biểu thức với
so sánh bằng số, người ta có thể định nghĩa một ký hiệu Kconfig mới:

.. code-block:: kconfig

	config RUSTC_HAS_SPAN_FILE
		def_bool RUSTC_VERSION >= 108800