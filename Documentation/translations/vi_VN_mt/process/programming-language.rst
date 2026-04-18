.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/programming-language.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _programming_language:

Ngôn ngữ lập trình
====================

Nhân Linux được viết bằng ngôn ngữ lập trình C [c-ngôn ngữ]_.
Chính xác hơn, nó thường được biên dịch bằng ZZ0001ZZ [gcc]_
trong ZZ0002ZZ [gcc-c-dialect-options]_: phương ngữ GNU của ISO C11.
ZZ0003ZZ [clang]_ cũng được hỗ trợ; xem tài liệu trên
ZZ0000ZZ.

Phương ngữ này chứa nhiều phần mở rộng cho ngôn ngữ [gnu-extensions]_,
và tất nhiên nhiều trong số chúng được sử dụng trong kernel.

Thuộc tính
----------

Một trong những phần mở rộng phổ biến được sử dụng xuyên suốt kernel là các thuộc tính
[gcc-thuộc tính-cú pháp]_. Thuộc tính cho phép giới thiệu
ngữ nghĩa do việc triển khai xác định cho các thực thể ngôn ngữ (như các biến,
chức năng hoặc loại) mà không cần phải thực hiện những thay đổi cú pháp đáng kể
sang ngôn ngữ (ví dụ: thêm từ khóa mới) [n2049]_.

Trong một số trường hợp, các thuộc tính là tùy chọn (tức là trình biên dịch không hỗ trợ chúng
vẫn phải tạo mã phù hợp, ngay cả khi nó chậm hơn hoặc không hoạt động
như nhiều lần kiểm tra/chẩn đoán tại thời điểm biên dịch).

Hạt nhân xác định các từ khóa giả (ví dụ ZZ0000ZZ) thay vì sử dụng
trực tiếp cú pháp thuộc tính GNU (ví dụ ZZ0001ZZ)
để phát hiện tính năng nào có thể được sử dụng và/hoặc rút ngắn mã.

Vui lòng tham khảo ZZ0000ZZ để biết thêm thông tin.

rỉ sét
----

Kernel có hỗ trợ ngôn ngữ lập trình Rust
[ngôn ngữ rỉ sét]_ dưới ZZ0000ZZ. Nó được biên dịch với ZZ0001ZZ [rustc]_
dưới ZZ0002ZZ [phiên bản rỉ sét]_. Ấn bản là một cách để giới thiệu
những thay đổi nhỏ đối với ngôn ngữ không tương thích ngược.

Ngoài ra, một số tính năng không ổn định [rust-unstable-feature]_ được sử dụng trong
hạt nhân. Các tính năng không ổn định có thể thay đổi trong tương lai, do đó đây là một điều quan trọng
mục tiêu đạt đến điểm chỉ sử dụng các tính năng ổn định.

Vui lòng tham khảo Documentation/rust/index.rst để biết thêm thông tin.

.. [c-language] http://www.open-std.org/jtc1/sc22/wg14/www/standards
.. [gcc] https://gcc.gnu.org
.. [clang] https://clang.llvm.org
.. [gcc-c-dialect-options] https://gcc.gnu.org/onlinedocs/gcc/C-Dialect-Options.html
.. [gnu-extensions] https://gcc.gnu.org/onlinedocs/gcc/C-Extensions.html
.. [gcc-attribute-syntax] https://gcc.gnu.org/onlinedocs/gcc/Attribute-Syntax.html
.. [n2049] http://www.open-std.org/jtc1/sc22/wg14/www/docs/n2049.pdf
.. [rust-language] https://www.rust-lang.org
.. [rustc] https://doc.rust-lang.org/rustc/
.. [rust-editions] https://doc.rust-lang.org/edition-guide/editions/
.. [rust-unstable-features] https://github.com/Rust-for-Linux/linux/issues/2
