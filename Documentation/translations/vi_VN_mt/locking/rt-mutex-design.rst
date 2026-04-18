.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/locking/rt-mutex-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Thiết kế triển khai RT-mutex
=================================

Bản quyền (c) 2006 Steven Rostedt

Được cấp phép theo Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2


Tài liệu này cố gắng mô tả thiết kế triển khai rtmutex.c.
Nó không mô tả lý do tại sao rtmutex.c tồn tại. Để biết điều đó xin vui lòng xem
Tài liệu/khóa/rt-mutex.rst.  Mặc dù tài liệu này giải thích các vấn đề
điều đó xảy ra mà không cần mã này, nhưng đó là khái niệm có thể hiểu được
mã thực sự đang làm gì.

Mục tiêu của tài liệu này là giúp người khác hiểu được mức độ ưu tiên
thuật toán kế thừa (PI) được sử dụng cũng như lý do
các quyết định được đưa ra để thực hiện PI theo cách đã được thực hiện.


Đảo ngược ưu tiên không giới hạn
----------------------------

Đảo ngược mức ưu tiên là khi một tiến trình có mức ưu tiên thấp hơn thực thi trong khi một tiến trình có mức ưu tiên cao hơn được thực hiện.
tiến trình ưu tiên muốn chạy.  Điều này xảy ra vì nhiều lý do và
hầu hết thời gian nó không thể được giúp đỡ.  Bất cứ lúc nào một quy trình có mức độ ưu tiên cao muốn
để sử dụng tài nguyên mà quy trình có mức độ ưu tiên thấp hơn (ví dụ: mutex),
tiến trình có mức ưu tiên cao hơn phải đợi cho đến khi tiến trình có mức ưu tiên thấp hơn được thực hiện
với tài nguyên.  Đây là một sự đảo ngược ưu tiên.  Điều chúng tôi muốn ngăn chặn
được gọi là đảo ngược ưu tiên không giới hạn.  Đó là khi cao
quy trình ưu tiên bị ngăn không cho chạy bởi quy trình có mức ưu tiên thấp hơn đối với
một khoảng thời gian không xác định.

Ví dụ kinh điển về đảo ngược mức độ ưu tiên không giới hạn là khi bạn có ba
các quy trình, hãy gọi chúng là các quy trình A, B và C, trong đó A là quy trình cao nhất
quá trình ưu tiên, C là thấp nhất và B ở giữa. A cố gắng lấy một cái khóa
mà C sở hữu và phải đợi và cho C chạy để giải phóng khóa. Nhưng trong
trong khi đó, B thực thi và vì B có mức độ ưu tiên cao hơn C nên nó ưu tiên C,
nhưng bằng cách đó, trên thực tế, nó đang ưu tiên cho A, quy trình có mức độ ưu tiên cao hơn.
Bây giờ không biết A sẽ ngủ đợi C bao lâu
để mở khóa, bởi vì theo tất cả những gì chúng ta biết, B là một con lợn CPU và sẽ
không bao giờ cho C cơ hội mở khóa.  Đây được gọi là ưu tiên không giới hạn
đảo ngược.

Đây là một chút nghệ thuật ASCII để thể hiện vấn đề ::

lấy khóa L1 (thuộc sở hữu của C)
       |
  Một ---+
          C bị B chiếm trước
            |
  C +----+

B +-------->
                  B bây giờ ngăn không cho A chạy.


Kế thừa ưu tiên (PI)
-------------------------

Có một số cách để giải quyết vấn đề này, nhưng những cách khác nằm ngoài phạm vi
cho tài liệu này.  Ở đây chúng tôi chỉ thảo luận về PI.

PI là nơi một tiến trình kế thừa mức độ ưu tiên của một tiến trình khác nếu tiến trình kia
khối quy trình trên khóa thuộc sở hữu của quy trình hiện tại.  Để làm việc này dễ dàng hơn
để hiểu, hãy sử dụng lại ví dụ trước, với các quy trình A, B và C.

Lần này, khi A chặn trên khóa do C sở hữu, C sẽ kế thừa mức độ ưu tiên
của A. Vì vậy, bây giờ nếu B có thể chạy được, nó sẽ không chiếm ưu thế trước C, vì C hiện có
mức độ ưu tiên cao của A. Ngay khi C nhả khóa, nó sẽ mất
ưu tiên được kế thừa và sau đó A có thể tiếp tục với tài nguyên mà C có.

Thuật ngữ
-----------

Ở đây tôi giải thích một số thuật ngữ được sử dụng trong tài liệu này để giúp mô tả
thiết kế được sử dụng để thực hiện PI.

chuỗi PI
         - Chuỗi PI là một chuỗi các khóa và quy trình được sắp xếp theo thứ tự gây ra
           các quy trình kế thừa các ưu tiên từ quy trình trước đó
           bị chặn trên một trong các ổ khóa của nó.  Điều này được mô tả chi tiết hơn
           sau này trong tài liệu này.

mutex
         - Trong tài liệu này, để phân biệt với các khóa thực hiện
           PI và khóa xoay được sử dụng trong mã PI kể từ bây giờ
           khóa PI sẽ được gọi là mutex.

khóa
         - Trong tài liệu này từ bây giờ tôi sẽ sử dụng thuật ngữ khóa khi
           đề cập đến khóa xoay được sử dụng để bảo vệ các bộ phận của PI
           thuật toán.  Các khóa này vô hiệu hóa quyền ưu tiên cho UP (khi
           CONFIG_PREEMPT được bật) và trên SMP ngăn nhiều CPU khỏi
           vào các phần quan trọng cùng một lúc.

khóa quay
         - Tương tự như khóa trên.

bồi bàn
         - Waiter là một cấu trúc được lưu trữ trên ngăn xếp của một đối tượng bị chặn
           quá trình.  Vì phạm vi của người phục vụ nằm trong mã dành cho
           một tiến trình đang bị chặn trên mutex, bạn có thể phân bổ
           người phục vụ trên ngăn xếp của tiến trình (biến cục bộ).  Cái này
           cấu trúc giữ một con trỏ tới tác vụ, cũng như mutex
           nhiệm vụ bị chặn.  Nó cũng có cấu trúc nút rbtree để
           đặt nhiệm vụ vào cây bồi bàn của một mutex cũng như
           pi_waiters rbtree của tác vụ chủ sở hữu mutex (được mô tả bên dưới).

bồi bàn đôi khi được sử dụng để chỉ nhiệm vụ đang chờ
           trên một mutex. Điều này giống như người phục vụ-> nhiệm vụ.

bồi bàn
         - Danh sách các tiến trình bị chặn trên mutex.

bồi bàn hàng đầu
         - Tiến trình có mức độ ưu tiên cao nhất đang chờ trên một mutex cụ thể.

bồi bàn pi hàng đầu
              - Quá trình có mức độ ưu tiên cao nhất đang chờ trên một trong các mutex
                mà một tiến trình cụ thể sở hữu.

Lưu ý:
       nhiệm vụ và quy trình được sử dụng thay thế cho nhau trong tài liệu này, chủ yếu là để
       phân biệt giữa hai quá trình đang được mô tả cùng nhau.


chuỗi PI
--------

Chuỗi PI là danh sách các tiến trình và mutex có thể gây ra mức độ ưu tiên
sự kế thừa diễn ra.  Nhiều chuỗi có thể hội tụ, nhưng một chuỗi
sẽ không bao giờ phân kỳ, vì một quá trình không thể bị chặn trên nhiều hơn một
mutex tại một thời điểm.

Ví dụ::

Quy trình: A, B, C, D, E
   Mutexes: L1, L2, L3, L4

A sở hữu: L1
           B bị chặn trên L1
           B sở hữu L2
                  C bị chặn trên L2
                  C sở hữu L3
                         D bị chặn trên L3
                         D sở hữu L4
                                E bị chặn trên L4

Chuỗi sẽ là::

E->L4->D->L3->C->L2->B->L1->A

Để chỉ ra nơi hai chuỗi hợp nhất, chúng ta có thể thêm một quy trình F khác và
một mutex L5 khác trong đó B sở hữu L5 và F bị chặn trên mutex L5.

Chuỗi cho F sẽ là::

F->L5->B->L1->A

Vì một tiến trình có thể sở hữu nhiều hơn một mutex nhưng không bao giờ bị chặn trên nhiều hơn
một, các chuỗi hợp nhất.

Ở đây chúng tôi hiển thị cả hai chuỗi::

E->L4->D->L3->C->L2-+
                       |
                       +->B->L1->A
                       |
                 F->L5-+

Để PI hoạt động, các quy trình ở đầu bên phải của các chuỗi này (hoặc chúng tôi có thể
cũng gọi là Top of the chain) phải có mức độ ưu tiên bằng hoặc cao hơn
hơn các quá trình ở bên trái hoặc bên dưới trong chuỗi.

Ngoài ra, vì một mutex có thể có nhiều tiến trình bị chặn trên đó nên chúng ta có thể
có nhiều chuỗi hợp nhất tại mutexes.  Nếu chúng ta thêm một tiến trình G khác thì đó là
bị chặn trên mutex L2::

G->L2->B->L1->A

Và một lần nữa, để cho thấy điều này có thể phát triển như thế nào, tôi sẽ chỉ ra các chuỗi hợp nhất
lần nữa::

E->L4->D->L3->C-+
                   +->L2-+
                   ZZ0000ZZ
                 G-+ +->B->L1->A
                         |
                   F->L5-+

Nếu tiến trình G có mức độ ưu tiên cao nhất trong chuỗi thì tất cả các tác vụ sẽ được thực hiện
chuỗi (A và B trong ví dụ này), phải tăng mức độ ưu tiên của chúng
đối với G.

Cây bồi bàn Mutex
------------------

Mỗi mutex đều theo dõi tất cả những người phục vụ bị chặn. các
mutex có rbtree để ưu tiên lưu trữ những người phục vụ này.  Cây này được bảo vệ
bởi một khóa xoay nằm trong cấu trúc của mutex. Khóa này được gọi là
chờ_lock.


Cây PI nhiệm vụ
------------

Để theo dõi các chuỗi PI, mỗi quy trình có cây PI rbtree riêng.  Đây là
một cây gồm tất cả những người phục vụ hàng đầu của các mutex được sở hữu bởi quy trình.
Lưu ý rằng cây này chỉ chứa những người phục vụ hàng đầu chứ không phải tất cả những người phục vụ
bị chặn trên mutexes thuộc sở hữu của quá trình.

Phần trên cùng của cây PI của nhiệm vụ luôn là nhiệm vụ có mức độ ưu tiên cao nhất
đang chờ trên một mutex thuộc sở hữu của tác vụ.  Vì vậy nếu nhiệm vụ có
được kế thừa mức độ ưu tiên, nó sẽ luôn là mức độ ưu tiên của nhiệm vụ được thực hiện
ở trên ngọn cây này.

Cây này được lưu trữ trong cấu trúc nhiệm vụ của một tiến trình dưới dạng rbtree được gọi là
pi_waiters.  Nó cũng được bảo vệ bởi một khóa xoay trong cấu trúc nhiệm vụ,
được gọi là pi_lock.  Khóa này cũng có thể được thực hiện trong bối cảnh ngắt, vì vậy khi
khóa pi_lock, các ngắt phải được tắt.


Độ sâu của chuỗi PI
---------------------

Độ sâu tối đa của chuỗi PI không linh hoạt và thực tế có thể
được xác định.  Nhưng rất phức tạp để tìm ra nó, vì nó phụ thuộc vào tất cả
sự lồng nhau của mutexes.  Hãy xem ví dụ chúng ta có 3 mutexes,
L1, L2 và L3 và bốn hàm riêng biệt func1, func2, func3 và func4.
Phần sau đây hiển thị thứ tự khóa L1->L2->L3, nhưng thực tế có thể không
được lồng trực tiếp theo cách đó::

void func1(void)
  {
	mutex_lock(L1);

/*làm bất cứ điều gì*/

mutex_unlock(L1);
  }

void func2(void)
  {
	mutex_lock(L1);
	mutex_lock(L2);

/*làm gì đó*/

mutex_unlock(L2);
	mutex_unlock(L1);
  }

void func3(void)
  {
	mutex_lock(L2);
	mutex_lock(L3);

/*làm việc khác*/

mutex_unlock(L3);
	mutex_unlock(L2);
  }

void func4(void)
  {
	mutex_lock(L3);

/*làm lại điều gì đó*/

mutex_unlock(L3);
  }

Bây giờ chúng tôi thêm 4 quy trình chạy riêng từng chức năng này.
Các tiến trình A, B, C và D chạy các hàm func1, func2, func3 và func4
tương ứng và sao cho D chạy đầu tiên và A chạy cuối cùng.  Với D được ưu tiên
trong func4 trong khu vực "làm lại", chúng tôi có khóa như sau ::

D sở hữu L3
         C bị chặn trên L3
         C sở hữu L2
                B bị chặn trên L2
                B sở hữu L1
                       Bị chặn trên L1

Và do đó chúng ta có chuỗi A->L1->B->L2->C->L3->D.

Điều này mang lại cho chúng ta độ sâu PI là 4 (bốn quy trình), nhưng nhìn vào bất kỳ
hoạt động riêng lẻ, có vẻ như chúng chỉ có nhiều nhất là một khóa
độ sâu của hai.  Vì vậy, mặc dù độ sâu khóa được xác định tại thời điểm biên dịch,
vẫn còn rất khó để tìm ra những khả năng ở độ sâu đó.

Bây giờ vì các mutex có thể được xác định bởi các ứng dụng trên đất người dùng nên chúng tôi không muốn có DOS
loại ứng dụng lồng một lượng lớn mutexes để tạo ra một lượng lớn
chuỗi PI, và có mã giữ ổ khóa quay trong khi nhìn vào một khối lớn
lượng dữ liệu.  Vì vậy để ngăn chặn điều này, việc thực hiện không chỉ thực hiện
độ sâu khóa tối đa nhưng cũng chỉ giữ tối đa hai khóa khác nhau tại một
thời gian khi nó đi qua chuỗi PI.  Thông tin thêm về điều này dưới đây.


Chủ sở hữu Mutex và cờ
---------------------

Cấu trúc mutex chứa một con trỏ tới chủ sở hữu của mutex.  Nếu
mutex không được sở hữu, chủ sở hữu này được đặt thành NULL.  Vì mọi kiến trúc
có cấu trúc nhiệm vụ trên ít nhất một căn chỉnh hai byte (và nếu đây là
không đúng, mã rtmutex.c sẽ bị hỏng!), điều này cho phép ít nhất
bit quan trọng được sử dụng làm cờ.  Bit 0 được sử dụng làm "Có người phục vụ"
cờ. Nó được đặt bất cứ khi nào có người phục vụ trên mutex.

Xem Tài liệu/khóa/rt-mutex.rst để biết thêm chi tiết.

thủ thuật cmpxchg
--------------

Một số kiến ​​trúc triển khai cmpxchg nguyên tử (So sánh và Trao đổi).  Cái này
được sử dụng (khi có thể) để giữ cho đường đi nhanh chóng của việc nắm và thả
mutexes ngắn.

cmpxchg về cơ bản là hàm sau được thực hiện một cách nguyên tử ::

dài không dấu _cmpxchg(ZZ0000ZZB dài không dấu, dài không dấu *C)
  {
	dài không dấu T = *A;
	nếu (ZZ0001ZZB) {
		ZZ0002ZZC;
	}
	trả lại T;
  }
  #define cmpxchg(a,b,c) _cmpxchg(&a,&b,&c)

Điều này thực sự tốt vì nó cho phép bạn chỉ cập nhật một biến
nếu biến đó là những gì bạn mong đợi.  Bạn biết nếu nó thành công nếu
giá trị trả về (giá trị cũ của A) bằng B.

Macro rt_mutex_cmpxchg được sử dụng để cố gắng khóa và mở khóa các mutex. Nếu
kiến trúc không hỗ trợ CMPXCHG, thì macro này chỉ được đặt
lần nào cũng thất bại.  Nhưng nếu CMPXCHG được hỗ trợ thì điều này sẽ
giúp đỡ rất nhiều để giữ cho con đường nhanh chóng ngắn lại.

Việc sử dụng rt_mutex_cmpxchg với các flag trong trường owner giúp tối ưu hóa
hệ thống cho các kiến trúc hỗ trợ nó.  Điều này cũng sẽ được giải thích
sau này trong tài liệu này.


Điều chỉnh mức độ ưu tiên
--------------------

Việc triển khai mã PI trong rtmutex.c có một số chỗ cần
tiến trình phải điều chỉnh mức độ ưu tiên của nó.  Với sự giúp đỡ của pi_waiters của một
quá trình này khá dễ dàng để biết những gì cần phải điều chỉnh.

Các hàm thực hiện điều chỉnh tác vụ là rt_mutex_just_prio
và rt_mutex_setprio. rt_mutex_setprio chỉ được sử dụng trong rt_mutex_ adjustment_prio.

rt_mutex_just_prio kiểm tra mức độ ưu tiên của tác vụ và mức cao nhất
quy trình ưu tiên đang chờ bất kỳ mutex nào thuộc sở hữu của tác vụ. Kể từ khi
pi_waiters của một nhiệm vụ giữ thứ tự ưu tiên của tất cả những người phục vụ hàng đầu
của tất cả các mutex mà tác vụ sở hữu, chúng ta chỉ cần so sánh phần trên cùng
pi Waiter về mức ưu tiên bình thường/thời hạn của chính nó và chọn mức ưu tiên cao hơn.
Sau đó rt_mutex_setprio được gọi để điều chỉnh mức độ ưu tiên của tác vụ thành
ưu tiên mới. Lưu ý rằng rt_mutex_setprio được xác định trong kernel/sched/core.c
để thực hiện thay đổi thực tế về mức độ ưu tiên.

Lưu ý:
	Đối với trường "prio" trong task_struct, số càng thấp thì
	mức độ ưu tiên cao hơn. "Prio" là 5 có mức độ ưu tiên cao hơn
	"trước" của 10.

Thật thú vị khi lưu ý rằng rt_mutex_ adjustment_prio có thể tăng
hoặc giảm mức độ ưu tiên của nhiệm vụ.  Trong trường hợp có mức độ ưu tiên cao hơn
quá trình vừa bị chặn trên một mutex thuộc sở hữu của tác vụ, rt_mutex_ adjustment_prio
sẽ tăng/tăng mức độ ưu tiên của nhiệm vụ.  Nhưng nếu một nhiệm vụ có mức độ ưu tiên cao hơn
vì lý do nào đó để rời khỏi mutex (hết thời gian hoặc tín hiệu), chức năng tương tự
sẽ giảm/không tăng mức độ ưu tiên của nhiệm vụ.  Đó là bởi vì pi_waiters
luôn chứa tác vụ có mức độ ưu tiên cao nhất đang chờ trên một mutex thuộc sở hữu
theo nhiệm vụ nên ta chỉ cần so sánh mức độ ưu tiên của pi bồi bàn top đó
theo mức độ ưu tiên thông thường của nhiệm vụ nhất định.


Tổng quan cấp cao về bước đi chuỗi PI
----------------------------------------

Bước đi chuỗi PI được triển khai bằng hàm rt_mutex_just_prio_chain.

Việc triển khai đã trải qua nhiều lần lặp lại và đã kết thúc
với những gì chúng tôi tin là tốt nhất.  Nó đi qua chuỗi PI bằng cách chỉ lấy
nhiều nhất là hai khóa cùng một lúc và rất hiệu quả.

rt_mutex_just_prio_chain có thể được sử dụng để tăng hoặc giảm quá trình
những ưu tiên.

rt_mutex_just_prio_chain được gọi với nhiệm vụ cần kiểm tra PI
(de)tăng cường (chủ sở hữu của một mutex mà một tiến trình đang chặn), một lá cờ để
kiểm tra bế tắc, mutex mà tác vụ sở hữu, con trỏ tới người phục vụ
đó là cấu trúc bồi bàn của tiến trình bị chặn trên mutex (mặc dù điều này
tham số có thể là NULL để khử tăng tốc), một con trỏ tới mutex mà tác vụ trên đó
bị chặn và top_task là người phục vụ hàng đầu của mutex.

Đối với lời giải thích này, tôi sẽ không đề cập đến việc phát hiện bế tắc. Lời giải thích này
sẽ cố gắng duy trì phong độ cao.

Khi chức năng này được gọi, không có khóa nào được giữ.  Điều đó cũng có nghĩa
trạng thái của chủ sở hữu và khóa có thể thay đổi khi được nhập vào chức năng này.

Trước khi hàm này được gọi, tác vụ đã có rt_mutex_just_prio
được thực hiện trên đó.  Điều này có nghĩa là nhiệm vụ được đặt ở mức độ ưu tiên mà nó
lẽ ra phải ở đó, nhưng các nút rbtree của người phục vụ nhiệm vụ chưa được cập nhật
với những ưu tiên mới và nhiệm vụ này có thể không ở đúng vị trí
trong cây pi_waiters và bồi bàn mà nhiệm vụ bị chặn. Chức năng này
giải quyết được tất cả điều đó.

Hoạt động chính của chức năng này được Thomas Gleixner tóm tắt trong
rtmutex.c. Xem nhận xét 'Thông tin cơ bản về bước đi theo chuỗi và phạm vi bảo vệ' để biết thêm
chi tiết.

Lấy một mutex (Đi qua)
------------------------------------

Được rồi, bây giờ chúng ta hãy xem hướng dẫn chi tiết về những gì xảy ra khi
dùng một mutex.

Điều đầu tiên được thử là sử dụng mutex nhanh chóng.  Đây là
được thực hiện khi chúng tôi bật CMPXCHG (nếu không, quá trình lấy nhanh sẽ tự động
thất bại).  Chỉ khi trường chủ sở hữu của mutex là NULL thì khóa mới có thể được
được chụp bằng CMPXCHG và không cần phải làm gì khác.

Nếu có tranh chấp về ổ khóa, chúng ta sẽ đi theo con đường chậm
(rt_mutex_slowlock).

Hàm đường dẫn chậm là nơi cấu trúc bồi bàn của nhiệm vụ được tạo trên
ngăn xếp.  Điều này là do cấu trúc bồi bàn chỉ cần thiết cho
phạm vi của chức năng này.  Cấu trúc bồi bàn giữ các nút để lưu trữ
nhiệm vụ trên cây bồi bàn của mutex và nếu cần, pi_waiters
cây của chủ nhân.

Wait_lock của mutex được thực hiện do quá trình mở khóa chậm
mutex cũng có khóa này.

Sau đó chúng tôi gọi try_to_take_rt_mutex.  Đây là nơi có kiến trúc
không triển khai CMPXCHG sẽ luôn lấy khóa (nếu không có
tranh chấp).

try_to_take_rt_mutex được sử dụng mỗi khi tác vụ cố lấy một mutex trong
đường đi chậm.  Điều đầu tiên được thực hiện ở đây là thiết lập nguyên tử của
cờ "Có người phục vụ" của trường chủ sở hữu của mutex. Bằng cách đặt cờ này
Bây giờ, chủ sở hữu hiện tại của mutex đang bị tranh chấp không thể giải phóng mutex
mà không cần đi vào đường dẫn mở khóa chậm và sau đó nó sẽ cần phải lấy
wait_lock, mã này hiện đang được giữ. Vì vậy, việc đặt cờ "Có người phục vụ"
buộc chủ sở hữu hiện tại phải đồng bộ hóa với mã này.

Khóa được thực hiện nếu những điều sau đây là đúng:

1) Ổ khóa không có chủ
   2) Nhiệm vụ hiện tại có mức độ ưu tiên cao nhất so với tất cả các nhiệm vụ khác
      bồi bàn của ổ khóa

Nếu tác vụ lấy được khóa thành công thì tác vụ đó sẽ được đặt là
chủ sở hữu của khóa và nếu khóa vẫn có người phục vụ, top_waiter
(nhiệm vụ có mức ưu tiên cao nhất đang chờ khóa) được thêm vào nhiệm vụ này
cây pi_waiters.

Nếu khóa không được lấy bởi try_to_take_rt_mutex(), thì
Hàm task_blocks_on_rt_mutex() được gọi. Điều này sẽ thêm nhiệm vụ vào
cây phục vụ của khóa và truyền cả chuỗi pi của khóa
giống như cây pi_waiters của chủ sở hữu khóa. Điều này được mô tả ở phần tiếp theo
phần.

Khối tác vụ trên mutex
--------------------

Việc tính toán một mutex và tiến trình được thực hiện bằng cấu trúc bồi bàn của
quá trình này.  Trường "tác vụ" được đặt thành quy trình và trường "khóa"
đến mutex.  Nút rbtree của bồi bàn được khởi tạo cho các tiến trình
ưu tiên hiện nay.

Vì wait_lock đã được lấy khi có khóa chậm, nên chúng ta có thể an toàn
thêm người phục vụ vào cây người phục vụ nhiệm vụ.  Nếu quy trình hiện tại là
quy trình có mức độ ưu tiên cao nhất hiện đang chờ trên mutex này, sau đó chúng tôi sẽ xóa
quy trình bồi bàn hàng đầu trước đó (nếu nó tồn tại) từ pi_waiters của chủ sở hữu,
và thêm quy trình hiện tại vào cây đó.  Vì pi_waiter của chủ sở hữu
đã thay đổi, chúng tôi gọi rt_mutex_just_prio cho chủ sở hữu để xem liệu chủ sở hữu có
nên điều chỉnh mức độ ưu tiên của nó cho phù hợp.

Nếu chủ sở hữu cũng bị chặn trên một khóa và đã thay đổi pi_waiters của nó
(hoặc kiểm tra bế tắc đang bật), chúng tôi mở khóa wait_lock của mutex và tiếp tục
và chạy rt_mutex_just_prio_chain trên chủ sở hữu, như được mô tả trước đó.

Bây giờ tất cả các khóa đã được giải phóng và nếu quy trình hiện tại vẫn bị chặn trên một
mutex (trường "nhiệm vụ" của người phục vụ không phải là NULL), sau đó chúng ta đi ngủ (lịch gọi).

Thức dậy trong vòng lặp
---------------------

Nhiệm vụ sau đó có thể thức dậy vì một vài lý do:
  1) Chủ sở hữu khóa trước đã mở khóa và nhiệm vụ bây giờ là top_waiter
  2) chúng tôi đã nhận được tín hiệu hoặc thời gian chờ

Trong cả hai trường hợp, tác vụ sẽ thử lại để lấy khóa. Nếu nó
làm vậy, sau đó nó sẽ tự rời khỏi cây bồi bàn và tự quay trở lại
sang trạng thái TASK_RUNNING.

Trong trường hợp đầu tiên, nếu khóa được một tác vụ khác lấy được trước tác vụ này
có thể lấy được khóa, sau đó nó sẽ quay lại chế độ ngủ và chờ được đánh thức lại.

Trường hợp thứ hai chỉ áp dụng cho các tác vụ đang lấy một mutex
có thể thức dậy trước khi nhận được khóa, do tín hiệu hoặc
hết thời gian chờ (tức là rt_mutex_timed_futex_lock()). Khi thức dậy, nó sẽ cố gắng
lấy lại khóa, nếu thành công thì nhiệm vụ sẽ quay trở lại với
khóa được giữ, nếu không nó sẽ trả về với -EINTR nếu tác vụ được đánh thức
bằng tín hiệu hoặc -ETIMEDOUT nếu hết thời gian.


Mở khóa Mutex
-------------------

Việc mở khóa một mutex cũng có một con đường nhanh chóng cho những kiến trúc có
CMPXCHG.  Vì việc tranh chấp một mutex luôn đặt ra
Cờ "Có người phục vụ" của chủ sở hữu mutex, chúng tôi sử dụng cờ này để biết liệu chúng tôi có cần không
đi theo con đường chậm khi mở khóa mutex.  Nếu mutex không có bất kỳ
người phục vụ, trường chủ sở hữu của mutex sẽ bằng quy trình hiện tại và
mutex có thể được mở khóa bằng cách thay thế trường chủ sở hữu bằng NULL.

Nếu trường chủ sở hữu có tập bit "Có người phục vụ" (hoặc CMPXCHG không khả dụng),
con đường mở khóa chậm được thực hiện.

Điều đầu tiên được thực hiện trong đường dẫn mở khóa chậm là lấy wait_lock của
mutex.  Điều này đồng bộ hóa việc khóa và mở khóa mutex.

Việc kiểm tra được thực hiện để xem liệu mutex có người phục vụ hay không.  Trên những kiến trúc
không có CMPXCHG, đây là vị trí mà chủ sở hữu mutex sẽ
xác định xem người phục vụ có cần được đánh thức hay không.  Trên những kiến trúc
có CMPXCHG, việc kiểm tra đó được thực hiện trong đường dẫn nhanh, nhưng vẫn cần thiết
trong con đường chậm quá.  Nếu người phục vụ của mutex thức dậy vì tín hiệu
hoặc hết thời gian chờ giữa thời điểm chủ sở hữu không thực hiện được việc kiểm tra đường dẫn nhanh CMPXCHG và
Khi lấy Wait_lock, mutex có thể không có bất kỳ người phục vụ nào, do đó
chủ sở hữu vẫn cần thực hiện việc kiểm tra này. Nếu không có người phục vụ thì mutex
trường chủ sở hữu được đặt thành NULL, wait_lock được giải phóng và không còn gì nữa
cần thiết.

Nếu có người phục vụ thì chúng ta cần đánh thức một người.

Khi mã đánh thức, pi_lock của chủ sở hữu hiện tại sẽ được lấy.  Đỉnh cao
người phục vụ của khóa được tìm thấy và xóa khỏi cây bồi bàn của mutex
cũng như cây pi_waiters của chủ sở hữu hiện tại. Bit "Có người phục vụ" là
được đánh dấu để ngăn chặn các nhiệm vụ có mức độ ưu tiên thấp hơn đánh cắp khóa.

Cuối cùng chúng ta mở khóa pi_lock của chủ sở hữu đang chờ xử lý và đánh thức nó.


Liên hệ
-------

Để biết thông tin cập nhật về tài liệu này, vui lòng gửi email cho Steven Rostedt <rostedt@goodmis.org>


Tín dụng
-------

Tác giả: Steven Rostedt <rostedt@goodmis.org>

Đã cập nhật: Alex Shi <alex.shi@linaro.org> - 6/7/2017

Người đánh giá gốc:
		     Ingo Molnar, Thomas Gleixner, Thomas Duetsch và
		     Randy Dunlap

Cập nhật (6/7/2017) Người đánh giá: Steven Rostedt và Sebastian Siewior

Cập nhật
-------

Tài liệu này ban đầu được viết cho 2.6.17-rc3-mm1
đã được cập nhật vào ngày 4.12
