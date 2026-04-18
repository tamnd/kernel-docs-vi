.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/running_tips.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Mẹo để chạy thử nghiệm KUnit
===============================

Sử dụng ZZ0000ZZ ("công cụ kunit")
=====================================

Chạy từ bất kỳ thư mục nào
--------------------------

Có thể hữu ích khi tạo một hàm bash như:

.. code-block:: bash

	function run_kunit() {
	  ( cd "$(git rev-parse --show-toplevel)" && ./tools/testing/kunit/kunit.py run "$@" )
	}

.. note::
	Early versions of ``kunit.py`` (before 5.6) didn't work unless run from
	the kernel root, hence the use of a subshell and ``cd``.

Chạy một tập hợp con các bài kiểm tra
-------------------------

ZZ0000ZZ chấp nhận một đối số toàn cục tùy chọn để lọc các bài kiểm tra. Định dạng
là ZZ0001ZZ.

Giả sử chúng tôi muốn chạy thử nghiệm sysctl, chúng tôi có thể thực hiện điều đó thông qua:

.. code-block:: bash

	$ echo -e 'CONFIG_KUNIT=y\nCONFIG_KUNIT_ALL_TESTS=y' > .kunit/.kunitconfig
	$ ./tools/testing/kunit/kunit.py run 'sysctl*'

Chúng ta có thể lọc xuống chỉ còn các bài kiểm tra "viết" thông qua:

.. code-block:: bash

	$ echo -e 'CONFIG_KUNIT=y\nCONFIG_KUNIT_ALL_TESTS=y' > .kunit/.kunitconfig
	$ ./tools/testing/kunit/kunit.py run 'sysctl*.*write*'

Chúng ta đang phải trả chi phí xây dựng nhiều bài kiểm tra hơn mức chúng ta cần theo cách này, nhưng đó là
dễ dàng hơn việc loay hoay với các tập tin ZZ0000ZZ hoặc bình luận
ZZ0001ZZ.

Tuy nhiên, nếu chúng ta muốn xác định một tập hợp các thử nghiệm theo cách ít đặc biệt hơn thì bước tiếp theo
mẹo rất hữu ích.

Xác định một tập hợp các bài kiểm tra
-----------------------

ZZ0000ZZ (cùng với ZZ0001ZZ và ZZ0002ZZ) hỗ trợ
Cờ ZZ0003ZZ. Vì vậy, nếu bạn có một bộ thử nghiệm mà bạn muốn chạy trên một
thường xuyên (đặc biệt nếu chúng có các phần phụ thuộc khác), bạn có thể tạo một
ZZ0004ZZ cụ thể cho họ.

Ví dụ. kunit có một cái để kiểm tra:

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py run --kunitconfig=lib/kunit/.kunitconfig

Ngoài ra, nếu bạn đang tuân theo quy ước đặt tên
tệp ZZ0000ZZ, bạn chỉ cần chuyển vào thư mục, ví dụ:

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py run --kunitconfig=lib/kunit

.. note::
	This is a relatively new feature (5.12+) so we don't have any
	conventions yet about on what files should be checked in versus just
	kept around locally. It's up to you and your maintainer to decide if a
	config is useful enough to submit (and therefore have to maintain).

.. note::
	Having ``.kunitconfig`` fragments in a parent and child directory is
	iffy. There's discussion about adding an "import" statement in these
	files to make it possible to have a top-level config run tests from all
	child directories. But that would mean ``.kunitconfig`` files are no
	longer just simple .config fragments.

	One alternative would be to have kunit tool recursively combine configs
	automagically, but tests could theoretically depend on incompatible
	options, so handling that would be tricky.

Đặt tham số dòng lệnh kernel
-------------------------------------

Bạn có thể sử dụng ZZ0000ZZ để truyền các đối số kernel tùy ý, ví dụ:

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py run --kernel_args=param=42 --kernel_args=param2=false


Tạo báo cáo bảo hiểm mã theo UML
------------------------------------------

.. note::
	TODO(brendanhiggins@google.com): There are various issues with UML and
	versions of gcc 7 and up. You're likely to run into missing ``.gcda``
	files or compile errors.

Điều này khác với cách nhận thông tin "thông thường"
được ghi lại trong Tài liệu/dev-tools/gcov.rst.

Thay vì bật ZZ0000ZZ, chúng ta có thể đặt các tùy chọn sau:

.. code-block:: none

	CONFIG_DEBUG_KERNEL=y
	CONFIG_DEBUG_INFO=y
	CONFIG_DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT=y
	CONFIG_GCOV=y


Đặt nó lại với nhau thành một chuỗi lệnh có thể sao chép:

.. code-block:: bash

	# Append coverage options to the current config
	$ ./tools/testing/kunit/kunit.py run --kunitconfig=.kunit/ --kunitconfig=tools/testing/kunit/configs/coverage_uml.config
	# Extract the coverage information from the build dir (.kunit/)
	$ lcov -t "my_kunit_tests" -o coverage.info -c -d .kunit/

	# From here on, it's the same process as with CONFIG_GCOV_KERNEL=y
	# E.g. can generate an HTML report in a tmp dir like so:
	$ genhtml -o /tmp/coverage_html coverage.info


Nếu phiên bản gcc đã cài đặt của bạn không hoạt động, bạn có thể điều chỉnh các bước:

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py run --make_options=CC=/usr/bin/gcc-6
	$ lcov -t "my_kunit_tests" -o coverage.info -c -d .kunit/ --gcov-tool=/usr/bin/gcov-6

Ngoài ra, các chuỗi công cụ dựa trên LLVM cũng có thể được sử dụng:

.. code-block:: bash

	# Build with LLVM and append coverage options to the current config
	$ ./tools/testing/kunit/kunit.py run --make_options LLVM=1 --kunitconfig=.kunit/ --kunitconfig=tools/testing/kunit/configs/coverage_uml.config
	$ llvm-profdata merge -sparse default.profraw -o default.profdata
	$ llvm-cov export --format=lcov .kunit/vmlinux -instr-profile default.profdata > coverage.info
	# The coverage.info file is in lcov-compatible format and it can be used to e.g. generate HTML report
	$ genhtml -o /tmp/coverage_html coverage.info


Chạy thử nghiệm thủ công
======================

Chạy thử nghiệm mà không sử dụng ZZ0000ZZ cũng là một trường hợp sử dụng quan trọng.
Hiện tại đây là lựa chọn duy nhất của bạn nếu bạn muốn thử nghiệm trên các kiến trúc khác ngoài
UML.

Vì việc chạy thử nghiệm trong UML khá đơn giản (cấu hình và biên dịch
kernel, chạy nhị phân ZZ0000ZZ), phần này sẽ tập trung vào thử nghiệm
kiến trúc không phải UML.


Chạy thử nghiệm tích hợp
----------------------

Khi cài đặt kiểm tra thành ZZ0000ZZ, các kiểm tra sẽ chạy như một phần của quá trình khởi động và in
kết quả tới dmesg ở định dạng TAP. Vì vậy, bạn chỉ cần thêm các bài kiểm tra của mình vào
ZZ0001ZZ, build và boot kernel của bạn như bình thường.

Vì vậy, nếu chúng tôi biên dịch kernel của mình bằng:

.. code-block:: none

	CONFIG_KUNIT=y
	CONFIG_KUNIT_EXAMPLE_TEST=y

Sau đó, chúng ta sẽ thấy đầu ra như thế này trong dmesg báo hiệu quá trình kiểm tra đã chạy và đạt:

.. code-block:: none

	TAP version 14
	1..1
	    # Subtest: example
	    1..1
	    # example_simple_test: initializing
	    ok 1 - example_simple_test
	ok 1 - example

Chạy thử nghiệm dưới dạng mô-đun
------------------------

Tùy thuộc vào các thử nghiệm, bạn có thể xây dựng chúng dưới dạng các mô-đun có thể tải được.

Ví dụ: chúng tôi sẽ thay đổi các tùy chọn cấu hình từ trước thành

.. code-block:: none

	CONFIG_KUNIT=y
	CONFIG_KUNIT_EXAMPLE_TEST=m

Sau khi khởi động vào kernel, chúng ta có thể chạy thử nghiệm thông qua

.. code-block:: none

	$ modprobe kunit-example-test

Điều này sau đó sẽ khiến nó in đầu ra TAP ra thiết bị xuất chuẩn.

.. note::
	The ``modprobe`` will *not* have a non-zero exit code if any test
	failed (as of 5.13). But ``kunit.py parse`` would, see below.

.. note::
	You can set ``CONFIG_KUNIT=m`` as well, however, some features will not
	work and thus some tests might break. Ideally tests would specify they
	depend on ``KUNIT=y`` in their ``Kconfig``'s, but this is an edge case
	most test authors won't think about.
	As of 5.13, the only difference is that ``current->kunit_test`` will
	not exist.

Kết quả in đẹp
-----------------------

Bạn có thể sử dụng ZZ0000ZZ để phân tích dmesg cho kết quả kiểm tra và in ra
dẫn đến định dạng quen thuộc tương tự như ZZ0001ZZ.

.. code-block:: bash

	$ ./tools/testing/kunit/kunit.py parse /var/log/dmesg


Truy xuất kết quả theo từng bộ
----------------------------

Bất kể bạn đang chạy thử nghiệm như thế nào, bạn có thể bật
ZZ0000ZZ để hiển thị các kết quả được định dạng TAP trên mỗi bộ:

.. code-block:: none

	CONFIG_KUNIT=y
	CONFIG_KUNIT_EXAMPLE_TEST=m
	CONFIG_KUNIT_DEBUGFS=y

Kết quả cho mỗi bộ sẽ được trình bày dưới
ZZ0000ZZ.
Vì vậy, sử dụng cấu hình ví dụ của chúng tôi:

.. code-block:: bash

	$ modprobe kunit-example-test > /dev/null
	$ cat /sys/kernel/debug/kunit/example/results
	... <TAP output> ...

	# After removing the module, the corresponding files will go away
	$ modprobe -r kunit-example-test
	$ cat /sys/kernel/debug/kunit/example/results
	/sys/kernel/debug/kunit/example/results: No such file or directory

Tạo báo cáo bảo hiểm mã
--------------------------------

Xem Documentation/dev-tools/gcov.rst để biết chi tiết về cách thực hiện việc này.

Lời khuyên mơ hồ duy nhất dành riêng cho KUnit ở đây là bạn có thể muốn xây dựng
bài kiểm tra của bạn dưới dạng mô-đun. Bằng cách đó, bạn có thể tách phạm vi phủ sóng khỏi các thử nghiệm từ
mã khác được thực thi trong khi khởi động, ví dụ:

.. code-block:: bash

	# Reset coverage counters before running the test.
	$ echo 0 > /sys/kernel/debug/gcov/reset
	$ modprobe kunit-example-test


Kiểm tra thuộc tính và lọc
=============================

Các bộ và trường hợp kiểm thử có thể được đánh dấu bằng các thuộc tính kiểm thử, chẳng hạn như tốc độ
kiểm tra. Các thuộc tính này sau đó sẽ được in ra trong kết quả thử nghiệm và có thể được sử dụng để
thực hiện kiểm tra bộ lọc.

Đánh dấu thuộc tính kiểm tra
-----------------------

Các thử nghiệm được đánh dấu bằng một thuộc tính bằng cách bao gồm đối tượng ZZ0000ZZ
trong định nghĩa kiểm tra.

Các trường hợp thử nghiệm có thể được đánh dấu bằng ZZ0000ZZ
macro để xác định trường hợp thử nghiệm thay vì ZZ0001ZZ.

.. code-block:: c

	static const struct kunit_attributes example_attr = {
		.speed = KUNIT_VERY_SLOW,
	};

	static struct kunit_case example_test_cases[] = {
		KUNIT_CASE_ATTR(example_test, example_attr),
	};

.. note::
	To mark a test case as slow, you can also use ``KUNIT_CASE_SLOW(test_name)``.
	This is a helpful macro as the slow attribute is the most commonly used.

Bộ thử nghiệm có thể được đánh dấu bằng một thuộc tính bằng cách đặt trường "attr" trong
định nghĩa bộ.

.. code-block:: c

	static const struct kunit_attributes example_attr = {
		.speed = KUNIT_VERY_SLOW,
	};

	static struct kunit_suite example_test_suite = {
		...,
		.attr = example_attr,
	};

.. note::
	Not all attributes need to be set in a ``kunit_attributes`` object. Unset
	attributes will remain uninitialized and act as though the attribute is set
	to 0 or NULL. Thus, if an attribute is set to 0, it is treated as unset.
	These unset attributes will not be reported and may act as a default value
	for filtering purposes.

Thuộc tính báo cáo
--------------------

Khi người dùng chạy thử nghiệm, các thuộc tính sẽ xuất hiện trong đầu ra kernel thô (trong
định dạng KTAP). Lưu ý rằng các thuộc tính sẽ bị ẩn theo mặc định trong đầu ra kunit.py
cho tất cả các bài kiểm tra vượt qua nhưng đầu ra kernel thô có thể được truy cập bằng cách sử dụng
Cờ ZZ0000ZZ. Đây là một ví dụ về cách kiểm tra thuộc tính cho các trường hợp kiểm thử
sẽ được định dạng trong đầu ra kernel:

.. code-block:: none

	# example_test.speed: slow
	ok 1 example_test

Đây là một ví dụ về cách các thuộc tính thử nghiệm cho bộ thử nghiệm sẽ được định dạng trong
đầu ra hạt nhân:

.. code-block:: none

	  KTAP version 2
	  # Subtest: example_suite
	  # module: kunit_example_test
	  1..3
	  ...
	ok 1 example_suite

Ngoài ra, người dùng có thể xuất báo cáo thuộc tính đầy đủ của các bài kiểm tra bằng
thuộc tính, sử dụng cờ dòng lệnh ZZ0000ZZ:

.. code-block:: bash

	kunit.py run "example" --list_tests_attr

.. note::
	This report can be accessed when running KUnit manually by passing in the
	module_param ``kunit.action=list_attr``.

Lọc
---------

Người dùng có thể lọc các bài kiểm tra bằng cờ dòng lệnh ZZ0000ZZ khi chạy
các bài kiểm tra. Như một ví dụ:

.. code-block:: bash

	kunit.py run --filter speed=slow


Bạn cũng có thể sử dụng các thao tác sau trên bộ lọc: "<", ">", "<=", ">=",
"!=" và "=". Ví dụ:

.. code-block:: bash

	kunit.py run --filter "speed>slow"

Ví dụ này sẽ chạy tất cả các bài kiểm tra với tốc độ nhanh hơn chậm. Lưu ý rằng
các ký tự < và > thường được shell diễn giải, vì vậy chúng có thể cần phải được
được trích dẫn hoặc thoát, như trên.

Ngoài ra, bạn có thể sử dụng nhiều bộ lọc cùng một lúc. Đơn giản chỉ cần tách các bộ lọc
sử dụng dấu phẩy. Ví dụ:

.. code-block:: bash

	kunit.py run --filter "speed>slow, module=kunit_example_test"

.. note::
	You can use this filtering feature when running KUnit manually by passing
	the filter as a module param: ``kunit.filter="speed>slow, speed<=normal"``.

Các bài kiểm tra đã lọc sẽ không chạy hoặc hiển thị trong kết quả kiểm tra. Bạn có thể sử dụng
Thay vào đó, hãy gắn cờ ZZ0000ZZ để bỏ qua các bài kiểm tra đã lọc. Những thử nghiệm này sẽ được
hiển thị trong đầu ra thử nghiệm trong thử nghiệm nhưng sẽ không chạy. Để sử dụng tính năng này khi
chạy KUnit theo cách thủ công, hãy sử dụng thông số mô-đun ZZ0001ZZ.

Quy tắc của thủ tục lọc
----------------------------

Vì cả bộ và trường hợp thử nghiệm đều có thể có thuộc tính nên có thể xảy ra xung đột
giữa các thuộc tính trong quá trình lọc. Quá trình lọc tuân theo các
quy tắc:

- Lọc luôn hoạt động ở mức mỗi lần kiểm tra.

- Nếu bài kiểm tra có tập thuộc tính thì giá trị của bài kiểm tra sẽ được lọc.

- Ngược lại giá trị sẽ quay về giá trị của bộ.

- Nếu cả hai đều không được đặt, thuộc tính này có giá trị "mặc định" chung và được sử dụng.

Danh sách thuộc tính hiện tại
--------------------------

ZZ0000ZZ

Thuộc tính này cho biết tốc độ thực hiện kiểm thử (tốc độ thực hiện kiểm thử chậm hay nhanh).
kiểm tra là).

Thuộc tính này được lưu dưới dạng enum với các danh mục sau: "bình thường",
"chậm" hoặc "rất_chậm". Tốc độ mặc định giả định cho các bài kiểm tra là "bình thường". Cái này
chỉ ra rằng bài kiểm tra mất một khoảng thời gian tương đối nhỏ (ít hơn
1 giây), bất kể nó đang chạy trên máy nào. Bất kỳ bài kiểm tra nào chậm hơn
điều này có thể được đánh dấu là "chậm" hoặc "rất chậm".

Macro ZZ0000ZZ có thể dễ dàng sử dụng để thiết lập tốc độ
của trường hợp thử nghiệm thành "chậm".

ZZ0000ZZ

Thuộc tính này cho biết tên của mô-đun được liên kết với bài kiểm tra.

Thuộc tính này được lưu tự động dưới dạng chuỗi và được in cho từng bộ.
Các thử nghiệm cũng có thể được lọc bằng thuộc tính này.

ZZ0000ZZ

Thuộc tính này cho biết liệu thử nghiệm có sử dụng dữ liệu hoặc hàm init hay không.

Thuộc tính này được lưu tự động dưới dạng boolean và các bài kiểm tra cũng có thể được
được lọc bằng thuộc tính này.