.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/rust/quick-start.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Bắt đầu nhanh
===========

Tài liệu này mô tả cách bắt đầu phát triển kernel trong Rust.

Có một số cách để cài đặt chuỗi công cụ Rust cần thiết cho việc phát triển kernel.
Một cách đơn giản là sử dụng các gói từ bản phân phối Linux của bạn nếu chúng
phù hợp -- phần đầu tiên bên dưới giải thích cách tiếp cận này. Một lợi thế của điều này
Cách tiếp cận thông thường là việc phân phối sẽ khớp với LLVM được Rust sử dụng
và Clang.

Một cách khác là sử dụng các phiên bản ổn định dựng sẵn của LLVM+Rust được cung cấp trên
ZZ0001ZZ. Đây là những thứ mỏng như nhau
và chuỗi công cụ LLVM nhanh từ ZZ0000ZZ với các phiên bản
của Rust đã thêm vào chúng những gì Rust hỗ trợ cho Linux. Hai bộ được cung cấp:
"LLVM mới nhất" và "LLVM phù hợp" (vui lòng xem liên kết để biết thêm thông tin).

Ngoài ra, hai phần "Yêu cầu" tiếp theo sẽ giải thích từng thành phần và
cách cài đặt chúng thông qua ZZ0000ZZ, trình cài đặt độc lập từ Rust
và/hoặc xây dựng chúng.

Phần còn lại của tài liệu giải thích các khía cạnh khác về cách bắt đầu.


Phân phối
-------------

Arch Linux
**********

Arch Linux cung cấp các bản phát hành Rust gần đây và do đó nó thường hoạt động tốt
của hộp, ví dụ::

pacman -S rỉ sét-src rỉ sét-bindgen


Debian
******

Debian 13 (Trixie), cũng như Kiểm tra và Debian Không ổn định (Sid) cung cấp các
Rust phát hành và do đó chúng thường hoạt động tốt, ví dụ::

apt cài đặt Rustc Rust-src bindgen Rustfmt Rust-clippy


Fedora Linux
************

Fedora Linux cung cấp các bản phát hành Rust gần đây và do đó nó thường hoạt động tốt
của hộp, ví dụ::

dnf cài đặt Rust Rust-src bindgen-cli Rustfmt clippy


Gentoo Linux
************

Gentoo Linux cung cấp các bản phát hành Rust gần đây và do đó nó thường hoạt động tốt
của hộp, ví dụ::

USE='Rust-src Rustfmt clippy' xuất hiện dev-lang/rust dev-util/bindgen

ZZ0000ZZ có thể cần được thiết lập.


Nix
***

Nix cung cấp các bản phát hành Rust gần đây và do đó nó thường hoạt động tốt
hộp, ví dụ::

{ gói ? nhập <nixpkgs> {} }:
	pkgs.mkShell {
	  bản địaBuildInputs = với pkgs; [ Rustc Rust-bindgen Rustfmt clippy ];
	  RUST_LIB_SRC = "${pkgs.rust.packages.stable.rustPlatform.rustLibSrc}";
	}


mởSUSE
********

openSUSE Slowroll và openSUSE Tumbleweed cung cấp các bản phát hành Rust gần đây và do đó
nhìn chung chúng sẽ hoạt động tốt, ví dụ:::

zypper cài đặt Rust Rust-src Rust-bindgen clang


Ubuntu
******

Ubuntu 25.10 và 26.04 LTS cung cấp các bản phát hành Rust gần đây và do đó chúng nên
thường hoạt động tốt, ví dụ::

apt cài đặt Rustc Rust-src bindgen Rustfmt Rust-clippy

Ngoài ra, cần phải đặt ZZ0000ZZ, ví dụ::

RUST_LIB_SRC=/usr/src/rustc-$(rustc --version | cut -d' ' -f2)/library

Để thuận tiện, ZZ0000ZZ có thể được xuất sang môi trường toàn cầu.


24.04 LTS trở lên
~~~~~~~~~~~~~~~~~~~

Mặc dù Ubuntu 24.04 LTS và các phiên bản cũ hơn vẫn cung cấp Rust gần đây
phát hành, chúng yêu cầu phải thiết lập một số cấu hình bổ sung, sử dụng
các gói được phiên bản, ví dụ::

apt cài đặt Rustc-1.85 Rust-1.85-src bindgen-0.71 Rustfmt-1.85 \
		rỉ sét-1,85-clippy
	ln -s /usr/lib/rust-1.85/bin/rustfmt /usr/bin/rustfmt-1.85
	ln -s /usr/lib/rust-1.85/bin/clippy-driver /usr/bin/clippy-driver-1.85

Không có gói nào trong số này đặt công cụ của chúng làm mặc định; do đó họ nên
được chỉ định rõ ràng, ví dụ::

tạo LLVM=1 RUSTC=rustc-1.85 RUSTDOC=rustdoc-1.85 RUSTFMT=rustfmt-1.85 \
		CLIPPY_DRIVER=clippy-driver-1.85 BINDGEN=bindgen-0.71

Ngoài ra, hãy sửa đổi biến ZZ0000ZZ để đặt các tệp nhị phân Rust 1.85
đầu tiên và đặt ZZ0001ZZ làm mặc định, ví dụ::

PATH=/usr/lib/rust-1.85/bin:$PATH
	cập nhật thay thế --install /usr/bin/bindgen bindgen \
		/usr/bin/bindgen-0.71 100
	cập nhật thay thế --set bindgen /usr/bin/bindgen-0.71

ZZ0000ZZ có thể cần được đặt khi sử dụng các gói đã được phiên bản, ví dụ:::

RUST_LIB_SRC=/usr/src/rustc-$(rustc-1.85 --version | cut -d' ' -f2)/library

Để thuận tiện, ZZ0000ZZ có thể được xuất sang môi trường toàn cầu.

Ngoài ra, ZZ0000ZZ có sẵn trong các phiên bản mới hơn (24.04 LTS),
nhưng nó có thể không có sẵn ở những phiên bản cũ hơn (20.04 LTS và 22.04 LTS),
do đó ZZ0001ZZ có thể cần được xây dựng thủ công (vui lòng xem bên dưới).


Yêu cầu: Tòa nhà
----------------------

Phần này giải thích cách tìm nạp các công cụ cần thiết để xây dựng.

Để dễ dàng kiểm tra xem các yêu cầu có được đáp ứng hay không, mục tiêu sau đây
có thể được sử dụng::

làm cho LLVM=1 có sẵn

Điều này kích hoạt logic tương tự được Kconfig sử dụng để xác định xem
ZZ0000ZZ nên được kích hoạt; nhưng nó cũng giải thích tại sao không
nếu đó là trường hợp.


rỉ sét
*****

Cần có phiên bản mới nhất của trình biên dịch Rust.

Nếu ZZ0000ZZ đang được sử dụng, hãy nhập thư mục xây dựng kernel (hoặc sử dụng
Đối số ZZ0001ZZ cho lệnh phụ ZZ0002ZZ) và chạy,
ví dụ::

thiết lập ghi đè rỉ sét ổn định

Điều này sẽ cấu hình thư mục làm việc của bạn để sử dụng phiên bản đã cho của
ZZ0000ZZ mà không ảnh hưởng đến chuỗi công cụ mặc định của bạn.

Lưu ý rằng việc ghi đè áp dụng cho thư mục làm việc hiện tại (và
các thư mục con).

Nếu bạn không sử dụng ZZ0000ZZ, hãy tìm trình cài đặt độc lập từ:

ZZ0000ZZ


Nguồn thư viện chuẩn Rust
****************************

Nguồn thư viện chuẩn Rust là bắt buộc vì hệ thống xây dựng sẽ
biên dịch chéo ZZ0000ZZ.

Nếu ZZ0000ZZ đang được sử dụng, hãy chạy::

thành phần Rustup thêm Rust-src

Các thành phần được cài đặt trên mỗi chuỗi công cụ, do đó nâng cấp trình biên dịch Rust
phiên bản sau này yêu cầu thêm lại thành phần.

Mặt khác, nếu sử dụng trình cài đặt độc lập, cây nguồn Rust có thể bị
được tải xuống thư mục cài đặt của toolchain::

cuộn tròn -L "ZZ0001ZZ --version ZZ0000ZZ
		tar -xzf - -C "$(rustc --print sysroot)/lib" \
		"rust-src-$(rustc --version | cut -d' ' -f2)/rust-src/lib/" \
		--strip-thành phần=3

Trong trường hợp này, việc nâng cấp phiên bản trình biên dịch Rust sau này yêu cầu phải thực hiện thủ công.
cập nhật cây nguồn (điều này có thể được thực hiện bằng cách xóa ZZ0000ZZ sau đó chạy lại lệnh trên).


libclang
********

ZZ0000ZZ (một phần của LLVM) được ZZ0001ZZ sử dụng để hiểu mã C
trong kernel, có nghĩa là LLVM cần được cài đặt; giống như khi hạt nhân
được biên dịch với ZZ0002ZZ.

Các bản phân phối Linux có thể có sẵn một bản phân phối phù hợp, vì vậy
tốt nhất nên kiểm tra điều đó trước.

Ngoài ra còn có một số tệp nhị phân cho một số hệ thống và kiến ​​trúc được tải lên tại:

ZZ0000ZZ

Mặt khác, việc xây dựng LLVM mất khá nhiều thời gian, nhưng đây không phải là một quá trình phức tạp:

ZZ0000ZZ

Vui lòng xem Documentation/kbuild/llvm.rst để biết thêm thông tin và các cách khác
để tìm nạp các bản phát hành và gói phân phối dựng sẵn.


chất kết dính
*******

Các liên kết với phía C của kernel được tạo tại thời điểm xây dựng bằng cách sử dụng
công cụ ZZ0000ZZ.

Ví dụ: cài đặt nó thông qua (lưu ý rằng thao tác này sẽ tải xuống và xây dựng công cụ
từ nguồn)::

cài đặt hàng hóa --bindgen-cli bị khóa

ZZ0000ZZ sử dụng thùng ZZ0001ZZ để tìm ZZ0002ZZ phù hợp (mà
có thể được liên kết tĩnh, động hoặc được tải khi chạy). Theo mặc định,
Lệnh ZZ0003ZZ ở trên sẽ tạo ra tệp nhị phân ZZ0004ZZ sẽ tải
ZZ0005ZZ khi chạy. Nếu không tìm thấy nó (hoặc ZZ0006ZZ khác với
nên sử dụng cái được tìm thấy), quy trình có thể được điều chỉnh, ví dụ: bằng cách sử dụng
Biến môi trường ZZ0007ZZ. Để biết chi tiết, vui lòng xem ZZ0008ZZ
tài liệu tại:

ZZ0000ZZ

ZZ0000ZZ


Yêu cầu: Đang phát triển
------------------------

Phần này giải thích cách tìm nạp các công cụ cần thiết để phát triển. Đó là,
chúng không cần thiết khi chỉ xây dựng kernel.


rỉ sét
*******

Công cụ ZZ0000ZZ được sử dụng để tự động định dạng tất cả mã hạt nhân Rust,
bao gồm các ràng buộc C được tạo ra (để biết chi tiết, vui lòng xem
mã hóa-guidelines.rst).

Nếu ZZ0000ZZ đang được sử dụng, cấu hình ZZ0001ZZ của nó đã cài đặt công cụ,
do đó không cần phải làm gì cả. Nếu một cấu hình khác đang được sử dụng, thành phần
có thể được cài đặt bằng tay::

thành phần Rustup thêm Rustfmt

Các trình cài đặt độc lập cũng đi kèm với ZZ0000ZZ.


gắt gỏng
******

ZZ0000ZZ là kẻ nói dối Rust. Việc chạy nó sẽ cung cấp thêm các cảnh báo cho mã Rust.
Nó có thể được chạy bằng cách chuyển ZZ0001ZZ tới ZZ0002ZZ (để biết chi tiết, vui lòng xem
thông tin chung.rst).

Nếu ZZ0000ZZ đang được sử dụng, cấu hình ZZ0001ZZ của nó đã cài đặt công cụ,
do đó không cần phải làm gì cả. Nếu một cấu hình khác đang được sử dụng, thành phần
có thể được cài đặt bằng tay::

thành phần rỉ sét thêm clippy

Các trình cài đặt độc lập cũng đi kèm với ZZ0000ZZ.


bác sĩ rỉ sét
*******

ZZ0000ZZ là công cụ tài liệu dành cho Rust. Nó tạo ra HTML khá đẹp
tài liệu về mã Rust (để biết chi tiết, vui lòng xem
thông tin chung.rst).

ZZ0000ZZ cũng được sử dụng để kiểm tra các ví dụ được cung cấp trong mã Rust được ghi lại
(được gọi là doctest hoặc kiểm tra tài liệu). ZZ0001ZZ Sử dụng mục tiêu
tính năng này.

Nếu ZZ0000ZZ đang được sử dụng, tất cả các cấu hình đã cài đặt công cụ,
do đó không cần phải làm gì cả.

Các trình cài đặt độc lập cũng đi kèm với ZZ0000ZZ.


máy phân tích rỉ sét
*************

Máy chủ ngôn ngữ ZZ0000ZZ có thể
được sử dụng với nhiều trình soạn thảo để bật đánh dấu, hoàn thành cú pháp, đi tới
định nghĩa và các tính năng khác.

ZZ0000ZZ cần một tệp cấu hình, ZZ0001ZZ, tệp này
có thể được tạo bởi ZZ0002ZZ Tạo mục tiêu::

tạo LLVM=1 máy phân tích rỉ sét


Cấu hình
-------------

ZZ0000ZZ (ZZ0001ZZ) cần được bật trong ZZ0002ZZ
thực đơn. Tùy chọn này chỉ được hiển thị nếu tìm thấy chuỗi công cụ Rust phù hợp (xem
ở trên), miễn là các yêu cầu khác được đáp ứng. Đổi lại, điều này sẽ làm
hiển thị phần còn lại của các tùy chọn phụ thuộc vào Rust.

Sau đó, đi tới::

Hack hạt nhân
	    -> Mã hạt nhân mẫu
	        -> Mẫu rỉ sét

Và kích hoạt một số mô-đun mẫu ở dạng tích hợp hoặc có thể tải được.


Xây dựng
--------

Xây dựng kernel với chuỗi công cụ LLVM hoàn chỉnh là thiết lập được hỗ trợ tốt nhất
vào lúc này. Đó là::

làm cho LLVM=1

Sử dụng GCC cũng hoạt động với một số cấu hình, nhưng nó mang tính thử nghiệm cao ở
khoảnh khắc.


hack
-------

Để tìm hiểu sâu hơn, hãy xem mã nguồn của các mẫu
tại ZZ0000ZZ, mã hỗ trợ Rust trong ZZ0001ZZ và
menu ZZ0002ZZ trong ZZ0003ZZ.