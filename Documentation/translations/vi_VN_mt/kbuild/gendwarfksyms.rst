.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/gendwarfksyms.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Phiên bản mô-đun DWARF
=======================

Giới thiệu
============

Khi CONFIG_MODVERSIONS được bật, các phiên bản ký hiệu cho mô-đun
thường được tính toán từ mã nguồn được xử lý trước bằng cách sử dụng
Công cụ ZZ0000ZZ.  Tuy nhiên, điều này không tương thích với các ngôn ngữ như
như Rust, nơi mã nguồn không có đủ thông tin về
kết quả là ABI. Với CONFIG_GENDWARFKSYMS (và CONFIG_DEBUG_INFO)
được chọn, thay vào đó ZZ0001ZZ được sử dụng để tính toán các phiên bản ký hiệu
từ thông tin gỡ lỗi DWARF, chứa thông tin cần thiết
chi tiết về mô-đun cuối cùng ABI.

phụ thuộc
------------

gendwarfksyms phụ thuộc vào thư viện libelf, libdw và zlib.

Dưới đây là một số ví dụ về cách cài đặt các phần phụ thuộc này:

* Arch Linux và các dẫn xuất::

sudo pacman --cần thiết -S libelf zlib

* Debian, Ubuntu và các phiên bản phái sinh::

sudo apt cài đặt libelf-dev libdw-dev zlib1g-dev

* Fedora và các dẫn xuất::

sudo dnf cài đặt elfutils-libelf-devel elfutils-devel zlib-devel

* openSUSE và các dẫn xuất::

sudo zypper cài đặt libelf-devel libdw-devel zlib-devel

Cách sử dụng
-----

gendwarfksyms chấp nhận danh sách các tệp đối tượng trên dòng lệnh và
danh sách tên ký hiệu (mỗi tên một dòng) ở dạng đầu vào tiêu chuẩn::

Cách sử dụng: gendwarfksyms [tùy chọn] elf-object-file ... < danh sách biểu tượng

Tùy chọn:
	  -d, --debug In thông tin gỡ lỗi
	      --dump-dies Kết xuất nội dung DWARF DIE
	      --dump-die-map In thông tin gỡ lỗi về các thay đổi của die_map
	      --dump-types Chuỗi kiểu kết xuất
	      --dump-versions Kết xuất các chuỗi loại mở rộng được sử dụng cho các phiên bản ký hiệu
	  -s, --stable Hỗ trợ tính năng ổn định kABI
	  -T, --symtypes file Viết một tập tin symtypes
	  -h, --help In thông báo này


Loại thông tin sẵn có
=============================

Mặc dù các ký hiệu thường được xuất trong cùng một đơn vị dịch (TU)
nơi chúng được xác định, việc TU xuất cũng hoàn toàn ổn
các ký hiệu bên ngoài. Ví dụ, điều này được thực hiện khi tính toán ký hiệu
các phiên bản để xuất khẩu ở dạng mã lắp ráp độc lập.

Để đảm bảo trình biên dịch phát ra thông tin loại DWARF cần thiết trong
TU nơi các ký hiệu thực sự được xuất, gendwarfksyms thêm một con trỏ
để xuất các ký hiệu trong macro ZZ0000ZZ bằng cách sử dụng thông tin sau
vĩ mô::

#define __GENDWARFKSYMS_EXPORT(sym) \
		kiểu tĩnh(sym) *__gendwarfksyms_ptr_##sym __used \
			__section(".discard.gendwarfksyms") = &sym;


Khi tìm thấy một con trỏ ký hiệu trong DWARF, gendwarfksyms có thể sử dụng nó
loại để tính toán các phiên bản ký hiệu ngay cả khi ký hiệu được xác định
ở nơi khác. Tên của con trỏ biểu tượng dự kiến sẽ bắt đầu bằng
ZZ0000ZZ, theo sau là tên của biểu tượng được xuất.

Định dạng đầu ra của Symtypes
======================

Tương tự như genksyms, gendwarfksyms hỗ trợ viết symtypes
tệp cho từng đối tượng được xử lý có chứa các loại để xuất
các ký hiệu và từng loại tham chiếu được sử dụng để tính toán ký hiệu
các phiên bản. Những tập tin này có thể hữu ích khi cố gắng xác định những gì
chính xác khiến các phiên bản biểu tượng thay đổi giữa các bản dựng. Để tạo ra
symtypes trong quá trình xây dựng kernel, hãy đặt ZZ0000ZZ.

Phù hợp với định dạng hiện có, cột đầu tiên của mỗi dòng chứa
tham chiếu kiểu hoặc tên ký hiệu. Tham chiếu kiểu có
tiền tố một chữ cái, theo sau là "#" và tên loại. bốn
các loại tham chiếu được hỗ trợ ::

e#<type> = enum
	s#<type> = cấu trúc
	t#<type> = typedef
	u#<type> = đoàn

Nhập tên có khoảng trắng được gói trong dấu ngoặc đơn, ví dụ:::

s#'core::result::Result<u8, core::num::error::ParseIntError>'

Phần còn lại của dòng chứa một chuỗi kiểu. Không giống như genksyms
tạo ra các chuỗi kiểu C, gendwarfksyms sử dụng cùng một chuỗi được phân tích cú pháp đơn giản
Định dạng DWARF do ZZ0000ZZ tạo ra, nhưng có tham chiếu loại
thay vì các chuỗi được mở rộng hoàn toàn.

Duy trì kABI ổn định
=========================

Các nhà bảo trì phân phối thường cần khả năng tương thích với ABI
thay đổi cấu trúc dữ liệu kernel do cập nhật hoặc backport LTS. sử dụng
ZZ0000ZZ truyền thống để ẩn những thay đổi này khỏi biểu tượng
phiên bản sẽ không hoạt động khi xử lý tệp đối tượng. Để hỗ trợ điều này
trường hợp sử dụng, gendwarfksyms cung cấp các tính năng ổn định kABI được thiết kế để
ẩn các thay đổi sẽ không ảnh hưởng đến ABI khi tính toán các phiên bản. Những cái này
tất cả các tính năng đều được kiểm soát phía sau cờ dòng lệnh ZZ0002ZZ và
không được sử dụng trong kernel dòng chính. Để sử dụng các tính năng ổn định trong kernel
xây dựng, đặt ZZ0001ZZ.

Ví dụ về cách sử dụng các tính năng này được cung cấp trong
Thư mục ZZ0000ZZ, bao gồm các macro trợ giúp
để chú thích mã nguồn. Lưu ý rằng vì các tính năng này chỉ được sử dụng để
chuyển đổi đầu vào cho phiên bản ký hiệu, người dùng chịu trách nhiệm về
đảm bảo rằng những thay đổi của họ thực sự sẽ không phá vỡ ABI.

quy tắc kABI
----------

Quy tắc kABI cho phép phân phối tinh chỉnh một số phần nhất định
của đầu ra gendwarfksyms và do đó kiểm soát cách biểu tượng
phiên bản được tính toán. Những quy định này được xác định trong
Phần ZZ0000ZZ của tệp đối tượng và
bao gồm các chuỗi kết thúc null đơn giản với cấu trúc sau ::

phiên bản\0type\0target\0value\0

Chuỗi chuỗi này được lặp lại nhiều lần nếu cần để thể hiện tất cả
các quy tắc. Các trường như sau:

- ZZ0000ZZ: Đảm bảo khả năng tương thích ngược cho những thay đổi trong tương lai đối với
  cấu trúc. Hiện tại dự kiến ​​là "1".
- ZZ0001ZZ: Cho biết loại quy tắc đang được áp dụng.
- ZZ0002ZZ: Chỉ định mục tiêu của quy tắc, điển hình là đầy đủ
  tên đủ điều kiện của Mục nhập thông tin gỡ lỗi DWARF (DIE).
- ZZ0003ZZ: Cung cấp dữ liệu theo quy tắc cụ thể.

Ví dụ: các macro trợ giúp sau đây có thể được sử dụng để chỉ định các quy tắc
trong mã nguồn::

#define ___KABI_RULE(gợi ý, mục tiêu, giá trị) \
		const char tĩnh __PASTE(__gendwarfksyms_rule_, \
					  __COUNTER__)[] __used __aligned(1) \
			__section(".discard.gendwarfksyms.kabi_rules") = \
				Giá trị "1\0" #hint "\0" mục tiêu "\0"

#define __KABI_RULE(gợi ý, mục tiêu, giá trị) \
		___KABI_RULE(gợi ý, #target, #value)


Hiện tại, chỉ hỗ trợ các quy tắc được thảo luận trong phần này, nhưng
định dạng này có thể mở rộng đủ để cho phép thêm các quy tắc khác dưới dạng
nhu cầu phát sinh.

Quản lý khả năng hiển thị định nghĩa
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một tuyên bố có thể thay đổi thành một định nghĩa đầy đủ khi bổ sung bao gồm
được kéo vào đơn vị dịch thuật. Điều này thay đổi phiên bản của bất kỳ
ký hiệu tham chiếu đến loại ngay cả khi ABI không thay đổi. Như
có thể không thể loại bỏ các phần bao gồm mà không làm hỏng bản dựng,
Quy tắc ZZ0000ZZ có thể được sử dụng để chỉ định một loại là chỉ khai báo, thậm chí
nếu thông tin gỡ lỗi chứa định nghĩa đầy đủ.

Các trường quy tắc dự kiến ​​​​sẽ như sau:

- ZZ0000ZZ: "declonly"
- ZZ0001ZZ: Tên đầy đủ của cấu trúc dữ liệu đích
  (như thể hiện trong đầu ra ZZ0003ZZ).
- ZZ0002ZZ: Trường này bị bỏ qua.

Sử dụng macro ZZ0000ZZ, quy tắc này có thể được xác định là::

#define KABI_DECLONLY(fqn) __KABI_RULE(declonly, fqn, )

Ví dụ sử dụng::

cấu trúc s {
		/*định nghĩa */
	};

KABI_DECLONLY(các);

Thêm điều tra viên
~~~~~~~~~~~~~~~~~~

Đối với enum, tất cả các điều tra viên và giá trị của chúng đều được đưa vào tính toán
phiên bản ký hiệu, điều này sẽ trở thành vấn đề nếu sau này chúng ta cần bổ sung thêm
điều tra viên mà không thay đổi phiên bản ký hiệu. ZZ0000ZZ
quy tắc cho phép chúng ta ẩn các điều tra viên có tên khỏi đầu vào.

Các trường quy tắc dự kiến ​​​​sẽ như sau:

- ZZ0000ZZ: "enumerator_ignore"
- ZZ0001ZZ: Tên đầy đủ của enum mục tiêu
  (như được hiển thị trong đầu ra ZZ0003ZZ) và tên của
  trường liệt kê cách nhau bởi một khoảng trắng.
- ZZ0002ZZ: Trường này bị bỏ qua.

Sử dụng macro ZZ0000ZZ, quy tắc này có thể được xác định là::

#define KABI_ENUMERATOR_IGNORE(fqn, trường) \
		__KABI_RULE(enumerator_ignore, trường fqn, )

Ví dụ sử dụng::

enum e {
		A, B, C, D,
	};

KABI_ENUMERATOR_IGNORE(e, B);
	KABI_ENUMERATOR_IGNORE(e, C);

Nếu enum bao gồm thêm điểm đánh dấu kết thúc và các giá trị mới phải
được thêm vào giữa, chúng ta có thể cần sử dụng giá trị cũ cho lần cuối cùng
điều tra viên khi tính toán các phiên bản. Quy tắc ZZ0000ZZ cho phép
chúng tôi ghi đè giá trị của một điều tra viên để tính toán phiên bản:

- ZZ0000ZZ: "giá trị liệt kê"
- ZZ0001ZZ: Tên đầy đủ của enum mục tiêu
  (như được hiển thị trong đầu ra ZZ0003ZZ) và tên của
  trường liệt kê cách nhau bởi một khoảng trắng.
- ZZ0002ZZ: Giá trị nguyên dùng cho trường.

Sử dụng macro ZZ0000ZZ, quy tắc này có thể được xác định là::

#define KABI_ENUMERATOR_VALUE(fqn, trường, giá trị) \
		__KABI_RULE(giá trị liệt kê, trường fqn, giá trị)

Ví dụ sử dụng::

enum e {
		A, B, C, LAST,
	};

KABI_ENUMERATOR_IGNORE(e, C);
	KABI_ENUMERATOR_VALUE(e, LAST, 2);

Quản lý thay đổi kích thước cấu trúc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấu trúc dữ liệu có thể mờ một phần đối với các mô-đun nếu việc phân bổ của nó bị
được xử lý bởi lõi lõi và các mô-đun chỉ cần truy cập vào một số phần của nó
các thành viên. Trong tình huống này, có thể thêm thành viên mới vào
cấu trúc mà không phá vỡ ABI, miễn là bố cục cho bản gốc
thành viên không thay đổi.

Để thêm thành viên mới, chúng tôi có thể ẩn chúng khỏi phiên bản biểu tượng như
được mô tả trong phần ZZ0000ZZ, nhưng chúng tôi không thể
ẩn sự gia tăng kích thước cấu trúc. Quy tắc ZZ0001ZZ cho phép chúng ta
ghi đè kích thước cấu trúc được sử dụng để tạo phiên bản biểu tượng.

Các trường quy tắc dự kiến ​​​​sẽ như sau:

- ZZ0000ZZ: "byte_size"
- ZZ0001ZZ: Tên đầy đủ của cấu trúc dữ liệu đích
  (như thể hiện trong đầu ra ZZ0003ZZ).
- ZZ0002ZZ: Số thập phân dương biểu thị kích thước cấu trúc
  tính bằng byte.

Sử dụng macro ZZ0000ZZ, quy tắc này có thể được xác định là::

#define KABI_BYTE_SIZE(fqn, giá trị) \
		__KABI_RULE(kích thước byte, fqn, giá trị)

Ví dụ sử dụng::

cấu trúc s {
		/*Thành viên ban đầu không thay đổi */
		không dấu dài a;
		vô hiệu *p;

/* Đã thêm thành viên mới */
		KABI_IGNORE(0, n dài không dấu);
	};

KABI_BYTE_SIZE(các, 16);

Ghi đè chuỗi kiểu
~~~~~~~~~~~~~~~~~~~~~~~

Trong những tình huống hiếm hoi khi việc phân phối phải tạo ra những thay đổi đáng kể đối với
mặt khác, các cấu trúc dữ liệu không rõ ràng đã vô tình được đưa vào
trong ABI đã xuất bản, giữ cho các phiên bản biểu tượng ổn định bằng cách sử dụng nhiều hơn
các quy tắc kABI được nhắm mục tiêu có thể trở nên tẻ nhạt. Quy tắc ZZ0000ZZ cho phép chúng ta
để ghi đè chuỗi loại đầy đủ cho một loại hoặc ký hiệu và thậm chí thêm
các loại dành cho phiên bản không còn tồn tại trong kernel.

Các trường quy tắc dự kiến ​​​​sẽ như sau:

- ZZ0000ZZ: "loại_chuỗi"
- ZZ0001ZZ: Tên đầy đủ của cấu trúc dữ liệu đích
  (như được hiển thị trong đầu ra ZZ0003ZZ) hoặc ký hiệu.
- ZZ0002ZZ: Một chuỗi loại hợp lệ (như được hiển thị trong đầu ra ZZ0004ZZ))
  để sử dụng thay vì loại thực.

Sử dụng macro ZZ0000ZZ, quy tắc này có thể được xác định là::

#define KABI_TYPE_STRING(loại, str) \
		___KABI_RULE("type_string", loại, str)

Ví dụ sử dụng::

/* Kiểu ghi đè cho cấu trúc */
	KABI_TYPE_STRING("s#s",
		"cấu trúc_type s {"
			"thành viên base_type int byte_size(4) "
				"mã hóa(5) n"
			"data_member_location(0) "
		"} byte_size(8)");

/* Loại ghi đè cho ký hiệu */
	KABI_TYPE_STRING("my_symbol", "biến s#s");

Quy tắc ZZ0000ZZ chỉ nên được sử dụng như là phương sách cuối cùng nếu duy trì
một phiên bản ký hiệu ổn định không thể đạt được một cách hợp lý bằng cách sử dụng các phiên bản khác
có nghĩa là. Ghi đè chuỗi loại làm tăng nguy cơ hỏng ABI thực tế
sẽ không được chú ý vì nó ẩn tất cả các thay đổi đối với loại.

Thêm thành viên cấu trúc
------------------------

Có lẽ thay đổi phổ biến nhất tương thích với ABI là thêm thành viên vào
cấu trúc dữ liệu hạt nhân Khi dự đoán được những thay đổi về cấu trúc,
người duy trì phân phối có thể dành trước không gian trong
cấu trúc và sử dụng sau này mà không làm hỏng ABI. Nếu
cần thay đổi cấu trúc dữ liệu không có không gian dành riêng, hiện có
các lỗ căn chỉnh có thể được sử dụng thay thế. Trong khi các quy tắc kABI có thể
được thêm vào cho những loại thay đổi này, việc sử dụng các kết hợp thường là một giải pháp hiệu quả hơn
phương pháp tự nhiên. Phần này mô tả gendwarfksyms hỗ trợ việc sử dụng
không gian dành riêng trong cấu trúc dữ liệu và ẩn các thành viên không thay đổi
ABI khi tính toán các phiên bản ký hiệu.

Đặt chỗ và thay thế thành viên
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Không gian thường được dành riêng để sử dụng sau này bằng cách nối thêm các kiểu số nguyên hoặc
mảng, ở cuối cấu trúc dữ liệu, nhưng bất kỳ loại nào cũng có thể được sử dụng. Mỗi
thành viên dành riêng cần một tên duy nhất, nhưng mục đích thực tế thường là
không biết tại thời điểm đó không gian được dành riêng, để thuận tiện, tên mà
bắt đầu bằng ZZ0000ZZ bị bỏ qua khi tính toán các phiên bản ký hiệu::

cấu trúc s {
		dài một;
		dài __kabi_reserved_0; /*dành riêng cho việc sử dụng sau này*/
	};

Không gian dành riêng có thể được đưa vào sử dụng bằng cách gói thành viên trong một
liên minh, bao gồm loại ban đầu và thành viên thay thế::

cấu trúc s {
		dài một;
		công đoàn {
			dài __kabi_reserved_0; /*kiểu ban đầu*/
			cấu trúc b b; /*trường được thay thế */
		};
	};

Nếu ZZ0001ZZ. Cái này
đảm bảo loại gốc được sử dụng khi tính toán các phiên bản, nhưng tên
một lần nữa lại bị bỏ rơi. Phần còn lại của công đoàn bị bỏ qua.

Nếu chúng tôi thay thế một thành viên không tuân theo quy ước đặt tên này,
chúng ta cũng cần giữ nguyên tên gốc để tránh phải đổi phiên bản,
điều mà chúng ta có thể làm bằng cách thay đổi tên của thành viên công đoàn đầu tiên bắt đầu bằng
ZZ0000ZZ theo sau là tên gốc.

Các ví dụ bao gồm các macro ZZ0000ZZ giúp
đơn giản hóa quy trình và cũng đảm bảo thành viên thay thế chính xác
căn chỉnh và kích thước của nó sẽ không vượt quá không gian dành riêng.

.. _hiding_members:

Ẩn thành viên
~~~~~~~~~~~~~~

Dự đoán cấu trúc nào sẽ yêu cầu thay đổi trong quá trình hỗ trợ
khung thời gian không phải lúc nào cũng có thể thực hiện được, trong trường hợp đó người ta có thể phải dùng đến
để đặt các thành viên mới vào các lỗ căn chỉnh hiện có::

cấu trúc s {
		int một;
		/* một lỗ căn chỉnh 4 byte */
		dài không dấu b;
	};


Mặc dù điều này sẽ không thay đổi kích thước của cấu trúc dữ liệu nhưng người ta cần phải
có thể ẩn các thành viên đã thêm khỏi phiên bản biểu tượng. Tương tự
vào các trường dành riêng, điều này có thể được thực hiện bằng cách gói phần bổ sung
thành viên của một liên minh trong đó một trong các trường có tên bắt đầu bằng
ZZ0000ZZ::

cấu trúc s {
		int một;
		công đoàn {
			char __kabi_ignored_0;
			int n;
		};
		dài không dấu b;
	};

Với ZZ0001ZZ, cả hai phiên bản đều cho ra cùng một phiên bản ký hiệu. các
các ví dụ bao gồm macro ZZ0000ZZ để đơn giản hóa mã.
