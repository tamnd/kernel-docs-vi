.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/idmappings.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Idmapping
==========

Hầu hết các nhà phát triển hệ thống tập tin sẽ gặp phải bản đồ id. Chúng được sử dụng khi
đọc hoặc ghi quyền sở hữu vào đĩa, báo cáo quyền sở hữu đối với không gian người dùng hoặc
để kiểm tra sự cho phép. Tài liệu này nhằm vào các nhà phát triển hệ thống tập tin
muốn biết idmappings hoạt động như thế nào.

ghi chú chính thức
------------

Bản đồ id về cơ bản là một bản dịch của một phạm vi id sang một id khác hoặc
cùng một dãy id. Quy ước ký hiệu cho ánh xạ id được sử dụng rộng rãi
trong không gian người dùng là::

bạn:k:r

ZZ0000ZZ cho biết phần tử đầu tiên trong idmapset trên ZZ0001ZZ và ZZ0002ZZ
cho biết phần tử đầu tiên trong idmapset thấp hơn ZZ0003ZZ. Thông số ZZ0004ZZ
cho biết phạm vi của ánh xạ id, tức là có bao nhiêu id được ánh xạ. Từ bây giờ
bật, chúng tôi sẽ luôn đặt tiền tố id bằng ZZ0005ZZ hoặc ZZ0006ZZ để làm rõ liệu
chúng ta đang nói về một id trong idmapset trên hoặc dưới.

Để xem điều này trông như thế nào trong thực tế, chúng ta hãy thực hiện bản đồ id sau::

u22:k10000:r3

và ghi lại các ánh xạ mà nó sẽ tạo ra ::

u22 -> k10000
 u23 -> k10001
 u24 -> k10002

Từ quan điểm toán học ZZ0000ZZ và ZZ0001ZZ là các tập hợp có thứ tự tốt và
idmapping là sự đẳng cấu thứ tự từ ZZ0002ZZ thành ZZ0003ZZ. Vậy ZZ0004ZZ và ZZ0005ZZ là
trật tự đẳng cấu. Trong thực tế, ZZ0006ZZ và ZZ0007ZZ luôn là các tập con có thứ tự tốt của
tập hợp tất cả các id có thể sử dụng được trên một hệ thống nhất định.

Nhìn vào điều này một cách ngắn gọn về mặt toán học sẽ giúp chúng ta làm nổi bật một số tính chất
điều đó giúp chúng ta dễ hiểu hơn về cách chúng ta có thể dịch giữa các bản đồ id. cho
Ví dụ: chúng ta biết rằng ánh xạ id nghịch đảo cũng là một đẳng cấu thứ tự ::

k10000 -> u22
 k10001 -> u23
 k10002 -> u24

Cho rằng chúng ta đang giải quyết các đẳng cấu bậc cộng với thực tế là chúng ta
xử lý các tập hợp con, chúng ta có thể nhúng các bản đồ id vào nhau, tức là chúng ta có thể
dịch hợp lý giữa các bản đồ id khác nhau. Ví dụ, giả sử chúng ta đã
đưa ra ba idmappings ::

1. u0:k10000:r10000
 2. u0:k20000:r10000
 3. u0:k30000:r10000

và id ZZ0000ZZ được tạo bởi bản đồ id đầu tiên bằng cách ánh xạ
ZZ0001ZZ từ idmapset trên xuống ZZ0002ZZ ở idmapset thấp hơn.

Bởi vì chúng ta đang xử lý các tập con đẳng cấu theo thứ tự nên việc hỏi
id ZZ0000ZZ tương ứng với id gì trong bản đồ id thứ hai hoặc thứ ba. các
thuật toán đơn giản để sử dụng là áp dụng nghịch đảo của bản đồ id đầu tiên,
ánh xạ ZZ0001ZZ lên tới ZZ0002ZZ. Sau đó, chúng ta có thể ánh xạ ZZ0003ZZ xuống bằng cách sử dụng
ánh xạ idmapping thứ hai hoặc ánh xạ idmapping thứ ba. thứ hai
idmapping sẽ ánh xạ ZZ0004ZZ xuống ZZ0005ZZ. Bản đồ id thứ ba sẽ ánh xạ
ZZ0006ZZ xuống còn ZZ0007ZZ.

Nếu chúng ta được giao cùng một nhiệm vụ cho ba bản đồ id sau::

1. u0:k10000:r10000
 2. u0:k20000:r200
 3. u0:k30000:r300

chúng tôi sẽ không dịch được vì các tập hợp không có thứ tự đẳng cấu trên toàn bộ
phạm vi của bản đồ id đầu tiên nữa (Tuy nhiên, chúng có thứ tự đẳng cấu trên
toàn bộ phạm vi của bản đồ id thứ hai.). Không phải bản đồ id thứ hai hoặc thứ ba
chứa ZZ0000ZZ trong idmapset trên ZZ0001ZZ. Điều này tương đương với việc không có
một id được ánh xạ. Chúng ta có thể nói một cách đơn giản rằng ZZ0002ZZ chưa được ánh xạ trong phần thứ hai và
bản đồ id thứ ba. Hạt nhân sẽ báo cáo các id chưa được ánh xạ dưới dạng tràn
ZZ0003ZZ hoặc tràn ZZ0004ZZ vào không gian người dùng.

Thuật toán để tính toán một id nhất định sẽ ánh xạ tới cái gì khá đơn giản. Đầu tiên, chúng tôi
cần xác minh rằng phạm vi có thể chứa id mục tiêu của chúng tôi. Chúng ta sẽ bỏ qua bước này
để đơn giản. Sau đó, nếu chúng ta muốn biết ZZ0000ZZ ánh xạ tới những gì chúng ta có thể làm
tính toán đơn giản:

- Nếu chúng ta muốn ánh xạ từ trái sang phải::

bạn:k:r
   id - u + k = n

- Nếu ta muốn ánh xạ từ phải sang trái::

bạn:k:r
   id - k + u = n

Thay vì "trái sang phải" chúng ta cũng có thể nói "xuống" và thay vì "phải sang
trái" chúng ta cũng có thể nói "lên". Rõ ràng ánh xạ xuống và lên đảo ngược lẫn nhau.

Để xem liệu các công thức đơn giản trên có hiệu quả hay không, hãy xem xét hai công thức sau
bản đồ id::

1. u0:k20000:r10000
 2. u500:k30000:r10000

Giả sử chúng ta có ZZ0000ZZ trong idmapset thấp hơn của idmapping đầu tiên. Chúng tôi
muốn biết id này được ánh xạ từ idmapset phía trên của id đầu tiên
idmapping. Vì vậy, chúng tôi đang lập bản đồ trong bản đồ id đầu tiên::

id - k + u = n
 k21000 - k20000 + u0 = u1000

Bây giờ giả sử chúng ta được cấp id ZZ0000ZZ trong idmapset phía trên của phần thứ hai
idmapping và chúng tôi muốn biết id này ánh xạ tới cái gì trong idmapset thấp hơn
của bản đồ id thứ hai. Điều này có nghĩa là chúng tôi đang lập bản đồ ở phần thứ hai
lập bản đồ::

id - u + k = n
 u1100 - u500 + k30000 = k30600

Ghi chú chung
-------------

Trong ngữ cảnh của kernel, việc ánh xạ id có thể được hiểu là ánh xạ một phạm vi
của id không gian người dùng vào một phạm vi id kernel::

không gian người dùng-id:kernel-id:phạm vi

Id không gian người dùng luôn là một thành phần trong idmapset phía trên của bản đồ id của
gõ ZZ0000ZZ hoặc ZZ0001ZZ và id kernel luôn là một phần tử ở phía dưới
idmapset của idmapping loại ZZ0002ZZ hoặc ZZ0003ZZ. Từ giờ trở đi
"id không gian người dùng" sẽ được sử dụng để chỉ ZZ0004ZZ và ZZ0005ZZ nổi tiếng
các loại và "id hạt nhân" sẽ được sử dụng để chỉ ZZ0006ZZ và ZZ0007ZZ.

Kernel chủ yếu liên quan đến id kernel. Chúng được sử dụng khi biểu diễn
kiểm tra quyền và được lưu trữ trong trường ZZ0000ZZ và ZZ0001ZZ của inode.
Mặt khác, id không gian người dùng là một id được báo cáo cho không gian người dùng bởi
kernel hoặc được không gian người dùng chuyển tới kernel hoặc id thiết bị thô được
ghi hoặc đọc từ đĩa.

Lưu ý rằng chúng tôi chỉ quan tâm đến idmappings vì kernel không lưu trữ chúng
không gian người dùng sẽ chỉ định chúng như thế nào.

Đối với phần còn lại của tài liệu này, chúng tôi sẽ đặt tiền tố ZZ0000ZZ cho tất cả các id không gian người dùng và
tất cả các id kernel có ZZ0001ZZ. Phạm vi của idmappings sẽ có tiền tố ZZ0002ZZ. Vì vậy
một bản đồ id sẽ được viết là ZZ0003ZZ.

Ví dụ: trong bản đồ id này, id ZZ0000ZZ là id ở phần trên
idmapset hoặc "idmapset không gian người dùng" bắt đầu bằng ZZ0001ZZ. Và nó được ánh xạ tới
ZZ0002ZZ là id kernel trong idmapset thấp hơn hoặc "idmapset kernel"
bắt đầu với ZZ0003ZZ.

Id kernel luôn được tạo bởi idmapping. Những idmapping như vậy được liên kết
với không gian tên người dùng. Vì chúng tôi chủ yếu quan tâm đến cách thức hoạt động của bản đồ id nên chúng tôi không
sẽ quan tâm đến cách tạo bản đồ id cũng như cách chúng được sử dụng
bên ngoài bối cảnh hệ thống tập tin. Điều này tốt nhất nên để lại lời giải thích của người dùng
không gian tên.

Không gian tên người dùng ban đầu là đặc biệt. Nó luôn có một bản đồ id của
dạng sau::

u0:k0:r4294967295

đó là bản đồ nhận dạng danh tính trên toàn bộ phạm vi id có sẵn trên này
hệ thống.

Các không gian tên người dùng khác thường có các ánh xạ id không nhận dạng, chẳng hạn như::

u0:k10000:r10000

Khi một tiến trình tạo hoặc muốn thay đổi quyền sở hữu một tập tin, hoặc khi
quyền sở hữu một tập tin được hệ thống tập tin đọc từ đĩa, id không gian người dùng là
ngay lập tức được dịch sang id kernel theo idmapping liên quan
với không gian tên người dùng có liên quan.

Ví dụ: hãy xem xét một tệp được lưu trữ trên đĩa bởi một hệ thống tệp là
thuộc sở hữu của ZZ0000ZZ:

- Nếu một hệ thống tập tin được gắn vào các không gian tên người dùng ban đầu (vì hầu hết
  hệ thống tập tin) thì bản đồ id ban đầu sẽ được sử dụng. Như chúng ta đã thấy đây là
  chỉ đơn giản là bản đồ nhận dạng. Điều này có nghĩa là id ZZ0000ZZ đọc từ đĩa
  sẽ được ánh xạ tới id ZZ0001ZZ. Vì vậy, trường ZZ0002ZZ và ZZ0003ZZ của inode
  sẽ chứa ZZ0004ZZ.

- Nếu một hệ thống tập tin được gắn với bản đồ id của ZZ0000ZZ
  sau đó ZZ0001ZZ đọc từ đĩa sẽ được ánh xạ tới ZZ0002ZZ. Vì vậy, một inode
  ZZ0003ZZ và ZZ0004ZZ sẽ chứa ZZ0005ZZ.

Thuật toán dịch thuật
----------------------

Chúng ta đã thấy sơ qua rằng có thể dịch giữa các ngôn ngữ khác nhau
idmapping. Bây giờ chúng ta sẽ xem xét kỹ hơn cách thức hoạt động của nó.

Ánh xạ chéo
~~~~~~~~~~~~

Thuật toán dịch thuật này được kernel sử dụng ở khá nhiều nơi. cho
ví dụ: nó được sử dụng khi báo cáo lại quyền sở hữu tệp cho không gian người dùng
thông qua nhóm cuộc gọi hệ thống ZZ0000ZZ.

Nếu chúng tôi đã được cấp ZZ0000ZZ từ một lần ánh xạ id, chúng tôi có thể ánh xạ id đó vào
một bản đồ id khác. Để tính năng này hoạt động, cả hai bản đồ id cần phải chứa
cùng một id kernel trong idmapset kernel của chúng. Ví dụ, hãy xem xét
các bản đồ id sau::

1. u0:k10000:r10000
 2. u20000:k10000:r10000

và chúng tôi đang ánh xạ ZZ0000ZZ xuống ZZ0001ZZ trong bản đồ id đầu tiên. Chúng tôi có thể
sau đó dịch ZZ0002ZZ thành id không gian người dùng trong bản đồ id thứ hai bằng cách sử dụng
kernel idmapset của idmapping thứ hai::

/* Ánh xạ id kernel thành id vùng người dùng trong bản đồ id thứ hai. */
 from_kuid(u20000:k10000:r10000, k11000) = u21000

Lưu ý, làm thế nào chúng ta có thể quay lại id kernel trong bản đồ id đầu tiên bằng cách đảo ngược
thuật toán::

/* Ánh xạ id không gian người dùng thành id kernel trong bản đồ id thứ hai. */
 make_kuid(u20000:k10000:r10000, u21000) = k11000

/* Ánh xạ id kernel thành id không gian người dùng trong bản đồ id đầu tiên. */
 from_kuid(u0:k10000:r10000, k11000) = u1000

Thuật toán này cho phép chúng tôi trả lời câu hỏi id không gian người dùng nhất định là gì
id kernel tương ứng với một idmapping nhất định. Để có thể trả lời
câu hỏi này cả hai bản đồ id đều cần chứa cùng một id kernel trong
idmapset kernel tương ứng.

Ví dụ: khi kernel đọc id không gian người dùng thô từ đĩa, nó sẽ ánh xạ nó xuống
vào id kernel theo bản đồ id được liên kết với hệ thống tập tin.
Giả sử hệ thống tập tin được gắn với một bản đồ id của
ZZ0000ZZ và nó đọc một tệp thuộc sở hữu của ZZ0001ZZ từ đĩa. Cái này
có nghĩa là ZZ0002ZZ sẽ được ánh xạ tới ZZ0003ZZ, đây là nội dung sẽ được lưu trữ trong
trường ZZ0004ZZ và ZZ0005ZZ của inode.

Khi ai đó trong không gian người dùng gọi ZZ0000ZZ hoặc một chức năng liên quan để nhận
thông tin quyền sở hữu về tập tin mà kernel không thể đơn giản ánh xạ id sao lưu
theo bản đồ id của hệ thống tập tin vì điều này sẽ cung cấp sai chủ sở hữu nếu
người gọi đang sử dụng bản đồ id.

Vì vậy, kernel sẽ ánh xạ id sao lưu trong bản đồ id của người gọi. Hãy
giả sử người gọi có bản đồ id hơi độc đáo
ZZ0000ZZ thì ZZ0001ZZ sẽ ánh xạ ngược lại ZZ0002ZZ.
Do đó, người dùng sẽ thấy rằng tệp này thuộc sở hữu của ZZ0003ZZ.

Ánh xạ lại
~~~~~~~~~

Có thể dịch id kernel từ idmapping này sang id khác thông qua
idmapset không gian người dùng của hai idmappings. Điều này tương đương với việc ánh xạ lại
một id hạt nhân.

Hãy xem một ví dụ. Chúng tôi được cung cấp hai idmappings sau::

1. u0:k10000:r10000
 2. u0:k20000:r10000

và chúng tôi được cấp ZZ0000ZZ trong bản đồ id đầu tiên. Để dịch cái này
id kernel trong bản đồ id đầu tiên thành id kernel trong bản đồ id thứ hai, chúng tôi
cần thực hiện hai bước:

1. Ánh xạ id kernel vào id không gian người dùng trong bản đồ id đầu tiên ::

/* Ánh xạ id kernel thành id không gian người dùng trong bản đồ id đầu tiên. */
    from_kuid(u0:k10000:r10000, k11000) = u1000

2. Ánh xạ id không gian người dùng thành id kernel trong bản đồ id thứ hai ::

/* Ánh xạ id không gian người dùng thành id kernel trong bản đồ id thứ hai. */
    make_kuid(u0:k20000:r10000, u1000) = k21000

Như bạn có thể thấy, chúng tôi đã sử dụng idmapset không gian người dùng trong cả hai bản đồ id để dịch
id kernel trong một bản đồ id thành id kernel trong một bản đồ id khác.

Điều này cho phép chúng tôi trả lời câu hỏi chúng tôi cần sử dụng id kernel nào để
lấy cùng một id không gian người dùng trong một bản đồ id khác. Để có thể trả lời
câu hỏi này cả hai bản đồ id đều cần chứa cùng một id không gian người dùng trong
idmapset không gian người dùng tương ứng.

Lưu ý, làm thế nào chúng ta có thể dễ dàng quay lại id kernel trong bản đồ id đầu tiên bằng cách
đảo ngược thuật toán:

1. Ánh xạ id kernel vào id không gian người dùng trong bản đồ id thứ hai ::

/* Ánh xạ id kernel thành id vùng người dùng trong bản đồ id thứ hai. */
    from_kuid(u0:k20000:r10000, k21000) = u1000

2. Ánh xạ id không gian người dùng thành id kernel trong bản đồ id đầu tiên ::

/* Ánh xạ id không gian người dùng thành id kernel trong ánh xạ id đầu tiên. */
    make_kuid(u0:k10000:r10000, u1000) = k11000

Một cách khác để xem xét bản dịch này là coi nó như một bản dịch đảo ngược
idmapping và áp dụng một idmapping khác nếu cả hai idmapping đều có liên quan
id không gian người dùng được ánh xạ. Điều này sẽ có ích khi làm việc với các mount được idmapped.

bản dịch không hợp lệ
~~~~~~~~~~~~~~~~~~~~

Sẽ không bao giờ hợp lệ khi sử dụng một id trong idmapset hạt nhân của một bản đồ id làm
id trong idmapset không gian người dùng của một idmapping khác hoặc cùng một id. Trong khi hạt nhân
idmapset luôn chỉ ra một idmapset trong không gian id hạt nhân không gian người dùng
idmapset cho biết id không gian người dùng. Vì vậy các bản dịch sau đây bị cấm::

/* Ánh xạ id không gian người dùng thành id kernel trong ánh xạ id đầu tiên. */
 make_kuid(u0:k10000:r10000, u1000) = k11000

/* INVALID: Ánh xạ id kernel thành id kernel trong bản đồ id thứ hai. */
 make_kuid(u10000:k20000:r10000, k110000) = k21000
                                 ~~~~~~

và sai như nhau::

/* Ánh xạ id kernel thành id không gian người dùng trong bản đồ id đầu tiên. */
 from_kuid(u0:k10000:r10000, k11000) = u1000

/* INVALID: Ánh xạ id vùng người dùng thành id vùng người dùng trong bản đồ id thứ hai. */
 from_kuid(u20000:k0:r10000, u1000) = k21000
                             ~~~~~~

Vì id không gian người dùng có loại ZZ0000ZZ và ZZ0001ZZ và id kernel có loại
ZZ0002ZZ và ZZ0003ZZ trình biên dịch sẽ báo lỗi khi chúng
gộp lại. Vì vậy, hai ví dụ trên sẽ gây ra lỗi biên dịch.

Idmappings khi tạo đối tượng hệ thống tập tin
-------------------------------------------

Các khái niệm ánh xạ id xuống hoặc ánh xạ id lên được thể hiện trong hai
các hàm kernel mà các nhà phát triển hệ thống tập tin khá quen thuộc và chúng tôi đã
đã được sử dụng trong tài liệu này::

/* Ánh xạ id không gian người dùng thành id kernel. */
 make_kuid(idmapping, uid)

/* Ánh xạ id kernel thành id vùng người dùng. */
 from_kuid(idmapping, kuid)

Chúng ta sẽ xem xét ngắn gọn cách idmappings tạo ra
các đối tượng hệ thống tập tin. Để đơn giản, chúng ta sẽ chỉ xem xét điều gì xảy ra khi
VFS đã hoàn tất việc tra cứu đường dẫn ngay trước khi nó gọi vào hệ thống tập tin
chính nó. Vì vậy, chúng tôi quan tâm đến những gì sẽ xảy ra khi ví dụ: ZZ0000ZZ là
được gọi. Chúng tôi cũng sẽ giả định rằng thư mục chúng tôi đang tạo hệ thống tập tin
các đối tượng trong đó có thể đọc và ghi được đối với mọi người.

Khi tạo một đối tượng hệ thống tập tin, người gọi sẽ xem địa chỉ của người gọi
id hệ thống tập tin. Đây chỉ là id không gian người dùng ZZ0000ZZ và ZZ0001ZZ thông thường
nhưng chúng được sử dụng riêng khi xác định quyền sở hữu tập tin, đó là lý do tại sao chúng
được gọi là "id hệ thống tập tin". Chúng thường giống hệt với uid và gid của
người gọi nhưng có thể khác nhau. Chúng ta sẽ chỉ giả sử chúng luôn giống hệt nhau
bị lạc vào quá nhiều chi tiết.

Khi người gọi vào kernel có hai điều xảy ra:

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong
   idmapping.
   (Nói chính xác, kernel sẽ chỉ xem xét các id kernel được lưu trong
   thông tin xác thực về nhiệm vụ hiện tại nhưng đối với việc học của chúng tôi, chúng tôi sẽ giả vờ điều này
   dịch xảy ra đúng lúc.)
2. Xác minh rằng id kernel của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin.

Bước thứ hai rất quan trọng vì hệ thống tập tin thông thường cuối cùng sẽ cần ánh xạ
id kernel sao lưu vào id không gian người dùng khi ghi vào đĩa.
Vì vậy, với bước thứ hai, kernel đảm bảo rằng id vùng người dùng hợp lệ có thể được
được ghi vào đĩa. Nếu không được thì kernel sẽ từ chối yêu cầu tạo để không
thậm chí từ xa có nguy cơ tham nhũng hệ thống tập tin.

Người đọc tinh tế sẽ nhận ra rằng đây chỉ đơn giản là một biến thể của
thuật toán ánh xạ chéo mà chúng tôi đã đề cập ở trên trong phần trước. Đầu tiên,
kernel ánh xạ id không gian người dùng của người gọi thành id kernel theo
ánh xạ id của người gọi và sau đó ánh xạ id kernel đó theo
bản đồ id của hệ thống tập tin.

Từ điểm triển khai, điều đáng nói là cách thể hiện bản đồ id.
Tất cả các idmappings được lấy từ không gian tên người dùng tương ứng.

- bản đồ id của người gọi (thường được lấy từ ZZ0000ZZ)
    - bản đồ id của hệ thống tập tin (ZZ0001ZZ)
    - bản đồ id của mount (ZZ0002ZZ)

Hãy xem một số ví dụ về bản đồ id người gọi/hệ thống tập tin nhưng không có mount
idmapping. Điều này sẽ cho thấy một số vấn đề mà chúng ta có thể gặp phải. Sau đó chúng tôi sẽ
xem lại/xem xét lại các ví dụ này, lần này bằng cách sử dụng bản đồ id gắn kết, để xem cách
họ có thể giải quyết các vấn đề mà chúng tôi đã quan sát trước đây.

Ví dụ 1
~~~~~~~~~

::

id người gọi: u1000
 ánh xạ id người gọi: u0:k0:r4294967295
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295

Cả người gọi và hệ thống tập tin đều sử dụng ánh xạ nhận dạng:

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong bản đồ id của người gọi::

make_kuid(u0:k0:r4294967295, u1000) = k1000

2. Xác minh rằng id kernel của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin.

Đối với bước thứ hai này, kernel sẽ gọi hàm
   ZZ0000ZZ cuối cùng tập trung vào việc gọi điện
   ZZ0001ZZ::

from_kuid(u0:k0:r4294967295, k1000) = u1000

Trong ví dụ này, cả hai bản đồ id đều giống nhau nên không có gì thú vị
trên. Cuối cùng, id vùng người dùng nằm trên đĩa sẽ là ZZ0000ZZ.

Ví dụ 2
~~~~~~~~~

::

id người gọi: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k20000:r10000

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong
   lập bản đồ::

make_kuid(u0:k10000:r10000, u1000) = k11000

2. Xác minh rằng id kernel của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin::

from_kuid(u0:k20000:r10000, k11000) = u-1

Có thể thấy ngay rằng mặc dù id không gian người dùng của người gọi có thể là
đã ánh xạ thành công vào id kernel trong phần idmapping kernel của người gọi
không thể ánh xạ id theo bản đồ id của hệ thống tập tin. Vì vậy
kernel sẽ từ chối yêu cầu tạo này.

Lưu ý rằng mặc dù ví dụ này ít phổ biến hơn vì hầu hết hệ thống tập tin không thể
được gắn với các bản đồ id không phải ban đầu, đây là một vấn đề chung như chúng ta có thể thấy trong
những ví dụ tiếp theo.

Ví dụ 3
~~~~~~~~~

::

id người gọi: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong
   lập bản đồ::

make_kuid(u0:k10000:r10000, u1000) = k11000

2. Xác minh rằng id kernel của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin::

from_kuid(u0:k0:r4294967295, k11000) = u11000

Chúng ta có thể thấy rằng bản dịch luôn thành công. Id không gian người dùng mà
hệ thống tập tin cuối cùng sẽ được đưa vào đĩa sẽ luôn giống với giá trị của
id kernel đã được tạo trong bản đồ id của người gọi. Điều này chủ yếu có hai
hậu quả.

Đầu tiên, chúng tôi không thể cho phép người gọi cuối cùng ghi vào đĩa bằng một người khác
id không gian người dùng. Chúng tôi chỉ có thể làm điều này nếu chúng tôi gắn toàn bộ hệ thống tập tin
với người gọi hoặc bản đồ id khác. Nhưng giải pháp đó chỉ giới hạn ở một số
hệ thống tập tin và không linh hoạt lắm. Nhưng đây là một trường hợp sử dụng khá
quan trọng trong khối lượng công việc được đóng gói.

Thứ hai, người gọi thường sẽ không thể tạo bất kỳ tệp nào hoặc truy cập
các thư mục có quyền chặt chẽ hơn vì không có hệ thống tập tin nào
id kernel ánh xạ vào id không gian người dùng hợp lệ trong bản đồ id của người gọi

1. Ánh xạ các id không gian người dùng thô xuống các id kernel trong bản đồ id của hệ thống tập tin ::

make_kuid(u0:k0:r4294967295, u1000) = k1000

2. Ánh xạ id hạt nhân lên tới id vùng người dùng trong bản đồ id của người gọi::

from_kuid(u0:k10000:r10000, k1000) = u-1

Ví dụ 4
~~~~~~~~~

::

id tập tin: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295

Để báo cáo quyền sở hữu đối với không gian người dùng, kernel sử dụng ánh xạ chéo
thuật toán được giới thiệu ở phần trước:

1. Ánh xạ id không gian người dùng trên đĩa vào id kernel trong hệ thống tập tin
   lập bản đồ::

make_kuid(u0:k0:r4294967295, u1000) = k1000

2. Ánh xạ id kernel vào id vùng người dùng trong bản đồ id của người gọi::

from_kuid(u0:k10000:r10000, k1000) = u-1

Thuật toán ánh xạ chéo không thành công trong trường hợp này vì id kernel trong
ánh xạ id hệ thống tập tin không thể được ánh xạ tới id không gian người dùng trong người gọi
idmapping. Do đó, kernel sẽ báo cáo quyền sở hữu tệp này dưới dạng
tràn ngập.

Ví dụ 5
~~~~~~~~~

::

id tập tin: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k20000:r10000

Để báo cáo quyền sở hữu đối với không gian người dùng, kernel sử dụng ánh xạ chéo
thuật toán được giới thiệu ở phần trước:

1. Ánh xạ id không gian người dùng trên đĩa vào id kernel trong hệ thống tập tin
   lập bản đồ::

make_kuid(u0:k20000:r10000, u1000) = k21000

2. Ánh xạ id kernel vào id vùng người dùng trong bản đồ id của người gọi::

from_kuid(u0:k10000:r10000, k21000) = u-1

Một lần nữa, thuật toán ánh xạ chéo không thành công trong trường hợp này vì id kernel trong
bản đồ id hệ thống tập tin không thể được ánh xạ tới id không gian người dùng trong người gọi
idmapping. Do đó, kernel sẽ báo cáo quyền sở hữu tệp này dưới dạng
tràn ngập.

Lưu ý rằng trong hai ví dụ cuối, mọi việc sẽ đơn giản như thế nào nếu người gọi là
bằng cách sử dụng bản đồ id ban đầu. Đối với một hệ thống tập tin được gắn với ban đầu
idmapping nó sẽ là tầm thường. Vì vậy, chúng tôi chỉ xem xét một hệ thống tập tin có
lập bản đồ của ZZ0000ZZ:

1. Ánh xạ id không gian người dùng trên đĩa vào id kernel trong hệ thống tập tin
   lập bản đồ::

make_kuid(u0:k20000:r10000, u1000) = k21000

2. Ánh xạ id kernel vào id vùng người dùng trong bản đồ id của người gọi::

from_kuid(u0:k0:r4294967295, k21000) = u21000

Idmappings trên các mount được idmapped
-----------------------------

Các ví dụ chúng ta đã thấy trong phần trước trong đó bản đồ id của người gọi
và bản đồ id của hệ thống tập tin không tương thích gây ra nhiều vấn đề cho
khối lượng công việc. Đối với một ví dụ phức tạp hơn nhưng phổ biến hơn, hãy xem xét hai vùng chứa
bắt đầu trên máy chủ. Để ngăn chặn hoàn toàn hai container ảnh hưởng
với nhau, quản trị viên có thể thường xuyên sử dụng các bản đồ id không chồng chéo khác nhau
cho hai container::

ánh xạ id container1: u0:k10000:r10000
 ánh xạ id container2: u0:k20000:r10000
 ánh xạ id hệ thống tập tin: u0:k30000:r10000

Quản trị viên muốn cung cấp quyền truy cập đọc-ghi dễ dàng cho bộ sau
của tập tin::

id thư mục: u0
 id/file1 id: u1000
 id thư mục/file2: u2000

đối với cả hai vùng chứa hiện không thể.

Tất nhiên quản trị viên có tùy chọn thay đổi quyền sở hữu một cách đệ quy thông qua
ZZ0000ZZ. Ví dụ: họ có thể thay đổi quyền sở hữu để ZZ0001ZZ và tất cả
các tệp bên dưới có thể được ánh xạ chéo từ hệ thống tệp vào vùng chứa
idmapping. Giả sử họ thay đổi quyền sở hữu để nó tương thích với
bản đồ id của vùng chứa đầu tiên::

id thư mục: u10000
 id thư mục/file1: u11000
 id/file2 id: u12000

Điều này vẫn khiến ZZ0000ZZ trở nên vô dụng đối với vùng chứa thứ hai. Trên thực tế,
ZZ0001ZZ và tất cả các tệp bên dưới nó sẽ tiếp tục xuất hiện thuộc sở hữu của tràn
cho thùng thứ hai.

Hoặc xem xét một ví dụ khác ngày càng phổ biến. Một số nhà quản lý dịch vụ như
systemd triển khai một khái niệm gọi là "thư mục chính di động". Một người dùng có thể muốn
sử dụng thư mục chính của chúng trên các máy khác nhau nơi chúng được chỉ định
id không gian người dùng đăng nhập khác nhau. Hầu hết người dùng sẽ có ZZ0000ZZ làm id đăng nhập
trên máy của họ ở nhà và tất cả các tập tin trong thư mục chính của họ thường sẽ được
thuộc sở hữu của ZZ0001ZZ. Tại trường đại học hoặc tại nơi làm việc, họ có thể có một id đăng nhập khác, chẳng hạn như
ZZ0002ZZ. Điều này khiến việc tương tác với thư mục chính của họ khá khó khăn
trên máy làm việc của họ.

Trong cả hai trường hợp, việc thay đổi quyền sở hữu một cách đệ quy đều có những tác động nghiêm trọng. nhất
một điều hiển nhiên là quyền sở hữu được thay đổi trên toàn cầu và vĩnh viễn. trong nhà
trường hợp thư mục, sự thay đổi quyền sở hữu này thậm chí cần phải xảy ra mỗi khi
người dùng chuyển từ nhà của họ sang máy làm việc của họ. Đối với các bộ thực sự lớn
các tập tin này ngày càng trở nên tốn kém.

Nếu người dùng may mắn, họ đang xử lý một hệ thống tập tin có thể gắn kết được
bên trong không gian tên người dùng. Nhưng điều này cũng sẽ thay đổi quyền sở hữu trên toàn cầu và
thay đổi về quyền sở hữu gắn liền với thời gian tồn tại của hệ thống tập tin gắn kết, tức là
siêu khối. Cách duy nhất để thay đổi quyền sở hữu là ngắt kết nối hoàn toàn
hệ thống tập tin và gắn lại nó vào không gian tên người dùng khác. Đây thường là
không thể vì điều đó có nghĩa là tất cả người dùng hiện đang truy cập vào
hệ thống tập tin không thể nữa. Và điều đó có nghĩa là ZZ0000ZZ vẫn không thể chia sẻ được
giữa hai vùng chứa có idmappings khác nhau.
Nhưng thông thường người dùng thậm chí không có tùy chọn này vì hầu hết các hệ thống tập tin
không thể gắn bên trong thùng chứa. Và việc không thể gắn kết chúng có thể là
mong muốn vì nó không yêu cầu hệ thống tập tin xử lý các phần mềm độc hại
hình ảnh hệ thống tập tin.

Tuy nhiên, các trường hợp sử dụng được đề cập ở trên và nhiều trường hợp khác có thể được xử lý bằng các giá trị gắn kết được idmapped.
Chúng cho phép trưng bày cùng một bộ răng giả với các quyền sở hữu khác nhau tại
gắn kết khác nhau. Điều này đạt được bằng cách đánh dấu các mount bằng không gian tên người dùng
thông qua cuộc gọi hệ thống ZZ0000ZZ. Bản đồ id được liên kết với nó
sau đó được sử dụng để dịch từ bản đồ id của người gọi sang hệ thống tập tin
idmapping và ngược lại bằng thuật toán ánh xạ lại mà chúng tôi đã giới thiệu ở trên.

Các giá treo được ánh xạ giúp có thể thay đổi quyền sở hữu một cách tạm thời và
cách cục bộ. Những thay đổi về quyền sở hữu được giới hạn ở một thú cưỡi cụ thể và
những thay đổi về quyền sở hữu gắn liền với thời gian tồn tại của thú cưỡi. Tất cả người dùng khác và
các vị trí mà hệ thống tập tin được hiển thị không bị ảnh hưởng.

Các hệ thống tập tin hỗ trợ gắn kết idmapped không có bất kỳ lý do thực sự nào để hỗ trợ
có thể gắn kết bên trong không gian tên người dùng. Một hệ thống tập tin có thể bị lộ
hoàn toàn dưới một giá đỡ idmapped để có được hiệu ứng tương tự. Điều này có
lợi thế là các hệ thống tập tin có thể để việc tạo siêu khối cho
người dùng đặc quyền trong không gian tên người dùng ban đầu.

Tuy nhiên, hoàn toàn có thể kết hợp các mount được idmapped với các hệ thống tập tin
có thể gắn kết bên trong không gian tên người dùng. Chúng tôi sẽ đề cập thêm về điều này bên dưới.

Các loại hệ thống tập tin so với các loại gắn kết được idmapped
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Với sự ra đời của các mount idmapped, chúng ta cần phân biệt giữa
quyền sở hữu hệ thống tập tin và quyền sở hữu gắn kết đối tượng VFS chẳng hạn như inode. các
chủ sở hữu của một nút có thể khác khi nhìn từ hệ thống tập tin
phối cảnh so với khi nhìn từ một giá treo được xác định bản đồ. Căn bản như vậy
sự khác biệt về mặt khái niệm hầu như luôn phải được thể hiện rõ ràng trong mã.
Vì vậy, để phân biệt quyền sở hữu mount được idmapped với quyền sở hữu hệ thống tập tin riêng biệt
các loại đã được giới thiệu.

Nếu uid hoặc gid đã được tạo bằng cách sử dụng hệ thống tập tin hoặc bản đồ id của người gọi
sau đó chúng ta sẽ sử dụng loại ZZ0000ZZ và ZZ0001ZZ. Tuy nhiên, nếu một uid hoặc gid
đã được tạo bằng cách sử dụng bản đồ id gắn kết thì chúng tôi sẽ sử dụng công cụ chuyên dụng
Loại ZZ0002ZZ và ZZ0003ZZ.

Tất cả các trình trợ giúp VFS tạo hoặc lấy uid và gid làm đối số đều sử dụng
Các loại ZZ0000ZZ và ZZ0001ZZ và chúng tôi sẽ có thể dựa vào trình biên dịch
để phát hiện các lỗi bắt nguồn từ việc kết hợp hệ thống tập tin với các uid và gid VFS.

Các loại ZZ0000ZZ và ZZ0001ZZ thường được ánh xạ từ và tới ZZ0002ZZ
và các loại ZZ0003ZZ tương tự như cách ánh xạ các loại ZZ0004ZZ và ZZ0005ZZ
từ và đến các loại ZZ0006ZZ và ZZ0007ZZ::

uid_t <--> kuid_t <--> vfsuid_t
 gid_t <--> kgid_t <--> vfsgid_t

Bất cứ khi nào chúng tôi báo cáo quyền sở hữu dựa trên loại ZZ0000ZZ hoặc ZZ0001ZZ,
ví dụ: trong ZZ0002ZZ hoặc lưu trữ thông tin quyền sở hữu trong đối tượng VFS được chia sẻ
dựa trên loại ZZ0003ZZ hoặc ZZ0004ZZ, ví dụ: trong ZZ0005ZZ, chúng ta có thể
sử dụng trình trợ giúp ZZ0006ZZ và ZZ0007ZZ.

Để minh họa tại sao trình trợ giúp này hiện đang tồn tại, hãy xem xét điều gì xảy ra khi chúng ta
thay đổi quyền sở hữu của một nút từ một mount được ánh xạ. Sau khi chúng tôi tạo ra
ZZ0000ZZ hoặc ZZ0001ZZ dựa trên bản đồ id gắn kết mà sau này chúng tôi cam kết thực hiện
ZZ0002ZZ hoặc ZZ0003ZZ này trở thành quyền sở hữu toàn bộ hệ thống tệp mới.
Vì vậy, chúng tôi đang biến ZZ0004ZZ hoặc ZZ0005ZZ thành ZZ0006ZZ toàn cầu
hoặc ZZ0007ZZ. Và điều này có thể được thực hiện bằng cách sử dụng ZZ0008ZZ và
ZZ0009ZZ.

Lưu ý, bất cứ khi nào một đối tượng VFS được chia sẻ, ví dụ: ZZ0000ZZ được lưu trong bộ nhớ đệm hoặc một đối tượng được lưu trong bộ nhớ đệm
ZZ0001ZZ, lưu trữ thông tin quyền sở hữu một hệ thống tập tin hoặc "toàn cầu"
Phải sử dụng ZZ0002ZZ và ZZ0003ZZ. Quyền sở hữu được thể hiện qua ZZ0004ZZ
và ZZ0005ZZ dành riêng cho giá đỡ được ánh xạ.

Chúng tôi đã lưu ý rằng các loại ZZ0000ZZ và ZZ0001ZZ được tạo dựa trên
trên idmappings gắn kết trong khi các loại ZZ0002ZZ và ZZ0003ZZ được tạo dựa trên
trên idmappings hệ thống tập tin. Để ngăn chặn việc lạm dụng ánh xạ id hệ thống tập tin để tạo
Các loại ZZ0004ZZ hoặc ZZ0005ZZ hoặc gắn bản đồ id để tạo ZZ0006ZZ
hoặc ZZ0007ZZ loại bản đồ id hệ thống tập tin và bản đồ id gắn kết là khác nhau
các loại cũng vậy.

Tất cả những người trợ giúp ánh xạ tới hoặc từ các loại ZZ0000ZZ và ZZ0001ZZ đều yêu cầu
một bản đồ id gắn kết cần được thông qua thuộc loại ZZ0002ZZ. Vượt qua
hệ thống tập tin hoặc bản đồ id người gọi sẽ gây ra lỗi biên dịch.

Tương tự như cách chúng tôi đặt tiền tố cho tất cả các id không gian người dùng trong tài liệu này bằng ZZ0000ZZ và tất cả
id hạt nhân với ZZ0001ZZ, chúng tôi sẽ đặt tiền tố tất cả các id VFS bằng ZZ0002ZZ. Vì vậy, một gắn kết
idmapping sẽ được viết là: ZZ0003ZZ.

Người trợ giúp ánh xạ lại
~~~~~~~~~~~~~~~~~

Các chức năng ánh xạ id đã được thêm vào để dịch giữa các bản đồ id. Họ tận dụng
của thuật toán ánh xạ lại mà chúng tôi đã giới thiệu trước đó. Chúng ta sẽ xem xét:

- ZZ0000ZZ và ZZ0001ZZ

Các hàm ZZ0000ZZ dịch id kernel của hệ thống tập tin thành
  Id VFS trong bản đồ id của thú cưỡi::

/* Ánh xạ id nhân của hệ thống tập tin vào id vùng người dùng trong bản đồ id của hệ thống tập tin. */
   from_kuid(filesystem, kid) = uid

/* Ánh xạ id không gian người dùng của hệ thống tập tin xuống id VFS trong bản đồ id của mount. */
   make_kuid(mount, uid) = kuid

- ZZ0000ZZ và ZZ0001ZZ

Các hàm ZZ0000ZZ dịch id kernel của người gọi thành
  id kernel trong bản đồ id của hệ thống tập tin. Bản dịch này đạt được bằng cách
  ánh xạ lại id VFS của người gọi bằng cách sử dụng idmapping của mount ::

/* Ánh xạ id VFS của người gọi vào id vùng người dùng trong bản đồ id của mount. */
   from_kuid(mount, kid) = uid

/* Ánh xạ id không gian người dùng của mount thành id kernel trong bản đồ id của hệ thống tập tin. */
   make_kuid(hệ thống tập tin, uid) = kuid

- ZZ0000ZZ và ZZ0001ZZ

Bất cứ khi nào

Lưu ý rằng hai chức năng này đảo ngược lẫn nhau. Hãy xem xét những điều sau đây
bản đồ id::

ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k20000:r10000
 gắn bản đồ id: u0:v10000:r10000

Giả sử một tệp thuộc sở hữu của ZZ0000ZZ được đọc từ đĩa. Hệ thống tập tin ánh xạ id này
tới ZZ0001ZZ theo bản đồ id của nó. Đây là những gì được lưu trữ trong
trường ZZ0002ZZ và ZZ0003ZZ của inode.

Khi người gọi truy vấn quyền sở hữu tệp này thông qua ZZ0000ZZ, kernel
thường sẽ chỉ đơn giản sử dụng thuật toán ánh xạ chéo và ánh xạ hệ thống tập tin
id kernel cho đến id không gian người dùng trong bản đồ id của người gọi.

Nhưng khi người gọi đang truy cập tệp trên mount được idmapped, kernel sẽ
đầu tiên hãy gọi ZZ0000ZZ để dịch kernel của hệ thống tập tin
id vào id VFS trong bản đồ id của mount::

i_uid_into_vfsuid(k21000):
   /* Ánh xạ id nhân của hệ thống tập tin vào id vùng người dùng. */
   from_kuid(u0:k20000:r10000, k21000) = u1000

/* Ánh xạ id vùng người dùng của hệ thống tập tin thành id VFS trong bản đồ id của mount. */
   make_kuid(u0:v10000:r10000, u1000) = v11000

Cuối cùng, khi kernel báo cáo chủ sở hữu cho người gọi, nó sẽ chuyển
Id VFS trong bản đồ id của mount thành id không gian người dùng trong người gọi
lập bản đồ::

k11000 = vfsuid_into_kuid(v11000)
  from_kuid(u0:k10000:r10000, k11000) = u1000

Chúng ta có thể kiểm tra xem thuật toán này có thực sự hoạt động hay không bằng cách xác minh điều gì xảy ra khi
chúng tôi tạo một tập tin mới. Giả sử người dùng đang tạo một tệp bằng ZZ0000ZZ.

Hạt nhân ánh xạ cái này tới ZZ0000ZZ trong bản đồ id của người gọi. Thông thường
kernel bây giờ sẽ áp dụng ánh xạ chéo, xác minh rằng ZZ0001ZZ có thể
được ánh xạ tới id không gian người dùng trong bản đồ id của hệ thống tệp. Vì ZZ0002ZZ không thể
được ánh xạ trực tiếp vào bản đồ id của hệ thống tập tin theo yêu cầu tạo này
thất bại.

Nhưng khi người gọi đang truy cập tệp trên mount được idmapped, kernel sẽ
đầu tiên gọi ZZ0000ZZ từ đó dịch kernel id của người gọi thành
id VFS theo bản đồ id của mount::

mapped_fsuid(k11000):
    /* Ánh xạ id kernel của người gọi vào id vùng người dùng trong bản đồ id của mount. */
    from_kuid(u0:k10000:r10000, k11000) = u1000

/* Ánh xạ id không gian người dùng của mount thành id kernel trong bản đồ id của hệ thống tập tin. */
    make_kuid(u0:v20000:r10000, u1000) = v21000

Cuối cùng, khi ghi vào đĩa, kernel sẽ ánh xạ ZZ0000ZZ thành một
id không gian người dùng trong bản đồ id của hệ thống tập tin ::

k21000 = vfsuid_into_kuid(v21000)
   from_kuid(u0:k20000:r10000, k21000) = u1000

Như chúng ta có thể thấy, chúng ta kết thúc với một thông tin không thể đảo ngược và do đó
thuật toán bảo toàn. Một tệp được tạo từ ZZ0000ZZ trên giá treo được idmapped sẽ
cũng được báo cáo là thuộc sở hữu của ZZ0001ZZ và ngược lại.

Bây giờ chúng ta hãy xem xét lại ngắn gọn các ví dụ thất bại trước đó trong ngữ cảnh
của các mount được idmapped.

Ví dụ 2 được xem xét lại
~~~~~~~~~~~~~~~~~~~~~~

::

id người gọi: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k20000:r10000
 gắn bản đồ id: u0:v10000:r10000

Khi người gọi đang sử dụng bản đồ id không phải ban đầu, trường hợp phổ biến là đính kèm
cùng một bản đồ id cho mount. Bây giờ chúng ta thực hiện ba bước:

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong bản đồ id của người gọi::

make_kuid(u0:k10000:r10000, u1000) = k11000

2. Dịch id VFS của người gọi thành id kernel trong hệ thống tập tin
   lập bản đồ::

mapped_fsuid(v11000):
      /* Ánh xạ id VFS thành id không gian người dùng trong bản đồ id của mount. */
      from_kuid(u0:v10000:r10000, v11000) = u1000

/* Ánh xạ id không gian người dùng thành id kernel trong bản đồ id của hệ thống tập tin. */
      make_kuid(u0:k20000:r10000, u1000) = k21000

3. Xác minh rằng id kernel của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin::

from_kuid(u0:k20000:r10000, k21000) = u1000

Vì vậy quyền sở hữu trên đĩa sẽ là ZZ0000ZZ.

Ví dụ 3 được xem xét lại
~~~~~~~~~~~~~~~~~~~~~~

::

id người gọi: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295
 gắn bản đồ id: u0:v10000:r10000

Thuật toán dịch tương tự hoạt động với ví dụ thứ ba.

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong bản đồ id của người gọi::

make_kuid(u0:k10000:r10000, u1000) = k11000

2. Dịch id VFS của người gọi thành id kernel trong hệ thống tập tin
   lập bản đồ::

mapped_fsuid(v11000):
       /* Ánh xạ id VFS thành id không gian người dùng trong bản đồ id của mount. */
       from_kuid(u0:v10000:r10000, v11000) = u1000

/* Ánh xạ id không gian người dùng thành id kernel trong bản đồ id của hệ thống tập tin. */
       make_kuid(u0:k0:r4294967295, u1000) = k1000

3. Xác minh rằng id kernel của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin::

from_kuid(u0:k0:r4294967295, k1000) = u1000

Vì vậy quyền sở hữu trên đĩa sẽ là ZZ0000ZZ.

Ví dụ 4 được xem xét lại
~~~~~~~~~~~~~~~~~~~~~~

::

id tập tin: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295
 gắn bản đồ id: u0:v10000:r10000

Để báo cáo quyền sở hữu không gian người dùng, kernel hiện thực hiện ba bước bằng cách sử dụng
thuật toán dịch mà chúng tôi đã giới thiệu trước đó:

1. Ánh xạ id không gian người dùng trên đĩa vào id kernel trong hệ thống tập tin
   lập bản đồ::

make_kuid(u0:k0:r4294967295, u1000) = k1000

2. Dịch id kernel thành id VFS trong bản đồ id của mount::

i_uid_into_vfsuid(k1000):
      /* Ánh xạ id kernel thành id vùng người dùng trong bản đồ id của hệ thống tập tin. */
      from_kuid(u0:k0:r4294967295, k1000) = u1000

/* Ánh xạ id không gian người dùng thành id VFS trong bản đồ id của mount. */
      make_kuid(u0:v10000:r10000, u1000) = v11000

3. Ánh xạ id VFS vào id không gian người dùng trong bản đồ id của người gọi::

k11000 = vfsuid_into_kuid(v11000)
    from_kuid(u0:k10000:r10000, k11000) = u1000

Trước đó, id kernel của người gọi không thể được ánh xạ chéo trong hệ thống tập tin
idmapping. Với giá đỡ được idmapped, giờ đây nó có thể được ánh xạ chéo vào
bản đồ id của hệ thống tập tin thông qua bản đồ id của mount. Bây giờ tập tin sẽ được tạo
với ZZ0000ZZ theo bản đồ id của thú cưỡi.

Ví dụ 5 được xem xét lại
~~~~~~~~~~~~~~~~~~~~~~

::

id tập tin: u1000
 ánh xạ id người gọi: u0:k10000:r10000
 ánh xạ id hệ thống tập tin: u0:k20000:r10000
 gắn bản đồ id: u0:v10000:r10000

Một lần nữa, để báo cáo quyền sở hữu vùng người dùng, kernel hiện thực hiện ba
các bước sử dụng thuật toán dịch mà chúng tôi đã giới thiệu trước đó:

1. Ánh xạ id không gian người dùng trên đĩa vào id kernel trong hệ thống tập tin
   lập bản đồ::

make_kuid(u0:k20000:r10000, u1000) = k21000

2. Dịch id kernel thành id VFS trong bản đồ id của mount::

i_uid_into_vfsuid(k21000):
      /* Ánh xạ id kernel thành id vùng người dùng trong bản đồ id của hệ thống tập tin. */
      from_kuid(u0:k20000:r10000, k21000) = u1000

/* Ánh xạ id không gian người dùng thành id VFS trong bản đồ id của mount. */
      make_kuid(u0:v10000:r10000, u1000) = v11000

3. Ánh xạ id VFS vào id không gian người dùng trong bản đồ id của người gọi::

k11000 = vfsuid_into_kuid(v11000)
    from_kuid(u0:k10000:r10000, k11000) = u1000

Trước đó, id hạt nhân của tệp không thể được ánh xạ chéo trong hệ thống tệp
idmapping. Với giá đỡ được idmapped, giờ đây nó có thể được ánh xạ chéo vào
bản đồ id của hệ thống tập tin thông qua bản đồ id của mount. Tệp hiện thuộc quyền sở hữu của
ZZ0000ZZ theo bản đồ id của thú cưỡi.

Thay đổi quyền sở hữu trên một thư mục chính
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Ở trên chúng ta đã thấy cách sử dụng các mount idmapped để dịch giữa
idmappings khi người gọi, hệ thống tập tin hoặc cả hai đều sử dụng tên không phải ban đầu
idmapping. Có rất nhiều trường hợp sử dụng khi người gọi đang sử dụng
một bản đồ id không ban đầu. Điều này chủ yếu xảy ra trong bối cảnh container hóa
khối lượng công việc. Hậu quả là như chúng ta đã thấy đối với cả hai, hệ thống tập tin
được gắn với hệ thống tập tin và bản đồ id ban đầu được gắn với không phải ban đầu
idmappings, quyền truy cập vào hệ thống tập tin không hoạt động vì id kernel không thể
được ánh xạ chéo giữa ánh xạ id của người gọi và hệ thống tập tin.

Như chúng ta đã thấy ở trên, các mount được idmapped cung cấp giải pháp cho vấn đề này bằng cách ánh xạ lại
bản đồ id của người gọi hoặc hệ thống tập tin theo bản đồ id của mount.

Ngoài khối lượng công việc được chứa trong container, các mount được idmapped còn có ưu điểm là
chúng cũng hoạt động khi cả người gọi và hệ thống tập tin đều sử dụng tên ban đầu
idmapping có nghĩa là người dùng trên máy chủ có thể thay đổi quyền sở hữu các thư mục
và các tập tin trên cơ sở mỗi lần gắn kết.

Hãy xem xét ví dụ trước của chúng tôi trong đó người dùng có thư mục chính của họ trên thiết bị di động
lưu trữ. Ở nhà họ có id ZZ0000ZZ và tất cả các tập tin trong thư mục chính của họ
được sở hữu bởi ZZ0001ZZ trong khi ở trường đại học hoặc nơi làm việc họ có id đăng nhập ZZ0002ZZ.

Mang theo thư mục chính của họ trở thành vấn đề. Họ không thể dễ dàng
truy cập các tập tin của họ, họ có thể không ghi được vào đĩa nếu không áp dụng
quyền hoặc ACL lỏng lẻo và thậm chí nếu có thể, chúng sẽ gây ra sự khó chịu
kết hợp các tập tin và thư mục thuộc sở hữu của ZZ0000ZZ và ZZ0001ZZ.

Gắn kết Idmapped cho phép giải quyết vấn đề này. Người dùng có thể tạo một bản đồ id
gắn kết thư mục chính của họ trên máy tính ở cơ quan hoặc máy tính ở nhà
tùy thuộc vào quyền sở hữu mà họ muốn sử dụng bộ lưu trữ di động
chính nó.

Giả sử họ muốn tất cả các tệp trên đĩa thuộc về ZZ0000ZZ. Khi người dùng
cắm thiết bị lưu trữ di động tại trạm làm việc của mình, họ có thể thiết lập công việc
tạo một giá trị gắn kết idmapped với idmapping ZZ0001ZZ tối thiểu. Vậy bây giờ
Khi họ tạo một tập tin, kernel sẽ thực hiện các bước sau mà chúng ta đã biết
từ trên cao:::

id người gọi: u1125
 ánh xạ id người gọi: u0:k0:r4294967295
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295
 gắn bản đồ id: u1000:v1125:r1

1. Ánh xạ id không gian người dùng của người gọi vào id kernel trong bản đồ id của người gọi::

make_kuid(u0:k0:r4294967295, u1125) = k1125

2. Dịch id VFS của người gọi thành id kernel trong hệ thống tập tin
   lập bản đồ::

mapped_fsuid(v1125):
      /* Ánh xạ id VFS thành id không gian người dùng trong bản đồ id của mount. */
      from_kuid(u1000:v1125:r1, v1125) = u1000

/* Ánh xạ id không gian người dùng thành id kernel trong bản đồ id của hệ thống tập tin. */
      make_kuid(u0:k0:r4294967295, u1000) = k1000

3. Xác minh rằng id hệ thống tệp của người gọi có thể được ánh xạ tới id vùng người dùng trong
   bản đồ id của hệ thống tập tin::

from_kuid(u0:k0:r4294967295, k1000) = u1000

Vì vậy, cuối cùng tệp sẽ được tạo bằng ZZ0000ZZ trên đĩa.

Bây giờ chúng ta hãy xem xét ngắn gọn quyền sở hữu mà người gọi có id ZZ0000ZZ sẽ thấy
trên máy tính làm việc của họ:

::

id tập tin: u1000
 ánh xạ id người gọi: u0:k0:r4294967295
 ánh xạ id hệ thống tập tin: u0:k0:r4294967295
 gắn bản đồ id: u1000:v1125:r1

1. Ánh xạ id không gian người dùng trên đĩa vào id kernel trong hệ thống tập tin
   lập bản đồ::

make_kuid(u0:k0:r4294967295, u1000) = k1000

2. Dịch id kernel thành id VFS trong bản đồ id của mount::

i_uid_into_vfsuid(k1000):
      /* Ánh xạ id kernel thành id vùng người dùng trong bản đồ id của hệ thống tập tin. */
      from_kuid(u0:k0:r4294967295, k1000) = u1000

/* Ánh xạ id không gian người dùng thành id VFS trong bản đồ id của mount. */
      make_kuid(u1000:v1125:r1, u1000) = v1125

3. Ánh xạ id VFS vào id không gian người dùng trong bản đồ id của người gọi::

k1125 = vfsuid_into_kuid(v1125)
    from_kuid(u0:k0:r4294967295, k1125) = u1125

Vì vậy, cuối cùng người gọi sẽ được thông báo rằng tệp thuộc về ZZ0000ZZ
đó là id không gian người dùng của người gọi trên máy trạm của họ trong ví dụ của chúng tôi.

Id không gian người dùng thô được đặt trên đĩa là ZZ0000ZZ vì vậy khi người dùng lấy
thư mục chính của họ trở lại máy tính ở nhà nơi họ được chỉ định
ZZ0001ZZ sử dụng bản đồ id ban đầu và gắn kết hệ thống tập tin với id ban đầu
idmapping họ sẽ thấy tất cả các tệp thuộc sở hữu của ZZ0002ZZ.