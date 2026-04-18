.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/start.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Bắt đầu
=================

Trang này chứa thông tin tổng quan về khung kunit_tool và KUnit,
dạy cách chạy các thử nghiệm hiện có và sau đó cách viết một trường hợp thử nghiệm đơn giản,
và đề cập đến những vấn đề thường gặp mà người dùng gặp phải khi sử dụng KUnit lần đầu tiên.

Cài đặt phụ thuộc
=======================
KUnit có các phần phụ thuộc giống như nhân Linux. Miễn là bạn có thể
xây dựng kernel, bạn có thể chạy KUnit.

Chạy thử nghiệm với kunit_tool
==============================
kunit_tool is a Python script, which configures and builds a kernel, runs
kiểm tra và định dạng kết quả kiểm tra. Từ kho kernel, bạn
có thể chạy kunit_tool:

.. code-block:: bash

	./tools/testing/kunit/kunit.py run

.. note ::
	You may see the following error:
	"The source tree is not clean, please run 'make ARCH=um mrproper'"

	This happens because internally kunit.py specifies ``.kunit``
	(default option) as the build directory in the command ``make O=output/dir``
	through the argument ``--build_dir``.  Hence, before starting an
	out-of-tree build, the source tree must be clean.

	There is also the same caveat mentioned in the "Build directory for
	the kernel" section of the :doc:`admin-guide </admin-guide/README>`,
	that is, its use, it must be used for all invocations of ``make``.
	The good news is that it can indeed be solved by running
	``make ARCH=um mrproper``, just be aware that this will delete the
	current configuration and all generated files.

Nếu mọi thứ hoạt động chính xác, bạn sẽ thấy như sau:

.. code-block::

	Configuring KUnit Kernel ...
	Building KUnit Kernel ...
	Starting KUnit Kernel ...

Các bài kiểm tra sẽ vượt qua hoặc thất bại.

.. note ::
   Because it is building a lot of sources for the first time,
   the ``Building KUnit Kernel`` step may take a while.

Để biết thông tin chi tiết về trình bao bọc này, hãy xem:
Tài liệu/dev-tools/kunit/run_wrapper.rst.

Chọn thử nghiệm nào sẽ chạy
----------------------------

Theo mặc định, kunit_tool chạy tất cả các thử nghiệm có thể truy cập được với cấu hình tối thiểu,
nghĩa là sử dụng các giá trị mặc định cho hầu hết các tùy chọn kconfig.  Tuy nhiên,
bạn có thể chọn thử nghiệm nào sẽ chạy:

- ZZ0000ZZ dùng để biên dịch kernel, hoặc
- ZZ0001ZZ để chọn cụ thể những bài kiểm tra đã biên dịch nào sẽ chạy.

Tùy chỉnh Kconfig
~~~~~~~~~~~~~~~~~~~
Điểm khởi đầu tốt cho ZZ0000ZZ là cấu hình mặc định KUnit.
Nếu bạn chưa chạy ZZ0001ZZ, bạn có thể tạo nó bằng cách chạy:

.. code-block:: bash

	cd $PATH_TO_LINUX_REPO
	tools/testing/kunit/kunit.py config
	cat .kunit/.kunitconfig

.. note ::
   ``.kunitconfig`` lives in the ``--build_dir`` used by kunit.py, which is
   ``.kunit`` by default.

Trước khi chạy thử nghiệm, kunit_tool đảm bảo rằng tất cả các tùy chọn cấu hình
được đặt trong ZZ0000ZZ được đặt trong kernel ZZ0001ZZ. Nó sẽ cảnh báo
bạn nếu bạn chưa bao gồm các phần phụ thuộc cho các tùy chọn được sử dụng.

Có nhiều cách để tùy chỉnh cấu hình:

Một. Chỉnh sửa ZZ0001ZZ. Tệp phải chứa danh sách kconfig
   các tùy chọn cần thiết để chạy các thử nghiệm mong muốn, bao gồm cả các phần phụ thuộc của chúng.
   Bạn có thể muốn xóa CONFIG_KUNIT_ALL_TESTS khỏi ZZ0002ZZ vì
   nó sẽ kích hoạt một số thử nghiệm bổ sung mà bạn có thể không muốn.
   Nếu bạn cần chạy trên kiến ​​trúc khác UML, hãy xem ZZ0000ZZ.

b. Kích hoạt các tùy chọn kconfig bổ sung trên ZZ0000ZZ.
   Ví dụ: để bao gồm kiểm tra danh sách liên kết của kernel, bạn có thể chạy::

./tools/testing/kunit/kunit.py run \
		--kconfig_add CONFIG_LIST_KUNIT_TEST=y

c. Cung cấp đường dẫn của một hoặc nhiều tệp .kunitconfig từ cây.
   Ví dụ: để chỉ chạy thử nghiệm ZZ0000ZZ và ZZ0001ZZ, bạn có thể chạy::

./tools/testing/kunit/kunit.py run \
		--kunitconfig ./fs/fat/.kunitconfig \
		--kunitconfig ./fs/ext4/.kunitconfig

d. Nếu bạn thay đổi ZZ0000ZZ, kunit.py sẽ kích hoạt việc xây dựng lại
   Tệp ZZ0001ZZ. Nhưng bạn có thể chỉnh sửa tệp ZZ0002ZZ trực tiếp hoặc bằng
   công cụ như ZZ0003ZZ. Miễn là nó là siêu bộ của
   ZZ0004ZZ, kunit.py sẽ không ghi đè các thay đổi của bạn.


.. note ::

	To save a .kunitconfig after finding a satisfactory configuration::

		make savedefconfig O=.kunit
		cp .kunit/defconfig .kunit/.kunitconfig

Lọc các bài kiểm tra theo tên
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Nếu bạn muốn cụ thể hơn những gì Kconfig có thể cung cấp thì cũng có thể
để chọn những thử nghiệm nào sẽ thực hiện khi khởi động bằng cách chuyển bộ lọc toàn cầu
(đọc hướng dẫn về mẫu trong trang ZZ0000ZZ).
Nếu có ZZ0001ZZ (dấu chấm) trong bộ lọc, nó sẽ được hiểu là
dấu phân cách giữa tên của bộ thử nghiệm và trường hợp thử nghiệm,
nếu không, nó sẽ được hiểu là tên của bộ thử nghiệm.
Ví dụ: giả sử chúng ta đang sử dụng cấu hình mặc định:

Một. thông báo tên của bộ thử nghiệm, như ZZ0000ZZ,
   để chạy mọi trường hợp thử nghiệm mà nó chứa::

./tools/testing/kunit/kunit.py chạy "kunit_executor_test"

b. thông báo tên của một trường hợp thử nghiệm được đặt trước bởi bộ thử nghiệm của nó,
   như ZZ0000ZZ, để chạy cụ thể trường hợp thử nghiệm đó ::

./tools/testing/kunit/kunit.py chạy "example.example_simple_test"

c. sử dụng các ký tự đại diện (ZZ0000ZZ) để chạy bất kỳ trường hợp thử nghiệm nào khớp với mẫu,
   như ZZ0001ZZ để chạy các trường hợp thử nghiệm có chứa ZZ0002ZZ trong tên bên trong
   bất kỳ bộ thử nghiệm nào::

./tools/testing/kunit/kunit.py chạy "ZZ0000ZZ64*"

Chạy thử nghiệm mà không có KUnit Wrapper
=========================================
Nếu bạn không muốn sử dụng KUnit Wrapper (ví dụ: bạn muốn mã
đang được thử nghiệm để tích hợp với các hệ thống khác hoặc sử dụng một/
kiến trúc hoặc cấu hình không được hỗ trợ), KUnit có thể được đưa vào
bất kỳ hạt nhân nào và kết quả sẽ được đọc và phân tích cú pháp theo cách thủ công.

.. note ::
   ``CONFIG_KUNIT`` should not be enabled in a production environment.
   Enabling KUnit disables Kernel Address-Space Layout Randomization
   (KASLR), and tests may affect the state of the kernel in ways not
   suitable for production.

Cấu hình hạt nhân
----------------------
Để kích hoạt KUnit, bạn cần kích hoạt ZZ0000ZZ Kconfig
tùy chọn (trong phần Hack hạt nhân/Kiểm tra hạt nhân và bảo hiểm trong
ZZ0001ZZ). Từ đó, bạn có thể kích hoạt bất kỳ bài kiểm tra KUnit nào. Họ
thường có các tùy chọn cấu hình kết thúc bằng ZZ0002ZZ.

Các bài kiểm tra KUnit và KUnit có thể được biên dịch thành các mô-đun. Các bài kiểm tra trong một mô-đun
sẽ chạy khi mô-đun được tải.

Đang chạy thử nghiệm (không có KUnit Wrapper)
---------------------------------------------
Xây dựng và chạy kernel của bạn. Trong nhật ký kernel, kết quả kiểm tra được in
ra ở định dạng TAP. Điều này sẽ chỉ xảy ra theo mặc định nếu KUnit/tests
được tích hợp sẵn. Nếu không thì mô-đun sẽ cần phải được tải.

.. note ::
   Some lines and/or data may get interspersed in the TAP output.

Viết bài kiểm tra đầu tiên của bạn
==================================
Trong kho kernel của bạn, hãy thêm một số mã mà chúng tôi có thể kiểm tra.

1. Tạo một tệp ZZ0000ZZ, bao gồm:

.. code-block:: c

	int misc_example_add(int left, int right);

2. Tạo một tệp ZZ0000ZZ, bao gồm:

.. code-block:: c

	#include <linux/errno.h>

	#include "example.h"

	int misc_example_add(int left, int right)
	{
		return left + right;
	}

3. Thêm các dòng sau vào ZZ0000ZZ:

.. code-block:: kconfig

	config MISC_EXAMPLE
		bool "My example"

4. Thêm các dòng sau vào ZZ0000ZZ:

.. code-block:: make

	obj-$(CONFIG_MISC_EXAMPLE) += example.o

Bây giờ chúng ta đã sẵn sàng để viết các trường hợp thử nghiệm.

1. Thêm trường hợp thử nghiệm bên dưới vào ZZ0000ZZ:

.. code-block:: c

	#include <kunit/test.h>
	#include "example.h"

	/* Define the test cases. */

	static void misc_example_add_test_basic(struct kunit *test)
	{
		KUNIT_EXPECT_EQ(test, 1, misc_example_add(1, 0));
		KUNIT_EXPECT_EQ(test, 2, misc_example_add(1, 1));
		KUNIT_EXPECT_EQ(test, 0, misc_example_add(-1, 1));
		KUNIT_EXPECT_EQ(test, INT_MAX, misc_example_add(0, INT_MAX));
		KUNIT_EXPECT_EQ(test, -1, misc_example_add(INT_MAX, INT_MIN));
	}

	static void misc_example_test_failure(struct kunit *test)
	{
		KUNIT_FAIL(test, "This test never passes.");
	}

	static struct kunit_case misc_example_test_cases[] = {
		KUNIT_CASE(misc_example_add_test_basic),
		KUNIT_CASE(misc_example_test_failure),
		{}
	};

	static struct kunit_suite misc_example_test_suite = {
		.name = "misc-example",
		.test_cases = misc_example_test_cases,
	};
	kunit_test_suite(misc_example_test_suite);

	MODULE_LICENSE("GPL");

2. Thêm các dòng sau vào ZZ0000ZZ:

.. code-block:: kconfig

	config MISC_EXAMPLE_TEST
		tristate "Test for my example" if !KUNIT_ALL_TESTS
		depends on MISC_EXAMPLE && KUNIT
		default KUNIT_ALL_TESTS

Lưu ý: Nếu thử nghiệm của bạn không hỗ trợ được xây dựng dưới dạng mô-đun có thể tải (được
không được khuyến khích), thay thế tristate bằng bool và phụ thuộc vào KUNIT=y thay vì KUNIT.

3. Thêm các dòng sau vào ZZ0000ZZ:

.. code-block:: make

	obj-$(CONFIG_MISC_EXAMPLE_TEST) += example_test.o

4. Thêm các dòng sau vào ZZ0000ZZ:

.. code-block:: none

	CONFIG_MISC_EXAMPLE=y
	CONFIG_MISC_EXAMPLE_TEST=y

5. Chạy thử nghiệm:

.. code-block:: bash

	./tools/testing/kunit/kunit.py run

Bạn sẽ thấy lỗi sau:

.. code-block:: none

	...
	[16:08:57] [PASSED] misc-example:misc_example_add_test_basic
	[16:08:57] [FAILED] misc-example:misc_example_test_failure
	[16:08:57] EXPECTATION FAILED at drivers/misc/example-test.c:17
	[16:08:57]      This test never passes.
	...

Xin chúc mừng! Bạn vừa viết bài kiểm tra KUnit đầu tiên của mình.

Các bước tiếp theo
==================

Nếu bạn quan tâm đến việc sử dụng một số tính năng nâng cao hơn của kunit.py,
hãy xem Tài liệu/dev-tools/kunit/run_wrapper.rst

Nếu bạn muốn chạy thử nghiệm mà không sử dụng kunit.py, hãy xem
Tài liệu/dev-tools/kunit/run_manual.rst

Để biết thêm thông tin về cách viết bài kiểm tra KUnit (bao gồm một số kỹ thuật phổ biến
để thử nghiệm những thứ khác nhau), hãy xem Documentation/dev-tools/kunit/usage.rst