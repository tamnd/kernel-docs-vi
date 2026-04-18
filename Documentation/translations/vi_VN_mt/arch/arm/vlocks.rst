.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/vlocks.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
vlocks để loại trừ lẫn nhau kim loại trần
=========================================

Khóa biểu quyết hoặc "vlocks" cung cấp loại trừ lẫn nhau ở mức độ thấp đơn giản
cơ chế, với yêu cầu hợp lý nhưng tối thiểu về bộ nhớ
hệ thống.

Chúng được dự định sẽ được sử dụng để điều phối hoạt động quan trọng giữa các CPU
mặt khác không mạch lạc, trong trường hợp phần cứng
không cung cấp cơ chế nào khác để hỗ trợ điều này và các khóa spin thông thường
không thể sử dụng được


vlocks tận dụng tính nguyên tử được cung cấp bởi hệ thống bộ nhớ để
ghi vào một vị trí bộ nhớ duy nhất.  Để phân xử, mọi CPU đều "bỏ phiếu cho
chính nó", bằng cách lưu trữ một số duy nhất vào một vị trí bộ nhớ chung.  các
giá trị cuối cùng được thấy ở vị trí bộ nhớ đó khi tất cả các phiếu bầu đã được
dàn diễn viên xác định người chiến thắng.

Để đảm bảo rằng cuộc bầu cử mang lại một kết quả rõ ràng
trong thời gian hữu hạn, CPU sẽ chỉ tham gia cuộc bầu cử ngay từ đầu nếu
không có người chiến thắng nào được chọn và cuộc bầu cử dường như không có
đã bắt đầu chưa.


Thuật toán
----------

Cách dễ nhất để giải thích thuật toán vlocks là sử dụng một số mã giả::


int current_voting[NR_CPUS] = { 0, };
	int Last_vote = -1; /*chưa có phiếu nào*/

bool vlock_trylock(int this_cpu)
	{
		/* báo hiệu mong muốn bỏ phiếu của chúng tôi */
		hiện_voting[this_cpu] = 1;
		if (last_vote != -1) {
			/* có người đã tình nguyện rồi */
			hiện tại_voting[this_cpu] = 0;
			trả về sai; /*không phải của chúng ta */
		}

/*chúng ta hãy tự đề xuất*/
		Last_vote = this_cpu;
		hiện tại_voting[this_cpu] = 0;

/* sau đó đợi cho đến khi mọi người bỏ phiếu xong */
		for_each_cpu(i) {
			trong khi (current_voting[i] != 0)
				/* chờ đã */;
		}

/*kết quả*/
		nếu (last_vote == this_cpu)
			trả về đúng sự thật; /*chúng ta đã thắng*/
		trả về sai;
	}

bool vlock_unlock(void)
	{
		phiếu bầu cuối cùng = -1;
	}


Mảng current_voting[] cung cấp cách để CPU xác định
liệu cuộc bầu cử có đang diễn ra hay không và đóng vai trò tương tự như
mảng "nhập" trong thuật toán làm bánh của Lamport [1].

Tuy nhiên, khi cuộc bầu cử đã bắt đầu, hệ thống bộ nhớ cơ bản
tính nguyên tử được sử dụng để chọn người chiến thắng.  Điều này tránh sự cần thiết của một tĩnh
quy tắc ưu tiên để đóng vai trò là người hòa giải hoặc bất kỳ bộ đếm nào có thể
tràn.

Miễn là biến Last_vote hiển thị trên toàn cầu đối với tất cả các CPU, thì nó
sẽ chỉ chứa một giá trị không thay đổi sau khi mọi CPU đã bị xóa
cờ current_voting của nó.


Tính năng và hạn chế
------------------------

* vlocks không nhằm mục đích công bằng.  Trong trường hợp tranh chấp, đó là
   _last_ CPU cố gắng lấy khóa, rất có thể
   để giành chiến thắng.

do đó vlocks phù hợp nhất với các tình huống cần thiết
   để chọn một người chiến thắng duy nhất, nhưng thực tế CPU nào không quan trọng
   thắng.

* Giống như các cơ chế tương tự khác, vlock sẽ không có quy mô lớn
   số lượng CPU.

vlocks có thể được xếp tầng trong hệ thống phân cấp biểu quyết để cho phép mở rộng quy mô tốt hơn
   nếu cần, như trong ví dụ giả định sau đây cho 4096 CPU::

/* cấp độ đầu tiên: bầu cử địa phương */
	my_town = thị trấn[(this_cpu >> 4) & 0xf];
	I_won = vlock_trylock(my_town, this_cpu & 0xf);
	nếu (tôi_won) {
		/* chúng ta đã thắng cuộc bầu cử ở thị trấn, hãy tiến tới bang */
		my_state = state[(this_cpu >> 8) & 0xf];
		I_won = vlock_lock(my_state, this_cpu & 0xf));
		nếu (tôi_won) {
			/*và v.v.*/
			I_won = vlock_lock(the_whole_country, this_cpu & 0xf];
			nếu (tôi_won) {
				/* ... */
			}
			vlock_unlock(the_whole_country);
		}
		vlock_unlock(my_state);
	}
	vlock_unlock(my_town);


Triển khai ARM
------------------

Việc triển khai ARM hiện tại [2] chứa một số tối ưu hóa ngoài
thuật toán cơ bản:

* Bằng cách xếp các thành viên của mảng current_voting lại gần nhau,
   chúng ta có thể đọc toàn bộ mảng trong một giao dịch (cung cấp số
   số CPU có khả năng tranh chấp khóa đủ nhỏ).  Cái này
   giảm số lượng các chuyến đi khứ hồi cần thiết cho bộ nhớ ngoài.

Trong triển khai ARM, điều này có nghĩa là chúng ta có thể sử dụng một tải duy nhất
   và so sánh::

LDR Rt, [Rn]
	CMP Rt, #0

   ...in place of code equivalent to::

LDRB Rt, [Rn]
	CMP Rt, #0
	LDRBEQ Rt, [Rn, #1]
	CMPEQ Rt, #0
	LDRBEQ Rt, [Rn, #2]
	CMPEQ Rt, #0
	LDRBEQ Rt, [Rn, #3]
	CMPEQ Rt, #0

Điều này làm giảm độ trễ đường dẫn nhanh, cũng như khả năng
   giảm tranh chấp xe buýt trong các trường hợp tranh chấp.

Việc tối ưu hóa dựa trên thực tế là hệ thống bộ nhớ ARM
   đảm bảo sự gắn kết giữa các lần truy cập bộ nhớ chồng chéo của
   kích thước khác nhau, tương tự như nhiều kiến trúc khác.  Lưu ý rằng
   chúng tôi không quan tâm thành phần nào của current_voting xuất hiện trong thành phần nào
   bit của Rt, do đó không cần phải lo lắng về độ bền trong phần này
   tối ưu hóa.

Nếu có quá nhiều CPU để đọc mảng current_voting trong
   một giao dịch thì nhiều giao dịch vẫn được yêu cầu.  các
   việc triển khai sử dụng một vòng lặp tải cỡ chữ đơn giản cho việc này
   trường hợp.  Số lượng giao dịch vẫn ít hơn dự kiến
   được yêu cầu nếu byte được tải riêng lẻ.


Về nguyên tắc, chúng tôi có thể tổng hợp thêm bằng cách sử dụng LDRD hoặc LDM, nhưng
   để giữ cho mã đơn giản, điều này đã không được thử trong lần đầu tiên
   thực hiện.


* vlock hiện chỉ được sử dụng để phối hợp giữa các CPU
   chưa thể kích hoạt bộ nhớ đệm của họ.  Điều này có nghĩa là
   Việc thực hiện sẽ loại bỏ nhiều rào cản cần thiết
   khi thực hiện thuật toán trong bộ nhớ đệm.

việc đóng gói mảng current_voting không hoạt động với bộ nhớ đệm
   bộ nhớ trừ khi tất cả các CPU tranh luận về khóa đều liên kết với bộ đệm, do
   để ghi vào bộ đệm ghi lại từ một giá trị ghi đè CPU được ghi bởi người khác
   CPU.  (Mặc dù nếu tất cả các CPU đều có tính kết hợp bộ đệm, bạn nên
   thay vào đó có lẽ đang sử dụng spinlocks thích hợp).


* Giá trị "chưa có phiếu bầu" được sử dụng cho biến Last_vote là 0 (không phải
   -1 như trong mã giả).  Điều này cho phép các vlock được phân bổ tĩnh
   được ngầm khởi tạo ở trạng thái mở khóa chỉ bằng cách đặt
   chúng trong .bss.

Một phần bù được thêm vào mỗi ID của CPU nhằm mục đích thiết lập điều này
   biến, do đó không có CPU nào sử dụng giá trị 0 cho ID của nó.


colophon
--------

Ban đầu được tạo ra và ghi lại bởi Dave Martin cho Linaro Limited, dành cho
sử dụng trong các nền tảng big.LITTLE dựa trên ARM, với sự đánh giá và đóng góp ý kiến chân thành
nhận được từ Nicolas Pitre và Achin Gupta.  Cảm ơn Nicolas vì
lấy hầu hết văn bản này ra khỏi chuỗi thư có liên quan và viết
lên mã giả.

Bản quyền (C) 2012-2013 Linaro Limited
Được phân phối theo các điều khoản của Phiên bản 2 của GNU General Public
Giấy phép, như được định nghĩa trong linux/COPYING.


Tài liệu tham khảo
------------------

[1] Lamport, L. "Giải pháp mới về lập trình đồng thời của Dijkstra
    Vấn đề", Truyền thông của ACM 17, 8 (tháng 8 năm 1974), 453-455.

ZZ0000ZZ

[2] linux/arch/arm/common/vlock.S, www.kernel.org.
