.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/descore-readme.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===============================================
Mã hóa và giải mã DES nhanh chóng và di động
===============================================

.. note::

   Below is the original README file from the descore.shar package,
   converted to ReST format.

------------------------------------------------------------------------------

des - mã hóa và giải mã DES nhanh chóng và di động.

Bản quyền ZZ0000ZZ 1992 Dana L. Làm thế nào

Chương trình này là phần mềm miễn phí; bạn có thể phân phối lại nó và/hoặc sửa đổi
nó theo các điều khoản của Giấy phép Công cộng Chung của Thư viện GNU do
Tổ chức Phần mềm Tự do; phiên bản 2 của Giấy phép, hoặc
(theo lựa chọn của bạn) bất kỳ phiên bản mới hơn.

Chương trình này được phân phối với hy vọng rằng nó sẽ hữu ích,
nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
Giấy phép Công cộng Chung của Thư viện GNU để biết thêm chi tiết.

Bạn hẳn đã nhận được một bản sao Giấy phép Công cộng Chung của Thư viện GNU
cùng với chương trình này; nếu không, hãy viết thư cho Phần mềm miễn phí
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.

Địa chỉ của tác giả:how@isl.stanford.edu

.. README,v 1.15 1992/05/20 00:25:32 how E

==>> Để biên dịch sau khi hủy ghi chú/hủy chia sẻ, chỉ cần ZZ0000ZZ <<==

Gói này được thiết kế với các mục tiêu sau:

1. PERFORMANCE mã hóa/giải mã cao nhất có thể.
2. PORTABILITY tới bất kỳ máy chủ có địa chỉ byte nào có loại C không dấu 32 bit
3. Thay thế tương thích với phích cắm cho các thói quen cấp thấp của KERBEROS.

Phiên bản thứ hai này bao gồm một số cải tiến hiệu suất cho
máy bị thiếu đăng ký.  Cuộc thảo luận của tôi với Richard Outerbridge,
71755.204@compuserve.com, đã đưa ra một số cải tiến này.

Để hiểu nhanh hơn mã trong gói này, hãy kiểm tra desSmallFips.i
(được tạo bằng cách gõ ZZ0000ZZ) BEFORE bạn giải quyết desCode.h.  Cái sau được thiết lập
theo kiểu được tham số hóa để có thể dễ dàng sửa đổi bằng speed-daemon
tin tặc đang theo đuổi micro giây cuối cùng đó.  Bạn sẽ tìm thấy nó nhiều hơn
chiếu sáng để kiểm tra một việc thực hiện cụ thể,
và sau đó chuyển sang bộ xương trừu tượng chung có lưu ý đến bộ xương này.


so sánh hiệu suất với mã des có sẵn khác mà tôi có thể
biên dịch trên SPARCStation 1 (cc -O4, gcc -O2):

mã này (độc lập thứ tự byte):

- 30us cho mỗi lần mã hóa (tùy chọn: 64k bảng, không có IP/FP)
  - 33us cho mỗi lần mã hóa (tùy chọn: 64k bảng, thứ tự bit tiêu chuẩn FIPS)
  - 45us cho mỗi lần mã hóa (tùy chọn: 2k bảng, không có IP/FP)
  - 48us cho mỗi lần mã hóa (tùy chọn: bảng 2k, thứ tự bit tiêu chuẩn FIPS)
  - 275us để đặt key mới (dùng 1k bảng key)

cái này có quy trình mã hóa/giải mã nhanh nhất mà tôi từng thấy.
	vì tôi quan tâm đến bộ lọc des nhanh hơn là mật mã(3)
	và bẻ khóa mật khẩu, tôi thực sự chưa bận tâm đến việc tăng tốc
	thói quen thiết lập phím. Ngoài ra, tôi không có hứng thú thực hiện lại
	tất cả những thứ rác rưởi khác trong thư viện mit kerberos des, nên tôi vừa
	đã cung cấp cho các thói quen của tôi những giao diện sơ khai nhỏ để chúng có thể
	được sử dụng để thay thế bằng mã của mit hoặc bất kỳ mit-
	gói tương thích bên dưới. (lưu ý rằng hai thời gian đầu tiên ở trên
	rất khác nhau do hiệu ứng bộ đệm).

kerberos des thay thế từ Úc (phiên bản 1.95):

- 53us cho mỗi lần mã hóa (sử dụng 2k bảng)
  - 96us để đặt key mới (sử dụng 2,25k bảng key)

vì vậy mặc dù tác giả đã đưa vào một số phần trình diễn
	những cải tiến tôi đã đề xuất với anh ấy, gói này
	mã hóa/giải mã vẫn chậm hơn trên sparc và 68000.
	cụ thể hơn là chậm hơn 19-40% trên 68020 và chậm hơn 11-35%
	trên sparc, tùy thuộc vào trình biên dịch;
	đầy đủ chi tiết đẫm máu (ALT_ECB là một biến thể libdes):

================ ============================== ===================
	máy biên dịch desCore libdes ALT_ECB chậm hơn bởi
	================ ============================== ===================
	gcc 2.1 -O2 Mặt Trời 3/110 304 Mỹ 369.5uS 461.8uS 22%
	cc -O1 Sun 3/110 336 Mỹ 436.6uS 399.3uS 19%
	cc -O2 Mặt Trời 3/110 360 Mỹ 532.4uS 505.1uS 40%
	cc -O4 Sun 3/110 365 Mỹ 532.3uS 505.3uS 38%
	gcc 2.1 -O2 Sun 4/50 48 Mỹ 53,4uS 57,5uS 11%
	cc -O2 Mặt Trời 4/50 48 Mỹ 64.6uS 64.7uS 35%
	cc -O4 Mặt Trời 4/50 48 Mỹ 64.7uS 64.9uS 35%
	================ ============================== ===================

(số đo thời gian của tôi không chính xác bằng của anh ấy).

các nhận xét trong bản phát hành desCore đầu tiên của tôi trên phiên bản 1.92:

- 68us cho mỗi lần mã hóa (sử dụng 2k bảng)
   - 96us để đặt key mới (sử dụng 2,25k bảng key)

đây là một gói rất hay, thực hiện những điều quan trọng nhất
	về những tối ưu hóa mà tôi đã thực hiện trong quy trình mã hóa của mình.
	nó hơi yếu trong việc tối ưu hóa ở mức độ thấp thông thường, đó là lý do tại sao
	nó chậm hơn 39%-106%.  bởi vì anh ấy quan tâm đến việc mã hóa nhanh(3) và
	các ứng dụng bẻ khóa mật khẩu, anh ấy cũng sử dụng ý tưởng tương tự để
	tăng tốc quá trình cài đặt phím với kết quả ấn tượng.
	(tại một số điểm tôi có thể làm tương tự trong gói của mình).  anh ấy cũng thực hiện
	phần còn lại của thư viện mit des.

(mã từ eay@psych.psy.uq.oz.au qua comp.sources.misc)

gói fast crypt(3) từ Đan Mạch:

quy trình des ở đây được chôn bên trong một vòng lặp để thực hiện
	crypt và tôi không muốn xé nó ra và đo
	hiệu suất. mã của anh ấy cần 26 lệnh sparc để tính một lệnh
	des lặp lại; ở trên, Nhanh (64k) mất 21 và Nhỏ (2k) mất 37.
	anh ta tuyên bố sử dụng 280k bảng nhưng tính toán lặp lại có vẻ
	chỉ sử dụng 128k.  các bảng và mã của anh ấy độc lập với máy.

(mã từ Glad@daimi.aau.dk qua alt.sources hoặc comp.sources.misc)

Thụy Điển triển khai lại thư viện Kerberos des

- 108us cho mỗi lần mã hóa (sử dụng bảng trị giá 34k)
  - 134us để đặt key mới (dùng 32k bảng key để có tốc độ này!)

các bảng được sử dụng dường như độc lập với máy;
	có vẻ như anh ấy đã đưa vào rất nhiều mã trường hợp đặc biệt
	do đó, ví dụ: có thể sử dụng tải ZZ0000ZZ thay vì 4 tải ZZ0001ZZ
	khi kiến trúc của máy cho phép điều đó.

(mã lấy từ chalmers.se:pub/des)

gói crack 3.3c từ Anh:

như trong crypt ở trên, quy trình des được chôn trong một vòng lặp. đó là
	cũng rất sửa đổi cho mật mã.  mã lặp của anh ấy sử dụng 16k
	của các bảng và có vẻ chậm.

(mã lấy từ aem@aber.ac.uk qua alt.sources hoặc comp.sources.misc)

ZZ0000ZZ và mã Kerberos/Athena được điều chỉnh (phụ thuộc vào thứ tự byte):

- 165us cho mỗi lần mã hóa (sử dụng bảng trị giá 6k)
  - 478us để đặt key mới (sử dụng <1k bảng key)

vì vậy bất chấp những nhận xét trong mã này, vẫn có thể nhận được
	mã AND nhanh hơn, tạo các bảng nhỏ hơn cũng như tạo các bảng
	độc lập với máy.
	(mã lấy từ prep.ai.mit.edu)

Mã UC Berkeley (phụ thuộc vào độ kết thúc của máy):
  - 226us cho mỗi lần mã hóa
  - 10848us để đặt chìa khóa mới

kích thước bàn không rõ ràng, nhưng trông chúng không nhỏ lắm
	(mã thu được từ wuarchive.wustl.edu)


động lực và lịch sử
======================

cách đây một thời gian tôi muốn có một số quy trình và các quy trình được ghi lại trên Sun's
các trang man không tồn tại hoặc bị loại bỏ lõi.  tôi đã nghe nói về kerberos,
và biết rằng nó sử dụng des, nên tôi nghĩ tôi sẽ sử dụng các chương trình của nó.  nhưng một lần
tôi đã hiểu và xem mã, nó thực sự gây ra nhiều sự khó chịu -
nó quá phức tạp, mã đã được viết mà không cần lấy
lợi thế của cấu trúc hoạt động thông thường như IP, E và FP
(tức là tác giả đã không ngồi xuống và suy nghĩ trước khi viết mã),
nó quá chậm, tác giả đã cố gắng làm rõ mã
bằng cách thêm các câu lệnh MORE để làm cho dữ liệu di chuyển nhiều hơn ZZ0000ZZ
thay vì đơn giản hóa việc thực hiện và cắt giảm tất cả dữ liệu
chuyển động (đặc biệt là việc anh ấy sử dụng L1, R1, L2, R2) và nó chứa đầy
ZZ0001ZZ ngu ngốc dành cho các máy cụ thể không mang lại hiệu quả đáng kể
tăng tốc nhưng điều đó đã làm xáo trộn mọi thứ.  vì vậy tôi đã lấy dữ liệu thử nghiệm
khỏi chương trình xác minh của anh ấy và viết lại mọi thứ khác.

Một lúc sau, tôi tình cờ thấy gói crypt(3) tuyệt vời được đề cập ở trên.
thực tế là anh chàng này đang tính toán 2 hộp cho mỗi bảng tra cứu thay vì
hơn một (và việc sử dụng bảng lớn hơn MUCH trong quá trình này) đã khuyến khích tôi
làm điều tương tự - đó là một sự thay đổi tầm thường mà tôi đã sợ hãi
bởi kích thước bảng lớn hơn.  trong trường hợp của anh ấy, anh ấy đã không nhận ra rằng bạn không cần phải giữ
dữ liệu làm việc ở dạng TWO, một dạng để dễ dàng sử dụng một nửa số hộp trong
lập chỉ mục, nửa còn lại để dễ sử dụng; thay vào đó bạn có thể giữ
nó ở dạng cho nửa đầu và sử dụng thao tác xoay đơn giản để lấy nửa còn lại
một nửa.  điều này có nghĩa là tôi có (gần như) một nửa thao tác dữ liệu và một nửa
kích thước bàn.  công bằng mà nói thì có thể anh ấy đang mã hóa thứ gì đó đặc biệt
vào crypt(3) trong bảng của anh ấy - tôi đã không kiểm tra.

tôi rất vui vì tôi đã triển khai nó theo cách tôi đã làm, vì phiên bản C này là
di động (ifdef là cải tiến hiệu suất) và nó nhanh hơn
hơn các phiên bản viết tay trong hội cho sparc!


ghi chú chuyển
=============

một điều tôi không muốn làm là viết một mớ hỗn độn
phụ thuộc vào độ kết thúc và các vấn đề khác của máy,
và nhất thiết phải tạo ra mã khác nhau và các bảng tra cứu khác nhau
cho các máy khác nhau.  xem mã kerberos để biết ví dụ
về điều tôi không muốn làm; tất cả ZZ0000ZZ dành riêng cho kết thúc của họ
làm xáo trộn mã và cuối cùng chậm hơn một máy đơn giản hơn
cách tiếp cận độc lập.  tuy nhiên, luôn có một số tính di động
những cân nhắc nào đó, và tôi đã đưa vào một số lựa chọn
cho số lượng biến đăng ký khác nhau.
có lẽ một số người vẫn sẽ coi kết quả là một mớ hỗn độn!

1) tôi cho rằng mọi thứ đều có thể định địa chỉ theo byte, mặc dù thực tế tôi không
   phụ thuộc vào thứ tự byte và byte đó là 8 bit.
   tôi cho rằng con trỏ từ có thể được tự do truyền tới và đi từ con trỏ char.
   lưu ý rằng 99% chương trình C đưa ra những giả định này.
   tôi luôn sử dụng ký tự không dấu nếu có thể đặt bit cao.
2) typedef ZZ0000ZZ có nghĩa là loại tích phân không dấu 32 bit.
   nếu ZZ0001ZZ không phải là 32 bit, hãy thay đổi typedef trong desCore.h.
   tôi giả sử sizeof(word) == 4 EVERYWHERE.

chi phí (trong trường hợp xấu nhất) của chiếc NOT của tôi khi thực hiện tối ưu hóa theo mục đích cụ thể
trong mã tải và lưu trữ dữ liệu xung quanh các lần lặp chính
là dưới 12%.  Ngoài ra còn có một lợi ích bổ sung là
khu vực làm việc đầu vào và đầu ra không cần phải căn chỉnh theo từ.


Tối ưu hóa hiệu suất OPTIONAL
==================================

1) bạn nên xác định một trong số ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ hoặc ZZ0003ZZ
   bất kỳ cái nào gần nhất với khả năng của máy của bạn.
   hãy xem phần đầu của desCode.h để biết chính xác lựa chọn này ngụ ý gì.
   lưu ý nếu chọn sai thì mã des vẫn có tác dụng;
   đây chỉ là những điều chỉnh về hiệu suất.
2) đối với những người có từ khóa ZZ0004ZZ chức năng: bạn nên thay đổi
   Các macro ROR và ROL để sử dụng hướng dẫn xoay máy nếu bạn có.
   điều này sẽ lưu 2 hướng dẫn và một hướng dẫn tạm thời cho mỗi lần sử dụng,
   hoặc khoảng 32 đến 40 hướng dẫn cho mỗi lần giải mã.

lưu ý rằng gcc đủ thông minh để dịch các macro ROL/R sang
   máy quay!

tất cả những tối ưu hóa này đều khá phức tạp, nhưng với chúng, bạn nên
có thể đạt được hiệu suất tương đương với mã hóa lắp ráp, ngoại trừ:

1) do thiếu toán tử xoay bit trong C, nên các phép quay phải được tổng hợp
   từ ca làm việc.  vì vậy việc truy cập vào ZZ0000ZZ sẽ tăng tốc mọi thứ nếu máy của bạn
   đã xoay, như đã giải thích ở trên trong (3) (không cần thiết nếu bạn sử dụng gcc).
2) nếu máy của bạn có ít hơn 12 thanh ghi 32 bit, tôi nghi ngờ trình biên dịch của bạn sẽ
   tạo mã tốt.

ZZ0000ZZ cố gắng định cấu hình mã cho 386 bằng cách chỉ khai báo 3 thanh ghi
   (có vẻ như gcc có thể sử dụng ebx, esi và edi để giữ các biến đăng ký).
   tuy nhiên, nếu bạn thích mã hóa lắp ráp, 386 có 7 thanh ghi 32 bit,
   và nếu bạn sử dụng ALL trong số chúng, hãy sử dụng chế độ địa chỉ ZZ0001ZZ với độ dịch chuyển
   và các thủ thuật khác, bạn có thể có được các quy trình hợp lý cho DesQuickCore... với
   khoảng 250 hướng dẫn mỗi cái.  Đối với DesSmall... nó sẽ giúp sắp xếp lại
   des_keymap, tức là bây giờ sbox # is là phần cao nhất của chỉ mục và
   6 bit dữ liệu là phần thấp; nó giúp trao đổi những thứ này.

vì tôi không có cách nào để kiểm tra nó một cách thuận tiện nên tôi chưa cung cấp
   phiên bản 386 có dây giày.  lưu ý rằng với bản phát hành desCore này, gcc có thể
   để đặt mọi thứ vào sổ đăng ký (!), và tạo ra khoảng 370 lệnh mỗi cái
   cho các quy trình DesQuickCore...!

ghi chú mã hóa
============

mỗi quy trình en/giải mã sử dụng 6 biến đăng ký cần thiết,
với 4 được sử dụng tích cực cùng một lúc trong các lần lặp bên trong.
nếu bạn không có 4 biến đăng ký, hãy lấy một máy mới.
tối đa 8 thanh ghi nữa được sử dụng để giữ các hằng số trong một số cấu hình.

tôi cho rằng việc sử dụng hằng số đắt hơn sử dụng thanh ghi:

a) Ngoài ra, tôi đã cố gắng đưa các hằng số lớn hơn vào sổ đăng ký.
   mức độ ưu tiên đăng ký như sau:

- bất cứ thứ gì nhiều hơn 12 bit (xấu đối với RISC và CISC)
	- giá trị lớn hơn 127 (không thể sử dụng movq hoặc byte ngay lập tức trên CISC)
	- 9-127 (có thể không sử dụng được CISC shift ngay lập tức hoặc thêm/sub nhanh),
	- 1-8 chưa bao giờ được đăng ký, là hằng số rẻ nhất.

b) trình biên dịch có thể quá ngu ngốc để nhận ra table và table+256 nên
   được gán cho các thanh ghi hằng số khác nhau và thay vào đó lặp đi lặp lại
   thực hiện phép tính, vì vậy tôi gán chúng cho các biến thanh ghi ZZ0000ZZ rõ ràng
   khi có thể và hữu ích.

tôi cho rằng việc lập chỉ mục rẻ hơn hoặc tương đương với việc tăng/giảm tự động,
trong đó chỉ mục là 7 bit không dấu hoặc nhỏ hơn.
giả định này bị đảo ngược đối với 68k và vax.

tôi cho rằng địa chỉ có thể được hình thành một cách rẻ tiền từ hai thanh ghi,
hoặc từ một thanh ghi và một hằng số nhỏ.
đối với 68000, dạng ZZ0000ZZ được sử dụng ít.
tất cả việc chia tỷ lệ chỉ mục được thực hiện một cách rõ ràng - không có sự thay đổi ẩn nào bởi log2(sizeof).

mã được viết sao cho ngay cả một trình biên dịch ngu ngốc cũng
không bao giờ cần nhiều hơn một ẩn tạm thời,
tăng cơ hội mọi thứ sẽ nằm gọn trong sổ đăng ký.
KEEP THIS MORE SUBTLE POINT TRONG MIND NẾU YOU REWRITE ANYTHING.

(trên thực tế, hiện nay có một số đoạn mã yêu cầu hai tốc độ,
nhưng việc sửa nó sẽ phá vỡ cấu trúc của macro hoặc
yêu cầu khai báo tạm thời khác).


định dạng dữ liệu hiệu quả đặc biệt
==============================

hầu hết thời gian các bit được thao tác theo cách sắp xếp này (S7 S5 S3 S1)::

003130292827xxxx242322212019xxxx161514131211xxxx080706050403xxxx

(các bit x vẫn còn đó, tôi chỉ nhấn mạnh vị trí của các hộp S).
các bit được quay sang trái 4 khi tính toán S6 S4 S2 S0::

282726252423xxxx201918171615xxxx121110090807xxxx040302010031xxxx

hai bit ngoài cùng bên phải thường bị xóa để có thể sử dụng byte thấp hơn
dưới dạng chỉ mục vào bảng ánh xạ sbox. hai bit x'd tiếp theo được đặt
tới các giá trị khác nhau để truy cập các phần khác nhau của bảng.


cách sử dụng các quy trình

kiểu dữ liệu:
	con trỏ tới vùng 8 byte kiểu DesData
	được sử dụng để giữ các phím và khối đầu vào/đầu ra cho des.

con trỏ tới vùng 128 byte kiểu DesKeys
	được sử dụng để giữ khóa 768 bit đầy đủ.
	phải được căn chỉnh lâu dài.

DesQuickInit()
	gọi điều này trước khi sử dụng bất kỳ quy trình nào khác có ZZ0000ZZ trong tên của nó.
	nó tạo ra bảng 64k đặc biệt mà các thủ tục này cần.
DesQuickDone()
	giải phóng bảng này

DesMethod(m, k)
	m trỏ đến khối 128byte, k trỏ đến khóa des 8 byte
	phải có tính chẵn lẻ lẻ (hoặc -1 được trả về) và phải
	không phải là khóa yếu (bán) (hoặc -2 được trả về).
	thông thường DesMethod() trả về 0.

m được điền từ k sao cho khi một trong các thủ tục dưới đây
	được gọi với m, thủ tục sẽ hoạt động giống như tiêu chuẩn des
	en/giải mã bằng khóa k. nếu bạn sử dụng DesMethod,
	bạn cung cấp khóa 56bit tiêu chuẩn; tuy nhiên, nếu bạn điền vào
	Bản thân tôi, bạn sẽ nhận được khóa 768bit - nhưng sau đó thì không
	được tiêu chuẩn.  đó là 768bit chứ không phải 1024 vì ít quan trọng nhất
	hai bit của mỗi byte không được sử dụng.  lưu ý rằng hai bit này
	sẽ được đặt thành các hằng số ma thuật giúp tăng tốc độ mã hóa/giải mã
	trên một số máy.  và vâng, mỗi byte điều khiển
	một sbox cụ thể trong một lần lặp cụ thể.

bạn thực sự không nên sử dụng trực tiếp định dạng 768bit;  tôi nên
	cung cấp một thủ tục chuyển đổi 128 byte 6 bit (được chỉ định trong
	Thứ tự ánh xạ hộp S hoặc thứ gì đó) sang định dạng phù hợp với bạn.
	điều này sẽ đòi hỏi một số phép nối và xoay byte.

Des{Small|Quick}{Fips|Core}{Encrypt|Decrypt}(d, m, s)
	thực hiện des trên 8 byte tại s thành 8 byte tại
	ZZ0000ZZ.

sử dụng m làm khóa 768bit như đã giải thích ở trên.

sự lựa chọn Mã hóa | Giải mã là hiển nhiên.

Fips|Core xác định xem FIPS ban đầu có hoàn toàn chuẩn hay không
	và hoán vị cuối cùng được thực hiện; nếu không thì dữ liệu sẽ được tải
	và được lưu trữ theo thứ tự bit không chuẩn (FIPS không có IP/FP).

Fips làm chậm Nhanh 10%, Nhỏ 9%.

Nhỏ | Nhanh xác định xem bạn có sử dụng quy trình bình thường hay không
	hoặc một cách nhanh chóng điên cuồng ngốn thêm 64k bộ nhớ.
	Nhỏ chậm hơn 50% so với Nhanh, nhưng Nhanh cần gấp 32 lần
	trí nhớ.  Quick được bao gồm cho các chương trình không làm gì khác ngoài DES,
	ví dụ: bộ lọc mã hóa, v.v.


Bắt nó biên dịch trên máy của bạn
=====================================

không có sự phụ thuộc vào máy trong mã (xem phần chuyển),
có lẽ ngoại trừ macro ZZ0000ZZ trong desTest.c.
Các bảng được tạo ALL độc lập với máy.
bạn nên chỉnh sửa Makefile bằng các cờ tối ưu hóa thích hợp
cho trình biên dịch của bạn (tối ưu hóa MAX).


Tăng tốc kerberos (và/hoặc thư viện des của nó)
=============================================

lưu ý rằng tôi đã đưa giao diện tương thích với kerberos vào desUtil.c
thông qua các hàm des_key_sched() và des_ecb_encrypt().
để sử dụng chúng với mã kerberos hoặc mã tương thích với kerberos, hãy đặt desCore.a
trước thư viện tương thích kerberos trên dòng lệnh của trình liên kết của bạn.
bạn không cần phải có #include desCore.h;  chỉ bao gồm tiêu đề
tập tin được cung cấp cùng với thư viện kerberos.

Công dụng khác
==========

các macro trong desCode.h sẽ rất hữu ích cho việc đặt các des nội tuyến
hoạt động trong các quy trình mã hóa phức tạp hơn.