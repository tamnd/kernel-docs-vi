.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/management-style.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _managementstyle:

Phong cách quản lý hạt nhân Linux
=================================

Đây là một tài liệu ngắn mô tả ưu tiên (hoặc tạo thành, tùy thuộc vào
vào người bạn hỏi) kiểu quản lý cho nhân linux.  Nó có nghĩa là
phản chiếu tài liệu ZZ0000ZZ cho một số người
độ, và chủ yếu được viết để tránh trả lời [#f1]_ giống nhau (hoặc tương tự)
những câu hỏi lặp đi lặp lại.

Phong cách quản lý mang tính cá nhân và khó định lượng hơn nhiều so với phong cách quản lý
các quy tắc về kiểu mã hóa đơn giản, vì vậy tài liệu này có thể có hoặc không có bất cứ điều gì
để làm với thực tế.  Nó bắt đầu như một con chim sơn ca, nhưng điều đó không có nghĩa là nó
có thể không thực sự đúng. Bạn sẽ phải tự quyết định.

Nhân tiện, khi nói về "trình quản lý hạt nhân", tất cả đều là về kỹ thuật
người lãnh đạo, không phải người quản lý truyền thống bên trong
các công ty.  Nếu bạn ký đơn đặt hàng hoặc bạn có bất kỳ manh mối nào về
ngân sách của nhóm bạn, bạn gần như chắc chắn không phải là người quản lý hạt nhân.
Những gợi ý này có thể áp dụng hoặc không áp dụng cho bạn.

Trước hết, tôi khuyên bạn nên mua "Bảy thói quen hiệu quả cao".
Mọi người", và NOT đã đọc nó.  Đốt nó đi, đó là một cử chỉ mang tính biểu tượng tuyệt vời.

.. [#f1] This document does so not so much by answering the question, but by
  making it painfully obvious to the questioner that we don't have a clue
  to what the answer is.

Dù sao, đây là:

.. _decisions:

1) Quyết định
-------------

Mọi người đều nghĩ rằng các nhà quản lý đưa ra quyết định và việc ra quyết định đó là
quan trọng.  Quyết định càng lớn và đau đớn thì càng lớn
người quản lý phải làm được điều đó.  Điều đó rất sâu sắc và rõ ràng, nhưng không phải vậy
thực sự đúng.

Tên của trò chơi là để ZZ0000ZZ phải đưa ra quyết định.  trong
Đặc biệt, nếu ai đó bảo bạn "chọn (a) hoặc (b), chúng tôi thực sự cần bạn
quyết định vấn đề này", bạn đang gặp rắc rối với tư cách là người quản lý.  Những người bạn
người quản lý biết rõ chi tiết hơn bạn, vì vậy nếu họ đến
bạn vì một quyết định kỹ thuật, bạn sẽ thất bại.  Rõ ràng là bạn không
có đủ thẩm quyền để đưa ra quyết định đó cho họ.

(Hệ quả tất yếu: nếu những người bạn quản lý không biết rõ chi tiết hơn
bạn, bạn cũng bị lừa, mặc dù vì một lý do hoàn toàn khác.
Cụ thể là bạn đang làm sai công việc và ZZ0000ZZ lẽ ra phải quản lý
thay vào đó là sự xuất sắc của bạn).

Vì vậy, tên của trò chơi là quyết định ZZ0000ZZ, ít nhất là lớn và
những nỗi đau.  Đưa ra những quyết định nhỏ và không gây hậu quả là tốt, và
khiến bạn có vẻ như biết rõ mình đang làm gì, vậy thì thật là một người quản lý hạt nhân
cần làm là biến những điều lớn lao và đau đớn thành những điều nhỏ nhặt
không ai thực sự quan tâm

Nó giúp nhận ra rằng sự khác biệt chính giữa một quyết định lớn và một
vấn đề nhỏ là liệu bạn có thể sửa chữa quyết định của mình sau đó hay không.  Mọi quyết định
có thể được làm nhỏ lại bằng cách luôn đảm bảo rằng nếu bạn sai (và
bạn ZZ0000ZZ sai), bạn luôn có thể khắc phục thiệt hại sau này bằng cách
quay lại.  Đột nhiên, bạn trở thành người quản lý gấp đôi để thực hiện
ZZ0001ZZ những quyết định vụn vặt - một sai lầm ZZ0002ZZ một quyết định đúng đắn.

Và mọi người thậm chí sẽ coi đó là khả năng lãnh đạo thực sự (ZZ0000ZZ nhảm nhí
ZZ0001ZZ).

Vì vậy, chìa khóa để tránh những quyết định lớn là tránh làm
những điều không thể làm lại được.  Đừng bị dồn vào một góc mà từ đó
bạn không thể trốn thoát.  Một con chuột bị dồn vào chân tường có thể nguy hiểm - người quản lý bị dồn vào chân tường
thật đáng thương.

Hóa ra là vì không ai đủ ngu ngốc để thực sự để
người quản lý hạt nhân có trách nhiệm tài chính rất lớn ZZ0000ZZ, thường là
khá dễ dàng để quay lại.  Vì bạn sẽ không thể lãng phí
số tiền khổng lồ mà bạn có thể không có khả năng hoàn trả, điều duy nhất
điều bạn có thể quay lại là một quyết định kỹ thuật, và ở đó
việc theo dõi lại rất dễ dàng: chỉ cần nói với mọi người rằng bạn là một
kẻ bất tài, hãy nói lời xin lỗi và hủy bỏ tất cả những điều vô giá trị
công việc mà bạn đã nhờ mọi người làm trong năm qua.  Đột nhiên quyết định
bạn đã đưa ra một năm trước không phải là một quyết định lớn vì nó có thể
dễ dàng hoàn tác.

Hoá ra là một số người gặp rắc rối với cách tiếp cận này, vì hai
lý do:

- thừa nhận mình là một tên ngốc khó hơn vẻ bề ngoài.  Tất cả chúng ta đều thích
   duy trì vẻ bề ngoài và xuất hiện trước công chúng để nói rằng bạn
   sai đôi khi thực sự rất khó khăn.
 - được ai đó nói cho bạn biết bạn đã làm gì trong năm vừa qua
   xét cho cùng thì không có giá trị gì có thể gây khó khăn cho những kỹ sư nghèo khổ
   cũng vậy, và mặc dù ZZ0000ZZ thực tế có thể hoàn tác đủ dễ dàng chỉ bằng
   xóa nó đi, bạn có thể đã mất niềm tin vào điều đó một cách không thể thay đổi được
   kỹ sư.  Và hãy nhớ: "không thể hủy ngang" là điều chúng tôi đã cố tránh trong
   vị trí đầu tiên và quyết định của bạn cuối cùng trở thành một quyết định lớn
   tất cả.

May mắn thay, cả hai lý do này đều có thể được giảm thiểu một cách hiệu quả chỉ bằng cách
thừa nhận ngay từ đầu rằng bạn không có manh mối gì đáng kinh ngạc và nói
mọi người biết trước rằng quyết định của bạn chỉ mang tính sơ bộ và
có thể là điều sai trái.  Bạn phải luôn có quyền thay đổi
tâm trí của bạn, và làm cho mọi người rất ZZ0000ZZ về điều đó.  Và nó dễ dàng hơn nhiều
phải thừa nhận rằng bạn thật ngu ngốc khi ZZ0001ZZ chưa thực sự làm được điều đó
điều ngu ngốc.

Sau đó, khi nó thực sự trở nên ngu ngốc, mọi người chỉ cần lăn lộn
mắt và nói "Rất tiếc, không phải nữa".

Việc thừa nhận trước sự kém cỏi này cũng có thể khiến những người
thực sự làm công việc đó cũng phải suy nghĩ kỹ xem liệu nó có đáng làm hay không
không.  Suy cho cùng, nếu ZZ0000ZZ không chắc chắn liệu đó có phải là một ý tưởng hay hay không thì bạn
chắc chắn không nên khuyến khích họ bằng cách hứa với họ rằng những gì họ
công việc đang làm sẽ được bao gồm.  Ít nhất hãy khiến họ suy nghĩ kỹ trước khi
bắt tay vào một nỗ lực lớn.

Hãy nhớ rằng: họ nên biết nhiều chi tiết hơn bạn và
họ thường nghĩ rằng họ đã có câu trả lời cho mọi thứ.  điều tốt nhất
điều bạn có thể làm với tư cách là người quản lý không phải là tạo dựng sự tự tin mà là
liều lượng tư duy phê phán lành mạnh về những gì họ làm.

Nhân tiện, một cách khác để tránh phải đưa ra quyết định là than vãn một cách than phiền "không thể
chúng ta chỉ làm cả hai thôi à?" và trông thật đáng thương.  Hãy tin tôi đi, nó có tác dụng đấy.  Nếu không
rõ cách tiếp cận nào tốt hơn thì cuối cùng họ sẽ tìm ra.  các
câu trả lời cuối cùng có thể là cả hai đội đều rất thất vọng vì
tình huống mà họ chỉ bỏ cuộc.

Điều đó nghe có vẻ như là một thất bại, nhưng đó thường là dấu hiệu cho thấy đã có
có điều gì đó không ổn xảy ra với cả hai dự án và lý do những người liên quan
không thể quyết định là cả hai đều sai.  Cuối cùng thì bạn cũng sắp tới
có mùi như hoa hồng, và bạn đã tránh được một quyết định khác mà bạn có thể
đã làm hỏng việc.


2) Con người
------------

Hầu hết mọi người đều là những kẻ ngốc và trở thành người quản lý đồng nghĩa với việc bạn sẽ phải giải quyết
với nó, và có lẽ quan trọng hơn là ZZ0000ZZ phải giải quyết
ZZ0001ZZ.

Hóa ra việc sửa chữa các lỗi kỹ thuật thì dễ dàng nhưng không phải
dễ dàng hóa giải những rối loạn nhân cách.  Bạn chỉ cần sống với
của họ - và của bạn.

Tuy nhiên, để chuẩn bị cho mình vai trò là người quản lý hạt nhân, tốt nhất bạn nên
hãy nhớ đừng đốt bất kỳ cây cầu nào, đánh bom bất kỳ dân làng vô tội nào, hoặc
xa lánh quá nhiều nhà phát triển kernel. Hóa ra người xa lánh
là khá dễ dàng, và việc xóa bỏ sự xa lánh của họ là điều khó khăn. Vì thế “xa lánh”
ngay lập tức rơi vào tiêu đề "không thể đảo ngược" và trở thành một
không-không theo ZZ0000ZZ.

Chỉ có một vài quy tắc đơn giản ở đây:

(1) đừng gọi mọi người là đồ d*ckhead (ít nhất là không ở nơi công cộng)
 (2) học cách xin lỗi khi quên quy tắc (1)

Vấn đề với #1 là nó rất dễ thực hiện, vì bạn có thể nói
"bạn là một tên khốn" theo hàng triệu cách khác nhau [#f2]_, đôi khi không có
thậm chí nhận ra điều đó, và hầu như luôn luôn có niềm tin mãnh liệt rằng
bạn nói đúng.

Và bạn càng tin rằng mình đúng (và hãy đối mặt với sự thật,
bạn có thể gọi ZZ0000ZZ là đồ ngu, và bạn thường coi ZZ0001ZZ là
đúng rồi), việc xin lỗi sau đó càng khó khăn hơn.

Để giải quyết vấn đề này, bạn thực sự chỉ có hai lựa chọn:

- thực sự giỏi trong việc xin lỗi
 - lan tỏa "tình yêu" một cách đồng đều đến mức không ai thực sự có cảm giác
   như thể họ bị nhắm mục tiêu một cách không công bằng.  Hãy làm cho nó đủ sáng tạo, và họ
   thậm chí có thể thích thú.

Lựa chọn luôn luôn lịch sự thực sự không tồn tại. Sẽ không có ai
hãy tin tưởng ai đó đang che giấu tính cách thật của họ một cách rõ ràng.

.. [#f2] Paul Simon sang "Fifty Ways to Leave Your Lover", because quite
  frankly, "A Million Ways to Tell a Developer They're a D*ckhead" doesn't
  scan nearly as well.  But I'm sure he thought about it.


3) Người II - Người Tốt
----------------------------

Mặc dù hóa ra hầu hết mọi người đều là những kẻ ngốc, nhưng hệ quả tất yếu của điều đó là
thật đáng buồn là bạn cũng là một trong số đó, và trong khi tất cả chúng ta đều có thể tận hưởng sự an toàn
biết rằng chúng ta tốt hơn người bình thường (hãy đối mặt với sự thật,
không ai tin rằng họ ở mức trung bình hoặc dưới mức trung bình), chúng ta nên
cũng thừa nhận rằng chúng ta không phải là con dao sắc bén nhất, và sẽ có
những người khác ít ngốc nghếch hơn bạn.

Một số người phản ứng không tốt với những người thông minh.  Những người khác tận dụng chúng.

Hãy đảm bảo rằng bạn, với tư cách là người bảo trì kernel, thuộc nhóm thứ hai.
Hãy yêu mến họ vì họ là những người sẽ tạo nên công việc của bạn
dễ dàng hơn. Đặc biệt, họ sẽ có thể đưa ra quyết định cho bạn,
đó chính là nội dung của trò chơi.

Vì vậy, khi bạn tìm thấy ai đó thông minh hơn mình, hãy cứ làm theo.  của bạn
trách nhiệm quản lý phần lớn trở thành những câu nói "Nghe có vẻ giống như một
ý tưởng hay - hãy mạnh dạn lên" hoặc "Nghe hay đó, nhưng còn xxx thì sao?".  các
phiên bản thứ hai nói riêng là một cách tuyệt vời để học điều gì đó
mới về "xxx" hoặc có vẻ như ZZ0000ZZ quản lý bằng cách chỉ ra điều gì đó
người thông minh hơn đã không nghĩ tới.  Trong cả hai trường hợp, bạn đều thắng.

Một điều cần chú ý là nhận ra rằng sự vĩ đại trong một lĩnh vực
không nhất thiết phải dịch sang các khu vực khác.  Vì vậy, bạn có thể khuyến khích mọi người tham gia
những hướng dẫn cụ thể, nhưng hãy đối mặt với sự thật, họ có thể giỏi những gì họ
làm và làm mọi thứ khác.  Tin tốt là mọi người có xu hướng
một cách tự nhiên họ sẽ quay lại với những gì họ giỏi, nên nó không giống bạn
đang làm điều gì đó không thể thay đổi được khi bạn ZZ0000ZZ kích động chúng trong một số trường hợp
hướng, đừng đẩy quá mạnh.


4) Đổ lỗi
----------------

Mọi việc sẽ không như ý muốn và mọi người muốn có ai đó chịu trách nhiệm. Tag, bạn là nó.

Thật ra không khó để chấp nhận sự đổ lỗi, đặc biệt nếu mọi người
kiểu như nhận ra rằng đó không phải lỗi của ZZ0000ZZ.  Điều này đưa chúng ta đến
Cách tốt nhất để nhận lỗi: làm điều đó cho người khác. Bạn sẽ cảm thấy tốt
vì đã vấp ngã, họ sẽ cảm thấy hài lòng vì không bị khiển trách, và
người đã mất toàn bộ bộ sưu tập khiêu dâm 36 GB của họ vì bạn
sự kém cỏi sẽ miễn cưỡng thừa nhận rằng ít nhất bạn đã không cố gắng né tránh
ra khỏi nó.

Sau đó, hãy cho nhà phát triển thực sự gặp khó khăn (nếu bạn có thể tìm thấy họ) biết
ZZ0000ZZ mà họ đã làm hỏng việc.  Không chỉ để họ có thể tránh nó trong
tương lai, nhưng để họ biết rằng họ nợ bạn một điều.  Và có lẽ còn hơn thế nữa
quan trọng là họ cũng có thể là người có thể sửa chữa nó.  Bởi vì, chúng ta hãy
đối mặt với nó đi, chắc chắn đó không phải là bạn.

Nhận lỗi cũng là lý do tại sao bạn được trở thành người quản lý ngay từ đầu.
Đó là một phần khiến mọi người tin tưởng bạn và cho phép bạn phát huy tiềm năng
vinh quang, bởi vì bạn là người có quyền nói "Tôi làm hỏng việc rồi".  Và nếu
bạn đã tuân theo các quy tắc trước đó, bạn sẽ khá giỏi khi nói điều đó
đến bây giờ.


5) Những điều cần tránh
-----------------------

Có một điều mà mọi người thậm chí còn ghét hơn cả việc bị gọi là "d*ckhead",
và điều đó đang được gọi là "d*ckhead" với giọng điệu tôn nghiêm.  các
đầu tiên bạn có thể xin lỗi, lần thứ hai bạn sẽ không thực sự hiểu được
cơ hội.  Họ có thể sẽ không còn lắng nghe ngay cả khi bạn không
làm tốt công việc

Tất cả chúng ta đều nghĩ mình giỏi hơn bất kỳ ai khác, điều đó có nghĩa là khi
ai đó khác phát sóng, ZZ0000ZZ đã khiến chúng tôi hiểu lầm.  Bạn có thể
vượt trội về mặt đạo đức và trí tuệ so với mọi người xung quanh bạn, nhưng
đừng cố làm nó quá rõ ràng trừ khi bạn thực sự khó chịu với ZZ0001ZZ
ai đó [#f3]_.

Tương tự, đừng quá lịch sự hay tế nhị trong mọi việc. Lịch sự dễ dàng
cuối cùng lại đi quá đà và che giấu vấn đề, và như họ nói, "Trên
internet, không ai có thể nghe thấy bạn đang tinh tế". Sử dụng một vật cùn lớn để
nhấn mạnh quan điểm, bởi vì bạn thực sự không thể phụ thuộc vào việc mọi người nhận được
quan điểm của bạn khác.

Một chút hài hước có thể giúp giảm bớt sự thẳng thừng và mang tính đạo đức.  Đi
quá nhiệt tình đến mức lố bịch có thể ghi điểm về nhà
mà không gây khó chịu cho người nhận, họ chỉ nghĩ rằng bạn đang
ngớ ngẩn.  Do đó, nó có thể giúp chúng ta vượt qua rào cản tinh thần cá nhân
có về những lời chỉ trích.

.. [#f3] Hint: internet newsgroups that are not directly related to your work
  are great ways to take out your frustrations at other people. Write
  insulting posts with a sneer just to get into a good flame every once in
  a while, and you'll feel cleansed. Just don't crap too close to home.


6) Tại sao lại là tôi?
----------------------

Vì trách nhiệm chính của bạn dường như là chịu trách nhiệm cho người khác
những sai lầm của mọi người và làm cho mọi người khác thấy rõ ràng một cách đau đớn rằng
bạn không đủ năng lực, câu hỏi hiển nhiên sẽ trở thành một trong những lý do tại sao bạn lại làm điều đó trong
vị trí đầu tiên?

Trước hết, mặc dù bạn có thể nghe thấy tiếng la hét của các cô gái tuổi teen (hoặc
các chàng trai, đừng phán xét hay phân biệt giới tính ở đây) chạm vào trang phục của bạn
cửa phòng, bạn ZZ0000ZZ sẽ có được cảm giác vô cùng thành tựu cá nhân
vì được "phụ trách".  Đừng bận tâm đến việc bạn đang thực sự dẫn đầu
bằng cách cố gắng theo kịp những người khác và chạy theo họ thật nhanh
như bạn có thể.  Mọi người vẫn sẽ nghĩ bạn là người chịu trách nhiệm.

Đó là một công việc tuyệt vời nếu bạn có thể hack nó.
