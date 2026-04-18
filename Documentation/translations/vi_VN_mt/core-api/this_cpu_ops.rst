.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/this_cpu_ops.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
hoạt động this_cpu
===================

:Tác giả: Christoph Lameter, ngày 4 tháng 8 năm 2014
:Tác giả: Pranith Kumar, ngày 2 tháng 8 năm 2014

Hoạt động this_cpu là một cách tối ưu hóa quyền truy cập vào mỗi cpu
các biến liên quan đến bộ xử lý thực thi ZZ0000ZZ. Đây là
được thực hiện thông qua việc sử dụng các thanh ghi phân đoạn (hoặc một thanh ghi chuyên dụng trong đó
CPU đã lưu trữ vĩnh viễn phần đầu của vùng trên mỗi CPU trong một thời gian
bộ xử lý cụ thể).

Hoạt động this_cpu thêm phần bù biến số trên mỗi cpu vào bộ xử lý
cụ thể trên mỗi cơ sở cpu và mã hóa hoạt động đó trong hướng dẫn
hoạt động trên mỗi biến cpu.

Điều này có nghĩa là không có vấn đề về tính nguyên tử giữa việc tính toán
offset và thao tác trên dữ liệu. Vì vậy nó không phải là
cần thiết để vô hiệu hóa quyền ưu tiên hoặc các ngắt để đảm bảo rằng
bộ xử lý không bị thay đổi giữa việc tính toán địa chỉ và
thao tác trên dữ liệu.

Các hoạt động đọc-sửa-ghi được đặc biệt quan tâm. Thường xuyên
bộ xử lý có các lệnh có độ trễ đặc biệt thấp hơn có thể hoạt động
không có chi phí đồng bộ hóa thông thường nhưng vẫn cung cấp một số
loại đảm bảo tính nguyên tử thoải mái. Ví dụ x86 có thể thực thi
Các lệnh RMW (Đọc sửa đổi ghi) giống như inc/dec/cmpxchg mà không có
tiền tố khóa và hình phạt độ trễ liên quan.

Việc truy cập vào biến không có tiền tố khóa sẽ không được đồng bộ hóa nhưng
đồng bộ hóa là không cần thiết vì chúng tôi đang xử lý trên mỗi CPU
dữ liệu cụ thể cho bộ xử lý hiện đang thực thi. Chỉ có hiện tại
bộ xử lý sẽ truy cập vào biến đó và do đó không có
vấn đề tương tranh với các bộ xử lý khác trong hệ thống.

Xin lưu ý rằng việc truy cập của bộ xử lý từ xa tới một khu vực trên mỗi CPU là
các tình huống đặc biệt và có thể ảnh hưởng đến hiệu suất và/hoặc tính chính xác
(thao tác ghi từ xa) của các hoạt động RMW cục bộ thông qua this_cpu_*.

Công dụng chính của thao tác this_cpu là tối ưu hóa bộ đếm
hoạt động.

Các thao tác this_cpu() sau đây có ngụ ý bảo vệ quyền ưu tiên
được xác định. Những thao tác này có thể được sử dụng mà không cần lo lắng về
quyền ưu tiên và ngắt::

this_cpu_read(pcp)
	this_cpu_write(pcp, val)
	this_cpu_add(pcp, val)
	this_cpu_and(pcp, val)
	this_cpu_or(pcp, val)
	this_cpu_add_return(pcp, val)
	this_cpu_xchg(pcp, nval)
	this_cpu_cmpxchg(pcp, hình bầu dục, nval)
	this_cpu_sub(pcp, val)
	this_cpu_inc(pcp)
	this_cpu_dec(pcp)
	this_cpu_sub_return(pcp, val)
	this_cpu_inc_return(pcp)
	this_cpu_dec_return(pcp)


Hoạt động bên trong của hoạt động this_cpu
------------------------------------

Trên x86, các thanh ghi phân đoạn fs: hoặc gs: chứa cơ sở của
mỗi khu vực cpu. Sau đó có thể chỉ cần sử dụng ghi đè phân đoạn
để di chuyển địa chỉ tương đối trên mỗi CPU sang khu vực thích hợp trên mỗi CPU cho
bộ xử lý. Vì vậy, việc di chuyển đến cơ sở mỗi CPU được mã hóa trong
lệnh thông qua tiền tố thanh ghi phân đoạn.

Ví dụ::

DEFINE_PER_CPU(int, x);
	int z;

z = this_cpu_read(x);

kết quả trong một hướng dẫn duy nhất::

mov rìu, gs:[x]

thay vì một chuỗi tính toán địa chỉ và sau đó tìm nạp
từ địa chỉ đó xảy ra với các hoạt động trên mỗi CPU. trước đây
this_cpu_ops trình tự như vậy cũng yêu cầu tắt/bật trước
ngăn kernel di chuyển luồng sang bộ xử lý khác
trong khi việc tính toán được thực hiện.

Hãy xem xét thao tác this_cpu sau::

this_cpu_inc(x)

Kết quả trên dẫn đến lệnh đơn sau đây (không có tiền tố khóa!)::

inc gs:[x]

thay vì các thao tác bắt buộc sau đây nếu không có phân đoạn
đăng ký::

int *y;
	intcpu;

cpu = get_cpu();
	y = per_cpu_ptr(&x, cpu);
	(*y)++;
	put_cpu();

Lưu ý rằng các thao tác này chỉ có thể được sử dụng trên mỗi dữ liệu CPU
dành riêng cho một bộ xử lý cụ thể. Không vô hiệu hóa quyền ưu tiên trong
mã xung quanh this_cpu_inc() sẽ chỉ đảm bảo rằng một trong những
mỗi bộ đếm CPU được tăng lên một cách chính xác. Tuy nhiên, không có
đảm bảo rằng hệ điều hành sẽ không di chuyển tiến trình trực tiếp trước hoặc
sau khi lệnh this_cpu được thực thi. Nói chung điều này có nghĩa là
giá trị của các bộ đếm riêng cho mỗi bộ xử lý là
vô nghĩa. Tổng của tất cả các bộ đếm trên mỗi CPU là giá trị duy nhất
đó là điều đáng quan tâm.

Các biến trên mỗi CPU được sử dụng vì lý do hiệu suất. Bộ nhớ đệm bị trả lại
có thể tránh được các dòng nếu nhiều bộ xử lý đồng thời đi qua
đường dẫn mã giống nhau.  Vì mỗi bộ xử lý có mỗi CPU riêng
các biến không có cập nhật dòng bộ đệm đồng thời diễn ra. Cái giá đó
phải trả tiền cho việc tối ưu hóa này là cần phải tăng số lượng CPU trên mỗi CPU
bộ đếm khi cần giá trị của bộ đếm.


Hoạt động đặc biệt
------------------

::

y = this_cpu_ptr(&x)

Lấy phần bù của một biến trên mỗi CPU (&x!) Và trả về địa chỉ
của biến mỗi CPU thuộc về biến hiện đang thực thi
bộ xử lý.  this_cpu_ptr tránh nhiều bước thông thường
Yêu cầu trình tự get_cpu/put_cpu. Không có số bộ xử lý
có sẵn. Thay vào đó, phần bù của vùng cục bộ trên mỗi CPU chỉ đơn giản là
được thêm vào phần bù trên mỗi cpu.

Lưu ý rằng thao tác này chỉ có thể được sử dụng trong các đoạn mã nơi
smp_processor_id() có thể được sử dụng, ví dụ, khi quyền ưu tiên đã được thực hiện
bị vô hiệu hóa. Con trỏ sau đó được sử dụng để truy cập dữ liệu cục bộ trên mỗi CPU trong một
phần quan trọng. Khi quyền ưu tiên được kích hoạt lại, con trỏ này thường là
không còn hữu ích vì nó có thể không còn trỏ đến dữ liệu CPU của
bộ xử lý hiện tại.

Các trường hợp đặc biệt trong đó việc lấy con trỏ trên mỗi CPU trong
mã ưu tiên được xử lý bằng raw_cpu_ptr(), nhưng những trường hợp sử dụng như vậy cần
để xử lý các trường hợp hai CPU khác nhau truy cập vào cùng một CPU trên mỗi CPU
biến, có thể là biến CPU thứ ba.  Những trường hợp sử dụng này là
thường là tối ưu hóa hiệu suất.  Ví dụ: SRCU thực hiện một cặp
bộ đếm dưới dạng một cặp biến per-CPU và rcu_read_lock_nmisafe()
sử dụng raw_cpu_ptr() để lấy con trỏ tới bộ đếm của CPU và sử dụng
Atomic_inc_long() để xử lý việc di chuyển giữa raw_cpu_ptr() và
nguyên tử_inc_long().

Mỗi biến số và độ lệch CPU
-----------------------------

Mỗi biến cpu có ZZ0000ZZ ở đầu mỗi cpu
khu vực. Họ không có địa chỉ mặc dù trông giống như vậy trong
mã. Phần bù không thể được hủy đăng ký trực tiếp. Phần bù phải là
được thêm vào một con trỏ cơ sở của vùng trên mỗi CPU của bộ xử lý để
tạo thành một địa chỉ hợp lệ.

Do đó, việc sử dụng x hoặc &x ngoài ngữ cảnh của mỗi CPU
các hoạt động không hợp lệ và thường sẽ được xử lý như NULL
sự hủy bỏ tham chiếu con trỏ.

::

DEFINE_PER_CPU(int, x);

Trong bối cảnh hoạt động trên mỗi CPU, điều trên ngụ ý rằng x là một
biến CPU. Hầu hết các hoạt động this_cpu đều có biến cpu.

::

int __percpu *p = &x;

&x và do đó p là ZZ0000ZZ của biến trên mỗi cpu. this_cpu_ptr()
lấy phần bù của một biến trên mỗi cpu, điều này làm cho điều này trông hơi giống
lạ lùng.


Hoạt động trên một trường của cấu trúc mỗi CPU
--------------------------------------------

Giả sử chúng ta có cấu trúc percpu ::

cấu trúc s {
		int n,m;
	};

DEFINE_PER_CPU(cấu trúc s, p);


Hoạt động trên các lĩnh vực này rất đơn giản::

this_cpu_inc(pm)

z = this_cpu_cmpxchg(p.m, 0, 1);


Nếu chúng ta có phần bù cho struct s::

cấu trúc s __percpu *ps = &p;

this_cpu_dec(ps->m);

z = this_cpu_inc_return(ps->n);


Việc tính toán con trỏ có thể yêu cầu sử dụng this_cpu_ptr()
nếu sau này chúng ta không sử dụng this_cpu để thao tác các trường ::

cấu trúc s *pp;

pp = this_cpu_ptr(&p);

pp->m--;

z = pp->n++;


Các biến thể của this_cpu ops
------------------------

ops this_cpu bị gián đoạn an toàn. Một số kiến trúc không hỗ trợ
những hoạt động này trên mỗi CPU cục bộ. Trong trường hợp đó hoạt động phải được
được thay thế bằng mã vô hiệu hóa các ngắt, sau đó thực hiện các thao tác
được đảm bảo là nguyên tử và sau đó kích hoạt lại các ngắt. Đang làm
như vậy là đắt tiền. Nếu có lý do khác khiến bộ lập lịch không thể
thay đổi bộ xử lý mà chúng tôi đang thực thi thì không có lý do gì để
vô hiệu hóa các ngắt. Vì mục đích đó, các thao tác __this_cpu sau đây
được cung cấp.

Các hoạt động này không đảm bảo chống lại các ngắt đồng thời hoặc
quyền ưu tiên. Nếu biến trên mỗi CPU không được sử dụng trong ngữ cảnh ngắt
và bộ lập lịch không thể ưu tiên thì chúng an toàn. Nếu có sự gián đoạn
vẫn xảy ra trong khi một hoạt động đang diễn ra và nếu ngắt quá
sửa đổi biến, thì các hành động RMW không thể được đảm bảo là
an toàn::

__this_cpu_read(pcp)
	__this_cpu_write(pcp, val)
	__this_cpu_add(pcp, val)
	__this_cpu_and(pcp, val)
	__this_cpu_or(pcp, val)
	__this_cpu_add_return(pcp, val)
	__this_cpu_xchg(pcp, nval)
	__this_cpu_cmpxchg(pcp, hình bầu dục, nval)
	__this_cpu_sub(pcp, val)
	__this_cpu_inc(pcp)
	__this_cpu_dec(pcp)
	__this_cpu_sub_return(pcp, val)
	__this_cpu_inc_return(pcp)
	__this_cpu_dec_return(pcp)


Sẽ tăng x và sẽ không chuyển sang mã vô hiệu hóa
ngắt trên các nền tảng không thể đạt được tính nguyên tử thông qua
tái định vị địa chỉ và thao tác Đọc-Sửa đổi-Ghi trong cùng một
hướng dẫn.


&this_cpu_ptr(pp)->n vs this_cpu_ptr(&pp->n)
--------------------------------------------

Thao tác đầu tiên lấy phần bù và tạo thành một địa chỉ, sau đó
thêm phần bù của trường n. Điều này có thể dẫn đến hai lần thêm
hướng dẫn được đưa ra bởi trình biên dịch.

Cái thứ hai trước tiên cộng hai phần bù và sau đó thực hiện
tái định cư.  IMHO dạng thứ hai trông gọn gàng hơn và có thời gian dễ dàng hơn
với (). Hình thức thứ hai cũng phù hợp với cách
this_cpu_read() và bạn bè được sử dụng.


Truy cập từ xa vào dữ liệu trên mỗi CPU
------------------------------

Cấu trúc dữ liệu trên mỗi CPU được thiết kế để chỉ sử dụng bởi một CPU.
Nếu bạn sử dụng các biến như dự định, this_cpu_ops() được đảm bảo
là "nguyên tử" vì không CPU nào khác có quyền truy cập vào các cấu trúc dữ liệu này.

Có những trường hợp đặc biệt mà bạn có thể cần truy cập dữ liệu trên mỗi CPU
các cấu trúc từ xa. Việc truy cập đọc từ xa thường an toàn
và điều đó thường được thực hiện để tóm tắt các bộ đếm. Truy cập ghi từ xa
điều gì đó có thể có vấn đề vì this_cpu ops không
có ngữ nghĩa khóa. Việc ghi từ xa có thể can thiệp vào this_cpu
Hoạt động RMW.

Việc truy cập ghi từ xa vào cấu trúc dữ liệu percpu không được khuyến khích
trừ khi thực sự cần thiết. Vui lòng cân nhắc sử dụng IPI để thức dậy
CPU từ xa và thực hiện cập nhật theo vùng CPU của nó.

Để truy cập cấu trúc dữ liệu trên mỗi CPU từ xa, thường là per_cpu_ptr()
chức năng được sử dụng::


DEFINE_PER_CPU(dữ liệu cấu trúc, dữ liệu);

dữ liệu cấu trúc *p = per_cpu_ptr(&datap, cpu);

Điều này cho thấy rõ rằng chúng tôi đã sẵn sàng truy cập percpu
khu vực từ xa.

Bạn cũng có thể thực hiện các thao tác sau để chuyển đổi phần bù dữ liệu thành địa chỉ ::

dữ liệu cấu trúc *p = this_cpu_ptr(&datap);

nhưng, việc chuyển các con trỏ được tính toán thông qua this_cpu_ptr sang các CPU khác là
bất thường và nên tránh.

Truy cập từ xa thường chỉ để đọc trạng thái của CPU khác
mỗi dữ liệu cpu. Quyền truy cập ghi có thể gây ra các vấn đề đặc biệt do
yêu cầu đồng bộ hóa thoải mái cho các hoạt động this_cpu.

Một ví dụ minh họa một số mối quan tâm với thao tác ghi là
tình huống sau đây xảy ra do có hai biến trên mỗi CPU
chia sẻ một dòng bộ đệm nhưng tính năng đồng bộ hóa thoải mái được áp dụng cho
chỉ có một quá trình cập nhật dòng bộ đệm.

Hãy xem xét ví dụ sau::


kiểm tra cấu trúc {
		nguyên tử_t a;
		int b;
	};

DEFINE_PER_CPU(kiểm tra cấu trúc, onecacheline);

Có một số lo ngại về điều gì sẽ xảy ra nếu trường 'a' được cập nhật
từ xa từ một bộ xử lý và bộ xử lý cục bộ sẽ sử dụng this_cpu ops
để cập nhật trường b. Cần thận trọng để việc truy cập đồng thời vào
tránh dữ liệu trong cùng một dòng bộ đệm. Đồng bộ hóa cũng tốn kém
có thể cần thiết. Thay vào đó, IPI thường được khuyến nghị trong các trường hợp như vậy
của một lệnh ghi từ xa vào vùng CPU của bộ xử lý khác.

Ngay cả trong trường hợp việc ghi từ xa hiếm khi xảy ra, vui lòng lưu ý
lưu ý rằng việc ghi từ xa sẽ xóa dòng bộ đệm khỏi bộ xử lý
rất có thể sẽ truy cập nó. Nếu bộ xử lý thức dậy và tìm thấy một
thiếu dòng bộ đệm cục bộ của từng vùng CPU, hiệu suất của nó và do đó
thời gian thức dậy sẽ bị ảnh hưởng.
