.. SPDX-License-Identifier: (GPL-2.0+ OR CC-BY-4.0)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/handling-regressions.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. See the bottom of this file for additional redistribution information.

Xử lý hồi quy
++++++++++++++++++++

ZZ0000ZZ -- tài liệu này mô tả "quy tắc đầu tiên của
Phát triển nhân Linux" trong thực tế có nghĩa là dành cho các nhà phát triển. Nó bổ sung
Documentation/admin-guide/reporting-regressions.rst, bao gồm chủ đề từ một
quan điểm của người dùng; nếu bạn chưa bao giờ đọc văn bản đó, hãy đi và ít nhất hãy lướt qua nó
trước khi tiếp tục ở đây.

Các bit quan trọng (còn gọi là "TL;DR")
====================================

#. Đảm bảo thuê bao của ZZ0000ZZ
   (regressions@lists.linux.dev) nhanh chóng nhận biết bất kỳ hồi quy mới nào
   báo cáo:

* Khi nhận được báo cáo gửi qua thư không có CC trong danh sách, hãy mang nó vào
      lặp lại bằng cách gửi ngay ít nhất một câu "Trả lời tất cả" ngắn gọn kèm theo danh sách
      Đã CC.

* Chuyển tiếp hoặc trả lại bất kỳ báo cáo nào được gửi trong trình theo dõi lỗi vào danh sách.

#. Làm cho bot theo dõi hồi quy nhân Linux "regzbot" theo dõi vấn đề (điều này
   là tùy chọn, nhưng được khuyến nghị):

* Đối với các báo cáo được gửi qua thư, hãy kiểm tra xem người báo cáo có đưa vào dòng như ZZ0000ZZ hay không. Nếu không, hãy gửi phản hồi (với các hồi quy
      list trong CC) chứa một đoạn như sau, thông báo cho regzbot
      khi sự cố bắt đầu xảy ra::

#regzbot ^giới thiệu: 1f2e3d4c5b6a

* Khi chuyển tiếp báo cáo từ trình theo dõi lỗi tới danh sách hồi quy (xem
      ở trên), bao gồm một đoạn như sau::

#regzbot giới thiệu: v5.13..v5.14-rc1
       #regzbot từ: Some N. Ice Human <some.human@example.com>
       Màn hình #regzbot: ZZ0000ZZ

#. Khi gửi bản sửa lỗi để hồi quy, hãy thêm thẻ "Đóng:" vào bản vá
   mô tả trỏ đến tất cả những nơi mà vấn đề đã được báo cáo, như
   được ủy quyền bởi Documentation/process/submit-patches.rst và
   ZZ0000ZZ. Nếu bạn là
   chỉ khắc phục một phần sự cố gây ra hiện tượng hồi quy, bạn có thể sử dụng
   thay vào đó là thẻ "Liên kết:". regzbot hiện không phân biệt giữa
   hai.

#. Cố gắng khắc phục tình trạng hồi quy nhanh chóng sau khi xác định được thủ phạm; sửa chữa
   đối với hầu hết các hồi quy nên được hợp nhất trong vòng hai tuần, nhưng một số cần phải được
   giải quyết trong vòng hai hoặc ba ngày.


Tất cả các chi tiết về hồi quy nhân Linux đều phù hợp với các nhà phát triển
===================================================================


Những điều cơ bản quan trọng chi tiết hơn
-----------------------------------


Phải làm gì khi nhận được báo cáo hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đảm bảo trình theo dõi hồi quy của nhân Linux và những người đăng ký khác của
ZZ0000ZZ
(regressions@lists.linux.dev) biết về mọi hồi quy mới được báo cáo:

* Khi nhận được báo cáo qua đường bưu điện mà không có CC trong danh sách, hãy mang ngay đến
   nó vào vòng lặp bằng cách gửi ít nhất một "Trả lời tất cả" ngắn gọn với danh sách được CC;
   cố gắng đảm bảo nó được CC lại trong trường hợp bạn trả lời một câu trả lời bị bỏ qua
   danh sách.

* Nếu một báo cáo được gửi trong trình theo dõi lỗi chạm vào Hộp thư đến của bạn, hãy chuyển tiếp hoặc trả lại nó
   vào danh sách. Hãy cân nhắc việc kiểm tra trước danh sách lưu trữ, nếu người báo cáo
   đã chuyển tiếp báo cáo theo hướng dẫn của
   Tài liệu/admin-guide/reporting-issues.rst.

Khi thực hiện một trong hai điều đó, hãy cân nhắc việc tạo bot theo dõi hồi quy nhân Linux
"regzbot" ngay lập tức bắt đầu theo dõi vấn đề:

* Đối với các báo cáo được gửi qua thư, hãy kiểm tra xem người báo cáo có đưa vào "lệnh regzbot" như
   ZZ0000ZZ. Nếu không, hãy gửi trả lời (với
   danh sách hồi quy trong CC) với một đoạn như sau:::

#regzbot ^giới thiệu: v5.13..v5.14-rc1

Điều này cho regzbot biết phạm vi phiên bản mà sự cố bắt đầu xảy ra;
   bạn cũng có thể chỉ định một phạm vi bằng cách sử dụng id xác nhận hoặc nêu một id xác nhận duy nhất
   trong trường hợp phóng viên xẻ thịt thủ phạm.

Lưu ý dấu mũ (^) trước "được giới thiệu": nó báo cho regzbot xử lý
   thư gốc (thư bạn trả lời) làm báo cáo ban đầu cho hồi quy
   bạn muốn xem được theo dõi; điều đó quan trọng vì sau này regzbot sẽ chú ý đến
   đối với các bản vá có thẻ "Đóng:" trỏ đến báo cáo trong kho lưu trữ trên
   truyền thuyết.kernel.org.

* Khi chuyển tiếp hồi quy được báo cáo tới trình theo dõi lỗi, hãy bao gồm một đoạn
   với các lệnh regzbot này ::

#regzbot giới thiệu: 1f2e3d4c5b6a
       #regzbot từ: Some N. Ice Human <some.human@example.com>
       Màn hình #regzbot: ZZ0000ZZ

Regzbot sau đó sẽ tự động liên kết các bản vá với báo cáo rằng
   chứa thẻ "Đóng:" trỏ đến thư của bạn hoặc vé được đề cập.

Điều quan trọng khi sửa lỗi hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn không cần phải làm bất cứ điều gì đặc biệt khi gửi bản sửa lỗi cho hồi quy, chỉ cần
hãy nhớ làm những gì Tài liệu/quy trình/gửi-patches.rst,
ZZ0000ZZ, và
Documentation/process/stable-kernel-rules.rst đã giải thích chi tiết hơn:

* Chỉ vào tất cả các vị trí đã báo cáo sự cố bằng cách sử dụng thẻ "Đóng:"::

Đóng: ZZ0000ZZ
       Đóng: ZZ0001ZZ

Nếu bạn chỉ khắc phục một phần vấn đề, bạn có thể sử dụng "Link:" thay vì
   được mô tả trong tài liệu đầu tiên được đề cập ở trên. regzbot hiện đang xử lý
   cả hai điều này đều tương đương nhau và coi các báo cáo được liên kết là đã được giải quyết.

* Thêm thẻ "Sửa lỗi:" để chỉ định cam kết gây ra hồi quy.

* Nếu thủ phạm đã được hợp nhất trong chu kỳ phát triển trước đó, hãy đánh dấu rõ ràng
   bản sửa lỗi backporting bằng thẻ ZZ0000ZZ.

Tất cả điều này được mong đợi từ bạn và quan trọng khi nói đến hồi quy, vì
những thẻ này có giá trị lớn cho tất cả mọi người (bao gồm cả bạn) có thể đang tìm kiếm
vào vấn đề này nhiều tuần, nhiều tháng hoặc nhiều năm sau đó. Những thẻ này cũng rất quan trọng đối với
các công cụ và tập lệnh được các nhà phát triển hạt nhân hoặc bản phân phối Linux khác sử dụng; một trong
những công cụ này là regzbot, dựa chủ yếu vào thẻ "Đóng:" để liên kết
báo cáo hồi quy với những thay đổi giải quyết chúng.

Kỳ vọng và cách thực hành tốt nhất để khắc phục hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Với tư cách là nhà phát triển nhân Linux, bạn phải cố gắng hết sức để ngăn chặn
các tình huống mà sự hồi quy do một thay đổi gần đây của bạn gây ra khiến người dùng
chỉ những tùy chọn này:

* Chạy kernel có hồi quy ảnh hưởng đến việc sử dụng.

* Chuyển sang loạt hạt nhân cũ hơn hoặc mới hơn.

* Tiếp tục chạy kernel đã lỗi thời và do đó có khả năng không an toàn để biết thêm
   hơn ba tuần sau khi thủ phạm của hồi quy được xác định. Lý tưởng nhất là nó
   nên ít hơn hai. Và có lẽ chỉ mất vài ngày thôi, nếu vấn đề là
   nghiêm trọng hoặc ảnh hưởng đến nhiều người dùng -- nói chung hoặc phổ biến
   môi trường.

Làm thế nào để nhận ra điều đó trong thực tế phụ thuộc vào nhiều yếu tố khác nhau. Sử dụng như sau
quy tắc ngón tay cái như một hướng dẫn.

Nói chung:

* Ưu tiên công việc hồi quy hơn tất cả các công việc khác của nhân Linux, trừ khi
   phần sau liên quan đến một vấn đề nghiêm trọng (ví dụ: lỗ hổng bảo mật nghiêm trọng, mất dữ liệu,
   phần cứng bị brick, ...).

* Xúc tiến việc sửa các hồi quy tuyến chính mà gần đây đã biến nó thành phù hợp
   bản phát hành chính, ổn định hoặc dài hạn (trực tiếp hoặc qua cổng sau).

* Đừng coi sự hồi quy của chu kỳ hiện tại là điều có thể chờ đợi
   cho đến hết chu kỳ, vì vấn đề này có thể làm nản lòng hoặc ngăn cản người dùng và
   Hệ thống CI từ thử nghiệm tuyến chính hiện nay hoặc nói chung.

* Làm việc với sự cẩn thận cần thiết để tránh thiệt hại thêm hoặc lớn hơn, ngay cả khi
   việc giải quyết vấn đề khi đó có thể mất nhiều thời gian hơn được nêu dưới đây.

Về thời gian khi xác định được thủ phạm của sự hồi quy:

* Nhằm mục đích đưa ra bản sửa lỗi chính thức trong vòng hai hoặc ba ngày, nếu sự cố nghiêm trọng hoặc
   làm phiền nhiều người dùng -- nói chung hoặc trong các điều kiện phổ biến như
   môi trường phần cứng cụ thể, phân phối hoặc chuỗi ổn định/dài hạn.

* Đặt mục tiêu đưa ra cách khắc phục chính thức vào Chủ nhật tiếp theo, nếu thủ phạm đã thực hiện việc đó
   thành bản phát hành chính thống, ổn định hoặc dài hạn gần đây (trực tiếp hoặc thông qua
   cổng sau); nếu thủ phạm được biết đến sớm trong một tuần và dễ dàng phát hiện
   giải quyết, hãy cố gắng thực hiện việc khắc phục trong cùng một tuần.

* Đối với các đợt hồi quy khác, hãy nhắm đến việc sửa lỗi chính trước ngày Chủ nhật cuối cùng
   trong vòng ba tuần tới. Một hoặc hai ngày Chủ nhật muộn hơn có thể chấp nhận được, nếu
   hồi quy là điều mọi người có thể dễ dàng chấp nhận trong một thời gian -- giống như một
   hồi quy hiệu suất nhẹ.

* Chúng tôi thực sự không khuyến khích trì hoãn việc sửa lỗi hồi quy chính cho đến lần sửa lỗi tiếp theo
   hợp nhất cửa sổ, ngoại trừ khi việc khắc phục cực kỳ rủi ro hoặc khi
   thủ phạm đã được nêu ra cách đây hơn một năm.

Về thủ tục:

* Luôn cân nhắc việc hoàn nguyên thủ phạm, vì đây thường là cách nhanh nhất và ít tốn kém nhất
   cách nguy hiểm để khắc phục sự hồi quy. Đừng lo lắng về việc cố định chính
   biến thể sau: điều đó sẽ dễ hiểu vì hầu hết mã đã được thực hiện
   qua xem xét một lần rồi.

* Cố gắng giải quyết mọi hồi quy được đưa ra trong dòng chính trong quá khứ
   mười hai tháng trước khi chu kỳ phát triển hiện tại kết thúc: Linus muốn
   các hồi quy sẽ được xử lý giống như các hồi quy trong chu kỳ hiện tại, trừ khi sửa chữa
   chịu những rủi ro bất thường.

* Cân nhắc sử dụng CC Linus trong các cuộc thảo luận hoặc đánh giá bản vá, nếu có vẻ như có sự hồi quy
   rối rắm. Hãy làm điều tương tự trong những trường hợp bấp bênh hoặc khẩn cấp -- đặc biệt nếu
   người bảo trì hệ thống con có thể không có sẵn. Còn CC là đội ổn định, khi bạn
   biết sự hồi quy như vậy đã biến nó thành một bản phát hành chính, ổn định hoặc dài hạn.

* Đối với các trường hợp hồi quy khẩn cấp, hãy cân nhắc việc yêu cầu Linus thực hiện ngay cách khắc phục
   từ danh sách gửi thư: anh ấy hoàn toàn đồng ý với điều đó vì không gây tranh cãi
   sửa lỗi. Lý tưởng nhất là những yêu cầu như vậy nên được thực hiện phù hợp với
   người bảo trì hệ thống con hoặc đến trực tiếp từ họ.

* Trong trường hợp bạn không chắc liệu cách khắc phục có đáng để mạo hiểm áp dụng chỉ vài ngày trước đó hay không
   một bản phát hành chính thức mới, hãy gửi cho Linus một thư với các danh sách thông thường và những người trong
   CC; trong đó, tóm tắt tình huống đồng thời yêu cầu anh ta cân nhắc việc nhặt
   cách khắc phục ngay từ danh sách. Sau đó anh ta có thể tự mình thực hiện cuộc gọi và khi nào
   thậm chí cần phải hoãn việc phát hành. Những yêu cầu như vậy một lần nữa lý tưởng nhất là nên xảy ra
   theo những người bảo trì hệ thống con hoặc đến trực tiếp từ họ.

Về hạt nhân ổn định và lâu dài:

* Bạn có quyền để lại phần hồi quy cho nhóm ổn định, nếu họ không có ích gì trong
   thời gian xảy ra với tuyến chính hoặc đã được sửa ở đó rồi.

* Nếu hồi quy biến nó thành một bản phát hành chính thống thích hợp trong quá khứ
   12 tháng, hãy đảm bảo gắn thẻ bản sửa lỗi với "Cc: stable@vger.kernel.org", làm
   Chỉ riêng thẻ "Sửa lỗi:" không đảm bảo có cổng sau. Vui lòng thêm thẻ tương tự,
   trong trường hợp bạn biết thủ phạm đã được chuyển sang hạt nhân ổn định hoặc lâu dài.

* Khi nhận được báo cáo về sự hồi quy trong kernel ổn định hoặc dài hạn gần đây
   loạt, vui lòng đánh giá ít nhất một cách ngắn gọn xem sự cố có thể xảy ra trong phiên bản hiện tại hay không
   cả đường dây chính -- và nếu điều đó có vẻ có khả năng xảy ra, hãy giữ lại báo cáo. Nếu ở
   nghi ngờ, hãy yêu cầu phóng viên kiểm tra dòng chính.

* Bất cứ khi nào bạn muốn giải quyết nhanh chóng một hồi quy gần đây cũng đã thực hiện nó
   thành một bản phát hành chính thống, ổn định hoặc dài hạn phù hợp, hãy sửa nó nhanh chóng trong
   đường chính; do đó, khi thích hợp hãy nhờ Linus theo dõi nhanh việc sửa lỗi (xem
   ở trên). Đó là bởi vì nhóm ổn định thường không hoàn nguyên hay sửa chữa
   bất kỳ thay đổi nào gây ra vấn đề tương tự trong dòng chính.

* Trong trường hợp sửa lỗi hồi quy khẩn cấp, bạn có thể muốn đảm bảo nhanh chóng
   quay lại bằng cách gửi ghi chú cho nhóm ổn định sau khi bản sửa lỗi được thực hiện chính thức;
   điều này đặc biệt được khuyến khích trong quá trình hợp nhất các cửa sổ và ngay sau đó, vì
   nếu không thì bản sửa lỗi có thể xuất hiện ở cuối hàng đợi bản vá lớn.

Trên luồng bản vá:

* Các nhà phát triển, khi cố gắng đạt được khoảng thời gian nêu trên, hãy nhớ
   để tính đến thời gian cần thiết để các bản sửa lỗi được kiểm tra, xem xét và hợp nhất bởi
   Linus, lý tưởng nhất là chúng ở trong linux-next ít nhất một thời gian ngắn. Do đó, nếu một
   việc khắc phục là khẩn cấp, hãy làm rõ ràng để đảm bảo những người khác xử lý nó một cách thích hợp.

* Người đánh giá, vui lòng hỗ trợ các nhà phát triển đạt được thời gian
   được đề cập ở trên bằng cách xem xét các bản sửa lỗi hồi quy một cách kịp thời.

* Người bảo trì hệ thống phụ, bạn cũng được khuyến khích đẩy nhanh việc xử lý
   sửa lỗi hồi quy. Do đó, hãy đánh giá xem việc bỏ qua linux-next có phải là một lựa chọn cho
   cách khắc phục cụ thể. Ngoài ra, hãy cân nhắc việc gửi yêu cầu kéo git thường xuyên hơn
   thông thường khi cần thiết. Và cố gắng tránh giữ lại các bản sửa lỗi hồi quy
   cuối tuần -- đặc biệt là khi bản sửa lỗi được đánh dấu để chuyển ngược lại.


Các khía cạnh khác liên quan đến hồi quy mà các nhà phát triển nên biết
----------------------------------------------------------------


Làm thế nào để đối phó với những thay đổi khi biết đến nguy cơ hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đánh giá mức độ rủi ro hồi quy lớn như thế nào, ví dụ bằng cách thực hiện mã
tìm kiếm trong các bản phân phối Linux và các lò rèn Git. Cũng nên cân nhắc việc hỏi người khác
nhà phát triển hoặc dự án có khả năng bị ảnh hưởng để đánh giá hoặc thậm chí kiểm tra
đề xuất thay đổi; nếu vấn đề xuất hiện, có thể một số giải pháp có thể chấp nhận được cho tất cả mọi người
có thể được tìm thấy.

Nếu rủi ro hồi quy cuối cùng có vẻ tương đối nhỏ, hãy tiếp tục
với sự thay đổi, nhưng hãy để tất cả các bên liên quan biết về rủi ro. Do đó, làm
chắc chắn rằng mô tả bản vá của bạn làm cho khía cạnh này trở nên rõ ràng. Một khi sự thay đổi được thực hiện
được hợp nhất, báo cho trình theo dõi hồi quy của nhân Linux và gửi thư hồi quy
danh sách về rủi ro, vì vậy mọi người đều có sự thay đổi trên radar trong các báo cáo trường hợp
nhỏ giọt vào. Tùy thuộc vào rủi ro, bạn cũng có thể muốn hỏi hệ thống con
người bảo trì đề cập đến vấn đề trong yêu cầu kéo tuyến chính của mình.

Còn điều gì khác cần biết về hồi quy?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hãy xem Tài liệu/admin-guide/reporting-regressions.rst, nó bao gồm rất nhiều thứ
về các khía cạnh khác mà bạn muốn biết:

* mục đích của quy tắc "không hồi quy"

* vấn đề nào thực sự được coi là hồi quy

* người chịu trách nhiệm tìm ra nguyên nhân cốt lõi của sự hồi quy

* cách xử lý các tình huống khó khăn, ví dụ: khi sự hồi quy được gây ra bởi một
   sửa lỗi bảo mật hoặc khi sửa lỗi hồi quy có thể gây ra lỗi khác

Ai sẽ xin lời khuyên khi nói đến hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Gửi thư đến danh sách gửi thư hồi quy (regressions@lists.linux.dev) trong khi
CCing trình theo dõi hồi quy của nhân Linux (regressions@leemhuis.info); nếu
vấn đề có thể được giải quyết riêng tư tốt hơn, vui lòng bỏ qua danh sách.


Tìm hiểu thêm về theo dõi hồi quy và regzbot
------------------------------------------


Tại sao nhân Linux có trình theo dõi hồi quy và tại sao regzbot được sử dụng?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các quy tắc như "không hồi quy" cần có người đảm bảo chúng được tuân thủ, nếu không thì
chúng bị hỏng vô tình hoặc cố ý. Lịch sử đã chứng minh điều này
đúng với nhân Linux. Đó là lý do tại sao Thorsten Leemhuis tình nguyện tham gia
theo dõi mọi thứ như trình theo dõi hồi quy của nhân Linux, ai
thỉnh thoảng được người khác giúp đỡ. Không ai trong số họ được trả tiền để làm việc này,
đó là lý do tại sao việc theo dõi hồi quy được thực hiện trên cơ sở nỗ lực tốt nhất.

Những nỗ lực trước đây để theo dõi hồi quy theo cách thủ công đã cho thấy đây là một công việc mệt mỏi và
công việc chán nản, đó là lý do tại sao họ bị bỏ rơi sau một thời gian. Để ngăn chặn
để điều này không xảy ra lần nữa, Thorsten đã phát triển regzbot để tạo điều kiện thuận lợi cho công việc,
với mục tiêu dài hạn là tự động hóa việc theo dõi hồi quy nhiều nhất có thể cho
mọi người có liên quan.

Theo dõi hồi quy hoạt động như thế nào với regzbot?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bot theo dõi các câu trả lời cho các báo cáo về hồi quy được theo dõi. Ngoài ra,
nó đang tìm kiếm các bản vá đã đăng hoặc đã cam kết tham chiếu đến các báo cáo đó
với thẻ "Đóng:"; các câu trả lời cho các bài đăng bản vá như vậy cũng được theo dõi.
Kết hợp dữ liệu này cung cấp những hiểu biết sâu sắc về trạng thái sửa lỗi hiện tại
quá trình.

Regzbot cố gắng thực hiện công việc của mình với ít chi phí nhất có thể cho cả hai
phóng viên và nhà phát triển. Trên thực tế, chỉ có phóng viên mới phải chịu thêm gánh nặng
nhiệm vụ: họ cần thông báo cho regzbot về báo cáo hồi quy bằng lệnh ZZ0000ZZ đã nêu ở trên; nếu họ không làm điều đó thì người khác có thể
hãy giải quyết vấn đề đó bằng cách sử dụng ZZ0001ZZ.

Đối với các nhà phát triển, thông thường họ không phải làm thêm việc gì, họ chỉ cần thực hiện
chắc chắn sẽ làm điều gì đó đã được mong đợi từ lâu trước khi regzbot xuất hiện: thêm
liên kết đến mô tả bản vá trỏ đến tất cả các báo cáo về sự cố đã được khắc phục.

Tôi có phải sử dụng regzbot không?
~~~~~~~~~~~~~~~~~~~~~~~~~

Đó là lợi ích của mọi người nếu bạn làm như vậy, với tư cách là những người bảo trì kernel như Linus
Torvalds một phần dựa vào sự theo dõi của regzbot trong công việc của họ -- ví dụ như khi
quyết định phát hành phiên bản mới hoặc kéo dài giai đoạn phát triển. Vì điều này họ
cần phải nhận thức được tất cả các hồi quy không cố định; để làm điều đó, Linus được biết là đã tìm kiếm
vào các báo cáo hàng tuần được gửi bởi regzbot.

Tôi có phải nói với regzbot về mọi hồi quy mà tôi gặp phải không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lý tưởng nhất là có: tất cả chúng ta đều là con người và dễ dàng quên đi các vấn đề khi có điều gì đó hơn thế nữa xảy ra.
quan trọng bất ngờ xuất hiện -- ví dụ như một vấn đề lớn hơn trong Linux
kernel hoặc thứ gì đó trong cuộc sống thực khiến chúng ta tránh xa bàn phím trong một thời gian dài.
trong khi. Do đó, tốt nhất là nói với regzbot về mọi hồi quy, ngoại trừ khi bạn
ngay lập tức viết bản sửa lỗi và chuyển nó vào cây thường xuyên được sáp nhập vào cây bị ảnh hưởng
loạt hạt nhân.

Làm cách nào để xem hiện tại các bản nhạc regzbot hồi quy nào?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Kiểm tra ZZ0000ZZ
để biết thông tin mới nhất; cách khác, ZZ0001ZZ,
mà regzbot thường gửi mỗi tuần một lần vào tối Chủ nhật (UTC), đây là một
vài giờ trước khi Linus thường xuất bản các bản phát hành (tiền) mới.

Regzbot giám sát những nơi nào?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Regzbot đang xem danh sách gửi thư Linux quan trọng nhất cũng như git
kho lưu trữ của linux-next, mainline và ổn định/dài hạn.

Những loại vấn đề nào được cho là sẽ được theo dõi bởi regzbot?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bot này có nhiệm vụ theo dõi quá trình hồi quy, do đó vui lòng không sử dụng regzbot để
các vấn đề thường xuyên. Nhưng trình theo dõi hồi quy của nhân Linux sẽ không sao nếu bạn
sử dụng regzbot để theo dõi các sự cố nghiêm trọng, như báo cáo về việc bị treo, dữ liệu bị hỏng,
hoặc lỗi nội bộ (Hoảng loạn, Rất tiếc, BUG(), cảnh báo, ...).

Tôi có thể thêm các kết quả hồi quy do hệ thống CI tìm thấy vào tính năng theo dõi của regzbot không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hãy thoải mái làm như vậy nếu sự hồi quy cụ thể có thể có tác động đến kết quả thực tế
các trường hợp sử dụng và do đó có thể được người dùng chú ý; do đó, xin vui lòng không liên quan
regzbot dành cho các hồi quy lý thuyết khó có thể xuất hiện trong thế giới thực
cách sử dụng.

Làm thế nào để tương tác với regzbot?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bằng cách sử dụng 'lệnh regzbot' để trả lời trực tiếp hoặc gián tiếp thư có
báo cáo hồi quy. Các lệnh này cần phải nằm trong đoạn văn riêng của chúng (IOW: chúng
cần được phân tách khỏi phần còn lại của thư bằng các dòng trống).

Một lệnh như vậy là ZZ0000ZZ, lệnh này tạo ra
regzbot coi thư của bạn như một báo cáo hồi quy được thêm vào theo dõi, vì
đã được mô tả ở trên; ZZ0001ZZ là một cái khác
lệnh như vậy, khiến regzbot coi thư gốc là một báo cáo cho một
hồi quy mà nó bắt đầu theo dõi.

Khi một trong hai lệnh đó đã được sử dụng, các lệnh regzbot khác có thể được
được sử dụng trong các câu trả lời trực tiếp hoặc gián tiếp cho báo cáo. Bạn có thể viết chúng bên dưới một
của các lệnh ZZ0000ZZ hoặc trả lời thư sử dụng một trong các lệnh đó
hoặc chính nó là thư trả lời cho thư đó:

* Đặt hoặc cập nhật tiêu đề::

Tiêu đề #regzbot: foo

* Giám sát một cuộc thảo luận hoặc phiếu bugzilla.kernel.org nơi bổ sung các khía cạnh của
   vấn đề hoặc cách khắc phục được thảo luận -- ví dụ như đăng bản sửa lỗi
   hồi quy::

Màn hình #regzbot: ZZ0000ZZ

Việc giám sát chỉ hoạt động đối với lore.kernel.org và bugzilla.kernel.org; regzbot
   sẽ coi tất cả các tin nhắn trong chuỗi hoặc phiếu đó có liên quan đến việc sửa lỗi
   quá trình.

* Chỉ vào một địa điểm có thêm chi tiết quan tâm, chẳng hạn như bài đăng trong danh sách gửi thư
   hoặc một phiếu trong trình theo dõi lỗi có liên quan đôi chút nhưng về một vấn đề khác
   chủ đề::

Liên kết #regzbot: ZZ0000ZZ

* Đánh dấu một hồi quy được cố định bởi một cam kết đang tiến lên ngược dòng hoặc đã sẵn sàng
   hạ cánh::

Sửa lỗi #regzbot: 1f2e3d4c5d

* Đánh dấu một hồi quy là bản sao của một hồi quy khác đã được regzbot theo dõi::

Bản sao của #regzbot: ZZ0000ZZ

* Đánh dấu hồi quy là không hợp lệ::

#regzbot không hợp lệ: không phải là hồi quy, vấn đề luôn tồn tại

Còn điều gì nữa để nói về regzbot và các lệnh của nó không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Thông tin chi tiết và cập nhật hơn về Linux
bot theo dõi hồi quy của kernel có thể được tìm thấy trên
ZZ0000ZZ, trong số những cái khác
chứa ZZ0001ZZ
và ZZ0002ZZ
cả hai đều bao gồm nhiều chi tiết hơn phần trên.

Trích dẫn từ Linus về hồi quy
----------------------------------

Những phát biểu sau đây của Linus Torvalds cung cấp một số hiểu biết sâu sắc về Linux
Quy tắc "không hồi quy" và cách anh ấy mong đợi các hồi quy sẽ được xử lý:

Về việc hồi quy nên được khắc phục nhanh như thế nào
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Nhưng về cơ bản, người dùng phàn nàn sẽ dẫn đến việc khắc phục ngay lập tức -
    có thể là "hoàn nguyên và suy nghĩ lại".

Với phần giải thích sau về ZZ0000ZZ::

Cũng cần lưu ý rằng "ngay lập tức" rõ ràng không có nghĩa là "đúng".
    ZZ0000ZZ này khi sự cố đã được báo cáo".

Nhưng nếu đó là một sự hồi quy với một cam kết đã biết đã gây ra nó, tôi nghĩ
    nguyên tắc chung thường là "trong vòng một tuần", tốt nhất là
    trước RC tiếp theo.

* Từ ZZ0000ZZ::

Cam kết đã biết bị hỏng
     (a) được khắc phục kịp thời mà không có câu hỏi nào khác
    hoặc
     (b) được hoàn nguyên

* Từ ZZ0000ZZ::

[…] Quá trình xem xét không nên giữ nguyên các hồi quy được báo cáo của mã hiện có. Đó là
    chỉ là _testing_ cơ bản - nên áp dụng bản sửa lỗi hoặc - nếu bản sửa lỗi được
    quá xâm lấn hoặc quá xấu - nguồn hồi quy có vấn đề sẽ
    được hoàn nguyên.

Đánh giá phải là về mã mới, không nên trì hoãn "có một
    báo cáo lỗi, đây là cách khắc phục rõ ràng".

* Từ ZZ0000ZZ::

Nếu thứ gì đó thậm chí không được xây dựng, thì nó phải được sửa chữa ASAP.

Về cách khắc phục hồi quy bằng hoàn nguyên có thể giúp ngăn ngừa tình trạng kiệt sức của người bảo trì
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

> Vậy làm cách nào tôi/chúng tôi có thể khiến việc "sửa chữa ngay lập tức" diễn ra thường xuyên hơn mà không cần
    > góp phần khiến người bảo trì kiệt sức?

[…] mô hình "hoàn nguyên và suy nghĩ lại" […] thường là một ý tưởng hay nói chung […]

Chính xác là để người bảo trì không bị căng thẳng vì có một hồ sơ đang chờ xử lý
    báo cáo vấn đề mà mọi người cứ làm phiền họ.

Tôi nghĩ mọi người đôi khi hơi quá tin vào bất cứ thay đổi nào
    họ đã thực hiện và việc hoàn nguyên được coi là "quá quyết liệt", nhưng tôi nghĩ đó là
    thường là giải pháp nhanh chóng và dễ dàng khi không có một số điều rõ ràng
    phản hồi đối với một báo cáo hồi quy.

Về các bản sửa lỗi chính khi đóng -rc hoặc bản phát hành mới
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Vì vậy, tôi nghĩ tôi thà thấy họ tấn công RC8 (sau ngày hôm nay) và có một tuần
    thử nghiệm trên cây của tôi và được hoàn nguyên nếu chúng gây ra sự cố, hơn là
    yêu cầu họ truy cập sau RC8 và sau đó gây ra sự cố trong bản phát hành 6.19
    thay vào đó.

* Từ ZZ0000ZZ::

Nhưng một cái gì đó như thế này, nơi hồi quy trong bản phát hành trước
    và đó chỉ là một bản sửa lỗi rõ ràng, không có sự tinh tế về mặt ngữ nghĩa, tôi coi đó chỉ là một
    hồi quy thường xuyên cần được đẩy nhanh - một phần để làm cho nó ổn định,
    và một phần để tránh phải đưa bản sửa lỗi vào kernel ổn định _another_.

Về việc gửi yêu cầu hợp nhất chỉ bằng một lần sửa lỗi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Nếu vấn đề chỉ là không có gì khác xảy ra, tôi nghĩ mọi người
    chỉ nên chỉ cho tôi bản vá và nói "bạn có thể áp dụng bản sửa lỗi này không?"

* Từ ZZ0000ZZ::

Tôi luôn sẵn sàng trực tiếp sửa chữa khi không có tranh cãi nào về việc sửa chữa.
    Không có gì. Tôi vẫn vui vẻ giải quyết các bản vá riêng lẻ.

Về tầm quan trọng của việc trỏ tới báo cáo lỗi bằng thẻ Link:/Closes:
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

[...] hoàn nguyên như thế này, thực sự sẽ rất tốt nếu liên kết với các vấn đề, vì vậy
    rằng khi mọi người cố gắng kích hoạt lại nó, họ sẽ biết lý do tại sao nó
    đã không hoạt động trong lần đầu tiên

* Từ ZZ0000ZZ::

Vì thế tôi lại phải phàn nàn một lần nữa […]

[…] Không có mối liên hệ nào với vấn đề thực tế mà bản vá đã khắc phục.

* Từ ZZ0000ZZ::

Hãy xem, liên kết ZZ0000ZZ [đến báo cáo] sẽ hữu ích trong cam kết.

Về lý do tồn tại quy tắc "không hồi quy"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Nhưng nguyên tắc cơ bản là: hãy thật giỏi về khả năng tương thích ngược
    người dùng không bao giờ phải lo lắng về việc nâng cấp. Họ hoàn toàn nên cảm thấy
    tự tin rằng mọi vấn đề được báo cáo về kernel sẽ được giải quyết hoặc
    có một giải pháp dễ dàng phù hợp với ZZ0000ZZ (tức là một
    người dùng không có kỹ thuật không nên mong đợi có thể làm được nhiều việc).

Bởi vì điều cuối cùng chúng tôi muốn là mọi người ngần ngại thử những điều mới
    hạt nhân.

* Từ ZZ0000ZZ::

Tôi đã giới thiệu quy tắc "không hồi quy" khoảng hai thập kỷ
    trước đây, bởi vì mọi người cần có khả năng cập nhật kernel của mình mà không cần
    sợ điều gì đó mà họ đang dựa vào đột nhiên ngừng làm việc.

* Từ ZZ0000ZZ::

Mục đích chung của "chúng tôi không thoái lui" là để mọi người có thể nâng cấp
    kernel và không bao giờ phải lo lắng về nó.

[…]

Bởi vì điều duy nhất quan trọng LÀ THE USER.

* Từ ZZ0000ZZ::

Nếu kernel đã từng hoạt động với bạn thì quy tắc là nó sẽ tiếp tục hoạt động
    dành cho bạn.

[…]

Về cơ bản, mọi người phải luôn cảm thấy như họ có thể cập nhật kernel của mình
    và đơn giản là không phải lo lắng về điều đó.

Tôi từ chối giới thiệu "bạn chỉ có thể cập nhật kernel nếu bạn cũng
    cập nhật loại chương trình khác" đó. Nếu hạt nhân được sử dụng để
    làm việc cho bạn, nguyên tắc là nó sẽ tiếp tục làm việc cho bạn.

Về các trường hợp ngoại lệ đối với quy tắc "không hồi quy"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Có _rất_ ít trường hợp ngoại lệ đối với quy tắc đó, ngoại lệ chính là "
    vấn đề này là một vấn đề bảo mật cơ bản rất lớn và còn tồn tại và chúng tôi ZZ0000ZZ cần
    thực hiện thay đổi đó và chúng tôi thậm chí không thể biến trường hợp sử dụng hạn chế của bạn thành
    tiếp tục làm việc".

Ngoại lệ khác là "vấn đề đã được báo cáo nhiều năm sau khi nó được
    được giới thiệu và hiện nay hầu hết mọi người đều dựa vào hành vi mới".

[…]

Bây giờ, nếu đó là một hoặc hai người dùng và bạn có thể yêu cầu họ biên dịch lại,
    đó là một điều Phần cứng thích hợp và các trường hợp sử dụng kỳ quặc đôi khi có thể
    được giải quyết theo cách đó, và sự hồi quy đôi khi có thể được khắc phục bằng cách nắm giữ
    mỗi phóng viên nếu phóng viên sẵn sàng và có khả năng thay đổi
    quy trình làm việc của mình.

* Từ ZZ0000ZZ::

Và vâng, tôi coi "hồi quy trong bản phát hành trước đó" là một
    hồi quy cần sửa chữa.

Rõ ràng là có một giới hạn về thời gian: nếu "sự hồi quy ở thời điểm trước đó
    phát hành" cách đây một năm hoặc hơn và phải mất rất nhiều thời gian để mọi người
    thông báo và nó có những thay đổi về ngữ nghĩa mà giờ đây có nghĩa là việc sửa lỗi
    hồi quy có thể gây ra hồi quy _new_, thì điều đó có thể khiến tôi
    đi "Ồ, bây giờ ngữ nghĩa mới là thứ chúng ta phải sống chung".

* Từ ZZ0000ZZ::

Đã có những trường hợp ngoại lệ, nhưng chúng rất ít và xa nhau, và chúng
    nói chung có một số lý do cơ bản và chính yếu dẫn đến việc đã xảy ra,
    điều đó về cơ bản là hoàn toàn không thể tránh khỏi và mọi người _đã_cố_cố gắng_
    tránh chúng. Có lẽ chúng ta thực tế không thể hỗ trợ phần cứng nữa
    sau khi nó đã tồn tại hàng thập kỷ và không ai sử dụng nó với các hạt nhân hiện đại nữa
    nhiều hơn nữa. Có thể có vấn đề bảo mật nghiêm trọng trong cách chúng tôi thực hiện mọi việc,
    và mọi người thực sự phụ thuộc vào mô hình đã bị phá vỡ về cơ bản đó. Có lẽ
    có một số sự cố cơ bản khác mà _had_ có
    ngày chào cờ vì những lý do rất cốt lõi và cơ bản.

Trong các tình huống cập nhật nội dung nào đó trong không gian người dùng có thể giải quyết hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Và chết tiệt, chúng tôi nâng cấp kernel ALL THE TIME mà không nâng cấp bất kỳ
    các chương trình khác cả. Điều này là hoàn toàn cần thiết bởi vì những ngày chào cờ
    và sự phụ thuộc là tồi tệ khủng khiếp.

Và nó cũng được yêu cầu đơn giản vì tôi, với tư cách là nhà phát triển kernel, không
    nâng cấp ngẫu nhiên các công cụ khác mà tôi thậm chí không quan tâm khi phát triển
    kernel và tôi muốn bất kỳ người dùng nào của tôi cảm thấy an toàn khi làm điều đó.

* Từ ZZ0000ZZ::

Nhưng nếu có điều gì đó thực sự bị hỏng thì thay đổi đó phải được sửa chữa hoặc
    được hoàn nguyên. Và nó đã được sửa trong ZZ0000ZZ. Không phải bằng cách nói "Ồ, hãy sửa chữa
    không gian người dùng rồi". Đó là một sự thay đổi kernel đã bộc lộ vấn đề, nó cần
    là hạt nhân sửa lỗi cho nó, bởi vì chúng tôi có một "bản nâng cấp tại chỗ"
    mô hình. Chúng tôi không có "nâng cấp với không gian người dùng mới".

Và tôi nghiêm túc sẽ từ chối lấy mã từ những người không hiểu
    và tôn trọng quy tắc rất đơn giản này.

Quy tắc này cũng sẽ không thay đổi.

Và vâng, tôi nhận ra rằng kernel "đặc biệt" về mặt này. tôi tự hào
    của nó.

* Từ ZZ0000ZZ::

Nếu bạn phá vỡ thiết lập không gian người dùng hiện có thì THAT LÀ REGRESSION.

Sẽ không ổn khi nói "nhưng chúng tôi sẽ sửa lỗi thiết lập không gian người dùng".

Thật sự. NOT được rồi.

Về những gì đủ điều kiện là giao diện không gian người dùng, ABI, API, giao diện được ghi lại, v.v.
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Vì vậy, tôi hoàn toàn ghét bỏ toàn bộ khái niệm "ABI thay đổi". Đó là một
    khái niệm vô nghĩa, và tôi cực kỳ ghét nó, […]

Quy tắc hồi quy của Linux về cơ bản dựa trên triết lý
    Câu hỏi “Nếu một cái cây đổ trong rừng và không có ai xung quanh
    nghe thấy nó, nó có phát ra âm thanh không?”.

Vì vậy, điều quan trọng duy nhất là nếu có thứ gì đó làm hỏng người dùng-ZZ0000ZZ
    hành vi.

Và khi điều đó xảy ra, sự khác biệt giữa "sửa lỗi" và "mới
    tính năng" và "thay đổi ABI" không phải là vấn đề nhỏ và sự thay đổi cần
    phải được thực hiện khác nhau.

[…]

Tôi chỉ muốn chỉ ra rằng cuộc tranh luận về việc liệu đó có phải là ABI hay không
    thay đổi hay không không quan trọng. Nếu hóa ra một chương trình nào đó - không phải là một bài kiểm tra
    kịch bản, nhưng một cái gì đó có liên quan đến mong đợi của người dùng có ý thức ~
    phụ thuộc vào hành vi cũ đã hỏng thì cần phải thực hiện một số hành vi khác
    cách.

* Từ ZZ0000ZZ::

> [...] điều này không nên nằm trong quy tắc không phá vỡ không gian người dùng […]

Lưu ý rằng quy tắc là phá vỡ ZZ0000ZZ, không phá vỡ không gian người dùng trên mỗi
    se. […]

Nếu một số thiết lập của người dùng bị hỏng thì mọi thứ cần được sửa chữa.

[…] nhưng tôi muốn nói rõ rằng không có lời bào chữa nào về "người dùng
    ứng dụng không gian”.

* Từ ZZ0000ZZ::

[…] sự hồi quy hơi giống con mèo của Schrödinger - nếu không có ai ở xung quanh
    để ý đến nó và nó không thực sự ảnh hưởng đến bất kỳ khối lượng công việc thực sự nào, thì bạn
    có thể coi hồi quy như thể nó không tồn tại.

* Từ ZZ0000ZZ::

Các quy tắc về hồi quy chưa bao giờ được ghi lại trong bất kỳ loại nào
    hành vi hoặc nơi mã tồn tại.

Các quy tắc về hồi quy luôn là "phá vỡ quy trình làm việc của người dùng".

Người dùng thực sự là thứ _only_ quan trọng.

* Từ ZZ0000ZZ::

Một lần hoàn nguyên _đặc biệt_ vào phút cuối là lần cam kết cao nhất (bỏ qua
    phiên bản tự thay đổi) được thực hiện ngay trước khi phát hành và trong khi
    nó rất khó chịu, có lẽ nó cũng mang tính hướng dẫn.

Điều mang tính hướng dẫn là tôi đã hoàn nguyên một cam kết không đúng
    thực sự có lỗi. Trên thực tế, nó đã làm chính xác những gì nó đặt ra,
    và đã làm nó rất tốt. Trên thực tế, nó đã làm được điều đó _tốt_ đến mức
    các mẫu IO được cải thiện mà nó gây ra rồi cuối cùng lại tiết lộ một giao diện người dùng có thể nhìn thấy
    hồi quy do lỗi thực sự ở một khu vực hoàn toàn không liên quan.

Các chi tiết thực sự của sự hồi quy đó không phải là lý do khiến tôi chỉ ra rằng
    Tuy nhiên, hãy hoàn nguyên như một hướng dẫn. Hơn nữa đó là một bài học
    ví dụ về những gì được coi là hồi quy và toàn bộ câu trả lời "không
    quy tắc hạt nhân" có nghĩa là hồi quy.

[…] Cam kết được hoàn nguyên không thay đổi bất kỳ API nào và nó không giới thiệu
    bất kỳ lỗi mới nào. Nhưng cuối cùng nó lại bộc lộ một vấn đề khác, và điều đó đã gây ra
    nâng cấp kernel không thành công đối với người dùng. Vì vậy, nó đã được hoàn nguyên.

Vấn đề ở đây là chúng tôi hoàn nguyên dựa trên _hành vi_ do người dùng báo cáo chứ không phải
    dựa trên một số khái niệm "nó thay đổi ABI" hoặc "nó gây ra lỗi". vấn đề
    thực sự đã tồn tại từ trước và nó chưa từng được kích hoạt trước đó. […]

Rút ra khỏi toàn bộ vấn đề: vấn đề không phải là bạn có thay đổi
    kernel-userspace ABI, hoặc sửa lỗi, hoặc về việc mã cũ có
    "đáng lẽ không bao giờ nên làm việc ngay từ đầu". Đó là về việc liệu
    điều gì đó phá vỡ quy trình làm việc của người dùng hiện tại.

* Từ ZZ0000ZZ::

Và quy tắc hồi quy của chúng tôi chưa bao giờ là “hành vi không thay đổi”.
    Điều đó có nghĩa là chúng tôi không bao giờ có thể thực hiện bất kỳ thay đổi nào cả.

* Từ ZZ0000ZZ::

Không có bất kỳ câu nói "bạn không nên sử dụng cái này" hay "hành vi đó là
    không xác định, đó là lỗi của chính bạn, ứng dụng của bạn đã bị hỏng" hoặc "đã từng hoạt động
    đơn giản chỉ vì lỗi kernel" hoàn toàn có liên quan.

* Từ ZZ0000ZZ::

Nhưng không, "điều đó đã được ghi nhận là đã bị hỏng" (cho dù đó là do mã
    đang được dàn dựng hoặc vì trang man đã nói điều gì đó khác) là không liên quan.
    Nếu mã dàn dựng hữu ích đến mức mọi người cuối cùng sử dụng nó, điều đó có nghĩa là
    về cơ bản nó là mã hạt nhân thông thường với một lá cờ có nội dung "vui lòng dọn dẹp cái này
    lên".

[…]

Mặt khác của vấn đề là những người nói về "sự ổn định của API" là
    hoàn toàn sai. API cũng không thành vấn đề. Bạn có thể thực hiện bất kỳ thay đổi nào đối với một
    API bạn thích - miễn là không ai để ý.

Một lần nữa, quy tắc hồi quy không phải về tài liệu, không phải về API, và
    không phải về giai đoạn của mặt trăng.

* Từ ZZ0000ZZ::

> Điều này khiến tôi băn khoăn liệu Debian _unstable_ có thực sự đủ tiêu chuẩn là một
    > không gian người dùng phân phối tiêu chuẩn.

Ồ, nếu kernel phá vỡ một số không gian người dùng tiêu chuẩn, điều đó sẽ được tính. tấn
    số người chạy Debian không ổn định

* Từ ZZ0000ZZ::

Rõ ràng NOT là một điểm theo dõi nội bộ. Theo định nghĩa. Nó đang được
    được sử dụng bởi powertop.

Về các hồi quy được người dùng hoặc bộ thử nghiệm/CI nhận thấy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Người dùng phàn nàn là dòng thực sự duy nhất cuối cùng.

[…] Việc phàn nàn về bộ thử nghiệm thường là một dấu hiệu tốt cho ZZ0000ZZ rằng
    có thể người dùng sẽ gặp phải một số vấn đề và cần xử lý các vấn đề về bộ thử nghiệm
    rất nghiêm túc […]

Nhưng lỗi của bộ thử nghiệm không nhất thiết là lỗi mà bạn phải rút ra
    dòng - đó là một lá cờ đỏ lớn […]

* Từ ZZ0000ZZ::

Quy tắc "không hồi quy" không phải là chuyện bịa đặt "nếu tôi làm điều này, hành vi
    những thay đổi".

Quy tắc "không hồi quy" là về ZZ0000ZZ.

Nếu bạn có một người dùng thực sự đang làm những việc điên rồ và chúng tôi
    thay đổi điều gì đó, và bây giờ điều điên rồ đó không còn tác dụng nữa, lúc đó
    chỉ ra rằng đó là một sự thoái lui và chúng tôi sẽ thở dài và nói "Người dùng thật điên rồ" và
    phải sửa nó.

Nhưng nếu bạn có một số thử nghiệm ngẫu nhiên mà bây giờ hoạt động khác đi, thì đó là
    không phải là sự hồi quy. Chắc chắn đó là dấu hiệu ZZ0000ZZ: các bài kiểm tra rất hữu ích.

Về việc chấp nhận khi xảy ra hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Nhưng việc bắt đầu tranh luận về việc người dùng báo cáo những thay đổi vi phạm là điều
    về cơ bản là dòng cuối cùng đối với tôi. Tôi có một vài người mà tôi có
    trong danh sách chặn thư rác của tôi và từ chối liên quan đến nó, và họ
    nói chung là về điều đó.

Hãy lưu ý rằng đây không phải là việc mắc sai lầm và gây ra sự thoái lui.
    Điều đó là bình thường. Đó là sự phát triển. Nhưng sau đó tranh luận về nó là một
    không-không.

* Từ ZZ0000ZZ::

Chúng tôi không đưa ra các hồi quy và sau đó đổ lỗi cho người khác.

Có một quy tắc rất rõ ràng trong việc phát triển kernel: những thứ bị hỏng
    những thứ khác ARE NOT FIXES.

EVER.

Chúng được hoàn nguyên hoặc thứ chúng làm hỏng sẽ được sửa chữa.

* Từ ZZ0000ZZ::

THERE ARE KHÔNG VALID ARGUMENTS FOR REGRESSIONS.

Thành thật mà nói, dân bảo mật cần hiểu rằng "không hoạt động" là không
    một trường hợp thành công về bảo mật. Đó là một trường hợp thất bại.

Có, "không hoạt động" có thể an toàn. Nhưng bảo mật trong trường hợp đó là ZZ0000ZZ.

* Từ ZZ0000ZZ::

[…] Khi xảy ra hồi quy ZZ0000ZZ, chúng tôi thừa nhận và sửa chúng, thay vì
    đổ lỗi cho không gian người dùng.

Thực tế là bây giờ bạn rõ ràng đã phủ nhận sự hồi quy
    ba tuần có nghĩa là tôi sẽ hoàn nguyên và tôi sẽ ngừng kéo trang bị
    yêu cầu cho đến khi những người liên quan hiểu cách phát triển kernel
    đã xong.

Đi tới đi lui
~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Quy tắc "không hồi quy" là chúng tôi không đưa ra lỗi NEW.

ZZ0000ZZ ra đời vì chúng tôi đã có một điệu nhảy bất tận về việc "sửa hai
    lỗi, giới thiệu một lỗi mới", và điều đó dẫn đến một hệ thống
    bạn không thể TRUST.

* Từ ZZ0000ZZ::

Và điều làm cho sự hồi quy trở nên đặc biệt là khi tôi
    không quá nghiêm khắc về những điều này, chúng ta sẽ kết thúc trong tình trạng "bập bênh" vô tận.
    tình huống" khi ai đó sửa chữa thứ gì đó, nó sẽ bị hỏng
    thứ khác, thì thứ khác đó sẽ vỡ, và nó sẽ
    không bao giờ thực sự hội tụ vào bất cứ điều gì đáng tin cậy cả.

* Từ ZZ0000ZZ::

Chính sách nghiêm ngặt không hồi quy thực sự ban đầu được bắt đầu chủ yếu bằng văn bản
    tạm dừng/tiếp tục các sự cố, trong đó kiểu "sửa máy này, hỏng máy khác"
    qua lại gây ra vô số vấn đề và có nghĩa là chúng tôi đã không thực sự
    nhất thiết phải đạt được bất kỳ tiến bộ nào về phía trước, chỉ cần giải quyết một vấn đề xung quanh.

Về những thay đổi có nguy cơ gây ra hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Vì vậy, điều tôi nghĩ bạn nên làm là sửa lỗi đúng cách, sạch sẽ
    bản vá và không có hack điên rồ. Đó là điều chúng ta có thể áp dụng và
    kiểm tra. Trong khi vẫn biết rõ rằng "uhhuh, đây là điều có thể nhìn thấy được
    thay đổi, chúng tôi có thể phải hoàn nguyên nó".

Nếu sau đó một số tải ZZ0000ZZ hiển thị hồi quy, chúng ta có thể chỉ
    vặn vẹo. Hành vi hiện tại của chúng tôi có thể có lỗi, nhưng chúng tôi có quy tắc rằng
    một khi không gian người dùng phụ thuộc vào lỗi kernel, chúng sẽ trở thành những tính năng khá hay
    theo định nghĩa, nhiều đến mức chúng ta có thể không thích nó.

Về các giải pháp trong kernel để tránh hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Những thay đổi về hành vi xảy ra và có thể chúng tôi thậm chí không hỗ trợ một số
    tính năng nào nữa. Có một số trường trong /proc/<pid>/stat
    được in ra dưới dạng số 0, đơn giản vì chúng thậm chí không có ZZ0000ZZ trong
    kernel nữa, hoặc vì hiển thị chúng là một sai lầm (thường là
    rò rỉ thông tin). Nhưng các con số đã được thay thế bằng số 0, nên
    mã được sử dụng để phân tích các trường vẫn hoạt động. Người dùng có thể không
    nhìn thấy mọi thứ họ từng thấy, và do đó hành vi rõ ràng là khác biệt,
    nhưng mọi thứ vẫn _hoạt động_, ngay cả khi chúng có thể không còn hiển thị nhạy cảm nữa
    (hoặc không còn phù hợp) thông tin.

Về các hồi quy do sửa lỗi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

> Kernel có lỗi đã được sửa

Đó là ZZ0000ZZ phi vật chất.

Các bạn ơi, có lỗi gì không DOES NOT MATTER.

[…]

Về cơ bản nó có nghĩa là "Tôi đã lấy thứ gì đó hoạt động được và tôi đã phá vỡ nó,
    nhưng bây giờ thì đỡ hơn rồi”. Bạn không thấy câu nói đó điên rồ đến thế nào à
    là?

Về những thay đổi nội bộ của API
~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Chúng tôi luôn thực hiện việc phá vỡ API _inside_ kernel. Chúng tôi sẽ sửa chữa
    vấn đề nội bộ bằng cách nói "bây giờ bạn cần thực hiện XYZ", nhưng sau đó
    về kernel nội bộ của API và những người làm điều đó cũng vậy
    rõ ràng là phải khắc phục tất cả người dùng trong kernel của API đó. không có ai
    có thể nói "Bây giờ tôi đã làm hỏng chiếc API mà bạn đã sử dụng và bây giờ _bạn_ cần sửa nó
    lên". Ai làm vỡ cái gì thì cũng có thể sửa nó.

Trên hồi quy chỉ được tìm thấy sau một thời gian dài
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ::

Tôi chắc chắn sẽ không hoàn nguyên một bản vá từ gần một thập kỷ trước như một bản vá
    hồi quy.

Nếu phải mất nhiều thời gian để tìm thấy, nó không thể là một sự hồi quy quan trọng.

Vì vậy, hãy coi nó như một lỗi thông thường.

Khi kiểm tra các bản sửa lỗi hồi quy trong linux-next
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Trên ZZ0000ZZ::

Vì vậy, chạy các bản sửa lỗi mặc dù linux-next chỉ lãng phí thời gian.

Về một số khía cạnh khác liên quan đến hồi quy
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Từ ZZ0000ZZ
  [ZZ0001ZZ]::

Tôi không còn âm thanh nữa.

Tôi cũng nghi ngờ rằng đó hoàn toàn là do "make oldconfig" không hoạt động,
    và có thể đã tắt cài đặt Intel HDA cũ của tôi. Hoặc một cái gì đó.

Đổi tên thông số cấu hình là ZZ0000ZZ. Tôi đã bắt kịp giai đoạn Kconfig
    việc xây dựng kernel có lẽ là điểm khó chịu nhất của chúng tôi và là một nỗi đau thực sự
    chỉ ra rằng mọi người tham gia vào quá trình phát triển chỉ vì
    xây dựng hạt nhân của riêng bạn có thể rất khó khăn với hàng trăm
    những câu hỏi bí truyền.

..
   end-of-content
..
   This text is available under GPL-2.0+ or CC-BY-4.0, as stated at the top
   of the file. If you want to distribute this text under CC-BY-4.0 only,
   please use "The Linux kernel developers" for author attribution and link
   this as source:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/process/handling-regressions.rst
..
   Note: Only the content of this RST file as found in the Linux kernel sources
   is available under CC-BY-4.0, as versions of this text that were processed
   (for example by the kernel's build system) might contain content taken from
   files which use a more restrictive license.