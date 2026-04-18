.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/howto.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _process_howto:

HOWTO phát triển nhân Linux
=================================

Đây là tài liệu cuối cùng về chủ đề này.  Nó chứa
hướng dẫn cách trở thành nhà phát triển nhân Linux và cách học
để làm việc với cộng đồng phát triển nhân Linux.  Nó cố gắng không
chứa mọi thứ liên quan đến khía cạnh kỹ thuật của lập trình hạt nhân,
nhưng sẽ giúp chỉ cho bạn đi đúng hướng cho điều đó.

Nếu bất cứ điều gì trong tài liệu này trở nên lỗi thời, vui lòng gửi các bản vá
tới người duy trì tập tin này, người được liệt kê ở cuối
tài liệu.


Giới thiệu
------------

Vì vậy, bạn muốn học cách trở thành nhà phát triển nhân Linux?  Hoặc bạn
đã được người quản lý của bạn yêu cầu "Hãy viết trình điều khiển Linux cho việc này
thiết bị."  Mục tiêu của tài liệu này là dạy cho bạn mọi thứ bạn cần
biết cách đạt được điều này bằng cách mô tả quá trình bạn cần trải qua,
và gợi ý về cách làm việc với cộng đồng.  Nó cũng sẽ cố gắng
giải thích một số lý do tại sao cộng đồng lại hoạt động như vậy.

Hạt nhân được viết chủ yếu bằng C, với một số phụ thuộc vào kiến trúc
các bộ phận được viết trong lắp ráp. Cần có sự hiểu biết tốt về C
phát triển hạt nhân.  Việc lắp ráp (bất kỳ kiến trúc nào) là không cần thiết trừ khi
bạn dự định thực hiện phát triển cấp thấp cho kiến trúc đó.  Mặc dù họ
không phải là sự thay thế tốt cho nền giáo dục C vững chắc và/hoặc nhiều năm học tập.
kinh nghiệm, những cuốn sách sau đây có thể dùng để tham khảo, nếu có:

- "Ngôn ngữ lập trình C" của Kernighan và Ritchie [Prentice Hall]
 - "Lập trình C thực tế" của Steve Oualline [O'Reilly]
 - "C: Cẩm nang tham khảo" của Harbison và Steele [Prentice Hall]

Hạt nhân được viết bằng GNU C và chuỗi công cụ GNU.  Trong khi nó
tuân thủ tiêu chuẩn ISO C11, nó sử dụng một số tiện ích mở rộng
không có trong tiêu chuẩn.  Hạt nhân là một C độc lập
môi trường, không phụ thuộc vào thư viện C tiêu chuẩn, vì vậy một số
các phần của tiêu chuẩn C không được hỗ trợ.  Dài tùy ý
không được phép phân chia và dấu phẩy động.  Nó đôi khi có thể
khó hiểu các giả định của kernel trên chuỗi công cụ
và các tiện ích mở rộng mà nó sử dụng, và rất tiếc là không có
tài liệu tham khảo chính xác cho họ.  Vui lòng kiểm tra các trang thông tin gcc (ZZ0000ZZ) để biết một số thông tin về chúng.

Hãy nhớ rằng bạn đang cố gắng học cách làm việc với
cộng đồng phát triển hiện có.  Đó là một nhóm người đa dạng, với
tiêu chuẩn cao về mã hóa, phong cách và thủ tục.  Các tiêu chuẩn này có
được tạo ra theo thời gian dựa trên những gì họ nhận thấy là hiệu quả nhất
một đội ngũ lớn và phân tán về mặt địa lý.  Hãy cố gắng học càng nhiều càng tốt
có thể về những tiêu chuẩn này trước thời hạn vì chúng rất tốt
được ghi lại; đừng mong đợi mọi người thích ứng với bạn hoặc cách làm việc của công ty bạn
làm mọi việc.


Các vấn đề pháp lý
------------

Mã nguồn nhân Linux được phát hành theo GPL.  Vui lòng xem tập tin
COPYING trong thư mục chính của cây nguồn. Việc cấp phép nhân Linux
các quy tắc và cách sử dụng mã định danh ZZ0001ZZ trong mã nguồn là
được mô tả trong ZZ0000ZZ.
Nếu bạn có thêm câu hỏi về giấy phép, vui lòng liên hệ với luật sư và thực hiện
không hỏi trong danh sách gửi thư của nhân Linux.  Những người trong danh sách gửi thư là
không phải luật sư và bạn không nên dựa vào tuyên bố của họ về các vấn đề pháp lý.

Để biết các câu hỏi và câu trả lời phổ biến về GPL, vui lòng xem:

ZZ0000ZZ


Tài liệu
-------------

Cây nguồn nhân Linux có rất nhiều tài liệu được
vô giá cho việc học cách tương tác với cộng đồng hạt nhân.  Khi nào
các tính năng mới được thêm vào kernel, chúng tôi khuyến nghị rằng các tính năng mới
các tệp tài liệu cũng được thêm vào để giải thích cách sử dụng tính năng này.
Khi một thay đổi kernel làm cho giao diện mà kernel hiển thị
không gian người dùng để thay đổi, bạn nên gửi thông tin hoặc
một bản vá cho các trang hướng dẫn giải thích sự thay đổi đối với các trang hướng dẫn
người bảo trì tại alx@kernel.org và CC danh sách linux-api@vger.kernel.org.

Đây là danh sách các tập tin trong cây nguồn hạt nhân được
yêu cầu đọc:

ZZ0000ZZ
    Tệp này cung cấp thông tin cơ bản ngắn gọn về nhân Linux và mô tả
    những gì cần làm để cấu hình và xây dựng kernel.  mọi người
    những người mới làm quen với kernel nên bắt đầu từ đây.

ZZ0000ZZ
    Tệp này cung cấp danh sách các mức tối thiểu của phần mềm khác nhau
    các gói cần thiết để xây dựng và chạy kernel
    thành công.

ZZ0000ZZ
    Điều này mô tả phong cách mã hóa nhân Linux và một số
    lý do đằng sau nó. Tất cả mã mới dự kiến sẽ tuân theo
    hướng dẫn trong tài liệu này. Hầu hết những người bảo trì sẽ chỉ chấp nhận
    bản vá nếu những quy tắc này được tuân theo và nhiều người sẽ chỉ
    xem lại mã nếu nó có phong cách phù hợp.

ZZ0000ZZ
    Tệp này mô tả chi tiết rõ ràng cách tạo thành công
    và gửi một bản vá, bao gồm (nhưng không giới hạn):

- Nội dung thư điện tử
       - Định dạng email
       - Gửi cho ai

Việc tuân theo các quy tắc này sẽ không đảm bảo thành công (vì tất cả các bản vá đều được
    được xem xét kỹ lưỡng về nội dung và phong cách), nhưng không tuân theo chúng
    hầu như sẽ luôn ngăn chặn nó.

Các mô tả tuyệt vời khác về cách tạo bản vá đúng cách là:

"Bản vá hoàn hảo"
		ZZ0000ZZ

"Định dạng gửi bản vá nhân Linux"
		ZZ0000ZZ

ZZ0000ZZ
    Tập tin này mô tả lý do căn bản đằng sau quyết định có ý thức để
    không có API ổn định trong kernel, bao gồm những thứ như:

- Lớp chêm hệ thống con (để tương thích?)
      - Tính di động của driver giữa các hệ điều hành.
      - Giảm thiểu sự thay đổi nhanh chóng trong cây nguồn hạt nhân (hoặc
	ngăn chặn sự thay đổi nhanh chóng)

Tài liệu này rất quan trọng để hiểu sự phát triển của Linux
    triết lý và rất quan trọng đối với những người chuyển sang Linux từ
    phát triển trên các Hệ điều hành khác.

ZZ0000ZZ
    Nếu bạn cảm thấy mình đã tìm thấy vấn đề bảo mật trong nhân Linux,
    vui lòng làm theo các bước trong tài liệu này để giúp thông báo kernel
    các nhà phát triển và giúp giải quyết vấn đề.

ZZ0000ZZ
    Tài liệu này mô tả cách các nhà bảo trì nhân Linux hoạt động và
    đặc tính chung đằng sau phương pháp của họ.  Đây là bài đọc quan trọng
    dành cho bất kỳ ai mới phát triển kernel (hoặc bất kỳ ai chỉ đơn giản là tò mò về
    it), vì nó giải quyết được rất nhiều quan niệm sai lầm và nhầm lẫn phổ biến
    về hành vi độc đáo của người bảo trì kernel.

ZZ0000ZZ
    Tệp này mô tả các quy tắc về cách phát hành kernel ổn định
    xảy ra và phải làm gì nếu bạn muốn thay đổi một trong những điều này
    phát hành.

ZZ0000ZZ
    Danh sách tài liệu bên ngoài liên quan đến kernel
    sự phát triển.  Hãy tham khảo danh sách này nếu bạn không tìm thấy những gì bạn
    đang tìm kiếm trong tài liệu trong kernel.

ZZ0000ZZ
    Phần giới thiệu hay mô tả chính xác bản vá là gì và cách thực hiện
    áp dụng nó cho các nhánh phát triển khác nhau của kernel.

Hạt nhân cũng có một số lượng lớn các tài liệu có thể được
được tạo tự động từ chính mã nguồn hoặc từ
Các đánh dấu ReStructuredText (ReST), như thế này. Điều này bao gồm một
mô tả đầy đủ về API trong kernel và các quy tắc về cách xử lý
khóa đúng cách.

Tất cả các tài liệu như vậy có thể được tạo dưới dạng PDF hoặc HTML bằng cách chạy::

tạo tài liệu pdf
	tạo tài liệu html

tương ứng từ thư mục nguồn kernel chính.

Các tài liệu sử dụng đánh dấu ReST sẽ được tạo tại Tài liệu/đầu ra.
Chúng cũng có thể được tạo trên các định dạng LaTeX và ePub với::

làm tài liệu latex
	tạo epubdocs

Trở thành nhà phát triển hạt nhân
---------------------------

Nếu bạn không biết gì về phát triển nhân Linux, bạn nên
hãy xem dự án Linux KernelNewbies:

ZZ0000ZZ

Nó bao gồm một danh sách gửi thư hữu ích nơi bạn có thể hỏi hầu hết mọi loại
câu hỏi phát triển hạt nhân cơ bản (đảm bảo tìm kiếm trong kho lưu trữ
đầu tiên, trước khi hỏi điều gì đó đã được trả lời trong
quá khứ.) Nó cũng có kênh IRC mà bạn có thể sử dụng để đặt câu hỏi trong
theo thời gian thực và rất nhiều tài liệu hữu ích cho
tìm hiểu về phát triển nhân Linux.

Trang web có thông tin cơ bản về tổ chức mã, hệ thống con,
và các dự án hiện tại (cả trong cây và ngoài cây). Nó cũng mô tả
một số thông tin hậu cần cơ bản, như cách biên dịch kernel và
áp dụng một bản vá.

Nếu bạn không biết mình muốn bắt đầu từ đâu nhưng bạn muốn tìm kiếm
một số nhiệm vụ cần bắt đầu thực hiện để tham gia vào cộng đồng phát triển hạt nhân,
đi tới dự án của Linux Kernel Janitor:

ZZ0000ZZ

Đó là một nơi tuyệt vời để bắt đầu.  Nó mô tả một danh sách tương đối đơn giản
các vấn đề cần được dọn dẹp và khắc phục trong nhân Linux
cây nguồn  Làm việc với các nhà phát triển phụ trách dự án này, bạn
sẽ tìm hiểu những kiến thức cơ bản về cách đưa bản vá của bạn vào cây nhân Linux,
và có thể được chỉ ra hướng tiếp theo nên làm gì, nếu
bạn chưa có ý tưởng.

Trước khi thực hiện bất kỳ sửa đổi thực tế nào đối với mã nhân Linux, cần phải
bắt buộc phải hiểu cách mã được đề cập hoạt động.  Vì điều này
mục đích, không có gì tốt hơn là đọc trực tiếp nó (khó nhất
bit được nhận xét tốt), thậm chí có thể với sự trợ giúp của chuyên môn
công cụ.  Một công cụ như vậy được đặc biệt khuyên dùng là Linux
Dự án Tham khảo chéo, có thể trình bày mã nguồn dưới dạng
định dạng trang web tự tham chiếu, được lập chỉ mục. Một bản cập nhật tuyệt vời
kho lưu trữ mã hạt nhân có thể được tìm thấy tại:

ZZ0000ZZ


Quá trình phát triển
-----------------------

Quá trình phát triển nhân Linux hiện nay bao gồm một vài
các "nhánh" hạt nhân chính và rất nhiều hạt nhân dành riêng cho hệ thống con khác nhau
chi nhánh.  Những nhánh khác nhau này là:

- Cây chính của Linus
  - Cây ổn định khác nhau với nhiều số chính
  - Cây dành riêng cho hệ thống con
  - cây thử nghiệm tích hợp linux-next

Cây chính
~~~~~~~~~~~~~

Cây chính được duy trì bởi Linus Torvalds và có thể tìm thấy tại
ZZ0000ZZ hoặc trong repo.  Quá trình phát triển của nó như sau:

- Ngay sau khi hạt nhân mới được phát hành, thời hạn hai tuần sẽ mở ra,
    trong khoảng thời gian này, người bảo trì có thể gửi những khác biệt lớn tới
    Linus, thường là các bản vá đã được đưa vào
    linux-next trong vài tuần.  Cách ưa thích để gửi những thay đổi lớn
    đang sử dụng git (công cụ quản lý nguồn của kernel, thông tin thêm
    có thể được tìm thấy tại ZZ0000ZZ nhưng các bản vá đơn giản cũng chỉ có
    ổn.
  - Sau hai tuần, hạt nhân -rc1 được phát hành và trọng tâm là tạo ra
    hạt nhân mới vững chắc nhất có thể.  Hầu hết các bản vá tại thời điểm này
    nên khắc phục hồi quy.  Những lỗi luôn tồn tại thì không
    hồi quy, vì vậy chỉ đưa ra các loại bản sửa lỗi này nếu chúng quan trọng.
    Xin lưu ý rằng trình điều khiển (hoặc hệ thống tệp) hoàn toàn mới có thể được chấp nhận
    sau -rc1 vì không có nguy cơ gây ra hồi quy với giá trị như vậy
    thay đổi miễn là sự thay đổi đó mang tính khép kín và không ảnh hưởng tới các khu vực
    bên ngoài mã đang được thêm vào.  git có thể được sử dụng để gửi
    các bản vá cho Linus sau khi -rc1 được phát hành, nhưng các bản vá cũng cần được
    gửi đến danh sách gửi thư công cộng để xem xét.
  - Một -rc mới được phát hành bất cứ khi nào Linus cho rằng cây git hiện tại
    ở trạng thái tỉnh táo hợp lý, đủ để thử nghiệm.  Mục tiêu là để
    phát hành kernel -rc mới mỗi tuần.
  - Quá trình tiếp tục cho đến khi kernel được coi là "sẵn sàng",
    quá trình sẽ kéo dài khoảng 6 tuần.

Điều đáng nói là Andrew Morton đã viết trên linux-kernel
danh sách gửi thư về các bản phát hành kernel:

*"Không ai biết khi nào một hạt nhân sẽ được phát hành, bởi vì nó
	được phát hành theo tình trạng lỗi được nhận biết chứ không phải theo một
	dòng thời gian được định trước."*

Cây ổn định khác nhau với nhiều số chính
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hạt nhân có phiên bản 3 phần là hạt nhân ổn định. Chúng chứa
các bản sửa lỗi tương đối nhỏ và quan trọng đối với các vấn đề bảo mật hoặc các vấn đề quan trọng
hồi quy được phát hiện trong một bản phát hành chính thống nhất định. Mỗi bản phát hành
trong một loạt ổn định lớn sẽ tăng phần thứ ba của phiên bản
số, giữ nguyên hai phần đầu tiên.

Đây là nhánh được đề xuất cho người dùng muốn có phiên bản ổn định gần đây nhất
kernel và không quan tâm đến việc giúp phát triển/thử nghiệm thử nghiệm
các phiên bản.

Cây ổn định được duy trì bởi nhóm "ổn định" <stable@vger.kernel.org> và
được phát hành khi nhu cầu ra lệnh.  Thời gian phát hành bình thường là khoảng
hai tuần, nhưng có thể lâu hơn nếu không có vấn đề gì cấp bách.  A
thay vào đó, vấn đề liên quan đến bảo mật có thể khiến việc phát hành gần như xảy ra
ngay lập tức.

Tệp ZZ0000ZZ
trong tài liệu cây nhân những loại thay đổi nào được chấp nhận đối với
cây ổn định và cách thức hoạt động của quá trình phát hành.

Cây dành riêng cho hệ thống con
~~~~~~~~~~~~~~~~~~~~~~~~

Những người duy trì các hệ thống con kernel khác nhau --- và cũng có nhiều
các nhà phát triển hệ thống con kernel --- phơi bày trạng thái hiện tại của họ
phát triển trong kho nguồn.  Bằng cách đó, những người khác có thể nhìn thấy những gì
xảy ra trong các khu vực khác nhau của kernel.  Ở những khu vực có
phát triển nhanh chóng, nhà phát triển có thể được yêu cầu căn cứ vào nội dung đệ trình của mình
trên cây nhân hệ thống con như vậy để tránh xung đột giữa
tránh được việc nộp đơn và các công việc đang diễn ra khác.

Hầu hết các kho này là cây git, nhưng cũng có những SCM khác
đang được sử dụng hoặc hàng đợi vá lỗi đang được xuất bản dưới dạng chuỗi chăn.  Địa chỉ của
các kho lưu trữ hệ thống con này được liệt kê trong tệp MAINTAINERS.  Nhiều
trong số chúng có thể được duyệt tại ZZ0000ZZ

Trước khi một bản vá được đề xuất được đưa vào cây hệ thống con như vậy, nó phải được
có thể được xem xét, điều này chủ yếu xảy ra trên danh sách gửi thư (xem
phần tương ứng bên dưới).  Đối với một số hệ thống con kernel, đánh giá này
quá trình được theo dõi bằng công cụ chắp vá.  Patchwork cung cấp một trang web
giao diện hiển thị các bài đăng về bản vá, bất kỳ nhận xét nào về bản vá hoặc
sửa đổi nó và người bảo trì có thể đánh dấu các bản vá là đang được xem xét,
được chấp nhận, hoặc bị từ chối.  Hầu hết các trang web chắp vá này được liệt kê tại
ZZ0000ZZ

cây thử nghiệm tích hợp linux-next
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trước khi các bản cập nhật từ cây hệ thống con được hợp nhất vào cây dòng chính,
chúng cần được kiểm thử tích hợp.  Với mục đích này, một điều đặc biệt
kho lưu trữ thử nghiệm tồn tại trong đó hầu như tất cả các cây hệ thống con đều được
được kéo gần như hàng ngày:

ZZ0000ZZ

Bằng cách này, linux-next đưa ra một cái nhìn tóm tắt về những gì sẽ xảy ra.
dự kiến sẽ đi vào hạt nhân dòng chính ở giai đoạn hợp nhất tiếp theo.
Những người thử nghiệm thích mạo hiểm rất được hoan nghênh khi thử nghiệm thời gian chạy linux-next.


Báo cáo lỗi
-------------

Tệp 'Documentation/admin-guide/reporting-issues.rst' trong kernel chính
thư mục nguồn mô tả cách báo cáo lỗi kernel có thể xảy ra và thông tin chi tiết
nhà phát triển hạt nhân cần loại thông tin nào để giúp theo dõi
xuống vấn đề.


Quản lý báo cáo lỗi
--------------------

Một trong những cách tốt nhất để thực hành kỹ năng hack của bạn là sửa
lỗi do người khác báo cáo. Bạn không chỉ giúp tạo ra hạt nhân
ổn định hơn, nhưng bạn cũng sẽ học cách khắc phục các vấn đề trong thế giới thực và bạn sẽ
cải thiện kỹ năng của bạn và các nhà phát triển khác sẽ biết đến sự hiện diện của bạn.
Sửa lỗi là một trong những cách tốt nhất để nhận được khen thưởng từ các nhà phát triển khác,
bởi vì không có nhiều người thích lãng phí thời gian sửa lỗi của người khác.

Để xử lý các báo cáo lỗi đã được báo cáo, hãy tìm hệ thống con mà bạn quan tâm.
Kiểm tra tệp MAINTAINERS nơi các lỗi của hệ thống con đó được báo cáo; thường xuyên
nó sẽ là một danh sách gửi thư, hiếm khi là một công cụ theo dõi lỗi. Tìm kiếm các tài liệu lưu trữ nói
nơi dành cho các báo cáo gần đây và trợ giúp khi bạn thấy phù hợp. Bạn cũng có thể muốn kiểm tra
ZZ0000ZZ để báo cáo lỗi; chỉ một số ít hệ thống con kernel
sử dụng nó một cách tích cực để báo cáo hoặc theo dõi, tuy nhiên vẫn có lỗi cho toàn bộ
kernel được nộp ở đó.


Danh sách gửi thư
-------------

Như một số tài liệu trên mô tả, phần lớn nhân lõi
các nhà phát triển tham gia vào danh sách Gửi thư hạt nhân Linux.  Chi tiết về cách
để đăng ký và hủy đăng ký khỏi danh sách có thể được tìm thấy tại:

ZZ0000ZZ

Có kho lưu trữ danh sách gửi thư trên web ở nhiều dạng khác nhau
những nơi.  Sử dụng công cụ tìm kiếm để tìm các tài liệu lưu trữ này.  Ví dụ:

ZZ0000ZZ

Chúng tôi khuyên bạn nên tìm kiếm các tài liệu lưu trữ về chủ đề này
bạn muốn đưa ra trước khi đăng nó vào danh sách. Rất nhiều thứ
đã thảo luận chi tiết chỉ được ghi vào danh sách gửi thư
kho lưu trữ.

Hầu hết các hệ thống con kernel riêng lẻ cũng có hệ thống con riêng
danh sách gửi thư nơi họ thực hiện nỗ lực phát triển của mình.  Xem
Tệp MAINTAINERS để biết danh sách các danh sách này dành cho những mục đích khác nhau
các nhóm.

Nhiều danh sách được lưu trữ trên kernel.org. Thông tin về chúng có thể
được tìm thấy tại:

ZZ0000ZZ

Hãy nhớ tuân theo những thói quen ứng xử tốt khi sử dụng danh sách.
Mặc dù hơi sến nhưng URL sau đây có một số hướng dẫn đơn giản để
tương tác với danh sách (hoặc bất kỳ danh sách nào):

ZZ0000ZZ

Nếu nhiều người trả lời thư của bạn, CC: danh sách người nhận có thể
trở nên khá lớn. Đừng xóa bất kỳ ai khỏi CC: danh sách không tốt
lý do hoặc không chỉ trả lời địa chỉ danh sách. Làm quen với việc nhận
gửi thư hai lần, một từ người gửi và một từ danh sách, và đừng thử
điều chỉnh điều đó bằng cách thêm các tiêu đề thư cầu kỳ, mọi người sẽ không thích nó.

Hãy nhớ giữ nguyên bối cảnh và ghi công của các câu trả lời của bạn,
giữ dòng "John Kernelhacker đã viết ...:" ở đầu câu trả lời của bạn và
thêm các tuyên bố của bạn vào giữa các phần được trích dẫn riêng lẻ thay vì
viết ở đầu thư.

Nếu bạn thêm các bản vá vào thư của mình, hãy đảm bảo chúng là văn bản dễ đọc
như đã nêu trong ZZ0000ZZ.
Các nhà phát triển hạt nhân không muốn giải quyết
tệp đính kèm hoặc bản vá nén; họ có thể muốn bình luận về
các dòng riêng lẻ của bản vá của bạn, chỉ hoạt động theo cách đó. Hãy chắc chắn rằng bạn
sử dụng chương trình thư không đọc sai dấu cách và ký tự tab. A
Thử nghiệm đầu tiên tốt là gửi thư cho chính bạn và cố gắng áp dụng
bản vá riêng của chính bạn. Nếu cách đó không hiệu quả, hãy sửa chương trình thư của bạn
hoặc thay đổi nó cho đến khi nó hoạt động.

Trên hết, hãy nhớ thể hiện sự tôn trọng với những người đăng ký khác.


Làm việc với cộng đồng
--------------------------

Mục tiêu của cộng đồng kernel là cung cấp kernel tốt nhất có thể
có đấy.  Khi bạn gửi một bản vá để được chấp nhận, nó sẽ được xem xét
dựa trên giá trị kỹ thuật của nó và những thứ đó thôi.  Vậy bạn nên là gì
mong đợi?

- chỉ trích
  - bình luận
  - yêu cầu thay đổi
  - yêu cầu biện minh
  - im lặng

Hãy nhớ rằng đây là một phần trong quá trình đưa bản vá của bạn vào kernel.  bạn có
để có thể nhận những lời chỉ trích và nhận xét về các bản vá của bạn, đánh giá
chúng ở cấp độ kỹ thuật và làm lại các bản vá của bạn hoặc cung cấp
lý rõ ràng và ngắn gọn về lý do tại sao không nên thực hiện những thay đổi đó.
Nếu không có phản hồi cho bài đăng của bạn, hãy đợi vài ngày và thử
một lần nữa, đôi khi mọi thứ bị mất đi trong khối lượng lớn.

Bạn không nên làm gì?

- mong đợi bản vá của bạn được chấp nhận mà không có câu hỏi nào
  - trở nên phòng thủ
  - bỏ qua ý kiến
  - gửi lại bản vá mà không thực hiện bất kỳ thay đổi nào được yêu cầu

Trong một cộng đồng đang tìm kiếm giải pháp kỹ thuật tốt nhất có thể,
sẽ luôn có những ý kiến ​​khác nhau về lợi ích của một bản vá.
Bạn phải hợp tác và sẵn sàng điều chỉnh ý tưởng của mình để phù hợp với
hạt nhân.  Hoặc ít nhất hãy sẵn sàng chứng minh ý tưởng của bạn có giá trị.
Hãy nhớ rằng, sai lầm có thể chấp nhận được miễn là bạn sẵn sàng làm việc
hướng tới một giải pháp đúng đắn.

Điều bình thường là các câu trả lời cho bản vá đầu tiên của bạn có thể chỉ đơn giản là một danh sách
trong số hàng tá điều bạn nên sửa.  Điều này ZZ0000ZZ có nghĩa là
bản vá sẽ không được chấp nhận và ZZ0001ZZ có ý chống lại bạn
cá nhân.  Chỉ cần sửa tất cả các vấn đề nảy sinh đối với bản vá của bạn và
gửi lại nó.


Sự khác biệt giữa cộng đồng hạt nhân và cấu trúc doanh nghiệp
-----------------------------------------------------------------

Cộng đồng kernel hoạt động khác với hầu hết các công ty truyền thống
các môi trường phát triển.  Dưới đây là danh sách những điều bạn có thể thử
làm để tránh các vấn đề:

Những điều tốt đẹp để nói về những thay đổi được đề xuất của bạn:

- "Điều này giải quyết được nhiều vấn đề."
    - "Điều này xóa 2000 dòng mã."
    - "Đây là bản vá giải thích những gì tôi đang cố gắng mô tả."
    - "Tôi đã thử nghiệm nó trên 5 kiến trúc khác nhau..."
    - "Đây là một loạt các miếng vá nhỏ..."
    - "Điều này làm tăng hiệu suất trên các máy thông thường..."

Những điều xấu bạn nên tránh nói:

- "Chúng tôi đã làm theo cách này trong AIX/ptx/Solaris, vì vậy nó phải là
      tốt..."
    - "Tôi đã làm nghề này được 20 năm rồi, nên..."
    - "Điều này là cần thiết để công ty của tôi kiếm tiền"
    - "Đây là dòng sản phẩm Enterprise của chúng tôi."
    - "Đây là tài liệu thiết kế 1000 trang mô tả ý tưởng của tôi"
    - "Tôi đã làm việc này được 6 tháng rồi..."
    - "Đây là bản vá 5000 dòng..."
    - "Tôi đã viết lại toàn bộ mớ hỗn độn hiện tại, và đây là..."
    - "Tôi có thời hạn, và bản vá này cần được áp dụng ngay bây giờ."

Một cách khác là cộng đồng kernel khác với hầu hết các cộng đồng kernel truyền thống
môi trường làm việc công nghệ phần mềm là bản chất vô hình của
tương tác.  Một lợi ích của việc sử dụng email và irc làm hình thức chính của
giao tiếp là thiếu sự phân biệt đối xử dựa trên giới tính hoặc chủng tộc.
Môi trường làm việc nhân Linux chấp nhận phụ nữ và người thiểu số
bởi vì tất cả những gì bạn có là một địa chỉ email.  Khía cạnh quốc tế cũng
giúp tạo sân chơi bình đẳng vì bạn không thể đoán giới tính dựa trên
tên của một người Một người đàn ông có thể tên là Andrea và một người phụ nữ có thể tên là Pat.
Hầu hết phụ nữ từng làm việc trong nhân Linux đều bày tỏ quan điểm
ý kiến đã có những trải nghiệm tích cực.

Rào cản ngôn ngữ có thể gây ra vấn đề cho một số người không
thoải mái với tiếng Anh.  Có thể cần phải nắm bắt tốt ngôn ngữ trong
để đưa các ý tưởng vào danh sách gửi thư một cách phù hợp, vì vậy nó là
khuyên bạn nên kiểm tra email của mình để đảm bảo chúng có ý nghĩa trong
tiếng Anh trước khi gửi chúng.


Chia nhỏ những thay đổi của bạn
---------------------

Cộng đồng nhân Linux không vui vẻ chấp nhận những đoạn mã lớn
rơi vào nó tất cả cùng một lúc.  Những thay đổi cần được đưa ra một cách đúng đắn,
được thảo luận và chia thành các phần nhỏ, riêng lẻ.  Điều này gần như
hoàn toàn trái ngược với những gì các công ty thường làm.  Đề xuất của bạn
cũng nên được giới thiệu từ rất sớm trong quá trình phát triển, để
bạn có thể nhận được phản hồi về những gì bạn đang làm.  Nó cũng cho phép
cộng đồng cảm thấy rằng bạn đang làm việc với họ chứ không chỉ đơn giản sử dụng họ
như một bãi rác cho tính năng của bạn.  Tuy nhiên, đừng gửi 50 email tại
một lần vào danh sách gửi thư, chuỗi bản vá của bạn phải nhỏ hơn
hầu như lúc nào cũng vậy.

Những lý do khiến mọi thứ tan vỡ như sau:

1) Các bản vá nhỏ làm tăng khả năng các bản vá của bạn sẽ bị
   được áp dụng vì chúng không mất nhiều thời gian và công sức để xác minh
   sự đúng đắn.  Một bản vá 5 dòng có thể được áp dụng bởi người bảo trì với
   chỉ một cái liếc nhìn thứ hai. Tuy nhiên, một bản vá 500 dòng có thể mất hàng giờ để
   xem xét tính đúng đắn (thời gian cần thiết là theo cấp số nhân
   tỷ lệ thuận với kích thước của miếng vá hoặc thứ gì đó).

Các bản vá nhỏ cũng giúp dễ dàng gỡ lỗi khi có sự cố xảy ra
   sai.  Việc sao lưu từng bản vá sẽ dễ dàng hơn nhiều so với thực hiện
   để mổ xẻ một miếng vá rất lớn sau khi nó được dán (và bị hỏng
   một cái gì đó).

2) Điều quan trọng không chỉ là gửi các bản vá nhỏ mà còn phải viết lại
   và đơn giản hóa (hoặc đơn giản là sắp xếp lại) các bản vá trước khi gửi chúng.

Đây là một ví dụ tương tự từ nhà phát triển hạt nhân Al Viro:

*"Hãy nghĩ về một giáo viên chấm bài tập về nhà của một học sinh toán.
	giáo viên không muốn nhìn thấy những thử thách và sai sót của học sinh
	trước khi họ nghĩ ra giải pháp. Họ muốn nhìn thấy
	câu trả lời sạch sẽ nhất, thanh lịch nhất.  Một học sinh giỏi biết điều này, và
	sẽ không bao giờ nộp tác phẩm trung cấp của mình trước kỳ thi cuối cùng
	giải pháp.*

*Điều tương tự cũng đúng với việc phát triển kernel. Những người bảo trì và
	người đánh giá không muốn thấy quá trình suy nghĩ đằng sau
	giải pháp cho vấn đề người ta đang giải quyết. Họ muốn nhìn thấy một
	giải pháp đơn giản và thanh lịch."*

Có thể khó giữ được sự cân bằng giữa việc thể hiện một phong cách trang nhã
giải pháp và làm việc cùng với cộng đồng và thảo luận về
công việc còn dang dở. Vì vậy, tốt nhất là bạn nên sớm bắt đầu quá trình này để
nhận phản hồi để cải thiện công việc của bạn nhưng cũng giữ những thay đổi nhỏ của bạn
những phần mà họ có thể đã được chấp nhận, ngay cả khi toàn bộ nhiệm vụ của bạn được thực hiện
chưa sẵn sàng để đưa vào bây giờ.

Cũng nhận ra rằng việc gửi các bản vá để đưa vào là không được chấp nhận
những thứ còn dang dở và sẽ được "sửa chữa sau".


Biện minh cho sự thay đổi của bạn
-------------------

Cùng với việc chia nhỏ các bản vá của bạn, điều rất quan trọng là bạn phải để
cộng đồng Linux biết tại sao họ nên thêm thay đổi này.  Tính năng mới
phải được chứng minh là cần thiết và hữu ích.


Ghi lại sự thay đổi của bạn
--------------------

Khi gửi bản vá của bạn, hãy đặc biệt chú ý đến những gì bạn nói trong
văn bản trong email của bạn.  Thông tin này sẽ trở thành ChangeLog
thông tin về bản vá và sẽ được lưu giữ cho mọi người xem
mọi lúc.  Nó phải mô tả đầy đủ bản vá, bao gồm:

- tại sao sự thay đổi là cần thiết
  - phương pháp thiết kế tổng thể trong bản vá
  - chi tiết thực hiện
  - kết quả thử nghiệm

Để biết thêm chi tiết về việc tất cả những thứ này sẽ trông như thế nào, vui lòng xem
Phần ChangeLog của tài liệu:

"Bản vá hoàn hảo"
      ZZ0000ZZ


Tất cả những điều này đôi khi rất khó thực hiện. Có thể mất nhiều năm để
hoàn thiện những thực hành này (nếu có). Đó là một quá trình liên tục của
cải tiến đòi hỏi rất nhiều kiên nhẫn và quyết tâm. Nhưng
đừng bỏ cuộc, điều đó là có thể. Nhiều người đã làm điều đó trước đây và mỗi người đều phải làm
bắt đầu chính xác nơi bạn đang ở hiện tại.




----------

Cảm ơn Paolo Ciarrocchi người đã cho phép "Quy trình phát triển"
(Phần ZZ0000ZZ
dựa trên văn bản ông đã viết, và gửi tới Randy Dunlap và Gerrit
Huizenga cho một số danh sách những điều bạn nên và không nên nói.
Cũng xin cảm ơn Pat Mochel, Hanna Linder, Randy Dunlap, Kay Sievers,
Vojtech Pavlik, Jan Kara, Josh Boyer, Kees Cook, Andrew Morton, Andi
Kleen, Vadim Lobanov, Jesper Juhl, Adrian Bunk, Keri Harris, Frans Pop,
David A. Wheeler, Junio Hamano, Michael Kerrisk và Alex Shepard cho
đánh giá, nhận xét và đóng góp của họ.  Nếu không có sự giúp đỡ của họ, điều này
tài liệu sẽ không thể thực hiện được.



Người bảo trì: Greg Kroah-Hartman <greg@kroah.com>
