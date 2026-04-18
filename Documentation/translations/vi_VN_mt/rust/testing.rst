.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/rust/testing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Kiểm tra
=======

Tài liệu này chứa thông tin hữu ích về cách kiểm tra mã Rust trong
hạt nhân.

Có ba loại bài kiểm tra:

- Các bài kiểm tra KUnit.
- Các bài kiểm tra ZZ0000ZZ.
- Kselftests.

Các bài kiểm tra KUnit
---------------

Đây là các thử nghiệm được lấy từ các ví dụ trong tài liệu Rust. Họ
được chuyển đổi thành các bài kiểm tra KUnit.

Cách sử dụng
*****

Các thử nghiệm này có thể được chạy qua KUnit. Ví dụ qua ZZ0000ZZ (ZZ0001ZZ)
trên dòng lệnh::

./tools/testing/kunit/kunit.py run --make_options LLVM=1 --arch x86_64 --kconfig_add CONFIG_RUST=y

Ngoài ra, KUnit có thể chạy chúng dưới dạng kernel tích hợp sẵn khi khởi động. tham khảo
Documentation/dev-tools/kunit/index.rst dành cho tài liệu chung về KUnit
và Documentation/dev-tools/kunit/architecture.rst để biết chi tiết về kernel
thử nghiệm tích hợp và dòng lệnh.

Để sử dụng các tài liệu KUnit này, bạn phải bật tính năng sau::

CONFIG_KUNIT
	   Hack hạt nhân -> Kiểm tra và bảo hiểm hạt nhân -> KUnit - Kích hoạt hỗ trợ cho các bài kiểm tra đơn vị
	CONFIG_RUST_KERNEL_DOCTESTS
	   Hack kernel -> Hack rỉ sét -> Doctests cho thùng ZZ0000ZZ

trong hệ thống cấu hình kernel.

Kiểm tra KUnit là kiểm tra tài liệu
***********************************

Các thử nghiệm tài liệu này thường là ví dụ về việc sử dụng bất kỳ mục nào (ví dụ:
hàm, cấu trúc, mô-đun...).

Chúng rất thuận tiện vì chúng chỉ được viết bên cạnh
tài liệu. Ví dụ:

.. code-block:: rust

	/// Sums two numbers.
	///
	/// ```
	/// assert_eq!(mymod::f(10, 20), 30);
	/// ```
	pub fn f(a: i32, b: i32) -> i32 {
	    a + b
	}

Trong không gian người dùng, các bài kiểm tra được thu thập và chạy qua ZZ0000ZZ. Sử dụng công cụ
nguyên trạng sẽ hữu ích vì nó cho phép xác minh rằng các ví dụ được biên dịch
(do đó việc thực thi chúng được giữ đồng bộ với mã mà chúng ghi lại) và cả
như chạy những ứng dụng không phụ thuộc vào API trong kernel.

Tuy nhiên, đối với kernel, các thử nghiệm này được chuyển thành bộ thử nghiệm KUnit.
Điều này có nghĩa là các doctest được biên dịch dưới dạng đối tượng kernel Rust, cho phép chúng
chạy với kernel được xây dựng.

Lợi ích của việc tích hợp KUnit này là các tài liệu của Rust có thể sử dụng lại các tài liệu hiện có
cơ sở thử nghiệm. Chẳng hạn, nhật ký kernel sẽ trông như sau::

KTAP phiên bản 1
	1..1
	    KTAP phiên bản 1
	    # Subtest: Rust_doctests_kernel
	    1..59
	    # rust_doctest_kernel_build_assert_rs_0.location: rỉ sét/kernel/build_assert.rs:13
	    ok 1 rust_doctest_kernel_build_assert_rs_0
	    # rust_doctest_kernel_build_assert_rs_1.location: rỉ sét/kernel/build_assert.rs:56
	    được 2 Rust_doctest_kernel_build_assert_rs_1
	    # rust_doctest_kernel_init_rs_0.location: rỉ sét/kernel/init.rs:122
	    được 3 Rust_doctest_kernel_init_rs_0
	    ...
# rust_doctest_kernel_types_rs_2.location: rỉ sét/kernel/types.rs:150
	    được 59 Rust_doctest_kernel_types_rs_2
	# rust_doctests_kernel: đạt:59 thất bại:0 bỏ qua:0 tổng cộng:59
	# Totals: đạt:59 thất bại:0 bỏ qua:0 tổng cộng:59
	được rồi 1 Rust_doctests_kernel

Kiểm tra bằng ZZ0000ZZ
toán tử cũng được hỗ trợ như bình thường, ví dụ:

.. code-block:: rust

	/// ```
	/// # use kernel::{spawn_work_item, workqueue};
	/// spawn_work_item!(workqueue::system(), || pr_info!("x\n"))?;
	/// # Ok::<(), Error>(())
	/// ```

Các bài test cũng được biên dịch bằng Clippy theo ZZ0000ZZ, như bình thường
mã, do đó cũng được hưởng lợi từ việc thêm linting.

Để các nhà phát triển dễ dàng xem dòng mã doctest nào gây ra lỗi
không thành công, dòng chẩn đoán KTAP sẽ được in vào nhật ký. Điều này chứa đựng
vị trí (tệp và dòng) của bài kiểm tra ban đầu (tức là thay vì vị trí trong
tệp Rust được tạo)::

# rust_doctest_kernel_types_rs_2.location: rỉ sét/kernel/types.rs:150

Các thử nghiệm về rỉ sét dường như được khẳng định bằng cách sử dụng ZZ0000ZZ và ZZ0001ZZ thông thường
macro từ thư viện chuẩn Rust (ZZ0002ZZ). Chúng tôi cung cấp một phiên bản tùy chỉnh
thay vào đó chuyển tiếp cuộc gọi đến KUnit. Điều quan trọng là các macro này không
yêu cầu chuyển ngữ cảnh, không giống như ngữ cảnh dành cho thử nghiệm KUnit (tức là
ZZ0003ZZ). Điều này làm cho chúng dễ sử dụng hơn và người đọc của
tài liệu không cần quan tâm đến việc sử dụng khung kiểm tra nào. trong
Ngoài ra, nó có thể cho phép chúng tôi kiểm tra mã của bên thứ ba dễ dàng hơn trong tương lai.

Hạn chế hiện tại là KUnit không hỗ trợ các xác nhận trong các tác vụ khác.
Vì vậy, hiện tại chúng tôi chỉ in một lỗi vào nhật ký kernel nếu một xác nhận
thực sự đã thất bại. Ngoài ra, doctest không được chạy cho các chức năng không công khai.

Vì các thử nghiệm này chỉ là ví dụ, tức là chúng là một phần của tài liệu nên chúng
nói chung nên được viết như "mã thực". Vì vậy, ví dụ, thay vì
sử dụng ZZ0000ZZ hoặc ZZ0001ZZ, hãy sử dụng toán tử ZZ0002ZZ. Để biết thêm thông tin cơ bản,
xin vui lòng xem:

ZZ0000ZZ

Các thử nghiệm ZZ0000ZZ
---------------------

Ngoài ra, còn có các bài kiểm tra ZZ0000ZZ. Giống như đối với các bài kiểm tra tài liệu,
những điều này cũng khá giống với những gì bạn mong đợi từ không gian người dùng và chúng
cũng được ánh xạ tới KUnit.

Các thử nghiệm này được giới thiệu bởi macro thủ tục ZZ0000ZZ, thực hiện
tên của bộ thử nghiệm làm đối số.

Ví dụ: giả sử chúng ta muốn kiểm tra hàm ZZ0000ZZ từ tài liệu
phần kiểm tra. Chúng ta có thể viết, trong cùng một tệp nơi chúng ta có hàm:

.. code-block:: rust

	#[kunit_tests(rust_kernel_mymod)]
	mod tests {
	    use super::*;

	    #[test]
	    fn test_f() {
	        assert_eq!(f(10, 20), 30);
	    }
	}

Và nếu chúng ta chạy nó, nhật ký kernel sẽ trông như thế này::

KTAP phiên bản 1
	    # Subtest: gỉ_kernel_mymod
	    # speed: bình thường
	    1..1
	    # test_f.speed: bình thường
	    được rồi 1 bài kiểm tra_f
	được rồi 1 Rust_kernel_mymod

Giống như kiểm tra tài liệu, macro ZZ0000ZZ và ZZ0001ZZ được ánh xạ
quay lại KUnit và đừng hoảng sợ. Tương tự, các
ZZ0005ZZ
toán tử được hỗ trợ, tức là các hàm kiểm tra có thể không trả về gì (tức là
loại thiết bị ZZ0002ZZ) hoặc ZZ0003ZZ (tức là bất kỳ ZZ0004ZZ nào). Ví dụ:

.. code-block:: rust

	#[kunit_tests(rust_kernel_mymod)]
	mod tests {
	    use super::*;

	    #[test]
	    fn test_g() -> Result {
	        let x = g()?;
	        assert_eq!(x, 30);
	        Ok(())
	    }
	}

Nếu chúng tôi chạy thử nghiệm và lệnh gọi tới ZZ0000ZZ không thành công thì nhật ký kernel sẽ hiển thị::

KTAP phiên bản 1
	    # Subtest: gỉ_kernel_mymod
	    # speed: bình thường
	    1..1
	    # test_g: ASSERTION FAILED ở gỉ/kernel/lib.rs:335
	    Dự kiến is_test_result_ok(test_g()) là đúng nhưng lại sai
	    # test_g.speed: bình thường
	    không ổn 1 bài kiểm tra_g
	không ổn 1 Rust_kernel_mymod

Nếu bài kiểm tra ZZ0000ZZ có thể hữu ích làm ví dụ cho người dùng thì vui lòng
thay vào đó hãy sử dụng bài kiểm tra tài liệu. Ngay cả các trường hợp cạnh của API, ví dụ: lỗi hoặc
trường hợp ranh giới, có thể thú vị để hiển thị trong ví dụ.

Các bài kiểm tra máy chủ ZZ0000ZZ
---------------------------

Đây là các thử nghiệm không gian người dùng có thể được xây dựng và chạy trên máy chủ (tức là thử nghiệm
thực hiện quá trình xây dựng kernel) bằng cách sử dụng ZZ0000ZZ Make target::

làm cho LLVM=1 rỉ sét nhất

Điều này yêu cầu kernel ZZ0000ZZ.

Hiện tại, chúng chủ yếu được sử dụng để thử nghiệm các ví dụ của thùng ZZ0000ZZ.

Kselftests
--------------

Kselftests cũng có sẵn trong thư mục ZZ0000ZZ.

Các tùy chọn cấu hình kernel cần thiết cho các bài kiểm tra được liệt kê trong
Tệp ZZ0000ZZ và có thể được kèm theo với sự trợ giúp
của tập lệnh ZZ0001ZZ::

./scripts/kconfig/merge_config.sh .config tools/testing/selftests/rust/config

Các kselftests được xây dựng trong cây nguồn kernel và nhằm mục đích
được thực thi trên hệ thống đang chạy cùng kernel.

Khi hạt nhân phù hợp với cây nguồn đã được cài đặt và khởi động,
các bài kiểm tra có thể được biên dịch và thực thi bằng lệnh sau ::

tạo TARGETS="rust" kselftest

Tham khảo Documentation/dev-tools/kselftest.rst để biết Kselftest chung
tài liệu.