.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/applying-patches.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _applying_patches:

Áp dụng các bản vá cho hạt nhân Linux
++++++++++++++++++++++++++++++++++++

Bản gốc bởi:
	Jesper Juhl, tháng 8 năm 2005

.. note::

   This document is obsolete.  In most cases, rather than using ``patch``
   manually, you'll almost certainly want to look at using Git instead.

Một câu hỏi thường gặp trong Danh sách gửi thư hạt nhân Linux là cách đăng ký
một bản vá cho kernel hay cụ thể hơn là bản vá dành cho kernel cơ sở nào
một trong nhiều cây/cành nên được áp dụng. Hy vọng tài liệu này
sẽ giải thích điều này cho bạn.

Ngoài việc giải thích cách áp dụng và hoàn nguyên các bản vá, một bản tóm tắt
mô tả các cây nhân khác nhau (và các ví dụ về cách áp dụng
bản vá cụ thể của họ) cũng được cung cấp.


Bản vá là gì?
================

Bản vá là một tài liệu văn bản nhỏ chứa nhiều thay đổi giữa hai
các phiên bản khác nhau của cây nguồn. Các bản vá được tạo bằng ZZ0000ZZ
chương trình.

Để áp dụng chính xác một bản vá, bạn cần biết nó được tạo ra từ cơ sở nào
và phiên bản mới nào mà bản vá sẽ thay đổi cây nguồn. Những cái này
cả hai đều phải có trong siêu dữ liệu của tệp bản vá hoặc có thể suy ra
từ tên tập tin.


Làm cách nào để áp dụng hoặc hoàn nguyên một bản vá?
=================================

Bạn áp dụng bản vá bằng chương trình ZZ0000ZZ. Chương trình vá lỗi đọc một khác biệt
(hoặc bản vá) và thực hiện các thay đổi đối với cây nguồn được mô tả trong đó.

Các bản vá cho nhân Linux được tạo tương ứng với thư mục mẹ
giữ thư mục nguồn kernel.

Điều này có nghĩa là đường dẫn đến các tệp bên trong tệp bản vá chứa tên của
thư mục nguồn kernel mà nó được tạo dựa vào (hoặc một số thư mục khác
những cái tên như "a/" và "b/").

Vì tên này khó có thể khớp với tên của thư mục nguồn kernel trên
máy cục bộ (nhưng thường là thông tin hữu ích để xem phiên bản nào khác
bản vá không được gắn nhãn đã được tạo dựa trên), bạn nên đổi sang kernel của mình
thư mục nguồn và sau đó loại bỏ phần tử đầu tiên của đường dẫn khỏi tên tệp
trong tệp vá khi áp dụng nó (đối số ZZ0000ZZ cho ZZ0001ZZ không
cái này).

Để hoàn nguyên bản vá đã áp dụng trước đó, hãy sử dụng đối số -R để vá.
Vì vậy, nếu bạn áp dụng một bản vá như thế này::

vá -p1 < ../patch-x.y.z

Bạn có thể hoàn nguyên (hoàn tác) nó như thế này::

vá -R -p1 < ../patch-x.y.z


Làm cách nào để nạp tệp vá/khác vào ZZ0000ZZ?
=============================================

Điều này (như thường lệ với Linux và các hệ điều hành giống UNIX khác) có thể
được thực hiện theo nhiều cách khác nhau.

Trong tất cả các ví dụ bên dưới, tôi cung cấp tệp (ở dạng không nén) để vá
thông qua stdin bằng cú pháp sau ::

vá -p1 < path/to/patch-x.y.z

Nếu bạn chỉ muốn có thể làm theo các ví dụ dưới đây và không muốn
biết nhiều cách để sử dụng bản vá, thì bạn có thể ngừng đọc phần này
phần ở đây.

Bản vá cũng có thể lấy tên tệp để sử dụng thông qua đối số -i, như
cái này::

vá -p1 -i path/to/patch-x.y.z

Nếu tệp bản vá của bạn được nén bằng gzip hoặc xz và bạn không muốn
Giải nén nó trước khi áp dụng, sau đó bạn có thể nạp nó vào bản vá như thế này
thay vào đó::

đường dẫn xzcat/đến/patch-x.y.z.xz | vá -p1
	đường dẫn bzcat/đến/patch-x.y.z.gz | vá -p1

Nếu bạn muốn giải nén tệp vá lỗi bằng tay trước khi áp dụng nó
(những gì tôi cho là bạn đã làm trong các ví dụ bên dưới), thì bạn chỉ cần chạy
gunzip hoặc xz trên tệp -- như thế này::

bản vá gunzip-x.y.z.gz
	xz -d patch-x.y.z.xz

Điều này sẽ để lại cho bạn một tệp patch-x.y.z văn bản đơn giản mà bạn có thể cung cấp cho
vá thông qua stdin hoặc đối số ZZ0000ZZ, tùy thích.

Một số đối số thú vị khác cho bản vá là ZZ0000ZZ khiến bản vá không hoạt động
ngoại trừ những lỗi rất hữu ích để ngăn lỗi cuộn ra khỏi
màn hình quá nhanh và ZZ0001ZZ khiến bản vá chỉ in danh sách
điều gì sẽ xảy ra, nhưng thực tế không tạo ra bất kỳ thay đổi nào. Cuối cùng là ZZ0002ZZ
yêu cầu bản vá in thêm thông tin về công việc đang được thực hiện.


Các lỗi thường gặp khi patch
===========================

Khi bản vá áp dụng một tệp bản vá, nó sẽ cố gắng xác minh tính đúng đắn của
tập tin theo những cách khác nhau.

Kiểm tra xem tệp có giống tệp vá hợp lệ không và kiểm tra mã
xung quanh các bit được sửa đổi phù hợp với bối cảnh được cung cấp trong bản vá
chỉ có hai trong số các bản vá kiểm tra độ tỉnh táo cơ bản.

Nếu bản vá gặp phải điều gì đó trông không ổn thì nó có hai
tùy chọn. Nó có thể từ chối áp dụng các thay đổi và hủy bỏ hoặc có thể thử
để tìm cách áp dụng bản vá với một vài thay đổi nhỏ.

Một ví dụ về điều gì đó không 'hoàn toàn đúng' mà bản vá sẽ cố gắng giải quyết
cách khắc phục là nếu tất cả ngữ cảnh khớp, các dòng được thay đổi khớp, nhưng
số dòng là khác nhau. Điều này có thể xảy ra, ví dụ, nếu bản vá tạo ra
một sự thay đổi ở giữa tập tin nhưng vì một số lý do mà một vài dòng có
được thêm vào hoặc xóa ở gần đầu tập tin. Trong trường hợp đó
mọi thứ có vẻ ổn, nó chỉ tăng hoặc giảm một chút và bản vá sẽ
thường điều chỉnh số dòng và áp dụng bản vá.

Bất cứ khi nào bản vá áp dụng một bản vá mà nó phải sửa đổi một chút để phù hợp
nó sẽ cho bạn biết về điều đó bằng cách cho biết bản vá được áp dụng với ZZ0000ZZ.
Bạn nên cảnh giác với những thay đổi như vậy vì mặc dù bản vá có thể đã có nó
đúng rồi, nó không /luôn luôn/ làm đúng, và kết quả đôi khi sẽ là
sai.

Khi bản vá gặp một thay đổi mà nó không thể khắc phục được bằng fuzz, nó sẽ từ chối nó
hoàn toàn và để lại một tệp có phần mở rộng ZZ0000ZZ (tệp từ chối). bạn có thể
đọc tệp này để biết chính xác thay đổi nào không thể áp dụng được, vì vậy bạn có thể
hãy sửa nó bằng tay nếu bạn muốn.

Nếu bạn không có bất kỳ bản vá lỗi nào của bên thứ ba được áp dụng cho nguồn kernel của mình, nhưng
chỉ các bản vá từ kernel.org và bạn áp dụng các bản vá theo đúng thứ tự,
và chưa tự mình sửa đổi các tập tin nguồn, thì bạn nên
không bao giờ thấy thông báo lỗi hoặc từ chối từ bản vá. Nếu bạn thấy những tin nhắn như vậy
dù sao đi nữa thì có nguy cơ cao là cây nguồn cục bộ của bạn hoặc
tập tin vá bị hỏng theo một cách nào đó. Trong trường hợp đó có lẽ bạn nên thử
tải xuống lại bản vá và nếu mọi thứ vẫn không ổn thì bạn sẽ được thông báo
để bắt đầu với một cây mới được tải xuống đầy đủ từ kernel.org.

Chúng ta hãy xem xét thêm một chút về một số thông báo mà bản vá có thể tạo ra.

Nếu bản vá dừng lại và hiển thị lời nhắc ZZ0000ZZ thì bản vá không thể
tìm một tập tin để được vá. Rất có thể bạn đã quên chỉ định -p1 hoặc bạn
trong thư mục sai. Ít thường xuyên hơn, bạn sẽ tìm thấy các bản vá cần được
được áp dụng với ZZ0001ZZ thay vì ZZ0002ZZ (đọc tệp vá sẽ tiết lộ nếu
đúng như vậy -- nếu vậy thì đây là lỗi của người tạo ra
miếng vá nhưng không gây tử vong).

Nếu bạn nhận được ZZ0000ZZ hoặc
có thông báo tương tự như vậy thì có nghĩa là patch đó phải điều chỉnh lại vị trí
của sự thay đổi (trong ví dụ này cần phải di chuyển 7 dòng từ nơi nó
dự kiến sẽ thực hiện thay đổi cho phù hợp).

Tệp kết quả có thể ổn hoặc không, tùy thuộc vào lý do tệp
đã khác với mong đợi.

Điều này thường xảy ra nếu bạn cố gắng áp dụng một bản vá được tạo cho một
phiên bản kernel khác với phiên bản bạn đang cố gắng vá.

Nếu bạn nhận được thông báo như ZZ0000ZZ thì điều đó có nghĩa là
bản vá không thể được áp dụng chính xác và chương trình bản vá không thể
làm mờ đường đi của nó. Điều này sẽ tạo ra một tệp ZZ0001ZZ với sự thay đổi
khiến bản vá bị lỗi và tệp ZZ0002ZZ hiển thị cho bạn bản gốc
nội dung không thể thay đổi được.

Nếu bạn nhận được ZZ0000ZZ
sau đó bản vá phát hiện ra rằng thay đổi có trong bản vá dường như có
đã được thực hiện.

Nếu bạn thực sự đã áp dụng bản vá này trước đây và bạn vừa áp dụng lại nó
nếu có lỗi thì chỉ cần nói [n]o và hủy bỏ bản vá này. Nếu bạn áp dụng bản vá này
trước đây và thực sự có ý định hoàn nguyên nó, nhưng lại quên chỉ định -R,
thì bạn có thể nói [ZZ0000ZZ]es tại đây để bản vá hoàn nguyên cho bạn.

Điều này cũng có thể xảy ra nếu người tạo bản vá đảo ngược nguồn và
thư mục đích khi tạo bản vá và trong trường hợp đó sẽ hoàn nguyên
bản vá trên thực tế sẽ áp dụng nó.

Một thông báo tương tự như ZZ0000ZZ hoặc
ZZ0001ZZ có nghĩa là bản vá đó không thể thực hiện được
ý nghĩa của tập tin bạn đã cung cấp cho nó. Hoặc tải xuống của bạn bị hỏng, bạn đã cố gắng
bản vá nguồn cấp dữ liệu một tệp bản vá đã nén mà không giải nén nó trước hoặc bản vá
tập tin bạn đang sử dụng đã bị đọc sai bởi ứng dụng thư khách hoặc chuyển thư
tác nhân trên đường đi ở đâu đó, ví dụ: bằng cách chia một dòng dài thành hai dòng.
Thông thường những cảnh báo này có thể dễ dàng được khắc phục bằng cách nối (nối)
hai dòng đã được tách ra.

Như tôi đã đề cập ở trên, những lỗi này sẽ không bao giờ xảy ra nếu bạn áp dụng
một bản vá từ kernel.org sang phiên bản chính xác của cây nguồn chưa sửa đổi.
Vì vậy, nếu bạn gặp những lỗi này với các bản vá kernel.org thì có lẽ bạn nên
giả sử rằng tệp vá hoặc cây của bạn bị hỏng và tôi khuyên bạn
để bắt đầu lại với bản tải xuống mới của cây nhân đầy đủ và bản vá mà bạn
mong muốn ứng tuyển.


Có lựa chọn thay thế nào cho ZZ0000ZZ không?
========================================


Vâng, có những lựa chọn thay thế.

Bạn có thể sử dụng chương trình ZZ0000ZZ (ZZ0001ZZ để
tạo một bản vá thể hiện sự khác biệt giữa hai bản vá và sau đó
áp dụng kết quả.

Điều này sẽ cho phép bạn chuyển từ thứ gì đó như 5.7.2 sang 5.7.3 trong một lần
bước. Cờ -z cho interdiff thậm chí sẽ cho phép bạn cung cấp các bản vá trong gzip hoặc
dạng nén bzip2 trực tiếp mà không cần sử dụng zcat hoặc bzcat hoặc thủ công
giải nén.

Đây là cách bạn chuyển từ 5.7.2 lên 5.7.3 chỉ bằng một bước::

interdiff -z ../patch-5.7.2.gz ../patch-5.7.3.gz | vá -p1

Mặc dù interdiff có thể giúp bạn tiết kiệm được một hoặc hai bước nhưng bạn thường nên
thực hiện các bước bổ sung vì sự khác biệt có thể xảy ra trong một số trường hợp.

Một lựa chọn khác là ZZ0000ZZ, đây là tập lệnh python để tự động
tải xuống và áp dụng các bản vá (ZZ0001ZZ

Các công cụ thú vị khác là diffstat, nó hiển thị bản tóm tắt các thay đổi được thực hiện bởi một
vá; lsdiff, hiển thị danh sách ngắn các tệp bị ảnh hưởng trong một bản vá
tệp, cùng với (tùy chọn) số dòng bắt đầu của mỗi bản vá;
và grepdiff, hiển thị danh sách các tệp được sửa đổi bởi một bản vá trong đó
bản vá chứa một biểu thức chính quy nhất định.


Tôi có thể tải xuống các bản vá ở đâu?
=================================

Các bản vá có sẵn tại ZZ0000ZZ
Hầu hết các bản vá gần đây đều được liên kết từ trang đầu, nhưng chúng cũng có
những ngôi nhà cụ thể.

Các bản vá 5.x.y (-stable) và 5.x có tại

ZZ0000ZZ

Các bản vá gia tăng 5.x.y có tại

ZZ0000ZZ

Các bản vá -rc không được lưu trữ trên máy chủ web mà được tạo trên
nhu cầu từ các thẻ git như

ZZ0000ZZ

Các bản vá lỗi -rc ổn định có tại

ZZ0000ZZ


Hạt nhân 5.x
===============

Đây là những bản phát hành ổn định cơ bản do Linus phát hành. Được đánh số cao nhất
phát hành là mới nhất.

Nếu tìm thấy hồi quy hoặc các sai sót nghiêm trọng khác, thì bản vá sửa lỗi ổn định
sẽ được phát hành (xem bên dưới) trên nền tảng này. Một khi là cơ sở 5.x mới
kernel được phát hành, một bản vá được cung cấp là bản vá giữa
kernel 5.x trước đó và kernel mới.

Để áp dụng bản vá chuyển từ 5.6 lên 5.7, bạn làm như sau (lưu ý
rằng các bản vá như vậy ZZ0000ZZ áp dụng trên hạt nhân 5.x.y nhưng trên
kernel 5.x cơ sở -- nếu bạn cần chuyển từ 5.x.y lên 5.x+1, bạn cần phải
đầu tiên hoàn nguyên bản vá 5.x.y).

Dưới đây là một số ví dụ::

# moving từ 5,6 đến 5,7

$ cd ~/linux-5.6 # change vào thư mục nguồn kernel
	$ patch -p1 < ../patch-5.7 # apply bản vá 5.7
	$ cd ..
	$ mv linux-5.6 linux-5.7 thư mục nguồn # rename

# moving từ 5.6.1 đến 5.7

$ cd ~/linux-5.6.1 # change vào thư mục nguồn kernel
	$ patch -p1 -R < ../patch-5.6.1 # revert bản vá 5.6.1
					Thư mục # source hiện là 5.6
	$ patch -p1 < ../patch-5.7 # apply bản vá 5.7 mới
	$ cd ..
	$ mv linux-5.6.1 linux-5.7 thư mục nguồn # rename


Hạt nhân 5.x.y
=================

Hạt nhân có phiên bản 3 chữ số là hạt nhân ổn định. Chúng chứa nhỏ (ish)
đã phát hiện các bản sửa lỗi quan trọng cho các vấn đề bảo mật hoặc các lỗi hồi quy đáng kể
trong hạt nhân 5.x nhất định.

Đây là nhánh được đề xuất cho người dùng muốn có phiên bản ổn định gần đây nhất
kernel và không quan tâm đến việc giúp phát triển/thử nghiệm thử nghiệm
các phiên bản.

Nếu không có kernel 5.x.y thì kernel 5.x có số cao nhất là
hạt nhân ổn định hiện tại.

Nhóm ổn định cung cấp các bản vá bình thường cũng như gia tăng. Dưới đây là
làm thế nào để áp dụng các bản vá này.

Các bản vá thông thường
~~~~~~~~~~~~~~

Các bản vá này không tăng dần, nghĩa là ví dụ như 5.7.3
bản vá không áp dụng trên nguồn kernel 5.7.2 mà áp dụng trên cùng
của nguồn kernel cơ sở 5.7.

Vì vậy, để áp dụng bản vá 5.7.3 cho kernel 5.7.2 hiện có của bạn
nguồn trước tiên bạn phải sao lưu bản vá 5.7.2 (vì vậy bạn chỉ còn lại một
nguồn kernel cơ sở 5.7) và sau đó áp dụng bản vá 5.7.3 mới.

Đây là một ví dụ nhỏ::

$ cd ~/linux-5.7.2 # change vào thư mục nguồn kernel
	$ patch -p1 -R < ../patch-5.7.2 # revert bản vá 5.7.2
	$ patch -p1 < ../patch-5.7.3 # apply bản vá 5.7.3 mới
	$ cd ..
	$ mv linux-5.7.2 linux-5.7.3 # rename thư mục nguồn kernel

Các bản vá gia tăng
~~~~~~~~~~~~~~~~~~~

Các bản vá tăng dần thì khác: thay vì được áp dụng lên trên
của kernel cơ sở 5.x, chúng được áp dụng trên kernel ổn định trước đó
(5.x.y-1).

Đây là ví dụ để áp dụng những điều này::

$ cd ~/linux-5.7.2 # change vào thư mục nguồn kernel
	$ patch -p1 < ../patch-5.7.2-3 # apply bản vá 5.7.3 mới
	$ cd ..
	$ mv linux-5.7.2 linux-5.7.3 # rename thư mục nguồn kernel


Hạt nhân -rc
===============

Đây là những hạt nhân ứng cử viên phát hành. Đây là những hạt nhân phát triển được phát hành
bởi Linus bất cứ khi nào anh ta xét thấy git hiện tại (quản lý nguồn của kernel
tool) cây ở trạng thái hợp lý, đủ để thử nghiệm.

Những hạt nhân này không ổn định và đôi khi bạn có thể sẽ bị gãy nếu
bạn có ý định chạy chúng. Tuy nhiên đây là bản ổn định nhất
các nhánh phát triển và cũng là thứ cuối cùng sẽ trở thành nhánh tiếp theo
hạt nhân ổn định, do đó điều quan trọng là nó phải được thử nghiệm bởi càng nhiều người càng tốt
có thể.

Đây là một nhánh tốt để điều hành cho những người muốn giúp thử nghiệm
hạt nhân phát triển nhưng không muốn chạy một số ứng dụng thực sự mang tính thử nghiệm
thứ gì đó (những người như vậy nên xem các phần về hạt nhân -next và -mm bên dưới).

Các bản vá -rc không tăng dần, chúng chỉ áp dụng cho kernel 5.x cơ sở, chỉ
giống như các bản vá 5.x.y được mô tả ở trên. Phiên bản kernel trước -rcN
hậu tố biểu thị phiên bản của kernel mà kernel -rc này cuối cùng sẽ
biến thành.

Vì vậy, 5.8-rc5 có nghĩa đây là ứng cử viên phát hành thứ năm cho 5.8
kernel và bản vá phải được áp dụng trên nguồn kernel 5.7.

Dưới đây là 3 ví dụ về cách áp dụng các bản vá này::

# first một ví dụ về việc chuyển từ 5,7 sang 5,8-rc3

$ cd ~/linux-5.7 # change sang thư mục nguồn 5.7
	$ patch -p1 < ../patch-5.8-rc3 # apply bản vá 5.8-rc3
	$ cd ..
	$ mv linux-5.7 linux-5.8-rc3 # rename thư mục nguồn

# now hãy chuyển từ 5,8-rc3 sang 5,8-rc5

$ cd ~/linux-5.8-rc3 # change sang thư mục 5.8-rc3
	$ patch -p1 -R < ../patch-5.8-rc3 # revert bản vá 5.8-rc3
	$ patch -p1 < ../patch-5.8-rc5 # apply bản vá 5.8-rc5 mới
	$ cd ..
	$ mv linux-5.8-rc3 linux-5.8-rc5 # rename thư mục nguồn

# finally hãy thử chuyển từ 5.7.3 sang 5.8-rc5

$ cd ~/linux-5.7.3 # change vào thư mục nguồn kernel
	$ patch -p1 -R < ../patch-5.7.3 # revert bản vá 5.7.3
	$ patch -p1 < ../patch-5.8-rc5 # apply bản vá 5.8-rc5 mới
	$ cd ..
	$ mv linux-5.7.3 linux-5.8-rc5 # rename thư mục nguồn kernel


Các bản vá -mm và cây linux-next
=======================================

Các bản vá -mm là các bản vá thử nghiệm do Andrew Morton phát hành.

Trước đây, cây -mm cũng được sử dụng để kiểm tra các bản vá hệ thống con, nhưng điều này
chức năng bây giờ được thực hiện thông qua
ZZ0000ZZ (ZZ0001ZZ
cây. Những người bảo trì Hệ thống con đẩy các bản vá của họ trước tiên sang linux-next,
và trong cửa sổ hợp nhất, gửi chúng trực tiếp đến Linus.

Các bản vá -mm đóng vai trò như một loại nền tảng chứng minh cho các tính năng mới và các tính năng khác
các bản vá thử nghiệm không được hợp nhất thông qua cây hệ thống con.
Khi các bản vá như vậy đã chứng tỏ được giá trị của nó trong -mm trong một thời gian, Andrew sẽ đẩy
nó lên Linus để đưa vào dòng chính.

Cây linux-next được cập nhật hàng ngày và bao gồm các bản vá -mm.
Cả hai đều thay đổi liên tục và chứa đựng nhiều đặc tính thử nghiệm, một
rất nhiều bản vá lỗi không phù hợp với dòng chính, v.v., và là bản vá nhiều nhất
thực nghiệm của các nhánh được mô tả trong tài liệu này.

Những bản vá này không phù hợp để sử dụng trên các hệ thống được cho là
ổn định và chúng có nhiều rủi ro hơn khi vận hành so với bất kỳ nhánh nào khác (làm cho
chắc chắn rằng bạn có các bản sao lưu cập nhật -- điều đó áp dụng cho bất kỳ hạt nhân thử nghiệm nào nhưng
thậm chí còn hơn thế đối với các bản vá -mm hoặc sử dụng Kernel từ cây linux-next).

Việc thử nghiệm các bản vá -mm và linux-next được đánh giá rất cao vì toàn bộ
mục đích của những việc đó là loại bỏ hiện tượng hồi quy, sự cố, lỗi hỏng dữ liệu,
sự cố bản dựng (và bất kỳ lỗi nào khác nói chung) trước khi các thay đổi được hợp nhất thành
cây Linus chính tuyến ổn định hơn.

Nhưng những người thử nghiệm -mm và linux-next nên lưu ý rằng sự cố xảy ra
phổ biến hơn bất kỳ cây nào khác.


Điều này kết thúc danh sách giải thích về các loại cây nhân khác nhau.
Tôi hy vọng bây giờ bạn đã hiểu rõ cách áp dụng các bản vá khác nhau và giúp kiểm tra
hạt nhân.

Xin cảm ơn Randy Dunlap, Rolf Eike Beer, Linus Torvalds, Bodo Eggert,
Johannes Stezenbach, Grant Coady, Pavel Machek và những người khác mà tôi có thể có
bị lãng quên vì những đánh giá và đóng góp của họ cho tài liệu này.
