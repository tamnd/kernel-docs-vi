.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/usage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Bài kiểm tra viết
=============

Trường hợp thử nghiệm
----------

Đơn vị cơ bản trong KUnit là trường hợp thử nghiệm. Một ca kiểm thử là một hàm có
chữ ký ZZ0000ZZ. Nó gọi hàm đang được thử nghiệm
và sau đó đặt ZZ0001ZZ để biết điều gì sẽ xảy ra. Ví dụ:

.. code-block:: c

	void example_test_success(struct kunit *test)
	{
	}

	void example_test_failure(struct kunit *test)
	{
		KUNIT_FAIL(test, "This test never passes.");
	}

Trong ví dụ trên, ZZ0000ZZ luôn vượt qua vì nó vượt qua
không có gì; không có kỳ vọng nào được đặt ra, và do đó mọi kỳ vọng đều trôi qua. Trên
mặt khác ZZ0001ZZ luôn thất bại vì nó gọi ZZ0002ZZ,
đó là một kỳ vọng đặc biệt ghi lại một thông báo và khiến trường hợp kiểm thử
thất bại.

Kỳ vọng
~~~~~~~~~~~~
ZZ0000ZZ chỉ định rằng chúng tôi mong đợi một đoạn mã sẽ thực hiện điều gì đó theo cách
kiểm tra. Một kỳ vọng được gọi giống như một hàm. Một bài kiểm tra được thực hiện bằng cách thiết lập
mong đợi về hành vi của một đoạn mã đang được thử nghiệm. Khi một hoặc nhiều
kỳ vọng thất bại, ca kiểm thử thất bại và thông tin về thất bại được
đã đăng nhập. Ví dụ:

.. code-block:: c

	void add_test_basic(struct kunit *test)
	{
		KUNIT_EXPECT_EQ(test, 1, add(1, 0));
		KUNIT_EXPECT_EQ(test, 2, add(1, 1));
	}

Trong ví dụ trên, ZZ0000ZZ đưa ra một số xác nhận về
hành vi của một hàm có tên ZZ0001ZZ. Tham số đầu tiên luôn thuộc loại
ZZ0002ZZ, chứa thông tin về bối cảnh thử nghiệm hiện tại.
Tham số thứ hai, trong trường hợp này, là giá trị dự kiến. các
giá trị cuối cùng là giá trị thực sự là gì. Nếu ZZ0003ZZ vượt qua tất cả những điều này
kỳ vọng, trường hợp thử nghiệm, ZZ0004ZZ sẽ vượt qua; nếu bất kỳ một trong số này
kỳ vọng không thành công, trường hợp thử nghiệm sẽ thất bại.

Trường hợp thử nghiệm ZZ0000ZZ khi bất kỳ kỳ vọng nào bị vi phạm; tuy nhiên, bài kiểm tra sẽ
tiếp tục chạy và thử các kỳ vọng khác cho đến khi trường hợp kiểm thử kết thúc hoặc
nếu không thì chấm dứt. Điều này trái ngược với ZZ0001ZZ đang được thảo luận
sau này.

Để tìm hiểu thêm về các kỳ vọng của KUnit, hãy xem Tài liệu/dev-tools/kunit/api/test.rst.

.. note::
   A single test case should be short, easy to understand, and focused on a
   single behavior.

Ví dụ: nếu chúng tôi muốn kiểm tra nghiêm ngặt hàm ZZ0000ZZ ở trên, hãy tạo
các trường hợp thử nghiệm bổ sung sẽ kiểm tra từng thuộc tính có chức năng ZZ0001ZZ
nên có như hình dưới đây:

.. code-block:: c

	void add_test_basic(struct kunit *test)
	{
		KUNIT_EXPECT_EQ(test, 1, add(1, 0));
		KUNIT_EXPECT_EQ(test, 2, add(1, 1));
	}

	void add_test_negative(struct kunit *test)
	{
		KUNIT_EXPECT_EQ(test, 0, add(-1, 1));
	}

	void add_test_max(struct kunit *test)
	{
		KUNIT_EXPECT_EQ(test, INT_MAX, add(0, INT_MAX));
		KUNIT_EXPECT_EQ(test, -1, add(INT_MAX, INT_MIN));
	}

	void add_test_overflow(struct kunit *test)
	{
		KUNIT_EXPECT_EQ(test, INT_MIN, add(INT_MAX, 1));
	}

Khẳng định
~~~~~~~~~~

Một khẳng định giống như một kỳ vọng, ngoại trừ việc khẳng định đó ngay lập tức
kết thúc trường hợp kiểm thử nếu điều kiện không được thỏa mãn. Ví dụ:

.. code-block:: c

	static void test_sort(struct kunit *test)
	{
		int *a, i, r = 1;
		a = kunit_kmalloc_array(test, TEST_LEN, sizeof(*a), GFP_KERNEL);
		KUNIT_ASSERT_NOT_ERR_OR_NULL(test, a);
		for (i = 0; i < TEST_LEN; i++) {
			r = (r * 725861) % 6599;
			a[i] = r;
		}
		sort(a, TEST_LEN, sizeof(*a), cmpint, NULL);
		for (i = 0; i < TEST_LEN-1; i++)
			KUNIT_EXPECT_LE(test, a[i], a[i + 1]);
	}

Trong ví dụ này, chúng ta cần có khả năng phân bổ một mảng để kiểm tra ZZ0000ZZ
chức năng. Vì vậy, chúng tôi sử dụng ZZ0001ZZ để hủy bỏ thử nghiệm nếu
có lỗi phân bổ.

.. note::
   In other test frameworks, ``ASSERT`` macros are often implemented by calling
   ``return`` so they only work from the test function. In KUnit, we stop the
   current kthread on failure, so you can call them from anywhere.

.. note::
   Warning: There is an exception to the above rule. You shouldn't use assertions
   in the suite's exit() function, or in the free function for a resource. These
   run when a test is shutting down, and an assertion here prevents further
   cleanup code from running, potentially leading to a memory leak.

Tùy chỉnh thông báo lỗi
--------------------------

Mỗi macro ZZ0000ZZ và ZZ0001ZZ đều có ZZ0002ZZ
biến thể.  Chúng lấy một chuỗi định dạng và các đối số để cung cấp thêm
context vào các thông báo lỗi được tạo tự động.

.. code-block:: c

	char some_str[41];
	generate_sha1_hex_string(some_str);

	/* Before. Not easy to tell why the test failed. */
	KUNIT_EXPECT_EQ(test, strlen(some_str), 40);

	/* After. Now we see the offending string. */
	KUNIT_EXPECT_EQ_MSG(test, strlen(some_str), 40, "some_str='%s'", some_str);

Ngoài ra, người ta có thể kiểm soát hoàn toàn thông báo lỗi bằng cách sử dụng
ZZ0000ZZ, ví dụ:

.. code-block:: c

	/* Before */
	KUNIT_EXPECT_EQ(test, some_setup_function(), 0);

	/* After: full control over the failure message. */
	if (some_setup_function())
		KUNIT_FAIL(test, "Failed to setup thing for testing");


Bộ thử nghiệm
~~~~~~~~~~~

Chúng tôi cần nhiều trường hợp thử nghiệm bao gồm tất cả các hành vi của đơn vị. It is common to have
nhiều bài kiểm tra tương tự. Để giảm sự trùng lặp trong những mối quan hệ chặt chẽ này
thử nghiệm, hầu hết các khung thử nghiệm đơn vị (bao gồm KUnit) đều cung cấp khái niệm về
ZZ0000ZZ. Bộ thử nghiệm là tập hợp các trường hợp thử nghiệm cho một đơn vị mã
với các chức năng thiết lập và chia nhỏ tùy chọn chạy trước/sau toàn bộ
bộ và/hoặc mọi trường hợp thử nghiệm.

.. note::
   A test case will only run if it is associated with a test suite.

Ví dụ:

.. code-block:: c

	static struct kunit_case example_test_cases[] = {
		KUNIT_CASE(example_test_foo),
		KUNIT_CASE(example_test_bar),
		KUNIT_CASE(example_test_baz),
		{}
	};

	static struct kunit_suite example_test_suite = {
		.name = "example",
		.init = example_test_init,
		.exit = example_test_exit,
		.suite_init = example_suite_init,
		.suite_exit = example_suite_exit,
		.test_cases = example_test_cases,
	};
	kunit_test_suite(example_test_suite);

Trong ví dụ trên, bộ thử nghiệm ZZ0000ZZ trước tiên sẽ chạy
ZZ0001ZZ, sau đó chạy các trường hợp thử nghiệm ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ. Mỗi người sẽ có
ZZ0005ZZ đã gọi ngay trước nó và ZZ0006ZZ
được gọi ngay sau nó. Cuối cùng, ZZ0007ZZ sẽ được gọi
sau mọi thứ khác. ZZ0008ZZ đăng ký
bộ thử nghiệm với khung kiểm tra KUnit.

.. note::
   The ``exit`` and ``suite_exit`` functions will run even if ``init`` or
   ``suite_init`` fail. Make sure that they can handle any inconsistent
   state which may result from ``init`` or ``suite_init`` encountering errors
   or exiting early.

ZZ0000ZZ là một macro yêu cầu trình liên kết đặt
bộ thử nghiệm được chỉ định trong phần liên kết đặc biệt để KUnit có thể chạy nó
sau ZZ0001ZZ hoặc khi mô-đun thử nghiệm được tải (nếu thử nghiệm được thực hiện
được xây dựng dưới dạng mô-đun).

Để biết thêm thông tin, hãy xem Tài liệu/dev-tools/kunit/api/test.rst.

.. _kunit-on-non-uml:

Viết bài kiểm tra cho các kiến ​​trúc khác
-------------------------------------

Tốt hơn là viết các bài kiểm tra chạy trên UML thành các bài kiểm tra chỉ chạy trong
kiến trúc đặc biệt. Tốt hơn là viết các bài kiểm tra chạy dưới QEMU hoặc
một môi trường phần mềm dễ dàng có được (và miễn phí về mặt tài chính) khác cho một môi trường cụ thể
một phần cứng.

Tuy nhiên, vẫn có những lý do chính đáng để viết một bài kiểm thử về kiến trúc
hoặc phần cứng cụ thể. Ví dụ: chúng tôi có thể muốn kiểm tra mã thực sự
thuộc về ZZ0000ZZ. Mặc dù vậy, hãy cố gắng viết bài kiểm tra để nó thực hiện được
không phụ thuộc vào phần cứng vật lý. Một số trường hợp thử nghiệm của chúng tôi có thể không cần phần cứng,
chỉ có một số thử nghiệm thực sự yêu cầu phần cứng để kiểm tra nó. Khi phần cứng không có
có sẵn, thay vì tắt các bài kiểm tra, chúng ta có thể bỏ qua chúng.

Bây giờ chúng ta đã thu hẹp chính xác những bit nào là phần cứng cụ thể,
quy trình thực tế để viết và chạy thử nghiệm cũng giống như viết bình thường
Kiểm tra KUnit.

.. important::
   We may have to reset hardware state. If this is not possible, we may only
   be able to run one test case per invocation.

.. TODO(brendanhiggins@google.com): Add an actual example of an architecture-
   dependent KUnit test.

Các mẫu chung
===============

Hành vi cô lập
------------------

Kiểm thử đơn vị giới hạn số lượng mã được kiểm thử ở một đơn vị. Nó điều khiển
mã nào sẽ được chạy khi đơn vị được kiểm tra gọi một hàm. Trường hợp một chức năng
được hiển thị như một phần của API sao cho định nghĩa của hàm đó có thể được
thay đổi mà không ảnh hưởng đến phần còn lại của cơ sở mã. Trong kernel, cái này xuất hiện
từ hai cấu trúc: các lớp, là các cấu trúc chứa các con trỏ hàm
được cung cấp bởi người triển khai và các chức năng theo kiến trúc cụ thể, có
định nghĩa được chọn tại thời điểm biên dịch.

Lớp học
~~~~~~~

Các lớp không phải là một cấu trúc được tích hợp sẵn trong ngôn ngữ lập trình C;
tuy nhiên, nó là một khái niệm dễ dàng bắt nguồn. Theo đó, trong hầu hết các trường hợp, mọi
dự án không sử dụng thư viện hướng đối tượng được tiêu chuẩn hóa (như GNOME's
GObject) có cách thực hiện hướng đối tượng hơi khác một chút
lập trình; nhân Linux cũng không ngoại lệ.

Khái niệm trung tâm trong lập trình hướng đối tượng kernel là lớp. trong
kernel, ZZ0000ZZ là một cấu trúc chứa các con trỏ hàm. Điều này tạo ra một
hợp đồng giữa ZZ0001ZZ và ZZ0002ZZ vì nó buộc họ phải sử dụng
chữ ký hàm tương tự mà không cần phải gọi hàm trực tiếp. Để trở thành một
lớp, các con trỏ hàm phải chỉ định rằng một con trỏ tới lớp, được gọi là
ZZ0003ZZ, là một trong các tham số. Do đó các hàm thành viên (cũng
được gọi là ZZ0004ZZ) có quyền truy cập vào các biến thành viên (còn được gọi là ZZ0005ZZ)
cho phép triển khai tương tự để có nhiều ZZ0006ZZ.

Một lớp có thể là ZZ0000ZZ bởi ZZ0001ZZ bằng cách nhúng ZZ0002ZZ
ở lớp con. Sau đó, khi lớp con ZZ0003ZZ được gọi, lớp con
việc triển khai biết rằng con trỏ được truyền tới nó là của một phần tử cha được chứa
bên trong đứa trẻ. Vì vậy, đứa trẻ có thể tính toán con trỏ tới chính nó vì
con trỏ tới cha mẹ luôn là một khoảng cách cố định từ con trỏ tới con.
Phần bù này là phần bù của phần tử cha có trong cấu trúc con. Ví dụ:

.. code-block:: c

	struct shape {
		int (*area)(struct shape *this);
	};

	struct rectangle {
		struct shape parent;
		int length;
		int width;
	};

	int rectangle_area(struct shape *this)
	{
		struct rectangle *self = container_of(this, struct rectangle, parent);

		return self->length * self->width;
	};

	void rectangle_new(struct rectangle *self, int length, int width)
	{
		self->parent.area = rectangle_area;
		self->length = length;
		self->width = width;
	}

Trong ví dụ này, việc tính toán con trỏ tới trẻ từ con trỏ đến
cha mẹ được thực hiện bởi ZZ0000ZZ.

Lớp học giả mạo
~~~~~~~~~~~~~~

Để kiểm tra đơn vị một đoạn mã gọi một phương thức trong một lớp,
hành vi của phương pháp phải được kiểm soát, nếu không thử nghiệm sẽ không còn là một thử nghiệm
kiểm thử đơn vị và trở thành kiểm thử tích hợp.

Một lớp giả sẽ triển khai một đoạn mã khác với đoạn mã chạy trong
phiên bản sản xuất, nhưng hoạt động giống hệt nhau theo quan điểm của người gọi.
Điều này được thực hiện để thay thế một phần phụ thuộc khó xử lý hoặc chậm. cho
ví dụ: triển khai EEPROM giả để lưu trữ "nội dung" trong một
bộ đệm bên trong. Giả sử chúng ta có một lớp đại diện cho EEPROM:

.. code-block:: c

	struct eeprom {
		ssize_t (*read)(struct eeprom *this, size_t offset, char *buffer, size_t count);
		ssize_t (*write)(struct eeprom *this, size_t offset, const char *buffer, size_t count);
	};

Và chúng tôi muốn kiểm tra mã mà bộ đệm ghi vào EEPROM:

.. code-block:: c

	struct eeprom_buffer {
		ssize_t (*write)(struct eeprom_buffer *this, const char *buffer, size_t count);
		int flush(struct eeprom_buffer *this);
		size_t flush_count; /* Flushes when buffer exceeds flush_count. */
	};

	struct eeprom_buffer *new_eeprom_buffer(struct eeprom *eeprom);
	void destroy_eeprom_buffer(struct eeprom *eeprom);

Chúng tôi có thể kiểm tra mã này bằng ZZ0000ZZ EEPROM cơ bản:

.. code-block:: c

	struct fake_eeprom {
		struct eeprom parent;
		char contents[FAKE_EEPROM_CONTENTS_SIZE];
	};

	ssize_t fake_eeprom_read(struct eeprom *parent, size_t offset, char *buffer, size_t count)
	{
		struct fake_eeprom *this = container_of(parent, struct fake_eeprom, parent);

		count = min(count, FAKE_EEPROM_CONTENTS_SIZE - offset);
		memcpy(buffer, this->contents + offset, count);

		return count;
	}

	ssize_t fake_eeprom_write(struct eeprom *parent, size_t offset, const char *buffer, size_t count)
	{
		struct fake_eeprom *this = container_of(parent, struct fake_eeprom, parent);

		count = min(count, FAKE_EEPROM_CONTENTS_SIZE - offset);
		memcpy(this->contents + offset, buffer, count);

		return count;
	}

	void fake_eeprom_init(struct fake_eeprom *this)
	{
		this->parent.read = fake_eeprom_read;
		this->parent.write = fake_eeprom_write;
		memset(this->contents, 0, FAKE_EEPROM_CONTENTS_SIZE);
	}

Bây giờ chúng ta có thể sử dụng nó để kiểm tra ZZ0000ZZ:

.. code-block:: c

	struct eeprom_buffer_test {
		struct fake_eeprom *fake_eeprom;
		struct eeprom_buffer *eeprom_buffer;
	};

	static void eeprom_buffer_test_does_not_write_until_flush(struct kunit *test)
	{
		struct eeprom_buffer_test *ctx = test->priv;
		struct eeprom_buffer *eeprom_buffer = ctx->eeprom_buffer;
		struct fake_eeprom *fake_eeprom = ctx->fake_eeprom;
		char buffer[] = {0xff};

		eeprom_buffer->flush_count = SIZE_MAX;

		eeprom_buffer->write(eeprom_buffer, buffer, 1);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[0], 0);

		eeprom_buffer->write(eeprom_buffer, buffer, 1);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[1], 0);

		eeprom_buffer->flush(eeprom_buffer);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[0], 0xff);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[1], 0xff);
	}

	static void eeprom_buffer_test_flushes_after_flush_count_met(struct kunit *test)
	{
		struct eeprom_buffer_test *ctx = test->priv;
		struct eeprom_buffer *eeprom_buffer = ctx->eeprom_buffer;
		struct fake_eeprom *fake_eeprom = ctx->fake_eeprom;
		char buffer[] = {0xff};

		eeprom_buffer->flush_count = 2;

		eeprom_buffer->write(eeprom_buffer, buffer, 1);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[0], 0);

		eeprom_buffer->write(eeprom_buffer, buffer, 1);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[0], 0xff);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[1], 0xff);
	}

	static void eeprom_buffer_test_flushes_increments_of_flush_count(struct kunit *test)
	{
		struct eeprom_buffer_test *ctx = test->priv;
		struct eeprom_buffer *eeprom_buffer = ctx->eeprom_buffer;
		struct fake_eeprom *fake_eeprom = ctx->fake_eeprom;
		char buffer[] = {0xff, 0xff};

		eeprom_buffer->flush_count = 2;

		eeprom_buffer->write(eeprom_buffer, buffer, 1);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[0], 0);

		eeprom_buffer->write(eeprom_buffer, buffer, 2);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[0], 0xff);
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[1], 0xff);
		/* Should have only flushed the first two bytes. */
		KUNIT_EXPECT_EQ(test, fake_eeprom->contents[2], 0);
	}

	static int eeprom_buffer_test_init(struct kunit *test)
	{
		struct eeprom_buffer_test *ctx;

		ctx = kunit_kzalloc(test, sizeof(*ctx), GFP_KERNEL);
		KUNIT_ASSERT_NOT_ERR_OR_NULL(test, ctx);

		ctx->fake_eeprom = kunit_kzalloc(test, sizeof(*ctx->fake_eeprom), GFP_KERNEL);
		KUNIT_ASSERT_NOT_ERR_OR_NULL(test, ctx->fake_eeprom);
		fake_eeprom_init(ctx->fake_eeprom);

		ctx->eeprom_buffer = new_eeprom_buffer(&ctx->fake_eeprom->parent);
		KUNIT_ASSERT_NOT_ERR_OR_NULL(test, ctx->eeprom_buffer);

		test->priv = ctx;

		return 0;
	}

	static void eeprom_buffer_test_exit(struct kunit *test)
	{
		struct eeprom_buffer_test *ctx = test->priv;

		destroy_eeprom_buffer(ctx->eeprom_buffer);
	}

Kiểm tra nhiều đầu vào
-------------------------------

Chỉ kiểm tra một vài đầu vào là không đủ để đảm bảo mã hoạt động chính xác,
ví dụ: kiểm tra hàm băm.

Chúng ta có thể viết macro hoặc hàm trợ giúp. Hàm này được gọi cho mỗi đầu vào.
Ví dụ: để kiểm tra ZZ0000ZZ, chúng ta có thể viết:

.. code-block:: c

	#define TEST_SHA1(in, want) \
		sha1sum(in, out); \
		KUNIT_EXPECT_STREQ_MSG(test, out, want, "sha1sum(%s)", in);

	char out[40];
	TEST_SHA1("hello world",  "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed");
	TEST_SHA1("hello world!", "430ce34d020724ed75a196dfc2ad67c77772d169");

Lưu ý việc sử dụng phiên bản ZZ0000ZZ của ZZ0001ZZ để in thêm
lỗi chi tiết và làm cho các xác nhận rõ ràng hơn trong macro trợ giúp.

Các biến thể ZZ0000ZZ rất hữu ích khi cùng một kỳ vọng được gọi là nhiều
lần (trong một vòng lặp hoặc hàm trợ giúp) và do đó số dòng không đủ để
identify what failed, as shown below.

Trong những trường hợp phức tạp, chúng tôi khuyên bạn nên sử dụng ZZ0000ZZ so với
biến thể macro trợ giúp, ví dụ:

.. code-block:: c

	int i;
	char out[40];

	struct sha1_test_case {
		const char *str;
		const char *sha1;
	};

	struct sha1_test_case cases[] = {
		{
			.str = "hello world",
			.sha1 = "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed",
		},
		{
			.str = "hello world!",
			.sha1 = "430ce34d020724ed75a196dfc2ad67c77772d169",
		},
	};
	for (i = 0; i < ARRAY_SIZE(cases); ++i) {
		sha1sum(cases[i].str, out);
		KUNIT_EXPECT_STREQ_MSG(test, out, cases[i].sha1,
		                      "sha1sum(%s)", cases[i].str);
	}


Có nhiều mã soạn sẵn hơn, nhưng nó có thể:

* dễ đọc hơn khi có nhiều đầu vào/đầu ra (do tên trường).

* Ví dụ: xem ZZ0000ZZ.

* giảm sự trùng lặp nếu các trường hợp thử nghiệm được chia sẻ qua nhiều thử nghiệm.

* Ví dụ: nếu chúng tôi muốn kiểm tra ZZ0000ZZ, chúng tôi có thể thêm ZZ0001ZZ
    trường và tái sử dụng ZZ0002ZZ.

* được chuyển đổi thành "thử nghiệm tham số hóa".

Kiểm tra tham số
~~~~~~~~~~~~~~~~~~~~~

Để chạy một trường hợp kiểm thử với nhiều đầu vào, KUnit cung cấp một cơ chế được tham số hóa
khuôn khổ thử nghiệm. Tính năng này chính thức hóa và mở rộng khái niệm về
các bài kiểm tra dựa trên bảng đã thảo luận trước đó.

Kiểm tra KUnit được xác định là được tham số hóa nếu hàm tạo tham số
được cung cấp khi đăng ký test case. Người dùng thử nghiệm có thể viết
chức năng tạo riêng hoặc sử dụng chức năng do KUnit cung cấp. Máy phát điện
được lưu trữ trong ZZ0000ZZ và có thể được thiết lập bằng cách sử dụng
macro được mô tả trong phần bên dưới.

Để thiết lập thuật ngữ, "thử nghiệm tham số hóa" là thử nghiệm được chạy
nhiều lần (một lần cho mỗi "tham số" hoặc "chạy tham số"). Mỗi lần chạy tham số có
cả ZZ0000ZZ độc lập của riêng nó ("ngữ cảnh chạy tham số") và
quyền truy cập vào ZZ0001ZZ gốc được chia sẻ ("ngữ cảnh thử nghiệm được tham số hóa").

Truyền tham số cho bài kiểm tra
^^^^^^^^^^^^^^^^^^^^^^^^^^^^
Có ba cách để cung cấp các tham số cho bài kiểm tra:

Macro tham số mảng:

KUnit cung cấp hỗ trợ đặc biệt cho mẫu thử nghiệm dựa trên bảng phổ biến.
   Bằng cách áp dụng ZZ0000ZZ hoặc ZZ0001ZZ cho
   Mảng ZZ0002ZZ từ phần trước, chúng ta có thể tạo một bài kiểm tra được tham số hóa
   như hình dưới đây:

.. code-block:: c

	// This is copy-pasted from above.
	struct sha1_test_case {
		const char *str;
		const char *sha1;
	};
	static const struct sha1_test_case cases[] = {
		{
			.str = "hello world",
			.sha1 = "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed",
		},
		{
			.str = "hello world!",
			.sha1 = "430ce34d020724ed75a196dfc2ad67c77772d169",
		},
	};

	// Creates `sha1_gen_params()` to iterate over `cases` while using
	// the struct member `str` for the case description.
	KUNIT_ARRAY_PARAM_DESC(sha1, cases, str);

	// Looks no different from a normal test.
	static void sha1_test(struct kunit *test)
	{
		// This function can just contain the body of the for-loop.
		// The former `cases[i]` is accessible under test->param_value.
		char out[40];
		struct sha1_test_case *test_param = (struct sha1_test_case *)(test->param_value);

		sha1sum(test_param->str, out);
		KUNIT_EXPECT_STREQ_MSG(test, out, test_param->sha1,
				      "sha1sum(%s)", test_param->str);
	}

	// Instead of KUNIT_CASE, we use KUNIT_CASE_PARAM and pass in the
	// function declared by KUNIT_ARRAY_PARAM or KUNIT_ARRAY_PARAM_DESC.
	static struct kunit_case sha1_test_cases[] = {
		KUNIT_CASE_PARAM(sha1_test, sha1_gen_params),
		{}
	};

Chức năng tạo tham số tùy chỉnh:

Hàm tạo có trách nhiệm tạo từng tham số một
   và có chữ ký sau:
   ZZ0000ZZ.
   Bạn có thể chuyển chức năng tạo cho ZZ0001ZZ
   hoặc macro ZZ0002ZZ.

Hàm nhận tham số được tạo trước đó làm đối số ZZ0000ZZ
   (là ZZ0001ZZ trong cuộc gọi đầu tiên) và cũng có thể truy cập vào tham số
   ngữ cảnh thử nghiệm được chuyển dưới dạng đối số ZZ0002ZZ. KUnit gọi hàm này
   lặp đi lặp lại cho đến khi nó trả về ZZ0003ZZ, điều này biểu thị rằng một tham số đã được tham số hóa
   bài kiểm tra kết thúc.

Dưới đây là một ví dụ về cách nó hoạt động:

.. code-block:: c

	#define MAX_TEST_BUFFER_SIZE 8

	// Example generator function. It produces a sequence of buffer sizes that
	// are powers of two, starting at 1 (e.g., 1, 2, 4, 8).
	static const void *buffer_size_gen_params(struct kunit *test, const void *prev, char *desc)
	{
		long prev_buffer_size = (long)prev;
		long next_buffer_size = 1; // Start with an initial size of 1.

		// Stop generating parameters if the limit is reached or exceeded.
		if (prev_buffer_size >= MAX_TEST_BUFFER_SIZE)
			return NULL;

		// For subsequent calls, calculate the next size by doubling the previous one.
		if (prev)
			next_buffer_size = prev_buffer_size << 1;

		return (void *)next_buffer_size;
	}

	// Simple test to validate that kunit_kzalloc provides zeroed memory.
	static void buffer_zero_test(struct kunit *test)
	{
		long buffer_size = (long)test->param_value;
		// Use kunit_kzalloc to allocate a zero-initialized buffer. This makes the
		// memory "parameter run managed," meaning it's automatically cleaned up at
		// the end of each parameter run.
		int *buf = kunit_kzalloc(test, buffer_size * sizeof(int), GFP_KERNEL);

		// Ensure the allocation was successful.
		KUNIT_ASSERT_NOT_NULL(test, buf);

		// Loop through the buffer and confirm every element is zero.
		for (int i = 0; i < buffer_size; i++)
			KUNIT_EXPECT_EQ(test, buf[i], 0);
	}

	static struct kunit_case buffer_test_cases[] = {
		KUNIT_CASE_PARAM(buffer_zero_test, buffer_size_gen_params),
		{}
	};

Đăng ký mảng tham số thời gian chạy trong hàm init:

Đối với các tình huống mà bạn có thể cần khởi tạo thử nghiệm được tham số hóa, bạn
   có thể đăng ký trực tiếp một mảng tham số vào bối cảnh thử nghiệm được tham số hóa.

Để làm điều này, bạn phải vượt qua bối cảnh kiểm tra được tham số hóa, chính mảng đó,
   kích thước mảng và hàm ZZ0000ZZ cho
   Macro ZZ0001ZZ. Macro này cư trú
   ZZ0002ZZ trong bối cảnh thử nghiệm được tham số hóa một cách hiệu quả
   lưu trữ một đối tượng mảng tham số. Chức năng ZZ0003ZZ sẽ
   được sử dụng để điền các mô tả tham số và có chữ ký sau:
   ZZ0004ZZ. Lưu ý rằng nó
   cũng có quyền truy cập vào bối cảnh thử nghiệm được tham số hóa.

      .. important::
         When using this way to register a parameter array, you will need to
         manually pass ``kunit_array_gen_params()`` as the generator function to
         ``KUNIT_CASE_PARAM_WITH_INIT``. ``kunit_array_gen_params()`` is a KUnit
         helper that will use the registered array to generate the parameters.

Nếu cần, thay vì chuyển trình trợ giúp KUnit, bạn cũng có thể chuyển
	 chức năng tạo tùy chỉnh riêng sử dụng mảng tham số. Đến
	 truy cập mảng tham số từ bên trong bộ tạo tham số
	 chức năng sử dụng ZZ0000ZZ.

Macro ZZ0000ZZ sẽ được gọi trong một
   Chức năng ZZ0001ZZ khởi tạo thử nghiệm được tham số hóa và có
   chữ ký sau ZZ0002ZZ. Để biết chi tiết
   giải thích về cơ chế này vui lòng tham khảo phần "Thêm tài nguyên chia sẻ"
   phần sau phần này. Phương pháp này hỗ trợ đăng ký cả
   mảng tham số tĩnh và được xây dựng động.

Đoạn mã bên dưới hiển thị bài kiểm tra ZZ0000ZZ
   sử dụng ZZ0001ZZ để tạo một mảng động, sau đó
   đã đăng ký bằng ZZ0002ZZ. Để xem mã đầy đủ
   vui lòng tham khảo lib/kunit/kunit-example-test.c.

.. code-block:: c

	/*
	* Example of a parameterized test param_init() function that registers a dynamic
	* array of parameters.
	*/
	static int example_param_init_dynamic_arr(struct kunit *test)
	{
		size_t seq_size;
		int *fibonacci_params;

		kunit_info(test, "initializing parameterized test\n");

		seq_size = 6;
		fibonacci_params = make_fibonacci_params(test, seq_size);
		if (!fibonacci_params)
			return -ENOMEM;
		/*
		* Passes the dynamic parameter array information to the parameterized test
		* context struct kunit. The array and its metadata will be stored in
		* test->parent->params_array. The array itself will be located in
		* params_data.params.
		*/
		kunit_register_params_array(test, fibonacci_params, seq_size,
					example_param_dynamic_arr_get_desc);
		return 0;
	}

	static struct kunit_case example_test_cases[] = {
		/*
		 * Note how we pass kunit_array_gen_params() to use the array we
		 * registered in example_param_init_dynamic_arr() to generate
		 * parameters.
		 */
		KUNIT_CASE_PARAM_WITH_INIT(example_params_test_with_init_dynamic_arr,
					   kunit_array_gen_params,
					   example_param_init_dynamic_arr,
					   example_param_exit_dynamic_arr),
		{}
	};

Thêm tài nguyên được chia sẻ
^^^^^^^^^^^^^^^^^^^^^^^
Tất cả các tham số chạy trong khung này đều chứa tham chiếu đến thử nghiệm được tham số hóa
bối cảnh, có thể được truy cập bằng con trỏ ZZ0000ZZ gốc. các
bối cảnh kiểm tra được tham số hóa không được sử dụng để thực thi bất kỳ logic kiểm tra nào; thay vào đó,
nó phục vụ như một nơi chứa các tài nguyên được chia sẻ.

Có thể thêm tài nguyên để chia sẻ giữa các lần chạy tham số trong một
kiểm tra được tham số hóa bằng cách sử dụng ZZ0000ZZ mà bạn vượt qua
các chức năng ZZ0001ZZ và ZZ0002ZZ tùy chỉnh. Các chức năng này chạy một lần
trước và một lần sau khi kiểm tra tham số tương ứng.

Chức năng ZZ0000ZZ, với chữ ký ZZ0001ZZ,
có thể được sử dụng để thêm tài nguyên vào các trường ZZ0002ZZ hoặc ZZ0003ZZ của
bối cảnh kiểm tra được tham số hóa, đăng ký mảng tham số và bất kỳ nội dung nào khác
logic khởi tạo.

Chức năng ZZ0000ZZ, với chữ ký ZZ0001ZZ,
có thể được sử dụng để giải phóng bất kỳ tài nguyên nào không được quản lý kiểm tra tham số hóa (tức là
không được tự động dọn sạch sau khi quá trình kiểm tra tham số hóa kết thúc) và đối với bất kỳ trường hợp nào khác
logic thoát.

Cả ZZ0000ZZ và ZZ0001ZZ đều đã vượt qua bài kiểm tra tham số hóa
bối cảnh đằng sau hậu trường. Tuy nhiên, hàm test case nhận tham số
chạy bối cảnh. Do đó, để quản lý và truy cập các tài nguyên được chia sẻ từ bên trong một thử nghiệm
chức năng trường hợp, bạn phải sử dụng ZZ0002ZZ.

Ví dụ: việc tìm tài nguyên dùng chung được phân bổ bởi Tài nguyên API yêu cầu
chuyển ZZ0000ZZ tới ZZ0001ZZ. Nguyên tắc này mở rộng đến
tất cả các API khác có thể được sử dụng trong chức năng trường hợp thử nghiệm, bao gồm
ZZ0002ZZ, ZZ0003ZZ và các loại khác (xem
Tài liệu/dev-tools/kunit/api/test.rst và
Tài liệu/dev-tools/kunit/api/resource.rst).

.. note::
   The ``suite->init()`` function, which executes before each parameter run,
   receives the parameter run context. Therefore, any resources set up in
   ``suite->init()`` are cleaned up after each parameter run.

Mã bên dưới cho biết cách bạn có thể thêm tài nguyên được chia sẻ. Lưu ý rằng mã này
sử dụng Tài nguyên API mà bạn có thể đọc thêm tại đây:
Tài liệu/dev-tools/kunit/api/resource.rst. Để xem phiên bản đầy đủ của điều này
mã vui lòng tham khảo lib/kunit/kunit-example-test.c.

.. code-block:: c

	static int example_resource_init(struct kunit_resource *res, void *context)
	{
		... /* Code that allocates memory and stores context in res->data. */
	}

	/* This function deallocates memory for the kunit_resource->data field. */
	static void example_resource_free(struct kunit_resource *res)
	{
		kfree(res->data);
	}

	/* This match function locates a test resource based on defined criteria. */
	static bool example_resource_alloc_match(struct kunit *test, struct kunit_resource *res,
						 void *match_data)
	{
		return res->data && res->free == example_resource_free;
	}

	/* Function to initialize the parameterized test. */
	static int example_param_init(struct kunit *test)
	{
		int ctx = 3; /* Data to be stored. */
		void *data = kunit_alloc_resource(test, example_resource_init,
						  example_resource_free,
						  GFP_KERNEL, &ctx);
		if (!data)
			return -ENOMEM;
		kunit_register_params_array(test, example_params_array,
					    ARRAY_SIZE(example_params_array));
		return 0;
	}

	/* Example test that uses shared resources in test->resources. */
	static void example_params_test_with_init(struct kunit *test)
	{
		int threshold;
		const struct example_param *param = test->param_value;
		/*  Here we pass test->parent to access the parameterized test context. */
		struct kunit_resource *res = kunit_find_resource(test->parent,
								 example_resource_alloc_match,
								 NULL);

		threshold = *((int *)res->data);
		KUNIT_ASSERT_LE(test, param->value, threshold);
		kunit_put_resource(res);
	}

	static struct kunit_case example_test_cases[] = {
		KUNIT_CASE_PARAM_WITH_INIT(example_params_test_with_init, kunit_array_gen_params,
					   example_param_init, NULL),
		{}
	};

Để thay thế cho việc sử dụng KUnit Resource API để chia sẻ tài nguyên, bạn có thể
đặt chúng vào ZZ0000ZZ. Đây là một phương pháp nhẹ hơn
để lưu trữ tài nguyên, tốt nhất cho các tình huống quản lý tài nguyên phức tạp
không bắt buộc.

Như đã nêu trước đây ZZ0000ZZ và ZZ0001ZZ nhận được tham số hóa
bối cảnh thử nghiệm. Vì vậy, bạn có thể trực tiếp sử dụng ZZ0002ZZ trong ZZ0003ZZ
để quản lý các tài nguyên được chia sẻ. Tuy nhiên, từ bên trong hàm test case, bạn phải
điều hướng đến ZZ0004ZZ gốc, tức là bối cảnh kiểm tra được tham số hóa.
Vì vậy, bạn cần sử dụng ZZ0005ZZ để truy cập những thứ tương tự
tài nguyên.

Các tài nguyên được đặt trong ZZ0000ZZ sẽ cần được phân bổ theo
bộ nhớ để tồn tại trong suốt quá trình chạy tham số. Nếu bộ nhớ được cấp phát bằng cách sử dụng
API cấp phát bộ nhớ KUnit (được mô tả thêm trong phần "Cấp phát bộ nhớ"
bên dưới), bạn sẽ không cần phải lo lắng về việc phân bổ. Các API sẽ tạo ra bộ nhớ
kiểm tra tham số 'được quản lý', đảm bảo rằng nó sẽ tự động được dọn sạch
sau khi thử nghiệm tham số hóa kết thúc.

Mã bên dưới minh hoạ cách sử dụng ví dụ của trường ZZ0000ZZ cho chia sẻ
tài nguyên:

.. code-block:: c

	static const struct example_param {
		int value;
	} example_params_array[] = {
		{ .value = 3, },
		{ .value = 2, },
		{ .value = 1, },
		{ .value = 0, },
	};

	/* Initialize the parameterized test context. */
	static int example_param_init_priv(struct kunit *test)
	{
		int ctx = 3; /* Data to be stored. */
		int arr_size = ARRAY_SIZE(example_params_array);

		/*
		 * Allocate memory using kunit_kzalloc(). Since the `param_init`
		 * function receives the parameterized test context, this memory
		 * allocation will be scoped to the lifetime of the parameterized test.
		 */
		test->priv = kunit_kzalloc(test, sizeof(int), GFP_KERNEL);

		/* Assign the context value to test->priv.*/
		*((int *)test->priv) = ctx;

		/* Register the parameter array. */
		kunit_register_params_array(test, example_params_array, arr_size, NULL);
		return 0;
	}

	static void example_params_test_with_init_priv(struct kunit *test)
	{
		int threshold;
		const struct example_param *param = test->param_value;

		/* By design, test->parent will not be NULL. */
		KUNIT_ASSERT_NOT_NULL(test, test->parent);

		/* Here we use test->parent->priv to access the shared resource. */
		threshold = *(int *)test->parent->priv;

		KUNIT_ASSERT_LE(test, param->value, threshold);
	}

	static struct kunit_case example_tests[] = {
		KUNIT_CASE_PARAM_WITH_INIT(example_params_test_with_init_priv,
					   kunit_array_gen_params,
					   example_param_init_priv, NULL),
		{}
	};

Phân bổ bộ nhớ
-----------------

Nơi bạn có thể sử dụng ZZ0000ZZ, thay vào đó bạn có thể sử dụng ZZ0001ZZ làm KUnit
sau đó sẽ đảm bảo rằng bộ nhớ được giải phóng sau khi quá trình kiểm tra hoàn tất.

Điều này rất hữu ích vì nó cho phép chúng tôi sử dụng macro ZZ0000ZZ để thoát
sớm khỏi bài kiểm tra mà không cần phải lo lắng về việc nhớ gọi ZZ0001ZZ.
Ví dụ:

.. code-block:: c

	void example_test_allocation(struct kunit *test)
	{
		char *buffer = kunit_kzalloc(test, 16, GFP_KERNEL);
		/* Ensure allocation succeeded. */
		KUNIT_ASSERT_NOT_ERR_OR_NULL(test, buffer);

		KUNIT_ASSERT_STREQ(test, buffer, "");
	}

Đăng ký hành động dọn dẹp
---------------------------

Nếu bạn cần thực hiện một số thao tác dọn dẹp ngoài việc sử dụng ZZ0000ZZ đơn giản,
bạn có thể đăng ký một "hành động trì hoãn" tùy chỉnh, đó là chức năng dọn dẹp
chạy khi quá trình kiểm tra kết thúc (dù là hoàn toàn hay thông qua xác nhận không thành công).

Hành động là các hàm đơn giản không có giá trị trả về và một ZZ0000ZZ duy nhất
đối số ngữ cảnh và thực hiện vai trò tương tự như các hàm "dọn dẹp" trong Python
và kiểm tra Go, các câu lệnh "trì hoãn" bằng các ngôn ngữ hỗ trợ chúng và
(trong một số trường hợp) hàm hủy trong ngôn ngữ RAII.

Chúng rất hữu ích cho việc hủy đăng ký mọi thứ khỏi danh sách chung, đóng
các tập tin hoặc các tài nguyên khác, hoặc giải phóng tài nguyên.

Ví dụ:

.. code-block:: C

	static void cleanup_device(void *ctx)
	{
		struct device *dev = (struct device *)ctx;

		device_unregister(dev);
	}

	void example_device_test(struct kunit *test)
	{
		struct my_device dev;

		device_register(&dev);

		kunit_add_action(test, &cleanup_device, &dev);
	}

Lưu ý rằng, đối với các hàm như device_unregister chỉ chấp nhận một
đối số có kích thước con trỏ, có thể tự động tạo trình bao bọc
với macro ZZ0000ZZ, ví dụ:

.. code-block:: C

	KUNIT_DEFINE_ACTION_WRAPPER(device_unregister, device_unregister_wrapper, struct device *);
	kunit_add_action(test, &device_unregister_wrapper, &dev);

Bạn nên thực hiện việc này thay vì truyền thủ công sang loại ZZ0000ZZ,
vì các con trỏ hàm truyền sẽ phá vỡ Tính toàn vẹn của luồng điều khiển (CFI).

ZZ0000ZZ có thể bị lỗi nếu hệ thống hết bộ nhớ chẳng hạn.
Bạn có thể sử dụng ZZ0001ZZ để chạy hành động
ngay lập tức nếu không thể trì hoãn được.

Nếu bạn cần kiểm soát nhiều hơn khi chức năng dọn dẹp được gọi, bạn
có thể kích hoạt sớm bằng ZZ0000ZZ hoặc hủy hoàn toàn
với ZZ0001ZZ.


Kiểm tra các hàm tĩnh
------------------------

Nếu bạn muốn kiểm tra các hàm tĩnh mà không để lộ các hàm đó ra bên ngoài
thử nghiệm, một tùy chọn là xuất ký hiệu có điều kiện. Khi KUnit được kích hoạt,
biểu tượng được hiển thị nhưng mặt khác vẫn tĩnh. Để sử dụng phương pháp này, hãy làm theo
mẫu dưới đây.

.. code-block:: c

	/* In the file containing functions to test "my_file.c" */

	#include <kunit/visibility.h>
	#include <my_file.h>
	...
	VISIBLE_IF_KUNIT int do_interesting_thing()
	{
	...
	}
	EXPORT_SYMBOL_IF_KUNIT(do_interesting_thing);

	/* In the header file "my_file.h" */

	#if IS_ENABLED(CONFIG_KUNIT)
		int do_interesting_thing(void);
	#endif

	/* In the KUnit test file "my_file_test.c" */

	#include <kunit/visibility.h>
	#include <my_file.h>
	...
	MODULE_IMPORT_NS("EXPORTED_FOR_KUNIT_TESTING");
	...
	// Use do_interesting_thing() in tests

Để biết ví dụ đầy đủ, hãy xem ZZ0000ZZ này
trong đó thử nghiệm được sửa đổi để hiển thị có điều kiện các hàm tĩnh để thử nghiệm
bằng cách sử dụng các macro ở trên.

Là một ZZ0001ZZ cho phương pháp trên, bạn có thể có điều kiện ZZ0000ZZ
tệp kiểm tra ở cuối tệp .c của bạn. Điều này không được khuyến khích nhưng hoạt động
nếu cần. Ví dụ:

.. code-block:: c

	/* In "my_file.c" */

	static int do_interesting_thing();

	#ifdef CONFIG_MY_KUNIT_TEST
	#include "my_kunit_test.c"
	#endif

Chèn mã chỉ kiểm tra
------------------------

Tương tự như được hiển thị ở trên, chúng ta có thể thêm logic dành riêng cho thử nghiệm. Ví dụ:

.. code-block:: c

	/* In my_file.h */

	#ifdef CONFIG_MY_KUNIT_TEST
	/* Defined in my_kunit_test.c */
	void test_only_hook(void);
	#else
	void test_only_hook(void) { }
	#endif

Mã chỉ dành cho thử nghiệm này có thể trở nên hữu ích hơn bằng cách truy cập ZZ0000ZZ hiện tại
như được hiển thị trong phần tiếp theo: ZZ0001ZZ.

Truy cập bài kiểm tra hiện tại
--------------------------

Trong một số trường hợp, chúng ta cần gọi mã chỉ kiểm tra từ bên ngoài tệp kiểm tra.  Cái này
hữu ích, chẳng hạn như khi cung cấp một triển khai giả mạo của một chức năng, hoặc
để thất bại bất kỳ thử nghiệm hiện tại nào từ bên trong trình xử lý lỗi.
Chúng tôi có thể thực hiện việc này thông qua trường ZZ0000ZZ trong ZZ0001ZZ, chúng tôi có thể
truy cập bằng chức năng ZZ0002ZZ trong ZZ0003ZZ.

ZZ0000ZZ có thể gọi an toàn ngay cả khi KUnit không được bật. Nếu
KUnit chưa được bật hoặc nếu không có bài kiểm tra nào đang chạy trong tác vụ hiện tại, nó sẽ
trả lại ZZ0001ZZ. Điều này biên dịch thành kiểm tra khóa không hoạt động hoặc khóa tĩnh,
do đó sẽ có tác động hiệu suất không đáng kể khi không chạy thử nghiệm.

Ví dụ bên dưới sử dụng điều này để triển khai triển khai "mô phỏng" một hàm, ZZ0000ZZ:

.. code-block:: c

	#include <kunit/test-bug.h> /* for kunit_get_current_test */

	struct test_data {
		int foo_result;
		int want_foo_called_with;
	};

	static int fake_foo(int arg)
	{
		struct kunit *test = kunit_get_current_test();
		struct test_data *test_data = test->priv;

		KUNIT_EXPECT_EQ(test, test_data->want_foo_called_with, arg);
		return test_data->foo_result;
	}

	static void example_simple_test(struct kunit *test)
	{
		/* Assume priv (private, a member used to pass test data from
		 * the init function) is allocated in the suite's .init */
		struct test_data *test_data = test->priv;

		test_data->foo_result = 42;
		test_data->want_foo_called_with = 1;

		/* In a real test, we'd probably pass a pointer to fake_foo somewhere
		 * like an ops struct, etc. instead of calling it directly. */
		KUNIT_EXPECT_EQ(test, fake_foo(1), 42);
	}

Trong ví dụ này, chúng tôi đang sử dụng thành viên ZZ0000ZZ của ZZ0001ZZ như một cách
truyền dữ liệu đến bài kiểm tra từ hàm init. Nói chung ZZ0002ZZ là
con trỏ có thể được sử dụng cho bất kỳ dữ liệu người dùng nào. Điều này được ưa thích hơn tĩnh
các biến, vì nó tránh được các vấn đề tương tranh.

Nếu chúng tôi muốn thứ gì đó linh hoạt hơn, chúng tôi có thể sử dụng ZZ0000ZZ có tên.
Mỗi bài kiểm tra có thể có nhiều tài nguyên có tên chuỗi cung cấp giống nhau
linh hoạt với tư cách là thành viên ZZ0001ZZ, nhưng cũng có thể, chẳng hạn như cho phép người trợ giúp
có chức năng tạo ra các tài nguyên mà không xung đột với nhau. Nó cũng là
có thể xác định chức năng dọn dẹp cho từng tài nguyên, giúp dễ dàng
tránh rò rỉ tài nguyên. Để biết thêm thông tin, hãy xem Tài liệu/dev-tools/kunit/api/resource.rst.

Thất bại trong bài kiểm tra hiện tại
------------------------

Nếu muốn thất bại trong bài kiểm tra hiện tại, chúng ta có thể sử dụng ZZ0000ZZ
được xác định trong ZZ0001ZZ và không yêu cầu kéo ZZ0002ZZ.
Ví dụ: chúng tôi có tùy chọn bật một số kiểm tra gỡ lỗi bổ sung trên một số dữ liệu
cấu trúc như hình dưới đây:

.. code-block:: c

	#include <kunit/test-bug.h>

	#ifdef CONFIG_EXTRA_DEBUG_CHECKS
	static void validate_my_data(struct data *data)
	{
		if (is_valid(data))
			return;

		kunit_fail_current_test("data %p is invalid", data);

		/* Normal, non-KUnit, error reporting code here. */
	}
	#else
	static void my_debug_function(void) { }
	#endif

ZZ0000ZZ có thể gọi an toàn ngay cả khi KUnit không được bật. Nếu
KUnit chưa được bật hoặc nếu không có thử nghiệm nào đang chạy trong tác vụ hiện tại, nó sẽ thực hiện
không có gì. Điều này biên dịch thành kiểm tra khóa không hoạt động hoặc khóa tĩnh, do đó sẽ
có tác động hiệu suất không đáng kể khi không chạy thử nghiệm.

Quản lý thiết bị và trình điều khiển giả mạo
---------------------------------

Khi kiểm tra trình điều khiển hoặc mã tương tác với trình điều khiển, nhiều chức năng sẽ
yêu cầu ZZ0000ZZ hoặc ZZ0001ZZ. Trong nhiều trường hợp, việc thiết lập
không cần phải thiết lập một thiết bị thật để kiểm tra bất kỳ chức năng cụ thể nào, vì vậy một thiết bị giả
có thể được sử dụng thay thế.

KUnit cung cấp các chức năng trợ giúp để tạo và quản lý các thiết bị giả mạo này.
bên trong thuộc loại ZZ0000ZZ và được gắn vào một thiết bị đặc biệt
ZZ0001ZZ. Các thiết bị này hỗ trợ tài nguyên thiết bị được quản lý (devres), như
được mô tả trong Tài liệu/driver-api/driver-model/devres.rst

Để tạo ZZ0000ZZ do KUnit quản lý, hãy sử dụng ZZ0001ZZ,
sẽ tạo trình điều khiển có tên đã cho trên ZZ0002ZZ. Người lái xe này
sẽ tự động bị hủy khi quá trình kiểm tra tương ứng kết thúc, nhưng cũng có thể
có thể bị hủy thủ công bằng ZZ0003ZZ.

Để tạo một thiết bị giả, hãy sử dụng ZZ0000ZZ, thiết bị này sẽ tạo
và đăng ký thiết bị bằng trình điều khiển mới do KUnit quản lý được tạo bằng ZZ0001ZZ.
Để cung cấp trình điều khiển cụ thể, không do KUnit quản lý, hãy sử dụng ZZ0002ZZ
thay vào đó. Giống như các trình điều khiển được quản lý, các thiết bị giả do KUnit quản lý sẽ tự động được
được dọn dẹp khi quá trình kiểm tra kết thúc, nhưng có thể được dọn dẹp sớm bằng tay với
ZZ0003ZZ.

Nên ưu tiên sử dụng các thiết bị KUnit hơn ZZ0000ZZ và
thay vì ZZ0001ZZ trong trường hợp thiết bị không khác
một thiết bị nền tảng.

Ví dụ:

.. code-block:: c

	#include <kunit/device.h>

	static void test_my_device(struct kunit *test)
	{
		struct device *fake_device;
		const char *dev_managed_string;

		// Create a fake device.
		fake_device = kunit_device_register(test, "my_device");
		KUNIT_ASSERT_NOT_ERR_OR_NULL(test, fake_device)

		// Pass it to functions which need a device.
		dev_managed_string = devm_kstrdup(fake_device, "Hello, World!");

		// Everything is cleaned up automatically when the test ends.
	}