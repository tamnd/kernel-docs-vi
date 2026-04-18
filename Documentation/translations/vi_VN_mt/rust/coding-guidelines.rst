.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/rust/coding-guidelines.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Nguyên tắc mã hóa
=================

Tài liệu này mô tả cách viết mã Rust trong kernel.


Kiểu & định dạng
------------------

Mã phải được định dạng bằng ZZ0000ZZ. Bằng cách này, một người
thỉnh thoảng đóng góp vào kernel không cần phải học và
hãy nhớ thêm một hướng dẫn về phong cách. Quan trọng hơn, người đánh giá và người bảo trì
không cần phải mất thời gian chỉ ra các vấn đề về phong cách nữa, và do đó
có thể cần ít bản vá hơn để thực hiện thay đổi.

.. note:: Conventions on comments and documentation are not checked by
  ``rustfmt``. Thus those are still needed to be taken care of.

Cài đặt mặc định của ZZ0000ZZ được sử dụng. Điều này có nghĩa là thành ngữ Rust
phong cách được theo sau. Ví dụ: 4 dấu cách được sử dụng để thụt lề thay vì
hơn các tab.

Thật thuận tiện khi hướng dẫn người soạn thảo/IDE định dạng trong khi gõ,
khi lưu hoặc tại thời điểm cam kết. Tuy nhiên, nếu vì lý do nào đó định dạng lại
toàn bộ nguồn Rust của kernel là cần thiết tại một số điểm, những điều sau đây có thể là
chạy::

tạo LLVM=1 rỉ sét

Cũng có thể kiểm tra xem mọi thứ đã được định dạng chưa (in một tệp khác
nếu không), ví dụ đối với CI, với::

tạo LLVM=1 Rustfmtcheck

Giống như ZZ0000ZZ cho phần còn lại của kernel, ZZ0001ZZ hoạt động trên
các tệp riêng lẻ và không yêu cầu cấu hình kernel. Đôi khi nó có thể
thậm chí làm việc với mã bị hỏng.

Nhập khẩu
~~~~~~~

ZZ0000ZZ, theo mặc định, định dạng nhập theo cách dễ xảy ra xung đột
trong khi hợp nhất và khởi động lại, vì trong một số trường hợp, nó cô đọng một số mục thành
cùng một dòng. Ví dụ:

.. code-block:: rust

	// Do not use this style.
	use crate::{
	    example1,
	    example2::{example3, example4, example5},
	    example6, example7,
	    example8::example9,
	};

Thay vào đó, kernel sử dụng bố cục dọc trông như thế này:

.. code-block:: rust

	use crate::{
	    example1,
	    example2::{
	        example3,
	        example4,
	        example5, //
	    },
	    example6,
	    example7,
	    example8::example9, //
	};

Tức là mỗi mục sẽ có một dòng riêng và dấu ngoặc nhọn sẽ được sử dụng ngay khi có
có nhiều hơn một mục trong một danh sách.

Nhận xét trống ở cuối cho phép giữ nguyên định dạng này. Không chỉ vậy,
ZZ0000ZZ sẽ thực sự định dạng lại quá trình nhập theo chiều dọc khi nhận xét trống
đã thêm vào. Nghĩa là, có thể dễ dàng định dạng lại ví dụ ban đầu thành
kiểu dự kiến bằng cách chạy ZZ0001ZZ trên đầu vào như:

.. code-block:: rust

	// Do not use this style.
	use crate::{
	    example1,
	    example2::{example3, example4, example5, //
	    },
	    example6, example7,
	    example8::example9, //
	};

Nhận xét trống ở cuối hoạt động đối với các lần nhập lồng nhau, như được hiển thị ở trên, cũng như
đối với việc nhập một mặt hàng -- điều này có thể hữu ích để giảm thiểu sự khác biệt trong bản vá
loạt:

.. code-block:: rust

	use crate::{
	    example1, //
	};

Chú thích trống ở cuối hoạt động ở bất kỳ dòng nào trong dấu ngoặc nhọn, nhưng nó
được ưu tiên giữ nó ở mục cuối cùng, vì nó gợi nhớ đến
dấu phẩy ở cuối trong các định dạng khác. Đôi khi việc tránh di chuyển có thể đơn giản hơn
nhận xét nhiều lần trong một loạt bản vá do những thay đổi trong danh sách.

Có thể có những trường hợp cần phải có ngoại lệ, tức là không có trường hợp nào trong số này là
một quy tắc cứng rắn. Ngoài ra còn có mã chưa được di chuyển sang kiểu này, nhưng
vui lòng không giới thiệu mã theo phong cách khác.

Cuối cùng, mục tiêu là khiến ZZ0000ZZ hỗ trợ kiểu định dạng này (hoặc
tương tự) tự động ở dạng bản phát hành ổn định mà không yêu cầu dấu vết
bình luận trống rỗng. Vì vậy, tại một thời điểm nào đó, mục tiêu là loại bỏ những bình luận đó.


Bình luận
--------

Nhận xét "Bình thường" (tức là ZZ0000ZZ, thay vì tài liệu mã bắt đầu
với ZZ0001ZZ hoặc ZZ0002ZZ) được viết bằng Markdown giống như tài liệu
nhận xét, mặc dù chúng sẽ không được hiển thị. Điều này cải thiện tính nhất quán,
đơn giản hóa các quy tắc và cho phép di chuyển nội dung giữa hai loại
bình luận dễ dàng hơn. Ví dụ:

.. code-block:: rust

	// `object` is ready to be handled now.
	f(object);

Hơn nữa, giống như tài liệu, các nhận xét được viết hoa ở đầu
của một câu và kết thúc bằng một dấu chấm (ngay cả khi đó là một câu đơn). Cái này
bao gồm ZZ0000ZZ, ZZ0001ZZ và các nhận xét "được gắn thẻ" khác, ví dụ:

.. code-block:: rust

	// FIXME: The error should be handled properly.

Không nên sử dụng nhận xét cho mục đích tài liệu: nhận xét là nhằm mục đích
để biết chi tiết triển khai, không phải người dùng. Sự phân biệt này rất hữu ích ngay cả khi
người đọc tệp nguồn vừa là người triển khai vừa là người dùng API. Trên thực tế,
đôi khi việc sử dụng cả nhận xét và tài liệu cùng một lúc sẽ rất hữu ích.
Ví dụ: đối với danh sách ZZ0000ZZ hoặc để nhận xét về chính tài liệu đó.
Đối với trường hợp sau, bình luận có thể được chèn vào giữa; tức là gần hơn
dòng tài liệu cần được bình luận. Đối với bất kỳ trường hợp nào khác, ý kiến ​​là
được viết sau tài liệu, ví dụ:

.. code-block:: rust

	/// Returns a new [`Foo`].
	///
	/// # Examples
	///
	// TODO: Find a better example.
	/// ```
	/// let foo = f(42);
	/// ```
	// FIXME: Use fallible approach.
	pub fn f(x: i32) -> Foo {
	    // ...
	}

Điều này áp dụng cho cả các mặt hàng công cộng và riêng tư. Điều này làm tăng tính nhất quán với
các mục công khai, cho phép thay đổi khả năng hiển thị với ít thay đổi liên quan hơn và sẽ
cho phép chúng tôi có khả năng tạo tài liệu cho các mục riêng tư.
Nói cách khác, nếu tài liệu được viết cho một mục riêng tư thì ZZ0000ZZ
vẫn nên sử dụng. Ví dụ:

.. code-block:: rust

	/// My private function.
	// TODO: ...
	fn f() {}

Một loại bình luận đặc biệt là bình luận ZZ0000ZZ. Những điều này phải xuất hiện
trước mỗi khối ZZ0001ZZ và họ giải thích lý do tại sao mã bên trong khối
đúng/âm thanh, tức là tại sao nó không thể kích hoạt hành vi không xác định trong mọi trường hợp, ví dụ:

.. code-block:: rust

	// SAFETY: `p` is valid by the safety requirements.
	unsafe { *p = 0; }

Không nên nhầm lẫn các bình luận ZZ0000ZZ với các phần ZZ0001ZZ
trong tài liệu mã. Phần ZZ0002ZZ chỉ định hợp đồng mà người gọi
(đối với chức năng) hoặc người triển khai (đối với đặc điểm) cần tuân thủ. ZZ0003ZZ
nhận xét cho thấy tại sao thực sự có lệnh gọi (đối với chức năng) hoặc triển khai (đối với đặc điểm)
tôn trọng các điều kiện tiên quyết được nêu trong phần ZZ0004ZZ hoặc ngôn ngữ
tham khảo.


Tài liệu mã
------------------

Mã hạt nhân Rust không được ghi lại như mã hạt nhân C (tức là thông qua kernel-doc).
Thay vào đó, hệ thống thông thường để ghi lại mã Rust được sử dụng: ZZ0000ZZ
công cụ sử dụng Markdown (ngôn ngữ đánh dấu nhẹ).

Để tìm hiểu Markdown, có rất nhiều hướng dẫn có sẵn. Ví dụ,
cái ở:

ZZ0000ZZ

Đây là cách một hàm Rust được ghi chép đầy đủ có thể trông như thế nào:

.. code-block:: rust

	/// Returns the contained [`Some`] value, consuming the `self` value,
	/// without checking that the value is not [`None`].
	///
	/// # Safety
	///
	/// Calling this method on [`None`] is *[undefined behavior]*.
	///
	/// [undefined behavior]: https://doc.rust-lang.org/reference/behavior-considered-undefined.html
	///
	/// # Examples
	///
	/// ```
	/// let x = Some("air");
	/// assert_eq!(unsafe { x.unwrap_unchecked() }, "air");
	/// ```
	pub unsafe fn unwrap_unchecked(self) -> T {
	    match self {
	        Some(val) => val,

	        // SAFETY: The safety contract must be upheld by the caller.
	        None => unsafe { hint::unreachable_unchecked() },
	    }
	}

Ví dụ này giới thiệu một số tính năng của ZZ0000ZZ và một số quy ước được tuân theo
trong hạt nhân:

- Đoạn đầu tiên phải là một câu duy nhất mô tả ngắn gọn những gì
  mục tài liệu đó có. Giải thích thêm phải đi trong đoạn văn bổ sung.

- Các chức năng không an toàn phải ghi lại các điều kiện tiên quyết về an toàn của chúng theo
  một phần ZZ0000ZZ.

- Mặc dù không được hiển thị ở đây, nhưng nếu một chức năng có thể bị hoảng loạn, các điều kiện theo đó
  điều đó xảy ra phải được mô tả trong phần ZZ0000ZZ.

Xin lưu ý rằng việc hoảng loạn sẽ rất hiếm khi xảy ra và chỉ được sử dụng với mục đích tốt.
  lý do. Trong hầu hết các trường hợp, nên sử dụng một cách tiếp cận có thể sai, điển hình là
  trả lại ZZ0000ZZ.

- Nếu việc đưa ra ví dụ về cách sử dụng giúp ích cho người đọc thì phải viết bằng
  một phần có tên ZZ0000ZZ.

- Các mục Rust (hàm, kiểu, hằng...) phải được liên kết phù hợp
  (ZZ0000ZZ sẽ tự động tạo liên kết).

- Bất kỳ khối ZZ0000ZZ nào cũng phải có nhận xét ZZ0001ZZ trước
  mô tả lý do tại sao mã bên trong lại có âm thanh.

Mặc dù đôi khi lý do có vẻ tầm thường và do đó không cần thiết,
  viết những nhận xét này không chỉ là một cách tốt để ghi lại những gì đã xảy ra
  được tính đến, nhưng quan trọng nhất, nó cung cấp một cách để biết rằng
  không có ràng buộc ngầm ZZ0000ZZ.

Để tìm hiểu thêm về cách viết tài liệu cho Rust và các tính năng bổ sung,
mời các bạn xem sách ZZ0000ZZ tại:

ZZ0000ZZ

Ngoài ra, kernel hỗ trợ tạo các liên kết liên quan đến cây nguồn bằng cách
thêm tiền tố đích liên kết bằng ZZ0000ZZ. Ví dụ:

.. code-block:: rust

	//! C header: [`include/linux/printk.h`](srctree/include/linux/printk.h)

hoặc:

.. code-block:: rust

	/// [`struct mutex`]: srctree/include/linux/mutex.h


Các loại C FFI
-----------

Mã hạt nhân Rust đề cập đến các loại C, chẳng hạn như ZZ0000ZZ, sử dụng các bí danh loại như
ZZ0001ZZ, có sẵn từ phần mở đầu ZZ0002ZZ. Xin vui lòng làm
không sử dụng bí danh từ ZZ0003ZZ -- chúng có thể không ánh xạ tới đúng loại.

Những bí danh này thường phải được gọi trực tiếp bằng mã định danh của chúng, tức là.
như một đường dẫn một đoạn. Ví dụ:

.. code-block:: rust

	fn f(p: *const c_char) -> c_int {
	    // ...
	}


Đặt tên
------

Mã hạt nhân Rust tuân theo các quy ước đặt tên Rust thông thường:

ZZ0000ZZ

Khi các khái niệm C hiện có (ví dụ: macro, hàm, đối tượng...) được gói gọn trong
một sự trừu tượng của Rust, một cái tên càng gần với phía C càng tốt
được sử dụng để tránh nhầm lẫn và cải thiện khả năng đọc khi chuyển đổi
qua lại giữa hai bên C và Rust. Ví dụ: các macro như
ZZ0000ZZ từ C được đặt tên giống nhau ở phía Rust.

Phải nói rằng, vỏ nên được điều chỉnh để tuân theo cách đặt tên Rust
không nên áp dụng các quy ước và không gian tên được giới thiệu bởi các mô-đun và kiểu
lặp lại trong tên mục. Chẳng hạn, khi gói các hằng số như:

.. code-block:: c

	#define GPIO_LINE_DIRECTION_IN	0
	#define GPIO_LINE_DIRECTION_OUT	1

Tương đương trong Rust có thể trông giống như (bỏ qua tài liệu):

.. code-block:: rust

	pub mod gpio {
	    pub enum LineDirection {
	        In = bindings::GPIO_LINE_DIRECTION_IN as _,
	        Out = bindings::GPIO_LINE_DIRECTION_OUT as _,
	    }
	}

Nghĩa là, tương đương với ZZ0000ZZ sẽ được gọi là
ZZ0001ZZ. Đặc biệt không nên đặt tên
ZZ0002ZZ.


xơ vải
-----

Trong Rust, có thể đưa ra các cảnh báo cụ thể cho ZZ0000ZZ (chẩn đoán, lint)
cục bộ, làm cho trình biên dịch bỏ qua các trường hợp của một cảnh báo nhất định trong một phạm vi nhất định
chức năng, mô-đun, khối, v.v.

Nó tương tự như ZZ0000ZZ + ZZ0001ZZ + ZZ0002ZZ trong C
[#]_:

.. code-block:: c

	#pragma GCC diagnostic push
	#pragma GCC diagnostic ignored "-Wunused-function"
	static void f(void) {}
	#pragma GCC diagnostic pop

.. [#] In this particular case, the kernel's ``__{always,maybe}_unused``
       attributes (C23's ``[[maybe_unused]]``) may be used; however, the example
       is meant to reflect the equivalent lint in Rust discussed afterwards.

Nhưng ít dài dòng hơn:

.. code-block:: rust

	#[allow(dead_code)]
	fn f() {}

Nhờ vào ưu điểm đó, nó có thể tạo điều kiện thuận lợi cho việc chẩn đoán nhiều hơn bằng cách
mặc định (tức là nằm ngoài mức ZZ0000ZZ). Đặc biệt, những người có thể có một số
kết quả dương tính giả nhưng điều đó khá hữu ích để tiếp tục kích hoạt để phát hiện
những sai lầm tiềm ẩn.

Trên hết, Rust còn cung cấp thuộc tính ZZ0000ZZ để thực hiện điều này hơn nữa.
Nó làm cho trình biên dịch cảnh báo nếu cảnh báo không được tạo ra. Ví dụ,
sau đây sẽ đảm bảo rằng, khi ZZ0001ZZ được gọi ở đâu đó, chúng ta sẽ phải
loại bỏ thuộc tính:

.. code-block:: rust

	#[expect(dead_code)]
	fn f() {}

Nếu không, chúng tôi sẽ nhận được cảnh báo từ trình biên dịch ::

cảnh báo: kỳ vọng lint này không được đáp ứng
	 --> x.rs:3:10
	  |
	3 | #[mong đợi(dead_code)]
	  |          ^^ ^^^ ^^ ^^
	  |
	  = lưu ý: ZZ0000ZZ được bật theo mặc định

Điều này có nghĩa là ZZ0000ZZ không bị lãng quên khi không cần thiết, điều này
có thể xảy ra trong một số tình huống, ví dụ:

- Thuộc tính tạm thời được thêm vào trong khi phát triển.

- Những cải tiến về lint trong trình biên dịch, Clippy hoặc các công cụ tùy chỉnh có thể
  loại bỏ một kết quả dương tính giả.

- Khi không cần đến xơ vải nữa vì đã dự kiến rằng nó sẽ
  bị xóa tại một số điểm, chẳng hạn như ví dụ ZZ0000ZZ ở trên.

Nó cũng làm tăng khả năng hiển thị của các ZZ0000ZZ còn lại và giảm
cơ hội áp dụng sai một.

Vì vậy, thích ZZ0000ZZ hơn ZZ0001ZZ trừ khi:

- Biên dịch có điều kiện kích hoạt cảnh báo trong một số trường hợp nhưng không kích hoạt cảnh báo trong một số trường hợp khác.

Nếu chỉ có một vài trường hợp cảnh báo kích hoạt (hoặc không
  trigger) so với tổng số trường hợp thì có thể cân nhắc sử dụng
  ZZ0000ZZ có điều kiện (tức là ZZ0001ZZ). Nếu không,
  có lẽ sẽ đơn giản hơn nếu chỉ sử dụng ZZ0002ZZ.

- Bên trong macro, khi các lệnh gọi khác nhau có thể tạo ra mã mở rộng
  kích hoạt cảnh báo trong một số trường hợp nhưng không gây ra cảnh báo trong những trường hợp khác.

- Khi mã có thể kích hoạt cảnh báo cho một số kiến trúc nhưng không kích hoạt các kiến trúc khác, chẳng hạn như
  dưới dạng ZZ0000ZZ được chuyển thành loại C FFI.

Để có một ví dụ phát triển hơn, hãy xem xét chương trình này:

.. code-block:: rust

	fn g() {}

	fn main() {
	    #[cfg(CONFIG_X)]
	    g();
	}

Ở đây, hàm ZZ0000ZZ là mã chết nếu ZZ0001ZZ không được đặt. Chúng ta có thể sử dụng
ZZ0002ZZ đây?

.. code-block:: rust

	#[expect(dead_code)]
	fn g() {}

	fn main() {
	    #[cfg(CONFIG_X)]
	    g();
	}

Điều này sẽ phát ra một lint nếu ZZ0000ZZ được đặt, vì nó không phải là mã chết trong đó
cấu hình. Do đó, trong những trường hợp như thế này, chúng tôi không thể sử dụng nguyên trạng ZZ0001ZZ.

Một khả năng đơn giản là sử dụng ZZ0000ZZ:

.. code-block:: rust

	#[allow(dead_code)]
	fn g() {}

	fn main() {
	    #[cfg(CONFIG_X)]
	    g();
	}

Một giải pháp thay thế sẽ là sử dụng ZZ0000ZZ có điều kiện:

.. code-block:: rust

	#[cfg_attr(not(CONFIG_X), expect(dead_code))]
	fn g() {}

	fn main() {
	    #[cfg(CONFIG_X)]
	    g();
	}

Điều này sẽ đảm bảo rằng, nếu ai đó giới thiệu một lệnh gọi khác tới ZZ0000ZZ ở đâu đó
(ví dụ: vô điều kiện), thì sẽ phát hiện ra rằng đó không phải là mã chết
nữa. Tuy nhiên, ZZ0001ZZ phức tạp hơn ZZ0002ZZ đơn giản.

Do đó, có thể không đáng sử dụng ZZ0000ZZ có điều kiện khi
có nhiều hơn một hoặc hai cấu hình liên quan hoặc khi xơ vải có thể bị hỏng
được kích hoạt do những thay đổi không cục bộ (chẳng hạn như ZZ0001ZZ).

Để biết thêm thông tin về chẩn đoán trong Rust, vui lòng xem:

ZZ0000ZZ

Xử lý lỗi
--------------

Để biết một số thông tin cơ bản và hướng dẫn về cách xử lý lỗi cụ thể của Rust dành cho Linux,
xin vui lòng xem:

ZZ0000ZZ