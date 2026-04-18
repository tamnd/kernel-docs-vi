.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/coding-style.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _codingstyle:

Phong cách mã hóa hạt nhân Linux
=========================

Đây là một tài liệu ngắn mô tả phong cách mã hóa ưa thích cho
hạt nhân linux.  Phong cách viết mã rất cá nhân và tôi sẽ không sử dụng ZZ0000ZZ
quan điểm về bất cứ ai, nhưng đây là điều phù hợp với bất cứ điều gì tôi phải trở thành
có thể duy trì và tôi cũng thích nó cho hầu hết những thứ khác.  làm ơn
ít nhất hãy xem xét các điểm được thực hiện ở đây.

Trước hết, tôi khuyên bạn nên in ra một bản sao của tiêu chuẩn mã hóa GNU,
và NOT đã đọc nó.  Đốt chúng đi, đó là một cử chỉ mang tính biểu tượng tuyệt vời.

Dù sao, đây là:


1) Thụt lề
--------------

Tab có 8 ký tự và do đó thụt lề cũng có 8 ký tự.
Có những phong trào dị giáo cố gắng tạo ra các vết lõm 4 (hoặc thậm chí 2!)
ký tự sâu và điều đó giống như cố gắng xác định giá trị của PI để
được 3.

Cơ sở lý luận: Toàn bộ ý tưởng đằng sau việc thụt đầu dòng là để xác định rõ ràng vị trí
một khối điều khiển bắt đầu và kết thúc.  Đặc biệt là khi bạn đang tìm kiếm
trước màn hình của bạn trong 20 giờ liên tục, bạn sẽ thấy nó dễ nhìn hơn nhiều
cách thụt đầu dòng hoạt động như thế nào nếu bạn có vết lõm lớn.

Bây giờ, một số người sẽ cho rằng việc thụt lề 8 ký tự sẽ tạo ra
mã di chuyển quá xa về bên phải và khiến nó khó đọc trên
Màn hình thiết bị đầu cuối 80 ký tự.  Câu trả lời cho điều đó là nếu bạn cần
hơn 3 cấp độ thụt, dù sao thì bạn cũng bị hỏng và nên sửa
chương trình của bạn.

Nói tóm lại, thụt lề 8 ký tự giúp mọi thứ dễ đọc hơn và có thêm
lợi ích của việc cảnh báo bạn khi bạn lồng các hàm của mình quá sâu.
Hãy chú ý đến cảnh báo đó.

Cách ưa thích để giảm bớt nhiều mức thụt lề trong câu lệnh switch là
để căn chỉnh ZZ0000ZZ và các nhãn ZZ0001ZZ cấp dưới của nó trong cùng một cột
thay vì ZZ0002ZZ bằng nhãn ZZ0003ZZ.  Ví dụ.:

.. code-block:: c

	switch (suffix) {
	case 'G':
	case 'g':
		mem <<= 30;
		break;
	case 'M':
	case 'm':
		mem <<= 20;
		break;
	case 'K':
	case 'k':
		mem <<= 10;
		fallthrough;
	default:
		break;
	}

Đừng viết nhiều câu lệnh trên một dòng trừ khi bạn có
một cái gì đó để che giấu:

.. code-block:: c

	if (condition) do_this;
	  do_something_everytime;

Không sử dụng dấu phẩy để tránh sử dụng dấu ngoặc nhọn:

.. code-block:: c

	if (condition)
		do_this(), do_that();

Luôn sử dụng dấu ngoặc nhọn cho nhiều câu lệnh:

.. code-block:: c

	if (condition) {
		do_this();
		do_that();
	}

Đừng đặt nhiều bài tập trên một dòng.  Kiểu mã hóa hạt nhân
là siêu đơn giản.  Tránh những cách diễn đạt phức tạp.


Ngoài các nhận xét, tài liệu và ngoại trừ trong Kconfig, không bao giờ có khoảng trắng
được sử dụng để thụt lề và ví dụ trên bị cố tình phá vỡ.

Hãy tìm một trình soạn thảo phù hợp và đừng để khoảng trắng ở cuối dòng.


2) Phá vỡ các dòng và dây dài
----------------------------------

Phong cách mã hóa tập trung vào khả năng đọc và bảo trì bằng cách sử dụng phổ biến
các công cụ có sẵn.

Giới hạn ưu tiên về độ dài của một dòng là 80 cột.

Các câu lệnh dài hơn 80 cột phải được chia thành các phần hợp lý,
trừ khi vượt quá 80 cột làm tăng đáng kể khả năng đọc và không
không che giấu thông tin.

Con cháu luôn ngắn hơn đáng kể so với cha mẹ và
về cơ bản được đặt ở bên phải.  Một phong cách được sử dụng rất phổ biến
là sắp xếp các hậu duệ theo một dấu ngoặc đơn mở của hàm.

Những quy tắc tương tự này được áp dụng cho các tiêu đề hàm có danh sách đối số dài.

Tuy nhiên, đừng bao giờ ngắt các chuỗi mà người dùng nhìn thấy chẳng hạn như thông báo printk vì
điều đó phá vỡ khả năng grep cho họ.


3) Đặt niềng răng và khoảng cách
----------------------------

Vấn đề khác luôn xuất hiện trong kiểu dáng C là vị trí của
niềng răng.  Không giống như kích thước thụt lề, có rất ít lý do kỹ thuật để
chọn chiến lược vị trí này thay vì chiến lược vị trí khác, nhưng theo cách ưa thích hơn, như
được các nhà tiên tri Kernighan và Ritchie chỉ cho chúng ta thấy, là để mở đầu
dấu ngoặc nhọn cuối cùng trên dòng và đặt dấu ngoặc nhọn đóng trước, do đó:

.. code-block:: c

	if (x is true) {
		we do y
	}

Điều này áp dụng cho tất cả các khối câu lệnh phi chức năng (if, switch, for,
trong khi, làm).  Ví dụ.:

.. code-block:: c

	switch (action) {
	case KOBJ_ADD:
		return "add";
	case KOBJ_REMOVE:
		return "remove";
	case KOBJ_CHANGE:
		return "change";
	default:
		return NULL;
	}

Tuy nhiên, có một trường hợp đặc biệt, đó là các hàm: chúng có
dấu ngoặc mở ở đầu dòng tiếp theo, do đó:

.. code-block:: c

	int function(int x)
	{
		body of function
	}

Những kẻ dị giáo trên khắp thế giới đã tuyên bố rằng sự mâu thuẫn này
là ... à ... không nhất quán, nhưng tất cả những người có suy nghĩ đúng đắn đều biết rằng
(a) K&R là ZZ0000ZZ và (b) K&R đúng.  Bên cạnh đó, các chức năng
dù sao cũng đặc biệt (bạn không thể lồng chúng vào C).

Lưu ý rằng dấu ngoặc nhọn đóng trống trên một dòng riêng, ZZ0002ZZ trong
các trường hợp theo sau nó là sự tiếp nối của cùng một tuyên bố,
tức là ZZ0000ZZ trong câu lệnh do hoặc ZZ0001ZZ trong câu lệnh if, như
cái này:

.. code-block:: c

	do {
		body of do-loop
	} while (condition);

Và

.. code-block:: c

	if (x == y) {
		..
	} else if (x > y) {
		...
	} else {
		....
	}

Cơ sở lý luận: K&R.

Ngoài ra, hãy lưu ý rằng vị trí đặt dấu ngoặc nhọn này cũng giảm thiểu số lượng khoảng trống
(hoặc gần như trống) dòng mà không làm mất khả năng đọc.  Như vậy, với tư cách là
việc cung cấp dòng mới trên màn hình của bạn không phải là nguồn tài nguyên có thể tái tạo (nghĩ
Màn hình terminal 25 dòng ở đây), bạn có nhiều dòng trống hơn để đặt
nhận xét về.

Không sử dụng dấu ngoặc nhọn một cách không cần thiết khi chỉ có một câu lệnh duy nhất.

.. code-block:: c

	if (condition)
		action();

Và

.. code-block:: c

	if (condition)
		do_this();
	else
		do_that();

Điều này không áp dụng nếu chỉ có một nhánh của câu lệnh điều kiện là đơn
tuyên bố; trong trường hợp sau sử dụng dấu ngoặc nhọn ở cả hai nhánh:

.. code-block:: c

	if (condition) {
		do_this();
		do_that();
	} else {
		otherwise();
	}

Ngoài ra, hãy sử dụng dấu ngoặc nhọn khi một vòng lặp chứa nhiều hơn một câu lệnh đơn giản:

.. code-block:: c

	while (condition) {
		if (test)
			do_something();
	}

3.1) Không gian
***********

Kiểu nhân Linux để sử dụng khoảng trắng phụ thuộc (chủ yếu) vào
cách sử dụng chức năng so với từ khóa.  Sử dụng khoảng trắng sau (hầu hết) từ khóa.  các
các trường hợp ngoại lệ đáng chú ý là sizeof, typeof, Alignof và __attribute__, trông giống như
hơi giống các hàm (và thường được sử dụng với dấu ngoặc đơn trong Linux,
mặc dù chúng không bắt buộc trong ngôn ngữ, như trong: ZZ0000ZZ sau
ZZ0001ZZ được khai báo).

Vì vậy, hãy sử dụng khoảng trắng sau những từ khóa này::

nếu, chuyển đổi, trường hợp, cho, làm, trong khi

nhưng không phải với sizeof, typeof, Alignof hoặc __attribute__.  Ví dụ.,

.. code-block:: c


	s = sizeof(struct file);

Không thêm dấu cách xung quanh (bên trong) các biểu thức được ngoặc đơn.  Ví dụ này là
ZZ0000ZZ:

.. code-block:: c


	s = sizeof( struct file );

Khi khai báo dữ liệu con trỏ hoặc một hàm trả về một kiểu con trỏ,
việc sử dụng ZZ0000ZZ ưa thích nằm liền kề với tên dữ liệu hoặc tên chức năng chứ không phải
liền kề với tên loại.  Ví dụ:

.. code-block:: c


	char *linux_banner;
	unsigned long long memparse(char *ptr, char **retptr);
	char *match_strdup(substring_t *s);

Sử dụng một khoảng trắng xung quanh (ở mỗi bên) hầu hết các toán tử nhị phân và bậc ba,
chẳng hạn như bất kỳ trong số này::

= + - < > * / % |  & ^ <= >= == != ?  :

nhưng không có khoảng trắng sau các toán tử đơn nguyên::

& * + - ~ !  sizeof typeof căn chỉnh __attribute__ được xác định

không có khoảng trống trước các toán tử đơn nguyên tăng & giảm hậu tố::

++ --

không có khoảng trắng sau các toán tử đơn nguyên tăng & giảm tiền tố::

++ --

và không có khoảng trống xung quanh các toán tử thành viên cấu trúc ZZ0000ZZ và ZZ0001ZZ.

Không để lại khoảng trắng ở cuối dòng.  Một số biên tập viên với
Việc thụt lề ZZ0000ZZ sẽ chèn khoảng trắng vào đầu dòng mới như
thích hợp để bạn có thể bắt đầu nhập dòng mã tiếp theo ngay lập tức.
Tuy nhiên, một số trình soạn thảo như vậy không xóa khoảng trắng nếu bạn không muốn
đặt một dòng mã ở đó, chẳng hạn như nếu bạn để một dòng trống.  Kết quả là,
bạn kết thúc với các dòng chứa khoảng trắng ở cuối.

Git sẽ cảnh báo bạn về các bản vá có khoảng trắng ở cuối và có thể
tùy ý loại bỏ khoảng trắng ở cuối cho bạn; tuy nhiên, nếu áp dụng một loạt
của các bản vá, điều này có thể làm cho các bản vá sau này trong chuỗi bị lỗi do thay đổi chúng
dòng ngữ cảnh.


4) Đặt tên
---------

C là ngôn ngữ Spartan và quy ước đặt tên của bạn phải tuân theo.
Không giống như lập trình viên Modula-2 và Pascal, lập trình viên C không sử dụng dễ thương
những cái tên như ThisVariableIsATemporaryCounter. Một lập trình viên C sẽ gọi đó là
biến ZZ0000ZZ, dễ viết hơn nhiều và không kém phần quan trọng
khó hiểu.

HOWEVER, trong khi các tên viết hoa hỗn hợp không được tán thành, các tên mô tả cho
các biến toàn cục là phải.  Để gọi một hàm toàn cục ZZ0000ZZ là một
hành vi bắn súng.

Các biến GLOBAL (chỉ được sử dụng nếu ZZ0002ZZ của bạn cần chúng) cần phải
có tên mô tả, cũng như các hàm toàn cục.  Nếu bạn có một chức năng
đếm số lượng người dùng đang hoạt động, bạn nên gọi đó là
ZZ0000ZZ hoặc tương tự, bạn nên gọi ZZ0003ZZ là ZZ0001ZZ.

Mã hóa loại hàm thành tên (được gọi là tiếng Hungary
ký hiệu) là asinine - dù sao thì trình biên dịch cũng biết các loại và có thể kiểm tra
những thứ đó và nó chỉ khiến lập trình viên bối rối.

Tên biến LOCAL phải ngắn gọn và súc tích.  Nếu bạn có
một số bộ đếm vòng lặp số nguyên ngẫu nhiên, có lẽ nó nên được gọi là ZZ0000ZZ.
Gọi là ZZ0001ZZ thì không có tác dụng, nếu không có cơ hội
bị hiểu sai.  Tương tự, ZZ0002ZZ có thể là bất kỳ loại
biến dùng để giữ giá trị tạm thời.

Nếu bạn sợ nhầm lẫn các tên biến cục bộ của mình, bạn có một cái khác
vấn đề, được gọi là hội chứng mất cân bằng chức năng-tăng trưởng-hormone.
Xem chương 6 (Chức năng).

Đối với tên biểu tượng và tài liệu, tránh đưa ra cách sử dụng mới của
'master/slave' (hoặc 'slave' độc lập với 'master') và 'blacklist/
danh sách trắng'.

Các lựa chọn thay thế được đề xuất cho 'master/slave' là:
    '{chính,chính} / {phụ,bản sao,cấp dưới}'
    '{người khởi xướng, người yêu cầu} / {mục tiêu, người phản hồi}'
    '{bộ điều khiển,máy chủ} / {thiết bị,nhân viên,proxy}'
    'người dẫn đầu/người theo sau'
    'đạo diễn/người biểu diễn'

Các lựa chọn thay thế được đề xuất cho 'danh sách đen/danh sách trắng' là:
    'danh sách từ chối / danh sách cho phép'
    'danh sách chặn / danh sách vượt qua'

Các ngoại lệ khi giới thiệu cách sử dụng mới là duy trì không gian người dùng ABI/API,
hoặc khi cập nhật mã cho phần cứng hoặc giao thức hiện có (kể từ năm 2020)
đặc điểm kỹ thuật bắt buộc các điều khoản đó. Đối với thông số kỹ thuật mới
dịch cách sử dụng đặc tả của thuật ngữ sang mã hóa kernel
tiêu chuẩn nếu có thể.

5) Kiểu chữ
-----------

Vui lòng không sử dụng những thứ như ZZ0000ZZ.
Đó là ZZ0001ZZ để sử dụng typedef cho cấu trúc và con trỏ. Khi bạn nhìn thấy một

.. code-block:: c


	vps_t a;

trong nguồn, nó có nghĩa là gì?
Ngược lại, nếu nó nói

.. code-block:: c

	struct virtual_container *a;

bạn thực sự có thể biết ZZ0000ZZ là gì.

Rất nhiều người nghĩ rằng typedefs ZZ0000ZZ. Không phải vậy. Họ là
chỉ hữu ích cho:

(a) các đối tượng hoàn toàn mờ đục (trong đó typedef được sử dụng tích cực cho ZZ0000ZZ
     đối tượng là gì).

Ví dụ: ZZ0000ZZ, v.v. các đối tượng mờ đục mà bạn chỉ có thể truy cập bằng cách sử dụng
     các chức năng truy cập thích hợp.

     .. note::

       Opaqueness and ``accessor functions`` are not good in themselves.
       The reason we have them for things like pte_t etc. is that there
       really is absolutely **zero** portably accessible information there.

(b) Xóa các kiểu số nguyên, trong đó sự trừu tượng hóa ZZ0002ZZ tránh nhầm lẫn
     cho dù đó là ZZ0000ZZ hay ZZ0001ZZ.

u8/u16/u32 là những typedef hoàn toàn ổn, mặc dù chúng phù hợp với
     loại (d) tốt hơn ở đây.

     .. note::

       Again - there needs to be a **reason** for this. If something is
       ``unsigned long``, then there's no reason to do

typedef không dấu dài myflags_t;

nhưng nếu có lý do rõ ràng tại sao trong những trường hợp nhất định
     có thể là ZZ0000ZZ và trong các cấu hình khác có thể là
     ZZ0001ZZ, thì bằng mọi cách hãy tiếp tục và sử dụng typedef.

(c) khi bạn sử dụng thưa thớt để tạo loại ZZ0000ZZ theo đúng nghĩa đen cho
     kiểm tra kiểu.

(d) Các loại mới giống hệt với các loại C99 tiêu chuẩn, trong một số trường hợp nhất định
     hoàn cảnh đặc biệt.

Mặc dù chỉ mất một khoảng thời gian ngắn cho mắt và
     não để làm quen với các loại tiêu chuẩn như ZZ0000ZZ,
     Dù sao thì một số người cũng phản đối việc sử dụng chúng.

Do đó, các loại ZZ0000ZZ dành riêng cho Linux và các loại
     tương đương đã ký giống hệt với các loại tiêu chuẩn là
     được phép -- mặc dù chúng không bắt buộc trong mã mới của bạn
     sở hữu.

Khi chỉnh sửa mã hiện có đã sử dụng bộ này hoặc bộ kia
     về các loại, bạn nên tuân theo các lựa chọn hiện có trong mã đó.

(e) Các loại an toàn để sử dụng trong không gian người dùng.

Trong một số cấu trúc nhất định hiển thị với không gian người dùng, chúng tôi không thể
     yêu cầu các loại C99 và không thể sử dụng mẫu ZZ0000ZZ ở trên. Vì vậy, chúng tôi
     sử dụng __u32 và các loại tương tự trong tất cả các cấu trúc được chia sẻ
     với không gian người dùng.

Có thể còn có những trường hợp khác nữa, nhưng về cơ bản quy tắc phải là NEVER
EVER sử dụng typedef trừ khi bạn có thể khớp rõ ràng một trong các quy tắc đó.

Nói chung, một con trỏ hoặc một cấu trúc có các phần tử có thể
được truy cập trực tiếp nếu ZZ0000ZZ là typedef.


6) Chức năng
------------

Các chức năng phải ngắn gọn, hấp dẫn và chỉ làm một việc.  Họ nên
vừa với một hoặc hai màn hình văn bản (kích thước màn hình ISO/ANSI là 80x24,
như chúng ta đều biết), hãy làm một việc và làm tốt việc đó.

Độ dài tối đa của hàm tỷ lệ nghịch với
độ phức tạp và mức độ thụt lề của hàm đó.  Vì vậy, nếu bạn có một
về mặt khái niệm hàm đơn giản chỉ là một hàm dài (nhưng đơn giản)
câu lệnh trường hợp, trong đó bạn phải làm rất nhiều việc nhỏ cho rất nhiều
các trường hợp khác nhau, có thể sử dụng chức năng dài hơn.

Tuy nhiên, nếu bạn có một hàm phức tạp và bạn nghi ngờ rằng
học sinh trung học năm thứ nhất kém năng khiếu thậm chí có thể không
hiểu rõ chức năng này là gì, bạn nên tuân theo
giới hạn tối đa càng chặt chẽ hơn.  Sử dụng các hàm trợ giúp với
tên mô tả (bạn có thể yêu cầu trình biên dịch đưa chúng vào dòng nếu bạn nghĩ
nó rất quan trọng về hiệu suất và có thể nó sẽ hoạt động tốt hơn
hơn những gì bạn đã làm).

Một thước đo khác của hàm là số lượng biến cục bộ.  Họ
không được vượt quá 5-10, nếu không bạn đang làm sai điều gì đó.  Hãy suy nghĩ lại
chức năng và chia nó thành các phần nhỏ hơn.  Một bộ não con người có thể
nói chung dễ dàng theo dõi khoảng 7 thứ khác nhau, bất cứ thứ gì hơn thế
và nó trở nên bối rối.  Bạn biết bạn rất thông minh, nhưng có lẽ bạn muốn
để hiểu những gì bạn đã làm trong 2 tuần kể từ bây giờ.

Trong các tệp nguồn, hãy phân tách các chức năng bằng một dòng trống.  Nếu chức năng là
đã xuất, macro ZZ0000ZZ cho nó sẽ xuất hiện ngay sau
đường ngoặc nhọn của hàm đóng.  Ví dụ.:

.. code-block:: c

	int system_is_up(void)
	{
		return system_state == SYSTEM_RUNNING;
	}
	EXPORT_SYMBOL(system_is_up);

6.1) Nguyên mẫu hàm
************************

Trong nguyên mẫu hàm, hãy bao gồm tên tham số cùng với kiểu dữ liệu của chúng.
Mặc dù ngôn ngữ C không yêu cầu điều này nhưng nó được ưu tiên hơn trong Linux
bởi vì đó là cách đơn giản để bổ sung những thông tin có giá trị cho người đọc.

Không sử dụng từ khóa ZZ0000ZZ với các khai báo hàm vì điều này làm cho
dòng dài hơn và không thực sự cần thiết.

Khi viết nguyên mẫu hàm, vui lòng giữ lại ZZ0000ZZ.
Ví dụ: sử dụng khai báo hàm này ví dụ::

__init void * __must_check hành động (giá trị ma thuật enum, kích thước size_t, số lượng u8,
				   char *fmt, ...) __printf(4, 5) __malloc;

Thứ tự ưu tiên của các phần tử cho nguyên mẫu hàm là:

- lớp lưu trữ (bên dưới là ZZ0000ZZ, lưu ý rằng ZZ0001ZZ
  về mặt kỹ thuật là một thuộc tính nhưng được xử lý như ZZ0002ZZ)
- thuộc tính lớp lưu trữ (ở đây là ZZ0003ZZ -- tức là khai báo phần, nhưng cũng
  những thứ như ZZ0004ZZ)
- kiểu trả về (ở đây, ZZ0005ZZ)
- thuộc tính kiểu trả về (ở đây, ZZ0006ZZ)
- tên hàm (ở đây, ZZ0007ZZ)
- tham số chức năng (ở đây, ZZ0008ZZ,
  lưu ý rằng tên tham số phải luôn được bao gồm)
- thuộc tính tham số chức năng (ở đây, ZZ0009ZZ)
- thuộc tính hành vi chức năng (ở đây, ZZ0010ZZ)

Lưu ý rằng đối với hàm ZZ0001ZZ (tức là phần thân hàm thực tế),
trình biên dịch không cho phép các thuộc tính tham số hàm sau
các tham số chức năng. Trong những trường hợp này, họ nên theo dõi việc lưu trữ
thuộc tính lớp (ví dụ: lưu ý vị trí đã thay đổi của ZZ0000ZZ
bên dưới, so với ví dụ ZZ0002ZZ ở trên)::

tĩnh __always_inline __init __printf(4, 5) void * __must_check hành động(giá trị ma thuật enum,
		kích thước size_t, số lượng u8, char *fmt, ...) __malloc
 {
	...
 }

7) Thoát tập trung các chức năng
-----------------------------------

Mặc dù bị một số người phản đối, nhưng câu lệnh goto tương đương là
được sử dụng thường xuyên bởi các trình biên dịch dưới dạng lệnh nhảy vô điều kiện.

Câu lệnh goto rất hữu ích khi một hàm thoát khỏi nhiều
địa điểm và một số công việc chung như dọn dẹp phải được thực hiện.  Nếu không có
cần dọn dẹp sau đó chỉ cần quay lại trực tiếp.

Chọn tên nhãn cho biết goto làm gì hoặc tại sao goto tồn tại.  Một
ví dụ về một cái tên hay có thể là ZZ0000ZZ nếu goto giải phóng ZZ0001ZZ.
Tránh sử dụng các tên GW-BASIC như ZZ0002ZZ và ZZ0003ZZ, vì bạn sẽ phải làm như vậy.
đánh số lại chúng nếu bạn thêm hoặc xóa đường dẫn thoát và chúng sẽ chính xác
dù sao cũng khó xác minh.

Lý do sử dụng gotos là:

- câu lệnh vô điều kiện dễ hiểu và dễ làm theo hơn
- làm tổ giảm
- lỗi do không cập nhật từng điểm thoát khi thực hiện
  sửa đổi bị ngăn chặn
- lưu công việc biên dịch để tối ưu hóa mã dư thừa;)

.. code-block:: c

	int fun(int a)
	{
		int result = 0;
		char *buffer;

		buffer = kmalloc(SIZE, GFP_KERNEL);
		if (!buffer)
			return -ENOMEM;

		if (condition1) {
			while (loop1) {
				...
			}
			result = 1;
			goto out_free_buffer;
		}
		...
	out_free_buffer:
		kfree(buffer);
		return result;
	}

Một loại lỗi phổ biến cần lưu ý là ZZ0000ZZ trông như thế này:

.. code-block:: c

	err:
		kfree(foo->bar);
		kfree(foo);
		return ret;

Lỗi trong mã này là trên một số đường dẫn thoát ZZ0000ZZ là NULL.  Thông thường
cách khắc phục là chia nó thành hai nhãn lỗi ZZ0001ZZ và
ZZ0002ZZ:

.. code-block:: c

	err_free_bar:
		kfree(foo->bar);
	err_free_foo:
		kfree(foo);
		return ret;

Tốt nhất bạn nên mô phỏng lỗi để kiểm tra tất cả các đường dẫn thoát.


8) Bình luận
-------------

Bình luận là tốt, nhưng cũng có nguy cơ bình luận quá mức.  NEVER
hãy thử giải thích HOW mã của bạn hoạt động trong một nhận xét: tốt hơn nhiều là
viết mã sao cho ZZ0000ZZ hiển nhiên và thật lãng phí
đã đến lúc giải thích mã viết sai.

Nói chung, bạn muốn nhận xét của mình cho WHAT biết rằng mã của bạn biết chứ không phải HOW.
Ngoài ra, hãy cố gắng tránh đặt chú thích bên trong thân hàm: nếu
hàm phức tạp đến mức bạn cần phải bình luận riêng từng phần của nó,
có lẽ bạn nên quay lại chương 6 một lúc.  Bạn có thể làm
những nhận xét nhỏ cần lưu ý hoặc cảnh báo về điều gì đó đặc biệt thông minh (hoặc
xấu xí), nhưng cố gắng tránh quá mức.  Thay vào đó hãy đặt bình luận ở đầu
của chức năng, cho mọi người biết nó làm gì và có thể là WHY nó làm gì
nó.

Khi nhận xét các chức năng API của kernel, vui lòng sử dụng định dạng kernel-doc.
Xem các tập tin tại ZZ0000ZZ và
ZZ0001ZZ để biết chi tiết. Lưu ý rằng sự nguy hiểm của việc bình luận quá mức
áp dụng cho các nhận xét kernel-doc đều giống nhau. Không thêm bản soạn sẵn
kernel-doc chỉ đơn giản nhắc lại những gì hiển nhiên từ chữ ký
của chức năng.

Kiểu ưa thích cho các nhận xét dài (nhiều dòng) là:

.. code-block:: c

	/*
	 * This is the preferred style for multi-line
	 * comments in the Linux kernel source code.
	 * Please use it consistently.
	 *
	 * Description:  A column of asterisks on the left side,
	 * with beginning and ending almost-blank lines.
	 */

Điều quan trọng nữa là phải chú thích dữ liệu, cho dù chúng là kiểu cơ bản hay kiểu dẫn xuất.
các loại.  Để đạt được mục đích này, chỉ sử dụng một khai báo dữ liệu trên mỗi dòng (không có dấu phẩy cho
nhiều khai báo dữ liệu).  Điều này giúp bạn có chỗ cho một nhận xét nhỏ về mỗi
mục, giải thích công dụng của nó.


9) Bạn đã làm mọi chuyện rối tung lên
---------------------------

Không sao đâu, tất cả chúng ta đều làm vậy.  Chắc hẳn bạn đã được Unix lâu năm của mình kể lại
trợ giúp người dùng rằng ZZ0000ZZ tự động định dạng nguồn C cho
bạn, và bạn nhận thấy rằng có, nó thực hiện điều đó, nhưng nó được đặt mặc định
việc sử dụng ít hơn mong muốn (trên thực tế, chúng còn tệ hơn so với việc sử dụng ngẫu nhiên
đang gõ - vô số con khỉ gõ vào emacs GNU sẽ không bao giờ
làm một chương trình hay).

Vì vậy, bạn có thể loại bỏ emacs GNU hoặc thay đổi nó để sử dụng saner
các giá trị.  Để thực hiện việc sau, bạn có thể dán phần sau vào tệp .emacs của mình:

.. code-block:: elisp

  (defun c-lineup-arglist-tabs-only (ignored)
    "Line up argument lists by tabs, not spaces"
    (let* ((anchor (c-langelem-pos c-syntactic-element))
           (column (c-langelem-2nd-pos c-syntactic-element))
           (offset (- (1+ column) anchor))
           (steps (floor offset c-basic-offset)))
      (* (max steps 1)
         c-basic-offset)))

  (dir-locals-set-class-variables
   'linux-kernel
   '((c-mode . (
          (c-basic-offset . 8)
          (c-label-minimum-indentation . 0)
          (c-offsets-alist . (
                  (arglist-close         . c-lineup-arglist-tabs-only)
                  (arglist-cont-nonempty .
                      (c-lineup-gcc-asm-reg c-lineup-arglist-tabs-only))
                  (arglist-intro         . +)
                  (brace-list-intro      . +)
                  (c                     . c-lineup-C-comments)
                  (case-label            . 0)
                  (comment-intro         . c-lineup-comment)
                  (cpp-define-intro      . +)
                  (cpp-macro             . -1000)
                  (cpp-macro-cont        . +)
                  (defun-block-intro     . +)
                  (else-clause           . 0)
                  (func-decl-cont        . +)
                  (inclass               . +)
                  (inher-cont            . c-lineup-multi-inher)
                  (knr-argdecl-intro     . 0)
                  (label                 . -1000)
                  (statement             . 0)
                  (statement-block-intro . +)
                  (statement-case-intro  . +)
                  (statement-cont        . +)
                  (substatement          . +)
                  ))
          (indent-tabs-mode . t)
          (show-trailing-whitespace . t)
          ))))

  (dir-locals-set-directory-class
   (expand-file-name "~/src/linux-trees")
   'linux-kernel)

Điều này sẽ làm cho emacs hoạt động tốt hơn với kiểu mã hóa kernel cho C
các tập tin bên dưới ZZ0000ZZ.

Nhưng ngay cả khi bạn thất bại trong việc khiến emacs thực hiện định dạng lành mạnh, thì cũng không
mọi thứ đều bị mất: sử dụng ZZ0000ZZ.

Bây giờ, một lần nữa, thụt lề GNU có cùng các cài đặt chết não như GNU emacs
có, đó là lý do tại sao bạn cần cung cấp cho nó một số tùy chọn dòng lệnh.
Tuy nhiên, điều đó cũng không quá tệ, vì ngay cả những người tạo ra GNU cũng phải thụt lùi
thừa nhận quyền lực của K&R (người GNU không xấu xa, họ
chỉ sai lầm nghiêm trọng trong vấn đề này), vì vậy bạn chỉ cần thụt lề
tùy chọn ZZ0000ZZ (viết tắt của ZZ0001ZZ), hoặc sử dụng
ZZ0002ZZ, thụt lề theo phong cách mới nhất.

ZZ0000ZZ có rất nhiều lựa chọn, và đặc biệt là về phần bình luận
định dạng lại, bạn có thể muốn xem trang man.  Nhưng
hãy nhớ: ZZ0001ZZ không phải là cách khắc phục lỗi lập trình.

Lưu ý rằng bạn cũng có thể sử dụng công cụ ZZ0001ZZ để giúp bạn
các quy tắc này, để tự động định dạng lại các phần mã của bạn một cách nhanh chóng,
và xem lại toàn bộ tệp để phát hiện các lỗi về kiểu mã hóa,
lỗi chính tả và những cải tiến có thể có. Nó cũng thuận tiện cho việc sắp xếp ZZ0002ZZ,
để căn chỉnh các biến/macro, để chỉnh lại văn bản và các tác vụ tương tự khác.
Xem file ZZ0000ZZ
để biết thêm chi tiết.

Một số cài đặt soạn thảo cơ bản, chẳng hạn như thụt lề và kết thúc dòng, sẽ được
được đặt tự động nếu bạn đang sử dụng trình chỉnh sửa tương thích với
EditorConfig. Xem trang web EditorConfig chính thức để biết thêm thông tin:
ZZ0000ZZ

10) Tệp cấu hình Kconfig
-------------------------------

Đối với tất cả các tệp cấu hình Kconfig* trong cây nguồn,
vết lõm có phần khác nhau.  Các dòng theo định nghĩa ZZ0000ZZ
được thụt lề bằng một tab, trong khi văn bản trợ giúp được thụt lề thêm hai tab.
không gian.  Ví dụ::

cấu hình AUDIT
	bool "Hỗ trợ kiểm tra"
	phụ thuộc vào NET
	giúp đỡ
	  Cho phép cơ sở hạ tầng kiểm toán có thể được sử dụng với cơ sở hạ tầng khác
	  hệ thống con kernel, chẳng hạn như SELinux (yêu cầu điều này cho
	  ghi nhật ký đầu ra của tin nhắn avc).  Không thực hiện cuộc gọi hệ thống
	  kiểm tra mà không có CONFIG_AUDITSYSCALL.

Các tính năng cực kỳ nguy hiểm (chẳng hạn như hỗ trợ ghi cho một số
filesystems) nên quảng cáo điều này một cách nổi bật trong chuỗi nhắc nhở của họ::

cấu hình ADFS_FS_RW
	bool "Hỗ trợ ghi ADFS (DANGEROUS)"
	phụ thuộc vào ADFS_FS
	...

Để có tài liệu đầy đủ về các tệp cấu hình, hãy xem tệp
Tài liệu/kbuild/kconfig-lingu.rst.


11) Cấu trúc dữ liệu
-------------------

Cấu trúc dữ liệu có khả năng hiển thị bên ngoài luồng đơn
môi trường mà chúng được tạo ra và bị phá hủy phải luôn có
số lượng tham chiếu.  Trong kernel, việc thu gom rác không tồn tại (và
bên ngoài bộ sưu tập rác kernel chậm và không hiệu quả), điều này
có nghĩa là bạn hoàn toàn có thể tham khảo ZZ0000ZZ để tham khảo tất cả các công dụng của mình.

Việc đếm tham chiếu có nghĩa là bạn có thể tránh bị khóa và cho phép nhiều
người dùng có quyền truy cập song song vào cấu trúc dữ liệu - và không có
lo lắng về việc cấu trúc đột nhiên biến mất khỏi chúng chỉ
bởi vì họ đã ngủ hoặc làm việc khác trong một thời gian.

Lưu ý rằng khóa là ZZ0000ZZ thay thế cho việc đếm tham chiếu.
Khóa được sử dụng để giữ cấu trúc dữ liệu mạch lạc, trong khi tham chiếu
đếm là một kỹ thuật quản lý bộ nhớ.  Thông thường cả hai đều cần thiết, và
chúng không được nhầm lẫn với nhau.

Nhiều cấu trúc dữ liệu thực sự có thể có hai cấp độ đếm tham chiếu,
khi có người dùng ZZ0000ZZ khác nhau.  Số lượng lớp con được tính
số lượng người dùng lớp con và giảm số lượng toàn cầu chỉ một lần
khi số lượng lớp con về 0.

Ví dụ về loại ZZ0000ZZ này có thể được tìm thấy trong
quản lý bộ nhớ (ZZ0001ZZ: mm_users và mm_count), và trong
mã hệ thống tập tin (ZZ0002ZZ: s_count và s_active).

Hãy nhớ: nếu một luồng khác có thể tìm thấy cấu trúc dữ liệu của bạn còn bạn thì không.
có số lượng tài liệu tham khảo về nó, bạn gần như chắc chắn có lỗi.


12) Macro, Enum và RTL
-------------------------

Tên của macro xác định hằng số và nhãn trong enum được viết hoa.

.. code-block:: c

	#define CONSTANT 0x12345

Enums được ưu tiên khi xác định một số hằng số liên quan.

Tên macro CAPITALIZED được đánh giá cao nhưng macro giống chức năng
có thể được đặt tên bằng chữ thường.

Nói chung, các hàm nội tuyến được ưu tiên hơn các macro giống như các hàm.

Macro có nhiều câu lệnh phải được đặt trong khối do - while:

.. code-block:: c

	#define macrofun(a, b, c)			\
		do {					\
			if (a == 5)			\
				do_this(b, c);		\
		} while (0)

Các macro giống chức năng có tham số không được sử dụng nên được thay thế bằng macro tĩnh
các hàm nội tuyến để tránh vấn đề về các biến không được sử dụng:

.. code-block:: c

	static inline void fun(struct foo *foo)
	{
	}

Do thông lệ lịch sử, nhiều tệp vẫn sử dụng "truyền tới (void)"
phương pháp đánh giá các thông số Tuy nhiên, phương pháp này không được khuyến khích.
Các hàm nội tuyến giải quyết vấn đề "biểu thức có tác dụng phụ
được đánh giá nhiều lần", tránh các vấn đề về biến không được sử dụng và
thường được ghi lại tốt hơn macro vì một số lý do.

.. code-block:: c

	/*
	 * Avoid doing this whenever possible and instead opt for static
	 * inline functions
	 */
	#define macrofun(foo) do { (void) (foo); } while (0)

Những điều cần tránh khi sử dụng macro:

1) macro ảnh hưởng đến luồng điều khiển:

.. code-block:: c

	#define FOO(x)					\
		do {					\
			if (blah(x) < 0)		\
				return -EBUGGERED;	\
		} while (0)

là một ý tưởng tồi ZZ0001ZZ.  Nó trông giống như một cuộc gọi hàm nhưng thoát khỏi ZZ0000ZZ
chức năng; không phá vỡ trình phân tích cú pháp nội bộ của những người sẽ đọc mã.

2) các macro phụ thuộc vào việc có biến cục bộ có tên ma thuật:

.. code-block:: c

	#define FOO(val) bar(index, val)

có thể trông có vẻ hay nhưng thật khó hiểu khi người ta đọc
mã và nó dễ bị hỏng do những thay đổi dường như vô hại.

3) macro có đối số được sử dụng làm giá trị l: FOO(x) = y; sẽ
cắn bạn nếu ai đó, ví dụ: biến FOO thành một hàm nội tuyến.

4) quên quyền ưu tiên: macro xác định hằng số bằng biểu thức
phải đặt biểu thức trong dấu ngoặc đơn. Cảnh giác với các vấn đề tương tự với
macro sử dụng tham số.

.. code-block:: c

	#define CONSTANT 0x4000
	#define CONSTEXP (CONSTANT | 3)

5) xung đột không gian tên khi xác định các biến cục bộ trong macro giống như
chức năng:

.. code-block:: c

	#define FOO(x)				\
	({					\
		typeof(x) ret;			\
		ret = calc_ret(x);		\
		(ret);				\
	})

ret là tên chung cho một biến cục bộ - __foo_ret ít có khả năng hơn
va chạm với một biến hiện có.

Hướng dẫn cpp xử lý các macro một cách triệt để. Hướng dẫn sử dụng nội bộ gcc cũng
bao gồm RTL được sử dụng thường xuyên với ngôn ngữ hợp ngữ trong kernel.


13) In thông báo kernel
----------------------------

Các nhà phát triển hạt nhân muốn được coi là người biết chữ. Hãy chú ý đến chính tả
của các thông điệp kernel để tạo ấn tượng tốt. Không sử dụng sai
các cơn co thắt như ZZ0000ZZ; thay vào đó hãy sử dụng ZZ0001ZZ hoặc ZZ0002ZZ. làm cho
thông điệp ngắn gọn, rõ ràng và không mơ hồ.

Tin nhắn kernel không nhất thiết phải kết thúc bằng dấu chấm.

Việc in các số trong ngoặc đơn (%d) không thêm giá trị nào và nên tránh.

Có một số macro chẩn đoán mô hình trình điều khiển trong <linux/dev_printk.h>
mà bạn nên sử dụng để đảm bảo tin nhắn được khớp với đúng thiết bị
và trình điều khiển và được gắn thẻ ở cấp độ phù hợp: dev_err(), dev_warn(),
dev_info(), v.v.  Đối với các tin nhắn không liên quan đến
thiết bị cụ thể, <linux/printk.h> định nghĩa pr_notice(), pr_info(),
pr_warn(), pr_err(), v.v. Khi trình điều khiển hoạt động bình thường, chúng sẽ im lặng,
vì vậy hãy ưu tiên sử dụng dev_dbg/pr_debug trừ khi có điều gì đó không ổn.

Việc đưa ra các thông báo gỡ lỗi tốt có thể là một thách thức khá lớn; và một lần
bạn có chúng, chúng có thể trợ giúp rất nhiều cho việc khắc phục sự cố từ xa.  Tuy nhiên
việc in thông báo gỡ lỗi được xử lý khác với việc in thông báo không gỡ lỗi khác
tin nhắn.  Trong khi các hàm pr_XXX() khác in vô điều kiện,
pr_debug() thì không; nó được biên dịch theo mặc định, trừ khi DEBUG được
được xác định hoặc CONFIG_DYNAMIC_DEBUG được đặt.  Điều đó cũng đúng với dev_dbg(),
và một quy ước liên quan sử dụng VERBOSE_DEBUG để thêm thông báo dev_vdbg() vào
những cái đã được kích hoạt bởi DEBUG.

Nhiều hệ thống con có tùy chọn gỡ lỗi Kconfig để bật -DDEBUG trong
Makefile tương ứng; trong các trường hợp khác, các tệp cụ thể #define DEBUG.  Và
khi một thông báo gỡ lỗi phải được in vô điều kiện, chẳng hạn như nếu nó được
đã ở trong phần #ifdef liên quan đến gỡ lỗi, printk(KERN_DEBUG ...) có thể
đã sử dụng.


14) Cấp phát bộ nhớ
---------------------

Hạt nhân cung cấp các bộ cấp phát bộ nhớ có mục đích chung sau:
kmalloc(), kzalloc(), kmalloc_array(), kcalloc(), vmalloc() và
vzalloc().  Vui lòng tham khảo tài liệu API để biết thêm thông tin
về họ.  ZZ0000ZZ

Hình thức ưa thích để truyền kích thước của một cấu trúc là như sau:

.. code-block:: c

	p = kmalloc(sizeof(*p), ...);

Dạng thay thế trong đó tên cấu trúc được đánh vần làm ảnh hưởng đến khả năng đọc và
đưa ra cơ hội xảy ra lỗi khi loại biến con trỏ bị thay đổi
nhưng sizeof tương ứng được chuyển đến bộ cấp phát bộ nhớ thì không.

Việc truyền giá trị trả về là con trỏ void là không cần thiết. Sự chuyển đổi
từ con trỏ void đến bất kỳ loại con trỏ nào khác đều được đảm bảo bởi lập trình C
ngôn ngữ.

Hình thức ưa thích để phân bổ một mảng là như sau:

.. code-block:: c

	p = kmalloc_array(n, sizeof(...), ...);

Dạng ưa thích để phân bổ một mảng có số 0 là như sau:

.. code-block:: c

	p = kcalloc(n, sizeof(...), ...);

Cả hai biểu mẫu đều kiểm tra mức tràn trên kích thước phân bổ n * sizeof(...),
và trả lại NULL nếu điều đó xảy ra.

Tất cả các hàm phân bổ chung này đều phát ra kết xuất ngăn xếp do lỗi khi sử dụng
không có __GFP_NOWARN nên việc phát ra thêm lỗi cũng chẳng ích gì
thông báo khi NULL được trả về.

15) Bệnh nội tuyến
----------------------

Dường như có một quan niệm sai lầm phổ biến rằng gcc có một phép thuật "làm cho tôi
tùy chọn tăng tốc nhanh hơn" được gọi là ZZ0000ZZ. Mặc dù việc sử dụng nội tuyến có thể
thích hợp (ví dụ như một phương tiện thay thế macro, xem Chương 12), nó
rất thường xuyên là không. Việc sử dụng nhiều từ khóa nội tuyến sẽ dẫn đến một kết quả lớn hơn nhiều
kernel, do đó làm chậm toàn bộ hệ thống do kích thước lớn hơn
dấu chân icache cho CPU và đơn giản vì có ít bộ nhớ hơn
có sẵn cho pagecache. Chỉ cần nghĩ về nó; lỗi bộ đệm trang gây ra lỗi
tìm kiếm đĩa, quá trình này dễ dàng mất 5 mili giây. Có LOT chu kỳ cpu
có thể đi vào 5 mili giây này.

Một nguyên tắc nhỏ hợp lý là không đặt nội tuyến tại các hàm có nhiều
hơn 3 dòng mã trong đó. Một ngoại lệ cho quy tắc này là trường hợp
một tham số được biết đến là hằng số thời gian biên dịch và do đó
tính không đổi của bạn ZZ0000ZZ trình biên dịch sẽ có thể tối ưu hóa hầu hết các
hoạt động đi vào thời gian biên dịch. Để có một ví dụ hay về trường hợp sau này, hãy xem
hàm nội tuyến kmalloc().

Mọi người thường tranh luận rằng việc thêm nội tuyến vào các hàm tĩnh và được sử dụng
chỉ một lần luôn là chiến thắng vì không có sự đánh đổi về không gian. Trong khi đây là
đúng về mặt kỹ thuật, gcc có khả năng tự động nội tuyến những thứ này mà không cần
trợ giúp và vấn đề bảo trì loại bỏ nội tuyến khi người dùng thứ hai
xuất hiện lớn hơn giá trị tiềm năng của gợi ý yêu cầu gcc thực hiện
dù sao thì nó cũng đã làm được điều gì đó.


16) Giá trị và tên trả về của hàm
------------------------------------

Hàm có thể trả về các giá trị thuộc nhiều loại khác nhau và một trong những
phổ biến nhất là một giá trị cho biết hàm đã thành công hay chưa
thất bại.  Giá trị như vậy có thể được biểu diễn dưới dạng số nguyên mã lỗi
(-Exxx = thất bại, 0 = thành công) hoặc boolean ZZ0000ZZ (0 = thất bại,
khác 0 = thành công).

Việc kết hợp hai loại biểu diễn này là một nguồn phong phú của
lỗi khó tìm.  Nếu ngôn ngữ C có sự phân biệt rõ ràng
giữa số nguyên và boolean thì trình biên dịch sẽ tìm ra những lỗi này
cho chúng tôi... nhưng không phải vậy.  Để giúp ngăn chặn những lỗi như vậy, hãy luôn làm theo điều này
quy ước::

Nếu tên của hàm là một hành động hoặc một mệnh lệnh,
	hàm sẽ trả về một số nguyên mã lỗi.  Nếu tên
	là một vị từ, hàm sẽ trả về một boolean "thành công".

Ví dụ: ZZ0000ZZ là một lệnh và hàm add_work() trả về 0
để thành công hoặc -EBUSY nếu thất bại.  Tương tự như vậy, ZZ0001ZZ là
một vị từ và hàm pci_dev_hiện tại() trả về 1 nếu thành công trong
tìm thiết bị phù hợp hoặc 0 nếu không.

Tất cả các chức năng được XUẤT phải tôn trọng quy ước này và tất cả
chức năng công cộng.  Các chức năng riêng tư (tĩnh) không cần thiết, nhưng nó là
khuyên họ nên làm như vậy.

Các hàm có giá trị trả về là kết quả thực sự của một phép tính, thay vì
hơn là một dấu hiệu cho thấy việc tính toán có thành công hay không, không phụ thuộc vào
quy tắc này.  Nói chung, chúng biểu thị sự thất bại bằng cách trả về một số giá trị ngoài phạm vi
kết quả.  Các ví dụ điển hình là các hàm trả về con trỏ; họ sử dụng
NULL hoặc cơ chế ERR_PTR để báo lỗi.


17) Sử dụng bool
--------------

Loại bool nhân Linux là bí danh của loại C99 _Bool. giá trị bool có thể
chỉ đánh giá thành 0 hoặc 1 và chuyển đổi ngầm định hoặc rõ ràng thành bool
tự động chuyển đổi giá trị thành đúng hoặc sai. Khi sử dụng kiểu bool,
!! việc xây dựng là không cần thiết, điều này giúp loại bỏ một lớp lỗi.

Khi làm việc với các giá trị bool, nên sử dụng định nghĩa đúng và sai
thay vì 1 và 0.

Các kiểu trả về của hàm bool và các biến ngăn xếp luôn có thể sử dụng bất cứ khi nào
thích hợp. Việc sử dụng bool được khuyến khích để cải thiện khả năng đọc và thường là một
tùy chọn tốt hơn 'int' để lưu trữ các giá trị boolean.

Không sử dụng bool nếu bố cục dòng bộ đệm hoặc kích thước của giá trị quan trọng, vì kích thước của nó
và căn chỉnh khác nhau dựa trên kiến trúc được biên dịch. Các cấu trúc được
được tối ưu hóa cho căn chỉnh và kích thước không nên sử dụng bool.

Nếu một cấu trúc có nhiều giá trị đúng/sai, hãy xem xét việc hợp nhất chúng thành một
bitfield có thành viên 1 bit hoặc sử dụng loại chiều rộng cố định thích hợp, chẳng hạn như
u8.

Tương tự đối với các đối số của hàm, nhiều giá trị đúng/sai có thể được hợp nhất
thành một đối số 'cờ' theo từng bit và 'cờ' thường có thể là một đối số nhiều hơn
giải pháp thay thế có thể đọc được nếu các trang gọi có hằng số đúng/sai trần trụi.

Mặt khác, việc hạn chế sử dụng bool trong cấu trúc và đối số có thể cải thiện
khả năng đọc.

18) Đừng phát minh lại macro kernel
-------------------------------------

Có nhiều tệp tiêu đề trong include/linux/ chứa một số macro
bạn nên sử dụng, thay vì tự mình viết mã một cách rõ ràng một số biến thể của chúng.
Ví dụ: nếu bạn cần tính độ dài của một mảng, hãy tận dụng
của vĩ mô

.. code-block:: c

	#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

được định nghĩa trong array_size.h.

Tương tự, nếu bạn cần tính kích thước của một số thành viên cấu trúc, hãy sử dụng

.. code-block:: c

	#define sizeof_field(t, f) (sizeof(((t*)0)->f))

được định nghĩa trong stddef.h.

Ngoài ra còn có các macro min() và max() được xác định trong minmax.h thực hiện kiểm tra loại nghiêm ngặt
nếu bạn cần chúng. Vui lòng xem qua các tệp tiêu đề để xem những gì khác đã có
đã xác định rằng bạn không nên sao chép trong mã của mình.


19) Mô hình biên tập và các hành trình khác
------------------------------------

Một số biên tập viên có thể diễn giải thông tin cấu hình được nhúng trong tệp nguồn,
được chỉ định bằng các dấu hiệu đặc biệt.  Ví dụ: emacs diễn giải các dòng được đánh dấu
như thế này:

.. code-block:: c

	-*- mode: c -*-

Hoặc như thế này:

.. code-block:: c

	/*
	Local Variables:
	compile-command: "gcc -DMAGIC_DEBUG_FLAG foo.c"
	End:
	*/

Vim diễn giải các điểm đánh dấu trông như thế này:

.. code-block:: c

	/* vim:set sw=8 noet */

Không bao gồm bất kỳ thứ nào trong số này trong các tệp nguồn.  Người ta có cái riêng của mình
cấu hình trình soạn thảo và các tệp nguồn của bạn không được ghi đè lên chúng.  Cái này
bao gồm các điểm đánh dấu thụt lề và cấu hình chế độ.  Mọi người có thể sử dụng
chế độ tùy chỉnh riêng hoặc có thể có một số phương pháp kỳ diệu khác để tạo vết lõm
làm việc chính xác.


20) Lắp ráp nội tuyến
-------------------

Trong mã dành riêng cho kiến trúc, bạn có thể cần sử dụng tập hợp nội tuyến để giao tiếp
với CPU hoặc chức năng nền tảng.  Đừng ngần ngại làm như vậy khi cần thiết.
Tuy nhiên, không sử dụng lắp ráp nội tuyến một cách vô cớ khi C có thể thực hiện công việc.  bạn có thể
và nên chọc phần cứng từ C khi có thể.

Hãy cân nhắc việc viết các hàm trợ giúp đơn giản bao bọc các bit chung của nội tuyến
lắp ráp, thay vì viết chúng nhiều lần với những thay đổi nhỏ.  Ghi nhớ
lắp ráp nội tuyến đó có thể sử dụng các tham số C.

Các hàm lắp ráp lớn, không tầm thường phải có trong các tệp .S, với các hàm tương ứng
Nguyên mẫu C được xác định trong tệp tiêu đề C.  Các nguyên mẫu C để lắp ráp
các chức năng nên sử dụng ZZ0000ZZ.

Bạn có thể cần đánh dấu câu lệnh asm của mình là không ổn định để ngăn GCC khỏi
loại bỏ nó nếu GCC không nhận thấy bất kỳ tác dụng phụ nào.  Bạn không phải lúc nào cũng cần
tuy nhiên, hãy làm như vậy và làm như vậy một cách không cần thiết có thể hạn chế việc tối ưu hóa.

Khi viết một câu lệnh hợp ngữ nội tuyến có chứa nhiều
hướng dẫn, đặt mỗi hướng dẫn trên một dòng riêng biệt trong một trích dẫn riêng
chuỗi và kết thúc mỗi chuỗi ngoại trừ chuỗi cuối cùng bằng ZZ0000ZZ để thụt lề chính xác
lệnh tiếp theo trong đầu ra lắp ráp:

.. code-block:: c

	asm ("magic %reg1, #42\n\t"
	     "more_magic %reg2, %reg3"
	     : /* outputs */ : /* inputs */ : /* clobbers */);


21) Biên dịch có điều kiện
---------------------------

Bất cứ khi nào có thể, đừng sử dụng các điều kiện tiền xử lý (#if, #ifdef) trong .c
tập tin; làm như vậy khiến mã khó đọc hơn và khó theo dõi logic hơn.  Thay vào đó,
sử dụng các điều kiện như vậy trong tệp tiêu đề xác định các hàm để sử dụng trong các tệp .c đó
các tệp, cung cấp các phiên bản sơ khai không hoạt động trong trường hợp #else, sau đó gọi chúng
hoạt động vô điều kiện từ các tệp .c.  Trình biên dịch sẽ tránh tạo ra
bất kỳ mã nào cho lệnh gọi sơ khai, tạo ra kết quả giống hệt nhau, nhưng logic sẽ
vẫn dễ dàng theo dõi.

Thích biên dịch toàn bộ hàm hơn là các phần của hàm hoặc
các phần của biểu thức.  Thay vì đặt ifdef vào một biểu thức, hãy tính hệ số
một phần hoặc toàn bộ biểu thức thành một hàm trợ giúp riêng biệt và áp dụng
có điều kiện cho hàm đó.

Nếu bạn có một hàm hoặc biến có khả năng không được sử dụng trong một
cấu hình cụ thể và trình biên dịch sẽ cảnh báo về định nghĩa của nó
không được sử dụng, hãy đánh dấu định nghĩa là __maybe_unused thay vì gói nó trong
một điều kiện tiền xử lý.  (Tuy nhiên, nếu một hàm hoặc biến ZZ0000ZZ bị hỏng
không sử dụng, hãy xóa nó.)

Trong mã, nếu có thể, hãy sử dụng macro IS_ENABLED để chuyển đổi Kconfig
ký hiệu thành biểu thức boolean C và sử dụng nó trong điều kiện C bình thường:

.. code-block:: c

	if (IS_ENABLED(CONFIG_SOMETHING)) {
		...
	}

Trình biên dịch sẽ liên tục loại bỏ điều kiện và bao gồm hoặc loại trừ
khối mã giống như với #ifdef, vì vậy điều này sẽ không thêm bất kỳ thời gian chạy nào
trên cao.  Tuy nhiên, cách tiếp cận này vẫn cho phép trình biên dịch C xem được mã
bên trong khối và kiểm tra tính chính xác (cú pháp, kiểu, ký hiệu)
tài liệu tham khảo, v.v.).  Vì vậy, bạn vẫn phải sử dụng #ifdef nếu mã bên trong
chặn các ký hiệu tham chiếu sẽ không tồn tại nếu điều kiện không được đáp ứng.

Ở cuối bất kỳ khối #if hoặc #ifdef không tầm thường nào (nhiều hơn một vài dòng),
đặt một nhận xét sau #endif trên cùng một dòng, lưu ý điều kiện
biểu thức được sử dụng.  Ví dụ:

.. code-block:: c

	#ifdef CONFIG_SOMETHING
	...
	#endif /* CONFIG_SOMETHING */


22) Đừng làm hỏng kernel
---------------------------

Nói chung, quyết định làm hỏng kernel thuộc về người dùng chứ không phải
hơn là cho nhà phát triển hạt nhân.

Tránh hoảng loạn()
*************

Panic() nên được sử dụng cẩn thận và chủ yếu chỉ trong khi khởi động hệ thống.
hoảng () chẳng hạn, có thể chấp nhận được khi hết bộ nhớ trong khi khởi động và
không thể tiếp tục.

Sử dụng WARN() thay vì BUG()
****************************

Không thêm mã mới sử dụng bất kỳ biến thể BUG() nào, chẳng hạn như BUG(),
BUG_ON() hoặc VM_BUG_ON(). Thay vào đó, hãy sử dụng biến thể WARN*(), tốt nhất là
WARN_ON_ONCE() và có thể có mã khôi phục. Mã khôi phục không
cần thiết nếu không có cách hợp lý để phục hồi ít nhất một phần.

"Tôi quá lười xử lý lỗi" không phải là lý do để sử dụng BUG(). Thiếu tá
lỗi nội bộ không có cách nào tiếp tục vẫn có thể sử dụng BUG(), nhưng cần
biện minh tốt.

Sử dụng WARN_ON_ONCE() thay vì WARN() hoặc WARN_ON()
**************************************************

WARN_ON_ONCE() thường được ưa thích hơn WARN() hoặc WARN_ON(), bởi vì nó
là điều bình thường đối với một tình trạng cảnh báo nhất định, nếu nó xảy ra, sẽ xảy ra
nhiều lần. Điều này có thể lấp đầy và bao bọc nhật ký kernel và thậm chí có thể làm chậm
hệ thống đủ để việc ghi nhật ký quá mức trở thành của riêng nó, bổ sung
vấn đề.

Đừng xem nhẹ WARN
*******************

WARN*() dành cho các tình huống không mong muốn, điều này không bao giờ nên xảy ra.
Không được sử dụng macro WARN*() cho bất kỳ điều gì dự kiến sẽ xảy ra
trong quá trình hoạt động bình thường. Đây không phải là các xác nhận trước hoặc sau điều kiện, vì
ví dụ. Xin nhắc lại: Không được sử dụng WARN*() cho điều kiện được mong đợi
để kích hoạt dễ dàng, chẳng hạn như bằng các hành động trong không gian của người dùng. pr_warn_once() là một
giải pháp thay thế khả thi nếu bạn cần thông báo cho người dùng về một vấn đề.

Đừng lo lắng về người dùng Panic_on_warn
**************************************

Một vài lời nữa về Panic_on_warn: Hãy nhớ rằng ZZ0000ZZ là một
tùy chọn kernel có sẵn và được nhiều người dùng đặt tùy chọn này. Đây là lý do tại sao
có một bài viết "Đừng xem nhẹ WARN" ở trên. Tuy nhiên, sự tồn tại của
người dùng Panic_on_warn không phải là lý do chính đáng để tránh việc sử dụng hợp lý
WARN*(). Đó là bởi vì, bất cứ ai kích hoạt Panic_on_warn đều rõ ràng
đã yêu cầu kernel gặp sự cố nếu WARN*() kích hoạt và những người dùng như vậy phải
sẵn sàng giải quyết những hậu quả của một hệ thống có phần phức tạp hơn
có khả năng gặp sự cố.

Sử dụng BUILD_BUG_ON() để xác nhận thời gian biên dịch
**********************************************

Việc sử dụng BUILD_BUG_ON() được chấp nhận và khuyến khích vì đây là một
xác nhận tại thời điểm biên dịch không có hiệu lực trong thời gian chạy.

Phụ lục I) Tài liệu tham khảo
----------------------

Ngôn ngữ lập trình C, Phiên bản thứ hai
của Brian W. Kernighan và Dennis M. Ritchie.
Prentice Hall, Inc., 1988.
ISBN 0-13-110362-8 (bìa mềm), 0-13-110370-9 (bìa cứng).

Thực hành lập trình
của Brian W. Kernighan và Rob Pike.
Addison-Wesley, Inc., 1999.
ISBN 0-201-61586-X.

Hướng dẫn sử dụng GNU - tuân thủ K&R và văn bản này - dành cho cpp, gcc,
nội bộ gcc và thụt lề, tất cả đều có sẵn từ ZZ0000ZZ

WG14 là nhóm làm việc tiêu chuẩn hóa quốc tế về lập trình
ngôn ngữ C, URL: ZZ0000ZZ

Kernel CodingStyle, bởi greg@kroah.com tại OLS 2002:
ZZ0000ZZ
