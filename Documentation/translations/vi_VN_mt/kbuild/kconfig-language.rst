.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/kconfig-language.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Ngôn ngữ Kconfig
==================

Giới thiệu
------------

Cơ sở dữ liệu cấu hình là tập hợp các tùy chọn cấu hình
được tổ chức theo cấu trúc cây::

+- Tùy chọn mức độ trưởng thành của mã
	|  +- Nhắc nhở phát triển và/hoặc mã/trình điều khiển chưa hoàn chỉnh
	+- Thiết lập chung
	|  +- Hỗ trợ mạng
	|  +- Hệ thống V IPC
	|  +- BSD Kế toán quy trình
	|  +- Hỗ trợ hệ thống
	+- Hỗ trợ mô-đun có thể tải
	|  +- Kích hoạt hỗ trợ mô-đun có thể tải
	|     +- Đặt thông tin phiên bản trên tất cả các ký hiệu mô-đun
	|     +- Trình tải mô-đun hạt nhân
	+- ...

Mỗi mục có sự phụ thuộc riêng của nó. Những phụ thuộc này được sử dụng
để xác định khả năng hiển thị của một mục. Bất kỳ mục nhập con nào chỉ
hiển thị nếu mục cha mẹ của nó cũng hiển thị.

Mục menu
------------

Hầu hết các mục đều xác định tùy chọn cấu hình; tất cả các mục khác giúp tổ chức
họ. Một tùy chọn cấu hình duy nhất được xác định như sau::

cấu hình MODVERSIONS
	bool "Đặt thông tin phiên bản trên tất cả các ký hiệu mô-đun"
	phụ thuộc vào MODULES
	giúp đỡ
	  Thông thường, các mô-đun phải được biên dịch lại bất cứ khi nào bạn chuyển sang một mô-đun mới.
	  hạt nhân.  ...

Mỗi dòng bắt đầu bằng một từ khóa và có thể được theo sau bởi nhiều từ khóa
lý lẽ.  "config" bắt đầu một mục cấu hình mới. Những dòng sau
xác định các thuộc tính cho tùy chọn cấu hình này. Các thuộc tính có thể là loại
tùy chọn cấu hình, lời nhắc đầu vào, phần phụ thuộc, văn bản trợ giúp và mặc định
các giá trị. Một tùy chọn cấu hình có thể được xác định nhiều lần với cùng một
tên, nhưng mọi định nghĩa chỉ có thể có một dấu nhắc đầu vào duy nhất và
loại không được xung đột.

Thuộc tính thực đơn
-------------------

Một mục menu có thể có một số thuộc tính. Không phải tất cả trong số họ là
áp dụng ở mọi nơi (xem cú pháp).

- định nghĩa kiểu: "bool"/"tristate"/"string"/"hex"/"int"

Mỗi tùy chọn cấu hình phải có một loại. Chỉ có hai loại cơ bản:
  tristate và chuỗi; các loại khác dựa trên hai loại này. Loại
  định nghĩa tùy ý chấp nhận lời nhắc đầu vào, vì vậy hai ví dụ này
  tương đương::

bool "Hỗ trợ mạng"

Và::

bool
	nhắc "Hỗ trợ mạng"

- dấu nhắc đầu vào: "prompt" <prompt> ["if" <expr>]

Mỗi mục menu có thể có nhiều nhất một dấu nhắc, được sử dụng để hiển thị
  tới người dùng. Tùy chọn chỉ có thể thêm phần phụ thuộc cho lời nhắc này
  với "nếu". Nếu không có lời nhắc, tùy chọn cấu hình sẽ không hiển thị
  ký hiệu, nghĩa là người dùng không thể trực tiếp thay đổi giá trị của nó (chẳng hạn như
  thay đổi giá trị trong ZZ0000ZZ) và tùy chọn sẽ không xuất hiện trong bất kỳ
  menu cấu hình. Giá trị của nó chỉ có thể được đặt thông qua "mặc định" và "chọn" (xem
  bên dưới).

- giá trị mặc định: "mặc định" <expr> ["if" <expr>]

Tùy chọn cấu hình có thể có bất kỳ số lượng giá trị mặc định nào. Nếu nhiều
  các giá trị mặc định được hiển thị, chỉ giá trị được xác định đầu tiên mới hoạt động.
  Giá trị mặc định không bị giới hạn ở mục menu nơi chúng tồn tại
  được xác định. Điều này có nghĩa là mặc định có thể được xác định ở một nơi khác hoặc
  bị ghi đè bởi định nghĩa trước đó.
  Giá trị mặc định chỉ được gán cho ký hiệu cấu hình nếu không có ký hiệu nào khác
  giá trị do người dùng đặt (thông qua lời nhắc nhập ở trên). Nếu một đầu vào
  lời nhắc hiển thị, giá trị mặc định được hiển thị cho người dùng và có thể
  bị anh ta lấn át.
  Theo tùy chọn, chỉ có thể thêm các phụ thuộc cho giá trị mặc định này bằng
  "nếu".

Giá trị mặc định được cố tình đặt mặc định là 'n' để tránh làm phồng lên
 xây dựng. Với một số ngoại lệ, các tùy chọn cấu hình mới sẽ không thay đổi điều này. các
 mục đích là để "tạo cấu hình cũ" để thêm ít nhất có thể vào cấu hình từ
 thả ra để thả ra.

Lưu ý:
	Những điều đáng được coi là "mặc định" bao gồm:

a) Tùy chọn Kconfig mới cho thứ luôn được xây dựng
	   phải là "mặc định y".

b) Tùy chọn Kconfig gác cổng mới giúp ẩn/hiển thị Kconfig khác
	   tùy chọn (nhưng không tạo ra bất kỳ mã nào của riêng nó), phải là
	   "mặc định y" để mọi người sẽ thấy các tùy chọn khác đó.

c) Hành vi của người lái xe phụ hoặc các tùy chọn tương tự dành cho người lái xe
	   "mặc định n". Điều này cho phép bạn cung cấp các giá trị mặc định hợp lý.

d) Phần cứng hoặc cơ sở hạ tầng mà mọi người mong đợi, chẳng hạn như CONFIG_NET
	   hoặc CONFIG_BLOCK. Đây là những trường hợp ngoại lệ hiếm hoi.

- định nghĩa kiểu + giá trị mặc định::

"def_bool"/"def_tristate" <expr> ["if" <expr>]

Đây là ký hiệu viết tắt cho định nghĩa kiểu cộng với một giá trị.
  Các phần phụ thuộc tùy chọn cho giá trị mặc định này có thể được thêm bằng "if".

- phụ thuộc: "phụ thuộc vào" <expr> ["if" <expr>]

Điều này xác định sự phụ thuộc cho mục menu này. Nếu nhiều
  các phụ thuộc được xác định, chúng được kết nối với '&&'. phụ thuộc
  được áp dụng cho tất cả các tùy chọn khác trong mục menu này (cũng
  chấp nhận biểu thức "if"), vì vậy hai ví dụ này tương đương nhau::

bool "foo" nếu BAR
	mặc định y nếu BAR

Và::

phụ thuộc vào BAR
	bool "foo"
	mặc định y

Bản thân định nghĩa phụ thuộc có thể có điều kiện bằng cách thêm "if"
  theo sau là một biểu thức. Ví dụ::

cấu hình FOO
	ba bang
	phụ thuộc vào BAR nếu BAZ

nghĩa là FOO bị ràng buộc bởi giá trị của BAR chỉ khi BAZ là
  cũng được thiết lập.

- phụ thuộc ngược lại: "select" <symbol> ["if" <expr>]

Trong khi các phụ thuộc thông thường làm giảm giới hạn trên của ký hiệu (xem
  bên dưới), các phụ thuộc ngược có thể được sử dụng để buộc giới hạn thấp hơn của
  một biểu tượng khác. Giá trị của biểu tượng menu hiện tại được sử dụng làm
  giá trị tối thiểu <biểu tượng> có thể được đặt thành. Nếu <ký hiệu> được chọn nhiều
  lần, giới hạn được đặt thành lựa chọn lớn nhất.
  Phụ thuộc ngược chỉ có thể được sử dụng với boolean hoặc tristate
  biểu tượng.

Lưu ý:
	select nên được sử dụng cẩn thận. chọn sẽ buộc
	một biểu tượng thành một giá trị mà không cần truy cập các phần phụ thuộc.
	Bằng cách lạm dụng chọn, bạn thậm chí có thể chọn biểu tượng FOO
	nếu FOO phụ thuộc vào BAR thì chưa được đặt.
	Nói chung chỉ sử dụng chọn những biểu tượng không nhìn thấy được
	(không có lời nhắc ở bất cứ đâu) và cho các ký hiệu không có phụ thuộc.
	Điều đó sẽ hạn chế tính hữu ích nhưng mặt khác tránh được
	các cấu hình bất hợp pháp trên tất cả.

Nếu "select" <symbol> được theo sau bởi "if" <expr>, <symbol> sẽ là
	được chọn bởi AND logic của giá trị của biểu tượng menu hiện tại
	và <expr>. Điều này có nghĩa là giới hạn dưới có thể bị hạ cấp do
	sự hiện diện của "nếu" <expr>. Hành vi này có vẻ kỳ lạ nhưng chúng tôi dựa vào
	nó. (Tương lai của hành vi này vẫn chưa được quyết định.)

- phụ thuộc ngược yếu: "ngụ ý" <symbol> ["if" <expr>]

Điều này tương tự như "chọn" vì nó thực thi giới hạn thấp hơn trên một
  ký hiệu ngoại trừ giá trị của ký hiệu "ngụ ý" vẫn có thể được đặt thành n
  từ phần phụ thuộc trực tiếp hoặc bằng lời nhắc hiển thị.

Cho ví dụ sau::

cấu hình FOO
	ba chữ "foo"
	ngụ ý BAZ

cấu hình BAZ
	tristate "baz"
	phụ thuộc vào BAR

Có thể có các giá trị sau:

=== === =============================
	FOO BAR BAZ Lựa chọn mặc định cho BAZ
	=== === =============================
	n y n N/m/y
	m y m M/y/n
	y y y Y/m/n
	n m n N/m
	ừ ừ ừ ừ M/n
	y m m M/n
	y n * N
	=== === =============================

Điều này rất hữu ích, ví dụ: với nhiều trình điều khiển muốn chỉ ra
  khả năng kết nối vào một hệ thống con thứ cấp đồng thời cho phép người dùng
  định cấu hình hệ thống con đó mà không cần phải hủy cài đặt các trình điều khiển này.

Lưu ý: Nếu tính năng do BAZ cung cấp rất được mong muốn đối với FOO,
  FOO không chỉ ngụ ý BAZ mà còn cả sự phụ thuộc của nó BAR::

cấu hình FOO
	ba chữ "foo"
	ngụ ý BAR
	ngụ ý BAZ

Lưu ý: Nếu "ngụ ý" <biểu tượng> được theo sau bởi "if" <expr>, thì mặc định là <biểu tượng>
  sẽ là AND logic của giá trị của biểu tượng menu hiện tại và <expr>.
  (Tương lai của hành vi này vẫn chưa được quyết định.)

- giới hạn hiển thị menu: "hiển thị nếu" <expr>

Thuộc tính này chỉ áp dụng cho các khối menu, nếu điều kiện là
  sai, khối menu không được hiển thị cho người dùng (các ký hiệu
  Tuy nhiên, ở đó vẫn có thể được chọn bởi các ký hiệu khác). Đó là
  tương tự như thuộc tính "nhắc nhở" có điều kiện cho từng menu
  mục nhập. Giá trị mặc định của "hiển thị" là đúng.

- phạm vi số: "phạm vi" <ký hiệu> <ký hiệu> ["if" <expr>]

Điều này cho phép giới hạn phạm vi giá trị đầu vào có thể có cho int
  và các ký hiệu hex. Người dùng chỉ có thể nhập giá trị lớn hơn
  hoặc bằng ký hiệu thứ nhất và nhỏ hơn hoặc bằng ký hiệu thứ hai
  biểu tượng.

- văn bản trợ giúp: "giúp đỡ"

Điều này xác định một văn bản trợ giúp. Sự kết thúc của văn bản trợ giúp được xác định bởi
  mức độ thụt lề, điều này có nghĩa là nó kết thúc ở dòng đầu tiên có
  thụt lề nhỏ hơn dòng đầu tiên của văn bản trợ giúp.

- thuộc tính mô-đun: "mô-đun"
  Điều này tuyên bố biểu tượng sẽ được sử dụng làm biểu tượng MODULES, biểu tượng này
  bật trạng thái mô-đun thứ ba cho tất cả các ký hiệu cấu hình.
  Nhiều nhất một biểu tượng có thể được đặt tùy chọn "mô-đun".

- thuộc tính chuyển tiếp: "chuyển tiếp"
  Điều này khai báo ký hiệu là chuyển tiếp, nghĩa là nó cần được xử lý
  trong quá trình cấu hình nhưng bị bỏ qua trong các tệp .config mới được viết.
  Các ký hiệu chuyển tiếp rất hữu ích cho khả năng tương thích ngược trong quá trình cấu hình
  di chuyển tùy chọn - chúng cho phép olddefconfig xử lý .config hiện có
  các tệp trong khi đảm bảo tùy chọn cũ không xuất hiện trong cấu hình mới.

Ký hiệu chuyển tiếp:
  - Không có lời nhắc (không hiển thị cho người dùng trong menu)
  - Được xử lý bình thường trong quá trình cấu hình (các giá trị được đọc và sử dụng)
  - Có thể được tham chiếu trong các biểu thức mặc định của các ký hiệu khác
  - Không được ghi vào tệp .config mới
  - Không thể có bất kỳ thuộc tính nào khác (đó là tùy chọn chuyển qua)

Ví dụ di chuyển từ OLD_NAME sang NEW_NAME::

cấu hình NEW_NAME
	bool "Tên tùy chọn mới"
	mặc định OLD_NAME
	giúp đỡ
	  Điều này thay thế tùy chọn CONFIG_OLD_NAME cũ.

cấu hình OLD_NAME
	bool
	chuyển tiếp
	giúp đỡ
	  Cấu hình chuyển tiếp để di chuyển OLD_NAME sang NEW_NAME.

Với thiết lập này, các tệp .config hiện có có "CONFIG_OLD_NAME=y" sẽ
  dẫn đến "CONFIG_NEW_NAME=y" được đặt, trong khi CONFIG_OLD_NAME sẽ được đặt
  bị bỏ qua khỏi các tệp .config mới được viết.

Phụ thuộc thực đơn
------------------

Các phần phụ thuộc xác định khả năng hiển thị của một mục menu và cũng có thể giảm
phạm vi đầu vào của các ký hiệu ba trạng thái. Logic ba trạng thái được sử dụng trong
các biểu thức sử dụng nhiều trạng thái hơn logic boolean thông thường để biểu diễn
trạng thái mô-đun. Biểu thức phụ thuộc có cú pháp sau::

<expr> ::= <biểu tượng> (1)
           <ký hiệu> '=' <ký hiệu> (2)
           <biểu tượng> '!=' <biểu tượng> (3)
           <ký hiệu1> '<' <ký hiệu2> (4)
           <ký hiệu1> '>' <ký hiệu2> (4)
           <ký hiệu1> '<=' <ký hiệu2> (4)
           <ký hiệu1> '>=' <ký hiệu2> (4)
           '(' <expr> ')' (5)
           '!' <expr> (6)
           <expr> '&&' <expr> (7)
           <expr> '||' <expr> (8)

Các biểu thức được liệt kê theo thứ tự ưu tiên giảm dần.

(1) Chuyển ký hiệu thành biểu thức. Ký hiệu Boolean và tristate
    được chuyển đổi đơn giản thành các giá trị biểu thức tương ứng. Tất cả
    các loại ký hiệu khác dẫn đến 'n'.
(2) Nếu giá trị của cả hai ký hiệu bằng nhau, nó trả về 'y',
    nếu không thì 'n'.
(3) Nếu giá trị của cả hai ký hiệu bằng nhau, nó trả về 'n',
    nếu không thì 'y'.
(4) Nếu giá trị của <ký hiệu 1> tương ứng thấp hơn, lớn hơn, thấp hơn hoặc bằng,
    hoặc lớn hơn hoặc bằng giá trị của <ký hiệu2>, nó trả về 'y',
    nếu không thì 'n'.
(5) Trả về giá trị của biểu thức. Được sử dụng để ghi đè quyền ưu tiên.
(6) Trả về kết quả của (2-/expr/).
(7) Trả về kết quả của min(/expr/, /expr/).
(8) Trả về kết quả của max(/expr/, /expr/).

Một biểu thức có thể có giá trị 'n', 'm' hoặc 'y' (hoặc 0, 1, 2
tương ứng để tính toán). Một mục menu sẽ hiển thị khi nó
biểu thức ước tính là 'm' hoặc 'y'.

Có hai loại ký hiệu: ký hiệu cố định và ký hiệu không cố định.
Các ký hiệu không cố định là những ký hiệu phổ biến nhất và được xác định bằng
câu lệnh 'cấu hình'. Các ký hiệu không cố định bao gồm toàn bộ chữ và số
ký tự hoặc dấu gạch dưới.
Các ký hiệu không đổi chỉ là một phần của biểu thức. Ký hiệu hằng số là
luôn được bao quanh bởi dấu ngoặc đơn hoặc dấu ngoặc kép. Trong trích dẫn, bất kỳ
ký tự khác được cho phép và dấu ngoặc kép có thể được thoát bằng cách sử dụng '\'.

Cấu trúc thực đơn
-----------------

Vị trí của một mục menu trong cây được xác định theo hai cách. đầu tiên
nó có thể được chỉ định rõ ràng ::

menu "Hỗ trợ thiết bị mạng"
	phụ thuộc vào NET

cấu hình NETDEVICES
	...

  endmenu

Tất cả các mục trong khối "menu" ... "endmenu" trở thành menu con của
"Hỗ trợ thiết bị mạng". Tất cả các mục con kế thừa các phụ thuộc từ
mục menu, ví dụ: điều này có nghĩa là phần phụ thuộc "NET" được thêm vào
danh sách phụ thuộc của tùy chọn cấu hình NETDEVICES.

Cách khác để tạo cấu trúc menu được thực hiện bằng cách phân tích
sự phụ thuộc. Nếu một mục menu bằng cách nào đó phụ thuộc vào mục trước đó, thì nó
có thể được thực hiện một menu con của nó. Đầu tiên, ký hiệu (mẹ) trước đó phải
là một phần của danh sách phụ thuộc và sau đó là một trong hai điều kiện sau
phải đúng:

- mục nhập con phải ẩn đi nếu mục nhập gốc được đặt thành 'n'
- mục con chỉ được hiển thị nếu mục cha mẹ được hiển thị::

cấu hình MODULES
	bool "Bật hỗ trợ mô-đun có thể tải"

cấu hình MODVERSIONS
	bool "Đặt thông tin phiên bản trên tất cả các ký hiệu mô-đun"
	phụ thuộc vào MODULES

bình luận "hỗ trợ mô-đun bị vô hiệu hóa"
	phụ thuộc vào !MODULES

MODVERSIONS trực tiếp phụ thuộc vào MODULES, điều này có nghĩa là nó chỉ hiển thị nếu
MODULES khác với 'n'. Mặt khác, nhận xét này chỉ
hiển thị khi MODULES được đặt thành 'n'.


Cú pháp Kconfig
---------------

Tệp cấu hình mô tả một loạt các mục menu, trong đó mỗi mục
dòng bắt đầu bằng một từ khóa (ngoại trừ văn bản trợ giúp). Các từ khóa sau
kết thúc một mục menu:

- cấu hình
- cấu hình menu
- sự lựa chọn/sự lựa chọn cuối cùng
- bình luận
- thực đơn/thực đơn cuối cùng
- nếu/endif
- nguồn

Năm điều đầu tiên cũng bắt đầu định nghĩa về một mục menu.

cấu hình::

"cấu hình" <ký hiệu>
	<tùy chọn cấu hình>

Điều này xác định biểu tượng cấu hình <symbol> và chấp nhận bất kỳ điều nào ở trên
thuộc tính dưới dạng tùy chọn.

cấu hình menu::

"menuconfig" <ký hiệu>
	<tùy chọn cấu hình>

Điều này tương tự như mục cấu hình đơn giản ở trên, nhưng nó cũng cung cấp một
gợi ý cho giao diện người dùng rằng tất cả các tùy chọn phụ sẽ được hiển thị dưới dạng
danh sách tùy chọn riêng biệt. Để đảm bảo tất cả các tùy chọn phụ sẽ thực sự
hiển thị dưới mục menuconfig chứ không phải bên ngoài nó, mọi mục
từ danh sách <config options> phải phụ thuộc vào biểu tượng menuconfig.
Trong thực tế, điều này đạt được bằng cách sử dụng một trong hai cấu trúc tiếp theo::

(1):
  menuconfig M
  nếu M
      cấu hình C1
      cấu hình C2
  cuối cùng

(2):
  menuconfig M
  cấu hình C1
      phụ thuộc vào M
  cấu hình C2
      phụ thuộc vào M

Trong ví dụ sau (3) và (4), C1 và C2 vẫn có M
phụ thuộc, nhưng sẽ không xuất hiện dưới menuconfig M nữa, bởi vì
của C0, không phụ thuộc vào M::

(3):
  menuconfig M
      cấu hình C0
  nếu M
      cấu hình C1
      cấu hình C2
  cuối cùng

(4):
  menuconfig M
  cấu hình C0
  cấu hình C1
      phụ thuộc vào M
  cấu hình C2
      phụ thuộc vào M

sự lựa chọn::

"sự lựa chọn"
	<các phương án lựa chọn>
	<khối lựa chọn>
	"sự lựa chọn cuối cùng"

Điều này xác định một nhóm lựa chọn và chấp nhận "nhắc nhở", "mặc định", "phụ thuộc vào" và
thuộc tính "trợ giúp" làm tùy chọn.

Một lựa chọn chỉ cho phép chọn một mục cấu hình duy nhất.

bình luận::

"bình luận" <nhắc>
	<tùy chọn bình luận>

Điều này xác định một nhận xét được hiển thị cho người dùng trong quá trình
quá trình cấu hình và cũng được lặp lại đến các tập tin đầu ra. duy nhất
các tùy chọn có thể là phụ thuộc.

thực đơn::

"thực đơn" <nhắc>
	<tùy chọn menu>
	<khối menu>
	"menu cuối"

Điều này xác định một khối menu, xem "Cấu trúc menu" ở trên để biết thêm
thông tin. Các lựa chọn khả thi duy nhất là phụ thuộc và "hiển thị"
thuộc tính.

nếu như::

"nếu" <expr>
	<nếu chặn>
	"endif"

Điều này xác định một khối if. Biểu thức phụ thuộc <expr> được thêm vào
cho tất cả các mục menu kèm theo.

nguồn::

"nguồn" <nhắc>

Điều này đọc tập tin cấu hình được chỉ định. Tệp này luôn được phân tích cú pháp.

menu chính::

"menu chính" <nhắc>

Điều này đặt thanh tiêu đề của chương trình cấu hình nếu chương trình cấu hình chọn
để sử dụng nó. Nó phải được đặt ở trên cùng của cấu hình, trước bất kỳ
tuyên bố khác.

'#' Nhận xét tệp nguồn Kconfig:

Ký tự '#' không được trích dẫn ở bất kỳ đâu trong dòng tệp nguồn cho biết
sự bắt đầu của một bình luận tập tin nguồn.  Phần còn lại của dòng đó
là một bình luận.


Gợi ý Kconfig
-------------
Đây là tập hợp các mẹo Kconfig, hầu hết trong số đó không rõ ràng ở
cái nhìn đầu tiên và hầu hết trong số đó đã trở thành thành ngữ trong một số Kconfig
tập tin.

Thêm các tính năng phổ biến và làm cho việc sử dụng có thể cấu hình được
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đó là một thành ngữ phổ biến để triển khai một tính năng/chức năng
phù hợp với một số kiến trúc nhưng không phải tất cả.
Cách được khuyến nghị để làm như vậy là sử dụng biến cấu hình có tên HAVE_*
được xác định trong một tệp Kconfig chung và được chọn bởi người có liên quan
kiến trúc.
Một ví dụ là chức năng IOMAP chung.

Chúng ta sẽ thấy trong lib/Kconfig::

# Generic IOMAP được sử dụng để ...
  cấu hình HAVE_GENERIC_IOMAP

cấu hình GENERIC_IOMAP
	phụ thuộc vào HAVE_GENERIC_IOMAP && FOO

Và trong lib/Makefile chúng ta sẽ thấy::

obj-$(CONFIG_GENERIC_IOMAP) += iomap.o

Đối với mỗi kiến ​​trúc sử dụng chức năng IOMAP chung, chúng ta sẽ thấy::

cấu hình X86
	chọn ...
	chọn HAVE_GENERIC_IOMAP
	chọn ...

Lưu ý: chúng tôi sử dụng tùy chọn cấu hình hiện có và tránh tạo tùy chọn cấu hình mới
biến cấu hình để chọn HAVE_GENERIC_IOMAP.

Lưu ý: việc sử dụng biến cấu hình bên trong HAVE_GENERIC_IOMAP, đó là
được giới thiệu để khắc phục hạn chế của lựa chọn sẽ buộc
tùy chọn cấu hình thành 'y' bất kể sự phụ thuộc.
Các phần phụ thuộc được chuyển sang ký hiệu GENERIC_IOMAP và chúng tôi tránh
tình huống trong đó việc chọn buộc một ký hiệu bằng 'y'.

Thêm các tính năng cần hỗ trợ trình biên dịch
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có một số tính năng cần hỗ trợ trình biên dịch. Cách được đề xuất
để mô tả sự phụ thuộc vào tính năng của trình biên dịch là sử dụng "phụ thuộc vào"
theo sau là macro thử nghiệm::

cấu hình STACKPROTECTOR
	bool "Phát hiện tràn bộ đệm Stack Protector"
	phụ thuộc vào $(cc-option,-fstack-protector)
	...

Nếu bạn cần thể hiện khả năng của trình biên dịch đối với các tệp makefiles và/hoặc tệp nguồn C,
ZZ0000ZZ là tiền tố được đề xuất cho tùy chọn cấu hình::

cấu hình CC_HAS_FOO
	def_bool $(success,$(srctree)/scripts/cc-check-foo.sh $(CC))

Chỉ xây dựng dưới dạng mô-đun
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Để hạn chế việc xây dựng thành phần chỉ ở mô-đun, hãy xác định biểu tượng cấu hình của nó
với "phụ thuộc vào m".  Ví dụ.::

cấu hình FOO
	phụ thuộc vào BAR && m

giới hạn FOO ở mô-đun (=m) hoặc bị vô hiệu hóa (=n).

Kiểm tra biên dịch
~~~~~~~~~~~~~~~~~~
Nếu biểu tượng cấu hình có phần phụ thuộc, nhưng mã được cấu hình kiểm soát
biểu tượng vẫn có thể được biên dịch nếu sự phụ thuộc không được đáp ứng, nó được khuyến khích
tăng phạm vi xây dựng bằng cách thêm mệnh đề "|| COMPILE_TEST" vào
sự phụ thuộc. Điều này đặc biệt hữu ích cho các trình điều khiển cho phần cứng kỳ lạ hơn, như
nó cho phép các hệ thống tích hợp liên tục biên dịch-kiểm tra mã trên cơ sở nhiều hơn
hệ thống chung và phát hiện lỗi theo cách đó.
Lưu ý rằng mã đã được biên dịch kiểm tra sẽ tránh bị lỗi khi chạy trên hệ thống có
sự phụ thuộc không được đáp ứng.

Sự phụ thuộc vào kiến ​​trúc và nền tảng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Do sự hiện diện của các trình điều khiển sơ khai, hầu hết các trình điều khiển hiện nay có thể được biên dịch trên hầu hết các trình điều khiển.
kiến trúc. Tuy nhiên, điều này không có nghĩa là có tất cả các trình điều khiển
có sẵn ở mọi nơi, vì phần cứng thực tế chỉ có thể tồn tại trên một số thiết bị cụ thể
kiến trúc và nền tảng. Điều này đặc biệt đúng đối với lõi IP trên SoC,
có thể bị giới hạn ở một nhà cung cấp cụ thể hoặc dòng SoC.

Để tránh hỏi người dùng về các trình điều khiển không thể sử dụng trên (các) hệ thống
người dùng đang biên dịch hạt nhân và nếu điều đó hợp lý, hãy biểu tượng cấu hình
kiểm soát việc biên dịch trình điều khiển phải chứa các phần phụ thuộc thích hợp,
giới hạn khả năng hiển thị của biểu tượng đối với (bộ siêu của) (các) nền tảng
trình điều khiển có thể được sử dụng trên. Phần phụ thuộc có thể là một kiến trúc (ví dụ ARM) hoặc
phụ thuộc vào nền tảng (ví dụ: ARCH_OMAP4). Điều này làm cho cuộc sống đơn giản hơn không chỉ đối với
chủ sở hữu cấu hình distro mà còn cho mọi nhà phát triển hoặc người dùng
cấu hình một kernel.

Sự phụ thuộc như vậy có thể được giảm bớt bằng cách kết hợp nó với quy tắc kiểm tra biên dịch
trên, dẫn đến:

cấu hình FOO
	bool "Hỗ trợ phần cứng foo"
	phụ thuộc vào ARCH_FOO_VENDOR || COMPILE_TEST

Phụ thuộc tùy chọn
~~~~~~~~~~~~~~~~~~~~~

Một số trình điều khiển có thể tùy ý sử dụng một tính năng từ mô-đun khác
hoặc xây dựng sạch sẽ với mô-đun đó bị tắt nhưng gây ra lỗi liên kết
khi cố gắng sử dụng mô-đun có thể tải đó từ trình điều khiển tích hợp.

Cách được đề xuất để thể hiện sự phụ thuộc tùy chọn này trong logic Kconfig
sử dụng dạng điều kiện::

cấu hình FOO
	tristate "Hỗ trợ phần cứng foo"
	phụ thuộc vào BAR nếu BAR

Phong cách hơi phản trực giác này cũng được sử dụng rộng rãi ::

cấu hình FOO
	tristate "Hỗ trợ phần cứng foo"
	phụ thuộc vào BAR || !BAR

Điều này có nghĩa là có sự phụ thuộc vào BAR không cho phép
sự kết hợp của FOO=y với BAR=m hoặc BAR bị vô hiệu hóa hoàn toàn. BAR
mô-đun phải cung cấp tất cả các phần sơ khai cho trường hợp !BAR.

Để có cách tiếp cận chính thức hơn nếu có nhiều trình điều khiển có
cùng một sự phụ thuộc, biểu tượng trợ giúp có thể được sử dụng, như::

cấu hình FOO
	tristate "Hỗ trợ phần cứng foo"
	phụ thuộc vào BAR_OPTIONAL

cấu hình BAR_OPTIONAL
	def_tristate BAR || !BAR

Cách ít thuận lợi hơn để thể hiện sự phụ thuộc tùy chọn là IS_REACHABLE() bên trong
mã mô-đun, ví dụ hữu ích khi mô-đun BAR không cung cấp
!BAR sơ khai::

foo_init()
	{
		nếu (IS_REACHABLE(CONFIG_BAR))
			bar_register(&foo);
		...
	}

IS_REACHABLE() thường không được khuyến khích vì mã sẽ ở chế độ im lặng
bị loại bỏ khi CONFIG_BAR=m và mã này được tích hợp sẵn. Đây không phải là điều người dùng
thường mong đợi khi kích hoạt BAR làm mô-đun.

Giới hạn phụ thuộc đệ quy Kconfig
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn gặp lỗi Kconfig: "đã phát hiện sự phụ thuộc đệ quy" thì bạn đã chạy
vào vấn đề phụ thuộc đệ quy với Kconfig, một phụ thuộc đệ quy có thể
được tóm tắt dưới dạng phụ thuộc vòng tròn. Các công cụ kconfig cần đảm bảo rằng
Các tệp Kconfig tuân thủ các yêu cầu cấu hình được chỉ định. để làm
kconfig đó phải xác định các giá trị có thể có cho tất cả Kconfig
ký hiệu, điều này hiện không thể thực hiện được nếu có mối quan hệ vòng tròn
giữa hai hoặc nhiều ký hiệu Kconfig. Để biết thêm chi tiết, hãy tham khảo phần "Đơn giản
Vấn đề đệ quy Kconfig" bên dưới. Kconfig không đệ quy
độ phân giải phụ thuộc; điều này có một số ý nghĩa đối với người viết tệp Kconfig.
Trước tiên, chúng tôi sẽ giải thích lý do tại sao vấn đề này tồn tại và sau đó đưa ra một ví dụ
giới hạn kỹ thuật mà điều này mang lại cho các nhà phát triển Kconfig. Háo hức
các nhà phát triển muốn cố gắng giải quyết hạn chế này nên đọc phần tiếp theo
tiểu mục.

Sự cố đệ quy Kconfig đơn giản
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đọc: Tài liệu/kbuild/Kconfig.recursion-issue-01

Kiểm tra với::

tạo KBUILD_KCONFIG=Documentation/kbuild/Kconfig.recursion-issue-01 allnoconfig

Sự cố đệ quy Kconfig tích lũy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đọc: Tài liệu/kbuild/Kconfig.recursion-issue-02

Kiểm tra với::

tạo KBUILD_KCONFIG=Documentation/kbuild/Kconfig.recursion-issue-02 allnoconfig

Các giải pháp thiết thực cho vấn đề đệ quy kconfig
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các nhà phát triển gặp phải sự cố Kconfig đệ quy có hai lựa chọn
theo ý của họ. Chúng tôi ghi lại chúng dưới đây và cũng cung cấp danh sách
các vấn đề lịch sử được giải quyết thông qua các giải pháp khác nhau này.

a) Loại bỏ mọi thông tin "chọn FOO" hoặc "phụ thuộc vào FOO" không cần thiết
  b) So khớp ngữ nghĩa phụ thuộc:

b1) Hoán đổi tất cả "select FOO" thành "phụ thuộc vào FOO" hoặc,

b2) Hoán đổi tất cả "phụ thuộc vào FOO" thành "chọn FOO"

Độ phân giải của a) có thể được kiểm tra bằng tệp Kconfig mẫu
Documentation/kbuild/Kconfig.recursion-issue-01 thông qua việc loại bỏ
của "chọn CORE" từ CORE_BELL_A_ADVANCED vì điều đó đã ẩn rồi
vì CORE_BELL_A phụ thuộc vào CORE. Đôi khi không thể loại bỏ được
một số tiêu chí phụ thuộc, trong những trường hợp như vậy bạn có thể làm việc với giải pháp b).

Hai độ phân giải khác nhau cho b) có thể được kiểm tra trong tệp Kconfig mẫu
Tài liệu/kbuild/Kconfig.recursion-issue-02.

Dưới đây là danh sách ví dụ về các bản sửa lỗi trước đây cho các loại sự cố đệ quy này;
tất cả các lỗi dường như liên quan đến một hoặc nhiều câu lệnh "chọn" và một hoặc nhiều
"phụ thuộc vào".

===================================================
cam kết sửa lỗi
===================================================
06b718c01208 chọn A -> phụ thuộc vào A
c22eacfe82f9 phụ thuộc vào A -> phụ thuộc vào B
6a91e854442c chọn A -> phụ thuộc vào A
118c565a8f2e chọn A -> chọn B
f004e5594705 chọn A -> phụ thuộc vào A
c7861f37b4c6 phụ thuộc vào A -> (null)
80c69915e5fb chọn A -> (null) (1)
c2218e26c0d0 chọn A -> phụ thuộc vào A (1)
d6ae99d04e1c chọn A -> phụ thuộc vào A
95ca19cf8cbf chọn A -> phụ thuộc vào A
8f057d7bca54 phụ thuộc vào A -> (null)
8f057d7bca54 phụ thuộc vào A -> chọn A
a0701f04846e chọn A -> phụ thuộc vào A
0c8b92f7f259 phụ thuộc vào A -> (null)
e4e9e0540928 chọn A -> phụ thuộc vào A (2)
7453ea886e87 phụ thuộc vào A > (null) (1)
7b1fff7e4fdf chọn A -> phụ thuộc vào A
86c747d2a4f0 chọn A -> phụ thuộc vào A
d9f9ab51e55e chọn A -> phụ thuộc vào A
0c51a4d8abd6 phụ thuộc vào A -> chọn A (3)
e98062ed6dc4 chọn A -> phụ thuộc vào A (3)
91e5d284a7f1 chọn A -> (null)
===================================================

(1) Trích dẫn một phần (hoặc không) lỗi.
(2) Đó dường như là ý chính của cách khắc phục đó.
(3) Lỗi tương tự.

Công việc kconfig trong tương lai
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Công việc trên kconfig được hoan nghênh trên cả hai lĩnh vực làm rõ ngữ nghĩa và
đánh giá việc sử dụng bộ giải SAT đầy đủ cho nó. Một bộ giải SAT đầy đủ có thể
mong muốn kích hoạt các ánh xạ và/hoặc truy vấn phụ thuộc phức tạp hơn,
ví dụ, một trường hợp sử dụng có thể có cho bộ giải SAT có thể là trường hợp xử lý
các vấn đề phụ thuộc đệ quy đã biết hiện nay. Người ta không biết liệu điều này có
giải quyết các vấn đề như vậy nhưng đánh giá như vậy là mong muốn. Nếu hỗ trợ đầy đủ SAT
bộ giải tỏ ra quá phức tạp hoặc nó không thể giải quyết các vấn đề phụ thuộc đệ quy
Kconfig ít nhất phải có ngữ nghĩa rõ ràng và được xác định rõ ràng.
địa chỉ và các hạn chế hoặc yêu cầu về tài liệu, chẳng hạn như những yêu cầu liên quan đến
với sự phụ thuộc đệ quy.

Công việc tiếp theo trên cả hai lĩnh vực này đều được hoan nghênh trên Kconfig. Chúng tôi xây dựng
về cả hai điều này trong hai tiểu mục tiếp theo.

Ngữ nghĩa của Kconfig
~~~~~~~~~~~~~~~~~~~~~

Việc sử dụng Kconfig rất rộng, Linux hiện chỉ là một trong những người dùng của Kconfig:
một nghiên cứu đã hoàn thành phân tích rộng rãi về việc sử dụng Kconfig trong 12 dự án [0]_.
Mặc dù được sử dụng rộng rãi và mặc dù tài liệu này thực hiện công việc hợp lý
trong việc ghi lại cú pháp Kconfig cơ bản, định nghĩa chính xác hơn về Kconfig
ngữ nghĩa được hoan nghênh. Một dự án đã suy luận ngữ nghĩa Kconfig thông qua
việc sử dụng bộ cấu hình xconfig [1]_. Công việc nên được thực hiện để xác nhận nếu
ngữ nghĩa được suy luận phù hợp với mục tiêu thiết kế Kconfig dự định của chúng tôi.
Một dự án khác đã chính thức hóa ngữ nghĩa biểu thị của một tập hợp con cốt lõi của
ngôn ngữ Kconfig [10]_.

Việc xác định rõ ngữ nghĩa có thể hữu ích cho các công cụ thực hành
đánh giá sự phụ thuộc, ví dụ một trường hợp như vậy là làm việc để
thể hiện dưới dạng trừu tượng boolean của ngữ nghĩa được suy ra của Kconfig thành
dịch logic Kconfig thành các công thức boolean và chạy bộ giải SAT trên này để
tìm thấy mã/tính năng chết (luôn không hoạt động), tìm thấy 114 tính năng chết trong
Linux sử dụng phương pháp này [1]_ (Phần 8: Các mối đe dọa đối với tính hợp lệ).
Công cụ kimet, dựa trên ngữ nghĩa trong [10]_, tìm ra sự lạm dụng đảo ngược
phụ thuộc và đã dẫn đến hàng tá bản sửa lỗi được cam kết cho các tệp Linux Kconfig [11]_.

Việc xác nhận điều này có thể hữu ích vì Kconfig là một trong những công ty hàng đầu
ngôn ngữ lập mô hình biến đổi công nghiệp [1]_ [2]_. Nghiên cứu của nó sẽ giúp
đánh giá việc sử dụng thực tế của các ngôn ngữ đó, việc sử dụng chúng chỉ mang tính lý thuyết
và các yêu cầu của thế giới thực không được hiểu rõ. Mặc dù vậy
chỉ có các kỹ thuật đảo ngược được sử dụng để suy ra ngữ nghĩa từ
ngôn ngữ lập mô hình biến thiên như Kconfig [3]_.

.. [0] https://www.eng.uwaterloo.ca/~shshe/kconfig_semantics.pdf
.. [1] https://gsd.uwaterloo.ca/sites/default/files/vm-2013-berger.pdf
.. [2] https://gsd.uwaterloo.ca/sites/default/files/ase241-berger_0.pdf
.. [3] https://gsd.uwaterloo.ca/sites/default/files/icse2011.pdf

Bộ giải SAT đầy đủ cho Kconfig
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mặc dù bộ giải SAT [4]_ vẫn chưa được Kconfig sử dụng trực tiếp, như đã lưu ý
Tuy nhiên, trong tiểu mục trước, công việc đã được thực hiện để thể hiện bằng boolean
trừu tượng hóa ngữ nghĩa được suy ra của Kconfig để dịch logic Kconfig sang
công thức boolean và chạy bộ giải SAT trên đó [5]_. Một dự án liên quan khác được biết đến
là CADOS [6]_ (trước đây là VAMOS [7]_) và các công cụ, chủ yếu là người đảm nhận [8]_, mà
đã được giới thiệu đầu tiên với [9]_.  Khái niệm cơ bản của người đảm nhận là
trích xuất các mô hình biến thiên từ Kconfig và ghép chúng lại với nhau bằng một
công thức mệnh đề được trích xuất từ CPP #ifdefs và xây dựng các quy tắc thành SAT
bộ giải để tìm mã chết, tập tin chết và biểu tượng chết. Nếu sử dụng SAT
bộ giải được mong muốn trên Kconfig, một cách tiếp cận sẽ là đánh giá việc tái sử dụng
những nỗ lực như vậy bằng cách nào đó trên Kconfig. Có đủ sự quan tâm từ các cố vấn của
các dự án hiện tại không chỉ giúp tư vấn cách tích hợp công việc này ngược dòng
mà còn giúp duy trì nó lâu dài. Các nhà phát triển quan tâm nên truy cập:

ZZ0000ZZ

.. [4] https://www.cs.cornell.edu/~sabhar/chapters/SATSolvers-KR-Handbook.pdf
.. [5] https://gsd.uwaterloo.ca/sites/default/files/vm-2013-berger.pdf
.. [6] https://cados.cs.fau.de
.. [7] https://vamos.cs.fau.de
.. [8] https://undertaker.cs.fau.de
.. [9] https://www4.cs.fau.de/Publications/2011/tartler_11_eurosys.pdf
.. [10] https://paulgazzillo.com/papers/esecfse21.pdf
.. [11] https://github.com/paulgazz/kmax
