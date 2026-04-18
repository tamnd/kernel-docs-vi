.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/run_manual.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Chạy thử nghiệm mà không có kunit_tool
======================================

Nếu chúng ta không muốn sử dụng kunit_tool (Ví dụ: chúng ta muốn tích hợp
với các hệ thống khác hoặc chạy thử nghiệm trên phần cứng thực), chúng tôi có thể
bao gồm KUnit trong bất kỳ hạt nhân nào, đọc kết quả và phân tích cú pháp theo cách thủ công.

.. note:: KUnit is not designed for use in a production system. It is
          possible that tests may reduce the stability or security of
          the system.

Cấu hình hạt nhân
====================

Kiểm tra KUnit có thể chạy mà không cần kunit_tool. Điều này có thể hữu ích nếu:

- Chúng tôi có sẵn cấu hình kernel để kiểm tra.
- Cần chạy trên phần cứng thực (hoặc sử dụng trình giả lập/VM kunit_tool
  không hỗ trợ).
- Mong muốn tích hợp với một số hệ thống thử nghiệm hiện có.

KUnit được cấu hình với tùy chọn ZZ0000ZZ và riêng lẻ
các bài kiểm tra cũng có thể được xây dựng bằng cách bật các tùy chọn cấu hình của chúng trong
ZZ0001ZZ. Các bài kiểm tra KUnit thường (nhưng không phải lúc nào cũng vậy) có các tùy chọn cấu hình
kết thúc bằng ZZ0002ZZ. Hầu hết các thử nghiệm có thể được xây dựng dưới dạng mô-đun,
hoặc được tích hợp vào kernel.

.. note ::

	We can enable the ``KUNIT_ALL_TESTS`` config option to
	automatically enable all tests with satisfied dependencies. This is
	a good way of quickly testing everything applicable to the current
	config.

	KUnit can be enabled or disabled at boot time, and this behavior is
	controlled by the kunit.enable kernel parameter.
	By default, kunit.enable is set to 1 because KUNIT_DEFAULT_ENABLED is
	enabled by default. To ensure that tests are executed as expected,
	verify that kunit.enable=1 at boot time.

Khi chúng tôi đã xây dựng xong kernel (và/hoặc mô-đun) của mình, việc chạy rất đơn giản
các bài kiểm tra. Nếu các bài kiểm tra được tích hợp sẵn, chúng sẽ tự động chạy trên
khởi động hạt nhân. Kết quả sẽ được ghi vào nhật ký kernel (ZZ0000ZZ)
ở định dạng TAP.

Nếu các thử nghiệm được xây dựng dưới dạng mô-đun, chúng sẽ chạy khi mô-đun được
đã tải.

.. code-block :: bash

	# modprobe example-test

Kết quả sẽ xuất hiện ở định dạng TAP trong ZZ0000ZZ.

gỡ lỗi
=======

KUnit có thể được truy cập từ không gian người dùng thông qua hệ thống tệp debugfs (Xem thêm
thông tin về debugf tại Documentation/filesystems/debugfs.rst).

Nếu ZZ0000ZZ được bật, hệ thống tệp gỡ lỗi KUnit sẽ được
được gắn tại /sys/kernel/debug/kunit. Bạn có thể sử dụng hệ thống tập tin này để thực hiện
những hành động sau đây.

Truy xuất kết quả kiểm tra
=====================

Bạn có thể sử dụng debugfs để truy xuất kết quả kiểm tra KUnit. Kết quả kiểm tra là
có thể truy cập từ hệ thống tệp debugfs trong tệp chỉ đọc sau:

.. code-block :: bash

	/sys/kernel/debug/kunit/<test_suite>/results

Kết quả kiểm tra được in trong tài liệu KTAP. Lưu ý tài liệu này là riêng biệt
vào nhật ký kernel và do đó, có thể có cách đánh số bộ thử nghiệm khác nhau.

Chạy thử nghiệm sau khi kernel đã khởi động
=================================

Bạn có thể sử dụng hệ thống tập tin debugfs để kích hoạt các thử nghiệm tích hợp để chạy sau
khởi động. Để chạy bộ thử nghiệm, bạn có thể sử dụng lệnh sau để ghi vào
tệp ZZ0000ZZ:

.. code-block :: bash

	echo "any string" > /sys/kernel/debugfs/kunit/<test_suite>/run

Kết quả là bộ thử nghiệm chạy và kết quả được in vào kernel
nhật ký.

Tuy nhiên, tính năng này không khả dụng với bộ KUnit sử dụng dữ liệu init,
vì dữ liệu init có thể đã bị loại bỏ sau khi kernel khởi động. KUđơn vị
các bộ sử dụng dữ liệu init phải được xác định bằng cách sử dụng
macro kunit_test_init_section_suites().

Ngoài ra, bạn không thể sử dụng tính năng này để chạy thử nghiệm đồng thời. Thay vào đó là một bài kiểm tra
sẽ đợi để chạy cho đến khi các thử nghiệm khác hoàn thành hoặc thất bại.

.. note ::

	For test authors, to use this feature, tests will need to correctly initialise
	and/or clean up any data, so the test runs correctly a second time.