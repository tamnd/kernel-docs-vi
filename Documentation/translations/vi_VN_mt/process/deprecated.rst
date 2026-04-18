.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/deprecated.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _deprecated:

===========================================================================
Giao diện, tính năng ngôn ngữ, thuộc tính và quy ước không được dùng nữa
=====================================================================

Trong một thế giới hoàn hảo, có thể chuyển đổi tất cả các phiên bản của
một số API không được dùng nữa chuyển sang API mới và loại bỏ hoàn toàn API cũ trong
một chu kỳ phát triển duy nhất. Tuy nhiên, do kích thước của hạt nhân,
hệ thống cấp bậc bảo trì và thời gian, không phải lúc nào cũng khả thi để thực hiện những điều này
các loại chuyển đổi cùng một lúc. Điều này có nghĩa là các phiên bản mới có thể lẻn vào
kernel trong khi những cái cũ đang bị loại bỏ, chỉ tạo ra một lượng
hoạt động để loại bỏ sự phát triển của API. Để giáo dục các nhà phát triển về những gì
không được dùng nữa và tại sao, danh sách này được tạo ra như một nơi để
điểm khi việc sử dụng những thứ không được dùng nữa được đề xuất đưa vào
hạt nhân.

__không được dùng nữa
------------
Mặc dù thuộc tính này đánh dấu trực quan một giao diện là không được dùng nữa,
nó ZZ0000ZZ
bởi vì một trong những mục tiêu thường trực của kernel là xây dựng mà không cần
cảnh báo và không ai thực sự làm bất cứ điều gì để loại bỏ những thứ không được dùng nữa này
giao diện. Trong khi sử dụng ZZ0001ZZ, thật tuyệt khi lưu ý một API cũ trong
một tệp tiêu đề, nó không phải là giải pháp đầy đủ. Các giao diện như vậy phải
bị xóa hoàn toàn khỏi kernel hoặc được thêm vào tệp này để ngăn cản
người khác sử dụng chúng trong tương lai.

BUG() và BUG_ON()
------------------
Thay vào đó, hãy sử dụng WARN() và WARN_ON() và xử lý "không thể"
tình trạng lỗi một cách duyên dáng nhất có thể. Trong khi họ BUG()-
API ban đầu được thiết kế để hoạt động như một "tình huống không thể"
khẳng định và để tiêu diệt một luồng hạt nhân một cách "an toàn", hóa ra chúng chỉ là
quá rủi ro. (ví dụ: "Các khóa cần được mở theo thứ tự nào? Có
nhiều trạng thái khác nhau đã được khôi phục chưa?") Rất thông thường, việc sử dụng BUG() sẽ
làm mất ổn định một hệ thống hoặc phá vỡ nó hoàn toàn, khiến nó không thể thực hiện được
để gỡ lỗi hoặc thậm chí nhận được các báo cáo sự cố khả thi. Linus có ZZ0000ZZ
cảm xúc ZZ0001ZZ.

Lưu ý rằng họ WARN() chỉ nên được sử dụng cho "dự kiến
những tình huống không thể tiếp cận được". Nếu bạn muốn cảnh báo về "có thể truy cập
nhưng không mong muốn", vui lòng sử dụng họ pr_warn()- của
chức năng. Chủ sở hữu hệ thống có thể đã đặt hệ thống ZZ0001ZZ,
để đảm bảo hệ thống của họ không tiếp tục chạy khi đối mặt với
điều kiện “không thể tiếp cận”. (Ví dụ: xem các cam kết như ZZ0000ZZ.)

số học được mã hóa mở trong các đối số cấp phát
--------------------------------------------
Không nên tính toán kích thước động (đặc biệt là phép nhân)
được thực hiện trong các đối số của hàm cấp phát bộ nhớ (hoặc tương tự) do
có nguy cơ chúng tràn. Điều này có thể dẫn đến các giá trị bao bọc xung quanh và một
phân bổ nhỏ hơn được thực hiện so với người gọi mong đợi. Sử dụng những cái đó
việc phân bổ có thể dẫn đến tình trạng tràn tuyến tính của bộ nhớ heap và các lỗi khác
những hành vi sai trái. (Một ngoại lệ cho điều này là các giá trị bằng chữ trong đó trình biên dịch
có thể cảnh báo nếu chúng có thể tràn. Tuy nhiên, cách ưa thích trong số này
trường hợp là cấu trúc lại mã như được đề xuất bên dưới để tránh mã hóa mở
số học.)

Ví dụ: không sử dụng ZZ0000ZZ làm đối số, như trong ::

foo = kmalloc(đếm * kích thước, GFP_KERNEL);

Thay vào đó, nên sử dụng dạng 2 yếu tố của bộ cấp phát ::

foo = kmalloc_array(đếm, kích thước, GFP_KERNEL);

Cụ thể, kmalloc() có thể được thay thế bằng kmalloc_array() và
kzalloc() có thể được thay thế bằng kcalloc().

Nếu không có sẵn biểu mẫu 2 yếu tố, trình trợ giúp bão hòa khi tràn sẽ
được sử dụng::

bar = dma_alloc_coherent(dev, array_size(count, size), &dma, GFP_KERNEL);

Một trường hợp phổ biến khác cần tránh là tính toán kích thước của một cấu trúc bằng
một mảng kéo theo các cấu trúc khác, như trong::

tiêu đề = kzalloc(sizeof(ZZ0000ZZ sizeof(*header->item),
			 GFP_KERNEL);

Thay vào đó, hãy sử dụng trợ giúp::

tiêu đề = kzalloc(struct_size(tiêu đề, mục, số lượng), GFP_KERNEL);

.. note:: If you are using struct_size() on a structure containing a zero-length
        or a one-element array as a trailing array member, please refactor such
        array usage and switch to a `flexible array member
        <#zero-length-and-one-element-arrays>`_ instead.

Đối với các phép tính khác, vui lòng soạn thảo việc sử dụng size_mul(),
người trợ giúp size_add() và size_sub(). Ví dụ: trong trường hợp::

foo = krealloc(current_size + chunk_size * (đếm - 3), GFP_KERNEL);

Thay vào đó, hãy sử dụng trợ giúp::

foo = krealloc(size_add(current_size,
				size_mul(chunk_size,
					 size_sub(đếm, 3))), GFP_KERNEL);

Để biết thêm chi tiết, hãy xem thêm array3_size() và flex_array_size(),
cũng như các check_mul_overflow(), check_add_overflow() có liên quan,
nhóm hàm check_sub_overflow() và check_shl_overflow().

simple_strtoll(), simple_strtoll(), simple_strtoul(), simple_strtoull()
----------------------------------------------------------------------
Simple_strtoll(), simple_strtoll(),
Các hàm simple_strtoul() và simple_strtoul()
bỏ qua một cách rõ ràng các lỗi tràn, điều này có thể dẫn đến kết quả không mong muốn
ở người gọi. Kstrtol(), kstrtoll() tương ứng,
Các hàm kstrtoul() và kstrtoul() có xu hướng là
thay thế chính xác, mặc dù lưu ý rằng những thay thế đó yêu cầu chuỗi
NUL hoặc dòng mới đã chấm dứt.

strcpy()
--------
strcpy() thực hiện kiểm tra không giới hạn trên bộ đệm đích. Cái này
có thể dẫn đến tràn tuyến tính vượt quá phần cuối của bộ đệm, dẫn đến
tất cả các loại hành vi sai trái. Trong khi ZZ0000ZZ và nhiều loại khác
cờ trình biên dịch giúp giảm thiểu rủi ro khi sử dụng hàm này, có
không có lý do chính đáng để thêm công dụng mới của chức năng này. Sự thay thế an toàn
là strscpy(), mặc dù vậy phải cẩn thận với mọi trường hợp trả về
giá trị của strcpy() đã được sử dụng, vì strscpy() không trả về con trỏ tới
đích, mà là số lượng byte không phải NUL được sao chép (hoặc âm
errno khi nó cắt ngắn).

strncpy() trên các chuỗi kết thúc NUL
-----------------------------------
Việc sử dụng strncpy() không đảm bảo rằng bộ đệm đích sẽ
NUL bị chấm dứt. Điều này có thể dẫn đến nhiều lỗi tràn đọc tuyến tính và
hành vi sai trái khác do thiếu sự chấm dứt hợp đồng. Nó cũng có miếng đệm NUL
bộ đệm đích nếu nội dung nguồn ngắn hơn bộ đệm
kích thước bộ đệm đích, có thể là một hình phạt hiệu suất không cần thiết
dành cho người gọi chỉ sử dụng chuỗi kết thúc NUL.

Khi đích đến được yêu cầu kết thúc NUL, việc thay thế là
strscpy(), tuy nhiên phải cẩn thận với mọi trường hợp giá trị trả về
của strncpy() đã được sử dụng, vì strscpy() không trả về con trỏ tới
đích, mà là số lượng byte không phải NUL được sao chép (hoặc âm
errno khi nó cắt ngắn). Bất kỳ trường hợp nào vẫn cần đệm NUL nên
thay vào đó hãy sử dụng strscpy_pad().

Nếu người gọi đang sử dụng các chuỗi kết thúc không phải NUL, strtomem() sẽ là
được sử dụng và các đích đến phải được đánh dấu bằng ZZ0000ZZ
thuộc tính để tránh các cảnh báo của trình biên dịch trong tương lai. Đối với những trường hợp vẫn cần
Có thể sử dụng phần đệm NUL, strtomem_pad().

strlcpy()
---------
strlcpy() đọc toàn bộ bộ đệm nguồn trước tiên (vì giá trị trả về
có nghĩa là khớp với strlen()). Lần đọc này có thể vượt quá đích
giới hạn kích thước. Điều này vừa không hiệu quả vừa có thể dẫn đến tình trạng tràn đọc tuyến tính
nếu chuỗi nguồn không bị kết thúc NUL. Sự thay thế an toàn là strscpy(),
mặc dù phải cẩn thận với mọi trường hợp giá trị trả về của strlcpy()
được sử dụng, vì strscpy() sẽ trả về giá trị âm errno khi nó cắt bớt.

công cụ xác định định dạng %p
-------------------
Theo truyền thống, việc sử dụng "%p" trong chuỗi định dạng sẽ dẫn đến địa chỉ thông thường
các lỗ hổng lộ diện trong dmesg, Proc, sysfs, v.v. Thay vì để chúng cho
có thể khai thác được, tất cả việc sử dụng "%p" trong kernel đang được in dưới dạng băm
giá trị, khiến chúng không thể sử dụng được để đánh địa chỉ. Không nên sử dụng "%p" mới
được thêm vào kernel. Đối với địa chỉ văn bản, sử dụng "%pS" có thể tốt hơn,
vì thay vào đó nó tạo ra tên biểu tượng hữu ích hơn. Đối với hầu hết mọi thứ
nếu không, đừng thêm "%p".

Diễn giải ZZ0000ZZ hiện tại của Linus:

- Nếu giá trị băm "%p" là vô nghĩa, hãy tự hỏi liệu con trỏ có
  bản thân nó là quan trọng. Có lẽ nó nên được loại bỏ hoàn toàn?
- Nếu bạn thực sự cho rằng giá trị con trỏ thực sự là quan trọng thì tại sao một số
  trạng thái hệ thống hoặc cấp đặc quyền người dùng được coi là "đặc biệt"? Nếu bạn nghĩ
  bạn có thể biện minh cho điều đó (trong phần bình luận và nhật ký cam kết) đủ tốt để đứng vững
  tùy theo sự xem xét kỹ lưỡng của Linus, có thể bạn có thể sử dụng "%px", cùng với việc đảm bảo
  bạn có quyền hợp lý.

Nếu bạn đang gỡ lỗi điều gì đó mà việc băm "%p" đang gây ra sự cố,
bạn có thể khởi động tạm thời bằng cờ gỡ lỗi "ZZ0000ZZ".

Mảng có độ dài thay đổi (VLA)
-----------------------------
Sử dụng VLA ngăn xếp tạo ra mã máy tệ hơn nhiều so với tĩnh
mảng ngăn xếp có kích thước. Mặc dù những chiếc ZZ0000ZZ không hề tầm thường này cũng đủ lý do để
loại bỏ VLA, chúng cũng là một rủi ro bảo mật. Sự tăng trưởng năng động của ngăn xếp
mảng có thể vượt quá bộ nhớ còn lại trong phân đoạn ngăn xếp. Điều này có thể
dẫn đến sự cố, có thể ghi đè nội dung nhạy cảm ở cuối
ngăn xếp (khi được xây dựng không có ZZ0001ZZ) hoặc ghi đè
bộ nhớ liền kề với ngăn xếp (khi được xây dựng không có ZZ0002ZZ)

Trường hợp chuyển đổi ngầm định rơi vào
---------------------------------
Ngôn ngữ C cho phép các trường hợp chuyển đổi chuyển sang trường hợp tiếp theo
khi thiếu câu lệnh "break" ở cuối trường hợp. Tuy nhiên, điều này
gây ra sự mơ hồ trong mã, vì không phải lúc nào cũng rõ ràng nếu thiếu
break là cố ý hoặc là một lỗi. Ví dụ, nó không rõ ràng chỉ từ
nhìn vào mã nếu ZZ0000ZZ được thiết kế có chủ ý để rơi
thông qua ZZ0001ZZ::

chuyển đổi (giá trị) {
	vỏ STATE_ONE:
		do_something();
	vỏ STATE_TWO:
		do_other();
		phá vỡ;
	mặc định:
		WARN("trạng thái không xác định");
	}

Vì đã có một danh sách dài các sai sót ZZ0000ZZ nên chúng tôi không còn cho phép
sự thất bại ngầm. Để xác định hành vi cố ý phá hoại
trường hợp, chúng tôi đã áp dụng macro từ khóa giả "dự phòng"
mở rộng sang phần mở rộng ZZ0001ZZ của gcc.
(Khi cú pháp C17/C18 ZZ0002ZZ được hỗ trợ phổ biến hơn bởi
Trình biên dịch C, máy phân tích tĩnh và IDE, chúng ta có thể chuyển sang sử dụng cú pháp đó
cho từ khóa giả macro.)

Tất cả các khối switch/case phải kết thúc bằng một trong:

* phá vỡ;
* thất bại;
* Tiếp tục;
* đi tới <nhãn>;
* trả về [biểu thức];

Mảng có độ dài bằng 0 và một phần tử
----------------------------------
Có một nhu cầu thường xuyên trong kernel là cung cấp một cách để khai báo có
một tập hợp các phần tử theo sau có kích thước động trong một cấu trúc. Mã hạt nhân
nên luôn luôn sử dụng ZZ0000ZZ
cho những trường hợp này. Kiểu cũ hơn của mảng một phần tử hoặc có độ dài bằng 0 sẽ
không còn được sử dụng nữa.

Trong mã C cũ hơn, các phần tử ở cuối có kích thước động được thực hiện bằng cách chỉ định
mảng một phần tử ở cuối cấu trúc::

cấu trúc một cái gì đó {
                số lượng size_t;
                các mục struct foo [1];
        };

Điều này dẫn đến việc tính toán kích thước dễ vỡ thông qua sizeof() (cần phải
xóa kích thước của phần tử cuối để có kích thước chính xác
“tiêu đề”). MỘT ZZ0000ZZ
được giới thiệu để cho phép các mảng có độ dài bằng 0, để tránh những kiểu này
vấn đề về kích thước::

cấu trúc một cái gì đó {
                số lượng size_t;
                cấu trúc foo mục [0];
        };

Nhưng điều này dẫn đến các vấn đề khác và không giải quyết được một số vấn đề được chia sẻ bởi
cả hai kiểu, như không thể phát hiện khi một mảng như vậy vô tình
được sử dụng _not_ ở cuối cấu trúc (điều này có thể xảy ra trực tiếp hoặc
khi một cấu trúc như vậy ở trong các liên kết, cấu trúc của các cấu trúc, v.v.).

C99 đã giới thiệu "các thành viên mảng linh hoạt", thiếu kích thước số cho
khai báo mảng hoàn toàn ::

cấu trúc một cái gì đó {
                số lượng size_t;
                struct foo mục [];
        };

Đây là cách kernel mong đợi các phần tử theo sau có kích thước động
được khai báo. Nó cho phép trình biên dịch tạo ra lỗi khi
Mảng linh hoạt không xuất hiện cuối cùng trong cấu trúc, giúp ngăn ngừa
một loại ZZ0000ZZ nào đó
lỗi vô tình được đưa vào cơ sở mã. Nó cũng cho phép
trình biên dịch để phân tích chính xác kích thước mảng (thông qua sizeof(),
ZZ0001ZZ và ZZ0002ZZ). Ví dụ,
không có cơ chế nào cảnh báo chúng ta rằng việc áp dụng sau đây của
Toán tử sizeof() đối với mảng có độ dài bằng 0 luôn cho kết quả bằng 0::

cấu trúc một cái gì đó {
                số lượng size_t;
                cấu trúc foo mục [0];
        };

cấu trúc một cái gì đó *ví dụ;

instance = kmalloc(struct_size(instance, items, count), GFP_KERNEL);
        dụ->đếm = đếm;

size = sizeof(instance->items) * instance->count;
        memcpy(instance->items, source, size);

Ở dòng mã cuối cùng ở trên, ZZ0000ZZ hóa ra là ZZ0001ZZ, khi người ta có thể
gần đây đã nghĩ rằng nó đại diện cho tổng kích thước tính bằng byte của bộ nhớ động
được phân bổ cho mảng cuối ZZ0002ZZ. Dưới đây là một vài ví dụ về điều này
vấn đề: ZZ0003ZZ,
ZZ0004ZZ.
Thay vào đó, ZZ0005ZZ,
vì vậy mọi hành vi lạm dụng các toán tử đó sẽ được phát hiện ngay lập tức tại thời điểm xây dựng.

Đối với mảng một phần tử, người ta phải nhận thức sâu sắc rằng ZZ0000ZZ,
do đó chúng góp phần vào kích thước của cấu trúc bao quanh. Điều này dễ xảy ra
bị lỗi mỗi khi người ta muốn tính tổng kích thước của bộ nhớ động
để phân bổ cho một cấu trúc chứa một mảng thuộc loại này với tư cách là thành viên ::

cấu trúc một cái gì đó {
                số lượng size_t;
                các mục struct foo [1];
        };

cấu trúc một cái gì đó *ví dụ;

instance = kmalloc(struct_size(instance, items, count - 1), GFP_KERNEL);
        dụ->đếm = đếm;

size = sizeof(instance->items) * instance->count;
        memcpy(instance->items, source, size);

Trong ví dụ trên, chúng ta phải nhớ tính toán ZZ0000ZZ khi sử dụng
trình trợ giúp struct_size(), nếu không chúng ta sẽ --vô tình-- được phân bổ
bộ nhớ cho quá nhiều đối tượng ZZ0001ZZ. Cách sạch nhất và ít xảy ra lỗi nhất
để thực hiện điều này là thông qua việc sử dụng ZZ0002ZZ, cùng với
Người trợ giúp struct_size() và flex_array_size()::

cấu trúc một cái gì đó {
                số lượng size_t;
                struct foo mục [];
        };

cấu trúc một cái gì đó *ví dụ;

instance = kmalloc(struct_size(instance, items, count), GFP_KERNEL);
        dụ->đếm = đếm;

memcpy(instance->items, source, flex_array_size(instance, items, instance->count));

Có hai trường hợp thay thế đặc biệt trong đó DECLARE_FLEX_ARRAY()
người trợ giúp cần được sử dụng. (Lưu ý rằng nó được đặt tên là __DECLARE_FLEX_ARRAY() cho
sử dụng trong các tiêu đề UAPI.) Những trường hợp đó là khi mảng linh hoạt là
một mình trong một cấu trúc hoặc là một phần của một liên minh. Những thứ này không được C99 cho phép
đặc điểm kỹ thuật, nhưng không có lý do kỹ thuật (như có thể thấy bởi cả hai
việc sử dụng các mảng như vậy ở những nơi đó và cách giải quyết vấn đề đó
DECLARE_FLEX_ARRAY() sử dụng). Ví dụ: để chuyển đổi cái này::

cấu trúc một cái gì đó {
		...
công đoàn {
			cấu trúc type1 one[0];
			cấu trúc type2 two[0];
		};
	};

Người trợ giúp phải được sử dụng::

cấu trúc một cái gì đó {
		...
công đoàn {
			DECLARE_FLEX_ARRAY(struct type1, one);
			DECLARE_FLEX_ARRAY(struct type2, two);
		};
	};

Bài tập kmalloc được mã hóa mở cho các đối tượng cấu trúc
-------------------------------------------------
Việc thực hiện các nhiệm vụ phân bổ kmalloc()-gia đình được mã hóa mở sẽ ngăn cản
kernel (và trình biên dịch) không thể kiểm tra kiểu của
biến được chỉ định, điều này hạn chế mọi sự xem xét nội tâm có liên quan
có thể giúp căn chỉnh, bao bọc xung quanh hoặc làm cứng thêm. các
kmalloc_obj()-họ macro cung cấp khả năng xem xét nội tâm này, có thể
được sử dụng cho các mẫu mã phổ biến cho đối tượng đơn, mảng và linh hoạt
phân bổ. Ví dụ: các bài tập được mã hóa mở này::

ptr = kmalloc(sizeof(*ptr), gfp);
	ptr = kzalloc(sizeof(*ptr), gfp);
	ptr = kmalloc_array(count, sizeof(*ptr), gfp);
	ptr = kcalloc(đếm, sizeof(*ptr), gfp);
	ptr = kmalloc(struct_size(ptr, flex_member, count), gfp);
	ptr = kmalloc(sizeof(struct foo, gfp);

lần lượt trở thành::

ptr = kmalloc_obj(*ptr, gfp);
	ptr = kzalloc_obj(*ptr, gfp);
	ptr = kmalloc_objs(*ptr, count, gfp);
	ptr = kzalloc_objs(*ptr, count, gfp);
	ptr = kmalloc_flex(*ptr, flex_member, count, gfp);
	__auto_type ptr = kmalloc_obj(struct foo, gfp);

Nếu ZZ0000ZZ được chú thích bằng __counted_by(), việc phân bổ
sẽ tự động thất bại nếu ZZ0001ZZ lớn hơn mức tối đa
giá trị đại diện có thể được lưu trữ trong thành viên truy cập được liên kết
với ZZ0002ZZ.