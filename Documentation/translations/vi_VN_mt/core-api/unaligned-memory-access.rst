.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/unaligned-memory-access.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Truy cập bộ nhớ không được sắp xếp
==================================

:Tác giả: Daniel Drake <dsd@gentoo.org>,
:Tác giả: Johannes Berg <johannes@sipsolutions.net>

:Với sự trợ giúp từ: Alan Cox, Avuton Olrich, Heikki Orsila, Jan Engelhardt,
  Kyle McMartin, Kyle Moffett, Randy Dunlap, Robert Hancock, Uli Kunitz,
  Vadim Lobanov


Linux chạy trên nhiều kiến trúc có hành vi khác nhau
khi nói đến việc truy cập bộ nhớ. Tài liệu này trình bày một số chi tiết về
truy cập không được phân bổ, tại sao bạn cần viết mã không gây ra chúng,
và cách viết mã như vậy!


Định nghĩa về quyền truy cập không được căn chỉnh
=====================================

Truy cập bộ nhớ không được phân bổ xảy ra khi bạn cố đọc N byte dữ liệu bắt đầu
từ một địa chỉ không chia hết cho N (tức là addr % N != 0).
Ví dụ: đọc 4 byte dữ liệu từ địa chỉ 0x10004 là được, nhưng
đọc 4 byte dữ liệu từ địa chỉ 0x10005 sẽ là bộ nhớ chưa được phân bổ
truy cập.

Những điều trên có vẻ hơi mơ hồ, vì việc truy cập bộ nhớ có thể xảy ra theo nhiều cách khác nhau.
cách. Bối cảnh ở đây là ở cấp mã máy: đọc một số hướng dẫn nhất định
hoặc ghi một số byte vào hoặc ra khỏi bộ nhớ (ví dụ: movb, movw, movl trong x86
lắp ráp). Như sẽ rõ, tương đối dễ dàng để phát hiện các câu lệnh C
sẽ biên dịch thành các hướng dẫn truy cập bộ nhớ nhiều byte, cụ thể là khi
xử lý các loại như u16, u32 và u64.


Căn chỉnh tự nhiên
=================

Quy tắc được đề cập ở trên hình thành nên cái mà chúng tôi gọi là sự liên kết tự nhiên:
Khi truy cập N byte bộ nhớ, địa chỉ bộ nhớ cơ sở phải bằng nhau
chia hết cho N, tức là addr % N == 0.

Khi viết mã, giả sử kiến trúc đích có sự liên kết tự nhiên
yêu cầu.

Trên thực tế, chỉ có một số kiến trúc yêu cầu sự căn chỉnh tự nhiên trên mọi kích thước
của việc truy cập bộ nhớ. Tuy nhiên, chúng ta phải xem xét các kiến ​​trúc được hỗ trợ bởi ALL;
viết mã thỏa mãn yêu cầu căn chỉnh tự nhiên là cách dễ nhất
để đạt được tính di động đầy đủ.


Tại sao quyền truy cập không được căn chỉnh là xấu
===========================

Tác động của việc thực hiện truy cập bộ nhớ không được phân bổ khác nhau tùy theo kiến trúc
đến kiến trúc. Sẽ thật dễ dàng để viết toàn bộ tài liệu về sự khác biệt
ở đây; một bản tóm tắt các tình huống phổ biến được trình bày dưới đây:

- Một số kiến trúc có thể thực hiện truy cập bộ nhớ không được phân bổ
   minh bạch, nhưng thường có chi phí thực hiện đáng kể.
 - Một số kiến trúc đưa ra các ngoại lệ của bộ xử lý khi truy cập không được căn chỉnh
   xảy ra. Trình xử lý ngoại lệ có thể sửa quyền truy cập chưa được phân bổ,
   với chi phí đáng kể cho hiệu suất.
 - Một số kiến trúc đưa ra các ngoại lệ của bộ xử lý khi truy cập không được căn chỉnh
   xảy ra, nhưng các trường hợp ngoại lệ không chứa đủ thông tin cho
   quyền truy cập chưa được căn chỉnh cần được sửa chữa.
 - Một số kiến trúc không có khả năng truy cập bộ nhớ không được sắp xếp, nhưng sẽ
   âm thầm thực hiện truy cập bộ nhớ khác vào bộ nhớ được yêu cầu,
   dẫn đến một lỗi mã tinh vi khó phát hiện!

Điều rõ ràng ở trên là nếu mã của bạn gây ra lỗi không được căn chỉnh
truy cập bộ nhớ xảy ra, mã của bạn sẽ không hoạt động chính xác trên một số
nền tảng và sẽ gây ra vấn đề về hiệu suất trên những nền tảng khác.


Mã không gây ra quyền truy cập không được phân bổ
=========================================

Lúc đầu, các khái niệm trên có vẻ hơi khó liên hệ với thực tế.
thực hành mã hóa. Suy cho cùng, bạn không có nhiều quyền kiểm soát
địa chỉ bộ nhớ của các biến nhất định, v.v.

May mắn thay mọi thứ không quá phức tạp, vì trong hầu hết các trường hợp, trình biên dịch
đảm bảo rằng mọi thứ sẽ làm việc cho bạn. Ví dụ, lấy như sau
cấu trúc::

cấu trúc foo {
		trường u161;
		trường u322;
		trường u83;
	};

Giả sử rằng một thể hiện của cấu trúc trên nằm trong bộ nhớ
bắt đầu từ địa chỉ 0x10000. Với mức độ hiểu biết cơ bản, nó sẽ
không phải là vô lý khi cho rằng việc truy cập vào trường 2 sẽ gây ra lỗi không được căn chỉnh
truy cập. Bạn có thể mong đợi trường2 được đặt ở vị trí bù 2 byte vào
cấu trúc, tức là địa chỉ 0x10002, nhưng địa chỉ đó không chia đều
bằng 4 (hãy nhớ rằng ở đây chúng ta đang đọc giá trị 4 byte).

May mắn thay, trình biên dịch hiểu được các ràng buộc căn chỉnh, vì vậy trong
trường hợp trên, nó sẽ chèn 2 byte đệm vào giữa trường 1 và trường 2.
Vì vậy, đối với các kiểu cấu trúc tiêu chuẩn, bạn luôn có thể dựa vào trình biên dịch
vào các cấu trúc đệm để việc truy cập vào các trường được căn chỉnh phù hợp (giả sử
bạn không chuyển trường sang loại có độ dài khác).

Tương tự, bạn cũng có thể dựa vào trình biên dịch để căn chỉnh các biến và hàm
tham số cho sơ đồ căn chỉnh tự nhiên, dựa trên kích thước của loại
biến số.

Tại thời điểm này, cần rõ ràng rằng việc truy cập một byte đơn (u8 hoặc char)
sẽ không bao giờ gây ra truy cập không được sắp xếp, bởi vì tất cả các địa chỉ bộ nhớ đều giống nhau
chia hết cho một.

Về một chủ đề liên quan, với những cân nhắc ở trên, bạn có thể quan sát thấy
rằng bạn có thể sắp xếp lại các trường trong cấu trúc để đặt các trường
nếu không thì phần đệm sẽ được chèn vào và do đó làm giảm tổng thể
kích thước bộ nhớ thường trú của các phiên bản cấu trúc. Cách bố trí tối ưu của
ví dụ trên là::

cấu trúc foo {
		trường u322;
		trường u161;
		trường u83;
	};

Đối với sơ đồ căn chỉnh tự nhiên, trình biên dịch sẽ chỉ phải thêm một
byte đệm ở cuối cấu trúc. Phần đệm này được thêm vào theo thứ tự
để đáp ứng các ràng buộc căn chỉnh cho mảng của các cấu trúc này.

Một điểm đáng nói nữa là việc sử dụng __attribute__((packed)) trên một
kiểu kết cấu. Thuộc tính dành riêng cho GCC này báo cho trình biên dịch không bao giờ
chèn bất kỳ phần đệm nào vào trong cấu trúc, hữu ích khi bạn muốn sử dụng cấu trúc C
để thể hiện một số dữ liệu được sắp xếp cố định 'không có dây'.

Bạn có thể có xu hướng tin rằng việc sử dụng thuộc tính này có thể dễ dàng
dẫn đến truy cập không được phân bổ khi truy cập vào các trường không thỏa mãn
yêu cầu về sự liên kết kiến trúc. Tuy nhiên, một lần nữa, trình biên dịch nhận thức được
của các ràng buộc căn chỉnh và sẽ tạo ra các hướng dẫn bổ sung để thực hiện
truy cập bộ nhớ theo cách không gây ra truy cập không được căn chỉnh. Tất nhiên,
các hướng dẫn bổ sung rõ ràng gây ra sự giảm hiệu suất so với
trường hợp không đóng gói, vì vậy thuộc tính đóng gói chỉ nên được sử dụng khi tránh
phần đệm cấu trúc là quan trọng.


Mã gây ra quyền truy cập không được căn chỉnh
=================================

Với ý nghĩ trên, chúng ta hãy chuyển sang một ví dụ thực tế về hàm
có thể gây ra truy cập bộ nhớ không được phân bổ. Chức năng sau đây được thực hiện
từ include/linux/etherdevice.h là một quy trình được tối ưu hóa để so sánh hai
địa chỉ ethernet MAC cho sự bình đẳng::

bool ether_addr_equal(const u8 *addr1, const u8 *addr2)
  {
  #ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
	u32 gấp = ((ZZ0001ZZ)addr1) ^ (ZZ0002ZZ)addr2)) |
		   ((ZZ0003ZZ)(addr1 + 4)) ^ (ZZ0004ZZ)(addr2 + 4)));

trả về gấp == 0;
  #else
	const u16 ZZ0000ZZ)addr1;
	const u16 ZZ0001ZZ)addr2;
	return ((a[0] ^ b[0]) ZZ0002ZZ (a[2] ^ b[2])) == 0;
  #endif
  }

Trong chức năng trên, khi phần cứng có quyền truy cập không được phân bổ hiệu quả
khả năng, không có vấn đề với mã này.  Nhưng khi phần cứng không
có thể truy cập bộ nhớ trên các ranh giới tùy ý, việc tham chiếu đến a[0] gây ra
2 byte (16 bit) được đọc từ bộ nhớ bắt đầu từ địa chỉ addr1.

Hãy nghĩ xem điều gì sẽ xảy ra nếu addr1 là một địa chỉ lẻ chẳng hạn như 0x10003.
(Gợi ý: đó sẽ là quyền truy cập chưa được phân bổ.)

Bất chấp các vấn đề tiềm ẩn về truy cập không được phân bổ với chức năng trên, nó
dù sao cũng được bao gồm trong kernel nhưng được hiểu là chỉ hoạt động bình thường trên
Địa chỉ liên kết 16-bit. Người gọi có quyền đảm bảo sự liên kết này hoặc
hoàn toàn không sử dụng chức năng này. Chức năng căn chỉnh không an toàn này vẫn hữu ích
vì đây là một sự tối ưu hóa phù hợp cho những trường hợp bạn có thể đảm bảo sự liên kết,
điều này hầu như luôn đúng trong bối cảnh mạng ethernet.


Đây là một ví dụ khác về một số mã có thể gây ra các truy cập không được phân bổ::

void myfunc(dữ liệu u8 *, giá trị u32)
	{
		[…]
		dữ liệu ZZ0000ZZ) = cpu_to_le32(giá trị);
		[…]
	}

Mã này sẽ gây ra các truy cập không được phân bổ mỗi khi các điểm tham số dữ liệu
đến một địa chỉ không chia hết cho 4.

Tóm lại, 2 tình huống chính mà bạn có thể gặp phải quyền truy cập không được phân bổ
vấn đề liên quan đến:

1. Truyền biến thành các loại có độ dài khác nhau
 2. Số học con trỏ theo sau là quyền truy cập vào ít nhất 2 byte dữ liệu


Tránh truy cập không được sắp xếp
===========================

Cách dễ nhất để tránh quyền truy cập chưa được phân bổ là sử dụng get_unaligned() và
macro put_unaligned() được cung cấp bởi tệp tiêu đề <linux/unaligned.h>.

Quay lại ví dụ trước về mã có khả năng gây ra lỗi không được căn chỉnh
truy cập::

void myfunc(dữ liệu u8 *, giá trị u32)
	{
		[…]
		dữ liệu ZZ0000ZZ) = cpu_to_le32(giá trị);
		[…]
	}

Để tránh việc truy cập bộ nhớ chưa được phân bổ, bạn sẽ viết lại như sau::

void myfunc(dữ liệu u8 *, giá trị u32)
	{
		[…]
		giá trị = cpu_to_le32(giá trị);
		put_unaligned(value, (u32 *) data);
		[…]
	}

Macro get_unaligned() hoạt động tương tự. Giả sử 'dữ liệu' là một con trỏ tới
bộ nhớ và bạn muốn tránh truy cập không được sắp xếp, cách sử dụng nó như sau ::

giá trị u32 = dữ liệu get_unaligned((u32 *));

Các macro này hoạt động để truy cập bộ nhớ có độ dài bất kỳ (không chỉ 32 bit như
trong các ví dụ trên). Xin lưu ý rằng khi so sánh với quyền truy cập tiêu chuẩn của
bộ nhớ được căn chỉnh, việc sử dụng các macro này để truy cập vào bộ nhớ chưa được căn chỉnh có thể tốn kém trong
điều khoản về hiệu suất.

Nếu việc sử dụng các macro như vậy không thuận tiện, có một tùy chọn khác là sử dụng memcpy(),
trong đó nguồn hoặc đích (hoặc cả hai) thuộc loại u8* hoặc unsigned char*.
Do tính chất theo byte của hoạt động này, nên tránh được các truy cập không được căn chỉnh.


Liên kết so với mạng
========================

Trên các kiến trúc yêu cầu tải liên kết, mạng yêu cầu IP
tiêu đề được căn chỉnh trên ranh giới bốn byte để tối ưu hóa ngăn xếp IP. cho
phần cứng ethernet thông thường, NET_IP_ALIGN không đổi được sử dụng. Trên hầu hết
kiến trúc hằng số này có giá trị 2 vì ethernet thông thường
tiêu đề dài 14 byte, vì vậy để có được sự căn chỉnh phù hợp, người ta cần phải
DMA tới một địa chỉ có thể được biểu thị dưới dạng 4*n + 2. Một ngoại lệ đáng chú ý
đây là powerpc xác định NET_IP_ALIGN thành 0 vì DMA không được căn chỉnh
địa chỉ có thể rất tốn kém và làm giảm chi phí của các tải không được sắp xếp.

Đối với một số phần cứng ethernet không thể DMA tới các địa chỉ chưa được căn chỉnh như
4*n+2 hoặc phần cứng không phải ethernet, đây có thể là một vấn đề và khi đó
cần thiết để sao chép khung hình đến vào bộ đệm được căn chỉnh. Bởi vì đây là
không cần thiết trên các kiến trúc có thể thực hiện truy cập không được sắp xếp, mã có thể
phụ thuộc vào CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS như vậy::

#ifdef CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS
		skb = skb gốc
	#else
		skb = sao chép skb
	#endif
