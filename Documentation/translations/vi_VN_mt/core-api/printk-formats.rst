.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/printk-formats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================================
Làm thế nào để có được thông số xác định định dạng printk đúng
==============================================================

.. _printk-specifiers:

:Tác giả: Randy Dunlap <rdunlap@infradead.org>
:Tác giả: Andrew Murray <amurray@mpc-data.co.uk>


Kiểu số nguyên
==============

::

Nếu biến thuộc Loại, hãy sử dụng công cụ xác định định dạng printk:
	------------------------------------------------------------
		char đã ký %d hoặc %hhx
		ký tự không dấu %u hoặc %x
		ký tự %u hoặc %x
		int ngắn %d hoặc %hx
		unsigned short int %u hoặc %x
		int %d hoặc %x
		unsigned int %u hoặc %x
		%ld hoặc %lx dài
		không dấu dài %lu hoặc %lx
		dài dài %lld hoặc %llx
		không dấu dài %llu hoặc %llx
		size_t %zu hoặc %zx
		ssize_t %zd hoặc %zx
		s8 %d hoặc %hhx
		u8 %u hoặc %x
		s16 %d hoặc %hx
		u16 %u hoặc %x
		s32 %d hoặc %x
		u32 %u hoặc %x
		s64 %lld hoặc %llx
		u64 %llu hoặc %llx


Nếu <type> phụ thuộc vào kiến trúc về kích thước của nó (ví dụ: Cycles_t, tcflag_t) hoặc
phụ thuộc vào tùy chọn cấu hình cho kích thước của nó (ví dụ: blk_status_t), hãy sử dụng định dạng
chỉ định loại lớn nhất có thể của nó và truyền rõ ràng cho nó.

Ví dụ::

printk("test: độ trễ: %llu chu kỳ\n", (unsigned long long)time);

Nhắc nhở: sizeof() trả về loại size_t.

printf của kernel không hỗ trợ %n. Các định dạng dấu phẩy động (%e, %f,
%g, %a) cũng không được nhận dạng vì những lý do rõ ràng. Sử dụng bất kỳ
công cụ xác định hoặc vòng loại độ dài không được hỗ trợ dẫn đến WARN và sớm
trở về từ vsnprintf().

Các loại con trỏ
================

Một giá trị con trỏ thô có thể được in bằng %p sẽ băm địa chỉ
trước khi in. Hạt nhân cũng hỗ trợ các bộ xác định mở rộng để in
con trỏ có nhiều kiểu khác nhau.

Thay vào đó, một số công cụ xác định mở rộng in dữ liệu trên địa chỉ đã cho
in chính địa chỉ đó. Trong trường hợp này, các thông báo lỗi sau
có thể được in thay vì thông tin không thể truy cập::

(null) dữ liệu trên địa chỉ NULL đơn giản
	(mặc định) dữ liệu về địa chỉ không hợp lệ
	(einval) dữ liệu không hợp lệ trên một địa chỉ hợp lệ

Con trỏ đơn giản
----------------

::

%p abcdef12 hoặc 00000000abcdef12

Các con trỏ được in mà không có phần mở rộng định danh (tức là %p không được trang trí) là
được băm để tránh rò rỉ thông tin về bố cục bộ nhớ kernel. Cái này
có thêm lợi ích là cung cấp mã định danh duy nhất. Trên máy 64-bit
32 bit đầu tiên bằng 0. Hạt nhân sẽ in ZZ0000ZZ cho đến khi nó
tập hợp đủ entropy.

Khi có thể, hãy sử dụng các công cụ sửa đổi chuyên dụng như %pS hoặc %pB (được mô tả bên dưới)
để tránh nhu cầu cung cấp một địa chỉ chưa được băm phải được giải thích
hậu hoc. Nếu không thể, và mục đích của việc in địa chỉ là cung cấp
thêm thông tin về cách gỡ lỗi, hãy sử dụng %p và khởi động kernel bằng
Tham số ZZ0000ZZ trong quá trình gỡ lỗi, sẽ in tất cả %p
địa chỉ không bị sửa đổi Nếu ZZ0001ZZ của bạn luôn muốn địa chỉ chưa được sửa đổi, hãy xem
%px bên dưới.

Nếu (và chỉ khi) bạn in địa chỉ dưới dạng nội dung của tệp ảo trong
ví dụ: procfs hoặc sysfs (sử dụng ví dụ seq_printf(), không phải printk()) được đọc bởi một
xử lý không gian người dùng, hãy sử dụng công cụ sửa đổi %pK được mô tả bên dưới thay vì %p hoặc %px.

Con trỏ lỗi
--------------

::

%pe -ENOSPC

Để in các con trỏ lỗi (tức là một con trỏ mà IS_ERR() là đúng)
như một tên lỗi tượng trưng. Giá trị lỗi không có tên tượng trưng
đã biết được in ở dạng thập phân, trong khi một số không phải ERR_PTR được chuyển thành
đối số cho %pe được coi là %p thông thường.

Ký hiệu/Con trỏ hàm
-------------------------

::

%pS linh hoạt_init+0x0/0x110
	%ps linh hoạt_init
	%pSR linh hoạt_init+0x9/0x110
		(với bản dịch __buildin_extract_return_addr())
	%pB prev_fn_of_versatile_init+0x88/0x88


Bộ xác định ZZ0000ZZ và ZZ0001ZZ được sử dụng để in một con trỏ dưới dạng ký hiệu
định dạng. Chúng dẫn đến tên biểu tượng có (S) hoặc không có (s)
sự bù đắp. Nếu KALLSYMS bị tắt thì địa chỉ ký hiệu sẽ được in thay thế.

Trình xác định ZZ0000ZZ dẫn đến tên ký hiệu có độ lệch và phải là
được sử dụng khi in dấu vết ngăn xếp. Người xác định sẽ đưa vào
xem xét ảnh hưởng của việc tối ưu hóa trình biên dịch có thể xảy ra
khi các lệnh gọi đuôi được sử dụng và được đánh dấu bằng thuộc tính GCC noreturn.

Nếu con trỏ nằm trong một mô-đun thì tên mô-đun và ID bản dựng tùy chọn là
được in sau tên biểu tượng với một chữ ZZ0000ZZ bổ sung được thêm vào cuối
người chỉ định.

::

%pS linh hoạt_init+0x0/0x110 [tên_mô-đun]
	%pSb linh hoạt_init+0x0/0x110 [tên_mô-đun ed5019fdf5e53be37cb1ba7899292d7e143b259e]
	%pSRb linh hoạt_init+0x9/0x110 [tên_mô-đun ed5019fdf5e53be37cb1ba7899292d7e143b259e]
		(với bản dịch __buildin_extract_return_addr())
	%pBb prev_fn_of_versatile_init+0x88/0x88 [tên_mô-đun ed5019fdf5e53be37cb1ba7899292d7e143b259e]

Con trỏ được thăm dò từ BPF / truy tìm
--------------------------------------

::

Chuỗi hạt nhân %pks
	chuỗi người dùng %pus

Bộ xác định ZZ0000ZZ và ZZ0001ZZ được sử dụng để in bộ nhớ được thăm dò trước đó từ
bộ nhớ kernel (k) hoặc bộ nhớ người dùng (u). Công cụ xác định ZZ0002ZZ tiếp theo
kết quả là in ra một chuỗi. Để sử dụng trực tiếp trong vsnprintf() thông thường, (k)
và (u) chú thích bị bỏ qua, tuy nhiên, khi được sử dụng ngoài bpf_trace_printk() của BPF,
ví dụ, nó đọc bộ nhớ mà nó đang trỏ tới mà không bị lỗi.

Con trỏ hạt nhân
----------------

::

%pK 01234567 hoặc 0123456789abcdef

Để in các con trỏ hạt nhân cần được ẩn khỏi những người không có đặc quyền
người dùng. Hành vi của %pK phụ thuộc vào kptr_restrict sysctl - xem
Tài liệu/admin-guide/sysctl/kernel.rst để biết thêm chi tiết.

Công cụ sửa đổi này được sử dụng ZZ0000ZZ khi tạo nội dung của tệp được đọc bởi
không gian người dùng từ ví dụ: Procfs hoặc sysfs, không dành cho dmesg. Vui lòng tham khảo
phần về %p ở trên để thảo luận về cách quản lý con trỏ băm
trong printk().

Địa chỉ chưa sửa đổi
--------------------

::

%px 01234567 hoặc 0123456789abcdef

Để in con trỏ khi ZZ0000ZZ muốn in địa chỉ. làm ơn
xem xét liệu bạn có đang rò rỉ thông tin nhạy cảm về
bố trí bộ nhớ kernel trước khi in con trỏ bằng %px. %px có chức năng
tương đương với %lx (hoặc %lu). %px được ưa thích hơn vì nó độc đáo hơn
có thể chấp nhận được. Nếu trong tương lai chúng ta cần sửa đổi cách xử lý kernel
in con trỏ, chúng tôi sẽ được trang bị tốt hơn để tìm các trang web cuộc gọi.

Trước khi sử dụng %px, hãy cân nhắc xem việc sử dụng %p có đủ cùng với việc bật
Tham số kernel ZZ0000ZZ trong các phiên gỡ lỗi (xem %p
mô tả ở trên). Một kịch bản hợp lệ cho %px có thể là in thông tin
ngay trước cơn hoảng loạn, điều này ngăn cản bất kỳ thông tin nhạy cảm nào bị lộ ra ngoài.
dù sao cũng bị khai thác và với %px sẽ không cần phải tái hiện sự hoảng loạn
với no_hash_pointers.

Sự khác biệt về con trỏ
-----------------------

::

%td 2560
	%tx a00

Để in sự khác biệt của con trỏ, hãy sử dụng công cụ sửa đổi %t cho ptrdiff_t.

Ví dụ::

printk("test: sự khác biệt giữa các con trỏ: %td\n", ptr2 - ptr1);

Tài nguyên cấu trúc
-------------------

::

%pr [mem 0x60000000-0x6fffffff cờ 0x2200] hoặc
		[mem 0x60000000 cờ 0x2200] hoặc
		[mem 0x0000000060000000-0x000000006fffffff cờ 0x2200]
		[mem 0x0000000060000000 cờ 0x2200]
	%pR [mem 0x60000000-0x6fffffff trước] hoặc
		[mem 0x60000000 trước] hoặc
		[mem 0x0000000060000000-0x000000006fffffff trước]
		[mem 0x0000000060000000 trước]

Để in tài nguyên cấu trúc. Bộ xác định ZZ0000ZZ và ZZ0001ZZ dẫn đến một
tài nguyên được in có (R) hoặc không có (r) thành viên cờ được giải mã.  Nếu bắt đầu là
bằng với kết thúc chỉ in giá trị bắt đầu.

Đã được thông qua bằng cách tham khảo.

Các loại địa chỉ vật lý Phys_addr_t
-----------------------------------

::

%pa[p] 0x01234567 hoặc 0x0123456789abcdef

Để in loại Phys_addr_t (và các dẫn xuất của nó, chẳng hạn như
Resource_size_t) có thể thay đổi tùy theo tùy chọn bản dựng, bất kể
chiều rộng của đường dẫn dữ liệu CPU.

Đã được thông qua bằng cách tham khảo.

Phạm vi cấu trúc
----------------

::

%pra [phạm vi 0x0000000060000000-0x000000006fffffff] hoặc
		[phạm vi 0x0000000060000000]

Để in phạm vi cấu trúc.  phạm vi cấu trúc giữ phạm vi tùy ý của u64
các giá trị.  Nếu bắt đầu bằng kết thúc thì chỉ in giá trị bắt đầu.

Đã được thông qua bằng cách tham khảo.

Loại địa chỉ DMA dma_addr_t
----------------------------

::

%pad 0x01234567 hoặc 0x0123456789abcdef

Để in loại dma_addr_t có thể thay đổi tùy theo tùy chọn bản dựng,
bất kể độ rộng của đường dẫn dữ liệu CPU.

Đã được thông qua bằng cách tham khảo.

Bộ đệm thô dưới dạng chuỗi thoát
--------------------------------

::

%*pE[achnops]

Để in bộ đệm thô dưới dạng chuỗi thoát. Đối với bộ đệm sau::

1b 62 20 5c 43 07 22 90 0d 5d

Một vài ví dụ cho thấy việc chuyển đổi sẽ được thực hiện như thế nào (không bao gồm xung quanh
trích dẫn)::

%*pE "\eb \C\a"\220\r]"
		%*pEhp "\x1bb \C\x07"\x90\x0d]"
		%*pEa "\e\142\040\\\103\a\042\220\r\135"

Các quy tắc chuyển đổi được áp dụng theo sự kết hợp tùy chọn
của cờ (xem tài liệu hạt nhân ZZ0000ZZ để biết
chi tiết):

- một - ESCAPE_ANY
	-c-ESCAPE_SPECIAL
	- h - ESCAPE_HEX
	- n - ESCAPE_NULL
	- o - ESCAPE_OCTAL
	-p-ESCAPE_NP
	-s-ESCAPE_SPACE

Theo mặc định ESCAPE_ANY_NP được sử dụng.

ESCAPE_ANY_NP là sự lựa chọn hợp lý cho nhiều trường hợp, đặc biệt đối với
in SSID.

Nếu độ rộng trường bị bỏ qua thì chỉ có 1 byte được thoát.

Bộ đệm thô dưới dạng chuỗi hex
------------------------------

::

%*ph 00 01 02 ... 3f
	%*phC 00:01:02: ... :3f
	%*phD 00-01-02- ... -3f
	%*phN 000102 ... 3f

Để in các bộ đệm nhỏ (dài tối đa 64 byte) dưới dạng chuỗi hex có
dấu phân cách nhất định. Đối với bộ đệm lớn hơn, hãy cân nhắc sử dụng
ZZ0000ZZ.

Địa chỉ MAC/FDDI
------------------

::

% chiều 00:01:02:03:04:05
	%pMR 05:04:03:02:01:00
	%pMF 00-01-02-03-04-05
	% chiều 000102030405
	%pmR 050403020100

Để in địa chỉ MAC/FDDI 6 byte ở dạng ký hiệu hex. ZZ0000ZZ và ZZ0001ZZ
công cụ xác định dẫn đến địa chỉ được in có (M) hoặc không có (m) byte
dải phân cách. Dấu phân cách byte mặc định là dấu hai chấm (:).

Khi có liên quan đến địa chỉ FDDI, công cụ xác định ZZ0000ZZ có thể được sử dụng sau
công cụ xác định ZZ0001ZZ để sử dụng dấu phân cách dấu gạch ngang (-) thay vì mặc định
dải phân cách.

Đối với các địa chỉ Bluetooth, bộ xác định ZZ0000ZZ sẽ được sử dụng sau ZZ0001ZZ
công cụ xác định sử dụng thứ tự byte đảo ngược phù hợp với việc giải thích trực quan
địa chỉ Bluetooth theo thứ tự endian nhỏ.

Đã được thông qua bằng cách tham khảo.

Địa chỉ IPv4
--------------

::

%pI4 1.2.3.4
	%pi4 001.002.003.004
	%p[Ii]4[hnbl]

Để in địa chỉ thập phân được phân tách bằng dấu chấm của IPv4. ZZ0000ZZ và ZZ0001ZZ
các công cụ xác định dẫn đến một địa chỉ được in có (i4) hoặc không có (I4) ở đầu
số không.

Các thông số bổ sung ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ được sử dụng để chỉ định
máy chủ, mạng, địa chỉ thứ tự endian lớn hay nhỏ tương ứng. Ở đâu
không có thông số xác định nào được cung cấp, mạng mặc định/thứ tự big endian được sử dụng.

Đã được thông qua bằng cách tham khảo.

Địa chỉ IPv6
--------------

::

%pI6 0001:0002:0003:0004:0005:0006:0007:0008
	%pi6 00010002000300040005000600070008
	%pI6c 1:2:3:4:5:6:7:8

Để in địa chỉ hex 16 bit theo thứ tự mạng IPv6. ZZ0000ZZ và ZZ0001ZZ
công cụ xác định dẫn đến địa chỉ được in có (I6) hoặc không có (i6)
máy tách ruột. Số 0 đứng đầu luôn được sử dụng.

Công cụ xác định ZZ0000ZZ bổ sung có thể được sử dụng với công cụ xác định ZZ0001ZZ để
in địa chỉ IPv6 nén như được mô tả bởi
ZZ0002ZZ

Đã được thông qua bằng cách tham khảo.

Địa chỉ IPv4/IPv6 (chung, có cổng, thông tin luồng, phạm vi)
------------------------------------------------------------

::

%pIS 1.2.3.4 hoặc 0001:0002:0003:0004:0005:0006:0007:0008
	%piS 001.002.003.004 hoặc 00010002000300040005000600070008
	%pISc 1.2.3.4 hoặc 1:2:3:4:5:6:7:8
	%pISpc 1.2.3.4:12345 hoặc [1:2:3:4:5:6:7:8]:12345
	%p[Ii]S[pfschnbl]

Để in địa chỉ IP mà không cần phân biệt xem đó có phải là địa chỉ IP không
gõ AF_INET hoặc AF_INET6. Một con trỏ tới một sockaddr struct hợp lệ,
được chỉ định thông qua ZZ0000ZZ hoặc ZZ0001ZZ, có thể được chuyển đến công cụ xác định định dạng này.

Các bộ xác định ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ bổ sung được sử dụng để chỉ định cổng
(IPv4, IPv6), thông tin luồng (IPv6) và phạm vi (IPv6). Các cổng có tiền tố ZZ0003ZZ,
flowinfo a ZZ0004ZZ và phạm vi ZZ0005ZZ, mỗi giá trị theo sau là giá trị thực.

Trong trường hợp địa chỉ IPv6, địa chỉ IPv6 được nén như được mô tả bởi
ZZ0006ZZ đang được sử dụng nếu bổ sung
chỉ định ZZ0000ZZ được đưa ra. Địa chỉ IPv6 được bao quanh bởi ZZ0001ZZ, ZZ0002ZZ trong
trường hợp chỉ định bổ sung ZZ0003ZZ, ZZ0004ZZ hoặc ZZ0005ZZ theo đề xuất của
ZZ0007ZZ

Trong trường hợp địa chỉ IPv4, ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ bổ sung
công cụ xác định cũng có thể được sử dụng và bị bỏ qua trong trường hợp IPv6
địa chỉ.

Đã được thông qua bằng cách tham khảo.

Các ví dụ khác::

%pISfc 1.2.3.4 hoặc [1:2:3:4:5:6:7:8]/123456789
	%pISsc 1.2.3.4 hoặc [1:2:3:4:5:6:7:8]%1234567890
	%pISpfc 1.2.3.4:12345 hoặc [1:2:3:4:5:6:7:8]:12345/123456789

Địa chỉ UUID/GUID
-------------------

::

%pUb 00010203-0405-0607-0809-0a0b0c0d0e0f
	%pUB 00010203-0405-0607-0809-0A0B0C0D0E0F
	%pUl 03020100-0504-0706-0809-0a0b0c0e0e0f
	%pUL 03020100-0504-0706-0809-0A0B0C0E0E0F

Để in địa chỉ UUID/GUID 16 byte. ZZ0000ZZ, ZZ0001ZZ bổ sung,
Các bộ xác định ZZ0002ZZ và ZZ0003ZZ được sử dụng để chỉ định một thứ tự endian nhỏ trong
ký hiệu hex chữ thường (l) hoặc chữ hoa (L) - và thứ tự endian lớn ở chữ thường (b)
hoặc ký hiệu hex chữ hoa (B).

Khi không có thông số bổ sung nào được sử dụng, big endian mặc định
thứ tự có ký hiệu hex chữ thường sẽ được in.

Đã được thông qua bằng cách tham khảo.

tên nha khoa
------------

::

%pd{,2,3,4}
	%pD{,2,3,4}

Để in tên nha khoa; nếu chúng ta chạy đua với ZZ0000ZZ, cái tên đó có thể
là sự kết hợp giữa cái cũ và cái mới, nhưng nó sẽ không thành công.  Nha khoa %pd an toàn hơn
tương đương với %s dentry->d_name.name chúng ta thường sử dụng, %pd<n> in ZZ0001ZZ
thành phần cuối cùng.  %pD thực hiện tương tự với tệp cấu trúc.

Đã được thông qua bằng cách tham khảo.

tên block_thiết bị
------------------

::

%pg sda, sda1 hoặc loop0p1

Để in tên của con trỏ block_device.

cấu trúc va_format
------------------

::

%pV

Để in cấu trúc struct va_format. Chúng chứa một chuỗi định dạng
và va_list như sau::

cấu trúc va_format {
		const char *fmt;
		va_list *va;
	};

Triển khai "đệ quy vsnprintf".

Không sử dụng tính năng này nếu không có cơ chế nào đó để xác minh
tính chính xác của chuỗi định dạng và đối số va_list.

Đã được thông qua bằng cách tham khảo.

Nút cây thiết bị
-----------------

::

%pOF[fnpPcCF]


Để in cấu trúc nút cây của thiết bị. Hành vi mặc định là
tương đương với %pOFf.

- f - nút thiết bị full_name
	- n - tên nút thiết bị
	- p - ph điểm nút thiết bị
	- P - thông số đường dẫn nút thiết bị (tên + @unit)
	- F - cờ nút thiết bị
	- c - chuỗi tương thích chính
	- C - chuỗi tương thích đầy đủ

Dấu phân cách khi sử dụng nhiều đối số là ':'

Ví dụ::

%pOF /foo/bar@0 - Tên đầy đủ của nút
	%pOFf /foo/bar@0 - Tương tự như trên
	%pOFfp /foo/bar@0:10 - Tên đầy đủ của nút + phân hiệu
	%pOFfcF /foo/bar@0:foo,device:--P- - Tên đầy đủ của nút +
	                                          chuỗi tương thích chính +
						  cờ nút
							D - năng động
							d - tách ra
							P - Dân cư
							B – Xe buýt đông người

Đã được thông qua bằng cách tham khảo.

Tay cầm Fwnode
--------------

::

%pfw[fP]

Để in thông tin trên fwnode_handle. Mặc định là in đầy đủ
tên nút, bao gồm cả đường dẫn. Các sửa đổi có chức năng tương đương với
%pOF ở trên.

- f - tên đầy đủ của nút, bao gồm cả đường dẫn
	- P - tên của nút bao gồm địa chỉ (nếu có)

Ví dụ (ACPI)::

%pfwf \_SB.PCI0.CIO2.port@1.endpoint@0 - Tên nút đầy đủ
	%pfwP điểm cuối@0 - Tên nút

Ví dụ (OF)::

%pfwf /ocp@68000000/i2c@48072000/Camera@10/port/endpoint - Tên đầy đủ
	Điểm cuối %pfwP - Tên nút

Ngày và giờ
-------------

::

%pt[RT] YYYY-mm-ddTHH:MM:SS
	%pt[RT]s YYYY-mm-dd HH:MM:SS
	%pt[RT]d YYYY-mm-dd
	%pt[RT]t HH:MM:SS
	%ptSp <giây>.<nano giây>
	%pt[RST][dt][r][s]

Để in ngày và giờ được biểu thị bằng::

Nội dung R của struct rtc_time
	Nội dung S của struct timespec64
	Loại thời gian T64_t

ở định dạng con người có thể đọc được.

Theo mặc định, năm sẽ tăng thêm 1900 và tháng tăng thêm 1.
Sử dụng %pt[RT]r (thô) để ngăn chặn hành vi này.

%pt[RT]s (dấu cách) sẽ ghi đè dấu phân cách ISO 8601 bằng cách sử dụng '' (dấu cách)
thay vì 'T' (viết hoa T) giữa ngày và giờ. Nó sẽ không có tác dụng gì
khi ngày hoặc thời gian bị bỏ qua.

%ptSp tương đương với %lld.%09ld đối với nội dung của struct timespec64.
Khi các chỉ định khác được đưa ra, nó sẽ tương đương với
%ptT[dt][r][s].%09ld. Nói cách khác, số giây đang được in
định dạng mà con người có thể đọc được theo sau là dấu chấm và nano giây.

Đã được thông qua bằng cách tham khảo.

cấu trúc clk
------------

::

%pC xin vui lòng1

Để in cấu trúc struct clk. %pC in tên đồng hồ
(Khung đồng hồ chung) hoặc ID 32 bit duy nhất (khung đồng hồ cũ).

Đã được thông qua bằng cách tham khảo.

bitmap và các dẫn xuất của nó như cpumask và nodemask
-------------------------------------------------------

::

%*pb 0779
	%*pbl 0,3-6,8-10

Để in bitmap và các dẫn xuất của nó như cpumask và nodemask,
%*pb outputs the bitmap with field width as the number of bits and %*pbl
xuất bitmap dưới dạng danh sách phạm vi với độ rộng trường là số bit.

Độ rộng trường được truyền theo giá trị, bitmap được truyền theo tham chiếu.
Các macro trợ giúp cpumask_pr_args() và nodemask_pr_args() có sẵn để dễ dàng sử dụng
in cpumask và nodemask.

Gắn cờ các trường bit như cờ trang và gfp_flags
--------------------------------------------------------

::

%pGp 0x17ffffc0002036(tham chiếu|uptodate|lru|active|private|node=0|zone=2|lastcpupid=0x1fffff)
	%pGg GFP_USERZZ0003ZZGFP_NOWARN
	%pGv read|exec|mayread|maywrite|mayexec|denywrite

Để in các trường bit cờ dưới dạng tập hợp các hằng số ký hiệu
sẽ xây dựng giá trị. Loại cờ được đưa ra bởi người thứ ba
nhân vật. Hiện được hỗ trợ là:

- p - [p]cờ tuổi, giá trị kỳ vọng thuộc loại (ZZ0000ZZ)
        - v - [v]ma_flags, giá trị mong đợi thuộc loại (ZZ0001ZZ)
        - g - [g]fp_flags, giá trị mong đợi thuộc loại (ZZ0002ZZ)

Tên cờ và thứ tự in phụ thuộc vào loại cụ thể.

Lưu ý rằng định dạng này không nên được sử dụng trực tiếp trong
ZZ0000ZZ một phần của điểm theo dõi. Thay vào đó, hãy sử dụng show_*_flags()
hoạt động từ <trace/events/mmflags.h>.

Đã được thông qua bằng cách tham khảo.

Tính năng thiết bị mạng
-----------------------

::

%pNF 0x000000000000c000

Để in netdev_features_t.

Đã được thông qua bằng cách tham khảo.

Mã FourCC V4L2 và DRM (định dạng pixel)
---------------------------------------

::

%p4cc

In mã FourCC được sử dụng bởi V4L2 hoặc DRM, bao gồm độ bền định dạng và
giá trị số của nó là thập lục phân.

Đã được thông qua bằng cách tham khảo.

Ví dụ::

%p4cc BG12 endian nhỏ (0x32314742)
	%p4cc Y10 endian nhỏ (0x20303159)
	%p4cc NV12 phiên bản lớn (0xb231564e)

Mã FourCC chung
-------------------

::
	%p4c[h[R]lb] gP00 (0x67503030)

In mã FourCC chung, dưới dạng cả ký tự ASCII và số của nó
giá trị dưới dạng thập lục phân.

Mã FourCC chung luôn được in ở định dạng big-endian,
byte quan trọng nhất đầu tiên. Điều này trái ngược với FourCC V4L/DRM.

Các bộ xác định ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ bổ sung xác định những gì
endianness được sử dụng để tải các byte được lưu trữ. Dữ liệu có thể được diễn giải
sử dụng máy chủ, đảo ngược thứ tự byte của máy chủ, endian nhỏ hoặc endian lớn.

Đã được thông qua bằng cách tham khảo.

Ví dụ về máy endian nhỏ, đã cho &(u32)0x67503030::

%p4ch gP00 (0x67503030)
	%p4chR 00Pg (0x30305067)
	%p4cl gP00 (0x67503030)
	%p4cb 00Pg (0x30305067)

Ví dụ về máy lớn, cho trước &(u32)0x67503030::

%p4ch gP00 (0x67503030)
	%p4chR 00Pg (0x30305067)
	%p4cl 00Pg (0x30305067)
	%p4cb gP00 (0x67503030)

rỉ sét
------

::

%pA

Chỉ nhằm mục đích sử dụng từ mã Rust sang định dạng ZZ0000ZZ.
ZZ0001ZZ có sử dụng nó từ C.

Cảm ơn
======

Nếu bạn thêm các phần mở rộng %p khác, vui lòng mở rộng <lib/tests/printf_kunit.c>
với một hoặc nhiều trường hợp thử nghiệm, nếu khả thi.

Cảm ơn sự hợp tác và quan tâm của bạn.
